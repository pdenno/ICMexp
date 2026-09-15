# Modeling specification
schema: flow-shop                          [scr: schema]

## 0. Two conventions this spec fixes

The SCR left two things for this stage to decide. Both are recorded here and
flagged in §6.

**Time unit: quarter-hours (15 min), integer.** `_config/domain.md` says hours,
but the SCR carries 15-minute changeovers (braze and run-test within R600a,
0.25 h) and a 3.5 h packing lag. Integer hours would either erase the cheap
changeover — the exact thing the expert wants the schedule to batch around —
or inflate it fourfold. All figures below are shown in hours for reading and
in quarter-hours (`qh`) for the model.

**Time axis: working hours, not wall-clock.** The plant runs 06:00–22:00
Mon–Fri and nothing moves off-shift [scr: other constraints (shift calendar)].
Because build, braze and vac/fill simply pause across the night gap, a timeline
that contains only working hours represents them exactly: 16 working hours per
day, day *d* occupying working hours `16d .. 16d+15`. Wall-clock hours convert
in, results convert back out. The one rule the gap-free axis cannot express for
free — run test must not span the gap — becomes an explicit day-containment
constraint (sentence 11).

Conversion, wall-clock hour `t` on calendar day `D = t div 24`:
`working_hour = 16 · workday_index(D) + min(max(t − 24D − 6, 0), 16)`,
where `workday_index` counts Mon–Fri only (Mon=0 … Fri=4, next Mon=5).
Check against the expert: Wed 16:00 = wall 64 → working 42, which is what they
said ("only 42 working hours in") [scr: orders].

## 1. Sets and parameters

- **Products**: `R600a-LBP`, `R600a-MBP`, `R134a-legacy`.        [scr: products]
  Refrigerant class matters for setup: `R600a-LBP` and `R600a-MBP` are class
  R600a; `R134a-legacy` is class R134a.                 [scr: setup / changeover]

- **Resources (with capacity)**:                                [scr: resources]

  | resource | capacity | no-overlap form |
  |---|---|---|
  | `assembly-line` | 1 | disjunctive |
  | `braze-cell` | 1 | disjunctive |
  | `vac-oil-station` | 1 | disjunctive |
  | `run-test-stands` | 2 | 2 identical machines, order→stand assignment |

- **Steps**, same order for every product, `res[k]` as shown:       [scr: steps]

  | k | step | resource |
  |---|---|---|
  | 1 | `build` | `assembly-line` |
  | 2 | `braze` | `braze-cell` |
  | 3 | `vac-oil-fill` | `vac-oil-station` |
  | 4 | `run-test` | `run-test-stands` |

  Between step 2 and step 3 there is a **6 h lag with no resource attached**
  (leak test)          [scr: other constraints (leak test, as a lag)].
  After step 4 there is a **3.5 h lag with no resource attached** (packing)
  before the order counts as delivered
                       [scr: other constraints (packing, as a lag)].

- **Durations table.** The SCR gives ranges for three of the four steps and a
  point value only for vac/oil fill. Convention adopted: **midpoint of the
  range, then scaled by `qty/300`, then rounded up to the nearest quarter-hour**
  (rounding up rather than to nearest, so the plan is never optimistic).
  [scr: durations]

  Per-300 basis: build 10.5 (from 9–12), braze 7 (from 6–8), vac/oil 8 (given),
  run-test 12 for the R600a products (from 10–14) and 14 for `R134a-legacy`
  (from 12–16).

  | order | product | qty | build | braze | vac/oil | run-test |
  |---|---|---|---|---|---|---|
  | L1 | R600a-LBP | 300 | 10.5 (42 qh) | 7 (28) | 8 (32) | 12 (48) |
  | L2 | R600a-MBP | 300 | 10.5 (42) | 7 (28) | 8 (32) | 12 (48) |
  | L3 | R134a-legacy | 300 | 10.5 (42) | 7 (28) | 8 (32) | 14 (56) |
  | L4 | R600a-LBP | 300 | 10.5 (42) | 7 (28) | 8 (32) | 12 (48) |
  | L5 | R134a-legacy | 300 | 10.5 (42) | 7 (28) | 8 (32) | 14 (56) |
  | L6 | R600a-MBP | 200 | 7 (28) | 4.75 (19) | 5.5 (22) | 8 (32) |

  L6 is the only scaled row: 2/3 of the per-300 figures, rounded up to a
  quarter-hour. Durations do **not** include setup; setup is separate and does
  not scale with quantity [scr: durations; setup / changeover].

- **Setup times.** Sequence-dependent, between consecutive orders on the same
  resource, keyed on the refrigerant class of the two products (0 when the same
  product runs back-to-back).                          [scr: setup / changeover]

  | resource | same product | R600a → R600a (different) | R600a ↔ R134a |
  |---|---|---|---|
  | `assembly-line` | 0 | 0 | 0.5 (2 qh) |
  | `braze-cell` | 0 | 0.25 (1) | 0.75 (3) |
  | `vac-oil-station` | 0 | 0 | 0.5 (2) |
  | `run-test-stands` | 0 | 0.25 (1) | 1.0 (4) |

  This is **not** the standard flow-shop treatment. `modeling-choices.md`
  §flow-shop says to fold setup into duration when capacity is 1 and setup is
  product-independent, and otherwise to raise it as an open question. Here setup
  is product-dependent, so folding it in is unavailable, and dropping it would
  remove the only mechanism by which the schedule can express the expert's
  second priority. It is therefore modeled explicitly; see §6, question 1.

- **Orders**, converted to the working-hour axis.                  [scr: orders]

  | order | product | qty | release wall | release (wh) | due wall | due (wh) | run-test must finish by (wh) |
  |---|---|---|---|---|---|---|---|
  | L1 | R600a-LBP | 300 | 0 | 0 (0 qh) | Wed 16:00 / 64 | 42 (168) | 38.5 (154) |
  | L2 | R600a-MBP | 300 | 0 | 0 (0) | Thu 16:00 / 88 | 58 (232) | 54.5 (218) |
  | L3 | R134a-legacy | 300 | 0 | 0 (0) | Thu 16:00 / 88 | 58 (232) | 54.5 (218) |
  | L4 | R600a-LBP | 300 | 0 | 0 (0) | Fri 16:00 / 112 | 74 (296) | 70.5 (282) |
  | L5 | R134a-legacy | 300 | Tue 06:00 / 30 | 16 (64) | Fri 16:00 / 112 | 74 (296) | 70.5 (282) |
  | L6 | R600a-MBP | 200 | 0 | 0 (0) | next Mon 16:00 / 184 | 90 (360) | 86.5 (346) |

  The last column is `due − 3.5 h` (the packing lag) and is shown only to make
  the constraint legible; the model computes it. The expert's own arithmetic
  agrees: a 16:00 promise means run test done by about 12:30 that day. Because
  3.5 h is less than the 10 working hours that elapse between 06:00 and 16:00,
  subtracting it never crosses into the previous working day, so the expert's
  "it has to be the same day" holds automatically and needs no extra constraint
  [scr: other constraints (packing, as a lag)].

  Order priorities, for the objective weights: L3 escalated, L6 filler, the rest
  normal [scr: orders (priorities note)].

- **Horizon (hours)**: `H = max(due) + sum(all durations)` = 90 + 216.75 =
  306.75 working hours → **320 working hours (1280 qh)**. All starts lie in
  `0..H`.                                        [derived, per spec-template §1]

## 2. Decisions

- `start[o,k]` — start time, in quarter-hours on the working-hour axis, of each
  (order, step) pair. 24 variables.
- `stand[o] ∈ {1,2}` — which run-test stand order `o` occupies. Required because
  run-test capacity is 2 **and** its setup is sequence-dependent: a changeover is
  paid between consecutive orders *on the same stand*, which a plain `cumulative`
  cannot see [scr: resources; setup / changeover].
- `before[o1,o2,r]` — boolean, which of two orders precedes the other on
  resource `r`. Needed to charge the correct direction of a sequence-dependent
  setup. This is an addition to `modeling-choices.md` §flow-shop, which lists
  only `start[o,k]`; it is the minimum needed to carry setup.

Permutation is not assumed — orders may pass each other between resources, per
`modeling-choices.md` §flow-shop, and nothing in the SCR forbids it.

## 3. Action sentences

1. The schedule starts no step of an order before that order's release hour, so
   that nothing is scheduled before its parts and material are on site.
   [scr: orders.release]
2. The schedule starts an order's braze only after that order's build has
   finished. [scr: steps]
3. The schedule starts an order's vacuum/oil fill at least 6 hours after that
   order's braze has finished, leaving room for the leak test that occupies no
   station in this model. [scr: other constraints (leak test, as a lag)]
4. The schedule starts an order's run test only after that order's vacuum/oil
   fill has finished. [scr: steps]
5. The schedule never has two orders on the main assembly line at the same time.
   [scr: resources.capacity]
6. The schedule never has two orders in the braze cell at the same time.
   [scr: resources.capacity]
7. The schedule never has two orders on the vacuum/oil charge station at the same
   time. [scr: resources.capacity]
8. The schedule puts each order on exactly one of the two run-test stands, and
   never has two orders on the same stand at the same time — so at most two
   orders are in run test at once. [scr: resources.capacity]
9. The schedule leaves the changeover gap between two orders that run
   back-to-back on the same resource (and, at run test, on the same stand): 
   nothing between two lots of the same product, the within-R600a gap between the
   two R600a products, and the larger R600a↔R134a gap whenever the refrigerant
   changes. [scr: setup / changeover]
10. The schedule measures every duration in working hours only, so a lot that is
    part-built at 22:00 resumes at 06:00 having consumed no time overnight; this
    applies to build, braze and vacuum/oil fill.
    [scr: other constraints (interruption at build, braze, vac-oil-fill)]
11. The schedule finishes an order's run test, including its changeover, on the
    same working day it starts it — it never starts a run-test batch that cannot
    be finished by 22:00. [scr: other constraints (no-span rule at run test)]
12. The schedule treats an order as delivered 3.5 hours after its run test
    finishes, that being the packing, palletizing and staging time before the lot
    is on the dock. [scr: other constraints (packing, as a lag)]
13. The schedule minimizes the sum over orders of how many hours each order is
    delivered after its promised hour, counting zero for orders delivered on
    time. [scr: objective (canonical) — minimize total tardiness]
14. The schedule counts each order's lateness according to its priority weight,
    so that an hour late on the escalated lot costs more than an hour late on the
    filler; with all weights equal to 1 this is exactly the total tardiness of
    sentence 13. [scr: orders (priorities note); objective (canonical),
    qualification 1]
15. Among schedules that tie on weighted lateness, the schedule minimizes total
    changeover time, so that same-refrigerant lots are run back-to-back — but it
    never accepts even one extra hour of lateness to save a changeover.
    [scr: objective (expert's words); objective (canonical), qualification 2]

## 4. Decisions on "other constraints"

| SCR text (verbatim) | Decision | Rationale |
|---|---|---|
| "Machining alone is 16–20 hours per lot, but it's not the assembly line's time … Treat it as 'parts must be ready before build starts' if you need it at all." | covered | The release hours already encode parts availability — L5's release of Tue 06:00 is exactly this constraint for the one order where it binds. Machining is not a resource in this model, and its 16–20 h does not appear anywhere. See §6 question 5. |
| "put it in as a fixed delay between braze finishing and vac/fill starting, say 6 hours, no station attached" | added as sentence 3 | Modeled as a minimum time lag on the braze→vac precedence. No resource is consumed, which is what the expert asked for. |
| "Three to four hours from run test signing off to a palletized lot on the dock … Call it 3.5." | added as sentence 12 | Modeled as a lag between run-test finish and the delivery time that tardiness is measured against. The "same day" rider needs no separate constraint (see §1, orders). |
| "We run two shifts, 06:00 to 22:00, Monday through Friday. From 22:00 to 06:00 and all weekend nothing moves" | added as the time axis (§0) and sentence 10 | Represented by working only in working hours rather than by an availability calendar; wall-clock dates convert in and out. |
| "build or braze can stop at 22:00 and pick up at 06:00 — so for those, just don't count the dead hours" (and the same for vac/oil fill) | covered by sentence 10 | This is precisely what the working-hour axis does. Note it is *calendar* interruption, not preemption by another lot, so it does not violate the no-preemption scope limit in `_config/domain.md`. |
| "we don't start a run-test batch we can't finish by 22:00 … make it 'run test doesn't span the night gap.'" | added as sentence 11 | The one rule the gap-free axis cannot give for free, and the one the expert said to keep if only one survives. |
| "second shift usually only staffs one of the two run-test stands. Fine to ignore for the first pass." | out of scope | Explicitly deferred by the expert. Run test is modeled at capacity 2 throughout. Recorded in §6 question 6 as the first thing to add if the plan looks optimistic. |
| "unless we've explicitly scheduled overtime, which is a separate decision — for the baseline plan treat off-shift as unavailable" | out of scope | The expert scoped overtime out of the baseline. The model produces the no-overtime plan. |
| "a retest can tie a stand up for 90+ minutes and everything behind it waits" | out of scope | Stochastic; `_config/domain.md` excludes stochastic elements. It is the expert's stated cause of bad weeks, so §6 question 7 records what a deterministic proxy would cost. |
| "lots 1 and 4 are the same family, and 3 and 5 are both R134a — we'd normally try to run those pairs back-to-back on run test" | covered by sentence 15 | Modeled as a preference the changeover tie-break produces, not as a hard pairing. Forcing the pairs would override the expert's own ranking, in which a promise beats a changeover. |
| "at run test, who goes next should be decided by ship date, not by who got there first" | covered by sentences 13–14 | This is a dispatch rule describing the outcome the expert wants, not an extra constraint. An optimizing model has no arrival-order bias to correct; minimizing weighted tardiness *is* deciding by ship date. |
| "We release in lots of 200–400 compressors of one model, call it 300 as the standard … it would sit at the bottlenecks for days" | out of scope | Rationale for why an order is a lot rather than a customer PO. Lot sizing is an input to this model, not a decision it makes. |
| "a 'good' schedule is one that minimizes changeovers and WIP while still shipping the right mix on time" | changeovers covered by sentence 15; WIP out of scope | WIP is never defined, measured or targeted anywhere in the SCR, and the SCR itself flags this. §6 question 4. |

## 5. Deliberately unused SCR fields

- **Range endpoints of the durations** (build 9–12, braze 6–8, run-test 10–14 /
  12–16): only the derived midpoints are used. The endpoints are kept in the SCR
  as the audit trail for §6 question 2.
- **Range columns of the setup table** (e.g. braze 0.17–0.25): only the expert's
  own consolidated single numbers are used, as those are what they offered as the
  planning figures.
- **The three HP families** (1/8, 1/6, 1/4 HP) named in the products note: the
  expert replaced this breakdown with the three refrigerant-class products. The
  HP dimension does not appear in the model.
- **Expert vocabulary annotations** on products and resources: naming only,
  carried for the human's benefit, with no modeling consequence.
- **Leak-test station figures** (5–7 h per lot, 2 benches): only the 6 h lag is
  used. The bench count is unused because leak test is not a resource.
- **Machining duration** (16–20 h per lot): unused — see §4, row 1.
- **Reason for L5's release** ("parts don't land until Tuesday morning"): the
  release hour is used, the reason is not.

## 6. Open questions for the expert

1. **Sequence-dependent setup departs from the standard formulation.**
   `modeling-choices.md` §flow-shop says setup that is not product-independent
   should be raised as an open question rather than modeled. It is modeled here,
   because the expert's second-ranked goal is exactly "don't pay changeovers you
   didn't need," and a model blind to which product ran last cannot express it.
   The cost is three extra decision variables per resource pair and a larger
   search. If the human prefers the reference's conservative route, sentences 9
   and 15 come out and the model reduces to the textbook flow shop.

2. **Duration point values.** Midpoint-then-round-up is this stage's choice, not
   the expert's. Build 10.5, braze 7, run-test 12 / 14. The expert should confirm,
   or give planning numbers. If they are systematically optimistic, every promise
   in the output is optimistic by the same margin.

3. **Objective weights.** The ordering is known (escalated > normal > filler),
   the ratios are not. The model parameterizes `weight[o]` in `data.dzn` with a
   default of 1 for every order, which reproduces the canonical total tardiness
   exactly. Until the expert answers, the run is unweighted and the priority
   ranking is not actually being honored. Question to ask: how many hours late on
   the filler lot would you trade for one hour late on the escalated lot?

4. **WIP is undefined.** Named in the expert's opening statement as something a
   good schedule minimizes, never quantified. Not modeled. If it matters, it
   needs a definition (lots between build start and dock? units on the floor?)
   and a target.

5. **Machining buffer policy.** Parts availability is represented only by release
   hours, and only L5 has a release later than 0. If the 16–20 h machining time
   per lot means other lots also cannot start at hour 0, the release column is
   wrong and the plan will be infeasible in practice.

6. **Second-shift run-test capacity.** Modeled as 2 stands for all 80 hours; the
   expert says second shift usually staffs 1. This makes the plan optimistic
   precisely at the resource they call the bottleneck. Deferred at their request,
   but it is the first refinement to make.

7. **Tardiness is measured in working hours.** An order delivered "16 hours late"
   on this axis is one working day late — Wednesday's truck missed, Thursday's
   caught — which in wall-clock is 24 hours. The ranking of schedules is
   unaffected, but the reported lateness figures must be read as working hours,
   and stage 3's output should print both.

8. **Retest time.** Excluded as stochastic. If the expert wants protection rather
   than a nominal plan, the cheapest deterministic proxy is padding the run-test
   duration, which costs throughput on every lot to buy slack for the few that
   need it. Their call, not this stage's.
