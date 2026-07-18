From Coq Require Import Lia ZArith.
From SSLEyerok.Proofs Require Import Area2Route RouteModel Spec.

Local Open Scope Z_scope.

(** A counterfactual route certificate: if a hand origin could reach 3627,
    its conservative 507-unit collision top would support the departure below.
    The authentic reachability proof separately shows that this premise is
    impossible in the audited source-shaped model. *)

Definition upper_shortcut_hand_origin_required : Z := 3627.
Definition upper_shortcut_departure_y : Z := 4134.

Definition fixed_twenty_frame_first_qstep_y4 (origin_y : Z) : Z :=
  4 * (origin_y + hand_collision_top_max + 220) - 10.

(** The air step moves one quarter of vertical velocity before its fresh floor
    query.  Scaling Y by four avoids fractions.  The query must truncate to at
    least 4351, hence [4*4351 <= y4]. *)
Lemma fixed_twenty_frame_upper_entry_minimum : forall origin_y,
  4 * 4351 <= fixed_twenty_frame_first_qstep_y4 origin_y <->
  upper_shortcut_hand_origin_required <= origin_y.
Proof.
  intros origin_y.
  unfold fixed_twenty_frame_first_qstep_y4,
    upper_shortcut_hand_origin_required, hand_collision_top_max.
  lia.
Qed.

Lemma fixed_twenty_frame_threshold_and_predecessor_values :
  fixed_twenty_frame_first_qstep_y4
    upper_shortcut_hand_origin_required / 4 = 4351 /\
  fixed_twenty_frame_first_qstep_y4
    (upper_shortcut_hand_origin_required - 1) / 4 = 4350.
Proof. vm_compute. split; reflexivity. Qed.

Definition counterfactual_upper_departure : mario_route_state :=
  {| route_area := Area3;
     route_x := 192;
     route_y := upper_shortcut_departure_y;
     route_z := -1993;
     route_vx := 0;
     route_vy := 30;
     route_vz := 48;
     route_floor_of := HandSurface;
     route_motion_of := RouteAirborne |}.

Definition counterfactual_upper_prewarp : mario_route_state :=
  controlled_air_frames 20 0 48 2 counterfactual_upper_departure.

Definition counterfactual_upper_warp : mario_route_state :=
  with_floor counterfactual_upper_prewarp Area3Warp1D.

Definition counterfactual_upper_entry : mario_route_state :=
  enter_area2 counterfactual_upper_warp.

Lemma counterfactual_upper_entry_values :
  upper_shortcut_hand_origin_required + hand_collision_top_max =
    upper_shortcut_departure_y /\
  route_x counterfactual_upper_entry = 192 /\
  route_y counterfactual_upper_entry = 4354 /\
  route_z counterfactual_upper_entry = -1033 /\
  route_vy counterfactual_upper_entry = -10.
Proof. vm_compute. repeat split; reflexivity. Qed.

Lemma counterfactual_upper_entry_selects_4429 :
  arrival_floor_selection counterfactual_upper_entry Area2Upper4429.
Proof.
  apply arrival_select_upper.
  - reflexivity.
  - vm_compute. repeat split; discriminate.
  - unfold floor_query_eligible. vm_compute. discriminate.
Qed.

Lemma counterfactual_upper_entry_is_instant_warp :
  instant_warp_step counterfactual_upper_warp counterfactual_upper_entry.
Proof. constructor; reflexivity. Qed.

Definition first_air_quarter_query (before : mario_route_state)
    : mario_route_state :=
  {| route_area := route_area before;
     route_x := (4 * route_x before + route_vx before) / 4;
     route_y := (4 * route_y before + route_vy before) / 4;
     route_z := (4 * route_z before + route_vz before) / 4;
     route_vx := route_vx before;
     route_vy := route_vy before;
     route_vz := route_vz before;
     route_floor_of := FloorPending;
     route_motion_of := RouteAirborne |}.

Definition snap_to_upper4429 (before : mario_route_state)
    : mario_route_state :=
  let query := first_air_quarter_query before in
  {| route_area := Area2;
     route_x := route_x query;
     route_y := 4429;
     route_z := route_z query;
     route_vx := route_vx before;
     route_vy := 0;
     route_vz := route_vz before;
     route_floor_of := Area2Upper4429;
     route_motion_of := RouteGrounded |}.

Definition counterfactual_upper_landing : mario_route_state :=
  snap_to_upper4429 counterfactual_upper_entry.

Definition can_land_on_selected_upper (before : mario_route_state) : Prop :=
  arrival_floor_selection before Area2Upper4429 /\
  route_vy before <= 0 /\
  in_area2_upper_overlap (first_air_quarter_query before) /\
  floor_query_eligible
    (route_y (first_air_quarter_query before)) 4429 /\
  route_y (first_air_quarter_query before) <= 4429.

Inductive selected_upper_landing_step
    : mario_route_state -> mario_route_state -> Prop :=
| land_on_selected_upper : forall before,
    can_land_on_selected_upper before ->
    selected_upper_landing_step before (snap_to_upper4429 before).

Lemma counterfactual_upper_entry_lands_on_4429 :
  selected_upper_landing_step
    counterfactual_upper_entry counterfactual_upper_landing.
Proof.
  constructor. split.
  - exact counterfactual_upper_entry_selects_4429.
  - vm_compute. repeat split; discriminate.
Qed.

Lemma counterfactual_first_quarter_query_values :
  route_x (first_air_quarter_query counterfactual_upper_entry) = 192 /\
  route_y (first_air_quarter_query counterfactual_upper_entry) = 4351 /\
  route_z (first_air_quarter_query counterfactual_upper_entry) = -1021.
Proof. vm_compute. repeat split; reflexivity. Qed.

Definition in_area2_star_platform (state : mario_route_state) : Prop :=
  between 387 (route_x state) 643 /\
  between (-1125) (route_z state) (-409).

Definition begin_controlled_jump
    (dx dz velocity_y : Z) (before : mario_route_state)
    : mario_route_state :=
  {| route_area := route_area before;
     route_x := route_x before;
     route_y := route_y before;
     route_z := route_z before;
     route_vx := dx;
     route_vy := velocity_y;
     route_vz := dz;
     route_floor_of := route_floor_of before;
     route_motion_of := RouteAirborne |}.

Definition upper_to_star_jump : mario_route_state :=
  begin_controlled_jump 12 0 62 counterfactual_upper_landing.

Definition before_star_platform_landing : mario_route_state :=
  controlled_air_frames 23 12 0 4 upper_to_star_jump.

Definition can_land_on_star_platform
    (dx dz : Z) (before : mario_route_state) : Prop :=
  let intended := controlled_air_frame dx dz 4 before in
  route_area before = Area2 /\
  route_y before >= 4815 /\
  route_y intended <= 4815 /\
  in_area2_star_platform intended.

Definition star_platform_landing : mario_route_state :=
  let intended := controlled_air_frame 12 0 4 before_star_platform_landing in
  {| route_area := Area2;
     route_x := route_x intended;
     route_y := 4815;
     route_z := route_z intended;
     route_vx := 12;
     route_vy := 0;
     route_vz := 0;
     route_floor_of := Area2Star4815;
     route_motion_of := RouteGrounded |}.

Lemma before_star_platform_landing_values :
  route_x before_star_platform_landing = 468 /\
  route_y before_star_platform_landing = 4843 /\
  route_z before_star_platform_landing = -1021 /\
  route_vy before_star_platform_landing = -30.
Proof. vm_compute. repeat split; reflexivity. Qed.

Lemma counterfactual_star_platform_landing_permitted :
  can_land_on_star_platform 12 0 before_star_platform_landing.
Proof. vm_compute. repeat split; try reflexivity; discriminate. Qed.

Lemma counterfactual_star_platform_landing_values :
  route_x star_platform_landing = 480 /\
  route_y star_platform_landing = 4815 /\
  route_z star_platform_landing = -1021 /\
  route_floor_of star_platform_landing = Area2Star4815.
Proof. vm_compute. repeat split; reflexivity. Qed.

Definition controlled_ground_frame
    (dx dz : Z) (before : mario_route_state) : mario_route_state :=
  {| route_area := route_area before;
     route_x := route_x before + dx;
     route_y := route_y before;
     route_z := route_z before + dz;
     route_vx := dx;
     route_vy := 0;
     route_vz := dz;
     route_floor_of := route_floor_of before;
     route_motion_of := RouteGrounded |}.

Fixpoint controlled_ground_frames
    (frames : nat) (dx dz : Z) (state : mario_route_state)
    : mario_route_state :=
  match frames with
  | O => state
  | S rest =>
      controlled_ground_frames rest dx dz
        (controlled_ground_frame dx dz state)
  end.

Definition can_walk_on_star_platform
    (dx dz : Z) (before : mario_route_state) : Prop :=
  route_area before = Area2 /\
  route_y before = 4815 /\
  route_floor_of before = Area2Star4815 /\
  route_motion_of before = RouteGrounded /\
  within_air_speed_48 dx dz /\
  in_area2_star_platform (controlled_ground_frame dx dz before).

Fixpoint ground_frames_remain_on_star_platform
    (frames : nat) (dx dz : Z) (state : mario_route_state) : Prop :=
  match frames with
  | O => True
  | S rest =>
      can_walk_on_star_platform dx dz state /\
      ground_frames_remain_on_star_platform rest dx dz
        (controlled_ground_frame dx dz state)
  end.

Definition star_platform_reposition_almost : mario_route_state :=
  controlled_ground_frames 10 0 48 star_platform_landing.

Definition star_platform_reposition : mario_route_state :=
  controlled_ground_frame 0 41 star_platform_reposition_almost.

Lemma counterfactual_star_platform_reposition_permitted :
  ground_frames_remain_on_star_platform
    10 0 48 star_platform_landing /\
  can_walk_on_star_platform 0 41 star_platform_reposition_almost.
Proof.
  vm_compute. repeat split; try reflexivity; try discriminate; lia.
Qed.

Lemma counterfactual_star_platform_reposition_values :
  route_x star_platform_reposition = 480 /\
  route_y star_platform_reposition = 4815 /\
  route_z star_platform_reposition = -500 /\
  in_area2_star_platform star_platform_reposition.
Proof. vm_compute. repeat split; try reflexivity; discriminate. Qed.

Definition star_jump_start : mario_route_state :=
  begin_controlled_jump 0 0 42 star_platform_reposition.

Definition star_interaction_state : mario_route_state :=
  controlled_air_frames 2 0 0 4 star_jump_start.

Lemma star_interaction_state_values :
  route_x star_interaction_state = 480 /\
  route_y star_interaction_state = 4895 /\
  route_z star_interaction_state = -500.
Proof. vm_compute. repeat split; reflexivity. Qed.

Definition counterfactual_upper_route_claim : Prop :=
  upper_shortcut_hand_origin_required + hand_collision_top_max =
    route_y counterfactual_upper_departure /\
  instant_warp_step counterfactual_upper_warp counterfactual_upper_entry /\
  arrival_floor_selection counterfactual_upper_entry Area2Upper4429 /\
  selected_upper_landing_step
    counterfactual_upper_entry counterfactual_upper_landing /\
  can_land_on_star_platform 12 0 before_star_platform_landing /\
  ground_frames_remain_on_star_platform
    10 0 48 star_platform_landing /\
  can_walk_on_star_platform 0 41 star_platform_reposition_almost /\
  can_collect_inside_ancient_pyramid_star star_interaction_state.

Theorem counterfactual_upper_route_collects_the_star :
  counterfactual_upper_route_claim.
Proof.
  unfold counterfactual_upper_route_claim.
  refine (conj (proj1 counterfactual_upper_entry_values) _).
  refine (conj counterfactual_upper_entry_is_instant_warp _).
  refine (conj counterfactual_upper_entry_selects_4429 _).
  refine (conj counterfactual_upper_entry_lands_on_4429 _).
  refine (conj counterfactual_star_platform_landing_permitted _).
  refine (conj (proj1 counterfactual_star_platform_reposition_permitted) _).
  refine (conj (proj2 counterfactual_star_platform_reposition_permitted) _).
  vm_compute. repeat split; try reflexivity; discriminate.
Qed.
