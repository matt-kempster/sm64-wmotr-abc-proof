# JP Rank-11 handstand damage diagnostic

This is a **fixture-assisted payoff test**, not a controller-only movie or
clean lower entry. It tests whether an ordinary Goomba hit can retain the
handstand height and carry Mario across the second-pole aperture. It uses
the inherited level-select cheat and Area-2 fixture described below; this
probe adds no action-table, behavior-pointer, or game-code edit.

## Explicit fixtures and controls

The probe composes `jp-rank11-pole-release`, which already composes the
`jp-full-route` / `jp-lifecycle` injected Area-2 loader. It retains that
loader and the 23 logged pole-contact writes unchanged. The extra fixture
is exactly **three writes** to one already-spawned Goomba's object X/Y/Z.
They move it to `(0, contactY, 1371)` once. They do not alter Mario's damage
action, velocity, animation, collision status, or tables.

The unique regular Goomba is selected by its saved home X/Z `(3263,3157)`,
active flag, normal bounce-top interaction, and damage 1. Its actual saved
home Y is 640, not the macro spawn's 778: its behavior drops to the floor
before `SET_HOME`. The probe prints the live behavior, home, flags, action,
and tangibility before any extra write. The validator checks those observations.

| Mode | Contact boundary | Controller setup after the inherited pole fixture |
|---|---|---|
| `0` | Steady handstand, Y 4194 | Climb, then wait ten distinct-timer handstand polls. |
| `1` | Ordinary holding, Y 4020 | Neutral input for ten holding polls; no climb. |
| `2` | Last return-animation frame, Y 4070 | Climb, wait, descend; suppress the base probe's pending Z on animation 12, frame 0. |

All inputs after the Goomba placement are neutral. No mode supplies A.
The inherited base logs are retained for provenance, but its `R11_FRAME`
button columns precede this wrapper's overrides: use **`H11_INPUT`** for the
controller input actually returned. `H11_FRAME` reads memory at that poll;
the returned input applies to the next update.

## Run and validate

Supply a legally obtained local JP ROM. The runner checks MD5 and SHA-256,
builds with GCC warnings as errors, and uses interpreter-mode Mupen64Plus,
Rice video, RSP HLE, Xvfb, and software OpenGL. Each mode has isolated
configuration/data/output under the project's ignored `build/` directory.
Repeating a mode replaces only that mode's generated output.

```bash
bash SSL-Coq/less-than-one-a-press/instrumentation/jp-rank11-handstand-damage/run.sh /path/to/baserom.jp.z64 0 750
bash SSL-Coq/less-than-one-a-press/instrumentation/jp-rank11-handstand-damage/run.sh /path/to/baserom.jp.z64 1 750
bash SSL-Coq/less-than-one-a-press/instrumentation/jp-rank11-handstand-damage/run.sh /path/to/baserom.jp.z64 2 850
```

`raw.log` includes the inherited fixture log. `trace.txt` includes the pole
fixture writes, final returned controller inputs, Goomba writes, the first
110 distinct-timer post-placement position samples, and the outcome.
The runner calls `validate.py`; a missing placement, wrong write, lost
height, failed crossing/landing/recovery, or nonzero A makes it fail.

Additional evidence checks, including deliberately altered negative cases:

```bash
python3 SSL-Coq/less-than-one-a-press/instrumentation/jp-rank11-handstand-damage/validate.py --self-test SSL-Coq/less-than-one-a-press/build/instrumentation/jp-rank11-handstand-damage/mode-{0,1,2}/trace.txt
```

`--receipt` prints the compact JSON receipt without modifying files. The
committed [verified receipt](verified-receipt.json) includes all 23+3 logged
writes and every sampled position through the first ring landing. Hashes
use LF-normalized bytes so line-ending conversion is not a content change.
The validator checks logged evidence; it is not an independent instruction
trace, and matching a receipt does not establish clean reachability.

## Result and limits

All three tests retain their incoming height, enter ordinary backward air
knockback at forward speed -16, cross the existing south target-air box,
land at Y 3942, and recover to idle on the target side. The handstand test
crosses at `(0,4110,1219)`; the ordinary-holding control also succeeds.
Thus the handstand's extra 174 units can survive, but are not necessary
for this installed-enemy payoff.

No star suffix is attempted. This probe does not record every collision
quarter, establish every surface owner, or connect IDO machine states to
Clight. The full fixture is not a valid clean start; particularly, the
Goomba's initially distant position is changed directly. That missing
controller-only transport is the next obstacle, not a demonstrated glitch.

See the [source/proof and residual audit](../../docs/notes/rank11-handstand-damage.md).
