# High item nudges: action creation, ordering and repeated updates

14 November 2026. **The ordinary sideways-push branches of Crazy Box, small
box, black Bob-omb and Koopa shell preserve Mario's existing action. Repeating
those branches does not itself create crawl or a ground slide.** A successful
shell mount remains a real airborne-to-ground constructor, followed by Z
cancellation into crouch slide, but it ends the interaction pass before the
grabbable handler. Multiple updates are allowed and matter; their collision
masks and floor queries restart each update. These are source restrictions on
the named branches, not a global no-Ink result.

This review starts at proof revision
`3772fb57701ad0074c9a2016c366bed7e7e3ea24`, branch
`codex/ssl-pyramid-item-proof`. It first inspected the latest
[high Fly Guy contact](ink-flyguy-high-contact.md),
[delayed-shell](ink-high-delayed-shell.md),
[unloaded-top source](ink-high-unloaded-entry-source.md),
[actor-cut](ink-high-action-entry-actor-cuts.md) and
[Buddy replacement source](ink-buddy-replacement-source.md) records. The
applicable game is original JP. Decompile checkout is
`36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`; the files cited below have no diff
against stock source `9921382a68bb0c865e5e45eb594d9c64db59b1af`.
No new runtime result, original-ROM replay or Coq proof is claimed in this
source note. The concurrent runtime study owns its supplied writes and results.

The intended initial search is raw high Y only: H=25000 and H=67277 are useful
controls. The relevant condition is a verified fresh low cache with the top
collision unloaded, not height alone. Neither an actor's raw Y nor its hitbox
is moved to another VPU by terrain-query aliasing.

## Available actors and plain push branches

All four candidates have stock SSL Area 1 resources. Nominal dimensions below
use Mario radius 37 and each actor's ordinary initialized/free size. Tests must
record the actual dimensions because growth, carried state and callback timing
can change them. In particular an enlarged Bob-omb is a different fixture.

| Actor | Area 1 source resource | Interaction / ordinary radius, height, down offset | Plain push target distance |
|---|---|---|---:|
| Crazy Box | Two macros: `(1120,0,6480)`, `(-5200,0,1700)`; prior fixture slots47/49 | GRABBABLE; free scale 0.5 gives 75,125,10 | 107 |
| Small breakable/cork box | One macro: `(5900,50,3440)`; prior slot23; native initialization/floor can yield Y51 | GRABBABLE; scale 0.4 gives 60,100,8 | 92 |
| Ordinary black Bob-omb | Two macros: `(3800,0,6000)`, `(1750,0,6450)`; prior slots39/40 | GRABBABLE; scale 1 gives 65,113,0; KICKABLE subtype | 97 |
| Koopa shell | Contents of shell box at `(5840,940,2500)` | KOOPA_SHELL; ordinary scale 1 gives 50,50,0 | 89 |

Pool slots identify the cited prior fixtures, not permanent species IDs.
The shell's spawned slot in particular changes with allocation history. A new
test must validate the selected behavior/type. Repeated XYZ placement cuts are
supplied actor placements; they are not a demonstrated frozen-clone history.

For the grabbables, `interact_grabbable` reaches its fallback only after the
kick/trip, actor-grabs-Mario and Mario-can-grab branches fail. DIVE/DIVE_SLIDE,
or PUNCHING/MOVE_PUNCHING with actionArg below 2, can instead set the fresh
grabbable input flag and end processing. A black Bob-omb can take the earlier
KICKABLE attack path, which changes recoil velocity and actor status. Those
are not plain nudges. Neutral FREEFALL, TWIRLING, crawl and the ordinary butt
or crouch slide are not automatically pickup actions.

The plain grabbable branch calls `push_mario_out_of_object(...,-5)` and returns
false. It does not change action, velocity, cached floor or interaction status.
The shell's plain branch uses padding +2 and also returns false. It is reached
only when Mario is not already riding a shell and neither the falling-hit
classifier nor WALKING/HOLD_WALKING requests mounting. While already riding,
the shell handler skips both mounting and pushing.

The push computes a radial X/Z target using current movement M and actual
actor coordinates. It wall-corrects the target and commits X/Z only if a floor
query there is nonnull. That query does **not** replace `m->floor` or
`m->floorHeight`. The wall helper's Y output is the unchanged input Y on this
source path. The push therefore supplies no vertical relocation, no ground
action constructor and no fresh floor-cache writer.

## Contact lists are snapshots; masks reset every update

The actual update order is: rebuild dynamic surfaces, update terrain actors,
apply prior platform displacement, detect object overlap, then run nonterrain
actors, including Mario. Mario copies the collision-type mask, resolves walls,
queries and stores the floor/ceiling, and only then processes interactions.
Action dispatch follows the interaction pass. A later action change may loop
through another action handler, but does not restart object interactions.

Overlap is checked with raw Mario-object C and actor coordinates, not stored
graphics D. Horizontal distance must be strictly less than the sum of radii.
Vertical intervals `[Y-downOffset,Y-downOffset+height]` overlap inclusively at
their endpoints. Both objects must be tangible, and either collision list
already containing four objects prevents adding another pair. High terrain
aliases do not remove these raw-coordinate requirements.

The handler order includes WARP at zero-based index4, KOOPA_SHELL at26,
GRABBABLE at29 and TEXT at30. The first
collision-list object whose current type exactly equals the handler type is
selected. Mario clears that type bit before testing INTERACTED or running the
handler. A false return proceeds to the next type, not another object of the
same type. Skipping an already-INTERACTED object likewise does not try the
second grabbable.

Thus a free nonmounting shell and one grabbable can supply two successive
pushes in one pass. The second push reads the M changed by the first; it does
not rerun hitbox detection. Both contacts must already be in the original
list. Two or three ordinary GRABBABLE actors cannot supply two or three
grabbable-handler pushes in that pass.

`clear_object_collision` clears collision lists and type masks on the next
update; it does not clear INTERACTED status. Mario then copies the newly built
mask again. Consequently different grabbables can push on successive updates,
and repeated plain contact with the same actor is allowed. Plain fallback
pushes themselves do not set INTERACTED. Native actor callbacks still affect
position, tangibility, size, status and lifetime. A truly frozen actor with
clear status may keep its collision-only fallback; a hypothetical clone does
not receive a new type or a free status reset merely by being called a clone.

In a wall-free, unchanged-actor example, the grabbable push targets five units
inside the detection radius: Crazy Box 107 versus 112; small box 92 versus97;
ordinary Bob-omb97 versus102. It can therefore remain in the next collision
list, but once at the target distance it receives no additional radial shove
from that unchanged actor. The shell targets89 versus detection87, leaving
a nominal two-unit gap; another movement or push is needed to restore contact.
These are geometric target distances, not claims that floating-point rounding
or walls always give those exact separation measurements.

## What a multi-update sequence can and cannot preserve

An earlier fallback push can change the next update's starting X/Z, so it can
prepare a later contact or choose a different floor-query location. It cannot
retain the old cache through the next ordinary input preparation: that next
update performs a fresh query at its then-current movement position, with the
stored-graphics retry if needed. A staged experiment must record the actual
floor each time, not carry the first 768 value forward as an assumption.

Among these four handlers, successful shell contact is the ground-action
constructor. A descending ordinary airborne Mario above the shell can be
classified HIT_FROM_ABOVE and enter RIDING_SHELL_GROUND. The mounting branch
returns true, so an overlapping Crazy Box, small box or Bob-omb cannot provide
its later fallback push in that same pass. Pressing Z is processed afterward:
it stops riding, raises speed to at least24 and requests CROUCH_SLIDE. With the
slippery-floor flag it can immediately become BUTT_SLIDE. The common slide
code still must reach a ground step and floor alignment; an action ID alone
does not establish that execution.

In the known high-sentinel configuration, immediate Z executes the stopped
ground step and aligns M.Y to the fresh low cache during this mounting update.
It does not leave the newly constructed slide at raw high Y for next-update
high actors to push. With unchanged X/Z and a still-present static pad, the
next low query can simply find that pad; a large Y split is then insufficient
for the failed-floor retry/top capture. This explains the missing shove in
that named configuration, rather than proving all possible geometries fail.

The suggested previous-frame/next-frame repair has three different cuts:

| Update | Named ordinary path | Why an extra shove does not automatically repair it |
|---|---|---|
| T−1 | A plain nudge while still airborne, followed by ordinary completed air movement | The air step refreshes D from M; T's geometry preparation queries at the new position. This is not a preserved old768 cache with a delayed shove. |
| T | Successful shell mount, followed by Z and common-slide alignment | The mounting handler returns true and skips the later GRABBABLE handler. Action dispatch does not reopen that pass. |
| T+1 | Low collision overlaps and accepts the ordinary upper warp | Geometry preparation/retry has already happened. WARP at index4 selects DISAPPEARED and returns true, skipping the shell26 and GRABBABLE29 handlers. A proposed later item shove therefore does not occur in this accepted-warp pass. |

The T−1 row assumes the ordinary completed air-step copy, rather than an
unproven universal property of every airborne handler. T+1 assumes accepted
ordinary warp contact; rejected contact or another geometry is a different
history. These orderings do not exclude every staged high setup.

Delaying Z does not automatically save the high slide opportunity. The prior
high delayed-shell study already observes the stopped riding step selecting
BACKWARD_GROUND_KB, which performs no floor alignment; its later IDLE recovery
exits through OFF_FLOOR. If a different setup genuinely retains a riding-shell
action until a later update, a GRABBABLE push can occur before that update's Z
cancel, but the shell itself contributes no fallback push while the riding
flag is set. Such a retained-riding predecessor and its fresh geometry must
be demonstrated, not supplied.

Plain fallback pushes therefore close one narrow proposed explanation:
an arbitrary number of these fallback contacts, without another action
constructor or actual landing, does not transform an airborne action into a
ground slide. This source statement is not an invariant over every possible
action handler, support, actor mutation, clone lineage or collision history.
No new Coq theorem is asserted.

The useful remaining finite test is a high staged history that records every
action execution and each fresh cache, and verifies exactly where the shell
constructor occurs relative to the pushes. Success still requires low warp
acceptance, failed low-floor retry, top capture/retention and a useful displaced
Area 2 arrival. Merely showing another shove or another high grounded action
does not meet the target. High Mario and high actor placement remain explicit
grants until joined to an allowed delivery history.

## Source pointers

All source links use the stock pin inspected above:
[overlap and per-update reset](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/object_collision.c#L25),
[world update order](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/object_list_processor.c#L625),
[fresh geometry](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario.c#L1314),
[interaction-before-action order](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario.c#L1699),
[floor-checked push](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/interaction.c#L616),
[shell handler](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/interaction.c#L1460),
[ordinary warp acceptance](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/interaction.c#L855),
[grabbable handler](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/interaction.c#L1636),
[interaction loop](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/interaction.c#L1780),
[shell cancellation](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario_actions_moving.c#L1200),
[common-slide alignment](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario_actions_moving.c#L1356),
[live dimensions](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/object_helpers.c#L2120),
[SSL actors](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/levels/ssl/areas/1/macro.inc.c#L20).
