# GOAL 2, TRUST row 0.3: height bound ⇒ coin #2 never collected ⇒ no star

Research note (2026-09-27). All paths are relative to `vendor/sm64/` unless marked otherwise.
**IN** = the code is in one of the 12 clightgen'd TUs under `generated/`. **OUT** = it is not.

## 0. The coin in question

`levels/wmotr/areas/1/macro.inc.c:10`: `macro_red_coin` at (2735, 3140, -3085).
`include/macro_presets.inc.c:14`: `macro_red_coin` → `{ bhvRedCoin, MODEL_RED_COIN, 0 }`.

WMotR has 8 red coins (macro.inc.c:9-14, 22-23), at y = 3990, **3140**, 4600, 240, -2680, -1360, 1725, 4600.
Four of them are above 2744: 3990, 3140, 4600, 4600. Coin #2 (y = 3140) is the lowest of those four, so
it gives the weakest requirement. Any of the four would do.

## 1. Touch test: the minimal Mario y is 2980

- Coin hitbox, `src/game/behaviors/red_coin.inc.c:11-21` (`sRedCoinHitbox`): INTERACT_COIN,
  downOffset 0, radius 100, height 64. It is set by `obj_set_hitbox` (red_coin.inc.c:44). That call
  scales by `gfx.scale` (`src/game/object_helpers.c:2136`), and the scale is 1 because the macro sets no scale.
- Mario's hitbox: `data/behavior_data.c:3511` `SET_HITBOX(37, 160)`, downOffset 0. The height is
  re-set every frame in `src/game/mario.c:1649-1653`: 100 if `ACT_FLAG_SHORT_HITBOX`, else 160 (**IN**, mario.c).
- Mario's object position comes from `m->pos` via `copy_mario_state_to_object`
  (`src/game/object_list_processor.c:224`, called at :276 after `execute_mario_action`). **OUT**.
- The overlap test is `detect_object_hitbox_overlap(a, b)`, `src/game/object_collision.c:25-63`. **OUT**.
  Call chain: `detect_object_collisions` (:176, from object_list_processor.c:658) →
  `check_player_object_collision` (:126) → `check_collision_in_list(mario, OBJ_LIST_LEVEL…)` (:134).
  So `a` = Mario, `b` = coin. The coin must have `oIntangibleTimer == 0` (:114-116).
  - Horizontal: `100 + 37 > sqrtf(dx²+dz²)`, i.e. distance < 137 (:31-34).
  - Vertical: the test fails if `marioY > coinY + 64` (:38) or `marioY + H_mario < coinY` (:41).
  - With H_mario ≤ 160 and coinY = 3140, a touch **requires `marioY + 160 ≥ 3140` in f32, i.e.
    `marioY ≥ 2980`**. The short hitbox makes the requirement stricter (3040). The coin's downOffset is 0 and its
    height of 64 only matters for the upper bound. Near 3000, f32 addition of 160 is exact, so the
    threshold is exactly 2980. The margin over YMAX = 2744 is 236.
- **Can the coin move?** No. `bhvRedCoin` (`data/behavior_data.c:4633-4645`) runs only `bhv_init_room`,
  `bhv_red_coin_init` and `bhv_red_coin_loop`, plus `oAnimState++`. There is no velocity, gravity or
  `cur_obj_move_*`. The coin's oPosY stays at the spawn value, 3140.
- Collision → interaction: `mario_process_interactions` reads `marioObj->collidedObjs` and calls
  `interact_coin` (`src/game/interaction.c:743-747`), which sets `o->oInteractStatus = INT_STATUS_INTERACTED`. **IN**.

## 2. Counting and star spawn (all OUT: red_coin.inc.c and spawn_star.inc.c are `#include`d by `src/game/obj_behaviors.c:834-835`, which is not one of the 12 TUs)

- `bhv_red_coin_init` (red_coin.inc.c:26-45) sets `parentObj` to the nearest `bhvHiddenRedCoinStar`.
- `bhv_red_coin_loop` (red_coin.inc.c:51-80): when INT_STATUS_INTERACTED is set, it runs
  `parentObj->oHiddenStarTriggerCounter++` (:57), then `coin_collected()`, which despawns the coin. So each coin counts once.
- `bhv_hidden_red_coin_star_init` (`src/game/behaviors/spawn_star.inc.c:142-158`) sets
  counter = 8 − `count_objects_with_behavior(bhvRedCoin)`. If that count is 0, it spawns a `bhvStar` at once (:150-155).
- `bhv_hidden_red_coin_star_loop` (:160-178): `gRedCoinsCollected = counter`. When **counter == 8** it
  runs `spawn_red_coin_cutscene_star` (:131) → `spawn_star` (:114), which creates a `bhvStarSpawnCoordinates`
  that carries the parent's `oBhvParams` (star index ACT_1).
- The spawner: `levels/wmotr/script.c:29` `bhvHiddenRedCoinStar` at (-160, 1950, -470), BPARAM1(STAR_INDEX_ACT_1).

## 3. Star collection and the save bit (IN)

`interact_star_or_key` (`src/game/interaction.c` ~766-812): `starIndex = (oBhvParams >> 24) & 0x1F`,
then `save_file_collect_star_or_key(m->numCoins, starIndex)` (:812). The save function itself is in
`src/game/save_file.c:357`, **OUT**.
Other star sources: the 100-coin star in `interact_coin` (interaction.c:749-750) is gated by
`COURSE_IS_MAIN_COURSE`, and WMotR is bonus course 23 (`levels/course_defines.h:37`,
`include/course_table.h:29`). So it cannot fire here. There is no other `bhvStar*` object in `levels/wmotr/`.

## 4. Objects that can bump the counter or spawn a star

- Counter writers: the 8 `bhvRedCoin` macros (macro.inc.c:9-14, 22-23), plus the star's own init (line 157).
- Star spawners: only `bhvHiddenRedCoinStar` (script.c:29). The rest of the level is cannons, a bob-omb buddy,
  coin rings, 1-ups, wing-cap boxes and poles (script.c:19-24).
- Caveat: `INT_STATUS_INTERACTED` could in principle be set on a coin by code other than Mario's
  interaction. No WMotR object does this, but that is a trust claim.

## 5. Proposed Coq shape

```
Lemma coin2_untouchable : forall st, reachable_noA st ->
  mario_posY st <= 2744 ->   (* HeightFrame capstone *)
  ~ hitbox_overlap (mario_obj st) coin2.     (* 2744 + 160 < 3140 *)
Theorem wmotr_noA_no_star : forall run, noA run ->
  forall t, ~ star_collected run t STAR_INDEX_ACT_1.
```
The first lemma is pure arithmetic over a **modelled** `detect_object_hitbox_overlap` (it is OUT of the link).
The rest needs new TRUST rows:
1. Object-collision code (object_collision.c:25-63, :126-136) and `copy_mario_state_to_object`, both OUT.
   Either clightgen them as a 13th/14th TU or add them as a tether row.
2. Level data: the coin positions (macro.inc.c), their hitbox (red_coin.inc.c:11), Mario's hitbox (behavior_data.c:3511),
   and the claim that bhvRedCoin is static.
3. Counter semantics (red_coin.inc.c, spawn_star.inc.c, OUT): the star appears only at counter 8, and only a coin
   touched by Mario increments it. Also: no other star object exists, and the 100-coin star is off for bonus courses.
4. Only the `interact_star_or_key` → save bit step is IN the link.
