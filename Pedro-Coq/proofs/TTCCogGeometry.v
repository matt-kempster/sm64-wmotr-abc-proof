From Coq Require Import Bool List ZArith.
From compcert Require Import AST Clight Floats Integers.
From Pedro.Generated Require Import
  us_ttc_cog_collision jp_ttc_cog_collision
  us_obj_behaviors_2 jp_obj_behaviors_2
  us_behavior_data jp_behavior_data
  us_macro_special_objects jp_macro_special_objects.
From Pedro.Proofs Require Import ASTFacts GameTypes TTCSpinnerGeometry DustPRNG.

Import ListNotations.
Open Scope Z_scope.

Module UCog := us_obj_behaviors_2.
Module JCog := jp_obj_behaviors_2.
Module UCogCollision := us_ttc_cog_collision.
Module JCogCollision := jp_ttc_cog_collision.

Definition cog_hexagon_words (version : GameVersion) : list Z :=
  init_int16_values (gvar_init
    (match version with
     | VersionUS => UCogCollision.v_ttc_seg7_collision_07015584
     | VersionJP => JCogCollision.v_ttc_seg7_collision_07015584
     end)).

Definition cog_triangle_words (version : GameVersion) : list Z :=
  init_int16_values (gvar_init
    (match version with
     | VersionUS => UCogCollision.v_ttc_seg7_collision_07015650
     | VersionJP => JCogCollision.v_ttc_seg7_collision_07015650
     end)).

Definition cog_records (version : GameVersion) : list (list Z) :=
  filter (fun record => record_low9_is 350 record || record_low9_is 351 record)
    (chunks5 (macro_words version)).

Definition cog_inventory : list (list Z) :=
  [[350; 1490; -2088; -873; 0];
   [350; -708; -1606; -1589; 0];
   [350; 954; -1627; -1448; 0];
   [350; 1215; -1781; -1215; 0];
   [350; 1052; -1934; -769; 0];
   [-24225; -620; 1229; 1233; 0];
   [-7841; 1050; -19; -1037; 0];
   [350; -1020; 1229; 537; 0]].

Definition cog_source_receipt (version : GameVersion) : Prop :=
  cog_records version = cog_inventory /\
  length (cog_hexagon_words version) = 102%nat /\
  length (cog_triangle_words version) = 129%nat /\
  firstn 2 (cog_hexagon_words version) = [64; 12] /\
  firstn 2 (skipn 38 (cog_hexagon_words version)) = [21; 20] /\
  firstn 2 (cog_triangle_words version) = [64; 15] /\
  firstn 2 (skipn 47 (cog_triangle_words version)) = [21; 26] /\
  gvar_init
    (match version with
     | VersionUS => us_behavior_data.v_bhvTTCCog
     | VersionJP => jp_behavior_data.v_bhvTTCCog end) =
    [Init_int32 (Int.repr 589824);
     Init_int32 (Int.repr 285278273);
     Init_int32 (Int.repr 239272336);
     Init_int32 (Int.repr 201326592);
     Init_addrof us_behavior_data._bhv_ttc_cog_init Ptrofs.zero;
     Init_int32 (Int.repr 134217728);
     Init_int32 (Int.repr 201326592);
     Init_addrof us_behavior_data._bhv_ttc_cog_update Ptrofs.zero;
     Init_int32 (Int.repr 201326592);
     Init_addrof us_behavior_data._load_object_collision_model Ptrofs.zero;
     Init_int32 (Int.repr 150994944)] /\
  firstn 6 (skipn (319 * 3)
    (gvar_init (match version with
      | VersionUS => us_macro_special_objects.v_sMacroObjectPresets
      | VersionJP => jp_macro_special_objects.v_sMacroObjectPresets end))) =
    [Init_addrof us_macro_special_objects._bhvTTCCog Ptrofs.zero;
     Init_int16 (Int.repr 60); Init_int16 Int.zero;
     Init_addrof us_macro_special_objects._bhvTTCCog Ptrofs.zero;
     Init_int16 (Int.repr 61); Init_int16 (Int.repr 2)].

Theorem cog_source_receipt_supported :
  forall version, cog_source_receipt version.
Proof. intros []; vm_compute; repeat split; reflexivity. Qed.

Theorem cog_geometry_inputs_match_us_jp :
  cog_hexagon_words VersionUS = cog_hexagon_words VersionJP /\
  cog_triangle_words VersionUS = cog_triangle_words VersionJP /\
  cog_records VersionUS = cog_records VersionJP /\
  sine_values VersionUS = sine_values VersionJP.
Proof.
  split; [reflexivity |].
  split; [reflexivity |].
  split.
  - transitivity cog_inventory.
    + exact (proj1 (cog_source_receipt_supported VersionUS)).
    + symmetry. exact (proj1 (cog_source_receipt_supported VersionJP)).
  - exact (proj2 (proj2 spinner_geometry_inputs_match_us_jp)).
Qed.

(** Unit-scale, zero-pitch/roll specialization of the generated Z-X-Y matrix
    and left-associated vertex transform. The existing geometry source receipt
    is retained at the capstone. This is an executable projection, not an
    execution proof of transform_object_vertices or surface insertion. *)
Definition transform_cog_vertex (version : GameVersion) (yaw : Z)
    (record : list Z) (vertex : vec3z) : vec3z :=
  let table := sine_values version in
  let index := Z.shiftr (Z.land yaw 65535) 4 in
  let sy := table_value table index in
  let cy := table_value table (index + 1024) in
  let x := f32_of_z (vx vertex) in
  let y := f32_of_z (vy vertex) in
  let z := f32_of_z (vz vertex) in
  Vec3Z
    (terrain_cast (f32_sum4 (Float32.mul x cy)
      (Float32.mul y Float32.zero) (Float32.mul z sy)
      (f32_of_z (nth 1 record 0))))
    (terrain_cast (f32_sum4 (Float32.mul x Float32.zero)
      (Float32.mul y (f32_of_z 1)) (Float32.mul z (Float32.neg Float32.zero))
      (f32_of_z (nth 2 record 0))))
    (terrain_cast (f32_sum4 (Float32.mul x (Float32.neg sy))
      (Float32.mul y Float32.zero) (Float32.mul z cy)
      (f32_of_z (nth 3 record 0)))).

Definition cog_hexagon_triangle (version : GameVersion) (yaw : Z)
    (cog_index triangle_index : nat) : list vec3z :=
  let record := nth cog_index (cog_records version) [] in
  let words := cog_hexagon_words version in
  let offset := (40 + 3 * triangle_index)%nat in
  map (fun i => transform_cog_vertex version yaw record
    (collision_vertex words (Z.to_nat (nth i words 0))))
    [offset; (offset + 1)%nat; (offset + 2)%nat].

Definition cog_witness_floor (version : GameVersion) : list vec3z :=
  cog_hexagon_triangle version 57344 0 0.
Definition cog_witness_ceiling (version : GameVersion) : list vec3z :=
  cog_hexagon_triangle version 0 3 10.

Theorem concrete_cog_triangle_vertices :
  forall version,
    cog_witness_floor version =
      [Vec3Z 1569 (-2088) (-1168); Vec3Z 1273 (-2088) (-1089);
       Vec3Z 1193 (-2088) (-793)] /\
    cog_witness_ceiling version =
      [Vec3Z 1062 (-1934) (-949); Vec3Z 1522 (-1934) (-1215);
       Vec3Z 1369 (-1934) (-949)].
Proof. intros []; vm_compute; split; reflexivity. Qed.

(** Actual vec3f_find_ceil queries at floorHeight+80, followed by find_ceil's
    s16 coordinate cast and its 78-unit tolerance. Positive gap alone does not
    imply this check passes: the adjacent 0/1-unit staircase gaps fail it. *)
Definition cog_ceiling_buffer_acceptsb (floor ceiling : float32) : bool :=
  Float32.cmp Cle
    (f32_of_z (terrain_cast (Float32.add floor (f32_of_z 80))))
    (Float32.add ceiling (f32_of_z 78)).

Definition cog_within_collision_distanceb (record : list Z) : bool :=
  let dx := 1330 - nth 1 record 0 in
  let dy := -2088 - nth 2 record 0 in
  let dz := -1025 - nth 3 record 0 in
  dx * dx + dy * dy + dz * dz <? 400 * 400.

Definition cog_pair_geometry_certificate (version : GameVersion) : bool :=
  let floor := cog_witness_floor version in
  let ceiling := cog_witness_ceiling version in
  let fp := make_surface_plane floor in
  let cp := make_surface_plane ceiling in
  let fh := surface_height fp 1330 (-1025) in
  let ch := surface_height cp 1330 (-1025) in
  surface_nondegenerateb fp && surface_nondegenerateb cp &&
  floor_partitionb fp && ceiling_partitionb cp &&
  floor_strictly_contains_xzb floor 1330 (-1025) &&
  ceiling_strictly_contains_xzb ceiling 1330 (-1025) &&
  gap_in_pedro_rangeb fp cp 1330 (-1025) &&
  cog_ceiling_buffer_acceptsb fh ch &&
  cog_within_collision_distanceb (nth 0 (cog_records version) []) &&
  cog_within_collision_distanceb (nth 3 (cog_records version) []).

Theorem concrete_cog_pair_geometry :
  forall version, cog_pair_geometry_certificate version = true.
Proof.
  intro version; unfold cog_pair_geometry_certificate.
  destruct (concrete_cog_triangle_vertices version) as [Hfloor Hceil].
  rewrite Hfloor, Hceil.
  destruct version; vm_compute; reflexivity.
Qed.

Theorem nominal_one_unit_cog_gap_fails_ceiling_query :
  cog_ceiling_buffer_acceptsb (f32_of_z (-2088)) (f32_of_z (-2087)) = false.
Proof. vm_compute; reflexivity. Qed.

(** This capstone-level proposition deliberately describes pairwise geometry,
    not a reached Mario state or the winner of the complete collision search. *)
Definition ttc_cog_geometry_reduction_claim : Prop :=
  forall version,
    cog_source_receipt version /\
    ttc_geometry_source_receipt version /\
    dust_prng_source_receipt version /\
    cog_pair_geometry_certificate version = true.

Theorem checked_ttc_cog_geometry_reduction_us_jp :
  ttc_cog_geometry_reduction_claim.
Proof.
  intro version.
  exact (conj (cog_source_receipt_supported version)
    (conj (ttc_geometry_source_receipt_supported version)
      (conj (dust_prng_source_receipt_supported version)
        (concrete_cog_pair_geometry version)))).
Qed.
