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

## Gotchas (learned the hard way)

- Register breakpoints **before** `run()`. Adding one mid-run invalidates the
  cached interpreter's blocks under the executing instruction, and the core
  dumps.
- Savestates are written on a background thread, so don't stop the core until
  the gzip is complete.
- A `STATE_LOAD` at VI 1 is too early. Load at about VI 60.
- The speed limiter has to be switched off through `CORE_STATE_SET` once the
  emulator is running.

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
