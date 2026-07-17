# Working claim and exact scope

Last updated: 2026-07-16 (IDLE inherited-velocity invariant).

## Source and toolchain boundary

- Super Mario 64 North American source (`VERSION_US=1`).
- Canonical revision:
  `9921382a68bb0c865e5e45eb594d9c64db59b1af`.
- Available sibling checkout:
  `36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`; audited files must match the
  pin or are extracted directly from it.
- Coq 8.16.1, CompCert 3.15, PPC32 EABI big-endian.

Generated Clight shape facts and source audits pin syntax, constants, call
edges/order, controller/action gates, per-unit name resolution, and collision
data. They are not a linked whole-program execution refinement.

## Definitions

- **Hand height** is the hand object's origin Y. It is not the top of its
  collision and not Mario's Y.
- **Hand surface ceiling** adds the audited 507-unit maximum collision offset
  to a hand-origin ceiling.
- **Modeled Mario peak** adds a 630-unit triple-jump rise to the hand surface
  ceiling. This route model excludes caps and external boosts and is not an
  unrestricted original-game speed theorem.
- **Useful direct tier** means one of the audited Y=1280, 1967, 2940, 4429, or
  4815 floors, or direct star interaction. The route theorem identifies the
  highest admitted audited tier; it does not prove globally minimum star time.
- **Rises unboundedly** means that for every real/integer ceiling, some later
  frame has greater Y. Persistent positive velocity with a rounded, unchanged
  position is a different property.

## Refined vertical result

The old 1196/2003 origin bounds are superseded. They used Area 3's maximum
vertex Y=896, which includes non-floor walls, and rounded every finite impulse
to 300.

The refined relation uses upward-floor maximum 384 and exact finite ascent
maximum 288:

```text
FirstHand origin:        384 + 288 = 672
FirstHand surface:       672 + 507 = 1179
SecondHand origin:      1179 + 288 = 1467
SecondHand surface:     1467 + 507 = 1974
modeled Mario peak:     1974 + 630 = 2604
```

Rocq proves every reachable vertical-relation state stays below the applicable
origin ceiling and no infinite run of that relation is unbounded. The binary32
representation bound is proved independently; rank/update-order correspondence
is backed by a deterministic pinned-source audit of order and geometry. The
audit does not itself prove the semantic correspondence. A whole-program
Clight proof of that mapping and source-to-model transition refinement remains
open.

### First-hand reachability refinement

The Y=384 premise above is an intentionally geometry-relaxed maximum. The
pinned collision audit now proves that Y=384 belongs to the tunnel, whereas
the first-updated hand initially has access only to static arena floors at or
below Y=-1150. The first hand queries before either hand's current-frame
dynamic collision can support it. The lowest tunnel floor is Y=-562 and needs
query Y at least -640 because of the 78-unit floor buffer.

Even the largest finite rise yields `-1150 + 288 = -862`. Rocq therefore
proves, for the source-shaped first-hand barrier:

- origin Y is at most -862;
- no floor at Y=-562 or above is query-eligible;
- the open-eye collision top is at most `-862 + 507 = -355`; and
- the old first-surface Y=1179 milestone is unreachable.

This is stronger than the geometry-relaxed first-rank bound, but narrower in
scope: a linked Clight frame refinement, the second hand's access to the first
hand's dynamic collision, and Mario's contact trace remain open.

The four legacy numbers are now separate formal predicates: 1179 observes the
first transformed surface, 1467 the second object origin, 1974 the second
transformed surface, and 2604 Mario's position. Disproving one predicate does
not silently substitute for a proof of the others.

### Two-hand reachability refinement

The second-updated hand can see the first hand's current dynamic collision.
`TwoHandBarrier.v` deliberately grants every such contact without requiring
X/Z overlap, floor-query eligibility, or the correct phase-specific mesh. Any
granted first-hand support is at most -355, while the maximum audited upward
static Area 3 floor is 384. Dynamic support therefore does not increase the
second hand's support ceiling.

With at most 288 units of remaining finite rise, Rocq proves:

```text
SecondHand support:       max(384, -355) = 384
SecondHand origin:                  384 + 288 = 672
SecondHand surface:                 672 + 507 = 1179
modeled Mario peak:                1179 + 630 = 1809
Area 2 Y=1967 query minimum:      1967 - 78 = 1889
```

Thus the source-shaped barrier strictly excludes second origin 1467, second
surface 1974, modeled Mario Y=2604, and even selection of the Area 2 Y=1967
floor. The load-bearing refinement premise is that every new positive episode
starts from classified support and carries at most 288 remaining rise; no
event replenishes that budget while already airborne. The source audits and
launch kernel support this premise, but the event-by-event linked Clight
theorem remains open.

The proposed `DOUBLE_POUND + airborne + gravity=0 + oVelY>0` route is now
handled explicitly rather than hidden inside that premise. The pinned source
has exactly three `IDLE` writers—`SLEEP`, `CLOSE`, and `RETREAT`—and none
clears or positively writes `oVelY`. The new velocity-aware relation preserves
that source behavior and proves the inherited value is always nonpositive.
The `DOUBLE_POUND -> RETREAT` case uses the boss active-hand lock: its terminal
request is available only with no active hand, while a positive double-pound
episode retains the lock until grounded under negative gravity.

### Double-pound and partial-update refinement

The earlier 280-unit mixed-frame hand-separation claim was false: the hands
can get closer during attacks. `DoublePoundTrace.v` proves the narrower fact
actually needed for the reusable positive-double approach. The audited setup
starts the later hand 360 units behind at relative Z=0. The closed top's
conservative scaled/cast X slice is `[-108,102]`, and floor eligibility needs
relative Y at least `306-78=228`. In the exact trace:

```text
... -> (-120,255) -> (-90,210) -> ...
```

`(-120,255)` is the last vertically eligible query but remains outside the
closed top. `(-90,210)` is the first horizontally eligible query but is 18
units too low. Rocq proves that the complete audited free-flight list has no
simultaneously eligible point. The theorem is phase-local and source-shaped;
it does not prove arbitrary hand noncollision or a linked Clight controller
trace, and its no-wall conservatism still needs a semantic wall-response
bridge.

`PartialUpdateBoundary.v` separately proves that a live hand cannot reach the
movement-only partial guard in the no-external-writer lifecycle. The native
sleep update installs nonnull collision before visibility; later collision
writes remain nonnull; room remains -1; visibility therefore sets neither
FAR_AWAY nor IN_DIFFERENT_ROOM; and time stop stutters the complete object
update. The source audit pins each ordering/writer premise. This closes the
partial-update branch inside the finite lifecycle model, not yet for every
linked Clight or ROM execution.

### Mario contact and A-edge refinement

The pinned Mario/platform audit and `MarioHandContact.v` now separate three
interfaces:

- direct platform displacement adds hand X/Z velocity but no hand Y velocity;
- vertical following therefore requires a fresh floor query and snap within
  the 78-unit buffer; and
- attacking the hand requires vertical interaction-hitbox overlap, not merely
  standing on a collision triangle.

Rocq proves that every positive attacked/death increment and the 20-unit
target lift pass the height filter. It also proves that a stationary Mario
fails it on the first 85-unit double-pound step, the 100-unit runaway step, and
the 201-unit closed-to-open mesh switch. These are height-only statements;
triangle X/Z containment, floor priority, and Mario action execution remain
required.

The scaled Eyerok hitbox top is origin+150, while the closed/open standing
floors are origin+306 and origin+507. Mario standing on either has no vertical
hitbox overlap and cannot attack the eye from that pose. The ordinary bounce
places Mario at origin+150 with velocity 30; even granting that full rise
before the hand's first +46 death increment leaves the new open surface outside
the floor buffer. Exotic predecessor/re-entry traces are not yet exhaustively
excluded.

Controller schedules now include the pre-interval A bit. Always released and
already-held A have no new press edge; press-and-hold beginning on frame zero
has exactly one. This is not a no-A reachability theorem because Mario might
enter the interval in an action launched earlier. It is not a held-A
nonmovement theorem either: the pinned punch actions can launch a jump kick
from `INPUT_A_DOWN` without a fresh press.
Never-A also permits a B-only speed-kick dive with vertical velocity 20 under
its speed/stick preconditions. The 630-unit model allowance is the exact
ordinary triple-jump sequence and requires a fresh-A predecessor chain for an
authentic witness; the backflip envelope is 512.

The executable finite kernel proves that the grounded zero-gravity launch seed
is unreachable. `IdleVelocityInvariant.v` separately proves that the airborne
zero-gravity, positive-velocity seed is unreachable. Together they close both
identified control paths to repeated zero-gravity ascent in the audited
source-shaped models. The kernel result quantifies over every modeled
boss/player event and every A-button policy. A is a ghost parameter because
the hand code does not read it; this is not a controller-accurate ABC or
new-press-count theorem.

### Conditional lower Area 2 threshold

`LowerArea2Entry.v` proves the route arithmetic available at the stricter
two-hand ceiling while keeping ceiling and reachability separate:

```text
conditional hand surface:                 1179
conditional triple-jump peak / entry:     1809
Area 3 selected warp point:       (0,1809,-1024)
after 16 controlled frames:       (0,1281, -832), vy=-67
next integer quarter-step query:  (0,1264, -829) -> floor Y=1280
```

The pinned audit checks both that the Area 3 departure point selects
`SURFACE_INSTANT_WARP_1D` and that the exact Area 2 query selects Y=1280 in
the real floor-list order. Z=-1024 is intentional: at the Z=-1023 north edge,
an overlapping ordinary Area 3 triangle can win floor-list priority.

Rocq proves that query Y=1809 is below the Y=1967 floor's minimum 1889 and
that surface Y=1179, without a further upward impulse, is 23 units below the
Y=1280 query minimum 1202. The checked backflip envelope reaches Y=1691 and is
also numerically high enough for Y=1280, but no exact backflip witness exists.

This result does not prove equality at the hand ceiling, authentic boarding,
moving off the hand so the static warp beats its dynamic floor, the
triple-jump predecessor chain, source execution of all sixteen controlled
frames, or absence of an earlier source collision response. Its landing step
is a handwritten relation mirroring the audited query and snap condition, not
a linked Clight execution. It is therefore a conditional fresh-A route
calculation. Never-A and
held-before-start witnesses remain open; no fresh A edge does not exclude the
source's B-only speed-kick dive or held-A jump kick.

### Ordinary no-A Y=1280 barrier

`NoA1280Barrier.v` analyzes the B-only speed-kick candidate separately from
the fresh-A triple-jump certificate. Conditional on starting from the Y=1179
surface ceiling, velocity 20 gives the exact positive steps
`20,16,12,8,4`, total rise 60, and peak Y=1239. If the first Area 3 dive frame
selects the warp, the Area 2 state is Y=1199 with vertical velocity 16.

The pinned Area 2 geometry has a south wall at Z=-844, X `[-2201,205]`, and
an east continuation at X=205 through Z=-537; both span Y=1152..1280. Wall
resolution runs before the quarter-step floor query, and a dive wall hit
switches Mario to `BACKWARD_AIR_KB`. The Y=1280 query remains eligible for 35
quarter-steps. Even granting arbitrary steering at horizontal speed 48 gives
only `35*12=420` units of path. Mario cannot pass over, because his peak 1239
is below the strict base-Y clearance 1255. The best east detour needs squared
displacement at least `63^2+537^2 > 420^2`; the west detour needs more than
2060 horizontal units.

Rocq therefore proves that no wall-avoiding path exists in this ordinary,
seam-free, speed-at-most-48 classification: the direct B-only candidate must
resolve against the perimeter before it can enter the Y=1280 top. This does
not prove unrestricted no-A impossibility. Surface-ceiling equality, authentic
speed-kick preparation and warp-floor selection, source exhaustiveness of the
wall classification, post-bonk recovery, faster incoming speed, seams,
quantum tunneling, and parallel-universe casts remain open. The held-A jump
kick is also a different action trace.

### Bounded-speed held-A Y=1280 barrier

`HeldA1280Barrier.v` analyzes that different trace. A continuously held A
schedule has no new press edge, but the punch action can use `INPUT_A_DOWN` to
enter jump kick. The jump kick's vertical velocity 20 gives the same Y=1239
peak and 35 eligible quarter-steps as the no-A dive.

Unlike the dive abstraction, jump kick inherits uncapped `forwardVel`.
Therefore the theorem explicitly assumes inherited `|forwardVel| <= 48` and a
conservative bound of 13 units per quarter-step, or 455 total. Peak Y=1239 is
still below the strict base-Y wall-clearance threshold 1255, the east detour still
needs squared displacement at least `63^2+537^2 > 455^2`, and the west detour
still needs more than 2060 units. Rocq proves no ordinary seam-free
wall-avoiding entry in this bounded-speed class. A separately conditional
stationary-predecessor budget is at most 140.

This is not unrestricted held-A impossibility. Faster inherited speed,
authentic predecessor/hand/warp reachability, source derivation of the
horizontal budget, seams/glitches, and continuation after a jump-kick wall hit
remain open. A wall hit zeros forward speed but leaves Mario in jump kick, so
the no-A dive's post-bonk action argument does not transfer.

### Packaged requested-height verdict

`RequestedHeightVerdict.v` preserves three different scopes in one checked
record: source-shaped impossibility of the four legacy milestones and the
Y=1967 query, a conditional modeled Y=1280 landing accompanied by one fresh A
edge but not causally derived from it, and the ordinary seam-free no-A wall
barrier. It does not turn those scopes into an original-game theorem.

## Verdict on the three requested questions

### 1. Raised hand and Area 3 to Area 2

Proved in the explicit Mario/area relation:

- `HandSurface` cannot trigger the instant warp.
- `Area3Warp1D` changes to Area 2 and preserves Mario X/Y/Z, velocity, and
  airborne/grounded state.
- the matching Area 2 surface does not immediately invoke this entry rule.

The combined abstract relations admit this conditional trace:

```text
hand origin 1467 -> Mario base 1974
20 modeled long-jump frames -> warp at (192,2194,-1033)
zero-displacement Area 2 entry
12 modeled steering/fall frames -> land at (387,1967,-500)
```

This disproves "the formal finite bound is too low for any mid-level route."
It does **not** prove the original game can create the starting hand pose.

For the proposed higher route, the result is a no-go in the coupled audited
model. The strict end-of-frame ground test clears stale grounding
when `IDLE` starts `BEGIN_DOUBLE_POUND` with gravity zero. The hand reaches
`DOUBLE_POUND` airborne, installs negative gravity before it can land, and
never reaches `DOUBLE_POUND + grounded + gravity=0`. The older relation then
gave a conservative global origin ceiling of 1467. The new two-hand barrier
uses the first-hand reachability result and lowers the second origin ceiling to
672. This conclusion is independent of whether A is pressed, never pressed,
or held continuously inside the model. The no-A case conservatively receives
the same 630-unit Mario-rise allowance, so it proves impossibility without
claiming that such a jump is a legal no-A move.

The coupled relation has an explicit `Runaway` transition if the dangerous
kernel seed exists; its height invariant therefore depends on the kernel proof
rather than merely conjoining two unrelated bounds. It is specifically a
kernel-controlled runaway gate on a safe vertical abstraction: ordinary
finite vertical steps are not yet paired event-by-event with kernel steps, and
the two components do not share a proved absolute-height field. The remaining
source bridge is still open. The old 280-unit mixed-frame separation has been
removed; the replacement exact phase trace and no-external-writer lifecycle
are now machine checked. Their correspondence to linked Clight, plus the
zero-velocity/floor-ready premise, still needs formal source-to-model
refinement.

The exact conditional Y=1467 pose used above is now refuted by the two-hand
barrier, rather than merely unproved. This answers the requested
**star-useful higher-hand** reachability question inside the source-shaped
model, not yet for linked Clight or the original ROM.

At the stricter Y=1809 Mario ceiling, the conditional lower witness instead
enters at `(0,1809,-1024)` and reaches a modeled Y=1280 landing whose first
landing quarter-step queries `(0,1264,-829)`. This proves that Y=1280 is not
rejected by the finite bound. It does not prove that the ceiling equality,
Mario action history, hand-to-static-warp transition, or controlled air frames
are authentic original-game transitions.

For never-A, the obvious B-only speed-kick substitute does not realize that
same landing in the ordinary speed-48 model. Its 60-unit rise is numerically
enough to keep Y=1280 query-eligible, but the perimeter-wall proof forces a
collision before entry. Faster or collision-glitch no-A traces are not ruled
out, and the assumed Y=1179 departure surface is not authenticated.

For already-held A, the jump-kick substitute is also wall-blocked under the
explicit inherited-speed-at-most-48 and 13-unit-quarter-step classification,
with 455 units of path. The source does not globally cap inherited jump-kick
speed, and post-wall continuation remains unclassified, so the unrestricted
held-A verdict is open.

### 2. Are the finite bounds high enough?

For the older geometry-relaxed relation and modeled Mario rise:

- Y=1967 is numerically and kinematically admitted by the conditional trace.
- Y=2940 first becomes floor-query eligible at Y=2862, above peak 2604.
- Y=4429 first becomes eligible at 4351.
- Y=4815 first becomes eligible at 4737.
- direct star interaction requires Mario base Y at least 4890.

Thus the bound is high enough for the conditional Y=1967 landing and too low
for every higher audited shortcut tier. `(387,1967,-500)` is proved to minimize
horizontal distance to the star over that platform, at distance 113, but it is
2923 units below the star's vertical interaction band.

The route model also supplies a useful counterfactual threshold. For its fixed
20-frame approach, hand origin Y=3627 is the proved minimum; its collision top
places Mario at Y=4134. The modeled trace enters Area 2 at Y=4354. Its first
quarter-step query truncates to Y=4351, selects the Y=4429 platform, and lands
on the Y=4815 star platform. The older coupled Y=1467 ceiling is 2160 units too
low, and the stricter two-hand Y=672 ceiling is 2955 units too low, to supply
this premise.

Therefore the proposed high-Eyerok route cannot displace Y=1967 in this model.
This is not a proof that Y=1967 is globally fastest or most useful: its own
starting pose remains conditional, ordinary movement from lower Area 2 floors
can still reach the star, and no frame/A-press optimization has been proved.

For the new two-hand barrier, the modeled peak is only 1809. That is below the
1889 query threshold for the Y=1967 floor, so the old conditional landing is
not available at all. The new conditional calculation reaches an exact Y=1280
floor query and modeled snap: Y=1280 needs query Y at least 1202, and the
modeled query is 1264. Under the current controlled-speed/no-new-boost
calculation this is the highest demonstrated lower landing tier. It is not a
global optimum or an authentic controller trace; Y=896 remains directly below
the warp, and unmodeled action, collision, or speed histories require separate
analysis.

### 3. Unqualified original-game indefinite ascent

For the project's defined property `rises unboundedly`, the literal
finite-height claim is disproved at the representation level. Every finite
binary32 value has the common real upper bound `2^128 - 2^104`. Rocq also
proves `Float32.add 2^31 100 = 2^31` and that the recurrence remains fixed
when started there. This conclusion does not depend on excluding the dangerous
scheduler seed.

This is not a proof that the authentic game never reaches
`2^31`. Separately, the source-shaped kernel now proves that it never reaches
`DOUBLE_POUND + grounded + gravity=0`, so the isolated `+100` recurrence has no
source-shaped starting state. What remains open is the linked theorem that
every whole-program Clight execution refines the kernel, and the separate ROM
semantics. CompCert's `Float32.to_int 2^31 = None` is not a statement about how
the original IDO/MIPS binary handles its out-of-range conversion.

## Explicit Clight refinement boundary

The project now generates `game_init.c` and Mario's moving, object, and
stationary action units in addition to the earlier units. Rocq checks the
controller AND/XOR edge expression, B-only speed-kick constants, held-A
jump-kick calls, press-gated backflip call, per-unit program resolution, and
critical AST call-site traversal order. The generated jump-kick switch case
also ties action `25168044` to vertical array slot 1 and binary32 value 20.

`ClightRefinementBoundary.v` defines a coherent run whose consecutive selected
states are connected by nonempty sequences of genuine CompCert
`Clight.step2` steps. If a complete linked program contains the selected
generated bodies **and** its observed hand height refines the audited coupled
model, Rocq transfers origin <=1467, surface <=1974, modeled Mario envelope
<=2604, and no unbounded ascent.

The refinement is a premise, not a proved fact. The project has not assembled
the complete linked program, identified normal game-frame boundaries in the
small-step run, read the intended live hand's binary32 `oPosY` from Clight
memory, justified its conversion to the model's integer height, or proved
PPC32 CompCert equivalent to the IDO-compiled MIPS ROM. Python pin/hash audits
are deterministic build evidence, not Rocq semantic proof terms.

## C abstraction boundary

`inputs/eyerok_model.c` is an executable interface model. Its public functions
do not enforce the same preconditions as the handwritten relation; an
unrestricted caller can request new impulses from unsafe heights. Its safety
predicate reports the violation. No theorem treats arbitrary calls to that C
API as original gameplay.

## Open authentic obligations

- Link the generated translation units and define a complete original frame.
- Prove that linked Clight executions refine the audited source-shaped kernel,
  coupling boss controller, both hands, list order, dynamic collision, Mario,
  time stop, and floor-pointer lifetime.
- Replace the audit-backed first/second rank and 78-unit floor-query facts with
  semantic Clight lemmas if a fully linked theorem is required.
- Prove the linked finite-episode classification used by the two-hand barrier:
  all positive second-hand writes start from classified support, carry at most
  288 remaining rise, and cannot replenish that rise while airborne. The two
  identified zero-gravity seeds are closed in source-shaped Rocq relations;
  what remains is their linked Clight/ROM refinement plus the exact
  double-pound trace and conservative wall response.
- Prove that the linked object's complete writer set refines the partial-update
  lifecycle, including time-stop classification and absence of external room,
  collision-null, FAR_AWAY, or IN_DIFFERENT_ROOM writes.
- Prove Mario's actual platform selection and vertical following. The source
  does not add a platform's vertical velocity to Mario; a moving hand must be
  reselected within the 78-unit buffer on every relevant frame.
- Construct or refute an X/Z-valid initial boarding and dismount trace. The
  vertical filter results are conditional on transformed-triangle containment
  and selected-floor priority.
- Exhaust the airborne predecessor states if claiming that no attack/re-entry
  can board a lethal rise; the ordinary attack bounce alone is ruled out.
- Authenticate or refute the conditional Y=1280 route below the Y=1967 query
  threshold, including every quarter-step collision response and the landing;
  then test whether any original-game action/speed history reaches a higher
  lower tier.
- Refine the seam-free speed-48 no-A wall barrier to source/Clight semantics;
  separately analyze post-bonk recovery, higher incoming speed, and collision
  seams before making an unrestricted no-A claim.
- Prove a held-A predecessor speed bound or analyze inherited speed above 48,
  and classify jump-kick continuation after its first wall response.
- Prove the exact controller/action trace and new-A-press count for any claimed
  Area 2 landing; the current high-hand no-go is A-policy-independent, but the
  Mario route witnesses over-approximate controller behavior.
- Treat always-released A, continuously held A with no new edge, and a fresh
  press-and-hold as different schedules. The first two are machine-proved to
  contain no A press edge, but no route verdict follows from that fact alone.
- Prove route timing before calling Y=1967 globally fastest.
- Add an IDO/MIPS boundary if the claim is about the original ROM rather than
  CompCert Clight source semantics.

No project-added `Admitted`, `Axiom`, `admit`, `sorry`, or equivalent proof
hole may occur in a capstone.
