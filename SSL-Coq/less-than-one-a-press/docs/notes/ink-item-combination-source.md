# JP item combinations: ground-action entry, sideways pushes and clones

14 November 2026. **The missing ingredient is a usable crawl/ground-slide
action plus the sideways shove, not merely a height change.** A
collision-only Goomba can still bounce Mario, but that does not construct
the required grounded movement action. A successful shell mount does
construct RIDING_SHELL_GROUND, from which Z can request the relevant slide;
it also ends the interaction pass before the box or NPC shove. This full
table review found no overlooked post-shell handler that converts an
ordinary airborne Mario into the productive common ground-slide path.

**Later multi-update positive:** the [native-entry combination](ink-item-native-slide-combinations.md) and [combined verdict](ink-item-combination-verdict.md) now demonstrate a useful handoff from supplied low AIR1810, with native shell/Z action entry and later stock Box/Buddy cuts. The selected case passes original JP. The one-pass exclusions below do not exclude that supported multi-update sequence; its actor delivery and initial approach remain supplied.

Ordinary bounce → box, and certain three-actor chains, remain source-permitted
ways to change height and horizontal position. They are secondary
diagnostics of the interaction ordering, not solutions to the missing
ground-action constructor. An action ID at update end, retaining that ID
until another update, and actually reaching ground-step/floor-alignment
code are three different requirements.

This is a complete classification of the **31 entries in Mario's JP
interaction table**, with effect-equivalent branches grouped together. The
header's remaining defined type, UNKNOWN_31, has no table entry; type zero
also has no handler. It is not a theorem covering every behavior callback,
solid collision surface, corrupted object reference or multi-update route.
No new Coq proof, original-ROM replay or controller-reachable setup is
claimed by this source review. The companion runtime and clone studies own
their measured results.

The source checkout is `36fbf8d693a9fc2bdec0c77402f8e96d07d2f461` with existing
local changes preserved. The proof checkout at this inspection is
`08b72af44fbb54aaef3ed7f8be399868ba75db98`. Stock SSL Area 1 placements are
compared against `9921382a68bb0c865e5e45eb594d9c64db59b1af`, excluding the
local disabled TAS-hack additions. The applicable JP conditionals are used:
for example, talking/reading uses B, not the non-JP B-or-A mask.

## Which contacts can supply the required movement action?

Here “movement action” means walking, crawling or an applicable ground
slide, as in the user's question. It does not mean changing the numerical
value of M.Y. These are the important constructor/retention branches before
the full effect inventory:

| Contact family | Ground-action entry or retention | Can it also leave the needed later sideways shove available? |
| --- | --- | --- |
| Successful shell mount | Really selects RIDING_SHELL_GROUND without requiring actual support; Z can then select CROUCH_SLIDE during dispatch | No later actor that pass: mount returns true. It needs an earlier continuing shove, or a separately valid later-update predecessor. |
| Already-riding shell contact | Continues without replacing the current action | A later box/NPC can push, but the earlier history that retained a usable high riding action remains an obligation. |
| Failed shell mount | Can push X/Z | Does not construct a ground action; an airborne input action stays airborne here. |
| Goomba/Pokey/Klepto ordinary bounce | Keeps the input airborne action; sets upward velocity | A later box/NPC can push, but neither supplies ground-action entry. |
| Fly Guy twirl bounce | Changes to TWIRLING (or the initializer's squished/quicksand JUMP substitute), not a ground slide | Terminates before later pushes. |
| Enemy damage/knockback | Air input selects air knockback; ground knockback presupposes a different input action | Effective hit terminates. Later air-knockback landing/recovery is a separate floor/action history. |
| Shock | Air contact enters SHOCKED with arg 0, whose handler performs an air step until landing | Terminates; its non-AIR-looking ID is not evidence of common-slide execution. Stock SSL Area 1 has no shock actor in this inventory. |
| Grabbable pickup | Sets a pickup input; airborne DIVE can acquire the object while remaining DIVE | The grabbable handler terminates; `act_dive` selects DIVE_SLIDE/DIVE_PICKING_UP only after AIR_STEP_LANDED, not merely after the grab. |
| Cap, NPC/sign dialogue | PUTTING_ON_CAP/dialog entry requires an already idle/walking state | Accepted entry terminates. Rejected NPC contact can push without changing the action. |
| Cannon, pole, tornado, Hoot, warp, grabbed-Mario | Select their automatic/air/cutscene actions, not the productive crawl/common-slide code | Accepted entry terminates; later release, landing, positioning and terrain checks are separate histories. |
| Punch recoil | Can change PUNCHING to MOVE_PUNCHING | This is a ground-to-ground change with velocity recoil, not an air-to-ground constructor or an immediate X/Z shove. |

For the proposed **ordinary bounce → nonmounting shell → box** triple,
take FREEFALL as the concrete input action and require the box's ordinary
fallback branch; a DIVE/grab or kick branch needs separate guards. The
first handler leaves that AIR action unchanged and sets Y
velocity to +30. The shell's falling-from-above test therefore fails; its
alternative pushes X/Z and continues without changing that action. The
ordinary box fallback then pushes X/Z and continues. There has been no
ground-action constructor anywhere in that pass. The next code is the
actual selected airborne handler, which must still satisfy a real landing
or other transition before a later ground slide can exist.

## What a push, bounce and action change mean here

**M** is `MarioState.pos`; **C** is Mario's object `oPos`; **D** is stored
`header.gfx.pos`. D is not the render matrix or the place the model is
necessarily drawn. This matrix measures immediate effects while the
interaction pass is running, before the selected action handler executes.

- A **push** changes M.X/Z immediately. The ordinary push helper
  (`interaction.c:616–647`) wall-corrects the proposed X/Z and commits only
  when a local destination floor query succeeds. It does not update
  Mario's cached floor pointer/height. Its wall call passes M.Y through
  the wall resolver, but that resolver preserves Y; this is not a height
  snap. Bully collision additionally has its own X/Z writes.
- A **bounce snap** changes M.Y immediately to actor origin Y plus its
  live hitbox height (`515–522`). It also sets vertical velocity to 30 or
  80. The stored collision and graphics positions are separate records.
- **Velocity/recoil** changes speed fields. `mario_set_forward_vel`
  changes forward/slide/velocity components; it does not move Mario's
  position. Recoil cannot substitute for an X/Z shove before a stopped
  quarter-step which never commits its proposed movement.
- An **action change** selects an ID and initializes action state. It does
  not mean that the corresponding action handler has run. The setter and
  its moving/airborne/cutscene initialization can change velocity,
  flags, animation metadata and timers; these inspected paths do not copy
  M into C or D or directly relocate M. Later action execution can do so.
- A true handler return **ends the interaction pass**, even when no action
  changed. A false return continues, even in a few branches that changed
  an action. Collection of a cap and ignored clam contact are important
  examples of terminating without the desired action change.

Under ordinary valid, distinct Mario/actor storage, the reviewed handler
families do not directly update C.XYZ or D.XYZ. Dropping a held actor writes
**that actor's** position, not Mario's C. Tornado/pole/sign bookkeeping
writes auxiliary Mario-object fields, not its collision position. This
distinction excludes an assumed arbitrary pointer alias between Mario and
the held/enemy object; it is not a proof against such corruption histories.

## Complete table, in execution order

The machine-readable [matrix](ink-item-combination-matrix.json) contains
all 31 rows and 85 grouped branch records, including immediate M.XZ, M.Y,
velocity, action, return value and other record effects. Its ordered
type/handler pairs were checked against `interaction.c:84–116`. In the
table below, “ends” means the rest of the actor table is skipped, not that
Mario's entire update has necessarily ended. “Absent” means no stock Area
1 source in the reviewed placement/child inventory, not a global cross-area
or corrupted-history theorem.

| Order / type | Immediate position and speed effects | Action/continuation branches | Stock SSL Area 1 source |
| --- | --- | --- | --- |
| 1 COIN | No M change | Collect/heal/status; continues; 100-coin threshold can spawn a star | Coins |
| 2 WATER_RING | No M change | Heal/status; continues | Absent |
| 3 STAR_OR_KEY | No M change; falling-star initializer stops forward speed | Accepted healthy collection chooses cutscene and ends; AIR normally chooses FALL_AFTER_STAR_GRAB | Stars; no key source |
| 4 BBH_ENTRANCE | No M change | Accepted entry chooses spin/jump and ends; already-entering continues | Absent |
| 5 WARP | No M change | Accepted fading or ordinary warp ends; ordinary selects DISAPPEARED; rejected paths continue | Real upper/lower and fading warps |
| 6 WARP_DOOR | No M change | Usable entry ends; missing-key message can change to automatic dialog and **continue** | Absent |
| 7 DOOR | No M change | Door/message entry ends; other branches continue | Absent |
| 8 CANNON_BASE | No immediate M change | IN_CANNON entry ends; already-in-cannon continues | Opened cannon |
| 9 IGLOO_BARRIER | X/Z push, padding +5 | Sets used/interact object and continues | Absent |
| 10 TORNADO | No immediate M change; zeroes forward/slide velocity | Captures into TORNADO_TWIRLING and ends; already twirling/squished continues | Tweester |
| 11 WHIRLPOOL | No immediate M change; forward speed zero | Capture ends; already captured continues | Absent |
| 12 STRONG_WIND | No immediate M change; Y velocity 12, forward −24 | GETTING_BLOWN entry ends; already blown continues | Absent |
| 13 FLAME | No immediate M change; burning-jump initializer gives Y velocity 31.5/forward 8 | Dry effective hit ends in burning action; water extinguish or ignored contact continues | Spawned flames |
| 14 SNUFIT_BULLET | No immediate M change; knockback velocity on effective hit | Damage ends; metal/ignored branch continues | Absent |
| 15 CLAM_OR_BUBBA | No immediate M change; possible knockback velocity | Eaten/damage **and final ignored branch all end** | Absent |
| 16 BULLY | X/Z push; collision solver may write additional X/Z; recoil/transfer velocity | Effective branches end; ignored branch continues without push | Absent |
| 17 SHOCK | No immediate M change | Effective SHOCKED/WATER_SHOCKED entry ends; ignored continues | Absent |
| 18 BOUNCE_TOP2 | Same ordinary/twirl bounce and recoil branches as BOUNCE_TOP | Ordinary top bounce continues; twirl/damage ends | No Area 1 writer found |
| 19 MR_BLIZZARD | No immediate M change; possible knockback velocity | Damage ends, ignored continues | Absent |
| 20 HIT_FROM_BELOW | Top bounce snaps Y; below hit only sets Y velocity 0; attack recoil changes horizontal speed | Ordinary bounce/attack continues; twirl or damage ends | Klepto |
| 21 BOUNCE_TOP | Ordinary top bounce snaps Y, sets Y velocity 30; twirl sets 80; attack recoil is velocity only | Ordinary bounce/attack continues; twirl or damage ends | Goomba, Pokey part, Fly Guy |
| 22 DAMAGE | No immediate M change; knockback velocity | Effective damage ends; ignored continues | Bob-omb explosion child |
| 23 POLE | No immediate M change; Y/forward velocity zero | Eligible air grab ends; rejected grab continues | Palm tree |
| 24 HOOT | No immediate M change | Eligible riding entry ends; rejected continues | Absent |
| 25 BREAKABLE | No immediate M change; recoil or below-hit Y velocity 0 | Accepted attack ends; ignored continues; apparent ordinary-bounce arm cannot pass mask | Large/exclamation boxes |
| 26 KOOPA | Same handler as BOUNCE_TOP | Ordinary bounce continues; twirl/damage ends | Absent; a shell is a different type |
| 27 KOOPA_SHELL | Successful mount does not push; failed mount can push X/Z, padding +2 | Successful mount sets RIDING_SHELL_GROUND and ends; failed/already-riding branch continues | Stock shell-box child |
| 28 UNKNOWN_08 | Punch recoil is velocity only; possible damage knockback | Punch continues; damage ends; ignored continues | Spiny type, absent here |
| 29 CAP | No immediate M change | Valid collection **always ends**; PUTTING_ON_CAP only from IDLE-flag/WALKING | Wing cap; normal cap through cap history |
| 30 GRABBABLE | Fallback X/Z push, padding −5; kick/trip is velocity only | Kick continues early; grab-Mario entry ends; pickup eligibility sets input and ends; ordinary fallback continues | Crazy Box, small box, Bob-omb |
| 31 TEXT | NPC fallback pushes X/Z, padding −10; untagged fallback +2; sign only stores interpolation deltas | Accepted NPC talk also pushes then ends; sign/talk entry needs idle/walking; rejected NPC continues, rejected sign does not push | Bob-omb Buddy NPC and signs |

`INTERACT_UNKNOWN_31` is defined at `interaction.h:39` but has no dispatch
entry or identified writer. Zero installs no table bit. Either kind of
actor can still occupy a collision-list slot if its hitbox is registered;
neither acquires an invented push handler. Tox Boxes, pyramid surfaces,
terrain hazards and other behavior-driven effects need their own source
paths rather than being inferred from an interaction type of zero.

The remaining post-shell branches were checked explicitly. An accepted cap
cannot let a following box push run. NONE of the defined ordinary AIR
actions has the IDLE flag; the six IDLE-flag actions are IDLE,
START_SLEEPING, PANTING, STANDING_AGAINST_WALL, COUGHING and SHIVERING. Thus
cap/NPC/sign guards do not provide a hidden ordinary-air-to-ground entry.
GRABBABLE's pickup eligibility can recognize an airborne DIVE, but the
later `mario_check_object_grab` only selects PICKING_UP/DIVE_PICKING_UP when
the action lacks AIR. The GRABS_MARIO subtype can select GRABBED, but its
stock users are not Area 1 actors and it ends the pass.

Two subtleties matter for branch completeness. `check_object_grab_mario`
pushes on its failed-grab path, then GRABBABLE can eventually call the push
helper again; these are two helper invocations on one actor, not two
independent objects or an automatic double-sized displacement. Also, the
loop's invulnerability snapshot and initial intangible test are not a
general recheck after every continuing handler. The absent missing-key
door branch therefore should not be silently treated as terminating merely
because it selected a dialog action.

## Collision lists and clones constrain combinations

Collision detection precedes this pass and uses **C** and each actor's raw
hitbox coordinates. It requires horizontal distance strictly less than the
sum of radii, and overlapping vertical intervals
`[oPosY-downOffset, oPosY-downOffset+height]`, including touching endpoints.
Both objects must have room in their four-entry collision lists. The
player lists are checked in the actual object-list order (polelike, level,
general actors, pushable, surface, destructive after player peers), not in
the desired order of a recipe (`object_collision.c:25–57,113–187`).

The handler table then orders **types**, not collision-list positions.
For each present type, `mario_get_collided_object` takes the first actor
whose type equals it. The loop clears that type's bit before checking
INTERACTED and calling the handler (`interaction.c:403–416,1780–1804`).
Consequently:

- Two Goombas, or Goomba plus Fly Guy, do not give two BOUNCE_TOP handlers
  in one pass. Two grabbable boxes likewise do not give two box handlers.
- Skipping the first actor because it is already INTERACTED does not try a
  second actor of that type. The skipped actor can still consume capacity.
- A shove or bounce does not rebuild the precomputed collision list.
  Every actor in a three-actor recipe must already have collided with C;
  it cannot become newly eligible simply because the first handler moved M.
- For later handlers already in the list, classifiers and push distances
  read the changed **M**. They do not rerun the original C hitbox overlap.
- Four total entries is a budget shared with coins, warps, stale clones and
  any other detected actor; four useful handlers are not guaranteed.

The existing [clone inventory](ssl1-clone-enemy-inventory.md),
[lineage/size review](ssl1-clone-lineage-sizing-review.md),
[collision-clone source](ink-collision-clone-source.md) and
[runtime comparison](ink-collision-clone-runtime.md) remain prerequisites,
not superseded results. For a non-HOLDABLE actor, the real held-state helper
redirects behavior execution to a carry script ending in BREAK. It does
not replace its interaction type/subtype, live dimensions or tangibility
with a new generic collision rule. Common object processing can continue.
For HOLDABLE actors such as Crazy Box, Bob-omb, small box and Bob-omb Buddy,
ordinary held-state writes do not by themselves stop the native callback;
a forced BREAK freeze is a separate supplied diagnostic.

A frozen initialized Goomba therefore still uses BOUNCE_TOP with its live
radius/height/down-offset (ordinary refreshed regular values 108/75/0).
Pokey parts normally use 120/60/30; Klepto 160/250/0 and HIT_FROM_BELOW;
Fly Guy 105/90/0 and TWIRL_BOUNCE before the documented fire-growth history.
The copied fields must actually exist at capture; allocation does not
inherit an old donor's enlarged hitbox. Placement does not grant an
arbitrarily tall Goomba. An ordinary top classification requires negative
Y velocity and M.Y above the actor origin, so the immediate upward snap is
controlled by the live height, not by choosing an arbitrarily high origin.

The stock cannon Buddy is specifically local, not a foreign-NPC fixture:
the Area 1 macro list places it at (−5990,0,−3871). Its script installs
TEXT, radius 100, height 60 and HOLDABLE; native initialization sets the NPC
subtype (`data/behavior_data.c:3777`, `behaviors/bobomb.inc.c:292`). Each
executed script loop makes it tangible before its native callback; that
callback clears interaction status, and its idle action runs `object_step`.
Its visibility radius 3000 is not itself a changed tangibility field.
Thus a source-permitted NPC shove is available from a stock species, but
high placement, any held/drop history and subsequent native motion are
still distinct prerequisites. A different absent NPC species would be a
foreign-actor diagnostic. A forced frozen Buddy is not the automatic
result of its ordinary HOLDABLE flag.

`clear_object_collision` clears lists/type masks and decrements positive
intangible timers; it does **not** clear `oInteractStatus`. Attack/bounce
sets INTERACTED. If the native callback that used to clear it has stopped,
a fresh collision list next update does not automatically permit another
bounce. Ordinary box pushing does not itself set INTERACTED, so its repeat
behavior differs. Shell STOP_RIDING is also a distinct bit, not synonymous
with INTERACTED. Actual status lifetime must be logged, not replaced with
“all clones are single-use” or “all clones repeat forever.”

Signed or dead-actor corner cases do not change this action classification.
A genuinely retained negative live hitbox height could make the bounce
formula move M downward, even below zero; it must still pass the actual
collision interval, classifier and status tests. The existing Fire Fly Guy
size review allows a negative shrinking history and explicitly separates
radius, height and timing. It does not grant arbitrary signed dimensions
to a clone. Fly Guy's twirl subtype still ends the interaction pass, and a
downward snap alone does not enter a common ground slide. A later air-step
landing can change actions, but that call also refreshes stored graphics
from its final movement position. A raised, already dead Goomba is not a
new solid floor: its normal shared death paths become intangible, and
freezing a slot does not automatically restore tangibility, clear attack
status or resume the constructor. These are scoped source checks, not a
global bound on every abnormal actor history.

## Source-permitted pairs and triples, and the first missing condition

These are effect sequences under the stated collision/guard hypotheses,
not new runtime witnesses or delivered actors. “Ordinary bounce” means a
non-twirl top bounce from an ordinary airborne action. Where a diagram has
arrows, it follows table order regardless of actor position.

| Sequence | Effects source permits | First failure or remaining condition for the Ink producer |
| --- | --- | --- |
| Goomba or Klepto ordinary bounce → grabbable box | M.Y snap and Y velocity +30, then X/Z push; cache remains the earlier cache | Action is still airborne. No native crawl/common-slide entry is supplied. |
| Ordinary bounce → nonmounting shell → grabbable box | Y snap, then two distinct X/Z pushes within three types | Positive Y velocity makes the shell's descending mount fail; the shell push preserves AIR. Actual floor queries and all three original C overlaps must work. |
| Ordinary bounce → grabbable box → NPC TEXT | Y snap followed by two different late push types | NPC cannot talk from the ordinary air action; its fallback push preserves AIR. Buddy delivery and continued behavior remain separate. |
| Nonmounting shell → grabbable box → NPC TEXT | Up to three X/Z push helpers | No vertical snap or ground-action conversion. A useful earlier state is still required. |
| Klepto bounce → Goomba contact → box | First bounce is possible because HIT_FROM_BELOW is earlier | After +30, the Goomba cannot also classify an ordinary descending top bounce. Its damage branch can terminate before the box; ignored/attack branches need their own guards. |
| Fly Guy twirl bounce → any later box/shell/NPC | Y snap and action/velocity change | TWIRL_BOUNCE returns true, so later handlers do not run that pass. |
| Descending shell mount → box/NPC | Native ground-action conversion; Z may later enter common slide | Successful mount returns true before either later push. |
| Ordinary bounce → shell mount → box | First Y snap is possible | Bounce's positive velocity prevents descending mount; even a successful mount would end before box. |
| Igloo push → shell mount | Earlier X/Z push plus native ground-action conversion is permitted by source | No stock SSL igloo barrier. This is an absent-actor counter-pattern, not a stock construction. |
| Box push → accepted NPC talk | X/Z push(es), then WAITING_FOR_DIALOG | Already requires idle/walking, and is not a high air-to-slide constructor. |

An earlier enemy attack that merely recoils can preserve a descending
approach, but provides no X/Z displacement before the shell. A high
already-established crawl/slide can of course use a later box push; that
is the supplied-state control, not the predecessor under investigation.
The floorless retained-shell alternative is separately bounded in
[the unloaded-entry source note](ink-high-unloaded-entry-source.md) and
[native floorless control](ink-floorless-shell-entry.md): the initial
double floor miss queues death before the mount.

The bounded diagnostic for these new combinations is to log
the ordinary-bounce/box and ordinary-bounce/nonmounting-shell/box passes
at raw Y=25000 and 67277, preserving actual initialized clone dimensions
and status. It must distinguish the immediate Y snap and pushes from the
later AIR step, and verify whether any actual native ground-action entry
occurs. A positive movement change alone is not an accepted warp, top
capture/retention or useful displaced Area 2 arrival. Native tests and the
clone lineage are separate obligations even if the source ordering permits
all three contacts.

## Native callbacks outside the interaction table

The table is not the entire object system. This follow-up inspected the
named stock SSL callback families, generic push/position helpers, their
call sites, and the ordinary object-list schedule. It found a real tree
callback push and a real NPC action callback; their ordering/guards matter.
The supplemental list in the JSON records these separately from the 31
interaction types. This is a bounded source review, not a generated
whole-program callback-frame theorem.

The ordinary schedule is (`object_list_processor.c:172,563–581,641–672`):

1. Clear dynamic surfaces, then run SPAWNER and SURFACE callbacks.
2. Apply the previously captured Mario platform displacement.
3. Detect actor collisions using the current C and actor hitboxes.
4. Run POLELIKE callbacks, then Mario's PLAYER callback. Mario prepares
   fresh geometry, runs interactions, then dispatches actions.
5. Run PUSHABLE, GENACTOR, DESTRUCTIVE, LEVEL, DEFAULT and UNIMPORTANT
   callbacks; unload deactivated actors; finally query Mario's platform.

Time stop can change which of these execute; it is not silently assumed
away for frozen actors or dialogues.

**Palm-tree push.** The stock Area 1 tree really runs
`bhv_pole_base_loop` (`behaviors/pole_base.inc.c:3`). If raw C.Y lies
strictly between actorY−10 and actorY+hitboxHeight+30, its timer exceeds 10,
and `action & MARIO_PUNCHING` is zero, it calls
`cur_obj_push_mario_away(70)`. This oddly named action mask is numerically
0x00100000, the ON_POLE bit in an action, not a test of Mario's punch flags.
The helper (`object_helpers.c:2200–2224`) measures horizontal separation
using C and adds `(70−distance)/70 * (C.XZ−actor.XZ)` to **M.XZ** when
distance<70. It does not query a floor or change M.Y, C, D or action. In
real arithmetic its displacement magnitude is at most 17.5; this is not a
new certified Float32 extremum.

This callback runs after the collision list was made but **before the fresh
Mario geometry query**. A shell can remain in the old-C contact list, but
the floor cache is then queried at the displaced M. If that first query
misses, the normal stored-graphics retry can undo the displacement. Also,
the tree's POLE handler precedes the shell and may grab an ordinary air
action, ending the pass first. A recipe must establish its rejection or
status guard rather than skip it. The unrelocated stock tree's raw vertical
range does not cover Y=25000 or 67277. Relocating an actor must be an actual
delivery history; a non-HOLDABLE tree frozen by carry-script redirection
loses the very callback push being proposed. Thus this is a real sideways
mechanism, with the fresh-cache and entry conditions still missing, not a
same-pass shell/box repair already demonstrated.

**Solid boxes and platforms.** Tox Boxes, large breakable boxes,
exclamation boxes and the spinning top run as SURFACE objects before Mario.
The checked callbacks move/scale their actors, update hitboxes, load meshes,
or spawn contents; they do not directly call the Mario X/Z push helper.
Their loaded walls and floors can affect Mario during his later geometry
and movement queries. Such floor following is a real support mechanism,
not an unexamined generic “type-zero push.” It still needs a reached owned
floor, correct height/loading and action continuation.

The proposed **Tox Box horizontal-PU rotation lever** is not newly opened
by its visible roll. As already recorded in
[the placement review](ssl1-other-interaction-placement-review.md),
`tox_box_move` (`tox_box.inc.c:86–100`) writes face pitch/roll and the
actor's position. `cur_obj_set_pos_via_transform` (`object_helpers.c:2072`)
derives and applies its actor velocity. Neither writes the separate
`oAngleVelPitch/Yaw/Roll` fields. Ordinary allocation zeroes raw fields
(`spawn_object.c:247`), and the inspected native Tox script/callback does
not supply a nonzero value for those fields. The carry helper
(`platform_displacement.c:91–164`) enters its rotational path only when one
of them is nonzero; otherwise it adds X/Z velocity and never adds VelY.
Consequently the named ordinary Tox lineage does not convert a huge X/Z
offset into vertical carry just because the face mesh rotates. A real
nonzero-angular-velocity provenance or a different floor-following
mechanism is the first missing condition; arbitrary field writes are not
such a provenance.

Loading and boarding remain additional conditions, not substitutes for
that missing rotation. Tox uses the allocation's collision-distance
default 1000 unless another real writer changes it. The loader requires
raw distance below that threshold, no active time stop and the right room;
it transforms vertices and casts each coordinate to signed TerrainData
(`surface_load.c:658–691,754–793`). Platform capture requires raw C.Y to be
within strictly 4 of the returned local floor height and a nonnull owner.
An aliased floor does not return its height plus the VPU offset. A
same-update load while Mario is near, followed by movement to a horizontal
PU, is not excluded solely by the next distance check: a previously
captured pointer can be consumed even if collision then unloads. It still
does not manufacture the missing Tox angular velocity. A frozen relocated
Tox also does not automatically reload its mesh; active-time-stop retention
preserves previously transformed surfaces, not freshly moved ones.

**Enemy and held-object callbacks.** The reviewed Goomba, Pokey, Fly Guy,
Klepto, Crazy Box, Bob-omb and small-box routines act on their actors after
Mario, with their specified movement, scale, attack status and lifetime.
The generic transport-cloning collision resolver explicitly tests
`otherObject != gMarioObject` before moving both actors' X/Z
(`obj_behaviors_2.c:549–587`); it is not a hidden post-Mario write to C.
The generic object-on-object attack helper likewise excludes Mario
(`object_helpers.c:2789–2807`). These mechanisms can affect actor delivery,
but do not directly give Mario the missing ground action or late shove.
Drop/throw and held following write the held actor's XYZ. Klepto's native
cap theft changes Mario cap/save flags under its distance/action guards;
the inspected callback does not move Mario or set a movement action.

**Tweester, cannon and NPC callbacks.** Tweester is POLELIKE: its native
movement/scale/hitbox refresh occurs after collision detection and before
Mario. This is a genuine reason not to assume a matched actor origin or
hitbox between those stages. Its native callback still moves the actor,
not Mario; the later accepted interaction selects TORNADO_TWIRLING and ends
the table. Cannon is LEVEL, after Mario: its callback moves the cannon and
changes cannon state, while Mario's automatic action performs the actual
Mario positioning. Bob-omb Buddy is GENACTOR, after Mario, and can call
`set_mario_npc_dialog`. This helper's `mario_ready_to_speak` guard accepts
WAITING_FOR_DIALOG or stationary/moving groups, and rejects riding-shell,
invulnerable and first-person states (`mario_actions_cutscene.c:325–366`).
It can change action after Mario's dispatch, but it does not turn an
ordinary airborne action into a ground slide or change M/C/D itself.

**Other out-of-table effects.** Star spawning can enable time stop and a
camera cutscene; its named callback is not a ground-action or XYZ
constructor. Pillar touch detectors change the top's touched counter and
deactivate themselves, rather than shoving Mario. The other callers of
the cylinder push helper are beta/treasure chests, bookends, haunted chairs,
Koopas, piano, penguins, snowmen and water-bomb cannon; the direct
`set_mario_pos` actor callers are Dorrie and the tilting inverted pyramid.
The butterfly callback also temporarily writes Mario-object C while
computing its own target, then subtracts the offsets; no exact Float32
cancellation is asserted here. Butterflies likewise are not in this
reviewed stock Area 1 inventory.
These named actors are absent from the reviewed SSL Area 1 inventory. No
sphere-push helper was found in this checkout. Their behavior is not
inherited by a cloned Goomba or a visually similar pyramid object.

## Automatic-action exits: ground-looking is still not ground-slide entry

The tree/pole, cannon and Tweester continuations were followed past their
interaction handlers rather than inferred from their action IDs.

`set_pole_position` (`mario_actions_automatic.c:61–111`) writes pole X/Z and
actorY+stored pole offset, resolves walls, then clamps Y against
`ceilHeight−160`. It queries a **local returned floor height** and selects IDLE
only in either of these cases:

- M.Y is below that returned height; it first snaps M.Y to that height.
- A wall collision occurred and M.Y is at most that height plus 20.

The helper does not add a nonnull check to those comparisons; a missing
floor's sentinel is still a returned height. Nor does its local query
replace Mario's cached floor pointer/height. These details matter for
other coordinates, but do not make the high near-pad comparisons true.

The branch between them instead tests whether the pole offset is below
`−hitboxDownOffset`; it restores M.Y to actorY−downOffset and selects
FREEFALL. This can restore a high raw actor-base Y **after** the ceiling
clamp, so 19840 is not an unconditional upper bound on the helper's return.
However, it is the FREEFALL branch, not a high IDLE constructor. With the
specific unloaded-top near-pad floors 768/1280 and absent-ceiling value
20000, these guards do not yield high IDLE at 21778+ or 67277 merely from a
high pole origin. All these normal returns copy M into stored graphics.
JP Z from HOLDING_POLE selects SOFT_BONK; climbing/top transitions remain
pole actions unless another explicit exit runs; their jumps require A.

`act_in_cannon` positions Mario at the cannon and copies stored graphics
on its normal non-shot path. The firing branch explicitly requires
INPUT_A_PRESSED and selects SHOT_FROM_CANNON (`674–761`), not a ground
slide. This is not a new no-A exit. `act_tornado_twirling` updates position
and floor information, normally copies M to D, and exits above the actor's
live hitbox into TWIRLING (`764–841`). Its ejection is not a ground slide.
Subsequent air landing still needs the actual floor and copy path.

NPC WAITING_FOR_DIALOG and READING_NPC_DIALOG can retain a high M while
copying it to D; their completion selects IDLE/HOLD_IDLE or PUTTING_ON_CAP,
not walking/crawl/slide. This is a real automatic-action holding interval,
not a reason to invoke the idle OFF_FLOOR lemma before its reached suffix.
Once the ordinary idle suffix is reached, its checked guard applies.
PUTTING_ON_CAP calls `stationary_ground_step`: on ordinary still ground it
snaps to the cached floor and then copies D; on moving sand/wind it can call
ground step, but does not add the common-slide post-copy alignment helper.
These observations narrow the named continuations, not every possible
multi-actor or time-stop history.

## Existing proof connections and verification

[The live bounce-read proof](bounce-live-height-read-connections.md) already
connects the actual generated classifier, returned memory and first bounce
height store. Under its explicit finite-coordinate and live-height-at-most-
250 hypotheses, it bounds the fresh upward snap by 251; it does not prove
all clone size histories or exclude an inherited split. This is meaningful
support for the distinction between placement and height, not an
unconditional retail-game bound. In particular, that joined theorem's
movement-Y hypothesis is −32768 through 32768, so it is not automatically
a theorem about raw Y=67277. Exact existing statements are:

- `InkBounceDetermineEntry.v:220`,
  `ibde_completed_above_classifier_reads_actual_return_heights`: the real
  completed classifier's top result reads the returned memory and puts M
  above the actor origin.
- `InkBounceLiveReadBoundary.v:43`,
  `iblr_real_classifier_through_bounce_has_at_most_251_new_rise`: joins the
  reached classifier/continuation/first snap under its live-size and
  numerical hypotheses. It does not construct a ground action.
- `InkAirReturnFrame.v:275`,
  `iar_completed_air_call_forgets_display_gap`: a completed actual air-step
  call reaches the real refresh and returns matching movement/stored
  graphics Y under its explicit valid separate state/object-slot and live
  load conditions. The collision-Y field retains its reached-cut value;
  this is not a whole-update or all-callback theorem.
- `InkIdleOffFloorGuard.v:109`,
  `iio_off_floor_returns_before_later_idle_controls`: the reached actual
  idle-cancellation suffix with the live OFF_FLOOR input requests FREEFALL
  before later controls. Its prefix join at line 138 still requires the
  earlier prefix to reach that suffix; it is not a global reachability
  invariant.

No extra axiom, simplified route model or new proof was added for this
matrix.

Checks actually run: read every table handler and its position/velocity
helpers and the named callback/automatic-action continuations, check JP
branches and source placement records, parse the complete
table to verify all 31 JSON entries in order, scan the 32 defined type bits
including unhandled UNKNOWN_31, and inspect the defined IDLE-flag action
constants. No Coq build or runtime experiment was run by this source
subtask. The matrix is a manually reviewed source classification, not a
machine-checked semantic certificate.

| Inspected local source | SHA-256 |
| --- | --- |
| `src/game/interaction.c` | `a327202d33612821f884f01b5e4692aa5cfe2003f3b9a2eeb1452ad72725ea00` |
| `src/game/mario.c` | `832c5301d3eda065310db5e5e429f6448eeeebcf7226a7e0bf2ac132556b8b1d` |
| `src/game/object_collision.c` | `4bdbe3bd3acd72c16738ec93638395a2f0daac4f69f905b76da8eae3384dc234` |
| `include/sm64.h` | `fabce457dd4e300d2fae451bf933ba82f452c48fcdd10af47d79bec0007dc3d9` |
| `src/game/object_helpers.c` | `a603370892b2589a97343be38a6fafd86b84279b8413e75ab94cada3719f5818` |
| `src/game/behaviors/pole_base.inc.c` | `aa652f0ee640172dde50300fe4a6d6abdff43141b6c817941837d3feada25224` |
| `src/game/behaviors/tox_box.inc.c` | `063729af05d0fc54095d2fc27505298481a3c3b38b85d6bfc59246d3428b0cf4` |
| `src/game/behaviors/bobomb.inc.c` | `fa71e00c4983f2ee0795bda430c5f2ede352e278d0ee81f636df682d0d11ace1` |
| `src/game/mario_actions_automatic.c` | `cfa6eaacbccd6f0246fac8d6742d95bf290e765d279443be74f4025212cd20ab` |
| `src/game/mario_actions_cutscene.c` | `e52b4a0d4278f3436c6e8ab7c6b9b0ba7e5bf6d84804c4a23f996c47c9b2735b` |
| `src/engine/surface_load.c` | `a9688dbac5b95e4859fc40c659faaf4c8064e0e7f8807dd2cf9c5ac7bd5cb9b0` |
