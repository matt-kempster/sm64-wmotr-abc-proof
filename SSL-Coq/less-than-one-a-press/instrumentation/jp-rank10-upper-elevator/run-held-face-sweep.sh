#!/usr/bin/env bash
set -euo pipefail

script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
project_dir="$(CDPATH= cd -- "$script_dir/../.." && pwd)"
rom="${1:?usage: $0 /path/to/authentic/baserom.jp.z64 /path/to/checkpoint.st}"
state="${2:?usage: $0 /path/to/authentic/baserom.jp.z64 /path/to/checkpoint.st}"

test -s "$state"
mkdir -p "$project_dir/build/instrumentation"
summary="$(mktemp "$project_dir/build/instrumentation/rank10-held-faces.XXXXXX")"
for mode in 2 3 4 5; do
    output="$(RANK10_RESUME_STATE=1 RANK10_SAVESTATE="$state" \
        bash "$script_dir/run.sh" "$rom" 250 "$mode")"
    printf '%s\n' "$output"
    receipt="$(printf '%s\n' "$output" | sed -n 's/^Receipt: //p')"
    grep -E '^RANK10_(POSE|FIRST_JUMP_WALL|HELD_RESULT)' "$receipt" >>"$summary"
done

if ! cmp -s "$script_dir/expected-held-face-summary.txt" "$summary"; then
    diff -u "$script_dir/expected-held-face-summary.txt" "$summary" >&2 || true
    printf '%s\n' 'Rank-10 held-A face sweep mismatch' >&2
    exit 3
fi
printf 'Rank-10 held-A four-face sweep passed: %s\n' "$summary"
