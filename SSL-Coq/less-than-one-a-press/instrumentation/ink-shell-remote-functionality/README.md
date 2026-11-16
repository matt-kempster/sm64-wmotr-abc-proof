# Remote shell release retains functionality at the tested coordinates

**An initialized above-water shell survives a native remote HOLP throw and
still mounts. Fresh Z can execute the ordinary ground-slide code.** A direct
native throw to the current Y1800 shell target also completes the useful
Y1810 Ink handoff with no subsequent shell position edit. Pusher placements,
the high/low Mario approach and shell-acquisition grants remain separate.
This packet is twice-reconstructed JP Wafel evidence, not a continuous route
or an assertion that every raw coordinate supports a usable ground slide.
The parent's original-ROM follow-up has its own scope and receipts.

## Three actual pickup/initialization schedules

`check.py` reuses the existing native pending-small-box pickup history in
`ink-shell-delivery/pending_slot.py`, including its accepted debug-level-select
bootstrap and one shell-box contents-action grant. Mario's selected pointer,
held pointer, allocation, hitbox and interaction type are never assigned.
The first900 inputs actually carry small box23; Mario drops it, waits for its
native expiry and starts another real pickup at released-counter897. The
existing shell box32 is granted action4 on the selected B-relative update.

| Spawn update after B | State before the new remote throw | What real release does |
|---|---|---|
|5|Native shell initializes before pickup; carry3 BREAK freezes it with type524288, intangible0, radius/height50/50.|B throw changes the script to carry5 BREAK; initialized shell fields survive.|
|6|Pickup freezes the newly allocated shell before its first native callback; type0, intangible−1, radius50/height100.|Remote release does not initialize or repair it; it remains intangible and cannot mount.|
|7|Pickup has already grabbed the vacant slot; subsequent native shell allocation initializes and leaves the ordinary shell callback live while Mario retains the slot reference.|The shell moves during throw preparation, but the actual throw redirects it to carry5 BREAK and places it at HOLP.|

The third case is a real native shell that is still running before release,
not a manufactured interaction profile. At the selected start it is around
`(5784.981,614,2493.712)`; six further updates move it to
`(5768.211,698,2491.796)`. Throw update7 then places it remotely and freezes
its native callback. It is not evidence that Mario can ordinarily grab an
above-water shell with B: this non-HOLDABLE actor uses the pending-slot
mechanism. Nor is it a shell that keeps running normal behavior after throwing.

## Remote throws and contact controls

For each of those three reached conditional pickup states, six branches press
B once and run24 updates. Immediately before throw update7, the test supplies
only HOLP. It subtracts the native32-unit yaw offset using the runtime sine
table, with binary32 rounding, so the native throw arrives at the target.
No shell XYZ, script, status, hitbox, type, tangibility, velocity or floor is
edited during or after the throw. The exact targets below all reproduce.

After the24 release updates, a separate supplied Mario FREEFALL pose is placed
ten units above the actual released shell, with speed0, velocity `(0,-16,0)`
and yaw0. Each position gets a four-update no-Z control and a fresh-Z control.
A is released throughout. The local terrain/top state is the pending-pickup
prefix's untriggered top, not the later spinning phase of the Ink positive.

| Released shell XYZ | First native mount without Z | Fresh Z on mount update, initialized cases |
|---|---|---|
|`(-1962.4404296875,1800,-1243.34130859375)`|RIDING_SHELL_GROUND is entered, then RIDING_SHELL_FALL.|BUTT_SLIDE executes, then BUTT_SLIDE_AIR at this different floor/phase.|
|`(-1950,24990,-939)`|Ground riding is entered, then BACKWARD_GROUND_KB.|BUTT_SLIDE executes; final GROUND_BONK with M.Y768/G.Y25000.|
|`(-1950,67267,-939)`|Ground riding is entered, then BACKWARD_GROUND_KB.|BUTT_SLIDE executes; final GROUND_BONK with M.Y768/G.Y67277.|
|`(63586,24990,-939)` (+65536 X)|Same mount/bonk sequence.|Slide executes; M retains actual X63586, with Y768/G.Y25000.|
|`(-67486,24990,-939)` (−65536 X)|Same mount/bonk sequence.|Slide executes; M retains actual X−67486, with Y768/G.Y25000.|
|`(-1950,-40746,-939)` (24800−65536 Mario Y)|Mount transition occurs, then WATER_PLUNGE; M.Y becomes−11100.|Water transition interrupts before ground slide execution, despite accepted shell contact.|

Initialized spawn5 and spawn7 give the same listed action classes. Both keep
the50×50 tangible shell and all24 tested first contacts include shell23 and
enter RIDING_SHELL_GROUND. The negative-VPU cases demonstrate why mountability
alone does not establish slide viability at arbitrary Y. The horizontal-PU
cases demonstrate shell functionality, not a warp handoff: Mario's raw X
remains in that PU and the real warp has not moved there. No complete arrival
is claimed for these short isolation controls.

All12 spawn6 contacts fail: the released object never enters Mario's collision
list, never mounts, and Z produces the ordinary airborne ground-pound response
(or the negative-height water transition). A remote throw does not fix an
uninitialized shell. Its behavior name alone is insufficient.

Three additional high-HOLP Z-drop controls use targetHOLP `(-1950,67267,-939)`.
They actually leave the shell at `(-1950,0,-939)`: native drop uses Mario's
current movement Y, whereas throw uses HOLP Y. They settle at carry4 BREAK.

Coverage is21 actual releases and36 four-update contacts,648 release/contact
boundaries, each independently reconstructed twice. Prefix/acquisition
observations are retained separately. This is a finite point menu, not a
continuous height interval, a float-unbounded positioning theorem, or a global
maximum/minimum result.

## Native throw directly to the useful Ink setup

`handoff.py` instead reuses the four-pillar conditional shell root. It retains
the existing shell-box spawn grant, low pickup preparation and one supplied
`usedObj` retarget. The actual pickup creates the holding/carry state. A native
B throw supplies the destination from HOLP before throw update7. The low
target is:

* HOLP `(-1962.4404296875,1800,-1275.34130859375)` with yaw0.
* Native shell release `(-1962.4404296875,1800,-1243.34130859375)`.

The native release is observed at stored top timer25. The shell stays at that actual released
position through the remainder of the24-update throw continuation and86
neutral waiting updates, until the stored top timer reaches128. There is
**no later shell position write**. At128, the test supplies only the native
released91 Bob profile, Bob/Box XYZ and Mario's existing1810 FREEFALL pose.
Z128 then mounts/cancels; Bob129 and Box130 yield fresh768, a1071.447266 G/M
gap, warp acceptance, top capture/retention and exact useful spawn
`(365.5927734375,5500,-1096.8026123046875)`.

The second positive uses HOLP `(-1960,19890,-1262)`, native shell release
`(-1960,19890,-1230)` and the older supplied19900 Mario start. It also reaches
the exact useful spawn. The low-entry control omits only the Box placement,
leaving that actor at its ordinary location; it arrives at ordinary
`(0,5500,256)` with no top capture. All three27-update continuations match
fresh reconstruction. The later actor/Mario grants remain explicit, so this
does not join real shell delivery with real pusher delivery or Mario entry.

The native-replay exports `low-positive.json`, `high-positive.json` and
`no-box.json` have seedPhase128, initialEdits without any shell field, empty
later cuts, controls and all expected boundaries. `shellPreparationHOLP`
specifies the one replacement for the inherited preparation's throw-time
HOLP. Reusing the old fixed HOLP and merely omitting the final shell cut would
be the wrong experiment. The record retains the earlier pickup-preparation
shell XYZ grant separately; "no later shell write" begins at the native throw,
not at level entry.

M is movement, C collision-object position and G stored `gfx.pos`, not the
rendered model. The actor status and action transitions are observed directly;
undecoded event placeholders are not interpreted as step-return values.

## Reproduce and limits

From `SSL-Coq/less-than-one-a-press`:

```powershell
& build/wafel-pilot/python/python.exe instrumentation/ink-shell-remote-functionality/check.py --verify
& build/wafel-pilot/python/python.exe instrumentation/ink-shell-remote-functionality/handoff.py --verify
& build/wafel-pilot/python/python.exe instrumentation/ink-shell-remote-functionality/archive.py --verify
```

Starting proof revision `4adf8faf311d1d271c57f288f51b06bf357874d1`, applicable
JP source pin `9921382a68bb0c865e5e45eb594d9c64db59b1af`, local decompile
`36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`, Wafel0.8.5/Python3.9.13, DLL SHA256
`960fe979068b78e6733b3ddb87741833fbf4eb29b2a21a2bba871977427c2d0f`.
Native source and predecessor input dependencies are pinned in the archive.
No new Coq theorem, ROM binary or conversation export is included. Legal
roof-box activation, the pending-slot join, reaching the HOLP, approaching
above the released shell and coordinating the pushers/top remain separate
gameplay questions. The source/distance study answers ordinary inactivity;
this packet tests actual remote release and subsequent shell functionality.
