# Stage 03 — Model (Layer 2 contract)

Write the MiniZinc model and data file from the specification, verify
them against the specification **and** against the original SCR, and
leave them ready for `scripts/run-minizinc.sh`.

## Inputs

| Source | File/Location | Section/Scope | Why |
|---|---|---|---|
| Layer 4 | `../02-specify/output/spec.md` | all | What to build |
| Layer 3 | `references/minizinc-conventions.md` | all | House style for the model |
| Layer 3 | `../../shared/glossary.md` | all | Identifier naming |
| Layer 4 (verify only) | `../01-interview/output/scr.md` | `orders`, `durations`/`routings`, `objective (expert's words)` | Cross-stage check, step 5 |

Do not read stage 1's `transcript.md`.

## Process

1. Read `spec.md`. If it contains `## 6. Open questions` with entries
   that affect any action sentence, write `output/BLOCKED.md` and stop.
2. Write `model.mzn`: parameters and decision variables per spec §1–§2,
   then one constraint block per action sentence in spec §3. Precede
   each block with a comment `% AS-<n>: <the sentence verbatim>`.
   Every action sentence must have exactly one such block.
3. Write `data.dzn` from spec §1 only.
4. Write `output/trace.md`: a table mapping each action sentence number
   to the line range in `model.mzn` that implements it.
5. **Verify** (cross-stage, n−2): open `../01-interview/output/scr.md`
   and check that every order, every duration and the objective in
   `data.dzn`/`model.mzn` match what the expert said. Record each check
   as pass/fail in `trace.md` §2. Do not silently fix a mismatch; if the
   spec and the SCR disagree, report it and stop.
6. Run `../../scripts/run-minizinc.sh` if the human permits; paste the
   solver's first solution into `trace.md` §3. If the solver reports
   unsatisfiable, do not relax constraints; report it.
7. **Audit**: every `AS-n` comment present once; `data.dzn` parses;
   no literal numbers in `model.mzn` that belong in `data.dzn`.
8. Write outputs and stop. Tell the human what to look at.

## Outputs

| Artifact | Location | Format |
|---|---|---|
| Model | `output/model.mzn` | MiniZinc |
| Data | `output/data.dzn` | MiniZinc data |
| Traceability and verification | `output/trace.md` | Markdown, three sections |
| Blocked notice (only if step 1 or 5 fails) | `output/BLOCKED.md` | Markdown |
