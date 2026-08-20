(** Closure of the normal Mario behavior-tail producer for timer-131 Ink.

    The dangerous generic tail is guarded by bit zero of [oFlags] and, when
    enabled, writes Graphics Y as raw Object Y plus [oGraphYOffset].  Earlier
    receipts checked only the three callbacks named by [bhvMario], and they
    accidentally inspected the signed union view of [oFlags] although the
    generated consumer reads [rawData.asU32[1]].

    This module corrects that union-view boundary and checks considerably
    more:

    - the exact bilateral whole-corpus direct writers of [asU32[1]] and
      [asF32[21]];
    - the complete recursively reachable direct-call graph from all three
      callbacks named by [bhvMario];
    - disjointness of that closed graph from both writer inventories; and
    - the exact [OR_INT(oFlags, 0x100)] interpreter source path and the fact
      that OR-ing 0x100 cannot turn on bit zero.

    Together with allocation clearing and the absence of a field-21 command
    in [bhvMario], this eliminates the ordinary direct-call Mario-tail story
    at the generated-source boundary.  It is not a linked retail execution
    theorem: indirect calls, externals, forged behavior pointers, aliases,
    out-of-bounds stores, slot reuse, and a failure to preserve the live
    [gCurrentObject = gMarioObject] identity remain explicit escape classes. *)

From Coq Require Import Bool Lia List String ZArith.
From compcert Require Import AST Clight Ctypes Integers export.Ctypesdefs.
From LessThanOneAPress.Generated Require Import
  us_behavior_data us_behavior_script
  us_object_list_processor
  jp_behavior_data jp_behavior_script
  jp_object_list_processor.
From LessThanOneAPress.Proofs Require Import
  ASTFacts ClightFacts ClightRefinement InkTimer131ProducerClosure
  JPGeneratedWriterCensus PyramidTopPU Timer131Surface.

Import ListNotations.
Local Open Scope Z_scope.
Local Open Scope string_scope.

Module ITMTC_USD := us_behavior_data.
Module ITMTC_USB := us_behavior_script.
Module ITMTC_USO := us_object_list_processor.
Module ITMTC_JPD := jp_behavior_data.
Module ITMTC_JPB := jp_behavior_script.
Module ITMTC_JPO := jp_object_list_processor.

Definition ink_expected_flag_writer_names : list string :=
  ["spawn_object_rel_with_rot";
   "spawn_obj_with_transform_flags";
   "obj_create_transform_from_self";
   "obj_set_hitbox";
   "bobomb_thrown_loop";
   "beta_holdable_object_throw";
   "bully_check_mario_collision";
   "bully_act_knockback";
   "bully_act_back_up";
   "breakable_box_small_get_thrown";
   "bhv_mips_act_fall_down";
   "bhv_mips_thrown";
   "obj_set_knockback_action";
   "koopa_the_quick_act_show_init_text";
   "koopa_the_quick_act_after_race";
   "spiny_act_walk";
   "bhv_fire_piranha_plant_init";
   "klepto_act_wait_for_mario";
   "klepto_act_turn_toward_mario";
   "klepto_act_retreat";
   "bhv_klepto_update";
   "skeeter_act_lunge";
   "king_bobomb_act_0";
   "bhv_spindrift_loop";
   "ukiki_act_go_to_cage";
   "exclamation_box_spawn_contents";
   "boo_set_move_yaw_for_during_hit";
   "boo_reset_after_hit";
   "boo_update_during_death";
   "bhv_scuttlebug_loop"].

Definition ink_expected_offset_writer_names : list string :=
  ["obj_copy_graph_y_offset";
   "bobomb_act_explode";
   "bhv_bowling_ball_initialize_loop";
   "bhv_snowmans_bottom_loop";
   "bhv_big_boulder_loop";
   "cap_sink_quicksand";
   "cur_obj_spin_all_dimensions";
   "bhv_pokey_body_part_update";
   "spiny_act_walk";
   "spiny_act_held_by_lakitu";
   "spiny_act_thrown_by_lakitu";
   "bhv_water_bomb_update";
   "bhv_mr_blizzard_update";
   "bhv_flying_bookend_loop";
   "bhv_fire_spitter_update";
   "bhv_small_piranha_flame_loop";
   "triplet_butterfly_act_activate";
   "bhv_mr_i_body_loop";
   "heave_ho_move";
   "beta_boo_key_dropped_loop";
   "bhv_grand_star_loop";
   "bhv_bowser_key_loop";
   "bhv_flame_bowser_loop";
   "bhv_flame_floating_landing_loop";
   "bhv_lll_sinking_rock_block_loop";
   "exclamation_box_act_2";
   "exclamation_box_act_3";
   "bhv_big_boo_loop"].

Definition ink_expected_flag_writers : list ident :=
  map ident_of_string ink_expected_flag_writer_names.

Definition ink_expected_offset_writers : list ident :=
  map ident_of_string ink_expected_offset_writer_names.

Definition ink_us_definitions := generated_definitions_of us_translation_units.
Definition ink_jp_definitions := generated_definitions_of jp_translation_units.

Definition ink_us_flag_writers :=
  internal_nested_array_slot_assignment_sites
    JGC_Mario._rawData JGC_Mario._asU32 1 ink_us_definitions.

Definition ink_jp_flag_writers :=
  internal_nested_array_slot_assignment_sites
    JGC_Mario._rawData JGC_Mario._asU32 1 ink_jp_definitions.

Definition ink_us_offset_writers :=
  internal_nested_array_slot_assignment_sites
    JGC_Mario._rawData JGC_Mario._asF32 21 ink_us_definitions.

Definition ink_jp_offset_writers :=
  internal_nested_array_slot_assignment_sites
    JGC_Mario._rawData JGC_Mario._asF32 21 ink_jp_definitions.

(** These are literal lvalue-shape censuses.  A store through another union
    view or an aliased pointer is deliberately not reclassified as a literal
    [asU32[1]]/[asF32[21]] store. *)
Definition ink_tail_writer_inventory_bilateral_claim : Prop :=
  ink_us_flag_writers = ink_expected_flag_writers /\
  ink_jp_flag_writers = ink_expected_flag_writers /\
  ink_us_offset_writers = ink_expected_offset_writers /\
  ink_jp_offset_writers = ink_expected_offset_writers /\
  List.length ink_expected_flag_writers = 30%nat /\
  List.length ink_expected_offset_writers = 28%nat.

Theorem ink_tail_writer_inventory_exact_bilateral :
  ink_tail_writer_inventory_bilateral_claim.
Proof.
  unfold ink_tail_writer_inventory_bilateral_claim,
    ink_us_flag_writers, ink_jp_flag_writers,
    ink_us_offset_writers, ink_jp_offset_writers,
    ink_us_definitions, ink_jp_definitions,
    ink_expected_flag_writers, ink_expected_offset_writers,
    ink_expected_flag_writer_names, ink_expected_offset_writer_names,
    generated_definitions_of.
  vm_compute. repeat split; reflexivity.
Qed.

Fixpoint ink_internal_direct_callees
    (target : ident)
    (definitions : list (ident * globdef (fundef function) type)) : list ident :=
  match definitions with
  | [] => []
  | (id, Gfun (Internal body)) :: rest =>
      (if Pos.eqb id target then direct_callees_s (fn_body body) else []) ++
      ink_internal_direct_callees target rest
  | _ :: rest => ink_internal_direct_callees target rest
  end.

Definition ink_ident_in (id : ident) (ids : list ident) : bool :=
  existsb (Pos.eqb id) ids.

Fixpoint ink_ident_list_eqb (left right : list ident) : bool :=
  match left, right with
  | [], [] => true
  | x :: xs, y :: ys => Pos.eqb x y && ink_ident_list_eqb xs ys
  | _, _ => false
  end.

Fixpoint ink_direct_call_closure
    (fuel : nat)
    (definitions : list (ident * globdef (fundef function) type))
    (frontier seen : list ident) : list ident :=
  match fuel with
  | O => seen ++ frontier
  | S rest =>
      let expanded := List.concat
        (map (fun id => ink_internal_direct_callees id definitions) frontier) in
      let fresh := filter
        (fun id => negb (ink_ident_in id (seen ++ frontier))) expanded in
      ink_direct_call_closure rest definitions (nodup Pos.eq_dec fresh)
        (seen ++ frontier)
  end.

Definition ink_mario_callback_roots : list ident :=
  map ident_of_string
    ["bhv_mario_update";
     "try_print_debug_mario_level_info";
     "try_do_mario_debug_object_spawn"].

Definition ink_us_mario_callback_direct_closure :=
  ink_direct_call_closure 20 ink_us_definitions ink_mario_callback_roots [].

Definition ink_jp_mario_callback_direct_closure :=
  ink_direct_call_closure 20 ink_jp_definitions ink_mario_callback_roots [].

Definition ink_call_closure_closedb
    (definitions : list (ident * globdef (fundef function) type))
    (closure : list ident) : bool :=
  forallb
    (fun caller => forallb
      (fun callee => ink_ident_in callee closure)
      (ink_internal_direct_callees caller definitions))
    closure.

Definition ink_writer_intersection
    (closure writers : list ident) : list ident :=
  filter (fun writer => ink_ident_in writer closure) writers.

(** A second recognizer deliberately ignores the union-member name.  This
    catches literal slot writes through [asS32], [asF32], pointer views, or
    any other generated member of [rawData], rather than assuming that C used
    the canonical macro view. *)
Definition expression_is_rawdata_any_view_slot
    (raw_data : ident) (index : Z) (expression : expr) : bool :=
  match expression with
  | Ederef
      (Ebinop Cop.Oadd
        (Efield (Efield _ found_raw_data _) _ _)
        offset _) _ =>
      Pos.eqb found_raw_data raw_data &&
      match expression_const_int_z offset with
      | Some found_index => Z.eqb found_index index
      | None => false
      end
  | _ => false
  end.

Fixpoint expression_mentions_rawdata_any_view_slot
    (raw_data : ident) (index : Z) (expression : expr) : bool :=
  expression_is_rawdata_any_view_slot raw_data index expression ||
  match expression with
  | Ederef inner _ | Eaddrof inner _ | Eunop _ inner _ | Ecast inner _ =>
      expression_mentions_rawdata_any_view_slot raw_data index inner
  | Efield inner _ _ =>
      expression_mentions_rawdata_any_view_slot raw_data index inner
  | Ebinop _ lhs_expression rhs_expression _ =>
      expression_mentions_rawdata_any_view_slot raw_data index lhs_expression ||
      expression_mentions_rawdata_any_view_slot raw_data index rhs_expression
  | _ => false
  end.

Fixpoint assigns_rawdata_any_view_slot_s
    (raw_data : ident) (index : Z) (body : statement) : bool :=
  match body with
  | Sassign lhs _ =>
      expression_mentions_rawdata_any_view_slot raw_data index lhs
  | Ssequence first second | Sloop first second =>
      assigns_rawdata_any_view_slot_s raw_data index first ||
      assigns_rawdata_any_view_slot_s raw_data index second
  | Sifthenelse _ yes no =>
      assigns_rawdata_any_view_slot_s raw_data index yes ||
      assigns_rawdata_any_view_slot_s raw_data index no
  | Sswitch _ cases =>
      assigns_rawdata_any_view_slot_ls raw_data index cases
  | Slabel _ nested => assigns_rawdata_any_view_slot_s raw_data index nested
  | _ => false
  end
with assigns_rawdata_any_view_slot_ls
    (raw_data : ident) (index : Z) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      assigns_rawdata_any_view_slot_s raw_data index body ||
      assigns_rawdata_any_view_slot_ls raw_data index rest
  end.

Fixpoint internal_rawdata_any_view_slot_assignment_sites
    (raw_data : ident) (index : Z)
    (definitions : list (ident * globdef (fundef function) type)) : list ident :=
  match definitions with
  | [] => []
  | (id, Gfun (Internal body)) :: rest =>
      if assigns_rawdata_any_view_slot_s raw_data index (fn_body body)
      then id :: internal_rawdata_any_view_slot_assignment_sites
        raw_data index rest
      else internal_rawdata_any_view_slot_assignment_sites raw_data index rest
  | _ :: rest =>
      internal_rawdata_any_view_slot_assignment_sites raw_data index rest
  end.

Definition ink_us_any_view_flag_storage_writers :=
  internal_rawdata_any_view_slot_assignment_sites
    JGC_Mario._rawData 1 ink_us_definitions.

Definition ink_jp_any_view_flag_storage_writers :=
  internal_rawdata_any_view_slot_assignment_sites
    JGC_Mario._rawData 1 ink_jp_definitions.

Definition ink_us_any_view_offset_storage_writers :=
  internal_rawdata_any_view_slot_assignment_sites
    JGC_Mario._rawData 21 ink_us_definitions.

Definition ink_jp_any_view_offset_storage_writers :=
  internal_rawdata_any_view_slot_assignment_sites
    JGC_Mario._rawData 21 ink_jp_definitions.

(** This is the important reachability reduction.  It follows every direct
    [Evar]-callee recursively, including helper functions, until the finite
    generated graph is closed.  It does not follow indirect calls or external
    effects, and it does not treat a spawned child's future callback as a call
    on Mario. *)
Definition ink_mario_callback_direct_closure_claim : Prop :=
  ink_ident_list_eqb ink_us_mario_callback_direct_closure
    (ink_direct_call_closure 21 ink_us_definitions
      ink_mario_callback_roots []) = true /\
  ink_ident_list_eqb ink_jp_mario_callback_direct_closure
    (ink_direct_call_closure 21 ink_jp_definitions
      ink_mario_callback_roots []) = true /\
  ink_call_closure_closedb ink_us_definitions
    ink_us_mario_callback_direct_closure = true /\
  ink_call_closure_closedb ink_jp_definitions
    ink_jp_mario_callback_direct_closure = true /\
  ink_writer_intersection ink_us_mario_callback_direct_closure
    ink_us_flag_writers = [] /\
  ink_writer_intersection ink_jp_mario_callback_direct_closure
    ink_jp_flag_writers = [] /\
  ink_writer_intersection ink_us_mario_callback_direct_closure
    ink_us_offset_writers = [] /\
  ink_writer_intersection ink_jp_mario_callback_direct_closure
    ink_jp_offset_writers = [] /\
  ink_writer_intersection ink_us_mario_callback_direct_closure
    ink_us_any_view_flag_storage_writers = [] /\
  ink_writer_intersection ink_jp_mario_callback_direct_closure
    ink_jp_any_view_flag_storage_writers = [] /\
  ink_writer_intersection ink_us_mario_callback_direct_closure
    ink_us_any_view_offset_storage_writers = [] /\
  ink_writer_intersection ink_jp_mario_callback_direct_closure
    ink_jp_any_view_offset_storage_writers = [].

Theorem ink_mario_callback_direct_closure_has_no_tail_writer :
  ink_mario_callback_direct_closure_claim.
Proof.
  unfold ink_mario_callback_direct_closure_claim,
    ink_us_mario_callback_direct_closure,
    ink_jp_mario_callback_direct_closure,
    ink_us_flag_writers, ink_jp_flag_writers,
    ink_us_offset_writers, ink_jp_offset_writers,
    ink_us_any_view_flag_storage_writers,
    ink_jp_any_view_flag_storage_writers,
    ink_us_any_view_offset_storage_writers,
    ink_jp_any_view_offset_storage_writers,
    ink_us_definitions, ink_jp_definitions,
    ink_mario_callback_roots, generated_definitions_of.
  vm_compute. repeat split; reflexivity.
Qed.

Fixpoint ink_assigns_global_from_temp_s
    (target source : ident) (body : statement) : bool :=
  match body with
  | Sassign (Evar found_target _) (Etempvar found_source _) =>
      Pos.eqb found_target target && Pos.eqb found_source source
  | Ssequence first second | Sloop first second =>
      ink_assigns_global_from_temp_s target source first ||
      ink_assigns_global_from_temp_s target source second
  | Sifthenelse _ yes no =>
      ink_assigns_global_from_temp_s target source yes ||
      ink_assigns_global_from_temp_s target source no
  | Sswitch _ cases => ink_assigns_global_from_temp_ls target source cases
  | Slabel _ nested => ink_assigns_global_from_temp_s target source nested
  | _ => false
  end
with ink_assigns_global_from_temp_ls
    (target source : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      ink_assigns_global_from_temp_s target source body ||
      ink_assigns_global_from_temp_ls target source rest
  end.

(** Couple the allocation result to the temporary later installed in a
    global.  The generated source first calls [callee] into [result], copies
    [result] into [object_temp], and later in the same syntactic continuation
    assigns [object_temp] to [global].  This is still a source dataflow
    receipt, not a proof that the enclosing guards execute. *)
Definition ink_is_call_result_to_temp_pair
    (callee object_temp : ident) (first second : statement) : bool :=
  match first, second with
  | Scall (Some result) (Evar found_callee _) _,
    Sset found_object_temp (Etempvar found_result _) =>
      Pos.eqb found_callee callee &&
      Pos.eqb found_object_temp object_temp &&
      Pos.eqb found_result result
  | _, _ => false
  end.

Fixpoint ink_contains_call_result_to_global_s
    (callee object_temp global : ident) (body : statement) : bool :=
  match body with
  | Ssequence first rest =>
      (match first with
       | Ssequence call_statement set_statement =>
           ink_is_call_result_to_temp_pair callee object_temp
             call_statement set_statement &&
           ink_assigns_global_from_temp_s global object_temp rest
       | _ => false
       end) ||
      ink_contains_call_result_to_global_s callee object_temp global first ||
      ink_contains_call_result_to_global_s callee object_temp global rest
  | Sloop first rest | Sifthenelse _ first rest =>
      ink_contains_call_result_to_global_s callee object_temp global first ||
      ink_contains_call_result_to_global_s callee object_temp global rest
  | Sswitch _ cases =>
      ink_contains_call_result_to_global_ls callee object_temp global cases
  | Slabel _ nested =>
      ink_contains_call_result_to_global_s callee object_temp global nested
  | _ => false
  end
with ink_contains_call_result_to_global_ls
    (callee object_temp global : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      ink_contains_call_result_to_global_s callee object_temp global body ||
      ink_contains_call_result_to_global_ls callee object_temp global rest
  end.

Fixpoint ink_count_temp_sets_s
    (target : ident) (body : statement) : nat :=
  match body with
  | Sset found _ => if Pos.eqb found target then 1%nat else 0%nat
  | Ssequence first rest | Sloop first rest =>
      (ink_count_temp_sets_s target first +
       ink_count_temp_sets_s target rest)%nat
  | Sifthenelse _ yes no =>
      (ink_count_temp_sets_s target yes +
       ink_count_temp_sets_s target no)%nat
  | Sswitch _ cases => ink_count_temp_sets_ls target cases
  | Slabel _ nested => ink_count_temp_sets_s target nested
  | _ => 0%nat
  end
with ink_count_temp_sets_ls
    (target : ident) (cases : labeled_statements) : nat :=
  match cases with
  | LSnil => 0%nat
  | LScons _ body rest =>
      (ink_count_temp_sets_s target body +
       ink_count_temp_sets_ls target rest)%nat
  end.

(** The source-level identity chain is finite: [spawn_objects_from_info]
    installs the same [_object] temp that receives [create_object]'s result,
    while [clear_objects] is the only other direct global writer.  Mario's
    behavior selects object list zero, list zero occurs in the normal update
    order, both traversal variants assign the visited node to
    [gCurrentObject] before [cur_obj_update], and the tail reads that global.
    Linked list membership, branch execution, and preservation of the pointer
    value are still semantic obligations. *)
Definition ink_mario_current_object_source_identity_claim : Prop :=
  internal_function_assignment_sites
    ITMTC_USO._gMarioObject ink_us_definitions =
      [ITMTC_USO._spawn_objects_from_info; ITMTC_USO._clear_objects] /\
  internal_function_assignment_sites
    ITMTC_JPO._gMarioObject ink_jp_definitions =
      [ITMTC_JPO._spawn_objects_from_info; ITMTC_JPO._clear_objects] /\
  internal_function_address_sites
    ITMTC_USO._gMarioObject ink_us_definitions = [] /\
  internal_function_address_sites
    ITMTC_JPO._gMarioObject ink_jp_definitions = [] /\
  calls_ident_s ITMTC_USO._create_object
    (fn_body ITMTC_USO.f_spawn_objects_from_info) = true /\
  calls_ident_s ITMTC_JPO._create_object
    (fn_body ITMTC_JPO.f_spawn_objects_from_info) = true /\
  ink_assigns_global_from_temp_s
    ITMTC_USO._gMarioObject ITMTC_USO._object
    (fn_body ITMTC_USO.f_spawn_objects_from_info) = true /\
  ink_assigns_global_from_temp_s
    ITMTC_JPO._gMarioObject ITMTC_JPO._object
    (fn_body ITMTC_JPO.f_spawn_objects_from_info) = true /\
  ink_contains_call_result_to_global_s
    ITMTC_USO._create_object ITMTC_USO._object ITMTC_USO._gMarioObject
    (fn_body ITMTC_USO.f_spawn_objects_from_info) = true /\
  ink_contains_call_result_to_global_s
    ITMTC_JPO._create_object ITMTC_JPO._object ITMTC_JPO._gMarioObject
    (fn_body ITMTC_JPO.f_spawn_objects_from_info) = true /\
  ink_count_temp_sets_s ITMTC_USO._object
    (fn_body ITMTC_USO.f_spawn_objects_from_info) = 1%nat /\
  ink_count_temp_sets_s ITMTC_JPO._object
    (fn_body ITMTC_JPO.f_spawn_objects_from_info) = 1%nat /\
  hd_error (gvar_init ITMTC_USD.v_bhvMario) =
    Some (Init_int32 (Int.repr 0)) /\
  hd_error (gvar_init ITMTC_JPD.v_bhvMario) =
    Some (Init_int32 (Int.repr 0)) /\
  gvar_init ITMTC_USO.v_sObjectListUpdateOrder =
    [Init_int8 (Int.repr 11); Init_int8 (Int.repr 9);
     Init_int8 (Int.repr 10); Init_int8 (Int.repr 0);
     Init_int8 (Int.repr 5); Init_int8 (Int.repr 4);
     Init_int8 (Int.repr 2); Init_int8 (Int.repr 6);
     Init_int8 (Int.repr 8); Init_int8 (Int.repr 12);
     Init_int8 (Int.repr (-1))] /\
  gvar_init ITMTC_JPO.v_sObjectListUpdateOrder =
    [Init_int8 (Int.repr 11); Init_int8 (Int.repr 9);
     Init_int8 (Int.repr 10); Init_int8 (Int.repr 0);
     Init_int8 (Int.repr 5); Init_int8 (Int.repr 4);
     Init_int8 (Int.repr 2); Init_int8 (Int.repr 6);
     Init_int8 (Int.repr 8); Init_int8 (Int.repr 12);
     Init_int8 (Int.repr (-1))] /\
  contains_global_from_temp_before_call_s
    ITMTC_USO._gCurrentObject ITMTC_USO._firstObj ITMTC_USB._cur_obj_update
    (fn_body ITMTC_USO.f_update_objects_starting_at) = true /\
  contains_global_from_temp_before_call_s
    ITMTC_JPO._gCurrentObject ITMTC_JPO._firstObj ITMTC_JPB._cur_obj_update
    (fn_body ITMTC_JPO.f_update_objects_starting_at) = true /\
  contains_global_from_temp_before_call_s
    ITMTC_USO._gCurrentObject ITMTC_USO._firstObj ITMTC_USB._cur_obj_update
    (fn_body ITMTC_USO.f_update_objects_during_time_stop) = true /\
  contains_global_from_temp_before_call_s
    ITMTC_JPO._gCurrentObject ITMTC_JPO._firstObj ITMTC_JPB._cur_obj_update
    (fn_body ITMTC_JPO.f_update_objects_during_time_stop) = true /\
  contains_global_to_unary_call_s
    ITMTC_USO._gCurrentObject ITMTC_USB._obj_update_gfx_pos_and_angle
    (fn_body ITMTC_USB.f_cur_obj_update) = true /\
  contains_global_to_unary_call_s
    ITMTC_JPO._gCurrentObject ITMTC_JPB._obj_update_gfx_pos_and_angle
    (fn_body ITMTC_JPB.f_cur_obj_update) = true /\
  contains_temp_bit_guarded_call_s
    ITMTC_USB._objFlags 0 ITMTC_USB._obj_update_gfx_pos_and_angle
    (fn_body ITMTC_USB.f_cur_obj_update) = true /\
  contains_temp_bit_guarded_call_s
    ITMTC_JPB._objFlags 0 ITMTC_JPB._obj_update_gfx_pos_and_angle
    (fn_body ITMTC_JPB.f_cur_obj_update) = true.

Theorem ink_mario_current_object_source_identity_checked :
  ink_mario_current_object_source_identity_claim.
Proof.
  unfold ink_mario_current_object_source_identity_claim,
    ink_us_definitions, ink_jp_definitions, generated_definitions_of.
  vm_compute. repeat split; reflexivity.
Qed.

(** Recognize the central dynamic store in [bhv_cmd_or_int]: the same dynamic
    raw-data index is read and written, and the old word is OR-ed with the
    decoded value. *)
Definition is_dynamic_raw_s32_or_pair
    (raw_data as_s32 index_temp value_temp : ident)
    (first second : statement) : bool :=
  match first, second with
  | Sset old_temp
      (Ederef
        (Ebinop Cop.Oadd
          (Efield
            (Efield (Ederef (Etempvar _ _) _) found_raw_data _)
            found_as_s32 _)
          (Etempvar read_index _) _) _),
    Sassign
      (Ederef
        (Ebinop Cop.Oadd
          (Efield
            (Efield (Ederef (Etempvar _ _) _) found_raw_data' _)
            found_as_s32' _)
          (Etempvar write_index _) _) _)
      (Ebinop Cop.Oor (Etempvar found_old_temp _)
        (Ecast (Etempvar found_value_temp _) _) _) =>
      Pos.eqb found_raw_data raw_data &&
      Pos.eqb found_raw_data' raw_data &&
      Pos.eqb found_as_s32 as_s32 &&
      Pos.eqb found_as_s32' as_s32 &&
      Pos.eqb read_index index_temp &&
      Pos.eqb write_index index_temp &&
      Pos.eqb found_old_temp old_temp &&
      Pos.eqb found_value_temp value_temp
  | _, _ => false
  end.

Fixpoint contains_dynamic_raw_s32_or_s
    (raw_data as_s32 index_temp value_temp : ident)
    (body : statement) : bool :=
  match body with
  | Ssequence first second =>
      is_dynamic_raw_s32_or_pair raw_data as_s32 index_temp value_temp
        first second ||
      contains_dynamic_raw_s32_or_s raw_data as_s32 index_temp value_temp
        first ||
      contains_dynamic_raw_s32_or_s raw_data as_s32 index_temp value_temp
        second
  | Sloop first second | Sifthenelse _ first second =>
      contains_dynamic_raw_s32_or_s raw_data as_s32 index_temp value_temp
        first ||
      contains_dynamic_raw_s32_or_s raw_data as_s32 index_temp value_temp
        second
  | Sswitch _ cases =>
      contains_dynamic_raw_s32_or_ls raw_data as_s32 index_temp value_temp
        cases
  | Slabel _ nested =>
      contains_dynamic_raw_s32_or_s raw_data as_s32 index_temp value_temp
        nested
  | _ => false
  end
with contains_dynamic_raw_s32_or_ls
    (raw_data as_s32 index_temp value_temp : ident)
    (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      contains_dynamic_raw_s32_or_s raw_data as_s32 index_temp value_temp
        body ||
      contains_dynamic_raw_s32_or_ls raw_data as_s32 index_temp value_temp
        rest
  end.

Definition ink_mario_or_int_interpreter_source_claim : Prop :=
  nth_error (gvar_init ITMTC_USB.v_BehaviorCmdTable) 17 =
    Some (Init_addrof ITMTC_USB._bhv_cmd_or_int (Ptrofs.repr 0)) /\
  nth_error (gvar_init ITMTC_JPB.v_BehaviorCmdTable) 17 =
    Some (Init_addrof ITMTC_JPB._bhv_cmd_or_int (Ptrofs.repr 0)) /\
  contains_dynamic_raw_s32_or_s
    ITMTC_USB._rawData ITMTC_USB._asS32
    ITMTC_USB._objectOffset ITMTC_USB._value
    (fn_body ITMTC_USB.f_bhv_cmd_or_int) = true /\
  contains_dynamic_raw_s32_or_s
    ITMTC_JPB._rawData ITMTC_JPB._asS32
    ITMTC_JPB._objectOffset ITMTC_JPB._value
    (fn_body ITMTC_JPB.f_bhv_cmd_or_int) = true /\
  statement_mentions_ident_s ITMTC_USB._gCurrentObject
    (fn_body ITMTC_USB.f_bhv_cmd_or_int) = true /\
  statement_mentions_ident_s ITMTC_JPB._gCurrentObject
    (fn_body ITMTC_JPB.f_bhv_cmd_or_int) = true /\
  statement_mentions_int_s 65535
    (fn_body ITMTC_USB.f_bhv_cmd_or_int) = true /\
  statement_mentions_int_s 65535
    (fn_body ITMTC_JPB.f_bhv_cmd_or_int) = true /\
  bhv_mario_flag_and_callbacks_source_shape_us_claim /\
  bhv_mario_flag_and_callbacks_source_shape_jp_claim.

Theorem ink_mario_or_int_interpreter_source_checked :
  ink_mario_or_int_interpreter_source_claim.
Proof.
  unfold ink_mario_or_int_interpreter_source_claim,
    bhv_mario_flag_and_callbacks_source_shape_us_claim,
    bhv_mario_flag_and_callbacks_source_shape_jp_claim,
    bhv_mario_initializer_prefix_us, bhv_mario_initializer_prefix_jp.
  vm_compute. repeat split; reflexivity.
Qed.

(** The stock command changes bit 8 only.  This theorem is independent of
    machine-word signedness because it is stated over Coq's bitwise integer
    operation and the selected bit. *)
Theorem or_256_preserves_flag_bit_zero :
  forall flags,
    Z.testbit (Z.lor flags 256) 0 = Z.testbit flags 0.
Proof.
  intro flags.
  rewrite Z.lor_spec.
  rewrite (proj2 (proj2 bhv_mario_o_flags_command_arithmetic)).
  apply Bool.orb_false_r.
Qed.

Corollary stock_mario_flag_command_cannot_enable_tail :
  forall flags,
    Z.testbit flags 0 = false ->
    Z.testbit (Z.lor flags 256) 0 = false.
Proof.
  intros flags Hclear.
  now rewrite or_256_preserves_flag_bit_zero.
Qed.

(** Even granting execution of the generic writer, a zero offset cannot put
    the Graphics retry on the timer-131 top. *)
Theorem zero_graph_offset_cannot_install_timer131_top_retry :
  forall object_position graphics_position floor_y,
    upper_warp_contact object_position ->
    -32768 <= position_y graphics_position < 32768 ->
    timer131_top_floor_min_y <= floor_y ->
    floor_query_can_return graphics_position floor_y ->
    position_y graphics_position = position_y object_position ->
    False.
Proof.
  intros object_position graphics_position floor_y
    Hwarp Hrange Hfloor Hquery Hsame.
  pose proof (timer131_warp_retry_requires_at_least_632_graphics_y_gap
    object_position graphics_position floor_y
    Hwarp Hrange Hfloor Hquery) as Hrequired.
  lia.
Qed.

Definition InkTimer131MarioTailCheckedBoundary : Prop :=
  ink_tail_writer_inventory_bilateral_claim /\
  ink_mario_callback_direct_closure_claim /\
  ink_mario_current_object_source_identity_claim /\
  ink_mario_or_int_interpreter_source_claim /\
  (forall flags,
    Z.testbit (Z.lor flags 256) 0 = Z.testbit flags 0) /\
  mario_tail_flag_offset_source_claim.

Theorem ink_timer131_mario_tail_checked_boundary_holds :
  InkTimer131MarioTailCheckedBoundary.
Proof.
  unfold InkTimer131MarioTailCheckedBoundary.
  split; [exact ink_tail_writer_inventory_exact_bilateral |].
  split; [exact ink_mario_callback_direct_closure_has_no_tail_writer |].
  split; [exact ink_mario_current_object_source_identity_checked |].
  split; [exact ink_mario_or_int_interpreter_source_checked |].
  split; [exact or_256_preserves_flag_bit_zero |].
  exact mario_tail_flag_offset_source_checked.
Qed.

(** What a final live disproof still has to refine.  The source boundary above
    makes these alternatives explicit instead of treating all callback code
    as an opaque writer escape. *)
Record InkTimer131MarioTailRetailResidual : Type := {
  ink_tail_live_current_equals_mario : Prop;
  ink_tail_allocation_zero_reaches_the_live_mario_slot : Prop;
  ink_tail_script_table_dispatch_is_faithful : Prop;
  ink_tail_direct_call_graph_refines_executed_internal_calls : Prop;
  ink_tail_no_indirect_or_external_field_writer : Prop;
  ink_tail_no_alias_oob_or_alternate_union_write : Prop;
  ink_tail_no_slot_reuse_or_behavior_pointer_forgery : Prop;
  ink_tail_spawned_children_do_not_write_the_mario_receiver : Prop
}.
