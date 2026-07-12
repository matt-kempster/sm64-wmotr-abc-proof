# Working claim and scope

## Game version

- Super Mario 64, North American release (`VERSION_US=1`)
- Reference decompilation source is the same source family used by
  `SSL-Cog/ssl-pyramid-item-proof`
- CompCert `clightgen` is the translation path for any C model committed here

## Boundary being studied

The target is SSL area 2, the Pyramid interior.

For this project, "entering a parallel universe" means reaching a position
whose horizontal coordinate is outside the modeled base world copy by a
non-zero multiple of the SM64 signed-16-bit coordinate period. The first
mechanized version will use a conservative integer abstraction:

- base area bound: `-8192 <= x,z <= 8191`
- signed coordinate period: `65536`
- first PU threshold: `32768`
- entering a PU requires `abs x >= 32768` or `abs z >= 32768`

The actual source-level motivation is `surface_collision.c`: floor, wall, and
ceiling lookup cast float positions to `TerrainData`/`s16` before collision
cell selection, which is the documented source of PU aliasing.

## Candidate formal statement

If Mario begins a normal SSL area 2 frame inside the modeled interior bound,
and the generated step model applies only a bounded per-frame displacement
whose result is clamped back to the area-2 interior, then the resulting state
is not in a parallel universe.

The first capstone will be conditional on a certificate that the frame is a
normal SSL area 2 frame and that the bounded-area invariant holds. Later work
can lower that certificate toward generated SM64 movement and collision code.

## Counterexample exit ramp

The unqualified claim that every Area 2 movement source preserves the bound is
now false at this abstraction level. The generated movement-source audit found
real Clight paths that write Mario's position without the bounded-step clamp:

- `perform_air_step` calls `perform_air_quarter_step`, and the quarter-step
  body assigns through `MarioState.pos`.
- `apply_mario_platform_displacement` calls `apply_platform_displacement`,
  which calls `set_mario_pos`, and `set_mario_pos` assigns through
  `MarioState.pos`.

`proofs/MovementSourceFacts.v` formalizes two counterexample-shaped source
models:

- starting at `x = 8191`, a horizontal air velocity whose quarter-step delta is
  `32768 - 8191` lands at the first PU threshold;
- starting at `x = 8191`, a platform displacement of `32768 - 8191` lands at
  the first PU threshold.

These are counterexamples to the bounded certificate as a complete account of
Area 2 movement. They are not yet a full in-game route: the remaining question
is whether SSL Area 2 can reach the required velocity or platform displacement
state from normal gameplay/glitch actions.

The next source-level lowering targets the air-velocity side through BLJ. In
the generated `mario.c` AST, the `ACT_LONG_JUMP` branch of
`set_mario_action_airborne` assigns through `forwardVel`, contains the `1.5f`
multiplier, and contains the `48.0f` positive-speed cap. That is exactly the
US-source asymmetry needed for negative BLJ speed growth. In the generated
`mario_actions_moving.c` AST, `act_long_jump_land` calls
`common_landing_cancels`, passes the `set_jumping_action` callback and
`sLongJumpLandAction`, and does not directly assign `forwardVel`.

`proofs/BLJRoute.v` formalizes the finite lowering envelope. It models repeated
negative BLJ speed growth by exact dyadic magnitudes: each recycle multiplies
speed magnitude by `3/2`. Starting from a `-16` speed magnitude, 22 recycles
exceed the `98304` horizontal velocity needed for one air step from
`x = -8192` to reach `x = -32768`. This refutes a source-level claim that all
reachable Mario horizontal velocities are uniformly bounded by the normal
movement constants. It still leaves a narrower route obligation: prove that
SSL Area 2 geometry and inputs can realize the 22 recycles while Mario remains
within the Area 2 setup bounds.

`proofs/BLJGeometry.v` now checks the first geometry/input lowering. The
generated `mario_actions_moving.c` AST contains the landing input gate:
`common_landing_cancels` checks `INPUT_A_PRESSED`, and `act_long_jump_land`
checks `INPUT_Z_DOWN` before preserving the A-press recycle path. The SSL Area
2 collision audit records the lower-entry stair band as concrete in-bounds
static treads. That candidate is too small: the source-backed narrow tread
certificate has capacity 8, while `BLJRoute.v` requires 22 recycles from the
modeled `-16` starting magnitude. The theorem
`ssl_area2_lower_entry_geometry_input_status` proves this mismatch. So the
direct lower-entry static-stair counterexample is refuted; a full positive
route would need a stronger dynamic collision certificate, a reusable
wall/ceiling/stair setup, or a source-backed way to start with much more
negative speed.

The next candidate is now source-identified rather than hypothetical. SSL Area
2 places a vertical Grindel at `(3297, 0, 95)` with behavior parameter 28. The
canonical Grindel behavior has a long rising phase in 10-unit increments. This
is larger than the 7.5-unit first quarter-step rise of a long jump, so it can
provide the repeated rising-floor interruption used by an elevator BLJ. The
additional generated Clight units needed to formalize that dynamic certificate
are now part of the project; the certificate itself remains the active proof
obligation.

## Current status

The isolated project scaffold exists. `inputs/pu_model.c` contains the first C
model for bounded SSL area 2 movement and PU detection, and
`generated/pu_model.v` is the corresponding committed CompCert Clight AST.

`proofs/ASTFacts.v` pins generated-program shape facts: the capstone wrapper
calls the normal step and then the PU detector; the normal step calls the delta
and coordinate clamps; and it writes `x` and `z` without assigning `area`.

`proofs/Spec.v` proves the arithmetic invariant: any coordinate inside
`[-8192, 8191]` has absolute value below `32768`, and the modeled normal
area-2 step clamps both horizontal coordinates back into that interval.

`proofs/ParallelUniverse.v` states the current capstone theorem
`ssl_area2_no_parallel_universe`. This is a generated-model theorem over the
bounded SSL area 2 transition certificate, not yet a full semantic lowering of
the real SM64 movement engine.

The next audit layer targets the actual SM64 movement-source translation units:
`src/game/mario_step.c` and `src/game/platform_displacement.c`.

`proofs/MovementSourceFacts.v` is the first result of that audit. It checks the
generated Clight AST shape for those translation units and proves
`bounded_certificate_does_not_cover_movement_sources`, which packages the
source-shape facts with the two arithmetic counterexamples above.

`proofs/BLJRoute.v` is the second result. It proves
`ssl_area2_blj_source_counterexample_envelope`, a source-level counterexample
envelope for the air-velocity path.

`proofs/BLJGeometry.v` is the third result. It proves
`ssl_area2_lower_entry_geometry_input_status`: the generated input/action gate
for BLJ recycling exists, the audited lower-entry static treads are inside the
modeled Area 2 bounds, and that finite static-tread certificate cannot provide
the 22 recycles needed by the BLJ envelope.

The remaining route question is narrower than before: mechanize a dynamic
repeated-reuse collision certificate, identify another Area 2 setup with enough
initial negative speed or enough certified recycles, or prove source-backed
bounds excluding those stronger setups.
