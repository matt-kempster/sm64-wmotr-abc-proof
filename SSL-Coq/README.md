# Shifting Sand Land Rocq proofs

The repository's pre-existing proof root is named `SSL-Coq` with this exact
casing.  The reorganization keeps that path rather than creating a parallel
`ssl-coq` tree.

`less-than-one-a-press/` is the current proof project.  It targets the US and
Japanese versions of Super Mario 64 at decomp revision
`9921382a68bb0c865e5e45eb594d9c64db59b1af` and uses CompCert Clight generated
by `clightgen` 3.15.  It generates 30 translation units per version, for 60
Clight modules total.  The coverage includes the Mario action, movement,
`mario_step`, `obj_behaviors_2`, `math_util`, `surface_collision`, and
`surface_load` units, the cutscene action containing
`ACT_SPAWN_NO_SPIN_AIRBORNE`, and a project wrapper that imports the
route-relevant SSL static and dynamic collision arrays.  A separate wrapper
imports the Area-1 macro stream used by the phase-split writer audit.  The
collision wrapper also imports the breakable-box, exclamation-box-outline,
cannon-lid, and wooden-signpost meshes used by the stock Area-1 owner bounds.

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

`PyramidTopSurface.v` and `PyramidTopPU.v` add a bounded admission-free result.
They import the matrix and dynamic-surface construction bodies, check the
concrete CompCert short casts and partition cells, link the parsed face to
manually translated zero-yaw home vertices, and evaluate hand-mirrored
binary32 transform and signed-edge arithmetic.  The dynamic checker finds a
guarded `floor := dynamicFloor` assignment source shape; it does not prove
assignment exclusivity or the complete height update.  The modules also prove
the same-sample and Y-preserving stock-yaw exclusions and a two-sample
coordinate/alias model for the candidate that a separate three-dimensional
State-only writer would have to realize.  The finite signed-16 arithmetic also
proves that an upper-warp overlap followed by an admissible numeric floor query
at height 1281 or above needs at least 385 units of upward State displacement.
This is not yet a linked memory execution, proof that the live top surface is
selected by `find_floor`, or a
reachability/lifetime theorem.  Authenticated US/JP retail disassembly plus
Rocq instruction-fragment arithmetic verifies the exact
`(63488, 1791, -1024) -> (-2048, 1791, -1024)` conversions; this is not a
general theorem about arbitrary out-of-range conversions.

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
normal reload/entry writer classes remain open.  It now proves the direction
needed by the target-bit theorem: under route/event alignment, a newly set Act
3 bit reaches the Act 3 cut and a newly set Act 6 bit reaches the upper-trigger
cut.  `evidence_bearing_route_cut_blocks_new_target_bits` consequently blocks
both bits when the evidence-bearing classifier and all six open writer-family
exclusions are supplied.  Constructing those premises from a linked US or JP
run remains open; the older payload-free
`FirstTargetCutClassificationObligation` is also still unproved.

`JPSlotLifetime.v` checks the JP allocation/unload source anchors, the
free-list push/pop shapes, and the loop/literal/write syntax for clearing 80
raw words, plus the
50 packed Area-2 macro records.  It proves a finite LIFO recurrence and the
clean upper-entry live/inactive/reused slot trichotomy.  The exact reachable
allocation count and linked Clight memory trace at the first Area-2 platform
apply remain explicit obligations, so this does not prove retention, reuse, or
a three-dimensional payload.

`Area1PhaseSplit.v` proves that stock triangle fragments provide a genuine
three-dimensional payload, and `Area1SurfaceWitness.v` checks one exact
binary32/mesh arithmetic candidate.  `[top, box]` is not a unique allocator
schedule: the source audit identifies three pre-apply angular-payload
classes—pyramid-top yaw, dirt triangles, and cartoon triangles—with
free-list-depth, mist-count, zero-allocation, and FIFO-eviction variants.

`Area1PlatformExhaustiveness.v` now proves the route-relevant source-bounded
result.  Its finite model enumerates fifteen stock Area-1 dynamic-floor owners,
pairs exact generated local bounds for four newly imported collision meshes
with conservative world-space envelopes, and proves that a completed final
query at node `0x1E` cannot return any modeled non-null stock owner.  The
completed-query, US spawn-clear, retained-inbound-pointer, and frozen-carry
pre-apply origins consequently all yield a null platform there.
Thus zero stock route-relevant schedules survive in this model, and generic
fragment controller/free-list lineage is no longer a Layer-B obligation.
Proving that every linked Clight memory state projects into this bounded
owner/origin relation—including derivation of the world-space envelopes and
live surface ownership/list selection—remains open.

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
bootstrap.  The matrix and surface-loader bodies, concrete CompCert casts,
partition cells, parsed-to-manual zero-yaw home-face link, and hand-mirrored
transform/edge tests are now checked.  The finite Area-1 owner theorem also
rules out the broader platform-created split for every bounded stock pre-apply
origin at the old-object node-`0x1E` sample.  Proving that this relation covers
the linked retail execution still requires live-memory execution, surface
ownership/list order, and actual `find_floor` selection.  The exact three
concrete retail conversions have been checked separately.  JP retention or
recapture through the delayed warp to Area-2 node `0x14` remains open.
For US, a small state lemma excludes retaining the same platform epoch after
the spawn clear; deriving that clear's memory effect from Clight remains open.
Moving/loading the warp onto the top, moving the top to the warp, and
collision-preserving cloning must still be shown to fall inside the bounded
source relation or be ruled out separately.  Source-backed prehistory evidence
must validate or refute those cases, not assume them away.

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
the exact boundary.  The narrower
[surface-refinement](less-than-one-a-press/docs/pyramid-top-surface-refinement.md)
and [JP slot-lifetime](less-than-one-a-press/docs/jp-slot-lifetime.md) notes
record the newest checked kernels; the
[retail cast receipt](less-than-one-a-press/docs/retail-find-floor-cast.md)
records the authenticated instructions and exact three-input arithmetic.
None of the six archived projects closes the whole-program Layer A refinement
or any Layer B obligation.
