# Raising the actual remote shell: twelve finite negative controls

15 November 2026. Raising the shell can preserve the mount-dropped Crazy Box
longer, but the tested positions lose the required ground-step trajectory.
None of12 tested shell heights produces top capture or useful displacement.
Each is independently reconstructed twice, with468 total suffix boundaries
per reconstruction. These are discrete points, not continuous bounds.

Every shell position comes from the actual native remote HOLP throw, rather
than a later shell-position edit. The target X/Z remains
`(-1962.4404296875,-1243.34130859375)`. After the throw and waiting, one initial
setup supplies Mario FREEFALL ten units above the shell, retaining Box49,
speed0/yaw0/velocity `(0,-16,0)`, target Box HOLP
`(-2102.720703125,1920,-1119.5618896484375)`, and the same initially free
native released91 Bob profile/compensated position as `check.py`. Fresh Z on
128 invokes native shell contact, Box drop and slide cancellation. Only
controller inputs follow; A remains released. This still does not establish
Mario's approach, hands-free acquisition or Bob delivery.

The native drop uses Mario's movement Y, not HOLP Y. Its later callback may
raise the actor to the selected floor. All numbered updates below use the
top timer at the **start** of the update.

| Actual shell Y | Initial Mario Y |128 action result|First failure in this fixture|
|---:|---:|---|---|
|1800,1840,1860,1880|1810,1850,1870,1890|BUTT_SLIDE, M.Y1809.206665|Box is raised to1920.549561, then lands/deletes129, missing130 final shove. Each gets ordinary Area2.|
|1900|1910|BUTT_SLIDE_AIR|First ground quarter finds floor1802.127075, more than100 below; air transition changes trajectory. Box also deletes129;130 floor1919.146851.|
|1920|1930|BUTT_SLIDE_AIR|Box survives until the130 collision pass and deletes in130 callback, but Mario remains airborne away from the needed shove;130 floor1898.477173.|
|1940,1960,1980,2010|1950,1970,1990,2020|BUTT_SLIDE_AIR|Box survives through130, but the same air transition/trajectory leaves130 floor1898.477173 and no final Box contact.|
|19900|19910|BUTT_SLIDE|Ceiling stop allows ground-slide alignment, but the Box drops at rawY19910, far above the later Mario position;130 floor1861.134399 and no capture.|
|24990|25000|GROUND_BONK|First result has floor1280 and M.Y1280/G.Y25000; Box stays at rawY25000, out of contact.|

The1920 case settles the immediate lifetime idea: a higher drop can keep the
Box available for130, but it does not by itself preserve the low-case Mario
trajectory. At128, Mario remains atY1930 while the floor query gives
1802.127075. At129 he is still BUTT_SLIDE_AIR at
`(-1945.62939453125,1930,-1136.9793701171875)`. At130 the collision list has no
Box49 and his movementY is1926; the required cache768 is absent.

The four low cases reach ordinary `(0,5500,256)`. The other eight remain in
Area1 through45 updates. Deletion and slot identity are recorded separately;
particles later reusing slot49 are not treated as the original Box. No new
original-ROM replay or Coq claim is made for this retune.

```powershell
& build/wafel-pilot/python/python.exe instrumentation/ink-shell-handsfree-placement/retune.py --verify
& build/wafel-pilot/python/python.exe instrumentation/ink-shell-handsfree-placement/analyze-retune.py --verify
```

The exact shell throw HOLP, shell pickup preparation grants, all initial
carrying/profile/HOLP edits, native wait inputs, full M/C/G and actor/cache/
platform/collision traces are in `retune-results.json.gz`. Source/runtime
revisions are the same as this packet's `README.md`.
