# Inputs

This project intentionally has no hand-written C model. The Makefile invokes
`clightgen` on the pinned decompile's real `src/game/game_init.c`,
`src/menu/title_screen.c`, and `src/game/mario.c` translation units. The Mario
unit is included to materialize the real `MarioState` composite layout.
