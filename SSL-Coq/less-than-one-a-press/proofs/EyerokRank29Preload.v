(** Rank 29: stock no-A preload boundary for the sleeping-hand Pedro entry.

    The archived retail fixture establishes the conditional payoff: an
    injected forward speed of 424 crosses the hand's greater-than-100-unit
    wall band in one air quarter-step.  This file asks the independent source
    question.  It authenticates the Area-2/Area-3 roster, the normal entry
    reset, the speed-relevant stock constants, and the sleeping hand's actual
    control split.  In particular, the sleeping branch still loads collision
    but does not execute [obj_check_attacks], so the hand cannot be used as a
    repeatable bounce source while it supplies the Pedro geometry.

    The arithmetic kernel then grants a very generous 110-unit stock preload,
    the maximum positive 0.15-unit gain on every ordinary high-speed air
    update, a 100-unit initial vertical velocity, gravity of only one unit per
    frame, and a broad Y envelope containing both selected static meshes.  It
    takes 1,934 uninterrupted air updates to exceed speed 400, whereas even
    the first 400 updates cannot remain in that envelope.  An ordinary
    settled episode therefore reaches at most speed 170, or a 42.5-unit
    quarter-step.

    This is a checked reduction, not a universal controller-reachability
    theorem.  A successful clean counterexample must now exhibit the exact
    reset-evading boundary omitted by [Rank29OrdinaryPreload]: for example a
    repeated landing/off-floor or moving-platform transition that preserves
    accumulated air speed across episodes.  It may instead refute the roster,
    action, alias, or outside-call classification. *)

From Coq Require Import Bool Lia List ZArith.
From compcert Require Import AST Clight Integers.
From LessThanOneAPress.Proofs Require Import
  ASTFacts ClightFacts CollisionMeshFacts GameTypes AreaTransitions
  EyerokRank15VSC LongJumpProvenanceBoundary.

Import ListNotations.
Local Open Scope Z_scope.

(** * The sleeping branch has collision but no attack/bounce check *)

Definition rank29_is_zero_test (condition : expr) : bool :=
  match condition with
  | Ebinop Oeq (Etempvar _ _) (Econst_int found _) _
  | Ebinop Oeq (Econst_int found _) (Etempvar _ _) _ =>
      Int.eq found Int.zero
  | _ => false
  end.

Fixpoint rank29_contains_sleep_attack_split_s
    (sleep attack : ident) (body : statement) : bool :=
  match body with
  | Ssequence first second | Sloop first second =>
      rank29_contains_sleep_attack_split_s sleep attack first ||
      rank29_contains_sleep_attack_split_s sleep attack second
  | Sifthenelse condition yes_branch no_branch =>
      (rank29_is_zero_test condition &&
       calls_ident_s sleep yes_branch &&
       negb (calls_ident_s attack yes_branch) &&
       calls_ident_s attack no_branch) ||
      rank29_contains_sleep_attack_split_s sleep attack yes_branch ||
      rank29_contains_sleep_attack_split_s sleep attack no_branch
  | Sswitch _ cases =>
      rank29_contains_sleep_attack_split_ls sleep attack cases
  | Slabel _ nested =>
      rank29_contains_sleep_attack_split_s sleep attack nested
  | _ => false
  end
with rank29_contains_sleep_attack_split_ls
    (sleep attack : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      rank29_contains_sleep_attack_split_s sleep attack body ||
      rank29_contains_sleep_attack_split_ls sleep attack rest
  end.

Definition rank29_direct_call_count
    (callee : ident) (body : statement) : nat :=
  count_occ Pos.eq_dec (direct_callees_s body) callee.

Definition Rank29SleepingHandSourceShape : Prop :=
  rank29_contains_sleep_attack_split_s
    UEye._eyerok_hand_act_sleep UEye._obj_check_attacks
    (fn_body UEye.f_bhv_eyerok_hand_loop) = true /\
  rank29_direct_call_count UEye._eyerok_hand_act_sleep
    (fn_body UEye.f_bhv_eyerok_hand_loop) = 1%nat /\
  rank29_direct_call_count UEye._obj_check_attacks
    (fn_body UEye.f_bhv_eyerok_hand_loop) = 1%nat /\
  rank29_direct_call_count UEye._load_object_collision_model
    (fn_body UEye.f_bhv_eyerok_hand_loop) = 1%nat /\
  statement_mentions_array_slot_s UEye._asS32 49
    (fn_body UEye.f_bhv_eyerok_hand_loop) = true /\
  rank29_contains_sleep_attack_split_s
    JEye._eyerok_hand_act_sleep JEye._obj_check_attacks
    (fn_body JEye.f_bhv_eyerok_hand_loop) = true /\
  rank29_direct_call_count JEye._eyerok_hand_act_sleep
    (fn_body JEye.f_bhv_eyerok_hand_loop) = 1%nat /\
  rank29_direct_call_count JEye._obj_check_attacks
    (fn_body JEye.f_bhv_eyerok_hand_loop) = 1%nat /\
  rank29_direct_call_count JEye._load_object_collision_model
    (fn_body JEye.f_bhv_eyerok_hand_loop) = 1%nat /\
  statement_mentions_array_slot_s JEye._asS32 49
    (fn_body JEye.f_bhv_eyerok_hand_loop) = true.

Theorem rank29_sleeping_hand_source_shape_checked :
  Rank29SleepingHandSourceShape.
Proof.
  unfold Rank29SleepingHandSourceShape, rank29_direct_call_count.
  vm_compute. repeat split; reflexivity.
Qed.

(** * Exact Area-2/Area-3 object inventory *)

Definition rank29_area2_scripted_us : list ident :=
  initializer_addrof_idents (gvar_init USS.v_script_func_local_4) ++
  initializer_addrof_idents (gvar_init USS.v_script_func_local_5).

Definition rank29_area2_scripted_jp : list ident :=
  initializer_addrof_idents (gvar_init JSS.v_script_func_local_4) ++
  initializer_addrof_idents (gvar_init JSS.v_script_func_local_5).

Definition rank29_expected_area2_scripted_us : list ident :=
  [USS._bhvPoleGrabbing; USS._bhvPoleGrabbing;
   USS._bhvGrindel; USS._bhvHorizontalGrindel;
   USS._bhvHorizontalGrindel; USS._bhvSpindel;
   USS._bhvSSLMovingPyramidWall; USS._bhvSSLMovingPyramidWall;
   USS._bhvSSLMovingPyramidWall; USS._bhvSSLMovingPyramidWall;
   USS._bhvPyramidElevator;
   USS._bhvSandSoundLoop; USS._bhvSandSoundLoop;
   USS._bhvSandSoundLoop; USS._bhvStar; USS._bhvHiddenStar].

Definition rank29_expected_area2_scripted_jp : list ident :=
  [JSS._bhvPoleGrabbing; JSS._bhvPoleGrabbing;
   JSS._bhvGrindel; JSS._bhvHorizontalGrindel;
   JSS._bhvHorizontalGrindel; JSS._bhvSpindel;
   JSS._bhvSSLMovingPyramidWall; JSS._bhvSSLMovingPyramidWall;
   JSS._bhvSSLMovingPyramidWall; JSS._bhvSSLMovingPyramidWall;
   JSS._bhvPyramidElevator;
   JSS._bhvSandSoundLoop; JSS._bhvSandSoundLoop;
   JSS._bhvSandSoundLoop; JSS._bhvStar; JSS._bhvHiddenStar].

Fixpoint rank29_every_fifth (values : list Z) : list Z :=
  match values with
  | first :: _ :: _ :: _ :: _ :: rest =>
      first :: rank29_every_fifth rest
  | _ => []
  end.

Definition rank29_macro_preset_id (encoded : Z) : Z :=
  Z.land encoded 511 - 31.

Definition rank29_area2_macro_presets_us : list Z :=
  map rank29_macro_preset_id
    (rank29_every_fifth
      (init_int16_values (gvar_init UAM.v_ssl_seg7_area_2_macro_objs))).

Definition rank29_area2_macro_presets_jp : list Z :=
  map rank29_macro_preset_id
    (rank29_every_fifth
      (init_int16_values (gvar_init JAM.v_ssl_seg7_area_2_macro_objs))).

(** Coins, signs, Goombas, Amps, a recovery heart, 1-ups, switches, and
    hidden-star triggers are the only macro-preset classes in Area 2.  In
    particular this list excludes both cannons, both shell sources, Hoot,
    Tweester/tornado, Heave-Ho, Chuckya, Fly Guy, and the jumping box. *)
Definition rank29_allowed_area2_macro_preset (preset : Z) : bool :=
  existsb (Z.eqb preset)
    [0; 1; 6; 9; 10; 11; 14; 21; 32; 37; 38; 39; 44;
     46; 48; 49; 53; 54; 67].

Definition Rank29Area23RosterSourceShape : Prop :=
  rank29_area2_scripted_us = rank29_expected_area2_scripted_us /\
  rank29_area2_scripted_jp = rank29_expected_area2_scripted_jp /\
  length rank29_area2_macro_presets_us = 50%nat /\
  rank29_area2_macro_presets_us = rank29_area2_macro_presets_jp /\
  forallb rank29_allowed_area2_macro_preset
    rank29_area2_macro_presets_us = true /\
  initializer_addrof_idents (gvar_init USS.v_script_func_local_6) =
    [USS._bhvEyerokBoss] /\
  initializer_addrof_idents (gvar_init JSS.v_script_func_local_6) =
    [JSS._bhvEyerokBoss] /\
  gvar_init USS.v_ssl_seg7_area_3_macro_objs = [] /\
  gvar_init JSS.v_ssl_seg7_area_3_macro_objs = [].

Theorem rank29_area23_roster_source_shape_checked :
  Rank29Area23RosterSourceShape.
Proof.
  unfold Rank29Area23RosterSourceShape,
    rank29_area2_scripted_us, rank29_area2_scripted_jp,
    rank29_expected_area2_scripted_us,
    rank29_expected_area2_scripted_jp,
    rank29_area2_macro_presets_us, rank29_area2_macro_presets_jp,
    rank29_allowed_area2_macro_preset, rank29_macro_preset_id.
  vm_compute. repeat split; reflexivity.
Qed.

(** * Generated speed-source receipts *)

Definition rank29_float32_drag_bits : Z := 1051931443.       (* 0.35 *)
Definition rank29_float32_one_bits : Z := 1065353216.
Definition rank29_float32_one_point_five_bits : Z := 1069547520.
Definition rank29_float32_five_point_three_bits : Z := 1084856730.

Definition Rank29MotionSourceShape : Prop :=
  assigns_field_float32_constant_s UMI._forwardVel 0
    (fn_body UMI.f_init_mario) = true /\
  assigns_field_float32_constant_s JMI._forwardVel 0
    (fn_body JMI.f_init_mario) = true /\
  statement_mentions_ident_s ULU._forwardVel
    (fn_body ULU.f_check_instant_warp) = false /\
  statement_mentions_ident_s JLU._forwardVel
    (fn_body JLU.f_check_instant_warp) = false /\
  statement_mentions_float32_bits_s float32_forty_eight_bits
    (fn_body UMove.f_update_walking_speed) = true /\
  statement_mentions_float32_bits_s float32_forty_eight_bits
    (fn_body JMove.f_update_walking_speed) = true /\
  statement_mentions_float32_bits_s rank29_float32_five_point_three_bits
    (fn_body UMove.f_apply_slope_accel) = true /\
  statement_mentions_float32_bits_s rank29_float32_five_point_three_bits
    (fn_body JMove.f_apply_slope_accel) = true /\
  statement_mentions_float32_bits_s float32_ten_bits
    (fn_body UMove.f_update_sliding) = true /\
  statement_mentions_float32_bits_s float32_one_hundred_bits
    (fn_body UMove.f_update_sliding_angle) = true /\
  statement_mentions_float32_bits_s float32_ten_bits
    (fn_body JMove.f_update_sliding) = true /\
  statement_mentions_float32_bits_s float32_one_hundred_bits
    (fn_body JMove.f_update_sliding_angle) = true /\
  statement_mentions_float32_bits_s rank29_float32_drag_bits
    (fn_body UAir.f_update_air_with_turn) = true /\
  statement_mentions_float32_bits_s rank29_float32_one_point_five_bits
    (fn_body UAir.f_update_air_with_turn) = true /\
  statement_mentions_float32_bits_s rank29_float32_one_bits
    (fn_body UAir.f_update_air_with_turn) = true /\
  statement_mentions_float32_bits_s rank29_float32_drag_bits
    (fn_body UAir.f_update_air_without_turn) = true /\
  statement_mentions_float32_bits_s rank29_float32_one_point_five_bits
    (fn_body UAir.f_update_air_without_turn) = true /\
  statement_mentions_float32_bits_s rank29_float32_one_bits
    (fn_body UAir.f_update_air_without_turn) = true /\
  statement_mentions_float32_bits_s rank29_float32_drag_bits
    (fn_body JAir.f_update_air_with_turn) = true /\
  statement_mentions_float32_bits_s rank29_float32_one_point_five_bits
    (fn_body JAir.f_update_air_with_turn) = true /\
  statement_mentions_float32_bits_s rank29_float32_one_bits
    (fn_body JAir.f_update_air_with_turn) = true /\
  statement_mentions_float32_bits_s rank29_float32_drag_bits
    (fn_body JAir.f_update_air_without_turn) = true /\
  statement_mentions_float32_bits_s rank29_float32_one_point_five_bits
    (fn_body JAir.f_update_air_without_turn) = true /\
  statement_mentions_float32_bits_s rank29_float32_one_bits
    (fn_body JAir.f_update_air_without_turn) = true /\
  calls_ident_s UAir._check_horizontal_wind
    (fn_body UAir.f_update_air_with_turn) = true /\
  calls_ident_s JAir._check_horizontal_wind
    (fn_body JAir.f_update_air_with_turn) = true.

Theorem rank29_motion_source_shape_checked : Rank29MotionSourceShape.
Proof.
  unfold Rank29MotionSourceShape,
    rank29_float32_drag_bits, rank29_float32_one_bits,
    rank29_float32_one_point_five_bits,
    rank29_float32_five_point_three_bits.
  vm_compute. repeat split; reflexivity.
Qed.

(** * Selected collision-envelope receipt *)

Definition rank29_envelope_low : Z := -5000.
Definition rank29_envelope_high : Z := 7000.

Definition rank29_vertex_in_envelope (vertex : Z * Z * Z) : bool :=
  let '(_, y, _) := vertex in
  (rank29_envelope_low <=? y) && (y <=? rank29_envelope_high).

Definition Rank29SelectedStaticEnvelope : Prop :=
  forallb rank29_vertex_in_envelope area2_collision_vertices_us = true /\
  forallb rank29_vertex_in_envelope area2_collision_vertices_jp = true /\
  forallb rank29_vertex_in_envelope
    (rank15_area3_vertices rank15_area3_words_us) = true /\
  forallb rank29_vertex_in_envelope
    (rank15_area3_vertices rank15_area3_words_jp) = true.

Theorem rank29_selected_static_envelope_checked :
  Rank29SelectedStaticEnvelope.
Proof.
  unfold Rank29SelectedStaticEnvelope, rank29_vertex_in_envelope,
    rank29_envelope_low, rank29_envelope_high.
  vm_compute. repeat split; reflexivity.
Qed.

(** * Conservative speed and airtime arithmetic *)

(** Speeds are represented in hundredths of one game unit. *)
Definition rank29_stock_preload_cap : Z := 11000.
Definition rank29_air_gain_per_frame : Z := 15.
Definition rank29_required_speed : Z := 40000.
Definition rank29_ordinary_episode_frames : nat := 400.

Definition rank29_air_speed_upper (start : Z) (frames : nat) : Z :=
  start + rank29_air_gain_per_frame * Z.of_nat frames.

Theorem rank29_air_growth_threshold_checked :
  rank29_air_speed_upper rank29_stock_preload_cap 1933 = 39995 /\
  rank29_air_speed_upper rank29_stock_preload_cap 1934 = 40010 /\
  rank29_air_speed_upper rank29_stock_preload_cap
    rank29_ordinary_episode_frames = 17000 /\
  17000 / 4 = 4250.
Proof. vm_compute. repeat split; reflexivity. Qed.

Definition rank29_vertical_velocity_upper (frame : nat) : Z :=
  Z.max (-75) (100 - Z.of_nat frame).

Definition rank29_vertical_displacement_upper (frames : nat) : Z :=
  fold_right Z.add 0
    (map rank29_vertical_velocity_upper (seq 0 frames)).

Theorem rank29_four_hundred_frame_vertical_sum_checked :
  rank29_vertical_displacement_upper
    rank29_ordinary_episode_frames = -14600.
Proof. vm_compute. reflexivity. Qed.

(** This proposition is the exact condensed kinematic premise supplied by a
    100-or-lower initial vertical speed, at least one unit of gravity per
    frame, and the -75 terminal-velocity cap.  Both endpoints are required to
    stay in the deliberately broadened selected-area envelope. *)
Definition Rank29FourHundredFrameEnvelope
    (start_y finish_y : Z) : Prop :=
  rank29_envelope_low <= start_y /\
  start_y <= rank29_envelope_high /\
  rank29_envelope_low <= finish_y /\
  finish_y <= rank29_envelope_high /\
  finish_y - start_y <=
    rank29_vertical_displacement_upper rank29_ordinary_episode_frames.

Theorem rank29_four_hundred_frame_episode_cannot_stay_in_envelope :
  forall start_y finish_y,
    ~ Rank29FourHundredFrameEnvelope start_y finish_y.
Proof.
  intros start_y finish_y Hepisode.
  unfold Rank29FourHundredFrameEnvelope,
    rank29_envelope_low, rank29_envelope_high in Hepisode.
  rewrite rank29_four_hundred_frame_vertical_sum_checked in Hepisode.
  lia.
Qed.

Definition Rank29OrdinaryPreload (start finish : Z) : Prop :=
  start <= rank29_stock_preload_cap /\
  exists frames,
    (frames <= rank29_ordinary_episode_frames)%nat /\
    finish <= rank29_air_speed_upper start frames.

Theorem rank29_every_ordinary_preload_is_below_pedro_threshold :
  forall start finish,
    Rank29OrdinaryPreload start finish ->
    finish <= 17000 /\ finish < rank29_required_speed.
Proof.
  intros start finish [Hstart [frames [Hframes Hfinish]]].
  unfold rank29_air_speed_upper, rank29_air_gain_per_frame,
    rank29_stock_preload_cap, rank29_ordinary_episode_frames,
    rank29_required_speed in *.
  assert (Z.of_nat frames <= 400) by lia.
  lia.
Qed.

Theorem rank29_threshold_preload_requires_a_classification_escape :
  forall start finish,
    rank29_required_speed <= finish ->
    ~ Rank29OrdinaryPreload start finish.
Proof.
  intros start finish Hrequired Hordinary.
  pose proof
    (rank29_every_ordinary_preload_is_below_pedro_threshold
      start finish Hordinary) as [_ Hbelow].
  lia.
Qed.

(** * Public Rank-29 boundary *)

Record EyerokRank29PreloadBoundary : Prop := {
  rank29_boundary_sleeping_hand : Rank29SleepingHandSourceShape;
  rank29_boundary_roster : Rank29Area23RosterSourceShape;
  rank29_boundary_motion : Rank29MotionSourceShape;
  rank29_boundary_instant_warp :
    forall before after event,
      (event = EventInstantWarp2To3 \/ event = EventInstantWarp3To2) ->
      CertifiedStep before event after ->
      kinematic_core_equal
        (state_mario_kinematics after) (state_mario_kinematics before);
  rank29_boundary_long_jump_source : bilateral_long_jump_source_chain_claim;
  rank29_boundary_spindel_us : spindel_pu_station_source_shape_us_claim;
  rank29_boundary_spindel_jp : spindel_pu_station_source_shape_jp_claim;
  rank29_boundary_static_envelope : Rank29SelectedStaticEnvelope;
  rank29_boundary_air_threshold :
    rank29_air_speed_upper rank29_stock_preload_cap 1933 = 39995 /\
    rank29_air_speed_upper rank29_stock_preload_cap 1934 = 40010;
  rank29_boundary_no_400_frame_episode :
    forall start_y finish_y,
      ~ Rank29FourHundredFrameEnvelope start_y finish_y;
  rank29_boundary_ordinary_preload :
    forall start finish,
      Rank29OrdinaryPreload start finish ->
      finish < rank29_required_speed;
  rank29_boundary_escape_reduction :
    forall start finish,
      rank29_required_speed <= finish ->
      ~ Rank29OrdinaryPreload start finish
}.

Theorem eyerok_rank29_preload_boundary_holds :
  EyerokRank29PreloadBoundary.
Proof.
  constructor.
  - exact rank29_sleeping_hand_source_shape_checked.
  - exact rank29_area23_roster_source_shape_checked.
  - exact rank29_motion_source_shape_checked.
  - exact instant_warp_has_zero_displacement_core.
  - exact bilateral_long_jump_source_chain_checked.
  - exact spindel_pu_station_source_shape_us.
  - exact spindel_pu_station_source_shape_jp.
  - exact rank29_selected_static_envelope_checked.
  - pose proof rank29_air_growth_threshold_checked as [H1933 [H1934 _]].
    split; assumption.
  - exact rank29_four_hundred_frame_episode_cannot_stay_in_envelope.
  - intros start finish Hordinary.
    exact (proj2
      (rank29_every_ordinary_preload_is_below_pedro_threshold
        start finish Hordinary)).
  - exact rank29_threshold_preload_requires_a_classification_escape.
Qed.
