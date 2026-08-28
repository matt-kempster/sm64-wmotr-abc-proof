(** Original-JP stale-Eyerok-hand progress certificate.

    The hash-gated debugger receipt in the archived Eyerok instrumentation
    follows both live hand addresses across Area 3 unloading and the true
    first Area-2 [apply_mario_platform_displacement] call.  This file keeps
    the finite receipt, generated initializer facts, and open reachability
    obligations separate.  In particular, explicitly writing a hand address
    into [gMarioPlatform] is not promoted into a clean route. *)

From Coq Require Import Bool Lia List ZArith.
From compcert Require Import AST Integers.
From LessThanOneAPress.Generated Require Import
  jp_behavior_data jp_ssl_collision.
From LessThanOneAPress.Proofs Require Import
  ASTFacts CollisionMeshFacts JPSlotLifetime.

Import ListNotations.
Local Open Scope Z_scope.

(** * Machine-word identification of the reused payload *)

Fixpoint init_int32_unsigned_values (values : list init_data) : list Z :=
  match values with
  | [] => []
  | Init_int32 value :: rest =>
      Int.unsigned value :: init_int32_unsigned_values rest
  | _ :: rest => init_int32_unsigned_values rest
  end.

Definition jp_static_object_command_words : list Z :=
  init_int32_unsigned_values
    (gvar_init jp_behavior_data.v_bhvStaticObject).

Definition jp_water_droplet_command_words : list Z :=
  init_int32_unsigned_values
    (gvar_init jp_behavior_data.v_bhvWaterDroplet).

Theorem jp_static_object_command_words_are_exact :
  jp_static_object_command_words =
    [524288; 285278209; 167772160].
Proof. vm_compute. reflexivity. Qed.

Theorem jp_water_droplet_command_words_are_distinct :
  firstn 3 jp_water_droplet_command_words =
    [786432; 285278219; 553648128] /\
  firstn 3 jp_water_droplet_command_words <>
    jp_static_object_command_words.
Proof. vm_compute. split; [reflexivity | discriminate]. Qed.

(** The debugger reads [00080000,11010001,0a000000] at virtual address
    [0x800ead50].  Those are exactly [bhvStaticObject]'s three generated
    words, not [bhvWaterDroplet]'s prefix.  This corrects the older prose
    identification while leaving the observed zero-motion result unchanged. *)
Definition jp_reused_behavior_machine_words : list Z :=
  [524288; 285278209; 167772160].

Theorem jp_reused_behavior_is_static_object_not_water_droplet :
  jp_reused_behavior_machine_words = jp_static_object_command_words /\
  jp_reused_behavior_machine_words <>
    firstn 3 jp_water_droplet_command_words.
Proof.
  rewrite jp_static_object_command_words_are_exact.
  destruct jp_water_droplet_command_words_are_distinct as [Hwater _].
  rewrite Hwater. split; [reflexivity | discriminate].
Qed.

(** * Exact Area-3 warp and hand-mesh initializer envelopes *)

Definition jp_area3_collision_vertices : list (Z * Z * Z) :=
  collision_vertices_from_words 122
    (init_int16_values
      (gvar_init jp_ssl_collision.v_ssl_seg7_area_3_collision)).

Definition jp_area3_warp_1d_vertices : list (Z * Z * Z) :=
  firstn 4 (skipn 18 jp_area3_collision_vertices).

Theorem jp_area3_warp_1d_vertices_are_exact :
  jp_area3_warp_1d_vertices =
    [(-191, 286, -1222); (-191, 384, -1023);
     (192, 384, -1023); (192, 286, -1222)].
Proof. vm_compute. reflexivity. Qed.

Definition collision_vertices_of {V : Type}
    (count : nat) (variable : globvar V) : list (Z * Z * Z) :=
  collision_vertices_from_words count
    (init_int16_values (gvar_init variable)).

Definition jp_eyerok_sleep_box_vertices : list (Z * Z * Z) :=
  collision_vertices_of 8
    jp_ssl_collision.v_ssl_seg7_collision_07028274.

Definition jp_eyerok_open_vertices : list (Z * Z * Z) :=
  collision_vertices_of 8
    jp_ssl_collision.v_ssl_seg7_collision_070282F8.

Definition jp_eyerok_right_sleep_vertices : list (Z * Z * Z) :=
  collision_vertices_of 19
    jp_ssl_collision.v_ssl_seg7_collision_07028370.

Definition jp_eyerok_left_sleep_vertices : list (Z * Z * Z) :=
  collision_vertices_of 19
    jp_ssl_collision.v_ssl_seg7_collision_070284B0.

Definition vertex_xz_within (bound : Z) (vertex : Z * Z * Z) : Prop :=
  let '(x, _, z) := vertex in
  -bound <= x <= bound /\ -bound <= z <= bound.

Theorem every_jp_eyerok_local_vertex_is_within_153_xz :
  Forall (vertex_xz_within 153) jp_eyerok_sleep_box_vertices /\
  Forall (vertex_xz_within 153) jp_eyerok_open_vertices /\
  Forall (vertex_xz_within 153) jp_eyerok_right_sleep_vertices /\
  Forall (vertex_xz_within 153) jp_eyerok_left_sleep_vertices.
Proof.
  vm_compute;
  repeat match goal with
  | |- _ /\ _ => split
  | |- Forall _ [] => apply Forall_nil
  | |- Forall _ (_ :: _) => apply Forall_cons
  end;
  easy.
Qed.

(** At scale 1.5, a deliberately coarse trigonometric-independent Z envelope
    is [1.5 * (|local X| + |local Z|) <= 459].  If a source execution supplies
    the target-Mario branch's pivot premise [pivot Z <= -1943], even that coarse
    envelope stops at -1484, strictly behind the warp's minimum Z -1222.
    This premise is not universal: the fist-push/sweep family must be audited
    separately.  That distinction is intentionally explicit rather than
    hidden inside this arithmetic theorem. *)
Definition target_mario_hand_pivot_z_max : Z := -1943.
Definition known_pedro_hand_pivot_z : Z := -3393.
Definition ordinary_hand_mesh_z_offset_max : Z := 459.
Definition area3_warp_1d_z_min : Z := -1222.

Theorem target_mario_hand_envelope_is_separate_from_warp_1d :
  forall pivot_z transformed_local_z warp_z,
    pivot_z <= target_mario_hand_pivot_z_max ->
    transformed_local_z <= ordinary_hand_mesh_z_offset_max ->
    area3_warp_1d_z_min <= warp_z ->
    pivot_z + transformed_local_z < warp_z.
Proof.
  unfold target_mario_hand_pivot_z_max,
    ordinary_hand_mesh_z_offset_max, area3_warp_1d_z_min.
  intros; lia.
Qed.

(** Both source-audited Eyerok Pedro configurations occur while the relevant
    hand pivots retain their spawn/home Z [-3393].  Even the same coarse mesh
    envelope ends at -2934, so neither known Pedro geometry can also cover the
    static warp.  A new ordinary mismatch therefore needs a different
    floor-retention mechanism or a different hand state. *)
Theorem known_pedro_hand_envelope_is_separate_from_warp_1d :
  forall transformed_local_z warp_z,
    transformed_local_z <= ordinary_hand_mesh_z_offset_max ->
    area3_warp_1d_z_min <= warp_z ->
    known_pedro_hand_pivot_z + transformed_local_z < warp_z.
Proof.
  unfold known_pedro_hand_pivot_z,
    ordinary_hand_mesh_z_offset_max, area3_warp_1d_z_min.
  intros; lia.
Qed.

(** * Unload, reuse, and first-apply receipt *)

Inductive EyerokHandSide := EyerokRight | EyerokLeft.

Record JPEyerokHandApplyReceipt : Type := {
  eyerok_receipt_side : EyerokHandSide;
  eyerok_source_pool_slot : nat;
  eyerok_raw_address : Z;
  eyerok_destination_allocation : nat;
  eyerok_unload_calls : nat;
  eyerok_allocations_at_first_apply : nat;
  eyerok_payload_behavior_address : Z;
  eyerok_payload_behavior_words : list Z;
  eyerok_payload_position : Z * Z * Z;
  eyerok_payload_velocity : Z * Z * Z;
  eyerok_payload_angle_velocity : Z * Z * Z;
  eyerok_time_stop_active : bool;
  eyerok_mario_object_present : bool;
  eyerok_retained_pointer_nonnull : bool
}.

Definition jp_right_hand_apply_receipt : JPEyerokHandApplyReceipt :=
  {| eyerok_receipt_side := EyerokRight;
     eyerok_source_pool_slot := 32;
     eyerok_raw_address := 2150894872;       (* 0x80340d18 *)
     eyerok_destination_allocation := 1;
     eyerok_unload_calls := 1;
     eyerok_allocations_at_first_apply := 83;
     eyerok_payload_behavior_address := 2148445520; (* 0x800ead50 *)
     eyerok_payload_behavior_words := jp_reused_behavior_machine_words;
     eyerok_payload_position := (1741, -101, 1843);
     eyerok_payload_velocity := (0, 0, 0);
     eyerok_payload_angle_velocity := (0, 0, 0);
     eyerok_time_stop_active := false;
     eyerok_mario_object_present := true;
     eyerok_retained_pointer_nonnull := true |}.

Definition jp_left_hand_apply_receipt : JPEyerokHandApplyReceipt :=
  {| eyerok_receipt_side := EyerokLeft;
     eyerok_source_pool_slot := 73;
     eyerok_raw_address := 2150919800;       (* 0x80346e78 *)
     eyerok_destination_allocation := 2;
     eyerok_unload_calls := 1;
     eyerok_allocations_at_first_apply := 83;
     eyerok_payload_behavior_address := 2148445520; (* 0x800ead50 *)
     eyerok_payload_behavior_words := jp_reused_behavior_machine_words;
     eyerok_payload_position := (0, -101, 528);
     eyerok_payload_velocity := (0, 0, 0);
     eyerok_payload_angle_velocity := (0, 0, 0);
     eyerok_time_stop_active := false;
     eyerok_mario_object_present := true;
     eyerok_retained_pointer_nonnull := true |}.

Definition jp_both_hand_apply_receipts : list JPEyerokHandApplyReceipt :=
  [jp_right_hand_apply_receipt; jp_left_hand_apply_receipt].

Definition receipt_apply_gate_open
    (receipt : JPEyerokHandApplyReceipt) : Prop :=
  eyerok_time_stop_active receipt = false /\
  eyerok_mario_object_present receipt = true /\
  eyerok_retained_pointer_nonnull receipt = true.

Definition receipt_payload_motionless
    (receipt : JPEyerokHandApplyReceipt) : Prop :=
  eyerok_payload_velocity receipt = (0, 0, 0) /\
  eyerok_payload_angle_velocity receipt = (0, 0, 0).

Theorem jp_both_hand_receipts_have_exact_lifo_reuse_order :
  map eyerok_destination_allocation jp_both_hand_apply_receipts =
    [1%nat; 2%nat] /\
  map eyerok_source_pool_slot jp_both_hand_apply_receipts =
    [32%nat; 73%nat] /\
  Forall (fun receipt =>
    eyerok_unload_calls receipt = 1%nat /\
    eyerok_allocations_at_first_apply receipt = 83%nat)
    jp_both_hand_apply_receipts.
Proof. repeat split; repeat constructor. Qed.

Theorem jp_both_hand_first_apply_gates_are_open :
  Forall receipt_apply_gate_open jp_both_hand_apply_receipts.
Proof. repeat constructor; repeat split; reflexivity. Qed.

Theorem jp_both_hand_first_apply_payloads_are_motionless_static_objects :
  Forall (fun receipt =>
    receipt_payload_motionless receipt /\
    eyerok_payload_behavior_words receipt =
      jp_static_object_command_words)
    jp_both_hand_apply_receipts.
Proof.
  rewrite jp_static_object_command_words_are_exact.
  repeat constructor; repeat split; reflexivity.
Qed.

Theorem jp_both_hand_first_apply_payload_positions_are_exact :
  map eyerok_payload_position jp_both_hand_apply_receipts =
    [(1741, -101, 1843); (0, -101, 528)].
Proof. reflexivity. Qed.

Record IntegerMarioKinematics : Type := {
  integer_mario_x : Z;
  integer_mario_y : Z;
  integer_mario_z : Z;
  integer_mario_yaw : Z
}.

Definition apply_integer_platform_payload
    (velocity angle_velocity : Z * Z * Z)
    (mario : IntegerMarioKinematics) : IntegerMarioKinematics :=
  let '(vx, vy, vz) := velocity in
  let '(_, angle_y, _) := angle_velocity in
  {| integer_mario_x := integer_mario_x mario + vx;
     integer_mario_y := integer_mario_y mario + vy;
     integer_mario_z := integer_mario_z mario + vz;
     integer_mario_yaw := integer_mario_yaw mario + angle_y |}.

Theorem apply_integer_motionless_payload_is_identity :
  forall mario,
    apply_integer_platform_payload (0, 0, 0) (0, 0, 0) mario = mario.
Proof.
  intros [x y z yaw].
  unfold apply_integer_platform_payload.
  simpl.
  rewrite !Z.add_0_r.
  reflexivity.
Qed.

Theorem both_observed_first_applies_leave_mario_unchanged :
  forall receipt mario,
    In receipt jp_both_hand_apply_receipts ->
    apply_integer_platform_payload
      (eyerok_payload_velocity receipt)
      (eyerok_payload_angle_velocity receipt) mario = mario.
Proof.
  intros receipt mario Hin.
  pose proof
    jp_both_hand_first_apply_payloads_are_motionless_static_objects as Hall.
  rewrite Forall_forall in Hall.
  specialize (Hall receipt Hin).
  destruct Hall as [[Hvelocity Hangle] _].
  rewrite Hvelocity, Hangle.
  apply apply_integer_motionless_payload_is_identity.
Qed.

(** The fixture's Area-2 entry Y is 346.080444, hence below 347.  A
    motionless first apply cannot directly overlap the Act-3 star at Y 5050:
    even Mario's ordinary 160-unit interaction height ends below it.  This is
    an immediate-apply no-go, not an exclusion of a later lower-route
    continuation. *)
Definition eyerok_fixture_entry_y_upper_bound : Z := 347.
Definition act3_star_y : Z := 5050.
Definition mario_interaction_height : Z := 160.

Theorem motionless_eyerok_apply_cannot_immediately_reach_act3_vertically :
  forall mario_y,
    mario_y <= eyerok_fixture_entry_y_upper_bound ->
    mario_y + mario_interaction_height < act3_star_y.
Proof.
  unfold eyerok_fixture_entry_y_upper_bound,
    mario_interaction_height, act3_star_y.
  intros; lia.
Qed.

(** * Exact mismatch and remaining split *)

Inductive CachedArea3Floor :=
| CachedWarp1D
| CachedOtherStatic
| CachedHandFloor (side : EyerokHandSide).

Inductive FreshPlatformOwner :=
| FreshStaticOwner
| FreshHandOwner (side : EyerokHandSide).

Definition refreshed_platform_address
    (owner : FreshPlatformOwner) : option EyerokHandSide :=
  match owner with
  | FreshStaticOwner => None
  | FreshHandOwner side => Some side
  end.

Definition exact_eyerok_floor_platform_mismatch
    (cached : CachedArea3Floor) (fresh : FreshPlatformOwner) : Prop :=
  cached = CachedWarp1D /\
  exists side, refreshed_platform_address fresh = Some side.

Theorem a_fresh_static_warp_query_cannot_supply_the_stale_hand_address :
  forall cached,
    cached = CachedWarp1D ->
    ~ exact_eyerok_floor_platform_mismatch cached FreshStaticOwner.
Proof.
  intros cached Hcached [Hwarp [side Howner]].
  subst cached. discriminate.
Qed.

(** Ordinary-scale closure can use the pivot theorem only for the
    target-Mario branch; fist push/sweep and every other live action remain
    separate, as does any post-Mario writer that separates MarioState from
    MarioObject before the final query.  The PU case must instead exhibit
    the exact signed-16 collision alias and a Pedro-style retained warp floor;
    it cannot borrow the ordinary spatial-separation theorem. *)
Definition TargetMarioEyerokSeparationObligation : Prop :=
  forall pivot_z transformed_local_z warp_z,
    pivot_z <= target_mario_hand_pivot_z_max ->
    transformed_local_z <= ordinary_hand_mesh_z_offset_max ->
    area3_warp_1d_z_min <= warp_z ->
    pivot_z + transformed_local_z < warp_z.

Definition PUEyerokMismatchWitnessObligation : Type :=
  { raw_pivot_z : Z &
    { signed16_surface_z : Z &
      { cached_floor : CachedArea3Floor &
        { fresh_owner : FreshPlatformOwner |
          cached_floor = CachedWarp1D /\
          exact_eyerok_floor_platform_mismatch
            cached_floor fresh_owner }}}}.

Definition JPEyerokStaleHandProgressCertificate : Prop :=
  jp_reused_behavior_machine_words = jp_static_object_command_words /\
  jp_area3_warp_1d_vertices =
    [(-191, 286, -1222); (-191, 384, -1023);
     (192, 384, -1023); (192, 286, -1222)] /\
  (map eyerok_destination_allocation jp_both_hand_apply_receipts =
      [1%nat; 2%nat] /\
   map eyerok_source_pool_slot jp_both_hand_apply_receipts =
      [32%nat; 73%nat] /\
   Forall (fun receipt =>
      eyerok_unload_calls receipt = 1%nat /\
      eyerok_allocations_at_first_apply receipt = 83%nat)
      jp_both_hand_apply_receipts) /\
  Forall receipt_apply_gate_open jp_both_hand_apply_receipts /\
  Forall (fun receipt =>
    receipt_payload_motionless receipt /\
    eyerok_payload_behavior_words receipt =
      jp_static_object_command_words)
    jp_both_hand_apply_receipts /\
  map eyerok_payload_position jp_both_hand_apply_receipts =
    [(1741, -101, 1843); (0, -101, 528)] /\
  (forall transformed_local_z warp_z,
    transformed_local_z <= ordinary_hand_mesh_z_offset_max ->
    area3_warp_1d_z_min <= warp_z ->
    known_pedro_hand_pivot_z + transformed_local_z < warp_z) /\
  TargetMarioEyerokSeparationObligation.

Theorem jp_eyerok_stale_hand_progress_certificate_holds :
  JPEyerokStaleHandProgressCertificate.
Proof.
  unfold JPEyerokStaleHandProgressCertificate.
  split; [exact (proj1 jp_reused_behavior_is_static_object_not_water_droplet) |].
  split; [exact jp_area3_warp_1d_vertices_are_exact |].
  split; [exact jp_both_hand_receipts_have_exact_lifo_reuse_order |].
  split; [exact jp_both_hand_first_apply_gates_are_open |].
  split.
  - exact jp_both_hand_first_apply_payloads_are_motionless_static_objects.
  - split.
    + exact jp_both_hand_first_apply_payload_positions_are_exact.
    + split.
      * exact known_pedro_hand_envelope_is_separate_from_warp_1d.
      * exact target_mario_hand_envelope_is_separate_from_warp_1d.
Qed.

Print Assumptions jp_eyerok_stale_hand_progress_certificate_holds.
