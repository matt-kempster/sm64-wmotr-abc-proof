# Bob-omb animation data: selected US/JP link audit

> Historical result for the programs through checkpoint
> `18765cf81dfeaf2b489183876a1db6162578d6f8`. The subsequent
> [real-data linking correction](bobomb-animation-data-repair.md) adds the
> missing assets to both selected programs and replaces the negative active
> certificate with a positive one. The statements and validation receipt
> below describe the old programs. The historical Coq source is preserved at
> [that checkpoint](https://github.com/tra38/sm64-wmotr-abc-proof/blob/18765cf81dfeaf2b489183876a1db6162578d6f8/SSL-Coq/less-than-one-a-press/proofs/BobombAnimationLink.v).

Review date: 29 October 2026. Starting proof checkpoint:
`87caa6637548c7505d82cde1e6764feb0267bdb4`.
Generated C source pin: `9921382a68bb0c865e5e45eb594d9c64db59b1af`.

**Both selected SSL programs at the reviewed checkpoint have a real missing-data dependency.** The symbol
`bobomb_seg8_anims_0802396C` resolves, but its selected global initializer is
empty. Thus it supplies no readable animation-pointer entry. The fail-closed
certificate below exposes that condition without changing generated files,
link selection, source preprocessing, or US/JP semantics. Actor animation
data has not been repaired in this patch. The standalone check and integrated
selected discipline audit both pass; the nonempty-data checker intentionally
returns false.

## Dependency and actual selected programs

`generated/us_behavior_data.v:7487` and `jp_behavior_data.v:7470` define
`v_bhvBobomb`. Its word2 is LOAD_ANIMATIONS for field38 (`0x27260000`),
word3 is an `Init_addrof` of this table at offset0, and word5 is ANIMATE(0)
(`0x28000000`). Both precede the call to `bhv_bobomb_init`, and hence the
repeated native `bhv_bobomb_loop` calls. The buddy scripts share this table,
but this audit follows the actual Bob-omb dependency, not just the upstream
placed buddy.

The generated LOAD_ANIMATIONS handler reads the script argument and installs
the object's animation pointer. ANIMATE reads field38 and calls
`geo_obj_init_animation` on the selected entry
(`us_behavior_script.v:2790,2845`; corresponding JP definitions). Native
`cur_obj_init_animation` also selects an entry from field38
(`us_object_helpers.v:7609`). The geometry helper converts the table address,
then dereferences `animSegmented` before comparing `curAnim` or reading the
animation structure (`us_graph_node.v:3736`; corresponding JP body).
An already-current animation does not bypass this first table load.

`SelectedClightTarget.selected_clight_target` selects:

- US: `us_viewport_repaired_program`, whose definition list is the mapped
  viewport repair of normalized definitions from the 38 original US units.
- JP: `jp_official_cleaned_slice`, the successful official link of the cleaned
  38 JP units.

The new finite census checks every declaration/definition of this identifier
in each original source union, not merely `behavior_data.v`. All are empty
variables. US normalization keeps a source entry, the repair preserves its
identifier and initializer, and its successful make-program receipt pins the
actual selected definition list. For JP the source-union coverage, successful
official link and exact source-definition provenance supply the same result.
No failed original 38-unit link is substituted for either selected target.
The certificate constructs the selected symbol/variable lookup; it does not
assume that no stronger definition exists elsewhere in the selected program.

An empty CompCert initializer allocates zero bytes. This is different from
a nonempty `Init_space` BSS definition. In particular, neither a sized C type
annotation nor existence of a symbol establishes a readable table entry.

## What the new Coq boundary says

At that checkpoint the module is `proofs/BobombAnimationLink.v`, registered in `_CoqProject`
and imported/consumed by
`MainTheorem.current_bobomb_animation_link_boundary`. The old conditional
memory-frame statements retain their original types.

The exact public checker result is:

```coq
Theorem selected_bobomb_animation_data_check_fails : forall version,
  selected_bobomb_animation_data_linked version = false.
```

The checker searches the actual selected program's definitions for a Gvar
of this identifier with `0 < init_data_list_size (gvar_init variable)`.
Consequently, a positive `= true` certificate cannot silently pass on this
tree. This is a necessary nonempty-data check, not a complete animation
validity or whole-object-closure census.

The exact lookup statement is:

```coq
Theorem selected_bobomb_animation_table_empty : forall version,
  exists block variable,
    Genv.find_symbol (Clight.globalenv (selected_clight_target version))
      bal_table_id = Some block /\
    Genv.find_var_info (Clight.globalenv (selected_clight_target version))
      block = Some variable /\ gvar_init variable = [].
```

The exact reached-load statement is:

```coq
Theorem selected_bobomb_animation_reached_load_fails : forall version,
  exists block,
    Genv.find_symbol (Clight.globalenv (selected_clight_target version))
      bal_table_id = Some block /\
    forall initial start trace last,
      Genv.init_mem (selected_clight_target version) = Some initial ->
      clight_bound_memory start = initial ->
      Smallstep.star Clight.step2
        (Clight.globalenv (selected_clight_target version)) start trace last ->
      forall chunk offset,
        Mem.load chunk (clight_bound_memory last) block offset = None.
```

This uses the existing `ClightAllocationBounds` theorem: defined Clight2 steps,
including external calls satisfying CompCert's external-call properties,
cannot enlarge an already allocated global block. The theorem requires
successful initialized memory and a finite actual Clight2 run from that memory;
it constructs neither a task/boot trace nor a normally reached Bob-omb.
The separate `selected_bobomb_animation_initial_load_fails` covers initialized
memory directly. Generated script words and the extracted geometry read are
also checked by `bal_generated_dependency_checked` and
`bal_geo_table_read_checked`. The full module retains all exact statements,
including the three-conjunct `BobombAnimationLinkBoundary` definition.

**Execution consequence and conditions.** If the animation helper reaches its
read with the converted table address pointing to this global block, that
load cannot have a successful Clight derivation at any offset in such a run.
It cannot support an authentic first Bob-omb update through ANIMATE(0).
This does not prove that the full chain reaches the read: command execution,
object-field provenance, segmented-address conversion and earlier calls may
have other unfilled execution boundaries. Retargeting the pointer to a
different block would be a different premise. A theorem assuming a completed
Bob-omb call remains a conditional theorem and supplies no existence witness
for this authentic setup. Missing execution in this model is not a retail
gameplay exclusion.

## Upstream comparison and repair boundary

[Upstream commit 187731ff](https://github.com/matt-kempster/sm64-wmotr-abc-proof/commit/187731ff391f1ae9ff2b8b3e48ee63bb914fab77)
adds the vendor animation data/tables for Bob-omb, blue fish, Bowser key,
Peach and Toad to its level-data translation unit and completes matching
external declaration types/read-only metadata during regeneration.
`BhvVM.closure_data_linked` checks nonempty data in `ObjTable.lprogs` for the
named object closure; `vm_data_args_linked` checks the data operands of
reachable LOAD_ANIMATIONS, LOAD_COLLISION_DATA and SPAWN_WATER_DROPLET states.

SSL's reviewed 38-unit construction includes no actor-animation data unit.
Its existing name/relocation-resolution checks do not impose the upstream
nonempty-data condition. This patch checks the specific reported dependency
on both actual selected targets; it does not claim to transplant upstream's
entire closure or VM-reachability census.

The pinned real Bob-omb table has two animation pointers plus a NULL sentinel
in `actors/bobomb/anims/table.inc.c`; `data.inc.c` includes their two real
animation definitions. A source-faithful repair must generate/link those
definitions and their referenced index/value arrays, not fabricate storage,
write `Init_space 12`, or merely resize an empty declaration. It must also
revalidate the cleaned JP link, US selection/viewport repair and their source
refinement boundaries for the enlarged program. This patch chooses the
requested fail-closed alternative and leaves that program correction explicit.

## Imports and reproducible validation

For historical reproduction at `18765cf`, use the following imports and
commands. These negative theorem names apply to that checkout; current
downstream proofs should use the [positive repair boundary](bobomb-animation-data-repair.md).

```coq
From LessThanOneAPress.Proofs Require Import BobombAnimationLink.
Check selected_bobomb_animation_data_check_fails.
Check selected_bobomb_animation_table_empty.
Check selected_bobomb_animation_reached_load_fails.
```

The complete required Coq/CompCert/generated imports are at the start of the
module. Run in Ubuntu WSL in `SSL-Coq/less-than-one-a-press`:

```sh
source pipeline/env.sh
ulimit -S -v 6815744
bash pipeline/build.sh audit-build AUDIT_VO_TARGETS=proofs/BobombAnimationLink.vo
bash pipeline/assumptions.sh LessThanOneAPress.Proofs.BobombAnimationLink bobomb_animation_link_boundary_checked
bash pipeline/discipline-check.sh --build-timeout 600 --assumption-timeout 240 LessThanOneAPress.Proofs.MainTheorem current_bobomb_animation_link_boundary LessThanOneAPress.Proofs.MainTheorem current_ink_backward_execution_boundary LessThanOneAPress.Proofs.InkRetryQuery irq_retry_connects_display_to_real_floor_call LessThanOneAPress.Proofs.InkVerticalRetryGeometry ivr_vertical_retry_geometry_checked
```

Use the existing `sm64-item-proof` switch, Coq8.16.1, CompCert3.15 and
6815744 KB memory cap. Do not use bare `coqc` or reduce the whole linked AST.
The [validation receipt](bobomb-animation-link-validation.json) records the
successful standalone check and assumption query, and integrated audit
`20261029-075043-nsaujezp`: build, inventory, no-holes, link hygiene, all four
selected assumption queries and integration pass. The new Main boundary uses
only the nine allowed foundations; there are no project axioms. Main imports
511 of 606 registered proof modules, with zero integration problems. The
unchanged baseline audit `20261029-071457-sd0gemxt` also passed. An earlier
integrated attempt was interrupted during a transient WSL connection failure;
the isolated retry passed without changing limits or restarting the distro.
The cause of the transient failure is undetermined.

This finding is separate from Mario's render-call frame and teleporter audio,
ownership, allocation and lifetime questions. No complete Bob-omb survival,
usable Area-2 regrab, reachable wrong warp, route exclusion or changed
subjective counterexample estimate is claimed.
