# The real internal discharge surface: 17 non-writer functions

Computed 2026-06-03 from the clightgen'd `generated/mario.v` (static direct call
graph, whitespace-normalized; **0 indirect/function-pointer calls** in the set, so
the static graph is sound here).

`execute_mario_action` (the GOAL-1 frame) reaches, **within `mario.prog`'s 62
internal functions**, exactly **17** of them — and **none writes Mario's action
field**:

```
debug_print_speed_action_normal   mario_floor_is_slippery
mario_get_floor_class             mario_get_terrain_sound_addend
mario_reset_bodystate             mario_update_hitbox_and_cap_model
set_submerged_cam_preset_and_spawn_bubbles
sink_mario_in_quicksand           squish_mario_model
update_and_return_cap_flags       update_mario_button_inputs
update_mario_geometry_inputs      update_mario_health
update_mario_info_for_cam         update_mario_inputs
update_mario_joystick_inputs      vec3f_find_ceil
```

## Why this matters

- **The goal's "~61 internal non-set_mario_action functions" is an overcount.**
  The reach residual `reach_value_body_nonwriter` is only *consumed* for functions
  the frame actually reaches. That set is **17**, not 61.
- **No internal writer is reached.** `set_mario_action` (and the
  `set_*_action` / `init_mario` family) ARE defined in `mario.prog`, but the frame
  reaches them only through **external** TUs: the action dispatch
  (`mario_execute_{stationary,moving,airborne,submerged,cutscene,automatic,object}_action`)
  is external (mario_step.c / the action TUs), as are `mario_process_interactions`
  and `mario_handle_special_floors`. So **leaf B (the writer case) is entirely an
  EXTERNAL-residual concern** at this scope, not an internal one.
- **5 of the 17 are pure readers** (0 `Sassign`): `vec3f_find_ceil`,
  `mario_floor_is_slippery`, `mario_get_floor_class`,
  `mario_get_terrain_sound_addend`, `debug_print_speed_action_normal` — they
  preserve `action_sat` trivially (modulo their own calls).
- The 12 storing functions all take a single `_m : MarioState*` param (so
  `mid = _m`), but some store to **globals** (e.g. `update_mario_inputs` writes
  `gCameraMovementFlags`) and other non-Mario memory. Those stores are off-`bm` by
  **block distinctness** (static globals ≠ Mario's struct block, MarioMemWF), so
  they need the *wider* census (allow `mid->disjoint-field` OR off-`bm` store), not
  just `body_field_chk`'s `mid->field`-only form.

## Consequence for the discharge

The internal value discharge is a **reachability-rooted cross-call provenance
closure over 17 writer-free functions** (+ externals via `reach_ext`), not a
60-function fan-out. Architecture:

1. Extend `body_field_chk` to a wider per-function census allowing off-`bm` stores
   (globals/Objects) certified by block distinctness.
2. Census each of the 12 storing functions (`vm_compute`).
3. Root the cross-call provenance closure at `execute_mario_action` (it loads
   `gMarioState` → `bm`), threading the Mario-arg = `(bm,0)` precondition across the
   direct calls to the 17.
4. Rewire the capstone's `reach_value_body_nonwriter` through a reachability-aware
   engine built on `body_field_preserves` (RealFrameValue.v) instead of the
   `forall-le` phantom.

Regeneration: see the call-graph BFS in the session transcript (Python over
`generated/mario.v`, function-typed `Evar _NAME (Tfunction` = a direct call).
