# Eyerok manipulation proof checklist

Last updated: 2026-07-14 (Mario/Area 2 source-ingestion phase).

## Verdict

Closed only for the handwritten Rocq relations: the scheduler cannot reach the
runaway seed, and vertical-relation heights are at most 2003. The executable C
abstraction, original-game Clight, rank/update-order mapping, and Area 2 route
are not semantically connected to those results. The proved runaway recurrence
uses mathematical integers; it is not an unbounded binary32 or 32-bit C
execution.

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
- [x] Add an executable C abstraction and generate its Clight AST.
- [x] Generate the authentic `obj_behaviors_2.c` Clight AST containing Eyerok.
- [x] Generate the authentic object-motion helper after documented CompCert
  long-double literal compatibility edits.
- [x] Generate behavior dispatch, object-list order, spawn insertion,
  `find_floor`, and SSL-script Clight surfaces.
- [x] Audit the gravity-zero setup corridor against static and sibling dynamic
  collision geometry.
- [x] Generate pinned Clight for area change, instant-warp dispatch, Mario
  floor input, airborne stepping, platform displacement, and interactions.
- [x] Audit the exact Area 3 warp quad, the non-returning Area 2 counterpart,
  destination floor tiers, star platform, star coordinates, and interaction
  cylinder.

## Formal proof

- [x] Pin generated C-abstraction constants and source action/vertical-write
  shapes.
- [x] Formalize nondeterministic vertical choices and partial-update
  stuttering.
- [x] Prove grounded double-pound implies gravity at most `-15` and exclude the
  gravity-zero runaway seed from scheduler reachability.
- [x] Prove the one-step vertical invariant.
- [x] Lift the invariant to finite prefixes and infinite runs.
- [x] Prove the closed-world no-unbounded-rise capstone.
- [x] Prove the idealized mathematical-integer runaway recurrence grows
  without bound.
- [x] State the original-game-to-Rocq lifting boundary explicitly.
- [x] Explain in plain English that the abstract Rocq scheduler excludes the
  runaway seed but the corresponding whole-program game-code result remains
  open.
- [ ] Discharge authentic whole-program Clight execution refinement.
- [ ] Prove that the executable C abstraction implements `vertical_step`, or
  explicitly remove it from the semantic proof chain; its public calls can
  currently violate the Rocq launch precondition.
- [ ] Replace or justify the mathematical-integer height abstraction with a
  faithful relation to original-game binary32 position, including rounding
  stagnation and non-finite-value exclusions.
- [ ] Couple the scheduler and vertical abstractions to every relevant
  original-game controller, collision, and partial-update transition.
- [ ] Add the Mario/Area relation and prove the exact floor-selected warp rule
  with zero-displacement state preservation.
- [ ] Prove or refute direct reachability of each audited Area 2 landing tier;
  do not treat a hand-origin upper bound as an attainable Mario state.
- [ ] Prove the finite-binary32 non-unboundedness theorem and the exact
  `2^31 + 100 = 2^31` stagnation fact, keeping the Clight-to-ROM conversion
  boundary explicit.

## Verification and handoff

- [x] Run `make generated` in the Ubuntu `sm64-item-proof` switch.
- [x] Run `bash pipeline/check.sh` in the same switch.
- [x] Confirm generated artifacts reproduce exactly.
- [x] Confirm proof-hole grep is empty, the three core theorems are closed, and
  the combined authentic-AST capstone has only documented standard
  Coq/CompCert classical dependencies.
- [x] Keep `Eyerok.md`, all three planning docs, and project README current.
- [x] Distinguish absolute Y from home-relative rise and give worked impulse,
  runaway, and height-bound examples.
- [x] Record that an Area 2 transition is not representable in the vertical
  relation and that the real Mario/floor/instant-warp interaction is outside
  the current theorem.
- [x] Distinguish the C abstraction, abstract scheduler, and handwritten
  vertical relation, including the missing semantic links among them.
- [ ] If a route-level conclusion is required, model and prove whether Mario
  can use a raised hand to select the Area 3 warp floor at a useful height.
- [ ] Do not push without explicit user approval.

## Commit ledger

- Scaffold: standard project layout, proof boundary, state-machine overview,
  and SSL-Cog registration.
- Source ingestion: exact pinned top-level C extraction, authentic Clight ASTs,
  source/collision audit, and explicit gravity-zero counterexample tripwire.
- Executable C abstraction: source-shaped action constants, asymmetric
  hand-support ceilings, finite ascent budgets, safe-envelope check, and
  explicit runaway branch, translated by CompCert Clight.
- Closed-world proof: generated AST facts, scheduler unreachability, preserved
  height envelope, finite/infinite-run bounds, idealized Z runaway recurrence,
  and explicit original-game refinement boundary.
- Verification: reproducible generation, complete Ubuntu build, proof-hole
  rejection, and clean assumption reports for all public boundary theorems.
- Documentation clarification: plain-English state-machine guide, precise
  modeled-versus-original-game verdict, and explicit Area 2 transition scope.
