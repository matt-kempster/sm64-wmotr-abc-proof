# Pyramid-top Parallel-Universe audit

## Verdict

Both quoted analyses identify real facts, and both reject the narrow proposal
in which an intact stock top supplies only a huge X/Z PU displacement and that
same displaced sample must newly touch the warp.  The first paragraph's
bottom line is correct for that proposal.  The second response is wrong to call
the first paragraph incorrect, but its full-float collision, vertical-gap, and
pre-displacement collision-timing observations are also correct.  Its broader
suggestion that the update order rules out every State/Object phase split is
too strong.

The newer Ink fallback audit strengthens that correction.  Update order also
permits a **three-view** conditional schedule: old `MarioObject.oPos` caches
the warp, floorless `MarioState.pos` triggers the OOB branch, and an
independently stale `header.gfx.pos` is copied into State for the retry.  If
that graphical query selects a loaded top surface, the disappeared action and
later State/Object copy can complete the coordinate snap.  Local and PU graphical
coordinate witnesses for a handwritten pipeline are proved in
`InkFallback.v`; generated syntax/dataflow receipts separately check the
null/copy/retry source shape.  No clean retail prestate constructing the
necessary Object/Graphics split has been found.
See [`ink-fallback.md`](ink-fallback.md).

The earlier two-view phase-split result explores a different question: could
Mario's old object already overlap the warp while a separate
three-dimensional, State-only writer moves the later geometry sample to the PU
top?  Direct source inspection shows this one-frame phase split:

1. platform displacement writes `MarioState.pos`;
2. object collision reads the still-old `gMarioObject->oPos`;
3. Mario geometry reads the displaced `MarioState.pos`;
4. Mario interaction can select `ACT_DISAPPEARED`;
5. the action snaps State Y to the newly found floor;
6. the unconditional quicksand sink writes Graphics Y and may also write the
   graphics throw matrix;
7. MarioState is copied into `gMarioObject`;
8. the remaining pushable, genactor, destructive, level, default, and
   unimportant lists update;
9. deactivated objects unload; and
10. the final platform query reads the copied object position and that frame's
    still-loaded surfaces.

The explosion frame is a distinct lifecycle subcase.  The top sets
`activeFlags = ACTIVE_FLAG_DEACTIVATED` in its terrain-object update, and its
behavior script then reaches `load_object_collision_model`.  Mario may query
that surface in the player-list update.  Later
`unload_deactivated_objects` calls the source deallocator without clearing the
already built dynamic partitions, and `update_mario_platform` tests only that
`floor->object` is non-null.  The generated syntax therefore contains the
deallocation path.  The open lifecycle postcondition is limited to asking that
a successfully retained owner be active or inactive in the same allocation
epoch; it does not encode that this top was scanned/deallocated or prove
concrete free-list membership.  No allocation runs between that unload pass and
the final platform query, but the exact memory/payload refinement remains open.

The two closed coordinate witnesses do not instantiate this subcase.  They
use the zero-yaw home top and floor Y `1791`.  A handwritten minimum-pose
recurrence starts at home Y and yields the conservative center-Y target `1871`
by timer `150`; it neither executes the timer-59 smooth-rise state nor proves
the needed binary32 lower bound for the generated Clight.  The explosion
branch must recover its actual translated/rotated surface and selected floor
height.  Concrete free-list membership remains open.

Consequently, the collision sample can be at the ordinary warp while the
geometry/platform sample is somewhere else.  An admission-free Rocq
two-sample arithmetic model demonstrates that coordinate-level consistency.
It is not a stale-slot, surface-selection, Clight-execution, or reachability
witness.  It does **not** supply the required gameplay-reachable
three-dimensional displacement, prove sink/throw-matrix memory refinement,
prove the post-copy owner epoch, or prove that a platform pointer survives the
delayed warp into Area 2.

The Area-1 audit now separates two questions that were previously conflated.
A three-dimensional replacement payload is not merely arithmetically
hypothetical:
breakable-box and exclamation-box triangle fragments write nonzero pitch
angular velocity, and the checked exact-binary32 coordinate witness in
`Area1PhaseSplit.v` shows that such a payload can change all three MarioState
coordinates.  From old sample `(-2048,768,-1024)`, the selected payload
evaluates to approximately
`(-2350.8427734375,1878.6683349609375,-714.5823974609375)`: a Y rise of
about `1110.6683`, above the proved 385-unit necessary bound.  Its exact
binary32 words are `[3306351996,1156240739,3291653446]`, and the corresponding
signed-short floor query is `(-2350,1878,-714)`.

That selected allocator prefix is not unique.  `[top, box]` is only one
example in a parametric source schedule.  The generic pre-apply angular
payloads fall into three stock classes: pyramid-top yaw, breakable-box dirt
triangles, and exclamation-box cartoon triangles.  Free-list depth, the
`20`/`10`/`0` mist branches, intervening zero-angular allocations, and FIFO
eviction create variants without creating another angular class.
The proof also checks the exact Area-1 macro parents and selects the middle
wing-cap box.  Its action-4 object position is `(-3000,540,800)`, and the
fragment's extra 100-unit Y offset makes the transform pivot
`(-3000,640,800)`.  It checks the seed-0 PRNG payload and the selected US/JP
sine-table words used by the transform.  It does not assert that this seed,
object count, and free-list state coincide in a reachable run.  The
breakable-box mist-suppression case and the middle-wing-cap-box numeric pivot
are separate source-backed subcases; the theorem does not silently splice
them into one execution.

For the resulting short query, `Area1SurfaceWitness.v` proves that the mirrored
transformed-top face has signed edge values `[207669,313344,2763]` and
binary32 plane height
`1483.603515625`.  A competing static face has signed edge values
`[2460,77749,76821]` and height `1280`.  These concrete checks establish
numeric candidates only.  The current theorem does not execute the live
surface lists or prove which face the real `find_floor` traversal owns or
selects.

`Area1PlatformExhaustiveness.v` shows why none of those stock schedule variants
supplies a pre-existing platform at the warp sample in its source-bounded
model.  Its finite inventory
has fifteen modeled dynamic-floor owners: one top, three Tox Boxes, two large breakables, five
exclamation boxes, one cannon lid, and three message panels.  The proof imports
four additional generated meshes—breakable-box, exclamation-box outline,
cannon lid, and wooden signpost—and checks their exact local bounds.

Every non-top owner is horizontally disjoint from node `0x1E`.  The top is the
only owner that overlaps horizontally, but its stock floor is too high for the
warp collision and platform tolerance.  Static floors have a null object
owner.  A completed final query at warp overlap must therefore return `None`.
The bounded pre-apply relation then covers completed final queries, the US
spawn clear, retained pointers at one of the three in-scope stock inbound
Area-1 positions, and frozen carry.  `stock_area1_upper_warp_preapply_platform_null` proves that
all four pre-apply platform-origin cases are null at node `0x1E`, regardless
of the controller/free-list lineage.  This theorem does not exclude Ink's
graphical fallback: that schedule starts with a null pre-apply platform and
attempts to capture the top only after the first State floor query returns
`NULL` and copies the independent Graphics sample into State for the retry.

The older admission-free theorems
`captured_top_epoch_cannot_bootstrap_upper_warp_collision` and
`captured_top_epoch_cannot_realize_route_relevant_phase_split` remain useful
special cases.  The stronger result still does not prove that every relevant
Clight memory state projects into the bounded owner/pre-apply relation.
A separately moved warp, moved top, collision-preserving clone, direct
post-query pointer/object writer, or other platform source must be connected to
that relation or excluded separately.  A graphical-retry construction instead
has to satisfy the separate Ink reachability, writer-coverage, and live-surface
obligations; it need not provide a non-null pre-apply pointer.

The second response's rendering detail names the wrong write.  The later
`copy_mario_state_to_object` updates Mario's `oPos*`, not
`header.gfx.pos`.  On this path, `stop_and_set_height_to_floor` is the code that
updates the graphical position, after which `ACT_DISAPPEARED` hides the model.
That correction does not rescue the narrow route, but it matters to an exact
phase trace.

## Authoritative source

The audit uses decomp revision:

```text
9921382a68bb0c865e5e45eb594d9c64db59b1af
```

The phase order is common to the selected `VERSION_US` and `VERSION_JP`
translations.  A crucial boundary difference is that the US
`spawn_objects_from_info` directly clears `gMarioPlatform`, while the JP
version does not.  A retained-pointer entry construction is therefore a
specifically JP concern.  A later US recapture after the clear would be a
separate technique; it cannot restore the first-Update retained pointer that
the spawn code has already destroyed.

- `src/engine/surface_collision.c`, `find_floor`:
  X, Y, and Z are narrowed to `TerrainData`, which is signed 16-bit, before
  spatial-partition and triangle queries.
- `src/game/platform_displacement.c`,
  `apply_platform_displacement`:
  Mario displacement reads and writes `gMarioStates[0].pos`.  It adds platform
  X and Z velocity but not Y velocity.
- `src/game/object_collision.c`,
  `detect_object_hitbox_overlap`:
  object overlap reads full binary32 `oPosX/Y/Z`; it does not use signed-16 PU
  wrapping.
- `src/game/object_list_processor.c`, `update_objects` and
  `bhv_mario_update`:
  surfaces are rebuilt, platform displacement runs, collision runs, Mario is
  updated and copied to his object, deactivated objects are unloaded, and the
  platform is recomputed in that order.
- `src/game/mario.c`, `update_mario_inputs` and
  `update_mario_geometry_inputs`:
  geometry and `floorHeight` are recomputed from the displaced MarioState
  before interaction dispatch.  If the first floor query fails, the fallback
  copies the graphical position back into MarioState and retries.  This
  destroys a proposal that needs to preserve the displaced State sample, but
  it enables Ink's different proposal when Graphics is already a top-side
  sample.  Proving the first `NULL`, the top-owned retry, and reachability of
  the required Object/Graphics split are separate obligations.
- `src/game/interaction.c`, `interact_warp`:
  a normal warp selects `ACT_DISAPPEARED`.
- `src/game/mario_actions_cutscene.c`, `act_disappeared`, and
  `src/game/mario_step.c`, `stop_and_set_height_to_floor`:
  the action uses the cached floor height and does not perform a ground or air
  step.
- `levels/ssl/script.c`:
  the top is at `(-2047,1536,-1023)` and the Area-1 node-`0x1E` warp is at
  `(-2048,768,-1024)`.
- `levels/ssl/pyramid_top/collision.inc.c`:
  the top mesh has local Y coordinates `-255` and `256`.
- `src/game/behaviors/pyramid_top.inc.c`:
  the intact top never moves below home, writes yaw but not pitch or roll, and
  eventually rises.
- `src/game/behaviors/warp.inc.c` and `data/behavior_data.c`:
  node `0x1E` has radius `150` and height `50`; Mario has radius `37` and a
  standard height of `160` (`100` in short-hitbox actions).

The generated Clight translation uses `AVOID_UB=1`, so the missing C return in
the failed horizontal-radius branch of `detect_object_hitbox_overlap` becomes
an explicit zero.  A separate target-object audit directly inspected the JP
return-zero path; the US result follows from the identical US/JP preprocessed
translation-unit hash and the same compiler pipeline, rather than a separately
committed US disassembly receipt.  A target-object refinement is still open.
The Rocq arithmetic does not use an undefined ISO C return to invent a
collision.

## What is proved

`CollisionMeshFacts.v` now checks the complete 39-word US and JP top-collision
initializers, parses the five vertices and six triangle-index triples from
those words, and proves that the parsed vertex Y values have minimum `-255`.
`PyramidTopSurface.v` goes one step further against newly generated
`math_util.c` and `surface_load.c` units.  It checks that the matrix and
surface-construction functions are internal, evaluates the exact CompCert
signed-short casts and partition cells for the phase-split sample, and connects
face `(1,4,3)` and its zero-yaw home vertices to the parsed generated mesh.  It
then evaluates manually mirrored binary32 transform and signed-edge formulas
and checks that both generated `find_floor` bodies contain the guarded
dynamic-floor assignment shape.  That recognizer establishes existence of the
guarded assignment only, not assignment exclusivity or the complete height
update.  The module does not yet extract the transform/edge expressions from
generated Clight, execute them over live object/surface memory, prove
partition-list ownership/order, or prove what `find_floor` actually selects.

`ClightFacts.v` now proves syntax/call-order facts for both versions:

- `find_floor_s16_coordinate_cast_source_shape_*`;
- `mario_state_object_phase_split_source_shape_*`;
- `upper_warp_phase_pipeline_source_shape_*`;
- `object_warp_delayed_lifetime_source_shape_*`;
- `pyramid_top_warp_geometry_source_shape_*`; and
- `stock_pyramid_top_yaw_only_source_shape_*`.

These are decidable, path-insensitive facts about the generated Clight ASTs.
The slot recognizers do not establish base-pointer identity, and literal
occurrences do not establish branch/dataflow control.  The detailed update
behavior above comes from direct inspection of the pinned C source.  These
theorems are not small-step memory/dataflow results.

`PyramidTopPU.v` proves the following arithmetic results without admissions.
For the concrete old/new samples it also evaluates the project's binary32
hitbox formula directly:
`upper_warp_center_overlaps_in_float32_model` proves overlap at the warp
center, while `pu_top_candidate_does_not_overlap_warp_in_float32_model` proves
that the overlap expression evaluates to false at the PU candidate.

### Same-coordinate impossibility

The minimum source-mesh vertex height at the stock home position is:

```text
1536 - 255 = 1281
```

Platform selection requires:

```text
abs(MarioY - floorY) < 4
```

so Mario's full Y must be strictly greater than `1277`.  Upper-warp overlap
requires Mario's hitbox base to be at most:

```text
768 + 50 = 818
```

The arithmetic theorem
`one_coordinate_cannot_contact_warp_and_capture_live_top` proves the
contradiction under its modeled floor-lower-bound and platform-proximity
premises.  The gap is strictly greater than 459 units; 463 would be valid only
with a separate premise that Mario is exactly on the minimum floor.  A
Clight/dynamic-surface refinement must still derive those premises.

### Conditional Y-preserving stock-yaw arithmetic exclusion

`find_floor_from_list` accepts a floor at most 78 units above the signed-16
query Y.  In the modeled standard 160-unit Mario hitbox case, warp contact puts
Mario's full Y in `[608,818]`; a 100-unit short hitbox changes the lower endpoint
to `668` but leaves the decisive upper endpoint `818` unchanged.  The modeled
top-floor lower bound is `1281`, so the 78-unit allowance cannot close the gap.

The pinned source shows the stock top changing yaw but not pitch or roll, and
the displacement code does not add its Y velocity.  Under the explicitly
modeled yaw-preserves-Y and floor-bound premises,
`stock_yaw_only_top_cannot_seed_upper_warp_bridge` proves that a synchronized
node-`0x1E` sample cannot become an admissible top-height floor query.  The
matrix and dynamic-surface helper bodies, parsed zero-yaw home-face link, and
mirrored arithmetic are now checked as described above.
Generated-expression extraction, initial-angle/state refinement, linked
live-memory execution, surface ownership/list order, and actual floor selection
remain open.
Thus the arithmetic makes a huge X/Z search pointless for the narrow
yaw-preserving stock model; it is not yet a retail US/JP impossibility theorem.

The pinned stock payload also has zero X/Z velocity, a pivot X in
`[-2087,-2007]`, pivot Z `-1023`, and no pitch or roll.  Consequently an
upper-warp-overlapping synchronized sample is within about 228 horizontal
units of that pivot, while the concrete PU candidate is at least 65,495 units
away.  Exact-real yaw preserves the pivot radius.  A linked theorem still has
to bound the generated binary32 sine-table and multiply/add rounding before
this horizontal margin is advertised as a completed Rocq execution theorem.
It applies only to stock lineage or an inactive, unreused payload; a reused
slot can contain a different pivot, velocity, pitch, or roll.

### Phase-separated countermodel

The following two samples are incompatible as one position but compatible
with the source update order:

```text
collision MarioObject = (-2048,  768, -1024)
displaced MarioState  = (63488, 1791, -1024)
```

Here:

```text
63488 = -2048 + 65536
signed16(63488) = -2048
```

Relative to the top home position, the wrapped X/Z point is `(-1,-1)`.
The Rocq model links triangle `(1,4,3)` and its zero-yaw vertices to the
generated mesh, checks the concrete CompCert casts and partition cells, and
evaluates all three manually mirrored transformed-face edge tests, world Y
`1791`, and the 78-unit numeric floor-query test.  Authenticated US/JP retail
disassembly identifies the byte-identical `trunc.w.s; mfc1; sh; lh` fragments,
and `concrete_retail_cast_fragment_arithmetic` verifies their exact
three-input value arithmetic; see
[`retail-find-floor-cast.md`](retail-find-floor-cast.md).  It does **not** prove
that a loaded dynamic surface owns the sample or that `find_floor` selects that
triangle.
The old object sample overlaps the handwritten full-float warp predicate; the
new State and copied-object sample satisfies the handwritten proximity and
alias arithmetic.

`phase_split_countermodel_exists` checks this two-sample coordinate model.  It
shows only that full-float warp contact and the later PU candidate need not be
properties of the same sample.  It does not refute either chatbot's rejection
of the narrower intact-top X/Z proposal, and it is deliberately not called a
stale-slot, ROM, or Clight execution.

`phase_split_candidate_requires_vertical_displacement` proves that this
candidate needs a Y change of `1023`.  Therefore a signed-16 X/Z alias alone
does not realize this candidate, and a Y-preserving stock-yaw transform cannot
supply the missing writer.  The more general
`upper_warp_to_live_top_query_requires_385_y_units` theorem proves that any
post-copy sample still in signed-16 Y range needs at least 385 units of upward
State displacement to turn an upper-warp overlap into an admissible numeric
floor query at height 1281 or above.  Despite its historical name, this theorem
does not establish a live, owned, or selected top surface.  A stale or reused
slot with different pitch, roll, or transform data is outside the conditional
stock-yaw theorem, but its concrete payload
must meet this quantitative bound.

## What remains open

The concrete retail cast is now verified, but the route is not.

The three-view fallback has five deliberately named boundaries:

- `Area1InkPrestateReachabilityObligation` asks whether a clean no-A Area-1
  execution can construct the required collision-Object, first-query-State,
  and retry-Graphics samples;
- `Area1InkWriterCoverageObligation` asks whether every reachable writer
  refines to the audited State-only, synchronizing, or bounded-Graphics
  relation; and
- `InkFallbackSurfaceRefinementObligation` asks whether the first query really
  returns `NULL` and the graphical retry really selects a loaded top-owned
  floor;
- `InkFallbackSinkMemoryRefinementObligation` asks for a concrete-memory
  refinement of the quicksand writer to both graphical Y and, when non-null,
  `throwMatrix[3][1]`; and
- `InkFallbackPostCopyLifecycleRefinementObligation` asks for the source-order
  link through later object writers and the explicit unload-function call,
  retained dynamic surfaces, an active or inactive same-epoch owner, and the
  final platform query.  A separate linked fact must establish that the top
  itself is scanned/deallocated and any claimed free-list insertion.

The dry ordinary source census identifies `45` as the route-specific positive
Graphics-minus-Object Y audit target; the closed arithmetic theorem excludes
a retry once a reachable writer is proved to satisfy that premise.  The
generic conservative modeled writer relation uses `<=208`.  Both are below
the `385` units required by the retry arithmetic.  Those numeric exclusions
are conditional on proving the writer/action closure and initial
synchronization represented by the obligations above; they are not a retail
reachability theorem.

A complete route witness still needs:

1. generated-expression extraction and a linked Clight memory execution for
   the now-imported matrix and surface
   helpers, including live surface ownership/list order and actual
   `find_floor` selection (`sqrtf` remains external where relevant);
2. a linked small-step proof of `Area1StockPreapplyProjectionSound`, showing
   that every relevant retail Area-1 platform pointer and final query projects
   into the fifteen-owner/source-origin relation.  A generic fragment
   controller/free-list lineage is no longer a separate obligation for this
   pre-existing-platform branch;
3. confirmation that wall/geometry processing preserves the candidate sample;
4. a multi-frame trace retaining or recapturing a valid top/surface allocation
   epoch through the `ACT_DISAPPEARED` countdown and delayed object warp; and
5. the exact Area-2 continuation to a target region and, ultimately, a newly
   set target save bit.

`delayed_warp_top_lifetime_obligation` names item 4 with exact sampled phases:
the collision frame ends with action argument `1`; the trigger frame ends after
the same-frame timer decrement at `19`; the remaining timer decrements occur
after object updates; two `PLAY_MODE_CHANGE_AREA` frames run without object
updates; and the following normal frame executes `warp_area` before the first
Area-2 platform-displacement phase.  The predicate tracks allocation epochs
after terrain-object updates and before each platform apply for the JP
retained-pointer construction.  The separate
`us_spawn_clear_blocks_retained_epoch_before_first_apply` lemma states the
state-level retained-epoch contradiction after a successful US clear; the
generated AST checks the direct US-only clear call, while its Clight memory
effect remains a refinement obligation.  The JP trace predicate likewise
awaits derivation from Clight, so one successful collision frame is
insufficient.

`Area1PlatformExhaustiveness.v` supersedes the generic fragment-lineage
question at the source-bounded pre-existing-platform boundary.  It retains the
exact
three-dimensional fragment capability, but proves every stock pre-apply
platform origin null at node `0x1E`; depth, mist, FIFO, and controller variants
cannot change that conclusion.  The remaining refinement must execute the
platform and surface code over live Clight memory and prove that the concrete
pointer/owner/query states project into the bounded relation.  The arithmetic
witness by itself does not provide that linked-memory fact.

`JPSlotLifetime.v` narrows the separate JP destination-area subproblem without
claiming that result.  It
checks the load/spawn/allocation/unload/free-list source anchors, confirms
the loop/literal/indexed-write syntax for an 80-word allocation clear and 50
packed Area-2 macro records, and proves the corresponding finite LIFO and
Before/At/After allocation-count case split.  Respawn filtering,
SpawnInfo/terrain/first-update allocations, the
exact reachable count, the concrete watched slot/payload, and the linked memory
loads at a reachable clean JP upper platform apply remain
`JPCleanUpperPlatformApplyMemoryRefinementObligation`, given an explicit
proved-first control-point witness.  Constructing that witness from the
Area-1 delayed warp and Area-2 source order is separately pending.

The prior same-sample
`UpperWarpTopCoincidenceMechanism` evidence in `FirstTargetRefinement.v` does
not encode either phase split.  Future route evidence must distinguish at
least the collision `MarioObject.oPos`, the first-query `MarioState.pos`, and
the fallback `header.gfx.pos`, followed by the post-snap State/Graphics values,
the later copied Object, and the final platform-query sample.

Thus the current result is:

- the same-sample contradiction and Y-preserving stock-transform exclusion are
  proved in the arithmetic model;
- the relevant generated matrix/surface bodies and concrete CompCert casts are
  checked; the zero-yaw face is linked to the parsed mesh, and mirrored
  transform/edge arithmetic evaluates;
- authenticated retail US/JP disassembly and Rocq fragment arithmetic verify
  the same three concrete cast results;
- generated-expression extraction, linked live-memory execution,
  dynamic-surface ownership/list order, and actual `find_floor` selection remain
  open;
- the stock source has three pre-apply angular-payload classes—top yaw, dirt
  triangles, and cartoon triangles—with depth, mist, zero-allocation, and FIFO
  variants; `[top, box]` is only one example;
- every source-bounded stock pre-apply platform origin is proved null at node
  `0x1E`, so the pre-existing-platform schedule variants do not survive in
  that model and generic controller/free-list lineage is not a remaining
  obligation for that branch; this does not eliminate the null-platform Ink
  graphical retry;
- the conditional theorem for the dry `<=45` audit target and the theorem for
  the generic conservative modeled `<=208` writer relation are arithmetically
  too small for the required `385`-unit retry gap, conditional on the
  still-open writer-coverage and entry-synchronization refinements;
- `Area1InkPrestateReachabilityObligation`,
  `Area1InkWriterCoverageObligation`, and
  `InkFallbackSurfaceRefinementObligation`,
  `InkFallbackSinkMemoryRefinementObligation`, and
  `InkFallbackPostCopyLifecycleRefinementObligation` remain open;
- a linked Clight derivation that validates the finite owner/origin projection,
  live ownership, list selection, and collision loads remains open;
- no stock-reachable counterexample has been found; and
- the ultimate less-than-one-A theorem remains unproved.
