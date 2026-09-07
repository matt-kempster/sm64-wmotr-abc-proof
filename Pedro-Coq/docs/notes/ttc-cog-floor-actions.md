# TTC cog floor selection and particle actions

Source inspection on 2026-09-06, against pin
`9921382a68bb0c865e5e45eb594d9c64db59b1af`, for US and JP only.
The original findings below are source analysis and experiment requirements.
The later [slide-kick follow-up](ttc-cog-slide-kick.md) adds a conditional
generated-Clight caller proof and a ground-gap suffix execution. Neither is
a successful in-spot RNG-control witness.

## Two different floor queries

`src/game/mario_step.c:388`, `perform_air_quarter_step`, first resolves walls
at the attempted position. Its floor and ceiling queries use that resulting
position. The relevant landing branch requires a non-null floor and attempted
Y at or below the selected floor height. With a floor-to-ceiling gap at most
160, it preserves Mario's old X/Z, floor pointer and stored floor height,
sets Y to the queried floor height, and returns `AIR_STEP_LANDED`.

Floor detection is geometric. In `src/engine/surface_collision.c:401`,
`find_floor_from_list` tests the query's X/Z against the triangle edges,
computes its plane height, and accepts a query up to 78 units below that
height. Coordinates undergo the stock integer conversion. It selects the
first qualifying triangle in each list; `find_floor` compares the static
and dynamic results. Competing surfaces and list ordering therefore matter.
`vec3f_find_ceil` in `src/game/mario.c:547` queries from floor height plus 80.

Collision must also be loaded. `bhvTTCCog` in `data/behavior_data.c:5499`
sets its collision distance to 400. `load_object_collision_model` in
`src/engine/surface_load.c:754` requires Mario distance strictly below that
limit, normal time and the appropriate room. Rendered cog geometry alone
does not establish that its collision triangles are present. Near the
video-side rim, a small downward movement can exceed the upper cog's
400-unit distance even while Mario remains horizontally beneath it.

On the next Mario update, `update_mario_geometry_inputs`
(`src/game/mario.c:1314`) refreshes the floor beneath Mario's actual retained
position, after its own wall resolution. It sets `INPUT_OFF_FLOOR` when Mario
is more than 100 units above that floor. A floor under the attempted position
does not imply a floor under the retained position.

The observed back-of-cog setup has floor Y=-2088 and ceiling Y=-1934, a gap
of 154. The nearby edge setup instead initially selects the distant floor
at Y=-8191 and sets `INPUT_OFF_FLOOR`. Neither setup alone enters the Pedro
branch. Simply detecting a small gap or seeing Mario temporarily stationary
is insufficient.

## Why a landing result does not guarantee dust

The ordinary freefall air action selects `ACT_FREEFALL_LAND` after a landing
result, subject to its damage/stuck checks. On the landing action's update,
`common_landing_cancels` (`src/game/mario_actions_moving.c:1758`) runs before
`common_landing_action`. It checks steepness, sliding, first-person input,
the landing timer, A input and then `INPUT_OFF_FLOOR`. Cancellation can return
Mario to an air action before the dust calculation runs.

If the landing body is reached, nonzero processed analog input selects the
0.98 speed multiplier; neutral input at speed at least 16 selects floor-class
deceleration. Dust is requested only if the resulting speed is strictly above
16, after the ground step. A raw stick deflection inside the dead zone does
not satisfy the processed analog condition. The sampled cog floor is
`SURFACE_NOT_SLIPPERY` (21); its flat-floor neutral decrement is 6 with the
landing coefficient 2. Thus the illustrative 17-speed comparison would be
about 16.66 versus 11 if this floor remains referenced and the landing body
actually runs. A different retained floor can give different friction.

The current proof's speed witness is conditional on reaching that code.
The following implication has not been established:

`Pedro landing result -> uncancelled landing body -> accepted dust -> RNG draws`.

Nor has cancellation been proved for every possible cog Pedro state.

The later `inner_rim` placement now demonstrates the two-query distinction
in both US and JP: frame 1 enters the close-gap branch with retained floor
height -8191 and queried floor -2088. The trace matches cancellation of the
preceding freefall landing action. The cog moves beneath Mario again on
frame 2, allowing the landing body to run at a speed below the dust threshold.
These are transient observations with rotating cogs, not a preserving strategy.
See [the checked trace results](ttc-cog-placement-results.md#checked-inner-rim-pedro-returns).

## Other ordinary actions examined

| Action | Relevant source behavior | Remaining obstacle |
| --- | --- | --- |
| Dive, then dive slide | `act_dive` can select `ACT_DIVE_SLIDE`; that action does not use `common_landing_cancels`. `common_slide_action` requests dust on `GROUND_STEP_NONE`. | Must reach the dive landing and the correct ground-step result while preserving the spot. The close-gap ground branch returns a wall-stop result instead. |
| Slide kick, then slide-kick slide | `act_slide_kick_slide` requests dust after the step switch, including its wall-stop case; no speed-above-16 gate on this tail. The caller path now has a conditional Clight proof. | Reach the sliding phase after its possible airborne bounce, execute the actual helpers, preserve the spot through the resulting backward ground knockback, and establish downstream acceptance. |
| Ground pound | A completed landing can request mist; its particle helper contains gameplay RNG calls. | Startup zeros forward speed and can change Y, potentially removing the inward movement needed for the Pedro collision. |
| Sidling along a wall | `push_or_sidle_wall` can request dust at low speed, depending on wall angle and animation frame. | Requires a reachable walking action and the sidling branch; observed approach dust is not in-spot control. |
| Punch/kick impact particles | The tiny-triangle initializer uses a fixed movement table. | Visible particles alone do not establish additional RNG calls. |
| Camera effects | Shock and selected handheld-shake effects call gameplay RNG. | Ordinary camera-button movement is not itself one of those effects. No reachable preserving trigger at these cogs has been established. |

Jump sound variation using `gAudioRandom` is distinct from the gameplay
`gRandomSeed16` used by the cogs. Background RNG changes also do not establish
controller choice: two continuations from the same state must differ because
of the input, while both preserve the required geometry.

The inner-rim dive and ground-pound continuations have now been compared in
US and JP. The dive reaches a Pedro return above speed 16, then dive slide
and ground bonk without landing dust. Ground-pound mist occurs only after
Mario falls to a lower platform. Neither tested continuation preserves the
spot, and neither establishes a general impossibility result for that action.

## Remaining entry and action work

The [detour follow-up](ttc-cog-detour-followup.md) now records actual/intended/
queried positions, selected triangles, action transitions and particle requests.
It reaches a natural zero-speed frame on a failed rim return and a single
ground-pound close-gap landing in US/JP. The latter has a supporting floor and
zero horizontal speed; the full path changes Mario's position and cog yaw.
It cannot replace the missing sustained entry.

Connect the corrected mesh detour to sustained close-gap returns with the
relevant Mario and cog state preserved. Only then compare input continuations
and their ordered RNG draws. An alternative action is a candidate until its
entire preserving path is checked.

The user's later priority is to resolve possible RNG sources, starting with
slide-kick dust, even before a sustained entry is available. Conditional local
proofs can address that priority. The [new proof and inventory](ttc-cog-slide-kick.md)
keep their explicit state, helper and coverage obligations separate from the
missing preserving witness. Six additional slide-kick timing trials and one
JP comparison reach no Pedro return or sliding phase in the spot.
