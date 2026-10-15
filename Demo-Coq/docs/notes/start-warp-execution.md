# Two executed scheduler boundaries around a pending demo exit

The full gameplay claim remains **OPEN**. These results do not establish
the actual Start-handling prefix, all intervening frame calls, or a
normally reachable no-desync invariant.

`proofs/DemoStartWarpExecution.v` contributes
`generated_demo_start_warp_execution_us_jp`, with two complete internal
CompCert call executions for both generated US and JP code:

- With the actual `sDelayedWarpOp` cell holding Demo Next (22) and the
  actual `sDelayedWarpTimer` cell holding 20, the whole
  `f_initiate_delayed_warp` call decrements the timer to 19, preserves
  operation 22, and takes no dialog/debug/warp callee path. Every memory
  load outside the timer's global block is preserved. The proof supplies
  the real function entry, generated body execution, return and cleanup;
  the only store is the real timer decrement.
- With the actual `sWarpDest.type` byte zero, the whole `f_warp_area` call
  skips and preserves exactly the entire memory. The composite lookup,
  type-byte offset, symbol resolution and load are explicit premises.
  This closes the relevant `warp_area` branch only under that zero-type
  invariant. If it is nonzero, the actual routine can call
  `init_mario_after_warp`, which clears the delayed operation.

The first theorem starts with a scheduled Demo Next operation; it does
not claim to have executed the code that schedules it. The second starts
with no ordinary warp destination; it does not claim to establish that
invariant. These starting-memory facts are the remaining composition
obligations, not a hidden assertion that demo pausing or desync is
unreachable.

The actual `level_trigger_warp` scheduling function and its transition/RGB
callees are now executed in [the scheduling proof](start-scheduling-execution.md).
The [actual Start prefix](normal-start-execution.md) also selects that call
under explicit UI/guard premises. Connecting these results to the complete
pause exclusion theorem requires reachable instantiation of those premises.
The object update, HUD, camera, instant-warp and
painting calls between that prefix and the pause decision must preserve
the relevant operation/transition and destination invariants. The
generated functions and concrete call sites are known, but these memory
frames are not proved for the entire reached interval. In particular, a
generic assumption that every frame preserves the desired result has not
been introduced.

The module was compiled in the project's full pipeline build alongside
the registered capstone. The established `sm64-item-proof` environment
reported Coq 8.16.1 and CompCert 3.15. The capstone's final audit and
assumptions receipts are recorded in the main report.
