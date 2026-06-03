# The reach_* residuals — inventory & discharge map

> **SCOPE CORRECTION (2026-06-02).** Earlier text below sizes the reachable graph
> at "~600 functions". That is **wrong**: the capstone's `mario_ge` is
> `globalenv mario.prog` — the **mario.c TU alone (62 internal functions)**, not a
> linked whole program. Cross-TU handlers (where 3 of the 5 flying sites live) are
> *external* and assumed via `reach_ext_action_cell`. See **`docs/theorem-scope.md`**
> for the corrected picture and the Job-A (in scope) / Job-B (needs linking) split.

After `body_preserves_real` was discharged (the `execute_mario_action` body is
now proved), the GOAL-1 capstone `noA_no_spawn_never_flying` rests on these
residual hypotheses, **all about the reached call graph, none about the frame
body itself**:

| # | residual (capstone) | informal meaning |
|---|---|---|
| 1a | `reach_value_body_nonwriter` | every reached **non-set_mario_action** body's **own direct** Sassigns are value-ok (avoid the action cell, or store a non-flying value) |
| 1b | `reach_writer_ok` (`reach_writer_preserves_noA`) | a reached `set_mario_action`, in a no-A frame, preserves **non-flying** (the taint-closure crux) |
| 1c | `reach_ext_action_cell` | reached externals don't write the action cell |
| 2 | `reach_rest_ok` (`reach_rest_noA`) | reached funcalls preserve `NoA`, `marioObj_wf`, `gMarioState_wf` |
| 3 | `ext_meminv_ok` | reached **externals** preserve `NoA` + full `meminv` |
| 4 | `noA_exec_ok` + `noA_entry_ok` | `NoA` survives any reached statement execution and any function entry |
| 5 | `input_grounds_noA` | a no-A frame's start memory satisfies `NoA` (input layer) |

> **2026-06-02 — the FALSE `reach_nonwriter_unchanged` was RETIRED.** Residual 1
> used to be `reach_nonwriter_ok` + `reach_writer_ok` glued by
> `reach_value_preserves_noA_split`. But `reach_nonwriter_unchanged` ("every
> reached funcall that is *not literally* `set_mario_action` leaves the action
> cell `unchanged_on`") is **false / unsatisfiable** for the real genv: writing
> the action cell is **transitive** (`act_walking` is not `set_mario_action` yet
> *calls* it). So that premise was vacuous. It is replaced by the sound
> `eval_funcall` value engine `ActionValueFrame.exec_funcall_reach_value_noA`
> (the value-twin of `exec_funcall_reach_unchanged_on`), which classifies a
> function's **own direct** Sassigns and lets the mutual induction carry
> transitivity through `Scall → funcall IH`. Residual 1 is now 1a/1b/1c above.

These split into **two layers** that want different tools.

---

## L1 — the mechanical aliasing layer (residuals 2, 3, 4)

*"Reached function X's stores land in blocks/offsets ≠ the watched cell(s)."*
Pure non-interference; no semantics of the ABC argument.

**Engine — ALREADY PROVED:**
- `FieldNonInterference.exec_funcall_reach_unchanged_on` — the mutual induction
  over `exec_stmt`/`eval_funcall`. Reduces *"every reached funcall preserves a
  watched byte-set P"* to a **per-function leaf** `reach_body_avoids P ge`
  (every reached function's `Sassign`s avoid P) + `reach_ext_preserves P ge`.

**What's left:** feed it `reach_body_avoids (action_cell bm)` etc., discharged by
- block-distinctness — `MarioMemWF` (static globals, no malloc ⇒ Mario's struct
  block ≠ Object blocks ≠ locals);
- offset-distinctness within `bm` (watched cells at fixed offsets);
- **cross-TU** calls resolved by symbolic linking (`LinkSpike` template).

**Sizing:** `execute_mario_action`'s reachable graph is the mario-action TUs —
`mario` (62), `mario_step` (23), `mario_actions_{airborne 64, moving 73,
submerged 57, stationary 44, cutscene 93, automatic 28, object 14}`,
`interaction` (68), `mario_misc` (25) ≈ **600 internal functions**.
It does **NOT** include `behavior_actions` (571 functions) — behaviors run in a
separate frame phase, outside `execute_mario_action`. Large but **uniform and
parallelizable** (a fan-out, once the per-function leaf lemma shape is fixed).

---

## L2 — the semantic crux (residual 1)

*"Every write of a FLYING value to the action cell is A-gated."* Does **not**
reduce to aliasing — this is the actual ABC content.

**Engine — ALREADY PROVED:** `ActionValueFrame.exec_stmt_value_preserves`
carries `action_sat` forward where each `Sassign` either *avoids* the cell **or**
*stores a Q-value* (non-flying). Its `eval_funcall` twin now also exists and is
proved: `ActionValueFrame.exec_funcall_reach_value_noA` (2026-06-02) — the mutual
induction reducing `reach_value_preserves_noA` to the per-direct-body leaf
(residual 1a) + the writer case (1b), retiring the false `reach_nonwriter_unchanged`.

**Write-side enumeration — ALREADY MACHINE-CHECKED in `Flying.v`** (`reflexivity`
`Example`s). The **only** route to a flying action value is
`set_mario_action(., FLYING_CONST, .)` at exactly **5 sites**:

| site | TU | constant |
|---|---|---|
| `set_jump_from_landing` | mario.c | `ACT_FLYING_TRIPLE_JUMP` |
| `act_shot_from_cannon` | mario_actions_airborne.c | `ACT_FLYING` |
| `act_flying_triple_jump` | mario_actions_airborne.c | `ACT_FLYING` |
| `set_triple_jump_action` | mario_actions_moving.c | `ACT_FLYING_TRIPLE_JUMP` |
| `set_mario_initial_action` | level_update.c | `ACT_FLYING` (spawn hatch — excluded by `no_spawn_flying_run`) |

Also proved: **no raw `m->action = <flyingConst>`** write anywhere
(`no_raw_flying_action_write_*`), the `set_mario_action_{airborne,moving,…}`
helpers never *fabricate* flying (`*_no_fabricate`), and **no behavior** is a
flying-setter (`no_behavior_is_a_flying_setter`).

**What's left (the two real gaps):**

- **(B1) Semantic bridge.** `Flying.v`'s facts are *syntactic* (about
  `flying_setters p` lists, per-TU). The capstone residuals are *semantic*
  (`eval_funcall`). **Nothing on the spine connects them** — the connectors
  (`ActionGraph`, `ActionWriters`, `NoAFlyingSpine`, `FlyingFrame`,
  `StoreFrameSpine`) currently live under `Unwired/` as sorry-spines. Promoting
  + completing this bridge is the load-bearing step.
- **(B2) Taint closure / A-gating.** Show each of the 4 non-spawn sites fires
  only under an A rising-edge:
  - `act_shot_from_cannon`, `act_flying_triple_jump` are reached *from within
    already-flying-class actions* — handled by the **inductive** taint set
    `T ⊇ {ACT_FLYING, ACT_FLYING_TRIPLE_JUMP, ACT_SHOT_FROM_CANNON}`: you are
    only in those actions if A was pressed on an earlier frame.
  - `set_jump_from_landing`, `set_triple_jump_action` need the A-press guard at
    their call site (the rising-edge input condition).
  - `set_mario_initial_action` is excluded by the `no_spawn_flying_run`
    precondition (the class-3 hatch).

---

## Cross-cutting

- **Cross-TU closure.** `Flying.v`'s `Example`s are *per-TU*. The whole-program
  *"only these 5 sites, program-wide"* claim is the union over TUs + symbolic
  linking — the per-TU bricks exist; the closure isn't assembled.
- **NoA grounding (residual 5 + the abstract `NoA`).** Currently `NoA` is an
  abstract `mem -> Prop`. Grounding it in the real controller bytes (the input
  word / A-bit) turns `noA_store_ok` and `input_grounds_noA` into block/offset
  facts of the same flavor as L1. Orthogonal track.

## Recommended sequencing

1. **B1 first** — build the `eval_funcall` `action_sat` engine + the
   syntactic→semantic bridge, so `reach_value_preserves_noA` reduces to the
   per-function leaf `reach_value_body_ok`. This retires the fragile top-level
   writer/non-writer split (writing is *transitive*, so a direct callee
   ≠ `set_mario_action` that transitively calls it does change the cell) and
   isolates the crux cleanly.
2. **L1 fan-out** — discharge `reach_body_avoids` over the ~600 mario-action
   functions via block/offset distinctness + symbolic linking. Parallelizable.
3. **B2 taint closure** — the inductive A-gating for the 4 sites. The real
   theorem; smallest in count, deepest in argument.
4. **Externals + NoA grounding** — separate, smaller tracks.
