# JP Rank-4 warp/top identity receipt

This read-only receipt tests Rank 4, “Move the warp/top or create a
collision-preserving clone,” along the authenticated original-JP zero-A
four-pillar route.  It starts at global timer 348, checks every frame through
timer 2809, and includes the pillar touches, top explosion, and upper-warp
entry.  It uses the same controller schedule and accepted level-select entry
boundary as the continuous Rank-1 receipt.

The probe first discovers the stock pyramid top and node-`0x1e` upper warp
from their live objects.  It then fixes their slot addresses, behavior
pointers, and the top's collision-data pointer.  On each of 2,462 frames it
scans all 240 live object slots and requires:

- at most one object with the top behavior and at most one object with the
  top collision pointer, both at the canonical top slot;
- exactly one node-`0x1e` object with the canonical warp behavior, at the
  canonical upper-warp slot;
- the live top to keep the stock collision pointer and remain inside its
  checked motion envelope; and
- the upper warp to remain at `(-2048, 768, -1024)` with null collision data.

Write breakpoints cover the canonical top and warp position, behavior, and
collision cells through both cached and uncached MIPS aliases.  An execute
breakpoint on `load_object_surfaces` checks the owner and pose whenever
moving collision is actually installed.  Thus a transient collision clone
that appeared between controller polls would still be rejected when it tried
to install the top mesh.  The probe contains no API capable of writing game
memory.

The exact receipt has no failed frame or collision-load check.  Slot 61 is
the sole top; slot 64 is the sole upper warp.  All 2,353 top collision loads
belong to slot 61 at a position within `x = [-2087,-2007]`,
`y = [1536,1878.07104]`, and `z = -1023`.  The warp receives no position,
behavior, or collision write and never loads collision.  No second top
behavior, second top collision pointer, or top resurrection occurs.

The trace also exposes a lifecycle detail that an endpoint-only census would
miss.  After the top retires, its slot receives 134 position writes and is
reinitialized three times.  At timers 2712, 2743, and 2775 the stock allocator
first clears `collisionData` at `0x802c926c`, then installs a different
behavior at `0x802c94b8`.  All six identity writes happen after retirement;
there is no live-top identity write, and none of the replacement identities
loads the top collision.  Slot reuse therefore does not create a
collision-preserving clone on this run.

Run the exact check with:

```sh
bash run.sh /path/to/baserom.jp.z64
```

The script hash-gates the original-JP ROM and authenticates the relevant
retail instruction ranges before running.  It then requires the exact
`expected-warp-top-receipt.txt`, the four pillar milestones, the upper-warp
actions, and zero A input.

This closes relocation and collision-preserving cloning for this successful
controller history.  It does not quantify over every input history, prove an
IDO-to-Clight simulation, or cover ACE, DMA, out-of-bounds writes, or
continuation after undefined behavior.  The source-level spawn and
collision-writer census supplies the complementary stock-program boundary;
a universal verdict still needs a linked induction from that census to every
reachable in-bounds execution.
