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

These theorems are deliberately **not yet the ultimate gameplay claims**. The
remaining semantic and control obligations are listed in
[`docs/checklist.md`](docs/checklist.md). In particular, a syntax receipt is not
a proof that the corresponding Clight path executes, and the TTC random-mode
source describes a bounded oscillation rather than a platform that stays at one
mathematically fixed angle. The proved geometry interval is too narrow for the
first 200-unit post-pause motion, so it is not yet a preservation witness. The
structural Clight link is also not a complete linked-program execution proof:
reachable tap state, composite-layout refinement, unresolved callees, competing
allocations, and other RNG consumers remain explicit obligations.
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

There is one source preprocessing step, inherited from the established
repository pipeline because CompCert 3.15 does not parse C `long double`
suffixes. For `src/game/object_helpers.c` only, a generated build copy is made
with this exact command before `clightgen`:

```sh
sed -E 's/([[:digit:]]+\.[[:digit:]]+)([lL])([^[:alnum:]_]|$)/\1\3/g' \
  build/pinned-sm64/src/game/object_helpers.c \
  > build/object_helpers-<version>.c
```

It removes only an `l`/`L` suffix immediately following a decimal literal;
the pinned source tree itself is never edited.

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
manifests. `make check` runs that reproducibility check, builds every listed
proof, rejects proof holes and unconstrained declarations, and prints the
assumptions of all checked capstones.

The default decomp checkout is `../../reference-sm64-decomp`; set
`SM64_SOURCE` to another Git checkout containing the pinned commit if needed.
