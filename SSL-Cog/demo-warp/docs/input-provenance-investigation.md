# Input/provenance investigation

## Audit verdict

The previous conclusion mixed a sound caution with an unsupported proof claim.
It was correct that the project had not ruled out corruption elsewhere in the
game. It was incorrect to say that
`normal_controller_path_preserves_no_alias_boundary` proved preservation through
the controller/demo path. That proposition was only the conjunction of:

1. a generated-AST census of selected syntactic assignments/calls; and
2. the existing initialization arithmetic/static certificate.

Neither conjunct mentions Clight execution states or before/after memories.
The theorem has therefore been renamed
`generated_controller_boundary_and_normal_initialization`.

## What the source census does establish

At pinned revision `36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`:

- `gCurrDemoInput` is initialized to null and has only three source assignment
  sites: title-screen null, title-screen `bufTarget + 1`, and playback increment;
- its only source pointee write is the timer decrement;
- no source occurrence takes `&gCurrDemoInput` or casts its address through an
  integer;
- `gDemoInputsBuf` is passed only to initial setup and title-screen table load;
- a title-screen call writes `gCurrDemoInput = NULL` before testing input and,
  on the 800th idle frame, reloads a fixed table entry and assigns
  `gCurrDemoInput = gDemoInputsBuf.bufTarget + 1`;
- during active demo playback, live player-one input contributes only the Start
  bit. Stick values and other buttons are replaced from the fixed demo record;
  player two is cleared; and
- authentic US table entries fit the allocated 2048-byte demo buffer according
  to the existing generated ROM audit.

These facts strongly narrow possible corruption mechanisms, but a textual or AST
census is not by itself a semantic noninterference proof.

## Is whole-program memory safety necessary?

No. It is sufficient, but stronger than necessary.

For a clean boot followed by the attract-mode title/demo path, a bounded semantic
proof can cover only setup, controller ingestion, the title countdown/table load,
demo playback, and the fixed demo termination bounds. The key input case split is:

- nonzero title input resets/delays the countdown, so no demo pointer is installed;
- a demo starts only after 800 idle frames, at which point the title code installs
  the allocator-derived pointer; and
- while the demo is active, arbitrary live input can preserve Start and terminate
  playback, but cannot select a different pointer, timer, stick, or demo button
  value.

For a stronger history that permits arbitrary ordinary gameplay before returning
to the title screen, the needed property is still target-specific rather than
whole-memory safety. It is enough to prove a frame invariant for:

- the `gCurrDemoInput` global cell;
- `gDemoInputsBuf.dmaTable`, `.currentAddr`, and `.bufTarget`; and
- the live 2048-byte demo allocation.

Such a proof must enumerate every reachable store that can alias those targets,
prove the relevant address-taking/escape facts, and handle the known setup,
DMA, title, and timer writes. Unrelated corruption that provably cannot reach
these addresses need not be ruled out.

## CompCert versus the matching N64 executable

For defined CompCert Clight executions, distinct global/allocation blocks provide
a useful boundary: an out-of-bounds store does not silently spill into an adjacent
block; the execution becomes stuck. A theorem quantified over all **defined**
input executions can therefore be substantially smaller than whole-program
memory safety, provided it proves the target blocks do not escape to unchecked
writers.

That theorem would not describe what the original N64 machine does after a C
undefined-behavior case. The pinned source contains documented examples including
an audio queue out-of-bounds write candidate, out-of-bounds reads, implementation-
dependent conversions, and crash paths; the proof translation also uses
`AVOID_UB=1`. To cover the matching US executable even after such a case, the
appropriate obligation is a machine-level, target-address write-reachability
analysis. That is still weaker than proving the entire program memory-safe: it
only needs to show that no reachable MIPS store can hit the protected pointer,
handler fields, or demo buffer with a corrupting value.

## Recommended next theorem

The next useful capstone should be a real Clight execution theorem for the
clean-boot attract-mode path. It should state a before/after invariant over the
concrete generated functions and memories, not another conjunction of syntax
checks. After that, a separate target-frame theorem can broaden the allowed
history to ordinary gameplay. The matching-ROM/UB question should remain a
clearly separate machine-semantics track.
