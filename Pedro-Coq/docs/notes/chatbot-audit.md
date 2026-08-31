# Audit of the motivating chatbot explanation

## Confirmed by pinned source shape

- `perform_air_quarter_step` computes a candidate floor and ceiling.
- If `nextPos[1] <= floorHeight`, horizontal position, `m->floor`, and
  `m->floorHeight` update only when `ceilHeight - floorHeight > 160.0f`.
- The same outer branch writes `m->pos[1] = floorHeight` and returns
  `AIR_STEP_LANDED` even when the gap is at most 160.
- `common_landing_action` uses analog input bit `INPUT_NONZERO_ANALOG` to select
  `apply_landing_accel(m, 0.98f)`.
- With no analog input and `forwardVel >= 16.0f`, it selects
  `apply_slope_decel(m, 2.0f)`.
- After the ground step, `forwardVel > 16.0f` sets `PARTICLE_DUST`.

## Corrections and missing premises

1. Dust is not created by the `AIR_STEP_LANDED` return itself. The action
   dispatch must reach a compatible landing action on a later frame.
2. `0.98f` multiplication is conditional on `!mario_floor_is_slope(m)` inside
   `apply_landing_accel`; slope acceleration occurs before that test.
3. Neutral-input deceleration is not one arbitrary floor-specific constant.
   With coefficient 2 it is 0.4, 1.4, 4.0, or 6.0 before the subsequent slope
   acceleration, depending on the generated floor-class branch.
4. Setting `PARTICLE_DUST` does not itself mutate `gRandomSeed16`. The proof must
   traverse Mario particle dispatch, `bhvMistParticleSpawner`, both white-puff
   behavior-script/native-loop links, `obj_translate_xz_random`,
   `random_float`, and `random_u16`.
5. Selectable dust/non-dust arithmetic is not enough: both controller choices
   must keep Mario in the same Pedro spot and must be reachable under the
   concrete object schedule.

The current Coq capstones check items 1-4 at the source-reduction level and
compute the flat-floor speed witnesses. The linked-Clight frontier now executes
one generated WhitePuff2 `cur_obj_update` dispatch cycle and its `CALL_NATIVE`
command, including the native,
random-X/Z helper, two nested `random_float` calls, two nested `random_u16`
calls, seed stores, and X/Z stores in both versions. Item 5 and the surrounding
retail-frame bridge remain open. The exact generated parent-bit-clear handler
is now executed separately under explicit arbitrary-`genv` premises, including
its Mario bit-clear and cursor stores, but typed-link instantiation and the Mist
script dispatch that reaches it are not. The following `ADD_INT`/`END_REPEAT`,
function tail, list scheduler,
particle dispatch, spawn/allocation path, WhitePuff1, and a reachable stock
Pedro memory image are not yet linked into one big-step. In particular,
generated `segmented_to_virtual` reaches pointer-to-integer arithmetic that
requires an explicit N64-address refinement under CompCert's symbolic memory.
