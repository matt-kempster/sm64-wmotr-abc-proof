# Ordinary-motion tranche

## Verdict

Ordinary motion has **not** been eliminated for every clean US or JP
execution.  This tranche proves a narrower upper-elevator arithmetic and
source-mesh kernel, exposes the correct preservation theorem needed for a
retail proof, and identifies two false shortcuts:

1. no `A_BUTTON_PRESSED` edge does not imply that Mario cannot ascend; and
2. an abstract event labeled `MotionPhysicsFrame` is not evidence that retail
   physics produced its endpoint.

No retail trace reaching either target region, and no newly set Act 3 or Act 6
save bit, was found here.

## Turning-Part-2 report

The separate animation audit does not add a new ordinary-motion primitive.
In the non-stopping turning handler, `perform_ground_step` runs before the
`forwardVel >= 18.0f` selector; in the finish-turning handler, animation
selection precedes its ground step.  In both orders the Part-2 metadata setter
preserves MarioState, raw Object, and Graphics-anchor coordinates in the
proved model.  The repeated value 189 gives renderer scale `189/189 = 1`, not
a Y displacement.  Consequently a same-frame turning upwarp must still be
classified through the real ground-step/floor, platform, or OOB writer path.
The linked animation-buffer/DMA footprint remains a narrow refinement
obligation.  See
[`turning-animation-upwarp.md`](turning-animation-upwarp.md).

## What counts as ordinary motion

The ordinary class includes controller-directed walking, existing momentum,
gravity, falling, sliding, landing, pole actions, and normal floor/wall/ceiling
resolution.  It does not include platform displacement, object impulses,
area-entry initialization, warp/reload displacement, or a collision
clip/tunnel.  Those have separate first-crossing classes.

The source writer boundary is larger than a single call to
`perform_ground_step` or `perform_air_step`.  It also includes:

- the pre-action wall push and graphical-position fallback in
  `update_mario_geometry_inputs`;
- stationary floor snaps and four ground or air quarter steps;
- action-local stores and action changes, including pole, ledge, and water
  actions; and
- potentially several action handlers in one `execute_mario_action` loop.

Every relevant control point and intermediate collision query must therefore
be represented in the eventual Clight refinement.  Constraining only the final
endpoint is insufficient.

## Why the current abstract event relation cannot prove the exclusion

`ModelGapAudit.current_certified_motion_accepts_arbitrary_endpoint` proves that
the current certificate accepts a `MotionPhysicsFrame` with any chosen
kinematic endpoint.  It does not require a gravity update, a reachable action,
a wall or floor result, a defined signed-short collision query, or execution
of the generated Clight.

This is an abstraction counterexample, not a ROM counterexample.  It disproves
the proposed inference

```text
abstract event is MotionPhysicsFrame
therefore its endpoint is reachable by ordinary retail motion
```

and is why `NoALocalOrdinaryFirstCrossing` cannot simply be asserted as the
next standalone theorem.

There is a second compositional problem.  A platform, object, clip, or
lifecycle event may prepare Mario's position, action, or velocity without
crossing a target cut.  The following ordinary frame could then be the first
crossing.  A sound proof must show that **every** earlier writer preserves one
common safe envelope, not prove the ordinary label in isolation from all
possible prestates.

## A real no-edge ascent in the source

The target definition permits A to be held before clean entry.  The generated
US and JP ASTs preserve the source distinction between `INPUT_A_DOWN` and the
edge-triggered `INPUT_A_PRESSED`.

Both stationary and moving punching can select `ACT_JUMP_KICK` when A is down.
That path needs a B press, but no new A edge.  The airborne action initializer
contains the binary32 value `20.0f` for jump-kick vertical velocity, and
`act_jump_kick` calls `perform_air_step(m, 0)`.  The literal zero is important:
this action does not request the air-step ledge-grab check.

This is a source-backed counterexample to “no A edge means no upward ordinary
motion.”  It is not a counterexample to the two-star claim.

B also keeps a higher candidate in the conservative action inventory.  A
high-speed ground dive can land in `ACT_DIVE_SLIDE`, and a later B press can
select a forward or backward rollout.  The rollout action initializes
vertical velocity to `30.0f` and also calls `perform_air_step(m, 0)`.
Reachability of that full chain inside the clean elevator cage is not assumed;
the arithmetic below bounds it even if it is supplied.

## Closed upper-elevator arithmetic

The generated collision initializer is parsed into the exact 20 local
pyramid-elevator vertices for both target versions.  Relevant facts are:

- the base floor is at local Y `0`;
- the side/rim vertices reach local Y `256`;
- dynamic surface construction stores `upperY = maxY + 5`;
- the lower air wall query samples Mario's center at offset Y `30`; and
- wall height rejection is strict above the surface's upper Y.

Consequently, for an integer-translated elevator wall, a normally resolved
airborne center must be strictly above

```text
256 + 5 - 30 = 231
```

relative to the elevator floor before the lower wall query rejects the side
wall vertically.  Equality still lies on the wall's inclusive Y range.
Nonintegral dynamic translations pass through signed-short transformed
vertices, so the precise live threshold must be recovered from the linked
Float32/short execution; `231` is the checked integer-translation arithmetic
boundary.

The arithmetic model uses the source values for the non-Wing fallback gravity
(`4` units/frame) and conservatively gives the airborne center the full
`10`-unit benefit of constant elevator descent on the first and every later
frame.  These first two sequences assume the non-Wing 4-unit branch:

```text
jump kick:  (20 + 10) + 26 + 22 + 18 + 14 + 10 + 6 + 2 = 128
rollout:    (30 + 10) + 36 + 32 + 28 + 24 + 20 + 16 + 12 + 8 + 4 = 220
```

Rocq proves these sequences saturate at `128` and `220`, respectively, and
proves:

```coq
Theorem held_a_jump_kick_elevator_relative_ascent_bound :
  forall frames,
    held_a_jump_kick_elevator_relative_ascent frames <= 128.

Theorem rollout_elevator_relative_ascent_bound :
  forall frames,
    rollout_elevator_relative_ascent frames <= 220.

Theorem held_a_jump_kick_relative_ascent_below_cage_clearance :
  128 < pyramid_elevator_cage_clearance.

Theorem rollout_relative_ascent_below_cage_clearance :
  220 < pyramid_elevator_cage_clearance.
```

The ordinary jump-kick absolute rise is also proved at most `60`.

These are closed arithmetic theorems, but their retail use is conditional on
the action and collision execution matching the model.  In particular, they
do not by themselves prove that:

- the transformed elevator walls are the surfaces selected from live Clight
  memory;
- all intermediate Float32 queries have the modeled values and defined
  signed-short conversions;
- normal wall resolution occurs rather than a clip, tunnel, or missed wall;
- the elevator descends by at most ten between the relevant samples;
- no earlier writer supplies a different action, height, or velocity; or
- the action inventory from a clean upper entry is closed.

Those points are deliberately retained as refinement obligations.

The upper clean-entry snapshot is not initially inside the cage: Mario starts
at Y `5500`, while the elevator starts at Y `4966` and its raw local rim
reaches world Y `5222`.  The generated no-spin-airborne entry action calls its
launch helper with zero forward speed; that helper writes forward speed and
then calls `perform_air_step`.  These are syntax receipts only.  A complete
ordinary proof must execute the spawn action and intermediate collision
queries, show the fall remains on the shaft line absent an already classified
nonordinary writer, select the intended live elevator floor, and only then
enter the post-landing ascent envelope.

Mario's cap state is not harmless bookkeeping.  If a Wing Cap is
hypothetically installed after entry while A stays held, `apply_gravity`
switches to the two-unit flutter branch after vertical velocity becomes
negative.  Mario then falls more slowly than the elevator descends.  The
corresponding closed rollout arithmetic has positive relative increments

```text
40, 36, 32, 28, 24, 20, 16, 12, 8, 6, 4, 2
```

and reaches the frame endpoint `228`.  Quarter-step execution is sharper:
only samples 44 and 45 exceed the `231` threshold, at `234` and `232`, and the
next two are `230` and `228`.  This is a diagnostic countermodel to omitting
`MarioState.flags` and `capTimer`, not a collision-complete bypass trace.
`UpperElevatorWingCapTransitionClosure.v` checks that the stock Area-1-to-2
route invokes Mario reinitialization, which writes only non-Wing flags and a
zero timer, and that SSL course 8 selects none of the initial special-cap
cases.  Thus carrying Wing through the stock transition is impossible in the
defined source execution.  `OrdinaryMotionCapFlagsEntryProjectionObligation`
still asks the linked proof to connect that route and those writes to the same
live Mario receiver; a post-reset grant, forged route/course, or different
receiver would be a separately named escape rather than preservation.

## Lower entrance and the second pole

The literal claim that A is the only way to leave the second pole is false.
The pole action source has a Z-triggered `ACT_SOFT_BONK` path with forward
speed `-2.0f`, and sliding below the pole bottom can also enter freefall.

The existing normalized integer kernel proves that its modeled soft-bonk
trajectory cannot retain enough height while acquiring the roughly 101 units
of lateral clearance needed by the upper floor opening.  This tranche also
extracts the exact generated Area-2 vertices used by that audit:

- the pole-base support vertices at Y `3200`; and
- the inner and outer boundary vertices of the upper ring at Y `3942`.

That remains a restricted subcase.  A complete lower ordinary-motion proof
must use a collision-phase safe envelope and cover every reachable approach,
pole exit, ledge action, slope, static support, and transition state.  It may
not replace that work with “Mario never reaches floor 3,” a bare Y threshold,
or the normalized soft-bonk lemma.

## Formal preservation boundary

`OrdinaryMotion.v` defines a finite-cell `OrdinarySafeEnvelope` and proves the
generic preservation composition:

```coq
Theorem ordinary_safe_envelope_execution_excludes_target :
  forall envelope before inputs after,
    OrdinaryEnvelopePreservationObligation envelope ->
    OrdinaryEnvelopeTargetExclusionObligation envelope ->
    fewer_than_one_a_press inputs ->
    state_in_ordinary_envelope envelope before ->
    OrdinaryMotionExecution before inputs after ->
    target_state after ->
    False.
```

This is not the retail exclusion.  A future instantiation must define cells
from parsed surface IDs/open regions plus explicit action, Float32 position,
velocity, floor, wall, ceiling, pole, and elevator bounds.  It must then prove
preservation from linked US/JP Clight execution.  The module separately names
source-execution, intermediate-query, and collision-observation linkage
obligations so none is hidden inside the arithmetic theorem.

The structural lemmas already prove what follows from existing indexed frame
evidence: physics endpoints align with projected kinematics, the area is
unchanged, an indexed projected input with no A edge exists, and an ordinary
writer label inverts to a `MotionPhysicsFrame`.  The input lemma is list-level
only; connecting that sample to the controller memory read by the Clight
segment remains open.

## Ink fallback and PU movement

The pre-action graphical fallback is not harmless bookkeeping.  Object
collision can cache the upper warp from old `MarioObject.oPos`; a later
floorless `MarioState.pos` query can copy `header.gfx.pos` into State and
retry.  If that independently stale graphical sample selects a loaded pyramid
top surface, the disappeared action and later State/Object copy satisfy the
coordinate part of a conditional warp/top snap.  The unconditional
quicksand-sink call occurs between the disappeared-action snap and the
State/Object copy; the projection models its Graphics-position write and
proves that modeled write cannot change the copied Object coordinate.  The
source may also write `gfx.throwMatrix[3][1]`.  The original memory obligation
was false under a repeated-return segment and a checked modular pointer alias;
its repaired first-return, disjoint-cell form remains open.  Later object lists
and deactivated-object unloading occur before the final platform query.  The
current lifecycle proposition is unsafe or vacuous and must be replaced before
owner-slot liveness can be claimed.

`InkFallback.v` now proves the relevant three-view invariant.  Any finite
prefix of writers that changes only MarioState preserves both the collision
Object and fallback Graphics samples.  Therefore arbitrary ordinary wall
motion, platform displacement, or PU-sized State displacement cannot create
the required Object/Graphics split from a synchronized sample.  PU wrapping
can affect the retry's floor lookup, but it does not itself write the
full-float Object or Graphics coordinates.

The generic retry, when Graphics Y is in signed-16 range, requires at least
385 units of upward
`GraphicsY - ObjectY` separation; either exact local/PU prestate proposed in
the Ink note requires at least `973`.  The dry ordinary source census finds a
largest relevant positive visual offset of 45, and the admission-free theorem
`dry_graphics_offset_cannot_supply_top_retry` closes that arithmetic subcase
once its `<=45` premise is derived.  The source audit motivates a conservative
cross-action relation bound of 208 because water pitch of at most 60 and
swimming bob below 148 can compose across a floor-hit branch; the upper warp
is outside the checked water boxes, so that is not the route-specific target.

If the graphical retry also returns no floor, the geometry code requests the
fatal warp before cached object interactions.  From an empty call-boundary
latch, `RetailFatalLatch.v` closes the block-or-reset invariant for its
source-audited event system and proves that no modeled suffix accepts the
upper-object-warp request; zero lives belongs to the same fatal class.  What
remains open is the linked Clight/memory refinement establishing that the
concrete US/JP execution projects to those events and that no unmodeled writer
changes the latch.  Subject to that refinement, ordinary or PU movement only
matters here if it produces a **non-null** retry floor.

A prepared `ACT_LONG_JUMP_LAND` state with pre-frame `actionTimer = 4` is a
precision exception to any blanket claim that quicksand always lowers
Graphics.  The checked binary32 calculation makes the depth operand
`-2.6500000953674316f`; subtracting it from a zero Graphics base produces
`+2.6500000953674316f`, while the actual delta at another binary32 base is
rounding-dependent.  In the normal action graph the prepared state requires a
prior A edge.  The stock static upper-warp support is `SURFACE_WALL_MISC`, so
it cannot generate this landing adjustment, but it does not clear a negative
depth prepared earlier.  Excluding persistence requires the still-open clean
no-A action/state closure.

This does not yet prove retail ordinary-motion exclusion.  It still needs
entry-time Object/Graphics equality, complete reachable Graphics-writer and
spawn closure, first-query `NULL` plus loaded top-owned non-null retry
selection, proof of the repaired sink statement, and a replacement exact-link
post-copy lifecycle interface.  The old surface/prestate/writer propositions
are predicate schemas, not those retail refinements.  No clean stock-reachable
prestate or target-bit counterexample was found.  See
[`ink-fallback.md`](ink-fallback.md).

## Current conclusion

The following statements are now justified:

- ordinary motion cannot be equated with “Mario does not move”;
- ordinary motion cannot be excluded by the current arbitrary-endpoint event
  model;
- no-A-edge input still permits held-A jump kick;
- the generated jump-kick and rollout source shapes use no ledge-grab step
  flag;
- in the checked non-Wing 4-unit-gravity integer ascent model, both candidates remain
  below the modeled integer-translation lower-wall vertical-rejection
  threshold;
- the checked Wing-Cap rollout countermodel proves `220 < 228 < 231`, so it
  does not clear the corrected vertical gate but cap initialization and
  preservation remain required proof inputs; and
- the normalized second-pole soft-bonk subcase remains blocked.

`MainTheorem.v` packages the checked source/mesh/arithmetic conjunction and
the Wing-Cap countermodel boundary in the closed theorem
`current_ordinary_motion_evidence_boundary`.  Its conclusion stops at
`220 < 228 < 231` plus the no-A-edge input fact; it contains no retail
safe-envelope preservation or target-region non-overlap conclusion.

The following statement is **not** yet justified:

> Every ordinary-motion trajectory from a clean US or JP lower or upper entry
> stays on the entrance side of both target cuts.

Therefore the ultimate less-than-one-A-press theorem remains incomplete.
