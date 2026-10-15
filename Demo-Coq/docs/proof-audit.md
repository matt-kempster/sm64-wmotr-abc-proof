# Demo-Coq proof audit

The gameplay verdict remains **OPEN**. The checks described here validate the
registered Coq development and its recorded source boundary. They do not prove
that every execution from retail boot preserves demo/level pairing, and they
do not establish a reachable desync counterexample.

## Verified environment

Use the **Ubuntu** WSL distribution for Coq and CompCert. The environment was
rechecked on 2026-10-15 through `pipeline/env.sh`:

- opam switch: `sm64-item-proof`;
- Coq: 8.16.1;
- CompCert Clight generator: 3.15;
- kernel checker: the switch's `coqchk`;
- default address-space limit: 6,815,744 KiB; default build concurrency: one.

`pipeline/build.sh`, `pipeline/assumptions.sh`, `pipeline/coqchk.sh`, and
`pipeline/discipline-check.sh` activate this environment themselves. Use these
entry points instead of invoking bare `coqc`.

The source pin is `9921382a68bb0c865e5e45eb594d9c64db59b1af`. There are 20
translation units per version, mechanically generated for US and JP. The
generation pipeline restores and byte-checks the complete pinned source
inventory, derives and hash-checks `levels/level_headers.h`, derives the text
headers required by star select and in-game menus, and records the generation flags. Private
global atoms receive unit scopes mechanically, with public/non-global and
existing string atoms preserved. This does not
certify whole-program linking or compatibility of public declarations.

## Commands

Run these commands inside `Demo-Coq` under Ubuntu WSL:

```sh
bash pipeline/build.sh proofs
bash pipeline/discipline-check.sh --build-timeout 600 --assumption-timeout 240 \
  Demo.Proofs.MainTheorem checked_demo_source_boundary_us_jp
bash pipeline/assumptions.sh \
  Demo.Proofs.MainTheorem checked_demo_source_boundary_us_jp
bash pipeline/coqchk.sh Demo.Proofs.MainTheorem
```

For a selected module and its dependencies:

```sh
bash pipeline/build.sh audit-build AUDIT_VO_TARGETS=proofs/SourceFacts.vo
```

The complete reproduction target is:

```sh
bash pipeline/build.sh check
```

It runs two generation passes with SHA-256 manifest comparison, the
independent authenticated demo metadata and selected script-image checks, the full registered build,
the proof-hole scan, capstone assumptions, `coqchk`, and the project discipline
audit. The metadata check is an external finite check, not a Coq proof of DMA
loading or retail execution.

## What the project discipline gate checks

The Demo gate adapts the existing SSL audit infrastructure to the
`Demo.Proofs` namespace and this project's capstone. It checks:

1. Every `.v` source under `proofs/` and `generated/`, including untracked
   files, is registered exactly once in `_CoqProject`.
2. The requested capstone and its registered dependencies build through the
   pipeline within the configured timeout. `--full-build` instead builds all
   registered modules.
3. All proof and generated sources pass the forbidden-hole scan, and each
   generated unit passes the private-global scope and cross-unit collision check.
4. Each requested theorem produces a complete `Print Assumptions` report;
   only the explicitly listed standard Coq/CompCert foundations are allowed.
   Missing output, compiler errors, timeouts and non-standard axioms fail.
5. A fresh `coqdep` graph contains no import across an `Unwired/` boundary and
   no unregistered proof module outside the capstone or declared audit roots.

Audit output goes to a fresh `build/audit/<timestamp>-<suffix>/` directory.
Its `report.json`, `summary.txt`, per-command logs and `interfaces.txt` are
local build evidence. Import reachability does not by itself establish that
a particular lemma is used. The interface index is informational; it is not
a list of proved or unproved gameplay claims. Explicit theorem premises and
statement fidelity require review in addition to these mechanical checks.

## Legacy repository gate

The repository-level build skill and `pipeline/env.sh` describe the older
`sm64-proof` switch and Coq 8.19.2. They have a different namespace and default
capstones from Demo-Coq. Demo-Coq uses the machine's verified
`sm64-item-proof` switch and Coq 8.16.1. The project audit above is the active
gate for this development; the legacy root gate is not reported as passing.

The execution-proof agent ran the following baseline command from the proof
repository under Ubuntu WSL:

```sh
timeout 60 bash .claude/skills/proof-discipline/discipline_check.sh
```

It returned status 1 after approximately five seconds, with the build-stage
message `opam switch 'sm64-proof' not found. Create it with:`. This is an
agent-reported observation from the tool output; a dedicated full legacy log
was not retained. The legacy gate was not rerun, and it supplies no passing
Demo-Coq build evidence. The active project gate and kernel checks use the
verified environment above.

## Recorded validation

Fresh registered validation passed for all 41 proof modules:

- complete40-source two-pass generation: `build/camera-promotion/full-reproducible.log`, exit0;
- registered build: `build/checkpoint7-proofs.log`, exit0;
- discipline/capstone assumptions: `build/checkpoint7-discipline.log`, exit0;
- independent silent kernel check: `build/checkpoint7-coqchk.log`, exit0;
- authenticated demo/script data and proof-hole scan: `build/checkpoint7-data.log`, exit0.

The audit is `build/audit/20261015-162346-ttb27n5e/report.json`. All 81 sources are
registered, and all 41 proof modules occur in the capstone import closure.
Exact source/pipeline hashes and the full report are in `notes/validation.json`.
The camera unit was added for both versions through the normal pipeline.
All 40 ASTs reproduce identically twice; the preceding 38 ASTs are separately
byte-checked unchanged, and both camera ASTs match isolated repeated generation.
There are 427 scoped private atoms: 218 US and 209 JP. This does not certify
whole-program linking or compatibility of public declarations.

The nine allowed Coq/CompCert foundations actually used are:

- `Axioms.proof_irr`;
- `ClassicalDedekindReals.sig_forall_dec`;
- `ClassicalDedekindReals.sig_not_dec`;
- `Classical_Prop.classic`;
- `Events.external_functions_properties`;
- `Events.external_functions_sem`;
- `Events.inline_assembly_properties`;
- `Events.inline_assembly_sem`;
- `FunctionalExtensionality.functional_extensionality_dep`.

There are no project axioms. Standard external-function/inline-assembly
properties do not establish the named math or SDK/hardware contracts, nor
discharge concrete memory or reachable-entry premises.

The [connected-P2 playback](notes/second-controller-playback.md),
[actual second-controller branch](notes/second-controller-execution.md) and
[complete caller](notes/connected-second-controller-read.md) now compose
the entire original post-polling path with P2 connected. Every timer branch,
arbitrary P1 raw axes/current/prior buttons, real P2 neutral analog call,
both loop iterations and player-three copies execute. Exact outputs,
stream pointer/timer/header and protected-read frames are retained.
Physical pad offsets0/6 and two precise pure sqrtf contracts remain explicit;
hardware entry, other physical-port assignments and all-frame provenance
remain open. The earlier P2-absent caller remains valid with its literal scope.

The [all-dialog terminal result](notes/dialog-zoom-execution.md) removes the
earlier dialogtype!=1 restriction from the complete terminal dispatcher and
actual normal suffix after painting. It executes the real camera trigger2,
reset, transition and special-warp callees. Exact camera-cell/callee resources
replace that dialog restriction. Debug/demo/scalar resources and ordinary warp
destination remain explicit. The earlier full post-camera pending2..20 interval
does not establish twenty consecutive gameplay frames. Whole object/HUD/camera
effects and boot reachability remain open.

The exact declaration normalization and official nine-unit script links,
checked next anonymous-tag boundary, area-unit initial-memory reset and earlier
startup/input/interpreter/warp components retain their recorded scopes.
There is no complete source-link/type-renaming proof, active-overlay simulation,
whole loaded-gameplay composition or N64 MIPS/hardware refinement. Ignored
staging is not counted as completed.

The full gameplay verdict remains **OPEN**, with no reachable counterexample
established. Bounded retail evidence remains 12,866 observed updates with
zero mismatches/errors.
