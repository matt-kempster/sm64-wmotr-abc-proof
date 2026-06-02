# `proofs/` — structure & dependency graph

Hand-written Rocq: generic analyses over the generated Clight ASTs, plus the
theorems. The tree is split into two parts:

- **the active spine** — the 9 files transitively required by the capstone
  theorem `wmotr_noA_no_spawn_never_flying` (in `Theorems/WMotRStatement.v`).
  These live in layered subdirectories (`Generic/`, `MarioModel/`, `Theorems/`)
  whose order is the build/topological order.
- **`Unwired/`** — everything proved but **not yet wired into the capstone**:
  the discharge engine + per-handler scoreboard, exploratory analyses, earlier
  theorem statements, pipeline demos, and spikes. Still listed in `_CoqProject`
  and compiled by `make`, so nothing bitrots — but it is, by construction, not
  load-bearing for the current capstone. As pieces get wired in, move them out
  of `Unwired/` into the appropriate spine layer.

All cross-file imports use `From SM64.Proofs Require Import <Basename>`, which
resolves by unique basename regardless of subdirectory — so moving a file in or
out of `Unwired/` needs no edit to its importers, only to `_CoqProject`.

> Renaming history: many files/theorems were renamed to literal names on
> 2026-06-01. Older `docs/` notes use the previous names — see
> [`../docs/RENAMING.md`](../docs/RENAMING.md) for the full old → new map.

---

## Active spine (load-bearing for the capstone)

The capstone's dependency chain, in build order:

```
Generic/Frame                 syntactic frame analysis: does f assign to global g? (writes_global)
Generic/AddressTaken          syntactic address-taken / escape analysis        (<- Frame)
Generic/CallgraphReach        whole-program callgraph reachability skeleton     (<- Frame, AddressTaken)
MarioModel/Flying             ACT_FLYING constants, flying setters, writers     (<- CallgraphReach)
Generic/FieldNonInterference  semantic frame lemma: a store to field f1 leaves field f2 unchanged
MarioModel/ActionValue        value-level reasoning about the action field      (<- Flying, FieldNonInterference)
MarioModel/ActionValueFrame   the value-aware frame engine                      (<- ActionValue)
Generic/ReachableRun          temporal harness: noA_run => not flying
Theorems/WMotRStatement       THE capstone: no-A, no-spawn => never flying      (<- Flying, ActionValueFrame, ReachableRun)
```

`wmotr_noA_no_spawn_never_flying` rests on exactly the 4 standard CompCert
axioms (verify with `bash pipeline/assumptions.sh
SM64.Proofs.Theorems.WMotRStatement wmotr_noA_no_spawn_never_flying`).

## `Unwired/` — proved but not yet wired in (28 files)

Grouped by what they are. All compile; none is reachable from the capstone.

**Discharge engine + per-handler "scoreboard"** — the interprocedural store-frame
machinery and the per-handler body proofs. (Per `docs/`, the 111-handler grind is
*not* the intended critical path — a single generic store-frame bridge is meant to
replace it; these are the interim/brute-force discharge.)
`ResetBodystate`, `SetAnimToFrame`, `SetMarioActionMoving`, `UpdateMarioInfoForCam`,
`SquishMarioModel`, `ArrayStore`, `BodyFrameDecider`, `FuncallFrame`,
`TempProvenanceInvariant`, `StatementFrame`, `PointerChaseCount`,
`PointerChaseList`, `PointerChaseDischarge`, `StoreFrameSpine`, `StoreFrameHook`.

**Earlier / alternate top-level statements** — parallel formulations of the
"must press A to fly" result, not (yet) the capstone's path:
`FlyingStatement`, `FlyingFrame`, `NoAFlyingSpine`.

**Mario-model extras** — analyses proved but not consumed by the capstone:
`MarioMemoryWF` (block-distinct memory), `ActionWriters` (whole-program action-writer
enumeration), `ActionGraph` (action transition graph).

**Generic helpers (unused by capstone)** — `RootedLvalue` (lvalue rooting),
`GlobalSeparation` (the separation / "havoc" rung).

**Pipeline demos (M0/M1)** — `ToyFrame`, `ToyReach`, `ShadowFrame`, `ShadowSpec`.

**De-risking spike** — `SymbolicLinking` (OOM-free cross-translation-unit calls).

---

## Recomputing the spine / floating split

The split is `closure(WMotRStatement)` vs. the rest. To recompute (e.g. after
wiring something in), list each file's proof-deps and take the transitive closure:

```sh
for f in $(find proofs -name '*.v' | sort); do
  echo "$(basename "$f" .v) <- $(grep -hzoE 'From SM64.Proofs Require( Import)?[^.]*\.' "$f" \
    | tr '\n' ' ' | sed -E 's/From SM64.Proofs Require( Import)?//g; s/\.//g')"
done
```
