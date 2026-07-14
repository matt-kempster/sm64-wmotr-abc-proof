# Goal recovery note

Last updated: 2026-07-14 (plain-English proof-boundary clarification).

## Objective

Build an isolated Rocq/Coq + CompCert Clight project that decides the claim:

> It is not possible to trigger a glitch and manipulate Eyerok's movements so
> that an Eyerok hand rises indefinitely above the floor triangles that toggle
> the Pyramid interior and Eyerok arena.

The intended proof must quantify over adversarial player position, attacks,
timing, and boss random choices. If the statement is false, replace the
impossibility target with a concrete action and movement trace.

## Proof route

1. Pin the US source revision and audit the Eyerok action handlers, object
   movement helper, paired SSL instant warps, and transition triangles.
2. Generate CompCert Clight for an executable C abstraction and the pinned
   Eyerok translation unit.
3. Prove selected generated-AST shape facts about source mechanisms that can
   assign Y, vertical velocity, or gravity.
4. Define a nondeterministic transition relation intended to over-approximate
   the original action choices and partial-update behavior, keeping that
   intended coverage as an explicit open obligation.
5. Prove a uniform Z-valued invariant, intended to represent absolute Y, and
   derive that no run of the handwritten Rocq vertical relation has unbounded
   height.
6. Keep the source-to-Rocq simulation boundary explicit; close it against
   generated Clight execution and binary32 arithmetic, or leave the global
   gameplay theorem conditional.

The source audit identified the critical fork for steps 3--5. If
`DOUBLE_POUND` is reached while grounded with gravity zero, its velocity-100
branch can preserve positive velocity and produce a very large rise. The Rocq
project proves only an idealized mathematical-integer `Y + 100*n` recurrence
is unbounded. Original hand position is binary32; repeated binary32 `+100`
eventually stops changing Y because of rounding. The intended reachability
proof still has to derive whether the seed is reachable from the original
hand/boss schedule, including dynamic collision and partial-update cases,
because a huge finite ascent could be enough for the route.

The executable C abstraction represents the proof split directly. Safe
impulses consume a finite ascent budget, while the grounded/gravity-zero
double-pound state enters an explicit runaway mode. The handwritten Rocq
relation separately proves preservation of a safe envelope. There is not yet a
semantic theorem connecting C-abstraction calls to that relation, and its
public C functions can be called in sequences that make the safety predicate
false. Every original-game scheduling case must still be mapped to the safe
side of the Rocq split.

The closed-world half is now machine checked. `SchedulerInvariant.v` excludes
the runaway seed from every scheduler-reachable state, `StateMachine.v` proves
one-step preservation of the ascent envelope, and `VerticalBound.v` lifts the
result to all finite prefixes and infinite runs. The local capstone is
`eyerok_no_unbounded_rise_certificate`. Its runaway theorem is over Rocq `Z`,
not authentic binary32 or the C abstraction's 32-bit `int`.

The remaining no-unbounded-rise bridge is narrower than the original search:
prove a Clight execution refinement from authentic object/boss frames to the
two formal transition systems. `GlobalBoundary.v` already proves that this
refinement implies a bound for an abstract Z-valued height observation. It does
not mention Clight or binary32 directly; a faithful instantiation must define
and justify that numeric observation.

An internal bridge is also open: prove that the executable C abstraction
implements `vertical_step`, or stop treating that C interface as a semantic
model and connect the original Clight program directly to the Rocq relations.
The abstract scheduler and vertical relation must also be coupled where their
properties are used together.

The route-level area question is a second boundary. An Area 3 to Area 2
transition is not representable in the current vertical relation because it
has no Mario, floor, or area state. This is not an impossibility result. The
pinned source changes area only when Mario's selected floor is the Area 3
instant-warp surface; Eyerok height alone does not trigger it.
After the hand-height refinement, a complete route analysis would separately
need to model Mario/hand contact, floor selection, horizontal alignment, the
zero-displacement area change, and whether the resulting finite Y is useful in
Area 2.

`Eyerok.md` now gives the intended senior-engineer explanation, concrete
finite-impulse and runaway examples, an explicit answer about the Area 2
transition, and separate lists of proved and unproved statements.

The recovery path has now been exercised with the required Ubuntu commands.
Generation is byte-reproducible, the source audit diff is clean, every Clight
and handwritten module compiles, the proof-hole scan is empty, and the four
public theorem assumption reports contain no project-defined assumptions.

## Repository constraints

- Work only in `SSL-Cog/eyerok-manipulation/`, except for the required project
  entry in `SSL-Cog/README.md`.
- Inspect but do not modify `SSL-Cog/ssl-pyramid-item-proof/`.
- Update `docs/goal.md`, `docs/claim.md`, and `docs/checklist.md` in every
  commit.
- Commit each coherent change.
- Do not push without explicit user approval.
