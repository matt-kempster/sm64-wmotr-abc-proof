#!/usr/bin/env bash

SM64_ITEM_SWITCH="${SM64_ITEM_SWITCH:-sm64-item-proof}"

if ! command -v opam >/dev/null 2>&1; then
  echo "opam is not on PATH" >&2
  return 1 2>/dev/null || exit 1
fi

eval "$(opam env --switch "$SM64_ITEM_SWITCH" --set-switch)"

echo "Activated opam switch '$SM64_ITEM_SWITCH'."
echo "  coqc:      $(coqc --version | head -1)"
echo "  clightgen: $(clightgen -version 2>/dev/null | head -1)"
