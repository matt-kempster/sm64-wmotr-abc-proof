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

Checkpoint `886cb4f` passed the complete `bash pipeline/build.sh check`
(`build/checkpoint-check.log`), including two byte-identical generations of
all 38 units and authenticated demo metadata. All 38 generated hashes remain
unchanged; that generation evidence is reused. The current expanded proofs
have fresh separate validation:

- full registered build: `build/checkpoint3-proofs.log`, exit 0;
- selected discipline audit and capstone assumptions:
  `build/checkpoint3-discipline.log`, exit 0;
- independent kernel check: `build/checkpoint3-coqchk.log`, exit 0;
- authenticated script-image and exact Coq-transcription check:
  `build/checkpoint3-script-images.log`, exit 0.

The final audit is `build/audit/20261015-142250-e87snnog/report.json`.
It checks 62 sources and all 24 proof modules in MainTheorem's import closure,
with no standalone modules, inventory/structure problems or proof holes.
Exact source hashes and the complete audit are in `notes/validation.json`.
The `script-images` target is now included in `check`; its existing matching
ELF cache requirement is documented in the README.

The capstone's six allowed foundations remain:

- `ClassicalDedekindReals.sig_forall_dec`;
- `ClassicalDedekindReals.sig_not_dec`;
- `Classical_Prop.classic`;
- `Events.external_functions_sem`;
- `Events.inline_assembly_sem`;
- `FunctionalExtensionality.functional_extensionality_dep`.

There are no project axioms. Explicit memory, layout, resolution and execution
premises remain. In particular, the connected-controller execution is confined
to neutral sticks and the named pure `sqrtf` contract. Its separate general
ordinary-playback bit proof establishes the actual new-Start and END-clear
guard masks. All timer branches of the actual demo consumer are executed,
with precise frames; authentic all-frame bounds/provenance remain open.

The normal Start prefix selects the actual scheduler but retains the real
per-version intro-text call. The contiguous warp/instant-warp/timer caller
interval executes through its actual internal callees without execution
premises and preserves the scheduled operation. Object/HUD/camera updates,
the connection of entry reads and a complete frame invariant remain open.

The taken numeric script jump now executes both actual callees and stores its
exact numeric PC. The actual next-opcode expression cannot dereference that
integer in ordinary Clight. Finite script/callback image authentication and
numeric representation certificates do not supply the missing active-overlay
address simulation. Shared addresses do not identify loaded level images.

The audit's private-string prefix check is **not** a whole-program link check.
Actual private script-global name collisions make the current BBH/CCM AST
link fail. A fail-closed private-global freshener and successful corrected
two-unit links are staging evidence; production generation remains unchanged.
See `notes/private-global-linkage.md`. Regeneration, renewed hash receipts and
the full source link remain further work. No vacuous no-gameplay theorem is
claimed from the address or link obstruction.

The corrected script census checks Bowser 1 (30) for the `bitdw.bin` stream,
rather than the BITDW course (17). A zero ordinary warp destination is still
required because it takes priority over a negative demo return code. Four
authenticated retail trials recorded 12,866 active-demo updates with no
mismatch/error. These bounded observations remain separate from Coq.

The requested full gameplay claim remains **OPEN**, with no reachable
counterexample established. The area-initialization proof and further layout
witnesses currently in ignored staging are not included in this checkpoint.
