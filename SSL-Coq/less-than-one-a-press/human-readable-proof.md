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
> out several classes inside the certified model.  It does **not** construct
> that evidence from a complete retail execution or close the remaining
> movement classes.  `ModelGapAudit.v` proves that the older abstract event
> relation admits a spurious one-frame collection from a clean entry, so that
> relation cannot by itself establish the retail theorem.

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
`(0, 5500, 256)`.  On JP, if Mario can trigger source node `0x1E` while his
floor is the spinning pyramid-top object, and that object unloads while
`gMarioPlatform` retains its slot, Area 2 can read the inactive or reused
slot's old displacement fields.  The current source-shaped payload with
position `(-2047, *, -1023)` and yaw delta `0x1800` maps upper-entry Mario from
approximately `(0, 5500, 256)` to
`(365.592773, 5500, -1096.8027)`.  That leaves the ordinary shaft/cage region
without an A edge and is therefore a serious platform-displacement
constructor in the current abstraction.

This is not yet a retail counterexample.  No controller-authentic predecessor
has been found that makes the upper warp and the spinning top's collision
coincide.  The unresolved constructions include moving/loading the warp onto
the top, moving the top down to the already-loaded warp, and cloning that
preserves usable collision.  The fact that some cloning attempts lose
collision is a candidate obstruction, not an exhaustiveness proof.

`UpperWarpTopCoincidenceMechanism`,
`UpperWarpTopPreludeCaptureEvidence`,
`UpperWarpTopPreludeToCleanEntryBridge`, unload-retention/reuse evidence, and
`UpperWarpStaleTopConditionalPathEvidence` name this conditional path.  A
source-backed clean-entry theorem must either construct such evidence or prove
all three coincidence families unreachable; it must not simply decree the JP
platform pointer null or safe.

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
stale pyramid-top calculation is evidence about one such mechanism, not yet a
witness that its required upper-warp/top coincidence is retail-reachable.

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
    => first target-side collision-support cut crossing    (OPEN: Clight/mesh coverage)
    => every crossing writer requires an A edge            (OPEN: six writer families)
    => at least one edge-triggered A press                 (OPEN: gate geometry)
```

Only the first two arrows are currently proved inside the abstract certified
event model, and `ModelGapAudit.v` shows why that model cannot stand in for the
retail execution.  `FirstTargetRefinement.v` defines the third and fourth
arrows as evidence-bearing obligations and proves several finite
eliminations, but it does not establish mesh connectivity, total writer
coverage, or the six remaining exclusions.  No global US/JP bypass exclusion
is proved.  The reverse direction--a cut bypass continuing to a target--also
remains conditional on separate downstream and abstract-execution
certificates.

## What the generated source already confirms

The current project regenerates CompCert Clight ASTs for both target versions
from the pinned decomp revision: 27 translation units per version, 54 modules
in total.  Direct inspection of that pinned C source shows:

- the controller input calculation distinguishes `buttonPressed` from
  `buttonDown`;
- the pole action bodies test `INPUT_A_PRESSED` on paths selecting pole-jump
  actions;
- the pole source also contains the Z-triggered soft-bonk/drop path,
  so "the source mentions A" alone is not a pole-impossibility proof;
- object processing applies Mario's platform displacement before detecting
  object collisions;
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
branches exhaust every way past the pole.

The generated collision wrapper contains the area 1/2/3 static arrays and the
pyramid-top, Tox Box, Grindel, Spindel, moving-wall, elevator, and Eyerok
arrays.  Rocq proves their checked initializer word counts and that the
route-relevant US and JP initializers are identical.  It does not yet parse
those words into triangles, resolve dynamic transforms, or prove a surface
connected-component theorem.

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
| `ssl-spawning-displacement-proof` | Identifies the JP stale-platform mechanism, retained inactive/reused slot cases, and the exact spinning-top payload that can move upper-entry Mario outside the shaft in the present abstraction.  It motivates the new predecessor, floor-owner, allocation-epoch, unload, reuse, and collision-phase evidence. | A controller-authentic upper-warp/top coincidence.  In particular it does not exhaust moving/loading the warp onto the top, moving the top to the warp, or collision-preserving cloning; nor does it provide a retail continuation to a target region. |
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
   source/target support and open-cell cuts for both entrances.
5. Prove first-crossing writer coverage and eliminate ordinary motion,
   platform displacement, object/moving geometry, clip/tunnel, general
   coordinate alias/out-of-bounds, and lifecycle/entry displacement.
6. For JP platform displacement, derive every admissible raw pointer from an
   actual predecessor, including inactive/reused slot epochs and the
   upper-warp/spinning-top coincidence families.
7. Validate the claimed no-A downstream paths from each successful bypass to
   the Act 3 region and all five Act 6 triggers.

Until these obligations are discharged, `conditional_target_clight_run_impossibility`
is correctly named *conditional* and the retail-game theorem remains open.

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
  cross-version equality;
- `proofs/FirstTargetRefinement.v`: indexed Clight-frame evidence, collision
  cuts, concrete bypass classes, and conditional stale-top path;
- `proofs/ModelGapAudit.v`: executable countermodels to the old abstraction
  boundary;
- `proofs/LowerEntrance.v` and `proofs/UpperEntrance.v`: open Layer B
  obligations;
- `proofs/MainTheorem.v`: proved reduction and conditional capstone; and
- `docs/archived-proof-evidence.md`: detailed audit of every prior project.

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
