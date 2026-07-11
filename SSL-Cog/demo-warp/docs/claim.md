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

The intended first capstone will combine:

- the exact generated-AST decrement certificate;
- generated layout facts (`DemoInput.timer` at offset 0 and Mario Y at the
  `MarioState.pos` offset plus one `float`);
- the CompCert `Mint8unsigned` store effect; and
- a concrete before/after memory witness.

The generated inputs are committed as `generated/game_init.v` and
`generated/title_screen.v`. Both are produced directly from the pinned source
units by `pipeline/clightgen.sh`; no extracted or hand-written C model sits
between the decompile and Clight.

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
