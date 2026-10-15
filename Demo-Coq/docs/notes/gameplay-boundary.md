# Executed painting and delayed-demo boundaries

The full normally reachable gameplay claim remains **OPEN**. These results
execute real generated control flow and a real internal call, but do not yet
compose the title, interpreter, frame scheduler and memory invariants into a
no-desync theorem. They do not exhibit a reachable desync counterexample.

## What is now executed

`proofs/DemoGameplayBoundary.v` contributes
`generated_demo_gameplay_boundary_us_jp` to the project capstone. It contains
three semantic results, all for the generated US and JP code.

1. **The entire painting-warp body skips with a null table.** Given the two
   actual generated reads of `gCurrentArea` and its `paintingWarpNodes` field,
   with the second read returning null, Coq constructs `exec_stmt` for the
   complete `f_initiate_painting_warp` body. The trace is empty and the final
   memory is exactly the starting memory. No floor value, Mario action,
   painting index or callee behavior is assumed. The short circuit avoids
   every one of those reads/calls. A separate corollary obtains these two
   reads from explicit symbol, composite-field-offset and `Mem.load` facts.

2. **The selected delayed-demo dispatch executes its callee.** Beginning
   after the dialog-reset call and optional debug exit, Coq executes the
   actual `gCurrDemoInput` load and pointer-nonnull test. It then reads the
   actual delayed operation, tests operation 25, and invokes the real
   generated `f_warp_special` with -8 or -2. The proof constructs the internal
   function entry, all three stores, the normal return and the empty cleanup;
   it does not assume a completed `warp_special` execution. The final
   `sCurrPlayMode` is 4 and `D_80339EE0` holds the sign-extended negative
   control code. Every `Mem.load` outside the three written global blocks is
   preserved exactly.

3. **The entire transition-completion body returns the special code.** Given
   a null transition callback, transition timer zero and a zero real
   `sWarpDest.type` byte, Coq executes all of
   `f_play_mode_change_level`: it decrements the timer to -1, clears the HUD
   flags, resets the timer, clears the callback, tests the actual warp type,
   loads `D_80339EE0`, and returns that signed control value. It does not
   take the ordinary-level return branch. The result also includes the real
   internal `eval_funcall`, with function entry and cleanup proved. Loads outside the timer, HUD and
   callback global blocks are preserved. The required HUD flags offset 10
   and warp type offset zero have separately proved witnesses from the
   generated composite definitions.

The delayed-dispatch premises are explicit symbol/function resolutions, a
readable current demo pointer, its CompCert weak pointer validity, a readable
operation, writable mode/timer/control-code cells, and pairwise separation
of those three written blocks. Separation of a protected demo, level or
warp-destination block from the three written blocks is how the generic
memory frame is applied; it is not silently assumed by the theorem.

## A necessary restriction on the conclusion

`warp_special` does **not** clear `sWarpDest.type`. In the actual
`play_mode_change_level`, once the transition timer finishes, a nonzero warp
type causes `sWarpDest.levelNum` to be returned. Only a zero warp type causes
the negative `D_80339EE0` value to be returned. Consequently, executing the
demo branch and obtaining -8/-2 in that global is not by itself a proof
that an ordinary level cannot be selected. The zero-warp-destination
invariant remains a load-bearing obligation. The third theorem now executes
the consumer of this invariant; it does not establish the invariant from
normal starts.

This restriction matters even though the ordinary generated source route
looks favorable: `play_mode_normal` processes a pending `warp_area` before
the painting and delayed-warp checks; the painting routine is skipped under
the proved null-table condition; and the active-demo delayed branch skips
the ordinary `initiate_warp` calls. Proving that ordering from the actual
scheduler, with store/callee framing and actual area initialization, is
different from reading the source in that order.

## Concrete gameplay observation

`demo_normal_update_observation` reads the current demo pointer and signed
level number from the memory of the real Clight
`Callstate (Internal f_play_mode_normal) [] k m`. This is explicitly a
**normal gameplay-update observation**, not a complete definition of a
loaded, authenticated consumed-input episode. It excludes an isolated
`run_demo_inputs` call while the title screen fades.

For the full claim, the initialization path must establish a loaded area,
and the scheduler must connect the record consumed by
`read_controller_inputs` to this gameplay update. Reading `gCurrDemoInput`
at the update boundary alone does not identify that consumed record: the
input routine may already have advanced the pointer after decrementing the
previous record's timer. Stream provenance, rather than a single-pointer
equality, must be carried across the real scheduler execution.

## Remaining concrete composition

- Construct and preserve a null painting table in every actually loaded
  demo area. A finite opcode check without script interpretation and area
  construction does not establish the semantic load used above.
- Reach the delayed-dispatch entry through the actual pending-operation,
  timer, dialog-reset and debug prefix, preserving the current demo pointer
  and warp-destination state across that prefix.
- Establish and preserve `sWarpDest.type = 0`, the null transition callback
  and the expected timer state, instantiate the executed transition
  completion theorem, and follow its returned negative code through the
  real script interpreter. The negative code by itself is insufficient.
- Cover the pause path: `pressed_pause` has no direct demo-pointer guard.
  The relevant source ordering is that an active demo sees Start earlier
  in `play_mode_normal` and schedules its demo exit before the pause test;
  this requires actual execution/framing of `level_trigger_warp` and the
  intervening calls. Debug/frame-advance and credits reachability also need
  their concrete start-state exclusions.
- Link independent generated units with the correct public/private atoms,
  instantiate all symbol/layout and nonaliasing facts, and preserve stream,
  level, area, script and DMA state across every reached store and external.

These are localized obligations over named generated objects. They have
not been replaced by an axiom saying that gameplay cannot desync.

## Validation

The module was built using Ubuntu WSL and
`bash pipeline/build.sh audit-build AUDIT_VO_TARGETS=proofs/DemoGameplayBoundary.vo`.
The pipeline rechecked Coq 8.16.1 and CompCert 3.15 in the
`sm64-item-proof` switch with the established memory cap. The assumptions
inspection for `generated_demo_gameplay_boundary_us_jp` reported the
standard CompCert/classical axioms only. The project-wide discipline and
capstone checks are recorded by the parent report after wiring.
