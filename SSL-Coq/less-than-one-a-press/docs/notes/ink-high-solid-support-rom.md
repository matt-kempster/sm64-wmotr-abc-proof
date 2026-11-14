# Original JP confirms the high live-box landing-to-Ink chain

On 2026-11-14 the original Japanese ROM reproduced the selected high live-solid witness: **FREEFALL+B creates DIVE_SLIDE by landing on a large breakable box, a non-mounting shell then nudges Mario, and the chain reaches useful Area 2 spawning displacement.** No ground action is supplied, and Mario is never edited after the initial high airborne cut. This is a conditional original-ROM replay: the high live box, airborne Mario, shell availability and timed shell position are supplied. Their delivery by a continuous no-new-A history remains open. This result advances the Mario action-entry test; it does not complete the route.

This supplements [the13-case JP Wafel experiment](ink-high-solid-support.md), whose source analysis explains the cancelled air landing and fresh low cache. The original-ROM test is one selected positive, not a repeat of the other12 controls or a new height search. Stored graphics means `gfx.pos`, not the rendered model matrix.

## Exact cuts and inputs

The unchanged mode12 `jp-clean-gap-search` controller prefix completes the four-pillar sequence with A released, after the established debug level-selection startup grant. At stored top timer125, the wrapper sets native shell-box32's action to4; two neutral updates spawn shell69. Two further neutral updates reach stored129. The new wrapper makes27 logged writes, each checked against address, width and cut time:

1. One shell-box action write at stored125. Shell behavior, interaction fields and hitbox are native.
2. At stored129,23 scalar writes supply M=C=D `(-1950,25001,-939)`, `ACT_FREEFALL`, action state/timer0, forward speed32, velocity `(32,-16,0)`, face angles `(0,16384,0)`, and live large box13 XYZ `(-1849,24800,-939)`. The helper first writes vertical velocity0 then-16 without any intervening update. Action argument, slide yaw, floor/ceiling caches, surfaces and held/ridden/used/platform pointers are inherited. No ground action is supplied.
3. After native landing, at stored130, only shell69 XYZ `(-1971,25000,-939)` is written. This is the final edit. The live large box stays in place and remains active; it is neither removed nor frozen.

Press B (`0x4000`) with neutral stick during the stored129→130 landing update. All subsequent suffix input is neutral. A is never held or newly pressed in the recorded prefix or suffix; there is no held-A dependency. The wrapper checks that the game has already entered DIVE_SLIDE before placing the shell. Mario never rides or holds an object in the53 camera observations, and usedObj never selects shell69. Its role is a fallback contact shove, not a shell mount.

## Native update boundaries

M is movement state, C is raw Mario collision position, and D is stored graphics XYZ. `step` includes the four earlier shell-preparation updates; high-suffix update1 is step5. Values below are the float32 values reconstructed from the printed nine-significant-digit native trace.

| High suffix / native step | Stored top timer | M and C | D | Action | Floor/cache/platform result |
|---|---:|---|---|---|---|
| Initial cut /4 |129|(-1950,25001,-939)|same|FREEFALL|Inherited static cache1024; no platform. |
|1 /5|130|(-1950,25000,-939)|same|DIVE_SLIDE|Fresh static floor768, no owner/platform; ceiling sentinel20000. |
|2 /6|131|(-1882,768,-939)|(-1882,25000,-939)|GROUND_BONK|Static floor768; producer gap24232. |
|3 /7|132|(-1882,1818.9613037109375,-939)|same|DISAPPEARED|Warp64 used; floor owner and platform61, the spinning top. |
|23 /27|1|(-1991.2451171875,1966.6990966796875,-831.4880981445312)|same|DISAPPEARED|Top61 retained in the last observed Area1 sample; top action2 and inactive. |
|24–25 /28–29|—|No camera sample|—|—|Transition camera-observation gap; no native values fabricated. |
|26 /30|1| (365.5927734375,5500,-1096.8026123046875)|same|SPAWN_NO_SPIN_AIRBORNE|Area2, static floor4429 and ceiling5222, platform cleared. |

The useful arrival differs from the ordinary warp spawn `(0,5500,256)` seen in the Wafel no-pusher/Crazy Box controls. The ROM run's actor and top behavior code is unpatched. Native capture and every available Area1 retention observation agree with Wafel; the two unobserved transition boundaries are covered by that separate Wafel trace, not claimed as native observations. The original live support never moves or deactivates in the observed Area1 suffix. Slot13 is reused after changing areas, so its later fields no longer describe that box.

## Comparison limits and reproducibility

The checker validates the write allowlist, initial cut, native slide, gap, top/warp selection, observed retention, useful arrival, null held/ridden pointers and A-off counters. It compares24 available boundaries ×45 scalar fields/components against the frozen Wafel trial. **1035 of1080 comparisons match.** All45 mismatches are `oInteractionSubtype`: native2 versus Wafel0 for support13 at23 Area1 boundaries and shell69 at22 boundaries from step7 onward. The offset0x190 was checked against the pinned source header. Their origin is not settled by this experiment, and full-field/full-state equivalence is explicitly false. The mismatch list is retained in the receipt. Every compared position, velocity, cache, action, pointer, interaction type/status, radius and height agrees.

Artifacts are in `instrumentation/jp-ink-high-solid-support/`: source, frozen expectation, scripts, `verification.json`, and `records/large-box-shell-25000/` containing text logs, compressed original log, exact source snapshots, receipt and manifest. The runner authenticates the existing ROM before launch. Reproduction commands are in that package's README; archived checking needs only Python. Screenshots and compiled instrumentation remain local build products and are not needed to recheck the recorded assertions. No ROM bytes or video are published.

Environment: Ubuntu-24.04 WSL, Mupen64Plus2.5.9 interpreter (`--emumode0`), Rice2.5.9, HLE RSP2.5.9, dummy audio and softwareGL/Xvfb. Original JP ROM SHA-256 `9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317`, MD5 `85d61f5525af708c9f1e84dce6dc10e9`. Proof start `08df00c605127a172d3a28049e31d6f50f7bff98`; decompile instrumentation checkout `36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`, stock pin `9921382a68bb0c865e5e45eb594d9c64db59b1af`. Frozen comparison uses JP Wafel0.8.5/Python3.9.13, runtime DLL SHA-256 `960fe979068b78e6733b3ddb87741833fbf4eb29b2a21a2bba871977427c2d0f`. No Coq proof is claimed by this replay package.

The first missing gameplay condition is still arranging airborne Mario together with a **live high collision mesh** and a correctly timed shell. The successful large box is present in SSL Area1, but its high delivery is not shown. A frozen hitbox-only clone cannot be assumed to supply the live terrain needed for this landing. The next focused question is whether an allowed history can raise and retain that collision loader; the current conditional success alone does not answer it.
