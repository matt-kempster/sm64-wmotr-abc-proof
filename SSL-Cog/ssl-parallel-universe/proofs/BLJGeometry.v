From Coq Require Import Bool Lia List ZArith.
From compcert Require Import Clight Integers.
From SSLPU.Generated Require Import mario_actions_moving.
From SSLPU.Proofs Require Import BLJRoute Spec.

Local Open Scope Z_scope.

Import ListNotations.

Fixpoint expr_mentions_int_bits (bits : Z) (e : expr) : bool :=
  match e with
  | Evar _ _ => false
  | Etempvar _ _ => false
  | Econst_int value _ => Int.eq value (Int.repr bits)
  | Econst_float _ _ => false
  | Econst_single _ _ => false
  | Econst_long _ _ => false
  | Ederef inner _ => expr_mentions_int_bits bits inner
  | Eaddrof inner _ => expr_mentions_int_bits bits inner
  | Eunop _ inner _ => expr_mentions_int_bits bits inner
  | Ebinop _ lhs rhs _ =>
      expr_mentions_int_bits bits lhs || expr_mentions_int_bits bits rhs
  | Ecast inner _ => expr_mentions_int_bits bits inner
  | Efield inner _ _ => expr_mentions_int_bits bits inner
  | Esizeof _ _ => false
  | Ealignof _ _ => false
  end.

Fixpoint exprs_mentions_int_bits (bits : Z) (args : list expr) : bool :=
  match args with
  | [] => false
  | arg :: rest =>
      expr_mentions_int_bits bits arg ||
      exprs_mentions_int_bits bits rest
  end.

Fixpoint stmt_mentions_int_bits (bits : Z) (s : statement) : bool :=
  match s with
  | Sskip => false
  | Sassign lhs rhs =>
      expr_mentions_int_bits bits lhs || expr_mentions_int_bits bits rhs
  | Sset _ rhs => expr_mentions_int_bits bits rhs
  | Scall _ fn args =>
      expr_mentions_int_bits bits fn || exprs_mentions_int_bits bits args
  | Sbuiltin _ _ _ _ => false
  | Ssequence s1 s2 =>
      stmt_mentions_int_bits bits s1 || stmt_mentions_int_bits bits s2
  | Sifthenelse test s1 s2 =>
      expr_mentions_int_bits bits test ||
      stmt_mentions_int_bits bits s1 ||
      stmt_mentions_int_bits bits s2
  | Sloop s1 s2 =>
      stmt_mentions_int_bits bits s1 || stmt_mentions_int_bits bits s2
  | Sbreak => false
  | Scontinue => false
  | Sreturn None => false
  | Sreturn (Some value) => expr_mentions_int_bits bits value
  | Sswitch key cases =>
      expr_mentions_int_bits bits key || cases_mentions_int_bits bits cases
  | Slabel _ body => stmt_mentions_int_bits bits body
  | Sgoto _ => false
  end
with cases_mentions_int_bits
    (bits : Z) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      stmt_mentions_int_bits bits body ||
      cases_mentions_int_bits bits rest
  end.

Definition input_a_pressed_bits : Z := 2.
Definition input_z_down_bits : Z := 16384.

Record generated_landing_input_gate_shape : Prop := {
  shape_common_landing_cancels_checks_a_pressed :
    stmt_mentions_int_bits input_a_pressed_bits
      (fn_body mario_actions_moving.f_common_landing_cancels) = true;
  shape_long_jump_land_checks_z_down :
    stmt_mentions_int_bits input_z_down_bits
      (fn_body mario_actions_moving.f_act_long_jump_land) = true;
  shape_long_jump_land_contains_a_pressed_clear_operand :
    stmt_mentions_int_bits input_a_pressed_bits
      (fn_body mario_actions_moving.f_act_long_jump_land) = true;
  shape_long_jump_land_uses_generated_blj_rejump_path :
    generated_blj_source_shape
}.

Theorem generated_landing_input_gate_shape_holds :
  generated_landing_input_gate_shape.
Proof.
  constructor.
  - vm_compute. reflexivity.
  - vm_compute. reflexivity.
  - vm_compute. reflexivity.
  - exact generated_blj_source_shape_holds.
Qed.

Record recycle_input := {
  recycle_input_a_pressed : bool;
  recycle_input_z_down : bool
}.

Definition input_allows_long_jump_land_recycle
    (input : recycle_input) : Prop :=
  recycle_input_a_pressed input = true /\
  recycle_input_z_down input = true.

Definition a_z_recycle_input : recycle_input := {|
  recycle_input_a_pressed := true;
  recycle_input_z_down := true
|}.

Theorem a_z_recycle_input_allows_long_jump_land_recycle :
  input_allows_long_jump_land_recycle a_z_recycle_input.
Proof.
  split; reflexivity.
Qed.

Record collision_tread := {
  tread_min_x : Z;
  tread_max_x : Z;
  tread_y : Z;
  tread_min_z : Z;
  tread_max_z : Z
}.

Definition tread_in_area2_bounds (tread : collision_tread) : Prop :=
  coord_in_area2_bounds (tread_min_x tread) /\
  coord_in_area2_bounds (tread_max_x tread) /\
  coord_in_area2_bounds (tread_min_z tread) /\
  coord_in_area2_bounds (tread_max_z tread).

Definition lower_entry_narrow_treads : list collision_tread := [
  {| tread_min_x := -511; tread_max_x := 512;
     tread_y := 435; tread_min_z := -3685; tread_max_z := -3327 |};
  {| tread_min_x := -511; tread_max_x := 512;
     tread_y := 461; tread_min_z := -3722; tread_max_z := -3685 |};
  {| tread_min_x := -511; tread_max_x := 512;
     tread_y := 486; tread_min_z := -3759; tread_max_z := -3722 |};
  {| tread_min_x := -511; tread_max_x := 512;
     tread_y := 512; tread_min_z := -3796; tread_max_z := -3759 |};
  {| tread_min_x := -511; tread_max_x := 512;
     tread_y := 538; tread_min_z := -3833; tread_max_z := -3796 |};
  {| tread_min_x := -511; tread_max_x := 512;
     tread_y := 563; tread_min_z := -3870; tread_max_z := -3833 |};
  {| tread_min_x := -511; tread_max_x := 512;
     tread_y := 589; tread_min_z := -3907; tread_max_z := -3870 |};
  {| tread_min_x := -511; tread_max_x := 512;
     tread_y := 614; tread_min_z := -3943; tread_max_z := -3907 |}
].

Definition lower_entry_static_tread_capacity : nat :=
  length lower_entry_narrow_treads.

Definition static_tread_certificate_discharges_blj_envelope
    (treads : list collision_tread) : Prop :=
  (blj_recycle_count_to_first_pu <= length treads)%nat.

Theorem lower_entry_narrow_treads_in_area2_bounds :
  Forall tread_in_area2_bounds lower_entry_narrow_treads.
Proof.
  cbv [lower_entry_narrow_treads].
  do 8 (constructor;
    [ unfold tread_in_area2_bounds, coord_in_area2_bounds,
        ssl_area2_min, ssl_area2_max; cbn; lia
    | ]).
  constructor.
Qed.

Theorem lower_entry_static_tread_capacity_is_eight :
  lower_entry_static_tread_capacity = 8%nat.
Proof.
  reflexivity.
Qed.

Theorem lower_entry_static_tread_capacity_too_short_for_blj_envelope :
  (lower_entry_static_tread_capacity < blj_recycle_count_to_first_pu)%nat.
Proof.
  unfold lower_entry_static_tread_capacity, blj_recycle_count_to_first_pu.
  cbn.
  lia.
Qed.

Theorem lower_entry_static_tread_certificate_does_not_discharge_blj_envelope :
  ~ static_tread_certificate_discharges_blj_envelope
      lower_entry_narrow_treads.
Proof.
  unfold static_tread_certificate_discharges_blj_envelope,
    blj_recycle_count_to_first_pu.
  cbn.
  lia.
Qed.

Theorem ssl_area2_lower_entry_geometry_input_status :
  generated_landing_input_gate_shape /\
  input_allows_long_jump_land_recycle a_z_recycle_input /\
  Forall tread_in_area2_bounds lower_entry_narrow_treads /\
  lower_entry_static_tread_capacity = 8%nat /\
  ~ static_tread_certificate_discharges_blj_envelope
      lower_entry_narrow_treads.
Proof.
  split.
  - exact generated_landing_input_gate_shape_holds.
  - split.
    + exact a_z_recycle_input_allows_long_jump_land_recycle.
    + split.
      * exact lower_entry_narrow_treads_in_area2_bounds.
      * split.
        { exact lower_entry_static_tread_capacity_is_eight. }
        exact
          lower_entry_static_tread_certificate_does_not_discharge_blj_envelope.
Qed.
