# Eyerok manipulation proof checklist

Last updated: 2026-07-14 (binary32 boundary proof).

## Current verdict

The refined handwritten relation bounds hand origins at 672/1467. The
Mario/Area 2 model proves that a hand floor itself cannot warp, that a selected
warp floor preserves Mario's state across Area 3 to Area 2, and that modeled
peak 2604 is too low for Y=2940 or higher route tiers. A conditional trace
lands at `(387,1967,-500)`. Authentic reachability of its starting hand pose is
still open. Literal unbounded finite binary32 Y is now disproved; authentic
dangerous-seed reachability and persistent control state remain open.

## Repository and source

- [x] Confirm repository and branch `codex/ssl-pyramid-item-proof`.
- [x] Keep work isolated in `SSL-Cog/eyerok-manipulation/`.
- [x] Register the project in `SSL-Cog/README.md`.
- [x] Pin canonical source revision `9921382a...`.
- [x] Record sibling checkout revision `36fbf8d6...` and audit equality.
- [x] Do not modify the existing pyramid proof.

## Clight and source audits

- [x] Generate pinned Eyerok behavior, object-motion, list-order, spawn,
  collision, and SSL script Clight.
- [x] Generate pinned area change, level update, Mario, airborne step,
  platform displacement, and interaction Clight.
- [x] Audit all 16 hand actions, positive velocity/gravity writers, finite
  ascent budgets, and the gravity-zero tripwire.
- [x] Audit the paired instant warps and exact Area 3 warp quad.
- [x] Audit Area 2 floor tiers and target star coordinates/hitbox.
- [x] Distinguish maximum collision vertex 896 from maximum upward-floor
  vertex 384.
- [x] Confirm platform displacement has no direct vertical velocity add.

## Vertical proof

- [x] Formalize the scheduler and exclude its grounded/gravity-zero seed.
- [x] Formalize finite ascent budgets and partial-update stuttering.
- [x] Refine support/ascent constants to 384 and 288.
- [x] Prove first/second hand-origin ceilings 672 and 1467.
- [x] Lift the invariant to all finite prefixes and infinite relation runs.
- [x] Keep original-game refinement explicit and conditional.
- [ ] Prove the coupled source-level seed invariant for every authentic frame,
  or provide a concrete counterexample trace.

## Mario and Area 2 proof

- [x] Represent Mario position, velocity, motion state, selected floor, and
  current area.
- [x] Prove hand-floor non-trigger and zero-displacement Area 3 to 2 entry.
- [x] Represent Area 2 Y=896, 1967, 2940, 4429, and 4815 thresholds.
- [x] Add hand collision top and modeled triple-jump rise to obtain peak 2604.
- [x] Prove peak 2604 cannot reach Y=2940 or higher audited tiers or directly
  collect the star.
- [x] Construct the conditional Y=1967 landing at the platform point closest
  to the star in X/Z.
- [x] State that an invariant upper bound is not an authentic reachability
  witness.
- [ ] Prove or refute the original game's ability to realize the starting hand
  pose and Mario launch.
- [ ] If required, optimize authentic remaining frames to star collection.

## Binary32 and original-game theorem

- [x] Prove every finite binary32 height stream is real-bounded.
- [x] Prove exact `Float32.add 2^31 100 = 2^31` and recurrence stagnation.
- [x] Record CompCert's undefined conversion at `2^31` without treating
  Clight stuckness as an original-ROM theorem.
- [ ] Add a linked whole-program Clight refinement.
- [ ] Add an IDO/MIPS correspondence boundary for a ROM-level claim.

## Verification and handoff

- [x] Use Ubuntu WSL and the `sm64-item-proof` opam switch.
- [x] Run reproducible generation after source-ingestion changes.
- [x] Compile the route proof modules with no proof holes.
- [x] Run the final complete `pipeline/check.sh` after binary32 integration.
- [x] Update `Eyerok.md`, project README, and all three planning documents.
- [ ] Do not push without explicit user approval.

## Commit ledger

- Scaffold and SSL-Cog registration.
- Pinned Eyerok source ingestion and Clight generation.
- Executable vertical C abstraction.
- Closed-world scheduler/vertical proof and explicit global boundary.
- Reproducible verification and plain-English scope clarification.
- Mario/Area 2 source ingestion.
- Refined 672/1467 height proof, floor-selected warp model, and conditional
  closest Y=1967 landing certificate.
- Finite-binary32 global bound, exact `2^31 + 100` fixed point, and explicit
  CompCert/ROM conversion boundary.
