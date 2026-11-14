# Can Mario place both pushers before mounting the shell?

**Both native drops can work, and the shell entry can be lowered to Y=1810.
A continuous pickup-and-delivery route remains open.** The earlier
preplacement replay used editor writes, not Mario placing the items. The new
controlled tests instead invoke Mario's actual drop actions and the actors'
native callbacks, then complete useful displacement with no later item edits.
They still supply the carrying states, held references, HOLP, shell preparation
and Mario's later airborne entry. The user authorized this diagnostic track
alongside actual controller pickup-and-delivery histories; the two evidence
levels are kept separate.

## What height needs to be reached?

The old shell recipe started Mario in supplied FREEFALL at Y=19900, over a
shell at Y=19890, while the pushers were nearY1809 and1839. That large altitude
requirement is now unnecessary for the selected conditional recipe: the new
entry is `(-1962.4404296875,1810,-1243.34130859375)`, with Mario's velocity
`(0,-16,0)`, speed0 and Z on update128. The shell is at the same X/Z and Y=1800.

There is still **no verified high approach** to Y=19900, the Y=21778–32767 window,
or a positive vertical universe in these joined no-new-A histories. A high
HOLP is an item-release prerequisite, not an elevator for Mario. Terrain
query aliasing also does not move his actual position, the warp or actors.

The strongest relevant existing actual approach uses a Crazy Box and the
native western Fire Fly Guy: it reaches airborne Mario Y=2099.514893, then
lands on the intact top and enters BUTT_SLIDE at Y=1768. The original JP ROM
confirms that trajectory, with the interaction-subtype differences reported
in its existing receipt. It has only three pillars credited, retains a high
floor cache and has already lost the Crazy Box. It is not the high-shell
approach or a useful Ink handoff.

The announced pivot was to lower the handoff target before inventing a19000-unit
ascent, crediting the older shell/Box/Buddy successes at supplied1810/1830.
It succeeds conditionally for the current Buddy-free recipe. The next route
target is the exact1810 mount geometry and phase, plus the item-release
history. Action still matters: the genuine2099 apex is TWIRLING, whose
descending attack prevents the ordinary above-contact shell mount. The
existing route lands and recovers before reaching the real1768 slide; those
states cannot simply be spliced into the supplied shell fixture.

## Both actual drops, then useful displacement

The controlled joint sequence uses the following disclosed grants:

| Before update | Supplied state | What the native update does |
|---|---|---|
|126|Mario HOLD_FREEFALL at `(5900,1920,3440)`, held Crazy Box49, HOLP `(-2102.720703125,1920,-1119.5618896484375)`; initialized frozen shell placed for the later mount|Z invokes the actual drop. The Box's floor query raises it to Y1933.432129; it is free/action1.|
|127|A separate carrying state at `(5900,1809.206665,3440)`, held/used Bob39, actual held91 donor fields and expired-drop status; HOLP `(-2080.060059,1809.206665,-1230.322021)`|Neutral invokes the forced native drop. Mario's held reference clears; Bob remains in pending HELD_DROPPED until its distance-gated callback runs.|
|128|Mario-only FREEFALL cut at the corrected1810 entry above; no actor edit|Z mounts the shell and creates BUTT_SLIDE.|
|129|No setup writes|Bob supplies the first shove; Mario reaches `(-2117.026855,1839.447266,-1113.008545)` with no platform.|
|130|No setup writes|The initial floor query saves768. The dropped Crazy Box supplies the final shove before its own native deletion. M=C becomes `(-2200.001709,768,-1075.003906)` and G.Y stays1839.447266.|
|131 and later|No setup writes|Real low warp accepted; high-G retry captures/retains the top; exact Area2 spawn `(365.5927734375,5500,-1096.8026123046875)` follows.|

No Crazy Box field is edited after its126 release, and no Bob field after
its127 release. The two granted carrying states are **not** consecutive
states reached by player inputs. Remote HOLP values, the ability to acquire
each hold in that order, the approach from the remote carrier to the shell,
and the top-phase join all remain missing. Z126 also leaves Mario in ground
pound near the remote setup; the later FREEFALL entry is explicitly supplied.

The exact low joint test leaves Bob's HOLP X/Z unchanged. Its pending drop
callback runs on128 and lifts it toY1867.130615, still overlapping for129.
A separate already-free Bob test needs a small initial X/Z compensation,
because its native patrol runs on128 instead. Applying that compensation
to the pending-drop version makes the tested joint sequence take the ordinary
warp. The release state and callback timing therefore matter as well as XYZ.

Two other informative high-entry joint controls fail: omitting the Box release gives ordinary
`(0,5500,256)`; moving the Bob carrier close to the destination wakes the
dropped Box earlier, so it breaks on129 before the needed130 shove. The
successful remote release schedule is not equivalent to Mario casually
placing both items while standing beside them.

The independent Box-only release menu tests eight discrete supplied drop
heights: six useful, two ordinary. Its2013/2014 pair straddles the observed
vertical contact boundary, not a proved continuous height interval. The
separate lower-air menu tests39 complete histories/1431 boundaries, each
twice: the old19900 and compensated1810 cases succeed;16 arrive ordinarily
and21 stay in Area1 through45 updates. The joint low-entry release test is
separate and also independently reproduced twice.

See the [controlled release packet](../../instrumentation/ink-mario-pusher-delivery/controlled-bob/README.md),
[Box release controls](../../instrumentation/ink-mario-pusher-delivery/controlled-box/README.md)
and [lower-entry packet](../../instrumentation/ink-mario-pusher-delivery/lower-approach/README.md).

## Actual Crazy Box pickup and release

The fresh Wafel test reconstructs the accepted first2500 inputs and the
existing western-box approach. From its genuinely reached held-box state,
the original continuation and12 nearby steering policies run100 updates
each. Two fresh roots agree on all1313 observed suffix boundaries. Only
controller writes occur after the inherited debug-level-selection bootstrap;
A remains released. No Mario/actor XYZ, held pointer, HOLP or phase is edited.

Nine histories release a living box through native Fly Guy/enemy contact.
The closest tested living release is
`(-3225.492919921875,1259.514892578125,-1194.014404296875)`: about1125.238
horizontal units from the reference box origin and579.932 units too low.
It is released at branch304 and gone by322. The top is still untriggered
with three pillars credited. These are finite observed misses, not global
height or transport bounds.

Crucially, native release changes the Box to **action1**, which breaks on
landing, wall impact or water. The earlier editor-preplacement positive used
free **action0**, which can bounce on floors; the new controlled release
positive works with action1. HOLD_IDLE and HOLD_WALKING enter CRAZY_BOX_BOUNCE
before ordinary B/Z drop handling, while the supplied HOLD_FREEFALL control
does allow Z to drop. The third
landing destroys it. An interrupting enemy contact really releases it, but
the tested contact is too low and far away. A usable real release may need
to intersect Mario during its short flight rather than park on the ground.

See [the controller packet](../../instrumentation/ink-mario-pusher-delivery/box/README.md)
for all inputs, states, independent replay and archive hashes. This fresh
menu adds Wafel evidence, not a new original-ROM replay.

## The enlarged Bob is not freely throwable on demand

The new24-policy transport menu executes2544 branch updates with14 distinct
realized suffixes. The closest actual Bob remains4056.014 XYZ units from
the target. The preserved905-input history makes16 additional real regrabs,
then enters moving quicksand on input898 and drops the actor; it expires
at905. Maximum held Mario Y in this menu is396.544281. A southern policy
instead loses the actor upon entering a slope-induced butt slide. These
are exact terrain/action failures in finite histories, not an impossibility
proof. The [Bob packet](../../instrumentation/ink-mario-pusher-delivery/bob/README.md)
preserves the inputs, observations and seven twice-reconstructed release
controls.

The existing no-A acquisition/regrab history really obtains the enlarged
radius91 Bob. Its familiar616-input donor is still in pickup recovery.
Neutral continuation releases it at input628 because the expired fuse
requests a forced drop. B or Z at627/628 does not replace that drop with a
chosen throw: the tested origins agree at
`(4558.10791015625,23.010007858276367,4253.400390625)`.

An earlier pickup does allow a real B throw: B at609 releases at615 using
native HOLP, at `(4589.56640625,147.4859619140625,4529.181640625)`, but that
actor still has radius65 and fuse157. The paired Z release is also real,
at Y=35.526939. These source/order controls distinguish an arbitrary-timed
throw from the particular enlarged donor's automatic release; they do not
exclude every enlarged throwing history.

The observed radius91 free release expires seven active callbacks later.
Regrabs can extend its lifetime, and a distant Stored Graphics position can
pause its behavior and fuse. Its action timer still advances while distant.
The two useful pusher origins are only117.029 units apart, so ordinary nearby
placement of the Crazy Box would keep an already-expired Bob active. A
candidate schedule should investigate the short-lived Bob last, or justify
an actual regrab/distance-pausing history.

## One tempting shortcut fails for a precise reason

Carrying a pusher into the exact Y=19900 shell mount does not drop it at the
useful low contact. Shell interaction calls Mario's drop helper **before**
the ground action snaps him down. A drop uses Mario's current movement Y,
so the pusher is released at19900 regardless of a low HOLP Y. The ordinary
drop callback does not snap it down18000 units in the next update.

A throw instead uses HOLP Y and releases on its own animation schedule.
That leaves prior throwing histories open, but requires reaching the actual
HOLP/carrying state and retaining a live actor through the contact timing.
The [source review](../../instrumentation/ink-mario-pusher-delivery/source-review.md)
records the applicable guards and exact scope. This is a source diagnosis
of one named shortcut, not a Coq reachability theorem or global impossibility.

## Evidence and route assessment

Four new original-JP runs confirm the controlled results:

| Native case | Entry Y | Checked boundaries | Outcome |
|---|---:|---:|---|
|Both native drops, supplied carries/HOLP|19900|27|Useful displaced spawn, captured/retained top|
|Same high entry, omit Box release|19900|27|Ordinary `(0,5500,256)`, no top capture|
|Editor-preplaced free actors, corrected entry and Bob X/Z|1810|25|Useful displaced spawn, captured/retained top|
|Both native drops, supplied carries/HOLP, corrected entry|1810|27|Useful displaced spawn, captured/retained top|

All8031 compared components retain143 recorded differences:106 known clock
offsets (`native+2=Wafel`) and37 Crazy Box subtype differences (native2,
Wafel0). The other7888 components agree, including M/C/G, actions, floor/cache,
platform, collision lists and the selected actor fields. Subtype2 is
DELAY_INVINCIBILITY, not read by the neutral butt-slide push; its origin
remains unestablished. Two transition camera boundaries per run are missing.
The exact arrivals and top retention at observed Area1 boundaries are direct
ROM observations; this is not whole-state equivalence. The native hooks
record2811 floor returns across these runs, including the fresh130 cache768.
The write ledgers contain139/134/95/139 scalar setup writes respectively,
including inherited shell preparation. None occurs after the mounting setup;
neither dropped actor is edited after its respective release.

The native [reproduction packet](../../instrumentation/jp-ink-mario-pusher-release/README.md)
preserves recipes, generated probes, raw logs, receipts, all differences,
checks and hashes. It uses Ubuntu-24.04 Mupen64Plus/Rice/RSP-HLE2.5.9 and
original JP ROM SHA256
`9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317`.
An initial low-entry run completed the emulator but its trace-export shell
step failed after the runner was edited during execution; the finalized
runner was rerun successfully in a fresh directory. Only that clean rerun
is included in the four accepted records.

The [editor-preplacement result](ink-preplaced-pushers.md) remains a valid
conditional original-JP positive: fresh768, the high-G/low-M split, accepted
warp, top capture/retention and exact spawn
`(365.5927734375,5500,-1096.8026123046875)`. Its no-final-Box control gets
ordinary `(0,5500,256)` despite a gap. Neither result supplies a player route.

Work starts at proof revision `0605d842cedb55151e70952d56064553c4970f60`,
then equal to the pushed branch. Applicable JP source pin:
`9921382a68bb0c865e5e45eb594d9c64db59b1af`; local decompile:
`36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`. The fresh controller studies use
Wafel0.8.5, Python3.9.13 and JP DLL SHA256
`960fe979068b78e6733b3ddb87741833fbf4eb29b2a21a2bba871977427c2d0f`.
M means Movement, C Collision and G Stored Graphics (`gfx.pos`), not the
visible model. No new Coq theorem, global height bound or complete controller
route is claimed. All45 subjective estimates are unchanged, including
Rank1 **1–2%** and Ink Rank2 **<1%**.
