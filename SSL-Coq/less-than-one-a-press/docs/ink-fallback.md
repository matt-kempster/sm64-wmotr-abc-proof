# Ink graphical-fallback investigation

## Verdict

Ink's proposed engine primitive is **conditionally valid**.  The frame order
does not rule it out.

A single frame can use three different Mario coordinate samples:

1. `MarioObject.oPos` for object collision with Area-1 warp node `0x1E`;
2. `MarioState.pos` for the wall and first floor queries; and
3. `MarioObject.header.gfx.pos` after the first floor query returns `NULL`.

If the object sample overlaps the warp, the State sample is floorless, and the
graphical sample makes the retry select a live pyramid-top floor, the already
cached warp interaction can coexist with the later top-floor snap.  The
subsequent State-to-Object copy and final platform query can then place Mario
on the top.

No clean US or JP retail execution constructing those three samples has been
found.  The project therefore records two conditional coordinate
countermodels, not a game counterexample and not a proof of the final
two-star claim.

## Which earlier analysis was right?

Both chatbot analyses contained correct local facts, but neither stated the
complete answer.

The following statements are correct:

- `find_floor` narrows X, Y, and Z to signed 16-bit terrain coordinates.
- warp hitbox collision uses the full binary32 `MarioObject.oPos` values;
  Parallel-Universe wrapping does not make a far-away object overlap the warp.
- one coordinate cannot simultaneously overlap the stock upper warp and be
  close enough to stand on the stock pyramid top;
- platform displacement cannot newly move `MarioObject` into the warp before
  that frame's object-collision pass; and
- Mario's rendered/object position is updated later.  This is not an invisible
  permanent displacement.

The incorrect inference was that those facts eliminate every schedule.  They
eliminate a **one-coordinate** schedule.  They do not eliminate the
State/Object/Graphics schedule above.  Object collision may cache the warp
from the old Object sample, while a failed State floor query later copies the
independently stale graphical sample and retries.

## Exact frame order

For the pinned US and JP source, the relevant normal object-update frame is:

1. update terrain objects and rebuild dynamic surfaces;
2. apply Mario's platform displacement to `MarioState.pos`;
3. detect object collisions from the old full-float `MarioObject.oPos`;
4. run Mario's behavior;
5. perform two wall queries and the first `find_floor` on `MarioState.pos`;
6. if the floor pointer is null, copy `header.gfx.pos` to `MarioState.pos` and
   retry `find_floor`;
7. process the collision array, including the warp cached at step 3;
8. execute `ACT_DISAPPEARED`, snap State Y to the retry floor, and copy State
   to Graphics;
9. copy State coordinates to raw `MarioObject.oPos`; and
10. perform the final platform query.

This explains two superficially conflicting facts:

- platform displacement cannot create the same-frame warp collision; but
- a warp collision that was already present can survive a later State and
  Graphics change.

The generated-AST theorem
`graphical_floor_fallback_source_shape_{us,jp}` recognizes the guarded
floor-null branch, its ordered `vec3f_copy`/`find_floor` retry, and its field
uses.  `upper_warp_phase_pipeline_source_shape_{us,jp}` checks the surrounding
call/assignment anchors.  These are syntax facts, not a Clight small-step
memory proof.

## Concrete floor-miss diagnostic

`InkFallback.v` uses the integer-exact State query:

```text
q = (-2200, 768, -1024)
```

It is still inside the standard Mario/warp horizontal overlap radius.  The
generated Area-1 collision initializer supplies these exact nearby results:

- floor `(498,500,501)` has edge values
  `[52020, 20604, -31008]` and is rejected;
- floor `(498,501,502)` has
  `[31008, -10404, 21012]` and is rejected;
- upper floor `(265,266,372)` has
  `[63140, 10404, 10096]`, but
  `768 - (1280 - 78) = -434`, so the upward floor buffer rejects it;
- the west wall plane offset is `-51`, outside both wall radii `50` and `24`;
  the other nearby axis-aligned offsets have magnitudes `255`, `101`, and
  `103`.

The module checks the supporting US/JP vertex and triangle-word receipts
directly from the generated initializers.

Under the existing fifteen-owner stock Area-1 abstraction,
`ink_first_query_has_no_modeled_stock_dynamic_floor_candidate` excludes every
dynamic owner at `q`: the top is too high for the 78-unit query allowance and
every non-top owner is horizontally disjoint.

This still does **not** prove that a live retail query returns `NULL`.
Completeness and order of the real static and dynamic partition lists remain a
Clight refinement obligation.

## Conditional local and PU countermodels

The local graphical sample is:

```text
Object   = (-2048,  768, -1024)   // cached warp collision
State    = (-2200,  768, -1024)   // first-query diagnostic
Graphics = (-2048, 1791, -1024)   // top-face sample
```

The PU graphical variant changes only X:

```text
Graphics = (63488, 1791, -1024)
signed16(63488) = -2048
```

For both variants, Rocq checks the top-face edge/arithmetic witness, the
78-unit retry condition, the modeled disappeared-action snap, the later
State-to-Object copy, and the final modeled platform proximity.  The theorems
are:

```coq
ink_local_conditional_control_flow_countermodel
ink_pu_conditional_control_flow_countermodel
```

They are conditional on the real first query returning `NULL` and the retry
selecting a live top-owned surface.  They do not prove allocation ownership,
list selection, branch reachability, collision-array retention, or delayed
warp continuation.

## What ordinary and PU movement can and cannot create

`MarioThreeView` separates State, Object, and Graphics.  A State-only writer
may choose an arbitrary next State coordinate while leaving Object and
Graphics untouched.  No locality or displacement-magnitude assumption is
used.

The proved invariant is:

```coq
state_only_prefix_preserves_collision_and_fallback_samples
```

Consequently:

```coq
state_only_prefix_cannot_create_object_graphics_split
arbitrary_ordinary_or_pu_state_only_prefix_needs_preexisting_split
```

This covers ordinary wall pushes, platform displacement, and PU-sized State
endpoints **when they are State-only**.  Starting from `Object = Graphics`,
none of them can manufacture the Object/Graphics split Ink's schedule needs.
PU floor aliasing changes surface lookup; it is not itself a full-float Object
or Graphics writer.

The retry needs less separation than final platform capture.  Because
`find_floor` accepts a floor up to 78 units above its query, a warp-overlapping
Object and a graphical query for a top floor at Y at least `1281` require:

```text
GraphicsY - ObjectY >= 385
```

`ink_ready_requires_at_least_385_graphics_y_separation` proves this for
signed-16-range graphical Y.  The dry ordinary source census finds a largest
relevant positive visual offset of `45`, and
`dry_graphics_offset_cannot_supply_top_retry` proves the corresponding closed
arithmetic exclusion.

For context, a deliberately conservative generic source/type envelope is
below `208`: water pitch and swimming bob can compose across the floor-hit
branch.  The upper warp is dry, so that generic water bound is not the
route-specific bound.  A prepared `ACT_LONG_JUMP_LAND` state with pre-frame
`actionTimer = 4` is a precision exception to any claim that quicksand always
lowers Graphics: after the timer increment, the exact binary32 calculation
changes depth from `1.1f` through `1.350000023841858f` to
`-2.6500000953674316f`, so the final subtraction raises Graphics by
`2.6500000953674316f`.  Rocq checks those bit patterns in
`prepared_landing_quicksand_raise_arithmetic_checked`.  The value remains
below `45`, this prepared action requires a prior A edge, and the upper-warp
floor is not quicksand.

## Writer census and its formal boundary

The source audit found no stock clean-SSL-Area-1 writer that independently
moves Mario Graphics by the required amount:

- normal ground, air, stationary, pole, hanging, and tornado paths synchronize
  Graphics from State;
- shell rendering contributes `+42` in air or `+45` on the ground;
- the large full-XYZ anchor writer is used by Chuckya/King Bob-omb anchoring,
  neither of which belongs to stock SSL Area 1;
- `bhvMario` does not set `OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE`;
- allocation initialization and SpawnInfo setup occur before `init_mario`,
  which synchronizes State, Object, and Graphics; and
- a stale `gMarioPlatform` pointer writes State, not Graphics.

`mario_entry_coordinate_sync_source_shape_{us,jp}` checks ordered initializer
and raw-slot syntax anchors.  It is deliberately not advertised as a memory
equality theorem.  The behavior-script interpreter and graph-node spawn
writer are outside the current generated translation-unit set.

The remaining source-to-semantics obligation is
`Area1InkWriterCoverageObligation`: every reachable clean no-A Area-1
position transition must refine to the audited State-only, synchronization,
or bounded-Graphics writer relation.  The related entry-memory equality and
action/spawn closure must also be proved.

## Remaining obligations

The decisive unfinished work is:

1. prove entry-time Object/Graphics synchronization in live US/JP Clight
   memory;
2. prove complete clean Area-1 writer/action/spawn closure, including bodies
   outside current generated coverage;
3. execute the real wall and surface-list code to prove or refute the first
   `NULL` result at a reachable State sample;
4. execute the retry over a live top-owned surface and prove actual selection;
5. prove collision-array retention through the fallback and action change;
6. if a top platform is captured, prove its allocation epoch, unload/reuse,
   delayed-warp retention or recapture, and destination-area first apply; and
7. continue to a target collision and newly set Act 3 or Act 6 bit.

`Area1InkPrestateReachabilityObligation` names the missing constructor.  No
reachable clean constructor and no retail target-bit counterexample was found.
The ultimate theorem remains unproved.
