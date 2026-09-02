# Ranks 13, 13A, 13B, and 18: live copies and upper-warp interactions

## Result

None of these four mechanisms creates a useful position split on the completed
zero-A four-pillar run.  The audit now covers the actual interaction calls,
the entire State-to-Object copy, and the disappearing action's remembered
floor through the final query.  This is stronger than the older checks only
before collision and after the copy.

There is also a separate, general result for Rank 18: selecting the second
Mario-state entry cannot complete the stock copy's first read in the
initialized US/JP Clight programs.  The game allocates only one entry.  This
rules out that specific successful-Clight mechanism, not the rest of Rank 18
and not a retail-machine continuation after an out-of-bounds read.

| Route | What the live run now establishes | What remains |
|---|---|---|
| 13: collision-Object-only writer | All 7,386 collision-coordinate stores are the ordinary three-coordinate copies; each has an immediate correct readback. | Another clean history with a real extra writer, or an all-history preservation proof. |
| 13A: extra terrain/collision-prefix writer | No State/Object coordinate store occurs in the pre-platform prefix or from platform return through collision return.  The platform helper never runs. | Coverage of other reachable clean schedules, receivers, and lifetimes. |
| 13B: later interaction or remembered-floor snap | The accepted warp stops the handler loop.  Three real Y writes merely rewrite 768; no X/Z write occurs after selection.  The same ownerless floor survives through each final query. | A clean acceptance with a useful different floor or a first concrete failure of these conditions. |
| 18: skipped/wrong/redirected copy | All 2,462 copies execute and return with index zero, the real Mario receiver, and exact coordinate stores.  Independently, index one's first read is outside the Clight allocation. | Skipped or redirected copies, changed source/receiver identity, or other transfers on a different history. |

These are not four newly discovered counterexamples.  They reduce the value
of repeating the same route without changing a specific checked boundary.
The atlas keeps the existing overall ranks and family order, but lowers their
current promise to very low on this evidence.

## One execution, not mixed checkpoints

The new mode extends the existing
[Rank-5/5A replay](rank5-state-split-trace.md), using its same controller
schedule and accepted level-select start.  It watches timers **348 through
2809**, inclusive: **2,462 frames**.  The run activates all four pillars and
accepts the upper warp with zero A-down frames, zero A-press frames, and zero
controller-A frames.  No ordinary castle-entry bridge is required.

The extra debugger hooks read registers and memory and observe CPU stores;
they do not install a pose, pointer, action, behavior, or game-memory payload.
The runner demands an exact match with the old Rank-5 receipt as well as the
new checked-in receipt.  Thus the old timing/identity checks and new
copy/interaction checks run together, rather than borrowing compatible-looking
checkpoints from different hypothetical states.

Every frame reaches the action entry, input return, interaction entry and
return, copy entry, actual index decision, and copy return once.  The copy
selects index zero every time.  The three ordered coordinate stores each
occur 2,462 times, with 2,462 immediate correct readbacks.  Mario remains
pool slot 67, the sole active PLAYER-list object with normal `bhvMario`;
`gMarioObject` and `MarioState.marioObj` keep that identity.  The separate
`gMarioState` pointer stays at the real state array.  During every copy,
`gCurrentObject` and all three source coordinates remain unchanged.

The new raw-Object watch spans the action interval too: it is not merely a
post-copy watch or an equality check at the end.  Unexpected or undecodable
stores, wrong-width/component writes, wrong order, missing returns, receiver
failures, and mutations to checked code/dispatch ranges fail the audit.
Reached aliases and outside callees are covered by their actual CPU writes
to these watched addresses on this run.  This does not specify their effects
for every other call or input history.

## Rank 13B: the real warp and floor snap

At timer 2807 the actual interaction-table slot 4 calls `interact_warp` for
the upper-warp object.  Its nonfading branch returns **1**, sets
`ACT_DISAPPEARED`, and makes that warp the used object.  The loop invokes no
later handler.  The full run has 65 interaction-handler calls and 65 returns;
the only accepted upper-warp call is this one.

At timers **2807, 2808, and 2809**, the disappearing action calls the real
floor-height snap and returns zero.  Each snap writes Y=768.  Across all
20 recorded interaction/action/copy snapshots, both State and raw Object
have these exact binary32 values:

```text
X = -2033.87939453125   bits c4fe3c24
Y =   768              bits 44400000
Z = -1037.05859375      bits c481a1e0
```

The stored floor pointer is `0x80195db0`, its cached height is `0x44400000`,
and its moving-object owner is null.  The floor-pointer/height cells and the
selected 48-byte surface receive no write from selection through the final
query.  Each final query returns that same floor.  There are no X/Z stores
in the post-selection interaction/action/copy window and no other Y-store
site in that window.

The distinction matters: **the floor is non-null; the cached platform is
null**.  The previous conditional stock-owner theorem was not claiming that
no floor exists at the warp.  The live floor supplies no moving platform, and
snapping to its existing height supplies no vertical gap.

## Rank 18: a genuine Clight allocation/read theorem

The generated `level_update` units define `gMarioStates[1]`, initialized by
`Init_space 200`.  Other units contain weaker external declarations.  The
proof checks every declaration in the real source unions and transports
the bound to both selected linked programs, including the repaired US target.
It separately resolves the actual `copy_mario_state_to_object` body there.

The copied source prefix is exact: initialize index to zero, increment it
when `gCurrentObject` differs from `gMarioObject`, load the receiver, then
read the selected state's first velocity component.  That velocity read
precedes the first copy store; it is not one of the later position reads.
The function has no stack-allocated local variables, and its real
`function_entry2` rule establishes an empty local-variable environment, so
a local array cannot shadow the global here.

The selected composite layout has a 200-byte `MarioState` and velocity at
offset 72.  Index one therefore requires:

```text
state-array block + (1 × 200) + 72 = block offset 272
```

[ClightAllocationBounds.v](../../proofs/ClightAllocationBounds.v) proves a useful memory fact directly over every
`Clight.step2` constructor: an already allocated block cannot acquire maximum
permissions outside its old bounds.  The proof handles assignments, bitfield
stores, byte copies, allocations, frees, function entry, builtins, and
external calls, then inducts over `Smallstep.star`.  For abstract outside
calls it uses CompCert's existing validity and maximum-permission laws; it
does **not** assume a special no-alias or protected-cell frame for this game.

Consequently, every actual step sequence rooted in `Genv.init_mem` retains
the state global's upper bound of 200.  `Mem.load Mfloat32` at offset 272
returns `None`.  Inverting the **actual generated expression** shows that
its successful evaluation would require that same load to succeed.  The
reached `Sset` therefore has no successful next Clight step when index one
is selected.  The capstone combines the linked-body resolution, exact prefix,
empty-local entry fact, and this no-step theorem.

This proof does not construct the whole game's initialization execution or
translate the accepted IDO endpoint into Clight.  It applies to all actual
Clight steps from initialized memory, independently of this finite replay.
It also does not say the retail processor traps at that address: reading
across adjacent flat-address globals after source undefined behavior is
outside this verdict and needs the separately deferred machine semantics.
Index-zero copies with a different live receiver, skipped calls, and
lifetime/identity changes are deliberately not eliminated by an array bound.

## Authentication and checkpoints

The runner accepts only the original JP ROM with SHA-256
`9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317`.
It authenticates the ROM ranges before execution; at timer 348 the probe
checks their live word hashes and watches both CPU address aliases for writes.
The older Mario behavior/dispatch checks remain enabled too.

| Range | Purpose | Live word-FNV |
|---|---|---|
| `8024c000..8029c3b4` (exclusive end) | Interaction, action, and copy code | `b0b82bed` |
| `8032c9f0..8032cae8` | 31 interaction descriptors | `9c829df6` |
| `803355b4..803357a0` | Cutscene dispatch | `998bbc13` |

The word hashes are runtime readback checks, not cryptographic hashes.
`verify.py` also prints the SHA-256 of each range from the authenticated ROM.
The important instruction addresses are recorded here for reproduction:

| Check | JP instruction address |
|---|---|
| Handler indirect call / return | `80250318` / `80250320` |
| Accepted nonfading warp branch | `8024de6c` |
| Disappeared entry / caller return | `80257794` / `8025d5b4` |
| Cached-floor Y store / readback | `802557c0` / `802557c4` |
| Copy entry / actual index read | `8029c000` / `8029c02c` |
| X / Y / Z copy stores | `8029c0e8` / `8029c118` / `8029c148` |
| Copy return | `8029c30c` |
| Final floor-query return | `802c7f88` |

The debugger, emulator, ROM authentication, store decoder, and transcription
checker remain the finite machine receipt's evidence boundary.  Neither this
receipt nor its Coq arithmetic is a verified MIPS interpreter.  DMA, ACE,
and post-undefined-behavior continuations are not silently added to Clight.

## Reproduction and proof integration

From the repository root, with a legally supplied matching ROM and the same
Mupen64Plus interpreter/debugger dependencies as the Rank-5 probe:

```bash
bash SSL-Coq/less-than-one-a-press/instrumentation/jp-ranks13-18/run.sh /path/to/baserom.jp.z64
```

The command writes a fresh directory beneath the project's ignored
`build/instrumentation/`, requires both exact receipt comparisons, and checks
every new Coq counter, component count, handler count, warp snapshot, and
final-query sample against the observed data.  A standalone transcription
check can reuse a completed receipt:

```bash
python3 SSL-Coq/less-than-one-a-press/instrumentation/jp-ranks13-18/verify_receipt.py /path/to/copy-interaction-receipt.txt SSL-Coq/less-than-one-a-press/proofs/Area1Ranks13To18TraceReceipt.v
```

The five new proof modules are wired into the [build manifest](../../_CoqProject);
[MainTheorem.v](../../proofs/MainTheorem.v)
exports `current_ranks13_to18_copy_interaction_trace_receipt` and
`current_rank18_wrong_index_copy_boundary`.  They intentionally leave the
project's global no-A impossibility theorem unchanged.

Validation on 2026-09-02: the strengthened retail replay reproduced both
receipts exactly; all ten transcription-validator tests passed; the full
active SSL build, proof-hole and link-hygiene checks, both new capstone
assumption audits, and the repository proof-discipline audit passed.  All
twelve edited atlas description sections remain a single paragraph each.
Run the validator's corruption tests with:

```bash
python3 SSL-Coq/less-than-one-a-press/instrumentation/jp-ranks13-18/test_verify_receipt.py
```

The Rank-18 assumption footprint includes the standard classical,
extensionality, and proof-irrelevance foundations plus CompCert's
`external_functions_sem/properties` and `inline_assembly_sem/properties`.
There are no new project-local axioms or admitted proofs.  The external-call
contracts are part of the chosen execution model, not a proof that arbitrary
unmodeled hardware effects obey those contracts.

[Back to the route atlas](../no-a-route-atlas.md#at-a-glance-ranking)
