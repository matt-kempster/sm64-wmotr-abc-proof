From Coq Require Import Bool Lia List ZArith.
From compcert Require Import AST Clight Floats Integers.
From Pedro.Generated Require Import
  us_math_util us_surface_load us_surface_collision
  us_ttc_area1_macro us_ttc_spinner_collision
  jp_math_util jp_surface_load jp_surface_collision
  jp_ttc_area1_macro jp_ttc_spinner_collision.
From Pedro.Proofs Require Import ASTFacts GameTypes.

Import ListNotations.
Open Scope Z_scope.

Module UMath := us_math_util.
Module USurface := us_surface_load.
Module USurfaceQuery := us_surface_collision.
Module UMacroGeometry := us_ttc_area1_macro.
Module UCollisionGeometry := us_ttc_spinner_collision.

Module JMath := jp_math_util.
Module JSurface := jp_surface_load.
Module JSurfaceQuery := jp_surface_collision.
Module JMacroGeometry := jp_ttc_area1_macro.
Module JCollisionGeometry := jp_ttc_spinner_collision.

(** These checks pin the two source operations represented by the executable
    certificate below: construction of the Z-X-Y matrix from [gSineTable], and
    binary32 transformation followed by TerrainData stores. *)
Definition ttc_geometry_source_receipt (version : GameVersion) : Prop :=
  match version with
  | VersionUS =>
      statement_mentions_ident_s UMath._gSineTable
        (fn_body UMath.f_mtxf_rotate_zxy_and_translate) = true /\
      calls_ident_s USurface._obj_build_transform_from_pos_and_angle
        (fn_body USurface.f_transform_object_vertices) = true /\
      calls_ident_s USurface._obj_apply_scale_to_matrix
        (fn_body USurface.f_transform_object_vertices) = true /\
      statement_mentions_ident_s USurface._normal
        (fn_body USurface.f_read_surface_data) = true /\
      statement_mentions_ident_s USurfaceQuery._originOffset
        (fn_body USurfaceQuery.f_find_floor_from_list) = true /\
      statement_mentions_ident_s USurfaceQuery._originOffset
        (fn_body USurfaceQuery.f_find_ceil_from_list) = true
  | VersionJP =>
      statement_mentions_ident_s JMath._gSineTable
        (fn_body JMath.f_mtxf_rotate_zxy_and_translate) = true /\
      calls_ident_s JSurface._obj_build_transform_from_pos_and_angle
        (fn_body JSurface.f_transform_object_vertices) = true /\
      calls_ident_s JSurface._obj_apply_scale_to_matrix
        (fn_body JSurface.f_transform_object_vertices) = true /\
      statement_mentions_ident_s JSurface._normal
        (fn_body JSurface.f_read_surface_data) = true /\
      statement_mentions_ident_s JSurfaceQuery._originOffset
        (fn_body JSurfaceQuery.f_find_floor_from_list) = true /\
      statement_mentions_ident_s JSurfaceQuery._originOffset
        (fn_body JSurfaceQuery.f_find_ceil_from_list) = true
  end.

Theorem ttc_geometry_source_receipt_supported :
  forall version, ttc_geometry_source_receipt version.
Proof. intros []; vm_compute; repeat split. Qed.

Record vec3z := Vec3Z { vx : Z; vy : Z; vz : Z }.

Definition collision_words (version : GameVersion) : list Z :=
  match version with
  | VersionUS => init_int16_values
      (gvar_init UCollisionGeometry.v_ttc_seg7_collision_rotating_clock_platform2)
  | VersionJP => init_int16_values
      (gvar_init JCollisionGeometry.v_ttc_seg7_collision_rotating_clock_platform2)
  end.

Definition sine_values (version : GameVersion) : list float32 :=
  match version with
  | VersionUS => init_float32_values (gvar_init UMath.v_gSineTable)
  | VersionJP => init_float32_values (gvar_init JMath.v_gSineTable)
  end.

Definition macro_words (version : GameVersion) : list Z :=
  match version with
  | VersionUS => init_int16_values (gvar_init UMacroGeometry.v_ttc_seg7_macro_objs)
  | VersionJP => init_int16_values (gvar_init JMacroGeometry.v_ttc_seg7_macro_objs)
  end.

Definition collision_vertex (words : list Z) (index : nat) : vec3z :=
  Vec3Z (nth (2 + 3 * index)%nat words 0)
        (nth (3 + 3 * index)%nat words 0)
        (nth (4 + 3 * index)%nat words 0).

Definition spinner_records (version : GameVersion) : list (list Z) :=
  filter (record_low9_is 356) (chunks5 (macro_words version)).

Definition spinner_yaw (record : list Z) : Z :=
  Z.land (Z.land (nth 0 record 0) 65535) 65024.
Definition spinner_x (record : list Z) : Z := nth 1 record 0.
Definition spinner_y (record : list Z) : Z := nth 2 record 0.
Definition spinner_z (record : list Z) : Z := nth 3 record 0.

Definition table_value (table : list float32) (index : Z) : float32 :=
  nth (Z.to_nat index) table Float32.zero.

Definition f32_of_z (value : Z) : float32 :=
  Float32.of_int (Int.repr value).

Definition terrain_cast (value : float32) : Z :=
  match Float32.to_int value with
  | Some word => Int.signed (Int.sign_ext 16 word)
  | None => 0
  end.

Definition f32_sum4 (a b c d : float32) : float32 :=
  Float32.add (Float32.add (Float32.add a b) c) d.

(** Unit-scale specialization of the generated Z-X-Y transform.  The order of
    every [Float32.mul]/[Float32.add] mirrors the left-associated C expressions
    in [mtxf_rotate_zxy_and_translate] and [transform_object_vertices]. *)
Definition transform_vertex
    (version : GameVersion) (pitch_index : Z)
    (spinner : list Z) (vertex : vec3z) : vec3z :=
  let table := sine_values version in
  let yaw_index := Z.shiftr (spinner_yaw spinner) 4 in
  let sx := table_value table pitch_index in
  let cx := table_value table (pitch_index + 1024) in
  let sy := table_value table yaw_index in
  let cy := table_value table (yaw_index + 1024) in
  let sz := table_value table 0 in
  let cz := table_value table 1024 in
  let m00 := Float32.add (Float32.mul cy cz)
      (Float32.mul (Float32.mul sx sy) sz) in
  let m10 := Float32.add (Float32.mul (Float32.neg cy) sz)
      (Float32.mul (Float32.mul sx sy) cz) in
  let m20 := Float32.mul cx sy in
  let m01 := Float32.mul cx sz in
  let m11 := Float32.mul cx cz in
  let m21 := Float32.neg sx in
  let m02 := Float32.add (Float32.mul (Float32.neg sy) cz)
      (Float32.mul (Float32.mul sx cy) sz) in
  let m12 := Float32.add (Float32.mul sy sz)
      (Float32.mul (Float32.mul sx cy) cz) in
  let m22 := Float32.mul cx cy in
  let fx := f32_of_z (vx vertex) in
  let fy := f32_of_z (vy vertex) in
  let fz := f32_of_z (vz vertex) in
  Vec3Z
    (terrain_cast (f32_sum4 (Float32.mul fx m00) (Float32.mul fy m10)
      (Float32.mul fz m20) (f32_of_z (spinner_x spinner))))
    (terrain_cast (f32_sum4 (Float32.mul fx m01) (Float32.mul fy m11)
      (Float32.mul fz m21) (f32_of_z (spinner_y spinner))))
    (terrain_cast (f32_sum4 (Float32.mul fx m02) (Float32.mul fy m12)
      (Float32.mul fz m22) (f32_of_z (spinner_z spinner)))).

Definition transformed_triangle
    (version : GameVersion) (pitch_index : Z)
    (spinner_index triangle_index : nat) : list vec3z :=
  let spinner := nth spinner_index (spinner_records version) [] in
  let words := collision_words version in
  let triangle_offset := (64 + 3 * triangle_index)%nat in
  let indices :=
    [Z.to_nat (nth triangle_offset words 0);
     Z.to_nat (nth (triangle_offset + 1)%nat words 0);
     Z.to_nat (nth (triangle_offset + 2)%nat words 0)] in
  map (fun index => transform_vertex version pitch_index spinner
    (collision_vertex words index)) indices.

Definition collision_layout_certificate (version : GameVersion) : bool :=
  let words := collision_words version in
  (nth 0 words 0 =? 64) &&
  (nth 1 words 0 =? 20) &&
  (nth 62 words 0 =? 0) &&
  (nth 63 words 0 =? 26).

Definition cross_normal (triangle : list vec3z) : vec3z :=
  match triangle with
  | a :: b :: c :: _ =>
      Vec3Z
        ((vy b - vy a) * (vz c - vz b) - (vz b - vz a) * (vy c - vy b))
        ((vz b - vz a) * (vx c - vx b) - (vx b - vx a) * (vz c - vz b))
        ((vx b - vx a) * (vy c - vy b) - (vy b - vy a) * (vx c - vx b))
  | _ => Vec3Z 0 0 0
  end.

Record surface_plane := SurfacePlane {
  plane_nx : float32;
  plane_ny : float32;
  plane_nz : float32;
  plane_origin_offset : float32;
  plane_magnitude : float32
}.

Definition f64_one : float := Float.of_int (Int.repr 1).
Definition f64_partition_threshold : float :=
  Float.of_bits (Int64.repr 4576918229304087675).
Definition f64_degenerate_threshold : float :=
  Float.of_bits (Int64.repr 4547007122018943789).

Definition make_surface_plane (triangle : list vec3z) : surface_plane :=
  let raw := cross_normal triangle in
  let nx0 := f32_of_z (vx raw) in
  let ny0 := f32_of_z (vy raw) in
  let nz0 := f32_of_z (vz raw) in
  let magnitude := Float32.sqrt
    (Float32.add (Float32.add (Float32.mul nx0 nx0) (Float32.mul ny0 ny0))
      (Float32.mul nz0 nz0)) in
  let inverse_magnitude := Float32.of_double
    (Float.div f64_one (Float32.to_double magnitude)) in
  let nx := Float32.mul nx0 inverse_magnitude in
  let ny := Float32.mul ny0 inverse_magnitude in
  let nz := Float32.mul nz0 inverse_magnitude in
  let origin :=
    match triangle with
    | first :: _ =>
        Float32.neg
          (Float32.add
            (Float32.add (Float32.mul nx (f32_of_z (vx first)))
              (Float32.mul ny (f32_of_z (vy first))))
            (Float32.mul nz (f32_of_z (vz first))))
    | [] => Float32.zero
    end in
  SurfacePlane nx ny nz origin magnitude.

Definition surface_nondegenerateb (plane : surface_plane) : bool :=
  negb (Float.cmp Clt (Float32.to_double (plane_magnitude plane))
    f64_degenerate_threshold).

Definition floor_partitionb (plane : surface_plane) : bool :=
  Float.cmp Clt f64_partition_threshold (Float32.to_double (plane_ny plane)).

Definition ceiling_partitionb (plane : surface_plane) : bool :=
  Float.cmp Clt (Float32.to_double (plane_ny plane))
    (Float.neg f64_partition_threshold).

Definition edge_xz (a b : vec3z) (x z : Z) : Z :=
  (vx b - vx a) * (z - vz a) - (vz b - vz a) * (x - vx a).

Definition strictly_inside_xzb (triangle : list vec3z) (x z : Z) : bool :=
  match triangle with
  | a :: b :: c :: _ =>
      let ab := edge_xz a b x z in
      let bc := edge_xz b c x z in
      let ca := edge_xz c a x z in
      ((ab <? 0) && (bc <? 0) && (ca <? 0)) ||
      ((0 <? ab) && (0 <? bc) && (0 <? ca))
  | _ => false
  end.

Definition floor_strictly_contains_xzb
    (triangle : list vec3z) (x z : Z) : bool :=
  match triangle with
  | a :: b :: c :: _ =>
      (edge_xz a b x z <? 0) && (edge_xz b c x z <? 0) &&
      (edge_xz c a x z <? 0)
  | _ => false
  end.

Definition ceiling_strictly_contains_xzb
    (triangle : list vec3z) (x z : Z) : bool :=
  match triangle with
  | a :: b :: c :: _ =>
      (0 <? edge_xz a b x z) && (0 <? edge_xz b c x z) &&
      (0 <? edge_xz c a x z)
  | _ => false
  end.

Definition surface_height (plane : surface_plane) (x z : Z) : float32 :=
  Float32.div
    (Float32.neg
      (Float32.add
        (Float32.add (Float32.mul (f32_of_z x) (plane_nx plane))
          (Float32.mul (plane_nz plane) (f32_of_z z)))
        (plane_origin_offset plane)))
    (plane_ny plane).

Definition gap_in_pedro_rangeb
    (floor ceiling : surface_plane) (x z : Z) : bool :=
  let gap := Float32.sub (surface_height ceiling x z)
    (surface_height floor x z) in
  Float32.cmp Clt Float32.zero gap &&
  Float32.cmp Cle gap (f32_of_z 160).

Definition spinner_geometry_certificate
    (version : GameVersion) (pitch_index : Z) : bool :=
  let floor := transformed_triangle version pitch_index 7 12 in
  let ceiling := transformed_triangle version pitch_index 0 4 in
  let floor_plane := make_surface_plane floor in
  let ceiling_plane := make_surface_plane ceiling in
  collision_layout_certificate version &&
  surface_nondegenerateb floor_plane &&
  surface_nondegenerateb ceiling_plane &&
  floor_partitionb floor_plane &&
  ceiling_partitionb ceiling_plane &&
  floor_strictly_contains_xzb floor 1045 1603 &&
  ceiling_strictly_contains_xzb ceiling 1045 1603 &&
  gap_in_pedro_rangeb floor_plane ceiling_plane 1045 1603.

Theorem spinner_geometry_inputs_match_us_jp :
  collision_words VersionUS = collision_words VersionJP /\
  macro_words VersionUS = macro_words VersionJP /\
  sine_values VersionUS = sine_values VersionJP.
Proof. vm_compute; repeat split; reflexivity. Qed.

Theorem ttc_spinner_pitch_table_interval_certificate :
  forall version pitch_index,
    979 <= pitch_index <= 1001 ->
    spinner_geometry_certificate version pitch_index = true.
Proof.
  intros version pitch_index Hrange.
  assert (
    pitch_index = 979 \/
      pitch_index = 980 \/
      pitch_index = 981 \/
      pitch_index = 982 \/
      pitch_index = 983 \/
      pitch_index = 984 \/
      pitch_index = 985 \/
      pitch_index = 986 \/
      pitch_index = 987 \/
      pitch_index = 988 \/
      pitch_index = 989 \/
      pitch_index = 990 \/
      pitch_index = 991 \/
      pitch_index = 992 \/
      pitch_index = 993 \/
      pitch_index = 994 \/
      pitch_index = 995 \/
      pitch_index = 996 \/
      pitch_index = 997 \/
      pitch_index = 998 \/
      pitch_index = 999 \/
      pitch_index = 1000 \/
      pitch_index = 1001) as Hcases by lia.
  destruct version;
    destruct Hcases as [-> | [-> | [-> | [-> | [-> | [-> | [-> | [-> | [-> | [-> | [-> | [-> | [-> | [-> | [-> | [-> | [-> | [-> | [-> | [-> | [-> | [-> | ->]]]]]]]]]]]]]]]]]]]]]];
    vm_compute; reflexivity.
Qed.

Definition pitch_table_index (pitch : Z) : Z :=
  Z.shiftr (Z.land pitch 65535) 4.

Theorem full_pitch_interval_uses_certified_entries :
  forall pitch,
    15664 <= pitch <= 16031 ->
    979 <= pitch_table_index pitch <= 1001.
Proof.
  intros pitch Hrange.
  unfold pitch_table_index.
  change (979 <= Z.shiftr (Z.land pitch (Z.ones 16)) 4 <= 1001).
  rewrite Z.land_ones by lia.
  rewrite Z.mod_small by lia.
  rewrite Z.shiftr_div_pow2 by lia.
  change (979 <= pitch / 16 <= 1001).
  split.
  - apply Z.div_le_lower_bound; lia.
  - assert (pitch / 16 < 1002).
    { apply Z.div_lt_upper_bound; lia. }
    lia.
Qed.

Theorem concrete_ttc_spinner_pitch_interval :
  forall version pitch,
    15664 <= pitch <= 16031 ->
    spinner_geometry_certificate version (pitch_table_index pitch) = true.
Proof.
  intros version pitch Hrange.
  apply ttc_spinner_pitch_table_interval_certificate.
  exact (full_pitch_interval_uses_certified_entries pitch Hrange).
Qed.
