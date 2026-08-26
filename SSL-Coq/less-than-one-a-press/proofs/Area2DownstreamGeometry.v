(** Exact Area-2 target geometry and initializer support receipts.

    The generated initializers establish the source records and exact static
    support triangles for the Act-3 star and all five Act-6 triggers.  These
    are topology and binary32-region facts, not executable continuations from
    either entrance cut. *)

From Coq Require Import Bool Lia List ZArith.
From compcert Require Import AST Floats Integers.
From LessThanOneAPress.Generated Require Import
  us_ssl_area2_macro jp_ssl_area2_macro
  us_ssl_collision jp_ssl_collision.
From LessThanOneAPress.Proofs Require Import
  GameTypes CollisionRegions ASTFacts ClightFacts CollisionMeshFacts
  PyramidTopPU.

Import ListNotations.
Local Open Scope Z_scope.

(** * Source-order target records *)

Definition hidden_trigger_source_record (trigger : HiddenTrigger) : list Z :=
  match trigger with
  | TriggerLowerWest => [45; -260; 2940; -600; 0]
  | TriggerLowerEast => [45; 260; 1967; -600; 0]
  | TriggerMiddleWest => [45; -1940; 1229; -600; 0]
  | TriggerMiddleNorth => [45; -1940; 1229; 2320; 0]
  | TriggerUpper => [45; 260; 3913; -600; 0]
  end.

Theorem hidden_trigger_source_order_is_exact :
  map hidden_trigger_source_record all_hidden_triggers =
    expected_hidden_triggers.
Proof. reflexivity. Qed.

Theorem hidden_trigger_source_records_are_exact_in_us_and_jp :
  records_with_tag 45
      (gvar_init us_ssl_area2_macro.v_ssl_seg7_area_2_macro_objs) =
      map hidden_trigger_source_record all_hidden_triggers /\
  records_with_tag 45
      (gvar_init jp_ssl_area2_macro.v_ssl_seg7_area_2_macro_objs) =
      map hidden_trigger_source_record all_hidden_triggers.
Proof.
  rewrite hidden_trigger_source_order_is_exact.
  exact (conj ssl_area2_hidden_triggers_exact_us
    ssl_area2_hidden_triggers_exact_jp).
Qed.

Theorem modeled_target_hitbox_bits_are_exact :
  Float32.to_bits (hitbox_radius collect_star_hitbox) =
      Int.repr 1117782016 /\
  Float32.to_bits (hitbox_height collect_star_hitbox) =
      Int.repr 1112014848 /\
  Float32.to_bits (hitbox_down_offset collect_star_hitbox) = Int.zero /\
  Float32.to_bits (hitbox_radius hidden_trigger_hitbox) =
      Int.repr 1120403456 /\
  Float32.to_bits (hitbox_height hidden_trigger_hitbox) =
      Int.repr 1120403456 /\
  Float32.to_bits (hitbox_down_offset hidden_trigger_hitbox) = Int.zero.
Proof. vm_compute. repeat split; reflexivity. Qed.

(** * Exact static support receipts

    Surface ordinals count triangles in source order.  They are stable names
    for this initializer audit, not pointers to live [Surface] records. *)

Definition area2_collision_words_us : list Z :=
  init_int16_values
    (gvar_init us_ssl_collision.v_ssl_seg7_area_2_collision).

Definition area2_collision_words_jp : list Z :=
  init_int16_values
    (gvar_init jp_ssl_collision.v_ssl_seg7_area_2_collision).

Lemma area2_collision_words_are_version_identical :
  area2_collision_words_us = area2_collision_words_jp.
Proof.
  unfold area2_collision_words_us, area2_collision_words_jp.
  pose proof (proj1 route_collision_initializers_are_version_identical)
    as Hequal.
  now rewrite Hequal.
Qed.

(** The indices supplied to [select_indexed_from] are strictly increasing.
    It consumes each skipped prefix once and stops at the last requested
    index.  This avoids independent reductions of the generated initializer
    while retaining each source index in the checked result. *)
Fixpoint select_indexed_from {A : Type}
    (cursor : nat) (wanted : list nat) (values : list A)
    : list (nat * A) :=
  match wanted with
  | [] => []
  | wanted_index :: wanted_rest =>
      match skipn (wanted_index - cursor) values with
      | [] => []
      | value :: values_rest =>
          (wanted_index, value) ::
            select_indexed_from (S wanted_index) wanted_rest values_rest
      end
  end.

Definition select_indexed {A : Type}
    (wanted : list nat) (values : list A) : list (nat * A) :=
  select_indexed_from 0 wanted values.

Definition downstream_support_vertex_indices : list nat :=
  [226; 227; 228; 236; 237; 238; 266; 267; 269; 778;
   779; 783; 784; 786; 789; 791; 794; 997]%nat.

Definition downstream_support_expected_vertices :
    list (nat * (Z * Z * Z)) :=
  [(226%nat, (-1740, 1229, 2150));
   (227%nat, (1178, 1229, 2150));
   (228%nat, (-1740, 1229, -588));
   (236%nat, (-2149, 1229, 2560));
   (237%nat, (1178, 1229, 2560));
   (238%nat, (-2149, 1229, -793));
   (266%nat, (387, 4815, -409));
   (267%nat, (643, 4815, -1125));
   (269%nat, (643, 4815, -409));
   (778%nat, (131, 1967, -716));
   (779%nat, (131, 1967, -460));
   (783%nat, (387, 1967, -716));
   (784%nat, (-384, 2940, -716));
   (786%nat, (-384, 2940, -460));
   (789%nat, (-128, 2940, -716));
   (791%nat, (131, 3913, -460));
   (794%nat, (387, 3913, -716));
   (997%nat, (131, 3913, -716))].

Definition downstream_support_vertex_receipts
    (vertices : list (Z * Z * Z)) : Prop :=
  select_indexed downstream_support_vertex_indices vertices =
    downstream_support_expected_vertices.

Theorem downstream_support_vertices_exact_us :
  downstream_support_vertex_receipts area2_collision_vertices_us.
Proof. vm_compute. reflexivity. Qed.

Theorem downstream_support_vertices_exact_jp :
  downstream_support_vertex_receipts area2_collision_vertices_jp.
Proof.
  rewrite <- area2_collision_vertices_are_version_identical.
  exact downstream_support_vertices_exact_us.
Qed.

(** The offsets below are offsets in the complete 8,098-word generated
    initializer.  Surface type 0 is [SURFACE_DEFAULT], 39 is
    [SURFACE_MOVING_QUICKSAND], and 102 is [SURFACE_CAMERA_FREE_ROAM]. *)
Definition downstream_support_word_offsets : list nat :=
  [3242; 3243;
   5152; 5153; 5154;
   5221; 5222; 5223;
   5251; 5252; 5253;
   7205; 7206;
   7499; 7500; 7501; 7502;
   7503; 7504; 7505; 7506;
   7507; 7508; 7509; 7510;
   7593; 7594;
   7601; 7602; 7603]%nat.

Definition downstream_support_triangle_word_receipts
    (words : list Z) : Prop :=
  select_indexed downstream_support_word_offsets words =
    [(3242%nat, 0); (3243%nat, 1068);
     (5152%nat, 779); (5153%nat, 783); (5154%nat, 778);
     (5221%nat, 786); (5222%nat, 789); (5223%nat, 784);
     (5251%nat, 791); (5252%nat, 794); (5253%nat, 997);
     (7205%nat, 39); (7206%nat, 78);
     (7499%nat, 227); (7500%nat, 226); (7501%nat, 237);
     (7502%nat, 320);
     (7503%nat, 228); (7504%nat, 236); (7505%nat, 226);
     (7506%nat, 256);
     (7507%nat, 228); (7508%nat, 238); (7509%nat, 236);
     (7510%nat, 256);
     (7593%nat, 102); (7594%nat, 27);
     (7601%nat, 266); (7602%nat, 269); (7603%nat, 267)].

Theorem downstream_support_triangle_words_exact_us :
  downstream_support_triangle_word_receipts area2_collision_words_us.
Proof. vm_compute. reflexivity. Qed.

Theorem downstream_support_triangle_words_exact_jp :
  downstream_support_triangle_word_receipts area2_collision_words_jp.
Proof.
  rewrite <- area2_collision_words_are_version_identical.
  exact downstream_support_triangle_words_exact_us.
Qed.

Record StaticSupportInitializerKey := {
  support_group_header_offset : nat;
  support_group_first_global_ordinal : nat;
  support_group_local_ordinal : nat;
  support_group_triangle_count : nat;
  (** Ordinary records have no trailer.  The two moving-quicksand records
      retain their source force word [256]. *)
  support_triangle_trailer : list Z
}.

Record StaticSupportReceipt := {
  support_surface_type : Z;
  support_global_ordinal : nat;
  support_triangle_indices : Z * Z * Z;
  support_triangle_vertices : list (Z * Z * Z);
  support_point : Z * Z * Z;
  support_initializer_key : StaticSupportInitializerKey
}.

Definition triangle_indices_as_words (indices : Z * Z * Z) : list Z :=
  let '(first, second, third) := indices in [first; second; third].

Fixpoint selected_at {A : Type}
    (wanted_index : nat) (selected : list (nat * A)) : option A :=
  match selected with
  | [] => None
  | (index, value) :: rest =>
      if Nat.eqb wanted_index index then Some value
      else selected_at wanted_index rest
  end.

Definition support_word_at (words : list Z) (index : nat) : option Z :=
  selected_at index
    (select_indexed downstream_support_word_offsets words).

Definition support_vertex_at
    (vertices : list (Z * Z * Z)) (index : nat)
    : option (Z * Z * Z) :=
  selected_at index
    (select_indexed downstream_support_vertex_indices vertices).

Lemma support_vertex_at_from_receipt :
  forall vertices index,
    downstream_support_vertex_receipts vertices ->
    support_vertex_at vertices index =
      selected_at index downstream_support_expected_vertices.
Proof.
  intros vertices index Hreceipt.
  unfold support_vertex_at, downstream_support_vertex_receipts in *.
  now rewrite Hreceipt.
Qed.

Definition support_initializer_record_width
    (key : StaticSupportInitializerKey) : nat :=
  (3 + length (support_triangle_trailer key))%nat.

Definition support_initializer_triangle_word_offset
    (key : StaticSupportInitializerKey) : nat :=
  (support_group_header_offset key + 2 +
   support_initializer_record_width key *
     support_group_local_ordinal key)%nat.

(** This is the missing connection between a receipt and the generated
    initializer: it checks the group header, derives the global ordinal from
    the group's first ordinal plus the local ordinal, and reads the exact
    triangle record at the calculated variable-width word offset. *)
Definition static_support_receipt_initializer_valid
    (words : list Z) (receipt : StaticSupportReceipt) : Prop :=
  let key := support_initializer_key receipt in
  support_word_at words (support_group_header_offset key) =
    Some (support_surface_type receipt) /\
  support_word_at words (S (support_group_header_offset key)) =
    Some (Z.of_nat (support_group_triangle_count key)) /\
  support_global_ordinal receipt =
    (support_group_first_global_ordinal key +
     support_group_local_ordinal key)%nat /\
  map (support_word_at words)
      (seq (support_initializer_triangle_word_offset key)
        (support_initializer_record_width key)) =
    map (@Some Z)
      (triangle_indices_as_words (support_triangle_indices receipt) ++
        support_triangle_trailer key).

Definition x_of (point : Z * Z * Z) : Z :=
  let '(x, _, _) := point in x.

Definition y_of (point : Z * Z * Z) : Z :=
  let '(_, y, _) := point in y.

Definition z_of (point : Z * Z * Z) : Z :=
  let '(_, _, z) := point in z.

Definition edge_cross_xz
    (first second point : Z * Z * Z) : Z :=
  (x_of second - x_of first) * (z_of point - z_of first) -
  (z_of second - z_of first) * (x_of point - x_of first).

Definition point_in_closed_triangle_xz
    (point first second third : Z * Z * Z) : Prop :=
  let ab := edge_cross_xz first second point in
  let bc := edge_cross_xz second third point in
  let ca := edge_cross_xz third first point in
  (0 <= ab /\ 0 <= bc /\ 0 <= ca) \/
  (ab <= 0 /\ bc <= 0 /\ ca <= 0).

Definition static_support_receipt_geometrically_valid
    (receipt : StaticSupportReceipt) : Prop :=
  match support_triangle_vertices receipt with
  | [first; second; third] =>
      y_of first = y_of (support_point receipt) /\
      y_of second = y_of (support_point receipt) /\
      y_of third = y_of (support_point receipt) /\
      edge_cross_xz first second third < 0 /\
      point_in_closed_triangle_xz
        (support_point receipt) first second third
  | _ => False
  end.

(** The handwritten vertex display in a receipt is accepted only when each
    vertex is obtained by indexing the generated vertex table with the exact
    initializer-derived triangle indices. *)
Definition static_support_receipt_vertices_match
    (vertices : list (Z * Z * Z))
    (receipt : StaticSupportReceipt) : Prop :=
  let '(first_index, second_index, third_index) :=
    support_triangle_indices receipt in
  match support_vertex_at vertices (Z.to_nat first_index),
        support_vertex_at vertices (Z.to_nat second_index),
        support_vertex_at vertices (Z.to_nat third_index) with
  | Some first, Some second, Some third =>
      support_triangle_vertices receipt = [first; second; third]
  | _, _, _ => False
  end.

Lemma static_support_vertices_match_from_receipt :
  forall vertices receipt,
    downstream_support_vertex_receipts vertices ->
    (let '(first_index, second_index, third_index) :=
       support_triangle_indices receipt in
     match selected_at (Z.to_nat first_index)
             downstream_support_expected_vertices,
           selected_at (Z.to_nat second_index)
             downstream_support_expected_vertices,
           selected_at (Z.to_nat third_index)
             downstream_support_expected_vertices with
     | Some first, Some second, Some third =>
         support_triangle_vertices receipt = [first; second; third]
     | _, _, _ => False
     end) ->
    static_support_receipt_vertices_match vertices receipt.
Proof.
  intros vertices receipt Hsource Hselected.
  unfold static_support_receipt_vertices_match, support_vertex_at.
  unfold downstream_support_vertex_receipts in Hsource.
  rewrite Hsource.
  exact Hselected.
Qed.

Definition static_support_receipt_fully_valid
    (words : list Z) (vertices : list (Z * Z * Z))
    (receipt : StaticSupportReceipt) : Prop :=
  static_support_receipt_initializer_valid words receipt /\
  static_support_receipt_vertices_match vertices receipt /\
  static_support_receipt_geometrically_valid receipt.

Definition act3_support_receipt : StaticSupportReceipt := {|
  support_surface_type := 102;
  support_global_ordinal := 1401%nat;
  support_triangle_indices := (266, 269, 267);
  support_triangle_vertices :=
    [(387, 4815, -409); (643, 4815, -409); (643, 4815, -1125)];
  support_point := (500, 4815, -500);
  support_initializer_key := {|
    support_group_header_offset := 7593%nat;
    support_group_first_global_ordinal := 1399%nat;
    support_group_local_ordinal := 2%nat;
    support_group_triangle_count := 27%nat;
    support_triangle_trailer := []
  |}
|}.

Definition trigger_support_receipt
    (trigger : HiddenTrigger) : StaticSupportReceipt :=
  match trigger with
  | TriggerLowerWest => {|
      support_surface_type := 0;
      support_global_ordinal := 659%nat;
      support_triangle_indices := (786, 789, 784);
      support_triangle_vertices :=
        [(-384, 2940, -460); (-128, 2940, -716);
         (-384, 2940, -716)];
      support_point := (-260, 2940, -600);
      support_initializer_key := {|
        support_group_header_offset := 3242%nat;
        support_group_first_global_ordinal := 0%nat;
        support_group_local_ordinal := 659%nat;
        support_group_triangle_count := 1068%nat;
        support_triangle_trailer := []
      |}
    |}
  | TriggerLowerEast => {|
      support_surface_type := 0;
      support_global_ordinal := 636%nat;
      support_triangle_indices := (779, 783, 778);
      support_triangle_vertices :=
        [(131, 1967, -460); (387, 1967, -716);
         (131, 1967, -716)];
      support_point := (260, 1967, -600);
      support_initializer_key := {|
        support_group_header_offset := 3242%nat;
        support_group_first_global_ordinal := 0%nat;
        support_group_local_ordinal := 636%nat;
        support_group_triangle_count := 1068%nat;
        support_triangle_trailer := []
      |}
    |}
  | TriggerMiddleWest => {|
      support_surface_type := 39;
      support_global_ordinal := 1378%nat;
      support_triangle_indices := (228, 238, 236);
      support_triangle_vertices :=
        [(-1740, 1229, -588); (-2149, 1229, -793);
         (-2149, 1229, 2560)];
      support_point := (-1940, 1229, -600);
      support_initializer_key := {|
        support_group_header_offset := 7205%nat;
        support_group_first_global_ordinal := 1303%nat;
        support_group_local_ordinal := 75%nat;
        support_group_triangle_count := 78%nat;
        support_triangle_trailer := [256]
      |}
    |}
  | TriggerMiddleNorth => {|
      support_surface_type := 39;
      support_global_ordinal := 1377%nat;
      support_triangle_indices := (228, 236, 226);
      support_triangle_vertices :=
        [(-1740, 1229, -588); (-2149, 1229, 2560);
         (-1740, 1229, 2150)];
      support_point := (-1940, 1229, 2320);
      support_initializer_key := {|
        support_group_header_offset := 7205%nat;
        support_group_first_global_ordinal := 1303%nat;
        support_group_local_ordinal := 74%nat;
        support_group_triangle_count := 78%nat;
        support_triangle_trailer := [256]
      |}
    |}
  | TriggerUpper => {|
      support_surface_type := 0;
      support_global_ordinal := 669%nat;
      support_triangle_indices := (791, 794, 997);
      support_triangle_vertices :=
        [(131, 3913, -460); (387, 3913, -716);
         (131, 3913, -716)];
      support_point := (260, 3913, -600);
      support_initializer_key := {|
        support_group_header_offset := 3242%nat;
        support_group_first_global_ordinal := 0%nat;
        support_group_local_ordinal := 669%nat;
        support_group_triangle_count := 1068%nat;
        support_triangle_trailer := []
      |}
    |}
  end.

Theorem act3_support_receipt_is_geometrically_valid :
  static_support_receipt_geometrically_valid act3_support_receipt.
Proof.
  vm_compute.
  intuition congruence.
Qed.

Theorem every_trigger_support_receipt_is_geometrically_valid :
  forall trigger,
    static_support_receipt_geometrically_valid
      (trigger_support_receipt trigger).
Proof.
  intros [];
    vm_compute;
    intuition congruence.
Qed.

Theorem act3_support_receipt_initializer_exact_us :
  static_support_receipt_initializer_valid
    area2_collision_words_us act3_support_receipt.
Proof.
  pose proof downstream_support_triangle_words_exact_us as Hwords.
  unfold downstream_support_triangle_word_receipts in Hwords.
  unfold static_support_receipt_initializer_valid.
  cbn [
    support_initializer_record_width
    support_initializer_triangle_word_offset
    triangle_indices_as_words act3_support_receipt].
  unfold support_word_at.
  rewrite Hwords.
  repeat split; reflexivity.
Qed.

Theorem act3_support_receipt_initializer_exact_jp :
  static_support_receipt_initializer_valid
    area2_collision_words_jp act3_support_receipt.
Proof.
  rewrite <- area2_collision_words_are_version_identical.
  exact act3_support_receipt_initializer_exact_us.
Qed.

Theorem every_trigger_support_receipt_initializer_exact_us :
  forall trigger,
    static_support_receipt_initializer_valid area2_collision_words_us
      (trigger_support_receipt trigger).
Proof.
  pose proof downstream_support_triangle_words_exact_us as Hwords.
  unfold downstream_support_triangle_word_receipts in Hwords.
  intros trigger. destruct trigger;
    unfold static_support_receipt_initializer_valid;
    cbn [
      support_initializer_record_width
      support_initializer_triangle_word_offset
      triangle_indices_as_words trigger_support_receipt];
    unfold support_word_at;
    rewrite Hwords;
    repeat split; reflexivity.
Qed.

Theorem every_trigger_support_receipt_initializer_exact_jp :
  forall trigger,
    static_support_receipt_initializer_valid area2_collision_words_jp
      (trigger_support_receipt trigger).
Proof.
  intros trigger.
  rewrite <- area2_collision_words_are_version_identical.
  exact (every_trigger_support_receipt_initializer_exact_us trigger).
Qed.

Theorem act3_support_receipt_vertices_exact_us :
  static_support_receipt_vertices_match
    area2_collision_vertices_us act3_support_receipt.
Proof.
  pose proof downstream_support_vertices_exact_us as Hvertices.
  eapply static_support_vertices_match_from_receipt.
  - exact Hvertices.
  - vm_compute. reflexivity.
Qed.

Theorem act3_support_receipt_vertices_exact_jp :
  static_support_receipt_vertices_match
    area2_collision_vertices_jp act3_support_receipt.
Proof.
  rewrite <- area2_collision_vertices_are_version_identical.
  exact act3_support_receipt_vertices_exact_us.
Qed.

Theorem every_trigger_support_receipt_vertices_exact_us :
  forall trigger,
    static_support_receipt_vertices_match area2_collision_vertices_us
      (trigger_support_receipt trigger).
Proof.
  pose proof downstream_support_vertices_exact_us as Hvertices.
  intros trigger. eapply static_support_vertices_match_from_receipt.
  - exact Hvertices.
  - destruct trigger; vm_compute; reflexivity.
Qed.

Theorem every_trigger_support_receipt_vertices_exact_jp :
  forall trigger,
    static_support_receipt_vertices_match area2_collision_vertices_jp
      (trigger_support_receipt trigger).
Proof.
  intros trigger.
  rewrite <- area2_collision_vertices_are_version_identical.
  exact (every_trigger_support_receipt_vertices_exact_us trigger).
Qed.

Theorem act3_support_receipt_fully_valid_us :
  static_support_receipt_fully_valid
    area2_collision_words_us area2_collision_vertices_us
    act3_support_receipt.
Proof.
  split.
  - exact act3_support_receipt_initializer_exact_us.
  - split.
    + exact act3_support_receipt_vertices_exact_us.
    + exact act3_support_receipt_is_geometrically_valid.
Qed.

Theorem act3_support_receipt_fully_valid_jp :
  static_support_receipt_fully_valid
    area2_collision_words_jp area2_collision_vertices_jp
    act3_support_receipt.
Proof.
  split.
  - exact act3_support_receipt_initializer_exact_jp.
  - split.
    + exact act3_support_receipt_vertices_exact_jp.
    + exact act3_support_receipt_is_geometrically_valid.
Qed.

Theorem every_trigger_support_receipt_fully_valid_us :
  forall trigger,
    static_support_receipt_fully_valid area2_collision_words_us
      area2_collision_vertices_us
      (trigger_support_receipt trigger).
Proof.
  intros trigger. split.
  - exact (every_trigger_support_receipt_initializer_exact_us trigger).
  - split.
    + exact (every_trigger_support_receipt_vertices_exact_us trigger).
    + exact (every_trigger_support_receipt_is_geometrically_valid trigger).
Qed.

Theorem every_trigger_support_receipt_fully_valid_jp :
  forall trigger,
    static_support_receipt_fully_valid area2_collision_words_jp
      area2_collision_vertices_jp
      (trigger_support_receipt trigger).
Proof.
  intros trigger. split.
  - exact (every_trigger_support_receipt_initializer_exact_jp trigger).
  - split.
    + exact (every_trigger_support_receipt_vertices_exact_jp trigger).
    + exact (every_trigger_support_receipt_is_geometrically_valid trigger).
Qed.

(** The star center is 235 units above its checked floor point.  With the
    stock 160-unit Mario hitbox, standing at that point remains 75 units below
    the star's bottom.  This does not exclude falling into the region from a
    higher support, retained velocity, or another no-A writer. *)
Definition act3_floor_standing_mario_position : Vec3f := {|
  vec_x := f32_bits 1140457472;  (* 500.0f *)
  vec_y := f32_bits 1167489024;  (* 4815.0f *)
  vec_z := f32_bits 3287941120   (* -500.0f *)
|}.

Theorem act3_floor_standing_sample_does_not_overlap_star :
  hitboxes_overlap
    act3_floor_standing_mario_position mario_standard_hitbox_f32
    act3_static_position collect_star_hitbox = false.
Proof. vm_compute. reflexivity. Qed.

Theorem act3_floor_standing_vertical_gap_is_75 :
  Float32.to_bits
      (hitbox_top act3_floor_standing_mario_position
        mario_standard_hitbox_f32) = Int.repr 1167816704 /\
  Float32.to_bits
      (hitbox_bottom act3_static_position collect_star_hitbox) =
        Int.repr 1167970304.
Proof. vm_compute. split; reflexivity. Qed.
