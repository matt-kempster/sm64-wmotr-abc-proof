# Executing Demo Next scheduling and both transition callees

The full gameplay verdict remains **OPEN**. The following result executes
the actual scheduling function; it does not establish which normally
reachable frame invokes it, nor frame every subsequent gameplay call.

`proofs/DemoStartSchedulingExecution.v` proves
`generated_demo_next_is_really_scheduled_us_jp`, consumed through
`demo_start_scheduling_execution_claim`. Given the real pending-operation
cell initially zero and the explicit memory/layout/linkage conditions,
Coq constructs complete US and JP calls of
`level_trigger_warp(mario, WARP_OP_DEMO_NEXT)` with operation 22.

The proof executes all six real scheduling stores, in order: -1 to Mario's
invincibility timer, zero to the delayed argument, 22 to the operation,
20 to its timer, 240 to the source warp node and zero to the saved course.
It follows the actual switch fall-through from case
22 to the shared case-25 body, calls `play_transition(9,20,0,0,0)`, skips
the fadeout branch because the actual local flag was cleared, and returns
20. The final operation and timer loads are proved to contain 22 and 20.

The two callees are executed rather than assumed:

- The complete real `set_warp_transition_rgb(0,0,0)` call computes the
  framebuffer color and performs its four global stores.
- The complete real `play_transition(9,20,0,0,0)` call performs its fourteen
  transition-structure stores, calls that actual RGB helper, follows the
  textured transition branch and computes the starting radius. The US
  and JP generated transition callees are checked identical.

All three calls include their actual CompCert function entries, parameter
bindings, generated body executions, returns and cleanup. No completed
callee execution is a premise. Closed Float32 quotient/radius facts are
proved through bit representations with `Float32.of_to_bits`; the proof
does not reduce a whole generated program or expand a geometry search.
The nested transition data's real alignment two, field membership and
lookups have a witness derived from the generated composite definitions.

The final theorem proves preservation of every initial valid memory
access, and exact preservation of every load outside the eleven named
written blocks: Mario, delayed argument, operation, timer, source node,
saved course, transition structure and the four RGB/framebuffer globals.
The operation and timer are explicitly separated from the later-written
blocks that could otherwise corrupt their final values. Other premises
resolve the actual globals/callees, provide the actual Mario field
offset, writable cells and the transition's writable byte range.

This discharges the local execution obligation for Demo Next scheduling
and its transition callees. The earlier pending-dispatch theorem started
with operation 22 and timer 20; it did not execute the scheduling call or
assume a completed call. The new result leaves three distinct
composition obligations: the real active-demo/Start prefix must select
this call with these arguments; its starting-memory conditions must be
established in a reachable state; and the object/HUD/camera/instant-warp/
painting interval must preserve the scheduled condition before the later
pause decision. The independent zero-`sWarpDest.type` invariant is still
needed for both `warp_area` and transition completion. None of these
obligations is replaced by a no-desync or frame-preservation axiom.

The staged module compiled through the existing Ubuntu WSL targeted audit
pipeline using Coq 8.16.1 and CompCert 3.15 in `sm64-item-proof`, with the
established memory cap. Promotion, capstone assumptions and project-wide
checks are recorded in the main report.
