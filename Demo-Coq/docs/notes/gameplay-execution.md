# From source receipts to actual control-path executions

The full gameplay verdict remains **OPEN**. The continuation adds actual
CompCert executions to the capstone; it does not assume a no-desync invariant.
The generated program remains the pinned US/JP source translated with the
documented PowerPC/32-bit/big-endian CompCert configuration and N64 source
flags. Complete retail/hardware refinement remains separate.

## First title-screen demo start

`DemoTitleStartExecution.v` executes the entire generated
`run_level_id_or_demo` body on the first-demo path: input level zero, idle
controller, countdown 799, demo index zero, and a table count unequal to one.
It covers the initial pointer clear, idle tests, countdown increment/store,
the real loader call, next-index update, count comparison, buffer pointer
installation, header read, save/act stores and final return. US/JP bodies and
loader function definitions are checked identical.

The original title theorem retains an explicit execution premise for the
concrete generated `load_patchable_table`. The new composed theorem in
[loaded-title-execution.md](loaded-title-execution.md) discharges that premise
using [the actual loader execution](loader-execution.md). Its remaining call
premise is the exact generated `dma_read`, with explicit post-DMA metadata reads.
The original theorem takes the two prefix store equations and the index store
equation; the composition now constructs the index store too. Compatible
composite layouts, symbol resolutions, separation and writable cells remain
explicit premises. Both construct the actual whole-body execution. They do not establish boot
reachability, execute DMA, handle every later index/wrap case, or preserve
all demo bytes through arbitrary intervening gameplay.

## Interpreter and level selection

`DemoLevelSelectionExecution.v` executes the complete active-demo
`lvl_set_current_level` function call. It resets the checkpoint flag, reads
the real course table, sets the current level/course, reads and tests the
valid nonnull demo pointer, and returns zero through its actual early return.
The demo pointer is preserved under the declared touched-cell separation.

The same module executes the complete generated `level_cmd_call` body. It
reads the real command pointer, decodes the function address and signed
argument at their generated offsets, loads the script register, resolves the
indirect target to that actual level-selection function, executes it,
captures its zero result, reads the command size and advances the command
pointer. Real function-entry/return bridges and generated command layouts
are proved. A separate arithmetic lemma proves that the signed header byte
returned at startup survives the signed16 level store unchanged.

These are conditional executions from explicit command, global, pointer and
memory images. They do not prove that the main script interpreter reaches
this command from the demo header. Opcode dispatch, the earlier
`lvl_init_from_save_file`, other script commands, loading/clearing areas, and
all-frame preservation still need composition. Merely listing these proved
components in a conjunction does not discharge that composition.

## Warp and pause boundaries

See [the gameplay-boundary note](gameplay-boundary.md) for whole painting-null
execution, actual delayed-demo dispatch through `warp_special`, and actual
level-transition completion. The key correction is that `warp_special` does
not clear an existing warp destination. `play_mode_change_level` prioritizes
a nonzero destination type over its stored negative title-return code.
Establishing and preserving the zero warp type is therefore necessary.

The complete real pause query now rejects an active warp transition or a
nonzero delayed-warp operation, executing its actual internal dialog helper
and Mario-action reads; see [pause-exclusion.md](pause-exclusion.md). The normal-mode
Start-to-demo-exit ordering still requires composition. A missing
direct demo check in pause/painting code is not a reachable counterexample.
The two helpers in [start-warp-execution.md](start-warp-execution.md) execute
the initial timer decrement while preserving the pending operation and
`warp_area` with a zero destination. They do not execute Start scheduling or
frame the intervening object/HUD/camera calls.

The actual scheduling call is now proved in
[start-scheduling-execution.md](start-scheduling-execution.md), including its
real transition and RGB callees. The [actual Start prefix](normal-start-execution.md)
now selects it, retaining the exact per-version intro-text execution and
post-UI reads as premises. Framing the remaining interval remains open.

## Actual record playback and conditional dispatch

[playback-execution.md](playback-execution.md) executes the full input consumer
for every timer branch with the second logical controller absent. It proves
record advance, terminal behavior and exact byte-range frames. Initial and
all-frame bounds/provenance, and complete input-to-gameplay composition remain open.

[conditional-dispatch.md](conditional-dispatch.md) executes the actual equality
helper and a complete nonmatching script jump. The taken jump needs the
numeric/symbolic address bridge described in [address-refinement.md](address-refinement.md).
Demo's [numeric helper proof](numeric-address-execution.md) now executes
numeric inputs against its own generated unit. The [numeric image check](script-numeric-image.md)
authenticates finite script/callback bytes, but ordinary relocated
caller/dereference/callback simulation remains unproved. No vacuous full-game
result is inferred from the symbolic-pointer obstruction.

The corrected generated dispatch-table certificate is documented in
[script-dispatch.md](script-dispatch.md). Header 30 selects the Bowser 1 arena,
not BITDW course 17; the finite opcode inventory now checks that actual arena.

## Finite gameplay observations

The independent retail-ROM observer and its exact limits are recorded in
[gameplay-search.md](gameplay-search.md). The current idle/Start trial receipts
record active-demo level-update entries, authentic stream identities and
loaded-terrain checks: 12,866 updates, no mismatch or observer error.
They do not cover arbitrary game-over histories, all Start timings,
memory corruption paths or every reachable state, and are not a Coq theorem.
