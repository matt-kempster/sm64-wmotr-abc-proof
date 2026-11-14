# Can an enemy turn airborne Mario into a useful ground action?

14 November 2026. **The reviewed ordinary enemy hitboxes do not provide the
shell's direct FREEFALL → grounded riding → crouch-slide shortcut.** They
bounce, damage, burn, grab or carry Mario, or require an actual landing before
ground recovery. This is a source review of the named branches, not a theorem
excluding every compound history or a new runtime search. A solid actor can
instead supply a real floor; that is a separate landing route.

Review base: proof `08df00c605127a172d3a28049e31d6f50f7bff98`, decompile checkout
`36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`, applicable stock JP source
`9921382a68bb0c865e5e45eb594d9c64db59b1af`. The inspected interaction, Mario
geometry/step/action, Chuckya, Heave Ho, shockwave, Tox Box and SSL macro files
have no diff against that stock pin. The local level script's unrelated disabled
TAS branch is not used as a stock route. No Coq code or runtime was changed.

## Enemy contact families

| Actor or contact | Stock SSL Area 1? | Incoming ordinary airborne Mario | Why it does not supply the wanted slide directly |
|---|---|---|---|
| Goomba, Pokey body segments; ordinary bounce handlers | Yes | A qualifying hit from above changes movement Y to the actor's top and vertical speed to 30; otherwise damage can select air knockback | The ordinary bounce does not request a ground action. Actor-top collision is not a floor landing. |
| Fly Guy / Fire Fly Guy | Yes | Qualifying bounce requests TWIRLING with vertical speed 80; side contact can select air knockback | TWIRLING's useful ground transition is AIR_STEP_LANDED → TWIRL_LAND. Z does not directly turn twirling into a slide. |
| Klepto | Yes | HIT_FROM_BELOW interaction uses the ordinary bounce/damage family; its template has damage 0 | This handler does not mount, give a floor, or request crawl/slide. Stealing Mario's cap is not grabbing Mario into a ground action. |
| Ordinary enemy damage, Bob-omb explosion, damaging snowman/bullet contacts | Some: black Bob-omb/explosion and local damaging enemies are present; snowman/Snufit are not | `determine_knockback_action` selects the air row for AIR, ON_POLE or HANGING | Ground-knockback animation/name is not granted to an ordinary AIR input. Air recovery uses real landing. |
| Bully / Big Bully | No | The ordinary vulnerable-contact branch explicitly selects FORWARD_AIR_KB or BACKWARD_AIR_KB when AIR is set | It pushes and ends the pass, but does not create a useful ground slide. Its non-AIR branch is a different predecessor, not evidence about ordinary freefall. |
| Fire projectile / flame from fire actors | Yes | BURNING_JUMP or BURNING_FALL, selected using incoming action and vertical speed | Both air handlers require AIR_STEP_LANDED for BURNING_GROUND. Burning ground itself does not call the common-slide floor alignment. |
| Tweester (SSL tornado) | Yes; one always, two more in acts 4–6 | TORNADO_TWIRLING, an automatic action with its own orbit/floor checks; eventual exit is TWIRLING | A STATIONARY flag is not a ground-step dispatch. The handler copies its resulting movement into stored graphics. |
| Shock enemy/projectile, e.g. Amp | No ordinary shock actor in SSL Area 1 | SHOCKED with actionArg=0 for AIR/ON_POLE/HANGING | Although STATIONARY is set, this is a cutscene-group action. It performs air steps until LANDED before its ground recovery. |
| Chuckya / Heave Ho / King Bob-omb-style grabber | No | A qualifying GRABS_MARIO branch can catch airborne Mario and select GRABBED | GRABBED is automatic, not a productive ground slide. Release selects THROWN_FORWARD/BACKWARD, both airborne; callbacks can move the graphical anchor or set throw speeds, not supply the desired ground action. |
| Bowser stomp/shockwave status | No | Ordinary AIR dispatch does not consume INPUT_STOMPED into SHOCKWAVE_BOUNCE; the shockwave callback also excludes air actions | The stationary-group shockwave bounce is not an unrestricted airborne-entry constructor. |
| Tox Box; solid enemies such as Whomp/Thwomp elsewhere | Tox Box: yes, three. Whomp/Thwomp: no | Their loaded collision mesh can be an actual floor or ceiling | Landing on a floating solid is genuine support, a different mechanism from enemy-hitbox contact. Its floor cache and later support history must be checked. |

The grabber guard deserves care: its expression contains an OR with
`!sInvulnerable`, so it is incorrect to say that all airborne Mario states are
rejected merely because AIR appears in the other half of the expression.
The resulting GRABBED action still does not provide the needed ground helper.

Bully's selector also illustrates why this is not a global uniqueness claim.
It tests AIR alone, whereas generic damage also recognizes ON_POLE and HANGING
as air-like. A pole/hanging action without AIR can therefore take the Bully's
ground-knockback branch if its other contact guards pass, despite being physically
off the floor. That is a different non-AIR predecessor, the resulting ground
knockback does not supply common-slide alignment, and Bully is absent from SSL
Area 1. No runtime witness for that compound case was made here.

## Squishing is a special geometry case, not the shell shortcut

`update_mario_geometry_inputs` finds the ceiling using **floorHeight + 80**.
If either the floor or ceiling is dynamic and their separation lies in the
inclusive interval 0–150, it sets INPUT_SQUISHED. That test does not separately
require raw Mario Y to be close to the floor. Common airborne cancellation can
then select ACT_SQUISHED. Therefore a sufficiently unusual *actually loaded*
floor/ceiling configuration deserves its own test; it is not ruled out merely
because Mario began physically unsupported or in a VPU.

This does not by itself create the Ink split. ACT_SQUISHED is a cutscene action.
Its ordinary tail calls `stop_and_set_height_to_floor`, which writes movement
Y to the cached floor and **then copies movement XYZ into gfx.pos**. The tail
therefore loses the retained high graphics position instead of supplying the
common-slide ordering. It can call a ground step under steep surfaces, but still
reaches that snap/copy tail unless an explicit early-return branch is taken.
Its idle exits and changing geometry are separate histories; no global exclusion
of those histories is claimed here.

## What cloning changes

A frozen collision-only clone retains its initialized interaction type,
subtype, dimensions and relevant status. Freezing a Goomba does not turn
BOUNCE_TOP into KOOPA_SHELL, and freezing a Fly Guy does not remove the twirl
subtype. Retained INTERACTED status can additionally prevent later handling
when the usual callback no longer clears it. A frozen grabber may also lose
the callback that releases Mario. No arbitrary clone lineage is supplied by
this source argument.

Solid collision needs a separate analysis. The ordinary Tox Box callback calls
`load_object_collision_model` every update. The non-HOLDABLE fake-object carry
scripts 3/4/5 stop at BREAK; simply replacing its normal behavior with such a
frozen carry script does not establish continuing collision-mesh loading.
Consequently a collision-only enemy clone cannot automatically be treated as a
portable solid platform. A live manipulated solid, a surviving mesh-loading
history, or another real support could still be investigated.

## What remains useful to test

The plausible alternative to a direct hitbox constructor is a **real high
landing on a loaded solid**, followed by a demonstrated support change that
leaves the needed ground action executable with a fresh low floor cache.
Tox Box is an SSL Area 1 candidate for that question. Its delivery, loading,
surface coordinates, action persistence and later shove are all obligations;
this review does not provide that witness. For ordinary cloned body-hitbox
contacts, the source review supplies no new confirmed alternative to the shell.

The subsequent [high solid-support experiment](ink-high-solid-support.md)
finds a conditional large-box landing result that creates DIVE_SLIDE while
leaving a low cache, followed by a shell shove and useful displacement; the
selected positive also [replays on original JP](ink-high-solid-support-rom.md).
This uses live loaded geometry, not an enemy body-hitbox shortcut. The two
tested native Tox Boxes in ROLL_LAND reset supplied high Y to their home
height; other phases and gameplay delivery remain untested.

Relevant stock source: [enemy interactions](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/interaction.c#L1229),
[geometry and squish input](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario.c#L1314),
[airborne cancellation](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario_actions_airborne.c#L2046),
[shock and squish execution](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario_actions_cutscene.c#L1457),
[snap then graphics copy](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario_step.c#L223),
[grabbed and tornado execution](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario_actions_automatic.c#L655),
[stock SSL actor placements](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/levels/ssl/script.c#L24),
[stock SSL macros](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/levels/ssl/areas/1/macro.inc.c#L3).
