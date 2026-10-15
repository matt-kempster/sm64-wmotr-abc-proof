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
The capstone also executes the whole first-demo title body, with the concrete
loader call still an explicit execution premise; the full active-demo
`lvl_set_current_level` and interpreter `level_cmd_call`; painting-warp
rejection with a null table; delayed-demo dispatch through the real
`warp_special`; transition completion with a zero warp destination; and the
full pause query with its real dialog helper. These components have explicit
memory, symbol, layout and branch premises. Their conjunction does not prove
that a complete normally reachable execution satisfies those premises.

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
metadata receipt, builds the registered modules with one job by default,
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

The private site source is the workspace sibling `demo-proof-notes-site`.
Keep its verdict aligned with these documents and preserve owner-only access.
Do not mix this result into the SSL or Pedro reports or publish conversation
exports.
