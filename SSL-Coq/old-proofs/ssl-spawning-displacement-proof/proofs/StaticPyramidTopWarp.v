From Coq Require Import ZArith Lia.
From SSLSpawning.Proofs Require Import
  Spec GeneratedClightFacts PyramidTopWarp ClonedPlatformWarp
  PyramidTopSlotPersistence.

Local Open Scope Z_scope.

Definition stock_mario_hitbox_height : Z :=
  cloned_route_mario_hitbox_height.

Definition find_floor_upward_buffer : Z := 78.

Definition static_node1e_warp_contact_y (mario_y : Z) : Prop :=
  mario_hitbox_overlaps_top_entry_warp_y
    mario_y stock_mario_hitbox_height.

Definition floor_search_result_is_admissible
    (query_y floor_y : Z) : Prop :=
  floor_y <= query_y + find_floor_upward_buffer.

Definition spinning_top_owned_floor_height
    (object_y floor_y : Z) : Prop :=
  pyramid_top_spinning_or_rising_y object_y /\
  pyramid_top_collision_min_world_y object_y <= floor_y /\
  floor_y <= pyramid_top_collision_max_world_y object_y.

Definition disappeared_floor_snap_from_static_warp
    (trigger_y snapped_floor_y : Z) : Prop :=
  static_node1e_warp_contact_y trigger_y /\
  floor_search_result_is_admissible trigger_y snapped_floor_y.

Theorem static_node1e_warp_contact_y_bounds :
  forall mario_y,
    static_node1e_warp_contact_y mario_y ->
    608 <= mario_y <= 818.
Proof.
  intros mario_y Hcontact.
  unfold static_node1e_warp_contact_y,
    stock_mario_hitbox_height,
    cloned_route_mario_hitbox_height,
    mario_hitbox_overlaps_top_entry_warp_y,
    vertical_intervals_overlap,
    ssl_top_entry_warp_low_y,
    ssl_top_entry_warp_high_y,
    ssl_top_entry_warp_y,
    ssl_top_entry_warp_height,
    ssl_top_entry_warp_down_offset,
    hitbox_low_y, hitbox_high_y in Hcontact.
  cbn in Hcontact.
  lia.
Qed.

Theorem static_node1e_contact_cannot_already_stand_on_spinning_top :
  forall object_y mario_y,
    pyramid_top_spinning_or_rising_y object_y ->
    mario_stands_on_pyramid_top_collision_y mario_y object_y ->
    ~ static_node1e_warp_contact_y mario_y.
Proof.
  intros object_y mario_y Hspinning Hstanding Hcontact.
  eapply standing_on_spinning_pyramid_top_does_not_overlap_top_entry_warp_y;
    eauto.
Qed.

Theorem disappeared_snap_from_static_warp_stays_below_top_collision :
  forall trigger_y snapped_floor_y object_y,
    disappeared_floor_snap_from_static_warp trigger_y snapped_floor_y ->
    pyramid_top_spinning_or_rising_y object_y ->
    snapped_floor_y < pyramid_top_collision_min_world_y object_y.
Proof.
  intros trigger_y snapped_floor_y object_y [Hcontact Hfloor] Hspinning.
  pose proof (static_node1e_warp_contact_y_bounds trigger_y Hcontact)
    as [_ Htrigger].
  unfold floor_search_result_is_admissible,
    find_floor_upward_buffer in Hfloor.
  unfold pyramid_top_spinning_or_rising_y in Hspinning.
  unfold pyramid_top_collision_min_world_y,
    pyramid_top_collision_min_relative_y.
  cbn in Hspinning.
  lia.
Qed.

Theorem platform_requery_after_disappeared_snap_cannot_find_spinning_top :
  forall trigger_y snapped_floor_y object_y top_floor_y,
    disappeared_floor_snap_from_static_warp trigger_y snapped_floor_y ->
    spinning_top_owned_floor_height object_y top_floor_y ->
    ~ floor_search_result_is_admissible snapped_floor_y top_floor_y.
Proof.
  intros trigger_y snapped_floor_y object_y top_floor_y
    Hsnap [Hspinning [Htop_min _]] Hplatform_query.
  pose proof
    (disappeared_snap_from_static_warp_stays_below_top_collision
      trigger_y snapped_floor_y object_y Hsnap Hspinning) as Hbelow.
  destruct Hsnap as [Hcontact Hfirst_query].
  pose proof (static_node1e_warp_contact_y_bounds trigger_y Hcontact)
    as [_ Htrigger].
  unfold floor_search_result_is_admissible,
    find_floor_upward_buffer in Hfirst_query, Hplatform_query.
  unfold pyramid_top_spinning_or_rising_y in Hspinning.
  unfold pyramid_top_collision_min_world_y,
    pyramid_top_collision_min_relative_y in Htop_min, Hbelow.
  cbn in Hspinning.
  lia.
Qed.

Definition mario_within_platform_selection_epsilon
    (mario_y floor_y : Z) : Prop :=
  Z.abs (mario_y - floor_y) < 4.

Inductive platform_floor_observation : Type :=
| PlatformUpdateNoMarioObject
| PlatformUpdateAwayFromFloor
| PlatformUpdateUnownedFloor
| PlatformUpdateOwnedFloor (owner : slot).

Definition update_gMarioPlatform_pointer_model
    (before : option slot) (observation : platform_floor_observation)
    : option slot :=
  match observation with
  | PlatformUpdateNoMarioObject => before
  | PlatformUpdateAwayFromFloor => None
  | PlatformUpdateUnownedFloor => None
  | PlatformUpdateOwnedFloor owner => Some owner
  end.

Theorem update_platform_does_not_require_a_standing_action :
  forall before owner,
    update_gMarioPlatform_pointer_model before
      (PlatformUpdateOwnedFloor owner) = Some owner.
Proof.
  reflexivity.
Qed.

Theorem platform_update_with_mario_returns_top_only_from_top_owned_floor :
  forall before observation,
    observation <> PlatformUpdateNoMarioObject ->
    update_gMarioPlatform_pointer_model before observation =
      Some observed_pyramid_top_slot ->
    observation = PlatformUpdateOwnedFloor observed_pyramid_top_slot.
Proof.
  intros before observation Hmario Hresult.
  destruct observation; cbn in Hresult.
  - contradiction.
  - discriminate.
  - discriminate.
  - inversion Hresult.
    reflexivity.
Qed.

Theorem ordinary_platform_update_away_from_top_clears_a_stale_top_pointer :
  update_gMarioPlatform_pointer_model
      (Some observed_pyramid_top_slot) PlatformUpdateAwayFromFloor = None /\
  update_gMarioPlatform_pointer_model
      (Some observed_pyramid_top_slot) PlatformUpdateUnownedFloor = None.
Proof.
  split; reflexivity.
Qed.

Definition static_pyramid_top_warp_seed_attempt : Prop :=
  exists trigger_y snapped_floor_y object_y top_floor_y,
    jp_static_pyramid_top_warp_source_certificate /\
    disappeared_floor_snap_from_static_warp trigger_y snapped_floor_y /\
    spinning_top_owned_floor_height object_y top_floor_y /\
    floor_search_result_is_admissible snapped_floor_y top_floor_y /\
    mario_within_platform_selection_epsilon snapped_floor_y top_floor_y.

Theorem stock_static_node1e_cannot_trigger_and_seed_exploding_pyramid_top :
  ~ static_pyramid_top_warp_seed_attempt.
Proof.
  intros
    (trigger_y & snapped_floor_y & object_y & top_floor_y &
     certificate & Hsnap & Htop & Hrequery & Hepsilon).
  exact
    (platform_requery_after_disappeared_snap_cannot_find_spinning_top
      trigger_y snapped_floor_y object_y top_floor_y
      Hsnap Htop Hrequery).
Qed.

Theorem stock_warp_update_cannot_preserve_or_create_top_pointer :
  forall before observation trigger_y snapped_floor_y object_y top_floor_y,
    disappeared_floor_snap_from_static_warp trigger_y snapped_floor_y ->
    spinning_top_owned_floor_height object_y top_floor_y ->
    observation <> PlatformUpdateNoMarioObject ->
    (observation = PlatformUpdateOwnedFloor observed_pyramid_top_slot ->
      floor_search_result_is_admissible snapped_floor_y top_floor_y) ->
    update_gMarioPlatform_pointer_model before observation <>
      Some observed_pyramid_top_slot.
Proof.
  intros before observation trigger_y snapped_floor_y object_y top_floor_y
    Hsnap Htop Hmario Hobservation Hresult.
  pose proof
    (platform_update_with_mario_returns_top_only_from_top_owned_floor
      before observation Hmario Hresult) as Howned.
  pose proof (Hobservation Howned) as Hquery.
  exact
    (platform_requery_after_disappeared_snap_cannot_find_spinning_top
      trigger_y snapped_floor_y object_y top_floor_y Hsnap Htop Hquery).
Qed.

Definition mario_object_is_near_loaded_top_floor
    (object_y floor_y mario_y : Z) : Prop :=
  spinning_top_owned_floor_height object_y floor_y /\
  mario_within_platform_selection_epsilon mario_y floor_y.

Theorem mario_object_near_top_can_seed_it_on_its_deactivation_frame :
  forall initial_free_list fields object_y floor_y mario_y,
    mario_object_is_near_loaded_top_floor object_y floor_y mario_y ->
    exists after,
      jp_static_pyramid_top_warp_source_certificate /\
      after = synchronized_last_normal_frame initial_free_list fields /\
      synchronized_top_active after = false /\
      synchronized_top_collision_loaded after = true /\
      synchronized_top_slot_is_free after = true /\
      synchronized_platform_pointer after =
        Some observed_pyramid_top_slot.
Proof.
  intros initial_free_list fields object_y floor_y mario_y _.
  exists (synchronized_last_normal_frame initial_free_list fields).
  split.
  - apply generated_jp_static_pyramid_top_warp_source_certificate.
  - repeat split.
Qed.

Theorem static_pyramid_top_warp_final_frame_capstone :
  jp_static_pyramid_top_warp_source_certificate /\
  (forall (initial_free_list : list slot) (fields : object_fields)
          object_y floor_y mario_y,
    mario_object_is_near_loaded_top_floor object_y floor_y mario_y ->
    exists after,
      synchronized_top_active after = false /\
      synchronized_top_collision_loaded after = true /\
      synchronized_top_slot_is_free after = true /\
      synchronized_platform_pointer after =
        Some observed_pyramid_top_slot) /\
  ~ static_pyramid_top_warp_seed_attempt.
Proof.
  split.
  - apply generated_jp_static_pyramid_top_warp_source_certificate.
  - split.
    + intros initial_free_list fields object_y floor_y mario_y Hstanding.
      destruct
        (mario_object_near_top_can_seed_it_on_its_deactivation_frame
          initial_free_list fields object_y floor_y mario_y Hstanding)
        as (after & _ & _ & Hactive & Hcollision & Hfree & Hplatform).
      exists after.
      repeat split; assumption.
    + apply stock_static_node1e_cannot_trigger_and_seed_exploding_pyramid_top.
Qed.
