# Eyerok movement state machine

This note records how the two Eyerok hand objects move in the pinned US SM64
source and which parts of that movement the player can influence. It will be
kept in sync with the source audit and formal transition system.

## Objects and area toggle

The boss controller spawns a left hand and a right hand. The hands execute the
16-action state machine in `src/game/behaviors/eyerok.inc.c`; the controller
chooses which hand attacks and coordinates the double-pound sequence.

The Pyramid interior (area 2) and Eyerok arena (area 3) use paired instant
warps with zero coordinate displacement. Special floor triangles in the
tunnel select the other area. The proposed route therefore needs a hand to
acquire unbounded positive Y motion above those triangles before Mario
crosses back into area 2.

## Hand actions

The source actions are `SLEEP`, `IDLE`, `OPEN`, `SHOW_EYE`, `CLOSE`,
`RETREAT`, `TARGET_MARIO`, `SMASH`, `FIST_PUSH`, `FIST_SWEEP`,
`BEGIN_DOUBLE_POUND`, `DOUBLE_POUND`, `ATTACKED`, `RECOVER`,
`BECOME_ACTIVE`, and `DIE`.

They divide into three vertical classes:

- controlled-position actions assign or approach a home-relative Y target;
- ballistic actions give the hand one finite upward impulse and negative
  gravity; and
- horizontal/animation actions do not create upward velocity.

Every non-sleep frame ends with `cur_obj_move_standard(-78)`. Its motion can
be skipped by the engine's partial-update flags, but skipping the helper also
skips the Y-coordinate update; it does not turn stored velocity into height.

## Player influence

Mario's Z position affects target selection and retreat conditions. Mario's X
and Z positions affect approach direction, wall/edge tests affect attack
termination, and attacks on the exposed eye select the `ATTACKED` or `DIE`
branches. Timing these inputs can choose among source transitions but does not
directly assign a hand's Y coordinate, vertical velocity, or gravity.

The formal model will over-approximate these choices rather than assume a
cooperative player. Its open source-to-model obligations are tracked in
`docs/claim.md`.

## Proof relevance

The desired refutation of the route is a uniform home-relative height bound
for every reachable hand state under every player strategy. Such a bound is
stronger than showing that one ordinary attack falls back down: it rules out
combining legal action transitions into an unbounded climb. If an authentic
transition can replenish upward motion while already above the bound, that is
a counterexample candidate and the impossibility proof must stop.
