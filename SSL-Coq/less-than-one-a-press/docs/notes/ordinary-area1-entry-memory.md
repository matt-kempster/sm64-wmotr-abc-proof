# Ordinary SSL Area 1 entry memory

This note isolates the default spawn in **SSL Area 1 (the exterior)**.

The core linked gameplay proof begins at `DefaultArea1StartBoundary`, after
the node-`0x0A` spin-airborne spawn has established its stated memory.  This is
an assumed run-start boundary, not a theorem that the OS, castle, painting, or
level-loading execution reaches it.

The generated files and kernel-checked receipts use the project's pinned
decomp revision `9921382a68bb0c865e5e45eb594d9c64db59b1af`, with
`VERSION_US` and `VERSION_JP` translated separately.

## SSL Area 1 (the exterior)

The stock exterior `WARP_NODE_0A` object is generated from this LevelScript
payload:

| Property | Value |
|---|---:|
| Behavior | `bhvSpinAirborneWarp` |
| Position | `(653, 1038, 6566)` |
| Yaw | 90 degrees |
| Warp node | `0x0A` |

`get_mario_spawn_type` places `bhvSpinAirborneWarp` at table index 11 and
maps that index to spawn type `0x16`.  Case `0x16` of
`set_mario_initial_action` calls `set_mario_action` with action
`0x00001924` (`ACT_SPAWN_SPIN_AIRBORNE`) and argument zero.

This corrects an easy category error.  Action `0x00001932`
(`ACT_SPAWN_NO_SPIN_AIRBORNE`) belongs to the two `bhvAirborneWarp` objects
inside Area 2.  It is not the ordinary outside-desert entry action.

The level script also contains a fallback `MARIO_POS` command for Area 1 at
`(653, 38, 6566)`, yaw 88 degrees.  During an ordinary inter-level warp,
`init_mario_after_warp` refreshes the live `SpawnInfo.startPos` from the
node-`0x0A` warp object before calling `init_mario`; the fallback command must
therefore not be mistaken for the ordinary post-warp Mario position.  The
linked execution proof still has to establish the live node lookup, the
float-to-`s16` conversion, the floor query, and the final exact binary32
coordinates.

## Initialization order

The source and generated Clight give this relevant order:

1. the level script's `INIT_LEVEL` path calls `clear_objects`;
2. `warp_level` calls `load_area`, then `init_mario_after_warp`;
3. `load_area` spawns Area-1 objects, including node `0x0A`;
4. because this is a change-level request, `init_mario_after_warp` calls
   `load_mario_area`, which spawns Mario's object;
5. `init_mario` resets Mario state and synchronizes MarioState position,
   MarioObject raw position, and graphical position;
6. `set_mario_initial_action` selects the spin-airborne action;
7. `init_mario_after_warp` binds `interactObj` and `usedObj` to the entry warp,
   clears `sWarpDest.type`, and clears `sDelayedWarpOp`.

The concrete postcondition in `proofs/OrdinaryArea1EntryMemory.v` records:

- identical binary32 X/Y/Z in MarioState, MarioObject raw position, and
  MarioObject graphical position;
- zero three-axis velocity and forward velocity;
- action `0x1924`, with action state, timer, and argument zero;
- `framesSinceA = framesSinceB = 255`;
- `quicksandDepth = +0.0f`;
- `heldObj = riddenObj = NULL`;
- `interactObj = usedObj =` the node-`0x0A` entry-warp object;
- an active Mario object with zero collision cache, null per-object platform,
  and null graphics throw matrix;
- the entry warp's `bhvSpinAirborneWarp` behavior pointer;
- no current or delayed warp request after initialization; and
- the live controller `buttonDown` and `buttonPressed` sample.

`DefaultArea1StartBoundary` fixes that postcondition at the exact default
coordinates `(653,1038,6566)`, selects the US/JP linked program and symbol
binding, carries coherent previous/current controller masks with no A edge,
and additionally requires the global `gMarioPlatform` load to be null.

Every block in this postcondition is tied to a named symbol in the linked
global environment.  The Mario and entry-warp objects are also required to be
two distinct, in-range slots of the 240-element object pool.  This avoids an
existential postcondition whose pointers have no connection to the generated
program.

The symbol bindings discharge part of the alias problem immediately.
`us_area1_entry_storage_blocks_pairwise_distinct` and its JP counterpart use
CompCert's `Genv.global_addresses_distinct` theorem to separate MarioState,
controller, and object-pool storage.  Two further theorems separate the
`gMarioState`, `gMarioObject`, `gObjectLists`, and `gMarioPlatform` pointer
cells from all three storage blocks.  These are linked-global facts, not
assumptions about C layout.

For the official cleaned JP global environment, those record premises now have
a concrete structural inhabitant.  Twelve focused source receipts plus
`JPArea1EntrySymbolResolution.v` construct `Area1EntryAddresses` with Mario and
entry-warp slots `0` and `1`, bind all twelve required symbols, prove the slots
valid, separate Mario-state/controller/object-pool storage pairwise, and
separate every pointer cell from those three storage blocks.  The platform
receipt reaches the official symbol through aggregate public-name coverage and
cleaned-link transport.  This construction does not prove the blocks' live
contents, allocation/layout sizes, initializer values, the Area-1 route,
reachability, or execution.

## Controller history and “no A press”

`init_mario` resets `framesSinceA` to 255.  That byte is not the definition of
an A press and does not replace controller history.

`read_controller_inputs` computes:

```text
buttonPressed = currentButtons & (currentButtons ^ previousButtonDown)
buttonDown    = currentButtons
```

The formal entry sample is therefore constructed from both the previous and
current button masks.  The no-A condition checks bit 15 of `buttonPressed`.
A may be continuously held across entry: previous A down plus current A down
produces no A edge even though `buttonDown` still contains A.  The theorem
`ordinary_entry_contract_permits_held_a` checks this case.

The retail predecessor still has to prove that the sample stored in live
controller memory really came from the coherent poll history supplied to the
modeled execution.  The postcondition does not assume `A_BUTTON_DOWN = false`.

## The US/JP platform split

The global `gMarioPlatform` has a null static initializer in both versions.
That fact applies at program start, not automatically at every level entry.

`spawn_objects_from_info` calls `clear_mario_platform` in `VERSION_US` and the
call is compiled out in `VERSION_JP`.  `clear_objects` itself does not clear
`gMarioPlatform`.  Consequently:

- the US Area-1 postcondition requires the global platform pointer to be null;
- the JP Area-1 postcondition requires the global pointer after the entry
  sequence to equal its value before the sequence; it does **not** require
  nullness; and
- Mario's newly allocated object's own `platform` field is null in both
  versions, which is a different field from the JP global raw pointer.

This distinction is essential for the stale-platform investigation.  A proof
that silently promotes the cold-start initializer to a JP level-entry fact
would incorrectly delete the spawning-displacement candidate.

The declared SSL Area 1 (the exterior) boundary therefore states nullness
explicitly for JP as well as US.  For JP this is a scope assumption, not
something derived from ordinary spawn code.  It excludes a platform pointer
inherited from the omitted castle prefix while leaving every post-boundary
installer under study.

## Object-pool status

The generated globals are exactly:

- 240 object slots, each 608 bytes;
- 16 object-list sentinels, each 104 bytes; and
- a separate 104-byte free-list sentinel.

The generated writer chain shows that `clear_objects` rebuilds the free list,
clears the object lists, deactivates pool slots, and clears dynamic surfaces.
Allocation initializes the new Mario object's active flags, collision cache,
per-object platform, raw fields, and throw matrix.  Area loading and Mario
loading then allocate multiple objects from that pool.

At the array level,
`distinct_object_slot_in_bounds_offsets_are_distinct` proves different
mathematical byte offsets, while
`distinct_valid_object_slot_ptrofs_do_not_alias` and
`distinct_valid_object_slot_vptrs_do_not_alias` lift that result through
CompCert's finite pointer representation for valid pool slots.  The result is
arithmetic over the actual generated object size.  It does not bless an
out-of-bounds access: `OrdinaryArea1ObjectAccessInBoundsObligation` records the
remaining proof that every projected object-field access stays inside its
slot.

What is not yet proved is the complete live graph after those allocations:
slot ownership, list membership, reciprocal links, uniqueness, the exact free
list, macro-object spawns, and the absence of an untracked alias.  The module
defines `Area1ObjectPoolPointerClosure` as a concrete first milestone and
`OrdinaryArea1ObjectPoolPointerClosureObligation` as the execution theorem
still required.  Pointer closure is explicitly weaker than a full ownership
and lifecycle invariant.

## Exactly what is proved

Theorem `ordinary_area1_entry_source_kernel_checked` proves, by computation on
the generated Clight data and syntax:

- both version-specific node-`0x0A` object records;
- both stock fallback `MARIO_POS` records;
- the behavior-table index and spawn-type value;
- the spawn-type-to-action case;
- the relevant call chain and reset writers;
- the coordinate-copy source shape;
- the pool dimensions and initialization/allocation writer shape;
- the finite-width controller edge-expression shape; and
- the US-clear/JP-retain platform source split.

Given the explicit live-memory postcondition,
`ordinary_area1_entry_memory_synchronizes_raw_and_graphics_y` proves that raw
Object Y and Graphics Y are the same CompCert binary32 value.  Thus the entry
gap is zero under that postcondition; no integer or real-number approximation
is involved.

The theorem `ordinary_area1_entry_checked_boundary_holds` packages only those
checked facts.  It is not a retail reachability theorem.

`proofs/InkTimer131RealEntryPrefix.v` supplies the next execution-shaped boundary
for the JP Ink investigation.  Because level select is accepted here, it starts
at the final Area-1 `clear_objects` call rather than at program startup or
ordinary castle entry.  It requires `load_mario_area`, the distinct Area-object
and Mario spawn calls, `init_mario`, the first object/behavior update, and the
final state to occur in one continuous CompCert small-step run whose every step
is a checked safe store or exact protected-cell frame/writer effect.  The first
update is essential: allocation zeros `oFlags`, and `bhvMario` later writes
`0x100`.  Exact slot-67, behavior, pointer, active, list-ring, safe-flag, zero-
offset, and protected-load reads directly imply the full Timer-131 live
invariant.  The 85-function pre-update family has three conservative outside
sites; the 150-function first-update family has five names at eight sites.  The
record has no constructed inhabitant because the project still lacks the
retail-IDO-to-Clight state simulation and concrete semantics for reached
`EF_external` declarations.

The authentic machine-code side is now continuous at the watched-memory level.
The hash-gated read-only mode-2 run arms physical write watchpoints for the ten
identity/tail ranges and records exactly 19 stores from the timer-347 clear to
the timer-348 endpoint.  Clear resets the pointers/list/free metadata; Mario's
allocation supplies the first zero flag and zero graphical-offset writes; the
spawn and initializer install slot 67, `bhvMario`, both Mario pointers and the
one-node list; and the first behavior pass writes exactly `0x100`.  The runner
rejects any changed, missing, extra, or reordered watched store.  A compiled Coq
replay theorem starts from arbitrary prior watched values, derives the complete
recorded endpoint, and proves every store overlapping the two protected words
safe.  This classifies the actual retail effects of all intervening code on
those ranges, but it remains a debugger receipt rather than a CompCert
small-step derivation.  Ordinary castle equivalence is not required.

`proofs/DefaultArea1StartBoundary.v` packages the selected program, exact
exterior spawn memory, coherent no-A controller history, and explicit global-
platform nullness.  It intentionally has no constructor theorem claiming that
the selected retail program reaches this boundary.

Separately, `jp_official_area1_entry_symbol_structure_closed` now packages the
official-JP twelve-symbol address bundle and the limited structural separation
facts above.  It does not inhabit the live-memory postcondition.

## Remaining obligations

The decisive in-scope work still open is:

1. connect the boundary fields to the concrete selected-program observation
   projection without treating boundary existence as a theorem;
2. construct an IDO-retail-to-Clight state/step simulation (or execute an
   independently reconstructed Clight start state) and give the three narrow
   `EF_external` declarations concrete semantics; the MIPS receipt already
   derives the slot-67 behavior/list/safe-tail endpoint and frames every watched
   range for the authenticated retail run, but cannot itself inhabit a
   `Clight.step2` star;
3. prove complete object-pool/list ownership and alias invariants, beyond the
   current pointer-closure definition, and discharge the explicit per-access
   in-bounds obligation;
4. preserve the coherent controller sample through the first reported frame;
5. prove the linked writer, terrain-dispatch, live-owner, and lifecycle
   projections needed by installer lineage; and
6. compose the boundary with per-frame writer coverage.  Entry synchronization
   alone does not show that the gap remains below 960.

Separately and at low priority, one may execute the actual linked US/JP
`thread5_game_loop`/castle/`warp_level`/`init_mario_after_warp` route, prove
behavior lookup and entry allocation, recover its controller predecessor, and
show that JP's retained predecessor `gMarioPlatform` is null.  That work would
establish reachability of the declared boundary or reveal a castle glitch, but
it is not required by the currently scoped theorem.

The current result therefore narrows the retail gap-installer problem but does
not prove that clean retail JP can or cannot install the required payload.
