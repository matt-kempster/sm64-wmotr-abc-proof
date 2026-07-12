# Working claim and scope

## Game version

- Super Mario 64, North American release (`VERSION_US=1`)
- Reference decompilation source is from the same source family used by
  `SSL-Cog/ssl-pyramid-item-proof`
- CompCert `clightgen` is the translation path for committed C inputs

## Boundary being studied

The target is SSL Area 2, the Pyramid interior. The project uses the following
conservative first-PU abstraction:

- modeled Area 2 bound: `-8192 <= x,z <= 8191`
- signed coordinate period: `65536`
- first PU threshold: `32768`
- a PU state has `abs x >= 32768` or `abs z >= 32768`

The source-level mechanism is the float-position to signed-16 collision lookup
conversion. Static floor and ceiling lookup therefore reuses Area 2 collision
at signed-16 aliases of distant coordinates.

## Bounded theorem

`proofs/ParallelUniverse.v` proves
`ssl_area2_no_parallel_universe`: a modeled normal Area 2 step that clamps both
horizontal coordinates back into the bounded interval cannot enter a PU. That
conditional theorem remains valid, but it does not cover every real movement
source.

Generated Clight audits then established that `perform_air_quarter_step` and
platform displacement write Mario's position outside that clamp. The US
long-jump branch multiplies `forwardVel` by `1.5f` without a negative hard cap,
and the A+Z landing path permits repeated long-jump recycling.

## Dynamic counterexample

The unqualified impossibility claim is false in the current source-shaped
model. `proofs/BLJDynamic.v` proves
`ssl_area2_grindel_dynamic_counterexample_certificate` using the vertical
Grindel placed at `(3297, 0, 95)` with behavior parameter 28.

The certificate fixes this finite trace:

1. Mario begins on the Grindel at its bottom with forward speed `11`, facing
   along the X route, and starts a normal long jump during the bottom idle
   window.
2. Sixteen full-back air updates apply the source order `.35` approach,
   `1.5` analog acceleration, then the `-16` soft-cap correction. Speed becomes
   `-8.4`.
3. The first 10-unit Grindel rise overtakes the long jump's third quarter step:
   quarter step 2 remains above the floor, while quarter step 3 is below it.
4. Nine immediate A+Z recycles remain inside the Grindel top footprint. The
   tenth long jump crosses the top edge.
5. Its first frame reaches static-floor X coordinates `3609`, `3726`, `3842`,
   and `3958`. The next quarter-step target truncates to `4074`, beyond the
   audited static mesh maximum `3994`, so the floor-null path keeps X fixed
   while Mario completes the arc.
6. The release lands with negative speed magnitude above `400`. Each later
   floor-null long-jump arc has 16 air updates, so its landing recurrence is
   `m' = 3/2*m - 16*(17/20)`.
7. The first 20 target aliases lie outside the static mesh X envelope. Target
   21 reaches X `522262`, aliases to `-2026`, and finds the audited Area 2
   floor triangle with vertices `(-2546,-101,-25)`, `(-1522,-101,230)`, and
   `(-1522,-101,-25)`.

The final modeled state is in SSL Area 2 and beyond the first PU threshold.

## Source certificate

The capstone packages generated AST checks for:

- the Grindel bottom timing and 10-unit rising behavior;
- terrain-object update before platform displacement and Mario action update;
- the platform-displacement omission of vertical velocity;
- the action executor's subframe transition loop;
- long-jump vertical speed `30` and horizontal multiplier `1.5`;
- airborne approach, analog acceleration, soft-cap constants, and velocity
  assignment;
- four air quarter steps, floor lookup, landing return, position/floor writes,
  and post-step gravity.

`pipeline/check_grindel_route.py` independently checks the level placement,
canonical source literals, exact Grindel top triangles, Area 2 mesh envelope,
four release-floor points, first floor-null point, and final alias triangle.

## Formal boundary

This is a generated-Clight source-shape certificate composed with an exact
rational execution model and audited collision literals. It is stronger than
an unbounded source-state witness: its initial speed, timing, moving floor,
recycles, release, floor-null arcs, and final alias are finite and concrete.

It is not yet a full CompCert operational-semantics derivation of the complete
float32 gameplay execution. Such a lowering is optional follow-up work; the
current project verdict is the concrete dynamic counterexample, not the
original unqualified impossibility claim.
