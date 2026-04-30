You must follow the flow given below:
1. Read the `Branch Scope Declaration` and only use the allowed branches listed there as evidence.
2. Read `/root/GR_SUMMARY.md` and extract SPRoute-relevant principles (plus transferable ideas from FastRoute/CUGR) before choosing hypotheses.
3. Make hypothesis-driven code changes inside `src/grt/src/NEWGR` only. There is no hard cap on hypotheses per iteration or total iterations; optimize for fewer expensive runs.
4. Build OpenROAD with `/root/SHELL_SCRIPTS/__buildOR.sh`.
5. Copy and run binaries with:
   - `/root/SHELL_SCRIPTS/__copyORbinary.sh`
   - `/root/SHELL_SCRIPTS/__runEOR.sh <iteration_number>`
6. Extract metrics with `/root/SHELL_SCRIPTS/_find_metrics.sh <iteration_number>`, report them in the run summary, and write the same values to `/root/TESTS/METRICS_TABLE.md`.
7. If build/run/metrics are valid, commit iteration state (`git add . && git commit -m "Iteration <n>"`).

> IMPORTANT NOTE : Since this evolution design is large, it will take a lot of time to run. You cannot complete partial runs. If there are any untracked files, add them to the current git commit.  You will not be able to ask me for any permission as this is an autonomous loop, so you have permission to make any and all decisions you need to proceed. You are in a sandbox, so you can perform all actions safely.

## Baseline Metrics
| Metric                   | Wirelength(um) | Via Count | Runtime (milliseconds) |
| ------------------------ | -------------- | --------- | ---------------------- |
| FastRoute 4.1 (Baseline) | 6977651        | 1480747   | 137322                 |
| CUGR (Baseline)          | 8070097        | 1720988   | 48093                  |
| SPRoute2 (Baseline)      | 7106441        | 1638777   | 15057                  |

## Build OpenROAD
Use `/root/SHELL_SCRIPTS/__buildOR.sh`. If compile errors appear, fix code/CMake and rebuild.

## Run Scripts
After successful build, run `/root/SHELL_SCRIPTS/__runEOR.sh <iteration_number>`.

## Log Files
- GR log: `/root/TESTS/newgr_autoevolve/GR_newgr_e.<n>_sky130hd.log`
- DR log: `/root/TESTS/newgr_autoevolve/DR_newgr_e.<n>_sky130hd.log`
- Metrics helper: `/root/SHELL_SCRIPTS/_find_metrics.sh <n>`

## Git Tracking
Commit all files changed in the iteration with message `Iteration <n>`.

## Branch Scope Declaration
This playbook is constrained to cumulative learnings from exactly these branches:
1. `NEWGR-CodexEvolve-SPRoute-AES-Iter13`
2. `NEWGR-CodexEvolve-SPRoute-IBEX-Iter10`
3. `NEWGR-CodexEvolve-SPRoute-JPEG-Iter31`

No other branches, commits, or local edits are valid evidence for the learning claims below.

## Required Theory Reference (GR_SUMMARY)
1. You must read `/root/GR_SUMMARY.md` before choosing iteration hypotheses.
2. Each proposed hypothesis must cite:
- one branch-backed learning from this document, and
- one supporting algorithmic principle from `GR_SUMMARY.md`.
3. If branch evidence and GR_SUMMARY guidance conflict, prioritize branch evidence and explicitly document the tradeoff.
4. Use GR_SUMMARY to improve mechanism design quality (cost functions, stage flow, search policy), not as a replacement for branch evidence.

## Read-Only Reference Source Paths (for inspiration)
Use these paths as read-only references when designing hypotheses:
1. NEWGR (editable code): `/root/OpenROAD_New_GRT/src/grt/src/NEWGR`
2. FastRoute source: `/root/OpenROAD_New_GRT/src/grt/src/fastroute`
3. CUGR source: `/root/OpenROAD_New_GRT/src/grt/src/cugr`
4. SPRoute2 source: `/root/OpenROAD_New_GRT/src/sproute_tool`
5. Shared GRT source: `/root/OpenROAD_New_GRT/src/grt/src`
6. FLUTE source: `/root/.flute-3.1`

## Edit Scope Policy
1. Code edits are allowed only inside `/root/OpenROAD_New_GRT/src/grt/src/NEWGR` (project shorthand: `src/grt/NEWGR`).
2. Treat all paths outside NEWGR as read-only.
3. Do not modify scripts, logs, build glue, or any source outside NEWGR.
4. Single exception: you may update `/root/TESTS/METRICS_TABLE.md` with metrics extracted from `/root/SHELL_SCRIPTS/_find_metrics.sh`.
5. If a task appears to require edits outside NEWGR (other than `METRICS_TABLE.md`), stop and report the limitation instead of editing those files.

## Deep Cumulative Learnings
### Learning SP-L01: Engine-mode choice (`Algo`) and maze-round budget are first-order quality controls
1. Learning ID
- `SP-L01`
2. Source branch(es)
- `NEWGR-CodexEvolve-SPRoute-AES-Iter13`, `NEWGR-CodexEvolve-SPRoute-IBEX-Iter10`, `NEWGR-CodexEvolve-SPRoute-JPEG-Iter31`
3. Code anchors
- `src/grt/src/NEWGR/src/NewgrEngine.cpp`
- Function: `NewgrEngine::run`
- Knobs: `runFastRoute(..., maxMazeRound, Algo::...)`
4. What changed
- AES used `Algo::DetPart_Astar_Local` with `maxMazeRound=500`; IBEX switched to `Algo::FineGrain` and `650`; JPEG kept `FineGrain` but restored `500`.
5. How it works (mechanism)
- `Algo` controls maze policy and partitioning style in vendor SPRoute core.
- `maxMazeRound` caps iterative reroute effort.
- Increasing round cap broadens convergence chance but also runtime exposure.
6. Why it helps
- WL/via: extra rounds can reduce residual overflow detours.
- Runtime: higher round cap can regress sharply when gains saturate.
7. When it fails
- High round cap with weak acceptance control wastes runtime on low-value refinements.
- Failure signature: long tail iterations with minimal overflow/WL improvement.
8. Tuning knobs and guardrails
- Keep one variable fixed while tuning the other (`Algo` or round cap).
- Treat `500` as runtime-safe default; expand only with measurable WL gain.
9. Evidence quality
- High confidence: explicit configuration changes across all 3 branch tips.
10. Reproduction and validation
- One iteration: hold `Algo::FineGrain`, sweep only `maxMazeRound`.
- Accept only if WL gain per runtime cost is favorable.

### Learning SP-L02: Thread-count capping improves quality stability in parallel reroute
1. Learning ID
- `SP-L02`
2. Source branch(es)
- `NEWGR-CodexEvolve-SPRoute-JPEG-Iter31` (added), contrasted with AES/IBEX behavior
3. Code anchors
- `src/grt/src/NEWGR/src/NewgrEngine.cpp`
- Variables: `numThreads`, `kMaxRoutingThreads = 8`, `galois::setActiveThreads`
4. What changed
- JPEG caps active routing threads to 8 before invoking SPRoute run.
5. How it works (mechanism)
- SPRoute’s parallel rip-up/reroute can vary behavior with thread scheduling.
- Thread cap reduces interleaving diversity and improves run-to-run consistency.
6. Why it helps
- WL/via stability: lower metric variance improves tuning signal quality.
- Runtime: can improve or worsen depending on machine; usually reduces extreme tail behavior.
7. When it fails
- On large machines with low contention, cap may leave performance on the table.
- Failure signature: runtime slower with no stability benefit on repeated runs.
8. Tuning knobs and guardrails
- Test caps in small set `{8, 12, 16}`; do not tune cap and algorithm mode simultaneously.
- Require repeated-run variance measurement before finalizing.
9. Evidence quality
- Medium-high: explicit JPEG addition aligned with documented concern about ordering differences.
10. Reproduction and validation
- Run same branch multiple times with and without cap; compare WL/via variance and runtime median.

### Learning SP-L03: Soft-cap model coefficients are highly sensitive and can over-constrain resources
1. Learning ID
- `SP-L03`
2. Source branch(es)
- `NEWGR-CodexEvolve-SPRoute-AES-Iter13`, `NEWGR-CodexEvolve-SPRoute-IBEX-Iter10`, `NEWGR-CodexEvolve-SPRoute-JPEG-Iter31`
3. Code anchors
- `src/grt/src/NEWGR/vendor/mysproute/include/global.h`
- Macros: `M2_ADJ_*`, `M3_ADJ_*`, `MID_ADJ_*`, `HIGH_ADJ`, `DEFAULT_RUDY_WEIGHT`
- Function: `GLOBAL_CAP_ADJ`
4. What changed
- IBEX reduced many adjust factors (aggressive capacity shrink). JPEG raised factors close to 1.0 and added safer rounding logic (`adjusted_cap`).
5. How it works (mechanism)
- Logistic adjustment maps local congestion metric to effective capacity.
- Lower multipliers reserve more capacity for detailed routing but increase global overflow pressure.
- JPEG’s rounding avoids harsh truncation of low-cap edges.
6. Why it helps
- Moderate soft-cap can improve DR friendliness.
- Over-aggressive soft-cap inflates global detours, hurting WL and potentially vias.
7. When it fails
- Low-capacity edges become bottlenecks due to excessive capacity discount.
- Failure signature: overflow concentration on lower layers despite available routes nearby.
8. Tuning knobs and guardrails
- Move coefficients incrementally; keep `HIGH_ADJ` near conservative range.
- Keep minimum adjusted capacity floor to avoid zero-like behavior.
9. Evidence quality
- High confidence: clear macro trajectory across all three branches.
10. Reproduction and validation
- One iteration adjusts only one macro family (for example M2/M3 pair).
- Validate overflow map shape, WL, via, runtime.

### Learning SP-L04: Via-pressure schedule inside vendor FastRoute layer assignment is more effective than static via cost
1. Learning ID
- `SP-L04`
2. Source branch(es)
- `NEWGR-CodexEvolve-SPRoute-IBEX-Iter10`, `NEWGR-CodexEvolve-SPRoute-JPEG-Iter31`
3. Code anchors
- `src/grt/src/NEWGR/vendor/mysproute/include/fastroute.h`
- Variables: `VIA`, `viacost`, `past_cong`
- Added JPEG logic: via pressure escalation when `past_cong < 6000` and `< 1200`, and floor during final layer assignment
4. What changed
- IBEX kept via pressure lower (`viacost=0` path); JPEG added congestion-dependent via pressure restoration.
5. How it works (mechanism)
- Early/mid congestion keeps flexibility.
- As congestion decreases, via penalty increases to prevent unnecessary layer hopping.
- Final LA enforces nonzero via pressure when congestion is clean.
6. Why it helps
- Via: explicit anti-via bias late in convergence.
- WL: moderate (not extreme) via pressure avoids overlong same-layer detours.
7. When it fails
- If via pressure ramps too early, routes detour horizontally and WL rises.
- Failure signature: WL up with only small via improvement.
8. Tuning knobs and guardrails
- Keep 2-stage ramp; avoid adding more breakpoints in one iteration.
- Couple ramp thresholds to observed `past_cong` distribution.
9. Evidence quality
- Medium-high: direct IBEX-to-JPEG change with clear intended mechanism.
10. Reproduction and validation
- One iteration: adjust only first congestion breakpoint.
- Accept if via improves and WL non-regresses.

### Learning SP-L05: IBEX route-topology cleanup was powerful but too heavy for stable iteration loops
1. Learning ID
- `SP-L05`
2. Source branch(es)
- `NEWGR-CodexEvolve-SPRoute-IBEX-Iter10` (added), `NEWGR-CodexEvolve-SPRoute-JPEG-Iter31` (removed)
3. Code anchors
- `src/grt/src/NEWGR/NewGR.cpp` (IBEX only)
- Functions: `dedupeAndDropStubs`, `optimizeRouteTopology`, `cleanupRouteSegments`
- Data structures: graph build, disjoint set, edge dedupe, acceptance by WL/via stats
4. What changed
- IBEX added a large post-route topology optimizer and FastRoute-first fallback path; JPEG reverted to simple engine flow.
5. How it works (mechanism)
- IBEX rebuilds route graph, prunes/rewires edges, and accepts only if WL improves or via is non-worse.
- Also applies cleanup after both FastRoute fallback and SPRoute engine outputs.
6. Why it helps
- Potentially reduces fragmented segments and redundant vias.
- But complexity and cost are high, and maintenance burden is large.
7. When it fails
- Large code path can hide regressions, inflate runtime, and reduce determinism of iteration outcomes.
- Failure signature: difficult-to-attribute metric shifts and unstable runtime.
8. Tuning knobs and guardrails
- Prefer smaller, local cleanup passes rather than full graph-rebuild optimizer.
- Keep wrapper thin while algorithmic core is still being tuned.
9. Evidence quality
- High confidence: explicit large add in IBEX and near-complete removal in JPEG.
10. Reproduction and validation
- If reintroduced, do it as isolated optional pass with counters and strict abort budget.

### Learning SP-L06: Pin lift and per-route via penalties in vendor utility are meaningful late-stage via controls
1. Learning ID
- `SP-L06`
2. Source branch(es)
- `NEWGR-CodexEvolve-SPRoute-JPEG-Iter31` (enhanced from IBEX baseline)
3. Code anchors
- `src/grt/src/NEWGR/vendor/mysproute/include/utility.h`
- Functions: `assignEdge`, `selectPinLiftLimit`, `newLA`
- Knobs: `la_via_start`, `la_via_mid`, `la_via_end`, dynamic pin lift limit
4. What changed
- JPEG introduced route-length-dependent via penalties and congestion-aware pin lift limit selection.
5. How it works (mechanism)
- Short/medium routes get stronger via penalties to suppress gratuitous switches.
- Long routes keep lower penalties to avoid severe horizontal detours.
- Pin lift limit inspects adjacent edge saturation before allowing extra layer lift.
6. Why it helps
- Via: targeted suppression where extra vias are usually low-value.
- WL: preserves flexibility for long routes that need layer escapes.
7. When it fails
- If penalties are too high on medium routes, WL increases from forced planar detours.
- Failure signature: WL up on medium-span nets with minimal via savings.
8. Tuning knobs and guardrails
- Tune one of `la_via_start/mid/end` per iteration.
- Keep long-route branch less aggressive than short-route branch.
9. Evidence quality
- Medium-high: explicit new logic in JPEG vendor utility.
10. Reproduction and validation
- One iteration: adjust only `la_via_mid`.
- Validate medium-net WL and global via direction.

## Repeated Wins
1. Moderate, congestion-aware via pressure in late stages repeatedly gives better via/WL balance than static zero-via pressure.
2. Soft-cap calibration near realistic capacities (not overly reduced) repeatedly avoids overflow blowups.
3. Simpler wrapper flow (thin `NewGR.cpp`) repeatedly improves iteration clarity and reduces hidden runtime regressions.

## Repeated Failures and Regressions
1. Over-aggressive soft-cap reduction (IBEX-style macro values) can over-constrain routing and increase detours.
2. Large post-route graph optimizers in wrapper code create high complexity and unstable tuning feedback loops.
3. Unbounded thread scaling risks quality jitter due to parallel ordering effects.

## Transferable Ideas From Other Router Families
1. From FastRoute (`NEWGR-CodexEvolve-FastRoute-JPEG-Iter137`): keep post-processing bounded and acceptance-driven.
2. From FastRoute (`NEWGR-CodexEvolve-FastRoute-AES-Iter147`): avoid enabling heavy parallel alternatives while objective tuning is still unstable.
3. From CUGR (`NEWGR-CodexEvolve-CUGR-IBEX-Iter52`): apply overflow-threshold gating to heavy stages instead of global always-on behavior.

## Iteration Budget Strategy
1. There is no hard cap on hypotheses per iteration or total iterations.
2. Primary objective is to reduce expensive iteration count by prioritizing high-impact, high-confidence hypotheses first.
3. Require predicted direction for WL/via/runtime before editing.
4. Prefer isolated changes for causal attribution; batch multiple changes only when they are tightly coupled.
5. If progress stalls, re-rank hypotheses using latest metrics and continue with a new strategy.

## Next Best Moves (Exactly 5)
1. Tune only `maxMazeRound` while keeping `Algo::FineGrain` fixed.
- Edit target: `src/grt/src/NEWGR/src/NewgrEngine.cpp`.
- Acceptance checks: runtime non-regression with WL/via non-worse.
2. Refine thread cap from fixed 8 to small adaptive rule.
- Edit target: `src/grt/src/NEWGR/src/NewgrEngine.cpp`.
- Acceptance checks: lower run-to-run variance without median runtime regression.
3. Soften soft-cap only on M2/M3 low-congestion regime.
- Edit target: `src/grt/src/NEWGR/vendor/mysproute/include/global.h`.
- Acceptance checks: reduced overflow hotspots and non-worse WL.
4. Calibrate late-stage via pressure breakpoints.
- Edit target: `src/grt/src/NEWGR/vendor/mysproute/include/fastroute.h` (`past_cong` breakpoint logic).
- Acceptance checks: via reduction with WL stable.
5. Narrow `assignEdge` via penalties for medium routes.
- Edit target: `src/grt/src/NEWGR/vendor/mysproute/include/utility.h`.
- Acceptance checks: medium-net WL non-regression and global via improvement.

## First Iteration Plan For Next LLM Run
### Exact 1-iteration objective
Reduce via count with no WL regression by tuning only late-stage via pressure thresholds in vendor SPRoute FastRoute path.

### Initial focus files/functions (non-binding; any NEWGR file may be edited)
You may edit any file under `/root/OpenROAD_New_GRT/src/grt/src/NEWGR` if required by the active hypothesis.

### Hypothesis table (recommended 1 to 3 to start; no hard cap)
| Hypothesis | Edit                                                | Predicted metric change                    |
| ---------- | --------------------------------------------------- | ------------------------------------------ |
| H1         | Shift first via-ramp threshold slightly lower       | WL stable, via down                        |
| H2         | Keep final LA via floor but reduce aggressiveness   | WL stable/slightly better, via mildly down |
| H3         | Prevent early via ramp under residual high overflow | WL better, via neutral to down             |
