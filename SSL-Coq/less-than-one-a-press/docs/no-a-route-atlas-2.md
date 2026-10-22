# SSL no-A route atlas 2: from the real reward backward

This separate work stream began on 2026-10-09 on `codex/ssl-pyramid-item-proof`.
It preserves the earlier [atlas](no-a-route-atlas.md) and its site unchanged.
Its private site is <https://ssl-act3-execution.tra38.chatgpt.site>; source lives
in the separate sibling `ssl-act3-execution-site` Git repository. No conversation
exports are included.

**Verdict: the end-to-end impossibility claim remains open for both Act 3 and
Act 6.** This iteration focuses on a concrete C1 contact-consumer connection
for Act 3. No genuine permitted selected-Clight no-A collection has been found
or excluded by this local result. Proof and audit status is recorded below;
successful compilation alone does not close a global obligation.

## Claim and chosen semantics

Starting at the accepted ordinary SSL Area-1 boundary, neither Inside the
Ancient Pyramid nor Pyramid Puzzle should be newly collected with fewer than
one new A-button press in any execution permitted by the explicitly chosen
semantics. This is the goal to investigate, not an assumption.

The immediate target is successful, defined execution of
`selected_clight_target VersionJP = jp_official_cleaned_slice`. The JP source
and selected target coincide. Existing linking and symbol-resolution proofs
resolve cross-unit internal calls in that selected program; this work does not
use standalone translation-unit executions with arbitrary unresolved internal
calls. Structural linking and identity lockstep do not establish original-C or
retail-MIPS correspondence. The initialized task-entry witness supplies a real
first selected step, but is not a gameplay route from the accepted boundary.

No-A continues to mean **no new A-button edge in a coherent controller
history**. Held-A histories remain in scope. This iteration's local call theorem
uses no controller restriction, so it applies to A and no-A histories alike.
Defined aliases and unusual object pointers remain in scope. True external-call
effects are still governed by CompCert's parameterized external semantics unless
a separate effect specification is proved. The dispatcher slice performs no
external call before the handler; it retains the handler's actual execution
without adding a harmless-effect assumption. Complete external effects for the
headline theorem are still an E1 residual.

## Starting dependency map

The current capstone is
[`conditional_consolidated_clight_run_impossibility`](../proofs/MainTheorem.v).
Its major premises are `WholeProgramClightRefinementObligation projection`,
`EvidenceBearingRouteClassificationRefinementObligation projection`, and
`RemainingNoAWriterObligations projection`. It also requires the projected
start, `RunUsesProjection`, `RunEndsAtSelectedFrameBoundary`,
`CleanPyramidEntry`, and `fewer_than_one_a_press` of the projected inputs.

```text
Actual selected-JP execution
  -> E1: WholeProgramClightRefinementObligation                 OPEN
  -> ClightFrameRefinementCertificate / CertifiedExecution
  -> StarCollection.newly_collected_act3_requires_collection_event
  -> FirstTargetRefinement.aligned_newly_collected_act3_reaches_act3_cut
  -> C1: EvidenceBearingRouteClassificationRefinementObligation OPEN
  -> evidence-bearing route reduction
  -> W1-W6: RemainingNoAWriterObligations                       ALL OPEN
  -> conditional_consolidated_clight_run_impossibility

Accepted DefaultArea1StartBoundary
  -X-> concrete start-memory/controller facts and
       same-history connection to CleanPyramidEntry             B0 OPEN
```

The capstone begins **inside the pyramid**. Acceptance of the outside Area-1
boundary does not imply an ordinary eventual pyramid entry. Displaced entries,
transient contact and same-frame collection must remain covered by future
whole-execution work. `FirstValidatedCutCrossingAt` requires crossing strictly
before the target frame; `NoSameFrameOrTransientCutEscape` is still unresolved.
The new call bridge does not impose a frame gap.

The following existing results motivate the target:

| Existing module | Checked fact | Missing end-to-end connection |
| --- | --- | --- |
| `ModelGapAudit.v` | The handwritten certified model admits arbitrary motion endpoints and synthetic Act 3 collection. | E1 cannot follow just from preservation of its own abstract rules. |
| `SourceExhaustiveness.v` | First-bit classification in an executable writer kernel. | Not a classification of every actual Clight write, alias or reload. |
| `StarCollection.v` | Certified Act 3 credit requires a certified collection event. | Actual save-memory transition to that event. |
| `ContactConsumerSource.v` | Actual search and dispatcher functions resolve in the selected global environment. | Reached same-execution call chronology. |
| `ContactConsumerExecution.v` | Successful search body reads its returned list entry; award body preserves its argument temporaries. | Search function return to dispatch handler argument. |
| `WritableActionTableReachedExecution.v` | Initialized table bytes remain framed along genuine selected task-origin `step2` runs, including `sInteractionHandlers`. | Exact live star-row load, dispatcher index/type dataflow, and connection of task-origin histories to the accepted Area-1 boundary. |
| `ObjectContactNecessity.v`, `ObjectContactReadback.v` | Actual successful contact body requires ordered tests and supplies same-call reads under explicit helper/read premises. | Cached entry to earlier registration, lifetime and collision comparisons. |

## Chosen vertical slice

Work backward through the actual generated JP interaction branch:

```text
mario_get_collided_object(mario, interaction_kind)
  -> returned candidate copied into _object
  -> actual collidedObjInteractTypes mask store
  -> actual candidate status read / suppression guard
  -> indirect handler(mario, interaction_kind, identical candidate)
```

The supporting new statement,
`ContactCreditExecution.ccr_star_call_reads_returned_object`, lifts the existing
body theorem to a complete `ClightBigstep.Clight2.eval_funcall` of the selected
search. Function entry binds the actual arguments. A successful pointer return
cast cannot invent a different pointer. The theorem derives the list count,
successful iteration-count guard, returned pointer read, interaction-type read and
successful type comparison in the **unchanged search input memory**.
A successful iteration guard and defined pointer read do not by themselves
establish a logical array-capacity bound or legitimate contact registration.

`JPContactDispatchExecution.jcd_branch_search_to_handler_identity` follows
one successful execution of the extracted generated dispatch branch. It derives
the selected search call, its concrete list/count/type observations, and either
actual status-guard suppression or an actual handler call with identical Mario,
interaction kind and candidate. The actual status dereference proves that the
candidate is a pointer, including in the suppressed case. The theorem applies
the complete-search readback to that same call; it does not require a separately
supplied pointer-result witness. Both zero and
nonzero handler returns are included. The post-mask memory is retained at the
handler; it is not assumed equal to search memory. The theorem leaves the
indirect callee's identity open, rather than silently treating it as the star
award handler.

These statements concern cached contact-list consumption. A cached entry is
not proof of a fresh collision or of a live target-star allocation epoch.

## Closure test

**A — Global obligation addressed.** This is a local C1 semantic bridge,
supporting E1's collection observation. Its next destination is the actual
collection evidence needed to justify
`clight_frame_observation_act3_complete` and
`clight_frame_observation_refines`. It does not inhabit
`WholeProgramClightRefinementObligation`,
`EvidenceBearingRouteClassificationRefinementObligation`, or a W-family field.

**B — New concrete fact.** The candidate passed to the reached handler is
derived from the search in that same branch execution. The search's input
memory and handler's post-store memory are kept in order. Pointer-valuedness
comes from the branch's actual status dereference, and the pointer readback
comes from that same complete search call, with bound parameters and return
cast accounted for. `jcd_search_readback` packages these derived conclusions;
it is not an assumed obligation.

**C — Remaining hypotheses.** The important premise is a successful finite
big-step execution of the actual branch in the selected-JP global environment
and empty function-local environment. The standalone search wrapper has an
actual pointer-valued result premise; the branch theorem now derives it.
Whole-dispatch/run decomposition,
reachability from Area 1, live handler-table identity, target origin, earlier
registration/clearing and allocation history, all first-bit writers including
backup reloads and aliases, and whole-history external effects remain open.
These are semantic gaps, not new foundational Coq axioms.

**D — Connection to the final argument.** The new module is registered in
`_CoqProject` and applied by `MainTheorem.current_jp_contact_dispatch_identity`.
That boundary is on the capstone's import spine, but the conditional no-star
theorem does not yet consume a proved whole-run certificate built from it.
The precise next connection is a reached dispatcher handler identified from
live table memory as `interact_star_or_key`, followed by its object-derived
reward-number read and save call. Reuse
`action_table_private_every_selected_task_run_is_private` for initialized-byte
framing and `rank9a_selected_body_resolves VersionJP R9Collect` for function
resolution. Neither theorem derives the concrete live row load or dispatcher
index/type correspondence. This evidence must eventually replace a granted
observer consequence.

**E — Stronger than before.** Previously, the search body and award argument
preservation were separate local facts. This slice constrains one actual
search-to-handler sequence across an intervening store. It removes the need
to supply the local candidate identity and pointer-result correspondence
independently, and joins the actual search observations to the same branch.
It does
not remove any complete capstone premise.

## Next specific work

Connect every relevant reached dispatcher invocation to this branch proof
(including prefixes that have reached the handler but have not returned).
Derive the real loop's index/type dataflow to star row 2, prove its initialized
handler-pointer load at byte offset 20, and transfer that load using the
existing table frame. This should identify the indirect call as the award
body. A supplied index of 2 is only an intermediate interface; the real
dispatcher must derive it. Task-origin table preservation must also be tied
to the accepted Area-1 history rather than granted from an arbitrary memory.
Then prove that the reached award's reward-number read and save call concern
the same object and memory chronology. Work backward through actual first target-bit
stores as well: normal award is not assumed to be the only cause. Backup reload,
other stores, defined aliases and external effects need actual coverage.

Only after that concrete necessary-collection chain is strong enough should
the invariant search claim to exclude target contact. Candidate invariants
must be tested against actual selected executions, with abstraction-only
counterexamples and unresolved gameplay feasibility recorded separately.

## Verification receipt

- Baseline selected audit: **PASS**, Coq 8.16.1 / CompCert 3.15, opam switch
  `sm64-item-proof`, established 6,815,744 KiB virtual-memory cap. Receipt:
  `build/audit/20261009-174102-6_j8a5qf/`.
- Focused new-module check: **PASS**, `bash pipeline/check.sh
  proofs/JPContactDispatchExecution.v`, exit 0. Timing log:
  `build/check/JPContactDispatchExecution.log`.
- Initial final-audit attempts: build **TIMEOUT**, exit 124 at 600, 600 and
  1,200 seconds while recompiling dependent modules. Hole and link hygiene
  checks passed each time; assumptions and integration were skipped. Receipts:
  `build/audit/20261009-180224-i8q1936r/`,
  `build/audit/20261009-181246-twiaieq2/`, and
  `build/audit/20261009-182322-1q7fwdr4/`. No failed proof was reported.
- Longer dependency rebuild: build **TIMEOUT**, exit 124 at 3,600 seconds,
  while compiling `InkBackwardHistory.v`; holes and link hygiene passed,
  assumptions/integration skipped. Receipt:
  `build/audit/20261009-184400-jnkjtqoh/`. No failed proof was reported.
- First integrated build of the strengthened boundary: **FAIL**, exit 2,
  missing `Globalenvs` import for `Genv.find_funct` in `MainTheorem.v`.
  The import was added; the local strengthened proof had already passed.
  Receipt: `build/audit/20261009-194819-xtid7x8l/`.
- Final discipline/assumption checks: **PASS**, exit 0. Receipt:
  `build/audit/20261009-195100-_4n8pdlj/`. The integrated build, proof-hole
  check (including untracked sources), link hygiene, named assumptions and
  import integration all passed. Inventory: 653 sources, zero problems;
  integration: zero problems. Command:

  ```sh
  bash pipeline/discipline-check.sh --build-timeout 1200 --assumption-timeout 240 \
    LessThanOneAPress.Proofs.MainTheorem conditional_consolidated_clight_run_impossibility \
    LessThanOneAPress.Proofs.MainTheorem current_jp_contact_dispatch_identity \
    LessThanOneAPress.Proofs.ContactCreditExecution ccr_star_call_reads_returned_object
  ```

- Assumption audit: the unchanged conditional capstone has six allowed
  foundations. The new Main boundary and complete-search wrapper each have
  those six plus existing CompCert `Axioms.proof_irr`: seven each. The shared
  six are `ClassicalDedekindReals.sig_not_dec`,
  `ClassicalDedekindReals.sig_forall_dec`, `Events.inline_assembly_sem`,
  `FunctionalExtensionality.functional_extensionality_dep`,
  `Events.external_functions_sem`, and `Classical_Prop.classic`.
  No project axiom or `Admitted` was added. These are not axiom-free
  results, and allowlisting foundations does not discharge explicit execution
  or reachability premises.
- Global verdict remains open. No retail theorem, universal no-A invariant,
  complete first-bit classification, route closure or W-family closure is
  claimed.
- New owner-private site: **published successfully** at
  <https://ssl-act3-execution.tra38.chatgpt.site>, from pushed site-source commit
  `19ff761c627853347e991dc6115c98ace48509d1`. The exact source was packaged and
  saved/deployed through Sites' private operation. The old sites were not
  edited. Windows packaging used process-local Git Bash and
  `TAR_OPTIONS=--force-local`; no global shell settings were changed.
