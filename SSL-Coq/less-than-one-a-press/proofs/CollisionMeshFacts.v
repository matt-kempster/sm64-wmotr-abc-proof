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
