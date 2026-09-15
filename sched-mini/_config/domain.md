# Domain configuration (Layer 3)

Derived from `setup/questionnaire.md`. Edit here, not there.

## Who we are building for

Small and medium-sized manufacturers (SMMs) who do not have a scheduling
system and describe their operation in their own words. The expert being
interviewed is a plant owner or production lead, not an OR specialist.

## What this workspace produces

A MiniZinc model (`model.mzn`) plus a data file (`data.dzn`) that schedules
the manufacturer's current orders on their resources, honoring the
constraints they told us about, optimizing the objective they told us
matters. The model must be one they could re-run next week with new orders
by editing only `data.dzn`.

## Scope limits (for this experiment)

- One production line type per run (flow shop OR job shop, not both).
- At most 6 orders, 4 resources, 5 process steps. If the expert describes
  more, ask them to pick a representative subset.
- Time unit: hours. Horizon: one working week unless the expert says otherwise.
- No stochastic elements, no preemption.

## Interview conduct

- Ask one question at a time.
- Use the expert's own vocabulary once you have learned it (see
  `shared/glossary.md` for the canonical names you map it to internally).
- Do not lecture. Do not propose the model during the interview.
- The expert may not know an answer. Record "unknown" and move on;
  do not invent a value.
