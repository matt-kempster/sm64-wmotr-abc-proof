#!/usr/bin/env bash
set -euo pipefail

# Historical receipts are retained, but debug entry is outside the cog task.
# Fail before inspecting ROMs, compiling a plugin, or starting an emulator.
printf '%s\n' \
    'This legacy probe required a level-select cheat and is retired.' \
    'Cog experiments require normal entry, legal inputs, and read-only observation.' \
    'Validate historical receipts with Pedro-Coq/pipeline/check-ttc-runtime-snapshot.py.' >&2
exit 2
