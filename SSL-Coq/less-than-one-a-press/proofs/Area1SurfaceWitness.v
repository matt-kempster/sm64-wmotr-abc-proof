(** Exact value-level geometry for the corrected Area-1 fragment witness.

    [Area1PhaseSplit] establishes that the stock PRNG seed 0 and the
    cartoon-star fragment payload produce the binary32 MarioState position

      (-2350.8427734375, 1878.6683349609375, -714.5823974609375)

    from the node-0x1E upper-warp centre when the fragment pivot is the
    source-derived [(-3000, 640, 800)].  This file proves the next bounded
    facts:

    - [find_floor]'s signed-short casts produce query
      [(-2350, 1878, -714)];
    - that query passes all three signed-32 edge tests for the parsed
      pyramid-top face [(0,2,3)];
    - a source-shaped binary32 face-plane calculation returns height
      [1483.603515625], whose word is [1153004368];
    - the 78-unit upward floor buffer accepts the query; and
    - a manually transcribed static face at height 1280 also accepts the
      query, while the top-face height is greater.

    These are functional and source-data facts.  They do not execute
    [transform_object_vertices], [read_surface_data], or [find_floor] in
    linked Clight memory.  In particular, they do not establish live
    dynamic-surface ownership, partition-list order, a reachable stale
    platform pointer, free-list alignment, or a route to either target star.
    The result is a payload-and-geometry capability witness, not a gameplay
    counterexample and not the ultimate no-A theorem. *)

From Coq Require Import List ZArith.
From compcert Require Import
  AST Cop Ctypes Floats Integers Memory Values.
From LessThanOneAPress.Proofs Require Import
  ASTFacts Area1PhaseSplit CollisionMeshFacts PyramidTopSurface.

Import ListNotations.
Local Open Scope Z_scope.

(** The exact output is first tied back to the binary32 computation in
    [Area1PhaseSplit], rather than introduced as an unrelated coordinate. *)
Definition area1_surface_witness_output_bits : Prop :=
  Float32.to_bits
    (f32_x concrete_area1_fragment_displacement) =
      Int.repr 3306351996 /\
  Float32.to_bits
    (f32_y concrete_area1_fragment_displacement) =
      Int.repr 1156240739 /\
  Float32.to_bits
    (f32_z concrete_area1_fragment_displacement) =
      Int.repr 3291653446.

Theorem area1_surface_witness_output_bits_checked :
  area1_surface_witness_output_bits.
Proof.
  unfold area1_surface_witness_output_bits.
  pose proof
    concrete_area1_fragment_displacement_is_route_sized_3d as H.
  tauto.
Qed.

(** CompCert's generated [find_floor] casts each [float] input to signed
    [TerrainData] ([s16]).  All three witness values are within signed-short
    range, so this does not depend on the target's out-of-range conversion
    behavior. *)
Definition area1_surface_witness_short_cast_claim : Prop :=
  forall memory,
    concrete_short_cast 3306351996 memory =
      Some (Vint (Int.repr (-2350))) /\
    concrete_short_cast 1156240739 memory =
      Some (Vint (Int.repr 1878)) /\
    concrete_short_cast 3291653446 memory =
      Some (Vint (Int.repr (-714))).

Theorem area1_surface_witness_short_casts :
  area1_surface_witness_short_cast_claim.
Proof.
  intros memory.
  vm_compute.
  repeat split; reflexivity.
Qed.

Definition area1_surface_query_xz : VertexXZ := {|
  vertex_x := Int.repr (-2350);
  vertex_z := Int.repr (-714)
|}.

Definition area1_top_face_vertex0_xz : VertexXZ := {|
  vertex_x := Int.repr (-2558);
  vertex_z := Int.repr (-511)
|}.

Definition area1_top_face_vertex2_xz : VertexXZ := {|
  vertex_x := Int.repr (-1535);
  vertex_z := Int.repr (-511)
|}.

Definition area1_top_face_vertex3_xz : VertexXZ := {|
  vertex_x := Int.repr (-2047);
  vertex_z := Int.repr (-1023)
|}.

(** Face 1 in the complete generated six-face stream is [(0,2,3)].  The
    world vertices below are the manually mirrored home, zero-yaw transform
    of the three parsed local vertices. *)
Definition area1_top_face_source_claim : Prop :=
  pyramid_top_source_mesh_claim /\
  nth_error pyramid_top_triangles 1 = Some (0, 2, 3) /\
  nth_error pyramid_top_vertices 0 = Some (-511, -255, 512) /\
  nth_error pyramid_top_vertices 2 = Some (512, -255, 512) /\
  nth_error pyramid_top_vertices 3 = Some (0, 256, 0) /\
  option_map home_zero_yaw_vertex
    (nth_error pyramid_top_vertices 0) =
      Some (-2558, 1281, -511) /\
  option_map home_zero_yaw_vertex
    (nth_error pyramid_top_vertices 2) =
      Some (-1535, 1281, -511) /\
  option_map home_zero_yaw_vertex
    (nth_error pyramid_top_vertices 3) =
      Some (-2047, 1792, -1023).

Theorem area1_top_face_source_checked :
  area1_top_face_source_claim.
Proof.
  unfold area1_top_face_source_claim.
  split; [exact pyramid_top_source_mesh_checked |].
  unfold pyramid_top_triangles, pyramid_top_vertices,
    home_zero_yaw_vertex.
  vm_compute.
  repeat split; reflexivity.
Qed.

Definition area1_top_face_edge_claim : Prop :=
  Int.signed
    (floor_edge_value area1_surface_query_xz
      area1_top_face_vertex0_xz area1_top_face_vertex2_xz) = 207669 /\
  Int.signed
    (floor_edge_value area1_surface_query_xz
      area1_top_face_vertex2_xz area1_top_face_vertex3_xz) = 313344 /\
  Int.signed
    (floor_edge_value area1_surface_query_xz
      area1_top_face_vertex3_xz area1_top_face_vertex0_xz) = 2763 /\
  Int.lt
    (floor_edge_value area1_surface_query_xz
      area1_top_face_vertex0_xz area1_top_face_vertex2_xz)
    Int.zero = false /\
  Int.lt
    (floor_edge_value area1_surface_query_xz
      area1_top_face_vertex2_xz area1_top_face_vertex3_xz)
    Int.zero = false /\
  Int.lt
    (floor_edge_value area1_surface_query_xz
      area1_top_face_vertex3_xz area1_top_face_vertex0_xz)
    Int.zero = false.

Theorem area1_top_face_edge_tests :
  area1_top_face_edge_claim.
Proof.
  unfold area1_top_face_edge_claim, floor_edge_value,
    area1_surface_query_xz, area1_top_face_vertex0_xz,
    area1_top_face_vertex2_xz, area1_top_face_vertex3_xz.
  vm_compute.
  repeat split; reflexivity.
Qed.

(** Integer cross-product arithmetic for world vertices

      p1 = (-2558,1281,-511)
      p2 = (-1535,1281,-511)
      p3 = (-2047,1792,-1023).

    This is the expression used by [read_surface_data] before conversion to
    binary32. *)
Definition area1_top_face_raw_normal_claim : Prop :=
  (1281 - 1281) * (-1023 - -511) -
      (-511 - -511) * (1792 - 1281) = 0 /\
  (-511 - -511) * (-2047 - -1535) -
      (-1535 - -2558) * (-1023 - -511) = 523776 /\
  (-1535 - -2558) * (1792 - 1281) -
      (1281 - 1281) * (-2047 - -1535) = 522753.

Theorem area1_top_face_raw_normal_checked :
  area1_top_face_raw_normal_claim.
Proof. vm_compute. repeat split; reflexivity. Qed.

(** Functional mirror of the binary32 part of [read_surface_data].
    [Float32.sqrt] supplies the expected single-precision [sqrtf] value.
    The reciprocal is expressed as double division followed by conversion
    back to single because the C source writes [(f32)(1.0 / mag)]. *)
Definition f32_reciprocal_via_double (value : float32) : float32 :=
  Float.to_single
    (Float.div
      (Float.of_single (f32_of_Z 1))
      (Float.of_single value)).

Definition area1_top_face_normal_magnitude : float32 :=
  Float32.sqrt
    (f32_add3
      (Float32.mul (f32_of_Z 0) (f32_of_Z 0))
      (Float32.mul (f32_of_Z 523776) (f32_of_Z 523776))
      (Float32.mul (f32_of_Z 522753) (f32_of_Z 522753))).

Definition area1_top_face_normal_inverse : float32 :=
  f32_reciprocal_via_double area1_top_face_normal_magnitude.

Definition area1_top_face_normal_x : float32 :=
  Float32.mul (f32_of_Z 0) area1_top_face_normal_inverse.

Definition area1_top_face_normal_y : float32 :=
  Float32.mul (f32_of_Z 523776) area1_top_face_normal_inverse.

Definition area1_top_face_normal_z : float32 :=
  Float32.mul (f32_of_Z 522753) area1_top_face_normal_inverse.

Definition area1_top_face_origin_offset : float32 :=
  Float32.neg
    (f32_add3
      (Float32.mul area1_top_face_normal_x (f32_of_Z (-2558)))
      (Float32.mul area1_top_face_normal_y (f32_of_Z 1281))
      (Float32.mul area1_top_face_normal_z (f32_of_Z (-511)))).

Definition area1_top_face_height : float32 :=
  Float32.div
    (Float32.neg
      (f32_add3
        (Float32.mul (f32_of_Z (-2350)) area1_top_face_normal_x)
        (Float32.mul area1_top_face_normal_z (f32_of_Z (-714)))
        area1_top_face_origin_offset))
    area1_top_face_normal_y.

Definition area1_top_face_plane_claim : Prop :=
  Float32.to_bits area1_top_face_normal_magnitude =
    Int.repr 1228188290 /\
  Float32.to_bits area1_top_face_normal_inverse =
    Int.repr 901078930 /\
  Float32.to_bits area1_top_face_normal_x =
    Int.repr 0 /\
  Float32.to_bits area1_top_face_normal_y =
    Int.repr 1060450874 /\
  Float32.to_bits area1_top_face_normal_z =
    Int.repr 1060427681 /\
  Float32.to_bits area1_top_face_origin_offset =
    Int.repr 3288886650 /\
  Float32.to_bits area1_top_face_height =
    Int.repr 1153004368.

Theorem area1_top_face_plane_height_checked :
  area1_top_face_plane_claim.
Proof.
  unfold area1_top_face_plane_claim, area1_top_face_height,
    area1_top_face_origin_offset, area1_top_face_normal_x,
    area1_top_face_normal_y, area1_top_face_normal_z,
    area1_top_face_normal_inverse, area1_top_face_normal_magnitude,
    f32_reciprocal_via_double, f32_add3, f32_of_Z.
  vm_compute.
  repeat split; reflexivity.
Qed.

Definition floor_upward_buffer_accepts
    (query_y height : float32) : bool :=
  negb
    (Float32.cmp Clt
      (Float32.sub query_y
        (Float32.add height (f32_of_Z (-78))))
      (f32_of_Z 0)).

Theorem area1_top_face_upward_buffer_accepts :
  floor_upward_buffer_accepts
    (f32_of_Z 1878) area1_top_face_height = true.
Proof.
  unfold floor_upward_buffer_accepts, area1_top_face_height,
    area1_top_face_origin_offset, area1_top_face_normal_x,
    area1_top_face_normal_y, area1_top_face_normal_z,
    area1_top_face_normal_inverse, area1_top_face_normal_magnitude,
    f32_reciprocal_via_double, f32_add3, f32_of_Z.
  vm_compute.
  reflexivity.
Qed.

Theorem area1_surface_witness_partition_cell :
  Int.signed (partition_cell_index (Int.repr (-2350))) = 5 /\
  Int.signed (partition_cell_index (Int.repr (-714))) = 7.
Proof. vm_compute. split; reflexivity. Qed.

(** A separate static source face lies under the same query.  The three
    vertex extractions are checked directly against the complete generated
    US and JP Area-1 collision initializers.  The triangle words occur at
    initializer offsets 3798--3800, within the [SURFACE_HARD] (encoded tag
    48), 288-triangle group beginning at offsets 3628--3629.  This file does
    not execute the surface loader or prove that this face is first in the
    live static partition list. *)
Definition area1_static_face_vertices_source_claim : Prop :=
  nth_error
    (init_int16_values
      (gvar_init us_ssl_collision.v_ssl_seg7_area_1_collision))
    (2 + 3 * 266) = Some (-2149) /\
  nth_error
    (init_int16_values
      (gvar_init us_ssl_collision.v_ssl_seg7_area_1_collision))
    (2 + 3 * 266 + 1) = Some 1280 /\
  nth_error
    (init_int16_values
      (gvar_init us_ssl_collision.v_ssl_seg7_area_1_collision))
    (2 + 3 * 266 + 2) = Some (-921) /\
  nth_error
    (init_int16_values
      (gvar_init us_ssl_collision.v_ssl_seg7_area_1_collision))
    (2 + 3 * 265) = Some (-2559) /\
  nth_error
    (init_int16_values
      (gvar_init us_ssl_collision.v_ssl_seg7_area_1_collision))
    (2 + 3 * 265 + 1) = Some 1280 /\
  nth_error
    (init_int16_values
      (gvar_init us_ssl_collision.v_ssl_seg7_area_1_collision))
    (2 + 3 * 265 + 2) = Some (-511) /\
  nth_error
    (init_int16_values
      (gvar_init us_ssl_collision.v_ssl_seg7_area_1_collision))
    (2 + 3 * 373) = Some (-2176) /\
  nth_error
    (init_int16_values
      (gvar_init us_ssl_collision.v_ssl_seg7_area_1_collision))
    (2 + 3 * 373 + 1) = Some 1280 /\
  nth_error
    (init_int16_values
      (gvar_init us_ssl_collision.v_ssl_seg7_area_1_collision))
    (2 + 3 * 373 + 2) = Some (-511) /\
  nth_error
    (init_int16_values
      (gvar_init jp_ssl_collision.v_ssl_seg7_area_1_collision))
    (2 + 3 * 266) = Some (-2149) /\
  nth_error
    (init_int16_values
      (gvar_init jp_ssl_collision.v_ssl_seg7_area_1_collision))
    (2 + 3 * 265) = Some (-2559) /\
  nth_error
    (init_int16_values
      (gvar_init jp_ssl_collision.v_ssl_seg7_area_1_collision))
    (2 + 3 * 373) = Some (-2176).

Theorem area1_static_face_vertices_source_checked :
  area1_static_face_vertices_source_claim.
Proof.
  unfold area1_static_face_vertices_source_claim.
  vm_compute.
  repeat split; reflexivity.
Qed.

Definition area1_static_face_triangle_source_claim : Prop :=
  nth_error
    (init_int16_values
      (gvar_init us_ssl_collision.v_ssl_seg7_area_1_collision))
    3628 = Some 48 /\
  nth_error
    (init_int16_values
      (gvar_init us_ssl_collision.v_ssl_seg7_area_1_collision))
    3629 = Some 288 /\
  nth_error
    (init_int16_values
      (gvar_init us_ssl_collision.v_ssl_seg7_area_1_collision))
    3798 = Some 266 /\
  nth_error
    (init_int16_values
      (gvar_init us_ssl_collision.v_ssl_seg7_area_1_collision))
    3799 = Some 265 /\
  nth_error
    (init_int16_values
      (gvar_init us_ssl_collision.v_ssl_seg7_area_1_collision))
    3800 = Some 373 /\
  nth_error
    (init_int16_values
      (gvar_init jp_ssl_collision.v_ssl_seg7_area_1_collision))
    3628 = Some 48 /\
  nth_error
    (init_int16_values
      (gvar_init jp_ssl_collision.v_ssl_seg7_area_1_collision))
    3629 = Some 288 /\
  nth_error
    (init_int16_values
      (gvar_init jp_ssl_collision.v_ssl_seg7_area_1_collision))
    3798 = Some 266 /\
  nth_error
    (init_int16_values
      (gvar_init jp_ssl_collision.v_ssl_seg7_area_1_collision))
    3799 = Some 265 /\
  nth_error
    (init_int16_values
      (gvar_init jp_ssl_collision.v_ssl_seg7_area_1_collision))
    3800 = Some 373.

Theorem area1_static_face_triangle_source_checked :
  area1_static_face_triangle_source_claim.
Proof.
  unfold area1_static_face_triangle_source_claim.
  vm_compute.
  repeat split; reflexivity.
Qed.

Definition area1_static_face_vertex266_xz : VertexXZ := {|
  vertex_x := Int.repr (-2149);
  vertex_z := Int.repr (-921)
|}.

Definition area1_static_face_vertex265_xz : VertexXZ := {|
  vertex_x := Int.repr (-2559);
  vertex_z := Int.repr (-511)
|}.

Definition area1_static_face_vertex373_xz : VertexXZ := {|
  vertex_x := Int.repr (-2176);
  vertex_z := Int.repr (-511)
|}.

Definition area1_static_face_edge_claim : Prop :=
  Int.signed
    (floor_edge_value area1_surface_query_xz
      area1_static_face_vertex266_xz area1_static_face_vertex265_xz) =
      2460 /\
  Int.signed
    (floor_edge_value area1_surface_query_xz
      area1_static_face_vertex265_xz area1_static_face_vertex373_xz) =
      77749 /\
  Int.signed
    (floor_edge_value area1_surface_query_xz
      area1_static_face_vertex373_xz area1_static_face_vertex266_xz) =
      76821.

Theorem area1_static_face_edge_tests :
  area1_static_face_edge_claim.
Proof.
  unfold area1_static_face_edge_claim, floor_edge_value,
    area1_surface_query_xz, area1_static_face_vertex266_xz,
    area1_static_face_vertex265_xz, area1_static_face_vertex373_xz.
  vm_compute.
  repeat split; reflexivity.
Qed.

Definition area1_static_face_height : float32 := f32_of_Z 1280.

Theorem area1_static_face_buffer_and_dynamic_height_comparison :
  Float32.to_bits area1_static_face_height =
    Int.repr 1151336448 /\
  floor_upward_buffer_accepts
    (f32_of_Z 1878) area1_static_face_height = true /\
  Float32.cmp Clt
    area1_static_face_height area1_top_face_height = true.
Proof.
  unfold area1_static_face_height, floor_upward_buffer_accepts,
    area1_top_face_height, area1_top_face_origin_offset,
    area1_top_face_normal_x, area1_top_face_normal_y,
    area1_top_face_normal_z, area1_top_face_normal_inverse,
    area1_top_face_normal_magnitude, f32_reciprocal_via_double,
    f32_add3, f32_of_Z.
  vm_compute.
  repeat split; reflexivity.
Qed.

(** The strongest theorem intentionally conjoins only the checked
    value/source facts.  It has no premise or conclusion asserting a live
    surface or reachable execution. *)
Definition area1_surface_capability_claim : Prop :=
  area1_surface_witness_output_bits /\
  area1_surface_witness_short_cast_claim /\
  area1_top_face_source_claim /\
  area1_top_face_edge_claim /\
  area1_top_face_raw_normal_claim /\
  area1_top_face_plane_claim /\
  floor_upward_buffer_accepts
    (f32_of_Z 1878) area1_top_face_height = true /\
  area1_static_face_vertices_source_claim /\
  area1_static_face_triangle_source_claim /\
  area1_static_face_edge_claim /\
  Float32.cmp Clt
    area1_static_face_height area1_top_face_height = true.

Theorem area1_surface_capability_checked :
  area1_surface_capability_claim.
Proof.
  unfold area1_surface_capability_claim.
  split; [exact area1_surface_witness_output_bits_checked |].
  split; [exact area1_surface_witness_short_casts |].
  split; [exact area1_top_face_source_checked |].
  split; [exact area1_top_face_edge_tests |].
  split; [exact area1_top_face_raw_normal_checked |].
  split; [exact area1_top_face_plane_height_checked |].
  split; [exact area1_top_face_upward_buffer_accepts |].
  split; [exact area1_static_face_vertices_source_checked |].
  split; [exact area1_static_face_triangle_source_checked |].
  split; [exact area1_static_face_edge_tests |].
  exact
    (proj2
      (proj2
        area1_static_face_buffer_and_dynamic_height_comparison)).
Qed.
