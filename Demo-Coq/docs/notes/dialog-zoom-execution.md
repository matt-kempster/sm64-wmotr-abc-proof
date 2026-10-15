# Terminal demo exit with every dialog-box type

`proofs/DemoDialogZoomExecution.v` removes the earlier terminal theorem's
condition that dialog-box type differs from 1. Its aggregate
`demo_dialog_zoom_terminal_execution_claim` is proved by
`generated_dialog_zoom_terminal_execution_us_jp` for US and JP. It covers
both the complete terminal `initiate_delayed_warp` call and its actual
`play_mode_normal` suffix after painting.

The missing branch calls `trigger_cutscene_dialog(2)` in the real camera
unit. `generated_dialog_trigger_two_call_executes_us_jp` executes that
complete function: it initializes result zero, performs the actual unused
local's `gCamera` pointer-cell read, rejects trigger 1 and returns zero with
identical memory and empty trace. It does not execute a camera cutscene.
The corresponding call target and readable pointer cell are concrete entry
resources; no camera-body execution is assumed.

`generated_any_dialog_reset_call_us_jp` executes the entire real reset for
an arbitrary readable dialog-box type. It first calls the real
`level_set_transition(0,NULL)`, then either executes that real trigger2
callee or takes the nonzoom branch, and finally performs all eight generated
dialog stores. It proves zero transition timer/callback, the exact frame
outside its ten written global blocks, all valid accesses/blocks and pointer
validity. The replacement resources add actual camera symbol/read/callee
facts and the required disjointness from earlier transition stores.

`generated_terminal_any_dialog_warp_executes_us_jp` composes that reset into
the complete actual operation-22, timer-1 dispatcher with debug selection
zero and a non-null valid demo pointer. It then executes the actual
`warp_special(-2)` callee. The result retains operation 22, installs mode 4
and control -2, zeros both timers and the transition callback, and supplies
the same outside-written-block frame and access/block preservation as the
narrower theorem. `generated_normal_any_dialog_terminal_suffix_executes_us_jp`
then executes the actual normal caller's delayed call and mode decision,
returning zero without entering its pause branch.

Entry memory, layouts where needed by earlier caller stages, concrete
callee resolution, debug zero, active demo, operation/timer values and block
separation still require reachability and preservation proofs. The caller
statement begins after painting. Ordinary warp destination type zero remains
separate because transition completion prioritizes an ordinary destination.
There is no twenty-frame induction, script/address simulation or global
no-desync theorem here. The gameplay verdict remains open.

The complete aggregate passed the established Ubuntu WSL pipeline with
Coq 8.16.1 and CompCert 3.15 and the existing memory cap. Production-camera
namespace validation and project-wide checks are recorded by the checkpoint.
