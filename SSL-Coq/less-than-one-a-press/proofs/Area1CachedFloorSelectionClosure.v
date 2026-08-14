(** Finite-model closure of the cached-floor selection branch.

    A successful upper-warp interaction can dispatch [ACT_DISAPPEARED].
    [stop_and_set_height_to_floor] then preserves X/Z and replaces State Y
    with the floor height cached by the preceding geometry query.  The old
    Y=768 result covered only one explicit cached value.  The arithmetic here
    covers every floor height which the modeled stock [find_floor] query can
    return from the same upper-warp sample.

    Upper-warp contact bounds the query Y by 818.  Stock [find_floor] accepts
    a floor only when its height is at most 78 units above the signed-16 query
    Y, so the cached height is at most 896.  At the preserved warp X/Z, every
    non-top Area-1 dynamic owner is outside its checked horizontal envelope.
    The pyramid top is also impossible: its floor is at least 1281 and the
    final platform query requires Mario within four units of it, whereas the
    snapped query remains at or below 896.

    These are conditional finite-model theorems, not linked Clight execution.
    In particular, a future lift must prove that the live binary32
    [find_floor] result refines [floor_query_can_return], that the collision,
    selection, copy, and final query use the live Mario receivers, that alias
    and external-call frames hold, and that every live dynamic surface owner
    refines [stock_area1_final_platform_query]. *)

From Coq Require Import Lia ZArith.
From LessThanOneAPress.Proofs Require Import
  Area1InteractionShortCircuitClosure Area1PlatformExhaustiveness
  Area1PostCopyObjectWriterClosure Area1QueryScheduleClosure PyramidTopPU.

Local Open Scope Z_scope.

(** Numeric consequence of the modeled [find_floor] acceptance test.  The
    [floor_query_can_return] premise is deliberately visible: deriving it
    from the live binary32 return and selected [Surface] remains a linked
    execution/refinement obligation. *)
Theorem upper_warp_selected_floor_height_at_most_896 :
  forall collision cached_floor_y,
    upper_warp_contact collision ->
    floor_query_can_return collision cached_floor_y ->
    cached_floor_y <= 896.
Proof.
  intros collision cached_floor_y Hcontact Hselected.
  pose proof (upper_warp_contact_y_bounds collision Hcontact) as Hy.
  unfold floor_query_can_return in Hselected.
  rewrite signed16_in_range in Hselected by lia.
  unfold find_floor_upward_buffer in Hselected.
  lia.
Qed.

(** X/Z are inherited from an upper-warp contact, but Y need not remain in
    the warp hitbox.  The finite owner partition still makes every non-null
    final platform result impossible when the new Y is at most 896.

    [stock_area1_final_platform_query] is an explicit premise because the
    live dynamic-list traversal, owner pointer, slot/epoch, and conservative
    owner-envelope projection have not been derived from linked memory. *)
Theorem warp_horizontal_low_y_stock_query_is_null :
  forall collision final_query platform,
    upper_warp_contact collision ->
    position_x final_query = position_x collision ->
    position_z final_query = position_z collision ->
    position_y final_query <= 896 ->
    stock_area1_final_platform_query final_query platform ->
    platform = None.
Proof.
  intros collision final_query [owner |] Hcontact Hx Hz Hy Hquery.
  - cbn in Hquery.
    destruct Hquery as (floor_y & Hinside & Hnear_below &
      Hnear_above & Howner_floor).
    destruct (area1_surface_owner_eq_dec owner A1PyramidTop)
      as [Htop | Hnot_top].
    + subst owner.
      cbn in Howner_floor.
      unfold pyramid_top_floor_min_y, platform_floor_tolerance in *.
      lia.
    + exfalso.
      eapply non_top_owner_envelope_disjoint_from_upper_warp.
      * exact Hnot_top.
      * exact Hcontact.
      * unfold inside_horizontal_envelope in *.
        destruct Hinside as ((Hmin_x & Hmax_x) & Hmin_z & Hmax_z).
        repeat split;
          [ now rewrite <- Hx
          | now rewrite <- Hx
          | now rewrite <- Hz
          | now rewrite <- Hz ].
  - reflexivity.
Qed.

(** Capstone for the accepted nonfading-warp schedule projection.  The
    projection supplies the already separated interaction short circuit,
    selection/collision sample equality, copy, alias frame, external frame,
    and final Object read.  Its sample-equality field is not itself a live
    receiver-identity proof; that linked premise remains required when the
    projection is constructed.

    The other two premises expose the remaining interfaces directly:
    [floor_query_can_return] is the selected-floor refinement and
    [stock_area1_final_platform_query] is the exhaustive live-owner
    projection. *)
Theorem accepted_nonfading_warp_cached_floor_selection_stock_query_is_null :
  forall schedule platform
      (projection : AcceptedNonfadingWarpRuntimeProjection schedule),
    upper_warp_contact
      (position_z_of_schedule (schedule_collision_object schedule)) ->
    floor_query_can_return
      (position_z_of_schedule (schedule_state_at_selection schedule))
      (schedule_y (schedule_state_after_disappeared schedule)) ->
    stock_area1_final_platform_query
      (position_z_of_schedule (schedule_final_query schedule)) platform ->
    platform = None.
Proof.
  intros schedule platform projection Hcontact Hselected Hstock.
  pose proof
    (projected_selection_sample_matches_collision schedule projection)
    as Hselection.
  pose proof
    (accepted_nonfading_warp_final_query_reads_completed_copy
      schedule projection) as Hfinal.
  assert (Hselection_contact :
    upper_warp_contact
      (position_z_of_schedule (schedule_state_at_selection schedule))).
  { now rewrite Hselection. }
  pose proof
    (upper_warp_selected_floor_height_at_most_896
      (position_z_of_schedule (schedule_state_at_selection schedule))
      (schedule_y (schedule_state_after_disappeared schedule))
      Hselection_contact Hselected) as Hcached_bound.
  assert (Hfinal_x :
    position_x (position_z_of_schedule (schedule_final_query schedule)) =
      position_x
        (position_z_of_schedule (schedule_collision_object schedule))).
  { cbn.
    rewrite Hfinal, schedule_copy_synchronizes_object.
    destruct (schedule_disappeared_continuation schedule) as
      [Hunchanged | cached_floor_y Hx _ Hz].
    - now rewrite Hunchanged, Hselection.
    - now rewrite Hx, Hselection. }
  assert (Hfinal_z :
    position_z (position_z_of_schedule (schedule_final_query schedule)) =
      position_z
        (position_z_of_schedule (schedule_collision_object schedule))).
  { cbn.
    rewrite Hfinal, schedule_copy_synchronizes_object.
    destruct (schedule_disappeared_continuation schedule) as
      [Hunchanged | cached_floor_y Hx _ Hz].
    - now rewrite Hunchanged, Hselection.
    - now rewrite Hz, Hselection. }
  assert (Hfinal_y :
    position_y (position_z_of_schedule (schedule_final_query schedule)) <=
      896).
  { cbn.
    rewrite Hfinal, schedule_copy_synchronizes_object.
    exact Hcached_bound. }
  eapply warp_horizontal_low_y_stock_query_is_null
    with (collision :=
      position_z_of_schedule (schedule_collision_object schedule)).
  - exact Hcontact.
  - exact Hfinal_x.
  - exact Hfinal_z.
  - exact Hfinal_y.
  - exact Hstock.
Qed.

(** Aggregate admission-free boundary for the three theorem layers.  It is
    intentionally a finite-model boundary; it does not discharge any of the
    linked premises named above. *)
Definition Area1CachedFloorSelectionFiniteModelBoundary : Prop :=
  (forall collision cached_floor_y,
    upper_warp_contact collision ->
    floor_query_can_return collision cached_floor_y ->
    cached_floor_y <= 896) /\
  (forall collision final_query platform,
    upper_warp_contact collision ->
    position_x final_query = position_x collision ->
    position_z final_query = position_z collision ->
    position_y final_query <= 896 ->
    stock_area1_final_platform_query final_query platform ->
    platform = None) /\
  (forall schedule platform
      (projection : AcceptedNonfadingWarpRuntimeProjection schedule),
    upper_warp_contact
      (position_z_of_schedule (schedule_collision_object schedule)) ->
    floor_query_can_return
      (position_z_of_schedule (schedule_state_at_selection schedule))
      (schedule_y (schedule_state_after_disappeared schedule)) ->
    stock_area1_final_platform_query
      (position_z_of_schedule (schedule_final_query schedule)) platform ->
    platform = None).

Theorem area1_cached_floor_selection_finite_model_boundary_holds :
  Area1CachedFloorSelectionFiniteModelBoundary.
Proof.
  unfold Area1CachedFloorSelectionFiniteModelBoundary.
  split.
  - exact upper_warp_selected_floor_height_at_most_896.
  - split.
    + exact warp_horizontal_low_y_stock_query_is_null.
    + exact
        accepted_nonfading_warp_cached_floor_selection_stock_query_is_null.
Qed.
