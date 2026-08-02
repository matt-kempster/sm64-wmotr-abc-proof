#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# shellcheck disable=SC1091
source "$PROJECT_ROOT/pipeline/env.sh"

make -C "$PROJECT_ROOT" "$@"
