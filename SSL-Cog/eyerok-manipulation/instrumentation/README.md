# Eyerok instrumentation

The Mupen64Plus probe in the mupen64plus folder checks the narrow
IDLE -> BEGIN_DOUBLE_POUND -> DOUBLE_POUND velocity question on the
authentic North-American ROM. It is deliberately separate from the Rocq proof
and does not replace the source audit.

Run it inside the Ubuntu-24.04 WSL distribution:

~~~powershell
wsl.exe -d Ubuntu-24.04 -- bash -lc "\
cd '/mnt/c/Users/tariq/OneDrive/Documents/sm64 - the item-grab proof/reference-sm64-wmotr-abc-proof/SSL-Cog/eyerok-manipulation' && \
bash instrumentation/mupen64plus/run_idle_double_probe.sh \
  '/mnt/c/Users/tariq/OneDrive/Documents/sm64 - the item-grab proof/reference-sm64-decomp/baserom.us.z64'"
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
kick. The wrapper requires `WSL_DISTRO_NAME=Ubuntu-24.04`, checks both MD5 and
SHA-256, builds three debugger input plugins, and runs Mupen64Plus in the pure
interpreter:

~~~powershell
wsl.exe -d Ubuntu-24.04 -- bash -lc "\
cd '/mnt/c/Users/tariq/OneDrive/Documents/sm64 - the item-grab proof/reference-sm64-wmotr-abc-proof/SSL-Cog/eyerok-manipulation' && \
bash instrumentation/mupen64plus/run_contact_probe.sh \
  '/mnt/c/Users/tariq/OneDrive/Documents/sm64 - the item-grab proof/reference-sm64-decomp/baserom.us.z64'"
~~~

The stationary mode authenticates Mario's selected dynamic floor and platform
as the closed hand top at Y `-1228`. On the first `+85` hand step Mario is
still inside the transformed top in X/Z, but the pre-query vertical gap is 85,
seven beyond the floor buffer. The arena floor wins, the raised hand underside
becomes a dynamic ceiling, and retail code selects `ACT_SQUISHED`.

Both prepared-action modes start at hand action timer 2. Retail code completes
two Mario air updates before the hand launch: Y `-1208`, velocity `16`, then Y
`-1192`, velocity `12`. Because surface objects update before Mario, the hand
then rises to top Y `-1143`; the pre-query gap is 49, inside the 78-unit
allowance, and ordinary collision snaps Mario to the same hand.

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
columns. `within78` is a conservative pre-query buffer test based on the
previous completed Mario Y; the ROM-reported floor and platform owners are the
decisive contact evidence. See `results/contact_manifest.md` for every setup
write and the exact scope. The results prove the local contact transition, not
controller-only reachability of the injected predecessor pose or a useful warp
dismount.
