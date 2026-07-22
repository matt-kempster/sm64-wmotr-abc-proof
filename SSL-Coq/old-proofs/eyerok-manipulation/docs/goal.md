# Goal recovery note

Last updated: 2026-07-19 (US/JP particle-platform version split).

## Objective

Decide the following related but separate questions for the pinned shared
source and the North American/original-Japanese version-specific behavior:

1. Can Mario use a raised Eyerok hand to select the Area 3 instant-warp floor
   and enter Area 2 at a useful height?
2. Are the finite Rocq hand-height bounds high enough for a useful Area 2
   landing, especially near the `Inside the Ancient Pyramid` star?
3. Can finite binary32 Eyerok Y be manipulated into an unbounded ascent, and
   can the dangerous upward-control state persist in an audited source-shaped
   run, a linked Clight run, or the original ROM?
4. Can either hand, or the two hands together, create a Pedro spot that Mario
   can use to build route-relevant speed?
5. Can an exploding hand replace a stale Eyerok slot with its rotating fragment
   and cause particle platform displacement? Separately, can the Area 3-to-Area
   2 load leave another stale raw payload that causes spawning/platform
   displacement?

The proof must not infer Mario reachability from a hand-origin upper bound.
Hand movement, Mario/platform contact, floor selection, area change, Area 2
collision, and star interaction are separate interfaces.

The new exploit layer resolves the same-area Eyerok-fragment form of question 5
negatively in both versions, and the cross-area form negatively in US because
US clears `gMarioPlatform`. Original JP retains a raw slot address, so a broader
cross-area candidate remains open. An ordinary coherent warp carries `NULL`,
and the matching-ROM injected comparison reused the address for a zero-motion
water droplet, but no authentic stale-floor/hand-pointer trace or rotating
replacement has been reached. For question 4 it finds real geometry, but the
two analyzed configurations do
not establish a useful speed engine: the stationary strip needs preloaded
speed above 400, while the ordinary local wake entry exists only on the last
valid update and therefore cannot provide a repeatable grind. The common air
helper's ideal-arithmetic bound is 3.85 for that one update; retail binary32
requires the conservative figure 4, whose universal Float32 proof remains
open. Other action-entry writes are not globally bounded here. Authentic 0/0.5-A
reachability of the exact wake prestate remains open, and other action phases
or seam-assisted entries have not been exhaustively classified.

## Completed proof layers

The project pins source revision
`9921382a68bb0c865e5e45eb594d9c64db59b1af` and generates CompCert Clight for
shared behavior plus US/original-JP area and platform units. Shared generated
units come from pin-identical files. The available 36fb JP units use disabled
TAS-hack blocks; the audit verifies the relevant normalized function bodies
against the pin, and a clean pinned JP build matches the canonical ROM.

The deterministic source audits now pin:

- the exact Area 3 warp quad and zero-displacement destination;
- the inactive matching Area 2 slot and adjacent return warp;
- the Area 2 Y=896, 1280, 1967, 2940, 4429, and 4815 route tiers, including
  exact floor-list selection at the lower witness's Y=1280 query;
- the star at `(500,5050,-500)` and its interaction bounds;
- that the largest upward-facing Area 3 floor vertex is 384 (the old value 896
  was the maximum of every vertex, including walls); and
- that platform displacement has no direct vertical-velocity addition;
- the US area-load platform clear, the original-JP omission, and JP's
  consume-before-refresh object-update order and three runtime gates;
- that floor equality clears both ground bits because grounding uses a strict
  comparison;
- the complete relevant gravity-writer order, hand spawn/update order, and
  dynamic-surface clear order;
- every `Unk1AC` exposure-latch writer, the `OPEN` acquisition and
  `SHOW_EYE` preservation of that latch, and the boss requirement that both
  the exposure latch and active-hand lock be zero before scheduling advances;
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

`IdleVelocityInvariant.v` addresses the distinct airborne candidate that the
kernel did not represent. It tracks `oVelY`, gravity, action, grounding, the
boss active-hand lock, and the double-pound terminal state. The source audit
now exhaustively checks all three assignments into `IDLE`, both zero-gravity
exits, every direct positive `oVelY` writer, the attacked animation delay, and
the boss lock/terminal guards. It also checks that the `SHOW_EYE` active-hand
clear is one-hand-only, that `SHOW_EYE` retains the independent exposure
latch, and that a single-hand double pound reasserts its active-hand lock. Rocq
proves every reachable `IDLE` state has
nonpositive velocity and excludes
`DOUBLE_POUND + airborne + gravity=0 + positive velocity`.

`NonlethalNoStacking.v` closes the repeated-nonlethal subproblem in one
source-shaped lifecycle. It tracks initialized health, relative Y, vertical
velocity, gravity, grounding, ATTACKED age, the one-frame attack latch,
accepted-hit count, and an owed-home-reset flag. Rocq proves that health 4
permits two nonlethal responses (`4->3` and `3->2`), each airborne impulse adds
at most 98 Y, and any path to another accepted nonlethal hit contains the
exact-home `RETREAT -> IDLE` reset with nonpositive inherited velocity. The
source audit now checks the full handler graph, health initialization and
decrement, latch overwrite, 15-movement ordinary ground return, and 25-frame
animation gate; generated Clight facts check the corresponding AST shape.
This does not forbid a different support mechanism after the reset, and its
dynamic whole-program Clight/ROM refinement remains open.

The new Ubuntu-24.04 Mupen64Plus probe checks this boundary on the hash-authenticated
US ROM as a separate evidence layer. It authenticates the ROM, discovers live
Eyerok objects by behavior, waits for genuine hand initialization and an
ordinary real-floor update, then installs a fully disclosed local scheduler
precondition without writing any hand physics field or either double-pound
action. The trace reaches IDLE, BEGIN_DOUBLE_POUND, and DOUBLE_POUND with zero
velocity; the next selected airborne handler writes gravity -20, while the
first +85 movement has gravity -15. No alternate seed occurs in 476 hand
rows. The fixture shortens area travel and scheduling, so this is not a
from-reset controller-only trace and does not close the source-to-ROM proof
boundary.

The companion contact wrapper runs three hash-authenticated ROM modes and
never writes a hand field. Stationary Mario is inside the closed top but loses
it at pre-query gap 85, after which the arena floor/hand underside produces
`ACT_SQUISHED`. In the successful schedules, retail Mario code first produces
Y=-1208/vY=16 and then Y=-1192/vY=12; the next +85 hand update leaves a
49-unit pre-player-update gap. The first air quarter-step adds 3, making the
modeled floor-query gap 46, and ordinary collision snaps to that same hand. A rear-interior B-only dive
with A always released and an already-held-A jump kick with no new edge both
remain floor/platform on every positive step to Y=-943. The B trace starts
from an injected walking/speed/stick predecessor; the held-A trace starts from
injected MOVE_PUNCHING state 0, so authentic predecessor reachability remains
open. Analyzer-derived X/Z/triangle, floor-owner, platform-owner, and fixture
evidence is versioned; build output and Python caches are locally ignored.

The attack wrapper adds nonlethal/lethal inherited-long-jump and slide-kick
modes plus bounded analog/braking continuations. It enforces the same US ROM
by MD5, SHA-256, and header CRC. The nonlethal long jump really reacquires the
home-height open hand at Y=-1027 one frame before its ground flag sets, later
reacquires the closed hand at -1228, and
rides `TARGET_MARIO` to -928. The lethal long jump passes the vertical filter
at conservative pre-player-update gaps 63/7 but misses X/Z then; steering later selects the hand as a floor,
never as a platform, and deletion wins with Mario still 43 units above it.
The source-valid B-only slide-kick entry has no A gate, but the tested front
wall immediately changes it to backward air knockback in both health modes.
All of these are local-fixture continuations, not controller-from-reset routes.

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

`DoublePoundBoarding.v` supplies the height-eligibility witness, and the ROM
probe resolves the concrete local timing. A stationary Mario loses the hand
on +85. Starting at observed hand timer 2 lets retail jump-kick or dive code
complete +20 and +16 Mario updates before launch. The +85 frame therefore
has a 49-unit pre-player-update gap and a 46-unit first-quarter query gap,
snaps to the closed top, and both recorded modes follow
every +70/+55/+40/+25/+10 step to Y=-943. The held-A input has no fresh edge
in the measured suffix (0.5-A-style), while the B-only suffix keeps A always
released. These are not complete ABC route counts because their predecessor
states are injected. Same-frame entry is blocked at gap 85 by the 78-unit
filter and underside squish. Controller predecessor boarding and boss
synchronization remain open.

`AttackedReboard.v` checks the standard `-4` schedule as arithmetic over
explicit lists. Its nonlethal open mesh fails the vertical filter during the
rise; the later 46-unit closed-top query is only conditionally height-eligible
and is not a proved snap. Its minimum listed airborne gap is 153, and its
first-grounded gap is 191.

The separate runtime result supplies the operational counterexample to the
old universal wording: inherited `ACT_LONG_JUMP` really reboards the
nonlethal home-height open top while the hand still has velocity -26 and no
ground flag; the flag sets next frame. It does not stay on during the +98
ascent. The lethal counterpart has conservative pre-player-update gaps 63/7 but is outside the top in X/Z;
after steering solves X/Z later, the hand becomes a selected floor but never
a platform. At the final live row Mario is -984 over top -1027, the next
projected position -1006 is still above it, and deletion precedes the -1030
crossing. The first post-deletion stored floor address is stale—the hand is
inactive and the platform null—and it clears before that crossing. A braking trace keeps X/Z valid through deletion, so this is the
first exact blocker for that cleaned local candidate.

The inherited long jump normally begins on a fresh A edge. The measured suffix
has A released, but that does not make it zero- or 0.5-A. Conversely, B-only
slide kick is genuinely no-A enterable; its tested open-wall branch exits to
`ACT_BACKWARD_AIR_KB` before the hand response and neither health mode
reboards. Other initial poses, yaw/action changes, and glitches remain open.

The Rocq result certifies height/XZ/deletion arithmetic, not the retail trace.
The source audit checks its governing branches and the ROM analyzer checks the
actual hit, actions, meshes, selected floor, platform, and deletion. A linked-
Clight derivation is still absent.

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
  coordinates, velocity, and motion state during the abstract warp step;
- original JP can subsequently consume a retained nonnull raw platform address
  in the same frame, while the ordinary coherent prestate carries `NULL`;
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
2. Authenticate the proved local hand-contact traces: reach an X/Z-valid
   closed-hand predecessor with held A or B-only speed at least 29, synchronize
   the observed timer-2 action and two prepared Mario updates, confirm
   selected-floor priority, then
   dismount and select the static Area 3 warp. Keep zero-A and 0.5-A schedules
   separate.
3. Construct or refute a controller predecessor for the successful nonlethal
   inherited-long-jump reboard, including its required prior A edge, then test
   whether the post-recovery/`TARGET_MARIO` top can dismount to the static
   warp. Generalize the lethal local blocker beyond the tested pose and
   bounded steering/yaw/braking schedules; separately search source-valid
   no-A actions beyond the blocked front-side slide kick.
4. Prove an event-by-event Clight bridge for the two-hand finite-episode
   premise: every positive episode starts from classified support and has at
   most 288 remaining rise. The grounded and inherited-positive-velocity
   zero-gravity seeds and nonlethal impulse stacking are now excluded by
   source-shaped Rocq invariants. Link those invariants to Clight/ROM frames,
   classify the other positive actions, and include the exact positive-double
   near-miss and dynamic-wall response.
5. Authenticate or refute the conditional Y=1280 landing under the Y=1809
   ceiling: prove the hand/Mario predecessor, all quarter-step collision and
   controller transitions, and the actual landing. Compare fresh-A triple
   jump, backflip, and held-A jump-kick cases. For never-A, refine the new
   ordinary speed-48 wall barrier and separately investigate faster or
   collision-glitch traces. For held A, prove the incoming-speed bound or
   analyze faster predecessors and the jump kick's post-wall continuation.
6. Construct or refute the authentic original-JP stale-floor/hand-pointer
   prestate. If reachable, stage the explosion/allocation order, identify the
   exact residual or Area 2 slot payload, derive the actual Float32 rotational
   displacement, and distinguish ordinary coordinates from a PU-scale lever
   arm. Keep never-A and already-held-A predecessors separate.
7. Optimize an authentic remaining Area 2 route to the star and count new A
   presses.
   The present work rules out the proposed higher Eyerok shortcut inside the
   source-shaped model; the old Y=1967 witness is now refuted there.
8. Determine whether any machine behavior outside the source-shaped kernel can
   preserve the dangerous action/velocity after binary32 Y stops changing.
9. Add an IDO/MIPS semantic boundary for the out-of-range float-to-integer
   conversion if a ROM-level execution claim is required.

## Repository constraints

- Work only in `SSL-Coq/eyerok-manipulation/`, apart from the existing project
  entry in `SSL-Coq/README.md`.
- Inspect but do not modify `SSL-Coq/ssl-pyramid-item-proof/`.
- Update `docs/goal.md`, `docs/claim.md`, and `docs/checklist.md` in every
  commit.
- Commit each coherent change.
- Use the Ubuntu WSL distribution and the `sm64-item-proof` opam switch.
- Do not push without explicit user approval.
