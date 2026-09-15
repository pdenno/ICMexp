# Stage 01 — Interview (Layer 2 contract)

Elicit, from a human expert, everything the later stages need to build a
scheduling model. This stage is a conversation, not a single pass.

## Inputs

| Source | File/Location | Section/Scope | Why |
|---|---|---|---|
| Layer 3 | `../../_config/domain.md` | all | Scope limits and interview conduct |
| Layer 3 | `../../shared/glossary.md` | all | Canonical names for what you hear |
| Layer 3 | `references/discovery-schema-flow-shop.md` | all | Question template if the plant is a flow shop |
| Layer 3 | `references/discovery-schema-job-shop.md` | all | Question template if the plant is a job shop |
| Layer 3 | `references/interview-method.md` | all | How to run the loop and when to stop |
| Layer 4 | (none — this is the first stage) | | |

Note: you must load **both** discovery schemas because you do not know
which applies until the expert has answered the opening questions. Use only
one of them after that point.

## Process

1. Read the inputs. Greet the expert briefly and ask the **opening
   questions** in `interview-method.md` §1.
2. From the answers, decide: flow shop or job shop. State your decision
   to the expert in one sentence and let them correct you.
3. Work through the chosen discovery schema. Ask one question at a time.
   After each answer, update your draft SCR (schema-conforming response)
   in memory. Do not show the SCR to the expert unless asked.
4. **Checkpoint** (ICM Pattern 11): when every schema field is either
   filled or marked `unknown`, show the expert a plain-language summary
   (not the SCR) and ask whether anything is wrong or missing.
5. Incorporate corrections. Repeat step 4 until the expert says it is right.
6. **Audit** (ICM Pattern 12) before writing outputs:
   - every field in the chosen schema is filled or `unknown`;
   - every resource named in a step exists in the resources list;
   - every product in an order exists in the products list;
   - the objective is stated in the expert's words and mapped to one
     canonical objective from the schema.
7. Write the outputs and stop. Tell the human stage 1 is complete and that
   they may edit `output/scr.md` before stage 2.

## Outputs

| Artifact | Location | Format |
|---|---|---|
| Transcript of the interview | `output/transcript.md` | Markdown; `**Q:**` / `**A:**` turns, verbatim |
| Schema-conforming response | `output/scr.md` | Markdown; the chosen schema's template, filled |
| Which schema was used | (recorded in the first line of `scr.md`) | `schema: flow-shop` or `schema: job-shop` |
