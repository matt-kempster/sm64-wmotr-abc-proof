# Eyerok instrumentation

The Mupen64Plus probe in the mupen64plus folder checks the narrow
IDLE -> BEGIN_DOUBLE_POUND -> DOUBLE_POUND velocity question on the
authentic North-American ROM. It is deliberately separate from the Rocq proof
and does not replace the source audit.

Run it from the project directory in the supported POSIX environment:

~~~sh
bash instrumentation/mupen64plus/run_idle_double_probe.sh \
  /path/to/baserom.us.z64
~~~

The wrapper refuses any ROM whose MD5 is not
20b854b239203baf6c961b850a4a51a2, builds the input plugin, runs to frame
600, and asks the analyzer to fail if it sees:

~~~text
action = DOUBLE_POUND
oVelY > 0
oGravity = 0
movement not skipped
~~~

The committed results/idle_double_trace.csv is the small transition witness.
results/idle_double_summary.txt records the authentication, result, and every
fixture write. Full raw logs and screenshots are generated under
build/instrumentation and are intentionally not committed.

This is authentic ROM execution from an initialized, source-reachable local
precondition. It is not a from-reset controller-only Eyerok-fight trace.
The controller selects SSL in the debug menu; RAM writes then shorten travel
to Areas 2 and 3 and install the scheduler precondition. The plugin waits for
both genuinely spawned hands to have homeY = posY = -1534, zero velocity and
gravity, and a non-null collision mesh. It changes only each hand's action
from SLEEP to IDLE, waits through an ordinary update until real floor
pointers and floor height -1534 appear, and only then writes boss scheduler
fields. It never writes a hand's position, velocity, gravity, movement flags,
floor, collision mesh, timer, previous action, BEGIN_DOUBLE_POUND, or
DOUBLE_POUND.

## Mario/hand contact probe

`run_contact_probe.sh` runs three additional authenticated-US-ROM modes:
stationary Mario, a never-A B-only speed kick, and an already-held-A jump
kick. The wrapper validates the supported execution environment, checks both
MD5 and SHA-256, builds three debugger input plugins, and runs Mupen64Plus in
the pure interpreter:

~~~sh
bash instrumentation/mupen64plus/run_contact_probe.sh \
  /path/to/baserom.us.z64
~~~

The stationary mode authenticates Mario's selected dynamic floor and platform
as the closed hand top at Y `-1228`. On the first `+85` hand step Mario is
still inside the transformed top in X/Z, but the pre-query vertical gap is 85,
seven beyond the floor buffer. The arena floor wins, the raised hand underside
becomes a dynamic ceiling, and retail code selects `ACT_SQUISHED`.

Both prepared-action modes start at hand action timer 2. Retail code completes
two Mario air updates before the hand launch: Y `-1208`, velocity `16`, then Y
`-1192`, velocity `12`. Because surface objects update before Mario, the hand
then rises to top Y `-1143`; this makes the conservative pre-player-update gap
49. Mario's first air quarter-step adds 3, making the modeled query gap 46,
inside the 78-unit allowance. Ordinary collision snaps Mario to the same hand.

- In `b_only`, the probe injects the local source-valid `ACT_WALKING`, speed
  29, rear-interior predecessor and sends one B edge with A always up. It does
  not inject `ACT_DIVE` or positive Mario velocity. Retail code enters the
  dive and remains on all `+85,+70,+55,+40,+25,+10` steps, reaching Y `-943`.
- In `held_a`, A is down from Area 3 entry. The probe injects
  `ACT_MOVE_PUNCHING`, state 0; this is not a controller-authentic punch entry.
  Retail code sees `INPUT_A_DOWN` without `INPUT_A_PRESSED`, enters jump kick,
  and remains on every positive step to Y `-943` with B up.

The analyzer logs Mario/hand X/Z and hand yaw, inverse-transforms the query
into the real closed-top triangles, and emits explicit `insideClosedTopXZ`,
`verticalGap`, `within78`, floor-owner, platform-owner, and contact-class
columns. `within78` is a conservative pre-player-update buffer test based on
the previous completed Mario Y; the ROM-reported floor and platform owners are the
decisive contact evidence. See `results/contact_manifest.md` for every setup
write and the exact scope. The results prove the local contact transition, not
controller-only reachability of the injected predecessor pose or a useful warp
dismount.

## Attack and reboarding probe

`run_attack_probe.sh` checks fixture-assisted nonlethal/lethal long-jump and
slide-kick attacks, followed by the retail hand response, Mario collision,
floor/platform choice, and deletion. It also runs eight fixed lethal steering
directions and an inward-then-reverse braking schedule:

~~~sh
bash instrumentation/mupen64plus/run_attack_probe.sh \
  /path/to/baserom.us.z64
~~~

The wrapper rejects any ROM whose MD5, SHA-256, or header CRC differs from the
authenticated US release. The local Mario fixture explicitly clears and logs
`squishTimer` and `quicksandDepth`; the lethal fixture writes only hand health
`2` to represent two prior hits. There is no attack-latch fallback or
post-response hand-state injection.

The nonlethal low-speed long jump is a local ordinary-geometry reboard
witness: Mario selects the home-height open top as both floor and platform
while the hand still has velocity `-26` and no ground flag; the flag sets on
the next frame. Mario survives the recovery mesh swap and later rides the
same hand upward. The lethal neutral trace reaches conservative
pre-player-update hand-top gaps `+63` and `+7`, but remains outside
the open top in X/Z at those moments.

Continuous inward stick `(0,+127)` later enters the lethal hand footprint and
selects it as floor only after the hand has grounded; it never becomes Mario's
platform. More decisively, `brake32` holds inward stick on pose-relative polls
`[1,32)`, then reverses it. This keeps the target selected as floor through
DIE timer 39 while X/Z remains valid, but Mario is still 43 above the top and
the platform is null. The hand is deleted while Mario is 21 above; his first
top crossing is the following frame, after the target is gone. Thus deletion,
not just lateral drift, blocks this bounded lethal reboard candidate.

Neither nonlethal nor lethal slide kick reboards: the first open-front-wall
hit forces `ACT_BACKWARD_AIR_KB` before the hand response. See
`results/attack_reboard_manifest.md` for exact fixtures, controller schedules,
source/geometry boundaries, and ABC interpretation.
`results/attack_reboard_trace.csv` contains the four base witnesses, while
`results/lethal_steering_sweep.csv` distinguishes height candidates, selected
floor, platform/landing, deletion, and the first post-deletion crossing. These
are local microtraces, not controller-only reachability proofs or a zero/0.5-A
route.

## Sleeping-hand Pedro collision probe

`run_pedro_probe.sh` compares two disclosed local Mario fixtures against an
otherwise untouched sleeping right hand on the authenticated US ROM:

~~~sh
bash instrumentation/mupen64plus/run_pedro_probe.sh \
  /path/to/baserom.us.z64
~~~

Both fixtures write Mario's position, long-jump action, facing, and starting
speed. They never write the hand. Speed 48 is resolved onto the hand's upper
thumb floor and never takes the Pedro branch. Preloaded speed 424 crosses the
entire greater-than-100-unit wall band in one intended quarter-step. Retail
collision then snaps Mario's Y from `-1532` to the lower floor at `-1459`
while preserving the old X/Z and old static floor height `-1534`. That is the
characteristic Pedro result.

This is a collision-semantic counterexample to unconditional sleeping-strip
entry impossibility. It does not construct speed 424, an authentic controller
predecessor, a repeatable speed-grinding loop, or any A-press classification:
the injected `ACT_LONG_JUMP` suffix proves neither 0 A nor 0.5 A. The separate
source audit also finds a one-unit local entry into the two-hand wake sandwich
on wake frame 11; that fixture has not been replayed as a controller-only TAS,
and the gap becomes 162 on the next frame.

## Original-JP retained-platform probe

`run_jp_platform_probe.sh` checks the version-specific `gMarioPlatform`
behavior on the authentic original-JP ROM:

~~~sh
bash instrumentation/mupen64plus/run_jp_platform_probe.sh \
  /path/to/baserom.jp.z64
~~~

The wrapper validates its supported execution environment and refuses a ROM
unless all of these identifiers match:

```text
MD5:        85d61f5525af708c9f1e84dce6dc10e9
SHA-1:      8a20a5c83d6ceb0f0506cfc9fa20d8f438cafe51
SHA-256:    9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317
header CRC: 4eaa3d0e 74757c24
country:    J
revision:   0
```

A clean pinned-revision `VERSION=jp COMPARE=1` build, with the local TAS hack
disabled, was byte-identical to this ROM. The probe uses matching JP addresses
and Mupen64Plus 2.5.9's cached interpreter.

Both cases place Mario on the genuine static Area 3 warp floor. The natural
case has a null floor owner and null `gMarioPlatform`, then reaches Area 2 with
zero displacement. The injected comparison writes only the genuine hand-slot
address (slot 32) to `gMarioPlatform` immediately before the warp. Area 2
reuses that address for `bhvWaterDroplet`, whose X/Z and angular velocities
are zero. The source/Clight order establishes one unchecked mid-update
platform-displacement call; the callback observes its zero effective delta,
unchanged `forwardVel`, and the later pointer refresh to null.

The input callback cannot observe inside `update_objects`, so source/Clight—not
the trace alone—establishes the application before refresh. No Eyerok explosion,
rotating replacement, controller-authentic stale-floor/hand-pointer state, or
0/0.5-A route was staged. Full setup and scope are recorded in
`results/jp_platform_manifest.md`.
