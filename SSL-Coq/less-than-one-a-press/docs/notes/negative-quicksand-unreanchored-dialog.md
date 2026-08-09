# Negative quicksand plus an unreanchored action

## Verdict

This is a real conditional Graphics-gap mechanism, not a proved clean zero-A
retail route and not an eliminated possibility.

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
timers 1 through 5.  The new bilateral census proves that descriptor's initial
six-frame value and writable storage.  The statement that every other stock
landing descriptor exits before timers 4 and 5 is currently a source-review
result, not a complete reachable descriptor-to-handler theorem.

The ordinary source transition into `ACT_LONG_JUMP` is guarded by
`INPUT_A_PRESSED`.  Therefore the floor-transition arithmetic is not by itself
a counterexample to the no-A claim.  A clean zero-A counterexample still needs
one of:

- a reachable long-jump/long-jump-landing prehistory that does not contain an
  A edge;
- a forged action, timer, descriptor, or callback through an aliased or
  out-of-bounds write; or
- a proof that the modeled interval can legally start in this state despite
  the clean-entry contract.

The source census finds no explicit address-taking of the sensitive action,
timer, argument, or depth scalar fields.  That does not close whole-structure
aliases, out-of-bounds writes, external effects, or writable landing-descriptor
corruption.

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

The samples are 44 units apart in Z.  The rational plane change is well under
the 100-unit leave-ground threshold.  A separate conservative read-only scan
found no wall bounding box or ceiling over this small region, but that scan is
not a Rocq theorem.  The proved projection facts do not establish the engine's
surface-list selection.  This is evidence that the split is geometrically
plausible, not an executed `perform_ground_step` witness: exact binary32
velocity/yaw and all four quarter-step wall, floor, and ceiling queries remain
to be checked.

## Why the dialog handoff remains open

A star collision on the same pre-action collision pass would select the star
dance before moving dispatch, so it would prevent this frame from writing the
negative depth.  The viable scheduling shape is instead:

1. frame F performs the long-jump-landing boundary crossing and writes the
   negative depth;
2. frame F+1's object collision pass touches an already tangible no-exit star
   before any ordinary action dispatcher can clamp/reset the depth;
3. star dance preserves the scalar and eventually selects
   `ACT_READING_AUTOMATIC_DIALOG` after a star-count milestone;
4. the open dialog stalls while the sink accumulates Graphics Y.

The stock candidate is the 100-coin no-exit star.  Its behavior initially
places its home Y 250 units above Mario and only later makes it tangible.  No
stock trace currently places an already tangible instance at the boundary in
the required next-frame contact geometry.  Proving that this placement is
impossible would close the stock star/dialog bridge even though the floor
crossing remains plausible.

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
- `Area1LongJumpQuicksandCrossing.v` records the static mesh boundary and its
  exact geometric subfacts; real four-quarter-step execution remains pending.

No theorem in these modules proves that a clean US or JP zero-A execution
installs the gap, reaches either target region, or collects either target star.

## Decisive remaining obligations

1. Execute the clean Area-1 entry and prove no-A action/timer/descriptor
   provenance in linked memory.
2. Execute the four real ground quarter-steps across the identified boundary,
   including binary32 walls, floors, ceilings, and floor-pointer update.
3. Prove or refute an already-tangible stock no-exit star at the required F+1
   hitbox, with correct spawn and lifecycle provenance.
4. Execute the collision-to-star-dance-to-milestone-dialog path without an
   intervening depth reset and with a non-null floor on every sink frame.
5. Close whole-program pointer, alias, out-of-bounds, and external-call frames
   for Mario state, object/Graphics position, and the mutable landing
   descriptor.
6. Carry the resulting three-view binary32 state into the timer-131 surface
   selection and the linked destination-area stale-platform trace.
