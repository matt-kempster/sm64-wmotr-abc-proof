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
string-literal atoms receive per-unit prefixes mechanically. This does not
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
independent authenticated ROM metadata checker, the full registered build,
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
   generated unit passes the private-string-literal prefix check.
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

The continuation's complete `bash pipeline/build.sh check` returned status 0
(`build/checkpoint-check.log`): two byte-identical generation passes for all
38 units, authenticated US/JP ROM metadata, full registered build, proof-hole
scan, capstone assumptions, independent `coqchk`, and project discipline.
The standalone selected audit also passed (`build/checkpoint-discipline.log`),
and the separate kernel check passed (`build/checkpoint-coqchk.log`).

The final audit report is `build/audit/20261015-131106-idieex1z/report.json`. It checks 48 source files,
all 10 proof modules in MainTheorem's import closure, no standalone-only
modules, no inventory/structure problems, no proof holes and no literal-prefix
problems. The exact report and SHA-256 hashes of every registered generated
and proof source are retained in `docs/notes/validation.json`.

The capstone's six allowed foundations remain:

- `ClassicalDedekindReals.sig_forall_dec`;
- `ClassicalDedekindReals.sig_not_dec`;
- `Classical_Prop.classic`;
- `Events.external_functions_sem`;
- `Events.inline_assembly_sem`;
- `FunctionalExtensionality.functional_extensionality_dep`.

There are no project axioms in that report. This does not remove the explicit
premises of the local execution theorems or close the reachable-gameplay and
hardware obligations. A read-only independent review found no critical
statement-fidelity issue by inspection; it did not instantiate a full boot
memory or prove non-vacuity of the entire gameplay composition.

The corrected script census now checks Bowser 1 (header 30), rather than the
BITDW course (17), for the stream file named `bitdw.bin`. Exact generated
dispatch-table parsing checks all seven actual header-to-entry mappings.
The earlier intended-domain error is corrected, not counted as a gameplay
counterexample. The real warp consumer also makes zero `sWarpDest.type`
essential: a nonzero ordinary destination takes priority over a negative
demo title code.

Four frozen-observer retail trials recorded 12,866 active-demo update entries,
zero mismatches and zero observer errors. Stream bytes, observed MIPS routines
and terrain prefixes were authenticated against the retail ROMs. These are
finite experiments outside Coq; exact hashes, policies and limitations are in
`docs/notes/gameplay-search.md` and its metadata-only receipt.
