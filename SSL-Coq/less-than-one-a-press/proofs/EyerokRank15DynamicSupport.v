(** Rank 15: promote the archived two-hand dynamic-support barrier.

    [EyerokRank15ScheduleSearch] deliberately left seven upward-motion action
    classes as a geometry worklist.  Those classes were not wholly unaudited:
    the archived Eyerok development had already proved a deliberately generous
    two-hand vertical barrier.  This file reconstructs that argument inside the
    active project and anchors its numerical premises to the current US/JP
    generated ASTs and collision initializers.

    The barrier grants every source-shaped positive episode up to the largest
    checked rise, every Area-3 static upward floor, the tallest hand mesh in
    every phase, arbitrary stuttering, and a later hand landing on an earlier
    hand.  Even then the later hand's origin is at most Y=672, its surface is
    at most Y=1179, and a deliberately excessive 630-unit Mario rise reaches
    only Y=1809, below the Y=1889 query threshold for the Area-2 floor at 1967.

    This is not presented as a completed live-execution theorem.  The final
    section names the exact remaining bridge: project real states of the
    selected linked Clight program to the two live hand envelopes and classify
    every reached step with the relation proved here.  That projection must in
    particular derive the live floor owner, first/later list order, direct-pose
    cap, and the start of each positive episode. *)

From Coq Require Import Bool Lia List ZArith.
From compcert Require Import AST Clight Events Floats Globalenvs Integers.
From LessThanOneAPress.Proofs Require Import
  ASTFacts ClightFacts CollisionMeshFacts EyerokRank15VSC
  EyerokRank15ScheduleSearch
  GameTypes JPEyerokStaleHand JPEyerokStaleHandPU OrdinaryMotion
  PyramidTopPU SelectedClightTarget.

Import ListNotations.
Local Open Scope Z_scope.

(** * Exhaustive generated-handler write census *)

Fixpoint rank15_float32_constant_bits (expression : expr) : option Z :=
  match expression with
  | Econst_single value _ =>
      Some (Int.unsigned (Float32.to_bits value))
  | Eunop Oneg (Econst_single value _) _ =>
      Some (Int.unsigned (Float32.to_bits (Float32.neg value)))
  | Ecast inner _ => rank15_float32_constant_bits inner
  | _ => None
  end.

Fixpoint rank15_slot_assignment_bits_s
    (array_field : ident) (index : Z) (statement : statement) :
    list (option Z) :=
  match statement with
  | Sassign lhs rhs =>
      if expression_is_array_slot array_field index lhs
      then [rank15_float32_constant_bits rhs]
      else []
  | Ssequence first second | Sloop first second =>
      rank15_slot_assignment_bits_s array_field index first ++
      rank15_slot_assignment_bits_s array_field index second
  | Sifthenelse _ yes no =>
      rank15_slot_assignment_bits_s array_field index yes ++
      rank15_slot_assignment_bits_s array_field index no
  | Sswitch _ cases =>
      rank15_slot_assignment_bits_ls array_field index cases
  | Slabel _ body =>
      rank15_slot_assignment_bits_s array_field index body
  | _ => []
  end
with rank15_slot_assignment_bits_ls
    (array_field : ident) (index : Z) (cases : labeled_statements) :
    list (option Z) :=
  match cases with
  | LSnil => []
  | LScons _ body rest =>
      rank15_slot_assignment_bits_s array_field index body ++
      rank15_slot_assignment_bits_ls array_field index rest
  end.

Definition rank15_us_vertical_writer_functions : list function :=
  [UEye.f_eyerok_hand_check_attacked;
   UEye.f_eyerok_hand_act_sleep;
   UEye.f_eyerok_hand_act_idle;
   UEye.f_eyerok_hand_act_open;
   UEye.f_eyerok_hand_act_show_eye;
   UEye.f_eyerok_hand_act_close;
   UEye.f_eyerok_hand_act_attacked;
   UEye.f_eyerok_hand_act_recover;
   UEye.f_eyerok_hand_act_become_active;
   UEye.f_eyerok_hand_act_die;
   UEye.f_eyerok_hand_act_retreat;
   UEye.f_eyerok_hand_act_target_mario;
   UEye.f_eyerok_hand_act_smash;
   UEye.f_eyerok_hand_act_fist_push;
   UEye.f_eyerok_hand_act_fist_sweep;
   UEye.f_eyerok_hand_act_begin_double_pound;
   UEye.f_eyerok_hand_act_double_pound].

Definition rank15_jp_vertical_writer_functions : list function :=
  [JEye.f_eyerok_hand_check_attacked;
   JEye.f_eyerok_hand_act_sleep;
   JEye.f_eyerok_hand_act_idle;
   JEye.f_eyerok_hand_act_open;
   JEye.f_eyerok_hand_act_show_eye;
   JEye.f_eyerok_hand_act_close;
   JEye.f_eyerok_hand_act_attacked;
   JEye.f_eyerok_hand_act_recover;
   JEye.f_eyerok_hand_act_become_active;
   JEye.f_eyerok_hand_act_die;
   JEye.f_eyerok_hand_act_retreat;
   JEye.f_eyerok_hand_act_target_mario;
   JEye.f_eyerok_hand_act_smash;
   JEye.f_eyerok_hand_act_fist_push;
   JEye.f_eyerok_hand_act_fist_sweep;
   JEye.f_eyerok_hand_act_begin_double_pound;
   JEye.f_eyerok_hand_act_double_pound].

Definition rank15_function_slot_writes
    (array_field : ident) (index : Z) (functions : list function) :
    list (option Z) :=
  flat_map
    (fun body =>
      rank15_slot_assignment_bits_s array_field index (fn_body body))
    functions.

Definition rank15_float32_thirty_bits : Z := 1106247680.
Definition rank15_float32_fifty_bits : Z := 1112014848.
Definition rank15_float32_one_hundred_bits : Z := 1120403456.
Definition rank15_float32_negative_four_bits : Z := 3229614080.
Definition rank15_float32_negative_fifteen_bits : Z := 3245342720.
Definition rank15_float32_negative_twenty_bits : Z := 3248488448.
Definition rank15_float32_one_point_five_bits : Z := 1069547520.

(** Slot 10 is [oVelY] and slot 23 is [oGravity].  Because the collector
    retains [None] for a nonconstant right-hand side, these equalities also
    exclude a hidden computed assignment in the enumerated handler family. *)
Definition EyerokRank15VerticalWriterReceipt : Prop :=
  rank15_function_slot_writes UEye._asF32 10
      rank15_us_vertical_writer_functions =
    [Some rank15_float32_thirty_bits;
     Some rank15_float32_fifty_bits;
     Some rank15_float32_one_hundred_bits] /\
  rank15_function_slot_writes JEye._asF32 10
      rank15_jp_vertical_writer_functions =
    [Some rank15_float32_thirty_bits;
     Some rank15_float32_fifty_bits;
     Some rank15_float32_one_hundred_bits] /\
  rank15_function_slot_writes UEye._asF32 23
      rank15_us_vertical_writer_functions =
    [Some rank15_float32_negative_four_bits;
     Some 0; Some 0;
     Some rank15_float32_negative_four_bits;
     Some rank15_float32_negative_four_bits;
     Some rank15_float32_negative_twenty_bits;
     Some rank15_float32_negative_fifteen_bits;
     Some rank15_float32_negative_twenty_bits] /\
  rank15_function_slot_writes JEye._asF32 23
      rank15_jp_vertical_writer_functions =
    [Some rank15_float32_negative_four_bits;
     Some 0; Some 0;
     Some rank15_float32_negative_four_bits;
     Some rank15_float32_negative_four_bits;
     Some rank15_float32_negative_twenty_bits;
     Some rank15_float32_negative_fifteen_bits;
     Some rank15_float32_negative_twenty_bits].

Theorem eyerok_rank15_vertical_writer_receipt_checked :
  EyerokRank15VerticalWriterReceipt.
Proof.
  unfold EyerokRank15VerticalWriterReceipt,
    rank15_function_slot_writes,
    rank15_us_vertical_writer_functions,
    rank15_jp_vertical_writer_functions,
    rank15_float32_thirty_bits, rank15_float32_fifty_bits,
    rank15_float32_one_hundred_bits,
    rank15_float32_negative_four_bits,
    rank15_float32_negative_fifteen_bits,
    rank15_float32_negative_twenty_bits.
  vm_compute. repeat split; reflexivity.
Qed.

(** The common movement tail, collision reload, 1.5 scale, and terrain-before-
    nonterrain scheduling order are all present in both generated programs.
    These are syntax receipts; the later projection obligation is what turns
    them into statements about one live pair of hands. *)
Definition EyerokRank15DynamicSupportSourceShape : Prop :=
  EyerokRank15ScheduleSourceReceipt /\
  EyerokRank15VerticalWriterReceipt /\
  calls_ident_s UOH._cur_obj_move_y
    (fn_body UOH.f_cur_obj_move_standard) = true /\
  calls_ident_s JOH._cur_obj_move_y
    (fn_body JOH.f_cur_obj_move_standard) = true /\
  calls_ident_s UOH._cur_obj_move_y_and_get_water_level
    (fn_body UOH.f_cur_obj_move_y) = true /\
  calls_ident_s JOH._cur_obj_move_y_and_get_water_level
    (fn_body JOH.f_cur_obj_move_y) = true /\
  statement_mentions_float32_bits_s rank15_float32_one_point_five_bits
    (fn_body UEye.f_eyerok_spawn_hand) = true /\
  statement_mentions_float32_bits_s rank15_float32_one_point_five_bits
    (fn_body JEye.f_eyerok_spawn_hand) = true /\
  ident_subsequenceb
    [UEye._obj_check_attacks; UEye._cur_obj_move_standard;
     UEye._load_object_collision_model]
    (direct_callees_s (fn_body UEye.f_bhv_eyerok_hand_loop)) = true /\
  ident_subsequenceb
    [JEye._obj_check_attacks; JEye._cur_obj_move_standard;
     JEye._load_object_collision_model]
    (direct_callees_s (fn_body JEye.f_bhv_eyerok_hand_loop)) = true /\
  ident_subsequenceb
    [UOL._clear_dynamic_surfaces; UOL._update_terrain_objects;
     UOL._apply_mario_platform_displacement;
     UOL._update_non_terrain_objects; UOL._unload_deactivated_objects;
     UOL._update_mario_platform]
    (direct_callees_s (fn_body UOL.f_update_objects)) = true /\
  ident_subsequenceb
    [JOL._clear_dynamic_surfaces; JOL._update_terrain_objects;
     JOL._apply_mario_platform_displacement;
     JOL._update_non_terrain_objects; JOL._unload_deactivated_objects;
     JOL._update_mario_platform]
    (direct_callees_s (fn_body JOL.f_update_objects)) = true.

Theorem eyerok_rank15_dynamic_support_source_shape_checked :
  EyerokRank15DynamicSupportSourceShape.
Proof.
  unfold EyerokRank15DynamicSupportSourceShape.
  refine (conj eyerok_rank15_schedule_source_receipt_checked _).
  refine (conj eyerok_rank15_vertical_writer_receipt_checked _).
  vm_compute. repeat split; reflexivity.
Qed.

(** * Complete static and hand-mesh ceilings *)

Definition rank15_upward_triangle_at_most
    (bound : Z) (vertices : list Rank15Vertex)
    (triangle : Z * Z * Z) : bool :=
  match rank15_triangle_vertices vertices triangle with
  | Some triangle_vertices =>
      if Z.ltb 0 (rank15_triangle_normal_y triangle_vertices)
      then Z.leb (rank15_triangle_max_y triangle_vertices) bound
      else true
  | None => false
  end.

Definition rank15_vertex_y_at_most
    (bound : Z) (vertex : Z * Z * Z) : bool :=
  let '(_, y, _) := vertex in Z.leb y bound.

Definition rank15_vertex_y_equals
    (expected : Z) (vertex : Z * Z * Z) : bool :=
  let '(_, y, _) := vertex in Z.eqb y expected.

Definition rank15_collision_vertices_of {V : Type}
    (count : nat) (variable : globvar V) : list (Z * Z * Z) :=
  collision_vertices_from_words count
    (init_int16_values (gvar_init variable)).

Definition rank15_us_eyerok_hand_vertices : list (Z * Z * Z) :=
  rank15_collision_vertices_of 8
      UCollision.v_ssl_seg7_collision_07028274 ++
  rank15_collision_vertices_of 8
      UCollision.v_ssl_seg7_collision_070282F8 ++
  rank15_collision_vertices_of 19
      UCollision.v_ssl_seg7_collision_07028370 ++
  rank15_collision_vertices_of 19
      UCollision.v_ssl_seg7_collision_070284B0.

Definition rank15_jp_eyerok_hand_vertices : list (Z * Z * Z) :=
  rank15_collision_vertices_of 8
      JCollision.v_ssl_seg7_collision_07028274 ++
  rank15_collision_vertices_of 8
      JCollision.v_ssl_seg7_collision_070282F8 ++
  rank15_collision_vertices_of 19
      JCollision.v_ssl_seg7_collision_07028370 ++
  rank15_collision_vertices_of 19
      JCollision.v_ssl_seg7_collision_070284B0.

Definition EyerokRank15DynamicGeometryReceipt : Prop :=
  EyerokRank15Area3StaticGapReceipt /\
  forallb
    (rank15_upward_triangle_at_most 384
      (rank15_area3_vertices rank15_area3_words_us))
    (rank15_area3_triangles rank15_area3_words_us) = true /\
  forallb
    (rank15_upward_triangle_at_most 384
      (rank15_area3_vertices rank15_area3_words_jp))
    (rank15_area3_triangles rank15_area3_words_jp) = true /\
  length rank15_us_eyerok_hand_vertices = 54%nat /\
  length rank15_jp_eyerok_hand_vertices = 54%nat /\
  forallb (rank15_vertex_y_at_most 338)
    rank15_us_eyerok_hand_vertices = true /\
  forallb (rank15_vertex_y_at_most 338)
    rank15_jp_eyerok_hand_vertices = true /\
  existsb (rank15_vertex_y_equals 338)
    rank15_us_eyerok_hand_vertices = true /\
  existsb (rank15_vertex_y_equals 338)
    rank15_jp_eyerok_hand_vertices = true /\
  3 * 338 = 2 * 507.

Theorem eyerok_rank15_dynamic_geometry_receipt_checked :
  EyerokRank15DynamicGeometryReceipt.
Proof.
  unfold EyerokRank15DynamicGeometryReceipt.
  refine (conj eyerok_rank15_area3_static_gap_receipt_checked _).
  unfold rank15_us_eyerok_hand_vertices,
    rank15_jp_eyerok_hand_vertices,
    rank15_collision_vertices_of.
  vm_compute. repeat split; reflexivity.
Qed.

(** The three genuine positive episodes integrate to 98, 288, and 285 after
    their checked first-frame gravity.  Thus 288 is a common conservative
    budget; the other four worklist classes are handled by the direct-pose or
    nonrising constructors below rather than being silently discarded. *)
Definition rank15_attacked_ascent_budget : Z :=
  accumulated_positive_ascent 26 4 8.
Definition rank15_die_ascent_budget : Z :=
  accumulated_positive_ascent 46 4 13.
Definition rank15_double_pound_ascent_budget : Z :=
  accumulated_positive_ascent 85 15 6.
Definition rank15_upward_episode_cap : Z := 288.

Theorem eyerok_rank15_positive_episode_budgets_checked :
  rank15_attacked_ascent_budget = 98 /\
  rank15_die_ascent_budget = 288 /\
  rank15_double_pound_ascent_budget = 285 /\
  0 <= rank15_attacked_ascent_budget <= rank15_upward_episode_cap /\
  0 <= rank15_die_ascent_budget <= rank15_upward_episode_cap /\
  0 <= rank15_double_pound_ascent_budget <= rank15_upward_episode_cap.
Proof.
  unfold rank15_attacked_ascent_budget, rank15_die_ascent_budget,
    rank15_double_pound_ascent_budget, rank15_upward_episode_cap.
  refine (conj eq_refl _).
  refine (conj eq_refl _).
  refine (conj eq_refl _).
  refine (conj _ _).
  - change (0 <= 98 <= 288). split; lia.
  - refine (conj _ _).
    + change (0 <= 288 <= 288). split; lia.
    + change (0 <= 285 <= 288). split; lia.
Qed.

(** * Promoted two-hand barrier *)

Definition rank15_eyerok_home_y : Z := -1534.
Definition rank15_direct_pose_y_cap : Z := -934.
Definition rank15_arena_floor_y_cap : Z := -1150.
Definition rank15_area3_floor_y_cap : Z := 384.
Definition rank15_hand_surface_offset_cap : Z := 507.
Definition rank15_first_origin_cap : Z :=
  rank15_arena_floor_y_cap + rank15_upward_episode_cap.
Definition rank15_later_origin_cap : Z :=
  rank15_area3_floor_y_cap + rank15_upward_episode_cap.
Definition rank15_later_surface_cap : Z :=
  rank15_later_origin_cap + rank15_hand_surface_offset_cap.
Definition rank15_granted_mario_rise : Z := 630.
Definition rank15_granted_mario_peak : Z :=
  rank15_later_surface_cap + rank15_granted_mario_rise.
Definition rank15_area2_floor_y : Z := 1967.
Definition rank15_area2_floor_query_min : Z :=
  rank15_area2_floor_y - find_floor_upward_buffer.

(** This is the vertical part of [find_floor]'s 78-unit acceptance window.
    It explains why the static-gap receipt is useful: an earlier hand bounded
    at -862 cannot select the next static band beginning at -562.  The live
    bridge must still show that the returned surface is one of the parsed
    upward triangles and that no dynamic later-hand surface precedes it. *)
Definition rank15_floor_height_within_query
    (query_y floor_y : Z) : Prop :=
  floor_y <= query_y + find_floor_upward_buffer.

Lemma rank15_first_cap_excludes_tunnel_floor_query :
  forall query_y floor_y,
    query_y <= -862 ->
    -562 <= floor_y ->
    ~ rank15_floor_height_within_query query_y floor_y.
Proof.
  unfold rank15_floor_height_within_query, find_floor_upward_buffer.
  intros; lia.
Qed.

Inductive Rank15HandEnvelopeMode : Type :=
| Rank15Controlled
| Rank15Ballistic
| Rank15Deleted.

Record Rank15HandEnvelope : Type := {
  rank15_hand_mode : Rank15HandEnvelopeMode;
  rank15_hand_y : Z;
  rank15_hand_remaining_rise : Z
}.

Record Rank15HandPair : Type := {
  rank15_earlier_hand : Rank15HandEnvelope;
  rank15_later_hand : Rank15HandEnvelope
}.

Definition rank15_initial_hand : Rank15HandEnvelope :=
  {| rank15_hand_mode := Rank15Controlled;
     rank15_hand_y := rank15_eyerok_home_y;
     rank15_hand_remaining_rise := 0 |}.

Definition rank15_initial_pair : Rank15HandPair :=
  {| rank15_earlier_hand := rank15_initial_hand;
     rank15_later_hand := rank15_initial_hand |}.

Definition rank15_first_hand_safe (hand : Rank15HandEnvelope) : Prop :=
  0 <= rank15_hand_remaining_rise hand <= rank15_upward_episode_cap /\
  rank15_hand_y hand + rank15_hand_remaining_rise hand <=
    rank15_first_origin_cap.

Definition rank15_later_hand_safe (hand : Rank15HandEnvelope) : Prop :=
  0 <= rank15_hand_remaining_rise hand <= rank15_upward_episode_cap /\
  rank15_hand_y hand + rank15_hand_remaining_rise hand <=
    rank15_later_origin_cap.

Definition rank15_hand_pair_safe (pair : Rank15HandPair) : Prop :=
  rank15_first_hand_safe (rank15_earlier_hand pair) /\
  rank15_later_hand_safe (rank15_later_hand pair).

Inductive Rank15FirstHandStep :
    Rank15HandEnvelope -> Rank15HandEnvelope -> Prop :=
| rank15_first_direct : forall before target,
    rank15_hand_mode before <> Rank15Deleted ->
    target <= rank15_direct_pose_y_cap ->
    Rank15FirstHandStep before
      {| rank15_hand_mode := Rank15Controlled;
         rank15_hand_y := target;
         rank15_hand_remaining_rise := 0 |}
| rank15_first_land : forall before floor_y,
    rank15_hand_mode before <> Rank15Deleted ->
    floor_y <= rank15_arena_floor_y_cap ->
    Rank15FirstHandStep before
      {| rank15_hand_mode := Rank15Controlled;
         rank15_hand_y := floor_y;
         rank15_hand_remaining_rise := 0 |}
| rank15_first_launch : forall before budget,
    rank15_hand_mode before <> Rank15Deleted ->
    rank15_hand_y before <= rank15_arena_floor_y_cap ->
    0 <= budget <= rank15_upward_episode_cap ->
    Rank15FirstHandStep before
      {| rank15_hand_mode := Rank15Ballistic;
         rank15_hand_y := rank15_hand_y before;
         rank15_hand_remaining_rise := budget |}
| rank15_first_rise : forall before delta,
    rank15_hand_mode before = Rank15Ballistic ->
    0 <= delta <= rank15_hand_remaining_rise before ->
    Rank15FirstHandStep before
      {| rank15_hand_mode := Rank15Ballistic;
         rank15_hand_y := rank15_hand_y before + delta;
         rank15_hand_remaining_rise :=
           rank15_hand_remaining_rise before - delta |}
| rank15_first_nonrise : forall before next_y,
    next_y <= rank15_hand_y before ->
    Rank15FirstHandStep before
      {| rank15_hand_mode := rank15_hand_mode before;
         rank15_hand_y := next_y;
         rank15_hand_remaining_rise :=
           rank15_hand_remaining_rise before |}
| rank15_first_stutter : forall hand,
    Rank15FirstHandStep hand hand
| rank15_first_delete : forall before,
    Rank15FirstHandStep before
      {| rank15_hand_mode := Rank15Deleted;
         rank15_hand_y := rank15_hand_y before;
         rank15_hand_remaining_rise := 0 |}.

Inductive Rank15LaterHandStep (earlier : Rank15HandEnvelope) :
    Rank15HandEnvelope -> Rank15HandEnvelope -> Prop :=
| rank15_later_direct : forall before target,
    rank15_hand_mode before <> Rank15Deleted ->
    target <= rank15_direct_pose_y_cap ->
    Rank15LaterHandStep earlier before
      {| rank15_hand_mode := Rank15Controlled;
         rank15_hand_y := target;
         rank15_hand_remaining_rise := 0 |}
| rank15_later_static_support : forall before floor_y,
    floor_y <= rank15_area3_floor_y_cap ->
    Rank15LaterHandStep earlier before
      {| rank15_hand_mode := rank15_hand_mode before;
         rank15_hand_y := floor_y;
         rank15_hand_remaining_rise :=
           rank15_hand_remaining_rise before |}
| rank15_later_first_support : forall before floor_y,
    floor_y <= rank15_hand_y earlier + rank15_hand_surface_offset_cap ->
    Rank15LaterHandStep earlier before
      {| rank15_hand_mode := rank15_hand_mode before;
         rank15_hand_y := floor_y;
         rank15_hand_remaining_rise :=
           rank15_hand_remaining_rise before |}
| rank15_later_launch : forall before budget,
    rank15_hand_mode before <> Rank15Deleted ->
    rank15_hand_y before <= rank15_area3_floor_y_cap ->
    0 <= budget <= rank15_upward_episode_cap ->
    Rank15LaterHandStep earlier before
      {| rank15_hand_mode := Rank15Ballistic;
         rank15_hand_y := rank15_hand_y before;
         rank15_hand_remaining_rise := budget |}
| rank15_later_rise : forall before delta,
    rank15_hand_mode before = Rank15Ballistic ->
    0 <= delta <= rank15_hand_remaining_rise before ->
    Rank15LaterHandStep earlier before
      {| rank15_hand_mode := Rank15Ballistic;
         rank15_hand_y := rank15_hand_y before + delta;
         rank15_hand_remaining_rise :=
           rank15_hand_remaining_rise before - delta |}
| rank15_later_nonrise : forall before next_y,
    next_y <= rank15_hand_y before ->
    Rank15LaterHandStep earlier before
      {| rank15_hand_mode := rank15_hand_mode before;
         rank15_hand_y := next_y;
         rank15_hand_remaining_rise :=
           rank15_hand_remaining_rise before |}
| rank15_later_stutter : forall hand,
    Rank15LaterHandStep earlier hand hand
| rank15_later_delete : forall before,
    Rank15LaterHandStep earlier before
      {| rank15_hand_mode := Rank15Deleted;
         rank15_hand_y := rank15_hand_y before;
         rank15_hand_remaining_rise := 0 |}.

(** One classified abstract chunk changes at most one hand envelope.  A chunk
    is intentionally larger than a Clight small step: the generated movement
    helper stores velocity, optionally clamps it, and only then stores Y.
    [EyerokRank15LiveProjection] supplies the connected-step chunking and the
    memory observations at its endpoints. *)
Inductive Rank15HandPairStep : Rank15HandPair -> Rank15HandPair -> Prop :=
| rank15_pair_first : forall pair next_first,
    Rank15FirstHandStep (rank15_earlier_hand pair) next_first ->
    Rank15HandPairStep pair
      {| rank15_earlier_hand := next_first;
         rank15_later_hand := rank15_later_hand pair |}
| rank15_pair_later : forall pair next_later,
    Rank15LaterHandStep (rank15_earlier_hand pair)
      (rank15_later_hand pair) next_later ->
    Rank15HandPairStep pair
      {| rank15_earlier_hand := rank15_earlier_hand pair;
         rank15_later_hand := next_later |}.

Lemma rank15_initial_pair_safe :
  rank15_hand_pair_safe rank15_initial_pair.
Proof.
  unfold rank15_hand_pair_safe, rank15_first_hand_safe,
    rank15_later_hand_safe, rank15_initial_pair, rank15_initial_hand,
    rank15_eyerok_home_y, rank15_upward_episode_cap,
    rank15_first_origin_cap, rank15_later_origin_cap,
    rank15_arena_floor_y_cap, rank15_area3_floor_y_cap.
  cbn. repeat split; lia.
Qed.

Lemma rank15_first_step_preserves_safe : forall before after,
  rank15_first_hand_safe before ->
  Rank15FirstHandStep before after ->
  rank15_first_hand_safe after.
Proof.
  intros before after Hsafe Hstep.
  unfold rank15_first_hand_safe in *.
  destruct Hsafe as (Hbudget & Hsum).
  destruct Hstep; cbn in *;
    unfold rank15_first_origin_cap, rank15_arena_floor_y_cap,
      rank15_direct_pose_y_cap, rank15_upward_episode_cap in *.
  - split; [split |]; lia.
  - split; [split |]; lia.
  - split; [exact H1 | lia].
  - split; [split |]; lia.
  - split; [exact Hbudget | lia].
  - split; assumption.
  - split; [split |]; lia.
Qed.

Lemma rank15_later_step_preserves_safe : forall earlier before after,
  rank15_first_hand_safe earlier ->
  rank15_later_hand_safe before ->
  Rank15LaterHandStep earlier before after ->
  rank15_later_hand_safe after.
Proof.
  intros earlier before after Hearlier Hsafe Hstep.
  unfold rank15_first_hand_safe in Hearlier.
  unfold rank15_later_hand_safe in *.
  destruct Hearlier as ((Hearlier_budget_nonnegative & _) & Hearlier_sum).
  destruct Hsafe as (Hbudget & Hsum).
  destruct Hstep; cbn in *;
    unfold rank15_later_origin_cap, rank15_first_origin_cap,
      rank15_area3_floor_y_cap, rank15_arena_floor_y_cap,
      rank15_hand_surface_offset_cap, rank15_direct_pose_y_cap,
      rank15_upward_episode_cap in *.
  - split; [split |]; lia.
  - split; [exact Hbudget | lia].
  - split; [exact Hbudget | lia].
  - split; [exact H1 | lia].
  - split; [split |]; lia.
  - split; [exact Hbudget | lia].
  - split; assumption.
  - split; [split |]; lia.
Qed.

Theorem rank15_pair_step_preserves_safe : forall before after,
  rank15_hand_pair_safe before ->
  Rank15HandPairStep before after ->
  rank15_hand_pair_safe after.
Proof.
  intros before after [Hfirst Hlater] Hstep.
  destruct Hstep as [pair next_first Hfirst_step
                    | pair next_later Hlater_step]; cbn in *.
  - split.
    + eapply rank15_first_step_preserves_safe; eauto.
    + exact Hlater.
  - split.
    + exact Hfirst.
    + eapply rank15_later_step_preserves_safe; eauto.
Qed.

(** Deletion is genuinely absorbing.  An earlier draft allowed [direct],
    [land], or [launch] to turn a deleted envelope back into a live one.  That
    did not weaken the arithmetic ceiling, but it hid exactly the same-slot
    reuse/lifetime escape that the live projection must expose. *)
Lemma rank15_first_deleted_mode_is_absorbing : forall before after,
  rank15_hand_mode before = Rank15Deleted ->
  Rank15FirstHandStep before after ->
  rank15_hand_mode after = Rank15Deleted.
Proof.
  intros before after Hdeleted Hstep.
  destruct Hstep; cbn in *; try congruence.
Qed.

Lemma rank15_later_deleted_mode_is_absorbing : forall earlier before after,
  rank15_hand_mode before = Rank15Deleted ->
  Rank15LaterHandStep earlier before after ->
  rank15_hand_mode after = Rank15Deleted.
Proof.
  intros earlier before after Hdeleted Hstep.
  destruct Hstep; cbn in *; try congruence.
Qed.

Inductive Rank15HandPairReachable : Rank15HandPair -> Prop :=
| rank15_pair_reachable_initial :
    Rank15HandPairReachable rank15_initial_pair
| rank15_pair_reachable_step : forall before after,
    Rank15HandPairReachable before ->
    Rank15HandPairStep before after ->
    Rank15HandPairReachable after.

Theorem rank15_every_reachable_pair_safe : forall pair,
  Rank15HandPairReachable pair -> rank15_hand_pair_safe pair.
Proof.
  intros pair Hreachable. induction Hreachable.
  - exact rank15_initial_pair_safe.
  - eapply rank15_pair_step_preserves_safe; eauto.
Qed.

Theorem rank15_reachable_vertical_ceiling : forall pair,
  Rank15HandPairReachable pair ->
  rank15_hand_y (rank15_earlier_hand pair) <= -862 /\
  rank15_hand_y (rank15_earlier_hand pair) +
      rank15_hand_surface_offset_cap <= -355 /\
  rank15_hand_y (rank15_later_hand pair) <= 672 /\
  rank15_hand_y (rank15_later_hand pair) +
      rank15_hand_surface_offset_cap <= 1179 /\
  rank15_hand_y (rank15_later_hand pair) +
      rank15_hand_surface_offset_cap + rank15_granted_mario_rise <= 1809 /\
  rank15_hand_y (rank15_later_hand pair) +
      rank15_hand_surface_offset_cap + rank15_granted_mario_rise <
    rank15_area2_floor_query_min.
Proof.
  intros pair Hreachable.
  pose proof (rank15_every_reachable_pair_safe pair Hreachable)
    as [Hfirst Hlater].
  unfold rank15_first_hand_safe in Hfirst.
  unfold rank15_later_hand_safe in Hlater.
  destruct Hfirst as ((Hfirst_nonnegative & _) & Hfirst_sum).
  destruct Hlater as ((Hlater_nonnegative & _) & Hlater_sum).
  unfold rank15_first_origin_cap, rank15_later_origin_cap,
    rank15_arena_floor_y_cap, rank15_area3_floor_y_cap,
    rank15_upward_episode_cap, rank15_hand_surface_offset_cap,
    rank15_granted_mario_rise, rank15_area2_floor_query_min,
    rank15_area2_floor_y, find_floor_upward_buffer in *.
  repeat split; lia.
Qed.

Definition EyerokRank15TwoHandBarrierCertificate : Prop :=
  rank15_first_origin_cap = -862 /\
  rank15_later_origin_cap = 672 /\
  rank15_later_surface_cap = 1179 /\
  rank15_granted_mario_peak = 1809 /\
  rank15_area2_floor_query_min = 1889 /\
  (forall query_y floor_y,
    query_y <= -862 ->
    -562 <= floor_y ->
    ~ rank15_floor_height_within_query query_y floor_y) /\
  forall pair, Rank15HandPairReachable pair ->
    rank15_hand_y (rank15_later_hand pair) +
        rank15_hand_surface_offset_cap + rank15_granted_mario_rise <
      rank15_area2_floor_query_min.

Theorem eyerok_rank15_two_hand_barrier_certificate_holds :
  EyerokRank15TwoHandBarrierCertificate.
Proof.
  unfold EyerokRank15TwoHandBarrierCertificate,
    rank15_first_origin_cap, rank15_later_origin_cap,
    rank15_later_surface_cap, rank15_granted_mario_peak,
    rank15_area2_floor_query_min, rank15_arena_floor_y_cap,
    rank15_area3_floor_y_cap, rank15_upward_episode_cap,
    rank15_hand_surface_offset_cap, rank15_granted_mario_rise,
    rank15_area2_floor_y, find_floor_upward_buffer.
  repeat split; try reflexivity.
  - intros query_y floor_y Hquery Hfloor.
    exact (rank15_first_cap_excludes_tunnel_floor_query
      query_y floor_y Hquery Hfloor).
  - intros pair Hreachable.
    exact (proj2 (proj2 (proj2 (proj2 (proj2
      (rank15_reachable_vertical_ceiling pair Hreachable)))))).
Qed.

(** * Superseded micro-step bridge *)

(** This older relation is retained for compatibility, but is no longer the
    accepted live bridge: demanding one complete envelope transition after
    every Clight micro-step cuts the velocity update apart from the following
    position store.  The replacement module uses nonempty connected chunks
    and exact [Mem.load] observations, so a constant [project_pair] cannot
    satisfy its endpoint facts. *)
Inductive Rank15SelectedClightPairRun
    (version : GameVersion) (start : Clight.state)
    (project_pair : Clight.state -> option Rank15HandPair) :
    Clight.state -> Rank15HandPair -> Prop :=
| rank15_selected_pair_run_start :
    project_pair start = Some rank15_initial_pair ->
    Rank15SelectedClightPairRun version start project_pair
      start rank15_initial_pair
| rank15_selected_pair_run_step :
    forall before after before_pair after_pair step_trace,
      Rank15SelectedClightPairRun version start project_pair
        before before_pair ->
      Clight.step2 (Clight.globalenv (selected_clight_target version))
        before step_trace after ->
      project_pair after = Some after_pair ->
      Rank15HandPairStep before_pair after_pair ->
      Rank15SelectedClightPairRun version start project_pair
        after after_pair.

Theorem rank15_selected_clight_pair_run_is_safe :
  forall version start project_pair state pair,
    Rank15SelectedClightPairRun version start project_pair state pair ->
    rank15_hand_pair_safe pair.
Proof.
  intros version start project_pair state pair Hrun.
  induction Hrun.
  - exact rank15_initial_pair_safe.
  - eapply rank15_pair_step_preserves_safe; eauto.
Qed.

Theorem rank15_selected_clight_pair_run_misses_area2_query :
  forall version start project_pair state pair,
    Rank15SelectedClightPairRun version start project_pair state pair ->
    rank15_hand_y (rank15_later_hand pair) +
        rank15_hand_surface_offset_cap + rank15_granted_mario_rise <
      rank15_area2_floor_query_min.
Proof.
  intros version start project_pair state pair Hrun.
  assert (Hreachable : Rank15HandPairReachable pair).
  { induction Hrun.
    - exact rank15_pair_reachable_initial.
    - eapply rank15_pair_reachable_step; eauto. }
  exact (proj2 (proj2 (proj2 (proj2 (proj2
    (rank15_reachable_vertical_ceiling pair Hreachable)))))).
Qed.

Definition EyerokRank15DynamicSupportBoundary : Prop :=
  EyerokRank15DynamicSupportSourceShape /\
  EyerokRank15DynamicGeometryReceipt /\
  EyerokRank15TwoHandBarrierCertificate /\
  (forall version start project_pair state pair,
    Rank15SelectedClightPairRun version start project_pair state pair ->
    rank15_hand_y (rank15_later_hand pair) +
        rank15_hand_surface_offset_cap + rank15_granted_mario_rise <
      rank15_area2_floor_query_min).

Theorem eyerok_rank15_dynamic_support_boundary_holds :
  EyerokRank15DynamicSupportBoundary.
Proof.
  unfold EyerokRank15DynamicSupportBoundary.
  refine (conj eyerok_rank15_dynamic_support_source_shape_checked _).
  refine (conj eyerok_rank15_dynamic_geometry_receipt_checked _).
  refine (conj eyerok_rank15_two_hand_barrier_certificate_holds _).
  exact rank15_selected_clight_pair_run_misses_area2_query.
Qed.

Print Assumptions eyerok_rank15_dynamic_support_boundary_holds.
