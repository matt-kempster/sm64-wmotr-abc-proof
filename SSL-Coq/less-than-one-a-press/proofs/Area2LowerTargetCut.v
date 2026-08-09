(* Exact source receipts and a sound proof boundary for the lower Area-2
   access cut.

   This module does not use a floor number, "above the second pole", or a
   bare Mario-Y threshold as the cut.  The static part is identified by the
   source ordinals of eight upward ring-triangle records and eight candidate
   vertical shaft-wall records.  Formal target-side membership uses the ring
   records plus a conservative union of four closed finite binary32 boxes over
   the ring footprint, deliberately excluding the central pole shaft.  The
   wall records remain separator evidence; none of this is yet a linked
   collision-object/hitbox component.

   The source-ordinal-to-[SurfaceRef] map remains an argument: [SurfaceRef] is
   a projection-assigned name, not a source triangle ordinal.  The nearby
   horizontal Grindel is recorded separately for moving-geometry/downstream
   analysis; its object-pool reference likewise cannot be guessed without an
   allocation epoch.  The linked-memory obligations are named below. *)

From Coq Require Import Bool Classical_Prop Lia List ZArith.
From compcert Require Import AST Floats Integers.
From LessThanOneAPress.Generated Require Import
  us_ssl_collision jp_ssl_collision us_ssl_script jp_ssl_script.
From LessThanOneAPress.Proofs Require Import
  ASTFacts GameTypes InputSemantics CleanEntry AreaTransitions
  CollisionMeshFacts RouteEvidence ClightRefinement TranscriptRouteModel
  FirstTargetRefinement FirstCrossingWriterCoverage.

Import ListNotations.
Local Open Scope Z_scope.

(** * Generated Area-2 collision receipts *)

Definition area2_collision_words_us : list Z :=
  init_int16_values
    (gvar_init us_ssl_collision.v_ssl_seg7_area_2_collision).

Definition area2_collision_words_jp : list Z :=
  init_int16_values
    (gvar_init jp_ssl_collision.v_ssl_seg7_area_2_collision).

Definition area2_triangle_block
    (payload_offset triangle_count : nat) (words : list Z)
    : list (Z * Z * Z) :=
  firstn triangle_count (triples_from_words (skipn payload_offset words)).

(* The default group begins immediately after the 1,080 vertex triples.  The
   CAMERA_FREE_ROAM and NO_CAM_COLLISION offsets account for every preceding
   three- or four-word triangle record. *)
Definition area2_default_triangles_us : list (Z * Z * Z) :=
  area2_triangle_block 3244 1068 area2_collision_words_us.

Definition area2_default_triangles_jp : list (Z * Z * Z) :=
  area2_triangle_block 3244 1068 area2_collision_words_jp.

Definition area2_camera_free_roam_triangles_us : list (Z * Z * Z) :=
  area2_triangle_block 7595 27 area2_collision_words_us.

Definition area2_camera_free_roam_triangles_jp : list (Z * Z * Z) :=
  area2_triangle_block 7595 27 area2_collision_words_jp.

Definition area2_no_cam_collision_triangles_us : list (Z * Z * Z) :=
  area2_triangle_block 7678 132 area2_collision_words_us.

Definition area2_no_cam_collision_triangles_jp : list (Z * Z * Z) :=
  area2_triangle_block 7678 132 area2_collision_words_jp.

Definition lower_pole_platform_triangles : list (Z * Z * Z) :=
  [(593, 1010, 807); (593, 805, 1010)].

Definition lower_ring_triangles : list (Z * Z * Z) :=
  [(283, 298, 284);
   (284, 298, 285);
   (284, 285, 299);
   (285, 300, 301);
   (285, 301, 299);
   (283, 286, 298);
   (286, 301, 300);
   (286, 283, 301)].

Definition lower_aperture_wall_triangles : list (Z * Z * Z) :=
  [(285, 407, 408);
   (298, 407, 285);
   (285, 408, 300);
   (300, 408, 409);
   (300, 409, 286);
   (298, 410, 407);
   (286, 410, 298);
   (286, 409, 410)].

Theorem lower_area2_group_headers_exact_us :
  firstn 2 (skipn 7593 area2_collision_words_us) = [102; 27] /\
  firstn 2 (skipn 7676 area2_collision_words_us) = [118; 132].
Proof. vm_compute. split; reflexivity. Qed.

Theorem lower_area2_group_headers_exact_jp :
  firstn 2 (skipn 7593 area2_collision_words_jp) = [102; 27] /\
  firstn 2 (skipn 7676 area2_collision_words_jp) = [118; 132].
Proof. vm_compute. split; reflexivity. Qed.

Theorem lower_pole_platform_triangles_exact_us :
  [nth_error area2_default_triangles_us 746;
   nth_error area2_default_triangles_us 753] =
  map (@Some (Z * Z * Z)) lower_pole_platform_triangles.
Proof. vm_compute. reflexivity. Qed.

Theorem lower_pole_platform_triangles_exact_jp :
  [nth_error area2_default_triangles_jp 746;
   nth_error area2_default_triangles_jp 753] =
  map (@Some (Z * Z * Z)) lower_pole_platform_triangles.
Proof. vm_compute. reflexivity. Qed.

Theorem lower_ring_triangles_exact_us :
  firstn 8 (skipn 15 area2_camera_free_roam_triangles_us) =
    lower_ring_triangles.
Proof. vm_compute. reflexivity. Qed.

Theorem lower_ring_triangles_exact_jp :
  firstn 8 (skipn 15 area2_camera_free_roam_triangles_jp) =
    lower_ring_triangles.
Proof. vm_compute. reflexivity. Qed.

Theorem lower_aperture_wall_triangles_exact_us :
  firstn 8 (skipn 108 area2_no_cam_collision_triangles_us) =
    lower_aperture_wall_triangles.
Proof. vm_compute. reflexivity. Qed.

Theorem lower_aperture_wall_triangles_exact_jp :
  firstn 8 (skipn 108 area2_no_cam_collision_triangles_jp) =
    lower_aperture_wall_triangles.
Proof. vm_compute. reflexivity. Qed.

(* Global source ordinal = the sum of preceding declared group counts plus
   the ordinal inside the selected group.  This is source metadata, not an
   assertion about a live [Surface] pointer or [SurfaceRef]. *)
Definition lower_pole_platform_source_ordinals : list nat :=
  [746%nat; 753%nat].

Definition lower_ring_group_ordinals : list nat :=
  [15%nat; 16%nat; 17%nat; 18%nat;
   19%nat; 20%nat; 21%nat; 22%nat].

Definition lower_ring_source_ordinals : list nat :=
  [1414%nat; 1415%nat; 1416%nat; 1417%nat;
   1418%nat; 1419%nat; 1420%nat; 1421%nat].

Definition lower_aperture_wall_group_ordinals : list nat :=
  [108%nat; 109%nat; 110%nat; 111%nat;
   112%nat; 113%nat; 114%nat; 115%nat].

Definition lower_aperture_wall_source_ordinals : list nat :=
  [1534%nat; 1535%nat; 1536%nat; 1537%nat;
   1538%nat; 1539%nat; 1540%nat; 1541%nat].

Theorem lower_ring_global_ordinals_are_derived :
  lower_ring_source_ordinals =
    map (fun ordinal => (1399 + ordinal)%nat)
      lower_ring_group_ordinals.
Proof. reflexivity. Qed.

Theorem lower_aperture_wall_global_ordinals_are_derived :
  lower_aperture_wall_source_ordinals =
    map (fun ordinal => (1426 + ordinal)%nat)
      lower_aperture_wall_group_ordinals.
Proof. reflexivity. Qed.

Fixpoint collision_vertex_max_y
    (vertices : list (Z * Z * Z)) : Z :=
  match vertices with
  | [] => 0
  | vertex :: rest => Z.max (vertex_y vertex) (collision_vertex_max_y rest)
  end.

Theorem area2_static_mesh_max_y_exact_us :
  collision_vertex_max_y area2_collision_vertices_us = 6144.
Proof. vm_compute. reflexivity. Qed.

Theorem area2_static_mesh_max_y_exact_jp :
  collision_vertex_max_y area2_collision_vertices_jp = 6144.
Proof. vm_compute. reflexivity. Qed.

(** * Exact aperture geometry *)

Definition lower_aperture_west : Z := -101.
Definition lower_aperture_east : Z := 102.
Definition lower_aperture_south : Z := 1229.
Definition lower_aperture_north : Z := 1434.
Definition lower_ring_floor_y : Z := 3942.

Inductive LowerApertureSide :=
| LowerApertureWest
| LowerApertureEast
| LowerApertureSouth
| LowerApertureNorth.

Definition vertex_on_aperture_side
    (side : LowerApertureSide) (vertex : Z * Z * Z) : bool :=
  let '(x, _, z) := vertex in
  match side with
  | LowerApertureWest => Z.eqb x lower_aperture_west
  | LowerApertureEast => Z.eqb x lower_aperture_east
  | LowerApertureSouth => Z.eqb z lower_aperture_south
  | LowerApertureNorth => Z.eqb z lower_aperture_north
  end.

Definition triangle_on_aperture_side
    (vertices : list (Z * Z * Z))
    (side : LowerApertureSide) (triangle : Z * Z * Z) : bool :=
  let '(a, b, c) := triangle in
  match nth_error vertices (Z.to_nat a),
        nth_error vertices (Z.to_nat b),
        nth_error vertices (Z.to_nat c) with
  | Some va, Some vb, Some vc =>
      andb (vertex_on_aperture_side side va)
        (andb (vertex_on_aperture_side side vb)
          (vertex_on_aperture_side side vc))
  | _, _, _ => false
  end.

Fixpoint lower_map2 {A B C : Type}
    (function : A -> B -> C) (left : list A) (right : list B) : list C :=
  match left, right with
  | left_head :: left_tail, right_head :: right_tail =>
      function left_head right_head ::
        lower_map2 function left_tail right_tail
  | _, _ => []
  end.

Theorem lower_aperture_wall_side_certificate_us :
  lower_map2
    (triangle_on_aperture_side area2_collision_vertices_us)
    [LowerApertureNorth; LowerApertureEast;
     LowerApertureNorth; LowerApertureWest;
     LowerApertureWest; LowerApertureEast;
     LowerApertureSouth; LowerApertureSouth]
    lower_aperture_wall_triangles =
  repeat true 8.
Proof. vm_compute. reflexivity. Qed.

Theorem lower_aperture_wall_side_certificate_jp :
  lower_map2
    (triangle_on_aperture_side area2_collision_vertices_jp)
    [LowerApertureNorth; LowerApertureEast;
     LowerApertureNorth; LowerApertureWest;
     LowerApertureWest; LowerApertureEast;
     LowerApertureSouth; LowerApertureSouth]
    lower_aperture_wall_triangles =
  repeat true 8.
Proof. vm_compute. reflexivity. Qed.

Definition collision_vertex_at_y
    (vertices : list (Z * Z * Z)) (y : Z) (index : nat) : bool :=
  match nth_error vertices index with
  | Some (_, vertex_y, _) => Z.eqb vertex_y y
  | None => false
  end.

Theorem lower_aperture_wall_lower_vertices_y_exact_us :
  forallb (collision_vertex_at_y area2_collision_vertices_us 3712)
    [407%nat; 408%nat; 409%nat; 410%nat] = true.
Proof. vm_compute. reflexivity. Qed.

Theorem lower_aperture_wall_lower_vertices_y_exact_jp :
  forallb (collision_vertex_at_y area2_collision_vertices_jp 3712)
    [407%nat; 408%nat; 409%nat; 410%nat] = true.
Proof. vm_compute. reflexivity. Qed.

Definition lower_aperture_interior_Z (x z : Z) : Prop :=
  lower_aperture_west < x < lower_aperture_east /\
  lower_aperture_south < z < lower_aperture_north.

(* This is the horizontal footprint of the ring, not the central shaft. *)
Definition lower_ring_air_footprint_Z (x y z : Z) : Prop :=
  lower_ring_floor_y <= y /\
  -1535 <= x <= 1536 /\
  922 <= z <= 1536 /\
  (x <= lower_aperture_west \/
   lower_aperture_east <= x \/
   z <= lower_aperture_south \/
   lower_aperture_north <= z).

Theorem lower_aperture_interior_excludes_ring_air_footprint :
  forall x y z,
    lower_aperture_interior_Z x z ->
    ~ lower_ring_air_footprint_Z x y z.
Proof.
  intros x y z [Hx Hz] [_ [_ [_ Houtside]]].
  unfold lower_aperture_west, lower_aperture_east,
    lower_aperture_south, lower_aperture_north in *.
  destruct Houtside as [Hwest | [Heast | [Hsouth | Hnorth]]]; lia.
Qed.

Theorem lower_radius_82_is_strictly_inside_aperture :
  forall x z,
    Z.abs x <= 82 ->
    Z.abs (z - 1331) <= 82 ->
    lower_aperture_interior_Z x z.
Proof.
  intros x z Hx Hz.
  apply Z.abs_le in Hx.
  apply Z.abs_le in Hz.
  unfold lower_aperture_interior_Z, lower_aperture_west,
    lower_aperture_east, lower_aperture_south, lower_aperture_north.
  lia.
Qed.

(** * Four binary32 target-side air cells *)

Definition lower_area2_static_mesh_ceiling : float32 :=
  f32_bits 1170210816. (* 6144.0f *)

Definition lower_ring_west_air_cell : AxisAlignedOpenCell :=
  {| open_cell_min :=
       {| vec_x := f32_bits 3300909056;  (* -1535.0f *)
          vec_y := f32_bits 1165385728;  (* 3942.0f *)
          vec_z := f32_bits 1147568128 |}; (* 922.0f *)
     open_cell_max :=
       {| vec_x := f32_bits 3268018176;  (* -101.0f *)
          vec_y := lower_area2_static_mesh_ceiling;
          vec_z := f32_bits 1153433600 |} |}. (* 1536.0f *)

Definition lower_ring_east_air_cell : AxisAlignedOpenCell :=
  {| open_cell_min :=
       {| vec_x := f32_bits 1120665600;  (* 102.0f *)
          vec_y := f32_bits 1165385728;
          vec_z := f32_bits 1147568128 |};
     open_cell_max :=
       {| vec_x := f32_bits 1153433600;  (* 1536.0f *)
          vec_y := lower_area2_static_mesh_ceiling;
          vec_z := f32_bits 1153433600 |} |}.

Definition lower_ring_south_air_cell : AxisAlignedOpenCell :=
  {| open_cell_min :=
       {| vec_x := f32_bits 3268018176;
          vec_y := f32_bits 1165385728;
          vec_z := f32_bits 1147568128 |};
     open_cell_max :=
       {| vec_x := f32_bits 1120665600;
          vec_y := lower_area2_static_mesh_ceiling;
          vec_z := f32_bits 1150918656 |} |}. (* 1229.0f *)

Definition lower_ring_north_air_cell : AxisAlignedOpenCell :=
  {| open_cell_min :=
       {| vec_x := f32_bits 3268018176;
          vec_y := f32_bits 1165385728;
          vec_z := f32_bits 1152598016 |}; (* 1434.0f *)
     open_cell_max :=
       {| vec_x := f32_bits 1120665600;
          vec_y := lower_area2_static_mesh_ceiling;
          vec_z := f32_bits 1153433600 |} |}.

Definition lower_ring_target_air_cells : list AxisAlignedOpenCell :=
  [lower_ring_west_air_cell; lower_ring_east_air_cell;
   lower_ring_south_air_cell; lower_ring_north_air_cell].

Definition position_in_lower_ring_target_air (position : Vec3f) : bool :=
  existsb (position_in_open_cell position) lower_ring_target_air_cells.

Definition lower_pole_top_position : Vec3f :=
  {| vec_x := f32_zero;
     vec_y := f32_bits 1165705216;       (* 4020.0f *)
     vec_z := f32_bits 1151754240 |}.    (* 1331.0f *)

Theorem lower_pole_top_central_shaft_is_not_target_air :
  position_in_lower_ring_target_air lower_pole_top_position = false.
Proof. vm_compute. reflexivity. Qed.

Theorem lower_ring_four_inner_edges_are_target_air :
  position_in_lower_ring_target_air
    {| vec_x := f32_bits 3268018176;
       vec_y := f32_bits 1165705216;
       vec_z := f32_bits 1151754240 |} = true /\
  position_in_lower_ring_target_air
    {| vec_x := f32_bits 1120665600;
       vec_y := f32_bits 1165705216;
       vec_z := f32_bits 1151754240 |} = true /\
  position_in_lower_ring_target_air
    {| vec_x := f32_zero;
       vec_y := f32_bits 1165705216;
       vec_z := f32_bits 1150918656 |} = true /\
  position_in_lower_ring_target_air
    {| vec_x := f32_zero;
       vec_y := f32_bits 1165705216;
       vec_z := f32_bits 1152598016 |} = true.
Proof. vm_compute. repeat split; reflexivity. Qed.

Theorem lower_clean_entry_position_is_not_target_air :
  position_in_lower_ring_target_air lower_entry_position = false.
Proof. vm_compute. reflexivity. Qed.

(** * Static support identities and a separate moving-owner receipt *)

Definition Area2StaticSurfaceMap : Type := nat -> SurfaceRef.

(** A bare function is sufficient for the elementary cut adapter, but the
    route-facing projection must also prevent two initializer ordinals from
    being silently assigned the same ghost surface name. *)
Record LowerArea2StaticSurfaceProjection := {
  lower_area2_surface_ref : Area2StaticSurfaceMap;
  lower_area2_surface_ref_injective :
    forall left right,
      lower_area2_surface_ref left = lower_area2_surface_ref right ->
      left = right;
  lower_area2_surface_ref_in_area2 :
    forall ordinal,
      surface_area (lower_area2_surface_ref ordinal) = pyramid_area_id
}.

Inductive LowerTargetDynamicSupportKey :=
| LowerUpperHorizontalGrindel.

Definition LowerTargetDynamicSupportMap : Type :=
  LowerTargetDynamicSupportKey -> ObjectRef.

Definition lower_ring_static_supports
    (static_surface : Area2StaticSurfaceMap) : list SurfaceRef :=
  map static_surface lower_ring_source_ordinals.

(* Generated level-script receipt for the object at (-870,3840,105), yaw
   180, behavior bhvHorizontalGrindel.  The packed command is retained in its
   generated representation rather than decoded by an unproved model. *)
Definition lower_upper_grindel_spawn_record_us : list init_data :=
  firstn 6 (skipn 18
    (gvar_init us_ssl_script.v_script_func_local_4)).

Definition lower_upper_grindel_spawn_record_jp : list init_data :=
  firstn 6 (skipn 18
    (gvar_init jp_ssl_script.v_script_func_local_4)).

Definition lower_upper_grindel_spawn_record_expected : list init_data :=
  [Init_int32 (Int.repr 605560630);
   Init_int32 (Int.repr (-57012480));
   Init_int32 (Int.repr 6881280);
   Init_int32 (Int.repr 11796480);
   Init_int32 Int.zero;
   Init_addrof us_ssl_script._bhvHorizontalGrindel Ptrofs.zero].

Theorem lower_upper_grindel_spawn_record_exact_us :
  lower_upper_grindel_spawn_record_us =
    lower_upper_grindel_spawn_record_expected.
Proof. vm_compute. reflexivity. Qed.

Theorem lower_upper_grindel_spawn_record_exact_jp :
  lower_upper_grindel_spawn_record_jp =
  [Init_int32 (Int.repr 605560630);
   Init_int32 (Int.repr (-57012480));
   Init_int32 (Int.repr 6881280);
   Init_int32 (Int.repr 11796480);
   Init_int32 Int.zero;
   Init_addrof jp_ssl_script._bhvHorizontalGrindel Ptrofs.zero].
Proof. vm_compute. reflexivity. Qed.

Definition lower_grindel_vertices_us : list (Z * Z * Z) :=
  collision_vertices_from_words 8
    (init_int16_values
      (gvar_init us_ssl_collision.v_ssl_seg7_collision_grindel)).

Definition lower_grindel_vertices_jp : list (Z * Z * Z) :=
  collision_vertices_from_words 8
    (init_int16_values
      (gvar_init jp_ssl_collision.v_ssl_seg7_collision_grindel)).

Definition lower_grindel_vertices : list (Z * Z * Z) :=
  [(224, 450, -224); (224, 3, -224); (-224, 3, -224);
   (-224, 450, -224); (-224, 3, 224); (224, 3, 224);
   (224, 450, 224); (-224, 450, 224)].

Theorem lower_grindel_vertices_exact_us :
  lower_grindel_vertices_us = lower_grindel_vertices.
Proof. vm_compute. reflexivity. Qed.

Theorem lower_grindel_vertices_exact_jp :
  lower_grindel_vertices_jp = lower_grindel_vertices.
Proof. vm_compute. reflexivity. Qed.

Theorem lower_upper_grindel_home_top_y : 3840 + 450 = 4290.
Proof. reflexivity. Qed.

(** * Target-side predicate and [CollisionSupportCut] adapter

    The horizontal Grindel is deliberately absent here.  Its home position is
    downstream of the pole aperture, and treating it as immediate cut
    membership would make the separator much broader than the checked ring.
    A moving-owner path that reaches the downstream component without first
    touching the ring support/air cells belongs to moving-geometry bypass
    coverage. *)

Definition LowerRingAirState (state : GameState) : Prop :=
  exists cell,
    In cell lower_ring_target_air_cells /\
    position_in_open_cell
      (mario_position (state_mario_kinematics state)) cell = true.

Definition LowerTargetSide
    (static_surface : Area2StaticSurfaceMap)
    (state : GameState) : Prop :=
  In (mario_floor (state_mario_kinematics state))
    (lower_ring_static_supports static_surface) \/
  LowerRingAirState state.

Definition lower_target_collision_cut
    (static_surface : Area2StaticSurfaceMap)
    (source_static : list SurfaceRef)
    (source_dynamic : list ObjectRef)
    (source_cells : list AxisAlignedOpenCell) : CollisionSupportCut :=
  {| cut_entrance := LowerEntrance;
     cut_source_static_supports := source_static;
     cut_target_static_supports :=
       lower_ring_static_supports static_surface;
     cut_source_dynamic_supports := source_dynamic;
     cut_target_dynamic_supports := [];
     cut_source_open_cells := source_cells;
     cut_target_open_cells := lower_ring_target_air_cells |}.

Theorem lower_target_collision_cut_target_side_is_exact :
  forall static_surface source_static source_dynamic source_cells state,
    StateOnCutTargetSide
      (lower_target_collision_cut static_surface
        source_static source_dynamic source_cells) state <->
    LowerTargetSide static_surface state.
Proof.
  intros static_surface source_static source_dynamic source_cells state.
  split.
  - intros Hside. inversion Hside; subst.
    + left. assumption.
    + contradiction.
    + right. eexists. split; eassumption.
  - intros [Hstatic | Hair].
    + constructor 1. exact Hstatic.
    + destruct Hair as [cell [Hin Hcell]].
      econstructor 3; eauto.
Qed.

Lemma clean_lower_entry_position_exact :
  forall initial,
    CleanPyramidEntry initial ->
    state_entrance initial = LowerEntrance ->
    mario_position (state_mario_kinematics initial) = lower_entry_position.
Proof.
  intros initial Hclean Hlower.
  rewrite (clean_current_kinematics initial Hclean).
  pose proof (clean_entry_snapshot initial Hclean) as Hsnapshot.
  unfold entry_snapshot_for in Hsnapshot.
  rewrite Hlower in Hsnapshot.
  destruct Hsnapshot as (_ & _ & _ & _ & _ & _ & Hposition).
  exact Hposition.
Qed.

Theorem clean_lower_entry_excludes_target_air :
  forall initial,
    CleanPyramidEntry initial ->
    state_entrance initial = LowerEntrance ->
    ~ LowerRingAirState initial.
Proof.
  intros initial Hclean Hlower [cell [Hin Hcell]].
  pose proof (clean_lower_entry_position_exact initial Hclean Hlower)
    as Hposition.
  assert (Hexists :
    position_in_lower_ring_target_air
      (mario_position (state_mario_kinematics initial)) = true).
  {
    unfold position_in_lower_ring_target_air.
    apply existsb_exists.
    exists cell. split; assumption.
  }
  rewrite Hposition, lower_clean_entry_position_is_not_target_air in Hexists.
  discriminate.
Qed.

(* [CleanPyramidEntry] deliberately does not assign a concrete live surface
   pointer or allocation epoch.  These two exclusions must come from the
   ordinary entry's linked memory, rather than from the abstract record. *)
Definition LowerCleanEntrySupportProjectionAt
    (static_surface : Area2StaticSurfaceMap)
    (initial : GameState) : Prop :=
  ~ In (mario_floor (state_mario_kinematics initial))
      (lower_ring_static_supports static_surface).

Theorem clean_lower_entry_is_not_on_target_side :
  forall static_surface initial,
    LowerCleanEntrySupportProjectionAt static_surface initial ->
    CleanPyramidEntry initial ->
    state_entrance initial = LowerEntrance ->
    ~ LowerTargetSide static_surface initial.
Proof.
  intros static_surface initial Hprojection Hclean Hlower.
  intros [Hring | Hair].
  - exact (Hprojection Hring).
  - exact (clean_lower_entry_excludes_target_air initial Hclean Hlower Hair).
Qed.

(** * Strongest closed no-A ordinary-pole subcase *)

Definition LegacyNormalizedLowerSoftBonkSample
    (frames x y z : Z) : Prop :=
  0 <= frames /\
  y <= legacy_soft_height_upper frames /\
  Z.abs x <= legacy_soft_radius_upper frames /\
  Z.abs (z - 1331) <= legacy_soft_radius_upper frames.

Theorem normalized_no_a_soft_bonk_cannot_enter_lower_target_air_footprint :
  forall frames x y z,
    LegacyNormalizedLowerSoftBonkSample frames x y z ->
    ~ lower_ring_air_footprint_Z x y z.
Proof.
  intros frames x y z
    [Hframes [Hy [Hx Hz]]] Htarget.
  destruct Htarget as [Htarget_y [Houter_x [Houter_z Houtside]]].
  assert (Hheight :
    legacy_sixth_floor_y <= legacy_soft_height_upper frames).
  {
    unfold legacy_sixth_floor_y, lower_ring_floor_y in *.
    lia.
  }
  pose proof
    (legacy_soft_max_radius_before_floor frames Hframes Hheight)
    as Hradius.
  assert (Hx82 : Z.abs x <= 82) by lia.
  assert (Hz82 : Z.abs (z - 1331) <= 82) by lia.
  pose proof (lower_radius_82_is_strictly_inside_aperture x z Hx82 Hz82)
    as Hinterior.
  eapply (lower_aperture_interior_excludes_ring_air_footprint x y z).
  - exact Hinterior.
  - unfold lower_ring_air_footprint_Z, lower_ring_floor_y.
    split; [exact Htarget_y |].
    split; [exact Houter_x |].
    split; assumption.
Qed.

(** * Retail closure and downstream obligations *)

(* This is the desired linked-run gate closure, stated against the conservative
   ring-support/closed-cell target side above.  It is not proved by the
   normalized soft-bonk theorem:
   all other ordinary actions, platform/object displacement, clips, nonlocal
   endpoints, lifecycle writes and same-position support changes remain. *)
Definition LowerNoAGateClosureObligation
    (projection : ClightObservationProjection)
    (static_surface : Area2StaticSurfaceMap) : Prop :=
  forall run initial
      (certificate : ClightFrameRefinementCertificate projection run initial)
      index event before after,
    CleanPyramidEntry initial ->
    state_entrance initial = LowerEntrance ->
    fewer_than_one_a_press (project_inputs projection run) ->
    ClightFrameEvidence projection run initial certificate
      index event before after ->
    ~ LowerTargetSide static_surface after.

(* Downstream Act-3 and all-five-trigger certificates are intentionally
   defined in [Area2DownstreamContinuations].  A universal continuation from
   every inhabitant of [LowerTargetSide] would quantify over dead, corrupted,
   or otherwise non-reachable boundary records and would be false or much
   stronger than the route claim. *)

Definition lower_relevant_surface_ordinals : list nat :=
  lower_pole_platform_source_ordinals ++
  lower_ring_source_ordinals ++
  lower_aperture_wall_source_ordinals.

(* Exact remaining retail bridges.  None is an axiom or theorem premise in a
   claimed unconditional result. *)
Definition LowerStaticSurfaceProjectionObligation
    (static_projection : LowerArea2StaticSurfaceProjection)
    (clight_state_is_relevant : Clight.state -> Prop)
    (live_surface_decodes_ordinal :
      Clight.state -> nat -> SurfaceRef -> Prop)
    (live_surface_is_inserted :
      Clight.state -> nat -> SurfaceRef -> Prop) : Prop :=
  forall clight_state ordinal,
    clight_state_is_relevant clight_state ->
    In ordinal lower_relevant_surface_ordinals ->
    live_surface_decodes_ordinal clight_state ordinal
      (lower_area2_surface_ref static_projection ordinal) /\
    live_surface_is_inserted clight_state ordinal
      (lower_area2_surface_ref static_projection ordinal).

Definition LowerDynamicSupportLifecycleObligation
    (dynamic_support : LowerTargetDynamicSupportMap) : Prop :=
  forall state platform,
    state_mario_platform state = Some platform ->
    object_ref_equal (captured_platform_ref platform)
      (dynamic_support LowerUpperHorizontalGrindel) ->
    raw_platform_slot_well_formed (state_object_pool state) platform.

Definition LowerCutRetailResiduals
    (projection : ClightObservationProjection)
    (static_projection : LowerArea2StaticSurfaceProjection)
    (clight_state_is_relevant : Clight.state -> Prop)
    (live_surface_decodes_ordinal :
      Clight.state -> nat -> SurfaceRef -> Prop)
    (live_surface_is_inserted :
      Clight.state -> nat -> SurfaceRef -> Prop) : Prop :=
  LowerStaticSurfaceProjectionObligation static_projection
    clight_state_is_relevant live_surface_decodes_ordinal
    live_surface_is_inserted /\
  LowerNoAGateClosureObligation projection
    (lower_area2_surface_ref static_projection).

(** * Conditional conservative first-crossing closure

    This is the lower analogue of the elevator closure interface.  The
    target side is fixed by the checked ring supports and four binary32 closed
    cells.  The cells are a conservative MarioState-position approximation,
    not an exact collision-phase/hitbox component.  The
    The source component still has to be supplied and validated by
    the linked collision-graph proof. *)

Record LowerTargetCutProjection := {
  lower_cut_static_surface_projection : LowerArea2StaticSurfaceProjection;
  lower_cut_source_static_supports : list SurfaceRef;
  lower_cut_source_dynamic_supports : list ObjectRef;
  lower_cut_source_open_cells : list AxisAlignedOpenCell
}.

Definition selected_lower_target_cut
    (projection : LowerTargetCutProjection) : CollisionSupportCut :=
  lower_target_collision_cut
    (lower_area2_surface_ref
      (lower_cut_static_surface_projection projection))
    (lower_cut_source_static_supports projection)
    (lower_cut_source_dynamic_supports projection)
    (lower_cut_source_open_cells projection).

Definition LowerTargetCrossingContext
    (cut_projection : LowerTargetCutProjection)
    {clight_projection run initial certificate region target_frame}
    (crossing :
      FirstValidatedCutCrossingAt
        clight_projection run initial certificate region target_frame) : Prop :=
  CleanPyramidEntry initial /\
  state_entrance initial = LowerEntrance /\
  first_crossing_cut _ _ _ _ _ _ crossing =
    selected_lower_target_cut cut_projection /\
  fewer_than_one_a_press (project_inputs clight_projection run).

(* These are the seven exhaustive outcomes of
   [validated_pre_target_first_crossing_writer_coverage] after ordinary
   physics is split by the complete Float32 cast-domain predicate.  They are
   semantic exclusions to prove, not constructors inhabited by this module. *)
Definition LowerTargetNoAWriterExclusions
    (cut_projection : LowerTargetCutProjection)
    (clight_projection : ClightObservationProjection) : Prop :=
  forall run initial certificate region target_frame
      (crossing :
        FirstValidatedCutCrossingAt
          clight_projection run initial certificate region target_frame),
    LowerTargetCrossingContext cut_projection crossing ->
    ~ CrossingUsesLocalOrdinaryPhysics crossing /\
    ~ CrossingUsesPositionWriter crossing FirstWriterPlatformDisplacement /\
    ~ CrossingUsesPositionWriter crossing FirstWriterObjectImpulse /\
    ~ CrossingUsesPositionWriter crossing FirstWriterCollisionClip /\
    ~ CrossingUsesCoordinateAliasOrOutOfBounds crossing /\
    ~ CrossingUsesPositionWriter crossing FirstWriterLifecycleEntry /\
    ~ CrossingUsesSupportSelection crossing.

Theorem lower_target_no_a_first_crossing_is_closed :
  forall cut_projection clight_projection,
    LowerTargetNoAWriterExclusions cut_projection clight_projection ->
    forall run initial certificate region target_frame
        (crossing :
          FirstValidatedCutCrossingAt
            clight_projection run initial certificate region target_frame),
      LowerTargetCrossingContext cut_projection crossing ->
      False.
Proof.
  intros cut_projection clight_projection Hexclusions
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

Definition LowerTargetAdapterCutConstructionObligation
    (cut_projection : LowerTargetCutProjection)
    (clight_projection : ClightObservationProjection) : Prop :=
  forall run initial
      (certificate :
        ClightFrameRefinementCertificate clight_projection run initial)
      trace region target_frame target_observation,
    CleanPyramidEntry initial ->
    state_entrance initial = LowerEntrance ->
    ClightRouteTraceProjection
      clight_projection run initial certificate trace ->
    first_target_observation_at
      trace region target_frame target_observation ->
    exists crossing :
      FirstValidatedCutCrossingAt
        clight_projection run initial certificate region target_frame,
      first_crossing_cut _ _ _ _ _ _ crossing =
        selected_lower_target_cut cut_projection.

Theorem lower_target_no_a_target_access_is_closed_under_adapter_obligations :
  forall cut_projection clight_projection,
    LowerTargetAdapterCutConstructionObligation
      cut_projection clight_projection ->
    LowerTargetNoAWriterExclusions cut_projection clight_projection ->
    forall run initial certificate trace,
      CleanPyramidEntry initial ->
      state_entrance initial = LowerEntrance ->
      ClightRouteTraceProjection
        clight_projection run initial certificate trace ->
      fewer_than_one_a_press (project_inputs clight_projection run) ->
      reaches_any_target_region trace ->
      False.
Proof.
  intros cut_projection clight_projection Hconstruction Hexclusions
    run initial certificate trace Hclean Hlower Htrace Hno_a Htarget.
  destruct (reaches_any_target_has_first_exact_occurrence trace Htarget)
    as [region [target_frame [target_observation Hfirst]]].
  destruct
    (Hconstruction run initial certificate trace region target_frame
      target_observation Hclean Hlower Htrace Hfirst)
    as [crossing Hcut].
  eapply (lower_target_no_a_first_crossing_is_closed
    cut_projection clight_projection Hexclusions
    run initial certificate region target_frame crossing).
  split; [exact Hclean |].
  split; [exact Hlower |].
  split; assumption.
Qed.

(* The last theorem is a sound frame-end reduction, not the retail gate proof.
   Its two hypotheses are the still-open construction of this conservative
   selected cut from the linked run and the seven cause-specific no-A
   exclusions.  The named timing obligation below requires every actual
   projected target-event frame to have a strictly earlier validated crossing.
   A real same-frame or earlier transient crossing refutes it and requires a
   richer program-point interface. *)

Definition LowerSameFrameCollisionPhaseCutRefinementObligation
    (cut_projection : LowerTargetCutProjection)
    (clight_projection : ClightObservationProjection) : Prop :=
  forall run initial certificate,
    CleanPyramidEntry initial ->
    state_entrance initial = LowerEntrance ->
    fewer_than_one_a_press (project_inputs clight_projection run) ->
    NoSameFrameOrTransientCutEscape
      clight_projection run initial certificate
      (selected_lower_target_cut cut_projection).

Theorem area2_lower_target_cut_checked_boundary :
  selected_area2_vertex_receipts area2_collision_vertices_us /\
  selected_area2_vertex_receipts area2_collision_vertices_jp /\
  lower_map2
    (triangle_on_aperture_side area2_collision_vertices_us)
    [LowerApertureNorth; LowerApertureEast;
     LowerApertureNorth; LowerApertureWest;
     LowerApertureWest; LowerApertureEast;
     LowerApertureSouth; LowerApertureSouth]
    lower_aperture_wall_triangles = repeat true 8 /\
  lower_map2
    (triangle_on_aperture_side area2_collision_vertices_jp)
    [LowerApertureNorth; LowerApertureEast;
     LowerApertureNorth; LowerApertureWest;
     LowerApertureWest; LowerApertureEast;
     LowerApertureSouth; LowerApertureSouth]
    lower_aperture_wall_triangles = repeat true 8 /\
  forallb (collision_vertex_at_y area2_collision_vertices_us 3712)
      [407%nat; 408%nat; 409%nat; 410%nat] = true /\
  forallb (collision_vertex_at_y area2_collision_vertices_jp 3712)
      [407%nat; 408%nat; 409%nat; 410%nat] = true /\
  collision_vertex_max_y area2_collision_vertices_us = 6144 /\
  collision_vertex_max_y area2_collision_vertices_jp = 6144 /\
  firstn 8 (skipn 15 area2_camera_free_roam_triangles_us) =
      lower_ring_triangles /\
  firstn 8 (skipn 15 area2_camera_free_roam_triangles_jp) =
      lower_ring_triangles /\
  firstn 8 (skipn 108 area2_no_cam_collision_triangles_us) =
      lower_aperture_wall_triangles /\
  firstn 8 (skipn 108 area2_no_cam_collision_triangles_jp) =
      lower_aperture_wall_triangles /\
  position_in_lower_ring_target_air lower_pole_top_position = false /\
  (forall frames x y z,
    LegacyNormalizedLowerSoftBonkSample frames x y z ->
    ~ lower_ring_air_footprint_Z x y z).
Proof.
  split; [exact selected_area2_vertex_receipts_exact_us |].
  split; [exact selected_area2_vertex_receipts_exact_jp |].
  split; [exact lower_aperture_wall_side_certificate_us |].
  split; [exact lower_aperture_wall_side_certificate_jp |].
  split; [exact lower_aperture_wall_lower_vertices_y_exact_us |].
  split; [exact lower_aperture_wall_lower_vertices_y_exact_jp |].
  split; [exact area2_static_mesh_max_y_exact_us |].
  split; [exact area2_static_mesh_max_y_exact_jp |].
  split; [exact lower_ring_triangles_exact_us |].
  split; [exact lower_ring_triangles_exact_jp |].
  split; [exact lower_aperture_wall_triangles_exact_us |].
  split; [exact lower_aperture_wall_triangles_exact_jp |].
  split; [exact lower_pole_top_central_shaft_is_not_target_air |].
  exact normalized_no_a_soft_bonk_cannot_enter_lower_target_air_footprint.
Qed.
