#!/usr/bin/env bash
set -euo pipefail

script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
rom="${1:?usage: $0 /path/to/authentic/baserom.jp.z64}"

expected_rom_sha256="9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317"
actual_rom_sha256="$(sha256sum "$rom" | awk '{print $1}')"
if [ "$actual_rom_sha256" != "$expected_rom_sha256" ]; then
    printf '%s\n' "refusing non-authentic or non-JP ROM" >&2
    exit 2
fi

for tool in dd sha256sum mips-linux-gnu-objdump; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        printf 'missing required tool: %s\n' "$tool" >&2
        exit 2
    fi
done

work_dir="$(mktemp -d)"
trap 'rm -rf -- "$work_dir"' EXIT
actual_manifest="$work_dir/store-call-manifest.csv"
printf '%s\n' 'kind,routine,pc,word,target_or_class' >"$actual_manifest"

classify_store() {
    case "$1" in
        802c9694) printf '%s' object-pool ;;
        8031dc98|8031dc9c) printf '%s' sound-request ;;
        8031dca4) printf '%s' sound-request-count ;;
        80321248) printf '%s' puzzle-music-state ;;
        *) printf '%s' stack ;;
    esac
}

while IFS=, read -r name start end word_count expected_sha256; do
    [ "$name" = name ] && continue
    start_decimal=$((16#$start))
    end_decimal=$((16#$end))
    offset=$((start_decimal - 16#80245000))
    byte_count=$((end_decimal - start_decimal))
    slice="$work_dir/$name.bin"
    disassembly="$work_dir/$name.disassembly"

    if [ "$byte_count" -ne $((word_count * 4)) ]; then
        printf 'range length mismatch for %s\n' "$name" >&2
        exit 3
    fi
    dd if="$rom" of="$slice" bs=1 skip="$offset" count="$byte_count" status=none
    actual_sha256="$(sha256sum "$slice" | awk '{print $1}')"
    if [ "$actual_sha256" != "$expected_sha256" ]; then
        printf 'range hash mismatch for %s\n' "$name" >&2
        exit 3
    fi

    mips-linux-gnu-objdump -D -b binary -m mips:4300 -EB \
        --adjust-vma="0x$start" "$slice" >"$disassembly"
    while read -r address word mnemonic operands _rest; do
        case "$address" in
            ????????:) ;;
            *) continue ;;
        esac
        pc="${address%:}"
        case "$mnemonic" in
            sb|sh|sw|swl|swr|sd|sdl|sdr|sc|scd|swc1|swc2|sdc1|sdc2)
                class="$(classify_store "$pc")"
                printf 'store,%s,%s,%s,%s\n' \
                    "$name" "$pc" "$word" "$class" >>"$actual_manifest"
                ;;
            jal)
                target="${operands#0x}"
                target="${target%%[[:space:]]*}"
                printf 'call,%s,%s,%s,%s\n' \
                    "$name" "$pc" "$word" "$target" >>"$actual_manifest"
                ;;
            jalr|bal|bgezal|bltzal|bgezall|bltzall)
                printf 'unexpected indirect/linking call at %s\n' "$pc" >&2
                exit 3
                ;;
        esac
    done <"$disassembly"
done <"$script_dir/expected-range-hashes.csv"

if ! diff -u "$script_dir/expected-store-call-manifest.csv" "$actual_manifest"; then
    printf '%s\n' 'retail direct-root store/call manifest mismatch' >&2
    exit 3
fi

printf '%s\n' 'Authenticated 163 direct-root instructions.'
printf '%s\n' 'No unexpected indirect/linking call occurred in the certified ranges.'
