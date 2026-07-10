From Coq Require Import Lia List ZArith.
From compcert Require Import AST Clight Floats Integers.
From SSLPU.Generated Require Import mario mario_actions_moving.
From SSLPU.Proofs Require Import ASTFacts MovementSourceFacts Spec.

Local Open Scope Z_scope.

Import ListNotations.

Fixpoint expr_mentions_var (needle : ident) (e : expr) : bool :=
  match e with
  | Evar found _ => Pos.eqb needle found
  | Etempvar _ _ => false
  | Econst_int _ _ => false
  | Econst_float _ _ => false
  | Econst_single _ _ => false
  | Econst_long _ _ => false
  | Ederef inner _ => expr_mentions_var needle inner
  | Eaddrof inner _ => expr_mentions_var needle inner
  | Eunop _ inner _ => expr_mentions_var needle inner
  | Ebinop _ lhs rhs _ =>
      expr_mentions_var needle lhs || expr_mentions_var needle rhs
  | Ecast inner _ => expr_mentions_var needle inner
  | Efield inner _ _ => expr_mentions_var needle inner
  | Esizeof _ _ => false
  | Ealignof _ _ => false
  end.

Fixpoint exprs_mentions_var (needle : ident) (args : list expr) : bool :=
  match args with
  | [] => false
  | arg :: rest => expr_mentions_var needle arg || exprs_mentions_var needle rest
  end.

Fixpoint stmt_mentions_var (needle : ident) (s : statement) : bool :=
  match s with
  | Sskip => false
  | Sassign lhs rhs =>
      expr_mentions_var needle lhs || expr_mentions_var needle rhs
  | Sset _ rhs => expr_mentions_var needle rhs
  | Scall _ fn args =>
      expr_mentions_var needle fn || exprs_mentions_var needle args
  | Sbuiltin _ _ _ _ => false
  | Ssequence s1 s2 =>
      stmt_mentions_var needle s1 || stmt_mentions_var needle s2
  | Sifthenelse test s1 s2 =>
      expr_mentions_var needle test ||
      stmt_mentions_var needle s1 ||
      stmt_mentions_var needle s2
  | Sloop s1 s2 =>
      stmt_mentions_var needle s1 || stmt_mentions_var needle s2
  | Sbreak => false
  | Scontinue => false
  | Sreturn None => false
  | Sreturn (Some value) => expr_mentions_var needle value
  | Sswitch key cases =>
      expr_mentions_var needle key || cases_mentions_var needle cases
  | Slabel _ body => stmt_mentions_var needle body
  | Sgoto _ => false
  end
with cases_mentions_var
    (needle : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      stmt_mentions_var needle body || cases_mentions_var needle rest
  end.

Fixpoint expr_mentions_float32_bits (bits : Z) (e : expr) : bool :=
  match e with
  | Evar _ _ => false
  | Etempvar _ _ => false
  | Econst_int _ _ => false
  | Econst_float _ _ => false
  | Econst_single value _ => Int.eq (Float32.to_bits value) (Int.repr bits)
  | Econst_long _ _ => false
  | Ederef inner _ => expr_mentions_float32_bits bits inner
  | Eaddrof inner _ => expr_mentions_float32_bits bits inner
  | Eunop _ inner _ => expr_mentions_float32_bits bits inner
  | Ebinop _ lhs rhs _ =>
      expr_mentions_float32_bits bits lhs ||
      expr_mentions_float32_bits bits rhs
  | Ecast inner _ => expr_mentions_float32_bits bits inner
  | Efield inner _ _ => expr_mentions_float32_bits bits inner
  | Esizeof _ _ => false
  | Ealignof _ _ => false
  end.

Fixpoint exprs_mentions_float32_bits (bits : Z) (args : list expr) : bool :=
  match args with
  | [] => false
  | arg :: rest =>
      expr_mentions_float32_bits bits arg ||
      exprs_mentions_float32_bits bits rest
  end.

Fixpoint stmt_mentions_float32_bits (bits : Z) (s : statement) : bool :=
  match s with
  | Sskip => false
  | Sassign lhs rhs =>
      expr_mentions_float32_bits bits lhs ||
      expr_mentions_float32_bits bits rhs
  | Sset _ rhs => expr_mentions_float32_bits bits rhs
  | Scall _ fn args =>
      expr_mentions_float32_bits bits fn ||
      exprs_mentions_float32_bits bits args
  | Sbuiltin _ _ _ _ => false
  | Ssequence s1 s2 =>
      stmt_mentions_float32_bits bits s1 ||
      stmt_mentions_float32_bits bits s2
  | Sifthenelse test s1 s2 =>
      expr_mentions_float32_bits bits test ||
      stmt_mentions_float32_bits bits s1 ||
      stmt_mentions_float32_bits bits s2
  | Sloop s1 s2 =>
      stmt_mentions_float32_bits bits s1 ||
      stmt_mentions_float32_bits bits s2
  | Sbreak => false
  | Scontinue => false
  | Sreturn None => false
  | Sreturn (Some value) => expr_mentions_float32_bits bits value
  | Sswitch key cases =>
      expr_mentions_float32_bits bits key ||
      cases_mentions_float32_bits bits cases
  | Slabel _ body => stmt_mentions_float32_bits bits body
  | Sgoto _ => false
  end
with cases_mentions_float32_bits
    (bits : Z) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      stmt_mentions_float32_bits bits body ||
      cases_mentions_float32_bits bits rest
  end.

Fixpoint find_case_body
    (key : Z) (cases : labeled_statements) : option statement :=
  match cases with
  | LSnil => None
  | LScons (Some found) body rest =>
      if Z.eqb key found then Some body else find_case_body key rest
  | LScons None _ rest => find_case_body key rest
  end.

Fixpoint find_switch_case_body_s (key : Z) (s : statement) : option statement :=
  match s with
  | Ssequence s1 s2 =>
      match find_switch_case_body_s key s1 with
      | Some body => Some body
      | None => find_switch_case_body_s key s2
      end
  | Sifthenelse _ s1 s2 =>
      match find_switch_case_body_s key s1 with
      | Some body => Some body
      | None => find_switch_case_body_s key s2
      end
  | Sloop s1 s2 =>
      match find_switch_case_body_s key s1 with
      | Some body => Some body
      | None => find_switch_case_body_s key s2
      end
  | Sswitch _ cases => find_case_body key cases
  | Slabel _ body => find_switch_case_body_s key body
  | _ => None
  end.

Definition act_long_jump : Z := 50333832.
Definition float32_one_point_five_bits : Z := 1069547520.
Definition float32_forty_eight_bits : Z := 1111490560.

Definition generated_airborne_long_jump_case_has_blj_speed_update : bool :=
  match find_switch_case_body_s
      act_long_jump (fn_body mario.f_set_mario_action_airborne) with
  | Some body =>
      assigns_through_field_s mario._forwardVel body &&
      stmt_mentions_float32_bits float32_one_point_five_bits body &&
      stmt_mentions_float32_bits float32_forty_eight_bits body
  | None => false
  end.

Record generated_blj_source_shape : Prop := {
  shape_airborne_long_jump_branch_updates_forward_vel :
    generated_airborne_long_jump_case_has_blj_speed_update = true;
  shape_long_jump_land_calls_common_landing_cancels :
    ident_mem mario_actions_moving._common_landing_cancels
      (direct_callees_s
        (fn_body mario_actions_moving.f_act_long_jump_land)) = true;
  shape_long_jump_land_mentions_rejump_callback :
    stmt_mentions_var mario_actions_moving._set_jumping_action
      (fn_body mario_actions_moving.f_act_long_jump_land) = true;
  shape_long_jump_land_mentions_long_jump_land_action :
    stmt_mentions_var mario_actions_moving._sLongJumpLandAction
      (fn_body mario_actions_moving.f_act_long_jump_land) = true;
  shape_us_long_jump_land_does_not_directly_assign_forward_vel :
    assigns_through_field_s mario_actions_moving._forwardVel
      (fn_body mario_actions_moving.f_act_long_jump_land) = false
}.

Theorem generated_blj_source_shape_holds :
  generated_blj_source_shape.
Proof.
  constructor; vm_compute; reflexivity.
Qed.

Definition required_negative_air_velocity_for_pu : Z :=
  4 * (first_parallel_universe - Z.abs ssl_area2_min).

Definition threshold_negative_air_velocity : Z :=
  - required_negative_air_velocity_for_pu.

Definition blj_recycle_count_to_first_pu : nat := 22%nat.

Fixpoint blj_speed_magnitude_num_after (cycles : nat) : Z :=
  match cycles with
  | O => 16
  | S rest => 3 * blj_speed_magnitude_num_after rest
  end.

Fixpoint blj_speed_magnitude_den_after (cycles : nat) : Z :=
  match cycles with
  | O => 1
  | S rest => 2 * blj_speed_magnitude_den_after rest
  end.

Definition blj_recycle_supplies_required_negative_velocity
    (cycles : nat) : Prop :=
  required_negative_air_velocity_for_pu *
    blj_speed_magnitude_den_after cycles <=
  blj_speed_magnitude_num_after cycles.

Theorem blj_22_recycles_reach_required_air_velocity :
  blj_recycle_supplies_required_negative_velocity
    blj_recycle_count_to_first_pu.
Proof.
  vm_compute.
  discriminate.
Qed.

Definition area2_negative_edge_state : pu_state :=
  {|
    state_area := ssl_area2;
    state_x := ssl_area2_min;
    state_z := 0
  |}.

Theorem area2_negative_edge_state_in_bounds :
  state_in_area2_bounds area2_negative_edge_state.
Proof.
  unfold area2_negative_edge_state, state_in_area2_bounds,
    coord_in_area2_bounds.
  simpl.
  split.
  - reflexivity.
  - split; unfold ssl_area2_min, ssl_area2_max; lia.
Qed.

Theorem threshold_negative_air_velocity_enters_parallel_universe :
  state_in_parallel_universe
    (unclamped_air_velocity_step
      area2_negative_edge_state threshold_negative_air_velocity 0).
Proof.
  left.
  unfold unclamped_air_velocity_step, area2_negative_edge_state,
    threshold_negative_air_velocity, required_negative_air_velocity_for_pu,
    parallel_universe_coord, first_parallel_universe, ssl_area2_min.
  simpl.
  replace (-8192 + - (4 * (32768 - 8192)) / 4) with (-32768)
    by (vm_compute; reflexivity).
  lia.
Qed.

Theorem ssl_area2_blj_source_counterexample_envelope :
  generated_blj_source_shape /\
  blj_recycle_supplies_required_negative_velocity
    blj_recycle_count_to_first_pu /\
  exists before after vx,
    state_in_area2_bounds before /\
    vx = threshold_negative_air_velocity /\
    after = unclamped_air_velocity_step before vx 0 /\
    state_in_parallel_universe after.
Proof.
  split.
  - exact generated_blj_source_shape_holds.
  - split.
    + exact blj_22_recycles_reach_required_air_velocity.
    + exists area2_negative_edge_state.
      exists (unclamped_air_velocity_step
        area2_negative_edge_state threshold_negative_air_velocity 0).
      exists threshold_negative_air_velocity.
      split.
      * exact area2_negative_edge_state_in_bounds.
      * split.
        { reflexivity. }
        split.
        { reflexivity. }
        exact threshold_negative_air_velocity_enters_parallel_universe.
Qed.
