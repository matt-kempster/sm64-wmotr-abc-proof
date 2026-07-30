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

> **Newest Ink fallback result:** the engine can observe three different Mario
> positions during one frame.  Object collision reads the old raw Object
> position; ordinary geometry reads MarioState; and, if that State has no
> floor, the null-floor graphical fallback (often described informally as the
> OOB fallback) copies the graphical position into MarioState and retries.  It
> is not specific to the wall-push routine; a wall push is only one candidate
> producer of the floorless State.  This makes Ink's scheduling idea
> conditionally real: an Object at
> Area-1 warp node `0x1E`, a floorless State, and Graphics over a loaded
> pyramid-top-owned surface can cache the warp and later copy the top-side
> coordinates into MarioState in the same update.
>
> `InkFallback.v` proves local and Parallel-Universe conditional pipeline
> coordinate witnesses for that schedule.  It checks nearby generated Area-1
> mesh receipts at State `(-2200,768,-1024)`, excludes all fifteen modeled
> stock dynamic owners for that first query, and proves that a generic
> top-height retry with Graphics Y in signed-16 range needs at least 385 units
> of upward Graphics/Object
> separation.  Either exact proposed prestate needs at least `973` units.  It
> also
> proves that any sequence of State-only ordinary, platform, or PU writes
> preserves Object and Graphics, so such writes cannot create their split from
> synchronized input.  The disappeared-action snap is followed by an
> unconditional quicksand sink; the projected Graphics-position write cannot
> change the Object coordinate later copied from State, while the conditional
> `gfx.throwMatrix` write still needs a memory-provenance proof.  The first
> sink specification was false: an unrestricted execution could pass the
> first return and call the function again, and a linear interval check missed
> a concrete 32-bit pointer-wrap alias.  The repaired statement stops at the
> first matching return and compares the individual modular memory cells, but
> remains unproved.  After the
> copy, later object lists and deactivated-object unloading occur before the
> final platform query.  That order admits a separate explosion-frame
> inactive-slot candidate, but does not yet prove free-list membership or
> retained concrete-surface identity.  The two closed coordinate witnesses
> use the zero-yaw home top and floor Y `1791`; they do not instantiate the
> later translated/rotated explosion pose.  The source audit uses
> `45` as the dry route-specific visual-offset target, while `208` is a
> deliberately conservative modeled writer relation.  Both are below the
> required gap, but neither covers retail until reachable writer/action state
> closure is proved.
>
> The retry has a decisive branch.  If the second floor query is also `NULL`,
> `update_mario_geometry_inputs` requests the death warp before cached object
> interactions are processed.  The interaction selects `ACT_DISAPPEARED`; it
> requests the object warp later.  The delayed-warp state is a first-writer
> latch: the fatal request is stored only if that latch is empty, and an
> uncleared stored fatal request blocks the later request.  At zero lives,
> death is rewritten to game-over, which is still fatal and nonzero.  Generated
> US/JP AST checks establish the guarded call shape, guarded-write latch shape,
> and lexical call order.  The exact disappeared count and zero-lives rewrite
> are still source-audit facts rather than AST-recognizer results.  A closed
> handwritten transition model evaluates the three abstract cases:
>
> | State query | Graphics retry | Source-ordered consequence |
> | --- | --- | --- |
> | floor | not run | no fallback and no fatal request; cached warp may select `ACT_DISAPPEARED` |
> | `NULL` | floor | Graphics is copied to State, no fatal request; cached warp may select `ACT_DISAPPEARED` |
> | `NULL` | `NULL` | death/game-over is requested before interaction and is stored if the latch is empty; the cached warp may still select `ACT_DISAPPEARED`, but action dispatch is skipped |
>
> “Failsafe to Mario’s position” is therefore not a separate first branch:
> the first branch simply keeps the post-wall State sample.  Also, “trigger
> the warp” initially means selecting `ACT_DISAPPEARED` with a two-tick
> argument, not changing areas immediately.  The successful Graphics retry
> performs only the first tick.  A second floor-supported Mario update is
> required to request node `0x1E`; on a second both-queries-null frame, an
> initially empty latch stores the fatal operation before the skipped action
> could issue that request.  The clean-entry model now separately records that
> the generic delayed-warp cell is empty, instead of conflating that condition
> with “no delayed star exit.”  Deriving an empty latch at this exact live
> Area-1 call boundary remains part of the Clight scheduler refinement.
>
> Thadortin is right about the three control-flow cases, but “failsafe” is
> wrong for the first case, and “trigger the warp” initially means action
> selection.  Only the non-`NULL` Graphics-retry branch remains usable.  The
> handwritten latch/countdown model excludes the both-queries-null schedule
> under the source-audited order plus empty-and-persistent-latch premises;
> linked retail Clight refinement is not yet proved.  The surviving Ink case
> specifically requires a non-null retry floor and a second supported action
> tick.  Selection of a live top-owned floor remains unproved.
>
> **Newest wall/floor diagnostic:** Rocq now parses the actual generated US/JP
> Area-1 initializers, obtains all 574 vertices and 962 triangle records, and
> computes the exact 17-wall/26-floor static inventories for cell `(5,7)`.
> At `q = (-2200,768,-1024)`, a pure evaluator computes all four static-wall
> and both static-floor decision lists as all-rejection, then packages
> zero-push and `Area1FloorNull`/`-11000.0f` records.  The record is not an
> independently executed collision traversal.  Its computed trace
> derives 12 first-edge failures, 8 second-edge failures, 5 third-edge
> failures, and one height-buffer failure.  Rocq also checks signed-32
> intermediate bounds and exact CompCert-binary32 planes/offsets for the
> decisive axis-aligned faces.  A separate theorem states the meaningful
> executable premises directly: all four wall decision lists and both floor
> decision lists consist entirely of computed rejections.
> The sole X/Z-accepting face is the Y=1280 roof and is 434 units too high for
> the query allowance.
> At `x=-2199`, the west-wall offset is exactly `-50` and pushes to
> `x=-2099`, where support exists; at `x=-2200`, offset `-51` is rejected.
> Thus the wall push does not create this miss.
>
> An exhaustive integer scan of the radius-187 warp-contact disk at Y=768
> found no supported point pushed to `NULL` and no wall-hit point ending at
> `NULL`.  Every post-wall-null point had no wall hit.  That scan remains an
> external audit result rather than a committed formal verifier.
> `Area1FirstNull.v` now derives the exact static diagnostic.  It does **not**
> yet prove the pure evaluator refines the live Clight allocator/list
> traversal, exclude extra dynamic entries, justify every cast/pointer effect,
> prove a clean trajectory reaches `q`, or prove a continuous-binary32
> neighborhood theorem.  In particular, `q` lies under
> the Y=1280 roof, so ordinary falling from above lands on the roof instead of
> reaching the sample.
>
> **Shell/wall writer result:** the pinned source puts each shell step before
> the `+42`/`+45` literal.  A handwritten two-step normal-frame transition
> threads the first result through an arbitrary State-only interframe write,
> then explicitly reanchors Object and Graphics from current State; under
> that model definition the second 42/45 gap replaces rather than adds to the
> first.  This is not yet a Clight transition theorem.  The ground
> dispatcher calls the quicksand update first; its riding-shell branch clears
> quicksand depth.  The airborne common-cancel path likewise clears depth
> before dispatching the shell-air body.  Those audited continuing source
> paths would block retained negative depth from amplifying the normal `+45`
> and `+42` writes.  Generated-AST receipts check the zero assignments and
> call ordering; linked branch/dataflow execution remains open.  The audited wall
> loop changes collision-record X/Z; its wrapper copies an unchanged Y back to
> the caller.  The shell step uses a local `nextPos`, while the interaction
> push uses State Y plus local X/Z, so neither directly passes Graphics.  A wall
> can still enable the fallback schedule by changing X/Z or making the later
> floor lookup miss; it is not a positive Graphics-Y writer in the inspected
> source.  Exact call arguments, pointer disjointness, every caller, and linked
> execution remain open.  An abstract State-only writer
> therefore preserves rather than enlarges an existing gap.  When cached warp
> contact selects
> `ACT_DISAPPEARED`, the shell action is not dispatched in that frame, so wall
> contact cannot combine with a same-frame shell addition.  These are
> source-shape and normal-form results, not yet a binary32 Clight proof with
> pointer non-aliasing and every caller covered.
>
> An unrestricted binary32 endpoint difference can be about `0.000061` larger
> than the `42.0f`/`45.0f` source operand when an addition crosses a binade;
> Rocq now checks concrete witnesses.  Those witnesses establish no general
> upper bound.  The remaining route-specific work is split into a pending
> exact-arithmetic lemma for Y in `608..818` and a separate live US/JP
> refinement that must derive that range.  The ground tilt helper also performs potentially
> problematic float-to-integer casts before `+45`; a total proof needs a
> reachable speed/yaw bound or compiled-MIPS semantics.  That issue can stop
> the source-level path but cannot increase its Graphics-Y add.
>
> Direct source inspection finds that the interaction table puts warp before
> Koopa shell and that the loop stops after a successful handler.  Thus the
> inspected source path would select the nonfading warp without processing a
> simultaneous shell collision.  Generated receipts check only the table
> subsequence and named bodies; indirect-call/break execution remains open.  The generic
> behavior-interpreter Graphics synchronizer is flag-bit-0 gated, while
> `bhvMario` ORs bit 8 (`0x100`) and does not itself introduce bit 0.  Retail
> allocation clears the raw words, but the project has not linked that fact
> through slot reuse and every live mutation.  An over-permissive state with
> bit 0 and a positive `oGraphYOffset` can overwrite Graphics and is therefore
> a formal-model counterexample to closure, not evidence of a retail route. The
> retail-resident debug callback also contains a guarded spawn path.  Proving
> live flag initialization/mutations, the debug guard false, and complete
> writer/action/spawn closure remains open.
>
> **Entry-memory result:** `EntryMemory.v` now proves the generated 32-bit
> US/JP composite layouts, defines a concrete `Mem.load` postcondition, and
> proves a narrower projection from that postcondition.  The important offsets
> are:
>
> | Structure | Field | Byte offset |
> | --- | --- | ---: |
> | `MarioState` (size 200) | action/state/timer/argument | `12 / 24 / 26 / 28` |
> | `MarioState` | `framesSinceA/B` | `40 / 41` |
> | `MarioState` | position / velocity / forward velocity | `60 / 72 / 84` |
> | `MarioState` | floor / floor height | `104 / 112` |
> | `MarioState` | Mario-object / controller pointers | `136 / 156` |
> | `MarioState` | quicksand depth | `192` |
> | `Object` (size 608) | Graphics position / throw matrix | `32 / 80` |
> | `Object` | raw `oPosX/Y/Z` | `160 / 164 / 168` |
> | `Controller` (size 28) | down / pressed | `16 / 18` |
>
> Given the concrete post-entry loads, Rocq proves State, raw Object, and
> Graphics carry the same three binary32 coordinates; action is `6450`
> (`ACT_SPAWN_NO_SPIN_AIRBORNE`); action state, timer, argument, velocities,
> forward velocity, and quicksand depth are positive zero; both
> `framesSinceA/B` are 255; and the throw-matrix pointer is null.  This is a
> real memory-layout/projection theorem, but it is conditional on those loads.
> The project has **not** yet executed `init_mario_after_warp` to derive them
> from a clean retail predecessor.  Exact advertised spawn coordinates also
> require proving the initial floor does not raise Mario.
>
> The controller boundary was corrected at the same time.  Controller input is
> read before the area warp, so the residual entry frame already has a live
> `buttonPressed`.  `CleanPyramidEntry` now records current `buttonDown`, the
> actual previous-down sample, and the resulting live `buttonPressed`, and
> requires the source edge formula relating them.  It no longer manufactures
> “no edge” by equating current and previous samples.  The separate no-A
> execution hypothesis must rule out bit 15 of that live pressed value.
>
> This is not a reachable game trace.  The project has not proved that a clean
> execution creates the Object/State/Graphics prestate, that the first live
> floor query returns `NULL`, that the retry selects a loaded top-owned
> surface, or that the post-copy lifecycle preserves the needed Object and
> owner epoch.  The current lifecycle proposition is not a sound proof target:
> its program link and memory projection are underconstrained, and importing
> `behavior_script.c` does not by itself construct the exact indirect call path; external effects and pointer-to-slot/epoch
> linkage are missing, and arbitrary binary32 samples include NaNs.  It must be
> replaced, not merely discharged.  No stock-reachable US/JP retail trace with
> a newly set target bit was found.
> The finite null-platform theorem applies only to pre-existing platform
> origins; it does not eliminate a graphical retry that captures the top
> afterward.  The focused audit is
> [`docs/notes/ink-fallback.md`](docs/notes/ink-fallback.md).

> **Newest first-crossing result:** `FirstCrossingWriterCoverage.v` repairs a
> second abstraction boundary.  The older
> `FirstTargetWriterCoverageObligation` is no longer used: it could name any
> projected event no later than the target without showing that the event
> crossed a route cut.  An unrestricted `CollisionSupportCut` was also only a
> data record; `an_unvalidated_cut_can_place_one_state_on_both_sides` gives an
> admission-free witness whose source and target sides overlap.
>
> The replacement scopes construction and exclusions to a selected
> `TargetCollisionCutFamily` parameter indexed by version, entrance, and
> target.  `EntranceCollisionCutEntryContract` puts the clean entry on the
> source side and excludes the entrance snapshot from the target side.
> `FirstValidatedCutCrossingAt` then carries the actual source-to-target Clight
> frame, its non-target event, endpoint-local side separation, a matching
> target-event segment later in the same Clight run, and ordered evidence for
> every earlier frame index.  The local separation avoids
> assuming that arbitrary, independently populated `GameState` fields describe
> a coherent collision query.
> `validated_pre_target_first_crossing_writer_coverage` proves, without
> admissions, that such a crossing has one of five projected abstract-event
> labels--ordinary physics, platform displacement, object impulse, collision
> clip, or area reload--or instead changes floor/platform support selection
> while keeping Mario's position fixed.  Ordinary physics is further split by
> whether its
> endpoint is in the local coordinate-cast domain.  Thus the corrected
> no-A interface has six movement/domain exclusions plus a separate seventh
> support-selection exclusion.  Coordinate alias/out-of-bounds is an endpoint
> domain of ordinary physics, not an independent store.
>
> This is abstract writer coverage, not the retail route theorem.  Constructing
> the validated first crossing from linked US/JP execution, connecting the
> target collision to the validated target side, and representing crossings
> that occur within the same frame or subframe as the target collision all
> remain open.  So do all six linked-retail movement/domain exclusions and the
> separate support-selection exclusion.

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
> frozen-carry cases all reduce to null.  Thus no bounded stock schedule whose
> split starts from a pre-existing platform pointer can create the older
> State/Object platform-displacement split.  This does not exclude Ink's
> null-preapply three-view graphical retry.
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
2. Fix the entrance/target-specific cut family, prove its entry contract, and
   prove source/target separation at the actual projected crossing endpoint.
3. Recover the minimal pre-target source-to-target crossing from an actual
   Clight segment.
4. Classify the cause as local ordinary physics, an ordinary-physics endpoint
   outside the local cast domain, platform displacement, object impulse,
   collision clip, area reload, or same-position floor/platform support
   selection.
5. Prove the applicable cause cannot cross the entrance-specific cut without
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
modeled 65536-unit coordinate alias.

The newer first-crossing module proves a different, corrected coverage result.
Its five position-writer constructors are ordinary physics, platform
displacement, object impulse, collision clip, and area reload.  If the
position does not change, a valid source-to-target crossing must instead
change the selected floor or platform.  It partitions ordinary-physics
endpoints into local-cast and coordinate-alias/out-of-bounds domains; the
latter is not a sixth function that writes Mario's coordinates.  Certified
ordinary administrative events preserve Mario's kinematics.  A changed reload
must return to the entry snapshot and is excluded from a validated target cut
when the post-reload state shares the initial version, entrance, and snapshot.
The bounded Area-1 upper-warp platform bootstrap is also closed.  These
results do not yet eliminate the six movement/domain cases or the seventh
same-position support-selection case for linked retail executions.

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
not the unconditional retail theorem.  This older capstone still uses the
evidence-bearing bypass interface.  The corrected first-crossing theorem proves
coverage only after `FirstValidatedCutCrossingAt` has been constructed; the
linked-run construction, six movement/domain exclusions, and separate
support-selection exclusion are still required.

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

### Ordinary motion: what is proved and what is not

“No A press” is not “Mario cannot move.”  The ordinary-motion class includes
walking, momentum, gravity, falling, sliding, landing, pole actions, and normal
static floor/wall/ceiling response.  The generated source also exposes a less
obvious case: A may already be held at clean entry, and stationary or moving
punching can then select `ACT_JUMP_KICK` after a B press without a new A edge.
That is a real counterexample to the shortcut “no A edge implies no upward
motion.”

The current abstract event model cannot decide whether such motion reaches a
route cut.  A `MotionPhysicsFrame` still accepts an arbitrary endpoint, so its
label is comparable to a log record whose payload has not been validated
against the implementation.  Moreover, an earlier platform, object, clip, or
lifecycle event could prepare the action or velocity used by the later
ordinary frame.  The sound shape is therefore a preservation proof: define a
finite, source/mesh-backed safe envelope and prove that every writer class
preserves it until the first target-side crossing.

The new `OrdinaryMotion.v` module proves that explicit generic preservation
and target-exclusion obligations compose, and closes two upper-elevator
arithmetic kernels:

- jump kick starts with vertical velocity `20`, uses the non-Wing fallback
  gravity of `4`, and
  has at most `60` units of absolute ascent;
- while granting the full `10`-unit elevator descent benefit on every frame,
  jump kick rises at most `128` units relative to the elevator;
- a conservatively supplied rollout starts at `30` and rises at most `220`
  units relative to the elevator; and
- the generated elevator mesh has side vertices through local Y `256`, the
  dynamic-surface loader adds an upper-Y pad of `5`, and the lower wall query
  samples Mario at Y offset `30`, so an integer-translated wall is rejected
  vertically only when relative center Y is strictly greater than
  `256 + 5 - 30 = 231`.

Thus both modeled ascent chains remain below the wall-clearance threshold:
`128 < 231` and `220 < 231`, on the non-Wing 4-unit-gravity branch.  Their
generated US/JP action bodies call
`perform_air_step` with literal step argument zero, so these actions do not
request the ledge-grab check.  Exact US/JP mesh receipts also recover the
20 elevator vertices and the lower-route pole-base and upper-ring vertices.
`MainTheorem.v` packages this exact checked boundary, together with the
Wing-Cap arithmetic below, as the closed theorem
`current_ordinary_motion_evidence_boundary`; that theorem is not a retail
containment theorem.

Cap state is a necessary engineering precondition, not decorative state.
With a retained Wing Cap and held A, flutter gravity slows Mario's fall after
the rollout turns downward while the elevator continues descending.  The
formal arithmetic countermodel then reaches `228` relative units.  It refutes
reuse of the non-Wing `220` bound but remains below `231`, so it does not
establish vertical or horizontal clearance, a collision miss, or a clean
retail bypass.  Retail area-entry initialization resets special-cap state, but
the abstract `GameState` currently omits flags and cap timer, so the source
initialization effect must still be connected to the clean-entry projection.

This is not yet an unconditional elevator-containment proof.  It still needs
linked Clight execution of the action and gravity paths, live transformed-wall
ownership and list selection, bounds for every intermediate collision query,
normal collision rather than a clip/tunnel, cap initialization and
preservation, and closure of the reachable upper-entry action states.  The
lower route is less complete: Z can leave the second pole through
`ACT_SOFT_BONK`, so A is not literally the only pole exit.  The existing
normalized pole arithmetic blocks that restricted Z-exit model, but does not
cover every lower-entry ordinary trajectory.

There is also an earlier upper-entry phase that the ascent arithmetic does not
cover.  Mario's clean snapshot is at Y `5500`, above the elevator's initial
raw rim top at Y `5222`.  The generated no-spin-airborne action contains the
expected zero-forward-speed launch-helper and air-step calls, which supports a
vertical entry fall at the syntax level.  The proof still has to execute that
path, select the live elevator floor, and establish the post-landing state
before applying either ascent bound.

The precise result and remaining obligations are documented in
[`docs/notes/ordinary-motion.md`](docs/notes/ordinary-motion.md).  No retail ordinary-motion
trace reached either target region in this tranche, and the ultimate theorem
remains incomplete.

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
Direct inspection of the pinned source shows that platform displacement writes
MarioState before collision, while collision still reads the old Mario object.
The older admission-free theorem `phase_split_countermodel_exists` checks this
concrete two-sample model:

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
alias or any Y-preserving transform therefore cannot realize it.

Ink's graphical-fallback proposal exposes a third sample that the older model
omitted:

```text
collision MarioObject = (-2048,  768, -1024)
first-query State     = (-2200,  768, -1024)
fallback Graphics     = (-2048, 1791, -1024)
```

The relevant Object-to-Graphics Y gaps are:

| Case | Object Y | Graphics Y | Gap | Meaning |
| --- | ---: | ---: | ---: | --- |
| Synchronized entry | same | same | `0` | Intended starting relationship; linked-memory proof pending |
| Dry audited envelope | arbitrary | arbitrary | at most `45` | Route-specific source-audit target |
| Conservative modeled envelope | arbitrary | arbitrary | at most `208` | Preserved by covered abstract writers; retail coverage pending |
| Signed-range generic top-query threshold | at most `818` | at least `1203` | at least `385` | Necessary for a floor at least `1281`, using the 78-unit query allowance |
| Exact Ink prestate schema, worst warp-overlap Y | at most `818` | `1791` | at least `973` | Admission-free arithmetic theorem |
| Displayed witness above | `768` | `1791` | exactly `1023` | Coordinate witness only, not a reachable trace |

The interaction/action side has a separate displacement table:

| Producer | Immediate coordinate effect | Amount |
| --- | --- | --- |
| Successful Koopa-shell interaction | Manual source audit finds no direct Mario position write; it changes action/object references | `0` immediate coordinate write under well-formed non-aliasing state; linked call-segment proof pending |
| Failed Koopa-shell contact | Pushes State X/Z toward a radial target before wall correction | Stock scale-1 target radius `50 + 37 + 2 = 89`; not a proved total bound |
| Riding-shell air renderer | Graphics Y in the source audit | `+42` source operand/model offset |
| Riding-shell ground renderer | Graphics Y in the source audit | `+45` source operand/model offset |
| Object-top bounce | State Y becomes `objectY + hitboxHeight` | Snap is geometry-dependent; callers set Y velocity `30` or `80` |
| Generic object push | State X/Z radial correction plus wall resolution | `objectRadius + 37 + padding`; no total bound without live walls |
| Bully response | State X/Z from the two-body solver | No fixed global bound without radii/speed/state closure |
| Water pitch plus bob | Graphics Y only | Conservative modeled envelope `<=208`, not linked retail coverage |
| Quicksand sink | Graphics Y, optionally throw-matrix Y | `-depth`; prepared negative-depth example raises a zero base by about `2.65` |

Walls do not supply a hidden `+Y` term to the two shell rows.  In the
inspected source, wall collision changes X/Z and may indirectly select a
different floor, so it can change the absolute height to which the step
synchronizes Mario.  The step then sets Graphics from State and adds exactly
one shell source operand; the end-of-behavior copy sets raw Object from the
same State.  Consequently a wall/floor lift moves Object along with State and
does not enlarge the next-frame Graphics-minus-Object gap.  The ground
wall-hit branch still reaches the one `+45`; the air wall-hit branch still
reaches the one `+42`.  On the frame where cached upper-warp interaction
succeeds, direct source inspection instead selects `ACT_DISAPPEARED` before
action dispatch, so neither shell body runs.

Rocq proves these statements only in the explicit three-view abstraction:
an arbitrary State-only writer has zero Graphics-Y delta, and an arbitrary
wall/floor-selected State height followed by the modeled shell reanchor leaves
a gap at most `45`.  Applying them to retail requires the still-open Clight
pointer/dataflow, action-dispatch, object-copy, and flag-closure proofs.  The
separate bit-0/`oGraphYOffset` behavior-tail overwrite remains a model
counterexample until retail initialization and all flag mutations are closed;
it is not caused by wall contact.

The shell `42`/`45` constants now have US/JP generated-AST occurrence receipts
and a Rocq integer-model bound.  The field/formula meaning comes from manual
source inspection; a statement-level Clight proof and route-local binary32
arithmetic/live-range results remain open.  The checked out-of-range witnesses
show that the source operand is not a valid arbitrary-input endpoint bound.
The `89` shell figure is the pre-wall
radial target, not permission to claim that every shell frame moves Mario by
at most 89.
The complete source formulas and caveats are in
[`docs/notes/ink-fallback.md`](docs/notes/ink-fallback.md#interaction-and-action-displacement-census).

The PU variant uses Graphics X `63488`, which the floor query narrows to
`-2048`.  Object collision can cache the warp from the first sample.  The wall
and first floor queries use the second sample.  If that first floor query
returns `NULL`, `update_mario_geometry_inputs` copies Graphics into State and
retries.  A loaded top-owned retry floor can then feed `ACT_DISAPPEARED`; State
is later copied to raw Object.  If the retry is also `NULL`, however,
`update_mario_geometry_inputs` requests `WARP_OP_DEATH` before it processes
the cached object interactions.  The interaction selects `ACT_DISAPPEARED`
with a two-count argument and requests the object warp later.
`level_trigger_warp` only writes an empty delayed-warp slot; at zero lives it
rewrites death to the still-nonzero game-over operation.  In the small model,
an uncleared fatal request prevents the later node-`0x1E` request from becoming
pending.  A retail proof must also cover the other timing branch: if a clear
happens first, it must occur in reset/initialization scheduling that destroys
the `ACT_DISAPPEARED` continuation before another Mario update can issue a
useful request.  Thus a surviving schedule must obtain a non-null retry floor
once that linked scheduler refinement is proved.

The detailed source audit found no retail timing escape from that latch.  The
retry-null frame still processes the cached interaction and sets
`ACT_DISAPPEARED`, but `execute_mario_action` returns on the null floor before
dispatching it.  Later usable-floor frames can decrement its two-count
argument and eventually request the object warp; meanwhile the normal
delayed-warp countdown does not directly clear the fatal operation.  Relevant
clear sites have two orderings: warp-arrival/credits paths reset before clear,
whereas `init_level` and `lvl_init_from_save_file` clear before reset but admit
no useful Mario update in between under the intended scheduler.  What prevents
this source argument from already being a linked theorem is concrete:
`behavior_script.c` is now generated, but the project does not yet construct
the exact link or prove the indirect `cur_obj_update` callback.  The proof still needs that scheduler fact,
shared-global/frame-condition, and compiled-`find_floor` refinements.

Remaining object lists and the deactivated unload pass run before the final
platform query.  The checked syntax therefore admits an explosion-frame
candidate in which the loop is followed by the collision loader and the final
query encounters a surface whose owner slot has become inactive.  The existing
lifecycle record tries to describe the retained surface pointer plus an active
or inactive same-epoch owner, but its current linking, projection, external
effects, and float premises are not strong enough to make it a valid proof
target.  It also does not encode that the top itself was scanned/deallocated;
free-list membership is a separate open fact.
`ink_local_conditional_pipeline_coordinate_witness` and
`ink_pu_conditional_pipeline_coordinate_witness` evaluate the handwritten
pipeline's coordinate arithmetic for these local and PU variants.  The
generated-AST receipt separately checks the null-test/copy/retry syntax; a
Clight execution of those outcomes remains open.

The five-obligation audit produced three different outcomes:

1. The surface, prestate, and writer propositions are predicate-sensitive
   schemas.  Rocq exhibits interpretations making each accept or reject.  They
   still need concrete linked-run relations before they can decide retail
   reachability.
2. The old sink proposition was refuted.  Its unrestricted `Smallstep.star`
   could continue past one return into a second invocation, and its aggregate
   address ranges admitted a concrete modular pointer alias.  The repaired
   obligation uses a first-return relation and pairwise-disjoint four-byte
   cells.  It is a plausible concrete memory obligation, but remains unproved.
3. The lifecycle proposition can be false under a hostile projection/link.
   Although `behavior_script.c` is now imported, the interface neither
   constructs the exact link nor establishes the indirect callback.  It also lacks external-call frame
   conditions, pointer-to-pool-slot/epoch linkage, and finite-float premises.
   It must be replaced by an exact-link, clean-run interface.  The checked NaN
   counterexample shows why equal Coq-level binary32 values alone do not imply
   the retail `< 4.0f` platform-tolerance comparison.

These are specification counterexamples, not gameplay counterexamples.

The two closed coordinate witnesses use the zero-yaw home top and floor Y
`1791`.  They are not explosion-pose witnesses.  A handwritten minimum-pose
recurrence starts at the home Y and yields the conservative center-Y target
`1871` by timer `150`.  It is not an exact execution of the timer-59
smooth-rise state, nor a proved binary32 lower bound for the generated Clight.
The explosion/inactive-slot branch must therefore recover the actual later
translated/rotated transform and selected floor height through the replacement
linked lifecycle interface.

This answers the chatbot disagreement precisely.  The second chatbot is right
that object collision does not wrap, the stock warp and top are vertically
disjoint at one coordinate, platform displacement cannot newly create the
same-frame warp collision, and Mario's model moves later.  Its conclusion is
too broad: the graphical fallback permits three different coordinate samples
in one frame.  The PU floor-alias primitive is real, but an audited PU-sized
State-only displacement writes only State and cannot manufacture the required
Object/Graphics split.  Neither conditional coordinate witness is a reachable
stale-slot Clight or ROM trace.

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
`1110.6683`-unit Y rise exceeds the signed-range 385-unit necessary lower
bound, and the
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
object count, or the watched free-list head occur together.  That concrete
lineage is no longer needed for the **pre-existing-platform-origin** subcase
because the generic stock pre-apply result below rules out every bounded
platform origin at the warp collision sample.  It does not rule out a first
query returning `NULL` followed by a graphical retry and a new top capture.
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
eliminates the pre-existing-platform bootstrap more generally than the
original top-slot argument.
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
`stock_upper_warp_has_no_platform_created_route_split` leaves **zero bounded
stock schedules whose split starts from a pre-existing platform pointer** in
that model, regardless of payload class, depth, mist branch, FIFO behavior, or
controller lineage.  A null pre-apply pointer is compatible with Ink's
graphical fallback: the retry can select the top and the final query can then
create a new platform pointer.

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
pre-existing-platform conclusion for all stock owners in its source-bounded
relation.  In software terms, Area 1 has real "replacement object mutates all
three coordinates" primitives, but none has a non-null **pre-apply** platform
producer at the required old-object warp sample.  This does not exclude a
post-collision graphical retry and later top capture.

This is still not a retail counterexample or a whole-program impossibility
proof.  `Area1StockPreapplyProjectionSound` is a stated refinement premise, not
yet a construction from linked Clight memory.  The proof has not executed the
surface loaders and final floor selection over a live object pool or shown that
every retail pre-apply state projects into the fifteen-owner relation.
For the graphical-fallback shape, it also has not proved entry-time
Object/Graphics equality in live memory, complete reachable graphics-writer
and action/spawn closure, the first-query `NULL`, the loaded-top retry,
sink-memory provenance, or the post-copy active/inactive-same-epoch owner
lifecycle.  The old sink statement is refuted and its repaired first-return
form is open.  The lifecycle statement itself must be replaced with an exact
link, certified projection, anchored clean run, constrained external effects,
and a pointer-to-slot/epoch relation before any unload or final-owner result
can be claimed.  It does not prove that the top is scanned/deallocated or
placed on the free list.
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
bounded pre-existing platform origins are null at the old-object warp sample.
That result does not exclude a null first query followed by Ink's graphical
retry and a new top capture.  The separate JP destination-area pointer/payload
census above remains open.

Moving/loading the warp onto the top, moving the top down to the already-loaded
warp, collision-preserving cloning, and direct post-query writers remain
separate unresolved constructions.  The full audit and theorem boundary are in
[`docs/notes/pyramid-top-pu.md`](docs/notes/pyramid-top-pu.md).

`UpperWarpTopCoincidenceMechanism`,
`UpperWarpTopPreludeCaptureEvidence`,
`UpperWarpTopPreludeToCleanEntryBridge`, unload-retention/reuse evidence, and
`UpperWarpStaleTopConditionalPathEvidence` name the older same-sample
conditional path.  They do not encode the new three-view schedule.  A
replacement Clight evidence record must carry collision Object C, first-query
State S, pre-fallback Graphics G, the first-query `NULL`, loaded-top retry
selection, post-action State/Graphics (including the intervening
Graphics-position and throw-matrix sink writes), the copied Object, intervening
object-list/unload lifecycle, an active-or-inactive-same-epoch final
surface owner, final platform query, and delayed-warp lifetime.  If the
explosion/free-list branch is claimed, separate evidence must prove that the
top itself is scanned/deallocated and inserted into that list.  A source-backed
clean-entry theorem must either construct that evidence or prove every family
unreachable; it must not simply decree the JP platform pointer null or safe.

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
[`docs/notes/model-counterexample.md`](docs/notes/model-counterexample.md).

### What the route theorem does not establish

The route contract is a formal transcription of the supplied strategy
argument, not yet a derived projection of the retail executable.  The new
evidence structures make the required projection checkable, but their
coverage and the entrance cuts are still unproved:

- extract the collision arrays into exact surface identifiers and prove the
  source/target connected-component cuts, their
  `EntranceCollisionCutEntryContract`, endpoint-local separation, and their
  selection by `TargetCollisionCutFamily`;
- construct `FirstValidatedCutCrossingAt` from each linked US/JP first target
  access, including target-collision-to-cut refinement and any crossing inside
  the same frame or subframe as that collision;
- prove the six movement/domain cases and the separate same-position
  support-selection case impossible from a source-backed clean entry, or else
  produce an exact reachable counterexample trace; and
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
lineage is therefore no longer a Layer-B obligation for the bounded
pre-existing-platform-origin subcase.  The null-preapply graphical retry, the
linked-Clight projection of that theorem, constructions outside its bounded
owner relation, and delayed-lifetime questions remain open.

The full alternative-route inventory and its present proof boundary are
spelled out in
[`docs/notes/route-exhaustiveness.md`](docs/notes/route-exhaustiveness.md).

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
    => position writer or changed support selection        (PROVED for a validated
                                                            pre-target non-target frame)
    => every crossing cause requires an A edge             (OPEN: six movement/domain
                                                            cases plus support selection)
    => at least one edge-triggered A press                 (OPEN: gate geometry)
```

The first two arrows are proved inside the abstract certified event model.
The target-region arrow is now proved by the route/event alignment carried by
`ClightRouteTraceProjection`; constructing that alignment from a retail
execution is part of the open whole-program refinement.  `ModelGapAudit.v`
shows why the old abstract endpoint relation cannot stand in for that
execution.  `FirstTargetRefinement.v` defines the older entrance-cut and
evidence-bearing bypass arrows and proves several finite eliminations.
`FirstCrossingWriterCoverage.v` proves admission-free writer coverage for an
already-constructed `FirstValidatedCutCrossingAt`; unlike the unused
`FirstTargetWriterCoverageObligation`, the cited frame is star-ordered before
a matching target-event segment, every earlier index has ordered evidence,
and none of those earlier endpoints is on the target side.  The selected
cut-family construction, mesh
connectivity, target-collision refinement, same-frame/subframe case, six
movement/domain exclusions, and support-selection exclusion remain open.  No
global US/JP bypass exclusion is proved.  The reverse direction--a cut bypass
continuing to a target--also remains conditional on separate downstream and
abstract-execution certificates.

## What the generated source already confirms

The current project regenerates CompCert Clight ASTs for both target versions
from the pinned decomp revision: 37 translation units per version, 74 modules
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
  snap, projected Graphics-position quicksand sink, and state/object copy occur
  in the phase order used by the new PU coordinate witness.  The sink can also
  write `gfx.throwMatrix`; remaining object lists and deactivated-object unload
  run before the final platform query.  The generated source admits a distinct
  explosion-frame inactive-owner candidate, but the home-pose Y `1791`
  witnesses do not instantiate its translated/rotated surface.  Free-list
  membership and the repaired first-return sink refinement remain open; the
  current post-copy lifecycle interface is invalid and must be replaced;
- the geometry refresh has a guarded first-floor-null branch that copies
  `MarioObject.header.gfx.pos` into MarioState and retries `find_floor`, which
  creates the three-view scheduling shape used by `InkFallback.v`;
- if that retry is also null, the geometry refresh calls
  `level_trigger_warp(m, WARP_OP_DEATH)` before interaction processing.  The
  generated US/JP recognizers check this guarded call, the
  `sDelayedWarpOp == WARP_OP_NONE` first-writer latch, and the call order.
  `ink_retry_null_fatal_latch_blocks_later_upper_request` proves the corresponding
  finite handwritten fatal-latch transition.  Under the source-audited order
  and empty/persistent-latch premises, that model excludes the
  both-queries-null upper-warp schedule.  Source-to-model refinement, the
  initial-empty fact, and the scheduler-aware block-or-reset disjunction in a
  linked retail run remain open;
- arbitrary ordinary, platform, or PU-sized **State-only** writes preserve the
  collision Object and fallback Graphics samples.  The source audit identifies
  `45` as the dry route-specific visual-offset target, while the deliberately
  conservative modeled water/bob writer relation uses `208`; both are below
  the signed-range generic required `385`.  The two exact proposed prestates
  require
  `973`; applying any bound to every reachable retail writer is open.
  Complete retail writer/action/spawn closure remains open.  In particular, a
  prepared `ACT_LONG_JUMP_LAND` state with pre-frame timer `4` can produce a
  negative quicksand-depth operand of about `-2.65`; subtracting it can raise
  Graphics by about `2.65`.  In the normal action graph this requires a prior
  A-edge setup.  Stock upper-warp support is `SURFACE_WALL_MISC` and cannot
  generate that adjustment, but persisted depth still requires action/state
  closure;
- node `0x1E` is delayed: object updates run before each of the 20 normal-play
  timer decrements, two change-area frames omit object updates, and the
  following normal frame loads Area 2 before its first object update;
- the US spawn path directly clears `gMarioPlatform`, while the JP path does
  not contain that direct clear call; and
- the no-spin airborne entry handler calls the launch helper with single-
  precision zero, and that helper calls forward-velocity setup and
  `perform_air_step`;
- `mario_actions_submerged.c` is now imported for both versions.  Admission-free
  AST receipts cover the water full-step helper calls, all three direct
  whirlpool position slots, and the common water-level clamp.  This closes the
  missing translation-unit hole, not SSL action reachability or complete
  position-writer callgraph refinement; and
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
| `ssl-spawning-displacement-proof` | Identifies the JP stale-platform mechanism, retained inactive/reused slot cases, and the exact spinning-top payload that can move upper-entry Mario outside the shaft in the present abstraction.  Its State/Object timing observations motivated the newly rechecked phase-split source facts and countermodel.  The current project now classifies the stock Area-1 angular-payload families and proves every bounded stock pre-apply platform origin null at node `0x1E`, not merely the earlier `[top, box]` case.  Its writer census also helped locate the real graphical fallback. | A linked Clight proof that the finite owner/origin relation covers every retail Area-1 pre-apply state, any construction outside that relation, survival or recapture through the delayed warp, or a retail continuation to a target region.  The archive's hand-selected unowned-floor observation is not a proof of stock provenance.  Its old model omitted the real Graphics-to-State null-floor retry, so its visual-position exclusion cannot rule out Ink's three-view schedule. |
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
5. Construct `FirstValidatedCutCrossingAt` from every linked first target
   access.  The abstract non-target-frame writer coverage theorem is now
   proved; the remaining construction must connect the target collision to a
   selected `TargetCollisionCutFamily` member and account for crossings inside
   the same frame or subframe as the target collision.
6. Eliminate, under the linked retail no-A execution, local ordinary motion,
   platform displacement, object/moving geometry, clip/tunnel,
   coordinate-alias/out-of-bounds ordinary-physics endpoints, and
   lifecycle/entry displacement.  Separately eliminate the seventh
   same-position floor/platform support-selection case.  None of these global
   exclusions is proved.  For Ink's graphical fallback, replace the
   predicate-sensitive surface, writer, and prestate schemas with concrete
   linked-run relations.  The surface replacement must execute the real first
   `find_floor` query and graphical retry over the live static and dynamic
   lists.  Then prove entry-time Object/Graphics synchronization plus complete
   reachable writer/action/spawn closure, or construct the exact clean no-A
   three-view prestate.  Prove the repaired first-return,
   modular-cell-disjoint `InkFallbackSinkMemoryRefinementObligation`.  Replace
   `InkFallbackPostCopyLifecycleRefinementObligation` with an exact linked
   program that exactly links the imported `behavior_script.c`, an anchored clean run, a certified
   memory projection, external-call frame conditions, finite transformed
   surface samples, and concrete pointer-to-slot/epoch linkage.  Only then
   prove later object writers, unload preservation, retained surface identity,
   and the final active/inactive-same-epoch owner.  Separately prove that the
   top itself is scanned/deallocated and any claimed free-list membership.
7. For JP platform displacement, derive every admissible raw pointer from an
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
   for both retail versions, but it does not discharge the replacement surface
   interface described in item 6.
8. Validate the claimed no-A downstream paths from each successful bypass to
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
- `proofs/Area1FirstNull.v`: generated-initializer parser and exact static
  cell-inventory computation; a pure static wall/floor evaluator with computed
  rejection trace, signed-32 bounds, and decisive binary32 receipts; plus
  explicitly separate live-Clight/dynamic-list/reachability obligations;
- `proofs/EntryMemory.v`: generated layout certificates and the conditional
  `Mem.load` postcondition-to-projection theorem; entry execution is pending;
- `proofs/PyramidTopSurface.v`: generated matrix/surface bodies and checked
  concrete Clight/retail-fragment cast values, parsed-to-manual zero-yaw
  face link, hand-mirrored cell/transform/edge arithmetic, and guarded
  dynamic-floor assignment source shape;
- `proofs/PyramidTopPU.v`: the modeled same-sample contradiction, conditional
  Y-preserving stock-yaw arithmetic exclusion lemmas, the phase-separated
  coordinate countermodel, and delayed-lifetime obligation;
- `proofs/InkFallback.v`: exact nearby Area-1 mesh arithmetic, local and PU
  three-view conditional pipeline coordinate witnesses, State-only
  preservation, the signed-range generic `385`-unit necessary gap, the exact
  proposed
  prestate's `973`-unit gap, conditional theorems for the dry audit target `45`
  and modeled `208` writer relation, the retry-null death-latch transition,
  schema-sensitivity witnesses, the modular pointer-wrap counterexample, the
  repaired first-return sink obligation, and the deliberately retained but
  invalid lifecycle interface that must be replaced;
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
- `docs/notes/archived-proof-evidence.md`: detailed audit of every prior project;
  and
- `docs/notes/pyramid-top-pu.md`: source audit and exact boundary of the newest
  pyramid-top PU result;
- `docs/notes/ink-fallback.md`: the human-readable scheduling verdict, writer census,
  PU distinction, and remaining reachability/surface obligations;
- `docs/notes/pyramid-top-surface-refinement.md`: exact checked surface kernel versus
  remaining live-memory refinement;
- `docs/notes/retail-find-floor-cast.md`: authenticated US/JP function offsets,
  instruction receipt, hashes, and reproduction commands; and
- `docs/notes/jp-slot-lifetime.md`: exact JP slot-lifetime facts and unresolved
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
