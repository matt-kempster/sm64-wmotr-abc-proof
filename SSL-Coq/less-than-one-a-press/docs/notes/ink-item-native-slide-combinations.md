# Native slide entry with a Crazy Box and Bob-omb Buddy

**A usable Mario-side fragment now works from a supplied low airborne state, without supplying a ground action.** A native shell contact and Z press create a real butt slide on the moving top. A stock Crazy Box and the stock Bob-omb Buddy then push Mario into the required intermediate position. A second supplied position for the box produces the low collision/high stored-graphics split, captures the top, retains it through the warp, and reaches the displaced Area 2 arrival. The initial Mario/shell state and later actor positions are still supplied; their joint delivery by an allowed controller history remains open.

The parent investigation independently reproduced the low-Y positive and its no-Buddy comparison on the original JP ROM: the full recipe reaches the displaced arrival, while removing Buddy stays in Area 1. See the [combined verdict](ink-item-combination-verdict.md) and [JP replay records](../../instrumentation/jp-ink-item-combinations/README.md). The 326 positive search recipes below are **Wafel results**, not 326 original-ROM replays.

## What changed

The earlier [native action-entry actor cuts](ink-high-action-entry-actor-cuts.md) gave a real shell-created butt slide, but the tested shell-plus-box pushes left it short of the low pad. The stock Buddy is a different interaction type, processed after the grabbable box, and adds a continuing push. This matters because the engine checks which objects overlap Mario's old collision position, then applies their pushes to Mario's already-carried movement position. Adding the nominal push distances alone is not a valid calculation.

This study first reused two named near misses from that earlier work. Buddy reduced the nearest miss from 58.18 to 6.86 units. A small placement/air-position refinement reached the pad in X/Z, but a ground quarter had already raised Mario to the top. The next refinement used actual native box-only positions to propose Buddy placements that put Mario inside the pad **before** the first ground quarter. That produced the useful handoff. Correcting the initial airborne X/Z then reduced the required initial raw Y from 21,700 to 1,810.

## Exact low-Y witness and all grants

Use the existing `capture.bKv95w/inputs.jsonl` prefix and the helper in `instrumentation/ink-high-action-entry/prelude.py`. The prefix and helper include the previously disclosed debug level selection; this is not an uninterrupted original-ROM controller route from reset.

1. Before top behavior phase 125, set the existing shell-box object, slot 32, to action 4. Two native neutral updates create the normal Koopa shell, slot 69. Continue neutrally to before phase 128.
2. Once, before phase 128, set Mario's movement, collision-object, and stored `gfx.pos` XYZ to **(-1922.4404296875, 1810, -1223.34130859375)**. Supply `FREEFALL`, action state/timer 0, forward speed 20, velocity **(0, -16, 20)**, and face angle **(0, 0, 0)**. Place the native shell at the same X/Z and Y=1800. Do not write floor, ceiling, platform, cache, slide velocity, hitbox, interaction status, or warp fields.
3. Use **Z with neutral stick** for update 128. Every later controller update is neutral, with A neither held nor pressed. The engine executes `RIDING_SHELL_GROUND`, then `CROUCH_SLIDE`, then `BUTT_SLIDE` in this update. It reaches the actual top at movement/collision **(-1920, 1799.2869873046875, -1210)**. No Mario writes follow the initial airborne cut.
4. Before update 129, place native Crazy Box slot 49 at **(-1990.710693359375, 1799.2869873046875, -1280.710693359375)** and native Buddy slot 15 at **(-2054.455810546875, 1799.2869873046875, -1208.867919921875)**. These are XYZ-only actor cuts. Their normal scripts run; neither actor is frozen or given a different type/radius/status.
5. Before update 130, place the **same** Crazy Box at **(-2117.125244140625, 1830.177978515625, -1128.1343994140625)**. This is another XYZ-only cut. No further state writes follow.

The Buddy is `bhvBobombBuddyOpensCannon`, interaction `TEXT`, NPC subtype, radius 100 and height 60. The Crazy Box is the initialized native `bhvJumpingBox`, grabbable radius 75, height 125, down-offset 10. Mario's collision radius is 37. The NPC fallback push uses padding -10, hence target separation 127; the box uses target separation 107. Both must first pass collision registration at their actual coordinates. Ordinary shell/Buddy/box callbacks and all status changes remain active.

The box's phase-130 cut moves its X/Z **198.141777834 units** from the phase-129 placement. This has not been replaced by a native throw. Calling the fragment an item-delivery route would therefore be incorrect.

## What each update actually does

Here, an update number is the top behavior timer **before** that update. M means movement, C means collision object, and D means stored `gfx.pos`, not the model's render matrix or where the model is visibly drawn. Values are rounded in this table; the receipt preserves the exact binary32 values.

| After update | M = C | D.Y | Action | Floor cache / platform | Consequence |
|---|---|---:|---|---|---|
| 128 | (-1920, 1799.286987, -1210) | 1799.286987 | Butt slide | Actual top 1799.286987 / top | Native ground action and support established |
| 129 | (-2140.031982, 1830.177979, -1115.029175) | 1799.286987 | Butt slide | Top 1830.177979 / none | Box then Buddy move Mario into the pad region; stored position and cached height differ |
| 130 | (-2210.062256, 768, -1075.108887) | 1830.177979 | Butt-slide stop | Fresh static floor 768 / none | Productive gap **1062.177979**; low collision overlaps the real warp |
| 131 | (-2210.062256, 1906.035156, -1075.108887) | 1906.035156 | Disappeared | Actual top 1906.035156 / top | Used object is warp slot 64; floor owner and platform are top slot 61 |
| Area 2 arrival | (365.592773, 5500, -1096.802612) | 5500 | Spawn no-spin airborne | Static floor 4429 / none | Actual displacement beyond the ordinary arrival region |

The top remains the platform at every sampled Area 1 boundary from capture through the last boundary before Area 2. The complete positive follows 26 updates after the initial native action conversion. The useful-spawn check is the existing project's test that the Area 2 X/Z lies outside `[-460,461] × [-204,717]`; the exact final position is also retained rather than relying only on that Boolean.

The first action event in update 130 still has movement Y=1830.177979; the end of that update has M/C.Y=768 and D.Y=1830.177979. The observed ceiling cache is 1523. The next update's first action event has already restored movement from D and selected `DISAPPEARED`, and its end has the top floor/platform. This matches the source's failed-floor retry through `gfx.pos`. This Wafel harness records action events and update boundaries; it does not invent a missing quarter-step return-code trace.

This working producer Y=1830.177979 is outside the old **fixed X/Z** 1741–1801 butt-slide window. It uses different X/Z and actor placements, so it is evidence that the earlier scan's maximum was not a universal starting-height limit. It is not a newly proved height interval.

## Controls and first failed conditions

| Change to the positive | Observed result | First relevant failure |
|---|---|---|
| Remove initial shell relocation; retain Z128 | Ground pound after 128 | The ground slide is never created |
| No initial shell; neutral128, neutral or Z129 | `FREEFALL_LAND` after 128 and 129 | The same actor cuts do not reach the productive slide action; no useful handoff |
| Remove box129 | Butt slide remains on top; no warp within 35 updates | Buddy alone pushes toward the wrong intermediate position |
| Remove Buddy129 | Butt slide remains on top; no warp within 35 updates | Box alone misses the required intermediate position/cache |
| Remove box130 | Low split, then **ordinary warp** | The final low position still has a static floor: no top capture, no useful displacement |
| Remove all later actor cuts | Remains on the top during the sampled interval | No productive low collision/high-D handoff |
| Initial Y=1810 but original X/Z (-1920,-1210), with all later cuts unchanged | Native butt slide at (-1917.559570,1808.184326,-1196.658691) | Native movement lands at a different predecessor, so the unchanged actor recipe fails |
| Corrected initial X/Z, Y=1830 | Same useful handoff | Positive lower-air comparison |
| Corrected initial X/Z, Y=1900 | `BUTT_SLIDE_AIR` | The ground action leaves support in update 128 |

The no-box130 control is especially important: it reaches Area 2, but only through the ordinary warp. Its after130 M/C is (-2140.031982,768,-1115.029175), with the high D still stored. On update131 the geometry resolves to low static floor at (-2099,768,-1075); it selects the warp without capturing the top. Thus neither a large gap nor entering Area 2 is the success criterion.

At the original X/Z, the fixed later actor cuts also succeeded from initial air Y=19900, 20100 and 21700. Tested initial Y=1809.286987, 1810, 1830, 1870 and 1900 created a native butt slide at the different predecessor above and failed; Y=2000 and 2500 created `BUTT_SLIDE_AIR`. These are finite controls, not an exhaustive interval or proof of a minimum. The low-X/Z correction used three iterations at each of Y=1810,1830,1900; the repeated successful second/third iterations are not independent discoveries.

## Coverage, provenance, and limits

All scripts and menus are in [the instrumentation directory](../../instrumentation/ink-item-native-slide-combinations/README.md). The [durable receipt](ink-item-native-slide-combinations-receipt.json) contains 15 complete selected histories, all 326 positive high-air inverse-search recipes, summary rows for every height/no-shell control, raw output hashes, and each supplied write. The full 88,188,709-byte inverse-search JSON remains local under `build/wafel-pilot/`; it is reproducible and is not copied into the private site.

| Batch | Native coverage | Outcome |
|---|---|---|
| Initial named-near-miss comparisons | 260 Buddy combinations from two native seeds | 0 pad arrivals; closest 6.856724 units short |
| Tangent/initial-position refinement | 13 initial positions; 9 low native seeds; 918 actor combinations | 1 final X/Z pad arrival at wrong height; 16 following producer cases, 0 captures |
| Inverse-placement refinement | 396 actual first-push comparisons; 748 registered Buddy proposals; 5566 following producer cases | 326 captures and useful arrivals |
| Fixed-cut initial-height/removal controls | 14 complete histories | 3 high-air positives; all named actor-removal controls fail useful capture |
| Low-air X/Z correction/removals | 13 complete histories | Low1810 and1830 positives; all four actor-removal controls fail useful capture |
| No-initial-shell controls | 3 complete histories | No captures or useful arrivals |

Across the batches, **392 selected complete histories were matched against a separately reconstructed game instance, covering 11,070 update boundaries**. These totals include repeated controls and are not counts of independent route families. The first two scripts and the inverse proposal calculation are finite searches; their negative results are not global impossibility theorems.

Investigation base: proof commit `08b72af44fbb54aaef3ed7f8be399868ba75db98`, decompile worktree commit `36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`, with the existing local instrumentation preserved. Native JP execution used Wafel 0.8.5, Python 3.9.13, DLL SHA256 `960fe979068b78e6733b3ddb87741833fbf4eb29b2a21a2bba871977427c2d0f`. Input-prefix SHA256 is `9bcc451964025d9f0bb1344c45957b6bfd095451b44bfb9a01f8584a75db6a72`. Runtime/helper/source hashes are also recorded. The durable receipt SHA256 is `6014f1c764dc4cca1dfd0e64bdbbaf8d3f8262dbf6f6ed1b7697992cc4525da6`.

Relevant JP source is `interaction.c`'s shell handler, grabbable handler, `check_npc_talk`, ordered dispatch and `push_mario_out_of_object`; `mario.c:update_mario_geometry_inputs`; the common slide helper in `mario_actions_moving.c`; and `mario_step.c:perform_ground_step`. This study adds no Coq theorem and does not recast a finite trace as an unconditional reachability proof. Existing source/Clight boundaries remain applicable at their stated assumptions.

The Mario-side action-conversion problem is now narrower: a supplied airborne pose only about eleven units above its eventual local floor can be converted natively into the exact productive predecessor. A continuous permitted history reaching that air pose and shell contact has not been supplied here. Actor delivery is more demanding: Buddy and the first box must be present at the right actual coordinates and phase, then the second shove must occur without the supplied 198-unit box relocation. A useful next experiment is two prepositioned legitimate grabbable actors: one registers at129 and a different one at130. That is a proposal to test, not evidence that two such actors can be delivered or that same-type collision ordering will cooperate.

The clean no-new-A route assessment remains open. This conditional fragment is a meaningful improvement over supplying a high ground action, and the original-JP positive establishes the actual displaced spawn under these grants; it is not yet a clean counterexample.
