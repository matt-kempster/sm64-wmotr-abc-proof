# Node 1E held-object route

## Result

Static JP source analysis is sufficient for the proposed node-1E relocation
routes.  No observation build or input search is needed for these hypotheses.

| Proposal | Result |
| --- | --- |
| Touch 1E and retain `usedObj == 1E` | The equality occurs transiently, but the warp changes Mario to `ACT_DISAPPEARED` before action dispatch. |
| Convert that `usedObj` into `heldObj` | Not reachable through the enumerated stock pickup paths. |
| Reuse an old held-object slot for 1E | A transient alias may exist while the destination area is loading, but normal `init_mario()` clears it before a controllable update. |
| Skip the clear with `ACT_UNINITIALIZED` | This also skips destination Mario initialization and action execution, so it provides no frame that can drop 1E. |
| Redirect 1E to `bhvCarrySomething3` | Mechanically works if `heldObj == 1E` already; it is not an independent way to obtain that pointer. |
| Let `bhvWarp` redirect itself | Its behavior data and native loop contain no carry-command or behavior-command redirect. |

## Counterfactual downstream result

`proofs/MovedWarpPortal.v` grants `heldObj == 1E` only to determine what follows.
It distinguishes three operations:

- grab changes the current behavior command but does not write `oPosX/Y/Z`;
- drop writes live X/Z from `heldObjLastPosition` and live Y from Mario's Y,
  without changing the node parameter, interaction type, hitbox, or permanent
  behavior;
- warp contact sets `usedObj`, `interactObj`, and `ACT_DISAPPEARED`, but does not
  write `gMarioPlatform`.

Consequently, merely carrying the rendered object away does not move its
collision hitbox.  Dropping it does move the live entrance.  If the resulting
contact happens while Mario stands on an object-owned moving platform,
`update_mario_platform()` later in the object-update frame sets
`gMarioPlatform` to that floor owner.  Repeated owned-floor updates preserve
the pointer during the disappearance interval, and JP area spawning does not
clear it.

The source entrance position is not part of warp routing.  Node 1E still maps
to SSL area 2 node 14, and destination Mario initializes from that target
object at `(0, 5500, 256)`.  Therefore the hypothetical moves the entrance and
can seed spawning displacement; it does not move the destination and does not
make the initial held pointer reachable in stock control flow.

## Generated JP source certificate

`generated_jp_node1e_control_flow_source_certificate` is proved by
`vm_compute` over JP Clight modules.  It checks:

- `interact_warp()` stores its object argument in `interactObj` and `usedObj`,
  and the non-fading branch contains `ACT_DISAPPEARED` (`4864`);
- warp and grabbable handlers are at indices 4 and 29, and the dispatcher has
  the successful-handler `break`;
- interactions precede Mario action dispatch;
- `mario_grab_used_object()` copies `usedObj` to `heldObj` and then calls
  `obj_set_held_state()`;
- ordinary and Bowser pickup actions call that grab helper, while
  `act_disappeared()` does not; the warp action replacement preempts either
  prior pickup action;
- the underwater path first selects an `INTERACT_GRABBABLE` collision and
  overwrites `usedObj` before calling the same grab helper;
- normal area loading calls Mario initialization after destination loading,
  and `init_mario()` clears `heldObj`, `riddenObj`, and `usedObj`;
- `obj_set_held_state()` can replace a non-holdable object's current behavior
  command without replacing its permanent behavior; its direct callers are
  exactly Mario's grab, drop, and throw helpers, which operate on `heldObj`;
  `create_object()` initializes both current and permanent behavior pointers;
- `bhvWarp` calls `bhv_warp_loop`, contains no carry behavior address, and the
  native warp loop does not write either behavior pointer.

The additional `object_helpers.c` Clight input uses a documented generation-only
normalization from unsupported C `long double` constants to `double`.  All
seven affected literals are outside `obj_set_held_state()`, so the audited
function is unchanged by that compatibility step.

## Coq conclusions

`proofs/Node1EWarpControlFlow.v` proves:

- `node1e_warp_interaction_sets_used_and_interact`;
- `warp_touch_used_pointer_is_a_pickup_dead_end`;
- `simultaneous_grabbable_does_not_overwrite_node1e_warp_result`;
- `water_grab_cannot_select_warp_only_node1e`;
- `normal_area_change_clears_reused_held_alias_before_control`;
- `action_zero_can_preserve_alias_but_cannot_execute_drop`;
- `redirecting_node1e_command_requires_held_node1e`;
- `hypothetical_held_node1e_redirect_preserves_permanent_behavior`;
- `node1e_warp_loop_does_not_self_redirect`;
- `no_enumerated_stock_route_holds_or_redirects_node1e`;
- `generated_jp_clight_node1e_control_flow_capstone`;
- `generated_jp_clight_moved_node1e_capstone`;
- `generated_jp_clight_moved_node1e_platform_seed_capstone`.

The capstone links the generated JP source certificate to the finite route
model.  The model deliberately grants the strongest stale-slot premise: after
area loading, the old `heldObj` pointer may already alias the newly allocated
1E slot.  Normal initialization still clears it before control; action zero can
retain it only in a state with no loaded/dispatchable Mario action.

## Pointer classification

- `usedObj == 1E` and `interactObj == 1E`: expected briefly on warp contact.
- `heldObj == 1E`: not reachable through the enumerated stock routes.
- `gCurrentObject == 1E`: expected while 1E's own behavior runs; this does not
  assign Mario's held pointer.
- `gMarioObject->prevObj == 1E`: no relevant writer is supplied by `bhvWarp`.
- `gMarioPlatform == 1E`: an active `bhvWarp` has no platform collision for
  ordinary floor selection.  Raw stale-slot equality is a separate mechanism
  and is not ruled out by this held-object theorem.

## Scope

The closed world assumes valid C memory, stock object lifecycle and the audited
pickup, warp, load, and behavior-command paths.  It excludes arbitrary writes,
ACE, hardware faults, and any future independently proved pointer-writer bug.
It also does not disprove JP spawning displacement: the existing stale
`gMarioPlatform` mechanism remains intact.
