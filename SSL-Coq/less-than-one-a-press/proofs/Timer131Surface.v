(** Exact timer-131 pyramid-top arithmetic and a corrected Graphics retry.

    This file addresses the value-level part of the timed Ink/top candidate.
    The object behavior executes timer 131 before [cur_obj_update] performs its
    trailing timer increment.  Thus the collision loader observes the pose
    after the updates for timers 60 through 131 inclusive: 72 spinning
    updates.  With the pinned sine table this is

      center = (-2087.0f, 1783.071044921875f, -1023.0f)
      raw face yaw = 0x5AC00, matrix s16 yaw = 0xAC00.

    The old home-pose retry [(-2048,1791,-1024)] is not valid at this pose:
    its containing face is about 2005.129 high, so the 78-unit upward buffer
    rejects Y=1791.  A robust interior replacement is

      Graphics query = (-1641,1456,-783)
      selected-face height = 1533.34375f.

    Its three signed edge values are strictly positive and its floor-buffer
    difference is +0.65625f.  The State diagnostic at
    [(-2200,768,-1024)] lies inside a different timer-131 face, but that face
    is about 1938.865 high and is rejected by the same buffer.

    That low side-face point loses support before the delayed warp.  A second
    strict-interior point [(-1862,1778,-902)] returns height bits [0x44defe16]
    and, in a separate conditional authentic-JP trace, remains top-owned
    through explosion and the first Area-2 displacement.  Its required
    Graphics-minus-warp-Object gap is at least 960 (1010 at warp centre).
    The observation is recorded here but does not prove a retail installer.

    These are admission-free, generated-data and binary32 facts.  They do not
    claim a live Clight execution.  A complete refinement must still prove
    that the renderer cleared [throwMatrix] before this update (or that the
    stored matrix already equals the fresh pose), that the dynamic surface
    lists were built from these vertices with this object as owner, that no
    earlier dynamic node wins, and that a clean run reaches the three-view
    State/Object/Graphics sample. *)

From Coq Require Import Lia List ZArith.
From compcert Require Import AST Clight Cop Floats Integers Memory Values.
From LessThanOneAPress.Proofs Require Import
  Area1FirstNull Area1SurfaceWitness ASTFacts ClightFacts CollisionMeshFacts
  InkFallback PyramidTopPU PyramidTopSurface.
From LessThanOneAPress.Generated Require Import
  us_behavior_data jp_behavior_data
  us_object_list_processor jp_object_list_processor
  us_rendering_graph_node jp_rendering_graph_node
  us_surface_load jp_surface_load.

Import ListNotations.
Local Open Scope Z_scope.

Module T131UBD := us_behavior_data.
Module T131JBD := jp_behavior_data.
Module T131UOL := us_object_list_processor.
Module T131JOL := jp_object_list_processor.
Module T131URender := us_rendering_graph_node.
Module T131JRender := jp_rendering_graph_node.
Module T131USL := us_surface_load.
Module T131JSL := jp_surface_load.

(** * Executed-timer convention and exact pose *)

Definition timer131_sine_timer59 : float32 :=
  Float32.of_bits (Int.repr 1060439283). (* +0.707106769f *)

Definition timer131_sine_x : float32 :=
  Float32.of_bits (Int.repr 3212836864). (* -1.0f *)

Definition timer131_sine_yaw : float32 :=
  Float32.of_bits (Int.repr 3210855832). (* sin(0xAC00) *)

Definition timer131_cosine_yaw : float32 :=
  Float32.of_bits (Int.repr 3203488490). (* cos(0xAC00) *)

Definition timer131_timer59_center_y : float32 :=
  Float32.add (f32_of_Z 1536)
    (Float32.mul timer131_sine_timer59 (f32_of_Z 10)).

Record Timer131SpinState : Type := {
  timer131_angle_velocity_yaw : Z;
  timer131_raw_face_yaw : Z;
  timer131_velocity_y : float32;
  timer131_center_y : float32
}.

Definition timer131_spin_step
    (state : Timer131SpinState) : Timer131SpinState :=
  let proposed := timer131_angle_velocity_yaw state + 256 in
  let exceeded := 6144 <? proposed in
  let next_angle_velocity := if exceeded then 6144 else proposed in
  let next_velocity_y :=
    if exceeded then f32_of_Z 5 else timer131_velocity_y state in
  {| timer131_angle_velocity_yaw := next_angle_velocity;
     timer131_raw_face_yaw :=
       timer131_raw_face_yaw state + next_angle_velocity;
     timer131_velocity_y := next_velocity_y;
     timer131_center_y :=
       Float32.add (timer131_center_y state) next_velocity_y |}.

Fixpoint timer131_iterate_spin
    (updates : nat) (state : Timer131SpinState) : Timer131SpinState :=
  match updates with
  | O => state
  | S remaining =>
      timer131_iterate_spin remaining (timer131_spin_step state)
  end.

Definition timer131_before_timer60 : Timer131SpinState :=
  {| timer131_angle_velocity_yaw := 0;
     timer131_raw_face_yaw := 0;
     timer131_velocity_y := f32_of_Z 0;
     timer131_center_y := timer131_timer59_center_y |}.

(** Timer values 60 through 131 are both inclusive. *)
Definition timer131_after_behavior : Timer131SpinState :=
  timer131_iterate_spin 72 timer131_before_timer60.

Definition timer131_center_x : float32 :=
  Float32.add (f32_of_Z (-2047))
    (Float32.mul timer131_sine_x (f32_of_Z 40)).

Definition timer131_center_z : float32 := f32_of_Z (-1023).

Definition timer131_pose_claim : Prop :=
  (131 * 16384) mod 65536 = 49152 /\
  49152 / 16 = 3072 /\
  (59 * 8192) mod 65536 = 24576 /\
  24576 / 16 = 1536 /\
  timer131_angle_velocity_yaw timer131_after_behavior = 6144 /\
  timer131_raw_face_yaw timer131_after_behavior = 371712 /\
  371712 mod 65536 = 44032 /\
  44032 / 16 = 2752 /\
  Float32.to_bits timer131_timer59_center_y = Int.repr 1153491526 /\
  Float32.to_bits (timer131_velocity_y timer131_after_behavior) =
    Int.repr 1084227584 /\
  Float32.to_bits (timer131_center_y timer131_after_behavior) =
    Int.repr 1155457606 /\
  Float32.to_bits timer131_center_x = Int.repr 3305271296 /\
  Float32.to_bits timer131_center_z = Int.repr 3296706560.

Theorem timer131_pose_checked : timer131_pose_claim.
Proof.
  unfold timer131_pose_claim, timer131_after_behavior,
    timer131_before_timer60, timer131_timer59_center_y,
    timer131_center_x, timer131_center_z, timer131_sine_timer59,
    timer131_sine_x, f32_of_Z.
  vm_compute.
  repeat split; reflexivity.
Qed.

(** * Fresh yaw-only transform and TerrainData narrowing *)

Definition timer131_world_x (vertex : Z * Z * Z) : float32 :=
  let '(x, y, z) := vertex in
  matrix_component_f32
    (f32_of_Z x) (f32_of_Z y) (f32_of_Z z)
    timer131_cosine_yaw (f32_of_Z 0) timer131_sine_yaw
    timer131_center_x.

Definition timer131_world_y (vertex : Z * Z * Z) : float32 :=
  let '(x, y, z) := vertex in
  matrix_component_f32
    (f32_of_Z x) (f32_of_Z y) (f32_of_Z z)
    (f32_of_Z 0) (f32_of_Z 1) (Float32.neg (f32_of_Z 0))
    (timer131_center_y timer131_after_behavior).

Definition timer131_world_z (vertex : Z * Z * Z) : float32 :=
  let '(x, y, z) := vertex in
  matrix_component_f32
    (f32_of_Z x) (f32_of_Z y) (f32_of_Z z)
    (Float32.neg timer131_sine_yaw) (f32_of_Z 0)
    timer131_cosine_yaw timer131_center_z.

Definition timer131_cast_vertex
    (memory : Mem.mem) (vertex : Z * Z * Z)
    : option (Z * Z * Z) :=
  match cast_transformed_component (timer131_world_x vertex) memory,
        cast_transformed_component (timer131_world_y vertex) memory,
        cast_transformed_component (timer131_world_z vertex) memory with
  | Some (Vint x), Some (Vint y), Some (Vint z) =>
      Some (Int.signed x, Int.signed y, Int.signed z)
  | _, _, _ => None
  end.

Definition timer131_vertices_s16 : list Area1SourceVertex :=
  [(-2297, 1528, -1715);
   (-1877, 1528, -330);
   (-2779, 1528, -812);
   (-2087, 2039, -1023);
   (-1395, 1528, -1232)].

Definition timer131_vertex_float_bits
    (vertex : Z * Z * Z) : Z * Z * Z :=
  (Int.unsigned (Float32.to_bits (timer131_world_x vertex)),
   Int.unsigned (Float32.to_bits (timer131_world_y vertex)),
   Int.unsigned (Float32.to_bits (timer131_world_z vertex))).

Theorem timer131_fresh_transform_float_bits_checked :
  map timer131_vertex_float_bits pyramid_top_vertices =
    [(3306134159, 1153368646, 3302383754);
     (3303716400, 1153368646, 3282389322);
     (3308109410, 1153368646, 3293262830);
     (3305271296, 1157554758, 3296706560);
     (3299765899, 1153368646, 3298433254)].
Proof.
  unfold timer131_vertex_float_bits, timer131_world_x, timer131_world_y,
    timer131_world_z, pyramid_top_vertices, matrix_component_f32,
    timer131_after_behavior, timer131_before_timer60,
    timer131_timer59_center_y, timer131_center_x, timer131_center_z,
    timer131_sine_timer59, timer131_sine_x, timer131_sine_yaw,
    timer131_cosine_yaw, f32_of_Z.
  vm_compute.
  reflexivity.
Qed.

Theorem timer131_fresh_transform_s16_checked :
  forall memory,
    map (timer131_cast_vertex memory) pyramid_top_vertices =
      map (@Some Area1SourceVertex) timer131_vertices_s16.
Proof.
  intros memory.
  unfold timer131_cast_vertex, timer131_vertices_s16,
    timer131_world_x, timer131_world_y, timer131_world_z,
    pyramid_top_vertices, matrix_component_f32,
    timer131_after_behavior, timer131_before_timer60,
    timer131_timer59_center_y, timer131_center_x, timer131_center_z,
    timer131_sine_timer59, timer131_sine_x, timer131_sine_yaw,
    timer131_cosine_yaw, cast_transformed_component, f32_of_Z.
  vm_compute.
  reflexivity.
Qed.

Definition timer131_state_face : Area1TriangleIndex := (0, 2, 3).
Definition timer131_retry_face : Area1TriangleIndex := (1, 4, 3).

Definition timer131_state_query : Area1IntegerQuery :=
  {| area1_query_x := -2200;
     area1_query_y := 768;
     area1_query_z := -1024 |}.

(** Strictly interior: the smallest signed edge value is 5474, not zero. *)
Definition timer131_retry_query : Area1IntegerQuery :=
  {| area1_query_x := -1641;
     area1_query_y := 1456;
     area1_query_z := -783 |}.

(** A second strict-interior sample, found by the authentic JP lifetime
    probe.  Unlike [timer131_retry_query], its post-snap point remains on the
    rotating top through the explosion in that conditional execution. *)
Definition timer131_midface_retry_query : Area1IntegerQuery :=
  {| area1_query_x := -1862;
     area1_query_y := 1778;
     area1_query_z := -902 |}.

Definition timer131_old_home_query : Area1IntegerQuery :=
  {| area1_query_x := -2048;
     area1_query_y := 1791;
     area1_query_z := -1024 |}.

Definition timer131_face_edge_values
    (query : Area1IntegerQuery) (face : Area1TriangleIndex) : list Z :=
  match area1_source_triangle_vertices timer131_vertices_s16 face with
  | Some (first, second, third) =>
      [Int.signed
         (area1_floor_edge_i32
           (area1_query_x query) (area1_query_z query) first second);
       Int.signed
         (area1_floor_edge_i32
           (area1_query_x query) (area1_query_z query) second third);
       Int.signed
         (area1_floor_edge_i32
           (area1_query_x query) (area1_query_z query) third first)]
  | None => []
  end.

Theorem timer131_mesh_face_link_checked :
  pyramid_top_source_mesh_claim /\
  nth_error pyramid_top_triangles 1 = Some timer131_state_face /\
  nth_error pyramid_top_triangles 4 = Some timer131_retry_face.
Proof.
  split; [exact pyramid_top_source_mesh_checked |].
  unfold pyramid_top_triangles, timer131_state_face, timer131_retry_face.
  vm_compute.
  split; reflexivity.
Qed.

Theorem timer131_state_and_retry_edges_checked :
  timer131_face_edge_values timer131_state_query timer131_state_face =
    [420653; 24535; 77986] /\
  timer131_face_edge_values timer131_retry_query timer131_retry_face =
    [5474; 259294; 258678] /\
  timer131_face_edge_values timer131_midface_retry_query timer131_retry_face =
    [262174; 130757; 130515] /\
  timer131_face_edge_values timer131_old_home_query timer131_retry_face =
    [488750; 7459; 27237].
Proof.
  unfold timer131_face_edge_values, timer131_state_query,
    timer131_retry_query, timer131_midface_retry_query,
    timer131_old_home_query, timer131_state_face, timer131_retry_face,
    timer131_vertices_s16,
    area1_source_triangle_vertices, area1_floor_edge_i32.
  vm_compute.
  repeat split; reflexivity.
Qed.

(** * Exact face planes and the corrected buffer result *)

Definition timer131_buffer_observation
    (query : Area1IntegerQuery) (face : Area1TriangleIndex)
    : option (Z * Z * bool) :=
  match area1_loaded_floor_height timer131_vertices_s16 face
          (area1_query_x query) (area1_query_z query),
        area1_loaded_floor_buffer_difference
          timer131_vertices_s16 face query with
  | Some height, Some difference =>
      Some
        (Int.unsigned (Float32.to_bits height),
         Int.unsigned (Float32.to_bits difference),
         Float32.cmp Clt difference (f32_of_Z 0))
  | _, _ => None
  end.

Theorem timer131_face_plane_bits_checked :
  area1_loaded_plane_bits timer131_vertices_s16 timer131_state_face =
    Some (3206524120, 1060440647, 3198842415, 3309356130) /\
  area1_loaded_plane_bits timer131_vertices_s16 timer131_retry_face =
    Some (1059030667, 1060448841, 1051360672, 1128674320).
Proof.
  unfold area1_loaded_plane_bits, area1_loaded_plane_for_triangle,
    area1_compute_loaded_plane, area1_source_normal_components,
    area1_source_triangle_vertices, timer131_vertices_s16,
    timer131_state_face, timer131_retry_face,
    area1_f32_reciprocal_via_double, area1_f32_of_Z.
  vm_compute.
  split; reflexivity.
Qed.

Theorem timer131_state_face_is_too_high :
  timer131_buffer_observation timer131_state_query timer131_state_face =
    Some (1156733869, 3297287085, true).
Proof.
  unfold timer131_buffer_observation, area1_loaded_floor_height,
    area1_loaded_floor_buffer_difference, area1_loaded_plane_for_triangle,
    area1_compute_loaded_plane, area1_source_normal_components,
    area1_source_triangle_vertices, timer131_vertices_s16,
    timer131_state_query, timer131_state_face,
    area1_f32_reciprocal_via_double, area1_f32_of_Z, f32_of_Z.
  vm_compute.
  reflexivity.
Qed.

Theorem timer131_old_home_sample_is_rejected :
  timer131_buffer_observation timer131_old_home_query timer131_retry_face =
    Some (1157276704, 3272089856, true).
Proof.
  unfold timer131_buffer_observation, area1_loaded_floor_height,
    area1_loaded_floor_buffer_difference, area1_loaded_plane_for_triangle,
    area1_compute_loaded_plane, area1_source_normal_components,
    area1_source_triangle_vertices, timer131_vertices_s16,
    timer131_old_home_query, timer131_retry_face,
    area1_f32_reciprocal_via_double, area1_f32_of_Z, f32_of_Z.
  vm_compute.
  reflexivity.
Qed.

Theorem timer131_robust_interior_retry_is_accepted :
  timer131_buffer_observation timer131_retry_query timer131_retry_face =
    Some (1153411840, 1059586048, false) /\
  Int.signed (partition_cell_index (Int.repr (-1641))) = 6 /\
  Int.signed (partition_cell_index (Int.repr (-783))) = 7.
Proof.
  unfold timer131_buffer_observation, area1_loaded_floor_height,
    area1_loaded_floor_buffer_difference, area1_loaded_plane_for_triangle,
    area1_compute_loaded_plane, area1_source_normal_components,
    area1_source_triangle_vertices, timer131_vertices_s16,
    timer131_retry_query, timer131_retry_face,
    area1_f32_reciprocal_via_double, area1_f32_of_Z, f32_of_Z,
    partition_cell_index.
  vm_compute.
  repeat split; reflexivity.
Qed.

Theorem timer131_midface_retry_is_accepted :
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
Proof.
  unfold timer131_buffer_observation, timer131_face_edge_values,
    area1_loaded_floor_height, area1_loaded_floor_buffer_difference,
    area1_loaded_plane_bits, area1_loaded_plane_for_triangle,
    area1_compute_loaded_plane, area1_source_normal_components,
    area1_source_triangle_vertices, area1_floor_edge_i32,
    timer131_vertices_s16, timer131_midface_retry_query,
    timer131_retry_face, area1_f32_reciprocal_via_double,
    area1_f32_of_Z, f32_of_Z, partition_cell_index.
  vm_compute.
  repeat split; reflexivity.
Qed.

(** * Corrected vertical installer bound *)

(** All five stored timer-131 vertices are at or above Y=1528.  The exact
    accepted witness above returns 1533.34375f; 1528 is the conservative
    integer lower boundary used for the reusable arithmetic theorem. *)
Definition timer131_top_floor_min_y : Z := 1528.
Definition timer131_min_retry_query_y : Z := 1450.

Theorem timer131_stored_vertices_respect_floor_minimum :
  forall x y z,
    In (x, y, z) timer131_vertices_s16 ->
    timer131_top_floor_min_y <= y.
Proof.
  intros x y z Hin.
  unfold timer131_vertices_s16 in Hin; cbn in Hin.
  destruct Hin as [Hin | [Hin | [Hin | [Hin | [Hin | Hin]]]]].
  all: try contradiction.
  all: inversion Hin; subst; unfold timer131_top_floor_min_y; lia.
Qed.

(** A signed-range query accepted for a timer-131 top height at least 1528
    must have Y at least [1528 - 78 = 1450]. *)
Theorem timer131_top_retry_requires_graphics_y_at_least_1450 :
  forall graphics_position floor_y,
    -32768 <= position_y graphics_position < 32768 ->
    timer131_top_floor_min_y <= floor_y ->
    floor_query_can_return graphics_position floor_y ->
    timer131_min_retry_query_y <= position_y graphics_position.
Proof.
  intros graphics_position floor_y Hrange Hfloor Hquery.
  unfold floor_query_can_return in Hquery.
  rewrite signed16_in_range in Hquery by exact Hrange.
  unfold timer131_top_floor_min_y, timer131_min_retry_query_y,
    find_floor_upward_buffer in *.
  lia.
Qed.

(** Any raw Mario Object still overlapping the upper warp has Y at most 818.
    Combining that with the corrected timer-131 floor boundary gives a
    Graphics-minus-Object requirement of at least [1450 - 818 = 632]. *)
Theorem timer131_warp_retry_requires_at_least_632_graphics_y_gap :
  forall object_position graphics_position floor_y,
    upper_warp_contact object_position ->
    -32768 <= position_y graphics_position < 32768 ->
    timer131_top_floor_min_y <= floor_y ->
    floor_query_can_return graphics_position floor_y ->
    632 <=
      position_y graphics_position - position_y object_position.
Proof.
  intros object_position graphics_position floor_y
    Hwarp Hrange Hfloor Hquery.
  pose proof
    (upper_warp_contact_y_bounds object_position Hwarp) as Hobject.
  pose proof
    (timer131_top_retry_requires_graphics_y_at_least_1450
      graphics_position floor_y Hrange Hfloor Hquery) as Hgraphics.
  unfold timer131_min_retry_query_y in Hgraphics.
  lia.
Qed.

Definition timer131_retry_position : PositionZ := {|
  position_x := -1641;
  position_y := 1456;
  position_z := -783
|}.

(** The concrete strict-interior witness is six units higher than the generic
    minimum, so it needs at least [1456 - 818 = 638] units against any
    warp-overlapping Object.  At the exact warp center the gap is 688. *)
Theorem timer131_concrete_retry_requires_at_least_638_graphics_y_gap :
  forall object_position,
    upper_warp_contact object_position ->
    638 <=
      position_y timer131_retry_position - position_y object_position.
Proof.
  intros object_position Hwarp.
  pose proof
    (upper_warp_contact_y_bounds object_position Hwarp) as Hobject.
  change (638 <= 1456 - position_y object_position).
  lia.
Qed.

Theorem timer131_concrete_retry_center_gap_is_688 :
  position_y timer131_retry_position - position_y upper_warp_center = 688.
Proof.
  unfold timer131_retry_position, upper_warp_center, upper_warp_y; reflexivity.
Qed.

Definition timer131_midface_retry_position : PositionZ := {|
  position_x := -1862;
  position_y := 1778;
  position_z := -902
|}.

(** This exact query is much higher than the earlier side-face query.  Since
    any collision Object overlapping the upper warp is at most Y=818, it
    needs a Graphics-minus-Object gap of at least 960; at the exact warp
    centre the gap is 1010. *)
Theorem timer131_midface_retry_requires_at_least_960_graphics_y_gap :
  forall object_position,
    upper_warp_contact object_position ->
    960 <=
      position_y timer131_midface_retry_position -
        position_y object_position.
Proof.
  intros object_position Hwarp.
  pose proof
    (upper_warp_contact_y_bounds object_position Hwarp) as Hobject.
  change (960 <= 1778 - position_y object_position).
  lia.
Qed.

Theorem timer131_midface_retry_center_gap_is_1010 :
  position_y timer131_midface_retry_position -
    position_y upper_warp_center = 1010.
Proof.
  unfold timer131_midface_retry_position, upper_warp_center, upper_warp_y;
    reflexivity.
Qed.

Theorem timer131_midface_current_writer_bounds_cannot_install :
  forall object_position,
    upper_warp_contact object_position ->
    (position_y timer131_midface_retry_position -
       position_y object_position <= 45 -> False) /\
    (position_y timer131_midface_retry_position -
       position_y object_position <= audited_graphics_y_gap_bound -> False).
Proof.
  intros object_position Hwarp.
  pose proof
    (timer131_midface_retry_requires_at_least_960_graphics_y_gap
      object_position Hwarp) as Hrequired.
  unfold audited_graphics_y_gap_bound.
  lia.
Qed.

(** The dry source-audit target (45) and the conservative modeled writer
    envelope (208) are both arithmetically too small for the 632-unit
    requirement.  As in [InkFallback], applying these exclusions to retail
    still requires the open writer/action-closure refinement. *)
Theorem timer131_gap_exceeds_current_writer_bounds :
  riding_shell_ground_graphics_y_offset < 632 /\
  audited_graphics_y_gap_bound < 632.
Proof.
  unfold riding_shell_ground_graphics_y_offset,
    audited_graphics_y_gap_bound; lia.
Qed.

Theorem timer131_bounded_writer_cannot_install_retry :
  forall object_position graphics_position floor_y,
    upper_warp_contact object_position ->
    -32768 <= position_y graphics_position < 32768 ->
    timer131_top_floor_min_y <= floor_y ->
    floor_query_can_return graphics_position floor_y ->
    (position_y graphics_position - position_y object_position <= 45 -> False) /\
    (position_y graphics_position - position_y object_position <=
       audited_graphics_y_gap_bound -> False).
Proof.
  intros object_position graphics_position floor_y
    Hwarp Hrange Hfloor Hquery.
  pose proof
    (timer131_warp_retry_requires_at_least_632_graphics_y_gap
      object_position graphics_position floor_y
      Hwarp Hrange Hfloor Hquery) as Hrequired.
  unfold audited_graphics_y_gap_bound.
  lia.
Qed.

(** * Reproducible authentic-JP observation record *)

(** [timer131_jp_probe_observation] is a transcription of the hash-gated
    instrumentation trace.  Its checker prevents documentation drift; it is
    not a theorem that the injected prestate is gameplay reachable, nor is an
    emulator observation substituted for a Clight small-step proof. *)
Record Timer131JPProbeObservation : Type := {
  timer131_probe_pre_top_timer : Z;
  timer131_probe_post_top_timer : Z;
  timer131_probe_post_top_bits : Z * Z * Z;
  timer131_probe_post_state_bits : Z * Z * Z;
  timer131_probe_floor_pointer : Z;
  timer131_probe_top_pointer : Z;
  timer131_probe_warp_pointer : Z;
  timer131_probe_floor_owner : Z;
  timer131_probe_post_action : Z;
  timer131_probe_post_action_arg : Z;
  timer131_probe_post_used_object : Z;
  timer131_probe_post_platform : Z;
  timer131_probe_a_pressed_frames : Z;
  timer131_probe_a_down_frames : Z;
  timer131_probe_controller_a_frames : Z
}.

Definition timer131_jp_probe_observation : Timer131JPProbeObservation := {|
  timer131_probe_pre_top_timer := 131;
  timer131_probe_post_top_timer := 132;
  timer131_probe_post_top_bits :=
    (3305271296, 1155457606, 3296706560);
  timer131_probe_post_state_bits :=
    (3301777408, 1153411840, 3292774400);
  timer131_probe_floor_pointer := 2149169936;
  timer131_probe_top_pointer := 2150912504;
  timer131_probe_warp_pointer := 2150914328;
  timer131_probe_floor_owner := 2150912504;
  timer131_probe_post_action := 4864;
  timer131_probe_post_action_arg := 262145;
  timer131_probe_post_used_object := 2150914328;
  timer131_probe_post_platform := 2150912504;
  timer131_probe_a_pressed_frames := 0;
  timer131_probe_a_down_frames := 0;
  timer131_probe_controller_a_frames := 0
|}.

Definition timer131_jp_probe_observation_claim : Prop :=
  timer131_probe_post_top_timer timer131_jp_probe_observation =
    timer131_probe_pre_top_timer timer131_jp_probe_observation + 1 /\
  timer131_probe_post_top_bits timer131_jp_probe_observation =
    (Int.unsigned (Float32.to_bits timer131_center_x),
     Int.unsigned (Float32.to_bits
       (timer131_center_y timer131_after_behavior)),
     Int.unsigned (Float32.to_bits timer131_center_z)) /\
  timer131_probe_post_state_bits timer131_jp_probe_observation =
    (3301777408, 1153411840, 3292774400) /\
  timer131_probe_floor_owner timer131_jp_probe_observation =
    timer131_probe_top_pointer timer131_jp_probe_observation /\
  timer131_probe_post_action timer131_jp_probe_observation = 4864 /\
  timer131_probe_post_action_arg timer131_jp_probe_observation = 262145 /\
  timer131_probe_post_used_object timer131_jp_probe_observation =
    timer131_probe_warp_pointer timer131_jp_probe_observation /\
  timer131_probe_post_platform timer131_jp_probe_observation =
    timer131_probe_top_pointer timer131_jp_probe_observation /\
  timer131_probe_a_pressed_frames timer131_jp_probe_observation = 0 /\
  timer131_probe_a_down_frames timer131_jp_probe_observation = 0 /\
  timer131_probe_controller_a_frames timer131_jp_probe_observation = 0.

Theorem timer131_jp_probe_observation_record_checked :
  timer131_jp_probe_observation_claim.
Proof.
  unfold timer131_jp_probe_observation_claim,
    timer131_jp_probe_observation, timer131_center_x, timer131_center_z,
    timer131_after_behavior, timer131_before_timer60,
    timer131_timer59_center_y, timer131_sine_timer59, f32_of_Z.
  vm_compute.
  repeat split; reflexivity.
Qed.

(** A separate authenticated trace replaced only the transient side-point
    Graphics coordinates with the mid-face witness.  These observations show
    capture at global timers 493 and 498, capture of the inactive/free top at
    timer 513, and the displaced first Area-2 position.  As above, the record
    is evidence about a conditional injected boundary, not reachability. *)
Record Timer131JPMidfaceCaptureObservation : Type := {
  midface_injected_graphics_bits : Z * Z * Z;
  midface_timer493_state_bits : Z * Z * Z;
  midface_timer498_state_bits : Z * Z * Z;
  midface_timer513_state_bits : Z * Z * Z;
  midface_first_area2_state_bits : Z * Z * Z;
  midface_selected_height_bits : Z;
  midface_top_pointer : Z;
  midface_warp_pointer : Z;
  midface_timer493_floor_owner : Z;
  midface_timer493_platform : Z;
  midface_timer498_floor_owner : Z;
  midface_timer498_platform : Z;
  midface_timer513_floor_owner : Z;
  midface_timer513_platform : Z;
  midface_timer513_top_active : Z;
  midface_timer513_free_depth : Z;
  midface_first_area2_free_depth : Z;
  midface_post_action : Z;
  midface_post_action_arg : Z;
  midface_post_used_object : Z;
  midface_a_pressed_frames : Z;
  midface_a_down_frames : Z;
  midface_controller_a_frames : Z;
  midface_final_hidden_counter : Z
}.

Definition timer131_jp_midface_capture_observation
    : Timer131JPMidfaceCaptureObservation := {|
  midface_injected_graphics_bits :=
    (3303587840, 1155416064, 3294724096);
  midface_timer493_state_bits :=
    (3303587840, 1155464726, 3294724096);
  midface_timer498_state_bits :=
    (3305743606, 1155839930, 3298192968);
  midface_timer513_state_bits :=
    (3304745090, 1156620135, 3292908471);
  midface_first_area2_state_bits :=
    (1136053216, 1168891904, 3297319343);
  midface_selected_height_bits := 1155464726;
  midface_top_pointer := 2150912504;
  midface_warp_pointer := 2150914328;
  midface_timer493_floor_owner := 2150912504;
  midface_timer493_platform := 2150912504;
  midface_timer498_floor_owner := 2150912504;
  midface_timer498_platform := 2150912504;
  midface_timer513_floor_owner := 2150912504;
  midface_timer513_platform := 2150912504;
  midface_timer513_top_active := 0;
  midface_timer513_free_depth := 0;
  midface_first_area2_free_depth := 47;
  midface_post_action := 4864;
  midface_post_action_arg := 262145;
  midface_post_used_object := 2150914328;
  midface_a_pressed_frames := 0;
  midface_a_down_frames := 0;
  midface_controller_a_frames := 0;
  midface_final_hidden_counter := 1
|}.

Definition timer131_jp_midface_capture_observation_claim : Prop :=
  midface_injected_graphics_bits timer131_jp_midface_capture_observation =
    (3303587840, 1155416064, 3294724096) /\
  timer131_buffer_observation
      timer131_midface_retry_query timer131_retry_face =
    Some
      (midface_selected_height_bits
         timer131_jp_midface_capture_observation,
       1116741280, false) /\
  midface_timer493_state_bits timer131_jp_midface_capture_observation =
    (3303587840, 1155464726, 3294724096) /\
  midface_timer498_state_bits timer131_jp_midface_capture_observation =
    (3305743606, 1155839930, 3298192968) /\
  midface_timer513_state_bits timer131_jp_midface_capture_observation =
    (3304745090, 1156620135, 3292908471) /\
  midface_first_area2_state_bits timer131_jp_midface_capture_observation =
    (1136053216, 1168891904, 3297319343) /\
  midface_timer493_floor_owner timer131_jp_midface_capture_observation =
    midface_top_pointer timer131_jp_midface_capture_observation /\
  midface_timer493_platform timer131_jp_midface_capture_observation =
    midface_top_pointer timer131_jp_midface_capture_observation /\
  midface_timer498_floor_owner timer131_jp_midface_capture_observation =
    midface_top_pointer timer131_jp_midface_capture_observation /\
  midface_timer498_platform timer131_jp_midface_capture_observation =
    midface_top_pointer timer131_jp_midface_capture_observation /\
  midface_timer513_floor_owner timer131_jp_midface_capture_observation =
    midface_top_pointer timer131_jp_midface_capture_observation /\
  midface_timer513_platform timer131_jp_midface_capture_observation =
    midface_top_pointer timer131_jp_midface_capture_observation /\
  midface_timer513_top_active timer131_jp_midface_capture_observation = 0 /\
  midface_timer513_free_depth timer131_jp_midface_capture_observation = 0 /\
  midface_first_area2_free_depth timer131_jp_midface_capture_observation = 47 /\
  midface_post_action timer131_jp_midface_capture_observation = 4864 /\
  midface_post_action_arg timer131_jp_midface_capture_observation = 262145 /\
  midface_post_used_object timer131_jp_midface_capture_observation =
    midface_warp_pointer timer131_jp_midface_capture_observation /\
  midface_a_pressed_frames timer131_jp_midface_capture_observation = 0 /\
  midface_a_down_frames timer131_jp_midface_capture_observation = 0 /\
  midface_controller_a_frames timer131_jp_midface_capture_observation = 0 /\
  midface_final_hidden_counter timer131_jp_midface_capture_observation = 1.

Theorem timer131_jp_midface_capture_observation_record_checked :
  timer131_jp_midface_capture_observation_claim.
Proof.
  unfold timer131_jp_midface_capture_observation_claim,
    timer131_jp_midface_capture_observation,
    timer131_buffer_observation, area1_loaded_floor_height,
    area1_loaded_floor_buffer_difference, area1_loaded_plane_for_triangle,
    area1_compute_loaded_plane, area1_source_normal_components,
    area1_source_triangle_vertices, timer131_vertices_s16,
    timer131_midface_retry_query, timer131_retry_face,
    area1_f32_reciprocal_via_double, area1_f32_of_Z, f32_of_Z.
  vm_compute.
  repeat split; reflexivity.
Qed.

(** The static Area-1 certificate and the finite stock-owner abstraction both
    reject the State diagnostic.  This still is not a live-list theorem. *)
Theorem timer131_state_miss_finite_boundary :
  (forallb area1_static_floor_decision_is_rejection
     (map
       (area1_static_floor_decision
         area1_collision_vertices_us area1_q_null_sample)
       area1_q_static_floor_candidates_computed_us) = true /\
   forallb area1_static_floor_decision_is_rejection
     (map
       (area1_static_floor_decision
         area1_collision_vertices_jp area1_q_null_sample)
       area1_q_static_floor_candidates_computed_jp) = true) /\
  (forall owner floor_y,
      ~ stock_dynamic_geometry_floor_candidate
          owner ink_warp_floor_miss_position floor_y) /\
  timer131_buffer_observation timer131_state_query timer131_state_face =
    Some (1156733869, 3297287085, true).
Proof.
  split.
  - pose proof area1_q_static_all_rejection_checks_computed as H.
    tauto.
  - split.
    + exact ink_first_query_has_no_modeled_stock_dynamic_floor_candidate.
    + exact timer131_state_face_is_too_high.
Qed.

(** * Generated-Clight source-order boundary *)

Definition timer131_surface_source_shape_claim : Prop :=
  pyramid_top_spin_explosion_pose_source_shape_us_claim /\
  pyramid_top_spin_explosion_pose_source_shape_jp_claim /\
  initializer_addrof_subsequenceb
    [T131UBD._bhv_pyramid_top_loop; T131UBD._load_object_collision_model]
    (gvar_init T131UBD.v_bhvPyramidTop) = true /\
  initializer_addrof_subsequenceb
    [T131JBD._bhv_pyramid_top_loop; T131JBD._load_object_collision_model]
    (gvar_init T131JBD.v_bhvPyramidTop) = true /\
  ident_subsequenceb
    [T131UOL._clear_dynamic_surfaces;
     T131UOL._update_terrain_objects;
     T131UOL._apply_mario_platform_displacement;
     T131UOL._detect_object_collisions;
     T131UOL._update_non_terrain_objects;
     T131UOL._unload_deactivated_objects;
     T131UOL._update_mario_platform]
    (straightline_callees_s (fn_body T131UOL.f_update_objects)) = true /\
  ident_subsequenceb
    [T131JOL._clear_dynamic_surfaces;
     T131JOL._update_terrain_objects;
     T131JOL._apply_mario_platform_displacement;
     T131JOL._detect_object_collisions;
     T131JOL._update_non_terrain_objects;
     T131JOL._unload_deactivated_objects;
     T131JOL._update_mario_platform]
    (straightline_callees_s (fn_body T131JOL.f_update_objects)) = true /\
  assigns_field_null_pointer_s T131URender._throwMatrix
    (fn_body T131URender.f_geo_process_object) = true /\
  assigns_field_null_pointer_s T131JRender._throwMatrix
    (fn_body T131JRender.f_geo_process_object) = true /\
  ident_subsequenceb
    [T131USL._dist_between_objects;
     T131USL._transform_object_vertices;
     T131USL._load_object_surfaces]
    (direct_callees_s (fn_body T131USL.f_load_object_collision_model)) = true /\
  ident_subsequenceb
    [T131JSL._dist_between_objects;
     T131JSL._transform_object_vertices;
     T131JSL._load_object_surfaces]
    (direct_callees_s (fn_body T131JSL.f_load_object_collision_model)) = true /\
  statement_contains_float32_to_s16_cast_s
    (fn_body T131USL.f_transform_object_vertices) = true /\
  statement_contains_float32_to_s16_cast_s
    (fn_body T131JSL.f_transform_object_vertices) = true /\
  assigns_field_named_s T131USL._object
    (fn_body T131USL.f_load_object_surfaces) = true /\
  assigns_field_named_s T131JSL._object
    (fn_body T131JSL.f_load_object_surfaces) = true.

Theorem timer131_surface_source_shape_checked :
  timer131_surface_source_shape_claim.
Proof.
  unfold timer131_surface_source_shape_claim.
  split; [exact pyramid_top_spin_explosion_pose_source_shape_us |].
  split; [exact pyramid_top_spin_explosion_pose_source_shape_jp |].
  vm_compute.
  repeat split; reflexivity.
Qed.

(** Exported capstone: exact pose, fresh transform, State rejection, corrected
    retry acceptance, and the generated source-order receipts hold together.
    No live-memory or reachability proposition is a conjunct. *)
Definition Timer131SurfaceCheckedBoundary : Prop :=
  timer131_pose_claim /\
  (forall memory,
    map (timer131_cast_vertex memory) pyramid_top_vertices =
      map (@Some Area1SourceVertex) timer131_vertices_s16) /\
  timer131_buffer_observation timer131_state_query timer131_state_face =
    Some (1156733869, 3297287085, true) /\
  timer131_buffer_observation timer131_old_home_query timer131_retry_face =
    Some (1157276704, 3272089856, true) /\
  timer131_buffer_observation timer131_retry_query timer131_retry_face =
    Some (1153411840, 1059586048, false) /\
  timer131_buffer_observation
      timer131_midface_retry_query timer131_retry_face =
    Some (1155464726, 1116741280, false) /\
  timer131_surface_source_shape_claim.

Theorem timer131_surface_checked_boundary :
  Timer131SurfaceCheckedBoundary.
Proof.
  unfold Timer131SurfaceCheckedBoundary.
  split; [exact timer131_pose_checked |].
  split; [exact timer131_fresh_transform_s16_checked |].
  split; [exact timer131_state_face_is_too_high |].
  split; [exact timer131_old_home_sample_is_rejected |].
  split; [exact (proj1 timer131_robust_interior_retry_is_accepted) |].
  split; [exact (proj1 timer131_midface_retry_is_accepted) |].
  exact timer131_surface_source_shape_checked.
Qed.
