# Claim and evidence boundary

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
[pause-exclusion.md](notes/pause-exclusion.md). The whole title body retains
an execution premise for the named real loader. No theorem here supplies a
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
