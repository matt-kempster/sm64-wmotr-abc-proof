# Carry the enlarged Bob into the actual remote shell

**A useful final join works: shell contact can release the held radius91 Bob,
mount the shell, and cancel with fresh Z in one update.** From that single
supplied carrying approach, no Mario or actor field is edited again. The native
Bob shove, native Crazy Box shove, fresh768 cache, warp acceptance, top capture,
observed retention and exact displaced spawn all follow.

This is not the user's complete unedited placement route. The shell is actually
thrown remotely first, but the later Box carrying state and the final Bob
carrying approach are separately supplied. No ordinary pickup/delivery history
joins those states yet. In particular, this packet does not claim the Box's
post-drop ground pound becomes the final held-Bob approach through inputs.

## Strongest positive and exact remaining grants

`positive.json` preserves the originalJP replay input/export. Its sequence is:

| Before update | Setup or native event |
|---|---|
|Shell preparation|The inherited four-pillar conditional root spawns/initializes the native shell and obtains it through the existing fake-pickup preparation. The real throw uses supplied HOLP `(-1962.4404296875,1800,-1275.34130859375)` and yaw0. It releases the shell at `(-1962.4404296875,1800,-1243.34130859375)`. No subsequent shell XYZ write occurs.|
|126|Supply Mario HOLD_FREEFALL at `(5900,1920,3440)`, held Crazy Box49, and HOLP `(-2102.720703125,1920,-1119.5618896484375)`. Z invokes the actual drop; the native floor correction lifts the Box toY1933.432129. No later Box field is edited.|
|127|Neutral input only. Mario remains in ground pound remotely; the Box stays far-away. The Bob is still its original world actor.|
|128|Supply one held-Bob approach: Mario HOLD_FREEFALL at `(-1962.4404296875,1810,-1243.34130859375)`, velocity `(0,-16,0)`, speed0, yaw0, held/used Bob39 with the exact native held91 donor scalar profile. Bob's carried origin and HOLP X/Z are supplied. The decisive positive clears Mario's expired-drop request to0; no forced-drop request is needed. All subsequent writes are controller input only.|
|128 native update|Fresh Z. Shell contact drops the held Bob at rawMarioY1810 and HOLP X/Z `(-2080.06005859375,-1230.322021484375)`, clears the hold, mounts, then reaches CROUCH_SLIDE and BUTT_SLIDE. Bob's later native drop callback raises it toY1867.130615.|
|129|Bob supplies the shove. Mario reaches `(-2117.02685546875,1839.447265625,-1113.008544921875)` in BUTT_SLIDE.|
|130|Fresh floor cache768; native Box shove gives M=C `(-2200.001708984375,768,-1075.00390625)` while stored G.Y remains1839.447265625. The Box deletes later in this update, after supplying its collision.|
|131 onward|The real warp is accepted, the high-G floor retry selects top61, and the top remains installed at observed Area1 boundaries. Exact Area2 movement position is `(365.5927734375,5500,-1096.8026123046875)`.|

The decisive action events are HOLD_FREEFALL → RIDING_SHELL_GROUND →
CROUCH_SLIDE → BUTT_SLIDE within update128. This is not a merely airborne
slide-looking animation, nor a supplied ground action. The source explanation
is `interact_koopa_shell` calling `mario_drop_held_object` before setting
RIDING_SHELL_GROUND, followed by the riding handler's fresh-Z transition.
The native drop writes raw Mario Y rather than HOLP Y. That was unsuitable at
the former19900 entry; it works at this lower entry. Bob's native callback
timing differs from the already-free/patrol profile, so its original pending-
drop HOLP X/Z are retained rather than the old compensated patrol coordinates.

All setup writes appear in the ledgers. The126 ledger has15 typed writes,
and the128 carried-approach ledger has57, including intermediate overrides;
these counts are not scalar ROM-store counts. The earlier shell preparation
and the real donor's no-A pickup/regrab inputs are also preserved. Copying
the donor fields does not transport that original Bob through one history.
All controller inputs keep A released, and the runtime rejects A-related
Mario input flags. M means Movement, C Collision and G Stored Graphics
(`gfx.pos`), not rendered model position.

## Finite menu and informative failures

`check.py` tests65 complete continuations, each reconstructed from two fresh
roots. This is2613 observed update boundaries per reconstruction, excluding
the separately recorded prefixes. Twenty-four are useful: supplied approach
update128, initialMarioY1810/1830/1850, Box dropY1920/1940/1980/2010, with or
without the expired-drop request. These are discrete points, not continuous
height windows. The other40 ordinary menu cases stay in Area1 through the
bounded continuation. The final no-Box control reaches ordinary Area2.

`no-box.json` omits the Box carry/release while preserving the native shell
throw and Bob approach. Mario still gets a floor768 graphics gap, but no top
capture follows; arrival is ordinary `(0,5500,256)`. A gap alone is insufficient.

`refine.py` tests36 earlier update127 approaches: MarioY1855/1860/1865,
initialZ offsets0/23/46, BoxY1920/1940/1980/2010, velocity−16, no expired-drop
request, freshZ128. All1692 observed boundaries independently reconstruct;
none captures or reaches Area2 within the bounded continuation. This does
not exclude other earlier approaches, velocities, release positions or inputs.

`frontier.py` retains two additional twice-reconstructed controls/96 boundaries:

- Removing the final supplied held-Bob approach altogether leaves Mario in
  the actual Box-drop GROUND_POUND at `(5900,1940,3440)` after126. He never
  acquires the Bob or contacts the shell in this neutral continuation; after
  48 updates he is at `(5900,614,3440)`. This is the first concrete missing
  join, not a global no-A impossibility result.
- Keeping the supplied held-Bob approach but omitting freshZ mounts and
  retains RIDING_SHELL_GROUND initially. It does not produce useful displacement.

The103 continuations cover4401 observed boundaries per reconstruction. The
pilot file is superseded exploratory output; it is excluded from the sealed
packet and verifier. No new proof code or Coq build is claimed. Original-ROM
validation belongs to the separate parent-owned `jp-ink-shell-three-releases`
packet; these exports alone are Wafel evidence.

## Reproduction

Run from `SSL-Coq/less-than-one-a-press` in Windows:

```powershell
& build/wafel-pilot/python/python.exe instrumentation/ink-shell-carried-bob-mount/check.py --verify
& build/wafel-pilot/python/python.exe instrumentation/ink-shell-carried-bob-mount/refine.py --verify
& build/wafel-pilot/python/python.exe instrumentation/ink-shell-carried-bob-mount/frontier.py --verify
& build/wafel-pilot/python/python.exe instrumentation/ink-shell-carried-bob-mount/archive.py --verify
```

Run these commands sequentially: the inherited root reconstructors share a
scratch prefix filename. An attempted parallel verification caused one root's
four-pillar precondition to fail before the test began. Its subsequent isolated
verification passed against the unchanged retained artifact; no failed-root
result is included in the accepted menus.

Start proof revision `ea1a4994f5157636f481723a89c6411a53e6e6d4`; applicableJP
source pin `9921382a68bb0c865e5e45eb594d9c64db59b1af`; local decompile
`36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`. Wafel0.8.5/Python3.9.13 uses
JP DLL SHA256 `960fe979068b78e6733b3ddb87741833fbf4eb29b2a21a2bba871977427c2d0f`.
No route percentage changes are implied by these finite successes.
