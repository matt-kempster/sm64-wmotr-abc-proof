# A native pending pickup can acquire an initialized SSL shell, conditionally

14 November 2026. **The object-slot mechanism works without supplying Mario's pickup pointer.** A real small box is picked up, carried, dropped, allowed to expire, and selected for pickup just before it expires. If the existing shell box is granted its contents-spawning action at the correct update, its actual shell replaces the expired small box's slot. Mario then finishes the already-started pickup, carries the shell, and drops or throws it. The released frozen shell remains mountable. **The shell-box activation is still supplied, and this experiment does not deliver anything high or produce an Ink handoff.** It closes an important mechanism question, not the controller route.

## Scope, versions, and credit

The proof checkout started at `162617b708b2244beca85af58b76ad5794e598cd`, after inspecting the requested `08df00c605127a172d3a28049e31d6f50f7bff98` high-item notes and current work. JP source statements use the project's stock pin `9921382a68bb0c865e5e45eb594d9c64db59b1af`; the local decompile checkout is `36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`. Its unrelated optional `SSL_SPAWNING_DISPLACEMENT_TAS_HACK` branches are not the source premise. Runtime search uses the existing Wafel 0.8.5 JP DLL, SHA-256 `960fe979068b78e6733b3ddb87741833fbf4eb29b2a21a2bba871977427c2d0f`, with Python 3.9.13. Original-JP confirmation is recorded separately in [ink-shell-delivery-rom.md](ink-shell-delivery-rom.md).

The existing [native small-box delivery](../../instrumentation/ink-buddy-replacement-delivery/README.md) supplied the first 900 controller inputs, not a memory cut. That study had already verified the longer actual carry/throw prefix on original JP. The [Buddy acquisition audit](ink-buddy-acquisition-source.md) supplied the pickup-writer census and distinction between a pending selected target and an arbitrarily supplied pointer. The earlier shell-release waypoint search in `instrumentation/ink-buddy-replacement-shell` tried 72 controller menus / 32,695 updates without releasing the roof shell; it is not repeated here or treated as impossibility. The independent initialized-shell isolation and high-entry studies answer different questions.

## Native shell, pickup, and release

The only native shell constructor identified in SSL Area 1 is `macro_box_koopa_shell` at **(5840, 940, 2500)**, slot 32 in this prefix. The Area 1 macro list and area scripts contain no Koopa actor. A Koopa's shell-dropping callback elsewhere in the game is therefore not an SSL supply route by itself. The existing small box begins at **(5900, 50, 3440)**, slot 23. Both objects are genuine SSL Area 1 inventory.

The relevant stock code is `data/behavior_data.c`, `src/game/behaviors/koopa_shell.inc.c`, `src/game/interaction.c`, `src/game/object_helpers.c`, and `src/game/mario_actions_object.c`:

- `bhvKoopaShell` uses `OBJ_LIST_LEVEL`, sets graphics-update and physics fields, and calls `bhv_koopa_shell_loop`; it is not `OBJ_FLAG_HOLDABLE` and has no solid-floor loader. The first callback calls `obj_set_hitbox`, which sets `INTERACT_KOOPA_SHELL` (524288), radius/height 50/50, and tangibility zero. The initialized flags are 1073741825. Newly allocated defaults instead have interaction type zero, intangible timer -1, and height 100.
- `mario_grab_used_object` reads the already-selected `usedObj`; it does not re-run the target selector. `obj_set_held_state` redirects a non-HOLDABLE object's behavior command to the appropriate `bhvCarrySomething3/4/5` script. These scripts terminate at `BREAK`, so the shell callback no longer runs. Its initialized type, dimensions, and tangibility survive. The native shell's normal status reset also stops, which matters after mounting.
- A native drop uses stored HOLP X/Z but **Mario's current movement Y**. A throw uses stored HOLP XYZ plus the horizontal throw offset. High HOLP is a separate gameplay prerequisite; no HOLP write is made here.
- `interact_koopa_shell` can mount on a downward airborne above-contact, or from WALKING/HOLD_WALKING. It writes the used/ridden references, sets `RIDING_SHELL_GROUND`, and returns true, ending that interaction pass. The low followups below use walking contact; they do not establish an above-contact high bridge. A contact that merely intersects the cylinder is not automatically a mount.

## Why one update changes the result

`update_objects` updates SPAWNER/SURFACE objects, applies platform displacement, detects object collisions, then updates the remaining lists. PLAYER precedes LEVEL. The exclamation box is a SURFACE object and its contents shell is a LEVEL object. Thus the contents shell can exist for Mario's update **before its first initialization callback** later in that same update.

`allocate_object` clears the raw fields and gives intangible timer -1; `try_allocate_object` takes the head of the free list. `deallocate_object` puts an unloaded object at that head. The small box's native released counter reaches 901, creates its respawner, marks itself inactive, and is unloaded at the end of the update. It is then the next free slot. `exclamation_box_act_4` allocates its contents before mist, break particles, or sound, so the shell wins that slot in the tested schedule.

This produces three distinct cases:

| Shell allocation relative to pickup commit | Actual result in this prefix |
|---|---|
| One update earlier | Shell executes its first LEVEL callback, then next update Mario freezes the initialized shell. Tangible 50×50 shell survives native release and mounts. |
| Same update | Mario freezes it before the first LEVEL callback. Type remains 0, intangible timer remains -1, height remains 100. Release does not repair this; walking contact fails. |
| One or two updates later | Mario has already grabbed the vacant slot. Allocation fills that still-referenced slot; the shell initially stays live and initializes. Native later drop/throw finally freezes it, after which walking contact mounts. This is a different sequence from freezing an initialized shell during pickup. |

The last case must not be described as an initialized shell already held by the carry script: its raw position can continue changing remotely until release. Its separately observed outcome also does not imply that arbitrary slot reuse is harmless.

## Reproducible controller predecessor and the only grant

[`pending_slot.py`](../../instrumentation/ink-shell-delivery/pending_slot.py) rejects every write except controller buttons/stick and the single specified `gObjectPool[32].oAction = 4`. It never writes Mario position/action/velocity, `usedObj`, `heldObj`, `riddenObj`, an object pose, a release timer, interaction type, hitbox, deletion flag, or the free list. The inherited startup enables debug level select, as in the existing accepted prefix; this is not a boot-to-level claim. Every input has A released, and each Wafel update checks that neither A-down nor A-pressed is present. There is no held-A prerequisite.

After the first 900 inputs, Mario settles into HOLD_IDLE, presses Z to place the small box, waits, and walks toward its actual drifting position before its release counter reaches 890. At the saved boundary (Wafel global timer 1805):

- Mario M = C = G = **(4652.5673828125, 0, 3462.84228515625)**, IDLE, real floor Y=0, no held or ridden object;
- the real small box is **(4562.3486328125, 0, 3444.6171875)**, released counter 890, active, tangible, native behavior;
- `usedObj` happens to retain slot23 from the earlier real carry. The new pickup is nevertheless selected through B and the collision/facing guard; it is not assigned by the experiment.

The tested menu starts B when the released counter is 894 through 900, and grants shell-box action4 at B-update 2 through 8: **49 cases**, with every update archived. Five cases end holding an initialized shell; two end holding an uninitialized shell. Of the initialized cases, only **counter897 / spawn-update5** freezes the already-initialized shell during pickup; `(896,7)`, `(896,8)`, `(897,7)`, and `(897,8)` fill an already-held vacant slot. The two uninitialized cases are `(896,6)` and `(897,6)`. The other 42 cases do not acquire a shell in this finite menu. These counts are not global reachability bounds.

For the selected counter897 pair, these are **post-update Wafel global timers**, not render-frame claims:

| Timer | Timely shell allocation (B-update5) | Late shell allocation (B-update6) |
|---:|---|---|
| 1813 | First B update; actual pickup sequence begins. | Same. |
| 1816 | PICKING_UP, used23, held null; donor reaches 901 and unloads; free-list head23. | Same. |
| 1817 | Real shell allocated into23; first native callback initializes type524288, intangible0, 50×50; Mario still not holding. | Slot23 still inactive, no shell spawned. |
| 1818 | Native pickup commits held23 and carry3; initialized fields retained. | Real shell allocated, then pickup commits before initialization; carry3, type0, intangible-1, 50×100. |
| 1829 | HOLD_IDLE with tangible frozen shell. | HOLD_IDLE with intangible uninitialized shell. |

The full samples include M/C/G, action/state/timer, animation/frame, floor cache, top-independent area state, held/used/ridden pointers, health, free-list head, shell-box action, slot23 behavior/command, position, type/subtype/status, tangibility, flags, parent, held state, dimensions, native action/timer/release fields, and collision slots. No warp/top timing is inferred: the top has not been opened in this predecessor.

For each of spawn5, spawn6, and spawn7, a native controller continuation walks while holding, settles, presses Z or B, and walks toward the released object for at most 80 updates: **six followups**. Both timely releases and both spawn7 releases mount; both uninitialized releases fail to mount. Timely drop leaves the shell at **(4376.41455078125, 41.43113708496094, 3402.406494140625)**; timely throw leaves it at **(4407.15478515625, 153.3899688720703, 3411.4599609375)**. These are the actual release coordinates, not supplied values. After the successful contact its status is 49152 and its initialized fields persist. The two heights illustrate why drop Y and HOLP throw Y cannot be conflated.

The complete 49-case menu and all six followups passed a second independent creation and controller replay with exact equality of all archived fields. `pending-results.json.gz` is the authoritative finite-search artifact; the log is a readable index.

## The first open step, and a narrower next experiment

**The first unproved gameplay condition here is making the real shell box reach its spawn action on the required update.** Our only post-entry grant skips that attack. In this demonstrated prefix the expiring donor is about 1,590 horizontal units from the roof shell box and at ground Y=0; the box is at Y=940. The player has not been shown attacking it during this history. Carrying the eventual shell high, generating useful high HOLP, reaching above the released shell, delivering a pusher, and synchronizing the pyramid top all remain additional open joins.

Source timing gives a useful target instead of demanding a simultaneous attack and pickup. In stock `exclamation_box_act_2`, an attack enters action3. Action3 executes with timers 0 through 7, setting action4 at timer7; the following SURFACE update spawns the shell. Since Mario runs after SURFACE, a direct Mario attack at update *a* is normally consumed at *a+1*, action3 runs at *a+2* through *a+9*, and contents spawn at *a+10*. `cur_obj_update` resets the timer after action changes. Successful `interact_breakable` returns true, so direct breakable attack and a later GRABBABLE selection in the **same interaction pass** are not the route; the delay explicitly allows different updates. Another object's attack would require checking that object's list order and actual attack capability.

The next focused experiment is to bring an expiring real small box close enough to a reachable shell-box attack, then synchronize the **native** attack with this ten-update schedule. The already-verified real carry and pending-pickup mechanism can be reused. The earlier failed roof waypoint menus do not settle whether Crazy Box bounce, terrain access, or a different donor position can accomplish that attack. This report supplies no Coq reachability theorem: the executable original-game mechanism and its initialization failure are narrower evidence than a complete controller route or a global obstruction.
