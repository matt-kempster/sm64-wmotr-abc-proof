# Negative quicksand plus an unreanchored action

## Verdict

This is a real conditional Graphics-gap mechanism, but its prerequisite late
landing state is unreachable from either legal clean boundary inside the
finite source-shaped no-edge/no-forgery kernel.  It is not a proved clean
zero-A route and it has not produced a target-star counterexample:

1. the checked source transition kernel cannot first acquire either
   long-jump action without an A edge or a forged-state event;
2. in the finite fresh-star lifecycle model, collision eligibility follows an
   unstopped Mario update, and the modeled post-timer-4 case preserves the
   attack by producing the timer-5 `-2.65f` payload; and
3. in the finite untransported-dialog model, sinks raise Graphics Y without
   moving the supplied raw Mario X/Z from the boundary near `(5760,4899.19)`
   to the fixed upper warp at `(-2048,-1024)`.

The three reachability possibilities now have different statuses:

| Possibility | Current result |
|---|---|
| A long-jump/landing prehistory with no A edge | Excluded in the finite source-shaped kernel.  The only recognized ordinary long-jump constructor is guarded by `INPUT_A_PRESSED`, and landing is produced only from long jump.  Linked Clight-step classification remains open. |
| A forged action, timer, descriptor, callback, or input | No concrete clean SSL writer has been found.  Whole-linked alias/OOB/external/indirect-call exclusion remains unproved. |
| Starting the modeled clean interval in the injected state | Excluded at the stated boundaries: the abstract pyramid contract fixes action `0x1932`; a separate concrete memory postcondition assumes/fixes timer zero and depth `+0.0f`.  The ordinary Area-1 entry memory postcondition separately fixes action `0x1924`, timer zero, and depth `+0.0f`. |

Retail exploitation work first needs linked-step classification, then either a
reachable forged installer or a failure of one of the named forge exclusions.
The star/dialog/PU analysis remains useful as a characterization of what that
payload would do, but it is not evidence that ordinary zero-A play can create
the payload.

Ordinary Parallel-Universe movement does not change this finite-kernel result.
Signed-16 collision aliasing can select remote surfaces and platform
displacement can change positions, but neither mechanism is an ordinary
constructor of Mario's action/timer or a writer of the landing descriptor.
A PU would become relevant to *creating* the payload only if it also enabled a
concrete aliased or out-of-bounds memory write into one of those control
cells; no such writer is currently known, and the compiled-memory exclusion
is still open.

The bounded forgery audit makes that residual more precise.  All nine landing
descriptors and `sInteractionHandlers` are writable globals, but the bilateral
generated programs contain no direct assignment to them.  Each descriptor
address appears only in the corresponding landing wrapper.  Corrupting only
the action timer is not enough for an ordinary four-frame landing: the
preincrement cancel returns before timer 4/5 can reach the body, so the frame
count must also be corrupted.  The landing function-pointer call remains
under `m->input & INPUT_A_PRESSED`; the other indirect MarioState call is the
writable interaction table.  In CompCert memory, a changed action load
requires a same-block byte-overlapping store.  Actual N64 flat-address OOB
behavior, pointer provenance, writable-global integrity, indexed held-object
render state, and unresolved external effects are still open.

A fresh star with compatible vertical placement, an older pre-positioned
tangible star, a forged long-jump state, live dialog platform transport, warp
relocation/substitution, collision aliasing, or an unclassified raw-coordinate
writer remains outside this reduction.

The strongest writer is more dangerous than the earlier `-2.65f` example.
`mario_execute_moving_action` updates quicksand from Mario's floor at the
start of the moving-action dispatch.  Later in the same action,
`common_landing_action` calls `perform_ground_step`, then tests Mario's new
floor and applies

```text
(4 - actionTimer) * 3.5f - 0.5f
```

to `quicksandDepth`.  If the first sample is ordinary floor and the ground
step crosses onto quicksand, the updater resets depth to `+0.0f` but the later
writer sees quicksand.  The exact binary32 candidate results are:

| Post-increment timer | Same-frame result |
|---:|---:|
| 4 | `-0.5f` |
| 5 | `-4.0f` |

The older `-2.650000095f` result remains valid when the pre-action updater
already sees quicksand and prepares `1.1f + 0.25f` before timer 5 subtracts
`4.0f`.  It is not the worst floor-transition result.

## Why long-jump landing is the stock late-timer candidate

`common_landing_cancels` increments `actionTimer` before comparing it with the
selected landing descriptor's frame count.  Eight ordinary landing
descriptors use four frames, so their bodies run only with timers 1 through 3.
The long-jump landing descriptor uses six frames, so its body can run with
timers 1 through 5.  The new bilateral census proves all nine generated
landing-descriptor frame counts: eight use four frames and only the long-jump
descriptor uses six.  It also checks the exact writable long-jump descriptor
payload, the two action dispatch sites, the airborne landing transition, and
the A-guarded indirect landing callback.  These are generated-AST facts, not
yet a proof that the writable descriptor retains that payload in every linked
retail state.

The generated constructor source shape and finite transition kernel guard the
ordinary `ACT_LONG_JUMP` transition with `INPUT_A_PRESSED`.  Therefore the
floor-transition arithmetic is not by itself a counterexample to the no-A
claim.  A clean zero-A counterexample still needs
one of:

- a reachable long-jump/long-jump-landing prehistory that does not contain an
  A edge;
- a forged action, timer, descriptor, or callback through an aliased or
  out-of-bounds write; or
- a proof that the modeled interval can legally start in this state despite
  the clean-entry contract.

`LongJumpProvenanceBoundary.v` proves the corresponding first-occurrence
theorem over a finite source transition kernel: starting with the stock entry
action, a trace with no A-edge event and no forged install cannot reach
`ACT_LONG_JUMP` or `ACT_LONG_JUMP_LAND`.  It classifies forgery escapes as
descriptor corruption, interaction/callback retargeting, MarioState aliasing,
out-of-bounds stores, external mutation, or an unclassified internal writer.
The linked whole-program step classification and exclusion of those causes
remain open.  The source census finds no explicit address-taking of the
sensitive scalar fields, but that alone does not close those escapes.

## The unreanchored action

`ACT_READING_AUTOMATIC_DIALOG` is a cutscene action.  It is not dispatched by
`mario_execute_automatic_action`, whose prefix resets `quicksandDepth` to zero.
The generated US and JP handlers for the reading action contain no recognized
direct depth write and no recognized direct State-to-Graphics position copy.
While a dialog is
open, the handler increments state 9 to 10, observes that the dialog remains
open, and restores state 9.  The finite scheduling model therefore permits an
arbitrarily long stall.

Every valid-floor Mario update still calls `sink_mario_in_quicksand` after
action dispatch.  That sink subtracts depth from Graphics Y.  A negative depth
therefore raises Graphics.  The finite model shows accumulation when the same
depth is supplied through a constructor/reanchor and later dialog frames.  It
does not prove that live Clight constructor/helper calls preserve that cell;
this is an explicit remaining frame obligation.

Exact CompCert binary32 checks now include both candidates:

- `-2.650000095f` reaches a zero-base endpoint of at least 960 after 363
  sinks; the earlier live-base witness reaches an integer gap of 1010 after
  381 sinks;
- exact single-frame `-4.0f` plus the integer scheduling model proves that 240
  four-unit sinks supply a 960-unit rise.  The corresponding 240-step
  binary32 recurrence from a live base remains a named obligation.

These are arithmetic sufficiency results, not reachable frame traces.

## Stock SSL Area-1 boundary candidate

The stock Area-1 collision mesh has a particularly relevant boundary.  The
default triangle `(120,473,125)` and shallow-moving-quicksand triangle
`(120,125,61)` meet along the horizontal edge from `(5248,0,4864)` to
`(6272,0,4864)`.  Static triangle evaluation gives:

| Sample | Candidate projected triangle | Plane Y |
|---|---|---:|
| `(5760,0,4856)` | default | `0` |
| `(5760,0,4900)` | shallow moving quicksand | about `-8.108108` |

The original samples are 44 units apart in Z, and the rational plane change is
well under the 100-unit leave-ground threshold.  The four retail ground
quarters have now been executed from injected late-long-jump fixtures in both
authenticated target ROMs.  Pre-timer-3 and pre-timer-4 fixtures, which enter
timer-4 and timer-5 bodies, produced the same geometry trace in US and JP:

| Quarter | Z | floor Y | floor | wall | ceiling |
|---:|---:|---:|---|---|---|
| 1 | `4867.0` | `-0.675691783` | static type 37 | null | null / `20000` |
| 2 | `4877.73096` | `-2.92787266` | static type 37 | null | null / `20000` |
| 3 | `4888.46191` | `-5.40540886` | static type 37 | null | null / `20000` |
| 4 | `4899.19287` | `-7.88282061` | static type 37 | null | null / `20000` |

Each run hit exactly four lower-wall, upper-wall, floor, ceiling, and normal
commit sites.  Every floor had flags zero and object owner null.  The exact
final bits are Z `0x4599198b` and Y `0xc0fc4011`.  This refutes the earlier
obligation's exact endpoint `4900`: after the first crossing, subsequent
quarters are scaled by the shallow-quicksand normal Y.  The instrumentation
establishes the conditional retail engine execution, not clean reachability
of the injected action/timer/velocity state.  Its Rocq trace certificate is a
transparent record of the authenticated observations, not an oracle linking
emulator execution to Clight semantics.

The matching retail symbol maps were recovered from a clean build at decomp
revision `36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`, whereas the formal project
is pinned to `9921382a68bb0c865e5e45eb594d9c64db59b1af`.  A read-only Git
comparison found no differences between those revisions in `mario.c`,
`mario_step.c`, `mario_actions_moving.c`, `surface_collision.c`, `math_util.c`,
`surface_load.c`, or the SSL Area-1 collision source.  This source-equivalence
receipt explains why the trace is relevant; it is still not a semantic
simulation theorem.  The probe separately hashes the authentic US and JP ROMs
before execution.

## Why the star/dialog handoff remains open

A star collision on the same pre-action collision pass would select the star
dance before moving dispatch, so it would prevent this frame from writing the
negative depth.  For an *older, already tangible* no-exit star, the candidate
scheduling shape is:

1. frame F performs the long-jump-landing boundary crossing and writes the
   negative depth;
2. frame F+1's object collision pass touches an already tangible no-exit star
   before any ordinary action dispatcher can clamp/reset the depth;
3. star dance preserves the scalar and eventually selects
   `ACT_READING_AUTOMATIC_DIALOG` after a star-count milestone;
4. the open dialog stalls while the sink accumulates Graphics Y.

The finite freshly spawned 100-coin-star lifecycle model uses a different
schedule, supported by generated object-list/behavior source-shape receipts:
the first post-clear collision pass has no hitbox, the modeled uninjected gap
frame runs, and only the later level-object update installs a hitbox for the
next collision pass.  The modeled behavior initially places home Y 250 units
above Mario and does not immediately install its hitbox.  In that finite
schedule, action 2 clears time stop, the following
collision pass still sees no hitbox, Mario receives one unstopped update, and
the later level-object update installs the hitbox for the next collision
pass.  That intervening update does **not** eliminate both landing cases.  A
post-timer-4 `-0.5f` state is clamped and incremented to `1.35f`, advances to
timer 5, and receives the `-4.0f` landing delta, ending at exact binary32
`-2.650000095f` (`0xc029999a`).  A post-timer-5 `-4.0f` state advances to timer
6 and exits before the landing body; the same action loop then reaches the
stationary updater and ends at positive `1.85f`.
The finite timing model therefore carries the first case into the star's first
eligible collision rather than eliminating that modeled route.  Linked branch
and lifecycle execution remain open.

The immediate successor of the prepared pre-timer-3 retail fixture has now
also been executed without another memory injection.  In both US and JP,
frame G performs four additional normal commits on static owner-null type-37
floors; every lower/upper wall and ceiling result is null, `gMarioPlatform`
remains null, and the live A-down/A-pressed fields and A poll counts remain
zero.  Its exact endpoint is:

| Field | Binary32 word | Value |
|---|---|---:|
| raw/Object Y | `0xc199271e` | `-19.1441002` |
| raw/Object Z | `0x459aaf5f` | `4949.92139` |
| Graphics Y | `0xc183f3eb` | `-16.4941006` |
| quicksand depth | `0xc029999a` | `-2.6500001` |

This authenticates the proposed timer-5 follow-up for the prepared fixture.
It does not execute the intervening star cutscene/time-stop lifecycle, prove
that the prepared long-jump state is clean-reachable, or connect the run to
linked CompCert memory.

The hand-modeled vertical overlap interval is now the principal known
fresh-star obstruction.  A separately supplied/model-composed star homed at
`spawnY + 250` does not remain exactly at home.  The finite source-order orbit
settles five units below it, at `spawnY + 245`, so the 160/50 hitboxes require
Mario raw Y in `[spawnY + 85, spawnY + 295]`; same-height Mario still cannot
overlap.  The star's first level-list update occurs after Mario's F endpoint
is copied to raw Object, so the prepared binary32 spawn Y is `0xc0fc4011`
(`-7.88282061`), the home Y is `0x43721dff` (about `242.1172`), and the
first-hitbox Y is `0x436d1dff` (about `237.1172`).  A local static-floor scan
found no suitable lower floor near the audited boundary.  The authenticated
successor-frame words sharpen that obstruction: under modeled 160/50 hitbox
fields and zero down offsets, its raw Mario top is more than 96 units below the
supplied first-hitbox Y, and even its higher Graphics top is below the star.
This is exact raw-word arithmetic over two separately supplied finite
artifacts, not a proof that a live star occupied that address or that the
retail overlap routine rejected it in the probed run.  The live hitbox/overlap
refinement, 77-step linked binary32/12k-gate refinement, dynamic
surfaces, coin placement, and transport provenance are not formally closed.
Thus the exact finite pairing is vertically separated under the modeled
hitbox fields, while both a freshly spawned star with a different compatible
Mario height gain and an older
already-tangible star remain explicit obligations rather than assumed objects.

A one-star milestone dialog is possible only when the pre-collection total is
`0`, `2`, `7`, `29`, `49`, or `69`.  Source review confirms that B can advance
the dialog without an A edge; the menu unit is not yet in the imported Clight
coverage.

## Why amplification still does not enter timer 131

`NegativeDepthTimer131Bridge.v` proves spatial separation inside its finite
untransported-dialog model.  The
idealized Z=4900 sample has squared horizontal distance `96058640` from the
fixed upper warp, versus a combined-hitbox squared threshold of only `34969`.
The retail endpoint correction to Z `4899.19287` is irrelevant to the stronger
fact: upper-warp contact requires X between `-2235` and `-1861`, while the
dialog trace retains X=5760.  In the finite untransported-dialog model, any
number of stalls can increase the vertical Graphics/Object gap while State
and raw Object X/Z remain at the supplied boundary sample.  Hence vertical
amplification alone cannot trigger the Area-1 upper warp.

The bilateral generated source-shape check also places
`mario_update_quicksand` before stationary action dispatch and finds the
ordinary idle/walking reanchor helpers.  On the checked stationary
shallow-moving-quicksand update, the exact arithmetic mirror maps both
negative candidates to positive `1.6f`; the moving updater's `.25f` case maps
them to positive `1.35f`.  These facts eliminate “close the
dialog and ordinarily walk to the warp” only after linked branch, pointer,
alias, and helper-frame refinement.  A platform can still move MarioState
during the dialog without the handler directly reanchoring Graphics; proving
or refuting a stock platform capable of the required X/Z transport is now the
most concrete surviving handoff.

## Reproducing the quarter-step receipt

With authenticated US and JP ROMs in the sibling `reference-sm64-decomp`
checkout and the documented emulator/debugger dependencies available, run
from the project root:

```sh
bash instrumentation/area1-long-jump-crossing/run.sh
bash instrumentation/area1-long-jump-next-frame/run.sh
```

The script verifies ROM hashes and the cross-revision source-equivalence
boundary, builds the project-local input/debug plugin, executes all four
version/timer fixtures in the pure interpreter, and fails unless every query,
commit, endpoint, depth, surface-owner, platform-pointer, and no-A-input field
matches the checked CSV receipts.  The second command replays the pre-timer-3
case and its uninjected immediate successor, then validates the second frame's
four quarter-steps and final words.  Runtime logs and binaries go under
`build/instrumentation/` and are not committed.

The runner is not a hermetic emulator toolchain: it expects compatible local
emulator, plugin, compiler, and cheat-database installations.  Exact CSV and
ROM-hash checks reject trace drift, while the clean-build map-to-PC derivation
recorded in `metadata.txt` remains a manual receipt rather than a rebuilt
proof artifact.

## Formal status

The new proof modules establish separate, deliberately scoped facts:

- `JPLongJumpLandingDepth.v` checks the exact binary32 split-floor results and
  the integer magnitude `240 * 4 = 960`.  Its 240-step binary32 recurrence and
  link to the actual Clight ground-step control flow are named pending
  obligations.
- `AutomaticDialogReanchoring.v` checks the bilateral generated handler,
  constructor, dispatcher, sink/copy, and reanchor source shapes, then proves
  the finite stalled-dialog accumulation model.
- `ActionDepthAliasCensus.v` checks a bilateral generated syntax boundary for
  direct writers, address-taking, indirect Mario-state calls, action resets,
  and the writable long-jump descriptor.  It does not prove semantic
  non-aliasing.
- `ZeroAQuicksandEntryBoundary.v` proves separate consequences of the abstract
  clean contract, concrete entry-memory postconditions, descriptor timing,
  bilateral 38-unit target-value/constructor census, and the finite
  no-edge/no-forgery source-kernel exclusion.  It does not connect those
  boundaries by linked execution, prove retail memory safety, or eliminate the
  seven forged-state causes.
- `NegativeDepthForgeryBoundary.v` checks the writable descriptors and
  interaction table, localizes their ordinary address/writer sites, proves
  timer-only forgery insufficient for a non-long landing, classifies the two
  indirect MarioState call sites, and proves the CompCert action-cell overlap
  requirement.  It does not prove compiled flat-memory/OOB safety.
- `Area1LongJumpQuicksandCrossing.v` records the static mesh boundary and its
  exact geometric subfacts.  `Area1LongJumpQuicksandRetailTrace.v` records the
  corrected four-quarter retail observation and refutes the old exact-Z
  endpoint.  `Area1LongJumpQuicksandNextFrameTrace.v` records the uninjected
  immediate successor and proves the prepared raw/Graphics arithmetic
  separation against separately supplied first-hitbox words.  A linked Clight
  execution/refinement, live star-memory connection, and clean provenance for
  the injected fixture remain pending.
- `LongJumpProvenanceBoundary.v` checks the bilateral long-jump source chain
  and proves no-edge/no-forgery exclusion in its source transition kernel.
  Whole-program linked step classification and forgery exclusion remain open.
- `NoExitStarDialogBridge.v` checks the bilateral star lifecycle/source shape
  and proves the fresh-star finite schedule, the exact split between the
  surviving post-timer-4 `-2.65f` case and the positive post-timer-5 case, the
  modeled home-Y interval, milestone arithmetic, and boundary/warp separation.
  Its live lifecycle/arithmetic refinement and star-placement closure remain
  open.
- `NegativeDepthTimer131Bridge.v` proves that its finite untransported-dialog
  model preserves the wrong X/Z sample, checks the ordinary idle/walking
  source shape, and checks the exact `1.6f` post-dialog sanitizer arithmetic.
  It does not prove the linked branch/helper execution and names the remaining
  linked transport alternatives.
- `InkTimer131CorruptionClosure.v` packages the route consequence: under the
  checked clean action/depth kernels, zero A edges and no forged action imply
  a nonnegative depth, so there is no negative dialog seed; even granting a
  negative seed and any finite number of untransported stalls still cannot
  overlap the fixed upper warp.  Thus a surviving construction needs both a
  kernel/forgery escape and a separate raw-X/Z transport (or warp/collision
  substitution), not merely more dialog frames.
- `DialogDepthMemoryFrame.v` proves with CompCert memory semantics that framed
  stores to the action/control prefix or distinct object-pool block preserve
  the exact depth word, and checks seven dialog-spine bodies are direct
  nonwriters.  Full statement execution, pointer/alias validity,
  preprocessing, and external frames remain open.

No theorem in these modules proves that a clean US or JP zero-A execution
installs the gap, reaches either target region, or collects either target star.

## Decisive remaining obligations

1. Refine the checked source action/depth kernels to every clean linked US/JP
   step and eliminate the seven forged-state cause classes.  This is now the
   prerequisite question; without such a forge, the negative payload is
   unreachable in the modeled zero-A execution.  This includes executing the
   `Controller.buttonPressed`-to-`INPUT_A_PRESSED` update and excluding a later
   forged input-bit writer.
2. Refine both authenticated four-quarter retail frames to linked Clight
   memory, including the exact injected prestate, successor chronology, and
   corrected binary32 endpoints.
3. Prove or refute a fresh 100-coin star whose vertical placement overlaps
   after the surviving timer-5 `-2.65f` write, or an *older*, already-tangible
   stock no-exit star at the required collision pass.
4. Execute the collision-to-star-dance-to-milestone-dialog path without an
   intervening depth reset and with a non-null floor on every sink frame.
5. Close whole-program pointer, alias, out-of-bounds, and external-call frames
   for Mario state, object/Graphics position, and the mutable landing
   descriptor.
6. Find or exclude the required raw-X/Z transport during the dialog (including
   active platform displacement), warp relocation/substitution, collision
   aliasing, and other post-copy writers before carrying the three-view state
   into timer 131 and the destination stale-platform trace.
