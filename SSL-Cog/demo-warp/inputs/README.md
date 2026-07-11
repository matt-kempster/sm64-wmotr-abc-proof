# Inputs

This project intentionally has no hand-written C model. The Makefile invokes
`clightgen` on the pinned decompile's real `src/game/game_init.c`,
`src/menu/title_screen.c`, and `src/game/mario.c` translation units. The Mario
unit is included to materialize the real `MarioState` composite layout.

The reachability extension also translates `src/game/main.c`,
`src/game/memory.c`, and `src/game/level_update.c`. These supply the fixed
main-pool initialization, allocator/DMA-list dataflow, and concrete
`gMarioStates` global definition.
