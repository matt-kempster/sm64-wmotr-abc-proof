From Coq Require Import List ZArith Lia.
From SSLSpawning.Proofs Require Import SourcePlatformOverlap SSLStartCloneRoute.

Import ListNotations.
Local Open Scope Z_scope.

Inductive mario_coordinate_source : Type :=
| MarioStatePosition
| MarioObjectPosition
| MarioVisualModelPosition.

Definition warp_hitbox_collision_coordinate_source : mario_coordinate_source :=
  MarioObjectPosition.

Definition warp_handler_coordinate_source : mario_coordinate_source :=
  MarioStatePosition.

Definition update_mario_platform_coordinate_source : mario_coordinate_source :=
  MarioObjectPosition.

Definition visible_astral_projection_coordinate_source
    : mario_coordinate_source :=
  MarioVisualModelPosition.

Definition bhv_mario_update_copies_state_to_object_before_platform_update
    : bool := true.

Definition detect_object_collisions_runs_before_bhv_mario_update : bool := true.

Definition visual_model_only_astral_projection_can_satisfy_seed_checks : Prop :=
  visible_astral_projection_coordinate_source =
    update_mario_platform_coordinate_source \/
  visible_astral_projection_coordinate_source =
    warp_hitbox_collision_coordinate_source.

Theorem visual_model_only_astral_projection_is_ignored_by_seed_checks :
  ~ visual_model_only_astral_projection_can_satisfy_seed_checks.
Proof.
  intros [Hplatform | Hwarp]; discriminate.
Qed.

Record post_copy_object_position_desync_seed_shape : Prop := {
  pre_update_object_position_collides_with_warp :
    warp_hitbox_collision_coordinate_source = MarioObjectPosition;
  post_copy_object_position_selects_platform :
    update_mario_platform_coordinate_source = MarioObjectPosition;
  player_update_copies_state_before_platform_update :
    bhv_mario_update_copies_state_to_object_before_platform_update = true
}.

Theorem post_copy_object_position_desync_is_the_right_shape :
  post_copy_object_position_desync_seed_shape.
Proof.
  constructor; reflexivity.
Qed.

Definition ssl_area1_has_chuckya_source : bool := false.

Definition known_astral_projection_chuckya_setup_available_in_ssl : Prop :=
  ssl_area1_has_chuckya_source = true.

Theorem known_astral_projection_chuckya_setup_not_available_in_ssl :
  ~ known_astral_projection_chuckya_setup_available_in_ssl.
Proof.
  unfold known_astral_projection_chuckya_setup_available_in_ssl,
    ssl_area1_has_chuckya_source.
  discriminate.
Qed.

Definition direct_global_gMarioObject_oPos_write_sites_are_butterfly_offsets
    : bool := true.

Definition butterfly_runs_after_player_copy_if_present : bool := true.
Definition butterfly_calculate_angle_restores_mario_object_oPos : bool := true.
Definition ssl_area1_has_butterfly_source : bool := false.
Definition ssl_area1_has_triplet_butterfly_source : bool := false.

Inductive audited_post_copy_oPos_write_candidate : Type :=
| ButterflyTemporaryOffset.

Definition audited_post_copy_oPos_candidate_present_in_ssl
    (candidate : audited_post_copy_oPos_write_candidate) : bool :=
  match candidate with
  | ButterflyTemporaryOffset =>
      ssl_area1_has_butterfly_source || ssl_area1_has_triplet_butterfly_source
  end.

Definition audited_post_copy_oPos_candidate_persists_after_behavior
    (candidate : audited_post_copy_oPos_write_candidate) : bool :=
  match candidate with
  | ButterflyTemporaryOffset =>
      negb butterfly_calculate_angle_restores_mario_object_oPos
  end.

Definition audited_post_copy_oPos_candidate_can_seed_overlap
    (candidate : audited_post_copy_oPos_write_candidate) : Prop :=
  direct_global_gMarioObject_oPos_write_sites_are_butterfly_offsets = true /\
  butterfly_runs_after_player_copy_if_present = true /\
  audited_post_copy_oPos_candidate_present_in_ssl candidate = true /\
  audited_post_copy_oPos_candidate_persists_after_behavior candidate = true.

Theorem butterfly_post_copy_oPos_write_does_not_persist :
  audited_post_copy_oPos_candidate_persists_after_behavior
    ButterflyTemporaryOffset = false.
Proof.
  reflexivity.
Qed.

Theorem butterfly_post_copy_oPos_write_not_available_in_ssl :
  audited_post_copy_oPos_candidate_present_in_ssl ButterflyTemporaryOffset =
    false.
Proof.
  reflexivity.
Qed.

Theorem no_audited_post_copy_oPos_write_candidate_seeds_overlap :
  forall candidate,
    ~ audited_post_copy_oPos_candidate_can_seed_overlap candidate.
Proof.
  intros candidate [_ [_ [Hpresent Hpersists]]].
  destruct candidate.
  cbn in Hpresent, Hpersists.
  discriminate.
Qed.

Definition tweester_begin_list_is_surface : bool := false.
Definition tweester_loads_owned_surface_collision : bool := false.
Definition tweester_is_source_platform_kind : bool := false.
Definition tweester_hides_when_distance_to_mario_exceeds_3000 : bool := true.

Definition tweester_transport_can_leave_standable_source_platform_surface
    : Prop :=
  tweester_begin_list_is_surface = true /\
  tweester_loads_owned_surface_collision = true /\
  tweester_is_source_platform_kind = true.

Theorem tweester_transport_cannot_leave_standable_source_platform_surface :
  ~ tweester_transport_can_leave_standable_source_platform_surface.
Proof.
  intros [Hsurface _].
  unfold tweester_begin_list_is_surface in Hsurface.
  discriminate.
Qed.

Theorem rapid_home_oscillation_tweester_transport_has_3000_unit_limit :
  tweester_hides_when_distance_to_mario_exceeds_3000 = true.
Proof.
  reflexivity.
Qed.

Inductive audited_source_platform_clone_candidate : Type :=
| PyramidTopPillarTouchDetector
| PyramidTopFragment
| ExclamationBoxSpawnedContents
| BreakableBoxSpawnedCoins
| CannonLidSpawnedCannon.

Definition tox_box_spawns_objects : bool := false.
Definition message_panel_spawns_objects : bool := false.

Definition audited_clone_candidate_is_standable_source_platform_surface
    (candidate : audited_source_platform_clone_candidate) : bool :=
  match candidate with
  | PyramidTopPillarTouchDetector => false
  | PyramidTopFragment => false
  | ExclamationBoxSpawnedContents => false
  | BreakableBoxSpawnedCoins => false
  | CannonLidSpawnedCannon => false
  end.

Definition audited_source_platform_clone_candidate_can_seed_overlap
    (candidate : audited_source_platform_clone_candidate) : Prop :=
  audited_clone_candidate_is_standable_source_platform_surface candidate = true.

Definition source_backed_memory_corruption_clone_route_found_in_audit : Prop :=
  tox_box_spawns_objects = true \/
  message_panel_spawns_objects = true \/
  exists candidate,
    audited_source_platform_clone_candidate_can_seed_overlap candidate.

Theorem tox_box_behavior_spawns_no_clone_candidate :
  tox_box_spawns_objects = false.
Proof.
  reflexivity.
Qed.

Theorem message_panel_behavior_spawns_no_clone_candidate :
  message_panel_spawns_objects = false.
Proof.
  reflexivity.
Qed.

Theorem audited_source_platform_behaviors_do_not_spawn_standable_clone :
  forall candidate,
    ~ audited_source_platform_clone_candidate_can_seed_overlap candidate.
Proof.
  intros [] Hseed; cbn in Hseed; discriminate.
Qed.

Theorem no_source_backed_memory_corruption_clone_candidate_found_in_audit :
  ~ source_backed_memory_corruption_clone_route_found_in_audit.
Proof.
  intros [Htox | [Hmessage | [candidate Hcandidate]]].
  - unfold tox_box_spawns_objects in Htox.
    discriminate.
  - unfold message_panel_spawns_objects in Hmessage.
    discriminate.
  - exact
      (audited_source_platform_behaviors_do_not_spawn_standable_clone
        candidate Hcandidate).
Qed.

Inductive investigated_desync_mechanism : Type :=
| AstralProjectionChuckyaSetup
| RapidHomeOscillationTweesterTransport
| AuditedPostCopyMarioObjectPositionWrite
| AuditedSourcePlatformCloneOrCorruptionCandidate.

Inductive interaction_kind_with_tornado : Type :=
| InteractionWarp2
| InteractionTornado2.

Definition interaction_handler_index_with_tornado
    (kind : interaction_kind_with_tornado) : nat :=
  match kind with
  | InteractionWarp2 => 4%nat
  | InteractionTornado2 => 9%nat
  end.

Definition non_fading_warp_handler_breaks_interaction_loop : bool := true.

Theorem warp_interaction_is_processed_before_tornado :
  (interaction_handler_index_with_tornado InteractionWarp2 <
   interaction_handler_index_with_tornado InteractionTornado2)%nat.
Proof.
  cbn.
  lia.
Qed.

Definition same_frame_warp_then_tornado_move_can_seed_platform : Prop :=
  non_fading_warp_handler_breaks_interaction_loop = false \/
  (interaction_handler_index_with_tornado InteractionTornado2 <
   interaction_handler_index_with_tornado InteractionWarp2)%nat.

Theorem warp_collision_preempts_same_frame_tornado_move :
  ~ same_frame_warp_then_tornado_move_can_seed_platform.
Proof.
  intros [Hno_break | Htornado_first].
  - unfold non_fading_warp_handler_breaks_interaction_loop in Hno_break.
    discriminate.
  - pose proof warp_interaction_is_processed_before_tornado as Hwarp_first.
    lia.
Qed.

Definition investigated_mechanism_can_seed_warp_platform_overlap
    (mechanism : investigated_desync_mechanism) : Prop :=
  match mechanism with
  | AstralProjectionChuckyaSetup =>
      known_astral_projection_chuckya_setup_available_in_ssl /\
      post_copy_object_position_desync_seed_shape
  | RapidHomeOscillationTweesterTransport =>
      tweester_transport_can_leave_standable_source_platform_surface \/
      same_frame_warp_then_tornado_move_can_seed_platform
  | AuditedPostCopyMarioObjectPositionWrite =>
      exists candidate,
        audited_post_copy_oPos_candidate_can_seed_overlap candidate
  | AuditedSourcePlatformCloneOrCorruptionCandidate =>
      source_backed_memory_corruption_clone_route_found_in_audit
  end.

Theorem investigated_desync_mechanisms_do_not_currently_seed_overlap :
  forall mechanism,
    ~ investigated_mechanism_can_seed_warp_platform_overlap mechanism.
Proof.
  intros mechanism Hseed.
  destruct mechanism.
  - destruct Hseed as [Hsetup _].
    exact (known_astral_projection_chuckya_setup_not_available_in_ssl Hsetup).
  - destruct Hseed as [Htweester_surface | Hsame_frame_move].
    + exact
        (tweester_transport_cannot_leave_standable_source_platform_surface
          Htweester_surface).
    + exact (warp_collision_preempts_same_frame_tornado_move Hsame_frame_move).
  - destruct Hseed as [candidate Hcandidate].
    exact
      (no_audited_post_copy_oPos_write_candidate_seeds_overlap
        candidate Hcandidate).
  - exact
      (no_source_backed_memory_corruption_clone_candidate_found_in_audit
        Hseed).
Qed.
