# Three vertical-PU handoffs: selected evidence for the video

13 November 2026. This record selects the existing native-JP witnesses and
reviews six new original-JP ROM recordings for a visual explanation of
crawling, sliding and walking-to-slide at **Y67277**. All three vertical
cases produce the useful Ink handoff from supplied states. The walking
case changes into crouch-slide during the producer update; it is not a
demonstration that ordinary walking alone performs the alignment snap.

The requested horizontal-PU comparison is separate. An equivalent terrain
query does not bring Mario's actual X/Z back to the real warp. Horizontal
failure controls must be labeled as such, not shown as a fourth successful
handoff or generalized to all possible PU routes.

Watch the [4:06.6 visual explainer](../media/ink-vpu-actions/ink-vpu-actions.mp4)
or read its [commentary transcript](../media/ink-vpu-actions/ink-vpu-actions-transcript.md).
It uses original-ROM gameplay, clearly labeled explanatory diagrams, pauses
and slow motion in the earlier crawl video's silent commentary style.

## Exact pre-existing witnesses

The source revision at selection is
`55b791068e0373be4e0382ebc02608853c3b3b03`. These selected records are
**Wafel 0.8.5 JP supplied-state observations**, not original-ROM footage.
Any new original-ROM capture used in the finished video needs its own
setup/trace/frame receipt and cannot inherit that label from these records.

| Chapter | Durable receipt and JSON path | First input, then neutral |
| --- | --- | --- |
| VPU crawl | `ink-pu-vpu-receipt.json`, `handoff.trials[2]`, recipe `vpu-box` | Z held, raw stick `(0,64)` |
| VPU butt slide | `ink-slide-handoff-receipt.json`, `selectedFullTraces[10]`, recipe `ACT_BUTT_SLIDE-y67277-v20-neutral` | Neutral |
| VPU walking → crouch-slide | `ink-slide-handoff-receipt.json`, `entryCuts.trials[10]`, recipe `walking-native-z-east`, height 67277; include `entryCuts.walkingPreparation` | Z held, raw stick `(33,55)` |

Each selected post-cut history contains 25 completed native updates to its
first Area 2 sample. All pads have A off. All three have the same observed
position, floor/platform and warp-countdown continuation from update 2 onward.
That equality is limited to the selected projection; the runs are separate
and are not whole-memory-identical histories.

The renderer-friendly selection at
`instrumentation/jp-ink-vpu-actions-demo/records/selected-witnesses.json`
contains the complete three records, walking preparation, source receipt
hashes, exact keyframes and the two older horizontal-crawl comparison records.
It is a derived selection, not a new gameplay experiment.

## What is supplied, and what the game does

All three high cuts supply M=C=D `(-1950,67277,-939)` and existing Crazy Box 49
at `(-1989,67277,-939)`. Here **M** is movement, **C** the collision object's
raw position and **D** stored graphics. The actor's remaining state is inherited.
No floor-cache, platform, surface list, top timer, RNG or allocator pointer is
patched. The Wafel prefix replays 2548 recorded A-off inputs and the disclosed
pre-entry debug level selection, then waits normally for the top phase.

The crawl fixture additionally supplies `ACT_CRAWLING` (`0x04008448`), action
state/timer 0, forward speed 5, velocity `(4,0,0)` and facing `0x4000`.
The butt-slide fixture instead supplies `ACT_BUTT_SLIDE` (`0x00840452`),
state/timer 0, forward speed 20, velocity `(20,0,0)`, facing `0x4000`, slide
velocity `(20,0)` and slide yaw `0x4000`. Their inherited floor before the high
update is 1024, not the desired 768; the native update refreshes the cache.

The walking case has **two supplied cuts**. Before behavior 129, the first
cut supplies M=C=D `(-1800,1280,-800)`, walking (`0x04000440`), state/timer 0,
forward speed 20, velocity `(20,0,0)` and facing `0x4000`. One actual input,
no buttons and stick `(28,58)`, establishes native walking speeds. The result
is M=C=D `(-1779.388671875,1280,-800.98095703125)`, forward speed
20.634883880615234, velocity/slide velocity XZ
`(20.611557006835938,-0.9808891415596008)`, and facing/slide yaw 16883.

At behavior 130, the second cut changes **only** the equal M/C/D high pose
and box XYZ. It retains the native walking action, speed, slide velocity,
floor cache and platform. The Z input then produces walking → crouch-slide
→ ground bonk within one update. This improves the conditional action-entry
component but does not demonstrate travel from the low roof to the VPU.
No animated camera flight or edit between those positions should imply such
travel occurred.

## Shared Wafel keyframes

These values are native observations in the selected records. The producer's
internal query and quarter-return explanation is connected through source and
the existing formal checkpoints; it is not a direct query-hook measurement.

| Completed boundary | Movement and collision | Stored graphics / other observations |
| --- | --- | --- |
| High supplied cut, global 2680, before behavior 130 | `(-1950,67277,-939)` | D agrees. Primary crawl/slide inherited floor 1024; walking inherited roof 1280. |
| Global 2681, behavior 130 completed | `(-1882,768,-939)` | D=`(-1882,67277,-939)`; gap **66509**; floor 768, no platform, **zero top surfaces**, no-ceiling height 20000. Crawl stays crawl; slide/walking cases end in ground bonk. |
| Global 2682, behavior 131 completed | `(-1882,1818.9613037109375,-939)` | D agrees. Disappeared `0x1300`, argument `0x40001`; used warp 64; floor owner/platform 61; six top surfaces. |
| Global 2683 | `(-1863.1396484375,1858.9560546875,-1044.82568359375)` | Warp operation 4, countdown 19; platform/floor owner 61. |
| Globals 2684–2701 | Exact native following positions in receipt | Platform and floor owner remain 61 while the normal countdown advances. |
| Global 2702 | `(-1991.2451171875,1966.6990966796875,-831.4880981445312)` | Top slot inactive, yet floor owner/platform still 61; countdown 0. |
| Globals 2703–2704 | Same position as 2702 | The inactive top's platform reference remains through the final Area 1 samples. |
| Global 2705, first completed Area 2 sample | `(365.5927734375,5500,-1096.8026123046875)` | Outside the elevator footprint; the useful displacement occurred. |

At the producer's action-entry event, M has already been pushed to
`(-1882,67277,-939)`. In the walking case the action log directly shows
walking and crouch-slide at that same high point. This is not an extra
controller opportunity between actions.

## Fresh original-JP recordings and independent review

The six new runs are separate launches of the original JP ROM, SHA-256
`9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317`,
MD5 `85d61f5525af708c9f1e84dce6dc10e9`. They use Mupen64Plus 2.5.9's
pure interpreter, Rice 2.5.9, HLE RSP 2.5.9 and dummy audio in Ubuntu 24.04.
The launcher checks both ROM hashes. The raw emulator logs identify the JP
ROM, interpreter and enabled cheat 6, the disclosed pre-entry level-select
boundary. The gameplay camera is unmodified.

The reproducible source and compact records are under
`instrumentation/jp-ink-vpu-actions-demo/`; original build directories are
`build/jp-ink-vpu-actions-{crawl,slide,walk,x-slide,x-walk,xy-slide}-20261113`.
These recordings run the existing state-dependent `SEARCH_MODE=12`
controller prefix, whose included source is archived and hashed. They do
not simply play the Wafel prefix file byte for byte. All six runs reach four
pillars normally under that prefix, then receive the disclosed setup edits.
The proof checkout remains `55b791068e0373be4e0382ebc02608853c3b3b03` plus
the new recording files. The inspected decompile is
`36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`; the original-ROM runs execute
retail instructions, not a newly built decompile.

The three high setups use the same supplied values listed above. Crawl has
22 word writes (17 of width 32, five of width 16); butt slide has 25 (19 and
six); walking has 31 (26 and five) across its **two cuts**. These counts
include writes that repeat an existing value. In walking, 19 writes create
the low preparation before relative input 5; input 5 then produces native
walking movement. Twelve writes before input 6 supply only the equal high
M/C/D and box XYZ. The high action, velocity and cache are inherited from
that walking update. The other cases make their only cut before input 6.
There are no recorder writes to the camera, floor cache, surface lists, top,
platform or allocator, and no gameplay writes after the last supplied cut.
Every logged controller input has A off; the selected first inputs match
the table above and inputs after 6 are neutral.

| Original-ROM case | Supplied M=C=D before input 6 | Input 6 result | Observed handoff |
| --- | --- | --- | --- |
| Vertical crawl | `(-1950,67277,-939)` | M=C=`(-1882,768,-939)`, D=`(-1882,67277,-939)`; gap 66509; still crawling | Capture input 7; useful Area 2 input 30 |
| Vertical butt slide | Same | Same M/C/D and gap; ground bonk `0x00020466` | Same capture and useful arrival |
| Vertical walking → crouch-slide | Same, after the separate low walking preparation | Same M/C/D and gap; ground bonk | Same capture and useful arrival |
| Horizontal X-PU butt slide | `(63586,1741,-939)` | M=C=D=`(63658.6015625,1741,-939)`; gap 0; butt-slide-air `0x0300088e` | No warp acceptance, top capture or Area 2 within 148 inputs |
| Horizontal X-PU walking → crouch-slide | Same, after low walking preparation | M=C=D=`(63658.8203125,1741,-939.2282104492188)`; gap 0; freefall `0x0100088c` | No warp acceptance, top capture or Area 2 within 148 inputs |
| Combined X/Y-PU butt slide | `(63586,67277,-939)` | M=C=`(63654,768,-939)`, D=`(63654,67277,-939)`; gap 66509; ground bonk | No warp or top capture; next input restores M=C=D high at `(63654,67277,-939)`; no useful arrival |

Each control supplies the box at `(MarioX-39,MarioY,-939)` with the same
action recipe and top phase 130. Thus even a pusher at the correct raw PU
coordinates does not repair these horizontal cases. The X-only controls
have a quarter-step that leaves ground. The combined X/Y case reproduces
the large vertical split but remains 65536 units east of the warp. These
are finite failures of these setups, not a theorem excluding all horizontal
PU routes. The combined run has camera samples through input 112 and inputs
through 148; camera updates subsequently stop. Its eventual CLI screenshot
does not supply missing gameplay states.

In each vertical success, input 7 directly records the accepted warp:
action `0x1300`, argument `0x40001`, used object `0x80345918`, and floor
owner/platform `0x803451f8`, at Y1818.9613037109375. Every available Area 1
camera sample from inputs 7 through 27 retains that top pointer. At input
27 the top is inactive and still has its top behavior; the pointer remains.
The raw prefix log also records that platform immediately before input 28.
Camera rows 28 and 29 are absent, so this recording does not directly
observe their full states. At input 30, Area 2 begins at
`(365.5927734375,5500,-1096.8026123046875)`, outside the elevator footprint.
The old top slot is then repurposed; its new Area 2 fields must not be
interpreted as the Area 1 top still being active. Logged decimal coordinates
use nine significant digits; the exact values here are recovered by
round-tripping those values to Float32.

The fresh recorder directly observes end-update M/C/D, action, cached
floor, owner/platform, box and top fields. It does **not** hook the local
floor query or ground-quarter return, count loaded surfaces, or record the
intermediate walking-to-crouch action inside input 6. Those explanations
remain source deductions supported by the earlier native Wafel event
records. The larger height scans are still Wafel finite searches; these six
original-ROM demonstrations do not convert them into original-ROM scans.

Independent review reparsed all six raw logs and checked their receipt
fields, payload hashes, every image hash, setup ledger, A-off controller
records, positive/negative milestones, and screenshot joins. The review
passed. `instrumentation/jp-ink-vpu-actions-demo/records/original-rom-review.json`
preserves the compact review results; `selected-witnesses.json` in that same
directory also includes original-ROM run
references and frame keyframes.

### Screenshot timing

Rice's requested image is the **previous framebuffer**. Join request timer
minus one to a camera row; do not infer the input from the image's ordinal.
For these captures, `006.png` is completed input 6, `007.png` is input 7 and
`028.png` is the first Area 2 input 30. The filenames have the full prefix
`super_mario_64-`. The first Area 2 image is still black during the normal
fade; later images show the arrival as the view opens.

Image `000.png` has no preceding camera-row join in any run. In the three
successes, `027.png` is an unjoined transition image: the request is at timer
2703 but timer 2702 has no camera row. The inactive-top state at input 27 is
directly logged, but no image is joined to it. A frozen adjacent frame may
illustrate the trace with a clear annotation; it must not acquire input 27
as an invented image label. In the combined X/Y run, the final `112.png` is
an extra CLI test shot at frame 2820 with no camera request or state join.
These missing joins are explicitly null in the receipts.

## Visual and commentary rules

The earlier Crazy Box explainer uses a 1600×900 layout: original gameplay at
left, a schematic at right, an M/C/D legend, two short commentary lines and
a provenance footer. Its slow portions repeat captured frames; the schematic
explains changes inside a single update without pretending they are extra
frames of gameplay. Preserve that presentation pattern.

Use the legend **“D: stored graphics”**, not “where Mario is drawn.”
Floor alignment installs a throw matrix that can render the model low even
when D is high. A high ghost marker or a cleared-matrix illustration must be
explicitly labeled. The gameplay panel alone cannot depict all three stored
positions or prove the internal floor selection.

A VPU diagram should have a broken vertical scale or separate high/local
panels. There is no physical duplicated pyramid 65536 units above SSL.
The successful high query narrows Y67277 to 1741 and returns the **ordinary
local plane**, without adding 65536. Raw Mario, box and warp positions do not
wrap. The far-away top has no loaded collision during the producer; the
default ceiling result 20000 stops the high quarter. After the low snap,
the top is nearby and reloads before the retry.

The actual cartoon sequence should therefore show: supplied high Mario and
box; query alias/pad cache; sideways push; high D retained and low M/C; local
warp overlap; top collision reload; high retry selecting a local top floor;
normal warp countdown; retained inactive platform; useful Area 2 arrival.
For slides, explicitly show that bonking does not skip alignment. For walking,
explicitly show Z entering crouch-slide first.

## Horizontal comparison references and limits

The older `ink-pu-vpu-receipt.json` supplies two useful comparison records:
`handoff.trials[4]` (`pu-x-box`) and `handoff.trials[8]` (`pu-vpu-box`).
They are crawl controls, not prior demonstrations of horizontal sliding or
walking. Fresh recordings of horizontal slide/walk controls must report their
actual results rather than assuming those crawl outcomes transfer unchanged.

Horizontal-only high crawl lacks the nearby top ceiling and leaves ground.
Combined X/Y PU crawl creates a vertical snap but leaves actual X far from
the real warp. Query aliasing does not copy or relocate the warp or pusher;
floor alignment changes Y, not X/Z. These finite failures explain why a
horizontal copy is not automatically a useful handoff. They do not exclude
all possible paths that later return Mario's X/Z.

The explanation adds no reachability theorem. The allowed history that
delivers the actor, obtains the high position/action and joins the top's
timing remains open. Rank 1 **1–2%** and Ink Rank 2 **<1%** remain subjective
estimates; the video should not present them as measured probabilities.
