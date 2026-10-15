From Coq Require Import List ZArith.
From compcert Require Import AST Clight Clightdefs ClightBigstep Coqlib Cop
  Ctypes Errors Events Globalenvs Integers Maps Memdata Memory Values.
From Demo.Generated Require Import us_level_update jp_level_update.
From Demo.Proofs Require Import DemoStartExecution.
Import ListNotations.
Local Open Scope Z_scope.
Module I := us_level_update.

(** Execute each actual generated version.  A non-castle level skips the
    castle/star query; a null instant-warp table then prevents every warp
    store/call, independently of the readable floor's surface type. *)

Definition selected_instant_warp (us : bool) : function :=
  if us then I.f_check_instant_warp else jp_level_update.f_check_instant_warp.

Ltac instant_reduce :=
  first
  [match goal with
   | H : Int.eq ?level (Int.repr 6) = false |- _ = ?out =>
       change (Some (Val.of_bool (Int.eq level (Int.repr 6))) = out);
       rewrite H; reflexivity
   end
  |match goal with
   | H : Int.cmp ?comparison ?left ?right = ?choice |- _ = ?out =>
       change (Some (Val.of_bool (Int.cmp comparison left right)) = out);
       rewrite H; reflexivity
   end
  |match goal with
   | H : Mem.weak_valid_pointer ?m ?b (Ptrofs.unsigned Ptrofs.zero) = true |- _ = ?out =>
       change (option_map Val.of_bool
         (if Mem.weak_valid_pointer m b (Ptrofs.unsigned Ptrofs.zero)
          then Some true else None) = out);
       rewrite H; reflexivity
   end
  |reflexivity].

Ltac instant_expr :=
  lazymatch goal with
  | |- eval_expr _ _ _ _ (Etempvar _ _) _ =>
      eapply eval_Etempvar; repeat rewrite PTree.gsspec;
      cbn -[Int.cmp Int.sub Int.eq]; first [reflexivity | eassumption]
  | |- eval_expr _ _ _ _ (Ebinop _ _ _ _) _ =>
      eapply eval_Ebinop; [instant_expr | instant_expr | instant_reduce]
  | |- eval_expr _ _ _ _ (Ecast _ _) _ =>
      eapply eval_Ecast; [instant_expr | instant_reduce]
  | _ => first [demo_expr |
      match goal with |- ?g => idtac "INSTANT EXPR FAILED" g end; fail 1000]
  end.

Ltac instant_stmt :=
  lazymatch goal with
  | |- exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ =>
      eapply exec_Sseq_1 with (t1 := E0) (t2 := E0); [instant_stmt | instant_stmt]
  | |- exec_stmt _ _ _ _ _ (Sifthenelse _ _ _) _ _ _ _ =>
      first
      [eapply exec_Sifthenelse with (v1 := Vzero) (b := false);
        [instant_expr | reflexivity | instant_stmt]
      |eapply exec_Sifthenelse with (v1 := Vint Int.one) (b := true);
        [instant_expr | reflexivity | instant_stmt]]
  | |- exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ => eapply exec_Sset; instant_expr
  | |- exec_stmt _ _ _ _ _ Sskip _ _ _ _ => apply exec_Sskip
  end.

Ltac instant_call :=
  lazymatch goal with
  | |- eval_funcall function_entry2 ?ge ?memory (Internal ?f) [] E0 ?memory Vundef =>
    eapply eval_funcall_internal with (e := empty_env)
      (le1 := create_undef_temps (fn_temps f))
      (m1 := memory) (m2 := memory) (out := Out_normal);
    [eapply function_entry2_intro;
      [change (list_norepet ([] : list ident)); apply list_norepet_nil |
       change (list_norepet ([] : list ident)); apply list_norepet_nil |
       unfold list_disjoint; cbn [I.f_check_instant_warp jp_level_update.f_check_instant_warp fn_params var_names]; tauto |
       cbn [I.f_check_instant_warp jp_level_update.f_check_instant_warp fn_vars]; apply alloc_variables_nil |
       reflexivity]
    |cbn [I.f_check_instant_warp jp_level_update.f_check_instant_warp fn_body]; instant_stmt
    |reflexivity
    |reflexivity]
  end.

Definition demo_instant_warp_null_table_execution_claim : Prop :=
  forall (ge : Clight.genv) m level_global level mario_global mario mario_co
      floor floor_co floor_type current area area_co,
    Genv.find_symbol ge I._gCurrLevelNum = Some level_global ->
    Mem.load Mint16signed m level_global 0 = Some (Vint level) ->
    Int.eq level (Int.repr 6) = false ->
    Genv.find_symbol ge I._gMarioState = Some mario_global ->
    Mem.load Mptr m mario_global 0 = Some (Vptr mario Ptrofs.zero) ->
    (genv_cenv ge) ! I._MarioState = Some mario_co ->
    field_offset (genv_cenv ge) I._floor (co_members mario_co) = OK (104, Full) ->
    Mem.load Mptr m mario 104 = Some (Vptr floor Ptrofs.zero) ->
    Mem.weak_valid_pointer m floor (Ptrofs.unsigned Ptrofs.zero) = true ->
    (genv_cenv ge) ! I._Surface = Some floor_co ->
    field_offset (genv_cenv ge) I._type (co_members floor_co) = OK (0, Full) ->
    Mem.load Mint16signed m floor 0 = Some (Vint floor_type) ->
    Genv.find_symbol ge I._gCurrentArea = Some current ->
    Mem.load Mptr m current 0 = Some (Vptr area Ptrofs.zero) ->
    (genv_cenv ge) ! I._Area = Some area_co ->
    field_offset (genv_cenv ge) I._instantWarps (co_members area_co) = OK (28, Full) ->
    Mem.load Mptr m area 28 = Some Vzero ->
    forall us, eval_funcall function_entry2 ge m (Internal (selected_instant_warp us))
      [] E0 m Vundef.

Theorem generated_instant_warp_null_table_skips_us_jp :
  demo_instant_warp_null_table_execution_claim.
Proof.
  intros ge m level_global level mario_global mario mario_co floor floor_co
    floor_type current area area_co Hlevel_symbol Hlevel Hnotcastle
    Hmario_symbol Hmario Hmario_co Hfloor_offset Hfloor Hfloor_valid
    Hfloor_co Htype_offset Hfloor_type Hcurrent Harea Harea_co Hinstant_offset Hnull us.
  destruct us;
    destruct (Int.cmp Cge (Int.sub floor_type (Int.repr 27)) Int.zero) eqn:Hlower;
    destruct (Int.cmp Clt (Int.sub floor_type (Int.repr 27)) (Int.repr 4)) eqn:Hupper;
    cbn [selected_instant_warp]; instant_call.
Qed.

Definition demo_instant_warp_null_floor_execution_claim : Prop :=
  forall (ge : Clight.genv) m level_global level mario_global mario mario_co,
    Genv.find_symbol ge I._gCurrLevelNum = Some level_global ->
    Mem.load Mint16signed m level_global 0 = Some (Vint level) ->
    Int.eq level (Int.repr 6) = false ->
    Genv.find_symbol ge I._gMarioState = Some mario_global ->
    Mem.load Mptr m mario_global 0 = Some (Vptr mario Ptrofs.zero) ->
    (genv_cenv ge) ! I._MarioState = Some mario_co ->
    field_offset (genv_cenv ge) I._floor (co_members mario_co) = OK (104, Full) ->
    Mem.load Mptr m mario 104 = Some Vzero ->
    forall us, eval_funcall function_entry2 ge m (Internal (selected_instant_warp us))
      [] E0 m Vundef.

Theorem generated_instant_warp_null_floor_skips_us_jp :
  demo_instant_warp_null_floor_execution_claim.
Proof.
  intros ge m level_global level mario_global mario mario_co
    Hlevel_symbol Hlevel Hnotcastle Hmario_symbol Hmario Hmario_co Hfloor_offset Hfloor us.
  destruct us; cbn [selected_instant_warp]; instant_call.
Qed.

Definition demo_instant_warp_execution_claim : Prop :=
  demo_instant_warp_null_table_execution_claim /\
  demo_instant_warp_null_floor_execution_claim.

Theorem generated_demo_instant_warp_execution_us_jp :
  demo_instant_warp_execution_claim.
Proof.
  split.
  - exact generated_instant_warp_null_table_skips_us_jp.
  - exact generated_instant_warp_null_floor_skips_us_jp.
Qed.
