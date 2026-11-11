# Original-JP recordings: three separate components

The original JP ROM reproduces a controller-only low hands-free pickup,
release and crawl component. It also reproduces the supplied-position high
hands-free example and, in a separate run, the supplied 973-unit Ink handoff.
These recordings do **not** establish one continuous no-A pyramid route.

The recordings use the authenticated 8 MiB JP ROM
`9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317`,
Mupen64Plus 2.5.9's interpreter, Rice rendering, a stock camera, and the existing
debug level-select entry. All controller sequences contain zero A inputs.
Game audio is disabled; explanatory text belongs to the presentation, not the
game. See the [capture workflow](../../instrumentation/jp-ink-handsfree-demo/README.md)
and [native provenance](../media/ink-handsfree-native/provenance.json).

## Controller-only low component

The 656-input clean sequence contains no gameplay-state writes after the
accepted entry setup. Mario picks up the eastern box 47 after input 424,
enters `ACT_DIVE_PICKING_UP` after 435, then `ACT_STOMACH_SLIDE` while retaining
the held box after 436. “Hands-free” refers to a non-holding action retaining
the held-object pointer; the box remains visibly attached to Mario.

The selected continuation brakes, drops the box at Y=38 after input 515,
and reaches crawl at Y=38 after 528. The box is already inactive after 516.
Thus this shows that low crawl can follow the hands-free component without A;
it does not supply a surviving box at the high handoff. The spinning-top
sequence has not begun in this component. The source investigation and
recorded search scope remain in [clean acquisition](ink-clean-handsfree.md)
and [continuations](ink-handsfree-continuations-receipt.json).

The native checker matched 305 distinct snapshots against the Wafel
acquisition and continuation records. Compared fields are action, held slot,
M/C/D, actorXYZ, floorY, area and top action/timer, with binary32 comparison
for floating-point fields. This is a finite observed projection, not a full
memory or execution theorem. [Native receipt](../media/ink-handsfree-native/clean-receipt.json),
[trace](../media/ink-handsfree-native/clean-trace.txt).

## Supplied high hands-free component

After the existing four-pillar prefix, five ordinary movement inputs and B
produce a native unheld dive. At stored top timer 6 the probe supplies Mario's
movement, collision and display positions at `(-2559,1741,-1535)` and box 49's
position at `(-2559,1741,-1465)`. These are twelve 32-bit coordinate writes.
It does not write an action, held pointer, velocity or floor cache. The next
140 updates use the recorded Z-and-steering inputs only.

The game picks up the box, lands in dive-picking-up, and enters hands-free
butt sliding while retaining the box. The continuation eventually dies in
quicksand. All 146 logged snapshots, including the six pre-cut updates, match
the compared Wafel projection. This is the high example from the
[hands-free investigation](ink-box-handsfree.md), not a controller producer
of that high starting pose. [Native receipt](../media/ink-handsfree-native/supplied-handsfree-receipt.json),
[trace](../media/ink-handsfree-native/supplied-handsfree-trace.txt).

## Separately supplied 973-unit handoff

A third boot replays the four-pillar prefix. At stored timer 129 the probe supplies
the crawl action at Mario's ordinary position and executes one native update,
which establishes the correct 100-unit hitbox. At stored timer 130 it supplies
M/C/D `(-1950,1741,-939)` and free box 49 `(-1989,1741,-939)`. There are thirteen
word writes in total: one action and twelve coordinates. No camera, floor,
velocity or platform-reference write is used.

The resulting native update ends at M=C `(-1882,768,-939)` while the display
remains at `(-1882,1741,-939)`, a 973-unit split. The following update captures
the top at floorY=1818.9613. First Area 2 arrival is approximately
`(365.592773,5500,-1096.80261)`, outside the screened elevator footprint.
This confirms the bounded supplied-state mechanism in the original ROM. It
does not connect either preceding hands-free history to that supplied crawl
or position, and it supplies no new all-history allocator theorem.
[Native receipt](../media/ink-handsfree-native/supplied-handoff-receipt.json),
[trace](../media/ink-handsfree-native/supplied-handoff-trace.txt).

## Timing and reproduction limits

Wafel's after-advance global timer is consistently two greater than the
camera-callback timer logged by this native capture. Comparisons align
controller inputs and top state; absolute global timers are not silently
identified. Screenshot requests return the preceding completed framebuffer.
The [workflow table](../../instrumentation/jp-ink-handsfree-demo/README.md#results-and-frame-alignment)
gives exact image indices for commentary. All three final-source probe builds
were byte-identical to their captured binaries. The checks succeeded; no Coq
proof was added for these runtime observations.
