# Shifting Sand Land Rocq proofs

The repository's pre-existing proof root is named `SSL-Coq` with this exact
casing.  The reorganization keeps that path rather than creating a parallel
`ssl-coq` tree.

`less-than-one-a-press/` is the current proof project.  It targets the US and
Japanese versions of Super Mario 64 at decomp revision
`9921382a68bb0c865e5e45eb594d9c64db59b1af` and uses CompCert Clight generated
by `clightgen` 3.15.  It generates 27 translation units per version, for 54
Clight modules total.  The coverage includes the Mario action, movement,
`mario_step`, `obj_behaviors_2`, and `surface_collision` units, the cutscene
action containing `ACT_SPAWN_NO_SPIN_AIRBORNE`, and a project wrapper that
imports the route-relevant SSL static and dynamic collision arrays.

`old-proofs/` contains archived proof attempts.  They are retained for
historical context, reusable lemmas, and future reference; they are not part of
the current result and may be incomplete, technique-specific, or superseded.
The current project rechecks selected lessons from all six archived
investigations in `ArchivedProofIntegrationKernel`; it does not import the old
generated ASTs or treat an archived capstone as a premise.

## Build

With Rocq 8.16.1 and CompCert 3.15 on `PATH`:

```sh
cd SSL-Coq/less-than-one-a-press
make check
```

The repository root also exposes:

```sh
make ssl-less-than-one-a-press
```

Regeneration requires a Git checkout containing the pinned decomp commit:

```sh
cd SSL-Coq/less-than-one-a-press
SM64_SOURCE=/path/to/sm64 make regenerate
SM64_SOURCE=/path/to/sm64 make verify-generated
```

## Status

The generated-AST source-shape facts and the certified-event
`collection_provenance_reduction` theorem build without proof holes.  The
reduction is constructor inversion over a handwritten `CertifiedExecution`:
its step constructors already require the relevant provenance, collision,
save-bit, spawn, and trigger facts.  It is useful staging, but it is not yet a
Layer A theorem derived from linked Clight semantics.

The current clean-entry model also records the exact lower/upper airborne warp
snapshot, coherent active/backup target bits, the exact static Act 3 object,
the exact hidden-star controller, and five distinct designated Pyramid Puzzle
trigger objects with explicit macro-respawn state.  The executable
`SourceExhaustiveness` kernel proves that the ordinary non-target SSL star
indices do not alias Act 3 or Act 6, that coherent save reload cannot newly set
either target, and that an anomaly-free first target-bit transition is caused
by the uniquely matching normal target source.  A whole-program
Clight-to-inventory refinement is still pending.

`archived_proof_integration_kernel_holds` also builds without proof holes.  It
packages current-US/JP source checks for platform displacement, object
lifecycle, movement, pole, and Eyerok code together with narrow held-A,
parallel-universe, normalized-pole, and CompCert memory lemmas.  Its
`gMarioPlatform` fields are only source-shape checks.  Separately, the abstract
game state represents a pool slot plus a ghost capture epoch and proves a
null/live/inactive/reused case split, without a Clight projection theorem.
These results guide the remaining proof; they do not establish authentic route
completeness.

`PyramidTopPU.v` adds a bounded admission-free result.  It proves a
same-sample contradiction and, under explicit Y-preservation and floor-bound
premises, excludes the stock-yaw arithmetic bootstrap from Area-1 node
`0x1E`.  It also proves a two-sample coordinate/alias model for the candidate
that a separate three-dimensional State-only writer would have to realize.
The matrix, dynamic-surface, Clight execution, reachability, and JP
delayed-warp pointer-lifetime refinements remain open.

`TranscriptRouteModel.v` now formalizes the two-gate contract suggested by the
supplied source text: the contract requires a modeled upper route to leave the
elevator and a modeled lower route to pass the second-pole gate.  The old
“above the second pole” observation is only a coarse transcript abstraction:
the real lower cut must be first collision-phase entry into an enumerated
target-side support or open-cell component, because target-side floor and
trigger geometry lie below the pole's top-grip height.

`FirstTargetRefinement.v` now supplies an evidence-bearing interface with
actual before/after Clight states, trace segments, exact indexed certified
steps, and `CollisionSupportCut` crossing witnesses.  Within the certified
event semantics it eliminates direct displacement by the zero-offset
area-2/area-3 warp, invalid target provenance, invalid controller/trigger
lifecycle, coherent save-reload mutation, and projection mismatch; it also
retains only a bounded static subcase of the parallel-universe exclusion.  The
ordinary/static, platform, moving-object, clip, general coordinate-alias, and
normal reload/entry writer classes remain open.  In particular,
`FirstTargetCutClassificationObligation` is still unproved.

The current endpoint certificate and handwritten clean-state model are too
permissive to establish route exhaustiveness: they admit arbitrary motion, and
the JP raw-platform case admits a model-only stale pyramid-top displacement
outside the upper shaft.  An authentic-JP fixture replay installs the same raw
transform payload once at the Area-2 boundary and goes further: with no A held
or pressed, it consumes the upper Pyramid Puzzle trigger.  The trace has no
Act 3 overlap and does not spawn the Act 6 star.  The probe does not directly
read the save bits, so it is not a newly-set-bit witness.
Preparing the same slot only before the Area-1 transition fails because the
slot is cleared or reused, so this is a compiled-mechanism/model-boundary
counterexample, not a stock-controller-reachable game counterexample.

The arithmetic model rules out one coordinate satisfying both warp contact and
top-height platform proximity, and rules out a Y-preserving stock-yaw
bootstrap.  Proving that the stock Clight execution supplies those premises
still requires matrix-helper and transformed-surface refinement.  A broader
conditional setup remains open in which collision samples Mario's old object
at node `0x1E` while a separate three-dimensional writer moves MarioState to a
PU top candidate before geometry and final platform selection.  That
two-sample model still needs surface selection, gameplay reachability, and
JP retention or recapture through the delayed warp to Area-2 node `0x14`.
For US, a small state lemma excludes retaining the same platform epoch after
the spawn clear; deriving that clear's memory effect from Clight remains open.
Moving/loading the warp onto the top, moving the top to the warp, and
collision-preserving cloning are also unresolved.  Source-backed prehistory
evidence must validate or refute those cases, not assume them away.

The ultimate less-than-one-A-press impossibility theorem is **not complete**.
`conditional_less_than_one_a_press_impossibility` requires a concrete
observation projection, a per-run Clight refinement certificate, and the named
lower, US-upper, and JP-upper collision-observation obligations.  No concrete
linked program/projection, whole-program semantic refinement, or Layer B
obligation is proved.  These gaps are explicit and are not presented as proved
geometry or as a complete ROM theorem.  See the
[project README](less-than-one-a-press/README.md) and the
[human-readable proof](less-than-one-a-press/human-readable-proof.md), plus the
[archived-proof evidence map](less-than-one-a-press/docs/archived-proof-evidence.md)
and [route-exhaustiveness analysis](less-than-one-a-press/docs/route-exhaustiveness.md)
and [pyramid-top PU audit](less-than-one-a-press/docs/pyramid-top-pu.md) for
the exact boundary.  None of the six archived projects closes the
whole-program Layer A refinement or any Layer B obligation.
