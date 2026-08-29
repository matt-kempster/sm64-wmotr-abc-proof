# Rank-5/5A intra-frame State-split trace

## Question and verdict

Rank 5 asks whether anything changes MarioState or Mario's raw collision
Object after `copy_mario_state_to_object`, leaving a split for the next
collision query.  Rank 5A asks whether the cached moving-platform update makes
that split just before collision.  These are adjacent parts of one frame, so a
single continuous audit is stronger than two controller-boundary samples.

Both mechanisms are absent from the checked successful route.  Across 2,462
original-JP updates, every Mario copy returns with the intended receiver and
equal State/Object coordinates, nothing writes either coordinate view in the
post-copy tail or the next pre-apply prefix, every cached-platform apply loads
null, and State and Object are equal at every checked collision entry and
return.  State, Object, and Graphics are unchanged during apply, and all three
views are equal at the three upper-warp apply entries.  This closes Ranks 5
and 5A for this clean zero-A four-pillar history, not for every possible
controller history.

## Reused source boundaries

The machine trace complements rather than replaces the generated-source
proofs:

- [`Area1PostCopyTailClassification.v`](../../proofs/Area1PostCopyTailClassification.v)
  proves that a faithful copy followed by a split must contain a genuinely
  value-changing tail edge or a classified receiver, lifecycle, alias,
  outside-effect, or scheduler residual.
- [`Area1PostPlayerTailSource.v`](../../proofs/Area1PostPlayerTailSource.v)
  fixes the post-PLAYER list suffix and finds no direct named Mario-coordinate
  writer in the fixed traversal, unload, final-query, and top-level bodies.
- [`Area1PlayerListTailClosure.v`](../../proofs/Area1PlayerListTailClosure.v)
  places Mario's normal particle and debug children on non-PLAYER lists.
- [`Area1PostCopyObjectWriterClosure.v`](../../proofs/Area1PostCopyObjectWriterClosure.v)
  reduces direct designated-Mario raw-coordinate writers to three families;
  the only post-copy candidate is the butterfly writer.
- [`Area1ButterflyStaticOriginClosure.v`](../../proofs/Area1ButterflyStaticOriginClosure.v)
  excludes the butterfly from normal SSL Area-1 object origins.
- [`Area1PostCopyAliasCallbackClosure.v`](../../proofs/Area1PostCopyAliasCallbackClosure.v)
  classifies the direct receiver-taking raw-coordinate APIs and the normal
  destinations of the post-copy particle/debug spawn chains.
- [`Area1PrecollisionWriterClosure.v`](../../proofs/Area1PrecollisionWriterClosure.v)
  verifies the terrain/apply/collision source order and shows conditionally
  that an effective platform apply is State-only.
- [`Area1InstallerTemporalClosure.v`](../../proofs/Area1InstallerTemporalClosure.v),
  [`JPLinkedPlatformGlobal.v`](../../proofs/JPLinkedPlatformGlobal.v), and
  [`LinkedPlatformLineageSyntax.v`](../../proofs/LinkedPlatformLineageSyntax.v)
  classify stock platform-pointer origins, the final-query store, and the
  later apply load.

Those results deliberately leave live receiver identity, deeper aliases,
reached indirect callbacks, outside callees, slot reuse, and exact phase
execution open.  A machine write watch covers all reached CPU code on this
one history without assuming which source function owns a store.

## Authenticated execution

[`jp-rank5-state-split`](../../instrumentation/jp-rank5-state-split/) first
applies the existing original-JP ROM hash and 2,200-instruction Rank-1 gate.
It additionally authenticates 228 instructions containing:

| Retail body | Range | Words | SHA-256 |
|---|---:|---:|---|
| `copy_mario_state_to_object` | `0x8029C000..0x8029C24C` | 147 | `1b6bc8cbc44ecee6df9bbca1dfd63c5a8607591f750e6a71527b016d0f080e1d` |
| `bhv_mario_update` | `0x8029C2D8..0x8029C3B4` | 55 | `259fca83d0157fa13d422a89523fee458cdc2a5b575f909970f171223a4d9fc4` |
| `apply_mario_platform_displacement` | `0x802C83F0..0x802C8458` | 26 | `f8d35fe38b8986037d5d45a8d97548682435d921bafcc60d5a6e496b933e1d78` |

The read-only plugin contains no game-memory write API.  It follows the same
controller schedule as the continuous Rank-1 and Rank-4 receipts: timers 348
through 2809, pillar touches at 848, 1065, 2390, and 2548, upper-warp contact
at 2807, disappeared action at 2808, and Area-2 load at 2830.  No A edge, held
A state, or controller A input occurs.

## Phase chronology and protected cells

The trace state machine observes these authenticated boundaries on every
update:

| Phase | Retail checkpoint |
|---|---:|
| Update entry | `0x8029CF08` |
| Cached-platform apply entry | `0x802C83F0` |
| Conditional displacement-helper call | `0x802C8438` |
| Apply caller return | `0x8029CFC8` |
| Collision entry / caller return | `0x802C8C44` / `0x8029CFEC` |
| Mario-copy return | `0x8029C30C` |
| Mario callback epilogue | `0x8029C3A4` |
| Post-nonterrain / post-unload | `0x8029D010` / `0x8029D034` |
| Final platform-query return | `0x8029D058` |

The write breakpoints cover both MIPS RAM aliases of:

- MarioState XYZ at `0x80339E3C..0x80339E48`;
- slot-67 raw Object XYZ at `0x803460D8..0x803460E4`;
- slot-67 Graphics XYZ at `0x80346058..0x80346064`;
- `gMarioPlatform` at `0x8032FED4` and slot 67's platform field at
  `0x8034624C`;
- `gMarioObject`, `MarioState.marioObj`, slot-67 liveness, behavior and list
  links, and both list-0 sentinel links; and
- the `bhvMario` command bytes and behavior-command dispatch table.

At each copy return, the audit also checks that `gCurrentObject`,
`gMarioObject`, and `MarioState.marioObj` all identify live pool slot 67, that
slot 67 is the sole list-0 object with normal `bhvMario`, and that State and
raw Object XYZ are bitwise equal.  Thus a transient alias, callback, outside
callee, or lifecycle store cannot hide merely by being repaired before the
next controller poll.

## Exact receipt

All expected per-frame phase counts are 2,462, with zero phase-order failures.
The result is:

- zero identity failures, identity writes, behavior/dispatch writes, wrong
  copy receivers, skipped copy returns, or State/Object mismatches;
- zero State or raw-Object XYZ writes after the copy and zero such writes in
  the next frame's pre-apply prefix;
- zero non-null cached-platform apply entries, invalid owners, or helper
  calls;
- zero State, Object, or Graphics changes or writes during apply, and zero
  protected-coordinate writes from apply return through collision-detection
  return; State and Object are equal at both checked collision boundaries;
- exactly 2,462 global platform-cell writes and 2,462 matching Object-field
  writes, all zero and all from four expected retail clear instructions; and
- zero unexpected or nonzero platform-cell stores, plus zero undecoded or
  ambiguously valued watched stores.  The decoder covers the ordinary,
  left/right, coprocessor, conditional, and 64-bit MIPS store forms and fails
  the invariant if a watched store cannot be classified exactly.

The platform-writer breakdown is:

| Writer | Meaning | Count |
|---:|---|---:|
| `0x802C8048` | Clear global pointer for an ownerless floor | 2,130 |
| `0x802C8054` | Clear Mario Object's platform field for that floor | 2,130 |
| `0x802C7FEC` | Clear global pointer after the distance check | 332 |
| `0x802C7FF8` | Clear Mario Object's platform field after that check | 332 |

No owner-store instruction (`0x802C8028` or `0x802C8040`) executes.  At apply
entries 2807, 2808, and 2809, `gMarioPlatform = 0`, `gTimeStopState = 0`, and
State, Object, and Graphics all have the exact binary32 words
`c4fe3c24:44400000:c481a1e0`, representing approximately
`(-2033.87939453125, 768, -1037.05859375)`.  The displacement helper remains
unreached.

[`Area1Rank5StateSplitTraceReceipt.v`](../../proofs/Area1Rank5StateSplitTraceReceipt.v)
hardcodes the exact totals and keeps two verdicts separate: Rank 5 has no
post-copy escape on the chosen trace, while Rank 5A has no pre-collision
platform origin on that trace.  Its capstone conjoins those machine facts with
the reusable source classifications without claiming an IDO-MIPS-to-Clight
simulation.

## What remains open

For Rank 5, a different clean history must expose the first post-copy
State/Object write, wrong copy receiver, extra PLAYER object, alias, outside
effect, slot reuse, failed return, or abnormal scheduler edge and preserve the
split until collision.  For Rank 5A, it must produce a non-null cached pointer
from a live valid owner, preserve that pointer to apply, supply the exact
useful payload, and reach collision before resynchronization.  The existing
conditional displacement theorem still proves that such a Rank-5A payload
would work; this trace disproves only its clean origin here.

A universal in-model disproof needs either the same protected-memory invariant
for every materially different reachable controller history or a linked
execution induction that connects all frames to the source classifications.
ACE, DMA, out-of-bounds writes, forged pointers, and retail continuation after
source undefined behavior remain outside the current CompCert execution
model.

## Reproduction

From `SSL-Coq/less-than-one-a-press` in the WSL environment containing
Mupen64Plus and its development headers:

```sh
bash instrumentation/jp-rank5-state-split/run.sh \
  /path/to/authentic/baserom.jp.z64
```

The runner authenticates the ROM and instruction ranges, rebuilds the
read-only plugin with `RANK5_STATE_SPLIT_AUDIT=1`, replays the route, checks
the milestones and zero-A result, and byte-compares the output with
`expected-state-split-receipt.txt`.
