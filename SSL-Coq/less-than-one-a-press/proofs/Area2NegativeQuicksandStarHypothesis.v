(** Conditional Area-2 negative-quicksand star hypothesis.

    This file deliberately proves a capability boundary, not reachability.
    The generated initializers contain 260 Area-2 quicksand triangles, and an
    exact moving-quicksand triangle supports the Act-6 star's X/Z sample at
    Y=1229.  Standing there leaves Mario's raw hitbox eleven units short.

    The finite view model mirrors the already-audited source distinction:
    [sink_mario_in_quicksand] changes Graphics Y while raw-object collision
    continues to use the raw Object position.  Consequently any number of
    hypothetical negative-depth sinks leaves direct star collision false.
    If a later failed State floor query invokes the Graphics retry, however,
    copying the accumulated Graphics position through State into the raw
    Object would make the next collision useful.  With the exact conditional
    late-landing value -2.6500000953674316f, five retained sinks suffice for
    Act 6; 29 suffice for the separate Act-3 standing gap.

    Ordinary initialization explicitly writes +0.0f, the checked zero-A
    source boundary has no clean negative producer, and both ordinary target
    samples have authenticated static support candidates.  No theorem below
    asserts a live floor-query miss, retained dialog stall, retry, raw copy,
    or collection.  [Area2NegativeDepthLiveBridgeObligation] names those
    missing execution facts so a future machine-level mutation cannot be
    confused with a successful in-bounds CompCert route. *)

From Coq Require Import Bool List ZArith.
From compcert Require Import Floats Integers.
From LessThanOneAPress.Proofs Require Import
  GameTypes CollisionRegions CollisionMeshFacts ClightFacts PyramidTopPU
  Area2DownstreamGeometry AutomaticDialogReanchoring.

Import ListNotations.
Local Open Scope Z_scope.

(** * Four source-enumerated Area-2 quicksand groups *)

(** Offsets are in the complete 8,098-word collision initializer.  The four
    group headers are deep, deep-moving, moving, and instant-moving quicksand. *)
Definition area2_quicksand_group_header_offsets : list nat :=
  [6673; 6674; 7059; 7060; 7205; 7206; 7519; 7520]%nat.

Definition area2_quicksand_group_header_receipt (words : list Z) : Prop :=
  select_indexed area2_quicksand_group_header_offsets words =
    [(6673%nat, 34); (6674%nat, 128);
     (7059%nat, 36); (7060%nat, 36);
     (7205%nat, 39); (7206%nat, 78);
     (7519%nat, 45); (7520%nat, 18)].

Theorem area2_quicksand_group_headers_exact_us :
  area2_quicksand_group_header_receipt area2_collision_words_us.
Proof. vm_compute. reflexivity. Qed.

Theorem area2_quicksand_group_headers_exact_jp :
  area2_quicksand_group_header_receipt area2_collision_words_jp.
Proof.
  rewrite <- area2_collision_words_are_version_identical.
  exact area2_quicksand_group_headers_exact_us.
Qed.

Definition area2_checked_quicksand_triangle_count : nat :=
  (128 + 36 + 78 + 18)%nat.

Theorem four_checked_area2_quicksand_groups_total_260 :
  area2_checked_quicksand_triangle_count = 260%nat.
Proof. reflexivity. Qed.

(** * Exact moving-quicksand support under the Act-6 star *)

Definition act6_star_quicksand_support_receipt : StaticSupportReceipt := {|
  support_surface_type := 39;
  support_global_ordinal := 1376%nat;
  support_triangle_indices := (227, 226, 237);
  support_triangle_vertices :=
    [(1178, 1229, 2150); (-1740, 1229, 2150);
     (1178, 1229, 2560)];
  support_point := (900, 1229, 2350);
  support_initializer_key := {|
    support_group_header_offset := 7205%nat;
    support_group_first_global_ordinal := 1303%nat;
    support_group_local_ordinal := 73%nat;
    support_group_triangle_count := 78%nat;
    support_triangle_trailer := [320]
  |}
|}.

Theorem act6_star_quicksand_support_is_geometrically_valid :
  static_support_receipt_geometrically_valid
    act6_star_quicksand_support_receipt.
Proof. vm_compute. intuition congruence. Qed.

Theorem act6_star_quicksand_support_initializer_exact_us :
  static_support_receipt_initializer_valid
    area2_collision_words_us act6_star_quicksand_support_receipt.
Proof.
  pose proof downstream_support_triangle_words_exact_us as Hwords.
  unfold downstream_support_triangle_word_receipts in Hwords.
  unfold static_support_receipt_initializer_valid.
  cbn [support_initializer_record_width
       support_initializer_triangle_word_offset
       triangle_indices_as_words act6_star_quicksand_support_receipt].
  unfold support_word_at.
  rewrite Hwords.
  repeat split; reflexivity.
Qed.

Theorem act6_star_quicksand_support_initializer_exact_jp :
  static_support_receipt_initializer_valid
    area2_collision_words_jp act6_star_quicksand_support_receipt.
Proof.
  rewrite <- area2_collision_words_are_version_identical.
  exact act6_star_quicksand_support_initializer_exact_us.
Qed.

Theorem act6_star_quicksand_support_vertices_exact_us :
  static_support_receipt_vertices_match
    area2_collision_vertices_us act6_star_quicksand_support_receipt.
Proof.
  pose proof downstream_support_vertices_exact_us as Hvertices.
  eapply static_support_vertices_match_from_receipt.
  - exact Hvertices.
  - vm_compute. reflexivity.
Qed.

Theorem act6_star_quicksand_support_vertices_exact_jp :
  static_support_receipt_vertices_match
    area2_collision_vertices_jp act6_star_quicksand_support_receipt.
Proof.
  rewrite <- area2_collision_vertices_are_version_identical.
  exact act6_star_quicksand_support_vertices_exact_us.
Qed.

Theorem act6_star_quicksand_support_fully_valid_us :
  static_support_receipt_fully_valid
    area2_collision_words_us area2_collision_vertices_us
    act6_star_quicksand_support_receipt.
Proof.
  split.
  - exact act6_star_quicksand_support_initializer_exact_us.
  - split.
    + exact act6_star_quicksand_support_vertices_exact_us.
    + exact act6_star_quicksand_support_is_geometrically_valid.
Qed.

Theorem act6_star_quicksand_support_fully_valid_jp :
  static_support_receipt_fully_valid
    area2_collision_words_jp area2_collision_vertices_jp
    act6_star_quicksand_support_receipt.
Proof.
  split.
  - exact act6_star_quicksand_support_initializer_exact_jp.
  - split.
    + exact act6_star_quicksand_support_vertices_exact_jp.
    + exact act6_star_quicksand_support_is_geometrically_valid.
Qed.

Definition act6_quicksand_floor_standing_position : Vec3f := {|
  vec_x := f32_bits 1147207680;  (* 900.0f *)
  vec_y := f32_bits 1150918656;  (* 1229.0f *)
  vec_z := f32_bits 1158864896   (* 2350.0f *)
|}.

Theorem act6_quicksand_floor_standing_does_not_overlap_star :
  hitboxes_overlap
    act6_quicksand_floor_standing_position mario_standard_hitbox_f32
    hidden_controller_position collect_star_hitbox = false.
Proof. vm_compute. reflexivity. Qed.

Theorem act6_quicksand_floor_standing_vertical_gap_is_11 :
  Float32.to_bits
      (hitbox_top act6_quicksand_floor_standing_position
        mario_standard_hitbox_f32) = Int.repr 1152229376 /\
  Float32.to_bits
      (hitbox_bottom hidden_controller_position collect_star_hitbox) =
        Int.repr 1152319488.
Proof. vm_compute. split; reflexivity. Qed.

(** * Three views and a Graphics-only sink *)

Record Area2MarioViews : Type := {
  area2_state_position : Vec3f;
  area2_raw_object_position : Vec3f;
  area2_graphics_position : Vec3f
}.

Definition area2_subtract_depth_from_y
    (position : Vec3f) (depth : float32) : Vec3f := {|
  vec_x := vec_x position;
  vec_y := Float32.sub (vec_y position) depth;
  vec_z := vec_z position
|}.

Definition area2_graphics_only_sink
    (depth : float32) (views : Area2MarioViews) : Area2MarioViews := {|
  area2_state_position := area2_state_position views;
  area2_raw_object_position := area2_raw_object_position views;
  area2_graphics_position :=
    area2_subtract_depth_from_y (area2_graphics_position views) depth
|}.

Fixpoint area2_repeat_graphics_only_sink
    (frames : nat) (depth : float32) (views : Area2MarioViews)
    : Area2MarioViews :=
  match frames with
  | O => views
  | S rest =>
      area2_repeat_graphics_only_sink rest depth
        (area2_graphics_only_sink depth views)
  end.

(** This is the effect that would become available only after a first State
    floor-query miss, a successful Graphics retry, and the later State-to-raw
    copy.  The definition does not assert that those branches are reachable. *)
Definition area2_forced_graphics_retry_and_raw_copy
    (views : Area2MarioViews) : Area2MarioViews := {|
  area2_state_position := area2_graphics_position views;
  area2_raw_object_position := area2_graphics_position views;
  area2_graphics_position := area2_graphics_position views
|}.

Definition area2_act6_standing_views : Area2MarioViews := {|
  area2_state_position := act6_quicksand_floor_standing_position;
  area2_raw_object_position := act6_quicksand_floor_standing_position;
  area2_graphics_position := act6_quicksand_floor_standing_position
|}.

Definition area2_act3_standing_views : Area2MarioViews := {|
  area2_state_position := act3_floor_standing_mario_position;
  area2_raw_object_position := act3_floor_standing_mario_position;
  area2_graphics_position := act3_floor_standing_mario_position
|}.

Theorem area2_graphics_sink_preserves_state_and_raw_object :
  forall depth views,
    area2_state_position (area2_graphics_only_sink depth views) =
      area2_state_position views /\
    area2_raw_object_position (area2_graphics_only_sink depth views) =
      area2_raw_object_position views.
Proof. intros; split; reflexivity. Qed.

Theorem area2_repeated_graphics_sinks_preserve_raw_object :
  forall frames depth views,
    area2_raw_object_position
      (area2_repeat_graphics_only_sink frames depth views) =
    area2_raw_object_position views.
Proof.
  induction frames as [| frames IH]; intros depth views; cbn.
  - reflexivity.
  - rewrite IH. reflexivity.
Qed.

Theorem any_number_of_act6_graphics_sinks_still_misses_directly :
  forall frames depth,
    hitboxes_overlap
      (area2_raw_object_position
        (area2_repeat_graphics_only_sink
          frames depth area2_act6_standing_views))
      mario_standard_hitbox_f32
      hidden_controller_position collect_star_hitbox = false.
Proof.
  intros frames depth.
  rewrite area2_repeated_graphics_sinks_preserve_raw_object.
  exact act6_quicksand_floor_standing_does_not_overlap_star.
Qed.

Theorem any_number_of_act3_graphics_sinks_still_misses_directly :
  forall frames depth,
    hitboxes_overlap
      (area2_raw_object_position
        (area2_repeat_graphics_only_sink
          frames depth area2_act3_standing_views))
      mario_standard_hitbox_f32
      act3_static_position collect_star_hitbox = false.
Proof.
  intros frames depth.
  rewrite area2_repeated_graphics_sinks_preserve_raw_object.
  exact act3_floor_standing_sample_does_not_overlap_star.
Qed.

Theorem act6_collection_after_graphics_sinks_requires_raw_change :
  forall frames depth raw_after,
    hitboxes_overlap raw_after mario_standard_hitbox_f32
      hidden_controller_position collect_star_hitbox = true ->
    raw_after <>
      area2_raw_object_position
        (area2_repeat_graphics_only_sink
          frames depth area2_act6_standing_views).
Proof.
  intros frames depth raw_after Hoverlap Hequal.
  rewrite Hequal in Hoverlap.
  rewrite any_number_of_act6_graphics_sinks_still_misses_directly in Hoverlap.
  discriminate.
Qed.

Theorem act3_collection_after_graphics_sinks_requires_raw_change :
  forall frames depth raw_after,
    hitboxes_overlap raw_after mario_standard_hitbox_f32
      act3_static_position collect_star_hitbox = true ->
    raw_after <>
      area2_raw_object_position
        (area2_repeat_graphics_only_sink
          frames depth area2_act3_standing_views).
Proof.
  intros frames depth raw_after Hoverlap Hequal.
  rewrite Hequal in Hoverlap.
  rewrite any_number_of_act3_graphics_sinks_still_misses_directly in Hoverlap.
  discriminate.
Qed.

(** * Exact conditional payload and minimum checked sink counts *)

(** This is the exact binary32 value produced by the conditional timer-four
    late-long-jump landing arithmetic already checked elsewhere.  Its clean
    zero-A provenance is disproved at the selected source boundary. *)
Definition area2_hypothetical_late_landing_depth : float32 :=
  f32_bits 3223951770.  (* -2.6500000953674316f *)

Theorem area2_hypothetical_late_landing_depth_is_negative :
  Float32.cmp Clt area2_hypothetical_late_landing_depth f32_zero = true.
Proof. vm_compute. reflexivity. Qed.

Definition area2_forced_retry_after_sinks
    (frames : nat) (views : Area2MarioViews) : Area2MarioViews :=
  area2_forced_graphics_retry_and_raw_copy
    (area2_repeat_graphics_only_sink
      frames area2_hypothetical_late_landing_depth views).

Theorem act6_four_sinks_miss_but_five_plus_forced_retry_overlap :
  hitboxes_overlap
    (area2_raw_object_position
      (area2_forced_retry_after_sinks 4 area2_act6_standing_views))
    mario_standard_hitbox_f32
    hidden_controller_position collect_star_hitbox = false /\
  Float32.to_bits
    (vec_y (area2_raw_object_position
      (area2_forced_retry_after_sinks 5 area2_act6_standing_views))) =
      Int.repr 1151027201 /\
  hitboxes_overlap
    (area2_raw_object_position
      (area2_forced_retry_after_sinks 5 area2_act6_standing_views))
    mario_standard_hitbox_f32
    hidden_controller_position collect_star_hitbox = true.
Proof. vm_compute. repeat split; reflexivity. Qed.

Theorem act3_twenty_eight_sinks_miss_but_twenty_nine_plus_retry_overlap :
  hitboxes_overlap
    (area2_raw_object_position
      (area2_forced_retry_after_sinks 28 area2_act3_standing_views))
    mario_standard_hitbox_f32
    act3_static_position collect_star_hitbox = false /\
  Float32.to_bits
    (vec_y (area2_raw_object_position
      (area2_forced_retry_after_sinks 29 area2_act3_standing_views))) =
      Int.repr 1167646407 /\
  hitboxes_overlap
    (area2_raw_object_position
      (area2_forced_retry_after_sinks 29 area2_act3_standing_views))
    mario_standard_hitbox_f32
    act3_static_position collect_star_hitbox = true.
Proof. vm_compute. repeat split; reflexivity. Qed.

(** * Generated-source boundary and the deliberately open live bridge *)

Definition Area2NegativeDepthHypothesisSourceBoundary : Prop :=
  mario_entry_field_reset_source_shape_us_claim /\
  mario_entry_field_reset_source_shape_jp_claim /\
  graphical_floor_fallback_source_shape_us_claim /\
  graphical_floor_fallback_source_shape_jp_claim /\
  goomba_player_collision_source_shape_us_claim /\
  goomba_player_collision_source_shape_jp_claim /\
  dialog_sink_and_raw_copy_order_claim.

Theorem area2_negative_depth_hypothesis_source_boundary_checked :
  Area2NegativeDepthHypothesisSourceBoundary.
Proof.
  unfold Area2NegativeDepthHypothesisSourceBoundary.
  split; [exact mario_entry_field_reset_source_shape_us |].
  split; [exact mario_entry_field_reset_source_shape_jp |].
  split; [exact graphical_floor_fallback_source_shape_us |].
  split; [exact graphical_floor_fallback_source_shape_jp |].
  split; [exact goomba_player_collision_source_shape_us |].
  split; [exact goomba_player_collision_source_shape_jp |].
  exact dialog_sink_and_raw_copy_order_checked.
Qed.

Theorem a_negative_seed_is_not_the_ordinary_entry_reset_value :
  forall depth,
    Float32.cmp Clt depth f32_zero = true ->
    depth <> f32_zero.
Proof.
  intros depth Hnegative Hequal.
  subst depth. vm_compute in Hnegative. discriminate.
Qed.

(** The reusable closed part of the hypothesis.  It packages exact bilateral
    initializer data, the generated source branches, the direct no-go, and
    the two positive arithmetic consequences.  It deliberately omits the
    uninhabited live bridge below. *)
Definition Area2NegativeQuicksandHypotheticalBoundary : Prop :=
  area2_quicksand_group_header_receipt area2_collision_words_us /\
  area2_quicksand_group_header_receipt area2_collision_words_jp /\
  area2_checked_quicksand_triangle_count = 260%nat /\
  static_support_receipt_fully_valid
    area2_collision_words_us area2_collision_vertices_us
    act6_star_quicksand_support_receipt /\
  static_support_receipt_fully_valid
    area2_collision_words_jp area2_collision_vertices_jp
    act6_star_quicksand_support_receipt /\
  Area2NegativeDepthHypothesisSourceBoundary /\
  (forall frames depth,
    hitboxes_overlap
      (area2_raw_object_position
        (area2_repeat_graphics_only_sink
          frames depth area2_act6_standing_views))
      mario_standard_hitbox_f32
      hidden_controller_position collect_star_hitbox = false) /\
  (forall frames depth,
    hitboxes_overlap
      (area2_raw_object_position
        (area2_repeat_graphics_only_sink
          frames depth area2_act3_standing_views))
      mario_standard_hitbox_f32
      act3_static_position collect_star_hitbox = false) /\
  hitboxes_overlap
    (area2_raw_object_position
      (area2_forced_retry_after_sinks 5 area2_act6_standing_views))
    mario_standard_hitbox_f32
    hidden_controller_position collect_star_hitbox = true /\
  hitboxes_overlap
    (area2_raw_object_position
      (area2_forced_retry_after_sinks 29 area2_act3_standing_views))
    mario_standard_hitbox_f32
    act3_static_position collect_star_hitbox = true.

Theorem area2_negative_quicksand_hypothetical_boundary_checked :
  Area2NegativeQuicksandHypotheticalBoundary.
Proof.
  unfold Area2NegativeQuicksandHypotheticalBoundary.
  split; [exact area2_quicksand_group_headers_exact_us |].
  split; [exact area2_quicksand_group_headers_exact_jp |].
  split; [exact four_checked_area2_quicksand_groups_total_260 |].
  split; [exact act6_star_quicksand_support_fully_valid_us |].
  split; [exact act6_star_quicksand_support_fully_valid_jp |].
  split; [exact area2_negative_depth_hypothesis_source_boundary_checked |].
  split; [exact any_number_of_act6_graphics_sinks_still_misses_directly |].
  split; [exact any_number_of_act3_graphics_sinks_still_misses_directly |].
  split.
  - exact
      (proj2 (proj2
        act6_four_sinks_miss_but_five_plus_forced_retry_overlap)).
  - exact
      (proj2 (proj2
        act3_twenty_eight_sinks_miss_but_twenty_nine_plus_retry_overlap)).
Qed.

(** A future live proof supplies [reaches] and the observation predicates from
    one actual execution.  For Act 6 instantiate [standing_views] with
    [area2_act6_standing_views], [target_position] with
    [hidden_controller_position], and [sink_frames] with 5.  For Act 3 use
    [area2_act3_standing_views], [act3_static_position], and 29.

    The accepted entry is required to contain +0.0f, so the unexplained seed
    is necessarily installed after that reset (or by a future model that
    explicitly replaces the reset).  The query miss and retry are separate
    fields because the static support receipts make an ordinary miss at either
    target something that must be explained, not silently assumed. *)
Definition Area2NegativeDepthLiveBridgeObligation
    {State : Type}
    (accepted_entry : State -> Prop)
    (reaches : State -> State -> Prop)
    (depth_at : State -> float32)
    (views_at : State -> Area2MarioViews)
    (first_state_floor_query_misses : State -> Prop)
    (graphics_retry_succeeds : State -> Prop)
    (target_collected : State -> Prop)
    (standing_views : Area2MarioViews)
    (target_position : Vec3f)
    (sink_frames : nat) : Prop :=
  exists entry seeded after_sinks after_retry after_raw_copy collision,
    accepted_entry entry /\
    depth_at entry = f32_zero /\
    reaches entry seeded /\
    depth_at seeded = area2_hypothetical_late_landing_depth /\
    views_at seeded = standing_views /\
    reaches seeded after_sinks /\
    views_at after_sinks =
      area2_repeat_graphics_only_sink sink_frames
        area2_hypothetical_late_landing_depth standing_views /\
    first_state_floor_query_misses after_sinks /\
    graphics_retry_succeeds after_sinks /\
    reaches after_sinks after_retry /\
    area2_state_position (views_at after_retry) =
      area2_graphics_position (views_at after_sinks) /\
    reaches after_retry after_raw_copy /\
    area2_raw_object_position (views_at after_raw_copy) =
      area2_state_position (views_at after_retry) /\
    reaches after_raw_copy collision /\
    area2_raw_object_position (views_at collision) =
      area2_raw_object_position (views_at after_raw_copy) /\
    hitboxes_overlap
      (area2_raw_object_position (views_at collision))
      mario_standard_hitbox_f32 target_position collect_star_hitbox = true /\
    target_collected collision.

Definition Area2Act6NegativeDepthLiveBridgeObligation
    {State : Type}
    (accepted_entry : State -> Prop)
    (reaches : State -> State -> Prop)
    (depth_at : State -> float32)
    (views_at : State -> Area2MarioViews)
    (first_state_floor_query_misses : State -> Prop)
    (graphics_retry_succeeds : State -> Prop)
    (act6_collected : State -> Prop) : Prop :=
  Area2NegativeDepthLiveBridgeObligation
    accepted_entry reaches depth_at views_at
    first_state_floor_query_misses graphics_retry_succeeds act6_collected
    area2_act6_standing_views hidden_controller_position 5.

Definition Area2Act3NegativeDepthLiveBridgeObligation
    {State : Type}
    (accepted_entry : State -> Prop)
    (reaches : State -> State -> Prop)
    (depth_at : State -> float32)
    (views_at : State -> Area2MarioViews)
    (first_state_floor_query_misses : State -> Prop)
    (graphics_retry_succeeds : State -> Prop)
    (act3_collected : State -> Prop) : Prop :=
  Area2NegativeDepthLiveBridgeObligation
    accepted_entry reaches depth_at views_at
    first_state_floor_query_misses graphics_retry_succeeds act3_collected
    area2_act3_standing_views act3_static_position 29.

Print Assumptions area2_quicksand_group_headers_exact_us.
Print Assumptions act6_star_quicksand_support_fully_valid_us.
Print Assumptions any_number_of_act6_graphics_sinks_still_misses_directly.
Print Assumptions act6_four_sinks_miss_but_five_plus_forced_retry_overlap.
Print Assumptions
  act3_twenty_eight_sinks_miss_but_twenty_nine_plus_retry_overlap.
Print Assumptions area2_negative_depth_hypothesis_source_boundary_checked.
Print Assumptions area2_negative_quicksand_hypothetical_boundary_checked.
