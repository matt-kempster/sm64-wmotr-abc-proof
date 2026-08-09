# JP destination chronology certificate

`proofs/JPDestinationChronologyCertificate.v` separates the part of the
timer-131 stale-top chronology that can already be checked in the Rocq kernel
from the linked execution that is still missing.

The checked part uses the composite environment of the official cleaned JP
link.  It proves that `struct Object` is 608 bytes, so observed pool slot 61
starts at pool-relative byte offset `61 * 608 = 37088`.  The twelve
fixture-designated payload-witness ranges are within that same object.  They
span relative offsets `[160,288)`, hence the absolute pool range
`[37248,37376)`.  Extracting the complete generated
`apply_platform_displacement` access set and proving it equals this list is
still open.

The complete cleaned JP declaration census also proves that exactly one
retained definition is named `_gObjectPool` and that it is a writable,
nonvolatile
`Init_space 145920` global; the weak incomplete-array declaration has been
removed by the cleaner.  For any block ultimately assigned to that global,
the watched pointer is exactly `Vptr block (Ptrofs.repr 37088)`.  The remaining
`JPLinkedObjectPoolInitialMemoryObligation` deliberately asks for the concrete
official-link `find_symbol`/`find_var_info` witness and writable slot range.
Whole-link reduction did not finish within the verification resource bound,
so this memory witness is not claimed.

The allocation theorem is conditional on the exact chronology reported by the
hash-gated trace: the released top is placed behind 131 teardown pushes and
the destination performs 84 allocations before the true first apply.  With a
duplicate-free free list, none of those 84 allocations can select the watched
slot and the top remains at depth `131 - 84 = 47`.  A separate frame theorem
shows that allocator writes confined to the selected 84 slots preserve the
watched slot's payload.

This is stronger than merely checking the subtraction `131 - 84`: it proves
the non-alias consequence for an abstract duplicate-free LIFO list and fixes
the exact linked object layout and payload range.  It is not yet a linked
Clight chronology certificate.  The project still has to extract the 131
pushes and 84 pops from one concrete small-step execution, resolve the checked
declaration to the concrete official-link initial/current-memory block, bind
the loaded pointer to its slot epoch, prove the intervening terrain/update
frame conditions, and execute the true first apply's loads and binary32
displacement.  Until those steps are complete, the observed
early-free depth and payload remain authenticated runtime evidence plus a
conditional formal theorem, not a retail-semantic counterexample.
