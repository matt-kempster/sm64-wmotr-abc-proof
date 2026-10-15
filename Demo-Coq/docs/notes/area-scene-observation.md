# Raw area snapshots and the loaded-scene boundary

The gameplay verdict remains **OPEN**. `DemoAreaSceneObservation.v` supplies
an owner-independent raw memory snapshot for the primary specification. It
does not identify a level, execute area initialization, prove terrain or graph
construction, or establish boot reachability.

`demo_area_scene_snapshot` records the real `gCurrentArea` pointer cell,
the pointed-to block/offset, Area index and flags, and the processed geometry,
terrain, rooms, macro-object, object-spawn and camera values. The snapshot
requires readable typed values and a checked generated Area layout. It does
not require active flags, a particular index, non-null field values, a Mario
alias or agreement with a demo header. `demo_no_current_area_at` separately
records an actual null current-area pointer. Invalid or unreadable scene state
must remain a full-specification classification/coherence obligation; it must
not erase an original controller-read observation.

The selected actual field expressions are checked against generated US/JP
`load_area`, `load_mario_area` and `basic_update` bodies. A snapshot supplies
their real `eval_expr` loads when the original pointer temporary contains the
observed address. This is a memory observation, not a claim that all these
functions execute simultaneously at that instant. `demo_area_snapshot_transport`
preserves the snapshot along the shared original `step2` history under an
explicit per-step byte frame for exactly the observed pointer and fields.
The frame does not freeze all scene data or prove ownership preservation.

The relevant generated Area fields are index at byte0, flags1, processed
`GraphNodeRoot*` at4, terrain8, rooms12, macros16, object spawn information32,
and camera36. The generated Area size is60. Other source fields include
terrain type2, ordinary warps20, painting warps24, instant warps28, unused40,
whirlpools44/48, dialogs52/53 and music54/56. This module's snapshot observes
the eight selected fields, rather than asserting every Area field invariant.

The runtime provenance receipt must distinguish these actual operations:

1. `level_cmd_begin_area` reads area byte2 and raw geometry operand4 from the
   current command, calls `process_geo_layout(pool, rawGeometry)`, obtains the
   processed root, reads its views array and first camera node, then stores
   the root and camera in `gAreas[index]`. The root's areaIndex is byte20 and
   its views pointer is32. Camera-node config.camera is byte24 and shares a
   union with an earlier numeric mode. Processed pointers cannot be identified
   with raw geometry symbols merely because the command references them.
2. `level_cmd_set_terrain_data` reads the interpreter's private
   `sCurrAreaIndex`, resolves the raw command operand through
   `segmented_to_virtual`, and installs the returned terrain pointer.
3. `load_area` publishes `gCurrentArea` before calling `load_area_terrain`,
   spawning objects, building warp-node links and invoking graph callbacks.
   A non-null pointer before those calls complete is not a completed
   materialization receipt.
4. `load_mario_area` can reuse an already-current area, sets its active flag
   when indices match, and spawns Mario. It does not itself assign
   `MarioState.area`; that occurs in the Mario initialization source.

The interpreter's `sCurrAreaIndex` and runtime `gCurrAreaIndex` are distinct.
`clear_areas` initializes each Area.index; begin-area does not initialize that
field. Unloading clears the current pointer but can leave the scalar current
area number stale. The `gAreas` pointer's alias to `gAreaData` must also be
established by actual initialization and preserved to the relevant commands.

Source-derived script ownership, authenticated active-image/relocation
provenance, matched nested calls and returns, processed results, static terrain
materialization, area reuse/unload/reset/pool lifetimes and preservation to an
input observation remain the runtime composition's obligations. A named
terrain or geometry call/return does not prove construction by an omitted or
arbitrary external body. Adding their source units supplies actual bodies;
their nested graph, behavior, allocation and callback dependencies and
execution still require justification. Legitimate object/camera/environment
updates must be allowed while preserving scene ownership.

The snapshot aggregate is `demo_area_scene_observation_claim`, proved by
`generated_area_scene_observation_us_jp`. Its result is actual field-expression
evaluation and conditional snapshot transport, with no level-pairing conclusion.
