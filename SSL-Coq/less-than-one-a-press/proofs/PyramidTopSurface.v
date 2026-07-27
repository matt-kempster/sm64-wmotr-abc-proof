(** Generated-Clight and finite-width facts for the pyramid-top floor query.

    This module closes four narrow, previously informal links:

    - the exact CompCert [Cop.sem_cast] result for the concrete PU sample;
    - the value arithmetic of the authenticated retail
      [trunc.w.s; mfc1; sh; lh] fragment for those same three inputs;
    - inclusion of the matrix and dynamic-surface helper bodies in the selected
      US/JP translation-unit set; and
    - a link from the parsed face to manually mirrored zero-yaw home vertices,
      followed by concrete cell, transform, and triangle-edge arithmetic.

    The ROM hashes, instruction addresses, and bytes authenticating the retail
    fragment are documented outside Rocq in
    [docs/retail-find-floor-cast.md]; this module does not parse a ROM or prove
    a general compiler theorem for arbitrary out-of-range conversions.
    It also does not execute the transform/surface bodies over linked memory,
    prove that a reachable object-pool epoch constructs the surface, or prove
    that [find_floor] selects it. *)

From Coq Require Import Bool List ZArith.
From compcert Require Import
  AST Clight Clightdefs Cop Ctypes Floats Integers Memory Values.
From LessThanOneAPress.Generated Require Import
  us_math_util jp_math_util
  us_object_helpers jp_object_helpers
  us_platform_displacement jp_platform_displacement
  us_surface_collision jp_surface_collision
  us_surface_load jp_surface_load.
From LessThanOneAPress.Proofs Require Import ASTFacts CollisionMeshFacts.

Import ListNotations.
Import Clightdefs.ClightNotations.
Local Open Scope Z_scope.

Module UM := us_math_util.
Module JM := jp_math_util.
Module UOH := us_object_helpers.
Module JOH := jp_object_helpers.
Module UPD := us_platform_displacement.
Module JPD := jp_platform_displacement.
Module USC := us_surface_collision.
Module JSC := jp_surface_collision.
Module USL := us_surface_load.
Module JSL := jp_surface_load.

(** A bounded lookup avoids normalizing a whole generated program merely to
    establish that a named helper is an internal Clight definition. *)
Fixpoint find_internal_function
    (needle : ident)
    (definitions : list
      (ident * globdef (fundef function) type)) : option function :=
  match definitions with
  | [] => None
  | (id, Gfun (Internal body)) :: rest =>
      if Pos.eqb id needle
      then Some body
      else find_internal_function needle rest
  | _ :: rest => find_internal_function needle rest
  end.

Definition find_floor_cast_prefix
    (body : statement)
    : option ((ident * expr) * (ident * expr) * (ident * expr)) :=
  match body with
  | Ssequence _
      (Ssequence _
        (Ssequence (Sset x_id x_rhs)
          (Ssequence (Sset y_id y_rhs)
            (Ssequence (Sset z_id z_rhs) _)))) =>
      Some ((x_id, x_rhs), (y_id, y_rhs), (z_id, z_rhs))
  | _ => None
  end.

Definition signed_short_temp_cast (source : ident) : expr :=
  Ecast (Ecast (Etempvar source tfloat) tshort) tshort.

Theorem find_floor_cast_prefix_exact_us :
  find_floor_cast_prefix (fn_body USC.f_find_floor) =
    Some
      ((USC._x, signed_short_temp_cast USC._xPos),
       (USC._y, signed_short_temp_cast USC._yPos),
       (USC._z, signed_short_temp_cast USC._zPos)).
Proof. vm_compute. reflexivity. Qed.

Theorem find_floor_cast_prefix_exact_jp :
  find_floor_cast_prefix (fn_body JSC.f_find_floor) =
    Some
      ((JSC._x, signed_short_temp_cast JSC._xPos),
       (JSC._y, signed_short_temp_cast JSC._yPos),
       (JSC._z, signed_short_temp_cast JSC._zPos)).
Proof. vm_compute. reflexivity. Qed.

Definition find_floor_cast_prefix_claim : Prop :=
  find_floor_cast_prefix (fn_body USC.f_find_floor) =
    Some
      ((USC._x, signed_short_temp_cast USC._xPos),
       (USC._y, signed_short_temp_cast USC._yPos),
       (USC._z, signed_short_temp_cast USC._zPos)) /\
  find_floor_cast_prefix (fn_body JSC.f_find_floor) =
    Some
      ((JSC._x, signed_short_temp_cast JSC._xPos),
       (JSC._y, signed_short_temp_cast JSC._yPos),
       (JSC._z, signed_short_temp_cast JSC._zPos)).

Theorem find_floor_cast_prefix_checked :
  find_floor_cast_prefix_claim.
Proof.
  split.
  - exact find_floor_cast_prefix_exact_us.
  - exact find_floor_cast_prefix_exact_jp.
Qed.

Definition concrete_short_cast
    (bits : Z) (memory : Mem.mem) : option val :=
  match Cop.sem_cast
      (Vsingle (Float32.of_bits (Int.repr bits)))
      tfloat tshort memory with
  | Some value => Cop.sem_cast value tshort tshort memory
  | None => None
  end.

(** 63488.0f is outside the signed-16 range but inside the signed-32 range.
    CompCert first performs its binary32-to-signed-32 conversion and then
    [Int.sign_ext 16], producing -2048.  This theorem itself is about the
    generated Clight semantics.  The separate instruction-fragment theorem
    below and authenticated receipt close the matching retail result for the
    same three inputs only. *)
Theorem compcert_find_floor_concrete_short_casts :
  forall memory,
    concrete_short_cast 1199046656 memory =
      Some (Vint (Int.repr (-2048))) /\
    concrete_short_cast 1155522560 memory =
      Some (Vint (Int.repr 1791)) /\
    concrete_short_cast 3296722944 memory =
      Some (Vint (Int.repr (-1024))).
Proof.
  intros memory.
  vm_compute.
  repeat split; reflexivity.
Qed.

(** The authenticated US and JP retail functions use the same instruction
    shape for each coordinate:

      [trunc.w.s; mfc1; sh stack_slot; ...; lh stack_slot].

    [Float32.to_int] models the truncation of these finite, exactly integral,
    signed-32-range inputs.  [Int.sign_ext 16] is the value-level effect of
    storing the low halfword and loading it back with signed [lh].

    The theorem below checks the instruction-fragment arithmetic.  ROM hashes,
    addresses, words, and the external attribution of that fragment to
    retail [find_floor] are recorded in
    [docs/retail-find-floor-cast.md]; this module does not parse a ROM. *)
Definition modeled_trunc_w_s_sh_lh (bits : Z) : option int :=
  match Float32.to_int (Float32.of_bits (Int.repr bits)) with
  | Some word => Some (Int.sign_ext 16 word)
  | None => None
  end.

Definition concrete_retail_cast_fragment_claim : Prop :=
  modeled_trunc_w_s_sh_lh 1199046656 =
    Some (Int.repr (-2048)) /\
  modeled_trunc_w_s_sh_lh 1155522560 =
    Some (Int.repr 1791) /\
  modeled_trunc_w_s_sh_lh 3296722944 =
    Some (Int.repr (-1024)).

Theorem concrete_retail_cast_fragment_arithmetic :
  concrete_retail_cast_fragment_claim.
Proof. vm_compute. repeat split; reflexivity. Qed.

Definition partition_cell_index (coordinate : int) : int :=
  Int.and
    (Int.divs
      (Int.add coordinate (Int.repr 8192))
      (Int.shl Int.one (Int.repr 10)))
    (Int.sub
      (Int.divs
        (Int.mul (Int.repr 2) (Int.repr 8192))
        (Int.shl Int.one (Int.repr 10)))
      Int.one).

Theorem concrete_pu_dynamic_partition_cell :
  Int.signed (partition_cell_index (Int.repr (-2048))) = 6 /\
  Int.signed (partition_cell_index (Int.repr (-1024))) = 7.
Proof. vm_compute. split; reflexivity. Qed.

Record VertexXZ : Type := {
  vertex_x : int;
  vertex_z : int
}.

Definition floor_edge_value
    (query vertex1 vertex2 : VertexXZ) : int :=
  Int.sub
    (Int.mul
      (Int.sub (vertex_z vertex1) (vertex_z query))
      (Int.sub (vertex_x vertex2) (vertex_x vertex1)))
    (Int.mul
      (Int.sub (vertex_x vertex1) (vertex_x query))
      (Int.sub (vertex_z vertex2) (vertex_z vertex1))).

Definition candidate_query_xz : VertexXZ := {|
  vertex_x := Int.repr (-2048);
  vertex_z := Int.repr (-1024)
|}.

Definition top_triangle_vertex1_xz : VertexXZ := {|
  vertex_x := Int.repr (-1535);
  vertex_z := Int.repr (-1534)
|}.

Definition top_triangle_vertex4_xz : VertexXZ := {|
  vertex_x := Int.repr (-2558);
  vertex_z := Int.repr (-1534)
|}.

Definition top_triangle_vertex3_xz : VertexXZ := {|
  vertex_x := Int.repr (-2047);
  vertex_z := Int.repr (-1023)
|}.

Definition home_zero_yaw_vertex (vertex : Z * Z * Z) : Z * Z * Z :=
  let '(x, y, z) := vertex in
  (-2047 + x, 1536 + y, -1023 + z).

Definition world_vertex_xz (vertex : Z * Z * Z) : VertexXZ :=
  let '(x, _, z) := vertex in {|
    vertex_x := Int.repr x;
    vertex_z := Int.repr z
  |}.

(** This is the explicit bridge from the parsed generated collision stream to
    the three zero-yaw home vertices used by the arithmetic below.  The
    separate [pyramid_top_source_mesh_claim] connects [pyramid_top_vertices]
    and [pyramid_top_triangles] to both generated US/JP initializers.  The
    home translation here is manual arithmetic, not an execution of the
    generated matrix or vertex-transform bodies. *)
Definition concrete_top_face_mesh_link_claim : Prop :=
  nth_error pyramid_top_triangles 4 = Some (1, 4, 3) /\
  option_map (fun vertex => world_vertex_xz (home_zero_yaw_vertex vertex))
    (nth_error pyramid_top_vertices 1) =
      Some top_triangle_vertex1_xz /\
  option_map (fun vertex => world_vertex_xz (home_zero_yaw_vertex vertex))
    (nth_error pyramid_top_vertices 4) =
      Some top_triangle_vertex4_xz /\
  option_map (fun vertex => world_vertex_xz (home_zero_yaw_vertex vertex))
    (nth_error pyramid_top_vertices 3) =
      Some top_triangle_vertex3_xz /\
  option_map home_zero_yaw_vertex
    (nth_error pyramid_top_vertices 1) =
      Some (-1535, 1281, -1534) /\
  option_map home_zero_yaw_vertex
    (nth_error pyramid_top_vertices 4) =
      Some (-2558, 1281, -1534) /\
  option_map home_zero_yaw_vertex
    (nth_error pyramid_top_vertices 3) =
      Some (-2047, 1792, -1023).

Theorem concrete_top_face_mesh_link_checked :
  concrete_top_face_mesh_link_claim.
Proof. vm_compute. repeat split; reflexivity. Qed.

Definition concrete_top_face_edge_acceptance_claim : Prop :=
  Int.signed
    (floor_edge_value candidate_query_xz
      top_triangle_vertex1_xz top_triangle_vertex4_xz) = 521730 /\
  Int.signed
    (floor_edge_value candidate_query_xz
      top_triangle_vertex4_xz top_triangle_vertex3_xz) = 0 /\
  Int.signed
    (floor_edge_value candidate_query_xz
      top_triangle_vertex3_xz top_triangle_vertex1_xz) = 1023 /\
  Int.lt
    (floor_edge_value candidate_query_xz
      top_triangle_vertex1_xz top_triangle_vertex4_xz) Int.zero = false /\
  Int.lt
    (floor_edge_value candidate_query_xz
      top_triangle_vertex4_xz top_triangle_vertex3_xz) Int.zero = false /\
  Int.lt
    (floor_edge_value candidate_query_xz
      top_triangle_vertex3_xz top_triangle_vertex1_xz) Int.zero = false.

(** These are manually mirrored instances of the three signed-32 edge
    expressions in [find_floor_from_list] for parsed face [(1,4,3)].  The
    candidate is on the 4--3 edge, so the middle value is zero and passes the
    mirrored strict-negative tests.  No theorem here extracts the complete
    expressions from generated Clight or executes the list traversal. *)
Theorem concrete_top_face_edge_tests :
  concrete_top_face_edge_acceptance_claim.
Proof. vm_compute. repeat split; reflexivity. Qed.

Definition f32_of_Z (value : Z) : float32 :=
  Float32.of_int (Int.repr value).

Definition matrix_component_f32
    (vx vy vz m0 m1 m2 translation : float32) : float32 :=
  Float32.add
    (Float32.add
      (Float32.add (Float32.mul vx m0) (Float32.mul vy m1))
      (Float32.mul vz m2))
    translation.

Definition identity_x_component_f32
    (vx vy vz translation : float32) : float32 :=
  matrix_component_f32 vx vy vz
    (f32_of_Z 1) (f32_of_Z 0) (f32_of_Z 0) translation.

Definition yaw_only_y_component_f32
    (vx vy vz translation : float32) : float32 :=
  matrix_component_f32 vx vy vz
    (f32_of_Z 0) (f32_of_Z 1) (Float32.neg (f32_of_Z 0)) translation.

Definition identity_z_component_f32
    (vx vy vz translation : float32) : float32 :=
  matrix_component_f32 vx vy vz
    (f32_of_Z 0) (f32_of_Z 0) (f32_of_Z 1) translation.

Definition cast_transformed_component
    (component : float32) (memory : Mem.mem) : option val :=
  Cop.sem_cast (Vsingle component) tfloat tshort memory.

Definition concrete_home_top_triangle_transform_claim : Prop :=
  forall memory,
    cast_transformed_component
      (identity_x_component_f32
        (f32_of_Z 512) (f32_of_Z (-255)) (f32_of_Z (-511))
        (f32_of_Z (-2047))) memory =
      Some (Vint (Int.repr (-1535))) /\
    cast_transformed_component
      (yaw_only_y_component_f32
        (f32_of_Z 512) (f32_of_Z (-255)) (f32_of_Z (-511))
        (f32_of_Z 1536)) memory =
      Some (Vint (Int.repr 1281)) /\
    cast_transformed_component
      (identity_z_component_f32
        (f32_of_Z 512) (f32_of_Z (-255)) (f32_of_Z (-511))
        (f32_of_Z (-1023))) memory =
      Some (Vint (Int.repr (-1534))) /\
    cast_transformed_component
      (identity_x_component_f32
        (f32_of_Z (-511)) (f32_of_Z (-255)) (f32_of_Z (-511))
        (f32_of_Z (-2047))) memory =
      Some (Vint (Int.repr (-2558))) /\
    cast_transformed_component
      (yaw_only_y_component_f32
        (f32_of_Z (-511)) (f32_of_Z (-255)) (f32_of_Z (-511))
        (f32_of_Z 1536)) memory =
      Some (Vint (Int.repr 1281)) /\
    cast_transformed_component
      (identity_z_component_f32
        (f32_of_Z (-511)) (f32_of_Z (-255)) (f32_of_Z (-511))
        (f32_of_Z (-1023))) memory =
      Some (Vint (Int.repr (-1534))) /\
    cast_transformed_component
      (identity_x_component_f32
        (f32_of_Z 0) (f32_of_Z 256) (f32_of_Z 0)
        (f32_of_Z (-2047))) memory =
      Some (Vint (Int.repr (-2047))) /\
    cast_transformed_component
      (yaw_only_y_component_f32
        (f32_of_Z 0) (f32_of_Z 256) (f32_of_Z 0)
        (f32_of_Z 1536)) memory =
      Some (Vint (Int.repr 1792)) /\
    cast_transformed_component
      (identity_z_component_f32
        (f32_of_Z 0) (f32_of_Z 256) (f32_of_Z 0)
        (f32_of_Z (-1023))) memory =
      Some (Vint (Int.repr (-1023))).

(** At zero pitch, roll, and yaw, the generated Z-X-Y matrix is the identity;
    its Y column [0,1,-0] remains independent of yaw.  The theorem evaluates a
    hand-mirrored CompCert binary32 multiply/add association for the three
    parsed vertices of face [(1,4,3)] at the stock home translation.
    Establishing that a linked execution of [transform_object_vertices]
    performs these operations over the intended memory is still a refinement
    obligation. *)
Theorem concrete_home_top_triangle_transform :
  concrete_home_top_triangle_transform_claim.
Proof.
  unfold concrete_home_top_triangle_transform_claim.
  intros memory.
  vm_compute.
  repeat split; reflexivity.
Qed.

Fixpoint sets_temp_from_temp_s
    (destination source : ident) (body : statement) : bool :=
  match body with
  | Sset found (Etempvar value _) =>
      Pos.eqb found destination && Pos.eqb value source
  | Ssequence a b | Sloop a b =>
      sets_temp_from_temp_s destination source a ||
      sets_temp_from_temp_s destination source b
  | Sifthenelse _ a b =>
      sets_temp_from_temp_s destination source a ||
      sets_temp_from_temp_s destination source b
  | Sswitch _ cases =>
      sets_temp_from_temp_ls destination source cases
  | Slabel _ nested => sets_temp_from_temp_s destination source nested
  | _ => false
  end
with sets_temp_from_temp_ls
    (destination source : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      sets_temp_from_temp_s destination source body ||
      sets_temp_from_temp_ls destination source rest
  end.

Fixpoint dynamic_floor_override_s
    (dynamic_height static_height floor dynamic_floor : ident)
    (body : statement) : bool :=
  match body with
  | Ssequence
      (Sset dynamic_temp (Evar found_dynamic_height _))
      (Ssequence
        (Sset static_temp (Evar found_static_height _))
        (Sifthenelse
          (Ebinop Ogt
            (Etempvar compared_dynamic_temp _)
            (Etempvar compared_static_temp _) _) then_branch _)) =>
      Pos.eqb found_dynamic_height dynamic_height &&
      Pos.eqb found_static_height static_height &&
      Pos.eqb compared_dynamic_temp dynamic_temp &&
      Pos.eqb compared_static_temp static_temp &&
      sets_temp_from_temp_s floor dynamic_floor then_branch
  | Sifthenelse
      (Ebinop Ogt
        (Etempvar found_dynamic_height _)
        (Etempvar found_static_height _) _) then_branch _ =>
      (Pos.eqb found_dynamic_height dynamic_height &&
       Pos.eqb found_static_height static_height &&
       sets_temp_from_temp_s floor dynamic_floor then_branch) ||
      dynamic_floor_override_s dynamic_height static_height
        floor dynamic_floor then_branch
  | Ssequence a b | Sloop a b =>
      dynamic_floor_override_s dynamic_height static_height
        floor dynamic_floor a ||
      dynamic_floor_override_s dynamic_height static_height
        floor dynamic_floor b
  | Sifthenelse _ a b =>
      dynamic_floor_override_s dynamic_height static_height
        floor dynamic_floor a ||
      dynamic_floor_override_s dynamic_height static_height
        floor dynamic_floor b
  | Sswitch _ cases =>
      dynamic_floor_override_ls dynamic_height static_height
        floor dynamic_floor cases
  | Slabel _ nested =>
      dynamic_floor_override_s dynamic_height static_height
        floor dynamic_floor nested
  | _ => false
  end
with dynamic_floor_override_ls
    (dynamic_height static_height floor dynamic_floor : ident)
    (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      dynamic_floor_override_s dynamic_height static_height
        floor dynamic_floor body ||
      dynamic_floor_override_ls dynamic_height static_height
        floor dynamic_floor rest
  end.

(** This recognizer is existential and syntactic: it finds a
    [dynamicHeight > height] guard whose then-branch contains
    [floor := dynamicFloor].  It does not establish that this is the only
    assignment to [floor], prove the complete height update, or derive any
    execution/dataflow semantics. *)
Theorem find_floor_dynamic_override_source_shape_us :
  dynamic_floor_override_s
    USC._dynamicHeight USC._height USC._floor USC._dynamicFloor
    (fn_body USC.f_find_floor) = true.
Proof. vm_compute. reflexivity. Qed.

Theorem find_floor_dynamic_override_source_shape_jp :
  dynamic_floor_override_s
    JSC._dynamicHeight JSC._height JSC._floor JSC._dynamicFloor
    (fn_body JSC.f_find_floor) = true.
Proof. vm_compute. reflexivity. Qed.

(** These checks close the former "external helper" ambiguity: every relevant
    matrix and dynamic-surface helper is an internal function of a selected
    generated translation unit.  A linked whole-program execution proof is
    still required to connect their memories and calls. *)
Definition pyramid_top_helper_bodies_present : Prop :=
  find_internal_function UM._mtxf_rotate_zxy_and_translate
    (prog_defs UM.prog) =
      Some UM.f_mtxf_rotate_zxy_and_translate /\
  find_internal_function JM._mtxf_rotate_zxy_and_translate
    (prog_defs JM.prog) =
      Some JM.f_mtxf_rotate_zxy_and_translate /\
  find_internal_function UOH._linear_mtxf_mul_vec3f
    (prog_defs UOH.prog) =
      Some UOH.f_linear_mtxf_mul_vec3f /\
  find_internal_function UOH._linear_mtxf_transpose_mul_vec3f
    (prog_defs UOH.prog) =
      Some UOH.f_linear_mtxf_transpose_mul_vec3f /\
  find_internal_function JOH._linear_mtxf_mul_vec3f
    (prog_defs JOH.prog) =
      Some JOH.f_linear_mtxf_mul_vec3f /\
  find_internal_function JOH._linear_mtxf_transpose_mul_vec3f
    (prog_defs JOH.prog) =
      Some JOH.f_linear_mtxf_transpose_mul_vec3f /\
  find_internal_function USL._read_surface_data
    (prog_defs USL.prog) =
      Some USL.f_read_surface_data /\
  find_internal_function USL._transform_object_vertices
    (prog_defs USL.prog) =
      Some USL.f_transform_object_vertices /\
  find_internal_function USL._load_object_surfaces
    (prog_defs USL.prog) =
      Some USL.f_load_object_surfaces /\
  find_internal_function USL._load_object_collision_model
    (prog_defs USL.prog) =
      Some USL.f_load_object_collision_model /\
  find_internal_function JSL._read_surface_data
    (prog_defs JSL.prog) =
      Some JSL.f_read_surface_data /\
  find_internal_function JSL._transform_object_vertices
    (prog_defs JSL.prog) =
      Some JSL.f_transform_object_vertices /\
  find_internal_function JSL._load_object_surfaces
    (prog_defs JSL.prog) =
      Some JSL.f_load_object_surfaces /\
  find_internal_function JSL._load_object_collision_model
    (prog_defs JSL.prog) =
      Some JSL.f_load_object_collision_model.

Theorem pyramid_top_helper_bodies_present_checked :
  pyramid_top_helper_bodies_present.
Proof.
  unfold pyramid_top_helper_bodies_present.
  vm_compute.
  repeat split; reflexivity.
Qed.

(** Despite the historical [semantic] name, this is a conjunction of exact
    source-shape, parsed-data, concrete cast, and manually mirrored arithmetic
    checks.  It is not a Clight small-step or linked-memory execution theorem. *)
Definition pyramid_top_surface_semantic_claim : Prop :=
  pyramid_top_helper_bodies_present /\
  find_floor_cast_prefix_claim /\
  pyramid_top_source_mesh_claim /\
  concrete_top_face_mesh_link_claim /\
  (forall memory,
      concrete_short_cast 1199046656 memory =
        Some (Vint (Int.repr (-2048))) /\
      concrete_short_cast 1155522560 memory =
        Some (Vint (Int.repr 1791)) /\
      concrete_short_cast 3296722944 memory =
        Some (Vint (Int.repr (-1024)))) /\
  concrete_retail_cast_fragment_claim /\
  Int.signed (partition_cell_index (Int.repr (-2048))) = 6 /\
  Int.signed (partition_cell_index (Int.repr (-1024))) = 7 /\
  concrete_top_face_edge_acceptance_claim /\
  concrete_home_top_triangle_transform_claim /\
  dynamic_floor_override_s
    USC._dynamicHeight USC._height USC._floor USC._dynamicFloor
    (fn_body USC.f_find_floor) = true /\
  dynamic_floor_override_s
    JSC._dynamicHeight JSC._height JSC._floor JSC._dynamicFloor
    (fn_body JSC.f_find_floor) = true.

Theorem pyramid_top_surface_semantic_kernel :
  pyramid_top_surface_semantic_claim.
Proof.
  unfold pyramid_top_surface_semantic_claim.
  split.
  - exact pyramid_top_helper_bodies_present_checked.
  - split.
    + exact find_floor_cast_prefix_checked.
    + split.
      * exact pyramid_top_source_mesh_checked.
      * split.
        -- exact concrete_top_face_mesh_link_checked.
        -- split.
           ++ exact compcert_find_floor_concrete_short_casts.
           ++ split.
              ** exact concrete_retail_cast_fragment_arithmetic.
              ** pose proof concrete_pu_dynamic_partition_cell as Hcell.
                 destruct Hcell as (Hx & Hz).
                 exact
                   (conj Hx
                     (conj Hz
                       (conj concrete_top_face_edge_tests
                         (conj concrete_home_top_triangle_transform
                           (conj find_floor_dynamic_override_source_shape_us
                             find_floor_dynamic_override_source_shape_jp))))).
Qed.
