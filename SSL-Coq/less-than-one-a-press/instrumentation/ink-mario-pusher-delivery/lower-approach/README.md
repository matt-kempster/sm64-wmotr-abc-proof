# Useful enlarged-Bob handoff from supplied air Y1810

**The conditional recipe no longer requires Mario at Y19900.** A supplied
FREEFALL start at **Y1810** mounts the initialized frozen shell, enters butt
slide through Z, receives the Bob and Crazy Box pushes, captures and retains
the top, and reaches the exact useful spawn
`(365.5927734375,5500,-1096.8026123046875)`.

This is twice-reconstructed Wafel JP evidence. It is not a controller route
to the initial pose, a demonstrated actor delivery, or an original-ROM replay.
The original-ROM follow-up, if completed, must be reported separately.

## Exact positive

All changes below occur before top update128. Z is pressed on128, then all
inputs are neutral with A released. No actor or Mario edit follows the cut.

| Supplied part | Initial state |
|---|---|
| Mario | M=C=G `(-1962.4404296875,1810,-1243.34130859375)`; FREEFALL, state/timer0, speed0, velocity `(0,-16,0)`, facing `(0,0,0)` |
| Initialized frozen shell71 | Same X/Z, Y1800; inherited native conditional fake-pickup/release fields |
| Black Bob-omb39 | `(-2079.9365234375,1809.2066650390625,-1233.3045654296875)`; native released91 donor-profile transplant, radius91/fuse170/patrol0 |
| Live Crazy Box49 | `(-2102.720703125,1839.447265625,-1119.5618896484375)`; original native action0/velocity/flags preserved |

The inherited preparation still grants shell-box contents spawning, a pickup
reference, a low pickup pose and a high HOLP throw before repositioning the
shell for this test. It does not demonstrate shell acquisition/delivery at
Y1800. The Bob's native616-input donor and actual628-input release remain
separate from copying its fields here. Full prior values, writes, controller
inputs, native events and sampled actor fields are retained in the archive.

M means movement, C means object collision position, and G means stored
`gfx.pos`, not the visibly rendered model position.

| Completed update | M=C XYZ | G.Y | Action / result |
|---:|---|---:|---|
|128|`(-1960,1809.2066650390625,-1230)`|1809.206665|BUTT_SLIDE, supported by actual top61|
|129|`(-2117.02685546875,1839.447265625,-1113.008544921875)`|1809.206665|Bob shove; top cache1839.447266, no retained platform|
|130|`(-2200.001708984375,768,-1075.00390625)`|1839.447266|Fresh cache768, Crazy Box shove, BUTT_SLIDE_STOP; gap1071.447266|
|131|`(-2200.001708984375,1914.85498046875,-1075.00390625)`|1914.854980|Warp64 accepted; top61 floor/platform|
|27th recorded update|`(365.5927734375,5500,-1096.8026123046875)`|5500|Useful Area2 spawn|

Top61 remains the platform at every observed Area1 boundary after capture.
Collision lists are `[71,39]`, `[71,39]`, `[49]`, `[64]` for128–131. The
shell's persistent native status prevents its second contact from becoming
another mount. No live collision geometry or interaction type was assigned.

The initial130 floor diagnostic reports768 at the actual pre-update Mario
position, with ceiling1523. It substitutes DISAPPEARED only in an isolated
branch and restores the whole state before the real trial. Its writes are
logged separately and never enter the successful history. The real completed
producer retains floor768 and the expected M/C/G split. This Wafel packet
does not claim an original-ROM internal-query trace.

## Why lowering the original pose was insufficient

At the old X/Z, low shell entry performs an accepted ground movement before
alignment, displacing the first endpoint by about `(2.44043,8.89758,13.34131)`.
Translating the initial X/Z by `(-2.4404296875,-13.34130859375)` restores the
same first Mario endpoint as the high control.

There is then a second difference: G is already low after128. The Bob's
4000-unit G-distance gate opens one update earlier. With its original
placement, Bob moves natively to
`(-2080.18359375,1871.849853515625,-1227.3394775390625)` and selects explosion
action with timer0 on128. This changes its next shove. The exact uncompensated
Y1810 control reaches the wrong intermediate X/Z and initial130 selects
top1913.823486 rather than static768; it stays in Area1 through the45-update
observation horizon.

Moving **only Bob's initial X/Z** by
`(+0.12353515625,-2.9825439453125)` compensates its first native movement.
After128 its actual position is
`(-2080.06005859375,1869.9464111328125,-1230.322021484375)`.
The different actual Y still overlaps Mario for129. Its radius remains91
for that collision, and its later native growth/deletion remains active.
The first compensation tried succeeds; no additional inverse iteration was
run. This is still an initial actor-placement grant, not Mario placing it.

## Finite coverage

| Script / archive | Exact coverage | Histories | Recorded boundaries |
|---|---|---:|---:|
|`check.py` / `results.json.gz`|Original X/Z, heights19900,1768,1809.206665,1810,1830,1900,2000,2099.514893|8|252|
|`corrected.py` / `corrected-results.json.gz`|Corrected X/Z at1768/1810/1830/1900; eight Y1810 axial offsets of2 or4|12|468|
|`refine.py` / `refine-results.json.gz`|Y1810, X correction offsets0.5/1/1.5 by Z offsets−0.5/0/0.5|9|315|
|`edge.py` / `edge-results.json.gz`|Y1810, X offsets0.75/1/1.25 by Z offsets−0.3/−0.2/−0.1|9|369|
|`compensated.py` / `compensated-results.json.gz`|One measured initial Bob X/Z compensation, otherwise corrected Y1810 recipe|1|27|
|Total|Every history independently reconstructed twice|39|1431|

Two histories reach the useful spawn: the known19900 baseline and the new
compensated1810 case. Sixteen reach ordinary Area2;21 have no Area2 arrival
within45 updates. These outcomes are finite observations, not a height window,
global minimum, or impossibility claim. In particular, lower2000/2099 tests
enter BUTT_SLIDE_AIR; many lower controls do obtain fresh768 but still fail
the subsequent contact/cache/warp geometry.

`positive-case.json` and `uncompensated-bob-case.json` export the positive and
exact corrected-X/Z negative, with all pre128 edits, zero later cuts, and full
expected samples. `export.py` generates them from the saved verified results.

## Reproduction and versions

From `SSL-Coq/less-than-one-a-press`, run each script with the bundled Python:

```powershell
& './build/wafel-pilot/python/python.exe' 'instrumentation/ink-mario-pusher-delivery/lower-approach/check.py' --verify
& './build/wafel-pilot/python/python.exe' 'instrumentation/ink-mario-pusher-delivery/lower-approach/corrected.py' --verify
& './build/wafel-pilot/python/python.exe' 'instrumentation/ink-mario-pusher-delivery/lower-approach/refine.py' --verify
& './build/wafel-pilot/python/python.exe' 'instrumentation/ink-mario-pusher-delivery/lower-approach/edge.py' --verify
& './build/wafel-pilot/python/python.exe' 'instrumentation/ink-mario-pusher-delivery/lower-approach/compensated.py' --verify
& './build/wafel-pilot/python/python.exe' 'instrumentation/ink-mario-pusher-delivery/lower-approach/export.py' --verify
```

All five experiment scripts completed with exit0, each comparing two fresh
reconstructions before writing results. Export completed successfully. The
runtime is Wafel0.8.5 / Python3.9.13, JP DLL SHA-256
`960fe979068b78e673b3ddb87741833fbf4eb29b2a21a2bba871977427c2d0f`.
Proof checkout start: `0605d842cedb55151e70952d56064553c4970f60`.
Applicable source pin: `9921382a68bb0c865e5e45eb594d9c64db59b1af`;
local decompile HEAD: `36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`.

Credit: the older `ink-item-native-slide-combinations.md` already had a
different supplied low-air shell/Buddy positive and its X/Z correction.
This package applies that lead to the latest Buddy-free enlarged-Bob recipe
and diagnoses its earlier Bob movement. It neither rediscovers low-air entry
in general nor connects the known clean Fly Guy2099/ground-slide1768 history
to this exact shell contact and top phase. That controller join remains open.
