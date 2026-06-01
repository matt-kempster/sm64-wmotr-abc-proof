# Status — the statement-level bundle frame is assembled (2026-06-01, part 3)

Picks up from `docs/2026-06-01-capstone-engine-and-chase-status.md` §3 ("WHAT'S
NEXT — the statement-level frame"). **That frame is now built.** Master is green;
`bash pipeline/build.sh proofs` RC=0; everything below is axiom-clean (CompCert
classical/Events base only).

---

## What this session delivered — `proofs/ValueFrameStmt.v`

The chase engine (ValueFrameINV / RootedLvalue) made individual chase stores
tractable; the missing piece was an induction that threads the temp-provenance
invariant THROUGH a whole function body. Built in three commits:

1. **`533409b` — the keystone.** `rooted_store_unchanged_bm`: a chase store
   (lvalue rooted at a non-Mario temp) leaves Mario's WHOLE block `bm` unchanged
   (`Mem.unchanged_on (fun b _ => b = bm)`), because it lands in the root temp's
   block, which `tmps_off_bm` puts off `bm`. From that one fact:
   `unchanged_bm_preserves_{action_sat,mem_wf}` + `chase_store_preserves_bundle`
   (the whole 4-part bundle survives a chase store). New def `mem_wf FS m bm` =
   "every chased pointer field in FS loads off-bm in m".

2. **`9b5452b` — `exec_body_nf`, the frame.** A fresh induction over `exec_stmt`
   threading the bundle `fr FS Q bm m le` =
   `valid ∧ action_sat Q ∧ tmps_off_bm ∧ mem_wf FS ∧ le!_m = Vptr bm 0`
   forward through a body, consuming a per-statement obligation `body_nf_ok`:
   - **Sassign**: chase (`∃p≠_m, rooted_lv p a1`) — off-bm, whole block unchanged;
     OR direct/other — `assign_avoids (watch FS bm)` where `watch` = the action
     cell ∪ the chased-field load ranges, so ONE avoidance clause preserves
     action_sat AND mem_wf at once.
   - **Sset**: `id ≠ _m ∧ set_off_bm_ok` (the rhs keeps tmps_off_bm).
   - **Scall**: result temp ≠ _m; everything else via `reach_frame_preserves`
     (the honest call boundary — callee preserves valid/action_sat/mem_wf and
     returns off-bm; to be discharged later by the whole-program closure).
   - **Sif/Sloop/Sswitch/Sseq**: structural (mirrors
     `ActionValueFrame.exec_stmt_value_preserves`). **Sbuiltin**: deferred (False).

3. **`9bec4e5` — the discharge toolkit.** `set_off_bm_ok_chase_load`
   (a chase-load `tid = m->fid`, fid∈FS, re-establishes tmps_off_bm via mem_wf)
   and `set_off_bm_ok_tempcopy` (a pointer copy `tid = q`, q≠_m). These discharge
   the pointer-producing Ssets clightgen emits.

The frame is the value analogue of `exec_stmt_value_preserves`, but threads the
temp invariant at RUNTIME — so the chase-store case is dischargeable where the
abstract `forall le` `stmt_value_ok` was not. This is exactly the wall the whole
chase engine was built to break, now broken at the statement level.

---

## The scoreboard — still 1/111 on real code, but the frame is the lever

No new function discharged THROUGH the frame yet. Two concrete obstacles remain
between `exec_body_nf` and the count climbing (these are the real next work):

### Obstacle 1 — the direct-store `assign_avoids (watch)` discharge
The `body_nf_ok` direct-store disjunct is `assign_avoids (watch FS bm) mario_ge e
a1`. To discharge it for a concrete `m->fid = rhs` one must invert the `Efield/
Ederef/Etempvar` lvalue chain to pin `loc = bm` and the offset, then show the
byte range misses the action cell [12,16) AND every chased field's load range —
`lia` over concrete offsets. The inversion is exactly `exec_marioState_field_
store`'s sequence but at `eval_lvalue` level. **Next brick:** a reusable
`assign_avoids_direct_field` lemma (one inversion, parameterised by fid/offset),
so each direct store discharges by `vm_compute` + `lia`.

### Obstacle 2 — word-sized scalar loads (the genuine wrinkle)
`set_off_bm_ok` is provable for chase-loads and pointer copies, and for SUB-word
scalar loads (`tuchar`/`tshort` → `Mint8`/`Mint16`, whose `load_result` can never
be a `Vptr`). It is NOT provable for a WORD-sized scalar load like
`t'1 = m->flags` (`tuint` → `Mint32`): in the 32-bit build `Val.load_result
Mint32 (Vptr ..) = Vptr ..`, so from `mem_wf` alone one cannot rule out `t'1`
being a `bm`-pointer. In reality `flags` holds an int, but proving it needs a
value-typing invariant on memory.

**The clean fix (a design decision for next session):** the blanket
`tmps_off_bm` over ALL temps is stronger than needed — `t'1` is never a chase
ROOT (it feeds scalar ops, and the subsequent `m->flags = t'1 & ~64` is a direct
store at `_m`, not a chase rooted at `t'1`). Options:
  (a) restrict `tmps_off_bm` to pointer-typed / chase-tainted temps;
  (b) add a lightweight memory value-typing invariant (scalar fields hold ints);
  (c) make `set_off_bm_ok` for a word load satisfiable when the loaded chunk is
      stored-int by a carried invariant.
Option (a) is the least invasive and the recommended route.

---

## Suggested next steps (in order)
1. **Obstacle 1**: `assign_avoids_direct_field` (mechanical inversion + lia).
2. **Obstacle 2**: pick option (a) — weaken `tmps_off_bm`/`set_off_bm_ok` so
   word scalar loads into never-rooted temps are free.
3. **Validate**: re-prove `mario_reset_bodystate` through `exec_body_nf`
   (call-free; needs a `call_free` variant of the frame OR a vacuous
   `reach_frame_preserves` — note: a call-free function still needs SOME proof of
   the reach hyp, so add `exec_body_nf_callfree` taking `call_free_s s = true`).
4. **Climb**: discharge a new chase function (e.g. `set_mario_animation`)
   CONDITIONALLY on `reach_frame_preserves` — honest and realistic, since real
   functions call out.

---

## Battle scars from this session
- `PTree.gso` wants the inequality as `key_lookedup <> key_set`; flip with
  `congruence`.
- `eapply Htmps` (where Htmps : `∀ t b o, ...`) leaves the offset `o` as a
  metavariable → `congruence`/`assumption` then can't close. Use
  `apply (Htmps q b o)` with explicit args.
- Inverting `eval_expr (Etempvar ..)` leaves a SPURIOUS `eval_Elvalue` case with
  an impossible `eval_lvalue (Etempvar ..)` hyp that `inversion` does NOT
  auto-refute — kill it with `try (match .. eval_lvalue .. (Etempvar _ _) .. =>
  solve [inv Hlv])`.
- Packaging the 5-part invariant as one `fr` Definition makes the structural IH
  applications trivial (`exact (IH2 (IH1 Hfr Hok1) Hok2)`) — destructure `fr`
  only in the leaf cases that need the components.

## Commit index (this session, on top of `56cf3d5`)
```
533409b ValueFrameStmt.v: stage 1a -- chase store leaves Mario's block bm unchanged
9b5452b ValueFrameStmt.v: exec_body_nf -- the statement-level bundle frame
9bec4e5 ValueFrameStmt.v: per-function discharge toolkit for the Sset obligation
```
