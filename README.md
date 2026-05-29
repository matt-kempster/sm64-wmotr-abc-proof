# sm64-wmotr-abc-proof

An experiment in machine-checked reasoning about the **Super Mario 64** decompilation,
aimed (eventually) at a formal *impossibility* result for the **Wing Mario over the
Rainbow (WMotR)** case of the **A Button Challenge (ABC)**.

Route: **Rocq (Coq) + CompCert `clightgen`**. C source → Clight AST (in Rocq) → generic
analyses / proofs over that AST. See `docs/` for the design conversations that led here.

> Status: **Milestone 0 — toolchain spine.** We are not proving anything about Mario yet.
> We are proving that the *pipeline* works end to end on a tiny self-contained C file.

---

## The one rule: this is a PIPELINE, not a bespoke model

The single most important convention in this repo:

> **We do not hand-write or hand-edit a Clight/Rocq model of SM64.**
> Every Clight artifact is **mechanically generated** from pinned upstream source by a
> reproducible script. Proofs are written *against* generated artifacts; they never edit
> them. Any unavoidable hand-modification of the *input* is captured as a **patch**, not
> as an in-place edit.

Why: the credibility of the eventual theorem rests on the model faithfully reflecting the
real, byte-matching decompilation. A bespoke hand-built model is unfalsifiable hand-waving.
A regenerable pipeline is auditable: anyone can re-run it from the pinned commit and get
byte-identical output.

### What this means concretely

| Directory      | Role | Hand-edited? |
|----------------|------|--------------|
| `vendor/sm64/` | Upstream SM64 decomp, pinned git **submodule**. The source of truth. | **Never.** Bump the pin deliberately. |
| `patches/`     | `*.patch` files applied to `vendor/sm64` (or to preprocessed TUs) before extraction. The *only* sanctioned form of hand-modification of input. | The patches, yes. The target, no. |
| `pipeline/`    | Scripts that turn source into Clight `.v`. The pipeline itself. | Yes — this is our code. |
| `generated/`   | Output of `pipeline/`: Clight ASTs as Rocq `.v`. Committed, but each file carries a `DO NOT EDIT` header. | **Never.** Regenerate instead. |
| `proofs/`      | Hand-written Rocq: generic analyses over generated ASTs + the theorems. Imports `generated/`, never modifies it. | Yes — this is our math. |
| `experiments/` | Self-contained scratch inputs (e.g. the Milestone-0 toy C file) that don't belong to upstream. | Yes. |
| `docs/`        | Design notes / source conversations. | Yes. |

### Generated files are committed but sacred

We commit `generated/*.v` (decision: reviewable diffs, and proofs build without a local
CompCert). Each is stamped with a `DO NOT EDIT — regenerate via pipeline` header. CI's job
(later) is to assert that re-running the pipeline produces byte-identical output. If you
feel the urge to tweak a generated file, the answer is always one of:
1. fix the **pipeline**, or
2. add a **patch** to the input, or
3. write the adjustment as a lemma in **`proofs/`**.

---

## Layout

```
docs/            design conversations (read these for the "why")
vendor/sm64/     pinned submodule: the n64decomp/sm64 source of truth
patches/         hand-modifications to input, as *.patch (none yet)
pipeline/        scripts: source -> preprocessed C -> clightgen -> generated/*.v
experiments/     self-contained inputs not from upstream
  toy/           Milestone-0 toy C file
generated/       GENERATED Clight ASTs (.v). Committed, never hand-edited.
proofs/          Rocq analyses + theorems over generated/
_CoqProject      Rocq logical-path map
Makefile         top-level: regenerate + build proofs
```

## Toolchain

Built into a dedicated, throwaway opam switch so it can't disturb your other projects:

```sh
opam repo add coq-released https://coq.inria.fr/opam/released
opam switch create sm64-proof ocaml-base-compiler.5.2.0 --no-switch
opam install coq-compcert        # provides `clightgen` + the compcert.* Rocq libs
```

Then, in any shell that touches this repo:

```sh
eval $(opam env --switch sm64-proof)
```

`pipeline/env.sh` does exactly that — `source pipeline/env.sh`.

## Milestone 0: the toy spine

Goal: prove the *infrastructure* works, with the smallest real theorem.

```sh
source pipeline/env.sh
make                     # clightgen the toy, then build proofs
```

This runs `clightgen` on `experiments/toy/toy.c` → `generated/toy.v`, then checks
`proofs/ToyFrame.v`, which defines a generic syntactic "does function `f` assign to global
`g`?" analysis over the Clight AST and machine-checks two facts:

- `clobber` **does** write the global `gUnrelated`  (positive control), and
- `set_timer` **does not**.

This deliberately mirrors the docs' target shape (`writesOf` computed over the AST, checked
by `reflexivity`), at toy scale. **Soundness** of the syntactic analysis (syntactic
non-write ⇒ semantic preservation, via CompCert's Clight semantics) is *not* proved here —
that's Milestone 2. Milestone 0 only establishes the generate→load→compute→check spine.

## Roadmap (from `docs/`)

- **M0 (here):** toolchain + pipeline spine on a toy file.
- **M1:** `clightgen` a *real* SM64 translation unit (`src/game/shadow.c`) from the pinned
  submodule; commit its generated Clight; recompute the same syntactic facts over it.
- **M2:** prove soundness of the frame/effect analysis against CompCert Clight semantics.
- **M3+:** WMotR level-load / action abstraction → the ABC impossibility theorem.
