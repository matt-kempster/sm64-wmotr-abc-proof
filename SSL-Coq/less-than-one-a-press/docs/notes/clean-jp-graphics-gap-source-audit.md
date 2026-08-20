# Clean JP Graphics/Object-gap source audit

## Scope and result

This note audits the original JP source at decomp revision
`9921382a68bb0c865e5e45eb594d9c64db59b1af`.  Its question is deliberately
narrow:

> Can a clean retail JP execution in SSL Area 1 create the positive
> `Mario.graphicsY - Mario.objectY` gap needed by the timer-131 upper-warp
> retry?

The current timer-131 midpoint construction needs a gap of at least `960`.
No source-backed clean Area-1 writer found in this audit can create that gap.
The ordinary positive writers are the riding-shell offsets (`+42` and `+45`)
and submerged visual offsets (covered by the existing conservative `208`
model).  Platform/PU displacement writes MarioState, not Mario Graphics or the
raw Mario Object.  The only genuinely unbounded source shapes found are not
clean stock Area-1 shapes:

1. a Chuckya/King-Bob-omb anchor writing Mario Graphics from a different
   object;
2. the generic behavior tail if Mario's `oFlags` unexpectedly contains
   `OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE` together with a large
   `oGraphYOffset`; or
3. repeated `sink_mario_in_quicksand` calls with a negative depth in a
   non-reanchoring action, notably a stalled automatic dialog.

This is strong negative source evidence, not a completed retail theorem.
The conclusion still needs linked Clight execution, object-pool/non-aliasing,
stock-spawn closure, and no-A action-state reachability proofs.  In
particular, this note must not be cited as proving the ultimate two-star
impossibility theorem.

## Boundary and frame order

The relevant source order is in `src/game/object_list_processor.c`:

1. surface objects update;
2. `apply_mario_platform_displacement()` writes MarioState;
3. `detect_object_collisions()` caches overlaps using raw Object positions;
4. non-terrain object lists update in the order
   `SPAWNER, SURFACE, POLELIKE, PLAYER, PUSHABLE, GENACTOR, DESTRUCTIVE,
   LEVEL, DEFAULT, UNIMPORTANT`;
5. Mario's player-list behavior runs `execute_mario_action()`, then
   `copy_mario_state_to_object()`;
6. later object lists run;
7. rendering later calls `geo_process_root()`.

Consequently, a State-only platform or PU displacement can make State differ
from Object and Graphics before collision, even by a very large amount, but
it preserves the already-existing Graphics/Object gap.  It cannot install
the gap that Ink's fallback needs.

`init_mario()` in `src/game/mario.c:1788-1856` starts from a synchronized
state: it initializes `quicksandDepth` to zero, copies the spawn position into
MarioState, raw Object position, and Graphics position, and chooses an idle or
water-idle action.  `set_mario_initial_action()` in
`src/game/level_update.c:306-365` contains no long-jump or long-jump-landing
entry case.

That is a direct source fact.  Proving that a particular clean JP course entry
executes those stores in live CompCert memory is still the existing
`CleanJPGraphicsGapEntryMemoryRefinementObligation`.

## Positive writer classification

The following table is a classification of source shapes, not yet a linked
whole-program theorem.

| Writer family | Exact effect on `GraphicsY - ObjectY` | Stock clean Area-1 assessment |
| --- | --- | --- |
| Ordinary ground/air/automatic steps | Step helpers normally copy final State to Graphics; the Mario behavior then copies State to Object | Reanchors to zero; call-path completeness remains to be proved |
| `act_riding_shell_air` | Reanchors through `perform_air_step`, then adds `42.0f` to Graphics Y | Source-backed and far below `960` |
| `tilt_body_ground_shell` | The ground step reanchors, then adds `45.0f` to Graphics Y | Source-backed and far below `960` |
| Water pitch | Adds `60 * sin(pitch)^2`, hence at most about `60` | Source-backed expression; exact binary32/live-state refinement remains open |
| Surface-swim bob | Adds `sBobHeight * sin(sBobTimer)`, with the audited s16 state giving a positive contribution below `148` | Existing abstract composition uses the conservative bound `208`; not a linked retail bound |
| Quicksand sink | `GraphicsY := GraphicsY - quicksandDepth` | Cannot raise Graphics when depth is nonnegative; negative-depth closure is discussed below |
| Generic behavior tail | If Mario flag bit zero is set, `GraphicsY := ObjectY + oGraphYOffset` | All 40 stock field-21 behavior commands are fixed offsets at most `+240`, and Mario has none; a non-stock `+1160` offset succeeds geometrically but still needs corruption/alias/lifetime provenance |
| Chuckya/King-Bob-omb anchor | `obj_set_gfx_pos_at_obj_pos(gMarioObject, anchor)` | Exact call/behavior chain is checked, but neither parent is selected or directly spawned by the audited stock SSL Area-1 sources |
| Platform/PU displacement | Writes MarioState XYZ only | Preserves the prior Graphics/Object gap exactly |
| OOB graphical fallback | Copies Graphics XYZ to State; the behavior tail then copies State to Object | Consumes/closes a prior gap unless a later interaction changes State |
| Instant warp | Writes State and raw Object by the same displacement, not Graphics | No Area-1 instance; SSL Area-2/3 instant displacement is zero |
| Normal renderer/animation | Reads Graphics to build matrices; animation root translation changes the matrix, not Mario's stored Graphics position | Not a stored Graphics writer |

The `42` and `45` literals are not, by themselves, mathematical-real endpoint
bounds for arbitrary binary32 inputs.  The existing project correctly keeps a
separate live-range/binary32 obligation.  At the upper-warp live Y range this
is a small local arithmetic obligation, not a plausible route to `960`.

The automatic-action dispatcher in
`src/game/mario_actions_automatic.c:850-882` assigns
`quicksandDepth = 0.0f` before dispatching pole, ledge, grabbed, cannon, and
tornado actions.  This is different from
`ACT_READING_AUTOMATIC_DIALOG`, which belongs to the cutscene group and does
not perform that reset.

The generic behavior-tail risk is similarly precise.  `allocate_object()`
zeroes the raw-data fields containing `oFlags` and `oGraphYOffset` on slot
allocation.  `bhvMario` sets `OBJ_FLAG_0100` (bit 8), whereas
`obj_update_gfx_pos_and_angle()` is guarded by
`OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE` (bit 0).  The corrected bilateral census
uses the unsigned slot view read by that guard, enumerates all 30 canonical
flag writers and 28 offset writers, then recursively follows every ordinary
direct callee from Mario's three callbacks; none reaches either word, even
through another literal raw-data union view.  The exact `OR_INT` handler and
bit theorem show that Mario's `OR 0x100` command preserves bit 0.  Turning
that source result into a retail invariant still requires live list/slot
identity, indirect/external call framing, and exclusion of aliases, OOB
stores, forged behavior, and reuse.

`InkTimer131ProducerClosure.v` replaces the earlier “no writer found” wording
with a complete initializer result.  Its opcode-neutral scan finds exactly 40
US/JP behavior-data words targeting raw float field 21; all 40 dispatch to
`bhv_cmd_set_float`, and their signed payloads range from `-288` through a
maximum of `+240`.  No ADD/random/SUM command targets that field, and
`bhvMario` contains no field-21 command at all.  Since a timer-131 top retry
from upper-warp contact needs at least `+632`, no stock behavior payload can
install it.  Conversely, the same finite face evaluator accepts Graphics
`(-2048,1928,-1024)`, exactly `+1160` above the raw warp-center Object.  The
tail is therefore geometrically capable only after a non-stock field value or
equivalent memory escape.

## Fire-particle `prevObj`: rejected false positive

The fire-particle path initially looks like a Mario Graphics writer, but it is
not one.

The real order is:

1. burning Mario actions request `PARTICLE_FIRE`;
2. Mario's player-list behavior spawns `bhvFireParticleSpawner` in the
   later `OBJ_LIST_DEFAULT`;
3. `bhv_flame_mario_loop()` assigns `gMarioObject->prevObj = o`, where `o` is
   the flame, and stores flame-local coordinates `(40, -120, 0)`;
4. Mario's geometry invokes `geo_move_mario_part_from_parent()`;
5. that callback sets local `obj = gCurGraphNodeObject` (Mario), but calls
   both mutators with `obj->prevObj` as their destination.

The destination distinction is explicit:

```c
obj_update_pos_from_parent_transformation(sp20, obj->prevObj);
obj_set_gfx_pos_from_pos(obj->prevObj);
```

`obj_update_pos_from_parent_transformation()` writes the `oPos` fields of its
second argument, and `obj_set_gfx_pos_from_pos()` writes the Graphics fields
of its argument.  Both therefore move the **flame**, not Mario.  The earlier
candidate calculation of a roughly `191`-unit bound describes a conservative
flame placement envelope; it is irrelevant to Mario's Graphics/Object gap
and must not be used as a Mario bound.

An exact source search finds only the flame behavior assigning
`gMarioObject->prevObj`.  The similar render callbacks in
`object_helpers.c`, `king_bobomb.inc.c`, `ukiki.inc.c`, and `bowser.inc.c`
also transform and copy `obj->prevObj`; they do not reverse the helper
arguments.  Their actor families are not stock SSL Area-1 spawns in any case.

The separate Chuckya path is real: `common_anchor_mario_behavior()` directly
passes `gMarioObject` as the first argument to
`obj_set_gfx_pos_at_obj_pos()`.  King Bob-omb reuses that anchor helper.  The
SSL global script loads a Chuckya model, but model loading is not object
spawning.  Neither the Area-1 level object list nor its macro-object list
spawns Chuckya or King Bob-omb.

That claim is now machine-checked across the generated source union.  The
cross-object helper has exactly one direct caller, the common anchor, and that
common anchor has exactly the Chuckya and King-Bob-omb anchor callbacks as
direct callers.  Their child behaviors occur only in the two parent behavior
arrays.  Neither parent appears in the Area-1 regular list, decoded macro
stream, or selected special presets; no generated C body directly mentions a
parent, and Chuckya's only initializer owner is the global macro-preset table.
This closes normal static provenance, not corrupted preset indices, forged
behavior pointers, indirect/external stores, or live object-pool semantics.

## OOB fallback and the interaction-stage vertical writer

`update_mario_geometry_inputs()` in `src/game/mario.c:1314-1367` performs the
first floor query from MarioState.  If it misses, it copies Graphics to State
and retries.  A second miss requests the death warp.  Interaction processing
still occurs after geometry input collection and before the later
`floor == NULL` early return.

The pinned `interaction.c` source has one direct vertical MarioState position
assignment: `bounce_off_object()` sets

```text
new StateY = target.oPosY + target.hitboxHeight.
```

This matters because a cached bounce may run after a double-NULL fallback and
before `copy_mario_state_to_object()`.

For a first gap starting from `GraphicsY = ObjectY`, however, ordinary stock
hitboxes do not turn this into a positive gap.  Let target down-offset be
`D`.  The cached vertical overlap condition gives

```text
old ObjectY <= target.oPosY + target.hitboxHeight - D.
```

After the bounce and State-to-Object copy,

```text
GraphicsY - new ObjectY <= -D.
```

The stock Area-1 bounce-capable hitbox sources audited here have nonnegative
down-offsets: Goomba `0`, Pokey `10`, Fly Guy `0`, small breakable box `20`,
jumping box `20`, and Koopa shell `0`; the other stock damage/flame/explosion
objects likewise use nonnegative offsets.  The two negative behavior-script
offsets found globally are the water-air bubble (`-150`) and Bowser tail
anchor (`-50`), neither of which is a stock Area-1 bounce target.  Thus this
source path cannot be the first positive-gap writer under the stock behavior
lineage.

This algebra is not yet the required behavior-script/Clight proof.  A final
proof must establish the active object's exact behavior, hitbox initialization
and scale, non-aliasing, and the cached-overlap branch in live memory.

Wall pushes and `push_mario_out_of_object()` alter X/Z, not Graphics Y.
`cur_obj_push_mario_away()` in later object lists also writes only MarioState
X/Z.  The only direct late raw-Mario-Object Y writes found in behavior code
are a butterfly's temporary add/subtract pair around an angle calculation;
the subtraction occurs in the same call with no behavior interleaving, and
butterflies are not stock SSL Area-1 objects.  Full-XYZ `set_mario_pos()` calls
from Dorrie and the tilting inverted pyramid are also absent from SSL Area 1.

## Negative quicksand depth is the important exception

An unconditional claim such as “every clean source frame has a gap at most
`208`” is not justified merely by the direct Graphics-writer census.

`sink_mario_in_quicksand()` runs after action dispatch and subtracts the
stored depth from Graphics Y.  Direct source search gives these depth-writer
families:

- entry initializes zero;
- airborne, submerged, and automatic-action dispatchers reset zero;
- `mario_update_quicksand()` resets, clamps to at least `1.1`, and then adds a
  nonnegative sinking speed;
- quicksand-jump landing subtracts but immediately clamps back to `1.1`;
- quicksand death adds `5`; and
- `common_landing_action()` adds
  `(4 - actionTimer) * 3.5 - 0.5`.

All ordinary four-frame landing descriptors invoke the last formula only for
timers `1..3`, so their additions are positive.  The six-frame long-jump
landing reaches timer `5`, where the addition is `-4`.  With the preceding
moving-action quicksand update, the checked prepared example produces a depth
near `-2.65`, hence a one-frame visual raise near `+2.65`.

The source action graph is favorable to the no-A claim:

- the only literal producer of `ACT_LONG_JUMP_LAND` is `act_long_jump()` on a
  landing result;
- the long-jump action is selected in `act_crouch_slide()` only under
  `INPUT_A_PRESSED`; and
- the clean entry initializer does not choose either action.

Therefore a no-`A_BUTTON_PRESSED` execution should make the negative-depth
producer unreachable.  That statement is still a linked action invariant,
not something established by literal-occurrence search alone.

The reason this invariant is essential is a real source-level
over-permissive counterexample: `act_reading_automatic_dialog()` does not
reanchor Graphics and can remain at dialog state `10`.  If a negative depth
is injected or inherited, the unconditional sink raises Graphics again on
every stalled frame.  Exact CompCert binary32 reaches a zero-base endpoint at
least `960` after 363 calls; proving the corresponding delta from an arbitrary
live Graphics base remains an explicit refinement obligation.

Stock SSL Area 1 has no door, star door, warp-door spawn, Chuckya, or King
Bob-omb.  Its wooden signs use `ACT_READING_SIGN`, and its Bob-omb Buddy uses
`ACT_READING_NPC_DIALOG`; both handlers copy State to Graphics every frame.
`ACT_WAITING_FOR_DIALOG` does the same.  `ACT_DISAPPEARED` calls
`stop_and_set_height_to_floor()`, which writes State Y and copies State to
Graphics.

Automatic-dialog reachability is not eliminated solely by that object
inventory.  Exact literal call-site search also finds star-collection
milestone dialogs.  Land and water star-dance handlers reanchor Graphics each
frame, but they do not reset the scalar `quicksandDepth`; a transition into an
automatic dialog could therefore preserve an already-negative depth.  For a
clean no-A proof, the decisive closure is `quicksandDepth >= 0` at every
non-reanchoring sink, rather than the stronger and potentially false claim
that automatic dialog is globally unreachable.

## Stock Area-1 object closure

The explicit Area-1 objects in `levels/ssl/script.c` are the pyramid top, Tox
Boxes, Tweesters, Klepto, the Act-2 star, the hidden-red-coin-star controller,
and warp objects.  `levels/ssl/areas/1/macro.inc.c` adds Goombas, Pokeys,
breakable and jumping boxes, a Bob-omb Buddy, coins, cap/shell boxes, a cannon,
wooden signs, 1-Ups, Fly Guys/fire Fly Guys, Bob-ombs, and fire spitters.

This inventory supports the following source exclusions:

- no Chuckya/King-Bob-omb Graphics anchor;
- no door-origin automatic dialog;
- no Dorrie or tilting-inverted-pyramid late full-XYZ State writer;
- no butterfly temporary raw-Object writer;
- no water-air-bubble or Bowser-tail negative-down-offset bounce target; and
- fire interactions are reachable, but the fire `prevObj` callback moves the
  flame rather than Mario.

The global level-script functions linked by SSL load common models, including
the Chuckya model, but do not instantiate those objects.  A whole-program
proof must additionally close all child spawns, behavior changes, macro
respawns, debug-only spawn paths, object-slot reuse, and pointer aliasing.

## Source closure versus proved retail closure

The audit used two layers:

1. an exact-revision syntactic census of direct writes to MarioState position,
   raw Mario Object position, Mario Graphics position, `oFlags`,
   `oGraphYOffset`, `quicksandDepth`, and `prevObj`; and
2. manual tracing of the generic helper call sites and stock SSL Area-1
   object/behavior sources.

That supports a source-level classification.  It does **not** yet prove that
every linked retail transition refines the classification.  The following
obligations remain narrow and decisive:

1. **Entry memory.** Connect the clean JP entry call chain to synchronized
   State/Object/Graphics fields, zero depth, Mario `oFlags` bit zero clear,
   and zero `oGraphYOffset` in live Clight memory.
2. **No-A action closure.** Prove that no frame with false
   `A_BUTTON_PRESSED` reaches `ACT_LONG_JUMP` or
   `ACT_LONG_JUMP_LAND`, including all interaction/action-loop transitions.
3. **Unsynchronized sink closure.** Prove `quicksandDepth >= 0` at every sink
   whose action has not first reanchored Graphics.  This discharges the
   automatic-dialog amplification case.
4. **Stock external-writer closure.** Prove that the Area-1 level script,
   macro spawner, all child-spawn/behavior-change paths, and retail debug
   configuration cannot create a Chuckya/King-Bob-omb anchor or another
   writer targeting Mario Graphics.
5. **Mario behavior-field invariant.** Lift the checked allocation zeroing,
   no-offset Mario script, bit-8-only flag command, and `+240` all-stock bound
   through the live Mario slot and every interpreter step.  Exclude or realize
   forged commands, slot reuse, aliases, OOB/external stores, and every other
   mutation that could supply the checked non-stock `+1160` witness.
6. **First-NULL interaction refinement.** Execute the actual collision cache,
   OOB retry, interaction dispatch, stock hitbox initialization, and
   State-to-Object copy, establishing the nonnegative-down-offset bounce bound.
7. **Render ownership.** Prove that callbacks receive the expected object and
   that `prevObj`/helper destinations do not alias Mario; culling may preserve
   a prior gap but cannot create one.
8. **Binary32 and compiled behavior.** Prove the local shell/water arithmetic
   over the live range and handle any relevant out-of-range float-to-integer
   conversion or other implementation-dependent behavior directly.

The project already names the main projections as
`CleanJPGraphicsGapWriterCoverageObligation` and
`CleanJPUnsynchronizedSinkDepthRefinementObligation`.  The source audit above
explains exactly what must be proved to instantiate them without an oracle.

## Bottom line

The source audit found no clean retail JP gameplay writer that installs the
required `>=960` Graphics/Object Y gap.  The most suspicious newly examined
path—the fire-particle `prevObj` callback—does not write Mario Graphics at all.
Ordinary motion, walls, platform/PU displacement, stock interactions, signs,
NPC dialog, and the normal renderer either write State only, reanchor the
views, or provide small bounded visual offsets.

The only still-credible gap-installation obligations are now sharply isolated:
an illegal/unexpected Mario behavior flag or alias, a non-stock anchor actor,
or negative-depth persistence into a non-reanchoring cutscene.  Source control
flow strongly excludes the last case under zero A edges because its sole
negative-depth producer descends from an A-edge long jump.  Proving that
control-flow and object-memory closure in linked JP Clight remains necessary
before claiming the retail route impossible.
