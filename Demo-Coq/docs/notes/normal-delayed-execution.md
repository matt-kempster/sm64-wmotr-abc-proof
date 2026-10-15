# Normal caller: bounded countdown and terminal Demo Next exit

`proofs/DemoNormalDelayedExecution.v` composes the generated delayed-warp
results with the actual `play_mode_normal` caller. Its aggregate is
`demo_normal_delayed_execution_claim`, proved by
`generated_normal_delayed_execution_us_jp` for US and JP.

`generated_normal_terminal_suffix_executes_us_jp` selects the complete real
suffix beginning at `initiate_delayed_warp`, immediately after the painting
call. It constructs that actual call using the full terminal theorem,
including the real dialog reset, transition and special-warp callees. The
resulting play mode 4 makes the caller bypass the normal warp, transition
and pause decisions and return zero. The proof establishes that control
flow from the generated body rather than assuming a terminal-call oracle.
It retains the terminal theorem's exact mode/control/timer/callback reads,
operation 22, outside-written-block frame and valid-access/block results.

`generated_normal_postcamera_countdown_interval_executes_us_jp` generalizes
the earlier post-camera theorem from timer 20 to every timer from 2 through
20. It executes the actual painting-null call, including its real local
allocation and free, the complete delayed countdown, the ordinary caller
choices, the full pause/dialog query and the final zero return. The timer
becomes one less and operation 22 remains scheduled. Every load from an
initially valid block outside the delayed-timer block is preserved. Its
explicit input resources include null painting table, ordinary destination
type zero, zero transition timer and the real pause-query reads.

The terminal statement begins after painting; the nonterminal statement
begins at the post-camera painting call. Their entry conditions still need
connection to the earlier object/HUD/camera interval and reachable memory.
The terminal theorem retains its dialog type different from 1 condition.
Neither result proves an induction over twenty frames, change-level script
execution, stream-to-loaded-level identity or boot/address refinement. The
full gameplay no-desync verdict remains open.

The complete staged aggregate passed the existing Ubuntu WSL pipeline
under Coq 8.16.1 and CompCert 3.15 with the established memory cap. Promotion
and project-wide validation are recorded separately by the checkpoint.
