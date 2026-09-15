# Standard formulations (Layer 3)

Load only the section named by the SCR's `schema:` line (ICM Pattern 4).

## flow-shop

Permutation is **not** assumed; orders may pass each other between
resources unless an "other constraint" forbids it.

- Index sets: `ORDER`, `STEP` (1..m, same for every order), `RESOURCE`
  (step k runs on resource `res[k]`).
- Parameters: `dur[o,k]` from the durations table via each order's
  product; `release[o]`, `due[o]`; `setup[r]` per resource (0 if none).
- Decisions: `start[o,k]`.
- Constraints:
  - release: `start[o,1] >= release[o]`
  - precedence: `start[o,k+1] >= start[o,k] + dur[o,k]`
  - resource capacity: for each resource, the steps assigned to it do
    not overlap beyond capacity (`cumulative` with unit demand, or
    `disjunctive` when capacity = 1)
  - setup (if any): treat as added to duration when capacity = 1 and
    setup is product-independent; otherwise mark as an open question
- Objectives (canonical):
  - makespan: `max(start[o,m] + dur[o,m])`
  - total tardiness: `sum(max(0, start[o,m] + dur[o,m] - due[o]))`
  - max tardiness: `max(...)` of the same term
  - number late: `sum(bool2int(start[o,m] + dur[o,m] > due[o]))`

## job-shop

- Index sets: `ORDER`, per-order routing of variable length; flatten to
  `TASK` with `task_order[t]`, `task_res[t]`, `task_dur[t]`, and
  `next[t]` (0 if last).
- Decisions: `start[t]`.
- Constraints: release on first task of each order; precedence along
  `next`; `disjunctive` per resource over its tasks; setup as in
  flow-shop.
- Objectives: as flow-shop, using each order's last task.

## Both

- Horizon: `H = max(due) + sum(all durations)`; all starts in `0..H`.
- Do not add symmetry breaking or search annotations in the first
  version; correctness first.
