From Coq Require Import List ZArith Lia.
From SSLSpawning.Proofs Require Import FreeListReuse SSLFacts.

Import ListNotations.
Local Open Scope Z_scope.

Inductive level_id : Type :=
| LevelCastle
| LevelSSL
| LevelOther.

Record warp_destination := {
  warp_dest_level : level_id;
  warp_dest_area : Z;
  warp_dest_node : Z
}.

Definition castle_ssl_painting_warp_nodes : list Z := [15; 16; 17].

Definition castle_ssl_painting_base_destination : warp_destination := {|
  warp_dest_level := LevelSSL;
  warp_dest_area := 1;
  warp_dest_node := 10
|}.

Definition ssl_area2_checkpoint_destination (node : Z) : warp_destination := {|
  warp_dest_level := LevelSSL;
  warp_dest_area := 2;
  warp_dest_node := node
|}.

Definition checkpoint_redirects_castle_ssl_painting
    (checkpoint_node : Z) : warp_destination :=
  ssl_area2_checkpoint_destination checkpoint_node.

Theorem castle_ssl_painting_nodes_target_ssl_area1_before_checkpoint :
  forall node,
    In node castle_ssl_painting_warp_nodes ->
    castle_ssl_painting_base_destination = {|
      warp_dest_level := LevelSSL;
      warp_dest_area := 1;
      warp_dest_node := 10
    |}.
Proof.
  intros _ _.
  reflexivity.
Qed.

Theorem active_ssl_checkpoint_redirects_castle_ssl_painting_to_area2 :
  forall checkpoint_node,
    warp_dest_level
      (checkpoint_redirects_castle_ssl_painting checkpoint_node) = LevelSSL /\
    warp_dest_area
      (checkpoint_redirects_castle_ssl_painting checkpoint_node) = 2 /\
    warp_dest_node
      (checkpoint_redirects_castle_ssl_painting checkpoint_node) =
      checkpoint_node.
Proof.
  intros checkpoint_node.
  repeat split.
Qed.

Inductive surface_type_class : Type :=
| SurfacePaintingWarp
| SurfaceNonPaintingWarp.

Inductive floor_owner_class : Type :=
| FloorStaticTerrain
| FloorObjectOwned.

Record floor_sample := {
  floor_sample_type : surface_type_class;
  floor_sample_owner : floor_owner_class
}.

Definition floor_can_trigger_painting_entry (floor : floor_sample) : Prop :=
  floor_sample_type floor = SurfacePaintingWarp.

Definition floor_can_set_gMarioPlatform (floor : floor_sample) : Prop :=
  floor_sample_owner floor = FloorObjectOwned.

Definition static_ssl_painting_floor : floor_sample := {|
  floor_sample_type := SurfacePaintingWarp;
  floor_sample_owner := FloorStaticTerrain
|}.

Record ordinary_synchronized_floor_seed
    (painting_floor platform_floor : floor_sample) : Prop := {
  ordinary_seed_same_floor :
    painting_floor = platform_floor;
  ordinary_seed_enters_painting :
    floor_can_trigger_painting_entry painting_floor;
  ordinary_seed_sets_platform :
    floor_can_set_gMarioPlatform platform_floor
}.

Theorem ordinary_painting_seed_requires_object_owned_painting_warp_floor :
  forall painting_floor platform_floor,
    ordinary_synchronized_floor_seed painting_floor platform_floor ->
    floor_can_trigger_painting_entry painting_floor /\
    floor_can_set_gMarioPlatform painting_floor.
Proof.
  intros painting_floor platform_floor Hseed.
  destruct Hseed as [Hsame Hpainting Hplatform].
  subst platform_floor.
  split; assumption.
Qed.

Theorem static_ssl_painting_floor_cannot_set_gMarioPlatform :
  ~ floor_can_set_gMarioPlatform static_ssl_painting_floor.
Proof.
  unfold floor_can_set_gMarioPlatform, static_ssl_painting_floor.
  cbn.
  discriminate.
Qed.

Inductive audited_castle_object_surface : Type :=
| CastleStarDoorSurface
| CastleFloorTrapSurface
| CastleWaterLevelPillarSurface
| CastleDDDWarpSurface.

Definition audited_castle_object_floor
    (_surface : audited_castle_object_surface) : floor_sample := {|
  floor_sample_type := SurfaceNonPaintingWarp;
  floor_sample_owner := FloorObjectOwned
|}.

Theorem audited_castle_object_surfaces_are_not_painting_warp_floors :
  forall surface,
    ~ floor_can_trigger_painting_entry
        (audited_castle_object_floor surface).
Proof.
  intros surface Hpainting.
  destruct surface; unfold floor_can_trigger_painting_entry,
    audited_castle_object_floor in Hpainting; cbn in Hpainting;
    discriminate.
Qed.

Inductive castle_checkpoint_seed_mechanism : Type :=
| CastleStaticPaintingWarpFloor
| CastleAuditedObjectSurface
    (surface : audited_castle_object_surface).

Definition castle_checkpoint_seed_mechanism_can_seed_platform
    (mechanism : castle_checkpoint_seed_mechanism) : Prop :=
  match mechanism with
  | CastleStaticPaintingWarpFloor =>
      floor_can_set_gMarioPlatform static_ssl_painting_floor
  | CastleAuditedObjectSurface surface =>
      ordinary_synchronized_floor_seed
        (audited_castle_object_floor surface)
        (audited_castle_object_floor surface)
  end.

Theorem castle_checkpoint_seed_mechanisms_do_not_seed_gMarioPlatform :
  forall mechanism,
    ~ castle_checkpoint_seed_mechanism_can_seed_platform mechanism.
Proof.
  intros mechanism Hseed.
  destruct mechanism as [| surface].
  - exact (static_ssl_painting_floor_cannot_set_gMarioPlatform Hseed).
  - destruct Hseed as [_ Hpainting _].
    exact
      (audited_castle_object_surfaces_are_not_painting_warp_floors
        surface Hpainting).
Qed.

Record castle_checkpoint_spindel_route
    (mechanism : castle_checkpoint_seed_mechanism) : Prop := {
  castle_checkpoint_route_seed :
    castle_checkpoint_seed_mechanism_can_seed_platform mechanism;
  castle_checkpoint_route_spindel_depth :
    exists watched free_list,
      nth_allocation_reuses_slot
        free_list ssl_area2_spindel_allocation_index watched
}.

Theorem castle_checkpoint_painting_route_cannot_seed_spawning_displacement :
  forall mechanism,
    ~ castle_checkpoint_spindel_route mechanism.
Proof.
  intros mechanism Hroute.
  destruct Hroute as [Hseed _].
  exact
    (castle_checkpoint_seed_mechanisms_do_not_seed_gMarioPlatform
      mechanism Hseed).
Qed.

Definition castle_checkpoint_route_escape_hatch : Prop :=
  exists painting_floor platform_floor,
    painting_floor <> platform_floor /\
    floor_can_trigger_painting_entry painting_floor /\
    floor_can_set_gMarioPlatform platform_floor.

Theorem any_positive_castle_checkpoint_seed_needs_floor_desync_or_new_surface :
  (exists surface,
      ordinary_synchronized_floor_seed
        (audited_castle_object_floor surface)
        (audited_castle_object_floor surface)) \/
  floor_can_set_gMarioPlatform static_ssl_painting_floor ->
  False.
Proof.
  intros [Hobject | Hstatic].
  - destruct Hobject as [surface Hseed].
    destruct Hseed as [_ Hpainting _].
    exact
      (audited_castle_object_surfaces_are_not_painting_warp_floors
        surface Hpainting).
  - exact (static_ssl_painting_floor_cannot_set_gMarioPlatform Hstatic).
Qed.
