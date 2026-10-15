# Actual controller fields after demo-pad consumption

The full gameplay claim remains **OPEN**. `DemoControllerInputExecution.v`
proves execution of the actual connected-controller branch selected from
US/JP `read_controller_inputs`. This is not a complete call of that outer
function: its polling prefix, loop control, second-controller case and
player-three copy suffix remain outside this result.

The four-store copy prefix is proved for arbitrary typed pad stick bytes,
pad buttons and previous controller button state. It copies signed pad X/Y
into the controller's signed 16-bit raw fields, computes
`buttonPressed = zero_ext16(buttons & (buttons XOR previous_buttonDown))`,
and sets `buttonDown` to the current pad buttons. The theorem constructs
these actual generated statements and frames all other memory.

The composed branch result, `generated_demo_controller_input_execution_us_jp`,
currently requires both pad stick bytes to be zero. Buttons and previous
button state remain arbitrary. It executes the real `adjust_analog_stick`
callee, including its eight-byte filler stack allocation, entire generated
body, void return and stack free. No controller or analog execution oracle
is assumed. This neutral case applies to EOF's cleared stick output, and to
ordinary input records when their recorded stick bytes are neutral.

The only external execution contract is for the actual generated `sqrtf`
external: its exact floating expression `0*0 + 0*0` returns the supplied
single-precision magnitude with empty trace and unchanged memory. The branch
also requires the actual comparison of that magnitude against 64 to be
false. This is an explicit named pure math-call boundary; neither that
external contract nor an N64 math/hardware refinement has been proved here.
The ordinary square-root result zero satisfies the intended comparison,
but this theorem does not derive the external contract from a math model.

The final controller has zero raw X/Y and analog X/Y, the supplied magnitude,
the exact current `buttonDown` and edge-derived `buttonPressed`. In
particular, a held Start button and a newly pressed Start button are not
conflated. The additional checked Start consumer proves that ordinary demo
output with physical Start set and the previous controller Start clear
has its `buttonPressed` Start bit set and END bit clear, for every recorded
button mask. It derives END clearing from the actual shifted-nibble decode
and its nonoverlapping low nibble; no END-clear assumption is supplied.
The proof also translates these bit results into the actual integer mask
guards: `Int.eq (buttonPressed & 4096) 0 = false` and
`Int.eq (buttonPressed & 128) 0 = true`.
The memory frame preserves every load in an existing block that
is disjoint from this controller's bytes `[0,20)`. It therefore preserves a
separately located demo header, current demo pointer and current level cell.
The result includes the actual internal callee and its generated field
accesses; it does not frame arbitrary later gameplay calls.

The explicit premises give the generated composite field layout, actual
callee symbol/function resolutions, initial controller temp, typed pad and
previous-button loads, writable controller cells, and controller/pad
separation. A complete linked-environment and boot-reachability witness for
these premises remains open. A generated layout witness has not yet been
included in this module.

Remaining work includes arbitrary nonzero-stick analog paths, the complete
outer input-read call, controller initialization/provenance, and composition
with playback and the actual gameplay/Start scheduling boundary. The module
was checked with the established Demo-Coq Ubuntu WSL pipeline using
`sm64-item-proof`, Coq 8.16.1 and CompCert 3.15 before promotion.
