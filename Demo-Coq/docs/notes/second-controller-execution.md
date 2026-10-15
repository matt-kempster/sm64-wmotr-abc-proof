# Connected second-controller processing during demo playback

`proofs/DemoSecondControllerExecution.v` executes the actual second
controller's `controllerData` load and non-null decision, its four input
copies and its complete neutral analog call. The checked aggregate is
`demo_second_controller_execution_claim`, proved by
`generated_second_connected_neutral_controller_executes_us_jp` for US and JP.

The caller temporary points to Controller-array offset 28. Its real data
field at offset 52 points to pad-array offset 6. The pad input reads are
at byte offsets 8 and 9 for the signed axes and offset 6 for the unsigned
buttons. All three are zero. The previous second-controller buttons may
be arbitrary: the real pressed-edge expression produces zero when current
buttons are zero. The theorem uses offset 6 in the same pad block whose first pad is at
offset 0. This is the selected physical-port configuration, not every
configuration: init_controllers scans four physical ports and maps the
first two connected ones, so other port choices require other pad offsets.

The copy prefix stores raw axes at Controller offsets 28 and 30 and button
fields at 46 and 44. The real `adjust_analog_stick` call then executes with
pointer `controllers+28`, including the actual eight-byte local allocation,
three analog stores at offsets 32, 36 and 40, and local free. It invokes the
named external `sqrtf` with the exact generated neutral square-sum argument.
The explicit pure math contract supplies its return value and the condition
that it does not exceed the cap. The axes remain zero and the magnitude
field contains that supplied return value; this local theorem does not
independently implement or validate the math external.

The proof returns the actual complete decision-subtree execution, all seven
resulting P2 fields and unchanged controller/index temporaries. A
`Mem.unchanged_on` byte frame protects everything outside Controller bytes
28 through 47 even across the real stack allocation/free. All initial valid
accesses and blocks remain valid. The existing typed-load and `loadbytes`
frame consumers therefore protect player one's record, both pads, stream
state and other globals when their actual ranges avoid that write interval.

Layout, concrete symbol/function resolutions, pointer validity, seven
writable fields and entry reads remain explicit. The
[complete connected caller](connected-second-controller-read.md) now composes
the loop setup, playback's actual P2 clears, this branch and player-three
copies for every timer. Hardware polling, other physical-port assignments,
reachable entry memory and whole-game preservation remain open. This local result
proves neither a reachable mismatch nor the global no-desync claim; the
full gameplay verdict remains open.

The complete staged module passed the established Ubuntu WSL pipeline with
Coq 8.16.1 and CompCert 3.15 and the existing memory cap. Source promotion
and project-wide checks are recorded separately by the checkpoint.
