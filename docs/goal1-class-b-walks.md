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
