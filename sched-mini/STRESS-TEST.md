# STRESS-TEST — what this workspace is for, and what we expect to break

`sched-mini` is a faithful ICM workspace (numbered stages, stage contracts
with Inputs/Process/Outputs tables, Layer 3 references, Layer 4 handoffs,
checkpoints, audits, a local script) built for a task ICM was not designed
for: agent-led requirements discovery ending in a constraint model, i.e. a
miniature of Sched6 / schedMCP. The point is to run it as intended and
record where the folder-as-plan architecture strains.

The agent should not read this file during a run unless asked. It is for
the human.

## 1. How to run it

1. Open this folder in Claude Code. Say "start". Play the expert using
   the brief in §2 (or your own plant). Answer as a plant owner would,
   not as a modeler.
2. At each review gate, look at `output/` and decide: edit, re-run, or
   proceed. Log what you did in §4.
3. After stage 3, run `scripts/run-minizinc.sh`.
4. Then do at least one **second run** in which you change one fact at
   the *source* rather than the output (e.g., edit `_config/domain.md`
   or a discovery schema) and see what has to be re-run — the paper's
   incremental-recompilation claim (§6.1).

## 2. Surrogate expert brief (craft brewery)

> **Not used in run 1.** The run played a refrigerator-compressor plant
> instead, with answers drawn from an earlier Sched6 project
> (`../data/s6-interviews/refrigerator-compressors-report.md`) and relayed
> by the human. The two withheld facts below were therefore never injected;
> the backward move predicted in P4 arose from stage 3's own gate instead.
> The brief is kept for a future run.

Answer from this; volunteer nothing until asked, except where marked.

- Products: Pale Ale, Stout, IPA. ("three core beers")
- Every beer goes: brewhouse → fermenter → bright tank → bottling line,
  in that order. (Flow shop. Do not say "flow shop"; say "they all go
  through the same things.")
- Resources: 1 brewhouse; 2 fermenters (identical); 1 bright tank;
  1 bottling line. Each holds one batch at a time.
- Durations (hours): brewhouse 8 for every beer; fermenter 168 Pale,
  240 Stout, 192 IPA; bright tank 48 all; bottling 6 all.
- Changeover: bottling line needs 2 h cleaning between different beers.
  The rest: "no, not really" (say `none`).
- Orders this period (hours from now): O1 Pale due 300; O2 Stout due
  400; O3 IPA due 350; O4 Pale due 500. Release 0 for all.
- Objective, in your words: "The thing that kills me is a customer
  getting their beer late. I'd rather everything be a little late than
  one account be really late." (→ minimize maximum tardiness. See
  whether the agent picks that or total tardiness.)
- **Withhold until the stage-1 checkpoint summary**, then add it as a
  correction: "Oh — the two fermenters aren't really the same. The
  small one can't do Stout." This is the deliberate late fact; it is
  not expressible in the flow-shop schema's `resources` field
  (identical-parallel assumption), so watch where it lands.
- **Withhold until the stage-3 review**, then say: "Actually we can't
  bottle two different beers on the same day." Out-of-schema, arrives
  after the model exists. Watch what the workflow makes you do.

## 3. Predictions (write these before running; check after)

| # | Prediction | Where it should show | Why it matters for Sched6 |
|---|---|---|---|
| P1 | Stage 1 is a loop, not a pass. The contract has to describe the loop in prose (`interview-method.md` §2–3) because ICM has no construct for iteration inside a stage other than "checkpoint". | Length of stage 1; whether the agent stops early or over-asks | Sched6's interview cycle is the unit of work; ICM's stage is the wrong grain |
| P2 | Stage 1 must load **both** discovery schemas because the choice depends on answers. The Inputs table cannot express "load A or B depending on state". Stage 2's Inputs table dodges this with "section matching `schema:` line", which is the agent doing dynamic routing the table cannot. | The `Note:` in `01-interview/CONTEXT.md`; the third row of `02-specify` Inputs | Schema selection is exactly what `next_step_advice` / the orchestrator does; here it is smuggled into prose |
| P3 | The "small fermenter can't do Stout" correction will land in `other constraints (verbatim, unmodeled)` because the flow-shop schema has no field for resource eligibility. Stage 2 will then have to decide (b) add or (c) out of scope. If (b), the standard formulation in `modeling-choices.md` does not cover it and the agent will improvise or block. | `scr.md` §other constraints; `spec.md` §4 | A Discovery Schema that can't absorb a fact is the normal case in Sched6; the fix is to pick/extend a schema mid-interview, which needs state-dependent control |
| P4 | The stage-3 "can't bottle two beers the same day" fact forces a **backward** move: the only ICM-sanctioned path is human re-runs stage 1 (or hand-edits `scr.md`, then re-runs 2 and 3). Count how many files you touch and how many stages re-run. | §4 log | Sched6 absorbs new facts into the ASCR and re-plans; ICM makes the human the re-planner |
| P5 | Editing `scr.md` by hand at the gate (the paper's "every output is an edit surface") will be *easier* than re-interviewing, and you will do it, and it will bypass stage 1's audit. This is the edit-source tension of §6.3 in practice. | Whether you edit output or re-run | Argues for the paper's own edit-source principle; and for Sched6 keeping working state in a DB with invariants, not a free-text file |
| P6 | The n−2 Verify step in stage 3 will catch at least one discrepancy between `data.dzn` and `scr.md` (my guess: the objective, max vs. total tardiness). | `trace.md` §2 | The one ICM idea worth lifting directly into Sched6's T&E |
| P7 | Context per stage will stay small (the paper's 2–8k claim will hold) — but only because the problem is capped at 4 orders. The transcript is excluded from stage 2 by contract; had it been included, or had the interview been long, the "working state" would be the transcript, not the SCR. | Token counts in Claude Code's context indicator | Sched6's ASCR exists precisely so the working state is a structured view, not a transcript |
| P8 | Second run: changing a discovery schema (Layer 3) invalidates stage 1 output but nothing tells you so. The "implicit dependency tracking" of §6.1 is the human remembering. | §4 log | Make's dependency graph is explicit; ICM's is not |

## 4. Observation log

Fill during/after runs. One entry per gate or event.

Entries for run 1 (2026-09-15) were reconstructed afterwards from
`stages/*/output/`, `../example-blocked.md`, and `../icm-exp.org`, not
logged live. Time budgets and token counts were not recorded.

| Run | Gate/event | What happened | Prediction hit? | Note |
|---|---|---|---|---|
| 1 | Stage 1, whole | 18 questions, one checkpoint summary, corrections absorbed. Schema chosen: flow shop. Several questions (Q13 leak-test treatment, Q14 changeover by station, Q16–17 shift calendar, lot scaling) had no schema field. | P1 yes; P2 yes (both schemas loaded) | Depth came partly from agent judgment, not files. |
| 1 | Stage 1 gate | Human did not edit `scr.md`; reaction was "where is the MiniZinc?" — the gate read as a stall, not a pause. | — | First data point: gate experienced as friction. |
| 1 | `scr.md` content | 13 entries under `other constraints (verbatim, unmodeled)`: machining upstream, leak-test lag, packing lag, shift calendar, pause-across-night at three stations, no-span at run test, 2nd-shift staffing, overtime, retest risk, batching preference, dispatch-by-ship-date, lot sizing, WIP. 6 unknowns listed. | P3 yes (landing) | Objective mapped to total tardiness with two qualifications the canonical list can't hold (priority weights; changeover as strict tie-break). |
| 1 | Stage 2, whole | Did not block. Decided every one of the 13 entries (covered / added as sentence / out of scope). Introduced a working-hour time axis and a quarter-hour unit (departing from `_config/domain.md`), lags with no resource, and explicit sequence-dependent setup (departing from `modeling-choices.md`). 15 action sentences, 8 open questions. | P3 yes (improvised, recorded) | Departures recorded in spec §0 and §6 rather than hidden. |
| 1 | Stage 3, first attempt | Gate at step 1 fired: §6 Q1 (setup) is structural — decides whether AS-9 and AS-15 exist. Wrote `BLOCKED.md` naming stage 2 as the one to re-run, examined the other 7 entries and found them non-blocking, and critiqued the gate itself ("will fire on most honestly written specs"). | P4 yes (backward move, human must act) | Best artifact of the run; preserved as `../example-blocked.md`. |
| 1 | Resolution | Human chose answer A and the resolution was written into `spec.md` §6 by hand ("RESOLVED by the human, 2026-09-15"). Stage 2 was **not** re-run. | P5 yes | Stage 2's audit never saw the change. |
| 1 | Stage 3, second attempt | Wrote `model.mzn` (217 lines, 15 `AS-n` blocks), `data.dzn`, `trace.md`. Deleted `BLOCKED.md`. Two deliberate departures flagged (AS-11 narrowed; `disjunctive` redundant under AS-9). | — | Record of having been blocked survives only as prose in `trace.md` §0 and the hand-made copy. |
| 1 | Verify (n−2) | 20 checks against `scr.md`; all pass. Flagged that the objective check passes only because `weight` is all 1 (spec §6 Q3 open) and that the plan serves the escalated lot worst. | P6 half: no mismatch, but a spec-vs-expert gap caught | "The model is doing exactly what the specification says; the specification is not yet doing what the expert said." |
| 1 | Solve | Gecode: no solution at 30 s or 120 s. Agent reported it and ran Chuffed via `MZN_SOLVER`; optimal in <60 s. Total tardiness 65 wh; nothing on time; L1 infeasible by construction (47 wh path vs 42 wh available); L3 (escalated) 39.5 h late, L6 (filler) 1.5 h; batching worked (R134a lots on one stand, 4.75 h total changeover). | — | The infeasible promise is a finding for the expert; ICM has no path to take it back. Agent judgment overrode the Gecode convention, correctly. |
| 1 | Context size | Not measured. By file size, stage 3 loaded ~10k tokens. | P7 yes (approx.) | |
| 1 | Second run (Layer-3 change) | Not performed. | P8 untested | |

## 5. Questions to answer at the end of the day

- Which of P1–P8 held? Which surprised you?
- Where did the *agent* do coordination that the *files* claim to do?
  (List every place the agent had to decide what to load or what to do
  next from state rather than from position.)
- Is there anything here that SCHED6_MCP_GUIDE.md should adopt: explicit
  Inputs tables per agent? action-sentence traceability comments in
  generated MiniZinc? an n−2 verify step?
- Is there anything ICM does *better* than Sched6 for the human at the
  gate? (Candidates: the edit surface; reading `spec.md` cold; the
  transcript being a plain file.)
