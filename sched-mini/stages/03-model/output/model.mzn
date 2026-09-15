% sched-mini — stage 03 flow-shop scheduling model
%
% Built from stages/02-specify/output/spec.md. Every constraint block below is
% headed by the action sentence it implements, verbatim.
%
% Time unit: quarter-hours (qh) on the WORKING-hour axis. The axis contains only
% working time (16 h per day, 06:00-22:00, Mon-Fri), so a lot that pauses
% overnight consumes no time while the plant is dark. Working day d occupies
% qh 64d .. 64d+63. Conversions to wall-clock happen in the output block.

include "globals.mzn";

% --------------------------------------------------------------------- sets
enum PRODUCT;
enum ORDER;
enum RESOURCE;
enum STEP;

% --------------------------------------------------------------- parameters
array[STEP] of RESOURCE: res;              % which resource each step runs on
array[RESOURCE] of int: cap;               % orders at once

STEP: build_step;
STEP: braze_step;
STEP: vac_step;
STEP: test_step;

array[ORDER] of PRODUCT: prod;
array[ORDER] of int: qty;
int: lot_base;                             % quantity the duration table is for
array[PRODUCT, STEP] of int: dur_per_lot;  % qh for a lot of lot_base units

array[ORDER] of int: release;              % qh, working axis
array[ORDER] of int: due;                  % qh, working axis
array[ORDER] of int: weight;               % priority weight for tardiness

array[RESOURCE, PRODUCT, PRODUCT] of int: setup;   % qh, from-product to-product

int: leak_lag;                             % braze finish -> vac start, no resource
int: pack_lag;                             % run-test finish -> on the dock
int: day_len;                              % qh in one working day
int: horizon;                              % qh

array[int] of string: day_name;

% Durations scale with quantity and round up (spec §1: midpoint per lot_base,
% scaled by qty/lot_base, rounded up to the quarter-hour). Setup does not scale.
array[ORDER, STEP] of int: dur =
  array2d(ORDER, STEP,
    [ (dur_per_lot[prod[o], k] * qty[o] + lot_base - 1) div lot_base
    | o in ORDER, k in STEP ]);

int: test_cap = cap[res[test_step]];
set of int: STAND = 1..test_cap;

% Upper bound on total changeover time, used to make the changeover term in the
% objective a strict tie-break that can never outweigh one qh of lateness.
int: max_total_setup =
  card(ORDER) * sum(k in STEP)(max([setup[res[k], p1, p2] | p1, p2 in PRODUCT]));
int: setup_scale = max_total_setup + 1;

% ---------------------------------------------------------------- decisions
array[ORDER, STEP] of var 0..horizon: start;
array[ORDER] of var STAND: stand;               % which run-test stand
array[STEP, ORDER, ORDER] of var bool: before;  % order sequence on each resource

% AS-1: The schedule starts no step of an order before that order's release hour, so that nothing is scheduled before its parts and material are on site.
constraint forall(o in ORDER, k in STEP)(
  start[o, k] >= release[o]
);

% AS-2: The schedule starts an order's braze only after that order's build has finished.
constraint forall(o in ORDER)(
  start[o, braze_step] >= start[o, build_step] + dur[o, build_step]
);

% AS-3: The schedule starts an order's vacuum/oil fill at least 6 hours after that order's braze has finished, leaving room for the leak test that occupies no station in this model.
constraint forall(o in ORDER)(
  start[o, vac_step] >= start[o, braze_step] + dur[o, braze_step] + leak_lag
);

% AS-4: The schedule starts an order's run test only after that order's vacuum/oil fill has finished.
constraint forall(o in ORDER)(
  start[o, test_step] >= start[o, vac_step] + dur[o, vac_step]
);

% AS-5: The schedule never has two orders on the main assembly line at the same time.
constraint disjunctive([start[o, build_step] | o in ORDER],
                       [dur[o, build_step]   | o in ORDER]);

% AS-6: The schedule never has two orders in the braze cell at the same time.
constraint disjunctive([start[o, braze_step] | o in ORDER],
                       [dur[o, braze_step]   | o in ORDER]);

% AS-7: The schedule never has two orders on the vacuum/oil charge station at the same time.
constraint disjunctive([start[o, vac_step] | o in ORDER],
                       [dur[o, vac_step]   | o in ORDER]);

% AS-8: The schedule puts each order on exactly one of the two run-test stands, and never has two orders on the same stand at the same time — so at most two orders are in run test at once.
constraint cumulative([start[o, test_step] | o in ORDER],
                      [dur[o, test_step]   | o in ORDER],
                      [1                   | o in ORDER], test_cap)
  /\ forall(o1, o2 in ORDER where o1 < o2)(
       stand[o1] = stand[o2] ->
         (  start[o1, test_step] + dur[o1, test_step] <= start[o2, test_step]
         \/ start[o2, test_step] + dur[o2, test_step] <= start[o1, test_step] ));

% AS-9: The schedule leaves the changeover gap between two orders that run back-to-back on the same resource (and, at run test, on the same stand): nothing between two lots of the same product, the within-R600a gap between the two R600a products, and the larger R600a<->R134a gap whenever the refrigerant changes.
constraint
  % `before` is an ordering of the orders on each resource
  forall(k in STEP, o in ORDER)(before[k, o, o] = false)
  /\ forall(k in STEP, o1, o2 in ORDER where o1 < o2)(
       before[k, o1, o2] = not before[k, o2, o1])
  % single-capacity resources: the follower waits out the changeover
  /\ forall(k in STEP, o1, o2 in ORDER where cap[res[k]] = 1 /\ o1 != o2)(
       before[k, o1, o2] ->
         start[o2, k] >= start[o1, k] + dur[o1, k] + setup[res[k], prod[o1], prod[o2]])
  % run test: a changeover is paid only between orders sharing a stand
  /\ forall(o1, o2 in ORDER where o1 != o2)(
       (stand[o1] = stand[o2] /\ before[test_step, o1, o2]) ->
         start[o2, test_step] >= start[o1, test_step] + dur[o1, test_step]
                                 + setup[res[test_step], prod[o1], prod[o2]]);

% AS-10: The schedule measures every duration in working hours only, so a lot that is part-built at 22:00 resumes at 06:00 having consumed no time overnight; this applies to build, braze and vacuum/oil fill.
% The working-hour axis carries this: no calendar gap exists on it to subtract,
% so a duration is pure working time. All that remains is to keep every step
% inside the horizon.
constraint forall(o in ORDER, k in STEP)(
  start[o, k] + dur[o, k] <= horizon
);

% AS-11: The schedule finishes an order's run test, including its changeover, on the same working day it starts it — it never starts a run-test batch that cannot be finished by 22:00.
% NARROWING, see trace.md §1: the run-test processing is contained in one working
% day. The changeover is charged as separation in AS-9 rather than as an occupied
% block, so it is not itself forced inside the day.
constraint forall(o in ORDER)(
  (start[o, test_step] mod day_len) + dur[o, test_step] <= day_len
);

% AS-12: The schedule treats an order as delivered 3.5 hours after its run test finishes, that being the packing, palletizing and staging time before the lot is on the dock.
array[ORDER] of var 0..horizon: delivery;
constraint forall(o in ORDER)(
  delivery[o] = start[o, test_step] + dur[o, test_step] + pack_lag
);

% AS-13: The schedule minimizes the sum over orders of how many hours each order is delivered after its promised hour, counting zero for orders delivered on time.
array[ORDER] of var 0..horizon: tardiness;
constraint forall(o in ORDER)(
  tardiness[o] = max(0, delivery[o] - due[o])
);
var int: total_tardiness = sum(o in ORDER)(tardiness[o]);

% AS-14: The schedule counts each order's lateness according to its priority weight, so that an hour late on the escalated lot costs more than an hour late on the filler; with all weights equal to 1 this is exactly the total tardiness of sentence 13.
var int: weighted_tardiness = sum(o in ORDER)(weight[o] * tardiness[o]);

% AS-15: Among schedules that tie on weighted lateness, the schedule minimizes total changeover time, so that same-refrigerant lots are run back-to-back — but it never accepts even one extra hour of lateness to save a changeover.
array[STEP, ORDER, ORDER] of var bool: adj;   % o2 runs immediately after o1
constraint
  forall(k in STEP, o in ORDER)(adj[k, o, o] = false)
  /\ forall(k in STEP, o1, o2 in ORDER where cap[res[k]] = 1 /\ o1 != o2)(
       adj[k, o1, o2] =
         (before[k, o1, o2]
          /\ not exists(o3 in ORDER where o3 != o1 /\ o3 != o2)(
                before[k, o1, o3] /\ before[k, o3, o2])))
  /\ forall(o1, o2 in ORDER where o1 != o2)(
       adj[test_step, o1, o2] =
         (stand[o1] = stand[o2]
          /\ before[test_step, o1, o2]
          /\ not exists(o3 in ORDER where o3 != o1 /\ o3 != o2)(
                stand[o3] = stand[o1]
                /\ before[test_step, o1, o3] /\ before[test_step, o3, o2])));
var int: total_setup =
  sum(k in STEP, o1, o2 in ORDER where o1 != o2)(
    bool2int(adj[k, o1, o2]) * setup[res[k], prod[o1], prod[o2]]);
var int: objective = weighted_tardiness * setup_scale + total_setup;

solve minimize objective;

% ------------------------------------------------------------------ output
function string: pad2(int: x) = if x < 10 then "0" ++ show(x) else show(x) endif;

function string: padr(string: s, int: n) =
  s ++ concat([" " | _ in 1..max(0, n - string_length(s))]);

% working-axis qh -> wall-clock, given the plant works 06:00-22:00 Mon-Fri
function string: wc(int: q) =
  padr(day_name[q div day_len] ++ " " ++
       pad2(6 + (q mod day_len) div 4) ++ ":" ++ pad2(((q mod day_len) mod 4) * 15), 12);

% qh -> hours, as a decimal
function string: hrs(int: q) =
  show(q div 4) ++ (if q mod 4 = 0 then "" else "." ++ show((q mod 4) * 25) endif);

output
  [ "order  product        stand  build starts  test starts   test ends     on the dock   promised      late\n",
    "--------------------------------------------------------------------------------------------------------------\n" ]
  ++
  [ padr(show(o), 7) ++ padr(show(prod[o]), 15) ++ padr(show(fix(stand[o])), 7) ++
    wc(fix(start[o, build_step])) ++ "  " ++
    wc(fix(start[o, test_step])) ++ "  " ++
    wc(fix(start[o, test_step] + dur[o, test_step])) ++ "  " ++
    wc(fix(delivery[o])) ++ "  " ++
    wc(due[o]) ++ "  " ++
    (if fix(tardiness[o]) = 0 then "on time" else hrs(fix(tardiness[o])) ++ " h late" endif) ++
    "\n"
  | o in ORDER ]
  ++
  [ "\ntotal tardiness (working hours): " ++ hrs(fix(total_tardiness)) ++
    "\nweighted tardiness             : " ++ hrs(fix(weighted_tardiness)) ++
    "\ntotal changeover time          : " ++ hrs(fix(total_setup)) ++
    "\n\nTimes are wall-clock; the plant works 06:00-22:00 Mon-Fri and nothing moves off-shift.\n" ++
    "Lateness is in WORKING hours: 16 h late = one working day late.\n" ];
