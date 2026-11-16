# Three native releases compose, but three carrying/approach cuts remain

15 November 2026. The actual remote shell throw composes with the actual Crazy
Box and enlarged Bob-omb drops and still produces useful Ink displacement.
There is no shell edit after its throw, no Box edit after its drop, and no Bob
edit after its drop. **This is not the requested continuous no-later-position-
edit delivery history:** the two carrying states and the later Mario approach
are supplied separately. Removing the final Mario approach cut fails in the
preserved control.

This credits and composes the prior
[`ink-shell-remote-functionality/handoff.py`](../ink-shell-remote-functionality/handoff.py)
remote release and the prior
[`controlled-bob/lower-joint.py`](../ink-mario-pusher-delivery/controlled-bob/lower-joint.py)
two-drop lower entry. Those earlier artifacts are unchanged. The new test
removes the former lower-joint shell XYZ placement by having Mario's actual
native throw put it there first.

## Exact timeline and surviving grants

The shared four-pillar shell root still supplies its shell-box action grant,
low Mario/shell pickup preparation and one used-object retarget. Real pickup
produces the held reference and carry script. Yaw0 B throw receives supplied
HOLP `(-1962.4404296875,1800,-1275.34130859375)` before throw update7. Its actual
release places the initialized shell71 at
`(-1962.4404296875,1800,-1243.34130859375)`, observed at stored top timer25.
No subsequent write targets that shell. The24 throw-continuation updates and
84 further neutral updates leave the top at126 and the shell still fixed.
Mario's actual pre126 position is `(5913.544921875,51,3320.7841796875)`.

| Before update | Supplied cut | Native result |
|---|---|---|
|126|Mario M/C/G to `(5900,1920,3440)`, HOLD_FREEFALL, Box49 held reference/state, HOLP `(-2102.720703125,1920,-1119.5618896484375)`|Z drops Box; its native floor query raises originY to1933.432129. Mario becomes GROUND_POUND atY1940.|
|127|Mario M/C/G to `(5900,1809.2066650390625,3440)`, HOLD_IDLE, held/used Bob39; native held91 donor scalar profile, carried Bob XYZ, forced-drop status and HOLP `(-2080.06005859375,1809.2066650390625,-1230.322021484375)`|Neutral forces actual Bob drop. Mario ends FREEFALL at `(5900,1809.2066650390625,3417)`. Bob is pending HELD_DROPPED.|
|128|Mario-only FREEFALL cut to `(-1962.4404296875,1810,-1243.34130859375)`, velocity `(0,-16,0)`, speed0/yaw0|Fresh Z accepts mount/cancellation and executes BUTT_SLIDE.|
|129|None|Bob shove reaches M `(-2117.02685546875,1839.447265625,-1113.008544921875)`.|
|130|None|Fresh floor cache768; Box shove gives M=C `(-2200.001708984375,768,-1075.00390625)`, G.Y1839.447266.|
|131 onward|None|Low warp acceptance, top61 capture and observed retention, then useful Area2 spawn `(365.5927734375,5500,-1096.8026123046875)` in29 observed updates from126.|

The first post-shellthrow position edit is the126 Mario relocation, including
the rise fromY51 to1920. The127 and128 cuts are likewise not gameplay
continuations. Actual pickup/delivery of the two pushers and Mario's journey
to the mount have not been joined. There are15 vector/scalar ledger entries
at126,52 at127 and12 at128; these are not scalar-expanded ROM write counts.
All are preserved with before/after values. Only controller writes occur
after128. The native callbacks and object lifetime remain enabled.

M is Movement, C Collision, G Stored Graphics (`gfx.pos`), not the visible
model. The producer's G/M gap is1071.447265625.

## Controls

* **No Box release:** leaves the original Box at its world position, performs
  the same remote shell throw/Bob drop and supplied1810 approach. The result
  is ordinary `(0,5500,256)`, without top capture. It has29 observed updates.
* **No final Mario approach cut:** keeps both native pusher drops but omits
  the128 relocation/action/velocity cut. At128 Mario is still by the remote
  carrier, and Z enters GROUND_POUND at `(5900,1829.2066650390625,3417)` with
  no shell contact. After47 observed updates he remains in Area1 at
  `(5900,614,3417)`, with no capture or arrival. This is one finite negative,
  not a proof that no steering or different release schedule can work.

All three traces are independently reconstructed twice from fresh roots,
including shell pickup/release and held91 donor reconstruction. The selected
continuations total105 boundaries per reconstruction. There are no A inputs
or held-A dependencies. `r.advance` also rejects interpreted A input flags.
The successful conditional join is Wafel evidence; any original-ROM replay
is separately recorded by its owner. No Coq source was changed or theorem
claimed in this packet.

## Reproduce

From the SSL project directory on this machine:

```powershell
& build/wafel-pilot/python/python.exe instrumentation/ink-shell-three-releases/check.py --verify
& build/wafel-pilot/python/python.exe instrumentation/ink-shell-three-releases/archive.py --verify
```

`results.json.gz` contains full setup ledgers, controls, M/C/G and actor/cache/
collision/platform observations, event traces, release/wait history and donor
preparation. `positive.json`, `no-box.json` and `no-entry.json` export the
phase126 suffix with supplied cuts, expected samples and actual shell HOLP.
Original-JP generation must perform that remote throw rather than the old
default highHOLP; the existing release generator accepts phase126/cuts127–128,
whereas the older remote-shell wrapper accepts only phase128/no-cut cases.

Start/pushed revision: `ea1a4994f5157636f481723a89c6411a53e6e6d4`.
Applicable JP source pin: `9921382a68bb0c865e5e45eb594d9c64db59b1af`.
Local decompile: `36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`.
Wafel0.8.5/Python3.9.13 DLL SHA256:
`960fe979068b78e6733b3ddb87741833fbf4eb29b2a21a2bba871977427c2d0f`.
