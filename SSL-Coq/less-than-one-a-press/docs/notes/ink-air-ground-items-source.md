# Airborne item contact: ground execution versus action labels

14 November 2026. This source review finds no additional ordinary **stock SSL
Area 1 item contact** that gives an incoming airborne action the shell's direct
route into a common ground slide. It does find a relevant broader-game
exception: Bowser's special pickup branch can select his grounded pickup action
without the ordinary AIR exclusion. Bowser is absent from stock SSL Area 1,
and that action's ordinary stationary snap copies the lowered position to
stored graphics instead of producing the crawl/slide split. This is a scoped
source review, not a global impossibility theorem or a new runtime witness.

Starting proof revision: `08df00c605127a172d3a28049e31d6f50f7bff98`.
Decompile checkout: `36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`.
The reviewed interaction, Mario action/step and action-constant files have no
diff against stock pin `9921382a68bb0c865e5e45eb594d9c64db59b1af`; JP branches
are the applicable ones. Existing high-shell, high-item-nudge and clone
inventory reports are credited below. No new Coq code, emulation or original-ROM
replay is added by this note.

## What is being asked

The useful question is whether a contact **starting with an airborne action**
selects and executes code that can produce the required ground-step/alignment
split. This differs from receiving an action with a STATIONARY or MOVING flag,
remaining visually suspended, or physically landing on a loaded actor surface.
`execute_mario_action` dispatches by `ACT_GROUP_MASK`, not those individual
flags. Its post-interaction null-floor guard can prevent every action handler
from executing even after an interaction changes the action ID.

| Contact or mechanism | Starting-air outcome | Stock SSL Area 1 and Ink consequence |
|---|---|---|
| Ordinary Crazy Box, small box or black Bob-omb plain contact | GRABBABLE fallback preserves the current action and pushes only X/Z | Present. They are useful pushers after the action exists, not direct action constructors. |
| Ordinary object pickup during `ACT_DIVE` | The grab helper can select the object, but explicitly skips `PICKING_UP`/`DIVE_PICKING_UP` while the action has AIR; the dive continues in air | Present grabbables. `act_dive` selects `DIVE_PICKING_UP` only after `AIR_STEP_LANDED`; the latter also has an OFF_FLOOR exit. |
| Cap, including Wing Cap or recovered Mario cap | Airborne cap collection changes cap flags without choosing the cap-putting action | Present. `PUTTING_ON_CAP` requires an existing IDLE-flag action or WALKING, so it does not construct that prerequisite from ordinary air. |
| Coins, 1-ups and ordinary stars | Coins heal/count without changing action; 1-up collection does not ground Mario; an ordinary star collected with AIR selects `FALL_AFTER_STAR_GRAB` | Present. The falling-star handler performs an air step and waits for LANDED before the ground star dance. The final Grand Star's special ending cutscene is a separate non-SSL exception, not a normal slide transition. |
| Pink Bob-omb or sign dialogue | `mario_can_talk` accepts IDLE-flag actions or WALKING, not ordinary airborne actions | Present. JP reading uses B, but B does not remove the entry-action guard. Plain NPC fallback can push without changing action. |
| Cannon | Contact can directly select `IN_CANNON`; its AUTOMATIC handler positions Mario at the cannon and copies stored graphics | Present once opened. STATIONARY flag is not a common ground action. Its normal launch requires A and selects `SHOT_FROM_CANNON`; it does not offer Z-to-crawl/slide. |
| Palm tree / pole grab | Qualifying air-action IDs select automatic pole-grab actions | Area 1 has the palm tree; the separately scripted poles are in Area 2. Pole positioning can select IDLE when meeting its actual floor or wall-near-floor test, and copies the resulting position into graphics; it is not the shell-style unsupported slide constructor. |
| Door interaction | Ordinary door/warp-door entry requires WALKING or DECELERATING; the special 70-star-door continuation requires IDLE and prior dialog state | No relevant Area 1 doors. These guards require a ground-action predecessor already. |
| Object warp | Ordinary warp selects `DISAPPEARED`; fading teleport and BBH entrance paths have their own guards/cutscenes | SSL warps exist, but these actions are not crawl/ground-slide execution. The ordinary upper warp also terminates the interaction pass. |
| Hoot | Qualifying airborne contact selects `RIDING_HOOT`, which dispatches in the AIRBORNE group and follows Hoot; letting go selects FREEFALL | Not stock SSL Area 1. Its MOVING flag does not make it execute ground-step code; holding A is required to remain riding, although an already-held A history is distinct from a new press. |
| Solid actor collision mesh | Normal air movement can return LANDED and select the corresponding landing/ground action | Large breakable boxes and Tox Boxes are stock SSL examples. This is actual support, not a hitbox-only shortcut. A live loaded surface at the required raw height and its later floor-cache history must be demonstrated. |

The rows distinguish incoming action guards from physical appearance. An
already-supplied IDLE action high above a floor might pass a cap/dialog guard;
that would still grant the very ground-action predecessor under investigation.
The table does not claim a whole-engine census of every callback-written action
or every later combination of interactions.

## Bowser is a real special-case source path, but not an SSL substitute

`mario_check_object_grab` has two different branches. Its ordinary-object branch
checks `!(m->action & ACT_FLAG_AIR)` before requesting a pickup action. Its
`bhvBowser` branch instead checks the relative facing angle in
`[-0x5555,0x5555]`, saves Bowser as `usedObj`, and requests
`ACT_PICKING_UP_BOWSER` without that AIR test.

An incoming DIVE can reach this helper after the GRABBABLE interaction supplies
the fresh grab input. `act_dive` notices that its action changed and returns
true, allowing the action loop to dispatch the new object action. Bowser's
native behavior is GRABBABLE/HOLDABLE. The ordinary tail-anchor callback must
make Bowser tangible; earlier damaging/terminating interactions, the facing
guard, valid object state, and the nonnull floor/action-dispatch guards remain
real prerequisites. This note does not supply those prerequisites as a replay.

`ACT_PICKING_UP_BOWSER` is an OBJECT-group action with a STATIONARY flag.
Its handler has no OFF_FLOOR exit and calls `stationary_ground_step`. The common
object-action cancels still handle water, squishing, health and quicksand.
On an ordinary floor, stationary ground step sets movement Y to cached floor
height and **then copies the new movement position into `gfx.pos`**. Windy or
moving-sand floors instead take its real ground-step branch. Therefore even
this broader-game airborne-to-ground-code exception is not automatically the
stopped-crawl/common-slide alignment producer needed by Ink.

Bowser is absent from the reviewed stock SSL Area 1 selectors. The existing
fake-pickup mechanism does not convert a Goomba, box or other cloned actor's
behavior identity into `bhvBowser`. A hypothetical frozen Bowser also retains
his own initialized tangibility/status conditions; the source path is not an
actor-delivery or cloning witness.

## Cloning and genuine support

A fake pickup can preserve an initialized nonholdable actor's interaction type,
subtype and dimensions while switching its callback to a stopped carry script.
That can matter for positioning and lifetime. It does not remove the Mario-side
AIR check for ordinary pickup, give a cap or NPC an unrestricted action setter,
or change a species-specific Bowser comparison into a general grab branch.
Action flags such as MOVING must not be treated as substitutes for dispatch
groups or actual executed movement functions.

A surface-bearing object is a different proposal. A native loaded collision
mesh can genuinely support Mario and thereby create a landing action. But
freezing the former behavior can stop future collision loading after the
per-update dynamic-surface clear. The surface lifetime, loading distance,
actual coordinates and transition from the high supporting floor to the fresh
low cache remain obligations. Nothing here proves a high support route
impossible; it simply keeps that route distinct from contact-only action entry.

The companion [high solid-support experiment](ink-high-solid-support.md)
records a conditional positive using a live large breakable box as real support:
native landing/B input creates a ground slide, followed by a nonmounting-shell
push and useful handoff. That is a different entry mechanism from an unsupported
hitbox contact, and is consistent with this review. The live high box is a
supplied prerequisite; delivering its collision surface still needs a history.

For that delivery question, the stock `bhvBreakableBox` script is a SURFACE-list
actor with the graphics-update flag, collision data, collision distance 500,
`bhv_init_room`, and a loop containing `bhv_breakable_box_loop` followed by
`load_object_collision_model`. It does **not** set HOLDABLE or execute an initial
`DROP_TO_FLOOR`. Its initializer adjusts loot/animation-related state (and scale
for the giant variant); its normal loop refreshes hitbox/model and can break
the box, but contains no ordinary XYZ movement or held/thrown transport path.
SSL Area 1 selects two fixed no-coin boxes at `(5900,51,4400)` and
`(5900,51,2311)`. A reference search over the inspected C sources finds
`bhvBreakableBox` only in its definition/declaration and three macro-preset
entries; it finds no named child-spawn call selecting this behavior at a high
parent's coordinates. This is a review of those ordinary source paths, not a
whole-history proof about every generic allocator or stale-pointer event.

The ordinary fake-pickup path for this non-HOLDABLE actor instead changes its
current behavior command to a carry script whose loop stops at `BREAK`. That
stops the mesh reload. Dynamic floor vertices are transformed and copied when
`load_object_collision_model` executes: changing a frozen box's raw XYZ through
HOLP placement does not move the previously loaded floor triangles. They are
normally removed by the next dynamic-surface clear. Time stop is an explicit
exception to clearing, but retaining old transformed triangles does not itself
rebuild them at the new high position. Thus a collision-only frozen hitbox and
a live reloaded support surface are different resources. A high live box,
retained/rebuilt mesh history, or another support-delivery mechanism must be
shown rather than inferred from cloning alone.

## Source and earlier evidence

The reviewed source paths are: `interaction.c:387–448` (ordinary versus Bowser
grab), `769–831` (star selection), `903–1076` (doors/cannon), `1510–1581`
(pole/Hoot), `1583–1749` (caps/grabbable/text); `mario_actions_airborne.c:725`
(dive) and `1850` (Hoot); `mario_actions_object.c:175–234` (pickup guards) and
`315–437` (Bowser actions); `mario_actions_automatic.c:54` (pole positioning)
and `674` (cannon); `mario_actions_cutscene.c:665` (fall after star);
`mario_step.c:236` (stationary ground step); `mario.c:1699` (dispatch/null-floor
guard); `behavior_data.c:1957` (Bowser); and `behaviors/bowser.inc.c:11–70`
(tail tangibility), and `behaviors/mushroom_1up.inc.c:3` (1-up collection).
The large-box delivery review additionally reads `behavior_data.c:1743`,
`behaviors/breakable_box.inc.c:3`, `behaviors/switch_hidden_objects.inc.c:15`,
`object_helpers.c:267`, `behavior_data.c:3925`,
`engine/surface_load.c:643,754`, and `object_list_processor.c:644`.
Stock Area 1 selection comes from `levels/ssl/script.c`,
`levels/ssl/areas/1/macro.inc.c`, and its collision special-object table.

Earlier project records: [high unloaded entry](ink-high-unloaded-entry-source.md),
[high item nudges](ink-high-item-nudge.md),
[clone inventory](ssl1-clone-enemy-inventory.md), and
[other interaction placement](ssl1-other-interaction-placement-review.md).
No additional stock-SSL unsupported-contact replacement for the shell is
established by this source review; the companion live-solid landing positive
is a different mechanism. Enemy-specific damage, bounce, shock, grab and release
paths require their separately scoped review.
