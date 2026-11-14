# Other high airborne entry paths — 2026-11-14

**Ordinary enemy damage does not supply the missing high ground-slide
conversion.** In the applicable JP source, its airborne knockback and
recovery remain airborne until an actual `AIR_STEP_LANDED` result. Eight
small native comparisons confirm that branch with an existing SSL Goomba:
they enter FORWARD_AIR_KB, never execute a ground-action handler, and never
capture the top or reach Area 2. This closes a specific proposed recovery
shortcut, not every high entry route.

This source pass complements [the high-entry guard analysis](ink-high-entry-source.md)
and [high-air/platform comparisons](ink-high-support-entry.md). It excludes
shell mount/cancellation, which has its own native conversion tests. It
also excludes creating a high dynamic support with other supplied actors;
such a support would require its own actual floor and delivery analysis.

## The precise recovery branch

`interaction.c:559` (`determine_knockback_action`) selects the air table if
the current action has AIR, ON_POLE, or HANGING, after the swimming/water
case. The forward/backward tables at lines 118–128 contain air knockback
actions in that row. Thus ordinary damage while FREEFALL, on a pole, or
hanging does not directly create ground knockback merely because a local
floor query returns a surface far below Mario.

`mario_actions_airborne.c:1097` (`common_air_knockback_step`) invokes
`perform_air_step`. Its land-action and hard-fall recovery requests occur
only in `case AIR_STEP_LANDED`; neither the animation nor an elapsed timer
independently requests them. Seven callers use this helper: forward/backward
air knockback, hard forward/backward air knockback, thrown forward/backward,
and soft bonk. Their optional wall-kick branch requires a new A press and
remains airborne anyway. The JP thrown-action argument handling differs
from later versions, but does not remove the landing guard.

The claimed exclusion is conditional: **while these seven handlers receive
no landed result, their normal recovery does not enter their ground landing
actions.** It does not assert that all possible future floor queries miss,
that every source action is one of these seven, or that no other actor can
interrupt them. The source deduction is not presented as a new Coq theorem.

Once a ground knockback has been supplied by some *different* mechanism,
`common_ground_knockback_action` is another problem: it runs a ground step
and eventually requests IDLE, without `align_with_floor`. The separate
`InkIdleOffFloorGuard.v` theorem covers IDLE's actual OFF_FLOOR tail. It does
not prove entry into, or every history through, that ground-knockback state.

## Other checked exits

| Candidate | Actual next action or position behavior | What it fails to supply |
|---|---|---|
| Grabbed/released | `act_grabbed` copies stored graphics XYZ into M, then requests THROWN_FORWARD/BACKWARD; both use the landed-gated air helper | A high ground slide. No non-SSL grabbing actor was injected |
| Shock recovery | Airborne shock uses an air step until landed; the grounded branch calls `stop_and_set_height_to_floor`, even when requesting IDLE | That helper assigns M.Y from floorHeight **then copies M to gfx.pos**, so it does not retain a high graphics Y |
| Squish recovery | The normal tail uses the same height-and-graphics snap. The early space-open return requests IDLE; a steep-surface LEFT_GROUND exit also requests IDLE | No call to common slide alignment. A remaining high IDLE is subject to OFF_FLOOR before crawl/walk entry |
| Putting on a cap | Runs `stationary_ground_step` and eventually requests IDLE; ordinary airborne cap collection does not itself select this action | A new airborne-to-ground-slide bypass. The stationary helper's no-sand/no-wind branch copies graphics after its floor snap |
| Crazy Box bounce | Its final bounce requests STOMACH_SLIDE only inside AIR_STEP_LANDED | Holding or bouncing on a supplied high box is not enough without that landed result |
| Cannon shot / wing flight / vertical wind | Their DIVE_SLIDE requests occur in AIR_STEP_LANDED | A high ground slide merely from looking horizontal or finishing an animation |
| Tornado release | Requests TWIRLING; the twirling handler uses an air step and lands through the normal landing result | A ground-action conversion at release |
| Pole/tree release | JP Z release requests SOFT_BONK. `set_pole_position` checks the ceiling sentinel and floor; its grounded returns require actual local floor contact/near-contact | A continuation of a high pole state into common ground-slide alignment |

The pole detail matters: with the default no-ceiling value 20000, continuing
pole positioning initially clamps Y to 19840. A subsequent below-pole exit
can overwrite that Y with the actor's base while selecting FREEFALL, so
19840 is **not** an unconditional bound on every return from the function.
None of these source checks supplies a globally reachable high actor, pole,
ceiling, or dynamic floor. Shock/foreign grabbing actors were not spawned
for runtime tests; stock SSL availability is kept distinct from generic
engine code. Tox Box squishing remains stock behavior, but was not turned
into an invented shock/grab handler.

## Reproducible stock-Goomba experiment

The accepted JP prefix has 2,548 A-off controller inputs plus its existing
pre-game debug level-select grant. Before top update 130, the test supplies:

- M=C=D=(-1950,Y,-939), FREEFALL, actionState=actionTimer=0;
- forward speed 20, velocity (20,-16,0), yaw 16384;
- in the interaction variant only, existing Goomba slot 6 at (-1989,Y+5,-939).

The Goomba's behavior, action, hitbox, interaction fields, health, and
intangible timer are not edited. Mario's floor/ceiling cache, platform,
health, and interaction list are not edited. No Crazy Box is placed in this
experiment. Every later input is neutral and A-off, with no held-A
dependency and no gameplay writes after setup. These positions and the
initial airborne state are grants, not reached controller histories.

| Supplied raw Y | Updates retained, each variant | First M=C=D.Y | With Goomba | Without Goomba | Last M=C=D.Y |
|---:|---:|---:|---|---|---:|
| 21778 | 1 | 21762 | FORWARD_AIR_KB | SOFT_BONK | 21762 |
| 25000 | 40 | 24984 | FORWARD_AIR_KB | SOFT_BONK | 22465 |
| 32767 | 40 | 32751 | FORWARD_AIR_KB | SOFT_BONK | 30232 |
| 67277 (+65536 from 1741) | 40 | 67261 | FORWARD_AIR_KB | SOFT_BONK | 66167 |

At the first update, every trial has floor cache 768 and ceiling sentinel
20000. Each retained boundary has **zero loaded pyramid-top surfaces**,
checked by an assertion. The final retained histories contain no
ground-action execution, no graphics/movement Y gap, no warp/top capture,
and no Area 2 arrival. All eight were independently reconstructed from a
fresh runtime: **242 matching boundaries**. At 21778 the top naturally
reloads on the following update, so the first pilot's later continuation is
excluded from the final unloaded-top receipt rather than suppressing the
native loader with an edit.

The positive-VPU pair has a useful negative detail. From the 22nd observed
update (top update 151), both floor queries fail at raw Y=66167, whose signed
terrain alias is 631. The cached height becomes -11000. M, C, and D stay at
66167, and the prior air action ID persists. But `execute_mario_action`
returns on a null floor before dispatching an action: the log records **no
FLT_EXECUTE_ACTION events** on those boundaries. This is action-ID retention
after a genuine floor miss, not execution of the needed slide/alignment
code. Raw collision also remains far above the real warp.

The frozen pose is not safe: on that same update 151, the real geometry
update queues DEATH (operation 18), source node 0xF1, with countdown 47 at
the observed boundary. The countdown continues to 29 by update 169 even
though the action handler is skipped. No warp fields were cleared. The
separate [world-edge shell diagnostic](ink-floorless-shell-entry.md) follows
this ordering through level clearing and also tests actor-only re-entry
into valid terrain; retained action IDs do not cancel the pending death.

The canonical run is
`build/wafel-pilot/ink-high-other-entry-20261114-revision-corrected.json`, preserved as
[the machine receipt](ink-high-other-entry-receipt.json). The
[script](../../instrumentation/ink-high-other-entry/search.py) saves every
initial write and all native observations/events. These are JP Wafel runs,
not new original-ROM replays. No fresh ground action was supplied or found,
so there is no positive candidate to promote to a retail-ROM replay here.

The next useful search must establish a *different* genuine conversion or
actual high support, rather than waiting longer for ordinary air knockback
to become a ground action without landing. Actor delivery and the complete
phase-correct handoff remain separate obligations. No route estimate is
changed by these finite failures.

Investigation revision: `77ed7515d9ddce96fe00a030a26aae8663b590b0`.
Decompile HEAD: `36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`, preserving existing
local instrumentation. Exact source hashes are in the receipt.
JP runtime SHA256: `960fe979068b78e6733b3ddb87741833fbf4eb29b2a21a2bba871977427c2d0f`.
Input-prefix SHA256: `9bcc451964025d9f0bb1344c45957b6bfd095451b44bfb9a01f8584a75db6a72`.
