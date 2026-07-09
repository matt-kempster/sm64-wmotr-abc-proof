# P1′ — growing the faithful link from twelve to fourteen TUs (design scout)

**Status:** READ-ONLY design scout (task #90). No `.v` edited. Deliverable = this
memo. Companion audit: `docs/goal1-hypothesis-consistency-audit.md` (2026-07-02,
which first named the 9 latent ids); state-of-the-union:
`docs/state-of-goal1-2026-07-09.md` (P1′ = "the main remaining structural
front").

P1′ adds `math_util` and `surface_collision` (already clightgen'd:
`generated/math_util.v`, `generated/surface_collision.v`) to the faithful link,
retiring the 9 exempt-callee rows that stay external today **only because those
two TUs are not linked**.

---

## 0. The one-sentence mechanism (why P1′ is a campaign, not a growth)

Adding a TU to `LinkedTwelve.tu_rest` forces its Internal bodies into `lp` (via
the `LO_*` linkorder pins). The capstone's **negative pin** `Hrest_ext_only`
(`RestSurface.v:155`, `NoAImpliesNoFlyLinked.v` `Hrest_ext_only`) asserts that
every id in `exempt_ext_ids` (+ the music helper) stays **External** in `lp`.
The 9 ids are all in `exempt_callees` (`CensusV2.v:601`) and each is **Internal**
in `math_util`/`surface_collision`. So the instant either TU joins the link, the
negative pin becomes **jointly unsatisfiable with the new `LO_*` pin** — exactly
the `vec3f_find_ceil` (#95) vacuity, nine times over
(`LinkedTwelve.capstone_negative_pin_refuted` is the machine witness of the
one-id case at `LinkedTwelve.v:436`).

Therefore **you cannot add the LO pins first.** Growing the link before retiring
the 9 rows *re-introduces the exact vacuity the last week repaired* — and worse,
it silently breaks the `no_internal_math`/`no_internal_surface` `vm_compute`
sweeps (they would have to prove the 9 are non-Internal in TUs that define them:
**false**, `vm_compute` returns `false`, the pin lemma fails to build). This
ordering constraint (§4) is the spine of the whole plan.

---

## 1. The link growth

### 1a. Two new `LO_*` pins

`tu_rest` (`LinkedTwelve.v:77`) grows from 11 to 13 members
(`... ; mario_step.prog ; math_util.prog ; surface_collision.prog`), and
`Linked12LO` (`LinkedTwelve.v:121-172`) grows by two lemmas
`linked14_LO_math`, `linked14_LO_surf`, each a one-line `link_chain_linkorder_in`
with the right `in_cons/in_eq` witness — mechanical, identical shape to the
existing 12. `RestSurface`'s `Section RestSurface` (`RestSurface.v:133`) gains
`LO_math`, `LO_surf` hypotheses alongside the existing `LO_mario … LO_stp`.

*(Naming note: the module is historically `linked12`/`LinkedTwelve`; P1′ either
renames to `linked14` or keeps the name and widens the list. Keeping the name +
widening is the smaller diff and matches `docs/RENAMING.md` discipline of not
churning theorem names mid-arc.)*

### 1b. The pairwise satisfiability certificate: 66 → 91 pairs

`Linked12Sat.v` proves `linked12_inhabited` from two `vm_compute` certs:
`twelve_head` (`:463`, `forallb (pair_ok mario.prog) tu_rest`, 11 pairs) and
`twelve_tail` (`:466`, `pairwise_ok tu_rest`, C(11,2)=55 pairs) — 66 total.
For 14 TUs `tu_rest` has 13 members ⇒ head = 13 pairs, tail = C(13,2) = 78,
**91 = C(14,2) total.** The machinery is length-generic:
`link_chain_of_ok` (`:423`), `pair_ok_stable` (`:287`), `link_def_either`
(`:84`) never mention a fixed length, so `linked14_inhabited` is the same
`exact (link_chain_of_ok tu_rest14 mario.prog fourteen_head fourteen_tail)`
(`:475`). **No structural restructure** — only the two `vm_compute` lemmas
re-state over the wider list.

**PERF LAW (`Linked12Sat.v:448-455`, `MEMORY.md` linked12 arc):** one pair costs
0.04–0.19 s in `vm` because GC keeps peak at one pair's views. 91 pairs → seconds
to low-tens-of-seconds. **Caveat to re-calibrate:** `math_util.v` is 850 KB
(12546+ lines of function bodies) and `surface_collision.v` 290 KB — the ~25
new pairs that *involve* `math_util`/`surface_collision` force those large
defmaps and may cost more than 0.19 s each. Expected still seconds, **not** the
tactic-hang class (the certs stay closed `vm_compute` lemmas; never let
`cbn`/`change`/`rewrite` touch a goal mentioning a whole-TU constant —
`Linked12Sat.v:452`, the 4-CPU-hour lesson). Recommend timing the two widened
certs with `-time` before committing.

### 1c. The init-mem certificate: 12 → 14 TUs

`InitMemSat.v` proves `linked12_init_mem` from `twelve_gvars_ok` (`:201`, one
`vm_compute` over `mario.prog :: tu_rest`) + per-TU origin lemmas
(`link_chain_gvar_origin` `:168`, length-generic). Widening: `fourteen_gvars_ok`
over the 14-list, and `rest_gvars_ok` (`:211`) covers the two new members
automatically (it quantifies `In q tu_rest`). The only real content is that
`math_util`'s `gArctanTable` and `surface_collision`'s partition arrays pass
`tu_gvars_ok` (`:84`): alignment + every `Init_addrof` self-defined. The
partition/environment globals are `gvar_init := nil` externs (verified:
`v_gEnvironmentRegions` is `gvar_init := nil` in both `surface_collision` and
`behavior_actions`), so they carry no addrof targets and pass trivially;
`gArctanTable` is the one large init-data list to check (decidable, `vm`).

### 1d. Link obstruction check — NO new obstruction class expected

The three pipeline normalizations that made the twelve link (stringlit rename,
anonymous-composite canonicalization `_317@mario ≡ _381@cutscene`, extern-array
completion — `Linked12Sat.v:24-28`, `state-of-goal1:60-65`) are **pipeline-wide**:
`state-of-goal1:64` records "**All 16 TUs regenerated**" in the P3 pass, so
`math_util`/`surface_collision` already carry the canonicalized composites and
renamed stringlits, and `state-of-goal1:111` explicitly notes "the canonicalizer
already handles both new TUs."

I checked the highest-risk NEW collision class — a **shared global defined
incompatibly** in `surface_collision` and a linked TU:

| shared symbol | defined in (linked) | defined in surface_collision | verdict |
|---|---|---|---|
| `gEnvironmentRegions` | `behavior_actions` (`v_…`, `gvar_init := nil`, `tptr tshort`) | `v_…`, `gvar_init := nil`, `tptr tshort` | **identical extern ⇒ links (link_vardef of equal externs = that extern)** |
| `gDynamicSurfacePartition`, `gStaticSurfacePartition` | — (only surface_collision) | Gvar | no other definer ⇒ no conflict |
| `gArctanTable` | — (only math_util) | — | no conflict |

`main` ident is shared (all TUs from one clightgen pass share the interned
symbol table; `pair_okv`'s `Pos.eqb v_main` already passes for the twelve, same
table). **Flag:** the definitive check is running the widened `fourteen_head` /
`fourteen_tail` certs — if any pair fails, `vm` prints the offending `id`, the
same counterexample loop that found the three P3 normalizations. Structurally I
find no new obstruction class; but this is a *reasoned* prediction, not a proof —
the cert run is the proof.

---

## 2. The vacuity mechanism, per id — STORE-SCOUT of the 9 bodies

The standing rule (`state-of-goal1:44-56`, rule 1): *audit-by-comment is
worthless; only per-store classification against the generated AST is sound.* So
each body was read, not trusted. The decisive split:

**The `Hrest_pres` gate is too weak for pointer-out-param writers.** The rest
residual `Hrest_pres` (`EngineV2Consumer.v:200`) and its decomposition target
`body_pres` (`RestSurface.v:247`) carry only two gates:
`(marg_exempt (Internal f) = false → marg_ok bm vargs)` and
`sargs_ok (Internal f) vargs`. For every one of the 9, param 0 is
`float*`/`short*`/`Surface**`/… — **not** `MarioState*` — so `marg_exempt` is
`true` (verified by `WL_exempt`'s intent, `EngineV2Consumer.v:183`, and the audit
§1.2) and the marg premise is **vacuous**. `sargs_ok` constrains only sub-32-bit
*integer* args (it is the wind gate, `RestSurface.v:265`), so it does **nothing**
for a pointer arg. Consequence:

> For the 6 ids that **write through a pointer parameter**, plain `body_pres`
> (`∀ vargs`) is **PHANTOM-FALSE** — an adversarial out-param `= Vptr bm 4`
> makes `dest[2]` land on the action cell `bm+12` and breaks `action_sat`. They
> **cannot** be discharged by copying the `vfc_pres` template. This is the same
> phantom-`∀-vargs` shape as `spawn_wind_particles` (`RestSurface.v:256-264`),
> and the same class as every out-param keystone the SPP/oc/wl/wol arc already
> built.

The 3 ids that write **nothing through a pointer** (pure / own-frame only) *can*
use the `vfc_pres` template directly and are **zero-trust**.

### 2a. The 3 PURE ids (mechanical — `vfc_pres`/pure template, zero new trust)

- **`atan2s`** (`math_util.v:12546`). `fn_vars := nil`, **0 stores**, returns
  `tshort`. Body is nested `Sifthenelse` over sign octants; every leaf is
  `Scall (Some _t'k) (Evar _atan2_lookup …)` then `Sset _ret (Ecast …)` on
  temps, then `Sreturn (Etempvar _ret)`. Writes only temps/params (Clight
  `Sset`, not memory). **Store class: PURE-SCALAR.** Discharge: the `vfc_pres`
  walk minus the alloc (no filler) — the `pure_walk`/`pure_chk` memory-identity
  walker (`MEMORY.md` pgqs-discharge, "the tool for read-only bodies") is the
  exact instrument. **Ripple:** one call to `atan2_lookup` (Internal in
  math_util, `math_util.v:12515`, `fn_vars:=nil`, 0 stores, reads `gArctanTable`)
  — see §2c.

- **`find_water_level`** (`surface_collision.v:3339`). `fn_vars := nil`, **0
  stores**, **no callees**, returns `tfloat`. Reads `gEnvironmentRegions`,
  computes a level, returns a temp. **Store class: PURE-SCALAR.** Discharge:
  `pure_walk`. **Cleanest of all 9 — zero ripple, zero alloc.**

- **`find_poison_gas_level`** (`surface_collision.v:3494`). `fn_vars :=
  ((_filler, tarray tuchar 4))` — **one alloc, exactly `vec3f_find_ceil`'s
  shape** — but **0 stores**, **no callees**, returns `tfloat`. Discharge: the
  `vfc_pres` template **verbatim minus the find_ceil call**: reuse
  `blocks_of_env_filler` (`RestSurface.v:122`) + `vfc_free_list_frame`
  (`RestSurface.v:96`), no external-call bricks needed. **Zero ripple.**

These 3 add **no** capstone trust: like `vfc_pres` they are proved from the
existing alloc/free frame bricks (`Halloc`/`Hfree` of `body_pres`) plus a
pure body. They become 3 new proved cases of `rest_pres_decompose`.

### 2b. The 6 OUT-PARAM WRITERS (hard — must route through the gated oc/wc/wl/wol classes, NOT plain body_pres)

- **`vec3f_set`** (`math_util.v:6129`). `fn_vars := ((_dest, tptr tfloat))` (the
  clightgen address-taken-param shadow ⇒ one alloc). Body:
  `Sassign (Evar _dest) (Etempvar _dest)` then 3× `Sassign (Ederef (t' + i))
  (Etempvar _x/_y/_z)` — **writes `dest[0..2]` through the `float*` out-param.**
  **Store class: WINDOW-OUT-PARAM (float).** Discharge: `call_pres_ext_wc`
  (`OutParamSurface.v:680`) — the window-out-param class. Plain `body_pres`
  phantom-FALSE.

- **`vec3f_copy`** (`math_util.v:6075`). Same shape: reads `src[i]`, writes
  `dest[i]` through the `float*` out-param, `dest` shadow alloc. **WINDOW-OUT-PARAM
  (float). `call_pres_ext_wc`.**

- **`vec3s_copy`** (`math_util.v:6322`). Same as `vec3f_copy` but `tshort`.
  **WINDOW-OUT-PARAM (short). `call_pres_ext_sc`** (`OutParamSurface.v:762`).
  GOTCHA: the `ptr32 cast_case_pointer passthrough` note (`MEMORY.md`) —
  storing a `Vptr` into a `tshort` field is `i2i` truncation (→ `Vundef`), not
  passthrough, but the gate is required regardless.

- **`find_floor`** (`surface_collision.v:3050`). `fn_vars := (_height,
  _dynamicHeight)` (own-frame, safe). 3 stores: 2 into the **own locals** `_height`
  / `_dynamicHeight` (safe), **1 into `*pfloor = NULL` through the `Surface**`
  out-param** (`:3082`). Passes `&dynamicHeight` (own local) into the nested
  call. **Store class: OUT-PARAM POINTER-FIELD (Surface**). `call_pres_ext_oc`**
  (`OutParamSurface.v:78`) — this is literally the `Hocp_find_floor`
  class the SPP keystone already built. **Ripple:** `find_floor_from_list` (§2c).

- **`find_ceil`** (`surface_collision.v:2270`). Same as `find_floor`: 2 own-frame
  stores + `*pceil = NULL` through the out-param, calls `find_ceil_from_list`.
  **OUT-PARAM POINTER-FIELD. `call_pres_ext_oc`** (`Hocp_find_ceil` class).

- **`f32_find_wall_collision`** (`surface_collision.v:1727`). `fn_vars :=
  ((_collision, Tstruct WallCollisionData))` — the wall struct is an **OWN
  LOCAL**, so the 11 field stores into `_collision` are **safe (own frame)**. The
  Mario-relevant writes are the **write-backs `*xPtr/*yPtr/*zPtr = collision.x/y/z`
  through the three `float*` out-params** *after* `find_wall_collisions`
  (`surface_collision.v` body lines ~1786–1810). **Store class: WINDOW-OUT-PARAM
  (3× float*, into the `m->pos` window). `call_pres_ext_wl`/`_wol`**
  (`OutParamSurface.v:1037`/`:1567`) — the `Hwcp_fwc`/`Holcp_fwc` class from the
  resolve-walk arc (`MEMORY.md` resolve-walk-scoping). **Ripple:**
  `find_wall_collisions`, `find_wall_collisions_from_list` (§2c). Heaviest.

**None of the 9 writes Mario state unconditionally** (verified, not assumed): 3
are pure, 6 write only through their declared out-params (or own frame). This
matches the engine-helper expectation — but the 6 are precisely the phantom-false
class, so the "engine helper, harmless" comment would have been a vacuity trap
had it been trusted (rule 1).

### 2c. The reachability CLOSURE — the ripple is 5 more Internal bodies

Walking the 6 writers reaches **5 helpers that are Internal in the newly-linked
TUs and are NOT on any census list today** (so `Hrest_pres` does not cover them,
and `rest_internal_cases` has no case for them):

| ripple id | TU (line) | fn_vars | stores | callees |
|---|---|---|---|---|
| `atan2_lookup` | math_util:12515 | nil | 0 (reads `gArctanTable`) | — |
| `find_floor_from_list` | surface_collision:2654 | nil | 1 (`*pheight` out-param) | — |
| `find_ceil_from_list` | surface_collision:1987 | nil | 1 (`*pheight` out-param) | — |
| `find_wall_collisions` | surface_collision:1808 | nil | 2 (into `colData` out-param) | `find_wall_collisions_from_list` |
| `find_wall_collisions_from_list` | surface_collision:709 | nil | 4 (into `colData` walls, out-param) | — |

Because these resolve **Internal** in `lp`, the `vfc_pres` trick of "the nested
call stays External, covered by the blanket `Hext_action`/`Hmwf_ext` rows"
(`RestSurface.v:370-383`) **does not apply** — the nested funcall resolves to an
Internal body. Two options, both sound (neither is a vacuity — `call_pres_ext`
quantifies over `fd`, `FloorsSurface.v:242`, so an Internal resolution is
*satisfiable*, not refutable):

1. **Boundary (fast, adds documented class-B trust):** discharge each nested call
   via a `call_pres_ext_oc/_wl` row keyed to the ripple id, i.e. add
   `atan2_lookup`, `find_*_from_list`, `find_wall_collisions[_from_list]` to the
   appropriate gated census list and consume them as gated externals. This is
   *exactly* the class-B "trusting an unwalked Internal body" ledger entry the
   audit §2 defined — honest but owed, NOT a vacuity.
2. **Walk (thorough, zero trust):** recurse — `atan2_lookup`/`find_water`-style
   pure walk for `atan2_lookup`; the out-param gate for the `_from_list` writers
   (they write only through their `pheight`/`colData` out-params, all `fn_vars :=
   nil`, no deeper ripple except `find_wall_collisions → …_from_list`).

**The effective P1′ body surface is therefore 9 primary + 5 ripple = 14 bodies**,
not 9. The 3 pure primaries have zero ripple; the ripple concentrates under the
2 surface out-param families.

---

## 3. The payoff (assumed-count delta)

- **`truly_ext_pin_ids` shrinks 16 → 7** (`LinkedTwelve.v:332`). The 7 genuine
  survivors (no Internal body anywhere in a full 17-TU link, audit §1.3):
  `sqrtf`, `print_text_fmt_int`, `set_camera_mode`, `stop_cap_music`,
  `fadeout_cap_music`, `play_sound`, `_play_infinite_stairs_music`. So
  `exempt_ext_ids` after P1′ = **6** ids and the negative pin covers 6 + music.
  `sqrtf` **stays a genuine boundary** (it is a builtin, **not** defined in
  math_util — only `atan2s` is; verified `atan2s` Internal at `math_util.v:12546`
  and calls `atan2_lookup`, no `sqrtf`).

- **The negative pin stays ONE row** (`Hrest_ext_only`), its domain just shrinks;
  it does not multiply. Its `no_internal_math`/`no_internal_surface` sweeps now
  **pass** (the 7 survivors are genuinely absent from both TUs) — whereas over
  the current 16-id list they would *fail* (audit §5).

- **9 rows move from "assumed-external (vacuous at 14-TU)" to proved/gated:**
  the 3 pure become **proved** `body_pres` cases of `rest_pres_decompose` (zero
  new capstone assumption, like `vfc_pres`); the 6 writers are **reclassified**
  into the existing gated out-param census (`oc/wc/sc/wl/wol`) whose consuming
  rows (`Hocp_find_floor`, `Hocp_find_ceil`, `Hwcp_fwc`, …) are **already
  capstone hypotheses** from the SPP/resolve arc — so retiring them adds **no new
  leaf row**; it *converts* the audit's class-B "mislabeled boundary, trust owed"
  debt into a discharged walk.

- **Net capstone-assumption delta: +2 `LO_*` structural pins** (both discharged
  by the widened `linked14`/`linked14_inhabited` certs, exactly as the twelve
  are), **±0 leaf rows**, **−1 vacuity** (the negative pin becomes satisfiable
  for the 14-TU link). Plus the ripple choice (§2c-1) adds ≤5 documented
  class-B rows *if* deferred as boundaries, or 0 *if* walked. Strong net-positive
  tethering: the link now contains the two lowest-level geometry/math TUs where
  find_floor/find_ceil/vec3 actually live, and 9 symbols the model previously
  *pretended* were external are now the real generated bodies.

---

## 4. Ordered slice plan (RETIRE FIRST, then GROW — the hard interdependency)

The ordering is forced by §0: **the LO pins and the `no_internal_*` sweeps cannot
be added while any of the 9 is still on the negative pin, or the sweep is a false
`vm_compute` and the vacuity is live mid-arc.** So retire the rows *before*
widening the link.

| slice | work | class | why this order |
|---|---|---|---|
| **S0** | Regenerate/confirm `math_util.v`, `surface_collision.v` carry the P3 normalizations; run standalone widened `fourteen_head`/`fourteen_tail` `vm_compute` as a **throwaway probe** (do not commit) to confirm the 14 link and surface any new obstruction id. | mechanical | de-risks §1d before any spine edit; counterexample-driven like P3 |
| **S1** | Retire the **3 pure** ids: remove from `exempt_callees`→`exempt_ext_ids`, add `atan2s_pres`/`find_water_pres`/`find_poison_pres` (pure/`vfc` template) as new `body_pres` cases in `rest_internal_cases` (`RestSurface.v:182`) + `rest_pres_decompose` (`RestSurface.v:313`). | mechanical, zero-trust | proves the retirement recipe on the easy 3 first; each is a self-contained `pure_walk` |
| **S2** | Retire the **6 writers**: remove from `exempt_ext_ids`; **verify every call site is covered by an `oc/wc/sc/wl/wol` recognizer arm** (CensusV2 recognizer `:656`) rather than the exempt arm — this is the census-surgery risk (§5). Discharge via `call_pres_ext_oc/_wc/_sc/_wl/_wol` (reuse `Hocp_find_floor`, `Hwcp_fwc` machinery). | HARD | phantom-false as plain `body_pres`; needs the gated classes + census reclassification |
| **S3** | Close (or document-as-boundary) the **5 ripple** bodies (§2c). Pure `atan2_lookup` is trivial; the `_from_list` out-param writers reuse S2's gated classes. | medium | only reachable once S1/S2 walks exist |
| **S4** | **Now** widen the link: `tu_rest`→13, add `linked14_LO_math`/`_surf` (`LinkedTwelve.v`), widen `no_internal_math`/`no_internal_surface` sweeps over the shrunk 7-id `truly_ext_pin_ids`, widen `fourteen_head`/`fourteen_tail` (`Linked12Sat.v`) and `fourteen_gvars_ok` (`InitMemSat.v`). Re-derive `linked14_ext_pin`, `linked14_inhabited`, `linked14_init_mem`. | mechanical (given S1–S3) | the pins are now safe: the negative pin no longer names any Internal-in-math/surface id |
| **S5** | Repoint the capstone(s) `NoAImpliesNoFlyLinked.v` / `NoAImpliesNoFlyTwelve.v` at the 14-TU link; run `discipline_check.sh` on all six capstone targets; confirm `Print Assumptions` clean and the negative pin satisfiable. | mechanical | capstone swap, like the #95 repair's final step |

**The trap to avoid** (spelled out because it *is* the failure mode): doing S4
before S1–S3 gives a green build in which `Hrest_ext_only` is again jointly
unsatisfiable — a re-vacuified capstone that `Print Assumptions` will call clean.
S1–S3 must land, `discipline_check` green with the *old* 12-TU link still in
place, before the link is widened.

---

## 5. The 9-id retirement table

| id | TU (body cite) | store class | discharging walker / gated class | proved-or-boundary |
|---|---|---|---|---|
| `atan2s` | math_util:12546 | PURE-SCALAR (0 stores; calls `atan2_lookup`) | `pure_walk` (vfc-minus-alloc) | **PROVED** zero-trust (+1 ripple) |
| `find_water_level` | surface_collision:3339 | PURE-SCALAR (0 stores, no calls) | `pure_walk` | **PROVED** zero-trust, no ripple |
| `find_poison_gas_level` | surface_collision:3494 | PURE + `_filler` alloc (0 stores, no calls) | `vfc_pres` template verbatim-minus-call | **PROVED** zero-trust, no ripple |
| `vec3f_set` | math_util:6129 | WINDOW-OUT-PARAM float `dest[0..2]` | `call_pres_ext_wc` (OutParamSurface:680) | gated (phantom-false as plain body_pres) |
| `vec3f_copy` | math_util:6075 | WINDOW-OUT-PARAM float `dest[0..2]` | `call_pres_ext_wc` | gated |
| `vec3s_copy` | math_util:6322 | WINDOW-OUT-PARAM short `dest[0..2]` | `call_pres_ext_sc` (OutParamSurface:762) | gated |
| `find_floor` | surface_collision:3050 | OUT-PARAM ptr-field `*pfloor` (+own locals) | `call_pres_ext_oc` (`Hocp_find_floor` class) | gated (+1 ripple `find_floor_from_list`) |
| `find_ceil` | surface_collision:2270 | OUT-PARAM ptr-field `*pceil` (+own locals) | `call_pres_ext_oc` (`Hocp_find_ceil` class) | gated (+1 ripple `find_ceil_from_list`) |
| `f32_find_wall_collision` | surface_collision:1727 | WINDOW-OUT-PARAM 3×float `*x/y/zPtr` (wall struct is OWN local) | `call_pres_ext_wl`/`_wol` (`Hwcp_fwc` class) | gated (+2 ripple `find_wall_collisions[_from_list]`) |

Ripple (reached-Internal, off all census lists today): `atan2_lookup`
(math_util:12515, pure), `find_floor_from_list` (surface_collision:2654),
`find_ceil_from_list` (surface_collision:1987), `find_wall_collisions`
(surface_collision:1808), `find_wall_collisions_from_list`
(surface_collision:709) — all `fn_vars := nil`, out-param writers or pure.

---

## 6. Open verification points (honest boundary of this scout)

1. **Census coverage of the 6 writers (the S2 risk).** `find_floor` et al. sit
   on `exempt_callees` (rest bucket, `EngineV2Consumer.v:109`) *and* are gated at
   their deep call sites by `Hocp_find_floor`/`Hwcp_fwc` (oc/wl bucket). Removing
   them from `exempt_callees` also removes them from `rest_fd`'s domain — which is
   safe **iff every call site is recognized through an out-param arm**, not the
   exempt arm, of the census recognizer (`CensusV2.v:656`). I did not trace every
   caller; **this must be verified before S2** (grep every `Scall (Evar
   _find_floor …)` site and confirm its enclosing walked body's recognizer routes
   it through `oc`/`wl`). If some site is exempt-only, that call needs an
   out-param arm added first.
2. **The gated `body_pres` shape.** The rest bucket's `body_pres`
   (`RestSurface.v:247`) has no out-param premise; the 6 writers therefore should
   **not** be discharged there at all — they belong in the oc/wl consumer, which
   is a different code path from `rest_pres_decompose`. Confirm the capstone
   consumes `find_floor` via the oc row and *not* via `Hrest_pres` once retired
   (else a gap opens).
3. **`math_util` pairwise `vm` cost** (§1b) — re-time before committing.
4. **Ripple policy** (§2c) — decide boundary-vs-walk per ripple id; if boundary,
   record the class-B trust in the ledger (audit §2 format), do not let a
   "harmless helper" comment stand un-walked (rule 1).

**Bottom line:** P1′ is the `vec3f_find_ceil` (#95) repair generalized to 9 ids,
split cleanly into **3 mechanical zero-trust pure walks** and **6 gated
out-param retirements** (reusing the oc/wc/sc/wl/wol keystones the SPP arc
already built), plus a **5-body ripple closure**, all of which must land **before**
the two `LO_*` pins are added — else the widened link re-vacuifies the exact row
the last week repaired. The link machinery itself (91-pair cert, init-mem cert,
LO pins) is a mechanical widening of length-generic lemmas; the campaign is the
9+5 body accounting, not the plumbing.

---

## 7. Ordering resolution — RETIRE-FIRST IS IMPOSSIBLE; the widen + 9 retirements are ONE ATOMIC COMMIT (task #90, 2026-07-09)

§4 orders the campaign **retire-first, then grow**. Slices A+B (task #90) were an
attempt to execute the *first* increment of that order — retire the 3 pure ids
(`atan2s`, `find_water_level`, `find_poison_gas_level`) against the **current
12-TU link**, before widening. **That increment cannot exist.** The retire-first
ordering is internally contradictory; the correct campaign structure is a single
atomic widen-and-retire commit (with an optional Unwired pre-stage). This section
is the machine-checked confirmation the director requested, with the exact cite
chain.

### 7.1 The three facts that close the question

**FACT 1 — the two TUs are absent from the current link.** `tu_rest`
(`LinkedTwelve.v:77–88`) has exactly **11** members
(`mario_actions_{stationary,moving,airborne,submerged,cutscene,automatic,object}`,
`interaction`, `behavior_actions`, `level_update`, `mario_step`). **Neither
`math_util.prog` nor `surface_collision.prog` is in it.** Stronger: `math_util` /
`surface_collision` are imported by **no** file under `proofs/` (`grep -rln` over
`proofs/**.v` returns nothing) and appear in **no** `_CoqProject`/`pipeline`
build input. They are clightgen'd (`generated/math_util.v`,
`generated/surface_collision.v`) but wholly outside the spine.

**FACT 2 — all 9 ids resolve EXTERNAL in the current `lp`.** In `mario.prog`'s
defmap every one of the 9 is `Gfun(External (EF_external …))` — verified for the
three pure ids at `generated/mario.v:12222` (`_atan2s`), `:12252`
(`_find_water_level`), `:12257` (`_find_poison_gas_level`); the six writers
likewise (`:12227` `_f32_find_wall_collision`, `:12238` `_find_ceil`, `:12245`
`_find_floor`, and `vec3f_set`/`vec3f_copy`/`vec3s_copy`). Their **only** Internal
bodies (`Definition f_atan2s`, `f_find_water_level`, `f_find_poison_gas_level`,
…) live in `generated/math_util.v` / `generated/surface_collision.v` — the two
**unlinked** TUs. `lp = link_chain mario.prog tu_rest` (`LinkedTwelve.v:90–91`) is
therefore, for each of the 9, a link of **agreeing Externals across all 12 TUs =
that External**. So in the current `lp` **there is no Internal body of any of the
9 to walk**, and the negative pin `Hrest_ext_only` (`RestSurface.v:155–158`,
covering `exempt_ext_ids` ∪ `{_play_infinite_stairs_music}`) is currently
**satisfiable/true** for all 9. (The 1-id refutation once either TU is linked is
machine-witnessed: `LinkedTwelve.capstone_negative_pin_refuted`,
`LinkedTwelve.v:436`.)

**FACT 3 — SLICE A fails for ALL THREE pure ids: removing them from
`exempt_callees` opens a coverage gap.** The census recognizer arm that catches
these call sites is `call_callee_exempt` (`CensusV2.v:654–658`): it matches
`Evar fid (Tfunction …)` **iff `mem_id fid exempt_callees = true`**. This is a
**purely syntactic** test on the *static* callee ident of the call site — it does
**not** consult `lp`'s resolution. The three pure ids have call sites *densely* in
the **linked, walked** bodies:

| id | `Evar` call-callee sites in linked TUs |
|---|---|
| `atan2s` | mario 6, moving 5, airborne 6, submerged 4, cutscene 9, interaction 6, behavior_actions 3, mario_step 5 (≈44) |
| `find_water_level` | mario 2, behavior_actions 14, mario_step 2 (18) |
| `find_poison_gas_level` | mario 1 |

Every one of these sites is recognized **only** through the exempt arm: the ids
are pure (no `MarioState*` head arg ⇒ **not** on `mptr_callees`, so no class-M
arm) and take no out-param (so no `oc/wc/sc/wl/wol` arm applies). Remove any of
the three from `exempt_callees` and `call_callee_exempt` returns `false` at all
its sites, the recognizer has **no** matching arm, and the walk of those bodies
**fails to typecheck**. Per the task rule ("if removing them from
`exempt_callees` WOULD open a coverage gap … STOP for that id"), **all three are
blocked** — including the "cleanest of all 9", `find_water_level`.

### 7.2 The paradox, stated precisely

- **Retire-first (remove from the exempt list *now*) is impossible.** By FACT 3
  the removal breaks recognizer coverage at dozens of walked call sites; and by
  FACT 2 there is no Internal body in `lp` for a replacement "walk" arm to
  discharge — a `body_pres`/`rest_internal_cases` case for `atan2s`
  (`RestSurface.v:182`) fires only on `rest_fd lp (Internal f)`, which for these
  ids is **never** inhabited at the 12-TU link. §4's S1 ("remove from
  `exempt_callees`, add `atan2s_pres` as a new `body_pres` case") is thus
  self-contradictory: the new case is dead while the removal is breaking.
- **Walk-now (SLICE B as literally scoped) is impossible.** You cannot walk the
  Internal body of `atan2s`/`find_water_level`/`find_poison_gas_level` in `lp`
  because `lp` has no such Internal body (FACT 2). The generated `f_atan2s` etc.
  can be reasoned about as **standalone AST facts**, but that is not a *walk in
  the capstone's `lp`*, and nothing consumes it.
- **Link-first re-vacuifies (§0).** Adding `LO_math`/`LO_surf` forces the 9
  Internal in `lp`, contradicting `Hrest_ext_only` (still naming them via
  `exempt_ext_ids`) → jointly unsatisfiable → the exact #95 vacuity, ninefold.

There is **no committed state** in which (a) the exempt list excludes the 9, (b)
the walked bodies still typecheck, and (c) the negative pin is satisfiable — for
any partial ordering. **VERDICT: the link-widen and the 9 retirements must be one
atomic commit.** Retire-first, as an incremental committable step, does not exist.

### 7.3 Recommended atomic-commit structure for the full 14-body campaign

Split the work into a **safe pre-stage** (freely committable, non-vacuous, adds
zero capstone trust) and **one atomic wiring commit**. This shrinks the atomic
commit to plumbing only, so it is reviewable and its green build is meaningful.

**Pre-stage (Unwired/, N commits, each green + `Print Assumptions`-clean):** prove
the 14 body facts as **standalone lemmas about the generated AST objects** in
`math_util.v` / `surface_collision.v`, with **no** edit to `tu_rest`,
`exempt_callees`, or the negative pin. These are honest facts about real bodies
(not vacuous, not disconnected in the harmful sense — they are the *content* the
atomic commit consumes) and touch `lp` nowhere:
  - 3 pure: `atan2s_pres`, `find_water_pres`, `find_poison_pres` via the
    `pure_walk`/`pure_chk` memory-identity walker (`MarioStepSurface.v`) and the
    `vfc_pres` alloc/free frame bricks (`RestSurface.v:96,122`) for the one with a
    `_filler` alloc.
  - 6 writers: the `call_pres_ext_oc/_wc/_sc/_wl/_wol` gated discharges
    (`OutParamSurface.v`) — reusing the SPP/resolve keystones (`Hocp_find_floor`,
    `Hwcp_fwc`, …).
  - 5 ripple (`atan2_lookup`, `find_{floor,ceil}_from_list`,
    `find_wall_collisions[_from_list]`) — pure walk / out-param gate.
  Because the two TUs are unlinked, these lemmas live in `Unwired/` (the firewall
  forbids the spine importing them) until the atomic commit promotes them.

**Atomic commit (single, green, `discipline_check` clean, negative pin
satisfiable at close):** in ONE step —
  1. `tu_rest` → 13 (`+ math_util.prog ; surface_collision.prog`); add
     `linked14_LO_math`/`_surf` (`LinkedTwelve.v`); add `LO_math`/`LO_surf` to
     `Section RestSurface` (`RestSurface.v:133`).
  2. **Shrink `exempt_callees`** (`CensusV2.v:601`) by the 9 **and** re-route each
     of their call sites: the 3 pure move to a new "pure internal callee" arm
     that discharges via the pre-staged `*_pres` (now that `lp` resolves them
     Internal); the 6 writers move onto the `oc/wc/sc/wl/wol` census lists so
     `call_callee_exempt` no longer needs them (this is §6-point-1's coverage
     surgery — it MUST be done in the same commit as the exempt-list edit, never
     before, or coverage breaks; never after, or the pin is unsatisfiable).
  3. **Restate the negative pin** so `exempt_ext_ids` excludes all 9 (the domain
     shrinks 16→7, `truly_ext_pin_ids` per §3); widen the
     `no_internal_math`/`no_internal_surface` sweeps over the 7 survivors (they
     now pass — the 7 are genuinely absent from both TUs).
  4. Add the 9 (+5 ripple) as new proved `rest_internal_cases` /
     `rest_pres_decompose` cases (pure) or gated consumer rows (writers),
     consuming the pre-staged Unwired lemmas.
  5. Widen the 3 certs (`fourteen_head`/`fourteen_tail` `Linked12Sat.v`,
     `fourteen_gvars_ok` `InitMemSat.v`) — time with `-time` first (§1b PERF LAW;
     the 25 `math_util`/`surface_collision` pairs may exceed 0.19 s each).
  6. Re-derive `linked14_ext_pin`/`_inhabited`/`_init_mem`; repoint the capstones;
     `discipline_check.sh` on all six targets; `Print Assumptions` clean.

At the close of step 6 the negative pin is satisfiable (it names no
Internal-in-`math_util`/`surface_collision` id) and every one of the 9 is
discharged by a consumed pre-staged lemma — so the capstone is non-vacuous at the
single commit boundary, and at **no** committed point is it vacuous.

**Amendment to §4:** the S0–S5 table's premise ("RETIRE FIRST, then GROW") is
withdrawn as a *committable* ordering. S1–S3 (the walks/gates) survive **only as
the Unwired pre-stage above**; S4 (widen) and the exempt-list/negative-pin edits
of S1–S3 collapse into the single atomic commit. The dependency §0 identified is
real; the resolution is atomicity, not sequencing.

**Task #90 outcome:** slices A+B produced **no `.v` code** (correctly — forcing
either would have broken coverage or re-vacuified the pin). Deliverable = this
§7. Next actionable unit = the Unwired pre-stage of the 3 pure `*_pres` lemmas
(zero-trust, zero-`lp`, freely committable), then the atomic wiring commit.

---

## §8 CORRECTION (2026-07-09, store-scout of find_floor/find_ceil)

§2b/§5 misclassified `find_floor`/`find_ceil` as "out-param-pointer-field,
`call_pres_ext_oc`". STORE-SCOUT (against the AST, verified) shows both also
write **static global counters**, so a pure `oc`-gated ge-generic fact is
PHANTOM-FALSE (nothing refutes `find_symbol ge gNumCalls = Some bm` at an
arbitrary `ge`; the `gNumCalls.floor` short-store could then hit `bm+12` and
break `action_sat`):

- `find_floor` (surface_collision.v:3050): 8 Sassign — 3 own-frame fn_var,
  **2** out-param `*_pfloor` (not 1), and **3 STATIC** writes:
  `gFindFloorIncludeSurfaceIntangible=0` (:3281), `gNumFindFloorMisses+=1`
  (:3293), `gNumCalls.floor+=1` (:3327). Calls `find_floor_from_list` ×3.
- `find_ceil` (:2270): 6 Sassign — own-frame + 2 out-param + **1 STATIC**
  (`gNumCalls.ceil+=1`, :2473). Calls `find_ceil_from_list` ×2.
- (All three globals are defined Gvars: v_gNumFindFloorMisses:625,
  v_gNumCalls:632, v_gFindFloorIncludeSurfaceIntangible:681.)
- `find_{floor,ceil}_from_list`: fn_vars=nil, exactly ONE out-param store
  `*_pheight` through a **float\*** (the `ol`/local-float class, NOT oc's
  Surface\*\*-last-arg), inside a **loop** (needs a loop-tolerant out-param
  walker — the oc bricks are straight-line). Clean, but their only consumers
  are find_floor/find_ceil, so premature to prove before the correction.

**Corrected fact shape:** find_floor/find_ceil need, IN ADDITION to the oc
out-param gate, per-static `stored_globals`-style ORACLE premises
(`find_symbol ge sym = Some b_sym /\ b_sym <> bm /\ store-into-b_sym-preserves-MWF`)
for the 3 counters — the exact analogue of atan2s's callee oracle, discharged
at the atomic wiring commit over `lp_ge` (where `Hglob_blk`/`stored_globals`
prove the counters `<> bm`). This is a heavier fact than the scoped oc class;
it is an honest refinement, not a blocker. ORDER: do the vec3 writers
(vec3f_set/copy/vec3s_copy — verify THEY are out-param-only, no statics) and
f32_find_wall_collision first; return to find_floor/ceil + their _from_list
loops with the oracle-augmented shape.
