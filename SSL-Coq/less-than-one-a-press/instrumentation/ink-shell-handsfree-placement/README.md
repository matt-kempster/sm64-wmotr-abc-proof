# Hands-free action holding does not preserve HOLP in these rendered tests

15 November 2026. The user's hands-free suggestion is tested directly:
Mario is supplied in ordinary FREEFALL, DIVE or BUTT_SLIDE_AIR while his held
reference remains Crazy Box49. HOLD_FREEFALL is the ordinary-carry control.
No grab-position, hand, rendering flag or per-update HOLP lock is supplied.
**All24 tested states that retain the Box through the first update overwrite
the initial remote HOLP.** Merely retaining a held reference in an ordinary
action does not freeze HOLP in these trajectories.

These are supplied action/holding diagnostic states, not newly reached
hands-free acquisitions. The prior actual hands-free dive-pickup/slide route
is credited in `docs/notes/ink-box-handsfree.md` and the clean follow-up. That
route is not spliced into this high setup. A shell at the desired position is
provided by the actual remote throw used in the preceding evidence; a native
released91 Bob profile and its compensated initial position are supplied.

## Source explanation and scope

`geo_switch_mario_hand_grab_pos` in `src/game/mario_misc.c` selects the held
object whenever Mario's held reference is nonnull; it does not require a
normal carrying action. Fist and open-hand geometry both contain a
`GEO_HELD_OBJECT` node. `geo_process_held_object` in
`src/game/rendering_graph_node.c` invokes `GEO_CONTEXT_HELD_OBJ` when the held
node has a nonnull object/model; that callback writes HOLP from the current
transform. Grab position changes the local translation, not whether ordinary
hands-free actions universally freeze HOLP.

This differs from an orphan actor that remains HELD_HELD after Mario's held
reference has become null. Such an actor is not supplied in this packet;
shell contact could not drop it through Mario's null held reference without
another acquisition step. Camera culling, pause-buffered invisible frames,
other geometry branches and changed trajectories are separate hypotheses.
The tests do not establish a global impossibility of HOLP preservation.

## Menu and concrete observations

The six `(start-of-update top phase, Mario Y)` pairs are
`(128,1810),(127,1830),(126,1850),(124,1890),(120,1930),(124,1970)`.
Each uses the shell X/Z `(-1962.4404296875,-1243.34130859375)`, speed0/yaw0,
velocity `(0,-16,0)`, each of the four actions above, and either neutral or B
first. Fresh Z is pressed at128, overriding the requested first B for cases
starting128. Thus48 requested cases contain44 distinct initial-edit/control
histories; the four first-input pairs at128 intentionally coincide. Each is
reconstructed twice from independent roots, totaling2016 suffix boundaries
per reconstruction. No A is pressed or held.

Initial HOLP is `(-2102.720703125,1920,-1119.5618896484375)` and initial Bob is
`(-2079.9365234375,1809.2066650390625,-1233.3045654296875)` with the exact native
free91 donor fields. After that one initial setup there are only controller
writes. No Box release endpoint, later Mario position, body grab pose or
rendering state is edited.

For phase124/Y1890 and neutral first, ordinary FREEFALL still holds Box49
after its first update, but HOLP changes from the requested remote value to
`(-1995.11962890625,1963.7677001953125,-1208.8822021484375)`. DIVE and
BUTT_SLIDE_AIR also overwrite it on their first update, as do HOLD_FREEFALL
controls. All24 delayed-first-contact cases behave this way. The body grab
position remains inherited LIGHT_OBJ=1; hand state is ordinary FISTS=0.
Those fields are observed rather than forced.

Of48 cases,45 actually drop the Box,2 actually throw it, and1 still holds it
through the45-update horizon. Actual throws are identified from the native
Box callback's forward speed40, rather than assuming B implies a throw.
No case captures the top or produces useful displacement. Eight phase128
cases (four distinct initial histories) arrive at ordinary `(0,5500,256)`;
the other40 remain in Area1 through45 updates.

## A same-update release avoids the HOLP overwrite but fails later

At128/Y1810, shell contact happens before another held-object render, so the
initial remote HOLP is still usable. This occurs for the ordinary-carry
control too; it does not demonstrate hands-free HOLP freezing. Native shell
contact drops the Box, and fresh Z creates BUTT_SLIDE with no further edits.

| Update start timer | Observed result |
|---|---|
|128|Mario becomes `(-1960,1809.2066650390625,-1230)`, BUTT_SLIDE. Native Box drop/callback yields `(-2102.720703125,1920.549560546875,-1119.5618896484375)`, active257.|
|129|Bob nudges Mario to `(-2117.02685546875,1839.447265625,-1113.008544921875)`. Box lands atY1925.161255 with OBJ_MOVE_LANDED=1 and deletes in its action1 callback.|
|130|Fresh cache768 and G.Y1839.447266 are obtained, but there is no surviving Box for the final shove.|
|131 onward|Real warp is accepted without top capture; ordinary Area2 arrival follows.|

Box slot49 is reused for particles after deletion; identity and active flags
are preserved, and those particles are not counted as the surviving Box.
The first remaining failure in this same-update candidate is Box deletion
one update before the required130 shove, rather than HOLP preservation.

## Reproduce

From the SSL directory:

```powershell
& build/wafel-pilot/python/python.exe instrumentation/ink-shell-handsfree-placement/check.py --verify
& build/wafel-pilot/python/python.exe instrumentation/ink-shell-handsfree-placement/analyze.py --verify
```

The runtime script verifies the full48-case archive against two fresh
reconstructions. Analysis rechecks first-update HOLP changes, actual release
kinds, same-update Box deletion, arrivals, duplicate policies and source/
artifact hashes. No original-ROM replay or Coq theorem is added for this menu.

Applicable JP source pin `9921382a68bb0c865e5e45eb594d9c64db59b1af`; local
decompile `36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`. Wafel0.8.5/Python3.9.13
DLL SHA256 `960fe979068b78e6733b3ddb87741833fbf4eb29b2a21a2bba871977427c2d0f`.
M is Movement, C Collision, G Stored Graphics (`gfx.pos`), not rendered pose.
