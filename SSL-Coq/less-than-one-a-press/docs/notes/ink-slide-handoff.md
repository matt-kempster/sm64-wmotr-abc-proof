# Ground slides can complete the conditional Ink handoff

Investigated 13 November 2026. **Yes: several ground slides complete the
warp, top capture, stale-platform retention and useful Area 2 arrival.**
An already established crawler is therefore not the only possible action
at the local handoff. The high position and correctly placed pushing actor
are still supplied; this is not a continuous no-new-A route.

The simplest explanation is that the slide takes its attempted step, saves
the high graphics position, then aligns movement to the low remembered
floor. It can even change into a bonk action during that same update: the
alignment still runs. Next update, the low collision position touches the
warp, while the failed low floor query retries from the saved high position
and selects the top. The full continuation matters: merely producing the
graphics gap also happens in controls that enter the ordinary warp without
capturing the top.

Read this with the [height/VPU map](ink-height-map.md),
[source and proof boundary](ink-slide-source-proof.md), and
[machine-readable receipt](ink-slide-handoff-receipt.json). The receipt
contains full update traces for selected successes and failures, every
setup recipe and edit, all outcomes, and independent fresh replays.

## Starting work and exact implementation

The initial proof HEAD and fetched branch were
`c862841fcd6ddf00356029b45d5693772b309603`. The previously local
`ink-early-air-entry-crawl.md`, `ink-top-slide-to-crawl.md`, and
`ink-walk-edge-crawl.md` and their scripts/receipts were present, inspected,
and then preserved in commit `585864953a065ee212c34ddcf01fc1f435bde643`
before this investigation's new files were committed. Their negative
crawl-entry findings are credited, not replaced by a claim that slide
entry was previously untested. In particular, they already supply a native
landing at behavior 113 followed by stomach slide at 117, from a supplied
exterior freefall at 112.

The sibling decompile is
`36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`, with local changes. The relevant
source-file hashes are in the receipt; the investigation uses the JP paths
of the actual code, not local custom level-start staging. Native execution
is the existing Wafel 0.8.5 JP DLL, SHA-256
`960fe979068b78e6733b3ddb87741833fbf4eb29b2a21a2bba871977427c2d0f`.
The 2,548-input four-pillar prefix has SHA-256
`9bcc451964025d9f0bb1344c45957b6bfd095451b44bfb9a01f8584a75db6a72`.
It includes the previously disclosed debug level-select setup. This is
not a new original-ROM replay, nor a whole-memory-equivalence proof.

## Precisely what the primary fixture supplies

After replaying that prefix and waiting normally to stored top timer 130,
each alternative restores the same full native state. It supplies equal
movement M, collision-object C and stored graphics D positions
`(-1950,Y,-939)`, the named action, action state/timer zero, forward speed
20, velocity `(20,0,0)`, facing `(0,16384,0)`, slide velocity `(20,0)`, and
slide yaw 16384. The existing Crazy Box in slot 49 receives only XYZ
`(-1989,Y,-939)`. Its behavior, velocity, hitbox, tangibility and allocation
history are retained. Neutral controller input then continues to Area 2
or the 32-update cap. Alternative speed and input controls are separately
identified in the receipt. No A-held or A-pressed flag occurs.

No floor/cache, platform, collision list, surface, top timer, RNG or
allocator pointer is patched. The primary fixture inherits cache 1024
before the first update; the actual initial geometry query refreshes it
to the low pad 768 before the actor pushes M sideways. This is not a
fabricated stale cache. The pusher leaves M at `(-1882,Y,-939)` before
the action's attempted ground step. D is an actual stored field, not
necessarily the displayed model translation when a throw matrix is used.

The held-slide trials additionally prepare a real held Bob-omb (slot 39)
at behavior 129: its held pointer/state and nearby position are supplied,
and a native held callback executes before the high pose/action cut.
They are valid *supplied holding* tests, not action codes run with a null
held pointer, and not a demonstrated high-object delivery history.

The shell fixture supplies shell-box slot 32's action 4 at behavior 128;
two native updates spawn real shell slot 126. At 130 only its XYZ is
supplied, `(-1971,Y,-939)`; native velocities remain intact. This changes
allocation history, so historical allocator counts from other fixtures
are not attributed to it.

## Action-specific results

The small-height column independently tests **every integer 1738–1806**
for each of the six common slides, with neutral input and speed 20.
Its successful interval is inclusive. Each also tests the large heights
19839, 19840, 20000, 21776, 21777, 21778, 21779, 25000, 32766, 32767 and
32768. Only 21778, 21779, 25000, 32766 and 32767 succeed among those large
probes. These probes do not by themselves certify all intervening real
or integer heights for the other actions. The separate height study
exhausts the main-universe integer range for crawl and butt slide.

| Action | Supplied pusher/extra prerequisite | Independently tested ordinary-height result | +65536 test | Outcome / evidence |
| --- | --- | --- | --- | --- |
| Crawling | Crazy Box; Z and analog, speed 5 in the reference control | Height study: integer 1741–1803 and 21778–32767 | Y67277 | Useful handoff; supplied-state native execution |
| Butt slide | Crazy Box; established slide speed | Every integer 1741–1801 works in the local scan; listed large probes work | Y67277 | Useful handoff; bonk still aligns |
| Stomach slide | Crazy Box; established slide speed | Same independently observed local interval and large probes | Y67277 | Useful handoff |
| Crouch slide | Crazy Box; established slide speed | Same independently observed local interval and large probes | Y67277 | Useful handoff |
| Held butt slide | Crazy Box pusher plus supplied held Bob-omb | Same independently observed local interval and large probes | Y67277 | Useful handoff; bonk drops held object |
| Held stomach slide | Crazy Box pusher plus supplied held Bob-omb | Same independently observed local interval and large probes | Y67277 | Useful handoff; bonk drops held object |
| Dive slide | Real released shell at supplied XYZ | Same independently observed local interval and large probes | Y67277 | Useful handoff with shell; box/Bob-omb are important failures |
| Slide-kick-slide | Crazy Box or real shell | Y1741 tested; no alignment gap | Y67277 tested | Backward ground knockback; no useful handoff |
| Butt-slide-air / airborne slide-kick | Crazy Box | Y1741 tested; no relevant gap | Y67277 tested | Remain airborne in first update; no useful handoff in these trials |

These are not global action impossibility statements. Slide-kick-slide's
separate handler lacks `align_with_floor`; an entirely different mechanism
or predecessor is not excluded. Airborne slide animations do not execute
the common grounded helper. At speed 20 the six common-slide successes
end the producer update in `ACT_GROUND_BONK`, not the initially supplied
slide. At speed 5, the butt/stomach/crouch/held variants still succeed but
end in their slow bonk/stop actions. The source calls alignment after both
the fast and slow stopped-step branches.

For the flat-pad neutral butt-slide fixture, supplied binary32 speed
`4.347799777984619` fails: `update_sliding` stops it before the ground
helper. Speed `4.34782600402832` succeeds, as do 4.5, 5, 20 and 60.
Those two nearby values are tested examples, not an exhaustive minimum
speed proof. At supplied 17.389999389648438 the slow stop still succeeds;
17.399999618530273 produces the fast ground bonk and also succeeds.
Dive slide has a separate 8-unit stopping/animation condition; these
butt-slide speed bounds must not be copied to it.

## Full handoff, not just a gap

For butt slide at Y1741 and Y67277 with the stated box fixture:

| Completed update | M and C | D / floor / object result |
| --- | --- | --- |
| Before behavior 130, global 2680 | `(-1950,Y,-939)` | D agrees; inherited cache 1024, no platform; box at `(-1989,Y,-939)` |
| Behavior 130, global 2681 | `(-1882,768,-939)` | D=`(-1882,Y,-939)`; cache 768, no platform, box 49 overlap; action ground bonk. Gap 973 or 66509. |
| Behavior 131, global 2682 | `(-1882,1818.9613037109375,-939)` | D agrees; disappeared action `0x1300`, argument `0x40001`, used warp 64; floor owner/platform 61; six loaded top surfaces. |
| Behavior 132, global 2683 | Native top-following position, retained in receipt | Warp operation 4, source node 30, countdown 19; platform 61. |
| Globals 2684–2701 | Native top-following positions, one row per update in receipt | Platform and floor owner 61 throughout, normal countdown; no supplied timing change. |
| Globals 2702–2704 | Recorded native positions | Top slot 61 inactive, yet platform and floor owner still 61. |
| Global 2705, first completed Area 2 update | `(365.5927734375,5500,-1096.8026123046875)` | Outside the elevator rectangle; the desired useful displacement occurred. |

The ordinary first producer update has six loaded top surfaces and ceiling
1523; the +1 VPU producer has **zero** top surfaces and the no-ceiling
answer 20000. On the next update both have six surfaces because the low
collision position is back within collision-loading range. Actor positions,
actions, velocities and hitboxes are retained update-by-update in the
selected full traces. Wafel's action log supplies the pre-ground-step M;
it does **not** directly hook the local floor-query return or the quarter's
return code. The low query failure, high retry and stopped-quarter control
path are source/proof explanations matched to native fields, with their
remaining execution premises stated in the source note.

Two instructive failures have the same 973/66509 gap. Without a nearby
pusher, a common slide stays at X=-1950. The next low query still finds the
pad, so no graphics retry selects the top; the accepted warp reaches the
ordinary `(0,5500,256)` arrival. A dive-slide with the Crazy Box or Bob-omb
does the same. `able_to_grab_object` accepts the dive action before the
fallback push, setting the grabbable-input bit. The actor is behind Mario,
so the later facing test rejects the actual grab. It neither grabs nor
pushes him into the required floorless X/Z. A Koopa shell uses a different
interaction handler and provides the needed push, which is why the shell
version succeeds. “Dive slide cannot work” would therefore be wrong.

## Entry reachability: what improved, and what remains supplied

**Walking can enter the successful crouch-slide handoff with Z.** One
component first supplies walking on static roof `(-1800,1280,-800)` at
behavior 129, speed 20, then executes one no-button eastward input. That
native frame produces walking speed 20.634883880615234, slide velocity
`(20.611557006835938,-0.9808891415596008)`, and yaw 16883. At behavior 130,
a second cut supplies **only** equal M/C/D at `(-1950,Y,-939)` and the
box XYZ. Action, speeds, floor cache and platform are retained. Z with
stick `(33,55)` executes walking, then crouch slide, then the successful
bonk/alignment handoff at both Y1741 and Y67277. The high relocation is
still supplied; this is not a continuous climb from the roof.

This also exposed a setup trap: merely writing `ACT_WALKING` and forward
velocity 20 while inheriting zero slide velocity is not the same walking
state. Z can enter crouch slide, immediately stop, change to crouching,
then freefall/ground pound without a useful gap. The action transition
does not initialize all slide-speed fields for the investigator. The
native walking preparation removes that artificial failure.

**A simultaneous shell mount and Z cancel supplies another genuine native
transition, but not this handoff.** From supplied freefall at
`(-1950,Y,-939)`, velocity `(20,-16,0)`, and a supplied real shell at
`(-1950,Y-10,-939)`, one Z input mounts the shell in interaction processing,
then executes ground riding and crouch slide in the same update. It creates
the 973/66509 gap. It still leaves X=-1950, so the subsequent warp uses the
pad and produces no top capture. The high shell/approach remain supplied.
Freefall+Z without the shell starts ground pound instead.

The simultaneous cancel has a distinct actor lifetime from the old
[ordinary two-update dismount](ink-shell-producer.md): **the shell remains
free, action 0 and active through the remaining Area 1 updates**. The stop
routine overwrites interaction status with `STOP_RIDING` before the shell's
first action-0 callback; that callback no longer sees the `INTERACTED` bit
that would start action 1. It never enters the riding deletion branch.
The receipt records its native action, status, identity and position; it
is unloaded at the Area 2 transition. This does not contradict the older
mount-on-one-update/dismount-on-the-next test, which really deletes the
already riding shell. It also does not establish a clean delivery route.

**Native landing onto the moving top still does not supply the required
interior slide in the tested continuations.** The existing exterior
freefall recipe at behavior 112 is `(-1975.625,1556.4498291015625,-655.125)`,
yaw 35840, speed 0 and vertical speed -16. Replaying its documented inputs
lands at 113 and reaches native stomach slide at 117. A new 132-policy
screen then uses only no-A controller inputs through behavior 150: 16
world headings plus inward/outward/two tangents/next-uphill/next-brake,
magnitudes 32/64/127, with Z off or held. All 4,356 subsequent samples are
ground slides; none is deeply inside the top and none has a D–M Y gap
greater than one. No pusher is supplied in this screen. The bounded menu
does not exclude other moving-support, landing, remote-slide, item or
adaptive-input histories. The source note explains why remote sliding is
a landing-dependent path, not a button available from arbitrary freefall.

## Reproduction and validation

The final run contains 180 action/speed/input/no-box trials, eight alternate
actor trials, 489 action-specific height/speed probes, the 132-policy native
landing-slide screen, and 14 walking/freefall/shell entry cuts. These are
trial labels, not distinct controller-reachable routes. The primary script
repeats 112 selected trials across 2,968 updates from saved native roots.
The separate verifier freshly reconstructs roots and matches **93 selected
main trials across 2,570 updates**, plus **all 14 entry cuts across 420
updates**, in the declared field/event projection. These replay counts
overlap the main trials and must not be added as independent search coverage.
All strict positive checks include warp acceptance, correct action argument,
floor owner/platform, countdown, retention after top retirement, and exact
useful Area 2 arrival. No original-ROM run was added.

From `SSL-Coq/less-than-one-a-press`, use fresh output names:

```powershell
& ./build/wafel-pilot/python/python.exe instrumentation/wafel-jp-pilot/ink_slide_handoff.py build/wafel-pilot/capture.bKv95w/inputs.jsonl build/wafel-pilot/ink-slide-handoff-20261113-final.json
& ./build/wafel-pilot/python/python.exe instrumentation/wafel-jp-pilot/ink_slide_handoff_entry.py build/wafel-pilot/capture.bKv95w/inputs.jsonl build/wafel-pilot/ink-slide-handoff-entry-20261113-final.json
& ./build/wafel-pilot/python/python.exe instrumentation/wafel-jp-pilot/verify_ink_slide_handoff.py build/wafel-pilot/ink-slide-handoff-20261113-final.json build/wafel-pilot/ink-slide-handoff-entry-20261113-final.json build/wafel-pilot/capture.bKv95w/inputs.jsonl docs/notes/ink-slide-handoff-receipt.json
```

All three final commands exited 0. Output writers refuse to overwrite an
existing report; the receipt pins the final script/dependency/native-source
and raw-report hashes. Earlier pilots are not included in the counts.

The route assessment changes in one precise respect: “must somehow arrive
already crawling” is too restrictive. Suitable ground slides, and a native
walking-to-crouch-slide transition after a supplied high relocation, also
work. Reaching a useful high grounded action and delivering its pusher by
one allowed history remain open. The existing subjective estimates,
including Rank 1 **1–2%** and Ink Rank 2 **<1%**, are not measured
probabilities and are not recalibrated by these conditional successes.
The next useful experiment is to target the newly valid ground-slide
handoff state in a continuous entry search while tracking its pusher,
rather than requiring a transition all the way to crawl.
