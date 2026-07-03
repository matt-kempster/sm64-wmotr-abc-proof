# SSL Parallel Universe proof checklist

Last updated: 2026-07-03

Rule for Codex rounds: every commit that changes proof scope, proof code, or
build behavior must update this file in the same commit.

## Current verdict

No counterexample is known yet.

The working proof route is an impossibility theorem for normal SSL area 2 play
under a concrete bounded-position invariant. The model must stay honest about
the actual PU mechanism: SM64 collision queries cast positions to `s16`, and
large float positions can therefore alias lower coordinate cells.

## Active next steps

- [x] Create the isolated `ssl-parallel-universe/` project scaffold.
- [ ] Add the C model and generate the first Clight AST with `clightgen`.
- [ ] Prove generated-program shape facts for the step function and PU
  detector.
- [ ] Prove the arithmetic invariant: bounded SSL area 2 positions stay below
  the first PU threshold.
- [ ] State the capstone theorem, or replace it with a counterexample if the
  model admits one.

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
