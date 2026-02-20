#!/usr/bin/env bash
# Context-efficient backpressure wrapper for Claude Code development.
# On success: prints a one-line summary (✓ + extracted metrics).
# On failure: prints ✗ header then full captured output for debugging.
#
# Usage:
#   ./scripts/run_silent.sh "description" command [args...]
#
# Examples:
#   ./scripts/run_silent.sh "tests" npm test
#   ./scripts/run_silent.sh "build" npx tsc --noEmit
#
# See: https://www.hlyr.dev/blog/context-efficient-backpressure

set -uo pipefail

# --- Summary extractors ---

parse_node_test() {
  local file="$1"
  local pass fail duration
  pass=$(grep -E '^# pass [0-9]+' "$file" | tail -1 | awk '{print $3}')
  fail=$(grep -E '^# fail [0-9]+' "$file" | tail -1 | awk '{print $3}')
  duration=$(grep -E '^# duration_ms' "$file" | tail -1 | awk '{printf "%.1fs", $2/1000}')

  if [ -n "$pass" ]; then
    echo "${pass} passed, ${fail:-0} failed (${duration:-?})"
  fi
}

parse_tsc() {
  local file="$1"
  local error_count
  error_count=$(grep -c 'error TS' "$file" 2>/dev/null || true)
  error_count="${error_count:-0}"
  if [ "$error_count" -eq 0 ]; then
    echo "no errors"
  else
    echo "${error_count} type errors"
  fi
}

extract_summary() {
  local desc="$1" file="$2"

  case "$desc" in
    test*)
      parse_node_test "$file"
      ;;
    build*|typecheck*)
      parse_tsc "$file"
      ;;
    *)
      ;;
  esac
}

# --- Main ---

description="${1:?Usage: run_silent.sh \"description\" command [args...]}"
shift

tmpfile=$(mktemp)
trap 'rm -f "$tmpfile"' EXIT

# Run command, capture all output, preserve exit code.
exit_code=0
"$@" > "$tmpfile" 2>&1 || exit_code=$?

if [ "$exit_code" -eq 0 ]; then
  summary=$(extract_summary "$description" "$tmpfile" 2>/dev/null || true)
  if [ -n "$summary" ]; then
    echo "✓ ${description}: ${summary}"
  else
    echo "✓ ${description}"
  fi
else
  echo "✗ ${description} (exit code ${exit_code})"
  echo "---"
  cat "$tmpfile"
fi

exit "$exit_code"
