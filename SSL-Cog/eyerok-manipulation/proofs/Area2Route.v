From Coq Require Import Lia Ring ZArith.
From SSLEyerok.Proofs Require Import RouteModel Spec StateMachine VerticalBound.

Local Open Scope Z_scope.

Definition mario_triple_jump_rise_max : Z := 630.

Definition hand_surface_ceiling (rank : hand_rank) : Z :=
  height_ceiling rank + hand_collision_top_max.

Definition mario_peak_ceiling (rank : hand_rank) : Z :=
  hand_surface_ceiling rank + mario_triple_jump_rise_max.

Lemma refined_route_ceiling_values :
  height_ceiling FirstHand = 672 /\
  height_ceiling SecondHand = 1467 /\
  hand_surface_ceiling FirstHand = 1179 /\
  hand_surface_ceiling SecondHand = 1974 /\
  mario_peak_ceiling FirstHand = 1809 /\
  mario_peak_ceiling SecondHand = 2604.
Proof. repeat split; reflexivity. Qed.

Lemma old_relation_numbers_were_looser :
  2003 + hand_collision_top_max + mario_triple_jump_rise_max = 3140 /\
  mario_peak_ceiling SecondHand = 2604 /\
  2604 < 3140.
Proof. repeat split; reflexivity. Qed.

Definition second_support_state : vertical_state :=
  {| state_rank := SecondHand;
     state_mode := Controlled;
     state_y := 1179;
     state_budget := 0 |}.

Definition second_launch_state : vertical_state :=
  {| state_rank := SecondHand;
     state_mode := Ballistic;
     state_y := 1179;
     state_budget := 288 |}.

Definition second_peak_state : vertical_state :=
  {| state_rank := SecondHand;
     state_mode := Ballistic;
     state_y := 1467;
     state_budget := 0 |}.

Lemma second_support_state_reachable_in_relation :
  vertically_reachable SecondHand second_support_state.
Proof.
  eapply vertical_reachable_step.
  - apply vertical_reachable_initial.
  - apply step_land. reflexivity.
Qed.

Lemma second_launch_state_reachable_in_relation :
  vertically_reachable SecondHand second_launch_state.
Proof.
  eapply vertical_reachable_step.
  - exact second_support_state_reachable_in_relation.
  - apply step_launch.
    + reflexivity.
    + cbv [upward_travel_max]. lia.
Qed.

Lemma second_peak_state_reachable_in_relation :
  vertically_reachable SecondHand second_peak_state.
Proof.
  eapply vertical_reachable_step.
  - exact second_launch_state_reachable_in_relation.
  - replace second_peak_state with
      {| state_rank := state_rank second_launch_state;
         state_mode := Ballistic;
         state_y := state_y second_launch_state + 288;
         state_budget := state_budget second_launch_state - 288 |}
      by reflexivity.
    apply (step_rise second_launch_state 288).
    + reflexivity.
    + change (0 <= 288 /\ 288 <= 288). split; lia.
Qed.

Theorem relation_admits_second_hand_origin_ceiling :
  exists state,
    vertically_reachable SecondHand state /\
    state_y state = global_height_ceiling.
Proof.
  exists second_peak_state. split.
  - exact second_peak_state_reachable_in_relation.
  - reflexivity.
Qed.

Theorem instant_warp_preserves_mario_kinematics : forall before after,
  instant_warp_step before after ->
  route_area after = Area2 /\
  route_x after = route_x before /\
  route_y after = route_y before /\
  route_z after = route_z before /\
  route_vx after = route_vx before /\
  route_vy after = route_vy before /\
  route_vz after = route_vz before /\
  route_motion_of after = route_motion_of before.
Proof.
  intros before after Hwarp. inversion Hwarp; subst.
  repeat split; reflexivity.
Qed.

Theorem a_hand_floor_does_not_trigger_the_instant_warp : forall before after,
  route_floor_of before = HandSurface ->
  ~ instant_warp_step before after.
Proof.
  intros before after Hhand Hwarp.
  inversion Hwarp; congruence.
Qed.

Theorem area2_does_not_immediately_trigger_this_entry_warp : forall before after,
  route_area before = Area2 ->
  ~ instant_warp_step before after.
Proof.
  intros before after Harea Hwarp.
  inversion Hwarp; congruence.
Qed.

Theorem peak_2604_cannot_select_the_upper_arrival_platform : forall state,
  route_y state <= mario_peak_ceiling SecondHand ->
  ~ arrival_floor_selection state Area2Upper4429.
Proof.
  intros state Hheight Hselect. inversion Hselect; subst.
  unfold floor_query_eligible, mario_peak_ceiling, hand_surface_ceiling,
    mario_triple_jump_rise_max in *. cbn in *. lia.
Qed.

Theorem peak_2604_cannot_make_mid2940_eligible : forall query_y,
  query_y <= mario_peak_ceiling SecondHand ->
  ~ floor_query_eligible query_y 2940.
Proof.
  intros query_y Hheight Heligible.
  unfold floor_query_eligible, mario_peak_ceiling, hand_surface_ceiling,
    mario_triple_jump_rise_max in *. cbn in *. lia.
Qed.

Theorem peak_2604_cannot_collect_the_star : forall state,
  route_y state <= mario_peak_ceiling SecondHand ->
  ~ can_collect_inside_ancient_pyramid_star state.
Proof.
  intros state Hheight (_ & _ & Hvertical).
  unfold inside_ancient_pyramid_star_vertical, between,
    mario_peak_ceiling, hand_surface_ceiling,
    mario_triple_jump_rise_max in *. cbn in *. lia.
Qed.

Definition conditional_global_bound_departure : mario_route_state :=
  {| route_area := Area3;
     route_x := 192;
     route_y := 1974;
     route_z := -1993;
     route_vx := 0;
     route_vy := 30;
     route_vz := 48;
     route_floor_of := HandSurface;
     route_motion_of := RouteAirborne |}.

Definition conditional_prewarp_kinematics : mario_route_state :=
  controlled_air_frames 20 0 48 2 conditional_global_bound_departure.

Definition conditional_warp_state : mario_route_state :=
  with_floor conditional_prewarp_kinematics Area3Warp1D.

Definition conditional_area2_entry : mario_route_state :=
  enter_area2 conditional_warp_state.

Lemma conditional_prewarp_values :
  route_area conditional_prewarp_kinematics = Area3 /\
  route_x conditional_prewarp_kinematics = 192 /\
  route_y conditional_prewarp_kinematics = 2194 /\
  route_z conditional_prewarp_kinematics = -1033 /\
  route_vy conditional_prewarp_kinematics = -10 /\
  in_area3_warp_footprint conditional_prewarp_kinematics.
Proof.
  vm_compute. repeat split; try reflexivity; discriminate.
Qed.

Lemma conditional_entry_is_an_instant_warp :
  instant_warp_step conditional_warp_state conditional_area2_entry.
Proof. constructor; reflexivity. Qed.

Lemma conditional_entry_values :
  route_area conditional_area2_entry = Area2 /\
  route_x conditional_area2_entry = 192 /\
  route_y conditional_area2_entry = 2194 /\
  route_z conditional_area2_entry = -1033 /\
  route_vy conditional_area2_entry = -10.
Proof. vm_compute. repeat split; reflexivity. Qed.

Lemma conditional_entry_selects_base896 :
  arrival_floor_selection conditional_area2_entry Area2Base896.
Proof.
  apply arrival_select_base.
  - reflexivity.
  - vm_compute. repeat split; discriminate.
  - right. vm_compute. reflexivity.
  - vm_compute. discriminate.
Qed.

Definition before_closest_mid1967_landing : mario_route_state :=
  controlled_air_frames 11 16 45 2 conditional_area2_entry.

Definition closest_mid1967_landing : mario_route_state :=
  land_on_mid1967 19 38 before_closest_mid1967_landing.

Lemma steering_steps_respect_speed_48 :
  within_air_speed_48 16 45 /\ within_air_speed_48 19 38.
Proof. unfold within_air_speed_48. split; lia. Qed.

Lemma before_closest_landing_values :
  route_x before_closest_mid1967_landing = 368 /\
  route_y before_closest_mid1967_landing = 1974 /\
  route_z before_closest_mid1967_landing = -538 /\
  route_vy before_closest_mid1967_landing = -32.
Proof. vm_compute. repeat split; reflexivity. Qed.

Lemma closest_mid1967_landing_is_permitted :
  can_land_on_mid1967 19 38 before_closest_mid1967_landing.
Proof. vm_compute. repeat split; try reflexivity; discriminate. Qed.

Lemma closest_mid1967_landing_values :
  route_area closest_mid1967_landing = Area2 /\
  route_x closest_mid1967_landing = 387 /\
  route_y closest_mid1967_landing = 1967 /\
  route_z closest_mid1967_landing = -500 /\
  route_floor_of closest_mid1967_landing = Area2Mid1967 /\
  route_motion_of closest_mid1967_landing = RouteGrounded.
Proof. vm_compute. repeat split; reflexivity. Qed.

Theorem mid1967_horizontal_distance_at_least_113 : forall state,
  in_area2_mid1967 state ->
  113 * 113 <=
    (route_x state - 500) * (route_x state - 500) +
    (route_z state + 500) * (route_z state + 500).
Proof.
  intros state ((Hxlow & Hxhigh) & (Hzlow & Hzhigh)).
  assert (Hdx : 113 <= 500 - route_x state) by lia.
  assert (Hdxsq :
    113 * 113 <=
      (500 - route_x state) * (500 - route_x state)) by nia.
  pose proof (Z.square_nonneg (route_z state + 500)) as Hzsq.
  replace ((route_x state - 500) * (route_x state - 500)) with
    ((500 - route_x state) * (500 - route_x state)) by ring.
  lia.
Qed.

Theorem closest_mid1967_landing_is_horizontally_optimal :
  in_area2_mid1967 closest_mid1967_landing /\
  (route_x closest_mid1967_landing - 500) *
    (route_x closest_mid1967_landing - 500) +
  (route_z closest_mid1967_landing + 500) *
    (route_z closest_mid1967_landing + 500) = 113 * 113.
Proof.
  vm_compute. split; [repeat split; discriminate | reflexivity].
Qed.

Theorem closest_mid1967_landing_is_not_star_collection :
  inside_ancient_pyramid_star_horizontal closest_mid1967_landing /\
  ~ inside_ancient_pyramid_star_vertical closest_mid1967_landing /\
  ~ can_collect_inside_ancient_pyramid_star closest_mid1967_landing.
Proof.
  split.
  - vm_compute. reflexivity.
  - split.
    + unfold inside_ancient_pyramid_star_vertical, between.
      intros (Hlow & _). vm_compute in Hlow.
      apply Hlow. reflexivity.
    + intros (_ & _ & Hvertical).
      unfold inside_ancient_pyramid_star_vertical, between in Hvertical.
      destruct Hvertical as (Hlow & _).
      vm_compute in Hlow.
      apply Hlow. reflexivity.
Qed.

Definition conditional_relation_route_claim : Prop :=
  vertically_reachable SecondHand second_peak_state /\
  state_y second_peak_state + hand_collision_top_max =
    route_y conditional_global_bound_departure /\
  instant_warp_step conditional_warp_state conditional_area2_entry /\
  can_land_on_mid1967 19 38 before_closest_mid1967_landing /\
  route_floor_of closest_mid1967_landing = Area2Mid1967 /\
  route_x closest_mid1967_landing = 387 /\
  route_z closest_mid1967_landing = -500 /\
  ~ can_collect_inside_ancient_pyramid_star closest_mid1967_landing.

Theorem conditional_relation_route_reaches_best_point_on_mid1967 :
  conditional_relation_route_claim.
Proof.
  unfold conditional_relation_route_claim.
  refine (conj second_peak_state_reachable_in_relation _).
  refine (conj eq_refl _).
  refine (conj conditional_entry_is_an_instant_warp _).
  refine (conj closest_mid1967_landing_is_permitted _).
  refine (conj eq_refl _).
  refine (conj eq_refl _).
  refine (conj eq_refl _).
  exact (proj2 (proj2 closest_mid1967_landing_is_not_star_collection)).
Qed.
