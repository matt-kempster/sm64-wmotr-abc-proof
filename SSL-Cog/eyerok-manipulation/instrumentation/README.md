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
