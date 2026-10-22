# Claim and evidence boundary

Research is stopped at the user's request. The original objective and full
scope remain recorded in [the stopping point](notes/stopping-point.md);
[the proven-results report](proven-results.md) gives the conditions of the
checked results. Stopping does not complete or disprove the requested claim.

## Requested claim

The question is whether an authentic demo's inputs can run as gameplay in a
level other than the level recorded in that demo's header. This differs from
Mario taking an unexpected path within the correct level. It also differs
from a transient pointer/current-level-number inequality while the title
screen is fading: input playback can already be active before the gameplay
level has been initialized.

The intended scope is unmodified US/JP retail configurations, normal starts
and controller inputs. The full claim needs a formal loaded-gameplay and
consumed-input observation boundary, along with a precise external-system
contract. It is **OPEN** in this project. No reachable desync counterexample
has been established.

The [October 22 setter-caller source audit](notes/level-setter-callers-source-audit.md)
finds no normal mismatched invocation. It traces the single call site's startup
header flow and distinguishes conditional ordinary-warp/debug re-entry routes.
It does not change the formal proof snapshot or the OPEN gameplay verdict.

The [intervening-call source audit](notes/demo-pause-intervening-calls-source-audit.md)
also finds no normal cancellation-to-pause route. An operation clear by warp
initialization starts a replacement fade; a later instant-area cancellation is
conditional on unestablished selected-demo scene/state resources. This is source
evidence, not a new gameplay or memory-preservation theorem.

The [primary specification status](notes/gameplay-observation-status.md)
records partial actual-read/history and input-origin formalization. The capstone
now consumes a conditional connection to a real generated camera read and
structural facts about a candidate external memory/event policy. Independently
loaded-scene provenance, complete read/producer coverage, permitted boot states,
SDK/hardware adequacy and an authentic gameplay witness remain open. The full
statement is not yet formalized at the required scope; the first checklist item
remains unchecked.

The raw scene probe now retains absent/invalid/unreadable scene results at
an actual input read. Source-owned AREA/terrain declarations and authenticated
native operand metadata are checked for all nine selected areas per version.
They do not establish runtime ownership. The actual scene-builder diagnostic
shows why a completed-load claim over the unrefined ordinary Clight pointer
representation could be vacuous. The explicit decoder view is not a next
Clight step or a source/native execution correspondence. See
[scene-address-boundary.md](notes/scene-address-boundary.md).

The [bounded scalar-read connection](notes/native-scalar-read-connection.md)
adds positive source/RAM reads and fetched retail LBU/LH steps in explicit
candidate numeric-expression/native-load projections. Its exact-site and
byte-range premises do not establish authentic image activation, whole-language
or hardware adequacy, or loaded ownership. Constructed local RAM witnesses
are distinguished from the still-missing normal-boot gameplay witness.

The mechanized object is the pinned source translated with `TARGET_N64=1`,
`NON_MATCHING=1` and `AVOID_UB=1` using the configured 32-bit, big-endian
PowerPC EABI CompCert target (`powerpc` / `ppc32`, as the generated `Info`
records show). A matching N64 MIPS retail-binary/address and hardware refinement is
not proved. “US/JP” identifies those translation configurations, not a claim
that an entire retail ROM execution has been verified.

## Local semantic result

`DemoStartExecution.v` selects the actual installation subtree and return
statement from generated `f_run_level_id_or_demo`. Its execution theorem
constructs `exec_stmt` for those statements: it does not assume that execution
already exists. The code reads `gDemoInputsBuf.bufTarget`, installs
`buffer + 4` in `gCurrDemoInput`, reads the buffer's first byte, sets save file
and act to one, and returns the sign-extended header byte. A generated-code
equality connects the US and JP suffixes.

Its explicit premises supply symbol resolutions, a compatible composite
environment (including `bufTarget` at byte 8 and four-byte `DemoInput`
records), readable pointer/header values, writable global cells, and the
separation needed for the intervening stores. The theorem does not prove
authentic DMA loading, successful allocation, the branch prefix, the demo
index invariant, a whole `eval_funcall`, a linked retail environment, or legal
reachability of its memory image. Its result is local to an explicitly
described starting memory.

The separation premises protect the loads and final pointer/save/act results;
they do not assert that the buffer is separate from the save/act cells. The
local theorem therefore does not preserve the demo bytes or handler after
return. The additional non-vacuity receipts separately exhibit satisfiable
memory-access premises and the generated composite layout. Their synthetic
memory/header example is not authentic initialization, nor an instantiated
complete linked environment with symbol resolutions and a reachable state.

## Finite generated-source results

The source capstone consumes these facts:

- `run_demo_inputs` has no syntactic reference to `gCurrLevelNum` in either
  generated version. It supplies no runtime level/header check.
- `initiate_painting_warp` has no syntactic reference to `gCurrDemoInput`.
  That is a reason to check area construction, not a demonstrated exploit.
- All nonempty global initializers in each of the seven demo-level script
  translation units parse at command boundaries and contain neither painting
  opcode `0x27` nor instant-warp opcode `0x28`. The JP Bowser 1 unit is included
  conservatively even though the JP demo table omits it. This check does not
  execute or transitively follow script references.
- The selected active-demo delayed-warp branch is exactly the generated
  test followed by `warp_special(-8)` or `warp_special(-2)`.
- Both interpreter call commands load the current register, pass it to the
  indirect callee and capture the returned result in that register.
- Direct-write and return censuses identify the `levelNum` assignments in
  the concrete level-initialization functions. Indirect stores and callee
  side effects are not framed by that census.

These results constrain real generated code. They do not prove that the
branches are reached with the required memory, that indirect targets resolve
correctly, or that other stores preserve the state.

## Additional local executions and corrected dispatch coverage

The capstone now consumes complete local executions of the first title-demo
body, active-demo `lvl_set_current_level`, `level_cmd_call`, null-table
`initiate_painting_warp`, zero-destination `play_mode_change_level`, and
`pressed_pause` with the real internal `get_dialog_id` query. The selected
delayed-demo branch executes the actual internal `warp_special` function.
The exact hypotheses and remaining composition are described in
[gameplay-execution.md](notes/gameplay-execution.md),
[gameplay-boundary.md](notes/gameplay-boundary.md) and
[pause-exclusion.md](notes/pause-exclusion.md). The original title theorem retains
its named loader premise; the composed loader/title theorem below reduces
that premise to the concrete DMA call. No theorem here supplies a
normal-boot reachability or whole-program store-preservation invariant.

`DemoScriptDispatchFacts.v` parses the actual generated dispatch table and
resolves each selected target to its exact generated EXECUTE initializer.
It checks headers 4, 5, 7, 12, 24, 27 and 30 against their level-entry symbols.
This corrects the earlier intended-domain error: `bitdw.bin` contains header
30 and selects `level_bowser_1_entry`; header 17 selects the separate BITDW
course. `SourceFacts.v` now checks the Bowser 1 script in place of BITDW.
This is a finite source mapping certificate, not an executed script route.

`warp_special` leaves `sWarpDest.type` unchanged. The transition consumer
returns a nonzero ordinary destination in preference to the stored negative
title code. Establishing and preserving a zero destination is therefore
required; proving only the -8/-2 branch is insufficient.

The retail experiments in [gameplay-search.md](notes/gameplay-search.md)
are bounded evidence outside Coq. They do not replace any universal gameplay
or hardware-refinement obligation.

The subsequent composed startup theorem in
[loaded-title-execution.md](notes/loaded-title-execution.md) now executes the
actual loader and uses its proved cache-store frame, replacing the whole
loader-call premise with the exact generated `dma_read` call and explicit
post-DMA reads. The original local title statement is retained with its
literal narrower boundary; no reachability premise was silently discharged.

The complete equality helper and a nonmatching `level_cmd_jump_if` body are
executed in [conditional-dispatch.md](notes/conditional-dispatch.md). The same
module selects the real first expression of `segmented_to_virtual` and proves
that its pointer-to-integer cast preserves a symbolic `Vptr`, while its shift
by 24 returns `None` in CompCert semantics. It supplies no assumed taken-jump
callee mapping from a symbolic relocation to an arbitrary target pointer.
The result identifies a model/refinement obstruction, not a retail mismatch
or a proof that all numerical-address executions get stuck. A complete
boot-to-gameplay claim needs a non-vacuous, justified address correspondence.

## Authenticated finite data check

`pipeline/check-demo-data.py` authenticates both ROMs against SHA-1 files
from the pinned source. It extracts metadata through the pinned asset and
demo-table manifests. All seven US and six JP selected streams have distinct
level headers, no earlier zero timer before the terminal record, and a DMA
size within the `0x800` demo buffer. WF's extra 368-byte DMA range is retained.
The receipt contains hashes and metadata only.

This Python check is separate from Coq. It does not prove the ROM-to-Clight
memory bridge, DMA correctness, actual execution duration, or a gameplay
invariant. Recorded frame totals count timers in the file, not a theorem
about the number of gameplay frames consumed after title transitions.

## What would decide the claim

A proof needs the concrete initialization, interpreter/dataflow and global
preservation obligations in [the checklist](checklist.md). A disproof needs
a normally reachable mismatched gameplay episode with input-stream identity
and loaded level established. Neither a forced emulator state nor an
arbitrary CompCert memory mismatch meets that standard.

The complete [playback consumer](notes/playback-execution.md) executes all
three actual timer cases with the second logical controller absent. It proves
exact outputs, pointer advance on expiry, terminal END_DEMO behavior, and
byte-range frames. Its no-wrap next-record bound remains conditional on the
supplied authentic buffer extent; initial and all-frame provenance remain open.
The [Start caller prefix](notes/normal-start-execution.md) selects the actual
proved scheduler under checked button/transition/operation reads. Its remaining
call premise is the actual per-version intro-text routine, with explicit
returned memory and post-UI reads. The [complete instant-warp check](notes/instant-warp-execution.md)
returns without writes for a null floor or null table under its stated reads.
The [pre-object caller interval](notes/normal-preobjects-execution.md) composes
the actual warp, instant-warp and timer statements, preserving the scheduled
operation through that interval without callee-execution premises. Its entry
reads still need connection to startup and the Start scheduler. The
[connected-controller branch](notes/controller-input-execution.md) executes
neutral-stick processing and exact button edges through the real analog
callee, under its named pure `sqrtf` contract; it is not the full input loop.
The [arbitrary-stick analog theorem](notes/arbitrary-analog-execution.md)
now executes that entire real analog callee for arbitrary axes, both cap
branches and actual allocation/free under the same named math contract.
The [actual controller-tail executions](notes/controller-copy-execution.md)
cover the disconnected second-controller branch and player-three copies
with exact byte frames; complete caller compositions are described below.
The [post-camera caller interval](notes/normal-postcamera-execution.md)
composes actual painting, pending countdown, complete pause query and return.
Neither result establishes the whole frame or boot reachability.

[Numeric helper execution](notes/numeric-address-execution.md) and
[authenticated numeric script images](notes/script-numeric-image.md) expose
the remaining representation obligation precisely. The external checker
authenticates complete matching ROMs, selected initializer words and three
native callback byte ranges. Coq checks numeric source representations and
header dispatch. None supplies a runtime dereference/callback simulation or
identifies an active overlay solely from a shared numerical entry address.
The [taken numeric jump](notes/numeric-dispatch-execution.md) now executes its
actual equality and address-helper callees and stores the exact numeric PC,
with its numeric target-cell read explicit. The actual next-opcode expression
cannot dereference that `Vint` in ordinary Clight. This sharpens the caller
boundary without asserting a full boot or overlay simulation.

The [current-level GET command](notes/current-level-get-execution.md) now
executes its complete real function call and exact register/pointer stores;
finite syntax checks tie it to the dispatch command and handler table.
The [complete area reset](notes/area-initialization.md) executes all eight
iterations and establishes null painting/instant pointers under explicit
entry memory conditions and a checked generated composite layout.
The [actual unit initial-memory theorem](notes/area-initial-memory.md)
constructs that unit's initialized memory and discharges all those entry
resources. Its only argument selects US or JP. It does not establish the
linked game environment or reachability from boot.

The [consumed-input connection](notes/consumed-input-execution.md) composes
ordinary playback, including expiry and arbitrary stick bytes, with the
actual controller-copy prefix and Start/END guard masks. It additionally
supplies an original-loop small-step path from the post-hardware-polling
body to the analog call under `ge = Clight.globalenv prog`. It does not
establish boot or post-polling-entry reachability or subsequent processing.
The [complete all-timer post-polling caller](notes/controller-read-execution.md)
now extends that path through both iterations, arbitrary-stick analog
processing and player-three copies, with exact outputs and stream/header
preservation for EOF, expiry and non-expiry. It allows arbitrary physical
and prior buttons; separate corollaries supply the real Start/EOF guards.
The disconnected second logical controller, named math contract and concrete
memory premises remain explicit in that theorem. The
[connected-P2 caller](notes/connected-second-controller-read.md) now executes
the same original complete path for every timer, including the actual
second-pad neutralization and connected-controller analog processing. It
consumes [complete connected-P2 playback](notes/second-controller-playback.md)
and the [actual second-controller branch](notes/second-controller-execution.md).
Physical pad offsets 0/6, two named pure math contracts and concrete entry
resources remain explicit. All other physical-port assignments, hardware-entry
reachability and all-frame provenance remain open.
The later [physical-pad caller](notes/physical-controller-read-execution.md)
generalizes that local path to arbitrary bounded pad bases, using
[shifted branches](notes/shifted-controller-execution.md) and
[physical-pad playback](notes/physical-pad-playback-execution.md), while
preserving the actual mapping pointers24/52 and entry-valid accesses.
Actual initialization and the global observation/history remain unproved.
The [complete delayed Demo Next calls](notes/delayed-warp-terminal-execution.md)
cover countdown values 2–20 and terminal expiry through every real callee,
under the stated debug/demo/dialog guards. They do not establish a sequence
of complete gameplay frames or eliminate the ordinary warp destination
condition.
The [all-dialog terminal extension](notes/dialog-zoom-execution.md) removes
the earlier dialogtype!=1 condition for both the complete terminal dispatcher
and normal caller after painting. It executes the actual camera trigger2
callee and replaces that condition with exact camera-cell/callee resources.
This does not frame the whole camera update or establish boot reachability.
The [full terminal post-camera interval](notes/normal-terminal-postcamera-execution.md)
also executes painting's real allocation/free and transports those resources
from the earlier entry. It is still one conditional caller interval.
The [normal caller composition](notes/normal-delayed-execution.md) consumes
those actual delayed-call proofs, including terminal exit after painting and
the full post-camera interval for all pending ticks 2–20. The
[next selected-source type boundary](notes/selected-link-type-boundary.md)
checks an anonymous Gfx pointer-type mismatch and matching definitions/layouts;
it does not establish a type-renaming simulation or a wider link.

The [private-name correction](notes/private-global-linkage.md) is now in the
generation pipeline. It preserves public/non-global and existing string
names and scopes every private global. Selected official AST and Clight
links succeed. The unmodified incomplete/complete public array pair still
fails strict type equality. A [proved declaration normalization](notes/extern-array-completion.md)
now derives empty public declarations from actual initialized array
definitions, preserves each unit's complete initial memory and every
ordinary Clight step, and establishes official nine-unit Clight links for
both versions. Production generated sources remain unchanged. Whole-game
linking and active-image simulation remain open. The official Clight link construction
uses CompCert's existing proof-irrelevance foundation, not a project axiom.
