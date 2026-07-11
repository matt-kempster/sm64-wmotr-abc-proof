# Claim and scope

## Pinned source and target

- SM64 decompile revision: `36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`
- game version: North American (`VERSION_US=1`)
- CompCert: 3.15, `ppc-eabi`, 32-bit pointers, big-endian memory
- translation flags: `NON_MATCHING=1`, `AVOID_UB=1`, `TARGET_N64=1`, F3DEX2

## Current claim

The unconditional impossibility statement is false at the local Clight-store
boundary. Generated `game_init.c` contains an unsigned-byte assignment for
`gCurrDemoInput->timer`. If the pointer value supplied to that generated
lvalue aliases the most-significant byte of `gMarioStates[0].pos[1]`, and that
byte is `0xC5`, the store writes `0xC4` to exactly that byte. Because the new
timer value is nonzero, the subsequent conditional pointer increment is not
taken.

The capstone `demo_timer_mario_y_counterexample_capstone` combines:

- the exact generated-AST decrement certificate;
- generated layout facts (`DemoInput.timer` at offset 0 and Mario Y at the
  `MarioState.pos` offset plus one `float`);
- the CompCert `Mint8unsigned` store effect; and
- a concrete before/after memory witness.

The proof additionally shows that the generated `run_demo_inputs` body has
exactly one assignment to a `DemoInput.timer` lvalue, that `0xC5 - 1 = 0xC4`,
and that `0xC4` is nonzero. The concrete CompCert store witness changes the
watched byte and preserves every disjoint unsigned-byte load. The separate
corollary `unconditional_no_matching_byte_store_is_false` refutes the narrow
unconditional no-store proposition.

The generated inputs are committed as `generated/game_init.v`,
`generated/title_screen.v`, and `generated/mario.v`. They are produced
directly from the pinned source units by `pipeline/clightgen.sh`; no extracted
or hand-written C model sits between the decompile and Clight. The Mario unit
supplies the complete generated `MarioState` composite needed for the Y-field
layout certificate.

## Reachability boundary

This is not yet a proof that an ordinary run from SM64 initialization reaches
the alias. The direct source writers found so far set `gCurrDemoInput` to
`NULL`, set it to `gDemoInputsBuf.bufTarget + 1`, or increment it by one
`DemoInput`. A separate generated-AST census will certify those shapes.

Closing the stronger gameplay question requires proving one of:

1. the demo buffer and Mario-state blocks remain disjoint in every reachable
   execution, yielding an impossibility theorem; or
2. a real generated execution path corrupts or constructs the alias, yielding
   a reachable counterexample.

The local counterexample must not be reported as satisfying item 2.

## Conditional impossibility result

`separated_demo_pointer_cannot_change_mario_y` combines the generated direct-
writer certificate with a CompCert memory-frame theorem: a one-byte store in
a demo block preserves Mario's Y byte whenever the demo and Mario blocks are
distinct. `alias_is_necessary_for_demo_timer_mario_y_byte_change` proves the
contrapositive boundary—a changed Mario-Y byte requires block equality.

Thus the formal split is now exact:

- distinct blocks: the proposed timer mechanism cannot change Mario Y;
- same block at the Y-byte offset: the checked `0xC5 -> 0xC4` counterexample
  exists;
- still open: whether a real gameplay execution can violate the expected
  demo-buffer/Mario-state block separation.

## Verification status

`pipeline/check.sh` regenerates as needed, builds all five proof modules,
rejects proof-hole keywords, checks the source census, and compiles a strict
`Print Assumptions` query. The capstone currently reports only the standard
classical and functional-extensionality axioms inherited from CompCert. The
same strict assumption check also runs for the separated-block safety theorem.
