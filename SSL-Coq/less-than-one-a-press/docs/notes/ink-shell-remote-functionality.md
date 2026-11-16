# Remote shells remain usable; ordinary distance does not freeze them

15 November 2026. **Yes: an initialized above-water shell can be remotely
thrown through native HOLP placement, remain tangible, mount into ground
riding, and cancel with fresh Z into a slide.** The original Japanese ROM
now confirms a throw directly into the useful Y1800 shell setup, with no
subsequent shell position edit. Supplied Mario FREEFALL at Y1810 and the
existing supplied pushers then produce top capture, retention and exact useful
spawn `(365.5927734375,5500,-1096.8026123046875)`.

This establishes the shell's conditional functionality, which is the user's
current priority. It does not establish that every raw location gives a useful
slide or handoff. Shell acquisition/HOLP, Mario approach and pusher delivery
remain separate gameplay obligations. No new global reachability theorem or
height interval is claimed.

## A legitimate shell still needs a way to become held

The SSL Area1 supply is the native above-water shell. Ordinary contact mounts
or nudges Mario; it is not normally picked up like a box. The underwater shell
is a different behavior, not the stock SSL supply under discussion.

Once an above-water shell becomes Mario's held target, its non-HOLDABLE branch
replaces the running behavior command with carry3 on pickup, carry4 on drop,
or carry5 on throw. These scripts stop at BREAK. A release does not restore
the native shell callback. Thus a legitimate shell can be the donor, but
ordinary grabbing is not an established alternative to the pending/fake-pickup
mechanism. The new tests include a native shell still running immediately
before release; its real throw also freezes it.

The existing pending-pickup history is credited: Mario actually carries a
small box, drops it, waits for its expiry and starts pickup just before its
slot is reused. It grants the roof shell box's contents-spawning action, not
the held/pickup pointer. Three initialization schedules are distinguished:

| Shell state before release | Actual remote release result | Mountability |
|---|---|---|
|Initialized before fake pickup; already frozen|Keeps type524288, tangible0, hitbox50×50; carry5 BREAK|Mounts in the tested contacts|
|Frozen before initialization|Keeps type0, intangible−1, default50×100; release does not repair it|All12 tested contacts fail to mount|
|Allocated/initialized after the slot was already held; still native before release|Moves during throw preparation, then native release installs carry5 BREAK|Mounts like the initialized frozen control|

No shell interaction type, hitbox, tangibility, status or behavior command is
assigned by the remote-release experiment. The native allocation and script
paths produce them. The old original-JP timely/late initialization pair is
separate existing evidence, not a new run for this task.

## What arbitrary placement means here

The actual throw writes, with native float rounding:

`shell XYZ = (HOLP.X + 32*sin(yaw), HOLP.Y, HOLP.Z + 32*cos(yaw))`.

The actual drop instead uses HOLP.X/Z and Mario's current movement Y. Three
high-HOLP drop controls leave the shell at Y0 rather than supplied HOLP.Y67267.
The same held states really throw to the requested high coordinates.

After the initialized shell's native throw, the stopped carry script applies
no gravity, movement or floor correction. Nonzero old velocity fields do not
move it. This provides conditional positioning at the tested raw coordinates
without needing a solid floor under the shell. It is not a theorem covering
all float values, initialization histories, actor interactions or area unloads.
Mario must still reach the shell's actual hitbox; terrain aliases do not
translate that hitbox or the real warp.

The following are discrete Wafel contact tests, independently reproduced
twice. Mario starts in supplied FREEFALL ten units above each released shell.
The table describes the initialized cases; no-Z and uninitialized controls
are retained in the packet.

| Actual shell XYZ | Fresh Z on accepted mount | What is established |
|---|---|---|
|`(-1962.440430,1800,-1243.341309)`|Ground slide executes, then slide-air in the isolation prefix|Mount/Z works; wrong top phase for the full handoff|
|`(-1950,24990,-939)`|Slide executes, then GROUND_BONK; M.Y768/G.Y25000|High placement preserves shell functionality|
|`(-1950,67267,-939)`|Slide executes, then GROUND_BONK; M.Y768/G.Y67277|Positive VPU contact works, not a complete handoff in this control|
|`(63586,24990,-939)` and `(-67486,24990,-939)`|Slide executes; actual X stays in its respective horizontal PU|Shell contact works; the real warp remains elsewhere|
|`(-1950,-40746,-939)`; initial MarioY−40736 =24800−65536|Mount transition occurs, then WATER_PLUNGE before slide execution|A concrete failure of universal arbitrary-Y slide viability|

The negative-VPU source explanation is the common moving-action water check:
raw M.Y is compared with waterLevel−100 before the riding-ground handler.
`find_water_level` can return the no-water lower sentinel−11000; plunge snaps
Mario to−11100 in this test. A terrain alias alone does not exempt the raw-Y
check. Other locations may instead fail because no floor is found, because
an earlier interaction ends the pass, or because the action is unsuitable.

Mounting accepts WALKING/HOLD_WALKING or the appropriate downward above-contact
interaction. Twirling and ground pound can be classified as attacks instead.
After a mount, **fresh Z**, with no A press, requests CROUCH_SLIDE before the
shell handler's own ground step. Holding Z from an earlier update is not the
same input edge. Later slope/step code may produce BUTT_SLIDE, slide-air or a
bonk. Merely seeing RIDING_SHELL_GROUND appear is not enough to establish that
the desired handler executes or survives into the next update.

## Direct remote throw into useful Ink

The full handoff test uses the established four-pillar conditional shell
preparation. It retains the shell-box spawn grant, low Mario/shell pickup
preparation and one used-object retarget. Actual pickup creates the held shell.
Before the native throw call, yaw0 and supplied HOLP
`(-1962.4404296875,1800,-1275.34130859375)` place the shell at
`(-1962.4404296875,1800,-1243.34130859375)`.

The shell is released at stored top timer25 and remains fixed through the
wait to timer128. There is **no shell position write after the throw**. The
later cut supplies Mario at Y1810 and the established enlarged Bob profile
and Bob/Box positions. Z128, then neutral inputs, produce the129 Bob shove,
the130 Box shove with fresh768 and G/M gap1071.447266, warp acceptance and
top capture131, observed retention, and the exact useful Area2 spawn.

The original-JP positive and no-final-Box control each compare25 observed
boundaries and1900 components. All selected physical fields agree; receipts
retain25 known clock offsets in each and2/25 Box-subtype differences. Two
transition camera boundaries per run are missing. Each native trace directly
records104 post-release observations with the shell fixed, tangible,50×50
and at carry5 BREAK. The positive arrives usefully; the control takes ordinary
`(0,5500,256)` without top capture. There are92/89 disclosed scalar setup
writes, including the earlier preparation, but no later shell XYZ write.
The floor hooks record709/685 returns. This is not whole-memory equivalence.

A separate Wafel positive throws directly to shellY19890 and supplies Mario
at19900; it also completes useful displacement. It was not rerun on the ROM
in this task. The local low/high positives and omission control each match
two fresh reconstructions. The remote isolation menu has21 actual releases
and36 four-update contacts,648 boundaries, also independently reconstructed
twice. These counts are finite coverage, not route probabilities.

## Distance inactivity and its actual benefit

**Normal above-water shells do not acquire distance inactivity merely because
Mario leaves.** Their flags omit COMPUTE_DIST_TO_MARIO. The generic wrapper
therefore neither refreshes distance nor enters its FAR_AWAY distance branch.
The stored distance can remain the allocation default19000 even next to Mario;
it is not evidence of sleep. Unlike the Bob-omb, the shell has no separate
4000-unit Stored Graphics gate. Camera culling is not behavior inactivity.

Twenty-four near/far and initial M/C/G-separation controls advance30 updates
each. The live shell's motion is identical at tested offsets400,1999–2001,
3999–4001 and65536, including vertical separation. It falls from Y968 to614
while far. The native dropped frozen shell stays fixed in every control.
No FAR_AWAY flag is supplied or appears. Two frozen high throws remain fixed
for180 updates near/far, then still accept a supplied approach and Z slide.
The wrapper timer continues increasing; the script stop is what parks them.

That freezing is useful: a remote shell need not fall before Mario arrives,
and a frozen shell can survive dismount for reuse. Four low controls distinguish
the following cases, with no editor status resets:

| State and timing | After Z | Fresh-Z remount from supplied return approach |
|---|---|---|
|Live shell, mount and Z in the same update|Remains action0, alive|Works|
|Live shell, ride one update then Z|Native action1 deletes it|No original shell remains|
|Frozen shell, immediate or delayed Z|Remains alive at its fixed position|Works in both controls|

Z assigns STOP_RIDING, clearing the INTERACTED bit that could block a later
mount. A live same-update cancellation can clear that bit before the shell
callback enters its riding action; delayed cancellation instead reaches its
deletion branch. Frozen scripts run neither callback branch. These are local
reuse controls with supplied return approaches, not a player-reached cycle
or an infinite-lifetime guarantee. Area unloading and slot reuse remain distinct.

## Proof scope, reproduction and route assessment

No new Coq lemma was needed to claim the narrower runtime result. Existing
Main-connected generated-Clight results already prove the carry-script/BREAK
cuts and preservation of disjoint cells across the script/stack stores:
`InkBoxFloor.ibf_every_break_preserves_memory` and
`InkBoxFloorFrame.ibff_clone_suffix_preserves_disjoint_cell`. Their exact
memory/access premises remain; they are not a complete shell-initialization
or infinite-wait theorem. Existing InkShellBridge and InkMarioEntryGuards
results cover the named ceiling-stop and null-floor dispatch boundaries.
No proof source changed or new proof build is claimed.

Reproduce from the packets: [remote release](../../instrumentation/ink-shell-remote-functionality/README.md),
[distance and reuse](../../instrumentation/ink-shell-distance/README.md),
[source and existing proofs](../../instrumentation/ink-shell-functionality-source/README.md),
and [original-JP direct throw](../../instrumentation/jp-ink-shell-remote/README.md).
Inputs, HOLP/setup ledgers, observations, native probes, raw comparisons and
hashes are retained. All A inputs are released; no held-A dependency is used.

Start revision `4adf8faf311d1d271c57f288f51b06bf357874d1` was verified against
the pushed branch. Applicable JP source pin:
`9921382a68bb0c865e5e45eb594d9c64db59b1af`; local decompile:
`36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`. Wafel0.8.5/Python3.9.13 DLL SHA256:
`960fe979068b78e6733b3ddb87741833fbf4eb29b2a21a2bba871977427c2d0f`.
Ubuntu-24.04 native runs use Mupen64Plus/Rice/RSP-HLE2.5.9, interpreter mode0,
and JP ROM SHA256 `9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317`.
M is Movement, C Collision and G Stored Graphics (`gfx.pos`), not rendered pose.

The shell mechanism remains viable under the stated holding/HOLP and approach
conditions; ordinary distance cannot replace freezing as a parking method.
The most useful next gameplay join is getting the initialized held shell
into the native release schedule and matching the low1810 approach/phase,
alongside the two pusher histories. A complete no-new-A route remains open.
All45 subjective estimates are unchanged, including Rank1 **1–2%** and
Ink Rank2 **<1%**.
