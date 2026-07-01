From Coq Require Import ZArith.
From SSLSpawning.Proofs Require Import Spec.

Local Open Scope Z_scope.

Definition spawn_objects_from_info_jp_model (state : game_state) : game_state :=
  state.

Definition spawn_objects_from_info_non_jp_model
    (state : game_state) : game_state := {|
  state_mario := state_mario state;
  state_gMarioPlatform := None;
  state_has_mario_object := state_has_mario_object state;
  state_time_stop_active := state_time_stop_active state;
  state_object_memory := state_object_memory state;
  state_free_list := state_free_list state
|}.

Theorem jp_spawn_preserves_gMarioPlatform :
  forall state,
    state_gMarioPlatform (spawn_objects_from_info_jp_model state) =
    state_gMarioPlatform state.
Proof.
  reflexivity.
Qed.

Theorem spawn_objects_from_info_jp_preserves_gMarioPlatform :
  forall state platform,
    state_gMarioPlatform state = Some platform ->
    state_gMarioPlatform (spawn_objects_from_info_jp_model state) =
    Some platform.
Proof.
  intros state platform Hplatform.
  rewrite jp_spawn_preserves_gMarioPlatform.
  exact Hplatform.
Qed.

Theorem non_jp_spawn_clears_gMarioPlatform :
  forall state,
    state_gMarioPlatform (spawn_objects_from_info_non_jp_model state) = None.
Proof.
  reflexivity.
Qed.
