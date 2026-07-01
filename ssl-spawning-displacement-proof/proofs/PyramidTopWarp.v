From Coq Require Import ZArith Lia.
From SSLSpawning.Proofs Require Import SSLFacts.

Local Open Scope Z_scope.

Definition ssl_top_entry_warp_x : Z := -2048.
Definition ssl_top_entry_warp_y : Z := 768.
Definition ssl_top_entry_warp_z : Z := -1024.
Definition ssl_top_entry_warp_bparam1 : Z := 15.

Definition warp_radius_from_bparam1 (bparam1 : Z) : Z :=
  if Z.eqb bparam1 0 then 50
  else if Z.eqb bparam1 255 then 10000
  else bparam1 * 10.

Definition ssl_top_entry_warp_radius : Z :=
  warp_radius_from_bparam1 ssl_top_entry_warp_bparam1.

Definition ssl_top_entry_warp_height : Z := 50.
Definition ssl_top_entry_warp_down_offset : Z := 0.

Definition hitbox_low_y (object_y down_offset : Z) : Z :=
  object_y - down_offset.

Definition hitbox_high_y (object_y height down_offset : Z) : Z :=
  hitbox_low_y object_y down_offset + height.

Definition ssl_top_entry_warp_low_y : Z :=
  hitbox_low_y ssl_top_entry_warp_y ssl_top_entry_warp_down_offset.

Definition ssl_top_entry_warp_high_y : Z :=
  hitbox_high_y
    ssl_top_entry_warp_y
    ssl_top_entry_warp_height
    ssl_top_entry_warp_down_offset.

Definition pyramid_top_collision_min_relative_y : Z := -255.
Definition pyramid_top_collision_max_relative_y : Z := 256.

Definition pyramid_top_collision_min_world_y (object_y : Z) : Z :=
  object_y + pyramid_top_collision_min_relative_y.

Definition pyramid_top_collision_max_world_y (object_y : Z) : Z :=
  object_y + pyramid_top_collision_max_relative_y.

Definition pyramid_top_spinning_or_rising_y (object_y : Z) : Prop :=
  ssl_object_y ssl_pyramid_top <= object_y.

Definition mario_stands_on_pyramid_top_collision_y
    (mario_y object_y : Z) : Prop :=
  pyramid_top_collision_min_world_y object_y <= mario_y.

Definition vertical_intervals_overlap
    (low_a high_a low_b high_b : Z) : Prop :=
  low_a <= high_b /\ low_b <= high_a.

Definition mario_hitbox_overlaps_top_entry_warp_y
    (mario_y mario_hitbox_height : Z) : Prop :=
  vertical_intervals_overlap
    mario_y
    (mario_y + mario_hitbox_height)
    ssl_top_entry_warp_low_y
    ssl_top_entry_warp_high_y.

Definition horizontal_distance_squared
    (x1 z1 x2 z2 : Z) : Z :=
  (x1 - x2) * (x1 - x2) + (z1 - z2) * (z1 - z2).

Theorem ssl_top_entry_warp_radius_is_150 :
  ssl_top_entry_warp_radius = 150.
Proof.
  reflexivity.
Qed.

Theorem ssl_top_entry_warp_vertical_interval_is_768_to_818 :
  ssl_top_entry_warp_low_y = 768 /\
  ssl_top_entry_warp_high_y = 818.
Proof.
  split; reflexivity.
Qed.

Theorem ssl_pyramid_top_home_collision_min_world_y_is_1281 :
  pyramid_top_collision_min_world_y
    (ssl_object_y ssl_pyramid_top) = 1281.
Proof.
  reflexivity.
Qed.

Theorem ssl_pyramid_top_home_collision_max_world_y_is_1792 :
  pyramid_top_collision_max_world_y
    (ssl_object_y ssl_pyramid_top) = 1792.
Proof.
  reflexivity.
Qed.

Theorem ssl_top_entry_warp_is_horizontally_aligned_with_pyramid_top_center :
  horizontal_distance_squared
    ssl_top_entry_warp_x
    ssl_top_entry_warp_z
    (ssl_object_x ssl_pyramid_top)
    (ssl_object_z ssl_pyramid_top) = 2.
Proof.
  reflexivity.
Qed.

Theorem ssl_top_entry_warp_horizontal_radius_contains_pyramid_top_center :
  horizontal_distance_squared
    ssl_top_entry_warp_x
    ssl_top_entry_warp_z
    (ssl_object_x ssl_pyramid_top)
    (ssl_object_z ssl_pyramid_top) <
  ssl_top_entry_warp_radius * ssl_top_entry_warp_radius.
Proof.
  rewrite ssl_top_entry_warp_is_horizontally_aligned_with_pyramid_top_center.
  rewrite ssl_top_entry_warp_radius_is_150.
  lia.
Qed.

Theorem spinning_pyramid_top_collision_min_above_top_entry_warp :
  forall object_y,
    pyramid_top_spinning_or_rising_y object_y ->
    ssl_top_entry_warp_high_y <
    pyramid_top_collision_min_world_y object_y.
Proof.
  intros object_y Hspinning.
  unfold pyramid_top_spinning_or_rising_y in Hspinning.
  unfold ssl_top_entry_warp_high_y, hitbox_high_y, hitbox_low_y.
  unfold pyramid_top_collision_min_world_y,
    pyramid_top_collision_min_relative_y.
  simpl in *.
  lia.
Qed.

Theorem standing_on_spinning_pyramid_top_does_not_overlap_top_entry_warp_y :
  forall object_y mario_y mario_hitbox_height,
    pyramid_top_spinning_or_rising_y object_y ->
    mario_stands_on_pyramid_top_collision_y mario_y object_y ->
    ~ mario_hitbox_overlaps_top_entry_warp_y
        mario_y mario_hitbox_height.
Proof.
  intros object_y mario_y mario_hitbox_height Hspinning Hstanding Hoverlap.
  unfold mario_hitbox_overlaps_top_entry_warp_y,
    vertical_intervals_overlap in Hoverlap.
  destruct Hoverlap as [HmarioBelowWarpTop _].
  pose proof
    (spinning_pyramid_top_collision_min_above_top_entry_warp
      object_y Hspinning) as HtopBelowPlatform.
  unfold mario_stands_on_pyramid_top_collision_y in Hstanding.
  lia.
Qed.

Definition can_enter_top_entry_warp_while_setting_pyramid_top_platform
    (object_y mario_y mario_hitbox_height : Z) : Prop :=
  pyramid_top_spinning_or_rising_y object_y /\
  mario_stands_on_pyramid_top_collision_y mario_y object_y /\
  mario_hitbox_overlaps_top_entry_warp_y mario_y mario_hitbox_height.

Theorem cannot_enter_top_entry_warp_while_standing_on_spinning_pyramid_top :
  forall object_y mario_y mario_hitbox_height,
    ~ can_enter_top_entry_warp_while_setting_pyramid_top_platform
        object_y mario_y mario_hitbox_height.
Proof.
  intros object_y mario_y mario_hitbox_height Hcan.
  destruct Hcan as [Hspinning [Hstanding Hoverlap]].
  eapply standing_on_spinning_pyramid_top_does_not_overlap_top_entry_warp_y;
    eauto.
Qed.
