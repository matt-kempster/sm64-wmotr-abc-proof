# Why ground sliding can make the Ink split

Investigated 13 November 2026. This source analysis accompanies the supplied-state
[slide handoff experiments](ink-slide-handoff.md) and [height survey](ink-height-map.md).
Those records distinguish native runtime results from a controller-reachable route.
The source alone does not establish a complete handoff.

## The three positions and the stopped step

**M** is MarioState's movement position, **C** is the Mario object's collision
position, and **D** is its stored graphics position. The successful sequence needs
a low C for the upper warp and a high D for the later floor-query retry; a high
animation, camera position or terrain matrix is not automatically that D.

In `mario_step.c:258–347`, each ground quarter first resolves walls, queries the
floor and ceiling, and records the upper wall. A missing floor returns the stopped
wall result before copying the attempted movement or installing a floor. With a
floor, a step more than 100 above its queried height returns the same stopped
result if **raw attempted Y + 160 >= returned ceiling height**. Otherwise that
high step installs its queried floor and leaves ground. A floor-to-ceiling gap
of at most 160 also stops. Accepted grounded movement copies the queried floor
height to M. Thus stopped movement does not automatically mean a physical wall.

`perform_ground_step` then copies M into D, including when a quarter stopped.
The caller's later `align_with_floor` (`mario_actions_moving.c:88`) copies the
**cached** `floorHeight` into M and builds a terrain matrix without copying that
new Y into D. The later Mario-object raw copy produces C from M. An old low cache
can therefore leave D high while M and C become low. The query's local returned
height and the cache are distinct: a stopped quarter need not install the new
local floor. Existing crawl work establishes this distinction already.

## Which slide handlers use it

All actions first face `check_common_moving_cancels`: water plunge, a stomp when
not invulnerable, squish, and low health when not invulnerable can replace the
action before its handler. No table row promises survival of those guards.

| Action | Path and early exits | Ground result and split mechanism |
| --- | --- | --- |
| Butt slide | `common_slide_action_with_jump`; A can jump when timer is 5. `update_sliding(...,4)` can stop. | Shared helper calls ground step, then floor alignment for NONE or HIT_WALL. |
| Holding butt slide | Same, with held jump/stop/air actions; drop-object status first drops into ordinary butt slide. | Same shared alignment. A fast bonk drops the held object. |
| Crouch slide | ABOVE_SLIDE immediately changes to butt slide; before timer 30 A with speed>10 long-jumps; B at speed>=10 selects airborne slide kick, otherwise move punching; other A jumps, first-person brakes. Then shared helper with threshold 4. | Same if those guards allow the shared helper to run. |
| Stomach slide | `stomach_slide_action`; at timer 5, A or B rolls out if not ABOVE_SLIDE; threshold 4 can stop. | Same shared alignment. |
| Holding stomach slide | Drop-object status first drops into stomach slide; same timer/rollout guard; threshold 4 stop selects dive-picking-up. | Same shared alignment if reached; fast bonk can drop the object. |
| Dive slide | A/B rolls out unless ABOVE_SLIDE. Threshold 8 plus animation end changes action but does not itself return; an actual grab can return before the shared helper. | Same shared alignment when reached. Actor interaction differs: a Crazy Box or Bob-omb may become a grab candidate instead of pushing. The shell experiment is a distinct positive control. |
| Slide-kick-slide | Separate handler; A rolls out; animation end with speed<1 stops. Calls `update_sliding(...,1)` then ground step. | **No `align_with_floor` call.** HIT_WALL reflects and selects backward-ground knockback; LEFT_GROUND selects freefall. It cannot use this handler's missing post-copy floor snap. This is not a theorem excluding every later possible split. |
| Butt-slide-air, holding-butt-slide-air, airborne slide kick, dive/freefall with a sliding animation | Air handlers call `perform_air_step`, with their own landing/bonk/timeout rules. | Not the shared ground-slide path. A real landing may select a ground action for a later dispatch. |

`update_sliding` (`mario_actions_moving.c:224`) uses cached floor class, slope,
slide velocity and stick direction. Its stop test requires both a non-slope
floor and squared speed strictly below the squared threshold. A slope can keep
a slow slide active. Forward speed alone is not a complete supplied slide state:
slideVelX, slideVelZ, slideYaw, facing, cached surface and input all matter.
The moving-action initializer has no crouch-slide case that reconstructs those
slide velocities. A native preceding walking update supplies them through
`apply_slope_accel`; merely editing forwardVel is a different and potentially
inconsistent controlled state.

The shared helper (`1359–1411`) does not immediately return after a wall result.
On a non-slippery cached floor, `slide_bonk` runs; JP always adds vertical stars
there (US additionally checks speed). If forward speed is >16, it reflects and
drops into ground bonk; otherwise it zeroes speed and selects the caller's stop
action. On a slippery floor with a nonnull wall, it reflects the sliding vector
and applies the 0.9 loss with a minimum speed of 4. With no wall it skips that
reflection. **Every one of these branches subsequently calls alignment.** A
bonk/action change therefore does not by itself prevent the gap in that same
helper invocation. Whether the later complete update retains it is a runtime
and execution obligation, addressed separately by the receipts.

## No-new-A entry leads and their boundaries

Ordinary walking checks `should_begin_sliding` before Z. That test needs
ABOVE_SLIDE and a slide-level, backward motion, or downhill facing. Action
initialization turns BEGIN_SLIDING into butt or stomach slide according to
downhill facing (`mario.c:918`). If earlier guards do not fire, walking Z selects
crouch slide (`mario_actions_moving.c:808`). On the spinning top, Z can therefore
lead into butt sliding rather than a crouch or crawler. The previously local
[top-slide](ink-top-slide-to-crawl.md), [walking-edge](ink-walk-edge-crawl.md), and
[earlier-air-entry](ink-early-air-entry-crawl.md) records were available and were
read; their negative crawl searches do not exclude successful slide handoffs.
They were preserved and pushed separately at `5858649` before this new work.

Remote sliding has a specific source path: `common_landing_cancels` checks an
extremely steep floor, then `should_begin_sliding`, before INPUT_OFF_FLOOR
(`mario_actions_moving.c:1758`). This can select grounded sliding while a
landing action is already off its remembered support. It is not an entry from
arbitrary freefall. Freefall uses B for dive and Z for ground pound
(`mario_actions_airborne.c:525`) and requires an actual landing or other verified
transition to reach the landing cancellation path. Moving supports can change
the relationship to the cached floor between these operations; their actual
timing and floor history must be demonstrated.

A second source lead is shell contact: `interact_koopa_shell` can set
RIDING_SHELL_GROUND after a hit-from-above or walking/holding-walking interaction,
even in air. Shell cancellation can then select crouch slide. This still needs
a real shell at the right raw coordinates, the correct contact/action and
subsequent timing; the source comment is not an arbitrary high-slide installer.

## What repeats in a VPU

For exactly represented integers in range for the float-to-integer conversion
(signed32 in the checked CompCert semantics: -2147483648 through values strictly
below 2147483648),
the initial floor/ceiling conversion obeys
`alias(y) = ((y + 32768) mod 65536) - 32768`.
For fractional inputs, conversion first truncates toward zero, then narrows to
signed16; one must not translate a fractional endpoint by applying an integer
formula blindly. For example, -0.5 truncates to 0, whereas 65535.5 truncates to
65535 and narrows to -1: adding 65536 across zero need not preserve a fractional
query. The report's conventional main interval is `[-32768,32768)`;
the float immediately below 32768 still converts to 32767, while 32768 converts
to -32768. This convention does not mean every negative fractional point just
below -32768 has already changed its cast: truncation toward zero matters.

Both `find_floor` and `find_ceil` use these initial signed16 coordinates
(`surface_collision.c:306,513`), but return heights of the actual stored
surfaces, without adding the VPU offset. Furthermore, `vec3f_find_ceil` queries
at **returned floor height + 80**, not at raw movement Y (`mario.c:547`). An
equivalent initial floor query consequently need not create a shifted ceiling
query or a shifted physical floor. The intangible-floor second query has its
own expression and is not covered by merely checking the initial cast.

The no-ceiling value is 20000. With a nonnull floor and raw Y sufficiently above
it, the stopped-quarter comparison can succeed against this sentinel even
without a ceiling surface: for integer Y, Y>=19840 satisfies Y+160>=20000.
That is a condition for this local branch, not a minimum successful handoff.
It still needs the right cache, pusher, action, warp and later retry. Binary32
rounding determines a precise fractional boundary near 19840.

Dynamic collision loading uses actual object-to-Mario distance and the current
room/time-stop checks (`surface_load.c:754`), and can disappear at high Y.
That may remove a high floor or ceiling and change the cache; after a low snap,
collision can load again on the next update. Raw Mario/object hitboxes and warp
coordinates do not wrap with floor queries. Neither do death/water tests,
action transitions, platform ownership or timing. At large magnitudes,
binary32 spacing also changes which nominal coordinates or offsets survive.
The finite height/VPU runtime survey, rather than this alias formula alone,
determines which full handoffs were actually observed.

## Formal checkpoint and remaining obligation

`proofs/InkSlideHandoff.v` extracts the common-slide ground call and switch from
both generated US and JP Clight bodies. A finite ten-edge source census also
checks all six common ground-slide caller paths and the absence of a direct
alignment/common-slide-helper call in slide-kick-slide. The exported boundary is
`MainTheorem.current_ink_slide_handoff_boundary`. It connects the actual resolved
ground-call return to that switch and proves that result 2 reaches the resolved
alignment call after the **actual** bonk/reflection prefix. At alignment entry,
if the current cache contains height F, the real snap stores F into movement Y
while preserving the Object pool, including C and D. It does not assume the
prefix preserved the pre-bonk floor or display, and does not prove the matrix
tail, the whole action/update, action entry, object delivery, warp capture or
Area 2 lifetime. Those missing bridges are explicit; this is not a new global
no-A theorem or a controller-reachable counterexample.

The sample-conversion theorem executes the actual initial signed-short Y
statement of floor and ceiling queries. Samples -129331, -63795, 1741, 67277,
132813 all convert to 1741; -32769 converts to 32767, -32768 stays -32768,
32767 stays 32767 and 32768 converts to -32768. These are finite real-statement
certificates, not an unrestricted float-periodicity theorem.

## Provenance and validation

The starting proof tip was `c862841fcd6ddf00356029b45d5693772b309603`;
historical local work was subsequently preserved at
`585864953a065ee212c34ddcf01fc1f435bde643` before new edits.
The decompile base is `36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`, with local
instrumentation changes left intact. The canonical generated JP files used
have SHA256:

| File | SHA256 |
| --- | --- |
| `jp_mario_actions_moving.v` | `be1314c3ff8ea5ab33015e20a20344e7360d7b44533ba059d5c2b5b35d9084a7` |
| `jp_mario_actions_airborne.v` | `15baaa2ee897d1ed5af963e4b2dac8eaaf1cfe8176b7a0dbeb6036b4ca5b06e4` |
| `jp_mario_step.v` | `6f54f2a9bbe4c39701aa39fd2350471bd52be704eda1db8f31edd7093a6a7854` |
| `jp_surface_collision.v` | `1475bf6d73fcbe1f64dddb1d4525b8d3e5899c920f46a46ccf892cd1aedb8ae0` |

The reviewed decompile moving-action, airborne-action, Mario-step,
surface-collision and surface-loading files were unmodified relative to that
decompile base (other instrumentation files remain dirty). Their SHA256 values
are respectively `63364abba7cd12cb89e47614f901c933334a26654183896448f309fa2d847cfb`,
`49a1df4e42e169a745e7c91c592bb6139ca1aa43ad27d6e7f1fb3d9cdc6f812f`,
`6bbec9d8b20fd7b7fbce0f864b9f311be008a95d2881f024140140f1a9430222`,
`d90b9b66250aad9596c0ef4be3f017c79f221dfd113010239f781226aaf3d2ef`,
and `a9688dbac5b95e4859fc40c659faaf4c8064e0e7f8807dd2cf9c5ac7bd5cb9b0`.

Ubuntu WSL activates `sm64-item-proof`: Coq 8.16.1, CompCert 3.15, unchanged
6.5 GiB pipeline cap. The applicable `docs/proof-audit.md` explicitly replaces
the legacy root WMotR audit with the active SSL pipeline. The baseline assumption
queries for backward execution, retry and vertical geometry succeeded with 9, 7
and 4 allowed foundations. A concurrent source edit made the baseline integration
check stale; it was not accepted as a passing complete audit. An initial direct
assumptions-wrapper invocation also failed because its shell had not activated
the switch; the successful checks use `pipeline/env.sh` or the active audit,
which activates it itself. No bare `coqc` build was used.

The **final stable-tree audit passed**, including the new source census and
MainTheorem export. Its retained [summary](ink-slide-source-proof-audit-summary.txt)
and [structured report](ink-slide-source-proof-audit.json) record 717 source
files, successful build/hole/link-hygiene checks, and 551 of 637 proof modules in
MainTheorem's import closure, with 86 intentional standalone modules and zero
integration problems. The five assumption checks use respectively 9, 7, 4, 7 and
6 allowed Coq/CompCert foundations; there are no project axioms or admitted
proofs. The conversion execution statement mentions the standard execution
relation, so an allowed external-semantics foundation in its printed footprint
does not mean it called an external or proved a whole-game execution.

Reproduce from this SSL directory in Ubuntu WSL:

```sh
bash pipeline/discipline-check.sh --build-timeout 600 --assumption-timeout 240 \
  LessThanOneAPress.Proofs.MainTheorem current_ink_backward_execution_boundary \
  LessThanOneAPress.Proofs.InkRetryQuery irq_retry_connects_display_to_real_floor_call \
  LessThanOneAPress.Proofs.InkVerticalRetryGeometry ivr_vertical_retry_geometry_checked \
  LessThanOneAPress.Proofs.MainTheorem current_ink_slide_handoff_boundary \
  LessThanOneAPress.Proofs.InkSlideHandoff isl_actual_vpu_sample_y_conversions
```

Full command logs remain in `build/audit/20261113-015828-ma9zuzz8/`.
The timed targeted check also passed before adding the final source census;
the final audit rebuilt the resulting module and MainTheorem. This advances the
local generated-source checkpoint from a hypothesized shared-slide alignment
path to a checked actual-call/switch checkpoint. It does **not** discharge clean
entry, whole-update position continuity, object delivery, live retry selection,
warp/platform lifecycle or the global impossibility obligations.
