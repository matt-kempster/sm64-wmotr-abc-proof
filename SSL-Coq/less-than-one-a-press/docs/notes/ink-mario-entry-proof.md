# Mario entry guards: exact local proof boundary

Investigated 14 November 2026 from proof revision
`921e4d1954d79f3b4deb6958c88419a8f4bd5a28`, branch
`codex/ssl-pyramid-item-proof`. This note concerns the generated US and JP
Clight bodies already selected by the SSL proof. It accompanies the
[Mario entry investigation](ink-mario-entry-reachability.md); it is not a
new original-ROM replay or a proof that every no-new-A route is impossible.

The useful distinction is simple: **an action number still stored in memory
does not show that its handler ran**. If Mario's floor pointer is still null
after interactions, the action executor returns before dispatch. Separately,
when crawling or the common ground-slide helper actually receives
`GROUND_STEP_LEFT_GROUND`, its switch takes the air-action branch and breaks
before the caller's floor-alignment branch. The stopped-quarter path used by
the successful Ink fixtures is different.

## Code and statements

[`InkMarioEntryGuards.v`](../../proofs/InkMarioEntryGuards.v) is registered in
`_CoqProject`, imported by `MainTheorem.v`, and exported through
`current_ink_mario_entry_guard_boundary`. The proofs inspect small source
cuts of the selected generated bodies and reason about actual
`ClightBigstep.Clight2.exec_stmt` executions. They do not evaluate the whole
generated program or replace the engine with a handwritten transition model.

| Lemma | What it establishes | Explicit conditions |
| --- | --- | --- |
| `imeg_null_floor_bypasses_action_dispatch` | Constructs execution of the complete post-preparation suffix: return 0, empty event trace, unchanged memory. | The real global symbol resolves to the cell containing Mario's pointer; its real floor-pointer field at offset 104 loads null. |
| `imeg_null_floor_forces_return_before_dispatch` | Every completed execution of that same suffix under those loads has that return, trace, and memory. | The same symbol/load premises and an actual suffix execution. This is the exclusion result, not merely existence of a convenient execution. |
| `imeg_actual_preparation_then_null_floor_returns` | Reattaches the suffix to actual preparation-stage executions, including input preparation, special floors, and interactions. | A real `iap_stage_chain` for those source stages, followed by the null loads in its resulting memory. The preparation effects and trace remain intact. |
| `imeg_left_ground_breaks_before_caller_alignment` | The actual crawl/common-slide switch with saved result 0 executes its selected air-action-request prefix and breaks; the later cases containing the caller's direct alignment are not taken. | Execution has reached this switch, and its saved result is 0. All request/sound-prefix effects are retained. |

The null-floor proofs concern the floor **after** the preparation stages,
including interactions. They do not assume that every initial failed query
leaves it null: `update_mario_geometry_inputs` can retry from stored graphics
coordinates. Nor do they assume that interactions preserve the pointer.
The completed stage-chain premise deliberately retains their real effects.
This is an enabled action-pass cut; the theorem does not construct the
preceding action-nonzero branch or a controller history that reaches it.

The LEFT_GROUND certificate checks the actual JP and US switch syntax.
Crawling requests action `16779404` (`ACT_FREEFALL`); the shared slide helper
requests its `airAction` parameter. Both break before the subsequent cases.
The theorem extracts actual execution of the selected prefix. It does not
assume that `set_mario_action` is harmless, assert an unproved final action
field value, or frame effects of transitive callees. “No alignment” here
means that the **caller-owned direct** `align_with_floor` branch is skipped.
The existing `isca_actual_ground_call_connects_return_to_switch` and
`isl_real_ground_return_drives_switch` separately connect these saved
temporaries to their actual `perform_ground_step` return; this new theorem
does not infer a ground result merely from Mario appearing unsupported.

## Which histories are narrowed

A proposed producer that depends on a crawl/slide action number surviving a
full post-interaction null-floor state fails this frame's dispatch condition.
The stored action number may remain unchanged because the suffix changes no
memory, but no action handler then runs. This does not exclude a later frame
recovering a floor and executing an action.

A proposed producer whose actual ground call returns LEFT_GROUND fails the
caller alignment condition in that invocation. It must instead establish a
different ground result or a different mechanism. This is **not** the same
event as a quarter-step's local floor query returning null: the latter can
return the stopped-wall result while preserving a prior nonnull floor cache.
Existing stopped-crawl and stopped-slide proofs show how their corresponding
caller branches reach alignment. A distant nonnull floor, physical lack of
support, `INPUT_OFF_FLOOR`, a quarter-query miss, and a final null floor pointer
are therefore separate conditions.

Still open are the actual continuous predecessor history, surviving earlier
action cancellations, fresh low cache creation at the producer, a suitable
actor at raw coordinates, and joining them at the top phase. The new proof
does not establish any of those premises or change the overall open route
assessment.

## Validation

Validation uses the repository's Ubuntu WSL pipeline and its unchanged
`sm64-item-proof` switch, Coq 8.16.1, CompCert 3.15, and default 6.5 GiB limit.
The targeted module build and final selected audit both **passed**. The audit
built MainTheorem and checked the established backward boundary, retry query,
and vertical geometry theorems, plus the new entry boundary. All four assumption
checks passed with respectively 9, 7, 4, and 7 allowed existing foundations.
Source inventory contains 718 files; integration reports 552 of 638 proof
modules in MainTheorem's import closure, 86 standalone-only, and no problems.
This was not an all-module `--full-build`.

The complete [validation receipt](../../instrumentation/ink-mario-entry-proof/README.md)
preserves the summary, JSON report, assumption logs, commands and source hashes.
The original audit directory is `build/audit/20261114-001616-kb9nz9q4`.
No bare `coqc`, new axiom, `Admitted`, or unchecked computational shortcut is
used. `Print Assumptions` reports foundations; the table above separately
states the gameplay/execution premises it does not report.
