# Technical Analysis of Modern Global Routing Algorithms

## Introduction

Global routing remains a pivotal stage in VLSI physical design, tasked with allocating routing resources for millions of nets across a 3D grid graph. The primary objectives are minimizing a weighted sum of total wirelength and vias while resolving all routing congestion. Modern global routers are further differentiated by their consideration of detailed-routability, performance on multi-core systems, and determinism. This document provides a detailed technical analysis of three significant global routers—CUGR, FastRoute 4.1, and SPRoute 2.0—focusing on their core algorithms, mathematical formulations, and novel contributions for an expert audience.

---

## 1. CUGR: Detailed-Routability-Driven 3D Global Routing with Probabilistic Resource Model

CUGR distinguishes itself by routing directly on the 3D grid graph and integrating a sophisticated, probability-based resource model to proactively address detailed routing challenges.

### Core Contribution

CUGR's main novelty is its detailed-routability-driven approach, which directly models the probability of post-routing overflow. Unlike traditional routers that use simplified congestion metrics, CUGR employs a cost function sensitive to resource changes, intended to better predict the outcomes of a detailed router like Dr. CU.

### Detailed Algorithmic Breakdown

**1. Probabilistic Cost Scheme**

CUGR's cost model is foundational to its operation. The cost of a wire edge `e(u, v)` is not merely its wirelength but includes a congestion component derived from a probabilistic model.

*   **Demand and Resource:** Demand `d(u,v)` on an edge is the sum of wire demand (`wire(u,v)`) and an estimated via demand. The remaining resource `r(u,v)` is `c(u,v) - d(u,v)`, where `c(u,v)` is the edge capacity.

*   **Congestion Cost:** The congestion cost for a wire edge is `eo(u,v) * lg(u,v)`.
    *   `eo(u,v)` is the *expected overflow cost*, calculated as `wl(u,v) * (d(u,v) / c(u,v)) * uoc`, where `uoc` is a unit overflow cost constant. This term models the raw probability of overflow.
    *   `lg(u,v)` is a logistic function: `(1.0 + exp(slope * r(u,v)))^-1`. This function models the detailed router's ability to resolve congestion. When resources `r(u,v)` are abundant, `lg` is near zero, effectively nullifying the congestion cost. As resources deplete, `lg` rapidly approaches 1, making the expected overflow cost dominant. The `slope` parameter controls the sensitivity to resource reduction.

*   **Via Cost:** The cost for a via between G-cells `u` and `u'` is `uvc * (1 + lg(u) + lg(u'))`, where `uvc` is a unit via cost. This ties the via cost directly to the routability of the G-cells it connects.

**2. 3D Pattern Routing**

This technique optimally routes two-pin nets using L-shapes directly in 3D.
*   **Net Decomposition:** Multi-pin nets are first decomposed into a set of two-pin nets using FLUTE to generate an RSMT (Rectilinear Steiner Minimum Tree).
*   **Dynamic Programming:** The core of 3D pattern routing is a dynamic programming algorithm. It computes the minimum sub-tree cost `msc(Pi, l)` for routing the sub-tree `S(Pi)` rooted at pin `Pi` on layer `l`. The recurrence relation considers all possible layer assignments for the children of `Pi` and the via costs to connect them.
*   **3D L-Shape Exploration:** For a two-pin net `Pi -> Pj`, the algorithm considers all `2 * L^2` possible 3D L-shaped paths, where `L` is the number of layers. For each combination of start layer for `Pi` and end layer for `Pj`, it evaluates the two possible turning points for the L-shape, calculating the full path cost (wire segments + via stack) and updates the minimum sub-tree cost. This guarantees an optimal solution with respect to the cost model for L-shaped topologies.

**3. Multi-level 3D Maze Routing**

For nets requiring more flexibility, CUGR uses a hierarchical maze routing approach.
*   **Grid Coarsening:** The G-cell grid `G` is coarsened into a smaller grid `Gc` by compressing blocks of G-cells (e.g., 5x5) into a single coarsened cell. The resource of a coarsened cell is the average resource of its constituent G-cells.
*   **Coarse-grained Maze Routing:** A-star search is performed on `Gc`. The edge cost in `Gc` is inversely proportional to the resources of the adjacent coarsened cells (`1/R(A) + 1/R(B)`), guiding the search towards resource-rich regions. This quickly identifies a highly-routable coarse-grained corridor.
*   **Fine-grained Maze Routing:** The solution from the coarse-grained route defines a bounding box or corridor. A second, standard A-star maze routing is then performed on the original grid `G`, but confined to this much smaller search space. This search uses the detailed probabilistic cost function from Section 1 to find the minimum cost path.

**4. Post-processing (Patching)**
After routing, CUGR adds standalone rectangular guides to enhance detailed routability in three scenarios:
*   **Pin Region Patching:** If the G-cells on layers adjacent to a pin have resources below a threshold `T`, 3x3 guides are added on those layers to improve pin accessibility.
*   **Long Segment Patching:** For long wire segments, if a G-cell along the path has resources below `T`, a single G-cell guide is added on an adjacent layer (above or below) to provide a "detour" for track switching.
*   **Violation Patching:** For G-cells with unavoidable overflow, guides are added on both sides and on adjacent layers to give the detailed router maximum flexibility.

---

## 2. FastRoute 4.1: An Efficient and High-Quality Global Router

FastRoute is a highly influential router that exemplifies the 2D-projection approach. It projects the 3D problem to 2D, performs a series of sophisticated optimizations to achieve a high-quality 2D route, and then assigns layers.

### Core Contribution
FastRoute's key strengths are its speed and its portfolio of powerful routing techniques that work in concert. Its multi-stage approach, from topology generation to flexible rerouting and intelligent layer assignment, has proven extremely effective and has influenced many subsequent routers.

### Detailed Algorithmic Breakdown

**1. Topology Generation and Optimization**

FastRoute invests significant effort in creating a good initial tree topology before routing.
*   **Congestion-driven Via-aware RSMT:** It uses FLUTE to generate an initial RSMT. However, it first "warps" the Hanan grid (the grid formed by the horizontal and vertical lines passing through the net's pins). The distance between Hanan grid lines is scaled by the "average congestion" of that region, causing the grid to expand in congested areas. FLUTE then operates on this warped grid, naturally producing a topology that avoids hotspots. A via-cost-driven factor, based on the ratio of horizontal to vertical resource usage, is also incorporated to generate via-aware topologies from the start.
*   **Segment Shifting:** After the tree is generated, the algorithm iteratively shifts horizontal and vertical tree segments within their "safe range" (the range in which a segment can move without increasing total wirelength) to the position that minimizes local congestion.

**2. Routing Techniques**

FastRoute uses a multi-stage routing strategy, starting with fast, simple patterns and escalating to more powerful but expensive methods.
*   **L/Z-Pattern Routing:** Used for initial routing. Fast and generates few vias, but is inflexible for congestion.
*   **3-Bend Routing:** As a mid-tier strategy, it finds the optimal 3-bend path within an expanded bounding box. The cost of any path from the source `S` to a point `B` is pre-calculated using dynamic programming tables for horizontal and vertical paths. This allows the cost of any 3-bend path `S -> Breakpoint -> T` to be computed in O(1) time after an O(m*n) table-building phase, where m and n are the dimensions of the search box.
*   **Multi-Source, Multi-Sink Maze Routing:** This is FastRoute's most powerful technique, used for the most difficult nets. When a tree edge `(A,B)` is ripped up, it splits the net into two sub-trees, `T1` and `T2`. Instead of finding a path from `A` to `B`, the algorithm treats all nodes in `T1` as sources and all nodes in `T2` as sinks. It then runs a modified Dijkstra's/A* algorithm that finds the globally optimal path to reconnect *any* part of `T1` to *any* part of `T2`. This avoids unnecessary detours and redundant routing, and can even change the net's topology for a better result.

**3. Convergence Enhancement**

*   **Virtual Capacity Adjustment (VCA):** To guide the iterative rerouting process, FastRoute adjusts edge capacities. After an iteration, the overflow `oe = usage - capacity` is calculated for each edge. The virtual capacity for the next iteration is then set to `vce = vce - oe`. This is a monotonic decrease for congested edges, which systematically increases their cost and pushes routes away. The paper also notes that negative overflow (under-utilization) can increase the virtual capacity, helping to reclaim resources that were previously avoided.
*   **Adaptive Maze Cost Function:** The cost of an edge `e` is based on a logistic function: `cost(e) = 1 + H / (1 + exp(-k * (ue - vce)))` for `ue <= vce`. When usage `ue` exceeds virtual capacity `vce`, a linear penalty term is added: `1 + H + S * (ue - vce)`. The `H` and `k` parameters are adaptively adjusted across iterations. In early stages, `H` and `k` are small to prioritize wirelength. In later stages, they are increased to aggressively penalize congestion and force convergence.

**4. Spiral Layer Assignment**

After a 2D congestion-free solution is obtained, it is mapped to 3D layers.
*   **Net Ordering:** Nets are ordered by a `Total_WL / #Pins` metric, prioritizing short, high-pin-count nets for lower layers.
*   **Segment Ordering:** Segments within a net are ordered by their graph distance from the nearest pin, processing segments closer to pins first.
*   **Dynamic Programming:** A "via grid graph" is created for each segment, where horizontal edges represent wire segments and vertical edges represent vias. A dynamic programming approach finds the least-via path through this graph, assigning each portion of the 2D segment to a specific metal layer.

---

## 3. SPRoute 2.0: A Detailed-Routability-Driven Deterministic Parallel Global Router

SPRoute 2.0 addresses the critical need for both speed (via parallelization) and deterministic, routable results in a modern global router.

### Core Contribution
The two primary contributions are: 1) a **soft capacity** model that reserves resources for detailed routing, and 2) a **deterministic bulk synchronous parallel (BSP)** execution model for maze routing that guarantees identical results regardless of execution order and scales effectively on multi-core systems.

### Detailed Algorithmic Breakdown

**1. Soft Capacity Model**

To improve detailed routability, SPRoute 2.0 avoids using the full hardware capacity of an edge.
*   **Congestion Estimation:** It first calculates a congestion metric for each G-cell: `cong(x,y) = pin_density(x,y) + w * RUDY(x,y)`. RUDY (Rectangular Uniform wire Density) is a measure of wire density, and `w` is a weighting factor. This metric predicts how difficult a region will be to route.
*   **Ratio Function:** The `soft_cap` is determined by multiplying the `hard_cap` by a `ratio` from a logistic function: `ratio(cong) = min + (max - min) / (1 + exp((cong - cong_mid) * k))`.
    *   This function returns a ratio (e.g., between 0.5 and 0.9). In low-congestion regions, the ratio is high (e.g., 0.9), reserving 10% of capacity.
    *   As congestion `cong` increases, the ratio drops sharply, reserving more space. The parameters `min`, `max`, `k`, and `cong_mid` are set differently for different metal layers, as lower layers are more susceptible to pin access and DRC issues and thus require more reserved space.
*   **Overflow Calculation:** All subsequent overflow calculations during rip-up and reroute are based on this `soft_cap`, not the `hard_cap`.

**2. Deterministic Parallel Maze Routing**

This is the key to SPRoute 2.0's speed and determinism.
*   **Bulk Synchronous Parallel (BSP) Model:** The set of overflowing nets is partitioned into batches. All threads execute one batch at a time.
*   **Thread-Local Updates:** When a thread performs rip-up and reroute for a net, it reads from the shared global grid graph. However, the usage changes (decrementing for the ripped-up path, incrementing for the new path) are **not** written back to the global graph. Instead, they are accumulated in a private buffer.
*   **Synchronization Barrier:** After all nets in the batch have been processed by all threads, a synchronization barrier is reached. At this point, the usage changes from all thread-local buffers are atomically applied to the global grid graph.
*   **Guaranteed Determinism:** Because all threads in a batch operate on the identical, read-only state of the global graph as it existed at the start of the batch, the routing decisions are independent of the execution order. This provides determinism without the need for complex locking or requiring nets to be spatially disjoint. The implementation uses the Galois `do_all` parallel loop construct.

**3. Parallelization Scheduler**

A scheduler is used to partition nets into batches, with the dual goals of mitigating load imbalance and livelock.
*   **Load Imbalance (First Iteration):** The first routing iteration typically has the worst load imbalance, as many simple nets are resolved quickly, leaving a few threads with very complex nets. The scheduler addresses this by filtering based on bounding box size (`n.bbox > bbox_thold`). Only large nets are processed in the first parallel iteration, leading to a more uniform distribution of work.
*   **Livelock Mitigation (Later Iterations):** Livelock occurs when competing nets in the same batch repeatedly overwrite each other's paths. The scheduler reduces this by:
    1.  **Spatial Sorting:** It sorts overflowing nets based on the X or Y coordinate of a congested edge.
    2.  **Round-Robin Distribution:** It distributes these sorted nets into batches in a round-robin fashion (`B[n.sorted_rank % nbatch]`). This tends to place physically adjacent (and thus competing) nets into different batches.
    3.  **Batch Size Reduction:** The batch size `s` is halved in each iteration (`s = [s/2]`). Smaller batches reduce the number of nets competing at any one time, lowering the probability of livelock as the solution converges.
When the total overflow is low, it reverts to simple random partitioning.

### Overall Flow
1.  **Soft Capacity Calculation:** Compute `soft_cap` for all edges based on pin density and RUDY.
2.  **Initial Routing:** Generate an initial solution using FLUTE and pattern routing.
3.  **Iterative Parallel Rerouting:** While `total_overflow > 0`:
    a. Filter out nets that are already routed without overflow.
    b. Invoke the parallel scheduler to partition the remaining overflowing nets into batches.
    c. For each batch, execute rip-up and reroute using the BSP model.
4.  **Layer Assignment:** Generate final 3D routing guides.