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

The air-velocity branch has been lowered to the generated-source BLJ envelope:
`SSLPU.Proofs.BLJRoute.ssl_area2_blj_source_counterexample_envelope` proves
that the US long-jump source admits negative-speed growth and that 22 repeated
recycles can supply the velocity needed to reach the first PU threshold from
the negative Area 2 edge. The remaining open obligation is geometry/input
reachability for those recycles inside SSL Area 2.

The first geometry/input lowering is now
`SSLPU.Proofs.BLJGeometry.ssl_area2_lower_entry_geometry_input_status`. It
proves generated-source A/Z landing-gate facts and records the lower-entry
Area 2 stair band as concrete in-bounds static treads. That certificate is
formally too short: it has capacity 8, below the 22 BLJ recycles required by
the current source-level envelope. This refutes the direct lower-entry
static-stair route. The next frontier is dynamic repeated reuse of the same
collision setup, another Area 2 setup with a higher starting speed or more
certified recycles, or source-backed bounds ruling those out.

## Repository workflow constraints

- Work on branch `codex/ssl-pyramid-item-proof` in the proof repository.
- Keep all new work inside `ssl-parallel-universe/` unless minimal build wiring
  outside the folder is required.
- Do not modify `ssl-pyramid-item-proof/` contents except to inspect and mirror
  structure.
- Commit after each logical change, and update docs in every commit.
- Do not push without explicit user approval.
