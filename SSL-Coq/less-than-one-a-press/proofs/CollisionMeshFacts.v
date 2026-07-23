(* Checked inventory facts for the generated SSL collision-data wrapper.

   The arrays are imported as CompCert global initializers.  These facts
   establish coverage and version identity only; they are not a connected
   components theorem and do not prove Mario reachability or non-reachability.
*)

From Coq Require Import List.
From compcert Require Import AST.
From LessThanOneAPress.Generated Require Import
  us_ssl_collision jp_ssl_collision.

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
