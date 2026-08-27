#!/usr/bin/env bash
set -euo pipefail

script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
project_dir="$(CDPATH= cd -- "$script_dir/../.." && pwd)"
rom="${1:?usage: $0 /path/to/authentic/baserom.jp.z64}"

expected_rom_sha256="9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317"
actual_rom_sha256="$(sha256sum "$rom" | awk '{print $1}')"
if [ "$actual_rom_sha256" != "$expected_rom_sha256" ]; then
    printf '%s\n' "refusing non-authentic or non-JP ROM" >&2
    exit 2
fi

for tool in dd sha256sum; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        printf 'missing required tool: %s\n' "$tool" >&2
        exit 2
    fi
done

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

probe_source="$project_dir/instrumentation/jp-clean-gap-search/jp_clean_gap_search_probe.c"
if grep -Eq 'DebugMemWrite|\bW32\b|\bW16\b|\bW8\b' "$probe_source"; then
    printf '%s\n' "probe source contains a game-memory write API" >&2
    exit 3
fi

if [ "$instruction_count" -ne 2200 ]; then
    printf 'unexpected authenticated instruction count: %s\n' \
        "$instruction_count" >&2
    exit 3
fi

printf 'Authenticated %u retail-JP instructions across the allocator, frame, surface, and query boundaries.\n' \
    "$instruction_count"
printf '%s\n' 'The runtime probe contains no game-memory write API.'
