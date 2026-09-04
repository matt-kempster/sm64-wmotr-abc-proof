#!/usr/bin/env bash
set -euo pipefail

script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
project_dir="$(CDPATH= cd -- "$script_dir/../.." && pwd)"
rom="${1:?usage: $0 /path/to/authentic/baserom.jp.z64 /path/to/checkpoint.st}"
state="${2:?usage: $0 /path/to/authentic/baserom.jp.z64 /path/to/checkpoint.st}"

test -s "$state"
mkdir -p "$project_dir/build/instrumentation"
summary="$(mktemp "$project_dir/build/instrumentation/rank10-query-summary.XXXXXX")"

held_output="$(RANK10_RESUME_STATE=1 RANK10_QUERY_TRACE=1 \
    RANK10_SAVESTATE="$state" \
    bash "$script_dir/run.sh" "$rom" 250 2)"
printf '%s\n' "$held_output"
held_receipt="$(printf '%s\n' "$held_output" | sed -n 's/^Receipt: //p')"
grep '^RANK10_QUERY_RESULT,' "$held_receipt" \
    | sed 's/^RANK10_QUERY_RESULT,/RANK10_QUERY_RESULT,mode=held-A-east,/' \
    >>"$summary"

rollout_output="$(RANK10_RESUME_STATE=1 RANK10_QUERY_TRACE=1 \
    RANK10_SAVESTATE="$state" \
    bash "$script_dir/run.sh" "$rom" 500 1)"
printf '%s\n' "$rollout_output"
rollout_receipt="$(printf '%s\n' "$rollout_output" | sed -n 's/^Receipt: //p')"
grep '^RANK10_QUERY_RESULT,' "$rollout_receipt" \
    | sed 's/^RANK10_QUERY_RESULT,/RANK10_QUERY_RESULT,mode=B-rollout,/' \
    >>"$summary"

if ! cmp -s "$script_dir/expected-query-summary.txt" "$summary"; then
    diff -u "$script_dir/expected-query-summary.txt" "$summary" >&2 || true
    printf '%s\n' 'Rank-10 quarter-step query summary mismatch' >&2
    exit 3
fi
printf 'Rank-10 held-A and rollout query traces passed: %s\n' "$summary"
