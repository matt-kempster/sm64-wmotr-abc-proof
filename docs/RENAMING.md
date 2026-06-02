# Renaming & reorganization map (2026-06-01)

On 2026-06-01 the flat `proofs/*.v` list was reorganized into 6 layered
subdirectories, and the cryptic file/theorem names were renamed to literal ones.
**This file is the authoritative old → new map.** Older `docs/` conversations
(dated before this) use the *old* names; translate through the tables here.

The change was done in 4 commits on branch `proofs-reorg`, each independently
green (`bash pipeline/build.sh proofs` → exit 0):

1. move files into layer subdirs (no source edits)
2. rename 15 jargon files to literal names (+ update all references)
3. rename cryptic theorems/definitions (+ update all use sites)
4. docs (this file, `proofs/README.md`, README layout)

No new axioms were introduced: the capstone `wmotr_noA_no_spawn_never_flying`
still rests on exactly the 4 standard CompCert axioms.

---

## 0. Later split: spine vs `Unwired/` (also 2026-06-01)

After the reorg below, the tree was split by *load-bearing-ness*: the 9 files in
the transitive closure of the capstone `wmotr_noA_no_spawn_never_flying` stay in
the layered spine dirs (`Generic/`, `MarioModel/`, `Theorems/`); the other 28
moved to a flat **`proofs/Unwired/`** (proved but not yet wired into the capstone;
still compiled). The old `Milestones/`, `BodyProofs/`, and `Spikes/` dirs were
emptied and removed — those files now live in `Unwired/`. So a file's *layer* is
no longer fixed by the tables below; find any file with `find proofs -name '<X>.v'`.
See `proofs/README.md` for the spine/Unwired breakdown.

## 1. Directory structure (new)

```
proofs/
  Generic/      reusable, subject-independent analyses + semantic frame lemmas
  Milestones/   toy & shadow pipeline demos (not load-bearing for the theorem)
  MarioModel/   Mario-specific: memory layout, action vocabulary, value engine
  BodyProofs/   per-handler body-preservation proofs + the frame-check engine
  Theorems/     assembled top-level statements (the spine)
  Spikes/       de-risking experiments
```

**Import note:** `From SM64.Proofs Require Import <Basename>` resolves by unique
basename anywhere under `SM64.Proofs`, so the subdir is invisible to importers —
moving a file needs no edit to its importers, only to `_CoqProject`. Logical
module paths *do* gain the layer, e.g. `SM64.Proofs.Theorems.WMotRStatement`
(matters for `Print Assumptions` / `pipeline/assumptions.sh`).

## 2. File renames (old name → new path)

Files not listed were only *moved* (name unchanged); find any file's new home
with `find proofs -name '<Name>.v'`.

| Old `proofs/<X>.v` | New path | New basename |
|---|---|---|
| `Escape` | `Generic/AddressTaken.v` | `AddressTaken` |
| `Reach` | `Generic/CallgraphReach.v` | `CallgraphReach` |
| `FrameTrace` | `Generic/ReachableRun.v` | `ReachableRun` |
| `ActionFrame` | `Generic/FieldNonInterference.v` | `FieldNonInterference` *(generic, not action-specific)* |
| `Havoc` | `Generic/GlobalSeparation.v` | `GlobalSeparation` |
| `MarioMemWF` | `MarioModel/MarioMemoryWF.v` | `MarioMemoryWF` |
| `BodyNfDec` | `BodyProofs/BodyFrameDecider.v` | `BodyFrameDecider` |
| `ValueFrameINV` | `BodyProofs/TempProvenanceInvariant.v` | `TempProvenanceInvariant` |
| `ValueFrameStmt` | `BodyProofs/StatementFrame.v` | `StatementFrame` |
| `ChaseCount` | `BodyProofs/PointerChaseCount.v` | `PointerChaseCount` |
| `ChaseList` | `BodyProofs/PointerChaseList.v` | `PointerChaseList` |
| `ChaseDischarge` | `BodyProofs/PointerChaseDischarge.v` | `PointerChaseDischarge` |
| `BucketASpine` | `Theorems/StoreFrameSpine.v` | `StoreFrameSpine` |
| `BucketAHook` | `Theorems/StoreFrameHook.v` | `StoreFrameHook` |
| `LinkSpike` | `Spikes/SymbolicLinking.v` | `SymbolicLinking` |

Moved-only files: `Frame`, `RootedLvalue` (→`Generic/`); `ToyFrame`, `ToyReach`,
`ShadowFrame`, `ShadowSpec` (→`Milestones/`); `Flying`, `ActionWriters`,
`ActionGraph`, `ActionValue`, `ActionValueFrame` (→`MarioModel/`);
`ResetBodystate`, `SetAnimToFrame`, `SetMarioActionMoving`,
`UpdateMarioInfoForCam`, `SquishMarioModel`, `ArrayStore`, `FuncallFrame`
(→`BodyProofs/`); `FlyingStatement`, `FlyingFrame`, `NoAFlyingSpine`,
`WMotRStatement` (→`Theorems/`).

## 3. Theorem / definition renames

Only genuinely cryptic names were changed; already-literal names
(`store_field_preserves_other_field`, `flying_setters`, …) were kept.

| Old | New | Where |
|---|---|---|
| `NF` | `nonflying_action` | `Theorems/StoreFrameSpine.v` |
| `fr` | `frame_bundle` | `BodyProofs/StatementFrame.v` (def) + use sites |
| `sma_<x>` | `set_mario_action_<x>` | `MarioModel/ActionValue.v`, `ActionValueFrame.v` |
| `PT_anim` | `tracked_ptrs_anim` | `BodyProofs/SetAnimToFrame.v` |
| `FS_anim` | `chased_fields_anim` | `BodyProofs/SetAnimToFrame.v` |
| `PT_mov` | `tracked_ptrs_mov` | `BodyProofs/SetMarioActionMoving.v` |
| `FS_mov` | `chased_fields_mov` | `BodyProofs/SetMarioActionMoving.v` |
| `PT_squish` | `tracked_ptrs_squish` | `BodyProofs/SquishMarioModel.v` |
| `FS_squish` | `chased_fields_squish` | `BodyProofs/SquishMarioModel.v` |
| `PT_cam` | `tracked_ptrs_cam` | `BodyProofs/UpdateMarioInfoForCam.v` |
| `FS_cam` | `chased_fields_cam` | `BodyProofs/UpdateMarioInfoForCam.v` |

`sma_<x>` covered: `sma_ge`, `sma_switch_scrut`, `sma_switch_cases`,
`sma_seq_{64,128,192,256}`, `sma_select_switch_default` →
`set_mario_action_ge`, `…_switch_scrut`, `…_switch_cases`,
`…_seq_{64,128,192,256}`, `…_select_switch_default`.

Other declaration names (e.g. `Act`/`cflying`/`cstep` in `ReachableRun.v`) were
left as-is: they are small, file-local helpers whose meaning is clear in context.

## 4. For future agents

- To find a file by its *old* name, use the table above or `find proofs -name '<New>.v'`.
- The build is driven by `_CoqProject` (paths) → `coq_makefile`. After moving or
  renaming a `.v` file, **delete stale build artifacts** before rebuilding —
  `find proofs -type f ! -name '*.v' -delete` — otherwise `coqdep` resolves
  `Require` against an orphaned `.glob`/`.vos` at the old path and the build fails
  with a misleading "No rule to make target …".
- See [`../proofs/README.md`](../proofs/README.md) for the layer descriptions and
  the dependency graph.
