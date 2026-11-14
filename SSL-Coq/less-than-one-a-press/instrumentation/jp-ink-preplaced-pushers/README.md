# Original-JP check: both pushers preplaced, zero later item edits

`positive` places Bob39 and CrazyBox49 at the earlier successful XYZ values
before the shell mounting update128. `no-final-box` places only the Bob and
leaves the Crazy Box at its original world location. Both cases have no
post-mount setup writes. The positive captures/retains the top and reaches
exact useful spawn (365.5927734375,5500,-1096.8026123046875); the control
accepts the warp without capture and reaches ordinary (0,5500,256).

The conditional shell preparation, high FREEFALL, actor coordinates and
copied released91 donor profile remain supplied. Z on128 and neutral after
are the only continuation inputs; A is never pressed or held. Source-case
arrays contain `cuts: []`. The95/92 scalar-write ledgers end at bridge0,
before any mounted continuation, and the checker requires no later writes.
The original shell preparation/prefix is unchanged.

The new generator reuses the existing authenticated native query/quarter
probe and adds read-only Crazy Box fields. It changes no game instructions,
actor callbacks or camera state. `PP_BOX` records the Box's normal motion;
`EB_BOB` records the live fuse/radius evolution. The original-ROM input
cases are exported from the independently verified Wafel controls.

Both runs have25 comparable boundaries and missing camera samples25/26.
Of3650 compared components,3573 match exactly. The77 retained discrepancies
are50 known global-clock offsets and27 Box-subtype differences: two in the
positive,25 in the control, all native2 versus Wafel0. The checker accepts
only those exact discrepancy classes and expected boundaries. All selected
Mario, floor/cache/platform, actor position/velocity/radius/fuse values
match. This is not full-memory equality. The initial floor cache768, stopped
quarter preserving768, warp/capture and final arrival are directly checked
from native records. There are690/667 recorded floor returns respectively.

The original-ROM metadata and starting revisions are in
`docs/notes/ink-preplaced-pushers.md`. The ROM SHA-256 is
`9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317`.
Ubuntu-24.04 uses the existing Mupen64Plus2.5.9 interpreter/debugger,
Rice2.5.9, RSP-HLE, dummy audio and software OpenGL/Xvfb workflow.

From `SSL-Coq/less-than-one-a-press`, choose fresh output directories:

```sh
python3 instrumentation/jp-ink-preplaced-pushers/generate.py \
  instrumentation/jp-ink-preplaced-pushers/positive.json \
  instrumentation/jp-ink-preplaced-pushers/positive.c
bash instrumentation/jp-ink-preplaced-pushers/run.sh \
  ../../../reference-sm64-decomp/baserom.jp.z64 build/preplaced-new positive
python3 instrumentation/jp-ink-preplaced-pushers/check.py build/preplaced-new
```

Use case `no-final-box` for the control. `archive.py` preserves exact compiled
sources, cases, raw logs, traces, receipts and checker source as compressed
files; it refuses to overwrite an existing record directory. `verify.py
--check` reruns the archived checker, verifies all file hashes and binds the
main report. No ROM/binaries are archived. Earlier1/2-update waiting tests
are separate Wafel evidence, not represented as these two ROM runs.
