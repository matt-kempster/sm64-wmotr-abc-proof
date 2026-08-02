From Coq Require Import Bool List ZArith.
From compcert Require Import AST Clight Floats Integers.
From Pedro.Generated Require Import
  us_mario_actions_moving jp_mario_actions_moving.
From Pedro.Proofs Require Import ASTFacts GameTypes.

Module UMove := us_mario_actions_moving.
Module JMove := jp_mario_actions_moving.

Definition landing_dust_source_receipt (version : GameVersion) : Prop :=
  match version with
  | VersionUS =>
      contains_landing_input_split_s
        UMove._input 1
        UMove._apply_landing_accel 1065017672
        UMove._forwardVel UMove._apply_slope_decel 1073741824 1098907648
        (fn_body UMove.f_common_landing_action) = true /\
      calls_ident_s UMove._apply_slope_accel
        (fn_body UMove.f_apply_landing_accel) = true /\
      calls_ident_s UMove._mario_floor_is_slope
        (fn_body UMove.f_apply_landing_accel) = true /\
      assigns_field_s UMove._forwardVel
        (fn_body UMove.f_apply_landing_accel) = true /\
      calls_ident_s UMove._mario_get_floor_class
        (fn_body UMove.f_apply_slope_decel) = true /\
      switch_has_case_float32_bits_s (Some 19) 1045220557
        (fn_body UMove.f_apply_slope_decel) = true /\
      switch_has_case_float32_bits_s (Some 20) 1060320051
        (fn_body UMove.f_apply_slope_decel) = true /\
      switch_has_case_float32_bits_s None 1073741824
        (fn_body UMove.f_apply_slope_decel) = true /\
      switch_has_case_float32_bits_s (Some 21) 1077936128
        (fn_body UMove.f_apply_slope_decel) = true /\
      calls_ident_s UMove._approach_f32
        (fn_body UMove.f_apply_slope_decel) = true /\
      calls_ident_s UMove._apply_slope_accel
        (fn_body UMove.f_apply_slope_decel) = true /\
      assigns_field_s UMove._forwardVel
        (fn_body UMove.f_apply_slope_decel) = true /\
      call_precedes_field_gt_float_or_bit_s
        UMove._perform_ground_step UMove._forwardVel UMove._particleFlags
        1098907648 0
        (fn_body UMove.f_common_landing_action) = true
  | VersionJP =>
      contains_landing_input_split_s
        JMove._input 1
        JMove._apply_landing_accel 1065017672
        JMove._forwardVel JMove._apply_slope_decel 1073741824 1098907648
        (fn_body JMove.f_common_landing_action) = true /\
      calls_ident_s JMove._apply_slope_accel
        (fn_body JMove.f_apply_landing_accel) = true /\
      calls_ident_s JMove._mario_floor_is_slope
        (fn_body JMove.f_apply_landing_accel) = true /\
      assigns_field_s JMove._forwardVel
        (fn_body JMove.f_apply_landing_accel) = true /\
      calls_ident_s JMove._mario_get_floor_class
        (fn_body JMove.f_apply_slope_decel) = true /\
      switch_has_case_float32_bits_s (Some 19) 1045220557
        (fn_body JMove.f_apply_slope_decel) = true /\
      switch_has_case_float32_bits_s (Some 20) 1060320051
        (fn_body JMove.f_apply_slope_decel) = true /\
      switch_has_case_float32_bits_s None 1073741824
        (fn_body JMove.f_apply_slope_decel) = true /\
      switch_has_case_float32_bits_s (Some 21) 1077936128
        (fn_body JMove.f_apply_slope_decel) = true /\
      calls_ident_s JMove._approach_f32
        (fn_body JMove.f_apply_slope_decel) = true /\
      calls_ident_s JMove._apply_slope_accel
        (fn_body JMove.f_apply_slope_decel) = true /\
      assigns_field_s JMove._forwardVel
        (fn_body JMove.f_apply_slope_decel) = true /\
      call_precedes_field_gt_float_or_bit_s
        JMove._perform_ground_step JMove._forwardVel JMove._particleFlags
        1098907648 0
        (fn_body JMove.f_common_landing_action) = true
  end.

Theorem landing_dust_source_receipt_us :
  landing_dust_source_receipt VersionUS.
Proof.
  unfold landing_dust_source_receipt.
  vm_compute.
  repeat split.
Qed.

Theorem landing_dust_source_receipt_jp :
  landing_dust_source_receipt VersionJP.
Proof.
  unfold landing_dust_source_receipt.
  vm_compute.
  repeat split.
Qed.

Theorem landing_dust_source_receipt_supported :
  forall version, landing_dust_source_receipt version.
Proof.
  intros []; [exact landing_dust_source_receipt_us |
              exact landing_dust_source_receipt_jp].
Qed.
