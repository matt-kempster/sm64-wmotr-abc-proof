# Cog slide-kick helper continuation

US/JP only, source pin `9921382a68bb0c865e5e45eb594d9c64db59b1af`.

The requested checklist item is **partly discharged**. The active slide-kick
caller now has two helper execution/preservation premises, down from four:
`update_sliding` and `perform_ground_step`. The real no-wall reflection and
backward-knockback transition execute from their specified entry memory,
including their nested helpers. Their position/floor preservation is proved.

The resulting request also executes the original moving-dispatcher dust tail.
It survives with input 4; input 516 instead replaces dust with a wave-trail
request. An already active dust bit causes the complete `spawn_particle`
function to skip allocation. Clear-bit allocation, the complete dispatcher,
entry/bounce and following knockback update **remain open in an actual cog
state**. No in-spot dust event, sustained entry or preserving RNG control has
been established.

## Corrected TTC terrain state

The earlier caller required `terrainSoundAddend = 0`. That is not the dry
ordinary-floor TTC case. TTC's area terrain is `TERRAIN_STONE`, terrain row 1;
the row's default sound is `SOUND_TERRAIN_STONE = 3`. These are different enums.
The generated sound-table entry is checked in both versions.

`CogActionExecution.generated_cog_stone_terrain_addend_us_jp` executes the full
generated terrain helper with level 14, terrain row 1, a readable retained
floor of type 0, and the actual dry comparison false. It returns `196608`
(`3 << 16`) with identical memory. Accordingly both caller layers now use
slide sound bits `335740929`, replacing the earlier `335544321`.

The terrain execution is consumed by the active capstone, but connecting it
to the end of the full ground step remains part of that helper obligation.
The retained type-0 floor is an explicit hypothesis. It is not identified
with the attempted cog surface, and no collision-query selection is inferred
from the area terrain alone.

## Executed reflection and transition

`CogReflectionExecution.v` executes the generated `mario_set_forward_vel` for
the supplied speed and yaw, with the actual sine/cosine table reads. It
constructs all five stores: forward speed, slide X/Z speeds and velocity X/Z.
It proves a frame rule for every load outside those cells. The angle cast and
shift yield an index below 4096; both four-byte table reads lie within the
generated 5120-float table. Table contents and readable entry cells remain
memory hypotheses, rather than invented trigonometric values.

The complete no-wall `mario_bonk_reflection(m, TRUE)` then:

1. Reads a null `m->wall` and the Mario object pointer.
2. Executes the real three-store sound queue operation with HIT bits `71614593`.
3. Reads forward speed after the sound operation.
4. Executes the real velocity setter with its binary32 negation.

The sound and velocity stores are constructed from entry permissions. Queue,
counter and sine-table global separation is checked from their bindings where
applicable. The proof derives Mario's position/floor preservation; it does
not assume a reflection execution or a reflection frame equation. It covers
this no-wall branch, not every possible wall normal or reflection branch.

`CogActionExecution.v` also executes the real `mario_get_floor_class`,
`set_mario_action_moving` and `set_mario_action` for the slide-to-backward-ground-
knockback transition. The floor pointer's comparison validity is derived from
the readable floor-type cell. The first two functions leave memory unchanged
on the specified path. The last performs seven stores:

| Store | Result |
| --- | --- |
| Flags, first write | Clear action-sound and Mario-sound played bits |
| Flags, second write | Clear the additional bit for the old non-air action |
| Previous action | `ACT_SLIDE_KICK_SLIDE` (`8389722`) |
| Action | `ACT_BACKWARD_GROUND_KB` (`132194`) |
| Action argument | 0 |
| Action state | 0 |
| Action timer | 0 |

The stores and all final action fields are proved, with a frame rule that
preserves the particle mask, terrain addend, position and floor cells. Separate
object/cog/seed blocks also fall within the frame rule. This is not a proof
that a complete cog update or a whole frame preserves those blocks.

## Stronger caller and dust clearing

`CogSlideExecution.generated_cog_slide_with_two_helpers_us_jp` consumes both
new helper executions and the earlier animation/sound results. Its memory
family explicitly requires:

- The already selected, cached slide animation 140, with a non-ended frame.
- The two unresolved sliding/ground executions and their two anchor equations.
- After the ground step: terrain 196608, a null wall, a readable retained
  type-0 floor in terrain row 1, action `8389722`, zero intended magnitude,
  input 4 and a clear Mario particle-request mask.
- The actual speed/yaw/table cells, writable action/velocity/particle fields,
  sound slots and stated block separation.

No reachable memory satisfying all of these has been exhibited. In particular,
zero intended magnitude is a restriction of this state family, not a theorem
about arbitrary input continuations. The slide and ground executions must
still establish their intermediate images from a real cog state.

After reflection the proof constructs the vertical-star store, the action
transition, the second sound request and the dust store. The second request
uses the actual incremented eight-bit queue index, including wraparound; it
does not reuse an arbitrary fresh sound-queue image. The conclusion supplies
the complete generated slide caller execution, mask 3, input 4, action 132194,
and the ten-boundary position/floor equality.

`CogDustClearing.v` selects the original dispatcher suffix after its action
switch and executes both relevant cases with `cancel = 0`:

| Input mask | Original tail's stores | Final particle mask |
| --- | --- | --- |
| 4: OFF_FLOOR, IN_WATER clear | None | 3: dust + vertical stars |
| 516: OFF_FLOOR + IN_WATER | OR 1024, then clear bit 1 | 1026: wave trail + vertical stars |

The dry execution is composed directly into the stronger caller's conclusion,
using its proved final input load. Both tail cases preserve position/floor.
The preceding cancellation/quicksand checks and action switch are not yet a
complete dispatcher execution. A suffix execution must not be described as
the complete function.

## Particle acceptance and the following action

`CogParticleAcceptance.v` executes the complete generated `spawn_particle`
function when the requested active dust bit is already set, allowing other
active bits too. It returns with identical memory before reaching allocation
or position-copy calls. There is no callee-execution hypothesis in this branch.
The request word in `MarioState` and the active-particle word in the Mario
object are distinct fields; mask 3 in the former does not establish a clear
bit in the latter.

The active capstone pairs this rejection with the existing clear-bit caller
proof and `SegmentedPointerBoundary.v`. The clear-bit caller still assumes
the allocator and position-copy executions. Standard Clight keeps its
behavior argument as a symbolic `Vptr`; the first integer shift in the real
`segmented_to_virtual` cannot evaluate that pointer. No numeric-address
substitution, invented allocator or new external-call axiom closes this gap.
The actual bit, pool reserve, particle-list order, and both the dust and
vertical-star consumers must be checked before counting ordered RNG draws.

The caller changes the next action to backward ground knockback. The generated
`act_backward_ground_kb` calls `common_ground_knockback_action` with animation
123 and threshold 22. The earlier cache-hit result for already selected
animation 140 cannot execute that animation transition. Heavy-landing/voice
sounds, the animation load, acceleration and subsequent ground step still
need execution. The airborne slide-kick entry also retains the real bounce
path before the sliding phase. Neither path is replaced by another invocation
of the proved sliding caller.

## Remaining work and validation

The unchecked requirements are the real sliding execution, full surface-query
ground execution, complete dispatcher, entry/bounce and successive knockback
updates, then accepted particle/object/camera scheduling in the preserving cog
state. Sliding reaches external `sqrtf`; the authenticated retail instruction
receipt is still not an external semantic contract. These and the N64 address
refinement are substantive boundaries, not proof-hole-check failures.

The [validation receipt](../../inputs/cog-transition-validation.json) records
the final build, proof-hole/source gates, active assumptions, discipline audit
and canonical code hashes. Generated game files are unchanged. There were no
new emulator experiments, game-memory edits or game-code edits in this work.
Bounded proof-search timeouts during development were resolved by keeping
symbolic arithmetic folded and matching actual memory reads directly. No new
content notice or automatic approval rejection was observed; the exact cause
of the user's earlier notice remains unknown.
