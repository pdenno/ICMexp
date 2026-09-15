#!/usr/bin/env bash
# Mechanical work that needs no AI (ICM: "local scripts handle the parts
# that do not need AI"). Runs the stage-03 model and saves the result
# beside it.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
out="$here/../stages/03-model/output"
solver="${MZN_SOLVER:-gecode}"
timeout="${MZN_TIMEOUT_MS:-30000}"

if ! command -v minizinc >/dev/null 2>&1; then
  echo "minizinc not found on PATH" >&2; exit 2
fi
for f in model.mzn data.dzn; do
  [[ -f "$out/$f" ]] || { echo "missing $out/$f — run stage 03 first" >&2; exit 2; }
done

minizinc --solver "$solver" --time-limit "$timeout" \
  "$out/model.mzn" "$out/data.dzn" | tee "$out/solution.txt"
echo "wrote $out/solution.txt"
