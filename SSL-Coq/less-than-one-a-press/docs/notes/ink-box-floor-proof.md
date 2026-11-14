# Clone-floor preservation: what the Coq statements establish

14 November 2026. These statements concern the actual generated JP code in
the selected linked Clight environment. They do not replace the collision
loader with a handwritten geometry model. They separate a constructive local
execution from a preservation result conditional on a completed call.

## Statements

| Statement | Exact scope |
| --- | --- |
| `ibf_scripts_checked` | Checks the generated carry 3/4/5 initializers, their BEGIN(DEFAULT)/BREAK words, and the large-box initializer's graphics flag and loader reference. It does not prove an invariant of every live object's flags. |
| `ibf_break_executes_without_erasing_memory` | For any starting memory, constructs the actual generated BREAK call returning 1, with empty trace and exactly the same memory. This has no assumed successful-call premise. |
| `ibf_every_break_preserves_memory` | Every completed generated BREAK call has that same return, trace and memory result. |
| `ibf_clone_tail_preserves_loaded_cells` | Constructs the actual two-store post-address-translation suffix. Given the live object temporary, translated script pointer and writable command/stack cells, it preserves any load from a different allocation block. It also fixes the result of any execution of that same suffix. |
| `ibff_clone_suffix_preserves_disjoint_cell` | Constructs that suffix while preserving a specified existing `Some value` load. The cell can be in the same allocation block if its byte interval is disjoint from both command and stack-index stores. |
| `ibff_whole_helper_preserves_loaded_cells` | Every **completed** generated `obj_set_held_state` call with an object pointer and a base carry-script pointer preserves loads in allocation blocks other than its object block. The selected `segmented_to_virtual` callee is resolved, and its completed calls are shown read-only. This is not a constructive existence theorem for the complete helper. |
| `rank10t_time_stop_does_not_erase_collision` | Reuses the existing generated-code theorem: with the live time-stop global resolved/read and ACTIVE set, the actual `clear_dynamic_surfaces` function body executes without changing memory. This is a body-execution theorem, not a new complete `eval_funcall` theorem. |
| `current_ink_box_floor_boundary` | Main exports the combined local results through `InkBoxFloorFrameBoundary`. |

For the constructive suffix, the two stores are at `curBhvCommand` and
`bhvStackIndex`, offsets 460 and 464 in the checked JP Object layout. The
nonoverlap predicate uses their actual modular addresses and four-byte store
widths; it does not assume that arithmetic cannot wrap. To apply it to a
collision asset pointer, matrix, surface payload or query-list cell, the
caller must supply the appropriate address/layout and disjointness facts.
These facts are not replaced by an assumption that the whole memory is
unchanged.

## Why this is a meaningful positive result

BREAK itself has an explicit execution for every memory. The script-replacement
suffix likewise has an explicit execution once its pointer/writable-cell
inputs are given. Thus these local results do not merely say "if the floor
survives, it survives," and do not assume the memory-preserving effects of the
statements they prove. A loaded mesh or partition cell satisfying the stated
separation is retained by those statements. This rules out using the script
replacement or BREAK itself as a reason that existing floor data must vanish
immediately.

It does **not** prove that a full game update keeps a queryable floor. Other
code may clear or reuse the dynamic pools. The finite native tests separately
check the complete update's surface records, spatial lists and real floor
queries, including ordinary clearing and active time stop.

## Exact remaining obligations

1. Construct a complete native-address translation and fake-pickup call in
   the linked CompCert memory model. In particular, the whole-helper frame
   assumes a completed call; it does not prove that the pointer/integer casts
   in `segmented_to_virtual` admit that execution for a real carry-script
   address. Its nonvacuity cannot be inferred from the frame statement.
2. Connect the already-loaded surface and partition cells to the live object
   allocation, including separation, owner, list membership and valid pool
   bounds. This module does not prove a full floor-query predicate or its
   scheduler-wide preservation from an initial game state.
3. Compose the surface pass, Mario pickup and later clear/loader dispatch into
   one reached update history, including the behavior interpreter's opcode
   dispatch and stop rule. Checked script words and a proved BREAK function
   are not by themselves a proof of that interpreter run. The source and
   finite experiments describe the ordering; the new theorem is not a
   complete scheduler theorem.
4. Produce the fake-pickup target, any useful time stop, high live support,
   Mario entry and top-phase join through allowed controller history. No
   theorem assumes these reachability properties and then labels them proved.

Consequently, these proofs establish scoped preservation, **not** a global
impossibility of cloning a floor or a reachable transport of that floor to
high Y. The empirical high-HOLP throw leaves the retained floor behind; the
formal statements must not be promoted into a theorem excluding every other
slot history, actor substitution, behavior-restoration mechanism or memory
history.

## Validation

Use the repository pipeline with `sm64-item-proof`, Coq 8.16.1 and CompCert
3.15. New modules are registered in `_CoqProject` and imported by Main. The
selected [audit receipt](../../instrumentation/ink-box-floor-proof/README.md)
records the final compilation and assumption checks. The final run at
`build/audit/20261114-135229-18oxyow3` passed: 723 source files, successful
Main/module build, no proof-hole or link problems, all four selected assumption
checks, and 557 of 643 modules in Main's import closure with zero integration
problems. The three new-boundary checks each report seven allowed foundations;
the unchanged backward-execution boundary reports nine. Their exact names
and types are preserved in the assumption logs. These are existing
Coq/CompCert foundations, not new game-specific axioms. In particular,
no bare `coqc`, new axiom, `Admitted`, memory-cap reduction or generated-program
whole-state computation is part of this result. Mechanical audit success is
not evidence that the remaining gameplay obligations are closed.
