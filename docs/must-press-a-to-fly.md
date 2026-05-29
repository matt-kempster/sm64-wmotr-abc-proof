# Goal: "you must press A to enter wing-cap flight (ACT_FLYING)"

> Lofty, explicitly shelvable goal (set 2026-05-29). This doc is the working spec, written so
> the goal survives a context compaction. See also
> [whole-program-and-the-interpreters.md](whole-program-and-the-interpreters.md) (this is the
> interpreter-free "thread 1b" beachhead) and [trust-model.md](trust-model.md).

## Why this matters for WMotR

WMotR = **Wing Mario Over the Rainbow** (`levels/wmotr/`), not Watch for Rolling Rocks.
`levels/wmotr/script.c:29` spawns `bhvHiddenRedCoinStar`; `levels/wmotr/areas/1/macro.inc.c`
has exactly **8** `macro_red_coin` objects at heights y ∈ {3990, 3140, **4600**, 240, −2680,
−1360, 1725, **4600**} (range −2680..4600). The two y=4600 coins sit high on the clouds and
need wing-cap altitude. Wing-cap flight is the action **`ACT_FLYING`**. So:

> If every way to enter `ACT_FLYING` requires an A press, then a no-A run cannot gain the
> altitude to reach the high red coins ⇒ can't collect all 8 ⇒ `bhvHiddenRedCoinStar` never
> spawns ⇒ the star is unobtainable A-free.

This is one self-contained limb of the full WMotR argument, and it is **interpreter-free**
(pure Mario-physics action code), which is why it's a good beachhead.

## The entry points to ACT_FLYING (the scouted enumeration)

Found by grepping `set_mario_action(_, ACT_FLYING…, _)` across `src/game/`. Every transition
into flying is one of three classes:

| # | Entry site | Immediate predecessor | A-gated? |
|---|------------|------------------------|----------|
| 1 | `act_flying_triple_jump` apex — `mario_actions_airborne.c:1934` (`if (m->vel[1] < 4.0f) … set_mario_action(m, ACT_FLYING, 1)`) | `ACT_FLYING_TRIPLE_JUMP`, set from a triple jump with wing cap: `mario_actions_moving.c:149`, `mario.c:1050` | **Yes** — the jump sequence (jump → double → triple) is driven by `INPUT_A_PRESSED` |
| 2 | `act_shot_from_cannon` — `mario_actions_airborne.c:1710` (`if ((m->flags & MARIO_WING_CAP) && m->vel[1] < 0.0f) set_mario_action(m, ACT_FLYING, 0)`) | being fired from a cannon | **Almost certainly** — firing a cannon is an A press (TO VERIFY: the cannon-fire input + how the cannon is entered) |
| 3 | `MARIO_SPAWN_FLYING` warp spawn — `level_update.c:339` (`set_mario_action(m, ACT_FLYING, 2)`) | a warp whose spawn type is `0x17` (`MARIO_SPAWN_FLYING`, `level_update.h:43`; spawn-type table at `area.c:74`) | **Not inherently** — this is the escape hatch |

Notes:
- `ACT_FLYING_TRIPLE_JUMP` is a distinct action that *becomes* `ACT_FLYING` at its apex; it is
  itself only reachable from the triple jump, which is the third element of the A-driven jump
  sequence.
- Class 3 is the dangerous one: a **warp** can drop Mario straight into flying with no A press.
  The mitigation is per-level (the move we learned with the gamepiece-set work): show that
  `levels/wmotr/` contains **no** warp object with spawn type `MARIO_SPAWN_FLYING`. (Globally,
  `MARIO_SPAWN_FLYING` is associated with a specific spawn/warp behavior via the `area.c:74`
  table — identify which, then check WMotR's object/warp set.)

## Why this is hard (set expectations honestly)

Unlike `ShadowSpec.dim_shadow` (a one-function input/output spec), this is a **temporal / trace
property**: *being in `ACT_FLYING` at frame n implies an A press at some frame ≤ n.* That is an
induction over the whole Mario action-update transition relation across frames, not a single
`eval_funcall`. It's a real step up in difficulty — hence "lofty, shelvable."

The relevant input plumbing: an A press shows up as `m->input & INPUT_A_PRESSED` (derived from
`gPlayer1Controller->buttonPressed & A_BUTTON`); the jump actions gate on it. "A-gated" formally
means the transition's guard is (transitively) conditioned on `INPUT_A_PRESSED`.

## Constant ground-truth (don't trust the header)

`sm64.h` annotates `#define ACT_FLYING … // 0x10880899`, but that comment is **stale**: the
real macro expansion is **`0x10808899` = 277350553** (verified — it's the constant clightgen
emits at all three `set_mario_action(m, ACT_FLYING, _)` sites, and the `MARIO_SPAWN_FLYING`
case carries actionArg 2, matching `level_update.c:339`). `ACT_FLYING_TRIPLE_JUMP = 0x03000894
= 50333844` (its comment is correct). We read both off the AST, not the header — the
trust-model rule (audit the statement, trust the compiler front-end) made concrete.

## Rung plan (value even if the top rung is shelved)

- **R1 — exhaustive setter enumeration. ✅ DONE (`proofs/Flying.v`, commit `d53dedf`,
  no `Admitted`, `Print Assumptions` = closed under the global context).** `flying_setters p`
  is `Reach.direct_writers` retargeted from "writes global g" to "feeds a flying action constant
  into a call" (it walks `Scall`/`Sbuiltin` argument expressions). Machine-checked over the four
  clightgen'd TUs, the flying-setter functions are *exactly*: `set_jump_from_landing` (mario.c),
  `act_shot_from_cannon` + `act_flying_triple_jump` (airborne.c), `set_triple_jump_action`
  (moving.c), `set_mario_initial_action` (level_update.c) — the five sites in the table above.
  Plus the **no-synthesis** half: the four `set_mario_action_*` group helpers (and
  `set_mario_action` itself) never *assign* a flying constant (`fabricates_flying = false`), so
  the setter cannot manufacture a flying action from a non-flying argument — the value written
  to `m->action` is flying only if a flying constant was passed in at one of the five sites.
  *Residual (named in the file's SCOPE):* the analysis flags flying *literals* in call args; a
  flying value arriving via a *computed* argument is dataflow = R3. The `m->action` store
  choke-point ("the only store to the action field lives in `set_mario_action`") is argued
  textually + supported by no-synthesis; promoting it to a semantic store-frame theorem (leak
  #1 for a struct field) is a later rung. Four TUs, not whole-program (leak #3).
- **R2 — guard classification. ✅ DONE, but it OVERTURNED its own premise** (`Flying.v`, commit
  `a274f74`). The imagined R2 ("each site locally checks `INPUT_A_PRESSED`") is **false of the
  code**: every flying transition gates on `MARIO_WING_CAP` and/or physics (`vel[1]`), never on
  the controller. Machine-checked via a `reads_input` field-read analysis: 4 of the 5 sites read
  **no** input at all; the 5th (`act_flying_triple_jump`) reads `m->input` only for `INPUT_B/Z`
  cancels (dive / ground-pound), while its `ACT_FLYING` step is gated on `vel[1] < 4.0f`. So **at
  no site is the flying transition itself locally A-gated** — the A-dependence is necessarily
  *upstream*, in the jump sequence. R2 thus delivers a verified *negative*: it proves the local
  guard is not the A-press, which is exactly the evidence that R3 (temporal) is unavoidable.
- **R3 — the temporal closure (the lofty core, research risk).** Reach `ACT_FLYING` ⟹ prior A,
  by induction over the per-frame action loop. This is the hard part and the one we may shelve.
  The concrete chain to formalize (confirmed in code): `ACT_FLYING` ⟸ `ACT_FLYING_TRIPLE_JUMP`
  ⟸ a **double-jump landing** (`set_jump_from_landing` case `ACT_DOUBLE_JUMP_LAND` + `MARIO_WING_CAP`,
  or `set_triple_jump_action` via the double-jump-land cancel) ⟸ `ACT_DOUBLE_JUMP` ⟸ `ACT_JUMP`,
  and **each jump in that sequence is entered on `INPUT_A_PRESSED`**. Two confirmed complications
  for R3: (a) `set_triple_jump_action` is reached via a **function pointer**
  (`common_landing_cancels(m, &sDoubleJumpLandAction, set_triple_jump_action)`, moving.c:1875) =
  leak #2 on the critical path; (b) the property is genuinely a trace invariant over the action
  loop, not a one-function spec.
- **R4 — retire class 3 for our target (per-level). ✅ ESTABLISHED (by full enumeration of the
  WMotR object set; mechanization blocked, see below).** `MARIO_SPAWN_FLYING` is produced only by
  a warp object whose behavior is `bhvFlyingWarp` (index 12 of `sWarpBhvSpawnTable` →
  `sSpawnTypeFromWarpBhv[12]`, `area.c`). WMotR's *complete* object set (`levels/wmotr/script.c`
  + `areas/1/macro.inc.c`) contains exactly one warp-spawn object — `bhvAirborneWarp` (script.c:51
  → `MARIO_SPAWN_AIRBORNE` → `ACT_SPAWN_NO_SPIN_AIRBORNE`, *not* flying) — and **no
  `bhvFlyingWarp`**. The rest: 6× `bhvPoleGrabbing`, `bhvHiddenRedCoinStar`, `bhvMario`, 2×
  `macro_cannon_closed`, coin rings, 1-ups, 6× `macro_box_wing_cap`, 8× `macro_red_coin`. So in
  WMotR the class-3 hatch is absent; the only flying routes are class 1 (A-driven jump sequence)
  and class 2 (the two cannons — firing a cannon is an A press). *Mechanization blocker:*
  clightgen rejects `levels/wmotr/script.c` (`initializer element is not a compile-time constant`
  — the level-script object macros), so making R4 a `reflexivity` fact needs a separate
  level-data pipeline step; the enumeration above is exhaustive and source-checkable today.

R1 and R2 are **done and verified** (reflexivity, no `Admitted`, `Print Assumptions` closed).
R3 is the genuinely hard core — the natural shelve point — now with its chain and obstacles
mapped. R4 is independent and tractable (a `levels/wmotr/` object-table scan).
