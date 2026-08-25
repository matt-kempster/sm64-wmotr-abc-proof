# Platform alias, indirect-call, and external-call closure

## Question

Can a clean linked execution sustain the needed local-Object/nonlocal-State
split through an alias, a function-pointer call, or an external call even when
the normal named writer census finds no such writer?

This note separates mechanisms that were previously grouped under the phrase
"non-alias/external frame."  The new theorems are conditional boundaries, not
claims that the relevant callstates are reachable from the default SSL Area 1
start.

Execution-scope note: this audit now separates defined CompCert memory from
retail machine corruption.  Valid same-block aliases, valid interior pointers,
known-function retargeting, and explicitly specified external effects remain
proof obligations.  An invalid or out-of-bounds dereference/store has no
successful Clight transition, while post-undefined-behavior machine execution,
ACE, DMA, and interrupts require a separate MIPS/hardware model.  Their absence
from a Clight run is therefore not a retail impossibility result; see
[the project execution-scope boundary](../compcert-execution-scope.md).

## Mechanism inventory and verdicts

| Mechanism | Current result | Counterexample value |
| --- | --- | --- |
| A retained internal function visibly stores to `gMarioPlatform` | The existing official census covers **every retained internal body**, not merely direct callsites. US permits only `update_mario_platform` and `clear_mario_platform`; JP permits only `update_mario_platform`. Entering a body through a function pointer therefore does not create a new internal-writer class. | Low as an undiscovered writer. Indirect control flow could still invoke the known updater at an unexpected time, so reachability and updater-source provenance remain live questions. |
| An internal function forms `&gMarioPlatform` and passes or saves it | The official body census finds no address-taking site in either version. | Eliminated as ordinary source-level pointer flow. |
| Static data initially contains a relocation to `gMarioPlatform` | The official initializer census finds no such relocation in either version. | Eliminated as an ordinary initial alias source. |
| A store through an unrelated, valid CompCert allocation aliases Object or State | `defined_store_creating_object_state_gap_targets_one_endpoint` proves that a single successful store which changes synchronized Object/State loads into unequal loads must target the Object block or the State block. A third block cannot wrap into either endpoint in CompCert's defined memory model. | Eliminated for a defined single store. A real counterexample must identify an endpoint block, an external effect, or leave the defined-memory model. |
| A recognized `EF_builtin` or `EF_runtime` mutates one endpoint | Existing `RetailExternalFrames` theorems prove recognized builtins and runtime helpers leave all memory unchanged. The official programs also contain no direct `Sbuiltin` statements. | Eliminated for the checked recognized constructors. |
| A reachable unresolved `EF_external` creates the split | `reachable_unresolved_external_created_object_state_gap_is_refined` proves that a callsite-sensitive inventory cannot classify such a call as framed. The exact call must enter its explicit writer/lifecycle branch. The more general changed-load theorem gives the same result for any protected cell. These theorems start at the reached external `Callstate`, so they apply whether that callstate arose from a direct or indirect callsite. | Potentially meaningful. The selected cleaned slices intentionally leave external semantics abstract; a stock implementation-specific refinement must either frame the two endpoints or expose the exact writer. |
| A pre-existing valid alias names an endpoint or `gMarioPlatform` | The official alias-origin theorem retains pre-existing and external-produced pointers after the ordinary named origins are excluded.  A valid pointer into a real CompCert block remains possible until clean initial memory and pointer provenance are linked. | A genuine in-model proof obligation. |
| An integer is cast to a pointer and used as the store address | `PlatformIntegerAliasClosure.v` proves that both CompCert integer constructors remain integer constructors under casts and never become `Vptr`; `Mem.storev` succeeds only on `Vptr`.  Therefore no successful defined Clight store can use an integer-fabricated address. | Eliminated in the selected CompCert model.  Retail execution after an invalid machine address is a separate semantics question. |
| Invalid or out-of-bounds arithmetic is proposed to forge an alias | A successful CompCert store cannot cross allocation blocks by offset wrap, and invalid dereference/store has no Clight successor.  What retail MIPS code does after source undefined behavior is not represented. | Deferred to a machine-semantics extension, not something this Clight proof must exclude and not a retail disproof. |
| Several individually legitimate stores create and then sustain the split | The single-store theorem localizes the **first** divergent store to one endpoint, but no trace-level first-divergence projection has yet been derived from the live linked run. | Still live. It is now a finite per-step classification problem rather than a free-standing "alias" mystery. |

## Formal additions

`proofs/PlatformExternalGapSemantics.v` provides three reusable conditional
theorems:

- a defined single-store endpoint theorem;
- changed protected load implies unresolved-external writer refinement; and
- synchronized Object/State loads becoming unequal implies unresolved-external
  writer refinement.

`proofs/PlatformAliasExternalClosure.v` specializes the generic alias-origin
classifier to both official cleaned retail programs.  Ordinary internal
address-taking and initializer relocation branches are contradictory, leaving
exactly the four semantic escape constructors above.

`proofs/PlatformIntegerAliasClosure.v` discharges one of those four semantic
labels whenever it is interpreted as a C integer cast feeding a successful
store.  It proves the result from CompCert's actual `sem_cast` and `Mem.storev`
definitions rather than assuming a non-alias frame.  The remaining defined
origins are therefore a genuinely valid pre-existing pointer or a pointer
returned by specified outside code; out-of-bounds fabrication is outside a
successful Clight execution.

## Most promising next checks

The external-produced alias branch is the most plausible of this group,
because `EF_external` in the selected slice represents an intentionally
unfinished implementation boundary rather than evidence that retail executes
arbitrary behavior.  The decisive task is to enumerate the unresolved
externals reached on the exact Area 1 update prefix and refine each callsite as
either:

1. a byte frame for the Object coordinate, State coordinate, and
   `gMarioPlatform` cell;
2. a known stock writer whose destination and value flow are projected; or
3. a lifecycle operation whose allocation/slot/epoch effect is projected.

For aliases, the shortest normal impossibility proof is a first-divergence
trace theorem: start with distinct valid linked blocks and synchronized loads,
then classify the first step that makes the loads unequal. Internal successful
stores reduce to the two endpoint blocks; recognized builtins disappear;
unresolved externals enter the writer refinement. That would leave only the
actual endpoint writer bodies and the defined-behavior/pointer-provenance
premise, rather than an unstructured global non-alias assumption.

No concrete clean-retail counterexample emerged from this tranche. The one
counterexample-oriented lead is therefore not "an unknown indirect writer,"
but a reachable unresolved external or lifecycle implementation whose real
stock body has not yet been imported/refined and which can produce an endpoint
or platform-cell alias.
