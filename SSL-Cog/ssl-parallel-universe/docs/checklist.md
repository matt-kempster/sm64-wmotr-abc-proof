# SSL Parallel Universe proof checklist

Last updated: 2026-07-17

Rule for Codex rounds: every commit that changes proof scope, proof code, or
build behavior must update this file in the same commit.

## Current verdict

The unqualified SSL Area 2 impossibility claim is false in the project's
source-shaped execution model. `proofs/BLJDynamic.v` now proves
`ssl_area2_grindel_dynamic_counterexample_certificate` for the vertical
Grindel at `(3297, 0, 95)`.

The finite route starts a normal `11`-speed long jump during the Grindel's
bottom wait. Sixteen generated-source air updates with full backward input
leave magnitude `8.4`; the first 10-unit rise catches quarter step 3. Nine
rising-floor BLJ recycles remain on the audited 448-unit top. The tenth long
jump leaves the top, and its four accepted static-floor quarter steps truncate
to X coordinates `3609`, `3726`, `3842`, and `3958`. The next target truncates
to `4074`, beyond the Area 2 static mesh, so the floor-null path freezes X
until landing.

Twenty subsequent out-of-bounds recycle targets have signed-16 aliases outside
the static mesh envelope. Target 21 reaches X `522262`, whose signed-16 alias
is `-2026`; that point lies in a concrete Area 2 floor triangle. The resulting
state is beyond the first PU threshold.

The theorem combines generated Clight AST shape checks, exact rational
arithmetic, and a source/mesh literal audit. It is not yet a full CompCert
operational-semantics proof of every float32 instruction and collision call.

The requested no-new-A subclaim is now proved under the same source/mesh
certificate boundary. `proofs/NoAPressed.v` proves
`ssl_area2_no_new_a_parallel_universe_certificate` for every per-frame
`INPUT_A_DOWN` schedule while `INPUT_A_PRESSED` remains clear. This includes
A-up, continuously held A, and held-then-released input.

The generated Clight facts pin the area-warp speed reset, edge-versus-held A
input distinction, fresh-A BLJ gate, C-up braking path, slope constants,
ordinary slide cap, held-A jump-kick initialization, and floor quarter steps.
The independent audit partitions all 32 very-slippery triangles into nine
finite components. Their largest certified path cost is `12368`, below the
`16384` budget. The resulting conservative speed bound is `1024`, hence an
accepted quarter step moves at most `256`; the first reusable static-floor
alias is at least `54630` units away. Floor-null steps freeze X/Z, and Area 2's
bounded dynamic horizontal writers remain local.

## Active next steps

- [x] Create the isolated `SSL-Coq/ssl-parallel-universe/` project scaffold.
- [x] Add the C model and generate the first Clight AST with `clightgen`.
  `generated/pu_model.v` was produced from `inputs/pu_model.c` by the local
  `pipeline/clightgen.sh` route.
- [x] Generate real movement-source Clight for `mario_step.c` and
  `platform_displacement.c`.
- [x] Prove generated-program shape facts for the step function and PU
  detector.
- [x] Prove the arithmetic invariant: bounded SSL area 2 positions stay below
  the first PU threshold.
- [x] State the capstone theorem, or replace it with a counterexample if the
  model admits one.
- [x] Audit generated movement-source ASTs for real position-writing paths.
- [x] Formalize the first counterexample-shaped source path outside the
  bounded-step certificate.
- [x] Lower the unbounded air-velocity counterexample to the generated-source
  BLJ recycle envelope.
- [x] Audit and formalize the first SSL Area 2 geometry/input certificate
  candidate for repeated BLJ recycles.
- [x] Refute the direct lower-entry static-stair certificate: it has only eight
  certified narrow treads, below the 22 recycles required by the BLJ envelope.
- [x] Prove a stronger dynamic collision certificate for repeated stair/wall
  reuse, find another Area 2 setup with enough initial speed/recycles, or close
  that route under source-backed bounds. The Area 2 vertical Grindel supplies
  the dynamic counterexample certificate.
- [x] Generate the additional real-source Clight needed for the dynamic
  Grindel candidate: airborne action updates, object/platform update ordering,
  and the canonical Grindel/Thwomp behavior.
- [x] Prove the finite Grindel bootstrap, nine in-footprint recycles, release,
  floor-null loops, and concrete PU-alias landing certificate.
- [x] Separate `INPUT_A_PRESSED = 0` from the older unqualified result and
  identify that the Grindel BLJ route is unavailable under that policy.
- [x] Add a reproducible authentic-US C-up fixture probe for all three Area 2
  very-slippery geometry families and confirm every recorded A input bit is
  clear.
- [x] Prove the source/mesh C-up speed bound, including fixed yaw, finite
  slippery components, and wall termination, and compare it with the first
  static-floor alias gap.
- [x] Audit all 18 `INPUT_A_DOWN` source occurrences and state the no-A
  capstone for an arbitrary A-down schedule, including continuously held A,
  A-up, and held-then-released input.
- [ ] Optional strengthening: connect the finite rational trace to a full
  CompCert execution semantics proof for the generated float32 Clight.

## Build and hygiene

- [x] Keep generated Clight files unedited.
- [x] Keep work isolated to this folder unless top-level build wiring becomes
  necessary.
- [x] Run `make proofs` and `bash pipeline/check.sh` when Rocq/Coq and
  CompCert are available.
- [x] Keep `Print Assumptions` output free of project-added axioms or admitted
  proof holes.
- [x] Do not push without explicit user approval.

## Done receipts

- 2026-07-03: Project scaffold, local build files, pipeline helpers, and docs
  created.
- 2026-07-03: Added the first C model for bounded SSL area 2 movement and PU
  detection.
- 2026-07-03: Generated the first CompCert Clight AST for the PU model.
- 2026-07-03: Added the empty proof-directory marker so `_CoqProject` path
  mapping is quiet before the first proof module.
- 2026-07-03: Added `ASTFacts.v`, `Spec.v`, and `ParallelUniverse.v`.
  The capstone `ssl_area2_no_parallel_universe` proves that the generated
  bounded-step model cannot reach a PU from an SSL area 2 bounded-state
  certificate.
- 2026-07-03: Tightened `pipeline/assumptions.sh` so it checks the local
  `SSLPU` logical paths with `coqc` and fails on import or assumption errors.
- 2026-07-03: Removed the proof-directory placeholder after adding real proof
  modules.
- 2026-07-03: Updated the assumptions-check cleanup trap to remove Coq's
  dotted temp `.aux` file.
- 2026-07-03: Extended `make clean` to remove generated/proof dotted `.aux`
  artifacts.
- 2026-07-03: Added generation targets for the real SM64 movement-source
  translation units `mario_step.c` and `platform_displacement.c`.
- 2026-07-03: Generated committed Clight for `mario_step.c` and
  `platform_displacement.c`.
- 2026-07-03: Added `MovementSourceFacts.v`, proving generated AST facts for
  air-step/platform-displacement position-writing paths and formalizing
  velocity/platform displacement counterexamples to the unqualified Area 2
  no-PU claim.
- 2026-07-03: Added generated `mario.c` and `mario_actions_moving.c` Clight
  targets plus `BLJRoute.v`. The new theorem
  `ssl_area2_blj_source_counterexample_envelope` packages generated-source BLJ
  shape facts with the arithmetic proof that 22 recycles supply the threshold
  air velocity.
- 2026-07-03: Updated the local `clightgen` wrapper to strip trailing
  horizontal whitespace from generated artifacts so regenerated Clight remains
  diff-clean.
- 2026-07-04: Added `pipeline/audit_area2_collision.py` and
  `BLJGeometry.v`. The new theorem
  `ssl_area2_lower_entry_geometry_input_status` packages the generated A/Z
  input-gate facts with the lower-entry stair-band mesh audit and proves that
  this direct static-tread certificate is too short for the 22-cycle BLJ
  envelope.
- 2026-07-12: Added Clight generation inputs for the dynamic Area 2 Grindel
  route. `inputs/grindel_behavior.c` is a translation shim over the canonical
  `thwomp.inc.c`; the build also generates `mario_actions_airborne.c` and
  `object_list_processor.c` so the next theorem can pin the rising-floor,
  drag, and update-order facts to generated ASTs.
- 2026-07-12: Added the independent Grindel source/mesh audit and
  `BLJDynamic.v`. The capstone
  `ssl_area2_grindel_dynamic_counterexample_certificate` proves the finite
  dynamic route described above and replaces the unqualified impossibility
  target with a concrete counterexample in the current model.
- 2026-07-17: Added the isolated Mupen C-up probe and six retail-US fixture
  runs. The probe enters Area 2 through the normal level machinery, uses only
  C-up after setup, records the retail action/floor state, and reports zero
  `INPUT_A_PRESSED` and `INPUT_A_DOWN` frames. The longest bottom-bevel run
  reaches magnitude `235.222733` before its wall terminates braking.
- 2026-07-17: Added generated Clight for `level_update.c`, the independent
  no-A source/mesh audit, and `NoAPressed.v`. The new capstone proves that a
  certified Area 2 execution with `INPUT_A_PRESSED = 0` cannot reach a PU for
  any A-down schedule. The proof covers all nine slippery components, the
  regular-slide cap, held-A branches, floor-null freezing, bounded dynamic
  writers, and the `54630`-unit first-alias gap.
