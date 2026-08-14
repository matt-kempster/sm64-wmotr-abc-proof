(** Concrete finite-model witness for a genuine collision/query sample split.

    Object collision is detected before Mario's interaction/action update.
    On an accepted nonfading object warp, [ACT_DISAPPEARED] subsequently
    calls [stop_and_set_height_to_floor], the player callback copies the
    resulting State position to Mario's raw Object, and the final platform
    query reads that copied Object.

    The witness below starts at the upper vertical edge of the warp hitbox,
    Y=818, and uses the ordinary cached floor Y=768.  Thus collision observes
    (-2048,818,-1024), while the final platform query observes
    (-2048,768,-1024).  This is a real split in the checked schedule model,
    and its construction needs no input or A-press premise.

    The generated US and JP Area-1 vertex lists also compute that the audited
    centre face [(498,500,501)] would hit at the actual Y=818 collision query,
    and that its horizontal height is 768.  This finite static receipt does
    not prove that a linked live [find_floor] traversal selects that face.

    It is not a useful top installer.  The already checked finite stock-owner
    model makes the final query null, and the general cached-floor theorem
    bounds every same-sample accepted floor by Y=896.  Nor is this module a
    linked-reachability proof that clean play reaches the exact Y=818 contact;
    it isolates the smallest source-backed mechanism once such an accepted
    contact is supplied. *)

From Coq Require Import Lia List ZArith.
From compcert Require Import Integers.
From LessThanOneAPress.Proofs Require Import
  Area1CachedFloorSelectionClosure Area1FirstNull
  Area1InteractionShortCircuitClosure Area1PlatformExhaustiveness
  Area1PostCopyObjectWriterClosure Area1QueryScheduleClosure
  CollisionMeshFacts PyramidTopPU PyramidTopSurface.

Local Open Scope Z_scope.

Definition cached_floor_split_collision : SchedulePosition :=
  {| schedule_x := -2048; schedule_y := 818; schedule_z := -1024 |}.

Definition cached_floor_split_query : SchedulePosition :=
  {| schedule_x := -2048; schedule_y := 768; schedule_z := -1024 |}.

(** Exact finite-mesh query corresponding to the collision sample, rather
    than the predeclared Y=768 centre diagnostic. *)
Definition cached_floor_split_collision_area1_query : Area1IntegerQuery :=
  {| area1_query_x := -2048;
     area1_query_y := 818;
     area1_query_z := -1024 |}.

Definition cached_floor_split_audited_face_height
    (vertices : list Area1SourceVertex) : option Z :=
  match
    area1_source_triangle_vertices vertices area1_upper_warp_floor_face
  with
  | Some triangle => area1_horizontal_floor_height triangle
  | None => None
  end.

Definition cached_floor_collision_query_split_schedule :
    UpperWarpSelectionPositionSchedule.
Proof.
  refine
    {| schedule_collision_object := cached_floor_split_collision;
       schedule_state_before_geometry := cached_floor_split_collision;
       schedule_graphics_before_geometry := cached_floor_split_collision;
       schedule_state_at_selection := cached_floor_split_collision;
       schedule_state_after_disappeared := cached_floor_split_query;
       schedule_object_after_copy := cached_floor_split_query;
       schedule_final_query := cached_floor_split_query |}.
  - apply GeometryKeptState. reflexivity.
  - apply (DisappearedSnappedToCachedFloor _ _ 768);
      reflexivity.
  - reflexivity.
  - apply FinalQueryReadsCopiedObject. reflexivity.
Defined.

Definition cached_floor_collision_query_split_projection :
    AcceptedNonfadingWarpRuntimeProjection
      cached_floor_collision_query_split_schedule.
Proof.
  refine
    {| projected_handler_index := 4%nat;
       projected_handler_result := 1;
       projected_next_handler_index := None;
       projected_object_after_alias_frame := cached_floor_split_query;
       projected_object_after_external_frame := cached_floor_split_query |};
    reflexivity.
Defined.

(** Generated-initializer receipt at the actual collision query.  Membership
    puts the named face in both computed cell-(6,7) inventories; both retail
    vertex lists then make its source-shaped edge/height decision a hit, and
    independently decode the horizontal face height as 768.  Live list
    construction, traversal/selection, and reachability of Y=818 remain the
    explicit linked-execution boundary. *)
Definition Area1CachedFloorSplitStaticReceipt : Prop :=
  area1_query_x cached_floor_split_collision_area1_query =
    schedule_x
      (schedule_collision_object
        cached_floor_collision_query_split_schedule) /\
  area1_query_y cached_floor_split_collision_area1_query =
    schedule_y
      (schedule_collision_object
        cached_floor_collision_query_split_schedule) /\
  area1_query_z cached_floor_split_collision_area1_query =
    schedule_z
      (schedule_collision_object
        cached_floor_collision_query_split_schedule) /\
  Int.signed
      (partition_cell_index
        (Int.repr
          (area1_query_x cached_floor_split_collision_area1_query))) = 6 /\
  Int.signed
      (partition_cell_index
        (Int.repr
          (area1_query_z cached_floor_split_collision_area1_query))) = 7 /\
  In area1_upper_warp_floor_face
    (area1_source_floor_inventory
      area1_collision_vertices_us area1_source_triangle_stream_us 6 7) /\
  In area1_upper_warp_floor_face
    (area1_source_floor_inventory
      area1_collision_vertices_jp area1_source_triangle_stream_jp 6 7) /\
  area1_static_floor_decision
      area1_collision_vertices_us
      cached_floor_split_collision_area1_query
      area1_upper_warp_floor_face = Area1StaticFloorWouldHit /\
  area1_static_floor_decision
      area1_collision_vertices_jp
      cached_floor_split_collision_area1_query
      area1_upper_warp_floor_face = Area1StaticFloorWouldHit /\
  cached_floor_split_audited_face_height area1_collision_vertices_us =
    Some 768 /\
  cached_floor_split_audited_face_height area1_collision_vertices_jp =
    Some 768.

Theorem area1_cached_floor_split_static_receipt_holds :
  Area1CachedFloorSplitStaticReceipt.
Proof.
  unfold Area1CachedFloorSplitStaticReceipt,
    cached_floor_split_collision_area1_query,
    cached_floor_collision_query_split_schedule,
    cached_floor_split_collision, cached_floor_split_audited_face_height.
  split; [reflexivity |].
  split; [reflexivity |].
  split; [reflexivity |].
  split; [exact (proj1 concrete_pu_dynamic_partition_cell) |].
  split; [exact (proj2 concrete_pu_dynamic_partition_cell) |].
  split; [vm_compute; tauto |].
  split; [vm_compute; tauto |].
  split.
  - vm_compute. reflexivity.
  - split.
    + vm_compute. reflexivity.
    + split; vm_compute; reflexivity.
Qed.

(** This is not special to the concrete Y=818 witness.  Once the accepted
    warp-tail projection is supplied, both disappeared continuations preserve
    State X/Z, the completed copy preserves those values, and the final query
    reads that copied Object.  Therefore this entire branch is Y-only. *)
Theorem accepted_nonfading_warp_final_query_preserves_collision_xz :
  forall schedule
      (projection : AcceptedNonfadingWarpRuntimeProjection schedule),
    schedule_x (schedule_final_query schedule) =
      schedule_x (schedule_collision_object schedule) /\
    schedule_z (schedule_final_query schedule) =
      schedule_z (schedule_collision_object schedule).
Proof.
  intros schedule projection.
  pose proof
    (accepted_nonfading_warp_final_query_reads_completed_copy
      schedule projection) as Hfinal.
  pose proof
    (projected_selection_sample_matches_collision schedule projection)
      as Hselection.
  rewrite Hfinal, schedule_copy_synchronizes_object.
  destruct (schedule_disappeared_continuation schedule) as
    [Hunchanged | cached_floor_y Hx Hy Hz].
  - now rewrite Hunchanged, Hselection.
  - split.
    + now rewrite Hx, Hselection.
    + now rewrite Hz, Hselection.
Qed.

Theorem accepted_nonfading_warp_difference_is_y_only :
  forall schedule
      (projection : AcceptedNonfadingWarpRuntimeProjection schedule),
    position_differs
      (schedule_final_query schedule)
      (schedule_collision_object schedule) ->
    schedule_y (schedule_final_query schedule) <>
      schedule_y (schedule_collision_object schedule).
Proof.
  intros schedule projection Hdifference.
  pose proof
    (accepted_nonfading_warp_final_query_preserves_collision_xz
      schedule projection) as [Hx Hz].
  unfold position_differs in Hdifference.
  destruct Hdifference as [Hdifferent_x | [Hdifferent_y | Hdifferent_z]].
  - contradiction.
  - exact Hdifferent_y.
  - contradiction.
Qed.

Theorem cached_floor_split_collision_is_accepted_upper_warp_contact :
  upper_warp_contact
    (position_z_of_schedule cached_floor_split_collision).
Proof.
  unfold upper_warp_contact, horizontal_distance_squared,
    upper_warp_center, upper_warp_radius, mario_hitbox_radius,
    upper_warp_y, upper_warp_height, mario_hitbox_height,
    position_z_of_schedule, cached_floor_split_collision.
  cbn. repeat split; lia.
Qed.

Theorem cached_floor_split_floor_is_numerically_selectable :
  floor_query_can_return
    (position_z_of_schedule cached_floor_split_collision) 768.
Proof.
  unfold floor_query_can_return, find_floor_upward_buffer,
    position_z_of_schedule, cached_floor_split_collision.
  cbn. lia.
Qed.

Theorem cached_floor_split_is_a_genuine_collision_query_difference :
  position_differs
    (schedule_final_query cached_floor_collision_query_split_schedule)
    (schedule_collision_object
      cached_floor_collision_query_split_schedule) /\
  cached_floor_snap_differs_from_collision
    cached_floor_collision_query_split_schedule.
Proof.
  split.
  - unfold position_differs, cached_floor_collision_query_split_schedule,
      cached_floor_split_collision, cached_floor_split_query.
    cbn. right. left. lia.
  - unfold cached_floor_snap_differs_from_collision,
      cached_floor_collision_query_split_schedule,
      cached_floor_split_collision, cached_floor_split_query.
    cbn. split; lia.
Qed.

Theorem cached_floor_split_moves_fifty_units_downward :
  schedule_y
      (schedule_final_query cached_floor_collision_query_split_schedule) -
    schedule_y
      (schedule_collision_object cached_floor_collision_query_split_schedule) =
    -50.
Proof. reflexivity. Qed.

(** By contrast, any final sample close enough to a modeled top floor needs
    more than 459 units of upward separation from an upper-warp collision.
    This is the platform-capture threshold, which is stricter than merely
    making the earlier floor query numerically capable of seeing the top. *)
Theorem useful_top_capture_split_requires_more_than_459_upward_units :
  forall collision final_query floor_y,
    upper_warp_contact collision ->
    live_top_platform_capture final_query floor_y ->
    459 < position_y final_query - position_y collision.
Proof.
  intros collision final_query floor_y Hcontact Hcapture.
  pose proof (upper_warp_contact_y_bounds collision Hcontact) as Hcollision.
  pose proof
    (live_top_capture_y_lower_bound final_query floor_y Hcapture) as Hfinal.
  lia.
Qed.

(** The source-backed interaction projection confirms that this difference
    does not require a later handler, post-copy Object writer, alias store, or
    external write inside the finite schedule: it is exactly the cached-floor
    Y snap followed by the ordinary copy and final Object read. *)
Theorem cached_floor_split_uses_the_ordinary_accepted_warp_tail :
  projected_next_handler_index
      cached_floor_collision_query_split_schedule
      cached_floor_collision_query_split_projection = None /\
  schedule_final_query cached_floor_collision_query_split_schedule =
    schedule_object_after_copy
      cached_floor_collision_query_split_schedule /\
  cached_floor_snap_differs_from_collision
    cached_floor_collision_query_split_schedule.
Proof.
  split.
  - exact (accepted_nonfading_warp_stops_before_later_handlers
      cached_floor_collision_query_split_schedule
      cached_floor_collision_query_split_projection).
  - split.
    + exact (accepted_nonfading_warp_final_query_reads_completed_copy
        cached_floor_collision_query_split_schedule
        cached_floor_collision_query_split_projection).
    + exact (proj2
        cached_floor_split_is_a_genuine_collision_query_difference).
Qed.

(** This genuine split still cannot install any modeled stock Area-1 owner.
    Live binary32 surface traversal and owner identity remain the explicit
    refinement premise represented by [stock_area1_final_platform_query]. *)
Theorem cached_floor_split_stock_platform_query_is_null :
  forall platform,
    stock_area1_final_platform_query
      (position_z_of_schedule
        (schedule_final_query
          cached_floor_collision_query_split_schedule)) platform ->
    platform = None.
Proof.
  intros platform Hstock.
  eapply accepted_nonfading_warp_cached_floor_selection_stock_query_is_null.
  - exact cached_floor_collision_query_split_projection.
  - exact cached_floor_split_collision_is_accepted_upper_warp_contact.
  - exact cached_floor_split_floor_is_numerically_selectable.
  - exact Hstock.
Qed.

Definition Area1CachedFloorSplitWitnessBoundary : Prop :=
  upper_warp_contact
    (position_z_of_schedule cached_floor_split_collision) /\
  floor_query_can_return
    (position_z_of_schedule cached_floor_split_collision) 768 /\
  Area1CachedFloorSplitStaticReceipt /\
  position_differs
    (schedule_final_query cached_floor_collision_query_split_schedule)
    (schedule_collision_object
      cached_floor_collision_query_split_schedule) /\
  cached_floor_snap_differs_from_collision
    cached_floor_collision_query_split_schedule /\
  (forall schedule
      (projection : AcceptedNonfadingWarpRuntimeProjection schedule),
    schedule_x (schedule_final_query schedule) =
      schedule_x (schedule_collision_object schedule) /\
    schedule_z (schedule_final_query schedule) =
      schedule_z (schedule_collision_object schedule)) /\
  (forall platform,
    stock_area1_final_platform_query
      (position_z_of_schedule
        (schedule_final_query
          cached_floor_collision_query_split_schedule)) platform ->
    platform = None).

Theorem area1_cached_floor_split_witness_boundary_holds :
  Area1CachedFloorSplitWitnessBoundary.
Proof.
  unfold Area1CachedFloorSplitWitnessBoundary.
  split; [exact cached_floor_split_collision_is_accepted_upper_warp_contact |].
  split; [exact cached_floor_split_floor_is_numerically_selectable |].
  split; [exact area1_cached_floor_split_static_receipt_holds |].
  pose proof cached_floor_split_is_a_genuine_collision_query_difference
    as [Hdifferent Hsnap].
  split; [exact Hdifferent |].
  split; [exact Hsnap |].
  split.
  - exact accepted_nonfading_warp_final_query_preserves_collision_xz.
  - exact cached_floor_split_stock_platform_query_is_null.
Qed.
