#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BIN="$ROOT_DIR/bin/io_optimizer"
INFILE="$ROOT_DIR/samples/input.txt"
BYTE_OUT="$ROOT_DIR/tests/output_byte.txt"
BLOCK_OUT="$ROOT_DIR/tests/output_block.txt"
BYTE_REPORT="$ROOT_DIR/tests/report_byte.txt"
BLOCK_REPORT="$ROOT_DIR/tests/report_block.txt"

score=0
max_score=100

pass() {
  echo "[PASS] $1"
}

fail() {
  echo "[FAIL] $1"
  exit 1
}

cleanup() {
  rm -f "$BYTE_OUT" "$BLOCK_OUT" "$BYTE_REPORT" "$BLOCK_REPORT"
}
trap cleanup EXIT

echo "== Build =="
make -C "$ROOT_DIR" clean >/dev/null || true
make -C "$ROOT_DIR" all >/dev/null || fail "Compilation failed"
pass "Compilation"
score=$((score + 20))

echo "== Run =="
"$BIN" "$INFILE" "$BYTE_OUT" 1 >"$BYTE_REPORT" || fail "Runtime failed in byte mode"
"$BIN" "$INFILE" "$BLOCK_OUT" 256 >"$BLOCK_REPORT" || fail "Runtime failed in block mode"
pass "Program runs in both modes"
score=$((score + 10))

echo "== Output Correctness =="
cmp -s "$INFILE" "$BYTE_OUT" || fail "Byte mode output differs from input"
cmp -s "$INFILE" "$BLOCK_OUT" || fail "Block mode output differs from input"
pass "Copied output matches input"
score=$((score + 30))

extract_metric() {
  local key="$1"
  local file="$2"
  local value
  value=$(grep -E "^${key}=[0-9]+$" "$file" | head -n1 | cut -d'=' -f2 || true)
  if [[ -z "$value" ]]; then
    echo ""
    return
  fi
  echo "$value"
}

byte_bytes=$(extract_metric "bytes" "$BYTE_REPORT")
byte_reads=$(extract_metric "read_calls" "$BYTE_REPORT")
byte_writes=$(extract_metric "write_calls" "$BYTE_REPORT")
byte_elapsed=$(extract_metric "elapsed_us" "$BYTE_REPORT")

block_bytes=$(extract_metric "bytes" "$BLOCK_REPORT")
block_reads=$(extract_metric "read_calls" "$BLOCK_REPORT")
block_writes=$(extract_metric "write_calls" "$BLOCK_REPORT")
block_elapsed=$(extract_metric "elapsed_us" "$BLOCK_REPORT")

[[ -n "$byte_bytes" && -n "$byte_reads" && -n "$byte_writes" && -n "$byte_elapsed" ]] || fail "Missing metrics in byte mode"
[[ -n "$block_bytes" && -n "$block_reads" && -n "$block_writes" && -n "$block_elapsed" ]] || fail "Missing metrics in block mode"
pass "All required metrics exist"
score=$((score + 10))

input_size=$(wc -c <"$INFILE" | tr -d ' ')

if [[ "$byte_bytes" -ne "$input_size" || "$block_bytes" -ne "$input_size" ]]; then
  fail "bytes metric must equal input size"
fi

expected_byte_reads=$((input_size + 1))
expected_byte_writes=$((input_size))

block_size=256
ceil_div=$(((input_size + block_size - 1) / block_size))
expected_block_reads=$((ceil_div + 1))
expected_block_writes=$((ceil_div))

if [[ "$byte_reads" -ne "$expected_byte_reads" ]]; then
  fail "byte mode read_calls expected ${expected_byte_reads}, got ${byte_reads}"
fi
if [[ "$byte_writes" -ne "$expected_byte_writes" ]]; then
  fail "byte mode write_calls expected ${expected_byte_writes}, got ${byte_writes}"
fi
if [[ "$block_reads" -ne "$expected_block_reads" ]]; then
  fail "block mode read_calls expected ${expected_block_reads}, got ${block_reads}"
fi
if [[ "$block_writes" -ne "$expected_block_writes" ]]; then
  fail "block mode write_calls expected ${expected_block_writes}, got ${block_writes}"
fi
pass "Deterministic syscall-count checks"
score=$((score + 20))

if [[ "$block_elapsed" -le $((byte_elapsed * 5)) ]]; then
  pass "Block mode not dramatically slower (timing sanity)"
  score=$((score + 10))
else
  echo "[WARN] Block mode much slower than byte mode on this run"
fi

echo
echo "Score: ${score}/${max_score}"
echo "Autograde completed successfully"
