# Which heights work for crawl and slide Ink?

13 November 2026. **The useful heights form separate windows. Higher is
not always better.** In the original fixed setup, crawl works at every
integer Y from **1741 through 1803**, fails again, then works at every
integer Y from **21778 through 32767**. Butt slide at supplied speed 20
has the slightly narrower first window **1741–1801** and the same high
window. A changed sideways push lowers a demonstrated working start to
**1740**, for both crawl and butt slide. None of these supplied states is
a continuous no-new-A route.

The [receipt](ink-height-map-receipt.json) contains exact recipes, initial
write ledgers, complete retained native traces, integer outcome intervals,
raw-file hashes and source/runtime hashes. The companion
[sliding investigation](ink-slide-handoff.md) treats other actions, actual
entry paths and the important distinction between a slide and slide kick.

## What the height means

Here **main universe** means the actual binary32 movement height in the
half-open bin **−32768 ≤ Y < 32768**, with the ordinary SSL X/Z coordinates.
It is a reporting convention, not a claim that Mario can normally stand
at every such height. The integer survey includes both −32768 and 32767.
The largest representable binary32 in this bin is **32767.998046875**.

M is `MarioState.pos`, C is the collision object's raw XYZ, and D is stored
`header.gfx.pos`. Every supplied start synchronizes M=C=D. The surveyed Y
is the movement Y before the gap-producing update and, in successful
traces, before its ground step: the push changes only X/Z. Afterwards M.Y
and C.Y are 768 while D.Y is the starting Y. The gap is **D.Y−M.Y**, not
the distance from Mario to the top or necessarily the rendered model's
height; floor alignment installs a separate throw matrix.

`find_floor` narrows its floating coordinates to signed 16-bit query
coordinates, but returns the ordinary plane height. It does **not** add a
VPU offset to that answer. For finite values whose float-to-signed32
conversion is valid, the relevant arithmetic description is
`sign16(trunc(binary32(Y)))`. In this work that description is inferred
from the source and checked finite casts; the Wafel frame log is not a
hook on the local query temporary. At 32768 the query wraps to −32768;
the adjacent float below 32768 still queries 32767. Negative fractions
truncate toward zero: −32768.00390625 still truncates to −32768. The
reporting bin and the exact cast preimage are therefore different things.

## Reproducible default fixture

The authenticated 2,548-input four-pillar prefix, including its documented
pre-entry debug level selection, followed by neutral waiting supplies the
native top state immediately before stored timer 130 executes. At this
one cut we supply:

* M=C=D `(-1950,Y,-939)` and existing Crazy Box 49 at `(-1989,Y,-939)`;
* established crawl, action state/timer zero, forward speed 5, velocity
  `(4,0,0)`, facing `0x4000`; or established butt slide, speed/velocity 20
  toward +X, `slideVelX=20`, `slideVelZ=0`, `slideYaw=0x4000`;
* one Z-held stick `(0,64)` update, followed by neutral inputs, all A-off.

The actor's remaining fields are inherited. There are no floor-cache,
platform, surface, top-timer, RNG, allocator or mid-continuation position
edits. Inherited cached floor height before execution is 1024; the native
geometry preparation refreshes the cache. Successful producers retain
floor 768 after the push. The slide study also tests neutral first input;
its separate input policy must not be silently substituted for this one.

The exhaustive integer menu screens the intended installation: producer
at behavior 130, accepted warp and top capture at behavior 131, then
neutral continuation to Area 2 within 32 updates. A failed immediate
capture stops that survey trial after two updates. Thus its negative
labels exclude **that specified immediate handoff**, not arbitrary later
controller continuations. Sixteen retained controls separately continue
up to 32 updates even after a failed capture; none of those negative
controls produces a later top capture or useful arrival.

## Integer windows and tested float boundaries

Each default integer row below checks every integer in its declared bin,
separately for each action. The listed windows contain all immediate
useful successes in that finite menu. Both integer endpoints are included.

| Action/setup | Actual Y menu | Successful integer Y | Useful successes |
| --- | --- | --- | ---: |
| Crawl, default | −32768…32767 | 1741…1803; 21778…32767 | 11,053 / 65,536 |
| Butt slide speed 20, default | −32768…32767 | 1741…1801; 21778…32767 | 11,051 / 65,536 |
| Crawl, default +65536 bin | 32768…98303 | 67277…98303 | 31,027 / 65,536 |
| Butt slide speed 20, same bin | 32768…98303 | 67277…98303 | 31,027 / 65,536 |
| Crawl, lower alternative below | 1600…2000 | 1740…1795 | 56 / 401 |
| Butt slide speed 20, lower alternative | 1600…2000 | 1740…1794 | 55 / 401 |

Adjacent binary32 boundary probes sharpen the default setup:

| Boundary | Working value | Immediately neighboring failing value |
| --- | ---: | ---: |
| First window begins, both | 1741 | 1740.9998779296875 |
| Crawl first window ends | 1803.9998779296875 | 1804 |
| Butt speed-20 first window ends | 1801.9998779296875 | 1802 |
| High window begins, both | 21777.658203125 | 21777.65625 |
| Main bin ends, both | 32767.998046875 | 32768 |
| +65536 bin begins working, both | 67277 | 67276.9921875 |
| +65536 bin ends, both | 98303.9921875 | 98304 |

The loading threshold was located with a binary32 bit-index bisection
inside the one-unit bracket. These are adjacent tested endpoints plus
exhaustive integer results, **not an enumeration or Coq proof of every
fractional interior value**. The working maximum within our main-bin
convention reaches its largest possible binary32 member; it is not a
global physical height limit. The corresponding observed useful gap is
**31999.998046875**. The minimum start and maximum gap answer different
questions, and changing a setup changes its boundaries.

The first upper cutoff changes with speed: selected butt-slide probes
at speed 5 still work at 1803, speed 10 works at 1802 but fails at 1803,
and speed 40 fails already at 1800. Crawl's analogous speed probes also
change the upper cutoff. These are finite neighboring examples, not a
complete speed map. Different quarter-step X/Z destinations select the
top sooner; action names alone do not determine the height interval.

## Why there is a hole between working windows

At Y1740 the default setup creates a 972-unit gap and the warp is accepted,
but the graphical retry chooses the static roof at 1280, not the top.
Continuing it reaches ordinary Area-2 `(0,5500,256)`. At Y1741 the retried
integer query is high enough to select top height **1818.9613037109375**.
The 78-unit floor allowance is material here: 1818.9613−78 is about
1740.9613, but the query has already been narrowed to an integer.

At Y1804 for crawl, or 1802 for the tested speed-20 butt slide, the
quarter-step can select an upper face rather than remain stopped. The
gap disappears; the producer ends on/near the top instead of at the low
warp. At much higher loaded-top heights, the fresh initial floor itself
is the upper face, **1914.344482421875** at the original pad coordinates.

The no-ceiling sentinel is 20000. Y19840 makes raw `Y+160 >= 20000`, so
the quarter can stop even without a real ceiling. That alone is
insufficient: with the top still loaded, alignment snaps to cached
1914.3445, not 768. The large resulting gap misses the low warp.

At **21777.658203125**, native top collision stops loading in the first
update. The immediately lower float still loads six surfaces; this float
loads zero. The actual top center in this update is
`(-2047,1778.071044921875,-1023)`, and its loader tests full 3-D distance
against 20000. Now initial geometry keeps the low pad at 768; the sentinel
stops the attempted step and alignment makes the desired low snap.
On the next update C is low again, all six top surfaces load, and the
high graphical retry captures that ordinary local top. This explains
the second window without pretending that the whole mechanism repeats
every 65536 units.

## A less demanding working setup

The radial search found four Y1740 recipes. One has these exact native
binary32 starting coordinates:

* Mario M=C=D `(-1946,1740,-927.7393798828125)`;
* Crazy Box `(-1994.79541015625,1740,-927.7393798828125)`.

The proposal used decimal Z −927.7393837993109 and separation
48.79543149877509; the ledger records the requested writes and the initial
snapshot records their actual binary32 values. No floor is supplied.

| Completed boundary | Native result, for both crawl and butt slide |
| --- | --- |
| Global 2681, stored top 131 | M=C `(-1887.79541015625,768,-927.7393798828125)`; D has the same X/Z and Y1740; gap **972**; floor 768; six top surfaces. Crawl remains crawl; butt slide becomes ground bonk. |
| Global 2682, stored top 132 | Accepted disappeared action `0x1300`, argument `0x40001`, used object 64; M=C=D Y**1817.717529296875**; floor owner/platform 61. |
| First completed Area 2 | `(365.5927734375,5500,-1096.8026123046875)`, outside the elevator rectangle. |

The previous binary32 height **1739.9998779296875** fails immediate top
capture. This lowers the observed minimum to 1740, not to a universal
minimum. All 401 integer heights 1600–2000 were checked at this one
alternative: crawl works at 1740–1795; butt speed 20 at 1740–1794.
The supplied high state is still inside the cap region in the low-height
witnesses; no collision-free approach has been established.

The broader variation menu tests **15,912** cases: 13 phases
96/112/120/124/128/129/130/131/132/136/140/144/148, four starting X/Z pairs,
three box separations, Y1200–2200 in steps of 20, both actions. Five
successes per action occur at phase 130. A further **5,880** lateral
crawl recipes at Y1740 find none; a **5,760** radial menu finds the four
Y1740 successes; **10,800** more precise warp-rim proposals at Y1739
find none. These are finite menus, not a geometric lower-bound proof.

Timing remains independent of height. At Y32767, supplied phases
128/129/131/132 all accept and capture the top, retain the platform during
the observed Area-1 continuation, yet arrive at ordinary `(0,5500,256)`.
The tested phase-130 state gives the useful displaced arrival. A platform
pointer and a big gap do not by themselves establish the payoff.

## What repeats in VPUs, and what does not

The +65536 integer bin is simpler than the main bin: both default actions
work at every tested integer from **67277 through 98303**. In particular,
the main-universe failure Y2000 becomes a success at Y67536: the top is
initially unloaded there, and the raw ceiling-sentinel comparison stops
the step. The main narrow low window is not the full repeated pattern.

The representative VPU menu checks 31 base heights for each action at
offsets **−131072, −65536, 0, +65536, +131072, +524288, +8388608**:
434 cases. Y132813, 526029 and 8390349 reproduce the successful alias1741
handoff. Y−63795 and −129331 also have integer alias1741, but their raw
positions trigger an earlier death-related action and end at Y−11100;
neither produces this handoff. No negative-offset success occurs in that
menu. This is not a theorem about all negative VPU states.

Float precision also matters. A requested start **16778957**
(1741+256×65536) rounds to actual binary32 **16778956**, whose alias is
1740: the gap occurs but the retry chooses static roof1280. Requested
**16778958** is representable, aliases1742 and completes the useful
handoff for both actions. Its observed gap is **16778190**, the largest
useful gap sampled here; it is not a global bound.

For exactly represented integer Y and offsets within the supported
conversion range, adding integer multiples of 65536 preserves the
signed16 query value. General fractional shifting requires more care:
truncation toward zero need not commute with crossing zero (−0.5 maps
to0, whereas 65535.5 maps to−1), and binary32 addition can round. Neither
the integer arithmetic identity nor the finite tests provide an
all-float, all-offset gameplay theorem; casts outside the signed32
conversion range are not justified here.

Even when a floor query aliases, the raw actor and warp hitboxes, dynamic
collision range, Mario action/cancellation, ceiling sentinel, platform
selection and timing do not automatically repeat. `find_ceil` also narrows
coordinates, but the relevant wrapper queries at **returned floor+80**,
not raw high M.Y. That returned floor remains local. Walls additionally
use raw float positions for their actual wall-list tests.

All positive height cases supply the box at the same actual high Y as
Mario. Leaving the native actor at its old location removes the required
push: selected ordinary/high/VPU no-actor controls fail top capture.
The earlier conditional HOLP/throw demonstrations in
[ink-pu-vpu.md](ink-pu-vpu.md) remain useful components, but they supplied
high HOLP/holding and the high crawler. This height map does not supply
an allowed item-delivery history.

## Reproduction and evidence limits

The initial fetched proof revision was
`c862841fcd6ddf00356029b45d5693772b309603`; existing local entry, top-slide
and walking-edge work was inspected and preserved separately. The
receipt also records the later preservation commit present while this
work ran. The decompile is
`36fbf8d693a9fc2bdec0c77402f8e96d07d2f461` with local changes, compared by
the overall investigation against stock
`9921382a68bb0c865e5e45eb594d9c64db59b1af`. Tests use pinned Wafel0.8.5
JP DLL SHA256
`960fe979068b78e6733b3ddb87741833fbf4eb29b2a21a2bba871977427c2d0f`.
These are native supplied-state execution results, not a new original-ROM
replay or a Coq theorem about height intervals.

From `SSL-Coq/less-than-one-a-press`, use the existing embedded Python and
fresh output filenames. The modes preserve their complete recipe menus:

```powershell
& ./build/wafel-pilot/python/python.exe instrumentation/wafel-jp-pilot/ink_height_map.py build/wafel-pilot/NEW-main.json --mode integer
& ./build/wafel-pilot/python/python.exe instrumentation/wafel-jp-pilot/ink_height_map.py build/wafel-pilot/NEW-vpu1.json --mode integer --first 32768 --last 98303
& ./build/wafel-pilot/python/python.exe instrumentation/wafel-jp-pilot/ink_height_map.py build/wafel-pilot/NEW-vpu.json --mode vpu
& ./build/wafel-pilot/python/python.exe instrumentation/wafel-jp-pilot/ink_height_map.py build/wafel-pilot/NEW-variation.json --mode variation
& ./build/wafel-pilot/python/python.exe instrumentation/wafel-jp-pilot/ink_height_map.py build/wafel-pilot/NEW-radial.json --mode radial --actions crawl
& ./build/wafel-pilot/python/python.exe instrumentation/wafel-jp-pilot/ink_height_map.py build/wafel-pilot/NEW-radial-dense.json --mode radial-dense --actions crawl
& ./build/wafel-pilot/python/python.exe instrumentation/wafel-jp-pilot/ink_height_map_verify.py docs/notes/ink-height-map-receipt.json --replay
```

The original integer scans used next-update used-object/floor/platform
checks; an offline check verifies every positive also has disappeared
action, exact useful arrival and retained platform. The final retained
traces additionally require action argument0x40001. Their initial edits,
all subsequent inputs and native samples reproduce exactly in a fresh
game: the final validator passes **145 retained records / 2184 updates**
(144 distinct initial-state/input histories; one positive control repeats).
Historical raw files stay in ignored build output; the receipt
records their hashes and the final script hash. Changed reporting fields
and stronger checks do not alter setup writes or controller execution.

No local-query return or quarter-return hook was added: source deductions
explain the observed outcomes, and stock frame events show action and
movement-step order. The event field called `_placeholder` is retained
for equality checking but is not interpreted as a quarter-step result.

The route assessment remains open. The useful next experiment is a
continuous no-A transition into one of these established ground actions
at a working raw height, with a delivered actor, a refreshed low cache,
and phase130 still available. Repeating a height alone does not address
those prerequisites. Rank1 **1–2%** and Ink Rank2 **<1%** remain subjective
estimates, unchanged by these conditional successes.
