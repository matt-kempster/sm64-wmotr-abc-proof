# Demo-Coq proof audit

Research is stopped at the user's request. The canonical proof-code remains
checkpoint `5dfb233`, with its existing build/assumption/kernel validation and
unchanged source hashes. A final bounded check of later staging found four
files that type-check and pass independent kernel checking, and three incomplete
files that fail. They remain outside the capstone. Full statuses, conditions
and preserved sources are in [the stopping record](notes/stopping-point.md)
and [proven-results report](proven-results.md). No proof search was resumed to
repair those failures.

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

Fresh registered proof build, three selected discipline/assumption checks,
independent silent kernel check and authenticated demo/script/scene/native
fixture checks returned exit0. The audit is
`build/audit/20261015-182514-y_k299mf/report.json`: 106 sources registered,
all 62 proof modules in MainTheorem's import closure, no project axioms and
the same nine allowed foundations for MainTheorem. The two new selected
scalar-connection/local-inhabitation claims use only four standard foundations.
Exact current source/pipeline/configuration hashes are in `notes/validation.json`.
Logs are `build/checkpoint11-{proofs,discipline,coqchk,data}.log`.

The 44 generated ASTs are unchanged by exact digest comparison with the previous
fresh complete two-pass reproduction at 851921a. That generation result is
reused; it is not reported as a new generation run. Its logs remain
`build/scene-promotion/full-reproducible.log`, `final-guard.log` and
`link-hygiene.log`. No generation pipeline/input changed. Scoped private atoms
remain 459 (234 US, 225 JP), and established memory/concurrency caps are unchanged.

The [bounded scalar-read connection](notes/native-scalar-read-connection.md)
uses actual selected generated expressions, per-read byte transport, fetched
retail LBU/LH words and exact instruction PCs. It derives positive scalar
results and has constructive local RAM witnesses. Its numeric-expression
evaluator and native load projection are explicitly partial candidates;
ordinary-Clight/whole-native/hardware adequacy is unproved. The finite external
receipt authenticates complete small routine ranges and selected assets, not
their runtime activation or execution. Local RAM inhabitation is not normal-boot
or authentic gameplay non-vacuity.

Loaded-scene ownership, complete read/producer coverage, permitted starts,
adequate SDK/hardware events and the composed all-executions invariant remain
open. No major unchecked gameplay obligation is closed. The first checklist
item remains partial and unchecked; the full verdict is **OPEN**. The existing
finite retail evidence remains 12,866 updates with zero mismatches/errors;
no new gameplay trial or counterexample is claimed.
