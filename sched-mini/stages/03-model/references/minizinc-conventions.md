# MiniZinc conventions (Layer 3)

- `include "globals.mzn";` at the top; use `cumulative` / `disjunctive`
  rather than hand-written pairwise no-overlap.
- All problem data in `data.dzn`; `model.mzn` declares parameters only.
- Identifiers: canonical glossary names in snake_case (`order`, `step`,
  `resource`, `dur`, `release`, `due`, `setup`). Enumerate with `enum`
  where the expert named things (`enum PRODUCT = {Pale, Stout, IPA};`)
  so output is readable to them.
- One `% AS-<n>: ...` comment immediately before the constraint(s) that
  implement action sentence n. Nothing else implements a sentence.
- Objective in a single `solve minimize <expr>;` line; name the
  expression with a `var int: <objective_name> = ...;` declaration so
  the output shows it.
- `output` block: one line per order — order id, product, start of
  first step, finish of last step, due, lateness — so the expert can
  read it without knowing MiniZinc.
- No search annotations, no symmetry breaking, in the first version.
- Target: `minizinc --solver gecode model.mzn data.dzn`. Should solve a
  6-order instance in seconds; if it does not, say so rather than
  tuning.
