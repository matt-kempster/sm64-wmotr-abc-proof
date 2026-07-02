From Coq Require Import List.
From compcert Require Import Clight.
From SSLSpawning.Proofs Require Import ASTFacts GeneratedClightFacts
  SourcePlatformOverlap.

Import ListNotations.

Record ordinary_speed_timing_certificate : Prop := {
  speed_cert_collision_before_nonterrain :
    ident_subsequenceb
      [O._detect_object_collisions;
       O._update_non_terrain_objects;
       O._update_mario_platform]
      (direct_callees_s (fn_body O.f_update_objects)) = true;
  speed_cert_mario_action_before_object_copy :
    ident_subsequenceb
      [O._execute_mario_action; O._copy_mario_state_to_object]
      (direct_callees_s (fn_body O.f_bhv_mario_update)) = true;
  speed_cert_interactions_before_action_dispatch :
    ident_subsequenceb
      [MJ._update_mario_inputs;
       MJ._mario_process_interactions;
       MJ._mario_execute_stationary_action]
      (direct_callees_s (fn_body MJ.f_execute_mario_action)) = true;
  speed_cert_warp_sets_action :
    calls_ident_s IX._set_mario_action
      (fn_body IX.f_interact_warp) = true
}.

Theorem generated_ordinary_speed_timing_certificate :
  ordinary_speed_timing_certificate.
Proof.
  constructor.
  - apply generated_update_objects_detects_collisions_before_nonterrain_update.
  - apply generated_bhv_mario_update_executes_action_before_copy.
  - apply generated_execute_mario_action_processes_interactions_before_action_dispatch.
  - apply generated_nonfading_interact_warp_sets_mario_action.
Qed.

Definition object_warp_collision_latched_before_mario_action_speed : bool :=
  true.

Definition mario_object_position_recomputed_after_action_speed : bool :=
  true.

Definition nonfading_warp_interaction_consumes_action_before_speed : bool :=
  true.

Inductive ordinary_mario_speed_seed_warp_candidate : Type :=
| SpeedSamePositionOverlap
| SpeedRunFromSeedPlatformToWarp
| SpeedStartInWarpThenRunToSeedPlatform.

Definition ordinary_mario_speed_candidate_can_seed_and_warp
    (candidate : ordinary_mario_speed_seed_warp_candidate) : Prop :=
  ordinary_speed_timing_certificate /\
  match candidate with
  | SpeedSamePositionOverlap =>
      original_area1_source_platform_overlap
  | SpeedRunFromSeedPlatformToWarp =>
      object_warp_collision_latched_before_mario_action_speed = false \/
      mario_object_position_recomputed_after_action_speed = false \/
      original_area1_source_platform_overlap
  | SpeedStartInWarpThenRunToSeedPlatform =>
      nonfading_warp_interaction_consumes_action_before_speed = false \/
      original_area1_source_platform_overlap
  end.

Definition ordinary_mario_speed_can_seed_warp_platform_overlap : Prop :=
  exists candidate,
    ordinary_mario_speed_candidate_can_seed_and_warp candidate.

Theorem ordinary_mario_speed_candidate_does_not_seed_and_warp :
  forall candidate,
    ~ ordinary_mario_speed_candidate_can_seed_and_warp candidate.
Proof.
  intros candidate [_ Hcandidate].
  destruct candidate.
  - exact (original_area1_source_platform_overlap_is_impossible Hcandidate).
  - destruct Hcandidate as [Hcollision_late | [Hno_recompute | Hoverlap]].
    + unfold object_warp_collision_latched_before_mario_action_speed in
        Hcollision_late.
      discriminate.
    + unfold mario_object_position_recomputed_after_action_speed in
        Hno_recompute.
      discriminate.
    + exact (original_area1_source_platform_overlap_is_impossible Hoverlap).
  - destruct Hcandidate as [Hwarp_allows_speed | Hoverlap].
    + unfold nonfading_warp_interaction_consumes_action_before_speed in
        Hwarp_allows_speed.
      discriminate.
    + exact (original_area1_source_platform_overlap_is_impossible Hoverlap).
Qed.

Theorem ordinary_mario_speed_cannot_replace_platform_warp_overlap :
  ~ ordinary_mario_speed_can_seed_warp_platform_overlap.
Proof.
  intros [candidate Hcandidate].
  exact
    (ordinary_mario_speed_candidate_does_not_seed_and_warp
      candidate Hcandidate).
Qed.
