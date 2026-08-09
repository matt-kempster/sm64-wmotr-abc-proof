# Area-2 lower target-side cut

## Verdict

The lower route can now be described without the unsound phrase “above the
second pole.”  The checked source geometry gives an initializer-backed
candidate geometry inventory:

- eight `SURFACE_CAMERA_FREE_ROAM` ring triangles, source ordinals
  `1414..1421`, at Y `3942`;
- eight `SURFACE_NO_CAM_COLLISION` aperture-plane records intended as vertical
  wall candidates, source ordinals `1534..1541`, running from Y `3712` to Y
  `3942`; and
- four conservative closed binary32 boxes over the ring footprint, outside
  the central shaft.

Formal target-side membership uses the ring supports and four boxes.  The
vertical walls constrain the pending separator/collision proof but are not
themselves members of either formal cut side.

The selected ring and wall vertices put the central aperture edges at X
`[-101,102]` and Z `[1229,1434]`; proving that those records exhaust the live
collision component and its edge selection remains open.
The four target boxes cover the outer ring rectangle but exclude its
central aperture.  This distinction is load-bearing: source/gameplay evidence
identifies an ordinary pole-top sample `(0,4020,1331)` obtainable without a
fresh A edge, but this tranche does not prove that reachability.  Declaring
the central above-floor shaft to be target-side would immediately make the
purported no-A gate closure false.

The new formal result is not a full retail gate closure.  It authenticates the
surface records in both generated US and JP collision arrays, defines the
cut, and closes the archived normalized soft-bonk subcase.  All other clean
zero-A writers and live collision-selection behavior remain explicit
obligations.

## Exact static geometry

The Area-2 collision initializer contains 1,080 vertices.  Its selected
triangle groups are identical in the generated US and JP units.

### Lower pole platform landmark

The two selected `SURFACE_DEFAULT` source triangles are:

| Global source ordinal | Vertex indices |
| ---: | --- |
| 746 | `(593,1010,807)` |
| 753 | `(593,805,1010)` |

The first is the flat triangle under the pole centre.  These triangles are a
source landmark; they are not asserted to enumerate the entire pre-gate
connected component.

### Target-side ring

The camera-free-roam group starts at global source ordinal `1399`.  Its local
ordinals `15..22` therefore have global ordinals `1414..1421`:

| Global ordinal | Vertex indices | Aperture side |
| ---: | --- | --- |
| 1414 | `(283,298,284)` | south |
| 1415 | `(284,298,285)` | east |
| 1416 | `(284,285,299)` | east |
| 1417 | `(285,300,301)` | north |
| 1418 | `(285,301,299)` | north |
| 1419 | `(283,286,298)` | south |
| 1420 | `(286,301,300)` | west |
| 1421 | `(286,283,301)` | west |

The relevant vertices have exact integer coordinates:

```text
outer southwest = (-1535,3942, 922)
outer southeast = ( 1536,3942, 922)
inner southwest = ( -101,3942,1229)
inner southeast = (  102,3942,1229)
inner northwest = ( -101,3942,1434)
inner northeast = (  102,3942,1434)
outer northwest = (-1535,3942,1536)
outer northeast = ( 1536,3942,1536)
```

### Vertical aperture wall candidates

The no-camera-collision group starts at global source ordinal `1426`.  Its
local ordinals `108..115`, hence global ordinals `1534..1541`, are the eight
triangles formed from the four upper inner-ring vertices and four matching
vertices at Y `3712`.  Rocq computes that each complete triangle lies on the
expected constant-X or constant-Z aperture plane.

These initializer records are intended wall candidates, not Mario floor
supports or formal cut-side members.  Proving their live wall classification,
partition-list membership, and selection is part of the future
`resolve_and_return_wall_collisions` execution and clip/tunnel proof.

## Binary32 airborne component

The target airborne component is the union of four closed binary32 boxes:

```text
west:  x=[-1535,-101], y=[3942,6144], z=[922,1536]
east:  x=[102,1536],   y=[3942,6144], z=[922,1536]
south: x=[-101,102],   y=[3942,6144], z=[922,1229]
north: x=[-101,102],   y=[3942,6144], z=[1434,1536]
```

The bounds are literal CompCert `Float32` values.  Y `6144` is the computed
maximum vertex Y of the complete generated Area-2 static mesh in both US and
JP.  The tests reject NaNs through the existing self-comparison guard.  Checked
samples establish that the pole-top centre is outside every target box while
each of the four inner ring edges is inside its corresponding target box.
The test uses projected MarioState position, not Mario's collision-object
hitbox at a particular collision phase; that refinement remains open.

The boxes intentionally stop at the outer ring rectangle.  A one-frame local
endpoint that jumps completely over them, a PU/nonlocal endpoint, or a moving
support that bypasses them is not silently declared impossible; it belongs to
the separator/first-crossing residual below.

## Dynamic support that cannot be ignored

The Area-2 script also spawns `bhvHorizontalGrindel` at
`(-870,3840,105)`, yaw `180`.  Its complete local collision vertex receipt has
top Y `450`, so its home-pose top reaches world Y `4290`.  Its behavior can
jump with vertical velocity `70` and forward velocity `11`.

The Grindel is **not** part of the immediate pole-hole cut: its home position
is downstream of that separator.  The module records only a projection-map
placeholder for moving-geometry/downstream auditing; it does not connect that
key to the spawned Grindel, guess an object-pool slot, or erase the allocation
epoch.  Live spawn,
movement, collision loading, deletion/reuse, and proof that it cannot bypass
the ring/open-cell separator remain obligations.  In particular, a
static-ring-only *route-exhaustiveness* claim would currently be unsound even
though the immediate cut itself is static.

## What is proved about no-A motion

The archived normalized pole model gives the strongest closed subcase.  While
its soft-bonk sample is high enough to meet Y `3942`, it has at most six
eligible frames and component displacement at most `82`.  Therefore:

```text
-82 <= x <= 82
1249 <= z <= 1413
```

This lies strictly inside the aperture, whose nearest checked ring boundary is
101 units
from the pole centre.  `Area2LowerTargetCut.v` proves that such a sample cannot
enter any of the four target air footprints.  This admission-free integer
geometry is packaged alongside the generated ring-vertex receipts; it is not
derived from them and remains only the normalized
soft-bonk case.  It does not prove live Float32 wall/floor selection or every
ordinary pole exit.

## Exact remaining closure obligations

`LowerNoAGateClosureObligation` remains open.  A retail proof must establish:

1. the mapping from source triangle ordinals to the `SurfaceRef` values
   projected from live US/JP `Surface` memory;
2. the lower-entry floor and platform allocation identities, rather than
   exploiting the abstract `CleanPyramidEntry` record's unconstrained surface
   index;
3. complete local ordinary-action execution, including every pole exit,
   falling, landing, wall resolution, slope response, and all four ground
   quarter-steps;
4. actual `find_floor`/wall-list construction, insertion, traversal, triangle
   ownership, and support selection for ordinals `1414..1421` and
   `1534..1541`;
5. moving-owner bypass coverage, including the horizontal Grindel's
   transformed collision and slot/epoch lifecycle;
6. platform displacement, object push/moving geometry, clip/tunnel, finite
   nonlocal and failed-cast endpoints, area transition/reload, and
   same-position floor/platform-selection cases;
7. a separator theorem: every clean route to the Act 3 region or any required
   hidden trigger has a first collision-phase entry into the enumerated
   support/air component, or is assigned to one of those explicit bypass
   classes; and
8. sub-frame ordering when the cut crossing and a target collision occur in
   the same rendered frame.

Thus the present result neither rules out all of Area 2 nor exhibits a new
Area-2 counterexample.

## Conditional first-crossing reduction

The module now has the same sound reduction interface as the upper elevator
cut.  `LowerTargetCrossingContext` binds one constructed
`FirstValidatedCutCrossingAt` to:

- a clean lower entry;
- the selected lower ring cut;
- the exact projected Clight run; and
- a complete input list with no A edge.

`LowerTargetNoAWriterExclusions` lists seven separate cases: local ordinary
physics, platform displacement, object impulse, clip/tunnel, nonlocal or
failed-cast ordinary physics, lifecycle/entry displacement, and same-position
floor/platform support selection.  Given all seven exclusions,
`lower_target_no_a_first_crossing_is_closed` proves that the constructed first
crossing is impossible.

`lower_target_no_a_target_access_is_closed_under_adapter_obligations` adds the
other missing half: if the linked collision projection constructs this
conservative
first cut crossing before the earliest Act 3 or upper-trigger target
observation, then the seven exclusions rule out target access.  This is a
conditional reduction theorem.  Neither cut construction nor the seven
retail exclusions has been proved.

`LowerSameFrameCollisionPhaseCutRefinementObligation` separately requires every
actual projected target-event frame to have a validated crossing in a strictly
earlier frame.  It remains uninhabited.  If a real same-frame or earlier
transient crossing exists, the obligation is false and the project must add
exact collision-program-point semantics rather than a ghost-state witness.

## Downstream validation boundary

Downstream certificates are defined in `Area2DownstreamContinuations.v`, not
in the cut module.  A universal promise from *every* abstract target-side
`GameState` would include dead, corrupted, high/nonlocal, or otherwise
unreachable states and would be false or far stronger than the route claim.

The correct downstream obligations begin at a supplied boundary state and
then separately validate suffixes:

- a no-A continuation to the Act 3 interaction region; and
- a no-A continuation consuming **each** member of `all_hidden_triggers`, not
  merely the upper trigger.

Neither suffix is implied by the mesh receipts.  The historical claim
that the rest of the pyramid is freely traversable cannot substitute for
collision-phase traces.  Each suffix must eventually be composed with a
separately proved clean-prefix boundary state in linked Clight memory, with
coherent controller history and target-object provenance.  Keeping the Act 3 and
five-trigger continuations separate also avoids suggesting that both stars
must be reached in one course visit.

## Formal status

The capstone `area2_lower_target_cut_checked_boundary` packages only:

- the exact US/JP ring records;
- the exact US/JP ring-vertex, aperture-plane-side, and lower-Y receipts;
- the exact US/JP static-mesh maximum Y receipts;
- exclusion of the central pole-top sample from target air; and
- the normalized no-A soft-bonk exclusion.

It does not include the named retail closure or downstream obligations.
