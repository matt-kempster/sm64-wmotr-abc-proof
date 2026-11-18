# Small breakable box as the last pusher in the low Ink setup

The native small crate (slot 23) can do the last shove. In the selected Japanese Wafel reconstruction, Mario drops the crate four updates before its contact. The bloated Bob-omb does the first shove. Mario takes the real warp, keeps the spinning top through the last observed Area 1 update, and reaches Area 2 at `(365.5927734375, 5500, -1096.8026123046875)`.

## Setup and inputs

Use the existing [low held-Bob setup](../ink-shell-carried-bob-mount/README.md). Its prefix, shell preparation, separate donor state and game/runtime revisions are preserved in `results.json.gz`. The earlier conditional shell pickup retarget, supplied remote HOLP and real shell throw are inherited. The frozen shell arrives at `(-1962.4404296875, 1800, -1243.34130859375)`. Both carrying states below are supplied. The run does not derive their acquisition, transport or timing from a single controller history.

| Update (top timer before the update) | Input, grant and observed result |
|---|---|
|126|Supply Mario in HOLD_FREEFALL at (5900, 1920, 3440) with the native crate held. Supply HOLP input (-2110.08984375, 1920, -1106.1024658203125). Fresh Z causes the native drop. At the end of the update the crate is free at (-2110.089844, 1929.547363, -1106.102417).|
|127|Neutral. The crate moves under its normal behavior.|
|128|Copy the previously verified held-Bob approach ledger. This supplies Mario at (-1962.440430, 1810, -1243.341309), falling at 16 units/update, holding the native-derived radius-91 Bob-omb (39), and supplies its HOLP. Fresh Z causes a shell-contact drop, ground mount and cancellation through crouch slide to butt slide.|
|129|Neutral. The Bob shoves Mario to M=C (-2117.026855, 1839.447266, -1113.008545). Stored Graphics Y is 1809.206665. The small crate has moved to (-2116.026855, 1925.437866, -1113.458496) by the end of this update.|
|130|Neutral. Mario's contact list begins with crate 23, then Bob 39. The final shove produces M=C (-2199.961670, **768**, -1075.789673), with stored G at the same X/Z and **Y 1839.447266**. Cache 768 is a static floor. The action ends in BUTT_SLIDE_STOP.|
|131|Neutral. Warp 64 is accepted, the floor and platform become spinning top 61 at Y 1915.737061, and Mario enters DISAPPEARED. The top has six loaded surfaces.|
|Through Area 2|Neutral. The top pointer persists at each measured Area 1 boundary. The first Area 2 M is (365.592773, 5500, -1096.802612).|

No input uses or holds A. All gameplay edits in the tail are the crate carrying/HOLP grant before 126 and the inherited Bob carrying/approach grant before 128. These ledgers include position, pointers, action fields, donor object scalars and HOLP. No state write moves the released crate, repositions the shell after its throw, or moves either Mario or an actor after the last carrying grant. M is movement position, C is the collision object's position and G is stored graphics position (`gfx.pos`).

## Controls and finite coverage

Using the old Crazy Box drop HOLP (-2102.720703125, 1920, -1119.5618896484375) for the smaller crate gives the same Bob shove on 129. Contact on 130 still includes crate 23 first, there is still a 1071.447266-unit stored-graphics gap and the real warp still accepts Mario. But M.X/Z is (-2156.197021, -1048.152466), and the next floor is static 768. The top never becomes the platform and arrival is ordinary (0, 5500, 256). Omitting the crate also ordinary-spawns. A different nearby release (case 17) selects the moving floor at 1917.872681 during the producer and stays in Area 1 throughout the bounded continuation.

`test.py` checks 44 cases (43 drop positions at Y 1920 plus one omitted-crate control) from two independent initializations. Each runs through the first Area 2 boundary or 45 updates. Two displaced, 33 reached ordinary Area 2, and nine remained in Area 1 for that period. `grid.py` checks every pair in two additional grids, from two independent initializations. It checks update 131 for warp-and-top capture and follows every capture through arrival. The 110 integer pairs (X -2111 through -2101, Z -1111 through -1102) gave zero immediate captures. In the 117 quarter-unit grid pairs (X -2111 through -2108, Z -1107 through -1105), two worked all the way to the displaced spawn. Their supplied HOLPs were (-2109.75, 1920, -1106.25) and (-2108.5, 1920, -1106.75). The grids overlap. These finite checks do not establish a required precision or a continuous working interval.

## Reproduce

Run these sequentially from `SSL-Coq/less-than-one-a-press` in Windows. The inherited initializer uses a shared scratch prefix in `build`.

```powershell
& build/wafel-pilot/python/python.exe instrumentation/ink-low-small-box-final/test.py --verify
& build/wafel-pilot/python/python.exe instrumentation/ink-low-small-box-final/grid.py --verify
```

`positive.json` and `control.json` are ROM-compatible exports with all tail writes, controller inputs and per-update expected observations. `results.json.gz` includes the shell/donor preparation, all 44 outcomes, and full inputs, actor state, Mario state and Wafel action events for four selected cases. `grid.json` records its complete grid definitions and every capture. This packet uses Wafel 0.8.5 / Python 3.9.13 with JP DLL SHA256 `960fe979068b78e6733b3ddb87741833fbf4eb29b2a21a2bba871977427c2d0f`. The starting proof branch revision is `01c1109e31216f854fe30bfa70866e62bcc00614`, the local decompile checkout is `36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`, and the upstream source pin is `9921382a68bb0c865e5e45eb594d9c64db59b1af`.
