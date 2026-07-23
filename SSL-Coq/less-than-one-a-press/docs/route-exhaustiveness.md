# Route exhaustiveness and alternative access

## Verdict

The two transcript routes have **not** been proved exhaustive for the retail
US and JP programs, and no stock-reachable no-A counterexample was found in
this investigation.

The work did settle three narrower questions:

1. The old `FirstTargetCutClassificationObligation` cannot follow from the
   endpoint/event certificate.  `endpoint_only_alignment_does_not_imply_cut_classification`
   gives a checked countermodel schema, and `ModelGapAudit.v` supplies explicit
   clean US/JP states and the missing one-step event witness.
2. “Above the second pole” is not a sound height cut.  The pole grip top is at
   world Y `4020`, but the upper-side floor ring is at Y `3942` and the upper
   Puzzle trigger is at Y `3913`.  The lower cut must instead be first
   collision-phase entry into an enumerated target-side support component
   around the pole hole.
3. A weak-model JP upper-entry bypass exists.  A retained pointer
   to an inactive, unreused exploded pyramid-top slot applies yaw delta
   `0x1800` and moves Mario from `(0,5500,256)` to approximately
   `(365.593,5500,-1096.803)`, outside the elevator shaft, without an A edge.
   The current raw-slot-only clean-state abstraction admits that seed.  Its
   raw payload and displacement mechanism are source-shaped; what remains
   unproved is the stock prehistory that retains the pointer at the upper
   warp.

The third item is an over-permissive-model counterexample, not yet a retail-ROM
counterexample.  It must not be excluded merely because no stock setup is
currently known.  One conditional setup is to trigger the upper warp while
standing on the spinning pyramid top as that object unloads.  The unresolved
ways to create that coincidence are moving/loading the upper warp onto the
top, or moving the top down to the upper warp.  The warp is normally created
on area entry, and object cloning may remove the clone's collision, but neither
fact is yet a proof that all such setups are impossible.

The Clight nonvacuity obligation no longer claims that every handwritten clean
state is source-reachable.  A retained JP pointer must be connected to its
actual source floor, the warp/top collision coincidence, allocation epoch,
unload/reuse trace, raw displacement fields, and first Area-2 memory before it
can be used in the evidence-bearing classifier.  That qualification validates
the conditional path; it does not define the path away or assume its
displacement is safe.

## Correct cuts

For the upper entrance, Mario spawns at `(0,5500,256)` inside the static shaft
aperture.  The aperture is approximately:

```text
x in [-101, 102]
z in [154, 358]
y in [5222, 5734]
```

The pyramid elevator is at `(0,4966,256)`.  Its collision has a floor at local
Y `0` and closed side walls up to local Y `256`.  The imported cutscene action
calls `launch_mario_until_land` with binary32 `0.0f`; that helper writes zero
forward velocity before `perform_air_step`.  Ordinary entry therefore falls
vertically into the cage.  JP retained-platform displacement is a distinct
pre-landing writer and cannot be hidden inside “ordinary fall.”

For the lower entrance, the second pole is based at `(0,3200,1331)`, has
modeled height `920`, and places Mario near Y `4020` at the top grip.  The
target-side floor opening is approximately:

```text
x in [-101, 102]
z in [1229, 1434]
support Y = 3942
```

The transcript’s ordinary A route supplies lateral clearance across the
roughly 101-unit opening.  The archived normalized soft-bonk model bounds
non-A lateral radius by `70 + 2*frame` and loses the required height before
reaching that clearance.  That is only a restricted subcase.  The formal cut
therefore uses finite static support IDs, dynamic object IDs, and Float32 open
cells rather than a predicate such as “Mario reached floor 3” or
`marioY > 4020`.

## Evidence-bearing classification

`FirstTargetRefinement.v` adds `ClightFrameEvidence`.  A classified frame now
carries:

- actual before/after Clight states;
- a prefix/segment/suffix decomposition of the CompCert trace;
- projected before/after `GameState` values;
- the exact indexed `CertifiedStep`; and
- a movement witness that starts on the source side and ends on the target
  side of a concrete `CollisionSupportCut`.

It also records that platform displacement writes `MarioState.pos`, while the
same-frame object collision phase can still sample `MarioObject.oPos`.  A
single abstract event slot cannot simultaneously stand for both the
displacement and the later target collision.

The writer inventory is total for `FrameEvent`, including a class missing from
the historical nine tags: ordinary Mario physics across static geometry.
That class has no honest legacy bypass tag, so the bridge to
`FirstTargetCutClassificationObligation` requires its unreachability
separately instead of silently dropping it.

Within the certified event semantics, the following proposed bypass causes are
proved impossible:

- direct displacement by the zero-offset Area-2/Area-3 instant warp;
- target relocation/substitution that violates target provenance;
- invalid trigger/controller lifecycle transitions;
- newly setting a target bit through coherent save reload; and
- a projected event with no indexed certified step, once a refinement
  certificate is supplied.

The remaining open route-writer classes are:

- ordinary Mario physics and static support transitions;
- platform displacement, especially JP retained/reused slots;
- object impulses and moving geometry;
- collision clips or tunneling;
- general parallel-universe/out-of-bounds coordinate aliasing; and
- normal area-reload or entry displacement.

The old bounded static quarter-step lemma rules out only one subcase of the
coordinate-alias class.

## JP stale pyramid-top candidate

The relevant retail formula in `platform_displacement.c` uses binary32
matrix operations and s16 angle-table indexing.  With:

```text
Mario M = (0, 5500, 256)
platform P.xz = (-2047, -1023)
oAngleVelYaw = 0x1800
oVelX = oVelZ = 0
pitch delta = roll delta = 0
```

the horizontal offset `(2047,1279)` is rotated by `33.75` degrees.  The
binary32 result is approximately:

```text
M' = (365.592773, 5500, -1096.8027)
```

The pointer dereference does not check active flags, behavior, collision data,
or floor ownership.  Vertical object velocity is irrelevant to this
horizontal rotation path.

This payload demonstrates why JP cannot simply be modeled as
`gMarioPlatform = NULL`.  It also does not prove stock reachability.  The
archived source-floor audit proves only that the pyramid top at its ordinary
position does not own either stock Area-1 pyramid warp, and its closed-world
seed census found no enumerated setup that installs this exact stale pointer
at node `0x14`.  It does not rule out moving/loading the upper warp onto the
top, moving the top to the warp, or a collision-preserving clone mechanism.
The concrete ROM replay is therefore a fixture-assisted mechanism test unless
a controller-only predecessor trace is later found.

## Emulator search boundary

The authenticated US and original-JP ROMs were checked with debugger input
plugins.  The search included:

- natural and injected JP Area-3-to-Area-2 platform-pointer probes;
- six US C-up speed fixtures;
- upper-entry schedules using idle, eight stick directions, B pulses,
  Z+B/slide-kick-shaped pulses, and already-held-A plus B schedules; and
- the stale pyramid-top payload above.

All tested schedules kept `A_BUTTON_PRESSED` false.  The clean upper-entry
search covered 41 schedules per version, 82 total.  The stale-payload search
covered 25 distinct boundary schedules and one pre-transition-only
predecessor.  The archived platform and C-up probes add eight fixture
executions.  The successful schedule was rerun while successively adding
object-lifecycle trace fields; those logging reruns are not counted as new
schedules.

No stock-reachable target region was found.  The boundary-fixture JP replay
did, however, find a model-level `BypassPlatformDisplacement`: slot-60 yaw
displacement followed by 60 frames of stick input and neutral input consumes
the upper hidden-star trigger at relative frame 78.  The trace has zero
`A_BUTTON_PRESSED` frames, zero `A_BUTTON_DOWN` frames, and changes the
hidden-star-controller count from zero to one.  It neither enters the Act 3
region nor spawns or collects the Act 6 star.  The probe does not directly read
save RAM, so this is not a newly-set-target-bit witness.

The matching pre-transition-only attempt fails: Area unload/load reuses slot
60, clears `gMarioPlatform`, and replaces the raw payload before the first
Area-2 input boundary.  Thus the successful replay refutes bypass
unreachability under the current over-permissive clean abstraction, but it is
not a controller-only retail trace.  Exact RAM fields, inputs, frame trace,
ROM hashes, and the reproducible probe are in
[`model-counterexample.md`](model-counterexample.md).

Level selection and warp setup also use fixture writes.  A finite schedule
search is negative evidence, not an exhaustive reachability theorem.

## Source-level exclusions

`SourceExhaustiveness.v` proves within its executable finite inventory that
the seven normal SSL star sources use indices `0` through `6`; only the static
pyramid source uses target index `2`, and only Pyramid Puzzle uses target
index `5`.  Klepto, the area-1 static star, Eyerok, red coins, and the
100-coin star therefore do not alias either target.

The same module proves coherent active/backup reload preservation and an
explicit first-target writer classification.  Connecting all compiled writers
to that inventory remains open.

`CollisionMeshFacts.v` checks the generated initializer lengths and exact
US/JP equality for the Area-2/Area-3 static arrays and route-relevant dynamic
collision arrays.  It does not yet parse those words into a proved surface
graph or show that a proposed `CollisionSupportCut` matches every triangle.

## What remains

To prove route exhaustiveness, the project still needs:

1. a linked-program frame projection that constructs `ClightFrameEvidence`;
2. a checked parser/refinement from the generated collision arrays to exact
   surface IDs, dynamic owners, and target-side components;
3. source-backed JP platform-capture and slot-reuse classification;
4. unreachability of each remaining movement class under no A edge; and
5. a proof that the ordinary elevator/pole A-labelled observations correspond
   to the actual action branches that cross those cuts.

Alternatively, a stock-reachable constructor must be recorded with its exact
clean initial RAM state, controller frames, object/global trace, and target
overlap or newly set bit.  Neither completion condition was met here, so the
ultimate impossibility theorem remains unproved.
