#!/usr/bin/env python3
"""coqc_cache.py -- opt-in, content-addressed cache of coqc outputs (.vo/.glob/.vos/.vok).

Used ONLY when `pipeline/build.sh` is run with SM64_VO_CACHE=<dir> set (and no
--no-cache): build.sh then passes COQC=<this script> to make, so CoqMakefile's
compile rule calls us instead of coqc.  Default builds, the discipline audit and
CI never go through here.

  key = sha256 over
    - this script's own cache-format version,
    - the toolchain fingerprint: `coqc --print-version`, `coqc -config`, and a
      listing (relative path, size, mtime) of every file under COQLIB and
      COQCORELIB (stdlib, CompCert's user-contrib, plugins), plus the Coq-related
      environment (COQPATH, COQLIB, ...),
    - the coqc argv with physical paths made relative to the repo root (so
      worktrees at different absolute paths share entries),
    - the source file's relative path and bytes,
    - for each DIRECT dependency coqdep reports (the same tool, same flags, the
      CoqMakefile uses): its relative path and the sha256 of its .vo bytes.
  Direct deps suffice: a .vo records the digest of every library it was compiled
  against, so a direct dep's bytes commit to its whole dependency closure, and
  coqc refuses to load a mix whose digests disagree ("makes inconsistent
  assumptions over library ...").

Only plain compiles are cached: argv must be flags from a small whitelist
(-q, -R/-Q, -I, -w, -native-compiler) plus exactly one .v file.  Anything else
(-vos, -vok, -vio, -time, --print-version, ...) is passed straight to coqc.
A source that can write side files (Extraction to a file, Redirect, Load, ...)
is never cached.  The outputs are stored only when coqc exits 0, verified by
sha256 on every hit, and written into place with tmp-file + rename.

Concurrency (several worktrees sharing one cache): an entry is built in a temp
dir and published with one rename(2); a per-key flock makes a second builder of
the SAME key wait for the first and then take its result instead of compiling
the same file twice (if the first fails, the waiter compiles it itself).

Escape hatch: SM64_VO_CACHE unset / empty / "off" -> exec coqc directly.
"""
import fcntl
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import time

FORMAT = "sm64-vo-cache-v1"
UMASK = os.umask(0); os.umask(UMASK)
OUT_EXTS = ("glob", "vos", "vok", "vo")          # written in this order; .vo last
FLAG0 = {"-q"}                                     # flags without a value
FLAG1 = {"-I", "-w", "-native-compiler"}            # flags with one value
FLAG2 = {"-R", "-Q"}                                # flags with two values (phys, logical)
# vernacular that can read or write files outside the .v/.vo pair
SIDE_EFFECT_RE = re.compile(
    rb"^\s*(?:(?:Load|Redirect|Recursive\s+Extraction|Separate\s+Extraction|"
    rb"Extraction\s+Library|Cd|Add\s+(?:Rec\s+)?LoadPath|Declare\s+ML\s+Module)\s"
    rb"|Extraction\s+\")", re.M)


def real_coqc():
    me = os.path.realpath(__file__)
    for d in os.environ.get("PATH", "").split(os.pathsep):
        c = os.path.join(d, "coqc")
        if os.path.isfile(c) and os.access(c, os.X_OK) and os.path.realpath(c) != me:
            return c
    sys.stderr.write("coqc_cache: no coqc on PATH\n")
    sys.exit(127)


def say(msg):
    sys.stdout.write("[vo-cache] %s\n" % msg)
    sys.stdout.flush()


def passthrough(coqc, argv):
    os.execv(coqc, [coqc] + argv)


def sha256_file(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def rel(p, root):
    a = os.path.abspath(p)
    if a == root or a.startswith(root + os.sep):
        return os.path.relpath(a, root)
    return a


def parse(argv, root):
    """-> (normalized flag list, .v path) or None if not a plain compile."""
    flags, src, i = [], None, 0
    while i < len(argv):
        a = argv[i]
        if a in FLAG0:
            flags.append(a); i += 1
        elif a in FLAG1 and i + 1 < len(argv):
            v = argv[i + 1]
            flags += [a, rel(v, root) if a == "-I" else v]; i += 2
        elif a in FLAG2 and i + 2 < len(argv):
            flags += [a, rel(argv[i + 1], root), argv[i + 2]]; i += 3
        elif a.endswith(".v") and not a.startswith("-") and src is None:
            src = a; i += 1
        else:
            return None
    if src is None or not os.path.isfile(src):
        return None
    return flags, src


def flags_of(argv, root):
    return parse(argv, root)[0]


def toolchain_fp(coqc):
    fp = os.environ.get("SM64_VO_CACHE_TOOLCHAIN")
    if fp:
        return fp
    h = hashlib.sha256()
    for args in (["--print-version"], ["-config"]):
        h.update(subprocess.run([coqc] + args, stdout=subprocess.PIPE,
                                check=True).stdout)
    cfg = subprocess.run([coqc, "-config"], stdout=subprocess.PIPE, check=True,
                         text=True).stdout
    roots = [l.split("=", 1)[1] for l in cfg.splitlines()
             if l.startswith(("COQLIB=", "COQCORELIB="))]
    for r in sorted(roots):
        r = os.path.realpath(r)
        for d, dirs, files in os.walk(r):
            dirs.sort()
            for f in sorted(files):
                p = os.path.join(d, f)
                try:
                    st = os.stat(p)
                except OSError:
                    continue
                h.update(("%s %d %d\n" % (os.path.relpath(p, r), st.st_size,
                                          st.st_mtime_ns)).encode())
    for k in sorted(os.environ):
        if k.startswith(("COQ", "ROCQ")) or k in ("OCAMLPATH",):
            h.update(("%s=%s\n" % (k, os.environ[k])).encode())
    h.update(("coqc=%s\n" % os.path.realpath(coqc)).encode())
    return h.hexdigest()


def direct_deps(coqdep, flags, src):
    """Direct .vo deps of src per coqdep (same loadpath flags as the compile)."""
    lp = []
    i = 0
    while i < len(flags):
        if flags[i] in FLAG2:
            lp += flags[i:i + 3]; i += 3
        elif flags[i] == "-I":
            lp += flags[i:i + 2]; i += 2
        elif flags[i] in FLAG1:
            i += 2
        else:
            i += 1
    r = subprocess.run([coqdep] + lp + [src], stdout=subprocess.PIPE,
                       stderr=subprocess.PIPE, text=True)
    if r.returncode != 0 or r.stderr.strip():
        return None              # unresolved Require etc.: don't cache
    stem = src[:-2]
    for line in r.stdout.splitlines():
        lhs, sep, rhs = line.partition(":")
        if sep and (stem + ".vo") in lhs.split():
            toks = rhs.split()
            return sorted(t for t in toks if t.endswith(".vo"))
    return None


def compute_key(coqc, flags, src, root):
    coqdep = os.path.join(os.path.dirname(coqc), "coqdep")
    deps = direct_deps(coqdep, flags, src)
    if deps is None:
        return None, "coqdep failed"
    h = hashlib.sha256()
    h.update((FORMAT + "\n").encode())
    h.update(("toolchain %s\n" % toolchain_fp(coqc)).encode())
    h.update(("argv %s\n" % json.dumps(flags)).encode())
    with open(src, "rb") as f:
        body = f.read()
    if SIDE_EFFECT_RE.search(body):
        return None, "side-effecting vernacular"
    h.update(("src %s %s\n" % (rel(src, root), hashlib.sha256(body).hexdigest())).encode())
    for d in deps:
        if not os.path.isfile(d):
            return None, "missing dep %s" % d
        h.update(("dep %s %s\n" % (rel(d, root), sha256_file(d))).encode())
    return h.hexdigest(), None


def install_hit(entry, stem):
    """Copy a cache entry into place; True on success (sha-verified)."""
    staged, man = [], {}
    try:
        with open(os.path.join(entry, "manifest.json")) as f:
            man = json.load(f)
        for ext in OUT_EXTS:
            if ext not in man["files"]:
                continue
            dst = "%s.%s" % (stem, ext)
            fd, tmp = tempfile.mkstemp(prefix=os.path.basename(dst) + ".",
                                       suffix=".vcache", dir=os.path.dirname(dst) or ".")
            staged.append((tmp, dst))
            h = hashlib.sha256()
            with open(os.path.join(entry, ext), "rb") as s, os.fdopen(fd, "wb") as o:
                for chunk in iter(lambda: s.read(1 << 20), b""):
                    h.update(chunk); o.write(chunk)
            if h.hexdigest() != man["files"][ext]:
                raise IOError("sha mismatch on %s" % ext)
            os.chmod(tmp, 0o666 & ~UMASK)     # mkstemp makes 0600; match coqc's mode
        for tmp, dst in staged:
            os.replace(tmp, dst)
        staged = []
    except (OSError, IOError, KeyError, ValueError) as e:
        sys.stderr.write("coqc_cache: bad entry %s (%s); recompiling\n" % (entry, e))
        for tmp, _ in staged:
            try:
                os.unlink(tmp)
            except OSError:
                pass
        return False, man
    try:
        os.utime(os.path.join(entry, "manifest.json"))   # LRU stamp for the GC
    except OSError:
        pass
    for stream, name in ((sys.stdout, "stdout"), (sys.stderr, "stderr")):
        p = os.path.join(entry, name)
        if os.path.isfile(p):
            with open(p, "rb") as f:
                stream.flush(); stream.buffer.write(f.read()); stream.flush()
    return True, man


def compile_and_store(coqc, argv, stem, src, key, entry, objroot, cache, root):
    t0 = time.time()
    start_ns = time.time_ns() - 2_000_000_000   # coarse-mtime slack
    with tempfile.TemporaryFile() as out, tempfile.TemporaryFile() as err:
        rc = subprocess.run([coqc] + argv, stdout=out, stderr=err).returncode
        if rc < 0:
            rc = 128 - rc        # killed by a signal: report 137/143 like a shell
        out.seek(0); err.seek(0)
        o, e = out.read(), err.read()
    sys.stdout.flush(); sys.stdout.buffer.write(o); sys.stdout.flush()
    sys.stderr.flush(); sys.stderr.buffer.write(e); sys.stderr.flush()
    dt = time.time() - t0
    if rc != 0:
        return rc
    # the source or a dep edited while coqc ran: the outputs may not match the key
    if compute_key(coqc, flags_of(argv, root), src, root)[0] != key:
        say("NOSTORE %s (inputs changed during compile)" % rel(src, root))
        return rc
    files = {}
    try:
        tmpd = tempfile.mkdtemp(prefix="entry.", dir=os.path.join(cache, "tmp"))
        for ext in OUT_EXTS:
            p = "%s.%s" % (stem, ext)
            if os.path.isfile(p) and os.stat(p).st_mtime_ns >= start_ns:
                shutil.copyfile(p, os.path.join(tmpd, ext))
                files[ext] = sha256_file(os.path.join(tmpd, ext))
        if "vo" not in files:
            shutil.rmtree(tmpd, ignore_errors=True)
            return rc
        # re-hash the in-tree .vo: a concurrent writer in THIS tree must not
        # get a mismatched pair stored under our key
        if sha256_file(stem + ".vo") != files["vo"]:
            shutil.rmtree(tmpd, ignore_errors=True)
            return rc
        for name, data in (("stdout", o), ("stderr", e)):
            with open(os.path.join(tmpd, name), "wb") as f:
                f.write(data)
        with open(os.path.join(tmpd, "manifest.json"), "w") as f:
            json.dump({"format": FORMAT, "key": key, "src": rel(src, root),
                       "files": files, "seconds": round(dt, 1),
                       "stored": time.strftime("%Y-%m-%dT%H:%M:%S")}, f)
        os.makedirs(os.path.dirname(entry), exist_ok=True)
        try:
            os.rename(tmpd, entry)               # atomic publish
            say("STORE %s (%.1fs)" % (rel(src, root), dt))
        except OSError:
            shutil.rmtree(tmpd, ignore_errors=True)   # someone else published first
    except OSError as ex:
        sys.stderr.write("coqc_cache: could not store %s (%s)\n" % (src, ex))
    return rc


def main():
    argv = sys.argv[1:]
    coqc = real_coqc()
    cache = os.environ.get("SM64_VO_CACHE", "")
    if not cache or cache.lower() in ("off", "0", "no"):
        passthrough(coqc, argv)
    root = os.path.realpath(os.getcwd())
    parsed = parse(argv, root)
    if parsed is None:
        passthrough(coqc, argv)
    flags, src = parsed
    cache = os.path.abspath(os.path.join(cache, FORMAT))
    for sub in ("objects", "tmp", "locks"):
        os.makedirs(os.path.join(cache, sub), exist_ok=True)
    key, why = compute_key(coqc, flags, src, root)
    if key is None:
        say("BYPASS %s (%s)" % (rel(src, root), why))
        passthrough(coqc, argv)
    stem = src[:-2]
    objroot = os.path.join(cache, "objects")
    entry = os.path.join(objroot, key[:2], key)

    def try_hit():
        if os.path.isfile(os.path.join(entry, "manifest.json")):
            ok, man = install_hit(entry, stem)
            if ok:
                say("HIT %s (saved %ss)" % (rel(src, root), man.get("seconds", "?")))
                return True
        return False

    if try_hit():
        return 0
    lockf = open(os.path.join(cache, "locks", key + ".lock"), "w")
    try:
        try:
            fcntl.flock(lockf, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            say("WAIT %s (same key being compiled elsewhere)" % rel(src, root))
            fcntl.flock(lockf, fcntl.LOCK_EX)
        if try_hit():
            return 0
        say("MISS %s" % rel(src, root))
        return compile_and_store(coqc, argv, stem, src, key, entry, objroot, cache, root)
    finally:
        lockf.close()


if __name__ == "__main__":
    sys.exit(main())
