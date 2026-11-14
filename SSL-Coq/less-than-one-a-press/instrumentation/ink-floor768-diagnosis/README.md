# Original-JP floor-cache diagnosis

This packet compares the successful supplied frozen-shell / Box+Buddy / Box
history with selected history 0 from `ink-bobomb-retimed-shoves`. The selected
failure has **no first Bob placement**: it is the no-first-pusher comparison
inside that bounded menu. No legal delivery or high-Mario reachability claim.

`probe.c` reuses the original-JP prefix and shell preparation, adding read-only
execute breakpoints at floor-query entry/return, ground-step entry/return,
quarter checks/commit/return and top collision loading. Every setup write is
logged. Run from the SSL project in Ubuntu-24.04 with fresh output folders:

```sh
bash instrumentation/ink-floor768-diagnosis/run.sh \
  ../../../reference-sm64-decomp/baserom.jp.z64 build/floor768-positive 1
bash instrumentation/ink-floor768-diagnosis/run.sh \
  ../../../reference-sm64-decomp/baserom.jp.z64 build/floor768-retime 2
python3 instrumentation/ink-floor768-diagnosis/check.py build/floor768-positive
python3 instrumentation/ink-floor768-diagnosis/check.py build/floor768-retime
```

Verify the archived evidence without running an emulator:

```sh
python3 instrumentation/ink-floor768-diagnosis/check.py \
  instrumentation/ink-floor768-diagnosis/records/positive --archived
python3 instrumentation/ink-floor768-diagnosis/check.py \
  instrumentation/ink-floor768-diagnosis/records/retime --archived
```

The native runs match 60 saved Wafel boundaries in the selected physical
fields. All 60 established clock differences (`native+2 = Wafel`) remain in
the receipts. Two positive camera boundaries are unavailable during the area
transition. Positive: exact useful spawn. Negative: Area 1 throughout its 35
recorded post-entry boundaries. The callback records 459/483 floor returns.

At update 130 the positive's **initial geometry query** returns 768, then its
shove/quarter queries return 1280. The negative's initial query returns the
top at 1933.4923095703125, then its shove/quarter queries return 768. Both
quarters stop with native result 2 without committing their local floor.

`FD_TOP_LOAD.distance` is stored `oDistanceToMario` sentinel 19000, not true
distance. Archived `yaw` is `oMoveAngleYaw`, not spinning face yaw. Loading
is witnessed by the `load_object_surfaces` hook. Archived probe source is
exactly what compiled, including an inherited obsolete mode-2 header comment;
the current header correctly describes mode 2. Mode-2 code and all actor cuts
implement the saved retiming comparison, as the checker verifies.

`geometry.py` and its receipts evaluate source floor selection on freshly
reconstructed loaded surface lists. Additional coordinate probes are
read-only query diagnostics, not new gameplay histories. See `geometry.md`
for its reproduction commands and `docs/notes/ink-floor768-diagnosis.md` for
the interpretation. Raw traces and exact sources are archived with hashes;
ROM and emulator binaries are excluded.
