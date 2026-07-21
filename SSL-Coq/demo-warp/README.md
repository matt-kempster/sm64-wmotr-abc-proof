# Demo-warp byte-store proof

This Rocq/Coq + CompCert project investigates whether SM64's demo-input
timer update can produce the one-byte Mario-Y change proposed for the
DOTA_Teabag Tick Tock Clock upwarp.

The checked result is deliberately split into three claims:

1. a generated-Clight counterexample to the unconditional claim that the
   code has no one-byte update capable of changing `0xC5` to `0xC4`; and
2. a generated source census of the assignments that can normally establish
   or advance `gCurrDemoInput`; and
3. a normal-initialization reachability theorem showing that the authentic US
   demo pointer cannot alias Mario's Y byte.

The local counterexample does **not** arise from normal initialization.
`normal_initialization_forbids_demo_pointer_mario_y_alias` composes generated
Clight provenance, allocator bounds, authentic US demo termination, and linker
ordering to prove the alias unreachable on that path. Reaching the local
counterexample therefore requires prior memory corruption, undefined behavior,
non-authentic demo data, or another state outside the proved normal path.

`demo_timer_mario_y_counterexample_capstone` proves the generated decrement
shape, the concrete layouts, the unsigned-byte store witness, and the direct
pointer-writer certificate. `unconditional_no_matching_byte_store_is_false`
records the narrow counterexample result. The normal-initialization theorem is
closed under the global context and includes an inhabitance witness; the older
CompCert memory theorems inherit CompCert's standard axioms.

The companion theorem `separated_demo_pointer_cannot_change_mario_y` proves
the conditional impossibility direction: an unsigned-byte timer store in a
demo-buffer block cannot change the Mario-Y byte in a distinct Mario-state
block. `alias_is_necessary_for_demo_timer_mario_y_byte_change` makes the proof
frontier explicit—a matching change requires the two pointers to share a
CompCert memory block.

## Proof route

```text
pinned US SM64 decompile sources
  -> CompCert clightgen-generated Clight ASTs
  -> generated layout and writer-census certificates
  -> byte-store semantics and aliasing counterexample
  -> ROM/linker and allocator reachability certificates
  -> normal-initialization no-alias capstone
```

Generated files are never hand-edited. With the repository's
`sm64-item-proof` opam switch active:

```sh
source pipeline/env.sh
make generated
make proofs
bash pipeline/check.sh
```
