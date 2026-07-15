# Goal recovery note

Last updated: 2026-07-14 (binary32 boundary proof).

## Objective

Decide three related but separate questions for the pinned North American
Super Mario 64 source:

1. Can Mario use a raised Eyerok hand to select the Area 3 instant-warp floor
   and enter Area 2 at a useful height?
2. Are the finite Rocq hand-height bounds high enough for a useful Area 2
   landing, especially near the `Inside the Ancient Pyramid` star?
3. Can finite binary32 Eyerok Y be manipulated into an unbounded ascent, and
   can the dangerous upward-control state persist in an authentic run?

The proof must not infer Mario reachability from a hand-origin upper bound.
Hand movement, Mario/platform contact, floor selection, area change, Area 2
collision, and star interaction are separate interfaces.

## Completed proof layers

The project pins source revision
`9921382a68bb0c865e5e45eb594d9c64db59b1af` and generates CompCert Clight for
Eyerok behavior, object motion and collision, area change, instant-warp
dispatch, Mario state input, airborne stepping, platform displacement,
interactions, and the SSL level script.

The source audits now establish:

- the exact Area 3 warp quad and zero-displacement destination;
- the inactive matching Area 2 slot and adjacent return warp;
- the Area 2 Y=896, 1280, 1967, 2940, 4429, and 4815 route tiers;
- the star at `(500,5050,-500)` and its interaction bounds;
- that the largest upward-facing Area 3 floor vertex is 384 (the old value 896
  was the maximum of every vertex, including walls); and
- that platform displacement has no direct vertical-velocity addition.

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

The binary32 boundary proof establishes that every finite binary32 height is
at most `2^128 - 2^104`. It also proves the exact fixed point
`Float32.add 2^31 100 = 2^31`, stagnation when the recurrence is started
there, and CompCert's `Float32.to_int 2^31 = None`. Thus literal unbounded
finite Y is closed independently of scheduler reachability. Persistent action
or positive velocity, authentic reachability of the dangerous seed, and the
original ROM's out-of-range conversion remain separate questions.

## Remaining proof route

1. Couple boss scheduling, both hand states, update rank, dynamic surfaces,
   Mario contact, and floor selection in one authentic frame relation.
2. Prove or refute reachability of the conditional hand pose. If unreachable,
   replace the Y=1967 trace with the highest reachable landing or a no-useful-
   landing theorem.
3. Determine whether the dangerous action/positive-velocity state can persist
   in an authentic run even after binary32 Y stops changing.
4. Add an IDO/MIPS semantic boundary for the out-of-range float-to-integer
   conversion if a ROM-level execution claim is required.
5. If route optimality is required, minimize authentic frames from Area 2
   entry to star collection; geometric distance is only a lower bound.

## Repository constraints

- Work only in `SSL-Cog/eyerok-manipulation/`, apart from the existing project
  entry in `SSL-Cog/README.md`.
- Inspect but do not modify `SSL-Cog/ssl-pyramid-item-proof/`.
- Update `docs/goal.md`, `docs/claim.md`, and `docs/checklist.md` in every
  commit.
- Commit each coherent change.
- Use the Ubuntu WSL distribution and the `sm64-item-proof` opam switch.
- Do not push without explicit user approval.
