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

The transcript specifies post-gate Act 3 itineraries for both entrances, but
there is not yet an authenticated cut-starting replay or linked-Clight
realization of either itinerary.  There is also no clean-retail proof for
either conditional JP replay.  Therefore this work does not close either
Area-2 gate theorem and is not a complete zero-A counterexample.

The admission-free formal tranche is split by dependency weight:

- `proofs/Area2DownstreamGeometry.v` checks generated initializer/support
  geometry and the Act 3 standing-floor gap;
- `proofs/Area2DownstreamReceipts.v` checks lightweight exact mirrors of the
  two distinct conditional JP observations; and
- `proofs/Area2DownstreamContinuations.v` defines the versioned, concrete-cut
  suffix obligations and the linked-Clight refinement boundary.

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
| all five Act 6 trigger regions | yes, JP injected-boundary replay | pending | pending |
| Act 6 star region and new bit | yes, separate JP injected-boundary replay | pending | pending |
| Act 3 star region and new bit | transcript itineraries; no cut-starting replay | pending | pending |
