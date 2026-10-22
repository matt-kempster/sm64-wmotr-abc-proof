# experiments/oracle — the real game, headless, as a test oracle

Tether §5.1 of `docs/TRUST.md`: record what the *real* game does to RAM
during `execute_mario_action`, so the model (the proved-sound Clight
interpreter in `proofs/Interp/`) can be run on the same state and compared.
This is evidence, not proof. Nothing in `proofs/` depends on it.

## What runs

- **ROM**: the decomp (`vendor/sm64` @ 9921382), built matching
  (`make VERSION=us COMPARE=1`). The sha1 is `9bef1128717f958171a4afac3ed78ee2bb4e86ce`,
  which equals the US baserom, so ledger row 2.1 has been checked.
- **Emulator**: Mupen64Plus core from source, with the debugger enabled, running the
  cached interpreter. HLE RSP. No audio.
- `video_plugin.c`: draws nothing, but raises the DP interrupt when a display
  list completes. The core's dummy video plugin never does, so the game thread
  hangs.
- `input_plugin.c`: controller 1 reports `oracle_keys`, which Python sets
  each frame.
- `m64.py`: ctypes frontend. Provides VI (per-frame) callback, PC breakpoints
  with Python handlers, registers, RDRAM in N64 byte order, and savestates.
  Runs about 1500 VIs per second.

## Scripts

- `nav_to_wmotr.py`: boots, picks file 1 (pokes the static `sSelectedFileNum`,
  found by disassembly since IDO strips statics), then waits for the intro to end
  and for Mario to stand still. It then requests a level change through the
  game's own `sWarpDest` path. The poke happens at `initiate_delayed_warp`
  entry, inside the frame, because `play_mode_normal` clears `sWarpDest` at
  the top of every frame. Once Mario is idle in WMotR it saves
  `~/sm64-oracle/wmotr_idle.st`. Only navigation pokes RAM.
- `record.py [N] [seed]`: loads that state and plays seeded random input
  (stick, plus A/B/Z presses). For each call of `execute_mario_action` it stores
  the full RDRAM at entry and the changed bytes at its return site (0x8029CA70
  in `bhv_mario_update`). Output goes to `~/sm64-oracle/rec/<seed>/fNNNN.pkl.zlib`.
- `cannon_probe.py`: pokes Mario next to WMotR's bob-omb buddy, talks and
  advances the dialog with B only, then steers into the opened cannon. On entry
  y goes −2950 → −2730 = lid y − 340 + 350. This showed the cannon entry is
  reachable without A (it is the `wmotr_cannon` Move case; TRUST 0.6/0.8).
  The one poke is a shortcut, not a route.

## The differential test (tether 5.1): does the model do what the game does?

```bash
bash pipeline/build.sh oracle-extract           # extraction of the proved-sound interpreter + the capstones' link
bash experiments/oracle/extract/build.sh introspect && \
  (ulimit -s unlimited; experiments/oracle/extract/drv/introspect > experiments/oracle/extract/boundary.txt)
DRV_DEPS=pp bash experiments/oracle/extract/build.sh replay   # the replay driver (~5 min)
python3 experiments/oracle/record.py 300 2      # 300 real frames, seed 2 (~1 min)
python3 experiments/oracle/difftest.py 2        # replay every frame through the model (~40 min)
ROM_SIZED=1 python3 experiments/oracle/difftest.py 2   # same, past the gMarioAnims finding (below)
```

`boundary.txt` (the link's externals) must be regenerated, and the frames
re-recorded, whenever the link changes: the recorder logs only calls to functions
outside the link. The link is `LinkedTwelve.tu_rest` (35 TUs since 2026-10-22).

For each recorded frame, `extract/drv/replay.ml` does the following:
1. **Builds a CompCert memory from the real RAM.** Each global of the link
   gets its own block, with contents taken from its real address. Addresses come
   from the ROM map. Statics come from each linked `.o`'s `.mdebug` (`mdebug_statics.py`).
   Segmented symbols go through the live `sSegmentTable`. One extra block holds all
   of RAM, for heap memory.
2. **Rebuilds pointers from C types.** It walks every global's type, and the heap
   objects those globals point to (also inside pointer-free buffers such as
   `gMarioAnimsBuf`). Each pointer-typed word becomes a CompCert pointer into the
   block that owns that address. **Address-model normalization** (the model is
   clightgen'd with the `NO_SEGMENTED_MEMORY` identity bodies of
   `segmented_to_virtual` and `VIRTUAL_TO_PHYSICAL`, TRUST.md 2.2): a pointer-typed
   word of the entry RAM that holds a *segmented* address (0xSSoooooo) or a
   *physical* one (below 4 MB) becomes a pointer to the object the ROM's own
   `segmented_to_virtual` maps it to (segment 0 = physical). A word in ROM space
   that lies in a linked ROM symbol (`gMarioAnims`, the anim DMA source) becomes a
   pointer into that symbol's block. All are counted. Bytes a replayed call writes
   (e.g. a DMA'd anim header, whose fields are file offsets) are never normalized.
3. **Runs `execute_mario_action`** with the extracted interpreter (`ex_call`, proved
   sound against `ClightBigstep`).
4. **Replays external calls.** A call to anything outside the link must match the
   real game's next call: same callee and same argument words (o32 convention). The
   real call's memory effects and return value are then applied. Model locals passed
   by address (out-params like `&floor`) are bound to the real stack address for that
   call. Only the game thread's calls are recorded: other threads run while it
   blocks in `osRecvMesg`, and libultra functions are now externals of the link.
5. **Compares the final memory** with the real RAM at return. This covers every placed
   global (about 890 KB with the 35-TU link) and every typed heap object, plus each
   DMA destination, byte by byte. A model pointer and a real word are equal under the
   same normalization (`virt(real) = model address`); each such word the frame wrote
   is printed (`NORM ... written this frame`). Not compared: the thread stacks
   (`gThread5Stack` is the game thread's machine stack, which the model keeps in
   CompCert stack blocks) and `OSThread` save areas (the OS writes them on every
   context switch). It also counts how many of the changed bytes the model computed
   itself, rather than copying them from a replayed call, so a match can't be vacuous.

**Result, 2026-10-22 (35-TU link; seeds 2 and 3, 300 frames each, re-recorded;
15 and 16 distinct actions).** The external calls left per frame are now only
`sqrtf`, the audio calls and the libultra DMA calls (`osInvalDCache`,
`osPiStartDma`, `osRecvMesg`): collision, `math_util`, `memory.c` and the rest run
as generated Clight.

| outcome | seed 2 | seed 3 | seed 2, `ROM_SIZED=1` | seed 3, `ROM_SIZED=1` |
|---|---|---|---|---|
| MATCH: same calls, same arguments, byte-identical final memory (modulo the normalization) | 62 | 15 | **300** | **300** |
| DIFF: completed with different memory | 0 | 0 | 0 | 0 |
| DIVERGE: different external-call sequence or arguments | 0 | 0 | 0 | 0 |
| STUCK: model has no execution | **238** | **285** | 0 | 0 |

**FINDING (vacuity, 2026-10-22): `load_patchable_table` has no CompCert execution
on real states.** Every STUCK frame, 523 of 600, stops at the same place:
`if (addr != list->currentAddr)` (`memory.c:575`), on every call of
`set_mario_animation` / `set_mario_anim_with_accel` with a valid anim id, not only
on anim loads. `setup_game_memory` (`game_init.c:629`, linked) passes `gMarioAnims`,
so `table->srcAddr` and every `addr` / `currentAddr` derived from it point into the
`gMarioAnims` block. That block has **size 0**: `extern u8 gMarioAnims[]` has no
definition in the link (the anim data is reached only by DMA from ROM;
`mario_anim_data.v` is generated but not linked). CompCert compares pointers only
when both are weakly valid, and no offset of a size-0 block is, so the comparison
has no semantics (also against the boot value `NULL`). The size-0 sweep
(`tools/size0_globals.py`) misses it because no linked function names
`gMarioAnims` in a load or store; the only use is `&gMarioAnims` at boot.
The capstones are not false, but for real WMotR states they are silent on about
80% of frames. Candidate repair: give `gMarioAnims` storage of its real extent
(a 2.4-style completion, or link `mario_anim_data.v`).

`ROM_SIZED=1` gives the `gMarioAnims` block its ROM extent (0x8DC20 bytes) **in the
harness only**. With it every frame of both seeds matches. The 33 (seed 3: 41) anim-load frames each
write two words under the expected normalization, `anim->values` (+0xc) and
`anim->index` (+0x10) of the relocated anim in the DMA buffer: the ROM stores the
physical address, the model a pointer to the same byte. This is the same count as the
33 STUCK frames of 2026-09-26. Completed frames change about 42 bytes of placed
globals, about 41 of them computed by the model. **STUCK must stay 0** (with
`ROM_SIZED=1` until the finding is repaired; then without): it is the regression
gate for UB and size-0 sites.

History: 2026-09-26, 12-TU link, seed 2: 267 MATCH and 33 STUCK
(`VIRTUAL_TO_PHYSICAL` as `ptr & 0x1FFFFFFF`, undefined on a pointer), then 300 MATCH
with the `ptr - 0x80000000` rewrite. That rewrite was replaced on 2026-10-22 by the
identity (TRUST.md 2.2), which this run's normalization covers. Pre-2026-10-22
recordings (12-TU boundary) are kept in `~/sm64-oracle/rec/{1,2}-pre1022`.

## Height-cell write watch (tether 5.4): which code writes Φ's cells?

```bash
python3 experiments/oracle/ywatch.py --learn              # once: Mario's object address in the savestate
python3 experiments/oracle/ywatch.py 3000 1 noA           # 3000 Mario frames, 300-frame episodes
python3 experiments/oracle/ywatch.py 3000 11 noA box2424  # episodes start at the K = 2424 box top (pos poke)
python3 experiments/oracle/ywatch.py 4000 21 macro box2424w  # scripted sequences; `w` sets the wing-cap save flag
python3 experiments/oracle/ywatch.py 2400 41 boxsk box2424w  # one slide kick per episode from the box top
python3 experiments/oracle/ywatch.py --summary ~/sm64-oracle/ywatch/noA-*.jsonl
```

Memory write-watchpoints (not single-stepping) on the cells `HeightInvariant.read_cells`
reads, over whole frames. Each store is logged with its PC, function (and caller for
`vec3f_copy`-style helpers), inside/outside `execute_mario_action`, old and new value,
and the level. The summary flags a value-changing height write by a writer outside
the Move catalog, and a pos[1] change outside `execute_mario_action`. Frames that end
outside WMotR are set aside: they are not steps of the capstone's run
(`HeightFrame.in_wmotr`). Re-run 2026-10-22 (`ywatch.py 2000 61 noA`): 2000 WMotR frames, 0 flags, Φ's numeric part held at all 2000 frame ends. Found so far: falling off WMotR sends Mario to the castle
grounds at y = 4500, which is why the run is one visit.

Every frame-end record also carries all of Φ's cells, and the summary evaluates Φ's
numeric part on it (`phi_check.credit`). That checks the value claim, not just which
writer ran. Policies: `noA` is random B/Z/stick; `macro` plays scripted sequences
(runs, slide kicks, dive + B rollout, ground pounds, turns); `boxsk` settles and slide
kicks once. Scripted policies advance once per Mario frame, because the game polls once
per two VIs and a one-VI pulse can be missed. **Trap:** without the wing-cap save flag
the wing-cap boxes are intangible outlines (`exclamation_box_act_1`), so a plain `box*`
spot never stands on a box. Use the `*w` spots for the K = 2424 case.
The `pole` and `buddy` spots start next to the low pole and the cannon-island buddy.
They exercise W's object clause (`objs_bad`), which reads Mario's collided objects at every `execute_mario_action` entry.

Gotchas: the core rebuilds its memory handlers when emulation starts, so write
watches must be added while running (unlike PC breakpoints). The store's new value is
read one instruction later (the watch fires before the store lands).

## Gotchas (learned the hard way)

- Register breakpoints **before** `run()`. Adding one mid-run invalidates the
  cached interpreter's blocks under the executing instruction, and the core
  dumps.
- Savestates are written on a background thread, so don't stop the core until
  the gzip is complete.
- A `STATE_LOAD` at VI 1 is too early. Load at about VI 60.
- The speed limiter has to be switched off through `CORE_STATE_SET` once the
  emulator is running.
- The core allows at most 128 breakpoints. External calls are therefore caught by
  single-stepping inside `execute_mario_action` (debugger STEPPING state, a Python
  callback on every instruction). That takes about 0.2 s per frame.
- `play_mode_normal` clears `sWarpDest` at the top of every frame, so a warp poke
  has to happen inside the frame, at `initiate_delayed_warp`.
- Sizes of `extern T x[]`: distance to the next ROM symbol, capped at the end of its
  section, except that `gCosineTable` lies inside `gSineTable` (with AVOID_UB,
  `math_util.h` makes it `gSineTable + 0x400`).
- An out-param often keeps its value across the call, so it is missing from the diff.
  The recorder therefore also saves the 64 bytes behind each pointer argument at
  return.

## Observed so far (feeds the trust ledger)

- During one `execute_mario_action` call, the Mario structs are not the only
  thing that changes. The PI manager thread, DMA into `gMarioAnimsBuf`
  (animation loading), thread save areas and `gZBuffer` also change.
  Concurrent writers are real (row 3.3). The comparison must be restricted to
  state the game thread owns.

## Setup (outside the repo, `~/sm64-oracle/`)

```bash
git clone https://github.com/mupen64plus/mupen64plus-core
git clone https://github.com/mupen64plus/mupen64plus-rsp-hle
make -C mupen64plus-core/projects/unix all DEBUGGER=1 DEBUGGER_NO_DISASM=1 OSD=0 VULKAN=0 NO_ASM=1
make -C mupen64plus-rsp-hle/projects/unix all
API=mupen64plus-core/src/api
gcc -shared -fPIC -O2 -I$API -o oracle-input.so <repo>/experiments/oracle/input_plugin.c
gcc -shared -fPIC -O2 -I$API -o oracle-video.so <repo>/experiments/oracle/video_plugin.c
git clone <repo>/vendor/sm64 decomp && cp <baserom.us.z64> decomp/ && make -C decomp VERSION=us COMPARE=1
```
