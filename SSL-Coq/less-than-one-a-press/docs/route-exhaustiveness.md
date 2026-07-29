# Route exhaustiveness and alternative access

## Verdict

The two transcript routes have **not** been proved exhaustive for the retail
US and JP programs, and no stock-reachable no-A counterexample was found in
this investigation.

The work did settle five narrower questions:

1. The old `FirstTargetCutClassificationObligation` cannot follow from the
   endpoint/event certificate.  `endpoint_only_alignment_does_not_imply_cut_classification`
   gives a checked countermodel schema, and `ModelGapAudit.v` supplies explicit
   clean US/JP states and the missing one-step event witness.
2. “Above the second pole” is not a sound height cut.  The pole grip top is at
   world Y `4020`, but the upper-side floor ring is at Y `3942` and the upper
   Puzzle trigger is at Y `3913`.  The lower cut must instead be first
   collision-phase entry into an enumerated target-side support component
   around the pole hole.
3. A weak-model JP upper-entry bypass exists.  A retained pointer
   to an inactive, unreused exploded pyramid-top slot applies yaw delta
   `0x1800` and moves Mario from `(0,5500,256)` to approximately
   `(365.593,5500,-1096.803)`, outside the elevator shaft, without an A edge.
   The current raw-slot-only clean-state abstraction admits that seed.  Its
   raw payload and displacement mechanism are source-shaped; what remains
   unproved is the stock prehistory that retains the pointer at the upper
   warp.
4. Area 1 contains genuine source-backed three-dimensional raw payloads, but
   no modeled stock pre-existing-platform origin survives the new
   source-bounded owner proof at the warp sample.  `[top, box]` is not unique:
   the generic schedule audit finds
   three angular-payload classes—pyramid-top yaw, breakable-box dirt triangles,
   and exclamation-box cartoon triangles—plus free-list-depth,
   `20`/`10`/`0` mist, zero-allocation, and FIFO-eviction variants.
   `Area1PlatformExhaustiveness.v` enumerates fifteen modeled stock
   dynamic-floor owners and proves that every bounded completed-query, US
   spawn-clear, retained-inbound-pointer, or frozen-carry origin has a null
   platform when the old Mario object overlaps node `0x1E`.  Non-top owners are
   horizontally disjoint, the top is vertically disjoint, and static floors
   have no object owner.  Exact generated route records make `0x0A`, `0x1F`,
   and `0x20` the
   clean, non-credits inbound node set and make `0x1E` source-only to Area 2
   node `0x14`.  Therefore generic fragment controller/free-list lineage is no
   longer a Layer-B obligation for that pre-apply-platform branch.  This does
   not cover the null-platform graphical fallback described below.
5. `FirstCrossingWriterCoverage.v` gives an admission-free abstract-event
   coverage theorem for an already-constructed, contracted, ordered,
   pre-target non-target crossing.  There are five position-writer labels:
   ordinary physics, platform displacement, object impulse, collision clip,
   and area reload.  If position is unchanged, endpoint-local separation
   instead forces a selected-floor or captured-platform change.
   Splitting ordinary physics into local-cast and nonlocal/failed-cast endpoint
   domains yields six movement/domain cases plus a separate seventh
   support-selection case.  Coordinate alias/out-of-bounds is therefore an
   endpoint domain, not an independent position store.

The third item is an over-permissive-model counterexample, not yet a retail-ROM
counterexample.  It must not be excluded merely because no stock setup is
currently known.  The new `PyramidTopPU.v` audit proves that an **intact
Y-preserving stock-yaw arithmetic model cannot bootstrap the setup**: warp
contact has Mario Y at most `818`, the modeled top-floor bound is `1281`, the
platform tolerance is strictly less than four, and the floor query permits
only 78 units above its query Y.  Exact packed LevelScript records and parsed
top vertices/triangles are checked for US and JP.
`PyramidTopSurface.v` now also imports the matrix/surface-loader bodies and
checks the concrete CompCert casts and partition cells, connects the selected
zero-yaw home face to the parsed generated mesh, and evaluates manually mirrored
transform/edge formulas.  Authenticated US/JP disassembly plus Rocq fragment
arithmetic verifies the same concrete retail casts.  Generated-expression
extraction, linked live-memory execution, dynamic-surface ownership/list order,
and actual `find_floor` selection remain open.  The dynamic checker finds one
guarded assignment source shape; it proves neither assignment exclusivity nor
the complete floor/height update.

The earlier same-sample result is not by itself a global stale-slot exclusion.
The source update order can use three independent coordinates in one frame:
the old `MarioObject.oPos` for cached warp collision, `MarioState.pos` for the
wall and first floor queries, and `header.gfx.pos` if that first floor query is
`NULL`.  The fallback copies Graphics into State and retries, after which the
floor snap, State-to-Object copy, and final platform selection observe later
samples.  `phase_split_countermodel_exists` checks the older two-sample
coordinate shape, `Area1PhaseSplit.v` supplies a real three-dimensional
State-writer capability, and `InkFallback.v` checks the conditional
Object/State/Graphics shape.  The platform-origin result closes only the
*pre-existing stock Area-1 platform* branch: its finite owner model proves
that the pre-apply pointer is null whenever the old object is at node `0x1E`,
before the angular payload matters.

This conclusion is conditional on `Area1StockPreapplyProjectionSound`.
No theorem yet derives that projection from linked Clight memory, constructs
the live dynamic-surface lists, or proves the actual `find_floor` owner
selection.  Consequently this is a source-bounded pre-apply-origin theorem,
not a global schedule exhaustiveness, stale-pointer exclusion, or retail route
theorem.

Moving/loading the upper warp onto the top, moving the top down to the warp,
collision-preserving cloning, and direct post-query pointer/object writers
must still be proved to project into the excluded owner/origin relation or be
handled separately.  A successful pre-apply-platform construction outside the
bounded relation must explain a non-null pointer at the old-object node-`0x1E`
sample.  Ink's distinct construction begins with a null pre-apply platform and
instead requires a floorless State query, an independently displaced Graphics
sample, and a top-owned graphical retry.  If either construction captures the
top, node `0x1E` is delayed, so it must then retain or recapture the relevant
pointer through the later object updates.

The Clight nonvacuity obligation no longer claims that every handwritten clean
state is source-reachable.  A retained JP pointer must be connected to its
actual source floor or phase-separated geometry sample, allocation epoch,
unload/reuse trace, raw displacement fields, delayed-warp lifetime, and first
Area-2 memory before it can be used in the evidence-bearing classifier.  That
qualification validates the conditional path; it does not define the path
away or assume its displacement is safe.  See
[`pyramid-top-pu.md`](pyramid-top-pu.md),
[`pyramid-top-surface-refinement.md`](pyramid-top-surface-refinement.md), and
[`jp-slot-lifetime.md`](jp-slot-lifetime.md) for the complete current boundary.
The authenticated cast receipt is
[`retail-find-floor-cast.md`](retail-find-floor-cast.md).

## Correct cuts

For the upper entrance, Mario spawns at `(0,5500,256)` inside the static shaft
aperture.  The aperture is approximately:

```text
x in [-101, 102]
z in [154, 358]
y in [5222, 5734]
```

The pyramid elevator is at `(0,4966,256)`.  Its collision has a floor at local
Y `0` and closed side walls up to local Y `256`.  The imported cutscene action
calls `launch_mario_until_land` with binary32 `0.0f`; that helper writes zero
forward velocity before `perform_air_step`.  That syntax receipt alone does
not prove a vertical descent, keep every intermediate query on the shaft line,
or prove selection of the live elevator floor.  Those facts require linked
execution of the initial action, wall/floor queries, and every earlier writer.
JP retained-platform displacement is a distinct
pre-landing writer and cannot be hidden inside “ordinary fall.”

For the lower entrance, the second pole is based at `(0,3200,1331)`, has
modeled height `920`, and places Mario near Y `4020` at the top grip.  The
target-side floor opening is approximately:

```text
x in [-101, 102]
z in [1229, 1434]
support Y = 3942
```

The transcript’s ordinary A route supplies lateral clearance across the
roughly 101-unit opening.  The archived normalized soft-bonk model bounds
non-A lateral radius by `70 + 2*frame` and loses the required height before
reaching that clearance.  That is only a restricted subcase.  The formal cut
therefore uses finite static support IDs, dynamic object IDs, and Float32 open
cells rather than a predicate such as “Mario reached floor 3” or
`marioY > 4020`.

## Evidence-bearing classification

`FirstTargetRefinement.v` adds `ClightFrameEvidence`.  A classified frame now
carries:

- actual before/after Clight states;
- a prefix/segment/suffix decomposition of the CompCert trace;
- projected before/after `GameState` values;
- the exact indexed `CertifiedStep`; and
- a movement witness that starts on the source side and ends on the target
  side of a concrete `CollisionSupportCut`.

It also records that platform displacement writes `MarioState.pos`, while the
same-frame object collision phase can still sample `MarioObject.oPos`.  A
single abstract event slot cannot simultaneously stand for both the
displacement and the later target collision.

The old `FirstTargetWriterCoverageObligation` is unused and too weak for this
job.  It only asks for some projected event no later than the target; it does
not require that event to change a cut side or to be the first crossing.  Nor
is an arbitrary `CollisionSupportCut` a separator:
`an_unvalidated_cut_can_place_one_state_on_both_sides` constructs a descriptor
whose source and target support sets overlap.

`FirstCrossingWriterCoverage.v` supplies the corrected boundary:

- `TargetCollisionCutFamily` parameterizes the selected descriptor for each
  version/entrance/target combination, while
  `EntranceCollisionCutEntryContract` places every matching clean entry on the
  source side and excludes the matching entry snapshot from the target side;
- `FirstValidatedCutCrossingAt` carries an actual projected Clight frame whose
  before-state is on the source side and after-state is on the target side,
  requires side separation at that actual endpoint, star-orders that segment
  before a matching target-event segment, supplies ordered evidence for every
  earlier index, and excludes every earlier projected endpoint from the target
  side; and
- `validated_pre_target_first_crossing_writer_coverage` is an admission-free
  theorem classifying that crossing.

The theorem has five possible projected position-writer labels: ordinary
physics, platform displacement, object impulse, collision clip, and area
reload.  It also finds
a distinct same-position case: if Mario's coordinates do not change,
endpoint-local side separation requires the projected floor or captured
platform to change.
Ordinary physics is then partitioned into a local coordinate-cast endpoint and
a nonlocal or failed-cast endpoint.  The corrected no-A boundary therefore has
six movement/domain exclusions and a separate seventh support-selection
exclusion.  General coordinate alias/out-of-bounds is a property of the
ordinary-physics endpoint, not an independent store that writes Mario's
position.

The module also proves useful bounded eliminations.  Certified ordinary
administrative events preserve Mario's entire kinematics.  A changed
`EventAreaReload` returns to the recorded entry snapshot; it cannot cross a
validated target cut when the post-reload state shares the initial version,
entrance, and entry snapshot.  The stock Area-1 node-`0x1E` platform-bootstrap
subcase reduces to the already-proved null-platform theorem.  These statements
do not prove the corresponding linked-retail exclusions.

Within the certified event semantics, the following proposed bypass causes are
proved impossible:

- direct displacement by the zero-offset Area-2/Area-3 instant warp;
- target relocation/substitution that violates target provenance;
- invalid trigger/controller lifecycle transitions;
- newly setting a target bit through coherent save reload; and
- a projected event with no indexed certified step, once a refinement
  certificate is supplied.

The target-bit connection is now load-bearing rather than merely adjacent to
that classification.  `aligned_newly_collected_act3_reaches_act3_cut` proves
that a newly set Act 3 bit in an aligned certified execution entails an
Act-3-region observation.  The Act 6 analogue,
`aligned_newly_collected_act6_reaches_upper_trigger_cut`, uses the clean-entry
hidden-star lifecycle theorem to entail an upper-trigger-region observation.
These implications intentionally run in only one direction: entering a region
does not by itself prove that the corresponding star was collected.

`evidence_bearing_route_cut_blocks_new_target_bits` then connects those Layer-A
facts to the evidence-bearing first-cut classifier.  Under no A edge, a
classification for the concrete Clight run, and unreachability of the six open
writer classes below, neither target bit can be newly set.  This capstone does
not use the payload-free `FirstTargetCutClassificationObligation`.

The whole-run form,
`conditional_evidence_bearing_clight_run_impossibility`, keeps three residuals
explicit:

1. `WholeProgramClightRefinementObligation`, which must construct the
   Clight-to-certified-event certificate, including Layer A;
2. `EvidenceBearingRouteClassificationRefinementObligation`, which must
   construct the aligned route and evidence-bearing first-cut classification
   from that same run; and
3. `NoAOpenRouteWriterClassesUnreachableObligation`, which must eliminate the
   six surviving writer/geometry classes under the actual projected no-A
   inputs.

This is a sharper theorem boundary, not a discharge of those residuals.  The
new first-crossing module does not silently retrofit this older capstone:
constructing `FirstValidatedCutCrossingAt` from the linked run, connecting the
target collision to the validated target side, and treating a crossing inside
the same frame or subframe as the target collision remain explicit refinement
work.

The linked-retail no-A exclusions still unproved are:

- local ordinary Mario physics and static geometry;
- platform displacement, especially JP retained/reused slots;
- object impulses and moving geometry;
- collision clips or tunneling;
- ordinary-physics endpoints outside the proved local cast domain, including
  general parallel-universe/out-of-bounds and failed-conversion cases;
- normal area-reload or entry displacement outside the conditional theorem's
  route-context premises; and
- same-position floor/platform support selection.

The first six are the movement/domain cases.  The final bullet is the separate
seventh case omitted by the historical classification.  The old bounded static
quarter-step lemma rules out only one coordinate-alias subcase.

## Ordinary-motion status

Ordinary motion cannot be eliminated by equating no A edge with no movement.
It includes walking, stored momentum, gravity, falling, sliding, landing, pole
actions, and normal static floor/wall/ceiling response.  The current abstract
`MotionPhysicsFrame` also accepts an arbitrary endpoint, so a first-crossing
event carrying that label is not yet evidence that the generated physics
produced the crossing.

`OrdinaryMotion.v` replaces that shortcut with a finite-cell safe-envelope
interface and proves composition from explicit preservation and
target-exclusion premises.  A concrete proof must enumerate source-side cells
and prove every linked no-A ordinary step preserves membership.  Endpoint locality is
insufficient; the refinement must expose the pre-action wall push, graphical
fallback, up to four ground/air quarter steps, action-local stores, and every
intermediate floor, wall, and ceiling query.  Earlier nonordinary writers must
preserve the same envelope, because they may prepare an action or velocity
whose following ordinary frame becomes the first crossing.

There is a genuine source-backed no-edge ascent.  A may be held at clean
entry, and punching followed by B can select `ACT_JUMP_KICK` on
`INPUT_A_DOWN`, without `INPUT_A_PRESSED`.  The checked US/JP source shape
sets vertical velocity to `20.0f` and calls `perform_air_step(m, 0)`.
A separate B-driven dive/rollout candidate initializes `30.0f` and also uses
step argument zero.  Exact generated elevator vertices reach local Y 256;
dynamic-surface construction adds five to the wall's upper Y, and the lower
wall query uses a 30-unit center offset.  For an integer-translated wall,
vertical rejection therefore requires relative center Y strictly above
`256 + 5 - 30 = 231`.  Closed non-Wing 4-unit-gravity arithmetic bounds jump
kick by 128 and rollout by 220 relative units.  These numbers do not prove the live wall
is selected or that the action inventory is closed.

The cap state is load-bearing.  With held-A Wing-Cap flutter after rollout
turns downward, a closed arithmetic countermodel reaches 228 relative units.
That refutes the non-Wing 220 bound but remains below 231, so it is not a
vertical-clearance witness.  Nor is it a clean retail bypass witness: retail
area-entry initialization resets the special cap state, but `GameState` does
not yet carry flags/cap timer and the generated initialization effect has not
been connected to the clean-entry projection.

The upper clean snapshot begins above, not inside, the elevator cage: entry Y
is 5500 and the initial raw rim top is 5222.  The generated
`ACT_SPAWN_NO_SPIN_AIRBORNE` path has syntax receipts for a zero-forward-speed
launch helper followed by an air step.  Those receipts do not yet execute the
fall, prove all intermediate queries stay on the shaft line, or select the
live elevator floor.  Landing into the post-entry safe envelope is therefore
an explicit prerequisite to the ascent subkernel.

For the lower entrance, Z can leave the second pole through `ACT_SOFT_BONK`;
sliding below its bottom can enter freefall.  The existing normalized
soft-bonk arithmetic blocks only that restricted trajectory.  The complete
collision-phase lower safe envelope is still open.  The exact theorem and
countermodel boundary is in
[`ordinary-motion.md`](ordinary-motion.md).

## JP stale pyramid-top candidate

The relevant retail formula in `platform_displacement.c` uses binary32
matrix operations and s16 angle-table indexing.  With:

```text
Mario M = (0, 5500, 256)
platform P.xz = (-2047, -1023)
oAngleVelYaw = 0x1800
oVelX = oVelZ = 0
pitch delta = roll delta = 0
```

the horizontal offset `(2047,1279)` is rotated by `33.75` degrees.  The
binary32 result is approximately:

```text
M' = (365.592773, 5500, -1096.8027)
```

The pointer dereference does not check active flags, behavior, collision data,
or floor ownership.  Vertical object velocity is irrelevant to this
horizontal rotation path.

This payload demonstrates why JP cannot simply be modeled as
`gMarioPlatform = NULL`.  It also does not prove stock reachability.  The
archived source-floor audit proves only that the pyramid top at its ordinary
position does not own either stock Area-1 pyramid warp, and its closed-world
seed census found no enumerated setup that installs this exact stale pointer
at node `0x14`.  It does not rule out moving/loading the upper warp onto the
top, moving the top to the warp, or a collision-preserving clone mechanism.
The concrete ROM replay is therefore a fixture-assisted mechanism test unless
a controller-only predecessor trace is later found.

## Pyramid-top PU result

Syntax anchors behind the newest proof are checked against both generated
versions.  Direct inspection of the pinned source supplies the stronger update
account: `find_floor` contains the binary32-to-signed-16 casts; platform
displacement writes MarioState; object collision reads the old Mario object;
Mario geometry refresh precedes warp interaction; `ACT_DISAPPEARED` snaps to
the refreshed floor; the later copy and platform query use the new object
position; object updates precede each of the 20 normal-play timer decrements;
two change-area frames omit object updates; and the next normal frame runs
`warp_area` before the first Area-2 update.  The AST slot/literal recognizers
are base- and path-insensitive, so this is not yet a Clight
execution/dataflow theorem.

The proved split is:

- `one_coordinate_cannot_contact_warp_and_capture_live_top`: the ordinary
  handwritten full-coordinate overlap and modeled platform conditions
  contradict;
- `stock_yaw_only_top_cannot_seed_upper_warp_bridge`: preserving warp-altitude
  Y cannot make the numeric floor query accept the modeled top bound;
- `pyramid_top_surface_semantic_kernel`: both generated versions contain the
  needed helper bodies and cast/guarded-assignment source shape; the guarded
  checker is not an exclusivity/full-update theorem; the concrete casts/cells
  evaluate, the zero-yaw face is tied to the parsed mesh, and the mirrored
  transform/edge formulas evaluate without linked Clight execution;
- `phase_split_countermodel_exists`: a collision sample and a later
  coordinate/alias sample can satisfy the handwritten conditions separately;
  this is not a stale-slot or surface-selection theorem; and
- `phase_split_candidate_requires_vertical_displacement`: the concrete model
  needs a Y writer, not just a 65536-unit X alias; and
- `upper_warp_to_live_top_query_requires_385_y_units`: any post-copy sample
  still in signed-16 Y range needs at least 385 units of upward State
  displacement between upper-warp overlap and an accepted numeric floor query
  at height 1281 or above.  Its historical name does not establish live
  surface ownership or selection;
- `area1_fragment_writer_source_checked`: the imported Area-1 source contains
  the nonzero triangle-fragment angular fields used by the candidate; and
- `concrete_area1_fragment_displacement_is_route_sized_3d`: exact CompCert
  binary32 arithmetic for the selected payload changes X, Y, and Z, and its Y
  rise exceeds the route's 385-unit necessary lower bound; and
- `area1_surface_capability_checked` in `Area1SurfaceWitness.v`: at short query
  `(-2350,1878,-714)`, the mirrored transformed-top face has signed edges
  `[207669,313344,2763]` and height `1483.603515625`; a checked static face has
  edges `[2460,77749,76821]` and height `1280`.  This checks numeric
  candidates, not live-list ownership or final selection; and
- `area1_platform_source_model_checked` in
  `Area1PlatformExhaustiveness.v`: the finite stock Area-1 owner inventory,
  source records, upper-warp owner exclusions, pre-apply origin cases,
  free-list example, and exact three-dimensional fragment arithmetic all hold.
  `CollisionMeshFacts.v` separately checks the four generated fixed-owner mesh
  bounds used by the audit.  In particular,
  `stock_area1_upper_warp_preapply_platform_null` leaves no non-null stock
  pre-apply platform at node `0x1E` in the source-bounded model.  It says
  nothing about capturing a platform later through the graphical retry.

The allocator analysis does not privilege one `[top, box]` prefix.  Its
parametric stock words contain top-yaw, dirt-triangle, and cartoon-triangle
angular payloads, with depth, mist-count, zero-allocation, and FIFO variants.
The exact fragment example remains useful proof that a three-dimensional
primitive exists, but no controller lineage for that generic primitive needs
to be solved for the pre-existing-platform branch: all source-bounded stock
pre-apply platform origins are null at the warp sample.  The Ink branch has
different reachability and surface-selection obligations.

The project also verifies the exact concrete retail cast.  It leaves
generated-expression extraction, linked live-memory execution, surface
ownership/list selection, proof that the finite owner/pre-apply relation covers
the linked program, and `delayed_warp_top_lifetime_obligation` open.  It is
neither a stock-game counterexample nor proof that all alternative upper routes
are impossible.

## Ink's graphical-fallback scheduling shape

The source admits one additional scheduling shape that the earlier
State/Object analysis did not represent:

```text
collision Object C  -- full-float overlap with node 0x1E
physics State S     -- two wall queries, then first find_floor(S) = NULL
graphical sample G  -- copied to State, retry find_floor(G) selects live top
```

The cached warp collision is processed after the fallback.  If its retry floor
is the top, `ACT_DISAPPEARED` snaps State to that floor, copies the snap to
Graphics, and the later State-to-Object copy and final platform query can
capture the top owner.  Thus update order does **not** make this conditional
primitive impossible.

`InkFallback.v` proves two coordinate/control-flow countermodels: one with a
local top-side `G`, and one with `G.x = 63488` aliasing the local top through
the signed-16 floor query.  It also proves:

- selected generated static faces and walls reject the concrete first-query
  diagnostic `S = (-2200,768,-1024)`;
- every owner in the fifteen-owner abstract dynamic-floor inventory is
  rejected for that first query;
- the retry requires at least 385 units of upward `G.y - C.y` separation;
- the dry ordinary visual bound `<=45` cannot supply that retry;
- the generic conservative audited Graphics-writer envelope `<=208` also
  cannot supply the required `385`-unit retry gap; and
- any prefix of arbitrary State-only ordinary, platform, or PU displacement
  preserves C and G, so it cannot create their split from `C = G`.

The `45` figure is the dry route-specific source-census bound.  The `208`
figure deliberately over-approximates generic water-pitch and swimming-bob
composition.  Both exclusions still require the open writer/action closure
and entry-synchronization refinement; the arithmetic theorem does not prove
that every retail step belongs to the audited writer relation.

The last point explains what PU movement adds: signed-16 aliasing can make a
pre-existing far-away graphical sample select the local top, but a State-only
PU displacement does not itself write that graphical sample.

No stock-reachable setup has been found.  The current source census finds no
clean SSL Area-1 large Graphics writer; the known full-XYZ anchoring writer is
used by Chuckya/King Bob-omb behavior, absent from stock SSL Area 1.  This is
not yet a linked Clight action/spawn-closure theorem.  The real static and
dynamic surface-list traversal is also unproved, so the selected face
arithmetic is not advertised as an actual first `NULL` or top-owned retry.

Accordingly, this scheduling shape is neither eliminated nor a retail
counterexample.  `Area1InkPrestateReachabilityObligation`,
`Area1InkWriterCoverageObligation`, and
`InkFallbackSurfaceRefinementObligation` state the narrow remaining work.
See [`ink-fallback.md`](ink-fallback.md).

`JPSlotLifetime.v` further checks the JP load/spawn/allocation/unload/free-list
anchors, the loop/literal/indexed-write syntax for an 80-word allocation clear,
and the 50-record Area-2 macro input.  Its finite LIFO recurrence and
Before/At/After allocation-count cases
do not determine the exact reachable allocation/free trace or payload at the
relevant clean JP upper platform apply; those loads remain
`JPCleanUpperPlatformApplyMemoryRefinementObligation`, given an explicit
proved-first control-point witness.  Constructing that witness from the
Area-1 delayed warp and Area-2 source order is part of the pending refinement.

## Emulator search boundary

The authenticated US and original-JP ROMs were checked with debugger input
plugins.  The search included:

- natural and injected JP Area-3-to-Area-2 platform-pointer probes;
- six US C-up speed fixtures;
- upper-entry schedules using idle, eight stick directions, B pulses,
  Z+B/slide-kick-shaped pulses, and already-held-A plus B schedules; and
- the stale pyramid-top payload above.

All tested schedules kept `A_BUTTON_PRESSED` false.  The clean upper-entry
search covered 41 schedules per version, 82 total.  The stale-payload search
covered 25 distinct boundary schedules and one pre-transition-only
predecessor.  The archived platform and C-up probes add eight fixture
executions.  The successful schedule was rerun while successively adding
object-lifecycle trace fields; those logging reruns are not counted as new
schedules.

No stock-reachable target region was found.  The boundary-fixture JP replay
did, however, find a model-level `BypassPlatformDisplacement`: slot-60 yaw
displacement followed by 60 frames of stick input and neutral input consumes
the upper hidden-star trigger at relative frame 78.  The trace has zero
`A_BUTTON_PRESSED` frames, zero `A_BUTTON_DOWN` frames, and changes the
hidden-star-controller count from zero to one.  It neither enters the Act 3
region nor spawns or collects the Act 6 star.  The probe does not directly read
save RAM, so this is not a newly-set-target-bit witness.

The matching pre-transition-only attempt fails: Area unload/load reuses slot
60, clears `gMarioPlatform`, and replaces the raw payload before the first
Area-2 input boundary.  Thus the successful replay refutes bypass
unreachability under the current over-permissive clean abstraction, but it is
not a controller-only retail trace.  Exact RAM fields, inputs, frame trace,
ROM hashes, and the reproducible probe are in
[`model-counterexample.md`](model-counterexample.md).

Level selection and warp setup also use fixture writes.  A finite schedule
search is negative evidence, not an exhaustive reachability theorem.

## Source-level exclusions

`SourceExhaustiveness.v` proves within its executable finite inventory that
the seven normal SSL star sources use indices `0` through `6`; only the static
pyramid source uses target index `2`, and only Pyramid Puzzle uses target
index `5`.  Klepto, the area-1 static star, Eyerok, red coins, and the
100-coin star therefore do not alias either target.

The same module proves coherent active/backup reload preservation and an
explicit first-target writer classification.  Connecting all compiled writers
to that inventory remains open.

`CollisionMeshFacts.v` checks the generated initializer lengths and exact
US/JP equality for the Area-2/Area-3 static arrays and route-relevant dynamic
collision arrays.  It now additionally proves exact local X/Y/Z bounds for the
imported breakable-box, exclamation-box-outline, cannon-lid, and
wooden-signpost meshes used by the Area-1 owner envelopes.  It does not yet
parse the general arrays into a proved surface graph or show that a proposed
`CollisionSupportCut` matches every triangle.

The generated boundary now contains 31 translation units per version, 62
Clight modules total.  The newly imported `mario_actions_submerged.c` units
have admission-free AST receipts for the water full-step helper calls, all
three direct whirlpool position slots, and the common water-level clamp.  This
repairs a source-coverage omission; it does not prove submerged actions
reachable or unreachable in SSL, nor does it establish whole-program
position-writer callgraph completeness.

## What remains

To prove route exhaustiveness, the project still needs:

1. a linked-program frame projection that constructs the ordinary refinement
   certificate and `ClightFrameEvidence`, thereby discharging
   `WholeProgramClightRefinementObligation` and the projection part of
   `EvidenceBearingRouteClassificationRefinementObligation`;
2. a checked parser/refinement from the generated collision arrays to exact
   surface IDs, dynamic owners, and target-side components, followed by proofs
   of their `EntranceCollisionCutEntryContract`, their endpoint-local
   separation, and their selection by `TargetCollisionCutFamily`;
3. source-backed JP destination-area platform state plus its exact reachable
   allocation/free trace, slot reuse, payload loads, and delayed-warp
   retention/recapture.  The generic Area-1 fragment controller lineage is no
   longer part of this Layer-B item; instead, the missing proof must connect
   linked Area-1 memory to the finite owner/pre-apply relation;
4. construction of `FirstValidatedCutCrossingAt` from every linked first
   target access, including the target-collision-to-cut relation and crossings
   occurring inside the same frame or subframe as the target collision;
5. unreachability under no A edge of the six linked movement/domain cases:
   local ordinary motion, platform displacement, object/moving geometry,
   clip/tunnel, nonlocal or failed-cast ordinary-physics endpoints, and
   lifecycle/entry displacement;
6. unreachability of the separate same-position floor/platform
   support-selection case; and
7. a proof that the ordinary elevator/pole A-labelled observations correspond
   to the actual action branches that cross those cuts, completing the
   classification residual.

For the node-`0x1E` candidate, item 3 no longer asks for a particular
controller sequence, object count, mist branch, or free-list depth.  `[top,
box]` is one schedule among many, but the bounded theorem removes all of them
at the platform-origin boundary: completed stock queries, the US clear, JP
stock inbound retention, and frozen carry are null at warp overlap.  The open
question is whether linked retail memory always satisfies that finite
projection.  Generated-expression extraction, linked live-surface memory, list
selection, every construction not yet shown to project into the bounded
relation, and the exact JP destination-area allocation trace remain open.
This platform-origin result does not remove Ink's null-platform graphical
retry; its three named reachability, writer-coverage, and surface-refinement
obligations remain open.

Alternatively, a stock-reachable constructor must be recorded with its exact
clean initial RAM state, controller frames, object/global trace, and target
overlap or newly set bit.  Neither completion condition was met here, so the
ultimate impossibility theorem remains unproved.
