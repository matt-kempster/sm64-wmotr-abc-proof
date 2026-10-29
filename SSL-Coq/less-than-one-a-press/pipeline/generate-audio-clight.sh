#!/usr/bin/env bash
# Supplemental real audio unit for a source-backed external binding.
# The existing selected gameplay target is not changed by this command.
set -euo pipefail
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
source "$PROJECT_ROOT/pipeline/env.sh"
REVISION=9921382a68bb0c865e5e45eb594d9c64db59b1af
SOURCE_REPOSITORY="${SM64_SOURCE:-$PROJECT_ROOT/../../../reference-sm64-decomp}"
git -c "safe.directory=$SOURCE_REPOSITORY" -C "$SOURCE_REPOSITORY" cat-file -e "$REVISION^{commit}"
mkdir -p "$PROJECT_ROOT/build"
AUDIO_SOURCE="$(mktemp -d "$PROJECT_ROOT/build/audio-source.XXXXXX")"
git -c "safe.directory=$SOURCE_REPOSITORY" -C "$SOURCE_REPOSITORY" archive --format=tar "$REVISION" |
  tar -xf - -C "$AUDIO_SOURCE"
export CLIGHTGEN_SOURCE_ROOT="$AUDIO_SOURCE"
export CLIGHTGEN_PROJECT_ROOT="$PROJECT_ROOT"
COMMON=( -nostdinc -fstruct-passing
  "-I$AUDIO_SOURCE/include" "-I$AUDIO_SOURCE/src" "-I$AUDIO_SOURCE/src/game"
  "-I$AUDIO_SOURCE" "-I$AUDIO_SOURCE/include/libc"
  -D_FINALROM=1 -DTARGET_N64=1 -DNON_MATCHING=1 -DAVOID_UB=1 -D_LANGUAGE_C=1 )
for version in us jp; do
  if [ "$version" = us ]; then
    VERSION_FLAGS=(-DVERSION_US=1 -DF3DEX_GBI_2=1 -DF3DEX_GBI_SHARED=1)
  else
    VERSION_FLAGS=(-DVERSION_JP=1 -DF3D_OLD=1)
  fi
  bash "$PROJECT_ROOT/pipeline/clightgen.sh" "$AUDIO_SOURCE/src/audio/external.c" \
    src/audio/external.c "VERSION_${version^^}" \
    "$PROJECT_ROOT/generated/runtime/${version}_audio_external.v" \
    "${COMMON[@]}" "${VERSION_FLAGS[@]}"
done
echo 'Generated two supplemental audio units from the pinned source; the gameplay link is unchanged.'
