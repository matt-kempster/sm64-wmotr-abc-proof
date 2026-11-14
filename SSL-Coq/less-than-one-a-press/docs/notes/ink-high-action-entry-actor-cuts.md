# Native shell predecessor with later actor placement cuts

2026-11-14. This finite extension still finds **no usable Ink handoff**. The
game creates a real butt slide from the supplied airborne Mario/shell state;
later shell and Crazy Box interactions can both push Mario. In this menu they
do not move the grounded Mario into the low pad before top behavior 130.
The next low-cache/warp-producing step is therefore not reached. This is an
observed failure of the recorded menu, not a global route exclusion.

This extends [the high-action entry study](ink-high-action-entry.md). Its
receipt is [ink-high-action-entry-actor-cuts-receipt.json](ink-high-action-entry-actor-cuts-receipt.json).
The companion [moving-box study](ink-moving-box-entry.md) investigates actual
actor motion; this extension deliberately relaxes delivery by supplying actor
XYZ again. It does not claim those placements can be delivered.

## What was supplied and what ran natively

The proof checkout base is `651c180e594e45c6825f9c4800da11f4afef0773`;
JP decompile base is `36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`.
The receipt hashes the actual relevant local source, the Wafel 0.8.5 JP
runtime, Python 3.9.13 input capture, seed receipt and search/helpers. Existing
dirty work was retained. This is native JP Wafel execution, **not a new
original-ROM replay or a Coq reachability theorem**.

The existing authenticated capture reaches the solved-top timing, with its
disclosed debug level selection. Before behavior 125 the shell box's action
is set to 4; two native neutral updates spawn shell slot 69. The initial cut
before behavior 128 supplies Mario's M/C/stored graphics XYZ, FREEFALL action
and reset action state/timer, speed 20, downward vertical velocity -16, one
of four headings, and the shell ten units below Mario. No floor/cache,
platform, collision-list, surface, RNG or allocator pointer is supplied.
The first input is neutral-stick Z; all later inputs are neutral. A remains
unheld and unpressed. The native update mounts/cancels the shell, enters a
slide and aligns Mario to the actual top. No Mario field is edited afterward.

The 892 native BUTT_SLIDE/top-platform seeds before behavior 129 come from
the prior 3,844-seed exporter and have actual M.Y in 1740–1801. Their initial
airborne Y was 21700, an explicit grant, not a reached gameplay state or a
claim that 21700 is a useful low-cache producer height. Before behavior 129
this extension permits only shell XYZ and/or Crazy Box XYZ writes. A second
box XYZ cut before behavior 130 is implemented, but **zero such cuts were
executed**, because the first-stage gate was never reached.

## Bounded menu and result

The target pad interior is X in [-2148,-1946], Z in [-1124,-922], following
the separately checked signed-coordinate boundary refinement. The menu
requires the before-130 ground action to be preserved on this pad, at actual
Y 1740–1801, with no platform. These height and position filters are useful
targets from the existing fixtures, not an exhaustive description of every
usable Ink setup.

| Stage | Coverage | Observed result |
|---|---:|---|
| Native seed replay | 892 seeds | All replayed from the air/shell initializer |
| Box-only cut before 129 | 100 collision-compatible proposals | All 100 registered and changed first-action M |
| Shell-only cut before 129 | 2,673 proposals across 81 selected seeds | All registered; 295 changed first-action M |
| Shell plus box before 129 | 2,673 paired proposals | Both registered in all; box changed first-action M in all; both actors separately changed it in 295 |
| Ground action ending inside the target pad | All preceding actor trials, any Y | 0 |
| Second box cut before 130 | Gate-dependent | 0 executed |
| Top capture or useful Area 2 arrival | Completed selected continuations | 0 |
| Independent fresh replay | 12 complete histories | 432 matching boundaries, including each initial native seed update |

For every seed the single-box proposals aim from the carried position toward
the pad's closest point and a 3-by-3 grid of pad points, using actor distances
1, 30, 60 and 90 from that carried position. They are filtered against the
old raw Mario collision position. For each cardinal heading the shell menu
takes the twelve nearest seeds overall and twelve nearest with an unopposed
post-129 top floor in 1740–1801; deduplication leaves 81 seeds. Shell positions
are the old collision position and radii 40/80 around it at sixteen angles.
For each shell result the paired-box test first tries direct pad proposals,
then executes the best ideal partial shove from radii 20/60/100 around old C
at those sixteen angles. The actual native wall and floor checks still run.
The receipt preserves the exact choices and 295 paired cases in which both
pushes actually changed the first action's M.

## Exact near misses

Here M is MarioState position, C is raw Mario-object collision position, and
D is **stored** `header.gfx.pos`. D is not a claim about the model's visible
render-matrix position. “Before/after 129” refers to the top behavior phase,
not a video frame number.

The closest pad endpoint among the 295 confirmed two-push cases starts with
the supplied air seed `(-1920,21700,-1210)`, heading 0, speed 20, before 128.
After the native Z update, before 129:

- M=C=`(-1920,1799.2869873046875,-1210)`;
- D=`(-1920,21700,-1210)`;
- action=BUTT_SLIDE (`8651858`), floor cache=1799.2869873046875,
  floor owner=top slot 61, platform=61.

The only further writes set shell XYZ to
`(-1956.9552001953125,1799.2869873046875,-1225.307373046875)` and box XYZ to
`(-2012.387939453125,1799.2869873046875,-1248.268310546875)` before 129.
Counterfactual runs from the identical native seed distinguish the pushes:

| Boundary within update 129 | M |
|---|---|
| First action without the new actor placements | `(-2038.5538330078125,1799.2869873046875,-1226.8194580078125)` |
| First action with shell placement only | `(-2045.9375,1799.2869873046875,-1227.08203125)` |
| First action with shell and box placements | `(-2102.875,1799.2869873046875,-1191.162353515625)` |
| End of update 129, M=C=D | `(-2100.150390625,1879.9844970703125,-1182.180908203125)` |

Both actors are in the collision list, and the action is BUTT_SLIDE at each
listed first-action event and the final boundary. The ending floor cache is
1879.9844970703125, owner/platform 61. The combined shove is still outside
the pad; even after the ground step, Z remains **58.180908203125 units short**
of the pad's -1124 edge. Ground movement realigns Mario to a higher actual
top floor. This first fails the geometric pad departure, not shell mounting
again or cancellation into an airborne action. The next two neutral updates
stay on the top, at Y 1886.809814453125 and 1909.45556640625. No fresh 768
cache or warp is obtained. There is no direct floor-return hook at the
first-action event; the table reports actual boundary caches, without
mislabeling a later ground-step cache as an observed earlier query result.

The closest confirmed two-push endpoint that still has Y in 1740–1801 uses
initial air `(-2220,21700,-1170)`, heading 16384. Before 129 M=C is
`(-2220,1796.9307861328125,-1170)`, D keeps Y 21700, and action/cache/platform
are BUTT_SLIDE/1796.9307861328125/top. Shell XYZ is set to
`(-2276.568603515625,1796.9307861328125,-1113.431396484375)` and box XYZ to
`(-2290.710693359375,1796.9307861328125,-1099.289306640625)`.
Unopposed first-action M is
`(-2265.77197265625,1796.9307861328125,-1026.8895263671875)`;
shell-only first-action M is
`(-2265.53857421875,1796.9307861328125,-1025.1175537109375)`;
both first-action M is
`(-2256.368408203125,1796.9307861328125,-997.9501953125)`.
After 129, M=C=D is
`(-2247.393798828125,1792.60595703125,-1000.672607421875)`, BUTT_SLIDE with
cache 1792.60595703125 and top owner/platform 61. X remains
**99.393798828125 units left** of the target pad. Thus keeping a useful
height is insufficient: the necessary horizontal departure is still missing.

## Final velocity refinements

Two bounded follow-ups reused the two exact actor pairs above and tested
six initial air speeds (24, 40, 64, 100, 160, 256) and four cardinal headings
at each initial X/Z: **48 recipes per batch**. Both receipts are in the
[speed-refinement receipt](ink-high-action-entry-speed-receipt.json).

The first batch only changed initial FREEFALL forward/Cartesian velocity
before 128. All 48 natively enter BUTT_SLIDE, remain BUTT_SLIDE after 129,
and execute four logged ground quarters there. None ends on the target pad
at any Y; no second box cut, capture or useful arrival occurs. Eight full
continuations independently match **288 boundaries**. This batch exposed a
setup limitation: initial `slideVelX=slideVelZ=0` is inherited from the
prefix and deliberately not edited. At forward speed 20, shell-Z calls
`mario_set_forward_vel(24)`, initializing slide velocity too; at speeds of
at least 24 that branch is skipped (`mario_actions_moving.c:1208–1213`,
`mario.c:374–381`). These requested high air speeds therefore produce only
actual slide speeds 5.42578125 or 5.431572437286377 after the native slope
update. This first batch is **not evidence about fast native slides**.

The corrected batch moves the initial Mario cut one update earlier, before
behavior 127, to Y=21716. A real neutral-input FREEFALL update runs with no
nearby shell. `update_air_without_turn` natively fills `slideVelX/Z`
(`mario_actions_airborne.c:242–249`). Only the shell is then positioned at
actual Mario XYZ with Y minus 10 before behavior 128, and Z is pressed.
The same actor XYZ cuts follow before 129. **There are no Mario edits after
the initial airborne cut before 127**, and A remains clear throughout.

The descending ceiling-sentinel step moves Y from 21716 to 21700 and causes
SOFT_BONK at initial speed 24 or BACKWARD_AIR_KB at the higher speeds. The
latter retain native horizontal slide velocity and descending vertical
velocity; shell contact still natively mounts and cancels into BUTT_SLIDE
in all 48 cases. All 48 still fail to end update 129 on the target pad at
any Y. Zero phase-130 actor cuts are executed, and no capture or useful
arrival is found. Eight independently replayed complete histories match
**296 boundaries**, including both native initializer updates. These counts
are additional to the actor-cut table and the first velocity batch.

For initial speed 256 and heading 0 in the first near miss, the real update
127 leaves forward speed 254.64999389648438, slide velocity
`(0,254.64999389648438)` and vertical velocity -20. After shell/Z128, the
stored forward speed is 240.29983520507812, but the slide vector is already
normalized to approximately `(1.43508589,99.98970032)`, magnitude 100.
The helper writes Cartesian velocity **before** normalizing the stored
slide vector: its cap is one update late. The actual update-128 velocity is
`(3.4485089778900146,0,240.27508544921875)`, magnitude approximately 240.30;
the high ceiling stops that update's horizontal step. Update 129 starts
from the retained magnitude-100 slide vector, applies native slope/friction
again, and uses actual velocity `(1.9180240631103516,0,90.58888244628906)`,
magnitude approximately **90.61**. Its incoming forward speed of 240.30 is
therefore not the velocity used by update 129's ground step. Update 129
logs only its first ground-quarter attempt and makes no horizontal
movement beyond the combined push: M becomes
`(-2102.875,1830.177978515625,-1191.162353515625)`, while D retains
`(-2102.875,1799.2869873046875,-1191.162353515625)`. The action remains
BUTT_SLIDE, floor cache is 1830.177978515625 with top owner 61, and platform
is cleared. It still has not reached the pad or a fresh 768 floor cache.
No trustworthy quarter-result/floor-return hook is present; the observation
is the single quarter attempt, unchanged X/Z, alignment and boundary cache,
not an invented result code from a log placeholder.

The corrected batch's closest pad endpoint uses the second near miss,
initial speed 256 and heading 16384. It ends update 129 at
M=C=D=`(-2192.284423828125,1847.39208984375,-999.306396484375)`, BUTT_SLIDE
with floor cache 1847.39208984375 and top platform 61. It remains
**44.284423828125 units left** of the pad. Thus this corrected menu really
tests native velocity initialization, including magnitude-100 slide vectors,
but the tested speed/heading changes still do not bridge the geometry.

## Carry ordering and the horizontal-PU branch

The local JP source places `apply_mario_platform_displacement` before
`detect_object_collisions`, followed by non-terrain updates (including Mario's
geometry/cache refresh and actions), and finally `update_mario_platform`
(`object_list_processor.c:626–670`). Carry therefore cannot itself be the
post-cache push that preserves a previously selected low floor. It moves M
before the fresh geometry query. The object collision list still uses old C.

`platform_displacement.c:91–169` applies platform X/Z velocity and rotation
to M; it does not copy C/D, and platform vertical velocity is not directly
added. The native top's pitch, roll and their angular velocities are zero;
the behavior uses yaw. In the ideal matrix calculation yaw preserves the
large horizontal radius about the actual top, rather than sending a
horizontal-PU point back to the nearby real warp. That is source-level
geometry, not a formal all-Float32 coordinate bound. No large inward term
appears in this named yaw-only mechanism. The companion
[high-support study](ink-high-support-entry.md) actually tested eight natural
PU top landings: they install the pointer, but the next update loses top
collision loading, changes to a local floor, and clears the pointer. Those
finite results do not establish that a different history with another large
movement cannot return from a PU.

`update_mario_platform` also compares **raw** C.Y with the returned floor
height and needs absolute distance below 4 (`platform_displacement.c:22–69`).
An aliased low floor does not by itself install a platform at an equally
shifted high VPU Y. This separates an equivalent terrain query from actual
support, retention and warp contact.

In the two-actor test, the shell's nonmount handler can push and return
false, allowing the later box handler (`interaction.c:1459–1482,1634–1666`).
Its push radius is 50+37+2=89; the box's is 75+37-5=107. Actor registration
uses the respective 87/112 radii about **old C**, while push direction is
computed from carried M (`interaction.c:616–647`). That difference limits
which shoves can be arranged. For a center B strictly inside the collision
disk around C, an M outside that disk has positive
`(M-B) dot (M-C)` in ideal arithmetic: its radial push points outward from C.
This helps explain why extra registered actors need not reverse the carry.
Wall corrections, binary32 arithmetic, different predecessor geometry and
later movement prevent treating this observation as a global exclusion.

The next specific experiment is to change the earlier landing phase or
landing X/Z so that immediately before actor handling carried M is closer
to the pad while old C still admits actor centers on the useful push side.
Measure old C, carried M, actual slide velocity and fresh floor first, then
repeat the same actor-only feasibility cuts before attempting delivery.
The corrected velocity menu already tested a real earlier air update;
repeating a larger speed or box grid around the same two pairs is not the
most informative next step. Different earlier geometry remains open.

## Reproduction and limits

Run `instrumentation/ink-high-action-entry/actor_cuts.py` with the preserved
capture and a new output path; its companion README gives the command.
It consumes the exact seed file `build/wafel-pilot/ink-high-shell-seeds-20261114.json`.
`preserve_actor_cuts.py` packages the final raw output into the durable
receipt without executing trials. Earlier development outputs remain in
ignored build storage; only the final preserved batch contributes the counts
above. The final rerun added collision-membership/counterfactual diagnostics
and independent histories; it did not enlarge the final actor menu.

No clean Mario entry history, actor delivery, joined route, original-ROM
replay or new Coq result is supplied by this extension. Its contribution is
a native action predecessor, a tested later two-type push mechanism, and an
exact first failed condition before a useful Ink installation.
