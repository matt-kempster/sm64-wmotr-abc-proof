From Coq Require Import Bool List ZArith.
From compcert Require Import AST Clight Floats Integers.
From Pedro.Generated Require Import
  us_mario_step jp_mario_step
  us_mario_actions_airborne jp_mario_actions_airborne.
From Pedro.Proofs Require Import ASTFacts GameTypes.

Module UStep := us_mario_step.
Module JStep := jp_mario_step.
Module UAir := us_mario_actions_airborne.
Module JAir := jp_mario_actions_airborne.

Definition pedro_collision_source_receipt (version : GameVersion) : Prop :=
  match version with
  | VersionUS =>
      contains_pedro_landing_branch_s
        UStep._nextPos UStep._pos UStep._floor
        UStep._floorHeight UStep._ceilHeight
        (fn_body UStep.f_perform_air_quarter_step) = true /\
      calls_ident_s UStep._perform_air_quarter_step
        (fn_body UStep.f_perform_air_step) = true /\
      calls_ident_s UAir._perform_air_step
        (fn_body UAir.f_common_air_action_step) = true /\
      calls_ident_s UAir._set_mario_action
        (fn_body UAir.f_common_air_action_step) = true
  | VersionJP =>
      contains_pedro_landing_branch_s
        JStep._nextPos JStep._pos JStep._floor
        JStep._floorHeight JStep._ceilHeight
        (fn_body JStep.f_perform_air_quarter_step) = true /\
      calls_ident_s JStep._perform_air_quarter_step
        (fn_body JStep.f_perform_air_step) = true /\
      calls_ident_s JAir._perform_air_step
        (fn_body JAir.f_common_air_action_step) = true /\
      calls_ident_s JAir._set_mario_action
        (fn_body JAir.f_common_air_action_step) = true
  end.

Theorem pedro_collision_source_receipt_us :
  pedro_collision_source_receipt VersionUS.
Proof.
  unfold pedro_collision_source_receipt.
  vm_compute.
  repeat split.
Qed.

Theorem pedro_collision_source_receipt_jp :
  pedro_collision_source_receipt VersionJP.
Proof.
  unfold pedro_collision_source_receipt.
  vm_compute.
  repeat split.
Qed.

Theorem pedro_collision_source_receipt_supported :
  forall version, pedro_collision_source_receipt version.
Proof.
  intros []; [exact pedro_collision_source_receipt_us |
              exact pedro_collision_source_receipt_jp].
Qed.
