# Eyerok movement, Mario's warp, and the proof boundary

This document is written for a software engineer who does not know Super
Mario 64. It explains the game mechanism, the state machines in this project,
the new Area 2 route calculation, and the line between proved results and
plausible game behavior.

## Executive summary

Eyerok is a boss made from two independently updated hand objects. The boss
arena is Area 3. The inside of the pyramid is Area 2. A pair of sloped tunnel
floors switches Mario between those areas.

The switch is based on **Mario's cached selected floor**, not on Eyerok
touching the floor. If that cached floor is the Area 3 instant-warp surface,
the instant-warp operation changes to Area 2 without changing Mario's
coordinates or velocity. In an ordinary coherent state, a hand floor instead
means no area change. Original JP has an additional same-frame hazard described
below: after the warp operation, a retained raw `gMarioPlatform` address may
still displace Mario during Area 2's object update.

The current machine-checked results are:

- the executable audited source-shaped kernel excludes
  `DOUBLE_POUND + grounded + gravity 0` for every modeled Mario-input policy,
  including never pressing A and continuously holding A;
- a separate velocity-aware Rocq relation now closes the stronger proposed
  seed, `DOUBLE_POUND + airborne + gravity 0 + positive velocity`. It audits
  every source entry into `IDLE` and proves that `IDLE` can inherit only zero
  or negative vertical velocity;
- the old 280-unit global separation argument is false and removed; an exact
  phase-local trace proves the approaching second hand misses the sibling
  closed top, first horizontally and then vertically;
- a separate source-shaped lifecycle proves that live hands cannot acquire the
  FAR_AWAY or IN_DIFFERENT_ROOM bits that would skip movement while still
  advancing the hand action;
- the older, geometry-relaxed relation bounds the first hand's origin at
  `672`, the second hand's origin at `1467`, the second surface at `1974`, and
  Mario's generously modeled peak at `2604`;
- a new source-shaped first-hand barrier proves that the first hand cannot
  realize the premise behind those positive heights: its origin is at most
  `-862`, its open collision top is at most `-355`, and it cannot select even
  the lowest tunnel floor;
- a two-hand extension grants the second hand every static Area 3 floor and
  every possible contact with the first hand's tallest mesh. Because the
  first surface is at most `-355`, it cannot beat the static floor maximum
  `384`; therefore the second origin is at most `672`, its surface at most
  `1179`, and its generously modeled Mario peak at most `1809`;
- consequently, the requested first-surface Y `1179`, second-origin Y `1467`,
  second-surface Y `1974`, and Mario Y `2604` constructions are all
  unreachable in the source-shaped barrier relations;
- hash-authenticated-US-ROM continuations from disclosed local fixtures show
  that the normal finite double-pound rise is boardable in ordinary collision
  when Mario completes two prepared air updates before the hand's first +85
  step. Both an already-held-A jump kick (no new A edge in the measured
  suffix) and a B-only speed kick (A always released) stay on all six positive
  steps and reach closed-top Y `-943`; neither predecessor is controller-
  authenticated;
- the standard `-4` attack certificate proves only the vertical arithmetic of
  an explicit schedule. It does **not** prove its conditional 46-unit recovery
  query becomes a reboard. A separate local inherited-long-jump ROM
  continuation really reboards the nonlethal hand after it reaches home height,
  later reaching top Y `-928` in `TARGET_MARIO`. Its lethal counterpart never
  becomes a platform: early vertical windows miss in X/Z, later steering gets
  the hand only as a floor below Mario, and deletion wins before landing;
- conditional on attaining the stricter second-hand surface ceiling `1179`
  and the full triple-jump envelope, a lower route enters Area 2 at Mario Y
  `1809` and its audited quarter-step selects and snaps to floor Y `1280`;
  this is a handwritten route witness, not authentic reachability;
- the obvious never-A substitute, a B-only speed-kick dive, cannot reach that
  Y `1280` top by a direct wall-avoiding, seam-free speed-at-most-48 approach:
  its height window is too short to clear or detour around the platform walls;
- an already-held-A punch can become a jump kick without a new A press. It has
  the same 20-unit vertical launch. If its inherited forward speed is at most
  48, even a generous 455-unit path cannot clear or detour around those walls;
  higher inherited speed and post-wall continuation remain open;
- `2604` is too low for a direct landing at Y `2940`, the upper warp-overlap
  platform at Y `4429`, the star platform at Y `4815`, or direct interaction
  with the star at Y `5050`;
- the combined abstract route model does admit a conditional landing on the
  Y `1967` platform at `(387, 1967, -500)`. That is the point on that platform
  with minimum horizontal distance to the star;
- no stream of finite IEEE binary32 hand positions can be unbounded as real
  heights;
- binary32 addition has the exact fixed point `2^31 + 100 = 2^31`, and the
  modeled recurrence remains there once started at `2^31`;
- Eyerok forms two real Pedro configurations, but neither checked
  configuration is an authenticated useful 0-A or 0.5-A speed engine;
- a hand's own explosion fragments cannot reuse that hand's slot, and the
  sibling cannot explode soon enough to reuse it in the one-active-update
  stale-pointer window. This same-area result applies to both US and JP; and
- US clears `gMarioPlatform` when Area 2 loads. Original JP does not: it keeps
  the raw slot address until the first Area 2 object update consumes and then
  refreshes it. An ordinary coherent JP warp carries `NULL`, while authentic
  construction of the required stale floor plus nonnull hand address remains
  open.

The word **conditional** is important. The geometry-relaxed vertical relation
admits the old starting hand heights, but it has no X/Z state and lets a hand
use any upward Area 3 floor regardless of whether that hand can reach it. The
new barriers close that abstraction gap for both hand-height calculations.
They do not yet prove a linked Clight frame, source-semantic Mario contact, or
an exact controller trace. The route model also over-approximates Mario's air
steering.
Its Y `1967` trace is
a counterexample to "the old formal height bound is numerically too low for
every useful landing," not a verified controller-input movie for the original
game.

That qualification is essential. The project does not yet prove that every
linked Clight or original-ROM frame refines the kernel and vertical relation.
The pinned-source audit makes the no-go result substantially stronger than a
free-standing toy model, but the unqualified original-game reachability
question remains open at this source-to-model bridge.

## Pedro spots and particle platform displacement

Two proposed speed-building ideas were checked separately. Eyerok really can
form Pedro geometry, but neither checked form is a useful authenticated speed
engine. The hands' own explosion particles cannot produce the required
same-area slot replacement. Cross-area behavior is version-specific: US closes
it by clearing the saved platform pointer, while original JP leaves a broader
stale-slot displacement candidate open.

### Sleeping-hand Pedro strip

A sleeping right hand has a narrow place where a lower floor at Y `-1459`
and a ceiling at Y `-1421` overlap. The 38-unit gap is small enough for the
Pedro branch. This is real collision geometry, not an approximation.

Mario does not normally reach it from the outside. Air movement resolves two
50-unit-radius wall cylinders before it asks for a floor or ceiling. The outer
thumb wall leaves Mario at world Z `-3116`; the useful internal part begins
strictly beyond Z `-3216`. Crossing from outside therefore needs a single
quarter-step longer than 100 units, corresponding to horizontal speed above
400 along that direction.

Example: the US-ROM probe injects the same local long-jump state twice. At
speed 48, wall handling wins and Mario lands on the ordinary upper hand floor.
At preloaded speed 424, the intended step crosses the whole wall band. Retail
code reports a landing, changes only Y to `-1459`, and preserves Mario's old
X/Z and old arena-floor reference. That is a genuine Pedro landing. It is not
a route to speed 424; assuming the high speed needed to enter would be
circular if the proposed purpose of the spot is to create that speed. Because
the fixture injects both `ACT_LONG_JUMP` and its starting speed, it proves no
A-press count: not 0 A, not 0.5 A, and not a fresh-A route.

### Two-hand wake sandwich

The hands wake on different updates. The right hand begins moving three
updates before the left, so from wake updates 5 through 11 the left palm is a
floor below the right palm's ceiling. The audited gaps are:

```text
16, 39, 63, 84, 105, 126, 144
```

On update 12 the gap is 162, which is too large for the 160-unit Pedro test.
There is an exact local entry counterexample on update 11:

```text
old Mario X/Z:      (-121, -3240)
intended X/Z:       (-121, -3241)
intended Y:         -1304
selected floor:     -1284
selected ceiling:   -1140
```

At this Y, the lower wall query is above the left hand's walls and the upper
wall query is below the right hand's walls. A one-unit ordinary quarter-step
therefore reaches the overlap and takes the Pedro branch. Triggering Eyerok's
wake itself needs only Mario's position; it reads neither A nor RNG.

What remains unproved is Mario's controller-only path to that exact airborne
state on exactly update 11. A direct B-only speed kick and an already-held-A
jump kick each rise 60 units, while the first wake query window starts 99
units above the arena; those direct setups miss by 39. Boarding a hand first,
carrying another air action into the window, seams, and other setups have not
been exhaustively excluded.

Even granting the update-11 entry, it is not a speed grinder. The Pedro gap
fails on the following update, so ordinary entry permits at most one air-speed
update rather than a repeatable grind. For the common
`update_air_with_turn`/`update_air_without_turn` family, the ideal-arithmetic
relation proves at most 3.85 per call and 26.95 over seven
calls; the 3.85 branch starts below `-16` and actually reduces backward-speed
magnitude. If the starting speed is nonnegative, its per-call bound is 1.50.
Retail binary32 rounding can slightly exceed 3.85, and a coarse-spacing witness
gains exactly 4 per call and 28 over seven calls. We therefore use 4/28 as the
conservative original-ROM-facing envelope, but have not proved that envelope
as a CompCert Float32 theorem. Other air-action entry writes have also not been
exhaustively bounded. The one-update geometry, rather than the exact decimal
envelope, is what rules out sustained Pedro grinding through this wake witness.

### Why Eyerok's own fragments cannot replace the hand slot

Particle platform displacement needs this exact object-slot sequence:

```text
Mario stands on object slot S
-> that object unloads and S becomes free
-> before next frame's platform-displacement call, a rotating particle takes S
```

An Eyerok hand creates mist particles and 30 rotating dirt triangles
before it marks itself for deletion. Its own slot is still occupied during all
of those allocations, so its own fragments cannot take that slot.

The other hand cannot supply a fragment on the required next frame. Only a
visible eye accepts the lethal hit. Opening an eye claims the boss's exclusive
eye lock, and a dying hand retains that lock for its entire 40-frame death
animation. The lock is cleared in the same block that explodes the first hand.
Only then can the sibling begin its 30-frame open animation, after which it
still needs a lethal hit and another 40-frame death animation. That delay is
far longer than the one-frame stale-platform window. Area 3 contains no third
surface object that can fill the role.

That proves a narrow, version-independent result: neither Eyerok hand can
supply the rotating Eyerok fragment needed by this exact same-area stale-slot
construction. It does not prove that every particle or stale-slot technique in
the level is impossible.

### US and JP differ at the Area 3-to-Area 2 load

Eyerok exists in Area 3, not Area 2. In US, PAL, Shindou, and iQue builds,
loading the new area calls `clear_mario_platform`. A saved hand pointer is
therefore cleared before Area 2 can use it. That is the additional US blocker.

Original JP intentionally omits that call. Its frame order is:

```text
read Mario's cached Area 3 warp floor and change area
-> unload Area 3 and load Area 2, retaining the raw slot address
-> update Area 2 terrain objects
-> apply platform displacement through that address
-> later unload inactive objects and refresh gMarioPlatform
```

The application checks only that time stop is inactive, Mario exists, and the
pointer is nonnull. It does not check the slot's active flag, behavior, or area.
The retained value is therefore an **address**, not a surviving Eyerok hand.
At application time the address can contain residual freed-hand fields or a
new Area 2 object.

There is an important ordinary-case blocker. The instant warp is a static
floor, so a coherent floor query stores no platform object. If the hand is the
selected dynamic floor, `gMarioPlatform` can point at it, but the warp does not
trigger. The natural JP emulator case confirms this ordinary state: Mario was
placed on the genuine Area 3 warp floor, its owner and `gMarioPlatform` were
both null, and Area 2 produced no displacement.

That is not an unconditional impossibility proof. `check_instant_warp` reads a
cached floor from Mario's preceding update, whereas platform refresh performs
another floor query. Pedro collision can report a landing while retaining an
old floor reference. We have not proved or demonstrated an authentic frame in
which the cached floor is the static warp triangle while the freshly saved
platform address is an Eyerok hand. That stale-floor/hand-pointer mismatch is
the first open JP prerequisite.

For controlled comparisons, the JP probe injected each genuine hand-slot
address before taking the real warp. Area 2 reused right slot 32 as allocation
1 and left slot 73 as allocation 2; both became `bhvStaticObject`, whose linear
and angular motion fields were zero. Retail breakpoints observed one unchecked
application through each address, effective delta `(0, 0, 0)`, unchanged stored speed, and the later
pointer refresh to null. This was not an Eyerok explosion,
not an authentic stale-floor setup, and not a 0-A or 0.5-A route.

The original JP ROM used by the probe has SHA-1
`8a20a5c83d6ceb0f0506cfc9fa20d8f438cafe51`. A clean pinned-revision
`VERSION=jp COMPARE=1` build was byte-identical to it. The checked common
Clight units come from pin-identical source; the JP area/platform units come
from the available 36fb source with its TAS hack disabled. The audit proves
the three relevant normalized function bodies are identical to the pinned
revision, and a separate pinned build authenticates the ROM.

### Normal speed versus PU speed

Platform displacement writes Mario's position and facing, not his stored
velocity or `forwardVel`, so it is not a mechanism for accumulating stored
normal or PU speed.  The sleeping-hand JP trace still moves Mario by zero, but
the separately audited death lifecycle has a conditional positional producer:
10 or 11 suppressed Area-2 macro allocations align the rotating Spindel with
the expected first-hand or last-hand stale ordinal.  The active Coq proof now
joins all four conditional PU gates.  It extracts the real Y=`768` ceiling over
the upper warp, proves that a closed hand standing on the recorded warp floor
has top Y=`652.08044` and Pedro gap `115.919556`, uses three negative Z periods
to preserve the local collision point, and computes Spindel's exact first apply
as `(0,5469.4233,-197679.7)`.  The older four-Y-period witness still reaches
Y=`5070.145`, but cannot itself install a platform because its raw Y is far
outside the four-unit floor test.  The new result is a positional lever arm,
not speed, and is not yet authentic.  The new source/Coq audit rules out stock
hand travel to the selected Z universe: even a generous two-hand support band
is only `[-4413,204]`, followed by a `60919`-unit no-floor gap.  Loading before
transport in an ordinary frame instead requires at least `195559` units of
Mario-owned Z motion.  The real unfixed-dialog time-stop window can retain the
surface while airborne Mario updates, but it freezes the hands, disables
platform displacement, and Eyerok never exposes it with the needed hand
surface: the intro freezes both pre-fight hands at home Z=`-3393`, whose
collision ends at `-2934` rather than reaching the warp, while the death dialog
starts at timer 60 after both 40-frame dying hands have disappeared.  Area 3
has no other local dialog object, so the clean PU installation is closed in the
audited stock model rather than left as an airborne-distance obligation.
Area 2 does contain fifteen normal individual coins whose no-respawn records
can in principle suppress ten or eleven allocations, although their exact
zero-A collection route is open.  Spindel's output remains `197179` raw Z
units from the star and at least `195032` from an Area-2 warp, so the
zero-displacement instant warp is not a reanchor.

The ordinary branch is now separated from that failed PU installation.  A new
authenticated baseline census checks all Area-2 allocations from 53 through
83, the complete suffix that a deletion-only shift can place at either
death-hand stale ordinal.  Only allocation 64, Spindel, has an X/Z or angular
field used by platform displacement; allocations 60 through 63 move vertically,
but the platform code never adds platform Y velocity to Mario.  The exact
original-JP binary32 transform at the recorded warp center is
`(0,346.08044,-1100)` to `(0,338.5134,-1138.419)`, a small downward/backward
shift.  At central X/Z the complete static ceiling set is Y=`-409` and Y=`768`,
so any Pedro installation must put the hand floor in `[-569,-411]` or
`[608,766]`; these correspond to closed-hand pivot bands `[-875,-717]` and
`[302,460]`, plus the open-hand low band `[-1076,-918]`.  This proves that the
ordinary payload is not the hoped-for lift and identifies the exact remaining
installation poses, but it does not yet exclude a later use for the small
shift, arbitrary state-changing suppression, or the residual fields of a slot
that Area 2 never reuses.

The corresponding Rocq certificates are in `PedroSpot.v`,
`EyerokParticleDisplacement.v`, `JPPlatformPersistence.v`, and
`ExploitScenarioVerdict.v`. They separate the common fragment result, the US
area-clear result, and the JP pointer-policy model. The handwritten certificates
are assumption-free. The combined verdict imports generated Clight AST facts
and therefore inherits the standard CompCert/classical assumptions reported by
`Print Assumptions`. These are source-audited AST-shape and abstract-model
theorems, not a linked whole-program Clight refinement. The JP ordinary-null
theorem assumes floor/platform coherence; it does not prove that every
authentic prewarp frame is coherent.

The active project additionally contains `JPEyerokStaleHand.v`,
`JPEyerokStaleHandPU.v`, and `JPEyerokStaleHandOrdinary.v`; the first packages
the corrected sleeping-hand no-op receipt, the second keeps the conditional PU
allocation alignment and closed installation separate, and the third proves
the ordinary suffix, unique effective replacement, exact displacement, and
two Pedro bands.

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
so that operation preserves X, Y, Z, action, and velocity. On original JP,
the later object-update phase can still apply a retained platform address as
described above.

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

In an ordinary coherent state, the same coordinates with
`floor = Eyerok hand surface` do not trigger the warp. A raised hand can only
help the ordinary route indirectly: Mario must leave the hand's footprint,
remain over the warp's X/Z footprint, and have the static warp surface become
his selected floor. The unresolved JP alternative is deliberately incoherent:
the cached floor would still be the warp while the separately refreshed
platform address points to the hand.

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
- every positive death-rise increment is at most 46, so height alone does not
  reject the hand if Mario was already supported and remains over its X/Z;
- the normal double-pound sequence starts with 85, then 70, 55, and so on. A
  stationary Mario is seven units too low after the first step, so that hand
  is rejected by the 78-unit filter; and
- a gravity-zero runaway that moves the hand by 100 every frame does not, by
  itself, carry a stationary Mario upward forever.

The 85-unit result changes if the action begins early enough in the observed
boss schedule. Surface objects update before Mario, and vertical platform
velocity is not copied to Mario. In the hash-authenticated local-fixture
continuation the input is
given at hand action timer 2. Retail Mario code then completes two air updates
before the selected hand launches:

```text
prepared Mario update 1:  Y -1228 -> -1208, velocity 20 -> 16
prepared Mario update 2:  Y -1208 -> -1192, velocity 16 -> 12
hand's next update:       closed top -1228 -> -1143 (+85)
gap before Mario updates: -1143 - (-1192) = 49
first air quarter-step:   -1192 + (12 / 4) = -1189
actual query gap:         -1143 - (-1189) = 46
```

The 49-unit value is the conservative gap before Mario's update. His first
quarter-step moves upward by 3, so the actual modeled floor query has a
46-unit gap. That is within the 78-unit floor buffer, and ordinary floor logic
selects and snaps Mario to the closed hand top at `-1143`. The later hand increments are
70, 55, 40, 25, and 10. In both hash-authenticated local continuations Mario's selected floor
owner and platform are the same hand on every positive step, and he reaches
top Y `-943`. The analyzer inverse-transforms Mario X/Z into the actual closed
top triangles and reports strict ordinary eligibility throughout; this is not
a seam or tunneling construction.

Timing is essential. Pressing B on the +85 frame is too late in the ordinary
central setup. The moved hand top is rejected, the arena floor wins, and the
hand underside is only 89.5 units above that floor. Mario's geometry input
requires 150 units, so it sets `INPUT_SQUISHED` before the walking speed-kick
branch runs. Even without that input cancellation, the upward ceiling branch
would zero Mario's velocity.

For the A Button Challenge, the two successful local modes are different:

- held A: the fixture injects the source-valid `ACT_MOVE_PUNCHING`, state-0
  predecessor while A has already been down since Area 3 entry. This is not a
  controller-authentic punch entry. Retail code observes `INPUT_A_DOWN` with
  no `INPUT_A_PRESSED` edge, enters `ACT_JUMP_KICK`, and writes velocity 20;
- never A: the fixture injects an interior `ACT_WALKING` predecessor with
  forward speed 29 and stick magnitude above 48, then supplies one B edge.
  Retail code itself enters `ACT_DIVE` and writes velocity 20. No A-down or
  A-pressed bit appears.

Both modes first require the ROM to report the hand as Mario's actual floor
owner and platform. The probe never writes hand position, velocity, gravity,
movement flags, floor, collision, action, or timer. It does inject Mario's
local predecessor and the boss schedule, so reaching those states and
synchronizing them from controller-only play remain open.

Hand collision is also loaded only while Mario remains near the hand. A hand
that escapes far above Mario eventually stops providing a usable dynamic
surface. This is why "the hand rises" and "Mario gets a high warp state" are
separate proof obligations.

There is also a 201-unit discontinuity when the hand changes from the closed
collision mesh (top offset 306) to the open-eye mesh (top offset 507). A Mario
standing on the old closed top cannot follow that mesh switch by ordinary
floor reselection because 201 exceeds 78.

`MarioHandContact.v` proves these statements as **height-only** conditions.
Passing the 78-unit inequality is necessary, not sufficient: Mario must also
remain inside the transformed triangle in X/Z, the hand must still load that
collision, it must win floor priority, and Mario's action must execute the
appropriate snap or landing.

## Why standing on the hand does not attack the eye

Eyerok's interaction hitbox is 100 units tall before the hand's 1.5 scale, so
its top is 150 units above the object origin. The closed collision top is 306
units above the origin and the open collision top is 507 units above it.

The object-overlap code rejects two vertical cylinders when the bottom of one
is strictly above the top of the other. Mario standing on either normal hand
top has his hitbox bottom above Y=150:

```text
hand hitbox top:       origin + 150
closed standing floor: origin + 306
open standing floor:   origin + 507
```

Rocq proves that neither standing pose vertically overlaps the attack hitbox,
regardless of Mario's own hitbox height. Thus the simple plan "stand on the
hand, damage the eye, and ride its lethal rise" does not work.

An ordinary attack-from-above bounce places Mario at origin+150 with vertical
velocity 30. The lethal hand's first positive displacement is 46, so its new
open top is origin+553. Even generously adding the full 30 to Mario first puts
him at only origin+180, far outside the 78-unit floor buffer. This is a proved
arithmetic obstruction, not yet a complete update-order theorem excluding
every exotic airborne re-entry.

The standard-gravity calculation in `AttackedReboard.v` is deliberately
narrow. For the listed nonlethal `-4` schedule, the open collision top remains
outside the 78-unit above-query buffer during the `+98` episode. When recovery
later installs the closed mesh, the listed Mario query is 46 units below that
top at absolute Y `-1228`. Passing this one vertical test is necessary, but it
does not prove X/Z containment, floor priority, a landing result, or even that
the handwritten Mario state is reached. It was incorrect to describe this
lemma as a proved snap. For the listed lethal `-4` schedule, the minimum
airborne gap is 153; on the first row with the hand's ground flag set, the gap
is 191. Both exceed 78. The certificate stops at that first grounded row and
does not claim an operational landing result.

The instrumented inherited-long-jump case behaves differently. The probe
starts from a disclosed local `ACT_LONG_JUMP` pose at hand-relative world
offset `(X,Y,Z)=(0,100,100)`, with velocity Y `-2`, forward speed `5`, and A and B
released. It does not write the hand's post-hit state. Retail code produces the
hit, the nonlethal `ATTACKED` action, velocity 30/gravity -4, hand movement,
collision meshes, and Mario floor queries. The hand finishes its `+98` rise
and returns to home height. Mario grabs the open top at Y `-1027` as the
actual floor and platform while the hand still has downward velocity `-26`
and no ground flag; the flag sets and velocity becomes zero on the next frame.
The recovery swap temporarily removes support;
Mario later reacquires the closed top at `-1228`, and the real
`TARGET_MARIO` action carries that top to observed Y `-928`.

This does not trigger the Area 3 to Area 2 transition. While Mario's selected
floor is the hand, the instant-warp test sees a hand surface rather than the
static tunnel warp. The lowest tunnel floor can first be queried at Mario Y
`-640`, so the observed `-928` top is 288 units too low by itself. Applying
the same 60-unit positive-rise envelope as the local jump-kick or B-only dive
would peak at `-868`, still 228 units short. This is only a result for that
20-velocity suffix; it does not exclude some different Mario impulse.

That is a genuine local reboard, but not a ride during the attacked upward
impulse. It is also not a controller-authenticated route: ordinary long-jump
entry requires an `INPUT_A_PRESSED` edge, and the probe does not construct the
earlier action, position, or boss timing. The measured interval itself keeps A
and B released.

The lethal version stages only health `2`, representing two earlier hits;
retail code performs the final hit, changes the hand to `DIE`, writes velocity
50/gravity -4, and preserves the open mesh. Because surface objects update
before Mario, two conservative pre-player-update hand-top gaps are `63` and
`7`. Mario's later quarter-step can only reduce these positive gaps, so they
pass the 78-unit height condition. At those frames the open front wall has left
Mario near hand-relative world Z `127`, outside the top boundary Z `76.5`, so
the hand is not selected.

Clearing the local fixture's inherited squish timer and applying full-stick
steering eventually moves Mario over the open top. In the Y-inward sample the
hand becomes Mario's selected floor at hand timer 27, but never his platform.
Mario is still above the floor and leaves the footprint again before falling
onto it. On the last live timer-39 row he is Y `-984`, 43 units above the open
top `-1027`, with velocity `-22`. A hypothetical next update reaches `-1006`,
still 21 units high; the following update would cross at `-1030`, but the
`DIE` handler deletes the hand first. The first post-deletion log row still
contains the old hand address in Mario's stored floor field, but the hand is
inactive and Mario's platform is null; this is a one-frame stale pointer, not
live support. The pointer is gone on the first crossing row. The
cardinal/diagonal and short
side-escape sweep is bounded evidence, not a proof over every analog sequence
or action change.

For the no-A special-gravity candidate, source code allows B-only
`ACT_CROUCH_SLIDE -> ACT_SLIDE_KICK`, but action initialization writes vertical
velocity 12 and raises forward speed to at least 32. More importantly,
`act_slide_kick` changes every `AIR_STEP_HIT_WALL` to
`ACT_BACKWARD_AIR_KB`, replacing its `-2` gravity with ordinary `-4` before
the later hand response. The probe reproduced this first blocker for both a
nonlethal and lethal local hit; neither selected the hand as a platform. The
injected speed-5 slide-kick state is not an ordinary slide-kick entry, so this
is not an unrestricted no-A impossibility theorem.

The proof boundary matters here: `AttackedReboard.v` checks integer arithmetic
over explicit lists and recorded constants. The deterministic source audit
checks the functions, action gates, mesh extents, and ordering used to
interpret them. The ROM analyzer checks the actual retail transitions and
floor/platform owners. There is still no linked-Clight operational theorem or
controller-from-reset trace deriving the fixture.

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

There is a second, more subtle candidate. Suppose some earlier action left the
hand airborne with positive vertical velocity, then changed to `IDLE` without
clearing that velocity. `IDLE` could select `BEGIN_DOUBLE_POUND`, which writes
gravity zero; `BEGIN_DOUBLE_POUND` could then select `DOUBLE_POUND`. In that
case the hand would continue adding its positive velocity every frame because
the `DOUBLE_POUND` handler changes gravity to `-20` only when velocity is zero
or negative.

The pinned source does not permit that sequence. There are exactly three
assignments to `EYEROK_HAND_ACT_IDLE`:

- `SLEEP -> IDLE`. A newly spawned sleeping hand starts with zero vertical
  velocity, and no sleep handler writes a positive velocity.
- `CLOSE -> IDLE`. The open/show-eye/close path contains no positive vertical
  writer. If the eye is hit, control goes to `ATTACKED` or `DIE`, not to
  `CLOSE -> IDLE`.
- `RETREAT -> IDLE`. Retreat itself writes no positive velocity. `ATTACKED`
  cannot reach recovery until its 25-frame animation has outlasted the eight
  `-4` gravity integrations needed to make its initial velocity 30
  nonpositive. `DIE` deletes the hand. The only potentially dangerous
  `DOUBLE_POUND -> RETREAT` transition requires the boss's terminal value
  `Unk104 == 1`; the boss can produce that terminal value only while its
  active-hand field is zero. A positively rising double-pound hand owns that
  active-hand lock, and the double-pound handler clears the lock only after a
  grounded frame with gravity below `-15`, where zero bounciness has already
  removed downward velocity.

There is one apparent sibling exception: `SHOW_EYE` also contains an
`ActiveHand = 0` write. Its surrounding guard is `NumHands != 2`, so it runs
only after the other hand has died; there is then no sibling double pound to
unlock. In the same one-hand phase, the surviving hand's `DOUBLE_POUND`
handler reasserts its own side into `ActiveHand` before any terminal or active
branch.

There is also a second, independent boss lock. When a hand opens its eye,
`OPEN` records that hand's side in `Unk1AC`. Think of `ActiveHand` as “a hand
is currently executing the selected attack” and `Unk1AC` as “an eye-exposure
sequence still owns the boss.” The boss is allowed to advance the
double-pound schedule only when **both** fields are zero. `SHOW_EYE` can clear
`ActiveHand` in the one-hand case, but it does not clear `Unk1AC`; that field
is released later by `CLOSE`, completed death cleanup, or `RETREAT`. For
example, a surviving hand that is visibly showing its eye may appear idle to
the first lock, but the second lock still prevents a new double pound. The
source audit enumerates every assignment to this second lock and checks the
two-field scheduler condition.

These transitions do not all execute an explicit `oVelY = 0`. That is not the
invariant. The invariant is that they can preserve only a value `<= 0`.
Consequently the two zero-gravity exits from `IDLE`—`BEGIN_DOUBLE_POUND` and
`TARGET_MARIO`—may preserve zero or negative velocity but cannot preserve a
positive one. `IdleVelocityInvariant.v` formalizes this control/velocity lock
and proves the airborne zero-gravity positive-velocity seed unreachable in
its over-approximating relation.

### Can two nonlethal hits stack their height?

No. A single hand starts with health 4. Its first accepted eye hit changes
health from 4 to 3 and starts `ATTACKED`; its second changes 3 to 2 and starts
another `ATTACKED`; a third changes 2 to 1 and enters `DIE`. There are two
nonlethal rises per hand, not an unlimited supply.

More importantly, the second nonlethal hit cannot be accepted while the first
rise or its recovery is still in progress. The only handler that consumes the
one-frame attack flag is `SHOW_EYE`. After an accepted nonlethal hit, the only
route back to an action that can expose and consume another hit is:

```text
ATTACKED -> RECOVER -> BECOME_ACTIVE -> RETREAT
         -> IDLE -> OPEN -> SHOW_EYE
```

`BECOME_ACTIVE` may wait for the boss, but it cannot skip `RETREAT`. The
`RETREAT -> IDLE` branch runs only after `approach_f32_ptr` has clamped the
hand's Y exactly to its home Y. At that point inherited vertical velocity is
nonpositive. The attack flag is recomputed after each non-sleep handler, so a
hit detected during recovery is not a persistent request that can bypass this
chain. A hit detected on the final `OPEN -> SHOW_EYE` frame may be consumed on
the next frame, but that is already after the reset.

If the eye closes without accepting that next hit, `CLOSE` returns either to
`IDLE` in the two-hand phase or to `RETREAT` in the one-hand phase. The latter
route performs another exact-home reset before the hand can reopen; neither
branch bypasses the reset already required after `ATTACKED`.

`NonlethalNoStacking.v` combines these facts in one axiom-free, labeled Rocq
lifecycle. It tracks health, Y, velocity, gravity, grounding, attack age, the
attack flag, accepted-hit count, and a proof-only “home reset owed” bit. An
accepted nonlethal hit sets that bit. Only the genuine `RETREAT -> IDLE` event
clears it. Rocq proves that every trace between two accepted nonlethal hits
contains that reset event. It separately proves that the airborne part of each
velocity-30, gravity-`-4` response rises at most 98 units above that hit's
origin.

For example, an ordinary hit beginning at home Y `-1534` peaks at `-1436`,
then the lifecycle passes through home Y `-1534` before another hit can be
accepted. With no other raising mechanism, the second hit also peaks at
`-1436`, not `-1338`.

There is an important limit to that example. After the required home reset,
another hand, a floor snap, or a later boss action could in principle put the
hand on a different support before its eye is hit again. If that happened,
the next 98-unit impulse would be measured from the new support. That would be
a separate support/geometry mechanism, not retained height from the first
nonlethal impulse. The first- and two-hand barriers are responsible for
bounding those supports. The new theorem therefore proves **a home-Y reset
occurs between successive nonlethal hits**; it does not claim every later hit
must itself occur at home under every possible intervening geometry.

The generated Clight AST is machine-checked for the named handlers, action
constants, hitbox call, and handler/attack-check/movement call order. The
source audit additionally checks health initialization, the unique attack
consumer, the exact recovery graph, attack-flag overwrite, the 15-movement
ordinary ground return, and the 25-frame ATTACKED gate. What remains open is a
dynamic whole-program Clight/ROM refinement showing every real frame is
represented by this lifecycle.

Here is the relevant double-pound frame sequence in plain English:

```text
Frame 0: IDLE chooses BEGIN_DOUBLE_POUND and writes gravity = 0.
         Vertical velocity is 0 and hand Y equals its floor.
         End-of-frame movement clears the stale ground flag.

Frame 1: BEGIN_DOUBLE_POUND changes the action to DOUBLE_POUND.
         Zero motion again leaves the hand ungrounded.

Frame 2: DOUBLE_POUND sees "not grounded" and velocity <= 0.
         It writes gravity = -20 before movement.
```

The same three-frame boundary was also observed in a debugger-enabled
Mupen64Plus run of the hash-authenticated US ROM. The probe first found the real hand
objects and required home Y and position -1534, velocity and gravity zero, and
a non-null collision mesh. It changed only each action from SLEEP to IDLE,
then waited for an ordinary update to select real arena floors at -1534.
After a disclosed boss-scheduler fixture, the log showed IDLE at timer 365,
BEGIN_DOUBLE_POUND at 366, DOUBLE_POUND at 367, gravity -20 with nonpositive
velocity at 368, and the first +85 movement with gravity -15 at 372. Its
analyzer found zero alternate-seed rows in 476 hand observations.

That experiment is stronger than arithmetic alone but narrower than a natural
TAS trace. Area travel and the local boss schedule were shortened with
documented RAM writes. No hand position, velocity, gravity, movement flag,
floor, collision mesh, timer, previous action, positive velocity, or
double-pound action was injected. It is therefore real ROM execution
from an initialized, source-reachable local precondition, not proof that
controller input from reset naturally reaches the same scheduling state.
The complete write manifest and concise CSV are under `instrumentation/`.

When the hand later lands with gravity `-20`, the first grounded branch changes
gravity to `-15` and clears the boss's active-hand selection without writing
velocity `100`. A later selected grounded branch may write velocity `100`, but
gravity is then already `-15`. The actual positive increments are therefore
only `85, 70, 55, 40, 25, 10`, totaling `285`.

The Rocq kernel also closes two modeled ways stale grounding might survive,
using source-audited boundary premises:

- there is no raised static floor in the begin-double corridor. The hands are
  not globally separated by 280 units, as an earlier draft claimed. In the
  relevant double-pound approach, the audited trace puts the moving hand
  at relative `(X,Y)=(-120,255)` and then `(-90,210)`. The first point is still
  outside the other closed top; the second is 18 units below its floor-query
  threshold. `DoublePoundTrace.v` proves that no sample satisfies both tests;
  the linked phase/wall refinement is still required; and
- a live hand cannot receive a movement-only partial update: its collision
  pointer is non-null, its room remains `-1`, and time stop freezes the entire
  hand update rather than just its movement. `PartialUpdateBoundary.v` proves
  this for the no-external-writer lifecycle; generated-Clight writer
  completeness remains open.

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
yet prove a Mario route for any of the three schedules. It also proves that
the third schedule has exactly one fresh edge, on frame zero.

No fresh edge does not imply "Mario cannot be airborne." Mario may enter the
measured interval in an action launched earlier. A no-A or held-A route proof
must constrain the complete predecessor trace, not merely inspect buttons
inside a convenient suffix.

Continuously held A is also not the same as inert input. The pinned action code
can turn a first-frame punch into a jump kick when `INPUT_A_DOWN` is set; that
path does not require `INPUT_A_PRESSED`. The no-new-edge theorem rules out
press-gated jumps such as a newly initiated backflip, not every vertical action
that can occur while A remains down.

Likewise, never pressing A does not imply zero upward velocity: a sufficiently
fast B-only speed-kick dive writes vertical velocity 20. Conversely, the
model's generous 630-unit rise is specifically the ordinary triple-jump
sequence `69,65,...,1`, and authentic initiation from a landing requires a
fresh A edge and the preceding jump chain. Rocq now checks both that total and
the 512-unit backflip sequence `62,58,...,2`; it does not grant either as an
authentic no-A witness.

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
| `1467` | second hand's object origin | disproved in the two-hand barrier |
| `1974` | second hand's transformed surface | disproved in the two-hand barrier |
| `2604` | Mario's modeled position | disproved with the same generous 630-unit rise |

The two-hand proof deliberately assumes every X/Z overlap succeeds, every
first-hand phase exposes the 507-unit open mesh, and a floor snap preserves any
unused upward budget. The first hand's dynamic support still tops out at
`-355`, below the static Area 3 floor maximum `384`. Thus the second hand uses
support ceiling `384`, reaches at most origin `672`, and exposes at most
surface `1179`. Adding the old route model's full 630-unit rise yields Mario Y
`1809`.

The load-bearing source-shaped premise is that each new positive-velocity
episode starts from classified support and has at most 288 units of remaining
rise; it cannot be replenished while already airborne. The source writer
census and launch kernel support that premise, but an event-by-event linked
Clight refinement is still open.

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

Because floor lookup accepts a floor up to 78 units above Mario, the Y `1280`
floor first becomes eligible at query Y `1202`; the Y `1967` floor at `1889`;
the Y `2940` floor at `2862`; the Y `4429` platform at `4351`; and the star
platform at `4737`.

The older geometry-relaxed peak `2604` is:

- high enough that the height inequality alone does not reject Y `1967`;
- too low for Y `2940` or any higher listed shortcut tier; and
- far too low for direct star collection.

The two-hand barrier replaces that conditional peak with `1809`. Since the
Y `1967` floor first becomes query-eligible at Y `1889`, even the generous
630-unit modeled rise is 80 units too low to select it. It can still be high
enough for lower Area 2 geometry; deciding an exact lower landing requires the
Mario/warp trace developed next.

## A conditional lower route lands on Y=1280

The numbers `1179` and `1809` are limits, not coordinates from a demonstrated
playthrough. The two-hand proof says the second hand's open surface cannot
exceed Y `1179`. Adding the checked 630-unit ordinary triple-jump rise gives a
Mario ceiling of Y `1809`. It does not say the hand reaches exactly `1179` or
that Mario can perform the jump from it.

`LowerArea2Entry.v` asks what follows if both upper bounds are attained:

```text
conditional Area 3 entry: (0,1809,-1024), velocity (0,-3,12)
after the instant warp:   same position and velocity in Area 2
after 16 modeled frames:  (0,1281,-832), vertical velocity -67
next quarter-step query:  (0,1264,-829)
audited selected floor:   Y=1280
modeled landing state:    (0,1280,-829), grounded
```

The Z coordinate `-1024` is intentional. At the north edge, Z `-1023`, an
ordinary Area 3 triangle overlaps the warp and wins the source floor-list
order. The pinned audit checks that `(0,1809,-1024)` actually selects
`SURFACE_INSTANT_WARP_1D`; the proof does not merely assign a point inside a
bounding rectangle.

On the landing quarter-step, Mario's mathematical Y is
`1281 - 67/4 = 1264.25`. The floor query converts that positive value to
integer `1264`. The Y=1280 floor is 16 units above the query, within the
game's 78-unit allowance, and the pinned collision audit confirms that it is
the first eligible floor at this exact X/Z. The handwritten Rocq landing
relation then applies the source-shaped `next Y <= floor Y` test and snaps
Mario to Y `1280`.

This proves an exact **conditional modeled landing**. It does not prove the
assumed hand surface, Mario's boarding or launch, or the crucial move off the
dynamic hand while staying over the static warp. It also does not prove that
the constant horizontal velocity comes from `update_air_without_turn`, that
no earlier source wall/floor/ceiling response changes a frame, or that the
sixteen controlled frames form a linked Clight execution.

The arithmetic separates several A-button cases:

- No new impulse leaves Mario at Y `1179`, 23 units below the Y=1280 query
  minimum `1202`.
- The checked backflip envelope gives conditional Y `1691`, enough by height,
  but backflip requires a fresh A edge and has no exact hand-to-warp witness.
- The Y `1809` certificate uses the full triple-jump envelope. An authentic
  triple jump needs its fresh-A predecessor chain and A held through the
  ascent; this certificate constructs neither.
- Already-held A and never-A remain distinct open cases. Held A can launch a
  jump kick through `INPUT_A_DOWN`, while never-A can launch a B-only
  speed-kick dive with vertical velocity 20. Neither source fact is yet an
  authenticated hand-to-Y=1280 trace.

Finally, Y `1809` is below the Y=1967 floor's query minimum `1889`. Thus this
restricted model conditionally lands on Y `1280` while formally excluding
Y `1967`. It does not prove Y `1280` globally fastest, most useful, or closest
to the star after ordinary movement.

## Why the straightforward never-A speed kick hits a wall

The B-only speed kick is important for the A Button Challenge because it can
launch Mario without pressing A. Its source preconditions require forward
speed at least 29 and strong stick input, then it writes vertical velocity 20
and enters the dive action.

At first, the height arithmetic looks promising. Starting conditionally from
the hand-surface ceiling Y `1179`, ordinary gravity gives positive movements:

```text
20 + 16 + 12 + 8 + 4 = 60
conditional peak: 1179 + 60 = 1239
Y=1280 query minimum: 1202
```

So the no-A jump is high enough by 37 units. If Mario uses the first 20-unit
movement to leave the hand and select the Area 3 warp, he appears in Area 2 at
Y `1199` with vertical velocity `16`.

The obstacle is horizontal geometry, not height. The Y=1280 platform has a
south wall at Z `-844`, running from X `-2201` to `205`, and an east wall at
X `205`, continuing north to Z `-537`. Both walls extend from Y `1152` to
`1280`. SM64 resolves those walls before it searches for the floor on each
airborne quarter-step. A dive that hits a wall bonks and switches to backward
air knockback.

`NoA1280Barrier.v` deliberately gives Mario more steering freedom than the
ordinary dive code. Y=1280 remains query-eligible for 35 quarter-steps. At
full horizontal speed 48, each quarter-step can cover at most 12 units, so the
entire available path is at most 420 units.

There are only three ordinary ways past the perimeter:

- **Over:** wall loading extends the upper test to Y `1285`, and Mario's lower
  wall sample is 30 units above his base. Clearing it requires base Y greater
  than `1255`; the conditional speed-kick peak is only `1239`.
- **East:** even starting at the best warp X `192`, Mario must clear to about
  `(255,-487)`. The displacement is at least
  `sqrt(63^2 + 537^2)`, about 541 units, beyond the 420-unit budget.
- **West:** clearing past X `-2251` from the best west warp point needs more
  than 2060 units.

Rocq proves that no wall-avoiding path exists in this explicitly ordinary,
seam-free, speed-at-most-48 classification. In practical terms, the simple
plan "B-dive north from the warp and land on Y=1280" must hit the perimeter
while the top is still eligible.

What this does **not** prove is equally important. The Y=1179 surface is still
an upper bound, not a reached pose. The proof assumes the speed kick can leave
the dynamic hand and select the static warp. It does not exhaust recovery
after the bonk, incoming horizontal speed above 48, collision seams, quantum
tunneling, parallel-universe coordinate casts, or a linked execution of the
source wall code. It also says nothing directly about the already-held-A jump
kick, whose action history and horizontal motion differ.

## Why already-held A is a separate bounded-speed case

Holding A before the measured interval creates no new A-button press edge, but
it is not inert. If Mario is in the first frame of a punch, the original action
code tests the held-state bit `INPUT_A_DOWN` and can change the action to jump
kick immediately. The generated Clight AST now machine-checks that the named
moving and object punch functions contain this held-A gate and the
`ACT_JUMP_KICK` transition.

The jump kick starts with vertical velocity 20. From the same conditional
surface Y `1179`, its vertical trace therefore matches the B-only speed kick:

```text
launch-frame Area 2 entry: Y=1199, vertical velocity 16
conditional peak:          Y=1239
Y=1280-eligible window:    35 quarter-steps
```

The horizontal behavior is different. Jump kick inherits Mario's incoming
`forwardVel`, and the air update does not impose a global speed-48 cap. The
new held-A theorem therefore states its predecessor and per-step assumptions
explicitly:

```text
assumed inherited |forwardVel|: at most 48
generous quarter-step length:  at most 13
35-step path allowance:        at most 455
east detour lower bound:       about 541
```

Rocq proves that Y `1239` is too low to pass over the wall and that neither the
east nor west seam-free detour fits in 455 units. A conditional stationary
predecessor submodel is tighter still: 35 steps at four units give 140 total.

This does **not** prove unrestricted held-A impossibility. A faster incoming
punch is outside the theorem. A jump kick that hits the wall also stays in
jump kick with forward speed reset, rather than taking the dive's backward
knockback action, so later wall contacts and recovery need a separate proof.
The assumed Y `1179` hand surface and hand-to-warp departure are still not
authenticated either.

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

## The now-refuted conditional Y=1967 trace

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

`TwoHandBarrier.v` now supplies the missing height refutation for this
particular premise. It proves second-hand origin Y at most `672`, not `1467`,
and modeled Mario peak Y at most `1809`, below the Y `1967` floor's query
threshold `1889`. The trace remains useful as a checked counterfactual about
the older relation, but it is no longer a candidate source-shaped witness.

## Why repeated upward launches are now ruled out in the audited model

The earlier phrase "an authentic transition can replenish upward motion while
already above the bound" meant this hypothetical failure mode:

```text
the hand completes one finite jump
-> the game gives it another upward launch without returning to safe support
-> the hand repeats this process at progressively greater heights
```

That would invalidate the Y `1467` bound. The important update is that both
known ways of entering a gravity-zero double pound with upward motion are now
ruled out in audited source-shaped relations. The original grounded candidate
needs `DOUBLE_POUND + grounded + gravity 0`; strict ground-flag updating
excludes it. The new inherited-velocity candidate needs
`DOUBLE_POUND + airborne + gravity 0 + positive velocity`; the complete
`IDLE`-entry/active-lock invariant excludes it. A normal 100-unit launch has
gravity `-15` and is finite.

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

There is still a trust boundary. The old 280-unit mixed-frame separation is
not a valid global invariant and has been removed from the proof. The narrower
double-pound near-miss and no-external-writer lifecycle are now machine
checked, but their source correspondence, the kernel's
zero-velocity/floor-ready premise, collision lifetime, and the claim that the
local Area 3 object set contains no other surface provider are not linked
semantic lemmas. The project has not linked all generated Clight
translation units and proved that every whole-program execution refines the
coupled model. Here, **audited source-shaped** means that the transition cases
were manually extracted from pinned source and protected by deterministic
checks. It is not yet a theorem over the IDO-compiled ROM.

## Exactly what is proved

The project now machine-checks these statements:

- the generated Clight ASTs contain the selected pinned source functions and
  call edges for Eyerok, Mario floor input, instant-warp handling, area change,
  airborne stepping, platform displacement, and star interaction; they also
  check the controller XOR/AND edge expression, B-only launch constants,
  held-A jump-kick gates, press-gated backflip call, per-unit name resolution,
  the jump-kick case's vertical-slot-1 value 20, and critical AST call-site
  traversal order;
- the executable source-shaped kernel cannot reach
  `DOUBLE_POUND + grounded + gravity 0` under any modeled event or A-button
  policy, including never pressing A and continuously holding A;
- the velocity-aware `IDLE` relation proves every reachable `IDLE` entry has
  `oVelY <= 0`, and therefore no reachable modeled state is
  `DOUBLE_POUND + airborne + gravity 0 + oVelY > 0`;
- the unified nonlethal lifecycle proves two nonlethal health transitions per
  hand, at most 98 units of airborne rise per nonlethal impulse, and a genuine
  exact-home `RETREAT -> IDLE` reset with nonpositive velocity between any two
  accepted nonlethal hits;
- the exact controller-schedule definitions distinguish unrestricted input,
  always-released A, continuously-held A, and a fresh A press, and released or
  already-held schedules have no fresh press edge, while press-and-hold from
  frame zero has exactly one;
- every state reachable in the geometry-relaxed vertical relation has
  hand-origin Y at most `672` for the first rank or `1467` for the second;
- every state reachable in the source-shaped first-hand barrier has origin Y
  at most `-862`, cannot query a tunnel floor at Y `-562` or above, and has
  open collision top at most `-355`, hence strictly below Y `1179`;
- even granting every static floor and every possible first-hand dynamic
  contact, every state reachable in the two-hand barrier has second origin Y
  at most `672`, open collision top at most `1179`, and generously modeled
  Mario peak at most `1809`;
- the two-hand result strictly excludes second origin Y `1467`, second surface
  Y `1974`, and modeled Mario Y `2604`, and `1809` is below the `1889` query
  threshold for the Area 2 Y `1967` floor;
- in the audited positive-double trace, setup separation is 360, the last
  vertically eligible sibling-floor query `(-120,255)` is outside the closed
  top, the first horizontally eligible query `(-90,210)` is 18 units too low,
  and no trace point passes both tests;
- in the no-external-writer lifecycle, native collision loading occurs before
  visibility, room remains -1, complete time-stop frames stutter, and no live
  hand reaches the movement-only partial-update guard;
- direct platform velocity displacement leaves Mario Y unchanged; the death
  and attacked rises and the 20-unit target lift pass the 78-unit height filter,
  while the first 85-unit double-pound step, a 100-unit runaway step, and the
  201-unit closed-to-open switch do not;
- in the hash-authenticated local continuation, jump kick or speed kick
  completes `+20` and `+16` Mario updates before the `+85` hand launch. The
  pre-player-update gap is 49 and the first-quarter floor-query gap is 46;
  both ordinary traces remain same-hand floor/platform on
  all positive steps to top Y `-943`. Same-frame entry is blocked at gap 85 by
  the 78-unit filter and the 89.5-unit underside squish condition;
- the held-A local catch has no fresh A edge, while the B-only local catch has
  A always released; both still assume their stated predecessor pose;
- under the listed standard `-4` falling-hit schedule, the nonlethal open mesh
  is vertically rejected during its rise and the later closed top is only
  conditionally height-eligible at a 46-unit gap; its lethal airborne minimum
  is 153 and first-grounded gap is 191. No operational snap follows from that
  lemma. The instrumented inherited-long-jump suffix really
  reboards the nonlethal home-height open hand one frame before its ground flag
  sets, while its lethal suffix has early
  X/Z misses and later floor selection but no platform before deletion;
- Mario standing on the 306- or 507-unit hand top has no vertical hitbox
  overlap with Eyerok's 150-unit interaction cylinder; and
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
- conditional on surface ceiling Y `1179` plus the full triple-jump envelope,
  the corrected Area 3 point `(0,1809,-1024)` selects the warp, sixteen
  controlled frames reach `(0,1281,-832)`, and the next audited query
  `(0,1264,-829)` selects and model-snaps to floor Y `1280`;
- the same certificate proves Y `1809` cannot query floor Y `1967`, while
  surface-only Y `1179` misses the Y `1280` query minimum by 23;
- for the conditional never-A B-only speed kick, rise is 60 and peak Y is
  `1239`; its 35 eligible quarter-steps give at most 420 units at speed 48,
  which is insufficient to go over or around the audited Y=1280 walls in the
  seam-free ordinary-path classification;
- for the conditional already-held-A jump kick with inherited
  `|forwardVel| <= 48` and the explicit 13-unit quarter-step budget, the same
  peak and 35-step window permit at most 455 units, also insufficient to go
  over or around those walls; the stationary predecessor submodel permits at
  most 140;
- `RequestedHeightVerdict.v` packages the four differently typed legacy
  milestone exclusions, the conditional fresh-edge Y=1280 landing, and the
  restricted no-A wall result without conflating their scopes;
- `ClightRefinementBoundary.v` defines a coherent CompCert small-step run and
  proves the 1467/1974/2604 and no-unbounded-rise transfers **if** a complete
  linked program and height refinement are supplied;
- modeled Mario peak `2604` cannot reach the Y `2940`, Y `4429`, Y `4815`, or
  direct-star thresholds; and
- counterfactually, a hand origin at Y `3627` is sufficient in the integer
  route model to enter Area 2 on Y `4429` and land on the star platform, while
  the older coupled ceiling is Y `1467` and the two-hand barrier ceiling is
  only Y `672`; and
- the conditional combined relation reaches the closest point on the Y `1967`
  platform but does not collect the star.

## What is not proved

The project still does not prove:

- a whole-program Clight refinement from every original game frame to the
  source-shaped kernel, vertical relation, and Mario route relation;
- a complete linked Clight program, a proof that chosen small-step states are
  game-frame boundaries, or an observer that reads the correct live hand's
  binary32 `oPosY` from memory and justifies its conversion to integer height;
- a semantic Clight proof, rather than the current deterministic source audit,
  of the original hands' update order and dynamic-floor choices;
- the event-by-event linked Clight theorem that every second-hand positive
  episode begins on classified support with at most 288 remaining rise. The
  two-hand barrier proves the consequence of that source-shaped premise. The
  source-shaped nonlethal reset subcase is now proved, but its whole-program
  Clight/ROM refinement and the other positive episodes remain open;
- an authentic controller trace that first boards the closed hand in the
  held-A or speed-at-least-29 B-only predecessor, synchronizes the timer-2
  preparation and its two Mario updates with the selected double pound, and
  then leaves the hand for the static warp. The local ROM continuation is
  observed from the injected pose;
- a global exclusion of exotic attack/re-entry geometries. The listed
  standard `-4` schedules, one inherited low-speed long-jump fixture, a bounded
  steering sweep, and the straight-front slide-kick fixture are classified;
  controller reachability, other initial positions/yaws, action changes,
  seams, tunneling, externally supplied caps/shells, and unrelated glitches
  remain outside this result;
- an exact original-controller trace from the hand through the warp to that
  landing;
- authentic realization of the conditional Y `1280` landing: equality at the
  surface ceiling, hand boarding, the jump/action predecessor, movement off
  the dynamic hand onto the static warp, and every source collision substep;
- unrestricted no-A impossibility. The ordinary speed-48 B-dive is blocked,
  but faster input, post-bonk recovery, seams, tunneling, PU casts, and the
  model-to-source geometry classification remain open;
- unrestricted held-A impossibility. The inherited-speed-at-most-48 jump kick
  is blocked, but faster predecessors and the jump kick's post-wall
  continuation are not classified;
- how many new A presses an authentic route uses. The high-hand impossibility
  is A-policy-independent, but the generous `+630` Mario rise and both route
  witnesses are not controller-accurate ABC proofs;
- that Y `1967` is the globally fastest or most useful post-warp state for the
  star, rather than only the highest audited tier admitted by this restricted
  height calculation;
- a linked whole-program or ROM theorem that the gravity-zero seed is
  unreachable in every machine execution. Both the grounded and inherited-
  velocity variants are unreachable in the audited source-shaped relations;
- that a hypothetical execution outside that kernel follows the isolated
  `+100` recurrence to `2^31`, how high it gets, or how the ROM handles it; or
- a source-to-ROM proof for out-of-range floating-point conversions in the
  original IDO-compiled MIPS binary.

In short: the Area 3 to Area 2 mechanic is represented, the old finite bound's
route consequences are proved for the explicit adversarial model, the
source-shaped repeated-launch seed is excluded for every A policy, and literal
unbounded finite binary32 Y is disproved. We have additionally disproved the
old first-hand Y `1179`, second-origin Y `1467`, second-surface Y `1974`, and
modeled Mario Y `2604` constructions in source-shaped reachability barriers.
The lower Y `1280` landing is now a machine-checked conditional route rather
than an unknown numerical threshold. Its straightforward ordinary no-A
speed-kick substitute and bounded-speed held-A jump kick are wall-blocked. The
remaining work is to authenticate or refute its Mario/hand predecessor,
classify higher-speed and post-wall traces, build controller-accurate
released/held/pressed-A traces, and connect the source-shaped steps to linked
Clight and, if needed, the original ROM.
