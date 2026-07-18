From Coq Require Import Lia ZArith.
From compcert Require Import Clight.
From SSLPU.Generated Require Import mario_step platform_displacement.
From SSLPU.Proofs Require Import ASTFacts Spec.

Local Open Scope Z_scope.

Record generated_movement_source_shape : Prop := {
  shape_air_step_calls_air_quarter_step :
    ident_mem mario_step._perform_air_quarter_step
      (direct_callees_s (fn_body mario_step.f_perform_air_step)) = true;
  shape_air_quarter_step_assigns_mario_pos :
    assigns_through_field_s mario_step._pos
      (fn_body mario_step.f_perform_air_quarter_step) = true;
  shape_platform_displacement_calls_set_mario_pos :
    ident_mem platform_displacement._set_mario_pos
      (direct_callees_s
        (fn_body platform_displacement.f_apply_platform_displacement)) = true;
  shape_apply_mario_platform_calls_platform_displacement :
    ident_mem platform_displacement._apply_platform_displacement
      (direct_callees_s
        (fn_body platform_displacement.f_apply_mario_platform_displacement)) =
      true;
  shape_set_mario_pos_assigns_mario_pos :
    assigns_through_field_s platform_displacement._pos
      (fn_body platform_displacement.f_set_mario_pos) = true
}.

Theorem generated_movement_source_shape_holds :
  generated_movement_source_shape.
Proof.
  constructor; vm_compute; reflexivity.
Qed.

Definition unclamped_air_velocity_step
    (state : pu_state) (vx vz : Z) : pu_state :=
  {|
    state_area := state_area state;
    state_x := state_x state + vx / 4;
    state_z := state_z state + vz / 4
  |}.

Definition platform_displacement_step
    (state : pu_state) (dx dz : Z) : pu_state :=
  {|
    state_area := state_area state;
    state_x := state_x state + dx;
    state_z := state_z state + dz
  |}.

Definition threshold_edge_state : pu_state :=
  {|
    state_area := ssl_area2;
    state_x := ssl_area2_max;
    state_z := 0
  |}.

Definition air_x_velocity_to_first_pu : Z :=
  4 * (first_parallel_universe - ssl_area2_max).

Definition platform_x_displacement_to_first_pu : Z :=
  first_parallel_universe - ssl_area2_max.

Lemma threshold_edge_state_in_area2_bounds :
  state_in_area2_bounds threshold_edge_state.
Proof.
  unfold state_in_area2_bounds, coord_in_area2_bounds,
    threshold_edge_state.
  simpl.
  split.
  - reflexivity.
  - split; unfold ssl_area2_min, ssl_area2_max; lia.
Qed.

Theorem unclamped_air_velocity_source_can_enter_parallel_universe :
  exists before after vx,
    state_in_area2_bounds before /\
    after = unclamped_air_velocity_step before vx 0 /\
    state_in_parallel_universe after.
Proof.
  exists threshold_edge_state.
  exists (unclamped_air_velocity_step
    threshold_edge_state air_x_velocity_to_first_pu 0).
  exists air_x_velocity_to_first_pu.
  split.
  - exact threshold_edge_state_in_area2_bounds.
  - split.
    + reflexivity.
    + left.
      unfold unclamped_air_velocity_step, threshold_edge_state,
        air_x_velocity_to_first_pu, parallel_universe_coord,
        first_parallel_universe, ssl_area2_max.
      simpl.
      replace (8191 + 4 * (32768 - 8191) / 4) with 32768
        by (vm_compute; reflexivity).
      lia.
Qed.

Theorem platform_displacement_source_can_enter_parallel_universe :
  exists before after dx,
    state_in_area2_bounds before /\
    after = platform_displacement_step before dx 0 /\
    state_in_parallel_universe after.
Proof.
  exists threshold_edge_state.
  exists (platform_displacement_step
    threshold_edge_state platform_x_displacement_to_first_pu 0).
  exists platform_x_displacement_to_first_pu.
  split.
  - exact threshold_edge_state_in_area2_bounds.
  - split.
    + reflexivity.
    + left.
      unfold platform_displacement_step, threshold_edge_state,
        platform_x_displacement_to_first_pu, parallel_universe_coord,
        first_parallel_universe, ssl_area2_max.
      simpl.
      replace (8191 + (32768 - 8191)) with 32768 by lia.
      lia.
Qed.

Theorem bounded_certificate_does_not_cover_movement_sources :
  generated_movement_source_shape /\
  (exists before after vx,
    state_in_area2_bounds before /\
    after = unclamped_air_velocity_step before vx 0 /\
    state_in_parallel_universe after) /\
  (exists before after dx,
    state_in_area2_bounds before /\
    after = platform_displacement_step before dx 0 /\
    state_in_parallel_universe after).
Proof.
  split.
  - exact generated_movement_source_shape_holds.
  - split.
    + exact unclamped_air_velocity_source_can_enter_parallel_universe.
    + exact platform_displacement_source_can_enter_parallel_universe.
Qed.
