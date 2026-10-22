# Source audit: shared scripts, callbacks and instant-warp installation

Review date: October 22, 2026.
Pinned source: `9921382a68bb0c865e5e45eb594d9c64db59b1af`.

**No normal hidden installation route was identified. The seven selected demo
entries and their 33 named script helpers contain no instant-warp command.
The only named installer is the level-script opcode handler; no C, behavior
or geometry callback names it or re-enters that interpreter. Ordinary level
entry resets all eight area tables, so no prior-level inheritance route was
identified either.**

This is a pinned-source review using `git show`/`git grep`, not a new Coq
certificate, emulator experiment or runtime trace. Proof work remains stopped.
The full gameplay verdict remains **OPEN**.

## The installation mechanism

`struct Area.instantWarps` is declared in `src/game/area.h:67`.
The complete named production-source census across `src`, `include`, `data`,
`levels` and `asm` finds these operations:

| Source | Effect |
| --- | --- |
| `src/game/area.c:201` | Reset the area pointer to NULL. |
| `src/engine/level_script.c:485–509` | Allocate and populate the instant-warp table. |
| `src/game/level_update.c:542–543` | Check the pointer and read an entry. |

The builder is the static `level_cmd_create_instant_warp`. Its only named
reference outside its definition is the private dispatch table's opcode
`0x28` slot (`level_script.c:800`), reached by dispatch at831.
`INSTANT_WARP` encodes that opcode (`include/level_commands.h:239–242`).

The handler requires an open script AREA (`sCurrAreaIndex != -1`, line489).
It allocates four entries when the table is NULL (491–492), clears their IDs
(494–495), then enables one entry and writes its destination/displacement
(499–506). It targets the script's private AREA-construction index, assigned
by `AREA` at356 and reset by `END_AREA` at371, rather than the current
gameplay area's index.

A shared level script therefore could install a table if it actually ran
opcode0x28 while an AREA was open. The selected shared scripts do not do so.

## The complete named outgoing script closure

Following explicit named script-target operands from the seven selected
entries yields **40 arrays: seven roots, 21 local helpers and 12 distinct
shared helpers**. Here G and L abbreviate `script_func_global_N` and
`script_func_local_N`; local names belong to the listed level's script unit.

| Root in `levels/` | Shared JUMP_LINK targets and lines | Local JUMP_LINK targets and lines | CALL / CALL_LOOP lines |
| --- | --- | --- | --- |
| `bowser_1/script.c` | G13:27 | None |42–43 |
| `wf/script.c` | G1,2,15:107–109 | L1–4:151–154 |164–165 |
| `ccm/script.c` | G1,8,17:66–68 | L1–3:92–94; L4:108 |117–118 |
| `bbh/script.c` | G1,10,18:92–94 | L1–4:106–109 |124–125 |
| `jrb/script.c` | G1,5,14:129–131 | L1–3:151–153; L4–5:165–166 |175–176 |
| `hmc/script.c` | G1,7,18:83–85 | L1–4:104–107 |117–118 |
| `pss/script.c` | G1,9:28–29 | None |45–46 |

Every shared helper contains only model-loading commands and RETURN.
Their definitions in `levels/scripts.c` are G1:172–197, G2:199–207,
G5:223–230, G7:242–248, G8:250–256, G9:258–263, G10:265–274,
G13:293–302, G14:304–314, G15:316–326, G17:336–341 and G18:343–351.
Local helpers contain object declarations and RETURN; JRB L5 is just RETURN.

There are no further script-target operands or C CALL commands in these
helpers. The roots have no JUMP, conditional jump, EXECUTE or
EXIT_AND_EXECUTE commands. No array in this closure contains INSTANT_WARP,
a raw CMD initializer supplying opcode0x28, or an alternate macro emitting
that opcode. Object declarations emit0x24; the shared model commands emit
0x21/0x22 (`level_commands.h:203–224`).

The US/JP differences in these script units are CCM's music-touch object
(`ccm/script.c:46–48`) and JRB's Star versus Exclamation Box
(`jrb/script.c:97–101`). Neither adds a warp or script edge. This includes
Bowser1 conservatively; JP's authentic demo table omits that stream.

For comparison, the nine INSTANT_WARP declarations in tracked `levels/`
occur only in Castle Inside:285, DDD:92/108, SSL:128/141, TTM:154/165 and
WDW:106/118. None is an explicit named target in the selected closure.

This closure ends at RETURN/EXIT boundaries. It does not assert that later
main-loop dispatch, corrupted command/stack pointers or arbitrary indirect
targets stay within these arrays.

## Callbacks and shared assets

The roots' explicit C callbacks are only `lvl_init_or_update(0)` and `(1)`;
these select `init_level` and `update_level` (`level_update.c:1218–1233`).
The only named external caller of `level_script_execute` is the outer game
loop (`game_init.c:692`). No callback names the instant-warp handler/table
or another call into that interpreter. A separate declaration in
`cn_common_syms_2.c:75` is a CN-only type field, not another US/JP writer.

Model/AREA processing can run geometry callbacks: both call
`process_geo_layout` (`level_script.c:353,393`), and graph constructors can
invoke GEO_CONTEXT_CREATE callbacks (`graph_node.c:450–463`). Objects also
carry behavior callbacks. These effects have not been proved harmless just
by counting script edges. The field/alias/copy census nevertheless found no
named callback installer, typed InstantWarp mutation or complete Area copy.

Geometry has a separate command interpreter (`geo_layout.c:11–44,770–794`).
Terrain parsing creates vertices/surfaces/objects/environment data
(`surface_load.c:585–637`); macro objects select behavior presets
(`macro_special_objects.c:103–167`); dynamic collision builds Surface records
(`surface_load.c:725–740,754–790`). These are not executions of the
level-command table builder. An instant-warp floor type alone is insufficient:
`check_instant_warp` also requires a nonnull current-area table at542.

## Old tables do not have a named cross-level inheritance path

`gAreas` is initialized to fixed `gAreaData[8]` storage (`area.c:28,41`),
with no named reassignment. Each selected entry starts INIT_LEVEL:
BBH:80, CCM:53, HMC:72, JRB:116, WF:95, PSS:19 and Bowser1:20.
Its handler calls `clear_areas` (`level_script.c:304–310`), which resets
all eight slots, including `instantWarps = NULL` (`area.c:191–211`).
Their exits also run CLEAR_LEVEL, whose handler clears those slots (313–319).

AREA/END_AREA do not copy a whole Area. `load_area` selects its own array
slot (`area.c:231–247`); `change_area` unloads/loads current-level slots and
copies flags only (282–295). **`unload_area` does not clear table definitions**:
same-level reuse is intentional. Ordinary new-level entry supplies the reset.
The named copy/alias census found no transfer of an earlier Area into a new
one; the port-only memcpy operations at `level_script.c:608,634` copy terrain
and macro payloads into separate allocations.

## Consequence and limits

For intact execution of these scripts after ordinary INIT_LEVEL, the source
supports null instant-warp tables and supplies no intended later installer.
This removes the specific shared-script/callback/inherited-table explanation
for the conditional fade-cancellation route in the
[pause audit](demo-pause-intervening-calls-source-audit.md). That audit still
contains no normal pause/desync witness.

This review does not establish all-callback memory preservation, valid
command bounds, allocation/segment separation, numeric aliases, DMA targets,
loaded-script ownership or reachable linked gameplay. In particular, the
builder itself does not locally bounds-check its four-entry index (499);
generic behavior/object/raw-memory writes cannot be excluded by a named-field
search. No claim of a usable corruption route follows from that limitation.
Reaching a different level with an active stream remains a separate open
question, as does the full no-desync theorem. No proof checklist item is closed.
