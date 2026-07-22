# Less than one A press in the SSL pyramid

This is the current Rocq/Coq and CompCert Clight project for the following
target:

> Starting from a clean entry into Shifting Sand Land pyramid area 2, neither
> "Inside the Ancient Pyramid" nor "Pyramid Puzzle" can be newly collected in
> an execution with fewer than one A-button press.

The project is intentionally blunt about status: **the ultimate theorem has
not been proved**.  The collection/provenance reduction is proved for the
project's certified event semantics, and syntax-level facts are proved about
the generated Clight ASTs.  A separate, current-source-rechecked
`ArchivedProofIntegrationKernel` incorporates narrow lessons from all six
archived investigations without importing their old ASTs.  The whole-program
Clight-to-event refinement and every lower/upper geometric reachability
obligation remain open.  None of the six archived projects closes either gap.

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
entrance, both target bits initially clear, all five Puzzle triggers
unconsumed, no pre-existing Act 3 or Act 6 substitute star, the designated
static Act 3 star and hidden-star controller, target provenance, valid macro
spawn state, abstract object-pool/list well-formedness flags, no pending star
interaction or delayed exit, coherent controller history, and
version-specific Mario platform state.

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
pending.

## Proof architecture and exact proved theorem

The current Layer A staging has three parts:

1. `ClightFacts.v` proves decidable source-shape facts over the generated US
   and JP Clight ASTs: identifier, constant, assignment-shape, direct-call, and
   direct-callee-order observations.  These checks do not prove operand
   dataflow, branch control dependence, loop execution, or memory effects.
2. `AreaTransitions.v` names abstract certified frame events for object
   spawn/deactivation, pool-slot reuse, macro respawn, unload/reload, area 2/3
   instant warp, collision refresh, and collection.  Most lifecycle labels do
   not yet impose their full named C state effects.
3. `StarCollection.v` and `HiddenStar.v` prove collection and provenance
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

The fully proved result is an abstract event-reduction theorem:

```coq
Theorem collection_provenance_reduction :
  forall initial events final,
    CleanPyramidEntry initial ->
    CertifiedExecution initial events final ->
    (newly_collected (state_save_flags initial)
       (state_save_flags final) act3_index ->
       exists star phase, (* active index-2 static star and Act 3 overlap *)) /\
    (newly_collected (state_save_flags initial)
       (state_save_flags final) act6_index ->
       (* active index-5 controller-origin star, its spawn, and an upper
          hidden-trigger overlap all occur *));
```

Within `CertifiedExecution`, it proves:

- a new Act 3 bit requires collection of an active index-2 star-or-key object
  carrying the handwritten static-Act-3 origin tag and an abstract registered
  interaction overlap;
- a new Act 6 bit requires an active index-5 star-or-key object with hidden
  controller origin tag;
- the Act 6 star was spawned only after all five triggers were consumed;
- the trigger event labeled `TriggerUpper` has an abstract registered
  player/object overlap in its collision phase.

The handwritten collision predicate uses CompCert `Float32` subtraction,
multiplication, addition, square root and comparison over projected positions,
radii, and vertical hitbox bounds.  It also requires collision-list capacity,
target reference/epoch equality, equality with a designated abstract player
reference, area, instant-warp state, and update-phase flags.  No theorem yet
projects these fields from the generated Clight state, and the upper trigger
label is not yet connected to the specific macro initializer/reference.

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

Twenty-five translation units are generated for each version, for 50 Clight
modules total: `game_init.c`, `mario.c`, the five
`mario_actions_{airborne,automatic,moving,object,stationary}.c` units,
`mario_step.c`, `interaction.c`, `save_file.c`, `object_collision.c`,
`object_list_processor.c`, `spawn_object.c`, `object_helpers.c`,
`obj_behaviors.c`, `obj_behaviors_2.c`, `behavior_actions.c`,
`behavior_data.c`, `area.c`, `level_update.c`,
`platform_displacement.c`, `surface_collision.c`,
`macro_special_objects.c`, `levels/ssl/script.c`, and a project wrapper for
`levels/ssl/areas/2/macro.inc.c`.  This expands the imported surface for
movement, action dispatch, Mario quarter steps, Eyerok behavior, and floor or
surface collision analysis.  `clightgen` translates every function and global
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
the five checked integration, reduction, and conditional theorems.

Regenerate from a Git checkout containing the pinned commit:

```sh
SM64_SOURCE=/path/to/sm64 make regenerate
SM64_SOURCE=/path/to/sm64 make verify-generated
```

The pipeline exports the pinned commit with `git archive`, so uncommitted files
in the source checkout are not translated.  `verify-generated` hashes the
committed output, regenerates all 50 modules, and requires byte-for-byte
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
  trigger facts, while most lifecycle event names do not encode their full C
  effects.  The reduction theorem is constructor inversion, not a completed
  Clight-derived Layer A proof.
- Object origins, allocation epochs, the designated player/static-star
  references, trigger labels, and pool/list validity flags are handwritten
  ghost data.  Their concrete memory interpretation and preservation must be
  supplied by the missing refinement; none is an oracle conclusion about ROM
  reachability.
- No concrete `TargetLinkedProgram`, `ClightObservationProjection`, or
  `ClightFrameRefinementCertificate` is provided.  The link record asks for
  `linkorder` witnesses above all 25 units; it does not construct an iterated
  CompCert link.  `ImportedClightRun` is a finite `Smallstep.star` fragment and
  is not yet required to begin at `initial_state` or end at `final_state`.
- `WholeProgramClightRefinementObligation` and the strong, nonvacuous
  `CleanEntryProjectionCoverageObligation` are both open.  Until a concrete
  projection and certificate are proved, projected inputs, events, collision
  observations, and abstract states are uninterpreted functions.
- All three Layer B reachability propositions are open.  They are phrased over
  projected Float32 collision observations rather than an informal floor
  number, but completeness of that observation stream is itself part of the
  missing concrete refinement.
- `ArchivedProofIntegrationKernel` is a proved package of current-source facts
  and narrow route lemmas, but it proves neither
  `TargetClightRefinementObligation` nor any Layer B premise.  Building or
  auditing the six archives does not transfer their old capstones into the
  current theorem.
- The JP `gMarioPlatform` analysis currently classifies null, live,
  inactive, and reused slots with a ghost capture epoch.  It does not yet prove
  that the abstract slot/epoch was projected from the C pointer, which cases
  are reachable, or the displacement produced by every reachable payload.
- The raw initializer/constant checks support indices `2`, `5`, and `6`, but no
  proved decoder yet connects every relevant behavior-parameter bit pattern to
  the abstract `object_star_index` field.
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
- A model audit found a counterexample to an earlier, over-permissive Layer B
  formulation: a continuously held-A/no-edge input list could be paired with a
  handcrafted immediate overlap/collection step because inputs and events were
  unrelated.  This was an abstraction-only witness, not an actual ROM trace.
  The current obligations instead quantify over a projected Clight run and
  explicit collision observations, with event/observation coverage carried by
  its refinement certificate.  No actual US or JP ROM counterexample was found
  during source inspection; no exhaustive ROM reachability search was run.

The supplied A-press transcript was used only to identify candidate routes and
version-sensitive behavior.  The pinned source and formal definitions control
the claims.
