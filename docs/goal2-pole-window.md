# GOAL 2: pole grab window (summit poles)

Source-verified against `vendor/sm64` (research note, 2026-09-27).

## Pole hitbox
- `bhvPoleGrabbing`: `SET_HITBOX(Radius 80, Height 1500)` (data/behavior_data.c:413); `SET_HITBOX` sets no downOffset.
- `bhv_pole_init` overrides height = BPARAM2*10 (src/game/behaviors/pole.inc.c:20-21).
- `hitboxDownOffset = 0` at spawn (src/game/spawn_object.c:263), and nothing on the pole path changes it. So no hitbox part sits below the base.

## Mario hitbox
- Height is 160, or 100 under `ACT_FLAG_SHORT_HITBOX` (src/game/mario.c:1649-1652). No airborne action (0x080-0x09F) has that flag. Mario's downOffset is 0.

## Overlap test (src/game/object_collision.c:25-43)
It needs horizontal distance < 80 + Mario radius, and:
- `marioY > poleY + H` fails the test (Mario is above the pole);
- `marioY + 160 < poleY` fails the test (Mario is below the pole).

So a hit needs `marioY >= poleY - 160` (inclusive).

## interact_pole (src/game/interaction.c:1510-1557)
- The only gate is the action group: `actionId` must be in `[0x080, 0x0A0)`, which is airborne. A grounded Mario cannot grab.
- The other gate is "not already on this pole".
- There is no y check and no velocity gate. Speed only picks the slow or fast grab.
- `oMarioPolePos = pos[1] - poleY` can be negative. The first `set_pole_position` call then sees `oMarioPolePos < -0`. It snaps `pos[1]` to poleY and sets FREEFALL (src/game/mario_actions_automatic.c:91-94). The exception is when a floor is above `pos[1]`.
- **So a grab from below lifts Mario to the pole base.**

## Lowest grab y
| pole | base | lowest pos[1] | moat above 2372 |
|---|---|---|---|
| script.c:22 | 3154 | 2994 | 622 |
| script.c:21 | 3359 | 3199 | 827 |
| script.c:20 | 3564 | 3404 | 1032 |

Two caveats:
- The overlap test uses `gMarioObject->oPosY`. That is Mario's end-of-frame y, and the interaction fires the next frame.
- The push-away in `bhv_pole_base_loop` (behaviors/pole_base.inc.c:4-8) is horizontal only.
