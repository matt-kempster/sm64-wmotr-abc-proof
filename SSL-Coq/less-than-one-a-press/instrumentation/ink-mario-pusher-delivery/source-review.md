# Can Mario place both pushers before the shell handoff?

14 November 2026. **The existing positive does not establish this.** It supplies
the two actor positions and the enlarged Bob-omb's released profile. Actual
controller histories acquire and release both kinds of actor, but neither
delivers the required joint state. This note traces the extra conditions that
an actual placement must satisfy. It does not turn source deductions into a
controller route or an impossibility theorem.

The checkout at review start was
`0605d842cedb55151e70952d56064553c4970f60`. Source anchors below are relative to
the sibling `reference-sm64-decomp`, whose HEAD is
`36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`; the project's applicable stock JP
source pin is `9921382a68bb0c865e5e45eb594d9c64db59b1af`. The optional local TAS
branches are not premises. No source or proof code was changed for this note.

## First separate compatibility from delivery

The preplacement positive starts Bob39 at
`(-2080.06005859375,1809.2066650390625,-1230.322021484375)` and Crazy Box49 at
`(-2102.720703125,1839.447265625,-1119.5618896484375)`. Their initial separation
is approximately117.029 units. Mario and an initialized frozen shell are
supplied at Y19900 and19890. Z on update128 creates the ground slide; Bob
pushes129, Crazy Box pushes130, and warp/top capture occurs131. The original
JP replay verifies useful spawning displacement from those supplied states.

The fact that the actors can already be present before128 removes the two
mid-sequence position cuts. It does **not** say that Mario performed either
placement. Nor does it remove the native Bob-profile transplant, conditional
shell preparation, supplied airborne Mario, or top-phase join.

## What native drop and throw actually write

`src/game/interaction.c:295–330` gives the exact helper endpoints, before
later object behavior updates:

| Release | Actor X/Z | Actor Y | Other effects |
|---|---|---|---|
| Drop | Stored HOLP X/Z | Mario's current movement Y | Sets held-state drop, yaw, then clears Mario's held pointer |
| Throw | HOLP X/Z plus32 times the yaw sine/cosine | Stored HOLP Y | Sets held-state throw, yaw, then clears held pointer |

These are float operations and the actual binary32 endpoints must be checked
in execution. A desired actor XYZ is not itself a demonstrated HOLP or Mario
state. HOLP is updated when the held object is drawn
(`src/game/mario_misc.c:571–578`); it is neither M nor G and need not remain
unchanged during carrying.

For an immediate drop at the desired Bob origin, before actor corrections,
Mario must have movement Y1809.206665 and HOLP X/Z equal the Bob target. A
throw instead requires that HOLP Y and the appropriate yaw-adjusted HOLP X/Z.
The Crazy Box target similarly requires its release height or a trajectory
which subsequently reaches the useful contact height. Its native positive
contact130 actually uses Box Y1852.873535, after its own129 movement; the
supplied initial1839.447266 is not a universal release-height requirement.

`src/game/object_helpers.c:1067–1113` then matters: the drop helper makes the
object tangible/free, queries floor at actorY+160, may lift it onto a higher
floor, and sets forward and vertical velocity to zero. A failed floor lookup
can instead copy Mario's object position. Thus an after-update release
coordinate must not be inferred from the Mario helper alone. Native Bob
throw has its own callback, which sets forward velocity25, vertical20 and
LAUNCHED (`bobomb.inc.c:207–216`). Crazy Box throw uses forward40, vertical20
and action1, including the helper's immediate vertical movement.

Ordinary ground throwing releases when its incremented action timer reaches7;
placing-down releases at8 (`mario_actions_object.c:233–274`). Air throw releases
at4 (`mario_actions_airborne.c:796–800`). These counts describe time executing
those actions, not a universal number of updates from any B press. A forced
expired-Bob drop follows a different status-triggered path.

## The useful enlarged Bob is short-lived once Mario is nearby

The prior continuous no-A Bob history really reaches an enlarged held actor
after616 controller inputs. No actor position, fuse, size, held pointer or
Mario pose is supplied. Continuing with neutral inputs produces the actual
release at628, with patrol action0, fuse170, radius91 and height158.2.
The released actor is at
`(4558.10791015625,23.010007858276367,4253.400390625)`, far from the Ink target.
Mario is at `(4556.08154296875,18.737794876098633,4182.6767578125)`.

The observed uninterrupted near-Mario sequence is:

| Completed input | State after callback |
|---:|---|
|628|Free patrol, radius91, fuse170|
|629|Explosion action, timer0, radius91, fuse171|
|630|Explosion timer1, radius65|
|631|Explosion timer2, radius78|
|632|Explosion timer3, radius91|
|633|Explosion timer4, radius104|
|634|Explosion timer5, radius117, still active|
|635|Original Bob inactive; native explosion spawned|

That is seven subsequent active callbacks before deletion in this particular
release continuation. It is not a universal elapsed-time or transport limit.
Repeated actual regrabs already extend the held actor's life much further.
The free loop always reselects explosion when fuse>150, while the held loop
delays execution of the free explosion body and requests a drop
(`src/game/behaviors/bobomb.inc.c:30–43,105–143,182–205`).

The fresh controller-only release controls expose a further restriction:
starting from the native616 enlarged regrab, neutral input, B or Z at627,
and B or Z at628 all produce the same automatic drop at628. When pickup
finishes, `act_hold_idle` checks `INT_STATUS_MARIO_DROP_OBJECT` before its
ordinary B/Z cancellation helper (`mario_actions_stationary.c:439–450`).
Thus the generic throw-coordinate formula above does not establish that this
particular radius91 held cycle permits a chosen throw. An earlier native597
branch can really throw with B609, releasing at615 at
`(4589.56640625,147.4859619140625,4529.181640625)`, but that actor has radius65
and fuse157. Z609 instead really drops at609 at
`(4607.4951171875,35.526939392089844,4555.734375)`, radius65/fuse151.
All seven selected histories were reconstructed twice, with no gameplay
writes; `bob/release-results.json.gz` preserves the actual controls/events.
An enlarged HOLP throw needs a different demonstrated action history which
avoids that forced-drop guard; it cannot be silently borrowed from the earlier
small-radius throw.

The callback gate tests **stored graphics G**, with strict squared distance
less than4000 squared (`src/game/obj_behaviors.c:496–507` and
`bobomb.inc.c:242–282`). Outside that range, motion, held/drop handling and
fuse increment all pause. The ordinary object wrapper nevertheless increments
the action timer (`src/engine/behavior_script.c:943–951`). Therefore:

- A free expired Bob still in patrol can wait outside G-range; its first near
  callback runs patrol and selects explosion, resetting the action timer.
- An already-exploding Bob does not preserve its remaining explosion time
  merely by moving outside G-range. If it returns with timer at least5, the
  next explosion callback deletes it. Other history changes, such as a real
  regrab and drop, must be analyzed separately.
- Keeping the actor outside G-range can also postpone a pending native drop
  callback. One cannot assume its held/free state has finished changing just
  because Mario cleared his held pointer.

The supplied preplacement positive pauses the low Bob through128 because the
shell/Z update leaves G.Y19900. G becomes low during129, so the Bob callback
then resumes. This high G is obtained **after the supplied high shell mount**;
it is not evidence that Mario can first place Bob low and freely fetch the
other items while remaining nearby.

For the two target origins, any G within approximately3882.97 units of the
Crazy Box target is necessarily within4000 of the Bob target by the triangle
inequality. Ordinary nearby placement with G near Mario therefore activates
the expired Bob. A schedule that parks this Bob first and spends many nearby
updates arranging the Crazy Box cannot appeal to distance deactivation alone.
A remote HOLP release or a real M/G split could change that premise, but must
be reached and measured. Merely pointing the camera elsewhere does not alter
G into a distant coordinate.

## A carried Crazy Box is not the same state as the preplaced live box

The preplacement positive uses the original free Crazy Box in action0.
Its idle bouncing can survive ordinary floor contact. An actual drop sets
action1; an actual throw also selects action1. In that action, native
`OBJ_MOVE_LANDED`, wall-hit or water flags delete the actor
(`src/game/behaviors/jumping_box.inc.c:31–36,64–70`). This is the first important
state mismatch when trying to replace the setup XYZ write with real carrying.
A release trajectory that still collides with Mario before deletion might
work, but the existing action0 positive does not test it.

The new parallel `controlled-box/results.json.gz` follow-up now tests this
distinction successfully under supplied holding/position/HOLP assumptions.
A native drop at126 can leave the action1 box alive through its130 push,
then it breaks on landing after that collision. No item edit is made after
the native drop. This resolves release-state compatibility for those tested
conditions; it does not supply the pickup, Mario release pose, HOLP or joined
delivery history. `controlled-box/README.md` records the complete grants.

Normal holding also cannot simply walk the Crazy Box into place and choose Z.
`act_hold_idle` and `act_hold_walking` first recognize `bhvJumpingBox` and
immediately enter `CRAZY_BOX_BOUNCE`, before ordinary B/Z controls
(`mario_actions_stationary.c:439–450`, `mario_actions_moving.c:875–903`).
That action supplies three launches and does not read B or Z. Its third
landing clears the held pointer and requests destruction of the box
(`mario_actions_airborne.c:1033–1093`). The known Fire Fly Guy interruption
really drops a live action1 box instead, but at the wrong place and height.
Hands-free dive-pickup exits are a separate source possibility
(`mario_actions_object.c:213–226`), not a demonstrated Crazy Box delivery.

Distance deactivation is different for Crazy Boxes. Their normal movement
skips while FAR_AWAY, but floor/flags/action callbacks still run
(`object_helpers.c:1746–1777,1802–1829`). An action1 box can still be deleted
if a killing flag is present. This is not a general indefinite-storage rule.
The preplaced action0 box's inherited FAR_AWAY flag explains its first skipped
movement; a newly released nearby box is not guaranteed to inherit that flag.

## One exact last-moment placement branch does not work

Suppose Mario instead brings the required pusher in his hands to the exact
high shell contact. `interact_koopa_shell` calls `mario_drop_held_object`
**before** entering RIDING_SHELL_GROUND and before the subsequent slide/ground
step (`interaction.c:1460–1479`). At the tested FREEFALL M.Y19900 contact, this
writes actorY19900, regardless of a low stored HOLP Y. It does not place Bob
at Y1809 for129 or Crazy Box nearY1853 for130.

For these ordinary native drop callbacks, the subsequent floor correction
does not snap a high object downward to a lower floor. A normal floor query
at these target X/Z finds a lower existing floor; the correction only raises
an actor when the selected floor is above it. Zero drop velocity and the next
one or two native updates cannot provide an18000-unit fall. Bob's callback
also becomes distant from Mario's low G after129. Crazy Box's ordinary
vertical integration is capped at a downward78 per active step
(`object_helpers.c:1311–1328`). This rejects the named exact high-mount
carry/drop shortcut under its ordinary floor conditions. It does not reject
a prior throw from reachable HOLP, another mount geometry, unrelated actor
displacement, or another sequence.

Mario also has only one held pointer; a normal pickup writes it only when
null (`interaction.c:288–292`). The shell, Bob and Crazy Box therefore cannot
all be ordinary held objects at once. Any real joint route needs an explicit
order of releases, retrieval, shell preparation and fourth-pillar timing.

## Current controller evidence and the useful next join

The existing accepted no-A recording really picks up western Crazy Box49,
rides three bounces to the pyramid roof and consumes it on landing. The
fourth pillar has already started the top too early for that sequence.
A different clean prefix with three pillars reaches the Fire Fly Guy release;
the live box starts atY1259.514893 and dies on landing18 updates later. Neither
is the delivered pusher required by the handoff.

The parallel fresh Wafel box study in this directory reconstructs the original
release plus12 local steering continuations, twice each. Nine histories
release a living free box; all have action1. The nearest tested release to
the desired initial Box target is
`(-3225.492919921875,1259.514892578125,-1194.014404296875)` at branch304,
about1125.238 horizontal units away and579.932 units too low. It is deleted
at322, with only three pillars active. See `box/results.json.gz` and its
reproduction notes. These results locate the first miss, not a global bound.

The real Bob donor/regrab history likewise remains a transport predecessor,
not placement at Ink. The current controller-only Bob search is recorded
separately under `bob/`; do not substitute the supplied radius91 profile into
that actual route or treat a distant carried actor as a placed pusher.

The most focused joint experiment is now to reach the **real action1 Crazy Box
release trajectory** through controller inputs, then arrange the short-lived
Bob's real release/regrab last. The parallel native-drop compatibility test
shows that deletion after the useful130 push need not defeat the handoff;
only its controller predecessor can close delivery. The shell's native
pending-slot acquisition also retains a separate
contents-spawn grant in existing work, and the high Mario/HOLP approach and
top timing remain unjoined.

No Coq theorem is claimed here. The narrow source branches above can guide a
future source-linked proof, but a global impossibility result would need an
invariant over actual acquisition, release, actor motion and Mario histories.

Prior records used: `docs/notes/ink-box-delivery.md`,
`ink-bobomb-regrab-transport.md`, `ink-enlarged-bob-profile.md`,
`ink-shell-delivery-source.md`, and `ink-preplaced-pushers.md`.

## Planning Mario's altitude separately

There is no demonstrated no-new-A ascent to movement Y19,900, the
21,778–32,767 band, or a positive VPU in the reviewed SSL records. Those high
initial Mario cuts are still grants. High HOLP can affect an object's release
position; it does not move Mario there. A terrain query alias also does not
translate Mario's actual coordinates.

The strongest directly relevant clean altitude predecessor in these records
is the western Crazy Box / Fire Fly Guy history. With only the inherited
pre-entry debug level-selection setup, actual controller inputs reach:

| Completed input | Actual Mario state | Limitation |
|---:|---|---|
|2804|TWIRLING at Y1339.514893 after the native Fly Guy bounce|Fly Guy is consumed; Crazy Box is dropped|
|2823|Airborne peak Y2099.514893|TWIRLING, not mountable ordinary freefall|
|2855|TWIRL_LAND at Y1772 on the intact top|Real high floor cache1772; fourth pillar still uncredited|
|2866|IDLE on that top|No useful low cache or phase join|
|2867|Native BUTT_SLIDE at Y1768|Real ground action, but cache1768 rather than768|

These trajectories have original-JP confirmation with the preserved
interaction-subtype mismatch described in `ink-flyguy-native-rom.md`; this is
not a claim of complete memory equality. The earlier box peaks2883.660889
and3089.280273 in `ink-box-crawl-predecessors.md` start from supplied roof
pickup positions. They must not be promoted to clean altitude predecessors.

A productive plan first separates the required height from the current
fixture's chosen height. The older shell / Box+Buddy / Box family has supplied
air-start positives at1810 and1830 after an X/Z correction, as well as19900.
The current enlarged-Bob, no-Buddy recipe did **not** inherit those lower
positives automatically. The new bounded `lower-approach/` experiment now
establishes one supplied-air **Y1810 positive** after correcting the entry X/Z
and Bob's initial X/Z for its earlier native movement. It verifies fresh768,
top capture/retention and the exact useful spawn, twice in Wafel. Therefore
MarioY19,900 is not required for this conditional no-Buddy recipe.

The successful initial Mario is
`(-1962.4404296875,1810,-1243.34130859375)` with FREEFALL and velocity
`(0,-16,0)`; frozen shellY1800 shares its X/Z. Bob's initial position is
`(-2079.9365234375,1809.2066650390625,-1233.3045654296875)`; the Crazy Box stays
at the original target. Low G opens Bob's callback on128, so the approximately
3-unit initial horizontal compensation makes its next X/Z match the useful
push. Its actual Y has risen onto the moving top by then and still overlaps
Mario. No Mario or actor writes follow the initial cut. The 39 finite
histories include the existing high baseline, one low positive,16 ordinary
arrivals and21 no-arrival controls, across1431 recorded boundaries each
reconstructed twice. No continuous low height interval or controller route
is claimed. See the package README and full positive/negative exports.

With this lower target surviving, work backward from its exact first-update
position/action to the clean2099/1768 predecessor, with all four pillar
activations, shell placement and live actors in the same input history. A
descending Fly Guy twirl cannot simply be substituted for the fixture's
FREEFALL: the interaction classifier recognizes the twirl attack first, so
the shell's above-contact mount is not selected. TWIRLING ignores B/Z and
requires a real landing to reach TWIRL_LAND, then a completed recovery to
IDLE. Walking can mount a shell through a different source guard, but reaching
the appropriate walking contact and its useful continuation must be tested.

If the higher band is retained as the objective, the next work should be one
actual altitude-producing mechanism with a repeatable controller predecessor,
not more high position cuts. Crazy Box launches and Tweester ejection are
available no-A sources worth measuring from real acquisition/contact. They
are not established repeatable ladders: the third Crazy Box landing destroys
its box; Tweester exits to TWIRLING and depends on its actual moving origin
and live hitbox; Fly Guy's upward steering targets MarioY+200 and does not
grant arbitrary altitude. Reaching successive higher supports or a repeatable
vertical actor transport remains a separate missing construction.

Several shortcuts are already scoped out by source: ordinary cannon firing
requires `INPUT_A_PRESSED` (`mario_actions_automatic.c:735`); descending twirl
does not refresh its bounce by landing on another Fly Guy; ordinary freefall
plus Z is not ground-slide entry; and the normal Tweester copy does not itself
retain an Ink graphics gap. None of these local facts proves a global height
bound. A practical first milestone is a controller-only increase above the
known2099.514893 predecessor together with a measured exit action and next
support, before claiming progress toward19,900 or a VPU.

Additional records read: `ink-flyguy-manipulation.md`,
`ink-flyguy-native-manipulation-runtime.md`,
`ink-flyguy-native-manipulation-source.md`, `ink-flyguy-video-review.md`,
`ink-shell-lower-boundary.md`, `ink-item-native-slide-combinations.md`,
`ink-supported-slide-preparation.md`, and `ink-pu-vpu.md`.
