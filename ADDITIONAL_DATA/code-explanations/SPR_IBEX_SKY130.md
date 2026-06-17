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

