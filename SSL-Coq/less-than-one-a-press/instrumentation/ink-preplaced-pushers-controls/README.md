# Preplace the two pushers before the shell update

**Both actors can be placed before update128 at the exact positions formerly
supplied later.** The finite Wafel JP control succeeds without further gameplay
state edits after the initial high FREEFALL cut. No compensated placement or
expanded search was necessary. The conditional donor profile, frozen-shell
preparation and high Mario entry remain supplied; this is not item delivery.

Starting root and controls are the established enlarged-Bob positive:
Mario `(-1960,19900,-1230)`, FREEFALL, speed0, velocity `(0,-16,0)`, yaw0;
initialized frozen shell `(-1960,19890,-1230)`. Input128 is Z; all subsequent
inputs are neutral, with A released throughout. The exact receiving Bob
profile comes from the separately controller-reached native released91 donor.

The two actor origin positions are:

- Bob39: `(-2080.06005859375,1809.2066650390625,-1230.322021484375)`.
- Crazy Box49: `(-2102.720703125,1839.447265625,-1119.5618896484375)`.

| Case | Bob placement | Box placement | Later actor edits | Outcome |
|---|---|---|---|---|
| Original staged control | Before129 | Before130 | Two XYZ cuts | Useful displaced spawn |
| Both preplaced | Before128 | Before128 | None | Useful displaced spawn |
| Bob preplaced only | Before128 | Before130 | One XYZ cut | Useful displaced spawn |
| Box preplaced only | Before129 | Before128 | One XYZ cut | Useful displaced spawn |
| No-Box-placement control | Before128 | Original world position retained | None | Ordinary spawn, no top capture |

Every case reaches Area2 after27 updates from the airborne cut, before the
45-update limit. Useful spawn is exactly
`(365.5927734375,5500,-1096.8026123046875)`; ordinary spawn is `(0,5500,256)`.
The negative does not delete the Crazy Box from the world. It omits its
placement near Ink, while retaining the enlarged Bob and native callbacks.

## What happens when both are preplaced

| Completed update | M = C | Stored G.Y | Action | Cache / platform |
|---|---|---|---|---|
| 128 | (-1960,1809.2066650390625,-1230) | 19900 | BUTT_SLIDE | Top1809.206665, platform61 |
| 129 | (-2117.02685546875,1839.447265625,-1113.008544921875) | 1809.2066650390625 | BUTT_SLIDE | Top1839.447266, no platform |
| 130 | (-2200.001708984375,768,-1075.00390625) | 1839.447265625 | BUTT_SLIDE_STOP | Static768, no platform |
| 131 | (-2200.001708984375,1914.85498046875,-1075.00390625) | 1914.85498046875 | DISAPPEARED | Top61 captured as platform; warp64 accepted |

Observed Area1 platform retention continues to the displaced Area2 arrival.
The no-Box-placement control also finishes130 with floor/cache768 and the
1071.447265625 vertical gap, but at
`(-2117.71533203125,768,-1111.11328125)`. It accepts the warp without capturing
the top, then reaches ordinary Area2.

The actors are not frozen. Bob remains at its supplied position through128
with native radius91/fuse170. Update129 moves it to
`(-2078.953369140625,1835.079345703125,-1227.845947265625)` and selects explode
timer0/fuse171. Subsequent growth and deletion remain native. The preplaced
Box begins at Y1839.447265625, reaches1852.87353515625 after129, and reaches
1923.4852294921875 after130. This differs from the staged Box's Y history,
but it still registers the needed130 collision and supplies the same shove.
The receiving-world donor transplant remains explicitly logged; no radius,
fuse, velocity, action or callback is adjusted after the airborne setup.

There is **no failed requirement in these four positive timing controls**.
Across all27 boundaries, their selected Mario/contact projection
M/C/G, action/state/timer, floor/cache owner, platform, used/ridden pointers
and collision lists matches the original staged positive. Actor state and
other world data are not claimed to be identical. The negative first differs
at the130 producer endpoint and does not capture the top at131. Merely getting
cache768 and a gap is again insufficient for useful spawning displacement.

## Scripts, checks and evidence limits

`check.py` reconstructs the four timing cases twice from independent fresh
roots and compares108 boundary snapshots, retaining full actor fields,
velocities, callback timers, fuse, M/C/G, action events and setup ledgers in
`results.json.gz`. The original staged control also matches the earlier
archived positive. `export.py` independently regenerates the both-preplaced
positive and zero-later-cut omission control twice (54 boundaries), saving
`zero-later-cuts-pair.json.gz` and the generic native-replay inputs:

- `both-pre128-positive.json`, case name `positive`.
- `both-pre128-no-box.json`, case name `no-final-box`.

Both exports list all donor/actor/Mario initial writes in their actual order,
have empty later `cuts`, and preserve controls and expected rich snapshots.
They are input files for an original-ROM follow-up, not themselves evidence
that such a follow-up has run. This package's evidence level is Wafel JP.
It does not hook the initial floor query; its floor values are recorded update
boundaries. Separate restored-query diagnostics or native traces have their
own evidence scope.

```powershell
& build/wafel-pilot/python/python.exe instrumentation/ink-preplaced-pushers-controls/check.py --verify instrumentation/ink-preplaced-pushers-controls/results.json.gz
& build/wafel-pilot/python/python.exe instrumentation/ink-preplaced-pushers-controls/export.py --verify
```

Runtime: Wafel0.8.5 / Python3.9.13, JP DLL SHA-256
`960fe979068b78e6733b3ddb87741833fbf4eb29b2a21a2bba871977427c2d0f`.
The result records the exact prior-positive artifact hash. Applicable JP source
pin remains `9921382a68bb0c865e5e45eb594d9c64db59b1af` in local decompile
`36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`. No Coq source or theorem is added.
Preplacement immediately before128 is tested; arbitrary earlier waiting,
normal delivery and reaching the high airborne start remain untested here.
