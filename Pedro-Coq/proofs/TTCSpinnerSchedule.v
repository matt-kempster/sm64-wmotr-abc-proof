From Coq Require Import Bool Lia List ZArith.
From compcert Require Import AST Clight Integers.
From Pedro.Generated Require Import
  us_obj_behaviors_2 us_behavior_script
  jp_obj_behaviors_2 jp_behavior_script.
From Pedro.Proofs Require Import ASTFacts GameTypes.

Import ListNotations.
Open Scope Z_scope.

Module USchedule := us_obj_behaviors_2.
Module UBehaviorScript := us_behavior_script.
Module JSchedule := jp_obj_behaviors_2.
Module JBehaviorScript := jp_behavior_script.

(** Syntax receipt for the constants and calls used by the executable schedule
    model.  The final conjunct pins the generic object's saturating timer bound;
    index 51 is [oTimer] after preprocessing the Object raw-data macros. *)
Definition ttc_schedule_source_receipt (version : GameVersion) : Prop :=
  match version with
  | VersionUS =>
      calls_ident_s USchedule._random_sign
        (fn_body USchedule.f_bhv_ttc_spinner_update) = true /\
      calls_ident_s USchedule._random_mod_offset
        (fn_body USchedule.f_bhv_ttc_spinner_update) = true /\
      statement_mentions_int_s 30
        (fn_body USchedule.f_bhv_ttc_spinner_update) = true /\
      statement_mentions_int_s 4
        (fn_body USchedule.f_bhv_ttc_spinner_update) = true /\
      statement_mentions_int_s 5
        (fn_body USchedule.f_bhv_ttc_spinner_update) = true /\
      calls_ident_s USchedule._random_u16
        (fn_body USchedule.f_random_mod_offset) = true /\
      calls_ident_s UBehaviorScript._random_u16
        (fn_body UBehaviorScript.f_random_sign) = true /\
      statement_mentions_int_s 1073741823
        (fn_body UBehaviorScript.f_cur_obj_update) = true /\
      assigns_array_field_index_s UBehaviorScript._asS32 51
        (fn_body UBehaviorScript.f_cur_obj_update) = true
  | VersionJP =>
      calls_ident_s JSchedule._random_sign
        (fn_body JSchedule.f_bhv_ttc_spinner_update) = true /\
      calls_ident_s JSchedule._random_mod_offset
        (fn_body JSchedule.f_bhv_ttc_spinner_update) = true /\
      statement_mentions_int_s 30
        (fn_body JSchedule.f_bhv_ttc_spinner_update) = true /\
      statement_mentions_int_s 4
        (fn_body JSchedule.f_bhv_ttc_spinner_update) = true /\
      statement_mentions_int_s 5
        (fn_body JSchedule.f_bhv_ttc_spinner_update) = true /\
      calls_ident_s JSchedule._random_u16
        (fn_body JSchedule.f_random_mod_offset) = true /\
      calls_ident_s JBehaviorScript._random_u16
        (fn_body JBehaviorScript.f_random_sign) = true /\
      statement_mentions_int_s 1073741823
        (fn_body JBehaviorScript.f_cur_obj_update) = true /\
      assigns_array_field_index_s JBehaviorScript._asS32 51
        (fn_body JBehaviorScript.f_cur_obj_update) = true
  end.

Theorem ttc_schedule_source_receipt_supported :
  forall version, ttc_schedule_source_receipt version.
Proof. intros []; vm_compute; repeat split. Qed.

Record rng_observation := RNGObservation {
  direction_draw : Z;
  timer_draw : Z
}.

Definition direction_from_draw (draw : Z) : Z :=
  if 32767 <=? draw then 1 else -1.

Definition change_timer_from_draw (draw : Z) : Z :=
  30 + 30 * (draw mod 4).

Theorem direction_draw_range :
  forall draw, direction_from_draw draw = -1 \/ direction_from_draw draw = 1.
Proof.
  intro draw; unfold direction_from_draw.
  destruct (32767 <=? draw); auto.
Qed.

Theorem random_change_timer_range :
  forall draw,
    change_timer_from_draw draw = 30 \/
    change_timer_from_draw draw = 60 \/
    change_timer_from_draw draw = 90 \/
    change_timer_from_draw draw = 120.
Proof.
  intro draw.
  unfold change_timer_from_draw.
  pose proof (Z.mod_pos_bound draw 4 ltac:(lia)) as Hmod.
  assert (draw mod 4 = 0 \/ draw mod 4 = 1 \/
          draw mod 4 = 2 \/ draw mod 4 = 3) by lia.
  destruct H as [-> | [-> | [-> | ->]]]; auto.
Qed.

Record spinner_state := SpinnerState {
  face_pitch : Z;
  object_timer : Z;
  change_direction_timer : Z;
  spinner_direction : Z
}.

Definition increment_object_timer (timer : Z) : Z :=
  if timer <? 1073741823 then timer + 1 else timer.

(** One native random-mode update followed by the timer increment performed by
    [cur_obj_update].  On a change frame the C code retains the initial +200
    velocity, even if the newly drawn direction is -1. *)
Definition random_mode_frame
    (state : spinner_state) (draws : rng_observation) : spinner_state :=
  if change_direction_timer state <? object_timer state then
    SpinnerState
      (face_pitch state + 200)
      (increment_object_timer 0)
      (change_timer_from_draw (timer_draw draws))
      (direction_from_draw (direction_draw draws))
  else if 5 <? object_timer state then
    SpinnerState
      (face_pitch state + 200 * spinner_direction state)
      (increment_object_timer (object_timer state))
      (change_direction_timer state)
      (spinner_direction state)
  else
    SpinnerState
      (face_pitch state)
      (increment_object_timer (object_timer state))
      (change_direction_timer state)
      (spinner_direction state).

Fixpoint run_random_mode
    (frames : nat) (state : spinner_state)
    (draws : nat -> rng_observation) : spinner_state :=
  match frames with
  | O => state
  | S remaining =>
      run_random_mode remaining (random_mode_frame state (draws remaining)) draws
  end.

Theorem post_change_stop_window :
  forall pitch change direction draws,
    In change [30; 60; 90; 120] ->
    run_random_mode 5 (SpinnerState pitch 1 change direction) draws =
      SpinnerState pitch 6 change direction.
Proof.
  intros pitch change direction draws Hchange.
  simpl in Hchange.
  destruct Hchange as [H | [H | [H | [H | H]]]]; try contradiction;
    subst change; vm_compute; reflexivity.
Qed.

Theorem first_post_stop_motion :
  forall pitch change direction draws,
    In change [30; 60; 90; 120] ->
    run_random_mode 6 (SpinnerState pitch 1 change direction) draws =
      SpinnerState (pitch + 200 * direction) 7 change direction.
Proof.
  intros pitch change direction draws Hchange.
  simpl in Hchange.
  destruct Hchange as [H | [H | [H | [H | H]]]]; try contradiction;
    subst change; vm_compute; reflexivity.
Qed.

Definition in_certified_pitch_interval (pitch : Z) : Prop :=
  15664 <= pitch <= 16031.

(** Unlike the original 96-unit subinterval, the strengthened certificate can
    contain one controlled 200-unit motion.  This is not yet a complete tap
    schedule: it isolates the geometric/schedule witness that such a schedule
    must arrange. *)
Theorem widened_interval_admits_one_negative_motion :
  forall change draws,
    In change [30; 60; 90; 120] ->
    in_certified_pitch_interval 15864 /\
    in_certified_pitch_interval
      (face_pitch
        (run_random_mode 6 (SpinnerState 15864 1 change (-1)) draws)).
Proof.
  intros change draws Hchange.
  split; [unfold in_certified_pitch_interval; lia|].
  rewrite first_post_stop_motion by exact Hchange.
  unfold in_certified_pitch_interval; simpl; lia.
Qed.

Theorem second_post_stop_motion :
  forall pitch change direction draws,
    In change [30; 60; 90; 120] ->
    run_random_mode 7 (SpinnerState pitch 1 change direction) draws =
      SpinnerState (pitch + 400 * direction) 8 change direction.
Proof.
  intros pitch change direction draws Hchange.
  simpl in Hchange.
  destruct Hchange as [H | [H | [H | [H | H]]]]; try contradiction.
  - subst change.
    change (SpinnerState (pitch + 200 * direction + 200 * direction)
      8 30 direction = SpinnerState (pitch + 400 * direction) 8 30 direction).
    f_equal; lia.
  - subst change.
    change (SpinnerState (pitch + 200 * direction + 200 * direction)
      8 60 direction = SpinnerState (pitch + 400 * direction) 8 60 direction).
    f_equal; lia.
  - subst change.
    change (SpinnerState (pitch + 200 * direction + 200 * direction)
      8 90 direction = SpinnerState (pitch + 400 * direction) 8 90 direction).
    f_equal; lia.
  - subst change.
    change (SpinnerState (pitch + 200 * direction + 200 * direction)
      8 120 direction = SpinnerState (pitch + 400 * direction) 8 120 direction).
    f_equal; lia.
Qed.

(** This is a negative search result, not the requested positive control
    schedule.  It quantifies over every RNG observation, hence over any seed
    changes a dust-tap strategy could arrange before the spinner consumes its
    draws.  The strengthened geometry interval admits one 200-unit motion but
    is narrower than two, so the second post-stop motion necessarily leaves it. *)
Theorem no_dust_tap_schedule_keeps_this_interval :
  forall pitch change direction draws,
    in_certified_pitch_interval pitch ->
    In change [30; 60; 90; 120] ->
    In direction [-1; 1] ->
    ~ in_certified_pitch_interval
        (face_pitch
          (run_random_mode 7 (SpinnerState pitch 1 change direction) draws)).
Proof.
  intros pitch change direction draws Hpitch Hchange Hdirection.
  rewrite second_post_stop_motion by exact Hchange.
  simpl.
  simpl in Hdirection.
  destruct Hdirection as [H | [H | H]]; try contradiction;
    subst direction; unfold in_certified_pitch_interval in *; lia.
Qed.
