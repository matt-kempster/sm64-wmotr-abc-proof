(** Route boundary for finite nonlocal SSL Area-1 endpoints.

    The arithmetic here composes the small cast certificate with the existing
    timer-131 surface certificate.  It shows a genuine conditional capability:
    it packages the coordinates needed if a reachable execution keeps the old
    full-float Mario Object at the upper warp while a separate MarioState
    sample at Y = 1778 + 65536 narrows to the accepted timer-131 terrain query.
    Such a successful first query would not need Ink's graphical retry.

    Nothing in this file supplies the pre-collision three-dimensional writer,
    executes the wall/floor lists, or proves clean zero-A reachability. *)

From Coq Require Import Lia List ZArith.
From compcert Require Import Floats Integers.
From LessThanOneAPress.Proofs Require Import
  Area1InvalidCastArithmetic Area1NonlocalCastSemantics
  Area1NonlocalYCastArithmetic
  Area1FirstNull Area1PlatformExhaustiveness GameTypes InkFallback PyramidTopPU
  PyramidTopSurface Timer131Surface.
From LessThanOneAPress.Proofs Require Import RouteEvidence.

Import ListNotations.
Local Open Scope Z_scope.

Definition position_in_legacy_ssl_domain (position : PositionZ) : Prop :=
  legacy_pu_local_coordinate (position_x position) /\
  legacy_pu_local_coordinate (position_y position) /\
  legacy_pu_local_coordinate (position_z position).

Theorem upper_warp_contact_is_in_legacy_ssl_domain :
  forall position,
    upper_warp_contact position ->
    position_in_legacy_ssl_domain position.
Proof.
  intros position Hcontact.
  pose proof (upper_warp_contact_horizontal_bounds position Hcontact)
    as (Hx & Hz).
  pose proof (upper_warp_contact_y_bounds position Hcontact) as Hy.
  unfold position_in_legacy_ssl_domain, legacy_pu_local_coordinate,
    legacy_pu_local_min, legacy_pu_local_max.
  lia.
Qed.

Corollary nonlocal_position_cannot_directly_contact_upper_warp :
  forall position,
    ~ position_in_legacy_ssl_domain position ->
    ~ upper_warp_contact position.
Proof.
  intros position Hnonlocal Hcontact.
  exact (Hnonlocal (upper_warp_contact_is_in_legacy_ssl_domain
    position Hcontact)).
Qed.

Definition timer131_nonlocal_y_state_position : PositionZ :=
  {| position_x := -1862;
     position_y := 67314;
     position_z := -902 |}.

Definition cast_vec3_to_integer_query (value : Vec3f)
    : option Area1IntegerQuery :=
  match terrain_s16_from_float (vec_x value),
        terrain_s16_from_float (vec_y value),
        terrain_s16_from_float (vec_z value) with
  | Some x, Some y, Some z =>
      Some {| area1_query_x := x; area1_query_y := y; area1_query_z := z |}
  | _, _, _ => None
  end.

Theorem timer131_nonlocal_float_integer_components_correspond :
  terrain_s16_from_float (vec_x timer131_nonlocal_y_state_float) =
      Some (position_x timer131_nonlocal_y_state_position) /\
  terrain_s16_from_float (vec_y timer131_nonlocal_y_state_float) =
      Some 1778 /\
  Float32.to_int (vec_y timer131_nonlocal_y_state_float) =
      Some (Int.repr (position_y timer131_nonlocal_y_state_position)) /\
  terrain_s16_from_float (vec_z timer131_nonlocal_y_state_float) =
      Some (position_z timer131_nonlocal_y_state_position).
Proof.
  destruct timer131_nonlocal_y_vector_cast_components_checked
    as (Hx & Hy & Hz).
  destruct timer131_nonlocal_y_binary32_cast_checked as (Hyword & _).
  unfold timer131_nonlocal_y_state_position,
    timer131_nonlocal_y_state_float in *.
  cbn in *.
  repeat split; assumption.
Qed.

Theorem timer131_nonlocal_y_casts_to_midface_query :
  cast_vec3_to_integer_query timer131_nonlocal_y_state_float =
    Some timer131_midface_retry_query /\
  Float32.to_int timer131_nonlocal_y_float = Some (Int.repr 67314) /\
  position_y timer131_nonlocal_y_state_position = 1778 + 65536 /\
  ~ position_in_legacy_ssl_domain timer131_nonlocal_y_state_position.
Proof.
  destruct timer131_nonlocal_y_binary32_cast_checked as (Hyword & _).
  destruct timer131_nonlocal_y_vector_cast_components_checked
    as (Hx & Hy & Hz).
  unfold cast_vec3_to_integer_query.
  rewrite Hx, Hy, Hz.
  split; [reflexivity |].
  split; [exact Hyword |].
  split; [reflexivity |].
  unfold timer131_nonlocal_y_state_position,
    position_in_legacy_ssl_domain, legacy_pu_local_coordinate,
    legacy_pu_local_min, legacy_pu_local_max.
  cbn. lia.
Qed.

Definition Timer131MidfaceNumericAcceptance : Prop :=
  timer131_buffer_observation
      timer131_midface_retry_query timer131_retry_face =
    Some (1155464726, 1116741280, false) /\
  timer131_face_edge_values
      timer131_midface_retry_query timer131_retry_face =
    [262174; 130757; 130515] /\
  area1_loaded_plane_bits timer131_vertices_s16 timer131_retry_face =
    Some (1059030667, 1060448841, 1051360672, 1128674320) /\
  Int.signed (partition_cell_index (Int.repr (-1862))) = 6 /\
  Int.signed (partition_cell_index (Int.repr (-902))) = 7.

Theorem timer131_midface_numeric_acceptance_checked :
  Timer131MidfaceNumericAcceptance.
Proof. exact timer131_midface_retry_is_accepted. Qed.

Definition NonlocalYStateFirstNumericCapability : Prop :=
  upper_warp_contact upper_warp_center /\
  cast_vec3_to_integer_query timer131_nonlocal_y_state_float =
    Some timer131_midface_retry_query /\
  Timer131MidfaceNumericAcceptance /\
  ~ position_in_legacy_ssl_domain timer131_nonlocal_y_state_position.

Theorem nonlocal_y_state_first_numeric_capability_checked :
  NonlocalYStateFirstNumericCapability.
Proof.
  unfold NonlocalYStateFirstNumericCapability.
  split.
  - unfold upper_warp_contact, horizontal_distance_squared,
      upper_warp_center, upper_warp_radius, mario_hitbox_radius,
      upper_warp_y, upper_warp_height, mario_hitbox_height.
    cbn. repeat split; lia.
  - split.
    + exact (proj1 timer131_nonlocal_y_casts_to_midface_query).
    + split.
      * exact timer131_midface_numeric_acceptance_checked.
      * exact (proj2 (proj2 (proj2
          timer131_nonlocal_y_casts_to_midface_query))).
Qed.

(** A State-only endpoint of any magnitude cannot manufacture Ink's distinct
    Object/Graphics prestate.  Thus the alias above is relevant only to the
    separate State-first schedule, or after some prior non-State-only writer
    has already installed the required view split. *)
Theorem nonlocal_state_only_prefix_cannot_install_ink_from_sync :
  forall positions views floor_y,
    three_object_position views = three_graphics_position views ->
    ~ InkFallbackReady (write_state_only_prefix positions views) floor_y.
Proof.
  exact state_only_prefix_from_synchronized_sample_cannot_be_ink_ready.
Qed.

(** The following two predicates only name where later linked semantics must
    connect.  They are deliberately called schemas: applying arbitrary
    predicates to the desired pair is not itself a clean-entry or Clight
    reachability obligation, and neither schema is consumed below. *)
Definition NonlocalYStateFirstRetailReachabilitySchema
    (reachable_clean_zero_a_prequery_views :
      PositionZ -> Vec3f -> Prop) : Prop :=
  reachable_clean_zero_a_prequery_views
    upper_warp_center timer131_nonlocal_y_state_float.

Definition NonlocalEndpointWriterAndSurfaceRefinementSchema
    (linked_state_first_selects_timer131 : PositionZ -> Vec3f -> Prop)
    : Prop :=
  linked_state_first_selects_timer131
    upper_warp_center timer131_nonlocal_y_state_float.

Definition Area1NonlocalEndpointCheckedBoundary : Prop :=
  RepresentativeFailedCastClassificationObligation /\
  (forall position,
    upper_warp_contact position ->
    position_in_legacy_ssl_domain position) /\
  NonlocalYStateFirstNumericCapability /\
  (forall positions views floor_y,
    three_object_position views = three_graphics_position views ->
    ~ InkFallbackReady (write_state_only_prefix positions views) floor_y).

Theorem area1_nonlocal_endpoint_checked_boundary :
  Area1NonlocalEndpointCheckedBoundary.
Proof.
  unfold Area1NonlocalEndpointCheckedBoundary.
  split; [exact representative_failed_cast_classification_checked |].
  split; [exact upper_warp_contact_is_in_legacy_ssl_domain |].
  split; [exact nonlocal_y_state_first_numeric_capability_checked |].
  exact nonlocal_state_only_prefix_cannot_install_ink_from_sync.
Qed.
