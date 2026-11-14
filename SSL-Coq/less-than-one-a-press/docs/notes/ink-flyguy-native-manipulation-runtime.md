# Western Fire Fly Guy: real high ground slide, missing useful cache history

14 November 2026. **A controller-only continuation now reaches a genuine
BUTT_SLIDE at Y1768 after bouncing on the native western Fire Fly Guy. It does
not complete useful Ink.** Mario lands on the still-stationary top before the
fourth pillar is credited. His actual floor cache is high. In 780 actor-only
small-box tests from four nearby reached states, movement, collision and stored
graphics remain equal at every sampled boundary. There is no accepted warp,
top capture at a warp, or Area 2 arrival in that menu.

This is a narrower failure than inability to enter a high ground action. The
high action is now reached in this history; its location, floor/cache provenance,
actor trajectory and top phase still do not form the working producer.

## Revisions, grants and earlier work credited

The study begins at proof revision
`4813e95d33286a30882caf0759dd838c95ee48f2`, branch
`codex/ssl-pyramid-item-proof`, with decompile checkout
`36fbf8d693a9fc2bdec0c77402f8e96d07d2f461` and applicable original-JP source
pin `9921382a68bb0c865e5e45eb594d9c64db59b1af`. It uses Wafel0.8.5 JP,
Python3.9.13 and DLL SHA-256
`960fe979068b78e6733b3ddb87741833fbf4eb29b2a21a2bba871977427c2d0f`.
The inherited 2,852-input capture has SHA-256
`9bcc451964025d9f0bb1344c45957b6bfd095451b44bfb9a01f8584a75db6a72`.

The existing [Crazy Box delivery study](ink-box-delivery.md) already found the
real pre-fourth Fire Fly Guy bounce to Y2099.5149. That prefix is reused and
credited, not presented as a new discovery. It begins after 2,500 accepted inputs,
steers through `(-5500,2300)` toward the western Crazy Box and pulses B every
tenth branch update while close enough until pickup. It then steers toward the
pyramid. The western Fly Guy is the native fire-capable slot45, spawn/home
`(-3400,1160,-1120)`; no clone is created or supplied.

The only noncontroller startup grant is inherited debug level selection.
Every primary update checks A released and rejects a noncontroller write.
No Mario pose/action/speed, actor placement, lifetime, held/used reference, HOLP,
floor/cache, top phase or RNG is edited. Saving/restoring a branch uses a full
state reached by the archived controller history. No castle-to-SSL approach or
held-A entry is assumed by this finite experiment.

## The new high-slide continuation

The old prefix supplies the first 2,804 controller inputs, including the native
Fly Guy bounce. From there a controller policy steers toward `(-2150,-920)`.
While twirling, it compares forward speed with `min(32, distance/15)`; when speed
exceeds that by0.6 it aims opposite Mario's facing to brake. Otherwise it aims
toward the target, with neutral stick only near the target at low speed. After
leaving TWIRLING it holds Z and steers toward the same target. The exact pad
stream is authoritative; these feedback rules do not edit speed or action.

The table counts **completed inputs**. M is movement, C is collision-object
position and D is stored `gfx.pos`, not the render matrix or visible model.

| Input | M=C=D | Action | Live support / actor result |
| --- | --- | --- | --- |
| 2804 | `(-3254.871826,1339.514893,-1178.699707)` | TWIRLING | Actual Fly Guy bounce; it is consumed. The held Crazy Box is dropped by the interaction. |
| 2823 | `(-2782.939209,2099.514893,-1386.602295)` | TWIRLING | Airborne apex; the dropped native box has already been deleted on landing. |
| 2855 | `(-2036.716553,1772,-1043.787354)` | TWIRL_LAND | Actual intact-top floor and platform61; cached floor1772. |
| 2866 | same position | IDLE | Native twirl landing recovery completes. |
| 2867 | `(-2036.716553,1768,-1047.598877)` | BUTT_SLIDE | Native slope/ground-action dispatch, cached floor1768; top still action0 with three pillars credited. |
| 2869 | `(-2037.098389,1750.000122,-1065.971924)` | BUTT_SLIDE | Still a real high ground slide; high live top cache remains. |

The twirl action is not relabeled as a ground slide. The history genuinely lands,
finishes the landing recovery and then enters BUTT_SLIDE. Likewise the airborne
maximum Y2099.5149 is not a maximum working handoff height. Y1768 is the largest
observed ground-slide height in the new 100-policy braking menu, not a proved
global maximum or an exhaustive landing-height bound.

The preserved full input stream is 2,869 inputs, with 2,521 Wafel observations
starting after input349. A fresh reconstruction matches the selected continuation.
The root task also confirms the trajectory on original JP: all2,869 inputs and
2,521 compared position/action/floor/platform and listed Fly Guy observations
match. Its strict comparison still reports1,951 interaction-subtype differences
(native130 versus Wafel128, polls849–2799). Thus the genuine high slide has
original-ROM trajectory confirmation, while full selected-field equivalence
does not pass. The native package's separate receipt records this limitation;
the component Wafel receipt here is not relabeled as a strict native pass.

## Does a box now complete the handoff?

The Crazy Box used for ascent no longer survives: the native Fly Guy interaction
drops it, and it falls and is deleted. The component test therefore uses the
still-live stock small cork box23, whose downstream push compatibility was
already established by the [replacement controls](ink-buddy-replacement-handoff.md).
Only its three actual XYZ fields are supplied, once at the start of each trial.
This is a Mario-side compatibility probe, not a demonstrated box delivery.

The finite menu begins after inputs2866,2867,2868 and2869, respectively IDLE at
1772 and butt slides at1768,1760.000244 and1750.000122. Actor Y offsets are -100,0,+100;
horizontal radii are0,20,40,60,80; nonzero radii use16 angles. All780 trajectories
run45 updates with the corresponding genuine controller continuation.

**520 initial contacts register. Every observed M/C/D triple is equal.**
Although554 trajectories later reach movement Y768 with fresh floor768, their
stored graphics Y is also768. None obtains the useful high stored-graphics retry,
contacts the warp, captures the top at a warp or reaches Area2. The low floor
cache eventually occurring during an ordinary descent is not the required
low-cache/high-position producer.

For one registered example, place the small box40 units east of the reached
input2867 position at the same Y1768. The next update ends at
`(-2088.813232,1751.000122,-1055.052002)` with BUTT_SLIDE, top floor/cache1751.000122,
and M=C=D. One update later they all agree atY1747.000244. The box really contacts
Mario, but the observed ground update follows the top floor and refreshes the
stored graphics instead of leaving the wanted split. These are update-boundary
observations, not a newly instrumented quarter-step breakpoint trace.

This rejects the stated finite single-small-box menu. It does not prove that an
intact top can never support Ink, that all actor sizes/combinations fail, or that
phase130 is a universal necessary condition. It also does not permit supplying
the low cache to erase this observed obstruction. A useful continuation must
actually produce it while retaining the needed ground code and position.

## Separate post-explosion lure/bounce and roof crawl

An independent controller diversion from the accepted first2,740 inputs steers
toward the native western Fly Guy at `(-3400,-1120)`. Mario first reaches a real
ledge atY1024. Fly Guy approaches, lunges under Mario and supplies a twirl bounce
after input2857. Mario peaks atY1885.1969. Constant steering later gives a low
slope butt slide and quicksand death. Forty follow-up flight menus vary target
and delay; one reaches a real roof landing followed by crawl atY1280, ending
`(-2112.283447,1280,-1495.331909)` after3,097 inputs. Aiming at the upper warp instead
reaches only the ordinary Area2 spawn `(0,5500,256)`.

This branch starts too late for the old spinning top: it has already been
removed. Supplementary native-identity observations confirm slot61 is no longer
`bhvPyramidTop`; its later raw action/timer/pillar fields must not be interpreted
as a reset or renewed pyramid top. The post-top crawl is a real gameplay
predecessor with the wrong height/cache/top state, not useful spawning displacement.

The root's separate original-JP replay confirms this3,097-input trajectory and
2,749 position/action/floor and listed actor observations, but reports2,003
interaction-subtype differences (native130 versus Wafel128, polls849–2851).
Again, trajectory confirmation is distinct from a strict all-field match.

The parallel flame/luring study may preserve Fly Guy instead of consuming it.
Its separate record is needed for any claim about that branch; the twirl-bounce
history above does not preserve the enemy for a second bounce or later transport.

## Coverage, verification and first remaining condition

The six retained batches cover338 primary controller histories (51,597 suffix
updates) and780 actor-only diagnostic histories (35,100 updates). Primary menus
include80 direct prefix diversions,40 post-top twirl continuations,28 alternate
real Buddy-history box-pickup continuations,90 pre-fourth steering/delay cases,
and100 pre-fourth braking cases. The alternate pickup cases die in quicksand
before a Fly Guy interaction. These finite menus are not exhaustive manipulation
searches. Earlier broad direct Fly Guy/Buddy substitution failures are not rerun.

The fresh verifier passes **1,120 stored history executions and93,085 observations**,
including the two overlapping selected full histories. It recreates every retained
branch from fresh controller-produced states and reapplies only the disclosed
XYZ cuts in the actor-only menu. No Coq theorem/build is added by this runtime
study. See [the instrumentation README](../../instrumentation/ink-flyguy-native-manipulation/README.md)
for archives, scripts, exact inputs and receipts; no ROM or runtime binary is included.

**Closest new predecessor:** genuine no-new-A ground slide atY1768 on the intact
top. **First exact failed handoff condition in the tested continuations:** a fresh
low cache with high movement/stored graphics before the stopping producer; the
ordinary ground history instead keeps all three positions together. The fourth
pillar/top activation and actual delivery of a surviving push actor also remain
unjoined. A different real manipulation/phase history, or a source-justified
multi-update displacement that changes this cache history, is still needed.
