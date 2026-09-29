# GOAL 2: the no-A action census R_noA (2026-09-27)

Tool: `tools/goal2_action_sites.py` (`--sites` for the full table, `--json F`).
It finds every write of `MarioState.action` in the twelve linked TUs two
independent ways and cross-checks them:

- **Clight** (`generated/<tu>.v`) decides *what* is written. Setters are found
  as a fixpoint from `set_mario_action`.
- **C** (`gcc -E` + pycparser) decides *under which guard*. Each guard is
  classified polarity-aware as A_PRESSED / A_DOWN / other.

Built-in cross-checks, all passing:

- The Clight and C target sets agree per function. The 12 differences are all
  C-side resolutions of arguments that are computed in Clight.
- The `LandingAction` tables' C initialisers equal their Clight `gvar_init`.
- The REMAP in `set_mario_action_{moving,airborne}` matches.

## Result

R_reach is the closure from level entry over non-A-gated edges: **73 actions,
12 of them airborne.**

| airborne action in R_reach | Φ credit row (`HeightInvariant.v`) |
|---|---|
| ACT_FREEFALL, ACT_BUTT_SLIDE_AIR | bal4 + 110 |
| ACT_SLIDE_KICK | state 0: bal2 + 110 / state 1: sk_bounced_credit |
| ACT_GROUND_POUND | windup_left / 0 |
| ACT_DIVE, ACT_FORWARD_ROLLOUT, ACT_BACKWARD_ROLLOUT, ACT_FORWARD_AIR_KB, ACT_BACKWARD_AIR_KB, ACT_SOFT_BONK, ACT_AIR_HIT_WALL, ACT_SPAWN_NO_SPIN_AIRBORNE | bal4 |

This matches the table in `goal2-phi.md` §2 exactly. Every A-gated air action
drops out, including ACT_JUMP, the double and triple jumps, ACT_FLYING,
ACT_TWIRLING, ACT_STEEP_JUMP and ACT_WATER_JUMP. If A_DOWN (held, never pressed)
were allowed, the only addition would be ACT_JUMP_KICK, from `act_punching`
(mario_actions_object:157). Holding A counts as using it, and since 2026-09-28 the
GOAL-2 capstone's premise says so (`AGates.a_used_real`: A neither pressed nor held),
which `Hframe_stays_noA` receives as `a_down_real bm m = false`.

## Follow-ups (not yet checked)

- **ACT_IN_CANNON is in R_reach, and it must stay in R_noA.** WMotR has two
  cannons (macro.inc.c:3-4) and the bob-omb buddy who opens them (:5). Talking
  and advancing the dialog take B only, and entering needs no button
  (`experiments/oracle/cannon_probe.py`, 2026-09-28). Firing is A-gated
  (automatic.c:732), so Mario stays in the cannon. The entry height is the
  `wmotr_cannon` attach case (HeightMoveCatalog).
- **Pole actions** (HOLDING / CLIMBING / TOP_OF_POLE, GRAB_POLE_*) are non-air,
  so Φ gives them credit A, i.e. y ≤ K. This needs the pole-top ≤ K row from
  `goal2-writers-vs-moves.md`. WMotR's reachable pole top is −1919.
- The tool is the **informal** census. The spine obligation is the writer arm of
  `execute_mario_action_preserves_real_reached_lp` at `Qv := R_noA`
  (`goal2-crux-decomposition.md` (i)). This table is its target list.
