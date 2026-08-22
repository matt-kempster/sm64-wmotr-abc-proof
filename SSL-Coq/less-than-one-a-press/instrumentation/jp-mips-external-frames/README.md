# JP retail external-call frame certificate

This certificate answers a narrow Timer-131 question directly at the retail-machine level: if `sqrtf`, `stop_sounds_from_source`, or `stop_sounds_in_continuous_banks` executes, can any path through the real JP MIPS body or its sound callees overwrite Mario's object fields?

`verify.sh` accepts only the authentic original-JP ROM (SHA-256 `9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317`). It authenticates all 332 instructions in eight complete ranges, disassembles every range, and compares all 42 store instructions and all eight direct calls against `expected-store-call-manifest.csv`. The Coq files `InkTimer131RetailMipsCode.v` and `InkTimer131RetailMipsFrames.v` independently scan the transcribed words, prove that every relative branch stays inside its routine, exclude plain jumps, indirect calls, and branch-and-link escapes, and classify every store address.

Run it from the proof-project directory:

```sh
bash instrumentation/jp-mips-external-frames/verify.sh /path/to/baserom.jp.z64
```

## Result

`sqrtf` is exactly two instructions and has no store or call. The sound call tree writes only four places: its bounded call stack, sound-bank nodes at or above `0x80360c48`, the music mask at `0x80332110`, and sequence-player-zero state in `0x80222a18..0x80222a3b`. It never stores through the source-position argument. The entire object pool is `0x8033c118..0x8035fb17`, so every non-stack destination misses every object, not merely the two Timer-131 fields.

The continuous-bank root can descend 128 bytes below its entry stack pointer. The authenticated level-select prefix now records its first live entry SP as `0x80207128`; therefore its whole conservative stack envelope is also below the object pool. This turns the reached pre-entry sound call into a protected-memory frame without an IDO-to-Clight bridge. `stop_sounds_from_source` was already proved unreached in that prefix, but its complete machine footprint is included so the result generalizes to another valid call with a stack outside the object pool.

## Scope

This is an all-path store-footprint certificate for ordinary execution of these immutable instruction ranges. It is not a full N64 hardware semantics. It does not cover a forged program counter or return address, self-modifying code, DMA or interrupt writers, or continuation after an invalid memory access. Those mechanisms remain outside the current execution model rather than being disproved in retail SM64.
