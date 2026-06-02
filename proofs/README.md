# `proofs/` — structure & dependency graph

Hand-written Rocq: generic analyses over the generated Clight ASTs, plus the
theorems. The tree is organized around **two nested goals**, near-term first:

| | Goal | Capstone | Status |
|---|---|---|---|
| **GOAL 1** | no-A ⇒ no-fly: entering `ACT_FLYING` requires an A press | `NoAImpliesNoFly/NoAImpliesNoFly.v` → `noA_no_spawn_never_flying` | proved (abstract harness) |
| **GOAL 2** | WMotR cannot be done with 0 A presses (ABC impossibility) | `WMotRRequiresA/` (README only) | not started; builds on GOAL 1 |

```
proofs/
  Generic/            shared analyses          ┐ used by both goals
  MarioModel/         shared action vocabulary ┘
  NoAImpliesNoFly/        GOAL 1 spine: the no-A⇒no-fly capstone
    NoAImpliesNoFly.v       the capstone theorem
    Unwired/                proved but NOT yet wired into GOAL 1 (still compiled): 28 files
  WMotRRequiresA/         GOAL 2 spine: the WMotR-ABC-impossibility capstone (not started)
    README.md               the goal + the argument chain it must formalize
    Unwired/                staging for GOAL 2 (empty)
```

**Spine vs `Unwired/`.** A goal's *spine* is the set of files transitively
required by its capstone — that's what's load-bearing. Everything else proved
toward the goal sits in its `Unwired/`: still listed in `_CoqProject` and compiled
by `make` (so it can't bitrot), but by construction not reachable from the
capstone. As a piece gets wired in, `git mv` it from `Unwired/` into a spine dir
and fix its `_CoqProject` path — imports need no edit (basename resolution, below).

All cross-file imports use `From SM64.Proofs Require Import <Basename>`, which
resolves by unique basename regardless of subdirectory.

> Renaming history: files/theorems were renamed to literal names on 2026-06-01
> (incl. `WMotRStatement`→`NoAImpliesNoFly`, since it proves the *smaller* goal).
> Older `docs/` notes use the previous names — see
> [`../docs/RENAMING.md`](../docs/RENAMING.md) for the full old → new map.

---

## GOAL 1 spine (load-bearing for `noA_no_spawn_never_flying`)

Shared infrastructure + the capstone, in build order:

```
Generic/Frame                 syntactic frame analysis: does f assign to global g? (writes_global)
Generic/AddressTaken          syntactic address-taken / escape analysis        (<- Frame)
Generic/CallgraphReach        whole-program callgraph reachability skeleton     (<- Frame, AddressTaken)
MarioModel/Flying             ACT_FLYING constants, flying setters, writers     (<- CallgraphReach)
Generic/FieldNonInterference  semantic frame lemma: a store to field f1 leaves field f2 unchanged
MarioModel/ActionValue        value-level reasoning about the action field      (<- Flying, FieldNonInterference)
MarioModel/ActionValueFrame   the value-aware frame engine                      (<- ActionValue)
Generic/ReachableRun          temporal harness: noA_run => not flying
NoAImpliesNoFly/NoAImpliesNoFly   THE GOAL-1 capstone                           (<- Flying, ActionValueFrame, ReachableRun)
```

`noA_no_spawn_never_flying` rests on exactly the 4 standard CompCert axioms:
`bash pipeline/assumptions.sh SM64.Proofs.NoAImpliesNoFly.NoAImpliesNoFly noA_no_spawn_never_flying`.

## `NoAImpliesNoFly/Unwired/` — proved but not yet wired into GOAL 1 (28 files)

Grouped by what they are. All compile; none is reachable from the GOAL-1 capstone.

**Discharge engine + per-handler "scoreboard"** — the interprocedural store-frame
machinery and the per-handler body proofs. (Per `docs/`, the 111-handler grind is
*not* the intended critical path — a single generic store-frame bridge is meant to
replace it; these are the interim/brute-force discharge.)
`ResetBodystate`, `SetAnimToFrame`, `SetMarioActionMoving`, `UpdateMarioInfoForCam`,
`SquishMarioModel`, `ArrayStore`, `BodyFrameDecider`, `FuncallFrame`,
`TempProvenanceInvariant`, `StatementFrame`, `PointerChaseCount`,
`PointerChaseList`, `PointerChaseDischarge`, `StoreFrameSpine`, `StoreFrameHook`.

**Earlier / alternate GOAL-1 statements** — parallel formulations of "must press A
to fly", not (yet) the capstone's path:
`FlyingStatement`, `FlyingFrame`, `NoAFlyingSpine`.

**Mario-model extras** — analyses proved but not consumed by the capstone:
`MarioMemoryWF` (block-distinct memory), `ActionWriters` (whole-program action-writer
enumeration), `ActionGraph` (action transition graph).

**Generic helpers (unused by capstone)** — `RootedLvalue` (lvalue rooting),
`GlobalSeparation` (the separation / "havoc" rung).

**Pipeline demos (M0/M1)** — `ToyFrame`, `ToyReach`, `ShadowFrame`, `ShadowSpec`.

**De-risking spike** — `SymbolicLinking` (OOM-free cross-translation-unit calls).

---

## Recomputing the spine / Unwired split

A goal's spine is `closure(<capstone>)` over the proof-only `Require` edges. To
regenerate a textual dep view (after wiring something in, say):

```sh
for f in $(find proofs -name '*.v' | sort); do
  echo "$(basename "$f" .v) <- $(grep -hzoE 'From SM64.Proofs Require( Import)?[^.]*\.' "$f" \
    | tr '\n' ' ' | sed -E 's/From SM64.Proofs Require( Import)?//g; s/\.//g')"
done
```
