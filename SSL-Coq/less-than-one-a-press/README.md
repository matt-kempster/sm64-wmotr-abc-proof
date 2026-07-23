# Less than one A press in the SSL pyramid

This is the current Rocq/Coq and CompCert Clight project for the following
target:

> Starting from a clean entry into Shifting Sand Land pyramid area 2, neither
> "Inside the Ancient Pyramid" nor "Pyramid Puzzle" can be newly collected in
> an execution with fewer than one A-button press.

The project is intentionally blunt about status: **the ultimate theorem has
not been proved**.  The collection/provenance reduction is proved for the
project's certified event semantics, and syntax-level facts are proved about
the generated Clight ASTs.  A finite writer model now classifies the first
target-bit transition as the matching normal star, an incoherent backup reload,
or an explicit corruption/unmodeled writer.  The historical first-target
theorem still classifies access as the entrance-specific A gate or one of nine
payload-free bypass tags only under the unproved
`FirstTargetCutClassificationObligation`.

`FirstTargetRefinement.v` now defines a stronger evidence-bearing interface:
each classified frame carries actual before/after Clight states, a CompCert
trace segment, projected states, an exact indexed `CertifiedStep`, and a
crossing of a concrete `CollisionSupportCut`.  It proves several limited
eliminations inside the certified semantics, but no concrete linked run
constructs that classifier and the remaining movement classes are not closed.
A separate, current-source-rechecked
`ArchivedProofIntegrationKernel` incorporates narrow lessons from all six
archived investigations without importing their old ASTs.  The whole-program
Clight-to-event/collision projection and every lower/upper collision-observation
non-overlap obligation remain open.  None of the six archived projects closes
either gap.

For a software-engineering-oriented explanation of the game state, the two
route gates, the exact proved reductions, and the contribution of each archived
project, see [`human-readable-proof.md`](human-readable-proof.md).  The precise
answer about routes outside the transcript is in
[`docs/route-exhaustiveness.md`](docs/route-exhaustiveness.md).

## Exact target and input definition

The pinned source names the edge field `Controller.buttonPressed` and the held
field `Controller.buttonDown`.  `read_controller_inputs` computes:

```c
buttonPressed = current & (current ^ previousButtonDown);
buttonDown = current;
```

Thus "fewer than one A press" is `fewer_than_one_a_press inputs`, defined as
`Forall frame_has_no_a_press inputs`, where bit 15 of the finite-width
`Int.and current (Int.xor current previous)` value is false on every modeled
frame.  A may be held at entry: `held_a_at_entry_is_permitted` proves that
`previous = current = A_BUTTON` has no edge while `A_BUTTON_DOWN` is true.

The behavior-parameter star indices are zero based.  The pinned source and
generated initializers establish:

- Act 3, "Inside the Ancient Pyramid": index `2`;
- Act 6, "Pyramid Puzzle": index `5`;
- the 100-coin star: index `6`, hence it aliases neither target.

"Newly collected" is the finite-width predicate:

```coq
Definition newly_collected initial_flags final_flags index : Prop :=
  Int.testbit initial_flags index = false /\
  Int.testbit final_flags index = true.
```

## Clean entry

`CleanPyramidEntry` constrains the supported version (`VERSION_US` or
`VERSION_JP`), SSL level and course, valid act, area 2, selected lower or upper
entrance, both active target bits initially clear, coherent active/backup
target bits, all five Puzzle triggers unconsumed, no pre-existing Act 3 or Act
6 substitute star, the designated static Act 3 star and hidden-star controller,
five distinct designated macro-trigger objects, target/trigger provenance,
per-trigger macro-respawn state equal to the consumed-trigger history, abstract
object-pool/list well-formedness flags, no pending star interaction or delayed
exit, coherent controller history, and version-specific Mario platform state.

The entry snapshot now distinguishes the two source objects exactly: lower
warp node `0x0A` at `(0, 300, 6451)` and upper warp node `0x14` at
`(0, 5500, 256)`, both facing 180 degrees and entering with the finite-width
`ACT_SPAWN_NO_SPIN_AIRBORNE` action (`0x1932`), zero Float32 velocity, and zero
Float32 forward velocity.  Current kinematics must equal that snapshot at the
chosen model boundary.  The designated Act 3 object is fixed at
`(500, 5050, -500)` with the source star hitbox.  The hidden-star controller is
fixed at `(900, 1400, 2350)`; an Act 6 star has that controller as parent and
that point as its home position, while its current position may change during
the spawn animation.  Each trigger carries its exact macro identity, Float32
position, trigger hitbox, and clear object/macro respawn state; in particular
the upper trigger is `(260, 3913, -600)`.  The concrete floor reference and its
projection from surface memory remain abstract.

It does not assert that Mario cannot reach either collision region.  The
abstract state represents `gMarioPlatform` by an intended object-pool slot plus
a ghost capture epoch used to distinguish allocation identities; no Clight
memory projection to that representation has yet been proved.  A null pointer
is `None`; a non-null pointer satisfying `raw_platform_slot_well_formed` is
exhaustively classified as live at the ghost epoch, inactive at that epoch, or
reused at a different epoch.  The ghost epoch is not yet proved to equal the
epoch at which the C pointer was captured.  US clean entries require `None`.
JP entries permit all four cases, so the separate JP upper obligation must
handle elevator containment and spawning displacement for each case.  The AST
checks establish a direct `clear_mario_platform` call in the US spawn body and
its absence from the JP body; an execution-level clearing/retention theorem is
pending.  The abstract clean-state predicate by itself does not prove that a
JP non-null pointer has a stock predecessor.  The concrete Clight nonvacuity
obligation consequently asks for actual projected clean runs rather than
claiming that every handwritten clean state is source-reachable.

This distinction matters for a model-only JP candidate: an inactive,
unreused pyramid-top slot with yaw delta `0x1800` can displace the abstract
upper-entry Mario state from `(0, 5500, 256)` to approximately
`(365.593, 5500, -1096.803)` with no A edge.  The payload and displacement
formula are source-shaped.  A fixture-assisted replay in the authentic JP ROM
installs the same raw transform payload once at the Area-2 boundary and, with
no A held or pressed, consumes the upper hidden-star trigger.  It is not a
target-bit counterexample: the trace has no Act 3 overlap, does not spawn the
Act 6 star, and does not directly read save RAM.  The same payload prepared
only before the Area-1
transition is cleared or reused and produces no displacement, so no stock
prehistory retaining that pointer has been established.

The conditional source path uses Area-1 warp node `0x1E` while the spinning
top owns Mario's floor, then arrives at Area-2 node `0x14`.  The warp normally
loads on area entry, but that observation is not an exhaustiveness proof.  The
proof must account for moving/loading the warp onto the top, moving the top to
the warp, and any collision-preserving cloning construction; it must not rule
them out by strengthening clean entry to assume a null or harmless pointer.
The formal evidence therefore puts capture, unload, and optional reuse in a
separate pre-entry Clight run whose final concrete state is exactly the clean
Area-2 run's starting state.

## Proof architecture and exact proved theorem

The current Layer A staging has four parts:

1. `ClightFacts.v` proves decidable source-shape facts over the generated US
   and JP Clight ASTs: identifier, constant, assignment-shape, direct-call, and
   direct-callee-order observations.  These checks do not prove operand
   dataflow, branch control dependence, loop execution, or memory effects.
2. `SourceExhaustiveness.v` provides an executable finite inventory of the
   seven normal SSL star sources and the target-save writers.  It proves that
   the normal non-target sources at indices `0`, `1`, `3`, `4`, and `6` cannot
   alias indices `2` or `5`, that a coherent backup reload cannot newly set
   either target, and that an anomaly-free first target-bit transition comes
   from the uniquely matching normal target source.  Completeness of this
   inventory for Clight executions remains an explicit refinement obligation.
3. `AreaTransitions.v` names abstract certified frame events for object
   spawn/deactivation, pool-slot reuse, macro respawn, unload/reload, area 2/3
   instant warp, collision refresh, save reload, Mario motion, and collection.
   Ordinary administrative events can no longer silently change Mario's
   kinematics; motion has explicit endpoint snapshots, the modeled area-2/3
   instant warp preserves the kinematic core, and save reload copies the
   coherent backup flags.  Trigger consumption marks the corresponding macro
   state consumed and leaves no active trigger of that kind; reload and macro
   respawn preserve that absence in the abstract semantics.  Full C effects
   are still not encoded for every lifecycle label.
4. `StarCollection.v` and `HiddenStar.v` prove collection and provenance
   reduction by inversion over those constructors.  The constructors already
   require the relevant origin, overlap, target-bit, trigger, and successor
   well-formedness facts; deriving those facts from Clight remains open.

`ArchivedProofIntegration.v` proves the separately audited theorem:

```coq
Theorem archived_proof_integration_kernel_holds :
  ArchivedProofIntegrationKernel.
```

Every generated-source field in this kernel is reproved against this
project's pinned US and JP Clight modules.  No archived Rocq namespace or
generated file is imported.  The six archive-derived components have the
following deliberately limited force:

- `ssl-spawning-displacement-proof` contributes current AST occurrence/call
  facts around `gMarioPlatform` and the US/JP platform-clear-call split, not a
  pointer dataflow theorem, containment, or reachability;
- `ssl-pyramid-item-proof` contributes current unload/load ordering,
  `_next`/`unload_object` source occurrences, and allocation-epoch identity
  facts, not loop execution or a Clight execution-to-event refinement;
- `ssl-parallel-universe` contributes current movement-source shape checks,
  the held-A edge fact, and a bounded static-quarter-step alias lemma, not a
  complete inventory of position writers;
- `pole-bypass` contributes current pole/action/gravity source-shape checks
  and a mathematical-integer normalized soft-bonk bound, not complete
  Float32 collision-phase coverage;
- `eyerok-manipulation` contributes current Eyerok lifecycle and platform
  recomputation source-shape facts, not its archived height-model refinement;
- `demo-warp` contributes the revision-neutral CompCert fact that a store can
  change a load only in the same memory block, not a proof of demo/Mario block
  provenance or reachable aliasing.

`RouteEvidence.v` contains only the narrow held-A, parallel-universe,
normalized-pole, and demo-memory lemmas named above.  Its `legacy_` relations
are regression certificates with explicit hypotheses, not simulations of the
linked game.  `MainTheorem.v` imports the integration module so it is on the
project build path.  The theorem
`current_verified_evidence_and_collection_reduction` combines the kernel and
event reduction as a conjunction; it deliberately proves no semantic bridge
between them and does not use the kernel as a substitute for refinement or
reachability.  See
[`docs/archived-proof-evidence.md`](docs/archived-proof-evidence.md) for the
project-by-project evidence boundary.

`TranscriptRouteModel.v` separately formalizes the route argument extracted
from the supplied transcript and the task's stronger post-gate completeness
proposal.  Its target nodes are the Act 3 interaction region and the upper
hidden-star trigger, not save-bit updates.  It selects the exact first target
observation, constructs the route/event prefix through it, and proves:

```coq
Theorem first_target_access_requires_gate_a_or_explicit_bypass :
  forall initial trace,
    FirstTargetCutClassificationObligation initial trace ->
    reaches_any_target_region trace ->
    exists region target_frame target_observation,
      first_target_observation_at
        trace region target_frame target_observation /\
      ((state_entrance initial = UpperEntrance /\
        (gate_a_press_precedes_exact_target trace ElevatorJumpOutGate
           region target_frame target_observation \/
         exists witness,
           upper_bypass_precedes_exact_target trace witness
             region target_frame target_observation)) \/
       (state_entrance initial = LowerEntrance /\
        (gate_a_press_precedes_exact_target trace SecondPoleJumpOffGate
           region target_frame target_observation \/
         exists witness,
           lower_bypass_precedes_exact_target trace witness
             region target_frame target_observation))).
```

The bypass values are finite entrance-specific class tags naming:
platform displacement; object pushes or moving geometry; warp/area 3;
collision clips or tunneling; parallel-universe/out-of-bounds movement; target
relocation or substitution; macro/object-lifecycle anomalies; save reload or
corruption; and memory or undefined behavior.

`first_target_access_with_all_bypasses_excluded_requires_a_edge` proves that
the same coverage premise plus absence of all tags entails an A edge.
`no_a_first_target_access_requires_explicit_bypass` proves that a no-A trace
reaching its first target must contain a tag before that target.  Tags are not
executable witnesses.  These theorems answer the route question only as
logical bookkeeping: the broad
`FirstTargetCutClassificationObligation` already assumes gate-or-tag coverage
and is not yet derived from the collision mesh or Clight.

`FirstTargetRefinement.v` makes the intended replacement precise.
`ClightFrameEvidence` binds a classification to the actual before/after
Clight states, a prefix/segment/suffix trace decomposition, projected
before/after game states, and the exact indexed certified step.
`MotionCrossesCollisionCutEvidence` uses finite static support references,
dynamic object references, and binary32 open cells to witness a source-side to
target-side crossing.  The event writer inventory is total and includes an
ordinary Mario/static-geometry class that the historical nine tags omitted.
The proved reductions eliminate, within the certified event semantics:

- direct displacement by the zero-offset area-2/area-3 instant warp;
- target identity/provenance anomalies at certified collection steps;
- invalid hidden-star macro/controller lifecycle steps;
- coherent save reload as a new target-bit writer; and
- projection mismatch once an indexed frame certificate exists.

The bounded static quarter-step lemma closes only one coordinate-alias
subcase.  Ordinary Mario/static-support motion, platform displacement, object
or moving geometry, clips/tunneling, general coordinate aliasing, and normal
reload/entry motion remain open.  Thus
`EvidenceBearingFirstTargetCutClassification` is a specification to construct,
not a completed US/JP classification, and its bridge does not prove
`FirstTargetCutClassificationObligation` without the still-open
ordinary/static class exclusion.

The older, coarser transcript contract also proves:

```coq
Theorem no_a_target_access_requires_gate_bypass :
  forall initial trace,
    TranscriptRouteGateModel initial trace ->
    fewer_than_one_a_press (route_inputs trace) ->
    reaches_any_target_region trace ->
    (state_entrance initial = UpperEntrance /\
       elevator_escape_observed trace) \/
    (state_entrance initial = LowerEntrance /\
       above_second_pole_observed trace).
```

The stronger
`no_a_target_access_requires_preceding_gate_bypass` theorem retains concrete
frame indices and proves that the selected bypass occurrence precedes the
selected target occurrence.  The capstone-facing corollary above drops those
indices after preserving the existence of the bypass.

It also proves that excluding both bypass observations on a supplied trace
forces an A edge in that route model.  Under explicit `UpperDownstreamCompleteness` or
`LowerDownstreamCompleteness` premises, a spawning-displacement escape or a
no-A state above the second pole yields separate no-A continuations to the two
target regions.  Those premises avoid claiming both stars are collected in one
course visit.

The `above_second_pole_observed` predicate is retained only as a historical
transcript node.  It is not the final lower collision cut: the pole grip top is
at Y `4020`, while the target-side support ring is at Y `3942` and the upper
Puzzle trigger is at Y `3913`.  A correct lower proof must classify first
collision-phase entry into the enumerated target-side support/open-cell
component around the pole hole, not use `marioY > 4020` or an informal floor
number.

Each route frame pairs its input with that frame's ordered observations.
`RealizedRouteTrace` additionally requires an abstract `CertifiedExecution`
with the same frame count and backs target observations by same-index Act 3
collection or upper-trigger-consumption events.  This rules out a bare appended
target label, but remains an abstract event certificate rather than a Clight
execution refinement.

`TranscriptRouteGateModel`, global US/JP bypass closure, both
downstream-completeness premises, `FirstTargetCutClassificationObligation`,
and the projection from Clight frames to synchronized route observations are
**not proved**.  Thus these are checked logical cut/classification lemmas, not
a proof that either contract exhausts target-ROM behavior.  An authentic no-A
elevator escape, target-side lower-cut crossing, or other bypass constructor
would refute the respective closure claim; it would become a zero-A
target-route capability only after downstream continuations are validated.

The fully proved result is an abstract event-reduction theorem:

```coq
Definition CollectionProvenanceReductionClaim : Prop :=
  forall initial events final,
    CleanPyramidEntry initial ->
    CertifiedExecution initial events final ->
    (newly_collected
       (state_save_flags initial) (state_save_flags final) act3_index ->
      exists star phase,
        In (EventCollectAct3 star phase) events /\
        active_star_or_key act3_index star /\
        object_origin star = StaticAct3PyramidStar /\
        act3_star_interaction_region phase star) /\
    (newly_collected
       (state_save_flags initial) (state_save_flags final) act6_index ->
      (exists star phase,
        In (EventCollectAct6 star phase) events /\
        active_star_or_key act6_index star /\
        object_origin star = PyramidHiddenStarController /\
        overlaps_object phase star) /\
      (exists spawned_star,
        In (EventSpawnAct6 spawned_star) events) /\
      all_five_trigger_consumption_events events /\
      (exists trigger_object phase,
        In (EventConsumeTrigger TriggerUpper trigger_object phase) events /\
        upper_hidden_trigger_overlap phase trigger_object)).

Theorem collection_provenance_reduction :
  CollectionProvenanceReductionClaim.
```

Within `CertifiedExecution`, it proves:

- a new Act 3 bit requires collection of an active index-2 star-or-key object
  carrying the handwritten static-Act-3 origin tag, designated allocation
  identity, exact static position, and an abstract registered interaction
  overlap;
- a new Act 6 bit requires an active index-5 star-or-key object with hidden
  controller origin tag;
- the trace contains an Act 6 spawn and a collision-backed consumption event
  for each of the five abstract trigger labels;
- the trigger event labeled `TriggerUpper` uses the designated trigger
  allocation, macro-origin/kind, and exact upper-trigger position, and has an
  abstract registered player/object overlap in its collision phase.

The handwritten collision predicate uses CompCert `Float32` subtraction,
multiplication, addition, square root and comparison over projected positions,
radii, and vertical hitbox bounds.  It also requires collision-list capacity,
target reference/epoch equality, equality with a designated abstract player
reference, area, instant-warp state, and update-phase flags.  No theorem yet
projects these fields from the generated Clight state.  The abstract upper
trigger is now connected to one designated reference and the exact macro
position, but proving that reference is the concrete spawned macro object is
part of the missing projection.

Layer B is split into `LowerEntranceReachabilityObligation`,
`UpperUSReachabilityObligation`, and `UpperJPReachabilityObligation`.  They
range over the explicit `project_collision_observations` stream of an imported
Clight run, rather than merely over collection event labels.  The refinement
certificate requires target collection and trigger-consumption events to occur
in that observation stream.  A concrete, complete collision projection is
still pending.  Given those propositions, the project proves the following
exact conditional statement:

```coq
Theorem conditional_less_than_one_a_press_impossibility :
  forall projection,
  LowerEntranceReachabilityObligation projection ->
  UpperEntranceReachabilityObligation projection ->
  forall run initial
      (certificate : ClightFrameRefinementCertificate
        projection run initial),
    CleanPyramidEntry initial ->
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

`conditional_target_clight_run_impossibility` additionally consumes
`TargetClightRefinementObligation`, a matching run/program and projected clean
start, and returns a projected final state with neither target newly collected.
That obligation is the conjunction of whole-run certificate construction and
nonvacuous clean-entry projection coverage.  Neither conjunct, either Layer B
premise, nor a concrete US/JP projection is proved.  Therefore neither
conditional theorem is the ultimate target theorem.

## Source and Clight scope

- Decomp revision: `9921382a68bb0c865e5e45eb594d9c64db59b1af`.
- Versions: `VERSION_US` with `F3DEX_GBI_2` and `F3DEX_GBI_SHARED`;
  `VERSION_JP` with `F3D_OLD`.
- Common flags: `-normalize -nostdinc -fstruct-passing`, project include paths,
  `_FINALROM`, `TARGET_N64`, `NON_MATCHING`, `AVOID_UB`, and `_LANGUAGE_C`.
- Generator: CompCert `clightgen` 3.15.

Twenty-seven translation units are generated for each version, for 54 Clight
modules total: `game_init.c`, `mario.c`, the six
`mario_actions_{airborne,automatic,cutscene,moving,object,stationary}.c` units,
`mario_step.c`, `interaction.c`, `save_file.c`, `object_collision.c`,
`object_list_processor.c`, `spawn_object.c`, `object_helpers.c`,
`obj_behaviors.c`, `obj_behaviors_2.c`, `behavior_actions.c`,
`behavior_data.c`, `area.c`, `level_update.c`,
`platform_displacement.c`, `surface_collision.c`,
`macro_special_objects.c`, `levels/ssl/script.c`, and a project wrapper for
`levels/ssl/areas/2/macro.inc.c`, plus `inputs/ssl_collision.c`, a project
wrapper importing the area-1/area-2/area-3 collision arrays and the
route-relevant pyramid-top, tox-box, grindel, spindel, moving-wall, elevator,
and Eyerok arrays.  This expands the imported surface for movement, entry
action dispatch, Mario quarter steps, Eyerok behavior, and static/dynamic
collision analysis.  `clightgen` translates every function and global
definition retained by preprocessing in each whole translation unit; the
proofs inspect only the named functions and shapes listed in the exact
source/function map in
[`notes/source-map.md`](notes/source-map.md).

## Build and regeneration

With Rocq 8.16.1 and CompCert 3.15 available:

```sh
make check
```

This builds all committed generated modules and proofs, rejects proof-hole and
unconstrained-declaration keywords in Rocq source, and prints assumptions for
the named integration, reduction, route, and conditional theorems.

Regenerate from a Git checkout containing the pinned commit:

```sh
SM64_SOURCE=/path/to/sm64 make regenerate
SM64_SOURCE=/path/to/sm64 make verify-generated
```

The pipeline exports the pinned commit with `git archive`, so uncommitted files
in the source checkout are not translated.  `verify-generated` hashes the
committed output, regenerates all 54 modules, and requires byte-for-byte
identity.

The command executed per unit is structurally:

```sh
clightgen -normalize -nostdinc -fstruct-passing \
  -Ibuild/pinned-sm64/include -Ibuild/pinned-sm64/src \
  -Ibuild/pinned-sm64/src/game -Ibuild/pinned-sm64 \
  -Ibuild/pinned-sm64/include/libc \
  -D_FINALROM=1 -DTARGET_N64=1 -DNON_MATCHING=1 \
  -DAVOID_UB=1 -D_LANGUAGE_C=1 VERSION_FLAGS input.c -o output.v
```

## Known limitations and semantic cautions

- `CertifiedExecution` is a contract-style event abstraction.  Collection
  constructors assume the desired origin, collision, save-bit, spawn, and
  trigger facts.  Motion, instant-warp kinematics, target-save reload, route
  context, and static trigger identity now have explicit effects, but other
  lifecycle labels still do not encode their full C effects.  The reduction
  theorem is constructor inversion, not a completed Clight-derived Layer A
  proof.
- Object origins, allocation epochs, the designated player/static-star
  references, hidden-controller parent references, trigger labels,
  macro-respawn bits, entry snapshots, and pool/list validity flags are
  handwritten ghost data.  Their concrete memory interpretation and
  preservation must be supplied by the missing refinement; none is an oracle
  conclusion about ROM reachability.
- No concrete `TargetLinkedProgram`, `ClightObservationProjection`, or
  `ClightFrameRefinementCertificate` is provided.  The link record asks for
  `linkorder` witnesses above all 27 units; it does not construct an iterated
  CompCert link.  `ImportedClightRun` is a finite `Smallstep.star` fragment and
  is not yet required to begin at `initial_state` or end at `final_state`.
- `WholeProgramClightRefinementObligation` and
  `CleanEntryProjectionNonvacuityObligation` are both open.  The latter asks
  for actual projected clean US/JP lower/upper starts; it deliberately does
  not assert the false surjectivity claim that every handwritten
  `CleanPyramidEntry` is source-reachable.  Until a concrete
  projection and certificate are proved, projected inputs, events, collision
  observations, and abstract states are uninterpreted functions.
- All three Layer B reachability propositions are open.  They are phrased over
  projected Float32 collision observations rather than an informal floor
  number, but completeness of that observation stream is itself part of the
  missing concrete refinement.
- The transcript route model has no Clight projection or collision-surface
  completeness theorem.  `FirstTargetCutClassificationObligation` makes the
  missing exhaustiveness result explicit and its tag sums make the intended
  historical case vocabulary finite.  Those tags have no state semantics.
  `FirstTargetRefinement.v` defines evidence-bearing replacements, but no
  concrete projection constructs them and the surviving writer classes are
  not excluded.  In particular, the lower cut is first collision-phase entry
  into enumerated target-side supports or binary32 open cells, not “above the
  second pole,” an informal floor number, or a bare Y bound.
- `ArchivedProofIntegrationKernel` is a proved package of current-source facts
  and narrow route lemmas, but it proves neither
  `TargetClightRefinementObligation` nor any Layer B premise.  Building or
  auditing the six archives does not transfer their old capstones into the
  current theorem.
- The JP `gMarioPlatform` analysis currently classifies null, live,
  inactive, and reused slots with a ghost capture epoch.  It does not yet prove
  that the abstract slot/epoch was projected from the C pointer, which cases
  are reachable, or the displacement produced by every reachable payload.  In
  particular, the model admits the stale pyramid-top payload described above.
  Proving source-backed prehistory must preserve the conditional
  upper-warp/top-unload route and separately analyze warp-to-top,
  top-to-warp, and collision-preserving clone constructions; setting the JP
  pointer to `None` or assuming every retained displacement is safe would not
  be a valid repair.
- The finite normal-SSL inventory proves unique abstract sources for indices
  `2` and `5` and non-aliasing of `0`, `1`, `3`, `4`, and `6`.  The raw
  initializer/constant checks support the target constants, but no proved
  Clight decoder/coverage result yet connects every relevant
  behavior-parameter bit pattern and spawn path to that inventory or to
  `object_star_index`.
- `AVOID_UB` supplies a zero return for the source's missing-return paths in
  collision helpers.  Refinement to the behavior of the target compiled ROM is
  pending for any reachable such path.
- Seven long-double literals in `object_helpers.c` are translated as double so
  `clightgen` can process the unit.  The target collection functions do not use
  those literals, but a formal call-graph irrelevance/refinement proof is still
  pending.
- The separate generated translation units have not yet been linked into one
  CompCert program with external-call specifications.
- `Print Assumptions` reports CompCert's standard classical real-number and
  dependent functional-extensionality foundations for the float model.  The
  project declares no new logical axioms.
- `ModelGapAudit.v` proves that the current endpoint-only certificate still
  accepts arbitrary Mario-motion endpoints and can pair a clean US or JP
  entry with a synthetic immediate Act 3 overlap/collection event.  Separately,
  `endpoint_only_alignment_does_not_imply_cut_classification` shows that
  endpoint/event alignment cannot derive the first-cut classification.  These
  are abstraction counterexamples, not actual ROM traces.  The
  evidence-bearing frame interface states the needed repair, but its
  construction from a linked Clight run remains open.
- A second audit found that an active target bit could be clear while the
  backup slot already held it; the real game-over reload path could then set
  the active bit without a star event in the older abstraction.  Clean entry
  now requires active/backup target coherence, `EventSaveFileReload` explicitly
  copies the backup, and the finite writer theorem classifies incoherent reload
  and corruption rather than hiding them.  This was also an abstraction
  loophole, not a demonstrated clean ROM state.
- No stock-reachable US or JP ROM counterexample has been established.  The
  fixture-assisted JP stale-top run does reach and consume the upper hidden
  trigger with zero A edges, but it has no Act 3 overlap, does not spawn the
  Act 6 star, and does not directly read save RAM.  No stock-reachable
  predecessor for the setup has been established.  Other finite schedules
  found no target witness; neither result is an exhaustive controller-only
  reachability proof.

The supplied A-press transcript was used only to identify candidate routes and
version-sensitive behavior.  The pinned source and formal definitions control
the claims.
