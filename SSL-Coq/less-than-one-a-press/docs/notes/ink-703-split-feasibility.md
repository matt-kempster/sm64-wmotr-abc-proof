# Can controller inputs create the 703.46-unit Ink split?

The later [source-only installation-handoff review](ink-installation-handoff.md)
sharpens the lower-floor question below: no authored static Y=818 floor plane
occurs in the checked square within 100 per axis of the 923-unit target, but
a high query 68 units west has a Y=768 static pad candidate. An eligible push
could preserve that cache and make a conditional 973-unit snap. The new push
commit proof does not supply the high crawling state, actor, stopping exit,
full action tail or useful next-update timing. No new runtime trial was run.

The existing evidence leaves the no-A controller route open. The strongest
ordinary action lead is a stopped crawl that leaves a high stored display
after movement snaps to an older floor height. Its reachable size and its
lifetime through the next warp check are unknown. This review uses existing
proofs, notes, and saved receipts.

## The three positions at the successful checkpoint

In the [saved near-warp Wafel sweep](ink-near-warp-receipt.json),
the smallest successful sampled mixed-direction setup at top timer 131
supplied the positions below.

| Record | Position | Role on the target update |
| --- | --- | --- |
| Movement (M) | `(-1887, 818, -929)` | First floor query misses. |
| Raw object collision (C) | `(-1887, 818, -929)` | Overlaps the upper warp and supplies the contact cache. |
| Stored display (D) | `(-1645, 1465, -796)` | Retry copies this position into movement and finds the live top at floor Y `1542.98291015625`. |

Before the retry, M−C is zero, and D−C and D−M both equal
`(242, 647, 133)`. That is 647 up, 276.14 sideways, and
703.4642848 units in three dimensions. After the retry, D−M becomes zero
while M−C has that vector. The disappeared action and raw-position copy
then let the final platform check remember the top. The saved run retains
it through the warp and reaches Area 2 at approximately
`(365.59, 5500, -1096.80)`.

The same finite sweep found a 923-unit vertical setup with M=C at
`(-1882, 818, -939)` and D at `(-1882, 1741, -939)`. These are staged
Wafel results for supplied positions. The [existing original-JP recording](ink-floorless-warp.md#original-jp-confirmation)
validates a different, larger split. The sweep establishes sampled
sufficient poses. The [timer-131 geometry proof](timer131-surface.md)
gives a necessary upward gap of 632 under its signed-coordinate and
stock overlap assumptions. The broader [stock bound](ink-controller-predecessor.md)
is 385 under the stated top-floor and query assumptions.

## Bounds by producer and checkpoint

Positive vertical D−C is the requirement for the display retry. Positive
vertical M−C can serve a separate first-query route if movement already
finds the top. The staged first-query Variant used M.Y=1861 and C.Y=D.Y=768
for 1093 units of M−C. Bounds at individual stores and maxima from finite
receipts apply at their own checkpoints.

| Approach | Largest established amount or applicable limit | What the amount covers |
| --- | --- | --- |
| Ordinary ground refresh, accepted floor alignment, normal non-ejecting Tweester | **0 D−M Y** at the documented refresh or snap | A raw collision record can still lag until its copy. Large physical ascent is compatible with synchronized positions at the relevant check. |
| Stopped crawl | **Unknown reachable maximum.** At the snap, D.Y−M.Y is pre-snap M.Y minus remembered floor Y. | The snap writes only Y. A fresh rejected ground-step lookup cannot install the older low height. The completed action and next-update lifetime remain open. The crouch-slide caller needs its own connection. |
| Pre-update platform displacement | **0 new D−C** in the complete phase. **0 fresh M−C Y** from matching heights for the specified nonrotating or stock yaw-only case. | The platform can move M while C and D stay fixed, early enough for the Variant. Pitch or roll can move all three axes of M. A supplied fragment-payload calculation rises **1110.6683 Y**, with no reachable live-payload maximum established. |
| Push, walls and horizontal contact | **0 direct Y** from the documented horizontal push. The scale-1 shell has a nominal **89-unit** radial push from center before walls. | A push on M can change the floor query. The total local XZ maximum is unknown. The exact display-retry pose also requires C to follow the resulting low movement position before the next warp check. |
| Bounce, Crazy Box, and other lifts | **At most 251 fresh upward M−C or M−D Y** for the bounded actor snap from matching incoming heights. The sampled/conditional clear-air first step is **100** for the third Crazy Box launch and **31.5** for burning. | The measured end-update actor-placement maximum was **249.9533 M−D Y**, with M−C zero and death pending in that case. The box's **1300** and the fast twirl's **840** are modeled flight altitude. Ordinary refreshes copy the rise into the other records. |
| Tweester lift before refresh | **160 Y** for the documented normal-hitbox clamp example, **100** for the short one, given synchronized Y=768, zero incoming speed and fixed origin. | These are conditional M−C and M−D values. The documented non-ejecting display copy erases D−M. A broader clamp or ejection maximum is open. |
| Shell | **42 airborne / 45 grounded D−M Y** in the checked helper | The offset follows a refresh. No stacking is shown. |
| Water pitch and bob | **207.99609375 D−M Y** in the one-refresh expression envelope at M.Y=768 | The envelope combines independent component bounds. A joint reachable maximum is unknown. |
| Ledge release, pole, or hanging | Nominal **100 downward Y and 60 sideways** at the ledge-release store. Ordinary pole/hang copies give **0 D−M** at the copy. | The ledge adjustment can be followed by another refresh. The checked stock warp vicinity lacks the matching pole or hangable top. |
| Cannon | **118.169815 upward M−D Y** in the checked pitch expressions | The ordinary firing path requires a fresh A press. |
| Quicksand and dialog | **0 upward display sinking** under the accepted classified stock no-A depth-seed contract. **1834 D−M Y** in the supplied negative-depth/dialog receipt. | The largest of the 68 supplied-depth trials refreshes on release. Dialog can preserve a gap. Stock observed ordinary sand moved display downward by up to **181.1000** in the earlier route search. |
| Retry, warp, camera, pauses, and skipped copies | **0 independent pre-contact gap created** by the checked retry transfer, accepting setter, camera-only motion, or pause | The retry copies D to M and can transfer an existing difference into M−C. These cases can preserve, transfer, or consume earlier differences. |

The detailed [split catalog](position-split-catalog.md) also covers
generic object writers, cutscenes, and debug. Stock graphical Y-offset
commands in the scanned behavior scripts range from −288 to +240. Mario's
checked behavior has no such setter and its relevant offset flag is clear.
The listed external actor selectors and debug or ending contexts give no
stock controller route to this warp. A general maximum for arbitrary
objects or supplied states remains outside the reviewed bounds.

Supporting sources include the [stopped-crawl proof notes](ink-stopped-floor-producer.md),
[producer sizing](ink-concrete-producers.md), [split lifetime audit](ink-gap-lifetime-audit.md),
[platform payload calculations](pyramid-top-pu.md), [actor placement results](ssl1-placement-runtime-review.md),
[other interaction bounds](ssl1-other-interaction-placement-review.md),
[earlier route search](rank1-reachable-search.md), and [small-offset sizing](ink-gap-backward.md).

## What Mario would have to do

For the stopped-crawl lead, use Z and the stick to start a crawl while the
top is still live. Arrive at the stopped ground quarter with high movement
and an already cached low floor. At the refresh, Mario's actual position
must supply the high display. The stop must leave that old floor cached
so the alignment snap lowers movement while display remains high.

For the exact mixed pose, some writer after that refresh must also move M
242 units toward negative X and 133 toward negative Z. The ordinary raw
copy would then have to put C at the low warp overlap while D retains the
high pose. The next update must cache the contact before changing C,
miss the floor at low M, and find the live top when retrying from D. The
pure vertical 923-unit fixture removes the separate XZ requirement at
the cost of a larger vertical snap. Neither scenario has a demonstrated
way to make the older low floor and high movement coexist at the crawl
refresh or preserve the resulting gap to the target update.

The first-query alternative instead needs an effective, owned platform
transform to raise M onto the top before geometry while C remains low.
The stock yaw-only top cannot supply the vertical displacement, and the
fragment calculation has no completed controller history or floor and
support continuation.

Across 248 A-released western Crazy Box schedules, 62,429 recorded Area-1
samples had maximum positive D−C Y and M−C Y of zero. Four original-JP
replays observed 3,323 first floor queries and 3,323 final platform
queries. They found static ownerless floors and never retried. These
sampled limits leave the route open. See the
[controller predecessor review](ink-controller-predecessor.md).

## Working backward from the 923-unit vertical setup

Mario needs a **fresh low floor reading in the crawl update**. The
ordinary geometry routine runs before interactions and action dispatch.
It stores the current floor query result, and a display retry replaces
that result if the first query misses. Two misses prevent ordinary
action dispatch. Keeping Y=818 from an earlier Mario update does not
pass this routine. See the [floor-query execution cuts](ink-floor-history.md)
and the [JP geometry and action code](../../generated/jp_mario.v).

For the exact setup with zero sink depth, the first crawl quarter needs
movement at `(-1882,1741,-939)` and the live cached floor height at 818.
Mario must already be crawling. The initial geometry sets
`INPUT_OFF_FLOOR` above cached floor plus 100, and the ordinary crouch
and start-crawl actions respond by switching to freefall. Established
crawling can continue with this flag when Z and a nonzero stick are held
and no other cancel takes precedence. The first ground quarter must stop
before it installs a new floor. A missing local floor or the applicable
ceiling block can stop it. An accepted quarter updates movement and floor
height together, and a left-ground result skips alignment. See the
[JP moving actions](../../generated/jp_mario_actions_moving.v),
[JP stationary actions](../../generated/jp_mario_actions_stationary.v)
and [stopped-crawl proof notes](ink-stopped-floor-producer.md).

The authored static roof triangle `(261,263,264)` covers the unshifted
target X/Z at **Y=1280**. It is eligible when queried from Y=1741 under
the 78-unit rule. The saved phase probes at timers **128, 129, 130 and
132** also show that with all three positions at the exact low pose,
even the display retry finds no floor. That retry uses the exact
supplied X/Z. A normal static floor at Y=818 at that query point would
also be eligible at query Y=818. Thus an unchanged ordinary static floor
at the target cannot supply the desired low cache. The saved probes use
supplied poses. The high Y=1741 producer query on timer 130 is unrecorded.
See the [sweep and phase-probe code](../../instrumentation/wafel-jp-pilot/ink_near_warp.py)
and [saved receipt](ink-near-warp-receipt.json).

The roof and underside illustrate what could stop the crawl but still
fail to install Ink. If the first quarter selects the Y=1280 roof and
the underside of the spinning top as its ceiling, a ceiling at or
below Y=1901 stops the step at movement Y=1741. With 1280 also cached,
alignment produces a 461-unit split and leaves raw Y=1280, above the
warp-contact ceiling of 818. The ceiling cannot provide the lower cache.

The remaining same-update handoff would start with a high, established
crawler over a different query point that returns an actual floor at
818. A later displacement would have to put movement at the target X/Z
before the first quarter, while preserving the cache and the crawling
action. The normal object push is a concrete X/Z writer with that cache
behavior. It changes neither altitude nor the cached floor, and its
destination check requires a floor at the high pose. The quarter's own
wall corrections use local coordinates and a stopped quarter does not
commit them. The authored static vertices reach at most Y=1408, below
the wall probes at movement Y=1741, and the stock top mesh supplies
floors and ceilings. This original review did not identify a nearby floor at
818 or an eligible actor contact. The follow-up above identifies a different
768-height static candidate and the shell push class, still without a
reachable contact. Reaching
1741 in flight alone does not supply an active crawl. The stock yaw-only
top also supplies no large vertical carry.

The producer update must finish with the low collision position and
high display. Its earlier warp interaction must leave the crawl
running. An earlier top phase can work in principle if the subsequent
retry and warp acceptance occur while the top can still be captured,
and the game retains the platform until Area-2 entry. Merely standing
on the top leaves ordinary raw collision above the warp. In the saved
128–130 and 132 probes at this X/Z, supplied display Y=2300 gave initial
top capture but no outside-elevator arrival. The saved 923-unit payoff
uses timer 131. These samples leave other phases, heights and
continuations open.
