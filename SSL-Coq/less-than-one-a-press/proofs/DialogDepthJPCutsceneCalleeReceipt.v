(** Identifier-only direct-callee receipts for the three JP cutscene bodies
    on the dialog/depth spine.  These prove neither transitive reachability
    nor any external writable-memory frame. *)

From Coq Require Import List.
From compcert Require Import AST Clight.
From LessThanOneAPress.Generated Require Import jp_mario_actions_cutscene.
From LessThanOneAPress.Proofs Require Import
  RetailExternalFrameReachability.

Import ListNotations.
Module DD_JPCutscene := jp_mario_actions_cutscene.

Definition jp_general_star_dance_handler_direct_callee_receipt : list ident :=
  [DD_JPCutscene._spawn_object;
   DD_JPCutscene._disable_background_sound;
   DD_JPCutscene._play_course_clear;
   DD_JPCutscene._play_music;
   DD_JPCutscene._play_music;
   DD_JPCutscene._play_sound;
   DD_JPCutscene._level_trigger_warp;
   DD_JPCutscene._enable_time_stop;
   DD_JPCutscene._create_dialog_box_with_response;
   DD_JPCutscene._save_file_do_save;
   DD_JPCutscene._is_anim_at_end;
   DD_JPCutscene._disable_time_stop;
   DD_JPCutscene._enable_background_sound;
   DD_JPCutscene._get_star_collection_dialog;
   DD_JPCutscene._set_mario_action;
   DD_JPCutscene._set_mario_action].

Definition jp_act_star_dance_direct_callee_receipt : list ident :=
  [DD_JPCutscene._set_mario_animation;
   DD_JPCutscene._general_star_dance_handler;
   DD_JPCutscene._stop_and_set_height_to_floor].

Definition jp_act_reading_automatic_dialog_direct_callee_receipt : list ident :=
  [DD_JPCutscene._enable_time_stop;
   DD_JPCutscene._set_mario_animation;
   DD_JPCutscene._create_dialog_box;
   DD_JPCutscene._create_dialog_box_with_var;
   DD_JPCutscene._get_dialog_id;
   DD_JPCutscene._disable_time_stop;
   DD_JPCutscene._play_cutscene_music;
   DD_JPCutscene._set_mario_action;
   DD_JPCutscene._set_mario_action;
   DD_JPCutscene._vec3s_set].

Theorem jp_general_star_dance_handler_direct_callees_exact :
  statement_direct_callees
    (fn_body DD_JPCutscene.f_general_star_dance_handler) =
  jp_general_star_dance_handler_direct_callee_receipt.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_act_star_dance_direct_callees_exact :
  statement_direct_callees (fn_body DD_JPCutscene.f_act_star_dance) =
  jp_act_star_dance_direct_callee_receipt.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_act_reading_automatic_dialog_direct_callees_exact :
  statement_direct_callees
    (fn_body DD_JPCutscene.f_act_reading_automatic_dialog) =
  jp_act_reading_automatic_dialog_direct_callee_receipt.
Proof. vm_compute. reflexivity. Qed.
