# Actual Crazy Box drop: conditional compatibility succeeds

**A native drop can replace the preplaced action0 Crazy Box.** From explicitly
supplied carrying/HOLP states, Z makes Mario release the box through the real
game helper. Its native dropped action1 remains alive until the useful contact
and the handoff reaches `(365.5927734375,5500,-1096.8026123046875)` in Area2.
For the main example the box breaks later in the same update as its shove;
that deletion does not undo the completed shove.

This answers release compatibility, not actual delivery. The neighboring
[`box`](../box/) package separately reconstructs controller-only pickup and
release attempts, which do not reach the useful setup. This packet explicitly
grants a held pointer and HOLP, a high carrying pose, the shell preparation,
an enlarged-Bob profile and Bob position, and a later airborne Mario cut.

## Exact experiment

Load the existing conditional frozen-shell root at spinning-top phase126.
Install the documented native released91 Bob donor profile, place Bob39 at
`(-2080.06005859375,1809.2066650390625,-1230.322021484375)`, and place the
initialized frozen shell71 at `(-1960,19890,-1230)`. These are grants.

Supply Mario's M/C/G=`(5900,Y,3440)`, HOLD_FREEFALL, action state/timer/arg0,
velocity `(0,-16,0)`, forward speed0 and yaw0. Supply `heldObj=box49`, the
native box's held-state field as HELD_HELD, and HOLP
`(-2102.720703125,Y,-1119.5618896484375)`. This distant stored hand position
is deliberately supplied; the test does not explain how actual holding
could preserve it. The box retains its native behavior, collision type,
hitbox and callback. No released action, free XYZ, release velocity or
lifetime is written directly.

1. Z126 executes HOLD_FREEFALL's real drop-and-ground-pound branch. The
   native Mario drop helper places the box using HOLP X/Z and Mario's
   pre-action movement Y. The native box callback consumes HELD_DROPPED,
   becomes tangible/free and selects action1.
2. Neutral127 releases Z. Mario remains in the supplied remote region;
   the box has the native FAR_AWAY flag and does not move normally yet.
3. Before128, make a **Mario-only** cut to the existing FREEFALL seed
   `(-1960,19900,-1230)`. Z128 mounts/cancels the shell; all later inputs
   are neutral. No actor field is edited after the actual drop126.

The original shell fake-pickup/high-HOLP preparation and all donor profile
writes are preserved under `results.preparation`. Each trial preserves its
carrying grants, actual release, wait, subsequent Mario-only cut, controls,
full boundary observations and restored cache-diagnostic fork. The fork
is not part of the actual history. A remains released throughout.

## Results: eight sampled release heights, not a continuous window

| Supplied movement Y before Z126 | Actual free box Y after native drop callback | Box contact130 | Capture/useful spawn |
|---:|---:|---|---|
|1600|1600|No: too low|No; ordinary `(0,5500,256)` |
|1799|1933.43212890625|Yes|Yes|
|1870|1933.43212890625|Yes|Yes|
|1920|1933.43212890625|Yes|Yes|
|1950|1950|Yes|Yes|
|2010|2010|Yes|Yes|
|2013|2013|Yes|Yes|
|2014|2014|No: too high|No; ordinary `(0,5500,256)` |

The upward correction in the middle rows is native, not an additional
placement. `cur_obj_move_after_thrown_or_dropped` checks a floor at item
Y+160 and raises the item if that floor is above its current position.
The selected phase126 top floor is1933.43212890625 at this X/Z.

The main Y1920 example has the following native sequence:

| Completed top update | Mario movement Y / G Y | Box Y / active flags | Meaning |
|---:|---|---|---|
|126|1940 /1940|1933.432129 /259|Native drop; remote Mario's ground-pound startup rises20; box is free action1|
|127|1958 /1958|1933.432129 /259|Neutral wait, remote Mario; box remains FAR_AWAY|
|128|1809.206665 /19900|1933.432129 /257|Native shell/Z slide entry; box activation flag clears after its callback|
|129|1839.447266 /1809.206665|1929.432129 /257|Bob supplies the first shove; box has begun falling|
|130|768 /1839.447266|1923.485229 /0|Box supplies the final shove, then lands and deletes in its later native callback|
|131|1914.854980 /1914.854980|Same old slot contents, inactive|Warp accepted, top61 captured; inactive slot is not a surviving box|

All six positives refresh the initial130 cache to768, capture/retain top61,
and reach the exact useful spawn after27 updates from the air cut (29 from
the carrying cut). Both negatives still refresh768 and create the vertical
gap, but lack the final Crazy Box registration and take the ordinary warp.
The live Bob remains present and can still shove; these are not no-pusher
controls.

The high pair explains its first failure precisely. For supplied2013, the
box is at2009 before130; its hitbox bottom1999 overlaps Mario's collision
top1999.447265625. At2014, its bottom is2000 and the collision list contains
only Bob39 rather than `[49,39]`. These are two actual sampled points with
a source-consistent contact explanation, not a proved global bound.

G means stored graphics `gfx.pos`, not the position visibly drawn by the
renderer. The source's release behavior and subsequent callback order are
used directly; no simplified action1 simulation replaces them.

## Reproduce and limits

From `SSL-Coq/less-than-one-a-press`:

```powershell
& './build/wafel-pilot/python/python.exe' 'instrumentation/ink-mario-pusher-delivery/controlled-box/check.py' --verify
& './build/wafel-pilot/python/python.exe' 'instrumentation/ink-mario-pusher-delivery/controlled-box/check.py' --edges --verify
& './build/wafel-pilot/python/python.exe' 'instrumentation/ink-mario-pusher-delivery/controlled-box/export.py' --verify
& './build/wafel-pilot/python/python.exe' 'instrumentation/ink-mario-pusher-delivery/controlled-box/archive.py' --verify
```

Each menu was rebuilt from two independent Wafel roots and compared exactly
for saved values. Runtime: Wafel0.8.5/Python3.9.13, JP DLL SHA256
`960fe979068b78e6733b3ddb87741833fbf4eb29b2a21a2bba871977427c2d0f`.
Applicable JP source pin is`9921382a68bb0c865e5e45eb594d9c64db59b1af`;
the initial proof checkout was`0605d842cedb55151e70952d56064553c4970f60`.
This packet itself adds no original-ROM replay or Coq theorem. Exported
cases are ready for a separately reported native replay.

This resolves the narrow action0/action1 compatibility question. It does
not show a real pickup at the required location, a reached HOLP or carrying
pose, joint Bob/shell delivery, or the later airborne Mario approach. A
different approach that activates the box earlier can change its landing
and deletion timing. Throwing is not tested in this packet.
