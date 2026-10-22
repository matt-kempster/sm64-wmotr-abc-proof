# Source audit: callers of the level setter

Review date: October 22, 2026.

**Source-review finding: no normal mismatched setter invocation was identified.
The full gameplay verdict remains OPEN. Proof work remains stopped.**

This audit reads the pinned decomp revision
`9921382a68bb0c865e5e45eb594d9c64db59b1af` using `git grep` and
`git show`, rather than the neighboring checkout's instrumented working
files. The relevant US/JP conditional branches were inspected. No Coq build,
proof change, emulator run, ROM experiment or new semantic certificate was
performed. Findings below are source control/dataflow observations.

## Complete named caller census

A tracked-tree search for `lvl_set_current_level` has exactly three hits:

| Pinned source | Role |
| --- | --- |
| `levels/menu/script.c:61` | Sole function-pointer-bearing call site: `CALL(0, lvl_set_current_level)`. |
| `src/game/level_update.c:1273` | Function definition. |
| `src/game/level_update.h:198` | Declaration. |

There is no second named C call, script callback initializer or assembly
reference. The sole named external entry to its script
`level_main_menu_entry_2` is `levels/scripts.c:118`; the menu script's
self-reference at line62 jumps past the setter to its EXIT command.

The script's literal zero is **not the level number**.
`include/level_commands.h:117–119` encodes the first short argument and
function pointer. `src/engine/level_script.c:232–236` calls the function with
that first argument and the interpreter's `sRegister` as its second argument,
then captures the return in the register. `CALL_LOOP` does the same at
`:239–249`. The setter's `levelNum` therefore comes from the interpreter
register; the first argument is unused.

The call command and setter contain no alternate US/JP-specific argument
source. A named-reference census is not a proof excluding corrupted commands,
numeric function pointers or indirect writes.

## First demo entry: its own header reaches the setter

The ordinary regular-head and game-over-head routes carry this value:

1. `src/menu/title_screen.c:48–78` clears the old demo pointer at line49.
   On idle timeout it loads a demo, installs the chosen buffer's input records
   at line69, and returns that same buffer's signed header byte at line70.
   `intro_regular` and `intro_game_over` forward the result at185/215;
   `lvl_intro_update` forwards their return at231–248.
2. The intro scripts' `CALL_LOOP` receives that result
   (`levels/intro/script.c:65–68,90–93`). Authentic demo headers are distinct
   from the special menu values100/101 and take `script_intro_L4`.
3. `script_intro_L4` fades, sleeps, clears the title scene, sleeps again and
   transfers to the main script (`:146–151`). It contains no `SET_REG`,
   `GET_OR_SET`, `CALL` or `CALL_LOOP` command.
4. The main script calls `lvl_init_from_save_file`
   (`levels/scripts.c:116`). That function stores the supplied level,
   clears the ordinary warp destination/delayed operation/credits state and
   returns the same level argument
   (`src/game/level_update.c:1236–1270`, especially1254–1261,1270).
5. The main loop executes menu entry2 (`levels/scripts.c:117–118`), whose
   first command calls the setter with the retained register.
6. The setter stores that level and, when the demo is active, returns zero
   without clearing the pointer (`level_update.c:1273–1281`). The menu's
   zero-result jump skips act selection (`levels/menu/script.c:61–62,95`).
   Main dispatch then reads `gCurrLevelNum`
   (`levels/scripts.c:155–158`).

`EXECUTE`, `EXIT_AND_EXECUTE`, `EXIT`, jumps, returns, sleeps and loop
tests do not assign `sRegister`
(`src/engine/level_script.c:91–208`). Its assignments are callback returns,
`SET_REG` and `GET_OR_SET` reads (`:232–254,717–753`). Starting another
interpreter frame does not reset it (`:823–840`).

Thus this source route has no independent normal level selector between
the returned demo header and the setter. This conclusion relies on the
ordinary intact script/call/dataflow route and the actual returned buffer
header; it is not a proof of authentic DMA or all intervening memory effects.

## The same command runs again after gameplay

The single call site is **not limited to first startup**.
`levels/scripts.c:117–122` repeats the menu/dispatch loop after nonnegative
gameplay-script returns. A negative return exits that loop.

Selected level scripts use `CALL_LOOP(1, lvl_init_or_update)`, then clear,
sleep and EXIT; for example `levels/bowser_1/script.c:43–46`.
`lvl_init_or_update` forwards `update_level()`'s result
(`level_update.c:1221–1233`). At level-change completion,
`play_mode_change_level` returns `sWarpDest.levelNum` if an ordinary
destination exists, ahead of any special demo-exit code
(`:1089–1106`, especially1099–1102). That positive result can survive the
script exit and repeat the main loop, entering the setter again.

This is a concrete **conditional route shape**:

`different ordinary warp destination + surviving demo -> positive level
return -> main-loop re-entry -> setter with that level and surviving pointer`.

The setter does not repair a mismatch at this point. The unresolved producer
question is whether a normal active authentic demo can create or retain that
ordinary destination. A startup clear alone does not establish perpetual
absence.

## Ordinary destination producers

The five named calls to `initiate_warp` are all in
`src/game/level_update.c`:

| Call site | Source review |
| --- | --- |
| Painting warp, line673 | No active-demo guard. An eligible painting node could create a different destination. The seven selected demo scripts declare no `PAINTING_WARP_NODE` or `INSTANT_WARP`; no normal selected-demo producer was identified. Actual area construction/lifetime still matters. |
| Credits start, line853 | Inside the branch bypassed when the demo pointer is nonnull. |
| Credits next, line868 | Same active-demo interception. |
| Ordinary delayed warp node, line875 | Same interception, before ordinary destination lookup. |
| Pause Exit Course, line1022 | No demo check here, but normal active-demo Start is intercepted earlier to schedule Demo Next; transition/delayed-warp state otherwise blocks pause. Preservation of the relevant state through intervening calls remains essential. |

`initiate_delayed_warp` selects the active-demo branch at
`:828–833`, ahead of the credits/node cases, when the preceding debug branch
does not apply. Normal active-demo Start/END handling is at `:963–970`;
`pressed_pause` tests transition/delayed state at `:205–214`.

The pause and zero-ordinary-destination arguments must be maintained together:
a preexisting ordinary destination consumed by `warp_area` can change the
delayed-warp state before the pause test. Assuming either global invariant
would skip this remaining work.

The earlier [ordinary-destination audit](demo-ordinary-destination-source-audit.md)
records the direct writer census. `initiate_warp` is the sole named nonzero
destination producer; the initializer clears it at `:1254`. Instant warps
change areas within the existing level and do not write `sWarpDest` or
`gCurrLevelNum` (`:532–568`). Source absence in selected declarations is
not a linked runtime preservation theorem.

## Ordinary negative exits and file selection

With debug off, active-demo delayed completion uses -8 for Demo End and -2
otherwise (`level_update.c:823–884`). Main-script negatives route to
ending, regular/dizzy heads, splash or debug rather than immediately repeating
the setter loop (`levels/scripts.c:121–146`).

Normal demo -2/-8 exits go through head/splash/title. The regular/game-over
callbacks call `run_level_id_or_demo`, which clears the old pointer before
choosing file selection or installing a fresh demo. Choosing title Start
returns100 (or101 with debug enabled) only after that clearing call
(`title_screen.c:171–185,203–215`).

File select ultimately sets `LEVEL_CASTLE_GROUNDS`
(`levels/menu/script.c:56–57`), an independent level, but its ordinary
title-entry path has already cleared the demo. The ending script loops on
sleep/jump rather than returning to the setter
(`levels/ending/script.c:33–36`).

The pointer can remain nonnull during exit/title sleeps. EOF supplies
`END_DEMO` without clearing it (`game_init.c:485–488`); playback advances
it at513. The direct lifecycle sites are initial NULL at `:77`, title clear
at `title_screen.c:49`, and title install at69. Persistent activity during
a fade does not alone establish input application in a different loaded scene.

## Important exception: already-enabled debug state

It would be incorrect to say that every debug-selector entry clears the demo.
Title-entry debug selection does, but direct special return -9 does not.

The debug test in `initiate_delayed_warp`
(`level_update.c:826–828`) precedes active-demo interception.
`WARP_OP_DEMO_NEXT == 0x16` and `WARP_OP_DEMO_END == 0x19` both contain
the `WARP_OP_TRIGGERS_LEVEL_SELECT == 0x10` bit
(`level_update.h:25–30`). If `gDebugLevelSelect` is already true, that
branch can choose -9 with the stream still active.

Main -9 enters `level_intro_entry_4`; its `intro_level_select` can
change/return `gCurrLevelNum` without calling the clearing helper
(`levels/scripts.c:126,145–146`;
`levels/intro/script.c:96–114,137–143`;
`title_screen.c:86–146`). This exposes an independent level-selection
mechanism under the enabled-debug precondition. This review does not exhibit
a complete authentic input/loaded-scene mismatch trace even in that scope.

Production source initializes the flag FALSE (`src/game/main.c:55`) and
its only other named live assignment sets it FALSE
(`title_screen.c:140`). The TRUE assignment found is in the unapplied
`enhancements/record_demo.patch:160`, outside the unmodified US/JP
production scope. No normal controller path enabling the flag was identified.
The enabled-debug branch is therefore not a normal-production counterexample.

## Conclusion and remaining boundary

The normal first-demo caller dataflow carries its own header to the setter.
The review found no normal mismatched setter invocation. It did identify
the precise later-loop ordinary-destination route and a separate
already-enabled-debug route, both with material upstream preconditions.

This narrows a source-level question; it does not close a proof checklist item.
It is not a formal caller closure, a proof of all callback/alias/DMA effects,
a normal-boot reachability theorem or a loaded-scene/input-consumption theorem.
The full gameplay claim remains **OPEN**, and proof research remains stopped.
