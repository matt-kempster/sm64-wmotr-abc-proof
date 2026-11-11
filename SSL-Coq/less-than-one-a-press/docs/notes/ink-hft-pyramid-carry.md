# Conditional orphan transport to the pyramid entrance roof

After a supplied approach to a teleporter, native no-A controls can carry an
orphaned Bob-omb through a tornado lift, land on the pyramid entrance roof at
Y=256, and start crawling there with the same live, tangible actor nearby.
This is a useful conditional transport component. It does not produce the
initial hands-free teleport, the high Y=1741 crawling state, three or four
touched pillars, or the timer-130 Ink handoff.

An **orphan** here means that Mario's held-object pointer is null while the
actor's own held state remains `HELD_HELD`. This differs from the earlier
hands-free state in which Mario still has a held-object pointer. The native
teleport/return helpers and their setup ledgers are in
[ink_handsfree_teleport.py](../../instrumentation/wafel-jp-pilot/ink_handsfree_teleport.py).
The new [carry script](../../instrumentation/wafel-jp-pilot/ink_hft_pyramid_carry.py)
and [receipt](ink-hft-pyramid-carry-receipt.json) preserve that distinction.

## Material setup assumptions

The normal families first replay the accepted 350 inputs and the existing
197-input controller-produced Bob-omb pickup/idle suffix. They then supply
one translation of Mario's movement, collision and display positions and
Bob-omb 39's XYZ to the eastern or western stock teleporter. This is eight
write records, including vector writes; the actor's relative position is
preserved. Actions, held states/pointers, fuse, scale and RNG are inherited.
The native teleport clears Mario's pointer, and native departure/return
controls reactivate the orphan at the source side. For a western source,
departure at the eastern destination goes north to `(6930,-5171)`; the
earlier eastward departure entered quicksand instead of completing a return.

The bloated eastern family is a stronger diagnostic. After the first
teleport/return, native B inputs produce scale 1.8. A second setup translates
Mario and the actor back to the eastern pad **and supplies `ACT_IDLE`** to
make that second teleport eligible. This second cut is explicitly recorded;
it does not prove native acquisition of a bloated hands-free state. Scale,
fuse and held references are not patched. All return, carry, waiting and
roof-crawl controls after these setup cuts are native, with no further
gameplay writes and no A input.

## Checked native components

The successful normal-west route walks around the southern side. Its full
waypoint list and controls are in route 0 of the receipt. Relative to the
post-return start at global 778:

| Carry update | Observed event |
| ---: | --- |
| 311 | `ACT_TORNADO_TWIRLING`, with the nearby Bob-omb still orphaned. |
| 360 | The tornado releases Mario into `ACT_TWIRLING`. |
| 372 | Peak sampled Mario Y=`1597.811279296875`, at X/Z=`(-3624.3206,3473.7512)`. |
| 487 | `ACT_TWIRL_LAND` on the entrance roof at `(-2182.9797,256,801.2762)`. |
| 487+25 | In the separate Z continuation, actual `ACT_CRAWLING` at Y=256, global 1290. |

At both the peak and the selected crawl sample, slot 39 has its original
Bob-omb behavior, nonzero active flags, area 1 ownership, `HELD_HELD`, and
`oIntangibleTimer=0`; Mario's held pointer is null. The actor is about 100
units away horizontally and 60 units above Mario. The verifier checks the
full conjunction and bounds each offset by 200. This proximity check is not
itself a theorem about an interaction or push.

The height peak is far south of the spinning top. It is not the sample
closest to the pyramid: the original walking continuation comes within
1114.1015 X/Z units of its center only at carry update 528, when Mario Y=0.
It then enters `ACT_DISAPPEARED` with used object 65 at the ordinary lower
entrance before the valid Area 1 Mario context ends. Neither statistic
demonstrates a high upper-warp contact.

The roof-crawl follow-up instead stops the original trail immediately after
update 487. It holds Z with no stick until crouching, then uses a small stick
in one of four cardinal directions. All four variants reach crawling at
Y=256 and still have a live, tangible nearby orphan at the end of 90 updates.
The neutral-stick control remains crouched. These suffixes add no setup cut.
There is no Y=768 remembered-floor claim: the selected crawl sample's cached
floor and Mario Y are both 256, its floor owner/platform are null, and the top
has zero touched pillars and action 0.

The tornado result has a source explanation. The interaction calls
`mario_stop_riding_and_holding` (`src/game/interaction.c:1086–1109` in the
sibling decomp), but that routine only drops an object reached through
Mario's held pointer (`interaction.c:295–338`). It therefore does not clear
this orphan merely by calling the routine. The automatic tornado handler
raises Mario and transitions to twirling when he passes the tornado's
height (`mario_actions_automatic.c:764–801`). Ordinary hands-free holding
with a nonnull Mario pointer must not be conflated with this orphan case.
The observed Bob-omb fuse continues increasing; this study does not claim
the fuse is frozen.

## Finite scope and remaining gap

| Screen | Policies | Native suffix updates | Bound/result |
| --- | ---: | ---: | --- |
| Carry routes | 32 | 19,031 | Four routes per side; normal walk/crawl and four bloated movement policies; horizon 2400. |
| Tornado timing/direct-roof follow-up | 18 | 8,100 | Six native delays × three steering targets; horizon 450. |
| Entrance-roof settle/crawl | 5 | 450 | Neutral control plus four directions; horizon 90. |

These are 55 policy executions and 27,581 suffix updates, excluding setup and
fresh-replay work. Earlier pilots are superseded and are not added to these
counts. The 32-route screen's maximum crawl height is 121.8125; the separate
roof follow-up supplies the stronger Y=256 crawl. The 18 direct-roof variants
never enter crawling. Their highest sample with
`abs(M.y-floorHeight)<0.01` is 417.99997; this scalar equality is not by itself
a landing or ground-action certificate. The normal and bloated eastern
route families did not escape to a high position; their last valid samples
are in quicksand before the Area 1 Mario context ends. Reverse-facing
movement tests the bloated orphan's push without supplying another pose.

Every recorded carry/follow-up sample has zero touched pillars and top
action 0. Object timers in action 0 are not spinning phases. The study does
not connect this conditional roof crawl to the high crawl, low floor cache,
live push position and timing needed at phase 130. It also does not exclude
better routes, waits or inputs outside these finite menus.

## Reproduction and checks

From `SSL-Coq/less-than-one-a-press`, the final native run was:

```powershell
./build/wafel-pilot/python/python.exe instrumentation/wafel-jp-pilot/ink_hft_pyramid_carry.py build/wafel-pilot/capture.bKv95w/inputs.jsonl build/wafel-pilot/ink-hft-pyramid-carry-final-v2-20261112.json --receipt build/wafel-pilot/ink-hft-pyramid-carry-final-v2-20261112-receipt.json
```

It exited 0. The compact receipt was copied to the notes path. Ten selected
fresh replays recreate and compare the complete conditional helper setup,
return and selected suffix projections; their recorded matched-snapshot
counts total 4,700. Equality is of the recorded projections, not a claim of
whole-memory equality or validation against the original ROM.

```powershell
./build/wafel-pilot/python/python.exe -m py_compile instrumentation/wafel-jp-pilot/ink_hft_pyramid_carry.py instrumentation/wafel-jp-pilot/verify_ink_hft_pyramid_carry.py
./build/wafel-pilot/python/python.exe instrumentation/wafel-jp-pilot/verify_ink_hft_pyramid_carry.py
```

Both checks exit 0. The read-only verifier checks hashes, the exact compact
projection, the setup ledgers, counts, no-A controls/native input samples,
stored replay assertions, and the selected tangible-orphan conjunctions.
It does not run gameplay. Source/runtime/helper hashes and complete control
lists are retained in the receipt; the full raw report is ignored build
output. No Coq file or theorem was added by this native conditional study.
