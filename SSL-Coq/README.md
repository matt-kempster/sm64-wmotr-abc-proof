# Shifting Sand Land Rocq proofs

The repository's pre-existing proof root is named `SSL-Coq` with this exact
casing.  The reorganization keeps that path rather than creating a parallel
`ssl-coq` tree.

`less-than-one-a-press/` is the current proof project.  It targets the US and
Japanese versions of Super Mario 64 at decomp revision
`9921382a68bb0c865e5e45eb594d9c64db59b1af` and uses CompCert Clight generated
by `clightgen` 3.15.  It generates 38 translation units per version, for 76
Clight modules total.  The coverage includes all seven Mario action units
(including the newly imported submerged-action writers), movement,
`mario_step`, `obj_behaviors_2`, `math_util`, `surface_collision`, and
`surface_load` units, plus `behavior_script`, `level_script`, `graph_node`,
`rendering_graph_node`,
`debug`, `memory`, and `mario_misc`, the cutscene action containing
`ACT_SPAWN_NO_SPIN_AIRBORNE`, and a project wrapper that imports the
route-relevant SSL static and dynamic collision arrays.  A separate wrapper
imports the Area-1 macro stream used by the phase-split writer audit.  The
collision wrapper also imports the breakable-box, exclamation-box-outline,
cannon-lid, and wooden-signpost meshes used by the stock Area-1 owner bounds.

CompCert 3.15's unmodified linker has been run over the original 38-unit lists.
Those lists do not produce a whole program: the first right-associated AST
join fails at `ssl_script` (index 34), and the first composite-definition join
fails at `area` (index 27), in both US and JP.  The audit finds 402 US and 401
JP duplicate public variables whose generated types differ.  A deterministic
normalized semantic slice remains useful for coverage experiments, but it is
not itself an official CompCert link.  `CleanedClightPrograms.v` now constructs
source-owned cleaned US and JP unit lists and proves that CompCert's unmodified
`link_list` returns their respective official cleaned targets.  In particular,
the US and JP `NormalizedCleanedUnitsOfficialLinkStructuralObligation`
inhabitants are kernel-checked.  This is a syntactic structural-link result
only; it does not prove that either cleaned target simulates the original
generated units or the target ROM.

The declaration/layout boundary is now much narrower and explicit.  Every
generated function declaration has the same CompCert call ABI as its selected
definition.  Variable declarations satisfy the exact-or-incomplete-array rule
except for `gDisplayListHead`, whose pointer declarations nevertheless have
equal checked storage behavior.  All named JP residual composite tags and the
five named US residual tags have equal checked storage layouts.  The remaining
US anonymous atom `__538` is a real collision: it denotes a 16-byte,
alignment-2 viewport structure in the affected `area` and cutscene source uses
and an 8-byte, alignment-4 graphics-command structure in `game_init`.  The
actual US official target inherits the latter `__538`; its `__540` viewport
wrapper is therefore 8 bytes while the source viewport wrapper/storage is 16
bytes.  A fresh-tag local layout repair is constructed, but a whole-AST
alpha-renaming of every affected type, expression, and global annotation plus
an execution simulation remain open.  Replacing only the composite table is
not a sound refinement.

`ClightLinkExecution.v` now specializes definition provenance to both actual
official targets.  Every nonlocal internal-body `Evar` and every initializer
`Init_addrof` occurrence in those targets resolves to a linked symbol, every
retained or reachable global `External` is classified as `EF_external`,
`EF_builtin`, or `EF_runtime`, and exhaustive body recursion proves that neither
official target contains a direct `Sbuiltin`.  The normalized/source manifests
retain the exact partitions US `133 EF_external + 75 EF_builtin + 19
EF_runtime` (227 total) and JP `132 + 75 + 19` (226 total).

The same file transports CompCert external calls under explicit CompCert
`symbols_inject` and `Mem.inject` hypotheses, including injected results and
memories, injection growth/separation, and the standard `loc_unmapped` and
`loc_out_of_reach` frame guarantees.  It also lifts external `Callstate` steps
and direct `Sbuiltin` steps after explicit argument-evaluation injection.  The
retail instantiation still needs the complete global-interface relation,
initial and current-state memory injections, expression/continuation/internal
step simulation, and concrete writable Mario/object/controller frame
conditions.  No arbitrary writable frame follows from CompCert's generic
external-call theorem.

`old-proofs/` contains archived proof attempts.  They are retained for
historical context, reusable lemmas, and future reference; they are not part of
the current result and may be incomplete, technique-specific, or superseded.
The current project rechecks selected lessons from all six archived
investigations in `ArchivedProofIntegrationKernel`; it does not import the old
generated ASTs or treat an archived capstone as a premise.

The latest focused result imports the renderer and checks the reported
Turning-Part-2 animation hypothesis.  The repeated value 189 normalizes
render translation to exact binary32 `1.0f`; it does not write Mario's
physics, raw Object, or Graphics-anchor position in the proved metadata
boundary.  Linked animation-buffer/DMA separation and the real ground-step
collision path remain open, so this is not a complete route or retail-game
theorem.

The newest JP installer tranche asks whether ordinary clean play can create
the `>=960` Graphics/Object Y gap required by the conditional timer-131
stale-top route.  No such installer was found.  Rocq proves that a phase
already refined to State-only preserves the old Object/Graphics gap, computes
a 38-unit generated-AST writer census, and proves nonnegative depth for a
source-shaped relation that excludes the late long-jump writer.  The census is
receiver-neutral and therefore does not itself establish Mario-writer closure.
An actual `Clight.step2` zero-edge relation reads the live `buttonPressed`
field, but is parameterized by an arbitrary program, controller address, and
entry state; it does not itself establish a clean JP entry.  Its composition
theorem preserves the current gap bound only when supplied total state
projection and per-step refinement.

The conditional quicksand warning is now checked at a nonzero live-range
base: starting at binary32 `768.5f`, 381 unreanchored sinks with prepared
depth `-2.650000095f` end at `1778.1593017578125f`; the collision-consumed
integers differ by exactly `1010`.  This validates the arithmetic, not the
installer.  The stock Area-1 audit still has no clean zero-A origin for the
negative-depth, automatic-dialog, unreanchored combination.  Ordinary Area-1
entry source facts and a synchronized memory postcondition are formalized,
but live entry execution, routing, external-call frames, pool/list ownership,
writer/action/alias closure, and reanchoring closure remain open.  Bounded JP
runtime search found no positive gap; it is not an exhaustive proof.

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
trigger objects with explicit macro-respawn state.  It now also distinguishes
an empty generic delayed-warp latch from “no delayed star exit” and records
the live controller pressed word together with the current/previous down
samples that compute it.  The executable
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
This is not yet a linked memory execution, proof that the loaded top surface is
selected by `find_floor`, or a
reachability/lifetime theorem.  Authenticated US/JP retail disassembly plus
Rocq instruction-fragment arithmetic verifies the exact
`(63488, 1791, -1024) -> (-2048, 1791, -1024)` conversions; this is not a
general theorem about arbitrary out-of-range conversions.

`InkFallback.v` adds the missing three-view schedule.  Object collision may
cache node `0x1E` from old `MarioObject.oPos`; a floorless MarioState query can
then copy `header.gfx.pos` into State and retry.  Rocq proves conditional local
and PU top-side pipeline-coordinate witnesses, exact generated null/copy/retry
syntax/dataflow and nearby mesh receipts, a signed-range generic 385-unit
necessary Graphics/Object Y gap, an exact-candidate `973`-unit gap, and
preservation of Object/Graphics by arbitrary prefixes already refined to
State-only.  The handwritten pipeline includes the
projected Graphics-position quicksand sink and proves its modeled value cannot
change the Object coordinate copied from State.  The source-shape kernel also
checks that later object lists and deactivated-object unloading precede the
final platform query.  Its checked syntax admits an explosion-frame candidate
in which the top behavior's loop is followed by its collision loader and the
slot is later unloaded before that query; linked execution, free-list
membership, and retained surface identity remain unproved.  The two closed
coordinate witnesses use the zero-yaw home top and floor Y `1791`.  They do
not instantiate the explosion/inactive-slot branch: that branch must recover
the later translated/rotated pose, transformed surface, and selected floor
height.  The old sink statement was false; its repaired first-return,
modular-cell form is open.  The current post-copy lifecycle statement is
unsafe or vacuous and must be replaced.  The project now closes the retry-null
fatal-latch invariant in a finite source-audited event model: fatal remains
pending or reset destroys the old disappeared-action continuation, and the
upper object-warp request is never accepted.  This is not yet a linked US/JP
Clight theorem.  Concrete event projection, latch-memory preservation,
clear/reset execution, initial acceptance of the fatal request, and the two
`find_floor` outcomes remain open.
The project does
not prove the first query returns `NULL`, a loaded top is selected, or a clean
retail prestate reaches the required split.  No stock-reachable US/JP retail
trace with a newly set target bit was found.

The latest tranche sharpens this audit.  `Area1FirstNull.v` now parses the
actual generated US/JP Area-1 collision initializers and kernel-computes the
17-wall/26-floor static inventories for cell `(5,7)`.  A pure evaluator over
those generated-data lists computes all four wall decision lists and both
floor decision lists as all-rejection.  It then packages zero-push and
`Area1FloorNull`/`-11000.0f` records; this is not an independently executed
collision traversal.  Its rejection trace derives the `12+8+5+1` tally.
Exact binary32 receipts cover the decisive axis-aligned planes and roof
buffer.  This still does not execute the live Clight
allocator/list traversal, exclude extra dynamic surfaces, or prove clean
reachability.  `EntryMemory.v` proves the US/JP composite layouts and
proves a projection *from* an explicitly assumed CompCert-memory
postcondition.  Executing `init_mario_after_warp` to establish those loads
remains open.

The fatal-latch model now checks all three State/retry outcomes and the
two-tick disappeared-action continuation.  Only a non-null Graphics retry
followed by another floor-supported update can request the upper object warp;
a both-null retry requests death/game-over and wins the first-writer latch when
that cell is empty.  A handwritten two-step transition explicitly reanchors
the second modeled shell frame from current State; under that definition its
`+42` air or `+45` ground gap does not accumulate.  Generated-AST receipts
separately establish source ordering and literal occurrences, but no theorem
yet refines a live shell frame to the handwritten transition.  Generated
receipts also find quicksand-depth reset paths before both shell writers.
Direct source inspection finds wall collision-record X/Z writes rather than
direct Graphics writes and puts successful warp selection before action
dispatch.  The generated warp facts do not prove indirect-call, success,
break, or dispatch dataflow.  Pointer
aliasing, all wall callers, live action paths, debug-spawn disablement, and
complete writer/flag closure remain unproved.
The project also records concrete binary32 binade-crossing witnesses where the
endpoint delta exceeds the shell source operand by about `0.000061`; those
witnesses provide no global bound.  The route-local Float32 work is split into
an exact-arithmetic obligation for Y in `608..818` and a predicate-parameterized
live-range schema.  The ground helper's pre-add cast behavior also remains
open.

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

`FirstCrossingWriterCoverage.v` now records why that older interface is not
the final coverage theorem: an unrestricted `CollisionSupportCut` may place
the same state on both sides.  Its corrected boundary parameterizes the
construction and exclusions by one selected version/entrance/target cut
family, gives each cut an entrance/entry contract, requires endpoint-local
side separation, orders the crossing segment before a matching target-event
segment, supplies evidence for every earlier index, and proves an exhaustive
abstract-event split.  A changed-XYZ projected event is labeled ordinary
physics, platform displacement, object impulse, collision clip, or area
reload.  Unchanged XYZ can still cross through a changed floor or raw-platform
selection, which is an additional support-selection case.  Proving that these
event labels cover the concrete C writers remains part of the open projection.
The module proves administrative-event preservation, narrows changed reload
to entry restoration, and excludes coordinate-alias witnesses under a local
successful-cast invariant.  It does not construct the contracted crossing or
prove the six no-A motion/domain predicates or the separate support-selection
predicate for either retail program.  Those predicates are explicitly scoped
to clean entries and the selected cut family.

`OrdinaryMotion.v` now isolates the ordinary/static writer class.  The proved
theorem `ordinary_safe_envelope_execution_excludes_target` composes
caller-supplied finite-cell preservation and target-exclusion obligations;
it does not discharge them for retail.  The closed capstone
`current_ordinary_motion_evidence_boundary` packages the source, mesh,
non-Wing arithmetic, and Wing-Cap countermodel boundary, but not the retail
exclusion.  In particular, no A edge still permits an already-held-A jump
kick after B.  The generated elevator initializer has a 256-unit wall/rim,
dynamic surfaces add a five-unit upper-Y pad, and the lower wall query uses a
30-unit center offset.  Non-Wing 4-unit-gravity jump kick and a conservatively
supplied rollout on that branch rise at most 128 and 220 units relative to the
descending elevator, below the strict 231-unit integer-translation rejection
threshold.  A Wing-Cap arithmetic countermodel reaches 228: it exceeds the
non-Wing 220 bound but does not clear the corrected vertical gate.  The retail
`init_mario` cap reset remains an explicit clean-entry projection/refinement
requirement.  Live Clight action execution, transformed collision selection,
intermediate queries, action-state closure, and the full lower route remain
open.
The clean upper snapshot itself is above the cage (`5500` versus raw rim top
`5222`); existing no-spin-airborne AST receipts support a zero-forward-speed
entry fall, but linked execution and landing on the intended live elevator
surface are still separate obligations.

`GoombaRaising.v` now proves a bounded conditional collision-raising kernel.
The corrected repeating state is airborne Goomba action `2`.  Binary32 makes
the velocity update `25 + (-4) = 21` exact, while the position model adds
`21` only as an idealized integer recurrence; concrete Y `51` runs for 31 and
83 rises are checked separately.  Binary32 `2^29` is a checked fixed point for
adding `21.0f`; no theorem claims the selected Y `51` orbit reaches it.
The checked integer abstraction rules out direct use of the audited Spindel
height band by the Area-2 Y `778` singleton; linked binary32 collision bounds
remain open.  The 31-hit Area-1 bound applies only to
the post-collision H/F/R schedule; an alternate pre-collision raw-Object writer
schedule is explicitly open.  Generated US/JP AST receipts support source
shapes but do not construct trace-wide no-A shuttling, same-segment PU
platform capture, singleton transport, or geometric handoffs.  This is not a
saved A press or a retail counterexample; see the
[Goomba-raising audit](less-than-one-a-press/docs/notes/goomba-raising.md).

`JPSlotLifetime.v` checks the JP allocation/unload source anchors, the
free-list push/pop shapes, and the loop/literal/write syntax for clearing 80
raw words, plus the
50 packed Area-2 macro records.  It proves a finite LIFO recurrence and the
clean upper-entry live/inactive/reused slot trichotomy.  `JPFirstApply.v`
corrects the fixture control point and proves the finite conditional fresh-load
census: 84 allocations before the true first Area-2 platform apply, or 85 with
a saved cap; Spindel is allocation 64/free-list depth 63.  The ordered linked
Clight trace, actual early-freed-top depth, pointer memory lineage, and consumed
payload remain explicit obligations, so this does not prove a retail
three-dimensional displacement.  See the
[first-apply audit](less-than-one-a-press/docs/notes/jp-first-apply.md).
`InkPayloadInstaller.v` formalizes Ink's graphical retry as one candidate
installer within this same JP stale-platform route, alongside other possible
installers and pointer fates, plus the exact timer-131/timer-150/explosion-0
arithmetic.  Its composition is conditional and is not a retail reachability
or route-exhaustiveness theorem.

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
Thus zero bounded pre-existing platform-origin schedules survive in this
model, and generic fragment controller/free-list lineage is no longer needed
for that finite origin theorem.  A null pre-apply platform does not exclude
Ink's later graphical retry and top capture.
Proving that every linked Clight memory state projects into this bounded
owner/origin relation—including derivation of the world-space envelopes and
loaded-surface ownership/list selection—remains open, as do the fallback's
writer/action closure, first-query `NULL` result, top-owned retry selection,
repaired sink-memory refinement, and replacement post-copy object/surface
lifecycle interface.

The current endpoint certificate and handwritten clean-state model are too
permissive to establish route exhaustiveness: they admit arbitrary motion, and
the JP raw-platform case admits a model-only stale pyramid-top displacement
outside the upper shaft.  In the older authentic-JP staged-payload replay, the
raw transform is first present at the initial Area-2 controller poll.  That
poll is after the true first platform application, so the payload affects the
second application and consumes one upper Pyramid Puzzle trigger; that older
probe does not read save bits.  The stronger current fixture instead injects
only the timer-131 three-view Area-1 prestate.  Retail execution then captures
and frees the top, retains its slot through the delayed warp, applies it at the
true first Area-2 application, consumes all five triggers, and spawns the Act-6
star.  A refined B/Z continuation overlaps the star and changes the authentic
JP save byte from `00` to `20` with every A counter zero.  This is still a
conditional trace, not a stock-game counterexample, because no clean retail
installer for the injected `>=960` gap has been found.  In the separate
pre-transition-only slot-60 test, the
numeric slot is free-list depth 7 and is reused by allocation 8, macro-object
5, before the true first application.  That failure does not refute a pyramid
top deliberately freed earlier at another depth before bulk unload.  The
fixture therefore remains a compiled-mechanism/model-boundary counterexample,
not a stock-controller-reachable game counterexample.

The arithmetic model rules out one coordinate satisfying both warp contact and
top-height platform proximity, and rules out a Y-preserving stock-yaw
bootstrap.  The matrix and surface-loader bodies, concrete CompCert casts,
partition cells, parsed-to-manual zero-yaw home-face link, and hand-mirrored
transform/edge tests are now checked.  The finite Area-1 owner theorem also
rules out the broader platform-created split for every bounded stock pre-apply
origin at the old-object node-`0x1E` sample.  It does not rule out a null-first
query that copies a separate graphical sample and captures the top afterward.
Proving that this relation covers
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
[archived-proof evidence map](less-than-one-a-press/docs/notes/archived-proof-evidence.md)
and [route-exhaustiveness analysis](less-than-one-a-press/docs/notes/route-exhaustiveness.md)
and [pyramid-top PU audit](less-than-one-a-press/docs/notes/pyramid-top-pu.md) for
the exact boundary.  The
[Ink graphical-fallback audit](less-than-one-a-press/docs/notes/ink-fallback.md)
records the newest conditional mechanism and writer boundary.  Its latest
audit proves that the exact proposed prestate needs at least a `973`-unit
Graphics/Object Y split, checks retry-null fatal-warp priority at the
source/abstract-latch boundary, repairs a refuted sink specification, and
identifies the current lifecycle statement as unsafe or vacuous rather than
proved.  The finite block-or-reset event invariant is now checked; its linked
US/JP Clight/memory refinement remains open.  No
clean retail counterexample was found.  The narrower
[surface-refinement](less-than-one-a-press/docs/notes/pyramid-top-surface-refinement.md)
and [JP slot-lifetime](less-than-one-a-press/docs/notes/jp-slot-lifetime.md) notes
record the newest checked kernels; the
[retail cast receipt](less-than-one-a-press/docs/notes/retail-find-floor-cast.md)
records the authenticated instructions and exact three-input arithmetic, and
the [ordinary-motion audit](less-than-one-a-press/docs/notes/ordinary-motion.md)
records the newest ordinary/static subkernel and its remaining obligations.
None of the six archived projects closes the whole-program Layer A refinement
or any Layer B obligation.
