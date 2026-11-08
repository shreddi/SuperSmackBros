#!/usr/bin/env bash
# Records deterministic fighter traces into the output directory.
# Usage: tests/run_regression.sh <out_dir> [godot_binary]
# Record once before a refactor and once after, then: diff -r <before> <after>
set -euo pipefail
OUT=${1:?usage: run_regression.sh <out_dir> [godot]}
GODOT=${2:-godot}
mkdir -p "$OUT"
cd "$(dirname "$0")/.."
FRAMES=${FRAMES:-4000}
i=0
for pair in fox:mario mario:fox fox:fox mario:mario; do
  for seed in 1 2 3; do
    i=$((i+1))
    p1=${pair%%:*}; p2=${pair##*:}
    "$GODOT" --headless --fixed-fps 60 --path . res://tests/trace_runner.tscn -- \
      --p1="$p1" --p2="$p2" --seed="$seed" --frames="$FRAMES" \
      --out="$OUT/${p1}_vs_${p2}_seed${seed}.txt" > /dev/null 2>&1
  done
done
echo "wrote $i traces to $OUT"
