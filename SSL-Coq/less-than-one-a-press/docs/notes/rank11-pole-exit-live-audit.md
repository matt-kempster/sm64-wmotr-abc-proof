# Rank 11: ordinary pole exits and the handstand-return timing edge

## Verdict

Rank 11 is still open, but two parts are now more concrete. The Coq proof
enumerates every direct action request in the real US/JP pole handlers,
executes their A tests from memory, and constructs the complete ordinary
freefall/soft-bonk initializer call in the selected linked program. That call
does not add height or speed. Separately, a staged JP retail test finds a
no-A release at Y **4070**, not the old normalized Y **4020**: press Z on the
last frame of the return from a handstand. Both tested releases fall back to
the Y-3200 pole base; neither supplies a counterexample. The timing result is
not a clean-entry proof or an exhaustive collision search.

## Exhaustive direct action split

The census reads the generated bodies, not a handwritten replacement for
their control flow. The table lists direct requests after excluding only the
exact adjacent `m->input` load and `INPUT_A_PRESSED` test. It does **not**
silently treat all other callees as harmless.

| Current handler | Direct requests without the A branch |
|---|---|
| Holding the pole | Soft bonk on Z; US also releases for low health. Otherwise climbing or starting the handstand. |
| Climbing | Return to holding; US also releases into soft bonk for low health. |
| Slow grab | Return to holding when the grab animation ends. |
| Fast grab | Return to holding when the grab animation ends. |
| Handstand transition | Enter the handstand, or return to holding with the reverse animation. |
| Stable handstand | Start the reverse transition. Z and B do not directly request a release here. |
| Shared pole-position helper | Idle on a floor, freefall below the pole bottom, soft bonk after a high wall collision, or idle after a near-floor collision. |

The unpruned census separately authenticates the three removed requests:
wall kick from holding, wall kick from climbing, and the top-of-pole jump.
The automatic-action common cancel also has a **water-plunge** call; it is
recorded separately, not assumed unreachable. Calls made after a release,
including `check_wall_kick` and the air-collision helpers, are not covered just
because the six pole handlers have been enumerated.

## What the new execution proof actually constructs

[`Area2Rank11BodyResolution.v`](../../proofs/Area2Rank11BodyResolution.v)
resolves the seven audited bodies and `set_mario_action_airborne` in the
selected US and JP global environments. It uses per-definition receipts and
the existing symbolic link transport, rather than evaluating a whole linked
program or assuming that a source name resolves to the expected function.

[`Area2Rank11LivePoleExit.v`](../../proofs/Area2Rank11LivePoleExit.v)
checks the relevant `MarioState` layout against the selected composite
environment. For each collected A-test fragment, the proof reads the actual
two-byte input field at offset 2. If the A-pressed bit (mask `0x0002`) is clear, an actual `Clight.step2`
sequence takes the skip branch with unchanged memory. Deriving that input
value from the controller history, reaching the fragment, and carrying the
same Mario receiver through preceding calls remain separate tasks.

[`Area2Rank11FallingInitializer.v`](../../proofs/Area2Rank11FallingInitializer.v)
starts at a real call to `set_mario_action_airborne`, binds its actual three
parameters, executes its generated body, and returns through the same call
continuation. For `ACT_SOFT_BONK` and `ACT_FREEFALL`, neither action matches a
jump-initialization switch case. From the explicitly checked normal entry
(`squishTimer = 0`, `quicksandDepth = 0`), the only writes are:

| Destination in the same MarioState block | Effect |
|---|---|
| `peakHeight`, bytes `[188,192)` | Copy the incoming Float32 Y position. |
| `flags`, bytes `[4,8)` | OR the incoming flags with `0x100`. |

The proof constructs both `Mem.store` results, frames disjoint loads, and
preserves all seven Float32 position/velocity/forward-speed cells at offsets
60, 64, 68, 72, 76, 80 and 84. No outside call is encountered in this executed
initializer branch. Importantly, **preserving incoming vertical speed is not
the same as deriving that it was zero**. This is also the airborne helper,
not the entire caller `set_mario_action` or the subsequent air movement.

The registered capstone is
`MainTheorem.current_rank11_pole_exit_boundary`. Its three components are the
source census, the memory-executed A tests, and the selected initializer-call
closure. It does not claim to inhabit
`LowerSameFrameCollisionPhaseCutRefinementObligation` or
`LowerTargetNoAWriterExclusions`.

## The newly observed 50-unit release

The reproducible diagnostic is
[`jp-rank11-pole-release`](../../instrumentation/jp-rank11-pole-release/README.md).
It authenticates the locally supplied JP ROM, uses the existing injected
Area-2 loader, and stages a zero-speed holding state on the real second pole
once. Its 23 additional staging writes are printed. Everything after that
staging uses controller input only; there is no action-table or code edit.
The inherited loader and staged pole contact mean this is **not a clean
lower-entrance route**.

Both runs climb into the handstand, wait 60 controller polls (including a Z
edge that does not release), and start the return animation. The final
return frame is neutralized in both runs to avoid adding a pole spin. The
only release-timing difference is whether Z is pressed on that final frame
or at the next holding-pole poll.

| Observation | Timed Z, mode 0 | Delayed Z, mode 1 |
|---|---:|---:|
| Maximum sampled handstand Y | 4194 | 4194 |
| Z-request timer | 610 | 611 |
| Action when Z is requested | Reverse transition, animation 12, frame 0 | Holding |
| Release Y | 4070 | 4020 |
| First soft-bonk sample: forward / vertical speed | -2 / -4 | -2 / -4 |
| Smallest sampled Z while Y is at least 3942 | 1257.74414 | 1268.21704 |
| A-press edges / held-A samples / controller-A samples | 0 / 0 / 0 | 0 / 0 / 0 |
| Observed outcome | Lands back on the Y-3200 base | Lands back on the Y-3200 base |

The source explains the timing: the reverse-transition handler returns to
holding when the animation frame is zero **before** it calls
`set_pole_position`. The repeated action dispatch can immediately enter
holding; a Z edge then releases before holding's ordinary position reset.
The previous animation-adjusted position survives. Without that Z edge,
holding restores the normal Y-4020 position. This source explanation and the
retail observation agree, but their complete state-and-step correspondence
has not yet been proved.

The timed run's last sampled position above the ring is
`(0,3958,1257.74414)`; its next is `(0,3926,1255.74414)`, already below the
Y-3942 ring. The south aperture edge is Z 1229. These observations explain
why this attempt fails; they are not a certificate for every intervening
collision quarter. The trace also shows that position advances can exceed
two horizontal units while `forwardVel` stays -2, so a live proof must include
the pole's push and collision phases, not just integrate forward speed.

## What is still required to close Rank 11

1. Execute a clean lower entry through the real pole grab and derive the
   receiver, used pole, initial velocity, and input values. Carry the same
   memory through every action redispatch, including the timed reverse exit.
2. Derive the animation translation and pole-push bounds for the reached
   states. The old Y-4020 normalized premise cannot simply be reused for the
   observed Y-4070 release. The sampled Y-4194 maximum is not yet a universal
   handstand bound.
3. Execute both pole-position wall queries, the ceiling and floor queries,
   every subsequent Float32 movement quarter, and the selected surface/owner
   chronology. Classify the first target-side crossing, including impulses,
   clips, moving supports, and same-position support changes.
4. Classify the reached transitive writers and give reached outside calls
   exact effects or protected-memory frames. The initializer's local frame
   does not cover animation loading, sound, geometry helpers, or other action
   and interaction calls. In particular, successful calls through animation
   loading cannot be granted arbitrary harmlessness from their names.

For the separate hypothetical mutation, the
[existing two-word payoff](hypothetical-pole-long-jump-mutation.md) is unchanged.
No MIPS/hardware execution or clean mutation installer was constructed here.
The required write addresses, timing, real table-cell selection, normal
long-jump setter, twenty clear collision quarters, and star continuation
still have to occur in one justified execution. The diagnostic's staging
writes are not a candidate installer.

## Verification

The active SSL build, no-hole guard, link-hygiene reproduction, new capstone
assumption audit, and repository proof-discipline audit passed. The new
capstone uses only the standard Coq/CompCert assumptions already accepted by
the project. Both retail diagnostic modes passed with zero A counters.
These checks establish the local results above, not the remaining live
first-crossing obligations.

[Back to Rank 11](../no-a-route-atlas.md#route-rank-11)
