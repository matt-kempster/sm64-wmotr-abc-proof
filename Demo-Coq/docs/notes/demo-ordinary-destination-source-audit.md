# Source audit: ordinary warp destination taking priority over demo exit

Scope: read-only token/direct-store and callsite review of the pinned tree
`9921382a68bb0c865e5e45eb594d9c64db59b1af`. Searches covered its C files,
headers and assembly (`*.c`, including `*.inc.c`; `*.h`; `*.s`), not the
neighboring decomp checkout's working files. The US/JP source branches were
read at each material destination/exit guard. This is a source fact census,
not a linked generated-program frame or native-memory theorem. No new
emulator experiment or Coq proof was added.

## Why the candidate matters

`play_mode_change_level` (`src/game/level_update.c:1089-1106`) returns
`sWarpDest.levelNum` whenever `sWarpDest.type != WARP_TYPE_NOT_WARPING`,
in preference to the special demo-exit code in `D_80339EE0`. Its unused
alternative (`1109-1123`) has the same priority. `warp_special` (`222-226`)
does not clear `sWarpDest.type`. Therefore a stale or newly created ordinary
destination is a real precondition to exclude; executing the demo -8/-2
branch alone is insufficient.

## Complete named direct-writer/caller census

Every named `sWarpDest` source occurrence found is in
`src/game/level_update.c` or its extern declaration in `level_update.h:152`.
It is a public `FORCE_BSS` global (`level_update.c:164`), not a private global.
No explicit `&sWarpDest` or whole-structure assignment was found.

| Source writer | Direct effect |
| --- | --- |
| `initiate_warp`, `level_update.c:615-629` | The only function assigning a nonzero `type`, and the only assignment site for `levelNum`, `areaIdx`, `nodeId`, and `arg`. The type is selected from change-level, change-area and same-area. |
| `init_mario_after_warp`, `397` | Clear `type` to not warping. |
| `warp_credits`, `520` | Clear `type` to not warping. |
| `lvl_init_from_save_file`, `1254` | Unconditionally clear `type` before installing the selected current level; also clear delayed warp operation and credits state. |

The complete named source callsite set for `initiate_warp` is:

| Callsite | Material guard/context |
| --- | --- |
| `initiate_painting_warp`, `673` | Requires an active area's nonnull painting table and eligible nonzero painting node. There is no active-demo rejection here. |
| `initiate_delayed_warp`, `853,868,875` | All three calls lie inside the `else` after the active-demo branch at `828`. While `gCurrDemoInput != NULL`, delayed requests instead call `warp_special(-8)` or `warp_special(-2)` (unless the preceding debug-level-select branch applies). |
| `play_mode_paused`, `1022` | Exit-course creates a castle destination. Pause reachability must be excluded under the active-demo invariant. |

There are no additional named C/assembly callsites in the searched tree,
including behavior implementation files. Behavior requests through
`level_trigger_warp` (`694-812`) set delayed operation/timer state, not an
ordinary destination. They are not an independent bypass of the active-demo
branch at delayed-warp completion.

`check_instant_warp` (`532-568`) does not assign `sWarpDest` or
`gCurrLevelNum`; it selects an area, adjusts positions and updates the
camera within the existing level's area table. Its correctness still needs
the current area table's provenance. An instant warp is not by itself a
different-level selector.

## Startup and the resulting narrower obligation

The demo-header route enters `level_main_scripts_entry`, which calls
`lvl_init_from_save_file` before the dispatch loop
(`levels/scripts.c:112-124`). Its unconditional destination clear removes a
previous game's ordinary destination on this route. A newly selected demo is
not installed by gameplay update code: the direct installation/clear sites
are in `run_level_id_or_demo`, reached from the intro callbacks; the playback
consumer only advances its record pointer and does not install a different
stream. A reachable memory/record-bounds proof remains necessary to preserve
the active pointer throughout a gameplay episode.

Given startup `type == 0`, a persistent active-demo pointer, absent painting
tables for the loaded demo-owned area, and pause exclusion, the direct source
census has no producer of an ordinary destination. Pause exclusion and zero
ordinary destination are a mutual invariant: normal demo Start/END_DEMO
scheduling makes the delayed operation nonzero before `pressed_pause`; a
preexisting ordinary destination could otherwise make `warp_area` clear that
operation. Treating either invariant as already established would be circular.

Only `clear_areas` (`area.c:200-201`) and the actual level-interpreter table
builders (`level_script.c:490-491,525-526`) directly assign the painting or
instant-warp table pointers in the searched C source. The selected demo
translation units' finite opcode checks and existing neutral/Start retail
observations support absent tables, but do not by themselves prove the
loaded area construction, all indirect frames, or every script route.

This narrows the strongest source obligation to preserving a structural
producer invariant through the actual program. It does not require enumerating
every demo movement trajectory or RNG outcome merely to exclude ordinary
destinations. The remaining risks are explicit: public/indirect aliases,
untranslated or external memory effects, numeric native addresses, valid
interpreter execution, debug/start-state constraints, and loaded-scene
provenance have not been discharged. Symbol-name searches do not exclude
assembly writes through numerical addresses, memory corruption, or indirect
calls manufactured by an unproved memory image.
