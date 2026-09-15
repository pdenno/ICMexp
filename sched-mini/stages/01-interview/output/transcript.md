# Stage 01 — Interview transcript

Expert: plant owner / production lead, hermetic refrigerator compressor plant.
Interviewer: agent, following `references/interview-method.md`.
Turns are recorded in order. Expert answers are verbatim.

---

**Q:** What do you make, and roughly how many different products are we talking about? (If it's a lot, pick a handful that are representative of the work you do.)

**A:** We manufacture hermetic refrigerator compressors in three main families: 1/8 HP, 1/6 HP, and ¼ HP models (typical monthly volume is ~45,000–55,000 units total). Each family has several variants (different refrigerants like R600a vs R134a, different mounting and electrical specs), but they share most of the same production lines.
The scheduling challenge is that we have to plan weekly and daily sequences across shared resources—stator winding, rotor/shaft machining, assembly, welding/brazing, vacuum oil filling, end-of-line testing, and packaging—while meeting customer ship dates. Changeovers between variants (especially refrigerant-related setups and test parameter changes) can take 30–90 minutes, and the bottleneck is usually end-of-line testing and vacuum/oil fill, so a "good" schedule is one that minimizes changeovers and WIP while still shipping the right mix on time.

---

**Q:** Walk me through what happens to one order, start to finish. You listed stator winding, rotor/shaft machining, assembly, welding/brazing, vacuum oil fill, end-of-line test, and packaging — is that the actual order it happens in, or do some of those run in parallel and feed into assembly?

**A:** A typical hermetic refrigerator compressor (all our main models) follows mostly the same route in the same order. The differences by model are usually (a) which machining programs/tools we use, (b) which motor winding variant we fit, and (c) some extra tests or longer test time for higher-capacity/high-efficiency models. But the backbone sequence is the same.
Main production steps (in order) for one unit: 1) Incoming parts receiving + kitting (crankshafts, shells, stators rotors, valves, oil, fasteners). We kit per order so assembly doesn't stop. 2) Machining (where applicable): crankshaft connecting parts finishing, deburring, cleaning. Not every component is machined in-house, but most models touch the same machining area. 3) Sub-assembly: - motor sub-assembly (stator/rotor fit), - mechanical set (crankshaft + piston/connecting rod), - valve plate + gaskets. 4) Main assembly into shell (stack build, fit into lower shell). 5) Welding / shell closing (attach upper shell / cover welding, and braze suction/discharge stubs). 6) Leak test (helium pressure decay style). 7) Evacuation + oil fill (vacuum, oil charge). 8) Run test / performance test (electrical + functional; higher-end models run longer). 9) Final QC (noise/vibration check, label/traceability). 10) Packing + palletizing + finished goods staging.

---

**Q:** [Schema decision, stated for correction] So I'm treating this as a flow shop: every product visits the same resources in the same order, and models differ only in how long they take. Correct me if there's a product that genuinely skips a step or goes somewhere out of sequence.

**A:** It is basically a flow shop. Mostly the same route. We do not have completely different "routes" like some units skipping welding or skipping test.
The main variations:
Machining time and sequence can differ depending on crankshaft type; some models use a purchased finished crankshaft and bypass one machining step.
Motor winding/stator variant changes at the motor sub-assembly step, but it's still the same station family.
Testing: a premium/high-capacity model may require an extra 100% extended run test (e.g., 8–10 minutes instead of 4–5), and sometimes an additional electrical test.

---

**Q:** This workspace builds a small model — at most 5 process steps on 4 resources, at most 6 orders. Does this grouping work, or would you cut it differently? (1) Machining & kitting on the machining area, (2) Assembly on the assembly line, (3) Vacuum & oil fill with leak test rolled in, (4) Run test & final QC, (5) Packing. That's five steps but five resources, one too many; my instinct is to drop packing.

**A:** I'm not sure why you consider that one too many, but if you'd like to drop packing, I guess that's okay. Doesn't manual labor count as a resource?

---

**Q:** [Answered: the cap is a workspace size limit, not anything about the plant; and yes, a crew counts as a resource.] Is labor a separate constraint here, or is it tied to the stations? Does each of those four areas come with its own crew that's always there, or do you have a pool of operators you move around, so that running assembly and machining flat-out at the same time isn't actually possible?

**A:** There is manual work to be done at each of the steps you list.

---

**Q:** Same crew or shared crew? If assembly is busy and machining is also busy, are those different people — each area staffed independently — or are you moving the same operators between areas so the two can't both run at full rate?

**A:** No, different crew; it is a flow line.

---

**Q:** Confirming the four things that can be busy — machining area, assembly line, vacuum/oil fill, end-of-line test. Did I miss anything that can be a bottleneck? And for each of the four, can it work on more than one order at a time, or is it one order at a time?

**A:** Our real choke points are main assembly, the braze cell, and the vacuum/oil charge station — each is a single line or station, one lot at a time. Leak test and run test also back up, but that's more a staffing thing: we have 2 leak benches and 2 run-test stands, and we often only staff one run-test stand on 2nd shift. Run test is the one that hurts most day to day because a retest can tie a stand up for 90+ minutes and everything behind it waits.

---

**Q:** Revised to fit four resources, keeping your choke points. Does this work? (1) Build — kitting, machining, sub-assembly, shell stack, fit into lower shell — on the main assembly line, one lot at a time. (2) Weld/braze — shell closing plus stubs — in the braze cell, one lot at a time. (3) Vacuum & oil fill, leak test folded in ahead of it — at the vac/oil charge station, one lot at a time. (4) Run test & final QC — on the run-test stands, two lots at a time. Machining disappears into Build and leak test into vac/fill; tell me if either hides something that bites you, and whether run test should be 2 stands or 1.

**A:** Yup, that's okay.

---

**Q:** You have three families (1/8, 1/6, 1/4 HP) and variants within each. For this week's schedule, should a "product" be just the family (three products), or do the variants need to be separate products because they behave differently — especially R600a vs R134a, which you said drives the setup time?

**A:** Yes, I think that's okay for a first pass scheduling system.

---

**Q:** Which of these two? (a) Three products — 1/8, 1/6, 1/4 HP — with refrigerant as a note the schedule doesn't sequence around. (b) Products split by refrigerant, so the model can see the 30–90 minute switch and batch around it. You said the refrigerant setup is the expensive one, so (b) is what would earn its keep, but it means more products to give me durations for.

**A:** (b). But keep it to three products, not every HP-by-refrigerant combination: R600a LBP, R600a MBP, and R134a legacy. That's how we actually batch on the floor — the family sets the fixtures and test recipe, and refrigerant is the big split inside it. Step durations are basically the same for all three; run test is the exception, R134a legacy runs a bit longer. Within R600a a changeover is cheap, maybe 15 minutes on the stands; R600a to R134a is the expensive one, 45–90 minutes.

---

**Q:** What's a lot on your floor? When you release work to the line, is it a standard quantity, or does each customer order run as whatever size it happens to be?

**A:** Neither, really — it's a planning quantity. We release in lots of 200–400 compressors of one model, call it 300 as the standard. A customer order gets cut into lots that size; a 2,400-piece order is eight lots, a small order might be one short lot. We don't release a whole order as one unit because it would sit at the bottlenecks for days. Main line does about 900–1,200 units a day depending on mix, so a lot is roughly a quarter to a third of a day's output.

---

**Q:** For one 300-piece lot, how many hours does it tie up each station — Build (including the machining/kitting time you folded in), braze cell, vacuum & oil fill, run test (with the R134a legacy number separately)? Ranges are fine.

**A:** Per 300-piece lot, station time:
Build (main assembly line): 9–12 hours. Careful with the machining/kitting though — that's upstream, off the line, and runs ahead of assembly out of a parts buffer. Machining alone is 16–20 hours per lot, but it's not the assembly line's time; if you fold it in you'll make the line look twice as slow as it is. Treat it as "parts must be ready before build starts" if you need it at all.
Braze cell: 6–8 hours.
Vacuum & oil fill: 6–10 hours, depends on how many stations are up and pump health; call it 8.
Run test: 10–14 hours for the R600a families. R134a legacy has the longer test recipe, more like 12–16.
If you want leak test too since we said it backs up: 5–7 hours per lot.

---

**Q:** What do I do with leak test? (a) Fold it into vac/fill — that station becomes ~14 h per lot at one lot at a time, which overstates it, since leak test has 2 benches in parallel. (b) Leave it out of the model and record the 5–7 h verbatim as a known omission, so the schedule runs ~6 h optimistic on every lot. My lean is (b).

**A:** (b), leave it out as a station — with two benches it's almost never the thing that truly stalls us; when it backs up it's because we only staffed one, and that's a staffing call, not a capacity wall. Folding it into vac/fill would invent a 14-hour single-station choke point we don't have.
But don't just drop the 6 hours. If you can, put it in as a fixed delay between braze finishing and vac/fill starting, say 6 hours, no station attached. Then the dates come out right and nothing queues where it shouldn't. If the model can't do a plain delay like that, fine, record it as the known omission and I'll mentally add six hours to every finish.

---

**Q:** Which of the four stations actually lose time on a changeover, and how much at each? Build, braze cell, vac/oil fill, run test — for each, the within-R600a number and the R600a↔R134a number, or tell me it's zero there.

**A:** Build (main assembly): within R600a about 10 minutes, just kitting and paperwork — call it zero if you like. R600a↔R134a, 30–45 minutes for fixtures and re-staging racks.
Braze cell: within R600a 10–15 minutes. R600a↔R134a, 30–60 minutes — different tubes/headers and torch program, plus a first-piece check.
Vac/oil fill: within R600a zero, same oil. R600a↔R134a is the one people forget — different oil, so we flush and swap, 30–45 minutes.
Run test: within R600a 15–20 minutes for harnesses and ports. R600a↔R134a, 45–90 minutes — adapter changes, different test recipe, and QA usually wants a verification run on the new setup. That's the one that eats us.
If you need single numbers: build 0 / 0.5 h, braze 0.25 / 0.75 h, vac/oil 0 / 0.5 h, run test 0.25 / 1.0 h.

---

**Q:** What do you have to get out this week? Up to six lots. For each: which of the three products, quantity, earliest it can start, and when it's promised. Hours from Monday 00:00 = hour 0.

**A:** Six lots this week, all ~300 unless noted. Hours from Monday 00:00.
1. R600a LBP, 300, can start hour 0, promised Wednesday 16:00 (hour 64). Regular customer, normal priority.
2. R600a MBP, 300, can start hour 0, promised Thursday 16:00 (hour 88).
3. R134a legacy, 300, can start hour 0, promised Thursday 16:00 (hour 88). This one is the hot one — sales already escalated it.
4. R600a LBP, 300, can start hour 0, promised Friday 16:00 (hour 112).
5. R134a legacy, 300, parts don't land until Tuesday morning, so earliest start Tuesday 06:00 (hour 30). Promised Friday 16:00 (hour 112).
6. R600a MBP, short lot, 200, can start hour 0, promised next Monday 16:00 (hour 184) — really it's filler to keep the line busy, lowest priority.
"Promised" means off pack and on the dock by that hour; trucks leave at 16:00. Note lots 1 and 4 are the same family, and 3 and 5 are both R134a — we'd normally try to run those pairs back-to-back on run test.

---

**Q:** Does the clock run continuously? Your hour numbers count straight through nights and weekends. Is the plant actually running around the clock Monday–Friday, or are there shifts where nothing moves?

**A:** No, the clock doesn't run straight through. We run two shifts, 06:00 to 22:00, Monday through Friday. From 22:00 to 06:00 and all weekend nothing moves unless we've explicitly scheduled overtime, which is a separate decision — for the baseline plan treat off-shift as unavailable. So the week is 80 working hours, not 120, and my promise times were wall-clock: Wednesday 16:00 is still hour 64 on the wall, but only 42 working hours in.
Two rules that matter for how you model it. A lot doesn't have to finish at a station in one shift — build or braze can stop at 22:00 and pick up at 06:00 — so for those, just don't count the dead hours. Run test is the exception: a unit that's on the stand at shift end just sits there, and QA won't sign off a batch nobody watched, so in practice we don't start a run-test batch we can't finish by 22:00. If you can only do one calendar rule, make it "run test doesn't span the night gap."
And if you want the extra realism, second shift usually only staffs one of the two run-test stands. Fine to ignore for the first pass.

---

**Q:** Three quick ones to close out durations and dates. (1) Lot 6 is 200, not 300 — do station times scale with quantity, or is there enough fixed setup that a short lot doesn't save much? (2) Can vac/oil fill pause at 22:00 and resume at 06:00 like build and braze, or must a lot on the station finish? (3) How long from run test signing off to a palletized lot on the dock?

**A:** 1. They scale. Almost everything I gave you is per-unit pace — build is a couple of minutes a unit, run test 2–3 minutes a unit — so a 200 lot is about two-thirds of the station time. The fixed part is the changeover, which is the same regardless of lot size; that's exactly why we don't like short lots on run test.
2. Vac/oil can pause. It's one unit at a time on the station; a unit mid-evacuation has to finish its cycle, but that's minutes, so at the lot level treat it like build and braze — stop at 22:00, resume at 06:00.
3. Three to four hours from run test signing off to a palletized lot on the dock — final visual, labels, foam and cartons, pallet wrap. Call it 3.5. So if a promise is 16:00, run test really needs to be done by about 12:30 that day, and it has to be the same day since pack doesn't run off-shift either.

---

**Q:** When a week goes badly here, what actually went wrong? And if you could fix exactly one thing about how the week gets sequenced, what would it be?

**A:** When a week goes badly it's almost always the same story: a few lots get released close together, they stack up at run test, then a retest ties up a stand for an extra hour or two mid-shift and the whole queue slides past 22:00. Nothing ships that day, and Thursday's promise becomes Friday's. Underneath that, the real mistake was usually sequencing — we ran whatever hit the stand first instead of what had to ship first, and by the time we noticed, the hot lot was behind a lot that wasn't due till next week.
So the one thing I'd fix: at run test, who goes next should be decided by ship date, not by who got there first. Same at braze, but run test is where it's won or lost.
What a good week looks like, in order: nobody misses a promise. If something has to miss, it's the lot with the latest promise or the filler, not the escalated one — and it misses by hours, not a day. Then, after that, batch the same families back-to-back so we're not paying changeovers we didn't need. I'd rather pay one extra changeover than miss a promise, every time.

---

**Q:** [Checkpoint — plain-language summary of the whole picture presented for correction: flow line Build → Braze → Vac/oil fill → Run test; machining upstream; leak test as a 6 h lag and packing as a 3.5 h lag; three products; four resources with capacities 1/1/1/2; per-300-lot durations; changeover matrix; two-shift calendar with run test not spanning the night gap; the six lots; and the objective recorded as weighted total tardiness with changeover batching second.] Anything wrong or missing?

**A:** I think that is about right.
