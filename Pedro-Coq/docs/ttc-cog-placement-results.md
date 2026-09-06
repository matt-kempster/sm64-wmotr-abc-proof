# Near-cog placement results — 2026-09-06

These experiments implement the user's authorization to start Mario near the
cogs. They use separate initialization-only US/JP builds of pinned source
`9921382a68bb0c865e5e45eb594d9c64db59b1af`. They do not establish normal entry,
and none of the completed trials establishes in-spot RNG control or frozen
cogs. Failed trials are not an impossibility proof.

## Setup and evidence

Only `levels/menu/script.c`, `levels/ttc/script.c`, and
`src/game/level_update.c` differ from the pinned source. The changes select
initial TTC, RANDOM mode, a declared Mario position/yaw, and ordinary idle
initialization. `prepare.py` checks every tracked source file. The cog,
movement, collision, dust, and RNG behavior functions remain stock.

All trials use fresh save/configuration directories, ordinary controller
inputs, and read-only observation. The emulator reports cheats disabled.
Each trial records the ROM, ELF, observer and input hashes, resolved symbols,
initialization manifest, raw log, trace, summary, and screenshot under
`build/cog-placement/`. Newer trials also copy the complete initialization
patch. No ROM or extracted asset belongs in Git.

| Setup | Position | Yaw | Initialization patch SHA-256 |
| --- | --- | --- | --- |
| `ledge` | `(1742,-2088,-125)` | 188° | `6daa97f3c5836c157ceba2d926d57481fd2b17713392845b3b3f4374cb56da91` |
| `cog_back` | `(1428,-2088,-1084)` | 7° | `86492c7d6e6986a9b9822c6a97bbc72447e60d41b0a45e232d4fabedbfad41b7` |
| `edge` | `(1456,-2088,-1178)` | 341° | `02eae5946fc87c2dbd6e76e2c08b60218fc760e527813f8951b4d8650987eaea` |

The supplied video's clock phase and setup provenance are unknown. Rounding
its coordinates and choosing RANDOM mode does not recreate that state.

## Measured outcomes

The ledge initialization is stable in both US and JP. All eight stock cogs
are present and update normally in RANDOM mode. The US neutral trial
`idle_us_02` records 625 initialized-TTC input snapshots. The independent JP
trial `idle_jp` records 225, with the same starting Mario pose and seed 44620.

The US controller trial `approach_us_01` crosses from the ledge onto the lower
cog, including a short fall and ordinary ledge grab/climb. Its final position
is approximately `(1573.26514,-2088,-805.088379)`, with the lower cog as its
floor owner. Continuing toward the video location meets the mesh and the
neighboring cog's side. Wider approaches and several jumps did not produce
a verified Pedro interval. These trials do not exhaust the controller choices
or phases; input-boundary snapshots alone cannot exclude a brief branch event.

The recorded inputs are saved as
`instrumentation/ttc-cog-placement/inputs/ledge-to-lower-cog-us.csv`, with SHA-256
`41e8051053c0e37f8386c2cfc8448566237f9fd940a4cec0e77b415094870ae8`.
`lower_cog_replay_us` replays them without the steering routine and reproduces
all 2250 input/Mario/cog records exactly. Its added call trace has 992 RNG
returns and 31 air-step returns; the recurrence/continuity checker passes,
and no air return takes the Pedro branch. This is an approach replay from the
declared test placement, not a normal-entry replay.

The independent `lower_cog_replay_jp` run reaches the same lower-cog position
using that input file. All its observed logical events agree with the US
replay after excluding raw addresses: 225 input/Mario snapshots, 1800 cog
records, 992 RNG returns, and 31 air-step returns. Its consistency check passes
and it also has zero Pedro branches.

`lower_cog_video_us_clean_log` records the same US replay, capturing every
rendered frame from 350 through 600. The complete extracted trace has the same
SHA-256 as `lower_cog_replay_us`. Two intact controller records followed partial
screenshot notices; the original logs and the earlier incomplete extraction
are retained alongside an extraction receipt. The completeness, recurrence,
and replay comparisons pass. The silent H.264 exports are
`lower-cog-replay-us.mp4` (251 frames at 30 fps, 8.367 seconds) and
`lower-cog-replay-us-half-speed.mp4` (the same frames at 15 fps, 16.733 seconds),
under that trial directory. `video-manifest.json` records frame/video hashes
and encoding commands; both exports decode successfully.

At the `cog_back` initialization, the actual selected floor is cog 0 at
Y=-2088 and the ceiling is cog 3's underside at Y=-1934: the gap is 154.
Mario nevertheless follows the rotating lower cog, then falls. The complete
`back_idle_us` and `back_idle_jp` collectors agree in their observed logical
fields after excluding raw addresses. Each includes 240 initialized-TTC
input snapshots, 985 RNG returns and 426 air-step returns, with zero Pedro
branch occurrences. Call collection continues through the ending transition;
these totals are not a proved TTC-only RNG census.

The controller inputs from the earlier back-of-cog jump attempt were also
exported and replayed with call tracing as `back_maneuver_replay_us`. Mario
falls; its 93 initialized-TTC input snapshots, 415 RNG returns, and 455
air-step returns contain zero Pedro branches. The recurrence and continuity
checks pass. This checks the attempted jump internally, not just at input polls.

At `edge`, Mario begins in freefall with the distant death-plane floor at
Y=-8191, the cog ceiling at -1934, and `INPUT_OFF_FLOOR` set. The neutral
`edge_idle_us` and `edge_idle_jp` traces again agree in their observed logical
fields: 84 initialized-TTC input snapshots, 372 RNG returns, 468 air-step
returns, and zero Pedro branch occurrences. Mario falls. A US dive toward
the cog is knocked back and also fails to enter the branch.

The trace checker verifies every recorded RNG transition against the stock
16-bit recurrence, checks continuity between calls and input snapshots, and
checks the expected position/floor effects whenever the Pedro condition is
reported. The compared trace hashes are:

| Trial | Trace SHA-256 |
| --- | --- |
| `lower_cog_replay_us` | `760bc6606fac5e09ee494c1b008e32e5220f55260b6bea834975abba0b14ce23` |
| `lower_cog_replay_jp` | `c9dd034a608777273273664f57956d0e062419728bad74559ccbf5ffcdef3bc5` |
| `cog_back/back_idle_us` | `9dfa9228fdc65bc9f35983585b29e415ac837e02da6e1d46ed566e824eb3178b` |
| `cog_back/back_idle_jp` | `ddf2dbf42e45595e6cdd55be03dd4582b0c9d34d987750b89be047bd881b0df6` |
| `cog_back/back_maneuver_replay_us` | `9b60651a97378847583b8a16e9e6c48d9eeaaede27aaa3b3e961d385ce59b77e` |
| `edge/edge_idle_us` | `ed98a3ecef1db546c2b608200254c898a3554c044da3e33ec7a224b5f23c4aac` |
| `edge/edge_idle_jp` | `06f21a8d4aee511605e94a17f7b059457e2572992f3370f75cafd7ad2dcfb3b2` |

## Correcting the mesh approach

The user correctly identified that the first video pushes against the mesh.
Its input snapshots spend roughly frames 80 through 180 near X=1415,
Z=-840 to -852. The supplied video's route is already near (1345,-954)
before proceeding toward (1428,-1084). A straight target beyond the mesh
does not provide a route around its end.

The corrected approach first heads toward (1450,-660), then (1320,-720),
and jumps with A on input frames 76 through 80 before turning toward
(1300,-965). This gets around the mesh end and the adjacent cog's side.
The `mesh_back_quick_us` continuation changes target to (1428,-1084) at
frame 115. At frame 130 Mario is approximately
(1455.532,-2088,-1092.210), and at frame 140 he is
(1444.375,-2088,-1123.893), behind the mesh with the 154-unit gap selected.
He is still walking and following the rotating floor. Later he leaves the
edge, grabs/releases a ledge, and falls. This fixes the route obstruction;
it does not establish Pedro entry.

The exported controller sequence is
`instrumentation/ttc-cog-placement/inputs/ledge-around-mesh-us.csv`, SHA-256
`93b39da8eb9a9c8895a2213813c3b5792fa85f2eed4f29a9234a4c9857415775`.
Its US video replay and independent JP replay reproduce the complete
logical trace: 335 controller/Mario snapshots, 2680 cog records, 1474 RNG
returns, 456 air-quarter-step returns and 98 wall observations. Every
consistency check passes; all three runs have zero Pedro branches.

| Trial | Trace SHA-256 |
| --- | --- |
| `mesh_back_quick_us` and `mesh_back_video_us` | `0acb0fbec12b4e2aa0fa919021370251a0df457ab6a76304bfcfe1afab30c0bb` |
| `mesh_back_replay_jp` | `2a457e1af805bf283303e66bcae2a63e8ea2035b6cdc8b9526be6c2b90ee9c91` |

The US capture uses rendered frames 350 through 710. One complete controller
record followed a shorter partial screenshot notice, `Core: Captured s`.
The extraction now recognizes the common screenshot-notice prefix while
retaining the complete canonical controller-record requirement. The original
extraction, raw logs, and extraction receipt are preserved. The repaired
video trace is byte-identical to the original controller trial.
The silent H.264 exports in `build/cog-placement/mesh_back_video_us/` are
`mesh-detour-us.mp4` (361 frames, 30 fps, 12.033 seconds) and
`mesh-detour-us-half-speed.mp4` (the same frames at 15 fps, 24.067 seconds).
Both decode successfully, and `video-manifest.json` records the frame/video
hashes and encoding commands. The footer explicitly labels this an approach
from a test spawn.

Additional checked US trials have no Pedro branch: `mesh_corner_walk_us`
(325 snapshots/31 air returns), `mesh_corner_jump_us` (293/516),
`mesh_back_dive_us` (335/362), `mesh_back_jump132_us` (223/559),
`mesh_back_jump180_us` (335/196), and `edge/edge_inward_us` (152/474).
The trial named `mesh_back_dive_us` presses B while grounded; the observed
action is punching. It is not evidence that a dive inside the spot was tested.
The edge inward trial grabs the ledge and rides it rather than taking the
close-gap air landing branch. These negative trials do not exhaust the
possible routes, phases or actions.

The later `rim` test initialization moves the video-side spawn to
(1456,-2088,-1139), just outside the lower cog's initial boundary at Z=-1138.
Its initialization patch hash is
`24bb81f1f729842fe30eb2c64e0d39652888687857ed6ddf97ba8aa2d0a20f8b`.
`rim/rim_inward_us` has 152 input snapshots, 641 RNG returns, 474 air returns,
zero Pedro branches, and a passing consistency check (trace SHA-256
`a1e600ebda0e728c6fc006b9f2714728553aaebb2659fdf3b225084ed8f9e45c`).
It also grabs the ledge and later falls. Its selected ceiling changes from
the cog underside to a distant static ceiling by snapshot 2. This is
consistent with the stock 400-unit collision distance: the initial distance
to the upper cog is about 397.6, and a four-unit drop increases it to about
400.7. Being close in the horizontal view is insufficient to retain collision.

## Checked inner-rim Pedro returns

The `inner_rim` initialization is (1313,-2088,-1098), yaw 90 degrees, with
patch SHA-256
`d4ba33485e7fb7a17996af5b31c4d48d34763979929ccf035939adf7d6f39c82`.
This point is near the lower cog's initial boundary and farther under the
upper cog. It uses the same initialization-only restriction as the other
placements. The inward controller target is (1490,-873), maximum raw
magnitude 80.

`inner_rim/inner_rim_inward_us_02` completes 125 input frames and records
two genuine close-gap air returns, on frames 0 and 1. It has 600 RNG returns,
two air returns and a passing consistency check. The independently completed
`inner_rim_inward_jp_02` has 65 input frames, 347 RNG returns and the same
two air returns. All 1002 normalized events in frames 0 through 64 agree
with the US prefix; `comparison-65-frames.json` records that explicit window.

On frame 1, the air routine starts at approximately
(1310.93665,-2088,-1096.36145) with retained floor height -8191 and input
`0x0005` (analog plus off-floor). It queries approximately
(1311.34448,-2090,-1094.43018), selects floor -2088 and ceiling -1934,
preserves X/Z and the retained floor, resets Y to -2088, and returns landed.
The preceding input snapshot is `ACT_FREEFALL_LAND`; the air call is again
`ACT_FREEFALL`. With the observed flat referenced floor and inputs, this
agrees with the source's off-floor landing cancellation before dust.

This is a transient local mechanism witness from the declared placement.
The lower cog yaw changes 0 -> 50 -> 150 -> 300; platform motion changes
Mario's position between calls. On the following frame the moving cog
covers the actual position again, and the landing body reduces speed
1.56026542 to 1.52906013. These traces neither hold the cogs fixed nor prove
that the landing body is always unreachable in all cog states. No dust is
requested during the initial Pedro interval.

Two continuations were checked independently in US and JP, with all logical
events agreeing over their complete 65-frame runs:

| Continuation | Input change | Observed outcome |
| --- | --- | --- |
| `inner_rim_dive_us/jp` | B on frame 1 | The second Pedro return occurs during a dive at speed 16.5602646. The next action is dive slide, followed by ground bonk and vertical-star particles. This does not produce landing dust. Three Pedro returns occur overall (frames 0, 1, 46), with 12 air returns and 349 RNG returns. |
| `inner_rim_pound_us/jp` | A+Z on frame 2 | Ground pound begins, Mario moves with the cog and falls. Mist appears only after landing at Y=-4822, well below the cog spot. There are 153 air returns, 409 RNG returns and only the original two Pedro returns. This is not preserving in-spot RNG control. |

| Trial | Trace SHA-256 |
| --- | --- |
| `inner_rim_inward_us_02` | `09a9fd575c60119a9d03366ae08700617e59d8571cc2780b786a57220d71beee` |
| `inner_rim_inward_jp_02` | `5c4bb230033d34d0c0430ac3f33759f32cd73060ad31a1c20c1b6faf9f79dd26` |
| `inner_rim_dive_us` | `3d6183a4100a5ffa455f6cd7914edce129133cdd6b96c932281b41a2dc9af24b` |
| `inner_rim_dive_jp` | `d2fa03845ea30f9b41a9b5b34866d768983203f05b330efb4b3148e97cfad099` |
| `inner_rim_pound_us` | `0a6b7b03dfb6cc6cac37010ea9912947e800fd94e666117ae4662855a984ee26` |
| `inner_rim_pound_jp` | `73842d73a531e01a92b99225e5ffce79263380e5c51174995a43e280fd8fd73a` |

Earlier runs named `inner_rim_inward_us` and `inner_rim_inward_jp` ended with
WSL exit 1 and no launcher diagnostic. Their partial logs are retained and
are not completed checked trials. The completed shorter repeats above supply
the comparisons; no missing observations were reconstructed.

## Consequence for the dust hypothesis

Pinned `act_freefall_land` calls `common_landing_cancels` before
`common_landing_action`. The cancellation helper can select the off-floor
action when `INPUT_OFF_FLOOR` is set. Earlier steep-floor, sliding, first-person,
timer and A-button conditions also matter. Therefore entering
`AIR_STEP_LANDED` does not itself establish that the velocity-dependent dust
code will execute on the following action update.
See [the detailed floor/action analysis](ttc-cog-floor-actions.md) for the
two distinct floor queries and other particle-producing action candidates.

The observed edge initialization really has a far-below referenced floor and
the off-floor input bit. This is a reason to check the cancellation path in a
successful Pedro trace; it is not yet a proof that every cog Pedro state must
cancel, or that all ordinary ways to influence RNG fail. The existing flat
landing speed witnesses assume the relevant landing code is reached.

## Next work

Extend the normal controller approach to a suitable natural cog phase and
the now-observed close-gap air mechanism. Determine
which cog rotations must be preserved at that witness; the video's one-cog
objective and the current two-cog geometry certificate are distinct.

Record the complete action cancellation and ground-step paths before testing
paired dust/no-dust continuations from the same state. If the ordinary landing
path is always cancelled there, prove that limited obstruction rather than
relabeling the existing arithmetic witness as usable in the spot. Normal
reachability, a sound address refinement, complete linked Clight frames, and
an explicit preservation duration remain required for the user's final claim.
