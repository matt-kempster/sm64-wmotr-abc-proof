# sm64-wmotr-abc-proof

Machine-checked reasoning about the **Super Mario 64** decompilation, aimed at a formal
*impossibility* result for the **Wing Mario over the Rainbow (WMotR)** case of the
**A Button Challenge (ABC)**.

Route: **Rocq (Coq) + CompCert `clightgen`**. Pinned decomp C source → Clight ASTs (in
Rocq, under `generated/`) → hand-written analyses and theorems over those ASTs (under
`proofs/`). The toolchain is configured N64-faithfully (32-bit pointers, big-endian).
See `docs/` for the design conversations that led here.

> **Status.** GOAL 1 — *"a run with no A-press never enters a flying action"* — has a
> live capstone theorem, `noA_no_spawn_never_flying_real_mwf`
> (`proofs/NoAImpliesNoFly/NoAImpliesNoFlyLinked.v`), stated over the **real linked
> program**: the mechanically generated Clight of `mario.c` linked with the interaction
> and action-handler translation units, under CompCert's bigstep semantics. It is fully
> `Qed`'d and rests only on the standard CompCert axioms — **but it is not finished**:
> it still consumes an explicit, shrinking set of named residual hypotheses (see the
> honest scoreboard below). GOAL 2 (WMotR itself requires A) is not started.

---

## The theorem being built (GOAL 1)

**Claim.** Over the linked Clight program (15 generated translation units: `mario`,
`interaction`, `mario_step`, the `mario_actions_*` handlers, …), if the per-frame input
never has the A button pressed, then Mario's `action` field never takes a value in the
tainted set (the flying actions, flying-triple-jump, and the cannon path that can launch
into flying).

The proof shape: every entry into the tainted action set is shown to be **A-gated** (a
census over the generated AST + per-site gate lemmas), and a value/provenance engine
walks the real execution of the frame showing nothing else can write a tainted value
into the `action` cell — including through pointer chases, stack locals, out-params,
and cross-TU calls. Memory well-formedness (`MWFReal.v`) supplies the anti-aliasing
facts (block distinctness, safe store windows, pointer-chase closure).

**Verify it yourself:**

```sh
bash pipeline/build.sh proofs                      # build everything
bash .claude/skills/proof-discipline/discipline_check.sh   # the full audit
```

The audit checks: clean build, no `Admitted`/`Axiom`/`sorry` anywhere, the capstones'
`Print Assumptions` footprint (only standard CompCert axioms), and the structural
firewall (nothing load-bearing hides in `Unwired/`). It also prints the **residual
surface** — the named hypotheses the capstone still assumes. That list, not the green
build, is the honest progress meter.

### Honest scoreboard — what is still assumed

The capstone's remaining residuals are explicit named hypotheses (never `Admitted`):

- **Per-handler walks (the active front).** The 29 `interact_*` handler bodies are
  being discharged one by one through a census-keyed split; each walked handler
  shrinks the assumed census (`io_rest_ids`).
- **`Hret_call`** — per-reached-body return-value non-aliasing (a known grind).
- **Terminal-external boundary rows** — functions that are `EF_external` in *every*
  generated TU (math builtins like `sqrtf`/`atan2s`, surface queries like
  `find_floor`/`find_wall_collisions`). These are the honest model boundary, each
  gated on its real argument shape (e.g. "writes only through its out-param, which
  is a stack local") rather than assumed blindly.
- **Block-distinctness hypotheses** — e.g. Mario's state block is distinct from the
  controller block (Mario's `MarioState` lives behind an uninitialized global pointer,
  so it is pinned by distinctness, not by `find_symbol`).

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

If you feel the urge to tweak a generated file, the answer is always one of:
1. fix the **pipeline**, or
2. add a **patch** to the input, or
3. write the adjustment as a lemma in **`proofs/`**.

A second discipline guards against the subtler failure mode (proving true things about
fictions): see `.claude/skills/proof-discipline/SKILL.md`. Residual gaps are kept as
*named hypotheses on the capstone*, so `Print Assumptions` plus the audit script always
tell the whole truth.

---

## Layout

```
docs/            design conversations + RENAMING.md (read these for the "why")
vendor/sm64/     pinned submodule: the n64decomp/sm64 source of truth
patches/         hand-modifications to input, as *.patch
pipeline/        scripts: source -> preprocessed C -> clightgen -> generated/*.v
                 + build.sh / check.sh / assumptions.sh drivers
experiments/     self-contained inputs not from upstream (the M0 toy)
generated/       GENERATED Clight ASTs (.v), 15 SM64 translation units.
                 Committed, never hand-edited; regenerate via pipeline.
proofs/          hand-written Rocq over generated/ (see proofs/README.md):
  Generic/         subject-independent: frame lemmas, callgraph reach,
                    symbolic linking (cross-TU calls without vm_compute-ing
                    the whole linked program)
  MarioModel/      the engine: action taint census (CensusV2), A-gate lemmas
                    (AGates), memory well-formedness (MWFReal), the value/
                    provenance walkers and per-TU "surface" files
  NoAImpliesNoFly/ GOAL 1 capstones (NoAImpliesNoFlyLinked.v) + sub-areas
  WMotRRequiresA/  GOAL 2 (not started)
  Toy/ Shadow/     the original M0/M1 pipeline demos
_CoqProject      Rocq logical-path map
Makefile         top-level: regenerate + build proofs
```

Everything load-bearing is in the transitive closure of the GOAL-1 capstone (the
**spine**). Anything compiled but not consumed by the spine lives under an `Unwired/`
directory, and CI forbids the spine from importing it — staging can't masquerade as
results.

## Toolchain & build

Built into a dedicated opam switch so it can't disturb other projects:

```sh
opam repo add coq-released https://coq.inria.fr/opam/released
opam switch create sm64-proof ocaml-base-compiler.4.14.2 --no-switch
opam install coq-compcert        # provides `clightgen` + the compcert.* Rocq libs
```

(`coq-compcert` requires **OCaml < 5** — on a 5.x switch opam silently resolves to an
ancient CompCert. Known-good versions: OCaml 4.14.2, Coq 8.19.2, coq-compcert 3.15.)

Then build through the pipeline drivers (they activate the switch and set
memory guardrails — don't run bare `coqc`):

```sh
bash pipeline/build.sh proofs                       # build the proofs
bash pipeline/assumptions.sh <Module.Path> <thm>    # Print Assumptions of a theorem
python3 pipeline/check_unwired.py                   # spine/Unwired firewall
```

## Roadmap

- ~~**M0/M1:** pipeline spine on a toy file, then a real TU (`shadow.c`).~~ Done.
- **GOAL 1 (active):** no-A ⇒ no-fly over the real linked program. Capstone live;
  discharging the remaining residual surface (handler walks, `Hret_call`).
- **GOAL 2:** WMotR requires entering the flying set — i.e. the red coins + star are
  unreachable without it (the Mario-y-bound / red-coin argument). Builds on GOAL 1.
