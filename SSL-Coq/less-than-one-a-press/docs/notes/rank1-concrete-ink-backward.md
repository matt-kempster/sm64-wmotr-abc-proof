# Working backward from the actual Ink checkpoint

2 October 2026. The new concrete experiment starts at the supplied Ink
installation, rather than the earlier freefall pilot. Its bounded search
took **51.0 seconds**, testing **7,812 proposals**. It kept six last-update
predecessors, but none of the tested moves reproduced any of those states one
update earlier. The finite tree therefore emptied at depth two. The requested
horizon was thirty updates; **no thirty-update predecessor chain was found or
validated**. This is a price for the chosen pruned tree, not exhaustive
one-second coverage, a new gap producer or an impossibility proof.

## First, check that we really started at Ink

The target occurs inside the update: the successful nonfading upper-warp
interaction returns while Mario is still in Area 1, before the disappeared
action executes. The separate emulator observer reads movement, collision
and display there. Wafel's action-entry record checks movement immediately
afterward; it cannot alone read the earlier collision/display records. All three
named emulator controls also check the actual first retained-top platform
apply in Area 2. End-of-update equality is not used as a substitute for the
inside-update checkpoint.

| Supplied movement Y | Collision Y | Display Y | Movement Y at acceptance | First Area-2 apply |
| ---: | ---: | ---: | ---: | --- |
| 768 | 768 | 1938.8648681640625 | 1938.8648681640625 | Retained top moves Mario to `(365.5927734375,5500,-1096.8026123046875)` |
| 1861 | 768 | 1938.8648681640625 | 1861 | Same retained-top displacement |
| 1861 | 768 | 768 | 1861 | Same retained-top displacement, with no raised display |

X=-2200 and Z=-1024 in all three supplied records. The second case is useful:
the first floor query already succeeds, so retry is unnecessary. The following
disappeared action aligns Mario with the top; the later copy makes the final
raw query high enough to retain it. We initially filtered that case out for
having a different movement height at acceptance, then corrected the filter
and repeated the run. It remains a supplied-state installation, not a route
to the disagreement. Lookup success alone is still not a proof of capture.

The third control supplies movement Y=1861 while both collision and display
remain at Y=768, with quicksand depth zero. It also installs: the first query
finds the top, the disappeared action aligns Mario, and the subsequent copy,
capture and retention produce the same Area-2 displacement. Thus this supplied
variant needs no raised display or negative seed. It still needs an unexplained
1,093-unit movement/collision split. Creation of that split by gameplay remains
open; checking an installer does not check its producer.

## What was tried backward

The final-update inverse starts from the accepted collision/display
relationship and proposes movement heights 768, 767, 769, 1201, 1202 and 1861.
It also proposes Y=1861 with display equal to the low collision position,
giving seven pose proposals across six movement heights.
It does not copy earlier height values from a recorded predecessor. There are
36 input representatives: neutral, B, Z and B+Z at nine stick directions. Of
252 trials, 216 match the selected installation and initial capture fields
and group into six pose cases; Y=1202 supplies no top capture. All six are
retained, including both successful Y=1861 display variants. Outside the timed search,
each retained neutral branch also replays through Area 2 from its single
initial patch and reproduces the same displacement. The other input variants
are not thereby proved equivalent in omitted state.

Each earlier move uses one of three explicit proposals: ordinary ground
copy plus sinking, ordinary freefall quarter-steps plus copy/sinking, or the
final automatic-dialog update. It varies the declared position records,
vertical speed, action fields and selected depth values. Some negative depth
is granted diagnostically; no no-A producer of it is claimed. Other full-state
values come from the corresponding unmounted neutral scene after supplied
pillar completion. The game executes every update normally. No callee is
replaced by an assumed harmless effect.

An extended trial restores its earliest context and patches only there. It
compares the next parent, then runs toward installation without an intermediate
restore or patch. All 7,560 earlier proposals fail the parent comparison, so
none reaches a valid two-edge continuous chain. Equality covers the declared
fields, not all memory or every relevant history. Moving support, late writers,
other action histories, unsampled values and different full contexts are not
covered by this menu.

## Why the sampled predecessors failed

The low ordinary-copy proposal with display Y=768 ends with that low display
and the disappeared action, instead of the required high-display idle parent.
Supplying the high display instead ends with all three heights at
1899.650390625 and the disappeared action one update too early. The selected
freefall proposal with speed -16 ends at Y=784. The final-dialog proposal with
depth -1170.864868 and display Y=768 remains in dialog with the negative seed;
it does not raise the display. In that branch, the failed floor checks stop the
action loop before the final sinking call. Negative depth alone cannot make
that particular floorless update generate the high display.

These are recorded counterchecks to the proposed inverse moves. They do not
prove that every use of ground movement, freefall or dialog is insufficient.
Thirty-five additional neutral diagnostic replays preserve the rejection
details separately from the timed search. Six separate neutral retention
controls check the kept installation branches through Area 2.

## What the price means

| Measurement | Checked value |
| --- | ---: |
| Requested horizon | 30 updates / nominally 1 second |
| Deepest validated predecessor | 1 update |
| Candidate checks | 7,812 |
| Backward-search wall time | 50.9505891 seconds |
| Total run, including preparation and controls | 52.0510664 seconds |
| Median trial | 5.97185 milliseconds |
| Candidate/time/beam limits | 9,000 / 90 seconds / 6 parents |

No limit was hit, and no distinct first-layer pose was discarded. This finite
tree ended because no proposed earlier move matched. That makes these concrete
checks tractable. It does not determine the price of three or five seconds of
broader inverse search: future branches may survive, require longer continuous
replays, or need new scene conditions. Multiplying this total by three or five
would give an unsupported estimate. All 45 atlas estimates stay unchanged.

The earlier raised-display-only menu tested 6,516 proposals in 41.1 seconds.
The expanded run includes the normal-display installation rather than imposing
a raised-display requirement on all successful parents.

## Runtime, sources and saved evidence

The Wafel run uses the installed Windows x64 Python 3.9.13, Wafel 0.8.5 and
authenticated JP DLL, SHA256
`960fe979068b78e6733b3ddb87741833fbf4eb29b2a21a2bba871977427c2d0f`.
The normally initialized level-select prefix and neutral scene are reused;
four pillar touches are supplied for this mechanics experiment. The source
review uses the actual `generated/{us,jp}_mario.v`,
`{us,jp}_mario_actions_cutscene.v` and `{us,jp}_object_list_processor.v`,
alongside pinned C. Their hashes are recorded, not a hand-authored Clight
replacement. No Coq files changed or proof audit was rerun.

The exact observer uses the existing Ubuntu-24.04 Mupen64Plus 2.5.9 pure
interpreter, authenticated original JP ROM and checked interaction/copy
instruction ranges. At retail timer 492, all three controls show the expected
three records and action argument `0x00040002`. At timer 515, the first Area-2
apply has the original retired top as platform and performs the displacement.
Wafel's observed global timer is one higher, as in the prior replay pilot.
There is no A input in these diagnostic continuations.

Commands are in
[the prototype README](../../instrumentation/concrete-ink-backward/README.md).
Twelve new tests and the original fifteen pilot tests pass. The compact
[result receipt](../../instrumentation/concrete-ink-backward/expected-result.json)
contains the limits, comparisons, timings, source/runtime hashes and emulator
control results. Full evidence remains under
`build/concrete-ink-backward/20261002-expanded/` (`report.json`, `diagnostics.json`,
`retention-controls.json` and test logs), `emulator-y768.9R0ESh/`, `emulator-y1861.NYCSpS/`
and `emulator-y1861-low.RjJrb5/`
(`raw.log`, `receipt.txt`, `report.json`). The initial stricter-filter report
is preserved under `20261002-initial/`, and the intermediate raised-display-only
run under `20261002-final/`. No full state or game binary is committed.

The verdict is a checked finite experiment with supplied contexts. Clean
creation of the gap, exhaustive predecessor coverage, no-A reachability and
whole-route closure remain open. No entry is promoted to Already proved.
