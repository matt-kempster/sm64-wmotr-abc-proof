# GOAL 2 — the Mario `pos[1]` (gameplay-y) **writer census**, from the generated Clight AST

**Status:** 2026-07-09. AST census, **no Coq**. This is the GOAL-2 analogue of GOAL-1's
one-writer action census (`docs/whole-program-action-writers.md`,
`docs/goal2-y-value-census.md`): the height invariant of GOAL 2 must *dominate every*
store that can change `gMarioState->pos[1]`, so this list must be **exhaustive** to be
worth anything.

Unlike the earlier `goal2-*-census.md` notes (which grepped `vendor/sm64/src/*.c`), this
census is built **against the mechanically `clightgen`'d AST** under `generated/` — the
store-scout law: classify against the Clight, cite comments only to *interpret*. Every
row cites `generated/<TU>.v:<line>` (the load-bearing fact) and, where useful, the
`vendor/sm64/…` line it corresponds to.

## 0. What we are counting, and how it was found

`gMarioState->pos` is a `Vec3f` (`float[3]`) at MarioState offset 60; **`pos[1]`
(offset 64) is gameplay y** — the value collision/interaction use (the earlier note's
"trap": `m->marioObj->header.gfx.pos[1]` is the *graphics* mirror, **not** gameplay y —
see §6). In the Clight AST a MarioState `pos` access is exactly
`… (Tstruct _MarioState noattr)) _pos (tarray tfloat 3)` (distinct from `_oPosY`, the
`Object` struct, and from `PlayerCameraState`/`GraphNodeObject` `_pos`).

A `pos[1]` **writer** has one of three AST shapes; each was enumerated with a
paren-matching scan over the 12 linked TUs (`mario`, `mario_step`,
`mario_actions_{stationary,moving,airborne,submerged,cutscene,automatic,object}`,
`interaction`, `behavior_actions`, `level_update`):

- **(a) direct field store** — `Sassign` whose lvalue is
  `(Ederef (Ebinop Oadd (Efield (Ederef m …) _pos …) (Econst_int 1) …) tfloat)`.
  Scan = every `Sassign` lvalue containing MarioState `_pos`, keep index `1`.
- **(b) whole-vector call-copy** — a `Scall` passing `m->pos` (array decays to `float*`)
  as **arg0** (the destination) to `vec3f_copy` / `vec3f_set` / `vec3s_to_vec3f`. Scan =
  every `Scall` with MarioState `_pos` as arg0; the callee filters out
  `vec3f_find_ceil`/`find_floor` (which take `pos` as a **read** input) and
  `f32_find_wall_collision` (writes x/z; y-identity — §4).
- **(c) interior-pointer store** — a helper takes `float*` aliasing into `m->pos` and
  stores through it. In the linked set these helpers (`resolve_and_return_wall_collisions`,
  `f32_find_wall_collision`) are called on **local** `nextPos` scratch, not `m->pos`
  directly (§4), so they are not *direct* `m->pos` writers; `set_pole_position` /
  `perform_hanging_step` write `m->pos` via shapes (a)/(b), already covered.

Index-0/2 (x/z) stores are catalogued separately (§5) — they are **not** y-writers, but
listed to prove the census saw them (e.g. bully knockback is x/z only).

## 1. The GOAL-2 classes (per the height-invariant strategy)

- **MONOTONE-SAFE** — writes y ≤ current y, or = a floor/geometry value below the cap. Free for an upper bound.
- **BALLISTIC** — `pos ← pos + vel/4` (the quarter-step integration). The Flocq interval step; the only channel that climbs without a geometric ceiling — bounded only by `vel[1]` (the yVel census, `goal2-wmotr-y-changer-census.md §1`).
- **ATTACH** — snap to a floor/ledge/ceiling/pole (`= floorHeight`, `ceilHeight − k`, ledge). The floor-ladder's attach windows; bounded by stage geometry.
- **EXOGENOUS** — copies an *object's* position into Mario (platform ride, grab, OOB-gfx recovery). Needs the object's y bounded.
- **TELEPORT** — spawn / warp / cutscene set to an absolute target. Needs the target census.

## 2. Direct `pos[1]` stores (shape a) — 24 sites

| # | writer site (generated) | function | value written (AST) | class | verdict in WMotR-no-A |
|---|---|---|---|---|---|
| 1 | `mario.v:2082` | `update_mario_pos_for_anim` | `pos[1] + (short)animY` | EXOGENOUS (tiny) | REACH — bounded anim translation (the ε); runs each action |
| 2 | `mario.v:6085` | `set_water_plunge_action` | `waterLevel − 100` | ATTACH | **ABSENT** — needs water (none in WMotR) |
| 3 | `mario_step.v:1744` | `stop_and_set_height_to_floor` | `= floorHeight` (`t'2`) | ATTACH/PIN | reachable; floor-bounded |
| 4 | `mario_step.v:1854` | `stationary_ground_step` | `= floorHeight` (`t'5`) | ATTACH/PIN | reachable; floor-bounded |
| 5 | `mario_step.v:2975` | `perform_air_quarter_step` | `= t'45` (floor/ceil-clamped intended y) | BALLISTIC→clamp | reachable; the air integration |
| 6 | `mario_step.v:2995` | `perform_air_quarter_step` | `= t'42` (intended y = nextPos) | **BALLISTIC** | reachable; `pos+vel/4` |
| 7 | `mario_step.v:3120` | `perform_air_quarter_step` | `= floorHeight` | ATTACH/PIN | landing snap |
| 8 | `mario_actions_airborne.v:6940` | `act_ground_pound` | `pos[1] + yOffset` | BALLISTIC | **REACH** — ground-pound rise (~110u, ceiling-gated); non-A kit |
| 9 | `mario_actions_airborne.v:13373` | `act_riding_hoot` | `hootY − 92.5` | EXOGENOUS | **ABSENT** — needs Hoot object |
| 10 | `mario_actions_moving.v:1030` | `align_with_floor` | `= floorHeight`-aligned (`t'5`) | ATTACH/PIN | reachable; floor-bounded |
| 11 | `mario_actions_stationary.v:5007` | `act_shockwave_bounce` | `t'11·sp18 + t'12` | BALLISTIC | **ABSENT** — needs shockwave (Bowser) |
| 12 | `mario_actions_stationary.v:5036` | `act_shockwave_bounce` | `t'9 − t'10·sp18` | BALLISTIC | **ABSENT** — same |
| 13 | `mario_actions_submerged.v:7798` | `act_caught_in_whirlpool` | `t'9 + t'10` | EXOGENOUS | **ABSENT** — needs whirlpool/water |
| 14 | `mario_actions_submerged.v:10289` | `check_common_submerged_cancels` | `waterLevel − 80` | ATTACH | **ABSENT** — needs water |
| 15 | `mario_actions_cutscene.v:14530` | `end_peach_cutscene_run_to_peach` | `= t'2` | TELEPORT | **ABSENT** — endgame cutscene |
| 16 | `mario_actions_automatic.v:964` | `set_pole_position` | `poleBase + t'31 + offsetY` | ATTACH | reachable — 5 summit poles (grab **not** A-gated, per strategy-v2); the binding constraint |
| 17 | `mario_actions_automatic.v:1093` | `set_pole_position` | `ceilHeight − 160` | ATTACH | pole ceiling clamp |
| 18 | `mario_actions_automatic.v:1220` | `set_pole_position` | `= floorHeight` | ATTACH/PIN | pole floor clamp |
| 19 | `mario_actions_automatic.v:3542` | `update_hang_stationary` | `ceilY − 160` | ATTACH | needs a hangable ceiling |
| 20 | `mario_actions_automatic.v:4280` | `let_go_of_ledge` | `ledgeY − 100` | ATTACH | ledge release |
| 21 | `mario_actions_automatic.v:4292` | `let_go_of_ledge` | `= floorHeight` | ATTACH/PIN | ledge release floor |
| 22 | `mario_actions_automatic.v:5718` | `act_in_cannon` | `cannonY + 350` | ATTACH→TELEPORT | **A-gated + taint-T** (cannon; GOAL-1 flying set) |
| 23 | `interaction.v:3476` | `bounce_off_object` | `t'3 + t'4` | EXOGENOUS | **ABSENT** — needs bounceable object |
| 24 | `level_update.v:4283` | `check_instant_warp` | `pos[1] + (short)warpΔ` | **TELEPORT** | instant-warp displacement (see §7 — not in exec_mario_action) |

## 3. Whole-vector call-copies (shape b) — 16 sites

`vec3f_copy(m->pos, src)` / `vec3f_set(m->pos, x,y,z)` / `vec3s_to_vec3f(m->pos, src)`.
Each writes all of x/y/z, hence `pos[1]`.

| # | writer site | function | callee & source (AST) | class | verdict |
|---|---|---|---|---|---|
| 25 | `mario.v:7114` | `update_mario_geometry_inputs` | `vec3f_copy(m->pos, m->marioObj->header.gfx.pos)` **inside `if (m->floor==NULL)`** | **EXOGENOUS (gfx copy-BACK)** | OOB recovery — see §6 flag |
| 26 | `mario.v:10341` | `init_mario` | `vec3s_to_vec3f(m->pos, m->spawnInfo->startPos)` | **TELEPORT** | level-load spawn (§7) |
| 27 | `mario_step.v:2104` | `perform_ground_quarter_step` | `vec3f_copy(m->pos, nextPos)` | BALLISTIC (x/z)+floor | ground integration |
| 28 | `mario_step.v:2158` | `perform_ground_quarter_step` | `vec3f_set(m->pos, x, floorHeight, z)` | ATTACH/PIN | floor snap |
| 29 | `mario_step.v:2687` | `check_ledge_grab` | `vec3f_copy(m->pos, ledgePos)` | ATTACH | ledge-grab snap |
| 30 | `mario_step.v:3335` | `perform_air_quarter_step` | `vec3f_copy(m->pos, nextPos)` | **BALLISTIC** | air integration |
| 31 | `mario_step.v:3369` | `perform_air_quarter_step` | `vec3f_copy(m->pos, nextPos)` | **BALLISTIC** | air integration |
| 32 | `mario_actions_submerged.v:927` | `perform_water_full_step` | `vec3f_copy(m->pos, nextPos)` | BALLISTIC | **ABSENT** — water |
| 33 | `mario_actions_submerged.v:984` | `perform_water_full_step` | `vec3f_set(m->pos, …)` | ATTACH | **ABSENT** — water |
| 34 | `mario_actions_submerged.v:1036` | `perform_water_full_step` | `vec3f_set(m->pos, …)` | ATTACH | **ABSENT** — water |
| 35 | `mario_actions_cutscene.v:3754` | `act_debug_free_move` | `vec3f_copy(m->pos, newPos)` | TELEPORT | **DEBUG** — unreachable in normal play (debug action) |
| 36 | `mario_actions_cutscene.v:12687` | `jumbo_star_cutscene_taking_off` | `vec3f_set(m->pos, …)` | TELEPORT | **ABSENT** — star grab cutscene (no star) |
| 37 | `mario_actions_cutscene.v:12928` | `jumbo_star_cutscene_flying` | `vec3f_copy(m->pos, …)` | TELEPORT | **ABSENT** — same |
| 38 | `mario_actions_automatic.v:3056` | `perform_hanging_step` | `vec3f_copy(m->pos, nextPos)` | ATTACH | ceiling hang; needs hangable ceiling |
| 39 | `mario_actions_automatic.v:5423` | `act_grabbed` | `vec3f_copy(m->pos, heldPos)` | **EXOGENOUS** | **ABSENT** — needs grabbing enemy |
| 40 | `mario_actions_automatic.v:7474` | `act_tornado_twirling` | `vec3f_copy(m->pos, …)` | EXOGENOUS | **ABSENT** — needs tweester/tornado |

## 4. Horizontal wall-collision writers (write x/z; **y-identity**) — MONOTONE-SAFE

`f32_find_wall_collision(&m->pos[0], &m->pos[1], &m->pos[2], offsetY, radius)` writes
back all three pointers, **but** the collision only pushes x/z; the y writeback is the
*input* y (`surface_collision.v:1727` `f_f32_find_wall_collision`: `*yPtr := collision.y`
where `collision.y` is loaded from `*yPtr`). So these are **y-writers of `y ← y`** —
monotone-safe, never climb.

| site | function | note |
|---|---|---|
| `mario.v:7005`, `mario.v:7028` | `update_mario_geometry_inputs` | pre-action wall push (60/50, 30/24) |
| `mario_actions_automatic.v:979`, `:1013` | `set_pole_position` | pole wall push |

`resolve_and_return_wall_collisions` (`mario.v:3270`) writes `pos[0..2]` through its
`float* pos` **param** with the same y-identity, but its linked call sites
(`mario_step.v:1940/1952/2855`, `automatic.v:2918`, `submerged.v:847`,
`cutscene.v:3680`, `interaction.v:10620`) pass a **local `nextPos`**, not `m->pos` — the
`m->pos` write then happens via the shape-(b) `vec3f_copy(m->pos, nextPos)` already
counted (rows 27/30/31). `f32_find_wall_collision`, `find_floor`, `vec3f_find_ceil` live
in `surface_collision.v` — a **callee TU, external to the GOAL-1 spine** (honest model
boundary).

## 5. x/z-only direct stores (NOT y-writers) — completeness ledger

These write `pos[0]` and/or `pos[2]` but **never** `pos[1]` (verified: no index-1 store
in the same block). Listed to prove the scan saw them.

- `mario.v:2031/2053` `update_mario_pos_for_anim` (x/z anim translation)
- `mario_step.v:3069` `perform_air_quarter_step` (x wall pushback)
- `mario_actions_airborne.v:13347/13403` `act_riding_hoot` (x/z)
- `mario_actions_submerged.v:7718/7751` `act_caught_in_whirlpool` (x/z)
- `mario_actions_automatic.v:893/922` `set_pole_position`; `4165/4203` `let_go_of_ledge`; `4352/4390` `climb_up_ledge`; `5684` `act_in_cannon` (x/z)
- `mario_actions_cutscene.v` `act_reading_sign` (3295/3334), `act_unlocking_key_door` (5336/5381), `act_unlocking_star_door` (5982/6007), `act_entering_star_door` (6335/6377/6489/6538), `act_going_through_door` (6711/6738), `jumbo_star_cutscene_falling` (12178/12187), `end_peach_cutscene_run_to_peach` (14465/14478) — door/cutscene x/z alignment
- **`interaction.v:3211/3228` `bully_knock_back_mario` (x/z only)** — answers the task's question: **bully knockback does NOT write `pos[1]`** (it writes x/z here and `vel` elsewhere)
- `interaction.v:4172/4185` `push_mario_out_of_object` (x/z)
- `level_update.v:4242/4324` `check_instant_warp` (x/z; the y companion is row 24)

## 6. Cross-check — gfx vs gameplay y (the copy-BACK flag)

The gameplay→graphics mirror is written each frame (`mario.c:1838`
`gfx.pos[1] = m->pos[1]`; `mario.c:1855` `vec3f_copy(gfx.pos, m->pos)`;
`sink_mario_in_quicksand` writes `marioObj->header.gfx.pos[1]`, verified at
`mario.v:8661+` — **gfx only, out of scope**). These are *not* `m->pos` writers.

**The one copy in the reverse direction is row 25** —
`update_mario_geometry_inputs` (`mario.v:7114`, vendor `mario.c:1328`):

```c
    if (m->floor == NULL) {                              // Mario is OOB
        vec3f_copy(m->pos, m->marioObj->header.gfx.pos); // snap gameplay pos to the gfx pos
        m->floorHeight = find_floor(m->pos …);
    }
```

This is an **OOB recovery**, guarded by `m->floor == NULL`. It copies the *graphics*
position **back into gameplay `m->pos`**. Since `gfx.pos` was itself set `= m->pos` on a
prior frame (1838/1855), the invariant must show `gfx.pos[1]` is bounded — it equals a
prior `m->pos[1]`, so this is **self-referential / EXOGENOUS-gfx**: safe under an
inductive height bound, but it **must be covered** (it is a genuine `m->pos[1]` writer,
and it runs in the *pre-action* phase, outside `execute_mario_action` — §7).

## 7. Frame phase & what GOAL-1's walk already covered

Ordering of a frame's `pos[1]` writers:

1. **Warp / level phase** — `level_update.v` `check_instant_warp` (row 24, TELEPORT).
2. **Spawn (level load / respawn)** — `mario.v` `init_mario` (row 26, TELEPORT).
3. **Pre-action geometry** — `update_mario_inputs → update_mario_geometry_inputs`: wall push (§4, y-identity) + OOB gfx recovery (row 25).
4. **Action phase** — `execute_mario_action → <handler> → perform_{ground,air,water}_step` and the ATTACH helpers (`set_pole_position`, `perform_hanging_step`, `check_ledge_grab`, `act_ground_pound`, `update_mario_pos_for_anim`, …): rows 1,3–8,10,16–22,27–34,38, and the ABSENT set.
5. **Object / interaction phase** — `interaction.v` (`bounce_off_object` row 23; bully/push x/z §5) and `act_grabbed`/`act_tornado_twirling` (rows 39/40); **platform displacement (unlinked, §8)**.

**GOAL-1's spine walked the `execute_mario_action` subtree** (all action handlers,
`perform_*_step`, `set_pole_position`, `perform_hanging_step`, `resolve_*`,
`check_ledge_grab`, `act_ground_pound`, the interact_* family — per MEMORY). So every
**phase-4** writer (and the phase-5 interaction writers) sits inside an
already-structurally-traversed body. The **writers NOT covered by GOAL-1's walked
bodies** — the ones GOAL 2 must newly dominate — are the frame phases *around*
`execute_mario_action`:

| writer | site | phase | why uncovered | class |
|---|---|---|---|---|
| `init_mario` spawn | `mario.v:10341` | spawn | not in `execute_mario_action` subtree | TELEPORT |
| `check_instant_warp` | `level_update.v:4283` | warp | level-update phase, separate root | TELEPORT |
| `update_mario_geometry_inputs` wall push | `mario.v:7005/7028` | pre-action | in `update_mario_inputs`, a sibling of exec | MONOTONE (y-identity) |
| `update_mario_geometry_inputs` OOB gfx copy | `mario.v:7114` | pre-action | same | EXOGENOUS-gfx (row 25) |
| **`apply_platform_displacement`** | **UNLINKED** | object phase | **not in any linked TU** (§8) | **EXOGENOUS** |

## 8. UNLINKED-TU FLAG — platform displacement (the WMotR carpets)

Task item (d): the moving-platform / carpet ride writer is
**`apply_platform_displacement`**, and it **is not in the linked TU set**.

- In `generated/`, `apply_platform_displacement` appears **only as an `Evar` call**
  (`behavior_actions.v:56842`, in the Bowser tilt-platform handler) — **no `Definition
  f_apply_platform_displacement`** exists in any generated TU. `update_mario_platform` is
  absent entirely.
- Its body lives in the **unlinked** `vendor/sm64/src/game/platform_displacement.c`:
  `apply_platform_displacement` (line 91) writes **`gMarioStates[0].pos[1] = y`**
  (line 83, after applying the platform's rotation+translation) — a direct gameplay-y
  write sourced from the platform's displaced position.

⇒ **This is a genuine `pos[1]` writer that the current 12-TU link CANNOT see.** For GOAL
2 it is **EXOGENOUS**: the height bound must either (i) link `platform_displacement.c`
and bound the ridden platform's y, or (ii) argue WMotR's ridable platforms (the carpets)
have bounded y and Mario's displacement never exceeds it. Until then it is an **honest
gap**, exactly like GOAL-1's `surface_collision`/`find_floor` external boundary.

## 9. Summary — the writer table

| writer | TU | linked? | phase | value-shape | class |
|---|---|---|---|---|---|
| `perform_air_quarter_step` (×2 direct + ×2 copy) | mario_step | ✓ | action | `pos + vel/4` | **BALLISTIC** |
| `perform_ground_quarter_step` (copy + set) | mario_step | ✓ | action | nextPos / floor snap | BALLISTIC / ATTACH |
| `perform_water_full_step` (×3) | submerged | ✓ | action | nextPos / set | ABSENT (water) |
| `act_ground_pound` | airborne | ✓ | action | `pos + yOffset` | BALLISTIC (kit, ~110u) |
| `update_mario_pos_for_anim` | mario | ✓ | action | `pos + animY` | EXOGENOUS-tiny (ε) |
| `set_pole_position` (×3) | automatic | ✓ | action | pole/ceil/floor | **ATTACH** (poles = binding) |
| `perform_hanging_step`, `update_hang_stationary`, `let_go_of_ledge`, `check_ledge_grab`, `align_with_floor`, `stop_and_set_height_to_floor`, `stationary_ground_step` | automatic/step/moving | ✓ | action | floor/ledge/ceil | **ATTACH/PIN** |
| `act_in_cannon` | automatic | ✓ | action | `cannonY + 350` | ATTACH→TELEPORT, **A-gated+taint** |
| `act_grabbed`, `act_tornado_twirling`, `act_riding_hoot`, `bounce_off_object`, `act_shockwave_bounce`, `act_caught_in_whirlpool`, water/plunge, cutscene star/peach, `act_debug_free_move` | automatic/airborne/interaction/stationary/submerged/cutscene | ✓ | action/interact | object / absolute | **ABSENT / DEBUG** (object or surface WMotR lacks) |
| `f32_find_wall_collision`, `resolve_*` (y-identity) | mario/step/automatic (+ surface_collision) | ✓ (callee ext) | pre-action/action | `y ← y` | **MONOTONE-SAFE** |
| `update_mario_geometry_inputs` OOB gfx copy | mario | ✓ | **pre-action** | `= gfx.pos` (`floor==NULL`) | **EXOGENOUS-gfx** (row 25) — not in GOAL-1 walk |
| `init_mario` spawn | mario | ✓ | **spawn** | `= spawnInfo->startPos` | **TELEPORT** — not in GOAL-1 walk |
| `check_instant_warp` | level_update | ✓ | **warp** | `pos + warpΔ` | **TELEPORT** — not in GOAL-1 walk |
| **`apply_platform_displacement`** | **platform_displacement.c** | **✗ UNLINKED** | object | `= displaced platform y` | **EXOGENOUS** — the WMotR carpets (§8) |

**The handful GOAL 2 must newly dominate** (outside GOAL-1's `execute_mario_action`
walk): the two **TELEPORTs** (`init_mario` spawn, `check_instant_warp` warp), the
pre-action **EXOGENOUS-gfx** OOB copy (`update_mario_geometry_inputs`), and the
**UNLINKED** platform-displacement writer. Everything else is a phase-4 action writer
already structurally traversed by GOAL 1 and falling into BALLISTIC (the yVel channel,
already A-gated/bounded per `goal2-wmotr-y-changer-census.md`), ATTACH (stage geometry),
or ABSENT (object/surface WMotR lacks).
