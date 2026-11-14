# Original JP confirms the frozen-shell compatibility and bridge failure

14 November 2026. **The original Japanese ROM reproduces the three Y25000
controls:** the explicitly relocated frozen-shell rider gives useful spawn
displacement; high freefall followed by next-update pusher/Z fails to retain
riding; immediate Z gives a large stored-graphics gap and an ordinary warp.
The second result does not show that the initialized clone is unmountable.
It shows that the mount is canceled by the first ground step before the
next input/interaction update.

The [Wafel report](ink-cloned-shell-bridge.md) records the full source
explanation, larger finite search, every grant and exact positions. This
ROM package is
[`instrumentation/jp-ink-cloned-shell-bridge/`](../../instrumentation/jp-ink-cloned-shell-bridge/).
It preserves the raw logs, source copies, exact Wafel expectations, receipts
and verification commands. No ROM or compiled binary is redistributed.

## Authentication and setup boundary

These runs use Mupen64Plus2.5.9, interpreter CPU, Rice2.5.9, HLE RSP, dummy
audio and software OpenGL under Ubuntu-24.04. The unchanged original JP ROM
is authenticated by SHA-256
`9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317` and
MD5 `85d61f5525af708c9f1e84dce6dc10e9`. The starting proof revision is
`162617b708b2244beca85af58b76ad5794e598cd`. The shared accepted four-pillar
A-off controller prefix retains its disclosed debug level-selection startup
cheat6. New test preparation starts only after that prefix.

Every new scalar write is logged and checked by exact address, width, value,
timing and field label against the corresponding Wafel setup:

- At setup step0, set shell-box slot32 action4; two native updates initialize
  shell71. This supplies shell availability.
- At step2, supply low idle Mario at `(5900,51,3380)`, zero motion, and shell
  XYZ `(6100,51,3380)`, then press B. The pickup starts against real small
  box23. At step6, supply only `usedObj=71`; native pickup reaches the shell
  on step8 and holding idle on step19.
- Press B for throw on step20. At step25, supply HOLP
  `(-1950,24990,-971)`. Native release on step26 leaves the frozen shell at
  `(-1950,24990,-939)`, tangible and with its initialized type/hitbox.
- The bridge cuts set initial Mario M/C/G, `FREEFALL`, action state/timer0,
  forward speed20, velocity `(20,-16,0)`, and face `(0,16384,0)`. Mode1 also
  relocates the shell low for its compatibility control, then supplies the
  high Mario XYZ cut after the native low mount. Modes2 and3 never change
  Mario after their initial high cut.
- The Bob-omb is a native SSL Area1 actor, slot39. Modes1 and2 supply its
  XYZ just before the Z update, at current Mario position plus `(-29,0,0)`.
  Mode3 has no pusher; its archived Wafel counterpart uses that exact recipe.

Shell type, hitbox, status, tangibility, carry command, floor data, platform
and ridden pointer are never assigned. Mode1/2/3 contain61/49/46 new scalar
writes respectively. All recorded new inputs and final native counters have
A released and no A press. No held-A dependency is used. The fake-pickup
pointer, high HOLP and initial Mario/actor placements remain supplied;
the ROM runs do not demonstrate legal delivery or reachability.

## What the ROM reaches

Here G means stored graphics `gfx.pos`, not the visibly drawn model.
Top timer values are before/after the relevant update, not an assertion
that the animation is at a rendered frame with the same number.

| Original-JP control | First relevant result | Later result |
| --- | --- | --- |
| Low native frozen-shell mount, then explicit high rider relocation | Low mount retains `RIDING_SHELL_GROUND` and ridden71. Supplied high XYZ plus Bob-omb/Z at top130→131 gives M=C `(-1882,768,-939)`, G `(-1882,25000,-939)`. | Next update accepts warp64 and captures top61. The platform is retained at every observed remaining Area1 boundary. First Area2 position is `(365.5927734375,5500,-1096.8026123046875)`. |
| Supplied high FREEFALL, neutral mount, next-update Bob-omb/Z | First update ends `BACKWARD_GROUND_KB`, ridden null, M=C `(-1950,25000,-939)`, G.Y25045, fresh floor768. Shell has `STOP_RIDING` status but remains tangible. | Next contact pushes X to−1861, still high ground knockback. Through the35 logged bridge updates there is no warp or top capture. |
| Supplied high FREEFALL, mount and fresh Z together | M=C `(-1950,768,-939)`, G `(-1950,25000,-939)`, `GROUND_BONK`: a real24232-unit gap. | Warp64 is accepted with no platform; first Area2 position is ordinary `(0,5500,256)`. |

The positive control uses low starting Mario
`(-5862.31787109375,1034,819.5643920898438)` with the shell10 below.
One neutral update at top129→130 mounts on real floor1024. The next cut
supplies Mario M/C/G `(-1950,25000,-939)` without altering the native riding
action, motion or pointer. The producer is bridge update2, capture update3,
and Area2 arrival update26 when the low-mount update is included. In mode2,
mount and pusher/Z are bridge updates1 and2. In mode3, same-update mount/Z
is bridge update1 and ordinary arrival update25.

## Verification limits and exact comparisons

The checker validates492 native camera observations across the three runs:
163 positive,165 delayed-Z,164 same-Z. It compares208 selected boundaries
to Wafel:66,77,65 respectively. The selection includes native initialized
shell, pickup, throw, the bridge and first Area2 arrival; the intervening
neutral wait has native logs but is not claimed as an exact Wafel comparison.

Every compared non-clock field matches bitwise, including M/C/G, velocity,
action, floor/ceiling, platform, used/held/ridden slots, shell hitbox/type/
status/tangibility, symbolic carry command and object collision list. All208
raw global-timer mismatches remain in the receipts: the native camera
observation's timer is two less than the corresponding Wafel boundary.
The normalized selected-field comparison passes; strict raw comparison
does not. This is not a full-state or full-memory equivalence claim.

There is no native camera callback at setup steps154 and155 during each
warping transition. Those two absent observations per run are listed
explicitly in the receipts. Positive platform retention is checked through
the last observed Area1 boundary, and the displaced arrival is observed
directly; the missing transition callbacks are not silently counted as
verified frames.

The archived expected mode3 was reproduced from two fresh Wafel roots with
no pusher, matching the ROM recipe. The broader Wafel report's same-Z case
with a late pusher has the same outcome but is not substituted into this
comparison. Original-ROM tests here cover **Y25000 only**; Y67277 and90536
remain Wafel tests in this package.

These original-ROM results strengthen the conditional compatibility result
and the tested bridge failure. They do not close the full shell route. The
first failed step of the tested Y25000 one-shell/one-pusher bridge remains
retaining the right action until the sideways interaction can run. Lower
heights and the earlier three-actor sequence are separate cases; this ROM
menu does not rule them out. Legal fake pickup, high HOLP and Mario delivery
are separate reachability obligations.
