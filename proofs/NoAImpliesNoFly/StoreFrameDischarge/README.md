# `StoreFrameDischarge/` — GOAL-1 sub-goal

Sub-goal: **every reached internal function preserves the non-flying action
invariant** (the interprocedural store-frame machinery). Sub-capstone:
`PointerChaseDischarge.v`, which ties the generic engine to the named handlers.

Per `docs/`, the 111-handler scoreboard is *not* the intended critical path — a
single generic store-frame bridge is meant to replace it; what's here is the
interim/brute-force discharge.

- The `.v` files in this dir are on the sub-capstone's spine (the engine +
  per-handler proofs + `PointerChaseDischarge`).
- `Unwired/` holds pieces proved but not yet reached from `PointerChaseDischarge`
  (`ArrayStore`, `PointerChaseList`).

This is GOAL 1's `Unwired/` ball, themed; see `../../README.md` for the whole tree.
