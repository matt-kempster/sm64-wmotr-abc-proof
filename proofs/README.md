# `proofs/` — structure & dependency graph

Hand-written Rocq: generic analyses over the generated Clight ASTs, plus the
theorems. Organized around **two nested goals**, near-term first, with the
*spine + `Unwired/`* idiom applied recursively.

| | Goal | Capstone | Status |
|---|---|---|---|
| **GOAL 1** | no-A ⇒ no-fly: entering `ACT_FLYING` requires an A press | `NoAImpliesNoFly/NoAImpliesNoFly.v` → `noA_no_spawn_never_flying` | proved (abstract harness) |
| **GOAL 2** | WMotR cannot be done with 0 A presses (ABC impossibility) | `WMotRRequiresA/` (README only) | not started; builds on GOAL 1 |

```
proofs/
  Generic/            shared subject-independent analyses + frame lemmas
  MarioModel/         shared Mario action vocabulary + value-aware frame engine
  Toy/                M0 pipeline demo (ToyFrame, ToyReach)
  Shadow/             M1 pipeline demo (ShadowFrame, ShadowSpec)
  NoAImpliesNoFly/        GOAL 1
    NoAImpliesNoFly.v       the capstone theorem (its spine is the shared dirs above)
    Unwired/                proved but NOT reached from the capstone:
      StoreFrameDischarge/    sub-goal: every reached fn preserves the non-flying action
        …15 engine + per-handler files (sub-capstone PointerChaseDischarge)…
        Unwired/              not wired into PointerChaseDischarge (ArrayStore, PointerChaseList)
      AltStatements/          parallel/earlier no-A⇒no-fly formulations
      ActionAnalyses/         syntactic action analyses, not yet consumed
  WMotRRequiresA/         GOAL 2 (not started)
    README.md               the goal + the argument chain it must formalize
    Unwired/                staging for GOAL 2 (empty)
```

**The idiom.** A goal (or sub-goal) directory holds its *capstone* and the files
on its spine; everything proved toward it but **not yet reachable from the
capstone** sits in a sibling `Unwired/`. Everything is in `_CoqProject` and
compiled by `make`, so nothing bitrots — `Unwired/` just marks "not load-bearing
(yet)". To wire a piece in: `git mv` it from `Unwired/` up into the spine and fix
its `_CoqProject` path. Imports never need editing — `From SM64.Proofs Require
Import <Basename>` resolves by unique basename regardless of subdirectory.

> Renaming history (2026-06-01): files/theorems were renamed to literal names,
> incl. `WMotRStatement`→`NoAImpliesNoFly` (it proves the *smaller* goal). Older
> `docs/` notes use the previous names — see [`../docs/RENAMING.md`](../docs/RENAMING.md).

---

## GOAL 1 spine — `noA_no_spawn_never_flying` (9 files)

The capstone's transitive closure, in build order:

```
Generic/Frame                 syntactic frame analysis: does f assign to global g?
Generic/AddressTaken          syntactic address-taken / escape analysis      (<- Frame)
Generic/CallgraphReach        whole-program callgraph reachability            (<- Frame, AddressTaken)
MarioModel/Flying             ACT_FLYING constants, flying setters, writers   (<- CallgraphReach)
Generic/FieldNonInterference  store to field f1 leaves field f2 unchanged
MarioModel/ActionValue        value-level reasoning about the action field    (<- Flying, FieldNonInterference)
MarioModel/ActionValueFrame   the value-aware frame engine                    (<- ActionValue)
Generic/ReachableRun          temporal harness: noA_run => not flying
NoAImpliesNoFly/NoAImpliesNoFly   THE capstone                                (<- Flying, ActionValueFrame, ReachableRun)
```

Rests on exactly the 4 standard CompCert axioms:
`bash pipeline/assumptions.sh SM64.Proofs.NoAImpliesNoFly.NoAImpliesNoFly noA_no_spawn_never_flying`.

`Generic/` also holds two **reusable-but-currently-unwired** lemmas, not in the
spine above: `GlobalSeparation` (the separation / "havoc" rung) and
`SymbolicLinking` (OOM-free cross-TU linking spike).

## GOAL 1 / `StoreFrameDischarge/` — the discharge sub-goal (15 + 2)

Sub-goal: *every reached internal function preserves the non-flying action
invariant* — the interprocedural store-frame machinery (sub-capstone
`PointerChaseDischarge`). Per `docs/`, the 111-handler grind is **not** the
intended critical path (a single generic store-frame bridge is meant to replace
it); this is the interim/brute-force discharge.

- spine: `StatementFrame`, `TempProvenanceInvariant`, `RootedLvalue`,
  `BodyFrameDecider`, `FuncallFrame`, `MarioMemoryWF`, `ResetBodystate`,
  `StoreFrameSpine`, `StoreFrameHook`, `PointerChaseCount`, the 4 per-handler
  proofs (`SetAnimToFrame`, `SetMarioActionMoving`, `SquishMarioModel`,
  `UpdateMarioInfoForCam`), and `PointerChaseDischarge`.
- `Unwired/`: `ArrayStore`, `PointerChaseList` (not reached from the sub-capstone).

## GOAL 1 / loose categories

- `AltStatements/` — `FlyingStatement`, `FlyingFrame`, `NoAFlyingSpine`: parallel
  formulations of "must press A to fly", not on the capstone's path.
- `ActionAnalyses/` — `ActionWriters`, `ActionGraph`: syntactic action analyses,
  proved but not yet consumed.

---

## Enforcement: `unused ⇒ unwired` (CI)

`pipeline/check_unwired.py` (a CI step) enforces the idiom mechanically:

1. **Firewall** — no file *outside* an `Unwired/` subtree may `Require` a file
   *inside* it (innermost boundary, so nesting works). The moment an `Unwired/`
   file is actually used by the spine, the build fails until it's promoted out.
2. **No orphans** — every `.v` *not* under an `Unwired/` must be reachable from a
   file marked as a root, or be marked itself. Markers are header comments:
   `(* spine-root: <why> *)` (a capstone) or `(* kept: <why> *)` (a standalone
   result deliberately not load-bearing, e.g. the `Toy/`/`Shadow/` demos and the
   unwired `Generic/` lemmas). A new lemma left unused in a spine dir is flagged.

Run locally: `python3 pipeline/check_unwired.py`.

## Recomputing any spine / Unwired split

A spine is `closure(<capstone>)` over the proof-only `Require` edges:

```sh
for f in $(find proofs -name '*.v' | sort); do
  echo "$(basename "$f" .v) <- $(grep -hzoE 'From SM64.Proofs Require( Import)?[^.]*\.' "$f" \
    | tr '\n' ' ' | sed -E 's/From SM64.Proofs Require( Import)?//g; s/\.//g')"
done
```
