# SSL Pyramid pole-bypass checklist

Last updated: 2026-07-12 (Clight model and generation commit).

Every commit must update this file and the other two files in `docs/`.

## Current verdict

Open. The project now contains an executable conservative pole-route model and
an isolated `clightgen` pipeline. Machine-checked proof modules are next.

## Project setup

- [x] Create `SSL-Cog/pole-bypass/` with the standard project layout.
- [x] Record the preparation quantifier and zero-A counting convention.
- [x] Record toolchain, source baseline, and local generation checkout.
- [x] Add the isolated Clight generation pipeline.
- [ ] Add the end-to-end proof/check pipeline.
- [ ] Update `SSL-Cog/README.md` after the project is buildable.

## Source and geometry certificates

- [x] Generate the small pole-route C model with CompCert `clightgen`.
- [x] Generate authentic Clight for the SSL level script, pole behavior,
  automatic pole actions, input/action setup, interaction, airborne action,
  and air-step source units.
- [ ] Audit the Area 2 collision mesh for the fifth-floor pole platform and
  sixth-floor hole.
- [ ] Pin the pole placement `(0,3200,1331)`, parameter 92, hitbox height 920,
  effective top Y 4020, and upward-facing sixth-floor Y 3942.
- [ ] Pin A-button mapping and the A/Z pole action branches in generated ASTs.

## Proof obligations

- [ ] Define complete-trace A-press counting and prepared fifth-floor entry.
- [ ] Prove the non-A `-2` soft-bonk exit cannot clear the hole before falling
  through the sixth-floor Y plane.
- [ ] Prove the A-gated jump clears the hole and supplies a one-A witness.
  Use the conservative five-frame speed lower bound 22, not a constant-speed
  reading of the source's initial 24-unit minimum.
- [ ] Prove the closed-world pole-route minimum-A capstone.
- [ ] Check capstone assumptions and reject proof holes.
- [ ] Either prove the global prepared-state model-completeness bridge or
  replace the global hypothesis with a concrete zero-A counterexample.

## Commit receipts

- 2026-07-12: created the isolated scaffold and durable goal/claim/checklist;
  no proof verdict claimed.
- 2026-07-12: added the conservative C pole-route model, local CompCert 3.15
  generation wrapper, authentic source-unit targets, and committed generated
  Clight AST surface.
