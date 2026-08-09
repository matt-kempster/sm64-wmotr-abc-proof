(** Exact collision-data boundary for the Area-2 upper-entry elevator.

    This module closes the finite data and logical parts of the elevator cut:

    - the generated US/JP collision arrays contain the stated base, inner-wall,
      rim, chamber-wall, and surrounding-floor triangles;
    - the clean upper-entry position lies in the concrete shaft/bucket sweep
      cell; and
    - a first crossing of a conservative absolute adapter is impossible under
      an exhaustive list of no-A writer exclusions.

    It deliberately does not claim a retail containment theorem.  In
    particular, [SurfaceRef] is a projection-assigned stable name, dynamic
    surfaces are rebuilt in live memory, and the existing generic
    [CollisionSupportCut] has only absolute open cells.  The exact moving
    predicate and the conservative adapter are therefore kept separate.  The
    linked program must still connect the initializer ordinals below to live
    transformed surfaces, show the moving-cell-to-sweep refinement, construct
    the first crossing, and discharge every writer exclusion. *)

From Coq Require Import Bool Classical_Prop Lia List ZArith.
From compcert Require Import AST Floats Integers.
From LessThanOneAPress.Generated Require Import
  us_ssl_collision jp_ssl_collision.
From LessThanOneAPress.Proofs Require Import
  ASTFacts GameTypes InputSemantics CleanEntry CollisionMeshFacts
  ClightRefinement RouteEvidence TranscriptRouteModel FirstTargetRefinement
  FirstCrossingWriterCoverage OrdinaryMotion.

Import ListNotations.
Local Open Scope Z_scope.

(** * Initializer-level surface identities *)

Inductive ElevatorCutInitializer :=
| Area2StaticInitializer
| PyramidElevatorDynamicInitializer.

Record ElevatorCutSurfaceKey := {
  elevator_key_initializer : ElevatorCutInitializer;
  (** Zero-based triangle ordinal inside that collision initializer, across
      all surface groups in source order. *)
  elevator_key_triangle_ordinal : nat
}.

Definition area2_static_key (ordinal : nat) : ElevatorCutSurfaceKey :=
  {| elevator_key_initializer := Area2StaticInitializer;
     elevator_key_triangle_ordinal := ordinal |}.

Definition elevator_dynamic_key (ordinal : nat) : ElevatorCutSurfaceKey :=
  {| elevator_key_initializer := PyramidElevatorDynamicInitializer;
     elevator_key_triangle_ordinal := ordinal |}.

(** The dynamic initializer contains ten default triangles, two close-camera
    base-floor triangles, then 24 no-camera triangles.  Within the last group,
    the eight inner walls, eight horizontal rim faces, and eight outer walls
    form a checked partition. *)
Definition elevator_base_surface_keys : list ElevatorCutSurfaceKey :=
  map elevator_dynamic_key [10%nat; 11%nat].

Definition elevator_inner_wall_surface_keys : list ElevatorCutSurfaceKey :=
  map elevator_dynamic_key
    [12%nat; 29%nat; 30%nat; 31%nat; 32%nat; 33%nat; 34%nat; 35%nat].

Definition elevator_rim_floor_surface_keys : list ElevatorCutSurfaceKey :=
  map elevator_dynamic_key
    [13%nat; 14%nat; 15%nat; 22%nat; 23%nat; 24%nat; 25%nat; 28%nat].

Definition elevator_outer_wall_surface_keys : list ElevatorCutSurfaceKey :=
  map elevator_dynamic_key
    [16%nat; 17%nat; 18%nat; 19%nat; 20%nat; 21%nat; 26%nat; 27%nat].

(** These eight default-group triangles are the horizontal Area-2 floor at
    world Y=5222 surrounding the 819-by-819 shaft opening.  Ordinal 97 is an
    unrelated triangle and is intentionally absent. *)
Definition elevator_surrounding_static_floor_keys :
    list ElevatorCutSurfaceKey :=
  map area2_static_key
    [94%nat; 95%nat; 96%nat; 98%nat; 99%nat; 100%nat; 101%nat; 102%nat].

(** The chamber walls are no-camera-group local ordinals 97 and 101..107.
    Their whole-initializer ordinals are 1523 and 1527..1533. *)
Definition elevator_static_chamber_wall_keys :
    list ElevatorCutSurfaceKey :=
  map area2_static_key
    [1523%nat; 1527%nat; 1528%nat; 1529%nat;
     1530%nat; 1531%nat; 1532%nat; 1533%nat].

Definition elevator_collision_words_us : list Z :=
  init_int16_values
    (gvar_init us_ssl_collision.v_ssl_seg7_collision_pyramid_elevator).

Definition elevator_collision_words_jp : list Z :=
  init_int16_values
    (gvar_init jp_ssl_collision.v_ssl_seg7_collision_pyramid_elevator).

Definition area2_collision_words_us : list Z :=
  init_int16_values
    (gvar_init us_ssl_collision.v_ssl_seg7_area_2_collision).

Definition area2_collision_words_jp : list Z :=
  init_int16_values
    (gvar_init jp_ssl_collision.v_ssl_seg7_area_2_collision).

(** Offsets follow directly from the generated arrays:

    - 2 header words + 20*3 vertices + 2 default-group words + 10*3
      default triangles = 94, so the two base triangles begin at word 96;
    - the no-camera triangles begin at word 104;
    - Area 2 has 2 + 1080*3 words before its first group, whose 1,068 default
      triangles begin at word 3244; and
    - accounting for the ordinary and special-width groups places the Area-2
      no-camera triangle payload at word 7678. *)
Definition elevator_base_triangles_from_words (words : list Z) :=
  triples_from_words (firstn 6 (skipn 96 words)).

Definition elevator_no_cam_triangles_from_words (words : list Z) :=
  triples_from_words (firstn 72 (skipn 104 words)).

Definition area2_default_triangles_from_words (words : list Z) :=
  triples_from_words (firstn (3 * 1068) (skipn 3244 words)).

Definition area2_no_cam_triangles_from_words (words : list Z) :=
  triples_from_words (firstn (3 * 132) (skipn 7678 words)).

Definition select_nth_options {A : Type}
    (values : list A) (indices : list nat) : list (option A) :=
  map (nth_error values) indices.

Definition elevator_base_triangles : list (Z * Z * Z) :=
  [(0, 1, 2); (0, 2, 3)].

Definition elevator_no_cam_triangles : list (Z * Z * Z) :=
  [(10, 12, 5);
   (4, 5, 6);
   (6, 5, 7);
   (6, 7, 8);
   (6, 2, 4);
   (6, 1, 2);
   (8, 1, 6);
   (8, 0, 1);
   (4, 2, 3);
   (4, 3, 9);
   (4, 10, 5);
   (9, 10, 4);
   (8, 7, 11);
   (8, 11, 9);
   (9, 0, 8);
   (9, 3, 0);
   (9, 11, 10);
   (5, 12, 13);
   (5, 13, 7);
   (11, 14, 10);
   (10, 14, 12);
   (7, 13, 15);
   (7, 15, 11);
   (11, 15, 14)].

Definition elevator_inner_wall_triangles : list (Z * Z * Z) :=
  [(10, 12, 5);
   (5, 12, 13); (5, 13, 7);
   (11, 14, 10); (10, 14, 12);
   (7, 13, 15); (7, 15, 11); (11, 15, 14)].

Definition elevator_rim_floor_triangles : list (Z * Z * Z) :=
  [(4, 5, 6); (6, 5, 7); (6, 7, 8);
   (4, 10, 5); (9, 10, 4);
   (8, 7, 11); (8, 11, 9); (9, 11, 10)].

Definition elevator_outer_wall_triangles : list (Z * Z * Z) :=
  [(6, 2, 4); (6, 1, 2); (8, 1, 6); (8, 0, 1);
   (4, 2, 3); (4, 3, 9); (9, 0, 8); (9, 3, 0)].

Definition elevator_selected_no_cam_triangles
    (triangles : list (Z * Z * Z)) : Prop :=
  select_nth_options triangles
      [0%nat; 17%nat; 18%nat; 19%nat; 20%nat; 21%nat; 22%nat; 23%nat] =
    map (@Some (Z * Z * Z)) elevator_inner_wall_triangles /\
  select_nth_options triangles
      [1%nat; 2%nat; 3%nat; 10%nat; 11%nat; 12%nat; 13%nat; 16%nat] =
    map (@Some (Z * Z * Z)) elevator_rim_floor_triangles /\
  select_nth_options triangles
      [4%nat; 5%nat; 6%nat; 7%nat; 8%nat; 9%nat; 14%nat; 15%nat] =
    map (@Some (Z * Z * Z)) elevator_outer_wall_triangles.

Definition area2_surrounding_floor_triangles : list (Z * Z * Z) :=
  [(475, 402, 401);
   (475, 401, 477);
   (476, 402, 475);
   (477, 401, 403);
   (477, 403, 592);
   (476, 406, 402);
   (403, 406, 476);
   (403, 476, 592)].

Definition area2_chamber_wall_triangles : list (Z * Z * Z) :=
  [(355, 405, 402);
   (354, 401, 402);
   (354, 403, 401);
   (354, 404, 403);
   (354, 402, 405);
   (355, 406, 403);
   (355, 403, 404);
   (355, 402, 406)].

Definition selected_area2_elevator_cut_triangles
    (default_triangles no_cam_triangles : list (Z * Z * Z)) : Prop :=
  select_nth_options default_triangles
      [94%nat; 95%nat; 96%nat; 98%nat;
       99%nat; 100%nat; 101%nat; 102%nat] =
    map (@Some (Z * Z * Z)) area2_surrounding_floor_triangles /\
  select_nth_options no_cam_triangles
      [97%nat; 101%nat; 102%nat; 103%nat;
       104%nat; 105%nat; 106%nat; 107%nat] =
    map (@Some (Z * Z * Z)) area2_chamber_wall_triangles.

Theorem elevator_cut_triangles_exact_us :
  elevator_base_triangles_from_words elevator_collision_words_us =
    elevator_base_triangles /\
  elevator_no_cam_triangles_from_words elevator_collision_words_us =
    elevator_no_cam_triangles /\
  elevator_selected_no_cam_triangles elevator_no_cam_triangles.
Proof.
  vm_compute.
  repeat split.
Qed.

Theorem elevator_cut_triangles_exact_jp :
  elevator_base_triangles_from_words elevator_collision_words_jp =
    elevator_base_triangles /\
  elevator_no_cam_triangles_from_words elevator_collision_words_jp =
    elevator_no_cam_triangles /\
  elevator_selected_no_cam_triangles elevator_no_cam_triangles.
Proof.
  vm_compute.
  repeat split.
Qed.

Theorem area2_elevator_cut_triangles_exact_us :
  selected_area2_elevator_cut_triangles
    (area2_default_triangles_from_words area2_collision_words_us)
    (area2_no_cam_triangles_from_words area2_collision_words_us).
Proof.
  vm_compute.
  split; reflexivity.
Qed.

Theorem area2_elevator_cut_triangles_exact_jp :
  selected_area2_elevator_cut_triangles
    (area2_default_triangles_from_words area2_collision_words_jp)
    (area2_no_cam_triangles_from_words area2_collision_words_jp).
Proof.
  vm_compute.
  split; reflexivity.
Qed.

Theorem elevator_no_cam_surface_partition_is_exact :
  NoDup
    ([0%nat; 17%nat; 18%nat; 19%nat; 20%nat; 21%nat; 22%nat; 23%nat] ++
     [1%nat; 2%nat; 3%nat; 10%nat; 11%nat; 12%nat; 13%nat; 16%nat] ++
     [4%nat; 5%nat; 6%nat; 7%nat; 8%nat; 9%nat; 14%nat; 15%nat]) /\
  length
    ([0%nat; 17%nat; 18%nat; 19%nat; 20%nat; 21%nat; 22%nat; 23%nat] ++
     [1%nat; 2%nat; 3%nat; 10%nat; 11%nat; 12%nat; 13%nat; 16%nat] ++
     [4%nat; 5%nat; 6%nat; 7%nat; 8%nat; 9%nat; 14%nat; 15%nat]) = 24%nat.
Proof.
  split.
  - repeat constructor; simpl; intuition congruence.
  - reflexivity.
Qed.

(** * Exact fixed and moving cells *)

Definition elevator_f32_integer (value : Z) : float32 :=
  Float32.of_int (Int.repr value).

Definition elevator_vec3_integer (x y z : Z) : Vec3f :=
  {| vec_x := elevator_f32_integer x;
     vec_y := elevator_f32_integer y;
     vec_z := elevator_f32_integer z |}.

(** The fixed entry chamber has walls at X=-409/410, Z=-153/666, with its
    lower and upper horizontal boundaries at Y=5222/5734. *)
Definition upper_entry_chamber_cell : AxisAlignedOpenCell :=
  {| open_cell_min := elevator_vec3_integer (-409) 5222 (-153);
     open_cell_max := elevator_vec3_integer 410 5734 666 |}.

(** The moving bucket interior uses the full inner-wall bounds, not the
    narrower fixed entry chamber.  At horizontal origin (0,256), local Z
    [-460,461] becomes world Z [-204,717].  The Y interval is the actual mesh
    skirt-to-rim interval.  The linked proof must establish zero
    pitch/yaw/roll and the horizontal origin before translation alone is
    sound. *)
Definition upper_elevator_moving_local_cell : AxisAlignedOpenCell :=
  {| open_cell_min := elevator_vec3_integer (-460) (-50) (-460);
     open_cell_max := elevator_vec3_integer 461 256 461 |}.

(** The route-source interior stops at the greatest binary32 value below the
    local rim height [256.0f].  [position_in_open_cell] is actually a closed
    comparison, despite its historical name, so using the mesh's 256 endpoint
    here would classify a rim point as both inside and on the target rim. *)
Definition upper_elevator_moving_source_local_cell : AxisAlignedOpenCell :=
  {| open_cell_min := open_cell_min upper_elevator_moving_local_cell;
     open_cell_max :=
       {| vec_x := elevator_f32_integer 461;
          vec_y := f32_bits 1132462079;  (* 0x437fffff, below 256.0f *)
          vec_z := elevator_f32_integer 461 |} |}.

(** This fixed box is only the union envelope swept by the translated bucket
    as its origin moves from Y=4966 down to Y=128.  It is not itself an exact
    open collision component: it contains positions belonging to different
    elevator times.  The exact source predicate is the translated local cell
    above; a linked pose/refinement theorem must justify use of this envelope
    by [CollisionSupportCut]. *)
Definition upper_elevator_bucket_sweep_cell : AxisAlignedOpenCell :=
  {| open_cell_min := elevator_vec3_integer (-460) 78 (-204);
     open_cell_max := elevator_vec3_integer 461 5222 717 |}.

Definition vec3f_sub (position origin : Vec3f) : Vec3f :=
  {| vec_x := Float32.sub (vec_x position) (vec_x origin);
     vec_y := Float32.sub (vec_y position) (vec_y origin);
     vec_z := Float32.sub (vec_z position) (vec_z origin) |}.

Definition position_in_translated_cell
    (position origin : Vec3f) (cell : AxisAlignedOpenCell) : bool :=
  position_in_open_cell (vec3f_sub position origin) cell.

Definition upper_elevator_initial_origin : Vec3f :=
  elevator_vec3_integer 0 4966 256.

Theorem upper_entry_position_is_in_exact_chamber_cell :
  position_in_open_cell upper_entry_position upper_entry_chamber_cell = true.
Proof. vm_compute. reflexivity. Qed.

Theorem upper_entry_position_is_in_source_cell_union :
  position_in_open_cell
    upper_entry_position upper_entry_chamber_cell = true /\
  position_in_translated_cell upper_entry_position
    upper_elevator_initial_origin upper_elevator_moving_local_cell = false.
Proof. vm_compute. split; reflexivity. Qed.

Lemma clean_upper_entry_has_exact_position :
  forall state,
    CleanPyramidEntry state ->
    state_entrance state = UpperEntrance ->
    mario_position (state_mario_kinematics state) = upper_entry_position.
Proof.
  intros state Hclean Hentrance.
  rewrite (clean_current_kinematics state Hclean).
  pose proof (clean_entry_snapshot state Hclean) as Hsnapshot.
  unfold entry_snapshot_for in Hsnapshot.
  rewrite Hentrance in Hsnapshot.
  tauto.
Qed.

(** * Projection-named surface cut *)

(** [SurfaceRef] is deliberately not manufactured from the initializer
    ordinal.  A linked projection supplies the stable name and proves that
    different initializer keys remain different. *)
Record ElevatorCutSurfaceProjection := {
  elevator_projected_object_ref : ObjectRef;
  elevator_surface_ref : ElevatorCutSurfaceKey -> SurfaceRef;
  elevator_surface_ref_injective :
    forall left right,
      elevator_surface_ref left = elevator_surface_ref right -> left = right;
  elevator_surface_ref_in_area2 :
    forall key,
      surface_area (elevator_surface_ref key) = pyramid_area_id
}.

Definition elevator_refs
    (projection : ElevatorCutSurfaceProjection)
    (keys : list ElevatorCutSurfaceKey) : list SurfaceRef :=
  map (elevator_surface_ref projection) keys.

(** The moving-relative candidate predicates are deliberately separate from
    the absolute [CollisionSupportCut] adapter below.  The local cell is a
    conservative wall-bounds box, not a connected collision component. *)
Definition stock_area2_elevator_object
    (projection : ElevatorCutSurfaceProjection)
    (elevator : ObjectState) : Prop :=
  object_ref_equal (object_ref elevator)
    (elevator_projected_object_ref projection) /\
  active_object elevator /\
  object_area elevator = pyramid_area_id /\
  vec_x (object_position elevator) = elevator_f32_integer 0 /\
  vec_z (object_position elevator) = elevator_f32_integer 256 /\
  f32_closed_between
    (elevator_f32_integer 128)
    (vec_y (object_position elevator))
    (elevator_f32_integer 4966) = true.

Definition UpperElevatorRelativeSourceCandidate
    (projection : ElevatorCutSurfaceProjection)
    (state : GameState) : Prop :=
  position_in_open_cell
    (mario_position (state_mario_kinematics state))
    upper_entry_chamber_cell = true \/
  exists elevator,
    In elevator (state_object_pool state) /\
    stock_area2_elevator_object projection elevator /\
    (In (mario_floor (state_mario_kinematics state))
        (elevator_refs projection elevator_base_surface_keys) \/
     position_in_translated_cell
       (mario_position (state_mario_kinematics state))
       (object_position elevator)
       upper_elevator_moving_source_local_cell = true).

Definition UpperElevatorRelativeTargetCandidate
    (projection : ElevatorCutSurfaceProjection)
    (state : GameState) : Prop :=
  In (mario_floor (state_mario_kinematics state))
    (elevator_refs projection
      (elevator_rim_floor_surface_keys ++
       elevator_surrounding_static_floor_keys)).

(** [GameState] does not yet connect its floor name to a transformed plane and
    position.  The live collision refinement must therefore establish this
    endpoint separation rather than obtaining it from unrelated ghost fields. *)
Definition UpperElevatorRelativeEndpointSeparated
    (projection : ElevatorCutSurfaceProjection)
    (state : GameState) : Prop :=
  UpperElevatorRelativeSourceCandidate projection state ->
  UpperElevatorRelativeTargetCandidate projection state ->
  False.

(** Owner-only dynamic supports are intentionally empty.  The base, walls,
    and rim all belong to the same elevator object, so an owner-only entry
    would put a rim state on the source side as well.  Specific transformed
    [SurfaceRef] values preserve the necessary distinction. *)
(** Conservative absolute adapter.  Its swept cell is an over-approximation
    across all elevator poses and can overlap a rim support at another pose;
    it is not the exact moving cut. *)
Definition upper_elevator_absolute_adapter_cut
    (projection : ElevatorCutSurfaceProjection) : CollisionSupportCut :=
  {| cut_entrance := UpperEntrance;
     cut_source_static_supports :=
       elevator_refs projection elevator_base_surface_keys;
     cut_target_static_supports :=
       elevator_refs projection
         (elevator_rim_floor_surface_keys ++
          elevator_surrounding_static_floor_keys);
     cut_source_dynamic_supports := [];
     cut_target_dynamic_supports := [];
     cut_source_open_cells :=
       [upper_entry_chamber_cell; upper_elevator_bucket_sweep_cell];
     cut_target_open_cells := [] |}.

Theorem clean_upper_entry_is_on_adapter_source :
  forall projection initial,
    CleanPyramidEntry initial ->
    state_entrance initial = UpperEntrance ->
    StateOnCutSourceSide
      (upper_elevator_absolute_adapter_cut projection) initial.
Proof.
  intros projection initial Hclean Hentrance.
  unfold StateOnCutSourceSide, upper_elevator_absolute_adapter_cut.
  eapply InCollisionOpenCell with (cell := upper_entry_chamber_cell).
  - cbn. auto.
  - rewrite (clean_upper_entry_has_exact_position initial Hclean Hentrance).
    exact upper_entry_position_is_in_exact_chamber_cell.
Qed.

(** A concrete linked proof must show that the translated live bucket cell is
    contained in the absolute sweep used above.  Keeping the actual elevator
    object and its transform in this premise prevents the absolute box from
    silently standing in for moving geometry. *)
Definition MovingElevatorCellToSweepRefinementObligation : Prop :=
  forall state elevator,
    In elevator (state_object_pool state) ->
    active_object elevator ->
    object_area elevator = pyramid_area_id ->
    vec_x (object_position elevator) = elevator_f32_integer 0 ->
    vec_z (object_position elevator) = elevator_f32_integer 256 ->
    f32_closed_between
      (elevator_f32_integer 128)
      (vec_y (object_position elevator))
      (elevator_f32_integer 4966) = true ->
    position_in_translated_cell
      (mario_position (state_mario_kinematics state))
      (object_position elevator) upper_elevator_moving_local_cell = true ->
    position_in_open_cell
      (mario_position (state_mario_kinematics state))
      upper_elevator_bucket_sweep_cell = true.

Definition relevant_elevator_cut_surface_key
    (key : ElevatorCutSurfaceKey) : Prop :=
  In key
    (elevator_base_surface_keys ++ elevator_inner_wall_surface_keys ++
     elevator_rim_floor_surface_keys ++ elevator_outer_wall_surface_keys ++
     elevator_surrounding_static_floor_keys ++
     elevator_static_chamber_wall_keys).

(** The live surface bridge is deliberately a semantic obligation, not a
    theorem about the raw initializer.  It requires each relevant key to have
    the exact projected reference and separately exposes memory decoding,
    owner/transform, and collision-list membership.  The three relations must
    themselves be instantiated by linked Clight predicates; this definition
    does not manufacture a live surface. *)
Definition LinkedElevatorSurfaceProjectionObligation
    (projection : ElevatorCutSurfaceProjection)
    (clight_state_is_relevant : Clight.state -> Prop)
    (live_surface_decodes_key :
      Clight.state -> ElevatorCutSurfaceKey -> SurfaceRef -> Prop)
    (live_surface_has_owner_and_transform :
      Clight.state -> ElevatorCutSurfaceKey -> SurfaceRef -> Prop)
    (live_surface_is_inserted :
      Clight.state -> ElevatorCutSurfaceKey -> SurfaceRef -> Prop) : Prop :=
  forall clight_state key,
    clight_state_is_relevant clight_state ->
    relevant_elevator_cut_surface_key key ->
    live_surface_decodes_key clight_state key
      (elevator_surface_ref projection key) /\
    live_surface_has_owner_and_transform clight_state key
      (elevator_surface_ref projection key) /\
    live_surface_is_inserted clight_state key
      (elevator_surface_ref projection key).

(** * Checked no-A ascent subkernel *)

Definition UpperElevatorCheckedGeometryAndAscentKernel : Prop :=
  pyramid_elevator_vertices_us = pyramid_elevator_vertices /\
  pyramid_elevator_vertices_jp = pyramid_elevator_vertices /\
  collision_vertex_bounds pyramid_elevator_vertices =
    (Some (-511, 512), Some (-50, 256), Some (-511, 512)) /\
  (elevator_base_triangles_from_words elevator_collision_words_us =
     elevator_base_triangles) /\
  (elevator_base_triangles_from_words elevator_collision_words_jp =
     elevator_base_triangles) /\
  elevator_selected_no_cam_triangles elevator_no_cam_triangles /\
  selected_area2_elevator_cut_triangles
    (area2_default_triangles_from_words area2_collision_words_us)
    (area2_no_cam_triangles_from_words area2_collision_words_us) /\
  selected_area2_elevator_cut_triangles
    (area2_default_triangles_from_words area2_collision_words_jp)
    (area2_no_cam_triangles_from_words area2_collision_words_jp) /\
  position_in_open_cell
    upper_entry_position upper_entry_chamber_cell = true /\
  UpperEntryDescentSourceShapeKernel /\
  UpperCandidateActionSourceShapeKernel /\
  (forall frames,
    held_a_jump_kick_elevator_relative_ascent frames <= 128) /\
  (forall frames,
    rollout_elevator_relative_ascent frames <= 220) /\
  wing_cap_rollout_relative_rise = 228 /\
  128 < pyramid_elevator_cage_clearance /\
  220 < pyramid_elevator_cage_clearance /\
  wing_cap_rollout_relative_rise < pyramid_elevator_cage_clearance.

Theorem upper_elevator_checked_geometry_and_ascent_kernel :
  UpperElevatorCheckedGeometryAndAscentKernel.
Proof.
  unfold UpperElevatorCheckedGeometryAndAscentKernel.
  refine (conj pyramid_elevator_vertices_exact_us _).
  refine (conj pyramid_elevator_vertices_exact_jp _).
  refine (conj pyramid_elevator_generated_vertex_bounds _).
  refine (conj (proj1 elevator_cut_triangles_exact_us) _).
  refine (conj (proj1 elevator_cut_triangles_exact_jp) _).
  refine (conj (proj2 (proj2 elevator_cut_triangles_exact_us)) _).
  refine (conj area2_elevator_cut_triangles_exact_us _).
  refine (conj area2_elevator_cut_triangles_exact_jp _).
  refine (conj upper_entry_position_is_in_exact_chamber_cell _).
  refine (conj upper_entry_descent_source_shape_kernel_checked _).
  refine (conj upper_candidate_action_source_shape_kernel_checked _).
  refine (conj held_a_jump_kick_elevator_relative_ascent_bound _).
  refine (conj rollout_elevator_relative_ascent_bound _).
  refine (conj wing_cap_rollout_relative_rise_is_228 _).
  refine (conj held_a_jump_kick_relative_ascent_below_cage_clearance _).
  refine (conj rollout_relative_ascent_below_cage_clearance _).
  exact wing_cap_rollout_arithmetic_below_integer_wall_clearance.
Qed.

(** This checked kernel closes only the stated action/arithmetic cases.  It
    does not establish their reachability, exhaust all clean actions, execute
    four real quarter steps, or show which live walls/floors are selected. *)

(** * Moving-relative and adapter retail-closure interfaces *)

Definition UpperElevatorCrossingContext
    (projection : ElevatorCutSurfaceProjection)
    {clight_projection run initial certificate region target_frame}
    (crossing :
      FirstValidatedCutCrossingAt
        clight_projection run initial certificate region target_frame) : Prop :=
  CleanPyramidEntry initial /\
  state_entrance initial = UpperEntrance /\
  first_crossing_cut _ _ _ _ _ _ crossing =
    upper_elevator_absolute_adapter_cut projection /\
  fewer_than_one_a_press (project_inputs clight_projection run).

(** Each conjunct is one specific writer/domain exclusion.  This is not an
    oracle predicate equivalent to target impossibility: it says exactly which
    cause of the already-constructed first crossing must be refuted. *)
Definition UpperElevatorNoAWriterExclusions
    (projection : ElevatorCutSurfaceProjection)
    (clight_projection : ClightObservationProjection) : Prop :=
  forall run initial certificate region target_frame
      (crossing :
        FirstValidatedCutCrossingAt
          clight_projection run initial certificate region target_frame),
    UpperElevatorCrossingContext projection crossing ->
    ~ CrossingUsesLocalOrdinaryPhysics crossing /\
    ~ CrossingUsesPositionWriter crossing FirstWriterPlatformDisplacement /\
    ~ CrossingUsesPositionWriter crossing FirstWriterObjectImpulse /\
    ~ CrossingUsesPositionWriter crossing FirstWriterCollisionClip /\
    ~ CrossingUsesCoordinateAliasOrOutOfBounds crossing /\
    ~ CrossingUsesPositionWriter crossing FirstWriterLifecycleEntry /\
    ~ CrossingUsesSupportSelection crossing.

Theorem upper_elevator_no_a_first_crossing_is_closed :
  forall surface_projection clight_projection,
    UpperElevatorNoAWriterExclusions
      surface_projection clight_projection ->
    forall run initial certificate region target_frame
        (crossing :
          FirstValidatedCutCrossingAt
            clight_projection run initial certificate region target_frame),
      UpperElevatorCrossingContext surface_projection crossing ->
      False.
Proof.
  intros surface_projection clight_projection Hexclusions
    run initial certificate region target_frame crossing Hcontext.
  destruct (Hexclusions run initial certificate region target_frame
    crossing Hcontext) as
    (Hordinary & Hplatform & Hobject & Hclip & Halias & Hlifecycle & Hsupport).
  pose proof
    (validated_pre_target_first_crossing_writer_coverage
      clight_projection run initial certificate region target_frame crossing)
    as Hcoverage.
  inversion Hcoverage as
    [writer Hwriter Hchanged | Hsame Hsupport_change]; subst.
  - inversion Hwriter; subst.
    + destruct (classic (CoordinatesInLocalCastDomain after))
        as [Hlocal | Hnonlocal].
      * apply Hordinary.
        exists before, after. split; [symmetry; assumption |].
        split; assumption.
      * apply Halias.
        exists before, after. split; [symmetry; assumption |].
        split; assumption.
    + apply Hplatform. split; assumption.
    + apply Hobject. split; assumption.
    + apply Hclip. split; assumption.
    + apply Hlifecycle. split; assumption.
  - apply Hsupport. split; assumption.
Qed.

Definition UpperElevatorAdapterCutConstructionObligation
    (surface_projection : ElevatorCutSurfaceProjection)
    (clight_projection : ClightObservationProjection) : Prop :=
  forall run initial
      (certificate :
        ClightFrameRefinementCertificate clight_projection run initial)
      trace region target_frame target_observation,
    CleanPyramidEntry initial ->
    state_entrance initial = UpperEntrance ->
    ClightRouteTraceProjection
      clight_projection run initial certificate trace ->
    first_target_observation_at
      trace region target_frame target_observation ->
    exists crossing :
      FirstValidatedCutCrossingAt
        clight_projection run initial certificate region target_frame,
      first_crossing_cut _ _ _ _ _ _ crossing =
        upper_elevator_absolute_adapter_cut surface_projection.

(** The stronger construction records the moving-relative candidate sides at the
    same endpoint.  This prevents the absolute sweep adapter from silently
    serving as the geometry proof. *)
Definition UpperElevatorRelativeCutConstructionObligation
    (surface_projection : ElevatorCutSurfaceProjection)
    (clight_projection : ClightObservationProjection) : Prop :=
  forall run initial
      (certificate :
        ClightFrameRefinementCertificate clight_projection run initial)
      trace region target_frame target_observation,
    CleanPyramidEntry initial ->
    state_entrance initial = UpperEntrance ->
    ClightRouteTraceProjection
      clight_projection run initial certificate trace ->
    first_target_observation_at
      trace region target_frame target_observation ->
    exists crossing :
      FirstValidatedCutCrossingAt
        clight_projection run initial certificate region target_frame,
      first_crossing_cut _ _ _ _ _ _ crossing =
        upper_elevator_absolute_adapter_cut surface_projection /\
      UpperElevatorRelativeSourceCandidate surface_projection
        (first_crossing_before _ _ _ _ _ _ crossing) /\
      UpperElevatorRelativeTargetCandidate surface_projection
        (first_crossing_after _ _ _ _ _ _ crossing) /\
      UpperElevatorRelativeEndpointSeparated surface_projection
        (first_crossing_after _ _ _ _ _ _ crossing).

(** [FirstValidatedCutCrossingAt] requires a strictly earlier rendered frame.
    This named residual therefore requires every actual projected target-event
    frame to have that earlier crossing.  A real same-frame or earlier
    transient crossing makes the obligation false until exact program-point
    semantics extend the interface. *)
Definition UpperElevatorSameFrameCollisionPhaseCutRefinementObligation
    (surface_projection : ElevatorCutSurfaceProjection)
    (clight_projection : ClightObservationProjection) : Prop :=
  forall run initial certificate,
    CleanPyramidEntry initial ->
    state_entrance initial = UpperEntrance ->
    fewer_than_one_a_press (project_inputs clight_projection run) ->
    NoSameFrameOrTransientCutEscape
      clight_projection run initial certificate
      (upper_elevator_absolute_adapter_cut surface_projection).

Theorem upper_elevator_no_a_target_access_is_closed_under_adapter_obligations :
  forall surface_projection clight_projection,
    UpperElevatorAdapterCutConstructionObligation
      surface_projection clight_projection ->
    UpperElevatorNoAWriterExclusions
      surface_projection clight_projection ->
    forall run initial certificate trace,
      CleanPyramidEntry initial ->
      state_entrance initial = UpperEntrance ->
      ClightRouteTraceProjection
        clight_projection run initial certificate trace ->
      fewer_than_one_a_press (project_inputs clight_projection run) ->
      reaches_any_target_region trace ->
      False.
Proof.
  intros surface_projection clight_projection Hconstruction Hexclusions
    run initial certificate trace Hclean Hupper Htrace Hno_a Htarget.
  destruct (reaches_any_target_has_first_exact_occurrence trace Htarget)
    as [region [target_frame [target_observation Hfirst]]].
  destruct
    (Hconstruction run initial certificate trace region target_frame
      target_observation Hclean Hupper Htrace Hfirst)
    as [crossing Hcut].
  eapply (upper_elevator_no_a_first_crossing_is_closed
    surface_projection clight_projection Hexclusions
    run initial certificate region target_frame crossing).
  unfold UpperElevatorCrossingContext.
  split; [exact Hclean |].
  split; [exact Hupper |].
  split; [exact Hcut | exact Hno_a].
Qed.

Theorem upper_elevator_no_a_target_access_is_closed_under_relative_obligations :
  forall surface_projection clight_projection,
    UpperElevatorRelativeCutConstructionObligation
      surface_projection clight_projection ->
    UpperElevatorNoAWriterExclusions
      surface_projection clight_projection ->
    forall run initial certificate trace,
      CleanPyramidEntry initial ->
      state_entrance initial = UpperEntrance ->
      ClightRouteTraceProjection
        clight_projection run initial certificate trace ->
      fewer_than_one_a_press (project_inputs clight_projection run) ->
      reaches_any_target_region trace ->
      False.
Proof.
  intros surface_projection clight_projection
    Hconstruction Hexclusions
    run initial certificate trace Hclean Hupper Htrace Hno_a Htarget.
  destruct (reaches_any_target_has_first_exact_occurrence trace Htarget)
    as [region [target_frame [target_observation Hfirst]]].
  destruct
    (Hconstruction run initial certificate trace region target_frame
      target_observation Hclean Hupper Htrace Hfirst)
    as [crossing [Hcut [_ [_ _]]]].
  eapply (upper_elevator_no_a_first_crossing_is_closed
    surface_projection clight_projection Hexclusions
    run initial certificate region target_frame crossing).
  unfold UpperElevatorCrossingContext.
  split; [exact Hclean |].
  split; [exact Hupper |].
  split; [exact Hcut | exact Hno_a].
Qed.

(** This remains an adapter-based writer contradiction enriched with
    moving-relative endpoint witnesses; it is not yet a writer theorem over a
    native moving-relative cut.  It is reduced to two semantic tasks: construct
    that endpoint (and its conservative adapter witness) from the linked run and
    discharge the seven enumerated writer/domain cases.  The checked
    initializer and ascent arithmetic above do not discharge either task. *)
