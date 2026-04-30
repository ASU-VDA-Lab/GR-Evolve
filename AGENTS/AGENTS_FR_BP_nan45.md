You must follow the flow given below:
1. Read the `Branch Scope Declaration` and only use the allowed branches listed there as evidence.
2. Read `/root/GR_SUMMARY.md` and extract FastRoute-relevant principles (plus transferable ideas from CUGR/SPRoute) before choosing hypotheses.
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
1. `NEWGR-CodexEvolve-FastRoute-AES-Iter147`
2. `NEWGR-CodexEvolve-FastRoute-IBEX-Iter38`
3. `NEWGR-CodexEvolve-FastRoute-JPEG-Iter137`

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
### Learning FR-L01: Dynamic local maze window is robust for WL and runtime
1. Learning ID
- `FR-L01`
2. Source branch(es)
- `NEWGR-CodexEvolve-FastRoute-AES-Iter147`, `NEWGR-CodexEvolve-FastRoute-IBEX-Iter38`, `NEWGR-CodexEvolve-FastRoute-JPEG-Iter137`
3. Code anchors
- `src/grt/src/NEWGR/src/maze.cpp`
- Function: `FastRouteCore::mazeRouteMSMD`
- Constants/params: `min_local_expand = 3`, `expand_ratio = 0.35`, `dynamic_cap`, `effective_enlarge`
4. What changed
- Fixed global `enlarge_` per edge was replaced by edge-length-adaptive expansion (`effective_enlarge`) before region bounding box construction.
5. How it works (mechanism)
- For each tree edge, Manhattan length determines a cap on search box growth.
- Short edges keep a tight box, long edges still get enough freedom.
- Decrease schedule (`decrease`) is applied against `effective_enlarge`, not global `enlarge_`.
- This reduces needless node expansions on easy edges while preserving escape routes for hard edges.
6. Why it helps
- WL: tighter region limits reduce opportunistic long detours on short segments.
- Via: fewer long detours usually means fewer corrective layer switches later.
- Runtime: smaller average maze region lowers heap and neighbor expansion cost.
7. When it fails
- Designs with broad correlated congestion plateaus can need wider search even for short edges.
- Failure signature: overflow stagnates while many rerouted edges report unchanged bbox-limited paths.
8. Tuning knobs and guardrails
- Tune `expand_ratio` in `[0.30, 0.45]`; keep `min_local_expand >= 3`.
- Stop increasing ratio if runtime rises >8% without overflow reduction after 2 iterations.
9. Evidence quality
- High confidence: same pattern present in all 3 branches with identical control-flow placement.
10. Reproduction and validation
- Run one iteration changing only `expand_ratio`; compare `totalOverflow`, DR WL, and runtime.
- Accept if WL does not regress and runtime stays within +5% while overflow is non-worse.

### Learning FR-L02: Difficulty-first net ordering is a repeated via/WL lever
1. Learning ID
- `FR-L02`
2. Source branch(es)
- `NEWGR-CodexEvolve-FastRoute-AES-Iter147`, `NEWGR-CodexEvolve-FastRoute-IBEX-Iter38`, `NEWGR-CodexEvolve-FastRoute-JPEG-Iter137`
3. Code anchors
- `src/grt/src/NEWGR/include/DataType.h` (`OrderNetPin::difficulty`)
- `src/grt/src/NEWGR/src/utility.cpp` (`compareNetPins`, `netpinOrderInc`)
- Constants: `via_component`, `pin_component`, `span_component`, `-400/+800` bias rules
4. What changed
- Net ordering now adds a computed `difficulty` score based on unique pin layers, pin count, and bbox span.
5. How it works (mechanism)
- Multi-layer, many-pin, wide-span nets route earlier.
- Earlier routing determines shared resources for later easy nets.
- Layer-rich nets are prioritized before resources are fragmented by small nets.
6. Why it helps
- WL: fewer late-stage rip-ups on hard nets reduces tree fragmentation.
- Via: early settlement of hard multilayer nets avoids repeated layer reassignment churn.
- Runtime: fewer late hard reroutes can reduce expensive maze invocations.
7. When it fails
- If difficulty overweights layer count, small critical nets can be delayed too much.
- Failure signature: easy nets accumulate overflow despite abundant nearby capacity.
8. Tuning knobs and guardrails
- Keep relative weights near `1000:200:50` (via:pin:span) initially.
- Adjust in <=20% steps; do not change all three weights in one iteration.
9. Evidence quality
- High confidence: same scoring logic and comparator role across all 3 branches.
10. Reproduction and validation
- One-iteration A/B: enable/disable `difficulty` term only.
- Validate by comparing reroute counts on high-degree nets plus DR via count direction.

### Learning FR-L03: Phase-aware layer-assignment via penalties reduce late via explosions
1. Learning ID
- `FR-L03`
2. Source branch(es)
- `NEWGR-CodexEvolve-FastRoute-AES-Iter147`, `NEWGR-CodexEvolve-FastRoute-IBEX-Iter38`, `NEWGR-CodexEvolve-FastRoute-JPEG-Iter137`
3. Code anchors
- `src/grt/src/NEWGR/src/utility.cpp` (`assignEdge`)
- Helpers: `iterationPenaltyScale`, `localLayerCongestion`, `congestionPenalty`
- Snapshots in `FastRoute.cpp`: `layer_assign_iter_snapshot_`, `layer_assign_total_iters_snapshot_`
4. What changed
- Layer transition penalties are no longer static; they are phased by iteration and destination congestion.
5. How it works (mechanism)
- Early phase keeps penalties low to preserve flexibility.
- Mid/late phases raise via penalties as congestion clears.
- Additional penalty applies when switching into more congested layers.
- JPEG branch adds explicit floor (`adaptive_via_cost >= 1`) to avoid zero-cost layer hopping.
6. Why it helps
- Via: stronger late penalties suppress gratuitous layer bouncing.
- WL: targeted penalty on congested destination layers avoids long cleanup detours later.
- Runtime: fewer oscillatory layer moves reduce repeated adjustment cost.
7. When it fails
- Over-penalization too early can trap paths on crowded layers and inflate overflow.
- Failure signature: 3D overflow remains while via count looks artificially low.
8. Tuning knobs and guardrails
- Keep phase breakpoints near `0.2` and `0.7` unless proven otherwise.
- Keep destination-layer penalty slope conservative; avoid >2x jump in one iteration.
9. Evidence quality
- High confidence: structure exists in all 3, with JPEG refining penalty shape.
10. Reproduction and validation
- Sweep one knob at a time: only penalty scale or only phase breakpoint.
- Accept only if DR via drops and WL non-regresses; reject if overflow increases.

### Learning FR-L04: Aggressive speed-mode gating is a repeated regression source
1. Learning ID
- `FR-L04`
2. Source branch(es)
- `NEWGR-CodexEvolve-FastRoute-AES-Iter147` (introduced), `NEWGR-CodexEvolve-FastRoute-IBEX-Iter38` (removed)
3. Code anchors
- `src/grt/src/NEWGR/src/FastRoute.cpp`
- Removed in IBEX: `speed_candidate`, `skip_spiral`, selective spiral subset, reduced `max_overflow_increases`
4. What changed
- AES introduced a "speed candidate" path that skipped/trimmed spiral and relaxed convergence checks; IBEX removed it.
5. How it works (mechanism)
- Speed mode cut expensive refinement stages under mild-congestion heuristics.
- It also reduced overflow-increase tolerance and tightened search windows.
- This reduced runtime but reduced solution maturation opportunities.
6. Why it helps
- Runtime can improve in easy designs when early routing is already close to feasible.
- But primary objective (WL) can regress if detours are left unpolished.
7. When it fails
- Dense/high-interaction designs where early mild metrics hide latent detours.
- Failure signature: fast completion, nonzero post-route detour patterns, worse DR WL.
8. Tuning knobs and guardrails
- Keep speed-mode off by default for WL-focused campaign.
- If reintroduced, gate by strict objective checks, not only overflow counters.
9. Evidence quality
- Medium-high: explicit introduction in AES and explicit rollback in IBEX.
10. Reproduction and validation
- Run one controlled iteration enabling speed gate only.
- Reject if WL regresses even if runtime improves.

### Learning FR-L05: Overflow-free 2D post-pass is high upside but needs bounded scope
1. Learning ID
- `FR-L05`
2. Source branch(es)
- `NEWGR-CodexEvolve-FastRoute-IBEX-Iter38`, `NEWGR-CodexEvolve-FastRoute-JPEG-Iter137`
3. Code anchors
- `src/grt/src/NEWGR/src/FastRoute.cpp`
- IBEX: bounded A* and topology-recovery block (`kAstar*`, `kTopoAstarExtraBudget`)
- JPEG: simpler bounded post-pass for detoured/fragmented routes
4. What changed
- Post-overflow cleanup added to shorten detoured routes without reintroducing overflow.
5. How it works (mechanism)
- Run only when 2D overflow is zero.
- Re-evaluate each eligible edge/path in local bounded search.
- Commit replacement only if capacity-feasible and shorter.
- JPEG version drops heavy topology rebuilding to reduce runtime unpredictability.
6. Why it helps
- WL: directly removes congestion-era detour residue.
- Via: cleaner 2D geometry reduces layer-assignment correction pressure.
- Runtime: bounded local searches keep cost controlled versus full reroute rounds.
7. When it fails
- Overly large A* budgets create runtime blowups for marginal WL gain.
- Failure signature: many A* attempts with low accepted-improvement ratio.
8. Tuning knobs and guardrails
- Keep capped attempts and expansions; tune only one budget parameter per iteration.
- Require acceptance ratio threshold (for example >=5%) before increasing search budget.
9. Evidence quality
- Medium-high: present in 2 branches; JPEG is a deliberate simplification of IBEX.
10. Reproduction and validation
- Start with JPEG-style bounded pass, then increment only if acceptance ratio is high.
- Validate WL/via deltas and runtime overhead separately.

### Learning FR-L06: RSMT policy must stay wirelength-first with guarded congestion use
1. Learning ID
- `FR-L06`
2. Source branch(es)
- `NEWGR-CodexEvolve-FastRoute-AES-Iter147`, `NEWGR-CodexEvolve-FastRoute-IBEX-Iter38`, `NEWGR-CodexEvolve-FastRoute-JPEG-Iter137`
3. Code anchors
- `src/grt/src/NEWGR/src/RSMT.cpp`
- Functions/lambdas: `gen_brk_RSMT`, `fluteNormal`, `fluteCongest`, `edgeShiftNew`
- Branch-specific knobs: FLUTE accuracy windows, congestion-tree gating by degree, shift window
4. What changed
- All branches altered RSMT generation to reduce WL: AES hybrid cost model, IBEX lightweight WL-vs-overflow scoring, JPEG simpler degree-gated congestion use and broader edge-shift window.
5. How it works (mechanism)
- Control whether congestion-distorted FLUTE is used, then optionally apply edge shifting.
- Accuracy settings trade runtime for topology quality on selected degree ranges.
- Later branches trend toward simpler conditions and bounded complexity.
6. Why it helps
- WL: better initial tree reduces downstream detour dependence.
- Via: fewer bends and cleaner trees usually reduce layer transitions.
- Runtime: targeted accuracy avoids blanket high-cost tree generation.
7. When it fails
- Overusing congestion-driven FLUTE can inflate tree length even when overflow is manageable.
- Overusing edge-shift or high accuracy can raise runtime without net WL gain.
8. Tuning knobs and guardrails
- Keep congestion-driven FLUTE for higher-degree nets only.
- Keep high FLUTE accuracy to a bounded degree band; expand only with evidence.
9. Evidence quality
- High confidence: all three branches modify this stage with a consistent WL-first intent.
10. Reproduction and validation
- One iteration: adjust only degree threshold for congestion-driven FLUTE.
- Accept only if DR WL improves and runtime overhead remains bounded.

### Learning FR-L07: Heavy parallel maze infrastructure produced maintenance complexity with unclear WL gain
1. Learning ID
- `FR-L07`
2. Source branch(es)
- `NEWGR-CodexEvolve-FastRoute-AES-Iter147` (added), `NEWGR-CodexEvolve-FastRoute-IBEX-Iter38` (removed)
3. Code anchors
- `src/grt/src/NEWGR/src/maze.cpp`, `src/grt/src/NEWGR/include/FastRoute.h`, deleted `src/grt/src/NEWGR/src/maze_parallel.cpp`
- Symbols: `mazeRouteMSMDParallel`, heap position maps, OpenMP blocks, callback-based usage updates
4. What changed
- AES introduced parallel cost-table build and parallel maze path flow; IBEX removed it and returned to serial path in main reroute loop.
5. How it works (mechanism)
- Parallel path used thread-local structures and barrier-style update patterns.
- This increased code-path complexity in setup heap, route update, and usage accounting.
- IBEX simplification reduced branching and removed parallel-only memory management paths.
6. Why it helps
- Runtime can improve in some cases, but determinism and quality consistency become harder to control.
- For WL-focused iterations, stable serial behavior gave cleaner signal for algorithm tuning.
7. When it fails
- Parallel ordering/heuristic interaction can create noisy result variance iteration to iteration.
- Failure signature: metric jitter not explained by code intent.
8. Tuning knobs and guardrails
- Keep serial default while optimizing WL/via logic.
- Reintroduce parallel only after stable quality strategy is locked.
9. Evidence quality
- Medium-high: explicit add/remove sequence with substantial code deletion.
10. Reproduction and validation
- If testing parallel again, isolate to one stage and run repeated seeds to measure variance.

## Repeated Wins
1. Adaptive local maze windows (`effective_enlarge`) repeatedly preserve WL while limiting runtime growth.
2. Difficulty-aware ordering plus phased via penalties repeatedly reduce late via churn without hurting convergence.
3. Overflow-free 2D detour cleanup (bounded) repeatedly improves route compactness after congestion is solved.

## Repeated Failures and Regressions
1. Early speed-mode gating (spiral skip and shortened convergence patience) repeatedly risks WL regressions.
2. Overly complex/parallel reroute infrastructure increases noise and obscures causal metric attribution.
3. Excessive congestion-driven topology bias can overpay wirelength to avoid overflow that later stages could resolve.

## Transferable Ideas From Other Router Families
1. From CUGR (`NEWGR-CodexEvolve-CUGR-IBEX-Iter52`): overflow-threshold stage gating avoids spending heavy stages on low-overflow nets; apply this to FastRoute post-pass candidate selection.
2. From CUGR (`NEWGR-CodexEvolve-CUGR-JPEG-Iter32`): stage-dependent net ordering (initial compact-first vs overflow-first) can refine reroute priority beyond a single global sort.
3. From SPRoute (`NEWGR-CodexEvolve-SPRoute-JPEG-Iter31`): thread cap (`kMaxRoutingThreads = 8`) stabilizes quality in parallel sections; useful if FastRoute parallel paths are reintroduced.

## Iteration Budget Strategy
1. There is no hard cap on hypotheses per iteration or total iterations.
2. Primary objective is to reduce expensive iteration count by prioritizing high-impact, high-confidence hypotheses first.
3. Require predicted direction for WL/via/runtime before editing.
4. Prefer isolated changes for causal attribution; batch multiple changes only when they are tightly coupled.
5. If progress stalls, re-rank hypotheses using latest metrics and continue with a new strategy.

## Next Best Moves (Exactly 5)
1. Tighten RSMT congestion-tree gate to reduce unnecessary topology inflation.
- Edit targets: `src/grt/src/NEWGR/src/RSMT.cpp`, function `gen_brk_RSMT`.
- Change: raise congestion-tree degree threshold slightly; keep edgeShift window fixed.
- Acceptance checks: DR WL down or equal, via down or equal, runtime <= +5%.
2. Add acceptance-ratio guard to overflow-free post-pass.
- Edit targets: `src/grt/src/NEWGR/src/FastRoute.cpp`, post-pass block after 2D overflow cleanup.
- Change: stop A* attempts when accepted_improvements/attempts falls below threshold.
- Acceptance checks: runtime improves versus current post-pass while WL remains non-worse.
3. Calibrate destination-layer congestion penalty slope only.
- Edit targets: `src/grt/src/NEWGR/src/utility.cpp`, `congestionPenalty` logistic scaling.
- Change: one-parameter slope sweep, keep phase breakpoints unchanged.
- Acceptance checks: via decreases with no overflow increase and no WL regression.
4. Add low-cost telemetry counters for causal diagnosis.
- Edit targets: `src/grt/src/NEWGR/src/FastRoute.cpp`, `RSMT.cpp`, `utility.cpp`.
- Change: counters for post-pass attempts/accepts, congestion-tree usage rate, layer-switch counts.
- Acceptance checks: logs expose per-stage acceptance and enable reject/continue decisions in one run.
5. Introduce bounded stage gating for post-pass candidate nets using overflow and detour score.
- Edit targets: `src/grt/src/NEWGR/src/FastRoute.cpp`.
- Change: candidate subset selection based on detour length and local congestion history.
- Acceptance checks: same or better WL at lower runtime than applying post-pass to all eligible nets.

## First Iteration Plan For Next LLM Run
### Exact 1-iteration objective
Reduce DR wirelength by trimming low-value overflow-free post-pass work while preserving via count and runtime non-regression.

### Initial focus files/functions (non-binding; any NEWGR file may be edited)
You may edit any file under `/root/OpenROAD_New_GRT/src/grt/src/NEWGR` if required by the active hypothesis.

### Hypothesis table (recommended 1 to 3 to start; no hard cap)
| Hypothesis | Edit                                                  | Predicted metric change                                   |
| ---------- | ----------------------------------------------------- | --------------------------------------------------------- |
| H1         | Add acceptance-ratio early-stop in post-pass          | Runtime improves, WL neutral/slightly better              |
| H2         | Restrict post-pass to top detoured edges only         | Runtime improves, via neutral, WL neutral/slightly better |
| H3         | Keep bounded A* budget fixed; remove low-gain retries | Runtime improves, WL unchanged                            |
