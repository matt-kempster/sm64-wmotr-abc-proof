# Dust runtime projection

This note records exactly what the checked dust episode does and does not
establish for `VERSION_US` and `VERSION_JP`.

## Source-derived episode

The executable projection decodes the committed `clightgen` initializers for
`bhvMistParticleSpawner`, `bhvWhitePuff1`, and `bhvWhitePuff2`. It also checks
the stock non-terrain list order and the fact that list traversal reloads
`firstObj->next` after `cur_obj_update`, permitting children appended to a later
position in the current walk to execute on that frame.

With accepted dust, normal time, successful isolated allocations, and a clear
active-dust bit, the derived sequence is:

| Order | Frame | Object list | Object/site | Dust-owned `random_u16` calls |
|---:|---:|---|---|---:|
| 1 | `F` | PLAYER | Mario dispatches Mist | 0 |
| 2 | `F` | DEFAULT | Mist spawns WhitePuff1 and WhitePuff2 | 0 |
| 3 | `F` | DEFAULT | WhitePuff1 X, then Z | 2 |
| 4 | `F` | UNIMPORTANT | WhitePuff2 X, then Z | 2 |

Thus the dust-only event trace has exactly four calls on `F`. Each puff's two
calls is a consecutive pair. Pre-existing UNIMPORTANT objects may consume RNG
between the WhitePuff1 and WhitePuff2 pairs. `TTCRNGWindow.v` therefore proves
the more useful exact composition rule: if a certified finite trace contains
`k` non-dust calls before, between, and after the two pairs, the final seed is
`R^(4+k)(seed)`. The special `R^4(seed_before_puff1)` statement still requires
`k = 0`.

TTC spinners are SURFACE objects and update before PLAYER, DEFAULT, and
UNIMPORTANT. A tap on `F` therefore cannot affect the spinner update already
performed on `F`; `F + 1` is the spinner's first subsequent observation
opportunity. This does not say that no other RNG call occurs before that
opportunity. The generated prefixes before spinner 0 and spinner 7 contain 39
and 46 macro records. Their source-derived path budgets, plus the area Thwomp,
give conditional conservative bounds of 80 and 94 non-dust calls. The bounds
retain two premises: a live object/action/timer snapshot must match the prefix,
and every consumer outside that prefix must be certified absent.

## Pool and active-bit boundary

The isolated allocation classes are DEFAULT, DEFAULT, and UNIMPORTANT. The
abstract trace succeeds exactly when `free + unimportant >= 3`. This reserve is
the reserve available to those three operations; a retail proof must also
account for any competing allocations between object-list phases.

Generated TTC level-script and loader receipts now count the source inventory:
110 macro descriptors, 9 area object descriptors, and Mario. Subtracting that
inventory from the 240-slot capacity gives nominal headroom 120 and reduces a
future no-deallocation competitor certificate to at most 117 important
allocations. Descriptor filtering and unexecuted loader paths mean this is not
yet a theorem about the simultaneous live pool at a tap.

`spawn_particle` accepts the request only when Mario's active-dust bit is clear.
The accepted branch sets the bit, and the newly executed Mist script clears it
from its parent. An already-set bit rejects the new spawner and is not treated
as a successful episode. Starting from a clear boundary, the normal-frame
reduction proves that any finite request sequence ends each DEFAULT phase with
the bit clear. A retail trace must still refine its frames to that reduction
and exclude the relevant time-stop cases.

`DustSpawnParticleExecution.v` and its JP companion now give exact generated
Clight big-steps for that accepted caller branch. They load the word at byte
224, take the clear-bit branch, store the ORed word, call
`spawn_object_at_origin(gCurrentObject, 0, 142, behavior)`, and call
`obj_copy_pos_and_angle` on the returned particle and Mario. A separate exact
table conjunct identifies the dust entry's `behavior` as
`bhvMistParticleSpawner`. The callee big-steps and preservation of the stored
active word across them are explicit premises; the proof does not manufacture
an allocation result.

`TTCDebugBoundary.v` now checks one complete finite boundary: exactly 240 pool
slots, 115 free objects, one UNIMPORTANT object, 125 active objects, reserve
116, a set dust request, a clear active-dust bit, and normal time in both
versions. This discharges the abstract pool/flag model for that boundary.
However, its origin is the dormant level-select debug mechanism, its dust is
ordinary walking dust, and its TTC setting is SLOW. The Coq statement includes
those negative provenance facts, so it does not derive the same premises at a
reachable TTC Pedro tap.

## RNG-consumer census and timing receipt

`TTCRNGCensus.v` parses exact generated TTC LevelScript and BehaviorScript
initializers rather than relying on a hand-maintained object list. It computes
the post-PLAYER descriptor roots, scheduler phases, stable behavior/native
closures, all reached direct calls, and the sole reached indirect action-table
dispatch. The selected static scope identifies the Amp, Bob-omb, and hidden
red-coin-star RNG-capable descriptors and proves that `random_u16` is the only
generated function that syntactically writes the file-local seed. The closure
fails closed at the declared external `sqrtf`; no effect contract is silently
assumed for that terminal. `TTCRetailSqrt.v` separately checks the authenticated
US/JP retail leaf bytes and decodes the complete four-word body as
`jr ra; sqrt.s f0,f12; nop; nop`; conservative recognizers find no nested call
or store. This closes the finite retail opcode receipt, not the missing MIPS or
CompCert-external semantics.

The committed debug receipt contains ten contiguous completed `random_u16`
calls: calls 33--37 on `F` and 38--42 on `F+1`. Each frame has one pre-existing
list-2 Bob-omb call followed by two Puff1 and two Puff2 calls. Every entry/return
seed transition is checked, giving five total steps per frame and ten across
the window. The address-to-Bob-omb association is an explicit checked
projection, not a proved linker-map or runtime-to-Clight refinement.

## Clight link boundary

`DustClightLink.v` selects the relevant generated definitions verbatim.
`DustLinkedExecution.v` then places them under the exact generated composite
environment and obtains US/JP witnesses under CompCert's official
`Linking.link`.

`DustBehavior.v` separately executes a source-derived behavior/list model. No
theorem currently identifies the complete model with a Clight big-step of a
retail frame.

The executable frontier is now substantially deeper than the scalar leaf.
`DustLinkedExecution.v`, `DustLinkedExecutionJP.v`, and
`DustWhitePuffExecution.v` execute the exact generated object translation,
both nested `random_float`/`random_u16` calls, and WhitePuff2's timer-zero
native in the linked US and JP environments. `DustBehaviorCommandExecution.v`
wraps that native in the real generated `bhv_cmd_call_native`: the command
loads its function pointer, calls the native, stores seed
`0 -> 57460 -> 55882`, updates X/Z, and advances `gCurBhvCommand` from byte 20
to byte 28. `DustCurObjUpdateExecution.v` then executes one exact surrounding
dispatcher cycle: opcode `0x0C`, `BehaviorCmdTable[12]`, indirect handler call,
result zero, and the generated CONTINUE branch.

`DustParentBitClearExecution.v` also executes the exact generated
`bhv_cmd_parent_bit_clear` function in an arbitrary compatible `genv`. Given
explicit symbol, layout, command, current-object, parent, raw-data, and store
premises, its US and JP
big-steps follow the Mist spawner's parent pointer, clear mask 1 (bit zero) in
Mario's raw-data word at byte 224, prove that bit clear, advance the behavior cursor
from byte 4 to byte 12, and return zero. The initializer words are checked too,
but typed-link instantiation and reaching it from the Mist script are open.

That parent-clear theorem starts from a concrete memory-image premise. It stops
before the following `ADD_INT`, `END_REPEAT`, and `cur_obj_update` tail. The
separate spawn-particle theorems close the caller's accepted branch but do not
derive its two callee executions from object-list traversal or Mario dispatch.
`SegmentedPointerBoundary.v` proves the precise next obstruction against the
exact US/JP generated expressions: on the configured 32-bit target the
pointer-to-unsigned cast preserves a symbolic `Vptr`, while `Oshr` has no
pointer operand case. A full standard-Clight allocation big-step therefore
needs an explicit N64-flat-address/CompCert-pointer refinement or proved
normalization at this seam. Allocation also
requires a CompCert memory realization of the observed free/object list, not
only a runtime row census. Consequently the parent "link and execute" and
reachable-tap checklist items remain open at full retail-frame strength.
