# sched-mini routing (Layer 1: "Where do I go?")

## Task routing

| Human says | Go to | Notes |
|---|---|---|
| "start", "interview me", "run stage 1" | `stages/01-interview/CONTEXT.md` | Clears nothing; if `01-interview/output/` is non-empty, ask whether to overwrite |
| "specify", "run stage 2" | `stages/02-specify/CONTEXT.md` | Requires `01-interview/output/scr.md` |
| "model", "run stage 3" | `stages/03-model/CONTEXT.md` | Requires `02-specify/output/spec.md` |
| "solve", "run the model" | `scripts/run-minizinc.sh` | Mechanical; no AI needed |
| "status" | Look at which `output/` folders are non-empty and report | |

## Shared resources (Layer 3, all stages)

| Resource | Location | Purpose |
|---|---|---|
| Domain configuration | `_config/domain.md` | Who the manufacturer is, what "done" means for this workspace |
| Terminology | `shared/glossary.md` | Canonical names for scheduling concepts used in every stage |

## Stage sequence

```
01-interview  ->  02-specify  ->  03-model  ->  (scripts/run-minizinc.sh)
      |               |              |
   review gate     review gate    review gate
```

Stages are strictly sequential. There is no branching. If a later stage finds
earlier output insufficient, it writes `BLOCKED.md` and the human decides
which stage to re-run.
