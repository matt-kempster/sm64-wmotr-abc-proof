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

The current Coq capstone checks items 1-4 at the source-reduction level and
computes the flat-floor speed witnesses. It leaves item 5 and the Clight
execution bridge open.
