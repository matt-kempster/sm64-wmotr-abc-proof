# Original-JP remote shell throw, Box drop, and mount-triggered Bob drop

15 November 2026. The original Japanese ROM reproduces the stronger joined
release sequence: Mario actually throws the initialized shell to its remote
target, actually drops the Crazy Box on126, and contacts the shell while
holding the enlarged Bob-omb on128. Native shell contact drops Bob; fresh Z
mounts/cancels into the slide in that update. Bob129 and Box130 then produce
fresh cache768, low-M/high-G Ink, top capture/retention and useful displacement
to `(365.5927734375,5500,-1096.8026123046875)`.

**The two carrying/approach cuts remain supplied.** Before126 Mario is placed
in the remote Box-carry state. Before128 Mario is placed in HOLD_FREEFALL at
`(-1962.4404296875,1810,-1243.34130859375)` holding the native radius91 donor
profile, with its required HOLP. There is no separate127 Bob-release setup
and no Mario relocation after Bob's actual128 drop. No shell field is edited
after its throw, no Box field after its126 drop, and no Bob field after its128
drop. These facts do not establish the requested continuous delivery route
without later Mario position edits. The two supplied holding states have not
been joined by controller gameplay.

## Exact shell release and mount

The inherited four-pillar shell preparation retains the shell-box spawn
grant, earlier low Mario/shell pickup preparation and used-pointer retarget.
Native pickup produces the held shell. Yaw0 B throw at preparation step25
uses supplied HOLP `(-1962.4404296875,1800,-1275.34130859375)` and places the
shell at `(-1962.4404296875,1800,-1243.34130859375)`. The running ROM records102
stationary/tangible50×50 post-release observations at carry5 BREAK before
the later release/mount sequence.

At128 the probe observes held Bob39 and HOLD_FREEFALL before the update, with
the forced-drop interaction-status bit cleared. The actual update clears
Mario's held and ridden pointers, leaves shell STOP_RIDING, and executes
BUTT_SLIDE. The native Bob drop callback completes with held-state0. The Bob
release origin is computed by the game, not written by the probe. Its current
movement Y is1810; the native floor correction raises the Bob toY1867.130615.
Mario's first slide ends at `(-1960,1809.2066650390625,-1230)`.

The Box-omission control performs the shell throw and128 held-Bob mount but
leaves the Box in its ordinary world position. It gets ordinary
`(0,5500,256)`, with no top capture. All A inputs remain released and the prefix
audit reports zero A press/down/controller-A frames.

| Accepted run | Selected comparisons | Retained differences | Outcome |
|---|---|---|---|
|`positive`|27 boundaries,2052 components|27 clocks,4 Box subtypes|Top capture131, observed retention, useful spawn|
|`no-box`|27 boundaries,2052 components|27 clocks,27 Box subtypes|Ordinary warp, no capture|

All other selected physical components agree with the independently repeated
Wafel traces. The clock difference is native+2=Wafel. Native Box subtype2
versus Wafel0 is DELAY_INVINCIBILITY, unused by the neutral slide push; its
origin remains unestablished. Camera boundaries27/28 are missing in both
transitions. Whole-memory equivalence is not claimed. The two runs contain
709/710 floor returns and125/120 scalar setup writes, respectively, including
inherited shell preparation. The positive's130 initial geometry query returns
768. M is Movement, C Collision and G Stored Graphics (`gfx.pos`), not visible
model position.

## Checks and provenance

`generate.py` uses the established native release exporter, substitutes only
the actual throw-time HOLP, and adds read-only shell observations. It requires
phase126 plus a single128 setup cut and rejects later shell grants.
`compare.py` is a local copy of the prior native release comparator with the
Bob no-later-write boundary changed from127 to its actual128 release; only
Bob fields may be supplied in that128 cut. It retains all physical component
comparisons and explicit mismatches. `check.py` additionally checks native
held-Bob entry, final unforced-drop status0, native dismount, shell position,
type/tangibility/hitbox, and absence of post-throw shell XYZ writes. No old
packet or comparator was modified.

Cases are copied from
[`ink-shell-carried-bob-mount`](../ink-shell-carried-bob-mount/README.md), not
the older three-cut diagnostic in `ink-shell-three-releases`. Both exact
recipes, generated probes, immutable raw logs, query/actor traces, receipts,
prefix source, runner source and comparator/checker bytes are archived.
No ROM or emulator binaries are distributed.

From the SSL project directory:

```powershell
python instrumentation/jp-ink-shell-three-releases/generate.py instrumentation/jp-ink-shell-three-releases/positive.json instrumentation/jp-ink-shell-three-releases/positive.c
```

Then in Ubuntu-24.04 WSL, with a fresh output directory:

```sh
bash instrumentation/jp-ink-shell-three-releases/run.sh '../../../reference-sm64-decomp/baserom.jp.z64' 'build/FRESH-THREE-RELEASES' positive
```

```powershell
python instrumentation/jp-ink-shell-three-releases/check.py build/FRESH-THREE-RELEASES
python instrumentation/jp-ink-shell-three-releases/verify.py --check
```

Substitute `no-box` for the negative control. Accepted local run directories
are `build/jp-shell-three-positive-a` and `build/jp-shell-three-no-box-a`; both
runner processes completed successfully before checking/archiving.

Start revision `ea1a4994f5157636f481723a89c6411a53e6e6d4`; applicable JP source
`9921382a68bb0c865e5e45eb594d9c64db59b1af`; local decompile
`36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`. Runtime:
Mupen64Plus/Rice/RSP-HLE2.5.9, interpreter mode0, Xvfb/software GL, dummy audio.
Original JP ROM SHA256:
`9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317`.
Wafel0.8.5/Python3.9.13 comparison DLL SHA256:
`960fe979068b78e6733b3ddb87741833fbf4eb29b2a21a2bba871977427c2d0f`.
No new Coq source or build is claimed by this runtime packet.
