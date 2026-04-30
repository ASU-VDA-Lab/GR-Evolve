You must follow the flow given below:
1. Read the `Branch Scope Declaration` and only use the allowed branches listed there as evidence.
2. Read `/root/GR_SUMMARY.md` and extract CUGR-relevant principles (plus transferable ideas from FastRoute/SPRoute) before choosing hypotheses.
3. Make hypothesis-driven code changes inside `src/grt/src/NEWGR` only. There is no hard cap on hypotheses per iteration or total iterations; optimize for fewer expensive runs.
4. Build OpenROAD with `/root/SHELL_SCRIPTS/__buildOR.sh`.
5. Copy and run binaries with:
   - `/root/SHELL_SCRIPTS/__copyORbinary.sh`
   - `/root/SHELL_SCRIPTS/__runEOR.sh <iteration_number>`
6. Extract metrics with `/root/SHELL_SCRIPTS/_find_metrics.sh <iteration_number>`, report them in the run summary, and write the same values to `/root/TESTS/METRICS_TABLE.md`.
7. If build/run/metrics are valid, commit iteration state (`git add . && git commit -m "Iteration <n>"`).

## Baseline Metrics
| Metric                   | Wirelength(um) | Via Count | Runtime (milliseconds) |
| ------------------------ | -------------- | --------- | ---------------------- |
| FastRoute 4.1 (Baseline) | 6325872        | 1579651   | 116398                 |
| CUGR (Baseline)          | 6855417        | 1786335   | 32105                  |
| SPRoute2 (Baseline)      | 6385769        | 1682982   | 16804                  |

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
1. `NEWGR-CodexEvolve-CUGR-AES-Iter14`
2. `NEWGR-CodexEvolve-CUGR-IBEX-Iter52`
3. `NEWGR-CodexEvolve-CUGR-JPEG-Iter32`

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
### Learning CU-L01: Stage-specific net ordering consistently controls overflow repair efficiency
1. Learning ID
- `CU-L01`
2. Source branch(es)
- `NEWGR-CodexEvolve-CUGR-AES-Iter14`, `NEWGR-CodexEvolve-CUGR-IBEX-Iter52`, `NEWGR-CodexEvolve-CUGR-JPEG-Iter32`
3. Code anchors
- `src/grt/src/NEWGR/src/CUGR.cpp`
- Function: `sortNetIndices(...)`
- Related fields: `halfParameters` (HPWL proxy), `pinCounts`, `overflowCounts`, stage enum (`NetSortStage` in JPEG)
4. What changed
- Sorting moved from single HP-based order to stage-aware order, especially overflow-first order in repair stages.
5. How it works (mechanism)
- Initial pattern route can prioritize compact nets to establish short trees.
- Overflow-repair stages reorder by actual overflow counts first.
- Pin count and deterministic tie-breakers stabilize routing order.
6. Why it helps
- WL: compact nets can settle with fewer detours early.
- Via: overflow-first repair reduces repeated topology/layer perturbations on severe nets.
- Runtime: concentrates expensive stages on nets with highest impact.
7. When it fails
- If compact-first is overused in congested designs, large trunk nets get deferred and cause cascading rip-ups.
- Failure signature: late iterations dominated by a small set of high-overflow macro nets.
8. Tuning knobs and guardrails
- Keep stage split explicit: one policy for initial route, another for repair.
- Avoid changing both primary key and tie-break key in the same iteration.
9. Evidence quality
- High confidence: all 3 branches changed ordering behavior; IBEX/JPEG formalized stage split.
10. Reproduction and validation
- Compare two runs: stage-aware sort versus single sort.
- Validate with overflow-net count after stage 2 and final WL/via.

### Learning CU-L02: Overflow-threshold gating for detour/maze stages is high leverage but sensitive
1. Learning ID
- `CU-L02`
2. Source branch(es)
- `NEWGR-CodexEvolve-CUGR-IBEX-Iter52` (introduced), `NEWGR-CodexEvolve-CUGR-JPEG-Iter32` (partially rolled back)
3. Code anchors
- `src/grt/src/NEWGR/include/CUGR.h`
- Constants: `detour_overflow_threshold`, `maze_overflow_threshold`
- `src/grt/src/NEWGR/src/CUGR.cpp` in `patternRouteWithDetours` and `mazeRoute`
4. What changed
- IBEX routes only nets exceeding overflow thresholds in heavy stages; JPEG re-expanded processing scope.
5. How it works (mechanism)
- Detour and maze route are skipped for low-overflow nets.
- Severe nets are extracted into dedicated vectors and processed with denser sparse-grid settings.
- This creates a compute budget filter for expensive stages.
6. Why it helps
- Runtime: avoids paying maze cost on nets unlikely to improve.
- WL/via: can improve if thresholds isolate true detour-heavy nets.
7. When it fails
- Thresholds too strict skip nets that still need subtle detour cleanup.
- Failure signature: low-overflow nets remain with avoidable detours and via-heavy layer switches.
8. Tuning knobs and guardrails
- Start with mild thresholds; do not gate both detour and maze aggressively at once.
- Track skipped-net volume and post-stage residual overflow distribution.
9. Evidence quality
- Medium-high: explicit add in IBEX and rollback pressure visible in JPEG.
10. Reproduction and validation
- One iteration: adjust only `maze_overflow_threshold`.
- Accept if runtime drops and WL/via are non-worse.

### Learning CU-L03: Access-point and fixed-layer interval policy is the dominant via/WL control surface
1. Learning ID
- `CU-L03`
2. Source branch(es)
- `NEWGR-CodexEvolve-CUGR-AES-Iter14`, `NEWGR-CodexEvolve-CUGR-IBEX-Iter52`, `NEWGR-CodexEvolve-CUGR-JPEG-Iter32`
3. Code anchors
- `src/grt/src/NEWGR/src/GridGraph.cpp`
- Function: `GridGraph::selectAccessPoints`
- Knobs: layer biasing (`layerDistanceBias` in IBEX, `layer_bias`/resource score in JPEG), fixed-layer extension logic
4. What changed
- Branches progressively replaced simple accessibility+distance tie-break with richer resource/layer/interval criteria.
5. How it works (mechanism)
- Candidate APs are scored by accessibility and local resource, then penalized by layer distance.
- Fixed-layer intervals are tightened for compact nets and widened only when edge accessibility is poor.
- JPEG reintroduced adaptive extension with compact-net handling and resource-aware tie-break.
6. Why it helps
- Via: tight fixed-layer intervals on compact/low-degree nets directly reduce vertical transitions.
- WL: larger nets retain enough layer freedom to avoid long horizontal detours.
- Runtime: fewer pathological AP choices reduce downstream reroute churn.
7. When it fails
- Too much low-layer bias can force long detours in globally congested regions.
- Failure signature: WL increases while via count decreases only marginally.
8. Tuning knobs and guardrails
- Keep layer penalties and resource weight modest; avoid hard forcing lower layers.
- Adjust compact-net threshold (`hp`, pin count) in small increments.
9. Evidence quality
- High confidence: all branches modify this function; branch-to-branch behavior explains major strategy shifts.
10. Reproduction and validation
- One iteration: tune only compact-net extension rule.
- Check via and WL jointly; reject if WL worsens >0.3%.

### Learning CU-L04: PatternRoute via-pressure escalation can over-constrain and was partially rolled back
1. Learning ID
- `CU-L04`
2. Source branch(es)
- `NEWGR-CodexEvolve-CUGR-IBEX-Iter52` (strong via bias), `NEWGR-CodexEvolve-CUGR-JPEG-Iter32` (rollback)
3. Code anchors
- `src/grt/src/NEWGR/include/CUGR.h`
- Constants: `weight_via_number`, `via_multiplier`, `layer_assignment_hysteresis_ratio`, `layer_usage_penalty_ratio`
- `src/grt/src/NEWGR/src/PatternRoute.cpp` in `calculateRoutingCosts`
4. What changed
- IBEX added dynamic via scaling, branching hysteresis, and layer usage penalties; JPEG removed most dynamic terms and restored simpler via costs.
5. How it works (mechanism)
- IBEX increased switching cost at branching points and for compact nets.
- Additional hysteresis prevented frequent layer changes unless benefit exceeded threshold.
- JPEG removed these extra barriers after over-constraint risk.
6. Why it helps
- Via: aggressive bias reduces layer churn.
- Potential WL risk: if bias is too high, router takes long same-layer detours.
7. When it fails
- Large/high-fanout nets need layer flexibility; hard via penalties can inflate WL and overflow.
- Failure signature: via count improves but WL and/or overflow worsen.
8. Tuning knobs and guardrails
- Use one via-bias term at a time (either multiplier or hysteresis), not all simultaneously.
- Keep large-net relaxation branch explicit.
9. Evidence quality
- High confidence: clear introduce-then-rollback sequence between IBEX and JPEG.
10. Reproduction and validation
- Run with only one restored dynamic term.
- Accept only if via improves without WL/overflow regression.

### Learning CU-L05: FLUTE accuracy scaling is useful, but broad high-accuracy windows are costly
1. Learning ID
- `CU-L05`
2. Source branch(es)
- `NEWGR-CodexEvolve-CUGR-IBEX-Iter52`, `NEWGR-CodexEvolve-CUGR-JPEG-Iter32`
3. Code anchors
- `src/grt/src/NEWGR/src/PatternRoute.cpp`
- Function: `constructSteinerTree`
- Parameters: `fluteAccuracy` dynamic schedule by `degree` and `hp`
4. What changed
- IBEX introduced multi-band FLUTE accuracy tuning; JPEG rolled back to base `flute_accuracy_`.
5. How it works (mechanism)
- Higher accuracy for small/medium nets improves Steiner quality.
- Lower accuracy for very large nets protects runtime.
- Implicit tradeoff is front-loaded topology quality versus compute cost.
6. Why it helps
- WL: better RSMTs can reduce downstream detours and bends.
- Via: cleaner trees reduce unnecessary vertical transitions.
- Runtime: only if high-accuracy window is narrow.
7. When it fails
- Overly wide high-accuracy bands increase runtime with diminishing WL returns.
- Failure signature: runtime rise without meaningful WL gain.
8. Tuning knobs and guardrails
- Keep high-accuracy window narrow (`low degree` and `low hp`).
- Expand one boundary at a time.
9. Evidence quality
- Medium-high: explicit dynamic schedule in IBEX and rollback in JPEG.
10. Reproduction and validation
- One iteration sweep of only one degree/hp boundary.
- Accept if WL gain per runtime cost is positive.

### Learning CU-L06: Guide patch policy must be conditional, not globally aggressive or globally disabled
1. Learning ID
- `CU-L06`
2. Source branch(es)
- `NEWGR-CodexEvolve-CUGR-AES-Iter14`, `NEWGR-CodexEvolve-CUGR-IBEX-Iter52`, `NEWGR-CodexEvolve-CUGR-JPEG-Iter32`
3. Code anchors
- `src/grt/src/NEWGR/src/CUGR.cpp`, function `getGuides`
- Constants: `pin_patch_threshold`, `wire_patch_threshold`, `wire_patch_inflation_rate`, `guide_patch_overflow_threshold` (IBEX)
4. What changed
- AES/JPEG use broader patching; IBEX adds early return for low-overflow nets and best-layer spare-resource selection.
5. How it works (mechanism)
- Patch insertion augments guide flexibility near weak-resource points.
- IBEX avoids patching when overflow is low and selects best adjacent layer by spare resource.
- JPEG re-broadens patching and thresholds.
6. Why it helps
- Properly targeted: better detailed-route recoverability without flooding guides.
- Overuse: can increase DR freedom too much, enabling detours and extra vias.
7. When it fails
- Under-patching hurts pin accessibility; over-patching causes guide bloat.
- Failure signature: either pin-access DRC pressure or WL inflation from diffuse guides.
8. Tuning knobs and guardrails
- Keep patching tied to per-net overflow bands.
- Tune inflation rate conservatively and monitor patch area counters.
9. Evidence quality
- High confidence: all 3 branches modified guide patch intensity/policy.
10. Reproduction and validation
- One iteration: change only wire patch threshold or overflow gate.
- Evaluate pin/access failures plus WL/via changes.

### Learning CU-L07: Maze start-pin heuristic adds determinism but can add overhead
1. Learning ID
- `CU-L07`
2. Source branch(es)
- `NEWGR-CodexEvolve-CUGR-IBEX-Iter52` (added), `NEWGR-CodexEvolve-CUGR-JPEG-Iter32` (removed)
3. Code anchors
- `src/grt/src/NEWGR/src/MazeRoute.cpp`, `MazeRoute::run`
- Added logic: `numPseudoPins`, `distanceSum`, `minEscapeCost`, chosen `startPinIndex`
4. What changed
- IBEX selected a central/low-escape-cost pseudo pin instead of always starting at pin 0; JPEG restored fixed start.
5. How it works (mechanism)
- Pre-scan computes aggregate Manhattan distance and local escape costs per pseudo pin.
- Chooses start vertex minimizing expected connection expansion burden.
6. Why it helps
- Potential WL/runtime benefit by reducing early tree growth bias.
- Potential downside: extra O(P^2) pre-processing and uncertain net-level payoff.
7. When it fails
- High-pin nets pay pre-processing overhead with little tree-shape improvement.
- Failure signature: runtime increase with minimal overflow/WL change.
8. Tuning knobs and guardrails
- Apply heuristic only above a pin-count threshold.
- Keep fixed-start fallback for small nets.
9. Evidence quality
- Medium: explicit add and rollback indicate mixed value.
10. Reproduction and validation
- Re-enable only for `numPseudoPins > N` in one iteration.
- Measure runtime delta and WL benefit on large nets.

## Repeated Wins
1. Stage-aware net ordering and overflow-priority repair consistently improve where heavy reroute effort is spent.
2. Access-point selection and fixed-layer interval control repeatedly influence via count without mandatory WL loss.
3. Conditional guide patching tied to congestion/overflow repeatedly outperforms unconditional patching extremes.

## Repeated Failures and Regressions
1. Over-aggressive via suppression in PatternRoute can improve vias but hurt WL and/or overflow.
2. Hard stage gating thresholds can skip nets that still need quality repair.
3. Extra heuristic preprocessing (for example maze start-pin optimization) can add runtime without stable quality gain.

## Transferable Ideas From Other Router Families
1. From FastRoute (`NEWGR-CodexEvolve-FastRoute-JPEG-Iter137`): overflow-free bounded post-pass is a safer cleanup style than deep topology rewrites.
2. From FastRoute (`NEWGR-CodexEvolve-FastRoute-IBEX-Iter38`): use acceptance-ratio limits for expensive local search stages.
3. From SPRoute (`NEWGR-CodexEvolve-SPRoute-JPEG-Iter31`): cap thread count for quality stability when parallel sections exist.

## Iteration Budget Strategy
1. There is no hard cap on hypotheses per iteration or total iterations.
2. Primary objective is to reduce expensive iteration count by prioritizing high-impact, high-confidence hypotheses first.
3. Require predicted direction for WL/via/runtime before editing.
4. Prefer isolated changes for causal attribution; batch multiple changes only when they are tightly coupled.
5. If progress stalls, re-rank hypotheses using latest metrics and continue with a new strategy.

## Next Best Moves (Exactly 5)
1. Reintroduce mild overflow-threshold gating only for maze stage.
- Edit targets: `src/grt/src/NEWGR/include/CUGR.h`, `src/grt/src/NEWGR/src/CUGR.cpp` (`mazeRoute`).
- Acceptance checks: runtime down, WL/via non-worse, no unresolved severe overflow spike.
2. Keep stage-aware sorting but simplify tie-break hierarchy.
- Edit targets: `src/grt/src/NEWGR/src/CUGR.cpp`, `sortNetIndices`.
- Acceptance checks: fewer late-stage overflow nets and stable runtime.
3. Tune AP fixed-layer extension for compact nets only.
- Edit targets: `src/grt/src/NEWGR/src/GridGraph.cpp`, `selectAccessPoints` extension block.
- Acceptance checks: via down with WL non-regression.
4. Add patch-area budget guard.
- Edit targets: `src/grt/src/NEWGR/src/CUGR.cpp`, `getGuides` patch loops.
- Acceptance checks: patch area reduced without pin-access regressions.
5. Restore a narrow FLUTE high-accuracy window for low-degree nets.
- Edit targets: `src/grt/src/NEWGR/src/PatternRoute.cpp`, `constructSteinerTree`.
- Acceptance checks: WL improves with runtime <= +5%.

## First Iteration Plan For Next LLM Run
### Exact 1-iteration objective
Reduce WL without runtime regression by adding only maze-stage overflow gating, leaving detour and AP logic unchanged.

### Initial focus files/functions (non-binding; any NEWGR file may be edited)
You may edit any file under `/root/OpenROAD_New_GRT/src/grt/src/NEWGR` if required by the active hypothesis.

### Hypothesis table (recommended 1 to 3 to start; no hard cap)
| Hypothesis | Edit                                            | Predicted metric change                  |
| ---------- | ----------------------------------------------- | ---------------------------------------- |
| H1         | Skip maze for low-overflow nets                 | Runtime down, WL neutral/slightly better |
| H2         | Keep sparse grid at default for skipped set     | Runtime down, no quality loss            |
| H3         | Preserve overflow-priority order in maze subset | WL stable, via stable                    |
