(** Finite certificate for the audited Area-1 upper-warp floor queries.

    This file computes the exact static wall and floor candidate inventories
    from the generated US/JP Area-1 collision initializers.  A pure parser
    reads all 574 vertices and 962 triangle records, and a source-shaped
    partition mirror reconstructs the source-shaped cell insertion order.  It
    classifies the two diagnostics used by the Ink fallback investigation:

      - for [(-2200,768,-1024)], every listed static wall and floor candidate
        is rejected, after which the pure evaluator constructs zero-push and
        [Area1FloorNull] / [-11000.0f] records; and
      - a separate literal diagnostic records the expected upper-warp-centre
        face [(498,500,501)] at height [768.0f].

    The generated-initializer computation, finite lists, and integer-valued
    boundary arithmetic below are checked by the Rocq kernel.  They are
    deliberately separated from the two pending obligations at the end of
    the file.  Neither diagnostic is yet a live [find_floor] traversal.  In
    particular, no theorem here says that [read_surface_data] built these
    exact lists in live Clight memory or that a clean retail execution can
    reach the candidate NULL sample. *)

From Coq Require Import Bool Lia List ZArith.
From compcert Require Import Clight Floats Integers.
From LessThanOneAPress.Proofs Require Import
  CollisionMeshFacts GameTypes.

Import ListNotations.
Local Open Scope Z_scope.

Definition Area1TriangleIndex : Type := (Z * Z * Z)%type.

(** * Generated-initializer parser and static-partition mirror

    The collision stream begins with [COL_INIT], the vertex count, and the
    packed vertex triples.  Surface groups then contain a type, count, and
    either three or four words per triangle; the fourth word is the force
    parameter for the seven types recognized by [surface_has_force].

    This parser intentionally stops at the first non-surface command.  In the
    pinned Area-1 stream that command is [COL_TRI_STOP] (65), after all static
    triangles and before special objects and water boxes. *)

Definition area1_source_surface_has_force (surface_type : Z) : bool :=
  existsb (Z.eqb surface_type) [4; 14; 36; 37; 39; 44; 45].

Definition area1_source_is_surface_type (command : Z) : bool :=
  Z.ltb command 64 || Z.leb 101 command.

Fixpoint area1_parse_triangle_records
    (count stride : nat) (words : list Z)
    : list Area1TriangleIndex * list Z :=
  match count with
  | O => ([], words)
  | S count' =>
      match words with
      | first :: second :: third :: rest =>
          let remaining :=
            match stride with
            | S (S (S (S _))) => tl rest
            | _ => rest
            end in
          let '(triangles, suffix) :=
            area1_parse_triangle_records count' stride remaining in
          ((first, second, third) :: triangles, suffix)
      | _ => ([], [])
      end
  end.

Fixpoint area1_parse_surface_groups
    (fuel : nat) (words : list Z) : list Area1TriangleIndex :=
  match fuel with
  | O => []
  | S fuel' =>
      match words with
      | surface_type :: count :: rest =>
          if area1_source_is_surface_type surface_type then
            let stride :=
              if area1_source_surface_has_force surface_type
              then 4%nat
              else 3%nat in
            let '(triangles, suffix) :=
              area1_parse_triangle_records
                (Z.to_nat count) stride rest in
            triangles ++ area1_parse_surface_groups fuel' suffix
          else []
      | _ => []
      end
  end.

Definition area1_source_triangle_stream (words : list Z)
    : list Area1TriangleIndex :=
  area1_parse_surface_groups 32
    (skipn (2 + 3 * area1_collision_vertex_count) words).

Definition area1_source_triangle_stream_us : list Area1TriangleIndex :=
  area1_source_triangle_stream area1_collision_words_us.

Definition area1_source_triangle_stream_jp : list Area1TriangleIndex :=
  area1_source_triangle_stream area1_collision_words_jp.

Definition Area1SourceVertex : Type := (Z * Z * Z)%type.

Definition area1_source_triangle_vertices
    (vertices : list Area1SourceVertex) (triangle : Area1TriangleIndex)
    : option (Area1SourceVertex * Area1SourceVertex * Area1SourceVertex) :=
  let '(first, second, third) := triangle in
  match nth_error vertices (Z.to_nat first),
        nth_error vertices (Z.to_nat second),
        nth_error vertices (Z.to_nat third) with
  | Some first_vertex, Some second_vertex, Some third_vertex =>
      Some (first_vertex, second_vertex, third_vertex)
  | _, _, _ => None
  end.

Definition area1_source_normal_components
    (vertices : Area1SourceVertex * Area1SourceVertex * Area1SourceVertex)
    : Z * Z * Z :=
  let '(first_vertex, second_vertex, third_vertex) := vertices in
  let '(x1, y1, z1) := first_vertex in
  let '(x2, y2, z2) := second_vertex in
  let '(x3, y3, z3) := third_vertex in
  ((y2 - y1) * (z3 - z2) - (z2 - z1) * (y3 - y2),
   (z2 - z1) * (x3 - x2) - (x2 - x1) * (z3 - z2),
   (x2 - x1) * (y3 - y2) - (y2 - y1) * (x3 - x2)).

Inductive Area1SourceSurfaceKind : Type :=
| Area1SourceFloor
| Area1SourceCeiling
| Area1SourceWall
| Area1SourceDegenerate.

(** [add_surface_to_cell] compares the normalized Y component against
    [+/- 0.01].  Squaring gives the exact rational test

      [10000 * ny^2 > nx^2 + ny^2 + nz^2].

    The parser uses that test over the same signed integer cross products.
    Connecting it to every binary32 operation in live [read_surface_data] is
    deliberately still part of [Area1LiveCollisionListExecutionObligation].
    The computed inventories below therefore establish a source-data
    certificate, not that live Clight memory has already been constructed. *)
Definition area1_source_surface_kind
    (vertices : Area1SourceVertex * Area1SourceVertex * Area1SourceVertex)
    : Area1SourceSurfaceKind :=
  let '(normal_x, normal_y, normal_z) :=
    area1_source_normal_components vertices in
  let magnitude_squared :=
    normal_x * normal_x +
    normal_y * normal_y +
    normal_z * normal_z in
  if Z.eqb magnitude_squared 0 then Area1SourceDegenerate
  else if Z.ltb magnitude_squared (10000 * normal_y * normal_y)
       then if Z.ltb 0 normal_y
            then Area1SourceFloor
            else Area1SourceCeiling
       else Area1SourceWall.

Definition area1_source_shifted_coordinate (coordinate : Z) : Z :=
  Z.max 0 (coordinate + 8192).

Definition area1_source_lower_cell_index (coordinate : Z) : Z :=
  let shifted := area1_source_shifted_coordinate coordinate in
  let base := shifted / 1024 in
  Z.max 0
    (if Z.ltb (shifted mod 1024) 50 then base - 1 else base).

Definition area1_source_upper_cell_index (coordinate : Z) : Z :=
  let shifted := area1_source_shifted_coordinate coordinate in
  let base := shifted / 1024 in
  Z.min 15
    (if Z.ltb 974 (shifted mod 1024) then base + 1 else base).

Definition area1_source_cell_contains_triangle
    (cell_x cell_z : Z)
    (vertices : Area1SourceVertex * Area1SourceVertex * Area1SourceVertex)
    : bool :=
  let '(first_vertex, second_vertex, third_vertex) := vertices in
  let '(x1, _, z1) := first_vertex in
  let '(x2, _, z2) := second_vertex in
  let '(x3, _, z3) := third_vertex in
  let minimum_x := Z.min x1 (Z.min x2 x3) in
  let maximum_x := Z.max x1 (Z.max x2 x3) in
  let minimum_z := Z.min z1 (Z.min z2 z3) in
  let maximum_z := Z.max z1 (Z.max z2 z3) in
  Z.leb (area1_source_lower_cell_index minimum_x) cell_x &&
  Z.leb cell_x (area1_source_upper_cell_index maximum_x) &&
  Z.leb (area1_source_lower_cell_index minimum_z) cell_z &&
  Z.leb cell_z (area1_source_upper_cell_index maximum_z).

Definition area1_source_triangle_is_kind_in_cell
    (vertices : list Area1SourceVertex)
    (kind : Area1SourceSurfaceKind)
    (cell_x cell_z : Z)
    (triangle : Area1TriangleIndex) : bool :=
  match area1_source_triangle_vertices vertices triangle with
  | Some triangle_vertices =>
      area1_source_cell_contains_triangle cell_x cell_z triangle_vertices &&
      match area1_source_surface_kind triangle_vertices, kind with
      | Area1SourceFloor, Area1SourceFloor
      | Area1SourceCeiling, Area1SourceCeiling
      | Area1SourceWall, Area1SourceWall => true
      | _, _ => false
      end
  | None => false
  end.

Definition area1_source_first_vertex_y
    (vertices : list Area1SourceVertex) (triangle : Area1TriangleIndex) : Z :=
  let '(first, _, _) := triangle in
  match nth_error vertices (Z.to_nat first) with
  | Some (_, y, _) => y
  | None => 0
  end.

(** Floors are sorted highest-first by their first vertex.  Strict
    insertion preserves source order when the priorities are equal, exactly
    as the linked-list loop does.  Walls remain in source insertion order. *)
Fixpoint area1_source_insert_floor
    (vertices : list Area1SourceVertex)
    (triangle : Area1TriangleIndex)
    (sorted : list Area1TriangleIndex) : list Area1TriangleIndex :=
  match sorted with
  | [] => [triangle]
  | current :: rest =>
      if Z.ltb
           (area1_source_first_vertex_y vertices current)
           (area1_source_first_vertex_y vertices triangle)
      then triangle :: sorted
      else current :: area1_source_insert_floor vertices triangle rest
  end.

Definition area1_source_sort_floors
    (vertices : list Area1SourceVertex)
    (triangles : list Area1TriangleIndex) : list Area1TriangleIndex :=
  fold_left
    (fun sorted triangle =>
      area1_source_insert_floor vertices triangle sorted)
    triangles [].

Definition area1_source_wall_inventory
    (vertices : list Area1SourceVertex)
    (triangles : list Area1TriangleIndex)
    (cell_x cell_z : Z) : list Area1TriangleIndex :=
  filter
    (area1_source_triangle_is_kind_in_cell
      vertices Area1SourceWall cell_x cell_z)
    triangles.

Definition area1_source_floor_inventory
    (vertices : list Area1SourceVertex)
    (triangles : list Area1TriangleIndex)
    (cell_x cell_z : Z) : list Area1TriangleIndex :=
  area1_source_sort_floors vertices
    (filter
      (area1_source_triangle_is_kind_in_cell
        vertices Area1SourceFloor cell_x cell_z)
      triangles).

(** Static wall traversal order in partition cell x=5, z=7. *)
Definition area1_q_static_wall_candidates :
    list Area1TriangleIndex :=
  [(263, 498, 502);
   (266, 502, 501);
   (266, 501, 372);
   (263, 502, 266);
   (238, 239, 240);
   (243, 242, 244);
   (243, 244, 359);
   (251, 364, 250);
   (250, 252, 365);
   (250, 365, 366);
   (251, 250, 366);
   (251, 366, 253);
   (254, 255, 369);
   (254, 369, 370);
   (258, 254, 370);
   (259, 238, 240);
   (258, 370, 373)].

(** Static floor traversal order in the same partition cell. *)
Definition area1_q_static_floor_candidates :
    list Area1TriangleIndex :=
  [(263, 266, 370);
   (263, 370, 369);
   (265, 372, 262);
   (265, 266, 372);
   (266, 265, 373);
   (373, 265, 260);
   (373, 260, 258);
   (255, 254, 258);
   (255, 258, 256);
   (260, 259, 256);
   (260, 238, 259);
   (239, 241, 242);
   (239, 242, 243);
   (239, 238, 260);
   (239, 262, 241);
   (239, 265, 262);
   (359, 239, 243);
   (498, 500, 501);
   (498, 501, 502);
   (253, 485, 239);
   (253, 367, 485);
   (361, 253, 239);
   (249, 252, 250);
   (249, 250, 364);
   (202, 359, 244);
   (202, 200, 359)].

Definition area1_q_static_wall_candidates_computed_us :
    list Area1TriangleIndex :=
  area1_source_wall_inventory
    area1_collision_vertices_us area1_source_triangle_stream_us 5 7.

Definition area1_q_static_floor_candidates_computed_us :
    list Area1TriangleIndex :=
  area1_source_floor_inventory
    area1_collision_vertices_us area1_source_triangle_stream_us 5 7.

Definition area1_q_static_wall_candidates_computed_jp :
    list Area1TriangleIndex :=
  area1_source_wall_inventory
    area1_collision_vertices_jp area1_source_triangle_stream_jp 5 7.

Definition area1_q_static_floor_candidates_computed_jp :
    list Area1TriangleIndex :=
  area1_source_floor_inventory
    area1_collision_vertices_jp area1_source_triangle_stream_jp 5 7.

(** These equalities are the generated-initializer connection for the two
    previously recorded inventories.  The kernel reduces the [gvar_init]
    arrays, parser, vertex lookups, source-shaped classification, cell bounds,
    and stable floor insertion sort. *)
Theorem area1_generated_initializer_inventory_certificate :
  length area1_source_triangle_stream_us = 962%nat /\
  length area1_source_triangle_stream_jp = 962%nat /\
  area1_q_static_wall_candidates_computed_us =
    area1_q_static_wall_candidates /\
  area1_q_static_floor_candidates_computed_us =
    area1_q_static_floor_candidates /\
  area1_q_static_wall_candidates_computed_jp =
    area1_q_static_wall_candidates /\
  area1_q_static_floor_candidates_computed_jp =
    area1_q_static_floor_candidates.
Proof.
  vm_compute.
  repeat split; reflexivity.
Qed.

Theorem area1_q_static_candidate_inventory_sizes :
  length area1_q_static_wall_candidates = 17%nat /\
  length area1_q_static_floor_candidates = 26%nat.
Proof. vm_compute. auto. Qed.

Theorem area1_q_static_candidate_inventories_have_no_duplicates :
  NoDup area1_q_static_wall_candidates /\
  NoDup area1_q_static_floor_candidates.
Proof.
  vm_compute.
  split;
    repeat constructor;
    simpl;
    intuition congruence.
Qed.

(** The selected upper-warp-centre face occurs exactly once in the audited
    floor inventory. *)
Definition area1_upper_warp_floor_face : Area1TriangleIndex :=
  (498, 500, 501).

Definition area1_triangle_index_eq_dec :
    forall left right : Area1TriangleIndex,
      {left = right} + {left <> right}.
Proof.
  intros [[left_x left_y] left_z] [[right_x right_y] right_z].
  destruct (Z.eq_dec left_x right_x) as [-> | Hx].
  2: { right. congruence. }
  destruct (Z.eq_dec left_y right_y) as [-> | Hy].
  2: { right. congruence. }
  destruct (Z.eq_dec left_z right_z) as [-> | Hz].
  2: { right. congruence. }
  left. reflexivity.
Defined.

Theorem area1_upper_warp_floor_face_inventory_membership :
  In area1_upper_warp_floor_face area1_q_static_floor_candidates /\
  count_occ
    area1_triangle_index_eq_dec
    area1_q_static_floor_candidates
    area1_upper_warp_floor_face = 1%nat.
Proof.
  split.
  - vm_compute. tauto.
  - vm_compute. reflexivity.
Qed.

(** Integer coordinates are appropriate for these two exact diagnostics: all
    components are in signed-short range, and each source binary32 value is an
    exact integer. *)
Record Area1IntegerQuery : Type := {
  area1_query_x : Z;
  area1_query_y : Z;
  area1_query_z : Z
}.

Definition area1_q_null_sample : Area1IntegerQuery := {|
  area1_query_x := -2200;
  area1_query_y := 768;
  area1_query_z := -1024
|}.

Definition area1_upper_warp_center_sample : Area1IntegerQuery := {|
  area1_query_x := -2048;
  area1_query_y := 768;
  area1_query_z := -1024
|}.

Inductive Area1FloorDiagnosticResult : Type :=
| Area1FloorNull (sentinel_binary32_bits : Z)
| Area1FloorHit
    (selected_face : Area1TriangleIndex)
    (height_binary32_bits : Z).

Record Area1QueryDiagnostic : Type := {
  area1_diagnostic_query : Area1IntegerQuery;
  area1_diagnostic_partition_x : nat;
  area1_diagnostic_partition_z : nat;
  area1_diagnostic_first_wall_pushes : nat;
  area1_diagnostic_second_wall_pushes : nat;
  area1_diagnostic_post_wall_query : Area1IntegerQuery;
  area1_diagnostic_floor_result : Area1FloorDiagnosticResult
}.

(** [3324764160 = 0xC62BE000], the binary32 word for [-11000.0f].
    The NULL diagnostic's cell is x=5,z=7. *)
Definition area1_q_null_diagnostic : Area1QueryDiagnostic := {|
  area1_diagnostic_query := area1_q_null_sample;
  area1_diagnostic_partition_x := 5%nat;
  area1_diagnostic_partition_z := 7%nat;
  area1_diagnostic_first_wall_pushes := 0%nat;
  area1_diagnostic_second_wall_pushes := 0%nat;
  area1_diagnostic_post_wall_query := area1_q_null_sample;
  area1_diagnostic_floor_result := Area1FloorNull 3324764160
|}.

(** [1145044992 = 0x44400000], the binary32 word for [768.0f].
    The exact candidate inventory of the boundary-centre cell is intentionally
    not asserted here; only the independently audited selected face/result is
    recorded. *)
Definition area1_upper_warp_center_diagnostic : Area1QueryDiagnostic := {|
  area1_diagnostic_query := area1_upper_warp_center_sample;
  area1_diagnostic_partition_x := 6%nat;
  area1_diagnostic_partition_z := 7%nat;
  area1_diagnostic_first_wall_pushes := 0%nat;
  area1_diagnostic_second_wall_pushes := 0%nat;
  area1_diagnostic_post_wall_query := area1_upper_warp_center_sample;
  area1_diagnostic_floor_result :=
    Area1FloorHit area1_upper_warp_floor_face 1145044992
|}.

Theorem area1_q_null_diagnostic_result_exact :
  area1_diagnostic_first_wall_pushes area1_q_null_diagnostic = 0%nat /\
  area1_diagnostic_second_wall_pushes area1_q_null_diagnostic = 0%nat /\
  area1_diagnostic_post_wall_query area1_q_null_diagnostic =
    area1_q_null_sample /\
  area1_diagnostic_floor_result area1_q_null_diagnostic =
    Area1FloorNull 3324764160.
Proof. repeat split; reflexivity. Qed.

Theorem area1_upper_warp_center_diagnostic_result_exact :
  area1_diagnostic_post_wall_query area1_upper_warp_center_diagnostic =
    area1_upper_warp_center_sample /\
  area1_diagnostic_floor_result area1_upper_warp_center_diagnostic =
    Area1FloorHit area1_upper_warp_floor_face 1145044992.
Proof. split; reflexivity. Qed.

(** * The west-wall one-unit discontinuity

    At this wall, the source-shaped signed plane offset is [x + 2149].  With a
    radius of 50, offset [-50] is accepted and pushes [x=-2199] to [-2099].
    Offset [-51] is rejected, so [x=-2200] is not moved.  These calculations
    are exact integer-valued instances of the binary32 expressions; executing
    the generated Clight wall loop over a live list remains an obligation
    below. *)

Definition area1_west_wall_radius : Z := 50.

Definition area1_west_wall_plane_offset (x : Z) : Z :=
  x + 2149.

Definition area1_wall_plane_offset_accepted
    (radius offset : Z) : bool :=
  Z.leb (-radius) offset && Z.leb offset radius.

Definition area1_west_wall_push_x (x : Z) : option Z :=
  let offset := area1_west_wall_plane_offset x in
  if area1_wall_plane_offset_accepted area1_west_wall_radius offset
  then Some (x + (area1_west_wall_radius - offset))
  else None.

Theorem area1_west_wall_minus_2199_is_accepted_and_pushed :
  area1_west_wall_plane_offset (-2199) = -50 /\
  area1_wall_plane_offset_accepted
    area1_west_wall_radius
    (area1_west_wall_plane_offset (-2199)) = true /\
  area1_west_wall_push_x (-2199) = Some (-2099).
Proof. vm_compute. auto. Qed.

Theorem area1_west_wall_minus_2200_is_rejected :
  area1_west_wall_plane_offset (-2200) = -51 /\
  area1_wall_plane_offset_accepted
    area1_west_wall_radius
    (area1_west_wall_plane_offset (-2200)) = false /\
  area1_west_wall_push_x (-2200) = None.
Proof. vm_compute. auto. Qed.

(** * Exact floor rejection tally at the NULL sample

    Traversing the 26 candidates rejects twelve at the first edge, eight at
    the second edge, five at the third edge, and the sole XZ-accepted face at
    the 78-unit upward-height buffer. *)

Record Area1FloorRejectionTally : Type := {
  area1_rejected_at_edge_1 : nat;
  area1_rejected_at_edge_2 : nat;
  area1_rejected_at_edge_3 : nat;
  area1_rejected_at_height_buffer : nat
}.

Definition area1_q_floor_rejection_tally : Area1FloorRejectionTally := {|
  area1_rejected_at_edge_1 := 12%nat;
  area1_rejected_at_edge_2 := 8%nat;
  area1_rejected_at_edge_3 := 5%nat;
  area1_rejected_at_height_buffer := 1%nat
|}.

Definition area1_rejection_tally_total
    (tally : Area1FloorRejectionTally) : nat :=
  (area1_rejected_at_edge_1 tally +
   area1_rejected_at_edge_2 tally +
   area1_rejected_at_edge_3 tally +
   area1_rejected_at_height_buffer tally)%nat.

Definition area1_q_only_xz_accepted_face : Area1TriangleIndex :=
  (265, 266, 372).

Theorem area1_q_floor_rejection_tally_is_complete :
  area1_rejection_tally_total area1_q_floor_rejection_tally = 26%nat /\
  area1_rejection_tally_total area1_q_floor_rejection_tally =
    length area1_q_static_floor_candidates /\
  area1_rejected_at_edge_1 area1_q_floor_rejection_tally = 12%nat /\
  area1_rejected_at_edge_2 area1_q_floor_rejection_tally = 8%nat /\
  area1_rejected_at_edge_3 area1_q_floor_rejection_tally = 5%nat /\
  area1_rejected_at_height_buffer area1_q_floor_rejection_tally = 1%nat.
Proof. vm_compute. repeat split; reflexivity. Qed.

Theorem area1_q_height_buffer_rejects_the_only_xz_face :
  In area1_q_only_xz_accepted_face area1_q_static_floor_candidates /\
  768 - (1280 - 78) = -434 /\
  768 < 1280 - 78.
Proof.
  split.
  - vm_compute. tauto.
  - vm_compute. auto.
Qed.

(** * Kernel-computed static query

    The preceding diagnostic record merely states the externally observed
    result.  The evaluator below derives the static-list part of that result
    from the generated-initializer inventories.

    Floor edge expressions use CompCert's signed 32-bit operations.  For the
    one face that survives all three edge tests, the face is exactly
    horizontal, so its height is obtained without an abstract real-number
    plane model.  The separate binary32 receipts below check that the relevant
    axis-aligned loader computations produce the same exact planes.

    This remains a *static* evaluator.  It does not assert that these lists
    occupy live Clight memory, that the dynamic partitions are irrelevant, or
    that a clean retail execution reaches the query. *)

Definition area1_floor_edge_i32
    (query_x query_z : Z)
    (first second : Area1SourceVertex) : int :=
  let '(first_x, _, first_z) := first in
  let '(second_x, _, second_z) := second in
  Int.sub
    (Int.mul
      (Int.sub (Int.repr first_z) (Int.repr query_z))
      (Int.sub (Int.repr second_x) (Int.repr first_x)))
    (Int.mul
      (Int.sub (Int.repr first_x) (Int.repr query_x))
      (Int.sub (Int.repr second_z) (Int.repr first_z))).

Definition area1_floor_edge_Z
    (query_x query_z : Z)
    (first second : Area1SourceVertex) : Z :=
  let '(first_x, _, first_z) := first in
  let '(second_x, _, second_z) := second in
  (first_z - query_z) * (second_x - first_x) -
  (first_x - query_x) * (second_z - first_z).

Definition area1_floor_edge_intermediates
    (query_x query_z : Z)
    (first second : Area1SourceVertex) : list Z :=
  let '(first_x, _, first_z) := first in
  let '(second_x, _, second_z) := second in
  let first_z_delta := first_z - query_z in
  let edge_x_delta := second_x - first_x in
  let first_x_delta := first_x - query_x in
  let edge_z_delta := second_z - first_z in
  let first_product := first_z_delta * edge_x_delta in
  let second_product := first_x_delta * edge_z_delta in
  [first_z_delta; edge_x_delta; first_x_delta; edge_z_delta;
   first_product; second_product; first_product - second_product].

Definition area1_triangle_floor_edge_intermediates
    (vertices : list Area1SourceVertex)
    (query : Area1IntegerQuery)
    (triangle : Area1TriangleIndex) : list Z :=
  match area1_source_triangle_vertices vertices triangle with
  | Some (first, second, third) =>
      area1_floor_edge_intermediates
        (area1_query_x query) (area1_query_z query) first second ++
      area1_floor_edge_intermediates
        (area1_query_x query) (area1_query_z query) second third ++
      area1_floor_edge_intermediates
        (area1_query_x query) (area1_query_z query) third first
  | None => []
  end.

Definition area1_floor_inventory_edge_intermediates
    (vertices : list Area1SourceVertex)
    (query : Area1IntegerQuery)
    (triangles : list Area1TriangleIndex) : list Z :=
  flat_map
    (area1_triangle_floor_edge_intermediates vertices query)
    triangles.

Definition area1_maximum_absolute_value (values : list Z) : Z :=
  fold_left Z.max (map Z.abs values) 0.

Definition area1_triangle_floor_i32_agrees_with_Z
    (vertices : list Area1SourceVertex)
    (query : Area1IntegerQuery)
    (triangle : Area1TriangleIndex) : bool :=
  match area1_source_triangle_vertices vertices triangle with
  | Some (first, second, third) =>
      Z.eqb
        (Int.signed
          (area1_floor_edge_i32
            (area1_query_x query) (area1_query_z query) first second))
        (area1_floor_edge_Z
          (area1_query_x query) (area1_query_z query) first second) &&
      Z.eqb
        (Int.signed
          (area1_floor_edge_i32
            (area1_query_x query) (area1_query_z query) second third))
        (area1_floor_edge_Z
          (area1_query_x query) (area1_query_z query) second third) &&
      Z.eqb
        (Int.signed
          (area1_floor_edge_i32
            (area1_query_x query) (area1_query_z query) third first))
        (area1_floor_edge_Z
          (area1_query_x query) (area1_query_z query) third first)
  | None => false
  end.

Theorem area1_q_static_floor_signed_arithmetic_receipt :
  area1_maximum_absolute_value
    (area1_floor_inventory_edge_intermediates
      area1_collision_vertices_us area1_q_null_sample
      area1_q_static_floor_candidates_computed_us) = 7760025 /\
  area1_maximum_absolute_value
    (area1_floor_inventory_edge_intermediates
      area1_collision_vertices_jp area1_q_null_sample
      area1_q_static_floor_candidates_computed_jp) = 7760025 /\
  7760025 <= 2147483647 /\
  forallb
    (area1_triangle_floor_i32_agrees_with_Z
      area1_collision_vertices_us area1_q_null_sample)
    area1_q_static_floor_candidates_computed_us = true /\
  forallb
    (area1_triangle_floor_i32_agrees_with_Z
      area1_collision_vertices_jp area1_q_null_sample)
    area1_q_static_floor_candidates_computed_jp = true.
Proof.
  split.
  - vm_compute. reflexivity.
  - split.
    + vm_compute. reflexivity.
    + split.
      * lia.
      * split.
        -- vm_compute. reflexivity.
        -- vm_compute. reflexivity.
Qed.

Inductive Area1StaticFloorDecision : Type :=
| Area1StaticFloorRejectEdge1
| Area1StaticFloorRejectEdge2
| Area1StaticFloorRejectEdge3
| Area1StaticFloorRejectHeight
| Area1StaticFloorWouldHit
| Area1StaticFloorUnresolved.

Definition area1_horizontal_floor_height
    (vertices : Area1SourceVertex * Area1SourceVertex * Area1SourceVertex)
    : option Z :=
  let '(first, second, third) := vertices in
  let '(_, first_y, _) := first in
  let '(_, second_y, _) := second in
  let '(_, third_y, _) := third in
  if Z.eqb first_y second_y && Z.eqb second_y third_y
  then Some first_y
  else None.

Definition area1_static_floor_decision
    (vertices : list Area1SourceVertex)
    (query : Area1IntegerQuery)
    (triangle : Area1TriangleIndex) : Area1StaticFloorDecision :=
  match area1_source_triangle_vertices vertices triangle with
  | Some (first, second, third) =>
      if Int.lt
           (area1_floor_edge_i32
             (area1_query_x query) (area1_query_z query) first second)
           Int.zero
      then Area1StaticFloorRejectEdge1
      else if Int.lt
                (area1_floor_edge_i32
                  (area1_query_x query) (area1_query_z query) second third)
                Int.zero
           then Area1StaticFloorRejectEdge2
           else if Int.lt
                     (area1_floor_edge_i32
                       (area1_query_x query) (area1_query_z query) third first)
                     Int.zero
                then Area1StaticFloorRejectEdge3
                else
                  match
                    area1_horizontal_floor_height (first, second, third)
                  with
                  | Some height =>
                      if Z.ltb
                           (area1_query_y query)
                           (height - 78)
                      then Area1StaticFloorRejectHeight
                      else Area1StaticFloorWouldHit
                  | None => Area1StaticFloorUnresolved
                  end
  | None => Area1StaticFloorUnresolved
  end.

Definition area1_static_floor_decision_is_rejection
    (decision : Area1StaticFloorDecision) : bool :=
  match decision with
  | Area1StaticFloorRejectEdge1
  | Area1StaticFloorRejectEdge2
  | Area1StaticFloorRejectEdge3
  | Area1StaticFloorRejectHeight => true
  | Area1StaticFloorWouldHit
  | Area1StaticFloorUnresolved => false
  end.

Definition area1_count_floor_decision
    (wanted : Area1StaticFloorDecision)
    (trace : list Area1StaticFloorDecision) : nat :=
  length
    (filter
      (fun found =>
      match wanted, found with
      | Area1StaticFloorRejectEdge1, Area1StaticFloorRejectEdge1
      | Area1StaticFloorRejectEdge2, Area1StaticFloorRejectEdge2
      | Area1StaticFloorRejectEdge3, Area1StaticFloorRejectEdge3
      | Area1StaticFloorRejectHeight, Area1StaticFloorRejectHeight
      | Area1StaticFloorWouldHit, Area1StaticFloorWouldHit
      | Area1StaticFloorUnresolved, Area1StaticFloorUnresolved => true
      | _, _ => false
      end)
      trace).

Definition area1_floor_tally_from_trace
    (trace : list Area1StaticFloorDecision) : Area1FloorRejectionTally := {|
  area1_rejected_at_edge_1 :=
    area1_count_floor_decision Area1StaticFloorRejectEdge1 trace;
  area1_rejected_at_edge_2 :=
    area1_count_floor_decision Area1StaticFloorRejectEdge2 trace;
  area1_rejected_at_edge_3 :=
    area1_count_floor_decision Area1StaticFloorRejectEdge3 trace;
  area1_rejected_at_height_buffer :=
    area1_count_floor_decision Area1StaticFloorRejectHeight trace
|}.

Record Area1ComputedStaticFloorEvaluation : Type := {
  area1_computed_static_floor_trace : list Area1StaticFloorDecision;
  area1_computed_static_floor_result : Area1FloorDiagnosticResult;
  area1_computed_static_floor_tally : Area1FloorRejectionTally
}.

Definition area1_static_floor_lower_limit_bits : Z :=
  Int.unsigned
    (Float32.to_bits
      (Float32.of_int (Int.repr (-11000)))).

Theorem area1_static_floor_lower_limit_binary32_receipt :
  area1_static_floor_lower_limit_bits = 3324764160.
Proof. vm_compute. reflexivity. Qed.

Definition area1_compute_static_floor_evaluation
    (vertices : list Area1SourceVertex)
    (query : Area1IntegerQuery)
    (triangles : list Area1TriangleIndex)
    : option Area1ComputedStaticFloorEvaluation :=
  let trace :=
    map (area1_static_floor_decision vertices query) triangles in
  if forallb area1_static_floor_decision_is_rejection trace
  then Some {|
    area1_computed_static_floor_trace := trace;
    area1_computed_static_floor_result :=
      Area1FloorNull area1_static_floor_lower_limit_bits;
    area1_computed_static_floor_tally := area1_floor_tally_from_trace trace
  |}
  else None.

Inductive Area1StaticWallDecision : Type :=
| Area1StaticWallRejectY
| Area1StaticWallRejectOffset (offset : Z)
| Area1StaticWallNeedsProjection
| Area1StaticWallUnresolved.

Definition area1_minimum3 (first second third : Z) : Z :=
  Z.min first (Z.min second third).

Definition area1_maximum3 (first second third : Z) : Z :=
  Z.max first (Z.max second third).

(** Exact signed distance for an axis-aligned wall.  [read_surface_data]
    normalizes these faces to one of [(+/-1,0,0)] or [(0,0,+/-1)];
    the binary32 receipt below checks that fact for every face whose Y range
    survives at the diagnostic query. *)
Definition area1_axis_aligned_wall_offset
    (query : Area1IntegerQuery)
    (vertices : Area1SourceVertex * Area1SourceVertex * Area1SourceVertex)
    : option Z :=
  let '(first, _, _) := vertices in
  let '(first_x, _, first_z) := first in
  let '(normal_x, normal_y, normal_z) :=
    area1_source_normal_components vertices in
  if negb (Z.eqb normal_y 0) then None
  else if Z.eqb normal_z 0 && negb (Z.eqb normal_x 0)
       then
         Some
           (if Z.ltb 0 normal_x
            then area1_query_x query - first_x
            else first_x - area1_query_x query)
       else if Z.eqb normal_x 0 && negb (Z.eqb normal_z 0)
            then
              Some
                (if Z.ltb 0 normal_z
                 then area1_query_z query - first_z
                 else first_z - area1_query_z query)
            else None.

Definition area1_static_wall_decision
    (vertices : list Area1SourceVertex)
    (query : Area1IntegerQuery)
    (offset_y radius : Z)
    (triangle : Area1TriangleIndex) : Area1StaticWallDecision :=
  match area1_source_triangle_vertices vertices triangle with
  | Some triangle_vertices =>
      let '(first, second, third) := triangle_vertices in
      let '(_, first_y, _) := first in
      let '(_, second_y, _) := second in
      let '(_, third_y, _) := third in
      let sampled_y := area1_query_y query + offset_y in
      let lower_y := area1_minimum3 first_y second_y third_y - 5 in
      let upper_y := area1_maximum3 first_y second_y third_y + 5 in
      if Z.ltb sampled_y lower_y || Z.ltb upper_y sampled_y
      then Area1StaticWallRejectY
      else
        match area1_axis_aligned_wall_offset query triangle_vertices with
        | Some plane_offset =>
            if Z.ltb plane_offset (-radius) ||
               Z.ltb radius plane_offset
            then Area1StaticWallRejectOffset plane_offset
            else Area1StaticWallNeedsProjection
        | None => Area1StaticWallUnresolved
        end
  | None => Area1StaticWallUnresolved
  end.

Definition area1_static_wall_decision_is_rejection
    (decision : Area1StaticWallDecision) : bool :=
  match decision with
  | Area1StaticWallRejectY
  | Area1StaticWallRejectOffset _ => true
  | Area1StaticWallNeedsProjection
  | Area1StaticWallUnresolved => false
  end.

Record Area1ComputedStaticWallPass : Type := {
  area1_computed_static_wall_trace : list Area1StaticWallDecision;
  area1_computed_static_wall_collisions : nat;
  area1_computed_static_wall_post_query : Area1IntegerQuery
}.

Definition area1_compute_static_wall_pass
    (vertices : list Area1SourceVertex)
    (query : Area1IntegerQuery)
    (offset_y radius : Z)
    (triangles : list Area1TriangleIndex)
    : option Area1ComputedStaticWallPass :=
  let trace :=
    map
      (area1_static_wall_decision
        vertices query offset_y radius)
      triangles in
  if forallb area1_static_wall_decision_is_rejection trace
  then Some {|
    area1_computed_static_wall_trace := trace;
    area1_computed_static_wall_collisions := 0%nat;
    area1_computed_static_wall_post_query := query
  |}
  else None.

(** * Binary32 receipts for the decisive axis-aligned faces *)

Definition area1_f32_of_Z (value : Z) : float32 :=
  Float32.of_int (Int.repr value).

Definition area1_f32_add4
    (first second third fourth : float32) : float32 :=
  Float32.add (Float32.add (Float32.add first second) third) fourth.

Definition area1_f32_reciprocal_via_double (value : float32) : float32 :=
  Float.to_single
    (Float.div
      (Float.of_single (area1_f32_of_Z 1))
      (Float.of_single value)).

Definition Area1LoadedPlane : Type :=
  (float32 * float32 * float32 * float32)%type.

Definition area1_compute_loaded_plane
    (vertices :
      Area1SourceVertex * Area1SourceVertex * Area1SourceVertex)
    : Area1LoadedPlane :=
  let '(first, _, _) := vertices in
  let '(first_x, first_y, first_z) := first in
  let '(raw_x, raw_y, raw_z) :=
    area1_source_normal_components vertices in
  let unnormalized_x :=
    area1_f32_of_Z (Int.signed (Int.repr raw_x)) in
  let unnormalized_y :=
    area1_f32_of_Z (Int.signed (Int.repr raw_y)) in
  let unnormalized_z :=
    area1_f32_of_Z (Int.signed (Int.repr raw_z)) in
  let magnitude :=
    Float32.sqrt
      (Float32.add
        (Float32.add
          (Float32.mul unnormalized_x unnormalized_x)
          (Float32.mul unnormalized_y unnormalized_y))
        (Float32.mul unnormalized_z unnormalized_z)) in
  let inverse := area1_f32_reciprocal_via_double magnitude in
  let normal_x := Float32.mul unnormalized_x inverse in
  let normal_y := Float32.mul unnormalized_y inverse in
  let normal_z := Float32.mul unnormalized_z inverse in
  let origin_offset :=
    Float32.neg
      (Float32.add
        (Float32.add
          (Float32.mul normal_x (area1_f32_of_Z first_x))
          (Float32.mul normal_y (area1_f32_of_Z first_y)))
        (Float32.mul normal_z (area1_f32_of_Z first_z))) in
  (normal_x, normal_y, normal_z, origin_offset).

Definition area1_loaded_plane_for_triangle
    (vertices : list Area1SourceVertex)
    (triangle : Area1TriangleIndex) : option Area1LoadedPlane :=
  option_map area1_compute_loaded_plane
    (area1_source_triangle_vertices vertices triangle).

Definition area1_loaded_plane_bits
    (vertices : list Area1SourceVertex)
    (triangle : Area1TriangleIndex) : option (Z * Z * Z * Z) :=
  match area1_loaded_plane_for_triangle vertices triangle with
  | Some (normal_x, normal_y, normal_z, origin_offset) =>
      Some
        (Int.unsigned (Float32.to_bits normal_x),
         Int.unsigned (Float32.to_bits normal_y),
         Int.unsigned (Float32.to_bits normal_z),
         Int.unsigned (Float32.to_bits origin_offset))
  | None => None
  end.

Definition area1_loaded_wall_offset
    (vertices : list Area1SourceVertex)
    (triangle : Area1TriangleIndex)
    (query_x query_y query_z : Z) : option float32 :=
  match area1_loaded_plane_for_triangle vertices triangle with
  | Some (normal_x, normal_y, normal_z, origin_offset) =>
      Some
        (area1_f32_add4
          (Float32.mul normal_x (area1_f32_of_Z query_x))
          (Float32.mul normal_y (area1_f32_of_Z query_y))
          (Float32.mul normal_z (area1_f32_of_Z query_z))
          origin_offset)
  | None => None
  end.

Definition area1_loaded_wall_offset_bits
    (vertices : list Area1SourceVertex)
    (triangle : Area1TriangleIndex)
    (query_x query_y query_z : Z) : option Z :=
  option_map
    (fun offset => Int.unsigned (Float32.to_bits offset))
    (area1_loaded_wall_offset
      vertices triangle query_x query_y query_z).

Definition area1_loaded_floor_height
    (vertices : list Area1SourceVertex)
    (triangle : Area1TriangleIndex)
    (query_x query_z : Z) : option float32 :=
  match area1_loaded_plane_for_triangle vertices triangle with
  | Some (normal_x, normal_y, normal_z, origin_offset) =>
      Some
        (Float32.div
          (Float32.neg
            (Float32.add
              (Float32.add
                (Float32.mul
                  (area1_f32_of_Z query_x) normal_x)
                (Float32.mul normal_z (area1_f32_of_Z query_z)))
              origin_offset))
          normal_y)
  | None => None
  end.

Definition area1_loaded_floor_buffer_difference
    (vertices : list Area1SourceVertex)
    (triangle : Area1TriangleIndex)
    (query : Area1IntegerQuery) : option float32 :=
  option_map
    (fun height =>
      Float32.sub
        (area1_f32_of_Z (area1_query_y query))
        (Float32.add height (area1_f32_of_Z (-78))))
    (area1_loaded_floor_height
      vertices triangle
      (area1_query_x query) (area1_query_z query)).

Definition area1_q_decisive_axis_faces : list Area1TriangleIndex :=
  [(263, 498, 502);
   (266, 502, 501);
   (266, 501, 372);
   (263, 502, 266);
   (265, 266, 372)].

Definition area1_q_y_live_wall_faces : list Area1TriangleIndex :=
  firstn 4 area1_q_decisive_axis_faces.

Theorem area1_q_decisive_axis_raw_normals_and_bounds :
  map
    (fun triangle =>
      option_map area1_source_normal_components
        (area1_source_triangle_vertices
          area1_collision_vertices_us triangle))
    area1_q_decisive_axis_faces =
      [Some (0, 0, -104448);
       Some (104448, 0, 0);
       Some (104448, 0, 0);
       Some (0, 0, -104448);
       Some (0, 83640, 0)] /\
  104448 <= 2147483647 /\
  map
    (fun triangle =>
      option_map area1_source_normal_components
        (area1_source_triangle_vertices
          area1_collision_vertices_jp triangle))
    area1_q_decisive_axis_faces =
      [Some (0, 0, -104448);
       Some (104448, 0, 0);
       Some (104448, 0, 0);
       Some (0, 0, -104448);
       Some (0, 83640, 0)].
Proof.
  split.
  - vm_compute. reflexivity.
  - split.
    + lia.
    + vm_compute. reflexivity.
Qed.

Definition area1_source_normal_signed_intermediates
    (vertices :
      Area1SourceVertex * Area1SourceVertex * Area1SourceVertex)
    : list Z :=
  let '(first, second, third) := vertices in
  let '(x1, y1, z1) := first in
  let '(x2, y2, z2) := second in
  let '(x3, y3, z3) := third in
  let delta_y21 := y2 - y1 in
  let delta_z32 := z3 - z2 in
  let delta_z21 := z2 - z1 in
  let delta_y32 := y3 - y2 in
  let delta_x32 := x3 - x2 in
  let delta_x21 := x2 - x1 in
  [delta_y21; delta_z32; delta_z21; delta_y32;
   delta_x32; delta_x21;
   delta_y21 * delta_z32;
   delta_z21 * delta_y32;
   delta_z21 * delta_x32;
   delta_x21 * delta_z32;
   delta_x21 * delta_y32;
   delta_y21 * delta_x32;
   delta_y21 * delta_z32 - delta_z21 * delta_y32;
   delta_z21 * delta_x32 - delta_x21 * delta_z32;
   delta_x21 * delta_y32 - delta_y21 * delta_x32].

Definition area1_decisive_axis_normal_signed_intermediates
    (vertices : list Area1SourceVertex) : list Z :=
  flat_map
    (fun triangle =>
      match area1_source_triangle_vertices vertices triangle with
      | Some triangle_vertices =>
          area1_source_normal_signed_intermediates triangle_vertices
      | None => []
      end)
    area1_q_decisive_axis_faces.

Theorem area1_q_decisive_axis_normal_signed_arithmetic_receipt :
  area1_maximum_absolute_value
    (area1_decisive_axis_normal_signed_intermediates
      area1_collision_vertices_us) = 104448 /\
  area1_maximum_absolute_value
    (area1_decisive_axis_normal_signed_intermediates
      area1_collision_vertices_jp) = 104448 /\
  104448 <= 2147483647.
Proof.
  split.
  - vm_compute. reflexivity.
  - split.
    + vm_compute. reflexivity.
    + lia.
Qed.

Theorem area1_q_decisive_loaded_plane_binary32_receipt :
  map
    (area1_loaded_plane_bits area1_collision_vertices_us)
    area1_q_decisive_axis_faces =
      [Some (0, 0, 3212836864, 3295035392);
       Some (1065353216, 0, 0, 1158041600);
       Some (1065353216, 0, 0, 1158041600);
       Some (0, 0, 3212836864, 3295035392);
       Some (0, 1065353216, 0, 3298820096)] /\
  map
    (area1_loaded_plane_bits area1_collision_vertices_jp)
    area1_q_decisive_axis_faces =
      [Some (0, 0, 3212836864, 3295035392);
       Some (1065353216, 0, 0, 1158041600);
       Some (1065353216, 0, 0, 1158041600);
       Some (0, 0, 3212836864, 3295035392);
       Some (0, 1065353216, 0, 3298820096)].
Proof.
  vm_compute.
  split; reflexivity.
Qed.

Theorem area1_q_y_live_wall_offsets_binary32_receipt :
  map
    (fun triangle =>
      area1_loaded_wall_offset_bits
        area1_collision_vertices_us triangle (-2200) 828 (-1024))
    area1_q_y_live_wall_faces =
      [Some 1120796672; Some 3259760640;
       Some 3259760640; Some 1120796672] /\
  map
    (fun triangle =>
      area1_loaded_wall_offset_bits
        area1_collision_vertices_us triangle (-2200) 798 (-1024))
    area1_q_y_live_wall_faces =
      [Some 1120796672; Some 3259760640;
       Some 3259760640; Some 1120796672] /\
  map
    (fun triangle =>
      area1_loaded_wall_offset_bits
        area1_collision_vertices_jp triangle (-2200) 828 (-1024))
    area1_q_y_live_wall_faces =
      [Some 1120796672; Some 3259760640;
       Some 3259760640; Some 1120796672] /\
  map
    (fun triangle =>
      area1_loaded_wall_offset_bits
        area1_collision_vertices_jp triangle (-2200) 798 (-1024))
    area1_q_y_live_wall_faces =
      [Some 1120796672; Some 3259760640;
       Some 3259760640; Some 1120796672].
Proof.
  vm_compute.
  repeat split; reflexivity.
Qed.

Theorem area1_q_roof_height_and_buffer_binary32_receipt :
  option_map
    (fun height => Int.unsigned (Float32.to_bits height))
    (area1_loaded_floor_height
      area1_collision_vertices_us area1_q_only_xz_accepted_face
      (-2200) (-1024)) = Some 1151336448 /\
  option_map
    (fun difference =>
      (Int.unsigned (Float32.to_bits difference),
       Float32.cmp Clt difference (area1_f32_of_Z 0)))
    (area1_loaded_floor_buffer_difference
      area1_collision_vertices_us area1_q_only_xz_accepted_face
      area1_q_null_sample) = Some (3285778432, true) /\
  option_map
    (fun height => Int.unsigned (Float32.to_bits height))
    (area1_loaded_floor_height
      area1_collision_vertices_jp area1_q_only_xz_accepted_face
      (-2200) (-1024)) = Some 1151336448 /\
  option_map
    (fun difference =>
      (Int.unsigned (Float32.to_bits difference),
       Float32.cmp Clt difference (area1_f32_of_Z 0)))
    (area1_loaded_floor_buffer_difference
      area1_collision_vertices_jp area1_q_only_xz_accepted_face
      area1_q_null_sample) = Some (3285778432, true).
Proof.
  vm_compute.
  repeat split; reflexivity.
Qed.

Definition area1_q_static_wall_pass_witness
    (vertices : list Area1SourceVertex)
    (triangles : list Area1TriangleIndex)
    (offset_y radius : Z) : Area1ComputedStaticWallPass := {|
  area1_computed_static_wall_trace :=
    map
      (area1_static_wall_decision
        vertices area1_q_null_sample offset_y radius)
      triangles;
  area1_computed_static_wall_collisions := 0%nat;
  area1_computed_static_wall_post_query := area1_q_null_sample
|}.

Definition area1_q_static_floor_witness
    (vertices : list Area1SourceVertex)
    (triangles : list Area1TriangleIndex)
    : Area1ComputedStaticFloorEvaluation :=
  let trace :=
    map
      (area1_static_floor_decision
        vertices area1_q_null_sample)
      triangles in {|
  area1_computed_static_floor_trace := trace;
  area1_computed_static_floor_result :=
    Area1FloorNull area1_static_floor_lower_limit_bits;
  area1_computed_static_floor_tally := area1_floor_tally_from_trace trace
|}.

(** Unlike the result-record witnesses below, this theorem exposes the
    decisive executable premises directly: every decision computed from each
    source-ordered US/JP list is a rejection.  The wall checks cover the
    source-shaped static list for each of the two Mario geometry-query
    radius/offset pairs; they do not execute the dynamic-list calls that
    precede each static-list call.  The floor checks cover the reconstructed
    source-shaped static cell list. *)
Theorem area1_q_static_all_rejection_checks_computed :
  forallb area1_static_wall_decision_is_rejection
    (map
      (area1_static_wall_decision
        area1_collision_vertices_us area1_q_null_sample 60 50)
      area1_q_static_wall_candidates_computed_us) = true /\
  forallb area1_static_wall_decision_is_rejection
    (map
      (area1_static_wall_decision
        area1_collision_vertices_us area1_q_null_sample 30 24)
      area1_q_static_wall_candidates_computed_us) = true /\
  forallb area1_static_wall_decision_is_rejection
    (map
      (area1_static_wall_decision
        area1_collision_vertices_jp area1_q_null_sample 60 50)
      area1_q_static_wall_candidates_computed_jp) = true /\
  forallb area1_static_wall_decision_is_rejection
    (map
      (area1_static_wall_decision
        area1_collision_vertices_jp area1_q_null_sample 30 24)
      area1_q_static_wall_candidates_computed_jp) = true /\
  forallb area1_static_floor_decision_is_rejection
    (map
      (area1_static_floor_decision
        area1_collision_vertices_us area1_q_null_sample)
      area1_q_static_floor_candidates_computed_us) = true /\
  forallb area1_static_floor_decision_is_rejection
    (map
      (area1_static_floor_decision
        area1_collision_vertices_jp area1_q_null_sample)
      area1_q_static_floor_candidates_computed_jp) = true.
Proof.
  vm_compute.
  repeat split; reflexivity.
Qed.

Theorem area1_q_static_wall_passes_computed :
  area1_compute_static_wall_pass
    area1_collision_vertices_us area1_q_null_sample 60 50
    area1_q_static_wall_candidates_computed_us =
      Some
        (area1_q_static_wall_pass_witness
          area1_collision_vertices_us
          area1_q_static_wall_candidates_computed_us 60 50) /\
  area1_compute_static_wall_pass
    area1_collision_vertices_us area1_q_null_sample 30 24
    area1_q_static_wall_candidates_computed_us =
      Some
        (area1_q_static_wall_pass_witness
          area1_collision_vertices_us
          area1_q_static_wall_candidates_computed_us 30 24) /\
  area1_compute_static_wall_pass
    area1_collision_vertices_jp area1_q_null_sample 60 50
    area1_q_static_wall_candidates_computed_jp =
      Some
        (area1_q_static_wall_pass_witness
          area1_collision_vertices_jp
          area1_q_static_wall_candidates_computed_jp 60 50) /\
  area1_compute_static_wall_pass
    area1_collision_vertices_jp area1_q_null_sample 30 24
    area1_q_static_wall_candidates_computed_jp =
      Some
        (area1_q_static_wall_pass_witness
          area1_collision_vertices_jp
          area1_q_static_wall_candidates_computed_jp 30 24).
Proof.
  vm_compute.
  repeat split; reflexivity.
Qed.

Theorem area1_q_static_floor_rejection_trace_computed :
  area1_compute_static_floor_evaluation
    area1_collision_vertices_us area1_q_null_sample
    area1_q_static_floor_candidates_computed_us =
      Some
        (area1_q_static_floor_witness
          area1_collision_vertices_us
          area1_q_static_floor_candidates_computed_us) /\
  area1_computed_static_floor_tally
    (area1_q_static_floor_witness
      area1_collision_vertices_us
      area1_q_static_floor_candidates_computed_us) =
        area1_q_floor_rejection_tally /\
  area1_compute_static_floor_evaluation
    area1_collision_vertices_jp area1_q_null_sample
    area1_q_static_floor_candidates_computed_jp =
      Some
        (area1_q_static_floor_witness
          area1_collision_vertices_jp
          area1_q_static_floor_candidates_computed_jp) /\
  area1_computed_static_floor_tally
    (area1_q_static_floor_witness
      area1_collision_vertices_jp
      area1_q_static_floor_candidates_computed_jp) =
        area1_q_floor_rejection_tally.
Proof.
  vm_compute.
  repeat split; reflexivity.
Qed.

(** This is the strongest result of the pure evaluator: both source-ordered
    static wall lists reject before a push, and every source-ordered static
    floor candidate has a computed rejection reason.  The tally is obtained
    by counting the computed trace, rather than by projecting the earlier
    literal diagnostic. *)
Theorem area1_q_static_traversal_computed :
  (area1_compute_static_wall_pass
     area1_collision_vertices_us area1_q_null_sample 60 50
     area1_q_static_wall_candidates_computed_us =
       Some
         (area1_q_static_wall_pass_witness
           area1_collision_vertices_us
           area1_q_static_wall_candidates_computed_us 60 50) /\
   area1_compute_static_wall_pass
     area1_collision_vertices_us area1_q_null_sample 30 24
     area1_q_static_wall_candidates_computed_us =
       Some
         (area1_q_static_wall_pass_witness
           area1_collision_vertices_us
           area1_q_static_wall_candidates_computed_us 30 24) /\
   area1_compute_static_wall_pass
     area1_collision_vertices_jp area1_q_null_sample 60 50
     area1_q_static_wall_candidates_computed_jp =
       Some
         (area1_q_static_wall_pass_witness
           area1_collision_vertices_jp
           area1_q_static_wall_candidates_computed_jp 60 50) /\
   area1_compute_static_wall_pass
     area1_collision_vertices_jp area1_q_null_sample 30 24
     area1_q_static_wall_candidates_computed_jp =
       Some
         (area1_q_static_wall_pass_witness
           area1_collision_vertices_jp
           area1_q_static_wall_candidates_computed_jp 30 24)) /\
  (area1_compute_static_floor_evaluation
     area1_collision_vertices_us area1_q_null_sample
     area1_q_static_floor_candidates_computed_us =
       Some
         (area1_q_static_floor_witness
           area1_collision_vertices_us
           area1_q_static_floor_candidates_computed_us) /\
   area1_computed_static_floor_tally
     (area1_q_static_floor_witness
       area1_collision_vertices_us
       area1_q_static_floor_candidates_computed_us) =
         area1_q_floor_rejection_tally /\
   area1_compute_static_floor_evaluation
     area1_collision_vertices_jp area1_q_null_sample
     area1_q_static_floor_candidates_computed_jp =
       Some
         (area1_q_static_floor_witness
           area1_collision_vertices_jp
           area1_q_static_floor_candidates_computed_jp) /\
   area1_computed_static_floor_tally
     (area1_q_static_floor_witness
       area1_collision_vertices_jp
       area1_q_static_floor_candidates_computed_jp) =
         area1_q_floor_rejection_tally).
Proof.
  split.
  - exact area1_q_static_wall_passes_computed.
  - exact area1_q_static_floor_rejection_trace_computed.
Qed.

(** * Pending concrete-execution obligations

    [Area1LiveCollisionListExecutionObligation] is intentionally a schema for
    relations that must be instantiated with actual US/JP Clight call
    segments.  It requires both live partition ownership and the two concrete
    [find_floor] results.  Nothing in this file proves an inhabitant.

    The second definition asks the separate gameplay question: can a clean
    Area-1 retail run reach this sample as its first NULL State query?  Future
    work may prove the proposition or its negation.  Merely possessing the
    static NULL capability does not answer it. *)

Definition Area1LiveCollisionListExecutionObligation
    (live_static_cell_lists :
      GameVersion -> Clight.state -> nat -> nat ->
      list Area1TriangleIndex -> list Area1TriangleIndex -> Prop)
    (executes_live_find_floor :
      GameVersion -> Area1IntegerQuery ->
      Clight.state -> Clight.state -> Area1FloorDiagnosticResult -> Prop) :
    Prop :=
  forall version,
    exists q_memory q_return center_memory center_return,
      live_static_cell_lists version q_memory 5%nat 7%nat
        area1_q_static_wall_candidates
        area1_q_static_floor_candidates /\
      executes_live_find_floor version area1_q_null_sample
        q_memory q_return (Area1FloorNull 3324764160) /\
      executes_live_find_floor version area1_upper_warp_center_sample
        center_memory center_return
        (Area1FloorHit area1_upper_warp_floor_face 1145044992).

Definition Area1FirstNullReachabilityObligation
    (clean_area1_entry_memory : GameVersion -> Clight.state -> Prop)
    (retail_reaches :
      GameVersion -> Clight.state -> Clight.state -> Prop)
    (executes_first_live_find_floor :
      GameVersion -> Area1IntegerQuery ->
      Clight.state -> Clight.state -> Area1FloorDiagnosticResult -> Prop) :
    Prop :=
  exists version initial query_state return_state,
    clean_area1_entry_memory version initial /\
    retail_reaches version initial query_state /\
    executes_first_live_find_floor version area1_q_null_sample
      query_state return_state (Area1FloorNull 3324764160).
