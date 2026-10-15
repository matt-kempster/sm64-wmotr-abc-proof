# Stopping point — October 15, 2026

**Research is stopped at the user's request to conserve compute. The full
gameplay claim remains OPEN. No automatic continuation is scheduled.**

The original objective was:

> Continue Demo-Coq until the full normal-gameplay claim that an authentic demo input sequence cannot play in a different loaded level is proved or disproved, using the pinned real SM64 generated program, with validated Coq evidence and consistent local/private-site reporting.

That objective has not been achieved. No normal-gameplay impossibility proof
or normally reachable authenticated mismatch has been established. The first
gameplay-specification checklist item remains partial and unchecked, and no
major unchecked gameplay obligation is closed.

## Checked result to retain

`5dfb2332f69da710f19e0b9ab9891571fc4290d8` is the last validated proof-code
checkpoint, pushed to the fork. Its 62 registered proof modules and 44 generated
ASTs remain unchanged. The full build, assumption/discipline audit and independent
kernel check passed. Exact proof/pipeline/configuration hashes remain in
`validation.json`. The [proven-results report](../proven-results.md) records
the results and conditions; the site additionally shows the exact declarations
and their complete defining source.

Those results are conditional components, finite checks and explicitly partial
candidate-model results. They do not compose into the requested gameplay theorem.

## Final validation of existing staging

At the user's subsequent request, existing staged files were checked through
the established pipeline, with a 120-second limit per file. No proof was extended
to repair the failures. Four files type-checked and then passed an independent
kernel check; three did not compile:

| Existing staged file | Validation | Meaning |
| --- | --- | --- |
| DemoNativeHelperImages | PASS | Authenticated finite helper-word fixture. |
| DemoNativeHelperMachine | PASS | Generic partial ISA decoder/steps and structural properties; no complete helper execution. |
| DemoNativeCallerImages | PASS | Authenticated finite caller-word fixture. |
| DemoSceneConnectionWitness | PASS | Joint hand-constructed local scalar source-view/RAM witnesses, for all nine selected descriptors, US/JP and both read kinds. |
| DemoNativeHelperExecution | FAIL | A rewrite in the unfinished arithmetic proof fails at line176; no 20-step helper theorem. |
| DemoNativeGeometryCaller | FAIL | An arithmetic proof fails at line116; no 19-instruction caller theorem. |
| DemoNativeSourceTableConnection | FAIL | A placement arithmetic proof fails at line54; source/helper table connection unfinished. |

The selected staged assumption checks contain only the four standard foundations
listed in `paused-draft-validation.json`, with no project-specific axioms. None
of this staging was promoted into the capstone. A green staged file is not an
additional proved gameplay obligation.

The joint witness allocates a one-byte/two-byte scalar source-view, constructs
4MiB RAM, stores code/data and places data at `0x80040000`. The supplied image's
length is a local read extent, not an authenticated whole-asset extent. It proves
joint satisfiability of those local read premises and their existing exact-site
connection, not original initialized asset memory, runtime loading/ownership,
normal boot or authentic gameplay. Its full conditions are preserved with the
staged source and shown separately in the site's formal appendix.

## Preserved handoff

The local ignored staging is retained. A separate committed source/validation
archive is at `Demo-Coq/checkpoints/paused-address-work-2026-10-15.zip` in the
proof repository. Its member hashes, source hashes, build results and failure
locations are recorded in `paused-draft-validation.json`. The archive contains
unfinished drafts as well as the four checked staged files; it is not a checked
Coq project. It includes no compiled objects, ROMs, full assets, recorded input
streams, credentials or conversation export. The archive itself is not published
to the private site.

If the user later resumes the work, first verify that the archive and canonical
hashes still match. The next actual proof step is the fetched helper path and
its caller's pointer-store/reload dataflow, including stack/global/code/data
frames and delay slots. Then runtime image activation/ownership, complete
input-use coverage, permitted starts, SDK/hardware adequacy and a genuine
boot-to-gameplay history still need work. Do not treat this handoff as a request
to resume, or turn the unfinished drafts into completed checklist items.
