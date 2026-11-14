# Original-JP enlarged Bob-omb handoff and ordinary-warp control

14 November 2026. **The original Japanese ROM reproduces useful spawning
displacement without Buddy in this supplied setup.** A radius-91 black Bob-omb
provides the earlier shove and a Crazy Box provides the next update's shove.
The positive captures and retains the spinning top and reaches
`(365.5927734375,5500,-1096.8026123046875)` in Area 2. Omitting only the final
Crazy Box placement still produces fresh floor768 and a gap, but gives the
ordinary arrival `(0,5500,256)` without top capture.

This validates the local compatibility discovered in
[the enlarged-Bob study](ink-enlarged-bob-handoff.md). It does not establish
continuous delivery, high Mario entry or the joint actor/phase history.

## Exact setup and controls

Both runs use the established conditional native shell initialization,
fake-pickup retarget and high-HOLP throw preparation. Immediately before top
update128 they supply FREEFALL Mario at `(-1960,19900,-1230)`, speed0,
velocity `(0,-16,0)`, yaw0, and the frozen initialized shell ten units below.
They also supply the recorded free radius-91 Bob profile before that cut:
32 scalar/vector fields, or34 scalar components, from the separately
controller-reached donor at input628. Behavior, native command and interaction
type/subtype are retained; neither fuse nor callback is frozen. This ROM
experiment transplants the donor fields, rather than replaying the entire
donor controller history on the ROM and transporting the actor to Ink.

Z is the only button on update128; later inputs are neutral and A is always
released. Before129, Bob39 is placed at
`(-2080.06005859375,1809.2066650390625,-1230.322021484375)`. The positive
places Crazy Box49 before130 at
`(-2102.720703125,1839.447265625,-1119.5618896484375)`; the negative omits
that placement. The live Bob and every other actor remain in the world.
There are no Mario edits after the initial airborne cut. The existing prefix
uses debug level selection; this is not an unmodified retail start.

The native positive logs95 scalar setup writes; the negative92. Every write,
including the shell preparation and donor transplant, is preserved. There
are no floor/cache, platform, collision-list, behavior-script or ROM-code
writes. Read-only execute breakpoints observe the existing instruction stream.

## What the original ROM actually queries

The Bob's update129 shove leaves Mario at
`(-2117.02685546875,1839.447265625,-1113.008544921875)` with platform cleared.
The producer's initial geometry query, before the next actor interaction,
returns and saves768 in both runs.

| Producer update130 observation | Positive | Omit final Crazy Box |
|---|---|---|
| Initial geometry query result | 768 | 768 |
| Actor shove's validation result | Top1916.10986328125 | 768, from the remaining Bob shove |
| Ground quarter's local floor | 1280 | 768 |
| Ground quarter ceiling | Top underside1523 | Top underside1523 |
| Native quarter result | STOP2; cache stays768 | STOP2; cache stays768 |
| Completed M = C | (-2200.001709,768,-1075.003906) | (-2117.715332,768,-1111.113281) |
| Stored Graphics Y | 1839.447265625 | 1839.447265625 |
| Accepted warp with captured/retained top | Yes | No top capture |
| First observed Area2 movement | (365.5927734375,5500,-1096.8026123046875) | (0,5500,256) |

G means stored `gfx.pos`, not the render matrix. The positive gap is
1071.447265625. The positive's shove validation selecting the top differs
from the older Buddy control's validation selecting1280; neither validation
query writes Mario's floor cache. The subsequent stopped quarter preserves
the earlier768 cache. Its real ceiling comes from the top's underside, not
the default20000 sentinel.

At the following update, the positive low collision accepts warp64; the
stored-G retry selects top61 at1914.85498046875. Every observed subsequent
Area1 boundary retains platform61 until the displaced Area2 arrival. The
negative's surviving Bob can still move Mario slightly on the producer
update; it must not be called a no-further-push control.

The Bob remains live after its useful shove. Its actual native fuse advances
170→171 on update129; its completed-update radii then follow91,65,78,91,104,
117 and deletion. Its explosion and spawned actors remain active during the
successful warp continuation. It is not a permanent radius-91 collision clone.

## Validation and reproduction

The [replay package](../../instrumentation/jp-ink-enlarged-bob-handoff/README.md)
contains exact recipes, generated C probes, generator, checker, raw logs,
compiled-source snapshots and hash inventories. ROM/emulator binaries are
excluded. The original ROM SHA-256 is
`9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317`.
The applicable stock JP source pin is
`9921382a68bb0c865e5e45eb594d9c64db59b1af`, local decompile
`36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`; work started from proof revision
`32f5eb4d5911b2e0a7972b748065c71ebe016717`.

Ubuntu-24.04 ran Mupen64Plus2.5.9's interpreter/debugger, Rice2.5.9 and RSP
HLE2.5.9, with dummy audio and Xvfb. The existing authenticated prefix and
floor-query breakpoint addresses are reused. Each run matches25 selected
physical-state boundaries against the independently reconstructed Wafel
history, including Bob action, size and position fields. All50 global-clock
differences (`native+2 = Wafel`) are retained. Each run lacks camera samples
25/26 across the area transition; the first Area2 observation is checked
exactly. This is not full-memory equality.

There are682 actual floor returns in the positive trace and665 in the
negative. The checker verifies producer query roles, the saved768 cache,
quarter STOP2 without a cache commit, ceiling1523, capture/retention outcome,
the exact useful/ordinary spawn, the no-A audit and absence of later Mario
writes. Both native comparisons and archived rechecks pass. No new Coq
statement, global height interval or controller reachability theorem follows.
