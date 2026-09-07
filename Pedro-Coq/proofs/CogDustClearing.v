From Coq Require Import Lia List ZArith.
From compcert Require Import AST Clight Clightdefs ClightBigstep Cop Ctypes
  Events Integers Maps Memory Values.
From Pedro.Generated Require Import us_mario_actions_moving jp_mario_actions_moving.
From Pedro.Proofs Require Import GameTypes TTCCogExecution GroundGapReturn
  SlideKickDustExecution CogActionExecution.
Import ListNotations.
Open Scope Z_scope.
Module DC := us_mario_actions_moving.

(** This is the original dispatcher suffix AFTER its action switch. The
    cancellation/quicksand prefix and switch remain a separate obligation. *)
Definition cog_dispatcher_dust_tail version :=
  ground_right_suffix 3 (fn_body
    (match version with VersionUS => DC.f_mario_execute_moving_action
                       | VersionJP => jp_mario_actions_moving.f_mario_execute_moving_action end)).

Ltac dust_tail_temp :=
  repeat first [rewrite PTree.gss | rewrite PTree.gso by discriminate];
  first [eassumption | reflexivity |
    match goal with |- ?G => idtac "DUST TAIL LOCAL" G end; fail 100].
Ltac dust_tail_expr :=
  lazymatch goal with
  | |- eval_expr _ _ _ _ (Econst_int _ _) _ => constructor
  | |- eval_expr _ _ _ _ (Etempvar _ _) _ => eapply eval_Etempvar; dust_tail_temp
  | |- eval_expr _ _ _ _ (Ebinop _ _ _ _) _ =>
      eapply eval_Ebinop; [dust_tail_expr | dust_tail_expr | cbn; reflexivity]
  | |- eval_expr _ _ _ _ (Eunop _ _ _) _ =>
      eapply eval_Eunop; [dust_tail_expr | cbn; reflexivity]
  | |- eval_expr _ _ _ _ (Ecast _ _) _ =>
      eapply eval_Ecast; [dust_tail_expr | cbn; reflexivity]
  | |- eval_expr _ _ _ _ _ _ =>
      eapply eval_Elvalue; [dust_tail_lvalue |
       first [eapply deref_loc_value; [reflexivity | cbn; action_check cog_memory_load]
             |eapply deref_loc_copy; reflexivity]]
  end
with dust_tail_lvalue :=
  lazymatch goal with
  | |- eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ => eapply eval_Ederef; dust_tail_expr
  | |- eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ =>
      eapply eval_Efield_struct; [dust_tail_expr | reflexivity | eassumption | eassumption]
  end.
Ltac dust_tail_stmt :=
  lazymatch goal with
  | |- exec_stmt _ _ _ _ _ Sskip _ _ _ _ => constructor
  | |- exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ =>
      eapply exec_Sseq_1 with (t1 := E0) (t2 := E0); [dust_tail_stmt | dust_tail_stmt]
  | |- exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ => eapply exec_Sset; dust_tail_expr
  | |- exec_stmt _ _ _ _ _ (Sassign _ _) _ _ _ _ =>
      eapply exec_Sassign;
      [dust_tail_lvalue | dust_tail_expr | cbn; reflexivity |
       eapply assign_loc_value; [reflexivity | cbn; eassumption]]
  | |- exec_stmt _ _ _ _ _ (Sifthenelse _ _ _) _ _ _ _ =>
      eapply exec_Sifthenelse;
      [dust_tail_expr | cbn; reflexivity | cog_reduce_statement; dust_tail_stmt]
  | |- exec_stmt _ _ _ _ _ (Sreturn (Some _)) _ _ _ _ =>
      eapply exec_Sreturn_some; dust_tail_expr
  end.

Theorem generated_cog_dry_dispatcher_tail_us_jp :
  forall version ge environment locals memory mario,
    slide_caller_layout ge ->
    locals ! DC._m = Some (Vptr mario Ptrofs.zero) ->
    locals ! DC._cancel = Some (Vint Int.zero) ->
    Mem.load Mint16unsigned memory mario 2 = Some (Vint (Int.repr 4)) ->
    exists locals', exec_stmt function_entry2 ge environment locals memory
      (cog_dispatcher_dust_tail version) E0 locals' memory
      (Out_return (Some (Vint Int.zero, tint))).
Proof.
  intros version ge environment locals memory mario Hlayout Hm Hcancel Hinput.
  destruct Hlayout. eexists. destruct version; unfold cog_dispatcher_dust_tail;
    cbn [ground_right_suffix]; cog_reduce_statement; timeout 10 dust_tail_stmt.
Qed.

Definition cog_dust_clearing_claim version : Prop :=
  forall ge environment locals before mario (wet : bool),
    slide_caller_layout ge ->
    locals ! DC._m = Some (Vptr mario Ptrofs.zero) ->
    locals ! DC._cancel = Some (Vint Int.zero) ->
    Mem.load Mint16unsigned before mario 2 = Some (Vint (Int.repr (if wet then 516 else 4))) ->
    Mem.load Mint32 before mario 8 = Some (Vint (Int.repr 3)) ->
    Mem.valid_access before Mint32 mario 8 Writable ->
    exists after locals',
      exec_stmt function_entry2 ge environment locals before (cog_dispatcher_dust_tail version)
        E0 locals' after (Out_return (Some (Vint Int.zero, tint))) /\
      Mem.load Mint32 after mario 8 = Some (Vint (Int.repr (if wet then 1026 else 3))) /\
      slide_anchor after mario = slide_anchor before mario /\
      (wet = false -> after = before).

Theorem generated_cog_dispatcher_dust_clearing_us_jp :
  forall version, cog_dust_clearing_claim version.
Proof.
  intros version ge environment locals before mario wet Hlayout Hm Hcancel Hinput Hflags Hwrite.
  destruct Hlayout. destruct wet.
  - destruct (Mem.valid_access_store before Mint32 mario 8 (Vint (Int.repr 1027)) Hwrite)
      as [middle Hwave].
    destruct (Mem.valid_access_store middle Mint32 mario 8 (Vint (Int.repr 1026))
      ltac:(cog_memory_access)) as [after Hclear].
    exists after. eexists. split.
    + destruct version; unfold cog_dispatcher_dust_tail;
        cbn [ground_right_suffix]; cog_reduce_statement; timeout 10 dust_tail_stmt.
    + split; [cog_memory_load |].
      split; [|discriminate].
      rewrite (slide_particle_store_preserves_anchor _ _ _ _ Hclear),
        (slide_particle_store_preserves_anchor _ _ _ _ Hwave). reflexivity.
  - exists before. eexists. split.
    + destruct version; unfold cog_dispatcher_dust_tail;
        cbn [ground_right_suffix]; cog_reduce_statement; timeout 10 dust_tail_stmt.
    + repeat split; try assumption; reflexivity.
Qed.
