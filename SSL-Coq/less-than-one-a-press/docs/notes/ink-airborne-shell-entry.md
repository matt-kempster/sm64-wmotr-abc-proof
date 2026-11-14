# Airborne shell cancel: the Crazy Box shove is skipped

14 November 2026. **A shell can put airborne Mario into the relevant grounded
action without A, but adding the Crazy Box does not complete the known Ink
handoff.** The first exact failure is the missing horizontal shove. Successful
shell mounting ends object-interaction processing before the Crazy Box's
later handler. The slide still makes the large vertical separation, but Mario
stays over the low pad; the next warp uses that pad and reaches the ordinary
Area 2 entrance.

This closes the proposed simultaneous combination at the source-control-flow
level and tests its exact local and +65536 fixtures in native JP execution.
It does not prove all shell-assisted histories impossible. A high airborne
Mario, shell placement and optional box placement are supplied. None is a
continuous controller route from the accepted start.

## Starting records and exact cuts

The inspected proof branch is `921e4d1954d79f3b4deb6958c88419a8f4bd5a28`.
The sibling decompile is `36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`, with
existing local changes; the receipt pins the applicable source files. Native
execution uses Wafel 0.8.5 JP, DLL SHA-256
`960fe979068b78e6733b3ddb87741833fbf4eb29b2a21a2bba871977427c2d0f`.
The 2,548-input four-pillar capture has SHA-256
`9bcc451964025d9f0bb1344c45957b6bfd095451b44bfb9a01f8584a75db6a72`.
Its previously disclosed pre-game debug level selection remains part of the
starting assumptions. No held-A dependency is used: A-held and A-pressed are
checked clear on every newly advanced frame.

The prior [slide handoff entry study](ink-slide-handoff.md) already tested
freefall plus a shell plus Z and found a gap without top capture. The new
question is whether adding the ordinary Crazy Box shove repairs that exact
failure. The test reuses its real-shell preparation: at stored top timer 128,
exclamation-box slot 32 receives `oAction = 4`; two native neutral updates
create shell slot 126. This action write is a supplied actor prerequisite,
not demonstrated shell acquisition. No fabricated shell object is inserted.

Before behavior 130, the freefall controls supply equal M, C and stored
graphics D at `(-1950,Y,-939)`, with Y either 1741 or 67277. They also supply
`ACT_FREEFALL`, action state/timer zero, forward speed 20, velocity
`(20,-16,0)` and facing `(0,16384,0)`. No slide velocity, floor cache,
platform, hitbox, top phase, collision mesh, RNG or allocator pointer is
written. The live shell, when used, receives only XYZ `(-1950,Y-10,-939)`.
The existing live Crazy Box in slot 49, when used, receives only XYZ
`(-1989,Y,-939)`. Native actor actions and velocities are retained.

The first input is neutral-stick Z (`buttons=0x2000`) or, for the delay
control, neutral followed by Z on the second frame. Remaining inputs are
neutral. Each run continues to Area 2 or 40 updates. The receipt lists every
individual write, input, native field snapshot and action/movement event.

## Exact observed outcomes

Both heights give the same action distinction; their successful gap sizes
are 973 and 66509 respectively.

| Supplied airborne fixture | First completed update | Following result |
| --- | --- | --- |
| Shell + immediate Z | M=C `(-1950,768,-939)`, D `(-1950,Y,-939)`, ground bonk | Warp accepted on pad; no top/platform capture; Area 2 `(0,5500,256)` |
| Shell + Crazy Box + immediate Z | Identical M/C/D and action, although the collision list contains both slots `[126,49]` | Same ordinary warp and Area 2 arrival |
| Shell + Crazy Box, Z delayed one frame | M=C remain `(-1950,Y,-939)`; backward ground knockback; stored graphics Y is temporarily Y+45 from shell-body tilt | Next frame the box/shell contacts move X/Z, but knockback does not call slide alignment; no top capture or Area 2 arrival within 40 updates |
| Crazy Box + Z, shell left at its native location | M=C `(-1882,Y,-939)`; ground pound, zero vertical gap | Shove occurs, but the required grounded slide does not execute; no useful handoff within 40 updates |
| Positive control: supplied butt slide + Crazy Box | M=C `(-1882,768,-939)`, D `(-1882,Y,-939)`, ground bonk | Top captured/retained; useful Area 2 `(365.5927734375,5500,-1096.8026123046875)` |

For the combined immediate-Z local control, global timer 2681 executes
behavior 130. Its native action events show riding-shell-ground followed
by crouch-slide in that same frame, then a ground-bonk action change. The
grounded helper genuinely executes; merely inspecting its final bonk action
would miss that fact. Its floor cache is 768, platform is null and X remains
-1950. Global 2682 accepts warp slot 64 and ends disappeared at
`(-1995,768,-971)` with static floor 768 and no platform. Globals 2683 onward
perform the ordinary countdown; the first Area 2 boundary is the standard
`(0,5500,256)`. The +65536 case repeats this outcome after the large snap.

In the delayed local control, global 2682 reaches approximately
`(-1946.240234375,1741,-1037.084716796875)` while still in backward ground
knockback, with M=C=D and cached floor 768. It is another example of a ground
action ID persisting high above a lower found floor; it is not the needed
ground-step/alignment path. The 45-unit first-frame graphics change is a
different graphics operation and must not be mistaken for the useful snap.

## Why this specific combination fails

The actual source orders shell interactions before grabbable interactions:
`src/game/interaction.c:84–115`. A successful shell mount in
`interact_koopa_shell` returns the result of `set_mario_action` at lines
1460–1477. The loop in `mario_process_interactions` breaks on that nonzero
handler return (1780–1797), so it never reaches the later Crazy Box handler.
Both objects being in the collision list does not imply both handlers ran.

Z is consumed later, during action dispatch. `act_riding_shell_ground`
stops riding, raises forward speed to at least 24 and returns the
crouch-slide action (moving source 1203–1214). That action can execute in
the same frame. Its stopped quarter copies high movement into `gfx.pos`,
then the common slide helper aligns movement to the already refreshed low
floor. It cannot retroactively run the skipped Crazy Box interaction.
At the exact tested pad pose the stopped quarter does not advance X/Z.
The next low query therefore continues to find the pad, rather than taking
the failed-floor retry from high stored graphics.

Delaying Z does not preserve riding here: the stopped ground step instead
stops the shell and selects backward ground knockback (moving source
1224–1228). The ordinary knockback helper, at 1588 onward, runs a ground
step but lacks `align_with_floor`. This explains why the subsequently
available box shove fails to make the same split in the delay control.

Source inspection also rejects two easy substitutions as ready-made SSL
solutions. The earlier-priority igloo-barrier handler does push and return
zero, but an ordinary SSL Area 1 igloo-barrier actor has not been established.
The bully push branches return nonzero and terminate interactions as well.
No actor type, flags or collision priority is edited to manufacture a
successful combination. This is not an exhaustive classification of every
earlier actor, global displacement or multi-frame shell history.

## Verification and remaining branch

The [receipt](ink-airborne-shell-entry-receipt.json) preserves eight new
trial recipes and two positive controls. Two independent fresh game
instances reconstruct the prefix and shell preparation; all ten histories
match across 310 recorded boundaries and their event lists. Every advance
increments the native global timer by one. The two butt-slide controls
still complete the known handoff, so the combined failure is not a broken
phase or actor fixture. No new original-ROM replay is claimed in this
receipt; the parent investigation's separate JP observer is distinct.
That [original-JP observer](../../instrumentation/jp-ink-mario-entry/README.md)
now independently confirms the Y1741 crawl control, shell-only failure and
shell-plus-box failure as modes1–3, with159 retained end-update observations.
The original-ROM endpoints match; its source-based interaction explanation
does not claim a newly installed internal interaction-return hook.

The script is `instrumentation/ink-airborne-shell-entry/search.py`; it
refuses to overwrite outputs. This investigation used
`build/wafel-pilot/ink-airborne-shell-entry-20261114.json`. Its root-level
reproduction instructions are in that instrumentation folder's README.
No Coq theorem is added by this experiment.

The useful unresolved alternative is a genuinely supported slide or walking
predecessor whose displacement loses upper support before geometry refresh,
or a different pre-action displacement that supplies the horizontal crossing
without terminating shell mounting. The prior fixed behavior-113 landing
has already received extensive crawl/edge steering searches; varying the
landing/support geometry and targeting a valid slide directly is more useful
than repeating that same fixed-seed menu. Mario entry, actual actor delivery
and their shared timing remain separate open obligations. These results do
not change the subjective route estimates.
