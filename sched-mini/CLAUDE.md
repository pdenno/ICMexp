# sched-mini — an ICM workspace (Layer 0: "Where am I?")

You are in `sched-mini`, an Interpretable Context Methodology (ICM) workspace.
Its purpose is to take a small manufacturer from a conversation about their
production to a working MiniZinc scheduling model, in three stages, with a
human review gate after each stage.

This workspace is also an **experiment**. It was built to test whether ICM's
folder-as-plan architecture can carry a problem-solving task of the kind the
Sched6 / schedMCP system performs (agent-led requirements discovery). Read
`STRESS-TEST.md` only if the human asks about the experiment; otherwise run
the workspace exactly as ICM intends and let the friction show.

## How this workspace works

- Stages live in `stages/` and are numbered in execution order.
- Each stage has a `CONTEXT.md` (its contract), a `references/` folder
  (Layer 3: stable material), and an `output/` folder (Layer 4: this run's
  artifacts, which the next stage reads).
- `_config/` holds workspace-wide reference material (Layer 3).
- `shared/` holds cross-stage constants.
- `scripts/` holds local, non-AI mechanical work (running the solver).
- `setup/questionnaire.md` was answered once; its answers are in `_config/`.

## Rules you must follow

1. Load only what the current stage's `CONTEXT.md` Inputs table names.
   Do not read other stages' folders unless the table sends you there.
2. Write outputs only to the current stage's `output/` folder, using the
   file names the Outputs table gives.
3. Stop at the end of every stage. The human reviews and may edit `output/`
   before telling you to run the next stage. Never run two stages in one go.
4. If a stage cannot complete because earlier output is insufficient, do not
   improvise the missing content. Write `output/BLOCKED.md` saying exactly
   what is missing and which earlier stage should be re-run, then stop.
5. Treat `references/` and `_config/` as constraints to internalize.
   Treat `output/` files from earlier stages as input to transform.

## Where to go next

Read `CONTEXT.md` in this folder for task routing.
