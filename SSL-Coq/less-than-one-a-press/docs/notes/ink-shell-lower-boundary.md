# Lower shell mounts and the separate Y19900 sequence

14 November 2026. The user's quoted “dot” review correctly distinguishes two
routes. **Lowering the mount does not repair the tested one-update grounded
riding bridge. But the existing immediate-Z, Box+Buddy, Box sequence works
at Y19900 with a genuinely initialized frozen shell too.** Its initial
airborne pose and actor placements remain supplied. This is a new clone
compatibility check of the credited older sequence, not discovery of its
original live-shell success or a clean controller route.

## The small lower-height test

The [high clone preparation](ink-shell-clone-isolation.md) creates a real
initialized shell, retargets one real small-box pickup, and performs a native
throw using supplied high HOLP. No shell type, dimensions, tangibility,
status or ridden pointer is assigned. The lower-height package preserves
the same grants, including debug level-selection startup, shell-box action4,
low pickup pose, `usedObj` retarget, and high HOLP.

For each listed height H, the shell is already at `(-1950,H-10,-939)` before
the supplied Mario cut. Mario starts `FREEFALL` with M=C=G=`(-1950,H,-939)`,
forward speed20, velocity `(20,-16,0)`, yaw16384, and state/timer0, before
stored top timer129. One neutral update mounts it. Before the next update,
native Bob-omb39 is placed at current M plus `(-29,0,0)` and Z is pressed.
All later pads are neutral. No later Mario writes occur. G is Stored
Graphics (`gfx.pos`), not the visibly rendered model position.

| Initial movement Y | Action after mount update | Native ridden pointer | Following Bob-omb + Z | Useful handoff |
| --- | --- | --- | --- | --- |
| 1741; 1800 | BACKWARD_GROUND_KB | Null | Remains knockback | No |
| 19839 | RIDING_SHELL_FALL | Shell71 | Still shell fall | No |
| 19839.998046875 | RIDING_SHELL_FALL | Shell71 | Still shell fall | No |
| 19840; 19900; 20000; 21777 | BACKWARD_GROUND_KB | Null | Remains knockback | No |

`19839.998046875` is the preceding binary32 value below19840. These are
finite points in this geometry, not an interval theorem. Under the stated
low-floor/no-ceiling conditions the source guard is proposed Y+160 >=20000,
so the nominal boundary is19840, inclusive. The two tested points just below
it take LEFT_GROUND instead of the ceiling stop. The shell remains attached,
but the action is airborne. `act_riding_shell_air` performs an air step;
Z does not run the ground riding handler's crouch-slide cancellation.
The low1741/1800 examples have local terrain/ceiling effects and are not
evidence of a global19840 threshold for every surface configuration.

For H19839 the first two completed movement positions are
`(-1946.6668701171875,19839,-939)` and
`(-1860.1702880859375,19839,-939)`. For H19840 they are
`(-1950,19840,-939)` and `(-1861,19840,-939)`. The native action changes,
cache, ceiling, actor status and complete continuation are in the artifact.

A ninth control uses H19900 and immediate Z at top130, at the high study's
fixed X/Z. It becomes BUTT_SLIDE on the actual moving top at
`(-1950,1914.344482421875,-939)`; the tested next Bob-omb cut does not complete
the handoff. That failure is specific to this recipe, not an exclusion of
the separate successful sequence below.

## Reusing the older Y19900 multi-actor success with the frozen shell

The predecessor is [Native slide entry with a Crazy Box and Bob-omb
Buddy](ink-item-native-slide-combinations.md), recorded before this study.
Its original-X/Z controls already succeed from supplied initial air
Y19900,20100,21700 with a live shell; its corrected low-X/Z version succeeds
at1810 and1830. Those are initial airborne heights. They must not be
confused with the movement Y just before the final gap-producing step,
which is about1830 here, or the separate fixed-setup crawl/slide height maps.

This new test starts with the same real fake-pickup/high-HOLP-throw shell
used above, frozen at `bhvCarrySomething5[1]`. At top128, supply Mario
M=C=G=`(-1920,19900,-1210)`, FREEFALL, speed20, velocity `(0,-16,20)`,
yaw0 and state/timer0. Explicitly place that released shell at
`(-1920,19890,-1210)` and press Z. This shell-position correction is a grant;
the high throw alone does not deliver that exact X/Z. There are no later
Mario writes or shell writes. Native mount and immediate cancellation put
Mario into the actual slide on the moving top.

Then reuse the exact previously recorded XYZ-only actor placements:

- Before top129: Crazy Box49 at
  `(-1990.710693359375,1799.2869873046875,-1280.710693359375)` and Buddy15 at
  `(-2054.455810546875,1799.2869873046875,-1208.867919921875)`.
- Before top130: move that same Box49 to
  `(-2117.125244140625,1830.177978515625,-1128.1343994140625)`.
- Every later pad is neutral, A always released.

| Completed boundary | M=C | G.Y | Result |
| --- | --- | --- | --- |
| Top129 | (-1920,1799.2869873046875,-1210) | 19900 | Native BUTT_SLIDE on top; initial high G retained |
| Top130 | (-2140.031982421875,1830.177978515625,-1115.0291748046875) | 1799.2869873046875 | Box then Buddy push into the intermediate position |
| Top131 | (-2210.062255859375,768,-1075.10888671875) | 1830.177978515625 | Fresh floor768; productive gap1062.177978515625 |
| Top132 | (-2210.062255859375,1906.03515625,-1075.10888671875) | 1906.03515625 | Warp64 accepted; floor owner/platform61 |
| Area2 arrival | (365.5927734375,5500,-1096.8026123046875) | 5500 | Useful displacement after top retention |

Removing only the Buddy129 placement does not capture the top or produce
useful displacement during the checked36 updates. All actors exist in SSL
Area1, but the record does not deliver Buddy, establish high HOLP, reach the
initial airborne pose, or replace the roughly198-unit second Box relocation
with allowed gameplay. The shell here needs no solid collision mesh, while
the real moving pyramid top supplies the temporary floor after cancellation.

## Evidence and reproduction

The new JP Wafel menu has eleven continuations and378 sampled boundaries,
independently reproduced from two fresh roots. The source, input prefix,
runtime version and starting revision are the same as the
[main cloned-shell bridge study](ink-cloned-shell-bridge.md): proof start
`162617b708b2244beca85af58b76ad5794e598cd`, Wafel0.8.5/Python3.9.13, stock
JP source pin `9921382a68bb0c865e5e45eb594d9c64db59b1af`.
`instrumentation/ink-shell-lower-boundary/` preserves all setup writes,
native action events, M/C/G/cache/object/platform snapshots and controls.
The matched original-JP positive/no-Buddy checks are documented separately
in [the ROM report](ink-shell-lower-boundary-rom.md).

This corrects any impression that Y25000 is a minimum shell-entry height
or that every lower shell route is excluded. It leaves the tested delayed
Bob-omb plan without its required grounded-rider predecessor, while retaining
a real conditional immediate-cancellation alternative. The next useful
work on that alternative is replacing the actor-placement and initial-air
grants, especially Buddy delivery and the second Box shove. Merely lowering
the mount does not remove those requirements.
