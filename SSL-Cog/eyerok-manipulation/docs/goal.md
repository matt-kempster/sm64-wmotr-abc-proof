# Goal recovery note

Last updated: 2026-07-14 (two-hand dynamic-support barrier).

## Objective

Decide three related but separate questions for the pinned North American
Super Mario 64 source:

1. Can Mario use a raised Eyerok hand to select the Area 3 instant-warp floor
   and enter Area 2 at a useful height?
2. Are the finite Rocq hand-height bounds high enough for a useful Area 2
   landing, especially near the `Inside the Ancient Pyramid` star?
3. Can finite binary32 Eyerok Y be manipulated into an unbounded ascent, and
   can the dangerous upward-control state persist in an audited source-shaped
   run, a linked Clight run, or the original ROM?

The proof must not infer Mario reachability from a hand-origin upper bound.
Hand movement, Mario/platform contact, floor selection, area change, Area 2
collision, and star interaction are separate interfaces.

## Completed proof layers

The project pins source revision
`9921382a68bb0c865e5e45eb594d9c64db59b1af` and generates CompCert Clight for
Eyerok behavior, object motion and collision, area change, instant-warp
dispatch, Mario state input, airborne stepping, platform displacement,
interactions, and the SSL level script.

The deterministic source audits now pin:

- the exact Area 3 warp quad and zero-displacement destination;
- the inactive matching Area 2 slot and adjacent return warp;
- the Area 2 Y=896, 1280, 1967, 2940, 4429, and 4815 route tiers;
- the star at `(500,5050,-500)` and its interaction bounds;
- that the largest upward-facing Area 3 floor vertex is 384 (the old value 896
  was the maximum of every vertex, including walls); and
- that platform displacement has no direct vertical-velocity addition;
- that floor equality clears both ground bits because grounding uses a strict
  comparison;
- the complete relevant gravity-writer order, hand spawn/update order, and
  dynamic-surface clear order;
- the live hand's nonnull collision-pointer writers, room default `-1`, and
  movement partial-update guards. The conclusion that their whole lifecycle
  excludes a partial update is still a manual source argument; and
- the Area 3 local object/macro data, closed-hand radius, and positioning
  constants. The 280-unit mixed-frame separation is a manual controller-phase
  invariant over those audited constants, not a linked semantic theorem.

`AuthenticKernel.v` extracts those audit-backed premises into an executable
finite transition function. Its start step computes the ground bit using the
strict comparison. Rocq proves that no event sequence reaches
`DOUBLE_POUND + grounded + gravity=0`. Its A-button argument is arbitrary, so
the hand-control result separately covers never pressing A and continuously
holding A. This argument is a ghost input because the hand code does not read
A; it is not an ABC press-edge or controller model.

The refined vertical relation uses exact maximum finite ascent budget 288. It
proves hand-origin ceilings 672 and 1467. Adding the collision top and modeled
triple-jump allowance gives a second-hand Mario peak ceiling of 2604.

Those are geometry-relaxed bounds, not authentic reachability witnesses. The
new Area 3 audit proves that the first hand's available static arena floors top
out at Y=-1150, while the tunnel begins at Y=-562 with no upward floor between
them. Because the floor query accepts a floor at most 78 units above the hand,
the full finite rise reaches only origin Y=-862 and misses tunnel eligibility
by 222 units. `FirstHandBarrier.v` proves that every state in the source-shaped
first-hand relation stays at or below -862, never selects the tunnel, and has
open collision top at or below -355. Therefore the old first-surface Y=1179
construction is unreachable in this barrier.

`TwoHandBarrier.v` conservatively grants the second hand every upward static
Area 3 floor, every possible first-hand contact at every X/Z, the tallest open
mesh in every phase, and preservation of unused rise across a floor snap. The
first dynamic surface is still at most Y=-355, below the static floor maximum
Y=384. Therefore the second support ceiling is 384, its finite origin ceiling
is 672, its open surface ceiling is 1179, and the modeled Mario peak is 1809.
This disproves the old second-origin 1467, second-surface 1974, and Mario 2604
constructions inside the source-shaped barrier. Since the Area 2 Y=1967 floor
requires query Y at least 1889, the old conditional Y=1967 trace cannot obtain
its starting premise from this barrier.

`HeightMilestones.v` now represents first surface Y=1179, second origin
Y=1467, second surface Y=1974, and Mario Y=2604 as distinct observations. It
also distinguishes always-released A, A held before the measured interval,
and a fresh press edge. No authentic Mario route is inferred from these
definitions.

The Mario/area relation proves:

- a hand floor does not trigger the instant warp;
- a selected Area 3 warp floor changes to Area 2 while preserving Mario's
  coordinates, velocity, and motion state;
- peak 2604 cannot reach the Y=2940 or higher audited tiers or collect the
  star; and
- a conditional adversarial trace reaches `(387,1967,-500)`, the point on the
  Y=1967 platform horizontally closest to the star.

The trace starts at the maximum hand state admitted by the older
geometry-relaxed vertical relation. The new two-hand barrier refutes that
starting state. The trace remains a checked counterfactual, not an
original-game trace.

The high-route counterfactual starts from hand origin Y=3627, enters Area 2 at
Y=4354, then makes its first quarter-step query at Y=4351, selects the Y=4429
platform, and reaches the Y=4815 star platform. This
proves that such a hand height would be route-useful. The audited source-shaped
coupled model cannot supply it. The stricter two-hand barrier bounds the second
origin at Y=672 and Mario's generously modeled peak at Y=1809, below even the
Y=1967 floor-query threshold. The result holds for arbitrary A input, no A,
and held A inside this abstraction. Even the no-A theorem grants the 630-unit
Mario rise, so it is an impossibility result rather than a legal no-A route
witness.

The binary32 boundary proof establishes that every finite binary32 height is
at most `2^128 - 2^104`. It also proves the exact fixed point
`Float32.add 2^31 100 = 2^31`, stagnation when the recurrence is started
there, and CompCert's `Float32.to_int 2^31 = None`. Thus literal unbounded
finite Y is closed independently of scheduler reachability. Persistent action
or positive velocity outside the source-shaped kernel, a linked whole-program
refinement of the kernel, and the original ROM's out-of-range conversion remain
separate questions. Within the audited source-shaped kernel, dangerous-seed
reachability is now closed.

## Remaining proof route

1. Link the generated translation units and prove that every relevant Clight
   frame refines the source-shaped kernel, including update rank, dynamic
   surfaces, time stop, Mario contact, and floor-pointer lifetime.
2. Prove Mario's contact lifecycle on the hand: boarding, per-frame floor
   reselection, attack-hitbox compatibility, dismount, and selection of the
   static Area 3 warp floor. Decide released-A, held-before-start, and fresh
   press-and-hold schedules separately.
3. Prove an event-by-event Clight bridge for the two-hand finite-episode
   premise: every positive episode starts from classified support and has at
   most 288 remaining rise, with no airborne replenishment.
4. Determine the highest authentic lower Area 2 landing admitted by the
   Y=1809 Mario ceiling and construct or refute its exact controller trace.
5. Optimize an authentic remaining Area 2 route to the star and count new A
   presses.
   The present work rules out the proposed higher Eyerok shortcut inside the
   source-shaped model; the old Y=1967 witness is now refuted there.
6. Determine whether any machine behavior outside the source-shaped kernel can
   preserve the dangerous action/velocity after binary32 Y stops changing.
7. Add an IDO/MIPS semantic boundary for the out-of-range float-to-integer
   conversion if a ROM-level execution claim is required.

## Repository constraints

- Work only in `SSL-Cog/eyerok-manipulation/`, apart from the existing project
  entry in `SSL-Cog/README.md`.
- Inspect but do not modify `SSL-Cog/ssl-pyramid-item-proof/`.
- Update `docs/goal.md`, `docs/claim.md`, and `docs/checklist.md` in every
  commit.
- Commit each coherent change.
- Use the Ubuntu WSL distribution and the `sm64-item-proof` opam switch.
- Do not push without explicit user approval.
