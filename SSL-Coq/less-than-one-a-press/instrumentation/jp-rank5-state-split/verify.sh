#!/usr/bin/env bash
set -euo pipefail

script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
project_dir="$(CDPATH= cd -- "$script_dir/../.." && pwd)"
rom="${1:?usage: $0 /path/to/authentic/baserom.jp.z64}"

bash "$project_dir/instrumentation/jp-rank1-live-boundary/verify.sh" "$rom"

work_dir="$(mktemp -d)"
trap 'rm -rf -- "$work_dir"' EXIT
instruction_count=0

while IFS=, read -r name start end rom_offset word_count expected_sha256; do
    [ "$name" = name ] && continue
    start_decimal=$((16#$start))
    end_decimal=$((16#$end))
    offset_decimal=$((16#$rom_offset))
    byte_count=$((end_decimal - start_decimal))
    slice="$work_dir/$name.bin"

    if [ "$byte_count" -ne $((word_count * 4)) ]; then
        printf 'range length mismatch for %s\n' "$name" >&2
        exit 3
    fi
    dd if="$rom" of="$slice" bs=1 skip="$offset_decimal" \
        count="$byte_count" status=none
    actual_sha256="$(sha256sum "$slice" | awk '{print $1}')"
    if [ "$actual_sha256" != "$expected_sha256" ]; then
        printf 'range hash mismatch for %s\n' "$name" >&2
        exit 3
    fi
    instruction_count=$((instruction_count + word_count))
done <"$script_dir/expected-range-hashes.csv"

if [ "$instruction_count" -ne 228 ]; then
    printf 'unexpected Rank-5/5A instruction count: %s\n' \
        "$instruction_count" >&2
    exit 3
fi

printf 'Authenticated %u additional retail-JP instructions across the Mario copy, callback tail, and cached-platform apply boundaries.\n' \
    "$instruction_count"
