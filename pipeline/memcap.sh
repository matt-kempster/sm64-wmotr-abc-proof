#!/usr/bin/env bash
# Source as the FIRST line of a pipeline driver:  source pipeline/memcap.sh "$0" "$@"
# Re-execs the driver inside a systemd user scope with a hard cgroup memory cap,
# so a runaway coqc is OOM-killed inside its own cgroup instead of thrashing the
# whole 8GB WSL VM (2026-09-27: the VM went down). env.sh's `ulimit -v` bounds
# address space per process; this bounds real RSS (+ swap) for the whole driver.
# Override: SM64_MEM_MAX=6G; disable: SM64_MEM_MAX=0. Skipped where
# `systemd-run --user` is unavailable (e.g. CI).
if [ -z "${SM64_MEMCAPPED:-}" ] && [ "${SM64_MEM_MAX:-5G}" != "0" ] \
   && systemd-run --user --scope --quiet true >/dev/null 2>&1; then
  export SM64_MEMCAPPED=1
  _memcap_script="$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
  shift
  exec systemd-run --user --scope --quiet \
    -p MemoryMax="${SM64_MEM_MAX:-5G}" -p MemorySwapMax=512M \
    bash "$_memcap_script" "$@"
fi
