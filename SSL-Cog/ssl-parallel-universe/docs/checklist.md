# SSL Parallel Universe proof checklist

Last updated: 2026-07-04

Rule for Codex rounds: every commit that changes proof scope, proof code, or
build behavior must update this file in the same commit.

## Current verdict

The bounded-step impossibility theorem is not enough for the full Area 2
claim, and an unconditional source-level horizontal-speed bound is false for
the US source.

The generated real-source audit found movement-source paths that write Mario's
position outside the bounded certificate: `perform_air_step` reaches
`perform_air_quarter_step`, which assigns through `MarioState.pos`, and
`apply_mario_platform_displacement` reaches `set_mario_pos`, which writes the
same position field. A formal counterexample now shows that an unbounded
horizontal velocity or platform displacement can move a bounded Area 2 state to
the first PU threshold.

The next lowering found the source-level BLJ route envelope: the generated
`mario.c` AST contains the US long-jump branch that multiplies `forwardVel` by
`1.5f` and only caps positive speed at `48.0f`, and the generated
`mario_actions_moving.c` AST shows `act_long_jump_land` recycles through
`set_jumping_action` without directly resetting `forwardVel`. The formal model
proves that 22 repeated BLJ recycles from a `-16` speed magnitude can supply
the air-step velocity needed to cross from the negative Area 2 edge to the
first PU threshold. The remaining geometric obligation is a collision/input
certificate that SSL Area 2 supports those repeated recycles in-bounds.

The first geometry/input lowering is now checked in
`proofs/BLJGeometry.v`. The generated-source input gate is present:
`common_landing_cancels` checks `INPUT_A_PRESSED`, and
`act_long_jump_land` checks `INPUT_Z_DOWN` before preserving the A press path.
The audited lower-entry stair band provides concrete in-bounds static treads,
but only eight narrow same-footprint treads from the collision mesh. The formal
theorem `ssl_area2_lower_entry_geometry_input_status` proves that this static
tread certificate does not discharge the 22-recycle source-level BLJ envelope.
This refutes the direct lower-entry static-stair certificate, not every
possible dynamic wall/ceiling/stair-reuse setup.

## Active next steps

- [x] Create the isolated `SSL-Cog/ssl-parallel-universe/` project scaffold.
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
- [ ] Prove a stronger dynamic collision certificate for repeated stair/wall
  reuse, find another Area 2 setup with enough initial speed/recycles, or close
  that route under source-backed bounds.

## Build and hygiene

- [ ] Keep generated Clight files unedited.
- [ ] Keep work isolated to this folder unless top-level build wiring becomes
  necessary.
- [ ] Run `make proofs` and `bash pipeline/check.sh` when Rocq/Coq and
  CompCert are available.
- [ ] Keep `Print Assumptions` output free of project-added axioms or admitted
  proof holes.
- [ ] Do not push without explicit user approval.

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
