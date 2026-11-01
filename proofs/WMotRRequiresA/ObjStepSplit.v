(* ======================================================================= *)
(* ObjStepSplit.v -- the per-object step rows (ObjLoop.step_row), with     *)
(* GOAL 1's claim split out of their conclusion (2026-10-26).              *)
(*                                                                         *)
(* One object's update (the loop body of update_objects_starting_at /      *)
(* update_objects_during_time_stop up to the cursor advance: ObjLoop.      *)
(* loop_pre) must keep Mario's action outside the no-A taint set T         *)
(* (Taint.is_tainted).  That is GOAL 1's need from the objects phase, and  *)
(* it is the claim the action-writer census is about                       *)
(* (ActWriterCensus.census_value: outside Mario's frame only               *)
(* set_mario_npc_dialog writes the action, with ACT_READING_NPC_DIALOG).   *)
(* It becomes its own row, step_act_row; the rest of the step row,         *)
(* step_rest_row, may assume it.  step_row_split puts them back together,  *)
(* so ObjLoop's walk (terrain_keeps / nonterrain_keeps) is unchanged.      *)
(* ======================================================================= *)

From compcert Require Import Coqlib Maps AST Integers Values Memory Globalenvs
  Ctypes Clight ClightBigstep.
From SM64.Generated Require object_list_processor.
From SM64.Proofs Require Import ActionValueFrame Taint.
From SM64.Proofs.WMotRRequiresA Require ObjLoop.

Module OLP := SM64.Generated.object_list_processor.

Section Split.
  Variables (G : genv) (bm : block) (P : mem -> Prop) (inr : mem -> val -> val -> Prop) (f : function).

  (* THE NARROW ROW: one object's update keeps Mario's action outside T *)
  Definition step_act_row : Prop :=
    forall hd v le m t le' m' out, P m -> inr m hd v ->
      le ! OLP._firstObj = Some v -> le ! OLP._objList = Some hd ->
      exec_stmt function_entry2 G empty_env le m (ObjLoop.app_seq (ObjLoop.loop_pre f) Sskip) t le' m' out ->
      action_sat not_tainted m' bm.

  (* the rest of the step row, given the action claim at its end *)
  Definition step_rest_row : Prop :=
    forall hd v le m t le' m' out, P m -> inr m hd v ->
      le ! OLP._firstObj = Some v -> le ! OLP._objList = Some hd ->
      exec_stmt function_entry2 G empty_env le m (ObjLoop.app_seq (ObjLoop.loop_pre f) Sskip) t le' m' out ->
      action_sat not_tainted m' bm -> P m' /\ inr m' hd v.

  Lemma step_row_split : step_act_row -> step_rest_row -> ObjLoop.step_row G P inr f.
  Proof.
    intros A Rr hd v le m t le' m' out Hp Hi Hv Hh Hx.
    exact (Rr hd v le m t le' m' out Hp Hi Hv Hh Hx (A hd v le m t le' m' out Hp Hi Hv Hh Hx)).
  Qed.
End Split.
