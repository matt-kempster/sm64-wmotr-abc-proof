# Pedro-Coq

Rocq/Coq + CompCert Clight project for the Super Mario 64 Pedro-spot RNG
question. The source of truth is the pinned decompilation commit
`9921382a68bb0c865e5e45eb594d9c64db59b1af`; `generated/*.v` is produced by
CompCert 3.15 `clightgen`, never hand-edited.

Only the North American and Japanese retail configurations are in scope:

- `VERSION_US`
- `VERSION_JP`

EU, Shindou, and iQue are intentionally unsupported.

## Current theorem boundary

`Pedro.Proofs.MainTheorem.checked_pedro_rng_mechanism_us_jp` is the initial
load-bearing capstone. It combines mechanically checked facts about:

1. the close-floor/ceiling branch of `perform_air_quarter_step`;
2. the analog/no-analog branches and strict `forwardVel > 16.0f` dust gate in
   `common_landing_action`;
3. the dust-to-white-puff-to-`random_u16` source chain; and
4. exact binary32 witnesses showing that analog and neutral input can land on
   opposite sides of the dust gate for every flat-floor deceleration class.

`Pedro.Proofs.MainTheorem.checked_ttc_spinner_source_reduction_us_jp` adds the
TTC spinner inventory, collision-array, speed-table, behavior-script, and
random-mode source receipts. It also contains an executable, source-derived
geometry certificate for pitch values 15,856 through 15,951 and the exact
random-mode timer/direction model.

`Pedro.Proofs.MainTheorem.checked_dust_source_projection_us_jp` adds the new
dust-chain result. Given an initially clear active-dust bit and an isolated
object reserve of at least three, it combines generated Clight receipts, a
CompCert symbol-level structural link, decoded behavior scripts, and an
executable normal-list projection. That projection computes three successful
allocations, same-frame Mist/WhitePuff1/WhitePuff2 execution, active-bit
clearing, and four dust-owned PRNG calls on the tap frame. The whole seed is
`R^4(seed)` only under the separate no-intervening-consumer premise.

`Pedro.Proofs.MainTheorem.checked_dust_frontier_reductions_us_jp` tightens the
three open retail premises without relabeling them as solved. It adds a real
CompCert big-step for the exact generated scalar `random_u16` function at the
initialized zero seed; generated US/JP receipts for the TTC loader chain and
the exact descriptor inventory `110 + 9 + 1 = 120`; a normal-frame clear-bit
reduction; and an interference-aware equation in which the dust episode gives
two exact two-call pairs and the global result is `R^(4+k)(seed)` for a
certified non-dust count `k`. Generated macro-prefix and Clight-call receipts
give conditional conservative bounds of 80 calls before spinner 0 and 94
before spinner 7. Those bounds still require a matching live-state snapshot
and a proof that the remainder of the observation window has no uncounted RNG
call.

`Pedro.Proofs.MainTheorem.checked_dust_linked_runtime_census_frontier_us_jp`
advances all three dust-to-PRNG obligations while retaining their evidence
boundaries. For US and JP, a typed CompCert link now executes one exact
generated `cur_obj_update` dispatch cycle: it fetches opcode `0x0C`, reads
`BehaviorCmdTable[12]`, indirectly invokes `bhv_cmd_call_native`, and takes the
real CONTINUE branch. The nested big-step executes
`bhv_white_puff_2_loop`, `obj_translate_xz_random`, two `random_float` calls,
and two `random_u16` calls; from seed zero it stores the successive seeds
57,460 and 55,882, updates the object's X/Z fields, and moves the behavior
cursor from byte 20 to byte 28. The theorem is conditional on an explicit
concrete memory image and stops before the following `ADD_INT`, `END_REPEAT`,
and `cur_obj_update` tail.

`DustParentBitClearExecution.v` executes the exact generated
`bhv_cmd_parent_bit_clear` handler for US and JP under explicit global-symbol,
layout, and memory premises. It follows the spawner's parent pointer, masks bit
1 from Mario's raw-data word at byte 224, proves the mask result clear, and
advances the behavior cursor from byte 4 to byte 12. This is an arbitrary-`genv`
handler theorem, not a typed-link or preceding Mist dispatch/allocation proof.
`checked_static_terminal_frontier_us_jp` separately pairs the TTC static census
with the authenticated retail `sqrtf` receipt.

The same capstone includes a reproducible debug-replay boundary certificate:
all 240 object-pool slots are covered exactly, the isolated reserve is 116,
the dust request is set, the active-dust bit is clear, and time is not stopped.
It also checks ten contiguous `random_u16` calls across frames `F` and `F+1`:
one pre-existing list-2 Bob-omb call followed by four dust-owned calls on each
frame, with every individual seed transition verified. This receipt entered
TTC through the dormant level-select mechanism and observed `TTC_SPEED_SLOW`,
so its Coq projection explicitly proves that it is neither a stock-entry nor a
RANDOM-mode witness.

Finally, a fail-closed generated-Clight census parses the TTC level and
behavior scripts, computes the exact post-PLAYER scheduler roots and their
forward/reverse call closures, checks the one reached indirect Heave-Ho action
dispatch, and proves that `random_u16` is the unique syntactic writer of the
file-local seed. The static terminal frontier is the declared external
`sqrtf`. A separate authenticated retail-byte receipt checks the complete US
and JP leaf as `jr ra; sqrt.s f0,f12; nop; nop` and proves that conservative
instruction recognizers find no nested call or store. This closes that finite
retail opcode question, but it is not a MIPS semantics or a CompCert
`EF_external` refinement. The runtime Bob-omb address bridge is likewise an
audited projection rather than a proved linker/retail refinement.

These theorems are deliberately **not yet the ultimate gameplay claims**. The
remaining semantic and control obligations are listed in
[`docs/checklist.md`](docs/checklist.md). In particular, a syntax receipt is not
a proof that the corresponding Clight path executes, and the TTC random-mode
source describes a bounded oscillation rather than a platform that stays at one
mathematically fixed angle. The widened 368-unit geometry interval admits one
selected 200-unit post-pause motion, but the second movement necessarily exits,
so it is not yet a complete preservation witness. The
typed Clight frontier now executes one actual `cur_obj_update` dispatch cycle
and its WhitePuff2 RNG subtree. Separate US/JP big-steps also execute the exact
accepted branch of `spawn_particle`: they read the clear guard, set the active
bit, and issue the generated allocation and position-copy calls with their
exact arguments. Those two callees remain explicit execution and preservation
premises, so this is still not a complete retail-frame execution: the remaining
command loop and function tail, list scheduler, Mario particle dispatch,
Mist-script dispatch, allocation, and WhitePuff1 remain open. A new US/JP
theorem proves why the generated `segmented_to_virtual` body cannot cross that
next seam in standard CompCert Clight: the pointer-to-unsigned cast preserves a
symbolic `Vptr`, while the first right shift requires an integer. Crossing it
requires an explicit N64-flat-address refinement. A stock
controller-only TTC snapshot, a refinement from runtime addresses to CompCert
memory, the external-function contract, and a reachable Pedro/RANDOM-mode tap
also remain explicit obligations.
The exact event order and premise boundary are summarized in
[`docs/notes/dust-runtime.md`](docs/notes/dust-runtime.md).

## Reproducible generation

The generator archives the pinned commit into `build/pinned-sm64`, then runs
the following command shape for each selected translation unit and each retail
version:

```sh
clightgen -normalize \
  -nostdinc -fstruct-passing \
  -Ibuild/pinned-sm64/include \
  -Ibuild/pinned-sm64/src \
  -Ibuild/pinned-sm64/src/game \
  -Ibuild/pinned-sm64 \
  -Ibuild/pinned-sm64/include/libc \
  -D_FINALROM=1 -DTARGET_N64=1 -DNON_MATCHING=1 -DAVOID_UB=1 \
  -D_LANGUAGE_C=1 \
  <version flags> \
  -o generated/<version>_<unit>.v <source.c>
```

Version flags are exactly:

```text
VERSION_US: -DVERSION_US=1 -DF3DEX_GBI_2=1 -DF3DEX_GBI_SHARED=1
VERSION_JP: -DVERSION_JP=1 -DF3D_OLD=1
```

There are two source preprocessing steps. The first is inherited from the
established repository pipeline because CompCert 3.15 does not parse C
`long double` suffixes. For `src/game/object_helpers.c` only, a generated build
copy is made with this exact command before `clightgen`:

```sh
sed -E 's/([[:digit:]]+\.[[:digit:]]+)([lL])([^[:alnum:]_]|$)/\1\3/g' \
  build/pinned-sm64/src/game/object_helpers.c \
  > build/object_helpers-<version>.c
```

It removes only an `l`/`L` suffix immediately following a decimal literal;
the archived `object_helpers.c` itself is never edited.

The upstream build derives `level_headers.h` from
`levels/level_headers.h.in`. For `levels/scripts.c` only, the proof generator
reproduces that rule inside the archived source tree with this exact command:

```sh
cc -E -P -x c -I build/pinned-sm64 \
  build/pinned-sm64/levels/level_headers.h.in |
  sed -E '/^[[:space:]]*$/d; s|(.+)|#include "\1"|' \
  > build/pinned-sm64/levels/level_headers.h
```

That translation unit alone receives the additional preprocessing flag
`-Ibuild/pinned-sm64/levels`. The generated header contains 31 include lines;
its SHA-256 digest at the pinned revision is
`fdfe0de8afdb3c751251a6ecbe10ef5b109b3b6711a9b430a32a88641a5d958c`.
Generation fails closed unless both that exact line count and digest match.

The complete command construction, source list, pinned revision check, path
normalization, and private string-literal atom prefixing are in
[`pipeline/generate-clight.sh`](pipeline/generate-clight.sh) and
[`pipeline/clightgen.sh`](pipeline/clightgen.sh). The latter also normalizes line
endings, removes trailing horizontal whitespace, and removes trailing blank
lines; these formatting-only operations make committed output platform-stable.

## Build and audit

The known-good switch is `sm64-item-proof` (override with
`SM64_PROOF_SWITCH`). Do not invoke a host `coqc` directly.

```sh
make generate
make reproducible
bash pipeline/build.sh proofs
make no-admitted
make assumptions
make check
```

`make reproducible` performs two clean generations and compares SHA-256
manifests. `make check` runs that reproducibility check, validates the committed
TTC runtime receipts against their Coq projection, builds every listed proof,
rejects proof holes and unconstrained declarations, and prints the assumptions
of all checked capstones. Proof compilation defaults to one job because the
generated call-closure census is memory-intensive; set `COQ_JOBS` explicitly
to opt into more parallelism.

The default decomp checkout is `../../reference-sm64-decomp`; set
`SM64_SOURCE` to another Git checkout containing the pinned commit if needed.
