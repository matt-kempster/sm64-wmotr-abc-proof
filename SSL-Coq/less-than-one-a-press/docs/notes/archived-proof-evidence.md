# Archived proof evidence and limits

This document records how the six archived proof projects bear on the current
`less-than-one-a-press` claim. It is an evidence map, not a composition theorem.

## Trust and transfer policy

The current project does **not** trust or import any archived Rocq namespace,
archived generated Clight AST, or archived source-shape certificate. In
particular, compiling an archived project does not make one of its theorems a
premise of the current theorem. Any fact that is needed by the current proof
must be reproved against the current project's generated US and JP Clight at
decomp revision `9921382a68bb0c865e5e45eb594d9c64db59b1af`, or connected to it
by an explicit checked refinement theorem.

The archived theorems are useful as candidate lemmas, counterexample warnings,
source-audit guides, and specifications for narrower bridge obligations. Their
old generated files remain historical evidence only.

## What is incorporated now

`proofs/ArchivedProofIntegration.v` proves
`archived_proof_integration_kernel_holds` entirely in the current namespace.
Its six fields are re-established from current-revision US/JP Clight checks,
the current finite-width input semantics, narrow route subcase lemmas, and a
revision-neutral CompCert memory-separation lemma. No archived generated module
is imported.

The current generator now translates 31 units for each target version (62
generated modules total), including the Mario action files,
`mario_actions_cutscene.c`, `mario_step.c`, `obj_behaviors_2.c`,
`math_util.c`, `surface_collision.c`, `surface_load.c`, and a wrapper importing
the route-relevant SSL static and dynamic collision arrays. The integration
kernel is a checked evidence
bundle, not a linked-Clight-to-`CertifiedExecution` bridge and not a proof of
any entrance reachability obligation.

The current entrance obligations quantify over an explicit projected stream of
collision observations, and a refinement certificate must include target
collection/trigger phases in that stream.  No concrete projection or
all-relevant-phase completeness proof exists yet.  The certified-event
reduction itself is constructor inversion: the event constructors assume the
origin, collision, save-bit, trigger, and successor-validity facts they expose.

`FirstTargetRefinement.v` now gives route classification an evidence-bearing
shape: actual Clight states and trace segments, exact indexed certified steps,
a total event-writer inventory, and `CollisionSupportCut` crossings.  It
eliminates several causes only within the certified semantics.  It does not
construct that evidence from a linked run, close the remaining movement
classes, or prove `FirstTargetCutClassificationObligation`.

## Evidence matrix

| Archived project | Recorded source and version boundary | Strongest relevant checked results | Bearing on the current claim | Boundary: what it does **not** establish | Integration disposition |
| --- | --- | --- | --- | --- | --- |
| `ssl-spawning-displacement-proof` | Original Japanese, `VERSION_JP=1`; its archived documentation does not record an exact decomp commit. That omission prevents treating its generated AST as pinned to the current revision. | `ssl_area2_all_first_update_platform_displacements_stay_in_elevator_shaft` and `ssl_area2_all_first_update_platform_displacements_do_not_reach_cage_top` in `old-proofs/ssl-spawning-displacement-proof/proofs/TargetPlatformEffects.v`; `no_closed_world_ssl_spawning_displacement_route_to_spindel` in `proofs/ClosedWorldDisproof.v`; conditional generated-AST/source-certificate theorem `generated_jp_clight_concrete_spindel_depth_capstone` in `proofs/ClightCapstone.v`. | Identifies the JP-only retained-`gMarioPlatform` hazard that the upper-entrance Layer B proof must cover. Its finite **area-2 replacement-object** enumeration remains useful, but it does not cover the separate inactive, unreused pyramid-top payload. Replaying the same raw transform payload at the current Area-2 boundary moves Mario outside the shaft and permits no-A upper-trigger consumption. Its seed analysis also narrows several ordinary area-1 platform-overlap routes. | The Clight capstone is conditional on a stale slot, exact free-list depth, and handwritten state/model hypotheses. The closed-world theorem covers only enumerated seed mechanisms. It neither proves that all authentic JP platform payloads are covered nor supplies a whole-game execution refinement. No stock predecessor has been established for the boundary-fixture trigger witness; warp-to-top, top-to-warp, and collision-preserving clone constructions remain open. It says nothing about US upper-entry behavior or lower-entry reachability. | Incorporated: the abstract model uses a slot plus ghost capture epoch and proves null/live/inactive/reused cases under slot well-formedness. Current US/JP AST checks establish a `gMarioPlatform` identifier occurrence, a direct displacement call, and absence of three validation-field identifiers in that function body; they do not prove dereference dataflow or validation absence in callees. The evidence-bearing prelude keeps Area-1 node `0x1E` capture/unload/reuse separate from the Area-2 displacement cut. The C-pointer projection, stock predecessor, all-payload classification, and all-frame Float32/reachability bridge remain pending. Status: a real fixture-reachable bypass mechanism and useful bounded negative subcases, but no stock Layer B discharge. |
| `ssl-pyramid-item-proof` | North American, `VERSION_US=1`; n64decomp/sm64 `9921382a68bb0c865e5e45eb594d9c64db59b1af`; CompCert PPC32 big-endian translation with `NON_MATCHING=1`, `AVOID_UB=1`, and `TARGET_N64=1`. | `ssl_pyramid_no_gameplay_usable_outside_item_entry` and the more explicit `certified_pyramid_transition_forbids_gameplay_usable_item_transfer` in `old-proofs/ssl-pyramid-item-proof/proofs/PyramidTransition.v`. The underlying project also contains CompCert memory lemmas for the generated `unload_object` prefix and object-pool layout. | Supplies the right allocation-epoch distinction: an area-1 object that is deactivated and whose slot is later reused is not the same live object in area 2. This is directly relevant to Layer A's deletion, slot-reuse, area unload/reload, and stale-reference accounting. | The capstone assumes a `pyramid_transition_certificate`, including a `valid_deactivation_trace`; it does not derive that certificate from the linked gameplay call chain. The archived project itself lists cleanup-tail, traversal, field-stability, and reachability obligations. It is US-only and does not prove target-star provenance, hidden-star spawning, interaction timing, or either no-A collision exclusion. | Incorporated: current US/JP AST checks establish direct-call order in `change_area` plus `_next` and `unload_object` occurrences in the unload body; they do not prove traversal execution. `fresh_slot_reuse_is_not_object_identity` makes the allocation-epoch distinction explicit. End-to-end unload-loop execution and the bridge to `CertifiedExecution` remain pending. Status: strong Layer A blueprint, but no whole-program Layer A discharge and no Layer B result. |
| `ssl-parallel-universe` | North American, `VERSION_US=1`; the archive says only that its source is from the same source family as `ssl-pyramid-item-proof` and records no exact commit. | `ssl_area2_no_new_a_parallel_universe_certificate` in `old-proofs/ssl-parallel-universe/proofs/NoAPressed.v`; the same project proves `bounded_certificate_does_not_cover_movement_sources`, plus concrete broad-model witnesses `unclamped_air_velocity_source_can_enter_parallel_universe` and `platform_displacement_source_can_enter_parallel_universe`, in `proofs/MovementSourceFacts.v`. | Correctly distinguishes `INPUT_A_PRESSED` from held A and covers A-up and continuously held-A schedules in its policy model. Under its source/mesh and bounded-writer certificate, it rules out a first parallel-universe transition. The counterexamples are important warnings that a position clamp cannot silently stand for every movement source. | `certified_no_a_area2_execution` is a compact transition system, not a proved simulation of all retail frame execution. The bounded certificate excludes movement sources that the companion file demonstrates can cross the threshold in the broader model. It is US-only, has no exact source pin, and does not prove that Mario cannot reach either target hitbox without entering a parallel universe. | Incorporated: held-A schedules use the current finite-width edge semantics, selected movement source shapes are checked in current US/JP Clight, and the bounded static alias-period lemma is re-proved with its hypotheses exposed. Writer coverage and the concrete execution bridge remain open. “No parallel universe” is not used as a substitute for target-region unreachability. Status: useful no-A semantic pattern and counterexample guardrail, no Layer A or Layer B discharge. |
| `pole-bypass` | North American, `VERSION_US=1`; canonical source baseline `9921382a68bb0c865e5e45eb594d9c64db59b1af`. The archive records generation from checkout `36fbf8d693a9fc2bdec0c77402f8e96d07d2f461` with an audit that the relevant pole, Mario-action, and area-2 collision files match the baseline. | `pole_route_minimum_a_certificate` in `old-proofs/pole-bypass/proofs/PoleBypass.v` proves that every modeled `NormalizedPole` trace reaching `SixthFloor` has at least one A edge and gives a one-A witness. `global_lower_bound_from_bypass_model_complete` in `proofs/GlobalBoundary.v` states the authentic lift, explicitly conditional on `bypass_model_complete`. | Rules out zero-A traversal for the ordinary normalized fifth-floor-pole transition system and makes the missing global bridge precise. This is useful for decomposing the lower-entrance Layer B search into the pole route versus all bypasses and prepared-state entries. | `bypass_model_complete` is not proved. Arbitrary bottom-reachable routes, pole avoidance, prepared velocity/action states, object or platform displacement, collision-phase timing, and JP behavior are outside the local certificate. Reaching the sixth floor is also not identical to overlapping either target interaction region. | Incorporated: selected pole/action/gravity source shapes are checked against current US/JP Clight, and the normalized soft-bonk arithmetic lemma is re-proved as a restricted integer subcase. Bypass completeness, Float32 geometry, and collision-region mapping remain open. Status: narrow Layer B evidence, no complete Layer B proof and no Layer A content. |
| `eyerok-manipulation` | Canonical revision `9921382a68bb0c865e5e45eb594d9c64db59b1af`; covers shared source plus `VERSION_US=1` and original `VERSION_JP=1` area/platform behavior. The archive also records a source-equivalence audit from checkout `36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`. | `eyerok_no_unbounded_rise_certificate` in `old-proofs/eyerok-manipulation/proofs/EyerokManipulation.v`; the more target-specific `eyerok_area2_route_certificate` in `proofs/RouteCertificate.v`, including modeled second-hand surface ceiling `1974`, modeled Mario peak `2604`, and exclusion of the upper arrival platform and Act 3 star within that route model. `authentic_no_unbounded_rise_from_refinement` in `proofs/GlobalBoundary.v` exposes the missing authentic-refinement premise. | Substantial negative evidence against the proposed Eyerok height-amplification family. It also identifies a real US/JP split for cached platform state and records why an area-3 hand floor does not itself trigger the area-2 instant warp in the route model. These cases should be represented in Layer B completeness analysis. | The main certificate packages many handwritten relations and generated source-shape checks; it is not a linked CompCert execution refinement. The finite height bound is for a selected Eyerok lifecycle/route model, not every particle, stale-slot, prepared-speed, partial-update, collision, or memory-corruption technique. Its conditional positive mid-tier route is not a no-A target-star route. | Incorporated: selected Eyerok lifecycle call shape, held-A edge semantics, and US/JP platform recomputation facts are rechecked in the current project. The archived height envelope and route model are not imported; their concrete refinement and completeness premises remain open. Status: route-family evidence for Layer B case analysis, but no Layer B discharge and no target-star Layer A proof. |
| `demo-warp` | North American, `VERSION_US=1`; decomp revision `36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`, which is **not** the current project's pinned revision. | `demo_timer_mario_y_counterexample_capstone` and `unconditional_no_matching_byte_store_is_false` in `old-proofs/demo-warp/proofs/Counterexample.v`; `normal_initialization_forbids_demo_pointer_mario_y_alias` and `normal_initialization_refutes_alias_reachability` in `proofs/NormalInitialization.v`. | Demonstrates the required counterexample discipline: a generated byte store really can modify Mario Y under an aliasing precondition, while a separate normal-initialization model forbids that alias. It is a warning that memory provenance must be proved rather than assumed when excluding demo/input-corruption routes. | The positive witness is a local store/alias witness, not a reachable game trace. The normal-initialization result combines static AST facts, linker/ROM receipts, and an arithmetic state model rather than a whole-program Clight reachability proof. It uses a different revision, is US-only, and has no direct theorem about star provenance or either Pyramid collision region. | Incorporated: `changed_load_after_store_requires_same_block` captures the revision-neutral CompCert memory-separation kernel without importing the different-revision AST. No demo pointer is connected to the current game state, so this remains methodology only and offers no direct Layer A or Layer B support. |

### Retained-platform caution

The spawning-displacement archive does not rule out every source prehistory for
a stale pyramid-top pointer.  The current abstract model admits an inactive
pyramid-top payload whose source-shaped yaw displacement exits the upper
shaft, but no stock-reachable predecessor trace reaching a target region has
been established.  The current `PyramidTopPU.v` audit proves the same-sample
arithmetic contradiction and conditionally excludes a Y-preserving stock-yaw
bootstrap; matrix, dynamic-surface, and Clight refinements remain open.  Its
separate two-sample coordinate model shows that the archive's old
same-coordinate argument cannot exclude a different three-dimensional
State/Object phase arrangement.  Such a split still needs a gameplay-reachable
writer, live-surface selection, and (for the retained-pointer construction) JP
pointer retention or recapture through the delayed node-`0x1E` warp.  The US
spawn clear blocks same-epoch retention in the state model, but its Clight
memory effect remains to be derived.

In particular, the archive's ordinary-position and enumerated seed results do
not prove impossible a setup that moves or loads the upper warp onto the
spinning top, moves the top to the warp, creates a collision-preserving clone,
or uses a distinct stale/reused transform while the top collision is loaded.
A future source-backed predecessor proof must track collision-object and
geometry-State samples separately, pointer capture, unload, slot epoch/reuse,
the delayed-warp lifetime, and the first area-2 displacement.  It must preserve
these conditional routes for analysis rather than assume the pointer is null
or safe.

## Cross-project verdict

None of the six archived projects discharges the current Layer A
whole-program refinement from generated Clight executions to the project's
collection/provenance transition relation. None proves either Layer B
collision-observation exclusion: no-A non-overlap with the Act 3 star
interaction region or no-A non-overlap with the upper hidden-star trigger,
from both clean lower and clean upper entries, for both US and JP. Completeness
of the concrete collision-observation projection is also unproved.

The strongest legitimate use of the archive is therefore:

1. `ssl-pyramid-item-proof` supplies the allocation-epoch and unload proof
   shape needed by Layer A.
2. `ssl-spawning-displacement-proof`, `ssl-parallel-universe`, `pole-bypass`,
   and `eyerok-manipulation` enumerate important Layer B route families and
   expose their own completeness boundaries.
3. `demo-warp` supplies a concrete warning about aliasing and the correct
   separation between a local counterexample and reachable normal execution.

Selected kernels have now been regenerated or reproved in the current project.
They remain supporting evidence because the checked semantic bridges and route
completeness theorems are still missing. They must not be cited as completing
the ultimate fewer-than-one-A-press impossibility theorem.

The strengthened first-target theorem makes that relationship explicit:
spawning displacement, object/lifecycle transfer, parallel-universe movement,
pole avoidance, area-3/Eyerok travel, and memory aliasing land in named bypass
constructors.  The archived results narrow selected constructors or expose
their hazards.  The new evidence-bearing interface has proved the zero-offset
instant-warp, invalid-provenance/lifecycle, coherent-save-reload, and
projection-mismatch eliminations only within the certified semantics.  None
of the archives constructs the Clight evidence for every first target access,
excludes every remaining writer class from a clean US/JP entry, or proves the
lower target-side collision-support cut.  See
[`route-exhaustiveness.md`](route-exhaustiveness.md) for that finite case split.
