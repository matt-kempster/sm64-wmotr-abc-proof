# Real Bob-omb animation data in both selected programs

Date: 29 October 2026. Baseline: `18765cf81dfeaf2b489183876a1db6162578d6f8`.
Pinned SM64 source: `9921382a68bb0c865e5e45eb594d9c64db59b1af`.
Validated integration source:
[`dff3531`](https://github.com/tra38/sm64-wmotr-abc-proof/commit/dff3531af566f37a3d48fd444e883a257a237846).
Preparation checkpoints `e2d4e53`, `8508fa9` and `fb586d0` retain the generated
inputs, initial positive certificate and source-census maintenance.

This follows the [missing-data audit](bobomb-animation-link-audit.md).
Both selected programs now contain the real Bob-omb animations. Their
construction, positive data/initialization certificate and MainTheorem pass
the Coq pipeline. The selected integrated audit and the additional standalone
receiver/JP-initialization checks also pass.
No survival or wrong-warp result is claimed.

**Initialization follow-up:** [the separate US/JP initialization proof](bobomb-selected-initialization.md),
validated at `42d55ad`, now supplies successful initialization and the real
table loads together for both selected programs, with no initialization-success
hypothesis. Audit `20261029-135749-oykqytoh` passes all five selected queries.
The conditional table-read lemma and repair receipt below remain the historical
repair record; the new note and receipt record the stronger existence result.
This does not supply boot, scheduled animation execution, survival or a wrong warp.

## Source-faithful change

`inputs/bobomb_animation_data.c` is a data-only slice of `actors/common0.c`.
It retains that file's header order and `make_const_nonconst.h` preprocessing,
then includes the pinned vendor `actors/bobomb/anims/data.inc.c` and
`table.inc.c`. The data file includes the two original animation files. There
are no hand-written animation constants, substituted buffers or synthetic
zero-storage definitions.

The existing generator builds this wrapper with its unchanged US and JP
flags. It is appended as unit38 (zero-based) to `us_units` and `jp_units`:
39 units per version, preserving all original unit indices 0–37. Both selected
programs therefore use the existing normalizer, source-owned cleaned selector,
official JP linker and US viewport repair with the added real input.
Their constructors are not replaced by an ad hoc merged program.

The unchanged external declaration in `behavior_data` still has an empty
initializer. The source-faithful nonempty definition now wins the existing
strong-definition selector. The cleaned inputs retain the definer and remove
the weaker declaration; the selected-variable certificate checks this outcome
on the actual targets. No manual edit of a generated declaration is needed.

The N64 actor source undefines `const` through its original header. The
generated animation globals consequently have `gvar_readonly = false`, as
the source preprocessing requires. The proof does not assume they stay
unchanged during gameplay.

| Generated asset | Initializer bytes |
| --- | ---: |
| `bobomb_seg8_animvalue_08023528` (278 signed16 values) |556 |
| `bobomb_seg8_animindex_08023754` (84 unsigned16 indices) |168 |
| `bobomb_seg8_anim_080237FC` |24 |
| `bobomb_seg8_animvalue_08023814` (76 signed16 values) |152 |
| `bobomb_seg8_animindex_080238AC` (84 unsigned16 indices) |168 |
| `bobomb_seg8_anim_08023954` |24 |
| `bobomb_seg8_anims_0802396C` (two pointers, NULL sentinel) |12 |

The existing 76 generated AST sources are unchanged. A second complete
generation of all 78 files reproduces byte-for-byte. Generated data-unit
programs type-check and are closed under the global context. The exact symbol
manifests now show seven additional definitive variables and one fewer
extern-only variable per version. Normalized total definition counts increase
by six, to 4340 US and 4323 JP: the table identifier already existed.

The source-index utility's expected unit count is updated to 39, and its
refreshed JSON/prose index passes `python pipeline/split_catalog.py --check`
and the five existing scanner tests. Its function/assignment/writer counts
are unchanged: the added units contain only data. Supplemental audio-script
messages no longer hard-code the gameplay unit count; no audio input or
binding changes.

The integration also extends the explicit source-unit lists, composite-only
projections, JP initializer-alignment aggregate and per-unit writer/action-table
checks to include the added input. The predicates are unchanged: the new unit
must satisfy the existing alignment, coordinate-receiver, syntax and private
table checks. These checks inspect the small data translation unit, rather
than reducing whole-program initialized memory. No old unit is dropped and
no gameplay premise is discharged by these coverage updates.

Unlike upstream's broader `BhvVM.closure_data_linked` and
`BhvVM.vm_data_args_linked` censuses, this correction certifies the seven
Bob-omb animation assets in SSL's actual selected targets. It does not claim
that every reachable behavior argument or every object-closure global has
nonempty data. The other actor families added upstream are outside this patch.

## Positive Coq boundary

`proofs/BobombAnimationLink.v` replaces the historical negative certificate
for the old targets. The public entry point remains
`MainTheorem.current_bobomb_animation_link_boundary`, now consuming the
positive `BobombAnimationLinkBoundary`. Old negative statements remain
historically available at the baseline commit; they are not claims about
these enlarged programs.

The active statements are:

```coq
Theorem selected_bobomb_animation_data_check_passes : forall version,
  selected_bobomb_animation_data_linked version = true.

Theorem selected_bobomb_animation_assets_exact : forall version id variable,
  In (id, variable) (bal_assets version) ->
  exists block,
    Genv.find_symbol (Clight.globalenv (selected_clight_target version)) id = Some block /\
    Genv.find_var_info (Clight.globalenv (selected_clight_target version)) block =
      Some variable.

Theorem selected_bobomb_animation_initial_entries : forall version memory,
  Genv.init_mem (selected_clight_target version) = Some memory ->
  exists table_block anim0_block anim1_block,
    Genv.find_symbol (Clight.globalenv (selected_clight_target version))
      bal_table_id = Some table_block /\
    Genv.find_symbol (Clight.globalenv (selected_clight_target version))
      bal_anim0_id = Some anim0_block /\
    Genv.find_symbol (Clight.globalenv (selected_clight_target version))
      bal_anim1_id = Some anim1_block /\
    Mem.load Mptr memory table_block 0 = Some (Vptr anim0_block Ptrofs.zero) /\
    Mem.load Mptr memory table_block 4 = Some (Vptr anim1_block Ptrofs.zero) /\
    Mem.load Mint32 memory table_block 8 = Some (Vint Int.zero).
```

The exact-asset result covers all seven globals, including the animation
records' value/index dependencies. It establishes the actual selected symbol
and variable bindings to their generated definitions, rather than assuming
nonempty storage or merely finding a symbol. The table-read result requires
successful `Genv.init_mem`; it constructs reads from that initialization,
not from a supplied already-readable table.

For JP, the existing initializer-existence theorem also rebuilds on the
enlarged official cleaned target:

```coq
Theorem jp_official_cleaned_initial_memory_exists :
  exists memory,
    Genv.init_mem jp_official_cleaned_slice = Some memory.
```

It has no explicit hypotheses. Combined with the new table-read theorem,
it supplies an initialized JP memory with the real table entries; the JP
initialization premise is therefore satisfiable. This is an initialized-memory
witness, with no object scheduling or normally reached animation call.
The US table-read statement retains its successful-initialization condition.

For downstream use:

```coq
From LessThanOneAPress.Proofs Require Import BobombAnimationLink.
Check selected_bobomb_animation_data_check_passes.
Check selected_bobomb_animation_assets_exact.
Check selected_bobomb_animation_initial_entries.
From LessThanOneAPress.Proofs Require Import JPOfficialInitialMemory.
Check jp_official_cleaned_initial_memory_exists.
```

The [complete certificate](https://github.com/tra38/sm64-wmotr-abc-proof/blob/dff3531af566f37a3d48fd444e883a257a237846/SSL-Coq/less-than-one-a-press/proofs/BobombAnimationLink.v)
contains the full Coq, CompCert and generated-module imports. Its public
aggregate is `bobomb_animation_link_boundary_checked : BobombAnimationLinkBoundary`;
`MainTheorem.current_bobomb_animation_link_boundary` exports that same proposition.

## Reproduction and limits

Use Ubuntu WSL, `sm64-item-proof`, Coq8.16.1 and CompCert3.15, from
`SSL-Coq/less-than-one-a-press`:

```sh
source pipeline/env.sh
ulimit -S -v 6815744
bash pipeline/check-generated.sh
bash pipeline/check-link-hygiene.sh
bash pipeline/build.sh audit-build AUDIT_VO_TARGETS=proofs/BobombAnimationLink.vo
bash pipeline/build.sh audit-build AUDIT_VO_TARGETS="proofs/MainTheorem.vo proofs/InkRetryQuery.vo proofs/InkVerticalRetryGeometry.vo"
bash pipeline/build.sh audit-build AUDIT_VO_TARGETS=proofs/JPCoordinateLvalueReceiverPartition.vo
bash pipeline/assumptions.sh LessThanOneAPress.Proofs.BobombAnimationLink bobomb_animation_link_boundary_checked
timeout 240 bash pipeline/assumptions.sh LessThanOneAPress.Proofs.JPCoordinateLvalueReceiverPartition jp_coordinate_lvalue_receiver_partition_audit_checked
timeout 240 bash pipeline/assumptions.sh LessThanOneAPress.Proofs.JPOfficialInitialMemory jp_official_cleaned_initial_memory_exists
bash pipeline/discipline-check.sh --build-timeout 600 --assumption-timeout 240 LessThanOneAPress.Proofs.MainTheorem current_bobomb_animation_link_boundary LessThanOneAPress.Proofs.MainTheorem current_ink_backward_execution_boundary LessThanOneAPress.Proofs.InkRetryQuery irq_retry_connects_display_to_real_floor_call LessThanOneAPress.Proofs.InkVerticalRetryGeometry ivr_vertical_retry_geometry_checked
```

A cold dependency build can take longer than the selected audit's 600-second
build limit; the targeted staging command above uses the existing pipeline
before the bounded audit. The memory cap stays at 6815744 KB throughout.

**Validation result: PASS.** Selected audit `20261029-124714-_515wa5e`
passes the build, 686-file inventory, proof-hole, link-hygiene, all four
assumption queries and integration checks. Main imports 512 of 606 proof
modules, with 94 registered standalone modules and zero integration
problems. The new animation boundary uses five allowed foundations; the
three established queries retain nine/seven/four. The changed standalone
JP receiver module builds and uses four allowed foundations. The existing
JP initializer-existence theorem uses five. No project axiom is introduced.

The [validation receipt](bobomb-animation-data-repair-validation.json)
distinguishes the successful generator/input checks from the final integrated
proof audit. No limits are lowered to obtain a pass. The positive standalone
boundary uses five allowed library foundations and no project-specific axiom;
explicit theorem hypotheses, including successful initialization, remain
conditions even though `Print Assumptions` does not list them.

This is a source-backed data-link correction. It does not execute a normally
reached Bob-omb behavior, prove script or segmented-address provenance, frame
the animation globals through later stores, establish all other object data,
or discharge the source-to-retail/viewport semantic refinement. The missing
animation-table obstruction is separate from those conditions. Complete
Bob-omb survival, usable Area-2 regrab and a reachable wrong warp remain open.
Mario's render-call frame and teleporter audio, ownership and lifetime work
are unchanged. All 45 route estimates and gameplay verdicts are retained.
