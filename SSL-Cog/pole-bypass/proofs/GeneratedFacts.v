From Coq Require Import Bool List PArith.BinPos ZArith.
From compcert Require Import AST Clight Floats Integers.
From SSLPoleBypass.Generated Require Import behavior_actions interaction mario
  mario_actions_airborne mario_actions_automatic mario_step
  object_list_processor pole_model.

Import ListNotations.

Fixpoint direct_callees_s (s : statement) : list ident :=
  match s with
  | Scall _ (Evar id _) _ => [id]
  | Ssequence s1 s2 => direct_callees_s s1 ++ direct_callees_s s2
  | Sifthenelse _ s1 s2 => direct_callees_s s1 ++ direct_callees_s s2
  | Sloop s1 s2 => direct_callees_s s1 ++ direct_callees_s s2
  | Slabel _ body => direct_callees_s body
  | Sswitch _ cases => direct_callees_ls cases
  | _ => []
  end
with direct_callees_ls (cases : labeled_statements) : list ident :=
  match cases with
  | LSnil => []
  | LScons _ body rest => direct_callees_s body ++ direct_callees_ls rest
  end.

Fixpoint ident_mem (needle : ident) (ids : list ident) : bool :=
  match ids with
  | [] => false
  | id :: rest => Pos.eqb needle id || ident_mem needle rest
  end.

Fixpoint expr_mentions_int_bits (bits : Z) (e : expr) : bool :=
  match e with
  | Econst_int value _ => Int.eq value (Int.repr bits)
  | Ederef inner _ | Eaddrof inner _ | Eunop _ inner _ | Ecast inner _ =>
      expr_mentions_int_bits bits inner
  | Ebinop _ lhs rhs _ =>
      expr_mentions_int_bits bits lhs || expr_mentions_int_bits bits rhs
  | Efield inner _ _ => expr_mentions_int_bits bits inner
  | _ => false
  end.

Fixpoint exprs_mentions_int_bits (bits : Z) (args : list expr) : bool :=
  match args with
  | [] => false
  | arg :: rest =>
      expr_mentions_int_bits bits arg || exprs_mentions_int_bits bits rest
  end.

Fixpoint stmt_mentions_int_bits (bits : Z) (s : statement) : bool :=
  match s with
  | Sassign lhs rhs =>
      expr_mentions_int_bits bits lhs || expr_mentions_int_bits bits rhs
  | Sset _ rhs => expr_mentions_int_bits bits rhs
  | Scall _ fn args =>
      expr_mentions_int_bits bits fn || exprs_mentions_int_bits bits args
  | Ssequence s1 s2 =>
      stmt_mentions_int_bits bits s1 || stmt_mentions_int_bits bits s2
  | Sifthenelse test s1 s2 =>
      expr_mentions_int_bits bits test ||
      stmt_mentions_int_bits bits s1 || stmt_mentions_int_bits bits s2
  | Sloop s1 s2 => stmt_mentions_int_bits bits s1 || stmt_mentions_int_bits bits s2
  | Sreturn (Some value) => expr_mentions_int_bits bits value
  | Sswitch key cases =>
      expr_mentions_int_bits bits key || cases_mentions_int_bits bits cases
  | Slabel _ body => stmt_mentions_int_bits bits body
  | _ => false
  end
with cases_mentions_int_bits (bits : Z) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      stmt_mentions_int_bits bits body || cases_mentions_int_bits bits rest
  end.

Fixpoint expr_mentions_float32_bits (bits : Z) (e : expr) : bool :=
  match e with
  | Econst_single value _ => Int.eq (Float32.to_bits value) (Int.repr bits)
  | Ederef inner _ | Eaddrof inner _ | Eunop _ inner _ | Ecast inner _ =>
      expr_mentions_float32_bits bits inner
  | Ebinop _ lhs rhs _ =>
      expr_mentions_float32_bits bits lhs || expr_mentions_float32_bits bits rhs
  | Efield inner _ _ => expr_mentions_float32_bits bits inner
  | _ => false
  end.

Fixpoint exprs_mentions_float32_bits (bits : Z) (args : list expr) : bool :=
  match args with
  | [] => false
  | arg :: rest =>
      expr_mentions_float32_bits bits arg || exprs_mentions_float32_bits bits rest
  end.

Fixpoint stmt_mentions_float32_bits (bits : Z) (s : statement) : bool :=
  match s with
  | Sassign lhs rhs =>
      expr_mentions_float32_bits bits lhs || expr_mentions_float32_bits bits rhs
  | Sset _ rhs => expr_mentions_float32_bits bits rhs
  | Scall _ fn args =>
      expr_mentions_float32_bits bits fn || exprs_mentions_float32_bits bits args
  | Ssequence s1 s2 =>
      stmt_mentions_float32_bits bits s1 || stmt_mentions_float32_bits bits s2
  | Sifthenelse test s1 s2 =>
      expr_mentions_float32_bits bits test ||
      stmt_mentions_float32_bits bits s1 || stmt_mentions_float32_bits bits s2
  | Sloop s1 s2 =>
      stmt_mentions_float32_bits bits s1 || stmt_mentions_float32_bits bits s2
  | Sreturn (Some value) => expr_mentions_float32_bits bits value
  | Sswitch key cases =>
      expr_mentions_float32_bits bits key || cases_mentions_float32_bits bits cases
  | Slabel _ body => stmt_mentions_float32_bits bits body
  | _ => false
  end
with cases_mentions_float32_bits (bits : Z) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      stmt_mentions_float32_bits bits body ||
      cases_mentions_float32_bits bits rest
  end.

Fixpoint expr_mentions_field (field : ident) (e : expr) : bool :=
  match e with
  | Ederef inner _ | Eaddrof inner _ | Eunop _ inner _ | Ecast inner _ =>
      expr_mentions_field field inner
  | Ebinop _ lhs rhs _ =>
      expr_mentions_field field lhs || expr_mentions_field field rhs
  | Efield inner found _ =>
      Pos.eqb found field || expr_mentions_field field inner
  | _ => false
  end.

Fixpoint assigns_through_field_s (field : ident) (s : statement) : bool :=
  match s with
  | Sassign lhs _ => expr_mentions_field field lhs
  | Ssequence s1 s2 =>
      assigns_through_field_s field s1 || assigns_through_field_s field s2
  | Sifthenelse _ s1 s2 =>
      assigns_through_field_s field s1 || assigns_through_field_s field s2
  | Sloop s1 s2 =>
      assigns_through_field_s field s1 || assigns_through_field_s field s2
  | Slabel _ body => assigns_through_field_s field body
  | Sswitch _ cases => assigns_through_field_ls field cases
  | _ => false
  end
with assigns_through_field_ls (field : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      assigns_through_field_s field body || assigns_through_field_ls field rest
  end.

Fixpoint stmt_contains_loop (s : statement) : bool :=
  match s with
  | Ssequence s1 s2 => stmt_contains_loop s1 || stmt_contains_loop s2
  | Sifthenelse _ s1 s2 => stmt_contains_loop s1 || stmt_contains_loop s2
  | Sloop _ _ => true
  | Sswitch _ cases => cases_contain_loop cases
  | Slabel _ body => stmt_contains_loop body
  | _ => false
  end
with cases_contain_loop (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest => stmt_contains_loop body || cases_contain_loop rest
  end.

Definition float32_point_three_five_bits : Z := 1051931443.
Definition float32_two_bits : Z := 1073741824.
Definition float32_four_bits : Z := 1082130432.
Definition float32_twenty_four_bits : Z := 1103101952.
Definition float32_sixty_two_bits : Z := 1115160576.
Definition float32_one_hundred_bits : Z := 1120403456.

Definition act_wall_kick_air : Z := 50333830.
Definition act_top_of_pole_jump : Z := 50333837.
Definition act_soft_bonk : Z := 16910518.

Record generated_pole_model_shape : Prop := {
  model_soft_certificate_calls_init_input_and_air :
    direct_callees_s (fn_body pole_model.f_soft_bonk_misses_sixth_floor) =
      [pole_model._pole_route_init; pole_model._pole_route_input;
       pole_model._pole_route_air_frame];
  model_jump_certificate_calls_init_two_inputs_and_air :
    direct_callees_s (fn_body pole_model.f_one_a_jump_clears_sixth_floor_hole) =
      [pole_model._pole_route_init; pole_model._pole_route_input;
       pole_model._pole_route_input; pole_model._pole_route_air_frame];
  model_air_frame_calls_conservative_push :
    ident_mem pole_model._conservative_pole_push
      (direct_callees_s (fn_body pole_model.f_pole_route_air_frame)) = true;
  model_soft_certificate_is_bounded_loop :
    stmt_contains_loop (fn_body pole_model.f_soft_bonk_misses_sixth_floor) = true;
  model_jump_certificate_is_bounded_loop :
    stmt_contains_loop (fn_body pole_model.f_one_a_jump_clears_sixth_floor_hole) = true
}.

Theorem generated_pole_model_shape_holds : generated_pole_model_shape.
Proof. constructor; vm_compute; reflexivity. Qed.

Record generated_pole_source_shape : Prop := {
  source_pole_init_assigns_hitbox_height :
    assigns_through_field_s behavior_actions._hitboxHeight
      (fn_body behavior_actions.f_bhv_pole_init) = true;
  source_pole_position_mentions_top_offset :
    stmt_mentions_float32_bits float32_one_hundred_bits
      (fn_body mario_actions_automatic.f_set_pole_position) = true;
  source_holding_mentions_a_and_z_inputs :
    stmt_mentions_int_bits 2
      (fn_body mario_actions_automatic.f_act_holding_pole) = true /\
    stmt_mentions_int_bits 32768
      (fn_body mario_actions_automatic.f_act_holding_pole) = true;
  source_holding_mentions_two_unit_non_a_exit :
    stmt_mentions_float32_bits float32_two_bits
      (fn_body mario_actions_automatic.f_act_holding_pole) = true /\
    stmt_mentions_int_bits act_soft_bonk
      (fn_body mario_actions_automatic.f_act_holding_pole) = true;
  source_holding_and_climbing_mention_wall_kick :
    stmt_mentions_int_bits act_wall_kick_air
      (fn_body mario_actions_automatic.f_act_holding_pole) = true /\
    stmt_mentions_int_bits act_wall_kick_air
      (fn_body mario_actions_automatic.f_act_climbing_pole) = true;
  source_top_mentions_a_gated_jump :
    stmt_mentions_int_bits 2
      (fn_body mario_actions_automatic.f_act_top_of_pole) = true /\
    stmt_mentions_int_bits act_top_of_pole_jump
      (fn_body mario_actions_automatic.f_act_top_of_pole) = true;
  source_interaction_clears_velocity_fields :
    assigns_through_field_s interaction._vel
      (fn_body interaction.f_interact_pole) = true /\
    assigns_through_field_s interaction._forwardVel
      (fn_body interaction.f_interact_pole) = true;
  source_button_update_assigns_input_and_mentions_a_masks :
    assigns_through_field_s mario._input
      (fn_body mario.f_update_mario_button_inputs) = true /\
    stmt_mentions_int_bits 32768
      (fn_body mario.f_update_mario_button_inputs) = true /\
    stmt_mentions_int_bits 2
      (fn_body mario.f_update_mario_button_inputs) = true;
  source_action_setup_mentions_pole_jump_speeds :
    stmt_mentions_float32_bits float32_sixty_two_bits
      (fn_body mario.f_set_mario_action_airborne) = true /\
    stmt_mentions_float32_bits float32_twenty_four_bits
      (fn_body mario.f_set_mario_action_airborne) = true;
  source_air_update_mentions_drag :
    stmt_mentions_float32_bits float32_point_three_five_bits
      (fn_body mario_actions_airborne.f_update_air_without_turn) = true;
  source_top_jump_calls_common_air_step :
    ident_mem mario_actions_airborne._common_air_action_step
      (direct_callees_s (fn_body mario_actions_airborne.f_act_top_of_pole_jump)) = true;
  source_gravity_mentions_four :
    stmt_mentions_float32_bits float32_four_bits
      (fn_body mario_step.f_apply_gravity) = true;
  source_air_step_contains_quarter_step_loop :
    stmt_contains_loop (fn_body mario_step.f_perform_air_step) = true;
  source_object_order_starts_spawner_surface_pole_player :
    gvar_init object_list_processor.v_sObjectListUpdateOrder =
      [Init_int8 (Int.repr 11); Init_int8 (Int.repr 9);
       Init_int8 (Int.repr 10); Init_int8 (Int.repr 0);
       Init_int8 (Int.repr 5); Init_int8 (Int.repr 4);
       Init_int8 (Int.repr 2); Init_int8 (Int.repr 6);
       Init_int8 (Int.repr 8); Init_int8 (Int.repr 12);
       Init_int8 (Int.repr (-1))]
}.

Theorem generated_pole_source_shape_holds : generated_pole_source_shape.
Proof.
  constructor.
  - vm_compute; reflexivity.
  - vm_compute; reflexivity.
  - split; vm_compute; reflexivity.
  - split.
    + vm_compute; reflexivity.
    + vm_compute; reflexivity.
  - vm_compute; repeat split; reflexivity.
  - vm_compute; repeat split; reflexivity.
  - vm_compute; repeat split; reflexivity.
  - vm_compute; repeat split; reflexivity.
  - vm_compute; repeat split; reflexivity.
  - vm_compute; reflexivity.
  - vm_compute; reflexivity.
  - vm_compute; reflexivity.
  - vm_compute; reflexivity.
  - vm_compute; reflexivity.
Qed.
