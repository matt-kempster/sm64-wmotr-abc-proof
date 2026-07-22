# Static node-1E warp versus the exploding pyramid top

## Result

The modified test works because the warp was moved to Mario.  It cannot be
replicated with node 1E at its stock position under ordinary, synchronized
game state.

The two screenshots show approximately:

```text
pyramid-top object: (-2047, 1778.071, -1023)
Mario:              (-1928.73, 1869.65, -900.67)
hacked node 1E:     (-1928.73, 1869.65, -900.67)
stock node 1E:      (-2048,    768,    -1024)
```

The test therefore raised the warp by about 1102 units and placed its center
on Mario.  The stock warp is already aligned horizontally with the pyramid,
but it is far below the top.

## Question 1: can Mario stand on the top as it unloads?

Yes, and Mario does not technically need a standing action.  On the explosion
frame the pyramid-top native function sets `activeFlags = 0`.  The next
command in `bhvPyramidTop` still calls
`load_object_collision_model()`.  Later in that same object update,
`unload_deactivated_objects()` frees the slot, but the loaded dynamic surface
remains until the next frame begins.  `update_mario_platform()` runs after the
free and inspects neither `activeFlags` nor Mario's action.  Any
`gMarioObject->oPos` already within four units of that top-owned floor can
leave `gMarioPlatform` pointing at the freed top slot.  Mario could be
airborne, intangible, or disappeared; this is a geometric floor-proximity
test, not a grounded-state test.

This collision survives only for the remainder of that frame.  The next
normal object update starts with `clear_dynamic_surfaces()`, and the unloaded
top no longer executes its behavior to reload it.

## Question 2: can Mario touch the static warp and then rise to the top?

No through ordinary action movement.  Warp collision changes Mario's action
to `ACT_DISAPPEARED` before action dispatch.  `act_disappeared()` immediately
calls `stop_and_set_height_to_floor()`, which sets forward velocity and Y
velocity to zero and assigns `pos[1] = floorHeight`.  It does this again on
later disappeared frames; no ground or air movement step runs.

The floor queries make the vertical separation conclusive.  With Mario's
160-unit hitbox, contact with the stock warp's Y interval `768..818` requires
Mario's base Y to be in `608..818`.  `find_floor_from_list()` can return a
floor at most 78 units above its query:

```text
warp-contact query Y:             <= 818
floor used by ACT_DISAPPEARED:    <= 896
end-of-frame platform re-query:   <= 974
lowest spinning-top collision Y: >= 1281
```

Thus neither the disappeared snap nor the subsequent platform query can reach
the pyramid-top surface.  The fact that the explosion frame reloads that
surface does not help when Mario remains hundreds of units below it.

An old top pointer does not bypass this re-query.  Warp interaction does not
write `gMarioPlatform`, but the normal object update still ends with
`update_mario_platform()` before the delayed area transition starts.  With a
live Mario object, that update preserves neither an out-of-range pointer nor a
pointer over an unowned static floor.  It can finish with the top pointer only
if the floor query actually returns a top-owned triangle.  The bounds above
rule that out at the stock warp.

## Question 3: can both events happen in the same frame?

Not with the stock coordinates and synchronized Mario state.  Direct overlap
is impossible, and after warp interaction the disappeared action consumes the
same frame without upward movement.  Consequently the final
`update_mario_platform()` cannot select the pyramid top.

`proofs/StaticPyramidTopWarp.v` proves:

- `static_node1e_contact_cannot_already_stand_on_spinning_top`
- `disappeared_snap_from_static_warp_stays_below_top_collision`
- `platform_requery_after_disappeared_snap_cannot_find_spinning_top`
- `update_platform_does_not_require_a_standing_action`
- `platform_update_with_mario_returns_top_only_from_top_owned_floor`
- `stock_warp_update_cannot_preserve_or_create_top_pointer`
- `mario_object_near_top_can_seed_it_on_its_deactivation_frame`
- `stock_static_node1e_cannot_trigger_and_seed_exploding_pyramid_top`
- `static_pyramid_top_warp_final_frame_capstone`

The proof is backed by JP Clight facts for action dispatch, the disappeared
floor snap, the 78-unit floor-search buffer, pyramid-top collision loading,
deactivation, and object-update order.

## Boundary of the result

The impossibility theorem assumes stock node-1E and pyramid-top coordinates,
valid memory, and synchronized `MarioState`/Mario-object position at warp
collision.  It excludes position hacks, a pre-existing stale platform
displacement, arbitrary object-pointer corruption, and an externally created
Mario/object-position desynchronization.  Such a state could place collision
and floor queries at different coordinates, but it would already require a
separate glitch outside this route.  The hacked screenshots are therefore a
valid mechanism demonstration, not a stock setup.
