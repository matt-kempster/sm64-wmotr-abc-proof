(** Native-call coverage needed by the Rank-15 live-memory projection.

    This is the complete syntactic direct-call closure of the two generated
    Eyerok native loops, not a claim that every listed branch is reached.
    In particular it includes allocation fallback, dialog/camera helpers and
    surface loading.  No indirect native call is hidden inside this closure.
    The behavior interpreter which calls the roots, later execution of spawned
    objects, and the task-entry prefix remain separate live obligations. *)

From Coq Require Import Bool List ZArith.
From compcert Require Import AST Clight Ctypes.
From LessThanOneAPress.Proofs Require Import
  ASTFacts ClightFacts Area1Rank1SixResidualAudit Area1Rank3PayloadWriterClosure
  EyerokRank15DynamicSupport.

Import ListNotations.

Definition rank15_us_native_closure : list ident :=
  internal_direct_call_closure 8 rank3_us_definitions
    [UEye._bhv_eyerok_boss_loop; UEye._bhv_eyerok_hand_loop].

Definition rank15_jp_native_closure : list ident :=
  internal_direct_call_closure 8 rank3_jp_definitions
    [JEye._bhv_eyerok_boss_loop; JEye._bhv_eyerok_hand_loop].

Definition rank15_us_native_outside_calls : list ident :=
  [UEye._cur_obj_play_sound_2; UEye._seq_player_lower_volume;
   UEye._stop_background_music; UEye._create_sound_spawner; UOH._sqrtf;
   UOH._cutscene_object_without_dialog; UOH._cutscene_object_with_dialog;
   UOH._set_camera_shake_from_point; A1R3_USSpawn._stop_sounds_from_source].

Definition rank15_jp_native_outside_calls : list ident :=
  [JEye._cur_obj_play_sound_2; JEye._seq_player_lower_volume;
   JEye._stop_background_music; JEye._create_sound_spawner; JOH._sqrtf;
   JOH._cutscene_object_without_dialog; JOH._cutscene_object_with_dialog;
   JOH._set_camera_shake_from_point; A1R3_JPSpawn._stop_sounds_from_source].

Theorem rank15_native_call_closure_sizes_checked :
  length rank15_us_native_closure = 166%nat /\
  length rank15_jp_native_closure = 166%nat.
Proof. vm_compute. split; reflexivity. Qed.

Theorem rank15_native_call_closure_closed_checked :
  internal_direct_call_set_is_closed rank3_us_definitions
    rank15_us_native_closure = true /\
  internal_direct_call_set_is_closed rank3_jp_definitions
    rank15_jp_native_closure = true.
Proof. vm_compute. split; reflexivity. Qed.

Theorem rank15_native_outside_call_inventory_checked :
  same_identifier_set
    (unresolved_identifiers rank3_us_definitions rank15_us_native_closure)
    rank15_us_native_outside_calls = true /\
  same_identifier_set
    (unresolved_identifiers rank3_jp_definitions rank15_jp_native_closure)
    rank15_jp_native_outside_calls = true /\
  length (unresolved_identifiers rank3_us_definitions rank15_us_native_closure)
    = 9%nat /\
  length (unresolved_identifiers rank3_jp_definitions rank15_jp_native_closure)
    = 9%nat.
Proof. vm_compute. repeat split; reflexivity. Qed.

Theorem rank15_native_closure_has_no_indirect_calls :
  rank1_internal_indirect_call_sites rank15_us_native_closure
    rank3_us_definitions = [] /\
  rank1_internal_indirect_call_sites rank15_jp_native_closure
    rank3_jp_definitions = [].
Proof. vm_compute. split; reflexivity. Qed.

Definition EyerokRank15LiveNativeCallBoundary : Prop :=
  (length rank15_us_native_closure = 166%nat /\
   length rank15_jp_native_closure = 166%nat) /\
  (internal_direct_call_set_is_closed rank3_us_definitions
      rank15_us_native_closure = true /\
   internal_direct_call_set_is_closed rank3_jp_definitions
      rank15_jp_native_closure = true) /\
  (same_identifier_set
     (unresolved_identifiers rank3_us_definitions rank15_us_native_closure)
     rank15_us_native_outside_calls = true /\
   same_identifier_set
     (unresolved_identifiers rank3_jp_definitions rank15_jp_native_closure)
     rank15_jp_native_outside_calls = true /\
   length (unresolved_identifiers rank3_us_definitions rank15_us_native_closure)
     = 9%nat /\
   length (unresolved_identifiers rank3_jp_definitions rank15_jp_native_closure)
     = 9%nat) /\
  (rank1_internal_indirect_call_sites rank15_us_native_closure
      rank3_us_definitions = [] /\
   rank1_internal_indirect_call_sites rank15_jp_native_closure
      rank3_jp_definitions = []).

Theorem eyerok_rank15_live_native_call_boundary_checked :
  EyerokRank15LiveNativeCallBoundary.
Proof.
  exact (conj rank15_native_call_closure_sizes_checked
    (conj rank15_native_call_closure_closed_checked
      (conj rank15_native_outside_call_inventory_checked
        rank15_native_closure_has_no_indirect_calls))).
Qed.
