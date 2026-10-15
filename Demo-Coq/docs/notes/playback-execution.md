# Complete execution of a positive demo-input record

The full gameplay no-desync claim remains **OPEN**. The new playback theorem
executes the real input consumer for one precisely described controller and
record path; it does not supply initialization or all-frame reachability.

`proofs/DemoPlaybackExecution.v` proves
`generated_demo_playback_execution_us_jp`. The actual generated US and JP
`run_demo_inputs` function definitions are equal. For each, the proof constructs
a complete internal CompCert `eval_funcall`, including function entry, the
entire generated body, implicit void return and cleanup. No callee execution,
abstract frame step, or already-completed playback execution is assumed.

The covered state has the first logical controller pointing to the beginning
of its pad block and the second logical controller's `controllerData` null.
This includes the usual single controller in physical port zero, subject to
the unproved initialization bridge. The current demo pointer is a readable,
valid pointer into the supplied stream block. Its unsigned-byte timer is
nonzero, and the actual unsigned-byte decrement is also nonzero: this is the
positive countdown path that does not yet advance to the next record. The
physical button value, recorded stick bytes and recorded button mask are
arbitrary values returned by the real typed loads.

The whole generated execution performs six stores:

1. Masks the physical first-controller buttons with the actual valid mask.
2. Copies the recorded signed X byte into the pad.
3. Copies the recorded signed Y byte into the pad.
4. Decodes the record's high button nibble into bits 15-12 and its low nibble
   into bits 3-0, storing the resulting pad buttons.
5. ORs in the physical Start bit captured after the initial valid-button mask.
6. Decrements exactly the current record's timer byte.

The conclusions give the exact final stick/button values, decremented timer,
and unchanged current demo pointer. Physical Start handling is represented by
the exact integer mask/decode/OR expression executed by the generated code;
the theorem does not assume that physical movement buttons reach gameplay.

Its memory frame is stated at byte ranges rather than discarding an entire
stream block. Every readable load disjoint from pad bytes `[0,4)` and the one
current-record timer byte is unchanged. This includes other demo records and
the header when their bytes are outside that timer cell. A separately located
`gCurrLevelNum` cell is also preserved by this frame. These conclusions are
derived from the six actual stores, not supplied as a preservation premise.

The explicit premises resolve the two real globals, the controller/pad/record
composites and their actual field offsets, the controller size of 28 bytes,
record size of four bytes, the named typed reads, writable destination cells,
the valid current-record pointer and touched-block separation. The theorem
does not instantiate these in a complete linked retail environment or show
their joint boot reachability. The additional generated-layout witness and
buffer-bounds helper remain draft work outside the registered proof.

Still required are the timer-one record-advance case, the zero-timer end-demo
case, the second-controller clearing path, nonzero physical-pad offsets,
authentic DMA/input provenance and record bounds, and composition through the
remaining `read_controller_inputs` updates into an actual loaded gameplay
frame. In particular, this conditional playback call is not a whole-game
no-desync theorem or a reachable mismatch witness.

The semantic leaf was validated through the existing Ubuntu WSL pipeline,
using the `sm64-item-proof` switch, Coq 8.16.1 and CompCert 3.15, with an
isolated staging target/dependency file before promotion. The main report
records its capstone wiring and project-wide audit.
