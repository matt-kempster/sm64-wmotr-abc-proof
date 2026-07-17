# Eyerok manipulation proof checklist

Last updated: 2026-07-16 (nonlethal recovery/no-stacking theorem).

## Current verdict

The geometry-relaxed handwritten relation bounds hand origins at 672/1467. Its
Mario/Area 2 model proves that a hand floor itself cannot warp, that a selected
warp floor preserves Mario's state across Area 3 to Area 2, and that its old
modeled peak 2604 is too low for Y=2940 or higher route tiers. Its conditional
trace lands at `(387,1967,-500)`, but the new two-hand barrier refutes the
starting hand pose. The
audited source-shaped kernel now excludes the dangerous repeated-launch seed
for arbitrary A input, no A, and held A inside the abstraction. A
velocity-aware companion relation additionally excludes the airborne seed
`DOUBLE_POUND + gravity 0 + positive oVelY` by proving every reachable `IDLE`
entry has nonpositive inherited velocity. A
counterfactual origin Y=3627 route would reach the star platform, but the
stricter two-hand origin ceiling is Y=672.
Literal unbounded finite binary32 Y is also disproved. Linked Clight/ROM
refinement and route optimality remain open.

A debugger-enabled Mupen64Plus run now checks the critical action boundary on
the hash-authenticated US ROM. After both genuinely spawned hands were validated at
home Y=-1534 with zero velocity/gravity and a real collision mesh, the
disclosed fixture changed only their actions from SLEEP to IDLE. One ordinary
update populated real floor pointers at -1534 before the boss scheduler fields
were installed. The observed sequence was IDLE -> BEGIN_DOUBLE_POUND ->
DOUBLE_POUND; the first eligible airborne handler installed gravity -20 at
nonpositive velocity, and the first positive movement was +85 with gravity
-15. The analyzer found zero airborne DOUBLE_POUND/gravity-zero/positive-
velocity rows. This is a real ROM continuation from a source-reachable local
precondition, not a from-reset controller-only fight trace or a refinement
proof.

The unified nonlethal lifecycle now tracks health, action, relative Y,
velocity, gravity, grounding, attack age/latch, accepted-hit count, and the
pending home reset. It proves that a hand has only the `4->3` and `3->2`
nonlethal responses, that each airborne impulse contributes at most +98, and
that every path to another accepted nonlethal hit contains the exact-home
`RETREAT -> IDLE` reset. This closes nonlethal impulse stacking in the
source-shaped relation. It does not close the broader linked Clight/ROM
finite-episode refinement or forbid a separate support mechanism after reset.

The normal finite double-pound now has hash-authenticated-US-ROM continuations
from disclosed local fixtures. At observed action timer 2, retail jump-kick or dive code moves Mario
`+20` and then `+16` before the selected hand launches. The resulting
pre-player-update gap is 49; Mario's first air quarter-step reduces the
modeled floor-query gap to 46. Ordinary collision selects the same hand and both modes
remain attached through `+85,+70,+55,+40,+25,+10` to top Y=-943. Same-frame
entry fails at gap 85 and produces hand-ceiling squish. The held-A input has
`A_DOWN` without a new edge; the B-only input has A always released. The probe
still injects the local predecessor pose/action and boss synchronization.

The standard `-4` attack certificate is arithmetic over explicit lists. It
proves the nonlethal open mesh fails the vertical filter during +98 and that a
later closed-top query would have a conditional 46-unit gap at Y=-1228; it
does not prove a snap. The lethal minimum airborne gap is 153 and the
first-grounded gap is 191.

The strict-US attack probe supplies a separate runtime result. An inherited
low-speed long-jump fixture really reboards the nonlethal home-height open
hand at Y=-1027 while it still has velocity -26 and no ground flag; the flag
sets next frame. It later reacquires closed Y=-1228 and rides `TARGET_MARIO`
to -928. It does not ride the +98 attacked ascent. Ordinary long-jump entry
requires a prior fresh-A edge, but this fixture injects the action and leaves
that predecessor unproved. In lethal mode the early gaps 63/7 are X/Z-blocked.
Clean full-stick steering later selects the hand only as a floor; even a
braking schedule that remains over the top through timer39 never gets a
platform, because Mario is still 43 units high and deletion precedes the
crossing update. The first post-deletion floor address is stale: the hand is
inactive and the platform is null. B-only slide kick is no-A enterable, but its tested first wall
unconditionally exits to backward air knockback in both health modes.

The false global 280-unit hand-separation shortcut has been removed. The
replacement phase trace starts 360 units behind: `(-120,255)` is the last
vertically eligible closed-top query but remains horizontally outside, while
`(-90,210)` is horizontally inside but 18 units too low. The source-shaped
partial-update lifecycle also proves that native-before-visibility collision
loading, room -1, and whole-update time-stop freezing keep both movement-only
partial flags clear. Both conclusions remain conditional on a linked Clight
refinement of their audited boundary premises.

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

For never-A, the B-only speed kick is now refuted as a direct ordinary
speed-at-most-48 route to Y=1280. Its 60-unit rise peaks at Y=1239, leaving 35
eligible quarter-steps and at most 420 units of path. The platform wall needs
base Y above 1255 to clear vertically, more than 540 units around the east,
or more than 2060 around the west. Rocq proves that every seam-free
wall-avoiding path in this classification is impossible. Faster input,
post-bonk recovery, seams/quantum tunneling, and authentic departure remain
open.

For already-held A, the jump kick has the same Y=1239 peak and 35 eligible
quarter-steps. Under the explicit inherited-speed bound
`|forwardVel| <= 48` plus the explicit 13-unit-per-step premise, Rocq bounds
the total at 455, still too little to clear or detour around the wall. The
stationary-predecessor submodel has a 140-unit budget. Faster predecessors and
jump-kick continuation after a wall hit remain open.

The requested-height package keeps the four legacy observation types and the
three proof scopes separate. The explicit Clight boundary now uses coherent
CompCert small-step runs, but its complete-program/height refinement remains a
premise; generated AST resolution and call-site-traversal facts do not
discharge it.

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
- [x] Generate pinned controller input and Mario moving, object, and
  stationary action Clight.
- [x] Prove per-unit name resolution, critical AST call-site traversal order,
  controller AND/XOR edge shape, the jump-kick case's vertical-slot-1 value
  20, and exact B-only/held-A/backflip call shapes.
- [x] Audit all 16 hand actions, positive velocity/gravity writers, finite
  ascent budgets, and the gravity-zero tripwire.
- [x] Exhaust the three `IDLE` writers, both zero-gravity exits, attacked
  recovery timing, and the double-pound active-hand/terminal handshake.
- [x] Audit health initialization at 4, the `4->3`, `3->2`, and `2->1`
  branches, the unique `SHOW_EYE` attack consumer, per-update latch overwrite,
  the full recovery/re-exposure graph (including both `CLOSE` exits),
  exact-home retreat guard, and the 15-movement ground return before the
  25-frame ATTACKED gate.
- [x] Prove generated-Clight AST shape facts for the nonlethal handler chain,
  hitbox initialization call, action constants, and handler/check/move order.
- [x] Audit the apparent sibling `SHOW_EYE` lock clear: it is one-hand-only,
  `OPEN` keeps the independent `Unk1AC` exposure latch nonzero throughout
  `SHOW_EYE`, and single-hand `DOUBLE_POUND` reasserts its active-hand side
  before branching.
- [x] Audit the paired instant warps and exact Area 3 warp quad.
- [x] Audit Area 2 floor tiers and target star coordinates/hitbox.
- [x] Audit four airborne quarter steps, the fresh quarter-step floor query,
  TerrainData Y cast, landing snap, and 78-unit floor buffer.
- [x] Audit that upper/lower wall resolution precedes each airborne floor
  query and that a dive wall hit enters `BACKWARD_AIR_KB`.
- [x] Parse Area 2 upward triangles and verify exact selected-floor heights at
  the lower Y=1280 and upper-route quarter-steps, star-platform landing, and
  every modeled ground-reposition point.
- [x] Distinguish maximum collision vertex 896 from maximum upward-floor
  vertex 384.
- [x] Confirm platform displacement has no direct vertical velocity add.
- [x] Audit strict ground comparison and equality clearing both ground flags.
- [x] Audit exact gravity-writer sequence, collision-pointer writers, room
  default, bounciness, native-before-visibility order, first sleep collision
  assignment, whole-update time-stop branch, and movement partial guards.
- [x] Audit hand spawn/append/update order and dynamic-surface clearing.
- [x] Audit the Area 3 local object/macro set, absence of water, begin-double
  corridor floors, closed-hand radius, and positioning constants; reject the
  old 280-unit mixed-frame calculation as a global separation invariant.
- [x] Audit the phase-specific 360-unit positive-double setup, exact relative
  trace, Z=0 closed-top footprint, 228 query threshold, and
  `(-120,255) -> (-90,210)` near miss.
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
- [x] Audit the Y=1280 platform's south/east wall rectangles and their
  Y=1152..1280 span.

## Vertical proof

- [x] Formalize the scheduler and exclude its grounded/gravity-zero seed.
- [x] Track inherited vertical velocity across every `IDLE` entry and exclude
  the airborne/gravity-zero/positive-velocity `DOUBLE_POUND` seed.
- [x] Track health, Y, velocity, gravity, grounding, attack latch/age, and the
  complete nonlethal recovery graph; prove at most two nonlethal hits, +98 per
  airborne impulse, and an intervening exact-home reset before another hit.
- [x] Formalize finite ascent budgets and partial-update stuttering.
- [x] Refine support/ascent constants to 384 and 288.
- [x] Prove first/second hand-origin ceilings 672 and 1467.
- [x] Lift the invariant to all finite prefixes and infinite relation runs.
- [x] Keep original-game refinement explicit and conditional.
- [x] Define a coherent Clight frame run and conditionally transfer the
  1467/1974/2604 and no-unbounded-rise results from an explicit refinement
  premise; do not claim that premise is discharged.
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
- [x] Prove no sample of the audited positive-double free-flight trace can
  select the sibling closed top; do not generalize this to global hand
  separation.
- [x] Prove the no-external-writer live-hand lifecycle cannot set FAR_AWAY or
  IN_DIFFERENT_ROOM and therefore cannot take a movement-only partial update.
- [ ] Prove the event-by-event linked Clight finite-episode premise, including
  no airborne replenishment, exact double-pound/wall refinement, lifecycle
  writer completeness, and support classification before another launch. The
  nonlethal `ATTACKED` reset/no-stacking subcase is closed in the source-shaped
  lifecycle, but not yet transferred from whole-program Clight/ROM frames.

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
- [x] Prove the conditional B-only speed-kick rise is 60, peak Y=1239, and its
  Y=1280 query window contains 35 quarter-steps.
- [x] Prove any arbitrary-steering, seam-free speed-48 path has length at most
  420, cannot clear over the wall, and cannot complete either wall detour.
- [x] Conclude the ordinary no-A candidate must resolve a wall before Y=1280;
  keep this separate from unrestricted no-A reachability.
- [x] Prove the held-A jump-kick reuses the 20-unit vertical launch and 35-step
  window; under inherited speed at most 48 and an explicit 13-unit-per-step
  premise, bound path by 455 and exclude the same seam-free wall-avoiding
  route.
- [x] Prove the conditional stationary held-A predecessor budget is at most
  140, without treating it as a linked source theorem.
- [x] Give 1179, 1467, 1974, and 2604 distinct observation predicates.
- [x] Package the source-shaped milestone exclusions, conditional fresh-edge
  landing, and restricted no-A barrier without conflating their scopes.
- [x] Define authentic A press edges with a pre-interval bit and prove that
  always-released and continuously-held schedules have no new edge.
- [x] Prove a height-only early-action catch witness, then authenticate the
  concrete two-update (`+20,+16`) schedule, 49-unit pre-player-update gap, and
  46-unit first-quarter query gap on the US
  ROM, including strict-interior X/Z and every later positive hand step.
- [x] Separate the already-held-A/no-new-edge local suffix from the
  A-always-released B-only suffix, without treating either injected predecessor
  as a complete 0.5-A or zero-A route; prove the same-frame B attempt is
  blocked by underside squish.
- [x] Prove the standard `-4` falling-hit trace-list facts: the nonlethal open
  top is vertically rejected during ascent, its recovery query is only
  conditionally height-eligible, and the listed lethal airborne plus first-
  grounded rows remain vertically ineligible.
- [x] State that the attack/reboard Rocq result is arithmetic over explicit
  trace lists, not yet an operational linked-Clight trace derivation.
- [x] Instrument the inherited long-jump modes without a fallback latch:
  reproduce the retail nonlethal home-height open reboard one frame before
  grounding and the lethal 63/7
  early X/Z miss.
- [x] Clear and disclose the local Mario squish timer, then run bounded
  full-stick/side-escape/yaw/braking lethal schedules. Record later hand-floor
  selection, no platform, final 43-unit clearance, and deletion before the
  crossing update.
- [x] Audit the no-A crouch-slide to slide-kick entry, minimum speed 32, and
  unconditional slide-kick wall exit; reproduce no reboard in nonlethal and
  lethal local modes.
- [ ] Construct or refute controller reachability of the successful
  nonlethal long-jump predecessor and classify its prior fresh A edge.
- [ ] Generalize the lethal no-platform result beyond the tested front-side
  local pose and bounded steering/yaw schedules.
- [x] Add strict-hash Ubuntu-24.04 wrappers, analyzers, fixture manifests, and
  narrow CSVs for stationary, B-only, already-held-A, attack, and steering
  contact.
- [x] Ignore project-local `build/`, Python `__pycache__/`, and bytecode so
  generated instrumentation/audit caches remain isolated.
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
- [ ] For never-A, refine the ordinary wall barrier and investigate speed over
  48, post-bonk actions, seams, quantum tunneling, and PU casts.
- [ ] For held A, prove the predecessor speed bound or analyze speed over 48,
  then classify jump-kick continuation after its first wall response.
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
- [x] Use Ubuntu-24.04 for the Mupen64Plus runtime probes. The idle wrapper
  rejects the wrong MD5; the contact wrapper rejects the wrong MD5 or SHA-256;
  the attack wrapper additionally rejects the wrong header CRC. No SHA-1 check
  is claimed.
- [x] Reproduce the initialized-local-precondition IDLE-to-double trace and
  mechanically reject the alternate airborne seed in all 476 captured hand
  rows.
- [x] Reproduce the four attack modes and bounded lethal steering/braking
  witness on the hash-authenticated US ROM, asserting retail hit/response,
  mesh, selected-floor, platform, and deletion fields.
- [ ] Reproduce the same result from reset using controller input only, with
  no travel or scheduler fixture.
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
- Exact positive-double sibling-floor near-miss and source-shaped live-hand
  partial-update exclusion, replacing the false global 280-unit separation
  shortcut.
- Ordinary no-A Y=1280 barrier: B-only rise is numerically sufficient, but a
  seam-free speed-48 path cannot clear or detour around the platform wall in
  its 35-quarter-step eligibility window.
- Generated controller/Mario action Clight facts, coherent conditional Clight
  refinement boundary, typed requested-height verdict package, and bounded-
  speed held-A Y=1280 wall barrier.
- Exhaustive `IDLE`-entry velocity audit and Rocq exclusion of the alternate
  airborne zero-gravity positive-velocity seed.
- Source-audited/Rocq normal-double catch plus standard-gravity attack/reboard
  trace-list arithmetic, with local already-held-A and A-always-released
  suffixes kept separate from complete ABC route claims.
- Strict-US-ROM attack/reboarding probe: nonlethal inherited-long-jump
  home-height open reboard one frame before grounding, lethal early X/Z and
  late deletion blocker, and
  nonlethal/lethal no-A slide-kick wall exit, with the arithmetic certificate
  narrowed to its actual scope.
