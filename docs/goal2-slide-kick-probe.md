# GOAL 2 tether: the slide kick in the real game

Evidence only, not proof. Nothing in `proofs/` depends on it. It checks the corrected
height-budget claim: `act_slide_kick` falls under gravity -2 (`mario_step.c:543`, the
`ACT_LONG_JUMP || ACT_SLIDE_KICK || ACT_BBH_ENTER_SPIN` branch of `apply_gravity`), not -4.
Its first landing bounces with `vel[1] = -vel[1] / 2` (`mario_actions_airborne.c:1604`).

## Setup (reproducible)

```bash
python3 experiments/oracle/slide_kick_probe.py 12 2     # RUN=12, ZWAIT=2
```

The script loads `~/sm64-oracle/wmotr_idle.st` (Mario idle on the WMotR spawn cloud) with
no RAM pokes. It sets controller 1 once per game frame, at the return of
`execute_mario_action` (0x8029CA70). It logs `gMarioStates` fields: action @12,
actionState @24, pos[1] @64, vel[1] @76, forwardVel @84.

Input, by Mario update index n (stick is x=0, y=+127, i.e. full forward):

| n | buttons | result |
|---|---|---|
| 0..11 | stick only | ACT_WALKING (0x04000440), forwardVel climbs to 17.67 |
| 12 | Z pressed (first press) | ACT_CROUCH_SLIDE (0x04808459); walking Z path, `mario_actions_moving.c:807` |
| 13 | Z held | crouch slide, forwardVel 15.61 |
| 14 | Z held + B pressed | ACT_SLIDE_KICK (0x018008AA); `act_crouch_slide:1467`, forwardVel >= 10 |
| 15.. | Z held | observe |

`set_mario_action` (mario.c:875) sets vel[1] = 12 and forwardVel = max(forwardVel, 32).

## Result: confirmed

Launch floor y = 1669.0. Each logged row is the state after that frame's update.
`perform_air_step` moves first and then applies gravity, so a row's vy is the value the
next frame moves by.

- **Gravity is exactly -2.0 per frame** in ACT_SLIDE_KICK: vy goes 12 (set), 10, 8, 6, 4,
  2, 0, -2, ..., -12. This is exact in binary32.
- **Apex: +42.0** (y = 1711.0 at n = 19..20). That is 12+10+8+6+4+2 = 42, as predicted.
- **Landing (n = 26):** the frame starts with vy = -12 and the step lands at the floor
  (1681 -> 1669). `apply_gravity` then runs, so vel[1] is **-14.0** when the
  `AIR_STEP_LANDED` handler reads it.
- **Bounce: vy = +7.0 = -(-14)/2**, actionState 0 -> 1. This is the top of the
  predicted "+6 to +7" range.
- **Bounce apex: +16.0** above the floor (y = 1685.0 at n = 30). The prediction said
  "about 12", but a bounce at +7 under gravity -2 rises 7+5+3+1 = 16. That is still well
  under the first apex (42), so the first arc bounds the kick.
- Second landing (n = 34, frame starts at vy = -7): actionState is 1, so the action becomes
  ACT_SLIDE_KICK_SLIDE (0x0080045A) with no further bounce.
- Contrast: Mario then slid off the cloud edge into ACT_FREEFALL (0x0100088C). There vy
  goes 0, -4, -8, ..., -72, -75 (capped). That is the ordinary -4 gravity with the -75
  terminal velocity, and it shows the slide kick's -2 is specific to that action.

Summary: the slide kick's peak height above its launch floor is 42 on the first arc and
16 on the bounce, so at most 42. The ~12 figure for the bounce rise should be 16. This
does not affect the maximum.

## Raw log

```
F   0 keys=7f000000 act=04000440 st=0 y=1669.0 vy=0.0 fwd=8.91395378112793
F   1 keys=7f000000 act=04000440 st=0 y=1669.0 vy=0.0 fwd=9.806652069091797
F   2 keys=7f000000 act=04000440 st=0 y=1669.0 vy=0.0 fwd=10.678590774536133
F   3 keys=7f000000 act=04000440 st=0 y=1669.0 vy=0.0 fwd=11.530251502990723
F   4 keys=7f000000 act=04000440 st=0 y=1669.0 vy=0.0 fwd=12.362106323242188
F   5 keys=7f000000 act=04000440 st=0 y=1669.0 vy=0.0 fwd=13.174615859985352
F   6 keys=7f000000 act=04000440 st=0 y=1669.0 vy=0.0 fwd=13.968229293823242
F   7 keys=7f000000 act=04000440 st=0 y=1669.0 vy=0.0 fwd=14.743387222290039
F   8 keys=7f000000 act=04000440 st=0 y=1669.0 vy=0.0 fwd=15.500517845153809
F   9 keys=7f000000 act=04000440 st=0 y=1669.0 vy=0.0 fwd=16.240039825439453
F  10 keys=7f000000 act=04000440 st=0 y=1669.0 vy=0.0 fwd=16.962364196777344
F  11 keys=7f000000 act=04000440 st=0 y=1669.0 vy=0.0 fwd=17.667890548706055
F  12 keys=7f000020 act=04808459 st=0 y=1669.0 vy=0.0 fwd=16.607816696166992
F  13 keys=7f000020 act=04808459 st=0 y=1669.0 vy=0.0 fwd=15.611347198486328
F  14 keys=7f000060 act=018008aa st=0 y=1681.0 vy=10.0 fwd=32.150001525878906
F  15 keys=7f000020 act=018008aa st=0 y=1691.0 vy=8.0 fwd=32.30000305175781
F  16 keys=7f000020 act=018008aa st=0 y=1699.0 vy=6.0 fwd=32.45000457763672
F  17 keys=7f000020 act=018008aa st=0 y=1705.0 vy=4.0 fwd=32.600006103515625
F  18 keys=7f000020 act=018008aa st=0 y=1709.0 vy=2.0 fwd=32.75000762939453
F  19 keys=7f000020 act=018008aa st=0 y=1711.0 vy=0.0 fwd=32.90000915527344
F  20 keys=7f000020 act=018008aa st=0 y=1711.0 vy=-2.0 fwd=33.050010681152344
F  21 keys=7f000020 act=018008aa st=0 y=1709.0 vy=-4.0 fwd=33.20001220703125
F  22 keys=7f000020 act=018008aa st=0 y=1705.0 vy=-6.0 fwd=33.350013732910156
F  23 keys=7f000020 act=018008aa st=0 y=1699.0 vy=-8.0 fwd=33.50001525878906
F  24 keys=7f000020 act=018008aa st=0 y=1691.0 vy=-10.0 fwd=33.65001678466797
F  25 keys=7f000020 act=018008aa st=0 y=1681.0 vy=-12.0 fwd=33.800018310546875
F  26 keys=7f000020 act=018008aa st=1 y=1669.0 vy=7.0 fwd=33.95001983642578
F  27 keys=7f000020 act=018008aa st=1 y=1676.0 vy=5.0 fwd=34.10002136230469
F  28 keys=7f000020 act=018008aa st=1 y=1681.0 vy=3.0 fwd=34.250022888183594
F  29 keys=7f000020 act=018008aa st=1 y=1684.0 vy=1.0 fwd=34.4000244140625
F  30 keys=7f000020 act=018008aa st=1 y=1685.0 vy=-1.0 fwd=34.550025939941406
F  31 keys=7f000020 act=018008aa st=1 y=1684.0 vy=-3.0 fwd=34.70002746582031
F  32 keys=7f000020 act=018008aa st=1 y=1681.0 vy=-5.0 fwd=34.85002899169922
F  33 keys=7f000020 act=018008aa st=1 y=1676.0 vy=-7.0 fwd=35.000030517578125
F  34 keys=7f000020 act=0080045a st=0 y=1669.0 vy=-9.0 fwd=35.15003204345703
F  35 keys=7f000020 act=0080045a st=0 y=1669.0 vy=0.0 fwd=33.04103088378906
F  36 keys=7f000020 act=0080045a st=0 y=1659.3406982421875 vy=0.0 fwd=31.058568954467773
F  37 keys=7f000020 act=0080045a st=0 y=1643.351318359375 vy=0.0 fwd=31.48492431640625
F  38 keys=7f000020 act=0080045a st=0 y=1627.3621826171875 vy=0.0 fwd=31.94356918334961
F  39 keys=7f000020 act=0080045a st=0 y=1610.93603515625 vy=0.0 fwd=32.42060852050781
F  40 keys=7f000020 act=0100088c st=0 y=1601.9315185546875 vy=0.0 fwd=32.9116096496582
F  41 keys=7f000020 act=0100088c st=0 y=1601.9315185546875 vy=-4.0 fwd=33.04637145996094
F  42 keys=7f000020 act=0100088c st=0 y=1597.9315185546875 vy=-8.0 fwd=33.18178176879883
F  43 keys=7f000020 act=0100088c st=0 y=1589.9315185546875 vy=-12.0 fwd=33.31782531738281
F  44 keys=7f000020 act=0100088c st=0 y=1577.9315185546875 vy=-16.0 fwd=33.45418167114258
F  45 keys=7f000020 act=0100088c st=0 y=1561.9315185546875 vy=-20.0 fwd=33.59144973754883
F  46 keys=7f000020 act=0100088c st=0 y=1541.9315185546875 vy=-24.0 fwd=33.72930908203125
F  47 keys=7f000020 act=0100088c st=0 y=1517.9315185546875 vy=-28.0 fwd=33.86774826049805
F  48 keys=7f000020 act=0100088c st=0 y=1489.9315185546875 vy=-32.0 fwd=34.00674819946289
F  49 keys=7f000020 act=0100088c st=0 y=1457.9315185546875 vy=-36.0 fwd=34.146297454833984
F  50 keys=7f000020 act=0100088c st=0 y=1421.9315185546875 vy=-40.0 fwd=34.28638458251953
F  51 keys=7f000020 act=0100088c st=0 y=1381.9315185546875 vy=-44.0 fwd=34.42673110961914
F  52 keys=7f000020 act=0100088c st=0 y=1337.9315185546875 vy=-48.0 fwd=34.56759262084961
F  53 keys=7f000020 act=0100088c st=0 y=1289.9315185546875 vy=-52.0 fwd=34.708953857421875
F  54 keys=7f000020 act=0100088c st=0 y=1237.9315185546875 vy=-56.0 fwd=34.85103988647461
F  55 keys=7f000020 act=0100088c st=0 y=1181.9315185546875 vy=-60.0 fwd=34.99359130859375
F  56 keys=7f000020 act=0100088c st=0 y=1121.9315185546875 vy=-64.0 fwd=35.136592864990234
F  57 keys=7f000020 act=0100088c st=0 y=1057.9315185546875 vy=-68.0 fwd=35.280033111572266
F  58 keys=7f000020 act=0100088c st=0 y=989.9315185546875 vy=-72.0 fwd=35.42368698120117
F  59 keys=7f000020 act=0100088c st=0 y=917.9315185546875 vy=-75.0 fwd=35.56775665283203
F  60 keys=7f000020 act=0100088c st=0 y=842.9315185546875 vy=-75.0 fwd=35.71222686767578
F  61 keys=7f000020 act=0100088c st=0 y=767.9315185546875 vy=-75.0 fwd=35.857086181640625
F  62 keys=7f000020 act=0100088c st=0 y=692.9315185546875 vy=-75.0 fwd=36.0023193359375
F  63 keys=7f000020 act=0100088c st=0 y=617.9315185546875 vy=-75.0 fwd=36.14773178100586
F  64 keys=7f000020 act=0100088c st=0 y=542.9315185546875 vy=-75.0 fwd=36.29349899291992
F  65 keys=7f000020 act=0100088c st=0 y=467.9315185546875 vy=-75.0 fwd=36.43960189819336
F  66 keys=7f000020 act=0100088c st=0 y=392.9315185546875 vy=-75.0 fwd=36.58603286743164
F  67 keys=7f000020 act=0100088c st=0 y=317.9315185546875 vy=-75.0 fwd=36.73262023925781
F  68 keys=7f000020 act=0100088c st=0 y=242.9315185546875 vy=-75.0 fwd=36.87950897216797
F  69 keys=7f000020 act=0100088c st=0 y=167.9315185546875 vy=-75.0 fwd=37.02668762207031
F  70 keys=7f000020 act=0100088c st=0 y=92.9315185546875 vy=-75.0 fwd=37.174007415771484
F  71 keys=7f000020 act=0100088c st=0 y=17.9315185546875 vy=-75.0 fwd=37.32146072387695
F  72 keys=7f000020 act=0100088c st=0 y=-57.0684814453125 vy=-75.0 fwd=37.46904754638672
F  73 keys=7f000020 act=0100088c st=0 y=-132.0684814453125 vy=-75.0 fwd=37.616764068603516
F  74 keys=7f000020 act=0100088c st=0 y=-207.0684814453125 vy=-75.0 fwd=37.76448059082031
```
