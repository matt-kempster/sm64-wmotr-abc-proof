# Pedro-Coq in plain English

This guide is for a reader who knows basic C# programming but does not know
Super Mario 64 or proof assistants. It explains the Rocq/Coq proof system used
by this project, what a Pedro spot is, why dust can matter to the game's random
number generator, and exactly what has been proved about the Tic Tock Clock
spinner Pedro interval and the newer cog work.

Only the North American (`VERSION_US`) and Japanese (`VERSION_JP`) versions of
the original game are covered. Nothing here should be assumed for the European,
Shindou, or iQue versions.

The active task now concerns TTC cogs, which have their own behavior. The cog
work has certified a pair of overlapping surfaces and proved one complete
stock cog update preserves its angle under specified initial conditions.
Reaching those conditions and controlling RNG while Mario stays in the spot
are still open. See [the cog plan](ttc-cog-plan.md). Gameplay experiments must
use legal inputs and read-only observation, with no cheats or state edits.

## The game ideas first

Super Mario 64 represents Mario's position with three coordinates: X, Y, and Z.
X and Z locate him across the ground, while Y is his height. The game also keeps
references to the floor and ceiling surfaces near him.

A **Pedro spot** is a very cramped collision arrangement. Mario attempts an air
movement and reaches a floor, but the gap between that floor and the ceiling is
at most 160 game units. In the important branch of the movement code, the game:

1. reports that Mario landed;
2. places his Y coordinate at the floor height; but
3. does not accept the attempted X/Z movement or replace his referenced floor
   when the floor-to-ceiling gap is 160 or less.

In simplified C#-style pseudocode, the relevant idea is:

```csharp
if (nextY <= floorHeight)
{
    if (ceilingHeight - floorHeight > 160.0f)
    {
        mario.X = nextX;
        mario.Z = nextZ;
        mario.Floor = newlyFoundFloor;
        mario.FloorHeight = floorHeight;
    }

    mario.Y = floorHeight;
    return AirStepLanded;
}
```

This is unusual because the result says "landed" even when the close ceiling
causes some of the normal landing updates to be skipped. A useful Pedro spot
must also have enough horizontal overlap between the floor and ceiling for
Mario to occupy the cramped region.

## How a landing can create dust

Landing does not create dust immediately. The landing result selects a landing
action, and that action changes Mario's forward speed before checking for dust.

There are two important controller cases:

- With analog-stick input, the flat-floor speed calculation multiplies the
  current speed by `0.98f`.
- With no analog input, the game applies a fixed slowdown. Its size depends on
  the floor class.

After that speed update and a ground step, the game requests dust only if the
resulting forward speed is strictly greater than `16.0f`.

The project has exact 32-bit floating-point examples for every relevant flat
floor class. In those examples, the same starting situation can leave the
analog-input result above 16 while the neutral-input result is at or below 16.
This is the basic controllable choice: one input requests dust and the other
does not.

This result is about the calculation itself. A complete proof still needs to
show that both input choices repeatedly preserve a real, reachable stock Pedro
state.

## Why dust can affect random numbers

The game has one shared 16-bit random seed. Calling its `random_u16` function
changes that seed. Many unrelated objects can call the same function, so the
order and frame of every call matter.

The checked dust chain is:

```text
Mario requests dust
  -> mist particle spawner
  -> two white-puff particles
  -> random X and Z offsets for each puff
  -> four dust-owned random_u16 calls
```

Thus, under the proved allocation, object-list, active-flag, and timing
conditions, the dust episode contributes four seed advances on its frame. If
other objects make `k` calls during the same window, the total is four plus
`k`, not simply four. The proof deliberately records those outside calls
instead of pretending they do not exist.

Parts of this chain have been executed directly in CompCert's formal Clight
semantics for both supported versions. The complete retail object loop and a
controller-only reachable memory snapshot are still open obligations.

## Tic Tock Clock: spinners and cogs

Tic Tock Clock, usually shortened to **TTC**, is a level containing moving
clockwork platforms. Two relevant families are **spinners** and **cogs**. They
are separate game objects with different shapes and movement rules; "spinner"
is not a general name for every rotating TTC platform.

The proved interval later in this guide concerns only the spinner family. A cog
can still be part of a Pedro spot because the generic landing code does not care
what kind of object supplied the floor or ceiling. It only cares about the
surfaces it found, their overlap, and the gap between them.

### Spinners

The spinners used by the current proof tilt around a horizontal axis. Their
collision surfaces therefore change height as their pitch angle changes.

In the random clock setting, a spinner chooses a direction and a change timer
using the shared random seed. After a direction change, object timers 1 through
5 are stationary. The spinner then moves by 200 angle units at timer 6, another
200 at timer 7, and continues in that direction until its later change time.
The possible change timers are 30, 60, 90, and 120.

Changing the random seed can influence a future direction or timer choice. It
cannot retroactively change a direction that the spinner has already selected.

### Cogs

The game's `bhvTTCCog` object covers two shapes: a hexagonal platform and a
triangular prism. The pinned TTC level data lists eight cog placements: six
hexagons and two triangular prisms. Seven occur before the first spinner in the
object order already checked by the project's RNG census.

Cogs turn around the vertical Y axis, so their yaw changes their horizontal
footprint rather than tilting the whole platform up and down. That can still
create or remove the horizontal overlap needed for a Pedro spot. A lower cog's
top and an upper cog's underside are therefore legitimate floor/ceiling
candidates. Several stock hexagon placements have promising vertical spacing
once the mesh's 153-unit thickness is considered, but that observation has not
yet been promoted into a checked geometry theorem.

Cog motion also differs from spinner motion:

- on the slow setting, the cog speed is 200 angle units per frame;
- on the fast setting, it is 400;
- on the random setting, the current speed changes toward a target by 50 per
  frame; and
- after reaching a target, the cog uses the shared RNG to choose a new signed
  target from zero through 1,200 in steps of 200.

Each cog also has a fixed clockwise or counter-clockwise multiplier selected by
its level data. The game multiplies that direction by the current speed and
adds the result to the cog's yaw each frame.

This matters twice. First, dust manipulation could affect a cog's next target
speed and direction. Second, a cog choosing a target consumes random values of
its own, so cogs can change the seed seen later by a spinner or another cog.
The existing RNG census accounts for cog call sites, but it does not yet prove
a complete cog Pedro schedule.

The spinner theorem cannot simply be relabeled as a cog theorem. A cog proof
needs to:

1. generate and authenticate the hexagon and triangle collision arrays;
2. enumerate all eight placements, shapes, and fixed directions in US and JP;
3. transform their collision triangles over exact yaw values;
4. find overlapping floor/ceiling pairs with a gap in `(0, 160]`;
5. prove a reachable Mario entry and both landing-input continuations; and
6. combine the cog's gradual random-speed rule with every dust and non-dust RNG
   call on the relevant frames.

## The proved TTC Pedro interval

This section is specifically about two **spinners**, not the TTC cogs.

The collision proof found one concrete cramped region shared by two spinners:

- floor: spinner 7, triangle 12;
- ceiling: spinner 0, triangle 4;
- common horizontal point: X = 1045, Z = 1603;
- certified pitch values: 15,664 through 16,031, inclusive.

There are 368 integer pitch values in that interval, or roughly two degrees of
a full rotation. At every certified pitch, for both US and JP:

- the point is strictly inside both triangles when viewed from above;
- the lower triangle is classified as a floor;
- the upper triangle is classified as a ceiling; and
- the computed vertical gap is greater than zero and at most 160.

These are not measurements copied from a video. The proof reconstructs the
triangles from the generated game data, applies the game's 32-bit floating-point
transformations and 16-bit terrain conversion, and lets Coq check every angle
table entry in the interval.

The widened interval is large enough for one carefully chosen movement. From
pitch 15,864, direction `-1` moves the spinner by 200 units to pitch 15,664,
which is still certified.

It is not large enough for the next movement in the same direction. Two moving
frames produce a total change of 400 units. Starting anywhere in the certified
interval, either `pitch + 400` or `pitch - 400` is outside it. Coq proves this
for every possible random observation, because no random observation can alter
the already-selected direction between those two frames.

So the present interval is a real Pedro geometry witness and supports one
controlled movement, but it is not yet the full "keep Mario there" schedule.
A successful final argument needs a sequence of other valid intervals, a
moving horizontal witness, or another game effect that preserves the Pedro
configuration beyond the second moving frame.

## What Coq and Clight contribute

Ordinary tests run a few selected inputs. A Coq theorem instead describes all
values satisfying its stated conditions, and its proof is checked by a small
proof kernel. A rough C# analogy is the difference between a unit test and a
compiler-checked contract, except the contract itself must have a complete
mathematical proof.

The project uses three layers:

1. The decompiled C source is pinned to one exact revision.
2. CompCert's `clightgen` converts selected C files into Clight syntax trees.
   This is similar to inspecting a compiler AST rather than searching source
   text.
3. Coq definitions and theorems inspect those trees, calculate exact game
   arithmetic, and, where completed, execute functions according to CompCert's
   formal C semantics.

A **source receipt** proves that an expected branch, constant, field write, or
function call really occurs in the generated program. An **execution theorem**
is stronger: it proves how that code runs from a specified memory state. The
project labels these boundaries explicitly so a source-shape check is never
presented as a complete gameplay proof.

The build also rejects unfinished proof commands such as `Admitted` and checks
the important theorems for undeclared assumptions. Generated Clight files are
reproducible and are not edited by hand.

## What is known, and what is not

The project currently establishes that:

- the relevant Pedro landing branch exists in the generated US and JP code;
- controller input can place the landing speed on opposite sides of the dust
  threshold for each flat-floor slowdown class;
- the checked dust path owns four random-seed advances under explicit runtime
  conditions;
- TTC's random spinner timer and direction rules are modeled;
- the concrete TTC Pedro geometry exists throughout pitches 15,664--16,031;
- one selected 200-unit movement stays inside that interval; and
- the following movement must leave that same fixed interval.

The project has **not** yet proved the final gameplay claims. In particular, it
still needs:

- a controller-only route into the TTC Pedro state in both supported versions;
- a reachable retail object-pool, particle-flag, and object-list state;
- complete linked execution of the remaining dust behavior chain;
- a geometry/control schedule that survives more than one moving frame; and
- a separate collision and motion certificate for any claimed cog Pedro spot;
- a classification and repeatability proof for every stock Pedro spot.

That distinction is important: the existing work proves the mechanism and a
substantial concrete TTC interval, but it does not yet prove that a player can
perform the entire strategy in an unmodified retail game.
