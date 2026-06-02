(* RealFrameValue.v -- the funcall->value bridge for the REAL per-frame entry.
 *
 * GOAL-1 tethering step. NoAImpliesNoFly's capstone rested on an ABSTRACT
 * `step` and a black-box `frame_preserves_nonflying`. This file replaces that
 * with the value engine applied to the REAL clightgen'd per-frame function
 * `mario.f_execute_mario_action`, reducing the per-frame obligation to the
 * value engine's named reach residuals over the real Mario genv.
 *
 * WHY A NEW BRIDGE (vs. FuncallFrame.funcall_body_nf_preserves). The existing
 * store-frame funcall bridge REQUIRES `_m` (Mario's pointer) as the function's
 * first formal, because its engine tracks a `tmps_off_bm` provenance invariant
 * over pointer temps. The real entry `execute_mario_action(struct Object *o)`
 * takes an OBJECT pointer and finds Mario by loading the `gMarioState` global
 * INTERNALLY -- so a temp DOES hold bm, and that engine's invariant is the
 * wrong fit. The VALUE engine (ActionValueFrame.exec_stmt_value_preserves)
 * tracks only `action_sat Q m bm` -- a fact about the watched cell (bm,12),
 * independent of params and temps. So the value bridge below needs NO
 * param-shape and NO temp hypotheses: it works for ANY `f` with no stack vars.
 *
 * WHAT IS TETHERED / WHAT REMAINS (no buried lede):
 *   - `funcall_value_preserves` (generic): a whole eval_funcall of any
 *     fn_vars=nil function carries `action_sat Q` forward, GIVEN the value
 *     engine's reach residuals + the function body's own per-Sassign value-ok.
 *     This is the entry inversion (function_entry2 -> exec_stmt of the body ->
 *     free_list), proved here, with no admit.
 *   - The residuals it leaves, specialized to execute_mario_action, are the
 *     interprocedural reach closure over the REAL genv:
 *       reach_value_preserves nonflying bm mario_ge   (THE CRUX)
 *       reach_ext_preserves (action_cell bm) mario_ge
 *     plus the decidable, body-local `stmt_value_ok` of execute_mario_action.
 *
 * THE CRUX, named honestly. `reach_value_preserves nonflying bm mario_ge`
 * (every reached funcall preserves the non-flying action) is the interprocedural
 * generalization the value engine inducts on. As stated UNCONDITIONALLY it is
 * still too strong -- `set_mario_action(m, ACT_FLYING, _)` is a reached funcall
 * that does NOT preserve non-flying. Closing it needs the no-A carve-out (the
 * only action writer is set_mario_action; under a no-A frame its argument is
 * non-flying -- ActionValue.set_mario_action_field + the ActionWriters corpus).
 * That conditioning is the next crux; here we reduce the capstone TO it, over
 * the real callgraph, with the entry inversion fully discharged.
 *
 * No Admitted.
 *)

From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Clight ClightBigstep.
From Coq Require Import List.
Import ListNotations.
From SM64.Generated Require mario.
From SM64.Proofs Require Import Flying ActionValue FieldNonInterference ActionValueFrame.

(* ================================================================== *)
(* THE GENERIC FUNCALL -> VALUE BRIDGE.                                 *)
(*                                                                     *)
(* For ANY function f with no stack vars (fn_vars = nil, the clightgen- *)
(* normalised shape), a whole eval_funcall preserves `action_sat Q`     *)
(* at the watched block bm, GIVEN the value engine's reach residuals     *)
(* (reach_value_preserves / reach_ext_preserves over the call genv) and  *)
(* the function body's own per-Sassign value-ok check. Unlike the store- *)
(* frame bridge this needs NO param-shape and NO temp invariant -- the    *)
(* value invariant is about the cell (bm,12) alone, so the params/temps   *)
(* the entry sets up are irrelevant to it.                                *)
(* ================================================================== *)
Theorem funcall_value_preserves :
  forall (Q : int -> Prop) (bm : block) (ge : genv) (f : function)
         vargs m m' t res,
    reach_value_preserves Q bm ge ->
    reach_ext_preserves (action_cell bm) ge ->
    fn_vars f = nil ->
    (forall e, stmt_value_ok Q bm ge e (fn_body f)) ->
    Mem.valid_block m bm ->
    action_sat Q m bm ->
    eval_funcall function_entry2 ge m (Internal f) vargs t m' res ->
    Mem.valid_block m' bm /\ action_sat Q m' bm.
Proof.
  intros Q bm ge f vargs m m' t res Hreach Hext Hvars Hok Hv Hsat Hfun.
  inv Hfun.
  (* entry: fn_vars = nil makes alloc_variables trivial (e = empty_env, mem kept) *)
  match goal with Hfe : function_entry2 _ _ _ _ _ _ _ |- _ => inv Hfe end.
  match goal with Hav : alloc_variables _ _ _ _ _ _ |- _ =>
    rewrite Hvars in Hav; inv Hav end.
  (* run the value engine over the body (e = empty_env, le = the bound temps) *)
  match goal with
  | Hexec : exec_stmt function_entry2 ge empty_env _ _ (fn_body f) _ _ _ _ |- _ =>
      destruct (exec_stmt_value_preserves Q bm ge Hreach Hext
                  _ _ _ _ _ _ _ _
                  Hexec Hv Hsat (Hok empty_env)) as [Hv2 Hsat2]
  end.
  (* free_list of the empty env touches nothing: result mem = body's m2 *)
  match goal with Hfree : Mem.free_list _ _ = Some _ |- _ =>
    assert (Hbe : blocks_of_env ge empty_env = nil) by reflexivity;
    rewrite Hbe in Hfree; cbn [Mem.free_list] in Hfree; inv Hfree end.
  exact (conj Hv2 Hsat2).
Qed.

(* ================================================================== *)
(* THE REAL PER-FRAME ENTRY, specialized.                              *)
(*                                                                     *)
(* `mario.f_execute_mario_action` is the per-frame Mario action dispatch *)
(* (one game tick's Mario update). It has fn_vars = nil (clightgen-       *)
(* normalised), so the generic bridge applies with NO param-shape side    *)
(* condition -- even though its formal is an Object pointer and it finds   *)
(* Mario via the gMarioState global internally. A whole frame therefore    *)
(* carries the non-flying action invariant forward, reduced to the value    *)
(* engine's reach residuals over the REAL Mario genv.                       *)
(* ================================================================== *)

Definition mario_ge : genv := globalenv mario.prog.

(* The non-flying action predicate (Q for the value engine). *)
Definition nonflying (v : int) : Prop := is_flying_int v = false.

(* One real per-frame Mario update: a CompCert big-step of the actual
   f_execute_mario_action on an Object pointer. (The input is latched in
   memory; the value-engine preservation below holds for ANY input -- the
   no-A carve-out lives inside reach_value_preserves, not here.) *)
Definition execute_mario_action_step (m m' : mem) : Prop :=
  exists (b_o : block) (t : trace) (res : val),
    eval_funcall function_entry2 mario_ge m
      (Internal mario.f_execute_mario_action)
      (Vptr b_o Ptrofs.zero :: nil) t m' res.

(* THE REDUCTION: a real frame preserves (valid bm /\ non-flying action),
   GIVEN exactly the value engine's three named residuals over mario_ge:
     - reach_value_preserves nonflying bm mario_ge   (THE interprocedural crux)
     - reach_ext_preserves (action_cell bm) mario_ge
     - the body-local per-Sassign value-ok of execute_mario_action's own body
       (decidable; the body's direct writes avoid the action cell or store a
       non-flying value -- the action writes happen in CALLEES, governed by
       reach_value_preserves, not here).
   No param-shape, no temp invariant, no gMarioState well-formedness: the
   value invariant is about the cell (bm,12) alone. *)
Theorem execute_mario_action_preserves_nonflying :
  forall (bm : block) m m',
    reach_value_preserves nonflying bm mario_ge ->
    reach_ext_preserves (action_cell bm) mario_ge ->
    (forall e, stmt_value_ok nonflying bm mario_ge e
                 (fn_body mario.f_execute_mario_action)) ->
    Mem.valid_block m bm ->
    action_sat nonflying m bm ->
    execute_mario_action_step m m' ->
    Mem.valid_block m' bm /\ action_sat nonflying m' bm.
Proof.
  intros bm m m' Hreach Hext Hok Hv Hsat (b_o & t & res & Hfun).
  exact (funcall_value_preserves nonflying bm mario_ge
           mario.f_execute_mario_action (Vptr b_o Ptrofs.zero :: nil) m m' t res
           Hreach Hext eq_refl Hok Hv Hsat Hfun).
Qed.
