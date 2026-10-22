# Source audit: can intervening calls undo Demo Next and enable pause?

Review date: October 22, 2026.
Pinned source: `9921382a68bb0c865e5e45eb594d9c64db59b1af`.

**No normal Pause → Exit Course bypass was identified. Clearing the delayed
operation alone does not open pause: the relevant warp initializer immediately
starts a replacement fade. Conditional instant-area changes can remove that
fade, so the combined state still matters.**

This is a source-only named-writer/caller and control-order review of the
unmodified US/JP paths, using pinned `git show`/`git grep` contents. No Coq
proof, build, emulator run, test trace or normal-gameplay witness was added.
The full gameplay claim remains **OPEN**, and proof research remains stopped.

## The two immediate blockers

In `src/game/level_update.c:963–970`, an active demo handles END_DEMO first,
then handles Start only if the screen transition is inactive and no delayed
warp operation exists. Scheduling Demo Next through `level_trigger_warp`:

- writes the operation (`:705`);
- sets the delayed timer to20 (`:708–709`);
- calls `play_transition` (`:713`).

`src/game/area.c:307–311` sets `gWarpTransition.isActive = TRUE`
immediately. No rendering call is needed to activate it.

Later `pressed_pause` requires a tangible Mario, no dialog, an inactive
screen transition, operation NONE and Start pressed
(`level_update.c:205–214`). Its caller also requires NORMAL mode, no
change-level destination and zero gameplay transition timer
(`:993–1004`). Thus scheduling creates two independent pause blockers:
pending operation and active screen fade.

The delayed-operation timer, gameplay transition timer and screen-transition
active flag are distinct state. Expiry or clearing of one does not by itself
clear the others.

## What runs before the pause test

The normal update order is `level_update.c:974–1004`:

1. `warp_area`;
2. `check_instant_warp`;
3. HUD timer increment;
4. `area_update_objects`;
5. `update_hud_values`;
6. `update_camera` if an area is present;
7. `initiate_painting_warp`;
8. `initiate_delayed_warp`;
9. mode/destination/gameplay-transition tests, then `pressed_pause`.

Rendering occurs later: the game loop reads controllers, then executes the
level script (`game_init.c:691–692`); the interpreter runs command handlers
before `render_game` (`engine/level_script.c:827–836`). The renderer's
screen-transition completion at `area.c:397–410` therefore does not occur
between Start scheduling and the pause test in this ordinary call sequence.

## Complete named delayed-operation store/caller census

All production named uses of `sDelayedWarpOp` are in `level_update.c`,
apart from its header declaration. The assignments are:

| Source | Effect and context |
| --- | --- |
| `init_mario_after_warp:398` | Clears to NONE. Called only by `warp_area:471` and `warp_level:482`. |
| `warp_credits:521` | Clears to NONE, installs a credits action, and starts a fade at523. Called by `init_level:1168`. |
| `level_trigger_warp:705,733,745` | Schedules the supplied operation or changes a newly scheduled death to GAME_OVER. Its entire mutating body is guarded by operation NONE at702. |
| `init_level:1160` | Clears during level initialization. Called by `lvl_init_or_update`'s initialization case at1226, not its gameplay update case. |
| `lvl_init_from_save_file:1255` | Clears during the main script's initial setup (`levels/scripts.c:116`), not an intervening object/camera call. |

The only named clearing chain inside the normal-frame interval is
`warp_area -> init_mario_after_warp`.
`warp_level` and `warp_credits` are called from level initialization.
The level-script interpreter has one named caller, the outer game loop;
no named object/behavior/camera callback invokes the clearing initializers or
re-enters it.

A later Mario/object warp request cannot overwrite an existing Demo Next:
`level_trigger_warp:702–811` puts its writes, switch and transition calls
inside the operation-is-NONE guard. Outside that guard it only returns the
existing timer (`:813`).

## The warp reset clears the operation, then replaces the fade blocker

`warp_area:463–472` invokes `init_mario_after_warp` only when an ordinary
destination is already pending. That initializer:

- clears destination and delayed operation (`:397–398`);
- calls `play_transition` in every spawn-type switch arm, including default
  (`:400–422`).

Consequently, even if a valid pending destination clears Demo Next, a fresh
active screen fade blocks `pressed_pause`. This remains true when the
initializer skips its Mario setup because the action is UNINITIALIZED:
the transition switch is after that conditional.

A missing warp node is not a quiet successful return that skips the fade:
the function dereferences the returned node/object before reaching the clears
(`:368–369`). Malformed resources do not establish a normal bypass.

Tangible action cannot be dismissed universally: some spawn types set
`ACT_IDLE` (`:311–322`). The generally applicable immediate blocker here
is the newly active fade.

This corrects the earlier incomplete suggestion that an ordinary-destination
reset could clear the operation and thereby allow pause. Clearing the
operation is only one step; its other effects must also be tracked.

## Object, HUD and camera calls

The named production-source census finds no delayed-operation clearing
initializers, direct paused-mode entry, or reentrant level-script execution
in the ordinary object/HUD/camera callback inventory.

`area_update_objects` calls `update_objects`
(`area.c:298–300`), which dispatches object behaviors through their command
table and CALL_NATIVE pointers
(`object_list_processor.c:626–686`;
`behavior_script.c:361–364,933–939`).
The named behavior-data/C/assembly references contain none of the clearing
initializers or pause-mode writer as callback targets.
`update_hud_values:888–945` and the camera update likewise contain no named
path to those stores.

This is a bounded named-source review, not a semantic proof of every indirect
target, pointer alias or machine-address write.

The interval need not preserve mode identically: Mario's save-and-quit handler
can call `fade_into_special_warp(-2,0)`
(`mario_actions_cutscene.c:247–257`), selecting CHANGE_LEVEL through
`warp_special`. That bypasses the later NORMAL-mode pause arm rather than
entering pause.

The direct `buttonPressed` assignments are in input processing and the
P1-to-P3 copy (`game_init.c:542,550,566`), not a later named producer
injecting a fresh Start between the two tests.

## Timer expiry does not silently clear the operation

`initiate_delayed_warp:823–884` decrements the delayed timer. With a live
demo it selects a special exit when the timer expires, or the earlier
enabled-debug branch. It does not assign operation NONE.
`warp_special:222–226` selects CHANGE_LEVEL, preventing the subsequent
NORMAL-mode pause arm. A timer reaching zero alone is not an opening.

## Conditional cancellation of the replacement fade

The named false writers of the screen-transition flag are:

- `clear_areas`, `area.c:187`;
- `clear_area_graph_nodes`, `:220`;
- `unload_area`, `:257`;
- transition completion during `render_game`, `:399`.

The clear-area/graph routines are called by script INIT/CLEAR handlers, not
named ordinary object/camera callbacks. Rendering is downstream of the pause
test. But `check_instant_warp` is an actual intervening call with a route
to `unload_area`:

`check_instant_warp (level_update.c:539–562) -> change_area (:556) ->
unload_area (area.c:285–287) -> isActive FALSE (:257)`.

It needs a suitable current floor, a nonnull instant-warp table, a nonzero
entry and a different target area. When the warp initializer calls
`init_mario` (its action-is-not-UNINITIALIZED branch), that call refreshes the
floor through `find_floor` (`mario.c:1831–1832`), so arbitrary stale pre-warp
floor data is not enough in that case. The skipped-body path still starts
the replacement fade.
Neither `change_area` nor `load_area` itself restarts a fade.

Two conditional route shapes therefore deserve explicit boundaries:

1. **New Demo Next, then both blockers removed.** A valid preexisting ordinary
   destination causes `warp_area` to clear the operation and start a fade.
   A subsequent eligible instant area change clears that new fade.
2. **Start initially ignored because a fade was active.** With END_DEMO absent
   and no pending operation, the active fade makes the Start branch skip
   scheduling Demo Next. A subsequent eligible instant area change can clear
   the fade before the pause test. No newly scheduled operation is cleared in
   this variant.

To enter pause, remaining work in either shape must leave Start pressed,
Mario tangible, no dialog, operation NONE, fade inactive, gameplay transition
timer zero, NORMAL mode and no change-level destination. This review does not
exhibit a normal authentic-demo run meeting those conditions.

The selected authentic demo scripts contain no direct `INSTANT_WARP`
declarations, and no normal source route to the required live instant-warp
resources was identified. In the first shape a valid preexisting ordinary
destination is an additional unresolved prerequisite. An instant warp alone
does not clear an already-pending Demo Next.

## Pause rendering and Exit Course are downstream

The only named explicit transition into PAUSED is
`set_play_mode(PLAY_MODE_PAUSED)` at `level_update.c:1004`, after
`pressed_pause`. The paused handler is selected by `update_level`'s
mode dispatch (`:1129–1144`).

`play_mode_paused:1011–1030` requests pause rendering, then consumes a
menu result. Pause rendering sets the gameplay transition timer to-1 on
opening and zero on confirmation
(`ingame_menu.c:2977–2982,3002–3020`); `render_game` stores its returned
choice in `gMenuOptSelectIndex` (`area.c:385`).
Only a subsequent paused-mode handler consumes Exit Course and creates the
castle destination (`level_update.c:1018–1024`).
A stale menu-choice value does not make normal-mode dispatch run that handler.

Even a hypothetical pause entry is not a completed demo-desync witness:
Exit Course must be selectable/confirmed under the actual menu/action/input
conditions, then a different scene must load and consume authentic demo input
before the stream is cleared or replaced.

## Conclusion

If Demo Next remains pending on entry to the object/HUD/camera interval,
those named calls do not clear or replace it. Repeated warp requests do not
replace it, and expiry selects change-level mode. The relevant exceptional operation
clearer also starts a new fade. No normal cancellation-to-Pause-to-Exit-Course
route was found.

The remaining source conditions are narrower than simply assuming that no
intervening call clears the operation: track the operation and screen fade
together, plus area lifetime/instant-warp data and mode selection. This does
not establish a linked all-frame preservation theorem, hardware/alias
adequacy or the full no-desync claim. The gameplay verdict remains **OPEN**.
