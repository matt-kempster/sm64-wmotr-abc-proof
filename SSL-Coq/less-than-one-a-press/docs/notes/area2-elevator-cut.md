# Area-2 upper-entry elevator cut

## Result

The upper route now has an initializer-exact triangle inventory and candidate
cut.  The Rocq
module `proofs/Area2ElevatorCut.v` identifies the elevator base, inner walls,
upper rim, fixed entry chamber walls, and the static floor surrounding the
shaft by their exact triangle ordinals.  It checks those triangles against
the generated US and JP Clight global initializers.

This is not yet a universal retail proof that Mario cannot leave the elevator
without a new A edge.  The checked result now includes the finite
mesh/arithmetic kernel, a conditional first-crossing theorem, complete
internal-query receipts for one JP held-A jump kick and one JP B rollout, and a
four-face held-A sweep.  All 148 tested quarter steps have the exact two-wall,
one-floor, one-ceiling query sequence; the selected US and JP source programs
resolve the same real query bodies.  Every live intended Y agrees with the
proved envelope, every floor and non-null wall has the elevator owner, and
every ceiling is static.  Continuous-pose exhaustiveness and the
remaining writer/clip/support alternatives stay explicit obligations.

## Exact surface inventory

The pyramid-elevator initializer has ten default triangles, two
`SURFACE_CLOSE_CAMERA` triangles, and 24 `SURFACE_NO_CAM_COLLISION` triangles.
Using zero-based whole-initializer triangle ordinals:

| Role | Group-local ordinals | Whole-initializer ordinals |
|---|---:|---:|
| base floor | close-camera 0, 1 | 10, 11 |
| inner bucket walls | no-camera 0, 17–23 | 12, 29–35 |
| horizontal upper rim | no-camera 1, 2, 3, 10, 11, 12, 13, 16 | 13, 14, 15, 22, 23, 24, 25, 28 |
| outer bucket walls | no-camera 4–9, 14, 15 | 16–21, 26, 27 |

The literal inventory lists the three eight-triangle no-camera sets over
indices `0..23`.  Rocq currently proves that the sets are pairwise disjoint and
have total length 24; exact membership in `0..23` is still a separate finite
receipt.  The decoded elevator vertices and triangle groups are identical in
the generated US and JP arrays.

For the Area-2 static initializer:

| Role | Exact triangle ordinals |
|---|---:|
| floor at Y=5222 surrounding the shaft | default 94, 95, 96, 98, 99, 100, 101, 102 |
| fixed chamber walls | whole-initializer 1523, 1527–1533; equivalently no-camera local 97, 101–107 |

Default ordinal 97 is unrelated and is deliberately excluded from the
surrounding-floor set.

These numbers name source initializer triangles.  They are not C pointers.
`SurfaceRef` is assigned by the Clight observation projection.  The new
`ElevatorCutSurfaceProjection` record requires an injective same-area ghost
name and one projected elevator object identity; it does not prove that such a
surface is live.  `LinkedElevatorSurfaceProjectionObligation` separately
requires relevant-state memory decoding, owner/transform, and list-insertion
relations for every selected key.  Those relations still need concrete linked
Clight inhabitants.

## Fixed chamber and moving bucket

The clean upper entry is at `(0,5500,256)`.  The fixed entry chamber is:

```text
X: -409 .. 410
Y: 5222 .. 5734
Z: -153 .. 666
```

Rocq evaluates the binary32 comparisons and proves that the exact clean-entry
position lies in this supplied cell.  The selected chamber-wall triangle
indices are generated-data receipts, but a full theorem deriving all six cell
bounds from their generated vertices remains part of the static-surface
projection work.

The moving bucket must not be confused with that narrower fixed chamber.  The
checked vertex inventory supplies this conservative wall-bounds box in
elevator-local coordinates:

```text
X: -460 .. 461
Y:  -50 .. 256
Z: -460 .. 461
```

At the stock horizontal origin `(0, *, 256)`, its Z interval is therefore
`-204 .. 717`.  As the elevator origin travels from Y=4966 to Y=128, the
fixed union envelope swept by this local box is:

```text
X: -460 .. 461
Y:    78 .. 5222
Z: -204 .. 717
```

That union envelope is useful to the existing `CollisionSupportCut`, whose
historically named open-cell test is actually closed and absolute.  It is not
itself an exact moving collision
component: points at different heights correspond to different elevator
times.  The moving-relative candidate uses Mario's position relative to the
live elevator origin and stops just below the binary32 rim height for
tie-breaking.  It is still a bounding box, not a connected collision
component.  `MovingElevatorCellToSweepRefinementObligation` keeps a necessary
translation bridge visible; behavior identity, allocation epoch, rotation,
transformed vertices, list insertion, and selection remain open.

The generic cut uses specific base and rim `SurfaceRef`s and deliberately
leaves its owner-only dynamic-support lists empty.  Base and rim surfaces have
the same elevator object owner; using that `ObjectRef` as a side identifier
would put rim states on the source side and destroy the separation.

## No-A result

The fully checked subkernel now contains:

- exact US/JP dynamic and static triangle receipts;
- exact clean-entry cell membership;
- existing US/JP source-shape receipts for the entry action, held-A jump kick,
  and B-driven rollout candidates;
- exact binary32 replays of the 32 held-A jump-kick and 40 B-rollout rising
  quarter-step queries, plus conservative full-return envelopes of 64 and 84
  queries; the rising maxima `134` and `224.5` become the later full-return
  maxima `135` and `227.5`, still below `231`;
- a generated-source return split limited to codes `0,1,2,3,4,6`;
- selected-program resolution of the real US/JP air-step, wall-wrapper,
  ceiling-wrapper, wall-query, floor-query, and ceiling-query bodies, including
  their unconditional `wall, wall, floor, ceiling` prefix;
- a JP held-A receipt covering all 64 full-return quarter steps and a JP
  B-rollout receipt covering all 84, with no missing sequence, wrong receiver,
  nonzero step argument, vertical projection, surface-owner, or unknown-result
  failure; four cardinal held-A poses each
  hit the matching live elevator face and peak at relative Y `128`;
- a checked Area-1-node-`0x1E` to Area-2-node-`0x14` call chain through
  `warp_area`, `init_mario_after_warp`, `init_mario`, and the initial-cap
  helper, proving that the stock transition resets Wing and that SSL course 8
  cannot immediately restore it; and
- an exact hypothetical-Wing result: only zero-based queries 44 and 45 are
  above the strict `231` wall cutoff, at `234` and `232`; queries 46 and 47
  are back to `230` and `228`.

The ordinary arithmetic facts eliminate the modeled vertical-clearance
versions throughout the conservative return envelope, not merely at frame endpoints.  The stock transition
also eliminates preservation of a Wing Cap carried from Area 1, subject to the
still-needed live-execution link showing that the decoded route and ordinary
call chain operate on the same Mario state.  A hypothetical post-reset Wing
grant would create only a two-query opportunity; it still needs the intended
live inner-wall owner/list choice, floor and ceiling results, horizontal
position, and rollout action result, so it is not a bypass witness.

## Hypothetical post-reset Wing decision chain

This branch cannot arise by preserving Wing through the stock transition, but
it is useful for classifying any distinct writer that might grant Wing after
the reset:

| Phase | Checked fact | Live fact still required |
|---|---|---|
| Entry descent | Area-2 node `0x14` places Mario at `(0,5500,256)` in the no-spin airborne entry; each air quarter-step resolves the upper wall, lower wall, floor, ceiling, and water in that order. | Execute every descent query, preserve the shaft X/Z line, and exclude an earlier fixed or target-side floor. |
| Elevator landing | The candidate elevator base and its exact triangles are inventoried. | Show the selected floor is the transformed base owned by the intended active elevator object in its current allocation epoch, then derive the actual landing action/state. |
| Rollout frames | Forward and backward rollout initialize vertical speed `30`, update horizontal air motion, call `perform_air_step(m, 0)`, and apply gravity after the four quarter-steps.  Step argument zero disables the ledge-grab and ceiling-hang result branches. | Derive the landed pose, facing, X/Z velocity, elevator phase, held-A input, and absence of another action/velocity writer. |
| Two-query Wing window | On the twelfth modeled rollout frame, quarter-steps 1 and 2 are at relative Y `234` and `232`; quarter-steps 3 and 4 are `230` and `228`. | At one of the first two samples, select the intended transformed inner wall in the correct partition while retaining a floor/ceiling result compatible with continuing motion. |
| Action result | `AIR_STEP_NONE` leaves rollout unchanged; `AIR_STEP_LANDED` selects `ACT_FREEFALL_LAND_STOP`; `AIR_STEP_HIT_WALL` zeros forward speed without selecting a new action; `AIR_STEP_HIT_LAVA_WALL` calls the lava-wall handler. | Execute the selected result and its same-frame state writes, then show the resulting position crosses the moving-relative cut rather than merely missing one wall query. |

Accordingly, Wing would help only by creating two possible lower-wall misses.
It supplies neither horizontal travel nor elevator ownership, and the stock
transition supplies no Wing state in the first place.

The strongest route theorem is an adapter-based conditional reduction enriched
with moving-relative endpoint witnesses:

```coq
Theorem upper_elevator_no_a_target_access_is_closed_under_relative_obligations :
  UpperElevatorRelativeCutConstructionObligation surface_projection
    clight_projection ->
  UpperElevatorNoAWriterExclusions surface_projection clight_projection ->
  ... ->
  fewer_than_one_a_press (project_inputs clight_projection run) ->
  reaches_any_target_region trace ->
  False.
```

The writer premise enumerates ordinary local physics, platform displacement,
object impulse, clip/tunnel motion, coordinate-alias or out-of-bounds motion,
lifecycle/entry displacement, and same-position floor/platform selection.
The contradiction still uses the conservative absolute adapter.  It is not
yet a writer theorem over a native moving-relative cut.  The proof uses the
existing first-crossing writer-coverage theorem, so there
is no unclassified abstract event after a valid strictly earlier-frame adapter
crossing has been supplied.  The premise is not inhabited here.

## Authenticated original-JP B-only execution

`instrumentation/jp-rank10-upper-elevator` extends the established clean,
zero-A four-pillar route through the upper warp without patching game memory.
Its exact 3500-frame mode-1 summary is pinned.  Area 2 begins at timer 2831
with MarioState and `gMarioObject` both naming pool slot 10 and with one live
elevator.  The 17 observed descent heights are
`534, 530, 522, 510, 494, 474, 450, 422, 390, 354, 314, 270, 222, 170, 114,
54, 0`; every selected floor is owned by the elevator, and landing occurs at
timer 2847.

After a bounded runway/orbit setup, B starts the speed-kick dive at timer 3198.
The dive lands on the moving elevator, and a second B at timer 3214 starts
`ACT_FORWARD_ROLLOUT`.  The first rollout update selects surface `0x801a2c50`,
owned by the same elevator.  It is the east wall at X `461`, spanning Z
`-204..717`, with inward normal `(-1,0,0)` and padded Y bounds `1381..1647`.
Mario is resolved to center X `411`, horizontal speed becomes zero, and all 20
observed rollout frames keep that wall and elevator floor.  Relative endpoint
heights are
`40, 76, 108, 136, 160, 180, 196, 208, 216, 220, 220, 216, 208, 196, 180,
160, 136, 108, 76, 40`; the following update lands on the elevator.  Across
all 671 Area-2 frames there are zero Mario/elevator identity failures, zero
floor-owner mismatches, zero A inputs, and zero Wing frames.

`proofs/UpperElevatorLiveTraceReceipt.v` packages those exact facts and pairs
them with the full-return Float32 envelope.  This closes the concrete B-only
trajectory's ordinary vertical/wall version.

The held-A replay arms A at the accepted Area-1 disappearance boundary and
therefore has no Area-2 A edge.  Its east launch executes exactly 64 quarter
steps: 61 return clear, two hit the elevator wall, and one lands.  Each step
executes two wall queries, one floor query, and one ceiling query in that order,
and every selected floor is owned by the same elevator.  The B rollout
independently executes 84 complete sequences: three clear, 80 wall-hit, and one
landing result.  Its 168 wall, 84 floor, and 84 ceiling calls are all accounted
for.  Their query-relative maxima are exactly `135` and `227.5`, matching the
Coq envelopes, with zero floor-owner, non-null-wall-owner, or static-ceiling
mismatch.

Checkpoint replays toward the four cardinal faces select four distinct live
walls with normals `(-1,0,0)`, `(1,0,0)`, `(0,0,-1)`, and `(0,0,1)`.
Every jump kick remains inside the cage, has 15 elevator-floor frames and one
elevator-wall frame, and reaches relative Y `128`; no launch creates the
needed vertical miss.  `UpperElevatorQueryResolution.v` separately proves
that the exact queried bodies and call prefix resolve in both selected US and
JP Clight programs.  These remain finite JP machine receipts rather than an
IDO-to-Clight simulation or a theorem over every continuous controller pose.

## Remaining retail obligations

The following are still open and prevent an unconditional elevator-gate
claim:

1. generalize the observed four JP wall classes to every continuously
   reachable X/Z/yaw launch, including allocation epoch and list insertion;
2. add an independent live US machine receipt if selected-source resolution is
   not accepted as sufficient US coverage;
3. prove the elevator pose and translated moving-cell-to-sweep relation at
   every relevant frame;
4. construct the first moving-relative source-to-target crossing before either target
   collision, including paths which skip a normal rim landing, and resolve
   the closed Y=5222 chamber/surrounding-floor edge with the real surface-list
   tie behavior;
5. discharge each of the seven no-A writer/domain exclusions for all clean
   US and JP executions; and
6. separately validate downstream continuation from the target side to the
   Act 3 interaction region and all five Act 6 triggers.

An additional named obligation requires every actual projected target-event
frame to have a validated cut crossing in a strictly earlier frame.  It
remains uninhabited.  If a real same-frame or earlier transient crossing
exists, this obligation is false and exact collision-program-point semantics
must extend the interface.

No new clean retail bypass or counterexample is established here.  The result
makes the remaining upper-route question narrower: either one of the listed
writer classes reaches the candidate rim/outside cut without an A edge, or the
linked moving-relative construction and all exclusions close the upper
entrance.
