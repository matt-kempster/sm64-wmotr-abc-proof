# Area-2 upper-entry elevator cut

## Result

The upper route now has an initializer-exact triangle inventory and candidate
cut.  The Rocq
module `proofs/Area2ElevatorCut.v` identifies the elevator base, inner walls,
upper rim, fixed entry chamber walls, and the static floor surrounding the
shaft by their exact triangle ordinals.  It checks those triangles against
the generated US and JP Clight global initializers.

This is not yet a retail proof that Mario cannot leave the elevator without a
new A edge.  The checked result is the finite mesh/arithmetic kernel and a
conditional first-crossing theorem.  Live dynamic-surface construction,
collision-list selection, and all reachable writers remain explicit
obligations.

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
- exact binary32 replays of all 32 held-A jump-kick and 40 B-rollout
  quarter-step queries, with maxima `134` and `224.5`;
- a generated-source return split limited to codes `0,1,2,3,4,6`;
- direct initializer checks accepting only non-Wing flag assignments and a
  zero cap timer; and
- a corrected retained-Wing result: zero-based query 44 is `234`, above the
  strict `231` wall cutoff even though the frame endpoints peak at `228`.

The ordinary arithmetic facts eliminate the modeled vertical-clearance
versions at every query, not merely at frame endpoints.  They do not prove the
live inner wall is selected or that the action reaches those query states.  The
Wing result is a surviving branch until live entry proves the normal cap reset
and its preservation.

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

## Remaining retail obligations

The following are still open and prevent an unconditional elevator-gate
claim:

1. map each initializer key to the transformed live `Surface` in US and JP
   memory, including allocation epoch and list insertion;
2. execute the initial fall and prove the entry floor pointer does not already
   name a target-side surface;
3. prove the elevator pose and translated moving-cell-to-sweep relation at
   every relevant frame;
4. execute all floor, wall, and ceiling queries and prove the intended base,
   inner-wall, rim, or surrounding-floor selection;
5. construct the first moving-relative source-to-target crossing before either target
   collision, including paths which skip a normal rim landing, and resolve
   the closed Y=5222 chamber/surrounding-floor edge with the real surface-list
   tie behavior;
6. discharge each of the seven no-A writer/domain exclusions for all clean
   US and JP executions; and
7. separately validate downstream continuation from the target side to the
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
