# What the public NA VC assembly establishes

Research snapshot: 19 October 2026. Public source checkout:
`build/research/vc64-decomp`, commit
`e28658f6e520c01c6fca8c0aebe24902d9f82505` of
<https://github.com/nim-ka/vc64-decomp>. Its README explicitly targets the
**North American** SM64 Wii VC `00000001.app`. Its expected built executable
SHA1 is `e0c57e067725c662fd603eb1ff8d777421e69b03`. That NA executable has
not been rebuilt or authenticated locally. Later in this session the user
supplied Japanese and European VC ZIPs; the following image checks bind the
relevant source windows directly to those supplied executables.

Run the source-only receipt checker from the proof repository root:

```text
python SSL-Coq/less-than-one-a-press/instrumentation/teleporter-wrong-warp/vc-na-source.py build/research/vc64-decomp --output SSL-Coq/less-than-one-a-press/instrumentation/teleporter-wrong-warp/vc-na-source-evidence.json
```

The checker compares source file bytes with their pinned Git blobs and records
493 literal PPC words across 26 fragments. It does **not** certify their
execution or a console binary. The corresponding upstream assembly URLs and
line numbers are in the JSON receipt.

## Supplied Japanese/Shindou and European images

`vc-wad-check.py` reads only the explicitly named ZIP's WAD member, never
extracts arbitrary ZIP paths, verifies every decrypted content against its
TMD SHA1, and writes plaintext only under `build/research/vc-images/`.
`vc-japan-wad.json` and `vc-europe-wad.json` retain archive, WAD, emulator,
ROM and content hashes. All seven content digests pass in each package.
The Japanese ticket has a noncanonical common-key-index byte (`203`);
the standard Wii common key nevertheless decrypts all its contents to their
exact TMD digests. Neither signature chain has been verified; TMD consistency
does not establish an intact Nintendo signature chain or unmodified packaging.

| Supplied title | Emulator SHA1 | Embedded game ROM SHA1 |
|---|---|---|
| Japanese `000100014e41414a` | `0e59d95268ecdf213807f7126d7c7a24875cfb1b` | `3f319ae697533a255a1003d09202379d78d5a2e0`, exact stock Shindou |
| European `000100014e414150` | `4d65a6aabcc9d902df6a84ad53e3c7619a85b4fb` | `4ac5721683d0e0b6bbb561b58a71740845dceea9`, exact stock PAL |

Both ROM hashes match the decomp's independent `sm64.sh.sha1` and
`sm64.eu.sha1`. The embedded uncompressed ROMs are separately extracted for
existing game instruction checkers; no emulator or game executable is added
to source/evidence publication.

`vc-image-check.py` gates both supplied emulator SHA1/SHA256 values, verifies
agreement with the WAD content receipts, maps virtual addresses through each
DOL header, and records 493 words per region. The relevant LBU interpreter,
default byte reader, low-address JIT specialization guard/fallback,
delay-slot markers, mode/interrupt gates, wrapper spill/reload generators,
and JAL delay-first compiler fragments are byte-identical to the NA source.
Their Japanese addresses match the NA addresses and European addresses are
`+0x10`. Other fragments' relocation differences are explicit in
`vc-supplied-images.json`; no whole-emulator equivalence is inferred.
The instruction literal arrays and wrapper register map in
`proofs/TeleporterVcFailedLoad.v` are checked directly against both supplied
images by name.

## Exact failed-read continuation

The relevant behavior is more precise than a generic exception-handler rule.
In this NA assembly, the default system read callback returns failure, and the
interpreter skips destination-register writeback when that callback fails.
No architected MIPS address-exception vector is entered by this callback.

| Assembly locations | Concrete evidence |
|---|---|
| `func_8000C560`, `0x8000C578`, `0x8000C590` | Default byte read writes zero to its output temporary, obtains the emulated PC through `func_8003DEA4`, then returns false. The zero output is not automatically a guest-register write. |
| `func_8000D0C0`, `0x8000D2F0`–`0x8000D31C` | Registers the byte/halfword/word/doubleword default read callbacks, including `func_8000C560`. |
| `func_8003D750`, `0x8003D750`–`0x8003D764` | Stores these callback addresses in the device's offsets `0x0C`/`0x10`/`0x14`/`0x18`. |
| `func_800365CC`, `0x80036650`, `0x8003665C` | Interpreter records `input game PC + 4` in the CPU's `nPC` field before dispatching the instruction. |
| `func_800365CC`, `0x80039FF4`–`0x8003A050` | LBU computes its effective address, chooses a device through the 64-KiB-page table, calls that device's byte-read callback, then tests the callback's return value. |
| `0x8003A038`/`0x8003A03C` | `cmpwi r3,0; beq 0x8003A894`: a failed callback branches straight to the interpreter tail. The only LBU guest-register store, at `0x8003A04C`, is skipped. |
| `func_8003DEA4`, `0x8003DEF4`–`0x8003DF00` | The helper called by the default reader reads CPU `nPC` and writes it into the supplied local diagnostic buffer. Its ordinary successful path does not set an exception vector. |

The default system mapping appears in `asm/data.s`, at
`lbl_8016C658`'s record 7 (zero-based): the record's type is zero, its object
class is `lbl_8016E7F0`, and its one physical-address range is
`0x00000000`–`0xFFFFFFFF`. `func_8003D2D8` installs that default across the
device page table. Ordinary RAM devices are separately installed in the
cached/uncached high virtual-address segments. A complete runtime theorem
would also justify that no subsequent TLB or device remapping changes the
selection of the default device for effective addresses 1, 2, and 3.

## JIT does not justify silently skipping its machinery

The CPU's generated-code link initialization in `func_8003C774` links CPU
offset `0xB48` to interpreter `func_800365CC`, and offset `0xB58` to
load/store specializer `func_8003ACB0`.

`func_80010760`'s LBU compiler starts at `0x8002A8FC`. It first has an
optimization for a base register flagged as RAM (`nFlagRAM`). Otherwise,
compile-flag `0x10` calls the load/store specializer through CPU offset
`0xB58`; compile-flag `1` has a separate device-index fast path and interpreter
fallback. Those flag and optimization conditions are material runtime state.

In the specializer, `0x8003AD58`–`0x8003AD6C` marks any unsigned effective
address below `0x80000000` for interpretation and branches to `0x8003B810`.
This includes null-node byte offsets 1, 2, and 3. The fallback at
`0x8003B810`–`0x8003B848` emits the game's instruction address into PPC `r5`
and a linked branch to the CPU's interpreter link at offset `0xB48`.
The fallback is not a successful RAM load returning zero.

The JIT explicitly emits `nWaitPC` markers around a delay-slot fallback and
the wrapper in `func_8003C540` saves and restores mapped guest registers.
The actual register-map tables are checked at Japanese `0x8016D3B0` and
European `0x8016DCD0`: guest `a0`/`a1`/`a2`/`a3` map to PPC registers
15/16/17/18, with spill/reload slots at CPU offsets `0x6C`/`0x74`/`0x7C`/`0x84`.
The wrapper takes its continuation from PPC LR through its C helper return,
and reloads the mapped argument registers from those CPU slots. The JAL
compiler processes the nonzero delay instruction before emitting the call.

For a compiled delay-slot fallback the marker is zero, so the interpreter
clears `nMode` bit 8. `cpuExecuteUpdate`'s ordinary interrupt path is gated
by that bit and is suppressed in this case. A failed LBU does not set bit 4;
the update helper's PC-remap call is gated by bit 4. Thus with incoming bit 4
clear, ordinary helper callbacks preserving the necessary state, and valid
generated code, this failed load returns to the generated call continuation.
These runtime premises matter: the finite image checks do not discharge them.

The interpreter's JAL case at `0x800374E4` sets guest `$ra` to PC+8 and writes
the destination to CPU `nWaitPC`. This is evidence of intended delay handling,
not an end-to-end theorem covering the game's JAL-delay-slot LBU. The main
emulator dispatch, wrapper, branch scheduling, fast-path validity, and
runtime device selection must be covered before the local failed-read fact
can be applied to every successful wrong warp.

## Discoverer's first-party account

The discoverer's account at <https://nim.cx/p/wrongwarp> links
<https://www.youtube.com/watch?v=YduutOI7uxY>. The video description was
retrievable directly as HTML, although the web reader could not open YouTube.
It identifies the demonstration as PAL Wii VC. It says sign reading can
make stale `a1` equal 2, and the stale `a2` pointer can be manipulated. The
description also discloses three demonstration hacks: teleporter relocation,
an action change enabling earlier handsfree Chuckya holding, and setting
`a2` to `0xF8`. The author asserts stock achievability of these ingredients;
this is not an unmodified, authenticated replay. In particular, the video
does not establish a reachable SSL Area 2 arrival, an item-retention
counterexample, or an all-origin reset theorem.

## Initial local executable search boundary

No Wii VC WAD, DOL, or `00000001.app` was found in the workspace and bounded
Windows folders inspected (Downloads, Documents, OneDrive Documents,
Saved Games, and common Dolphin settings locations), or in
Ubuntu-24.04 `/home` to maximum depth 6. This was a bounded inventory result
before the user supplied ZIPs, not proof that the user had no executable
elsewhere. The later supplied files and their verified extraction supersede
that initial absence. No console binary was downloaded externally.
