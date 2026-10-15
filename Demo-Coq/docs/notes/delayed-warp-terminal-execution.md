# Complete delayed Demo Next countdown and exit

`proofs/DemoDelayedWarpTerminalExecution.v` executes the complete generated
`initiate_delayed_warp` call in two cases. The aggregate
`demo_delayed_warp_execution_claim` is proved by
`generated_demo_delayed_warp_execution_us_jp` for US and JP.

`generated_bounded_demo_countdown_executes_us_jp` covers Demo Next operation
22 and every signed timer from 2 through 20. The real function decrements
that timer by one, performs no calls, retains operation 22 and preserves
all loads outside the timer block and all initial valid accesses. Only
small bounded integer arithmetic is checked by finite computation; no
whole generated program or large floating-point term is reduced.

`generated_terminal_delayed_warp_executes_us_jp` covers operation 22 with
timer 1, debug selection zero, a non-null valid demo pointer and dialog-box
type different from 1. It executes the whole real function, including the
countdown store, the actual `reset_dialog_render_state` call, that call's
actual `level_set_transition` callee, the real debug/demo guards and the
actual `warp_special` call. No callee execution or whole reset frame is a
premise. The reset's eight dialog stores use the exact generated values;
the type condition rejects the real `trigger_cutscene_dialog` branch.

The terminal call performs fourteen stores: one delayed-timer store, two
transition stores, eight dialog stores and three special-warp stores. It
establishes change-level play mode 4, special control code -2, delayed
timer zero, transition timer zero and a null transition callback, while
retaining operation 22. It preserves all initial valid accesses and blocks
and supplies an exact frame outside the listed written global blocks.
The reset helper separately preserves pointer validity and proves the two
transition-zero reads. Concrete symbol resolutions, scalar memory resources,
read guards and the required block separations are explicit.

This removes the former local entry boundary after dialog reset and debug
selection for the Demo Next terminal path. The outputs supply the mode
needed by the normal caller's exit decision and the zero timer/callback
needed by change-level completion. Ordinary warp destination type zero
remains a separate obligation: an already pending ordinary destination has
priority over the special control code in `play_mode_change_level`.

The result is not an induction over twenty gameplay frames. Reaching its
entry state, preservation through object/HUD/camera work and other frames,
the dialog zoom branch, other delayed operations, script control transfer,
loaded-level identity and boot/address refinement remain separate. The
full gameplay no-desync claim remains open.

The cleaned staged module passed the existing Ubuntu WSL pipeline using
Coq 8.16.1 and CompCert 3.15 with the established memory limit. The promoted
source is identical to that validated source. Whole-project validation is
recorded separately by the checkpoint.
