# Human-readable proof guide

This document explains the proof project for a reader who understands software
engineering but does not know *Super Mario 64*.

> **Current status:** the project does not yet prove the retail-game theorem.
> It proves a collection/provenance reduction in an abstract event model, a
> logical route-gate theorem extracted from the supplied transcript, and
> selected facts about generated US and JP Clight syntax.  The refinement from
> complete game executions to those models, and the decisive collision
> reachability results, remain open obligations.

## The problem in software terms

The game runs an update loop.  Each frame reads a controller, updates Mario and
the object pool, detects collisions, runs object behaviors, and may update the
save file.  The two outcomes of interest are save-file bits for these stars:

- Act 3, **Inside the Ancient Pyramid**, whose zero-based star index is `2`;
- Act 6, **Pyramid Puzzle**, whose zero-based star index is `5`.

A star is *newly collected* only when its bit is clear in the initial save
flags and set in the final save flags.  Starting with the bit already set does
not count.

The controller stores both the buttons currently held and the buttons newly
pressed on this frame.  In the source, the relevant update is equivalent to:

```c
buttonPressed = current & (current ^ previousButtonDown);
buttonDown = current;
```

The project therefore defines "fewer than one A press" as: the A bit of the
edge-triggered pressed value is false on every modeled frame.  A may already be
held when execution begins.  Holding A continuously is not a new press.

The pyramid interior is area 2.  A clean execution can begin through either:

- the **upper entrance**, which places Mario inside a descending elevator; or
- the **lower entrance**, which places Mario at the bottom of the pyramid.

`CleanPyramidEntry` also requires the two target bits to be clear, all five
Puzzle triggers to be unconsumed, no substitute target star to be waiting in
the object pool, valid spawn/list state, no pending collection or exit, enough
controller history to compute the first edge, and the version-specific
platform-pointer state needed by US and JP.

The pinned area definitions provide concrete landmarks for the future geometry
proof: the lower and upper entry warp objects are at `(0, 300, 6451)` and
`(0, 5500, 256)`; the elevator starts at `(0, 4966, 256)`; the second pole is
at `(0, 3200, 1331)` with behavior parameter `92`; the Act 3 star is at
`(500, 5050, -500)`; the Act 6 hidden-star controller is at
`(900, 1400, 2350)`; and the upper trigger is at `(260, 3913, -600)`.  These
initializer facts identify objects and candidate regions.  Coordinates alone
do not prove that Mario can or cannot reach them.

## The route argument in one diagram

The supplied transcript, together with the route-completeness refinement in
the task request, describes years of route construction as a graph with two
remaining cut points:

```text
clean upper entry
       |
       v
 elevator cage -- A jump or genuine no-A elevator escape --+
                                                           |
clean lower entry                                          |
       |                                                   v
       +-- previously solved no-A trials --> second pole --+--> shared upper region
                                             A jump or            |          |
                                             genuine bypass       v          v
                                                            Act 3 region  upper Puzzle trigger
```

The "second pole" here is the upper of the two poles encountered by the normal
bottom-up route.  It is trial 3 in the transcript's five-trial terminology.

This is a control-flow-cut argument:

1. On the modeled upper route, access to either relevant region requires at
   least one A edge unless an elevator-escape capability is available.
2. On the modeled lower route, access to either relevant region requires at
   least one A edge unless a state above the second pole is available without
   an A edge.
3. The transcript says that the other four named trials have no-A solutions.
   The stronger statement that either bypass gives access to both reduction
   nodes--the Act 3 region and upper trigger--is the task's proposed reduction
   and still needs a checked continuation for each node.

The Rocq route-gate model proves the logical case split itself.  For a trace
satisfying its explicit route-coverage premise, excluding both bypass
observations makes target-region access imply at least one A edge.  Under the corresponding downstream-completeness
premise, a spawning-displacement elevator escape enables no-A modeled access
from the upper entrance, while a no-A seed above the second pole does the same
from the lower entrance.  Conversely, any no-A modeled target route exposes
the corresponding bypass capability.

The capstone-facing statement is:

```coq
Theorem transcript_route_gate_reduction :
  forall initial trace,
    TranscriptRouteGateModel initial trace ->
    fewer_than_one_a_press (route_inputs trace) ->
    reaches_any_target_region trace ->
    (state_entrance initial = UpperEntrance /\
       elevator_escape_observed trace) \/
    (state_entrance initial = LowerEntrance /\
       above_second_pole_observed trace).
```

The lower-level theorem
`no_a_target_access_requires_preceding_gate_bypass` keeps the selected frame
indices, so the bypass is proved to occur before the selected target
observation.  `transcript_route_gate_reduction` is its simpler capstone-facing
corollary and intentionally forgets those indices.

`TranscriptRouteGateModel` is an explicit route-coverage premise.  It says the
chronological observation stream contains the entrance-specific gate before a
target observation: either an A-edge-labelled gate observation paired with the
same modeled frame input, or the corresponding bypass.  The theorem removes
the A-action branch when every input frame has no A edge.  It does not prove
the gate label's control-flow meaning or the coverage premise from C.

The model deliberately targets the **Act 3 interaction region** and the
**upper hidden-star trigger**, rather than claiming that merely reaching a
floor writes a save bit.  The collection layer separately explains why those
regions matter.

### What the route theorem does not establish

The route contract is a formal transcription of the supplied strategy
argument, not a projection of the retail executable.  Its gate-necessity
fields encode two important completeness claims that are still unproved:

- no retail route goes around the elevator and second-pole cuts; and
- after either cut, the transcript's remaining no-A strategies work under the
  actual Float32 movement, collision, object, and version semantics.

Completed target traces must carry a `RealizedRouteTrace`: a synchronized
abstract `CertifiedExecution` whose Act 3 and upper-trigger observations are
backed by collection and trigger-consumption events at the same frame index.
That prevents downstream access from being certified by appending a free target
label.  `CertifiedExecution` is still the handwritten event model, so this is
not a replacement for the missing Clight refinement.

Likewise, `SpawningDisplacementEscape` is currently a route-observation tag.
The JP-only sufficiency lemma does not calculate displacement or prove a
retained platform state reachable; it combines that tag with the explicit
downstream premise.

The transcript's rollout measurements--six units short in the observed setup
and a hypothetical seven-unit lift escaping--are candidate geometric facts, not
premises of the current theorem.  They need a checked state/mesh calculation
before they can support elevator closure.

Consequently, finding an authentic no-A elevator escape or any authentic no-A
state above the second pole would invalidate the corresponding lower-bound
case.  If the downstream-completeness claim is also validated, that witness
would provide the missing capability for a zero-A route to each relevant
region in separate executions.  The separation matters because collecting a
star normally exits the course; the claim is not that both stars are collected
in one run.  The archived spawning-displacement work is evidence about one
such candidate mechanism; it is not a witness that the mechanism is reachable
on entry to the pyramid.

## Why reaching those regions is relevant

The collection/provenance layer treats the save file like a protected data
sink and asks which execution events are authorized to change it.

For Act 3, a newly set bit requires a collection event involving an active
star-or-key object with index `2`, the static pyramid-star origin, and a
registered Mario/star collision in the Act 3 interaction region.

For Act 6, a newly set bit requires an active star-or-key object with index
`5`, originating from the hidden-star controller.  Spawning it requires all
five hidden-star triggers to have been consumed.  Consumption of the upper
trigger requires a registered Mario/trigger collision in the relevant
collision phase.  The 100-coin star uses index `6`, so it cannot directly set
either target bit even though it may be useful as a movement resource.

These statements are proved by inversion over `CertifiedExecution`.  That is
useful, but it is not yet a whole-program Clight proof: the event constructors
already require the provenance, overlap, bit-update, and trigger facts.  A
future refinement must derive those constructor premises from actual Clight
steps.

Combining the intended layers gives this proof plan:

```text
new target bit
    => authorized target collection event                 (collection layer)
    => Act 3 collision or upper-trigger collision          (provenance reduction)
    => upper elevator gate or lower second-pole gate       (route completeness)
    => at least one edge-triggered A press                 (gate geometry)
```

Only the first two arrows are currently proved inside the abstract certified
event model.  The third arrow is a field of `TranscriptRouteGateModel`, not a
derived geometry theorem.  Given that field, the route lemma derives the last
arrow only after the relevant bypass is excluded for the supplied trace; no
global US/JP bypass exclusion is proved.  The reverse direction--bypass to
target access--is conditional on separate downstream and abstract-execution
certificates.  The semantic bridges between all of these statements are
pending.

## What the generated source already confirms

The current project regenerates CompCert Clight ASTs for both target versions
from the pinned decomp revision.  Direct inspection of that pinned C source
shows:

- the controller input calculation distinguishes `buttonPressed` from
  `buttonDown`;
- the pole action bodies test `INPUT_A_PRESSED` on paths selecting pole-jump
  actions;
- the pole source also contains the Z-triggered soft-bonk/drop path,
  so "the source mentions A" alone is not a pole-impossibility proof;
- object processing applies Mario's platform displacement before detecting
  object collisions;
- the US spawn path directly clears `gMarioPlatform`, while the JP path does
  not contain that direct clear call; and
- target collection, hidden-star, area transition, object lifecycle, and
  collision functions are present in the generated source set.

The checked Rocq AST theorems are narrower: they establish selected operator,
identifier, constant, direct-call, and direct-callee-order shapes.  In
particular, the pole AST theorem checks occurrences of the relevant input and
action constants; it does not prove branch control dependence or that those
branches exhaust every way past the pole.

The area script also contains a conditional
`SSL_SPAWNING_DISPLACEMENT_TAS_HACK` branch used for experiments.  The target
generation leaves that branch disabled.  Its hacked position/platform setup is
therefore not evidence about either target ROM.

These are syntax and source-shape checks.  They do not prove branch dominance,
loop execution, exact memory effects, route coverage, or reachability.

## How the six earlier projects support the argument

The archived projects are treated like previous design investigations: they
identify invariants, failure modes, and candidate lemmas.  The current project
does not import an old generated AST or assume an old capstone.  Selected facts
are regenerated or reproved in the current namespace.

| Prior project | Evidence in favor of the route argument | What it still does not prove |
| --- | --- | --- |
| `ssl-spawning-displacement-proof` | Identifies the JP stale-platform mechanism that could move Mario during an area load, enumerates modeled first-frame displacements, and motivates explicit object-slot/epoch cases.  This is the principal candidate for a no-A elevator escape. | That an authentic clean pyramid entry can retain a suitable platform, that every pointer payload is covered, or that any retail displacement escapes the elevator. |
| `ssl-pyramid-item-proof` | Shows the proof shape needed for area unload/reload, object deletion, free-list slot reuse, and allocation identity.  This supports the claim that outside objects do not simply survive as substitute target stars. | A linked execution proof of the unload loop, target-star provenance, or either route gate. |
| `ssl-parallel-universe` | Correctly models continuously held A as zero new edges and warns that a bounded-position proof must cover every movement writer.  It tests a possible way of bypassing ordinary geometry. | Complete movement-writer coverage or non-reachability of either target region. |
| `pole-bypass` | Proves a one-A lower bound for a restricted normalized pole model and isolates `bypass_model_complete` as the missing global premise.  This is the closest prior result to the second-pole gate. | Every approach state, pole avoidance route, object/platform interaction, Float32 collision phase, or JP execution. |
| `eyerok-manipulation` | Provides negative evidence against using the area-3 boss and platform state to manufacture unbounded height, and records the US/JP platform-state split. | A complete exclusion of every area-2/area-3 high-entry technique or a route to either target. |
| `demo-warp` | Demonstrates why memory provenance matters: a byte store can alter Mario state under an aliasing premise, while normal initialization can rule out that alias in a narrower model. | Any direct pyramid route result, or a current-revision whole-program memory proof. |

Taken together, the projects make the two-gate hypothesis more credible and
make its missing completeness assumptions much more precise.  They do not
compose into a proof of the final claim.

## Exact remaining obligations

The ultimate theorem needs all of the following:

1. Construct a linked US program and a linked JP program from the generated
   translation units, including specifications for external calls.
2. Project Clight memory and traces to `GameState`, frame inputs, lifecycle
   events, and complete collision observations.
3. Prove that the projection produces `CertifiedExecution`, including object
   provenance, behavior-parameter decoding, deletion/reuse, macro respawn,
   unload/reload, instant-warp, and collision-list timing.
4. Prove the route-gate contract complete for every clean upper and lower
   entry, or
   replace it with an equivalent exhaustive collision-phase case analysis.
5. Prove elevator containment for US and every reachable JP platform-pointer
   case when no A edge occurs.
6. Prove that no lower-entry execution crosses the second-pole cut without an
   A edge, including pole avoidance, amp, goomba, parallel-universe, Eyerok,
   stale-slot, and prepared-state cases.
7. Validate the claimed no-A downstream paths from each successful bypass to
   the Act 3 region and all five Act 6 triggers.

Until these obligations are discharged, `conditional_target_clight_run_impossibility`
is correctly named *conditional* and the retail-game theorem remains open.

## How to inspect and build the proof

The most useful entry points are:

- `proofs/TranscriptRouteModel.v`: route-observation contract and gate/bypass
  lemmas;
- `proofs/InputSemantics.v`: edge-triggered A definition;
- `proofs/StarCollection.v` and `proofs/HiddenStar.v`: collection reduction;
- `proofs/ClightFacts.v`: checked generated-AST source facts;
- `proofs/ClightRefinement.v`: the explicit missing semantic bridge;
- `proofs/LowerEntrance.v` and `proofs/UpperEntrance.v`: open Layer B
  obligations;
- `proofs/MainTheorem.v`: proved reduction and conditional capstone; and
- `docs/archived-proof-evidence.md`: detailed audit of every prior project.

Build and run all project checks with:

```sh
source pipeline/env.sh
make clean
make check
make verify-generated
```

The check rejects `Admitted`/`admit` and audits the assumptions of the named
capstone theorems.  A successful build means the stated conditional and model
theorems type-check; it does not convert open bridge obligations into proved
facts.
