# Goal recovery note

This file backs up the active objective for the SSL Parallel Universe proof.
If app-level goal state is lost, recreate it from this note rather than relying
on memory.

## Active objective

Build a formal Rocq/Coq + CompCert `clightgen` proof, following the structure
of `ssl-pyramid-item-proof`, for SSL area 2 parallel-universe impossibility:

- prove that Mario cannot enter a parallel universe in normal SSL area 2 play
  under the mechanized bounds and transition model; or
- if that claim is false, provide a concrete counterexample.

## Working proof route

```text
source C model
  -> CompCert clightgen-generated Clight AST
  -> generated-program shape facts
  -> arithmetic invariant over SSL area 2 positions
  -> no-PU capstone theorem
```

The first source model is `inputs/pu_model.c`. It models only the bounded
normal SSL area 2 transition certificate, not the full SM64 movement engine.
The current capstone theorem is
`SSLPU.Proofs.ParallelUniverse.ssl_area2_no_parallel_universe`.

The active frontier is now the real movement-source boundary. The generated
AST audit proves that `mario_step.c` and `platform_displacement.c` contain
position-writing paths outside the bounded-step clamp, and
`SSLPU.Proofs.MovementSourceFacts.bounded_certificate_does_not_cover_movement_sources`
packages formal counterexamples for unbounded horizontal air velocity and
platform displacement.

## Repository workflow constraints

- Work on branch `codex/ssl-pyramid-item-proof` in the proof repository.
- Keep all new work inside `ssl-parallel-universe/` unless minimal build wiring
  outside the folder is required.
- Do not modify `ssl-pyramid-item-proof/` contents except to inspect and mirror
  structure.
- Commit after each logical change, and update docs in every commit.
- Do not push without explicit user approval.
