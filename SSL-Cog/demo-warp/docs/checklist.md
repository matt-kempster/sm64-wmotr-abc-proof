# Checklist

## Verdict

- [x] Reject the unconditional no-byte-store claim at the proposed local
  aliasing boundary.
- [ ] Prove or refute reachability of the alias from normal initialization.

## Source and generation

- [x] Pin the inspected decompile revision and target configuration.
- [x] Generate `game_init.c` Clight.
- [x] Generate `title_screen.c` Clight.
- [x] Generate `mario.c` Clight for the concrete `MarioState` layout.
- [x] Add a reproducible direct-writer source census.

## Mechanized proof

- [x] Certify the generated decrement/dataflow shape.
- [x] Certify `DemoInput.timer` and Mario-Y layout offsets.
- [x] Prove that the generated assignment uses `Mint8unsigned`.
- [x] Construct and prove the `0xC5 -> 0xC4` one-byte memory witness.
- [x] Certify the direct `gCurrDemoInput` writer shapes.
- [x] Wire all results into a capstone theorem.
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
