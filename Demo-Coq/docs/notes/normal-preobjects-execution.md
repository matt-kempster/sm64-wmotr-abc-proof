# Normal frame: Start to the object-update boundary

`proofs/DemoNormalPreObjectsExecution.v` composes the contiguous actual
`play_mode_normal` interval immediately after the demo/Start prefix and
before `area_update_objects`: the `warp_area` call, the
`check_instant_warp` call, and the HUD timer statement. The selected caller
prefix is checked nonempty and identical in US and JP. The actual callee
body is selected separately for each version.

`generated_normal_preobjects_interval_executes` executes that complete
interval. Its premises are concrete symbol and callee resolution, layout,
readability and writability facts: the ordinary warp destination type is
zero; the level differs from castle level 6; the real floor and its type
are readable; and the real area's instant-warp table is null. There is no
assumed execution or frame for either warp call. The theorem uses their
already verified complete internal executions, then the
[actual HUD timer block](normal-timer-execution.md).

If the real delayed-operation and delayed-timer globals contain 22 and
20 on entry and their blocks differ from HUD, those exact values remain
at the object-update boundary. The result also preserves every initial
valid access and every load outside the HUD block. A running HUD timer
is allowed; its only possible write is the previously verified timer
increment.

This connects the local warp/timer pieces through their real caller. The
theorem starts after the Start prefix; it does not establish all its
entry premises from the scheduler's output. The subsequent object,
HUD-value and camera calls, the UI execution inside the Start prefix,
area-table lifecycle, and reachable concrete memory still need their
respective proofs. It supplies no generic preservation assumption for
those calls and proves no complete gameplay no-desync result.

The staged caller composition passed the existing Ubuntu pipeline target
with Coq 8.16.1 and CompCert 3.15. The registered aggregate checks are
recorded by the project checkpoint.
