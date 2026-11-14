# High airborne Mario and the yaw-only top: bounded entry checks

14 November 2026. **These comparisons do not find a new usable Ink entry.**
The high window often does provide the fresh low floor cache, but native
freefall, B-dive and Z-ground-pound do not become the required ground slide
there. A separate horizontal-PU support experiment really acquires the top
without editing its platform pointer, but the native top rotates only about
yaw and does not convert that horizontal offset into a high raw Y.

This is a deliberately small follow-up to the existing height map and
native-landing predecessor. It does not repeat the previous broad low-top
search, and it does not call an ordinary warp a useful handoff.

## Environment and supplied state

Proof base: `651c180e594e45c6825f9c4800da11f4afef0773`.
Decompile checkout: `36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`, with
existing local changes. The receipt pins the four relevant source files.
Runtime is Wafel 0.8.5 JP, DLL SHA256
`960fe979068b78e6733b3ddb87741833fbf4eb29b2a21a2bba871977427c2d0f`,
using the established 2,548-input four-pillar prefix, SHA256
`9bcc451964025d9f0bb1344c45957b6bfd095451b44bfb9a01f8584a75db6a72`.
Its disclosed pre-game debug level selection remains an assumption.
No new original-ROM replay or Coq theorem is claimed here.

For the high-air comparisons, before native top behavior130, supply M=C=D
`(-1950,Y,-939)`, `ACT_FREEFALL`, action state/timer0, forward speed20,
velocity `(20,vy,0)` and facing `(0,16384,0)`. The main cases also supply
Crazy Box49 XYZ `(-1989,Y,-939)`. Its other fields retain their native values.
No floor/cache, ceiling, platform, top phase, surface or RNG is supplied.
The guard permits only controller writes after this initial cut. A remains
released in every tested update, with no held-A dependency.

The six Y values are21777,21778,25000,32767,67277,67536. For each, test
vy=-16,+16,+64 with neutral, B or Z input on the first update, then neutral.
Each Y also has a neutral vy=-16 control without a nearby box. This gives
60 high-air recipes. The B and Z transitions are native action executions,
not supplied dive/ground-pound action numbers.

## A low cache alone does not land airborne Mario

All50 high-air recipes at Y>=21778 refresh the initial floor to768; the ten
Y21777 recipes still select the loaded upper face at1914.344482421875.
Thus the integer lower bound in the old default fixture remains21778,
not21777. Its previously tested adjacent-float transition is recorded in
[the height map](ink-height-map.md), not newly enumerated here.

None of these60 six-update screens executes a crawl or common ground-slide
action. The eight retained high-air continuations remain negative through
33 updates. Selected observations with the nearby box are:

| Supplied start and first input | After behavior130 | Cache and consequence |
| --- | --- | --- |
| Y21778, vy=-16, neutral | M=C=D `(-1882,21762,-939)`, soft bonk | Fresh floor768, no top surfaces; no alignment to768. As Mario descends, the top can load again next update. |
| Y25000, vy=+16, neutral | M=C=D `(-1882,25000,-939)`, freefall | Floor768 and no-ceiling20000; upward velocity is stopped, but Y is not snapped to the floor. |
| Y25000, vy=+64, B | M=C=D `(-1882,25000,-939)`, dive | Next update becomes backward air knockback; no grounded dive-slide. |
| Y25000, vy=-16, Z | M=C=D `(-1882,25000,-939)`, ground pound | This is the airborne ground-pound action, not a common ground slide. |
| Y67277, vy=-16, neutral | M=C=D `(-1882,67261,-939)`, soft bonk | Fresh floor768; aliased terrain does not move the local floor to VPU height. |

`perform_air_quarter_step` first compares raw next-position Y with the
returned floor height. A floor miss can instead compare that same raw Y
with the current cache. With a nonnull low floor and raw high Y, neither
landing test is satisfied. The no-ceiling sentinel at20000 does not create
a high support: upward ceiling handling zeroes vertical velocity and returns
without committing a higher position; descending handling preserves the
next raw Y unless it is already at/below the cached floor.

These are the actual source branches at `mario_step.c:388–466`. Freefall's
B and Z transitions are at `mario_actions_airborne.c:525–548`; dive enters
grounded dive-slide only on its landing result around lines746–770. The
screen records native fields and action events, not an internal floor-query
or quarter-return breakpoint. It does not exclude another action conversion,
another incoming cache, or another actor history.

## A horizontal-PU top support does not give a vertical boost

The second menu starts before behavior128 with the earlier exterior air
pose M=C=D `(-1930,1837.8726806640625,-880)`, freefall, vy=-16, four cardinal
facing yaws and forward speeds20,262145,524289. Horizontal velocity matches
the facing and speed. No box is moved. The high speeds are explicitly
supplied; neither speed acquisition nor the initial approach is solved.

The eight high-speed cases land on a terrain alias while the top surfaces
were loaded at the start of that update. End-update floor selection really
acquires platform61, with no platform-pointer edit. For example, yaw16384
and initial speed262145 land at
`(63605.9140625,1843.8236083984375,-880)` in FREEFALL_LAND, with top floor
and platform61. The next update has zero loaded top surfaces, uses local
floor1280, cancels the landing action into freefall/air knockback and clears
the platform. Y remains around1844, not21778 or a positive VPU.

The source explains why the tempting vertical-boost proposal is inapplicable
to this actual top. `bhv_pyramid_top_spinning` changes yaw and center Y; its
native pitch/roll and pitch/roll angular velocities stay zero. Meanwhile,
`apply_platform_displacement` adds only platform VelX/VelZ, not VelY. Its
pure-yaw matrices leave Y with the subtract/add center round trip. Horizontal
PU offsets therefore do not turn into vertical displacement on this support.
This is not a proof of arbitrary-float bitwise Y identity: subtract/add
rounding can matter, and other platforms may have pitch or roll.

The four local-speed controls retain real supported landing and slide
transitions. In the yaw0/speed20 control, the first landing Y is
1839.883544921875; the next pre-action event has the same Y while X/Z change
to `(-1860.801025390625,-942.794189453125)`. The native top has VelY5 but
pitch/roll0 and angular yaw6144. Subsequent floor following can change Y;
that is separate from direct platform carry. For PU cases, geometry retry
may undo the large X/Z carry before the first action event. No unobserved
internal carry position is claimed from those endpoints.

Source anchors: `platform_displacement.c:22–69,90–172` and
`behaviors/pyramid_top.inc.c:32–66`. The existing zero-rotation proof in
`InkPlatformProducerHeight.v` is not silently extended to this yaw branch.

## Positive controls and verification

Two explicitly supplied butt-slide controls at Y25000 and67277, with the
existing box fixture, still produce M/C Y768 and retain their high stored
graphics position. Each captures the top on the accepted warp, retains it
through deactivation and reaches useful Area2
`(365.5927734375,5500,-1096.8026123046875)` after25 updates. These verify the
existing handoff fixture; they are not new action-entry witnesses.

The complete menu contains74 recipes and444 six-update observations.
Eight high-air cases, all12 support cases and both positive controls are
continued up to33 updates or first Area2:22 histories and710 boundaries
match exactly after independent fresh boot/prefix reconstruction. The
[receipt](ink-high-support-entry-receipt.json) retains every recipe, initial
write, input, full sampled state and action/movement event, along with source
and runtime hashes. The `_placeholder` event field is not interpreted as a
quarter result. [Reproduction instructions](../../instrumentation/ink-high-support-entry/README.md)
include the exact command. No random seed is introduced.

The remaining useful search target is an actual action conversion or support
history that reaches the common ground helper at high raw Y and then completes
the accepted warp, top capture/retention and spawning displacement. These
small negative comparisons do not close that global question or change the
project's subjective route estimates.
