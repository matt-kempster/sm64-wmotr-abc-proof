#!/usr/bin/env bash
set -euo pipefail

PROOF_SWITCH="${SM64_PROOF_SWITCH:-sm64-item-proof}"

if ! command -v opam >/dev/null 2>&1; then
  echo "opam is not on PATH" >&2
  return 1 2>/dev/null || exit 1
fi

eval "$(opam env --switch "$PROOF_SWITCH" --set-switch)"

echo "Activated proof toolchain '$PROOF_SWITCH'."
echo "  coqc:      $(coqc --version | head -1)"
echo "  clightgen: $(clightgen -version 2>/dev/null | head -1)"

# Preserve the established WSL memory guardrail: 6.5 GiB address-space cap.
SM64_PROOF_VCAP_KB="${SM64_PROOF_VCAP_KB:-6815744}"
if [ "$SM64_PROOF_VCAP_KB" != 0 ]; then
  ulimit -S -v "$SM64_PROOF_VCAP_KB"
fi
