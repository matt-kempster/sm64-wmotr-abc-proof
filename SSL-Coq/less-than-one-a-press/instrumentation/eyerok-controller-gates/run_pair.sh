#!/usr/bin/env bash
set -euo pipefail

if [[ "${WSL_DISTRO_NAME:-}" != "Ubuntu-24.04" ]]; then
    echo "run explicitly in WSL Ubuntu-24.04" >&2
    exit 1
fi

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
project_dir="$(cd -- "$script_dir/../.." && pwd)"
rom="${1:?usage: run_pair.sh /path/to/authentic/baserom.us.z64 [output-directory]}"
output_dir="${2:-$project_dir/build/instrumentation/eyerok-controller-gates-pair}"

"$script_dir/run.sh" "$rom" "$output_dir/positive-front" \
    800.0f 800.0f -2000.0f 1 8500 120.0f
"$script_dir/run.sh" "$rom" "$output_dir/negative-front" \
    800.0f 800.0f -2000.0f -1 8500 120.0f
python3 "$script_dir/analyze.py" "$rom" \
    "$output_dir/positive-front/raw.log" \
    "$output_dir/negative-front/raw.log" \
    "$script_dir/results/paired_receipt.txt"
