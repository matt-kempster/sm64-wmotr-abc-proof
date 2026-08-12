(** Identifier-only direct-callee receipts for the three US cutscene bodies
    on the dialog/depth spine.  No transitive reachability or memory-frame
    conclusion is encoded here. *)

From Coq Require Import List.
From compcert Require Import AST Clight.
From LessThanOneAPress.Generated Require Import us_mario_actions_cutscene.
From LessThanOneAPress.Proofs Require Import
  RetailExternalFrameReachability.

Import ListNotations.
Module DD_USCutscene := us_mario_actions_cutscene.

Definition us_general_star_dance_handler_direct_callee_receipt : list ident :=
  [DD_USCutscene._spawn_object;
   DD_USCutscene._disable_background_sound;
   DD_USCutscene._play_course_clear;
   DD_USCutscene._play_music;
   DD_USCutscene._play_music;
   DD_USCutscene._play_sound;
   DD_USCutscene._level_trigger_warp;
   DD_USCutscene._enable_time_stop;
   DD_USCutscene._create_dialog_box_with_response;
   DD_USCutscene._save_file_do_save;
   DD_USCutscene._is_anim_at_end;
   DD_USCutscene._disable_time_stop;
   DD_USCutscene._enable_background_sound;
   DD_USCutscene._get_star_collection_dialog;
   DD_USCutscene._set_mario_action;
   DD_USCutscene._set_mario_action].

Definition us_act_star_dance_direct_callee_receipt : list ident :=
  [DD_USCutscene._set_mario_animation;
   DD_USCutscene._general_star_dance_handler;
   DD_USCutscene._stop_and_set_height_to_floor].

Definition us_act_reading_automatic_dialog_direct_callee_receipt : list ident :=
  [DD_USCutscene._enable_time_stop;
   DD_USCutscene._set_mario_animation;
   DD_USCutscene._create_dialog_box;
   DD_USCutscene._create_dialog_box_with_var;
   DD_USCutscene._get_dialog_id;
   DD_USCutscene._disable_time_stop;
   DD_USCutscene._play_cutscene_music;
   DD_USCutscene._set_mario_action;
   DD_USCutscene._set_mario_action;
   DD_USCutscene._vec3s_set].

Theorem us_general_star_dance_handler_direct_callees_exact :
  statement_direct_callees
    (fn_body DD_USCutscene.f_general_star_dance_handler) =
  us_general_star_dance_handler_direct_callee_receipt.
Proof. vm_compute. reflexivity. Qed.

Theorem us_act_star_dance_direct_callees_exact :
  statement_direct_callees (fn_body DD_USCutscene.f_act_star_dance) =
  us_act_star_dance_direct_callee_receipt.
Proof. vm_compute. reflexivity. Qed.

Theorem us_act_reading_automatic_dialog_direct_callees_exact :
  statement_direct_callees
    (fn_body DD_USCutscene.f_act_reading_automatic_dialog) =
  us_act_reading_automatic_dialog_direct_callee_receipt.
Proof. vm_compute. reflexivity. Qed.
