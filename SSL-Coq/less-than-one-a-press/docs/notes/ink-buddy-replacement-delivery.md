# Real small-box transport: useful component, still short of Ink

14 November 2026. **The stock small box can genuinely be picked up, carried and thrown without a new A press. A selected history is confirmed on the original Japanese ROM. It does not deliver the box to the Ink setup and produces no useful spawning displacement.** A separate Wafel uphill continuation raises Mario while holding the box to Y=979.4578857421875, but hits a steeper terrain face and slides back. Those heights and coordinates must not be substituted for the high actor placement in the conditional handoff.

This work starts at proof revision `1222ab0ee82b870ba5efe1a8afd7f3ea7e78b1bf`, decompile revision `36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`, stock source pin `9921382a68bb0c865e5e45eb594d9c64db59b1af`. All searches use Wafel 0.8.5 JP and Python 3.9.13. The runtime DLL SHA-256 is `960fe979068b78e6733b3ddb87741833fbf4eb29b2a21a2bba871977427c2d0f`. The source input capture has 2852 rows and SHA-256 `9bcc451964025d9f0bb1344c45957b6bfd095451b44bfb9a01f8584a75db6a72`.

The actor is **native small box slot 23**, `bhvBreakableBoxSmall`, initially at `(5900,51,3440)`. It exists in SSL Area 1's stock macro list. It is not a cloned box and is not interchangeable with a second NPC push: the GRABBABLE interaction group processes one selected object. Compatibility of replacing the primary Box in Ink is a separate [handoff investigation](ink-buddy-replacement-handoff.md).

## All grants and actual controls

The sole startup grant is the existing debug level-selection entry (`gDebugLevelSelect=1`, equivalent to the established ROM recorder's `--cheats 6`). After that, a wrapper rejects every write except the three controller-pad fields. Every update rejects both an A button and native held/pressed-A input flags. No Mario position, action, velocity, actor position, object lifetime, held/used pointer, HOLP, floor/cache, RNG or top phase is supplied. Full-state restores branch only from states reached by the recorded controller history. This does not construct a castle-to-SSL approach from a clean save.

The original-ROM-validated stream consists of the accepted first **500 inputs**, **342** inputs that approach and grab the small box, **260** carry inputs, **45** release/observation inputs, and **two** neutral observation-tail inputs: **1149 total**. The acquisition steers through `(4800,4200)` and `(5300,4000)`, then the actual actor. B is pulsed every 24 updates during the approach; within the final 110-unit radius the stick is reduced and B is pulsed every 12 updates. These B inputs use ordinary dives, rollouts and pickup. The exact resulting input stream, rather than these steering targets, is authoritative.

The selected carry follows the beginning of a route through `(5000,3440)`, `(4000,3500)`, `(2500,6000)` and later southern waypoints. It stops at its actual highest held sample before attempting B throw. The route does not reach all proposed waypoints. There is no teleport between them.

## Original-JP carry and throw

The table uses **completed controller inputs**. The original recorder sees the result before poll `n+1`; Wafel's global timer is one greater at those matched cuts. M is movement, C is collision-object position, D is stored `gfx.pos`. HOLP is the renderer-maintained last held-object position and is a different record from all three.

| Completed input | Mario / reference result | Small box / HOLP result |
| --- | --- | --- |
| 842 | Native PICKING_UP; `heldObj = usedObj = 23`; M=`(5821.0888671875,51,3487.29736328125)` | Raw box XYZ remains `(5900,51,3440)` while held. |
| 1102 | HOLD_WALKING; M=`(3393.489990234375,493.27569580078125,4512.3935546875)` | Wafel HOLP=`(3354.61279296875,568.0584716796875,4537.599609375)`. Raw box still at spawn. |
| 1108 | Native throw animation, still holding | Wafel HOLP=`(3393.86279296875,605.234619140625,4491.33935546875)`. |
| 1109 | Native release; Mario's held pointer becomes null | Actual box XYZ=`(3376.12548828125,605.234619140625,4517.9736328125)`. |
| Following free motion | Box remains a live native actor | Its recorded Y peaks at **675.234619140625**, then falls. |

The exact ROM replay passes: **1149 A-off inputs**, **801 native/Wafel before-poll observations**, **zero selected-field mismatches**. The compared fields include binary32 M/C/D, floor, top, action/input, held/used references, and small-box raw XYZ/action/activity/held state. The small-box behavior pointer stays constant. The native probe imports no game-memory write API. This is a finite field comparison, not whole-memory equivalence.

**HOLP itself was not included in the original-ROM observer.** The HOLP values above come from a supplementary fresh Wafel replay of the same input history, whose core fields again match the archived trace. Actual actor release XYZ and subsequent movement were compared against the original ROM. This distinction prevents a source explanation of release from being mislabeled as an internal native HOLP trace.

A Z comparison at the same carried position drops the box at `(3354.61279296875,493.27569580078125,4537.599609375)`. That comparison is Wafel only. The selected native B throw is actual actor relocation; merely moving Mario while his held pointer remains nonnull would not establish raw actor delivery.

The authenticated ROM SHA-256 is `9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317` (MD5 `85d61f5525af708c9f1e84dce6dc10e9`). Replay uses Ubuntu-24.04 WSL, Mupen64Plus 2.5.9's interpreter, Rice 2.5.9, HLE RSP and dummy audio. The original run is `build/wafel-pilot/capture.D8QKUc`; its compressed log, receipt and source hashes are preserved in the instrumentation directory.

## Higher uphill carry, with its exact failure

A real southern-perimeter carry reaches `(-5647.2001953125,14.333476066589355,7154.28466796875)` holding the box. Alternating one full-stick update with one neutral update then repeatedly switches HOLD_WALKING/HOLD_DECELERATING. On the reached floor of type 19 and normal approximately `(0.12700012,0.76200074,0.63500065)`, the steady walking/decelerating forward speeds are `1.5748229026794434` and `0.5748229026794434`. The resulting movement climbs rather than sliding down.

One continuation reaches M=`(-6377.05859375,979.4578857421875,6143.27099609375)` while still holding native box 23. Its actual Wafel HOLP is `(-6393.41552734375,1062.2509765625,6100.8779296875)`; raw box XYZ is still at its spawn. This is a higher **Mario/held-render** predecessor, not a box parked at Y979 and not the Ink location.

The next face has vertices `(-511,0,6144)`, `(-2687,1280,5632)` and `(-8191,1280,6144)`, normal approximately `(0.08096105,0.48576626,0.87033123)`. At continuation update 1509, walking ends with speed `0.37430620193481445`; the next neutral update reaches zero and enters the held slide. Mario slides back and eventually dies in quicksand. This is the first exact failure of that tested uphill cycle. Diagonal steering does not reduce the fixed uphill speed subtraction on the same face; going around to another face would be a different route.

A separate release branch stops one update earlier, at M.Y=`979.291015625` with HOLP.Y=`1049.3438720703125`. B produces a real release at actor XYZ=`(-6377.048828125,1091.25,6125.17431640625)` and the free actor reaches Y=`1108.75` before terrain affects it. Z instead first records the box at Y=`1062.916748046875`: native object floor resolution raises it after the generic drop, so the observed after-update Y is not simply the Y written by the drop helper. These are Wafel results, reproduced from actual inputs, still far from Ink and below the studied useful high actor placement. No original-ROM replay of this longer uphill branch is claimed.

## Earlier high HOLP is not preserved into pickup

The accepted prefix itself supplies another real but incomplete lead. At completed input **463**, while Mario holds eastern Crazy Box 47 in CRAZY_BOX_BOUNCE, M=`(3258.90234375,1459.48779296875,5332.384765625)` and Wafel measures HOLP=`(3340.078857421875,1501.6251220703125,5329.43896484375)`. The continued held rendering overwrites it during descent. By input 500, HOLP has become `(3723.880859375,251.12982177734375,4993.22021484375)`; at small-box pickup 842 it changes again to the newly rendered held box. This record therefore does **not** preserve the high HOLP for a later clone or throw, and its X/Z is not the Ink target. No camera or HOLP edit is used to hide this failure.

## Finite coverage and verification

The ten compressed batches preserve the realized controls and per-update observations. They include four initial failed approaches; four successful acquisition policies followed by 32 direct carry-policy executions across two route menus; two bounded carry beams (29,072 proposed branches and 238,486 branch updates); four southern-perimeter carries; eight one-update continuations from the nearest beam endpoint; nine longer perimeter/steering comparisons; four ordinary release controls; and three uphill release controls. Repeated acquisitions and overlapping histories are not independent discoveries. The nearest beam endpoint immediately dies in quicksand on its next tested update; it is not a stable pyramid-base predecessor. Direct carry losses include Goomba damage and Tweester contact, which normally drops the held actor.

Fresh guarded replays match **61,199 suffix observations across 74 preserved history executions**, plus **801** observations for the selected native-replay stream. The two beam counts describe the original finite search; only their selected complete histories are independently replayed by this check. The stored inputs remain authoritative for older acquisition menus after search-policy refinement. An early diagnostic aborted before producing a final batch; it is not included in those counts.

See [the instrumentation README](../../instrumentation/ink-buddy-replacement-delivery/README.md), `verification.json`, `holp-observations.json`, the compressed records and `native-record/receipt.json`. No new Coq code or theorem is added by this delivery study.

**Verdict:** native small-box acquisition and substantial low-world transport are demonstrated, including original-ROM throw confirmation; actual delivery to the usable Ink coordinates/height, a usable clone there, the phase join, and useful spawning displacement from this history remain unestablished. The earlier high supplied-position handoff is a separate compatibility result. None of these finite failures is a global transport impossibility proof.
