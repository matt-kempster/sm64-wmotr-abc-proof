# Working claim and scope

## Game version

- Super Mario 64, North American release (`VERSION_US=1`)
- Reference decompilation source is the same source family used by
  `ssl-pyramid-item-proof`
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

If the generated C model or later SM64-derived lowering permits a transition
from the area-2 invariant to `abs x >= 32768` or `abs z >= 32768`, stop the
impossibility proof and document the concrete setup, transition, and resulting
coordinate.

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
