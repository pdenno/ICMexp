# Stage 03 — BLOCKED at step 1

Stage 03's process step 1 reads:

> Read `spec.md`. If it contains `## 6. Open questions` with entries that
> affect any action sentence, write `output/BLOCKED.md` and stop.

`spec.md` §6 contains eight entries. One of them changes whether two action
sentences exist at all, so the gate fires and no model was written.

## The blocking entry

**§6 question 1 — sequence-dependent setup departs from the standard
formulation.**

The spec models changeover explicitly, as action sentences 9 and 15:

> 9. The schedule leaves the changeover gap between two orders that run
>    back-to-back on the same resource (and, at run test, on the same stand) …
> 15. Among schedules that tie on weighted lateness, the schedule minimizes
>     total changeover time …

`stages/02-specify/references/modeling-choices.md` §flow-shop says the
opposite for this case:

> setup (if any): treat as added to duration when capacity = 1 and setup is
> product-independent; otherwise mark as an open question

The setup here is product-dependent (cheap within R600a, expensive across the
refrigerant boundary), so the reference directs it to be raised as an open
question rather than modeled. Stage 02 modeled it and flagged the departure.

This is not a missing value that stage 3 can default. It decides the shape of
the model:

- **Answer A — keep sentences 9 and 15.** `model.mzn` needs a stand-assignment
  variable at run test, pairwise ordering booleans on all four resources, and a
  setup matrix indexed by refrigerant class. Larger search, but the model can
  express the expert's second-ranked goal ("batch the same families back-to-back
  so we're not paying changeovers we didn't need").
- **Answer B — follow `modeling-choices.md`.** Sentences 9 and 15 are deleted,
  `before[o1,o2,r]` and `stand[o]` disappear, and the resources become plain
  `disjunctive` / `cumulative`. The model is the textbook flow shop and is blind
  to changeover cost entirely. The expert's stated second priority is then
  unrepresented, and nothing in the output would show that it was dropped.

Stage 3 cannot pick between these without overriding either the spec or the
reference, and its step 5 verification would then have nothing stable to check
against.

## Which stage to re-run

**Stage 02.** The decision belongs in `spec.md` — either §6 question 1 is
resolved and removed, or the action sentence list is amended to match answer B.
Stage 01's output is not implicated: the SCR records the setup times and the
expert's objective correctly, and nothing about the interview needs redoing.

The fastest path: the human answers A or B, edits `spec.md` §6 accordingly (or
tells stage 02 to), and stage 03 re-runs.

## The other seven entries — examined, not blocking

Recorded so the human can confirm the reading rather than take it on trust.

| § | Entry | Affects an action sentence? | Why not blocking |
|---|---|---|---|
| 2 | Duration point values (midpoint-then-round-up) | No | Changes numbers in `data.dzn` only. Every action sentence stands unchanged whichever values the expert confirms. Re-running is an edit to one data file. |
| 3 | Objective weights unknown | No | Sentence 14 is written weight-agnostic, and `weight[o]` defaults to 1 in data, which reduces it exactly to the canonical total tardiness of sentence 13. The first run is unweighted — a real limitation, but not a structural one. |
| 4 | WIP undefined | No | Not modeled, cited by no sentence, and §4 already decided it out of scope. |
| 5 | Machining buffer policy | No | Could make the release column in `data.dzn` wrong; sentence 1 is unaffected either way. |
| 6 | Second-shift run-test capacity | Borderline | Sentence 8 names two stands, so a change here would reword it. Treated as already decided rather than open: the expert explicitly deferred it ("Fine to ignore for the first pass"), so the sentence reflects a resolved choice, not an unresolved one. |
| 7 | Tardiness measured in working hours | No | A reporting convention. Sentence 13 is the canonical objective on either axis; the ranking of schedules is identical. |
| 8 | Retest time excluded as stochastic | No | Excluded by `_config/domain.md`'s scope limits, cited by no sentence. |

## A note on the gate itself

The test in step 1 — any §6 entry that affects any action sentence — will fire
on most honestly written specs. `spec-template.md` §6 exists to collect exactly
the residue that a specification cannot resolve on its own, and a spec with real
open questions is doing its job. Here, seven of the eight entries are
confirmations, data refinements or recorded scope decisions that stage 3 could
carry without improvising anything; only one is structural. As written the gate
does not distinguish those cases, so the way to pass it is to write a §6 that is
empty or evasive.

Flagged for the human, not acted on: this stage followed the contract as written
and stopped.
