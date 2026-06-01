# Status & next steps — the chase-store capstone engine (2026-06-01, part 2)

Picks up from `docs/2026-06-01-status-and-next-steps.md`. That doc ended with the
engine for the per-frame "no-A ⇒ no-fly" store argument identified but not built.
**This session built it.** Master is green at `5fd6571`; everything below is
machine-checked and axiom-clean (CompCert classical/Events base only — none of
VST's `prop_ext`/`eq_rect_eq`).

---

## 0. The one-paragraph recap of the whole project

Prove (Rocq 8.19.2 + CompCert 3.15) that finishing SM64's "Wing Mario over the
Rainbow" **requires pressing A** (flight = `ACT_FLYING`, only reachable via A).
The honest theorem is conditional on no-A ∧ no-spawn-flying. The hard core is the
**per-frame store argument**: every function the game runs each frame must be shown
not to write a flying value into Mario's `action` field. The functions that write
through *loaded pointers* ("chase stores") are the difficult subset — this session
made them tractable in bulk.

---

## 1. What this session delivered (the chase-store capstone engine)

The wall was `ActionValueFrame.assign_value_ok`'s `forall le`: a chase store
`p->...` lands wherever temp `p` points, and under an arbitrary temp env `p` could
point *into* Mario's block. Broken by threading a **temp-environment invariant**.

### New files (all in `proofs/`, all in `_CoqProject`)

- **`ArrayStore.v`** (commits `bf3b856`, `78f2d75`) — the array-element store
  inverter, the last un-cracked lvalue shape. `exec_marioState_tfloatarr_store`
  inverts any `m->fid[n] = rhs` to an `assign_loc` at `(bm, field_offset+4n)`.
  Cracked the genv/`vm_compute` hang (the recipe is in the file header).

- **`ChaseList.v`** (commit `78c73db`) — the **machine-checked NAMED enumeration of
  the 111 chase functions**, per TU, proven `= chase_funcs <TU>.prog` of the real
  compiled program (`vm_compute; reflexivity`), plus the `all_<TU>` lists naming all
  435 internal functions. Two connectors: `chase_nonchase_complete` (axiom-free:
  chase + nonchase = 435, nothing hidden) and `body_preserves_action_sat`
  (specialises the value capstone to a function body — meaningfulness).

- **`ValueFrameINV.v`** (commits `529af88`, `be965b4`, `ff672fd`, `5fd6571`) — the
  engine. `tmps_off_bm bm mid le := ∀ t b o, t<>mid → le!t = Some(Vptr b o) → b<>bm`
  ("every temp except the Mario pointer `_m` points off Mario's block `bm`").
  - `tmps_off_bm_set` (axiom-free): invariant survives a tempvar update if the new
    pointer is off-bm/scalar.
  - `exec_field_ptr_load`: GENERIC pointer-field load inverter (any field/temp/
    result-type/symbolic-offset+bound), generalising `exec_bodystate_load`.
  - `field_loads_off_bm` (the per-field anti-aliasing clause) + `tmps_off_bm_set_field`
    (generic establishment: any chase-load `tid = m->fid` re-creates the invariant).
  - `chase_store_preserves_tmps` (single-Efield) and **`rooted_store_nf`** (general,
    any accessor depth, SELF-CONTAINED — see below).

- **`RootedLvalue.v`** (commits `91b8dd9`, `5fd6571`) — genv-GENERIC (works for every
  TU). The deep chases (`o->header.gfx.pos[i]`, `t->throwMatrix[i][j]`) are *rooted*
  at a temp via block-preserving accessors.
  - `rooted_rv`/`rooted_lv`: syntactic "rooted at temp p" predicates (Efield/Ederef
    on an aggregate; Ebinop Oadd with a ptr/array left operand).
  - **`rooted_block`** (mutual induction over `eval_expr`/`eval_lvalue`): a rooted
    rvalue evaluates to a `Vptr` in p's block; a rooted lvalue's location is in it.
  - `rooted_root_exists` / `rooted_lv_root_value`: the root temp of an executing
    rooted lvalue IS a `Vptr` in memory (so `le!p` is extractable from the exec).
  - helpers: `deref_loc_aggregate_inv`, `sem_add_l_ptr`, `sem_add_l_implies_l_ptr`.

- **`ChaseDischarge.v`** (commit `7902186`) — the **scoreboard**. `reset_bodystate_
  is_one_of_the_111` (machine-checked `In _ (chase_funcs mario.prog)`) +
  `reset_bodystate_preserves_nonflying` (the real `f_mario_reset_bodystate` body).

### The headline lemma to reuse

```
ValueFrameINV.rooted_store_nf :
  tmps_off_bm bm mario._m le → p <> mario._m → rooted_lv p lhs = true →
  Mem.valid_block m bm → action_sat Q m bm →
  exec_stmt function_entry2 mario_ge e le m (Sassign lhs rhs) t le' m' out →
  le' = le ∧ out = Out_normal ∧ Mem.valid_block m' bm ∧ action_sat Q m' bm.
```
Any chase store, any nesting depth, preserves non-flying — needing only the
invariant + the store. This is the chase-Sassign case of the assembly.

---

## 2. The scoreboard

**1 / 111** formally discharged on real code: `mario_reset_bodystate`
(`ChaseDischarge.reset_bodystate_preserves_nonflying`, machine-checked as a member
of the 111). The engine now handles **every chase-store shape**; the count is gated
on the assembly (next section), not on any remaining semantic difficulty.

The 111 named functions live in `ChaseList.v`. The **real unit of remaining work is
the chased FIELD**, not the function: `mario.c`'s 12 distinct pointer fields cover
its 14 chase functions — `marioObj`(51), `floor`(27), `area`(19), `controller`(7),
`marioBodyState`(5, done), `animList`(5), `statusForCamera`(4), `heldObj`(4),
`ceil`(3), + 3 singletons.

---

## 3. WHAT'S NEXT — the statement-level frame (the assembly)

This is the single thing between "engine done" and the scoreboard climbing. Build
`proofs/ValueFrameStmt.v` (a draft was started and removed — it had holes the
now-committed lemmas fill). Goal:

```
exec_body_nf : exec_stmt .. mario_ge e le m s t le' m' out →
  Mem.valid_block m bm → action_sat Q m bm → tmps_off_bm bm mario._m le →
  MemWF FS m bm → body_ok FS Q bm e s →
  Mem.valid_block m' bm ∧ action_sat Q m' bm ∧ tmps_off_bm bm mario._m le' ∧ MemWF FS m' bm.
```
by induction on `exec_stmt`, threading the 4-part bundle.

- `MemWF FS m bm := ∀ fid ∈ FS, field_loads_off_bm m bm fid` (the chased pointer
  fields all load off-bm).
- `body_ok` (per-statement obligation, a `Fixpoint → Prop`): `Sassign a1 a2` →
  `(∃ p, p<>_m ∧ rooted_lv p a1 = true) ∨ assign_value_ok Q bm mario_ge e a1 a2`;
  `Sset id a` → `set_keeps` (the rhs keeps `tmps_off_bm`); `Ssequence` → ∧;
  control flow → recurse; `_ → False` (unsupported bodies don't qualify yet).

### Cases that DROP IN from what's committed
- **chase-Sassign**: `rooted_store_nf` gives action_sat + le'=le + valid. The store
  is off-bm, so `assign_loc_unchanged_on (fun b _ => b = bm)` (in `ActionFrame`)
  shows the whole `bm` block is unchanged → `MemWF` preserved (loads at bm
  unchanged) and `action_sat` preserved, all at once. (The drafted-then-removed
  helpers `MemWF_unchanged` and `action_sat_unchanged_bm` re-derive in ~6 lines each.)
- **Sset**: m unchanged → action_sat/MemWF/valid trivially preserved; `tmps_off_bm`
  preserved by `tmps_off_bm_set` fed by `set_keeps`.
- **Ssequence / Sreturn / Sskip / Sbreak / Scontinue**: structural threading.

### The TWO genuine remaining complications
1. **MemWF across a DIRECT scalar store** (`m->squishTimer = ..`): needs the store's
   offset disjoint from the chased pointer-field offsets (`Mem.load_store_other`,
   same block, concrete offsets). Fold an offset-disjointness side-condition into the
   direct disjunct of `body_ok`, or prove it per field.
2. **Scall / control flow**: `Scall` changes `m` via the callee — needs a reach-style
   assumption that the callee preserves `MemWF` (and the existing
   `reach_value_preserves` for `action_sat`); the return temp must keep `tmps_off_bm`
   (return value off-bm/scalar, or no return temp). `Sif`/`Sloop`/`Sswitch` are
   structural but multiply the bundle-threading boilerplate.

### Suggested staging
1. First a **straight-line frame** (Sseq/Sset/Sassign/returns; control flow & calls
   → `False` in `body_ok`). Validate by **re-proving `mario_reset_bodystate` through
   the frame** (it's straight-line: 5 chase stores + 1 direct flags store) — that
   exercises both the chase path and the one direct-store complication, on real code.
2. Then extend `body_ok` to `Sifthenelse`/`Sloop`/`Sswitch` (structural).
3. Then `Scall` with the callee `MemWF`/`action_sat` assumptions.
4. Then **walk the 111**: per function, supply `field_loads_off_bm` for its chased
   fields (12 clauses cover `mario.c`) and apply the frame. Each becomes short.

---

## 4. Honest gaps unchanged from part-1 doc
- `field_loads_off_bm` instances beyond `marioBodyState` (the anti-aliasing
  assumptions for `marioObj`/`floor`/`area`/… — mechanical, same shape).
- Other TUs (`mario_actions_*`): the engine (`rooted_*`) is genv-generic, but the
  establishment lemmas are `mario_ce`-specific; each TU needs its own field clauses.
- Bucket C / R3 temporal closure (the jump→flight chain needs A) — untouched, still
  the hardest *intellectual* frontier (§5e of part-1 doc).
- Model faithfulness, cross-TU linking, WMotR object-table extraction — unchanged.

---

## 5. Battle scars from this session (save hours)
- **NEVER `vm_compute` near `genv_cenv mario_ge`** — OOM/hang. Reduce pointer
  arithmetic with scoped `cbn [sizeof tfloat ..]` (cenv stays opaque) and discharge
  `classify_add` by a TYPE-ONLY `reflexivity`.
- `eval_expr` inversion on `Ebinop`/`Econst_int` leaves a SPURIOUS `eval_Elvalue`
  branch (bogus `eval_lvalue` on a non-lvalue) → kill with `solve [inv Hl]`.
- struct-base `deref_loc` is By_copy; discharge its spurious By_value/By_reference
  branches with TARGETED `discriminate H` on the access_mode hyp — bare
  `discriminate` scans the heavy `field_offset` eq and HANGS.
- the struct-base block/offset pin needs a TWO-hyp match (eval-derived `Vptr l o`
  AND entry `Vptr bm zero`) so `subst` binds `l/o`, not `bm`.
- in `rooted_block`'s mutual induction, the `eval_lvalue` (P0) cases close with
  `congruence` (NOT `inv Heq; exact Hb` — `inv` leaves `loc=blk` unsubstituted); the
  IH starts `rooted_rv .. ->` so `specialize` it before use; dispatch cases via
  `apply eval_expr_lvalue_ind; intros` then per-case `match goal`, killing vacuous
  via `solve [simpl in *; discriminate]`.
- `sem_add_ptr_int` with a `Vint` left operand can yield a `Vint` (32-bit ptr) — the
  helper case-splits `v2` and `Archi.ptr64` to discriminate.
- `_CoqProject` order matters: `RootedLvalue.v` before `ValueFrameINV.v` before
  `ChaseDischarge.v`.

---

## 6. Commit index (this session, on top of `9ff173b`)
```
bf3b856 ArrayStore.v: crack the array-element store inverter (last un-cracked lvalue)
78f2d75 ArrayStore.v: generalize to arbitrary field + index
78c73db ChaseList.v: NAMED enumeration of the 111 + completeness/meaningfulness connectors
529af88 ValueFrameINV.v: capstone engine -- tmps_off_bm + chase store
be965b4 ValueFrameINV.v: generic field-load inverter + establishment
7902186 ChaseDischarge.v: scoreboard, 1/111 on real code, machine-checked membership
91b8dd9 RootedLvalue.v: general rooted-at-temp store inverter (any depth, genv-generic)
ff672fd ValueFrameINV.v: rooted_store_preserves_tmps (general chase store)
5fd6571 RootedLvalue+ValueFrameINV: root-existence -> self-contained rooted_store_nf
```
All green; `bash pipeline/build.sh proofs` RC=0. Memory `proof-spine-architecture`
is updated to match.
