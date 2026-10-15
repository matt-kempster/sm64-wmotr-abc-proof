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

The source pin is `9921382a68bb0c865e5e45eb594d9c64db59b1af`. There are 22
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

Fresh full44-source two-pass reproduction, the registered build, discipline/
assumption audit and independent silent kernel check returned exit0. Authenticated
demo/script data, the new scene-native fixture check and hole checks returned exit0.
The audit is `build/audit/20261015-174827-bma7x3p6/report.json`: all99 sources
registered, all55 proof modules in the capstone import closure, no project
axioms and the same nine allowed foundations in `notes/validation.json`.
Exact source/pipeline/project-configuration hashes are recorded there.
Logs are `build/checkpoint10-{proofs,discipline,coqchk,data}.log`.

The complete44-unit generation is fresh, not a reused result. Its reproduction
and guards are `build/scene-promotion/full-reproducible.log`, `final-guard.log`
and `link-hygiene.log`. All40 preceding ASTs remain byte-identical, and all4
new geometry/terrain builder ASTs match isolated production-wrapper outputs.
There are459 scoped private atoms:234 US,225 JP. Memory/concurrency caps are
unchanged. This does not certify whole-program linking or public declarations.

The capstone now consumes total raw same-index scene probing, actual Area field
observations, checked selected-source/native scene operands, an explicit bounded
numeric view, and exact original-Clight scene-builder read obstructions.
The [primary status](notes/gameplay-observation-status.md),
[source inventory](notes/scene-source-inventory.md),
[probe scope](notes/gameplay-scene-probe.md),
[builder diagnostic](notes/scene-address-boundary.md), and
[address-view scope](notes/scene-address-view.md) distinguish these from missing
runtime materialization/ownership, source/native execution correspondence,
permitted boot, adequate SDK/hardware behavior and authentic gameplay non-vacuity.
The two source audits are evidence guiding the next invariant, not Coq whole-run
or retail counterexample results.

No major unchecked gameplay obligation is closed; the first checklist item
stays partial and unchecked. The full verdict remains **OPEN**. Finite retail
evidence remains12,866 updates with zero mismatches/errors; no new trial is claimed.
