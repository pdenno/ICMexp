# Specification template (Layer 3)

Copy into `output/spec.md`. Keep headings. Cite SCR fields as
`[scr: <section>]`.

```
# Modeling specification
schema: <flow-shop | job-shop>          [scr: schema]

## 1. Sets and parameters
- Products: ...                          [scr: products]
- Resources (with capacity): ...         [scr: resources]
- Steps / routings: ...                  [scr: steps | routings]
- Durations table: ...                   [scr: durations | routings]
- Setup times: ... | none                [scr: setup / changeover]
- Orders (product, qty, release, due)    [scr: orders]
- Horizon (hours): <n>                   [derived: sum of all durations + max due, rounded up]

## 2. Decisions
- start time of each (order, step)
- (job shop only) sequence of orders on each resource

## 3. Action sentences
Numbered. One sentence each. Form: "The schedule <verb> <what> <because/so that>."
Each ends with a citation. Examples:
1. The schedule starts no step of an order before the order's release hour. [scr: orders.release]
2. The schedule runs step 2 of an order only after its step 1 has finished. [scr: steps]
3. The schedule never has two orders occupying the fermenter at once. [scr: resources.capacity]
4. The schedule minimizes the sum over orders of max(0, finish − due). [scr: objective (canonical)]

## 4. Decisions on "other constraints"
| SCR text (verbatim) | Decision | Rationale |
|---|---|---|
| "..." | covered / added as sentence N / out of scope | ... |

## 5. Deliberately unused SCR fields
- <field>: <why>

## 6. Open questions for the expert (if any)
- ...
```

## §3 notes on action sentences

They are the specification. Stage 3 must be able to point at a line of
MiniZinc for each one, and the human should be able to read them without
knowing MiniZinc. Write them so that a false one would be obvious to the
expert ("the schedule never fills the fermenter with two batches" is
checkable; "capacity constraints hold" is not).
