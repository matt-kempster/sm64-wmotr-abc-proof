# Can the SSL cannon Buddy be moved?

14 November 2026. **Ordinary contact does not let Mario pick up or push the pink Bob-omb Buddy, and no legitimate SSL Area 1 cloning history that captures him has been established. However, his coordinates are not protected against all movement: his idle behavior runs terrain physics, and the real generic drop/throw helpers relocate him if Mario has acquired a held pointer to him.** That last condition is the missing gameplay connection, not something supplied by the word “cloning.” The conditional release experiment must not be reported as actor delivery for the Ink route.

The [combined verdict](ink-buddy-movement.md) records the final evidence and proof status. See the [Wafel experiment record](ink-buddy-movement-runtime.md), [original-JP replay instructions and results](../../instrumentation/jp-ink-buddy-movement/README.md), and [proof explanation](ink-buddy-movement-proof.md) with its [generated-code Coq statements](../../proofs/InkBuddyMovement.v). A runtime observation, a conditional helper theorem and a controller-reachable clone are separate claims.

This source audit starts from proof checkout `9229f9e2466782a142b595fda6d5cc64ee4c1016` and decompile checkout `36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`, including their existing local work. The actor, collision, interaction, pickup, dialog, behavior-script and helper source reviewed here matches stock pin `9921382a68bb0c865e5e45eb594d9c64db59b1af`; a scoped `git diff` against that pin was empty. The disabled local `SSL_SPAWNING_DISPLACEMENT_TAS_HACK` additions are not part of this argument. JP-specific NPC input uses B, not the later-version A-or-B mask.

The earlier [item interaction source audit](ink-item-combination-source.md), [clone controls](ink-item-clone-controls.md), and [clone lineage review](ssl1-clone-lineage-sizing-review.md) already distinguish native HOLDABLE actors from actors whose behavior is redirected to a carry script. The [native slide combination](ink-item-native-slide-combinations.md) and [combined verdict](ink-item-combination-verdict.md) establish why Buddy delivery matters: the selected useful handoff uses a supplied Buddy position. This note investigates that prerequisite; it does not invalidate the supplied-state handoff.

## The actual SSL actor

Area 1 contains `macro_bobomb_buddy_opens_cannon_1` at `(-5990, 0, -3871)`, yaw zero. The preset selects `bhvBobombBuddyOpensCannon`, not the black Bob-omb behavior. Its script:

- belongs to `OBJ_LIST_GENACTOR`;
- sets `OBJ_FLAG_HOLDABLE`, angle/distance/graphics flags and `OBJ_FLAG_PERSISTENT_RESPAWN`;
- sets `INTERACT_TEXT`, hitbox radius 100 and height 60;
- drops to the floor, sets home, selects the cannon role and runs Buddy initialization;
- resets intangible timer to zero and calls `bhv_bobomb_buddy_loop` each ordinary loop.

Initialization sets gravity 2.5, friction 0.8, buoyancy 1.3, and `INT_SUBTYPE_NPC`. HOLDABLE controls how a generic held-state helper handles an *already selected* object. It does not make this TEXT object ordinarily GRABBABLE. Home is not a command to teleport back to the spawn point.

Sources: [SSL macro entry](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/levels/ssl/areas/1/macro.inc.c#L12), [preset](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/include/macro_presets.inc.c#L33), [cannon Buddy script](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/data/behavior_data.c#L3777), [Buddy initialization and actions](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/behaviors/bobomb.inc.c#L292).

## Native behavior is not an unconditional position lock

In IDLE, Buddy copies current XYZ into `oBobombBuddyPosXCopy/YCopy/ZCopy`, then unconditionally calls `object_step`. These copies have no restoration reader in the reviewed source. He can turn toward Mario; an interaction status exactly equal to `INT_STATUS_INTERACTED` selects TURN_TO_TALK. Turning and talking do not themselves translate him. The cannon dialog sets save/dialog/camera state and eventually returns him to IDLE; it does not restore XYZ or install a walking speed. The loop clears interaction status afterward.

The black Bob-omb's patrol/chase/launch and held-state handlers occur earlier in the same file. They are not Buddy handlers. In particular, black Bob-omb throw velocity must not be attributed to Buddy.

Buddy's `object_step` has real position writers:

| Reached operation | Possible effect on Buddy | Additional condition |
| --- | --- | --- |
| `obj_find_wall` | Stores the wall query's corrected XYZ | A wall query must actually report contact; zero forward speed does not bypass this query. |
| `calc_new_obj_vel_and_pos_y` | Applies gravity, changes Y, snaps up to the floor and sometimes bounces | The selected floor must pass the preceding floor/steepness guard. |
| The near-floor slope calculation | Can create nonzero horizontal velocity from the floor normal | A suitable non-flat selected floor, finite arithmetic and the near-floor height guard; zero incoming speed alone is insufficient for stationarity. |
| `obj_update_pos_vel_xz` | Adds forward-speed/yaw components to X/Z | Uses the speed produced earlier in the same `object_step`. |

There is an analogous underwater integration branch. A missing floor or rejected steep floor takes a different branch; a missing floor is not permission to infer the ordinary gravity branch. The script lacks the common automatic MOVE_XZ/MOVE_Y flags, but that does not suppress the native `object_step` call. Merely setting `parentObj` to Mario also does not make raw Buddy XYZ follow Mario: Buddy lacks the corresponding relative-parent transform flag and lacks a held-state `obj_copy_pos` handler.

The generic `apply_platform_displacement(FALSE, platform)` helper can translate a non-Mario current object, but its only non-Mario native caller in this source is Bowser. Buddy does not automatically receive Mario-style displacement from a moving support. A moving collision mesh can matter to Buddy only through a separately reached terrain-query/correction path or another actual writer; merely finding a floor owned by an object is not enough to infer that displacement call. See [generic platform displacement](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/platform_displacement.c#L91) and [Bowser's explicit call](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/behaviors/bowser.inc.c#L1594).

For a settled zero-speed Buddy on a flat, unchanged floor with no wall correction or other position writer, the reviewed computation explains stationarity. Extending that to *all reachable histories* requires proving the terrain/contact and absence-of-other-writers invariant. This source audit does not assume that invariant in order to claim it. In particular, an externally supplied slope, velocity, moved collision mesh or held pointer is a different premise from the native spawn setup.

Sources: [idle calls physics](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/behaviors/bobomb.inc.c#L299), [terrain object physics](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/obj_behaviors.c#L133), [gravity and slope calculation](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/obj_behaviors.c#L256), [full step](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/obj_behaviors.c#L417), [common flag processing](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/engine/behavior_script.c#L905).

## Contact and two-body pushing

The NPC interaction pushes **Mario's movement position**, not Buddy. Talking also moves Mario away before changing Mario's action. Punching, diving, walking into him or standing beside him does not route his TEXT interaction through the ordinary grabbable handler. This is useful for the supplied-position Ink experiment precisely because Buddy provides a separate late NPC push on Mario.

The object collision pass only registers overlap records. It does not generally push both actors apart. Its list pairs are important:

- PLAYER can register Buddy because it tests GENACTOR.
- PUSHABLE tests other PUSHABLE actors, not GENACTOR. An ordinary Goomba, including one retaining its original list membership after fake holding, therefore does not acquire a Buddy collision merely by overlapping him.
- DESTRUCTIVE can register GENACTOR, including Buddy, subject to the distance/activity gates.

There is a real helper, `obj_resolve_object_collisions`, which writes *both* actors' X/Z and can cause transport cloning. It would be wrong to dismiss that helper as moving only its caller. However, its direct and transitive native callers are Goomba, Koopa, Pokey, Skeeter, Spiny and Wiggler. Their normal scripts place them in PUSHABLE or GENACTOR, never DESTRUCTIVE. The stock pair tests do not register one of those actors against a GENACTOR Buddy. This closes that named direct-shove proposal while the actor scripts, lists and collision records retain their stock provenance. It does not cover supplied/corrupted collision lists or a different behavior/list lineage.

The relevant destructive Bob-omb and small-box attack helper only ORs the other actor's interaction status with punch/attacked/interacted/touched-Bob-omb bits. It does not write the target's position or velocity. Buddy does not process those bits as knockback; its talk check requires exact equality to `INT_STATUS_INTERACTED`, so the attack bundle does not meet that test either. Crazy Box's callback runs its own movement/held logic and does not call the two-body resolver. These conclusions concern actor hitboxes; terrain-mesh correction by `object_step` is the separate mechanism above.

Sources: [NPC interaction](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/interaction.c#L1723), [collision pair selection](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/object_collision.c#L125), [two-body resolver](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/obj_behaviors_2.c#L549), [destructive attack helper](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/object_helpers.c#L2789), [Crazy Box callback](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/behaviors/jumping_box.inc.c#L57).

## A held Buddy can be relocated, conditionally

`mario_grab_used_object` copies `usedObj` into an empty `heldObj` without rechecking the species. For a HOLDABLE Buddy, `obj_set_held_state` sets parent and held state, preserving the native behavior script. It does **not** redirect him to the frozen `bhvCarrySomething*` scripts. The Buddy loop does not branch on `oHeldState`, so ordinary idle physics can continue while that pointer is held. A visibly held model is also not evidence that raw XYZ follows the hand.

The actual generic release stores are nevertheless explicit:

| Reached helper, with non-null `heldObj` pointing to Buddy | Raw destination written |
| --- | --- |
| `mario_drop_held_object` | `(HOLP.x, Mario movement Y, HOLP.z)` |
| `mario_throw_held_object` | `(HOLP.x + 32 sin(yaw), HOLP.y, HOLP.z + 32 cos(yaw))` |

Both set move yaw, call the held-state helper and clear Mario's held pointer. There is no interaction-type test blocking these stores. There is also no generic throw-speed initialization here: Buddy has no native HELD_THROWN handler that supplies the black Bob-omb or Crazy Box projectile velocities. Subsequent native physics can move the result again. Thus “the release helper can reposition Buddy” is a concrete conditional claim; “Buddy is now an ordinary throwable item” is not.

The [Wafel runtime investigation](ink-buddy-movement-runtime.md) exercises these actual helpers by retargeting `usedObj` during a real small-box pickup. That retarget is an explicit supplied pointer write. Its untouched prefix observes Buddy at `(-5990,0,-3871)` for 2,201 live boundaries. Sixteen supplied-Mario walk/B approaches at eight angles register contact without moving him. In the conditional pickup, his raw position remains at the spawn point through 64 held updates. Native Z-drop produces approximately `(5884.970703,51,3394.097656)`. The first completed update containing native B-throw ends at approximately `(5888.640137,160.459412,3362.269531)`: the throw helper writes HOLP Y approximately 162.959412, then Buddy's callback applies 2.5 units of gravity before that observation. After throwing, he reaches the Y=51 floor on release update 15, bounces with vertical velocity 11.25, and settles by update 24. These tests leave the required legal clone/capture history open. Exact inputs, edits and traces are retained in that record; the separate [JP record](../../instrumentation/jp-ink-buddy-movement/README.md) identifies which diagnostic was independently reproduced on original ROM. This source note does not count the supplied pointer as gameplay acquisition.

Sources: [generic grab/drop/throw](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/interaction.c#L288), [HOLDABLE dispatch](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/object_helpers.c#L267), [Buddy loop](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/behaviors/bobomb.inc.c#L438).

## Why talking does not supply the missing capture

The remembered `usedObj` pointer can indeed point to Buddy during NPC dialogue. That is not enough for a grab. These named candidate histories fail at specific source conditions:

| Proposed history | First obstruction in the stock path |
| --- | --- |
| Pick up Buddy directly because his flags say HOLDABLE | Ordinary grab input comes from GRABBABLE interaction; Buddy remains TEXT/NPC. Water grabbing also selects GRABBABLE. |
| Overlap a grabbable donor and Buddy in one interaction pass so Buddy replaces the donor pointer | GRABBABLE precedes TEXT. An accepted grabbable handler sets the input/interact object and returns true, ending that pass before TEXT. |
| Have Buddy's NPC callback replace `usedObj` while a donor pickup animation is pending | `mario_ready_to_speak` checks the action **group**, not the STATIONARY flag. PICKING_UP (`0x383`), DIVE_PICKING_UP (`0x385`) and PICKING_UP_BOWSER (`0x390`) are OBJECT-group actions (`action & 0x1c0 = 0x180`), not eligible stationary/moving groups. |
| Press B to talk during the pending pickup and retain that animation | `mario_can_talk` requires an IDLE flag or WALKING; these pickup actions satisfy neither. Accepted NPC talk would change the action to WAITING_FOR_DIALOG anyway. |
| Finish talking, then grab the still-remembered Buddy pointer | Dialog completion selects IDLE/HOLD_IDLE. A subsequent normal grab first selects a current grabbable interact object and rewrites `usedObj`; it does not resume the old pickup animation. |
| Dive-grab using an old Buddy pointer | Dive and dive-slide call `mario_check_object_grab` immediately before the generic grab. Successful checking writes `usedObj` from the current grabbable interact object. |

The delayed ordinary PICKING_UP helper is precisely where fake-object reuse can avoid a fresh type check: its source comment documents unloading/replacing the remembered slot during the animation. However, the required replacement must actually be a Buddy in the remembered donor slot. No reviewed SSL1 native callback spawns a new Buddy body. The entry macro loader is not a distance respawner; hiding/showing the same Buddy does not free/reallocate him. `OBJ_FLAG_PERSISTENT_RESPAWN` prevents a deactivated object's entry respawn record being permanently suppressed; it does not periodically allocate a replacement beside Mario.

Normal area reload can allocate an entry Buddy again, but normal Mario initialization clears held/used pointers and resets the action, so it does not preserve this pending fake pickup across the reload. Area 1 has no instant-warp table providing an action-preserving version of that proposal. These are closures of the named ordinary pickup, talk-overwrite and normal-reload paths. They are not a proof excluding every possible history involving slot corruption, unusual reloads or an as-yet-unidentified mechanism.

Sources: [grab selector](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/interaction.c#L418), [interaction ordering](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/interaction.c#L84), [break on accepted handler](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/interaction.c#L1780), [dialog readiness](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario_actions_cutscene.c#L324), [dialog completion](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario_actions_cutscene.c#L378), [fake-pickup call](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario_actions_object.c#L174), [persistent respawn meaning](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/object_list_processor.c#L377), and the linked [clone lineage review](ssl1-clone-lineage-sizing-review.md) for allocator/load-order and Mario-reset evidence.

## Exact remaining obligation

The useful positive target is a controller history that makes the live stock Buddy the object consumed by a reached pickup helper, or another identified engine operation that moves him from his native position. A replay beginning with `usedObj` or `heldObj` edited to Buddy tests what happens *after* that obligation. A replay beginning with his XYZ edited tests an even later obligation. Neither is a complete route.

A universal “Buddy can never move” theorem would need a reached-state invariant covering the actual flat support, no terrain correction, stock collision-list provenance, absence of generic release stores to Buddy, and all relevant allocation/pointer writers. A theorem assuming “Mario never holds Buddy” would not settle whether cloning can make Mario hold Buddy. Meaningful generated-code proof targets are instead the exact pickup/talk guard exclusions and the actual generic release stores, followed by a separate reachability argument. The source findings narrow those obligations without relabeling a local guard theorem, finite runtime check or conditional release as global retail-game impossibility or a delivered Ink actor.

The accompanying [InkBuddyMovement.v](../../proofs/InkBuddyMovement.v) states the exact cannon-script HOLDABLE certificate, conditional position/script preservation for the complete held-state pickup helper, and generated-body NPC-readiness exclusion for the three named pickup actions. It incorporates the existing drop-placement boundary: the drop Y store reads Mario movement Y, not HOLP Y; the reached placement changes the actor's Y if its old Y differs from that movement Y. It does not prove throw placement, later callback clamping, indefinite native stationarity or legal Buddy capture. The [proof explanation](ink-buddy-movement-proof.md) and [combined verdict](ink-buddy-movement.md) record compilation, assumption checks and how that local boundary is connected to the selected proof.
