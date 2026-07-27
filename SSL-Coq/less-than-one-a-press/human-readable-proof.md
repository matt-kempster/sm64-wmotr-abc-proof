# Human-readable proof guide

This document explains the proof project for a reader who understands software
engineering but does not know *Super Mario 64*.

> **Current status:** the project does not yet prove the retail-game theorem.
> It proves a collection/provenance reduction in an abstract event model, a
> finite normal-star/save-writer classification, exact first-target
> gate-or-named-bypass theorems, selected facts about generated US and JP
> Clight syntax, and exact equality/count facts for the generated route-relevant
> collision arrays.  `FirstTargetRefinement.v` now gives bypasses concrete
> Clight-frame, projected-state, writer, and collision-cut evidence and rules
> out several classes inside the certified model.  It also proves the needed
> direction from an aligned newly set Act 3/Act 6 bit to the corresponding
> target-region cut, then blocks both bits when an evidence-bearing classifier
> and exclusions for all six open writer families are supplied.  It does
> **not** construct those premises from a complete retail execution.
> `ModelGapAudit.v` proves that the older abstract event relation admits a
> spurious one-frame collection from a clean entry, so that relation cannot by
> itself establish the retail theorem.

> **Newest bounded result:** `Area1PlatformExhaustiveness.v` replaces the
> earlier focus on one `[top, box]` free-list prefix with a finite stock Area-1
> platform-owner model.  The source audit finds three pre-apply angular-payload
> classes—pyramid-top yaw, breakable-box dirt triangles, and exclamation-box
> cartoon triangles—with parameterized depth, mist-count, and FIFO-eviction
> variants.  `[top, box]` is therefore one example, not a unique schedule.
> Nevertheless, every stock pre-apply platform-origin case in the bounded model
> has a null platform when Mario's old collision object overlaps warp node
> `0x1E`.  Non-top dynamic owners are horizontally disjoint from the warp; the
> pyramid top is vertically disjoint; static floors carry no object owner; and
> the US clear, retained stock inbound positions, completed-query, and
> frozen-carry cases all reduce to null.  Thus no stock route-relevant schedule
> in this model
> can create the needed State/Object split.
>
> `PyramidTopSurface.v` and `PyramidTopPU.v` retain the exact cast, mesh,
> partition-cell, and arithmetic kernel.  The retail cast question is closed
> for the exact candidate inputs: authenticated US/JP disassembly uses
> `trunc.w.s; mfc1; sh; lh`, and Rocq checks its signed-halfword arithmetic.
> The new null result is conditional on the linked Clight state projecting into
> the finite stock-owner/pre-apply relation.  That live-memory refinement,
> actual surface ownership and list selection, alternative constructions outside
> the bounded relation, and JP delayed-warp lifetime remain open.
> `JPSlotLifetime.v` narrows the destination-area question but does not extract
> the reachable memory trace.  The ultimate theorem is still incomplete.

## The problem in software terms

The game runs an update loop.  Each frame reads a controller, updates Mario and
the object pool, detects collisions, runs object behaviors, and may update the
save file.  The two outcomes of interest are save-file bits for these stars:

- Act 3, **Inside the Ancient Pyramid**, whose zero-based star index is `2`;
- Act 6, **Pyramid Puzzle**, whose zero-based star index is `5`.

A star is *newly collected* only when its bit is clear in the initial save
flags and set in the final save flags.  Starting with the bit already set does
not count.

The controller stores both the buttons currently held and the buttons newly
pressed on this frame.  In the source, the relevant update is equivalent to:

```c
buttonPressed = current & (current ^ previousButtonDown);
buttonDown = current;
```

The project therefore defines "fewer than one A press" as: the A bit of the
edge-triggered pressed value is false on every modeled frame.  A may already be
held when execution begins.  Holding A continuously is not a new press.

The pyramid interior is area 2.  A clean execution can begin through either:

- the **upper entrance**, which places Mario inside a descending elevator; or
- the **lower entrance**, which places Mario at the bottom of the pyramid.

`CleanPyramidEntry` also requires the two target bits to be clear, all five
Puzzle triggers to be unconsumed, no substitute target star to be waiting in
the object pool, valid spawn/list state, no pending collection or exit, enough
controller history to compute the first edge, and the version-specific
platform-pointer state needed by US and JP.  It now also requires the backup
save slot to agree on both target bits.  This matters because the game-over
path can copy the backup slot over the active one; without coherence, a model
could "collect" a target merely by reloading an already-set backup.

There is an important current abstraction gap here.  The abstract JP branch
accepts a non-null platform pointer when its pool slot is merely well formed;
it does not yet prove the gameplay prehistory that made Mario stand on that
surface or that preserved the pointer across the load.  This is deliberately
reported rather than hidden by strengthening clean entry to require `None`.
The concrete clean-entry refinement must instead recover the pointer, slot,
allocation epoch, raw platform fields, unload, and possible reuse from an
actual predecessor Clight execution.

The two entrances are not represented by a label alone.  The entry snapshot
records source warp node `0x0A` or `0x14`, exact Float32 position, 180-degree
facing, zero velocity, zero forward speed, and the airborne-spawn action
`0x1932`.  It also identifies the static Act 3 star and all five macro triggers
by allocation reference, macro kind, and exact Float32 position.  The concrete
surface pointer behind the abstract floor reference still needs a Clight
projection.

The pinned area definitions provide concrete landmarks for the future geometry
proof: the lower and upper entry warp objects are at `(0, 300, 6451)` and
`(0, 5500, 256)`; the elevator starts at `(0, 4966, 256)`; the second pole is
at `(0, 3200, 1331)` with behavior parameter `92`; the Act 3 star is at
`(500, 5050, -500)`; the Act 6 hidden-star controller is at
`(900, 1400, 2350)`; and the upper trigger is at `(260, 3913, -600)`.  These
initializer facts identify objects and candidate regions.  Coordinates alone
do not prove that Mario can or cannot reach them.

## The route argument in one diagram

The transcript suggests two normal-route gates.  The formal cut cannot be
defined only as "outside the elevator" or "above the second pole," because
those phrases omit collision phase, moving support, and passage topology.
The current evidence interface therefore describes each cut by source-side
and target-side static surface identifiers, dynamic object identifiers, and
Float32 open cells:

```text
clean upper entry
       |
       v
 spawn shaft / elevator supports
       |
       +-- first collision-phase crossing of the upper cut --+
                                                              |
clean lower entry                                             v
       |                                             shared target-side supports
       +-- ordinary lower route --> second-pole area --+      |             |
                                                       |      v             v
                                                       +--> Act 3 region  upper trigger
                          first crossing of the lower target-side cut
```

The "second pole" is still the likely normal control-flow gate, but its grip
top is at Y `4020`, while real target-side support and the upper trigger are
lower (support Y `3942`, trigger Y `3913`).  A predicate such as
`marioY > 4020` would therefore miss a genuine route.  The lower proof
obligation is the first collision-phase transition into the target-side
support/open-cell component around the access hole, not a height threshold.

This is a control-flow-cut argument:

1. Select the first collision observation of the Act 3 star region or upper
   hidden-star trigger.
2. Recover the last source-side and first target-side states before that
   observation from an actual Clight segment.
3. Classify the writer responsible for the crossing: ordinary Mario/static
   geometry, platform displacement, object or moving geometry, warp,
   clip/tunnel, coordinate alias, target/lifecycle anomaly, save mutation, or
   projection/memory failure.
4. Prove the applicable writer cannot cross the entrance-specific cut without
   an A edge, or record its exact reachable witness.

The Rocq route-gate model proves the logical case split itself.  The strengthened
version first selects the exact earliest target observation, including its
position within a frame, and synchronizes the route prefix with the event
prefix.  For a trace satisfying its explicit route-coverage premise, that first
access has one of two entrance-specific forms:

- an A edge occurred at the elevator or second-pole gate before the target; or
- one bypass class tag occurred before the target.

The historical route tags are still only vocabulary.  The new
`EvidenceBearingBypassAt` record does carry the missing payload: an indexed
Clight segment, projected before/after `GameState`s, an exact certified event,
a writer class, a collision-support cut crossing, and alignment to the route
tag.  It also adds the previously omitted ordinary Mario/static-geometry
class.  `EvidenceBearingFirstTargetCutClassification` is the narrow remaining
coverage interface that must be constructed from the linked program.

Inside the present certified semantics, the proof eliminates direct area-2/3
warp displacement, invalid target identity/provenance, invalid hidden-star
lifecycle, coherent save-reload mutation, and projection mismatch once the
indexed certificate exists.  A bounded static quarter-step cannot make the
modeled 65536-unit coordinate alias.  Six writer families remain open:
ordinary Mario/static geometry, platform displacement, object/moving
geometry, collision clips, general coordinate alias/out-of-bounds behavior,
and normal lifecycle/entry displacement.

The evidence-bearing conditional theorem is:

```coq
Theorem evidence_classifier_with_open_writers_closed_requires_a_edge :
  forall projection run initial certificate trace,
    CleanPyramidEntry initial ->
    ClightRouteTraceProjection
      projection run initial certificate trace ->
    EvidenceBearingFirstTargetCutClassification
      projection run initial certificate trace ->
    OpenRouteWriterClassesUnreachable
      projection run initial certificate trace ->
    reaches_any_target_region trace ->
    trace_contains_a_press trace.
```

Every substantial premise in this statement is visible.  In particular, it is
not the unconditional retail theorem: writer coverage and the six
unreachability families are exactly the work still required.

The proof now connects this route result to the save bits in the direction an
impossibility argument needs:

```coq
Theorem evidence_bearing_route_cut_blocks_new_target_bits :
  forall projection run initial certificate trace,
    CleanPyramidEntry initial ->
    ClightRouteTraceProjection projection run initial certificate trace ->
    EvidenceBearingFirstTargetCutClassification
      projection run initial certificate trace ->
    OpenRouteWriterClassesUnreachable
      projection run initial certificate trace ->
    fewer_than_one_a_press (project_inputs projection run) ->
    ~ newly_collected
        (state_save_flags initial)
        (state_save_flags
          (refined_final_state projection run initial certificate))
        act3_index /\
    ~ newly_collected
        (state_save_flags initial)
        (state_save_flags
          (refined_final_state projection run initial certificate))
        act6_index.
```

The key intermediate lemmas say “new Act 3 bit implies an Act 3 interaction
cut” and “new Act 6 bit implies an upper-trigger cut.”  They do **not** reverse
that implication: merely entering a region is not modeled as collecting a
star.  The whole-run wrapper
`conditional_evidence_bearing_clight_run_impossibility` keeps three residuals
visible: whole-program Clight/event refinement, construction of the
evidence-bearing route classification, and unreachability of the six open
writer families.  All three remain open for the retail programs.

The older, coarser capstone-facing statement remains:

```coq
Theorem transcript_route_gate_reduction :
  forall initial trace,
    TranscriptRouteGateModel initial trace ->
    fewer_than_one_a_press (route_inputs trace) ->
    reaches_any_target_region trace ->
    (state_entrance initial = UpperEntrance /\
       elevator_escape_observed trace) \/
    (state_entrance initial = LowerEntrance /\
       above_second_pole_observed trace).
```

The lower-level theorem
`no_a_target_access_requires_preceding_gate_bypass` keeps the selected frame
indices, so the bypass is proved to occur before the selected target
observation.  `transcript_route_gate_reduction` is its simpler capstone-facing
corollary and intentionally forgets those indices.

`TranscriptRouteGateModel` is an explicit route-coverage premise.  It says the
chronological observation stream contains the entrance-specific gate before a
target observation: either an A-edge-labelled gate observation paired with the
same modeled frame input, or the corresponding bypass.  The theorem removes
the A-action branch when every input frame has no A edge.  It does not prove
the gate label's control-flow meaning or the coverage premise from C.

The model deliberately targets the **Act 3 interaction region** and the
**upper hidden-star trigger**, rather than claiming that merely reaching a
floor writes a save bit.  The collection layer separately explains why those
regions matter.

### Conditional stale pyramid-top route

The user's additional route observation is represented explicitly rather than
ruled out by definition.  The relevant source is Area-1 warp node `0x1E` at
`(-2048, 768, -1024)`; it enters Area 2 at node `0x14`,
`(0, 5500, 256)`.  On JP, if a top-owned `gMarioPlatform` pointer survives
that warp and the top's slot becomes inactive or reused, Area 2 can read the
slot's displacement fields.  The current source-shaped payload with position
`(-2047, *, -1023)` and yaw delta `0x1800` maps upper-entry Mario from
approximately `(0, 5500, 256)` to
`(365.592773, 5500, -1096.8027)`.  That leaves the ordinary shaft/cage region
without an A edge and is therefore a serious platform-displacement
constructor in the current abstraction.

The newest source/Clight audit sharply narrows the tempting **intact-top
self-bootstrap** subcase.  The C source narrows `find_floor` coordinates to a
signed 16-bit type.  The generated Clight body and CompCert semantics now prove
that the concrete binary32 sample `(63488,1791,-1024)` becomes
`(-2048,1791,-1024)`, and the finite partition calculation places X and Z in
cells 6 and 7.  Authenticated US and JP retail disassembly now supplies the
same byte-identical coordinate conversion at `find_floor`: `trunc.w.s`,
`mfc1`, store-halfword, then signed load-halfword.  The Rocq theorem
`concrete_retail_cast_fragment_arithmetic` checks that instruction-fragment
result for all three concrete inputs.  This closes the target-code question
for these samples, not for arbitrary out-of-signed-32 conversions.
Warp hitboxes continue to use full binary32 object positions.  The parsed
source mesh has minimum home-relative world Y `1281`; the arithmetic platform
predicate then requires full Mario Y strictly above `1277`, while the upper
warp ends at Y `818`.  Under the explicit premise that the stock yaw transform
preserves MarioState Y, the floor query's 78-unit allowance cannot lift a
warp-altitude query to the top.
`one_coordinate_cannot_contact_warp_and_capture_live_top` and
`stock_yaw_only_top_cannot_seed_upper_warp_bridge` prove those arithmetic
statements.  The quantitative theorem
`upper_warp_to_live_top_query_requires_385_y_units` also proves that, for a
post-copy Y coordinate still in signed-16 range, any such phase split needs
at least 385 units of upward State displacement.  That is a lower bound on a
candidate reused-slot writer, not evidence that one exists.  The matrix and
surface-loader bodies are now internal generated functions.  Rocq links
parsed top face `(1,4,3)` to manually translated zero-yaw home vertices, then
evaluates a hand-mirrored CompCert binary32 transform formula, all three
hand-mirrored signed edge expressions
(`521730`, `0`, `1023`), and their strict-negative tests.  What is still
missing is generated-expression extraction and linked execution over live
object/surface memory, initial-angle/state refinement, dynamic-list ownership
and order, and proof that the actual `find_floor` traversal returns this
top-owned face.  The result removes the motivation for an enormous X/Z search
within the Y-preserving stock model; it is not yet a retail impossibility
theorem.

A pinned-source audit gives the stock or inactive-but-unreused top an even
wider horizontal margin: its pivot X stays in `[-2087,-2007]`, Z is `-1023`,
X/Z velocity is zero, and only yaw rotates.  A Mario object overlapping the
upper warp is then within about 228 horizontal units of the pivot, whereas
the concrete PU candidate is at least 65,495 units away.  Exact real yaw
rotation preserves that radius.  The project does not yet call this a Rocq
Float32 theorem because the generated sine table and matrix multiply/add
rounding still need a conservative coefficient-bound refinement.  The result
also says nothing about a reused slot whose replacement object installs a new
pivot, velocity, pitch, or roll.

That same-sample result does **not** close the broader stale/reused-slot case.
Direct inspection
of the pinned source shows that platform displacement
writes MarioState before collision, while collision still reads the old Mario
object.  Mario geometry then reads the displaced State, interaction can select
`ACT_DISAPPEARED`, the action snaps to the new floor, and the later copy/final
platform query read the displaced coordinate.  The admission-free theorem
`phase_split_countermodel_exists` checks this concrete two-sample model:

```text
collision MarioObject = (-2048,  768, -1024)
displaced MarioState  = (63488, 1791, -1024)
```

CompCert's exact signed-short cast maps X `63488` back to `-2048`.  Rocq checks
the parsed triangle index, its manually translated zero-yaw vertices, the
hand-mirrored transform and face-edge arithmetic, world Y `1791`, and the
numeric 78-unit floor-query condition.  It does not yet prove loaded
dynamic-surface ownership or actual `find_floor` selection.  The two-sample
model needs a Y change of `1023`; more generally, the proved floor-query bound
requires at least 385 upward units from an upper-warp overlap.  An X/Z-only
alias or any Y-preserving transform therefore cannot realize it.  Thus the
second chatbot is right
about the narrow “PU wrapping alone makes Mario overlap the warp/top” proposal:
object hitboxes do not wrap and the vertical intervals do not meet.  Its
broader same-frame dismissal is incomplete, however, because later geometry
and platform selection can observe displaced MarioState after collision read
the old Mario object.  That phase split is only a possible semantic shape, not
a reachable stale-slot Clight or ROM trace.

The Area-1-first audit now answers the next question more precisely.  A generic
three-dimensional raw payload really does exist in stock source.  Triangle
fragments spawned by breakable and exclamation boxes write nonzero pitch
angular velocity.  `area1_fragment_writer_source_checked` verifies those
source fields, and
`concrete_area1_fragment_displacement_is_route_sized_3d` evaluates one selected
payload using CompCert binary32 operations: it changes all three MarioState
coordinates, taking the selected old sample `(-2048,768,-1024)` to
approximately
`(-2350.8427734375,1878.6683349609375,-714.5823974609375)`.  The roughly
`1110.6683`-unit Y rise exceeds the 385-unit necessary lower bound, and the
three exact binary32 words are `[3306351996,1156240739,3291653446]`.  The
signed-short collision query is `(-2350,1878,-714)`.  For an
attacked breakable box, an object count above 210 suppresses the mist
allocation, so the first triangle
allocation becomes a concrete candidate for reuse of a just-freed slot.

That first-allocation example is not exhaustive and is not intended to be.
Deallocation pushes a slot onto the free-list head, while allocation pops the
head; `[top, box]` is only the shortest illustrative prefix.  The generic
source schedule has three stock angular-payload classes before platform apply:

1. the pyramid top's live/retained yaw payload;
2. breakable-box dirt-triangle pitch/yaw payloads; and
3. exclamation-box cartoon-triangle pitch payloads.

Each class admits different free-list depths.  The fragment classes also admit
the source's `20`, `10`, or `0` mist-allocation branches, and pool exhaustion
can substitute FIFO eviction for an ordinary free-list pop.  Coin-formation and
other zero-angular allocations shift depths without adding a fourth angular
class.  This is why proving one controller history for `[top, box]` would never
have established schedule exhaustiveness.

More precisely, let `A` be the number of earlier allocations in the frame,
`d` the watched slot's zero-based free-list depth, and
`m ∈ {20,10,0}` the source-selected mist count.  With `M`, `D`, `C`, and `T`
standing for mist, dirt-triangle, contents, and cartoon-triangle allocations,
the two fragment bursts have these words:

```text
large breakable:    M^m D^30 S
exclamation box:    C M^m T^20 S
```

Here `S` is a trailing zero-angular allocation.  The watched slot receives a
dirt payload exactly when `A + m <= d < A + m + 30`, and a cartoon payload
exactly when `A + 1 + m <= d < A + 1 + m + 20`.  A nearby coin formation may
add `k` zero-angular allocations for `0 <= k <= 5`; other zero-angular
allocations shift `A`.  If the free list empties, the allocator evicts the
oldest eligible unimportant object, replacing the depth condition with the
corresponding FIFO-rank condition.  These variants change which payload reaches
a slot, not the node-`0x1E` owner-null conclusion.

The arithmetic witness is reproducible rather than existential.  Rocq checks
the packed US and JP Area-1 macro records for all three wing-cap/exclamation
boxes and both no-coin breakable boxes, then selects the middle wing-cap box.
Its real action-4 object position is `(-3000,540,800)`; the fragment
initializer's 100-unit Y offset makes the transform pivot
`(-3000,640,800)`.  It also evaluates the stock 16-bit PRNG recurrence for the
seed-0 payload and checks the selected sine-table words in both generated
versions.  This proves that the chosen angular payload is compatible with the
source formulas.  It deliberately does not claim that seed 0, the required
object count, or the watched free-list head occur together; that concrete
lineage is no longer needed as a Layer-B route obligation because the generic
stock pre-apply result below rules out every bounded platform origin at the
warp collision sample.
The breakable-box "fragment can be first" case and the middle-wing-cap-box
numeric pivot are separate source-backed subcases; the proof does not combine
them into a fabricated execution.

The proof then checks both floor candidates at the short query.  The transformed
top face has signed edge values `[207669,313344,2763]` and binary32 plane
height `1483.603515625`.  A static face has signed edge values
`[2460,77749,76821]` and height `1280`.  Those are exact arithmetic facts, not
a proof that either face is live, owns the relevant list entry, wins the real
list traversal, or came from a reachable object-pool state.

That sounds like the missing writer, but `Area1PlatformExhaustiveness.v`
eliminates the bootstrap more generally than the original top-slot argument.
It defines and checks a finite inventory of fifteen modeled stock Area-1
dynamic-floor owners:
the pyramid top, three Tox Boxes, two large breakable boxes, five exclamation
boxes, the cannon lid, and three message panels.  Four newly imported generated
collision meshes—breakable-box, exclamation-box outline, cannon lid, and wooden
signpost—supply exact local bounds for the fixed owners.

At node `0x1E`, every non-top owner is excluded by its horizontal envelope.
The top overlaps horizontally but its lowest stock floor is at least Y `1281`,
which cannot satisfy the warp's Y interval and platform-query tolerance.
Static floors have a null object owner.  Therefore
`stock_upper_warp_final_query_clears_platform` proves that a completed stock
final query at the warp returns `None`.

The theorem then classifies every modeled pre-apply platform origin as a
completed final query, the US spawn clear, a retained pointer at one of the
three in-scope stock inbound Area-1 positions, or frozen carry from one of
those cases.  The retained case covers JP cross-area entry and US/JP same-area
`0x1F`/`0x20` warps.
Generated LevelScript receipts prove that the clean, non-credits inbound node
set is `0x0A`, `0x1F`, and `0x20`; node `0x1E` only exits Area 1, to Area 2
node `0x14`.
`stock_area1_upper_warp_preapply_platform_null` proves that every such case is
null when the old collision object overlaps node `0x1E`.  Consequently
`stock_upper_warp_has_no_platform_created_route_split` leaves **zero** stock
route-relevant schedules in that model, regardless of payload class, depth,
mist branch, FIFO behavior, or controller lineage.

The older top-specific explanation remains a useful sanity check:

1. At the end of a frame, `update_mario_platform` can save the pyramid-top
   pointer only if the copied Mario object is within four vertical units of a
   top-owned floor.  The proved bounds put that object above Y `1277`.
2. On the next frame, platform displacement may change MarioState, but object
   collision still reads the old Mario object from step 1.
3. Node-`0x1E` warp overlap requires that old object at or below Y `818`.
   Those requirements are incompatible.
4. If the top has deactivated, its slot is freed only after that frame's
   platform apply.  A fragment can reuse it only in a later terrain-update
   phase, after `clear_dynamic_surfaces` removed the old top surfaces.

The admission-free theorems
`captured_top_epoch_cannot_bootstrap_upper_warp_collision` and
`captured_top_epoch_cannot_realize_route_relevant_phase_split` formalize that
finite phase/epoch argument.  The newer owner theorem subsumes the
route-relevant conclusion for all stock owners in its source-bounded relation.
In software terms, Area 1 has real "replacement object mutates all three
coordinates" primitives, but none has a non-null platform producer at the
required old-object warp sample.

This is still not a retail counterexample or a whole-program impossibility
proof.  `Area1StockPreapplyProjectionSound` is a stated refinement premise, not
yet a construction from linked Clight memory.  The proof has not executed the
surface loaders and final floor selection over a live object pool or shown that
every retail pre-apply state projects into the fifteen-owner relation.
Moving/loading the warp onto the top, moving the top down to the warp,
collision-preserving cloning, or a direct post-query pointer/object writer must
either be shown to project into the excluded cases or handled separately.

Even one successful collision frame would be insufficient: node
`0x1E` uses an action countdown followed by a delayed warp.  The trigger frame
sets timer `20` transiently during Mario's object update.  After
`area_update_objects` returns, the same frame decrements it to `19`.  Object
updates precede each of the 20 normal-play decrements through `1 -> 0`; the next
two change-area frames run no object updates; then `warp_area` unloads/loads
before the first Area-2 object update.  JP pointer retention or recapture
through that interval remains `delayed_warp_top_lifetime_obligation`.  Its
phase-indexed trace tracks the action-argument prelude, stable timer values,
version/area state, allocation epochs sampled after terrain updates and before
each platform apply, object-update validity, and the pre-first-platform-apply
Area-2 boundary.  The separate
`us_spawn_clear_blocks_retained_epoch_before_first_apply` lemma proves the
state-level consequence of a successful US clear; deriving that clear effect
from Clight execution remains open.

`JPSlotLifetime.v` now makes the JP allocation boundary less vague.  It checks
that area terrain loads before SpawnInfo objects, follows the macro and
SpawnInfo allocation call chains, checks the free-list head push/pop assignment
shapes, and checks that the selected unload/deallocation bodies do not directly
mention `rawData`.  It also confirms that allocation contains a loop, literal
`80`, and the indexed zero-write shape expected for clearing `rawData`.  Those
are path-insensitive syntax anchors: they prove neither all possible indirect
writes nor that 80 writes execute on the relevant path.  It also proves that
the packed Area-2
macro stream contains 50 complete records in both versions and proves the
finite LIFO recurrence: if the watched slot is released before a later bulk
release, it is reached exactly after that bulk prefix is allocated.

Those are source-shape and finite-list theorems, not the missing game trace.
Respawn filtering, SpawnInfo objects, terrain objects, first-update spawns, and
the exact free/allocation order determine whether the watched slot is still
inactive, is selected at the boundary, or was already reused.  The
Before/At/After allocation-count trichotomy is proved, but the concrete count
and exact payload loads at a reachable clean JP upper
`apply_mario_platform_displacement` state remain
`JPCleanUpperPlatformApplyMemoryRefinementObligation`, given an explicit
proved-first control-point witness.  Constructing that witness from the
Area-1 delayed warp and Area-2 source order remains a separate refinement.
For Area 1 proper, the newer audit classifies the stock pre-apply angular
payloads into top yaw, dirt triangles, and cartoon triangles.  It does not need
to decide which generic controller schedule realizes a fragment because all
bounded stock platform origins are null at the old-object warp sample.  The
separate JP destination-area pointer/payload census above remains open.

Moving/loading the warp onto the top, moving the top down to the already-loaded
warp, collision-preserving cloning, and direct post-query writers remain
separate unresolved constructions.  The full audit and theorem boundary are in
[`docs/pyramid-top-pu.md`](docs/pyramid-top-pu.md).

`UpperWarpTopCoincidenceMechanism`,
`UpperWarpTopPreludeCaptureEvidence`,
`UpperWarpTopPreludeToCleanEntryBridge`, unload-retention/reuse evidence, and
`UpperWarpStaleTopConditionalPathEvidence` name the older same-sample
conditional path.  They do not encode the new State/Object phase split.  A
replacement Clight evidence record must carry the collision-object,
geometry-State, post-copy object, final platform-query, and delayed-warp
lifetime samples.  A source-backed clean-entry theorem must either construct
that evidence or prove every family unreachable; it must not simply decree the
JP platform pointer null or safe.

The mechanism was also tested in the authentic JP executable with the exact
top-derived raw payload installed once in a reused slot at the modeled Area-2
boundary.  With
buttons always zero and the stick held straight for 60 frames, the first
platform update moved Mario to approximately
`(365.592773, 5496, -1096.802734)`.  Mario later fell through the upper-trigger
hitbox, whose controller count changed from zero to one.  The trace contained
zero `A_BUTTON_DOWN` and zero `A_BUTTON_PRESSED` frames.  No Act 3 overlap
occurred, and the Act 6 controller remained at one of five, so the Act 6 star
was not spawned; the probe did not directly read save bits.
Preparing the payload only before the Area-1 transition instead left a
different reused slot and a null platform pointer at Area-2 entry, so the
displacement and trigger contact did not occur.

This trace is a concrete counterexample to “every bypass constructor is
unreachable from the current state-only clean boundary.”  It is not a
counterexample to the retail theorem, because the one-time fixture supplies
the Area-2 boundary pointer/payload state whose stock controller prehistory has
not yet been constructed.  The exact RAM fields and frame trace are recorded in
[`docs/model-counterexample.md`](docs/model-counterexample.md).

### What the route theorem does not establish

The route contract is a formal transcription of the supplied strategy
argument, not yet a derived projection of the retail executable.  The new
evidence structures make the required projection checkable, but their
coverage and the entrance cuts are still unproved:

- extract the collision arrays into exact surface identifiers and prove the
  source/target connected-component cuts;
- prove every first crossing in a linked US/JP execution produces one of the
  evidence-bearing writer classes;
- prove the six surviving classes impossible from a source-backed clean entry,
  or else produce an exact reachable counterexample trace; and
- after either cut, the transcript's remaining no-A strategies work under the
  actual Float32 movement, collision, object, and version semantics.

Completed target traces must carry a `RealizedRouteTrace`: a synchronized
abstract `CertifiedExecution` whose Act 3 and upper-trigger observations are
backed by collection and trigger-consumption events at the same frame index.
That prevents downstream access from being certified by appending a free target
label.  `CertifiedExecution` is still the handwritten event model, so this is
not a replacement for the missing Clight refinement.

Likewise, `SpawningDisplacementEscape` is currently a route-observation tag.
The new stale-top evidence interface records the predecessor, unload,
retention/reuse, and cut crossing separately, but no theorem constructs all of
those records from retail controller input.

The transcript's rollout measurements--six units short in the observed setup
and a hypothetical seven-unit lift escaping--are candidate geometric facts, not
premises of the current theorem.  They need a checked state/mesh calculation
before they can support elevator closure.

Consequently, finding an authentic no-A crossing of either entrance-specific
collision cut would invalidate that lower-bound case.  If the downstream
continuation claim is also validated, the witness would provide the missing
capability for a zero-A route to each relevant region in separate executions.
The separation matters because collecting a star normally exits the course;
the claim is not that both stars are collected in one run.  The conditional
stale pyramid-top calculations are evidence about one such mechanism.  The
Y-preserving stock-yaw arithmetic case is excluded; its execution refinement
is open.  Area 1 supplies three stock pre-apply angular-payload classes, but
the source-bounded owner/provenance theorem leaves none with a non-null platform
at the node-`0x1E` collision sample.  A generic fragment controller/free-list
lineage is therefore no longer a Layer-B obligation.  The linked-Clight
projection of that theorem, constructions outside its bounded owner relation,
and delayed-lifetime questions remain open.

The full alternative-route inventory and its present proof boundary are
spelled out in
[`docs/route-exhaustiveness.md`](docs/route-exhaustiveness.md).

## Why reaching those regions is relevant

The collection/provenance layer treats the save file like a protected data
sink and asks which execution events are authorized to change it.

For Act 3, a newly set bit requires a collection event involving an active
star-or-key object with index `2`, the static pyramid-star origin, and a
registered Mario/star collision in the Act 3 interaction region.

For Act 6, a newly set bit requires an active star-or-key object with index
`5`, originating from the designated hidden-star controller.  Its parent
reference, home position, and collection hitbox are fixed in the abstract
provenance invariant; its current position is fixed only at spawn because the
spawn animation moves it.  Spawning it requires all five hidden-star triggers
to have been consumed.  Consumption of the upper trigger requires the
designated macro object, its exact trigger hitbox, and a registered
Mario/trigger collision in the relevant collision phase.  The consumed
trigger's macro state is then set and no active same-kind trigger remains.
The 100-coin star uses index `6`, so it cannot directly set either target bit
even though it may be useful as a movement resource.

An executable finite source inventory separately lists all seven normal SSL
star sources.  It proves that indices `0`, `1`, `3`, `4`, and `6` cannot alias
target indices `2` or `5`.  Its first-writer classifier has three exhaustive
causes: the matching normal star interaction, an incoherent backup reload, or
an explicit corruption/unmodeled writer.  Starting from coherent active and
backup target bits and allowing no anomaly writer rules out the latter two.
This closes the logical save-reload loophole in the finite model, but a
Clight-to-writer-inventory theorem is still needed before it becomes a
whole-program result.

These statements are proved by inversion over `CertifiedExecution`.  That is
useful, but it is not yet a whole-program Clight proof: the event constructors
already require the provenance, overlap, bit-update, and trigger facts.  A
future refinement must derive those constructor premises from actual Clight
steps.

Combining the intended layers gives this proof plan:

```text
new target bit
    => authorized target collection event                 (collection layer)
    => Act 3 collision or upper-trigger collision          (provenance reduction)
    => matching target-region route cut                    (PROVED under route/event alignment)
    => first entrance collision-support cut crossing       (OPEN: Clight/mesh coverage)
    => every crossing writer requires an A edge            (OPEN: six writer families)
    => at least one edge-triggered A press                 (OPEN: gate geometry)
```

The first two arrows are proved inside the abstract certified event model.
The target-region arrow is now proved by the route/event alignment carried by
`ClightRouteTraceProjection`; constructing that alignment from a retail
execution is part of the open whole-program refinement.  `ModelGapAudit.v`
shows why the old abstract endpoint relation cannot stand in for that
execution.  `FirstTargetRefinement.v` defines the entrance-cut and writer
arrows as evidence-bearing obligations and proves several finite eliminations,
but it does not establish mesh connectivity, total writer coverage, or the six
remaining exclusions.  No global US/JP bypass exclusion is proved.  The
reverse direction--a cut bypass continuing to a target--also remains
conditional on separate downstream and abstract-execution certificates.

## What the generated source already confirms

The current project regenerates CompCert Clight ASTs for both target versions
from the pinned decomp revision: 30 translation units per version, 60 modules
in total.  Direct inspection of that pinned C source shows:

- the controller input calculation distinguishes `buttonPressed` from
  `buttonDown`;
- the pole action bodies test `INPUT_A_PRESSED` on paths selecting pole-jump
  actions;
- the pole source also contains the Z-triggered soft-bonk/drop path,
  so "the source mentions A" alone is not a pole-impossibility proof;
- object processing applies Mario's platform displacement before detecting
  object collisions;
- platform displacement writes MarioState, object collision reads the old
  Mario object, and Mario's later behavior copies State back to the object;
- `find_floor` narrows all three coordinates to a signed 16-bit C type, while
  object hitboxes use full binary32 coordinates; the concrete CompCert cast is
  proved, and authenticated US/JP disassembly plus Rocq fragment arithmetic
  confirms the same three concrete retail results;
- `math_util.c` and `surface_load.c` are now imported, so the matrix and
  transformed dynamic-surface helper bodies are no longer unconstrained
  externals in the linked-program obligation;
- the Area-1 macro wrapper exposes three wing-cap/exclamation-box records and
  two no-coin breakable-box records at their exact source coordinates;
- the generated fragment helpers contain the nonzero pitch/yaw fields, the
  object-count `210` mist-suppression threshold, and the fresh-allocation
  80-word clearing shapes used by the Area-1 candidate;
- the stock source audit classifies pre-apply angular payloads as pyramid-top
  yaw, dirt triangles, or cartoon triangles, with parametric free-list depth,
  mist-count, zero-allocation, and FIFO-eviction variants;
- the normal warp interaction, geometry refresh, disappeared-action floor
  snap, state/object copy, and final platform query occur in the phase order
  used by the new PU countermodel;
- node `0x1E` is delayed: object updates run before each of the 20 normal-play
  timer decrements, two change-area frames omit object updates, and the
  following normal frame loads Area 2 before its first object update;
- the US spawn path directly clears `gMarioPlatform`, while the JP path does
  not contain that direct clear call; and
- the no-spin airborne entry handler calls the launch helper with single-
  precision zero, and that helper calls forward-velocity setup and
  `perform_air_step`;
- target collection, hidden-star, area transition, object lifecycle, and
  collision functions are present in the generated source set.

The checked Rocq AST theorems are narrower: they establish selected operator,
identifier, constant, direct-call, and direct-callee-order shapes.  In
particular, the pole AST theorem checks occurrences of the relevant input and
action constants; it does not prove branch control dependence or that those
branches exhaust every way past the pole.  The new raw-slot recognizers are
also base-insensitive, so the phase pipeline is a direct-source inspection
backed by separate syntax anchors, not an AST-level dataflow theorem.

The generated collision wrapper contains the area 1/2/3 static arrays and the
pyramid-top, Tox Box, Grindel, Spindel, moving-wall, elevator, Eyerok,
breakable-box, exclamation-box outline, cannon-lid, and wooden-signpost arrays.
Rocq proves their checked initializer word counts and that the route-relevant
US and JP initializers are identical.  The new Area-1 owner audit also proves
the exact local X/Y/Z bounds of the last four meshes.  The pyramid audit checks
all 39 top words exactly and parses its five vertices and six triangle indices.
For the selected top face, it links those parsed words to manually translated
zero-yaw home vertices and evaluates signed-short casts, partition cells, and
hand-mirrored binary32 transform and edge arithmetic.  Generated helper bodies
are present, but the arithmetic is not extracted from or executed through those
bodies.  The general area arrays are not yet parsed into surfaces, and no
linked live-surface construction, actual `find_floor` list selection, or
surface connected-component theorem is proved.

The area script also contains a conditional
`SSL_SPAWNING_DISPLACEMENT_TAS_HACK` branch used for experiments.  The target
generation leaves that branch disabled.  Its hacked position/platform setup is
therefore not evidence about either target ROM.

These are syntax and source-shape checks.  They do not prove branch dominance,
loop execution, exact memory effects, route coverage, or reachability.

## How the six earlier projects support the argument

The archived projects are treated like previous design investigations: they
identify invariants, failure modes, and candidate lemmas.  The current project
does not import an old generated AST or assume an old capstone.  Selected facts
are regenerated or reproved in the current namespace.

| Prior project | Evidence in favor of the route argument | What it still does not prove |
| --- | --- | --- |
| `ssl-spawning-displacement-proof` | Identifies the JP stale-platform mechanism, retained inactive/reused slot cases, and the exact spinning-top payload that can move upper-entry Mario outside the shaft in the present abstraction.  Its State/Object timing observations motivated the newly rechecked phase-split source facts and countermodel.  The current project now classifies the stock Area-1 angular-payload families and proves every bounded stock pre-apply platform origin null at node `0x1E`, not merely the earlier `[top, box]` case. | A linked Clight proof that the finite owner/origin relation covers every retail Area-1 pre-apply state, any construction outside that relation, survival or recapture through the delayed warp, or a retail continuation to a target region.  The archive's hand-selected unowned-floor observation is not a proof of stock provenance. |
| `ssl-pyramid-item-proof` | Shows the proof shape needed for area unload/reload, object deletion, free-list slot reuse, and allocation identity.  This supports the claim that outside objects do not simply survive as substitute target stars. | A linked execution proof of the unload loop, target-star provenance, or either route gate. |
| `ssl-parallel-universe` | Correctly models continuously held A as zero new edges and warns that a bounded-position proof must cover every movement writer.  It tests a possible way of bypassing ordinary geometry. | Complete movement-writer coverage or non-reachability of either target region. |
| `pole-bypass` | Proves a one-A lower bound for a restricted normalized pole model and isolates `bypass_model_complete` as the missing global premise.  This is evidence about the normal second-pole route. | Every approach state, pole avoidance route, object/platform interaction, Float32 collision phase, JP execution, or the actual target-side support cut.  Its pole-height abstraction is not route-exhaustive. |
| `eyerok-manipulation` | Provides negative evidence against using the area-3 boss and platform state to manufacture unbounded height, and records the US/JP platform-state split. | A complete exclusion of every area-2/area-3 high-entry technique or a route to either target. |
| `demo-warp` | Demonstrates why memory provenance matters: a byte store can alter Mario state under an aliasing premise, while normal initialization can rule out that alias in a narrower model. | Any direct pyramid route result, or a current-revision whole-program memory proof. |

Taken together, the projects make the two-gate hypothesis more credible and
make its missing completeness assumptions much more precise.  They do not
compose into a proof of the final claim.

## Exact remaining obligations

The ultimate theorem needs all of the following:

1. Construct a linked US program and a linked JP program from the generated
   translation units, including specifications for external calls.
2. Project Clight memory and traces to `GameState`, frame inputs, lifecycle
   events, and complete collision observations.
3. Prove that the projection produces `CertifiedExecution`, including object
   provenance, behavior-parameter decoding, deletion/reuse, macro respawn,
   unload/reload, instant-warp, and collision-list timing.
4. Parse the generated collision arrays into surfaces and prove exact
   source/target support and open-cell cuts for both entrances.  The selected
   pyramid-top home face arithmetic is checked; its live construction, list
   ownership/order, actual `find_floor` selection, and the general support graph
   remain open.
5. Prove first-crossing writer coverage and eliminate ordinary motion,
   platform displacement, object/moving geometry, clip/tunnel, general
   coordinate alias/out-of-bounds, and lifecycle/entry displacement.
6. For JP platform displacement, derive every admissible raw pointer from an
   actual predecessor, including inactive/reused slot epochs and the
   upper-warp/spinning-top coincidence families.  The source-level LIFO shape,
   50 packed macro records, and Before/At/After count cases are proved.  The
   Area-1 audit classifies the three stock pre-apply angular-payload classes and
   proves that every source-bounded stock platform origin is null at node
   `0x1E`; generic fragment controller/free-list lineage is therefore no longer
   a Layer-B obligation.  What remains is the linked-Clight proof that every
   retail Area-1 pre-apply state projects into that owner/origin relation, plus
   live surface construction/list selection, alternative constructions outside
   the bounded relation, the exact JP destination-area allocation state, and
   delayed-warp retention/recapture.  The concrete candidate cast is verified
   for both retail versions.
7. Validate the claimed no-A downstream paths from each successful bypass to
   the Act 3 region and all five Act 6 triggers.

Until these obligations are discharged,
`conditional_evidence_bearing_clight_run_impossibility` and
`conditional_target_clight_run_impossibility` are correctly named
*conditional* and the retail-game theorem remains open.

## How to inspect and build the proof

The most useful entry points are:

- `proofs/TranscriptRouteModel.v`: route-observation contract and gate/bypass
  lemmas;
- `proofs/InputSemantics.v`: edge-triggered A definition;
- `proofs/SourceExhaustiveness.v`: finite normal-star and target-save writer
  inventory;
- `proofs/StarCollection.v` and `proofs/HiddenStar.v`: collection reduction;
- `proofs/ClightFacts.v`: checked generated-AST source facts;
- `proofs/ClightRefinement.v`: the explicit missing semantic bridge;
- `proofs/CollisionMeshFacts.v`: generated collision-array counts and
  cross-version equality, the exact 39-word pyramid-top initializer, and exact
  local bounds for the breakable-box, exclamation-box-outline, cannon-lid, and
  wooden-signpost meshes;
- `proofs/PyramidTopSurface.v`: generated matrix/surface bodies and checked
  concrete Clight/retail-fragment cast values, parsed-to-manual zero-yaw
  face link, hand-mirrored cell/transform/edge arithmetic, and guarded
  dynamic-floor assignment source shape;
- `proofs/PyramidTopPU.v`: the modeled same-sample contradiction, conditional
  Y-preserving stock-yaw arithmetic exclusion lemmas, the phase-separated
  coordinate countermodel, and delayed-lifetime obligation;
- `proofs/Area1PhaseSplit.v`: checked triangle-fragment payload fields, exact
  binary32 three-dimensional displacement, and the ordinary captured-top epoch
  bootstrap exclusion for node `0x1E`;
- `proofs/Area1SurfaceWitness.v`: exact signed-short query, parsed top-face and
  static-face edge tests, binary32 plane height, 78-unit floor-buffer test, and
  candidate-height comparison, without claiming live list selection;
- `proofs/Area1PlatformExhaustiveness.v`: the fifteen-owner stock Area-1
  inventory, source-bounded pre-apply provenance cases, node-`0x1E` null
  platform result, and checked three-dimensional fragment capability;
- `proofs/JPSlotLifetime.v`: the JP allocation/free-list source boundary,
  50-record macro count, finite LIFO recurrence, and exact open first-apply
  memory obligation;
- `proofs/FirstTargetRefinement.v`: indexed Clight-frame evidence, collision
  cuts, concrete bypass classes, and conditional stale-top path;
- `proofs/ModelGapAudit.v`: executable countermodels to the old abstraction
  boundary;
- `proofs/LowerEntrance.v` and `proofs/UpperEntrance.v`: open Layer B
  obligations;
- `proofs/MainTheorem.v`: proved reduction and conditional capstone; and
- `docs/archived-proof-evidence.md`: detailed audit of every prior project;
  and
- `docs/pyramid-top-pu.md`: source audit and exact boundary of the newest
  pyramid-top PU result;
- `docs/pyramid-top-surface-refinement.md`: exact checked surface kernel versus
  remaining live-memory refinement;
- `docs/retail-find-floor-cast.md`: authenticated US/JP function offsets,
  instruction receipt, hashes, and reproduction commands; and
- `docs/jp-slot-lifetime.md`: exact JP slot-lifetime facts and unresolved
  allocation trace.

Build and run all project checks with:

```sh
source pipeline/env.sh
make clean
make check
make verify-generated
```

The check rejects `Admitted`/`admit` and audits the assumptions of the named
capstone theorems.  A successful build means the stated conditional and model
theorems type-check; it does not convert open bridge obligations into proved
facts.
