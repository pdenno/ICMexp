# Discovery schema: flow shop (Layer 3)

Use when every product visits the resources in the same order.
Copy this template into `output/scr.md` and fill it. Keep the headings.
`unknown` is a legal value everywhere. Record the expert's own word for
each thing in parentheses after the canonical name.

```
schema: flow-shop

## products
- <canonical name> (<expert's word>)
- ...

## steps (in the order every product visits them)
1. <step name> on <resource>
2. ...

## resources
- <resource name> (<expert's word>) — capacity: <how many orders at once, usually 1>
- ...

## durations (hours; one row per product × step)
| product | step 1 | step 2 | ... |
|---|---|---|---|
| <product> | <h> | <h> | |

## setup / changeover
- between products on <resource>: <hours> | none | unknown
- ...

## orders (current week)
| order | product | quantity | release (h) | due (h) |
|---|---|---|---|---|
| <id> | <product> | <qty> | 0 | <h> |

## objective (expert's words)
"<verbatim>"

## objective (canonical) — pick one
- minimize makespan
- minimize total tardiness
- minimize maximum tardiness
- minimize number of late orders

## other constraints (verbatim, unmodeled)
- "<what the expert said>"
- ...

## unknowns and open questions
- <field>: <why unknown / what would resolve it>
```

## Questions to ask, per section

- **products / steps / resources**: covered by the opening questions;
  confirm the resource list explicitly ("So the things that can be busy
  are: A, B, C. Anything else?").
- **durations**: "For <product>, how long is it in <resource>?" for each
  cell. If the expert gives a range, record the range.
- **setup**: "When <resource> switches from one product to another, is
  there time lost? How much?"
- **orders**: "What do you have to get out this week? For each: which
  product, how much, and when is it promised?"
- **objective**: "When a week goes badly, what went wrong?" then "So if
  you could only fix one thing about the schedule, what would it be?"
