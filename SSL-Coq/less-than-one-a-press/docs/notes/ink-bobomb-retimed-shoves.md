# Bob-omb and Crazy Box shoves on different updates

14 November 2026. **The small retimed search did not replace Buddy with a
useful Bob-omb/Box sequence.** Actual Bob-omb contact can leave Mario sliding,
so there is no universal action-entry failure here. The tested later producers
instead finish on the high top floor rather than with the required low-floor
split. This is a bounded search, not proof that every retiming must fail.

This follows the untested consecutive-update suggestion in
[the earlier replacement study](ink-buddy-replacement-handoff.md), rather
than repeating its large same-update inverse-placement searches. It reuses
the genuinely initialized frozen-shell preparation from
[the lower-boundary study](ink-shell-lower-boundary.md). The direct current
Buddy replacements are covered separately by
[the frozen-shell replacement controls](ink-frozen-shell-buddy-replacement.md).

## Setup and exact finite menu

Start revision `c1f31bff1365055745d08fdd2728ac501378c4df`; decompile checkout
`36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`, applicable stock JP pin
`9921382a68bb0c865e5e45eb594d9c64db59b1af`. Runtime is JP Wafel0.8.5,
Python3.9.13, existing DLL SHA256
`960fe979068b78e6733b3ddb87741833fbf4eb29b2a21a2bba871977427c2d0f`.
The accepted four-pillar prefix retains debug level-selection startup.
The shell-box action4 grant, low pickup pose, one native pickup-target
retarget, and high-HOLP throw grants are exactly recorded in preparation.
The shell itself is native initialized slot71, subsequently stopped by the
native carry script. No shell type, dimensions, status or ridden pointer is
manufactured.

The ten initial seeds cross stored top phases126/127 with these five X/Z:
`(-1920,-1210)`, `(-1900,-1170)`, `(-1940,-1210)`, `(-1920,-1170)`, and
`(-1900,-1210)`. Once per seed supply Mario M=C=G at raw Y19900,
FREEFALL, state/timer0, speed20, velocity `(0,-16,20)`, yaw0. Put the released
frozen shell ten units below, then press Z with neutral stick. Native mount,
cancellation and movement establish the slide; no ground action is supplied.
There are **no later Mario edits**, and all later pads are neutral with A off.

The first Bob-omb39 position cut occurs one update after the shell/Z update:
at127 for the126 seeds, at128 for the127 seeds. For126 seeds there is then a
neutral update128. Crazy Box49 is placed before129. A final position cut of
Box49 or the second native Bob-omb40 is tested before130. No older actor is
removed, frozen, reset or deactivated by the test; native callbacks and
collision priority continue. This is not an assertion that the selected new
actor always wins the GRABBABLE handler.

The native black Bob-ombs are the actual stock **radius65/height113** actors;
their callback, fuse, scale and lifetime fields remain untouched. This does
not test the larger91/117-radius profiles discussed in the source review,
nor a joined real carried-Bob-omb history. The Crazy Box is native radius75.
Both species and the shell box exist in SSL Area1.

The candidate generator uses actual collision position C and a neutral
continuation's first native action-entry movement P, accounting for moving
platform displacement between them. It proposes actor positions toward a
fixed pad-target grid, plus sixteen radial placements and a no-cut control.
Push separation uses the current hitbox radius plus Mario37 minus padding5;
every proposal is then run through the real engine. This arithmetic proposes
tests, not replacements for the collision/ground execution.

The search keeps three intermediate outcomes per seed, then32 final routes:
sixteen ranked by horizontal pad proximity and sixteen by proximity to the
known producer Y1830. Duplicate recipes are removed. The first ranking alone
was a prior1,095-screen pilot; its archive is retained as overlapping work,
not additional independent coverage. Both rankings and exact target/radial
menus are in `search.py`; their pruning means the search is not exhaustive.

## Results

| Stage | Coverage | Observed result |
| --- | ---: | --- |
| Earlier shell/Z initializers | 10 | Native slide seeds, all inputs A-off |
| First Bob placement/neutral controls | 170 | 160 actual Bob collision registrations; all170 finish BUTT_SLIDE |
| Later Crazy Box proposals | 523 | 493 actual Box registrations;522 finish BUTT_SLIDE, one BUTT_SLIDE_AIR |
| Final producer and next-update acceptance screens | 1863 | Zero top captures; zero completed producer floor768; zero completed G-minus-M gaps above900 |
| Selected complete continuations | 12 ×40 updates | All remain Area1 through the horizon; no useful displaced arrival |

The12 full histories and ten initializer observations independently match a
second fresh runtime:480 complete-history boundaries plus ten initializer
boundaries. The complete saved artifact, including every finite screen,
also passes a separate `--verify` reconstruction. This does not make the
overlapping menus independent route discoveries.

One representative near miss starts at phase127 with air X/Z(-1920,-1170).
Its no-Bob-cut comparison places Box49 at
`(-2097.10595703125,1865.3800048828125,-1204.163818359375)` before129, then
at `(-2190.210205078125,1889.0369873046875,-1052.587646484375)` before130.
After130, M=C is
`(-2104.462890625,1933.4923095703125,-988.58447265625)`, while G.Y is
1889.0369873046875. The completed floor is top-owned at1933.4923095703125,
not768. The next update still slides on the top, used object remains the
shell, and no warp is accepted. It is a horizontal-pad near miss, not a
useful low-collision/high-G state. Bob-containing recipes also fail the
screened handoff; the no-cut control is identified rather than mislabeled
as a successful Bob shove.

The first directly verified missing condition is the completed low-floor
producer state. The harness does not expose every intermediate floor-query
return, so this note does not claim that no earlier query ever returned768.
Raw movement-step `_placeholder` events are retained but not decoded as
quarter-step return values.

## Limits and next discriminator

Source one-handler-per-type explains why two GRABBABLE actors do not give
two independent same-pass pushes, but it does not prohibit consecutive-frame
pushes. This search actually tries that scheduling alternative and still
finds no usable crossing in its finite menu. Different initial coordinates,
input steering, intermediate phases, enlarged native Bob profiles and
different delivery histories remain untested. No new original-ROM replay or
Coq theorem is claimed by this component.

The useful next discriminator is a native enlarged-Bob contact profile or a
retimed history that demonstrably preserves low floor768 at the productive
cut. It should be tested before claiming that ordinary carrying alone makes
the substitute usable. The search does not transport its actors: all named
XYZ cuts, the initial air pose, fake-pickup target and high HOLP remain grants.

Artifact: [`instrumentation/ink-bobomb-retimed-shoves/`](../../instrumentation/ink-bobomb-retimed-shoves/).
M means Movement, C Collision, and G Stored Graphics `gfx.pos`, not the rendered
model. No full no-new-A route or universal Bob-omb exclusion follows.
