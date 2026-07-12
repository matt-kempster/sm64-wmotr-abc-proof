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

## The gravity-zero tripwire

`BEGIN_DOUBLE_POUND` sets gravity to zero. Later, `DOUBLE_POUND` contains a
grounded branch that writes vertical velocity 100 without changing gravity.
As an isolated C state, grounded double-pound with gravity zero is a genuine
runaway seed: after the ground flag is cleared, every active movement frame
would add 100 to Y and the `velY <= 0` branch would never install gravity.

The normal source schedule prevents that state in three ways that the formal
proof must retain:

- gravity-zero movement at the arena floor uses a strict `posY < floorHeight`
  ground test, so equality clears stale landed/on-ground bits;
- hand collision data becomes non-null on its first update and its room stays
  `-1`, excluding the far-away/different-room partial-movement guards; and
- during double-pound setup the hand centers remain at least 280 units apart
  even under a conservative mixed-frame interpolation bound,
  outside the earlier hand's closed collision footprint, while raised static
  floors do not intersect the setup corridor.

After the first descent/pound, gravity is `-15` before the velocity-100 branch
can be selected. The source audit checks the constants and geometry; the Rocq
work must still prove the schedule invariant.

## Conservative height envelope

For the eventual global bound, the audit records three deliberately loose
ceilings. Area 3's largest static collision vertex Y is 896. An authentic
upward impulse gains less than 300 units once the gravity-zero seed is
excluded. An Eyerok collision model reaches at most 507 units above its
origin after scale. Because dynamic surfaces are cleared and the first-spawned
hand updates before the second, the first hand can use static floors only and
the second can use at most the first hand's current surface. This yields
candidate absolute bounds 1196 and 2003 respectively.

## Executable proof model

`inputs/eyerok_model.c` packages this reasoning as a small C transition
interface. A state records which hand updates first, its current action and Y,
a remaining positive-ascent budget, gravity, and grounded status. Controlled
source assignments are capped at home plus 600. Landing support is capped at
896 for the first hand and at `1196 + 507 = 1703` for the second. A safe
ballistic step transfers units from the remaining budget to Y, preserving
`Y + budget`.

The three authentic positive impulses receive conservative budgets 98
(`ATTACKED`), 288 (`DIE`), and 285 (`DOUBLE_POUND`); the common proof ceiling
is 300. The C model also enters a separate `RUNAWAY` mode for the forbidden
gravity-zero grounded double-pound seed. That branch is intentional: generated
model facts and the Rocq proof can distinguish “the local lasso exists” from
“the authentic scheduler cannot reach it.”

## Machine-checked impact

The Rocq scheduler has nondeterministic stutter, exit, normalize, air, land,
pound, and launch edges. It therefore does not depend on a favorable player or
RNG choice. Its invariant says both:

```text
DOUBLE_POUND and gravity = 0  -> not grounded
DOUBLE_POUND and grounded     -> gravity <= -15
```

The vertical transition system treats controlled positioning, landing,
impulse selection, rising, falling, partial-update stuttering, and deletion as
separate cases. The quantity `Y + remaining ascent budget` never exceeds the
rank-specific ceiling. Reachability induction gives Y <= 1196 for the earlier
hand and Y <= 2003 for the later hand, hence an infinite run cannot be
unbounded.

For contrast, the proved runaway recurrence is
`Y(n) = Y(0) + 100*n`, which is unbounded. The proof therefore addresses the
dangerous branch rather than erasing it from the model.

The end-to-end check recompiles these theorems and uses `Print Assumptions` on
the capstone, scheduler invariant, infinite-run bound, and global lifting
theorem. They introduce no project-defined logical assumptions. The combined
capstone inherits standard Coq/CompCert classical and functional-extensionality
dependencies from mentioning the authentic binary32 Clight AST; the three core
transition/boundary theorems are closed under the global context. The global
lifting theorem remains conditional because refinement is an ordinary theorem
argument, not because it is postulated.

## Proof relevance

The desired refutation of the route is a uniform home-relative height bound
for every reachable hand state under every player strategy. Such a bound is
stronger than showing that one ordinary attack falls back down: it rules out
combining legal action transitions into an unbounded climb. If an authentic
transition can replenish upward motion while already above the bound, that is
a counterexample candidate and the impossibility proof must stop.
