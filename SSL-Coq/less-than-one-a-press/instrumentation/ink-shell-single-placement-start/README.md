# One initial Box-carry setup, then only controller inputs: finite misses

15 November 2026. **None of215 tested single-initial-cut histories gives useful
Ink displacement.** The remote shell throw is actual, and no Mario, actor,
held-pointer or HOLP edit follows the initial Box-carry setup. The initial
setup still supplies that carrying state plus the free enlarged Bob profile
and placement. It therefore isolates removal of the post-Box-release Mario
relocation; it does not claim Mario has delivered the Bob or reached the high
initial state.

Each case runs from two fresh independent reconstructions, retaining9639
suffix boundaries per reconstruction. Two histories take an ordinary warp;
none captures the top. This finite menu is not an impossibility theorem.

## Exact finite menu

The actual shell pickup/remote throw is inherited from
`ink-shell-remote-functionality/handoff.py`, including its disclosed pickup
grants and throw-time HOLP. The actual shell ends at
`(-1962.4404296875,1800,-1243.34130859375)` and is never edited afterward.

At start-of-update top phases120–126, the one initial setup supplies Mario
HOLD_FREEFALL at that shell's X/Z, speed0/yaw0, vertical velocity−16 or−32,
holding Crazy Box49. It supplies a native released91 Bob scalar profile once
at `(-2079.9365234375,1809.2066650390625,-1233.3045654296875)`, the earlier
compensated free-Bob fixture. That actor's native fuse, movement and lifetime
then run normally. Its delivery is not established by this test.

The regular grid is Y1850,1890,1930,1970,2010,2050,2090 ×7 phases ×2 velocities
×B/Z first input =196 cases. Twenty-one additional B cases use initialY
`1810+16*n+2*n*(n-1)+dy`, where `n=128-startPhase` and `dy=-10,0,10`, with
velocity−16. Two duplicates are removed:215 distinct cases in total,117 B
and98 Z, with actual initialY1836–2090. This is a discrete grid and named
time-of-fall heuristic, not a continuous height window.

Initial Box HOLP is `(-2102.720703125,1920,-1151.5618896484375)` for requested
B throws (accounting for yaw0's32-unit throw offset), or
`(-2102.720703125,1920,-1119.5618896484375)` for Z drops. A fresh Z is pressed
at128; remaining inputs are neutral, up to45 updates or Area2 arrival.
Every input has A released, and interpreted A flags are checked too.
All phase labels here are **timers at the start of the named update**.

## The remote HOLP is overwritten during the B windup

In all101 B histories that still hold the Box after the first update, ordinary
held-object rendering immediately replaces the supplied remote HOLP. All73
actual B throws therefore use a changed HOLP, not the requested remote one.
The remaining44 B requests become native drops because shell contact occurs
before the throw call and interrupts AIR_THROW. Each has a recorded shell
mount transition on its release update. These are not73+44 successful throws.

Release kind is independently classified using the native Crazy Box callback:
HELD_THROWN calls `cur_obj_get_thrown_or_placed(40,20,1)` and the observed
release boundary has forward speed40/vertical speed16; HELD_DROPPED gives
forward/vertical speed0. The correct `bhvJumpingBox` identity and free held
state are checked. Actor slots may be reused after deletion; later slot
snapshots are not assumed to remain the original Box/Bob.

An actual-throw example starts at phase120/Y1930/vy−16. Initial HOLP is
`(-2102.720703125,1920,-1151.5618896484375)`. Before the phase123 throw it has
become `(-1943.83251953125,1962.531494140625,-1294.09423828125)`. The native
throw and callback leave the Box at
`(-1943.83251953125,1978.531494140625,-1262.09423828125)`. It has not reached
the desired final-pusher origin. The first failed assumption is preservation
of remote HOLP through the ordinary visible carry/throw windup.

Another B example, phase124/Y1890/vy−16, overwrites HOLP on124 and mounts the
shell on127, a frame before the planned Z. Shell contact drops the Box at
`(-1942.81298828125,1830,-1294.2342529296875)`. Z128 does produce BUTT_SLIDE,
but by130 the floor cache is1858.062622 rather than768; there is no capture.
This is a real controller-only continuation after its one initial grant,
with the wrong release geometry and contact timing.

## Z controls and the closest warp

Of98 Z starts,84 immediately become GROUND_POUND. In the example
phase124/Y1890/vy−16, the Box drops at its intended X/Z, but Mario's ground
pound initially rises. The Box activates and is deleted on126; Mario is still
in GROUND_POUND at128/Y1970. This misses the desired mount/slide timing.
The other14 Z starts contact the shell immediately:12 end the first update
in BUTT_SLIDE and2 in BUTT_SLIDE_AIR. Z is not universally a failed mount.

The two ordinary-warp cases start at phase120/Y1850 with either velocity.
They reach M.Y768/G.Y1799.077759 on122 and contact the real warp on123, but
never capture the top. Both arrive at `(0,5500,256)`. A gap and an accepted
warp therefore remain insufficient. Across the whole menu103 histories
execute the riding-ground handler and159 have a BUTT_SLIDE/CROUCH_SLIDE
boundary; none completes useful displacement.

The next targeted experiment would need to preserve or naturally produce the
desired HOLP through the throw, while arranging the first above-shell contact
for the Z update. This menu fixes horizontal starting position and speed0;
it does not close schedules with another trajectory, speed or rendering/HOLP
history. No original-ROM replay or new Coq result is claimed for this menu.

## Reproduce

From the SSL directory:

```powershell
& build/wafel-pilot/python/python.exe instrumentation/ink-shell-single-placement-start/check.py --verify
& build/wafel-pilot/python/python.exe instrumentation/ink-shell-single-placement-start/analyze.py --verify
```

The first command independently reconstructs all215 cases twice and checks
the exact archived traces. The second reclassifies every actual release,
checks the HOLP claims and binds the source/artifact hashes. Full initial
write ledgers, controls, M/C/G, HOLP, actor identity/velocity/lifetime,
floor/cache/platform/collision data and frame events are preserved.

Start revision `ea1a4994f5157636f481723a89c6411a53e6e6d4`; applicable JP source
`9921382a68bb0c865e5e45eb594d9c64db59b1af`; local decompile
`36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`. Wafel0.8.5/Python3.9.13 DLL SHA256:
`960fe979068b78e6733b3ddb87741833fbf4eb29b2a21a2bba871977427c2d0f`.
