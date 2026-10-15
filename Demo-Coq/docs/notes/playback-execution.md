# Complete execution of demo-input playback

The full gameplay no-desync claim remains **OPEN**. These playback theorems
execute the actual input consumer for a precisely described controller state.
They do not supply authentic initialization or whole-frame reachability.

`proofs/DemoPlaybackExecution.v` proves the positive countdown path that does
not yet advance the record. `proofs/DemoPlaybackAdvanceExecution.v` adds the
record-expiry and EOF cases, then proves
`generated_complete_playback_consumer_us_jp`. The generated US and JP
`run_demo_inputs` definitions are equal. For both versions the result
constructs a complete internal CompCert `eval_funcall`, including entry, the
entire generated body, implicit void return, and cleanup. No callee execution,
abstract frame step, or already-completed playback execution is assumed.

The common state has the first logical controller pointing to offset zero of
its pad block, and the second logical controller's `controllerData` null.
This includes the usual single controller in physical port zero, subject to
the unproved initialization bridge. The current demo pointer is a readable,
valid pointer into the supplied stream block. The physical buttons, timer,
recorded stick bytes and recorded button mask are arbitrary values returned
by actual typed loads. All timer values are covered:

- A nonzero timer whose unsigned-byte decrement remains nonzero executes
  six stores: mask physical buttons, copy signed X and Y, decode the record's
  button nibbles, OR in captured physical Start, and decrement the timer.
  The record pointer remains unchanged.
- A nonzero timer whose unsigned-byte decrement is zero executes the same
  six stores, then stores the current stream pointer plus one four-byte
  record in `gCurrDemoInput`. In particular, an actual timer of one reaches
  this case. The new pointer keeps the same CompCert stream block.
- A zero timer executes the EOF branch: after the initial physical button
  mask it clears both sticks and stores `END_DEMO` (128). It leaves the
  stream and current demo pointer unchanged. Physical Start is not retained
  by that EOF output.

The all-timer theorem gives the exact final pointer, timer, sticks, and
buttons as conditional expressions matching those branches. Physical Start
is represented by the exact mask/decode/OR expression executed by the code.
These conclusions do not assume that other physical movement buttons reach
gameplay.

Each branch derives a byte-range memory frame from its actual stores. The
common theorem preserves every load disjoint from pad bytes `[0,4)`, the
current record's one-byte timer cell, and the four-byte global current-pointer
cell. Its explicit additional conclusion preserves the buffer's first
four bytes when the current record starts at offset four or later. Other
records and a separately located `gCurrLevelNum` cell are covered by the
frame. The EOF branch separately has the stronger pad-only frame.

The pointer arithmetic theorem connects the actual conditional output
pointer to a supplied buffer bound: if its current offset is at least four,
the current and next four-byte records fit inside a supplied byte size, and
that size is no larger than `Ptrofs.max_unsigned`, the next record remains
inside that buffer and beyond its header without integer wrap. This is a
generic arithmetic condition; the authenticated ROM stream sizes and
terminal-record positions in `demo-data.json` are still outside Coq and are
not yet used to prove that condition from normal loading.

The explicit execution premises resolve the two real globals, the actual
controller/pad/record composites and field offsets, controller size 28,
record size four, the named typed reads, writable destination cells, the
valid current-record pointer, and touched-block separation. They are not
instantiated in a complete linked retail environment or proved jointly
reachable from boot. The common theorem supplies writable timer and pointer
cells and the input-record fields even in the EOF branch, which does not
need all of them. No generated composite-layout witness is yet included for
this playback layout.

Still required are the second-controller clearing path, nonzero physical
pad offsets, authentic DMA/input provenance and an inductive record-bound
invariant, and composition through the remaining `read_controller_inputs`
updates into actual loaded gameplay frames. The complete consumer theorem
under these explicit conditions is neither a whole-game no-desync theorem
nor a reachable mismatch witness.

Both semantic modules were validated through the existing Ubuntu WSL
pipeline, using the `sm64-item-proof` switch, Coq 8.16.1 and CompCert 3.15,
with isolated staging targets/dependency files before promotion. The main
report records capstone wiring and project-wide audits.
