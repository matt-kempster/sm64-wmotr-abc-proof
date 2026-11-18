# Comparing the two shove roles at low Y

JP Wafel used the existing [low carried-Bob omission recipe](../ink-shell-carried-bob-mount/no-box.json). The supplied shell pickup and remote throw, the no-crate setup at 126 and the held, enlarged Bob-omb approach at 128 are inherited from that recipe. The game drops the Bob-omb on shell contact. Mario gets a ground slide by pressing Z. A is released. The experiment changes **actor positions** to isolate the shoves. These placements are distinct from the [small crate's actual pre-mount drop](../ink-low-small-box-final/README.md).

* For the first role, immediately after the mount we move the released Bob-omb 39 to (5900, 51, 3440), place the test actor before 129 and place Crazy Box 49 at the inherited final-shove position before 130. If 49 is itself tested first, it receives two position edits. The omission makes no capture and stays in Area 1 through the bounded suffix.
* For the final role, we let the held Bob-omb drop and shove on 129, then change the test actor's XYZ before 130. The original Bob-omb stays present. Testing 39 itself in this series repositions the actor that gave the first shove. Its unedited continuation reaches the ordinary spawn.
* For the order control, we give the same supplied held profile to the other real black Bob-omb, 40, at 128. The native shell drop and its first shove give the exact same Mario XYZ. We then vary ordinary Bob-omb 39's XYZ before 130. Both black Bob-ombs enter the collision list in order 39,40. The game processes just the first GRABBABLE. The omitted-final-position branch reaches the ordinary spawn.

| Actor tested | Useful / first-shove placements | Useful / final-shove placements after Bob-omb 39 |
|---|---:|---:|
| Pink Bob-omb Buddy 15 | 3/61 | 5/62 |
| Small breakable box 23 | 0/6 | 3/35 |
| Ordinary Bob-omb 40 | 0/6 | 0/50 |
| Crazy Box 49 | 0/15 | 7/61 |
| Already-mounted and dismounted frozen shell 71 | 0/6 | 0/27 |
| Enlarged Bob-omb 39 itself, moved again after 129 | — | 7/62 |

With **enlarged 40 first and ordinary 39 last**, 7/50 final placements reached the displaced spawn. The selected ordinary Bob-omb position is (−2113.16455078125, 1839.447265625, −1114.7020263671875). On original JP, the shove helper actually moved Mario with 40 on 129 and with 39 on 130. The last Mario state edit was on 128 and the last actor XYZ edit was on 130. [Native replay receipt](../jp-ink-low-small-box-final/swapped-bobs-receipt.json)

For a first-role Buddy example, place it at (−2081.490966796875, 1809.2066650390625, −1224.776611328125) on 129. For a final-role Buddy example, put it at (−2086.498046875, 1839.447265625, −1123.991455078125) on 130 after the enlarged 39 shove. These examples keep the original shell and native collision ordering. Neither delivers Buddy. The already-used shell remains at its observed status, including STOP_RIDING. These shell misses apply to this menu, alongside a working nonmounting-shell shove in a different setup.

The menu in [compare.py](compare.py) generates discrete coordinates from each actor’s initialized radius and its interaction padding. It also includes collision-centred placements. Every trial executes native updates through 131. Every capture and omission continues to Area 2 or the 40-update bound. Success requires warp 64, top-owned floor and platform 61 on 131, uninterrupted observed retention in Area 1, and exact first Area 2 movement (365.5927734375, 5500, −1096.8026123046875). The counts are descriptive. They do not bound untested placements or allow conclusions about acquiring an actor.

Run from the SSL project directory on Windows, sequentially with other Wafel shell-root experiments.

```powershell
& build/wafel-pilot/python/python.exe instrumentation/ink-low-shove-roles/compare.py --verify
```

The file [comparison.json.gz](comparison.json.gz) preserves each coordinate, collision lists, action, M/C/G, floor, platform, 131 result and the selected continuations. [swapped-bobs.json](swapped-bobs.json) contains the full native replay recipe, inputs and seed-relative edits. JP Wafel 0.8.5, Python 3.9.13 and the existing project DLL were used. The independent verification rebuilds the root and checks both files. The [small-crate study](../../docs/notes/ink-low-small-box-final.md) records the exact revisions.
