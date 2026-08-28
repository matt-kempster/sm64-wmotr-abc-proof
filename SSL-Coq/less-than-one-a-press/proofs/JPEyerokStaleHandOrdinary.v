(** Ordinary-scale replacement-payload audit for the original-JP stale-hand
    proposal.  The baseline Area-2 allocation census is authenticated retail
    evidence; this file packages its finite effective-motion classification
    and evaluates the one nonidentity candidate at the recorded warp entry.
    It does not assume that the required cached-floor/hand-owner mismatch is
    reachable. *)

From Coq Require Import Lia List ZArith.
From compcert Require Import Floats Integers.
From LessThanOneAPress.Proofs Require Import
  Area1PhaseSplit JPEyerokStaleHandPU PyramidTopSurface.

Import ListNotations.
Local Open Scope Z_scope.

Definition jp_ordinary_spindel_input : F32Vec3 := {|
  f32_x := f32_of_Z 0;
  f32_y := jp_pu_recorded_local_entry_y;
  f32_z := f32_of_Z (-1100)
|}.

Definition jp_ordinary_spindel_velocity_adjusted : F32Vec3 := {|
  f32_x := f32_x jp_ordinary_spindel_input;
  f32_y := f32_y jp_ordinary_spindel_input;
  f32_z := Float32.add
    (f32_z jp_ordinary_spindel_input) (f32_of_Z 5)
|}.

Definition jp_ordinary_spindel_result : F32Vec3 :=
  let offset := f32_vec_sub
    jp_ordinary_spindel_velocity_adjusted jp_pu_spindel_pivot in
  let relative := f32_linear_transpose_mul jp_pu_identity_matrix offset in
  let new_offset := f32_linear_mul jp_pu_spindel_pitch256_matrix relative in
  f32_vec_add jp_pu_spindel_pivot new_offset.

Definition jp_ordinary_spindel_apply (input : F32Vec3) : F32Vec3 :=
  let adjusted := {|
    f32_x := f32_x input;
    f32_y := f32_y input;
    f32_z := Float32.add (f32_z input) (f32_of_Z 5)
  |} in
  let offset := f32_vec_sub adjusted jp_pu_spindel_pivot in
  let relative := f32_linear_transpose_mul jp_pu_identity_matrix offset in
  let new_offset := f32_linear_mul jp_pu_spindel_pitch256_matrix relative in
  f32_vec_add jp_pu_spindel_pivot new_offset.

Definition jp_ordinary_warp_vertex_inputs : list F32Vec3 :=
  [{| f32_x := f32_of_Z (-191); f32_y := f32_of_Z 286;
      f32_z := f32_of_Z (-1222) |};
   {| f32_x := f32_of_Z (-191); f32_y := f32_of_Z 384;
      f32_z := f32_of_Z (-1023) |};
   {| f32_x := f32_of_Z 192; f32_y := f32_of_Z 384;
      f32_z := f32_of_Z (-1023) |};
   {| f32_x := f32_of_Z 192; f32_y := f32_of_Z 286;
      f32_z := f32_of_Z (-1222) |}].

Definition f32_vec_integer_projection (value : F32Vec3)
    : option int * option int * option int :=
  (Float32.to_int (f32_x value),
   Float32.to_int (f32_y value),
   Float32.to_int (f32_z value)).

Definition f32_vec_bits_projection (value : F32Vec3) : int * int * int :=
  (Float32.to_bits (f32_x value),
   Float32.to_bits (f32_y value),
   Float32.to_bits (f32_z value)).

Definition jp_ordinary_warp_vertex_results :
    list (option int * option int * option int) :=
  map (fun input =>
    f32_vec_integer_projection (jp_ordinary_spindel_apply input))
    jp_ordinary_warp_vertex_inputs.

(** The center is the authenticated natural Area-3-to-Area-2 entry point.
    Spindel's only effective linear component is Z=5 and its only angular
    component is pitch=256.  At ordinary scale that combination lowers Mario
    and moves him about 38 units toward negative Z; it is not a lift. *)
Theorem jp_ordinary_spindel_center_displacement_is_exact :
  f32_vec_bits_projection jp_ordinary_spindel_result =
    (Int.zero, Int.repr 1135165880, Int.repr 3297660264) /\
  f32_vec_integer_projection jp_ordinary_spindel_result =
    (Some Int.zero, Some (Int.repr 338), Some (Int.repr (-1138))).
Proof.
  split; vm_compute; reflexivity.
Qed.

Theorem jp_ordinary_spindel_center_moves_down_and_back :
  338 - 346 = -8 /\
  -1138 - (-1100) = -38 /\
  338 + 160 < 5050.
Proof. repeat split; lia. Qed.

(** The same exact binary32 calculation at all four initializer vertices
    supplies a readable envelope check without pretending that a finite
    vertex check is a full theorem about every rounded interior point. *)
Theorem jp_ordinary_spindel_warp_vertices_are_exact :
  jp_ordinary_warp_vertex_results =
    [(Some (Int.repr (-191)), Some (Int.repr 281),
        Some (Int.repr (-1261)));
     (Some (Int.repr (-191)), Some (Int.repr 374),
        Some (Int.repr (-1060)));
     (Some (Int.repr 192), Some (Int.repr 374),
        Some (Int.repr (-1060)));
     (Some (Int.repr 192), Some (Int.repr 281),
        Some (Int.repr (-1261)))].
Proof. vm_compute. reflexivity. Qed.

(** * Finite replacement suffix

    A hand destroyed first is reused at Area-2 allocation 54; the last hand
    is reused at 53.  If prior persistent deletions merely omit allocations
    from the authenticated baseline stream, every actual replacement is in
    the inclusive suffix 53..83.  If too many entries are omitted, the slot
    is not reused at all. *)

Definition jp_ordinary_baseline_allocation_count : nat := 83.
Definition jp_ordinary_candidate_allocations : list nat := seq 53 31.

Inductive JPOrdinaryEffectivePayload : Type :=
| JPOrdinaryMotionless
| JPOrdinarySpindelPitch256.

Definition jp_ordinary_effective_payload
    (allocation : nat) : JPOrdinaryEffectivePayload :=
  if Nat.eqb allocation 64
  then JPOrdinarySpindelPitch256
  else JPOrdinaryMotionless.

Theorem jp_ordinary_death_ordinal_replacement_is_in_finite_suffix :
  forall destination omitted,
    (destination = 53%nat \/ destination = 54%nat) ->
    (destination + omitted <= jp_ordinary_baseline_allocation_count)%nat ->
    In (destination + omitted)%nat jp_ordinary_candidate_allocations.
Proof.
  intros destination omitted Hdestination Hbound.
  unfold jp_ordinary_candidate_allocations,
    jp_ordinary_baseline_allocation_count in Hbound |- *.
  rewrite in_seq. destruct Hdestination; subst; lia.
Qed.

(** The authenticated census records zero effective X/Z translation and zero
    angular velocity for every member of that suffix except allocation 64.
    Allocations 60--63 do have vertical object velocity, but the audited
    platform-displacement body never adds platform Y velocity to Mario. *)
Theorem jp_ordinary_authenticated_suffix_has_one_nonidentity_payload :
  filter (fun allocation => Nat.eqb allocation 64)
    jp_ordinary_candidate_allocations = [64%nat] /\
  Forall (fun allocation =>
    allocation = 64%nat \/
    jp_ordinary_effective_payload allocation = JPOrdinaryMotionless)
    jp_ordinary_candidate_allocations.
Proof.
  split.
  - vm_compute. reflexivity.
  - apply Forall_forall. intros allocation _.
    unfold jp_ordinary_effective_payload.
    destruct (Nat.eqb allocation 64) eqn:Heq.
    + left. apply Nat.eqb_eq. exact Heq.
    + right. reflexivity.
Qed.

Theorem jp_ordinary_spindel_is_the_unique_effective_exception :
  forall allocation,
    jp_ordinary_effective_payload allocation =
      JPOrdinarySpindelPitch256 <-> allocation = 64%nat.
Proof.
  intros allocation.
  unfold jp_ordinary_effective_payload.
  destruct (Nat.eqb_spec allocation 64).
  - subst. split; reflexivity.
  - split; [discriminate | contradiction].
Qed.

(** * Exact ordinary Pedro split

    At X/Z=(0,-1100), the authenticated static collision has only the two
    downward faces at Y=-409 and Y=768.  The source Pedro branch requires a
    positive 2..160 gap.  Consequently a hand floor has to lie in one of two
    small vertical bands. *)

Definition jp_ordinary_low_warp_ceiling_y : Z := -409.
Definition jp_ordinary_high_warp_ceiling_y : Z := 768.

Definition jp_ordinary_pedro_gap (floor_y ceiling_y : Z) : Prop :=
  2 <= ceiling_y - floor_y <= 160.

Theorem jp_ordinary_warp_pedro_floor_has_one_of_two_exact_bands :
  forall floor_y ceiling_y,
    (ceiling_y = jp_ordinary_low_warp_ceiling_y \/
     ceiling_y = jp_ordinary_high_warp_ceiling_y) ->
    jp_ordinary_pedro_gap floor_y ceiling_y ->
    (-569 <= floor_y <= -411) \/ (608 <= floor_y <= 766).
Proof.
  intros floor_y ceiling_y [Hlow | Hhigh] Hgap;
    subst ceiling_y;
    unfold jp_ordinary_pedro_gap,
      jp_ordinary_low_warp_ceiling_y,
      jp_ordinary_high_warp_ceiling_y in *; lia.
Qed.

Definition jp_ordinary_closed_top_offset : Z := 306.
Definition jp_ordinary_open_top_offset : Z := 507.

Theorem jp_ordinary_low_ceiling_requires_one_of_two_hand_origin_bands :
  forall pivot_y top_offset floor_y,
    (top_offset = jp_ordinary_closed_top_offset \/
     top_offset = jp_ordinary_open_top_offset) ->
    floor_y = pivot_y + top_offset ->
    -569 <= floor_y <= -411 ->
    (-875 <= pivot_y <= -717) \/ (-1076 <= pivot_y <= -918).
Proof.
  intros pivot_y top_offset floor_y [Hclosed | Hopen] Hfloor Hband;
    subst top_offset; subst floor_y;
    unfold jp_ordinary_closed_top_offset,
      jp_ordinary_open_top_offset in *; lia.
Qed.

Theorem jp_ordinary_high_ceiling_closed_hand_requires_known_pivot_band :
  forall pivot_y floor_y,
    floor_y = pivot_y + jp_ordinary_closed_top_offset ->
    608 <= floor_y <= 766 ->
    302 <= pivot_y <= 460.
Proof.
  intros pivot_y floor_y Hfloor Hband.
  subst floor_y. unfold jp_ordinary_closed_top_offset in *. lia.
Qed.

(** * Stock live-installation exclusion

    The authenticated retail action probe separates horizontal and vertical
    failures.  FIST_PUSH/SWEEP remains on the arena floor and is edge-stopped
    before even the conservative collision envelope reaches the warp.
    One-hand SHOW_EYE does cross the warp in X/Z, but its open top is only
    Y=-1027.  The only accepted-hit consumer is SHOW_EYE.  Even granting its
    lethal 50/-4 vertical continuation at the farthest forward pose, the open
    top peaks at Y=-739, still below the low Pedro floor band.  TARGET_MARIO
    and double-pound can rise, but their conservative collision envelopes end
    behind the warp.  The following small executable kernel checks the lethal
    arc and packages that source/receipt classification without claiming that
    the conditional fixture is a controller trace. *)

Definition jp_ordinary_home_pivot_y : Z := -1534.
Definition jp_ordinary_warp_near_z : Z := -1222.
Definition jp_ordinary_coarse_hand_xz_offset : Z := 459.
Definition jp_ordinary_fist_coarse_max_z : Z := -1409.
Definition jp_ordinary_target_coarse_max_z : Z := -1484.
Definition jp_ordinary_double_coarse_max_z : Z := -1634.

Definition jp_ordinary_death_step (state : Z * Z) : Z * Z :=
  let '(relative_y, velocity_y) := state in
  let velocity_y' := velocity_y - 4 in
  let candidate_y := relative_y + velocity_y' in
  if candidate_y <? 0 then (0, 0) else (candidate_y, velocity_y').

Fixpoint jp_ordinary_death_after (steps : nat) (state : Z * Z) : Z * Z :=
  match steps with
  | O => state
  | S remaining =>
      jp_ordinary_death_after remaining (jp_ordinary_death_step state)
  end.

Fixpoint jp_ordinary_death_peak (steps : nat) (state : Z * Z) : Z :=
  match steps with
  | O => fst state
  | S remaining =>
      let next := jp_ordinary_death_step state in
      Z.max (fst next) (jp_ordinary_death_peak remaining next)
  end.

Definition jp_ordinary_lethal_open_top_y : Z :=
  jp_ordinary_home_pivot_y
  + jp_ordinary_death_peak 25 (0, 50)
  + jp_ordinary_open_top_offset.

Theorem jp_ordinary_lethal_arc_is_exact_and_returns_to_ground :
  jp_ordinary_death_peak 25 (0, 50) = 288 /\
  jp_ordinary_death_after 25 (0, 50) = (0, 0) /\
  jp_ordinary_lethal_open_top_y = -739.
Proof. vm_compute. repeat split; reflexivity. Qed.

Definition jp_ordinary_floor_in_pedro_band (floor_y : Z) : Prop :=
  (-569 <= floor_y <= -411) \/ (608 <= floor_y <= 766).

Definition jp_ordinary_pose_overlaps_warp (coarse_max_z : Z) : Prop :=
  jp_ordinary_warp_near_z <= coarse_max_z.

Inductive JPOrdinaryStockPoseClass : Z -> Z -> Prop :=
| JPOrdinaryStockPoseRemote : forall floor_y coarse_max_z,
    coarse_max_z < jp_ordinary_warp_near_z ->
    JPOrdinaryStockPoseClass floor_y coarse_max_z
| JPOrdinaryStockPoseForwardLow : forall floor_y coarse_max_z,
    floor_y <= jp_ordinary_lethal_open_top_y ->
    JPOrdinaryStockPoseClass floor_y coarse_max_z.

(** This is the exact final logical split supplied by the pinned-source audit:
    each stock pose is horizontally remote, or its highest relevant floor is
    no higher than the lethal forward SHOW_EYE bound. *)
Theorem jp_ordinary_stock_pose_cannot_install_pedro_at_warp :
  forall floor_y coarse_max_z,
    JPOrdinaryStockPoseClass floor_y coarse_max_z ->
    ~ (jp_ordinary_pose_overlaps_warp coarse_max_z /\
       jp_ordinary_floor_in_pedro_band floor_y).
Proof.
  intros floor_y coarse_max_z Hclass [Hoverlap Hband].
  destruct Hclass as
    [classified_floor classified_max_z Hremote
    | classified_floor classified_max_z Hlow].
  - unfold jp_ordinary_pose_overlaps_warp,
      jp_ordinary_warp_near_z in Hoverlap, Hremote.
    lia.
  - unfold jp_ordinary_floor_in_pedro_band in Hband.
    change (classified_floor <= -739) in Hlow.
    destruct Hband as [[Hfloor_min Hfloor_max]
                      | [Hfloor_min Hfloor_max]]; lia.
Qed.

Theorem jp_ordinary_named_remote_families_miss_warp :
  jp_ordinary_fist_coarse_max_z < jp_ordinary_warp_near_z /\
  jp_ordinary_target_coarse_max_z < jp_ordinary_warp_near_z /\
  jp_ordinary_double_coarse_max_z < jp_ordinary_warp_near_z.
Proof. vm_compute. repeat split; lia. Qed.

(** A dying hand's 40-frame animation outlasts the 25 integrations needed for
    its lethal arc to return to the arena floor.  DIE then writes forwardVel
    zero, the common movement tail recomputes X/Z velocity from that zero, and
    the Eyerok behavior never changes the three allocation-zeroed angular
    velocities.  Therefore a genuinely freed but unreused death slot is also
    an identity payload for the five fields read by platform displacement. *)
Record JPOrdinaryEffectiveFields : Type := {
  jp_effective_vel_x : Z;
  jp_effective_vel_z : Z;
  jp_effective_angle_pitch : Z;
  jp_effective_angle_yaw : Z;
  jp_effective_angle_roll : Z
}.

Definition jp_ordinary_unreused_death_fields : JPOrdinaryEffectiveFields :=
  {| jp_effective_vel_x := 0;
     jp_effective_vel_z := 0;
     jp_effective_angle_pitch := 0;
     jp_effective_angle_yaw := 0;
     jp_effective_angle_roll := 0 |}.

Definition jp_ordinary_effective_fields_are_identity
    (fields : JPOrdinaryEffectiveFields) : Prop :=
  jp_effective_vel_x fields = 0 /\
  jp_effective_vel_z fields = 0 /\
  jp_effective_angle_pitch fields = 0 /\
  jp_effective_angle_yaw fields = 0 /\
  jp_effective_angle_roll fields = 0.

Theorem jp_ordinary_unreused_death_slot_is_identity_payload :
  jp_ordinary_effective_fields_are_identity
    jp_ordinary_unreused_death_fields.
Proof. repeat split; reflexivity. Qed.

Definition JPEyerokOrdinaryPayloadCertificate : Prop :=
  (forall destination omitted,
    (destination = 53%nat \/ destination = 54%nat) ->
    (destination + omitted <= jp_ordinary_baseline_allocation_count)%nat ->
    In (destination + omitted)%nat jp_ordinary_candidate_allocations) /\
  filter (fun allocation => Nat.eqb allocation 64)
    jp_ordinary_candidate_allocations = [64%nat] /\
  f32_vec_integer_projection jp_ordinary_spindel_result =
    (Some Int.zero, Some (Int.repr 338), Some (Int.repr (-1138))) /\
  (forall floor_y ceiling_y,
    (ceiling_y = jp_ordinary_low_warp_ceiling_y \/
     ceiling_y = jp_ordinary_high_warp_ceiling_y) ->
    jp_ordinary_pedro_gap floor_y ceiling_y ->
    (-569 <= floor_y <= -411) \/ (608 <= floor_y <= 766)) /\
  jp_ordinary_death_peak 25 (0, 50) = 288 /\
  (forall floor_y coarse_max_z,
    JPOrdinaryStockPoseClass floor_y coarse_max_z ->
    ~ (jp_ordinary_pose_overlaps_warp coarse_max_z /\
       jp_ordinary_floor_in_pedro_band floor_y)) /\
  jp_ordinary_effective_fields_are_identity
    jp_ordinary_unreused_death_fields.

Theorem jp_eyerok_ordinary_payload_certificate_holds :
  JPEyerokOrdinaryPayloadCertificate.
Proof.
  unfold JPEyerokOrdinaryPayloadCertificate.
  refine (conj jp_ordinary_death_ordinal_replacement_is_in_finite_suffix _).
  refine (conj
    (proj1 jp_ordinary_authenticated_suffix_has_one_nonidentity_payload) _).
  refine (conj
    (proj2 jp_ordinary_spindel_center_displacement_is_exact) _).
  refine (conj
    jp_ordinary_warp_pedro_floor_has_one_of_two_exact_bands _).
  refine (conj
    (proj1 jp_ordinary_lethal_arc_is_exact_and_returns_to_ground) _).
  refine (conj jp_ordinary_stock_pose_cannot_install_pedro_at_warp _).
  exact jp_ordinary_unreused_death_slot_is_identity_payload.
Qed.

Print Assumptions jp_eyerok_ordinary_payload_certificate_holds.
