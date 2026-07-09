# GOAL-2 — WMotR object/behavior census: hardening `seg_rest`

**Status:** store-scout audit, 2026-07-09. Executes **rung 4** of
[goal2-real-frame-plan.md](goal2-real-frame-plan.md) §6. **No Coq.** This
hardens the `seg_rest` spec — "nothing else in the frame writes Mario's
memory" (plan §6, the largest single trusted claim in the frame) — from a
bare assertion to a per-behavior audited claim, by store-scouting **every**
behavior that can run in WMotR for writes into Mario's `MarioState` block.

Every claim below is cited `file:line` from decomp source (never a comment);
the store-scout methodology caught 5 false claims elsewhere this week.

---

## VERDICT (headline)

> **`seg_rest`'s bare claim — "no Mario-block writes outside Mario's slice" —
> is FALSE for WMotR's closed behavior set.** Three object-side behaviors write
> into Mario's `MarioState` block. BUT all three writes are **benign for the
> GOAL-2 height/no-fly invariant**:
>
> | # | writer (object-side) | cell(s) written | pos[1]? | action? | in WMotR? |
> |---|---|---|---|---|---|
> | 1 | `cur_obj_push_mario_away` (via **6 poles**) | `pos[0]`, `pos[2]` | **no** | no | YES |
> | 2 | `bhv_1up_interact` (via **1-ups**) | `numLives` (++) | no | no | YES |
> | 3 | `set_mario_npc_dialog` (via the **cannon bob-omb buddy**) | `action`:=`ACT_READING_NPC_DIALOG`, `usedObj` | no | **YES** | YES |
>
> **The refined spec that IS true:** *no object-side behavior in WMotR writes
> `pos[1]` (y), and the only object-side write to the `action` cell sets a
> single non-flying value (`ACT_READING_NPC_DIALOG`), never a value in the
> flying/taint set `T`.* Under this refined spec both the y-bound and the
> no-fly invariant cross the composition.
>
> **The dogs that did not bark (loud negatives):** the game's dangerous
> object-side y/velocity writers — `heave_ho` (`vel[1] = 95`), `chuckya`
> (`vel[1]`), `recovery_heart` (`healCounter`), `butterfly` (`gMarioObject->oPosY`)
> — are **all absent** from WMotR. No object in this level launches, lifts, or
> knocks Mario upward.

**Action item for the composition skeleton (T0):** `seg_rest`'s spec row must
be stated as the refined predicate above (`pos[1]` preserved + `action` writes
confined to `ACT_READING_NPC_DIALOG` ∉ `T`), **not** the bare "no Mario writes."
Two of the three writers (#1 pos-x/z, #3 action) are genuine composition
concerns and must appear explicitly; #2 (`numLives`) is invisible to both
invariants but must be acknowledged so the spec is not overclaimed.

---

## 1. The closed object/behavior set

Level script [`levels/wmotr/script.c`](../vendor/sm64/levels/wmotr/script.c)
and macro table
[`areas/1/macro.inc.c`](../vendor/sm64/levels/wmotr/areas/1/macro.inc.c),
read in full; macro→behavior via
[`include/macro_presets.inc.c`](../vendor/sm64/include/macro_presets.inc.c).
Cross-checks the E1 inventory (all objects match).

### 1a. Level-script objects (`script.c`)

| behavior | count | cite | native update fn(s) |
|---|---|---|---|
| `bhvMario` | 1 | script.c:45 | `bhv_mario_update` (= Mario's slice) + 2 debug fns |
| `bhvPoleGrabbing` | 6 | script.c:19–24 | `bhv_pole_init`, `bhv_pole_base_loop` |
| `bhvHiddenRedCoinStar` | 1 | script.c:29 | `bhv_hidden_red_coin_star_init/_loop` |
| `bhvAirborneWarp` | 1 | script.c:51 | **none** — script body is `BREAK()` (behavior_data.c:3547–3548) |

### 1b. Macro objects (`macro.inc.c` → preset → behavior)

| preset | count | macro.inc.c | behavior | native update fn |
|---|---|---|---|---|
| `macro_cannon_closed` | 2 | :3,:4 | `bhvCannonClosed` | `bhv_cannon_closed_init/_loop` |
| `macro_bobomb_buddy_opens_cannon_1` | 1 | :5 | `bhvBobombBuddyOpensCannon` | `bhv_bobomb_buddy_init/_loop` |
| `macro_coin_ring_horizontal_flying` | 1 | :6 | `bhvCoinFormation` | `bhv_coin_formation_init/_loop` |
| `macro_coin_ring_vertical_flying` | 4 | :24–27 | `bhvCoinFormation` | ″ |
| `macro_box_1up` | 1 | :7 | `bhvExclamationBox` (BP_1UP_WALKING) | `bhv_exclamation_box_loop` |
| `macro_box_wing_cap` | 6 | :15–20 | `bhvExclamationBox` (BP_WING_CAP) | ″ |
| `macro_hidden_1up_in_pole` | 1 | :8 | `bhvHidden1UpInPoleSpawner` | `bhv_1up_hidden_in_pole_spawner_loop` |
| `macro_red_coin` | 8 | :9–14,:22,:23 | `bhvRedCoin` | `bhv_red_coin_init/_loop` |
| `macro_1up` | 2 | :21,:28 | `bhv1Up` | `bhv_1up_init/_loop` |

### 1c. Spawn chains (one level chased — what these behaviors spawn at runtime)

- `bhvExclamationBox` (wing-cap box) → on break spawns `bhvWingCap`
  (`exclamation_box.inc.c:24,132` via `sExclamationBoxContents`) + a
  `bhvRotatingExclamationMark` (:67); the `macro_box_1up` variant spawns
  `bhv1UpWalking` (:31). Plus mist/triangle particles + a sound spawner (:148–150).
- `bhvCannonClosed` → when cannon unlocked, spawns `bhvCannon`
  (`cannon_door.inc.c:6`), which `SPAWN_CHILD`s `bhvCannonBarrel`
  (behavior_data.c:632).
- `bhvBobombBuddyOpensCannon` → runs cannon-open cutscene; spawns nothing
  Mario-relevant.
- `bhvCoinFormation` → spawns `bhvCoinFormationSpawn` → `bhvYellowCoin`
  (`coin.inc.c:216,127`) + golden-coin sparkles.
- `bhvHidden1UpInPoleSpawner` → spawns `bhvHidden1UpInPole` +
  `bhvHidden1UpInPoleTrigger` (`mushroom_1up.inc.c:330–332`).
- `bhv1Up`/`bhv1UpWalking`/`bhvHidden1UpInPole` → sparkles (`bhvSparkleSpawn`).
- `bhvRedCoin` → `coin_collected` spawns `bhvGoldenCoinSparkles`
  (`moving_coin.inc.c:49`); on the **8th** coin `bhvHiddenRedCoinStar` spawns
  the cutscene star (`bhvStarSpawnCoordinates`, `spawn_star.inc.c:172`).
- Cosmetic terminals (`bhvSparkleSpawn`, `bhvGoldenCoinSparkles`,
  `bhvCoinSparkles`, mist/triangle particles, `bhvRotatingExclamationMark`,
  `bhvSoundSpawner`) — no Mario access (spot-checked).

---

## 2. Per-behavior store-scout verdicts

### WRITES-MARIO (the three exceptions)

**`bhvPoleGrabbing` → `cur_obj_push_mario_away`** — WRITES `pos[0]`,`pos[2]`.
`bhv_pole_base_loop` (`pole_base.inc.c:3–10`) calls `cur_obj_push_mario_away(70.0f)`
when Mario is within the pole's vertical span (`:4–5`), `oTimer>10`, and
`!(action & MARIO_PUNCHING)` (`:6`). The callee
(`object_helpers.c:2200–2211`) writes **only**:
```
gMarioStates[0].pos[0] += (radius - marioDist)/radius * marioRelX;   // :2208
gMarioStates[0].pos[2] += (radius - marioDist)/radius * marioRelZ;   // :2209
```
Horizontal only — **never `pos[1]`, never `action`**. (This is the "bonk off
an ungrabbed pole" nudge; grabbing is Mario-side `interact_pole`.) The 6 poles
are the level's designed climbing route, so this write fires on the main path.
**pos[1]/action risk: NONE.**

**`bhv1Up` family → `bhv_1up_interact`** — WRITES `numLives`.
`mushroom_1up.inc.c:8`: `gMarioState->numLives++`, gated on
`obj_check_if_collided_with_object(o, gMarioObject)` (:6). Reached by `bhv1Up`
(`bhv_1up_loop`:195), `bhv1UpWalking` (`:104,109`), and `bhvHidden1UpInPole`
(`pole_1up_move_towards_mario`:59). Writes **only** `numLives` — a `MarioState`
field, so a genuine block write, but **invisible to y and action.**
**pos[1]/action risk: NONE.**

**`bhvBobombBuddyOpensCannon` → `set_mario_npc_dialog`** — WRITES `action`,`usedObj`.
`bhv_bobomb_buddy_loop` (`bobomb.inc.c:438`) → `bobomb_buddy_act_talk` (:376) →
`set_mario_npc_dialog(MARIO_DIALOG_LOOK_FRONT)` (:377), and the STOP path (:365,384).
The callee (`mario_actions_cutscene.c:345–367`) at :361–362:
```
gMarioState->usedObj = gCurrentObject;
set_mario_action(gMarioState, ACT_READING_NPC_DIALOG, actionArg);
```
This is the **only object-side write to the action cell in the entire level.**
Gated by `mario_ready_to_speak()` + Mario initiating INTERACT_TEXT (:360). The
value written is `ACT_READING_NPC_DIALOG` — a stationary grounded cutscene
action, **∉ the flying/taint set `T`** and no y-change. So it does not break
the no-fly invariant, but it **does** write the cell the invariant tracks — the
composition's `seg_rest` spec cannot say "action cell untouched"; it must say
"action only set to `ACT_READING_NPC_DIALOG`." The buddy sits at
(3684,−2712,4660) (SE island, across the death void), so reachability is a
further (horizontal) gate, but that is not a source-level guarantee.
**pos[1] risk: none. action risk: writes a NON-flying action (benign but present).**

### NO-MARIO-WRITES (the common case — all others)

| behavior | update fn (file) | writes | note |
|---|---|---|---|
| `bhvExclamationBox` | `bhv_exclamation_box_loop` (exclamation_box.inc.c) | own `o->*` only; reads `gMarioObject->oMoveAngleYaw` (:135) | SPAWNS wing cap / 1up / particles |
| `bhvWingCap` | `bhv_wing_vanish_cap_loop` (cap.inc.c) | none touching Mario (grep: 0 hits) | flight is granted Mario-side `interact_cap` |
| `bhvCannonClosed` / `bhvCannon` | `bhv_cannon_closed_loop` (cannon_door.inc.c), `bhv_cannon_base_loop` (cannon.inc.c) | own `o->*` only (grep: 0 Mario hits in cannon.inc.c) | cannon *entry* (`ACT_IN_CANNON`) is Mario-side interaction |
| `bhvCoinFormation` + coins | coin.inc.c | own `o->*` only | collection is Mario-side; `coin_collected` (moving_coin.inc.c:48) writes only `o->*` |
| `bhvRedCoin` | `bhv_red_coin_loop` (red_coin.inc.c:51) | `o->parentObj->oHiddenStarTriggerCounter++` (the STAR obj) | `coin_collected` only; `bhv_red_coin_init` calls `find_floor` (read-only) |
| `bhvHiddenRedCoinStar` | spawn_star.inc.c:160 | global `gRedCoinsCollected` (:161), not a MarioState field | spawns cutscene star at 8/8 |
| `bhvHidden1UpInPoleSpawner` / `…Trigger` | mushroom_1up.inc.c:327,316 | own `o->*` / `hidden1Up->o*` | trigger writes another object, not Mario |
| `bhvAirborneWarp` | — | none (`BREAK()`) | inert object-side; warp is level-phase |
| `bhvMario` debug fns | `try_print_debug_mario_level_info`, `try_do_mario_debug_object_spawn` (debug.c) | none (reads controller JPAD only) | debug object spawns, no Mario write |
| engine helpers | `bhv_init_room` (object_helpers.c), `load_object_collision_model` (surface_load.c) | 0 Mario hits | room/collision only |

---

## 3. The behavior-VM side (does the interpreter itself write Mario?)

The VM is `object_list_processor.c` / `engine/behavior_script.c` running each
object's script. It operates on `gCurrentObject` (the object being processed);
it writes each object's **own** slots, never another object's, and never a
`MarioState` field. The only Mario touchpoints are Mario's *own* processing:

- `copy_mario_state_to_object` (`object_list_processor.c:224–250`) **reads**
  `gMarioStates[i]` and **writes** `gCurrentObject` (the Mario *object*) —
  direction MarioState→object; no MarioState write. Part of Mario's slice.
- The interaction channel: objects set `gMarioObject->oInteractStatus` (the
  Mario **object** struct, a *different* memory block from `MarioState`) as
  the designed flag path, consumed Mario-side by `mario_process_interactions`
  inside `seg_action`. **In WMotR's set, no behavior even does this** — the
  only such writers game-wide (`hoot`, `heave_ho`, `chuckya`, `bowser`,
  `shock_wave`, and `bobomb.inc.c:192` which is the *enemy* `bhvBobomb`, not
  the buddy `bhvBobombBuddyOpensCannon` in this level) are all absent. Verified
  by grep of `gMarioObject->… =` across `src/game/behaviors/`.

So the VM adds **no** Mario-block writes beyond the three §2 behaviors.

---

## 4. Summary table

| behavior | WMotR objects | Mario-writes? | pos[1]/action risk | spawn chain |
|---|---|---|---|---|
| `bhvPoleGrabbing` | 6 poles | **YES** `pos[0],pos[2]` | none | — |
| `bhv1Up` / spawned 1ups | 2 + box + pole-hidden | **YES** `numLives` | none | sparkles |
| `bhvBobombBuddyOpensCannon` | 1 | **YES** `action:=ACT_READING_NPC_DIALOG`,`usedObj` | **action (non-fly)** | cutscene |
| `bhvExclamationBox` | 6 wing-cap + 1 1up-box | no | none | `bhvWingCap`/`bhv1UpWalking`/particles |
| `bhvWingCap` | spawned | no | none | — |
| `bhvCannonClosed`/`bhvCannon` | 2 | no | none | `bhvCannon`/`bhvCannonBarrel` |
| `bhvCoinFormation` + coins | 5 rings | no | none | yellow coins |
| `bhvRedCoin` | 8 | no | none | sparkles; star at 8/8 |
| `bhvHiddenRedCoinStar` | 1 | no (global `gRedCoinsCollected`) | none | cutscene star |
| `bhvHidden1UpInPoleSpawner` | 1 | no | none | hidden 1up + triggers |
| `bhvAirborneWarp` | 1 | no (`BREAK`) | none | — |
| `bhvMario` debug fns | 1 | no | none | debug objects |

**Overall:** three benign exceptions; refined `seg_rest` spec (§ VERDICT) holds.

### Loud flags for the eventual Coq (genuine composition concerns, not nits)

1. **Object-side action write.** `set_mario_action(…, ACT_READING_NPC_DIALOG)`
   via the bob-omb buddy is a real write to the action cell from outside
   Mario's slice. `seg_rest`'s spec MUST enumerate this value (∉ `T`) or gate
   it by the buddy's cross-void unreachability. Do not state "action untouched."
2. **Object-side horizontal-position write.** The pole push writes `pos[0]/pos[2]`
   on the main climbing path. Harmless to the y-bound but the spec must permit
   x/z writes rather than claim "pos untouched."

### Adjacent segments (out of `seg_rest`, noted for completeness)

- `seg_level` (level_update): the instant-warp displacement writes
  `gMarioState->pos[0/1/2]` (`level_update.c:546–548`, **includes pos[1]**) —
  belongs to the TELEPORT census, not `seg_rest`. WMotR's warp nodes are the
  self-loop airborne warp + success/death/floor exits (script.c:52–55); the
  instant-warp *displacement* table for this level must be censused separately
  (plan §2 TELEPORT row).
- `seg_platform` (platform_displacement): writes `pos[0/1/2]`
  (`platform_displacement.c:82–84`) but is y-inert in WMotR per T1
  (NULL-or-box, both arms y-identity).
- The 8/8-coin star spawn calls `set_time_stop_flags(TIME_STOP_MARIO_AND_DOORS)`
  (`spawn_star.inc.c:50`) — a global flag, not a MarioState write, and only
  reachable *after* the star condition is met (i.e. after the theorem has
  already been lost); irrelevant to the impossibility argument.

---

## 5. Rung-5 walkability ledger (linked vs. un-generated)

Which behavior update functions are already in a **clightgen'd, linked** TU
(ready to walk) vs. **un-generated** (need `clightgen` first for rung 5):

| behavior fn | source `.inc.c` | unity TU | in `generated/`? | status |
|---|---|---|---|---|
| `bhv_pole_base_loop` (+ pole init) | pole_base.inc.c, pole.inc.c | `behavior_actions.c` | **YES** `behavior_actions.v` | LINKED |
| `bhv_exclamation_box_loop` | exclamation_box.inc.c | `behavior_actions.c` | **YES** | LINKED |
| `bhv_coin_formation_loop` (+ coins) | coin.inc.c | `behavior_actions.c` | **YES** | LINKED |
| `bhv_cannon_base_loop` / barrel | cannon.inc.c | `behavior_actions.c` | **YES** | LINKED |
| `bhv_1up_loop` / `bhv_1up_interact` | mushroom_1up.inc.c | `obj_behaviors.c` | **no** | UN-GENERATED |
| `bhv_bobomb_buddy_loop` | bobomb.inc.c | `obj_behaviors.c` | **no** | UN-GENERATED |
| `bhv_cannon_closed_loop/_init` | cannon_door.inc.c | `obj_behaviors.c` | **no** | UN-GENERATED |
| `bhv_red_coin_loop/_init` | red_coin.inc.c | `obj_behaviors.c` | **no** | UN-GENERATED |
| `bhv_hidden_red_coin_star_loop/_init` | spawn_star.inc.c | `obj_behaviors.c` | **no** | UN-GENERATED |

**Callee locations of the three Mario-writers:**
- `cur_obj_push_mario_away` → `object_helpers.c` — **UN-GENERATED**; currently
  an external symbol referenced from the linked `behavior_actions.v` (the pole
  loop calls it), so walking the pole write needs `object_helpers.c` generated
  or a named boundary row for this one callee.
- `set_mario_npc_dialog` / `set_mario_action` → `mario_actions_cutscene.c` —
  **LINKED** (`generated/mario_actions_cutscene.v`); walkable today.
- `bhv_1up_interact`'s `numLives++` → `obj_behaviors.c` — **UN-GENERATED**.

**Rung-5 cost summary:** of the three real Mario-writers, one lives in a
linked TU (bob-omb action write, `mario_actions_cutscene.v`) and two need a
`clightgen` of `obj_behaviors.c` (1up `numLives`) + `object_helpers.c` (pole
push). The remaining NO-MARIO-WRITES behaviors split 4 linked
(`behavior_actions.c`) / 5 un-generated (`obj_behaviors.c`); walking them for
rung 5 confirms "no Mario write" but is not required to state the refined
`seg_rest` spec — this census already discharges it at the source level.
