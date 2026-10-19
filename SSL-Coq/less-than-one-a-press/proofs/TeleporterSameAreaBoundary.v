(** Same-area initialization does not execute the area-load reset.

    This certificate constructs a call-free, store-free path through the
    actual generated US/JP load choice when sWarpDest.type is 3.  It then
    proves that every execution of that statement preserves memory.  This
    is a local source boundary: neither the preceding warp prefix nor the
    subsequent init_mario and object updates are replaced by this path. *)
From Coq Require Import Bool List ZArith.
From compcert Require Import AST Clight ClightBigstep Clightdefs Cop Ctypes
  Events Globalenvs Integers Maps Memory Values.
From LessThanOneAPress.Generated Require Import
  us_level_update jp_level_update us_platform_displacement jp_platform_displacement.
From LessThanOneAPress.Proofs Require Import GameTypes ObjectContactNecessity
  TeleporterDestinationReset TeleporterWrongWarpBoundary ReadOnlyClightPaths
  InkCopyCaller EyerokRank15LiveMovement SelectedClightTarget.
Import ListNotations.
Local Open Scope Z_scope.

Definition tsa_type_read := Efield
  (Evar us_level_update._sWarpDest (Tstruct us_level_update._WarpDest noattr))
  us_level_update._type tuchar.
Definition tsa_type_temp version := match version with
  | VersionUS => us_level_update._t'45
  | VersionJP => jp_level_update._t'29 end.
Definition tsa_second_type_temp version := match version with
  | VersionUS => us_level_update._t'46
  | VersionJP => jp_level_update._t'30 end.
Definition tsa_same_area_locals version le :=
  PTree.set us_level_update._t'3 (Vint Int.zero)
    (PTree.set (tsa_second_type_temp version) (Vint (Int.repr 3))
      (PTree.set (tsa_type_temp version) (Vint (Int.repr 3)) le)).

(** The full guard, including both reads, is extracted from the generated
    initializer.  In particular, 1 and 2 load an area; the same-area byte
    is 3.  Equality here rules out an extraction fallback to Sskip. *)
Theorem tsa_generated_load_choice_exact : forall version,
  tdr_load_choice version =
    Ssequence
      (Ssequence (Sset (tsa_type_temp version) tsa_type_read)
        (Sifthenelse
          (Ebinop Oeq (Etempvar (tsa_type_temp version) tuchar)
            (Econst_int (Int.repr 1) tint) tint)
          (Sset us_level_update._t'3 (Econst_int (Int.repr 1) tint))
          (Ssequence (Sset (tsa_second_type_temp version) tsa_type_read)
            (Sset us_level_update._t'3
              (Ecast
                (Ebinop Oeq (Etempvar (tsa_second_type_temp version) tuchar)
                  (Econst_int (Int.repr 2) tint) tint) tbool)))))
      (Sifthenelse tdr_load_guard (tdr_load_effects version) Sskip).
Proof. intros []; reflexivity. Qed.

Lemma tsa_selected_type_layout : forall version,
  ibcc_field_ok (Clight.globalenv (selected_clight_target version))
    us_level_update._WarpDest us_level_update._type 0 = true.
Proof.
  intro version.
  change (ibcc_field_ok (prog_comp_env (selected_clight_target version))
    us_level_update._WarpDest us_level_update._type 0 = true).
  rewrite <- rank15_selected_header_environment_exact.
  destruct version; vm_compute; reflexivity.
Qed.

Lemma tsa_actual_type_read : forall version e le m warp_cell byte,
  e ! us_level_update._sWarpDest = None ->
  Genv.find_symbol (Clight.globalenv (selected_clight_target version))
    us_level_update._sWarpDest = Some warp_cell ->
  Mem.load Mint8unsigned m warp_cell 0 = Some (Vint byte) ->
  eval_expr (Clight.globalenv (selected_clight_target version))
    e le m tsa_type_read (Vint byte).
Proof.
  intros version e le m wb byte Hlocal Hsymbol Hload.
  destruct (ibcc_field_ok_sound _ _ _ _ (tsa_selected_type_layout version))
    as (co & Hco & Hoff).
  unfold tsa_type_read.
  eapply eval_Elvalue with (ofs := Ptrofs.zero) (bf := Full).
  - replace Ptrofs.zero with (Ptrofs.add Ptrofs.zero (Ptrofs.repr 0))
      by reflexivity.
    eapply eval_Efield_struct with (co := co).
    + eapply eval_Elvalue with (ofs := Ptrofs.zero) (bf := Full).
      * eapply eval_Evar_global; eauto.
      * apply deref_loc_copy. reflexivity.
    + reflexivity.
    + exact Hco.
    + exact Hoff.
  - eapply deref_loc_value with (chunk := Mint8unsigned); eauto.
Qed.

(** This constructs a real terminating execution path from byte loads;
    no completed execution, callee effect, or null platform is assumed. *)
Theorem tsa_same_area_load_choice_is_readonly :
  forall version e le m warp_cell,
  e ! us_level_update._sWarpDest = None ->
  Genv.find_symbol (Clight.globalenv (selected_clight_target version))
    us_level_update._sWarpDest = Some warp_cell ->
  Mem.load Mint8unsigned m warp_cell 0 = Some (Vint (Int.repr 3)) ->
  readonly_path (Clight.globalenv (selected_clight_target version)) e m le
    (tdr_load_choice version) (tsa_same_area_locals version le).
Proof.
  intros version e le m wb Hlocal Hsymbol Hload.
  rewrite tsa_generated_load_choice_exact. unfold tsa_same_area_locals.
  eapply ro_seq.
  - eapply ro_seq.
    + apply ro_set. eapply tsa_actual_type_read; eauto.
    + eapply ro_if with (v := Vint Int.zero) (choice := false).
      * eapply eval_Ebinop;
          [apply eval_Etempvar; apply PTree.gss|constructor|reflexivity].
      * reflexivity.
      * eapply ro_seq.
        -- apply ro_set. eapply tsa_actual_type_read; eauto.
        -- apply ro_set. eapply eval_Ecast.
           ++ eapply eval_Ebinop;
                [apply eval_Etempvar; apply PTree.gss|constructor|reflexivity].
           ++ reflexivity.
  - eapply ro_if with (v := Vint Int.zero) (choice := false).
    + unfold tdr_load_guard. apply eval_Etempvar. apply PTree.gss.
    + reflexivity.
    + apply ro_skip.
Qed.

Definition TSASameAreaLoadChoicePreservation : Prop :=
  forall version e le m warp_cell trace last after out,
  e ! us_level_update._sWarpDest = None ->
  Genv.find_symbol (Clight.globalenv (selected_clight_target version))
    us_level_update._sWarpDest = Some warp_cell ->
  Mem.load Mint8unsigned m warp_cell 0 = Some (Vint (Int.repr 3)) ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le m
    (tdr_load_choice version) trace last after out ->
  trace = E0 /\ last = tsa_same_area_locals version le /\
    after = m /\ out = Out_normal.

Definition TSASameAreaLoadChoiceExecutes : Prop :=
  forall version e le m warp_cell,
  e ! us_level_update._sWarpDest = None ->
  Genv.find_symbol (Clight.globalenv (selected_clight_target version))
    us_level_update._sWarpDest = Some warp_cell ->
  Mem.load Mint8unsigned m warp_cell 0 = Some (Vint (Int.repr 3)) ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le m
    (tdr_load_choice version) E0 (tsa_same_area_locals version le) m Out_normal.

Theorem tsa_same_area_load_choice_executes : TSASameAreaLoadChoiceExecutes.
Proof.
  unfold TSASameAreaLoadChoiceExecutes.
  intros. apply readonly_path_executes.
  eapply tsa_same_area_load_choice_is_readonly; eauto.
Qed.

Theorem tsa_same_area_load_choice_preserves_memory : TSASameAreaLoadChoicePreservation.
Proof.
  unfold TSASameAreaLoadChoicePreservation.
  intros version e le m wb trace last after out Hlocal Hsymbol Hload Hrun.
  eapply readonly_path_forces_every_execution; [|exact Hrun].
  eapply tsa_same_area_load_choice_is_readonly; eauto.
Qed.

(** The generated displacement function's first statement samples the
    separate global.  A retained global is not inferred from a cleared
    gMarioObject->platform field. *)
Definition tsa_platform_read := Evar us_platform_displacement._gMarioPlatform
  (tptr (Tstruct us_platform_displacement._Object noattr)).
Definition tsa_platform_sampler := Sset us_platform_displacement._platform tsa_platform_read.
Definition tsa_apply_body version := fn_body (match version with
  | VersionUS => us_platform_displacement.f_apply_mario_platform_displacement
  | VersionJP => jp_platform_displacement.f_apply_mario_platform_displacement end).
Theorem tsa_generated_displacement_samples_global : forall version,
  exists tail, tsa_apply_body version = Ssequence tsa_platform_sampler tail.
Proof. intros []; eexists; reflexivity. Qed.

Lemma tsa_actual_platform_read : forall version e le m platform_cell pointer,
  e ! us_platform_displacement._gMarioPlatform = None ->
  Genv.find_symbol (Clight.globalenv (selected_clight_target version))
    us_platform_displacement._gMarioPlatform = Some platform_cell ->
  Mem.load Mptr m platform_cell 0 = Some pointer ->
  eval_expr (Clight.globalenv (selected_clight_target version)) e le m
    tsa_platform_read pointer.
Proof.
  intros. unfold tsa_platform_read.
  eapply eval_Elvalue with (ofs := Ptrofs.zero) (bf := Full).
  - eapply eval_Evar_global; eauto.
  - eapply deref_loc_value with (chunk := Mptr); eauto.
Qed.

(** Conditional memory-level retention, not gameplay reachability.  A
    nonnull platform supplied at this actual same-area checkpoint survives
    the load choice.  The theorem deliberately stops before init_mario. *)
Definition TSASameAreaPlatformRetention : Prop :=
  forall version e le m warp_cell platform_cell ob ofs trace last after out,
  e ! us_level_update._sWarpDest = None ->
  Genv.find_symbol (Clight.globalenv (selected_clight_target version))
    us_level_update._sWarpDest = Some warp_cell ->
  Mem.load Mint8unsigned m warp_cell 0 = Some (Vint (Int.repr 3)) ->
  e ! us_platform_displacement._gMarioPlatform = None ->
  Genv.find_symbol (Clight.globalenv (selected_clight_target version))
    us_platform_displacement._gMarioPlatform = Some platform_cell ->
  Mem.load Mptr m platform_cell 0 = Some (Vptr ob ofs) ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le m
    (tdr_load_choice version) trace last after out ->
  eval_expr (Clight.globalenv (selected_clight_target version)) e last after
    tsa_platform_read (Vptr ob ofs) /\
  Mem.load Mptr after platform_cell 0 = Some (Vptr ob ofs) /\
    Mem.load Mptr after platform_cell 0 <> Some (Vint Int.zero).
Theorem tsa_same_area_load_choice_retains_nonnull_platform : TSASameAreaPlatformRetention.
Proof.
  unfold TSASameAreaPlatformRetention.
  intros version e le m wb pb ob ofs trace last after out Hl Hs Htype Hpl Hps Hp Hrun.
  destruct (tsa_same_area_load_choice_preserves_memory version e le m wb
    trace last after out Hl Hs Htype Hrun) as (_ & _ & -> & _).
  split; [eapply tsa_actual_platform_read; eauto|].
  split; [exact Hp|rewrite Hp; discriminate].
Qed.

Definition TeleporterSameAreaBoundary : Prop :=
  TSASameAreaLoadChoiceExecutes /\ TSASameAreaLoadChoicePreservation /\
  TSASameAreaPlatformRetention /\
  (forall version, exists tail,
    tsa_apply_body version = Ssequence tsa_platform_sampler tail).
Theorem teleporter_same_area_boundary_checked : TeleporterSameAreaBoundary.
Proof.
  split; [exact tsa_same_area_load_choice_executes|].
  split; [exact tsa_same_area_load_choice_preserves_memory|].
  split; [exact tsa_same_area_load_choice_retains_nonnull_platform|].
  exact tsa_generated_displacement_samples_global.
Qed.
