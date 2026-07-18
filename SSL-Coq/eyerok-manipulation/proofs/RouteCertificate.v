From Coq Require Import ZArith.
From SSLEyerok.Proofs Require Import Area2Route GeneratedFacts RouteModel Spec
  StateMachine.

Local Open Scope Z_scope.

Theorem eyerok_area2_route_certificate :
  generated_route_source_shape /\
  (forall before after,
    route_floor_of before = HandSurface ->
    ~ instant_warp_step before after) /\
  (forall before after,
    instant_warp_step before after ->
    route_area after = Area2 /\
    route_x after = route_x before /\
    route_y after = route_y before /\
    route_z after = route_z before /\
    route_vx after = route_vx before /\
    route_vy after = route_vy before /\
    route_vz after = route_vz before /\
    route_motion_of after = route_motion_of before) /\
  hand_surface_ceiling SecondHand = 1974 /\
  mario_peak_ceiling SecondHand = 2604 /\
  (forall state,
    route_y state <= mario_peak_ceiling SecondHand ->
    ~ arrival_floor_selection state Area2Upper4429) /\
  (forall state,
    route_y state <= mario_peak_ceiling SecondHand ->
    ~ can_collect_inside_ancient_pyramid_star state) /\
  conditional_relation_route_claim.
Proof.
  refine (conj generated_route_source_shape_holds _).
  refine (conj a_hand_floor_does_not_trigger_the_instant_warp _).
  refine (conj instant_warp_preserves_mario_kinematics _).
  refine (conj eq_refl _).
  refine (conj eq_refl _).
  refine (conj peak_2604_cannot_select_the_upper_arrival_platform _).
  refine (conj peak_2604_cannot_collect_the_star _).
  exact conditional_relation_route_reaches_best_point_on_mid1967.
Qed.
