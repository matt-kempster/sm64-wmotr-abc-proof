From Coq Require Import List ZArith Lia.
From SSLSpawning.Proofs Require Import Spec JPSpawn PlatformDisplacement
  FreeListReuse SSLFacts PyramidTopWarp ClonedPlatformWarp
  SSLStartCloneRoute.

Import ListNotations.
Local Open Scope Z_scope.

Record area1_warp_hitbox := {
  area1_warp_node : Z;
  area1_warp_x : Z;
  area1_warp_y : Z;
  area1_warp_z : Z;
  area1_warp_radius : Z;
  area1_warp_height : Z
}.

Definition ssl_lower_area1_to_area2_warp : area1_warp_hitbox := {|
  area1_warp_node := 20;
  area1_warp_x := -2048;
  area1_warp_y := 0;
  area1_warp_z := 56;
  area1_warp_radius := 50;
  area1_warp_height := 50
|}.

Definition ssl_top_area1_to_area2_warp : area1_warp_hitbox := {|
  area1_warp_node := 30;
  area1_warp_x := ssl_top_entry_warp_x;
  area1_warp_y := ssl_top_entry_warp_y;
  area1_warp_z := ssl_top_entry_warp_z;
  area1_warp_radius := ssl_top_entry_warp_radius;
  area1_warp_height := ssl_top_entry_warp_height
|}.

Definition ssl_area1_to_area2_warps : list area1_warp_hitbox := [
  ssl_lower_area1_to_area2_warp;
  ssl_top_area1_to_area2_warp
].

Definition area1_warp_low_y (warp : area1_warp_hitbox) : Z :=
  area1_warp_y warp.

Definition area1_warp_high_y (warp : area1_warp_hitbox) : Z :=
  area1_warp_y warp + area1_warp_height warp.

Record platform_bbox := {
  platform_bbox_kind : object_kind;
  platform_bbox_half_x : Z;
  platform_bbox_half_z : Z;
  platform_bbox_min_relative_y : Z;
  platform_bbox_max_relative_y : Z
}.

Definition pyramid_top_bbox : platform_bbox := {|
  platform_bbox_kind := KindPyramidTop;
  platform_bbox_half_x := 512;
  platform_bbox_half_z := 512;
  platform_bbox_min_relative_y := -255;
  platform_bbox_max_relative_y := 256
|}.

Definition tox_box_bbox : platform_bbox := {|
  platform_bbox_kind := KindToxBox;
  platform_bbox_half_x := 256;
  platform_bbox_half_z := 256;
  platform_bbox_min_relative_y := -255;
  platform_bbox_max_relative_y := 256
|}.

Definition exclamation_box_bbox : platform_bbox := {|
  platform_bbox_kind := KindExclamationBox;
  platform_bbox_half_x := exclamation_box_scaled_half_width;
  platform_bbox_half_z := exclamation_box_scaled_half_width;
  platform_bbox_min_relative_y := 0;
  platform_bbox_max_relative_y := exclamation_box_scaled_top_relative_y
|}.

Definition point_in_platform_bbox
    (obj : ssl_object) (bbox : platform_bbox) (x y z : Z) : Prop :=
  within_axis x (ssl_object_x obj) (platform_bbox_half_x bbox) /\
  within_axis z (ssl_object_z obj) (platform_bbox_half_z bbox) /\
  ssl_object_y obj + platform_bbox_min_relative_y bbox <= y <=
  ssl_object_y obj + platform_bbox_max_relative_y bbox.

Definition point_in_warp_bbox
    (warp : area1_warp_hitbox) (mario_hitbox_height x y z : Z) : Prop :=
  within_axis x (area1_warp_x warp) (area1_warp_radius warp) /\
  within_axis z (area1_warp_z warp) (area1_warp_radius warp) /\
  vertical_intervals_overlap
    y (y + mario_hitbox_height)
    (area1_warp_low_y warp) (area1_warp_high_y warp).

Definition platform_bbox_overlaps_warp_bbox
    (obj : ssl_object) (bbox : platform_bbox) (warp : area1_warp_hitbox)
    (mario_hitbox_height : Z) : Prop :=
  exists x y z,
    point_in_platform_bbox obj bbox x y z /\
    point_in_warp_bbox warp mario_hitbox_height x y z.

Ltac solve_no_platform_warp_bbox_overlap :=
  unfold platform_bbox_overlaps_warp_bbox, point_in_platform_bbox,
    point_in_warp_bbox, within_axis, vertical_intervals_overlap,
    area1_warp_low_y, area1_warp_high_y in *;
  intros (x & y & z & Hplatform & Hwarp);
  destruct Hplatform as [[Hpx_min Hpx_max] [[Hpz_min Hpz_max] [Hpy_min Hpy_max]]];
  destruct Hwarp as [[Hwx_min Hwx_max] [[Hwz_min Hwz_max] [Hwy_low Hwy_high]]];
  cbn in *;
  lia.

Theorem ssl_area1_to_area2_warp_nodes_are_fixed_source_warps :
  map area1_warp_node ssl_area1_to_area2_warps = [20; 30].
Proof.
  reflexivity.
Qed.

Theorem original_pyramid_top_does_not_overlap_lower_area1_to_area2_warp :
  ~ platform_bbox_overlaps_warp_bbox
      ssl_pyramid_top pyramid_top_bbox
      ssl_lower_area1_to_area2_warp
      cloned_route_mario_hitbox_height.
Proof.
  solve_no_platform_warp_bbox_overlap.
Qed.

Theorem original_pyramid_top_does_not_overlap_top_area1_to_area2_warp :
  ~ platform_bbox_overlaps_warp_bbox
      ssl_pyramid_top pyramid_top_bbox
      ssl_top_area1_to_area2_warp
      cloned_route_mario_hitbox_height.
Proof.
  solve_no_platform_warp_bbox_overlap.
Qed.

Theorem original_tox_boxes_do_not_overlap_area1_to_area2_warps :
  forall obj warp,
    In obj [ssl_tox_box_1; ssl_tox_box_2; ssl_tox_box_3] ->
    In warp ssl_area1_to_area2_warps ->
    ~ platform_bbox_overlaps_warp_bbox
        obj tox_box_bbox warp cloned_route_mario_hitbox_height.
Proof.
  intros obj warp Hobj Hwarp.
  destruct Hobj as [Hobj | [Hobj | [Hobj | []]]]; subst obj;
    destruct Hwarp as [Hwarp | [Hwarp | []]]; subst warp;
    solve_no_platform_warp_bbox_overlap.
Qed.

Theorem original_exclamation_boxes_do_not_overlap_area1_to_area2_warps :
  forall obj warp,
    In obj ssl_area1_exclamation_box_sources ->
    In warp ssl_area1_to_area2_warps ->
    ~ platform_bbox_overlaps_warp_bbox
        obj exclamation_box_bbox warp cloned_route_mario_hitbox_height.
Proof.
  intros obj warp Hobj Hwarp.
  destruct Hobj as [Hobj | [Hobj | [Hobj | [Hobj | [Hobj | []]]]]];
    subst obj;
    destruct Hwarp as [Hwarp | [Hwarp | []]]; subst warp;
    solve_no_platform_warp_bbox_overlap.
Qed.

Theorem original_area1_seed_platforms_do_not_overlap_area1_to_area2_warps :
  (forall warp,
      In warp ssl_area1_to_area2_warps ->
      ~ platform_bbox_overlaps_warp_bbox
          ssl_pyramid_top pyramid_top_bbox warp
          cloned_route_mario_hitbox_height) /\
  (forall obj warp,
      In obj [ssl_tox_box_1; ssl_tox_box_2; ssl_tox_box_3] ->
      In warp ssl_area1_to_area2_warps ->
      ~ platform_bbox_overlaps_warp_bbox
          obj tox_box_bbox warp cloned_route_mario_hitbox_height) /\
  (forall obj warp,
      In obj ssl_area1_exclamation_box_sources ->
      In warp ssl_area1_to_area2_warps ->
      ~ platform_bbox_overlaps_warp_bbox
          obj exclamation_box_bbox warp cloned_route_mario_hitbox_height).
Proof.
  repeat split.
  - intros warp Hwarp.
    destruct Hwarp as [Hwarp | [Hwarp | []]]; subst warp.
    + apply original_pyramid_top_does_not_overlap_lower_area1_to_area2_warp.
    + apply original_pyramid_top_does_not_overlap_top_area1_to_area2_warp.
  - apply original_tox_boxes_do_not_overlap_area1_to_area2_warps.
  - apply original_exclamation_boxes_do_not_overlap_area1_to_area2_warps.
Qed.

Definition cloned_pyramid_top_at_top_warp : ssl_object := {|
  ssl_object_kind := KindPyramidTop;
  ssl_object_x := ssl_top_entry_warp_x;
  ssl_object_y := ssl_top_entry_warp_y - pyramid_top_collision_max_relative_y;
  ssl_object_z := ssl_top_entry_warp_z
|}.

Theorem cloned_pyramid_top_bbox_can_overlap_top_entry_warp :
  platform_bbox_overlaps_warp_bbox
    cloned_pyramid_top_at_top_warp
    pyramid_top_bbox
    ssl_top_area1_to_area2_warp
    cloned_route_mario_hitbox_height.
Proof.
  exists ssl_top_entry_warp_x, ssl_top_entry_warp_y, ssl_top_entry_warp_z.
  vm_compute.
  repeat split; discriminate.
Qed.

Definition area1_source_platform_kind (kind : object_kind) : bool :=
  match kind with
  | KindPyramidTop => true
  | KindToxBox => true
  | KindExclamationBox => true
  | _ => false
  end.

Definition platform_bbox_for_source_platform_kind
    (kind : object_kind) : platform_bbox :=
  match kind with
  | KindPyramidTop => pyramid_top_bbox
  | KindToxBox => tox_box_bbox
  | KindExclamationBox => exclamation_box_bbox
  | _ => exclamation_box_bbox
  end.

Definition transported_source_platform_at_top_warp
    (kind : object_kind) : ssl_object := {| 
  ssl_object_kind := kind;
  ssl_object_x := ssl_top_entry_warp_x;
  ssl_object_y :=
    ssl_top_entry_warp_y -
    platform_bbox_max_relative_y
      (platform_bbox_for_source_platform_kind kind);
  ssl_object_z := ssl_top_entry_warp_z
|}.

Theorem transported_source_platform_kind_bbox_can_overlap_top_entry_warp :
  forall kind,
    area1_source_platform_kind kind = true ->
    platform_bbox_kind (platform_bbox_for_source_platform_kind kind) = kind /\
    platform_bbox_overlaps_warp_bbox
      (transported_source_platform_at_top_warp kind)
      (platform_bbox_for_source_platform_kind kind)
      ssl_top_area1_to_area2_warp
      cloned_route_mario_hitbox_height.
Proof.
  intros kind Hkind.
  destruct kind; try discriminate.
  all:
    split; [reflexivity |];
    exists ssl_top_entry_warp_x, ssl_top_entry_warp_y, ssl_top_entry_warp_z;
    vm_compute; repeat split; discriminate.
Qed.

Record area1_source_platform_seed
    (state : game_state) (watched : slot) (kind : object_kind) : Prop := {
  source_seed_kind :
    area1_source_platform_kind kind = true;
  source_seed_platform_pointer :
    state_gMarioPlatform state = Some watched
}.

Definition source_seed_spindel_first_update_state
    (seed_state : game_state) (watched : slot) : game_state := {|
  state_mario := state_mario seed_state;
  state_gMarioPlatform := Some watched;
  state_has_mario_object := true;
  state_time_stop_active := false;
  state_object_memory :=
    object_memory_with watched
      (spindel_active_fields 1 SpindelForward);
  state_free_list := []
|}.

Theorem any_area1_source_platform_seed_feeds_spindel_if_reused :
  forall seed_state watched kind free_list,
    area1_source_platform_seed seed_state watched kind ->
    nth_allocation_reuses_slot
      free_list ssl_area2_spindel_allocation_index watched ->
    exists after_jp_spawn first_update_state observation,
      after_jp_spawn = spawn_objects_from_info_jp_model seed_state /\
      state_gMarioPlatform after_jp_spawn = Some watched /\
      first_update_state =
        source_seed_spindel_first_update_state seed_state watched /\
      apply_mario_platform_displacement_model first_update_state =
        Some observation /\
      observation_slot observation = watched /\
      observation_oVelZ observation = 20 /\
      observation_oAngleVelPitch observation = 1024.
Proof.
  intros seed_state watched kind free_list Hseed _Hreuse.
  exists (spawn_objects_from_info_jp_model seed_state).
  exists (source_seed_spindel_first_update_state seed_state watched).
  exists (observe_platform_fields watched
    (spindel_active_fields 1 SpindelForward)).
  destruct Hseed as [_ Hplatform].
  split.
  - reflexivity.
  - split.
    + rewrite jp_spawn_preserves_gMarioPlatform.
      exact Hplatform.
    + split.
      * reflexivity.
      * split.
        -- unfold apply_mario_platform_displacement_model,
             source_seed_spindel_first_update_state, object_memory_with.
           cbn.
           rewrite Z.eqb_refl.
           reflexivity.
        -- split.
          ++ reflexivity.
          ++ split; vm_compute; reflexivity.
Qed.
