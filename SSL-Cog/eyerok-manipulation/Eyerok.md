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

- the refined handwritten Eyerok relation bounds the first-updated hand's
  origin at absolute Y `672` and the second-updated hand's origin at `1467`;
- after adding the hand's maximum `507`-unit collision top, Mario's modeled
  standing height is at most `1974` on the second hand;
- after adding a generous ordinary triple-jump rise of `630`, Mario's modeled
  peak is `2604`;
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

The word **conditional** is important. The handwritten vertical relation
admits the starting hand height, but it has no X/Z state and does not prove
that the original game can put the hand at the required position. The route
model also over-approximates Mario's air steering. It is a counterexample to
"the formal height bound is numerically too low for every useful landing," not
a verified controller-input movie for the original game.

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

The handwritten scheduler relation excludes that seed in its own reachable
states. That is a proof about the scheduler relation, not yet a whole-program
proof about the two hands, boss controller, collision engine, and original
compiled game.

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

## The corrected hand-height bound

The earlier `1196`/`2003` numbers used the largest Y of **any** Area 3
collision vertex, `896`. That included walls. Floor support requires an
upward-facing triangle. The audited maximum vertex of an upward-facing Area 3
floor is only `384`.

The refined relation uses this arithmetic:

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

## What "an authentic transition above the bound" means

An authentic transition is one frame produced by the pinned original-game
code, rather than a constructor in a handwritten relation.

The refined vertical relation permits a fresh finite launch only from at or
below the rank's support ceiling. For the second rank that support is `1179`.
If the original game could repeatedly give the hand a fresh 285-unit
double-pound impulse after it had already climbed far above `1179`, those
frames would not refine the relation and its `1467` origin bound would not
apply. Such a trace would be a counterexample to the **small route-useful
height bound**, not to the separate theorem that finite binary32 values have a
representation ceiling.

No constructor in `vertical_step` permits that replenishment. The executable C
abstraction's public API can be called in an unsafe sequence, so it is not a
proof that the game cannot do so. A whole-program refinement must show that
every source transition falls on the safe side of this split. In other words,
authentic replenishment has not been ruled out; only the handwritten relation's
version of it has.

## Exactly what is proved

The project now machine-checks these statements:

- the generated Clight ASTs contain the selected pinned source functions and
  call edges for Eyerok, Mario floor input, instant-warp handling, area change,
  airborne stepping, platform displacement, and star interaction;
- the abstract scheduler cannot reach `DOUBLE_POUND + grounded + gravity 0`;
- every state reachable in the refined vertical relation has hand-origin Y at
  most `672` for the first rank or `1467` for the second;
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
- the conditional combined relation reaches the closest point on the Y `1967`
  platform but does not collect the star.

## What is not proved

The project still does not prove:

- a whole-program Clight refinement from every original game frame to the
  scheduler, vertical relation, and Mario route relation;
- that the original hands' update order and actual dynamic-floor choices
  realize the abstract first/second ranks;
- that the original game reaches the conditional hand pose used by the Y
  `1967` route witness;
- an exact original-controller trace from the hand through the warp to that
  landing;
- that Y `1967` is the globally fastest or most useful post-warp state for the
  star, rather than only the highest audited tier admitted by this restricted
  height calculation;
- that the gravity-zero seed is unreachable in every original-game run;
- that an authentic run follows the isolated `+100` recurrence to `2^31`,
  how high such a run gets, or that its action and positive velocity exit; or
- a source-to-ROM proof for out-of-range floating-point conversions in the
  original IDO-compiled MIPS binary.

In short: the Area 3 to Area 2 mechanic is now represented, the finite bound's
route consequences are proved for the explicit adversarial model, and literal
unbounded finite binary32 Y is disproved. The remaining uncertainty is no
longer "what does Area 2 look like?" It is the authentic reachability of the
hand/Mario starting state, possible persistence of the dangerous control
state, and the whole-program connection from the pinned source to the
relations.
