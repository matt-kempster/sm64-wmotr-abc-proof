#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -eq 0 ]; then
  echo "usage: $0 <generated-file> [...]" >&2
  exit 2
fi

for file in "$@"; do
  perl -0pi -e 's/[ \t]+(?=\n)//g; s/\n+\z/\n/' "$file"
done
