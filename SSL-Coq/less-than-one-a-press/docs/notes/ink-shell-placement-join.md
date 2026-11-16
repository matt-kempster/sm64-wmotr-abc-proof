# Joining the shell throw and Mario's pusher releases

15 November 2026. **The complete placement history without later position
edits remains open. A smaller useful join works: Mario can carry the enlarged
Bob-omb into shell contact, release it through the shell interaction, mount,
cancel with fresh Z, and reach the useful displaced spawn without any further
state edits. Original JP confirms this useful continuation.** The shell was actually thrown remotely earlier, and Mario's
actual Crazy Box drop precedes this approach. However, the Box carrying setup
and the later held-Bob approach are still separate supplied states. This is
not the requested continuous history in which Mario places all three actors.

## What has actually been joined

The older release witness used three cuts after the remote shell throw:
Box carrying state126, Bob carrying state127, then Mario-only FREEFALL128.
Simply combining its scripts with the remote throw succeeds, but retains
all three cuts. Removing the last Mario relocation leaves him far away:
after the actual Bob drop he is at `(5900,1809.206665,3417)`, and Z128 starts
ground pound rather than mounting the shell. The finite47-update control
does not capture the top or reach Area2. That composition is preserved as a
compatibility control, not relabeled as the requested route.

The stronger continuation removes the separately supplied Bob release127
and the post-release Mario relocation. Its selected schedule is:

Handoff update numbers126–131 name the top timer at the start of the update.
The saved post-update `topPhase`/`topTimer` is one higher: mount128 ends129,
and capture131 ends132. The earlier shell-release timer25 below is instead
the observed post-release timer, explicitly labeled as such.

| Update | Supplied preparation or actual execution | Result |
|---|---|---|
|Release observed at timer25|Existing conditional shell pickup, then real throw using supplied HOLP `(-1962.4404296875,1800,-1275.34130859375)` and yaw0|Shell71 is released at `(-1962.4404296875,1800,-1243.34130859375)`; no later shell XYZ write.|
|After throw through125|Native neutral continuation|The initialized frozen shell stays parked.|
|Before126|Supply Mario HOLD_FREEFALL at `(5900,1920,3440)`, held Crazy Box49 and its remote HOLP|This is a carrying/position grant after the shell throw, not a reached pickup.|
|126|Actual Z drop|The Box becomes free/action1 at `(-2102.720703125,1933.43212890625,-1119.5618896484375)`. No later Box field write.|
|127|Neutral|Mario remains in the drop's ground-pound continuation; the remote Box remains parked.|
|Before128|Supply Mario HOLD_FREEFALL at `(-1962.4404296875,1810,-1243.34130859375)`, velocity `(0,-16,0)`, speed0, holding the native-derived radius91 Bob39; HOLP X/Z `(-2080.06005859375,-1230.322021484375)`|Last supplied approach/carrying state. The selected positive clears, rather than supplies, the expired-drop status bit.|
|128|Fresh Z; shell interaction drops the held Bob before assigning RIDING_SHELL_GROUND; Z cancels into the ground slide|BUTT_SLIDE at M=C=G `(-1960,1809.206665,-1230)`, cache1809.206665 and platform61. Bob's native release callback raises its origin toY1867.130615.|
|129|Neutral; Bob shove|M=C `(-2117.026855,1839.447266,-1113.008545)`, G.Y1809.206665, cache1839.447266 and no platform.|
|130|Neutral; fresh low floor query, then Box shove|M=C `(-2200.001709,768,-1075.003906)`, G.Y1839.447266, cache768, gap1071.447266. The Box then deletes in its own callback.|
|131 onward|Neutral|The real warp is accepted, top61 is captured and retained, and Area2 arrival is `(365.5927734375,5500,-1096.8026123046875)`.|

Every controller update keeps A released. There is no held-A dependency.
After the supplied held-Bob approach, only controller fields are written.
The Bob is not placed at its final shove origin by an editor: the game's
drop helper writes its release position. Its radius91/held scalar profile
is transplanted from the separately controller-produced donor. Acquiring
that same Bob and carrying it here remains unjoined.

M means Movement, C Collision and G Stored Graphics (`gfx.pos`), not rendered
pose. The preserved traces contain all three coordinates, action changes,
floor/cache, collisions, actor state, top phase and platform observations.

## Why the new Bob join works

In the applicable JP `interact_koopa_shell`, accepted above-contact sets the
interaction/used/ridden references, invokes `mario_drop_held_object`, then
enters RIDING_SHELL_GROUND. Thus the held item is released before that ground
action executes. Fresh Z in the ground-riding handler can then select the
common crouch-slide path in the same update. The shell ends the interaction
pass; the Bob's intended shove is on the next update, not a second push in
the mounting pass.

The earlier high-Y carrying shortcut failed because dropping uses Mario's
actual movement Y, not HOLP Y. At MarioY19900 that released the pusher far
above the useful contact. At the corrected1810 approach, the same ordering
can be useful. This does not make the source claim about high drops false;
it supplies a different concrete geometry.

## What still prevents claiming the full requested history

The first missing join is already after the shell throw: the selected
native throw/wait history leaves Mario low near the remote carrier position,
not holding the Crazy Box at Y1920. The next missing join is Box release to
the held-Bob approach. The test explicitly changes Mario's position and
holding state at128; it does not derive them from the Box drop126.

The exact old two-update timetable cannot simply retain Mario's action.
Z from HOLD_FREEFALL invokes drop-and-ground-pound. The next neutral update
does not enter a pickup action. The actual grab guard requires dive,
dive-slide, or the appropriate early punching state; ground pound is not
one. Descending ground-pound contact also has a different attack
classification from the ordinary above-contact shell mount. This closes
that immediate substitution, not all no-A release/approach histories.

The Box's wake-up timing is another concrete constraint. The native distance
wrapper uses raw Mario collision coordinates and its4000-unit threshold,
with the FAR_AWAY flag updated after the callback. In this recipe the freshly
dropped Box is still parked on127, clears FAR_AWAY on128, first moves on129,
then collides with Mario before its own landing/deletion on130. A nearby
carrier in the older control wakes it sooner and loses it on129. Merely
walking toward the parked actor cannot be assumed to reproduce the selected
last-moment wake-up. An earlier wake and a different release trajectory are
not excluded.

The next useful experiment is a different Crazy Box release/approach
schedule, with an actual Bob pickup between release and shell contact.
In particular, B from HOLD_FREEFALL can enter AIR_THROW, whose fourth update
throws through HOLP without forcing ground pound. However, AIR_THROW does
not automatically become FREEFALL and has no B/Z cancel or grab check. Under
the premise of no landing or other action-changing interruption, pressing
B/Z after that throw cannot make Mario grab the Bob. A genuine action exit
is another requirement, not a detail that can be omitted.

A source-supported candidate uses an earlier shell mount/cancel to escape
AIR_THROW, then a real action exit and Bob grab, followed by a return to the
same reusable frozen shell. A crouch-slide that actually leaves ground can
become FREEFALL, allowing later B to enter DIVE and a later Bob overlap to
grab. This is not an immediate Z-then-B shortcut: at the selected geometry
the action instead becomes BUTT_SLIDE, which ignores B; fast crouch-slide B
produces SLIDE_KICK. A returning held-Bob DIVE must also have forward speed
strictly between-26 and26 for the ordinary above-contact shell classifier.
The alternative is a genuine landing/recovery and ordinary pickup. None of
these longer acquisition paths is established by the successful final join.
They must preserve the live Box until the final shove and recover the shell
phase without changing Mario's position afterward.

## A stricter single-start placement search

The additional [single-start packet](../../instrumentation/ink-shell-single-placement-start/README.md)
tests whether Mario can release the Crazy Box and approach the shell without
another position, holding-state or HOLP edit. After the actual remote shell
throw, one initial setup supplies Mario holding the Box near the shell, a
native-derived already-free radius91 Bob at the compensated useful position,
and the intended Box-release HOLP. Only controller inputs follow. Thus even
a positive would still grant Bob delivery and the initial carrying state;
this is a narrower test of removing the post-Box-release Mario relocation.

There are215 distinct cases, each reconstructed twice, with9639 observed
suffix boundaries per reconstruction. They use starting phases120–126,
speed0, vertical velocity-16/-32, regular Y1850–2090 and selected fall-timed
points (overall Y1836–2090), B air throw or Z drop, then fresh Z128. None
captures the top or reaches the useful spawn. Two reach ordinary Area2.
This is finite coverage of fixed X/Z, actor profiles and controls, not a
general impossibility result.

Of117 B-input cases,73 execute the actual throw and44 instead have shell
contact interrupt AIR_THROW and drop the Box. Those44 mount on the release
update. All101 B cases still holding after their first update already
overwrite the initial remote HOLP, and all73 actual throws use changed HOLP.
For example, phase120/Y1930/velocity-16 starts with HOLP
`(-2102.720703125,1920,-1151.5618896484375)`. Before throw123 it has become
approximately `(-1943.832520,1962.531494,-1294.094238)`; the native throw's
post-update Box origin is approximately
`(-1943.832520,1978.531494,-1262.094238)`. Neither the initial remote HOLP nor
the desired release point survives this wind-up. The earlier successful
remote-shell experiment instead supplies HOLP immediately before its throw
call. The two preparation conditions must not be conflated.

This gives another concrete prerequisite for a longer route: establish the
needed HOLP at the actual release time, accounting for held-object rendering
during the wind-up. A camera/visibility history that preserves a useful HOLP
is a candidate to investigate, not a demonstrated fix here. It still must
join the actual Bob pickup/action exit and the live Box's timing.

## Evidence, scope and revisions

The new Wafel packets separately preserve the older three-cut composition
and the stronger held-Bob contact join. Positive tests require the exact
useful Area2 spawn, top capture and observed retention; an ordinary warp is
not accepted as success. The omitted-Box control reaches `(0,5500,256)`.
Finite test coverage and original-JP validation are recorded in the packets
below; no continuous height interval or global route exclusion is claimed.

The held-Bob menu contains65 cases, each independently reconstructed twice:
24 useful positives at the discrete Mario starting heights1810,1830,1850,
Box release heights1920,1940,1980,2010, and each of forced-drop status0/8,
all using the128 approach. The other40 cases stay in Area1 for the tested
suffix; the final omitted-Box control reaches ordinary Area2. A separate
36-case earlier127 approach menu finds no capture. The missing-approach and
missing-fresh-Z controls distinguish the unreached entry from the action
transition needed on contact. These are finite supplied-state checks, not
proofs that the successful points form an interval.

Two fresh original-JP runs validate the stronger carried-Bob positive and
omitted-Box control. Each compares27 handoff boundaries and2052 components.
The positive has31 recorded differences (27 known clock offsets and4 Box
subtypes); the control has54 (27 clocks and27 subtypes). All other selected
fields agree. The clock convention is native+2=Wafel; Box subtype2 versus0
is DELAY_INVINCIBILITY, not read by the selected neutral push, with its origin
still unestablished. Each run lacks two transition camera samples. Neither
result is whole-memory equivalence.

Native checks observe the held Bob before128, HOLD_FREEFALL and a cleared
forced-drop status, then cleared held/ridden references and STOP_RIDING after
mount/cancel. Each run retains102 fixed, tangible-shell observations after
the native throw. The positive records709 floor returns, fresh768 on130,
top capture131, observed retention, and the exact useful spawn. The control
records710 floor returns and ordinary arrival without capture. Their125/120
scalar setup writes include inherited preparation and both later carrying
cuts; no shell XYZ write follows the throw, no Box field write follows126,
and no Mario or actor setup write follows the128 carried approach.

The inherited Wafel roots share a temporary prefix filename. One parallel
verification attempt failed its four-pillar root precondition before the
tested suffix. Sequential verification subsequently passed against the
unchanged retained artifacts; that failed root is not counted as evidence.
Reproduction instructions require the Wafel root scripts to run sequentially.

- [Three-cut composition and missing-entry control](../../instrumentation/ink-shell-three-releases/README.md).
- [Held-Bob approach and native drop on shell contact](../../instrumentation/ink-shell-carried-bob-mount/README.md).
- [Original-JP carried-Bob positive and omitted-Box control](../../instrumentation/jp-ink-shell-three-releases/README.md).

Work started at pushed `ea1a4994f5157636f481723a89c6411a53e6e6d4`, verified
against the branch before extending it. Applicable JP source pin:
`9921382a68bb0c865e5e45eb594d9c64db59b1af`; local decompile revision:
`36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`. Wafel0.8.5/Python3.9.13 DLL SHA256:
`960fe979068b78e6733b3ddb87741833fbf4eb29b2a21a2bba871977427c2d0f`.
The native runs use Ubuntu-24.04, Mupen64Plus/Rice/RSP-HLE2.5.9,
interpreter mode0 and original JP ROM SHA256
`9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317`.

No new Coq statement or proof build is claimed. These runtime joins reduce
the disclosed setup requirements of a conditional witness; they do not
prove acquisition or reachability. All45 subjective estimates stay unchanged,
including Rank1 **1–2%** and Ink Rank2 **<1%**. The complete no-new-A route,
including all three deliveries and Mario's intervening travel, remains open.
