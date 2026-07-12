# Eyerok manipulation proof checklist

Last updated: 2026-07-12 (verified end-to-end proof commit).

## Verdict

Closed for the source-shaped adversarial model: the runaway seed is
unreachable and all modeled heights are at most 2003. Whole-program Clight
execution refinement remains open and is stated explicitly.

## Completed

- [x] Confirm the actual repository and branch:
  `codex/ssl-pyramid-item-proof` at `08d84db` before this project.
- [x] Mirror the standard SSL-Cog project structure.
- [x] Pin canonical source revision `9921382a...` and record the available
  sibling checkout mismatch instead of assuming equality.
- [x] Record the 16 Eyerok hand actions and the player-influence surface.
- [x] Add the project to `SSL-Cog/README.md`.

## Source and generation

- [x] Audit relevant files at the canonical revision and compare the available
  checkout byte-for-byte where it is used for generation.
- [x] Audit both paired instant warps and their special collision triangles.
- [x] Add an executable vertical model and generate its Clight AST.
- [x] Generate the authentic `obj_behaviors_2.c` Clight AST containing Eyerok.
- [x] Generate the authentic object-motion helper after documented CompCert
  long-double literal compatibility edits.
- [x] Generate behavior dispatch, object-list order, spawn insertion,
  `find_floor`, and SSL-script Clight surfaces.
- [x] Audit the gravity-zero setup corridor against static and sibling dynamic
  collision geometry.

## Formal proof

- [x] Pin generated model constants and source action/vertical-write shapes.
- [x] Formalize adversarial action choices and partial-update stuttering.
- [x] Prove grounded double-pound implies gravity at most `-15` and exclude the
  gravity-zero runaway seed from scheduler reachability.
- [x] Prove the one-step vertical invariant.
- [x] Lift the invariant to finite prefixes and infinite runs.
- [x] Prove the closed-world no-unbounded-rise capstone.
- [x] Prove the counterfactual runaway seed grows without bound.
- [x] State the authentic source-to-model lifting boundary explicitly.
- [ ] Discharge authentic whole-program Clight execution refinement.

## Verification and handoff

- [x] Run `make generated` in the Ubuntu `sm64-item-proof` switch.
- [x] Run `bash pipeline/check.sh` in the same switch.
- [x] Confirm generated artifacts reproduce exactly.
- [x] Confirm proof-hole grep is empty, the three core theorems are closed, and
  the combined authentic-AST capstone has only documented standard
  Coq/CompCert classical dependencies.
- [x] Keep `Eyerok.md`, all three planning docs, and project README current.
- [ ] Do not push without explicit user approval.

## Commit ledger

- Scaffold: standard project layout, proof boundary, state-machine overview,
  and SSL-Cog registration.
- Source ingestion: exact pinned top-level C extraction, authentic Clight ASTs,
  source/collision audit, and explicit gravity-zero counterexample tripwire.
- Executable model: source-shaped action constants, asymmetric hand-support
  ceilings, finite ascent budgets, safe-envelope check, and explicit runaway
  branch, translated by CompCert Clight.
- Closed-world proof: generated AST facts, scheduler unreachability, preserved
  height envelope, finite/infinite-run bounds, runaway lasso, and explicit
  authentic-refinement boundary.
- Verification: reproducible generation, complete Ubuntu build, proof-hole
  rejection, and clean assumption reports for all public boundary theorems.
