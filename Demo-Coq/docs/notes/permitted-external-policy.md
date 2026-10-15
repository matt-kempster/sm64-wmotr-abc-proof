# Candidate external policy over actual execution histories

`DemoPermittedExternalSpec.v` is a partial specification of a proposed
caller-visible SDK boundary. It does not establish normal boot, successful SDK
execution, hardware refinement, coverage of all normal inputs, or no desync.
The first unchecked gameplay-specification item remains partial.

`demo_history_external_policy` carries one `demo_external_phase` through an
indexed `demo_execution_history`. Every history edge remains an actual
`Clight.step2` edge. At an external `Callstate`, the policy requires the exact
next `Returnstate`, the actual `Events.external_call`, and the corresponding
whitelisted effect. At all internal edges the phase is unchanged. `Sbuiltin`
is explicitly rejected, since it can invoke `external_call` without using an
external `Callstate`. Unknown externals, including omitted game functions,
have no permitted effect constructor. There is no arbitrary start predicate.

The phase-erased `demo_permitted_external_call` is only a projection. Applying
it independently to calls would lose controller/DMA sequencing; the full
history policy uses the phase-carrying relation instead.

## Whitelisted candidate effects

The signatures match the SDK/math declarations inspected in the generated
`game_init` and `memory` units. This is a finite direct-boundary inventory,
not a closed transitive game callgraph or a linked source environment.

| API | Proposed caller-visible effect |
| --- | --- |
| `osContInit` | Four status records, each with error 0/4/8/12; update type/status only on success; derive the four-bit controller mask from zero errors. A repeated initialized call preserves outputs. SI queue effects have a bounded footprint. |
| `osContStartReadData` | Successful submission establishes one pending four-pad sample and permits the fixed SI queue footprint. |
| `osRecvMesg` on SI | Successful blocking completion changes the pending sample to completed and writes the configured SI completion message. |
| `osContGetReadData` | Apply the completed sample to four six-byte pad records. Always write error byte 4; write button/x/y only when the error is zero. Byte 5 padding is untouched. |
| `osPiStartDma` | Successful normal-priority ROM read stores the actual descriptor fields and establishes one pending DMA request. Sizes are positive multiples of 16, at most 4096 bytes, matching the selected `dma_read` chunks. |
| `osRecvMesg` on DMA | Require that pending request, copy its exact ROM-image slice, then return its descriptor as the completion message and clear the pending request. |
| `osCreateMesgQueue` | Six explicit queue-header stores with the configured thread-tail pointer, buffer and capacity. |
| `osRecvMesg` on game/Gfx vblank | Bounded queue effects and the source-configured message value 1 for game vblank or 2 for Gfx completion. |
| `osEepromProbe` | SI queue footprint and US/JP result 0 or 1. |
| Cache maintenance and video-buffer submission | Preserve caller-visible memory in this proposed abstraction. Cache/coherence and private SDK state refinement remain open. |
| `sqrtf` | Preserve memory and propose `Float32.sqrt` as the result. Native rounding-mode, exceptions and NaN correspondence remain unproved. |

Pad values use the full representation ranges: unsigned 16-bit buttons, signed
8-bit axes, and error 0/4/8/12. The SDK header's comment about physical stick
range [-80,80] is not used as an established input restriction. Pinned
`lib/src/osContStartReadData.c:44` and `lib/src/osContInit.c:74` support the
error-path retention rules. These SDK functions have not yet been translated
or proved in this project.

The policy requires generated member-layout conditions for the pad, status,
queue and DMA descriptor types. Fixed queue resources require the exact game
global symbols and their one-message buffers; SI/DMA buffers come from pinned
`src/game/main.c`, which is not currently translated. Exact global arguments
are required for the controller arrays, mask, DMA descriptor and receive cell.
No claim is made that the currently selected linked environment instantiates
these resources.

The Gfx message differs from the game-vblank message: pinned
`src/game/game_init.c:250` configures `gGfxSPTask` with message 2 and its Gfx
queue, while `src/game/main.c:322` sends that task message on DP completion.
The game-vblank handler is configured with message 1 in `thread5_game_loop`.

## Deliberate remaining obligations

The ROM resource is an explicit list of bytes. No ROM bytes are included in
this module. Its authentication, retail offsets, DMA placement and relation
to the external Python authentication receipt remain unproved. DMA requests
require a numerical device address; this does not turn an unrefined symbolic
`Vptr` cast into such an address.

Copying DMA bytes at successful receive is a proposed completion boundary.
Native DMA can write before receive returns. A projection/linearization proof
must justify deferring visibility at these boundaries and account for
concurrent threads; no per-native-instruction simulation is claimed.

Queue effects are bounded memory footprints, not a proof of FIFO order,
blocking progress, interrupt delivery or thread wakeup. SDK private state is
represented by the phase; relating it to actual private SDK memory is open.
The successful submission/completion cases do not yet cover all failed SDK
returns, nonblocking receives, queue backpressure or boot-only scheduler APIs.
`bzero`, decompression, allocation, save routines, rendering, audio and other
omitted game/library functions are not silently permitted as environment calls.

EEPROM coverage is especially incomplete: `save_file_load_all` reaches
`osEepromLongRead`, and saving reaches `osEepromLongWrite` and their underlying
read/write APIs. They are absent from this whitelist. They also share the SI
device, queue/access protocol, PIF command channel and controller-command
tracking with controller operations. A phase containing independent pending
controller/DMA requests is not a proof that EEPROM and controller transactions
are serialized correctly. The shared SI/PIF state, SDK caches and command
dependencies need an actual SDK/scheduler refinement.
The RDRAM command buffers are distinct (`__osContPifRam` and
`__osEepPifRam`); the physical SI/PIF channel and `__osContLastCmd` tracking
are shared. EEPROM read/write update that command field in pinned
`lib/src/osEepromRead.c:68` and `lib/src/osEepromWrite.c:72`.

`EF_external` does not automatically emit a syscall. The candidate accepts
`E0` or a syscall with the exact API name, in addition to the actual external
relation. CompCert's external properties constrain trace length and require
deterministic output memory for a fixed input memory and fixed trace. A fresh
arbitrary multi-pad sample therefore cannot simply be postulated as an `E0`
buffer write. The pending/completed phase does not prove that every sample is
realizable by that external relation. PIF-memory/input-event refinement and
coverage witnesses are still necessary.

In particular, the history policy does not supply an initial state. Normal
retail assembly boot, OS thread creation, the missing ordinary `main`, address
representation and the game's actual loaded-scene/input-use observation all
remain separate obligations. A full theorem must establish a nonvacuous
normal-boot/gameplay witness and coverage of the intended input domain, rather
than deriving safety from a policy that admits no gameplay histories.

The checked history lemmas establish only: every admitted history edge is an
actual Clight edge; phase continuity on internal edges; the exact external
call/return condition; and explicit rejection of builtin invocations. They do
not discharge any SDK refinement or global gameplay invariant.
The aggregate `demo_external_history_policy_claim`, proved by
`checked_demo_external_history_policy`, combines exactly these structural
policy facts for capstone use.
