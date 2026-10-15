# Actual normal-frame HUD timer block

`proofs/DemoNormalTimerExecution.v` selects the actual timer statement between
`check_instant_warp` and `area_update_objects` in generated
`play_mode_normal`. The selector is checked to be nonempty, and the selected
US and JP statements are checked equal. No game transition model or callee
execution premise is introduced.

`generated_normal_timer_executes_us_jp` executes that complete statement from
the actual `sTimerRunning` and `gHudDisplay.timer` reads. When the timer is
inactive, or its value fails the actual signed comparison with 17999, memory
is unchanged. Otherwise the only change is the concrete unsigned 16-bit
store of the incremented HUD timer at offset 12. The result has empty trace,
preserves every access permission, and preserves every memory load outside
the actual HUD block. It does not require that the running flag is zero in
every demo frame.

`generated_normal_timer_preserves_pending_start` consumes that exact store
frame for the real `sDelayedWarpOp` and `sDelayedWarpTimer` globals. If their
blocks are distinct from the HUD block, their scheduled values 22 and 20
survive this segment. `demo_normal_timer_boundary_claim` combines the
execution and its scheduling-field consumer;
`generated_normal_timer_boundary_us_jp` is the aggregate theorem.

The [pre-object caller interval](normal-preobjects-execution.md) consumes
this theorem together with the complete real warp calls, preserving the
pending Demo Next operation through that contiguous interval.

This closes one concrete segment of the interval after the verified
[Start prefix](normal-start-execution.md) and
[warp checks](instant-warp-execution.md). The subsequent actual
`area_update_objects`, `update_hud_values`, and camera calls still require
their own execution and memory frames before this can be composed with
the delayed-warp and pause results. Their preservation is not a premise of
this timer theorem, and is not established by it. The full gameplay verdict
remains open.

The staged leaf was compiled through the existing Ubuntu pipeline with Coq
8.16.1 and CompCert 3.15; the registered build and aggregate audit are part
of the project checkpoint.
