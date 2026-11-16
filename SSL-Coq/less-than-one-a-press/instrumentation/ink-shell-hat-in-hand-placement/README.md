# Hat-in-Hand placement search: completed data preserved, follow-up stopped

15 November 2026. **Stopped at the user's request.** No younger-Bob test,
additional Bob/HOLP adjustment or original-ROM replay was run after that
instruction. The already completed records below remain available. They do
not demonstrate a continuous delivery route or useful spawning displacement.

The actual remote shell throw precedes one supplied setup of Mario's cap-in-
hand flag, HOLD_FREEFALL carrying Crazy Box49, remote HOLP, and an exact native
released91 Bob profile/position. The cap flag is `(flags & ~0x10) | 0x20`;
native rendering derives handState3 and preserves HOLP. Neither hand state nor
rendering state is locked per frame. Only no-A controller inputs follow the
initial setup. Hat-in-Hand acquisition, Mario's approach and Bob delivery are
explicit grants. The earlier five-case cap/ordinary comparison is in
`../ink-shell-handsfree-placement/CAP-CONTROL.md`.

## Completed finite runs

* `search.py` / `results.json.gz`:234 cases, each reconstructed twice from
  independent fresh roots,10530 suffix boundaries per reconstruction. The117
  B starts from the earlier single-placement menu are each tested with the
  old Box release-origin HOLP and a free-flight-compensated HOLP intended to
  put the Box near the final push position at the end of129. The compensation
  is only a heuristic; the actual game computes floor contact, drag and
  release/flight. No capture or useful spawn occurred.
* `refine.py` / `refine-results.json.gz`:105 cases, likewise reconstructed
  twice,4431 suffix boundaries per reconstruction. These fix phase124,
  vertical velocity−16, compensated Box flight and vary initialMarioY
  1930/1940/1950, X offset−12..12 in steps of4 and Z offset0..16 in steps of4.
  This reaches fresh floor768 and ordinary warps in some cases, but no top
  capture or useful spawn.

All numbered phases denote the top timer at the **start** of the update.
The full records preserve initial state writes, controls, native shell
preparation, cap/HOLP evolution, actual Box releases, M/C/G, actor identity/
lifetime, cache, platform, collision lists and action events. B requests
interrupted by shell contact are not automatically counted as actual throws.

One close completed case is phase124/Y1930, initialX offset0 andZ offset4,
with flight compensation. Mario first mounts/cancels on128. The native
throw leaves the Box alive at `(-2102.720703125,1930,-1119.5618896484375)` at
the end of129. Mario's measured sequence is:

| Update | Mario M | G.Y | Platform |
|---|---|---:|---:|
|128|`(-1954.7318115234375,1803.0908203125,-1233.6724853515625)`|1803.090820|61|
|129|`(-2130.569580078125,1833.285888671875,-1104.9486083984375)`|1803.090820|none|
|130|`(-2197.546630859375,768,-1069.9930419921875)`|1833.285889|none|
|131|`(-2099,768,-1069.9930419921875)`|768|none|

The Box participates in the130 collision pass and the warp is accepted, but
top capture fails and arrival is ordinary. This is close in horizontal
position to the prior supplied positive, but its producer G.Y is about6.16
units lower. A failed-floor retry-height explanation is a lead to inspect,
not a proven cause recorded by this packet's query hooks.

The planned next step was a small initial Bob-position/Box-HOLP adjustment to
control Mario's129 floor height and130 shove endpoint, while retaining one
initial setup only. That experiment was **not run**. A younger native Bob
release profile was also suggested but **not tested**. No Coq statement or
proof is added. Original-JP validation would only follow a useful positive.

Existing reproduction commands (not run again after the stop instruction):

```powershell
& build/wafel-pilot/python/python.exe instrumentation/ink-shell-hat-in-hand-placement/search.py --verify
& build/wafel-pilot/python/python.exe instrumentation/ink-shell-hat-in-hand-placement/refine.py --verify
```

These commands reconstruct their full finite menus twice and compare the
saved records. Applicable JP source pin:
`9921382a68bb0c865e5e45eb594d9c64db59b1af`; local decompile:
`36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`. Wafel0.8.5/Python3.9.13 DLL SHA256:
`960fe979068b78e6733b3ddb87741833fbf4eb29b2a21a2bba871977427c2d0f`.
G means Stored Graphics (`gfx.pos`), not the rendered model.
