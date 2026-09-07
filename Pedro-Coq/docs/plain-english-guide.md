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
There is also a conditional execution proof for dust requested during the
sliding phase after a slide kick. The latest work proves that two previously
assumed helper paths execute and preserve Mario's position and floor reference.
The sliding-motion and ground-step helpers remain open.

The project still has no complete witness of Mario staying in the cog Pedro
spot and controlling RNG there. Some recorded experiments start from a declared
near-cog test placement; they do not establish a route from normal level entry.
See [the cog plan](notes/ttc-cog-plan.md) and
[the latest execution report](notes/ttc-cog-transition-execution.md).

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

Notice that Y is still assigned. This call preserves all three coordinates
only if Mario was already at the returned floor height. Other code can move
Mario or change his action before or after this call. Seeing one such "landed"
return therefore does not establish that he stays in the spot for the whole
frame, or for the next frame.

## How a landing can create dust

The landing return itself does not create dust. The action handling that
return determines what happens next. The common landing action studied in the
original proof changes Mario's forward speed before checking for dust.

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
state. It must also show that the landing action reaches this calculation:
the game computes an off-floor input flag from Mario's floor state, and that
flag can cancel the action before its dust-producing code.

### The sliding phase after a slide kick

A slide kick has its own action sequence: an airborne kick, a possible bounce,
and a ground-sliding phase. The sliding phase has a different dust-request
path from the common landing action above. Its dust assignment can run after
the ground step reports a wall stop. The checked cramped-gap branch can return
that stop result even without a wall reference.

The latest proof executes the generated sliding action under explicit conditions
on its starting state and intermediate helper results. These include an already
selected slide animation that has not ended, no intended stick movement, an
off-floor flag, a null wall reference, and readable speed, floor, animation and
sound-queue data. A reachable cog state satisfying all these conditions has not
yet been exhibited.

A **helper** is simply another function called by the action. Two previously
assumed helper paths are now executed in the proof:

- The no-wall reflection requests the hit sound and reverses forward speed,
  using the actual velocity setter and sine/cosine table reads. Its writes
  preserve Mario's position and retained floor reference.
- The action setter changes Mario to backward ground knockback and resets
  the relevant action fields. Its writes also preserve position, floor and
  particle requests.

The proof also corrects the terrain-dependent sound to TTC's stone-terrain
case and executes that sound-selection helper. TTC's terrain category and the
floor Mario still references are separate facts; the retained floor remains
an explicit condition of this proof.

Two helper executions and their position/floor preservation remain assumed:
`update_sliding`, which updates sliding motion, and `perform_ground_step`,
which performs the ground movement and collision queries. Subject to those
conditions, the action requests **dust and vertical stars**, selects backward
ground knockback, and preserves the checked position and floor reference.

Selecting the next action does not execute it. The following knockback update
needs a different animation and more movement code. The airborne entry and
bounce also need their own preserving execution proofs. The current result
therefore identifies a dust candidate; it does not establish dust creation
while Mario remains in the actual cog spot.

## Why dust can affect random numbers

TTC cogs use the shared 16-bit gameplay random seed. Calling its `random_u16`
function changes that seed. Many unrelated objects can call the same function,
so the order and frame of every call matter. Audio has a separate random
generator; hearing a sound alone does not show that the cog seed changed.

Before counting dust's random calls, three separate questions must be settled:

1. Does the action request dust while preserving the spot?
2. Does the request survive the common cleanup after the action?
3. Does the particle system accept it and run the resulting objects?

The latest proof checks the cleanup at the end of the moving-action dispatcher,
the routine that selects an action handler and performs common follow-up work.
With the specified off-floor input and no in-water flag, the dust and star
requests survive this tail unchanged. With the in-water flag also set, the
same tail removes dust and requests a wave trail instead; the stars remain.
Only this tail is executed here. The dispatcher's earlier cancellation checks
and action selection still need to be connected to the actual cog state.

There is another gate in the particle system. Mario's request flags and his
object's active-particle flags are different fields. If the active dust bit
is already set, the proof executes the complete particle-spawn function and
shows that it returns without allocating anything or changing memory. If the
bit is clear, the existing caller proof still assumes successful execution of
allocation and position copying. A dust request alone does not settle that case.

Once its runtime conditions hold, the checked dust chain is:

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
controller-only reachable memory snapshot are still open obligations. For the
slide-kick candidate, the accompanying vertical-star request must also be
followed through its consumers before the complete random-call order is known.

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
candidates. The proof now checks the generated cog collision arrays, all eight
placements and their mappings, and one concrete overlapping pair at specified
angles. Its floor is at Y = -2088 and its ceiling at Y = -1934: a 154-unit gap,
within the Pedro branch's 160-unit limit. These calculations use the generated
game data and exact game arithmetic.

This is a certificate for the pair of surfaces. It does not yet prove that
the complete collision search selects that pair from a reachable Mario state,
or that successive action updates keep Mario there.

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

The project also executes one complete generated cog update, including its
speed-approach and random-number helpers. In the checked random-mode example,
speed and target start at zero, the fixed direction multiplier is +1, yaw is
57344, and the seed is 16. The update leaves speed, target and yaw unchanged
while its two random calls advance the seed to 54874. This establishes one
stationary update from the stated memory conditions. Reaching those conditions
and keeping both relevant cogs fixed across successive frames remain open.

Recorded experiments have reached individual close-gap air returns, but the
checked full paths fail to preserve the required Mario and cog state across
successive updates. Ground-pound startup that holds Mario still, or an impact
with an ordinary supporting floor, does not fill that gap. The
[successive-update report](notes/ttc-cog-successive-updates.md) records these
limitations.

A short stationary window, such as four frames, could be useful if a preserving
action can produce an accepted RNG effect in time. Its length alone does not
establish that. Cogs update before Mario and the dust objects in the checked
object order, so dust cannot change a cog's earlier draw on the same frame.
The remaining argument must connect entry, action preservation, accepted
particles and every intervening RNG draw to the later cog decisions.

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

The widened interval contains one carefully chosen change of platform angle.
From pitch 15,864, direction `-1` moves the spinner by 200 units to pitch 15,664,
which is still certified.

It is not large enough for the next movement in the same direction. Two moving
frames produce a total change of 400 units. Starting anywhere in the certified
interval, either `pitch + 400` or `pitch - 400` is outside it. Coq proves this
for every possible random observation, because no random observation can alter
the already-selected direction between those two frames.

This checks the geometry at those angles; it does not execute Mario's actions
across the movement. Extending this spinner result would need other valid
intervals, a moving horizontal witness, or another preserving game effect.
Leaving this particular interval does not rule out other spinner arrangements
or the separate cog target.

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

An explicit condition of a theorem can still be a substantial unfinished task.
For example, a theorem saying "if the sliding and ground helpers execute and
preserve these fields, then the caller does too" does not prove those helpers
or show that gameplay reaches their starting state. A successful build and
assumption audit do not remove conditions written into the theorem itself.

Two remaining boundaries also concern how the formal model represents the
retail game. Sliding calls the external square-root function `sqrtf`; checking
the retail instruction alone does not supply its formal execution contract.
Particle allocation reaches an address-conversion helper that performs integer
operations on an N64 address. CompCert normally represents a pointer as a memory
block plus an offset. The proof still needs to establish the connection between
that representation and the game's numeric addresses so that this helper can
execute correctly in the model.

## What the all-RNG inventory establishes

The source inventory now covers 41 generated C compilation units per version,
including every Mario action group, interactions, camera and environmental
effects. Its structural checks account for 282 direct RNG call sites, 16
functions containing computed calls, 53 functions that write particle-request
fields, and all 18 entries in Mario's particle table. These are source-code
counts, not the number of random draws in a frame.

That inventory provides a checked list of places requiring analysis. A computed
call chooses its target at runtime, much like invoking a C# delegate, so listing
it does not identify which function runs in the cog state. Likewise, finding
every particle writer does not prove which writers Mario can reach while
staying in the spot.

One exclusion is fully executed under its stated starting conditions: the
environmental-particle update in its NONE mode returns with all memory unchanged,
including the gameplay seed. Connecting those starting conditions to normal TTC
entry still needs proof. The remaining action, particle, object and camera paths
must either be executed in a preserving state or excluded by proved conditions.
The exhaustive claim about all available RNG control in the cog spot remains
open. See [the all-RNG report](notes/ttc-cog-all-rng.md).

## What is known, and what is not

The project currently establishes that:

- the relevant Pedro landing branch exists in the generated US and JP code;
- the landing-speed calculation has input-dependent examples on opposite sides
  of the dust threshold for each flat-floor slowdown class;
- a concrete cog surface pair has a certified 154-unit gap, and one complete
  cog update preserves its angle under explicit starting conditions;
- the slide-kick sliding caller requests dust and stars while preserving its
  checked position/floor fields, conditional on two remaining helper executions
  and their preservation conditions;
- the dry dispatcher tail keeps those requests, its water case clears dust,
  and an already active dust bit makes the spawn function skip allocation;
- the checked dust path owns four random-seed advances under explicit runtime
  conditions;
- the broader RNG and particle source inventory is checked; and
- the earlier spinner geometry spans pitches 15,664--16,031, with one selected
  200-unit angle change inside it and two successive changes in the same
  direction leaving that fixed interval.

The project has **not** yet proved the final gameplay claims. In particular, it
still needs:

- a controller-only route into the cog Pedro state in both supported versions,
  followed by actual successive updates that preserve Mario and the relevant cogs;
- execution and preservation proofs for `update_sliding` and the full
  `perform_ground_step`, including the actual surface selections;
- the complete moving-action dispatcher, airborne slide-kick entry/bounce and
  following knockback update in that state;
- accepted particle allocation, the N64 address connection, and the complete
  dust/star behavior chain in a reachable object-pool and object-list state; and
- preserving input choices or proved exclusions for all relevant RNG sources,
  with their ordered draws connected to future cog decisions.

The current proofs leave both the sustained cog entry and preserving RNG
control unresolved. The [checklist](checklist.md) tracks the individual remaining
obligations.
