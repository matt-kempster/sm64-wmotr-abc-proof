# SSL Parallel Universe proof checklist

Last updated: 2026-07-03

Rule for Codex rounds: every commit that changes proof scope, proof code, or
build behavior must update this file in the same commit.

## Current verdict

The bounded-step impossibility theorem is not enough for the full Area 2
claim.

The generated real-source audit found movement-source paths that write Mario's
position outside the bounded certificate: `perform_air_step` reaches
`perform_air_quarter_step`, which assigns through `MarioState.pos`, and
`apply_mario_platform_displacement` reaches `set_mario_pos`, which writes the
same position field. A formal counterexample now shows that an unbounded
horizontal velocity or platform displacement can move a bounded Area 2 state to
the first PU threshold. This is not yet a full gameplay route proving that the
required velocity/displacement is reachable inside SSL Area 2.

## Active next steps

- [x] Create the isolated `ssl-parallel-universe/` project scaffold.
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
- [ ] Lower the counterexample from an unbounded source state to a reachable
  SSL Area 2 gameplay/glitch setup, or prove source-level bounds that rule it
  out.

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
