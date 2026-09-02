(** A checked finite suffix for the controller-facing Eyerok gates.

    [EyerokControllerManipulation] proves which stock state-machine choices
    Mario's position can influence.  This file records the complementary US
    retail experiment: after the ordinary Area-3 entry boundary, stick input
    reaches the narrow deterministic TARGET_MARIO strip, releases the chase,
    and selects either sweep sign without an A press or a memory write.

    The receipt also records the negative result.  The forward-side sample
    reaches the arena edge and falls; the mirrored, grounded sample is pushed
    chiefly in X and bends backward in Z.  Neither run ever makes the hand
    Mario's floor owner or cached platform.  The theorem is deliberately a
    finite suffix receipt, not an exhaustive analog-input or from-reset
    controller theorem. *)

From Coq Require Import Bool Lia ZArith.
From LessThanOneAPress.Proofs Require Import
  EyerokControllerManipulation EyerokRank15ControllerRide
  JPEyerokStaleHand.

Local Open Scope Z_scope.

Record EyerokControllerSuffixReceipt : Type := {
  ecsr_boundary_timer : Z;
  ecsr_wake_timer : Z;
  ecsr_strip_timer : Z;
  ecsr_selection_timer : Z;
  ecsr_smash_timer : Z;
  ecsr_sweep_timer : Z;
  ecsr_selection_mario_z_micro : Z;
  ecsr_selection_hand_z_micro : Z;
  ecsr_farthest_hand_z_micro : Z;
  ecsr_positive_entry_x_micro : Z;
  ecsr_positive_entry_y_micro : Z;
  ecsr_positive_entry_z_micro : Z;
  ecsr_positive_fell_from_edge : bool;
  ecsr_negative_entry_x_micro : Z;
  ecsr_negative_entry_y_micro : Z;
  ecsr_negative_entry_z_micro : Z;
  ecsr_negative_postzero_dx_micro : Z;
  ecsr_negative_postzero_dz_micro : Z;
  ecsr_negative_postzero_speed : Z;
  ecsr_a_polls : Z;
  ecsr_dialog_b_polls : Z;
  ecsr_postboundary_writes : Z;
  ecsr_hand_floor_frames : Z;
  ecsr_hand_platform_frames : Z
}.

Definition us_eyerok_controller_suffix_receipt :
    EyerokControllerSuffixReceipt :=
  {| ecsr_boundary_timer := 363;
     ecsr_wake_timer := 560;
     ecsr_strip_timer := 603;
     ecsr_selection_timer := 903;
     ecsr_smash_timer := 952;
     ecsr_sweep_timer := 981;
     ecsr_selection_mario_z_micro := -2998543;
     ecsr_selection_hand_z_micro := -3393000;
     ecsr_farthest_hand_z_micro := -1970731;
     ecsr_positive_entry_x_micro := 921000;
     ecsr_positive_entry_y_micro := -1534000;
     ecsr_positive_entry_z_micro := -1889765;
     ecsr_positive_fell_from_edge := true;
     ecsr_negative_entry_x_micro := 602705;
     ecsr_negative_entry_y_micro := -1534000;
     ecsr_negative_entry_z_micro := -1897536;
     ecsr_negative_postzero_dx_micro := -1232672;
     ecsr_negative_postzero_dz_micro := -133266;
     ecsr_negative_postzero_speed := 0;
     ecsr_a_polls := 0;
     ecsr_dialog_b_polls := 13;
     ecsr_postboundary_writes := 0;
     ecsr_hand_floor_frames := 0;
     ecsr_hand_platform_frames := 0 |}.

Definition check_eyerok_controller_suffix_receipt
    (r : EyerokControllerSuffixReceipt) : bool :=
  Z.eqb (ecsr_boundary_timer r) 363 &&
  Z.eqb (ecsr_wake_timer r) 560 &&
  Z.eqb (ecsr_strip_timer r) 603 &&
  Z.eqb (ecsr_selection_timer r) 903 &&
  Z.eqb (ecsr_smash_timer r) 952 &&
  Z.eqb (ecsr_sweep_timer r) 981 &&
  Z.eqb (ecsr_selection_mario_z_micro r) (-2998543) &&
  Z.eqb (ecsr_selection_hand_z_micro r) (-3393000) &&
  Z.eqb (ecsr_farthest_hand_z_micro r) (-1970731) &&
  Z.eqb (ecsr_positive_entry_z_micro r) (-1889765) &&
  ecsr_positive_fell_from_edge r &&
  Z.eqb (ecsr_negative_postzero_dx_micro r) (-1232672) &&
  Z.eqb (ecsr_negative_postzero_dz_micro r) (-133266) &&
  Z.eqb (ecsr_negative_postzero_speed r) 0 &&
  Z.eqb (ecsr_a_polls r) 0 &&
  Z.eqb (ecsr_dialog_b_polls r) 13 &&
  Z.eqb (ecsr_postboundary_writes r) 0 &&
  Z.eqb (ecsr_hand_floor_frames r) 0 &&
  Z.eqb (ecsr_hand_platform_frames r) 0.

Theorem us_eyerok_controller_suffix_receipt_checked :
  check_eyerok_controller_suffix_receipt
    us_eyerok_controller_suffix_receipt = true.
Proof. vm_compute. reflexivity. Qed.

(** TARGET_MARIO stops once its pivot is beyond boss Z + 1700.  Because the
    handler runs before the ordinary movement integration, one final movement
    of at most 50 can overshoot that boundary. *)
Definition eyerok_target_stop_pivot_z : Z :=
  eyerok_boss_home_z + 1700.

Definition eyerok_target_max_step : Z := 50.

Definition eyerok_target_poststep_pivot_cap : Z :=
  eyerok_target_stop_pivot_z + eyerok_target_max_step.

Theorem eyerok_target_poststep_cap_is_minus_1943 :
  eyerok_target_poststep_pivot_cap = -1943.
Proof. reflexivity. Qed.

(** Reuse the generated-collision proof's deliberately loose 459-unit bound.
    Even that bound leaves every TARGET_MARIO hand surface behind the nearest
    Z of the tunnel warp.  This is stronger than the single observed pivot. *)
Theorem eyerok_deterministic_target_surface_stays_behind_warp :
  forall pivot_z transformed_local_z warp_z,
    pivot_z <= eyerok_target_poststep_pivot_cap ->
    transformed_local_z <= ordinary_hand_mesh_z_offset_max ->
    area3_warp_1d_z_min <= warp_z ->
    pivot_z + transformed_local_z < warp_z.
Proof.
  intros pivot_z transformed_local_z warp_z Hpivot Hlocal Hwarp.
  apply target_mario_hand_envelope_is_separate_from_warp_1d;
    assumption.
Qed.

Definition eyerok_arena_floor_y : Z := -1534.
Definition eyerok_closed_top_offset : Z := 306.
Definition eyerok_target_pivot_y : Z := -1234.
Definition eyerok_target_closed_top_y : Z :=
  eyerok_target_pivot_y + eyerok_closed_top_offset.
Definition eyerok_sweep_closed_top_y : Z :=
  eyerok_arena_floor_y + eyerok_closed_top_offset.

(** From the flat arena, the hand's closed top is too high for an ordinary
    78-unit upward floor query both during chase and during the grounded
    sweep.  Conversely, even the raised chase top remains 288 units below the
    minimum Y at which Mario can query the tunnel floor. *)
Theorem eyerok_chase_and_sweep_have_no_flat_floor_boarding_or_tunnel_height :
  78 < eyerok_target_closed_top_y - eyerok_arena_floor_y /\
  78 < eyerok_sweep_closed_top_y - eyerok_arena_floor_y /\
  rank15_tunnel_floor_query_min_y - eyerok_target_closed_top_y = 288.
Proof. vm_compute. repeat split; lia. Qed.

(** The favorable-looking forward sample still ends 667.765 units behind the
    warp's nearest Z, then falls from the X edge.  The grounded mirror moves
    over 1,200 units sideways only after stored speed has reached zero, but
    its Z displacement is negative. *)
Theorem eyerok_controller_suffix_displacement_is_not_a_forward_warp_route :
  (-1222000) - ecsr_positive_entry_z_micro
      us_eyerok_controller_suffix_receipt = 667765 /\
  ecsr_positive_fell_from_edge us_eyerok_controller_suffix_receipt = true /\
  ecsr_negative_postzero_dx_micro us_eyerok_controller_suffix_receipt
      < -1200000 /\
  ecsr_negative_postzero_dz_micro us_eyerok_controller_suffix_receipt < 0 /\
  ecsr_negative_postzero_speed us_eyerok_controller_suffix_receipt = 0 /\
  ecsr_hand_floor_frames us_eyerok_controller_suffix_receipt = 0 /\
  ecsr_hand_platform_frames us_eyerok_controller_suffix_receipt = 0.
Proof. vm_compute. repeat split; lia. Qed.

Definition EyerokControllerReachabilityBoundary : Prop :=
  EyerokControllerManipulationBoundary /\
  check_eyerok_controller_suffix_receipt
    us_eyerok_controller_suffix_receipt = true /\
  eyerok_target_poststep_pivot_cap = -1943 /\
  (forall pivot_z transformed_local_z warp_z,
    pivot_z <= eyerok_target_poststep_pivot_cap ->
    transformed_local_z <= ordinary_hand_mesh_z_offset_max ->
    area3_warp_1d_z_min <= warp_z ->
    pivot_z + transformed_local_z < warp_z) /\
  (78 < eyerok_target_closed_top_y - eyerok_arena_floor_y /\
   78 < eyerok_sweep_closed_top_y - eyerok_arena_floor_y /\
   rank15_tunnel_floor_query_min_y - eyerok_target_closed_top_y = 288) /\
  ecsr_negative_postzero_dz_micro us_eyerok_controller_suffix_receipt < 0 /\
  ecsr_negative_postzero_speed us_eyerok_controller_suffix_receipt = 0 /\
  ecsr_hand_floor_frames us_eyerok_controller_suffix_receipt = 0 /\
  ecsr_hand_platform_frames us_eyerok_controller_suffix_receipt = 0.

Theorem eyerok_controller_reachability_boundary_holds :
  EyerokControllerReachabilityBoundary.
Proof.
  unfold EyerokControllerReachabilityBoundary.
  refine (conj eyerok_controller_manipulation_boundary_holds _).
  refine (conj us_eyerok_controller_suffix_receipt_checked _).
  refine (conj eyerok_target_poststep_cap_is_minus_1943 _).
  refine (conj eyerok_deterministic_target_surface_stays_behind_warp _).
  refine (conj eyerok_chase_and_sweep_have_no_flat_floor_boarding_or_tunnel_height _).
  vm_compute. repeat split; lia.
Qed.
