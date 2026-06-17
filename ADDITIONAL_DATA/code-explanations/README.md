
# Code Explanation snippets


1. [CUGR_AES](#cugr_aessky130-vs-cugr-key-algorithmic-changes)
2. [FR_IBEX](#fr_ibex-vs-fastroute-key-algorithmic-changes)
3. [SPR_IBEX](#spr_ibex-vs-sproute-key-algorithmic-changes)


## CUGR_AES(SKY130) vs CUGR: Key Algorithmic Changes

### Change 1: Hard-First Net Ordering

#### Background

In global routing, nets are routed sequentially. The first net processed gets first pick of
routing resources on the grid. If a large, complex net is processed later after many simpler
nets have already claimed resources and may be forced into a congested detour, increasing
overflow for both itself and surrounding nets.

#### What CUGR Does

CUGR sorts all nets by half-perimeter wirelength (HPWL) in ascending order before routing,
meaning small, short nets are always routed first:

```cpp
// CUGR — CUGR.cpp
// Nets sorted by ascending HPWL: shortest (easiest) nets go first.
return halfParameters[lhs] < halfParameters[rhs];
```

#### What CUGR_AES Does

CUGR_AES reverses the sort order, routing the longest and highest pin-count nets first. Pin
count is used as a tiebreaker so that complex multi-pin nets take priority over simpler
nets of similar span:

```cpp
// CUGR_AES — CUGR.cpp
// Hard (long, high-pin) nets first.
if (halfParameters[lhs] != halfParameters[rhs]) {
    return halfParameters[lhs] > halfParameters[rhs];
}
return pinCounts[lhs] > pinCounts[rhs];
```

CUGR_AES also pre-computes pin counts explicitly to enable this secondary sort:

```cpp
// CUGR_AES — CUGR.cpp
std::vector<int> pinCounts(gr_nets_.size());
// ...
pinCounts[netIndex] = net->getNumPins();
```

#### Why This Produces Better Results

Nets large bounding boxes and many pins are the primary source of
routing overflow. Routing them first ensures they claim tracks while the grid is still
uncongested. Simpler nets are then routed into whatever space remains, which is generally
sufficient for them. Routing easy nets first has the opposite effect: it consumes resources
in regions that hard nets urgently need, forcing detours and creating overflow hotspots.

---

### Change 2: Long-Segment Layer Promotion

#### Background

Long wire segments routed on lower layers are a major source of congestion.
Ideally, long wires should be pushed to higher metal layers, which have more tracks and
lower per-unit congestion.

#### What CUGR Does

During 3D pattern routing, CUGR evaluates wire cost uniformly across all candidate layers.
The DP simply picks whichever layer has the lowest base wire cost, with no preference for
assigning long segments to higher layers:

```cpp
// CUGR — PatternRoute.cpp
// Wire cost is evaluated identically on every layer; no layer preference for long wires.
CostT cost = path->getCosts()[layerIndex]
             + grid_graph_->getWireCost(layerIndex, *node, *path);
```

#### What CUGR_AES Does

CUGR_AES first identifies whether a segment is "long" by comparing its length to a tunable
threshold. For long segments, it multiplies the wire cost on lower layers by a bias factor
that grows with distance from the top preferred layer for that routing direction. This makes
lower layers artificially more expensive for long wires, steering the 3D DP toward higher layers:

```cpp
// CUGR_AES — PatternRoute.cpp
// Flag long segments based on a tunable threshold.
const int segment_len = std::abs((*node)[direction] - (*path)[direction]);
const bool promote_long = segment_len >= constants_.long_segment_threshold;
```

```cpp
// CUGR_AES — PatternRoute.cpp
// For long segments, inflate the wire cost on lower layers proportionally
// to how far below the top preferred layer the candidate layer is.
CostT wire_cost = grid_graph_->getWireCost(layerIndex, *node, *path);
if (promote_long && top_layer_for_dir[direction] != -1
    && top_layer_for_dir[direction] > layerIndex) {
    const int diff = top_layer_for_dir[direction] - layerIndex;
    wire_cost *= (1.0 + constants_.long_segment_layer_bias * diff);
}
CostT cost = path->getCosts()[layerIndex] + wire_cost;
```

#### Why This Produces Better Results

Long horizontal and vertical segments are the dominant cause of lower-layer congestion.
By making lower layers artificially more expensive for long wires, the 3D DP naturally
assigns them to higher metal layers, freeing the lower layers for the short pin-access
segments that genuinely need to reside there. This reduces peak congestion on the layers
closest to the pin layer and lowers overall overflow without increasing total wirelength.

---

### Change 3: Removal of Unconditional Pin Layer Extension

#### Background

During access-point selection, the router records which metal layers each pin can be
accessed on. This interval informs the 3D pattern routing,
which must plan via stacks to connect to the pin on those layers. Overstating the interval
forces the router to model more layers as occupied than the pin actually requires, consuming
routing resources unnecessarily near pin regions.

#### What CUGR Does

After selecting the best access point for each pin, CUGR unconditionally extends every
pin's fixed layer interval upward by 2 additional layers. It does this for all pins
regardless of their actual layer connectivity:

```cpp
// CUGR — GridGraph.cpp
const PointT selectedPoint = accessPoints[bestIndex];
const AccessPoint ap{selectedPoint, {}};
auto it = selected_access_points.emplace(ap).first;
// ...
// Collect layers from all co-located access points.
for (const auto& point : accessPoints) {
    if (point.x() == selectedPoint.x() && point.y() == selectedPoint.y()) {
        fixedLayerInterval.Update(point.getLayerIdx());
    }
}

// Extend the fixed layers to 2 layers higher to facilitate track switching.
for (auto& accessPoint : selected_access_points) {
    IntervalT& fixedLayers = accessPoint.layers;
    fixedLayers.SetHigh(
        std::min(fixedLayers.high() + 2, (int) getNumLayers() - 1));
}
```

#### What CUGR_AES Does

CUGR_AES removes the blanket extension entirely. The fixed layer interval is set only from
the layer of the actually selected access point, reflecting true pin connectivity:

```cpp
// CUGR_AES — GridGraph.cpp
const GRPoint& selectedPoint = accessPoints[bestIndex];
const AccessPoint ap{{selectedPoint.x(), selectedPoint.y()}, {}};
auto [it, inserted] = selected_access_points.emplace(ap);
// ...
// Record only the layer of the selected access point — no artificial extension.
if (!fixedLayerInterval.IsValid()) {
    fixedLayerInterval.Set(selectedPoint.getLayerIdx());
} else {
    fixedLayerInterval.Update(selectedPoint.getLayerIdx());
}
// (no layer extension block)
```

#### Why This Produces Better Results

The +2 layer extension forces via stacks around every pin to span more layers than the
pin physically requires. This inflates via demand and overstates resource consumption
in pin regions, causing the congestion model to see those regions as more crowded than
they are. Removing the extension gives the router an accurate picture of which layers
are truly pinned, resulting in shorter via stacks, more accurate congestion estimates
near pins, and better use of available routing resources.

---

### Change 4: Adaptive Maze Search Grid Density

#### Background

CUGR's multi-level maze routing first coarsens the G-cell grid into a sparser grid, runs
A* on the coarser graph to identify a good routing corridor, then performs fine-grained
maze routing within that corridor. The coarsening step size controls the size of the
reduced graph: a large step produces a coarser, faster search, but may miss better
routing paths. A smaller step explores more of the grid but takes longer.

#### What CUGR Does

CUGR uses a single fixed step size of 10×10 for all nets regardless of their size or
complexity:

```cpp
// CUGR — CUGR.cpp
// One fixed coarse grid for every net, regardless of size.
SparseGrid grid(10, 10, 0, 0);
```

#### What CUGR_AES Does

CUGR_AES uses a finer baseline step of 8×8 and further scales the step size down based on
the net's bounding-box half-perimeter (HPWL). Larger nets — which span more G-cells and
have more potential routing corridors — receive a denser search grid:

```cpp
// CUGR_AES — CUGR.cpp
// Finer baseline grid, then adapted to net size.
SparseGrid grid(8, 8, 0, 0);
// ...
const int hp = net->getBoundingBox().hp();
if (hp >= 80) {
    grid.reset(5, 5);   // large net: finest search
} else if (hp >= 40) {
    grid.reset(6, 6);   // medium net
} else {
    grid.reset(7, 7);   // smaller net
}
```

#### Why This Produces Better Results

Large nets traverse more G-cells and have more potential detour paths through the grid.
A coarse fixed step size causes the maze router to collapse too many G-cells into a
single coarsened node, averaging out local congestion differences and missing
less-congested corridors. By scaling the grid density to net size, CUGR_AES gives larger
and harder to route nets a more thorough search, improving the quality
of the maze solution, while keeping the search fast for small nets
that do not need the extra resolution.



## FR_IBEX vs FastRoute: Key Algorithmic Changes

This document explains the four most impactful changes introduced in FR_IBEX relative to the
baseline FastRoute implementation, with code comparisons for each.

---

### Change 1: Priority-Based Net Scheduling

#### Background

In global routing, nets are processed sequentially. The first net routed gets first pick of
routing resources. If a large, complex net is processed late, the grid is already partially
occupied and the net may be forced into a long detour — increasing congestion for everyone else.

#### What FastRoute Does

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

#### What FR_IBEX Does

FR_IBEX defines a sort function that ranks nets by a composite priority score, and calls it
before every major routing phase:

```cpp
// FR_IBEX — FastRoute.cpp
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
// FR_IBEX — FastRoute.cpp
gen_brk_RSMT(true, true, true, false, noADJ);
sort_wirelength_priority_nets();   // <-- added
newrouteLAll(false, true);

sort_wirelength_priority_nets();   // <-- added
spiralRouteAll();

sort_wirelength_priority_nets();   // <-- added
newrouteZAll(10);
```

#### Why This Produces Better Results

Routing the most complex, long-distance, and clock nets first ensures that the important nets
claim routing resources while the grid is still uncongested. Smaller, simpler nets are
routed into the remaining gaps. This reduces the chance of any net being forced into a
detour, lowering overall overflow and wirelength.

---

### Change 2: Always-On Maze Ordering

#### Background

Each maze iteration can optionally sort nets by their congestion load before routing them,
so the most congested nets are ripped up and rerouted first. This is controlled by an
`ordering` flag passed to `mazeRouteMSMD`.

#### What FastRoute Does

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

#### What FR_IBEX Does

FR_IBEX passes `true` unconditionally so that congestion-ordered routing is applied on
every iteration:

```cpp
// FR_IBEX — FastRoute.cpp
mazeRouteMSMD(i,
              enlarge_,
              ripup_threshold,
              mazeedge_threshold_,
              true,        // always sort by congestion
              VIA, L, cost_params, slack_th);
```

#### Why This Produces Better Results

On the two out of three iterations where `fastroute` skips the sort, a lightly congested
net may be rerouted before a heavily congested one, wasting maze search budget on easy
nets while hard ones wait. Sorting every iteration ensures the most overloaded edges are
always addressed first, making each iteration as effective as possible at reducing overflow.

---

### Change 3: Bounding Box Detour Penalty in Maze Routing

#### Background

When the maze router rips up and reroutes a tree edge, it searches within a rectangular
region expanded around the edge's two endpoints. Within this region, any path from source
to sink is considered valid. Without any guidance, the router may take a long detour around
congestion even when that detour adds unnecessary wirelength.

#### What FastRoute Does

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

#### What FR_IBEX Does

FR_IBEX makes two additions.

**First**, the search window is capped by the actual Manhattan length of the edge, so
short edges are not given an oversized search region:

```cpp
// FR_IBEX — maze.cpp
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
grid step during the maze search — FR_IBEX adds an explicit cost penalty for each tile the
route moves outside the edge's bounding box:

```cpp
// FR_IBEX — maze.cpp:  (inside relaxAdjacent lambda)
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
// FR_IBEX — maze.cpp:
const bool zero_overflow_mode    = total_overflow_ == 0;
const bool wirelength_focus_mode = zero_overflow_mode || iter > overflow_iterations_ / 2;

// Tiles outside the box that are still penalty-free
edge_bbox_margin = zero_overflow_mode ? 0 : (wirelength_focus_mode ? 1 : 2);
// Cost added per tile of detour beyond the margin
detour_unit_cost = zero_overflow_mode ? 1.55 : (wirelength_focus_mode ? 0.80 : 0.10);
```

#### Why This Produces Better Results

Without this penalty, the maze router takes detours freely whenever congestion makes the
direct path slightly more expensive, accumulating unnecessary wirelength across many nets.
The bounding box penalty makes such detours explicitly more expensive: the router only
takes them when the congestion saving is large enough to justify the wirelength cost. In
zero-overflow mode (the final cleanup phase), the margin shrinks to zero and the penalty
rises to 1.55 per tile, strongly pulling routes back toward their shortest path and
recovering wirelength accumulated during congestion resolution.

---

### Change 4: Adaptive Via Costs in Layer Assignment

#### Background

Layer assignment maps each 2D route segment onto a specific metal layer using dynamic
programming (DP). At every layer transition (via), the DP adds a via cost. The quality of
the assignment — how many vias are used and whether they land on congested layers —
depends entirely on how this cost is set.

#### What FastRoute Does

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

#### What FR_IBEX Does

FR_IBEX adds two new cost components before computing `total_via_cost`.

**Component 1 — Phase-dependent scaling**: via penalties grow as routing converges, so
the DP is flexible early but discourages unnecessary vias near the end:

```cpp
// FR_IBEX — utility.cpp:
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
// FR_IBEX — utility.cpp:
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
// FR_IBEX — utility.cpp:
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

// FR_IBEX:
int total_via_cost = adaptive_via_cost   // grows with routing progress
                   + via_resistance_cost  // unchanged
                   + congestion_penalty;  // penalises already-full layers
```

#### Why This Produces Better Results

Early in routing, the DP needs freedom to explore different layer combinations, so the via
cost stays low. As routing converges, the rising `iterationPenaltyScale` discourages
unnecessary layer switches that would add vias without improving routability. The
`congestionPenalty` steers vias away from layers already at capacity: the logistic
S-curve means the penalty is near-zero for lightly loaded layers but grows sharply once
`usage/capacity > 1`, so it only activates where it truly matters. Together, these two
terms produce layer assignments with fewer total vias and better load balance across layers.

## SPR_IBEX vs SPRoute: Key Algorithmic Changes


### Change 1: Increased Rerouting Budget 

#### Background

Global routing converges through an iterative rip-up and reroute loop. Each iteration
identifies overflowing edges, rips up the nets crossing them, and reroutes those nets through
less congested paths. The loop exits when either all overflow is resolved (`totalOverflow == 0`)
or a hard iteration ceiling is reached. On difficult, congested designs, overflow often
reduces slowly and a  handful of edges remain congested after many passes and would clear with
a few additional iterations, but the router stops early and leaves them unresolved.

#### What SPRoute Does

SPRoute sets the iteration ceiling at 500 when it calls the shared routing engine:

```cpp
// SPRoute — SprouteEngine.cpp:101
runFastRoute(generator,
             /*benchFile=*/"",
             /*OutFileName=*/"",
             congestion_map,
             timer,
             /*maxMazeRound=*/500,
             Algo::FineGrain);
```

The shared engine's loop uses this value as a hard stop:

```cpp
// vendor/mysproute/include/fastroute.h:1326
if (i >= mazeRound) {   // mazeRound == 500
    getOverflow2Dmaze(&maxOverflow, &tUsage);
    break;   // exits even if totalOverflow > 0
}
```

#### What SPR_IBEX Does

SPR_IBEX raises the ceiling by 30%, to 650 iterations:

```cpp
// SPR_IBEX — SPR_IBEXEngine.cpp:101
runFastRoute(generator,
             /*benchFile=*/"",
             /*OutFileName=*/"",
             congestion_map,
             timer,
             /*maxMazeRound=*/650,
             Algo::FineGrain);
```

The same loop termination check now permits 150 additional passes before giving up:

```cpp
// vendor/mysproute/include/fastroute.h:1326
if (i >= mazeRound) {   // mazeRound == 650 when called from SPR_IBEX
    getOverflow2Dmaze(&maxOverflow, &tUsage);
    break;
}
```

#### Why This Produces Better Results

On benchmarks that converge early, the change has no cost — the loop exits at
`totalOverflow == 0` regardless of the ceiling. On congested benchmarks where SPRoute
terminates just short of a zero-overflow solution, the extra 150 iterations give the router
the opportunity to resolve the remaining violations. The result is a lower final overflow
count and fewer routing guides that the detailed router must handle as DRC violations.

---

### Change 2: CUGR-Integrated Router Architecture

#### What SPRoute Does

The SPRoute adapter is a minimal pass-through wrapper. It holds a `SprouteEngine` and
exposes only initialize and run. It has no knowledge of other routers and performs no
post-processing itself — the caller (`GlobalRouter`) is responsible for all of that:

```cpp
// SPRoute — SprouteAdapter.cpp:22
NetRouteMap SprouteAdapter::run() {
    if (!initialized_) {
        return {};
    }
    return engine_->run();  // raw routes only; no post-processing
}
```

Post-processing is then performed by the caller, outside the adapter:

```cpp
// GlobalRouter.cpp:389
sproute_adapter_->initialize(sproute_grid_data_, sproute_nets_);
routes_ = sproute_adapter_->run();
sproute_total_overflow_ = sproute_adapter_->getTotalOverflow();
addRemainingGuides(routes_, nets, min_layer, max_layer);
connectPadPins(routes_);
for (auto& net_route : routes_) {
    mergeSegments(db_net_map_[net_route.first]->getPins(), net_route.second);
}
```

#### What SPR_IBEX Does

`NewGR` constructor
accepts a `CUGR*` pointer, giving SPR_IBEX a direct channel to CUGR's 3D pattern routing and
probabilistic cost model. SPR_IBEX also owns its full post-processing pipeline internally,
rather than relying on the caller:

```cpp
// NEWGR — NewGR.cpp:13
NewGR::NewGR(GlobalRouter* grouter, CUGR* cugr, utl::Logger* logger)
    : grouter_(grouter), cugr_(cugr), logger_(logger) {}

NetRouteMap NewGR::run(std::vector<Net*>& nets,
                       int min_routing_layer,
                       int max_routing_layer)
{
    engine_->init(grouter_->sproute_grid_data_, grouter_->sproute_nets_);
    NetRouteMap routes = engine_->run();

    // Post-processing is owned by NEWGR, not the caller.
    grouter_->addRemainingGuides(routes, nets, min_routing_layer, max_routing_layer);
    grouter_->connectPadPins(routes);
    for (auto& net_route : routes) {
        std::vector<Pin>& pins = grouter_->db_net_map_[net_route.first]->getPins();
        grouter_->mergeSegments(pins, net_route.second);
    }
    return routes;
}
```

#### Why This Produces Better Results

Holding a `CUGR*` inside SPR_IBEX enables future use of CUGR's 3D pattern routing as a
high-quality initial solution before the rip-up and reroute loop begins. CUGR's
probabilistic cost model produces initial routes with lower congestion than the
FLUTE-based L/Z pattern routing used by SPRoute's first pass. Replacing that initial
phase with CUGR output would reduce the number of overflowing nets that the iterative
loop must handle, improving both solution quality and convergence speed. The current
implementation provides the architectural plumbing for this integration. Internalizing
post-processing also makes SPR_IBEX self-contained, removing the caller's responsibility to
know the correct sequence of guide-repair steps — a source of subtle correctness bugs
when the router is composed with other tools.

