# Working claim and scope

Last updated: 2026-07-14 (plain-English proof-boundary clarification).

## Game and source boundary

- Super Mario 64, North American release (`VERSION_US=1`).
- Canonical reference source baseline:
  `9921382a68bb0c865e5e45eb594d9c64db59b1af`.
- Available sibling checkout:
  `36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`.
- The Eyerok implementation, object fields, action constants, and movement
  helper are checked byte-for-byte against the baseline before generation.
  The sibling SSL script contains later conditional instrumentation, so the
  pipeline extracts the canonical script directly from the pinned Git object.
- Coq 8.16.1; CompCert 3.15 configured for 32-bit big-endian `ppc-eabi`.

## Definitions

- **Eyerok** means either spawned Eyerok hand unless a statement explicitly
  names the non-moving boss controller.
- **Height in the formal state** is a mathematical integer intended to
  represent the hand's absolute world Y coordinate. Eyerok's spawn/home Y is
  `-1534`; a home-relative rise is therefore intended as
  `absolute Y - (-1534)`. The proved `1196` and `2003` ceilings are Z values;
  their connection to original-game binary32 is open.
- **Adversarial modeled choices** are all nondeterministic edges allowed by the
  handwritten relations. It remains open whether they correctly cover every
  legal player position, attack, wall/edge outcome, and boss random selection
  in the original game.
- **Rises indefinitely** means that the heights along one infinite execution
  are unbounded above. A single high but finite jump is not an infinite rise.
  The handwritten relation uses mathematical integers for this definition;
  original-game hand position is binary32 and requires a separate observation
  relation.
- **Partial update** is the `cur_obj_move_standard` path where far-away or
  different-room flags suppress physical movement after the behavior state
  has updated.
- **Area transition** means the original engine changing areas when Mario's
  current floor is an instant-warp surface. It is not part of the vertical
  relation.

## Target theorem and proof boundary

The local capstone proves a closed-world statement about the handwritten Rocq
vertical relation:

```text
every execution of the handwritten Rocq vertical relation
  -> every reachable hand height is at most one uniform bound
  -> the execution is not unbounded above
```

Generated Clight and source-audit facts justify selected constants and syntax
shapes. They are not a semantics theorem for either the executable C
abstraction or the original game. The final gameplay claim requires a bridge
showing that every original-game Eyerok hand frame is represented by a
reachable state of the handwritten Rocq relation.

## Current verdict

Proved only for the handwritten Rocq relations; neither the executable C
abstraction nor the original game is semantically connected to them. The
source contains a gravity-zero branch that can preserve velocity 100 after a
grounded `DOUBLE_POUND`. The project proves an idealized mathematical-integer
recurrence for that branch is unbounded. This is not an authentic binary32
execution theorem: repeated binary32 `+100` eventually rounds to no position
change. The audit supports, but does not itself prove, the original-game
reachable-state invariant excluding the seed:

```text
reachable hand && action = DOUBLE_POUND && gravity = 0
  -> not grounded
```

The formal scheduler proves this invariant for every state reachable in that
scheduler and proves the stronger grounded form has gravity at most `-15`.
The separate vertical relation proves the conservative absolute-height
envelope: 1196 for `FirstHand` and 2003 for `SecondHand`, from static vertex
ceiling 896, upward-flight allowance 300, and scaled hand-collision top offset
507. Those ranks are intended to represent surface-list update order, but that
mapping is part of the open bridge. Every infinite run of the vertical
relation is therefore not unbounded above.

The object-helper Clight input applies the sibling project's seven literal-
suffix compatibility edits because CompCert 3.15 rejects long-double
constants. None of those edits occurs in the audited vertical integration,
ground comparison, or `cur_obj_move_standard` control path.

The executable C abstraction is an explicit boundary. Its
`ascentBudget` and surface rank are ghost-style proof state, not SM64 object
fields. The budgets 98, 288, and 285 are the sums of the positive post-gravity
vertical increments for the source's `30/-4`, `50/-4`, and `100/-15`
impulses. The uniform budget 300 is conservative. The C abstraction's safety
predicate requires `Y + ascentBudget` to stay below 1196 for the first hand or
2003 for the second and excludes the explicit runaway mode. Its fields use
32-bit C `int`, not the mathematical integers used by the Rocq relations.

The C functions do not enforce the same transition preconditions as the
handwritten Rocq `vertical_step` relation. For example, an unrestricted caller
can request another `DIE` impulse after rising above the support ceiling; the C
safety predicate then returns false, but the call is not blocked. No semantic
theorem connects C-abstraction executions to `vertical_step`. Likewise,
`scheduler_step` and `vertical_step` are separate relations with independently
proved invariants, not a coupled operational semantics.

`proofs/EyerokManipulation.v` packages generated-model shape, authentic-source
shape, scheduler unreachability, finite height boundedness, infinite-run
boundedness, and the runaway-lasso counterfactual. Generated shape facts are
syntactic Clight certificates, not whole-program execution semantics.

`proofs/GlobalBoundary.v` is a generic lemma over an arbitrary run type and an
arbitrary Z-valued height function; it contains no Clight or binary32 execution
semantics. It proves that representing every frame with a reachable handwritten
Rocq vertical state implies Z height <= 2003 and rules out unbounded Z height.
The project does not yet instantiate that premise. A real bridge must also
define and justify a binary32-to-Z observation or change the boundary to use a
faithful numeric relation, so the unqualified original-binary theorem is not
claimed.

No handwritten Rocq `vertical_step` transition can add a fresh ascent budget
above its rank-specific support ceiling. The executable C abstraction does not
enforce this restriction, and it has not been proved complete for every
transition of the pinned game. For example, a real transition that launched
the second hand from absolute Y `1950` would fall outside the Rocq relation;
one such transition would invalidate the `2003` bound and could support a high
finite route. Repetition at increasing heights would refute the idealized Z
bound, but authentic binary32 addition eventually stagnates and therefore
needs its own precisely stated property.

## Area-transition boundary

An Area 3 to Area 2 transition is not representable in the vertical relation:
it has no Mario position, Mario floor pointer, current area, or instant-warp
rule. This omission neither enables nor rules out the game route. The source
audit verifies the Area 3 `SURFACE_INSTANT_WARP_1D` level
configuration mapping to Area 2 with displacement `(0, 0, 0)`. Separate manual
inspection confirms that pinned `check_instant_warp` uses Mario's current
floor, but that engine function is not in the generated/audited surface. The
project does not prove whether Mario can use a raised Eyerok hand to make the
warp surface become his current floor at a useful elevated Y. The hand-height
claim and proposed high-warp route are related but distinct proof obligations.

The final Ubuntu check passes with Coq 8.16.1 and CompCert 3.15. `Print
Assumptions` reports no project-defined assumptions for
`eyerok_no_unbounded_rise_certificate`,
`reachable_scheduler_excludes_runaway_seed`,
`no_safe_vertical_run_rises_unboundedly`, or
`authentic_no_unbounded_rise_from_refinement`. The last statement is a
conditional implication whose refinement premise remains visible in its type.
The combined capstone reports the standard Coq/CompCert classical real,
functional-extensionality, and classical-proposition dependencies inherited
from the authentic binary32 Clight AST. The scheduler, infinite-run, and global
lifting theorems each report `Closed under the global context`.

The source audit, rather than a noncomputable float equality inside Rocq, pins
the exact authentic values `30`, `50`, `100`, `-4`, `-15`, and `-20` against
normalized hashes. `GeneratedFacts.v` independently pins the corresponding
Clight functions' float-constant counts, negation shapes, and call edges.

No `Admitted`, `Axiom`, `admit`, `sorry`, or equivalent project-added proof
hole may enter a capstone.
