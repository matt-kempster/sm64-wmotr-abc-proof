# TTC runtime snapshot receipt

This directory contains a deterministic discovery probe for the authentic US
and JP retail ROMs. The input plugin performs no RAM writes. It:

- opens the dormant level-select screen with controller input;
- selects TTC;
- holds the stick forward after entry;
- detects the first frame whose Mario particle flags request dust;
- walks the singly linked free list and all thirteen doubly linked object
  lists;
- checks pointer direction, slot alignment, no duplicate slots, active/free
  consistency, and exact coverage of all 240 pool slots; and
- records each slot's list, active flags, behavior address, action, and timer.

Run:

```sh
./run-probe.sh /path/to/baserom.us.z64 /path/to/baserom.jp.z64
```

The script rejects ROMs whose MD5 and SHA-256 digests differ from the pinned
US and JP images, generates `build/us.snapshot` and `build/jp.snapshot`, and
compares them byte-for-byte with `results/`.

Both receipts observe global timer 414, TTC level 14 area 1, Mario in pool slot
119, `particleFlags & 1 = 1`, the Mario object's active-particle dust bit clear,
`gTimeStopState = 0`, 115 free slots, one UNIMPORTANT object, and 125 active
objects. Hence the allocator reserve is 116. After erasing version-specific
RAM addresses, the slot/list/active/action/timer rows agree between US and JP.

They also observe `gTTCSpeedSetting = 0`, the retail `TTC_SPEED_SLOW` value.
`TTC_SPEED_RANDOM` is 2, so this read-only level-select receipt does not cover
the RANDOM-mode spinner schedule. The authenticated retail addresses of this
setting are `0x80361258` (US) and `0x8035fee8` (JP).

## `random_u16` timing receipt

The probe also installs read-only execute breakpoints at the entry and return
of the retail `random_u16`. Each completed call records the global timer,
return address, current-object pointer/pool slot/list/behavior/action/timer,
TTC speed setting, seed before and after, return value, and Mario's
dust-request and active-dust words. `run-probe.sh` retains every call on the
snapshot frame as `frame=F` and every call on the following frame as
`frame=F+1` in `results/*.rng`.

US and JP have the same normalized ten-event receipt. Each frame contains one
pre-existing list-2 call followed by four calls owned by the two freshly
allocated dust-puff objects (two in list 8 and two in list 12). Calls 33
through 42 are contiguous across the F/F+1 boundary. The seed chain is:

```text
F:   66a4 -> b2b1 -> 2630 -> f84f -> 5994 -> 34f2
F+1: 34f2 -> 99e5 -> 922f -> 69f1 -> 9849 -> 5aa1
```

The checker verifies every individual `random_u16` transition, the return
value, version-specific object and behavior addresses, four dust-owned calls
per frame, and the absence of an unlogged TTC call between F and F+1 as
encoded by the contiguous complete-entry call indices and seed chain.
It also cross-checks the observed list-2 behavior address against the explicit
US/JP Bob-omb projection in `TTCRNGCensus.v`; that projection is not a proof
that a CompCert symbol and a retail virtual address denote the same object.

The PCs were derived from the hash-pinned ROMs, rather than from a modified
build map. The identical 65-word retail body begins at ROM offset `0x100930`
in US and `0x0ff5c0` in JP. Its callsite instruction `0x0c0e0eec` resolves to
entry PC `0x80383bb0`; its `jr ra` is at `0x80383cac`. The seed load/store
pairs use `lui ...,0x8039` with signed offset `0xeee0`, resolving
`gRandomSeed16` to `0x8038eee0`. The probe hashes the complete 65-word body
(`0x0436edbe`) and independently checks every seed access plus the epilogue
before arming either breakpoint. The immediately preceding object-update
instructions encode `gCurrentObject` as `0x80361160` in US and `0x8035fdf0`
in JP.

The symbol addresses were independently authenticated by exporting clean
source at commit `9921382a68bb0c865e5e45eb594d9c64db59b1af`, building matching
US and JP ROMs, and comparing each output byte-for-byte with its baserom. The
output and baserom SHA-256 values were respectively
`17ce077343c6133f8c9f2d6d6d9a4ab62c8cd2aa57c40aea1f490b4c8bb21d91`
and
`9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317`.
Only after those comparisons succeeded were `gTTCSpeedSetting`,
`gCurrentObject`, and `random_u16` read from the clean linker maps.

## Retail `sqrtf` byte receipt

After authenticating each full ROM, `run-probe.sh` extracts exactly sixteen
bytes at US ROM offset `0x000dea50` and JP offset `0x000ddb20`. The committed
`results/*.sqrtf` receipts record the full-image SHA-256, virtual address, ROM
offset, and identical bytes:

```text
03e00008460060040000000000000000
```

`pipeline/check-ttc-runtime-snapshot.py` cross-checks those receipts against
the finite image transcribed in `TTCRetailSqrt.v`. The Coq theorem recognizes
the words as `jr ra`, delay-slot `sqrt.s f0,f12`, and two padding NOPs, and
finds no nested call or store instruction. This is a byte/opcode receipt, not a
MIPS execution semantics or a CompCert external-function refinement.

## Evidence boundary

The configured emulator cheat only enables the retail binary's dormant
level-select screen, but it is still a debug entry mechanism. These receipts
therefore establish reproducible runtime evidence and supply the finite census
and dynamic call projection checked by `TTCDebugBoundary.v` and
`TTCRNGCensus.v`; they do **not** prove stock reachability or a CompCert
execution. The observed request is ordinary walking dust in SLOW mode, not a
Pedro landing tap, and the receipt must not be cited as either a Pedro witness
or a RANDOM-mode spinner witness.

The minimum missing reachability artifact is a controller-only replay from an
ordinary save-file/clock-door entry to a dust-request boundary, together with
either a linked-Clight execution proof or a proved refinement from that replay
to the generated program. Such a replay can replace the entry prefix while
retaining this probe's read-only pool, flag, and time-stop checks.
