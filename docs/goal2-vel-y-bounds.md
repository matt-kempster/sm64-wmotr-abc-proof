# GOAL 2: bounds on vel[1] and on pos[1] while rising (research note, 2026-09-27)

This is a source scout of `vendor/sm64/src/game`. Nothing here is proved. It is input for two proposed Phi side clauses.

## (1) |vel[1]| <= 128

Every `m->vel[1]` write in the linked TUs, found by grep for `vel[1] =`, `op=`, `vec3f_set/copy(m->vel`.
No writes were found in behavior_actions.c or level_update.c, or through `gMarioState->vel`.

| Kind | Sites | Value |
|---|---|---|
| Zeroing | moving.c:201,327,1730; stationary.c:817; automatic.c:361,381,494,687; airborne.c:402,781,975,1133,1299,1323,1331,1455,1494,1615,1696,1796,1876; interaction.c:525,596,1531; cutscene.c:1561; step.c:227,448,667; submerged.c:186,1138 | 0 |
| Constants | mario.c:813 (31.5), 850 (84), 876 (12), 883 (20), 943 (32), 955 (52), 968 (64); moving.c:491 (20); automatic.c:786 (20); airborne.c:934 (**-50**, ground pound), 1039/1044/1049 (45/60/**100**, crazy box), 1316 (52), 1355/1396 (30), 1534 (84), 2022 (42); interaction.c:517 via bounce_off_object (80/30, interaction.c:1347-1446), 592 (20), 1148 (12); cutscene.c:1377/1701 (60); submerged.c:499 (62) | in [-50, 100] |
| fspeed formula | mario.c:766 `initialVelY + forwardVel*mult`: the multiplier is 0.25 only for JUMP/HOLD_JUMP/STEEP_JUMP/RIDING_SHELL_JUMP. All of these are A-gated or shell-only. The largest initialVelY is 82 (flying triple jump) | at most 82 + 0.25*fv |
| Pitch-based | automatic.c:732 (cannon, needs `INPUT_A_PRESSED`, 100*sin); airborne.c:364 and step.c:661 (flying/unused, fv*sin(pitch)) | excluded: needs A, or flying (GOAL 1) |
| Halving/reflection | mario.c:769, 1176 (/2); airborne.c:1445,1484,1604 (-v/2 when v<0); 1542 (-0.4v) | magnitude shrinks |
| Gravity (step.c:505-578) | -4h with clamp -75h (h<=1); -1/-2/-4 with clamp -75; -3.2 with clamp -65; /4 then -1.6 with clamp -16; -37.5 floor | stays >= -75 if it starts there |
| Wind | step.c:598, maxVelY <= 50 | at most 50 |
| Water/whirlpool | submerged.c:221 (approach), 251, 1071 (-640/(d+16) >= -20); no water in WMotR | small |
| Cutscene | cutscene.c:1303, sqrt(4*fd+1)-1 with fd <= 512 | at most about 44.3 |

**Verdict: the clause is true.** Under no-A with no flying, vel[1] stays in [-75, 100]. The 100 comes only from the crazy box, which is not in WMotR. Without it the maximum is 84. The -75 gravity clamp is the only floor applied by gravity. No write puts vel[1] below -75: the ground pound is -50, and the reflections only reduce magnitude. The tightest statement is **-75 <= vel[1] <= 100**, which easily meets 128.

## (2) pos[1] >= -8192 while rising

- WMotR's lowest surface is the full-area death plane at y = -8191, spanning x,z in [-8191, 8192] (levels/wmotr/areas/1/collision.inc.c:5-8, :807).
- `check_death_barrier` (interaction.c:1819-1825) fires once pos[1] < floorHeight + 2048 = -6143. It starts `WARP_OP_WARP_FLOOR` with sDelayedWarpTimer = 20 (level_update.c:741-751). Mario keeps stepping during those 20 frames.
- Steps clamp to the floor. On a ground or air step, a nextPos at or below floorHeight lands at pos[1] = floorHeight (mario_step.c:431-442, 249). Mario can land on the death plane at -8191 and bounce with -v/2 (airborne.c:1445 and similar), but he is still at y >= -8191.
- FLOOR_LOWER_LIMIT = -11000 (surface_collision.h:14) is only the value find_floor returns when there is no floor. It is never a surface.
  - The ground step returns before moving when floor is NULL (mario_step.c:277).
  - When the air step's floor is NULL (step.c:414-419), pos[1] is clamped to the old m->floorHeight.
- update_mario_geometry (mario.c:1320-1330) can set m->floorHeight to -11000 only when both pos and gfx pos are outside the ±8192 columns. Once that happens, mario_execute_action stops (mario.c:1710).

**Verdict: true.** In WMotR, pos[1] >= -8191 holds at all times, not only while rising. The tightest bound is **y >= -8191**. The residual trust point is the horizontal OOB escape: the step code refuses qsteps with a NULL floor, and no WMotR warp or teleport targets a point outside the ±8192 columns.
