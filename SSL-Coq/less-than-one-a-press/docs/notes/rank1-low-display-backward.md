# One-second backward horizon from the low-display installation

3 October 2026. This follow-up starts only from the supplied installation with
movement at `(-2200,1861,-1024)` and both collision and display at
`(-2200,768,-1024)`. Depth is zero. The requested backward horizon is thirty
updates, nominally one second. The finite search takes **9.947622 seconds for
1,476 candidate checks**, or 11.6480921 seconds including preparation and the
initial installation control. It validates one backward update; every sampled
extension fails, so the tree empties at depth two. **No thirty-update chain is
obtained.** This is not exhaustive one-second coverage or a gameplay exclusion.

## The target really is this variant

The new `--target low-display` mode supplies this variant as its recognition
control and requires movement Y=1861 at the disappeared-action entry. Matching
only the end of the update would admit other acceptance heights, so that event
check is enforced on last-update proposals as well as extended replays. The
control selects the original top and upper warp, retains the top and reaches
the first Area-2 displacement `(365.5927734375,5500,-1096.8026123046875)`.

Wafel advances from frame 492 to 493 for installation. Earlier proposals start
at frame 491 and must first reproduce the selected frame-492 parent, then the
installation continuously. Frame labels are not substituted for the actual
inside-update warp checkpoint. The exact retail observer receipt from
`emulator-y1861-low.RjJrb5/` is rechecked against the variant's nine position
words and first Area-2 apply; no new emulator capture is claimed. Wafel still
does not itself expose collision/display at the successful handler return.

## The bounded tree

| Stage | Checked result |
| --- | --- |
| Last update into installation | 216 proposals: 36 match, grouped into one pose; 180 fail |
| One update earlier | 1,260 proposals: all fail the parent comparison |
| Search time | 9.947622 seconds |
| Total with preparation/control | 11.6480921 seconds |
| Median trial | 6.2604 milliseconds |
| Limits | 30 updates; 9,000 candidates; 90 seconds; 6 retained poses |

No candidate, time or pose limit is hit. The last-update menu uses six movement
heights and 36 released-A input representatives, with the low collision/display
fixed by the target. Duplicate declared patches and inputs are removed. The
36 successful inputs give the same declared pose; the first neutral suffix is
retained. Their omitted states are not proved equivalent, so grouping is a
finite search choice rather than a coverage theorem.

The earlier inverse menu proposes ordinary ground copying/sinking, four
freefall quarters followed by copying/sinking, or the final automatic-dialog
update. Its heights, speeds and depths are sampled. In this low-display target,
the depth hypotheses are zero or positive: the target's display is below its
movement. This run does not grant a negative seed. Every trial restores the
earliest full scene context, patches once and advances normally, without an
intermediate patch or restore. Failed parent comparisons stop the trial before
the installation suffix. A separate retained neutral control runs continuously
through the first Area-2 displacement.

## The useful rejection detail

Here, "dialog" means Mario's automatic message-reading action, used for
star-count milestone messages. This trial supplies `ACT_READING_AUTOMATIC_DIALOG`
with action state 24, immediately before its final update returns to idle.
It also supplies movement Y=1861, collision/display Y=768 and depth zero.
No star is collected and no actual message box is opened to construct that
state. The test asks what the action ending does to those candidate records;
it does not demonstrate a reachable reward/message predecessor.

The neutral ground proposal at movement Y=1861 instead reaches the disappeared
action one update early and synchronizes the three heights at 1899.650390625.
The sampled freefall proposal with speed -16 does the same. These trials do not
leave the required idle parent with its low collision record.

The final-dialog proposal at depth zero is closer: movement stays at 1861,
display stays at 768 and the action becomes idle. **Its collision record becomes
1861**, however. That single mismatch rejects it. This proposal inherited its
movement/display split; it did not discover a way to create it. With supplied
depth 1093, the corresponding proposal also retains the wrong depth. Thirty-five
additional neutral diagnostics save the exact mismatch and patch records
outside the timed search. These are finite counterchecks, not whole-family
proofs about dialog, freefall or grounded movement.

## Why this continuation misses the upper warp

The neutral final-dialog continuation was separately extended for 24 updates
from its single initial patch. It never reaches the disappeared action or
Area 2 in that window. This is a checked finite continuation, not a statement
about every later input or dialog history.

During automatic dialog, the action's intangible flag prevents the warp
handler from running. When that update ends, Mario returns to idle and the
normal Object copy writes movement Y=1861 into collision Y. Display stays at
768 for that one boundary. The next contact test uses collision, not display.
The live upper warp is at Y=768 with height 50 and down-offset zero, so its
vertical span ends at 818. Mario's collision bottom is 1861 with down-offset
zero, above that volume. The source's hitbox-overlap test rejects such separated
vertical intervals. The next ordinary update refreshes the display as well:
movement, collision and display all become Y=1935.7481689453125. The old low
picture therefore does not supply the required low collision contact.

This explains rejection of this trial without assuming that every movement
and display split is useless. The useful supplied installation instead has
collision Y=768 when the warp is checked, while movement Y=1861 lets the first
geometry query find the top. Creating that simultaneous relationship remains
open. The actual US/JP generated hitbox, warp, interaction and Object-copy
functions were inspected; the new runtime continuation is JP only.

The reproducible diagnostic is
[`dialog_continuation.py`](../../instrumentation/concrete-ink-backward/dialog_continuation.py),
with a [compact receipt](../../instrumentation/concrete-ink-backward/expected-dialog-continuation.json).
Full observations remain in
`build/concrete-ink-backward/20261003-low-display/dialog-continuation.json`.
No formal theorem, estimate change or Already proved promotion follows.

## What remains conditional

Other state comes from the existing normally initialized SSL prefix followed
by supplied four-pillar completion and unmounted neutral scene contexts. No
controller route to a patched pose, action or depth is established. Comparison
covers movement, collision, display, action and depth at parents, plus the
selected warp, floor, owner, platform and action-entry fields at installation;
it does not cover all memory. Moving support, different earlier collision
positions, late writers, other actions, timings, inputs and scene histories
remain outside this menu. The 1,093-unit movement/collision split still needs
a gameplay producer. No new Coq result or full Ink impossibility is claimed,
and the forty-five atlas estimates are unchanged.

## Reproduce and inspect

Use the installed Windows x64 Python 3.9.13, Wafel 0.8.5 and authenticated JP
DLL. From the SSL project:

```powershell
& './build/wafel-pilot/python/python.exe' instrumentation/concrete-ink-backward/search.py --target low-display --depth 30 --candidates 9000 --seconds 90 --beam 6 --output build/concrete-ink-backward/20261003-low-display/report.json
```

The actual generated US/JP geometry and disappeared-action code remain the
source reference; runtime tests are JP only. Source/runtime/capture hashes,
limits, accepted patch/input records and the rechecked native receipt are in
[the compact receipt](../../instrumentation/concrete-ink-backward/expected-low-display-result.json).
Full `report.json`, `diagnostics.json`, `retention-controls.json` and test logs
remain in `build/concrete-ink-backward/20261003-low-display/`. Fifteen search
tests and the fifteen original pilot tests pass. The test fixtures check
bookkeeping and target recognition, not gameplay impossibility. No Coq source
changed or formal audit was rerun; no game binary or full save state is committed.
