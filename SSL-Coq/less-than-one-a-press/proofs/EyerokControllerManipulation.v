(** Controller-facing consequences of Eyerok's stock state machine.

    This file answers a narrower question than the route certificates: which
    hand decisions can Mario influence with ordinary movement?  The generated
    US/JP Clight receipts below authenticate the relevant handlers, calls,
    action writes, constants, and end-of-loop order.  The small executable
    model then exposes the exact Z gates and sweep choices.

    It is deliberately not a linked-execution or controller-reachability
    theorem.  In particular, it does not assert that Mario can reach every
    witness pose at the required frame, that a steered hand remains usable as
    a platform, or that any manipulation reaches either target star. *)

From Coq Require Import Bool Lia List ZArith.
From compcert Require Import AST Clight.
From LessThanOneAPress.Proofs Require Import ASTFacts ClightFacts.

Import ListNotations.
Local Open Scope Z_scope.

(** * Generated-source receipts *)

Definition EyerokControllerSourceShape : Prop :=
  (** The boss's fight scheduler reads the 400-unit Z predicate, uses RNG for
      the sixth-cycle formation, and clamps Mario's captured Z. *)
  calls_ident_s UEye._eyerok_check_mario_relative_z
    (fn_body UEye.f_eyerok_boss_act_fight) = true /\
  calls_ident_s UEye._random_u16
    (fn_body UEye.f_eyerok_boss_act_fight) = true /\
  calls_ident_s UEye._clamp_f32
    (fn_body UEye.f_eyerok_boss_act_fight) = true /\
  statement_mentions_int_s 400
    (fn_body UEye.f_eyerok_boss_act_fight) = true /\
  calls_ident_s JEye._eyerok_check_mario_relative_z
    (fn_body JEye.f_eyerok_boss_act_fight) = true /\
  calls_ident_s JEye._random_u16
    (fn_body JEye.f_eyerok_boss_act_fight) = true /\
  calls_ident_s JEye._clamp_f32
    (fn_body JEye.f_eyerok_boss_act_fight) = true /\
  statement_mentions_int_s 400
    (fn_body JEye.f_eyerok_boss_act_fight) = true /\
  (** A selected idle hand chooses TARGET_MARIO or FIST_PUSH. *)
  calls_ident_s UEye._eyerok_check_mario_relative_z
    (fn_body UEye.f_eyerok_hand_act_idle) = true /\
  calls_ident_s UEye._random_u16
    (fn_body UEye.f_eyerok_hand_act_idle) = true /\
  assigns_array_slot_int_constant_s UEye._asS32 49 6
    (fn_body UEye.f_eyerok_hand_act_idle) = true /\
  assigns_array_slot_int_constant_s UEye._asS32 49 8
    (fn_body UEye.f_eyerok_hand_act_idle) = true /\
  calls_ident_s JEye._eyerok_check_mario_relative_z
    (fn_body JEye.f_eyerok_hand_act_idle) = true /\
  calls_ident_s JEye._random_u16
    (fn_body JEye.f_eyerok_hand_act_idle) = true /\
  assigns_array_slot_int_constant_s JEye._asS32 49 6
    (fn_body JEye.f_eyerok_hand_act_idle) = true /\
  assigns_array_slot_int_constant_s JEye._asS32 49 8
    (fn_body JEye.f_eyerok_hand_act_idle) = true /\
  (** TARGET_MARIO continuously turns toward Mario, approaches speed 50, and
      has the source's 1700-Z and 900-X stop boundaries. *)
  calls_ident_s UEye._obj_forward_vel_approach
    (fn_body UEye.f_eyerok_hand_act_target_mario) = true /\
  calls_ident_s UEye._cur_obj_rotate_yaw_toward
    (fn_body UEye.f_eyerok_hand_act_target_mario) = true /\
  statement_mentions_float32_bits_s 1154777088
    (fn_body UEye.f_eyerok_hand_act_target_mario) = true /\
  statement_mentions_float32_bits_s 1147207680
    (fn_body UEye.f_eyerok_hand_act_target_mario) = true /\
  calls_ident_s JEye._obj_forward_vel_approach
    (fn_body JEye.f_eyerok_hand_act_target_mario) = true /\
  calls_ident_s JEye._cur_obj_rotate_yaw_toward
    (fn_body JEye.f_eyerok_hand_act_target_mario) = true /\
  statement_mentions_float32_bits_s 1154777088
    (fn_body JEye.f_eyerok_hand_act_target_mario) = true /\
  statement_mentions_float32_bits_s 1147207680
    (fn_body JEye.f_eyerok_hand_act_target_mario) = true /\
  (** Both smash and push can enter the sideways sweep; the two signs are
      selected from Mario-relative position. *)
  assigns_array_slot_int_constant_s UEye._asS32 49 9
    (fn_body UEye.f_eyerok_hand_act_smash) = true /\
  statement_mentions_int_s 8192
    (fn_body UEye.f_eyerok_hand_act_smash) = true /\
  statement_mentions_int_s 24576
    (fn_body UEye.f_eyerok_hand_act_smash) = true /\
  assigns_array_slot_int_constant_s UEye._asS32 49 9
    (fn_body UEye.f_eyerok_hand_act_fist_push) = true /\
  statement_mentions_float32_bits_s 1112014848
    (fn_body UEye.f_eyerok_hand_act_fist_push) = true /\
  assigns_array_slot_int_constant_s JEye._asS32 49 9
    (fn_body JEye.f_eyerok_hand_act_smash) = true /\
  statement_mentions_int_s 8192
    (fn_body JEye.f_eyerok_hand_act_smash) = true /\
  statement_mentions_int_s 24576
    (fn_body JEye.f_eyerok_hand_act_smash) = true /\
  assigns_array_slot_int_constant_s JEye._asS32 49 9
    (fn_body JEye.f_eyerok_hand_act_fist_push) = true /\
  statement_mentions_float32_bits_s 1112014848
    (fn_body JEye.f_eyerok_hand_act_fist_push) = true /\
  (** Attack receipt is sampled after the action handler and before movement;
      collision is reloaded after either the sleep or active branch. *)
  ident_subsequenceb
    [UEye._obj_check_attacks; UEye._cur_obj_move_standard;
     UEye._load_object_collision_model]
    (direct_callees_s (fn_body UEye.f_bhv_eyerok_hand_loop)) = true /\
  ident_subsequenceb
    [JEye._obj_check_attacks; JEye._cur_obj_move_standard;
     JEye._load_object_collision_model]
    (direct_callees_s (fn_body JEye.f_bhv_eyerok_hand_loop)) = true.

Theorem eyerok_controller_source_shape_checked :
  EyerokControllerSourceShape.
Proof.
  unfold EyerokControllerSourceShape.
  vm_compute. repeat split; reflexivity.
Qed.

(** * Exact arena gates *)

Definition eyerok_boss_home_z : Z := -3693.
Definition eyerok_hand_home_z : Z := -3393.
Definition eyerok_relative_gate : Z := 400.

Definition eyerok_boss_near (mario_z : Z) : bool :=
  mario_z <? eyerok_boss_home_z + eyerok_relative_gate.

Definition eyerok_hand_near (mario_z : Z) : bool :=
  mario_z <? eyerok_hand_home_z + eyerok_relative_gate.

Definition eyerok_target_selection_strip (mario_z : Z) : bool :=
  (-3293 <=? mario_z) && (mario_z <? -2993).

Inductive EyerokNormalAttack : Type :=
| EyerokTargetMario
| EyerokFistPush.

Definition eyerok_normal_attack
    (mario_z : Z) (random_odd : bool) : EyerokNormalAttack :=
  if eyerok_hand_near mario_z || random_odd
  then EyerokTargetMario
  else EyerokFistPush.

Theorem eyerok_target_strip_exact (mario_z : Z) :
  eyerok_target_selection_strip mario_z = true ->
  eyerok_boss_near mario_z = false /\
  eyerok_hand_near mario_z = true.
Proof.
  unfold eyerok_target_selection_strip, eyerok_boss_near,
    eyerok_hand_near, eyerok_boss_home_z, eyerok_hand_home_z,
    eyerok_relative_gate.
  rewrite Bool.andb_true_iff, Z.leb_le, Z.ltb_lt.
  intros [Hlow Hhigh].
  split.
  - apply Z.ltb_ge. lia.
  - apply Z.ltb_lt. lia.
Qed.

Theorem eyerok_target_strip_defeats_attack_rng
    (mario_z : Z) (random_odd : bool) :
  eyerok_target_selection_strip mario_z = true ->
  eyerok_normal_attack mario_z random_odd = EyerokTargetMario.
Proof.
  intros Hstrip.
  destruct (eyerok_target_strip_exact mario_z Hstrip) as [_ Hnear].
  unfold eyerok_normal_attack. rewrite Hnear. reflexivity.
Qed.

Theorem eyerok_position_alone_cannot_force_fist_push :
  ~ exists mario_z,
      forall random_odd,
        eyerok_normal_attack mario_z random_odd = EyerokFistPush.
Proof.
  intros [mario_z Hall].
  specialize (Hall true).
  unfold eyerok_normal_attack in Hall.
  destruct (eyerok_hand_near mario_z); discriminate.
Qed.

(** Mario can stand at -2994 for deterministic TARGET selection and move only
    two units forward before the hand's next sample.  The next pose is beyond
    the hand-relative near gate, so that gate no longer immediately stops the
    chase. *)
Theorem eyerok_two_unit_target_handoff :
  eyerok_target_selection_strip (-2994) = true /\
  eyerok_normal_attack (-2994) false = EyerokTargetMario /\
  eyerok_hand_near (-2992) = false.
Proof. vm_compute. repeat split. Qed.

(** * Boss schedule manipulation *)

Inductive EyerokBossChoice : Type :=
| EyerokNegativeDoublePound
| EyerokPositiveDoublePound
| EyerokSingleHand (side : Z).

Definition eyerok_selected_side (counter : Z) : Z :=
  if Z.odd counter then 1 else -1.

Definition eyerok_new_boss_choice
    (mario_z counter : Z) (both_hands : bool) : EyerokBossChoice :=
  if eyerok_boss_near mario_z then EyerokNegativeDoublePound
  else if both_hands && Z.eqb (counter mod 6) 0
       then EyerokPositiveDoublePound
       else EyerokSingleHand (eyerok_selected_side counter).

Theorem eyerok_boss_position_examples :
  eyerok_new_boss_choice (-3294) 5 true = EyerokNegativeDoublePound /\
  eyerok_new_boss_choice (-2994) 5 true = EyerokSingleHand 1 /\
  eyerok_new_boss_choice (-2994) 6 true = EyerokPositiveDoublePound /\
  eyerok_selected_side 1 = 1 /\
  eyerok_selected_side 2 = -1.
Proof. vm_compute. repeat split. Qed.

Definition eyerok_advance_negative_counter
    (mario_z counter : Z) : Z :=
  if eyerok_boss_near mario_z then counter
  else if Z.eqb (counter + 1) 0 then 1 else counter + 1.

Fixpoint eyerok_iterate_negative_release
    (updates : nat) (mario_z counter : Z) : Z :=
  match updates with
  | O => counter
  | S rest =>
      eyerok_iterate_negative_release rest mario_z
        (eyerok_advance_negative_counter mario_z counter)
  end.

Theorem eyerok_negative_loop_hold_and_release :
  eyerok_iterate_negative_release 100 (-3294) (-8) = -8 /\
  eyerok_iterate_negative_release 7 (-3293) (-8) = -1 /\
  eyerok_iterate_negative_release 8 (-3293) (-8) = 1.
Proof. vm_compute. repeat split. Qed.

(** The positive sixth-cycle formation captures Mario's Z and clamps it to
    boss Z + 400 through boss Z + 1600. *)
Definition eyerok_formation_target_z (mario_z : Z) : Z :=
  Z.max (-3293) (Z.min (-2093) mario_z).

Theorem eyerok_formation_target_z_bounds (mario_z : Z) :
  -3293 <= eyerok_formation_target_z mario_z <= -2093.
Proof.
  unfold eyerok_formation_target_z.
  split.
  - apply Z.le_max_l.
  - apply Z.max_lub; [lia |].
    destruct (Z_le_dec (-2093) mario_z) as [Hge | Hlt].
    + rewrite Z.min_l by exact Hge. lia.
    + rewrite Z.min_r by lia. lia.
Qed.

Theorem eyerok_formation_examples :
  eyerok_formation_target_z (-4000) = -3293 /\
  eyerok_formation_target_z (-2500) = -2500 /\
  eyerok_formation_target_z (-1000) = -2093.
Proof. vm_compute. repeat split. Qed.

(** * Chase and sweep positioning *)

Definition eyerok_target_stops
    (mario_z hand_x hand_z boss_x boss_z : Z)
    (hit_wall : bool) : bool :=
  eyerok_hand_near mario_z ||
  (mario_z <? hand_z) ||
  (1700 <? hand_z - boss_z) ||
  (900 <? Z.abs (hand_x - boss_x)) ||
  hit_wall.

Theorem eyerok_central_target_can_continue_after_handoff :
  eyerok_target_stops (-2992) (-500) (-3393) 0 (-3693) false = false.
Proof. vm_compute. reflexivity. Qed.

Inductive EyerokSweepDirection : Type :=
| EyerokSweepPositiveX
| EyerokSweepNegativeX.

Definition eyerok_push_sweep_direction
    (hand_x mario_x : Z) : EyerokSweepDirection :=
  if hand_x <? mario_x
  then EyerokSweepPositiveX
  else EyerokSweepNegativeX.

Definition eyerok_smash_can_sweep
    (distance angle_difference : Z) : bool :=
  (distance <? 300) &&
  (8192 <? angle_difference) && (angle_difference <? 24576).

Definition eyerok_smash_sweep_direction
    (face_minus_mario_angle : Z) : EyerokSweepDirection :=
  if face_minus_mario_angle <? 0
  then EyerokSweepPositiveX
  else EyerokSweepNegativeX.

Theorem eyerok_controller_can_choose_push_sweep_sign :
  eyerok_push_sweep_direction 0 1 = EyerokSweepPositiveX /\
  eyerok_push_sweep_direction 0 (-1) = EyerokSweepNegativeX.
Proof. vm_compute. split; reflexivity. Qed.

Theorem eyerok_controller_can_choose_smash_sweep_sign :
  eyerok_smash_can_sweep 299 16384 = true /\
  eyerok_smash_sweep_direction (-1) = EyerokSweepPositiveX /\
  eyerok_smash_sweep_direction 1 = EyerokSweepNegativeX.
Proof. vm_compute. repeat split. Qed.

Definition EyerokControllerManipulationBoundary : Prop :=
  EyerokControllerSourceShape /\
  eyerok_target_selection_strip (-2994) = true /\
  eyerok_normal_attack (-2994) false = EyerokTargetMario /\
  eyerok_hand_near (-2992) = false /\
  eyerok_iterate_negative_release 100 (-3294) (-8) = -8 /\
  eyerok_iterate_negative_release 8 (-3293) (-8) = 1 /\
  eyerok_target_stops (-2992) (-500) (-3393) 0 (-3693) false = false /\
  eyerok_push_sweep_direction 0 1 = EyerokSweepPositiveX /\
  eyerok_push_sweep_direction 0 (-1) = EyerokSweepNegativeX.

Theorem eyerok_controller_manipulation_boundary_holds :
  EyerokControllerManipulationBoundary.
Proof.
  unfold EyerokControllerManipulationBoundary.
  refine (conj eyerok_controller_source_shape_checked _).
  vm_compute. repeat split.
Qed.
