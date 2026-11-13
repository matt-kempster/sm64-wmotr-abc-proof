# Conditional VPU actions: original JP-ROM video captures

These six fresh runs reproduce three conditional handoffs and three horizontal-PU controls on the original Japanese ROM. They supply the producer state and Crazy Box position. They do **not** demonstrate delivery to the supplied high or remote position or a continuous allowed controller route.

The successful states come from the prior `ink-pu-vpu-receipt.json` `vpu-box` crawler and `ink-slide-handoff-receipt.json` `ACT_BUTT_SLIDE-y67277-v20-neutral` and `walking-native-z-east` trials. The native preparation and observed key positions agree with those Wafel witnesses. The underlying four-pillar approach is the existing `jp-clean-gap-search` mode-12 controller prefix. The capture wrapper starts at stored top phase125, supplies the main state immediately before native phase130, then runs native code with controller inputs only. No camera, floor cache, top, pillar, platform, or RNG field is supplied. Debug level-select cheat6 remains the existing emulator setup.

| Mode | State supplied before producer | Producer result M/C and D | Handoff |
|---|---|---|---|
| 1 crawl | (-1950,67277,-939), established crawl, speed5, box atX−39 | M=C=(-1882,768,-939); D=(-1882,67277,-939) | Accepted warp; top captured/retained; useful Area2 |
| 2 butt slide | Same position, butt slide20, box atX−39 | Same 66,509 gap; ends ground bonk | Same accepted result |
| 3 walking | Native walking preparation followed by position/box-only high cut | Same gap; ends ground bonk | Same accepted result |
| 4 horizontal-X slide | (63586,1741,-939), butt slide20, box atX−39 | M=C=D=(63658.6016,1741,-939); airborne butt slide | No gap, warp, top capture or Area2 |
| 5 horizontal-X walking | Native walking preparation; position/box-only cut to(63586,1741,-939) | M=C=D=(63658.8203,1741,-939.228210); freefall | No gap, warp, top capture or Area2 |
| 6 horizontal-X plus vertical-Y slide | (63586,67277,-939), butt slide20, box atX−39 | M=C=(63654,768,-939); D=(63654,67277,-939) | Full gap but no warp, top capture or Area2 |

Modes1–3 use a vertical offset of+65,536 overY1741. Modes4–5 use horizontalX+65,536 only. Mode6 adds both offsets. These are finite controlled examples, not universal PU/VPU conclusions. The raw horizontal collision position remains far from the warp even when aliased floor queries and a large vertical split occur.

At local input6 (native producer phase130), the successful gap is66,509. At input7 the action is`0x00001300`, argument`0x40001`, used object`0x80345918` (upper warp), floor owner/platform`0x803451f8` (top), M=C=D=(-1882,1818.9613,-939). The pointer remains assigned through the inactive-top portion of Area1. The first observed Area2 update is input30, M=C=D=(365.592773,5500,-1096.80261), outside the ordinary lower destination footprint. Native neutral inputs then land Mario on the upper walkway at(337,4429,-1075). Input87/image085 visibly shows him standing there beside coins.

The walking example has **two supplied-state cuts**. Before input5, pose(-1800,1280,-800), walking action, state/timer0, speed20, velocity(20,0,0), and face yaw0x4000 are supplied. Input5 is stick(28,58), no buttons. Native code produces speed20.6348839, slide velocity(20.611557,-0.980889142), yaw16883, action timer3, floor1280. Before input6 only M/C/D and the boxXYZ are moved. Input6 isZ plus stick(33,55). This validates the native walking-to-slide edge in a supplied high state, not a method of reaching that state.

Crawl input6 isZ plus stick(0,64); slide input6 is neutral. All later inputs are neutral. The wrapper logs every write with address, width, previous bits, replacement bits and field name. Modes1–6 make respectively22,25,31,25,31,25 writes; all cease before the producer update. The complete prefix and capture record zero A input/down/pressed frames. No A input does not make the supplied-state edits a valid route.

## Reproduce

Use Ubuntu-24.04 WSL (emulator environment), with the project directory as current directory. The output directory must not exist:

```sh
bash instrumentation/jp-ink-vpu-actions-demo/run.sh \
  ../../../reference-sm64-decomp/baserom.jp.z64 \
  build/jp-ink-vpu-actions-crawl-repeat 1
```

Change the final mode1–6 and fresh output directory for each run. The launcher verifies ROM hashes, builds the native instrumentation with GCC warning checks, runs Mupen64Plus interpreter under Xvfb with Rice rendering and HLE RSP, saves stock-camera PNGs, and checks the trace. No ROM is copied into an output or publication directory. `check.py OUTPUT MODE` can recheck an existing run. `index.py` gathers the six dated runs into`build/vpu-video/original-rom-captures.json` for the renderer.

Runtime: Ubuntu24.04, Mupen64Plus2.5.9 interpreter, Rice2.5.9, HLE RSP2.5.9, dummy audio. ROM SHA256:`9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317`; MD5:`85d61f5525af708c9f1e84dce6dc10e9`. Proof checkout at capture:`55b791068e0373be4e0382ebc02608853c3b3b03`; decompile checkout:`36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`. The new wrapper is captured and hashed in each output alongside the included prefix, launcher, compiled probe and checker. The original ROM is the actual executed program; the decompile provides symbol/layout interpretation.

The only active local source include is`instrumentation/jp-clean-gap-search/jp_clean_gap_search_probe.c`; every receipt's`sourceDependencies` records its exact SHA256 and repository path, and every original output preserves its bytes as`prefix-source.c`. Its optional`jp_ranks13_18_probe.h` include is guarded by`RANK13_18_COPY_AUDIT=0` and is not compiled in these modes. The GCC system/Mupen development headers come from the recorded Ubuntu environment.

## Evidence and image timing

Each output preserves`raw.log`, `trace.txt`, `probe-source.c`, `prefix-source.c`, `run-source.sh`, `checker-source.py`, `probe.so`, `receipt.json`, configuration and screenshots. The receipt records writes, controller inputs, end-update Mario movement(M), collision(C), graphics(D), action, cached floor/ceiling, floor owner/platform, top state and box state. No per-quarter or local floor-query hook is installed; those internal explanations remain source deductions.

Rice screenshot requests at the camera callback save the **previous completed framebuffer**. `receipt.frameMap` joins requestTimer−1 to the corresponding camera snapshot. Never infer the completed input from the PNG index through the warp transition. Before the transition, images001–026 join inputs1–26; skipped transition callbacks change subsequent indexing. For all successful runs input6 is image006, input7 image007, firstArea2/input30 image028 (black transition), and visible walkway/input87 image085. Input27 telemetry observes the inactive top and retained pointer, but has no joined image; image027 has a null join. The high Mario graphics position is outside the stock camera at the gap; a labeled explanatory diagram is needed. The diagram must not be represented as rendered gameplay. Unknown joins are explicitly null. Mode6 additionally has a final CLI testshot without a camera join; it is retained, marked null, and unsuitable as a timed gameplay illustration.

All six checks passed. The only initial checker failure was mode6 having113 PNGs for112 camera requests: the final CLI testshot occurred after camera callbacks stopped. The checker now requires and records that single extra terminal screenshot separately; gameplay assertions were unchanged. No Coq work was performed for these recordings. A clean route still requires continuous no-new-A delivery of the high/remote Mario state and correctly placed actor.

The durable `records/{crawl,slide,walk,x-slide,x-walk,xy-slide}/` directories contain compact receipts and every relevant trace/write/input/screenshot-request record, plus the final native no-A summary. They omit unrelated prefix telemetry, binaries and screenshot bytes; original hashes and build locations are preserved. `python3 instrumentation/jp-ink-vpu-actions-demo/check.py instrumentation/jp-ink-vpu-actions-demo/records/crawl 1 --archived` validates the archived gameplay assertions and image-time joins without writing files. That mode checks recorded image hashes for format; use the original-output check to rehash actual images. `archive.py` rebuilds the durable records from the original build outputs.
