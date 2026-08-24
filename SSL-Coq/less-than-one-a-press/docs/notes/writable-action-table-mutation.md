# Writable action-table mutation audit

## Verdict

The tables exist and are writable memory, but neither the complete decompiled
game nor the checked US/JP CompCert corpus contains a defined first producer
for a mutation.  The pinned 431-file source tree names all three tables in
only `src/game/interaction.c`.  The formal audit then checks every one of the
38 modeled translation units per version: each table has its expected private
definition, no global initializer stores any table address, no public-symbol
list exports one, and the only function-body occurrences are four complete
terminal reads per version—two handler fields and one word from each knockback
table.  No occurrence stores, returns, or hands off a table address.  The
linked programs contain three real valid table blocks.  The formal proof now
constructs a filtered identity injection at every successful selected-program
initialization: every ordinary named global maps to itself, while precisely the
three table blocks are omitted.  It carries that same growing relation through
stores, byte copies, allocation, freeing, abstract outside calls, and finite
actual Clight executions.  The reached-step theorem now classifies every
selected `Clight.step2` constructor, including the four legitimate terminal
reads, and preserves every table byte from the exact initialized task start
through every finite successful in-bounds US/JP run.  Thus this route has no
defined producer in the selected CompCert model.

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
`0`, `1`, or `2` and loads one action.  This matters because the former
assignment checker recognized only a whole-global left side and could have
missed `table[i] = value`; the new occurrence-sensitive checker explicitly
rejects that array-element shape and still accepts the entire US and JP
corpus.

## Why an outside call cannot be the first writer

CompCert pointers contain an allocation-block identity, not merely a flat
numeric address.  The three tables are private to `interaction.c`, are absent
from that unit's public-symbol list, and are not named by an initializer
relocation.  A proof can therefore use a self-injection that maps all ordinary
live values to themselves while deliberately leaving the three table blocks
unmapped.  A store address related to itself by that injection cannot be a
pointer into an omitted table block.

CompCert requires every abstract external call to respect memory injections.
Applied to the private self-injection, this rule says that the call leaves
every byte of each omitted block unchanged.  It also cannot return a table
pointer: extending the injection may map newly allocated blocks, but
`inject_separated` forbids it from newly mapping an already-valid omitted
block.  Since an injected copy of the same call has the same trace, external
call determinism identifies its result and memory with the original call;
the extended private injection therefore remains available after the call.
This argument covers every CompCert abstract external at once and does not
depend on guessing which sound, math, or debug routine happens to be reached.

The initialization construction is not an assumption about a convenient
snapshot.  It is derived from the selected linked program's successful
`Genv.init_mem`: the whole-game initializer census proves that no initialized
word contains a table address, the export census proves that no omitted table
is public, and the linked-symbol proof resolves all three omitted blocks and
proves them valid.  CompCert's initialized-byte argument is replayed with this
filtered identity injection, so all non-table initialized bytes inject into
themselves while the table blocks remain private.

For live execution, each successful memory-changing primitive has an explicit
carrier.  A normal store must supply a self-injected address and value; a byte
copy must supply a self-injected destination and bytes; a fresh allocation
grows the injection with its new block; a free must name an already mapped
non-table block; and an outside call must receive self-injected arguments.  The
outside-call theorem returns the actual monotone extension of the incoming
injection rather than an unrelated existential witness.  These carriers
compose over an actual finite `Clight.step2` run, starting from the exact
initialized memory, and yield both the final private relation and a byte frame
from start to finish.  A one-step dichotomy identifies the first actual step
that cannot be put in one of these classes.

## Whole-game aliases and cross-level lifetime

“Stored alias” here means any persistent pointer derived from one of the three
table addresses: a global initializer, exported name, saved local value,
returned value, call or builtin argument, or another nonterminal expression
that could later feed a write.  The full decompiled source audit at commit
`36fbf8d693a9fc2bdec0c77402f8e96d07d2f461` finds the three names in exactly
one of 431 files, `src/game/interaction.c`; there is no header declaration or
second translation-unit naming site.  The stronger generated-AST receipt
checks the modeled 38-unit US and JP corpora rather than relying on text: it
rejects every initializer and export alias, and its occurrence classifier
accepts only the four final reads.  The handler reads yield a stock handler
function pointer, not a pointer back into the table, while the knockback reads
yield ordinary action integers.  Thus no persistent in-bounds source alias is
present before SSL or created elsewhere in the modeled game.

The lifetime answer is conditional but useful: if some separate mechanism did
mutate a table after engine startup, the edit would carry into SSL Area 1 and
Area 2.  These are engine globals, not level-pool objects.  The decompiled boot
path calls `load_engine_code_segment()` once from `main.c`, whereas
`clear_objects`, `clear_areas`, `load_area`, `unload_area`, `change_area`, and
`level_trigger_warp` do not reload or name the tables; the US/JP Clight receipt
checks those transition bodies directly.  Consequently cross-level carryover
would make a genuine producer valuable for either the upper-elevator or lower-
pole route, but carryover does not create the first write.  DMA, arbitrary code
execution, out-of-bounds flat-address writes, or execution after C undefined
behavior remain separate retail-machine extensions.

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

## Scope and reopening condition

The in-model search is closed: the proof classifies each actual next step as
memory-preserving, a private-safe store or copy, allocation or free of a mapped
non-table block, a framed outside call, or one of the four stock terminal
reads.  Reopening it requires a concrete counterexample to the accepted
initialized task start, selected linked-program provenance, or one of those
semantic cases—not another free-form controller, stored-alias, or per-callee
search.  Invalid or out-of-bounds stores, ACE, DMA, and continuations after
undefined behavior remain separate retail-machine questions, not unfinished
Clight producers.

Formal receipts are in
[`WritableActionTableClosure.v`](../../proofs/WritableActionTableClosure.v),
with the occurrence-sensitive and abstract-external closure in
[`WritableActionTableAliasExternalClosure.v`](../../proofs/WritableActionTableAliasExternalClosure.v),
the whole-game initializer/export, linked-block, transition-lifetime, and
first-failure receipts in
[`WritableActionTableWholeGameAliases.v`](../../proofs/WritableActionTableWholeGameAliases.v),
the filtered initialization construction in
[`WritableActionTablePrivateInitialization.v`](../../proofs/WritableActionTablePrivateInitialization.v),
and the primitive, outside-call, and actual-Clight-run carrier in
[`WritableActionTablePrivateLive.v`](../../proofs/WritableActionTablePrivateLive.v),
the sharded whole-source syntax receipts beginning with
[`WritableActionTableSyntaxBase.v`](../../proofs/WritableActionTableSyntaxBase.v),
the expression and four terminal-read semantics in
[`WritableActionTableExpressionCoverage.v`](../../proofs/WritableActionTableExpressionCoverage.v)
and
[`WritableActionTableTerminalReads.v`](../../proofs/WritableActionTableTerminalReads.v),
and the exhaustive reached-step and finite-run capstones in
[`WritableActionTableClightStepCoverage.v`](../../proofs/WritableActionTableClightStepCoverage.v)
and
[`WritableActionTableReachedExecution.v`](../../proofs/WritableActionTableReachedExecution.v),
with the previously compiled whole-corpus handler census in
[`InkTimer131CorruptionClosure.v`](../../proofs/InkTimer131CorruptionClosure.v)
and initialized action-flow census in
[`NegativeDepthInteractionClosure.v`](../../proofs/NegativeDepthInteractionClosure.v).
