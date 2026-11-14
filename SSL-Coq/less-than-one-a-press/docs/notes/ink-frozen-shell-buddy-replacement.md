# Replacing Buddy in the frozen-shell Y19900 handoff

14 November 2026. **A black Bob-omb does not directly replace Buddy in the
tested successful sequence. It really can shove Mario, but it shares the
Crazy Box's GRABBABLE interaction. In the closer two-actor controls, both
actors collide and only the Box's shove is selected.** The same limitation
applies to the small box. This is a local substitution result, not proof that
Bob-ombs cannot participate in another timing or handoff recipe.

**Size limit:** these new controls use stock Bob-ombs with radius65 and
height113. They do not instantiate the enlarged transported profile
(radius91) or the conditional release-growth profile (radius117). Those
larger actors could change contact and single-push geometry. The source's
one-GRABBABLE-per-pass ordering remains, but their retuned outcomes are not
excluded by this finite menu.

The [earlier replacement study](ink-buddy-replacement-handoff.md) already
tested exact/closer substitutions with a live-shell initializer. This work
credits those results and checks the latest actual frozen-shell Y19900
sequence, without repeating its large inverse-placement searches.

## Exact setup and grants

The [frozen-shell lower study](ink-shell-lower-boundary.md) is the control.
Its preparation creates a real initialized shell71 from shell box32, performs
a native conditional fake pickup and native high-HOLP throw, then waits to
stored top timer128. Inherited grants are debug level-selection startup,
shell-box action4, low pickup poses, one `usedObj` retarget, and high HOLP.
No shell interaction type, hitbox, status, tangible state or ridden pointer
is assigned. This is not legal high shell delivery.

At timer128 supply Mario M=C=G=`(-1920,19900,-1210)`, FREEFALL, forward
speed20, velocity `(0,-16,20)`, yaw0 and state/timer0. Place the frozen shell
at `(-1920,19890,-1210)` and press Z with neutral stick. All later pads are
neutral and A remains released. No Mario field is edited afterward.
The native result is BUTT_SLIDE on the actual spinning top at
`(-1920,1799.2869873046875,-1210)`; G still stores Y19900 on this first update.

The tested replacements occur at the **following lower position near
Y1799**, not at the original shell/Mario height19900. Before top129, retain
Crazy Box49 at `(-1990.710693359375,1799.2869873046875,-1280.710693359375)`
unless the recipe explicitly removes that cut. The candidate is placed at:

- Exact Buddy position:
  `(-2054.455810546875,1799.2869873046875,-1208.867919921875)`.
- Closer control:
  `(-2000,1799.2869873046875,-1210)`.

Before top130, every recipe places the same Crazy Box49 at
`(-2117.125244140625,1830.177978515625,-1128.1343994140625)`.
That roughly198-unit second Box relocation is still supplied. “Candidate
alone” below means without the Box129 cut; it still includes this Box130 cut.
Actor cuts change XYZ only. Every behavior, hitbox, type, callback, velocity,
status, floor query and platform operation runs natively afterward.

The live stock candidates are black Bob-ombs39/40 (radius65,height113) and
small box23 (radius60,height100), all GRABBABLE. The control Buddy15 has
radius100,height60 and TEXT/NPC interaction. All exist in SSL Area1.
Two extra controls reposition the **same initialized frozen shell71** after
its initial cancellation; they add no second shell or arbitrary shell type.
Its radius/height are50/50 and its interaction is KOOPA_SHELL.

## Results

Sixteen complete continuations and567 sampled boundaries match a second
fresh runtime exactly. Only the Buddy positive captures/retains the top and
reaches `(365.5927734375,5500,-1096.8026123046875)` in Area2. Each negative
continues36 updates, without a top capture or useful arrival in that horizon.

| Replacement before top129 | Collision result | Actual effect with Box129 present | Useful result |
| --- | --- | --- | --- |
| Buddy at original position | Both register; list `[15,49]` | Distinct Box then NPC handlers give the original productive intermediate position | Yes, positive control |
| No Buddy | Only Box49 | Box-only trajectory | No |
| Bob39 or Bob40 at original Buddy position | Bob does not register | Identical to Box-only | No |
| Bob39 or Bob40 at closer position | Both register; `[49,39]` or `[49,40]` | First selected GRABBABLE is49; identical to Box-only | No |
| Small23 at original position | Small box does not register | Identical to Box-only | No |
| Small23 at closer position | Both register; `[49,23]` | First selected GRABBABLE is49; identical to Box-only | No |
| Frozen shell71 at original position | Shell does not register | Identical to Box-only | No |
| Frozen shell71 at closer position | Both register; `[71,49]` | Shell's earlier distinct-type push changes trajectory, but misses the required setup | No |

The smaller radii are the **first** failure at the exact Buddy coordinates.
One-object-per-type dispatch is the separate failure demonstrated by the
closer controls; do not conflate the two.

The first native action-entry movement position after the top129 interactions
is `(-2061.834716796875,1799.2869873046875,-1200.7708740234375)` in the Box-only
control and all six Box-plus-Bob/small controls. Its completed M/C/G is
`(-2059.110107421875,1867.0308837890625,-1191.7894287109375)`. By contrast the
Buddy control reaches action-entry
`(-2140.031982421875,1799.2869873046875,-1115.0291748046875)` and completed
M/C `(-2140.031982421875,1830.177978515625,-1115.0291748046875)`.
G retains Y1799.2869873046875 there, setting up the later useful producer.

Bob's shove itself is not absent: with the Box129 cut removed, the closer
Bob alone registers and reaches action-entry
`(-2088.8583984375,1799.2869873046875,-1248.89990234375)`; completed movement
is `(-2086.1337890625,1821.93994140625,-1239.91845703125)`. The unchanged
later Box130 placement still fails. Small box alone similarly changes the
trajectory. The closer frozen shell plus Box reaches completed movement
`(-2087.81640625,1828.0035400390625,-1233.220458984375)`, confirming that a
distinct interaction type can matter without claiming it reproduces Buddy.

## Why transferability alone does not make this substitution work

The actual ordered dispatcher visits each interaction type once. It obtains
the first collided object of that exact type, clears the type bit, then
calls its handler if eligible. Continuing after one handler goes to the
next type, not the next GRABBABLE actor. Buddy's TEXT handler occurs after
GRABBABLE; the shell type occurs before it. Collision-list order and handler
order therefore differ: `[15,49]` still processes Box before Buddy.
Sources: [ordered handlers and collided-object selection](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/interaction.c),
[source review and inventory](ink-buddy-replacement-source.md).

A Bob-omb with a real transport history can have different dimensions. The
earlier expired/held transport record reaches scale about1.4, radius91 and
height158.2; conditional release growth can reach radius117. These new
controls use stock radius65,height113. They do not
prove that every delivered Bob-omb misses the original hitbox placement or
that every retuned single push fails. A larger Bob still uses GRABBABLE and
does not obtain a second same-pass handler merely by being larger. Freezing
an actor also does not give it Buddy's interaction type.

Different-update Bob/Box shoves or one sufficiently placed actor replacing
both old shoves remain distinct questions. This package does not test those
retimed alternatives, prove all-height impossibility, or join actual Bob
transport to the Ink setup. Parent followups, if any, are reported separately.

## A low frozen shell with no later shell relocation

The highY19900 shell is initially far above Mario after alignment onto the
top, so it cannot provide the next shove without another position grant.
A separate nine-case control uses the earlier corrected low airborne pose
`(-1922.4404296875,1810,-1223.34130859375)` and the same native FREEFALL
velocity/yaw, with the initialized frozen shell at Y1800. Its initial X/Z
offset from Mario ranges over `{-60,0,60} × {-60,0,60}`. Z is pressed at128;
the same Box129/130 cuts follow, with **no Buddy and no further shell or
Mario writes**. The preparation uses a real conditional fake pickup and
native throw with supplied HOLP, followed by the declared initial low pose.
It does not manufacture a new shell status or interaction type.

All nine mounts succeed and enter BUTT_SLIDE. The frozen shell remains at
its initial XYZ throughout all36 updates in each case. Seven of the nine
register the shell alongside Box49 at129. The center offset `(0,0)` follows
the Box-only path despite shell registration. Two offsets `(-60,0)` and
`(-60,60)` change the action-entry and completed trajectory; their completed
M after129 is respectively
`(-2078.032470703125,1847.0113525390625,-1213.930908203125)` and
`(-2063.646484375,1862.4498291015625,-1196.06884765625)`.
The other seven match the Box-only intermediate position. None captures
the top or reaches a useful spawn in the checked36 updates.

This is324 further independently matched boundaries, separate from the
sixteen direct-replacement histories. Collision registration uses the older
raw collision position, while the push uses current movement after platform
motion, so registration alone does not guarantee a nonzero additional shove.
The two changed trajectories show that retaining the frozen shell nearby can
matter, but this finite initial-offset menu does not replace Buddy. It does
not exhaust offsets, Box placements or timing, and it credits the earlier
live-shell low initializer rather than claiming that initializer is new.

## Reproduction and evidence level

Start revision `c1f31bff1365055745d08fdd2728ac501378c4df`; decompile checkout
`36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`, stock JP source pin
`9921382a68bb0c865e5e45eb594d9c64db59b1af`. Runtime is Wafel0.8.5/Python3.9.13,
DLL SHA256
`960fe979068b78e6733b3ddb87741833fbf4eb29b2a21a2bba871977427c2d0f`.
This package adds JP source-runtime evidence, **not a new original-ROM replay**
or Coq proof. The existing frozen-shell positive already has its separate
original-JP confirmation.

`instrumentation/ink-frozen-shell-buddy-replacement/` preserves every setup
write, input, shell/candidate snapshot, collision list, native action event,
M/C/G, floor/cache, top/warp/platform result and finite continuation.
G means stored `gfx.pos`, not where the model is rendered. Raw undecoded
event fields are retained but not promoted to ground-quarter return values.

```powershell
& build/wafel-pilot/python/python.exe instrumentation/ink-frozen-shell-buddy-replacement/test.py --verify instrumentation/ink-frozen-shell-buddy-replacement/results.json.gz
```

The hash checker is `verify.py`. No new A press or held-A dependency occurs
inside these supplied-state histories; this does not make their supplied
poses or actor deliveries controller-reachable.

The separate low-offset rerun is:

```powershell
& build/wafel-pilot/python/python.exe instrumentation/ink-frozen-shell-buddy-replacement/low.py --verify instrumentation/ink-frozen-shell-buddy-replacement/low-results.json.gz
```
