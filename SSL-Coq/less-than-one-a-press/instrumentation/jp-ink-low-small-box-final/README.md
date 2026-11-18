# Low small-crate replacement on the Japanese ROM

The two cases replay the same shell mount and enlarged black Bob-omb shove.
Both start the final sequence with an actual SSL Area 1 small crate in object
slot 23. Mario's carrying states and the remote held-object positions (HOLP)
are supplied. The game executes the crate drop on update 126 and the held
Bob-omb release, shell mount and Z cancel on 128. No state edits follow the
128 approach cut. The original Crazy Box stays in its ordinary location.

Both 130 producer updates cache 768 and keep stored graphics Y at
1839.447265625. At the retuned position, the next low query misses and its
stored-graphics retry returns top slot 61 at Y1915.73706. Mario arrives at
(365.5927734375, 5500, -1096.8026123046875). At the old Crazy Box release
placement, the small crate also pushes Mario, but the next low query at
wall-corrected X=-2099 finds the static floor at 768. There is no retry
and the destination is the ordinary (0, 5500, 256).

The authenticated JP image has SHA-256
`9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317`.
The interpreter is Mupen64Plus 2.5.9 with the project's existing level-select
prefix. The prefix supplies the shell-box spawn, low pickup preparation,
used-object retarget and throw-time HOLP. Additional grants are listed field by
field in the sibling Wafel cases. A is released throughout.

`probe.py` builds the existing shell/release probe, observes the normal small
crate, and logs the actor, behavior pointer and Mario XYZ on entry and exit of
the JP shove function. The read-only breakpoints are at 0x8024d3d8 (actor in
a1) and 0x8024d57c (same actor saved at sp+0x44). The latter follows the
two conditional Mario X/Z writes at 0x8024d564 and 0x8024d570. The floor
query in that function returns to 0x8024d550. Raw logs also contain the
preparation writes, controls, ground-quarter decisions, floor queries, actor
state, and Movement, Collision and Stored Graphics XYZ.

Run from the SSL proof project in Ubuntu 24.04 WSL, with a fresh output
directory for each case.

```sh
packet=instrumentation/jp-ink-low-small-box-final
cases=instrumentation/ink-low-small-box-final
bash "$packet/run.sh" ../../../reference-sm64-decomp/baserom.jp.z64 "$cases/positive.json" /tmp/ssl-small-positive
bash "$packet/run.sh" ../../../reference-sm64-decomp/baserom.jp.z64 "$cases/control.json" /tmp/ssl-small-control
```

To verify the preserved evidence without an emulator, run the following
commands. The compact receipts identify the intervening X/Z changes and
the exact destination in each run. The two missing transition cameras
are bridges 27 and 28, as in the earlier Crazy Box replay.

```sh
python3 "$packet/check.py" "$cases/positive.json" "$packet/positive.log.gz"
python3 "$packet/check.py" "$cases/control.json" "$packet/control.log.gz"
```

## Two ordinary SSL Bob-omb slots

A third case uses the same shell and grants an enlarged held profile to
Bob-omb 40 for the first shove. The other Bob-omb, slot 39, retains its stock
radius of 65. Exactly three additional position writes put it at
(-2113.16455, 1839.44727, -1114.70203) just before update 130. The ROM
records 40 pushing on 129 and 39 pushing on 130. Mario reaches
(-2202.02295, 768, -1075.80212) with stored graphics Y1839.44727, captures
the top the next update, and gets the same useful displaced spawn. Supplying
the second Bob-omb's position leaves delivery open. In this case the generic
`EB_BOB` observer follows 40 and `SB_BOX` follows 39. `SB_SHOVE` reports
the actual actor pointer in every case.

```sh
two=instrumentation/ink-low-shove-roles/swapped-bobs.json
bash "$packet/run.sh" ../../../reference-sm64-decomp/baserom.jp.z64 "$two" /tmp/ssl-two-bobs
python3 "$packet/check.py" "$two" "$packet/swapped-bobs.log.gz"
```
