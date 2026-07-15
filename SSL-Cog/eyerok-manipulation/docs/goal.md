# Goal recovery note

Last updated: 2026-07-15 (requested-height package and Clight/A boundaries).

## Objective

Decide three related but separate questions for the pinned North American
Super Mario 64 source:

1. Can Mario use a raised Eyerok hand to select the Area 3 instant-warp floor
   and enter Area 2 at a useful height?
2. Are the finite Rocq hand-height bounds high enough for a useful Area 2
   landing, especially near the `Inside the Ancient Pyramid` star?
3. Can finite binary32 Eyerok Y be manipulated into an unbounded ascent, and
   can the dangerous upward-control state persist in an audited source-shaped
   run, a linked Clight run, or the original ROM?

The proof must not infer Mario reachability from a hand-origin upper bound.
Hand movement, Mario/platform contact, floor selection, area change, Area 2
collision, and star interaction are separate interfaces.

## Completed proof layers

The project pins source revision
`9921382a68bb0c865e5e45eb594d9c64db59b1af` and generates CompCert Clight for
Eyerok behavior, object motion and collision, area change, instant-warp
dispatch, controller input, Mario moving/object/stationary/airborne actions,
platform displacement, interactions, and the SSL level script.

The deterministic source audits now pin:

- the exact Area 3 warp quad and zero-displacement destination;
- the inactive matching Area 2 slot and adjacent return warp;
- the Area 2 Y=896, 1280, 1967, 2940, 4429, and 4815 route tiers, including
  exact floor-list selection at the lower witness's Y=1280 query;
- the star at `(500,5050,-500)` and its interaction bounds;
- that the largest upward-facing Area 3 floor vertex is 384 (the old value 896
  was the maximum of every vertex, including walls); and
- that platform displacement has no direct vertical-velocity addition;
- that floor equality clears both ground bits because grounding uses a strict
  comparison;
- the complete relevant gravity-writer order, hand spawn/update order, and
  dynamic-surface clear order;
- the live hand's nonnull collision-pointer writers, room default `-1`, native
  execution before visibility, first sleep collision assignment, time-stop
  whole-update branch, and movement partial-update guards; and
- the Area 3 local object/macro data, closed-hand radius, and positioning
  constants. The previously quoted 280-unit mixed-frame calculation is not a
  valid global hand-separation invariant. The replacement audit derives a
  360-unit positive-double setup separation and the exact no-wall relative
  query trace.

`AuthenticKernel.v` extracts those audit-backed premises into an executable
finite transition function. Its start step computes the ground bit using the
strict comparison. Rocq proves that no event sequence reaches
`DOUBLE_POUND + grounded + gravity=0`. Its A-button argument is arbitrary, so
the hand-control result separately covers never pressing A and continuously
holding A. This argument is a ghost input because the hand code does not read
A; it is not an ABC press-edge or controller model.

`DoublePoundTrace.v` replaces the false global separation shortcut with a
phase-local proof. At relative Z=0, the scaled/cast closed-top slice is
conservatively inside X `[-108,102]` and needs relative query Y at least 228.
The last vertically eligible trace point is `(-120,255)`, still outside that
slice; the first horizontally eligible point is `(-90,210)`, 18 units too
low. Rocq proves no point in the audited free-flight trace satisfies both
conditions. This is not a theorem for arbitrary phases or a linked proof that
wall resolution can only make the approach less favorable.

`PartialUpdateBoundary.v` formalizes the no-external-writer lifecycle. Spawn
starts with null collision, room -1, and both partial flags clear. A complete
running frame executes the native sleep body first, making collision nonnull,
then visibility cannot set FAR_AWAY and the default room cannot set
IN_DIFFERENT_ROOM. A time-stopped frame stutters the whole hand update. Rocq
therefore proves that no reachable live state in this source-shaped lifecycle
enters the movement-only partial guard. Linking the generated Clight scheduler
and all possible external writers to this lifecycle remains open.

The refined vertical relation uses exact maximum finite ascent budget 288. It
proves hand-origin ceilings 672 and 1467. Adding the collision top and modeled
triple-jump allowance gives a second-hand Mario peak ceiling of 2604.

Those are geometry-relaxed bounds, not authentic reachability witnesses. The
new Area 3 audit proves that the first hand's available static arena floors top
out at Y=-1150, while the tunnel begins at Y=-562 with no upward floor between
them. Because the floor query accepts a floor at most 78 units above the hand,
the full finite rise reaches only origin Y=-862 and misses tunnel eligibility
by 222 units. `FirstHandBarrier.v` proves that every state in the source-shaped
first-hand relation stays at or below -862, never selects the tunnel, and has
open collision top at or below -355. Therefore the old first-surface Y=1179
construction is unreachable in this barrier.

`TwoHandBarrier.v` conservatively grants the second hand every upward static
Area 3 floor, every possible first-hand contact at every X/Z, the tallest open
mesh in every phase, and preservation of unused rise across a floor snap. The
first dynamic surface is still at most Y=-355, below the static floor maximum
Y=384. Therefore the second support ceiling is 384, its finite origin ceiling
is 672, its open surface ceiling is 1179, and the modeled Mario peak is 1809.
This disproves the old second-origin 1467, second-surface 1974, and Mario 2604
constructions inside the source-shaped barrier. Since the Area 2 Y=1967 floor
requires query Y at least 1889, the old conditional Y=1967 trace cannot obtain
its starting premise from this barrier.

`HeightMilestones.v` now represents first surface Y=1179, second origin
Y=1467, second surface Y=1974, and Mario Y=2604 as distinct observations. It
also distinguishes always-released A, A held before the measured interval,
and a fresh press edge. No authentic Mario route is inferred from these
definitions.

`MarioHandContact.v` proves the next source-shaped interface facts. Direct
platform velocity adds X/Z but not Y. The attacked and death increments and
the 20-unit target lift pass the 78-unit vertical floor filter if Mario is
already supported. A stationary Mario fails that filter on the 85-unit first
double-pound step, a 100-unit runaway step, and the 201-unit closed-to-open
mesh switch. The closed/open standing floors (origin+306/+507) are strictly
above Eyerok's scaled hitbox top (origin+150), so standing on either top cannot
attack the eye. The ordinary origin+150, velocity-30 bounce also cannot satisfy
the height filter for the first lethal-rise surface.

The A schedule now proves that press-and-hold from frame zero has exactly one
fresh edge. Released A and A held before the interval have none. These facts do
not exclude an airborne action launched before the interval and do not yet
construct an X/Z-valid boarding trace. Held A is not inert: a punch can enter
a jump kick from `INPUT_A_DOWN` without a fresh edge.
Never-A can also obtain positive velocity from a B-only speed-kick dive. The
630-unit envelope is the checked triple-jump sequence and requires an
authenticated fresh-A landing chain when used as a witness; the 512-unit
backflip envelope is checked separately.

`LowerArea2Entry.v` resolves the next numerical route threshold without
claiming authentic hand reachability. Conditional on equality at the
source-shaped surface ceiling Y=1179 and on the full 630-unit triple-jump
envelope, Mario enters Area 2 at `(0,1809,-1024)`. The source audit verifies
that this interior point selects the Area 3 instant-warp surface; the north
edge at Z=-1023 is deliberately avoided because floor-list priority can select
an overlapping ordinary triangle there. Sixteen controlled arithmetic frames
reach `(0,1281,-832)` with vertical velocity -67, and the next quarter-step
query `(0,1264,-829)` selects the actual Y=1280 floor. Rocq separately proves
that Y=1809 cannot query Y=1967, and that a Mario left at surface Y=1179 with
no new impulse misses the Y=1280 query minimum 1202 by 23 units.

This is a conditional A-using route calculation, not an authentic execution.
The proof does not show that the hand reaches its ceiling, that Mario boards
it, that the triple-jump predecessor chain is possible there, that every one
of the sixteen frames refines the source collision/controller loop, or that no
earlier source collision changes the trace. The proved snap is a handwritten
landing relation tied to the audited query, not a linked Clight step. A
backflip envelope
would peak at Y=1691 and is numerically high enough for Y=1280, but no exact
backflip route witness has been constructed. Released-A and held-before-start
routes remain open; held A can still enable a jump kick, and never-A can still
enable the smaller B-only dive under its source preconditions.

`NoA1280Barrier.v` now resolves the straightforward B-only dive candidate
inside an explicitly ordinary, seam-free, horizontal-speed-at-most-48 model.
Conditionally starting from surface ceiling Y=1179, the speed kick writes
vertical velocity 20, rises only 60 units to peak Y=1239, and would enter Area
2 after the first Area 3 air frame at Y=1199 with velocity 16. Height alone is
enough for the Y=1280 query minimum, but the platform's south/east walls block
the approach. Mario has 35 eligible quarter-steps, hence at most 420 units of
path at 12 units per quarter-step. Going over requires base Y greater than
1255; going around the best east side needs more than 540 units; the west side
needs more than 2060. Rocq proves that every wall-avoiding path in this
classification is impossible, so an ordinary route must resolve against the
wall before reaching the top.

This is a meaningful no-A refutation, not an unrestricted original-game
theorem. The starting surface is still only a ceiling, speed-kick preparation
and static-warp selection are assumed, and the geometric classification still
needs linked source refinement. The theorem excludes seams, quantum tunneling,
parallel-universe casts, horizontal speed above 48, and any later recovery
after the source dive bonks into `BACKWARD_AIR_KB`. The already-held-A jump
kick remains a separate action trace.

`HeldA1280Barrier.v` now resolves the bounded-speed form of that separate
trace. A continuously held schedule has no fresh A edge, but the punch action
can still enter jump kick through `INPUT_A_DOWN`. The jump kick reuses the
20-unit launch, Y=1239 peak, and 35 eligible quarter-steps. Because inherited
forward speed is uncapped in the source, the theorem explicitly assumes
`|forwardVel| <= 48` plus a conservative 13-unit quarter-step premise, bounds
the total at 455, and proves that neither vertical clearance nor the east/west
detours fit. A
conditional stationary-predecessor budget is 140. Faster predecessors,
post-wall jump-kick continuation, and authentic hand/warp preparation remain
open.

`RequestedHeightVerdict.v` packages the completed arithmetic without changing
scope: the four legacy observations are impossible in the source-shaped
barriers; the Y=1280 fresh-edge landing remains conditional; and the ordinary
no-A wall theorem remains seam-free and speed bounded.

The generated Clight surface now includes `game_init.c` and Mario's moving,
object, and stationary action units. Rocq checks per-unit name resolution,
critical AST call-site traversal order, the controller's AND/XOR edge
expression, the B-only launch constants, the held-A jump-kick case's
vertical-slot-1 value 20, and the press-gated backflip call.
`ClightRefinementBoundary.v` defines a coherent execution from genuine Clight
small steps and transfers the older 1467/1974/2604 bounds and no-unbounded-rise
theorem **if** a complete linked program and height refinement are supplied.
Those premises remain open: no theorem yet reads the correct live hand's
binary32 `oPosY`, identifies game-frame boundaries, or connects PPC32 Clight
semantics to the IDO-compiled MIPS ROM.

The Mario/area relation proves:

- a hand floor does not trigger the instant warp;
- a selected Area 3 warp floor changes to Area 2 while preserving Mario's
  coordinates, velocity, and motion state;
- peak 2604 cannot reach the Y=2940 or higher audited tiers or collect the
  star; and
- a conditional adversarial trace reaches `(387,1967,-500)`, the point on the
  Y=1967 platform horizontally closest to the star.

The trace starts at the maximum hand state admitted by the older
geometry-relaxed vertical relation. The new two-hand barrier refutes that
starting state. The trace remains a checked counterfactual, not an
original-game trace.

The high-route counterfactual starts from hand origin Y=3627, enters Area 2 at
Y=4354, then makes its first quarter-step query at Y=4351, selects the Y=4429
platform, and reaches the Y=4815 star platform. This
proves that such a hand height would be route-useful. The audited source-shaped
coupled model cannot supply it. The stricter two-hand barrier bounds the second
origin at Y=672 and Mario's generously modeled peak at Y=1809, below even the
Y=1967 floor-query threshold. The result holds for arbitrary A input, no A,
and held A inside this abstraction. Even the no-A theorem grants the 630-unit
Mario rise, so it is an impossibility result rather than a legal no-A route
witness.

The binary32 boundary proof establishes that every finite binary32 height is
at most `2^128 - 2^104`. It also proves the exact fixed point
`Float32.add 2^31 100 = 2^31`, stagnation when the recurrence is started
there, and CompCert's `Float32.to_int 2^31 = None`. Thus literal unbounded
finite Y is closed independently of scheduler reachability. Persistent action
or positive velocity outside the source-shaped kernel, a linked whole-program
refinement of the kernel, and the original ROM's out-of-range conversion remain
separate questions. Within the audited source-shaped kernel, dangerous-seed
reachability is now closed.

## Remaining proof route

1. Link the generated translation units and prove that every relevant Clight
   frame refines the source-shaped kernel, including update rank, dynamic
   surfaces, the no-external-writer partial lifecycle, time stop, Mario
   contact, and floor-pointer lifetime.
2. Prove Mario's remaining contact lifecycle on the hand: an X/Z-valid initial
   boarding state, per-frame selected-floor priority, dismount, and selection of the
   static Area 3 warp floor. Decide released-A, held-before-start, and fresh
   press-and-hold schedules separately.
3. Prove an event-by-event Clight bridge for the two-hand finite-episode
   premise: every positive episode starts from classified support and has at
   most 288 remaining rise, with no airborne replenishment. Include the exact
   positive-double near-miss and dynamic-wall response.
4. Authenticate or refute the conditional Y=1280 landing under the Y=1809
   ceiling: prove the hand/Mario predecessor, all quarter-step collision and
   controller transitions, and the actual landing. Compare fresh-A triple
   jump, backflip, and held-A jump-kick cases. For never-A, refine the new
   ordinary speed-48 wall barrier and separately investigate faster or
   collision-glitch traces. For held A, prove the incoming-speed bound or
   analyze faster predecessors and the jump kick's post-wall continuation.
5. Optimize an authentic remaining Area 2 route to the star and count new A
   presses.
   The present work rules out the proposed higher Eyerok shortcut inside the
   source-shaped model; the old Y=1967 witness is now refuted there.
6. Determine whether any machine behavior outside the source-shaped kernel can
   preserve the dangerous action/velocity after binary32 Y stops changing.
7. Add an IDO/MIPS semantic boundary for the out-of-range float-to-integer
   conversion if a ROM-level execution claim is required.

## Repository constraints

- Work only in `SSL-Cog/eyerok-manipulation/`, apart from the existing project
  entry in `SSL-Cog/README.md`.
- Inspect but do not modify `SSL-Cog/ssl-pyramid-item-proof/`.
- Update `docs/goal.md`, `docs/claim.md`, and `docs/checklist.md` in every
  commit.
- Commit each coherent change.
- Use the Ubuntu WSL distribution and the `sm64-item-proof` opam switch.
- Do not push without explicit user approval.
