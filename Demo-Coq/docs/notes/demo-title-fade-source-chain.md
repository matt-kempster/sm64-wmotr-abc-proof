# Source audit: selecting a demo while an old scene remains active

Scope: read-only review of the complete pinned source tree at
`9921382a68bb0c865e5e45eb594d9c64db59b1af`, especially the ordinary US/JP
intro/demo script routes. This note is not a Coq execution, callback-closure,
boot-reachability or native refinement proof. No new emulator trial was run.

The concrete candidate was that a newly selected authentic demo begins
driving the preceding demo's Mario or gameplay camera during the title fade.
The ordinary source route supplies a specific clearing/ordering chain against
this candidate, rather than excluding it merely because the screen is called
the title screen:

1. `src/game/game_init.c:643` defines `thread5_game_loop`; its loop reads
   controllers before calling `level_script_execute`. Consequently the input
   processing of the frame that installs a new stream precedes that stream's
   installation in `src/menu/title_screen.c:48-76`.
2. The only direct calls to `run_level_id_or_demo` are `intro_regular` and
   `intro_game_over` (`title_screen.c:185,215`). The ordinary and dizzy intro
   scripts call them through `lvl_intro_update`, then route a demo-header
   result to `script_intro_L4` (`levels/intro/script.c:46-93,146-153`).
3. `level_cmd_call_loop` (`src/engine/level_script.c:239`) advances the script
   immediately when the callback returns nonzero. The same interpreter
   invocation therefore executes `TRANSITION`, then `SLEEP(16)`, after the
   new stream is installed. `level_cmd_sleep` (`level_script.c:123`) pauses
   the interpreter; it does not perform an object/gameplay update.
4. `level_script_execute` (`level_script.c:823`) renders after pausing. It
   does not itself call `area_update_objects`, `update_level`, or
   `update_camera`. The regular/dizzy head geometries
   (`levels/intro/geo.c:55-125`) contain the backdrop and Goddard head
   callbacks, rather than a gameplay `geo_camera_main` callback or a Mario
   object placement.
5. The actual head callback has an additional input guard:
   `geo_draw_mario_head_goddard` (`src/game/mario_misc.c:85-100`) copies the
   controller pad to Goddard only when `!gWarpTransition.isActive`.
   The outgoing transition therefore suppresses that copy while its active
   flag remains set. This is a source guard, not a proved all-frame timing
   invariant or a claim about every Goddard callback.
6. `script_intro_L4` executes `CLEAR_LEVEL` before its following `SLEEP(2)`
   and exit to the main scripts. `level_cmd_clear_level`
   (`level_script.c:313`) calls `clear_objects`, `clear_area_graph_nodes`,
   and `clear_areas` before returning. `clear_objects`
   (`src/game/object_list_processor.c:528-556`) sets `gMarioObject = NULL`,
   clears object lists and deactivates the pool. `clear_areas`
   (`src/game/area.c:183-213`) clears the active area and area resources.
7. All seven selected demo-level script entries have `CLEAR_LEVEL`
   immediately after their `CALL_LOOP(1,lvl_init_or_update)` returns nonzero:
   Bowser 1 `script.c:43-45`, WF `165-167`, CCM `118-120`, BBH `125-127`,
   JRB `176-178`, HMC `118-120`, PSS `46-48`. Both intro head entries begin
   with `INIT_LEVEL`, whose handler (`level_script.c:304`) again clears
   objects and areas. The preceding gameplay scene is therefore explicitly
   cleared before the next idle timeout installs another demo.

There are meaningful limitations. Rendering invokes callbacks, and a
transitive callback closure/frame theorem is not established by this review.
Opcode `CMD2D` (`level_script.c:673`) calls `area_update_objects` outside
`play_mode_normal`; `basic_update` can also update objects/camera during
transitions (`level_update.c:953`). A complete observation must account for
these real paths rather than equate gameplay with one update entry. The
source search found no `CMD2D()` use in the pinned level scripts, but that
search is not an interpreter/control-flow proof.

Old-demo input processing can persist across the intervening script sleeps
until a later intro callback clears `gCurrDemoInput`. This is not sufficient
to establish different-level gameplay: the corresponding Mario/object/area
state and actual input-use boundary must also be present. The exact native
render/transition timing and every callback's memory effects remain outside
this source-chain observation.

This weakens the ordinary title-fade candidate substantially. It does not
decide the full gameplay claim or establish a global no-desync invariant.
