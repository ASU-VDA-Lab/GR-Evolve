# NEWGR vs FastRoute: Key Algorithmic Changes

This document explains the four most impactful changes introduced in NEWGR relative to the
baseline FastRoute implementation, with code comparisons for each.

---

## Change 1: Priority-Based Net Scheduling

### Background

In global routing, nets are processed sequentially. The first net routed gets first pick of
routing resources. If a large, complex net is processed late, the grid is already partially
occupied and the net may be forced into a long detour — increasing congestion for everyone else.

### What FastRoute Does

Nets are added to `net_ids_` one by one as they are registered from the design database.
This order is never changed before any routing phase:

```cpp
// fastroute — FastRoute.cpp
// Called once per net during database iteration.
// Order = database insertion order (arbitrary from a routing perspective).
if (!is_local) {
  net_ids_.push_back(netID);
}
```

The routing phases then consume this list as-is, with no sorting:

```cpp
// fastroute — FastRoute.cpp
gen_brk_RSMT(true, true, true, false, noADJ);
newrouteLAll(false, true);
spiralRouteAll();
newrouteZAll(10);
```

### What NEWGR Does

NEWGR defines a sort function that ranks nets by a composite priority score, and calls it
before every major routing phase:

```cpp
// NEWGR — FastRoute.cpp
auto sort_wirelength_priority_nets = [&]() {
  std::stable_sort(net_ids_.begin(), net_ids_.end(),
    [&](int lhs_id, int rhs_id) {
      auto net_priority = [](const FrNet* net) {
        // HPWL scaled up by log(pin count) — large multi-pin nets score higher
        const double hpwl_weight = hpwl * (1.0 + 0.95 * log1p(pin_count));
        // Layer span — nets crossing many layers need more routing resources
        const double layer_weight = layer_span * (180.0 + 0.10 * hpwl);
        // Clock nets always go first regardless of size
        const double clock_bias = net->isClock() ? 1500.0 : 0.0;
        return hpwl_weight + layer_weight + clock_bias;
      };
      return net_priority(lhs) > net_priority(rhs);  // highest score first
    });
};
```

The sort is applied before each routing phase:

```cpp
// NEWGR — FastRoute.cpp
gen_brk_RSMT(true, true, true, false, noADJ);
sort_wirelength_priority_nets();   // <-- added
newrouteLAll(false, true);

sort_wirelength_priority_nets();   // <-- added
spiralRouteAll();

sort_wirelength_priority_nets();   // <-- added
newrouteZAll(10);
```

### Why This Produces Better Results

Routing the most complex, long-distance, and clock nets first ensures that the important nets
claim routing resources while the grid is still uncongested. Smaller, simpler nets are
routed into the remaining gaps. This reduces the chance of any net being forced into a
detour, lowering overall overflow and wirelength.

---

## Change 2: Always-On Maze Ordering

### Background

Each maze iteration can optionally sort nets by their congestion load before routing them,
so the most congested nets are ripped up and rerouted first. This is controlled by an
`ordering` flag passed to `mazeRouteMSMD`.

### What FastRoute Does

`fastroute` toggles congestion-based ordering on only every third iteration using `!(i % 3)`:

```cpp
// fastroute — FastRoute.cpp
mazeRouteMSMD(i,
              enlarge_,
              ripup_threshold,
              mazeedge_threshold_,
              !(i % 3),   // true on iterations 0, 3, 6, 9 ... false otherwise
              VIA, L, cost_params, slack_th);
```

Inside `mazeRouteMSMD`, when `ordering` is false, nets are processed in insertion order
instead of congestion order:

```cpp
// maze.cpp
if (ordering) {
  StNetOrder();   // sorts nets: most congested first
}
// uses sort order if ordering=true, insertion order if false
const int netID = ordering ? tree_order_cong_[nidRPC].treeIndex : net_ids_[nidRPC];
```

### What NEWGR Does

NEWGR passes `true` unconditionally so that congestion-ordered routing is applied on
every iteration:

```cpp
// NEWGR — FastRoute.cpp
mazeRouteMSMD(i,
              enlarge_,
              ripup_threshold,
              mazeedge_threshold_,
              true,        // always sort by congestion
              VIA, L, cost_params, slack_th);
```

### Why This Produces Better Results

On the two out of three iterations where `fastroute` skips the sort, a lightly congested
net may be rerouted before a heavily congested one, wasting maze search budget on easy
nets while hard ones wait. Sorting every iteration ensures the most overloaded edges are
always addressed first, making each iteration as effective as possible at reducing overflow.

---

## Change 3: Bounding Box Detour Penalty in Maze Routing

### Background

When the maze router rips up and reroutes a tree edge, it searches within a rectangular
region expanded around the edge's two endpoints. Within this region, any path from source
to sink is considered valid. Without any guidance, the router may take a long detour around
congestion even when that detour adds unnecessary wirelength.

### What FastRoute Does

`fastroute` computes a fixed search window and applies no penalty for moving outside
the edge's bounding box:

```cpp
// fastroute — maze.cpp
// Search window is purely a function of iteration count and edge route length.
enlarge_ = std::min(origENG, (iter / 6 + 3) * treeedge->route.routelen);

const int regionX1 = std::max(xmin - enlarge_, 0);
const int regionX2 = std::min(xmax + enlarge_, x_grid_ - 1);
const int regionY1 = std::max(ymin - enlarge_, 0);
const int regionY2 = std::min(ymax + enlarge_, y_grid_ - 1);
// No penalty for moving far from [xmin..xmax, ymin..ymax] inside this window.
```

### What NEWGR Does

NEWGR makes two additions.

**First**, the search window is capped by the actual Manhattan length of the edge, so
short edges are not given an oversized search region:

```cpp
// NEWGR — maze.cpp
enlarge_ = std::min(origENG, (iter / 6 + 3) * treeedge->route.routelen);
const int manhattan_len   = treeedge->len;
const double expand_ratio = zero_overflow_refine ? 0.12 : 0.35;
const int dynamic_cap     = 1 + round(manhattan_len * expand_ratio);
// effective_enlarge is at most 35% of the edge length in normal mode
const int effective_enlarge = std::max(3, std::min(enlarge_, dynamic_cap));

const int regionX1 = std::max(xmin - effective_enlarge, 0);
const int regionX2 = std::min(xmax + effective_enlarge, x_grid_ - 1);
```

**Second**, inside the `relaxAdjacent` lambda — the function that evaluates every candidate
grid step during the maze search — NEWGR adds an explicit cost penalty for each tile the
route moves outside the edge's bounding box:

```cpp
// NEWGR — maze.cpp:  (inside relaxAdjacent lambda)
// edge_bbox_{xmin,xmax,ymin,ymax} = bounding box of the two endpoints being connected
// edge_bbox_margin = allowed slack around the box (0-2 tiles, depending on phase)
int bbox_detour = 0;
if (next_x < edge_bbox_xmin - edge_bbox_margin)
  bbox_detour += edge_bbox_xmin - edge_bbox_margin - next_x;
else if (next_x > edge_bbox_xmax + edge_bbox_margin)
  bbox_detour += next_x - (edge_bbox_xmax + edge_bbox_margin);
if (next_y < edge_bbox_ymin - edge_bbox_margin)
  bbox_detour += edge_bbox_ymin - edge_bbox_margin - next_y;
else if (next_y > edge_bbox_ymax + edge_bbox_margin)
  bbox_detour += next_y - (edge_bbox_ymax + edge_bbox_margin);

if (bbox_detour > 0)
  tmp += detour_unit_cost * bbox_detour;   // added to cost before updateAdjacent
```

The penalty strength and allowed margin adapt to the current routing phase:

```cpp
// NEWGR — maze.cpp:
const bool zero_overflow_mode    = total_overflow_ == 0;
const bool wirelength_focus_mode = zero_overflow_mode || iter > overflow_iterations_ / 2;

// Tiles outside the box that are still penalty-free
edge_bbox_margin = zero_overflow_mode ? 0 : (wirelength_focus_mode ? 1 : 2);
// Cost added per tile of detour beyond the margin
detour_unit_cost = zero_overflow_mode ? 1.55 : (wirelength_focus_mode ? 0.80 : 0.10);
```

### Why This Produces Better Results

Without this penalty, the maze router takes detours freely whenever congestion makes the
direct path slightly more expensive, accumulating unnecessary wirelength across many nets.
The bounding box penalty makes such detours explicitly more expensive: the router only
takes them when the congestion saving is large enough to justify the wirelength cost. In
zero-overflow mode (the final cleanup phase), the margin shrinks to zero and the penalty
rises to 1.55 per tile, strongly pulling routes back toward their shortest path and
recovering wirelength accumulated during congestion resolution.

---

## Change 4: Adaptive Via Costs in Layer Assignment

### Background

Layer assignment maps each 2D route segment onto a specific metal layer using dynamic
programming (DP). At every layer transition (via), the DP adds a via cost. The quality of
the assignment — how many vias are used and whether they land on congested layers —
depends entirely on how this cost is set.

### What FastRoute Does

`fastroute` uses a fixed formula: via cost is proportional only to the number of layers
crossed, plus a resistance term:

```cpp
// fastroute — utility.cpp:
// Same cost on iteration 1 as on iteration 50.
// Same whether the destination layer is empty or fully congested.
int base_via_cost  = abs(i - l) * (k == 0 ? 2 : 3);
int total_via_cost = base_via_cost + via_resistance_cost;

if (gridD[i][k] > gridD[l][k] + total_via_cost) {
  gridD[i][k] = gridD[l][k] + total_via_cost;
}
```

### What NEWGR Does

NEWGR adds two new cost components before computing `total_via_cost`.

**Component 1 — Phase-dependent scaling**: via penalties grow as routing converges, so
the DP is flexible early but discourages unnecessary vias near the end:

```cpp
// NEWGR — utility.cpp:
// iter_ratio = how far through the full routing flow we are (0.0 -> 1.0)
const double iter_ratio = (double)layer_assign_iter_snapshot_
                        / layer_assign_total_iters_snapshot_;

auto iterationPenaltyScale = [&](int layer_delta) -> double {
  if (layer_delta == 0)   return 0.0;   // no layer change: no penalty
  if (iter_ratio <= 0.2)  return 0.0;   // early phase: full flexibility
  if (iter_ratio >= 0.7) {
    double late = (iter_ratio - 0.7) / 0.3;
    return 2.0 + 3.0 * late;            // late phase: up to 5x penalty
  }
  double mid = (iter_ratio - 0.2) / 0.5;
  return 0.3 + 1.7 * mid;              // mid phase: ramps from 0.3x to 2.0x
};
```

**Component 2 — Congestion-aware penalty**: adds extra cost if the destination layer is
already overloaded, using an S-curve (logistic function) that activates sharply only when
a layer is genuinely congested:

```cpp
// NEWGR — utility.cpp:
// Sample actual edge usage/capacity ratio at the via location
auto localLayerCongestion = [&](int layer, int grid_idx) -> double {
  accum += sampleEdgeRatio(h_edges_3D_[layer][gy][gx]);
  accum += sampleEdgeRatio(v_edges_3D_[layer][gy][gx]);
  return accum / samples;  // returns usage / capacity ratio
};

auto congestionPenalty = [&](int from_layer, int to_layer,
                              int grid_idx, int reference_cost,
                              double phase_scale) -> int {
  const double avg_ratio = (localLayerCongestion(from_layer, grid_idx)
                          + localLayerCongestion(to_layer, grid_idx)) * 0.5;
  if (avg_ratio <= 1.0) return 0;  // not congested: no penalty

  const double overflow = avg_ratio - 1.0;
  // S-curve: penalty grows sharply once a layer is genuinely overloaded
  const double logistic = 1.0 / (1.0 + exp(-4.0 * overflow));
  const double penalty_scale = 2.0 * (0.4 + logistic) * overflow * phase_scale;
  return round(reference_cost * penalty_scale);
};
```

The DP via cost is then composed from all three parts:

```cpp
// NEWGR — utility.cpp:
const int base_via_cost     = layer_delta * (k == 0 ? 2 : 3);
const double phase_scale    = iterationPenaltyScale(layer_delta);
const int adaptive_via_cost = round(base_via_cost * phase_scale);
const int congestion_penalty = congestionPenalty(l, i, k, base_via_cost, phase_scale);

int total_via_cost = adaptive_via_cost + via_resistance_cost + congestion_penalty;

if (gridD[i][k] > gridD[l][k] + total_via_cost) {
  gridD[i][k] = gridD[l][k] + total_via_cost;
}
```

**Side-by-side comparison of the DP cost line:**

```cpp
// fastroute:
int total_via_cost = base_via_cost + via_resistance_cost;

// NEWGR:
int total_via_cost = adaptive_via_cost   // grows with routing progress
                   + via_resistance_cost  // unchanged
                   + congestion_penalty;  // penalises already-full layers
```

### Why This Produces Better Results

Early in routing, the DP needs freedom to explore different layer combinations, so the via
cost stays low. As routing converges, the rising `iterationPenaltyScale` discourages
unnecessary layer switches that would add vias without improving routability. The
`congestionPenalty` steers vias away from layers already at capacity: the logistic
S-curve means the penalty is near-zero for lightly loaded layers but grows sharply once
`usage/capacity > 1`, so it only activates where it truly matters. Together, these two
terms produce layer assignments with fewer total vias and better load balance across layers.

