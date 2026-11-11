# Hands-free holding can reach crawl, but the useful joint state remains open

**A continuous no-A controller history now acquires the eastern jumping
box, takes the hands-free slide exit, stops, releases the box and enters
crawl.** It does so on the starting platform at Y=38, with no pillars
activated. The box is deleted one update after release; Mario enters crawl
13 updates after release. This clean action sequence therefore does not
supply a surviving push actor or the high timer-130 handoff.

The separate roof continuations retain the earlier study's explicit
Mario/box position cut. They fail to stop on the roof or enter crawl in
the tested feedback policies and narrow beam. These failures are bounded
observations, not an exclusion of other controls, phases, histories or
initial positions.

This study starts from `48a289c18409d17edc694c00fdb4b7864fcc94c7`. It
uses the pinned native JP Wafel runtime and introduces no Coq theorem.
See the [clean acquisition study](ink-clean-handsfree.md) and the
[supplied-position hands-free study](ink-box-handsfree.md) for the two
different starting boundaries. No action, velocity, held reference, cache,
timer, RNG or allocator field is patched in these continuations.

## Clean pickup, release and crawl

Replay the accepted first 350 inputs, followed by the clean acquisition
witness's first 86 inputs. After 436 completed inputs, Wafel global timer
437, Mario has actually acquired eastern box 47 and changed through
`ACT_DIVE_PICKING_UP` into hands-free `ACT_STOMACH_SLIDE`, at
`(1121.5709,35.3070,5994.3999)`.

The selected continuation holds Z. During sliding it aims the full stick
opposite Mario's current horizontal velocity. During the stop animation,
idle and crouch-start states it supplies neutral stick. Once crouching,
it uses magnitude 32 toward `(1120,6500)`. There are no B or A inputs in
this selected suffix and no gameplay setup writes.

| Completed inputs | Wafel global timer | Observation |
| --- | --- | --- |
| 436 | 437 | Hands-free stomach slide, box 47 held |
| 514 | 515 | Idle at Y=38, held pointer still 47 before the next idle dispatch |
| 515 | 516 | Mario begins crouching and drops the box at Y=38 |
| 516 | 517 | Box 47 becomes inactive |
| 520 | 521 | Crouching |
| 521 | 522 | Start-crawling animation |
| 528 | 529 | `ACT_CRAWLING`, Mario `(892.5358,38,6331.1060)`, box inactive |

The complete selected input sequence has 656 inputs: the accepted 350,
86 acquisition inputs and 220 continuation inputs. A fresh native
instance reproduced all 221 continuation snapshots, including the initial
boundary. The parent demo study separately reproduces this sequence on
the original JP ROM; its input-count convention should not be confused
with Wafel's between-update global timer.

The drop is concrete. At Wafel timer 516 Mario is
`(943.5033,38,6295.5151)`. His recorded HOLP is
`(980.2059,100.4452,6269.7632)`, while the released box is
`(980.2059,38,6269.7632)`. The drop uses HOLP X/Z and Mario's Y, not HOLP Y.
Its floor cache is 38, held state is free, action is 1, tangibility is 0,
and active flags are 257. At timer 517 it is inactive. The receipt retains
the before/after drop snapshots, including HOLP and the actor's floor and
movement fields.

Source explains this observed lifetime: `act_idle` drops an existing
held object before normal input handling
(`src/game/mario_actions_stationary.c:21` in the sibling decompilation),
and `mario_drop_held_object` places the actor using HOLP X/Z and Mario Y
(`src/game/interaction.c:295–313`). The jumping box's dropped callback
selects action 1; that action deletes on landing, wall or water flags
(`src/game/behaviors/jumping_box.inc.c:31–36,68–71`). These source paths
explain this trace, not a universal one-update lifetime bound.

## Other clean stopping and release controls

Forty policies start from the same actual hands-free state. The menu
uses six world targets with stick magnitudes 32,64,127, each with or
without B every twelfth update, plus neutral and opposite-velocity braking
with the same B choices. Z is held, with the action-dependent stop/crawl
handling described in the script. Each policy runs 220 updates:
**8,800 updates, 22 policies entering crawl, highest crawling Y=38.**

No sampled crawler has this box simultaneously free, tangible and alive.
The longest observed release-to-deletion interval is four updates. That
policy steers magnitude 32 toward `(1120,6500)` with periodic B. It drops
the box at Wafel timer 462 at
`(1019.1971,28.0005,6093.3267)` over a floor at Y=0; the box is inactive
at timer 466. That continuation does not enter crawl. These lifetimes and
outcomes describe this finite menu, not all possible HOLP placements or
release histories.

All these clean continuations still have zero pillars credited. No top
spin phase 130 is reached. They show a genuine pickup-to-crawl connection
at low height and also expose the actor-lifetime mismatch in the tested
route. They do not provide an upper-warp installation.

## Continuing the eighteen supplied roof pickups

The earlier local study creates DIVE with ordinary inputs, then makes one
position cut at stored timer 6. Its eighteen configurations have Mario
heights 1400/1600/1741, box distances 70/110/150 and box Y offsets 0/−60.
All other fields remain native. Their actual hands-free exits occur at
stored timers 17,24,25, at Y=1336.0002,1427,1391.0002 respectively.

For each endpoint this study tries 22 feedback policies for 130 updates:
six roof/warp-region targets at magnitudes 32,64,127, and neutral or
opposite-velocity braking with or without periodic B. The target policies
hold Z without B. These are **396 policies and 51,480 updates**. None
enters crawl. The tested paths continue through butt slide, airborne butt
slide and quicksand death. These endpoints are already below 1741; the
supplied initial Y1741 is not preserved through the pickup and slide exit.

A further beam starts from the first endpoint at each initial height.
It uses eight full-stick world directions plus neutral, always holding Z,
width at most 12 and horizon at most 110. It rejects states below Y=1150,
more than 1100 X/Z units from the pyramid center, or outside the valid
area/camera context. Ranking prefers crawl, then height with speed and
distance-from-the-north-roof penalties; coarse position/yaw/speed cells
provide diversity. The three beams test **1,143 one-update continuations**.
No candidate enters crawl. All three beams lose their retained candidates
under these cutoffs at depths 13 or 14, so they stop early. Their last retained
12/13/13-input trails independently replay all 13/14/14 snapshots.

The cutoff is a search restriction, not a proof that going lower can never
lead back upward. Other initial phases, changed dive headings, different
pickup approaches, paths discarded by width/ranking and other actor
interactions remain outside this beam.

The relevant source bottleneck is specific. Butt slide's ordinary body
does not test B or Z; `update_sliding` stops only when the floor is not a
slope and squared forward speed is below 16
(`mario_actions_moving.c:218–281,1413–1437`). Reaching that stop condition,
rather than merely pressing Z, is needed for the ordinary action chain.
The roof failures here do not prove that every possible hands-free route
must fail to reach a suitable flat floor.

## Reproduction and remaining obligation

From `SSL-Coq/less-than-one-a-press`, the final run exited 0:

```powershell
& ./build/wafel-pilot/python/python.exe instrumentation/wafel-jp-pilot/ink_handsfree_continuations.py build/wafel-pilot/capture.bKv95w/inputs.jsonl build/wafel-pilot/ink-box-handsfree-20261112-checked.json build/wafel-pilot/ink-clean-handsfree-20261112-final.json build/wafel-pilot/ink-handsfree-continuations-20261112-final.json --receipt docs/notes/ink-handsfree-continuations-final-receipt.json
```

The final receipt was renamed to
[`ink-handsfree-continuations-receipt.json`](ink-handsfree-continuations-receipt.json).
Use fresh output names on reproduction. It records both source-report
hashes, the current script/helper hashes, the explicit starting cuts,
all policy outcomes, selected complete input trails and key snapshots.
The ignored raw report contains all selected snapshots. Fresh replay
comparisons cover 483 continuation snapshots across five selected trails,
not every hidden byte of native state. A read-only projection/hash/count
check also passes without running gameplay again.

The gameplay gap is now narrower: ordinary inputs can connect an actual
hands-free pickup to release and crawl. What remains unproduced is that
sequence at useful high coordinates and the required spinning-top phase,
with a free actor surviving long enough and placed to push Mario while
the current update has the needed low-floor cache. Neither the low clean
sequence nor the supplied roof failures establish the desired joint state
or an all-history impossibility result.
