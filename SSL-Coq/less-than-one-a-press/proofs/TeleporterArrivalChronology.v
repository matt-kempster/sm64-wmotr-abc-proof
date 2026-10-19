(** The normal-frame interval includes an instant-warp check between ordinary
    warp initialization and the object update. These are cuts in one actual
    generated execution; they do not assert that the intervening calls are
    harmless to the remembered platform. *)
From Coq Require Import List ZArith.
From compcert Require Import AST Clight ClightBigstep Clightdefs Ctypes
  Events Globalenvs Integers Maps Memory Values.
From LessThanOneAPress.Generated Require Import us_level_update jp_level_update.
From LessThanOneAPress.Proofs Require Import GameTypes ObjectContactNecessity
  InkBackwardExecution TeleporterWrongWarpBoundary SelectedClightTarget.
Import ListNotations.
Local Opaque selected_clight_target.

Definition tac_normal_function version := match version with
  | VersionUS => us_level_update.f_play_mode_normal
  | VersionJP => jp_level_update.f_play_mode_normal end.
Definition tac_normal_body version := fn_body (tac_normal_function version).
Definition tac_before_warp version := ocn_prefix_items 1 (tac_normal_body version).
Definition tac_warp_call := Scall None
  (Evar us_level_update._warp_area (Tfunction [] tvoid cc_default)) [].
Definition tac_instant_call := Scall None
  (Evar us_level_update._check_instant_warp (Tfunction [] tvoid cc_default)) [].
Definition tac_timer_statement version :=
  match tww_drop_sequence_prefix 3 (tac_normal_body version) with
  | Ssequence timer _ => timer | _ => Sskip end.
Definition tac_objects_call := Scall None
  (Evar us_level_update._area_update_objects (Tfunction [] tvoid cc_default)) [].
Definition tac_after_objects version :=
  tww_drop_sequence_prefix 5 (tac_normal_body version).

Theorem tac_generated_frame_cut_exact : forall version,
  tac_normal_body version = ocn_prepend (tac_before_warp version)
    (Ssequence tac_warp_call (Ssequence tac_instant_call
      (Ssequence (tac_timer_statement version)
        (Ssequence tac_objects_call (tac_after_objects version))))) /\
  forallb ibk_normal (tac_before_warp version) = true /\
  ibk_normal (tac_timer_statement version) = true.
Proof. intros []; repeat split; reflexivity. Qed.

Definition TACNormalFrameChronology : Prop :=
  forall version e le m trace last after out,
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le m
    (tac_normal_body version) trace last after out ->
  exists warp_le warp_m instant_le instant_m timer_le timer_m
    objects_le objects_m done_le done_m pre warp_t instant_t timer_t objects_t suf,
    trace = pre ++ (warp_t ++ (instant_t ++ (timer_t ++ (objects_t ++ suf)))) /\
    ocn_exec (Clight.globalenv (selected_clight_target version)) e le m
      (ocn_prepend (tac_before_warp version) Sskip) pre warp_le warp_m Out_normal /\
    ocn_exec (Clight.globalenv (selected_clight_target version)) e warp_le warp_m
      tac_warp_call warp_t instant_le instant_m Out_normal /\
    ocn_exec (Clight.globalenv (selected_clight_target version)) e instant_le instant_m
      tac_instant_call instant_t timer_le timer_m Out_normal /\
    ocn_exec (Clight.globalenv (selected_clight_target version)) e timer_le timer_m
      (tac_timer_statement version) timer_t objects_le objects_m Out_normal /\
    ocn_exec (Clight.globalenv (selected_clight_target version)) e objects_le objects_m
      tac_objects_call objects_t done_le done_m Out_normal /\
    ocn_exec (Clight.globalenv (selected_clight_target version)) e done_le done_m
      (tac_after_objects version) suf last after out.

Theorem tac_completed_normal_frame_has_connected_warp_object_calls :
  TACNormalFrameChronology.
Proof.
  unfold TACNormalFrameChronology.
  intros version e le m trace last after out Hrun.
  destruct (tac_generated_frame_cut_exact version) as (Hbody & Hnormal & Htimer).
  rewrite Hbody in Hrun.
  destruct (ibk_split_prefix _ _ _ _ _ _ _ _ _ _ Hnormal Hrun)
    as (wl & wm & pre & rest & Htrace & Hpre & Hrest).
  destruct (ibk_split_sequence _ _ _ _ tac_warp_call _ _ _ _ _ eq_refl Hrest)
    as (il & im & wt & rest2 & Htr2 & Hwarp & Hrest2).
  destruct (ibk_split_sequence _ _ _ _ tac_instant_call _ _ _ _ _ eq_refl Hrest2)
    as (tl & tm & it & rest3 & Htr3 & Hinstant & Hrest3).
  destruct (ibk_split_sequence _ _ _ _ _ _ _ _ _ _ Htimer Hrest3)
    as (ol & om & tt & rest4 & Htr4 & Htimer_run & Hrest4).
  destruct (ibk_split_sequence _ _ _ _ tac_objects_call _ _ _ _ _ eq_refl Hrest4)
    as (dl & dm & ot & suf & Htr5 & Hobjects & Hsuf).
  exists wl, wm, il, im, tl, tm, ol, om, dl, dm,
    pre, wt, it, tt, ot, suf.
  split; [subst; reflexivity|].
  repeat split; assumption.
Qed.

(** A concrete load, in the same cell, is transported across this actual
    interval only when each of the two reached segments preserves it.
    The middle segment is the real instant-warp call, not an omitted gap.
    This composition is a residual specification, not a proof of its frames. *)
Definition TACReachedIntervalCellFrames : Prop :=
  forall version e le m trace last after out pb offset chunk value,
  Mem.load chunk m pb offset = Some value ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le m
    (Ssequence tac_instant_call (tac_timer_statement version))
    trace last after out ->
  (forall first_t middle first,
    ocn_exec (Clight.globalenv (selected_clight_target version)) e le m
      tac_instant_call first_t middle first Out_normal ->
    Mem.load chunk first pb offset = Mem.load chunk m pb offset) ->
  (forall first_t middle first second_t,
    ocn_exec (Clight.globalenv (selected_clight_target version)) e le m
      tac_instant_call first_t middle first Out_normal ->
    ocn_exec (Clight.globalenv (selected_clight_target version)) e middle first
      (tac_timer_statement version) second_t last after out ->
    Mem.load chunk after pb offset = Mem.load chunk first pb offset) ->
  Mem.load chunk after pb offset = Some value.
Theorem tac_instant_and_timer_cell_frame_composes : TACReachedIntervalCellFrames.
Proof.
  unfold TACReachedIntervalCellFrames.
  intros version e le m trace last after out pb offset chunk value
    Hload Hrun Hinstant Htimer.
  destruct (ibk_split_sequence _ _ _ _ tac_instant_call _ _ _ _ _ eq_refl Hrun)
    as (middle & first & first_t & second_t & Htrace & Hfirst & Hsecond).
  rewrite (Htimer first_t middle first second_t Hfirst Hsecond).
  rewrite (Hinstant first_t middle first Hfirst). exact Hload.
Qed.

Definition TACActualNormalCallBody : Prop :=
  forall version before trace after result,
  ClightBigstep.Clight2.eval_funcall
    (Clight.globalenv (selected_clight_target version)) before
    (Internal (tac_normal_function version)) [] trace after result ->
  exists le last out,
    ocn_exec (Clight.globalenv (selected_clight_target version)) empty_env le before
      (tac_normal_body version) trace last after out.
Theorem tac_actual_normal_call_supplies_connected_body : TACActualNormalCallBody.
Proof.
  intros version before trace after result Hcall.
  assert (fn_vars (tac_normal_function version) = []) as Hvars
    by (destruct version; reflexivity).
  inversion Hcall; subst.
  match goal with Hentry : function_entry2 _ _ _ _ _ _ _ |- _ =>
    inversion Hentry; subst; clear Hentry end.
  match goal with Halloc : alloc_variables _ _ _ _ _ _ |- _ =>
    rewrite Hvars in Halloc; inversion Halloc; subst; clear Halloc end.
  match goal with Hfree : Mem.free_list ?m (blocks_of_env _ empty_env) = Some ?m' |- _ =>
    change (Some m = Some m') in Hfree; inversion Hfree; subst end.
  do 3 eexists. eassumption.
Qed.

Definition TeleporterArrivalChronologyBoundary : Prop :=
  TACNormalFrameChronology /\ TACReachedIntervalCellFrames /\ TACActualNormalCallBody.
Theorem teleporter_arrival_chronology_boundary_checked :
  TeleporterArrivalChronologyBoundary.
Proof.
  split; [exact tac_completed_normal_frame_has_connected_warp_object_calls|].
  split; [exact tac_instant_and_timer_cell_frame_composes|].
  exact tac_actual_normal_call_supplies_connected_body.
Qed.
