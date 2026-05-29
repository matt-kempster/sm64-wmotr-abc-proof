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

## Rung plan (value even if the top rung is shelved)

- **R1 — exhaustive setter enumeration (tractable, ~now, syntactic/`reflexivity`).** Enumerate
  *every* `set_mario_action(_, ACT_FLYING | ACT_FLYING_TRIPLE_JUMP, _)` site in the whole codebase
  and prove the list is exactly those. This is `Reach.direct_writers` retargeted from "writes
  global g" to "sets the action to a flying value." Soundness caveat: must also catch indirect
  writes to `m->action` (it's a struct field via the `m` pointer) — same leak-#1 shape, so the
  honest version is "these are the only *direct* `set_mario_action` flying sites," with raw
  `m->action = …` stores checked separately.
- **R2 — per-site guard classification (tractable, syntactic).** For each site, show the enclosing
  action requires `INPUT_A_PRESSED` (pins classes 1 & 2 locally). Cannon needs the fire-input +
  entry checked.
- **R3 — the temporal closure (the lofty core, research risk).** Reach `ACT_FLYING` ⟹ prior A,
  by induction over the per-frame action loop. This is the hard part and the one we may shelve.
- **R4 — retire class 3 for our target (per-level).** Prove `levels/wmotr/` has no
  `MARIO_SPAWN_FLYING` warp, so the escape hatch is absent where we actually need the result.

R1–R2 are near-term and reuse `Reach`/`Frame`; R3 is where it gets genuinely hard. Starting point
when we run the goal: **R1.**
