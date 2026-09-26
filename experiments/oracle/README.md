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

## The differential test (tether 5.1): does the model do what the game does?

```bash
bash pipeline/build.sh oracle-extract           # OCaml extraction of the proved-sound interpreter + 12-TU link
bash experiments/oracle/extract/build.sh replay # (DRV_DEPS=pp) compile the replay driver
python3 experiments/oracle/record.py 300 2      # 300 real frames, seed 2 (~1 min)
python3 experiments/oracle/difftest.py 2        # replay every frame through the model (~5 min)
```

For each recorded frame, `extract/drv/replay.ml` does the following:
1. **Builds a CompCert memory from the real RAM.** Each global of the twelve-TU link
   gets its own block, with contents taken from its real address. Addresses come
   from the ROM map. Statics come from each `.o`'s `.mdebug` (`mdebug_statics.py`).
   Segmented symbols go through the live `sSegmentTable`. One extra block holds all
   of RAM, for heap memory.
2. **Rebuilds pointers from C types.** It walks every global's type, and the heap
   objects those globals point to. Each pointer-typed word becomes a CompCert
   pointer into the block that owns that address.
3. **Runs `execute_mario_action`** with the extracted interpreter (`ex_call`, proved
   sound against `ClightBigstep`).
4. **Replays external calls.** A call to anything outside the link must match the
   real game's next call: same callee and same argument words (o32 convention). The
   real call's memory effects and return value are then applied. Model locals passed
   by address (out-params like `&floor`) are bound to the real stack address for that
   call.
5. **Compares the final memory** with the real RAM at return. This covers every placed
   global (about 27 KB) and every typed heap object (about 53 KB), byte by byte. It
   also counts how many of the changed bytes the model computed itself, rather than
   copying them from a replayed call, so a match can't be vacuous.

**Result (seed 2, 300 frames of random input, 15 distinct actions including
jumps, double jumps, jump kicks, crouch-slides and crawling):**

| outcome | frames |
|---|---|
| MATCH: same calls, same arguments, byte-identical final memory | **267** |
| DIFF: completed with different memory | 0 |
| DIVERGE: different external-call sequence or arguments | 0 |
| STUCK: model has no execution | 33 |

All 33 STUCK frames have one cause, and it is real (TRUST.md 3.2).
`set_mario_animation` and `set_mario_anim_with_accel` run
`VIRTUAL_TO_PHYSICAL(ptr)`, which is `(uintptr_t)ptr & 0x1FFFFFFF`, whenever a new
animation has just been DMA-loaded. Bitwise AND on a pointer is undefined in
CompCert C, so these frames, about 11% of real play, **have no CompCert execution**.
The game runs them fine. Completed frames change about 29 bytes of placed globals,
and about 18 of those are computed by the model.

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
