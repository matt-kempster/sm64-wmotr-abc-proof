# SSL Pyramid pole-bypass proof

This project studies whether Mario can get from the fifth floor to the sixth
floor of the Shifting Sand Land Pyramid without pressing A. It follows the
Rocq/Coq + CompCert Clight structure used by the sibling SSL-Cog projects.

The intended result has two deliberately separate parts:

1. prove that the ordinary pole route needs an A press and that one A press is
   sufficient; and
2. either close every pole-bypass route from an arbitrary reachable prepared
   state, or provide a concrete zero-A counterexample.

The first part has a source-and-geometry proof plan. The second is the global
completeness obligation and is not assumed away. See `docs/claim.md` for the
exact boundary and `docs/checklist.md` for live status.

## Project route

```text
pinned US SM64 source and SSL Area 2 collision literals
  -> CompCert clightgen
  -> generated Clight AST shape certificates
  -> exact pole-exit and sixth-floor-hole arithmetic
  -> pole-route minimum-A theorem
  -> global prepared-state bypass audit
```

Generated Clight files are never hand-edited.

## Current status

The isolated project scaffold and durable claim documents exist. Model,
generated Clight, proofs, and end-to-end checks are the next commits.

## Build

The toolchain is Coq 8.16.1 and CompCert 3.15 in the `sm64-item-proof` opam
switch. Once the model and proof modules land, the normal commands will be:

```sh
source pipeline/env.sh
make generated
bash pipeline/check.sh
```
