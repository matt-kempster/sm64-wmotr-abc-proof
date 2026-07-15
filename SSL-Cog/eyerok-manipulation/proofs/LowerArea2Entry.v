From Coq Require Import Lia ZArith.
From SSLEyerok.Proofs Require Import MarioHandContact RouteModel Spec
  TwoHandBarrier.

Local Open Scope Z_scope.

(** This witness deliberately begins at the conservative two-hand surface
    ceiling plus the exact ordinary triple-jump envelope.  Neither equality is
    claimed reachable in the original game. *)
Definition lower_entry_surface_y : Z := second_hand_open_surface_peak.
Definition lower_entry_mario_y : Z :=
  lower_entry_surface_y + sum_z triple_jump_positive_steps.
Definition area2_y1280_query_min : Z := 1280 - 78.
Definition conditional_backflip_peak_y : Z :=
  lower_entry_surface_y + sum_z backflip_positive_steps.

Lemma lower_entry_threshold_values :
  lower_entry_surface_y = 1179 /\
  lower_entry_mario_y = 1809 /\
  area2_y1280_query_min = 1202 /\
  conditional_backflip_peak_y = 1691 /\
  area2_y1280_query_min - lower_entry_surface_y = 23.
Proof. repeat split; reflexivity. Qed.

Definition conditional_lower_area3_entry : mario_route_state :=
  {| route_area := Area3;
     route_x := 0;
     route_y := lower_entry_mario_y;
     route_z := -1024;
     route_vx := 0;
     route_vy := -3;
     route_vz := 12;
     route_floor_of := Area3Warp1D;
     route_motion_of := RouteAirborne |}.

Definition conditional_lower_area2_arrival : mario_route_state :=
  enter_area2 conditional_lower_area3_entry.

Lemma conditional_lower_entry_is_in_warp_footprint :
  in_area3_warp_footprint conditional_lower_area3_entry.
Proof.
  unfold in_area3_warp_footprint, between,
    conditional_lower_area3_entry. cbn. lia.
Qed.

Lemma conditional_lower_entry_warps_to_area2 :
  instant_warp_step conditional_lower_area3_entry
    conditional_lower_area2_arrival.
Proof.
  unfold conditional_lower_area2_arrival.
  apply area3_warp_1d_to_area2; reflexivity.
Qed.

Definition conditional_lower_after_16 : mario_route_state :=
  controlled_air_frames 16 0 12 4 conditional_lower_area2_arrival.

Lemma conditional_lower_after_16_values :
  route_area conditional_lower_after_16 = Area2 /\
  route_x conditional_lower_after_16 = 0 /\
  route_y conditional_lower_after_16 = 1281 /\
  route_z conditional_lower_after_16 = -832 /\
  route_vy conditional_lower_after_16 = -67.
Proof. repeat split; reflexivity. Qed.

(** The source air step performs four floating quarter-steps.  At the first
    one, 1281 + (-67/4) = 1264.25 and -832 + (12/4) = -829; TerrainData casts
    the positive Y to 1264.  The pinned route audit checks the actual Area 2
    floor-list result at this exact integer query. *)
Definition conditional_lower_first_qstep_query : mario_route_state :=
  {| route_area := Area2;
     route_x := 0;
     route_y := 1264;
     route_z := -829;
     route_vx := 0;
     route_vy := -67;
     route_vz := 12;
     route_floor_of := FloorPending;
     route_motion_of := RouteAirborne |}.

Definition lower_first_air_quarter_query (before : mario_route_state)
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

Lemma conditional_lower_first_qstep_is_computed_query :
  lower_first_air_quarter_query conditional_lower_after_16 =
    conditional_lower_first_qstep_query.
Proof. reflexivity. Qed.

Lemma conditional_lower_first_qstep_scaled_arithmetic :
  4 * route_y conditional_lower_after_16 +
      route_vy conditional_lower_after_16 = 4 * 1264 + 1 /\
  4 * route_z conditional_lower_after_16 +
      route_vz conditional_lower_after_16 = 4 * (-829).
Proof. split; reflexivity. Qed.

Theorem conditional_lower_first_qstep_selects_y1280 :
  arrival_floor_selection conditional_lower_first_qstep_query Area2Mid1280.
Proof.
  apply arrival_select_mid1280_audited; reflexivity.
Qed.

Theorem two_hand_peak_cannot_query_y1967 :
  ~ floor_query_eligible lower_entry_mario_y 1967.
Proof.
  unfold floor_query_eligible, lower_entry_mario_y,
    lower_entry_surface_y, second_hand_open_surface_peak,
    second_hand_finite_origin_peak, second_hand_support_ceiling,
    area3_upward_floor_y_max, upward_travel_max,
    hand_collision_top_max, triple_jump_positive_steps, sum_z.
  cbn. lia.
Qed.

Theorem conditional_lower_entry_can_query_y1280_at_landing :
  floor_query_eligible (route_y conditional_lower_first_qstep_query) 1280.
Proof.
  unfold floor_query_eligible, conditional_lower_first_qstep_query. cbn. lia.
Qed.

Definition snap_to_mid1280 (before : mario_route_state)
    : mario_route_state :=
  let query := lower_first_air_quarter_query before in
  {| route_area := Area2;
     route_x := route_x query;
     route_y := 1280;
     route_z := route_z query;
     route_vx := route_vx before;
     route_vy := 0;
     route_vz := route_vz before;
     route_floor_of := Area2Mid1280;
     route_motion_of := RouteGrounded |}.

Definition can_land_on_selected_mid1280 (before : mario_route_state) : Prop :=
  arrival_floor_selection
    (lower_first_air_quarter_query before) Area2Mid1280 /\
  route_vy before <= 0 /\
  floor_query_eligible
    (route_y (lower_first_air_quarter_query before)) 1280 /\
  route_y (lower_first_air_quarter_query before) <= 1280.

Inductive selected_mid1280_landing_step
    : mario_route_state -> mario_route_state -> Prop :=
| land_on_selected_mid1280 : forall before,
    can_land_on_selected_mid1280 before ->
    selected_mid1280_landing_step before (snap_to_mid1280 before).

Definition conditional_lower_landing : mario_route_state :=
  snap_to_mid1280 conditional_lower_after_16.

Theorem conditional_lower_first_qstep_lands_on_y1280 :
  selected_mid1280_landing_step
    conditional_lower_after_16 conditional_lower_landing.
Proof.
  constructor. unfold can_land_on_selected_mid1280.
  rewrite conditional_lower_first_qstep_is_computed_query.
  repeat split.
  - exact conditional_lower_first_qstep_selects_y1280.
  - cbn. lia.
  - exact conditional_lower_entry_can_query_y1280_at_landing.
  - cbn. lia.
Qed.

Lemma conditional_lower_landing_values :
  route_area conditional_lower_landing = Area2 /\
  route_x conditional_lower_landing = 0 /\
  route_y conditional_lower_landing = 1280 /\
  route_z conditional_lower_landing = -829 /\
  route_floor_of conditional_lower_landing = Area2Mid1280 /\
  route_motion_of conditional_lower_landing = RouteGrounded.
Proof. repeat split; reflexivity. Qed.

(** This states only the no-additional-impulse arithmetic.  No A policy alone
    implies that Mario remains grounded at the hand surface. *)
Theorem grounded_surface_without_new_impulse_misses_y1280 :
  ~ floor_query_eligible lower_entry_surface_y 1280.
Proof.
  unfold floor_query_eligible, lower_entry_surface_y,
    second_hand_open_surface_peak, second_hand_finite_origin_peak,
    second_hand_support_ceiling, area3_upward_floor_y_max,
    upward_travel_max, hand_collision_top_max.
  lia.
Qed.

Definition lower_area2_entry_certificate : Prop :=
  lower_entry_surface_y = 1179 /\
  lower_entry_mario_y = 1809 /\
  conditional_backflip_peak_y = 1691 /\
  in_area3_warp_footprint conditional_lower_area3_entry /\
  instant_warp_step conditional_lower_area3_entry
    conditional_lower_area2_arrival /\
  route_y conditional_lower_after_16 = 1281 /\
  route_z conditional_lower_after_16 = -832 /\
  route_vy conditional_lower_after_16 = -67 /\
  lower_first_air_quarter_query conditional_lower_after_16 =
    conditional_lower_first_qstep_query /\
  arrival_floor_selection conditional_lower_first_qstep_query Area2Mid1280 /\
  selected_mid1280_landing_step
    conditional_lower_after_16 conditional_lower_landing /\
  ~ floor_query_eligible lower_entry_mario_y 1967 /\
  ~ floor_query_eligible lower_entry_surface_y 1280.

Theorem lower_area2_entry_certificate_holds : lower_area2_entry_certificate.
Proof.
  unfold lower_area2_entry_certificate.
  refine (conj (proj1 lower_entry_threshold_values) _).
  refine (conj (proj1 (proj2 lower_entry_threshold_values)) _).
  refine (conj (proj1 (proj2 (proj2 (proj2 lower_entry_threshold_values)))) _).
  refine (conj conditional_lower_entry_is_in_warp_footprint _).
  refine (conj conditional_lower_entry_warps_to_area2 _).
  refine (conj (proj1 (proj2 (proj2 conditional_lower_after_16_values))) _).
  refine (conj (proj1 (proj2 (proj2 (proj2 conditional_lower_after_16_values)))) _).
  refine (conj (proj2 (proj2 (proj2 (proj2 conditional_lower_after_16_values)))) _).
  refine (conj conditional_lower_first_qstep_is_computed_query _).
  refine (conj conditional_lower_first_qstep_selects_y1280 _).
  refine (conj conditional_lower_first_qstep_lands_on_y1280 _).
  refine (conj two_hand_peak_cannot_query_y1967 _).
  exact grounded_surface_without_new_impulse_misses_y1280.
Qed.
