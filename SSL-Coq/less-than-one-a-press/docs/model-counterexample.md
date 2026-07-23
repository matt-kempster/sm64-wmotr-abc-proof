# JP stale-platform model counterexample

## Result

The current raw-slot-only clean-entry abstraction admits a
`BypassPlatformDisplacement` execution that reaches and consumes the upper
Pyramid Puzzle trigger without an A-button edge.  This is a counterexample to
the claim that every bypass constructor is unreachable from every state
currently admitted by that abstraction.

It is **not** a controller-only retail-game counterexample.  No target-star
collection interaction was observed.  Only one of the five Pyramid Puzzle
triggers is consumed, so the Act 6 star is not spawned.  The probe does not
directly read save RAM, so this report does not claim an observed newly-set
target bit.

## ROM and semantic boundary

The replay is hash-gated to the authentic original-JP ROM:

```text
MD5     85d61f5525af708c9f1e84dce6dc10e9
SHA256  9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317
```

The probe uses the retail JP program for the displacement, Mario physics,
collision, trigger deletion, object-slot reuse, and hidden-star-controller
update.  Two setup operations are outside a controller-only execution:

1. a debugger write requests the normal Area-2 upper-entry warp node `0x14`;
2. in the successful mode, the debugger writes the stale platform payload once
   at the first Area-2 input boundary.

After that boundary write there are no state writes.  Every subsequent change
comes from the retail program and the recorded controller input.

The modeled execution begins at that first Area-2 input boundary.  Menu input
and the warp setup precede it.

## Exact relevant initial RAM state

At global timer `361`, the upper entry has placed Mario at:

```text
gCurrLevelNum       = SSL (numeric value 8)
gCurrAreaIndex      = 2
Mario.pos           = (0.0f, 5500.0f, 256.0f)
Mario.action        = 0x00001932
Mario.input         = 0x0024
gMarioPlatform      = 0x80344f98
```

Neither `0x0024` nor any later recorded input contains
`INPUT_A_PRESSED = 0x0002` or `INPUT_A_DOWN = 0x0080`.

`gMarioPlatform` points to JP object-pool slot 60.  The one-time fixture leaves
the slot's activity, behavior, collision, and list links untouched and writes
these fields:

```text
slot address        = 0x80344f98
active flags        = 257
behavior            = 0x800eca2c
oPos                = (-2047.0f, 1778.071045f, -1023.0f)
oVel                = (0.0f, 5.0f, 0.0f)
oFaceAngle           = (0, 0, 0)
oAngleVel            = (0, 0x1800, 0)
```

The behavior and active flag belong to the slot naturally allocated in this
fixture-assisted Area-2 load; the raw transform fields represent the stale
exploded-pyramid-top payload admitted by the abstract model.  The platform
displacement code does not validate the activity flag, behavior, collision
owner, or allocation epoch before reading the transform fields.

The upper hidden trigger is initially active at object `0x80343c98`, behavior
`0x800ec21c`, position `(260,3913,-600)`.  The hidden-star controller is object
`0x8033ebd8`, position `(900,1400,2350)`, with action `0` and trigger counter
`0`.

This is an exact state for the fields used by the replay, not a claim that all
RAM bytes form a naturally reachable retail history.  In the Rocq
countermodel, the target bits are initially clear as required by
`CleanPyramidEntry`; the emulator replay establishes the compiled displacement
and collision mechanism but does not directly inspect those bits.

## Complete controller schedule

Relative frame `0` is the first Area-2 input boundary.

```text
frames 0 through 59: all buttons released, X_AXIS = 0, Y_AXIS = -127
frame 60 onward:    all buttons released, X_AXIS = 0, Y_AXIS = 0
```

The replay records 360 modeled frames.  Thus:

```text
A_BUTTON_PRESSED frames = 0
A_BUTTON_DOWN frames    = 0
controller A frames     = 0
```

## Key trace

| Relative frame | Controller | `MarioState.input` | Mario position | Upper trigger | Controller count |
|---:|---|---:|---|---|---:|
| 0 | no buttons, `(0,-127)` | `0x0024` | `(0,5500,256)` | active | 0 |
| 1 | no buttons, `(0,-127)` | `0x0005` | `(365.592773,5496,-1096.802734)` | active | 0 |
| 23 | no buttons, `(0,-127)` | `0x0001` | `(337,4441,-1075)` | active | 0 |
| 24 | no buttons, `(0,-127)` | `0x0001` | `(337,4429,-1075)` | active | 0 |
| 39 | no buttons, `(0,-127)` | `0x0001` | `(337,4429,-1075)` | active | 0 |
| 40 | no buttons, `(0,-127)` | `0x0001` | `(337,4429,-1075)` | active | 0 |
| 59 | no buttons, `(0,-127)` | `0x0001` | `(342.243042,4429,-771.412048)` | active | 0 |
| 60 | no buttons, neutral | `0x0001` | `(342.940918,4429,-748.670349)` | active | 0 |
| 76 | no buttons, neutral | `0x0024` | `(349.176636,4065,-545.477783)` | active | 0 |
| 77 | no buttons, neutral | `0x0024` | `(349.468140,4009,-535.979980)` | active | 0 |
| 78 | no buttons, neutral | `0x0020` | `(349.748901,3949,-526.831787)` | inactive | 1 |
| 79 | no buttons, neutral | `0x0020` | `(349.951416,3913,-520.233032)` | slot reused | 1 |

At frame 1, the JP platform update has applied the exact binary32 displacement.
Collision then pushes Mario from `(365.59,-1096.80)` to the nearby valid floor
at `(337,4429,-1075)`.  Normal no-A movement carries him off that floor and
through the upper trigger's collision region.  At frame 78 the original
trigger deactivates and the hidden-star-controller counter changes from `0`
to `1`.  The trigger slot is subsequently reused by the orange-number object,
so the controller counter is the durable consumption evidence.

No Act 3 interaction region was entered.  The Act 6 controller remained below
five triggers and did not spawn its star.  Thus neither normal target
collection path ran.  Because save RAM was not directly read, this is a target
region/bypass witness, not a newly-set-bit witness.

## Failed pre-transition-only predecessor

The second probe mode writes the same pointer and raw fields only while Area 1
is still loaded, then performs no Area-2 state write.  At the first Area-2
input boundary the retail unload/load path has produced:

```text
slot 60 active       = 257
slot 60 behavior     = 0x800eca2c
slot 60 oPos         = (-3638.0f, -0.0f, 1928.0f)
slot 60 oVel         = (-0.0f, 2.0f, 0.0f)
slot 60 oFaceAngle   = (0, -512, 0)
slot 60 oAngleVel    = (0, -512, 0)
gMarioPlatform       = NULL
```

No displacement or upper-trigger consumption occurs.  This falsifies that
specific proposed predecessor, not every possible retail predecessor.
Allocation history reused slot 60 and cleared the pointer.  A retail
counterexample would still require a controller-only source trace that
retains a suitable pointer and payload through the upper warp.

## Reproduction

With Mupen64Plus, its development headers, a debugger-capable core, a software
display, and an authentic original-JP ROM:

```sh
bash ./instrumentation/stale-top-trigger/run.sh /path/to/baserom.jp.z64
```

The script builds and runs both modes, hash-checks the ROM, checks the decisive
summary fields, and writes full 360-frame traces under:

```text
build/instrumentation/stale-top-trigger/
```

`instrumentation/stale-top-trigger/expected-trace.txt` is the compact checked
trace included in the repository.

## Proof consequence

The current `FirstTargetCutClassificationObligation` work cannot prove
`BypassPlatformDisplacement` unreachable for every currently admitted clean JP
state.  The clean-entry definition/refinement must add and prove allocation
epoch, source-floor ownership, area-transition, and first-Area-2-memory
conditions.  Those conditions may exclude this fixture only after a
source-to-Clight argument shows that every retail clean entry satisfies them.

This result neither proves nor disproves the ultimate retail theorem.  It
closes option 2 only at the over-permissive model boundary and leaves retail
reachability, route exhaustiveness, and the ultimate star-bit theorem open.
