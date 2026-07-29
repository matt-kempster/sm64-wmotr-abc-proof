(* Checked inventory facts for the generated SSL collision-data wrapper.

   The arrays are imported as CompCert global initializers.  These facts
   establish coverage and version identity only; they are not a connected
   components theorem and do not prove Mario reachability or non-reachability.
*)

From Coq Require Import List ZArith Lia.
From compcert Require Import AST.
From LessThanOneAPress.Generated Require Import
  us_ssl_collision jp_ssl_collision.
From LessThanOneAPress.Proofs Require Import ASTFacts.

Import ListNotations.
Local Open Scope Z_scope.

Definition collision_word_count {V : Type} (variable : globvar V) : nat :=
  length (gvar_init variable).

Theorem ssl_collision_array_word_counts_us :
  collision_word_count us_ssl_collision.v_ssl_seg7_area_1_collision =
    4945%nat /\
  collision_word_count us_ssl_collision.v_ssl_seg7_collision_pyramid_top =
    39%nat /\
  collision_word_count us_ssl_collision.v_ssl_seg7_collision_tox_box =
    138%nat /\
  collision_word_count
    us_ssl_collision.v_breakable_box_seg8_collision_08012D70 = 66%nat /\
  collision_word_count
    us_ssl_collision.v_exclamation_box_outline_seg8_collision_08025F78 =
      66%nat /\
  collision_word_count
    us_ssl_collision.v_cannon_lid_seg8_collision_08004950 = 24%nat /\
  collision_word_count
    us_ssl_collision.v_wooden_signpost_seg3_collision_0302DD80 = 66%nat /\
  collision_word_count us_ssl_collision.v_ssl_seg7_area_2_collision =
    8098%nat /\
  collision_word_count us_ssl_collision.v_ssl_seg7_area_3_collision =
    908%nat /\
  collision_word_count us_ssl_collision.v_ssl_seg7_collision_grindel =
    66%nat /\
  collision_word_count us_ssl_collision.v_ssl_seg7_collision_spindel =
    156%nat /\
  collision_word_count us_ssl_collision.v_ssl_seg7_collision_0702808C =
    66%nat /\
  collision_word_count
    us_ssl_collision.v_ssl_seg7_collision_pyramid_elevator = 178%nat /\
  collision_word_count us_ssl_collision.v_ssl_seg7_collision_07028274 =
    66%nat /\
  collision_word_count us_ssl_collision.v_ssl_seg7_collision_070282F8 =
    60%nat /\
  collision_word_count us_ssl_collision.v_ssl_seg7_collision_07028370 =
    159%nat /\
  collision_word_count us_ssl_collision.v_ssl_seg7_collision_070284B0 =
    159%nat.
Proof. vm_compute. repeat split. Qed.

Theorem ssl_collision_array_word_counts_jp :
  collision_word_count jp_ssl_collision.v_ssl_seg7_area_1_collision =
    4945%nat /\
  collision_word_count jp_ssl_collision.v_ssl_seg7_collision_pyramid_top =
    39%nat /\
  collision_word_count jp_ssl_collision.v_ssl_seg7_collision_tox_box =
    138%nat /\
  collision_word_count
    jp_ssl_collision.v_breakable_box_seg8_collision_08012D70 = 66%nat /\
  collision_word_count
    jp_ssl_collision.v_exclamation_box_outline_seg8_collision_08025F78 =
      66%nat /\
  collision_word_count
    jp_ssl_collision.v_cannon_lid_seg8_collision_08004950 = 24%nat /\
  collision_word_count
    jp_ssl_collision.v_wooden_signpost_seg3_collision_0302DD80 = 66%nat /\
  collision_word_count jp_ssl_collision.v_ssl_seg7_area_2_collision =
    8098%nat /\
  collision_word_count jp_ssl_collision.v_ssl_seg7_area_3_collision =
    908%nat /\
  collision_word_count jp_ssl_collision.v_ssl_seg7_collision_grindel =
    66%nat /\
  collision_word_count jp_ssl_collision.v_ssl_seg7_collision_spindel =
    156%nat /\
  collision_word_count jp_ssl_collision.v_ssl_seg7_collision_0702808C =
    66%nat /\
  collision_word_count
    jp_ssl_collision.v_ssl_seg7_collision_pyramid_elevator = 178%nat /\
  collision_word_count jp_ssl_collision.v_ssl_seg7_collision_07028274 =
    66%nat /\
  collision_word_count jp_ssl_collision.v_ssl_seg7_collision_070282F8 =
    60%nat /\
  collision_word_count jp_ssl_collision.v_ssl_seg7_collision_07028370 =
    159%nat /\
  collision_word_count jp_ssl_collision.v_ssl_seg7_collision_070284B0 =
    159%nat.
Proof. vm_compute. repeat split. Qed.

Theorem area1_actor_collision_initializers_are_version_identical :
  gvar_init
    us_ssl_collision.v_breakable_box_seg8_collision_08012D70 =
      gvar_init
        jp_ssl_collision.v_breakable_box_seg8_collision_08012D70 /\
  gvar_init
    us_ssl_collision.v_exclamation_box_outline_seg8_collision_08025F78 =
      gvar_init
        jp_ssl_collision.v_exclamation_box_outline_seg8_collision_08025F78 /\
  gvar_init
    us_ssl_collision.v_cannon_lid_seg8_collision_08004950 =
      gvar_init
        jp_ssl_collision.v_cannon_lid_seg8_collision_08004950 /\
  gvar_init
    us_ssl_collision.v_wooden_signpost_seg3_collision_0302DD80 =
      gvar_init
        jp_ssl_collision.v_wooden_signpost_seg3_collision_0302DD80.
Proof. vm_compute. repeat split. Qed.

(* The geometry wrapper has no version-dependent preprocessing branch in the
   selected US/JP configurations.  Equality is checked over every 16-bit
   initializer word of the route-relevant static and dynamic arrays. *)
Theorem route_collision_initializers_are_version_identical :
  gvar_init us_ssl_collision.v_ssl_seg7_area_2_collision =
    gvar_init jp_ssl_collision.v_ssl_seg7_area_2_collision /\
  gvar_init us_ssl_collision.v_ssl_seg7_area_3_collision =
    gvar_init jp_ssl_collision.v_ssl_seg7_area_3_collision /\
  gvar_init us_ssl_collision.v_ssl_seg7_collision_grindel =
    gvar_init jp_ssl_collision.v_ssl_seg7_collision_grindel /\
  gvar_init us_ssl_collision.v_ssl_seg7_collision_spindel =
    gvar_init jp_ssl_collision.v_ssl_seg7_collision_spindel /\
  gvar_init us_ssl_collision.v_ssl_seg7_collision_0702808C =
    gvar_init jp_ssl_collision.v_ssl_seg7_collision_0702808C /\
  gvar_init us_ssl_collision.v_ssl_seg7_collision_pyramid_elevator =
    gvar_init jp_ssl_collision.v_ssl_seg7_collision_pyramid_elevator /\
  gvar_init us_ssl_collision.v_ssl_seg7_collision_07028274 =
    gvar_init jp_ssl_collision.v_ssl_seg7_collision_07028274 /\
  gvar_init us_ssl_collision.v_ssl_seg7_collision_070282F8 =
    gvar_init jp_ssl_collision.v_ssl_seg7_collision_070282F8 /\
  gvar_init us_ssl_collision.v_ssl_seg7_collision_07028370 =
    gvar_init jp_ssl_collision.v_ssl_seg7_collision_07028370 /\
  gvar_init us_ssl_collision.v_ssl_seg7_collision_070284B0 =
    gvar_init jp_ssl_collision.v_ssl_seg7_collision_070284B0.
Proof. vm_compute. repeat split. Qed.

(* The complete 39-word pyramid-top collision stream is small enough to audit
   exactly.  In particular, the five vertex Y coordinates are
   [-255; -255; -255; 256; -255].  These facts are about the generated
   initializers, not a claim that every transformed dynamic surface has
   already been reconstructed in Clight memory. *)
Definition pyramid_top_collision_words : list Z :=
  [64; 5;
   -511; -255; 512;
   512; -255; -511;
   512; -255; 512;
   0; 256; 0;
   -511; -255; -511;
   53; 6;
   0; 1; 2;
   0; 2; 3;
   2; 1; 3;
   0; 4; 1;
   1; 4; 3;
   4; 0; 3;
   65; 66].

Fixpoint triples_from_words (words : list Z) : list (Z * Z * Z) :=
  match words with
  | x :: y :: z :: rest => (x, y, z) :: triples_from_words rest
  | _ => []
  end.

Definition collision_vertices_from_words
    (vertex_count : nat) (words : list Z) : list (Z * Z * Z) :=
  triples_from_words (firstn (3 * vertex_count) (skipn 2 words)).

Definition pyramid_top_vertices : list (Z * Z * Z) :=
  [(-511, -255, 512);
   (512, -255, -511);
   (512, -255, 512);
   (0, 256, 0);
   (-511, -255, -511)].

Definition pyramid_top_triangles : list (Z * Z * Z) :=
  [(0, 1, 2);
   (0, 2, 3);
   (2, 1, 3);
   (0, 4, 1);
   (1, 4, 3);
   (4, 0, 3)].

Definition pyramid_top_vertices_from_words (words : list Z) :=
  triples_from_words (firstn 15 (skipn 2 words)).

Definition pyramid_top_triangles_from_words (words : list Z) :=
  triples_from_words (firstn 18 (skipn 19 words)).

Theorem pyramid_top_collision_words_exact_us :
  init_int16_values
    (gvar_init us_ssl_collision.v_ssl_seg7_collision_pyramid_top) =
  pyramid_top_collision_words.
Proof. vm_compute. reflexivity. Qed.

Theorem pyramid_top_collision_words_exact_jp :
  init_int16_values
    (gvar_init jp_ssl_collision.v_ssl_seg7_collision_pyramid_top) =
  pyramid_top_collision_words.
Proof. vm_compute. reflexivity. Qed.

Theorem pyramid_top_vertices_exact_us :
  pyramid_top_vertices_from_words
    (init_int16_values
      (gvar_init us_ssl_collision.v_ssl_seg7_collision_pyramid_top)) =
  pyramid_top_vertices.
Proof. rewrite pyramid_top_collision_words_exact_us. reflexivity. Qed.

Theorem pyramid_top_vertices_exact_jp :
  pyramid_top_vertices_from_words
    (init_int16_values
      (gvar_init jp_ssl_collision.v_ssl_seg7_collision_pyramid_top)) =
  pyramid_top_vertices.
Proof. rewrite pyramid_top_collision_words_exact_jp. reflexivity. Qed.

Theorem pyramid_top_triangles_exact_us :
  pyramid_top_triangles_from_words
    (init_int16_values
      (gvar_init us_ssl_collision.v_ssl_seg7_collision_pyramid_top)) =
  pyramid_top_triangles.
Proof. rewrite pyramid_top_collision_words_exact_us. reflexivity. Qed.

Theorem pyramid_top_triangles_exact_jp :
  pyramid_top_triangles_from_words
    (init_int16_values
      (gvar_init jp_ssl_collision.v_ssl_seg7_collision_pyramid_top)) =
  pyramid_top_triangles.
Proof. rewrite pyramid_top_collision_words_exact_jp. reflexivity. Qed.

Definition pyramid_top_source_mesh_claim : Prop :=
  pyramid_top_vertices_from_words
    (init_int16_values
      (gvar_init us_ssl_collision.v_ssl_seg7_collision_pyramid_top)) =
      pyramid_top_vertices /\
  pyramid_top_vertices_from_words
    (init_int16_values
      (gvar_init jp_ssl_collision.v_ssl_seg7_collision_pyramid_top)) =
      pyramid_top_vertices /\
  pyramid_top_triangles_from_words
    (init_int16_values
      (gvar_init us_ssl_collision.v_ssl_seg7_collision_pyramid_top)) =
      pyramid_top_triangles /\
  pyramid_top_triangles_from_words
    (init_int16_values
      (gvar_init jp_ssl_collision.v_ssl_seg7_collision_pyramid_top)) =
      pyramid_top_triangles.

Theorem pyramid_top_source_mesh_checked :
  pyramid_top_source_mesh_claim.
Proof.
  unfold pyramid_top_source_mesh_claim.
  exact
    (conj pyramid_top_vertices_exact_us
      (conj pyramid_top_vertices_exact_jp
        (conj pyramid_top_triangles_exact_us
          pyramid_top_triangles_exact_jp))).
Qed.

Definition vertex_y (vertex : Z * Z * Z) : Z :=
  let '(_, y, _) := vertex in y.

Definition pyramid_top_vertex_y_values : list Z :=
  map vertex_y pyramid_top_vertices.

Theorem pyramid_top_vertex_y_values_extracted :
  map vertex_y pyramid_top_vertices = pyramid_top_vertex_y_values.
Proof. reflexivity. Qed.

Theorem pyramid_top_negative_z_face_is_generated :
  In (1, 4, 3) pyramid_top_triangles.
Proof.
  unfold pyramid_top_triangles.
  right. right. right. right. left. reflexivity.
Qed.

Definition pyramid_top_negative_z_edge_claim
    (triangles vertices : list (Z * Z * Z)) : Prop :=
  In (1, 4, 3) triangles /\
  nth_error vertices 4 = Some (-511, -255, -511) /\
  nth_error vertices 3 = Some (0, 256, 0).

Theorem pyramid_top_negative_z_edge_claim_holds :
  pyramid_top_negative_z_edge_claim
    pyramid_top_triangles pyramid_top_vertices.
Proof.
  unfold pyramid_top_negative_z_edge_claim.
  exact
    (conj pyramid_top_negative_z_face_is_generated
      (conj eq_refl eq_refl)).
Qed.

Definition pyramid_top_source_edge_claim : Prop :=
  pyramid_top_negative_z_edge_claim
    (pyramid_top_triangles_from_words
      (init_int16_values
        (gvar_init us_ssl_collision.v_ssl_seg7_collision_pyramid_top)))
    (pyramid_top_vertices_from_words
      (init_int16_values
        (gvar_init us_ssl_collision.v_ssl_seg7_collision_pyramid_top))) /\
  pyramid_top_negative_z_edge_claim
    (pyramid_top_triangles_from_words
      (init_int16_values
        (gvar_init jp_ssl_collision.v_ssl_seg7_collision_pyramid_top)))
    (pyramid_top_vertices_from_words
      (init_int16_values
        (gvar_init jp_ssl_collision.v_ssl_seg7_collision_pyramid_top))).

Theorem pyramid_top_source_edge_checked :
  pyramid_top_source_edge_claim.
Proof.
  unfold pyramid_top_source_edge_claim.
  rewrite pyramid_top_triangles_exact_us, pyramid_top_vertices_exact_us.
  rewrite pyramid_top_triangles_exact_jp, pyramid_top_vertices_exact_jp.
  exact
    (conj pyramid_top_negative_z_edge_claim_holds
      pyramid_top_negative_z_edge_claim_holds).
Qed.

Theorem pyramid_top_vertex_y_minimum :
  Forall (fun y => -255 <= y) pyramid_top_vertex_y_values /\
  In (-255) pyramid_top_vertex_y_values.
Proof.
  unfold pyramid_top_vertex_y_values, pyramid_top_vertices, vertex_y.
  cbn.
  split.
  - repeat constructor; lia.
  - left; reflexivity.
Qed.

Theorem pyramid_top_home_floor_lower_bound :
  forall local_y,
    In local_y pyramid_top_vertex_y_values ->
    1536 + local_y >= 1281.
Proof.
  intros local_y Hlocal.
  unfold pyramid_top_vertex_y_values, pyramid_top_vertices, vertex_y in Hlocal.
  cbn in Hlocal.
  repeat (destruct Hlocal as [Hlocal | Hlocal];
          [subst local_y; lia |]).
  contradiction.
Qed.

(* Exact local-space bounds for the four stock Area-1 actor collision meshes.
   Each receipt evaluates the vertices directly from the generated CompCert
   initializer, after the COL_INIT and COL_VERTEX_INIT words. *)
Definition vertex_x (vertex : Z * Z * Z) : Z :=
  let '(x, _, _) := vertex in x.

Definition vertex_z (vertex : Z * Z * Z) : Z :=
  let '(_, _, z) := vertex in z.

Definition projected_bounds
    (projection : Z * Z * Z -> Z)
    (vertices : list (Z * Z * Z)) : option (Z * Z) :=
  match vertices with
  | [] => None
  | first :: rest =>
      Some
        (fold_left Z.min (map projection rest) (projection first),
         fold_left Z.max (map projection rest) (projection first))
  end.

Definition collision_vertex_bounds (vertices : list (Z * Z * Z)) :=
  (projected_bounds vertex_x vertices,
   projected_bounds vertex_y vertices,
   projected_bounds vertex_z vertices).

Theorem breakable_box_generated_vertex_bounds_us :
  collision_vertex_bounds
    (collision_vertices_from_words 8
      (init_int16_values
        (gvar_init
          us_ssl_collision.v_breakable_box_seg8_collision_08012D70))) =
  (Some (-100, 100), Some (0, 200), Some (-100, 100)).
Proof. vm_compute. reflexivity. Qed.

Theorem breakable_box_generated_vertex_bounds_jp :
  collision_vertex_bounds
    (collision_vertices_from_words 8
      (init_int16_values
        (gvar_init
          jp_ssl_collision.v_breakable_box_seg8_collision_08012D70))) =
  (Some (-100, 100), Some (0, 200), Some (-100, 100)).
Proof. vm_compute. reflexivity. Qed.

Theorem exclamation_box_generated_vertex_bounds_us :
  collision_vertex_bounds
    (collision_vertices_from_words 8
      (init_int16_values
        (gvar_init
          us_ssl_collision.v_exclamation_box_outline_seg8_collision_08025F78))) =
  (Some (-26, 26), Some (30, 52), Some (-26, 26)).
Proof. vm_compute. reflexivity. Qed.

Theorem exclamation_box_generated_vertex_bounds_jp :
  collision_vertex_bounds
    (collision_vertices_from_words 8
      (init_int16_values
        (gvar_init
          jp_ssl_collision.v_exclamation_box_outline_seg8_collision_08025F78))) =
  (Some (-26, 26), Some (30, 52), Some (-26, 26)).
Proof. vm_compute. reflexivity. Qed.

Theorem cannon_lid_generated_vertex_bounds_us :
  collision_vertex_bounds
    (collision_vertices_from_words 4
      (init_int16_values
        (gvar_init
          us_ssl_collision.v_cannon_lid_seg8_collision_08004950))) =
  (Some (-111, 112), Some (0, 0), Some (-111, 112)).
Proof. vm_compute. reflexivity. Qed.

Theorem cannon_lid_generated_vertex_bounds_jp :
  collision_vertex_bounds
    (collision_vertices_from_words 4
      (init_int16_values
        (gvar_init
          jp_ssl_collision.v_cannon_lid_seg8_collision_08004950))) =
  (Some (-111, 112), Some (0, 0), Some (-111, 112)).
Proof. vm_compute. reflexivity. Qed.

Theorem wooden_signpost_generated_vertex_bounds_us :
  collision_vertex_bounds
    (collision_vertices_from_words 8
      (init_int16_values
        (gvar_init
          us_ssl_collision.v_wooden_signpost_seg3_collision_0302DD80))) =
  (Some (-44, 45), Some (-9, 126), Some (-12, 20)).
Proof. vm_compute. reflexivity. Qed.

Theorem wooden_signpost_generated_vertex_bounds_jp :
  collision_vertex_bounds
    (collision_vertices_from_words 8
      (init_int16_values
        (gvar_init
          jp_ssl_collision.v_wooden_signpost_seg3_collision_0302DD80))) =
  (Some (-44, 45), Some (-9, 126), Some (-12, 20)).
Proof. vm_compute. reflexivity. Qed.

(** * Selected Area-1 upper-warp mesh receipts

    The graphical-position fallback audit uses the local integer point
    [(-2200,768,-1024)].  The vertices below are the nearby pillar and upper
    plateau vertices from the complete generated Area-1 collision stream.
    The raw word slice records the corresponding triangle-index records.

    These are initializer receipts, not a theorem about spatial-partition
    insertion, traversal order, a live dynamic-surface owner, or the result of
    a concrete [find_floor] call. *)

Definition area1_collision_vertex_count : nat := 574.

Definition area1_collision_vertices_from_words (words : list Z) :
    list (Z * Z * Z) :=
  collision_vertices_from_words area1_collision_vertex_count words.

Definition area1_collision_words_us : list Z :=
  init_int16_values
    (gvar_init us_ssl_collision.v_ssl_seg7_area_1_collision).

Definition area1_collision_words_jp : list Z :=
  init_int16_values
    (gvar_init jp_ssl_collision.v_ssl_seg7_area_1_collision).

Definition area1_collision_vertices_us : list (Z * Z * Z) :=
  area1_collision_vertices_from_words area1_collision_words_us.

Definition area1_collision_vertices_jp : list (Z * Z * Z) :=
  area1_collision_vertices_from_words area1_collision_words_jp.

Definition selected_ink_area1_vertex_receipts
    (vertices : list (Z * Z * Z)) : Prop :=
  nth_error vertices 263 = Some (-1945, 1280, -921) /\
  nth_error vertices 265 = Some (-2559, 1280, -511) /\
  nth_error vertices 266 = Some (-2149, 1280, -921) /\
  nth_error vertices 371 = Some (-1945, 1280, -1125) /\
  nth_error vertices 372 = Some (-2149, 1280, -1125) /\
  nth_error vertices 498 = Some (-1945, 768, -921) /\
  nth_error vertices 500 = Some (-1945, 768, -1125) /\
  nth_error vertices 501 = Some (-2149, 768, -1125) /\
  nth_error vertices 502 = Some (-2149, 768, -921).

Theorem area1_collision_vertex_count_exact_us :
  length area1_collision_vertices_us = area1_collision_vertex_count.
Proof. vm_compute. reflexivity. Qed.

Theorem area1_collision_vertex_count_exact_jp :
  length area1_collision_vertices_jp = area1_collision_vertex_count.
Proof. vm_compute. reflexivity. Qed.

Theorem selected_ink_area1_vertex_receipts_exact_us :
  selected_ink_area1_vertex_receipts area1_collision_vertices_us.
Proof. vm_compute. repeat split. Qed.

Theorem selected_ink_area1_vertex_receipts_exact_jp :
  selected_ink_area1_vertex_receipts area1_collision_vertices_jp.
Proof. vm_compute. repeat split. Qed.

Definition selected_ink_area1_triangle_word_slice : list Z :=
  [371; 498; 263;
   371; 500; 498;
   498; 500; 501;
   263; 498; 502;
   372; 501; 500;
   266; 502; 501;
   266; 501; 372;
   498; 501; 502;
   263; 502; 266;
   372; 500; 371].

Theorem selected_ink_area1_triangle_words_exact_us :
  firstn 30 (skipn 3320 area1_collision_words_us) =
    selected_ink_area1_triangle_word_slice.
Proof. vm_compute. reflexivity. Qed.

Theorem selected_ink_area1_triangle_words_exact_jp :
  firstn 30 (skipn 3320 area1_collision_words_jp) =
    selected_ink_area1_triangle_word_slice.
Proof. vm_compute. reflexivity. Qed.

(** Collision-format receipts around the selected Ink diagnostic.

    Decimal [40] is [SURFACE_WALL_MISC], [48] is [SURFACE_HARD], [45] is
    [SURFACE_INSTANT_MOVING_QUICKSAND], and [68] is the water-box marker in
    the pinned source.  The ten-triangle slice above is the tail of the
    58-triangle wall-misc group.  The upper y=1280 face
    [(265,266,372)] is the 56th triangle in the following 288-triangle hard
    group.  These are exact generated-word memberships; interpreting the
    complete stream as live collision lists remains a separate refinement. *)

Definition selected_ink_area1_water_box_word_slice : list Z :=
  [68; 3;
   51; 1024; -7065; 7578; -716; -50;
   52; -3993; -7065; 1024; -4197; -50;
   0; -6911; -7167; -4223; -4607; -127;
   66].

Definition selected_ink_area1_surface_receipts
    (words : list Z) : Prop :=
  firstn 2 (skipn 3174 words) = [40; 58] /\
  firstn 32 (skipn 3320 words) =
    selected_ink_area1_triangle_word_slice ++ [45; 69] /\
  firstn 2 (skipn 3628 words) = [48; 288] /\
  firstn 3 (skipn 3795 words) = [265; 266; 372] /\
  firstn 21 (skipn 4924 words) =
    selected_ink_area1_water_box_word_slice.

Theorem selected_ink_area1_surface_receipts_exact_us :
  selected_ink_area1_surface_receipts area1_collision_words_us.
Proof. vm_compute. repeat split; reflexivity. Qed.

Theorem selected_ink_area1_surface_receipts_exact_jp :
  selected_ink_area1_surface_receipts area1_collision_words_jp.
Proof. vm_compute. repeat split; reflexivity. Qed.

Theorem selected_ink_area1_mesh_is_version_identical :
  area1_collision_vertices_us = area1_collision_vertices_jp /\
  firstn 30 (skipn 3320 area1_collision_words_us) =
    firstn 30 (skipn 3320 area1_collision_words_jp).
Proof. vm_compute. split; reflexivity. Qed.

(** * Selected Area-2 static-mesh receipts

    The generated collision stream begins with [COL_INIT], the declared vertex
    count, and then 1,080 triples.  The following parser reads exactly those
    triples.  The selected indices identify the floor ring around the upper
    pole opening and the lower pole platform used by the route analysis.

    These are raw-initializer receipts only.  They do not prove dynamic surface
    construction, partition insertion or selection by a live collision query.
*)

Definition area2_collision_vertex_count : nat := 1080.

Definition area2_collision_vertices_from_words (words : list Z) :
    list (Z * Z * Z) :=
  collision_vertices_from_words area2_collision_vertex_count words.

Definition area2_collision_vertices_us : list (Z * Z * Z) :=
  area2_collision_vertices_from_words
    (init_int16_values
      (gvar_init us_ssl_collision.v_ssl_seg7_area_2_collision)).

Definition area2_collision_vertices_jp : list (Z * Z * Z) :=
  area2_collision_vertices_from_words
    (init_int16_values
      (gvar_init jp_ssl_collision.v_ssl_seg7_area_2_collision)).

Definition selected_area2_vertex_receipts
    (vertices : list (Z * Z * Z)) : Prop :=
  nth_error vertices 283 = Some (-1535, 3942, 922) /\
  nth_error vertices 284 = Some (1536, 3942, 922) /\
  nth_error vertices 285 = Some (102, 3942, 1434) /\
  nth_error vertices 286 = Some (-101, 3942, 1229) /\
  nth_error vertices 298 = Some (102, 3942, 1229) /\
  nth_error vertices 299 = Some (1536, 3942, 1536) /\
  nth_error vertices 300 = Some (-101, 3942, 1434) /\
  nth_error vertices 301 = Some (-1535, 3942, 1536) /\
  nth_error vertices 593 = Some (-204, 3200, 1536) /\
  nth_error vertices 807 = Some (-204, 3200, 1126) /\
  nth_error vertices 1010 = Some (205, 3200, 1126).

Theorem area2_collision_vertex_count_exact_us :
  length area2_collision_vertices_us = area2_collision_vertex_count.
Proof. vm_compute. reflexivity. Qed.

Theorem area2_collision_vertex_count_exact_jp :
  length area2_collision_vertices_jp = area2_collision_vertex_count.
Proof. vm_compute. reflexivity. Qed.

Theorem selected_area2_vertex_receipts_exact_us :
  selected_area2_vertex_receipts area2_collision_vertices_us.
Proof.
  unfold selected_area2_vertex_receipts.
  vm_compute.
  repeat split.
Qed.

Theorem selected_area2_vertex_receipts_exact_jp :
  selected_area2_vertex_receipts area2_collision_vertices_jp.
Proof.
  unfold selected_area2_vertex_receipts.
  vm_compute.
  repeat split.
Qed.

Theorem area2_collision_vertices_are_version_identical :
  area2_collision_vertices_us = area2_collision_vertices_jp.
Proof. vm_compute. reflexivity. Qed.

(** * Pyramid-elevator local mesh

    This list is the complete 20-vertex prefix declared by the generated
    pyramid-elevator collision initializer.  In particular, indices [0..3]
    form the local-Y-zero base floor, while indices [4..11] are the inner and
    outer vertices of the local-Y-256 upper rim.  The statements remain about
    source mesh data, not transformed live surfaces.
*)

Definition pyramid_elevator_vertices : list (Z * Z * Z) :=
  [(-511, 0, 512);
   (512, 0, 512);
   (512, 0, -511);
   (-511, 0, -511);
   (512, 256, -511);
   (461, 256, 461);
   (512, 256, 512);
   (-460, 256, 461);
   (-511, 256, 512);
   (-511, 256, -511);
   (461, 256, -460);
   (-460, 256, -460);
   (461, 0, 461);
   (-460, 0, 461);
   (461, 0, -460);
   (-460, 0, -460);
   (-511, -50, -511);
   (512, -50, -511);
   (512, -50, 512);
   (-511, -50, 512)].

Definition pyramid_elevator_vertices_from_words (words : list Z) :
    list (Z * Z * Z) :=
  collision_vertices_from_words 20 words.

Definition pyramid_elevator_vertices_us : list (Z * Z * Z) :=
  pyramid_elevator_vertices_from_words
    (init_int16_values
      (gvar_init
        us_ssl_collision.v_ssl_seg7_collision_pyramid_elevator)).

Definition pyramid_elevator_vertices_jp : list (Z * Z * Z) :=
  pyramid_elevator_vertices_from_words
    (init_int16_values
      (gvar_init
        jp_ssl_collision.v_ssl_seg7_collision_pyramid_elevator)).

Theorem pyramid_elevator_vertices_exact_us :
  pyramid_elevator_vertices_us = pyramid_elevator_vertices.
Proof. vm_compute. reflexivity. Qed.

Theorem pyramid_elevator_vertices_exact_jp :
  pyramid_elevator_vertices_jp = pyramid_elevator_vertices.
Proof. vm_compute. reflexivity. Qed.

Theorem pyramid_elevator_vertices_are_version_identical :
  pyramid_elevator_vertices_us = pyramid_elevator_vertices_jp.
Proof. vm_compute. reflexivity. Qed.

Definition pyramid_elevator_base_floor_vertices :
    list (Z * Z * Z) :=
  firstn 4 pyramid_elevator_vertices.

Definition pyramid_elevator_upper_rim_vertices :
    list (Z * Z * Z) :=
  firstn 8 (skipn 4 pyramid_elevator_vertices).

Theorem pyramid_elevator_base_floor_local_y_is_zero :
  Forall
    (fun vertex => vertex_y vertex = 0)
    pyramid_elevator_base_floor_vertices.
Proof.
  vm_compute.
  repeat constructor.
Qed.

Theorem pyramid_elevator_upper_rim_local_y_is_256 :
  Forall
    (fun vertex => vertex_y vertex = 256)
    pyramid_elevator_upper_rim_vertices.
Proof.
  vm_compute.
  repeat constructor.
Qed.

Theorem pyramid_elevator_generated_vertex_bounds :
  collision_vertex_bounds pyramid_elevator_vertices =
  (Some (-511, 512), Some (-50, 256), Some (-511, 512)).
Proof. vm_compute. reflexivity. Qed.
