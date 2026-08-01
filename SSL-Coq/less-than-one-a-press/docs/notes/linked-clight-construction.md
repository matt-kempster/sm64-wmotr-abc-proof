# Linked Clight construction audit

## Result

The project now contains a reproducible, kernel-checked attempt to link all 38
selected Clight translation units for each of `VERSION_US` and `VERSION_JP`.
CompCert 3.15's unmodified `Linking.link_list` does **not** produce a linked
program for either version.  Consequently the project does not construct a
whole-program `Genv.globalenv`, does not instantiate `TargetLinkedProgram`, and
does not use a fabricated fallback program.

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

## Exact unresolved symbol boundary

The following checked manifests list every canonical atom after applying this
coverage rule: retain an available `Internal` function body in preference to
an `EF_external` declaration, and retain an available definitive variable
definition in preference to an extern or tentative declaration.

- `linked-symbol-coverage-us.txt`: 227 remaining `EF_external` functions, 314
  extern-only variables, and 157 tentative-only variables;
- `linked-symbol-coverage-jp.txt`: 226 remaining `EF_external` functions, 314
  extern-only variables, and 156 tentative-only variables.

The files also enumerate the 2,567 US / 2,561 JP internal functions and 1,069
US / 1,060 JP definitive variables found by the same rule.  Regenerate either
manifest with:

```sh
python3 pipeline/link-coverage-manifest.py generated us
python3 pipeline/link-coverage-manifest.py generated jp
```

These are symbol-index and coverage manifests only.  In particular, an
unresolved `EF_external` function is not automatically entitled to mutate
Mario, object-pool, or controller memory.  External-call frame conditions
remain separate proof obligations.

## Exploratory normalized slice and sound link path

`proofs/NormalizedClightPrograms.v` now performs the first four structural
steps as an explicitly exploratory construction:

1. select every available internal function body exactly once;
2. select every available definitive variable definition exactly once;
3. drop redundant extern or tentative declarations when such a definition is
   selected;
4. retain the exact unresolved atoms recorded in the manifests.

The resulting US/JP `Clight.program` values pass `Ctypes.make_program`, but
they are **not** results of CompCert's `Linking.link`.  The kernel audit also
keeps the unresolved boundary visible: three function-signature mismatch
atoms per version, the single `gDisplayListHead` variable-type mismatch per
version, and six US / five JP incompatible same-name composite definitions.

Before the slices can support retail semantics, the project must construct
cleaned translation units satisfying
`NormalizedCleanedUnitsOfficialLinkStructuralObligation` and then prove at
least these semantic refinement facts:

- every incomplete-array declaration and use is compatible with the chosen
  complete array type, including initializer relocations and pointer decay;
- TU-local anonymous composite identifiers are alpha-renamed consistently in
  global types, function signatures, local declarations, expressions, and
  composite environments, with equal layouts proved;
- each preserved function body resolves all global references to the intended
  selected definition;
- unresolved external calls satisfy stated writable-memory frame conditions;
- executions in the normalized global environment simulate the corresponding
  generated Clight executions.

Until those obligations are discharged, the normalized slice is only a
coverage instrument.  It is not a whole-program Clight semantics and cannot
justify the final zero-A gap bound.

## Verification

```sh
coqc -q -R generated LessThanOneAPress.Generated \
  -R proofs LessThanOneAPress.Proofs proofs/LinkedClightPrograms.v
coqc -q -R generated LessThanOneAPress.Generated \
  -R proofs LessThanOneAPress.Proofs proofs/NormalizedClightPrograms.v
bash pipeline/check-link-hygiene.sh
bash pipeline/check-generated.sh
```
