# Shifting Sand Land Rocq proofs

`less-than-one-a-press/` is the current proof project.  It targets the US and
Japanese versions of Super Mario 64 at decomp revision
`9921382a68bb0c865e5e45eb594d9c64db59b1af` and uses CompCert Clight generated
by `clightgen` 3.15.  It generates 25 translation units per version, for 50
Clight modules total, including the Mario action, movement, `mario_step`,
`obj_behaviors_2`, and `surface_collision` units needed to investigate the
archived route families against the current source.

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

`TranscriptRouteModel.v` now formalizes the two-gate contract suggested by the
supplied source text: the contract requires a modeled upper route to leave the
elevator and a modeled lower route to get above the second pole.  Its logical
lemmas show that no-A target-region access exposes a corresponding bypass, and
that spawning displacement or above-pole access becomes complete for the two
reduction nodes only under explicit downstream-continuation premises.  No
Clight-to-route projection, gate closure, or downstream-completeness premise
has been proved.  A stronger first-target theorem now enumerates nine explicit
bypass class tags for each entrance and proves “A gate or named tag” under the
visibly open `FirstTargetCutClassificationObligation`.  The tags carry no
state evidence and the broad obligation already assumes their coverage; it is
not a ROM route-completeness proof.

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
for the exact boundary.  None of the six archived projects closes the
whole-program Layer A refinement or any Layer B obligation.
