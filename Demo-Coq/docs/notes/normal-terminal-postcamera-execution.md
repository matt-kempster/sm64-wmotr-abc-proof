# Complete post-camera interval on the terminal countdown frame

`proofs/DemoNormalTerminalPostCameraExecution.v` starts at the actual
post-camera suffix of `play_mode_normal`, matching the start boundary of
the earlier nonterminal countdown theorem. Its claim is
`demo_normal_terminal_postcamera_execution_claim`, proved by
`generated_normal_terminal_postcamera_interval_executes_us_jp` for US and JP.

The interval executes the real painting-null call, its actual local
`WarpNode` allocation and free, the complete timer-1 Demo Next dispatcher
with every dialog-box type, and the actual normal caller's final decision
and zero return. No painting or delayed-call execution is supplied as a
premise. All internal callees, including dialog reset, transition reset,
camera trigger2 when selected and special warp, are already proved real
executions and are composed by this theorem.

`generated_painting_null_complete_byte_frame` strengthens the painting
bridge to `Mem.unchanged_on True`: every byte and permission of every
entry block is preserved across the real allocation/null body/free. The
proof accounts for the fresh local block explicitly. CompCert's memory
lemmas then transport each actual dialog-type, camera-pointer, operation,
timer, debug and demo-pointer read, every writable resource, weak stream
pointer validity and block validity. The theorem's input resources are all
at the original post-camera entry, rather than wished-for post-call values.

On exit, operation 22 remains scheduled, delayed timer is zero, play mode
is 4, special control is -2, transition timer is zero and its callback is
null. The caller returns zero for this frame. All entry-valid accesses and
blocks are preserved, and every load from an entry-valid block outside the
terminal routine's listed written globals retains its original value.
Painting's stronger byte frame is exported separately and also supports
`loadbytes` preservation.

The concrete painting table must still be null on entry. Debug zero,
active valid demo, operation 22/timer 1, concrete scalar/camera resources,
callee resolution, layouts and separations remain explicit. Earlier object,
HUD and camera effects must establish these entry conditions. Ordinary warp
destination type zero remains a separate requirement for subsequent
change-level completion. This theorem is one real caller interval, not an
induction over twenty gameplay frames or a boot/script/address simulation.
The full gameplay no-desync verdict remains open.

The complete staged source passed the established Ubuntu WSL pipeline with
Coq 8.16.1 and CompCert 3.15 and the existing memory cap. Promotion and
project-wide checks are recorded separately by the checkpoint.
