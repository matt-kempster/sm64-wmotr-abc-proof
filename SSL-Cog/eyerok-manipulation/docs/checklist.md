# Eyerok manipulation proof checklist

Last updated: 2026-07-12 (executable vertical-model commit).

## Verdict

Open. Pinned source ingestion and collision/source auditing are reproducible.
The gravity-zero runaway seed is isolated; its unreachability and the global
height bound remain to be machine-checked.

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

- [ ] Pin generated model constants and source action/vertical-write shapes.
- [ ] Formalize adversarial action choices and partial updates.
- [ ] Prove the one-step vertical invariant.
- [ ] Lift the invariant to finite prefixes and infinite runs.
- [ ] Prove the no-unbounded-rise capstone without project-added assumptions.
- [ ] State the authentic source-to-model lifting boundary explicitly.

## Verification and handoff

- [ ] Run `make generated` in the Ubuntu `sm64-item-proof` switch.
- [ ] Run `bash pipeline/check.sh` in the same switch.
- [ ] Confirm generated artifacts reproduce exactly.
- [ ] Confirm proof-hole grep is empty and `Print Assumptions` is clean.
- [ ] Keep `Eyerok.md`, all three planning docs, and project README current.
- [ ] Do not push without explicit user approval.

## Commit ledger

- Scaffold: standard project layout, proof boundary, state-machine overview,
  and SSL-Cog registration.
- Source ingestion: exact pinned top-level C extraction, authentic Clight ASTs,
  source/collision audit, and explicit gravity-zero counterexample tripwire.
- Executable model: source-shaped action constants, asymmetric hand-support
  ceilings, finite ascent budgets, safe-envelope check, and explicit runaway
  branch, translated by CompCert Clight.
