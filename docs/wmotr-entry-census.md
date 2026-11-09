# WMotR entry census: every real way into level 31

Status 2026-11-07. Coverage track, goal item 3: from ONE real start
(`StartSat.goal2_start_sat`) to every state the game can be in on its first WMotR
frame. Produced by `python3 tools/entry_census.py --vendor <vendor/sm64>`. Part 1
reads the decomp level scripts as text, because only WMotR's script is clightgen'd.
Part 2 reads the generated Clight. The source-read claims (§1, §4) are marked
**[src]**. Every other claim is the tool's output on `generated/`, or a vm lemma
named in place.

## 1. The ways in

| # | Way in | Lands at | Notes |
|---|---|---|---|
| W1 | `castle_inside` area 2 `bhvWarp` (3002, 2816, 5886), `BPARAM2(0x0A)`, hitbox radius 150; its `WARP_NODE(0x0A, LEVEL_WMOTR, 1, 0x0A, WARP_NO_CHECKPOINT)` | WMotR area 1, node 0x0A | **The only one.** `interact_warp` sets `ACT_DISAPPEARED`, then `level_trigger_warp(WARP_OP_WARP_OBJECT)` runs. After 20 frames `initiate_delayed_warp` calls `initiate_warp(31, 1, 0x0A, 0)`. `sDelayedWarpArg` is 0 because `level_trigger_warp` zeroes it. The type is `WARP_TYPE_CHANGE_LEVEL` (6 ≠ 31). These are exactly `EntryWarp.iw_args`. [src] |

Not ways in. The tool finds `LEVEL_WMOTR` in no other warp, table or call:

- WMotR's own `WARP_NODE(0x0A, LEVEL_WMOTR, 1, 0x0A)`. Its source object is `bhvAirborneWarp`, whose script is `BREAK()`: it never interacts, so it is never a warp source. There is no same-level re-entry and no `WARP_TYPE_SAME_AREA` / `CHANGE_AREA` entry, since WMotR has one area. [src]
- Death, star exit, warp floor, pause exit and game over all leave WMotR: `WARP_NODE_DEATH` goes to castle 0x6D, `SUCCESS` to castle 0x38, `WARP_FLOOR` to castle grounds 0x0A, and game over to file select. No exit re-enters WMotR. [src]
- Credits (`sCreditsSequence`) and the demo list (`bbh ccm hmc jrb wf pss unused bitdw`) do not include WMotR. [src]
- The debug level select (`gDebugLevelSelect`) is never set in a retail build. [src]

**Consequence.** Every real entry runs the same code: the same script, node, spawn
object and spawn type (`bhvAirborneWarp` gives 0x12, so `ACT_SPAWN_NO_SPIN_AIRBORNE`).
Mario's position (-67, 2669, -16), yaw, velocity, action and timer are therefore the
witness's on every entry. `WMotREntry` / `StartTerrain.bm_cells` already read them
off generated code. What can differ is the state the entry **reads** (§2) or
**leaves untouched** (§3, §4).

## 2. Discrete branches the entry code reads

The entry closure is 154 functions: `lvl_set_current_level`, `init_level` and the
15 level-command handlers WMotR's script uses. Its `save_file_*` calls are
`save_file_get_flags` and `save_file_get_cap_pos` (from `init_mario`),
`save_file_get_star_flags` (from `lvl_set_current_level`), and `save_file_exists`
(from `init_level`'s non-warp arm, which is not taken).

| # | Branch | Values on real entries | What it changes at entry | Witness (S-list) | Status |
|---|---|---|---|---|---|
| B1 | `gCurrActNum` (read only by `level_cmd_place_object`: `val7 = 1 << (gCurrActNum - 1)`, then `mask & val7 \|\| mask == 0x1F`) | 0..6. It is 0 from power-on until an act select (main course) or a title demo sets it. A save with key 2 can walk straight from file select to WMotR, so **0 is a real entry**. | Nothing for 1..6: every WMotR `OBJECT` has mask 0x1F, so each is placed. On N64, 0 is also harmless (`sllv` by 31, then `(u8)` gives 0, and mask == 0x1F). | S2: 1 | **FOUND 2026-11-07: act 0 has no Clight execution.** `1 << -1` is UB in C, and CompCert's `sem_shl` is `None` for a shift amount ≥ 32. So the real entry from a fresh boot has no execution in the model. Repair needs an `AVOID_UB`-style rewrite or a 3.2 line, which needs user approval: **reported to main, not done.** |
| B2 | `save_file_get_flags() & (CAP_ON_GROUND \| CAP_ON_KLEPTO \| CAP_ON_UKIKI \| CAP_ON_MR_BLIZZARD)` in `init_mario` | set or clear | `m->flags` = 0 (capless) or 0x11 (`NORMAL_CAP \| CAP_ON_HEAD`). `set_mario_initial_cap_powerup` adds nothing for course 23. | clear (empty save): 0x11 | Generalise: no start-premise component reads `flags` (offset 4) to be checked. |
| B3 | `save_file_get_cap_pos`: cap on the ground in (level 31, area 1) | never | It would spawn a `bhvNormalCap`. The cap pos is set only by `mario_blow_off_cap` (from `act_getting_blown`, i.e. `INTERACT_STRONG_WIND`) and by a cap object already in the level. No WMotR object has `INTERACT_STRONG_WIND`, so this is circular. [src; the census can pin it from `BehaviorScripts.closure_itypes`] | — | Unreachable: no cap object at entry. |
| B4 | `save_file_get_star_flags(…, 22)` | any 7-bit mask | Only `gCurrCourseStarFlags`, read by star objects on later frames. | 0 | No effect on the entry state. |
| B5 | Cannon unlocked (`courseStars[22]` bit 7): `bhv_cannon_closed_init` | set or clear | Nothing at entry. It runs on the cannon lid's first update: if open, the lid deactivates and spawns a `bhvCannon` base at home. | clear | Covered by the general object rows (`obj_w` does not pin `gSaveBuffer`). **Not run** on the witness, so it is a non-vacuity gap. |
| B6 | Wing-cap switch (`SAVE_FLAG_HAVE_WING_CAP`): the 6 `macro_box_wing_cap` boxes | set or clear | Nothing at entry. On the first frame the box is solid (top = a floor rung) or an outline. | clear | As B5. |

## 3. Mario fields the entry never writes (carried from the castle)

Tool §2b. The tool over-approximates writes, so these are certainly carried:
`unk00, input, particleFlags, terrainSoundAddend, intendedMag, intendedYaw,
doubleJumpTimer, slideYaw, twirlYaw, wall, ceil, ceilHeight, floorAngle, spawnInfo,
statusForCamera, marioBodyState, controller, animList, collidedObjInteractTypes,
numStars, numKeys, numLives, health, unkB0, fadeWarpOpacity, prevNumStarsForDialog,
gettingBlownGravity`.

Against the start premise (`mem_ok_lp` ∧ `PhiW` ∧ `plat_still` ∧ `obj_w`):

- **`spawnInfo`, `statusForCamera`, `marioBodyState`, `controller`, `animList`:**
  `init_mario_from_save_file` stores them once at boot, and no other code writes
  them (ffw / MWF comments). They are the same on every real entry, and the witness
  is tethered (`ifs_tether`).
- **`input`:** ffw `ff_Ai` and MWF R1 need the A-pressed / A-down /
  grabbable bits clear. The A bits hold in an ABC run (no A press ever). The
  grabbable bit is the last castle frame's. `update_mario_inputs` zeroes `input`
  every frame, and `interact_grabbable` sets the bit only when
  `able_to_grab_object` holds, i.e. in a dive or punch action. Mario's last castle
  frames are `ACT_DISAPPEARED`, so the bit is clear [src]. All other bits are free.
  To generalise: every `input` with `input & 0x882 = 0`.
- **`wall`, `ceil`: OPEN, the main real-entry risk.** `wmotr_world` asks
  `surface_ok` of both: NULL, or a pointer at an s16 that is a WMotR surface type.
  ffw `ff_Wc0` / `ff_Spl` ask that they are not region blocks and are past every
  global. On a real entry they are the castle's last-frame pointers into the main
  pool. The pool is reused, and the segment loads before `alloc_surface_pools` differ
  per level, so what those bytes hold in WMotR's memory depends on the layout. The
  witness has NULL (boot zero), which **no real entry has** (the castle ceiling is
  above Mario at the light). TRUST row 0.4 already notes this ("Seen at the literal
  entry memory"). The first frame's `update_mario_geometry_inputs` rewrites both
  before any read. Repair: state the start premise with `wall` / `ceil`
  unconstrained, and prove the first frame re-establishes them. That changes the
  capstone's premise (weaker premise, stronger claim), so it goes to main.
- **`health`, `numLives`, `numStars`, `numKeys`, timers and the rest:** to be
  checked per premise component. None is in `ffw_bm_cells`, the height cells or MWF
  R0–R14. Generalise them with a store-keeps lemma (ClearKeep's `gstore_keep` is
  the global-cell analogue).

## 4. Carried globals and residue

Tool §2c lists the globals the entry reads by name and never assigns, among them
`gCurrActNum` (B1), `gCurrSaveFileNum` (1..4), `gSaveBuffer` (B2–B6),
`gNeverEnteredCastle`, `gCurrDemoInput` / `gCurrCreditsEntry` (NULL in play),
`gDebugLevelSelect` (0). Further carried state that the premise reads:

| State | Premise clause | Real entries |
|---|---|---|
| `gControllers` / `gControllerPads` A bits | `ctl_w`, MWF R3 | Clear in an ABC run. |
| `sPlayingInfiniteStairs` | `lvl_w` = 0 | Set only in castle area 2, floor room 6, z < 2540; the warp light is at z ≈ 5886, so it is 0 [src]. |
| `sSourceWarpNodeId` | `warp_w`, only if `sDelayedWarpOp ≠ 0` | `init_mario_after_warp` stores `sDelayedWarpOp = NONE`, so it is vacuous. |
| `gShowDebugText`, `sDebugPage`, `gDebugInfoFlags` bit 0 | `env_w`, `ow_debug` | 0 in retail (no retail writer) [src]. |
| camera.c state (`sSelectionFlags`: Mario- vs Lakitu-cam, chosen with R and carried) | `cam_w` pins pointer cells only | Any. Not read by the premise; it changes the first frames' camera path (labeled camera row). |
| `gRandomSeed16`, `gGlobalTimer`, `gAreaUpdateCounter` | not read (MWF R8: `gGlobalTimer` is not a pointer) | Any. They change object behaviour on later frames (general rows). |
| **Residue:** free `gObjectPool` slots, surface-pool slots past the allocated count, the reused main pool | MWF R7 (SafeB load-closed: every pointer in a SafeB block aims at SafeB); `obj_w`'s free list | The castle's bytes. The witness has boot zeros. Whether R7 holds of the castle's residue is a fact about castle frames, which nothing proves. **OPEN.** |
| **Layout:** the anim DMA buffer is a `main_pool_alloc` (game_init.c), so under TRUST 3.6 it sits in the same block as the surfaces and the Camera | ffw `ff_D2` / `ff_Dbt`, `anim_apart`, `cam_w` ("not the animation buffer's block") | The witness's S7 gives the buffer its own block. In 3.6's one-block model the block-granular "apart" clauses fail. **OPEN**, tied to stand-in S7. **Floor check (2026-11-08):** the same failure hits `m->floor`. `ff_Wf` (`wfl`: the floor is a `wblk`, off the regions) and `Wff`'s surfaces sit in WMotR's surface pool, i.e. in the main-pool block, which is also `fw_bt`'s block. They are off the regions only because S7 splits the buffer out. Unlike wall / ceil, the floor IS read (FrameSplit's NULL check, the floor type and height), so it cannot simply be dropped. The repair is byte-range regions (the buffer's 0x4000 bytes, not its block) in `ff_rl` / `rblk`, or a separate-block refinement of 3.6. |

## 4b. Act 0: the two options (decided 2026-11-07: (a))

The user approved option (a), implemented as `1 << ((gCurrActNum - 1) & 31)`, which
spells out sllv's mod 32 directly (it equals the ternary below at acts 0..32).
S2 (`gCurrActNum := 1`) stays as the witness's act.

- **(a) An `AVOID_UB`-style rewrite** of `level_script.c:436`, for the proof build
  only:
  `u8 val7 = 1 << (gCurrActNum - 1);` becomes
  `u8 val7 = (gCurrActNum >= 1) ? (u8)(1 << (gCurrActNum - 1)) : 0;`.
  It agrees with the N64 at every act number:
  - at act 0, IDO emits `sllv`, which shifts by the low 5 bits of -1 (31). That
    gives `1 << 31` = 0x80000000, and the `u8` store truncates it to 0;
  - at acts 1..6 both forms give the same value.
  The test that follows, `(mask & val7) || mask == 0x1F`, places every WMotR
  `OBJECT`, since each one's mask is 0x1F. The rewrite would join the 2.x
  preprocessing register as one row.
- **(b) Act 0 out of scope.** A short named TRUST line: "the theorem covers WMotR
  entries with `gCurrActNum` in 1..6, i.e. after some act select or title demo
  since power-on. Act 0 has no Clight execution (C UB, `level_script.c:436`)."

## 4c. Decisions (main, 2026-11-07)

- **wall / ceil (§3): approved.** The start premise leaves `m->wall` / `m->ceil`
  unconstrained, and frame 1's `update_mario_geometry_inputs` re-establishes them.
  The first step is to check, from the generated code, that nothing in frame 1
  reads either one before that call.
- **Residue vs R7, and the anim buffer's block (S7): known gaps, next in line**
  after chunk 3.

## 4d. Remaining queue (coverage track, handed back 2026-11-08)

1. **Castle residue vs MWF R7.** Free `gObjectPool` slots, surface-pool slots past
   the count, and the reused main pool hold the castle's bytes. R7 (SafeB is
   load-closed) is not known to hold of them. That needs an invariant that is true
   of every castle frame, or R7 restated to cover only the cells the frame reads.
2. **S7 and the floor.** See the §4 Layout row. The anim buffer, the surface pool
   and the Camera share the main-pool block in 3.6's model. Every block-granular
   apartness then fails on a real entry: `ff_D2` / `ff_Dbt`, `anim_apart`,
   `cam_w`, and now `ff_Wf` / `Wff` for the floor. The fix is byte-range regions
   in `ff_rl` / `rblk`, and the witness then drops S7.
3. **Stand-ins S1–S8** (`StartTerrain`'s header, TRUST 0.4). Each is a witness
   shortcut, not a trust row, but the capstone's premise is shown satisfiable
   only at the witness they build:
   - S1: `ACT_IDLE` before the warp.
   - S2: `gCurrActNum = 1`. `StartCarry` now covers 0..6 at the premise.
   - S3: segment loads, model JUMP_LINKs and AREA's geo layout not run.
   - S4: `level_script_execute` not run.
   - S5: `FREE_LEVEL_POOL` as three stores.
   - S6: `set_background_music` and `init_level`'s tail.
   - S7: the anim DMA shortcut (item 2).
   - S8: `main_pool_init`'s post-state, `gCurrCourseNum` and `gControllers[0]`.

   Shrinking each means running the real code from the boot memory.
4. `m->input`: the A bits are the ABC premise. The other bits are free (§3).

## 5. Parametrisation (chunk 2) and status

Every real entry is W1 with parameters

  `act ∈ 0..6`, `cap ∈ {on, lost}`, the save bits `cannon`, `wingcap` and the star flags,
  Mario's carried scalars (`input` with `input & 0x882 = 0`, `health`, `numLives`, …),
  and the carried globals of §4,

plus the residue and the layout of §4 (not parametrised: a whole-castle fact).

| Part | Plan |
|---|---|
| act 1..6, cap, Mario's scalars, carried int globals | **Done** (`StartCarry.goal2_start_carried`). The real-entry witness, after any sequence of int stores into Mario's flags / coins / stars / keys / lives / health / unkB0 / prevNumStarsForDialog and into `gCurrActNum` / `gCurrSaveFileNum` / `gCurrCourseStarFlags`, still meets the capstone's start premise. `object_masks` checks that every OBJECT in WMotR's script has mask 0x1F, so every act places the same objects. |
| act 0 | FOUND (B1). **Repaired 2026-11-07** by option (a), the approved rewrite `1 << ((gCurrActNum - 1) & 31)` (TRUST 2.2; `StartCarry.act0_val7`: val7 = 0, so the same objects as acts 1..6 are placed). |
| wall / ceil | **Done** (2026-11-08). `wmotr_world`'s `wall_ok` / `ceil_ok` are `True`. ffw's `ff_Wc0` is dropped: FOUND false of a real entry, since the stale pointers point into the main pool, which holds the anim buffer region (TRUST 0.4). The wall / ceil parts of `ff_Spl`, `ffw_surf_ok` and `surf_apart` are dropped too. The start premise says nothing about either cell. `mobj_apart` still keeps them off Mario's object block, which holds on entry (the object is a `gObjectPool` slot, a global). |
| residue / layout | OPEN. Needs a pre-entry invariant or a block-model change; for main. |
