From Coq Require Import List Lia.

Import ListNotations.

Inductive update_event : Type :=
| UpdateClearDynamicSurfaces
| UpdateTerrainObjects
| UpdateApplyMarioPlatformDisplacement
| UpdateDetectObjectCollisions
| UpdateNonTerrainObjects
| UpdateUnloadDeactivatedObjects
| UpdateMarioPlatform.

Definition update_objects_order : list update_event := [
  UpdateClearDynamicSurfaces;
  UpdateTerrainObjects;
  UpdateApplyMarioPlatformDisplacement;
  UpdateDetectObjectCollisions;
  UpdateNonTerrainObjects;
  UpdateUnloadDeactivatedObjects;
  UpdateMarioPlatform
].

Definition event_index (event : update_event) : nat :=
  match event with
  | UpdateClearDynamicSurfaces => 0
  | UpdateTerrainObjects => 1
  | UpdateApplyMarioPlatformDisplacement => 2
  | UpdateDetectObjectCollisions => 3
  | UpdateNonTerrainObjects => 4
  | UpdateUnloadDeactivatedObjects => 5
  | UpdateMarioPlatform => 6
  end.

Theorem update_objects_order_matches_source_sequence :
  update_objects_order = [
    UpdateClearDynamicSurfaces;
    UpdateTerrainObjects;
    UpdateApplyMarioPlatformDisplacement;
    UpdateDetectObjectCollisions;
    UpdateNonTerrainObjects;
    UpdateUnloadDeactivatedObjects;
    UpdateMarioPlatform
  ].
Proof.
  reflexivity.
Qed.

Theorem apply_mario_platform_displacement_before_update_mario_platform :
  event_index UpdateApplyMarioPlatformDisplacement <
  event_index UpdateMarioPlatform.
Proof.
  simpl.
  lia.
Qed.

Theorem first_object_update_applies_before_platform_recompute :
  event_index UpdateApplyMarioPlatformDisplacement <
  event_index UpdateMarioPlatform.
Proof.
  apply apply_mario_platform_displacement_before_update_mario_platform.
Qed.

Theorem terrain_objects_update_before_platform_displacement :
  event_index UpdateTerrainObjects <
  event_index UpdateApplyMarioPlatformDisplacement.
Proof.
  simpl.
  lia.
Qed.
