# Inputs

This project intentionally has no hand-written C model. The Makefile invokes
`clightgen` on the pinned decompile's real `src/game/game_init.c`,
`src/menu/title_screen.c`, and `src/game/mario.c` translation units. The Mario
unit is included to materialize the real `MarioState` composite layout.

The reachability extension also translates `src/game/main.c`,
`src/game/memory.c`, and `src/game/level_update.c`. These supply the fixed
main-pool initialization, allocator/DMA-list dataflow, and concrete
`gMarioStates` global definition.

`pipeline/generate-reachability-facts.py` supplements Clight with the two
inputs that a C translation unit cannot contain: authentic US ROM demo bytes
and final linker-section ordering. Regeneration requires a canonical
`baserom.us.z64` (SHA-1
`9bef1128717f958171a4afac3ed78ee2bb4e86ce`) in the SM64 source root. The ROM
is read only and is never copied into this project; the generated Coq file
contains only sizes, terminal offsets, bounds, and hashes.
