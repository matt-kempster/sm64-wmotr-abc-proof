# Controller processing at shifted physical-pad bases

`proofs/DemoShiftedControllerExecution.v` generalizes the pad-dependent input
copies while keeping the real logical Controller records at offsets 0 and
28. The aggregate is `demo_shifted_controller_execution_claim`, proved by
`generated_shifted_controller_execution_us_jp` for US and JP.

`generated_shifted_connected_arbitrary_controller_executes` executes the
actual first-controller connected branch for a pad pointer at `pads+base`,
where `0 <= base <= 18`. It reads buttons at `base` and signed axes at
`base+2` and `base+3`, performs the real raw/button stores and reuses the
already proved complete arbitrary-stick analog call at Controller offset 0.
Its exact raw/button/float outputs, controller/index temporary preservation,
all initial valid accesses and typed-load frame outside Controller bytes
0 through 19 match the previous fixed-pad theorem. The actual analog
allocation/free and named pure `sqrtf` contract remain explicit through
that callee theorem.

`generated_shifted_second_connected_neutral_controller_executes_us_jp`
executes the real second-controller data-pointer load and non-null guard,
its shifted-pad input copies and the complete neutral analog call with
Controller pointer at offset 28. Pad axes and buttons must be zero, while
previous P2 buttons may be arbitrary. The result has zero raw axes and
button fields, zero float axes and the magnitude supplied by the named
neutral-square-sum math contract, under its stated cap condition. It keeps
the controller/index temporaries, every initial valid access/block and a
`Mem.unchanged_on` byte frame outside Controller bytes 28 through 47.

The shifted address calculations reuse the mechanically bounded pointer
helpers from `DemoPhysicalPadPlaybackExecution.v`; no controller or analog
body is replaced by a hand-written transition. The prefix theorems execute
the same generated stores at the actual symbolic pad offsets. For a real
physical port, `base=6*port` and `0 <= port < 4` imply these bounds. The
writable/readable resource premises retain the required alignment.

This removes the fixed pad-0/pad-6 restriction from these local copy and
connected-branch results. The initialization scan must still establish the
actual port mapping, and full callers must compose playback, setup, both
iterations and player-three copies at those bases. Hardware polling,
reachable memory, record bounds, whole gameplay frames and loaded-level
identity remain separate. The gameplay no-desync verdict remains open.

The complete staged aggregate passed the existing Ubuntu WSL pipeline
using Coq 8.16.1, CompCert 3.15 and the established memory cap. The promoted
source is byte-identical to the validated source; canonical-path and
project-wide checks are recorded separately by the checkpoint.
