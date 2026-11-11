# Where a floorless upper-warp attempt goes

Placing Mario outside the collision grid changes which floor query can
succeed. It does not give the upper warp a new destination. A floorless
frame can be part of Ink when the display retry can already reach the top.

## Placement and timing

The ten tests replay the established Japanese Mode 12 prefix through the
fourth pillar and release the stick until top timer 131. At that reached
checkpoint Mario is idle and has no held object or remembered platform.
Each trial restores that checkpoint, stages the indicated position records
and runs 90 neutral updates. All trials keep A released. Only the ordinary
death comparison also turns off the level-select startup flag.

The outside point is `(9000,768,-1024)`. Its X is outside the collision
grid and within signed-16 range. The supported portal centre is
`(-2048,768,-1024)`. The positive vertical control uses low contact
`(-2200,768,-1024)` and display `(-2200,1938.8648681640625,-1024)`.

## Outcomes

| Staged order | Result |
| --- | --- |
| All three positions outside | Floor is null and death queues. With the replay's level-select flag on, the game selects the special return to Select Stage. |
| All three outside, level-select flag off | The ordinary death warp targets Castle Area 3, node `0x65`. The first castle sample is `(-2918,-870,-875)`. |
| Outside, then place all three at the portal after death queues | The upper warp accepts contact on the recovered static floor. Death remains queued and the game returns to Select Stage. |
| Supported portal, then outside after acceptance and before the object warp queues | The floorless update queues death. The disappearing action still has one tick left and the object warp has yet to queue. |
| Supported portal, then outside after the object warp queues | The queued warp stays on upper node `0x1E` and enters SSL Area 2 at `(0,5500,256)`, the usual elevator entrance. |
| Raw collision at the portal, movement and display outside | The game can register upper-warp contact and set the disappearing action. The floor stays null, death queues and the destination is Select Stage. |
| Raw collision and display at the supported portal, movement outside | The retry restores the display coordinates and finds the static floor. Mario uses the upper warp and arrives at the usual entrance. |
| Raw collision low by the portal, movement outside, display on the top | The retry selects the live top. The game retains it and arrives at `(365.5927734375,5500,-1096.8026123046875)` outside the elevator, matching the staged Ink control. |
| Staged Ink control, then all three outside after the upper warp queues | The next sample has already lost the remembered top. The queued upper warp remains and Mario arrives at the usual entrance. |

The replay distinguishes contact, the disappearing action's two supported
updates, and the delayed warp queue. With both floor queries missing, the
death request comes before the cached warp interaction. A pending warp
keeps its own destination through later requests. These ordering facts
come from the [stock routine audit](ink-fallback.md#oob-death-check-and-delayed-warp-priority);
the runtime records the cached floor and operation at update boundaries.
The earlier [flat demo control](ink-installation-demo.md) also visibly
returns to Select Stage on the original ROM.

## Original JP confirmation

The [annotated original-ROM recording](../media/ink-outside-retry.mp4)
uses the same four-pillar controller replay as the Wafel trials. The video
begins on the approach to pillar four. At 0:06 it holds a frame to show
the three edited position records. Immediately before the edit all
three are approximately `(-5883.07373,1024,819.564392)`. The edit at top
timer 131 supplies movement `(9000,768,-1024)`, raw collision
`(-2200,768,-1024)` and display `(-2200,1938.8648681640625,-1024)`.
Movement and collision X differ by 11,200 units, and display is
1170.8648681640625 units above collision.

The [recording trace](../media/ink-outside-retry-trace.txt) captures the
first floor return with a null pointer, then the retry returning a
surface owned by the top in the same update. At that point movement
equals display and collision is still low. The next poll shows the
accepted warp and the remembered top. The trace records the ordinary
Area-2 spawn and the first platform displacement before the camera
shows Mario landing on the upper walkway at Y=4429.

The existing [lifecycle fixture](../../instrumentation/jp-lifecycle/README.md)
also repeats the successful outside-movement case on the authenticated JP ROM.
This independent fixture supplies the pillar count and uses the earlier
mid-face coordinates. It stages movement `(9000,768,-1024)`, raw collision
`(-2048,768,-1024)` and display `(-1862,1778,-902)`. The game accepts the
upper warp, retains top slot 61 through its explosion, then changes the
normal Area-2 entrance position to the same displaced position in the
first real platform-apply call. The trace reports zero A input.

The outside placement supplies a reliable first miss in these examples.
Ink still needs low portal contact and a display retry that can reach the
live top in the same update. These tests supply those coordinates. Creating
them with controller input remains open. There is no new whole-route
exclusion or estimate change.

## Reproduce

From the SSL project in the pinned Windows JP Wafel runtime:

```powershell
& './build/wafel-pilot/python/python.exe' instrumentation/wafel-jp-pilot/ink_floorless_warp.py build/wafel-pilot/capture.bKv95w/inputs.jsonl build/wafel-pilot/ink-floorless-warp-replay.json
```

From the same project in Ubuntu-24.04, with an authentic original JP ROM:

```sh
LIFECYCLE_CAPTURE_FROM=880 bash instrumentation/jp-lifecycle/run.sh \
  /path/to/baserom.jp.z64 -127 -96 131 60 three-view 9000 768 -1024 -1862 1778 -902
```

The [receipt](ink-floorless-warp-receipt.json) records the significant
frames and hashes for the initial experiments. The
[video runner](../../instrumentation/jp-ink-installation-demo/README.md#outside-movement-recording)
reproduces the later annotated four-pillar recording.
