# US-ROM IDLE-to-double probe manifest

## Runtime

- WSL distribution: Ubuntu-24.04
- Mupen64Plus UI/core: 2.5.9, debugger-enabled cached interpreter
- Video/RSP: Mupen64Plus Rice and HLE RSP 2.5.9
- Display: xvfb-run, Mesa software renderer
- Probe: host input plugin compiled with GCC 13.3.0
- ROM title: Super Mario 64 (U) [!]
- ROM MD5: 20b854b239203baf6c961b850a4a51a2
- ROM SHA-1: 9bef1128717f958171a4afac3ed78ee2bb4e86ce
- ROM SHA-256: 17ce077343c6133f8c9f2d6d6d9a4ab62c8cd2aa57c40aea1f490b4c8bb21d91
- ROM header CRC: 635A2BFF 8B022326

The core reports that it includes MIPS R4300 debugger support, and the plugin
successfully resolves DebugMemRead/Write exports from the core handle. The
wrapper passes the console UI's --debug option and pipes its run command before
the frame trace begins.

The fixed virtual addresses and object offsets were checked against a matching
North-American build at source revision
36fbf8d693a9fc2bdec0c77402f8e96d07d2f461. Its built ROM was byte-for-byte
identical to the authentic input ROM (the SHA-1 above). Eyerok objects are not
assumed to occupy fixed pool slots: the probe resolves segment 0x13 and scans
the live object pool for bhvEyerokBoss and bhvEyerokHand.

The proof project pins canonical source revision
9921382a68bb0c865e5e45eb594d9c64db59b1af. The Eyerok behavior, movement,
area-transition, and collision files used by this probe were diff-checked
equal between that pin and the available 36fbf8d6 checkout.

## Fixture RAM writes

The fixture is fully disclosed:

1. Mupen's US-ROM cheat database enables Have Level Select by writing byte
   1 at 0x8032D58C and Debug Mode On by writing byte 1 at 0x8032D598.
   Controller input then selects SSL in the game's debug menu.
2. To shorten travel from Area 1 to Area 2, it writes sWarpDest as
   { type=CHANGE_AREA, level=SSL, area=2, node=0x0A, arg=0 }.
3. In Area 2, it writes Mario's state/object position to
   (0,450,-1320) and velocity to zero until the real
   SURFACE_INSTANT_WARP_1D floor is selected. The game's own instant-warp
   code changes to Area 3.
4. Only after genuine Eyerok initialization has produced both hands at
   homeY = posY = -1534, oVelY = oGravity = 0, and non-null collision
   meshes, it writes each hand's oAction from SLEEP to IDLE.
5. It performs no other hand write. An ordinary hand update supplies the
   selected floor, floor height, movement flags, action timer, and previous
   action.
6. Only after validating both real floor pointers and floor heights -1534,
   it writes the boss scheduler fields:
   action=FIGHT, numHands=2, activeHand=0, Unk104=-8,
   Unk108=0, Unk110=1, and Unk1AC=0.

In particular, the fixture never writes hand position, velocity, gravity,
movement flags, floor, collision mesh, timer, previous action, positive
velocity, BEGIN_DOUBLE_POUND, or DOUBLE_POUND.

## Observation

The first hand is logged as:

~~~text
timer 365  IDLE                velY=0   gravity=0
timer 366  BEGIN_DOUBLE_POUND  velY=0   gravity=0
timer 367  DOUBLE_POUND        velY=0   gravity=0
timer 368  DOUBLE_POUND        velY≈0   gravity=-20  ground collision
timer 372  DOUBLE_POUND        velY=85  gravity=-15  first +85 movement
~~~

The first exact blocking condition is therefore the airborne
oVelY <= 0 branch in eyerok_hand_act_double_pound: it writes gravity
-20 before positive ascent can be retained. When a later grounded handler
launches, gravity is already -15, so the movement observation is +85, not
positive velocity with zero gravity.

The analyzer parsed 476 hand rows and found zero rows matching the alternate
seed. This execution supports the source invariant; because of the disclosed
fixture, it does not by itself prove from-reset controller reachability or the
whole-program source-to-ROM refinement.
