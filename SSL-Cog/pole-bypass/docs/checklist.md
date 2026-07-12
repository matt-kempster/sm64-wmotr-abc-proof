# SSL Pyramid pole-bypass checklist

Last updated: 2026-07-12 (global boundary interface commit).

Every commit must update this file and the other two files in `docs/`.

## Current verdict

The normalized closed-world pole route now has a machine-checked exact minimum
of one A press. The global gameplay verdict remains open until the model-
completeness bridge covers every bottom-reachable zero-A bypass state.

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
- [x] Audit the Area 2 collision mesh for the fifth-floor pole platform and
  sixth-floor hole.
- [x] Pin the pole placement `(0,3200,1331)`, parameter 92, hitbox height 920,
  effective top Y 4020, and upward-facing sixth-floor Y 3942.
- [x] Pin A-button mapping and the A/Z pole action branches in generated ASTs.

## Proof obligations

- [x] Define A-edge counting for the closed-world pole-route trace.
- [ ] Extend that count to an authentic complete bottom-to-sixth trace and
  prepared fifth-floor entry.
- [x] Prove the non-A `-2` soft-bonk exit cannot clear the hole before falling
  through the sixth-floor Y plane.
- [x] Prove the A-gated westward jump clears the hole and supplies a one-A
  witness.
  Use the conservative five-frame speed lower bound 22, not a constant-speed
  reading of the source's initial 24-unit minimum.
- [x] Prove the closed-world pole-route minimum-A capstone.
- [ ] Check capstone assumptions and reject proof holes.
- [ ] Either prove the global prepared-state model-completeness bridge or
  replace the global hypothesis with a concrete zero-A counterexample.
- [x] State the global lifting theorem with model completeness as an explicit
  premise, without adding an axiom for that premise.

## Commit receipts

- 2026-07-12: created the isolated scaffold and durable goal/claim/checklist;
  no proof verdict claimed.
- 2026-07-12: added the conservative C pole-route model, local CompCert 3.15
  generation wrapper, authentic source-unit targets, and committed generated
  Clight AST surface.
- 2026-07-12: added a deterministic source/collision audit and receipt. It
  verifies 1080 vertices, 1558 triangles, the exact fifth support and eight
  sixth-floor ring triangles, the 203-by-205 opening, source action/physics
  literals, pole push, and update order.
- 2026-07-12: added generated-AST shape facts, exact conservative pole-exit
  arithmetic, A-edge trace semantics, a zero-A invariant, a one-A westward
  witness, and the closed-world `pole_route_minimum_a_certificate` capstone.
- 2026-07-12: added `GlobalBoundary.v`, which machine-checks the reduction from
  the authentic global lower bound to the named bypass-model-completeness
  obligation and keeps that still-open premise visible.
