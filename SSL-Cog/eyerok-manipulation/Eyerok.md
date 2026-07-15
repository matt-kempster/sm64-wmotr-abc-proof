# Eyerok movement, Mario's warp, and the proof boundary

This document is written for a software engineer who does not know Super
Mario 64. It explains the game mechanism, the state machines in this project,
the new Area 2 route calculation, and the line between proved results and
plausible game behavior.

## Executive summary

Eyerok is a boss made from two independently updated hand objects. The boss
arena is Area 3. The inside of the pyramid is Area 2. A pair of sloped tunnel
floors switches Mario between those areas.

The switch is based on **Mario's selected floor**, not on Eyerok touching the
floor. If Mario's saved floor is the Area 3 instant-warp surface, the next
normal frame changes to Area 2 and preserves Mario's position and velocity.
If Mario's floor is a hand surface, no area change occurs.

The current machine-checked results are:

- the executable audited source-shaped kernel excludes
  `DOUBLE_POUND + grounded + gravity 0` for every modeled Mario-input policy,
  including never pressing A and continuously holding A;
- the older, geometry-relaxed relation bounds the first hand's origin at
  `672`, the second hand's origin at `1467`, the second surface at `1974`, and
  Mario's generously modeled peak at `2604`;
- a new source-shaped first-hand barrier proves that the first hand cannot
  realize the premise behind those positive heights: its origin is at most
  `-862`, its open collision top is at most `-355`, and it cannot select even
  the lowest tunnel floor;
- consequently, the proposed first-hand surface at Y `1179` is unreachable in
  that barrier model. The second-hand Y `1467`, surface Y `1974`, and Mario Y
  `2604` constructions remain conditional until the two-hand and Mario-contact
  refinements are completed;
- `2604` is too low for a direct landing at Y `2940`, the upper warp-overlap
  platform at Y `4429`, the star platform at Y `4815`, or direct interaction
  with the star at Y `5050`;
- the combined abstract route model does admit a conditional landing on the
  Y `1967` platform at `(387, 1967, -500)`. That is the point on that platform
  with minimum horizontal distance to the star;
- no stream of finite IEEE binary32 hand positions can be unbounded as real
  heights; and
- binary32 addition has the exact fixed point `2^31 + 100 = 2^31`, and the
  modeled recurrence remains there once started at `2^31`.

The word **conditional** is important. The geometry-relaxed vertical relation
admits the old starting hand heights, but it has no X/Z state and lets a hand
use any upward Area 3 floor regardless of whether that hand can reach it. The
new barrier closes that abstraction gap for the first-updated hand. It does
not yet close the second-hand, Mario-contact, or exact-controller gaps. The
route model also over-approximates Mario's air steering. Its Y `1967` trace is
a counterexample to "the old formal height bound is numerically too low for
every useful landing," not a verified controller-input movie for the original
game.

That qualification is essential. The project does not yet prove that every
linked Clight or original-ROM frame refines the kernel and vertical relation.
The pinned-source audit makes the no-go result substantially stronger than a
free-standing toy model, but the unqualified original-game reachability
question remains open at this source-to-model bridge.

## Coordinate system and target

SM64 positions use X, Y, and Z. Y is height.

The Area 3 to Area 2 warp floor is the quadrilateral with:

```text
X: -191 to 192
Z: -1222 to -1023
Y: 286 + 98 * (Z + 1222) / 199
```

Its Y values run from `286` to `384`. Area 3 configures this surface as
instant-warp slot 2, whose destination is Area 2 with displacement `(0,0,0)`.
Area 2 contains the same surface geometry but does not configure slot 2, so
Mario does not immediately bounce back. The active return warp is the
adjacent lower strip in slot 3.

The "Inside the Ancient Pyramid" star is a normal star object at:

```text
(X, Y, Z) = (500, 5050, -500)
```

Mario and the star have a combined horizontal interaction radius of `117`.
With Mario's normal 160-unit interaction height, Mario's base Y must be in
`[4890, 5100]` to collect it.

## What actually triggers the area change

The relevant normal-frame order in the pinned source is:

```text
warp_area()
check_instant_warp()
area_update_objects()
```

`check_instant_warp` reads the floor pointer saved by Mario's preceding
update. For the Area 3 tunnel surface, it changes the current area and adds
the configured displacement to Mario's position. The displacement is zero,
so X, Y, Z, action, and velocity are preserved.

Example:

```text
Mario state before check:
  area = 3
  position = (0, 1500, -1100)
  floor = Area3 instant-warp surface 1D

Mario state after check:
  area = 2
  position = (0, 1500, -1100)
  velocity unchanged
```

The same coordinates with `floor = Eyerok hand surface` do not trigger the
warp. A raised hand can only help indirectly: Mario must leave the hand's
footprint, remain over the warp's X/Z footprint, and have the static warp
surface become his selected floor.

SM64's floor search has no maximum downward search distance. A high Mario can
therefore select a floor thousands of units below him. A surface more than 78
units above the query point is rejected, and a higher dynamic floor beats a
lower static one. This explains both sides of the hand-to-warp transition:

- while the hand is the higher selected floor, no warp occurs;
- after Mario leaves the hand and no higher dynamic surface covers him, the
  low tunnel floor can become his selected floor and the next frame warps.

## Eyerok's state machine

Each hand has 16 source actions. The useful high-level graph is:

```text
sleep -> idle

idle -> open -> show eye -> close -> idle/retreat
                    |\
                    +-- hit -> attacked -> recover -> active -> retreat
                    +-- final hit -> die

idle -> target Mario -> smash -> retreat/fist sweep -> retreat
idle -> fist push -> fist sweep -> retreat
idle -> begin double pound -> double pound -> retreat
```

Mario influences target direction, attack selection, eye damage, wall/edge
outcomes, and boss timing. Those inputs select action handlers; they do not
directly write hand Y.

There are three normal ways Y changes:

1. **Direct positioning.** Sleep and targeting code assign or approach a
   home-relative height. Home Y is `-1534`; the largest direct source value is
   home plus 600, or `-934`.
2. **Finite impulses.** Damage, death, and a normal double pound set positive
   velocity under negative gravity.
3. **No rise.** Many states animate, move laterally, descend, wait, or delete
   the hand.

The exact positive finite budgets are:

| Action | Per-frame positive Y increments | Total |
| --- | --- | ---: |
| `ATTACKED` (`30`, gravity `-4`) | 26, 22, 18, 14, 10, 6, 2 | 98 |
| `DIE` (`50`, gravity `-4`) | 46, 42, ..., 6, 2 | 288 |
| normal `DOUBLE_POUND` (`100`, gravity `-15`) | 85, 70, 55, 40, 25, 10 | 285 |

The relation now uses `288`, the exact maximum of those three totals. The old
project version rounded this to 300.

## Why a moving hand does not automatically carry Mario

SM64's platform-displacement code adds a platform's X and Z velocity to
Mario. It does **not** directly add the platform's vertical velocity.

Mario follows a vertically moving surface through repeated floor selection
and landing/snap logic. If the new hand top is more than 78 units above Mario
when the floor query runs, that surface is rejected.

Examples:

- a 20-unit scripted lift is small enough to remain a candidate;
- the normal double-pound sequence starts with 85, then 70, 55, and so on, so
  the first step needs Mario to have enough upward motion to bridge the
  7-unit excess over the 78-unit tolerance; and
- a gravity-zero runaway that moves the hand by 100 every frame does not, by
  itself, carry a stationary Mario upward forever.

Hand collision is also loaded only while Mario remains near the hand. A hand
that escapes far above Mario eventually stops providing a usable dynamic
surface. This is why "the hand rises" and "Mario gets a high warp state" are
separate proof obligations.

## The dangerous gravity-zero branch

`BEGIN_DOUBLE_POUND` can set gravity to zero. A grounded branch of
`DOUBLE_POUND` writes vertical velocity 100 without changing gravity. If a
hand reached that branch while grounded with gravity zero, the idealized
integer recurrence would be:

```text
Y, Y + 100, Y + 200, Y + 300, ...
```

The audited source-shaped kernel now excludes that seed. The easy-to-miss
detail is how SM64 updates an object's ground flags. At the end of every
non-sleep hand update, `cur_obj_move_standard` integrates vertical motion and
then regards the hand as grounded only when its new Y is **strictly below** its
selected floor. If hand Y is exactly equal to floor Y, the code clears the old
`LANDED` and `ON_GROUND` bits.

Here is the relevant frame sequence in plain English:

```text
Frame 0: IDLE chooses BEGIN_DOUBLE_POUND and writes gravity = 0.
         Vertical velocity is 0 and hand Y equals its floor.
         End-of-frame movement clears the stale ground flag.

Frame 1: BEGIN_DOUBLE_POUND changes the action to DOUBLE_POUND.
         Zero motion again leaves the hand ungrounded.

Frame 2: DOUBLE_POUND sees "not grounded" and velocity <= 0.
         It writes gravity = -20 before movement.
```

When the hand later lands with gravity `-20`, the first grounded branch changes
gravity to `-15` and clears the boss's active-hand selection without writing
velocity `100`. A later selected grounded branch may write velocity `100`, but
gravity is then already `-15`. The actual positive increments are therefore
only `85, 70, 55, 40, 25, 10`, totaling `285`.

The audit-backed premise and Rocq kernel also close the two modeled ways stale
grounding might have survived:

- there is no raised static floor in the begin-double corridor, and the two
  closed hands stay far enough apart that one hand's center cannot select the
  other as a floor while gravity is zero; and
- a live hand cannot receive a movement-only partial update: its collision
  pointer is non-null, its room remains `-1`, and time stop freezes the entire
  hand update rather than just its movement.

This result is player-adversarial inside the abstraction: the kernel has event
cases for every boss or Mario-dependent choice relevant to this launch, while
its A-button argument is arbitrary. Rocq proves separate corollaries for never
pressing A and for continuously holding A. No relevant Eyerok hand branch
reads the A button, so changing only A cannot restore the cleared ground flag.

The A argument is deliberately a ghost input, not a full ABC controller model.
It records whether A is down, but it does not count press edges, carry-in, or
half-press conventions. The no-A height theorem is conservative: it still
grants Mario the model's generous 630-unit jump allowance. That makes the
impossibility stronger, but it does not construct a legal no-A jump.

`HeightMilestones.v` now supplies the controller vocabulary needed for the
next refinement. An A schedule records the bit immediately before the measured
interval and the bit on every frame. A press is a false-to-true edge. This
separates three cases that are often conflated:

```text
always released:        A was up before the interval and stays up
continuously held:      A was already down and stays down
press and keep holding: A starts up, then has one false-to-true edge
```

Rocq proves that the first two schedules contain no new A press. It does not
yet prove a Mario route for any of the three schedules.

There are useful sensitivity checks. If the source comparison were `<=`
instead of `<`, or if movement could partial-stutter across the two action
changes, the dangerous seed would be reachable in two frames. Those variants
are proved as counterexamples to the weakened model; the pinned source audit
rules both variants out.

The original position field is IEEE binary32, not an unbounded integer. Rocq
now proves two representation facts, separate from gameplay reachability.
First, every finite binary32 value is at most `2^128 - 2^104`, so no stream of
finite binary32 hand heights can rise above every real bound. Second, at
exactly `2^31`, binary32 addition satisfies `2^31 + 100 = 2^31`; repeating
that same addition remains fixed there.

This disproves literal unbounded finite Y even if the dangerous seed were
reachable. It does not prove that a run starting from Eyerok's normal height
reaches `2^31`, identify the first rounded fixed point of that run, or show
that the hand's action or positive velocity stops. A control state may persist
while rounded Y no longer changes.

There is a second numeric boundary. Every active hand update passes `oPosY`
through a float-to-integer conversion while preparing wall collision. At
`2^31`, CompCert's `Float32.to_int` returns `None`. A CompCert Clight execution
that reaches that cast with exactly this value therefore has no semantic
result for the conversion. This is conditional CompCert behavior: the proof
neither shows that an authentic run reaches that cast nor specifies the
original IDO/MIPS out-of-range conversion. It is not a theorem that the ROM
stops there.

## The geometry-relaxed bounds and the first-hand barrier

The earlier `1196`/`2003` numbers used the largest Y of **any** Area 3
collision vertex, `896`. That included walls. Floor support requires an
upward-facing triangle. The audited maximum vertex of an upward-facing Area 3
floor is only `384`.

The older refined relation uses this arithmetic:

1. The first-updated hand can use static Area 3 floor support at most `384`.
2. Its maximum finite impulse adds `288`, so its origin is at most `672`.
3. Its scaled collision can reach `507` above its origin, so the next hand's
   conservative support is `1179`.
4. The second hand can add another `288`, so its origin is at most `1467`.
5. Mario standing at the highest collision point is at most `1974`.
6. Adding the modeled 630-unit triple-jump rise gives Mario peak Y `2604`.

| Quantity | Absolute Y |
| --- | ---: |
| Eyerok home | -1534 |
| Largest direct scripted hand position | -934 |
| Highest upward-facing Area 3 floor vertex | 384 |
| First-hand origin ceiling | 672 |
| First-hand surface ceiling | 1179 |
| Second-hand origin ceiling | 1467 |
| Second-hand surface / Mario standing ceiling | 1974 |
| Modeled Mario peak after triple jump | 2604 |

These remain **upper bounds**, not measurements of a normal fight. The
relation conservatively allows the second hand to land on the first hand's
maximum collision top even though the original game's 78-unit floor-query
tolerance and X/Z alignment may make that exact stack unreachable.

There is a more basic problem with the first line of that arithmetic. The
Y `384` floor is in the upper tunnel, not in the boss arena. The pinned Area 3
collision separates its upward-facing floors into two groups:

| Region | Relevant floor Y |
| --- | ---: |
| highest arena floor | `-1150` |
| lowest tunnel floor | `-562` |
| no upward floor triangles | strictly between `-1150` and `-562` |

A hand can select a floor above it only if its query Y is no more than 78
units below that floor. Selecting the lowest tunnel floor at Y `-562`
therefore requires hand Y at least `-640`.

The first-updated hand cannot use the other hand as a platform. At the start
of a normal frame the engine clears dynamic surfaces. It then updates the
first hand, including its floor query, before loading that hand's new
collision. Only afterward does it update the second hand. The first hand thus
sees static Area 3 floors, not a sibling hand surface.

Even granting the first hand the highest arena floor and the largest finite
rise gives:

```text
highest arena support              -1150
largest finite rise                  +288
first-hand origin peak               -862
minimum query Y for tunnel floor      -640
shortfall                              222
```

Its maximum open-eye collision top is 507 units above its origin, so that top
can reach only Y `-355`. This does not help the hand's own floor query: the
query is made at the object's origin, and an object cannot use the collision
surface it has not loaded yet as its own support.

`FirstHandBarrier.v` formalizes this source-shaped over-approximation and
proves that every reachable first-hand state has origin Y at most `-862`, can
never query a tunnel floor, and has open surface Y below `1179`. This disproves
authentic reachability of the old first-surface Y `1179` construction within
the new barrier. It is still not a linked Clight or original-ROM theorem.

The four requested numbers now have deliberately separate predicates in
`HeightMilestones.v`:

| Milestone | What it observes | Current status |
| --- | --- | --- |
| `1179` | first hand's transformed surface | disproved in the first-hand barrier |
| `1467` | second hand's object origin | open pending two-hand refinement |
| `1974` | second hand's transformed surface | open pending two-hand refinement |
| `2604` | Mario's position | open pending authentic contact/action refinement |

Numerically, the latter three depend on the now-disproved first-hand `1179`
premise in the old stacking construction. A formal two-hand proof is still
needed before calling them unreachable in every source-shaped run.

## Area 2 floors relevant to the route

The audited destination geometry gives these milestones:

| Surface | Y | Relationship to the warp |
| --- | ---: | --- |
| ordinary floor covering the full warp footprint | 896 | directly below every arrival point |
| lower mid-level floor | 1280 | minimum horizontal gap 179 |
| square nearest the star in X/Z | 1967 | gap 307; X `[131,387]`, Z `[-716,-460]` |
| next square | 2940 | gap 307 |
| upper platform | 4429 | overlaps the northern warp footprint |
| star platform | 4815 | minimum horizontal gap 195 |
| star interaction center | 5050 | Mario base must reach at least 4890 |

Because floor lookup accepts a floor up to 78 units above Mario, the Y `2940`
floor first becomes eligible at query Y `2862`; the Y `4429` platform at
`4351`; and the star platform at `4737`.

The modeled peak `2604` is therefore:

- high enough that the height inequality alone does not reject Y `1967`;
- too low for Y `2940` or any higher listed shortcut tier; and
- far too low for direct star collection.

## A counterfactual height that would be useful

It is useful to separate two questions:

1. How high would Eyerok need to be for the proposed shortcut to work in the
   route model?
2. Can the audited Eyerok state machine actually reach that height?

`UpperRoute.v` answers the first question with a concrete counterfactual. For
the fixed 20-frame approach in that model, the minimum hand origin is Y
`3627`; its audited 507-unit collision top would put Mario's departure base at
Y `4134`. The modeled sequence is:

```text
Area 3 departure:       (192, 4134, -1993), vertical velocity 30
after 20 air frames:    (192, 4354, -1033), vertical velocity -10
first Area 2 qstep:     query at (192, 4351, -1021), select Y 4429
after the upper jump:   land on the star platform at (480, 4815, -1021)
after reposition/jump:  enter the star interaction band at (480, 4895, -500)
```

Why is the minimum `3627` rather than the simpler pre-warp threshold `3624`?
Mario's airborne update divides movement into four substeps and performs a new
floor query after the first quarter-step. Starting from entry Y `4354` with
vertical velocity `-10`, that query occurs at real Y `4351.5`, which the C
query truncates to integer Y `4351`. That is exactly 78 units below the Y
`4429` floor, so the floor is accepted. Reducing the hand origin to `3626`
makes the same query truncate to `4350`, one unit too low. Rocq proves this
scaled-by-four threshold arithmetic and checks the modeled quarter-step at
`(192,4351,-1021)`.

This is an intentionally generous integer route model, not an original-input
movie. In particular, it treats horizontal steering and the short walk along
the star platform as controlled motion. The first Area 2 landing has an
explicit quarter-step query. The source audit parses the actual Area 2
triangles and checks the selected Y `4429` floor there, the Y `4815` landing,
and every modeled ground-reposition point. The later controlled frames are
still not a linked proof of every wall, ceiling, or controller update. Its
purpose is to establish that Y
`3627` would be high enough to matter: it would skip the Y `1967` route and
reach the star platform.

Inside the older audited coupled model, the second question has the opposite
answer. That model bounds every hand origin at Y `1467`, which is `2160` units
below the modeled minimum Y `3627`. The new first-hand barrier is stronger for
the first rank, but the exact two-hand and Mario refinement is not complete.
Accordingly, the high route is ruled out in the existing coupled abstraction,
not yet by an end-to-end theorem about every original-game frame. A lower
arrival can still traverse Area 2 by ordinary gameplay, and comparing
completion times requires a controller-accurate timing proof.

## The conditional Y=1967 trace

`Area2Route.v` contains an executable integer route witness. It deliberately
starts from the maximum state admitted by the handwritten relation:

```text
second-hand origin: 1467
collision top / Mario base: 1974
assumed X,Z: (192,-1993)
long-jump vertical velocity: 30
```

Twenty modeled long-jump frames move 48 units toward the tunnel per frame and
use long-jump gravity 2. The resulting pre-warp state is:

```text
(X,Y,Z) = (192,2194,-1033)
vertical velocity = -10
```

That point is inside the Area 3 warp footprint. After the model marks the warp
floor as selected, the proved instant-warp rule enters Area 2 without changing
position or velocity.

The Area 2 steering witness then uses 11 frames of `(dX,dZ)=(16,45)` and one
final frame `(19,38)`. Both vectors have length at most 48. Mario crosses the
Y `1967` platform on the final step and lands at:

```text
(387,1967,-500)
```

For every point on that platform, horizontal distance to the star center is at
least 113. The witness achieves exactly 113, so Rocq proves it is the
horizontally closest landing point on that platform. It is still 2923 units
below the bottom of the star's vertical interaction band (`4890`). It is not a
star collection.

What this witness proves:

- the refined relation's finite bound is numerically high enough for a
  Y `1967` landing in the explicit adversarial Mario/Area 2 relation; and
- the same bound is too low for the higher audited shortcut tiers.

What it does not prove:

- that an original Eyerok hand reaches origin Y `1467` at `(192,-1993)`;
- that Mario can prepare exactly this long jump on that hand;
- that every abstract steering vector is realizable by the original analog
  input and action code; or
- that the Y `1967` landing improves the intended A-press route.

The first missing item is especially important: an invariant ceiling is not a
reachability witness.

## Why repeated upward launches are now ruled out in the audited model

The earlier phrase "an authentic transition can replenish upward motion while
already above the bound" meant this hypothetical failure mode:

```text
the hand completes one finite jump
-> the game gives it another upward launch without returning to safe support
-> the hand repeats this process at progressively greater heights
```

That would invalidate the Y `1467` bound. The important update is that this
failure mode is now ruled out in the audited source-shaped state machine. The
only source write large enough to create the proposed repeated ascent is the
100-unit double-pound launch. A launch with gravity `-15` is finite. A
repeating launch needs the hand to reach `DOUBLE_POUND` while both grounded
and still at gravity zero. The strict ground-flag update described above makes
that three-field state unreachable.

This is stronger than merely omitting an unsafe constructor from
`vertical_step`. `AuthenticKernel.v` gives the relevant source actions,
gravity values, ground flag, relative floor premise, event choices, and
A-button policy an executable transition function. Its start-double step
computes the ground bit with the same strict comparison; it does not simply
assign `false`. Rocq proves the invariant for every kernel event sequence.

`AuthenticReachability.v` then couples that kernel to the vertical relation. A
dangerous seed would select an explicit `Runaway` transition and break the
height invariant, so the Y `1467` proof now genuinely depends on excluding the
seed. The source audit checks the comparison, writers, call order,
surface-list order, collision/room syntax, local level objects, and collision
geometry on which the abstraction relies.

More precisely, this is a **kernel-controlled runaway gate on a safe vertical
abstraction**. Ordinary finite `vertical_step` choices are still admitted
independently of the kernel event, and the kernel's local floor probe is not
equated with the vertical relation's absolute Y. Those missing event/height
correspondence facts belong to the linked refinement obligation.

There is still a trust boundary. The 280-unit mixed-frame hand separation uses
a manually derived controller-phase invariant whose constants are checked by
the audit. The kernel's zero-velocity move also assumes that bounciness-zero
ground response has normalized the idle hand and that no newly selected floor
is above it. Collision lifetime and the claim that the local Area 3 object set
contains no other surface provider are likewise syntax-backed arguments, not
linked semantic lemmas. The project has not linked all generated Clight
translation units and proved that every whole-program execution refines the
coupled model. Here, **audited source-shaped** means that the transition cases
were manually extracted from pinned source and protected by deterministic
checks. It is not yet a theorem over the IDO-compiled ROM.

## Exactly what is proved

The project now machine-checks these statements:

- the generated Clight ASTs contain the selected pinned source functions and
  call edges for Eyerok, Mario floor input, instant-warp handling, area change,
  airborne stepping, platform displacement, and star interaction;
- the executable source-shaped kernel cannot reach
  `DOUBLE_POUND + grounded + gravity 0` under any modeled event or A-button
  policy, including never pressing A and continuously holding A;
- the exact controller-schedule definitions distinguish unrestricted input,
  always-released A, continuously-held A, and a fresh A press, and released or
  already-held schedules have no fresh press edge;
- every state reachable in the geometry-relaxed vertical relation has
  hand-origin Y at most `672` for the first rank or `1467` for the second;
- every state reachable in the source-shaped first-hand barrier has origin Y
  at most `-862`, cannot query a tunnel floor at Y `-562` or above, and has
  open collision top at most `-355`, hence strictly below Y `1179`;
- the coupled kernel/vertical relation cannot
  supply a hand high enough for direct selection of the Y `2940`, `4429`, or
  `4815` Area 2 tiers;
- no infinite run of that relation has unbounded integer Y;
- no arbitrary stream has unbounded finite binary32 height observations;
- `Float32.add 2^31 100 = 2^31`, and iterating the same addition from `2^31`
  remains fixed there;
- CompCert's checked `Float32.to_int 2^31` conversion returns `None`;
- a hand floor cannot trigger the modeled instant warp;
- a selected Area 3 warp floor changes to Area 2 with Mario's coordinates,
  velocity, and motion state unchanged;
- modeled Mario peak `2604` cannot reach the Y `2940`, Y `4429`, Y `4815`, or
  direct-star thresholds; and
- counterfactually, a hand origin at Y `3627` is sufficient in the integer
  route model to enter Area 2 on Y `4429` and land on the star platform, while
  the audited source-shaped ceiling is only Y `1467`; and
- the conditional combined relation reaches the closest point on the Y `1967`
  platform but does not collect the star.

## What is not proved

The project still does not prove:

- a whole-program Clight refinement from every original game frame to the
  source-shaped kernel, vertical relation, and Mario route relation;
- a semantic Clight proof, rather than the current deterministic source audit,
  of the original hands' update order and dynamic-floor choices;
- whether the second hand can use any authentic first-hand collision state to
  exceed the first-hand barrier, including all action/mesh/update-order cases;
- that the original game reaches the conditional second-hand pose used by the
  Y `1967` route witness;
- that Mario can board and remain selected on the relevant moving hand. In
  particular, vertical platform velocity is not inherited, an 85-unit first
  double-pound step exceeds the 78-unit floor tolerance, and standing on the
  normal hand top is above the eye's attack hitbox;
- an exact original-controller trace from the hand through the warp to that
  landing;
- how many new A presses an authentic route uses. The high-hand impossibility
  is A-policy-independent, but the generous `+630` Mario rise and both route
  witnesses are not controller-accurate ABC proofs;
- that Y `1967` is the globally fastest or most useful post-warp state for the
  star, rather than only the highest audited tier admitted by this restricted
  height calculation;
- a linked whole-program or ROM theorem that the gravity-zero seed is
  unreachable in every machine execution. It is unreachable in the audited
  source-shaped kernel;
- that a hypothetical execution outside that kernel follows the isolated
  `+100` recurrence to `2^31`, how high it gets, or how the ROM handles it; or
- a source-to-ROM proof for out-of-range floating-point conversions in the
  original IDO-compiled MIPS binary.

In short: the Area 3 to Area 2 mechanic is represented, the old finite bound's
route consequences are proved for the explicit adversarial model, the
source-shaped repeated-launch seed is excluded for every A policy, and literal
unbounded finite binary32 Y is disproved. We have additionally disproved the
old first-hand Y `1179` construction in a source-shaped reachability barrier.
The remaining work is to close the second-hand and Mario-contact cases, decide
the conditional Y `1967` pose, build controller-accurate released/held/pressed
A traces, and connect the source-shaped steps to linked Clight and, if needed,
the original ROM.
