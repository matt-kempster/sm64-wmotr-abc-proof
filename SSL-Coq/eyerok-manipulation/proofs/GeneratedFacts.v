From Coq Require Import Bool List PArith.BinPos ZArith.
From compcert Require Import AST Clight Cop Ctypes Floats Integers Maps.
From SSLEyerok.Generated Require area area_jp behavior_script eyerok_model
  game_init interaction level_update level_update_jp mario
  mario_actions_airborne mario_actions_moving mario_actions_object
  mario_actions_stationary mario_step obj_behaviors_2 object_helpers
  object_list_processor object_list_processor_jp platform_displacement
  platform_displacement_jp spawn_object.

Import ListNotations.

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
  | Sloop s1 s2 =>
      stmt_mentions_int_bits bits s1 || stmt_mentions_int_bits bits s2
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

Fixpoint expr_mentions_single_bits (bits : Z) (e : expr) : bool :=
  match e with
  | Econst_single value _ =>
      Int.eq (Float32.to_bits value) (Int.repr bits)
  | Ederef inner _ | Eaddrof inner _ | Eunop _ inner _ | Ecast inner _ =>
      expr_mentions_single_bits bits inner
  | Ebinop _ lhs rhs _ =>
      expr_mentions_single_bits bits lhs ||
      expr_mentions_single_bits bits rhs
  | Efield inner _ _ => expr_mentions_single_bits bits inner
  | _ => false
  end.

Fixpoint exprs_mentions_single_bits (bits : Z) (args : list expr) : bool :=
  match args with
  | [] => false
  | arg :: rest =>
      expr_mentions_single_bits bits arg ||
      exprs_mentions_single_bits bits rest
  end.

Fixpoint stmt_mentions_single_bits (bits : Z) (s : statement) : bool :=
  match s with
  | Sassign lhs rhs =>
      expr_mentions_single_bits bits lhs ||
      expr_mentions_single_bits bits rhs
  | Sset _ rhs => expr_mentions_single_bits bits rhs
  | Scall _ fn args =>
      expr_mentions_single_bits bits fn ||
      exprs_mentions_single_bits bits args
  | Ssequence s1 s2 =>
      stmt_mentions_single_bits bits s1 || stmt_mentions_single_bits bits s2
  | Sifthenelse test s1 s2 =>
      expr_mentions_single_bits bits test ||
      stmt_mentions_single_bits bits s1 || stmt_mentions_single_bits bits s2
  | Sloop s1 s2 =>
      stmt_mentions_single_bits bits s1 || stmt_mentions_single_bits bits s2
  | Sreturn (Some value) => expr_mentions_single_bits bits value
  | Sswitch key cases =>
      expr_mentions_single_bits bits key ||
      cases_mentions_single_bits bits cases
  | Slabel _ body => stmt_mentions_single_bits bits body
  | _ => false
  end
with cases_mentions_single_bits
    (bits : Z) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      stmt_mentions_single_bits bits body ||
      cases_mentions_single_bits bits rest
  end.

Fixpoint expr_mentions_binop
    (matches : Cop.binary_operation -> bool) (e : expr) : bool :=
  match e with
  | Ederef inner _ | Eaddrof inner _ | Eunop _ inner _ | Ecast inner _ =>
      expr_mentions_binop matches inner
  | Ebinop op lhs rhs _ =>
      matches op || expr_mentions_binop matches lhs ||
      expr_mentions_binop matches rhs
  | Efield inner _ _ => expr_mentions_binop matches inner
  | _ => false
  end.

Fixpoint exprs_mentions_binop
    (matches : Cop.binary_operation -> bool) (args : list expr) : bool :=
  match args with
  | [] => false
  | arg :: rest =>
      expr_mentions_binop matches arg || exprs_mentions_binop matches rest
  end.

Fixpoint stmt_mentions_binop
    (matches : Cop.binary_operation -> bool) (s : statement) : bool :=
  match s with
  | Sassign lhs rhs =>
      expr_mentions_binop matches lhs || expr_mentions_binop matches rhs
  | Sset _ rhs => expr_mentions_binop matches rhs
  | Scall _ fn args =>
      expr_mentions_binop matches fn || exprs_mentions_binop matches args
  | Ssequence s1 s2 =>
      stmt_mentions_binop matches s1 || stmt_mentions_binop matches s2
  | Sifthenelse test s1 s2 =>
      expr_mentions_binop matches test ||
      stmt_mentions_binop matches s1 || stmt_mentions_binop matches s2
  | Sloop s1 s2 =>
      stmt_mentions_binop matches s1 || stmt_mentions_binop matches s2
  | Sreturn (Some value) => expr_mentions_binop matches value
  | Sswitch key cases =>
      expr_mentions_binop matches key || cases_mentions_binop matches cases
  | Slabel _ body => stmt_mentions_binop matches body
  | _ => false
  end
with cases_mentions_binop
    (matches : Cop.binary_operation -> bool)
    (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      stmt_mentions_binop matches body || cases_mentions_binop matches rest
  end.

Definition is_bitwise_and (op : Cop.binary_operation) : bool :=
  match op with Cop.Oand => true | _ => false end.

Definition is_bitwise_xor (op : Cop.binary_operation) : bool :=
  match op with Cop.Oxor => true | _ => false end.

Fixpoint expr_count_single (e : expr) : nat :=
  match e with
  | Econst_single _ _ => 1%nat
  | Ederef inner _ | Eaddrof inner _ | Eunop _ inner _ | Ecast inner _ =>
      expr_count_single inner
  | Ebinop _ lhs rhs _ =>
      (expr_count_single lhs + expr_count_single rhs)%nat
  | Efield inner _ _ => expr_count_single inner
  | _ => 0%nat
  end.

Fixpoint exprs_count_single (args : list expr) : nat :=
  match args with
  | [] => 0%nat
  | arg :: rest =>
      (expr_count_single arg + exprs_count_single rest)%nat
  end.

Fixpoint stmt_count_single (s : statement) : nat :=
  match s with
  | Sassign lhs rhs =>
      (expr_count_single lhs + expr_count_single rhs)%nat
  | Sset _ rhs => expr_count_single rhs
  | Scall _ fn args =>
      (expr_count_single fn + exprs_count_single args)%nat
  | Ssequence s1 s2 =>
      (stmt_count_single s1 + stmt_count_single s2)%nat
  | Sifthenelse test s1 s2 =>
      (expr_count_single test + stmt_count_single s1 + stmt_count_single s2)%nat
  | Sloop s1 s2 =>
      (stmt_count_single s1 + stmt_count_single s2)%nat
  | Sreturn (Some value) => expr_count_single value
  | Sswitch key cases =>
      (expr_count_single key + cases_count_single cases)%nat
  | Slabel _ body => stmt_count_single body
  | _ => 0%nat
  end
with cases_count_single (cases : labeled_statements) : nat :=
  match cases with
  | LSnil => 0%nat
  | LScons _ body rest =>
      (stmt_count_single body + cases_count_single rest)%nat
  end.

Fixpoint expr_mentions_neg (e : expr) : bool :=
  match e with
  | Eunop _ _ _ => true
  | Ederef inner _ | Eaddrof inner _ | Ecast inner _ =>
      expr_mentions_neg inner
  | Ebinop _ lhs rhs _ =>
      expr_mentions_neg lhs || expr_mentions_neg rhs
  | Efield inner _ _ => expr_mentions_neg inner
  | _ => false
  end.

Fixpoint stmt_mentions_neg (s : statement) : bool :=
  match s with
  | Sassign lhs rhs => expr_mentions_neg lhs || expr_mentions_neg rhs
  | Sset _ rhs => expr_mentions_neg rhs
  | Scall _ fn _ => expr_mentions_neg fn
  | Ssequence s1 s2 => stmt_mentions_neg s1 || stmt_mentions_neg s2
  | Sifthenelse test s1 s2 =>
      expr_mentions_neg test || stmt_mentions_neg s1 || stmt_mentions_neg s2
  | Sloop s1 s2 => stmt_mentions_neg s1 || stmt_mentions_neg s2
  | Sreturn (Some value) => expr_mentions_neg value
  | Sswitch key cases => expr_mentions_neg key || cases_mentions_neg cases
  | Slabel _ body => stmt_mentions_neg body
  | _ => false
  end
with cases_mentions_neg (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest => stmt_mentions_neg body || cases_mentions_neg rest
  end.

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

Fixpoint ident_before
    (first second : ident) (ids : list ident) : bool :=
  match ids with
  | [] => false
  | id :: rest =>
      (Pos.eqb first id && ident_mem second rest) ||
      ident_before first second rest
  end.

(** Syntactic write classifiers.  These deliberately inspect only assignment
    lvalues; mentioning a field on the right-hand side is not a write. *)
Fixpoint lvalue_mentions_field (field : ident) (e : expr) : bool :=
  match e with
  | Efield inner actual _ =>
      Pos.eqb actual field || lvalue_mentions_field field inner
  | Ederef inner _ | Eaddrof inner _ | Eunop _ inner _ | Ecast inner _ =>
      lvalue_mentions_field field inner
  | Ebinop _ lhs rhs _ =>
      lvalue_mentions_field field lhs || lvalue_mentions_field field rhs
  | _ => false
  end.

Definition lvalue_is_global (variable : ident) (e : expr) : bool :=
  match e with
  | Evar actual _ => Pos.eqb actual variable
  | _ => false
  end.

(** Syntactic read classifier used to pin the three guards on the saved JP
    platform pointer.  Unlike [lvalue_is_global], this walks every expression
    position, including tests and call arguments. *)
Fixpoint expr_mentions_global (variable : ident) (e : expr) : bool :=
  match e with
  | Evar actual _ => Pos.eqb actual variable
  | Ederef inner _ | Eaddrof inner _ | Eunop _ inner _ | Ecast inner _ =>
      expr_mentions_global variable inner
  | Ebinop _ lhs rhs _ =>
      expr_mentions_global variable lhs || expr_mentions_global variable rhs
  | Efield inner _ _ => expr_mentions_global variable inner
  | _ => false
  end.

Fixpoint exprs_mention_global
    (variable : ident) (args : list expr) : bool :=
  match args with
  | [] => false
  | arg :: rest =>
      expr_mentions_global variable arg ||
      exprs_mention_global variable rest
  end.

Fixpoint stmt_mentions_global (variable : ident) (s : statement) : bool :=
  match s with
  | Sassign lhs rhs =>
      expr_mentions_global variable lhs || expr_mentions_global variable rhs
  | Sset _ rhs => expr_mentions_global variable rhs
  | Scall _ fn args =>
      expr_mentions_global variable fn || exprs_mention_global variable args
  | Ssequence s1 s2 =>
      stmt_mentions_global variable s1 || stmt_mentions_global variable s2
  | Sifthenelse test s1 s2 =>
      expr_mentions_global variable test ||
      stmt_mentions_global variable s1 || stmt_mentions_global variable s2
  | Sloop s1 s2 =>
      stmt_mentions_global variable s1 || stmt_mentions_global variable s2
  | Sreturn (Some value) => expr_mentions_global variable value
  | Sswitch key cases =>
      expr_mentions_global variable key || cases_mention_global variable cases
  | Slabel _ body => stmt_mentions_global variable body
  | _ => false
  end
with cases_mention_global
    (variable : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      stmt_mentions_global variable body ||
      cases_mention_global variable rest
  end.

Fixpoint stmt_assigns_field (field : ident) (s : statement) : bool :=
  match s with
  | Sassign lhs _ => lvalue_mentions_field field lhs
  | Ssequence s1 s2 =>
      stmt_assigns_field field s1 || stmt_assigns_field field s2
  | Sifthenelse _ s1 s2 =>
      stmt_assigns_field field s1 || stmt_assigns_field field s2
  | Sloop s1 s2 =>
      stmt_assigns_field field s1 || stmt_assigns_field field s2
  | Sswitch _ cases => cases_assign_field field cases
  | Slabel _ body => stmt_assigns_field field body
  | _ => false
  end
with cases_assign_field (field : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      stmt_assigns_field field body || cases_assign_field field rest
  end.

Fixpoint stmt_assigns_global (variable : ident) (s : statement) : bool :=
  match s with
  | Sassign lhs _ => lvalue_is_global variable lhs
  | Ssequence s1 s2 =>
      stmt_assigns_global variable s1 || stmt_assigns_global variable s2
  | Sifthenelse _ s1 s2 =>
      stmt_assigns_global variable s1 || stmt_assigns_global variable s2
  | Sloop s1 s2 =>
      stmt_assigns_global variable s1 || stmt_assigns_global variable s2
  | Sswitch _ cases => cases_assign_global variable cases
  | Slabel _ body => stmt_assigns_global variable body
  | _ => false
  end
with cases_assign_global
    (variable : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      stmt_assigns_global variable body || cases_assign_global variable rest
  end.

Fixpoint stmt_calls_with_two_int_args
    (callee : ident) (first_bits second_bits : Z)
    (s : statement) : bool :=
  match s with
  | Scall _ (Evar id _) args =>
      Pos.eqb callee id &&
      exprs_mentions_int_bits first_bits args &&
      exprs_mentions_int_bits second_bits args
  | Ssequence s1 s2 =>
      stmt_calls_with_two_int_args callee first_bits second_bits s1 ||
      stmt_calls_with_two_int_args callee first_bits second_bits s2
  | Sifthenelse _ s1 s2 =>
      stmt_calls_with_two_int_args callee first_bits second_bits s1 ||
      stmt_calls_with_two_int_args callee first_bits second_bits s2
  | Sloop s1 s2 =>
      stmt_calls_with_two_int_args callee first_bits second_bits s1 ||
      stmt_calls_with_two_int_args callee first_bits second_bits s2
  | Sswitch _ cases =>
      cases_calls_with_two_int_args callee first_bits second_bits cases
  | Slabel _ body =>
      stmt_calls_with_two_int_args callee first_bits second_bits body
  | _ => false
  end
with cases_calls_with_two_int_args
    (callee : ident) (first_bits second_bits : Z)
    (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      stmt_calls_with_two_int_args callee first_bits second_bits body ||
      cases_calls_with_two_int_args callee first_bits second_bits rest
  end.

Fixpoint stmt_has_switch_case_int_single
    (case_value int_bits single_bits : Z) (s : statement) : bool :=
  match s with
  | Ssequence s1 s2 =>
      stmt_has_switch_case_int_single case_value int_bits single_bits s1 ||
      stmt_has_switch_case_int_single case_value int_bits single_bits s2
  | Sifthenelse _ s1 s2 =>
      stmt_has_switch_case_int_single case_value int_bits single_bits s1 ||
      stmt_has_switch_case_int_single case_value int_bits single_bits s2
  | Sloop s1 s2 =>
      stmt_has_switch_case_int_single case_value int_bits single_bits s1 ||
      stmt_has_switch_case_int_single case_value int_bits single_bits s2
  | Sswitch _ cases =>
      cases_has_switch_case_int_single
        case_value int_bits single_bits cases
  | Slabel _ body =>
      stmt_has_switch_case_int_single case_value int_bits single_bits body
  | _ => false
  end
with cases_has_switch_case_int_single
    (case_value int_bits single_bits : Z)
    (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons label body rest =>
      (match label with
       | Some actual =>
           Z.eqb case_value actual &&
           stmt_mentions_int_bits int_bits body &&
           stmt_mentions_single_bits single_bits body
       | None => false
       end) ||
      stmt_has_switch_case_int_single
        case_value int_bits single_bits body ||
      cases_has_switch_case_int_single
        case_value int_bits single_bits rest
  end.

Definition generated_model_shape : Prop :=
  stmt_mentions_int_bits 384 (fn_body eyerok_model.f_eyerok_support_ceiling) = true /\
  stmt_mentions_int_bits 1179 (fn_body eyerok_model.f_eyerok_support_ceiling) = true /\
  stmt_mentions_int_bits 672 (fn_body eyerok_model.f_eyerok_height_ceiling) = true /\
  stmt_mentions_int_bits 1467 (fn_body eyerok_model.f_eyerok_height_ceiling) = true /\
  stmt_mentions_int_bits 98 (fn_body eyerok_model.f_eyerok_action_ascent_budget) = true /\
  stmt_mentions_int_bits 288 (fn_body eyerok_model.f_eyerok_action_ascent_budget) = true /\
  stmt_mentions_int_bits 285 (fn_body eyerok_model.f_eyerok_action_ascent_budget) = true /\
  stmt_mentions_int_bits 100 (fn_body eyerok_model.f_eyerok_runaway_frame) = true /\
  stmt_mentions_int_bits 288 (fn_body eyerok_model.f_eyerok_safe_envelope) = true.

Theorem generated_model_shape_holds : generated_model_shape.
Proof. vm_compute. repeat split; reflexivity. Qed.

Definition generated_critical_source_shape : Prop :=
  stmt_count_single
    (fn_body obj_behaviors_2.f_eyerok_hand_check_attacked) = 4%nat /\
  stmt_mentions_neg
    (fn_body obj_behaviors_2.f_eyerok_hand_check_attacked) = true /\
  stmt_count_single
    (fn_body obj_behaviors_2.f_eyerok_hand_act_double_pound) = 7%nat /\
  stmt_mentions_neg
    (fn_body obj_behaviors_2.f_eyerok_hand_act_double_pound) = true /\
  ident_mem obj_behaviors_2._cur_obj_move_standard
    (direct_callees_s (fn_body obj_behaviors_2.f_bhv_eyerok_hand_loop)) = true /\
  stmt_count_single
    (fn_body object_helpers.f_cur_obj_move_y_and_get_water_level) = 2%nat /\
  stmt_mentions_neg
    (fn_body object_helpers.f_cur_obj_move_y_and_get_water_level) = true /\
  ident_mem object_helpers._cur_obj_move_y
    (direct_callees_s (fn_body object_helpers.f_cur_obj_move_standard)) = true /\
  ident_mem object_list_processor._clear_dynamic_surfaces
    (direct_callees_s (fn_body object_list_processor.f_update_objects)) = true.

Theorem generated_critical_source_shape_holds : generated_critical_source_shape.
Proof. vm_compute. repeat split; reflexivity. Qed.

(** Syntactic Clight witnesses for the audited nonlethal lifecycle.  These
    facts pin the generated translation unit to the named handlers and action
    constants used by [NonlethalNoStacking].  They do not replace a dynamic
    Clight-to-lifecycle refinement. *)
Definition generated_nonlethal_lifecycle_shape : Prop :=
  stmt_mentions_int_bits 2
    (fn_body obj_behaviors_2.f_eyerok_hand_check_attacked) = true /\
  stmt_mentions_int_bits 12
    (fn_body obj_behaviors_2.f_eyerok_hand_check_attacked) = true /\
  stmt_mentions_int_bits 15
    (fn_body obj_behaviors_2.f_eyerok_hand_check_attacked) = true /\
  ident_mem obj_behaviors_2._eyerok_hand_check_attacked
    (direct_callees_s
      (fn_body obj_behaviors_2.f_eyerok_hand_act_show_eye)) = true /\
  stmt_mentions_int_bits 13
    (fn_body obj_behaviors_2.f_eyerok_hand_act_attacked) = true /\
  stmt_mentions_int_bits 14
    (fn_body obj_behaviors_2.f_eyerok_hand_act_recover) = true /\
  stmt_mentions_int_bits 5
    (fn_body obj_behaviors_2.f_eyerok_hand_act_become_active) = true /\
  ident_mem obj_behaviors_2._approach_f32_ptr
    (direct_callees_s
      (fn_body obj_behaviors_2.f_eyerok_hand_act_retreat)) = true /\
  stmt_mentions_int_bits 1
    (fn_body obj_behaviors_2.f_eyerok_hand_act_retreat) = true /\
  stmt_mentions_int_bits 2
    (fn_body obj_behaviors_2.f_eyerok_hand_act_idle) = true /\
  stmt_mentions_int_bits 3
    (fn_body obj_behaviors_2.f_eyerok_hand_act_open) = true /\
  ident_mem obj_behaviors_2._obj_set_hitbox
    (direct_callees_s (fn_body obj_behaviors_2.f_obj_check_attacks)) = true /\
  ident_before obj_behaviors_2._eyerok_hand_act_show_eye
    obj_behaviors_2._obj_check_attacks
    (direct_callees_s (fn_body obj_behaviors_2.f_bhv_eyerok_hand_loop)) = true /\
  ident_before obj_behaviors_2._obj_check_attacks
    obj_behaviors_2._cur_obj_move_standard
    (direct_callees_s (fn_body obj_behaviors_2.f_bhv_eyerok_hand_loop)) = true.

Theorem generated_nonlethal_lifecycle_shape_holds :
  generated_nonlethal_lifecycle_shape.
Proof. vm_compute. repeat split; reflexivity. Qed.

Definition generated_route_source_shape : Prop :=
  ident_mem level_update._check_instant_warp
    (direct_callees_s (fn_body level_update.f_play_mode_normal)) = true /\
  ident_mem level_update._area_update_objects
    (direct_callees_s (fn_body level_update.f_play_mode_normal)) = true /\
  ident_mem level_update._change_area
    (direct_callees_s (fn_body level_update.f_check_instant_warp)) = true /\
  ident_mem area._unload_area
    (direct_callees_s (fn_body area.f_change_area)) = true /\
  ident_mem area._load_area
    (direct_callees_s (fn_body area.f_change_area)) = true /\
  ident_mem mario._find_floor
    (direct_callees_s (fn_body mario.f_update_mario_geometry_inputs)) = true /\
  ident_mem mario_step._apply_gravity
    (direct_callees_s (fn_body mario_step.f_perform_air_step)) = true /\
  ident_mem mario_actions_airborne._perform_air_step
    (direct_callees_s
      (fn_body mario_actions_airborne.f_common_air_action_step)) = true /\
  ident_mem platform_displacement._get_mario_pos
    (direct_callees_s
      (fn_body platform_displacement.f_apply_platform_displacement)) = true /\
  ident_mem platform_displacement._set_mario_pos
    (direct_callees_s
      (fn_body platform_displacement.f_apply_platform_displacement)) = true /\
  ident_mem interaction._save_file_collect_star_or_key
    (direct_callees_s (fn_body interaction.f_interact_star_or_key)) = true.

Theorem generated_route_source_shape_holds : generated_route_source_shape.
Proof. vm_compute. repeat split; reflexivity. Qed.

(** [direct_callees_s] performs a deterministic depth-first traversal of the
    Clight statement tree, including mutually exclusive branches.  These
    booleans pin call-site traversal order only; they do not prove dynamic
    execution-path order, external-call behavior, or whole-program linking. *)
Definition generated_callsite_traversal_shape : Prop :=
  ident_before obj_behaviors_2._cur_obj_update_floor_and_walls
    obj_behaviors_2._eyerok_hand_act_double_pound
    (direct_callees_s (fn_body obj_behaviors_2.f_bhv_eyerok_hand_loop)) = true /\
  ident_before obj_behaviors_2._eyerok_hand_act_double_pound
    obj_behaviors_2._cur_obj_move_standard
    (direct_callees_s (fn_body obj_behaviors_2.f_bhv_eyerok_hand_loop)) = true /\
  ident_before obj_behaviors_2._obj_check_attacks
    obj_behaviors_2._cur_obj_move_standard
    (direct_callees_s (fn_body obj_behaviors_2.f_bhv_eyerok_hand_loop)) = true /\
  ident_before obj_behaviors_2._cur_obj_move_standard
    obj_behaviors_2._load_object_collision_model
    (direct_callees_s (fn_body obj_behaviors_2.f_bhv_eyerok_hand_loop)) = true /\
  ident_before level_update._warp_area level_update._check_instant_warp
    (direct_callees_s (fn_body level_update.f_play_mode_normal)) = true /\
  ident_before level_update._check_instant_warp
    level_update._area_update_objects
    (direct_callees_s (fn_body level_update.f_play_mode_normal)) = true /\
  ident_before object_list_processor._clear_dynamic_surfaces
    object_list_processor._update_non_terrain_objects
    (direct_callees_s
      (fn_body object_list_processor.f_update_objects)) = true.

Theorem generated_callsite_traversal_shape_holds :
  generated_callsite_traversal_shape.
Proof. vm_compute. repeat split; reflexivity. Qed.

(** Resolution is proved in each generated translation unit's own program.
    This is deliberately weaker than constructing and validating a linked
    whole-game [Clight.program]. *)
Definition generated_unit_resolution_shape : Prop :=
  PTree.get game_init._read_controller_inputs
    (PTree_Properties.of_list (Ctypes.prog_defs game_init.prog)) =
      Some (Gfun (Internal game_init.f_read_controller_inputs)) /\
  PTree.get mario_actions_moving._check_ground_dive_or_punch
    (PTree_Properties.of_list
      (Ctypes.prog_defs mario_actions_moving.prog)) =
      Some (Gfun (Internal
        mario_actions_moving.f_check_ground_dive_or_punch)) /\
  PTree.get mario_actions_moving._act_move_punching
    (PTree_Properties.of_list
      (Ctypes.prog_defs mario_actions_moving.prog)) =
      Some (Gfun (Internal mario_actions_moving.f_act_move_punching)) /\
  PTree.get mario_actions_object._act_punching
    (PTree_Properties.of_list
      (Ctypes.prog_defs mario_actions_object.prog)) =
      Some (Gfun (Internal mario_actions_object.f_act_punching)) /\
  PTree.get mario_actions_stationary._act_crouching
    (PTree_Properties.of_list
      (Ctypes.prog_defs mario_actions_stationary.prog)) =
      Some (Gfun (Internal mario_actions_stationary.f_act_crouching)) /\
  PTree.get obj_behaviors_2._bhv_eyerok_hand_loop
    (PTree_Properties.of_list
      (Ctypes.prog_defs obj_behaviors_2.prog)) =
      Some (Gfun (Internal obj_behaviors_2.f_bhv_eyerok_hand_loop)) /\
  PTree.get level_update._play_mode_normal
    (PTree_Properties.of_list (Ctypes.prog_defs level_update.prog)) =
      Some (Gfun (Internal level_update.f_play_mode_normal)) /\
  PTree.get object_list_processor._update_objects
    (PTree_Properties.of_list
      (Ctypes.prog_defs object_list_processor.prog)) =
      Some (Gfun (Internal object_list_processor.f_update_objects)).

Theorem generated_unit_resolution_shape_holds :
  generated_unit_resolution_shape.
Proof. vm_compute. repeat split; reflexivity. Qed.

(** These are syntactic facts about the Clight generated from the pinned
    controller and Mario action translation units.  They establish that the
    audited constants and branch operators occur in the named functions;
    they do not by themselves prove a Clight execution or a refinement from
    an original-game frame to a handwritten route relation. *)
Definition generated_jump_kick_vertical_shape : Prop :=
  stmt_has_switch_case_int_single
    25168044 1 1101004800
    (fn_body mario.f_set_mario_action_airborne) = true.

Theorem generated_jump_kick_vertical_shape_holds :
  generated_jump_kick_vertical_shape.
Proof. vm_compute. reflexivity. Qed.

Definition generated_controller_action_shape : Prop :=
  stmt_mentions_binop is_bitwise_and
    (fn_body game_init.f_read_controller_inputs) = true /\
  stmt_mentions_binop is_bitwise_xor
    (fn_body game_init.f_read_controller_inputs) = true /\
  stmt_mentions_int_bits 8192
    (fn_body mario_actions_moving.f_check_ground_dive_or_punch) = true /\
  stmt_mentions_single_bits 1105723392
    (fn_body mario_actions_moving.f_check_ground_dive_or_punch) = true /\
  stmt_mentions_single_bits 1111490560
    (fn_body mario_actions_moving.f_check_ground_dive_or_punch) = true /\
  stmt_mentions_single_bits 1101004800
    (fn_body mario_actions_moving.f_check_ground_dive_or_punch) = true /\
  stmt_calls_with_two_int_args mario_actions_moving._set_mario_action
    25692298 1
    (fn_body mario_actions_moving.f_check_ground_dive_or_punch) = true /\
  stmt_mentions_int_bits 128
    (fn_body mario_actions_moving.f_act_move_punching) = true /\
  stmt_calls_with_two_int_args mario_actions_moving._set_mario_action
    25168044 0
    (fn_body mario_actions_moving.f_act_move_punching) = true /\
  stmt_mentions_int_bits 128
    (fn_body mario_actions_object.f_act_punching) = true /\
  stmt_calls_with_two_int_args mario_actions_object._set_mario_action
    25168044 0
    (fn_body mario_actions_object.f_act_punching) = true /\
  stmt_mentions_int_bits 2
    (fn_body mario_actions_stationary.f_act_crouching) = true /\
  stmt_calls_with_two_int_args mario_actions_stationary._set_jumping_action
    16779395 0
    (fn_body mario_actions_stationary.f_act_crouching) = true /\
  ident_mem mario_actions_stationary._set_jumping_action
    (direct_callees_s
      (fn_body mario_actions_stationary.f_act_crouching)) = true /\
  generated_jump_kick_vertical_shape.

Theorem generated_controller_action_shape_holds :
  generated_controller_action_shape.
Proof. vm_compute. repeat split; reflexivity. Qed.

(** Syntactic witnesses for the Pedro and version-independent fragment
    investigations.  These ASTs are generated with the US headers from source
    files that the audit proves pin-identical; the version-sensitive JP
    area/platform units are checked separately below.  Call-list order is a
    deterministic traversal fact; the source audit pins the corresponding
    straight-line execution order and field writers. *)
Definition generated_exploit_common_source_shape : Prop :=
  stmt_mentions_single_bits 1126170624
    (fn_body mario_step.f_perform_air_quarter_step) = true /\
  stmt_mentions_single_bits 1125515264
    (fn_body mario_step.f_perform_air_quarter_step) = true /\
  stmt_mentions_single_bits 1112014848
    (fn_body mario_step.f_perform_air_quarter_step) = true /\
  stmt_mentions_single_bits 1106247680
    (fn_body mario_step.f_perform_air_quarter_step) = true /\
  ident_before mario_step._resolve_and_return_wall_collisions
    mario_step._find_floor
    (direct_callees_s
      (fn_body mario_step.f_perform_air_quarter_step)) = true /\
  ident_before mario_step._find_floor mario_step._vec3f_find_ceil
    (direct_callees_s
      (fn_body mario_step.f_perform_air_quarter_step)) = true /\
  ident_before object_helpers._spawn_mist_particles_variable
    object_helpers._spawn_triangle_break_particles
    (direct_callees_s
      (fn_body object_helpers.f_obj_explode_and_spawn_coins)) = true /\
  ident_before object_helpers._spawn_triangle_break_particles
    object_helpers._obj_mark_for_deletion
    (direct_callees_s
      (fn_body object_helpers.f_obj_explode_and_spawn_coins)) = true /\
  ident_mem obj_behaviors_2._obj_explode_and_spawn_coins
    (direct_callees_s (fn_body obj_behaviors_2.f_eyerok_hand_act_die)) = true /\
  ident_before object_list_processor._apply_mario_platform_displacement
    object_list_processor._unload_deactivated_objects
    (direct_callees_s
      (fn_body object_list_processor.f_update_objects)) = true /\
  ident_before object_list_processor._unload_deactivated_objects
    object_list_processor._update_mario_platform
    (direct_callees_s
      (fn_body object_list_processor.f_update_objects)) = true /\
  ident_before platform_displacement._get_mario_pos
    platform_displacement._set_mario_pos
    (direct_callees_s
      (fn_body platform_displacement.f_apply_platform_displacement)) = true /\
  stmt_assigns_field object_helpers._activeFlags
    (fn_body object_helpers.f_obj_mark_for_deletion) = true /\
  ident_mem spawn_object._deallocate_object
    (direct_callees_s
      (fn_body object_helpers.f_obj_mark_for_deletion)) = false /\
  ident_mem object_list_processor._unload_object
    (direct_callees_s
      (fn_body object_list_processor.f_unload_deactivated_objects_in_list)) = true /\
  ident_mem spawn_object._deallocate_object
    (direct_callees_s (fn_body spawn_object.f_unload_object)) = true /\
  ident_mem spawn_object._try_allocate_object
    (direct_callees_s (fn_body spawn_object.f_allocate_object)) = true /\
  ident_before object_list_processor._clear_dynamic_surfaces
    object_list_processor._update_terrain_objects
    (direct_callees_s (fn_body object_list_processor.f_update_objects)) = true /\
  ident_before object_list_processor._update_terrain_objects
    object_list_processor._apply_mario_platform_displacement
    (direct_callees_s (fn_body object_list_processor.f_update_objects)) = true /\
  stmt_assigns_global platform_displacement._gMarioPlatform
    (fn_body platform_displacement.f_update_mario_platform) = true /\
  ident_mem platform_displacement._apply_platform_displacement
    (direct_callees_s
      (fn_body platform_displacement.f_apply_mario_platform_displacement)) = true /\
  stmt_assigns_field platform_displacement._vel
    (fn_body platform_displacement.f_apply_platform_displacement) = false /\
  stmt_assigns_field platform_displacement._forwardVel
    (fn_body platform_displacement.f_apply_platform_displacement) = false /\
  stmt_assigns_field platform_displacement._vel
    (fn_body platform_displacement.f_set_mario_pos) = false /\
  stmt_assigns_field platform_displacement._forwardVel
    (fn_body platform_displacement.f_set_mario_pos) = false.

Definition generated_us_area_clear_shape : Prop :=
  ident_mem object_list_processor._clear_mario_platform
    (direct_callees_s
      (fn_body object_list_processor.f_spawn_objects_from_info)) = true.

(** Backward-compatible aggregate for the original US-facing theorem. *)
Definition generated_exploit_source_shape : Prop :=
  generated_exploit_common_source_shape /\ generated_us_area_clear_shape.

Theorem generated_exploit_common_source_shape_holds :
  generated_exploit_common_source_shape.
Proof. vm_compute. repeat split; reflexivity. Qed.

Theorem generated_us_area_clear_shape_holds : generated_us_area_clear_shape.
Proof. vm_compute. reflexivity. Qed.

Theorem generated_exploit_source_shape_holds :
  generated_exploit_source_shape.
Proof.
  split.
  - exact generated_exploit_common_source_shape_holds.
  - exact generated_us_area_clear_shape_holds.
Qed.

(** Version-specific Clight witnesses for the Japanese spawning-displacement
    behavior.  The exact direct-call list is exhaustive for the normalized JP
    [spawn_objects_from_info] body: unlike the US body above, it contains no
    area-load call that could clear Mario's saved platform pointer. *)
Definition generated_jp_platform_source_shape : Prop :=
  ident_mem object_list_processor._clear_mario_platform
    (direct_callees_s
      (fn_body object_list_processor.f_spawn_objects_from_info)) = true /\
  direct_callees_s
      (fn_body object_list_processor_jp.f_spawn_objects_from_info) =
    [ object_list_processor_jp._segmented_to_virtual;
      object_list_processor_jp._create_object;
      object_list_processor_jp._geo_make_first_child;
      object_list_processor_jp._geo_obj_init_spawninfo ] /\
  ident_before level_update_jp._check_instant_warp
    level_update_jp._area_update_objects
    (direct_callees_s (fn_body level_update_jp.f_play_mode_normal)) = true /\
  ident_mem level_update_jp._change_area
    (direct_callees_s (fn_body level_update_jp.f_check_instant_warp)) = true /\
  ident_before area_jp._unload_area area_jp._load_area
    (direct_callees_s (fn_body area_jp.f_change_area)) = true /\
  ident_before object_list_processor_jp._clear_dynamic_surfaces
    object_list_processor_jp._update_terrain_objects
    (direct_callees_s
      (fn_body object_list_processor_jp.f_update_objects)) = true /\
  ident_before object_list_processor_jp._update_terrain_objects
    object_list_processor_jp._apply_mario_platform_displacement
    (direct_callees_s
      (fn_body object_list_processor_jp.f_update_objects)) = true /\
  ident_before object_list_processor_jp._apply_mario_platform_displacement
    object_list_processor_jp._unload_deactivated_objects
    (direct_callees_s
      (fn_body object_list_processor_jp.f_update_objects)) = true /\
  ident_before object_list_processor_jp._unload_deactivated_objects
    object_list_processor_jp._update_mario_platform
    (direct_callees_s
      (fn_body object_list_processor_jp.f_update_objects)) = true /\
  stmt_mentions_global platform_displacement_jp._gTimeStopState
    (fn_body platform_displacement_jp.f_apply_mario_platform_displacement) =
      true /\
  stmt_mentions_global platform_displacement_jp._gMarioObject
    (fn_body platform_displacement_jp.f_apply_mario_platform_displacement) =
      true /\
  stmt_mentions_global platform_displacement_jp._gMarioPlatform
    (fn_body platform_displacement_jp.f_apply_mario_platform_displacement) =
      true /\
  ident_mem platform_displacement_jp._apply_platform_displacement
    (direct_callees_s
      (fn_body platform_displacement_jp.f_apply_mario_platform_displacement)) =
      true /\
  stmt_assigns_global platform_displacement_jp._gMarioPlatform
    (fn_body platform_displacement_jp.f_update_mario_platform) = true.

Theorem generated_jp_platform_source_shape_holds :
  generated_jp_platform_source_shape.
Proof. vm_compute. repeat split; reflexivity. Qed.
