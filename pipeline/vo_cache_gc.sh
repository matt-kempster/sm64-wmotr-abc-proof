#!/usr/bin/env bash
# Trim the shared .vo cache (pipeline/coqc_cache.py) to the most recently USED
# entries totalling at most N GB (default 10).  Safe to run while builds use the
# cache: an entry is retired by one rename into tmp/ before it is deleted, so a
# reader sees either the whole entry or none (and then just recompiles).
#
#   bash pipeline/vo_cache_gc.sh            # keep 10 GB
#   bash pipeline/vo_cache_gc.sh 4          # keep 4 GB
#   bash pipeline/vo_cache_gc.sh 0          # empty the cache
#   SM64_VO_CACHE=/other/dir bash pipeline/vo_cache_gc.sh
#
# A full build of the tree stores about 0.5 GB (.vo + .glob).
set -euo pipefail
dir="${SM64_VO_CACHE:-$HOME/.cache/sm64-vo}"
keep_gb="${1:-10}"
exec python3 - "$dir" "$keep_gb" <<'EOF'
import os, shutil, sys, time
root = os.path.join(os.path.abspath(sys.argv[1]), "sm64-vo-cache-v1")
keep = int(float(sys.argv[2]) * 1e9)
objs, tmp, locks = (os.path.join(root, d) for d in ("objects", "tmp", "locks"))
if not os.path.isdir(objs):
    print("vo_cache_gc: no cache at %s" % root); sys.exit(0)
now = time.time()
for d in (tmp,):                       # abandoned temp entries (> 1 day)
    for n in os.listdir(d) if os.path.isdir(d) else ():
        p = os.path.join(d, n)
        try:
            if now - os.lstat(p).st_mtime > 86400:
                shutil.rmtree(p, ignore_errors=True) if os.path.isdir(p) else os.unlink(p)
        except OSError:
            pass
for n in os.listdir(locks) if os.path.isdir(locks) else ():
    p = os.path.join(locks, n)         # lock files are only advisory (flock); stale = harmless
    try:
        if now - os.lstat(p).st_mtime > 7 * 86400:
            os.unlink(p)
    except OSError:
        pass
entries = []
for sub in os.listdir(objs):
    for k in os.listdir(os.path.join(objs, sub)):
        e = os.path.join(objs, sub, k)
        try:
            used = os.stat(os.path.join(e, "manifest.json")).st_mtime
            size = sum(os.lstat(os.path.join(e, f)).st_size for f in os.listdir(e))
        except OSError:
            used, size = 0, 0
        entries.append((used, size, e))
entries.sort(reverse=True)            # most recently used first
total, kept, removed, freed = 0, 0, 0, 0
for used, size, e in entries:
    if total + size <= keep:
        total += size; kept += 1; continue
    t = os.path.join(tmp, "gc.%d.%s" % (os.getpid(), os.path.basename(e)))
    try:
        os.rename(e, t)
        shutil.rmtree(t, ignore_errors=True)
        removed += 1; freed += size
    except OSError:
        pass
print("vo_cache_gc: %s: kept %d entries (%.2f GB), removed %d (%.2f GB)"
      % (root, kept, total / 1e9, removed, freed / 1e9))
EOF
