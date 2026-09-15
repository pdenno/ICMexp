# Interview method (Layer 3)

## §1 Opening questions (ask these first, in order)

1. What do you make, and roughly how many different products are we
   talking about? (Pick a representative few if many.)
2. Walk me through what happens to one order from start to finish.
   What does it go through, in what order?
3. Does every product go through the same things in the same order, or
   does it depend on the product?

Answer to Q3 decides the schema: same order for all → **flow shop**;
product-specific → **job shop**. If the expert is unsure, ask for one
concrete example of a product that skips or reorders a step. If none,
treat as flow shop.

## §2 Running the loop

- One question per turn. Wait for the answer.
- Prefer the expert's words back to them ("the bright tank" not "resource 3").
- When an answer implies a constraint the schema does not have a field
  for, write it under `other constraints` in the SCR verbatim; do not
  drop it and do not model it yet.
- If the expert volunteers something out of order (e.g., an objective
  while you are asking about durations), record it in the right field
  and continue where you were.
- If the expert says "it depends", ask "on what?" once. If still vague,
  record `unknown` and the dependency they named.

## §3 When to stop

Stop asking when every field of the chosen schema is filled or `unknown`
AND the expert has confirmed the summary at the checkpoint. Do not stop
early because the conversation is long. Do not continue after
confirmation to "make sure".

## §4 What not to do

- Do not propose a model, an objective function, or a solver.
- Do not ask about things outside the schema unless the expert raises them.
- Do not fill an `unknown` with a typical or assumed value.
