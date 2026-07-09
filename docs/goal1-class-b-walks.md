# GOAL-1 class-B walks — findings (task #96)

Scope: the two class-B "mislabeled external" bodies flagged in
`docs/goal1-hypothesis-consistency-audit.md` §2 as the biggest walk debt —
`init_bully_collision_data` and `transfer_bully_speed`. Both are **Internal in
`mario_step.prog`** (a linked TU), so the capstone rows that call them
"terminal externals" (`NoAImpliesNoFlyLinked.v:1656–1672`, comment) are wrong on
the trust ledger. Task #96 set out to walk them like the #95 `vec3f_find_ceil`
repair (`RestSurface.vfc_pres`).

**Verdict: both rows as stated are PHANTOM-FALSE. Neither can be walked. No .v
file was edited (per the task's phantom-false protocol: document and stop).**

The #95 template does **not** transfer: `vec3f_find_ceil`'s only memory effects
are an `fn_var` alloc/free plus two *pure loads* through its `float*` param and
one call to still-external `find_ceil` — it **never stores through a param
pointer**, so its bare `call_pres_ext` (∀ `vargs`) is true. The bully bodies
store **exclusively through their pointer params**, and the bare
`call_pres_ext` drops the call-site gate that keeps those pointers off Mario's
block. That is the whole difference.

---

## 0. The rows and their exact statement

`NoAImpliesNoFlyLinked.v:1667–1672`:

```
Hypothesis Hcpx_ibcd_real :
  call_pres_ext lp bm (NoA_real bm) MWF interaction._init_bully_collision_data.
Hypothesis Hcpx_tbs_real :
  call_pres_ext lp bm (NoA_real bm) MWF interaction._transfer_bully_speed.
```

`call_pres_ext` (`FloorsSurface.v:242`) unfolds to:

```
forall fd m0 vargs0 t0 m1 vres0,
  eval_funcall function_entry2 (lp_ge lp) m0 fd vargs0 t0 m1 vres0 ->
  resolves_lp lp fid fd ->
  NoA_real bm m0 -> MWF m0 -> Mem.valid_block m0 bm -> action_sat not_tainted m0 bm ->
  Mem.valid_block m1 bm /\ action_sat not_tainted m1 bm /\ MWF m1 /\ NoA_real bm m1.
```

Key predicates:
* `action_sat not_tainted m bm := forall v, Mem.load Mint32 m bm 12 = Some (Vint v) -> is_tainted v = false`
  (`ActionValueFrame.v:46`, `Taint.v:65,69`). Offset 12 is `MarioState.action`
  (composite order: `unk00`@0, `input`@2, `flags`@4, `particleFlags`@8,
  **`action`@12**).
* `NoA_real bm m := ctl_a_clear m bm` (`NoAImpliesNoFlyLinked.v:277`) — the
  controller A-bit, unrelated to these bodies.
* `MWF_real` (`MWFReal.v:190`) is `R0` (block-validity, monotone) ∧ `R1..R9`,
  **every one of `R1..R9` a load-shape-conditional implication** (e.g. R6:
  *if* `loadv Mptr (bm, chase_root)` *is* `Some (Vptr b' o')` *then* `SafeB b'`).
  The only rows keyed to an integer cell are R1 (`input`@2), R3
  (`Controller.buttonPressed`@`oc0+18` in block `bc`), R4 (`action`@12).

The decisive consequence of the conditional shape: **clobbering any Mario cell
to a non-pointer value never breaks `R2/R5/R6/R7/R8/R9`** — the store of a
`Mfloat32` value produces `inj_bytes` (or `Undef`), so a subsequent `Mptr` load
decodes to `Vint`/`Vundef`, the row's `= Some (Vptr …)` antecedent goes false,
and the implication holds vacuously. A clean refutation therefore has to land a
*non-pointer store on an integer-checked cell* — `action`@12 (kills
`action_sat` and R4) or `buttonPressed`@`oc0+18` (kills R3).

---

## 1. `init_bully_collision_data` — PHANTOM-FALSE (airtight, no MWF dependency)

AST: `generated/mario_step.v:736` (`f_init_bully_collision_data`).
`fn_vars := nil`. Every memory write is `Sassign (Efield (Ederef (Etempvar
_data …)) …) …` — i.e. **through arg0 `_data : BullyCollisionData*`**. Field
offsets (BullyCollisionData = 6× `tfloat`): `conversionRatio`@0, `radius`@4,
`posX`@8, **`posZ`@12**, `velX`@16, `velZ`@20. Store order (mario_step.v:761–817):
radius(4), conversionRatio(0), posX(8), **posZ(12)**, velX(16), velZ(20). Nothing
after the posZ store touches offset 12.

**Store classification:** 6 stores, all through `_data` (arg0). `posZ` lands at
struct offset 12.

**Refutation witness.** Instantiate `call_pres_ext` with
`vargs0 = [Vptr bm Ptrofs.zero ; posX ; posZ ; forwardVel ; yaw ; convRatio ; radius]`
where `posZ = Vsingle (Float32.of_bits ACT_SHOT_FROM_CANNON)` (any `is_flying_int`
works too; `ACT_SHOT_FROM_CANNON = Int.repr 8915096`, `Taint.v:63`), and `m0` any
memory satisfying the four premises with `gSineTable` initialised (e.g. a real
reachable pre-`interact_bully` memory; the sine reads only feed the velX/velZ
stores at offsets 16/20 and are irrelevant to the kill — take `yaw = 0`).

* Premises hold: `_data = (bm,0)` and `bm` is Mario's valid, writable block, so
  `eval_funcall` runs to completion; `resolves_lp` holds via `LO_stp`
  (`mario_step.prog` linked); `NoA_real`/`MWF`/`valid_block`/`action_sat` are on
  `m0`, untouched by choosing adversarial `vargs`.
* The `posZ` store writes `Mfloat32` at `(bm,12)`. `Mem.load Mint32 m1 bm 12`
  `= decode_val Mint32 (encode_val Mfloat32 (Vsingle f))`. `encode_val Mfloat32`
  is `inj_bytes` (pure bytes, **no `Fragment`s**), so
  `decode_val Mint32 = Vint (Float32.to_bits f) = Vint ACT_SHOT_FROM_CANNON`
  (`Float32.to_of_bits`).
* Then `action_sat not_tainted m1 bm` requires `is_tainted ACT_SHOT_FROM_CANNON
  = false`, but it is `true`. **Conclusion false, premises true ⇒ the row is not
  a theorem.**

This kill needs nothing from `MWF_real` — it hits `action_sat` directly, and it
needs no offset arithmetic (`_data = (bm,0)` is enough because `posZ`'s struct
offset already equals `action`'s offset).

---

## 2. `transfer_bully_speed` — PHANTOM-FALSE (via R3 / the ungated-pointer defect)

AST: `generated/mario_step.v:527` (`f_transfer_bully_speed`, ~208 L).
`fn_vars := nil`. Reads many fields of `_obj1`/`_obj2` (both
`BullyCollisionData*`, arg0/arg1); the only **stores** are 4× `Sassign` through
those params: `_obj2->velX`(16), `_obj2->velZ`(20), `_obj1->velX`(16),
`_obj1->velZ`(20). So writes hit struct offsets **16 and 20** only.

**Why the clean `init`-style kill does not apply, and why it is still false.**
Struct offsets 16/20 map, under `_obj = (bm,0)`, to `MarioState.prevAction`(16)
and `terrainSoundAddend`(20) — *not* `action`(12), and *not* constrained by any
`MWF_real` conjunct. To land a write on `action`@12 you would need base
`k = 12-16 = -4` (or `-8`), which underflows the struct's own offset-0 read
(`(bm,-4)` is out of `bm`'s bounds ⇒ the load fails ⇒ `eval_funcall` gets stuck
⇒ not a witness). So `transfer_bully_speed` **cannot** reach `action`@12 or
`input`@2 in any *successful* run, and the `init`-style `action_sat` kill is
unavailable.

It is nonetheless not a theorem, because `call_pres_ext` also quantifies over
pointer args aliasing **other** blocks the premises fix. Refutation witness on
R3 (the controller `buttonPressed` cell): take
`_obj1 = Vptr bc (Ptrofs.repr (oc0 + 2))`, `_obj2 = ` any writable
BullyCollisionData-sized block. Then `_obj1->velX` (struct offset 16) writes
`Mfloat32` at `(bc, oc0 + 18)` = `Controller.buttonPressed`, whose value is
`t'3 + …` with all summands traceable to adversary-controlled `_obj2` fields, so
the stored 32 bits are adversary-chosen. `MWF_real` R3 (`MWFReal.v:215`) requires
`Mem.load Mint16unsigned m bc (oc0+18)` to have the `0x8000` (A-button) bit
clear; choosing the low halfword of the stored float with bit 15 set makes
`Int.and v 32768 = 32768 ≠ 0`. **R3 false ⇒ `MWF m1` false ⇒ the row is not a
theorem.** (This witness is realisable exactly when `bc` is writable at
`[oc0+18, oc0+22)` and the `Controller` struct spans `oc0+22`; both hold for the
real controller global. Even if one wished to contest those permissions, the
row still fails structurally — see §3 — so the verdict does not rest on this
single witness.)

---

## 3. Root cause (both rows) and the honest repair

Both bodies' entire memory footprint is *stores through a `BullyCollisionData*`
param*, and `BullyCollisionData` is **not** `MarioState`. The bare
`call_pres_ext`'s `forall vargs0` therefore admits `vargs0` in which that param
**aliases Mario's block `bm`** (or the controller block `bc`) — cases the real
program never produces. `interact_bully` (`generated/interaction.v:2874`) always
passes `Eaddrof (Evar _marioData)` / `Eaddrof (Evar _bullyData)`, and
`_marioData`/`_bullyData` are its own `fn_vars` — **fresh stack blocks, provably
`bm`-disjoint** (this is exactly what `BullySurface.bkbm_row`'s alloc bookkeeping
establishes; comment at `BullySurface.v:1023` "fresh, bm-disjoint"). The consumer
only ever needs the row at that fresh, disjoint instance.

So the honest form of both rows is a **gated** `call_pres_ext` — the pointer
arg confined to a fresh / `SafeB` block `≠ bm` (`≠ bc`), i.e. the `ob`/`SafeB`
call-site class already used elsewhere in the ob-arc. The current bare rows are
**latent phantom-false assumptions** — the critical class: `Hcpra_bkbm_real`
(and everything above it on the capstone, up through the `interact_*` family)
rests on hypotheses that are *false as written*. Per the task's protocol these
rows were **not** weakened or restated here; the restatement (adding the
fresh-block gate) is the follow-up fix, and it must be designed so `bkbm_row`
supplies the gate from its alloc bookkeeping.

---

## 4. Do the other 7 class-B bodies share this pattern? No.

The bully pair is special: a **non-Mario struct pointer** param, **stored
through**, left **ungated**. The other §2 rows differ:

* `load_level_init_text` (arg0 `tuint`) and `bhv_spawn_star_no_level_exit`
  (arg0 `tuint`) take **no pointer param** — `forall vargs` cannot alias `bm`,
  so their bare `call_pres_ext` has no phantom. Ordinary walk debt.
* `play_mario_heavy_landing_sound`, `play_mario_heavy_landing_sound_once`,
  `play_mario_landing_sound`, `play_mario_landing_sound_once`,
  `play_sound_if_no_flag` take arg0 `MarioState*`. Here the row's fixed `bm`
  **is** the intended target: the real caller passes Mario's own pointer, so
  "param aliases `bm`" is the *real* case, not an adversarial one. If (as the
  audit expects) these sound helpers perform no store into `action`/the pinned
  cells, their bare `call_pres_ext` is *true* and walkable — a normal class-B
  walk, not a phantom. (Each still needs the walk to *confirm* "writes no Mario
  state"; that is honest owed work, not a latent falsehood.)

Bottom line: the phantom-false defect is **unique to the two bully bodies**
among the class-B set, precisely because they store through a pointer param that
is neither `MarioState*` (so `bm` is not its intended target) nor gated (so the
adversary may point it at `bm`/`bc`). The remaining 7 are genuine walk debt and
can be discharged with the #95-style approach (adjusted for the `MarioState*`
callees, which are walked, not kept external).

---

## 5. Second batch (task #96 cont'd): `load_level_init_text` WALKED; `bhv_spawn_star_no_level_exit` is a NEW store-through-return phantom

### 5.1 `load_level_init_text` — WALKED (DONE)

`StationaryLeafSurface.llit_row` now proves
`call_pres_ext lp bm NoA MWF level_update._load_level_init_text` for the real
body (`generated/level_update.v:2389`), replacing the old `Hpres_sta_ext`
boundary trust. Mechanism (generic non-Mario-param walker
`call_pres_ext_of_wwalk` + `wwalk_chk` decision procedure):

* arg0 `tuint`, `fn_vars = nil`, **no `Sassign` of its own** — the body only
  writes temps and calls four functions: `save_file_get_flags`,
  `save_file_get_star_flags` (genuine save-buffer readers, external in every
  TU), `create_dialog_box` (genuine external), and **`level_set_transition`**
  (Internal in `level_update.prog`, a one-level cascade).
* `level_set_transition` is walked in the same file as `sta_lst_row` (the twin
  of the already-proved `CutsceneLeafSurface.lst_row`): its only effects are two
  stores into the bm-disjoint statics `sTransitionTimer` / `sTransitionUpdate`
  (both in `stored_globals`), no callees. `wwalk_chk` accepts it.
* the three genuine externals are supplied at the capstone from **existing**
  boundaries — `save_file_get_flags` / `save_file_get_star_flags` via
  `Hpres_obj_ext` (the latter newly added to `obj_ext_ids`, same save-reader
  class), `create_dialog_box` via `Hpres_cut_ext` — and `LO_lvl` was already a
  capstone term. **The `real_mwf` capstone signature is UNCHANGED (zero new
  capstone hypothesis); Twelve is untouched.** Net trust-ledger change: one
  mislabeled-Internal boundary id (`load_level_init_text`) plus its hidden
  Internal glob-setter (`level_set_transition`) move from *trusted-external* to
  *walked*, bottoming out in three genuine externals (one newly surfaced).

The audit's "no pointer param ⇒ ordinary walk debt" call was correct; the only
wrinkle it missed is the one-level internal cascade into `level_set_transition`,
which is bounded (that body has no callees).

### 5.2 `bhv_spawn_star_no_level_exit` — PHANTOM (store through an EXTERNAL's return), NOT walkable

The audit's "no pointer param ⇒ no phantom" call is **WRONG** for this body, and
`wwalk_chk` **rejects** it (mechanically verified). AST
`generated/behavior_actions.v:21423`: arg0 `tuint`, `fn_vars = nil`, but the
body does `_t'1 := spawn_object(gCurrentObject, 122, &bhvSpawnedStarNoLevelExit)`
then `_star := _t'1` and **stores through `_star`**:
`_star->rawData.asS32[64] = starIndex << 24` and `_star->rawData.asU32[66] =
1024`, finally `obj_set_angle(_star, …)`.

`_star` is the **return value of the external `spawn_object`**. The abstract
`external_call` model does **not** pin that returned pointer off Mario's block
`bm` (nor the controller block `bc`), so the generic walker cannot classify the
store target as bm-safe and refuses the store (exactly the mechanism that made
the two bully bodies phantom-false, but via an external *return* rather than a
*param*). The bare `call_pres_ext bhv_spawn_star_no_level_exit` is therefore
another **latent phantom-false** boundary row: its `obj_ext_ids` comment ("the
pool is SafeB-disjoint from Mario's state") is precisely the unverified gate the
model does not supply.

**Verdict: NOT walked; no `.v` weakening.** The honest repair is the #97-style
GATED row — `spawn_object`'s return confined to a fresh / `SafeB` object-pool
block `≠ bm` (`≠ bc`) — supplied from the object-pool allocation bookkeeping.
This is the same class of defect as the bully pair, now known to also arise from
**external return values**, not only pointer params. (Left for a follow-up like
#97.)

### 5.3 The `play_mario_*_sound*` / `play_sound_if_no_flag` cluster (target #3) — SCOUTED in §6

Deferred here; the full store-level scout and the per-body verdict are in §6.

---

## 6. The `play_mario_*_sound*` / `play_sound_if_no_flag` cluster (task #96 target #3) — SCOUTED, then REPAIRED in #98

> **UPDATE (task #98, REPAIRED):** all five sound ids were REMOVED from
> `sta_ext_ids` / `mov_ext_ids` (director option 1 below, adopted) and are now
> WALKED as GATED `call_pres` (marg, arg0 = m) via each caller's `ids` arm.
> `ObjectLeafSurface` gained four reusable rows `pmls_row` / `pmhls_row` /
> `pmlso_row` / `pmhlso_row` (bottoming in the existing `psasp_row` / `pmas_row`,
> which route `play_sound` through the obj_ext boundary — NO new external trust).
> `Hpres_sta_ext` / `Hpres_mov_ext` are now TRUE-as-stated (the phantom `psinf`
> and the four landing helpers are gone from their scope). The cutscene
> `Hcpx_pmlso` (bare `call_pres_ext` = unverified marg-drop) was restated as the
> gated `Hcp_pmlso`, supplied at the `real*` capstone by `pmlso_row`. Every walk
> vm_computes and the six-target discipline audit is green. The scout below is
> retained as the record of the defect.

**Bottom line of the SCOUT (one airtight phantom + four unverified marg-drops; NO `.v` edited AT SCOUT TIME):**

* **`play_sound_if_no_flag` — PHANTOM-FALSE, airtight.** Its store `m->flags |= flags`
  ORs an **adversary-controlled** value, so the bare `call_pres_ext` lands a tainted
  action constant on `action`@12. It is in **both** `sta_ext_ids` **and** `mov_ext_ids`,
  so **both** capstone rows `Hpres_sta_ext` and `Hpres_mov_ext`
  (`NoAImpliesNoFlyLinked.v:823,862`) are **false as stated** — latent phantom-false,
  the critical class (same defect family as the bully pair §1–3).
* **`play_mario_landing_sound`, `play_mario_heavy_landing_sound`,
  `play_mario_landing_sound_once`, `play_mario_heavy_landing_sound_once` —
  UNVERIFIED marg-gate-drops, NOT provably phantom, NOT walkable-as-external.**
  They store nothing themselves but forward arg0 into the Internal m-writers
  `play_sound_and_spawn_particles` / `play_mario_action_sound`, whose stores are
  **fixed single-bit ORs** on bits `{8,12,14,15,16}` of `flags`@4 / `particleFlags`@8.
  A precise bit census (§6.3) shows those bits **cannot** taint `action`@12, and the
  wide-struct reads (`marioObj`, `terrainSoundAddend`) **overflow the small controller
  block**, killing the R3/`ctl_a_clear` alias — so **no airtight refutation exists**.
  These bare rows merely **drop the marg gate** the real program always supplies; the
  gated `call_pres` versions are already **proved** for two of them (`pmls_row`,
  `pmhls_row`). Left for a director-decided marg-gated repair (#97-style), **not** walked.

**No `.v` file was edited** (per the phantom-false protocol of §0–3). The
`play_sound_if_no_flag` row cannot be walked (it is not a theorem); the four landing
variants are not external-only (they route through Internal m-writers) so the
`vfc_pres` external-only template of §5.1 does not apply to them either.

### 6.0 Scope — the exact in-scope boundary ids

Only bodies covered by an **assumed** ext-row are in scope. Membership (positives are
shared across TUs, so the TU qualifier is cosmetic — all resolve to the single
`mario.prog` Internal body in `lp`):

| body (`mario.v`) | store census | boundary row(s) that assume it |
|---|---|---|
| `f_play_sound_if_no_flag`  (2126) | **1 store `m->flags`@4**, value `t'2 \| flags_arg` (**adversary** arg) | `sta_ext_ids`, `mov_ext_ids` → `Hpres_sta_ext`, `Hpres_mov_ext` |
| `f_play_mario_landing_sound`  (2562) | **0 own stores**; tail-calls `psasp(m,…)` | `mov_ext_ids` → `Hpres_mov_ext` |
| `f_play_mario_heavy_landing_sound` (2644) | **0 own stores**; tail-calls `psasp(m,…)` | `sta_ext_ids` → `Hpres_sta_ext` |
| `f_play_mario_landing_sound_once` (2603) | **0 own stores**; tail-calls `pmas(m,…)` | `mov_ext_ids` → `Hpres_mov_ext`; cutscene `Hcpx_pmlso` (`CutsceneLeafSurface.v:1454`) |
| `f_play_mario_heavy_landing_sound_once` (2685) | **0 own stores**; tail-calls `pmas(m,…)` | `mov_ext_ids` → `Hpres_mov_ext` |

Callees reached (Internal, `mario.prog`) and their stores:

* `f_play_mario_action_sound` (2523): calls `psasp(m,…)` then **1 store `m->flags`@4**,
  value `t'2 \| 65536` (bit 16, **const**).
* `f_play_sound_and_spawn_particles` (`psasp`, 2339): **stores `m->particleFlags`@8**,
  each value `t'k \| (1<<b)` for **const** `b ∈ {12,8,15,14}` (mario.v:2373,2385,2405,2425);
  then two `play_sound` externals. No `action`/`flags` store.

Out of scope (not in any ext_ids list — already walked as **gated** `call_pres`):
`play_mario_jump_sound` (`pmjs_row`), `play_mario_action_sound` (only reached as a
callee, not a boundary row), `play_mario_sound` (`air_pms_row`).

### 6.1 `play_sound_if_no_flag` — PHANTOM-FALSE (airtight)

AST `mario.v:2126`. `fn_vars = nil`. The single store (2167–2171):
`Sassign (Efield (Ederef (Etempvar _m) …) _flags tuint) (Oor t'2 flags)`,
guarded by `!(t'1 & flags)`, where `t'1 = t'2 = m->flags` and `flags` is **param arg2**.

**Refutation witness.** Instantiate the bare `call_pres_ext` (`FloorsSurface.v:242`,
`forall … vargs0 …`) with
`vargs0 = [Vptr bm (Ptrofs.repr 8); soundBits; Vint ACT_SHOT_FROM_CANNON]`
(`ACT_SHOT_FROM_CANNON = Int.repr 8915096`, `Taint.v:63`) and any `m0` meeting the four
premises with `action`@12 `= Vint Int.zero` (`0` is non-tainted, so `action_sat`/R4 hold)
and a valid `Object` placed at `(bm, 8 + off_marioObj)` (adversary's choice of `m0`;
the MWF `marioObj` chase root is pinned at `(bm, off_marioObj)` — a **different**
address — so no premise is violated).

* arg0 `= (bm, 8)` ⇒ `m->flags` (struct offset 4) is the cell `(bm, 12)` = **`action`**.
* Guard `!(t'1 & flags) = !(0 & T) = !(0)` ⇒ **true**, branch entered.
* `play_sound` runs (external; its arg `t'3->…cameraToObject` reads the placed Object).
* Store: `m->flags = t'2 | flags = 0 | T = T` at `(bm, 12)`; `T` is `Mint32`/non-pointer,
  so `Mem.load Mint32 m1 bm 12 = Vint T`.
* `action_sat not_tainted m1 bm` then demands `is_tainted T = false`, but
  `is_tainted ACT_SHOT_FROM_CANNON = true` (`Taint.v:66,83`). **Conclusion false,
  premises true ⇒ the row is not a theorem.** (Airtight, no MWF dependency — hits
  `action_sat` directly, exactly like §1.)

**Consequence for the capstone.** `play_sound_if_no_flag ∈ sta_ext_ids ∩ mov_ext_ids`,
so the universally-quantified capstone hypotheses
`Hpres_sta_ext : ∀ fid ∈ sta_ext_ids, call_pres_ext … fid` and its `mov` twin are each
**false** (they assert a false instance). GOAL-1's live `real*`/`linked12` capstones
rest on both. Latent phantom-false, critical class.

### 6.2 The four landing variants — UNVERIFIED marg-drops (no airtight refutation)

None stores `m` itself; each forwards its (adversarial) arg0 into `psasp` or `pmas`.
The `init`-style `action`@12 kill would need those forwarded stores to land a **tainted**
value on `(bm, 12)`. They cannot — see §6.3. The controller-block route (R3 /
`ctl_a_clear`, A-bit `0x8000`) also fails: to reach `psasp`/`pmas` the callee first
reads `m->marioObj` and `m->terrainSoundAddend` (offsets ≫ a `Controller`'s size), so
any `arg0 = (bc, oc0+k)` alias **overflows `bc`** on those loads and `eval_funcall`
gets stuck — not a witness (dual of the §2 underflow). And `input`@2 (R1, bit `0x2`)
needs a store bit `≡1 (mod 8)`, which `{8,12,14,15,16}` never are.

So these bare rows are **not demonstrably phantom** — plausibly true, but **unproven**:
they silently **drop the marg gate** (`arg0 = (bm,0)`) that every real caller supplies.
This is honest walk-debt of the "trusted-external that is really a gated-Internal body"
kind, **not** a proven falsehood. The gated `call_pres` versions are **already proved**
for `play_mario_landing_sound` (`AirborneLeafSurface.pmls_row`,
`CutsceneLeafSurface.pmls_row`, `StationaryLeafSurface.sta_pmls_row`,
`AutomaticLeafSurface`) and `play_mario_heavy_landing_sound`
(`AirborneLeafSurface`/`CutsceneLeafSurface.pmhls_row`); the two `_once` variants have
no gated walk yet (they route through `pmas`).

### 6.3 The taint-bit lemma (reproducible)

The taint set is the three constants (`Flying.v:53,54`, `Taint.v:63`) — note the
`0x10808899` **hex comment on `Flying.v:53` is a typo**; the real `Int.repr 277350553`
is `0x10880899`:

| constant | value | bits set |
|---|---|---|
| `ACT_FLYING` | `277350553` = `0x10880899` | 0,3,4,7,11,19,23,28 |
| `ACT_FLYING_TRIPLE_JUMP` | `50333844` = `0x03000894` | 2,4,7,11,24,25 |
| `ACT_SHOT_FROM_CANNON` | `8915096` = `0x00880898` | 3,4,7,11,19,23 |

Union of tainted bits = `{0,2,3,4,7,11,19,23,24,25,28}`. The const-OR store bits are
`{8,12,14,15,16}` (`psasp` `1<<{12,8,15,14}`, `pmas` `65536 = 1<<16`) — **disjoint**
from the union. Hence for every non-tainted `old`, `old | (1<<b)` (which forces bit
`b ∈ {8,12,14,15,16}` to `1`, but every tainted constant has bit `b = 0`) can **never**
equal a tainted constant. `action`@12 therefore survives every const-OR store.
(Check: `is_tainted (Int.or v (Int.repr 32768)) = false` etc. by `vm_compute` over the
three constants; big-endian ppc32 places bit `k` of a `Mint32` store at byte
`A + (3 - k/8)`, bit `k mod 8`, which is why the R3/R1 halfword A-bits — bit 31 / bit 9
of the stored word — are out of reach of bits `{8,12,14,15,16}`.)

### 6.4 Verdict table and director options

| id | store scout | verdict | `.v` action |
|---|---|---|---|
| `play_sound_if_no_flag` | `m->flags`@4, **adversary** value | **PHANTOM-FALSE (airtight)** | none — cannot be walked; makes `Hpres_{sta,mov}_ext` false |
| `play_mario_landing_sound` | →`psasp` `particleFlags`@8, const bits | **UNVERIFIED marg-drop** (gated `call_pres` proved) | none — director |
| `play_mario_heavy_landing_sound` | →`psasp` `particleFlags`@8, const bits | **UNVERIFIED marg-drop** (gated `call_pres` proved) | none — director |
| `play_mario_landing_sound_once` | →`pmas`→`psasp`, const bits | **UNVERIFIED marg-drop** (no gated walk yet) | none — director |
| `play_mario_heavy_landing_sound_once` | →`pmas`→`psasp`, const bits | **UNVERIFIED marg-drop** (no gated walk yet) | none — director |

**Director options for the honest repair (a #97-style arc, not done here):**

1. **Restate the sound boundaries as marg-gated `call_pres`** (arg0 pinned to `(bm,0)`)
   and discharge each call site with the marg gate the walked action bodies already
   carry — turning `Hpres_sta_ext`/`Hpres_mov_ext`/`Hcpx_pmlso` from
   (false / unverified) bare rows into proved gated ones. `play_mario_landing_sound`
   and `play_mario_heavy_landing_sound` can consume the **existing** `pmls_row`/`pmhls_row`
   directly; `play_sound_if_no_flag` and the two `_once` variants need fresh gated walks
   (all bottom out in `play_sound`/`psasp`, already-understood bodies).
2. Or keep them external **but move the ids off the "honest model-boundary" comment** —
   they are Internal `mario.prog` bodies that write Mario state, not pure externals; the
   current `mov_ext_ids`/`sta_ext_ids` comments ("pure audio externals … writes no Mario
   state") are **factually wrong** and must not be trusted as-is.

The `play_sound_if_no_flag` phantom is the priority: unlike the four landing variants
(possibly-sound), it is a **proven falsehood** sitting under the live capstones.
