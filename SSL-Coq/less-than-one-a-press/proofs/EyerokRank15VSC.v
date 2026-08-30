(** Rank 15: an optimistic vertical-speed-conservation bound above the
    controller-authentic Eyerok hand ride.

    This file answers a narrow question: can the stock vertical seeds already
    present in the Rank-15 proposal supply the missing height if their speed is
    conserved until the hand reaches its observed top?  The arithmetic grants
    perfect conservation, the full positive ascent of the seed, and the most
    favorable ordinary ledge-floor lookup allowance.  Even under those grants,
    every seed through 31 misses the Area-3 tunnel floor.  Seed 32 is the first
    integral seed to reach the purely vertical arithmetic threshold, but that
    does not establish a wall, X/Z, action, or live-execution route.

    The generated US/JP receipts below pin the relevant stock constants and
    couple ACT_JUMP_KICK to the exact [m->vel[1] = 20.0f] assignment.  The
    complete Area-3 static collision initializer is also checked: none of its
    positively oriented triangles spans the open vertical band between the
    arena's Y=-1150 top and the tunnel's Y=-562 floor.  A dynamic hand or other
    moving support is deliberately outside that static-mesh fact. *)

From Coq Require Import Bool Lia List ZArith.
From compcert Require Import AST Clight Integers.
From LessThanOneAPress.Proofs Require Import
  ASTFacts ClightFacts CollisionMeshFacts EyerokRank15ControllerRide
  OrdinaryMotion PyramidTopPU.

Import ListNotations.
Local Open Scope Z_scope.

(** * Coupled generated-source receipts *)

(** Locate one switch case and couple its label to one exact array-slot
    assignment.  This is stronger than independently finding a label, a slot,
    and a literal, though it remains a syntax receipt rather than reachability
    or Clight execution. *)
Fixpoint rank15_switch_case_assigns_float32_slot_s
    (case_label : Z) (array_field : ident) (index bits : Z)
    (statement : statement) : bool :=
  match statement with
  | Ssequence first second | Sloop first second =>
      rank15_switch_case_assigns_float32_slot_s
        case_label array_field index bits first ||
      rank15_switch_case_assigns_float32_slot_s
        case_label array_field index bits second
  | Sifthenelse _ yes no =>
      rank15_switch_case_assigns_float32_slot_s
        case_label array_field index bits yes ||
      rank15_switch_case_assigns_float32_slot_s
        case_label array_field index bits no
  | Sswitch _ cases =>
      rank15_switch_case_assigns_float32_slot_ls
        case_label array_field index bits cases
  | Slabel _ body =>
      rank15_switch_case_assigns_float32_slot_s
        case_label array_field index bits body
  | _ => false
  end
with rank15_switch_case_assigns_float32_slot_ls
    (case_label : Z) (array_field : ident) (index bits : Z)
    (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons label body rest =>
      (match label with
       | Some found =>
           Z.eqb found case_label &&
           assigns_array_slot_float32_constant_s
             array_field index bits body
       | None => false
       end) ||
      rank15_switch_case_assigns_float32_slot_s
        case_label array_field index bits body ||
      rank15_switch_case_assigns_float32_slot_ls
        case_label array_field index bits rest
  end.

Definition rank15_float32_one_hundred_sixty_bits : Z := 1126170624.
Definition rank15_eyerok_interact_bounce_top_bits : Z := 32768.

Definition EyerokRank15VSCSourceShape : Prop :=
  rank15_switch_case_assigns_float32_slot_s
    act_jump_kick_bits UMI._vel 1 float32_twenty_bits
    (fn_body UMI.f_set_mario_action_airborne) = true /\
  rank15_switch_case_assigns_float32_slot_s
    act_jump_kick_bits JMI._vel 1 float32_twenty_bits
    (fn_body JMI.f_set_mario_action_airborne) = true /\
  calls_ident_with_float32_arg_s
    UI._bounce_off_object float32_thirty_bits
    (fn_body UI.f_interact_bounce_top) = true /\
  calls_ident_with_float32_arg_s
    JI._bounce_off_object float32_thirty_bits
    (fn_body JI.f_interact_bounce_top) = true /\
  firstn 1 (gvar_init UEye.v_sEyerokHitbox) =
    [Init_int32 (Int.repr rank15_eyerok_interact_bounce_top_bits)] /\
  firstn 1 (gvar_init JEye.v_sEyerokHitbox) =
    [Init_int32 (Int.repr rank15_eyerok_interact_bounce_top_bits)] /\
  calls_ident_with_float32_arg_s
    UStep._find_floor rank15_float32_one_hundred_sixty_bits
    (fn_body UStep.f_check_ledge_grab) = true /\
  calls_ident_with_float32_arg_s
    JStep._find_floor rank15_float32_one_hundred_sixty_bits
    (fn_body JStep.f_check_ledge_grab) = true /\
  statement_mentions_float32_bits_s float32_seventy_eight_bits
    (fn_body USurface.f_find_floor_from_list) = true /\
  statement_mentions_float32_bits_s float32_seventy_eight_bits
    (fn_body JSurface.f_find_floor_from_list) = true /\
  statement_mentions_float32_bits_s float32_four_bits
    (fn_body UStep.f_apply_gravity) = true /\
  statement_mentions_float32_bits_s float32_four_bits
    (fn_body JStep.f_apply_gravity) = true.

Theorem eyerok_rank15_vsc_source_shape_checked :
  EyerokRank15VSCSourceShape.
Proof.
  unfold EyerokRank15VSCSourceShape,
    rank15_float32_one_hundred_sixty_bits,
    rank15_eyerok_interact_bounce_top_bits.
  vm_compute. repeat split.
Qed.

(** * Complete Area-3 static-mesh gap receipt *)

Definition rank15_area3_words_us : list Z :=
  init_int16_values
    (gvar_init UCollision.v_ssl_seg7_area_3_collision).

Definition rank15_area3_words_jp : list Z :=
  init_int16_values
    (gvar_init JCollision.v_ssl_seg7_area_3_collision).

Definition rank15_area3_vertices (words : list Z) :
    list (Z * Z * Z) :=
  collision_vertices_from_words 122 words.

(** The generated stream has 122 vertices followed by five surface groups:
    158 default, 6 death-plane, 8 not-slippery, and two 2-triangle warp
    groups.  The offsets include each group's two-word header. *)
Definition rank15_area3_triangles (words : list Z) :
    list (Z * Z * Z) :=
  triples_from_words (firstn (3 * 158) (skipn 370 words)) ++
  triples_from_words (firstn (3 * 6) (skipn 846 words)) ++
  triples_from_words (firstn (3 * 8) (skipn 866 words)) ++
  triples_from_words (firstn (3 * 2) (skipn 892 words)) ++
  triples_from_words (firstn (3 * 2) (skipn 900 words)).

Definition Rank15Vertex : Type := (Z * Z * Z)%type.
Definition Rank15TriangleVertices : Type :=
  (Rank15Vertex * Rank15Vertex * Rank15Vertex)%type.

Definition rank15_triangle_vertices
    (vertices : list Rank15Vertex) (triangle : Z * Z * Z) :
    option Rank15TriangleVertices :=
  let '(first, second, third) := triangle in
  match nth_error vertices (Z.to_nat first),
        nth_error vertices (Z.to_nat second),
        nth_error vertices (Z.to_nat third) with
  | Some first_vertex, Some second_vertex, Some third_vertex =>
      Some (first_vertex, second_vertex, third_vertex)
  | _, _, _ => None
  end.

Definition rank15_triangle_normal_y
    (vertices : Rank15TriangleVertices) : Z :=
  let '(first, second, third) := vertices in
  let '(x1, _, z1) := first in
  let '(x2, _, z2) := second in
  let '(x3, _, z3) := third in
  (z2 - z1) * (x3 - x2) - (x2 - x1) * (z3 - z2).

Definition rank15_vertex_y (vertex : Rank15Vertex) : Z :=
  let '(_, y, _) := vertex in y.

Definition rank15_triangle_min_y
    (vertices : Rank15TriangleVertices) : Z :=
  let '(first, second, third) := vertices in
  Z.min (rank15_vertex_y first)
    (Z.min (rank15_vertex_y second) (rank15_vertex_y third)).

Definition rank15_triangle_max_y
    (vertices : Rank15TriangleVertices) : Z :=
  let '(first, second, third) := vertices in
  Z.max (rank15_vertex_y first)
    (Z.max (rank15_vertex_y second) (rank15_vertex_y third)).

Definition rank15_arena_static_upper_y : Z := -1150.
Definition rank15_tunnel_floor_y : Z := -562.

(** This conservative check treats every strictly positive raw normal-Y face
    as potentially floor-like.  Thus it does not depend on the engine's more
    permissive normalized floor/wall threshold. *)
Definition rank15_triangle_avoids_open_static_gap
    (vertices : list Rank15Vertex) (triangle : Z * Z * Z) : bool :=
  match rank15_triangle_vertices vertices triangle with
  | Some triangle_vertices =>
      if Z.ltb 0 (rank15_triangle_normal_y triangle_vertices)
      then Z.leb (rank15_triangle_max_y triangle_vertices)
             rank15_arena_static_upper_y ||
           Z.leb rank15_tunnel_floor_y
             (rank15_triangle_min_y triangle_vertices)
      else true
  | None => false
  end.

Definition EyerokRank15Area3StaticGapReceipt : Prop :=
  length rank15_area3_words_us = 908%nat /\
  length rank15_area3_words_jp = 908%nat /\
  length (rank15_area3_vertices rank15_area3_words_us) = 122%nat /\
  length (rank15_area3_vertices rank15_area3_words_jp) = 122%nat /\
  length (rank15_area3_triangles rank15_area3_words_us) = 176%nat /\
  length (rank15_area3_triangles rank15_area3_words_jp) = 176%nat /\
  nth_error (rank15_area3_vertices rank15_area3_words_us) 14 =
    Some (192, -562, -2048) /\
  nth_error (rank15_area3_vertices rank15_area3_words_jp) 14 =
    Some (192, -562, -2048) /\
  nth_error (rank15_area3_vertices rank15_area3_words_us) 52 =
    Some (631, -1150, -3864) /\
  nth_error (rank15_area3_vertices rank15_area3_words_jp) 52 =
    Some (631, -1150, -3864) /\
  forallb
    (rank15_triangle_avoids_open_static_gap
      (rank15_area3_vertices rank15_area3_words_us))
    (rank15_area3_triangles rank15_area3_words_us) = true /\
  forallb
    (rank15_triangle_avoids_open_static_gap
      (rank15_area3_vertices rank15_area3_words_jp))
    (rank15_area3_triangles rank15_area3_words_jp) = true.

Theorem eyerok_rank15_area3_static_gap_receipt_checked :
  EyerokRank15Area3StaticGapReceipt.
Proof.
  unfold EyerokRank15Area3StaticGapReceipt.
  vm_compute. repeat split.
Qed.

(** * Optimistic VSC arithmetic *)

Definition rank15_ledge_floor_query_offset : Z := 160.

(** Sixteen frames exceed the positive lifetime of every seed considered in
    this theorem.  [Z.max 0] makes later terms harmless, so this is the full
    positive ascent, not a chosen early cutoff, for seeds through 32. *)
Definition rank15_ideal_vsc_ascent (seed : Z) : Z :=
  accumulated_positive_ascent seed normal_gravity_per_frame 16.

Definition rank15_ideal_ledge_query_ceiling (seed : Z) : Z :=
  rank15_observed_highest_hand_top + rank15_ideal_vsc_ascent seed +
  rank15_ledge_floor_query_offset + find_floor_upward_buffer.

Definition rank15_jump_kick_installed_velocity (_stored_velocity : Z) : Z :=
  20.

Definition rank15_jump_kick_departure_ascent
    (stored_velocity : Z) : Z :=
  rank15_ideal_vsc_ascent
    (rank15_jump_kick_installed_velocity stored_velocity).

Theorem rank15_query_threshold_matches_recorded_minimum :
  rank15_tunnel_floor_y - find_floor_upward_buffer =
    rank15_tunnel_floor_query_min_y.
Proof. reflexivity. Qed.

Theorem rank15_checked_seed_ascents_are_exact :
  rank15_ideal_vsc_ascent 20 = 60 /\
  rank15_ideal_vsc_ascent 26 = 98 /\
  rank15_ideal_vsc_ascent 30 = 128 /\
  rank15_ideal_vsc_ascent 31 = 136 /\
  rank15_ideal_vsc_ascent 32 = 144.
Proof. vm_compute. repeat split. Qed.

Theorem rank15_checked_seed_query_ceilings_are_exact :
  rank15_ideal_ledge_query_ceiling 20 = -645 /\
  rank15_ideal_ledge_query_ceiling 26 = -607 /\
  rank15_ideal_ledge_query_ceiling 30 = -577 /\
  rank15_ideal_ledge_query_ceiling 31 = -569 /\
  rank15_ideal_ledge_query_ceiling 32 = -561.
Proof. vm_compute. repeat split. Qed.

Lemma rank15_ascent_monotone_in_seed :
  forall lower upper frames,
    lower <= upper ->
    accumulated_positive_ascent
      lower normal_gravity_per_frame frames <=
    accumulated_positive_ascent
      upper normal_gravity_per_frame frames.
Proof.
  intros lower upper frames Hle.
  induction frames as [|earlier IH].
  - reflexivity.
  - cbn [accumulated_positive_ascent].
    apply Z.add_le_mono.
    + exact IH.
    + apply Z.max_le_compat.
      * reflexivity.
      * unfold vertical_increment. lia.
Qed.

(** No seed at or below 31 reaches the tunnel even after granting both the
    complete positive ascent and the full 160+78 ledge/floor lookup allowance.
    This theorem intentionally ignores X/Z and wall-selection constraints, so
    it is an optimistic vertical impossibility result. *)
Theorem rank15_every_integral_seed_through_31_misses_tunnel :
  forall seed,
    seed <= 31 ->
    rank15_ideal_ledge_query_ceiling seed < rank15_tunnel_floor_y.
Proof.
  intros seed Hseed.
  pose proof (rank15_ascent_monotone_in_seed seed 31 16 Hseed) as Hascent.
  change (rank15_ideal_vsc_ascent seed <=
    rank15_ideal_vsc_ascent 31) in Hascent.
  destruct rank15_checked_seed_ascents_are_exact as [_ [_ [_ [H31 _]]]].
  rewrite H31 in Hascent.
  unfold rank15_ideal_ledge_query_ceiling,
    rank15_observed_highest_hand_top, rank15_ledge_floor_query_offset,
    find_floor_upward_buffer, rank15_tunnel_floor_y.
  lia.
Qed.

Theorem rank15_seed_32_is_first_arithmetic_threshold_witness :
  rank15_ideal_ledge_query_ceiling 31 < rank15_tunnel_floor_y /\
  rank15_tunnel_floor_y <= rank15_ideal_ledge_query_ceiling 32.
Proof.
  split.
  - apply rank15_every_integral_seed_through_31_misses_tunnel. lia.
  - destruct rank15_checked_seed_query_ceilings_are_exact as
      [_ [_ [_ [_ H32]]]].
    rewrite H32.
    unfold rank15_tunnel_floor_y. lia.
Qed.

(** Entering ACT_JUMP_KICK is replacement, not addition: the checked switch
    case writes 20 directly.  Consequently its idealized positive ascent is
    60 regardless of a previously conserved speed. *)
Theorem rank15_jump_kick_overwrites_instead_of_stacking :
  (forall stored_velocity,
    rank15_jump_kick_installed_velocity stored_velocity = 20) /\
  (forall stored_velocity,
    rank15_jump_kick_departure_ascent stored_velocity = 60) /\
  (forall stored_velocity,
    stored_velocity <> 0 ->
    rank15_jump_kick_installed_velocity stored_velocity <>
      stored_velocity + 20).
Proof.
  split.
  - intros stored_velocity. reflexivity.
  - split.
    + intros stored_velocity. vm_compute. reflexivity.
    + intros stored_velocity Hnonzero.
      unfold rank15_jump_kick_installed_velocity. lia.
Qed.

Definition EyerokRank15VSCBoundary : Prop :=
  EyerokRank15VSCSourceShape /\
  EyerokRank15Area3StaticGapReceipt /\
  rank15_tunnel_floor_y - find_floor_upward_buffer =
    rank15_tunnel_floor_query_min_y /\
  (forall seed,
    seed <= 31 ->
    rank15_ideal_ledge_query_ceiling seed < rank15_tunnel_floor_y) /\
  (rank15_ideal_ledge_query_ceiling 31 < rank15_tunnel_floor_y /\
   rank15_tunnel_floor_y <= rank15_ideal_ledge_query_ceiling 32) /\
  (forall stored_velocity,
    rank15_jump_kick_departure_ascent stored_velocity = 60).

Theorem eyerok_rank15_vsc_boundary_holds :
  EyerokRank15VSCBoundary.
Proof.
  unfold EyerokRank15VSCBoundary.
  refine (conj eyerok_rank15_vsc_source_shape_checked _).
  refine (conj eyerok_rank15_area3_static_gap_receipt_checked _).
  refine (conj rank15_query_threshold_matches_recorded_minimum _).
  refine (conj rank15_every_integral_seed_through_31_misses_tunnel _).
  refine (conj rank15_seed_32_is_first_arithmetic_threshold_witness _).
  exact (proj1 (proj2 rank15_jump_kick_overwrites_instead_of_stacking)).
Qed.
