# Supplied timer-130 crawl and shell handoff

Checked 11 November 2026, after gameplay experiments were authorized. This is
a new bounded runtime fixture in the pinned Wafel 0.8.5 JP library. It is not
a clean controller-produced route and is not an original-ROM emulator replay
of this newly supplied shell setup. The existing controller prefix has an
original-JP comparison, with the documented Wafel global-timer offset of +1.

**The proposed handoff works in this supplied state.** A real shell's ordinary
interaction pushes already-crawling Mario from `(-1950,1741,-939)` to
`(-1882,1741,-939)`. After one logged ground-movement event, movement and collision
are `(-1882,768,-939)`, display remains `(-1882,1741,-939)`, the remembered
floor is the static Y=768 pad, and the action is still crawling. The next
update captures the spinning top through the upper warp. The tested neutral
continuation reaches Area 2 outside the elevator rectangle.

The finite result removes a practical doubt about the **supplied-state
handoff**, including whether the real interaction and ordinary action tail
can cooperate. It does not produce the high crawling state or deliver a
shell there with controller input. The shell's supplied release also changes
allocation history, so the earlier timer-131 allocation counts cannot be
attached to this run.

## What was supplied

The script [ink_timer130_crawl.py](../../instrumentation/wafel-jp-pilot/ink_timer130_crawl.py)
replays the existing no-A four-pillar prefix through poll 2548, checking all
existing sampled-field comparisons along the way. It then gives neutral
inputs until the live top is in spinning action 1 with stored timer 128.
The stock shell box is verified by behavior, slot 32, and contents ID 3.
Its action is set to 4, making its ordinary behavior spawn the shell. Two
ordinary updates produce a real initialized shell in slot 126 and top timer
130. The script saves this full state for all six trials.

Each trial supplies Mario's movement, collision and display at the same high
coordinate, `ACT_CRAWLING`, action state/timer zero, forward velocity 5,
velocity `(4,0,0)` and face angle `(0,0x4000,0)`. In the four shell trials it
also supplies the real shell's position `(-1971,1741,-939)` and zeros its
forward and XYZ velocities. It gives one Z-held update with one of the four
cardinal stick inputs of magnitude 64, followed by at most 28 neutral
updates. Every controller write excludes A.

Every gameplay write, including its previous value, is in the
[compact receipt](ink-timer130-crawl-receipt.json). The inherited stored floor
height is **1024**, not 768, before each trial. No floor pointer/height,
surface data, platform pointer, collision list, action input flags, RNG or
allocator pointer is patched. The actor's real hitbox and behavior are
retained. The prefix's existing pre-entry level-select setup is unchanged.

## Observations and calculation

All four shell trials have the same endpoint and continuation. The following
table describes the first, using Z plus stick `(0,64)`.

| Boundary | Observation |
| --- | --- |
| Before update, global 2680 / top timer 130 | M=C=D `(-1950,1741,-939)`; supplied crawling; inherited floor height 1024 |
| `FLT_EXECUTE_ACTION` during that update | Crawling at `(-1882,1741,-939)`, confirming the +68 X push before action execution |
| Ground movement log | Exactly one `FLT_BEGIN_MOVEMENT_STEP`, type 2 / step 1; no wall-push event |
| After update, global 2681 / stored top timer 131 | M=C `(-1882,768,-939)`, D `(-1882,1741,-939)`; crawling; floor 768; static pad vertices `(-1945,768,-921)`, `(-1945,768,-1125)`, `(-2149,768,-1125)`; stored ceiling height 1523 |
| After next neutral update, global 2682 / stored top timer 132 | Disappeared action, used object slot 64, floor and platform owned by top slot 61; floor height `1818.9613037109375` |
| First sampled inactive top, global 2702 | Top action 2, timer 1, inactive; platform still slot 61 |
| First sampled Area 2, global 2705 | M=C=D `(365.5927734375,5500,-1096.8026123046875)`; outside `[-460,461] × [-204,717]`; floor 4429; platform null |

The phrase “timer-130 update” means the update starting with `oTimer=130`;
the next after-update observation stores 131. These global timers are Wafel
boundaries, not the original emulator's input-poll timers.

The first trial's observed final velocity is
`(3.9231410026550293,0,-0.7803612947463989)`. The walking-speed update turns
Mario by `0x800`, so the executed velocity is not exactly `(4,0,0)`. Applying
the ground-quarter expression to the observed action-entry position, this
velocity and the horizontal pad's normal Y=1 gives the **calculated**, rounded
binary32 intended position
`(-1881.0191650390625,1741,-939.195068359375)`, with words
`0xc4eb209d`, `0x44d9a000`, `0xc46acc7c`. Its signed-integer query coordinates
are `(-1881,1741,-939)`. The other cardinal inputs either give this same
integer point or `(-1881,1741,-938)`.

The log contains exactly one begin event with `stepType=2`, `stepNum=1`.
The [released API](https://github.com/branpk/wafel/blob/v0.8.5/wafel_api/src/frame_log.rs)
decodes that event from the DLL's frame-log structure, but
the exact insertion point of its hook has not been checked against the
pinned library's C build. We therefore do not use the event count alone as
a checked count of individual ground quarters.

Wafel's log does **not** expose floor/ceiling return values, the quarter's
return code, or its intended-position local. Thus local floor 1280 and local
ceiling 1523 are supplied by the independent source/geometry argument, not
reported as newly hooked query observations. The stored `ceilHeight=1523`
is an observed Mario field from geometry preparation. Likewise the sampled
Area-2 coordinate is not a new breakpoint receipt at the first platform
apply call. The source-level selected-tail theorem and the finite geometry
certificate must retain their own exact hypotheses.

## Matched controls

All controls restore the same post-release state, so their allocator history
includes the same supplied box release. They retain the shell far away at its
ordinary location instead of moving it beside Mario.

| Supplied high Mario coordinate | End of first update | Next update / continuation |
| --- | --- | --- |
| Pad `(-1950,1741,-939)`, no nearby shell | M=C Y768, D Y1741 at X=-1950; cache768 | The low query still finds the pad. No top capture; ordinary Area-2 arrival `(0,5500,256)` |
| Target `(-1882,1741,-939)`, no nearby shell | M=C Y1280, D Y1741; cache1280 | No upper-warp/top capture and no Area-2 entry within 28 neutral updates |

These controls support the specific ordering: prepare the low cache at the
pad, then leave its footprint by interaction before the first ground quarter.
Simply supplying the high target does not preserve a Y768 cache; supplying the
pad without the push leaves a low floor that suppresses the desired retry.

## Reproduction and result

From `SSL-Coq/less-than-one-a-press` in PowerShell, the executed command was:

```powershell
& ./build/wafel-pilot/python/python.exe instrumentation/wafel-jp-pilot/ink_timer130_crawl.py build/wafel-pilot/capture.bKv95w/inputs.jsonl build/wafel-pilot/ink-timer130-crawl-20261111.json
```

Exit 0. The script's assertions passed for four successful shell cases and
two controls. It authenticates the same pinned DLL as `replay.py`, and the
baseline capture SHA256 is
`9bcc451964025d9f0bb1344c45957b6bfd095451b44bfb9a01f8584a75db6a72`.
The checked raw report remains under ignored `build/wafel-pilot/`. The
committed compact receipt retains all writes, action/step events, first
quarter calculation, after-update samples, first inactive-top sample and
first Area-2 sample, plus hashes of the raw report and script. Its
`compact_receipt` function was applied to that existing raw report; no second
gameplay run was needed. For a fresh run and receipt, add
`--receipt PATH_TO_A_NEW_JSON_FILE`; both output paths must be new.

Remaining gameplay obligations are the controller production of the high,
already-crawling Mario state, delivery of an eligible shell with the required
contact and phase, and confirmation of the complete setup on the original
JP ROM. The finite Wafel success is stronger than the former untested shell
suggestion but does not discharge these obligations.
