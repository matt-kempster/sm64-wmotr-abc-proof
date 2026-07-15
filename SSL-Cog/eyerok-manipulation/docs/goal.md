# Goal recovery note

Last updated: 2026-07-14 (audited source-shaped reachability proof).

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

The Mario/area relation proves:

- a hand floor does not trigger the instant warp;
- a selected Area 3 warp floor changes to Area 2 while preserving Mario's
  coordinates, velocity, and motion state;
- peak 2604 cannot reach the Y=2940 or higher audited tiers or collect the
  star; and
- a conditional adversarial trace reaches `(387,1967,-500)`, the point on the
  Y=1967 platform horizontally closest to the star.

The trace starts at the maximum hand state admitted by the vertical relation.
It is not yet an original-game trace because hand X/Z, Mario contact, and
controller input have not been refined from the pinned Clight program.

The high-route counterfactual starts from hand origin Y=3627, enters Area 2 at
Y=4354, then makes its first quarter-step query at Y=4351, selects the Y=4429
platform, and reaches the Y=4815 star platform. This
proves that such a hand height would be route-useful. The audited source-shaped
coupled audited model cannot supply it: every hand origin is at most Y=1467 and Mario's
generously modeled peak is at most Y=2604, below every direct tier above
Y=1967. The result holds for arbitrary A input, no A, and held A inside this
abstraction. Even the no-A theorem grants the 630-unit Mario rise, so it is an
impossibility result rather than a legal no-A route witness.

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
2. Prove or refute the exact conditional Y=1467 hand pose at the required X/Z,
   together with Mario contact and a controller-accurate Y=1967 launch.
3. Optimize an authentic Area 2 route to the star and count new A presses.
   The present work rules out the proposed higher Eyerok shortcut inside the
   audited model, but does not prove Y=1967 globally fastest or even
   authentically reachable.
4. Determine whether any machine behavior outside the source-shaped kernel can
   preserve the dangerous action/velocity after binary32 Y stops changing.
5. Add an IDO/MIPS semantic boundary for the out-of-range float-to-integer
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
