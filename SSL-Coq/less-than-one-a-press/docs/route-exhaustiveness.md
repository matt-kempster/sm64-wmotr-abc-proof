# Route exhaustiveness and alternative access

The supplied transcript identifies two ordinary entrance-specific cuts:

- from the upper entrance, Mario begins inside the elevator cage and must leave
  it before reaching either target region;
- from the lower entrance, Mario must get above the second pole before reaching
  the shared upper part of the pyramid.

That observation does **not** by itself prove that these are the only possible
routes in the US and JP programs.  A proof by map intuition would miss exactly
the techniques that matter in the A-button challenge: displacement, clips,
object interactions, state retained across area changes, and memory aliases.

## Formal answer

`TranscriptRouteModel.v` now uses the first target-region observation in a
trace.  For that exact occurrence,
`first_target_access_requires_gate_a_or_explicit_bypass` proves the following
conditional classification:

```text
first Act 3 or upper-trigger access
  =>
    upper entry and
      (an A edge at the elevator gate or an earlier upper-bypass class tag)
  or
    lower entry and
      (an A edge at the second-pole gate or an earlier lower-bypass class tag).
```

The theorem requires `FirstTargetCutClassificationObligation`.  That record is
a broad, still-unproved coverage premise.  Its fields already require every
first target access to be classified as gate-or-tag.  It is not derived from a
game state, collision mesh, or Clight execution and is therefore not itself a
route-completeness result.  Naming it an obligation prevents the conditional
case split from being reported as the retail theorem.

If every explicit bypass tag is absent, the companion theorem
`first_target_access_with_all_bypasses_excluded_requires_a_edge` derives an
A-button edge.  With no A edge, the converse case split
`no_a_first_target_access_requires_explicit_bypass` exposes one bypass **tag**
before the first target observation.  It does not produce Mario/object states
or an executable bypass witness.

## Bypass classes

The upper and lower entrances have separate finite tag types, but both
enumerate the same families:

| Family | Why it is a route around the ordinary cut | Current status |
| --- | --- | --- |
| Platform displacement | A retained or reused platform pointer could move Mario outside the elevator or above the pole cut. | US clears the relevant pointer on spawn in the checked source shape; JP does not.  The archived JP spawning-displacement proof covers a restricted first-update model, not every reachable pointer and displacement. |
| Object push or moving geometry | An amp, goomba, grindel, spindel, elevator, or other object could carry, knock, or snap Mario across the cut. | Individual archived models give useful negative evidence.  There is no complete object/collision reachability proof. |
| Warp or area 3 | An instant warp or the Eyerok area could return Mario on the far side of a cut. | The modeled area-2/area-3 instant warp preserves the kinematic core because its displacement is zero.  Complete floor-trigger and area-transition reachability is pending. |
| Collision clip or tunnel | Wall/floor ordering, misalignments, quarter steps, or tunneling could avoid the intended path. | Pending Float32 and collision-mesh proof. |
| Parallel universe or out of bounds | Unbounded or wrapped coordinates could bypass ordinary geometry. | The archived project proves only a compact, partial model and explicitly lacks complete position-writer coverage. |
| Target relocation or substitution | Moving a target, changing its index, or creating a substitute target object could make route geometry irrelevant. | The certified-event model enforces the static Act 3 allocation/position/hitbox and the Act 6 controller parent, home position, and hitbox.  The Act 6 current position is fixed only at spawn because its animation moves it.  Derivation from Clight object allocation, deletion, slot reuse, and behavior parameters remains pending. |
| Macro or lifecycle anomaly | Trigger respawn, object reuse, unload/reload, or stale lifecycle state could change which objects exist. | Clean entry identifies five distinct static trigger objects, exact positions/hitboxes, and clear macro respawn bits.  Abstract consumption sets the matching macro bit and excludes an active same-kind trigger through reload/respawn.  Whole-program lifecycle refinement remains pending. |
| Save reload or corruption | A target bit could change without Mario reaching a star at all. | Coherent active/backup slots make the ordinary game-over reload unable to newly set either target bit in the executable save abstraction.  Incoherent reload and arbitrary writes remain explicit anomaly causes. |
| Memory or undefined behavior | Aliasing, stale pointers, or implementation-dependent operations could change Mario, objects, or save state outside the functional model. | Pending compiled-behavior and memory-refinement proof; it is not silently interpreted as ordinary ISO C. |

Finiteness makes the intended case names reviewable, but it does **not** make
the tags evidence-bearing.  `ObservedUpperBypass` and `ObservedLowerBypass`
currently carry only one of these tags.  The coverage premise and tag-absence
premises remain oracle-like until a projection gives each family precise state
and event semantics.  Every relevant US/JP Clight execution must still be
shown to fall into the ordinary gate branch or a semantically defined class,
and every reachable class must then be ruled out or turned into a genuine
counterexample.

## Source-level exclusions already isolated

`SourceExhaustiveness.v` proves within an executable finite inventory that the
seven normal SSL star sources use indices `0` through `6`; only the static
pyramid source uses target index `2`, and only the Pyramid Puzzle source uses
target index `5`.  Klepto, the area-1 static star, Eyerok, red coins, and the
100-coin star therefore do not alias either target.

The same module proves:

- the five trigger kinds are distinct and include `TriggerUpper`;
- coherent active and backup target bits make a backup reload unable to create
  a first target-bit transition; and
- a first target-bit transition in its writer model is caused by the matching
  normal star interaction, an incoherent reload, or an explicit
  corruption/unmodeled writer.

These are checked finite-model theorems.  The generated Clight syntax confirms
the relevant functions and constants are present, but the completeness bridge
from all machine executions to this writer inventory remains open.

## What would settle the question

There are two sound ways to finish:

1. define state/event evidence for each class, prove the Clight/collision
   refinement that constructs it, and prove every class unreachable for clean
   US and JP entries; or
2. find a reachable class, record the exact clean initial state and
   frame trace, and test whether it reaches a target region without an A edge.

Until one of those is done, the project proves a precise conditional answer,
not that the two transcript routes are globally exhaustive in the retail ROMs.
