# Demo-warp byte-store proof

This Rocq/Coq + CompCert project investigates whether SM64's demo-input
timer update can produce the one-byte Mario-Y change proposed for the
DOTA_Teabag Tick Tock Clock upwarp.

The checked result is deliberately split into two claims:

1. a generated-Clight counterexample to the unconditional claim that the
   code has no one-byte update capable of changing `0xC5` to `0xC4`; and
2. a generated source census of the assignments that can normally establish
   or advance `gCurrDemoInput`.

The counterexample does **not** by itself prove that normal gameplay can make
`gCurrDemoInput` alias `gMarioStates[0].pos[1]`. That reachability question is
tracked explicitly in [docs/claim.md](docs/claim.md) and
[docs/checklist.md](docs/checklist.md).

`demo_timer_mario_y_counterexample_capstone` proves the generated decrement
shape, the concrete layouts, the unsigned-byte store witness, and the direct
pointer-writer certificate. `unconditional_no_matching_byte_store_is_false`
records the narrow counterexample result. Both compile without proof holes;
their assumption footprint is the standard axioms inherited from CompCert.

## Proof route

```text
pinned US SM64 decompile sources
  -> CompCert clightgen-generated Clight ASTs
  -> generated layout and writer-census certificates
  -> byte-store semantics and aliasing counterexample
  -> explicit reachability boundary
```

Generated files are never hand-edited. With the repository's
`sm64-item-proof` opam switch active:

```sh
source pipeline/env.sh
make generated
make proofs
bash pipeline/check.sh
```
