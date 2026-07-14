# Eyerok movement and proof status

This document explains the Eyerok hypothesis without assuming prior knowledge
of Super Mario 64. It separates three things that are easy to confuse:

1. what the original game source does;
2. what the smaller formal artifacts allow; and
3. what has been connected by a machine-checked theorem.

## Bottom line

| Question | Current answer |
| --- | --- |
| Can a hand rise forever in the handwritten Rocq vertical relation? | **No.** Rocq proves that the `FirstHand` rank stays at or below absolute Y = 1196 and the `SecondHand` rank stays at or below absolute Y = 2003. These ranks are intended to represent update order; that connection to the game is not yet proved. |
| What can an unrestricted execution of the C abstraction do? | It can enter `Runaway` and replenish an impulse above the safety ceiling. The safety predicate detects an invalid state but does not prevent it. Its Y field is a 32-bit `int`, however, so the mathematical unboundedness theorem is not about C execution. |
| Can the abstract Rocq scheduler reach the dangerous `DOUBLE_POUND`, grounded, gravity-zero state? | **No.** This is proved for that scheduler relation. Given grounded, gravity-zero input and a double-pound request, the C abstraction intentionally maps the request to `Runaway`; it does not return the same grounded seed state. |
| Does the original binary32 `Y += 100` operation produce mathematically unbounded Y? | **No under IEEE binary32 arithmetic, although this is not yet a theorem in the project.** At large values, adding 100 rounds back to the same value. The branch can still produce a very large finite rise if it is reachable. |
| Has the same result been proved for every execution of the pinned SM64 game code? | **No.** The audit supplies supporting source facts, but the C-to-Rocq and game-to-Rocq semantic bridges are both open. |
| Can raising a hand make the formal artifacts change from Area 3 to Area 2? | **Not representable.** They have no Mario state, floor pointer, or area transition. This is an omission, not an impossibility result. |
| Has this project proved whether Mario can use a raised hand to enter Area 2 at a useful height in the real game? | **No.** The level's warp configuration is audited and the engine trigger was source-inspected, but the Mario/hand/warp interaction is not modeled or proved. |

The precise result is therefore:

> Every execution admitted by the handwritten Rocq vertical relation has
> bounded hand height. If every frame of the pinned game can be represented by
> a reachable state of that relation, the pinned game also has bounded hand
> height. The first sentence is proved; the premise of the second sentence is
> not yet proved.

The earlier shorthand “the player-adversarial model proves the first hand is
at or below 1196 and the second is at or below 2003” refers only to this
handwritten Rocq relation. It is too broad if read as a claim about arbitrary
C-abstraction calls or the original game.

In this document, “rises indefinitely” means that Y is unbounded above: for
every proposed ceiling, some later frame is higher. A very long but finite
climb, or a positive velocity whose binary32 position has stopped changing, is
not unbounded ascent.

## Game setup

Super Mario 64 represents locations with X, Y, and Z coordinates. Y is height.
The Eyerok boss arena uses two animated hand objects plus a non-moving boss
controller. Each hand has its own action, position, velocity, gravity, and
collision surface. The controller decides when a hand attacks and when the two
hands perform their coordinated pound.

The inside of the pyramid is Area 2. The Eyerok arena is Area 3. They are
separate copies of the world, but the tunnel contains special floor triangles
that switch between them. The audited Area 3 triangles form a small sloped
rectangle with approximately these limits:

```text
X: -191 to 192
Y:  286 to 384
Z: -1222 to -1023
```

Inspection of the pinned engine source shows that `check_instant_warp` looks
at **Mario's current floor surface**. If that floor is the Area 3
`SURFACE_INSTANT_WARP_1D` surface, the game changes to Area 2. The configured
displacement is `(0, 0, 0)`, so the area changes while Mario's X, Y, and Z
coordinates are preserved. The automated project audit checks the level
configuration and triangle declarations; it does not currently audit or
generate `check_instant_warp` itself.

This is not a generic “anything crossed the triangle” trigger. Moving an
Eyerok hand over the triangle does not itself change areas. Mario must have the
special triangle recorded as his current floor.

For example, suppose Mario is at `(0, 1500, -1100)`:

- if Mario's current floor is an Eyerok collision surface, the instant-warp
  check does not switch areas; but
- if the engine has selected the Area 3 instant-warp triangle as Mario's
  current floor, the check switches to Area 2 and preserves Y = 1500.

This project has not proved whether the first situation can be turned into the
second at that height by stepping or falling off a raised hand.

## The hand state machine

The original hand behavior has 16 named actions. A useful high-level view is:

```text
sleep -> idle

idle -> open -> show eye -> close -> idle or retreat
                    |\
                    +-- hit -> attacked -> recover -> become active -> retreat
                    +-- final hit -> die

idle -> target Mario -> smash -> retreat or fist sweep -> retreat
idle -> fist push -> fist sweep -> retreat
idle -> begin double pound -> double pound -> retreat
```

The real graph has timing and controller guards, so this diagram is a guide,
not an executable specification. The source action names are `SLEEP`, `IDLE`,
`OPEN`, `SHOW_EYE`, `CLOSE`, `RETREAT`, `TARGET_MARIO`, `SMASH`, `FIST_PUSH`,
`FIST_SWEEP`, `BEGIN_DOUBLE_POUND`, `DOUBLE_POUND`, `ATTACKED`, `RECOVER`,
`BECOME_ACTIVE`, and `DIE`.

Mario can influence which path is taken:

- his X and Z coordinates affect targeting and retreat checks;
- attacking an exposed eye selects the damaged or dying path;
- walls and platform edges can end an attack; and
- the boss controller uses Mario's position, timers, and random choices to
  select an attacking hand or a double pound.

Those inputs do not directly assign a hand's Y coordinate, vertical velocity,
or gravity. They influence the action handler that performs those writes.
After every non-sleep handler, the game calls the shared object-movement
helper. Unless partial-update guards suppress physics, the helper applies
gravity, adds vertical velocity to Y, and performs floor handling.

## The three ways a hand changes height

### 1. Scripted positioning

Some actions move directly toward a height relative to the hand's home
position. Eyerok's home Y is -1534. The largest direct-position ceiling encoded
in the abstractions is home plus 600, or -934.

Example: `TARGET_MARIO` approaches home plus 300, which is Y = -1234. This is
scripted positioning, not a launch that can accumulate forever.

### 2. A finite upward impulse

Being hit and dying set a positive vertical velocity together with negative
gravity. The normal double-pound launch writes velocity 100 after an earlier
frame has established gravity -15. In each case, negative gravity reduces the
upward velocity each movement frame until the hand stops rising.

| Case | Initial velocity and gravity | Positive per-frame rises | Encoded ascent budget |
| --- | --- | --- | ---: |
| Hit (`ATTACKED`) | velocity 30, gravity -4 | 26, 22, 18, 14, 10, 6, 2 | 98 |
| Final hit (`DIE`) | velocity 50, gravity -4 | 46 down to 2 in steps of 4 | 288 |
| Normal double pound | velocity 100, gravity -15 | 85, 70, 55, 40, 25, 10 | 285 |

The proof rounds all three cases up to one conservative allowance of 300.
This is deliberately larger than every audited finite impulse.

### 3. No rise

Many actions only animate, move horizontally, fall, remain still, or delete
the object. A partial update can suppress the movement helper's physics
integration, but it does not suppress Y assignments already made by the action
handler. Skipping the helper does not convert stored velocity into extra
height.

## Three formal artifacts, not one “model”

The project currently contains three different formal artifacts:

1. **Generated Clight syntax for selected original-game source files.** The
   source audit and `GeneratedFacts.v` check hashes, constants, function-body
   shapes, and selected call sites. They do not execute the game or prove its
   frame semantics.
2. **An executable C abstraction in `inputs/eyerok_model.c`.** It exposes
   functions for landing, launching, rising, stuttering, deletion, and the
   runaway case. `eyerok_safe_envelope` reports whether a state is safe, but
   the C API does not prevent a caller from making an unsafe call sequence.
   Its `int` fields have 32-bit machine semantics, not mathematical-integer
   semantics.
3. **Two handwritten Rocq relations.** `scheduler_step` describes the
   double-pound schedule, while `vertical_step` describes bounded vertical
   motion. These relations are the subjects of the reachability and height
   theorems.

No semantic theorem currently connects executions of the C abstraction to
`vertical_step`. The two handwritten relations are also not coupled to each
other by a theorem. The capstone places their independently proved properties
side by side; it does not turn them into one combined operational semantics.

This distinction has a concrete consequence. Starting from the C abstraction,
a caller can land a `SecondHand` state at Y = 1703, request the `DIE` impulse,
rise by its 288-unit budget to Y = 1991, request another `DIE` impulse at that
height, and repeat. The safety checker becomes false, but it does not block the
calls. The handwritten `vertical_step` relation forbids this because its launch
constructor requires the starting Y to be at or below the support ceiling.

## The dangerous gravity-zero state

`BEGIN_DOUBLE_POUND` sets gravity to zero. A later grounded branch of
`DOUBLE_POUND` writes vertical velocity 100 without also changing gravity.
If the hand could enter that branch while both grounded and at gravity zero,
the idealized mathematical-integer recurrence used by the Rocq theorem would
be:

```text
initial Y, initial Y + 100, initial Y + 200, initial Y + 300, ...
```

Once the ground flag is cleared, velocity remains positive, so the branch that
installs falling gravity is not selected. This is a dangerous source-level
state for the local movement logic. The C abstraction maps such an input to a
separate `Runaway` mode instead of assuming it away, and Rocq separately proves
the mathematical-integer recurrence shown above is unbounded. That recurrence
theorem is not a Clight execution theorem for either C program.

The original hand fields are binary32 floating-point values. Exact repeated
addition by 100 is therefore not valid forever. For example, the spacing
between binary32 values at `2^31` is 256, so round-to-nearest evaluates
`2^31 + 100` as `2^31`. Under the isolated repeated operation, the position
eventually stops changing even though the stored velocity can remain 100 and
gravity can remain zero. The C abstraction has a different mismatch: its Y
field is a finite-width `int`.

The reachability question still matters. A reachable gravity-zero launch could
raise the hand to an enormous but finite height—potentially enough to be
relevant to the proposed route—before binary32 rounding stalls it. This project
has not proved whether the original game can reach that launch.

The abstract scheduler proves that this combination is unreachable in its own
transition system. Its intended normal sequence is:

```text
idle and grounded, gravity 0
  -> begin double pound, not grounded, gravity 0
  -> double pound, not grounded, gravity 0
  -> first descent, not grounded, gravity -20
  -> land and pound, gravity -15
  -> launch with velocity 100 under negative gravity
```

The source audit supplies evidence for this sequence. In particular, it checks
the strict ground comparison at the initial floor, relevant partial-update
guards, dynamic-surface clearing, presence of the surface-list update, the
append-order allocation code, and collision geometry that could otherwise
provide an unexpected floor during setup. These facts motivate the scheduler;
they do not constitute a semantic proof of the complete two-hand update order.

There are three relevant answers:

- **Inside the abstract scheduler: yes, by a Rocq reachability proof.**
- **For every execution of the original game: reachability is not yet ruled
  out by a semantic proof.**
- **As a claim of unbounded original-game Y: the exact-integer recurrence is
  inapplicable because original Y is binary32.**

The missing work includes a proof that every relevant execution of the pinned
Clight program follows the cases represented by the abstract scheduler and
vertical relation, plus a faithful relation between binary32 and the formal
numeric state.

## How the height bound works

The handwritten Rocq vertical state records a mathematical-integer (`Z`) hand
Y, whether it is controlled or in flight, and a proof-only “ascent budget.”
The C abstraction has analogous fields, but, as explained above, its call
semantics have not been proved to implement the Rocq relation. In the Rocq
relation, the budget is fuel for future upward travel. For example, after a
normal double pound, a state can spend at most 285 units of upward movement.
Every rise adds an amount to Y and subtracts the same amount from the budget,
so `Y + remaining budget` does not increase.

The Rocq relation encodes conservative support heights, using the following
source-based rationale:

1. Dynamic surfaces are cleared before the two hands update.
2. The rank intended to represent the first-updated hand is assigned static
   Area 3 support only. The audit's largest static vertex Y is 896.
3. Adding the common 300-unit ascent allowance gives the `FirstHand` bound:
   `896 + 300 = 1196`.
4. The rank intended to represent the second-updated hand is allowed to use the
   first rank as a dynamic floor. A hand's scaled collision reaches at most 507
   units above its origin, so its support bound is `1196 + 507 = 1703`.
5. Adding another 300 units gives the `SecondHand` bound:
   `1703 + 300 = 2003`.

The arithmetic is proved for those abstract ranks. The claims that the ranks
match the game's update order and that these are all original-game supports
belong to the still-open game-to-Rocq bridge. That bridge must also relate the
game's binary32 position to the relation's mathematical-integer Y.

These are formal upper bounds, not predictions of heights seen during an
ordinary fight. Their Z values are intended to represent absolute world Y,
subject to the still-open binary32 observation bridge:

| Quantity | Absolute Y | Height above the home Y of -1534 |
| --- | ---: | ---: |
| Home position | -1534 | 0 |
| Largest scripted position | -934 | 600 |
| Largest audited Area 3 static vertex | 896 | 2430 |
| `FirstHand` relation bound | 1196 | 2730 |
| `SecondHand` relation bound | 2003 | 3537 |

Rocq proves that every state reachable through the handwritten vertical
relation stays within the appropriate bound. It then proves that an infinite
run of that relation cannot have unbounded height. Separately, it proves that
the excluded mathematical-integer `Runaway` recurrence grows without bound.

## Does raising a hand allow an Area 3 to Area 2 transition?

### In the formal abstractions: the transition is not represented

Neither the executable C abstraction nor the handwritten Rocq relations can
change areas because they contain only hand-vertical state. They have no Mario
position, Mario floor, current-area identifier, collision contact between
Mario and a hand, or instant-warp rule. “Player-adversarial” means that the
represented choices do not assume a cooperative player; it does **not** mean
that the formal system contains the whole player and level engine.

Therefore the statements “the `SecondHand` rank is at or below Y = 2003” and
“the system transitions to Area 2” cannot be combined: the second statement is
not expressible. This neither enables nor forbids the real route. The fact that
2003 is numerically above the warp triangles' Y range also does not establish
horizontal alignment, Mario's floor selection, or an area change.

### In the original game: the basic warp exists, but the raised-hand route is open

The automated source audit verifies that Area 3's special floor is configured
to map to Area 2 with zero coordinate displacement. Separate inspection of the
pinned `check_instant_warp` source shows that the code changes area when Mario's
current floor has that surface type. That engine function and Mario's floor
selection are not generated or machine-connected in this project. Eyerok
height alone is not the trigger.

The pinned floor-search source also has no maximum distance for a floor below
Mario. It finds dynamic and static candidates, rejects a surface more than 78
units above the query point, and prefers the dynamic candidate when it is
higher than the static candidate. Consequently, if the warp triangle is the
selected static candidate and no higher hand surface wins, a Mario positioned
high over its X/Z footprint can have the much lower triangle recorded as his
floor. This makes a high, zero-displacement area change mechanically plausible,
but it does not prove that Eyerok can put Mario into that situation.

This project has not modeled or proved the sequence needed for the proposed
route: Mario riding or leaving a hand, being above the triangle in X/Z, the
engine selecting the triangle as Mario's floor, and the area change preserving
the useful elevated position. It has therefore proved neither that a raised
hand enables this high transition nor that it cannot do so.

Even after the hand-height refinement is completed, a route-level result would
need an additional Mario/floor/area argument. It would also need to compare any
reachable finite height with the height actually required inside Area 2. The
current 1196 and 2003 bounds answer “unbounded?” only for the handwritten
relation; they do not by themselves answer “high enough for the route?”

## What the unclear “authentic transition” sentence meant

Here, “authentic transition” meant one frame transition made by the pinned
original game code, as opposed to a rule in a smaller formal relation.
“Replenish upward motion above the bound” meant giving a hand a fresh upward
impulse after it had already climbed above the support height from which the
Rocq `vertical_step` relation permits a launch.

For example, `vertical_step` lets the `SecondHand` rank launch at Y = 1703 with
at most 300 units of upward travel, so it stays at or below Y = 2003. Imagine
that the original game can instead give the hand another 285-unit double-pound
impulse at Y = 1950. It could then reach Y = 2235, and that execution would not
be covered by the current Rocq relation or its 2003 bound.

No `vertical_step` transition does this. As noted above, the executable C
abstraction does permit an unrestricted caller to replenish a budget; its
safety checker detects the resulting invariant violation but does not prevent
it. Neither the C-to-Rocq connection nor the game-to-Rocq connection is proved.
Finding one such original-game transition would invalidate this particular
bound; it would not, by itself, prove infinite ascent. A counterexample to the
idealized integer claim would require a repeatable sequence that obtains new
upward motion at ever greater heights. Under authentic binary32 arithmetic,
repeated addition eventually stagnates; the same transition could instead be
evidence for a very high finite route or for persistent attempted motion.

## Exactly what is proved

The machine-checked project proves all of the following about its formal
systems:

- generated Clight syntax contains the audited C-abstraction constants and
  selected control-flow shapes from the pinned Eyerok-related source;
- every state reachable in the abstract scheduler excludes
  `DOUBLE_POUND + grounded + gravity 0`;
- every state reachable in the handwritten vertical relation has Y at most
  1196 for `FirstHand` or 2003 for `SecondHand`;
- no infinite execution of that relation rises without bound; and
- the explicit gravity-zero runaway recurrence rises by 100 per frame and is
  arithmetically unbounded over mathematical integers.

The source audit additionally checks the pinned source revision, all positive
vertical-velocity writes, relevant gravity writes, partial-update guards,
source text relevant to surface-list ordering, collision limits, and the two
instant-warp definitions. Those checks are strong evidence about the source
surface, but they do not prove the complete two-hand semantic update order, and
syntax and constant checks are not a whole-program execution theorem.

`proofs/GlobalBoundary.v` proves a generic conditional lemma. Despite its
variable names, it imports no original-game execution semantics: `authentic_run`
is an arbitrary type, and `authentic_height` is an arbitrary Z-valued function.
Its intended reading is:

> If a sound Z-valued observation of every frame of every valid original-game
> run has the same value as some reachable handwritten Rocq vertical state,
> then that observed height is at most 2003 and cannot be unbounded.

The theorem contains no project-added axiom, but its “if” premise has not been
filled with a proof about the generated original-game Clight program. A real
instantiation also needs a sound observation or abstraction from binary32 hand
position to Z, including rounding and any non-finite values. A closed proof of
an implication does not prove its premise.

## What is not proved

The project does **not** currently prove:

- that every execution of the pinned SM64 Clight program is represented by the
  abstract scheduler and handwritten vertical relation;
- that executions of `inputs/eyerok_model.c` or its generated Clight implement
  the handwritten `vertical_step` relation;
- that `scheduler_step` and `vertical_step` form one coupled transition system;
- that the abstract `FirstHand` and `SecondHand` ranks correspond to the
  original-game two-hand update order and support choices;
- that binary32 original-game position is soundly represented by the
  mathematical-integer Y used in `vertical_step` and `GlobalBoundary.v`;
- that the dangerous gravity-zero grounded state is unreachable in every
  original-game execution;
- that the two separate abstractions correctly preserve all interactions among
  controller timing, object ordering, dynamic collision, partial updates, and
  hand height;
- that Mario can or cannot use a raised Eyerok hand to trigger the Area 3 to
  Area 2 warp at a useful height;
- that the finite Rocq-relation bounds are too low or high enough for the
  proposed route through Area 2; or
- the unqualified statement that the original game cannot be manipulated into
  an indefinite Eyerok ascent.

It also does not prove that the source's gravity-zero branch has unbounded
height. The existing unbounded theorem is deliberately about an idealized Z
recurrence; repeated binary32 `+100` eventually stagnates. If “rises
indefinitely” is intended to mean persistent positive velocity or a persistent
action state rather than unbounded Y, that is a different property and has not
been formalized here.

One way to view the gap is as an interface-conformance problem. We proved an
invariant for every input accepted by a small reference state machine. We have
not yet proved that the production game can produce only transitions accepted
by that reference state machine. Until that bridge is complete, the original
gameplay claim remains conditional.
