# Rank-4 warp/top relocation and clone audit

## Question and verdict

Rank 4 asks whether a clean execution can move the SSL Area-1 upper warp onto
a standable moving floor, move the pyramid top into that warp, or construct a
second object that retains the top's collision and movement.  Any of those
would let the warp contact and platform selection agree at one useful place.

The stock-source census and one complete original-JP machine execution now
agree on a negative result.  The authenticated zero-A four-pillar route has no
warp relocation, no standable warp, no second top, and no
collision-preserving clone from global timer 348 through 2809.  This closes
the mechanism for that successful route.  It remains a trace-scoped result,
not a proof over every possible controller history.

## Static source boundary

[`Area1WarpTopCloneCensus.v`](../../proofs/Area1WarpTopCloneCensus.v) computes
the following facts from the selected US and JP generated Clight programs:

- the top collision symbol occurs in exactly the `bhvPyramidTop` initializer;
- the only static top-behavior object request is SSL Area 1;
- no native top callback contains a second top request;
- the top creates pillar detectors and fragments, neither of which carries
  the top collision or calls the collision loader;
- normal pose-copy and behavior-script spawn helpers do not copy behavior or
  collision identity;
- allocation resets `collisionData` to null; and
- every direct `Object.collisionData` writer is in a finite 21-function list,
  while the two generic installers contain no embedded top-mesh address.

Those are source-shape facts.  On their own they leave indirect data
provenance, reached callbacks, aliases, allocator epochs, and outside effects
open.  The runtime receipt tests those remaining concerns on the clean route.

## Continuous machine receipt

[`jp-rank4-warp-top`](../../instrumentation/jp-rank4-warp-top/) hash-gates an
original JP ROM, authenticates the relevant retail instruction ranges, and
runs the independent zero-A four-pillar schedule used by the Rank-1 upper-warp
receipt.  The plugin is read-only.  At timer 348 it discovers these live
identities rather than supplying them:

| Role | Object | Pool slot | Behavior | Collision |
|---|---:|---:|---:|---:|
| Pyramid top | `0x803451F8` | 61 | `0x800EBEB4` | `0x8010AAD4` |
| Node-`0x1E` upper warp | `0x80345918` | 64 | `0x800E8AA0` | null |

For each of the 2,462 frames from timer 348 through 2809, the probe scans all
240 object slots.  It rejects a second top behavior, a second top collision
pointer, another node-`0x1E` warp, a changed canonical identity, a top outside
its motion envelope, or a moved/collision-bearing warp.  Cached and uncached
MIPS aliases of the canonical position, behavior, and collision cells are
write-watched.  An execute breakpoint on `load_object_surfaces` checks the
owner and pose at every actual moving-collision installation, which catches a
transient clone even if it appears and disappears between controller polls.

The exact result is:

- 2,462 frames checked and zero failed frame censuses;
- maximum one top behavior, one top collision owner, and one upper warp;
- 2,353 live-top frames and 109 post-top frames, with no resurrection;
- 2,353 top-collision loads, all from canonical slot 61 at a valid pose;
- top envelope `x = [-2087,-2007]`, `y = [1536,1878.07104]`,
  `z = -1023`;
- zero upper-warp position, behavior, or collision writes; and
- zero upper-warp collision loads.

The same execution touches the four pillars at timers 848, 1065, 2390, and
2548, begins the top at 2549, explodes it at 2700, enters the upper warp at
2807–2808, and loads Area 2 at 2830 with no A input.

## The retired slot does not preserve a clone

The write watch found activity that a live-object endpoint scan alone would
hide.  After the top retires, slot 61 is reused three times:

| Timer | First store | Second store | New behavior |
|---:|---|---|---:|
| 2712 | clear collision at `0x802C926C` | install behavior at `0x802C94B8` | `0x800E8AFC` |
| 2743 | clear collision at `0x802C926C` | install behavior at `0x802C94B8` | `0x800E915C` |
| 2775 | clear collision at `0x802C926C` | install behavior at `0x802C94B8` | `0x800E90D4` |

All six identity writes occur after retirement; there is no live-top identity
write.  The allocator clears the top collision before each different behavior
is installed, and none of the replacements later loads the top mesh.  The
additional 134 stores to the recycled slot's position are therefore movement
of unrelated replacement objects, not movement of a top clone.

[`Area1Rank4WarpTopTraceReceipt.v`](../../proofs/Area1Rank4WarpTopTraceReceipt.v)
hardcodes the exact census, lifecycle split, collision-load counts, and warp
write counts.  It packages them with the earlier continuous Rank-1 route
receipt and the generated-source uniqueness/writer census.

## What remains open

The route can still survive inside the selected in-bounds model only if a
different reachable execution breaks the checked boundary: it must create a
second top identity or collision owner, move or retarget the warp, arrange a
collision load through a noncanonical owner, or find a defined alias/outside
effect not connected to the source census.  A universal disproof needs an
induction connecting all reachable spawn, callback, collision-writer,
allocator, and outside-call steps to the static census and the runtime
invariants.

ACE, DMA, out-of-bounds writes, forged pointers, and retail continuation after
source undefined behavior are outside the current CompCert execution model.
They are not disproved by this receipt; if investigated later, the frozen
watch conditions give a precise machine-level success test.
