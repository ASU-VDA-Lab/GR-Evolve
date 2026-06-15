# NEWGR vs CUGR: Key Algorithmic Changes


## Change 1: Hard-First Net Ordering

### Background

In global routing, nets are routed sequentially. The first net processed gets first pick of
routing resources on the grid. If a large, complex net is processed later after many simpler
nets have already claimed resources and may be forced into a congested detour, increasing
overflow for both itself and surrounding nets.

### What CUGR Does

CUGR sorts all nets by half-perimeter wirelength (HPWL) in ascending order before routing,
meaning small, short nets are always routed first:

```cpp
// CUGR — CUGR.cpp
// Nets sorted by ascending HPWL: shortest (easiest) nets go first.
return halfParameters[lhs] < halfParameters[rhs];
```

### What NEWGR Does

NEWGR reverses the sort order, routing the longest and highest pin-count nets first. Pin
count is used as a tiebreaker so that complex multi-pin nets take priority over simpler
nets of similar span:

```cpp
// NEWGR — CUGR.cpp
// Hard (long, high-pin) nets first.
if (halfParameters[lhs] != halfParameters[rhs]) {
    return halfParameters[lhs] > halfParameters[rhs];
}
return pinCounts[lhs] > pinCounts[rhs];
```

NEWGR also pre-computes pin counts explicitly to enable this secondary sort:

```cpp
// NEWGR — CUGR.cpp
std::vector<int> pinCounts(gr_nets_.size());
// ...
pinCounts[netIndex] = net->getNumPins();
```

### Why This Produces Better Results

Nets large bounding boxes and many pins are the primary source of
routing overflow. Routing them first ensures they claim tracks while the grid is still
uncongested. Simpler nets are then routed into whatever space remains, which is generally
sufficient for them. Routing easy nets first has the opposite effect: it consumes resources
in regions that hard nets urgently need, forcing detours and creating overflow hotspots.

---

## Change 2: Long-Segment Layer Promotion

### Background

Long wire segments routed on lower layers are a major source of congestion.
Ideally, long wires should be pushed to higher metal layers, which have more tracks and
lower per-unit congestion.

### What CUGR Does

During 3D pattern routing, CUGR evaluates wire cost uniformly across all candidate layers.
The DP simply picks whichever layer has the lowest base wire cost, with no preference for
assigning long segments to higher layers:

```cpp
// CUGR — PatternRoute.cpp
// Wire cost is evaluated identically on every layer; no layer preference for long wires.
CostT cost = path->getCosts()[layerIndex]
             + grid_graph_->getWireCost(layerIndex, *node, *path);
```

### What NEWGR Does

NEWGR first identifies whether a segment is "long" by comparing its length to a tunable
threshold. For long segments, it multiplies the wire cost on lower layers by a bias factor
that grows with distance from the top preferred layer for that routing direction. This makes
lower layers artificially more expensive for long wires, steering the 3D DP toward higher layers:

```cpp
// NEWGR — PatternRoute.cpp
// Flag long segments based on a tunable threshold.
const int segment_len = std::abs((*node)[direction] - (*path)[direction]);
const bool promote_long = segment_len >= constants_.long_segment_threshold;
```

```cpp
// NEWGR — PatternRoute.cpp
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

### Why This Produces Better Results

Long horizontal and vertical segments are the dominant cause of lower-layer congestion.
By making lower layers artificially more expensive for long wires, the 3D DP naturally
assigns them to higher metal layers, freeing the lower layers for the short pin-access
segments that genuinely need to reside there. This reduces peak congestion on the layers
closest to the pin layer and lowers overall overflow without increasing total wirelength.

---

## Change 3: Removal of Unconditional Pin Layer Extension

### Background

During access-point selection, the router records which metal layers each pin can be
accessed on. This interval informs the 3D pattern routing,
which must plan via stacks to connect to the pin on those layers. Overstating the interval
forces the router to model more layers as occupied than the pin actually requires, consuming
routing resources unnecessarily near pin regions.

### What CUGR Does

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

### What NEWGR Does

NEWGR removes the blanket extension entirely. The fixed layer interval is set only from
the layer of the actually selected access point, reflecting true pin connectivity:

```cpp
// NEWGR — GridGraph.cpp
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

### Why This Produces Better Results

The +2 layer extension forces via stacks around every pin to span more layers than the
pin physically requires. This inflates via demand and overstates resource consumption
in pin regions, causing the congestion model to see those regions as more crowded than
they are. Removing the extension gives the router an accurate picture of which layers
are truly pinned, resulting in shorter via stacks, more accurate congestion estimates
near pins, and better use of available routing resources.

---

## Change 4: Adaptive Maze Search Grid Density

### Background

CUGR's multi-level maze routing first coarsens the G-cell grid into a sparser grid, runs
A* on the coarser graph to identify a good routing corridor, then performs fine-grained
maze routing within that corridor. The coarsening step size controls the size of the
reduced graph: a large step produces a coarser, faster search, but may miss better
routing paths. A smaller step explores more of the grid but takes longer.

### What CUGR Does

CUGR uses a single fixed step size of 10×10 for all nets regardless of their size or
complexity:

```cpp
// CUGR — CUGR.cpp
// One fixed coarse grid for every net, regardless of size.
SparseGrid grid(10, 10, 0, 0);
```

### What NEWGR Does

NEWGR uses a finer baseline step of 8×8 and further scales the step size down based on
the net's bounding-box half-perimeter (HPWL). Larger nets — which span more G-cells and
have more potential routing corridors — receive a denser search grid:

```cpp
// NEWGR — CUGR.cpp
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

### Why This Produces Better Results

Large nets traverse more G-cells and have more potential detour paths through the grid.
A coarse fixed step size causes the maze router to collapse too many G-cells into a
single coarsened node, averaging out local congestion differences and missing
less-congested corridors. By scaling the grid density to net size, NEWGR gives larger
and harder to route nets a more thorough search, improving the quality
of the maze solution, while keeping the search fast for small nets
that do not need the extra resolution.

