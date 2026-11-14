# Original JP: live solid landing creates a useful Ink slide

The authenticated original Japanese ROM reproduces the high live-large-box witness from `../ink-high-solid-support`: supplied FREEFALL+B lands into DIVE_SLIDE, then a separately placed non-mounting shell nudges Mario and completes useful spawning displacement. Initial high air/support placement and shell spawning/placement remain grants. No ground action, floor/cache/platform pointer, later Mario pose or support-removal write is used.

From `SSL-Coq/less-than-one-a-press`, in Ubuntu-24.04 WSL, use a fresh output directory:

```sh
bash instrumentation/jp-ink-high-solid-support/run.sh ../../../reference-sm64-decomp/baserom.jp.z64 build/NEW-high-solid
```

The runner verifies ROM SHA-256/MD5, compiles the probe with warnings as errors, and uses Mupen64Plus2.5.9 interpreter/Rice/HLE RSP. The mode12 four-pillar prefix is inherited from `../jp-clean-gap-search`, retaining its debug level-selection startup grant. This is instrumented original-ROM execution; no modified ROM, compiled plugin or emulator binary is distributed.

The selected replay has 27 disclosed wrapper writes: shell-box action preparation1, initial high air/support setup23, later shell XYZ3. The velocity-Y component is initially written0 by the setup helper and immediately overwritten-16 before game execution. All 53 camera observations have null held/ridden pointers; shell69 is never used. All A counters are zero. Native useful Area2 arrival after26 high-suffix updates is `(365.5927734375,5500,-1096.8026123046875)`.

Frozen Wafel trial comparison covers24 visible boundaries ×45 scalar fields/components. Of1080 comparisons,1035 match. The45 differences are **interaction subtype only**: native2 versus Wafel0 for the live support at23 Area1 observations and for shell69 at22 observations beginning after capture. These are preserved, not normalized away. All compared M/C/D, action, cache, velocity and pointer results match. Camera observations28/29 are absent during transition; continuous platform retention is established separately by Wafel, while this ROM replay checks the available samples. Neither replay establishes full-state equivalence.

Recheck archived evidence without ROM/emulator:

```sh
python3 instrumentation/jp-ink-high-solid-support/check.py instrumentation/jp-ink-high-solid-support/records/large-box-shell-25000 --archived
```

`expected.json.gz` freezes final Wafel trial `edge=1,pusher=shell` and its source archive hash. `prepare_expected.py` checks that it still equals the source artifact. `archive.py` preserves the filtered and compressed raw logs, checker, probe/prefix/runner snapshots and hashes. `verification.json` pins scope, versions and checked results. The detailed setup and frame table are in `../../docs/notes/ink-high-solid-support-rom.md`; source explanation and the broader finite controls remain in `../../docs/notes/ink-high-solid-support.md`.
