From Coq Require Import ZArith.

Local Open Scope Z_scope.

Definition ssl_area2 : Z := 2.
Definition pole_x : Z := 0.
Definition pole_base_y : Z := 3200.
Definition pole_z : Z := 1331.
Definition pole_parameter : Z := 92.
Definition pole_hitbox_height : Z := pole_parameter * 10.
Definition pole_top_offset : Z := 100.
Definition pole_top_y : Z := pole_base_y + pole_hitbox_height - pole_top_offset.

Definition sixth_floor_y : Z := 3942.
Definition hole_west_clearance : Z := 101.
Definition ring_west_outer_radius : Z := 1535.

Definition pole_push_radius : Z := 70.
Definition non_a_speed_upper : Z := 2.
Definition normal_gravity : Z := 4.
Definition jump_vertical_speed : Z := 62.
Definition jump_initial_speed : Z := 24.
Definition jump_first_five_speed_lower : Z := 22.

Definition soft_height_upper (frames : Z) : Z :=
  pole_top_y - 2 * frames * (frames - 1).

(* The source push maps an inside-radius point no farther than radius 70;
   granting that full radius before every two-unit air frame is conservative. *)
Definition soft_radius_upper (frames : Z) : Z :=
  pole_push_radius + non_a_speed_upper * frames.

Definition jump_height (frames : Z) : Z :=
  pole_top_y + jump_vertical_speed * frames - 2 * frames * (frames - 1).

Definition jump_west_distance_lower (frames : Z) : Z :=
  jump_first_five_speed_lower * Z.min frames 5.

Definition jump_distance_upper (frames : Z) : Z := jump_initial_speed * frames.

Definition soft_clearable (frames : Z) : Prop :=
  hole_west_clearance <= soft_radius_upper frames /\
  sixth_floor_y <= soft_height_upper frames.

Definition jump_landing_window (frames : Z) : Prop :=
  hole_west_clearance <= jump_west_distance_lower frames /\
  jump_distance_upper frames <= ring_west_outer_radius /\
  sixth_floor_y <= jump_height frames /\
  jump_height (frames + 1) < sixth_floor_y.

Theorem pole_geometry_constants :
  pole_hitbox_height = 920 /\ pole_top_y = 4020 /\
  pole_top_y - sixth_floor_y = 78.
Proof. repeat split; reflexivity. Qed.
