# A frozen shell mounts, but the tested high one-update bridge still bonks

14 November 2026. **A genuinely initialized shell left frozen by native fake
pickup and throw remains mountable. The tested high freefall mounts do not
leave Mario riding on the next update.** Without Z, Mario mounts and enters
ground knockback during the same update. With Z immediately, he enters the
slide/alignment code, but the mount ends the interaction pass before the
later pusher can move him sideways. The selected control takes the ordinary
warp, with no useful displacement. This is a finite local result, not an
impossibility theorem for all shell routes.

The distinction matters: six further controls show that a frozen shell is
compatible with the useful downstream Ink handoff. They mount the frozen
shell on a real low floor, **supply a high Mario relocation**, then let a
black Bob-omb or small box shove before Z. All six capture the top, retain
it during the delay, and reach the displaced spawn. They do not solve the
new proposal's high freefall entry.

## Revisions, evidence and prior work

The fetched starting proof revision was
`162617b708b2244beca85af58b76ad5794e598cd`; the pinned earlier request's
`08df00c605127a172d3a28049e31d6f50f7bff98` records were read as predecessors.
The decompile checkout was `36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`, with
stock JP pin `9921382a68bb0c865e5e45eb594d9c64db59b1af`. This package uses
the existing JP Wafel 0.8.5 DLL, SHA-256
`960fe979068b78e6733b3ddb87741833fbf4eb29b2a21a2bba871977427c2d0f`, and
bundled Python 3.9.13. Individual source hashes are in the result. This is
native-runtime evidence; this package does not claim an original-ROM replay.

The immediate/delayed shell failures and no-ceiling sentinel explanation
already occur in [the high unloaded-top follow-up](ink-high-unloaded-entry-followup.md),
[delayed-shell study](ink-high-delayed-shell.md), and
[high-item nudge record](ink-high-item-nudge.md). The new work replaces a
live shell or synthetic carry profile with the native conditional pickup and
release in [the shell-clone isolation study](ink-shell-clone-isolation.md),
checks its persistent interaction status, varies geometry, and tests whether
the frozen shell can still support the known downstream positive control.

Reproduction package:
[`instrumentation/ink-cloned-shell-bridge/`](../../instrumentation/ink-cloned-shell-bridge/).
Its `results.json.gz` contains every attempted recipe, edit, input, sampled
M/C/G, shell state, floor and ceiling, top loading, warp and platform result.
**M** is movement position, **C** is collision object position, and **G** is
stored graphics `gfx.pos`; G is not where the render matrix draws Mario.
Undecoded event `_placeholder` fields are retained as raw telemetry and are
not treated as decoded movement-step return values.

## What is supplied, and what the game does

The existing after-pillars fixture is retained, using the archived high-item
nudge prefix (uncompressed SHA-256
`9bcc451964025d9f0bb1344c45957b6bfd095451b44bfb9a01f8584a75db6a72`). Its
accepted A-off four-pillar controller prefix is credited to
`ink-buddy-movement/original-prefix.jsonl.gz`; its original debug
level-selection startup grant remains. The experiments below add explicit
state grants after that prefix, so the resulting sequence is not a continuous
controller route to the high setup.
The new preparation is completely recorded:

1. Set the existing shell box's slot32 action to4 and run two neutral updates.
   Its real callback spawns and initializes the shell in slot71.
2. Supply low Mario `IDLE` at `(5900,51,3380)`, and shell XYZ at
   `(6100,51,3380)`. Press B once and release. During the real small-box
   pickup, after update4, retarget `usedObj` once from small box23 to shell71.
   Native pickup grabs on update6 and reaches `HOLD_IDLE` on update17.
3. Press B once for a native throw. Immediately before throw update7,
   supply HOLP `(-1950,H-10,-971)`. Native release places the shell at
   `(-1950,H-10,-939)`. Finish 24 throw updates and wait neutrally for the
   selected top phase. This grants high HOLP and the fake-pickup pointer;
   it is not a controller-produced shell delivery.
4. For the high-entry trials, supply Mario M/C/G at `(-1950,H,-939)`,
   `FREEFALL`, action state/timer0, forward speed20, velocity `(20,-16,0)`,
   face angles `(0,16384,0)`. Native floor queries then refresh the cache.
   No floor, ceiling, platform, interaction status or ridden pointer is set.
5. Where specified, place native black Bob-omb39 at current Mario XYZ plus
   `(-29,0,0)`, or native small box23 plus `(-24,0,0)`. These are position
   grants. Some trials place the actor before the first contact; others
   place it just before the second update. There are no subsequent Mario
   edits in the high-FREEFALL trial family.

All new controls have A released; no held-A dependency is used. The default
clone already stands at its native thrown position before the high Mario cut,
so it receives no extra placement write. Geometry variants and the live-shell
comparison explicitly log additional shell XYZ writes. The live shell starts
from the same initialized native spawn, bypassing fake pickup/release.

The frozen shell has behavior `bhvKoopaShell`, command
`bhvCarrySomething5[1]`, held state0, action0, flags1073741825,
intangible timer0, interaction type524288, radius50 and height50. It has
no solid floor mesh. Its native callback is frozen; the global object
collision and Mario interaction machinery still sees it. These fields are
observed, never assigned by this experiment.

## Finite coverage and outcomes

Heights tested are **25000**, **67277**, and **90536 = 25000 + 65536**.
These are three points, not a demonstrated continuous height interval.
Top phases below mean the stored timer before the next update, with top
action1. Default phase129 advances to130 on the first contact.

| Test family | Coverage | Result |
| --- | --- | --- |
| High freefall, live versus frozen shell | 36 continuations: three heights, two shell states, Bob-omb/small box, Z on first update/second update/never | Every trial mounts; none retains the required high rider at the next update or captures the top. |
| Pusher already present before mount | 12 frozen-shell continuations: three heights, both pushers, first/second-update Z | Mount still ends the pass before the grabbable pusher; no useful handoff. |
| Adjacent timing | 12 frozen-shell continuations: three heights, phase128/130, first/second-update Z, Bob-omb | No useful handoff. |
| Repeated fresh Z presses | Three frozen-shell continuations, one per height, 90 updates | No capture or useful displacement; the Y25000 example is backward air knockback at Y21941 after90 updates. |
| Position/speed/direction | 288 one-update checks at Y25000, live/frozen: X in {-2030,-1950,-1882}, Z in {-1019,-939,-859}, four cardinal yaws, speed in {0,20,60,-20} | All mount and immediately end ground knockback; no high rider bridge. |
| Contact geometry/fall speed | 36 one-update checks at Y25000, live/frozen: shell offset X in {-80,0,80}, Y in {-1,-10,-49}, vertical velocity in {-1,-75} | All mount and immediately end ground knockback; no high rider bridge. |
| Explicit relocated-rider compatibility control | Six continuations: three heights, Bob-omb/small box | All six produce the full split, top capture/retention and useful Area2 displacement. High Mario relocation remains supplied. |

The 69 continuations and 324 geometry checks compare **2,610 sampled update
boundaries**, including six low-mount control updates and excluding the
additional preparation/wait updates. Every recipe and preparation record
was independently reproduced from a second fresh runtime. Some geometry
checks overlap continuation seeds; the total is not a count of distinct
global histories or a probability estimate.

## Exact negative: mount now, pusher and Z next update

Use frozen shell, H25000, phase129, Bob-omb placed before the second update.
Shell status starts0 and becomes `0x400000` (`STOP_RIDING`) on the first
update. `riddenObj` is null at every completed boundary below.

| Boundary | M = C | G | Action; floor/platform |
| --- | --- | --- | --- |
| Supplied start, top129 | (-1950,25000,-939) | Same | FREEFALL; cache inherited until native refresh |
| Contact update, top130 | (-1950,25000,-939) | (-1950,25045,-939) | FREEFALL → RIDING_SHELL_GROUND → BACKWARD_GROUND_KB; fresh floor768, platform null |
| Bob-omb plus Z, top131 | (-1861,25000,-939) | Same | BACKWARD_GROUND_KB; floor768, platform null |
| Next neutral, top132 | (-1861,25000,-939) | Same | BACKWARD_GROUND_KB; fresh floor1280, platform null |

Top surface count remains0 during those updates; ceiling is absent and its
height is the sentinel20000. The shell remains in the collision list on
the second update. Unlike a live shell, its frozen callback never cleans up
the stop status. `STOP_RIDING` alone does not include `INTERACTED`, so the
shell can still run its plain-contact push before the later grabbable
handler. That changes the trajectory, but it cannot make the knockback
handler perform slide floor alignment. The corresponding live-shell
trajectory is different, which is why live and frozen controls are kept
separate.

The precise first failed requirement is **retaining the ground-riding action
until the next input/interaction update**, not mountability, collision-list
membership, or the presence of a solid floor mesh on the shell.

## Exact negative: cancel on the mount update

Use frozen shell, H25000, phase130, fresh Z on the first update. The first
completed boundary has `M=C=(-1950,768,-939)` and
`G=(-1950,25000,-939)`: a real gap of24232. The action sequence is
`FREEFALL → RIDING_SHELL_GROUND → CROUCH_SLIDE → GROUND_BONK`.
Mounting has already ended the interaction pass, so neither a preplaced
grabbable nor a pusher placed next update supplies the needed producer shove.

On the next update the real warp64 is accepted, but M/C/G become
`(-1995,768,-971)`, with floor768 and no platform. After25 updates the game
arrives at ordinary Area2 spawn `(0,5500,256)`. A high G and accepted warp
are therefore insufficient evidence of Ink's useful displacement.

## Exact positive compatibility control, with the missing step exposed

Use the same native fake-pickup/high-throw preparation, phase129. Supply
Mario `FREEFALL` at `(-5862.31787109375,1034,819.5643920898438)` with the
same speed/velocity/yaw as above, and explicitly place the frozen shell10
units below him. The real low floor is1024. One neutral update produces
`RIDING_SHELL_GROUND`, M/C at `(-5841.56201171875,1024,819.5643920898438)`,
G.Y1069, and `riddenObj=71`.

Now **explicitly relocate Mario M/C/G only** to `(-1950,H,-939)`.
Do not edit his action, velocity, ridden pointer, floor or the shell again.
Place Bob-omb39 at `(-1979,H,-939)` (or small box23 at `(-1974,H,-939)`)
and press Z on the top130→131 update. The shell itself remains at the low
control position, so it cannot add a second contact at the high point.

| Boundary for H25000 | M = C | G | Relevant result |
| --- | --- | --- | --- |
| Producer, top131 | (-1882,768,-939) | (-1882,25000,-939) | Bob-omb shove precedes native riding cancellation; fresh floor768; top surfaces0 |
| Warp accepted, top132 | (-1882,1818.9613037109375,-939) | Same | Warp64; high stored-G retry selects floor owned by top61; platform61; top surfaces6 |
| Following update, top133 | (-1863.1396484375,1858.9560546875,-1044.82568359375) | Same | Top61 retained and moves Mario |
| Last Area1 boundary | (-1991.2451171875,1966.6990966796875,-831.4880981445312) | Same | Platform61 and floor owner61 retained through the delay |
| Update25, Area2 | (365.5927734375,5500,-1096.8026123046875) | Same | Useful displaced spawn |

Both pushers give that exact arrival at all three sampled heights. The
producer gaps are24232, 66509, and89768 respectively. This establishes
compatibility of the native frozen-shell state with the downstream mechanism;
the high rider relocation is still the missing gameplay link.

## Source boundary and next useful experiment

In JP `interact_koopa_shell`, above-contact while descending selects
`RIDING_SHELL_GROUND` and returns true, ending interaction processing.
The riding handler checks fresh Z before its ground step. Without Z, a
ground quarter with local floor far below and no real ceiling can stop on
`nextY > floorHeight+100` and `nextY+160 >= ceilHeight`, where the no-ceiling
height is20000. The riding handler handles that wall result by stopping
riding and choosing `BACKWARD_GROUND_KB`. This does not require hitting a
physical wall. Shell body tilt subsequently adds45 to G.Y, explaining the
recorded G value even though the action has already changed.

Ground knockback performs a ground step but not the common slide's floor
alignment. Ordinary later recovery has its own off-floor guards; a retained
action ID is not a substitute for reaching alignment. These source facts
explain the finite results under the stated floor/ceiling conditions. They
do not prove that all possible high supports, earlier interactions, input
histories, or shells outside this geometry must fail. No new Coq theorem is
claimed by this runtime package; generated-code proof work is reported
separately.

The earlier [Y19900 three-actor study](ink-item-native-slide-combinations.md)
is a separate supplied-state success and is not refuted by this menu at
25000/67277/90536. Lower-height action boundaries and compatibility with the
actual frozen shell are examined separately in
[the lower-boundary follow-up](ink-shell-lower-boundary.md).

For the tested higher, one-shell/one-pusher proposal, the most useful next
experiment is a concrete exception to the failed
ordering: a pre-mount interaction that can supply the sideways crossing
after the fresh low-floor query but before the shell's successful handler,
or a genuinely reachable temporary support that preserves riding through
one update. Merely freezing the shell, changing its approach speed, or
moving the mount away from a physical wall does not remove the demonstrated
sentinel guard. Legal shell-slot delivery and high HOLP must be established
separately even if such a local bridge is found.
