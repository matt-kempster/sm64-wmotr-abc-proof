# Ordinary SSL Area-1 entry memory

This note isolates the ordinary stock entry into Shifting Sand Land Area 1.
It is deliberately narrower than a claim about all clean reachability.  The
purpose is to identify the exact memory state from which the Graphics/Object
gap audit should begin, and to state honestly what still has to be executed in
linked Clight.

The generated files and kernel-checked receipts use the project's pinned
decomp revision `9921382a68bb0c865e5e45eb594d9c64db59b1af`, with
`VERSION_US` and `VERSION_JP` translated separately.

## The ordinary entry route

The stock Area-1 `WARP_NODE_0A` object is generated from this LevelScript
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

Separately, `jp_official_area1_entry_symbol_structure_closed` now packages the
official-JP twelve-symbol address bundle and the limited structural separation
facts above.  It does not inhabit the live-memory postcondition.

## Remaining obligations

The decisive work still open is:

1. execute the actual linked US and JP `warp_level` / `init_mario_after_warp` /
   `init_mario` sequence from a valid ordinary predecessor;
2. connect castle painting selection and the level script to the change-level,
   SSL, Area-1, node-`0x0A` request in
   `CastlePaintingToSSLArea1RoutingObligation`;
3. connect the live warp behavior pointer through `virtual_to_segmented` to
   behavior-table index 11;
4. prove the floor/water, graph, camera, save, audio, allocator, and other
   still-external calls preserve the memory locations used by the
   postcondition, as isolated by
   `OrdinaryArea1EntryExternalFrameObligation`;
5. prove the complete object-pool/list ownership and alias invariant, beyond
   the current pointer-closure definition, and discharge the explicit
   per-access in-bounds obligation;
6. prove that the controller sample comes from the coherent no-A poll history;
7. for JP, derive the actual predecessor `gMarioPlatform` value and its
   slot/epoch provenance instead of assuming null; and
8. compose this entry theorem with per-frame writer coverage.  Entry
   synchronization alone does not show that the gap remains below 960.

The current result therefore narrows the retail gap-installer problem but does
not prove that clean retail JP can or cannot install the required payload.
