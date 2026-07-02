# GOAL-1 capstone hypothesis-surface consistency audit (2026-07-02)

Scope: `noA_no_spawn_never_flying_real_mwf`
(`proofs/NoAImpliesNoFly/NoAImpliesNoFlyLinked.v:2451`), section
`NoARealInputMWF` (lines 651–3258). Goal: find every sibling of the
`vec3f_find_ceil` vacuity bug — a hypothesis row that quietly asserts a symbol
is external/unresolvable while a generated TU contradicts it.

Method: enumerated every function/id-list mentioned by the section's
`Hypothesis` rows, deduped by name (idents are string-interned, so the TU
prefix is irrelevant), and machine-checked each name for an Internal body
`^Definition f_<name>` across all 17 generated TUs. **READ-ONLY audit; no .v
file was edited.**

The 12 linked TUs (per `LinkedTwelve.tu_rest`): `mario`,
`mario_actions_{stationary,moving,airborne,submerged,cutscene,automatic,object}`,
`interaction`, `behavior_actions`, `level_update`, `mario_step`.
The 4 non-linked (matter only for the future 14-TU "P1'" plan): `math_util`,
`surface_collision`, `mario_misc`, `shadow`.

---

## 0. The one structural fact that bounds the whole audit

There are **exactly three** `~ resolves_lp lp fid (Internal f)` externality
assertions in the entire proof tree:

| site | ranges over | status |
|---|---|---|
| `LinkedTwelve.v:392` `linked12_ext_pin` | `truly_ext_pin_ids` (16 ids) | **PROVED** (12 per-TU `vm_compute` sweeps) |
| `RestSurface.v:65` | stub shape | scaffold |
| `NoAImpliesNoFlyLinked.v:794–797` `Hrest_ext_only` | `exempt_callees` (16) + `_play_infinite_stairs_music` = 17 ids | **on the live capstone; REFUTABLE** |

Everything else that "looks external" — every `Hpres_*_ext` row and every
named `call_pres_ext*` row — is consumed via `call_pres_ext` (and its
`_oc/_sc/_w1/_wl/_wol/_ol/_sr` variants), whose definition
(`FloorsSurface.v:242`) quantifies over `fd` via `resolves_lp lp fid fd` and
asserts *preservation of the run facts for whatever `fd` resolves to*. It does
**not** assert externality. Therefore:

* **A refutation (vacuity) can only arise on `Hrest_ext_only`** (and, in
  principle, `WL_exempt`) — those are the only rows whose truth requires a
  symbol to stay non-Internal.
* A `call_pres_ext*` row on an id that turns out Internal is **satisfiable**
  (the body probably does preserve) but is a **trust-accounting defect**: the
  "honest terminal-external model boundary" story in its comment is wrong — it
  is silently trusting an **unwalked Internal body** reachable in `lp`.

This cleanly separates class A (vacuity bugs) from class B (mislabeled but
sound).

---

## 1. Class A — REFUTATION-CLASS (vacuity bugs) — LEAD FINDING

### 1.1 Today's 12-TU link: `vec3f_find_ceil` is the ONLY one

`exempt_callees` (`CensusV2.v:601`) has 16 members; `Hrest_ext_only`
(`NoAImpliesNoFlyLinked.v:794`) additionally names `_play_infinite_stairs_music`.
Machine sweep of all 16 exempt ids + the music helper against the 12 linked TUs:

* **`vec3f_find_ceil`** — Internal in **`mario.prog`** (`generated/mario.v:3382`
  `f_vec3f_find_ceil`, from mario.c:547). `mario.prog` is linked
  (`LO_mario`), so `Hrest_ext_only` forces `~ resolves_lp lp _vec3f_find_ceil
  (Internal f)` while `LO_mario` forces exactly that resolution — **jointly
  unsatisfiable**. This is the known bug, machine-witnessed by
  `LinkedTwelve.capstone_negative_pin_refuted` (`LinkedTwelve.v:435`), tracked
  as task #95, blocking P3 slice 2. It appears at `CensusV2.v:605`.
* **The other 15 exempt ids + `_play_infinite_stairs_music`**: none has an
  Internal body in any of the 12 linked TUs. **No new 12-TU vacuity bug.**

So on the link as it exists today, `Hrest_ext_only` has **exactly one**
refuting id, and it is the one already found. The audit confirms there is no
undiscovered sibling *within the current link*.

### 1.2 `WL_exempt` is NOT refutable (checked per step 4)

`WL_exempt` (`NoAImpliesNoFlyLinked.v:768`) asserts `marg_exempt fd = true` for
every `exempt_callees` id. The only exempt id with an Internal body in a linked
TU is `vec3f_find_ceil`; its `fn_params` first parameter is
`(_pos, tptr tfloat)` (`generated/mario.v:3383`), **not** a `MarioState*`, so
`marg_exempt` of its real body is `true`. `WL_exempt` is therefore satisfiable
for the intended link. **No loud flag.** (This is why the #95 repair is a
routing change on the negative pin, not a `marg` problem.)

### 1.3 LATENT class-A: the same bug is armed for **9 more** exempt ids under the faithful link

`vec3f_find_ceil` is caught today only because it happens to live in `mario.c`
(a linked TU). Its true siblings hide in `math_util` and `surface_collision`,
which are **not yet linked**. Of the 16 `exempt_callees`, these are Internal in
a non-linked TU and become refutation-class the instant that TU joins the link:

| exempt id | Internal in (non-linked) |
|---|---|
| `atan2s` | math_util |
| `vec3f_set` | math_util |
| `vec3f_copy` | math_util |
| `vec3s_copy` | math_util |
| `f32_find_wall_collision` | surface_collision |
| `find_floor` | surface_collision |
| `find_ceil` | surface_collision |
| `find_poison_gas_level` | surface_collision |
| `find_water_level` | surface_collision |

So the honest count is: **`vec3f_find_ceil` is the first of ten** exempt ids
that a faithful model must route through gated internal rest cases. The #95
repair should be designed to generalise, not to special-case one symbol. See
§5 for the exact interaction with `truly_ext_pin_ids`.

The 7 exempt/music ids that survive as genuine externals even in a full 17-TU
link (no Internal body anywhere under `generated/`): `sqrtf`,
`print_text_fmt_int`, `set_camera_mode`, `stop_cap_music`, `fadeout_cap_music`,
`play_sound`, `_play_infinite_stairs_music`.

---

## 2. Class B — MISLABELED-BOUNDARY (satisfiable, comment/trust wrong)

Rows whose comment claims "EF_external in EVERY linked TU / honest terminal
model boundary" but whose id has an Internal body in a **linked** TU. The row
(`call_pres_ext*`, behavioral) is **satisfiable**, so the capstone is not
vacuous — but the assumption is really trusting an **unwalked Internal body**,
and the trust ledger / comment must be corrected. Walk-cost = clightgen'd
`f_<name>` AST body span (lines).

| id | consuming row | list | Internal in | walk-cost | param0 |
|---|---|---|---|---|---|
| `load_level_init_text` | `Hpres_sta_ext` (`:816`) | `sta_ext_ids` (`StationaryLeafSurface.v:916`) | level_update | ~95 L | `tuint` |
| `play_mario_heavy_landing_sound` | `Hpres_sta_ext` | `sta_ext_ids` | mario | ~40 L | **`MarioState*`** |
| `play_sound_if_no_flag` | `Hpres_sta_ext` + `Hpres_mov_ext` | `sta_ext_ids`, `mov_ext_ids` | mario | ~48 L | **`MarioState*`** |
| `play_mario_heavy_landing_sound_once` | `Hpres_mov_ext` (`:855`) | `mov_ext_ids` (`MovingLeafSurface.v:51`) | mario | ~40 L | mario-ptr* |
| `play_mario_landing_sound_once` | `Hpres_mov_ext` | `mov_ext_ids` | mario | ~40 L | mario-ptr* |
| `play_mario_landing_sound` | `Hpres_mov_ext` | `mov_ext_ids` | mario | ~40 L | **`MarioState*`** |
| `bhv_spawn_star_no_level_exit` | `Hpres_obj_ext` (`:1183`) | `obj_ext_ids` (`ObjectLeafSurface.v:116`) | behavior_actions | ~52 L | `tuint` |
| `init_bully_collision_data` | `Hcpx_ibcd_real` (`:1660`) | (named) | mario_step | ~83 L | `BullyCollisionData*` |
| `transfer_bully_speed` | `Hcpx_tbs_real` (`:1663`) | (named) | mario_step | ~208 L | `BullyCollisionData*` |

Notes:
* The four `play_mario_*_sound*` helpers and `play_sound_if_no_flag` take
  `MarioState*` as arg0. Their comments assert "writes no Mario state"; that is
  an **unverified** claim about a linked Internal body. They are sound-effect
  helpers (almost certainly true), but a walk is required to discharge, and the
  ~40–48-line bodies are cheap.
* `init_bully_collision_data` (~83 L) and `transfer_bully_speed` (~208 L) are
  flagged in the memory ledger's "terminal-external boundary
  (…init+transfer_bully…)" note — that note is wrong: both are Internal in
  `mario_step.prog`. `transfer_bully_speed` is the largest class-B walk.
* Total class-B walk debt ≈ **9 bodies, ~446 lines**. All are behavioral rows,
  so this is honest-but-owed work, not a vacuity.

### 2.1 Expected-Internal (NOT bugs — correctly modeled as internal / class M)

`mptr_callees` (`CensusV2.v:615`) deliberately routes MarioState-first-arg
callees as class M (resolved through their home TU by `linkorder`, **not** the
exempt whitelist). Their Internal bodies are expected and documented; they are
on no externality pin:

* Internal in `mario`: `update_mario_button_inputs`,
  `update_mario_joystick_inputs`, `update_mario_geometry_inputs`,
  `debug_print_speed_action_normal`, `mario_get_terrain_sound_addend`,
  `mario_floor_is_slippery`, `mario_get_floor_class`,
  `update_and_return_cap_flags`.
* Internal in `mario_step` / `level_update`: `stub_mario_step_1`,
  `level_trigger_warp` (also `mptr_external_callees`, `EngineV2Consumer.v:103`).
  `CensusV2.v:596–600` explicitly documents why these two are kept OFF
  `exempt_callees` (they take `MarioState*` first, so whitelisting them would
  make `WL_exempt` unsatisfiable) — i.e. the codebase already applies exactly
  the reasoning this audit uses, and applies it correctly here.

---

## 3. Class C — HONEST-EXTERNAL (the real trust boundary)

Ids on capstone rows with **no Internal body in any of the 17 generated TUs**
— the genuine model boundary for the announcement doc. Grouped:

**C-genuine (no Internal anywhere; safe under any link):** `sqrtf`,
`print_text_fmt_int`, `set_camera_mode`, `stop_cap_music`, `fadeout_cap_music`,
`play_sound`, `_play_infinite_stairs_music`, and the audio/dialog/save/camera/
object-pool externals from `obj_ext_ids`, `cut_ext_ids`, `warp_ext_ids`,
`floors_ext_ids` and the named rows: `segmented_to_virtual`,
`virtual_to_segmented`, `stop_shell_music`, `obj_set_held_state`,
`load_patchable_table`, `set_sound_moving_speed`, `set_camera_shake_from_hit`,
`save_file_get_flags`, `save_file_get_total_star_count`,
`save_file_collect_star_or_key`, `save_file_set_flags`,
`save_file_clear_flags`, `save_file_do_save`, `save_file_set_cap_pos`,
`play_cap_music`, `play_shell_music`, `drop_queued_background_music`,
`fadeout_level_music`, `override_viewport_and_clip`, `reset_cutscene_msg_fade`,
`create_dialog_inverted_box`, `trigger_cutscene_dialog`,
`create_dialog_box{,_with_var,_with_response}`, `get_dialog_id`,
`play_cutscene_music`, `spawn_object`, `spawn_object_abs_with_rot`,
`spawn_default_star`, `disable_background_sound`, `enable_background_sound`,
`disable_time_stop`, `enable_time_stop`, `play_course_clear`, `play_music`,
`set_menu_mode`, `play_peachs_jingle`, `fadeout_music`, `play_transition`,
`camera_approach_f32_symmetric`, `sound_banks_enable`, `obj_mark_for_deletion`,
`set_cutscene_message`, `seq_player_lower_volume`, `seq_player_unlower_volume`,
`obj_scale`, `area_get_warp_node`, `get_current_background_music`,
`geo_update_animation_frame`, `retrieve_animation_index`,
`raise_background_noise`, `lower_background_noise`, `stop_sound`.

**C-math (Internal in `math_util`; external ONLY because math_util isn't
linked):** `approach_f32`, `approach_s32`, `atan2s`, `anim_spline_init`,
`anim_spline_poll`, `mtxf_align_terrain_triangle`, `vec3f_copy`, `vec3f_set`,
`vec3s_copy`, `vec3s_set`.

**C-surface (Internal in `surface_collision`; external ONLY because it isn't
linked):** `f32_find_wall_collision`, `find_ceil`, `find_floor`,
`find_poison_gas_level`, `find_wall_collisions`, `find_water_level`.

C-math and C-surface are the **P1' 14-TU ledger**: each becomes class B (or
class A, if also on `exempt_callees` — see §5) the day math_util/
surface_collision join the link.

---

## 4. Class D — NON-FUNCTION (global-symbol rows)

Checked that each global id is a real `Gvar` in ≥1 linked TU (not dangling):

* `stored_globals` (`CensusV2.v:780`, 42 ids, consumed by `Hglob_blk`
  `NoAImpliesNoFlyLinked.v:676`): **all 42 are Gvars** in a linked TU
  (mario / cutscene / level_update / interaction / submerged / moving / step).
  No dangling id.
* `gobj_ids` (`CutsceneLeafSurface.v:600`, 5 ids, consumed by `Hglob_obj_root`
  `:1157`): all 5 are Gvars in `mario_actions_cutscene`. Clean.
* `knockback_table_ids` (`MWFReal.v:87`, 11 ids, consumed by `Hktab_blk`
  `:694`): all 11 are Gvars (2 in `interaction`, 9 in `mario_actions_moving`).
  Clean.

**No class-D discrepancy.** Every global row names a real symbol.

---

## 5. DISCREPANCIES vs `LinkedTwelve.truly_ext_pin_ids` (16 ids) + OPEN items

`truly_ext_pin_ids` (`LinkedTwelve.v:332`) =
`_play_infinite_stairs_music :: (exempt_callees \ {_vec3f_find_ceil})` = 16 ids.
`linked12_ext_pin` PROVES via 12 per-TU `vm_compute` sweeps that none of these
16 is Internal in any of the **12** linked TUs. This audit confirms that (all
16 show `L:[]`). **Consistent — no discrepancy against the 12-TU claim.**

The discrepancy is against the *intended full model*: **9 of the 16
`truly_ext_pin_ids` are Internal in `math_util`/`surface_collision`** —
`atan2s`, `vec3f_set`, `vec3f_copy`, `vec3s_copy` (math_util);
`f32_find_wall_collision`, `find_floor`, `find_ceil`, `find_poison_gas_level`,
`find_water_level` (surface_collision). The two `vm_compute` lemmas a faithful
14-TU version would need (`no_internal_math_util`, `no_internal_surface_collision`
over `truly_ext_pin_ids`) would **FAIL**. Only **7** of the 16 survive as
genuine externals in a full link (the C-genuine subset from §1.3).

**Bottom line for the announcement doc:** the "16 genuinely external ids" and
the whole `exempt_callees`/`Hrest_ext_only` externality story are **artifacts of
the 12-TU scope**. `vec3f_find_ceil` is not a lone typo; it is the one member of
a 10-symbol family (all the math/surface vector+geometry helpers) that happens
to live in an already-linked TU. The #95 repair must route the whole family
through gated internal rest cases (its `marg_exempt` first-param check is fine
for all of them — they take `float*`/`Surface**` first, not `MarioState*` — so
`WL_exempt` stays sound throughout).

### Open items / caveats
1. **Class-A latent (P1'):** 9 exempt ids armed to refute at 14-TU (§1.3). Fix
   #95 generically.
2. **Class-B walk debt:** 9 unwalked linked-Internal bodies on behavioral rows
   (~446 L, §2). Comments/ledger say "external"; correct to "internal, gated,
   preservation-owed." Biggest: `transfer_bully_speed` (~208 L).
3. **`NoAImpliesNoFlyTwelve.v`** (the staged P3-slice-2 spine consumer) already
   consumes `linked12_rest_ext_only` and is correctly marked blocked on #95
   (`NoAImpliesNoFlyTwelve.v:1–4`); excluded from `_CoqProject`. Not a new bug.
4. Walk-costs are raw AST line spans (proxy), not proof-effort estimates.
5. This audit covers the `real_mwf` capstone's section rows only. The three
   blanket rows `Hext_action`/`Hmwf_ext` (`:2055/:2059`, restricted to
   `External ef` by construction) and `Hret_unsafe` (`:2036`, over reached
   fundefs) carry no id list and are fine by construction.
