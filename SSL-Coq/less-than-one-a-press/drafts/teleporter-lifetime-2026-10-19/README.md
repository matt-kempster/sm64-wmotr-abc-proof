# Teleporter lifetime drafts: recoverable checkpoint

Follow-up: WholeScan, TransportCut and SpawnOwnership now have repaired,
verified active copies; see the [current salvage report](../../docs/notes/teleporter-wrong-warp.md#verified-source-draft-salvage-19-october-2026).
AudioFrame and PoolPartition remain uncompiled. The source snapshots and
historical statuses below describe the original checkpoint and are retained
unchanged. Verification applies to the active copies, not these raw drafts.

Saved 19 October 2026. These are **unverified working drafts**, preserved so
the stopped lifetime work can be resumed without reconstructing it. They are
not active proof modules, verified evidence, or a completed Bob-omb lifetime
theorem. No proof or VC emulator analysis was resumed to make this archive.

The full question remains open: no surviving transported Bob-omb with a usable
SSL Area-2 regrab, and no universal exclusion of that possibility, is established.
The checked conditional unload call-path results remain the stopping point.
See [the project report](../../docs/notes/teleporter-wrong-warp.md).

## What was saved

All five sources were copied byte for byte from the ignored
`build/check/transport-wip/` checkpoint. The originals remain untouched.
The `.v.draft` suffix and location outside `proofs/` and `generated/` keep
them outside the active source inventory; none is registered in `_CoqProject`
or imported by `MainTheorem`. Git backs up the archive independently of build
cleanup. Archive-local `.gitattributes` disables line-ending conversion on the
source snapshots and historical records.

| Snapshot | Status of the saved text | First resumption task |
| --- | --- | --- |
| `TeleporterSpawnOwnership.v.draft` | Latest full check failed in `tso_geo_vector_call_resolves`, line 832, with `No matching clauses for match`. Later text is unchecked. | Repair function-resolution proof plumbing, then check the complete file. Reached-checkpoint owner facts do not yet establish global birth/owner history. |
| `TeleporterWholeScan.v.draft` | Trace-strengthened version uncompiled. An earlier baseline's timing log reaches its final `Qed`; that log does not validate this version. | Check the added trace-fold equations and full module; retain the actual list-head, membership and preceding-unload frame obligations. |
| `TeleporterTransportCut.v.draft` | Current version uncompiled. An older check stopped at the missing WholeScan import before its body. | Complete/check WholeScan first, then check this composition against the actual changed-area execution. |
| `TeleporterAudioFrame.v.draft` | No compiler evidence. | Check the proposed five-function concrete game-audio frame and its resolution premises. Resolve its relationship to the selected abstract external audio call; compiling the concrete closure alone does not discharge that call. |
| `TeleporterPoolPartition.v.draft` | No compiler evidence. Despite its name, its proposed result concerns four concrete deallocator pointer stores under separation conditions. | Check that local frame. Derive a real live/free partition and allocation-episode invariant separately. |

The only direct dependency among these five is WholeScan -> TransportCut.
The other three can be assessed independently against the existing checked
modules. Useful work is salvageable, but successful completion of every
proposed statement is not guaranteed. Statements may need correction.

`manifest.json` records byte lengths, SHA-256 hashes, original paths and the
scope of every saved record. `original-README.txt` is the verbatim old note:
its statement that the drafts were excluded from commits describes the old
ignored checkpoint. They are now committed **as drafts**, still excluded
from the active proof and published verified evidence.

`logs/` contains three historical compiler logs and the active-boundary audit
summary. No source hash was recorded by those compiler runs, so the new
manifest authenticates today's saved bytes, not a historical source/log
binding. No AudioFrame or PoolPartition check log was found. The audit PASS
applies to the existing active conditional boundary, never to these drafts.

## Check the backup

From this directory run `node verify-snapshot.cjs`. It checks every saved
record against the manifest, and, when the original scratch file is still
present, also checks equality with that original. New pipeline runs overwrite
the live compiler logs; the verifier reports those expected replacements
while still requiring each saved historical log's exact manifest hash.
Source snapshots and other available original records must remain identical.
It does not compile or
validate a proof. A Git checkout can recover these snapshots even if the
ignored build directory is later removed.

## Resume without losing the proof boundary

1. Read the repository's `CLAUDE.md`, the proof-discipline skill, the current
   MainTheorem boundary statements and their assumption audit. Recheck the
   installed environment before proof work. The saved baseline used Ubuntu
   WSL, `sm64-item-proof`, Coq 8.16.1 and CompCert 3.15.
2. Work on one module at a time. Copy its snapshot to `proofs/Name.v` only
   if that destination is absent; do not overwrite subsequent work. Keep
   this historical archive unchanged and make repairs in the active copy.
   WholeScan then TransportCut is the shortest dependency chain; ownership,
   audio and the local deallocator frame are separate tasks.
3. Build needed dependencies with the existing pipeline. In the WSL unit
   directory use `CHECK_TIMEOUT=600 bash pipeline/check.sh proofs/Name.v`.
   Keep the established 6815744-KB memory cap. Do not use bare `coqc` or
   reduce the whole generated program with a large computation.
4. Review the statement against the actual generated functions and reached
   execution: callee/receiver identity, traces, list provenance, concrete
   storage separation, satisfiable premises and absence of circular lifetime
   assumptions. Passing compilation alone is insufficient.
5. Promote a genuinely complete module by registering it in `_CoqProject`
   and connecting its intended result to the actual MainTheorem boundary.
   Run the established source/build/assumption/integration checks and the
   three Ink/retry/geometry regression queries through the pipeline. Update
   the atlas and private site with exactly the resulting scope.

Even five checked modules would not by themselves settle transport survival.
The eventual composition must establish reachable creator ownership and
live-list membership, whole-scan coverage, the selected audio call's effect,
derived pending-read frames, live/free partition, allocation identity across
reuse, reset/respawner ancestry and a usable regrab continuation. An address
reappearing after allocation is not evidence that the old Bob-omb survived.
The resumption plan stays within game-source proofs; VC emulator analysis
remains stopped.
