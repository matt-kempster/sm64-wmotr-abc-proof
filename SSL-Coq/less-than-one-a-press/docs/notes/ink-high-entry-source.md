# High-window entry: source constraints on the remaining search

14 November 2026. **The second height window makes an established ground
slide useful; it does not make an ordinary airborne action land at that
height.** The native shell-mount/Z cancellation remains a real way to enter
the grounded slide helper in air. Its known obstacle is still horizontal
placement after the fresh floor-cache query. The source checks below narrow
several proposed repairs without claiming that every no-new-A entry is
impossible.

This pass starts from proof commit
`651c180e594e45c6825f9c4800da11f4afef0773`, branch
`codex/ssl-pyramid-item-proof`. It builds on the already committed
[entry investigation](ink-mario-entry-reachability.md),
[shell experiment](ink-airborne-shell-entry.md),
[height map](ink-height-map.md), and
[supported landing preparation](ink-supported-slide-preparation.md).
Those records already distinguish useful displacement from an ordinary
accepted warp; a large position gap alone is not a success.

The inspected source is the applicable JP path in sibling decompile
`36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`. The checkout has existing local
changes, which were preserved. `git diff` for the inspected `mario.c` and
`interaction.c` reports no content changes (their status reflects line-ending
normalization); the other source files listed below are unmodified. This
note records source deductions. Companion runtime reports retain their own
setup writes, inputs, hashes and complete continuations. This note does not
introduce a new original-ROM replay or a new continuous controller route.

## What the high window actually removes

For the default tested box fixture, the main-universe second window starts
at binary32 Y **21777.658203125**. The previous binary32 value
**21777.65625** fails. Its working integer heights are **21778–32767**;
integer 21777 is not included. The separately tested positive-VPU integer
window includes **67277–98303**. These are fixture-specific results from the
height map, not exhaustive ranges for every X/Z and actor placement.

At the high main-universe fixture, the top is beyond the dynamic collision
loading distance during the producer. The initial query obtains the real
low pad floor, while the high raw movement Y and the no-ceiling sentinel
20000 stop the ground quarter. Thus a genuine crawl/common-slide handler can
copy high movement Y into stored `gfx.pos` and then align movement to the
fresh low cache. A next-update low query must still miss the pad, use the
high stored graphics retry, select the now-loaded top, and carry that
reference through the accepted warp to useful Area 2 displacement.

Here movement position M is `MarioState.pos`, collision position C is the
Mario object's position, and stored graphics position D is `header.gfx.pos`.
D is not the render matrix and does not specify where the model is drawn.
Query aliasing does not translate M, the Crazy Box, the shell or the real warp.

## Airborne aliasing is not high landing

The actual `perform_air_quarter_step` in `mario_step.c:392–510` first queries
the candidate floor and ceiling. The landing branches compare **raw
binary32 next-position Y** against a returned or cached floor height:

| Reached branch | Condition for `AIR_STEP_LANDED` | Resulting movement Y |
| --- | --- | --- |
| New floor is NULL | `nextY <= m->floorHeight` | Cached floor height |
| New floor is nonnull | `nextY <= floorHeight` | New returned floor height |
| Descending into the ceiling/sentinel branch | `nextY <= m->floorHeight` | Cached floor height |

Therefore, if raw nextY is in the high target window and both the effective
new floor and cached floor are below it, none of those branches lands.
An aliased floor query by itself does not return a floor height shifted by
65536. In particular, a low aliased floor plus raw Y67277 is not a landing
on a floor at 67277. The shell water-pseudo-floor override must be accounted
for separately when the riding-shell flag is set; this deduction assumes
the **effective** floor after that override is also below nextY.

The ceiling test is `nextY + 160 > ceilHeight`. At high raw Y with no ceiling,
this can execute against sentinel 20000. For nonnegative vertical velocity
it cancels upward velocity and returns `AIR_STEP_NONE` (or follows the
separate hangable-ceiling condition); for a descending step still above the
cached floor it writes raw nextY and returns `AIR_STEP_HIT_WALL`. Neither
return is `AIR_STEP_LANDED`. A Pedro-style landed return in a cramped
floor/ceiling gap also first needs `nextY <= floorHeight` and sets movement
Y to that floor; it does not remove this inequality.

The landing-dependent remote-slide cancellation remains useful only after
an actual landing-action predecessor. `common_landing_cancels` in moving
source checks steepness/sliding before `INPUT_OFF_FLOOR`, but arbitrary
freefall does not call it. This narrows the proposed “fall through a VPU and
remote-slide at its aliased floor” family under the stated low-floor/cache
premises. It does not prove that all reachable caches are low, rule out a
different interaction, or establish a global height bound.

## Why a delayed shell cancel does not recover through idle

`act_riding_shell_ground` (`mario_actions_moving.c:1203`) checks Z before its
ground step. With Z pressed it stops riding, raises forward speed to at
least 24 and selects crouch-slide. This is the genuine same-update airborne
conversion already observed in the shell experiments. Without that cancel,
`GROUND_STEP_LEFT_GROUND` selects shell-fall, while the stopped-wall result
selects backward ground knockback.

The proposed delayed repair was to keep the high knockback state until its
animation ended, then use Z or analog to obtain a useful ground action.
The actual dispatcher and handlers exclude that **named** repair:

* `check_common_moving_cancels` checks water plunge, stomp, squish and death;
  it supplies no generic Z or remote-slide conversion.
* `common_ground_knockback_action` (`moving:1588`) performs a ground step
  but never calls `align_with_floor`. Its healthy animation-end branch
  selects `ACT_IDLE`; an accepted ledge departure selects airborne knockback.
* The next ordinary `check_common_idle_cancels` invocation
  (`stationary:22`) checks `INPUT_OFF_FLOOR` before ABOVE_SLIDE, analog, B
  or Z. `check_common_action_exits` (`mario.c:1117`) likewise checks
  OFF_FLOOR before walking or beginning a slide, covering the ordinary
  stationary punch/slide-stop exit shortcut.

This conclusion assumes a fresh input preparation still sets OFF_FLOOR
(raw Y more than 100 above the found floor), no earlier interaction replaces
the action, and no earlier guard takes a different path. It does not close
every multi-frame shell history. Merely retaining a ground-knockback action
ID at high Y does not reach the ground-slide alignment code.

## Can another interaction shove before a successful shell mount?

The interaction table and loop (`interaction.c:84–115,1780–1797`) process
Koopa shells before grabbables and stop when a handler returns nonzero.
Successful shell mounting (`1460–1477`) changes action and returns nonzero;
it does not perform the nonmounting shell branch's X/Z push. A Crazy Box
already present in the collision list consequently cannot provide its
later grabbable shove in that same update. Z is processed during later
action dispatch and cannot restart the completed interaction loop.

The earlier handler search gives these precise alternatives and obstacles:

| Earlier interaction | Source behavior relevant to shell conversion |
| --- | --- |
| Igloo barrier | Pushes X/Z and returns false, so its position in the table would permit a later shell handler. The source identifies the igloo barrier as the only object with this interaction type; no stock SSL barrier is supplied by the area's object list. This is not an available stock SSL actor recipe. |
| Bully | Both branches that push Mario return true, so they terminate processing before the shell. The ignored/invulnerable branch can return false but does not push. |
| Ordinary bounce-top / hit-from-below enemy | A bounce can return false, but `bounce_off_object` adjusts Y and gives positive vertical velocity rather than the required X/Z shove. For an ordinary airborne action, this destroys the descending `INT_HIT_FROM_ABOVE` condition for the later shell mount. |
| Breakable | A successful attack branch returns true. A nonattack continuation does not provide the desired pre-mount X/Z push. |
| Grabbable or nonsign text object | Can push, but appears after the shell handler; a successful shell mount has already ended the loop. |

This is a source exclusion of the stated same-update combinations, not a
proof over all cloned behaviors, object corruption or actor histories.
It leaves geometry-driven movement, a different multi-update history and
different starting X/Z as concrete things to test. In the high-sentinel
case the stopped ground quarter itself commits no X/Z, so a recipe relying
on that quarter to carry Mario across the low-pad edge fails before the
retry question is reached.

## The spinning top does not provide the proposed vertical PU lever

A tempting transport idea is to stand at a horizontal-PU copy of the top
and use its rotation to turn a huge X/Z offset into vertical displacement.
The actual top callback (`behaviors/pyramid_top.inc.c:32–64`) changes yaw,
horizontal X oscillation and its own Y; it does not create pitch or roll.
For the ordinary initialized top, the rotation is about the vertical axis.

`apply_platform_displacement` (`platform_displacement.c:94–182`) directly
adds only `oVelX` and `oVelZ`, not `oVelY`. Its rotational branch transforms
the offset through the old and new orientation. For zero pitch/roll, the Y
part is the subtraction/addition round trip `(Y - topY) + topY`; the large
horizontal offset does not couple into Y. This rules out the proposed
pitch/roll lever mechanism for the ordinary pure-yaw top. Binary32 rounding
in that round trip is not silently identified with exact real arithmetic,
and this note makes no bit-exact all-input preservation claim.

This observation does not say that Mario never moves upward while standing
on the top: later floor stepping may snap him to the rising actual surface.
It says that the top's ordinary yaw/platform-displacement call is not the
proposed source of a 65536-unit vertical boost from a distant horizontal
offset. Top capture itself still requires the end-update platform query's
actual Mario Y to be close to the returned floor height; a VPU alias alone
does not satisfy that closeness check.

## Proof boundary and next useful tests

The new [`InkIdleOffFloorGuard.v`](../../proofs/InkIdleOffFloorGuard.v)
checks the US and JP generated idle bodies and proves two local execution
results, exported through `current_ink_idle_off_floor_guard_boundary` in
`MainTheorem.v`:

| Theorem | Exact result | Remaining premises |
| --- | --- | --- |
| `iio_off_floor_returns_before_later_idle_controls` | Every completed execution of the actual idle suffix starting at its OFF_FLOOR read executes the FREEFALL request and returns one. The later idle controls are not reached. The actual selected `set_mario_action` return theorem supplies the return value; its memory effects and trace are retained. | A valid Mario pointer and live input-field load with mask 4 set; the action setter resolves globally; execution has reached this suffix. |
| `iio_actual_idle_prefix_joins_off_floor_return` | Attaches an actually executed four-stage prefix to that suffix, obtaining an execution of the complete generated idle cancellation body and the same return. | The real prefix executes normally and its resulting memory satisfies the suffix's live input premise; the suffix completes. No effects of earlier calls are assumed absent. |

This proves the decisive idle-tail part of the delayed knockback recovery
exclusion. It does not prove the preceding knockback animation reaches idle,
that geometry sets OFF_FLOOR in every possible history, that all earlier
idle guards continue, or that no interaction first changes the action. It
does not assert an unproved final action-field value merely from the
FREEFALL request. The source analysis above separately identifies the
ground-knockback predecessor and the raw-height condition that supplies the
input flag in the selected recipes.

The targeted pipeline build and selected audit passed with the existing
Ubuntu WSL `sm64-item-proof` switch, Coq 8.16.1, CompCert 3.15 and unchanged
6.5 GiB memory limit. The five assumption checks report 9, 7, 4, 7 and 7
allowed existing foundations; the new boundary has seven. Inventory checks
719 sources, and integration finds 553/639 proof modules in MainTheorem's
import closure with 86 standalone-only and no problems. This is not an
all-module full build. The detailed receipt is recorded in
[`instrumentation/ink-high-entry-proof/`](../../instrumentation/ink-high-entry-proof/README.md).
No new axiom, admitted proof, whole-program computation or bare `coqc` is
used. This is a new local guard boundary, not a discharge of the whole-route
reachability obligation.

Existing
[`InkMarioEntryGuards.v`](../../proofs/InkMarioEntryGuards.v) proves the
actual generated-code final-null-floor dispatch stop and LEFT_GROUND
caller-branch exclusion, as detailed in the
[entry proof report](ink-mario-entry-proof.md). Those earlier results do not
prove the shell-recovery guard chain above or global entry impossibility.
[`InkPlatformProducerHeight.v`](../../proofs/InkPlatformProducerHeight.v)
proves the **nonrotating** branch; its zero-rotation theorem must not be
relabelled as a proof of the spinning yaw branch.

The companion [high-air and horizontal-PU support checks](ink-high-support-entry.md)
test the two source deductions directly: high air actions do not land merely
on the aliased low floor, and native horizontal-PU top support does not
produce the proposed vertical boost. Their supplied airborne poses/speeds
remain explicit; their positive controls are supplied ground slides.

The most direct search remains a source-faithful airborne-to-ground
conversion whose low position is actually outside the pad after the fresh
cache is established. Shell-only searches should continue past the gap and
record the next geometry wall resolution, low floor result, top retry,
platform retention and first Area 2 coordinates. A native supported
landing/slide predecessor must similarly be judged by that continuation;
the previously verified landing fragment ends at ordinary `(0,5500,256)`.
For a positive result, high Mario entry, actor delivery and their phase
join remain three separately disclosed obligations.

## Native thrown-box two-update conditions

The same Crazy Box can in principle push on two successive updates: ordinary
grabbable pushing sets no interaction cooldown. The following are source
conditions for testing that repair, not a new handoff witness. The separate
moving-actor runtime studies own their measured search counts, setup edits,
retained continuations and final outcomes; this source analysis does not
replace those records or turn a promising intermediate state into success.

**Ordering matters.** `object_list_processor.c:647–662` updates terrain,
applies platform displacement at654, detects object collisions at658, and
then updates Mario before general actors such as the box (list order at174).
Platform carry therefore happens **before Mario's fresh geometry/floor
query**, not as an additional shove after that cache is established.
It updates movement M; collision detection still uses Mario object's C.
The box position in update129's collision list is its position before its
own129 callback. Motion in that later callback can position it for130.

`jumping_box.inc.c:3–13,43–73` and `obj_set_hitbox`
(`object_helpers.c:2120`) give the ordinary half-scale box radius75,
height125 and down-offset10. Mario's radius is37
(`data/behavior_data.c:3511`). Consequently the collision-list horizontal
test is strict distance **<112**; vertical intervals overlap inclusively.
The box interval is `[boxY-10, boxY+115]`. Grabbable pushing uses padding-5,
so a further push needs movement-position distance **<107** and attempts to
place Mario107 units from the box, subject to wall correction and a nonnull
floor at the proposed X/Z (`interaction.c:616–645,1636–1666`). It retains the
old cached floor. After an ideal first push in direction `u`, the next
movement-position separation is approximately
`107*u + Mario_between_updates - box_between_updates`; it must again be
inside107. Collision-list eligibility using C and actual pushing using M
are separate tests.

`mario_get_collided_object` (`interaction.c:403–416`) returns only the first
matching actor. The processing loop clears that interaction-type bit before
handling it (`1780–1797`), so another grabbable is not tried merely because
the first one's push fails or its interaction status causes skipping. The
four-object collision-list limit also applies (`object_collision.c:26–61`).

**A native throw is not a constant-speed translation.** The HELD_THROWN
callback calls `cur_obj_get_thrown_or_placed(40,20,1)`. The helper makes the
actor tangible/free and selects action1; it queries the floor at
`(boxX,boxY+160,boxZ)`, may clamp Y upward to that floor, and has an out-of-bounds
position fallback before applying the initial Y motion
(`object_helpers.c:1067–1110`). That callback has no X/Z movement. Away from
water and floor correction it advances Y by16. Subsequent active FREE
callbacks apply gravity-4 and componentwise drag before movement: cardinal
speed40 becomes approximately **38.4**, then36.92544. A thrown action1 box
is marked for deletion on wall, water or LANDED flags after its movement
(`jumping_box.inc.c:31–49`); it does not survive as an ordinary repeatedly
bouncing box. The free callback's raw-Y floor query and movement/clamp are
at `object_helpers.c:1740–1815`, unlike the throw initializer's Y+160 query.

There is also a one-update activation issue. `cur_obj_move_standard` skips
motion while FAR_AWAY or IN_DIFFERENT_ROOM is set (`object_helpers.c:1802`).
`cur_obj_update` calculates current distance before running the callback,
but changes FAR_AWAY only **after** it (`behavior_script.c:915–917,989–999`).
A newly near box can therefore skip one FREE movement using the previous
flag. Actual traces must determine which callbacks moved; elapsed updates
alone do not establish the simple motion schedule below.

For one precisely scoped obstruction, take the **old exact supported-landing
fragment**, a throw callback on127, followed by unsuppressed FREE motion on
128 and129, with no floor clamp, wall correction, water effect, other
displacement or early deletion. Let `B129` be box Y used by collision
detection129. In this ordinary local-height range the native Y increments
are16,12,8, so `B128=B129-12` and `B130=B129+8`. Avoiding128 **solely by
placing the box below** the supplied Mario C.Y1837.8726806640625 requires
`B129 < 1734.8726806640625`. Contacting130 after that old fragment's
C129.Y1874.9208984375 requires `B129 >= 1751.9208984375`. These are disjoint.
Thus adjusting only throw Y cannot give that exact fragment a delayed first
contact and second contact under this schedule. Horizontal avoidance of128,
a changed Mario129 height or a different native motion schedule is outside
this narrow exclusion. In particular, the formula is not asserted for a
trace whose first FREE movement is suppressed by FAR_AWAY. No new Coq
proof or build is claimed for this additional source arithmetic.

Inspected source SHA-256 values:

| File under the decompile checkout | SHA-256 |
| --- | --- |
| `src/game/mario_step.c` | `6bbec9d8b20fd7b7fbce0f864b9f311be008a95d2881f024140140f1a9430222` |
| `src/game/mario.c` | `832c5301d3eda065310db5e5e429f6448eeeebcf7226a7e0bf2ac132556b8b1d` |
| `src/game/mario_actions_moving.c` | `63364abba7cd12cb89e47614f901c933334a26654183896448f309fa2d847cfb` |
| `src/game/mario_actions_stationary.c` | `a6ce312eadb4271646643b14c90ca7c6135de9d0846cd7a6a5642972c8501608` |
| `src/game/interaction.c` | `a327202d33612821f884f01b5e4692aa5cfe2003f3b9a2eeb1452ad72725ea00` |
| `src/game/platform_displacement.c` | `7aef24bca5a431495459be5f229bc4a603027e827721e85cb145026bd4c6d923` |
| `src/game/behaviors/pyramid_top.inc.c` | `57b4b8b4895f2e28db80ef67d4f60ae011741273a9f96d8ca526a52e3a4de5fe` |
| `src/game/behaviors/jumping_box.inc.c` | `38ac532512361af15f5e78d89afc02ac349e5a74a6779db27e03cdf1b27545b8` |
| `src/game/object_helpers.c` | `a603370892b2589a97343be38a6fafd86b84279b8413e75ab94cada3719f5818` |
| `src/game/object_list_processor.c` | `203bcde4c5eb638eb1eab93d2d7b2226fda797644e26dc2b26d52c21edf851e8` |
| `src/game/object_collision.c` | `4bdbe3bd3acd72c16738ec93638395a2f0daac4f69f905b76da8eae3384dc234` |
| `src/engine/behavior_script.c` | `941bbbdcda2767d8b3ea33f49ca401c6ce6576754c7ee6ea392792562520738d` |
