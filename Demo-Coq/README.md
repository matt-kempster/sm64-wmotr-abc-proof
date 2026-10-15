# Demo-Coq

Coq + CompCert investigation of the claim:

> Demo desync is not possible. Demo desync is having one demo input sequence
> playing in a different demo level.

**Verdict: OPEN for normal retail gameplay.** This project neither proves the
all-executions impossibility claim nor supplies a reachable counterexample.
It proves concrete local startup, interpreter, warp and pause executions and
checks source facts that narrow the remaining work. A mismatched state supplied by
hand is not a normal-boot counterexample.

This is a separate project alongside SSL-Coq and Pedro-Coq. Its source of
truth is decomp commit `9921382a68bb0c865e5e45eb594d9c64db59b1af`.
The pipeline mechanically generates 19 translation units for each of
`VERSION_US` and `VERSION_JP` with CompCert 3.15. Generated Clight is never
hand-edited. EU, Shindou, iQue, ROM patches, and emulator refinements are
outside the current result.
Generation uses `TARGET_N64=1`, `NON_MATCHING=1` and `AVOID_UB=1` with a
32-bit big-endian PowerPC EABI CompCert target. Refinement to N64 MIPS
retail-binary execution and hardware is open.

## Read the result

- [Plain English guide](docs/plain-english-guide.md)
- [Exact claim and proof boundary](docs/claim.md)
- [Remaining obligations](docs/checklist.md)
- [Build and audit details](docs/proof-audit.md)
- [Detailed source audit](docs/notes/source-audit.md)
- [Executed startup and interpreter paths](docs/notes/gameplay-execution.md)
- [Composed loader/title path](docs/notes/loaded-title-execution.md)
- [Executed conditional dispatch and address-model obstruction](docs/notes/conditional-dispatch.md)
- [Existing address-refinement results and remaining bridge](docs/notes/address-refinement.md)
- [Actual Demo Next scheduling and transition callees](docs/notes/start-scheduling-execution.md)
- [Complete demo-record consumer and byte-range frames](docs/notes/playback-execution.md)
- [Actual Start handling prefix](docs/notes/normal-start-execution.md)
- [Complete instant-warp rejection](docs/notes/instant-warp-execution.md)
- [Numeric address-helper execution](docs/notes/numeric-address-execution.md)
- [Authenticated numeric script images](docs/notes/script-numeric-image.md)
- [Taken numeric jump and next-opcode boundary](docs/notes/numeric-dispatch-execution.md)
- [Actual controller processing branch](docs/notes/controller-input-execution.md)
- [Warp and timer caller interval before object updates](docs/notes/normal-preobjects-execution.md)
- [Private global linking correction still to apply](docs/notes/private-global-linkage.md)
- [Executed warp boundaries](docs/notes/gameplay-boundary.md)
- [Executed pause exclusion](docs/notes/pause-exclusion.md)
- [Finite retail gameplay search](docs/notes/gameplay-search.md)
- [Authenticated finite demo-data receipt](docs/notes/demo-data.json)
- [Private companion site](https://demo-proof-notes.tra38.chatgpt.site)

## Checked capstone

`Demo.Proofs.MainTheorem.checked_demo_source_boundary_us_jp` combines the
generated-source certificates with a forward CompCert execution of the exact
demo-installation suffix and the real return statement. With the declared
layout, symbol, readable-header, writable-cell and separation premises, that
code installs the buffer pointer plus four bytes and returns the signed first
header byte from the same buffer. US and JP use the same installation code.
The capstone composes the actual loader with the whole first-demo title body,
reducing the remaining call premise to the exact `dma_read`. It also executes
the full active-demo `lvl_set_current_level` and interpreter `level_cmd_call`,
painting rejection with a null table, delayed-demo dispatch through the real
`warp_special`, transition completion with a zero warp destination, the full
pause query with its real dialog helper, and Demo Next scheduling with its
actual transition/RGB callees. These components have explicit memory, symbol,
layout and branch premises. Their conjunction does not prove that a complete
normally reachable execution satisfies those premises.
The actual input consumer now executes every timer branch with the second
logical controller absent: ordinary decrement, record advance, and the
terminal record. It proves exact outputs and byte-range memory frames;
initialization, bounds and all-frame provenance remain open. The actual Start
prefix selects the proved scheduler, with its real per-version intro-text
call still an explicit premise. The complete instant-warp routine returns
without writes for a null floor or null table under its stated reads.

The finite source certificates inspect playback's lack of a current-level
reference, the painting path's lack of a demo-pointer reference, the delayed
demo-exit branch, the interpreter's register-forward/capture syntax, direct
level-assignment syntax, and command-boundary parsing of the seven demo-level
script units. A new exact generated dispatch-table check maps each authentic
header to its level entry. The file `bitdw.bin` selects header 30, the
**Bowser 1 arena**, rather than the BITDW course (17). The earlier census
used the wrong first script; it is corrected to `bowser_1`. These finite
checks are syntax results, not whole-program execution proofs.
In particular, no-painting declarations do not establish a memory invariant.
The actual equality helper and a complete nonmatching conditional jump are
executed too. A separate mechanical check exposes why a taken script jump
cannot simply assume that `segmented_to_virtual` converts an `Init_addrof`
symbolic pointer to a retail numeric address: its first pointer shift is
undefined in this memory model. This is a refinement gap, not a game desync.

## Reproduce

On this machine use **Ubuntu** WSL and the `sm64-item-proof` opam switch.
The verified toolchain is Coq 8.16.1 and CompCert 3.15. Every build and audit
goes through `pipeline/`; do not invoke bare `coqc`.

```sh
bash pipeline/build.sh generate
bash pipeline/build.sh proofs
bash pipeline/build.sh check
```

`check` regenerates twice and compares hashes, authenticates the finite ROM
metadata and numeric script-image receipts, builds the registered modules with one job by default,
checks for proof holes, prints the capstone's assumptions, runs `coqchk`, and
runs the project discipline audit. Keep the established memory limit.

For a selected audit:

```sh
bash pipeline/discipline-check.sh --build-timeout 600 --assumption-timeout 240 \
  Demo.Proofs.MainTheorem checked_demo_source_boundary_us_jp
```

The default source checkout is `../../reference-sm64-decomp`; override
`SM64_SOURCE` for Clight generation. The independent ROM receipt checker
accepts `--source PATH` and reads only canonical US/JP ROMs. It records hashes,
headers, sizes, termination offsets and frame counts, not ROMs or recorded
button/stick streams. To intentionally regenerate that metadata after review:

```sh
python3 pipeline/check-demo-data.py --write
```

`script-images` additionally requires the existing matching US/JP ELF/ROM
build cache at `../Pedro-Coq/instrumentation/ttc-runtime-snapshot/build/retail-map-9921382`.
It authenticates the complete build ROM against the clean ROM before using
ELF placements, checks all selected initializer words, and checks that the
Coq numeric transcription matches. The checker's `--help` lists explicit
source/cache overrides. These checks authenticate finite
data; they do not supply a runtime address simulation.

The private site source is the workspace sibling `demo-proof-notes-site`.
Keep its verdict aligned with these documents and preserve owner-only access.
Do not mix this result into the SSL or Pedro reports or publish conversation
exports.
