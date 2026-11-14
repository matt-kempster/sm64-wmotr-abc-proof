# High-air and yaw-only support comparisons

Run from `SSL-Coq/less-than-one-a-press`, using a new output path:

```powershell
& ./build/wafel-pilot/python/python.exe instrumentation/ink-high-support-entry/search.py build/wafel-pilot/capture.bKv95w/inputs.jsonl build/NEW-high-support.json
```

This is a bounded Wafel JP diagnostic, not a continuous no-new-A route.
The script tests 60 high-freefall recipes, 12 native landing/support recipes
and two supplied-slide positive controls. The initial pose, airborne action,
velocity and optional box XYZ are supplied once; a write guard then permits
controller input only. No floor, ceiling, platform, mesh, top timer or RNG is
edited. The two positive controls explicitly supply butt slide and native
slide velocity to check the existing useful handoff, not to claim new entry.

Six updates are retained for every screen recipe. Eight selected high-air
cases, all 12 support cases and both positive controls continue up to 33
updates or first Area2. Those 22 histories are compared with reconstruction
from a separate fresh Wafel game and prefix, including every field and event.
The script refuses to overwrite an existing output and uses no random seed.

The horizontal-PU support cases supply extreme initial air speed. They do
not supply a platform pointer; actual native landing and end-update floor
selection acquire the top. The top has native yaw only, so this does not
provide a vertical-PU boost. No controller acquisition of the supplied speed
or initial airborne pose is claimed.

Every setup write, controller input, M/C/D, floor/cache, owner, platform,
top transform and action/movement event is retained. The Wafel event field
`_placeholder` is preserved for replay equality but is not interpreted as
a native quarter-step return hook. Source reasoning and observed endpoints
are distinguished in `docs/notes/ink-high-support-entry.md`.

Permanent receipt: `docs/notes/ink-high-support-entry-receipt.json`.
Original output: `build/wafel-pilot/ink-high-support-entry-20261114.json`.
