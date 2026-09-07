From Coq Require Import List ZArith.
From compcert Require Import AST Clight Clightdefs ClightBigstep Cop Ctypes
  Events Globalenvs Integers Maps Memory Values.
From Pedro.Generated Require Import
  us_envfx_snow jp_envfx_snow us_ingame_menu jp_ingame_menu us_ttc_geo jp_ttc_geo.
From Pedro.Proofs Require Import GameTypes TTCCogExecution.
Import ListNotations.
Open Scope Z_scope.
Module ES := us_envfx_snow.
Module EM := us_ingame_menu.

Definition environment_update_function version : function :=
  match version with VersionUS => ES.f_envfx_update_particles
                   | VersionJP => jp_envfx_snow.f_envfx_update_particles end.
Definition environment_init_function version : function :=
  match version with VersionUS => ES.f_envfx_init_snow
                   | VersionJP => jp_envfx_snow.f_envfx_init_snow end.
Definition environment_dialog_function version : function :=
  match version with VersionUS => EM.f_get_dialog_id
                   | VersionJP => jp_ingame_menu.f_get_dialog_id end.

Ltac environment_stmt :=
  lazymatch goal with
  | |- exec_stmt _ _ _ _ _ Sskip _ _ _ _ => constructor
  | |- exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ =>
      first [eapply exec_Sseq_1 with (t1 := E0) (t2 := E0);
             [environment_stmt | environment_stmt]
            |eapply exec_Sseq_2; [environment_stmt | discriminate]]
  | |- exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ =>
      eapply exec_Sset; cog_expr
  | |- exec_stmt _ _ _ _ _ (Sifthenelse _ _ _) _ _ _ _ =>
      eapply exec_Sifthenelse;
      [cog_expr | cbn; reflexivity | cog_reduce_statement; environment_stmt]
  | |- exec_stmt _ _ _ _ _ (Sswitch _ _) _ _ _ _ =>
      eapply exec_Sswitch with (n := 0);
      [cog_expr | cbn; reflexivity | cog_reduce_statement; environment_stmt]
  | |- exec_stmt _ _ _ _ _ (Sreturn (Some _)) _ _ _ _ =>
      eapply exec_Sreturn_some; cog_expr
  | |- exec_stmt _ _ _ _ _ (Scall _ _ _) _ _ _ _ =>
      eapply exec_Scall;
      [reflexivity | cog_expr | cog_arguments |
       eapply cog_find_funct_zero; eassumption | reflexivity | eassumption]
  end.

Theorem generated_dialog_none_getter_us_jp :
  forall version (ge : Clight.genv) memory dialog,
    Genv.find_symbol ge EM._gDialogID = Some dialog ->
    Mem.load Mint16signed memory dialog 0 = Some (Vint (Int.repr (-1))) ->
    eval_funcall function_entry2 ge memory (Internal (environment_dialog_function version))
      [] E0 memory (Vint (Int.repr (-1))).
Proof.
  intros version ge memory dialog Hsymbol Hload.
  destruct version; cbn [environment_dialog_function].
  all: eapply eval_funcall_internal.
  1,5: eapply function_entry2_intro;
    [cbn; apply Coqlib.list_norepet_nil | cbn; cog_norepet |
     cbn; intros x y Hx; contradiction | cbn; apply alloc_variables_nil | cbn; reflexivity].
  1,4: simpl fn_body; environment_stmt.
  1,3: cbn; split; [discriminate | reflexivity].
  all: cbn; reflexivity.
Qed.

Theorem generated_environment_init_none_us_jp :
  forall version (ge : Clight.genv) memory,
    eval_funcall function_entry2 ge memory (Internal (environment_init_function version))
      [Vint Int.zero] E0 memory (Vint Int.zero).
Proof.
  intros version ge memory. destruct version; cbn [environment_init_function].
  all: eapply eval_funcall_internal.
  1,5: eapply function_entry2_intro;
    [cbn; apply Coqlib.list_norepet_nil | cbn; cog_norepet |
     vm_compute; intros x y Hx Hy Heq; subst y; intuition congruence |
     cbn; apply alloc_variables_nil | cbn; reflexivity].
  1,4: simpl fn_body; environment_stmt.
  1,3: cbn; split; [discriminate | reflexivity].
  all: cbn; reflexivity.
Qed.

(** Complete generated update, including both real callees. No callee
    execution is assumed. The two global values and symbol/function bindings
    remain entry premises. Connecting TTC's geometry callback to these values
    across level entry is a separate obligation. *)
Definition environment_none_execution_claim version : Prop :=
  forall (ge : Clight.genv) memory dialog mode getter initialize marioPos camTo camFrom,
    Genv.find_symbol ge EM._gDialogID = Some dialog ->
    Genv.find_symbol ge ES._gEnvFxMode = Some mode ->
    Genv.find_symbol ge ES._get_dialog_id = Some getter ->
    Genv.find_funct_ptr ge getter = Some (Internal (environment_dialog_function version)) ->
    Genv.find_symbol ge ES._envfx_init_snow = Some initialize ->
    Genv.find_funct_ptr ge initialize = Some (Internal (environment_init_function version)) ->
    Mem.load Mint16signed memory dialog 0 = Some (Vint (Int.repr (-1))) ->
    Mem.load Mint8signed memory mode 0 = Some (Vint Int.zero) ->
    eval_funcall function_entry2 ge memory (Internal (environment_update_function version))
      [Vint Int.zero; marioPos; camTo; camFrom] E0 memory (Vint Int.zero).

Theorem generated_environment_none_preserves_all_memory_us_jp :
  forall version, environment_none_execution_claim version.
Proof.
  intros version ge memory dialog mode getter initialize marioPos camTo camFrom
    Hdialog Hmode Hgetter Hgetterfn Hinit Hinitfn Hdialogload Hmodeload.
  pose proof (generated_dialog_none_getter_us_jp version ge memory dialog Hdialog Hdialogload) as Hgetcall.
  pose proof (generated_environment_init_none_us_jp version ge memory) as Hinitcall.
  destruct version;
    cbn [environment_update_function environment_dialog_function environment_init_function] in *.
  all: eapply eval_funcall_internal.
  1,5: eapply function_entry2_intro;
    [cbn; apply Coqlib.list_norepet_nil | cbn; cog_norepet |
     vm_compute; intros x y Hx Hy Heq; subst y; intuition congruence |
     cbn; apply alloc_variables_nil | cbn; reflexivity].
  1,4: simpl fn_body; environment_stmt.
  1,3: cbn; split; [discriminate | reflexivity].
  all: cbn; reflexivity.
Qed.

Definition ttc_environment_callback_words version : list init_data :=
  skipn 37 (gvar_init
    (match version with VersionUS => us_ttc_geo.v_ttc_geo_0003B8
                        | VersionJP => jp_ttc_geo.v_ttc_geo_0003B8 end)).

Theorem generated_ttc_environment_callback_zero_argument_us_jp :
  forall version,
    firstn 2 (ttc_environment_callback_words version) =
      [Init_int32 (Int.repr 402653184);
       Init_addrof us_ttc_geo._geo_envfx_main Ptrofs.zero].
Proof. intros []; vm_compute; reflexivity. Qed.

Definition environment_exclusion_frontier_claim : Prop :=
  (forall version, environment_none_execution_claim version) /\
  (forall version, firstn 2 (ttc_environment_callback_words version) =
    [Init_int32 (Int.repr 402653184);
     Init_addrof us_ttc_geo._geo_envfx_main Ptrofs.zero]).

Theorem checked_environment_exclusion_frontier_us_jp : environment_exclusion_frontier_claim.
Proof. exact (conj generated_environment_none_preserves_all_memory_us_jp
  generated_ttc_environment_callback_zero_argument_us_jp). Qed.
