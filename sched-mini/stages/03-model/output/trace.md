# Stage 03 — traceability and verification

Model: `model.mzn` (217 lines). Data: `data.dzn`. Solver output: `solution.txt`.

## §0 This stage blocked once, then ran

Step 1 of the stage contract stops the stage if `spec.md` §6 contains open
questions that affect an action sentence. It did, and `BLOCKED.md` was written
naming **§6 question 1 — sequence-dependent setup** as the structural one: it
decided whether action sentences 9 and 15 exist at all. The other seven entries
were examined and found to be data refinements, reporting conventions or scope
decisions the expert had already made.

The human answered **A — model sequence-dependent setup explicitly**, which was
recorded in `stages/02-specify/output/spec.md` §6 as resolved, and this stage
re-ran against the amended spec. `BLOCKED.md` was then removed, because a stale
blocked notice sitting beside a finished model would misread as an active block;
this section is its record.

## §1 Action sentence → model

| AS | Sentence (abbreviated) | `model.mzn` lines | Implementation |
|---|---|---|---|
| 1 | starts no step before the order's release hour | 69–72 | `start[o,k] >= release[o]` for every step |
| 2 | braze only after build has finished | 74–77 | precedence |
| 3 | vac/oil at least 6 h after braze finishes | 79–82 | precedence + `leak_lag` |
| 4 | run test only after vac/oil has finished | 84–87 | precedence |
| 5 | never two orders on the assembly line at once | 89–91 | `disjunctive` |
| 6 | never two orders in the braze cell at once | 93–95 | `disjunctive` |
| 7 | never two orders on the vac/oil station at once | 97–99 | `disjunctive` |
| 8 | each order on one of two stands, never two on a stand at once | 101–108 | `cumulative` at capacity 2 + same-stand non-overlap |
| 9 | changeover gap between back-to-back orders on a resource / stand | 110–124 | `before` ordering booleans + setup-separated disjunction; stand-guarded at run test |
| 10 | durations are working hours only | 126–132 | the working-hour axis itself; the block keeps every step inside the horizon |
| 11 | run test finishes on the working day it starts | 134–140 | `start mod day_len + dur <= day_len` |
| 12 | delivered 3.5 h after run test finishes | 142–146 | `delivery[o]` + `pack_lag` |
| 13 | minimize sum of hours delivered after promised | 148–153 | `tardiness[o] = max(0, delivery − due)`, `total_tardiness` |
| 14 | count lateness by priority weight | 155–156 | `weighted_tardiness` |
| 15 | tie-break on total changeover time, never buying it with lateness | 158–179 | `adj` immediate-successor booleans, `total_setup`, and `objective = weighted_tardiness * setup_scale + total_setup` |

Each `% AS-<n>:` comment appears exactly once and carries the sentence verbatim
from spec §3.

### Two departures, both deliberate and visible in the model

**AS-11 is narrowed.** The sentence says run test finishes "including its
changeover" within the working day. The model contains the *processing* in one
day; the changeover is charged as separation between two lots (AS-9), not as an
occupied block that must itself fit the day. Identifying an order's immediate
predecessor in order to place its changeover would duplicate the `adj` machinery
inside a day-containment constraint. Consequence: a plan may imply adapters being
changed across the 22:00 boundary. At run test the changeover is at most 1 h, so
the distortion is bounded by that. Flagged rather than fixed — stage 2's sentence
is the contract, and narrowing it is a change the human should see.

**AS-5/6/7 use `disjunctive`, which AS-9 then strengthens.** The conventions
require the globals, and the globals cannot carry sequence-dependent setup. Both
are posted: `disjunctive` for propagation, the setup-separated pairwise
disjunction for correctness. The `disjunctive` calls are therefore redundant, not
wrong, and they are what the three sentences literally say.

## §2 Cross-stage verification against `stages/01-interview/output/scr.md`

Checked: every order, every duration, and the objective. Times in `data.dzn` are
quarter-hours (qh) on the working-hour axis; the SCR is in wall-clock hours, so
each order check also verifies the spec's conversion.

| # | Check | SCR says | Model/data has | Result |
|---|---|---|---|---|
| 1 | L1 | R600a-LBP, 300, release 0, due 64 | `R600a_LBP`, 300, 0, 168 qh = working h 42 = Wed 16:00 | **pass** |
| 2 | L2 | R600a-MBP, 300, release 0, due 88 | `R600a_MBP`, 300, 0, 232 qh = working h 58 = Thu 16:00 | **pass** |
| 3 | L3 | R134a-legacy, 300, release 0, due 88 | `R134a_legacy`, 300, 0, 232 qh | **pass** |
| 4 | L4 | R600a-LBP, 300, release 0, due 112 | `R600a_LBP`, 300, 0, 296 qh = working h 74 = Fri 16:00 | **pass** |
| 5 | L5 | R134a-legacy, 300, release 30, due 112 | `R134a_legacy`, 300, 64 qh = working h 16 = Tue 06:00, 296 qh | **pass** |
| 6 | L6 | R600a-MBP, 200, release 0, due 184 | `R600a_MBP`, 200, 0, 360 qh = working h 90 = next Mon 16:00 | **pass** |
| 7 | the expert's own conversion check | "Wednesday 16:00 is still hour 64 on the wall, but only 42 working hours in" | L1 due 168 qh = 42 working h | **pass** |
| 8 | build duration | 9–12 h, all products | 42 qh = 10.5 h (spec's midpoint) | **pass** — inside the SCR range |
| 9 | braze duration | 6–8 h, all products | 28 qh = 7 h | **pass** — inside the range |
| 10 | vac/oil duration | "8 (range 6–10)" | 32 qh = 8 h | **pass** — exactly the expert's number |
| 11 | run-test duration, R600a | 10–14 h | 48 qh = 12 h | **pass** — inside the range |
| 12 | run-test duration, R134a-legacy | 12–16 h | 56 qh = 14 h | **pass** — inside the range, and longer than the R600a products as the expert said |
| 13 | duration scaling | durations "scale linearly with quantity"; setup does not | `dur = (dur_per_lot * qty + lot_base − 1) div lot_base`; L6 → 28/19/22/32 qh = 7 / 4.75 / 5.5 / 8 h | **pass** |
| 14 | setup, assembly line | 0 within R600a, 0.5 h across | 0 / 2 qh | **pass** |
| 15 | setup, braze cell | 0.25 / 0.75 h | 1 / 3 qh | **pass** |
| 16 | setup, vac/oil | 0 / 0.5 h | 0 / 2 qh | **pass** |
| 17 | setup, run test | 0.25 / 1.0 h | 1 / 4 qh | **pass** |
| 18 | setup, same product back-to-back | "No changeover cost when the same product runs back-to-back" | diagonal of every `setup` block is 0 | **pass** |
| 19 | objective, canonical | "minimize total tardiness" | `total_tardiness` is declared and, with all weights 1, is the primary term of `objective` | **pass** |
| 20 | objective, the expert's ranking | "I'd rather pay one extra changeover than miss a promise, every time" | `setup_scale` = 67 qh, strictly greater than the 66 qh upper bound on `total_setup`, so one quarter-hour of lateness outweighs every changeover in the plan | **pass** |

**No mismatch between the spec and the SCR was found.** Nothing was silently
fixed.

One finding that is not a mismatch but must not be lost: check 19 passes only
because `weight` is all 1 in `data.dzn`, which spec §6 question 3 left open. The
SCR is explicit that L3 is escalated and L6 is filler. The solved plan below
makes L3 the *worst-served* lot. The model is doing exactly what the
specification says; the specification is not yet doing what the expert said.

## §3 Solver result

The conventions target `minizinc --solver gecode` and say a 6-order instance
should solve in seconds. **It does not.** Gecode found no solution at all — not a
poor one, none — at the script's default 30 s limit, and none at 120 s. Reported
rather than tuned, as the conventions direct. No search annotations or symmetry
breaking were added.

Chuffed solves the same model and **proves optimality in under 60 s**. The run
below is `MZN_SOLVER=chuffed MZN_TIMEOUT_MS=60000 bash scripts/run-minizinc.sh`;
the script already exposes `MZN_SOLVER`, so it needed no change. The trailing
`==========` in `solution.txt` is MiniZinc's proof-of-optimality marker.

```
order  product        stand  build starts  test starts   test ends     on the dock   promised      late
--------------------------------------------------------------------------------------------------------------
L1     R600a_LBP      2      Mon 06:00     Wed 06:00     Wed 18:00     Wed 21:30     Wed 16:00     5.50 h late
L2     R600a_MBP      2      Mon 16:30     Thu 06:00     Thu 18:00     Thu 21:30     Thu 16:00     5.50 h late
L3     R134a_legacy   1      Wed 16:30     Mon+1 06:00   Mon+1 20:00   Tue+1 07:30   Thu 16:00     39.50 h late
L4     R600a_LBP      2      Tue 11:00     Fri 06:00     Fri 18:00     Fri 21:30     Fri 16:00     5.50 h late
L5     R134a_legacy   1      Wed 06:00     Fri 06:00     Fri 20:00     Mon+1 07:30   Fri 16:00     7.50 h late
L6     R600a_MBP      2      Thu 14:45     Mon+1 06:00   Mon+1 14:00   Mon+1 17:30   Mon+1 16:00   1.50 h late

total tardiness (working hours): 65
weighted tardiness             : 65
total changeover time          : 4.75
```

### Reading the plan

- **Nothing ships on time.** The best achievable total is 65 working hours of
  lateness across six lots, and this is proved optimal, not a solver giving up.
- **L1 cannot make Wednesday, by construction.** One lot's own path is
  build 10.5 + braze 7 + leak 6 + vac 8 + run test 12 = 43.5 working hours, plus
  3.5 h packing = 47 h, against a promise at working hour 42. Starting at hour 0
  on an empty plant, L1 is 5 h late; the run-test day-containment rule (AS-11)
  adds the remaining half hour. **No schedule of any kind meets that promise**
  with these durations. Spec §6 question 2 — whether the midpoint durations are
  the right planning numbers — decides whether this is real or an artifact.
- **The escalated lot is served worst.** L3 is 39.5 working hours late — two and
  a half working days — while the filler L6 lands 1.5 h late. With all weights at
  1 the objective is indifferent to which lot absorbs the lateness, and it loaded
  it onto the R134a lots because their changeovers are expensive and their run
  test is 2 h longer. This directly contradicts the expert: "If something has to
  miss, it's the lot with the latest promise or the filler, not the escalated
  one." The fix is spec §6 question 3, not a change to the model.
- **Batching worked.** Total changeover time is 4.75 h. Both R134a lots (L3, L5)
  are on stand 1 and all four R600a lots on stand 2, so the expensive 1 h
  refrigerant changeover at run test is never paid — the pairing the expert
  predicted: "3 and 5 are both R134a — we'd normally try to run those pairs
  back-to-back on run test."
- **The plan runs into the following week.** L3, L5 and L6 finish after Friday
  22:00. The horizon permits it, the expert's week does not, and no constraint
  forbids it because none was specified.

## §4 Audit

| Check | Result |
|---|---|
| every `% AS-<n>` comment present exactly once, n = 1..15 | pass — 15 comments, one per sentence |
| `data.dzn` parses | pass — model compiles and solves |
| no literal numbers in `model.mzn` that belong in `data.dzn` | pass — `shift_start_hour`, `qh_per_hour` and `day_len` were moved into data during this stage; the literals that remain are string-formatting widths and zero-padding |
| model declares parameters only, all problem data in `data.dzn` | pass |
| `globals.mzn` included; `disjunctive` / `cumulative` used rather than hand-written no-overlap | pass, with the AS-9 strengthening noted in §1 |
| identifiers use glossary names in snake_case | pass — `order`, `step`, `resource`, `dur`, `release`, `due`, `setup` |
| objective named and in a single `solve minimize` | pass — `objective`, line 179 |
| output block readable without MiniZinc | pass — one line per order, wall-clock times |
| no search annotations, no symmetry breaking | pass |
| re-runnable next week by editing only `data.dzn` | pass — a new order needs product, quantity, release and due; its durations derive from `dur_per_lot` and `qty` |
