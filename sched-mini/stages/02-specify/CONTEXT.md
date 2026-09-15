# Stage 02 — Specify (Layer 2 contract)

Turn the interview's schema-conforming response into a modeling
specification: what the model must represent, what it must decide, and
what it must optimize. No MiniZinc yet.

## Inputs

| Source | File/Location | Section/Scope | Why |
|---|---|---|---|
| Layer 4 | `../01-interview/output/scr.md` | all | The facts elicited from the expert |
| Layer 3 | `../../shared/glossary.md` | all | Canonical names to use |
| Layer 3 | `references/spec-template.md` | all | Structure of the output |
| Layer 3 | `references/modeling-choices.md` | section matching `schema:` line of scr.md | Standard formulation for that shop type |

Do **not** read `../01-interview/output/transcript.md`. If the SCR is
ambiguous, that is a defect in stage 1's output; write `BLOCKED.md`.

## Process

1. Read `scr.md`. Note the `schema:` line; load only the matching section
   of `modeling-choices.md`.
2. Check sufficiency. The spec needs: a non-empty products list, a
   non-empty resources list, durations for every (product, step) or
   routing step, at least one order with a due date, and one canonical
   objective. If any is `unknown` or missing, write `output/BLOCKED.md`
   naming each gap and the question stage 1 should ask, then stop.
3. For each entry under `other constraints (verbatim, unmodeled)` in the
   SCR decide one of: (a) already covered by the standard formulation,
   (b) add as an explicit constraint in the spec, (c) out of scope for
   this workspace (say why). Every entry must get a decision.
4. Write the **action sentences** (see `spec-template.md` §3): one plain
   sentence per thing the schedule decides or respects, each traceable to
   an SCR field. These are the contract the model must satisfy.
5. **Audit** before writing:
   - every action sentence cites an SCR field;
   - every SCR field that carries a value is used by at least one action
     sentence or is listed as deliberately unused;
   - the objective matches the SCR's canonical objective exactly.
6. Write outputs and stop. Tell the human they may edit `spec.md`.

## Outputs

| Artifact | Location | Format |
|---|---|---|
| Modeling specification | `output/spec.md` | Markdown following `spec-template.md` |
| Blocked notice (only if step 2 fails) | `output/BLOCKED.md` | Markdown; gaps + questions for stage 1 |
