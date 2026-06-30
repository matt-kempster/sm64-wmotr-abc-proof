From Coq Require Import Bool List ZArith.
Import ListNotations.
From compcert Require Import AST Cop Ctypes Clight Integers.
From SSLPyramid.Generated Require Import
  area audio_external behavior_actions graph_node interaction level_script
  level_update macro_special_objects mario mario_actions_cutscene
  obj_behaviors object_helpers object_list_processor spawn_object
  ssl_area1_macro ssl_script.
From SSLPyramid.Proofs Require Import ASTFacts.

Module A := area.
Module AU := audio_external.
Module B := behavior_actions.
Module G := graph_node.
Module I := interaction.
Module LS := level_script.
Module L := level_update.
Module P := macro_special_objects.
Module M := mario.
Module MC := mario_actions_cutscene.
Module OB := obj_behaviors.
Module H := object_helpers.
Module O := object_list_processor.
Module S := spawn_object.
Module SM := ssl_area1_macro.
Module SSL := ssl_script.

Definition proposition_of {P : Prop} (_ : P) : Prop := P.

Definition events_emptyb (events : list statement_event) : bool :=
  match events with
  | [] => true
  | _ => false
  end.

Definition expr_is_temp_nonzero_guard (temporary : ident) (e : expr) : bool :=
  match e with
  | Etempvar found _ => Pos.eqb found temporary
  | Ebinop Cop.One (Etempvar found _) (Econst_int value _) _ =>
      Pos.eqb found temporary && Int.eq value Int.zero
  | _ => false
  end.

Fixpoint temp_nonzero_guarded_event_subsequenceb
    (temporary : ident) (needle : list statement_event) (s : statement)
    : bool :=
  match s with
  | Sifthenelse condition then_branch else_branch =>
      (expr_is_temp_nonzero_guard temporary condition &&
       event_subsequenceb needle (statement_events_s then_branch) &&
       events_emptyb (statement_events_s else_branch)) ||
      temp_nonzero_guarded_event_subsequenceb temporary needle then_branch ||
      temp_nonzero_guarded_event_subsequenceb temporary needle else_branch
  | Ssequence s1 s2 | Sloop s1 s2 =>
      temp_nonzero_guarded_event_subsequenceb temporary needle s1 ||
      temp_nonzero_guarded_event_subsequenceb temporary needle s2
  | Slabel _ body =>
      temp_nonzero_guarded_event_subsequenceb temporary needle body
  | Sswitch _ cases =>
      temp_nonzero_guarded_event_subsequence_ls temporary needle cases
  | _ => false
  end
with temp_nonzero_guarded_event_subsequence_ls
       (temporary : ident) (needle : list statement_event)
       (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      temp_nonzero_guarded_event_subsequenceb temporary needle body ||
      temp_nonzero_guarded_event_subsequence_ls temporary needle rest
  end.

Inductive second_arg_shape : Type :=
| SecondArgTemp : ident -> second_arg_shape
| SecondArgConst : int -> second_arg_shape
| SecondArgOther : second_arg_shape.

Definition expression_second_arg_shape (e : expr) : second_arg_shape :=
  match e with
  | Etempvar temporary _ => SecondArgTemp temporary
  | Econst_int value _ => SecondArgConst value
  | Ecast (Econst_int value _) _ => SecondArgConst value
  | _ => SecondArgOther
  end.

Definition second_arg_shape_of_args (args : list expr) : second_arg_shape :=
  match args with
  | _ :: second :: _ => expression_second_arg_shape second
  | _ => SecondArgOther
  end.

Fixpoint call_second_arg_shapes_s (callee : ident) (s : statement)
    : list second_arg_shape :=
  match s with
  | Scall _ (Evar id _) args =>
      if Pos.eqb id callee
      then [second_arg_shape_of_args args]
      else []
  | Ssequence s1 s2 | Sifthenelse _ s1 s2 | Sloop s1 s2 =>
      call_second_arg_shapes_s callee s1 ++
      call_second_arg_shapes_s callee s2
  | Slabel _ body => call_second_arg_shapes_s callee body
  | Sswitch _ cases => call_second_arg_shapes_ls callee cases
  | _ => []
  end
with call_second_arg_shapes_ls
       (callee : ident) (cases : labeled_statements)
    : list second_arg_shape :=
  match cases with
  | LSnil => []
  | LScons _ body rest =>
      call_second_arg_shapes_s callee body ++
      call_second_arg_shapes_ls callee rest
  end.

Definition expression_const_int (e : expr) : option int :=
  match e with
  | Econst_int value _ => Some value
  | Ecast (Econst_int value _) _ => Some value
  | _ => None
  end.

Fixpoint temp_const_assignments_s (temporary : ident) (s : statement)
    : list int :=
  match s with
  | Sset found rhs =>
      if Pos.eqb found temporary
      then
        match expression_const_int rhs with
        | Some value => [value]
        | None => []
        end
      else []
  | Ssequence s1 s2 | Sifthenelse _ s1 s2 | Sloop s1 s2 =>
      temp_const_assignments_s temporary s1 ++
      temp_const_assignments_s temporary s2
  | Slabel _ body => temp_const_assignments_s temporary body
  | Sswitch _ cases => temp_const_assignments_ls temporary cases
  | _ => []
  end
with temp_const_assignments_ls
       (temporary : ident) (cases : labeled_statements) : list int :=
  match cases with
  | LSnil => []
  | LScons _ body rest =>
      temp_const_assignments_s temporary body ++
      temp_const_assignments_ls temporary rest
  end.

Fixpoint expression_mentions_field_deep
    (field : ident) (e : expr) : bool :=
  match e with
  | Ederef inner _ | Eaddrof inner _ | Eunop _ inner _
  | Ecast inner _ | Efield inner _ _ =>
      match e with
      | Efield inner found _ =>
          Pos.eqb found field ||
          expression_mentions_field_deep field inner
      | _ => expression_mentions_field_deep field inner
      end
  | Ebinop _ operand1 operand2 _ =>
      expression_mentions_field_deep field operand1 ||
      expression_mentions_field_deep field operand2
  | _ => false
  end.

Fixpoint expression_list_mentions_field_deep
    (field : ident) (args : list expr) : bool :=
  match args with
  | [] => false
  | arg :: rest =>
      expression_mentions_field_deep field arg ||
      expression_list_mentions_field_deep field rest
  end.

Fixpoint statement_mentions_field_s
    (field : ident) (s : statement) : bool :=
  match s with
  | Sassign lhs rhs =>
      expression_mentions_field_deep field lhs ||
      expression_mentions_field_deep field rhs
  | Sset _ rhs => expression_mentions_field_deep field rhs
  | Scall _ callee args =>
      expression_mentions_field_deep field callee ||
      expression_list_mentions_field_deep field args
  | Sbuiltin _ _ _ args =>
      expression_list_mentions_field_deep field args
  | Ssequence s1 s2 =>
      statement_mentions_field_s field s1 ||
      statement_mentions_field_s field s2
  | Sifthenelse condition s1 s2 =>
      expression_mentions_field_deep field condition ||
      statement_mentions_field_s field s1 ||
      statement_mentions_field_s field s2
  | Sloop s1 s2 =>
      statement_mentions_field_s field s1 ||
      statement_mentions_field_s field s2
  | Slabel _ body => statement_mentions_field_s field body
  | Sswitch selector cases =>
      expression_mentions_field_deep field selector ||
      statement_mentions_field_ls field cases
  | Sreturn (Some result) =>
      expression_mentions_field_deep field result
  | _ => false
  end
with statement_mentions_field_ls
       (field : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      statement_mentions_field_s field body ||
      statement_mentions_field_ls field rest
  end.

Fixpoint statement_mentions_field_before_call_s
    (stop : ident) (field : ident) (s : statement) : bool :=
  match s with
  | Sassign lhs rhs =>
      expression_mentions_field_deep field lhs ||
      expression_mentions_field_deep field rhs
  | Sset _ rhs => expression_mentions_field_deep field rhs
  | Scall _ callee args =>
      expression_mentions_field_deep field callee ||
      expression_list_mentions_field_deep field args
  | Sbuiltin _ _ _ args =>
      expression_list_mentions_field_deep field args
  | Ssequence s1 s2 =>
      statement_mentions_field_before_call_s stop field s1 ||
      if calls_ident_s stop s1 then
        false
      else
        statement_mentions_field_before_call_s stop field s2
  | Sifthenelse condition s1 s2 =>
      expression_mentions_field_deep field condition ||
      statement_mentions_field_before_call_s stop field s1 ||
      statement_mentions_field_before_call_s stop field s2
  | Sloop s1 s2 =>
      statement_mentions_field_before_call_s stop field s1 ||
      statement_mentions_field_before_call_s stop field s2
  | Slabel _ body =>
      statement_mentions_field_before_call_s stop field body
  | Sswitch selector cases =>
      expression_mentions_field_deep field selector ||
      statement_mentions_field_before_call_ls stop field cases
  | Sreturn (Some result) =>
      expression_mentions_field_deep field result
  | _ => false
  end
with statement_mentions_field_before_call_ls
       (stop : ident) (field : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      statement_mentions_field_before_call_s stop field body ||
      statement_mentions_field_before_call_ls stop field rest
  end.

Definition field_mentioners
    (program : Clight.program) (field : ident) : list ident :=
  map fst
    (filter
      (fun named_function =>
         statement_mentions_field_s field (fn_body (snd named_function)))
      (internal_functions (prog_defs program))).

Definition direct_callers
    (program : Clight.program) (callee : ident) : list ident :=
  map fst
    (filter
      (fun named_function =>
         calls_ident_s callee (fn_body (snd named_function)))
      (internal_functions (prog_defs program))).

Fixpoint init_data_contains_addrof
    (target : ident) (data : list init_data) : bool :=
  match data with
  | Init_addrof found _ :: rest =>
      Pos.eqb found target || init_data_contains_addrof target rest
  | _ :: rest => init_data_contains_addrof target rest
  | [] => false
  end.

Definition type_is_graph_node (ty : type) : bool :=
  match ty with
  | Tstruct found _ => Pos.eqb found G._GraphNode
  | _ => false
  end.

Definition graph_node_link_field (field : ident) : bool :=
  Pos.eqb field G._parent ||
  Pos.eqb field G._children ||
  Pos.eqb field G._prev ||
  Pos.eqb field G._next.

Fixpoint expression_graph_node_link_fields (e : expr) : list ident :=
  match e with
  | Ederef inner _ | Eaddrof inner _ | Eunop _ inner _
  | Ecast inner _ =>
      expression_graph_node_link_fields inner
  | Efield inner found _ =>
      (if graph_node_link_field found
          && type_is_graph_node (typeof inner)
       then [found]
       else []) ++
      expression_graph_node_link_fields inner
  | Ebinop _ lhs rhs _ =>
      expression_graph_node_link_fields lhs ++
      expression_graph_node_link_fields rhs
  | _ => []
  end.

Fixpoint expression_list_graph_node_link_fields
    (args : list expr) : list ident :=
  match args with
  | [] => []
  | arg :: rest =>
      expression_graph_node_link_fields arg ++
      expression_list_graph_node_link_fields rest
  end.

Fixpoint statement_graph_node_link_fields_s
    (s : statement) : list ident :=
  match s with
  | Sassign lhs rhs =>
      expression_graph_node_link_fields lhs ++
      expression_graph_node_link_fields rhs
  | Sset _ rhs => expression_graph_node_link_fields rhs
  | Scall _ callee args =>
      expression_graph_node_link_fields callee ++
      expression_list_graph_node_link_fields args
  | Sbuiltin _ _ _ args =>
      expression_list_graph_node_link_fields args
  | Ssequence s1 s2 =>
      statement_graph_node_link_fields_s s1 ++
      statement_graph_node_link_fields_s s2
  | Sifthenelse condition s1 s2 =>
      expression_graph_node_link_fields condition ++
      statement_graph_node_link_fields_s s1 ++
      statement_graph_node_link_fields_s s2
  | Sloop s1 s2 =>
      statement_graph_node_link_fields_s s1 ++
      statement_graph_node_link_fields_s s2
  | Slabel _ body => statement_graph_node_link_fields_s body
  | Sswitch selector cases =>
      expression_graph_node_link_fields selector ++
      statement_graph_node_link_fields_ls cases
  | Sreturn (Some result) =>
      expression_graph_node_link_fields result
  | _ => []
  end
with statement_graph_node_link_fields_ls
       (cases : labeled_statements) : list ident :=
  match cases with
  | LSnil => []
  | LScons _ body rest =>
      statement_graph_node_link_fields_s body ++
      statement_graph_node_link_fields_ls rest
  end.

Fixpoint statement_graph_node_link_fields_before_call_s
    (stop : ident) (s : statement) : list ident :=
  match s with
  | Sassign lhs rhs =>
      expression_graph_node_link_fields lhs ++
      expression_graph_node_link_fields rhs
  | Sset _ rhs => expression_graph_node_link_fields rhs
  | Scall _ callee args =>
      expression_graph_node_link_fields callee ++
      expression_list_graph_node_link_fields args
  | Sbuiltin _ _ _ args =>
      expression_list_graph_node_link_fields args
  | Ssequence s1 s2 =>
      statement_graph_node_link_fields_before_call_s stop s1 ++
      if calls_ident_s stop s1 then
        []
      else
        statement_graph_node_link_fields_before_call_s stop s2
  | Sifthenelse condition s1 s2 =>
      expression_graph_node_link_fields condition ++
      statement_graph_node_link_fields_before_call_s stop s1 ++
      statement_graph_node_link_fields_before_call_s stop s2
  | Sloop s1 s2 =>
      statement_graph_node_link_fields_before_call_s stop s1 ++
      statement_graph_node_link_fields_before_call_s stop s2
  | Slabel _ body =>
      statement_graph_node_link_fields_before_call_s stop body
  | Sswitch selector cases =>
      expression_graph_node_link_fields selector ++
      statement_graph_node_link_fields_before_call_ls stop cases
  | Sreturn (Some result) =>
      expression_graph_node_link_fields result
  | _ => []
  end
with statement_graph_node_link_fields_before_call_ls
       (stop : ident) (cases : labeled_statements) : list ident :=
  match cases with
  | LSnil => []
  | LScons _ body rest =>
      statement_graph_node_link_fields_before_call_s stop body ++
      statement_graph_node_link_fields_before_call_ls stop rest
  end.

Definition statement_mentions_graph_node_link_fields
    (s : statement) : bool :=
  match statement_graph_node_link_fields_s s with
  | [] => false
  | _ => true
  end.

Definition graph_node_link_field_mentioners
    (program : Clight.program) : list ident :=
  map fst
    (filter
      (fun named_function =>
         statement_mentions_graph_node_link_fields (fn_body (snd named_function)))
      (internal_functions (prog_defs program))).

Definition graph_node_link_field_occurrences
    (program : Clight.program) : list (ident * list ident) :=
  map
    (fun named_function =>
       (fst named_function,
        statement_graph_node_link_fields_s (fn_body (snd named_function))))
    (filter
      (fun named_function =>
         statement_mentions_graph_node_link_fields (fn_body (snd named_function)))
      (internal_functions (prog_defs program))).

Theorem generated_for_32_bit_big_endian :
  M.Info.bitsize = 32%Z /\ M.Info.big_endian = true.
Proof. vm_compute; auto. Qed.

Theorem ssl_outside_node_14_targets_pyramid_entrance :
  contains_warp_node (gvar_init SSL.v_level_ssl_entry)
    20 8 2 10 128 = true.
Proof. vm_compute; reflexivity. Qed.

Theorem ssl_outside_node_1e_targets_pyramid_top :
  contains_warp_node (gvar_init SSL.v_level_ssl_entry)
    30 8 2 20 128 = true.
Proof. vm_compute; reflexivity. Qed.

Theorem ssl_outside_has_small_breakable_box :
  contains_macro_object
    (gvar_init SM.v_ssl_seg7_area_1_macro_objs)
    103 5900 50 3440 0 = true.
Proof. vm_compute; reflexivity. Qed.

Theorem ssl_outside_has_first_bobomb :
  contains_macro_object
    (gvar_init SM.v_ssl_seg7_area_1_macro_objs)
    142 3800 0 6000 0 = true.
Proof. vm_compute; reflexivity. Qed.

Theorem ssl_outside_has_second_bobomb :
  contains_macro_object
    (gvar_init SM.v_ssl_seg7_area_1_macro_objs)
    142 1750 0 6450 0 = true.
Proof. vm_compute; reflexivity. Qed.

Theorem ssl_outside_has_first_jumping_box :
  contains_macro_object
    (gvar_init SM.v_ssl_seg7_area_1_macro_objs)
    118 1120 0 6480 0 = true.
Proof. vm_compute; reflexivity. Qed.

Theorem ssl_outside_has_second_jumping_box :
  contains_macro_object
    (gvar_init SM.v_ssl_seg7_area_1_macro_objs)
    118 (-5200) 0 1700 0 = true.
Proof. vm_compute; reflexivity. Qed.

Theorem ssl_outside_has_koopa_shell_box :
  contains_macro_object
    (gvar_init SM.v_ssl_seg7_area_1_macro_objs)
    94 5840 940 2500 0 = true.
Proof. vm_compute; reflexivity. Qed.

Theorem ssl_outside_has_first_wing_cap_box :
  contains_macro_object
    (gvar_init SM.v_ssl_seg7_area_1_macro_objs)
    91 6900 350 (-5400) 0 = true.
Proof. vm_compute; reflexivity. Qed.

Theorem ssl_outside_has_second_wing_cap_box :
  contains_macro_object
    (gvar_init SM.v_ssl_seg7_area_1_macro_objs)
    91 (-3000) 500 800 0 = true.
Proof. vm_compute; reflexivity. Qed.

Theorem ssl_outside_has_third_wing_cap_box :
  contains_macro_object
    (gvar_init SM.v_ssl_seg7_area_1_macro_objs)
    91 5860 940 4180 0 = true.
Proof. vm_compute; reflexivity. Qed.

Theorem preset_72_is_small_breakable_box :
  macro_preset_behavior_at 72
    (gvar_init P.v_sMacroObjectPresets) =
  Some P._bhvBreakableBoxSmall.
Proof. vm_compute; reflexivity. Qed.

Theorem preset_87_is_jumping_box :
  macro_preset_behavior_at 87
    (gvar_init P.v_sMacroObjectPresets) =
  Some P._bhvJumpingBox.
Proof. vm_compute; reflexivity. Qed.

Theorem preset_111_is_bobomb :
  macro_preset_behavior_at 111
    (gvar_init P.v_sMacroObjectPresets) =
  Some P._bhvBobomb.
Proof. vm_compute; reflexivity. Qed.

Theorem preset_63_is_shell_box :
  macro_preset_behavior_at 63
    (gvar_init P.v_sMacroObjectPresets) =
  Some P._bhvExclamationBox.
Proof. vm_compute; reflexivity. Qed.

Theorem preset_60_is_wing_cap_box :
  macro_preset_behavior_at 60
    (gvar_init P.v_sMacroObjectPresets) =
  Some P._bhvExclamationBox.
Proof. vm_compute; reflexivity. Qed.

Theorem bobomb_is_grabbable :
  first_int32 (gvar_init OB.v_sBobombHitbox) =
  Some (Int.repr 2).
Proof. vm_compute; reflexivity. Qed.

Theorem jumping_box_is_grabbable :
  first_int32 (gvar_init B.v_sJumpingBoxHitbox) =
  Some (Int.repr 2).
Proof. vm_compute; reflexivity. Qed.

Theorem small_breakable_box_is_grabbable :
  first_int32 (gvar_init OB.v_sBreakableBoxSmallHitbox) =
  Some (Int.repr 2).
Proof. vm_compute; reflexivity. Qed.

Theorem warp_area_calls_unload_mario_area :
  calls_ident_s L._unload_mario_area (fn_body L.f_warp_area) = true.
Proof. vm_compute; reflexivity. Qed.

Theorem warp_area_calls_load_area :
  calls_ident_s L._load_area (fn_body L.f_warp_area) = true.
Proof. vm_compute; reflexivity. Qed.

Theorem warp_area_calls_init_mario_after_warp :
  calls_ident_s L._init_mario_after_warp (fn_body L.f_warp_area) = true.
Proof. vm_compute; reflexivity. Qed.

Theorem warp_area_direct_call_order :
  direct_callees_s (fn_body L.f_warp_area) =
  [L._level_control_timer;
   L._unload_mario_area;
   L._load_area;
   L._init_mario_after_warp].
Proof. vm_compute; reflexivity. Qed.

Theorem init_mario_after_warp_rebinds_after_init :
  event_subsequenceb
    [Event_call L._load_mario_area;
     Event_call L._init_mario;
     Event_call L._set_mario_initial_action;
     Event_assign_field L._interactObj;
     Event_assign_field L._usedObj]
    (statement_events_s (fn_body L.f_init_mario_after_warp)) = true.
Proof. vm_compute; reflexivity. Qed.

Theorem init_mario_after_warp_rebinds_spawn_object_after_init :
  event_subsequenceb
    [Event_call L._init_mario;
     Event_call L._set_mario_initial_action;
     Event_set_temp_from_field L._t'41 L._spawnNode L._object;
     Event_assign_field_from_temp L._interactObj L._t'41;
     Event_set_temp_from_field L._t'39 L._spawnNode L._object;
     Event_assign_field_from_temp L._usedObj L._t'39]
    (statement_events_s (fn_body L.f_init_mario_after_warp)) = true.
Proof. vm_compute; reflexivity. Qed.

Theorem act_uninitialized_is_zero :
  Int.eq (Int.repr 0) Int.zero = true.
Proof. vm_compute; reflexivity. Qed.

Theorem init_mario_after_warp_cleanup_is_guarded_by_action_nonzero :
  event_subsequenceb
    [Event_set_temp_from_field L._t'37 L._t'36 L._action]
    (statement_events_s (fn_body L.f_init_mario_after_warp)) = true /\
  temp_nonzero_guarded_event_subsequenceb L._t'37
    [Event_call L._load_mario_area;
     Event_call L._init_mario;
     Event_call L._set_mario_initial_action;
     Event_assign_field L._interactObj;
     Event_assign_field L._usedObj]
    (fn_body L.f_init_mario_after_warp) = true.
Proof. vm_compute; repeat split; reflexivity. Qed.

Theorem init_mario_after_warp_writes_interact_object :
  assigns_field_s L._interactObj
    (fn_body L.f_init_mario_after_warp) = true.
Proof. vm_compute; reflexivity. Qed.

Theorem init_mario_after_warp_writes_used_object :
  assigns_field_s L._usedObj
    (fn_body L.f_init_mario_after_warp) = true.
Proof. vm_compute; reflexivity. Qed.

Theorem init_mario_after_warp_does_not_directly_write_held_object :
  assigns_field_s L._heldObj
    (fn_body L.f_init_mario_after_warp) = false.
Proof. vm_compute; reflexivity. Qed.

Theorem init_mario_after_warp_does_not_directly_write_ridden_object :
  assigns_field_s L._riddenObj
    (fn_body L.f_init_mario_after_warp) = false.
Proof. vm_compute; reflexivity. Qed.

Theorem level_update_interact_object_writers :
  direct_field_writers L.prog L._interactObj =
  [L._init_mario_after_warp].
Proof. vm_compute; reflexivity. Qed.

Theorem level_update_used_object_writers :
  direct_field_writers L.prog L._usedObj =
  [L._init_mario_after_warp].
Proof. vm_compute; reflexivity. Qed.

Theorem level_update_has_no_direct_held_object_writer :
  direct_field_writers L.prog L._heldObj = [].
Proof. vm_compute; reflexivity. Qed.

Theorem level_update_has_no_direct_ridden_object_writer :
  direct_field_writers L.prog L._riddenObj = [].
Proof. vm_compute; reflexivity. Qed.

Theorem interact_warp_disappeared_path_stops_riding_not_holding :
  calls_ident_s I._mario_stop_riding_object
    (fn_body I.f_interact_warp) = true /\
  calls_ident_s I._mario_drop_held_object
    (fn_body I.f_interact_warp) = false /\
  calls_ident_s I._drop_and_set_mario_action
    (fn_body I.f_interact_warp) = false /\
  calls_ident_s I._set_mario_action
    (fn_body I.f_interact_warp) = true.
Proof. vm_compute; repeat split; reflexivity. Qed.

Theorem act_disappeared_triggers_warp_without_dropping_held_object :
  calls_ident_s MC._level_trigger_warp
    (fn_body MC.f_act_disappeared) = true /\
  calls_ident_s MC._drop_and_set_mario_action
    (fn_body MC.f_act_disappeared) = false /\
  calls_ident_s MC._set_mario_action
    (fn_body MC.f_act_disappeared) = false.
Proof. vm_compute; repeat split; reflexivity. Qed.

Theorem level_transition_bodies_do_not_drop_held_object_before_reinit :
  statement_mentions_field_s L._heldObj
    (fn_body L.f_level_trigger_warp) = false /\
  statement_mentions_field_s L._heldObj
    (fn_body L.f_warp_area) = false /\
  statement_mentions_field_s L._heldObj
    (fn_body L.f_warp_level) = false /\
  calls_ident_s L._init_mario_after_warp
    (fn_body L.f_warp_area) = true /\
  calls_ident_s L._init_mario_after_warp
    (fn_body L.f_warp_level) = true /\
  direct_field_writers L.prog L._heldObj = [] /\
  assigns_zero_to_field_s M._heldObj
    (fn_body M.f_init_mario) = true.
Proof.
  repeat split;
    first
      [ vm_compute; reflexivity
      | exact level_update_has_no_direct_held_object_writer
      | exact init_mario_clears_held_object ].
Qed.

Theorem unload_mario_area_calls_unload_objects_from_area :
  calls_ident_s A._unload_objects_from_area
    (fn_body A.f_unload_mario_area) = true.
Proof. vm_compute; reflexivity. Qed.

Theorem unload_mario_area_calls_unload_area :
  calls_ident_s A._unload_area (fn_body A.f_unload_mario_area) = true.
Proof. vm_compute; reflexivity. Qed.

Theorem unload_mario_area_direct_call_order :
  direct_callees_s (fn_body A.f_unload_mario_area) =
  [A._unload_objects_from_area; A._unload_area].
Proof. vm_compute; reflexivity. Qed.

Theorem unload_area_calls_unload_objects_from_area :
  calls_ident_s A._unload_objects_from_area
    (fn_body A.f_unload_area) = true.
Proof. vm_compute; reflexivity. Qed.

Theorem load_area_direct_call_order :
  direct_callees_s (fn_body A.f_load_area) =
  [A._load_area_terrain;
   A._spawn_objects_from_info;
   A._load_obj_warp_nodes;
   A._geo_call_global_function_nodes].
Proof. vm_compute; reflexivity. Qed.

Theorem load_area_does_not_call_update_objects :
  calls_ident_s A._update_objects (fn_body A.f_load_area) = false.
Proof. vm_compute; reflexivity. Qed.

Theorem load_mario_area_does_not_call_update_objects :
  calls_ident_s A._update_objects (fn_body A.f_load_mario_area) = false.
Proof. vm_compute; reflexivity. Qed.

Theorem unload_objects_from_area_calls_unload_object :
  calls_ident_s O._unload_object
    (fn_body O.f_unload_objects_from_area) = true.
Proof. vm_compute; reflexivity. Qed.

Theorem unload_objects_from_area_direct_call_order :
  direct_callees_s (fn_body O.f_unload_objects_from_area) =
  [O._unload_object].
Proof. vm_compute; reflexivity. Qed.

Theorem unload_objects_from_area_traversal_spine :
  direct_callees_s (fn_body O.f_unload_objects_from_area) =
    [O._unload_object] /\
  statement_mentions_field_s O._next
    (fn_body O.f_unload_objects_from_area) = true /\
  statement_mentions_field_s O._activeAreaIndex
    (fn_body O.f_unload_objects_from_area) = true /\
  writes_temp_s O._list (fn_body O.f_unload_objects_from_area) = true /\
  writes_temp_s O._node (fn_body O.f_unload_objects_from_area) = true /\
  writes_temp_s O._obj (fn_body O.f_unload_objects_from_area) = true /\
  writes_temp_s O._i (fn_body O.f_unload_objects_from_area) = true.
Proof.
  repeat split;
    vm_compute;
    reflexivity.
Qed.

Theorem unload_object_deactivates_slot :
  assigns_zero_to_field_s S._activeFlags
    (fn_body S.f_unload_object) = true.
Proof. vm_compute; reflexivity. Qed.

Theorem init_mario_clears_held_object :
  assigns_zero_to_field_s M._heldObj (fn_body M.f_init_mario) = true.
Proof. vm_compute; reflexivity. Qed.

Theorem init_mario_clears_ridden_object :
  assigns_zero_to_field_s M._riddenObj (fn_body M.f_init_mario) = true.
Proof. vm_compute; reflexivity. Qed.

Theorem init_mario_clears_used_object :
  assigns_zero_to_field_s M._usedObj (fn_body M.f_init_mario) = true.
Proof. vm_compute; reflexivity. Qed.

Theorem init_mario_from_save_file_sets_action_uninitialized :
  assigns_zero_to_field_s M._action
    (fn_body M.f_init_mario_from_save_file) = true.
Proof. vm_compute; reflexivity. Qed.

Theorem init_mario_assigns_nonzero_initial_action_shape :
  assigns_field_s M._action (fn_body M.f_init_mario) = true /\
  assigns_zero_to_field_s M._action (fn_body M.f_init_mario) = false.
Proof. vm_compute; repeat split; reflexivity. Qed.

Theorem execute_mario_action_processes_interactions_only_when_action_nonzero :
  event_subsequenceb
    [Event_set_temp_from_field M._t'9 M._t'8 M._action]
    (statement_events_s (fn_body M.f_execute_mario_action)) = true /\
  temp_nonzero_guarded_event_subsequenceb M._t'9
    [Event_call M._update_mario_inputs;
     Event_call M._mario_process_interactions]
    (fn_body M.f_execute_mario_action) = true.
Proof. vm_compute; repeat split; reflexivity. Qed.

Theorem execute_mario_action_normal_warp_sources_guarded_by_action_nonzero :
  event_subsequenceb
    [Event_set_temp_from_field M._t'9 M._t'8 M._action]
    (statement_events_s (fn_body M.f_execute_mario_action)) = true /\
  temp_nonzero_guarded_event_subsequenceb M._t'9
    [Event_call M._update_mario_inputs;
     Event_call M._mario_handle_special_floors;
     Event_call M._mario_process_interactions;
     Event_call M._mario_execute_cutscene_action]
    (fn_body M.f_execute_mario_action) = true.
Proof. vm_compute; repeat split; reflexivity. Qed.

Theorem interaction_handler_table_contains_warp_handlers :
  init_data_contains_addrof I._interact_warp
    (gvar_init I.v_sInteractionHandlers) = true /\
  init_data_contains_addrof I._interact_warp_door
    (gvar_init I.v_sInteractionHandlers) = true.
Proof. vm_compute; repeat split; reflexivity. Qed.

Theorem interaction_warp_handlers_set_actions_not_direct_warp_triggers :
  calls_ident_s I._set_mario_action
    (fn_body I.f_interact_warp) = true /\
  assigns_field_s I._interactObj
    (fn_body I.f_interact_warp) = true /\
  assigns_field_s I._usedObj
    (fn_body I.f_interact_warp) = true /\
  calls_ident_s I._level_trigger_warp
    (fn_body I.f_interact_warp) = false /\
  calls_ident_s I._set_mario_action
    (fn_body I.f_interact_warp_door) = true /\
  calls_ident_s I._level_trigger_warp
    (fn_body I.f_interact_warp_door) = false.
Proof. vm_compute; repeat split; reflexivity. Qed.

Theorem interaction_special_floor_warp_trigger_callers :
  direct_callers I.prog I._level_trigger_warp =
    [I._check_death_barrier; I._mario_handle_special_floors] /\
  calls_ident_s I._level_trigger_warp
    (fn_body I.f_check_death_barrier) = true /\
  calls_ident_s I._level_trigger_warp
    (fn_body I.f_mario_handle_special_floors) = true /\
  calls_ident_s I._check_death_barrier
    (fn_body I.f_mario_handle_special_floors) = true.
Proof. vm_compute; repeat split; reflexivity. Qed.

Theorem disappeared_cutscene_action_triggers_delayed_warp :
  calls_ident_s MC._level_trigger_warp
    (fn_body MC.f_act_disappeared) = true /\
  calls_ident_s MC._act_disappeared
    (fn_body MC.f_mario_execute_cutscene_action) = true.
Proof. vm_compute; repeat split; reflexivity. Qed.

Theorem level_update_normal_play_warp_entry_callers :
  direct_callers L.prog L._warp_area =
    [L._play_mode_normal] /\
  direct_callers L.prog L._level_trigger_warp =
    [L._play_mode_normal] /\
  event_subsequenceb
    [Event_call L._warp_area]
    (statement_events_s (fn_body L.f_play_mode_normal)) = true /\
  calls_ident_s L._level_trigger_warp
    (fn_body L.f_play_mode_normal) = true.
Proof. vm_compute; repeat split; reflexivity. Qed.

Theorem play_mode_normal_demo_warp_call_arguments :
  call_second_arg_shapes_s L._level_trigger_warp
    (fn_body L.f_play_mode_normal) =
  [SecondArgTemp L._t'1; SecondArgConst (Int.repr 22)].
Proof. vm_compute; reflexivity. Qed.

Theorem play_mode_normal_demo_warp_temp_candidates :
  temp_const_assignments_s L._t'1 (fn_body L.f_play_mode_normal) =
  [Int.repr 25; Int.repr 22].
Proof. vm_compute; reflexivity. Qed.

Theorem play_mode_normal_demo_trigger_before_area_update :
  event_subsequenceb
    [Event_call L._level_trigger_warp;
     Event_call L._warp_area;
     Event_call L._area_update_objects;
     Event_call L._initiate_delayed_warp]
    (statement_events_s (fn_body L.f_play_mode_normal)) = true.
Proof. vm_compute; reflexivity. Qed.

Theorem play_mode_frame_advance_routes_through_normal_play :
  calls_ident_s L._warp_area
    (fn_body L.f_play_mode_frame_advance) = false /\
  calls_ident_s L._level_trigger_warp
    (fn_body L.f_play_mode_frame_advance) = false /\
  calls_ident_s L._play_mode_normal
    (fn_body L.f_play_mode_frame_advance) = true /\
  direct_callers L.prog L._play_mode_normal =
    [L._play_mode_frame_advance; L._update_level].
Proof. vm_compute; repeat split; reflexivity. Qed.

Theorem level_init_routes_do_not_directly_trigger_normal_warp_entry :
  calls_ident_s L._warp_area (fn_body L.f_init_level) = false /\
  calls_ident_s L._level_trigger_warp (fn_body L.f_init_level) = false /\
  calls_ident_s L._warp_area
    (fn_body L.f_lvl_init_from_save_file) = false /\
  calls_ident_s L._level_trigger_warp
    (fn_body L.f_lvl_init_from_save_file) = false /\
  calls_ident_s L._init_mario_from_save_file
    (fn_body L.f_lvl_init_from_save_file) = true /\
  calls_ident_s L._init_mario (fn_body L.f_init_level) = true.
Proof. vm_compute; repeat split; reflexivity. Qed.

Theorem object_update_debug_module_does_not_directly_trigger_warp_entry :
  direct_callers O.prog L._level_trigger_warp = [] /\
  direct_callers O.prog L._warp_area = [].
Proof. vm_compute; repeat split; reflexivity. Qed.

Theorem audited_script_area_modules_do_not_directly_trigger_normal_warp_entry :
  direct_callers LS.prog L._level_trigger_warp = [] /\
  direct_callers LS.prog L._warp_area = [] /\
  direct_callers A.prog L._level_trigger_warp = [] /\
  direct_callers A.prog L._warp_area = [] /\
  direct_callers SSL.prog L._level_trigger_warp = [] /\
  direct_callers SSL.prog L._warp_area = [].
Proof. vm_compute; repeat split; reflexivity. Qed.

Theorem nonnormal_script_init_debug_demo_warp_entry_audit :
  proposition_of
    level_init_routes_do_not_directly_trigger_normal_warp_entry /\
  proposition_of
    object_update_debug_module_does_not_directly_trigger_warp_entry /\
  proposition_of play_mode_frame_advance_routes_through_normal_play /\
  proposition_of play_mode_normal_demo_warp_call_arguments /\
  proposition_of play_mode_normal_demo_warp_temp_candidates /\
  proposition_of play_mode_normal_demo_trigger_before_area_update /\
  proposition_of
    audited_script_area_modules_do_not_directly_trigger_normal_warp_entry.
Proof.
  unfold proposition_of.
  split; [ exact level_init_routes_do_not_directly_trigger_normal_warp_entry |].
  split; [ exact object_update_debug_module_does_not_directly_trigger_warp_entry |].
  split; [ exact play_mode_frame_advance_routes_through_normal_play |].
  split; [ exact play_mode_normal_demo_warp_call_arguments |].
  split; [ exact play_mode_normal_demo_warp_temp_candidates |].
  split; [ exact play_mode_normal_demo_trigger_before_area_update |].
  exact audited_script_area_modules_do_not_directly_trigger_normal_warp_entry.
Qed.

Theorem normal_gameplay_ssl_warp_entry_action_nonzero_syntactic_certificate :
  proposition_of
    execute_mario_action_processes_interactions_only_when_action_nonzero /\
  proposition_of
    execute_mario_action_normal_warp_sources_guarded_by_action_nonzero /\
  proposition_of interaction_handler_table_contains_warp_handlers /\
  proposition_of interaction_warp_handlers_set_actions_not_direct_warp_triggers /\
  proposition_of interaction_special_floor_warp_trigger_callers /\
  proposition_of disappeared_cutscene_action_triggers_delayed_warp /\
  proposition_of level_update_normal_play_warp_entry_callers /\
  proposition_of nonnormal_script_init_debug_demo_warp_entry_audit /\
  proposition_of
    audited_script_area_modules_do_not_directly_trigger_normal_warp_entry.
Proof.
  unfold proposition_of.
  split;
    [ exact execute_mario_action_processes_interactions_only_when_action_nonzero
    |].
  split;
    [ exact execute_mario_action_normal_warp_sources_guarded_by_action_nonzero
    |].
  split; [ exact interaction_handler_table_contains_warp_handlers |].
  split;
    [ exact interaction_warp_handlers_set_actions_not_direct_warp_triggers
    |].
  split; [ exact interaction_special_floor_warp_trigger_callers |].
  split; [ exact disappeared_cutscene_action_triggers_delayed_warp |].
  split; [ exact level_update_normal_play_warp_entry_callers |].
  split; [ exact nonnormal_script_init_debug_demo_warp_entry_audit |].
  exact audited_script_area_modules_do_not_directly_trigger_normal_warp_entry.
Qed.

Theorem star_collection_handler_sets_action_but_is_interaction_downstream :
  statement_mentions_field_s I._action
    (fn_body I.f_interact_star_or_key) = true /\
  assigns_field_s I._interactObj
    (fn_body I.f_interact_star_or_key) = true /\
  assigns_field_s I._usedObj
    (fn_body I.f_interact_star_or_key) = true /\
  calls_ident_s I._set_mario_action
    (fn_body I.f_interact_star_or_key) = true.
Proof. vm_compute; repeat split; reflexivity. Qed.

Theorem dynamic_spawn_sets_active_area :
  assigns_field_s H._activeAreaIndex
    (fn_body H.f_spawn_object_at_origin) = true.
Proof. vm_compute; reflexivity. Qed.

Theorem spawninfo_initialization_sets_active_area :
  assigns_field_s G._activeAreaIndex
    (fn_body G.f_geo_obj_init_spawninfo) = true.
Proof. vm_compute; reflexivity. Qed.

Theorem graph_node_active_area_writers :
  direct_field_writers G.prog G._activeAreaIndex =
  [G._geo_obj_init_spawninfo].
Proof. vm_compute; reflexivity. Qed.

Theorem object_helpers_active_area_writers :
  direct_field_writers H.prog H._activeAreaIndex =
  [H._spawn_object_at_origin].
Proof. vm_compute; reflexivity. Qed.

Theorem macro_loader_active_area_writers :
  direct_field_writers P.prog P._activeAreaIndex =
  [P._spawn_macro_objects;
   P._spawn_macro_objects_hardcoded;
   P._spawn_special_objects].
Proof. vm_compute; reflexivity. Qed.

Theorem level_script_active_area_writers :
  direct_field_writers LS.prog LS._activeAreaIndex =
  [LS._level_cmd_init_mario; LS._level_cmd_place_object].
Proof. vm_compute; reflexivity. Qed.

Theorem area_has_no_direct_active_area_writer :
  direct_field_writers A.prog A._activeAreaIndex = [].
Proof. vm_compute; reflexivity. Qed.

Theorem object_update_has_no_direct_active_area_writer :
  direct_field_writers O.prog O._activeAreaIndex = [].
Proof. vm_compute; reflexivity. Qed.

Theorem behavior_actions_have_no_direct_active_area_writer :
  direct_field_writers B.prog B._activeAreaIndex = [].
Proof. vm_compute; reflexivity. Qed.

Theorem obj_behaviors_have_no_direct_active_area_writer :
  direct_field_writers OB.prog OB._activeAreaIndex = [].
Proof. vm_compute; reflexivity. Qed.

Theorem audio_has_no_direct_active_flags_writer :
  direct_field_writers AU.prog S._activeFlags = [].
Proof. vm_compute; reflexivity. Qed.

Theorem spawn_object_active_flags_writers :
  direct_field_writers S.prog S._activeFlags =
  [S._unload_object;
   S._allocate_object;
   S._create_object;
   S._mark_obj_for_deletion].
Proof. vm_compute; reflexivity. Qed.

Theorem stop_sounds_does_not_write_through_source_pointer :
  assigns_through_temp_s AU._pos
    (fn_body AU.f_stop_sounds_from_source) = false.
Proof. vm_compute; reflexivity. Qed.

Theorem stop_sounds_direct_call_order :
  direct_callees_s (fn_body AU.f_stop_sounds_from_source) =
  [AU._update_background_music_after_sound].
Proof. vm_compute; reflexivity. Qed.

Theorem geo_remove_child_direct_call_order :
  direct_callees_s (fn_body G.f_geo_remove_child) = [].
Proof. vm_compute; reflexivity. Qed.

Theorem geo_add_child_direct_call_order :
  direct_callees_s (fn_body G.f_geo_add_child) = [].
Proof. vm_compute; reflexivity. Qed.

Theorem deallocate_object_has_no_direct_active_flags_assignment :
  assigns_field_s S._activeFlags
    (fn_body S.f_deallocate_object) = false.
Proof. vm_compute; reflexivity. Qed.

Theorem geo_remove_child_has_no_direct_active_flags_assignment :
  assigns_field_s G._activeFlags
    (fn_body G.f_geo_remove_child) = false.
Proof. vm_compute; reflexivity. Qed.

Theorem geo_add_child_has_no_direct_active_flags_assignment :
  assigns_field_s G._activeFlags
    (fn_body G.f_geo_add_child) = false.
Proof. vm_compute; reflexivity. Qed.

Theorem cleanup_call_targets_have_no_direct_active_flags_assignment :
  direct_field_writers AU.prog S._activeFlags = [] /\
  assigns_through_temp_s AU._pos
    (fn_body AU.f_stop_sounds_from_source) = false /\
  assigns_field_s S._activeFlags
    (fn_body S.f_deallocate_object) = false /\
  assigns_field_s G._activeFlags
    (fn_body G.f_geo_remove_child) = false /\
  assigns_field_s G._activeFlags
    (fn_body G.f_geo_add_child) = false.
Proof.
  repeat split;
    first
      [ exact audio_has_no_direct_active_flags_writer
      | exact stop_sounds_does_not_write_through_source_pointer
      | exact deallocate_object_has_no_direct_active_flags_assignment
      | exact geo_remove_child_has_no_direct_active_flags_assignment
      | exact geo_add_child_has_no_direct_active_flags_assignment ].
Qed.

Theorem non_deallocate_cleanup_helpers_have_no_direct_active_flags_write :
  direct_field_writers AU.prog S._activeFlags = [] /\
  assigns_through_temp_s AU._pos
    (fn_body AU.f_stop_sounds_from_source) = false /\
  direct_callees_s (fn_body AU.f_stop_sounds_from_source) =
    [AU._update_background_music_after_sound] /\
  assigns_field_s G._activeFlags
    (fn_body G.f_geo_remove_child) = false /\
  direct_callees_s (fn_body G.f_geo_remove_child) = [] /\
  assigns_field_s G._activeFlags
    (fn_body G.f_geo_add_child) = false /\
  direct_callees_s (fn_body G.f_geo_add_child) = [].
Proof.
  repeat split;
    first
      [ exact audio_has_no_direct_active_flags_writer
      | exact stop_sounds_does_not_write_through_source_pointer
      | exact stop_sounds_direct_call_order
      | exact geo_remove_child_has_no_direct_active_flags_assignment
      | exact geo_remove_child_direct_call_order
      | exact geo_add_child_has_no_direct_active_flags_assignment
      | exact geo_add_child_direct_call_order ].
Qed.

Theorem transition_structural_spine :
  calls_ident_s L._unload_mario_area (fn_body L.f_warp_area) = true /\
  calls_ident_s A._unload_objects_from_area
    (fn_body A.f_unload_mario_area) = true /\
  calls_ident_s A._unload_area (fn_body A.f_unload_mario_area) = true /\
  calls_ident_s A._unload_objects_from_area
    (fn_body A.f_unload_area) = true /\
  calls_ident_s O._unload_object
    (fn_body O.f_unload_objects_from_area) = true /\
  assigns_zero_to_field_s S._activeFlags
    (fn_body S.f_unload_object) = true /\
  assigns_zero_to_field_s M._heldObj (fn_body M.f_init_mario) = true /\
  assigns_zero_to_field_s M._riddenObj (fn_body M.f_init_mario) = true /\
  assigns_zero_to_field_s M._usedObj (fn_body M.f_init_mario) = true /\
  event_subsequenceb
    [Event_call L._load_mario_area;
     Event_call L._init_mario;
     Event_call L._set_mario_initial_action;
     Event_assign_field L._interactObj;
     Event_assign_field L._usedObj]
    (statement_events_s (fn_body L.f_init_mario_after_warp)) = true /\
  event_subsequenceb
    [Event_call L._init_mario;
     Event_call L._set_mario_initial_action;
     Event_set_temp_from_field L._t'41 L._spawnNode L._object;
     Event_assign_field_from_temp L._interactObj L._t'41;
     Event_set_temp_from_field L._t'39 L._spawnNode L._object;
     Event_assign_field_from_temp L._usedObj L._t'39]
    (statement_events_s (fn_body L.f_init_mario_after_warp)) = true /\
  direct_field_writers L.prog L._heldObj = [] /\
  direct_field_writers L.prog L._riddenObj = [].
Proof.
  repeat split;
    first
      [ exact warp_area_calls_unload_mario_area
      | exact unload_mario_area_calls_unload_objects_from_area
      | exact unload_mario_area_calls_unload_area
      | exact unload_area_calls_unload_objects_from_area
      | exact unload_objects_from_area_calls_unload_object
      | exact unload_object_deactivates_slot
      | exact init_mario_clears_held_object
      | exact init_mario_clears_ridden_object
      | exact init_mario_clears_used_object
      | exact init_mario_after_warp_rebinds_after_init
      | exact init_mario_after_warp_rebinds_spawn_object_after_init
      | exact level_update_has_no_direct_held_object_writer
      | exact level_update_has_no_direct_ridden_object_writer ].
Qed.

Theorem warp_area_loads_destination_before_mario_reference_cleanup :
  direct_callees_s (fn_body L.f_warp_area) =
    [L._level_control_timer;
     L._unload_mario_area;
     L._load_area;
     L._init_mario_after_warp] /\
  event_subsequenceb
    [Event_call L._load_mario_area;
     Event_call L._init_mario]
    (statement_events_s (fn_body L.f_init_mario_after_warp)) = true /\
  assigns_zero_to_field_s M._heldObj (fn_body M.f_init_mario) = true /\
  assigns_zero_to_field_s M._riddenObj (fn_body M.f_init_mario) = true /\
  assigns_zero_to_field_s M._usedObj (fn_body M.f_init_mario) = true /\
  event_subsequenceb
    [Event_call L._init_mario;
     Event_set_temp_from_field L._t'41 L._spawnNode L._object;
     Event_assign_field_from_temp L._interactObj L._t'41;
     Event_set_temp_from_field L._t'39 L._spawnNode L._object;
     Event_assign_field_from_temp L._usedObj L._t'39]
    (statement_events_s (fn_body L.f_init_mario_after_warp)) = true.
Proof.
  repeat split;
    first
      [ exact warp_area_direct_call_order
      | vm_compute; reflexivity
      | exact init_mario_clears_held_object
      | exact init_mario_clears_ridden_object
      | exact init_mario_clears_used_object
      | exact init_mario_after_warp_rebinds_spawn_object_after_init ].
Qed.

Theorem load_area_does_not_mention_stale_mario_object_refs :
  statement_mentions_field_s L._heldObj
    (fn_body A.f_load_area) = false /\
  statement_mentions_field_s L._usedObj
    (fn_body A.f_load_area) = false /\
  statement_mentions_field_s L._riddenObj
    (fn_body A.f_load_area) = false /\
  statement_mentions_field_s L._interactObj
    (fn_body A.f_load_area) = false.
Proof. vm_compute; repeat split; reflexivity. Qed.

Theorem load_mario_area_does_not_mention_stale_mario_object_refs :
  statement_mentions_field_s L._heldObj
    (fn_body A.f_load_mario_area) = false /\
  statement_mentions_field_s L._usedObj
    (fn_body A.f_load_mario_area) = false /\
  statement_mentions_field_s L._riddenObj
    (fn_body A.f_load_mario_area) = false /\
  statement_mentions_field_s L._interactObj
    (fn_body A.f_load_mario_area) = false.
Proof. vm_compute; repeat split; reflexivity. Qed.

Theorem object_list_processor_does_not_mention_stale_mario_object_refs :
  field_mentioners O.prog O._heldObj = [] /\
  field_mentioners O.prog O._usedObj = [] /\
  field_mentioners O.prog O._riddenObj = [] /\
  field_mentioners O.prog O._interactObj = [].
Proof. vm_compute; repeat split; reflexivity. Qed.

Theorem init_mario_after_warp_before_init_mario_does_not_mention_stale_refs :
  statement_mentions_field_before_call_s L._init_mario L._heldObj
    (fn_body L.f_init_mario_after_warp) = false /\
  statement_mentions_field_before_call_s L._init_mario L._usedObj
    (fn_body L.f_init_mario_after_warp) = false /\
  statement_mentions_field_before_call_s L._init_mario L._riddenObj
    (fn_body L.f_init_mario_after_warp) = false /\
  statement_mentions_field_before_call_s L._init_mario L._interactObj
    (fn_body L.f_init_mario_after_warp) = false.
Proof. vm_compute; repeat split; reflexivity. Qed.

Theorem pyramid_load_window_stale_refs_not_observed_before_cleanup :
  statement_mentions_field_s L._heldObj
    (fn_body A.f_load_area) = false /\
  statement_mentions_field_s L._usedObj
    (fn_body A.f_load_area) = false /\
  statement_mentions_field_s L._riddenObj
    (fn_body A.f_load_area) = false /\
  statement_mentions_field_s L._interactObj
    (fn_body A.f_load_area) = false /\
  statement_mentions_field_s L._heldObj
    (fn_body A.f_load_mario_area) = false /\
  statement_mentions_field_s L._usedObj
    (fn_body A.f_load_mario_area) = false /\
  statement_mentions_field_s L._riddenObj
    (fn_body A.f_load_mario_area) = false /\
  statement_mentions_field_s L._interactObj
    (fn_body A.f_load_mario_area) = false /\
  field_mentioners O.prog O._heldObj = [] /\
  field_mentioners O.prog O._usedObj = [] /\
  field_mentioners O.prog O._riddenObj = [] /\
  field_mentioners O.prog O._interactObj = [] /\
  statement_mentions_field_before_call_s L._init_mario L._heldObj
    (fn_body L.f_init_mario_after_warp) = false /\
  statement_mentions_field_before_call_s L._init_mario L._usedObj
    (fn_body L.f_init_mario_after_warp) = false /\
  statement_mentions_field_before_call_s L._init_mario L._riddenObj
    (fn_body L.f_init_mario_after_warp) = false /\
  statement_mentions_field_before_call_s L._init_mario L._interactObj
    (fn_body L.f_init_mario_after_warp) = false.
Proof.
  vm_compute; repeat split; reflexivity.
Qed.

Theorem pyramid_load_window_object_owned_roots_not_mentioned_before_cleanup :
  statement_mentions_field_s S._platform
    (fn_body A.f_load_area) = false /\
  statement_mentions_field_s S._asObject
    (fn_body A.f_load_area) = false /\
  statement_mentions_field_s S._platform
    (fn_body A.f_load_mario_area) = false /\
  statement_mentions_field_s S._asObject
    (fn_body A.f_load_mario_area) = false /\
  field_mentioners O.prog O._platform = [] /\
  field_mentioners O.prog O._asObject = [] /\
  statement_mentions_field_before_call_s L._init_mario S._platform
    (fn_body L.f_init_mario_after_warp) = false /\
  statement_mentions_field_before_call_s L._init_mario S._asObject
    (fn_body L.f_init_mario_after_warp) = false.
Proof. vm_compute; repeat split; reflexivity. Qed.

Theorem pyramid_load_window_full_object_owned_roots_not_mentioned_before_cleanup :
  statement_mentions_field_s S._parentObj
    (fn_body A.f_load_area) = false /\
  statement_mentions_field_s S._prevObj
    (fn_body A.f_load_area) = false /\
  statement_mentions_field_s S._platform
    (fn_body A.f_load_area) = false /\
  statement_mentions_field_s S._collidedObjs
    (fn_body A.f_load_area) = false /\
  statement_mentions_field_s S._asObject
    (fn_body A.f_load_area) = false /\
  statement_mentions_field_s S._parentObj
    (fn_body A.f_load_mario_area) = false /\
  statement_mentions_field_s S._prevObj
    (fn_body A.f_load_mario_area) = false /\
  statement_mentions_field_s S._platform
    (fn_body A.f_load_mario_area) = false /\
  statement_mentions_field_s S._collidedObjs
    (fn_body A.f_load_mario_area) = false /\
  statement_mentions_field_s S._asObject
    (fn_body A.f_load_mario_area) = false /\
  field_mentioners O.prog O._parentObj = [] /\
  field_mentioners O.prog O._prevObj = [] /\
  field_mentioners O.prog O._platform = [] /\
  field_mentioners O.prog O._collidedObjs = [] /\
  field_mentioners O.prog O._asObject = [] /\
  statement_mentions_field_before_call_s L._init_mario S._parentObj
    (fn_body L.f_init_mario_after_warp) = false /\
  statement_mentions_field_before_call_s L._init_mario S._prevObj
    (fn_body L.f_init_mario_after_warp) = false /\
  statement_mentions_field_before_call_s L._init_mario S._platform
    (fn_body L.f_init_mario_after_warp) = false /\
  statement_mentions_field_before_call_s L._init_mario S._collidedObjs
    (fn_body L.f_init_mario_after_warp) = false /\
  statement_mentions_field_before_call_s L._init_mario S._asObject
    (fn_body L.f_init_mario_after_warp) = false.
Proof. vm_compute; repeat split; reflexivity. Qed.

Theorem pyramid_load_window_mario_platform_externals_not_called_before_cleanup :
  calls_ident_s O._clear_mario_platform
    (fn_body A.f_load_area) = false /\
  calls_ident_s O._apply_mario_platform_displacement
    (fn_body A.f_load_area) = false /\
  calls_ident_s O._update_mario_platform
    (fn_body A.f_load_area) = false /\
  calls_ident_s O._clear_mario_platform
    (fn_body A.f_load_mario_area) = false /\
  calls_ident_s O._apply_mario_platform_displacement
    (fn_body A.f_load_mario_area) = false /\
  calls_ident_s O._update_mario_platform
    (fn_body A.f_load_mario_area) = false /\
  calls_ident_s O._clear_mario_platform
    (fn_body L.f_init_mario_after_warp) = false /\
  calls_ident_s O._apply_mario_platform_displacement
    (fn_body L.f_init_mario_after_warp) = false /\
  calls_ident_s O._update_mario_platform
    (fn_body L.f_init_mario_after_warp) = false.
Proof. vm_compute; repeat split; reflexivity. Qed.

Theorem pyramid_load_window_graph_specific_roots_not_mentioned_before_cleanup :
  statement_mentions_field_s G._sharedChild
    (fn_body A.f_load_area) = false /\
  statement_mentions_field_s G._objNode
    (fn_body A.f_load_area) = false /\
  statement_mentions_field_s G._sharedChild
    (fn_body A.f_load_mario_area) = false /\
  statement_mentions_field_s G._objNode
    (fn_body A.f_load_mario_area) = false /\
  statement_mentions_field_before_call_s L._init_mario G._sharedChild
    (fn_body L.f_init_mario_after_warp) = false /\
  statement_mentions_field_before_call_s L._init_mario G._objNode
    (fn_body L.f_init_mario_after_warp) = false.
Proof. vm_compute; repeat split; reflexivity. Qed.

Theorem load_area_direct_typed_graph_node_link_fields :
  statement_graph_node_link_fields_s (fn_body A.f_load_area) = [].
Proof. vm_compute; reflexivity. Qed.

Theorem load_obj_warp_nodes_typed_graph_node_link_fields :
  statement_graph_node_link_fields_s (fn_body A.f_load_obj_warp_nodes) =
    [G._children; G._next; G._children].
Proof. vm_compute; reflexivity. Qed.

Theorem load_area_calls_graph_node_link_traversal_helpers :
  event_subsequenceb
    [Event_call A._load_obj_warp_nodes;
     Event_call A._geo_call_global_function_nodes]
    (statement_events_s (fn_body A.f_load_area)) = true.
Proof. vm_compute; reflexivity. Qed.

Theorem area_typed_graph_node_link_field_occurrences :
  graph_node_link_field_occurrences A.prog =
    [(A._load_obj_warp_nodes, [G._children; G._next; G._children])].
Proof. vm_compute; reflexivity. Qed.

Theorem load_mario_area_direct_typed_graph_node_link_fields :
  statement_graph_node_link_fields_s (fn_body A.f_load_mario_area) = [].
Proof. vm_compute; reflexivity. Qed.

Theorem object_list_processor_typed_graph_node_link_field_mentioners :
  graph_node_link_field_mentioners O.prog = [].
Proof. vm_compute; reflexivity. Qed.

Theorem init_mario_after_warp_before_init_mario_typed_graph_node_link_fields :
  statement_graph_node_link_fields_before_call_s L._init_mario
    (fn_body L.f_init_mario_after_warp) = [].
Proof. vm_compute; reflexivity. Qed.

Theorem graph_node_typed_graph_node_link_field_mentioners :
  graph_node_link_field_mentioners G.prog =
    [G._init_scene_graph_node_links;
     G._geo_add_child;
     G._geo_remove_child;
     G._geo_make_first_child;
     G._geo_call_global_function_nodes_helper;
     G._geo_call_global_function_nodes;
     G._geo_find_root].
Proof. vm_compute; reflexivity. Qed.

Theorem pyramid_load_window_typed_graph_node_link_audit :
  statement_graph_node_link_fields_s (fn_body A.f_load_area) = [] /\
  statement_graph_node_link_fields_s (fn_body A.f_load_obj_warp_nodes) =
    [G._children; G._next; G._children] /\
  event_subsequenceb
    [Event_call A._load_obj_warp_nodes;
     Event_call A._geo_call_global_function_nodes]
    (statement_events_s (fn_body A.f_load_area)) = true /\
  statement_graph_node_link_fields_s (fn_body A.f_load_mario_area) = [] /\
  graph_node_link_field_mentioners O.prog = [] /\
  statement_graph_node_link_fields_before_call_s L._init_mario
    (fn_body L.f_init_mario_after_warp) = [] /\
  graph_node_link_field_mentioners G.prog =
    [G._init_scene_graph_node_links;
     G._geo_add_child;
     G._geo_remove_child;
     G._geo_make_first_child;
     G._geo_call_global_function_nodes_helper;
     G._geo_call_global_function_nodes;
     G._geo_find_root].
Proof.
  repeat split;
    first
      [ exact load_area_direct_typed_graph_node_link_fields
      | exact load_obj_warp_nodes_typed_graph_node_link_fields
      | exact load_area_calls_graph_node_link_traversal_helpers
      | exact load_mario_area_direct_typed_graph_node_link_fields
      | exact object_list_processor_typed_graph_node_link_field_mentioners
      | exact init_mario_after_warp_before_init_mario_typed_graph_node_link_fields
      | exact graph_node_typed_graph_node_link_field_mentioners ].
Qed.
