# What the GOAL-1 capstone is actually scoped to (and why it matters)

The capstone `noA_no_spawn_never_flying` runs the frame
`execute_mario_action` over **`mario_ge := globalenv mario.prog`**, where
`mario.prog` is the clightgen'd **`mario.c` translation unit alone** — *not* a
linked whole-program. Each SM64 `.c` becomes a separate `generated/*.v`; they are
**not linked** in the capstone.

## The consequence: the reach residuals only see 62 functions

`mario.prog` contains **62 internal (defined) functions** and **138 external
(declared-only) functions**. The reach residuals quantify over
`function_entry2 mario_ge f …`, which only matches the **62 internal mario.c
functions**. Everything in the other TUs is an **external call** from this genv's
viewpoint, governed by the *external* residuals (`ext_meminv_ok`,
`reach_ext_action_cell`), not the *internal* reach.

So when the GOAL-1 prose says "the game's **other functions** keep Mario's action
non-flying," at the current scope that can only mean **mario.c's other ~61
internal functions** — not the whole game.

## Where flying actually lives — mostly OUT of scope

The 5 flying-write sites (from `Flying.v`) split by TU:

| site | TU | in mario.prog? |
|---|---|---|
| `set_jump_from_landing` (→ ACT_FLYING_TRIPLE_JUMP) | mario.c | **internal** |
| `set_mario_action` (the choke point) | mario.c | **internal** |
| `act_flying_triple_jump` (→ ACT_FLYING) | mario_actions_airborne.c | external |
| `act_shot_from_cannon` (→ ACT_FLYING) | mario_actions_airborne.c | external |
| `set_triple_jump_action` (→ ACT_FLYING_TRIPLE_JUMP) | mario_actions_moving.c | external |

**3 of the 5 flying sites are external** to `mario.prog`. The A-gates that make
them safe (e.g. the `if (m->input & INPUT_A_PRESSED)` in
`common_landing_cancels`, mario_actions_moving.c) are *also* external. So the
taint-closure (leaf-B) **cannot be fully stated at single-TU scope** — it needs
linking to bring those handlers into the genv.

This also means `reach_ext_action_cell` ("reached externals don't write the
action cell") is currently a **strong, crux-bearing assumption** — it assumes the
entire cross-TU action machinery preserves non-flying. It is the honest boundary,
to be discharged by symbolic linking (see `Generic/SymbolicLinking.v` /
`LinkSpike.v`), not a mere math/memcpy externals boundary.

## Two genuinely separable jobs (and which scope each needs)

- **Job A — pointer-provenance / kill forall-le (leaf-A).** *In scope now.* The
  ~61 internal mario.c functions are reached by **direct** calls (the action
  dispatch is `switch` + direct calls, not function pointers). Replace the
  `forall le` `stmt_value_ok` residual with an execution-relative provenance
  invariant (generalize `RealFrameValue.tprov`/`exec_body_prov_noA` from the one
  body to these ~61). No linking required.
- **Job B — taint closure / A-gating (leaf-B).** *Needs linking.* The flying
  sites and their A-gates live in external TUs. Requires bringing those TUs into
  scope (symbolic linking), then proving the inductive A-gating.

## Why this matters for the goal

The GOAL-1 prose ("nothing the game's code does during a frame can turn the
action flying … the game's other functions … proved") describes the **fully
linked whole-program** result. The current capstone is **single-TU (mario.c)**
with the rest assumed via external residuals. So the prose goal is not
dischargeable against the present architecture without a linking expansion — it
should be re-scoped into the two jobs above (Job A now, Job B after linking).
