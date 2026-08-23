# Writable action-table mutation audit

## Verdict

The tables exist and are writable memory, but the checked US and JP source has
no ordinary named controller-driven mutation producer.  Controller state can
only influence which initialized entry gets read.  No named table assignment,
separate explicit address-taking site, or controller-controlled table payload
was found.  This closes the ordinary “press buttons to invoke a table editor”
idea; a complete linked in-bounds disproof still has to exclude a valid alias
or a reached outside routine whose exact effect includes the table.

The audited storage is finite and exact:

| Table | Shape | Size | Normal use |
|---|---:|---:|---|
| `sInteractionHandlers` | 31 mask/handler pairs | 248 bytes | Read a collision mask, then call its matching handler. |
| `sForwardKnockbackActions` | 3 by 3 action words | 36 bytes | Select a forward knockback action. |
| `sBackwardKnockbackActions` | 3 by 3 action words | 36 bytes | Select a backward knockback action. |
| **Total** | 80 four-byte words | **320 bytes** | **Zero bytes written by named ordinary controller operations.** |

“Writable” therefore means that the compiler allocated mutable storage, not
that the game exposes a controller command for editing it.  The source census
finds `sInteractionHandlers` only in `mario_process_interactions` and the two
knockback tables only in `determine_knockback_action`.  The former loads the
mask and handler; the latter chooses terrain and strength indices from
`0`, `1`, or `2` and loads one action.  The generated corpora contain no named
assignment to any of the three tables, and the handler table has no explicit
address-taking site outside its stock value reads.

## What a hypothetical write could do

A producer would be powerful.  Each knockback entry is one four-byte action
word.  Replacing a selected entry with `0x03000888` would make the next
eligible damage or Snufit-style interaction feed `ACT_LONG_JUMP` into the
normal action setter.  The formal payload theorem is general: that one cell can
hold any 32-bit action word.  This is enough for an arbitrary long-jump action
once a damaging interaction that selects the edited cell is actually reached;
it is not arbitrary code execution, and it does not establish the required
collision or trajectory.

Each interaction-handler record is two four-byte words.  The handler pointer
for the coin row is word `1`; the pole handler is word `45`, byte offset `180`.
The checked generated signatures show that stock handlers such as
`interact_snufit_bullet` and `interact_flame` have the same three-argument
function type as `interact_pole`.  Consequently:

- one handler-pointer write could turn an eligible coin or pole collision into
  another stock automatic interaction, such as the burning-action handler;
- two writes—one handler pointer to the Snufit/damage path and one selected
  knockback word to `ACT_LONG_JUMP`—could conditionally turn that collision
  into a long jump; and
- a repeatable arbitrary four-byte writer could in principle edit all 320
  bytes, but no such writer is known.  The proved ordinary controller capacity
  is zero bytes, not 320.

The burning handler normally chooses `ACT_BURNING_JUMP` unless Mario is already
descending in an air action, in which case it chooses burning fall.  The jump
initializer gives `31.5` vertical speed and `8` forward speed.  This makes a
single handler mutation potentially useful, but less general than the
knockback-word route and still subject to the handler's invulnerability, cap,
water, and object-subtype guards.

## Upper elevator and lower pole implications

The Area-2 inventory contains the upper pyramid elevator at `(0,4966,256)`, a
horizontal coin line around `(-210,4521,-994)`, and a vertical flying coin line
around `(290,4479,-940)`.  A coin-row redirection could therefore be relevant
to an upper-route search if one of those coins is reachable at the required
side of the elevator cut.  The inventory alone does not prove that geometry,
timing, or collision order, so this is a conditional consumer rather than a
new no-A route.

The bottom warp is not a zero-A solution by itself: the ordinary continuation
still spends its A press jumping from the second pole.  The lower itinerary
contains poles at `(2867,640,2867)` and `(0,3200,1331)`; the latter is that
familiar jump-off gate.  A pole-row redirection could in principle replace the
normal pole handler with an automatic airborne handler, and the two-word
Snufit-plus-knockback construction could request a long jump.  This makes the
bottom-warp branch the natural fallback if a mutated action needs an
interaction unavailable inside the upper elevator, but it does not yet solve
the route: a mutation present before first contact may prevent ordinary pole
grabbing, a mutation performed after climbing needs a writer and exact timing,
and the redirected action still needs a complete collision and trajectory
replay.  The nearby lower Goomba at `(3263,778,3157)` is a possible native
damage consumer for a knockback-word payload, but reachability and the required
post-hit route are not established.

## What remains

No more controller search for a normal table-write command is warranted.  A
clean in-model counterexample must identify one of these exact producers:

1. a valid, in-bounds pointer alias that evaluates to the private handler or
   knockback-table block and performs an overlapping store; or
2. a reached outside call with an exact effect that writes that block.

If both are excluded along the clean linked execution, table mutation is
disproved for the current CompCert model and the negative-quicksand seed loses
this escape.  Invalid or out-of-bounds stores, ACE, DMA, and continuations after
undefined behavior remain separate retail-machine questions, not unfinished
Clight table producers.

Formal receipts are in
[`WritableActionTableClosure.v`](../../proofs/WritableActionTableClosure.v),
with the previously compiled whole-corpus handler census in
[`InkTimer131CorruptionClosure.v`](../../proofs/InkTimer131CorruptionClosure.v)
and initialized action-flow census in
[`NegativeDepthInteractionClosure.v`](../../proofs/NegativeDepthInteractionClosure.v).
