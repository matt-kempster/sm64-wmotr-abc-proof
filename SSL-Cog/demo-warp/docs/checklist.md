# Checklist

## Verdict

- [x] Reject the unconditional no-byte-store claim at the proposed local
  aliasing boundary.
- [x] Refute reachability of the alias from normal initialization.

## Source and generation

- [x] Pin the inspected decompile revision and target configuration.
- [x] Generate `game_init.c` Clight.
- [x] Generate `title_screen.c` Clight.
- [x] Generate `mario.c` Clight for the concrete `MarioState` layout.
- [x] Add a reproducible direct-writer source census.
- [x] Generate `main.c` Clight for the fixed pool bounds.
- [x] Generate `memory.c` Clight for allocator and DMA-list provenance.
- [x] Generate `level_update.c` Clight for the concrete Mario-state global.
- [x] Generate a canonical-US demo stream certificate without committing ROM
  bytes.
- [x] Generate a linker-order certificate placing `level_update` BSS after the
  main-pool interval.

## Mechanized proof

- [x] Certify the generated decrement/dataflow shape.
- [x] Certify `DemoInput.timer` and Mario-Y layout offsets.
- [x] Prove that the generated assignment uses `Mint8unsigned`.
- [x] Construct and prove the `0xC5 -> 0xC4` one-byte memory witness.
- [x] Certify the direct `gCurrDemoInput` writer shapes.
- [x] Certify the generated controller-to-demo call boundary and absence of
  direct controller-reader assignments to the demo pointer/handler.
- [x] Audit that certificate's statement and retract the unsupported semantic
  preservation interpretation.
- [ ] Prove a Clight execution invariant for the clean-boot title/demo path.
- [ ] Prove a target-specific frame invariant for `gCurrDemoInput`,
  `gDemoInputsBuf`, and the allocated demo buffer across the desired gameplay
  scope.
- [ ] Prove whole-program memory safety for every input-reachable gameplay path
  (sufficient, but no longer presented as necessary for the narrower target
  integrity claim).
- [x] Wire all results into a capstone theorem.
- [x] Prove the distinct-block conditional impossibility theorem.
- [x] Prove that a matching Mario-Y byte change requires block aliasing.
- [x] Certify the generated normal-initialization pointer provenance chain.
- [x] Certify that `load_patchable_table` cannot rewrite `bufTarget`.
- [x] Compose the allocator, authentic-stream, and linker receipts into the
  normal-initialization reachability capstone.
- [x] Check `Print Assumptions` and reject proof holes.

## Integration

- [x] Add this project to `SSL-Cog/README.md`.
- [x] Run the end-to-end Ubuntu build and check pipeline.

## Commit log

- Scaffold: established the source pin, counterexample boundary, proof route,
  and isolated build layout.
- Generated Clight: translated the real US `game_init.c` and
  `title_screen.c` units with CompCert 3.15; generated files are committed and
  reproducible through `make generated`.
- Layout input: added the real `mario.c` translation unit to the generation
  set so the proof can compute the Mario-Y offset from a generated composite.
- Generated Mario layout: translated `mario.c` successfully with the same
  pinned CompCert target and flags.
- Proof spine: added generated AST/dataflow and writer facts, concrete layout
  facts, unsigned-byte `assign_loc` semantics, an allocated-memory
  `0xC5 -> 0xC4` witness with a disjoint-byte frame, and the composed
  counterexample capstone. The strict end-to-end check is green.
- SSL-Cog integration: added `demo-warp/` to the parent project index with the
  local-counterexample/gameplay-reachability distinction intact.
- Reachability boundary: proved that distinct demo/Mario memory blocks forbid
  the byte change and that any matching change requires block equality. The
  only open route-level issue is whether generated gameplay can establish that
  alias.
- Reachability inputs: added the three real translation units needed to move
  that issue onto the generated proof spine (`main`, `memory`, and
  `level_update`).
- Generated reachability ASTs: translated all three units successfully with
  the pinned CompCert target and committed them without hand edits.
- ROM/linker bridge: verified the canonical US ROM SHA-1, all seven table
  streams and terminal records, the 0x800 DMA bound, fixed pool constants,
  linker section order, and the concrete `gMarioStates[1]` definition. The
  generated Coq receipt records only metadata and hashes.
- Generated provenance: certified fixed pool initialization, allocator
  align/header and left-result shapes, the 2048-byte demo allocation handoff,
  the sole `bufTarget = buffer` store, absence of `bufTarget` writes during
  patch loading, title-screen buffer origin, and the concrete Mario-state
  global.
- Reachability verdict: composed the generated facts into
  `normal_initialization_forbids_demo_pointer_mario_y_alias`, proved the
  normal-state predicate inhabited, and refuted existence of a normal state
  where the demo pointer equals Mario's Y address. The capstone is closed under
  the global context.
