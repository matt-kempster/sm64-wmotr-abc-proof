# Executed animation and sound helpers

US/JP only; pinned source `9921382a68bb0c865e5e45eb594d9c64db59b1af`.

The active cog capstone now uses a stronger slide-kick caller theorem with
**four**, rather than seven, remaining helper-execution premises. It executes
the real animation setter, animation end test, and sound request. It still
does not prove a reachable Pedro state, preservation across the following
knockback action, accepted particles, or a preserving RNG choice.

## Complete sound request

`SoundRequestExecution.v` proves execution of the generated `play_sound` body
for every queue index from 0 through 255. The US and JP function bodies are
definitionally equal. The proof constructs the actual three stores from
entry permissions:

1. Write `soundBits` at the selected eight-byte queue entry.
2. Write the position pointer four bytes later in that entry.
3. Increment the eight-bit request count, including its normal wrap at 255.

The queue has 256 entries and 2,048 initialized bytes in both generated
programs. Its structure size and field offsets are checked separately.
The array-offset lemma proves the promoted index remains within those bounds.
Successful stores are derived from `Mem.valid_access`; no sound-callee
execution is assumed. This is mathematical execution of unchanged game code,
not an operation on emulator memory.

All loads outside the queue and counter blocks are preserved. A corollary
derives preservation of `gRandomSeed16` from the distinct global bindings;
another derives Mario's position/floor preservation from block separation.
The body contains no calls. A silent CompCert trace by itself would not be
enough to establish absence of gameplay RNG calls.

## Complete cached animation path

`SlideKickAnimationExecution.v` executes the real `load_patchable_table`:

- The table count includes animation 140 and its offset/size cells are readable.
- The computed source address equals the list's existing `currentAddr`.
- The compared pointer satisfies CompCert's validity requirement.

The helper returns false with identical memory. The proof does not take the
DMA branch or assume a DMA result. Its table-entry stride is eight bytes;
entry 140's fields are at table offsets 1,128 and 1,132.

The real `set_mario_animation` calls that helper. Given animation ID 140 is
already selected, the setter keeps memory unchanged and returns the loaded
frame with the generated signed-short return conversion. The real
`is_anim_at_end` also keeps memory unchanged and returns false when
`animFrame + 1 != loopEnd`. Frame and loop end remain explicit live-memory
values; the theorem does not assume an invented animation asset.

The Mario, animation and table field offsets used by these executions are
checked against both versions' generated composite environments. Cache
contents, compatible linked bindings and the entry image are still premises.
They have not been established by a controller replay or by normal TTC entry.

## Stronger caller, exact remaining premises

`SlideKickHelperDischarge.generated_slide_kick_with_animation_and_sound_discharged_us_jp`
consumes these execution proofs and the original generated caller theorem.
It is used by `MainTheorem.checked_ttc_cog_dust_action_frontier_us_jp`, which
is used by the active `checked_ttc_cog_local_mechanism_us_jp` capstone.

The caller starts with OFF_FLOOR set and A clear. Its animation cache and
non-ended-frame image are supplied at entry. At the later sound boundary,
the request queue is valid and disjoint from Mario. The actual sound stores
are constructed, followed by the caller's dust-bit store. The final particle
mask is 3: vertical stars plus dust.

The following actual generated helper executions remain explicit premises:

| Helper | Required path/result |
| --- | --- |
| `update_sliding(m, 1.0f)` | Executes from the initial memory |
| `perform_ground_step(m)` | Returns wall-stop result 2 |
| `mario_bonk_reflection(m, TRUE)` | Completes before the star-bit store |
| `set_mario_action(m, ACT_BACKWARD_GROUND_KB, 0)` | Returns true |

Their four position/floor preservation equalities also remain premises.
The sound preservation equality is now proved, and the two animation
boundaries use identical memory. The caller theorem retains explicit terrain,
object-pointer and particle-flag loads, and writable particle flags after
the action transition. These entry and intermediate facts are not erased by
an axiom audit; they appear in the theorem statement.

The resulting ten-boundary position/floor equality is conditional on those
four remaining helper paths. It asserts neither cog-yaw preservation nor
preservation inside the unresolved callees. It cannot justify repeating the
slide-kick body: the next action is backward ground knockback.

## Address refinement and full-frame work still open

This work does not close particle allocation's N64 address boundary.
`SegmentedPointerBoundary.v` still proves that standard Clight cannot execute
the first integer shift in `segmented_to_virtual` from the symbolic global
pointer passed by the generated particle path. Proving a calculation on a
numeric argument would not justify replacing that symbolic argument or
dereferencing the result. A complete refinement must connect US/JP address
encoding, segment-table contents, relocation, valid data access and behavior
dispatch to the generated caller and allocator.

The next execution work is the four helpers above, then the dispatcher,
slide-kick entry/bounce and following knockback update with real surface
queries. `update_sliding` also reaches the existing `sqrtf` semantic boundary;
the retail instruction receipt is not a CompCert external-call contract.
The remaining object/particle and camera paths must be scheduled from a
legal in-spot state, with every gameplay RNG draw in order. The source census
is unchanged by this continuation and is not a substitute for that execution.

## Build and notice diagnosis

The complete Pedro project builds through the configured pipeline. The first
cache proof attempt exposed excessive reduction of a symbolic struct stride;
the bounded build reported `Fatal error: out of memory`. A small entry-address
lemma now resolves the stride first. The corrected full build passes with a
4-GiB virtual-memory cap. No generated game file was changed, and no new
emulator experiment or game-memory/code edit was performed.

The full proof-hole check, authenticated source-coverage check for all 81
RNG-bearing files and 82 generated outputs, and root proof-discipline audit
pass. The active-capstone assumption output is identical to its baseline;
only the existing Coq/CompCert assumptions occur. The generated files were
unchanged, so their earlier two-pass regeneration receipt remains applicable;
no new regeneration is claimed. The durable check results and code hashes are
in [the validation receipt](../inputs/helper-execution-validation.json).

This observed compiler-resource failure is separate from the user's content
notice. This continuation has no observed content-check or approval rejection.
The notice's exact trigger remains unknown; see
[the notice review](content-notice-review.md). The existing restrictions on
ordinary gameplay and read-only observation remain in force.
