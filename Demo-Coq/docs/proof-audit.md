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

The source pin is `9921382a68bb0c865e5e45eb594d9c64db59b1af`. There are 19
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

Fresh registered validation passed for all 32 proof modules:

- build: `build/checkpoint5-initial-proofs.log` and `build/checkpoint5-proofs.log`, exit 0;
- discipline and capstone assumptions: `build/checkpoint5-discipline.log`, exit 0;
- independent silent kernel check: `build/checkpoint5-coqchk.log`, exit 0;
- authenticated demo/script data and proof-hole scan: `build/checkpoint5-data.log`, exit 0.

The audit is `build/audit/20261015-152356-1h_x461y/report.json`. All 70 generated/proof
sources are registered, and all 32 proof modules are in the capstone import
closure. There are no inventory, standalone-module or proof-hole failures.
Exact source/pipeline hashes and the full report are in `notes/validation.json`.

The complete two-pass reproduction in
`build/private-freshening-reproducible.log` is reused after verifying every
generated-source and pipeline digest against the preceding receipt. Those 38
generated sources and all pipeline scripts are unchanged from checkpoint
`6565e6c`; proof, assumptions, kernel and data checks above are fresh.

The seven allowed Coq/CompCert foundations actually used remain:

- `Axioms.proof_irr`;
- `ClassicalDedekindReals.sig_forall_dec`;
- `ClassicalDedekindReals.sig_not_dec`;
- `Classical_Prop.classic`;
- `Events.external_functions_sem`;
- `Events.inline_assembly_sem`;
- `FunctionalExtensionality.functional_extensionality_dep`.

There are no project axioms. CompCert's official Clight link construction
uses its standard proof-irrelevance foundation. Explicit external contracts
and concrete memory premises retain their literal scope.

The actual US/JP area-unit initial memories now exist constructively, and
their real symbols, spawn initializer, separation, writable accesses and
generated layouts discharge every entry resource of the complete area-reset
call. The final theorem has only a version argument. It is a unit image,
not the complete linked game's initialized memory or a boot execution.

The actual arbitrary-stick analog call now executes all deadzone/cap branches
and its real allocation/free, with exact symbolic outputs and preserved
old-memory accesses. Its named pure `sqrtf` contract remains explicit. The
actual second-controller disconnected stores and seven player3 field copies
have precise byte frames. Composition through the whole input loop remains
open.

The actual contiguous normal-frame interval after camera processing now
executes painting rejection with its real local allocation/free, pending
Demo Next countdown 20-to-19, complete pause query and final zero return.
Concrete entry reads and separation remain explicit; no painting, delayed
warp or pause callee execution is assumed. Earlier object/HUD/camera effects
and later countdown/expiry are still unproved composition obligations.

The selected source links, actual current-level GET, original-loop path to
analog, numeric taken jump and authenticated script images retain their
previous boundaries. Full linking, active-overlay representation simulation,
authentic DMA/boot, all-frame preservation and MIPS/hardware refinement remain
open. Additional ignored staging work is not counted as a completed result.

The full gameplay verdict remains **OPEN**, with no reachable counterexample
established. The finite retail evidence remains 12,866 observed updates,
zero mismatches/errors.
