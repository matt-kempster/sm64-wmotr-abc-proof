(** Bounded source geometry for the update preceding the timer-131 Ink
    installation. No emulator state or controller search is used here.

    Reuses the existing source-shaped spin recurrence and binary32 matrix,
    narrowing and plane evaluators. The sine samples are checked against
    BOTH generated math-table initializers. These certificates do not execute
    the live loader/list traversal, prove a fresh throwMatrix, place a shell,
    or construct a high crawling Mario. *)
From Coq Require Import Bool List ZArith.
From compcert Require Import AST Cop Ctypes Floats Integers Memory Values.
From LessThanOneAPress.Generated Require Import us_math_util jp_math_util
  us_ssl_collision jp_ssl_collision.
From LessThanOneAPress.Proofs Require Import ASTFacts Area1FirstNull CollisionMeshFacts
  PyramidTopSurface Timer131Surface InkVerticalRetryGeometry InkNearbyFloorGeometry.
Import ListNotations.
Local Open Scope Z_scope.

Definition i130_initializer_float_bits (word : init_data) : option Z :=
  match word with
  | Init_float32 f => Some (Int.unsigned (Float32.to_bits f))
  | _ => None end.

Definition i130_table_samples (words : list init_data) :=
  map (fun n => match nth_error words n with
    | Some word => i130_initializer_float_bits word | None => None end)
    [1536%nat;2048%nat;2368%nat;3392%nat].

(** 59*0x2000 -> index1536; 130*0x4000 -> index2048;
    matrix yaw0x9400 -> index2368, cosine uses index2368+1024. *)
Theorem i130_generated_trig_samples_checked :
  i130_table_samples (gvar_init us_math_util.v_gSineTable) =
    [Some 1060439283; Some 0; Some 3203488490; Some 3210855832] /\
  i130_table_samples (gvar_init jp_math_util.v_gSineTable) =
    [Some 1060439283; Some 0; Some 3203488490; Some 3210855832].
Proof. vm_compute. split; reflexivity. Qed.

Definition i130_after_behavior := timer131_iterate_spin 71 timer131_before_timer60.
Definition i130_sine_x := Float32.of_bits (Int.repr 0).
Definition i130_sine_yaw := Float32.of_bits (Int.repr 3203488490).
Definition i130_cosine_yaw := Float32.of_bits (Int.repr 3210855832).
Definition i130_center_x := Float32.add (f32_of_Z (-2047))
  (Float32.mul i130_sine_x (f32_of_Z 40)).

Definition InkTimer130Pose : Prop :=
  (130 * 16384) mod 65536 = 32768 /\ 32768 / 16 = 2048 /\
  timer131_angle_velocity_yaw i130_after_behavior = 6144 /\
  timer131_raw_face_yaw i130_after_behavior = 365568 /\
  365568 mod 65536 = 37888 /\ 37888 / 16 = 2368 /\
  Float32.to_bits (timer131_center_y i130_after_behavior) = Int.repr 1155416646 /\
  Float32.to_bits i130_center_x = Int.repr 3305103360.

Theorem i130_pose_checked : InkTimer130Pose.
Proof. vm_compute. repeat split; reflexivity. Qed.

Definition i130_world_x (v : Area1SourceVertex) :=
  let '(x,y,z) := v in matrix_component_f32
    (f32_of_Z x) (f32_of_Z y) (f32_of_Z z)
    i130_cosine_yaw (f32_of_Z 0) i130_sine_yaw i130_center_x.
Definition i130_world_y (v : Area1SourceVertex) :=
  let '(x,y,z) := v in matrix_component_f32
    (f32_of_Z x) (f32_of_Z y) (f32_of_Z z)
    (f32_of_Z 0) (f32_of_Z 1) (Float32.neg (f32_of_Z 0))
    (timer131_center_y i130_after_behavior).
Definition i130_world_z (v : Area1SourceVertex) :=
  let '(x,y,z) := v in matrix_component_f32
    (f32_of_Z x) (f32_of_Z y) (f32_of_Z z)
    (Float32.neg i130_sine_yaw) (f32_of_Z 0) i130_cosine_yaw timer131_center_z.

Definition i130_cast_vertex (m : Mem.mem) (v : Area1SourceVertex) :=
  match cast_transformed_component (i130_world_x v) m,
        cast_transformed_component (i130_world_y v) m,
        cast_transformed_component (i130_world_z v) m with
  | Some (Vint x), Some (Vint y), Some (Vint z) =>
      Some (Int.signed x, Int.signed y, Int.signed z)
  | _,_,_ => None end.

Definition i130_vertices : list Area1SourceVertex :=
  [(-1837,1523,-1715);(-2257,1523,-330);(-2739,1523,-1233);
   (-2047,2034,-1023);(-1355,1523,-813)].

Theorem i130_fresh_transform_checked : forall m,
  map (i130_cast_vertex m) pyramid_top_vertices =
  map (@Some Area1SourceVertex) i130_vertices.
Proof. intro m. vm_compute. reflexivity. Qed.

Definition i130_top_floors := filter (fun face =>
  match area1_source_triangle_vertices i130_vertices face with
  | Some vs => infg_is_floor vs | None => false end) pyramid_top_triangles.
Definition i130_top_ceilings := filter (fun face =>
  match area1_source_triangle_vertices i130_vertices face with
  | Some vs => match area1_source_surface_kind vs with
    | Area1SourceCeiling => true | _ => false end
  | None => false end) pyramid_top_triangles.
Definition i130_floor_hits x y z :=
  filter (ivr_accepts i130_vertices (infg_query x y z)) i130_top_floors.

Definition i130_sample_x : list Z := [-1950;-1882;-1881].

Theorem i130_high_floor_queries_checked :
  i130_top_floors = [(0,2,3);(2,1,3);(1,4,3);(4,0,3)] /\
  i130_top_ceilings = [(0,1,2);(0,4,1)] /\
  map (fun x => i130_floor_hits x 1741 (-939)) i130_sample_x = [ []; []; [] ] /\
  infg_static_hits (-1950) 1741 (-939) = [(498,500,501)] /\
  infg_static_hits (-1882) 1741 (-939) = [(261,263,264)] /\
  infg_static_hits (-1881) 1741 (-939) = [(261,263,264)].
Proof. vm_compute. repeat split; reflexivity. Qed.

(** Each sample lies inside face(1,4,3), but its height rejects the floor
    query. These numbers are computed from the stored signed-16 vertices,
    not from the object origin or an ideal unrounded mesh. *)
Theorem i130_rejected_top_heights_checked :
  map (fun x => option_map (fun h => Int.unsigned (Float32.to_bits h))
    (area1_loaded_floor_height i130_vertices (1,4,3) x (-939)))
    i130_sample_x = [Some 1156532998;Some 1156270444;Some 1156266583] /\
  map (fun x => ivr_xz_accepts i130_vertices (infg_query x 1741 (-939)) (1,4,3))
    i130_sample_x = [true;true;true].
Proof. vm_compute. split; reflexivity. Qed.

Definition i130_ceil_edges x z face :=
  match area1_source_triangle_vertices i130_vertices face with
  | Some (a,b,c) =>
    [area1_floor_edge_i32 x z a b; area1_floor_edge_i32 x z b c;
     area1_floor_edge_i32 x z c a]
  | None => [] end.
Definition i130_ceil_xz x z face :=
  forallb (fun edge => negb (Int.lt Int.zero edge)) (i130_ceil_edges x z face).

(** The ceiling source rejects positive edges (the opposite floor winding)
    and rejects queryY-(height+78)>0. vec3f_find_ceil uses floorHeight+80,
    NOT movementY+80. This certificate evaluates those expressions; it is
    deliberately not a live find_ceil execution theorem. *)
Theorem i130_underside_query_checked :
  map (fun x => filter (i130_ceil_xz x (-939)) i130_top_ceilings)
    i130_sample_x = [[(0,4,1)];[(0,4,1)];[(0,4,1)]] /\
  map (fun x => map Int.signed (i130_ceil_edges x (-939) (0,4,1)))
    i130_sample_x = [[-475958;-401037;-169415];
                     [-414622;-368193;-263595];[-413720;-367710;-264980]] /\
  area1_loaded_plane_bits i130_vertices (0,4,1) =
    Some (0,3212836864,0,1153327104) /\
  map (fun x => option_map (fun h => Int.unsigned (Float32.to_bits h))
    (area1_loaded_floor_height i130_vertices (0,4,1) x (-939)))
    i130_sample_x = [Some 1153327104;Some 1153327104;Some 1153327104] /\
  Float32.to_bits (Float32.add (f32_of_Z 1280) (f32_of_Z 80)) =
    Float32.to_bits (f32_of_Z 1360) /\
  Float32.cmp Cgt
    (Float32.sub (f32_of_Z 1360)
      (Float32.sub (f32_of_Z 1523) (f32_of_Z (-78)))) (f32_of_Z 0) = false /\
  Float32.cmp Cgt (f32_of_Z 1741) (Float32.add (f32_of_Z 1280) (f32_of_Z 100)) = true /\
  Float32.cmp Cge (Float32.add (f32_of_Z 1741) (f32_of_Z 160)) (f32_of_Z 1523) = true.
Proof. vm_compute. repeat split; reflexivity. Qed.

(** At the earlier geometry preparation, the low pad floor supplies 768;
    the ceiling query is therefore 848. The selected top underside has
    755 units of floor/ceiling clearance. At the next timer-131 geometry,
    the target misses at low Y=768 but accepts the existing high retry.
    This does not prove the subsequent warp or slot lifetime. *)
Definition InkTimer130HandoffGeometry : Prop :=
  infg_static_hits (-1882) 768 (-939) = [] /\
  infg_timer131_hits (-1882) 768 (-939) = [] /\
  infg_timer131_hits (-1882) 1741 (-939) = [timer131_retry_face] /\
  Float32.to_bits (Float32.add (f32_of_Z 768) (f32_of_Z 80)) =
    Float32.to_bits (f32_of_Z 848) /\
  Float32.cmp Cgt
    (Float32.sub (f32_of_Z 848)
      (Float32.sub (f32_of_Z 1523) (f32_of_Z (-78)))) (f32_of_Z 0) = false /\
  Float32.cmp Cle (Float32.sub (f32_of_Z 1523) (f32_of_Z 768))
    (f32_of_Z 150) = false /\
  nth_error pyramid_top_collision_words 17 = Some 53 /\
  53 <> 114 /\ ~ In 53 [118;119;120;122].

Theorem i130_handoff_geometry_checked : InkTimer130HandoffGeometry.
Proof. vm_compute. repeat split; try reflexivity; intuition congruence. Qed.

Definition InkTimer130MeshSource : Prop :=
  init_int16_values (gvar_init us_ssl_collision.v_ssl_seg7_collision_pyramid_top) =
    pyramid_top_collision_words /\
  init_int16_values (gvar_init jp_ssl_collision.v_ssl_seg7_collision_pyramid_top) =
    pyramid_top_collision_words /\ pyramid_top_source_mesh_claim.

Theorem i130_mesh_source_checked : InkTimer130MeshSource.
Proof.
  split; [exact pyramid_top_collision_words_exact_us|].
  split; [exact pyramid_top_collision_words_exact_jp|].
  exact pyramid_top_source_mesh_checked.
Qed.

Definition InkTimer130GeometryBoundary : Prop :=
  InkTimer130Pose /\
  (i130_table_samples (gvar_init us_math_util.v_gSineTable) =
    [Some 1060439283;Some 0;Some 3203488490;Some 3210855832] /\
   i130_table_samples (gvar_init jp_math_util.v_gSineTable) =
    [Some 1060439283;Some 0;Some 3203488490;Some 3210855832]) /\
  (forall m, map (i130_cast_vertex m) pyramid_top_vertices =
    map (@Some Area1SourceVertex) i130_vertices) /\
  (i130_top_floors = [(0,2,3);(2,1,3);(1,4,3);(4,0,3)] /\
   i130_top_ceilings = [(0,1,2);(0,4,1)] /\
   map (fun x => i130_floor_hits x 1741 (-939)) i130_sample_x = [ []; []; [] ] /\
   infg_static_hits (-1950) 1741 (-939) = [(498,500,501)] /\
   infg_static_hits (-1882) 1741 (-939) = [(261,263,264)] /\
   infg_static_hits (-1881) 1741 (-939) = [(261,263,264)]) /\
  (map (fun x => filter (i130_ceil_xz x (-939)) i130_top_ceilings)
    i130_sample_x = [[(0,4,1)];[(0,4,1)];[(0,4,1)]] /\
   map (fun x => map Int.signed (i130_ceil_edges x (-939) (0,4,1)))
    i130_sample_x = [[-475958;-401037;-169415];
                     [-414622;-368193;-263595];[-413720;-367710;-264980]] /\
   area1_loaded_plane_bits i130_vertices (0,4,1) =
    Some (0,3212836864,0,1153327104) /\
   map (fun x => option_map (fun h => Int.unsigned (Float32.to_bits h))
    (area1_loaded_floor_height i130_vertices (0,4,1) x (-939)))
    i130_sample_x = [Some 1153327104;Some 1153327104;Some 1153327104] /\
   Float32.to_bits (Float32.add (f32_of_Z 1280) (f32_of_Z 80)) =
     Float32.to_bits (f32_of_Z 1360) /\
   Float32.cmp Cgt (Float32.sub (f32_of_Z 1360)
     (Float32.sub (f32_of_Z 1523) (f32_of_Z (-78)))) (f32_of_Z 0) = false /\
   Float32.cmp Cgt (f32_of_Z 1741) (Float32.add (f32_of_Z 1280) (f32_of_Z 100)) = true /\
   Float32.cmp Cge (Float32.add (f32_of_Z 1741) (f32_of_Z 160)) (f32_of_Z 1523) = true) /\
  InkTimer130HandoffGeometry /\
  (map (fun x => option_map (fun h => Int.unsigned (Float32.to_bits h))
    (area1_loaded_floor_height i130_vertices (1,4,3) x (-939)))
    i130_sample_x = [Some 1156532998;Some 1156270444;Some 1156266583] /\
   map (fun x => ivr_xz_accepts i130_vertices (infg_query x 1741 (-939)) (1,4,3))
    i130_sample_x = [true;true;true]) /\
  InkTimer130MeshSource /\ timer131_surface_source_shape_claim.

Theorem i130_geometry_checked : InkTimer130GeometryBoundary.
Proof.
  split; [exact i130_pose_checked|].
  split; [exact i130_generated_trig_samples_checked|].
  split; [exact i130_fresh_transform_checked|].
  split; [exact i130_high_floor_queries_checked|].
  split; [exact i130_underside_query_checked|].
  split; [exact i130_handoff_geometry_checked|].
  split; [exact i130_rejected_top_heights_checked|].
  split; [exact i130_mesh_source_checked|].
  exact timer131_surface_source_shape_checked.
Qed.
