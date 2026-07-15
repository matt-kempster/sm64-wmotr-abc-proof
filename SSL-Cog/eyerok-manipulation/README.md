# Eyerok manipulation proof

This project studies the proposed Shifting Sand Land route in which an Eyerok
hand is manipulated into rising without bound above the instant-warp floor
triangles between the Pyramid interior and the boss arena. It follows the
Rocq/Coq + CompCert Clight structure used by the sibling SSL-Cog projects.

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
pinned US SM64 Eyerok, Mario, area, SSL script, and collision source
  -> reproducible source audit + CompCert clightgen
  -> generated Clight AST shape certificates
  -> executable source-shaped launch kernel under arbitrary A input
  -> audited arena/tunnel split + source-shaped two-hand barriers
  -> handwritten Eyerok, Mario/warp, and Area 2 transition systems
  -> hand-height invariant + route-threshold theorems
  -> relation-level and binary32 representation bounds
  -> conditional Y=1967 witness + counterfactual high-route witness
  -> original-game refinement (open)
```

Generated Clight files are never hand-edited.

## Current status

The pinned source-ingestion pipeline now generates Clight for the authentic
Eyerok translation unit, object motion, behavior dispatch, object-list order,
spawn/list insertion, floor queries, area change, Mario and airborne stepping,
platform displacement, interactions, and the SSL script. Deterministic audits
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

The A value is a ghost input because the Eyerok hand code does not read it. It
shows that changing only A cannot alter this hand-control invariant; it does
not model new press edges or construct a legal no-A Mario route.

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

`inputs/eyerok_model.c` makes a vertical abstraction executable. It
tracks surface-list rank, controlled positioning, static or earlier-hand
support, finite ascent budget, partial-update stuttering, deletion, and the
runaway seed as a distinct mode. Its Clight AST is generated alongside the
pinned source surface. No semantic theorem connects executions of this C
abstraction to the handwritten Rocq `vertical_step` relation. Its public API
can violate the Rocq launch precondition; its safety predicate reports such a
violation but does not prevent it.

## Current result

`proofs/EyerokManipulation.v` packages these independent closed-world facts:

- the generated model contains the envelope constants, while the critical
  authentic-source Clight shapes pin float-constant counts, the movement call,
  and relevant dynamic-surface/list call sites; the source audit pins the exact
  impulse, gravity, strict-ground, list-order, and collision-lifetime facts;
- every state reachable in the scheduler and the executable source-shaped
  kernel excludes the runaway seed, independent of Mario's A-button policy;
- the source-shaped first-hand barrier bounds its origin at absolute Y `-862`,
  prevents tunnel-floor selection, and bounds its open surface at `-355`;
- the source-shaped two-hand barrier bounds the second origin at `672`, its
  open surface at `1179`, and the generously modeled Mario peak at `1809`;
- the Mario-contact arithmetic proves the ride/filter, hitbox, bounce, and
  fresh-A-edge facts above, while leaving X/Z contact and action execution
  explicit;
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
Area 2 with Mario's coordinates and velocity unchanged. Adding the maximum
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
`sm64-item-proof` opam switch. From PowerShell, use the Ubuntu distribution
explicitly because the default WSL distribution is not usable:

```powershell
wsl.exe -d Ubuntu
```

Run generation followed by the complete source/proof check:

```sh
opam exec --switch sm64-item-proof -- make generated
opam exec --switch sm64-item-proof -- bash pipeline/check.sh
```

The check diff-verifies both source audits, compiles every generated and
handwritten module, rejects proof-hole keywords, and prints the assumptions of
the Eyerok, route, scheduler, infinite-run, binary32, and audited-coupled
theorems.
