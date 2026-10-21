(** Rank 10A: exact generated gravity and the post-bounce AIR_STEP_NONE
    continuation.  The four collision quarters and the surrounding helper
    calls are NOT replaced by a motion-model assumption here.  Their live
    projection, and iteration from a controller-reachable launch, remain open.

    Motivated by upstream 3f12cca: a lower bound of -75 is insufficient;
    the final velocity must be the result of the actual clamp decision. *)
From Coq Require Import Bool Lia List ZArith.
From compcert Require Import AST Clight ClightBigstep Clightdefs Cop Coqlib
  Ctypes Events Floats Globalenvs Integers Maps Memory Values.
From LessThanOneAPress.Generated Require Import us_mario_step jp_mario_step.
From LessThanOneAPress.Proofs Require Import Area2SlideKickEntry
  Area2SlideKickGravityCore Area2SlideKickEnvelope Area2SlideKickInitializer Area2Rank9ACoinFlight
  Area2Rank11LivePoleExit Area2Rank11PoleExitSplit Area2Rank12BContact
  EyerokRank15LiveMovement InkBackwardSource ObjectContactNecessity
  InkCopyCaller UpperElevatorQueryResolution CleanedClightPrograms
  ClightLinkExecution GlobalInterfaceStructural JPSourceSymbolTransport
  JPWarpLevelEntryResolution LinkedClightPrograms NormalizedClightPrograms
  SuccessfulMakeProgramResolution USViewportRepairedNamesNorepet
  USViewportRepairedProgramSelection USWarpLevelRepairReceipt
  USWarpLevelSourceUnionReceipt USWholeASTTagRepair
  GameTypes SelectedClightTarget.
Import ListNotations.
Local Open Scope Z_scope.
Theorem skp_us_jp_shared_code :
  ske_body VersionUS = ske_body VersionJP /\
  us_mario_actions_airborne.f_update_air_without_turn =
    jp_mario_actions_airborne.f_update_air_without_turn /\
  us_mario_step.f_perform_air_step = jp_mario_step.f_perform_air_step /\
  skp_body VersionUS = skp_body VersionJP.
Proof. repeat split; reflexivity. Qed.

Theorem skp_timer_wrap_checked :
  ske_next_timer (Int.repr 65535) = Int.zero /\
  ske_late (ske_next_timer (Int.repr 65535)) = false.
Proof. vm_compute; split; reflexivity. Qed.
Lemma skp_us_source :
  nth_error SKP.global_definitions
    (ueqr_definition_index SKP._apply_gravity SKP.global_definitions) =
  Some (SKP._apply_gravity, Gfun (Internal (skp_body VersionUS))).
Proof. vm_compute; reflexivity. Qed.
Lemma skp_us_member :
  In (SKP._apply_gravity, Gfun (Internal (skp_body VersionUS)))
    (unit_global_definitions us_units).
Proof.
  eapply source_unit_definition_enters_source_union with (unit := us_nlist_at 9 us_units).
  - exact (us_nlist_at_nIn _ 9 us_units).
  - eapply nth_error_In. exact skp_us_source.
Qed.
Lemma skp_us_selection :
  us_normalized_global_definition_map ! SKP._apply_gravity =
    Some (Gfun (Internal (skp_body VersionUS))).
Proof.
  eapply (checked_internal_selection_is_exact
    (unit_global_definitions us_units) us_normalized_global_definition_map).
  - exact us_internal_identifiers_are_unique_checked.
  - exact us_all_internal_identifiers_selected_checked.
  - exact (normalized_definition_map_has_source_provenance (unit_global_definitions us_units)).
  - exact skp_us_member.
Qed.
Lemma skp_us_selected :
  In (SKP._apply_gravity, Gfun (Internal (skp_body VersionUS)))
    us_viewport_repaired_global_definitions.
Proof.
  unfold us_viewport_repaired_global_definitions. apply fixed_point_enters_mapped_list.
  - reflexivity.
  - apply every_selected_internal_body_is_preserved_verbatim. exact skp_us_selection.
Qed.
Lemma skp_jp_source :
  (prog_defmap (nlist_at 9 jp_cleaned_units)) ! SKP._apply_gravity =
    Some (Gfun (Internal (skp_body VersionJP))).
Proof. vm_compute; reflexivity. Qed.
Theorem skp_selected_gravity_resolves : forall version, exists b,
  Genv.find_symbol (Clight.globalenv (selected_clight_target version)) SKP._apply_gravity = Some b /\
  Genv.find_funct_ptr (Clight.globalenv (selected_clight_target version)) b =
    Some (Internal (skp_body version)).
Proof.
  intros [].
  - eapply program_definitions_resolve_internal_globalenv.
    + exact us_viewport_repaired_program_definitions_checked.
    + exact us_viewport_repaired_definition_names_norepet.
    + exact skp_us_selected.
  - eapply (official_link_resolves_internal_globalenv jp_cleaned_units
      jp_official_cleaned_slice jp_cleaned_units_official_link (nlist_at 9 jp_cleaned_units)).
    + exact (nlist_at_nIn _ 9 jp_cleaned_units).
    + exact skp_jp_source.
Qed.

Lemma skp_selected_layout : forall version,
  SKPLayout (Clight.globalenv (selected_clight_target version)).
Proof.
  intro version. split.
  - apply (rank11_selected_mario_field version). cbn; auto.
  - apply (ski_field_layout version). cbn; auto.
Qed.
Theorem skp_exact_gravity_call : forall version m mario v,
  Mem.load Mint32 m mario 12 = Some (Vint skp_action) ->
  Mem.load Mfloat32 m mario 76 = Some (Vsingle v) ->
  Mem.valid_access m Mfloat32 mario 76 Writable ->
  exists after,
    ClightBigstep.Clight2.eval_funcall (Clight.globalenv (selected_clight_target version)) m
      (Internal (skp_body version)) [Vptr mario Ptrofs.zero] E0 after Vundef /\
    Mem.load Mfloat32 after mario 76 = Some (Vsingle (skp_gravity v)) /\
    (forall chunk b offset, SKPOutsideVelocity mario chunk b offset ->
      Mem.load chunk after b offset = Mem.load chunk m b offset).
Proof. intros. eapply skp_exact_gravity_call_in; eauto using skp_selected_layout. Qed.

(** Both sample families already check binary32 subtraction and the clamp
    comparison.  Reuse those checks to connect an execution to sk_next. *)
Lemma skp_sample_velocity_exact : forall s,
  sk_sample_exact s = true -> sk_bounced s = true ->
  skp_gravity (sk_float8 (sk_velocity8 s)) = sk_float8 (sk_velocity8 (sk_next s)).
Proof.
  intros s Hex Hb. unfold sk_sample_exact in Hex.
  repeat rewrite andb_true_iff in Hex.
  destruct Hex as (((((((Hfloor & Hgap) & Hhigh) & Htimer) & Hquarters) & Hsub) & Hcmp) & Hbounce).
  unfold sk_bits_equal in Hsub. apply Int.same_if_eq in Hsub.
  apply rank9cf_bits_injective in Hsub.
  apply Bool.eqb_prop in Hcmp.
  assert (Htwo : skp_two = rank9cf_integer 2) by (apply rank9cf_bits_injective; vm_compute; reflexivity).
  assert (Hminus : skp_minus75 = rank9cf_integer (-75)) by (apply rank9cf_bits_injective; vm_compute; reflexivity).
  unfold skp_gravity, skp_clamp, skp_raw. rewrite Htwo, Hminus, Hsub, Hcmp.
  unfold sk_next. destruct (sk_quarters 4 (sk_y8 s) (sk_next_floor s) (sk_velocity8 s)) as [y landed].
  rewrite Hb. destruct landed; cbn [negb andb sk_velocity8];
    destruct (sk_velocity8 s - 16 <? -600) eqn:Hlt.
  all: try (apply Z.ltb_lt in Hlt; rewrite Z.max_r by lia;
    apply rank9cf_bits_injective; vm_compute; reflexivity).
  all: apply Z.ltb_ge in Hlt; rewrite Z.max_l by lia; reflexivity.
Qed.

Theorem skp_post_bounce_call_matches_model : forall version m mario s state,
  sk_sample_exact s = true -> sk_bounced s = true ->
  Mem.load Mint32 m mario 12 = Some (Vint ski_action) ->
  Mem.load Mint16unsigned m mario 24 = Some (Vint state) ->
  Int.eq state Int.zero = false ->
  Mem.load Mfloat32 m mario 76 = Some (Vsingle (sk_float8 (sk_velocity8 s))) ->
  Mem.valid_access m Mfloat32 mario 76 Writable ->
  exists after,
    ClightBigstep.Clight2.eval_funcall (Clight.globalenv (selected_clight_target version)) m
      (Internal (skp_body version)) [Vptr mario Ptrofs.zero] E0 after Vundef /\
    Mem.load Mfloat32 after mario 76 = Some (Vsingle (sk_float8 (sk_velocity8 (sk_next s)))) /\
    Mem.load Mint16unsigned after mario 24 = Some (Vint state) /\
    (forall chunk b offset, SKPOutsideVelocity mario chunk b offset ->
      Mem.load chunk after b offset = Mem.load chunk m b offset).
Proof.
  intros version m mario s state Hex Hb Ha Hstate Hnonzero Hv Haccess.
  destruct (skp_exact_gravity_call version m mario _ Ha Hv Haccess)
    as (after & Hcall & Hload & Hframe).
  exists after. split; [exact Hcall|]. split.
  - rewrite (skp_sample_velocity_exact s Hex Hb) in Hload. exact Hload.
  - split; [|exact Hframe]. rewrite Hframe; [exact Hstate|unfold SKPOutsideVelocity; right; left; cbn; lia].
Qed.

Definition skp_switch version := match
  ibk_head (rank12b_drop_sequences 3 (fn_body (ske_body version))) with
| Ssequence _ dispatch => dispatch | _ => Sskip end.
Definition skp_cases version := match skp_switch version with
| Sswitch _ cases => cases | _ => LSnil end.
Definition skp_after_air version := Ssequence (skp_switch version)
  (rank12b_drop_sequences 4 (fn_body (ske_body version))).
Definition skp_state := rank11_mario_field_expression SK._actionState tushort.

Lemma skp_post_air_source : forall version,
  skp_switch version = Sswitch (Etempvar SK._t'5 tint) (skp_cases version) /\
  rank12b_drop_sequences 4 (fn_body (ske_body version)) =
    Sreturn (Some (Econst_int Int.zero tint)) /\
  exists angle rest,
    seq_of_labeled_statement (select_switch 0 (skp_cases version)) =
    Ssequence (Ssequence
      (Ssequence (Sset SK._t'13 skp_state)
        (Sifthenelse (Ebinop Oeq (Etempvar SK._t'13 tushort)
          (Econst_int Int.zero tint) tint) angle Sskip)) Sbreak) rest.
Proof. intros []; repeat split; try reflexivity; do 2 eexists; reflexivity. Qed.

Lemma skp_state_read : forall version e le m mario state,
  le ! SK._m = Some (Vptr mario Ptrofs.zero) ->
  Mem.load Mint16unsigned m mario 24 = Some (Vint state) ->
  eval_expr (Clight.globalenv (selected_clight_target version)) e le m skp_state (Vint state).
Proof.
  intros version e le m mario state Hm Hstate.
  assert (Hlayout : ibcc_field_ok (prog_comp_env (selected_clight_target version))
    SK._MarioState SK._actionState 24 = true).
  { rewrite <- rank15_selected_header_environment_exact. destruct version; vm_compute; reflexivity. }
  destruct (ibcc_field_ok_sound _ _ _ _ Hlayout) as (co & Hco & Hoff).
  eapply eval_Elvalue with (loc := mario) (ofs := Ptrofs.add Ptrofs.zero (Ptrofs.repr 24)) (bf := Full).
  - unfold skp_state, rank11_mario_field_expression.
    eapply eval_Efield_struct with (co := co).
    + eapply eval_Elvalue; [apply eval_Ederef; apply eval_Etempvar; exact Hm|].
      apply deref_loc_copy. reflexivity.
    + reflexivity.
    + exact Hco.
    + exact Hoff.
  - eapply deref_loc_value with (chunk := Mint16unsigned); [reflexivity|exact Hstate].
Qed.

(** This is the actual remainder of act_slide_kick after its air-step call.
    AIR_STEP_NONE and nonzero actionState skip the pre-bounce angle code;
    the remainder returns FALSE and performs no store or further call. *)
Theorem skp_post_bounce_no_collision_suffix : forall version e le m mario state,
  le ! SK._m = Some (Vptr mario Ptrofs.zero) ->
  le ! SK._t'5 = Some (Vint Int.zero) ->
  Mem.load Mint16unsigned m mario 24 = Some (Vint state) ->
  Int.eq state Int.zero = false ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le m
    (skp_after_air version) E0 (PTree.set SK._t'13 (Vint state) le) m
    (Out_return (Some (Vint Int.zero, tint))).
Proof.
  intros version e le m mario state Hm Hresult Hstate Hnonzero.
  destruct (skp_post_air_source version) as (Hswitch & Hreturn & angle & rest & Hcase).
  unfold skp_after_air. rewrite Hswitch, Hreturn.
  eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
  - eapply exec_Sswitch with (v := Vint Int.zero) (n := 0) (out := Out_break).
    + apply eval_Etempvar. exact Hresult.
    + reflexivity.
    + rewrite Hcase. eapply exec_Sseq_2; [|discriminate].
      eapply exec_Sseq_1 with (t1 := E0) (t2 := E0); [|constructor].
      eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
      * apply exec_Sset. eapply skp_state_read; eauto.
      * eapply exec_Sifthenelse with (v1 := Vint Int.zero) (b := false).
        -- eapply eval_Ebinop; [apply eval_Etempvar; apply PTree.gss|constructor|].
           change (Some (Val.of_bool (Int.eq state Int.zero)) = Some (Vint Int.zero)).
           rewrite Hnonzero. reflexivity.
        -- reflexivity.
        -- constructor.
  - apply exec_Sreturn_some. constructor.
Qed.

Definition SlideKickPostBounceBoundary : Prop :=
  (forall version, exists b,
    Genv.find_symbol (Clight.globalenv (selected_clight_target version)) SKP._apply_gravity = Some b /\
    Genv.find_funct_ptr (Clight.globalenv (selected_clight_target version)) b =
      Some (Internal (skp_body version))) /\
  (forall version m mario v,
    Mem.load Mint32 m mario 12 = Some (Vint ski_action) ->
    Mem.load Mfloat32 m mario 76 = Some (Vsingle v) ->
    Mem.valid_access m Mfloat32 mario 76 Writable ->
    exists after,
      ClightBigstep.Clight2.eval_funcall (Clight.globalenv (selected_clight_target version)) m
        (Internal (skp_body version)) [Vptr mario Ptrofs.zero] E0 after Vundef /\
      Mem.load Mfloat32 after mario 76 = Some (Vsingle (skp_gravity v)) /\
      (forall chunk b offset, SKPOutsideVelocity mario chunk b offset ->
        Mem.load chunk after b offset = Mem.load chunk m b offset)) /\
  (forall version m mario s state,
    sk_sample_exact s = true -> sk_bounced s = true ->
    Mem.load Mint32 m mario 12 = Some (Vint ski_action) ->
    Mem.load Mint16unsigned m mario 24 = Some (Vint state) ->
    Int.eq state Int.zero = false ->
    Mem.load Mfloat32 m mario 76 = Some (Vsingle (sk_float8 (sk_velocity8 s))) ->
    Mem.valid_access m Mfloat32 mario 76 Writable ->
    exists after,
      ClightBigstep.Clight2.eval_funcall (Clight.globalenv (selected_clight_target version)) m
        (Internal (skp_body version)) [Vptr mario Ptrofs.zero] E0 after Vundef /\
      Mem.load Mfloat32 after mario 76 = Some (Vsingle (sk_float8 (sk_velocity8 (sk_next s)))) /\
      Mem.load Mint16unsigned after mario 24 = Some (Vint state) /\
      (forall chunk b offset, SKPOutsideVelocity mario chunk b offset ->
        Mem.load chunk after b offset = Mem.load chunk m b offset)) /\
  (forall version e le m mario state,
    le ! SK._m = Some (Vptr mario Ptrofs.zero) ->
    le ! SK._t'5 = Some (Vint Int.zero) ->
    Mem.load Mint16unsigned m mario 24 = Some (Vint state) ->
    Int.eq state Int.zero = false ->
    ocn_exec (Clight.globalenv (selected_clight_target version)) e le m
      (skp_after_air version) E0 (PTree.set SK._t'13 (Vint state) le) m
      (Out_return (Some (Vint Int.zero, tint)))).

Theorem skp_post_bounce_boundary_checked : SlideKickPostBounceBoundary.
Proof.
  split; [exact skp_selected_gravity_resolves|].
  split; [exact skp_exact_gravity_call|].
  split; [exact skp_post_bounce_call_matches_model|exact skp_post_bounce_no_collision_suffix].
Qed.
