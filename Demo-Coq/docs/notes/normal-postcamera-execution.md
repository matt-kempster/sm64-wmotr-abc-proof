# Actual normal-frame interval after camera processing

`DemoNormalPostCameraExecution.v` proves
`generated_normal_postcamera_interval_executes_us_jp`, with claim
`demo_normal_postcamera_execution_claim`. It composes the actual contiguous
`play_mode_normal` suffix after camera processing: the complete painting-warp
call, complete pending delayed-warp call, ordinary mode choices, complete
pause query with its actual dialog helper, and final zero return.

The painting call takes its null-table path. Its real local `WarpNode`
allocation and cleanup are executed; the proof preserves loads and valid
accesses in memory that existed before the call rather than asserting that
allocation/free leaves the memory record identical. The pending Demo Next
call decrements operation 22's timer from 20 to 19. Its exact store frame
transfers the concrete pause-query resources to the decision point. With
ordinary mode, ordinary warp destination and transition timer all zero, the
proved pause exclusion makes the actual caller leave the mode unchanged and
return zero. The combined interval has empty trace, preserves the pending
operation, and preserves every load in an entry-valid block other than the
delayed timer block.

Entry symbol resolutions, field layouts, null painting table, scheduled
operation/timer, zero mode/destination/transition timer, dialog/Mario/active
reads, write access and separation remain explicit. No painting, delayed-warp
or pause function execution is a premise. The generic decision helper also
executes the mode-4 exit choice, but the aggregate claim is the pending
post-camera interval above.

This joins actual caller statements on the gameplay path. It does not frame
the earlier object, HUD or camera calls, establish its entry conditions from
boot or scheduler execution, handle later countdown values or terminal
expiry, or establish a whole-game invariant. The full gameplay verdict
remains **OPEN**.
