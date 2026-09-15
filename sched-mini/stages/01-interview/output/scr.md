schema: flow-shop

## products
- R600a-LBP (expert: "R600a LBP")
- R600a-MBP (expert: "R600a MBP")
- R134a-legacy (expert: "R134a legacy")

Note: the expert first described three HP families (1/8, 1/6, 1/4 HP). When asked
whether the schedule should sequence around refrigerant, they replaced that
breakdown with these three, "how we actually batch on the floor — the family sets
the fixtures and test recipe, and refrigerant is the big split inside it."

## steps (in the order every product visits them)
1. build on assembly-line — kitting, sub-assembly, shell stack, fit into lower shell
2. braze on braze-cell — shell closing plus suction/discharge stub brazing
3. vac-oil-fill on vac-oil-station — evacuation and oil charge
4. run-test on run-test-stands — run/performance test plus final QC

Two operations the expert described are **not** steps in this schema but carry time
(see `other constraints`): machining/kitting runs upstream off the line, and leak
test sits between braze and vac-oil-fill as a 6 h lag with no resource attached.
Packing is a 3.5 h lag after run-test, before the lot counts as delivered.

## resources
- assembly-line (expert: "main assembly", "the line") — capacity: 1
- braze-cell (expert: "the braze cell") — capacity: 1
- vac-oil-station (expert: "vacuum/oil charge station") — capacity: 1
- run-test-stands (expert: "run-test stands") — capacity: 2

Each area has its own crew ("different crew; it is a flow line"), so labor is not a
separate resource and the four resources can run concurrently.

## durations (hours; one row per product × step)
Values are for a 300-unit lot and scale linearly with quantity ("almost everything
I gave you is per-unit pace"). A 200-unit lot is ~2/3 of these. Changeover time
does not scale — it is fixed per changeover.

| product | build | braze | vac-oil-fill | run-test |
|---|---|---|---|---|
| R600a-LBP | 9–12 | 6–8 | 8 (range 6–10) | 10–14 |
| R600a-MBP | 9–12 | 6–8 | 8 (range 6–10) | 10–14 |
| R134a-legacy | 9–12 | 6–8 | 8 (range 6–10) | 12–16 |

Ranges are as given; the expert supplied a single number only for vac-oil-fill
("call it 8"). Choosing point values for the others is left to stage 2 — see
`unknowns and open questions`.

## setup / changeover
Sequence-dependent. The cheap case is a changeover between the two R600a products;
the expensive case is any changeover that crosses the refrigerant boundary
(R600a-LBP or R600a-MBP ↔ R134a-legacy). No changeover cost when the same product
runs back-to-back.

| resource | within R600a | R600a ↔ R134a |
|---|---|---|
| assembly-line | 0 (observed ~10 min, expert: "call it zero if you like") | 0.5 (range 0.5–0.75) |
| braze-cell | 0.25 (range 0.17–0.25) | 0.75 (range 0.5–1.0) |
| vac-oil-station | 0 (same oil) | 0.5 (range 0.5–0.75) — flush and oil swap |
| run-test-stands | 0.25 (range 0.25–0.33) | 1.0 (range 0.75–1.5) — adapters, test recipe, QA verification run |

The single numbers in the table are the expert's own consolidation: "build 0 / 0.5 h,
braze 0.25 / 0.75 h, vac/oil 0 / 0.5 h, run test 0.25 / 1.0 h."

## orders (current week)
Release and due are wall-clock hours from Monday 00:00. Due = "off pack and on the
dock" — trucks leave at 16:00 — so the lot must clear run-test 3.5 h earlier and on
the same working day.

| order | product | quantity | release (h) | due (h) |
|---|---|---|---|---|
| L1 | R600a-LBP | 300 | 0 | 64 |
| L2 | R600a-MBP | 300 | 0 | 88 |
| L3 | R134a-legacy | 300 | 0 | 88 |
| L4 | R600a-LBP | 300 | 0 | 112 |
| L5 | R134a-legacy | 300 | 30 | 112 |
| L6 | R600a-MBP | 200 | 0 | 184 |

Priorities (no schema field; recorded here and under other constraints):
L3 is escalated ("the hot one — sales already escalated it"); L6 is filler
("lowest priority"); L1, L2, L4, L5 are normal. L5's release is late because
"parts don't land until Tuesday morning."

## objective (expert's words)
"What a good week looks like, in order: nobody misses a promise. If something has to
miss, it's the lot with the latest promise or the filler, not the escalated one —
and it misses by hours, not a day. Then, after that, batch the same families
back-to-back so we're not paying changeovers we didn't need. I'd rather pay one
extra changeover than miss a promise, every time."

"So the one thing I'd fix: at run test, who goes next should be decided by ship
date, not by who got there first. Same at braze, but run test is where it's won or
lost."

## objective (canonical) — pick one
- **minimize total tardiness** ← selected

Two qualifications the canonical list cannot express, carried forward for stage 2:
1. The expert wants it **weighted by priority** — L3 (escalated) heaviest, L6
   (filler) lightest, others equal. "Number of late orders" was rejected as the
   mapping because it is indifferent between missing by an hour and missing by a
   day, and the expert cares about that difference explicitly.
2. Changeover count is a **secondary** objective, strictly subordinate: "I'd rather
   pay one extra changeover than miss a promise, every time."

## other constraints (verbatim, unmodeled)
- Machining, upstream: "Machining alone is 16–20 hours per lot, but it's not the
  assembly line's time; if you fold it in you'll make the line look twice as slow as
  it is. Treat it as 'parts must be ready before build starts' if you need it at all."
- Leak test, as a lag: "put it in as a fixed delay between braze finishing and
  vac/fill starting, say 6 hours, no station attached. Then the dates come out right
  and nothing queues where it shouldn't." Leak test itself is 5–7 h per lot on
  2 benches; deliberately not a station — "Folding it into vac/fill would invent a
  14-hour single-station choke point we don't have."
- Packing, as a lag: "Three to four hours from run test signing off to a palletized
  lot on the dock … Call it 3.5. So if a promise is 16:00, run test really needs to
  be done by about 12:30 that day, and it has to be the same day since pack doesn't
  run off-shift either."
- Shift calendar: "We run two shifts, 06:00 to 22:00, Monday through Friday. From
  22:00 to 06:00 and all weekend nothing moves … So the week is 80 working hours,
  not 120, and my promise times were wall-clock."
- Interruption at build, braze, vac-oil-fill: "A lot doesn't have to finish at a
  station in one shift — build or braze can stop at 22:00 and pick up at 06:00 — so
  for those, just don't count the dead hours." And for vac-oil-fill: "at the lot
  level treat it like build and braze — stop at 22:00, resume at 06:00."
- No-span rule at run test: "we don't start a run-test batch we can't finish by
  22:00. If you can only do one calendar rule, make it 'run test doesn't span the
  night gap.'"
- Second-shift staffing, explicitly deferred: "second shift usually only staffs one
  of the two run-test stands. Fine to ignore for the first pass."
- Overtime: "unless we've explicitly scheduled overtime, which is a separate
  decision — for the baseline plan treat off-shift as unavailable."
- Retest risk (stochastic, out of scope): "a retest can tie a stand up for 90+
  minutes and everything behind it waits."
- Batching preference the expert expects to see honored: "lots 1 and 4 are the same
  family, and 3 and 5 are both R134a — we'd normally try to run those pairs
  back-to-back on run test."
- Sequencing rule the expert wants the model to embody: "at run test, who goes next
  should be decided by ship date, not by who got there first."
- Lot sizing rationale (why an order is a lot, not a customer PO): "We release in
  lots of 200–400 compressors of one model, call it 300 as the standard … We don't
  release a whole order as one unit because it would sit at the bottlenecks for days."
- WIP, mentioned in the opening answer but never quantified: "a 'good' schedule is
  one that minimizes changeovers and WIP while still shipping the right mix on time."

## unknowns and open questions
- durations (build, braze, run-test): the expert gave ranges, not point values
  (build 9–12, braze 6–8, run-test 10–14 / 12–16). Only vac-oil-fill was pinned
  ("call it 8"). Stage 2 must choose a convention — midpoint, pessimistic, or
  per-product — and say which. Resolved by the expert naming a planning number.
- machining lead time: unknown how far ahead machining must run to guarantee parts
  at build. The 16–20 h per lot figure is given, but not the buffer policy, and no
  release time except L5's was traced to parts availability. Resolved by asking what
  the parts buffer normally holds.
- objective weights: unknown numeric weights for escalated / normal / filler. The
  ordering is clear; the ratios are not. Resolved by asking how many hours late a
  filler lot is "worth" one hour late on the escalated lot.
- WIP: named as something a good schedule minimizes, never defined or measured. No
  target, no unit. Resolved by asking what WIP level is normal and what is too much.
- retest probability and duration distribution: unknown, and out of scope for this
  workspace (no stochastic elements). Noted because the expert identifies it as the
  proximate cause of bad weeks.
- second-shift run-test capacity: known behavior (1 stand rather than 2), deliberately
  deferred by the expert for this pass rather than genuinely unknown.
