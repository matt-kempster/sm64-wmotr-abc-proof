# Area 2 downstream continuations

## Verdict

The checked source geometry now identifies a concrete static support triangle
under the Act 3 star and under each of the five Pyramid Puzzle triggers.  The
conditional JP instrumentation also supplies two useful, but distinct,
receipts:

- one replay overlaps all five trigger regions and spawns the Act 6 star but
  does **not** collect it; and
- a separately tuned replay from the same injected timer-131 boundary reaches
  the spawned Act 6 star, matches the project's source-shaped hitbox model,
  and changes the SSL save byte from `0x00` to `0x20` without an A edge.

A supplied published video now adds a continuous visual gameplay witness for
both lower-entrance targets.  Each of its two runs uses a common 95-coin and
100-coin-star setup, displays its sole A press at the upper second-pole jump,
and then visibly collects either Act 3 or Act 6 with no further displayed
press.  The horizontal Grindel sequence is downstream of the pole jump, not an
independent A-triggered mount.  The Act-6 run also visibly joins all five
puzzle events, spawn, and pickup.  This establishes that the downstream
gameplay pieces fit together and localizes the remaining gameplay obstacle to
the pole exit, but it is not an authenticated input receipt: no `.m64` is
available, the ROM region is unknown, and the on-screen counter is not raw
controller state.

The video/transcript route still lacks an authenticated cut-starting replay or
linked-Clight realization, and neither conditional JP replay has a clean-retail
prefix.  Therefore this work does not close either Area-2 gate theorem and is
not a complete zero-A counterexample.  See the [published lower-entrance video
audit](lower-entrance-downstream-video.md) for the artifact hash, timeline,
scope, and exact next obligations.

The admission-free formal tranche is split by dependency weight:

- `proofs/Area2DownstreamGeometry.v` checks generated initializer/support
  geometry and the Act 3 standing-floor gap;
- `proofs/Area2DownstreamReceipts.v` checks lightweight exact mirrors of the
  two distinct conditional JP observations; and
- `proofs/Area2DownstreamContinuations.v` defines the versioned, concrete-cut
  suffix obligations and the linked-Clight refinement boundary, and separately
  checks the finite transcription of the published video's marked press and
  post-pole-jump routes plus a one-edge button-history prefix.

## Exact source targets and support triangles

The target positions come from the pinned level/macro initializers.  Triangle
ordinals below count triangles in source order in the generated Area-2
collision initializer.  They are stable audit labels, not claims about live
`Surface *` addresses.

| Target | Target centre | Static floor point | Surface type | Global triangle | Vertex indices | Triangle vertices |
|---|---:|---:|---|---:|---|---|
| Act 3 star | `(500, 5050, -500)` | `(500, 4815, -500)` | `SURFACE_CAMERA_FREE_ROAM` (`102`) | `1401` | `(266,269,267)` | `(387,4815,-409)`, `(643,4815,-409)`, `(643,4815,-1125)` |
| upper trigger | `(260, 3913, -600)` | same | `SURFACE_DEFAULT` (`0`) | `669` | `(791,794,997)` | `(131,3913,-460)`, `(387,3913,-716)`, `(131,3913,-716)` |
| lower-west trigger | `(-260, 2940, -600)` | same | `SURFACE_DEFAULT` (`0`) | `659` | `(786,789,784)` | `(-384,2940,-460)`, `(-128,2940,-716)`, `(-384,2940,-716)` |
| lower-east trigger | `(260, 1967, -600)` | same | `SURFACE_DEFAULT` (`0`) | `636` | `(779,783,778)` | `(131,1967,-460)`, `(387,1967,-716)`, `(131,1967,-716)` |
| middle-west trigger | `(-1940, 1229, -600)` | same | `SURFACE_MOVING_QUICKSAND` (`39`) | `1378` | `(228,238,236)` | `(-1740,1229,-588)`, `(-2149,1229,-793)`, `(-2149,1229,2560)` |
| middle-north trigger | `(-1940, 1229, 2320)` | same | `SURFACE_MOVING_QUICKSAND` (`39`) | `1377` | `(228,236,226)` | `(-1740,1229,-588)`, `(-2149,1229,2560)`, `(-1740,1229,2150)` |

The Rocq checks calculate each record's word offset from its group header,
local ordinal, and record width; read its type/count and triangle indices from
both generated US and JP initializers; recover the listed vertices by indexing
the generated vertex arrays; derive the global ordinal; check upward triangle
orientation; and calculate that each listed X/Z centre lies in its triangle.
This is static initializer geometry only.  Live surface allocation,
transformed dynamic collision, list insertion, `find_floor` selection, and the
projection from a returned `Surface *` to these ordinals remain linked-semantics
work.

## Act 3 standing-floor gap

The static star centre is 235 units above its checked floor point.  Mario's
stock interaction hitbox is 160 units high, while the star's bottom is its
centre Y because its down offset is zero.  Thus a Mario sample standing at
`(500,4815,-500)` has hitbox top Y `4975`, leaving a **75-unit vertical gap**
to the star bottom at Y `5050`.

`act3_floor_standing_sample_does_not_overlap_star` evaluates the project's
binary32 hitbox model to `false`; it is not merely an integer sketch.  It
does not rule out a falling approach, retained vertical velocity, a moving
support, a rollout/interaction writer, or a glitch that supplies the missing
height.

## Transcript-specified Act 3 continuations

The [Rank-9 upper-platform follow-up](rank9-upper-star-dance.md) now connects
a granted airborne coin pickup to star spawning, ground-pound resumption,
first star contact, a rear-wall catch and landing in one local timing test.
It works when the coin is collected in the update that starts the ground
pound; all nine tested later startup timings leave too little rise. Coq
executes the actual star-home Y stores as well as the earlier floor-pair
commit and ledge-result decision, with separate Float32 timing checks.
The initial airborne pose and 99-coin history, live whole-frame execution,
dance completion and final Act-3 pickup remain unproved.

The transcript supplies two different post-gate methods; the failed experiment
below did not execute either one.

For an upper-entrance elevator escape, the transcript's route is:

1. make the 100th coin spawn the 100-coin star near the Act 3 platform;
2. store the upward part of a rollout with vertical-speed conservation;
3. reactivate that speed, ground-pound into, and collect the 100-coin star;
4. use the resulting star-dance ledge grab to reach the Act 3 platform; and
5. rollout into the Act 3 star.

For a lower route already past the second-pole gate, the transcript's route is:

1. lure the homing amp from the next floor and use its shock to ledge grab past
   the post-pole ledge;
2. traverse the ramp to the upper horizontal Grindel;
3. enter the one-unit misalignment on that Grindel;
4. rollout into the misalignment on the still-undescended upper-route elevator;
5. use that contact to start the elevator's descent;
6. move onto the top of the elevator;
7. cross to the Act 3 platform; and
8. rollout into the star.

`Area2DownstreamContinuations.v` records those ordered stage lists as
`upper_transcript_act3_stages` and `lower_transcript_act3_stages`.  The lists
are route specifications, not executions.  The suffix records carry an exact
copy of the relevant list, but no theorem yet connects each stage label to a
Clight program point.  The file separately defines
`UpperTranscriptAct3ContinuationObligation` and
`LowerTranscriptAct3ContinuationObligation`; neither has an inhabitant.  Exact
100-coin provenance/placement, vertical-speed and star-dance execution,
homing-amp routing and shock/ledge-grab behavior, misalignment cells,
Grindel/elevator owner identity and pose, quarter steps, and final star
collision remain source-to-Clight refinement work.

The published lower-entrance video materially strengthens this route's
gameplay evidence: it visibly performs a 100-coin-star ledge transition, jumps
from the upper second pole, follows moving-platform play toward Act 3, and
collects the target in one run.  It does not yet identify each moving object
or certify that every displayed motion is exactly one of the transcript's Amp,
Grindel, and elevator stages.  The footage therefore replaces “prose only”
with a visual route witness, not with an inhabitant of the formal continuation
obligation.

## Published lower-entrance visual receipt

The hash-identified 216.898-second video contains an Act-3 run followed by an
Act-6 run.  Both begin at the lower entrance with 95 coins, obtain and collect
the 100-coin star, and display `A Press #1` only when Mario jumps from the upper
second pole.  The recovered full transcript (attachment SHA-256
`B5418A6B8A40357EBC36F571EEE7A993F59288D906DCDB9FCC478AF543CBE73F`)
supplies this gate identity and the exact five-trial ordering: thin-pillar
mesh/teleporter, 100-coin-star dance, second-pole jump, homing-Amp ledge grab,
then Grindel/elevator misalignment.  After that displayed pole jump, the first
run collects Act 3 and the second run descends through the five puzzle regions,
visibly spawns Act 6, and collects it.  The full event table and video SHA-256
are recorded in the [video audit](lower-entrance-downstream-video.md), while
the transcript audit is in [transcript candidates](../../notes/transcript-candidates.md).

The formal file records this observation in a separate
`PublishedLowerEntranceVideoStage` vocabulary.  It proves by computation that
both complete transcriptions contain one marked pole-jump press, both
post-pole-jump transcriptions contain zero, the Act-6 trigger order matches the
conditional JP receipt, and the routes end at their respective target
collections.  The same file also checks a coherent button-only controller
prefix with one A edge, 33 further held-A samples, release, and A up for 32
later samples; the entire suffix after the first edge is proved to contain no
new A press.  This separation is intentional: visual stages and a button
prefix cannot inhabit
`CutDownstreamSuffix`, whose inputs, events, state transition, and no-A edge
property require linked execution evidence.

## Conditional one-A pole controller receipt

The hash-gated `instrumentation/jp-lower-one-a-route` fixture now tests the
corrected gate on an authentic JP ROM.  It stages the live Mario object at the
top of the live second pole, supplies exactly one A rising edge, holds that
same press for 34 controller polls, and releases it; held-A samples do not add
edges.  Timer 516 records pole `0x80350418`, Mario `0x80346e78`, position
`(0,4020,1331)`, and `ACT_TOP_OF_POLE`; timer 517 records
`ACT_TOP_OF_POLE_JUMP`, position approximately `(-21.434,4082,1307.712)`, and
forward speed `31.65`; and timer 551 records a Y=`3840` landing near the live
Grindel base at approximately `(-803.728,3840,456.996)`.  Final instrumentation
counts are `aPressedFrames=1`, `aDownFrames=34`, `controllerAFrames=34`, and
`injectedAFrames=34`.

This creates concrete controller inputs for the decisive one-A pole-to-base
segment and confirms at retail-machine level that the press belongs to the
pole exit.  It also exposes why a one-frame tap was misleading: immediate
release activates strengthened ascent gravity and lands on the Y=`3942` ring,
whereas holding the same edge produces the full arc.  The fixture does not
reconstruct the clean lower-entrance prefix or the full post-pole route, and
its first exact-corner attempt has not yet selected the Grindel as Mario's
platform.  That failure rejects only the tested analog schedule.  Exact
commands, scope, checked-in pole inputs, and output locations are in the
fixture's
[`README.md`](../../instrumentation/jp-lower-one-a-route/README.md).

## Five-trigger conditional JP receipt

The authenticated conditional replay records these first counter transitions:

| New counter | Timer | Mario sample | Intended source trigger |
|---:|---:|---:|---|
| 1 | 595 | approximately `(391.87,3949,-588.82)` | upper |
| 2 | 693 | approximately `(-254.56,2940,-602.70)` | lower west |
| 3 | 748 | approximately `(252.74,1967,-602.25)` | lower east |
| 4 | 869 | approximately `(-1807.37,1229,-600.14)` | middle west |
| 5 | 1111 | approximately `(-1909.46,1229,2198.83)` | middle north |

The lightweight receipt theorem pairs those raw binary32 samples with the
five source-order trigger identities and checks the recorded overlap flags
and ordering.  It deliberately does not reload and recompute the larger
`JPLifecycleTrace` dependency closure.  Connecting each recorded flag back to
the project's binary32 collision model remains a separate audit.  The replay
then observes an Act 6 star spawn at timer 1115.

It also records no star interaction, no star dance, and no Act 6 save-bit
transition.  This is direct evidence that "all five triggers were consumed"
is not itself the target theorem.  A downstream proof must additionally show
an overlap with the active Act 6 star and a clear-to-set transition of bit 5.

## Separate conditional Act 6 collection receipt

The separately tuned continuation from the same injected boundary records:

- all A counters equal to zero over timers 516 through 1343;
- an ordinary Z-then-B slide kick sample at timer 1342;
- Mario at `(925.564697265625,1241,2346.21044921875)`;
- the Act 6 star at `(900,1400,2350)` with its `80 x 50` hitbox;
- Mario hitbox top Y `1401`, one unit above the star bottom Y `1400`;
- `usedObj` equal to the observed star pointer; and
- the SSL save byte changing from `0x00` to `0x20` at timer 1343.

This supplies a conditional emulator receipt for an Act 6 target-region and
target-bit continuation.  It remains conditional because the timer-131
three-view/stale-platform state was injected by the harness.  The replay is
authenticated ROM evidence, not a CompCert small-step execution and not
evidence that clean retail gameplay can install that boundary.

## Transient Act 3 experiment

A discardable experiment tried direct steering from the authenticated
upper-trigger schedule toward the source-spawned upper horizontal Grindel and
then toward the Act 3 star.  It did not target the Grindel/elevator
misalignment itinerary above.  The run used an authentic hash-gated JP ROM for 1,800 frames
and forced A false throughout.  It observed:

- the horizontal Grindel at timer 516 in pool slot 134, pointer `0x8034ff58`,
  position `(-870,3840,105)`;
- the existing upper-trigger transition at timer 595;
- direct steering from the Y=3913 upper-trigger support toward the Grindel;
- a fall through the intervening open shaft to the Y=-101 floor;
- no Grindel ride, no Act 3 hitbox overlap, and no additional trigger count;
  and
- `aPressedFrames=0`, `aDownFrames=0`, and `controllerAFrames=0`.

The temporary instrumentation was removed after the run.  The exact command
shape was:

```sh
instrumentation/jp-full-route/run.sh \
  /path/to/authentic/baserom.jp.z64 \
  260.0f -600.0f 20 act3-grindel-transient 1800 0 0 0 900.0f
```

This rules out only that naïve direct-steering schedule.  It does not prove
that the Grindel route is impossible.  In particular, a support-respecting
waypoint schedule, moving-platform alignment, rollout, or another no-A
approach remains to be tested and then refined.

## Formal continuation boundary

`CutDownstreamCoverage` deliberately requires three version-indexed suffix
certificates for each concrete candidate cut:

1. a no-A continuation containing an Act 3 collection-region event;
2. one no-A continuation containing a valid consumption event for every one
   of the five exact source triggers; and
3. a no-A continuation that visits all five exact trigger regions, overlaps
   an active controller-origin Act 6 star, and actually newly collects Act 6.

Coverage requires both the Act 6 star overlap and the five trigger events on
that same suffix explicitly; item 2 cannot substitute for item 3.

The suffix records start at a target-side boundary and intentionally do not
contain a clean-entry prefix.  `CleanCutPrefix` and
`CleanComposedCutContinuation` are the separate optional layer that joins an
exact clean prefix to the suffix, including controller-history continuity.
The present module deliberately leaves composition consequences to the
existing clean-provenance results rather than repackaging their conjunctions.
This split avoids assuming the still-open gate crossing merely to state
downstream capability.

Each abstract suffix frame pairs one input sample with one certified event so
the two lists have the same order and length.  The handwritten event semantics
does not itself prove that the input caused that event.  Only the separate
linked-suffix certificate's exact input/event lists can place both projections
on one imported run, and the whole-program Clight refinement for that
certificate remains pending.  The abstract pairs must therefore not be read
as retail-aligned traces by themselves.

The named open obligations are separate for the upper elevator cut and the
lower support/closed-box cut.  Both still require:

- an inhabited cut-specific suffix record starting on the candidate target side;
- separately, when claiming a clean route, a coherent clean-entry prefix
  whose endpoint is exactly that suffix state;
- collision-phase execution for each downstream event;
- a projection from linked US or JP Clight memory and steps to that event
  trace; and
- clean-retail reachability of any stale-platform or other glitch state used
  by the continuation.

Accordingly, the present status is:

| Continuation | Conditional emulator evidence | Linked Clight | Clean retail |
|---|---|---|---|
| all five Act 6 trigger regions | JP injected-boundary replay; published one-A run visually joins all five | pending | pending |
| Act 6 star region and new bit | separate JP injected receipt for region/bit; published one-A run visually joins spawn and pickup | pending | pending |
| Act 3 star region and new bit | transcript plus published one-A visual collection; no input-authenticated cut replay | pending | pending |
