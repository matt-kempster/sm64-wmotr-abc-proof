# Native moving-box predecessor comparison — 2026-11-14

The bounded moving Crazy Box experiment did **not** produce a usable Ink
handoff. The closest selected native landings remain too far from the low
pad for the proposed single shove. The actual thrown box also clamps upward
on release and, in these histories, delays its first free movement because
the previous far-away flag is still set. Most tested boxes then break on
landing before the intended second shove. These are failures of the stated
finite setups, not a proof that all moving-box routes fail.

This study complements, and credits, the native shell-entry seed export in
`instrumentation/ink-high-action-entry/seeds.py`. The shell seeds enter a
ground slide through actual shell interaction/cancellation; no ground-action
ID is written. The separate low landing/ordinary-warp fragment is not counted
as a successful handoff here.

## What was supplied and run

The existing 2,548-input, A-off JP prefix reaches the top sequence. Its
pre-game debug level-select grant remains an assumption. Shell preparation
sets the existing shell box's action to 4 before top update 125 and runs two
neutral updates, producing shell slot 69. That box break is supplied, not
controller-reached.

For each native throw test, the only Crazy Box cut is before top update 127:
its XYZ, move yaw, and `HELD_THROWN` state are supplied in slot 49. The real
throw callback releases it and initializes forward speed 40 and vertical
speed 20. This is a **native release diagnostic**, not a HOLP delivery or a
player-thrown-box witness. No further box writes occur.

Before update 128, Mario's XYZ in M/C/D, FREEFALL action/state/timer, yaw,
forward speed 20, and velocity with vertical component -16 are supplied.
For shell trials only, the already-created shell's XYZ is also placed at
Mario's X/Z and ten units below his supplied Y. The first input is Z with a
neutral stick in shell trials; ordinary-air trials use neutral input. All
later inputs are neutral, all are A-off, and there is no held-A dependency.
There are no Mario edits after this cut. No floor, ceiling, platform,
collision list, top state, RNG, or allocator pointer is written.

The final run is `build/wafel-pilot/ink-moving-box-entry-20261114-final.json`,
preserved byte-for-byte as [the receipt](ink-moving-box-entry-receipt.json).
The [script](../../instrumentation/ink-moving-box-entry/search.py) records
every setup field, inputs, M/C/D, floor owner/cache, platform, action, top
phase, frame events, and actor fields for ten retained full histories.
All 160 screened recipes and their first four observations are also saved.
Object-slot reuse is explicitly tracked with `isJumpingBox`; slot 49 after
box destruction must not be mistaken for a surviving Crazy Box.

## Finite coverage and the first missed condition

The seed menu comprised all 892 exported shell seeds at supplied raw Y=21700
plus 800 ordinary-air proposals. For ordinary air, the script inspected the
actually loaded top planes on the 20-unit X/Z grid X=-2180 through -1740 and
Z=-1180 through -800, retained proposed upper heights 1640–1830, supplied
Y one unit above the plane, and used four cardinal yaws. Native execution,
not the geometric proposal, determined landing and cache results.

Of 1,692 seeds, 1,066 natively had a top-supported FREEFALL_LAND or BUTT_SLIDE
state with M.Y in [1740,1801] before update 129: 174 ordinary-air and 892
shell cases. Of these, 569 still had an unopposed top cache in that interval
after update 129. That later cache is not assumed to be the cache of the
actor-perturbed trial.

The proposed target menu covered eight points in the pad's northeastern portion:
(-1946,-922), (-1948,-924), (-2044,-922), (-2042,-924), (-1946,-1020),
(-1948,-1018), (-2044,-1020), and (-2042,-1018). For each retained seed the
script read both old collision C and Mario's position after native platform
carry. No candidate passed both the proposed radial shove and old-C actor
overlap requirements. This is only a finite proposal filter; it does not
exclude other target points, velocities, actors, or earlier interactions.

| Selected nearest NE predecessor | Supplied FREEFALL position | Native C before129 | Carried M before129 action | Distance to (-1946,-922) |
|---|---|---|---|---|
| Ordinary air, yaw 49152 | (-1920,1777.650269,-820) | (-1924.912476,1800.403931,-820) | (-1825.965942,1800.403931,-899.817078) | 122.066609 |
| Shell mount/Z, yaw 0 | (-1900,21700,-850) | (-1900,1800.878174,-850) | (-1821.919067,1800.878174,-938.601807) | 125.186652 |

Both distances exceed the box push target radius 107. Even a proposal that
only pushes 106 units toward that corner puts the box 127.780219 or
118.853709 units from old C, respectively, outside the 112-unit collision
list threshold. These numbers describe the selected one-box proposal, not
a bound on a sequence of different interactions. The stricter filter that
also required an unopposed low cache after129 gave minima 143.251640 and
143.413449; those stricter figures must not be substituted for the table.

Despite this failed geometry filter, the final native screen tested the two
nearest predecessors. For each it used 16 evenly spaced throw yaws and five
initial vertical separations (114,108,100,80,0), for **160 trials / 800
updates including release**. Thirty retained a top cache in [1740,1801]
after129. None produced floorY=768 with a gap over 800 after130, captured
the top with the warp, or demonstrated useful Area 2 displacement. The box
was inactive after129 in 147 cases (69 air and 78 shell). Ten complete
33-update continuations were independently rebuilt and compared, including
release, for **340 matching boundaries**. All ten remained in Area 1.

## An exact native throw failure

Take the shell predecessor above. Before127 supply box
(-1859.327881,1658.878174,-938.734436), yaw16384, HELD_THROWN. The callback's
floor lookup at boxY+160 clamps it to the top before adding vertical motion:
after127 its actual Y is1842.056274, not the proposed low trajectory. Its
forward speed is40, vertical speed16, and active flags259 (0x103).

| Top update processed | M=C after update | Stored graphics D | Action | Floor Y / owner / platform | Original box |
|---|---|---|---|---|---|
| 128 | (-1900,1800.878174,-850) | (-1900,21700,-850) | BUTT_SLIDE | 1800.878174 / top / top | Still at release XYZ; vY16, forward40 |
| 129 | (-1745.658569,1758.326050,-919.874573) | same as M | BUTT_SLIDE | 1758.326050 / top / top | X=-1820.927856,Y=1873.536011; then inactive |
| 130 | (-1729.358398,1723.112671,-1088.844482) | same as M | BUTT_SLIDE | 1723.112671 / top / top | Destroyed; slot49 has another behavior |
| 131 | (-1815.001221,1698.083740,-1264.640015) | same as M | BUTT_SLIDE | 1698.083740 / top / top | Destroyed |

The large graphics/movement split at128 is not useful: collision is still
high above the actual warp and the floor cache belongs to the top. Stored
graphics means `gfx.pos`, not the visible model's render matrix.

The unchanged box at128 is explained by actual behavior-script ordering.
`ACTIVE_FLAG_FAR_AWAY` from the previous remote Mario state is cleared only
after the callback; `cur_obj_move_standard` therefore skips this first free
movement. It can move at129, where moveFlags8193 includes LANDED and the
thrown-box behavior destroys it. This specific stale-flag delay depends on
the supplied release/air-cut history; it is not asserted for every genuine
nearby throw. There is no general push cooldown behind this failure.

The ordinary-air control with yaw0 release uses box
(-1824.982544,1658.403931,-938.035400). It natively lands at the table's
1800.403931 before129, but after129 is still FREEFALL_LAND at
(-1835.578247,1845.276611,-893.394470), with top cache1845.276611; its box is
also destroyed. This control fails before a useful low-cache producer.

## Evidence limits and next discriminating experiment

These runs use the existing JP Wafel runtime, not a new original-ROM replay.
They produce no complete controller route, no usable actor delivery, and no
change to the open route assessment. No Coq theorem was added for this
finite experiment. A general impossibility claim would need to cover
different supports, phases, velocities, multiple interaction types, and the
native actor-delivery history; this search covers none of those globally.

The subsequent [two-actor feasibility study](ink-high-action-entry-actor-cuts.md)
tests distinct interaction types: a nonmounting shell shove followed by a
Crazy Box shove on a native supported slide. Both can actually shove Mario,
but its finite menu and corrected native-speed refinement still fail to
reach the pad. These actor cuts isolate Mario-side geometry without
establishing delivery. Different earlier support geometry remains the next
target; actor delivery would still have to replace the cuts in any success.

Proof base: `651c180e594e45c6825f9c4800da11f4afef0773`.
Decompile HEAD: `36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`, with pre-existing
local instrumentation. The receipt records exact source and helper hashes.
JP DLL SHA256: `960fe979068b78e6733b3ddb87741833fbf4eb29b2a21a2bba871977427c2d0f`.
Prefix SHA256: `9bcc451964025d9f0bb1344c45957b6bfd095451b44bfb9a01f8584a75db6a72`.
