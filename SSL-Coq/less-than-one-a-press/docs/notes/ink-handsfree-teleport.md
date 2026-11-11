# Hands-free teleport, recoverable Bob-ombs, and backward pushing

The hands-free teleport fallback has a real advantage over a jumping box:
after the same-area teleport clears Mario's held-object pointer, a Bob-omb can
remain tangible, be collected again, and be released again. The selected JP
replay reproduces that mechanism. It also reproduces a bloated Bob-omb's
repeated backward push. These are **conditional local experiments**, not a
clean journey to a teleporter or the high timer-130 Ink handoff. The clean part
of this study is acquisition of the original Bob-omb and the hands-free state
before the teleporter setup.

This investigates the mechanism illustrated in pannenkoek2012's
[SM64 Hands Free Teleport Glitch](https://www.youtube.com/watch?v=qqmYYIQRSuI).
The results below come from the pinned JP runtime and inspected source, not
from treating the video's description as a proof.

## What the source actually does

The inspected decompilation is `n64decomp/sm64` commit
`36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`.

* [The fading-warp interaction](https://github.com/n64decomp/sm64/blob/36fbf8d693a9fc2bdec0c77402f8e96d07d2f461/src/game/interaction.c#L855)
  accepts idle, panting, standing against a wall, or crouching, subject to the
  just-teleported latch. It does not accept an ordinary holding action, crawl,
  or slide. It does not first drop the object. Thus the end-of-update state
  with an ordinary idle action and a nonnull held pointer can be intercepted
  before idle's next execution drops it.
* [Same-area warp initialization](https://github.com/n64decomp/sm64/blob/36fbf8d693a9fc2bdec0c77402f8e96d07d2f461/src/game/level_update.c#L391)
  skips the area reload but still calls `init_mario`; that function
  [clears `heldObj`](https://github.com/n64decomp/sm64/blob/36fbf8d693a9fc2bdec0c77402f8e96d07d2f461/src/game/mario.c#L1817).
  The actor's `oHeldState` is a separate field. Pointer retention during
  fade-out is not pointer retention after the teleport.
* [The Bob-omb held callback](https://github.com/n64decomp/sm64/blob/36fbf8d693a9fc2bdec0c77402f8e96d07d2f461/src/game/behaviors/bobomb.inc.c#L182)
  hides its model and places it 60 units above and 100 units ahead of Mario's
  object. It does **not** make it intangible. The entire held/free callback
  and fuse increment are inside the
  [4,000-unit distance gate](https://github.com/n64decomp/sm64/blob/36fbf8d693a9fc2bdec0c77402f8e96d07d2f461/src/game/behaviors/bobomb.inc.c#L238).
  SSL's east and west teleports are roughly 12,873 units apart, so a Bob-omb
  left near the source can remain remote with a frozen fuse until Mario
  returns within range. This is an actor-specific behavior gate, not a claim
  that every object is transported or frozen by teleporting.
* Fuse expiry while `HELD_HELD` sets the pending explosion action and Mario's
  drop-interaction flag, but the explosion function is not executed until the
  held state changes. The source comment explicitly notes indefinite regrabs.
  A fixed 151-update upper bound on all Bob-omb transport would be false.
  [Dropped](https://github.com/n64decomp/sm64/blob/36fbf8d693a9fc2bdec0c77402f8e96d07d2f461/src/game/behaviors/bobomb.inc.c#L196)
  and thrown callbacks restore `HELD_FREE`; an expired free actor can then
  execute its short explosion sequence.
* [Collision-list eligibility](https://github.com/n64decomp/sm64/blob/36fbf8d693a9fc2bdec0c77402f8e96d07d2f461/src/game/object_collision.c#L113)
  tests intangibility, not `HELD_FREE`. The
  [grabbable interaction](https://github.com/n64decomp/sm64/blob/36fbf8d693a9fc2bdec0c77402f8e96d07d2f461/src/game/interaction.c#L1636)
  likewise has no `HELD_FREE` guard: it can grab or push the orphan. Kick and
  trip interaction handling precedes grabbing for a kickable Bob-omb, so a
  different attack is not interchangeable with the successful B sequence.
* The jumping-box held branch instead
  [sets intangibility through its unrender helper](https://github.com/n64decomp/sm64/blob/36fbf8d693a9fc2bdec0c77402f8e96d07d2f461/src/game/behaviors/jumping_box.inc.c#L58).
  In the selected control it follows Mario to the destination invisibly but
  remains intangible and is not regrabbed. This study does not generalize
  that result to every non-Bob-omb behavior.

The other stock SSL grabbable considered from source is the small breakable
box, initially near `(5900, 51, 3440)` in the inspected runtime inventory.
Its [held branch](https://github.com/n64decomp/sm64/blob/36fbf8d693a9fc2bdec0c77402f8e96d07d2f461/src/game/behaviors/breakable_box_small.inc.c#L123)
disables rendering and makes it intangible without the jumping box's
position-copy callback. Its normal dropped/thrown branches restore
tangibility and begin a 900-update released-lifetime counter, but the null
Mario held pointer after teleport does not itself invoke either branch.
Consequently its held orphan is a poor candidate for the Bob-omb's ordinary
recollection mechanism. This is source analysis, not an additional replay or
an all-history impossibility result.

The earlier [teleporter wrong-warp analysis](teleporter-wrong-warp.md) remains
applicable: same-area survival is distinct from an area change's unload, and
an orphan actor-held flag is distinct from a usable Mario held pointer.

## Selected checked replay

The [script](../../instrumentation/wafel-jp-pilot/ink_handsfree_teleport.py) and
[receipt](ink-handsfree-teleport-receipt.json) record controls, relevant state
projections, original actor identity, and every non-controller setup write.
“Update” below counts one call to the pinned Wafel `advance`, including
transition updates. The action names describe recorded post-update states
unless an executed-action entry is explicitly mentioned.

1. **Clean acquisition component.** Starting from the accepted pre-entry
   level-select setup and the first 350 accepted controls, 197 further no-A
   controls acquire the original Bob-omb in slot 39. Pickup is after branch
   update 109, hands-free sliding after 115, and idle with the held pointer
   after 197. The final Mario position is approximately
   `(3895.1531, 0, 6085.1802)`, with fuse 89. This component has no gameplay
   memory edits. It does not establish a clean arrival at either teleporter.
2. **First local setup.** Translate Mario's movement, collision and display
   positions to the stock east teleporter `(6930, 0, -4871)`, and translate
   the actor's XYZ by the same vector. Those are twelve scalar coordinate
   writes. Action, held pointer, actor held state, fuse, scale, floor/cache,
   velocity, and controller history are inherited. Supplying only Mario's
   position would leave the Bob-omb out of range already before teleporting;
   the actor translation removes that ambiguity.
3. **Native teleport and return.** With neutral input, fade-out starts after
   local update 1. Update 43 reaches fade-in at the west teleporter with
   Mario's pointer null; fade-in ends after 75. The original actor remains
   at approximately `(6992.3662, 60, -4792.8306)`, `HELD_HELD`, intangible 0,
   fuse 129. Controller-only departure, stop, return, and stop trigger the
   reverse teleport. It reaches the east side after return-suffix update
   123, finishes fade-in at 155 with fuse 162, and the helper's additional
   neutral update 156 leaves fuse 163. The actor is again following Mario,
   although Mario's held pointer is still null. No second setup cut is used
   for this return.
4. **Actual regrab and release.** From that returned state, B on update 1
   followed by neutral input restores the original slot-39 held pointer on
   update 6. The expired-fuse flag causes the ordinary holding action to
   release it on update 18; actor `HELD_FREE` is observed. It is not merely
   a flag-cleared invisible copy. The actor is deactivated on update 25.
5. **Release followed by crouch/crawl input.** Holding Z after the first B,
   then applying analog only once crouching/crawl startup permits it, gives
   starting-crouch on update 18, crouching on 23, and starting-crawl on 24.
   The Bob-omb is deactivated on 25, before an established crawling state;
   the explosion knocks Mario back on 26. This is a bounded obstruction for
   this expired release and these controls. It does not exclude earlier
   releases, another fuse history, or every possible crawl producer.
6. **Native bloat capture.** A second B on update 18, 19, or 20 regrabs the
   expanding original actor at scale 1.4, 1.6, or 1.8 respectively. The
   seven tested second-press times were 17 through 23. The largest captured
   actor has binary32 scale `1.7999999523162842` and radius 117. Ordinary
   `ACT_PICKING_UP` is not the hands-free action; this alone does not supply
   a bloated hands-free teleport history.

## The stronger bloated-orphan diagnostic

To isolate backward pushing, the script starts from the first native
teleport/return state, departs north to `(6930, -5171)` in X/Z and stops. This
clears the teleport latch. B on updates 1 and 20 then produces the native
scale-1.8 held Bob-omb after 25 updates. The second explicit setup translates
Mario's three positions and actor XYZ back to the east teleporter and supplies
`ACT_IDLE`: **twelve coordinate writes plus one action write**. This action
hypothesis is material. The script does not claim that ordinary inputs
produced this bloated idle-with-pointer state. Other action fields are left
as recorded in the receipt; scale, fuse and both held-state fields are not
written.

The actual warp interaction then intercepts before idle drops the actor. A
native teleport and controller-only round trip leave a bloated tangible
orphan: Mario's held pointer is null, actor `HELD_HELD` persists, and the actor
has radius 117. Four further neutral updates each move Mario backward by
approximately `49.000090779` horizontal units while his velocity vector and
`forwardVel` remain zero. Thus “backward momentum” here is a repeated object
push, not stored negative forward velocity. The source's target separation
is `117 + 37 - 5 = 149`; the held callback puts the actor 100 units ahead,
so a 49-unit correction is the expected real-arithmetic value. The observed
small difference is binary32 arithmetic. Neither this calculation nor the
replay is a Coq theorem about arbitrary histories.

The tangible actor can therefore be a push candidate **without first becoming
free**. Connecting either that candidate or an actual regrab/release to a
high established crawl, a useful fresh floor cache, and timer-130/131 warp
timing remains a separate obligation. The four-update push test is not a
proof of indefinite safe travel, climbing, or a completed no-A route.

## Reproduction and checks

Use the existing pinned Wafel installation described in the
[pilot README](../../instrumentation/wafel-jp-pilot/README.md). From the SSL
project directory, this command uses only a committed controller file:

```powershell
& './build/wafel-pilot/python/python.exe' instrumentation/wafel-jp-pilot/ink_handsfree_teleport.py --study instrumentation/jp-ink-handsfree-demo/clean-component-inputs.jsonl instrumentation/jp-ink-handsfree-demo/clean-component-inputs.jsonl build/wafel-pilot/ink-handsfree-teleport-reproduced.json
```

The output filename must be new. The selected normal teleport/return/regrab,
release-to-crawl control, and bloated teleport/return/push are reconstructed
in fresh game instances and compared field for field. The script asserts no
A input, the actual regrab/free/deactivation milestones, and the selected
49-unit pushes. The logged projection includes action/state/argument/timer,
M/C/D positions, velocity, held/used slot, floor and platform owner, hitbox,
and actor behavior/owner/activity/held/intangibility/fuse/scale. Equality of
these fields is not equality of all game memory or an original-ROM replay.

The original accepted capture command was also run, with first argument
`build/wafel-pilot/capture.bKv95w/inputs.jsonl`. Its final raw output is
`build/wafel-pilot/ink-handsfree-teleport-final-v3-20261112.json`. A second full
run using the committed input file produced exactly the same result except
the input-file SHA field. Both selected studies passed, including their
internal fresh reconstructions. The receipt pins their hashes and the
script SHA `1e0a9322e2a469108a731fcc4930d537b0ce54086f48522bc68dcbfb57305af2`.

The receipt also records a **post-run current helper inventory** for
`replay.py`, `ink_box_delivery.py`, and `ink_crawl_predecessors.py`.
Those hashes were added during review after the successful reproductions;
the original raw run did not record them. They identify the currently
audited helper files and must not be represented as an at-run fingerprint
of every transitive dependency. The reproducibility claim is the recorded
fresh-instance and committed-input comparison with the current code.

No Coq files were changed for this study. The existing proof checks do not
certify these emulator observations, nor does this study change the theorem
boundary to include a clean HFT or high Ink producer.
