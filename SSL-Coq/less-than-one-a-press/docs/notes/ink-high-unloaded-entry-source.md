# High entry with the top unloaded: can another contact shove before mounting?

14 November 2026. **This complete source pass found no stock SSL actor that
provides the missing sideways shove before a successful Koopa-shell mount
in the same interaction pass.** Of the 26 interaction-table entries before
the shell, the igloo barrier is the continuing X/Z-push case, and it is not
a stock SSL actor. Bully pushes end the pass. The remaining handlers either
leave X/Z unchanged when continuing, or end the pass before mounting.

This is a narrow source conclusion about a proposed same-update combination,
not a proof that every high entry is impossible. It does not assume that
the obstructing spinning-top floor must remain loaded. The intended search
region is the established high main-universe window, integers 21778–32767,
and positive-VPU examples such as raw Y=67277, with the actual producer's top
collision unloaded and fresh low floor verified. A height alone does not
prove those live loading/cache conditions for every X/Z or phase.

The proof checkout at inspection is
`77ed7515d9ddce96fe00a030a26aae8663b590b0`, branch
`codex/ssl-pyramid-item-proof`. The decompile checkout remains
`36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`, with existing local changes
preserved. The applicable `VERSION_JP` branches were read. The stock SSL
placement comparison uses decompile revision
`9921382a68bb0c865e5e45eb594d9c64db59b1af`; this avoids mistaking the local
script's disabled `SSL_SPAWNING_DISPLACEMENT_TAS_HACK` additions for stock
actors. No runtime, new Coq proof, build or original-ROM replay was performed
for this source pass.

## The exact handoff being sought

The desired ordering is: Mario's geometry preparation refreshes the low
floor cache; an actor pushes movement X/Z toward the needed edge; a shell
contact selects `ACT_RIDING_SHELL_GROUND`; Z selects the common crouch-slide
path; the stopped quarter and floor alignment create low movement/collision
with high stored graphics; the next accepted warp captures and retains the
top and reaches the displaced Area 2 spawn. Merely changing velocity or
ending the update with a ground action number does not supply the shove.

For an ordinary airborne mounting approach, `determine_interaction`
(`interaction.c:182–247`) must return exactly `INT_HIT_FROM_ABOVE`: the
action has the AIR flag, vertical velocity is negative, Mario is above the
shell, and no earlier attack classification overrides the result. The
shell handler also accepts WALKING/HOLD_WALKING, but these are separate
ground-action prerequisites. Its successful branch sets the three object
references, attacks the shell, drops any held actor and returns the nonzero
result of `set_mario_action` (`1460–1477`). It does not execute its alternative
X/Z-push branch.

Platform displacement is not an extra post-cache shove: it runs before
collision-list detection and before Mario's fresh input/geometry preparation
(`object_list_processor.c:647–662`). This pass therefore examines the actual
interaction functions that could run between the fresh query and the mount.

## All entries before the shell

The order below is the actual table at `interaction.c:84–111`. Repeated
entries using one function are grouped, but all 26 entries are accounted
for. “Continues” means returning false to this interaction loop; it does not
mean an action handler has already executed.

| Table entries / function lines | Branch relevant to a shove followed by mounting |
| --- | --- |
| COIN and WATER_RING,743–767 | Continue after collection/healing/status updates. Coin 100 can spawn a star object, but neither handler moves Mario X/Z or immediately runs that new object's behavior. |
| STAR_OR_KEY,769–835 | Accepted collection returns an action change and ends processing. The failed-health path continues without a shove. |
| BBH_ENTRANCE,837–853 | Accepted entry ends processing. Already-entering actions continue without moving X/Z here. |
| WARP,855–901 | Accepted fading or ordinary warp ends processing. Rejected/already-teleporting paths do not shove. A high raw position is not contact with the real low warp merely because a floor query aliases. |
| WARP_DOOR,903–951 | Door entry ends processing. A missing-key dialog is an exception that can change action and still return false, but its entry guard requires WALKING/DECELERATING and it does not move X/Z. It is not a descending-air shove. |
| DOOR,999–1064 | Accepted opening/dialog ends processing. Other paths continue without a shove. |
| CANNON_BASE,1066–1076 | Cannon entry ends processing; already-in-cannon is a no-shove continuation. |
| IGLOO_BARRIER,1078–1086 | Sets used/interact references, pushes X/Z and continues. This is the relevant source pattern, but no stock SSL igloo barrier exists. |
| TORNADO,1088–1111; WHIRLPOOL,1113–1134; STRONG_WIND,1136–1156 | Accepted capture/wind changes action and ends processing. Their already-in-action or excluded branches do not move X/Z. Position following in a later automatic handler is not an earlier shove in this pass. |
| FLAME,1158–1186 | An effective dry burn selects a burning action and ends processing. Immunity, delayed-invincibility and extinguishing-in-water continuations do not shove. |
| SNUFIT_BULLET,1188–1211 | Damage/knockback ends processing. Metal-hit and ignored branches can continue, but change actor status/health effects rather than Mario X/Z. |
| CLAM_OR_BUBBA,1213–1227 | Always returns nonzero, including its final no-damage path. It cannot be an ignored contact that lets the later shell run. |
| BULLY,1229–1274 | Both actual X/Z-push branches return true. The ignored/invulnerable continuation does not push. |
| SHOCK,1276–1303; MR_BLIZZARD,1312–1322; DAMAGE,1423–1433 | Effective shock/damage/knockback ends processing. The continuing immunity/ignored branches do not move X/Z. |
| BOUNCE_TOP2, BOUNCE_TOP and KOOPA, all 1368–1404 | These three entries call exactly the same `interact_bounce_top` function. Attack recoil can change velocity; ordinary top bounce changes Y and makes vertical velocity +30; twirl bounce changes action and ends processing. None supplies a continuing X/Z shove. |
| HIT_FROM_BELOW,1324–1366 | Uses the same recoil/bounce helpers. A hit from below sets vertical velocity 0; ordinary top bounce sets+30; twirl ends processing. Non-damage continuations do not move X/Z. |
| POLE,1510–1558; HOOT,1560–1581 | Accepted grabbing/riding ends processing. Their used-object/previous-action/timer guards can reject interaction, but rejected branches do not shove. The JP pole path's velocity-reset bug does not change this return ordering. |
| BREAKABLE,1435–1458 | A qualifying attack ends processing. The nonattack path continues without a shove. |

The stock SSL inventory contains relevant examples of these checked groups:
coins/stars/warps/cannon, Tweesters, flames, Goombas/Pokeys/Fly Guys, Klepto
and breakable objects. The actor hitbox sources identify Goomba, Pokey and
Fly Guy as BOUNCE_TOP and Klepto as HIT_FROM_BELOW. Relocating one of these
actors to actual high coordinates would still leave its handler's ordering
constraint. The source uses IGLOO_BARRIER for `bhvIgloo`
(`data/behavior_data.c:1859–1867`); the stock SSL Area 1 script and macro list
do not instantiate it. This inventory statement does not prove a theorem
over every possible corrupted or aliased object-pool history.

## Why the apparently permissive enemy branches do not repair it

The helper names can be misleading. `bounce_back_from_attack`
(`interaction.c:650–668`) changes forward/slide/velocity values, and can
convert stationary punching to moving punching; it does not displace X/Z.
`mario_set_forward_vel` (`mario.c:374–382`) writes speed and velocity, not
position. The high stopped quarter cannot later commit the missing X/Z
merely because one of these handlers changed speed.

`bounce_off_object` (`interaction.c:515–522`) writes **only movement Y** and
vertical velocity among position/velocity components. Its ordinary +30
bounce prevents the later ordinary airborne shell test from reporting
HIT_FROM_ABOVE. `hit_object_from_below` (`524–527`) sets vertical velocity 0,
which also fails that descending test. Metal/attack classifications can
avoid a bounce and preserve a descending approach, but still provide no X/Z
push. This distinction matters: a continuing enemy contact is not by itself
the desired geometric change.

`take_damage_and_knock_back` (`710–733`) returns false only when its guard
rejects damage, without a sideways position write. Its active branch
returns the action setter's true result. The checked source's
`set_mario_action` ends with `return TRUE` (`mario.c:979–1014`); an ignored
damage branch must not be confused with a completed knockback action that
might move Mario later.

## Held, used and interaction-status fields do not reorder the pass

The handler loop selects the next **interaction type**, then finds the
first collided object with exactly that type (`interaction.c:403–416,
1780–1797`). It clears that type's bit before checking status/calling the
handler. An INTERACTED flag can skip that actor's handler, but cannot move
GRABBABLE ahead of KOOPA_SHELL, nor cause a second shell of the same type to
be tried later in the same pass. If the shell is skipped, no successful
mount has occurred. If it mounts, its true return ends processing before
GRABBABLE. A nonmounting shell can push and return false, but that branch
does not create RIDING_SHELL_GROUND and the shell type has been consumed.

Changing `usedObj` can affect a pole/Hoot guard and the later action's
reference; it does not change this table or its index. A genuine held actor
is dropped by the successful shell handler before the return. The drop
routine writes **that actor's** coordinates/held state and clears `heldObj`
(`interaction.c:295–313`); it does not push Mario or recursively run the
grabbable handler. Collision-list detection has already happened. Actor
behavior updates and future contacts remain later events.

These statements concern valid ordinary actor references, not an assumed
arbitrary alias between held-object storage and Mario's own state/object.
They do not exclude every cloning history. They also do not assume that a
held flag prevents contact: collision eligibility and which interaction
handler is actually reached are different questions.

One adjacent guard was checked rather than inferring a ground action from
an air grab: `mario_check_object_grab` (`interaction.c:418–446`) selects
PICKING_UP/DIVE_PICKING_UP only when the current action lacks the AIR flag.
An airborne dive's successful grab test therefore does not by itself enter
that ground action. The separate DIVE_PICKING_UP handler checks OFF_FLOOR
before ABOVE_SLIDE (`mario_actions_object.c:213–230`).

## Scope and useful next boundary

This closes the specific proposal “a normal SSL interaction earlier in the
same pass supplies an X/Z shove, then the descending airborne Mario mounts
the shell” at the inspected source-control-flow level. The absent igloo
pattern, arbitrary object corruption, different multi-update histories and
other action-conversion mechanisms are not globally excluded. No claim is
made that the only possible Ink producer is this one.

The high-window continuation should therefore test a genuinely different
predecessor: one that retains a useful action into a later update where a
grabbable handler can run, or another native transition that reaches the
ground-slide/alignment code without mounting in that same pass. Such a
result must still log unloaded producer top collision, fresh low cache,
the X/Z crossing, accepted warp, top capture/retention and useful spawning
displacement. Existing lower-top supported fragments do not answer that
high-window question.

## Floorless mounting retains the action, but queues death first

A separate multi-update proposal survives the action-order check: mount a
shell while the fresh floor pointer is null, let the final dispatch guard
preserve RIDING_SHELL_GROUND without executing it, then use a later box
contact after the shell's mount is no longer terminating the interaction
pass. This is **not** excluded merely because an ordinary high shell-ground
handler would bonk or fall. The relevant handler has not run yet.

The exact ordering is `mario.c:1314–1370` and `1699–1712`. Geometry first
queries movement position; on a miss it copies stored graphics XYZ into
movement XYZ and retries. If that second query also misses, it calls
`level_trigger_warp(m, WARP_OP_DEATH)`. Mario interactions run afterwards.
A descending shell contact can then select RIDING_SHELL_GROUND, and the
final null-floor guard returns before action dispatch. The ordinary-air
mount's moving-action initializer does not require a nonnull floor: its
floor-class helper guards that pointer, and its separate old-CRAWLING floor
normal access does not apply to this starting action.

On the following interaction pass the RIDING_SHELL flag makes
`interact_koopa_shell` return false without mounting again
(`interaction.c:1460–1483`). The later grabbable handler can consequently be
reached. `push_mario_out_of_object` (`616–647`) computes and wall-corrects a
candidate X/Z, queries its floor, and commits X/Z **only if that destination
query finds a floor**. It uses a local floor pointer; it does not refresh
Mario's cached floor. Thus a push can move Mario back over terrain while
the final action-dispatch guard still sees null. A further update can find
the new terrain and reach an action handler. Each of these is a distinct
update boundary, not an automatic same-update slide producer.

For an initially empty pending-warp queue, the earlier death request is
already fatal to this proposed normal object-warp continuation.
`level_update.c:723–764` installs DEATH (18), or GAME_OVER (20) if lives are
zero, with timer 48 and source node DEATH (241). All installation in
`level_trigger_warp` is guarded by `sDelayedWarpOp == WARP_OP_NONE`. A later
OBJECT (4) request does not overwrite that pending operation, timer or
source. Seeing ACT_DISAPPEARED or a warp object reference later would not
establish that the desired Area 2 warp was scheduled. The delayed-warp
consumer (`843–914`) uses the saved source node; finding a floor again does
not change it. The explicit resets to NONE at lines 422, 545, 1190 and 1289
belong to warp/level initialization, not ordinary floor recovery.

This call-level obstruction already has an actual generated US/JP Clight
proof; no replacement model or new proof is needed:

- `InkFailedRetryGuard.v:156`,
  `ifg_pending_operation_blocks_actual_trigger_call`, proves that a
  completed actual trigger call preserves memory and emits no trace when
  the live signed-short pending-operation load is nonzero.
- `InkFailedRetryGuard.v:175`,
  `ifg_pending_death_or_game_over_blocks_object_warp`, specializes this to
  an OBJECT request while DEATH or GAME_OVER is pending.
- `MainTheorem.v:1569`, `current_ink_fallback_contact_boundary`, already
  includes the general actual-call result through `InkFallbackBoundary`.

The proof requires the global symbol/load and a completed actual call with
that nonzero value still live. It does **not** derive the initial death
installation, frame every intervening interaction, prohibit selecting
DISAPPEARED, or prove a whole scheduler/reset history. The source ordering
and the runtime control are separate evidence for those adjoining steps.
This closes the proposed initially-NONE, no-intervening-reset continuation;
an already queued warp or a different history is outside that claim and
would need its own reachable predecessor.

The companion `ink-floorless-shell-entry.md` records the native Wafel control,
whose setup and measured outcomes belong to that study: a supplied
descending air cut at X=8192, Y=25000 (and a negative-edge control) mounts
the native shell with null floor and skips action dispatch, but ends its
first update with operation 18, source 241 and countdown 47. In its
actor-only repair, moving only the box before the next update pushes Mario
from X=8192 to X=8124 while the cached floor remains null. The next update
finds terrain; the pending death remains. This validates action retention
and recovery of terrain, **not** an accepted object warp or useful Ink
handoff. The later normal object-warp request itself was not runtime-tested
in that control; the existing call-level proof addresses its scheduling
guard.

## The nearby pad has no floorless pocket in the checked mesh rectangle

The static pad vertices span X=[−2149,−1945], Z=[−1125,−921] at height 768;
the surrounding roof is height 1280. A bounded source-mesh check is saved
as `instrumentation/ink-high-unloaded-entry/check_static_pad_cover.py`, with
its result in `static-pad-cover.json`. It parses the actual Area 1 collision
file and applies the three inclusive integer triangle-edge tests from
`surface_collision.c:401–467`. This is a finite geometry check, **not** an
execution of `find_floor`, surface loading, a controller replay or Coq.

All 185,761 integer pairs in X=[−2260,−1830], Z=[−1240,−810], inclusive,
lie in at least one eligible upward-facing horizontal pad or roof triangle:
143,736 pairs have roof coverage only, 41,209 pad coverage only, and 816
shared-edge pairs have both. There are zero uncovered pairs. This enlarged
rectangle includes the pad's 107-unit neighborhood and the neighboring
truncation-to-integer coordinates. The selected pad triangles are at
collision-source lines 1056 and 1061 (`SURFACE_WALL_MISC`, but upward-facing);
the roof triangles are at 1180–1191 (`SURFACE_HARD`). Neither type is a
camera-only or intangible surface.

For raw Y=25000, the queried Y is 25000; for raw Y=67277 it is 1741.
Both satisfy the floor height test for 768 and 1280. As usual, the floor's
returned height is the local 768/1280, not that value plus 65536. With the
ordinary static SSL mesh loaded and these query conditions, this supplies
nearby floor coverage rather than a floorless primer. Exact selection at
shared edges, dynamic floors, surface-list execution and any wall-corrected
transport are not simulated by this check.

Consequently, a proposed floorless state elsewhere must supply additional
transport into this neighborhood; merely placing one ordinary box close
to the pad does not supply a nearby missing-floor origin. The 107-unit
number is the standard box's radial push target (75+37−5), not a global
bound on arbitrary wall corrections, multiple interactions or histories.
Even a successful remote recovery still faces the earlier queued-death
condition. Neither observation excludes every high action-entry route.

Reproduce the geometry check from the workspace root with:

```text
python reference-sm64-wmotr-abc-proof/SSL-Coq/less-than-one-a-press/instrumentation/ink-high-unloaded-entry/check_static_pad_cover.py reference-sm64-decomp
```

Inspected local source SHA-256 values:

| Source | SHA-256 |
| --- | --- |
| `src/game/interaction.c` | `a327202d33612821f884f01b5e4692aa5cfe2003f3b9a2eeb1452ad72725ea00` |
| `src/game/mario.c` | `832c5301d3eda065310db5e5e429f6448eeeebcf7226a7e0bf2ac132556b8b1d` |
| `src/game/object_list_processor.c` | `203bcde4c5eb638eb1eab93d2d7b2226fda797644e26dc2b26d52c21edf851e8` |
| `src/game/level_update.c` | `d56f0950f4119d32dca2e1458d7c40059d57565421d3daec9db37531baf9c4ea` |
| `src/engine/surface_collision.c` | `d90b9b66250aad9596c0ef4be3f017c79f221dfd113010239f781226aaf3d2ef` |
| `levels/ssl/areas/1/collision.inc.c` | `198d388721ac25793a7e6b96fc579b71a44e95c3233c55aae08a5f7d0ee87d5d` |
| `data/behavior_data.c` | `da1aad6e3982bc3a35b195480157330e2cd98e909503e2100d2072d3be265f6a` |
| Local `levels/ssl/script.c` (stock comparison separately named above) | `ae34dfb1b8f5e83cda838234eeb6f48b0d77db5946e985dc74de407e6c7e93f0` |
| `levels/ssl/areas/1/macro.inc.c` | `890d95b332802b98f9d2dbd6a09bdf1a4c8028d7e411818fb8a697379b700525` |
