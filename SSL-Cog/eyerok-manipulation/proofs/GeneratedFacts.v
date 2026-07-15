From Coq Require Import Bool List PArith.BinPos ZArith.
From compcert Require Import AST Clight Cop Ctypes Floats Integers Maps.
From SSLEyerok.Generated Require area behavior_script eyerok_model game_init
  interaction level_update mario mario_actions_airborne mario_actions_moving
  mario_actions_object mario_actions_stationary mario_step obj_behaviors_2
  object_helpers object_list_processor platform_displacement.

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
