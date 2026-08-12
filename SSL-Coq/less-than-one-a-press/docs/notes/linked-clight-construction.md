# Linked Clight construction audit

## Result

The project now contains reproducible, kernel-checked results for both the
failed original links and successful source-owned cleaned links for
`VERSION_US` and `VERSION_JP`.  CompCert 3.15's unmodified
`Linking.link_list` does **not** produce a linked program directly from either
original 38-unit list, and the project does not use a fabricated fallback
program.  `proofs/CleanedClightPrograms.v` constructs cleaned unit lists and
proves that the same unmodified linker returns `us_official_cleaned_slice` and
`jp_official_cleaned_slice`.  The theorems
`us_normalized_cleaned_units_official_link_structural` and
`jp_normalized_cleaned_units_official_link_structural` are the two
kernel-checked `NormalizedCleanedUnitsOfficialLinkStructuralObligation`
inhabitants.

Those inhabitants establish syntactic structural linking only.  They do not
show that executions of the cleaned programs simulate the original generated
units or the target ROM.

`proofs/LinkedClightPrograms.v` proves all of the following without admissions:

- the selected US and JP unit lists each contain 38 programs;
- the executable AST-program link and composite-definition link both return
  failure for each version;
- the first AST failure in the documented right-associated order is index 34
  from the zero-based head, where `ssl_script` is joined to the already joined
  SSL data wrappers;
- the first composite-definition failure is index 27 for both versions, where
  `area` is joined to the suffix beginning with `level_update`;
- any successful Clight `link_list` would project to a successful AST-program
  link; therefore no Clight `link_list` result exists for either selected list.

The important negative theorems are
`us_compcert_clight_link_list_has_no_result`,
`jp_compcert_clight_link_list_has_no_result`, and
`generated_whole_program_link_is_blocked`.

## Private string-literal alpha-renaming

CompCert's C front end resets its private string-literal counter for each
invocation.  Separate `clightgen` calls therefore emit internal-linkage atoms
such as `__stringlit_1` in several units.  CompCert's linker deliberately
rejects same-named static definitions because it has no general renamer.

`pipeline/clightgen.sh` now performs one deterministic link-hygiene
post-processing step: the atom value of each generated private
`__stringlit_N` definition is prefixed with the generated module name.  For
example, the Coq constant `___stringlit_1` in `us_game_init.v` denotes
`__us_game_init_stringlit_1`.  References in that module still use the same
Coq constant.  No public atom, C statement, function body, initializer, or
type is changed by this step.

`pipeline/check-link-hygiene.sh` checks that every renamed literal has exactly
the expected module-qualified name, that none occurs in `public_idents`, that
no duplicate non-public atom remains, and that the committed symbol manifests
reproduce.  It currently checks 135 US and 127 JP private literal atoms.
Byte-for-byte regeneration remains checked independently by
`pipeline/check-generated.sh`.

This establishes the exact syntactic scope of the transformation.  A reusable
CompCert semantic alpha-renaming theorem for these programs has not yet been
proved; that connection remains a named refinement task if later proofs rely
on the renamed atoms semantically.

## Why linking still fails

After the private collisions are removed, the generated public declarations
still expose a systematic limitation of CompCert 3.15's syntactic type linker.
It requires equal `gvar_info` types.  The decomp commonly declares an external
array with unknown bound while another unit supplies its complete definition.
The generated types are consequently unequal even though the C declarations
refer to the same object.

Examples from the generated US programs are:

- `ssl_seg7_area_1_collision` is `tarray tshort 0` in `us_ssl_script.v` and
  `tarray tshort 4945` in `us_ssl_collision.v`;
- the corresponding Area 2 and Area 3 lengths are 8098 and 908;
- `ssl_seg7_area_1_macro_objs` and `ssl_seg7_area_2_macro_objs` have complete
  lengths 231 and 251 in their data wrappers but length 0 in the script unit;
- `gDisplayListHead` is an extern pointer to anonymous union `__613` in
  `us_area.v`, while its definition in `us_game_init.v` and declarations in
  `us_memory.v` and `us_rendering_graph_node.v` use anonymous union `__549`.

The deterministic audit groups `Gvar` entries by their canonical atom string,
normalizes the generated `gvar_info` text, and counts duplicate public atoms
with more than one type.  It finds 402 groups for US and 401 for JP.  Of the US
groups, 401 are array-shape differences and the remaining one is the
`gDisplayListHead` anonymous-composite mismatch.  Fixing only the five SSL
array declarations would therefore move, not discharge, the linking failure.

The composite-definition link also fails for both versions.  No theorem in
this project treats either failed component link as a linked environment.

`proofs/CompositeLayoutRefinement.v` narrows the necessary cleanup.  Every
generated function declaration has the selected definition's CompCert call
ABI.  Every generated variable declaration satisfies the
exact-or-incomplete-array rule except `gDisplayListHead`; the exceptional
pointer views nevertheless agree on checked size, alignment, access mode, and
volatility.  All named JP residual composite layouts and the five named US
residual layouts are storage-compatible.

The remaining US anonymous atom `__538` is a genuine collision, not a harmless
name mismatch.  `us_area.__538` and affected cutscene source uses denote the
viewport structure with members `vscale`/`vtrans`, size 16, alignment 2.  The
equal atom in `us_game_init` denotes a graphics-command payload, size 8,
alignment 4.  The actual official US target inherits the normalized header's
graphics-command `__538`.  As a result, its `__540` viewport wrapper has checked
size 8 while the affected source viewport wrapper/global storage has size 16.
This is a checked counterexample to identifying structural linkability with
composite refinement.

The proof constructs a globally fresh tag and rebuilds the two local viewport
  composite environments with their original layout.  `USWholeASTTagRepair.v`
now defines a recursive transformation over global and function types,
local/temporary annotations, expressions, `sizeof`, `alignof`, statements,
continuations, and Clight states while preserving initializer data.  The
repaired `make_program` success certificate and small-step execution simulation
remain open.  Replacing only the composite definition is insufficient.  JP's
residual anonymous tags pass the checked storage-layout
boundary, but JP still needs the same kind of original-to-cleaned retail
execution refinement.

## Exact unresolved symbol boundary

The following checked manifests list every canonical atom after applying this
coverage rule: retain an available `Internal` function body in preference to
an external declaration, and retain an available definitive variable
definition in preference to an extern or tentative declaration.  Global
`External` fundefs are partitioned by their actual CompCert constructor; the
old combined total must not be described as all `EF_external`.

- `linked-symbol-coverage-us.txt`: 133 `EF_external`, 75 `EF_builtin`, and 19
  `EF_runtime` functions, plus 314 extern-only variables and 157 tentative-only
  variables;
- `linked-symbol-coverage-jp.txt`: 132 `EF_external`, 75 `EF_builtin`, and 19
  `EF_runtime` functions, plus 314 extern-only variables and 156 tentative-only
  variables.

The files also enumerate the 2,567 US / 2,561 JP internal functions and 1,069
US / 1,060 JP definitive variables found by the same rule.  Regenerate and
verify them with:

```sh
python3 pipeline/link-coverage-manifest.py generated us \
  --output docs/notes/linked-symbol-coverage-us.txt
python3 pipeline/link-coverage-manifest.py generated jp \
  --output docs/notes/linked-symbol-coverage-jp.txt
bash pipeline/check-link-hygiene.sh
```

These are symbol-index and coverage manifests only.  In particular, an
unresolved `EF_external` function is not automatically entitled to mutate
Mario, object-pool, or controller memory.  External-call frame conditions
remain separate proof obligations.  Direct `Sbuiltin` effects are embedded in
statements rather than global definitions and therefore are not members of
these manifests.

## Exploratory normalized slice and sound link path

`proofs/NormalizedClightPrograms.v` now performs the first four structural
steps as an explicitly exploratory construction:

1. select every available internal function body exactly once;
2. select every available definitive variable definition exactly once;
3. drop redundant extern or tentative declarations when such a definition is
   selected;
4. retain the exact unresolved atoms recorded in the manifests.

The resulting US/JP `Clight.program` values pass `Ctypes.make_program`, but
they are **not** themselves results of CompCert's `Linking.link`.  A separate
cleaner retains selected definitions in source-owned units under normalized
headers.  CompCert's unmodified `link_list` is now proved to return the US and
JP official cleaned targets.  This does not retroactively make the exploratory
normalized values official links, nor does it establish retail semantics for
the cleaned targets.

`proofs/CleanedClightPrograms.v` proves exact-definition provenance from each
official target to a cleaned source-owned unit and onward to the original source
union.  `proofs/ClightLinkExecution.v` uses that provenance to close several
actual-target reference obligations without assuming that the official target
equals the normalized candidate:

- a source `Internal` definition that participates in a successful official
  link resolves to that exact body in the linked `prog_defmap` and global
  environment;
- source and target global blocks are related by symbol name, not assumed to
  have equal block numbers;
- every nonlocal `Evar` in an internal body of either actual official target
  resolves to a target symbol;
- every `Init_addrof` occurrence in either target initializer resolves to a
  target symbol;
- `named_global_evar_lvalue_execution_bridge` crosses the actual
  `eval_Evar_global` rule for one typed global reference.  Given
  `NamedSymbolCoverage`, explicit source and target environment lookups showing
  the identifier is not a local, and current memories already related by
  `Mem.inject (symbol_block_map source target)`, it constructs both
  `eval_lvalue` derivations and proves `Val.inject` for the source and target
  zero-offset pointers;
- every retained or reachable global `External` in either target has one of
  the supported CompCert constructors: `EF_external`, `EF_builtin`, or
  `EF_runtime`;
- exhaustive recursion through all actual-target internal bodies proves that
  `program_direct_sbuiltins` is empty for US and JP;
- reachable global external `Callstate`s have linked-program definition
  provenance and cannot hide an internal body from an input unit.

The normalized/source coverage manifests preserve the exact global-external
inventories: US has 227 total (`133 EF_external + 75 EF_builtin + 19
EF_runtime`), and JP has 226 (`132 + 75 + 19`).  The actual-target provenance
and classifier establish supported constructors; they do not reclassify every
entry as `EF_external`.

The file also proves execution transport using CompCert's real interfaces:

- `global_interface_agreement_is_external_environment_injection` turns the
  required pointwise global/public interface into `symbols_inject` for the
  name-based `symbol_block_map`;
- `external_call_executes_under_memory_injection` and
  `external_call_executes_across_global_interface` transport `external_call`
  through `Mem.inject` and `Val.inject_list`;
- the produced result and memory are injected, the new injection grows and is
  separated from the old one, and CompCert supplies `Mem.unchanged_on` for
  `loc_unmapped` and `loc_out_of_reach` locations;
- `clight_external_callstate_step_injects` lifts an external Clight
  `Callstate` step;
- `clight_sbuiltin_step_injects_after_argument_evaluation` handles the generic
  direct-`Sbuiltin` case only after an explicit proof that source and target
  argument evaluations yield injected value lists.  The actual official
  targets contain no such direct statement.

These are memory-injection transport results, not arbitrary writable-game-state
frames.  `RetailExternalFrames.v` now identifies the concrete Mario-state,
object-pool, Mario-object-pointer, controller-array, and player-controller
blocks.  Recognized builtins/runtime helpers preserve all of them by leaving
memory unchanged.  The declaration-wide whole-pool external frame is now a
legacy sufficient condition, not the intended target: legitimate helpers can
allocate and write object slots.  `RetailExternalFrameReachability.v` instead
requires each reachable call to preserve callsite-selected cells or enter an
explicit writer/lifecycle refinement.  Its generic bridge is checked; the
exact selected unresolved direct-callee set for the seven dialog/depth bodies
is now checked as the expected ten names for both US and JP.  Path-sensitive
reachable call sequences, transitive reachability, argument provenance, and
concrete effect cases remain open.
`ClightEndToEndRefinement.v` relates local/temp environments, continuations, and
all Clight state constructors and proves pointer, dereference, scalar-operation,
lockstep, and initial-to-final composition lemmas.  It does not yet instantiate
the whole-expression or internal-step simulation for US or JP.

The whole-AST repaired US program is now checked to build, and target selection
uses it together with the official cleaned JP link.  This avoids the impossible
common-`linkorder` gate over incompatible original-unit composites without
claiming a semantic repair.  Original-unit cleaning/header normalization is a
checked structural certificate only; standalone units are not executed with
their arbitrary cross-unit `EF_external` declarations.  The open semantic
boundary starts from the whole official cleaned link and requires selected-
target lockstep anchored at matching null-argument `thread5_game_loop` task
starts with an actual first step.  The official JP initialized memory, exact
  task-body resolution, first step, and identity source-to-selected lockstep are
  now inhabited.  Its OS handoff and later gameplay prefix remain open; US
  initialization and viewport-repair lockstep are also open.  A generic
  selector-exactness theorem is also checked under explicit hypotheses; concrete
  US/JP global/public-map agreement remains open.  Separately, data-bearing
frame chronologies under one fixed observer now compose into the whole-run
projection certificate.  The interface pins the controller/pointer bindings
and selected poll/consumer bodies, authenticates the boundary input, and
separates gameplay from poll-only administrative frames.  The concrete
  observer, chronology, projection, and task-entry prefixes are not supplied.
  The actual successful repaired US program now has a separate conditional
  selected-target audit.  The focused syntax/name transport proves no direct
  `Sbuiltin`, supported external constructors, and resolution of internal-body
  `Evar` and initializer `Init_addrof` names; the two split core-symbol receipts
  prove `find_symbol` existence for five identifiers.  `USSelectedTargetAudit.v`
  packages these facts as `SelectedTargetAuditTransportObligation` when the
  projection is fixed to `VersionUS` and `us_viewport_repaired_program`.  This
  does not prove initialization, memory shape/content/block correspondence, or
  source-to-selected execution lockstep.
`JPWarpLevelEntryResolution.v` resolves the exact `warp_level` symbol/body in
the official cleaned JP environment.  The split `USWarpLevel*Receipt.v` chain
and `USWarpLevelEntryResolution.v` transport and resolve the exact `_warp_level`
internal body in the selected viewport-repaired US environment.  Neither
lookup supplies routing, reachability, execution, or an entry postcondition.
Twelve focused JP symbol receipts and `JPArea1EntrySymbolResolution.v`
separately construct the complete official-JP `Area1EntryAddresses` bundle at
slots `0`/`1`.  The aggregate proves all twelve entry-symbol bindings, valid
slots, pairwise distinction of the three core storage blocks, and separation
of every pointer cell from core storage.  The `gMarioPlatform` receipt uses
aggregate public-name coverage and cleaned-link transport.  No live contents,
allocation/layout sizes, initializer values, routing, reachability,
`warp_level` execution, postcondition, or prefix follows from this structural
bundle.

Although the structural official links exist, retail semantics still requires
at least these refinement facts:

- whole-linked-source-to-selected-target lockstep anchored at matching
  runtime-task starts, including the repaired-US execution relation;
- a complete normalized/original-to-official global-interface proof: pointwise
  declaration/composite/global-reference correspondence and public-name
  equivalence sufficient to instantiate the proved `symbols_inject` theorem;
- concrete initial-memory and current-state `Mem.inject` under the name-based
  `symbol_block_map`, including concrete relocation contents rather than symbol
  existence alone;
- whole-expression refinement, including argument-list injection where a
  generic direct `Sbuiltin` theorem is used;
- the concrete internal Clight step simulation, including every relevant
  composite access (the generic environment/continuation/state relations are
  already available);
- pointer/type compatibility for cleaned incomplete-array uses beyond the
  checked declaration/storage boundary;
- castle routing and live `warp_level` execution (the exact JP and repaired-US
  symbol/body resolutions and the official-JP twelve-symbol structural bundle
  are checked, while the remaining US entry bindings are open);
- callsite-sensitive protected-cell frames or writer/lifecycle refinements for
  every reachable `EF_external`; the finite dialog/depth direct-callee
  inventory is checked, while path-sensitive reachable call sequences,
  argument provenance, transitive reachability, and concrete effects remain;
- a fixed concrete observer instantiating the pinned bindings, concrete
  gameplay/admin classification, data-bearing projection chronologies, and
  `thread5_game_loop` task-entry prefixes to the lower and upper clean entries;
- related initial/final whole-program executions and the projection from the
  cleaned official execution to retail state.

Until those obligations are discharged, the normalized slice is only a
coverage instrument.  It is not a whole-program Clight semantics and cannot
justify the final zero-A gap bound.

## Verification

```sh
source pipeline/env.sh
make clean
make check
SM64_SOURCE=/path/to/pinned/decomp make verify-generated
```

`make check` follows `_CoqProject`, so it compiles the cleaned-link witnesses,
the split declaration/composite receipts, the official-target execution
boundary, and their dependencies in a clean checkout.  `verify-generated` is a
separate byte-for-byte regeneration check and requires the pinned decomp
checkout through `SM64_SOURCE`.
