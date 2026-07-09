# GOAL-2 frame-boundary scout

READ-ONLY reconnaissance (2026-07-09). Goal: decide where the proof's per-frame
boundary should sit when GOAL-2 widens it from GOAL-1's `f_execute_mario_action`
to "the real game frame", because GOAL-2 tracks `m->pos[1]` (Mario's y, offset 64
in `MarioState`) and the frame must contain **every** per-frame writer of `m->pos`
and `m->action`.

Every claim below is cited to `vendor/sm64/src/**` (the C truth) or the
`generated/*.v` Clight AST. No `.v` was edited.

---

## TL;DR — the headline result

1. **The premise "WMotR's flying carpets displace Mario outside `execute_mario_action`"
   is FALSE for WMotR.** WMotR (`levels/wmotr/script.c`) has **no moving platforms,
   no carpets, no dynamic-surface objects at all** — see §4. Its floors are one
   static `TERRAIN` block. Therefore `gMarioPlatform` is **provably `NULL` every
   frame**, and `apply_mario_platform_displacement()` is an **inert no-op** in
   WMotR. Platform displacement never writes `m->pos` in this level.

2. **In *general* SM64, platform displacement IS a per-frame `m->pos` writer that
   runs OUTSIDE `execute_mario_action`** — it is a *sibling* call in
   `update_objects`, running *before* `bhv_mario_update` (§1). So the general
   suspicion in the task is correct; it just doesn't bite in WMotR.

3. **The smallest F that contains both writers in the general game is
   `update_objects` (object_list_processor.c) — but that is a catastrophic
   widening**: `update_objects` runs the entire object-behavior-script VM for
   *all* objects (`update_non_terrain_objects → cur_obj_update →` the
   `engine/behavior_script.c` interpreter), and its bodies live in **TUs that are
   neither linked nor even `clightgen`'d** (`object_list_processor.c`,
   `platform_displacement.c`, `area.c`, `engine/behavior_script.c`, …). This is a
   large P1'-class (actually worse: pipeline-regen) growth. See §3.

4. **RECOMMENDATION (§3):** do **not** widen the eval_funcall frame to
   `update_objects`. Keep GOAL-1's `f_execute_mario_action` eval_funcall as the
   *action segment* of the frame, and model the frame as a short **composition of
   segments** whose only *other* `m->pos` writers are:
   - `apply_platform_displacement` — a **self-contained ~76-line** body, discharged
     for WMotR by the **inertness lemma `gMarioPlatform ≡ NULL`** (no dynamic
     surfaces ⇒ guard at platform_displacement.c:174 always fails), so it
     contributes **zero** Δy in WMotR; and
   - the **warp teleports** (`check_instant_warp`, level_trigger_warp / delayed /
     painting warps) — conditional writes to fixed, level-defined destinations
     (bounded by geometry), handled as boundary jumps, not incremental gain.

   Under that decomposition the widened frame **subsumes** GOAL-1 (the action-cell
   invariant transfer is trivial: the extra segments never touch `m->action`), and
   no new TU has to be linked or generated for WMotR.

---

## 1. The per-frame chain, from the game loop down to Mario

Frame driver (normal play), all in `level_update.c` (LINKED TU `level_update`):

```
play_mode_normal()                             level_update.c:962
├─ level_trigger_warp(...)  (demo/START only)  level_update.c:966,970  [sets warp state]
├─ warp_area()                                 level_update.c:974
├─ check_instant_warp()                        level_update.c:975   *** writes m->pos[1] (cond) ***
├─ area_update_objects()                       level_update.c:981
│    └─ update_objects(0)                       area.c:300  →  object_list_processor.c:626
│         ├─ clear_dynamic_surfaces()
│         ├─ update_terrain_objects()
│         ├─ apply_mario_platform_displacement() object_list_processor.c:654  *** writes m->pos (cond) ***
│         ├─ detect_object_collisions()
│         ├─ update_non_terrain_objects()       object_list_processor.c:662
│         │    └─ ... cur_obj_update() (behavior_script.c VM) ...
│         │         └─ bhv_mario_update()        object_list_processor.c:267
│         │              ├─ execute_mario_action(gCurrentObject)  ← GOAL-1's frame
│         │              ├─ copy_mario_state_to_object()          object_list_processor.c:224
│         │              └─ spawn_particle loop
│         ├─ unload_deactivated_objects()
│         └─ update_mario_platform()            object_list_processor.c:670  [sets gMarioPlatform for NEXT frame]
├─ update_hud_values()
├─ update_camera(...)
├─ initiate_painting_warp()                     level_update.c:988   *** warp (cond) ***
└─ initiate_delayed_warp()                      level_update.c:989   *** warp (cond) ***
```

### What is INSIDE `execute_mario_action` (GOAL-1's frame, already in scope)

`execute_mario_action` (mario.c:1699) calls, in order (mario.c:1704–1754):
`mario_reset_bodystate`, **`update_mario_inputs`**, `mario_handle_special_floors`,
**`mario_process_interactions`**, the action-group `switch` (the 7 dispatchers),
`sink_mario_in_quicksand`, `squish_mario_model`,
`set_submerged_cam_preset_and_spawn_bubbles`, `update_mario_health`,
`update_mario_info_for_cam`, `mario_update_hitbox_and_cap_model`.

- **`mario_process_interactions` is INSIDE** `execute_mario_action` (mario.c:1707),
  not a separate frame phase — good, it is already in GOAL-1's frame.
- **`update_mario_inputs` → `update_mario_geometry_inputs`** (mario.c:1381 → 1314)
  itself writes `m->pos`:
  - `f32_find_wall_collision(&m->pos[0], …)` twice (mario.c:1318–1319) — wall push-out;
  - `vec3f_copy(m->pos, m->marioObj->header.gfx.pos)` on the OOB branch (mario.c:1328).
  These are already inside GOAL-1's frame.
- The action-group dispatchers are the primary `m->pos[1]` movers (`perform_air_step`,
  `perform_ground_step`, jump velocity, etc.) — all inside GOAL-1's frame.

### What is OUTSIDE `execute_mario_action` but still per-frame

- **`apply_mario_platform_displacement()`** — sibling in `update_objects`, runs
  **before** `bhv_mario_update`. Applies displacement from the platform Mario was on
  at the *end of last frame*. **Writes `m->pos`** (see §4 for the exact writes) and
  `m->faceAngle[1]`.
- **`update_mario_platform()`** — sibling, runs **after** `bhv_mario_update`. Does
  **not** write `m->pos`; it only records `gMarioPlatform`/`gMarioObject->platform`
  for next frame (reads pos, writes platform pointers).
- **`check_instant_warp()`** and the warp initiators — conditional `m->pos` writes.

---

## 2. TU / linkage table for every frame participant

The 12 LINKED TUs (`proofs/MarioModel/LinkedTwelve.v:77`): `mario`,
`mario_actions_{stationary,moving,airborne,submerged,cutscene,automatic,object}`,
`interaction`, `behavior_actions`, `level_update`, `mario_step`.

`generated/` also contains `mario_misc`, `math_util`, `shadow`, `surface_collision`,
`toy` (generated but **not** in the linked 12). Everything else is **not generated**.

| participant | vendor C file | generated `.v`? | in linked 12? | Internal there? | writes `m->pos`? |
|---|---|---|---|---|---|
| `bhv_mario_update` | object_list_processor.c:267 | **NO** | no | — | no (delegates) |
| `execute_mario_action` | mario.c:1699 | mario.v | **yes** | Internal (mario.v:9275) | via callees |
| `update_mario_inputs` | mario.c:1373 | mario.v | **yes** | Internal (mario.v:7635) | via geometry |
| `update_mario_geometry_inputs` | mario.c:1314 | mario.v | **yes** | Internal (mario.v:6973) | **YES** (1318,1328) |
| `mario_process_interactions` | interaction.c | interaction.v | **yes** | Internal (interaction.v:10832) | via handlers |
| `squish_mario_model` | mario.c | mario.v | **yes** | Internal (mario.v:6205) | (model only) |
| `sink_mario_in_quicksand` | mario.c | mario.v | **yes** | Internal (mario.v:8661) | quicksandDepth |
| `mario_update_hitbox_and_cap_model` | mario.c | mario.v | **yes** | Internal (mario.v:8996) | no |
| `update_mario_platform` | platform_displacement.c:22 | **NO** | no | — | no (platform ptr) |
| `apply_mario_platform_displacement` | platform_displacement.c:171 | **NO** | no | — | via callee |
| `apply_platform_displacement` | platform_displacement.c:91 | **NO** | no | — | **YES** (set_mario_pos, 159–160) |
| `check_instant_warp` | level_update.c:530 | level_update.v | **yes** | Internal | **YES** (547) |
| `update_objects` | object_list_processor.c:626 | **NO** | no | — | no (delegates) |
| `area_update_objects` | area.c:298 | **NO** | no | — | no |
| `copy_mario_state_to_object` | object_list_processor.c:224 | **NO** | no | — | object←state (not m->pos) |
| `cur_obj_update` (bhv VM) | engine/behavior_script.c:906 | **NO** | no | — | — |

### UNLINKED / UN-GENERATED flags (the cost of widening)

- `platform_displacement.c` — **not generated**. Holds `apply_platform_displacement`
  (the real platform `m->pos` writer) and `update_mario_platform`.
- `object_list_processor.c` — **not generated**. Holds `update_objects`,
  `bhv_mario_update`, `copy_mario_state_to_object`, `update_non_terrain_objects`.
- `area.c` — **not generated**. Holds `area_update_objects`.
- `engine/behavior_script.c`, `object_helpers.c`, `spawn_object.c`, … — **not
  generated**. The behavior-script VM and object machinery reached by
  `update_non_terrain_objects`.

Note: `apply_platform_displacement` *does* appear in `behavior_actions.v` — but only
as `Gfun(External (EF_external "apply_platform_displacement"))`
(behavior_actions.v:112405–112406), the **object-side** (`isMario=FALSE`) call from
`bowser.inc.c`. There is **no Internal body** for it anywhere in the linked set.

---

## 3. The frame-root decision (the deliverable)

**Requirement.** F must be the smallest function such that one `eval_funcall F`
contains ALL per-frame writes to `m->pos` AND all writes to `m->action`, so that a
GOAL-2 frame *subsumes* GOAL-1's `execute_mario_action` frame (the invariant
transfer then reduces to "the extra callees don't touch the action cell").

**Candidate A — `update_objects` (object_list_processor.c).** This is the *smallest
single function* whose body statically contains both `apply_mario_platform_displacement`
(pos writer) and — via `update_non_terrain_objects → cur_obj_update →` the behavior VM
— `bhv_mario_update → execute_mario_action` (pos + action writer). It also contains
`update_mario_platform`, closing the platform induction (set at end, applied at start).

But `update_objects` is **maximal in code even though minimal in name**: one
`eval_funcall` of it symbolically executes the **entire object-behavior-script
interpreter for every object in the level**. Its transitive callees live in
`object_list_processor.c`, `platform_displacement.c`, `area.c`,
`engine/behavior_script.c`, `object_helpers.c`, `spawn_object.c` — **none of which
are `clightgen`'d today**. Widening to F = `update_objects` therefore costs:
(i) generating ≥4 new TUs, (ii) re-linking to a 16-TU program, and (iii) walking the
behavior VM. This is a pipeline-regeneration growth, far heavier than the linked-12
P1' work. **Not recommended.**

**Candidate B — `play_mode_normal` (level_update.c, LINKED).** Even larger; adds the
warp teleports and camera/HUD. `level_update` *is* linked, but the body pulls in
`area_update_objects` (un-generated) exactly as A does. Strictly worse than A.

### RECOMMENDATION: keep the eval_funcall frame at `execute_mario_action`; model the frame as a segment composition

Do **not** move the `eval_funcall` root. Instead define one GOAL-2 frame as the
**ordered composition of three segments**, and prove the y-invariant is preserved by
each:

```
frame(m ⟶ m') :=
   seg_warp        (check_instant_warp etc.)          -- bounded teleports
 ∘ seg_platform    (apply_mario_platform_displacement) -- Δpos from last frame's platform
 ∘ seg_action      (eval_funcall f_execute_mario_action) -- GOAL-1's frame, verbatim
```

- **`seg_action`** is GOAL-1's existing linked `eval_funcall f_execute_mario_action`
  over `lp` (RealFrameLinked.v:415–419). Reused verbatim; carries the action-cell
  reasoning. All action-driven `m->pos[1]` motion lives here.
- **`seg_platform`** = `apply_platform_displacement` (platform_displacement.c:91, a
  **self-contained ~76-line** body reading only `platform->…` fields + `m->pos` +
  `m->faceAngle`, writing `m->pos`/`m->faceAngle`). It **never touches `m->action`**
  ⇒ GOAL-1 invariant transfer is trivial. For **WMotR** it is discharged *without
  walking the body* by the **inertness lemma** (§4): `gMarioPlatform ≡ NULL` ⇒ the
  guard `apply_mario_platform_displacement` (platform_displacement.c:174) fails ⇒ Δy = 0.
  (For a general level you would `clightgen` platform_displacement.c and bound its Δy;
  for WMotR that is unnecessary.)
- **`seg_warp`** = the conditional warp writers (`check_instant_warp` level_update.c:547,
  level_trigger_warp / delayed / painting). These **set** `m->pos[1]` to fixed
  level-defined destinations (not increments), so they cannot manufacture unbounded
  height; treat as boundary jumps bounded by static geometry. `check_instant_warp` is
  in the LINKED `level_update` TU if you want to walk it; WMotR uses only an
  `bhvAirborneWarp` self-loop + death/success warps (script.c:51–55).

**Why this subsumes GOAL-1.** `seg_action` *is* GOAL-1's frame. The two extra
segments are `m->action`-free, so the GOAL-1 no-A / action-cell invariant is
preserved across the whole composition by "the extra segments don't write the action
cell" — exactly the transfer condition the task asked for.

### Δ-callee table (bodies inside a hypothetical F = `update_objects` but OUTSIDE `execute_mario_action`)

| callee | TU | linked? | generated? | C lines | writes pos? | writes action? |
|---|---|---|---|---|---|---|
| `update_objects` | object_list_processor.c | no | **no** | 61 | no | no |
| `apply_mario_platform_displacement` | platform_displacement.c | no | **no** | 7 | via callee | no |
| `apply_platform_displacement` | platform_displacement.c | no | **no** | 76 | **YES** | no |
| `update_mario_platform` | platform_displacement.c | no | **no** | 46 | no | no |
| `bhv_mario_update` | object_list_processor.c | no | **no** | 21 | no | no |
| `copy_mario_state_to_object` | object_list_processor.c | no | **no** | ~30 | no (obj←state) | no |
| `update_non_terrain_objects` + `cur_obj_update` + behavior VM | object_list_processor.c / behavior_script.c | no | **no** | hundreds | (other objects) | no |

The only Δ-callee that writes `m->pos` is `apply_platform_displacement` (76 lines).
Everything else in the Δ is either plumbing or the full object engine — which is the
whole argument for the segment-composition recommendation over widening the funcall.

---

## 4. WMotR specifics — platform displacement is INERT here

`levels/wmotr/script.c` (full file read) object roster for Area 1:

- 6× `bhvPoleGrabbing` (script.c:19–24) — grab-volume poles, `MODEL_NONE`, **no
  collision surfaces** (poles are proximity-grab triggers, they do not create
  dynamic floor surfaces Mario stands on).
- 1× `bhvHiddenRedCoinStar` (script.c:29).
- 1× `bhvAirborneWarp` (script.c:51) — a static warp trigger volume (WARP_NODE_0A
  self-loop; this is the "you flew too far, warp back" volume).
- Macro objects (`macro.inc.c`): 2 cannons, 1 bob-omb buddy, coin rings, 1-up boxes,
  wing-cap boxes, red coins, hidden-1up-in-pole. **All static.**
- Terrain: one static `TERRAIN(wmotr_seg7_collision)` (script.c:58). The collision
  (`areas/1/collision.inc.c`) is only static surface types — `SURFACE_DEFAULT`,
  `SURFACE_HANGABLE`, `SURFACE_DEATH_PLANE`, `SURFACE_NOT_SLIPPERY`,
  `SURFACE_HARD_NOT_SLIPPERY`. No dynamic/object surfaces.

**There is NO `bhvPlatformOnTrack`, no carpet, no moving platform, no dynamic-surface
object in WMotR.** The "flying carpets" in the task premise do not exist in this level.

Consequence for the frame boundary:

- `update_mario_platform()` (platform_displacement.c:57–64) sets `gMarioPlatform` to a
  non-NULL value **only when** `floor->object != NULL`, i.e. when Mario stands on a
  *dynamic object surface*. WMotR has none ⇒ `find_floor` always returns a static
  level surface with `floor->object == NULL` ⇒ `gMarioPlatform` stays at its static
  init `NULL` (platform_displacement.c:16) **every frame**.
- `apply_mario_platform_displacement()` (platform_displacement.c:171–177) early-returns
  because its guard requires `platform != NULL` (line 174). ⇒ **`apply_platform_displacement`
  never runs in WMotR; it contributes zero `m->pos` change.**

So in WMotR the *only* incremental per-frame `m->pos[1]` writer is
`execute_mario_action` (GOAL-1's frame) plus the geometry/interaction writes already
inside it. `seg_platform` reduces to a one-line inertness lemma; `seg_warp` reduces to
"warps go to fixed level-bounded destinations."

**Exact platform pos-writes (for reference / the general case).** In
`apply_platform_displacement` (platform_displacement.c:91):
- linear branch (always): `x += platform->oVelX; z += platform->oVelZ;` (lines 120–121)
  — only X and Z; **no `oVelY` term**, so a purely *translating* platform does not
  drag Mario's y through this path (his y follows via `perform_ground_step`
  floor-snap inside the action).
- rotation branch (only if `oAngleVel{Pitch,Yaw,Roll} != 0`, lines 123–157): recomputes
  `x,y,z` through `mtxf_rotate_zxy_and_translate` — **this is the only path that writes
  `m->pos[1]` (y)** — and also `m->faceAngle[1] += rotation[1]` (line 129).
- commit: `set_mario_pos(x,y,z)` (line 160 → platform_displacement.c:81–85 writes
  `gMarioStates[0].pos[0..2]`).

None of these paths touch `m->action`.

---

## 5. Other per-frame pos-writers (survey)

- **Instant warp** — `check_instant_warp` writes `gMarioState->pos[0..2]` (level_update.c:546–548)
  and mirrors to `marioObj->oPos*`. Conditional on entering an instant-warp region.
  LINKED (`level_update`). WMotR has no instant-warp macro regions (its warps are the
  airborne self-loop + death/success node warps).
- **Level warps / respawn** — `level_trigger_warp` (called from
  `update_mario_geometry_inputs` OOB branch, mario.c:1366, and from `play_mode_normal`)
  set warp state; the actual reposition happens on area (re)load
  (`MARIO_POS(area 1, pos -67,1669,-16)` script.c:65), a one-time init, not per-frame gain.
- **`init_mario` / area init** — one-time, not per-frame (mario.c:1788).
- **Debug free-move** (`ACT_DEBUG_FREE_MOVE`) — a debug action that writes pos; it is
  an in-`execute_mario_action` action handler, already inside GOAL-1's frame, and is
  A/gate-irrelevant to no-A reasoning.
- **Camera / HUD** (`update_camera`, `update_hud_values`) — read Mario pos, do not
  write it.

No per-frame `m->pos` writer exists outside {`execute_mario_action`,
`apply_platform_displacement`, the warp writers} enumerated above.

---

## Bottom line

- **Recommended frame root F:** keep `eval_funcall f_execute_mario_action` (GOAL-1's,
  over `lp`) as `seg_action`; define the GOAL-2 frame as
  `seg_warp ∘ seg_platform ∘ seg_action`. Do **not** promote F to `update_objects`
  (that imports the un-generated object-behavior VM).
- **Δ pos-writer outside GOAL-1's frame:** exactly one — `apply_platform_displacement`
  (platform_displacement.c:91, 76 lines, un-generated). Discharged for **WMotR** by
  the inertness lemma `gMarioPlatform ≡ NULL` (no dynamic surfaces), so it needs no
  body walk and adds no linked TU for the WMotR theorem.
- **Unlinked/un-generated flags** (would be required only if you widen the funcall
  instead of composing segments): `platform_displacement.c`, `object_list_processor.c`,
  `area.c`, `engine/behavior_script.c`, `object_helpers.c`, `spawn_object.c`.
