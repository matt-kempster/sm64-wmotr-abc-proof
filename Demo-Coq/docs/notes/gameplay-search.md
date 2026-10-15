# Normally reachable demo desync search

## Verdict and scope

The all-gameplay claim remains **OPEN**. This investigation has not found a
normally reachable episode in which an authentic demo input stream runs in a
different level. Its source observations and finite retail-ROM experiments
are not a global Coq invariant or a reachable counterexample.

The source reviewed below is the pinned tree at
`9921382a68bb0c865e5e45eb594d9c64db59b1af`, rather than the neighboring decomp
checkout's modified working files. Both US and JP retail configurations are
in scope; differences in physics or timing within the correct level do not
meet this project's mismatch definition.

## Additional source exclusions and their boundaries

**Dispatch correction:** the authentic US stream file `bitdw.bin` has header
30, which the pinned `level_table.h`/`levels/level_defines.h` enumeration maps
to `LEVEL_BOWSER_1` and folder `bowser_1`. `LEVEL_BITDW`, the obstacle course,
is 17. The earlier seven-script census checked `levels/bitdw/script.c` while
omitting `levels/bowser_1/script.c`, so it did not cover the first US demo's
actual selected level. This is a scope correction, not a demo mismatch:
live terrain bytes identified Bowser's arena, consistent with header 30.
The corrected generated-script census must include Bowser 1 before making a
coverage statement about every actual US demo level.

`lvl_init_from_save_file` (`src/game/level_update.c:1230-1269`) is the demo
startup route's common initializer. Before returning its level argument it
resets `sWarpDest.type` to not warping, clears `sDelayedWarpOp`, clears
`gCurrCreditsEntry`, and sets `gCurrLevelNum` from that argument. Thus a stale
ordinary warp or credits destination from an earlier gameplay session is not
an independent level selector on this source route. This is a source/dataflow
observation; complete interpreter execution and indirect memory framing are
still required for an all-runs semantic theorem.

The regular and game-over heads both call `run_level_id_or_demo`, then follow
the same `script_intro_L4` route for a demo header return
(`src/menu/title_screen.c:152-218`, `levels/intro/script.c:45-93,146-153`).
The game-over variant therefore does not select a level from a separate demo
index or bypass the common initializer. A game-over-induced change to Mario's
path, RNG or timing is not itself a different-level demo witness.

`play_mode_paused` contains a direct `initiate_warp(LEVEL_CASTLE,1,0x1F,0)`
exit-course path without a demo check (`level_update.c:1010-1029`). It must not
be omitted merely because delayed warps are intercepted. On the ordinary
normal-mode route, however, an active demo receives Start first at lines
963-972. With transition inactive and no delayed warp, that schedules
`WARP_OP_DEMO_NEXT`; `pressed_pause` at lines 205-214 later requires no delayed
warp. If a transition or delayed warp was already active, its guard also
prevents pausing. A complete proof must preserve this sequencing through the
intervening calls and exclude an already pending ordinary `sWarpDest` which
`warp_area` could consume and clear. The common initializer clears that state,
and the delayed-demo interception does not create ordinary warp destinations;
this remains a composition obligation, not a proved pause-unreachability
claim.

`gDebugLevelSelect` is initialized false in `src/game/main.c:55`; its only
other explicit C assignment in the pinned tree sets it false when quitting
level select (`src/menu/title_screen.c:140`). The debug branch precedes demo
interception in `initiate_delayed_warp`, so excluding debug initialization is
material. No ordinary C assignment turning level select on was found.
Frame-advance mode likewise has a handler/dispatch case but no explicit
`set_play_mode(PLAY_MODE_FRAME_ADVANCE)` source call. These are finite source
censuses, not memory-corruption or hardware exclusions.

`run_demo_inputs` overwrites the first controller's stick and ordinary button
values from the stream, retaining only physical Start, and clears the second
logical controller's input. `read_controller_inputs` then copies the resulting
first-controller values to the third logical controller. Thus additional
physical button/stick choices are not a separate movement controller during
an ordinary active demo (`src/game/game_init.c:467-578`). Initialization can
map the first logical controller to a connected physical port; this does not
give another port an unmasked stream-selection mechanism.

## Address escape census

A multiline source-token search over the pinned tree's C, headers and assembly
found no explicit unary address-of occurrence for `gCurrLevelNum`,
`gCurrDemoInput`, `gDemoInputListID`, or the level interpreter's private
`sRegister`. The handler address `&gDemoInputsBuf` occurs exactly at
`src/menu/title_screen.c:58` (table load) and
`src/game/game_init.c:633` (initial setup).

This is a possible route toward a generated-program pointer-provenance/frame
lemma, not that lemma. A source regex is not a preprocessed Clight closed-world
certificate. A linked proof must distinguish private atoms, frame all direct
writers, cover external initialization/DMA and every expression that can expose
an address, and maintain pointer capability invariants through memory.

The real target also has flat numeric RDRAM and segmented pointers:
`memory.c:68-90` translates between pointer values, integer masks and segment
bases; `main_pool_init` rounds numeric addresses. `setup_game_memory` also
places the allocated demo buffer in segment 24 (`game_init.c:631-633`). A proof
that scalar-global pointers cannot be synthesized inside defined symbolic
CompCert execution must not silently become a retail hardware no-alias claim.
Real-address refinement and external contracts remain separate obligations.

## Finite retail-ROM observation workflow

The new read-only observer lives in
`instrumentation/demo-desync-search/`. It boots SHA-1-authenticated retail ROMs
with fresh emulator configuration/save-data directories, byte-matches each
initial stream to its ROM source, checks subsequent record pointer/timer/input
progression, and observes actual `update_level` entries with same-frame demo
input. Runtime code hashes check the two observed routines against the
existing authenticated matching ELF cache. No cheats, state loading or game
memory/register writes are used. Derived raw data remains in ignored trial
directories; only hashes/metadata should be published.

The first US smoke run reached the authentic `bitdw.bin` stream (Bowser 1
arena, header 30) and observed 701
active-demo `update_level` entries, all with level 30 and no observer error.
This was a harness check. The full idle-cycle trials subsequently completed:

| Retail configuration | Rendered-frame cutoff | Episode starts | Active-demo update entries | Level/header mismatches | Observer errors |
| --- | ---: | ---: | ---: | ---: | ---: |
| US, neutral controller from boot | 14,500 | 9 | 6,746 | 0 | 0 |
| JP, neutral controller from boot | 12,500 | 8 | 5,587 | 0 | 0 |
| US, one physical Start poll at update-relative frame 20 | 6,600 | 7 | 287 | 0 | 0 |
| JP, one physical Start poll at update-relative frame 20 | 5,700 | 6 | 246 | 0 | 0 |

US observed all seven selected stream files (`bitdw`, `wf`, `ccm`, `bbh`,
`jrb`, `hmc`, `pss`) and repeated `bitdw`/`wf`.
JP observed all six (`wf`, `ccm`, `bbh`, `jrb`, `hmc`, `pss`) and
repeated WF/CCM. Every episode's initial buffer matched its authentic stream
byte for byte. Every observed area had null painting and instant-warp tables.
The record-bound, pointer/timer-progression, input-byte and loaded-code checks
reported no errors. The final observer additionally authenticated the first
256 live terrain bytes on every observed update against the corresponding
named terrain data: Bowser 1 for the `bitdw` recording, and WF, CCM, BBH, JRB,
HMC and PSS for their recordings. Expected terrain ELF bytes were checked
against MIO0 decompression of the authenticated retail ROM; the prefixes are
distinct among the nine US/eight JP declared demo areas. This identifies the
observed terrain prefix independently of `gCurrLevelNum`, without proving the
entire geometry or uniqueness against arbitrary non-demo/corrupted buffers.
The metadata-only
[receipt](../../instrumentation/demo-desync-search/results.json) includes ROM,
ELF, observer and trace hashes and per-episode frame counts.

The interruption trials also covered every selected stream. Each episode
received one physical Start poll twenty global frames after its first
`update_level` entry and returned to the title route. The reports contain
seven US and six JP actual Start polls; they do not enumerate every possible
Start timing. Each observed episode lasted 41 active-demo update entries,
including the outgoing level-transition entry.

The observed function entries were also verified as actual retail MIPS code
before launch: US `run_demo_inputs` at `0x80248498` (ROM offset `0x3498`, 104
words) and `update_level` at `0x8024B9B8` (`0x69B8`, 53 words); JP entries at
`0x80248468` (`0x3468`, 104 words) and `0x8024B818` (`0x6818`, 53 words).
The full routine byte sequences matched the authenticated ROM at the main
segment load offsets, then runtime checksums checked those loaded routines
before installing the breakpoints. Their SHA-256 hashes are in the receipt.
The summary checker additionally requires each trial's observer and runner
source hashes to match the current files and checks final counters against
every parsed observation.

These finite counts include normal and change-level play modes, and do not
assert a physics update on every entry. They cover the stated neutral-boot
histories, not arbitrary prior gameplay, save contents, all physical Start
timings or hardware executions. The gameplay claim remains **OPEN**.
