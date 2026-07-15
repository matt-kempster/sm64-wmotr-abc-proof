# Eyerok manipulation proof checklist

Last updated: 2026-07-14 (conditional lower Area 2 landing).

## Current verdict

The geometry-relaxed handwritten relation bounds hand origins at 672/1467. Its
Mario/Area 2 model proves that a hand floor itself cannot warp, that a selected
warp floor preserves Mario's state across Area 3 to Area 2, and that its old
modeled peak 2604 is too low for Y=2940 or higher route tiers. Its conditional
trace lands at `(387,1967,-500)`, but the new two-hand barrier refutes the
starting hand pose. The
audited source-shaped kernel now excludes the dangerous repeated-launch seed
for arbitrary A input, no A, and held A inside the abstraction. A
counterfactual origin Y=3627 route would reach the star platform, but the
stricter two-hand origin ceiling is Y=672.
Literal unbounded finite binary32 Y is also disproved. Linked Clight/ROM
refinement and route optimality remain open.

The source-shaped first-hand barrier is stricter: the arena floor maximum
is -1150, the tunnel floor minimum is -562, and the first hand's full finite
rise reaches only origin -862 and open surface -355. Rocq proves that it cannot
query the tunnel or reach the legacy first-surface milestone 1179. The
two-hand barrier grants every static floor and every possible first-hand
contact; dynamic support -355 is still below static maximum 384. It proves
second origin <=672, second surface <=1179, and generously modeled Mario peak
<=1809. Thus 1467/1974/2604 and the Y=1967 floor-query threshold 1889 are
unreachable in this source-shaped relation.

A new conditional certificate assumes equality at surface ceiling 1179 and
the full 630-unit triple-jump envelope. It enters Area 2 at
`(0,1809,-1024)`, reaches `(0,1281,-832)` with vertical velocity -67, and
uses an exact quarter-step query `(0,1264,-829)` that the pinned audit resolves
to floor Y=1280. The handwritten landing relation snaps to that floor. This
does not authenticate either ceiling equality, moving off the dynamic hand to
select the static warp, the original controller inputs, or all intervening C
collision steps. Surface Y=1179 without another impulse misses the Y=1280
query threshold by 23.

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
- [x] Audit four airborne quarter steps, the fresh quarter-step floor query,
  TerrainData Y cast, landing snap, and 78-unit floor buffer.
- [x] Parse Area 2 upward triangles and verify exact selected-floor heights at
  the lower Y=1280 and upper-route quarter-steps, star-platform landing, and
  every modeled ground-reposition point.
- [x] Distinguish maximum collision vertex 896 from maximum upward-floor
  vertex 384.
- [x] Confirm platform displacement has no direct vertical velocity add.
- [x] Audit strict ground comparison and equality clearing both ground flags.
- [x] Audit exact gravity-writer sequence, collision-pointer writers, room
  default, bounciness, and movement partial-update guards; keep the lifecycle
  exclusion labeled as a manual source argument.
- [x] Audit hand spawn/append/update order and dynamic-surface clearing.
- [x] Audit the Area 3 local object/macro set, absence of water, begin-double
  corridor floors, closed-hand radius, and positioning constants; reject the
  old 280-unit mixed-frame calculation as a global separation invariant.
- [x] Partition every upward Area 3 triangle into arena (maximum Y=-1150) and
  tunnel (minimum Y=-562), and prove that no triangle crosses the gap.
- [x] Audit the open/closed upward collision tops, scale transform, and the
  25/40-frame attacked/death animation lengths.
- [x] Audit controller A-edge calculation, INPUT_A_PRESSED/INPUT_A_DOWN,
  backflip's fresh-A gate, direct platform X/Z-only velocity displacement,
  hitbox separation, and ordinary bounce placement.
- [x] Audit the held-A `INPUT_A_DOWN` punch-to-jump-kick gates so no-edge is
  not misreported as behaviorally inert input.
- [x] Audit the no-A B-only speed-kick dive and the fresh-edge triple-jump
  chain; prove the triple-jump/backflip rise envelopes are 630/512.

## Vertical proof

- [x] Formalize the scheduler and exclude its grounded/gravity-zero seed.
- [x] Formalize finite ascent budgets and partial-update stuttering.
- [x] Refine support/ascent constants to 384 and 288.
- [x] Prove first/second hand-origin ceilings 672 and 1467.
- [x] Lift the invariant to all finite prefixes and infinite relation runs.
- [x] Keep original-game refinement explicit and conditional.
- [x] Prove the executable audited source-shaped seed invariant for every
  modeled event sequence.
- [x] Compute the start-double ground bit through the strict floor comparison
  rather than assigning the invariant's desired result.
- [x] Couple the kernel and vertical relation so a reachable seed would enable
  an explicit runaway transition and invalidate the height bound.
- [x] Quantify the seed and useful-height results over arbitrary A input, with
  explicit never-A and continuously-held-A corollaries; keep A documented as
  a hand-insensitive ghost input, not an ABC press counter.
- [ ] Prove every linked whole-program Clight frame refines the source-shaped
  kernel, or provide a concrete counterexample trace.
- [x] Prove the source-shaped first-hand origin ceiling -862, tunnel-query
  impossibility, open-surface ceiling -355, and failure of milestone 1179.
- [x] Prove that even granting all X/Z overlap, phase meshes, and first-hand
  contact, dynamic support cannot exceed the static support ceiling; derive
  second origin 672 and surface 1179.
- [x] Refute legacy second origin 1467, second surface 1974, modeled Mario
  2604, and modeled selection of the Area 2 Y=1967 floor.
- [ ] Prove the event-by-event linked Clight finite-episode premise, including
  no airborne replenishment and the source phase reset before another launch.

## Mario and Area 2 proof

- [x] Represent Mario position, velocity, motion state, selected floor, and
  current area.
- [x] Prove hand-floor non-trigger and zero-displacement Area 3 to 2 entry.
- [x] Represent Area 2 Y=896, 1280, 1967, 2940, 4429, and 4815 thresholds.
- [x] Add hand collision top and modeled triple-jump rise to obtain peak 2604.
- [x] Prove peak 2604 cannot reach Y=2940 or higher audited tiers or directly
  collect the star.
- [x] Construct the conditional Y=1967 landing at the platform point closest
  to the star in X/Z.
- [x] Construct a counterfactual origin Y=3627 route that selects Y=4429 and
  lands on the Y=4815 star platform.
- [x] Prove Y=3627 is the exact minimum for the fixed 20-frame model after the
  first descending quarter-step query; Y=3626 truncates one unit too low.
- [x] Prove the older coupled Y=1467 and stricter two-hand Y=672 ceilings
  cannot supply that counterfactual premise.
- [x] State that an invariant upper bound is not an authentic reachability
  witness.
- [x] Recompute the source-shaped two-hand Mario peak as 1809 and prove it is
  below the 1889 floor-query threshold for Y=1967.
- [x] Prove attacked/death and target-lift increments pass the 78-unit
  height-only filter when Mario is already supported.
- [x] Prove a stationary Mario fails the height filter on the first 85-unit
  double-pound step, a 100-unit runaway step, and the 201-unit mesh switch.
- [x] Prove standing on closed/open hand tops does not vertically overlap the
  scaled eye hitbox and the ordinary attack bounce cannot immediately follow
  the first lethal-rise surface.
- [x] Prove released/held-before-start schedules have no new A edge and fresh
  press-and-hold has exactly one frame-zero edge.
- [x] Construct the conditional Y=1809 Area 2 entry and 16-frame state
  `(0,1281,-832)` with vertical velocity -67.
- [x] Audit the selected Area 3 warp at `(0,1809,-1024)` and the exact Area 2
  query `(0,1264,-829) -> Y=1280`; prove the modeled Y=1280 snap.
- [x] Prove Y=1809 cannot query Y=1967 and unboosted surface Y=1179 misses the
  Y=1280 query minimum by 23.
- [x] Give 1179, 1467, 1974, and 2604 distinct observation predicates.
- [x] Define authentic A press edges with a pre-interval bit and prove that
  always-released and continuously-held schedules have no new edge.
- [ ] Prove or refute the original game's ability to realize the conditional
  Y=1467 hand pose and Mario launch for the Y=1967 route.
- [ ] Prove Mario can board, follow, attack or dismount from a raised hand and
  then select the static Area 3 warp floor, including the 78-unit reselection
  tolerance and phase-specific hitbox/collision separation.
- [ ] Constrain predecessor actions before treating "held A" or "no A in the
  measured suffix" as a complete no-new-A route.
- [ ] Prove a controller-accurate Area 2 route and count new A presses.
- [ ] Authenticate or refute the conditional Y=1280 trace separately for a
  fresh-A jump chain, already-held A, and never-A, including dynamic-hand exit,
  every airborne collision substep, and the landing.
- [ ] If required, optimize authentic remaining frames to star collection and
  prove or disprove the claim that Y=1967 is globally fastest.

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
- [x] Run the final complete `pipeline/check.sh` after source-shaped
  reachability integration.
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
- Audited source-shaped dangerous-seed exclusion for arbitrary/no-A/held-A
  input, plus counterfactual star-platform route and source-height no-go.
- Audited arena/tunnel split, exact A-schedule/milestone vocabulary, and
  source-shaped first-hand tunnel barrier.
- Conservative two-hand dynamic-support barrier refuting the 1467/1974/2604
  construction and the conditional Y=1967 premise.
- Mario/hand height-filter, hitbox, bounce, and authentic A-edge boundary.
- Conditional lower Area 2 certificate: Y=1809 excludes Y=1967 but supplies
  an exact source-audited Y=1280 floor selection and modeled snap; surface-only
  Y=1179 remains 23 units short and authentic controller reachability remains
  open.
