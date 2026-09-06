From Coq Require Import List ZArith.
From compcert Require Import AST Clight Clightdefs ClightBigstep Cop Ctypes
  Events Floats Globalenvs Integers Maps Memory Values.
From Pedro.Generated Require Import us_obj_behaviors_2 jp_obj_behaviors_2.

Import ListNotations.
Open Scope Z_scope.
Module C := us_obj_behaviors_2.

Theorem cog_approach_function_identical_us_jp :
  C.f_approach_f32_ptr = jp_obj_behaviors_2.f_approach_f32_ptr.
Proof. reflexivity. Qed.

Definition cog_zero : val := Vsingle Float32.zero.
Definition cog_fifty : val :=
  Vsingle (Float32.of_bits (Int.repr 1112014848)).

(** These constructor tactics only assemble standard ClightBigstep derivations.
    Every load and store is discharged by an explicit CompCert memory fact. *)
Ltac cog_scalar_expr :=
  lazymatch goal with
  | |- eval_expr _ _ _ _ (Econst_int _ _) _ => constructor
  | |- eval_expr _ _ _ _ (Econst_single _ _) _ => constructor
  | |- eval_expr _ _ _ _ (Etempvar _ _) _ =>
      eapply eval_Etempvar; cbn; reflexivity
  | |- eval_expr _ _ _ _ (Ederef _ _) _ =>
      eapply eval_Elvalue;
      [ eapply eval_Ederef; cog_scalar_expr
      | eapply deref_loc_value; [reflexivity | cbn; eassumption] ]
  | |- eval_expr _ _ _ _ (Ebinop _ _ _ _) _ =>
      eapply eval_Ebinop;
      [cog_scalar_expr | cog_scalar_expr | cbn; reflexivity]
  | |- eval_expr _ _ _ _ (Eunop _ _ _) _ =>
      eapply eval_Eunop; [cog_scalar_expr | cbn; reflexivity]
  end.

Ltac cog_scalar_stmt :=
  lazymatch goal with
  | |- exec_stmt _ _ _ _ _ Sskip _ _ _ _ => constructor
  | |- exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ =>
      first
        [ eapply exec_Sseq_1 with (t1 := E0) (t2 := E0);
          [cog_scalar_stmt | cog_scalar_stmt]
        | eapply exec_Sseq_2; [cog_scalar_stmt | discriminate] ]
  | |- exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ =>
      eapply exec_Sset; cog_scalar_expr
  | |- exec_stmt _ _ _ _ _ (Sassign (Ederef _ _) _) _ _ _ _ =>
      eapply exec_Sassign;
      [eapply eval_Ederef; cog_scalar_expr
      |cog_scalar_expr
      |cbn; reflexivity
      |eapply assign_loc_value; [reflexivity | cbn; eassumption]]
  | |- exec_stmt _ _ _ _ _ (Sifthenelse _ _ _) _ _ _ _ =>
      first
        [eapply exec_Sifthenelse with (b := false);
         [cog_scalar_expr | vm_compute; reflexivity | cbn; cog_scalar_stmt]
        |eapply exec_Sifthenelse with (b := true);
         [cog_scalar_expr | vm_compute; reflexivity | cbn; cog_scalar_stmt]]
  | |- exec_stmt _ _ _ _ _ (Sreturn (Some _)) _ _ _ _ =>
      eapply exec_Sreturn_some; cog_scalar_expr
  end.

(** Byte 248 is rawData byte 136 + 4*28, the generated cog speed access.
    The caller/layout connection is a separate obligation. There is no
    assumed helper execution: both stores, the overshoot test, and return 1
    are proved for the complete generated helper. *)
Definition cog_approach_zero_execution_claim : Prop :=
  forall (ge : Clight.genv) memory_before object_block,
    Mem.load Mfloat32 memory_before object_block 248 = Some cog_zero ->
    Mem.valid_access memory_before Mfloat32 object_block 248 Writable ->
    exists memory_after,
      eval_funcall function_entry2 ge memory_before
        (Internal C.f_approach_f32_ptr)
        [Vptr object_block (Ptrofs.repr 248); cog_zero; cog_fifty]
        E0 memory_after (Vint Int.one) /\
      Mem.load Mfloat32 memory_after object_block 248 = Some cog_zero.

Lemma generated_cog_approach_zero_with_stores :
  forall (ge : Clight.genv) memory_before object_block
      memory_transient memory_after,
    Mem.load Mfloat32 memory_before object_block 248 = Some cog_zero ->
    Mem.store Mfloat32 memory_before object_block 248 cog_fifty =
      Some memory_transient ->
    Mem.store Mfloat32 memory_transient object_block 248 cog_zero =
      Some memory_after ->
    eval_funcall function_entry2 ge memory_before
      (Internal C.f_approach_f32_ptr)
      [Vptr object_block (Ptrofs.repr 248); cog_zero; cog_fifty]
      E0 memory_after (Vint Int.one).
Proof.
  intros ge memory_before object_block memory_transient memory_after
    Hload0 Hstore50 Hstore0.
  pose proof (Mem.load_store_same _ _ _ _ _ _ Hstore50) as Hload50.
  pose proof (Mem.load_store_same _ _ _ _ _ _ Hstore0) as Hload_end.
  cbn in Hload50, Hload_end.
  eapply eval_funcall_internal.
    + eapply function_entry2_intro.
      * constructor.
      * cbn. apply Coqlib.list_norepet_cons.
        -- cbn. intros [H | [H | H]]; try contradiction;
             vm_compute in H; discriminate.
        -- apply Coqlib.list_norepet_cons.
           ++ cbn. intros [H | H]; try contradiction;
                vm_compute in H; discriminate.
           ++ apply Coqlib.list_norepet_cons.
              ** cbn; tauto.
              ** apply Coqlib.list_norepet_nil.
      * vm_compute. intros x y Hx Hy Heq. subst y. intuition congruence.
      * constructor.
      * reflexivity.
    + simpl fn_body. cog_scalar_stmt.
    + cbn. split; [discriminate | reflexivity].
    + cbn. reflexivity.
Qed.

Theorem generated_cog_approach_zero_executes :
  cog_approach_zero_execution_claim.
Proof.
  intros ge memory_before object_block Hload0 Hwrite0.
  destruct (Mem.valid_access_store memory_before Mfloat32 object_block 248
    cog_fifty Hwrite0) as [memory_transient Hstore50].
  pose proof (Mem.store_valid_access_1 _ _ _ _ _ _ Hstore50
    Mfloat32 object_block 248 Writable Hwrite0) as Hwrite50.
  destruct (Mem.valid_access_store memory_transient Mfloat32 object_block 248
    cog_zero Hwrite50) as [memory_after Hstore0].
  exists memory_after; split.
  - eapply generated_cog_approach_zero_with_stores; eassumption.
  - exact (Mem.load_store_same _ _ _ _ _ _ Hstore0).
Qed.

Theorem generated_cog_approach_zero_executes_jp :
  forall (ge : Clight.genv) memory_before object_block,
    Mem.load Mfloat32 memory_before object_block 248 = Some cog_zero ->
    Mem.valid_access memory_before Mfloat32 object_block 248 Writable ->
    exists memory_after,
      eval_funcall function_entry2 ge memory_before
        (Internal jp_obj_behaviors_2.f_approach_f32_ptr)
        [Vptr object_block (Ptrofs.repr 248); cog_zero; cog_fifty]
        E0 memory_after (Vint Int.one) /\
      Mem.load Mfloat32 memory_after object_block 248 = Some cog_zero.
Proof. exact generated_cog_approach_zero_executes. Qed.
