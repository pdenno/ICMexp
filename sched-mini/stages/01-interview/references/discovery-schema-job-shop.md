# Discovery schema: job shop (Layer 3)

Use when products visit resources in product-specific orders (or skip
some). Copy this template into `output/scr.md` and fill it. Keep the
headings. `unknown` is a legal value everywhere.

```
schema: job-shop

## products
- <canonical name> (<expert's word>)
- ...

## resources
- <resource name> (<expert's word>) — capacity: <orders at once, usually 1>
- ...

## routings (one per product; steps in order, each on one resource)
### <product>
1. <step name> on <resource> — <hours>
2. ...

### <product>
...

## setup / changeover
- on <resource>, between products: <hours> | none | unknown

## orders (current week)
| order | product | quantity | release (h) | due (h) |
|---|---|---|---|---|

## objective (expert's words)
"<verbatim>"

## objective (canonical) — pick one
- minimize makespan
- minimize total tardiness
- minimize maximum tardiness
- minimize number of late orders

## other constraints (verbatim, unmodeled)
- ...

## unknowns and open questions
- ...
```

## Questions to ask, per section

- **routings**: "Take <product>. Where does it go first? How long there?
  Then where?" — complete one product before starting the next.
- **resources**: after all routings, list every resource you heard and
  confirm: "Did I miss any machine or station?"
- **setup**, **orders**, **objective**: same questions as the flow-shop
  schema (see `discovery-schema-flow-shop.md` — do not duplicate here;
  ICM Pattern 5, canonical sources).
