# Rank 9A — Can the 100-coin star replace a gate jump?

## Result

**The direct pole-pickup ledge trick fails, but Rank 9A as a whole remains
open.** Collecting the star while grabbing, holding, climbing, or handstanding
on the pole selects the standing dance, not the airborne ledge-check action.
The standing dance's height-setting operation replaces Mario's height with
his cached floor height; it does not preserve the handstand elevation as a
departure. A different cached floor would need its own explanation.

For airborne pickup, the useful question is now more concrete: can Mario
collect a properly placed star while descending beside the right wall?
There is a consistent local wall/ledge geometry to test. It is **not** a
controller-reachable placement or an executed collision sequence. In
particular, this tranche does not prove a no-A route to either target star.

## What the new Coq code establishes

The source authority is the project's pinned decompile revision
`9921382a68bb0c865e5e45eb594d9c64db59b1af`, through the generated US/JP Clight
files. The new proofs use the actual selected program's global environment.

| Result | Checked scope |
| --- | --- |
| Six ordinary pole poses choose the standing dance | One connected Clight execution of the three action-flag tests and the no-exit selection; reads real memory and leaves memory unchanged |
| An action with the airborne flag chooses the falling star-grab action | The final airborne test overrides the earlier dance/water selections |
| Standing-dance initialization supplies no jump | The complete generated cutscene-initializer body returns without a call or memory write for this action |
| The dance's height snap discards the old Y | The generated load/store fragment reads `floorHeight` and writes it into `pos[1]`; X/Z and the sampled floor height are preserved |
| A rising Mario cannot pass this ledge check | The complete generated ledge-check body immediately returns false, with no memory write or outside call, when the loaded Float32 vertical velocity is positive |
| A descending west-wall candidate is geometrically consistent | Exact Float32 arithmetic, an actual generated ring triangle, and the existing target-side predicate agree; query selection and execution remain unproved |
| No nearby individually listed yellow coin supplies an obvious setup | All 15 such Area-2 initializer records are outside a generous horizontal rectangle around the shaft; this is not a live coin-motion census |

The six pole actions include both initial grabs, holding, climbing, the
handstand transition, and the full handstand. The generated automatic-action
dispatcher authenticates those six labels. Unlike the damage selector
investigated in Rank 11, the star selector does **not** treat `ON_POLE` as
airborne. That difference prevents transferring the successful staged
enemy-damage departure directly to a coin-star pickup.

### Exact execution boundaries

[Area2Rank9AStarSource.v](../../proofs/Area2Rank9AStarSource.v) resolves six
native bodies in the selected US/JP program and identifies the generated
selection, height-snap, and ledge-check fragments. US resolution uses the
existing normalized/repaired-program transport; JP uses the official link.
No independently invented game function substitutes for those bodies.

[Area2Rank9AStarExecution.v](../../proofs/Area2Rank9AStarExecution.v) proves:

- `rank9a_no_exit_selection_executes` and `rank9a_selection_smallsteps`:
  the selection window reads Mario's action at byte 12, with the already
  computed `noExit` temporary equal to one. This point is **after** the healthy
  pickup guard and stop-riding call. Reaching it, and preserving the selected
  value through the rest of the caller to the setter, remain obligations.
- `rank9a_every_attached_pole_pose_selects_standing_dance`:
  all six attached actions select `ACT_STAR_DANCE_NO_EXIT` (`4871`), not
  `ACT_FALL_AFTER_STAR_GRAB` (`6404`).
- `rank9a_standing_initializer_is_memory_identity`:
  the complete selected cutscene initializer for `4871` has no applicable
  switch case and changes no memory.
- `rank9a_dance_snap_executes_cached_height`:
  with a valid destination, the actual load at Mario byte 112 and store at
  byte 64 replace Y with the cached floor height. Loads at X, Z, vertical
  velocity, and floor-height offsets are preserved by **this fragment**.
  Other parts of the helper clear velocity and update graphics; their calls
  are not silently included in this fragment's memory frame.
- `rank9a_rising_ledge_check_returns_without_writes`:
  positive Float32 velocity loaded at byte 76 selects the immediate false
  return. This is the whole function body from an already entered call,
  before any wall/floor lookup. It does not require a guessed effect for a
  call that this branch never reaches.

The positive-velocity exclusion is about the **ledge-check instant**, not
necessarily the earlier star pickup. A rising airborne pickup could retain
its vertical velocity, later start descending, and reach a ledge check then.
That timing is not ruled out by the new theorem.

These are local execution theorems, not one uninterrupted execution from the
accepted SSL start. In particular, they do not assume that an arbitrary
cached floor is the correct floor, or that every intervening call is harmless.

## The surviving pole-side test target

The ordinary ledge routine samples walls at offsets 30 and 150, searches for
a ledge from Y+160, and places Mario 60 units through the selected wall normal.
Its wall-displacement dot-product rejection uses a strict positive test, so
zero horizontal speed alone is not a reason to reject the idea.

The following is a **proposed post-wall-query sample**, not a reached pose:

| Quantity | Candidate |
| --- | --- |
| Resolved near-side position | `(-51, 3800, 1331)` |
| Selected west-wall normal | `(1, 0, 0)` |
| Lower/upper wall sample heights | `3830` / `3950` |
| Shaft wall's vertical extent | `3712` through `3942` |
| Ledge-floor lookup height | `3960` |
| Desired returned floor | `3942`, a 142-unit rise |
| Ledge snap destination | `(-111, 3942, 1331)` |

[Area2Rank9AStarGeometry.v](../../proofs/Area2Rank9AStarGeometry.v) checks these
Float32 calculations and proves the endpoint satisfies the existing west-ring
target-side position test. It also authenticates the ring triangle
`(286, 301, 300)` in both generated meshes and checks that `(-111,1331)` lies
strictly inside its horizontal projection. The candidate is not merely on an
ambiguous triangle edge.

Still unproved: that the real two wall queries return lower-west-wall/non-null
and upper-wall/null; that no earlier floor or ceiling response diverts the
quarter step; that the ledge query selects this floor from the live list;
and that Mario reaches the sample with a suitable nonpositive velocity.
`AIR_STEP_GRABBED_LEDGE` is also **not** `AIR_STEP_LANDED`: the falling-star
handler explicitly changes to the standing dance only for the latter.
The snap and subsequent landing/action continuation must both be executed.

### The star-placement bottleneck

The existing prepared star-orbit mirror settles five units below home: a home
initialized from Mario Y+250 therefore gives a star at sample Y+245. Using its
normal vertical hitbox model, a Mario contact at Y=3800 requires that earlier
home-initialization sample to lie in **[3505,3715]**. A sample of 3560 gives a
star at 3805 and passes the vertical-overlap calculation.

This is not permission to place a star there. The home-initialization sample
need not be the same sample as the 100th-coin collision: their scheduling,
raw-Object copies, star orbit, horizontal travel, time stop, and first tangible
frame must be linked. The existing orbit mirror's live Float32/lifecycle
refinement remains open; the new interval theorem does not discharge it.

The follow-up [ordinary coin audit](rank9a-ordinary-coin-producers.md) expands
the original 15-yellow-coin census to all 41 fixed coin actors: 23 formation
children and three switched blues are also away from
`[-302,302] × [1029,1634]`. The generated parents/presets and conservative
separation are Coq-checked; exact formation expansion is a separate diagnostic,
not a complete live-memory preservation theorem. Regular Goomba drops are
the concrete mobile producer, with their real post-RNG launch now executed
in Coq. Neither their useful placement nor every later coin motion has been
proved or disproved. A different useful pickup location remains possible.

The lower published route also spends the coin star at the big steps before
the second pole. A new lower route must replace that earlier use or justify
a fresh resource through ordinary game behavior. The upper Act-3 plan uses
the star downstream, so using it at the elevator likewise needs a compatible
star-collection suffix. The coin star itself is index 6, not either target.

## Next decisive work

For the pole, first follow a normal Goomba defeat and its moving loot coin
through a controller history which creates the star in a compatible place,
or exclude every such drop; a different source needs its own evidence. Then reach an airborne
contact and a non-rising ledge check without consuming the resource earlier. The numeric
sample above is a useful test target, not a requirement imposed on all
possible counterexamples. A different wall, star height, or departure can be
investigated on its own evidence. If no compatible producer exists, close
that installation family before spending effort on the suffix.

The upper-elevator version remains separate: it needs its own coin placement,
moving-support phase, wall/ceiling queries and exit. The pole result is not
an elevator disproof. Unexpected selected floors and ordinary scheduling or
object-lifetime changes also require their actual execution, not a blanket
frame assumption. No outside-model memory-modification method is developed
here.

## Integration and verification

Validation on 2026-09-04: all three new modules and the updated active capstone
compiled with Coq 8.16.1 / CompCert 3.15. `check-rank9a` passed the proof-hole
scan, generated-link hygiene check, and all six focused assumption audits;
no project-local axiom was introduced. The atlas anchors, single-paragraph
Rank 9A sections, and changed notes' local links were also checked.

The 2026-09-05 producer follow-up compiled both additional modules and the
main theorem, and passed the expanded nine-audit `check-rank9a` target plus
the ultimate conditional theorem's assumption audit. Its separate diagnostic
checks all 41 fixed placements and 65,536 isolated coin-launch return values;
see the [producer notes](rank9a-ordinary-coin-producers.md) for the limits.

`current_rank9a_coin_star_gate_boundary` in
[MainTheorem.v](../../proofs/MainTheorem.v) consumes the selected-program
execution boundary, geometric/coin census, and the follow-up ordinary-producer
and live-memory launch boundaries. This adds checked
evidence to the active proof; it does **not** discharge the ultimate theorem's
whole-program refinement or open first-crossing writer obligations.

Run the focused check from the repository root:

```bash
SM64_PROOF_SWITCH=sm64-item-proof bash pipeline/build.sh \
  -C SSL-Coq/less-than-one-a-press check-rank9a
```

The active SSL `pipeline/check.sh` also checks one proof with bounded timing
and memory, using the correct logical namespace. Exact-bit comparisons avoid
expanding large, irrelevant Float32 representation proofs. The repository's
older root discipline script was attempted, but its build check targets the
uninstalled `sm64-proof` switch; its failure is separate from the active SSL
build and assumption audits.

[Back to Rank 9A](../no-a-route-atlas.md#route-rank-9a)
