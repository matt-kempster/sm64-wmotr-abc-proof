# Ordinary demo records reaching the controller button-copy boundary

The full gameplay no-desync claim remains **OPEN**.
`DemoConsumedInputExecution.v` proves
`generated_demo_consumed_record_start_boundary_us_jp` for ordinary records,
including records whose timer expires on this frame. Unlike the separately
proved complete connected-controller branch, this copy-boundary result
allows arbitrary recorded signed stick bytes. It stops before analog
adjustment and does not assume or call an analog/controller execution oracle.

The proof constructs execution of a sequence selected and unrolled from the
actual generated US/JP `read_controller_inputs` code: its real
`run_demo_inputs` call, the first iteration's actual index initialization,
loop guard, controller-pointer assignment and pad-pointer read, the actual
connected-controller guard, and the actual four-store copy prefix. The
callee is the complete real `run_demo_inputs` function, with exact symbol and
function resolution premises. All statement and expression nodes in this
boundary are selected from generated code.

The selected sequence is not itself the whole function's AST subtree. The
additional checked conclusion now connects it to the original caller:
when the executing environment equals `Clight.globalenv prog` for a supplied
program, the proof constructs a genuine `star step2` path from the actual
post-hardware-polling `read_controller_inputs` body through its original
first `Sloop` iteration and continuations to its actual
`adjust_analog_stick` call. It lands at that call with the same proved raw
input, button fields and memory. This uses CompCert's big-step/small-step
correspondence and the real sequence, loop and conditional transition rules;
it does not assume a loop reachability or controller-execution oracle.

This is a local actual-program-state path. It does not prove that boot or a
whole input-read call reaches the supplied post-polling entry state, that
the supplied program is the complete linked retail program, or that the
remaining analog call, second-controller iteration and player-three copy
preserve the fields until the later gameplay/Start boundary.

The initial state has the same first-pad-at-offset-zero and second-logical-
controller-null conditions as the complete playback consumer. The current
record has nonzero timer; its raw stick bytes and mask are supplied by actual
typed stream loads. Physical Start is set in the initially read pad buttons,
and the previous controller Start bit is clear. All other button bits,
record mask and signed stick bytes are arbitrary.

The conclusions pin down the consumed inputs: controller raw X/Y equal the
current record's actual bytes, `buttonDown` equals the real decoded record
buttons with physical Start preserved, and `buttonPressed` equals the actual
edge expression against previous `buttonDown`. The generated Start mask
comparison is false against zero and the END mask comparison is true against
zero. END clearing is derived from the real nibble decoder for every mask;
it is not a premise.

The final current demo pointer remains in the same stream block and has the
actual countdown/expiry offset. The timer cell retains the actual playback
decrement. The buffer's first four bytes are preserved when the current
record begins at offset four or later. The combined byte frame preserves
all loads avoiding the pad bytes, current timer byte, current-pointer global
cell, controller raw fields, and controller button fields. A separately
located current level cell is therefore covered.

The controller's writable cells after playback are derived, not assumed:
a CompCert semantic lemma proves that supported store-only statements
preserve permissions, then lifts that fact through actual internal function
entry and cleanup when there are no local stack variables. A finite check on
the real generated playback body discharges its no-call/store-only condition.
This covers the actual playback call used in this composition.

The explicit unresolved context includes real symbol/callee resolutions,
composite layouts, readable input/current/previous-button cells, writable
cells before the call, valid current record and touched-block separation.
Authentic DMA and controller initialization, the previous-frame invariant,
stream bounds from ROM data, normal reachability of the post-polling entry,
later analog/copy
preservation and the loaded gameplay observation boundary remain open.
The module was validated against the regenerated dependencies using the
established Ubuntu WSL pipeline (`sm64-item-proof`, Coq 8.16.1, CompCert 3.15).
