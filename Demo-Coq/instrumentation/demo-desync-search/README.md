# Retail demo pairing observer

This finite experiment starts the authenticated US or JP retail ROM from boot
with fresh emulator configuration and save-data directories. It uses ordinary
controller inputs only. The plugin resolves memory-read and debugger-control
exports; it does not resolve a game-memory-write export, load a save state, or
enable cheats. Breakpoints observe the entries of `run_demo_inputs` and
`update_level`; runtime checksums verify those routines against an existing
matching retail ELF before installing the observers. The runner additionally
byte-matches both complete MIPS routines to the authenticated retail ROM at
their load offsets before launching the emulator.

The source pin is `9921382a68bb0c865e5e45eb594d9c64db59b1af`. Matching ELF
metadata is reused read-only from the established authenticated cache in
`Pedro-Coq/instrumentation/ttc-runtime-snapshot/build/retail-map-9921382`.
The running ROM is always the SHA-1-authenticated
`reference-sm64-decomp/baserom.{us,jp}.z64`, and the cached matching ROM must
have exactly the same SHA-256. This reuse adds no findings to Pedro-Coq.

Run in Ubuntu-24.04 WSL from Demo-Coq:

```sh
python3 instrumentation/demo-desync-search/run.py us us_terrain_cycle --video-frames 14500 --timeout-seconds 900
python3 instrumentation/demo-desync-search/run.py jp jp_terrain_cycle --video-frames 12500 --timeout-seconds 900
python3 instrumentation/demo-desync-search/run.py us us_terrain_start_20 --video-frames 6600 --timeout-seconds 900 --start-at 20
python3 instrumentation/demo-desync-search/run.py jp jp_terrain_start_20 --video-frames 5700 --timeout-seconds 900 --start-at 20
python3 instrumentation/demo-desync-search/summarize.py us_terrain_cycle jp_terrain_cycle us_terrain_start_20 jp_terrain_start_20 --write
```

Every trial needs a new name. Derived binaries, emulator data, raw logs and
expected demo bytes remain in the ignored `build/<name>` directory. Publicable
summary receipts contain hashes and metadata only. Do not publish generated
`addresses.h`: it contains temporary expected stream bytes for the byte-exact
comparison.

`DLOAD` records the first consumed record of a new active-demo episode. The
entire named stream must match the authenticated ROM bytes exactly before any
timer is decremented. The record pointer must stay aligned and within that
stream's authentic terminal record. Subsequent calls check the expected timer
countdown, record advancement and stick/button bytes. The short FNV checksum in
`DLOAD` is a display checksum, not the sole identity test.

`DGAME` records an actual `update_level` entry with active demo input, and
connects it to the `run_demo_inputs` observation on that same `gGlobalTimer`
frame. It reports `gCurrLevelNum`, expected header level, current Area pointer,
terrain pointer, independently matched terrain name/level, painting/instant
table pointers, and play mode. Thus title fade
consumption is not counted as gameplay. The observer includes update entries
in normal and level-transition play modes; this is not a claim that Mario's
physics consumes input on every such entry.

Before launch, terrain-data ELF symbol bytes must match the authenticated ROM
geometry segment after MIO0 decompression. Each gameplay observation then
byte-matches the first 256 live terrain bytes to one of those declarations.
These prefixes are checked distinct among the selected demo areas. This
independently identifies their actual loaded terrain prefix and does not infer
it merely from `gCurrLevelNum`; it is still a finite observation, not a proof
of the full geometry, all memory writes, or prefix uniqueness across every
possible non-demo or corrupted terrain buffer.

The runner derives the loaded level folder from the numeric header and pinned
`levels/level_defines.h`. A recording's filename is not a level enum: in
particular, `bitdw.bin` has header 30 (`LEVEL_BOWSER_1`, folder `bowser_1`),
whereas the obstacle course `LEVEL_BITDW` is 17. The US recording correctly
runs in Bowser's arena.

`--start-at N` presses physical Start for one poll N global frames after each
episode's first `update_level` observation (the earliest observable next poll
is N=1). `--start-frames N` extends the hold duration. The no-argument policy
returns neutral controller input from boot.

These experiments can find a concrete candidate and check specific normal
runs. They cannot establish impossibility over all legal histories, all
physical Start timings, save files, RNG histories, or emulator/hardware events.
They are outside Coq, and do not close the gameplay claim.

The summary checker requires complete final observer counters, exact agreement
between those counters and parsed trace records, no observer errors, and
matching SHA-256 hashes for the current `observer.c` and `run.py`. It refuses
to regenerate a current receipt from trials produced by a different source
revision. Keep older trial directories as historical diagnostics.
