# P1′ atomic 14-TU wiring blueprint (task #90)

**Status:** READ-ONLY wiring blueprint. No `.v` edited, no commit. This is the
ordered, cite-anchored plan the implementation agent executes for the single
atomic widen-and-retire commit that promotes the P1′ pre-stage
(`proofs/MarioModel/Unwired/MathGeomBodies.v`) into the spine.

Companion inputs: `docs/p1prime-fourteen-tu-design.md` (esp. §7/§8),
`docs/goal1-hypothesis-consistency-audit.md`.

## TL;DR — the commit is NOT yet a mechanical feed of the pre-stage

The **link plumbing** (link widen, 2 LO pins, 91-pair cert, init-mem cert,
negative-pin shrink 16→7) IS mechanical and length-generic — §1, §2, §5 below
are low-risk.

The **body wiring** has **three genuine pre-reqs the pre-stage does not yet
satisfy** (flagged LOUD in §3/§4/§6). In descending severity:

1. **PHANTOM CALLEE/SYMBOL ORACLES on the 4 aggregators.** `find_floor`,
   `find_ceil`, `f32_find_wall_collision`, `find_wall_collisions` each carry
   `∀vargs` callee oracles and/or `∀e0` symbol-store oracles
   (`MathGeomBodies.v` `Hcall`/`Hglob`/`Hsafe` premises) that are **not
   dischargeable at wiring** (an adversarial `vargs`/`e0` defeats them). They
   are true-but-unwireable as literally stated. See §4-A. **This means
   `find_floor_body_frame`/`find_ceil_body_frame`/`f32_..._body_frame`/
   `find_wall_collisions_body_frame` cannot be applied as-is** — their premises
   must be re-stated call-site-arg-aware / concrete-env-aware first.

2. **ENGINE `chk` COVERAGE GAP for the writers (CONFIRMED, not hypothetical).**
   `f_update_mario_geometry_inputs` — a **censused_body** walked by the EngineV2
   census `chk` (`CensusV2.v:2567`, `bc_ugeo`) — **directly calls `_find_floor`
   and `_f32_find_wall_collision` via `Evar` (class-E)**. The engine `chk` Scall
   recognizer (`CensusV2.v:1085-1088`) has **only** class-M and class-E arms —
   no out-param arm. Removing the writers from `exempt_callees` breaks that walk;
   keeping them forces a `∀vargs` `body_pres` case that is phantom-false. See §3-B.
   **Requires a new out-param arm in the shared engine `chk` + consumer.**

3. **`vfc_pres` REGRESSES.** The #95 body `vec3f_find_ceil` is discharged
   (`RestSurface.v:370` `vfc_pres`) with the premise
   `∀f, ~ resolves_lp lp mario._find_ceil (Internal f)` (`:374`) — i.e. it
   **requires `find_ceil` to stay External**. Linking `surface_collision` makes
   `find_ceil` Internal → that premise is FALSE → `vfc_pres` is unusable → the
   `Hvfc` slot of `rest_pres_decompose` (`RestSurface.v:333,360`) loses its
   discharge. `vfc_pres` must be re-proven routing its nested `find_ceil` call
   through the new `find_ceil` oc discharge. See §3-C.

If the implementation agent wires the 10 clean facts and blindly feeds the 4
aggregators, the build will **not** go green (it will stick on the un-suppliable
`Hcall`/`Hsafe`/`Hglob` premises) — it is not a silent vacuity, it is a hard
block. The honest next unit is to **repair the 4 aggregator facts' interfaces**
(§6, NEW LEMMAS) *before* attempting the atomic commit.

---

## 0. The pre-stage inventory (what MathGeomBodies.v actually delivers)

14 `Qed`'d ge-generic facts. Cites are `proofs/MarioModel/Unwired/MathGeomBodies.v`.

| # | fact (Lemma) | line | gate arg | oracle premises | wireable? |
|---|---|---|---|---|---|
| 1 | `find_water_level_body_frame` | 77 | none | none (memory identity) | ✅ clean |
| 2 | `find_poison_gas_level_body_frame` | 120 | none | `Halloc`,`Hfree` | ✅ clean |
| 3 | `atan2_lookup_body_frame` | 203 | none | none (memory identity) | ✅ clean (ripple) |
| 4 | `atan2s_body_frame` | 328 | none | `Hcall`=`is_atan2_lookup_call` (∀vargs → `m'=m`) | ✅ clean¹ |
| 5 | `vec3f_set_body_frame` | 676 | `hd_error vargs`=arg0 | `Halloc`,`Hfree`,`Hstore`(off-bm) | ✅ clean² |
| 6 | `vec3f_copy_body_frame` | 772 | `hd_error vargs`=arg0 | `Halloc`,`Hfree`,`Hstore` | ✅ clean² |
| 7 | `vec3s_copy_body_frame` | 862 | `hd_error vargs`=arg0 | `Halloc`,`Hfree`,`Hstore` | ✅ clean² |
| 8 | `f32_find_wall_collision_body_frame` | 1240 | `nth_error vargs 0/1/2` | `Halloc`,`Hfree`,`Hstore`,**`Hcall`=`is_fwc_call` (∀vargs frame-pres)** | ⛔ §4-A |
| 9 | `find_floor_from_list_body_frame` | 1613 | `nth_error vargs 4`(`_pheight`) | `Hstore` | ✅ clean³ |
| 10 | `find_ceil_from_list_body_frame` | 1661 | `nth_error vargs 4` | `Hstore` | ✅ clean³ |
| 11 | `find_wall_collisions_from_list_body_frame` | 1712 | `nth_error vargs 1`(`_data`) | `Hstore` | ✅ clean³ |
| 12 | `find_wall_collisions_body_frame` | 1930 | `nth_error vargs 0`(`_colData`) | `Hstore`,**`Hcall`=`_from_list`(∀vargs)**,**`Hglob`=`is_global_store _gNumCalls`(∀e0)** | ⛔ §4-A |
| 13 | `find_floor_body_frame` | 2239 | `nth_error vargs 3`(`_pfloor`) | `Halloc`,`Hfree`,`Hstore`,**`Hcall`=`find_floor_from_list`(∀vargs)**,**`Hsafe`=`is_symbase_store`(∀e0)** | ⛔ §4-A |
| 14 | `find_ceil_body_frame` | 2326 | `nth_error vargs 3`(`_pceil`) | `Halloc`,`Hfree`,`Hstore`,**`Hcall`=`find_ceil_from_list`(∀vargs)**,**`Hsafe`=`is_symbase_store`(∀e0)** | ⛔ §4-A |

¹ `atan2s`'s callee oracle is satisfiable because `atan2_lookup` is **pure**
(`atan2_lookup_memid`, `:180`, holds for **all** `vargs`).
² the arg0 gate is supplied by the consumer's out-param class (`last_arg`/
`hd`-arg `<> bm`); the alloc/free/off-bm-store oracles map to MWFReal rows (§4-B).
³ the `_from_list` leaves are clean **standalone**, but they are only *reached*
as the very ∀vargs callee oracles that are phantom for #8/#12/#13/#14 — see §4-A.

**A 15th reached math_util body exists and has NO pre-stage fact:**
`f_vec3s_set` (`generated/math_util.v`) — consumed via `Hscp_v3s`/
`Hw1cp_v3sset_real` (`NoAImpliesNoFlyTwelve.v:123,143`). It is **not** on
`exempt_callees`/the negative pin, so linking it Internal is **non-vacuous** and
does **not** block the commit — but it (and `approach_f32`, `approach_s32`,
`anim_spline_init/poll`, `mtxf_align_terrain_triangle`, all math_util internals
reached as `call_pres_ext*` residuals) becomes an **Internal-but-assumed**
residual (class-B "unwalked Internal body" trust) after the widen. Honest note,
not a blocker; if the payoff wants "math_util fully walked" these need facts too.

---

## 1. LINK WIDENING (mechanical, low-risk)

**`tu_rest`** (`LinkedTwelve.v:77-88`): append **in this order**
`... ; mario_step.prog ; math_util.prog ; surface_collision.prog`. Order is
free-choice for correctness (membership only); pick math_util at index 11,
surface_collision at index 12 to match the two new LO pins' witness depth.

**Two new LO pins** in `Section Linked12LO` (`LinkedTwelve.v:121-172`), each a
one-liner mirroring `linked12_LO_stp` (`:168`):
```
Lemma linked14_LO_math : linkorder math_util.prog lp.
Proof. exact (link_chain_linkorder_in _ _ _ _ (in_cons _ _ _ (…×11… (in_eq _ _))) H12). Qed.
Lemma linked14_LO_surf : linkorder surface_collision.prog lp.
Proof. exact (link_chain_linkorder_in _ _ _ _ (in_cons _ _ _ (…×12… (in_eq _ _))) H12). Qed.
```
`link_chain_linkorder_in` (`:108`) is length-generic — no change to it. Witness
= `in_cons` nested to the member's index then `in_eq`.

**`Section RestSurface`** (`RestSurface.v:133-150`): add two hypotheses
`LO_math : linkorder math_util.prog lp` and `LO_surf : linkorder
surface_collision.prog lp` alongside `LO_mario … LO_stp`. Wired from the two new
LO pin lemmas at the capstone.

Keep the module name `LinkedTwelve`/`linked12` (per `docs/RENAMING.md`; widen the
list, don't churn theorem names). Optionally alias `linked12`→`linked14`.

---

## 2. CERT WIDENING (mechanical + one PERF caveat)

**Pairwise cert (66→91), `Linked12Sat.v`.** `link_chain_of_ok` (`:423`),
`pair_ok`/`pairwise_ok` (`:166,417`) are **length-generic** — no restructure.
Only the two `vm_compute` leaves re-state over the 13-member `tu_rest`:
- `twelve_head` (`:463`) `forallb (pair_ok mario.prog) tu_rest`: 11→13 pairs.
- `twelve_tail` (`:466`) `pairwise_ok tu_rest`: C(11,2)=55 → C(13,2)=78 pairs.
- `linked12_inhabited` (`:475`) reuses `exact (link_chain_of_ok tu_rest …
  fourteen_head fourteen_tail)` verbatim.

**PERF LAW (re-time before commit).** `math_util.v` ≈ 850 KB, `surface_collision.v`
≈ 290 KB. The ~25 new pairs *involving* those two force their large defmaps into
the `pair_okv` view. GC keeps peak at one pair (`Linked12Sat.v:448-455`), so
expect seconds–low-tens-of-seconds, **not** the tactic-hang class — provided the
certs stay closed `vm_compute` lemmas. **Never** let `cbn`/`change`/`rewrite`
touch a goal mentioning a whole-TU constant (the 4-CPU-hour lesson). Run both
widened leaves under `-time` standalone as an S0 probe (don't commit) to confirm
they close and surface any obstruction `id` counterexample.

**Init-mem cert (12→14), `InitMemSat.v`.** `twelve_gvars_ok` (`:201`,
`forallb tu_gvars_ok (mario.prog :: tu_rest)`) re-states as `fourteen_gvars_ok`
over the 14-list; `rest_gvars_ok` (`:211`, `∀q, In q tu_rest → …`) is generic and
covers the two new members free. Only content: `math_util`'s `gArctanTable`
(one large `Init_int*` list, decidable/`vm`) and `surface_collision`'s partition
arrays pass `tu_gvars_ok` (`:84`). The environment/partition globals are
`gvar_init := nil` externs (design §1c, verified) → no `Init_addrof` targets → pass
trivially. `gArctanTable` is the only real check; alignment risk low (int table).

---

## 3. CENSUS REROUTE — the coverage-critical part (per-id)

Two recognizer surfaces classify a `Scall` to one of the 9:
- **Engine census `chk`** (`CensusV2.v:1085-1088`): `call_optid_ok && (class-M ||
  class-E)`. Class-E = `call_callee_exempt a` (`:654`) = `Evar fid Tfunction ∧
  mem_id fid exempt_callees`. **No out-param arm.** Frame effect of a class-E call
  is discharged by the consumer's `Hrest_pres` (`EngineV2Consumer.v:200`) via
  `rest_fd (Internal f)` **only when the symbol resolves Internal** — a `∀vargs`
  `body_pres` obligation (`RestSurface.v:247`).
- **Leaf out-param surfaces** (`OutParamSurface.v`, `InterSurface.v`,
  `ObjectLeafSurface.v`, etc.): `oc_call_chk`/`wl`/`wol`/`sc`/`ol`/`w1` keyed on
  per-class `_pids` lists (e.g. `InterSurface.v:2157` `oc_call_chk (_floor::nil)
  (_find_floor::nil)`). These are **arg-aware** (`call_pres_ext_oc`,
  `OutParamSurface.v:78`, carries `last_arg_local` → out-param block `<> bm`) and
  **do not consult `exempt_callees`**.

### 3-A. The 3 PURE ids (atan2s, find_water_level, find_poison_gas_level) — SAFE

These are `∀vargs`-frame-safe (facts #1/#2/#4 have no arg gate). Plan:
- **KEEP in `exempt_callees`** (`CensusV2.v:601`) → class-E coverage preserved at
  every engine-`chk` call site (no gap; this is why §7.1-FACT-3's "removal breaks
  coverage" is real — so *don't remove*, mirror the vfc treatment instead).
- **REMOVE from `exempt_ext_ids`** by widening the filter (`RestSurface.v:55`)
  from `≠ vec3f_find_ceil` to `∉ {vec3f_find_ceil, atan2s, find_water_level,
  find_poison_gas_level}` → they leave the negative pin.
- **Extend `exempt_split`** (`RestSurface.v:70`) to route these three (like vfc)
  to the internal branch.
- **Add 3 `body_pres` cases** to `rest_internal_cases` (`RestSurface.v:182-243`,
  becomes 13→16 disjuncts) and `rest_pres_decompose` (`:313-361`), each
  discharged by the pre-stage fact (`find_water_level_body_frame` etc.) —
  exactly the `vfc_pres` pattern. Their `mario._{sym}` defmap-pin lemmas
  (twin of `mario_defmap_vfc`, `RestSurface.v:81`) pin the Internal resolution
  to the **math_util/surface_collision** body via `LO_math`/`LO_surf`
  (NB: cross-TU — the pinned body is `surface_collision.f_find_water_level`, not
  a mario.prog body; use `resolves_pin` `:164` with `LO_surf`).
- **Discharge the leaf `Hcpx_atan2s`/`Hxcp_fwl_real` residuals**
  (`StationaryLeafSurface.v:2003`, `InterSurface.v:2266,6174,6423`,
  `ObjectLeafSurface.v:1280`, `AirborneLeafSurface.v:1923`,
  `CutsceneLeafSurface.v:1487`, `BullySurface.v:88`, `MarioStepSurface.v:836,842`,
  `NoAImpliesNoFlyTwelve.v:160`) from the pre-stage facts — `call_pres_ext` is
  `∀fd` (satisfiable for Internal), so each collapses to one application of the
  pure body_frame. **No coverage falls through** for the pure ids.

### 3-B. The 6 WRITERS — the CONFIRMED coverage gap ⛔

vec3f_set, vec3f_copy, vec3s_copy, find_floor, find_ceil, f32_find_wall_collision
are on `exempt_callees` **because at least one engine-`chk` body calls them via
class-E** (the comment `CensusV2.v:590-592` says the whitelist is exactly the
callee set of the 17 frame-reached bodies).

**CONFIRMED direct class-E sites in a censused body:**
`f_update_mario_geometry_inputs` (`censused_body`, `CensusV2.v:2567`, `bc_ugeo`)
calls `(Evar _find_floor …)` ×2 and `(Evar _f32_find_wall_collision …)` ×2
(scanned in `generated/mario.v`). Its `chk` walk (`body_TI_C_dispatch`,
`CensusV2.v:2574`) recognizes those calls **only** via class-E.

The conflict:
- **Remove writers from `exempt_callees`** → `call_callee_exempt` returns false at
  those sites → the engine `chk` Scall arm has no match → `body_TI_C_update_mario_
  geometry_inputs` fails to typecheck. **Coverage gap.**
- **Keep writers in `exempt_callees`** → after linking they resolve Internal →
  `rest_fd (Internal f_find_floor)` → `rest_pres_decompose` needs a `body_pres`
  case for `f_find_floor` → **`body_pres` is `∀vargs` PHANTOM-FALSE** (find_floor
  writes through the `_pfloor` out-param; adversarial `vargs` arg3 = `Vptr bm oo`
  hits the action cell — the design §2b/§0 phantom class). **Cannot discharge.**

There is **no** committed state satisfying both with the current engine. **The
atomic commit MUST extend the engine `chk` Scall recognizer** (`CensusV2.v:1085`)
with an **out-param arm** — recognize `find_floor`/`f32_find_wall_collision`
(and any other writer directly called from a censused body) with their out-param
argument, thread the actual arg through the engine TI to establish `arg <> bm`,
and route the frame effect to an **arg-gated** discharge (find_floor's oc/wl body
frame) in `EngineV2Consumer` — a NEW hypothesis analogous to `Hrest_pres` but
carrying the out-param locality, **not** the `∀vargs` `body_pres`. This is a
**shared-engine change** touching every `chk`-walked body's proof, and is the
single largest structural item in the commit.

For writer call sites that are **only** in leaf out-param bodies (vec3f_set/copy,
vec3s_copy, find_ceil deep sites), removal from `exempt_callees` is safe (those
walkers never used it) — but the CONFIRMED `update_mario_geometry_inputs` sites
force the engine change regardless.

**S2 verification the implementer MUST run first** (fills the last gap in this
blueprint — I confirmed `update_mario_geometry_inputs` but did not enumerate
*every* censused body): for each writer,
```
grep -nE 'Evar _(find_floor|find_ceil|f32_find_wall_collision|vec3f_set|vec3f_copy|vec3s_copy)\b' generated/mario.v
```
and map each enclosing `f_*` to `censused_body` (`CensusV2.v:2557`). Every hit in
a censused body = one engine-`chk` out-param arm obligation.

### 3-C. `vfc_pres` regression ⛔

`vec3f_find_ceil` stays a `body_pres` case (`RestSurface.v:333`). But `vfc_pres`
(`:370`) discharges its nested `find_ceil` call as **External** (premise `:374`
`∀f, ~ resolves_lp lp _find_ceil (Internal f)`). Linking `surface_collision`
makes `find_ceil` Internal → premise false → `vfc_pres` inapplicable.
`vfc_pres` must be **re-proven** so its nested `find_ceil(…, &filler-window)` call
routes through the new `find_ceil` oc discharge (vec3f_find_ceil forwards its own
out-param, so `last_arg_local`/arg-gate is threadable from vfc's own out-param
hypothesis). New work, blocked on §4-A being fixed for `find_ceil`.

---

## 4. ORACLE DISCHARGE (the DAG, and the phantom flags)

### 4-A. FLAG: the 4 aggregators' `∀vargs`/`∀e0` oracles are NOT dischargeable ⛔

The pre-stage facts #8/#12/#13/#14 take oracle premises that, **as literally
quantified**, cannot be supplied at the wiring point:

**Writer-callee oracles (`∀vargs` frame-pres).** e.g. `find_floor_body_frame`'s
`Hcall` (`MathGeomBodies.v:2245`) is
`∀ e0 le0 m0 a vf f vargs t0 m0' vres, is_cid_call _find_floor_from_list a → … →
eval_funcall … f vargs … → frame m0 → frame m0'`. To supply it you must prove
`find_floor_from_list` preserves the frame **for all `vargs`**. But
`find_floor_from_list_body_frame` (#9) itself **requires `nth_error vargs 4 <>
bm`** — with `vargs`'s 5th arg = `Vptr bm oo` the callee writes `*_pheight` into
`bm` and the frame breaks. So `Hcall` is **false in general** → unprovable.
Same for `f32`→`find_wall_collisions` (`:1247`),
`find_wall_collisions`→`_from_list` (`:1934`),
`find_ceil`→`find_ceil_from_list` (`:2332`).
(Contrast: `atan2s`→`atan2_lookup` is fine — `atan2_lookup` is pure, `m'=m`
for **all** vargs.)

**Symbol-store oracles (`∀e0`).** `find_floor_body_frame`'s `Hsafe`
(`:2252`) is `∀ lv rhs e0 …, is_symbase_store lv → exec (Sassign lv rhs) …
→ frame ∧ le0'=le0 ∧ Out_normal`. `is_symbase_store` (`:2039`) accepts **any**
By_value `Evar id` or `Efield (Evar id _)`. An adversarial `e0` with
`e0!id = Some(bm, _)` (a local shadow) and `lv = Efield (Evar id) <action-offset
field>` stores into the action cell of `bm` → `action_sat` breaks, and MWF can't
be recovered (the off-bm store brick needs `b<>bm`). So `Hsafe` is **false in
general** → unprovable. Same for `find_wall_collisions`'s `Hglob`
(`is_global_store _gNumCalls`, `:1941`): `∀e0` an `_gNumCalls` local-shadow to
`bm` defeats it.

**Why it Qed'd anyway:** these are *hypotheses* of the body_frame lemma; the
lemma is trivially true given a (possibly unsatisfiable) hypothesis. The failure
surfaces only when you try to **construct** the hypothesis at the atomic commit —
and there you are stuck.

**The fix (NEW work, §6):** re-state #8/#12/#13/#14 with **narrowed** premises:
- callee oracle keyed to the **actual call-site arg** — the internal call passes
  `&<own local>` (find_floor: `&dynamicHeight`; f32: `&collision`), so the
  aggregator's walker (`sg_walk`/`wc_walk`) must be made **arg-aware**: recognize
  the specific internal call, evaluate its `Eaddrof`/out-param arg to the
  aggregator's OWN fresh frame block (`<> bm`, already in hand as `Hb2_bm` etc.),
  and apply the callee's `_from_list` body_frame with that gate — replacing the
  blanket `Hcall`. i.e. package the `_from_list` facts as arg-aware
  `call_pres_ext_ol`-shaped residuals and consume them at the recognized site.
- symbol oracle narrowed from blanket `is_symbase_store` to a **whitelist** of
  the concrete statics (`_gNumCalls`, `_gNumFindFloorMisses`,
  `_gFindFloorIncludeSurfaceIntangible`) discharged from `stored_globals`
  (see §4-C) **plus** the aggregator's own fresh-frame locals discharged from
  the concrete env (`Hb1_bm`/`Hb2_bm`) — i.e. thread the concrete `e` through the
  walker rather than abstracting it.

Until #8/#12/#13/#14 are re-stated, the atomic commit for
find_floor/find_ceil/f32/find_wall_collisions is blocked.

### 4-B. The dischargeable oracles (for the 10 clean facts) and their DAG

Feed order (a fact's callee oracle needs the callee's fact first):
```
atan2_lookup_memid ──► atan2s_body_frame                      (pure chain, clean)
find_floor_from_list_body_frame ──► find_floor_body_frame     (blocked at the ► by §4-A)
find_ceil_from_list_body_frame  ──► find_ceil_body_frame      (blocked by §4-A)
find_wall_collisions_from_list_body_frame ──► find_wall_collisions_body_frame ──► f32_find_wall_collision_body_frame  (blocked by §4-A twice)
```
Discharge of the base oracles at `ge := lp_ge lp`:
- `Halloc` ⟵ `HMWF_alloc`/`Hmwf_entry` (MWFReal alloc row, `EngineV2Consumer.v:236`,
  `OutParamSurface.v:52`).
- `Hfree` ⟵ `HMWF_free`/`Hmwf_free` (`EngineV2Consumer.v:238`, `OutParamSurface.v:54`).
- `Hstore` (off-bm store) ⟵ the MWFReal off-bm store row (the `Hmwf_chase`/
  `Hmwf_glob` family, `EngineV2Consumer.v:164-172`; MWFReal proves
  `b<>bm → store → MWF`).
- top-level arg gate (`hd_error`/`nth_error vargs k <> bm`) ⟵ the consuming
  out-param class's `last_arg_local`/window premise (`call_pres_ext_oc`
  `:82`, etc.) — the block is `local_blk lp bm SafeB b` ⇒ `<> bm` via
  `HSafeNotBm`. This is where the clean vec3/from_list gates are met.

### 4-C. `stored_globals` needs THREE new members

`find_floor`/`find_ceil`/`find_wall_collisions` write static counters
`gNumCalls`, `gNumFindFloorMisses`, `gFindFloorIncludeSurfaceIntangible`
(design §8; `surface_collision.v` `v_gNumCalls:632`, `v_gNumFindFloorMisses:625`,
`v_gFindFloorIncludeSurfaceIntangible:681`). **None is in `stored_globals`**
(`CensusV2.v:780-900`, verified — it lists mario/level_update/interaction/
mario_step/submerged/cutscene statics only). The narrowed symbol oracle (§4-A)
discharges the static writes via `Hmwf_glob` (`EngineV2Consumer.v:164`, gives
`bg <> bm` and store-preserves-MWF) **only if** these three are added:
```
surface_collision._gNumCalls ::
surface_collision._gNumFindFloorMisses ::
surface_collision._gFindFloorIncludeSurfaceIntangible :: …
```
Adding them also obliges the capstone's `Hmwf_glob`/`Hglob_blk` row to prove
each `<> bm` (static-layout, same trust class as the existing entries).

---

## 5. PIN RESTATEMENT (16→7) — mechanical

- `truly_ext_pin_ids` (`LinkedTwelve.v:332`) = `_play_infinite_stairs_music ::
  exempt_ext_ids`. After the §3-A filter widen + the 6 writers leaving
  `exempt_callees`, `exempt_ext_ids` shrinks from 15 to **6**:
  `sqrtf`, `print_text_fmt_int`, `set_camera_mode`, `stop_cap_music`,
  `fadeout_cap_music`, `play_sound`; `truly_ext_pin_ids` = those 6 + music = **7**.
- The **negative pin stays ONE row** (`Hrest_ext_only`, `RestSurface.v:155`) —
  its domain just shrinks. `linked12_ext_pin` (`LinkedTwelve.v:390`) re-derives
  over the 6.
- **Add two sweep lemmas** `no_internal_math`/`no_internal_surface`
  (`no_internal_ids {math_util,surface_collision}.prog truly_ext_pin_ids = true`,
  mirror `no_internal_mario` `:336`) and wire them into the
  `link_chain_internal_origin` case split of `linked12_ext_pin` (`:404-418`).
  They **pass** because none of the 7 survivors is defined in math_util/
  surface_collision (`sqrtf` is a builtin, not math_util — verified: math_util has
  `atan2f`/`atan2s`/`atan2_lookup`, no `sqrtf`; the 5 others are audio/text/camera).
  Over the OLD 15-id list they would FAIL (design §5) — hence the retire-first
  ordering is impossible and this is atomic.
- `capstone_negative_pin_refuted` (`LinkedTwelve.v:436`) stays as the machine
  witness of why the widen without the retirement re-vacuifies (the 1-id case);
  after the commit it no longer applies to the shrunk domain.
- Capstone rows that FLIP from assumed to proved:
  `Hocp_find_floor`, `Hocp_find_ceil` (`=vec3f_find_ceil` fwd, `NoAImpliesNoFlyTwelve.v:112-116`),
  `Hwolcp_fwc` (`:117`), `Hscp_v3f`/`Hwlcp_v3f_real`/`Hw1cp_v3f_real`/`Hwolcp_v3f_real`
  (vec3f_copy, `:120,126,173,176`), `Hscp_v3fset_real`/`Hw1cp_v3fset_real` (vec3f_set,
  `:179,182`), `Hxcp_fwl_real` (find_water, `:159`), `Holcp_fwc_real`
  (find_wall_collisions, `:170`), and the `Hcpx_atan2s` section hyps (§3-A list).
  The vec3 ones (via facts #5/#6/#7) and find_water/atan2s are dischargeable now;
  the find_floor/find_ceil/f32/find_wall_collisions ones are blocked on §4-A.

---

## 6. ORDERED RECIPE, RISK RANKING, and the NEW LEMMAS the pre-stage owes

### The ordered green-in-one-pass recipe
**PRE-REQ (before the atomic commit — the pre-stage is INCOMPLETE without these):**
- **P-1** Re-state facts #13/#14 (`find_floor_body_frame`, `find_ceil_body_frame`):
  arg-aware `sg_walk` that (a) recognizes the `find_{floor,ceil}_from_list`
  internal call, evaluates its 5th arg to the body's own fresh local (`Hb2_bm`
  ⟹ `<> bm`), applies the `_from_list` fact with that gate — dropping the ∀vargs
  `Hcall`; (b) narrows `Hsafe` to the concrete `{_gNumCalls,
  _gNumFindFloorMisses, _gFindFloorIncludeSurfaceIntangible}` statics +
  own-frame locals, threading the concrete `e`.
- **P-2** Re-state facts #8/#12 (`f32_..._body_frame`, `find_wall_collisions_
  body_frame`) the same way (arg-aware `wc_walk`; f32's `&collision` internal arg,
  `_gNumCalls` static).
- **P-3** Add fact #15 `vec3s_set_body_frame` (mechanical `vec_block_set` twin of
  #5, `Mint16signed`) IF the payoff wants vec3s_set walked (optional; else leave
  as assumed residual, §0 note).

**ATOMIC COMMIT (single, green, discipline-clean, negative pin satisfiable):**
1. §1 link widen (`tu_rest`+2, 2 LO pins, RestSurface LO_math/LO_surf).
2. §4-C add 3 statics to `stored_globals`; add their `Hmwf_glob` `<>bm` rows.
3. §3-A retire the 3 pure (filter widen, `exempt_split` +3, `rest_internal_cases`/
   `rest_pres_decompose` +3 cases from #1/#2/#4; discharge the `Hcpx_*` leaf hyps).
4. §3-B **extend the engine `chk` Scall recognizer + consumer** with the
   out-param arm for the writers directly called from censused bodies
   (`update_mario_geometry_inputs` confirmed; run the S2 grep for the rest);
   remove the 6 writers from `exempt_callees`; discharge the oc/wl/wol/sc/ol
   capstone rows from the (re-stated) writer facts.
5. §3-C re-prove `vfc_pres` routing `find_ceil` through its Internal oc discharge.
6. §5 shrink `exempt_ext_ids`/`truly_ext_pin_ids` 15→6, add `no_internal_math`/
   `no_internal_surface`, re-derive `linked12_ext_pin`.
7. §2 widen the 3 certs (`fourteen_head`/`fourteen_tail`/`fourteen_gvars_ok`);
   `-time` first.
8. Re-derive `linked12_inhabited`/`_ext_pin`/`_init_mem`; repoint capstones;
   `discipline_check.sh` on all six targets; `Print Assumptions` clean.

### Risk ranking (most→least likely to not thread)
1. **§4-A phantom oracles (the 4 aggregators).** BLOCKER. The pre-stage's
   find_floor/find_ceil/f32/find_wall_collisions facts are unwireable as stated.
   Needs P-1/P-2 (arg-aware walkers + narrowed symbol oracle). Highest effort.
2. **§3-B engine `chk` out-param arm.** BLOCKER for the writers. A shared-engine
   recognizer + consumer change; must land in the SAME commit as the
   `exempt_callees` edit (never before → coverage; never after → pin). Touches
   every `chk`-walked body proof.
3. **§3-C `vfc_pres` re-proof.** Blocked on P-1 (needs find_ceil arg-gated
   discharge). Medium.
4. **§4-C stored_globals + `Hmwf_glob` rows.** Mechanical but a real capstone
   obligation (3 static `<>bm` proofs). Low-medium.
5. **§2 PERF** (math_util 850 KB pairs). Low (re-time to confirm).
6. **§1/§5 plumbing.** Low — length-generic, mirror-existing.

### NEW lemmas the pre-stage did NOT provide (the gap list)
- **Arg-aware `sg_walk`/`wc_walk` variants** (recognize the specific internal
  `_from_list`/`find_wall_collisions` call, extract its `&own-local` out-param
  arg, apply the callee fact gated) — replaces the blanket `Hcall` in #8/#12/#13/#14.
- **`_from_list` facts re-packaged as `call_pres_ext_ol`-shaped** (arg-aware
  `last_arg_local`) so the arg-aware walker can consume them.
- **Narrowed symbol-store lemma** (`is_symbase_store` → concrete
  {3 statics + own-frame locals}) discharged from `stored_globals`(+3) and the
  concrete env — replaces the blanket `Hsafe`/`Hglob`.
- **Engine `chk` out-param arm + `EngineV2Consumer` arg-gated writer-frame
  hypothesis** (the §3-B shared-engine change).
- **`vec3s_set_body_frame`** (fact #15) — optional, only for full math_util walk.
- **`stored_globals` membership** for `_gNumCalls`, `_gNumFindFloorMisses`,
  `_gFindFloorIncludeSurfaceIntangible`, with their `Hmwf_glob` `<>bm` rows.
- **Re-proved `vfc_pres`** (find_ceil Internal path).

**Bottom line:** §1/§2/§5 are mechanical and ready. §3/§4 reveal the pre-stage
delivered the right *bodies* but the wrong *interfaces* for the 4 aggregators
(phantom `∀vargs`/`∀e0` oracles) and did not build the engine out-param arm the
confirmed `update_mario_geometry_inputs` class-E sites require. The atomic commit
is **not** yet a mechanical execution — the pre-reqs P-1/P-2 (+ the §3-B engine
change) must land first. The 3 pure ids and the 3 vec writers (facts #1/#2/#4/#5/
#6/#7) plus find_water are cleanly wireable today.
