From Coq Require Import List ZArith.
From SSLSpawning.Proofs Require Import FreeListReuse SSLFacts
  SourcePlatformOverlap SourcePlatformTransport MarioSpeedWarp
  DesyncMechanismSearch.

Local Open Scope Z_scope.

Inductive closed_world_seed_mechanism : Type :=
| ClosedWorldOriginalSpawnedSurface
| ClosedWorldModeledSourceTransport
    (mechanism : modeled_source_platform_transport)
| ClosedWorldOrdinaryMarioSpeed
| ClosedWorldInvestigatedDesync
    (mechanism : investigated_desync_mechanism).

Definition closed_world_seed_mechanism_can_set_platform_at_area2_warp
    (mechanism : closed_world_seed_mechanism) : Prop :=
  match mechanism with
  | ClosedWorldOriginalSpawnedSurface =>
      original_area1_source_platform_overlap
  | ClosedWorldModeledSourceTransport mechanism =>
      modeled_transport_can_leave_standable_surface_at_area2_warp mechanism
  | ClosedWorldOrdinaryMarioSpeed =>
      ordinary_mario_speed_can_seed_warp_platform_overlap
  | ClosedWorldInvestigatedDesync mechanism =>
      investigated_mechanism_can_seed_warp_platform_overlap mechanism
  end.

Theorem closed_world_seed_mechanisms_do_not_set_platform_at_area2_warp :
  forall mechanism,
    ~ closed_world_seed_mechanism_can_set_platform_at_area2_warp mechanism.
Proof.
  intros mechanism Hseed.
  destruct mechanism as [| mechanism | | mechanism].
  - exact (original_area1_source_platform_overlap_is_impossible Hseed).
  - exact (modeled_source_platform_transport_mechanisms_do_not_seed_warp
      mechanism Hseed).
  - exact (ordinary_mario_speed_cannot_replace_platform_warp_overlap Hseed).
  - exact (investigated_desync_mechanisms_do_not_currently_seed_overlap
      mechanism Hseed).
Qed.

Record closed_world_spindel_depth_route
    (mechanism : closed_world_seed_mechanism) : Prop := {
  closed_world_route_seed :
    closed_world_seed_mechanism_can_set_platform_at_area2_warp mechanism;
  closed_world_route_spindel_depth :
    exists watched free_list,
      nth_allocation_reuses_slot
        free_list ssl_area2_spindel_allocation_index watched
}.

Theorem no_closed_world_ssl_spawning_displacement_route_to_spindel :
  forall mechanism,
    ~ closed_world_spindel_depth_route mechanism.
Proof.
  intros mechanism Hroute.
  destruct Hroute as [Hseed _].
  exact
    (closed_world_seed_mechanisms_do_not_set_platform_at_area2_warp
      mechanism Hseed).
Qed.
