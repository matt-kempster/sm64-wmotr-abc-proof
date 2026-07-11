# Checklist

## Verdict

- [x] Reject the unconditional no-byte-store claim at the proposed local
  aliasing boundary.
- [ ] Prove or refute reachability of the alias from normal initialization.

## Source and generation

- [x] Pin the inspected decompile revision and target configuration.
- [ ] Generate `game_init.c` Clight.
- [ ] Generate `title_screen.c` Clight.
- [ ] Add a reproducible direct-writer source census.

## Mechanized proof

- [ ] Certify the generated decrement/dataflow shape.
- [ ] Certify `DemoInput.timer` and Mario-Y layout offsets.
- [ ] Prove that the generated assignment uses `Mint8unsigned`.
- [ ] Construct and prove the `0xC5 -> 0xC4` one-byte memory witness.
- [ ] Certify the direct `gCurrDemoInput` writer shapes.
- [ ] Wire all results into a capstone theorem.
- [ ] Check `Print Assumptions` and reject proof holes.

## Integration

- [ ] Add this project to `SSL-Cog/README.md`.
- [ ] Run the end-to-end Ubuntu build and check pipeline.

## Commit log

- Scaffold: established the source pin, counterexample boundary, proof route,
  and isolated build layout.

