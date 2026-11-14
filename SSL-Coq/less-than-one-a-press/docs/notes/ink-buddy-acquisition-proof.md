# Buddy acquisition: what the new Coq guard establishes

14 November 2026. **A remembered Buddy conversation pointer is not enough to
pass the real grab selector.** If the live Mario input word does not contain
`INPUT_INTERACT_OBJ_GRABBABLE` (`0x0800`), the complete generated
`mario_check_object_grab` body returns false without any memory write or
external trace. This is a local execution theorem, not a proof that every
controller history fails to acquire Buddy.

The work starts from proof revision
`49807c387f90e29856e2ae34a656f9394137ec19`, using the existing generated US/JP
Clight and selected program environments; the gameplay request concerns JP.
The [source audit](ink-buddy-acquisition-source.md) records the stock JP pin
and the five actual generic-grab callers. The
[combined verdict](ink-buddy-acquisition.md) and
[controller experiment](ink-buddy-acquisition-runtime.md) give the separate
gameplay evidence.

`proofs/InkBuddyAcquisition.v` is registered in `_CoqProject` and exported as
`MainTheorem.current_ink_buddy_acquisition_boundary`. Its new theorem,
`iba_selector_without_grabbable_returns_false`, uses these exact premises:

- The function's `m` parameter identifies Mario storage at offset zero.
- A `Mint16unsigned` load of the actual MarioState input field, offset 2,
  yields the stated input word. The selected composite layout is checked.
- ANDing that word with 2048 yields zero.
- The actual generated function body executes in the selected Clight global
  environment, with its empty local-variable environment.

The conclusion is return value zero of type `tuint`, an empty trace and
equality of the entire before/after memories. It does not assume a value for
`usedObj` or `heldObj`: neither is read on this path. In particular, retaining
Buddy in `usedObj` does not bypass the guard.

The proof also constructs the call-free, store-free path directly from the
input load in `iba_no_grabbable_path`. It does not assume that the branch was
skipped or that its memory writes were harmless. The source shape is checked
against each version's generated body. The universal execution result then
uses the existing read-only-path uniqueness theorem and the actual return
statement. Only the small function and checked layouts are reduced; the
whole generated program is not computed.

The exported boundary combines this new result with the existing
`ibm_pickup_actions_cannot_pass_npc_readiness` theorem. That theorem proves
the actual readiness helper returns false for PICKING_UP, DIVE_PICKING_UP and
PICKING_UP_BOWSER, using live global-pointer/action loads. Together the
results support the two local exclusions in the source argument: a retained
dialog pointer without a new grab flag cannot authorize a selector success,
and a pending named pickup cannot pass the native dialog-readiness gate.
The new proof does not assume, or formally prove, the whole source argument
connecting every caller and interaction pass.

The missing integrated obligations remain collision provenance and dispatch
order, complete reachable action/pointer histories, Buddy's live TEXT/NPC
slot and type lifetime, exhaustive reachable replacement constructors, and
normal area-reset behavior. The fresh-target overwrite on a successful
GRABBABLE selection is source-reviewed and observed in the controller test;
this new theorem covers the selector's *clear-flag* branch. It does not
machine-check all successful selections, forbid every clone lineage, or
construct delivery to Ink. It is independent of the A button, and therefore
cannot by itself prove a global no-new-A impossibility result.

This sharpens one actual execution guard on the acquisition path. It does
not remove the full-run reachability assumptions or change the route verdict.
The connected boundary is a local source-derived result, not a newly proved
retail-game history invariant.

Validation uses Ubuntu WSL, `sm64-item-proof`, Coq 8.16.1 and CompCert 3.15,
through the established pipeline with its unchanged 6,815,744 KiB virtual
memory cap. The pre-edit selected audit passed at
`build/audit/20261114-080800-wrqtqs8x`; the targeted new module compiled on its
first build. The final selected audit and its complete assumption outputs
are recorded in
[`instrumentation/ink-buddy-acquisition-proof`](../../instrumentation/ink-buddy-acquisition-proof/README.md).

The final selected audit passed at `build/audit/20261114-081312-j4brwaq_`,
including the actual MainTheorem rebuild, source inventory, proof-hole/link
checks, all four assumption queries and integration. It found 721 sources,
555/641 modules in MainTheorem's import closure, 86 standalone modules and
zero integration problems. The selected foundation counts are 9/7/4/7.
The new boundary uses seven existing allowed foundations: classical excluded
middle, two standard real decision principles, proof irrelevance, dependent
functional extensionality, and CompCert's external-function and inline-assembly
semantic parameters. No project axiom or admission was added. These checks
do not establish the explicit gameplay premises.
