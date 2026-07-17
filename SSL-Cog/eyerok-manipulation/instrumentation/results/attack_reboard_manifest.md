# Eyerok attack/reboarding probe manifest

## Authentication and reproduction

- ROM: North-American Super Mario 64 (`baserom.us.z64`)
- MD5: `20b854b239203baf6c961b850a4a51a2`
- SHA-256: `17ce077343c6133f8c9f2d6d6d9a4ab62c8cd2aa57c40aea1f490b4c8bb21d91`
- ROM-header CRC: `635A2BFF 8B022326`
- Emulator: Ubuntu-24.04 WSL Mupen64Plus 2.5.9, debugger pure
  interpreter (`--debug --emumode 0`)

`run_attack_probe.sh` rejects a different WSL distribution, MD5, SHA-256, or
header CRC. It builds four base cases, an eight-direction lethal steering
sweep, and one braking schedule, then invokes the fail-closed analyzer. Shared objects, raw
logs, and screenshots stay under ignored `build/instrumentation/`; the concise
CSV files and summary in this directory are committed evidence.

## Evidence boundary and fixture writes

These are source-shaped local microtraces, not controller-only traces from
reset. Retail code performs the attack classification, Eyerok response,
gravity and movement, ground collision, mesh loading, Mario air action,
surface query, floor/platform selection, and hand deletion.

The setup writes are disclosed and deliberately narrow:

1. `sWarpDest` and Mario position/velocity shorten travel through the genuine
   Area 2 instant-warp triangle into Area 3.
2. The boss is set to `WAKE_UP`; both hands execute their retail
   `SLEEP -> IDLE` initialization. Boss scheduler fields are then set so one
   real hand executes `IDLE -> OPEN -> SHOW_EYE` and installs its retail open
   collision mesh.
3. The local Mario fixture writes position at hand-local Z `+100`, Y
   `handY + 100`, vertical velocity `-2`, forward speed `5`, facing direction,
   current/previous action, action state/timer/argument, intended magnitude,
   slide velocity, `squishTimer = 0`, and `quicksandDepth = 0`. Clearing and
   logging the last two fields prevents an inherited squish state from
   changing the action path.
4. Nonlethal cases do not write any target-hand field. Lethal cases write only
   hand health `2`, representing two previous hits; retail code performs the
   final `2 -> 1` decrement and writes `DIE`, velocity `50`, gravity `-4`, and
   movement state. The first logged post-move velocity is therefore `46`.

There is no fallback attack latch and no fixture write to target-hand action,
timer, previous action, position, velocity, gravity, movement flags, floor,
collision mesh, or active flags.

The four base Mario fixtures are nonlethal/lethal `ACT_LONG_JUMP` and
nonlethal/lethal `ACT_SLIDE_KICK`. A and B are released during the measured
interval. The steering sweep uses the lethal long-jump fixture. Its first
retail frame has neutral stick, allowing the open front wall to push local Z
`+100 -> +127` and zero forward speed while preserving `ACT_LONG_JUMP`.
Starting on the following frame it holds one of:

~~~text
(+127,0) (-127,0) (0,+127) (0,-127)
(+90,+90) (+90,-90) (-90,+90) (-90,-90)
~~~

A and B remain released. This is a bounded schedule search, not a proof over
all analog sequences.

The additional `brake32` schedule holds `(0,+127)` on pose-relative polls
`[1,32)`, then reverses to `(0,-127)` from relative poll `32` onward. It is
included to keep X/Z inside the open top until deletion, separating the
vertical/deletion blocker from the continuous-inward trace's far-edge exit.

## Geometry and update-order checks

The analyzer inverse-transforms Mario X/Z by the hand yaw and scale. It tests
the actual open-top triangles `(1,3,4)` and `(1,4,2)` from
`levels/ssl/eyerok_col/collision.inc.c`. Their front/back source Z limit is
`51`, or `76.5` world units at scale `1.5`.

Because surface objects update before Mario, the relevant observable for a
current row is:

~~~text
preQueryFloorMinusMario = current hand-top Y - previous completed Mario Y
~~~

The `+78` floor-query allowance applies when that value is nonnegative. The
CSV deliberately calls the simultaneous completed-frame quantity
`postFrameMarioAboveHandTop`; it is not mislabeled as a `+78` test.
ROM-reported `mFloorObject` and `gMarioPlatform` remain the decisive evidence.

## Results

- Nonlethal long jump: retail `c003 -> received=3 -> ATTACKED`, health
  `4 -> 3`, first post-move hand velocity `26`. Mario selects and becomes
  platform-supported by the ordinary open top at Y `-1027` while the hand is
  at home height but still has velocity `-26` and ground flag `0`; the next
  frame sets the ground flag and velocity zero. Mario survives the
  open-to-closed recovery mesh swap, reacquires the closed top, and is later
  carried by the same hand to Y `-928`. This is a local reboard witness.
- Lethal long jump, neutral stick: retail `c003 -> received=3 -> DIE`, health
  `2 -> 1`, first post-move hand velocity `46`. After a second retail
  hit-from-above bounce, the conservative pre-player-update gaps are exactly
  `63` and `7`,
  but Mario is still at local Z `+127`, outside the open top. At DIE timer 39
  Mario is 43 above the top and the hand is deleted next.
- Nonlethal and lethal slide kicks: the retail interaction and corresponding
  hand response both occur, but the first open-front-wall hit unconditionally
  changes Mario from `ACT_SLIDE_KICK` to `ACT_BACKWARD_AIR_KB`. Neither trace
  ever selects the target as floor or platform.
- Lethal continuous inward stick `(0,+127)`: the early `+63` and `+7` rows are
  still outside X/Z. It later enters the footprint and first selects the
  target as floor at poll 509 / DIE timer 27: Mario Y `-876`, velocity `+2`,
  local Z `+76.252`, floor Y `-1027`. The hand is already grounded with
  velocity zero. `gMarioPlatform` remains null.
- That inward trace keeps the hand as selected floor through timer 36 (Mario
  Y `-930`, velocity `-16`, local Z `-71.792`), then crosses the far edge at
  timer 37 (local Z `-93.991`). At timer 39 Mario is Y `-984`, velocity `-22`,
  43 above the top, with neither target floor nor target platform. The next
  projected Mario positions are `-1006` and `-1030`; the first crossing of
  top Y `-1027` would be after the hand has been deleted.
- The `brake32` schedule keeps X/Z valid: at timer 39 Mario is at local Z
  `+20.156` and the still-live target remains his selected floor, but Mario is
  43 above the top and `gMarioPlatform` is null. At poll 522 the target is
  absent while Mario is Y `-1006`, still 21 above the old top. The stored
  floor pointer is stale for that row; at poll 523 Mario first crosses the old
  top at Y `-1030` and neither floor nor platform refers to the target.
- None of the eight fixed-direction schedules or the braking schedule makes the hand
  `gMarioPlatform` or produces a landing. The inward case is a retail-code
  floor-selection observation from the disclosed fixture, but it is not a reboard and it occurs only
  after the upward impulse has ended.

## ABC interpretation and open work

The long-jump local action has historical A-button cost even though A is up in
the measured interval, so it is not a demonstrated zero-A or held-A-only
route. Slide kick is source-enterable by B without A, but ordinary entry sets
vertical velocity `12` and clamps forward speed to at least `32`; this
injected descending speed-5 state is not established as authentically
reachable with no A press.

The traces settle what the retail update and collision code do from these
local states. They do not prove controller-only reachability of the fixtures,
a useful Area 3-to-2 warp departure, or a zero/0.5-A star route.
