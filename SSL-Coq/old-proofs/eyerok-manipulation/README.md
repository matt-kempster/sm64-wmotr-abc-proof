# Eyerok manipulation proof

This project studies the proposed Shifting Sand Land route in which an Eyerok
hand is manipulated into rising without bound above the instant-warp floor
triangles between the Pyramid interior and the boss arena. It follows the
Rocq/Coq + CompCert Clight structure used by the sibling SSL-Coq projects.

The intended target is deliberately adversarial: player position, attacks,
timing, and the boss's random choices may select any original-game action
transition. The executable source-shaped kernel contains event cases for the
audited choices relevant to the dangerous vertical launch and treats the
A-button policy as arbitrary. Its source correspondence is audit-backed; a
linked whole-program Clight refinement remains open.

See [Eyerok.md](Eyerok.md) for the source state machine,
`docs/claim.md` for the exact formal boundary, and `docs/checklist.md` for the
live proof status.

## Project route

```text
pinned common SM64 source plus US/original-JP area and platform behavior
  -> reproducible source audit + CompCert clightgen
  -> generated Clight AST shape certificates
  -> executable source-shaped launch kernel under arbitrary A input
  -> nonlethal health/recovery lifecycle + no-stacking theorem
  -> audited arena/tunnel split + source-shaped two-hand barriers
  -> handwritten Eyerok, Mario/warp, and Area 2 transition systems
  -> hand-height invariant + route-threshold theorems
  -> relation-level and binary32 representation bounds
  -> requested-height verdict + conditional Y=1280 route barriers
  -> refuted Y=1967 premise + high-route counterfactual
  -> original-game refinement (open)
```

Generated Clight files are never hand-edited.

## Pedro and particle-platform verdict

The source audit finds two real Pedro geometries in the two configurations
analyzed here, while the Rocq proof keeps
geometry, entry, and usefulness separate. The stationary sleeping-hand strip
has a 38-unit gap, but ordinary exterior entry is behind a greater-than-100
quarter-step wall band. A US-ROM local fixture reaches it with preloaded speed
424; speed 48 does not. The injected fixture establishes no A-press count.
During the one-time wake, the two palms have valid
gaps on updates 5--11, and update 11 admits an exact one-unit local entry.
Update 12 has gap 162, so ordinary entry permits only one cancellation and at
most one air-speed update, not a repeatable grind. For the common with-turn and
without-turn air helpers, the ideal-arithmetic Rocq envelope is 3.85 on that
update; retail binary32 witnesses require the conservative value 4. The Float32
bound is not yet machine-checked. Authentic controller
reachability of the update-11 airborne prestate, especially with no new A
press, remains open. Other action families, hand phases, seams, and
moving-boundary entries have not been exhaustively classified.

The pinned-source audit blocks the same-area Eyerok-fragment construction in
both checked versions. Each hand allocates its particles before freeing its
own slot, and the exclusive eye lock prevents the sibling from exploding in
the next-active-update stale-pointer window. The Rocq lifecycle relation
formalizes those audited premises; it is not a linked whole-program refinement.

The cross-area result is version-specific. US clears Mario's saved platform
pointer while loading Area 2. Original JP omits that call, retains the raw slot
address, and consumes a nonnull address before the first Area 2 update refreshes
it. An ordinary coherent JP warp carries `NULL`; an authentic stale cached warp
floor plus freshly saved hand pointer remains open. In a disclosed injected
comparison, the authentic JP ROM reused hand slot 32 for a zero-motion
`bhvWaterDroplet`. Source/Clight order implies one unchecked application; the
probe observed effective delta `(0,0,0)` and unchanged Mario speed. No explosion
or 0/0.5-A route was staged. Platform displacement changes position/facing, not stored speed, so a
hypothetical large result would depend on positional lever arm rather than
normal versus PU stored speed.

See `proofs/PedroSpot.v`, `proofs/EyerokParticleDisplacement.v`,
`proofs/JPPlatformPersistence.v`, the US Pedro trace in
`instrumentation/results/pedro_entry_trace.csv`, and the JP evidence manifest
in `instrumentation/results/jp_platform_manifest.md`.

## Current status

The source-ingestion pipeline generates shared Clight units from files identical
to the pinned revision, plus version-specific US and original-JP area/platform
units. The available 36fb checkout adds disabled TAS-hack blocks to three JP
source functions; the audit proves their normalized disabled bodies equal the
pinned revision, and a separate clean pinned `VERSION=jp COMPARE=1` build is
byte-identical to the canonical JP ROM. The generated surface covers Eyerok,
object motion and scheduling, controller input, floor queries, area change,
Mario actions, platform displacement, interactions, and the SSL script.
Deterministic audits
check the source pin, vertical writer census, paired instant warps, collision
bounds, Area 2 landing tiers, and the target star. Those checks do not
themselves prove an authentic route. They now also pin the strict ground test,
ground-mask clearing, gravity-writer order, collision/room lifetime, hand
spawn/update order, absence of other Area 3 surface objects, and closed-hand
geometry used by the source-shaped launch kernel.

The audit exposes one critical tripwire: the local C state
`DOUBLE_POUND + grounded + gravity=0` would launch at velocity 100 without
ever installing negative gravity. `proofs/AuthenticKernel.v` proves this state
unreachable for every modeled event sequence and every A-button policy,
including never pressing A and continuously holding A. The key source fact is
that equality with the floor clears stale grounding on the frame that starts
the double pound. No linked theorem yet proves that every whole-program Clight
or original-ROM execution is represented by this kernel.

`proofs/IdleVelocityInvariant.v` closes the separate inherited-velocity
candidate. The audit finds exactly three entries into `IDLE` and two
zero-gravity exits. The Rocq relation preserves the source fact that `IDLE`
does not necessarily clear velocity, but proves every reachable inherited
value is nonpositive. It therefore excludes
`DOUBLE_POUND + airborne + gravity=0 + positive velocity`. This result uses
the attacked-animation delay and the boss active-hand/terminal handshake; a
linked whole-program/ROM refinement is still a separate obligation. The audit
also closes the apparent sibling exception: `SHOW_EYE` can clear the global
active-hand lock only in the one-hand phase, retains the independent nonzero
`Unk1AC` exposure latch, and a one-hand double pound reasserts its own
active-hand lock before branching. The boss scheduler requires both locks to
be zero.

`proofs/NonlethalNoStacking.v` closes the repeated-nonlethal question inside
a unified source-shaped lifecycle. It tracks initialized health, action,
relative Y, vertical velocity, gravity, grounding, the one-frame attack latch,
ATTACKED age, impulse rise, accepted-hit count, and whether a home reset is
owed. Each hand permits two nonlethal hits (`4->3` and `3->2`); `2->1` is
lethal. Rocq proves that each airborne nonlethal impulse contributes at most
98 Y and that every trace from one accepted nonlethal hit to another contains
the genuine `RETREAT -> IDLE` event that clamps Y to `oHomeY` with
nonpositive inherited velocity. Thus the two `+98` impulses do not stack.
This does not claim that another hand or later boss action cannot raise the
hand again after the reset. Generated-Clight AST facts and the deterministic
source audit pin the lifecycle graph; dynamic whole-program Clight/ROM
refinement remains open.

The A value is a ghost input because the Eyerok hand code does not read it. It
shows that changing only A cannot alter this hand-control invariant; it does
not model new press edges or construct a legal no-A Mario route.

The project now includes a reproducible Mupen64Plus probe of this exact
boundary on the hash-authenticated US ROM. It waits for genuine Eyerok hand
initialization, changes only SLEEP to IDLE, lets an ordinary update populate
the real arena floor fields, and then installs a disclosed boss scheduler
precondition without writing hand physics or double-pound actions. The
observed IDLE -> BEGIN_DOUBLE_POUND -> DOUBLE_POUND trace writes gravity -20
at nonpositive velocity before the first +85 movement, which has gravity -15.
The analyzer found no alternate seed in 476 hand rows. See
[instrumentation/README.md](instrumentation/README.md). This is a real ROM
continuation from a source-reachable initialized local precondition, not a
from-reset controller-only fight trace or a discharged ROM refinement.

The instrumentation also contains three hash-authenticated-US-ROM local
Mario/contact continuations. Stationary Mario loses the hand on `+85`: the
pre-query gap is
85, beyond the 78-unit filter, and the hand underside produces squish input.
For both prepared actions, retail code first records Mario at Y `-1208` with
velocity `16`, then Y `-1192` with velocity `12`; the hand moves first on the
next frame, leaving a 49-unit pre-player-update gap. Mario's first air
quarter-step adds 3, so the modeled floor-query gap is 46, and ordinary
collision snaps Mario to
top Y `-1143`. A rear-interior B-only dive with A always up and an already-held
A jump kick with no new A edge both remain same-hand floor/platform on all six
positive steps and reach Y `-943`. The B run injects a walking/speed/stick
predecessor and a real B edge; the held-A run injects MOVE_PUNCHING state 0, so
neither is yet a controller-only predecessor trace. X/Z triangle eligibility,
floor ownership, platform ownership, and every fixture write are recorded in
`instrumentation/results/contact_manifest.md`.

A separate strict-US-ROM attack probe checks fixture-assisted inherited
`ACT_LONG_JUMP` and `ACT_SLIDE_KICK` cases without writing a hand's post-hit
action, velocity, gravity, flags, or collision mesh. The nonlethal long-jump
case performs a retail hit and response, then selects the home-height open top
at Y `-1027` as both floor and platform through an ordinary ledge grab. On that
row the hand still has velocity `-26` and no ground flag; it grounds on the
next frame. It later
reacquires the closed top at `-1228` and is carried by `TARGET_MARIO` to
`-928`. This is a real local reboard, but it happens after the `+98` attacked
episode has returned home; it does not ride that upward impulse.

The lethal long-jump case has conservative pre-player-update gaps `63` and
`7`, but the open front wall leaves the tested pose outside the top at those
early frames.
With `squishTimer=0`, full-stick steering later makes the hand Mario's selected
floor, but never his platform: on the final live hand row Mario is still 43
units above the open top, one projected update would still leave 21 units, and
the hand is deleted before the second update would cross it. The first
post-deletion row's stored floor address is stale: the hand is inactive and
Mario's platform is null, and the pointer clears before the crossing. The bounded
steering sweep is not an exhaustive controller proof. The B-only/no-A
`ACT_SLIDE_KICK` source entry writes velocity 12 and clamps speed to at least
32; the tested open-wall contact immediately changes it to
`ACT_BACKWARD_AIR_KB` in both nonlethal and lethal modes, and neither trace
reboards. The injected long jump itself has an unproved predecessor and its
normal entry requires a fresh A edge, so none of these attack traces is yet a
zero- or 0.5-A route.

The former 280-unit global hand-separation argument was incorrect and has been
removed. `proofs/DoublePoundTrace.v` uses the exact phase-local positive-double
trace instead. The setup begins 360 units behind; at relative Z=0 the last
vertically eligible query `(-120,255)` is outside the closed top, while the
first horizontally eligible query `(-90,210)` is 18 units too low. Rocq proves
that no audited trace point satisfies both conditions.

`proofs/PartialUpdateBoundary.v` closes the other source-shaped stutter route.
It models native collision loading before visibility, persistent room -1, and
whole-update time-stop freezing, then proves that no reachable live hand in
the no-external-writer lifecycle enters the FAR_AWAY/IN_DIFFERENT_ROOM movement
guard. These are audited source-shaped theorems; linked Clight writer/order
refinement remains open.

The audit now also separates the Area 3 collision into arena floors, whose
maximum Y is `-1150`, and tunnel floors, whose minimum Y is `-562`. There are
no upward-facing floor triangles between them. `proofs/FirstHandBarrier.v`
uses the 78-unit floor-query tolerance and first-hand update rank to prove that
the first hand's maximum finite origin is `-862`, its open surface top is
`-355`, and it cannot select the tunnel floor. Thus the older first-hand
surface Y `1179` construction is not reachable in this source-shaped barrier.
The linked finite-episode refinement and the Mario-contact cases remain open.

`proofs/HeightMilestones.v` keeps Y `1179`, `1467`, `1974`, and `2604` as four
different observations rather than interchangeable heights. It also defines
controller schedules with a pre-interval A bit, so always-released A,
continuously-held A, and a fresh press-and-hold can be distinguished.

`proofs/TwoHandBarrier.v` grants the second hand every static Area 3 floor and
every possible contact with the first hand's tallest collision. The first
dynamic surface ceiling `-355` is below the static upward-floor maximum `384`,
so the second hand's support ceiling remains `384`. Rocq obtains second origin
ceiling `672`, surface ceiling `1179`, and modeled Mario peak `1809`. This
strictly excludes the old `1467`, `1974`, and `2604` milestones and is below
the `1889` query threshold for Area 2's Y=1967 floor.

`proofs/MarioHandContact.v` separates platform displacement, vertical floor
eligibility, and interaction hitboxes. The source directly adds only a
platform's X/Z velocity to Mario. The attacked/death increments and 20-unit
target lift fit the 78-unit floor buffer if Mario is already supported; the
85-unit first double-pound step, 100-unit runaway step, and 201-unit
closed-to-open mesh switch do not. Standing on the closed/open top also puts
Mario above the hand's scaled 150-unit attack hitbox, so he cannot simply
stand on the hand, attack the eye, and ride the lethal rise.

The same module distinguishes A held before the interval from a fresh press:
released and already-held schedules have no new edge, while pressing and
holding from frame zero has exactly one. This does not yet prove boarding or a
no-A route; a carried-in airborne action is still possible unless its
predecessor trace is constrained.
Held A is not otherwise inert: the pinned punch actions can enter a jump kick
from `INPUT_A_DOWN` without a fresh edge, so each action gate must be audited
separately.
Never-A input can still obtain a smaller B-only speed-kick dive. The checked
630-unit and 512-unit envelopes are specifically the ordinary triple jump and
backflip; the former needs a fresh-edge jump chain and neither is a no-A route
witness merely because an upper-bound theorem grants it.

`proofs/DoublePoundBoarding.v` gives the height-eligibility witness; the ROM
probe supplies the concrete local timing. In the observed schedule, jump kick
or speed kick completes `+20` and `+16` updates before the hand launches. The
next `+85` step therefore leaves a 49-unit pre-player-update gap; the first
air quarter-step reduces the modeled floor-query gap to 46, and ordinary
floor logic snaps Mario to the closed top. Both recorded modes follow every later
positive increment through `+10`. Same-frame entry is too late: the gap is 85,
the hand underside leaves only 89.5 units of clearance, and squish input is set
before the new action can help. Authentic predecessor boarding and boss
synchronization are still open.

`proofs/AttackedReboard.v` classifies the explicitly listed standard `-4`
Mario-gravity schedule. The nonlethal open mesh stays outside the vertical
buffer during its 98-unit ascent. After recovery, the listed Mario query would
be 46 units below the closed top at Y -1228; this is conditional height
eligibility, not a proved or observed snap. In the same listed schedule the
lethal open mesh has minimum airborne gap 153 and first-grounded gap 191.

The module also certifies arithmetic transcribed from the separate ROM probe:
the nonlethal long-jump floors `-1027/-1228/-928`; the lethal `63/7` early
vertical windows and tested `127 > 76.5` X/Z miss; the standard-gravity
airborne/first-grounded gaps `153/191`; and the final lethal
`43`, then projected `21`, units above the grounded open top before deletion.
These lemmas do not turn the injected local Mario pose into a controller trace.

That Rocq module checks arithmetic over an explicit, hand-written schedule.
The source audit supplies the update-order, interaction, animation, mesh, and
deletion facts; Rocq does not yet derive the schedule from linked Clight
small steps.

`proofs/LowerArea2Entry.v` tests the stricter two-hand ceiling. It deliberately
assumes equality at second-hand surface ceiling Y=1179 and adds the 630-unit
triple-jump envelope to obtain conditional Mario Y=1809. The pinned audit
checks that `(0,1809,-1024)` selects the Area 3 warp; this avoids a floor-list
priority conflict at the Z=-1023 edge. Sixteen controlled Area 2 frames lead
to `(0,1281,-832)`, and the next query `(0,1264,-829)` selects Y=1280. A
handwritten landing relation snaps to that floor. Rocq also proves Y=1809
cannot query Y=1967 and that surface Y=1179 without another impulse misses
Y=1280 by 23. This is not an authentic hand pose, controller/Clight trace,
fresh-A predecessor proof, never-A route, or held-A route.

`proofs/NoA1280Barrier.v` addresses the direct B-only alternative. Conditional
on surface Y=1179, the speed kick rises 60 units to Y=1239. Although that is
numerically high enough for a Y=1280 query, the platform's south/east walls
block a direct wall-avoiding approach: only 35 eligible quarter-steps and 420
units of path are available at speed 48, versus base Y above 1255 to pass over
or more than 540 units to pass east. Rocq proves every seam-free wall-avoiding
path in this classification impossible. It does not cover faster speed, post-bonk
recovery, seams/tunneling, PU casts, or authentic hand/warp preparation.

`proofs/HeldA1280Barrier.v` treats the already-held-A punch-to-jump-kick
alternative separately. The jump kick has the same 20-unit vertical launch,
but inherits uncapped forward speed. Under the explicit predecessor bound
`|forwardVel| <= 48` and an explicit conservative 13-unit quarter-step budget,
Rocq bounds the total at 455 and proves the same ordinary seam-free
wall-avoiding route impossible. This
does not cover a faster predecessor or prove what happens after the jump kick
hits the wall.

`proofs/RequestedHeightVerdict.v` packages the four requested milestones
without mixing their meanings: first surface 1179, second origin 1467, second
surface 1974, and Mario Y 2604 are all excluded in the source-shaped barrier
relations. It separately records the conditional Y=1280 fresh-edge witness
and the restricted no-A wall theorem; it does not promote either to an
original-game trace.

`inputs/eyerok_model.c` makes a vertical abstraction executable. It
tracks surface-list rank, controlled positioning, static or earlier-hand
support, finite ascent budget, partial-update stuttering, deletion, and the
runaway seed as a distinct mode. Its Clight AST is generated alongside the
pinned source surface. No semantic theorem connects executions of this C
abstraction to the handwritten Rocq `vertical_step` relation. Its public API
can violate the Rocq launch precondition; its safety predicate reports such a
violation but does not prevent it.

`proofs/ClightRefinementBoundary.v` now states the semantic gap as a theorem
premise rather than prose. It checks generated-unit name resolution and
AST call-site traversal order, defines a coherent run from genuine CompCert
Clight small steps, and conditionally transfers the 1467/1974/2604 bounds and
no-unbounded-rise result. The project does **not** construct the complete
linked program or prove the required refinement, binary32-to-integer observer,
or equivalence to the IDO-compiled MIPS ROM.

## Current result

`proofs/EyerokManipulation.v` packages these independent closed-world facts:

- the generated model contains the envelope constants, while the critical
  authentic-source Clight shapes pin float-constant counts, the movement call,
  controller edge expression, A/B action gates, per-unit name resolution, and
  relevant dynamic-surface/list call-site traversal; the source audit pins the
  exact impulse, gravity, strict-ground, list-order, and collision-lifetime
  facts;
- every state reachable in the scheduler and the executable source-shaped
  kernel excludes the runaway seed, independent of Mario's A-button policy;
- the unified per-hand nonlethal lifecycle permits two nonlethal health
  transitions, bounds each airborne impulse to origin+98, and requires an
  exact-home `RETREAT -> IDLE` reset before another accepted nonlethal hit;
- the source-shaped first-hand barrier bounds its origin at absolute Y `-862`,
  prevents tunnel-floor selection, and bounds its open surface at `-355`;
- the source-shaped two-hand barrier bounds the second origin at `672`, its
  open surface at `1179`, and the generously modeled Mario peak at `1809`;
- the Mario-contact arithmetic proves the ride/filter, hitbox, bounce, and
  fresh-A-edge facts above, while leaving X/Z contact and action execution
  explicit;
- hash-authenticated local-fixture normal-double continuations show full
  finite-rise already-held-A/no-new-edge and A-always-released B-only catches
  after two prepared Mario updates, while leaving their predecessors open;
  the standard-gravity attack certificate proves only listed vertical
  conditions, while the separate inherited-long-jump probe really reboards
  the nonlethal home-height open hand one frame before its ground flag sets,
  but does not reboard the lethal hand;
- the exact positive-double trace has no sibling-floor candidate, and the
  no-external-writer lifecycle has no movement-only partial update; neither is
  yet a linked whole-program theorem;
- the conditional lower-route certificate uses the Y=1809 ceiling to select
  and model-land on the audited Y=1280 floor, while excluding Y=1967 and
  leaving authentic hand/controller reachability explicit;
- the ordinary never-A B-only candidate is wall-blocked under a seam-free
  speed-48 route classification, without claiming unrestricted no-A
  impossibility;
- the already-held-A jump-kick candidate is likewise wall-blocked when its
  inherited forward speed is at most 48, without claiming an unrestricted
  held-A result;
- the requested-height package preserves the separate observation types and
  the separate source-shaped, conditional-route, and no-A scopes; and
- the older geometry-relaxed vertical relation bounds hand origins at absolute
  Y 672 for `FirstHand` and 1467 for `SecondHand`; and
- no infinite execution of that handwritten relation is unbounded above.

`proofs/AuthenticReachability.v` couples the launch kernel with the conservative
vertical relation. A reachable dangerous seed would enable an explicit runaway
transition, so the height invariant's runaway case depends on the kernel proof.
Ordinary finite vertical steps remain the safe handwritten abstraction; there
is not yet a shared-height or event-by-event Clight refinement. The module
proves a hand-surface ceiling of 1974 and a generous modeled Mario peak of 2604
for arbitrary, never-A, and held-A input. Even the no-A case receives the full
630-unit rise; this is a conservative impossibility bound, not a no-A witness.
Those positive bounds remain useful route thresholds, but the new first-hand
barrier shows that their original `384 + 288` starting construction is not an
authentic first-hand trace inside the source-shaped model.
The two-hand barrier goes further: even granting all dynamic contact, the
conditional Y=1467 hand pose and resulting Y=1967 landing premise cannot be
supplied by this source-shaped relation. An event-by-event linked Clight proof
of the finite-episode premise remains open.

`proofs/RouteCertificate.v` adds a separate Mario/Area 2 result. A hand floor
does not trigger the modeled instant warp; a selected Area 3 warp floor enters
Area 2 with Mario's coordinates and velocity unchanged during the abstract
warp step. Original JP may subsequently apply a retained raw platform address
in the same frame, unless the ordinary coherent prestate carried `NULL`.
Adding the maximum
507-unit hand collision top and a modeled 630-unit triple-jump rise gives a
Mario peak ceiling of 2604. That is too low for the audited Y=2940 and higher
shortcut tiers or direct star collection. The combined abstract relations do,
however, admit a **conditional** landing at `(387,1967,-500)`, the point on the
Y=1967 platform horizontally closest to the star. The original game has not
been proved to realize the witness's starting hand pose; the new two-hand
barrier now refutes that pose inside the source-shaped height relation. The
trace remains a checked counterfactual about the older geometry-relaxed model.

`proofs/UpperRoute.v` establishes why a genuinely high hand would matter. A
counterfactual hand origin at Y=3627 supplies a modeled Y=4354 Area 2 entry;
its first quarter-step query truncates to Y=4351, selects the Y=4429 platform,
and permits a landing on the Y=4815 star platform.
The older coupled ceiling is Y=1467 and the stricter two-hand barrier ceiling
is Y=672, so neither model can supply that premise.
This eliminates the proposed high-Eyerok alternative inside the audited model;
it does not prove the conditional Y=1967 route authentic, globally fastest, or
lowest in A presses.

`proofs/Binary32Boundary.v` proves an independent representation bound:
finite binary32 hand positions cannot be unbounded as real heights. It also
proves the exact fixed point `Float32.add 2^31 100 = 2^31` and stagnation of
the recurrence when started there. These facts disprove literal unbounded
finite Y; they are independent of the kernel proof that makes the dangerous
seed unreachable in the audited model, and they do not prove that an authentic
hand reaches the fixed point. The same module proves
`Float32.to_int 2^31 = None` in CompCert. Any resulting Clight stuckness is
conditional on reaching that cast and is not a theorem about the IDO-compiled
MIPS ROM.

The source audit backs the rank-to-update order used by the model, but a
semantic Clight proof of that mapping, source-to-coupled-model refinement,
C-to-Rocq semantics, and original-game refinement are open. The project
separately proves that an idealized mathematical-integer recurrence
`Y + 100*n` is unbounded. That integer counterexample demonstrates why the
kernel invariant matters, but it is not a C execution theorem and does not
override the binary32 representation bound.

This is not yet a whole-program CompCert simulation of every original SM64
frame. `proofs/GlobalBoundary.v` is a generic lemma over an arbitrary run type
and arbitrary Z-valued height function; it does not itself mention Clight.
Coupling linked source transitions and binary32 observations to the
source-shaped kernel and small route-useful height relation remains open.

## Build

The intended toolchain is Coq 8.16.1 and CompCert 3.15 in the
`sm64-item-proof` opam switch. Activate that switch in a supported POSIX shell.

Run generation followed by the complete source/proof check:

```sh
opam exec --switch sm64-item-proof -- make generated
opam exec --switch sm64-item-proof -- bash pipeline/check.sh
```

The check diff-verifies both source audits, compiles every generated and
handwritten module, rejects proof-hole keywords, and prints the assumptions of
the Eyerok, route, scheduler, infinite-run, binary32, and audited-coupled
theorems.
