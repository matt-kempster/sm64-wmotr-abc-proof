# Pyramid-top cast, transform, and floor-query refinement

This note records the exact boundary of
`proofs/PyramidTopSurface.v`.  It is a refinement of the pyramid-top
Parallel-Universe audit, not a proof that the proposed route is reachable.

## Newly imported Clight

The reproducible `clightgen` pipeline now translates these pinned decomp
translation units for both `VERSION_US` and `VERSION_JP`:

- `src/engine/math_util.c`, including
  `mtxf_rotate_zxy_and_translate` and the complete `gSineTable`
  initializer;
- `src/engine/surface_load.c`, including `read_surface_data`,
  `transform_object_vertices`, `load_object_surfaces`, and
  `load_object_collision_model`.

The two linear matrix-vector helpers were already internal functions in the
generated `src/game/object_helpers.c` units.  All of these programs are now in
`ClightRefinement.target_translation_units`; they are no longer opaque external
helpers at the project boundary.

## What is proved

The generated `find_floor` body begins by applying the exact nested Clight cast
`(s16)(s16)position` to X, Y, and Z.  For the concrete binary32 candidate
`(63488.0f, 1791.0f, -1024.0f)`, CompCert's `Cop.sem_cast` evaluates to signed
16-bit values `(-2048, 1791, -1024)`.  In particular, CompCert converts
`63488.0f` to signed 32-bit first and then applies `Int.sign_ext 16`, yielding
`-2048`.

That theorem has a deliberately narrow scope:

1. It is an exact theorem about the selected generated Clight and CompCert
   semantics.
2. ISO C does not supply a portable signed-16 result for this out-of-range
   source conversion.
3. It does not claim anything about unrelated values outside the signed-32
   range.

The exact target-code question for these three inputs has now been checked
separately.  Authenticated US and JP retail `find_floor` functions contain the
same `trunc.w.s; mfc1; sh; lh` conversion sequence, and
`concrete_retail_cast_fragment_arithmetic` evaluates its concrete finite-width
result.  See [`retail-find-floor-cast.md`](retail-find-floor-cast.md) for ROM
hashes, addresses, instruction words, and reproduction commands.
The receipt authenticates the instructions; the Rocq theorem checks their
value arithmetic.  Together they close only these three concrete inputs, not a
general IDO/CompCert equivalence.

The proof also evaluates the finite-width partition arithmetic: wrapped X
`-2048` selects cell 6 and Z `-1024` selects cell 7.

`concrete_top_face_mesh_link_checked` connects both generated collision
initializers, through the existing parser theorem, to face `(1,4,3)` and its
three zero-yaw home vertices.  For that face, the proof evaluates a manually
mirrored signed-32 edge formula.  At query `(-2048,-1024)` the three values are
`521730`, `0`, and `1023`; all are nonnegative.  A generated-AST expression
extraction theorem for the complete `find_floor_from_list` calculation is still
pending, so this is not yet an execution theorem.

At the stock home translation with zero pitch, roll, **and yaw**, the proof
evaluates a manually mirrored CompCert binary32 multiply/add association for
all three vertices of that face.  The Y column `[0,1,-0]` is independent of
yaw, but the concrete X/Z coordinates and edge values are zero-yaw results.
This is a concrete arithmetic kernel linked to the parsed source vertices; it
is not yet a generated-expression extraction or Clight memory execution of the
matrix construction, scaling, and vertex loop.

Finally, a generated-AST recognizer establishes that `find_floor` contains a
`dynamicHeight > height` branch with the `floor := dynamicFloor` assignment.
This is an existential source-shape result: it does not prove absence of
another assignment, control-flow exclusivity, the complete height update, or
the runtime value selected.
Separate exact lookup checks establish that every matrix/surface helper named
above is an internal function of a selected generated program.

These facts are checked staging aimed at the named PU execution residual:
`PyramidTopPU.pyramid_top_pu_checked_bundle` now includes
`pyramid_top_surface_semantic_claim`, but that arithmetic/source bundle is not
currently imported by `MainTheorem`.  Separately, the two new generated
programs are load-bearing in the real-program inventory because
`ClightRefinement.target_translation_units` includes them.  That inclusion
does not itself prove a linked execution.

## Remaining execution obligations

The following prose work-item names are not Rocq declarations.  They identify
the narrow refinements still needed before claiming that `find_floor` actually
returns the live pyramid-top surface:

- `PyramidTopTransformExecutionRefinement`: execute the linked matrix,
  scale, and vertex-transform bodies from a source-backed pyramid-top object
  memory state and obtain the checked transformed vertices;
- `PyramidTopDynamicPartitionOwnership`: execute surface allocation/insertion,
  prove that the resulting live surface is owned by the intended object-pool
  epoch, and account for clear/rebuild, unload, and slot reuse;
- `PyramidTopFindFloorListOrderRefinement`: prove that no earlier dynamic
  surface in cell `(6,7)` passes first, and discharge the `sqrtf`/normal/height
  memory calculation for face `(1,4,3)`;
- `PyramidTopFindFloorSelectionExecution`: run the linked generated
  `find_floor` from the concrete memory and prove the returned pointer and
  height, including comparison with the static-floor result.

None of these obligations is assumed by a completed theorem.  No gameplay
reachability, delayed-warp lifetime, target-region continuation, or star-bit
collection result follows from this increment alone.
