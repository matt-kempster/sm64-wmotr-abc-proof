# Task #50 design: discharging (and de-vacuifying) `Hret_unsafe`

READ-ONLY scout, 2026-07-09. No `.v` edited. Goal: understand the exact
residual behind `Hret_unsafe`, design the extension that discharges it, and —
per the phantom-`forall` law — check that the residual is even *satisfiable*
before proposing to "extend" it.

**Bottom line up front (the loud flag):** the residual as stated is **not the
harmless syntactic gap the comments suggest.** Its **External arm is a
re-imported phantom-`forall` and is UNSATISFIABLE** — it is the same false
`forall ef` the project already deleted once (`Hret_ext`, see
`EngineV2Consumer.v:216-220`), let back in through `reached_v2`'s External
members. The fix is a **restatement of the residual / a small engine change**
(gate the return-value consumption on `optid = Some`), *not* a bigger tracker.
Only after that restatement do the honest, dischargeable pieces remain. Details
in §4.

---

## 1. The exact residual set

`Hret_unsafe` (`NoAImpliesNoFly/NoAImpliesNoFlyTwelve.v:201`, identical at
`NoAImpliesNoFlyLinked.v:496`) ranges over

```
reached_v2 lp fd  ∧  RetSurface.ret_fd_safe fd = false  ∧  RetSurface.fd_is_vint fd = false
```

`reached_v2` (`EngineV2Consumer.v:124`) `= censused_body Internal ∨ bridged_fd`,
where `bridged_fd` (`:114`) `= update_mario_button_inputs ∨ rest_fd`, and
`rest_fd` (`:107`) is the `resolves_lp` image of three ident lists:
`exempt_callees` (`CensusV2.v:601`), `root_residual_callees`
(`EngineV2Consumer.v:87`), `mptr_external_callees` (`:103`).

`ret_fd_safe` (`RetSurface.v:53`) is `false` exactly for `Tint I32`-returning
Internals and **for every External** (`:56`). `fd_is_vint` (`:863`) is `false`
for every External and for any Internal whose return is neither a
vint-tracked temp (`fn_vint_temp`, `:850`) nor an all-`vint_expr`-return body
(`ret_const_chk`, `:668`).

Enumerating `reached_v2` against these two filters (return types read from
`generated/`):

### 1a. Censused internals (`censused_body`, `CensusV2.v:2557`)

12 of the 15 return `tvoid` → `ret_ty_safe = true` → **dropped structurally**
(`eval_funcall_ret_safe`, `RetSurface.v:154`). Of the 4 `Tint I32` returns:

| fn | `fn_return` | why NOT in residual / IN residual |
|---|---|---|
| `mario_get_floor_class` | `tint` | `fd_is_vint = true` (temp arm) — discharged |
| `mario_get_terrain_sound_addend` | `tuint` | `fd_is_vint = true` (temp arm) — discharged |
| `mario_floor_is_slippery` | `tuint` | `fd_is_vint = true` (const arm) — discharged |
| **`update_and_return_cap_flags`** | `tuint` | **IN residual** — return temp `_flags` is a **field load** |

So exactly **one** censused internal survives: `update_and_return_cap_flags`
(`generated/mario.v`, `Sset _flags (Efield (Ederef _m) _flags …)` then bit-ops,
`Sreturn (Some (Etempvar _flags tuint))` at line ~214). This is a **getter that
returns a value read from Mario memory** (category (a) in the task) — NOT a call
result.

### 1b. `rest_fd` Internal members (resolve to Internal in linked12)

`root_residual_callees` splits (return types from the home TU's generated AST):

| ident | resolves to | `fn_return` | verdict |
|---|---|---|---|
| `mario_execute_stationary_action` | Internal (`mario_actions_stationary.v`) | `tint` | **IN residual** |
| `mario_execute_moving_action` | Internal (`…_moving.v`) | `tint` | **IN residual** |
| `mario_execute_airborne_action` | Internal (`…_airborne.v`) | `tint` | **IN residual** |
| `mario_execute_submerged_action` | Internal (`…_submerged.v`) | `tint` | **IN residual** |
| `mario_execute_cutscene_action` | Internal (`…_cutscene.v`) | `tint` | **IN residual** |
| `mario_execute_automatic_action` | Internal (`…_automatic.v`) | `tint` | **IN residual** |
| `mario_execute_object_action` | Internal (`…_object.v`) | `tint` | **IN residual** |
| `mario_handle_special_floors` | Internal (`interaction.v`) | `tvoid` | dropped structurally |
| `mario_process_interactions` | Internal (`interaction.v`) | `tvoid` | dropped |
| `spawn_wind_particles` | Internal (`behavior_actions.v`) | `tvoid` | dropped |
| `play_infinite_stairs_music` | **External** (home TU not linked) | `tvoid` | External arm (§1c) |

`mptr_external_callees`: `stub_mario_step_1` → Internal `tvoid` (dropped);
`level_trigger_warp` → Internal `tshort` = `Tint I16` → `ret_ty_safe = true`
(dropped, as `RetSurface.v:19` already notes).

So the `rest_fd` Internal residual is **exactly the 7 `mario_execute_*_action`
dispatchers** — category (b): the returned `I32` is a **call result**. Each ends
`Sset _cancel (Etempvar _t'k tint)` where `_t'k` is a `Scall` result, then
`Sreturn (Some (Etempvar _cancel tint))` (verified in
`f_mario_execute_stationary_action`: `Sset _cancel (Etempvar _t'3 tint)` /
`Sreturn (Some (Etempvar _cancel tint))`).

### 1c. `rest_fd` External members — 16 of them

`ret_fd_safe = false` and `fd_is_vint = false` unconditionally for Externals, so
**every reached External is in the residual regardless of its declared return
type**. From the `exempt_callees` list (minus `vec3f_find_ceil`, which is
`Internal`, `tfloat` → dropped) plus `play_infinite_stairs_music`:

| External | declared `tres` | tabled at a walked call site? |
|---|---|---|
| `find_floor`, `find_ceil`, `find_water_level`, `find_poison_gas_level` | `tfloat` | **Some** (tabled) |
| `sqrtf` | `tfloat` | **Some** (tabled) |
| `atan2s` | `tshort` | **Some** (tabled — in censused bodies, §4) |
| `f32_find_wall_collision` | `tint` | None (discarded) |
| `vec3f_set`, `vec3f_copy`, `vec3s_copy` | **`(tptr tvoid)`** | None (discarded) |
| `play_sound`, `set_camera_mode`, `print_text_fmt_int`, `stop_cap_music`, `fadeout_cap_music`, `play_infinite_stairs_music` | `tvoid` | None (discarded) |

"tabled?" was computed by scanning every `(Evar _fn …)` call site in
`generated/mario.v` for the enclosing `Scall (Some _t')` vs `Scall None`.

---

## 2. Why `fd_is_vint` fails on the survivors (confirming the gap)

`fd_is_vint`'s two arms both reason **syntactically about one body** and neither
follows a value across a `Scall`:

- `vint_expr` (`RetSurface.v:243`) accepts only `Econst_int`, a `vint_binop`
  `Ebinop`, or an `Ecast` to a sub-word int. It rejects `Efield` (a field load)
  and `Etempvar` (a temp holding a call result).
- `vint_body_chk`'s `Scall` arm (`:391`) only checks that the result ident is
  **not** the return temp (`negb (Pos.eqb id vt)`); it records **nothing** about
  what value the callee produced. A called function's return is opaque to the
  tracker.

Consequently:

- **`update_and_return_cap_flags`** fails because `Sset _flags (Efield …)` makes
  `vint_body_chk _flags` return `false` at the field load, and `ret_const_chk`
  fails because the return is `Etempvar _flags` (not a `vint_expr`).
- **The 7 dispatchers** fail because `Sset _cancel (Etempvar _t'k)` is not a
  `vint_expr` (temp arm dies), and `Sreturn (Some (Etempvar _cancel))` is not a
  `vint_expr` (const arm dies). Their return value **is** a `Scall` result — the
  exact case the comment at `RetSurface.v:222-225` flags as "needs an
  `eval_funcall` closure".
- **Externals**: `fd_is_vint (External _) = false` by definition (`:864`).

So the syntactic diagnosis is confirmed. But the *right* response differs
per class, and for the External class the honest response is **not** "extend the
tracker" — see §4.

---

## 3. The call-aware idea, and why the dispatchers should NOT get a bespoke tracker

The task proposes a call-aware `fd_is_vint'` that marks a body vint when its
return temp is fed from a `Scall` to an already-vint callee, closed as a
bottom-up fixpoint over the reached callgraph. That is sound in principle —
`CallgraphReach.v` gives the finite machinery (`callees`/`callees_s` `:45,61`,
`reach`/`reaches` `:77,92`) to enumerate the actual callee set and avoid the
"all callees" phantom, and the soundness proof would strengthen the currently
trivial `Q := True` funcall predicate in `exec_stmt_vint`'s mutual induction
(`RetSurface.v:482`) to carry "if the callee ident is on the established-vint
safelist then `no_vptr_val vres`".

**But it is the wrong tool here, for a tethering reason.** The 7 dispatchers are
already `reached_v2` **via `rest_fd`**, and their *whole-funcall* preservation is
already owed by **`Hrest_pres`** (`EngineV2Consumer.v:200`), the rest surface
that the A-gating taint closure (`Taint.v`/`AGates.v`) discharges. Building a
separate syntactic call-aware tracker would:

- duplicate a walk the rest surface already performs, and
- require certifying `ret_const_chk`/vint for the **~100+ `act_*` handlers**
  each dispatcher switches into (the leaves feeding `_cancel`) — a large
  `vm_compute` census that buys nothing the taint walk doesn't already touch.

**Recommended instead:** extend `Hrest_pres`'s *conclusion* with the
return-value fact, i.e. add `∧ (forall b o, vres = Vptr b o -> b <> bm)` to its
postcondition (`EngineV2Consumer.v:206`). Then the dispatcher return obligation
is discharged wherever the rest surface is discharged, with no new tracker and
no handler census. This is a decomposition (Step 2/§3 of `proof-discipline`),
not a new island: the fact rides the walk that already exists.

(If one insists on the syntactic route regardless, the fixpoint shape is:
`callee_vint : ident -> bool` seeded from `ret_const_chk`/`fn_vint_temp` leaves,
extended one callgraph layer at a time via `CallgraphReach.callees`; the
dispatchers land at layer 1. It is *more* code and *more* trust surface than the
`Hrest_pres` conjunct.)

---

## 4. Non-vacuity / tethering audit — the critical part

For each residual member, does the proposed fix **discharge** `Hret_unsafe` (turn
it into a lemma), or is the member a **genuine obligation** (a real pointer
return) that no tracker can wish away?

### 4a. The External arm is UNSATISFIABLE as stated — a latent vacuity

`Hret_call` is consumed **unconditionally at every `Scall`** in a walked body:
`ActionValueFrame.v:1518-1529` applies `Hret_call f … Hfd` and feeds it to
`HTI_optc`, *even when `optid = None`* (`set_opttemp None v le = le`, so the fact
is unused but still demanded). So the residual must be **true for every reached
funcall**, discarded results included.

Now consider the reached Externals with **discarded** results (`Scall None`):
`vec3f_copy`/`vec3f_set`/`vec3s_copy` (declared `(tptr tvoid)`), and the `tvoid`
audio/camera/print helpers. Under CompCert's `external_call` axioms an
`EF_external` result is only constrained by `external_call_well_typed`:
`Val.has_type vres (proj_sig_res sig)`. For `sig_res ∈ {Tvoid, Tint, Tlong,
Tany*}` — and, on `ptr64 = false`, for `Tint` — `has_type (Vptr bm o) _ = True`.
So the axioms **permit** `vres0 = Vptr bm o`. The blanket `forall`
`vres0 = Vptr b o -> b <> bm` is therefore **not provable, and false in an
adversarial model** — precisely the `EF_vload`/`EF_memcpy` counterexample that
got `Hret_ext` **deleted** (`EngineV2Consumer.v:216-220`). It re-entered through
`reached_v2 (External …)`.

This is a **phantom-`forall`** (`proof-discipline` §"We don't need `forall`"):
the residual quantifies over a return value the program never consumes. The
`(tptr tvoid)` vector helpers are the sharpest illustration — they return their
*destination*, which at a Mario-interior call would be `Vptr bm _`, i.e.
`b = bm` outright. They happen to be **discarded everywhere** (verified: all
`Scall None`), so nothing breaks operationally — but the *stated hypothesis* is
false, so the capstone currently rests on an unsatisfiable assumption. **Flag
loudly.**

**Required fix (satisfiability, not gold-plating):** make the engine's return
consumption `optid`-conditional. Change `HTI_optc`/`HTI_optb`
(`ActionValueFrame.v:1434-1439`) so the `(forall b o, v = Vptr b o -> b<>bm)`
premise is only required when `optid = Some _` (for `None`, `set_opttemp` is
identity and `TI le` already holds). Then re-derive `Hret_call` only over
**tabled** calls. This deletes the discarded-External obligations entirely and
makes the residual satisfiable. This is an **engine (ActionValueFrame) change**,
low-to-moderate, and it is the load-bearing step.

### 4b. What survives after 4a — all honestly dischargeable

- **Tabled float externals** — `find_floor`, `find_ceil`, `find_water_level`,
  `find_poison_gas_level`, `sqrtf` (all `Scall (Some _)`, `tfloat`). Discharge
  with **`external_call_well_typed`**: `has_type vres Tsingle` and
  `Val.has_type (Vptr _ _) Tsingle = False`, so `vres` is not a `Vptr` at all.
  **Zero trust, mechanical.**
- **`atan2s`** — tabled (`Scall (Some _)`) inside *censused* bodies
  (`debug_print_speed_action_normal`, `update_mario_joystick_inputs`,
  `update_mario_geometry_inputs`), return `tshort`. `has_type (Vptr _ _) Tint =
  True` on `ptr64=false`, so well-typedness does **not** rule out a pointer. This
  is a **genuine model-boundary obligation**: keep it as ONE named per-symbol row
  (the honest boundary, exactly like `Hext_action`/`Hmwf_ext`,
  `EngineV2Consumer.v:221-228`): `reached_v2 (External atan2s …) → external_call
  → vres ≠ Vptr _`. True of the real angle routine; finite; not a tracker gap.
- **`update_and_return_cap_flags`** (censused, `tuint`, field-load return). A
  **scalar-field getter**, category (a). A purely syntactic "`Efield`-of-scalar
  is non-`Vptr`" arm would be **UNSOUND** on `ptr64=false`: a `Mint32` load over
  a cell where a pointer was stored decodes back to `Vptr` (see memory note
  *ptr32-cast-pointer-passthrough*). Discharge instead with an **MWF field-load
  projection**, the twin of `HactVint` (`EngineV2Consumer.v:134`): "`Mint32` load
  from `bm + off(flags)` yields `Vundef` or `Vint`" ⇒ `_flags` is non-`Vptr` ⇒
  return non-`Vptr`. LOW effort; mechanical; mirrors an existing row.
- **7 dispatchers** — fold return non-`Vptr` into `Hrest_pres` (§3). Discharged
  with the rest surface; no new tracker.

### 4c. Verdict

`update_and_return_cap_flags`, the dispatchers, and the tabled float externals
**can all be fully discharged** (turning that slice of `Hret_unsafe` into
lemmas). The External blanket **cannot** be discharged as written — it is
false; it must be **restated** (4a). `atan2s` remains as an honest, finite,
true boundary row. **No residual member is a real `Vptr bm` return that needs
SafeB-return/mgco treatment** — the one `Vptr`-returning family (the vec3
helpers) is discarded, so §4a's `optid`-gate is the correct fix, not aliasing
analysis.

---

## 5. Residual-fd table

| fd | `fn_return`/`tres` | in `reached_v2` via | why unsafe now | class | fix |
|---|---|---|---|---|---|
| `update_and_return_cap_flags` | `tuint` | censused | return temp `_flags` = field load; `vint_body_chk` rejects `Efield` | MWF field-load (getter) | add `HflagsVint` MWF row (twin of `HactVint`); mechanical |
| `mario_execute_{stationary,moving,airborne,submerged,cutscene,automatic,object}_action` (×7) | `tint` | `rest_fd`/`root_residual` | return `_cancel` = `Scall` result; tracker won't follow a call | call-result / rest surface | add `∧ vres≠Vptr bm` to `Hrest_pres` conclusion; discharged by the taint walk |
| `find_floor`, `find_ceil`, `find_water_level`, `find_poison_gas_level`, `sqrtf` | `tfloat` | `rest_fd`/`exempt` (External) | External ⇒ `ret_fd_safe`/`fd_is_vint` false; but **tabled** | well-typed float | `external_call_well_typed` (`Vptr ∉ Tsingle`); zero trust |
| `atan2s` | `tshort` | `rest_fd`/`exempt` (External) | External + tabled; `has_type Vptr Tint = true` | honest model boundary | ONE named per-symbol row (like `Hext_action`); true, finite |
| `vec3f_copy`, `vec3f_set`, `vec3s_copy` | `(tptr tvoid)` | `rest_fd`/`exempt` (External) | **can return `Vptr bm`** (dest = Mario interior) — makes the blanket **false** | phantom (discarded) | §4a `optid`-gate the engine; obligation vanishes |
| `f32_find_wall_collision` | `tint` | `rest_fd`/`exempt` (External) | External blanket; discarded | phantom (discarded) | §4a `optid`-gate |
| `play_sound`, `set_camera_mode`, `print_text_fmt_int`, `stop_cap_music`, `fadeout_cap_music`, `play_infinite_stairs_music` | `tvoid` | `rest_fd`/`exempt`+`root_residual` (External) | External blanket; discarded | phantom (discarded) | §4a `optid`-gate |

Dropped structurally (for the record, NOT in residual): 12 `tvoid` censused +
umbi; `mario_handle_special_floors`/`mario_process_interactions`/
`spawn_wind_particles`/`stub_mario_step_1` (`tvoid`); `level_trigger_warp`
(`Tint I16`); `vec3f_find_ceil` (Internal `tfloat`); and the three
already-`fd_is_vint` getters.

---

## 6. Recommended implementation shape and ordered slices

The keystone is **the engine `optid`-gate (Slice 1)** — without it the capstone
rests on a false hypothesis, and the other slices only shrink a vacuous surface.

1. **Engine `optid`-gate (ActionValueFrame).** Make `HTI_optc`/`HTI_optb`
   premises conditional on `optid = Some`; re-thread the `Scall`/`Sbuiltin`
   cases (`:1518-1539`) so `Hret_call` is invoked only for tabled results.
   Re-derive `Hret_call`/`ret_avoids_bm_of_unsafe_vint` accordingly. **Removes
   the entire discarded-External phantom.** *Needs engine surgery; moderate.*
2. **Well-typed float externals (RetSurface).** A small lemma:
   `external_call ef … vres → proj_sig_res (ef_sig ef) = Tsingle → no_vptr_val
   vres`, plugged into the tabled `find_*`/`sqrtf` sites. *Mechanical.*
3. **`atan2s` boundary row.** Add one `reached_v2 (External atan2s …)` row to the
   capstone's external boundary block (beside `Hext_action`). *Mechanical, honest
   trust.*
4. **`update_and_return_cap_flags` MWF row.** Add `HflagsVint` (twin of
   `HactVint`) and either walk the body in the value engine or discharge its
   return leaf directly. *Mechanical.*
5. **Dispatcher `Hrest_pres` conjunct.** Add `∧ vres≠Vptr bm` to `Hrest_pres`'s
   conclusion; the 7 dispatchers' return obligation then rides the rest walk.
   *Needs the `Hrest_pres` restatement + re-plumbing where it is consumed;
   moderate, but reuses the existing taint closure — no new induction.*

After 1-5, `Hret_unsafe` is gone: the survivors are `Hret_call` lemmatized
(structural + well-typed + MWF `HflagsVint`) plus two honest, finite,
true boundary/rest rows (`atan2s`, the `Hrest_pres` conjunct). Net tethering
move: a **latent vacuity is removed** (Slice 1) and the remaining real
obligations are decomposed onto existing machinery rather than a bespoke
syntactic call-aware tracker.

### Anti-goals (per proof-discipline)
- Do **not** ship a call-aware `fd_is_vint'` fixpoint for the dispatchers — it
  re-walks the rest surface and drags in a ~100-handler census (§3).
- Do **not** add an `Efield`-of-scalar arm to `vint_expr` — unsound on
  `ptr64=false` (§4b).
- Do **not** "prove" the External blanket — it is false; restate it (§4a).
