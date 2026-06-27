From Coq Require Import List ZArith.
Import ListNotations.
From compcert Require Import AST Ctypes Clight Integers.
From SSLPyramid.Generated Require Import
  area audio_external behavior_actions graph_node level_script level_update
  macro_special_objects mario
  obj_behaviors object_helpers object_list_processor spawn_object
  ssl_area1_macro ssl_script.
From SSLPyramid.Proofs Require Import ASTFacts.

Module A := area.
Module AU := audio_external.
Module B := behavior_actions.
Module G := graph_node.
Module LS := level_script.
Module L := level_update.
Module P := macro_special_objects.
Module M := mario.
Module OB := obj_behaviors.
Module H := object_helpers.
Module O := object_list_processor.
Module S := spawn_object.
Module SM := ssl_area1_macro.
Module SSL := ssl_script.

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

Theorem unload_objects_from_area_calls_unload_object :
  calls_ident_s O._unload_object
    (fn_body O.f_unload_objects_from_area) = true.
Proof. vm_compute; reflexivity. Qed.

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
    (fn_body A.f_load_area) = false.
Proof. vm_compute; repeat split; reflexivity. Qed.

Theorem load_mario_area_does_not_mention_stale_mario_object_refs :
  statement_mentions_field_s L._heldObj
    (fn_body A.f_load_mario_area) = false /\
  statement_mentions_field_s L._usedObj
    (fn_body A.f_load_mario_area) = false /\
  statement_mentions_field_s L._riddenObj
    (fn_body A.f_load_mario_area) = false.
Proof. vm_compute; repeat split; reflexivity. Qed.

Theorem object_list_processor_does_not_mention_stale_mario_object_refs :
  field_mentioners O.prog O._heldObj = [] /\
  field_mentioners O.prog O._usedObj = [] /\
  field_mentioners O.prog O._riddenObj = [].
Proof. vm_compute; repeat split; reflexivity. Qed.

Theorem init_mario_after_warp_before_init_mario_does_not_mention_stale_refs :
  statement_mentions_field_before_call_s L._init_mario L._heldObj
    (fn_body L.f_init_mario_after_warp) = false /\
  statement_mentions_field_before_call_s L._init_mario L._usedObj
    (fn_body L.f_init_mario_after_warp) = false /\
  statement_mentions_field_before_call_s L._init_mario L._riddenObj
    (fn_body L.f_init_mario_after_warp) = false.
Proof. vm_compute; repeat split; reflexivity. Qed.

Theorem pyramid_load_window_stale_refs_not_observed_before_cleanup :
  statement_mentions_field_s L._heldObj
    (fn_body A.f_load_area) = false /\
  statement_mentions_field_s L._usedObj
    (fn_body A.f_load_area) = false /\
  statement_mentions_field_s L._riddenObj
    (fn_body A.f_load_area) = false /\
  statement_mentions_field_s L._heldObj
    (fn_body A.f_load_mario_area) = false /\
  statement_mentions_field_s L._usedObj
    (fn_body A.f_load_mario_area) = false /\
  statement_mentions_field_s L._riddenObj
    (fn_body A.f_load_mario_area) = false /\
  field_mentioners O.prog O._heldObj = [] /\
  field_mentioners O.prog O._usedObj = [] /\
  field_mentioners O.prog O._riddenObj = [] /\
  statement_mentions_field_before_call_s L._init_mario L._heldObj
    (fn_body L.f_init_mario_after_warp) = false /\
  statement_mentions_field_before_call_s L._init_mario L._usedObj
    (fn_body L.f_init_mario_after_warp) = false /\
  statement_mentions_field_before_call_s L._init_mario L._riddenObj
    (fn_body L.f_init_mario_after_warp) = false.
Proof.
  repeat split;
    first
      [ destruct load_area_does_not_mention_stale_mario_object_refs as
          [Hheld [Hused Hridden]]; exact Hheld
      | destruct load_area_does_not_mention_stale_mario_object_refs as
          [Hheld [Hused Hridden]]; exact Hused
      | destruct load_area_does_not_mention_stale_mario_object_refs as
          [Hheld [Hused Hridden]]; exact Hridden
      | destruct load_mario_area_does_not_mention_stale_mario_object_refs as
          [Hheld [Hused Hridden]]; exact Hheld
      | destruct load_mario_area_does_not_mention_stale_mario_object_refs as
          [Hheld [Hused Hridden]]; exact Hused
      | destruct load_mario_area_does_not_mention_stale_mario_object_refs as
          [Hheld [Hused Hridden]]; exact Hridden
      | destruct object_list_processor_does_not_mention_stale_mario_object_refs
          as [Hheld [Hused Hridden]]; exact Hheld
      | destruct object_list_processor_does_not_mention_stale_mario_object_refs
          as [Hheld [Hused Hridden]]; exact Hused
      | destruct object_list_processor_does_not_mention_stale_mario_object_refs
          as [Hheld [Hused Hridden]]; exact Hridden
      | destruct init_mario_after_warp_before_init_mario_does_not_mention_stale_refs
          as [Hheld [Hused Hridden]]; exact Hheld
      | destruct init_mario_after_warp_before_init_mario_does_not_mention_stale_refs
          as [Hheld [Hused Hridden]]; exact Hused
      | destruct init_mario_after_warp_before_init_mario_does_not_mention_stale_refs
          as [Hheld [Hused Hridden]]; exact Hridden ].
Qed.
