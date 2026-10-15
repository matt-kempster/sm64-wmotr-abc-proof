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

The private-global correction has fresh complete reproducibility evidence:
`build/private-freshening-reproducible.log`, exit 0, two byte-identical
generations of all 38 units. Comparison with checkpoint `22882e2` established
that only hygiene headers and 299 nonliteral private atom strings changed.
All public/non-global names and existing string atoms were preserved.
The 18 generated-source digests in the script-image receipt were refreshed;
retail words, placements, callback bytes and Coq numeric transcription remain
unchanged. Earlier generation hashes are not reused for this checkpoint.

Fresh registered validation passed:

- full 28-module build: `build/checkpoint4-proofs.log`, exit 0;
- discipline and capstone assumptions: `build/checkpoint4-discipline.log`, exit 0;
- independent silent kernel check: `build/checkpoint4-coqchk.log`, exit 0;
- authenticated demo/script data and proof-hole scan:
  `build/checkpoint4-data.log`, exit 0.

The final audit is `build/audit/20261015-145542-lkrzem5f/report.json`.
It checks 66 sources and all 28 proof modules in MainTheorem's import closure,
with no standalone modules or inventory/structure problems. Exact source and
pipeline hashes, actual foundation names and the full report are recorded in
`notes/validation.json`.

The seven allowed Coq/CompCert foundations actually used are:

- `Axioms.proof_irr`;
- `ClassicalDedekindReals.sig_forall_dec`;
- `ClassicalDedekindReals.sig_not_dec`;
- `Classical_Prop.classic`;
- `Events.external_functions_sem`;
- `Events.inline_assembly_sem`;
- `FunctionalExtensionality.functional_extensionality_dep`.

`Axioms.proof_irr` is used by CompCert's official Clight link construction.
It was already on the project's standard-foundation allowlist. There are no
project axioms; this does not discharge explicit memory/execution premises or
establish normal-boot non-vacuity. External math/hardware contracts retain
their literal scopes.

The complete eight-iteration `clear_areas` call now establishes all eight
null painting/instant pointers, with checked generated layout and an exact
outside-written-block frame. Its initial symbol/access/relocation resources
and later area-table lifecycle remain open. The staged build took 223.9 s;
the registered build and kernel check above include its promoted source.

The actual dispatch current-level GET command executes its full function
call, signed-level register store and four-byte command advance, with exact
handler/command syntax checks. It does not establish interpreter reachability.
Ordinary playback, including expiry and arbitrary record sticks, now composes
with controller copying and the real Start/END guards. Under a supplied
program's global environment, a genuine original-loop small-step path reaches
the analog call. Boot/post-polling entry and remaining input processing are
still separate obligations.

All eight selected level-script AST units link officially per version; the
actual BBH/CCM pair also links as Clight programs with compatible composites.
The current main/BBH incomplete/complete public array pair is rejected by
strict variable type equality. No public type or flag was changed to force
a link. A justified metadata/source-link refinement and a complete game link
remain open. Private collision hygiene does not supply that result.

The numeric taken jump and authenticated script images still require an
active-overlay representation simulation for subsequent opcode loads and
callbacks. Shared addresses do not identify loaded images. Remaining UI,
object/HUD/camera processing, authentic loading/initialization, all-frame
preservation and retail/hardware refinement are not assumed solved.

The full gameplay claim remains **OPEN**, with no reachable counterexample
established. The bounded retail evidence remains 12,866 observed updates,
zero mismatches/errors. Initial-memory resource and public-type completion
work in ignored staging is not counted as a completed gameplay result.
