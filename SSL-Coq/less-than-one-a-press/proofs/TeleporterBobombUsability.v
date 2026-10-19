(** A live, scheduled Bob-omb uses its own held-state word.  This module
    follows actual generated executions to the held behavior and its relative
    positioning call.  It does not establish survival across an area unload,
    regrabbing, cloning, or a reachable complete wrong warp. *)
From Coq Require Import Bool List ZArith.
From compcert Require Import AST Clight ClightBigstep Clightdefs Cop Ctypes
  Events Floats Globalenvs Integers Maps Memory Values.
From LessThanOneAPress.Generated Require Import us_obj_behaviors jp_obj_behaviors.
From LessThanOneAPress.Proofs Require Import GameTypes ObjectContactNecessity
  InkBackwardExecution InkActionTimerReset ContactConsumerExecution
  TeleporterHeldObjectState TeleporterDestinationReset SelectedClightTarget
  InkRawCopyExpressions
  UpperElevatorQueryResolution CleanedClightPrograms ClightLinkExecution
  GlobalInterfaceStructural JPSourceSymbolTransport JPWarpLevelEntryResolution
  LinkedClightPrograms NormalizedClightPrograms SuccessfulMakeProgramResolution
  USViewportRepairedNamesNorepet USViewportRepairedProgramSelection
  USWarpLevelRepairReceipt USWarpLevelSourceUnionReceipt USWholeASTTagRepair
  SecretContactExecution.
Import ListNotations.
Local Open Scope Z_scope.

Definition tbu_bobomb_function version := match version with
| VersionUS => us_obj_behaviors.f_bhv_bobomb_loop
| VersionJP => jp_obj_behaviors.f_bhv_bobomb_loop end.
Definition tbu_held_function version := match version with
| VersionUS => us_obj_behaviors.f_bobomb_held_loop
| VersionJP => jp_obj_behaviors.f_bobomb_held_loop end.
Definition tbu_radius_prefix version := match fn_body (tbu_bobomb_function version) with
| Ssequence prefix _ => prefix | _ => Sskip end.
Definition tbu_active_branch version := match fn_body (tbu_bobomb_function version) with
| Ssequence _ (Sifthenelse _ yes _) => yes | _ => Sskip end.
Definition tbu_dispatch version := match tbu_active_branch version with
| Ssequence dispatch _ => dispatch | _ => Sskip end.
Definition tbu_after_dispatch version := match tbu_active_branch version with
| Ssequence _ tail => tail | _ => Sskip end.
Definition tbu_held_read version := match tbu_dispatch version with
| Ssequence _ (Ssequence (Sset _ read) _) => read
| _ => Econst_int Int.zero tuint end.
Definition TBUGeneratedHeldRead : Prop := forall version,
  tbu_held_read version = Ederef (Ebinop Oadd
    (Efield (irc_raw_union version us_obj_behaviors._t'13)
      us_obj_behaviors._asU32 (tarray tuint 80))
    (Econst_int (Int.repr 39) tint) (tptr tuint)) tuint.
Theorem tbu_generated_held_read_exact : TBUGeneratedHeldRead.
Proof. intros []; reflexivity. Qed.
Definition tbu_cases version := match tbu_dispatch version with
| Ssequence _ (Ssequence _ (Sswitch _ cases)) => cases | _ => LSnil end.
Definition tbu_held_call := Scall None
  (Evar us_obj_behaviors._bobomb_held_loop (Tfunction [] tvoid cc_default)) [].
Definition tbu_cases_after_held version := match tbu_cases version with
| LScons _ _ (LScons _ _ rest) => rest | _ => LSnil end.
Lemma tbu_selected_held_case_exact : forall version,
  seq_of_labeled_statement (select_switch 1 (tbu_cases version)) =
    Ssequence (Ssequence tbu_held_call Sbreak)
      (seq_of_labeled_statement (tbu_cases_after_held version)).
Proof. intros []; reflexivity. Qed.
Definition tbu_follow_prefix version := ocn_prefix_items 2 (fn_body (tbu_held_function version)).
Definition tbu_follow_block version := match fn_body (tbu_held_function version) with
| Ssequence _ (Ssequence _ (Ssequence block _)) => block | _ => Sskip end.
Definition tbu_after_follow version := match fn_body (tbu_held_function version) with
| Ssequence _ (Ssequence _ (Ssequence _ tail)) => tail | _ => Sskip end.
Definition tbu_follow_call := Scall None
  (Evar us_obj_behaviors._cur_obj_set_pos_relative
    (Tfunction ((tptr (Tstruct us_obj_behaviors._Object noattr)) ::
      tfloat :: tfloat :: tfloat :: []) tvoid cc_default))
  [Etempvar us_obj_behaviors._t'8 (tptr (Tstruct us_obj_behaviors._Object noattr));
   Econst_int Int.zero tint;
   Econst_single (Float32.of_bits (Int.repr 1114636288)) tfloat;
   Econst_float (Float.of_bits (Int64.repr 4636737291354636288)) tdouble].

Theorem tbu_generated_cuts_exact : forall version,
  fn_body (tbu_bobomb_function version) =
    Ssequence (tbu_radius_prefix version)
      (Sifthenelse (Etempvar us_obj_behaviors._t'1 tschar)
        (tbu_active_branch version) Sskip) /\
  ibk_normal (tbu_radius_prefix version) = true /\
  tbu_active_branch version = Ssequence (tbu_dispatch version) (tbu_after_dispatch version) /\
  tbu_dispatch version =
    Ssequence (Sset us_obj_behaviors._t'13
      (Evar us_obj_behaviors._gCurrentObject (tptr (Tstruct us_obj_behaviors._Object noattr))))
      (Ssequence (Sset us_obj_behaviors._t'14 (tbu_held_read version))
        (Sswitch (Etempvar us_obj_behaviors._t'14 tuint) (tbu_cases version))) /\
  fn_body (tbu_held_function version) =
    ocn_prepend (tbu_follow_prefix version)
      (Ssequence (tbu_follow_block version) (tbu_after_follow version)) /\
  forallb ibk_normal (tbu_follow_prefix version) = true /\
  tbu_follow_block version =
    Ssequence (Sset us_obj_behaviors._t'8
      (Evar us_obj_behaviors._gMarioObject (tptr (Tstruct us_obj_behaviors._Object noattr))))
      tbu_follow_call /\
  ibk_normal (tbu_follow_block version) = true.
Proof. intros []; repeat split; reflexivity. Qed.

(** Resolve the actual selected-program held behavior; a call-name receipt
    alone would not identify the function that really executes. *)
Lemma tbu_us_held_source :
  nth_error us_obj_behaviors.global_definitions
    (ueqr_definition_index us_obj_behaviors._bobomb_held_loop us_obj_behaviors.global_definitions) =
  Some (us_obj_behaviors._bobomb_held_loop, Gfun (Internal (tbu_held_function VersionUS))).
Proof. vm_compute; reflexivity. Qed.
Lemma tbu_us_held_member :
  In (us_obj_behaviors._bobomb_held_loop, Gfun (Internal (tbu_held_function VersionUS)))
    (unit_global_definitions us_units).
Proof.
  eapply source_unit_definition_enters_source_union with (unit := us_nlist_at 23 us_units).
  - exact (us_nlist_at_nIn _ 23 us_units).
  - change (In (us_obj_behaviors._bobomb_held_loop,
      Gfun (Internal (tbu_held_function VersionUS))) us_obj_behaviors.global_definitions).
    eapply nth_error_In. exact tbu_us_held_source.
Qed.
Lemma tbu_us_held_selection :
  us_normalized_global_definition_map ! us_obj_behaviors._bobomb_held_loop =
    Some (Gfun (Internal (tbu_held_function VersionUS))).
Proof.
  eapply (checked_internal_selection_is_exact
    (unit_global_definitions us_units) us_normalized_global_definition_map).
  - exact us_internal_identifiers_are_unique_checked.
  - exact us_all_internal_identifiers_selected_checked.
  - exact (normalized_definition_map_has_source_provenance (unit_global_definitions us_units)).
  - exact tbu_us_held_member.
Qed.
Local Opaque normalize_global_definition_map.
Lemma tbu_us_held_selected_member :
  In (us_obj_behaviors._bobomb_held_loop, Gfun (Internal (tbu_held_function VersionUS)))
    us_viewport_repaired_global_definitions.
Proof.
  unfold us_viewport_repaired_global_definitions. apply fixed_point_enters_mapped_list.
  - unfold repair_us_selected_global_definition.
    assert (us_selected_definition_needs_viewport_repair
      (us_obj_behaviors._bobomb_held_loop, Gfun (Internal (tbu_held_function VersionUS))) = false)
      as Hrepair by (vm_compute; reflexivity).
    rewrite Hrepair. reflexivity.
  - apply every_selected_internal_body_is_preserved_verbatim. exact tbu_us_held_selection.
Qed.
Theorem tbu_selected_held_behavior_resolves : forall version, exists b,
  Genv.find_symbol (Clight.globalenv (selected_clight_target version))
    us_obj_behaviors._bobomb_held_loop = Some b /\
  Genv.find_funct_ptr (Clight.globalenv (selected_clight_target version)) b =
    Some (Internal (tbu_held_function version)).
Proof.
  intros [].
  - eapply program_definitions_resolve_internal_globalenv.
    + exact us_viewport_repaired_program_definitions_checked.
    + exact us_viewport_repaired_definition_names_norepet.
    + exact tbu_us_held_selected_member.
  - eapply (official_link_resolves_internal_globalenv jp_cleaned_units
      jp_official_cleaned_slice jp_cleaned_units_official_link (nlist_at 23 jp_cleaned_units)).
    + exact (nlist_at_nIn _ 23 jp_cleaned_units).
    + vm_compute; reflexivity.
Qed.

Lemma tbu_reached_call_uses_real_held_body : forall version e le m t last after out,
  e ! us_obj_behaviors._bobomb_held_loop = None ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le m
    tbu_held_call t last after out ->
  exists result, ClightBigstep.Clight2.eval_funcall
    (Clight.globalenv (selected_clight_target version)) m
    (Internal (tbu_held_function version)) [] t after result /\
    last = le /\ out = Out_normal.
Proof.
  intros version e le m t last after out Hlocal Hrun.
  destruct (tbu_selected_held_behavior_resolves version) as (b & Hsymbol & Hfunction).
  inversion Hrun; subst.
  match goal with Hclass : classify_fun _ = _ |- _ =>
    cbn in Hclass; inversion Hclass; subst end.
  match goal with Hexpr : eval_expr _ _ _ _ (Evar _ (Tfunction _ _ _)) ?vf |- _ =>
    assert (vf = Vptr b Ptrofs.zero) by (eapply sce_function_name_value; eauto);
    subst vf end.
  match goal with Hfind : Genv.find_funct _ (Vptr _ _) = Some ?fd |- _ =>
    change (Genv.find_funct_ptr (Clight.globalenv (selected_clight_target version)) b = Some fd)
      in Hfind; rewrite Hfunction in Hfind; inversion Hfind; subst fd end.
  match goal with Hargs : eval_exprlist _ _ _ _ [] [] ?args |- _ =>
    inversion Hargs; subst args end. eauto 8.
Qed.

Lemma tbu_held_switch_calls_held : forall version ge e le m t last after out,
  le ! us_obj_behaviors._t'14 = Some (Vint Int.one) ->
  ocn_exec ge e le m (Sswitch (Etempvar us_obj_behaviors._t'14 tuint) (tbu_cases version))
    t last after out ->
  ocn_exec ge e le m tbu_held_call t last after Out_normal.
Proof.
  intros version ge e le m t last after out Hheld Hrun. inversion Hrun; subst.
  match goal with Hexpr : eval_expr _ _ _ _ (Etempvar _ _) ?value |- _ =>
    assert (value = Vint Int.one) by (eapply ocn_temp_value; eauto); subst value end.
  match goal with Harg : sem_switch_arg _ _ = Some ?n |- _ =>
    change (Some 1 = Some n) in Harg; inversion Harg; subst n end.
  match goal with Hcase : ClightBigstep.exec_stmt _ _ _ _ _
    (seq_of_labeled_statement (select_switch 1 (tbu_cases version))) _ _ _ _ |- _ =>
      rewrite (tbu_selected_held_case_exact version) in Hcase end.
  cce_unroll_loop_free_exec.
  all: try match goal with
    Hcall : ClightBigstep.exec_stmt _ _ _ _ _ tbu_held_call _ _ _ ?bad,
    Hbad : ?bad <> Out_normal |- _ =>
      exfalso; apply Hbad; exact (ibk_normal_outcome _ _ _ _ tbu_held_call _ _ _ _ eq_refl Hcall) end.
  all: try match goal with
    Hcall : ClightBigstep.exec_stmt _ _ _ _ _ (Scall _ _ _) _ _ _ ?bad,
    Hbad : ?bad <> Out_normal |- _ =>
      exfalso; apply Hbad; exact (ibk_normal_outcome _ _ _ _ _ _ _ _ _ eq_refl Hcall) end.
  all: unfold Eapp in *; repeat rewrite app_nil_r in *; eassumption.
Qed.

Definition TBUActualDispatchRead : Prop := forall version e le m t last after out,
  e ! us_obj_behaviors._bobomb_held_loop = None ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le m
    (tbu_dispatch version) t last after out ->
  exists object held,
    eval_expr (Clight.globalenv (selected_clight_target version)) e le m
      (Evar us_obj_behaviors._gCurrentObject (tptr (Tstruct us_obj_behaviors._Object noattr))) object /\
    eval_expr (Clight.globalenv (selected_clight_target version)) e
      (PTree.set us_obj_behaviors._t'13 object le) m (tbu_held_read version) held /\
    (held = Vint Int.one -> exists result,
      ClightBigstep.Clight2.eval_funcall (Clight.globalenv (selected_clight_target version)) m
        (Internal (tbu_held_function version)) [] t after result).
Theorem tbu_actual_dispatch_uses_object_held_state : TBUActualDispatchRead.
Proof.
  intros version e le m t last after out Hlocal Hrun.
  destruct (tbu_generated_cuts_exact version) as (_ & _ & _ & Hdispatch & _).
  rewrite Hdispatch in Hrun.
  unfold ocn_exec, ClightBigstep.Clight2.exec_stmt in Hrun.
  cce_unroll_loop_free_exec.
  all: do 2 eexists; split; [eassumption|]; split; [eassumption|]; intro Hheld; subst.
  all: match goal with Hswitch : ClightBigstep.exec_stmt _ _ _ _ _ (Sswitch _ _) _ _ _ _ |- _ =>
    pose proof (tbu_held_switch_calls_held _ _ _ _ _ _ _ _ _ (PTree.gss _ _ _) Hswitch) as Hcall;
    destruct (tbu_reached_call_uses_real_held_body _ _ _ _ _ _ _ _ Hlocal Hcall)
      as (result & Hreal & _); eauto end.
Qed.

Lemma tbu_dispatch_finishes_normally : forall version ge e le m t last after out,
  ocn_exec ge e le m (tbu_dispatch version) t last after out -> out = Out_normal.
Proof.
  intros version ge e le m t last after out Hrun.
  destruct (tbu_generated_cuts_exact version) as (_ & _ & _ & Hdispatch & _).
  rewrite Hdispatch in Hrun.
  unfold ocn_exec, ClightBigstep.Clight2.exec_stmt in Hrun.
  cce_unroll_loop_free_exec.
  all: eapply iar_switch_normal; [|eassumption].
  all: intro selector; destruct version;
    cbv [tbu_cases tbu_dispatch tbu_active_branch tbu_bobomb_function
      us_obj_behaviors.f_bhv_bobomb_loop jp_obj_behaviors.f_bhv_bobomb_loop fn_body
      select_switch select_switch_case select_switch_default
      seq_of_labeled_statement iar_normal_or_break];
    repeat match goal with |- context [if ?test then _ else _] => destruct test end;
    reflexivity.
Qed.

Definition TBUActualActiveDispatch : Prop := forall version ge e le m t last after out,
  ocn_exec ge e le m (tbu_active_branch version) t last after out ->
  exists dispatched memory pre suf, t = pre ++ suf /\
    ocn_exec ge e le m (tbu_dispatch version) pre dispatched memory Out_normal /\
    ocn_exec ge e dispatched memory (tbu_after_dispatch version) suf last after out.
Theorem tbu_actual_active_branch_reaches_dispatch : TBUActualActiveDispatch.
Proof.
  intros version ge e le m t last after out Hrun.
  destruct (tbu_generated_cuts_exact version) as (_ & _ & Hbody & _).
  rewrite Hbody in Hrun.
  eapply tdr_split_normal_execution; [|exact Hrun].
  intros. eapply tbu_dispatch_finishes_normally; eauto.
Qed.

(** The complete scheduled behavior retains the radius check. A hands-free
    object outside that range is not claimed to follow Mario on this update. *)
Definition TBUActualRadiusChoice : Prop := forall version ge e le m t last after out,
  ocn_exec ge e le m (fn_body (tbu_bobomb_function version)) t last after out ->
  exists checked memory chosen pre branch,
    t = pre ++ branch /\
    ocn_exec ge e le m (tbu_radius_prefix version) pre checked memory Out_normal /\
    ocn_test_value ge e checked memory (Etempvar us_obj_behaviors._t'1 tschar) chosen /\
    ocn_exec ge e checked memory (if chosen then tbu_active_branch version else Sskip)
      branch last after out.
Theorem tbu_actual_behavior_has_radius_choice : TBUActualRadiusChoice.
Proof.
  intros version ge e le m t last after out Hrun.
  destruct (tbu_generated_cuts_exact version) as (Hbody & Hnormal & _).
  rewrite Hbody in Hrun.
  destruct (ibk_split_sequence _ _ _ _ _ _ _ _ _ _ Hnormal Hrun)
    as (checked & memory & pre & branch & Htrace & Hpre & Hbranch).
  inversion Hbranch; subst. do 5 eexists; repeat split; try eassumption.
  unfold ocn_test_value; eauto.
Qed.

Definition TBUActualFollowCall : Prop := forall version ge e le m t last after out,
  ocn_exec ge e le m (fn_body (tbu_held_function version)) t last after out ->
  exists prefix_le prefix_m call_le call_m done_le done_m mario pre call_t suf,
    t = pre ++ (call_t ++ suf) /\
    ocn_exec ge e le m (ocn_prepend (tbu_follow_prefix version) Sskip)
      pre prefix_le prefix_m Out_normal /\
    eval_expr ge e prefix_le prefix_m
      (Evar us_obj_behaviors._gMarioObject (tptr (Tstruct us_obj_behaviors._Object noattr))) mario /\
    call_le = PTree.set us_obj_behaviors._t'8 mario prefix_le /\ call_m = prefix_m /\
    ocn_exec ge e call_le call_m tbu_follow_call call_t done_le done_m Out_normal /\
    ocn_exec ge e done_le done_m (tbu_after_follow version) suf last after out.
Theorem tbu_actual_held_body_reaches_relative_position_call : TBUActualFollowCall.
Proof.
  intros version ge e le m t last after out Hrun.
  destruct (tbu_generated_cuts_exact version)
    as (_ & _ & _ & _ & Hbody & Hprefix & Hblock & Hnormal).
  rewrite Hbody in Hrun.
  destruct (ibk_split_prefix _ _ _ _ _ _ _ _ _ _ Hprefix Hrun)
    as (pl & pm & pre & rest & Htrace & Hp & Hr).
  destruct (ibk_split_sequence _ _ _ _ _ _ _ _ _ _ Hnormal Hr)
    as (dl & dm & call_t & suf & Hrest & Hcall & Hsuf).
  rewrite Hblock in Hcall.
  unfold ocn_exec, ClightBigstep.Clight2.exec_stmt in Hcall.
  cce_unroll_loop_free_exec.
  all: do 10 eexists; repeat split; try eassumption; try reflexivity.
  all: subst; reflexivity.
Qed.

Definition TBUActualHeldFuncallBody : Prop := forall version ge m t after result,
  ClightBigstep.Clight2.eval_funcall ge m (Internal (tbu_held_function version))
    [] t after result ->
  exists e le last out, ocn_exec ge e le m (fn_body (tbu_held_function version))
    t last after out.
Theorem tbu_actual_held_funcall_exposes_body : TBUActualHeldFuncallBody.
Proof.
  intros version ge m t after result Hcall.
  assert (fn_vars (tbu_held_function version) = []) as Hvars by (destruct version; reflexivity).
  inversion Hcall; subst.
  match goal with Hentry : function_entry2 _ _ _ _ _ _ _ |- _ =>
    inversion Hentry; subst; clear Hentry end.
  match goal with Halloc : alloc_variables _ _ _ _ _ _ |- _ =>
    rewrite Hvars in Halloc; inversion Halloc; subst; clear Halloc end.
  match goal with Hfree : Mem.free_list ?before (blocks_of_env _ empty_env) = Some ?final |- _ =>
    change (Some before = Some final) in Hfree; inversion Hfree; subst end.
  eauto 8.
Qed.

Definition TeleporterBobombUsabilityBoundary : Prop :=
  TBUGeneratedHeldRead /\ TBUActualRadiusChoice /\ TBUActualActiveDispatch /\ TBUActualDispatchRead /\
  TBUActualHeldFuncallBody /\ TBUActualFollowCall.
Theorem teleporter_bobomb_usability_boundary_checked : TeleporterBobombUsabilityBoundary.
Proof.
  split; [exact tbu_generated_held_read_exact|].
  split; [exact tbu_actual_behavior_has_radius_choice|].
  split; [exact tbu_actual_active_branch_reaches_dispatch|].
  split; [exact tbu_actual_dispatch_uses_object_held_state|].
  split; [exact tbu_actual_held_funcall_exposes_body|].
  exact tbu_actual_held_body_reaches_relative_position_call.
Qed.
