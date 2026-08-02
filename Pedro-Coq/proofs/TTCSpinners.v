From Coq Require Import Bool List PArith.BinPos ZArith.
From compcert Require Import AST Clight Floats Integers.
From Pedro.Generated Require Import
  us_obj_behaviors_2 us_behavior_data us_behavior_actions
  us_platform_displacement us_ttc_area1_macro us_ttc_spinner_collision
  jp_obj_behaviors_2 jp_behavior_data jp_behavior_actions
  jp_platform_displacement jp_ttc_area1_macro jp_ttc_spinner_collision.
From Pedro.Proofs Require Import ASTFacts GameTypes.

Import ListNotations.

Module USpinner := us_obj_behaviors_2.
Module UBD := us_behavior_data.
Module UBA := us_behavior_actions.
Module UPD := us_platform_displacement.
Module UMacro := us_ttc_area1_macro.
Module UCollision := us_ttc_spinner_collision.

Module JSpinner := jp_obj_behaviors_2.
Module JBD := jp_behavior_data.
Module JBA := jp_behavior_actions.
Module JPD := jp_platform_displacement.
Module JMacro := jp_ttc_area1_macro.
Module JCollision := jp_ttc_spinner_collision.

Definition ttc_spinner_source_receipt (version : GameVersion) : Prop :=
  match version with
  | VersionUS =>
      gvar_init USpinner.v_sTTCSpinnerSpeeds =
        [Init_int16 (Int.repr 200); Init_int16 (Int.repr 600);
         Init_int16 (Int.repr 200); Init_int16 (Int.repr 0)] /\
      statement_mentions_ident_s USpinner._gTTCSpeedSetting
        (fn_body USpinner.f_bhv_ttc_spinner_update) = true /\
      calls_ident_s USpinner._random_sign
        (fn_body USpinner.f_bhv_ttc_spinner_update) = true /\
      calls_ident_s USpinner._random_mod_offset
        (fn_body USpinner.f_bhv_ttc_spinner_update) = true /\
      statement_mentions_int_s 2
        (fn_body USpinner.f_bhv_ttc_spinner_update) = true /\
      statement_mentions_int_s 5
        (fn_body USpinner.f_bhv_ttc_spinner_update) = true /\
      initializer_addrof_subsequenceb
        [UBD._ttc_seg7_collision_rotating_clock_platform2;
         UBD._bhv_ttc_spinner_update;
         UBD._load_object_collision_model]
        (gvar_init UBD.v_bhvTTCSpinner) = true /\
      count_records_with_low9 356 (gvar_init UMacro.v_ttc_seg7_macro_objs) = 14%nat /\
      length (init_int16_values
        (gvar_init UCollision.v_ttc_seg7_collision_rotating_clock_platform2)) =
        170%nat /\
      statement_assigns_global_s UBA._gTTCSpeedSetting
        (fn_body UBA.f_bhv_rotating_clock_arm_loop) = true /\
      calls_ident_s UPD._apply_platform_displacement
        (fn_body UPD.f_apply_mario_platform_displacement) = true
  | VersionJP =>
      gvar_init JSpinner.v_sTTCSpinnerSpeeds =
        [Init_int16 (Int.repr 200); Init_int16 (Int.repr 600);
         Init_int16 (Int.repr 200); Init_int16 (Int.repr 0)] /\
      statement_mentions_ident_s JSpinner._gTTCSpeedSetting
        (fn_body JSpinner.f_bhv_ttc_spinner_update) = true /\
      calls_ident_s JSpinner._random_sign
        (fn_body JSpinner.f_bhv_ttc_spinner_update) = true /\
      calls_ident_s JSpinner._random_mod_offset
        (fn_body JSpinner.f_bhv_ttc_spinner_update) = true /\
      statement_mentions_int_s 2
        (fn_body JSpinner.f_bhv_ttc_spinner_update) = true /\
      statement_mentions_int_s 5
        (fn_body JSpinner.f_bhv_ttc_spinner_update) = true /\
      initializer_addrof_subsequenceb
        [JBD._ttc_seg7_collision_rotating_clock_platform2;
         JBD._bhv_ttc_spinner_update;
         JBD._load_object_collision_model]
        (gvar_init JBD.v_bhvTTCSpinner) = true /\
      count_records_with_low9 356 (gvar_init JMacro.v_ttc_seg7_macro_objs) = 14%nat /\
      length (init_int16_values
        (gvar_init JCollision.v_ttc_seg7_collision_rotating_clock_platform2)) =
        170%nat /\
      statement_assigns_global_s JBA._gTTCSpeedSetting
        (fn_body JBA.f_bhv_rotating_clock_arm_loop) = true /\
      calls_ident_s JPD._apply_platform_displacement
        (fn_body JPD.f_apply_mario_platform_displacement) = true
  end.

Theorem ttc_spinner_source_receipt_us :
  ttc_spinner_source_receipt VersionUS.
Proof.
  unfold ttc_spinner_source_receipt.
  vm_compute.
  repeat split.
Qed.
Theorem ttc_spinner_source_receipt_jp :
  ttc_spinner_source_receipt VersionJP.
Proof.
  unfold ttc_spinner_source_receipt.
  vm_compute.
  repeat split.
Qed.

Theorem ttc_spinner_source_receipt_supported :
  forall version, ttc_spinner_source_receipt version.
Proof.
  intros []; [exact ttc_spinner_source_receipt_us |
              exact ttc_spinner_source_receipt_jp].
Qed.

Theorem ttc_spinner_collision_streams_match_us_jp :
  init_int16_values
    (gvar_init UCollision.v_ttc_seg7_collision_rotating_clock_platform2) =
  init_int16_values
    (gvar_init JCollision.v_ttc_seg7_collision_rotating_clock_platform2).
Proof.
  vm_compute.
  reflexivity.
Qed.

Theorem ttc_spinner_macro_streams_match_us_jp :
  init_int16_values (gvar_init UMacro.v_ttc_seg7_macro_objs) =
  init_int16_values (gvar_init JMacro.v_ttc_seg7_macro_objs).
Proof.
  vm_compute.
  reflexivity.
Qed.
