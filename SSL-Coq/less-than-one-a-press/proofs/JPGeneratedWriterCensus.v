(** Exact generated-AST census for the JP translation set.

    This file closes a scope ambiguity in the earlier quicksand audit.  The
    per-file theorems in [JPQuicksandDepth] covered the Mario/action units;
    here the same recognizers run over every one of the 38 JP units emitted by
    [pipeline/generate-clight.sh], including [rendering_graph_node.c].

    The concatenation below is an inventory surface, not a linked Clight
    program.  In particular, these theorems do not prove pointer non-aliasing,
    reachability, external-call frame conditions, or that no omitted source
    body can write through an unrelated pointer. *)

From Coq Require Import Lia List ZArith.
From compcert Require Import AST Clight Ctypes Integers.
From LessThanOneAPress.Generated Require Import
  jp_game_init jp_mario jp_mario_actions_airborne
  jp_mario_actions_automatic jp_mario_actions_cutscene
  jp_mario_actions_moving jp_mario_actions_object
  jp_mario_actions_stationary jp_mario_actions_submerged jp_mario_step
  jp_interaction jp_save_file jp_object_collision jp_object_list_processor
  jp_behavior_script jp_level_script jp_graph_node jp_rendering_graph_node
  jp_spawn_object jp_object_helpers jp_debug jp_memory jp_mario_misc
  jp_obj_behaviors jp_obj_behaviors_2 jp_behavior_actions jp_behavior_data
  jp_area jp_level_update jp_platform_displacement jp_math_util
  jp_surface_collision jp_surface_load jp_macro_special_objects
  jp_ssl_script jp_ssl_area1_macro jp_ssl_area2_macro jp_ssl_collision.
From LessThanOneAPress.Proofs Require Import ASTFacts JPQuicksandDepth.

Import ListNotations.
Local Open Scope Z_scope.

Module JGC_Mario := jp_mario.
Module JGC_Air := jp_mario_actions_airborne.
Module JGC_Auto := jp_mario_actions_automatic.
Module JGC_Cut := jp_mario_actions_cutscene.
Module JGC_Move := jp_mario_actions_moving.
Module JGC_Stationary := jp_mario_actions_stationary.
Module JGC_Submerged := jp_mario_actions_submerged.
Module JGC_Step := jp_mario_step.
Module JGC_Interaction := jp_interaction.
Module JGC_LevelScript := jp_level_script.
Module JGC_Graph := jp_graph_node.
Module JGC_Render := jp_rendering_graph_node.
Module JGC_Spawn := jp_spawn_object.
Module JGC_Objects := jp_object_list_processor.
Module JGC_Helpers := jp_object_helpers.
Module JGC_Debug := jp_debug.
Module JGC_Macro := jp_macro_special_objects.
Module JGC_BScript := jp_behavior_script.
Module JGC_BData := jp_behavior_data.
Module JGC_ObjBehaviors := jp_obj_behaviors.
Module JGC_BehaviorActions := jp_behavior_actions.
Module JGC_LevelUpdate := jp_level_update.
Module JGC_Platform := jp_platform_displacement.
Module JGC_SurfaceLoad := jp_surface_load.

(** Keep this order synchronized with [generate-clight.sh]. *)
Definition jp_generated_translation_units : list Clight.program :=
  [jp_game_init.prog;
   jp_mario.prog;
   jp_mario_actions_airborne.prog;
   jp_mario_actions_automatic.prog;
   jp_mario_actions_cutscene.prog;
   jp_mario_actions_moving.prog;
   jp_mario_actions_object.prog;
   jp_mario_actions_stationary.prog;
   jp_mario_actions_submerged.prog;
   jp_mario_step.prog;
   jp_interaction.prog;
   jp_save_file.prog;
   jp_object_collision.prog;
   jp_object_list_processor.prog;
   jp_behavior_script.prog;
   jp_level_script.prog;
   jp_graph_node.prog;
   jp_rendering_graph_node.prog;
   jp_spawn_object.prog;
   jp_object_helpers.prog;
   jp_debug.prog;
   jp_memory.prog;
   jp_mario_misc.prog;
   jp_obj_behaviors.prog;
   jp_obj_behaviors_2.prog;
   jp_behavior_actions.prog;
   jp_behavior_data.prog;
   jp_area.prog;
   jp_level_update.prog;
   jp_platform_displacement.prog;
   jp_math_util.prog;
   jp_surface_collision.prog;
   jp_surface_load.prog;
   jp_macro_special_objects.prog;
   jp_ssl_script.prog;
   jp_ssl_area1_macro.prog;
   jp_ssl_area2_macro.prog;
   jp_ssl_collision.prog].

Theorem jp_generated_translation_unit_count :
  length jp_generated_translation_units = 38%nat.
Proof. reflexivity. Qed.

Definition jp_generated_definitions :
    list (ident * globdef (fundef function) type) :=
  concat (map (fun unit => prog_defs unit) jp_generated_translation_units).

(** Enumerate internal bodies whose assignment left-hand side is the selected
    array-field slot.  The test is deliberately syntactic and
    receiver-neutral: for example, [_pos]/[1] can denote Mario State,
    GraphNodeObject, or another structure exposing a field with that atom. *)
Fixpoint internal_array_slot_assignment_sites
    (array_field : ident) (index : Z)
    (definitions : list (ident * globdef (fundef function) type)) :
    list ident :=
  match definitions with
  | [] => []
  | (id, Gfun (Internal body)) :: rest =>
      if assigns_array_slot_s array_field index (fn_body body)
      then id :: internal_array_slot_assignment_sites array_field index rest
      else internal_array_slot_assignment_sites array_field index rest
  | _ :: rest =>
      internal_array_slot_assignment_sites array_field index rest
  end.

(** Preserve translation-unit provenance instead of flattening identifiers
    whose atoms can occur in more than one separately generated program. *)
Definition jp_generated_array_slot_assignment_partition
    (array_field : ident) (index : Z) : list (list ident) :=
  map (fun unit =>
         internal_array_slot_assignment_sites
           array_field index (prog_defs unit))
      jp_generated_translation_units.

(** A stricter recognizer for the exact generated lvalue shape
    [receiver.outer_field.array_field[index]].  This distinguishes
    [rawData.asF32] from an unrelated field array also named [asF32]. *)
Definition expression_is_nested_array_slot
    (outer_field array_field : ident) (index : Z) (e : expr) : bool :=
  match e with
  | Ederef
      (Ebinop Oadd
        (Efield (Efield _ found_outer _) found_array _) offset _) _ =>
      Pos.eqb found_outer outer_field &&
      Pos.eqb found_array array_field &&
      match expression_const_int_z offset with
      | Some found_index => Z.eqb found_index index
      | None => false
      end
  | _ => false
  end.

(** Recover the receiver of the two exact Y expressions used by
    [obj_set_gfx_pos_from_pos]. *)
Definition raw_y_receiver_temp (e : expr) : option ident :=
  match e with
  | Ederef
      (Ebinop Oadd
        (Efield
          (Efield (Ederef (Etempvar receiver _) _) raw_data _) as_f32 _)
        offset _) _ =>
      if andb
         (andb (Pos.eqb raw_data JGC_Mario._rawData)
           (Pos.eqb as_f32 JGC_Mario._asF32))
         (match expression_const_int_z offset with
         | Some index => Z.eqb index 7
         | None => false
         end)
      then Some receiver else None
  | _ => None
  end.

Definition gfx_y_receiver_temp (e : expr) : option ident :=
  match e with
  | Ederef
      (Ebinop Oadd
        (Efield
          (Efield
            (Efield (Ederef (Etempvar receiver _) _) header _) gfx _) pos _)
        offset _) _ =>
      if andb
         (andb (andb (Pos.eqb header JGC_Mario._header)
           (Pos.eqb gfx JGC_Mario._gfx)) (Pos.eqb pos JGC_Mario._pos))
         (match expression_const_int_z offset with
         | Some index => Z.eqb index 1
         | None => false
         end)
      then Some receiver else None
  | _ => None
  end.

Definition is_same_receiver_raw_y_to_gfx_y_pair
    (first second : statement) : bool :=
  match first, second with
  | Sset loaded rhs, Sassign lhs (Etempvar stored _) =>
      match raw_y_receiver_temp rhs, gfx_y_receiver_temp lhs with
      | Some raw_receiver, Some gfx_receiver =>
          Pos.eqb loaded stored && Pos.eqb raw_receiver gfx_receiver
      | _, _ => false
      end
  | _, _ => false
  end.

Fixpoint contains_same_receiver_raw_y_to_gfx_y_s (s : statement) : bool :=
  match s with
  | Ssequence first second =>
      is_same_receiver_raw_y_to_gfx_y_pair first second ||
      contains_same_receiver_raw_y_to_gfx_y_s first ||
      contains_same_receiver_raw_y_to_gfx_y_s second
  | Sloop first second =>
      contains_same_receiver_raw_y_to_gfx_y_s first ||
      contains_same_receiver_raw_y_to_gfx_y_s second
  | Sifthenelse _ first second =>
      contains_same_receiver_raw_y_to_gfx_y_s first ||
      contains_same_receiver_raw_y_to_gfx_y_s second
  | Sswitch _ cases => contains_same_receiver_raw_y_to_gfx_y_ls cases
  | Slabel _ body => contains_same_receiver_raw_y_to_gfx_y_s body
  | _ => false
  end
with contains_same_receiver_raw_y_to_gfx_y_ls
    (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      contains_same_receiver_raw_y_to_gfx_y_s body ||
      contains_same_receiver_raw_y_to_gfx_y_ls rest
  end.

Definition is_global_to_unary_call_pair
    (global callee : ident) (first second : statement) : bool :=
  match first, second with
  | Sset loaded (Evar found_global _),
    Scall _ (Evar found_callee _) [Etempvar passed _] =>
      andb (Pos.eqb found_global global)
        (andb (Pos.eqb found_callee callee) (Pos.eqb loaded passed))
  | _, _ => false
  end.

Fixpoint contains_global_to_unary_call_s
    (global callee : ident) (s : statement) : bool :=
  match s with
  | Ssequence first second =>
      is_global_to_unary_call_pair global callee first second ||
      contains_global_to_unary_call_s global callee first ||
      contains_global_to_unary_call_s global callee second
  | Sloop first second | Sifthenelse _ first second =>
      contains_global_to_unary_call_s global callee first ||
      contains_global_to_unary_call_s global callee second
  | Sswitch _ cases => contains_global_to_unary_call_ls global callee cases
  | Slabel _ body => contains_global_to_unary_call_s global callee body
  | _ => false
  end
with contains_global_to_unary_call_ls
    (global callee : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      contains_global_to_unary_call_s global callee body ||
      contains_global_to_unary_call_ls global callee rest
  end.

Fixpoint assigns_nested_array_slot_s
    (outer_field array_field : ident) (index : Z) (s : statement) : bool :=
  match s with
  | Sassign lhs _ =>
      expression_is_nested_array_slot outer_field array_field index lhs
  | Ssequence a b | Sloop a b =>
      assigns_nested_array_slot_s outer_field array_field index a ||
      assigns_nested_array_slot_s outer_field array_field index b
  | Sifthenelse _ a b =>
      assigns_nested_array_slot_s outer_field array_field index a ||
      assigns_nested_array_slot_s outer_field array_field index b
  | Sswitch _ cases =>
      assigns_nested_array_slot_ls outer_field array_field index cases
  | Slabel _ body =>
      assigns_nested_array_slot_s outer_field array_field index body
  | _ => false
  end
with assigns_nested_array_slot_ls
    (outer_field array_field : ident) (index : Z)
    (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      assigns_nested_array_slot_s outer_field array_field index body ||
      assigns_nested_array_slot_ls outer_field array_field index rest
  end.

Fixpoint internal_nested_array_slot_assignment_sites
    (outer_field array_field : ident) (index : Z)
    (definitions : list (ident * globdef (fundef function) type)) :
    list ident :=
  match definitions with
  | [] => []
  | (id, Gfun (Internal body)) :: rest =>
      if assigns_nested_array_slot_s
           outer_field array_field index (fn_body body)
      then id :: internal_nested_array_slot_assignment_sites
                   outer_field array_field index rest
      else internal_nested_array_slot_assignment_sites
             outer_field array_field index rest
  | _ :: rest =>
      internal_nested_array_slot_assignment_sites
        outer_field array_field index rest
  end.

Definition jp_generated_nested_array_slot_assignment_partition
    (outer_field array_field : ident) (index : Z) : list (list ident) :=
  map (fun unit =>
         internal_nested_array_slot_assignment_sites
           outer_field array_field index (prog_defs unit))
      jp_generated_translation_units.

(** [assigns_through_field_s] recognizes both a direct assignment to a named
    field and a nested lvalue whose address computation mentions that field.
    This is therefore suitable for writes through [throwMatrix], but remains
    a receiver-neutral syntax census rather than an ownership fact. *)
Fixpoint internal_assignment_lhs_field_mention_sites
    (field : ident)
    (definitions : list (ident * globdef (fundef function) type)) :
    list ident :=
  match definitions with
  | [] => []
  | (id, Gfun (Internal body)) :: rest =>
      if assigns_through_field_s field (fn_body body)
      then id :: internal_assignment_lhs_field_mention_sites field rest
      else internal_assignment_lhs_field_mention_sites field rest
  | _ :: rest => internal_assignment_lhs_field_mention_sites field rest
  end.

Definition jp_generated_assignment_lhs_field_mention_partition
    (field : ident) : list (list ident) :=
  map (fun unit =>
         internal_assignment_lhs_field_mention_sites
           field (prog_defs unit))
      jp_generated_translation_units.

Definition assignment_partition_counts (partition : list (list ident)) :
    list nat :=
  map (@length ident) partition.

Definition assignment_partition_total (partition : list (list ident)) : nat :=
  fold_right Nat.add 0%nat (assignment_partition_counts partition).

(** [clightgen] preserves C's unary negation in [-1], so the generic direct
    integer-constant recognizer does not match this exact generated shape. *)
Definition rhs_is_negative_int_constant (magnitude : Z) (rhs : expr) : bool :=
  match rhs with
  | Eunop Oneg (Econst_int found _) _ =>
      Int.eq found (Int.repr magnitude)
  | _ => false
  end.

Fixpoint assigns_field_negative_int_constant_s
    (field : ident) (magnitude : Z) (s : statement) : bool :=
  match s with
  | Sassign lhs rhs =>
      lhs_field_is field lhs && rhs_is_negative_int_constant magnitude rhs
  | Ssequence a b | Sloop a b =>
      assigns_field_negative_int_constant_s field magnitude a ||
      assigns_field_negative_int_constant_s field magnitude b
  | Sifthenelse _ a b =>
      assigns_field_negative_int_constant_s field magnitude a ||
      assigns_field_negative_int_constant_s field magnitude b
  | Sswitch _ cases =>
      assigns_field_negative_int_constant_ls field magnitude cases
  | Slabel _ body =>
      assigns_field_negative_int_constant_s field magnitude body
  | _ => false
  end
with assigns_field_negative_int_constant_ls
    (field : ident) (magnitude : Z) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      assigns_field_negative_int_constant_s field magnitude body ||
      assigns_field_negative_int_constant_ls field magnitude rest
  end.

(** * Receiver-neutral coordinate-lvalue inventories *)

(** Exact 38-unit partition for assignments to a field-array slot named
    [pos[1]].  This includes Mario State and GraphNodeObject writes, but the
    theorem does not identify either receiver: that requires a typed pointer
    and alias-provenance argument over live memory. *)
Theorem jp_generated_pos_y_direct_assignment_partition :
  jp_generated_array_slot_assignment_partition JGC_Mario._pos 1 =
  [[];
   [JGC_Mario._update_mario_pos_for_anim;
    JGC_Mario._set_water_plunge_action;
    JGC_Mario._sink_mario_in_quicksand;
    JGC_Mario._init_mario];
   [JGC_Air._act_riding_shell_air;
    JGC_Air._act_ground_pound;
    JGC_Air._act_riding_hoot];
   [JGC_Auto._set_pole_position;
    JGC_Auto._update_hang_stationary;
    JGC_Auto._let_go_of_ledge;
    JGC_Auto._update_ledge_climb_camera;
    JGC_Auto._act_in_cannon;
    JGC_Auto._act_tornado_twirling];
   [JGC_Cut._end_peach_cutscene_run_to_peach;
    JGC_Cut._end_peach_cutscene_run_to_castle];
   [JGC_Move._align_with_floor;
    JGC_Move._tilt_body_ground_shell];
   [];
   [JGC_Stationary._act_shockwave_bounce];
   [JGC_Submerged._update_water_pitch;
    JGC_Submerged._surface_swim_bob;
    JGC_Submerged._act_caught_in_whirlpool;
    JGC_Submerged._check_common_submerged_cancels];
   [JGC_Step._stop_and_set_height_to_floor;
    JGC_Step._stationary_ground_step;
    JGC_Step._perform_air_quarter_step];
   [JGC_Interaction._bounce_off_object];
   []; []; [];
   [JGC_BScript._obj_update_gfx_pos_and_angle];
   [];
   [JGC_Graph._geo_obj_init_spawninfo];
   [];
   [JGC_Spawn._allocate_object];
   [JGC_Helpers._obj_set_gfx_pos_from_pos;
    JGC_Helpers._obj_set_gfx_pos_at_obj_pos];
   []; []; []; []; []; []; []; [];
   [JGC_LevelUpdate._check_instant_warp];
   [JGC_Platform._set_mario_pos];
   []; []; []; []; []; []; []; []].
Proof. vm_compute. reflexivity. Qed.

Theorem jp_generated_pos_y_direct_assignment_counts :
  assignment_partition_counts
    (jp_generated_array_slot_assignment_partition JGC_Mario._pos 1) =
  map Z.to_nat
    [0; 4; 3; 6; 2; 2; 0; 1; 4; 3; 1; 0; 0; 0; 1; 0; 1; 0; 1;
     2; 0; 0; 0; 0; 0; 0; 0; 0; 1; 1; 0; 0; 0; 0; 0; 0; 0; 0] /\
  assignment_partition_total
    (jp_generated_array_slot_assignment_partition JGC_Mario._pos 1) = 33%nat.
Proof. vm_compute. split; reflexivity. Qed.

(** Unlike the receiver-neutral [pos[1]] inventory above, this selector
    requires the generated lvalue suffix [gfx.pos[1]].  It therefore removes
    MarioState, raw-object, and unrelated position arrays from the direct
    stored-Graphics-Y census.  The receiver itself remains intentionally
    unclassified: proving which of these eleven bodies can receive the live
    Mario object is still a pointer/alias and call-path obligation. *)
Theorem jp_generated_gfx_pos_y_direct_assignment_partition :
  jp_generated_nested_array_slot_assignment_partition
    JGC_Mario._gfx JGC_Mario._pos 1 =
  [[];
   [JGC_Mario._sink_mario_in_quicksand;
    JGC_Mario._init_mario];
   [JGC_Air._act_riding_shell_air];
   [];
   [JGC_Cut._end_peach_cutscene_run_to_castle];
   [JGC_Move._tilt_body_ground_shell];
   []; [];
   [JGC_Submerged._update_water_pitch;
    JGC_Submerged._surface_swim_bob];
   []; []; []; []; [];
   [JGC_BScript._obj_update_gfx_pos_and_angle];
   []; []; [];
   [JGC_Spawn._allocate_object];
   [JGC_Helpers._obj_set_gfx_pos_from_pos;
    JGC_Helpers._obj_set_gfx_pos_at_obj_pos];
   []; []; []; []; []; []; []; []; []; []; []; []; []; []; []; []; []; []].
Proof. vm_compute. reflexivity. Qed.

Theorem jp_generated_gfx_pos_y_direct_assignment_counts :
  assignment_partition_counts
    (jp_generated_nested_array_slot_assignment_partition
       JGC_Mario._gfx JGC_Mario._pos 1) =
  map Z.to_nat
    [0; 2; 1; 0; 1; 1; 0; 0; 2; 0; 0; 0; 0; 0; 1; 0; 0; 0; 1;
     2; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0] /\
  assignment_partition_total
    (jp_generated_nested_array_slot_assignment_partition
       JGC_Mario._gfx JGC_Mario._pos 1) = 11%nat.
Proof. vm_compute. split; reflexivity. Qed.

(** Split the finite eleven-body inventory at the proof boundary that matters
    for Ink.  The first seven are Mario initialization/action paths and still
    include the unresolved negative-quicksand case.  The final four accept a
    generic Object receiver, so they retain the pointer-identity/call-path
    obligation.  This is a classification, not a reachability claim. *)
Definition jp_mario_path_gfx_y_direct_writers : list ident :=
  [JGC_Mario._sink_mario_in_quicksand;
   JGC_Mario._init_mario;
   JGC_Air._act_riding_shell_air;
   JGC_Cut._end_peach_cutscene_run_to_castle;
   JGC_Move._tilt_body_ground_shell;
   JGC_Submerged._update_water_pitch;
   JGC_Submerged._surface_swim_bob].

Definition jp_receiver_generic_gfx_y_direct_writers : list ident :=
  [JGC_BScript._obj_update_gfx_pos_and_angle;
   JGC_Spawn._allocate_object;
   JGC_Helpers._obj_set_gfx_pos_from_pos;
   JGC_Helpers._obj_set_gfx_pos_at_obj_pos].

Definition jp_generated_gfx_pos_y_direct_assignment_sites : list ident :=
  concat
    (jp_generated_nested_array_slot_assignment_partition
       JGC_Mario._gfx JGC_Mario._pos 1).

Theorem jp_generated_gfx_y_writer_residual_split_checked :
  jp_generated_gfx_pos_y_direct_assignment_sites =
    jp_mario_path_gfx_y_direct_writers ++
    jp_receiver_generic_gfx_y_direct_writers /\
  length jp_mario_path_gfx_y_direct_writers = 7%nat /\
  length jp_receiver_generic_gfx_y_direct_writers = 4%nat.
Proof. vm_compute. repeat split; reflexivity. Qed.

Theorem every_direct_gfx_y_writer_is_mario_path_or_receiver_generic :
  forall writer,
    In writer jp_generated_gfx_pos_y_direct_assignment_sites ->
    In writer jp_mario_path_gfx_y_direct_writers \/
    In writer jp_receiver_generic_gfx_y_direct_writers.
Proof.
  intros writer Hwriter.
  rewrite (proj1 jp_generated_gfx_y_writer_residual_split_checked) in Hwriter.
  now apply in_app_or in Hwriter.
Qed.

(** The four receiver-generic bodies are not one undifferentiated escape.
    Their source roles are respectively: behavior-offset update, allocation
    sentinel initialization, same-object raw-to-Graphics reanchor, and
    two-object anchor copy.  Runtime receiver identity and reachability remain
    deliberately outside this syntactic partition. *)
Definition jp_behavior_offset_gfx_y_residual : list ident :=
  [JGC_BScript._obj_update_gfx_pos_and_angle].
Definition jp_allocator_gfx_y_residual : list ident :=
  [JGC_Spawn._allocate_object].
Definition jp_same_object_reanchor_gfx_y_residual : list ident :=
  [JGC_Helpers._obj_set_gfx_pos_from_pos].
Definition jp_cross_object_anchor_gfx_y_residual : list ident :=
  [JGC_Helpers._obj_set_gfx_pos_at_obj_pos].

Theorem jp_receiver_generic_gfx_y_four_role_split_checked :
  jp_receiver_generic_gfx_y_direct_writers =
    jp_behavior_offset_gfx_y_residual ++
    jp_allocator_gfx_y_residual ++
    jp_same_object_reanchor_gfx_y_residual ++
    jp_cross_object_anchor_gfx_y_residual /\
  length jp_behavior_offset_gfx_y_residual = 1%nat /\
  length jp_allocator_gfx_y_residual = 1%nat /\
  length jp_same_object_reanchor_gfx_y_residual = 1%nat /\
  length jp_cross_object_anchor_gfx_y_residual = 1%nat.
Proof. vm_compute. repeat split; reflexivity. Qed.

(** This closes one of the four bodies as a gap *producer*: its Y store reads
    raw Y from the identical formal receiver, so executing it on Mario
    reanchors Graphics Y rather than separating the two views.  Call
    reachability is irrelevant to that local effect. *)
Theorem jp_obj_set_gfx_pos_from_pos_same_receiver_y_checked :
  map fst (fn_params JGC_Helpers.f_obj_set_gfx_pos_from_pos) =
    [JGC_Helpers._obj] /\
  contains_same_receiver_raw_y_to_gfx_y_s
    (fn_body JGC_Helpers.f_obj_set_gfx_pos_from_pos) = true /\
  forall raw_y : Z, raw_y - raw_y = 0.
Proof.
  vm_compute.
  split; [reflexivity |].
  split; [reflexivity |].
  exact Z.sub_diag.
Qed.

(** Identity and static reachability boundary for the dangerous behavior-tail
    writer.  [cur_obj_update] loads [gCurrentObject] and passes that exact
    pointer as the sole argument, under object-flag bit zero.  [bhvMario]
    names the Mario callback in its script, so this is a real stock source
    candidate.  Interpreter execution and proof that the live current object
    is Mario remain outside this syntax theorem. *)
Theorem jp_obj_update_gfx_pos_and_angle_identity_reachability_checked :
  map fst (fn_params JGC_BScript.f_obj_update_gfx_pos_and_angle) =
    [JGC_BScript._obj] /\
  contains_global_to_unary_call_s
    JGC_BScript._gCurrentObject JGC_BScript._obj_update_gfx_pos_and_angle
    (fn_body JGC_BScript.f_cur_obj_update) = true /\
  contains_temp_bit_guarded_call_s
    JGC_BScript._objFlags 0 JGC_BScript._obj_update_gfx_pos_and_angle
    (fn_body JGC_BScript.f_cur_obj_update) = true /\
  initializer_addrof_subsequenceb [JGC_BData._bhv_mario_update]
    (gvar_init JGC_BData.v_bhvMario) = true.
Proof. vm_compute. repeat split; reflexivity. Qed.

(** None of the three callbacks named by the stock Mario behavior directly
    assigns either the raw-data word containing [oFlags] or the float slot
    containing [oGraphYOffset].  Thus the dangerous tail state cannot be
    manufactured by a direct store in Mario's own callbacks.  Indirect
    callees, aliases, external stores, interpreter commands, and slot lifetime
    remain outside this direct-lvalue result. *)
Theorem jp_mario_direct_callbacks_do_not_write_tail_flag_or_offset_checked :
  assigns_nested_array_slot_s JGC_Mario._rawData JGC_Mario._asU32 1
    (fn_body JGC_Objects.f_bhv_mario_update) = false /\
  assigns_nested_array_slot_s JGC_Mario._rawData JGC_Mario._asF32 21
    (fn_body JGC_Objects.f_bhv_mario_update) = false /\
  assigns_nested_array_slot_s JGC_Mario._rawData JGC_Mario._asU32 1
    (fn_body JGC_Debug.f_try_print_debug_mario_level_info) = false /\
  assigns_nested_array_slot_s JGC_Mario._rawData JGC_Mario._asF32 21
    (fn_body JGC_Debug.f_try_print_debug_mario_level_info) = false /\
  assigns_nested_array_slot_s JGC_Mario._rawData JGC_Mario._asU32 1
    (fn_body JGC_Debug.f_try_do_mario_debug_object_spawn) = false /\
  assigns_nested_array_slot_s JGC_Mario._rawData JGC_Mario._asF32 21
    (fn_body JGC_Debug.f_try_do_mario_debug_object_spawn) = false /\
  Z.land 256 1 = 0.
Proof. vm_compute. repeat split; reflexivity. Qed.

(** The raw-object inventories use the stricter nested selector, so the
    counted lvalue has the generated shape [receiver.rawData.asF32[index]],
    not merely some unrelated field array named [asF32].  Index 7 is
    [oPosY].  Index 10 is retained as an older generic raw-slot census; it is
    not [oGraphYOffset], whose actual raw-data index is 21 and is checked by
    [InkTimer131ProducerClosure]. *)
Theorem jp_generated_rawdata_asf32_7_direct_assignment_counts :
  assignment_partition_counts
    (jp_generated_nested_array_slot_assignment_partition
       JGC_Mario._rawData JGC_Mario._asF32 7) =
  map Z.to_nat
    [0; 1; 0; 0; 5; 0; 0; 0; 0; 0; 3; 0; 0; 2; 1; 0; 0; 0; 1;
     28; 0; 0; 3; 51; 35; 83; 0; 0; 1; 1; 0; 0; 0; 0; 0; 0; 0; 0] /\
  assignment_partition_total
    (jp_generated_nested_array_slot_assignment_partition
       JGC_Mario._rawData JGC_Mario._asF32 7) = 215%nat.
Proof. vm_compute. split; reflexivity. Qed.

Theorem jp_generated_rawdata_asf32_10_direct_assignment_counts :
  assignment_partition_counts
    (jp_generated_nested_array_slot_assignment_partition
       JGC_Mario._rawData JGC_Mario._asF32 10) =
  map Z.to_nat
    [0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 1; 0; 0; 0; 0; 0;
     13; 0; 0; 0; 45; 43; 78; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0] /\
  assignment_partition_total
    (jp_generated_nested_array_slot_assignment_partition
       JGC_Mario._rawData JGC_Mario._asF32 10) = 180%nat.
Proof. vm_compute. split; reflexivity. Qed.

(** Exact partition for assignment lvalues whose address computation mentions
    [throwMatrix].  It includes direct pointer-field initialization/clearing
    and nested matrix-cell stores.  It does not prove which matrix is Mario's
    or that a non-null pointer is valid and non-aliased. *)
Theorem jp_generated_throw_matrix_assignment_partition :
  jp_generated_assignment_lhs_field_mention_partition
    JGC_Mario._throwMatrix =
  [[]; []; []; []; [];
   [JGC_Move._align_with_floor];
   []; []; []; []; []; []; []; []; []; [];
   [JGC_Graph._init_graph_node_object;
    JGC_Graph._geo_obj_init;
    JGC_Graph._geo_obj_init_spawninfo];
   [JGC_Render._geo_process_object;
    JGC_Render._geo_process_node_and_siblings];
   [JGC_Spawn._unload_object;
    JGC_Spawn._allocate_object];
   [JGC_Helpers._obj_set_throw_matrix_from_transform;
    JGC_Helpers._obj_build_transform_relative_to_parent;
    JGC_Helpers._cur_obj_align_gfx_with_floor];
   []; []; [];
   [JGC_ObjBehaviors._obj_orient_graph];
   [];
   [JGC_BehaviorActions._bhv_kickable_board_loop;
    JGC_BehaviorActions._bhv_tilting_inverted_pyramid_loop];
   []; []; []; []; []; [];
   [JGC_SurfaceLoad._transform_object_vertices];
   []; []; []; []; []].
Proof. vm_compute. reflexivity. Qed.

Theorem jp_generated_throw_matrix_assignment_counts :
  assignment_partition_counts
    (jp_generated_assignment_lhs_field_mention_partition
       JGC_Mario._throwMatrix) =
  map Z.to_nat
    [0; 0; 0; 0; 0; 1; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 3; 2; 2;
     3; 0; 0; 0; 1; 0; 2; 0; 0; 0; 0; 0; 0; 1; 0; 0; 0; 0; 0] /\
  assignment_partition_total
    (jp_generated_assignment_lhs_field_mention_partition
       JGC_Mario._throwMatrix) = 15%nat.
Proof. vm_compute. split; reflexivity. Qed.

(** Across all 38 generated units, these are the only internal function
    bodies containing a direct assignment whose field identifier is
    [quicksandDepth].  The order is translation-unit order, then source order. *)
Theorem jp_generated_quicksand_depth_direct_writer_census :
  internal_field_assignment_sites
    JGC_Mario._quicksandDepth jp_generated_definitions =
  [JGC_Mario._init_mario;
   JGC_Air._check_common_airborne_cancels;
   JGC_Auto._mario_execute_automatic_action;
   JGC_Cut._act_quicksand_death;
   JGC_Move._common_landing_action;
   JGC_Move._quicksand_jump_land_action;
   JGC_Submerged._mario_execute_submerged_action;
   JGC_Step._mario_update_quicksand].
Proof. vm_compute. reflexivity. Qed.

Fixpoint internal_int_literal_sites
    (needle : Z)
    (definitions : list (ident * globdef (fundef function) type)) :
    list ident :=
  match definitions with
  | [] => []
  | (id, Gfun (Internal body)) :: rest =>
      if statement_mentions_int_s needle (fn_body body)
      then id :: internal_int_literal_sites needle rest
      else internal_int_literal_sites needle rest
  | _ :: rest => internal_int_literal_sites needle rest
  end.

(** Exact literal-call census for the ordinary long-jump constructor.  No
    generated internal body directly calls [set_mario_action] with
    [ACT_LONG_JUMP], and the one [set_jumping_action] call is
    [act_crouch_slide]. *)
Theorem jp_generated_long_jump_constructor_call_census :
  internal_two_literal_call_sites
    JGC_Move._set_jumping_action 50333832 0 jp_generated_definitions =
      [JGC_Move._act_crouch_slide] /\
  internal_two_literal_call_sites
    JGC_Move._set_mario_action 50333832 0 jp_generated_definitions = [].
Proof. vm_compute. split; reflexivity. Qed.

(** [ACT_LONG_JUMP_LAND] is passed to [common_air_action_step], rather than
    installed by a direct two-literal [set_mario_action] call. *)
Theorem jp_generated_long_jump_land_direct_set_action_census :
  internal_two_literal_call_sites
    JGC_Move._set_mario_action 1145 0 jp_generated_definitions = [].
Proof. vm_compute. reflexivity. Qed.

(** These literal-occurrence lists deliberately ignore switch labels.  They
    identify expressions in internal bodies that can compute with or pass the
    action constants.  They are useful review receipts, not an action-flow
    invariant. *)
Theorem jp_generated_long_jump_literal_expression_census :
  internal_int_literal_sites 50333832 jp_generated_definitions =
    [JGC_Air._update_air_with_turn;
     JGC_Air._update_air_without_turn;
     JGC_Move._act_crouch_slide;
     JGC_Step._apply_gravity].
Proof. vm_compute. reflexivity. Qed.

Theorem jp_generated_long_jump_land_literal_expression_census :
  internal_int_literal_sites 1145 jp_generated_definitions =
    [JGC_Air._act_long_jump].
Proof. vm_compute. reflexivity. Qed.

(** * Automatic-dialog constructor and reanchoring census *)

Definition is_call_with_second_int_literal_s
    (callee : ident) (second : Z) (s : statement) : bool :=
  match s with
  | Scall _ (Evar found_callee _)
      [Etempvar _ _; Econst_int found_second _; _] =>
      Pos.eqb found_callee callee &&
      Int.eq found_second (Int.repr second)
  | _ => false
  end.

Fixpoint calls_with_second_int_literal_s
    (callee : ident) (second : Z) (s : statement) : bool :=
  match s with
  | Scall _ _ _ => is_call_with_second_int_literal_s callee second s
  | Ssequence lhs rhs | Sloop lhs rhs =>
      calls_with_second_int_literal_s callee second lhs ||
      calls_with_second_int_literal_s callee second rhs
  | Sifthenelse _ yes_branch no_branch =>
      calls_with_second_int_literal_s callee second yes_branch ||
      calls_with_second_int_literal_s callee second no_branch
  | Sswitch _ cases =>
      calls_with_second_int_literal_ls callee second cases
  | Slabel _ body => calls_with_second_int_literal_s callee second body
  | _ => false
  end
with calls_with_second_int_literal_ls
    (callee : ident) (second : Z) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      calls_with_second_int_literal_s callee second body ||
      calls_with_second_int_literal_ls callee second rest
  end.

Fixpoint internal_second_literal_call_sites
    (callee : ident) (second : Z)
    (definitions : list (ident * globdef (fundef function) type)) :
    list ident :=
  match definitions with
  | [] => []
  | (id, Gfun (Internal body)) :: rest =>
      if calls_with_second_int_literal_s callee second (fn_body body)
      then id :: internal_second_literal_call_sites callee second rest
      else internal_second_literal_call_sites callee second rest
  | _ :: rest => internal_second_literal_call_sites callee second rest
  end.

(** Every generated direct call whose second argument is the exact
    [ACT_READING_AUTOMATIC_DIALOG] value.  The first two sites are interaction
    handlers for door objects.  The remaining four are cutscene handlers. *)
Theorem jp_generated_automatic_dialog_constructor_call_census :
  internal_second_literal_call_sites
    JGC_Mario._set_mario_action 536875781 jp_generated_definitions =
  [JGC_Cut._handle_save_menu;
   JGC_Cut._general_star_dance_handler;
   JGC_Cut._act_unlocking_star_door;
   JGC_Cut._act_warp_door_spawn;
   JGC_Interaction._interact_warp_door;
   JGC_Interaction._interact_door].
Proof. vm_compute. reflexivity. Qed.

Definition jp_cutscene_automatic_dialog_constructor_sites : list ident :=
  [JGC_Cut._handle_save_menu;
   JGC_Cut._general_star_dance_handler;
   JGC_Cut._act_unlocking_star_door;
   JGC_Cut._act_warp_door_spawn].

Definition jp_door_interaction_automatic_dialog_constructor_sites :
    list ident :=
  [JGC_Interaction._interact_warp_door;
   JGC_Interaction._interact_door].

(** The constructor census splits exactly into four cutscene-path sites whose
    enclosing same-frame path has a preceding/following Graphics reanchor,
    and two interaction handlers that first require a live door object. *)
Theorem jp_generated_automatic_dialog_constructor_classification :
  internal_second_literal_call_sites
    JGC_Mario._set_mario_action 536875781 jp_generated_definitions =
  jp_cutscene_automatic_dialog_constructor_sites ++
  jp_door_interaction_automatic_dialog_constructor_sites /\
  length jp_cutscene_automatic_dialog_constructor_sites = 4%nat /\
  length jp_door_interaction_automatic_dialog_constructor_sites = 2%nat.
Proof. vm_compute. repeat split; reflexivity. Qed.

(** The four cutscene-origin constructor families have a source-level
    synchronization call in their enclosing action path.  For the two
    star-exit helpers the synchronization precedes the helper and neither
    helper writes [m->pos[1]].  For land/water star dance it occurs in the
    caller; for door-unlock/spawn it follows the direct constructor call.

    These are generated-AST ordering receipts.  A linked control-flow proof
    must still show that the calls execute on the same path with one valid,
    non-aliased Mario pointer and that their external bodies satisfy the
    advertised frame condition. *)
Definition jp_automatic_dialog_reanchor_source_shape_claim : Prop :=
  assigns_array_slot_s JGC_Cut._pos 1
    (fn_body JGC_Cut.f_handle_save_menu) = false /\
  ident_subsequenceb
    [JGC_Cut._stationary_ground_step; JGC_Cut._handle_save_menu]
    (direct_callees_s (fn_body JGC_Cut.f_act_exit_land_save_dialog)) = true /\
  assigns_array_slot_s JGC_Cut._pos 1
    (fn_body JGC_Cut.f_general_star_dance_handler) = false /\
  ident_subsequenceb
    [JGC_Cut._general_star_dance_handler;
     JGC_Cut._stop_and_set_height_to_floor]
    (direct_callees_s (fn_body JGC_Cut.f_act_star_dance)) = true /\
  ident_subsequenceb
    [JGC_Cut._vec3f_copy; JGC_Cut._general_star_dance_handler]
    (direct_callees_s (fn_body JGC_Cut.f_act_star_dance_water)) = true /\
  ident_subsequenceb
    [JGC_Cut._set_mario_action;
     JGC_Cut._update_mario_pos_for_anim;
     JGC_Cut._stop_and_set_height_to_floor]
    (direct_callees_s (fn_body JGC_Cut.f_act_unlocking_star_door)) = true /\
  ident_subsequenceb
    [JGC_Cut._set_mario_action; JGC_Cut._stop_and_set_height_to_floor]
    (direct_callees_s (fn_body JGC_Cut.f_act_warp_door_spawn)) = true.

Theorem jp_automatic_dialog_reanchor_source_shape_checked :
  jp_automatic_dialog_reanchor_source_shape_claim.
Proof.
  unfold jp_automatic_dialog_reanchor_source_shape_claim.
  vm_compute. repeat split.
Qed.

(** * Mario-object identity and area-lifetime syntax *)

(** The only direct assignments to the [gMarioObject] global in the 38-unit
    JP inventory install the object selected by [spawn_objects_from_info] or
    clear the global during whole-object-system reset.  No generated internal
    function takes the address of the global cell explicitly. *)
Theorem jp_generated_mario_object_global_assignment_census :
  internal_function_assignment_sites
    JGC_Objects._gMarioObject jp_generated_definitions =
  [JGC_Objects._spawn_objects_from_info;
   JGC_Objects._clear_objects] /\
  internal_function_address_sites
    JGC_Objects._gMarioObject jp_generated_definitions = [].
Proof. vm_compute. split; reflexivity. Qed.

(** All direct assignments to a field named [activeAreaIndex] in the
    generated set.  The first initializes Mario's [SpawnInfo] to -1; the
    second initializes ordinary level-object [SpawnInfo] records to their
    current area; [geo_obj_init_spawninfo] copies a SpawnInfo value into an
    Object; the macro-object functions write their dedicated default parent;
    and [spawn_object_at_origin] writes a newly allocated child. *)
Theorem jp_generated_active_area_index_direct_writer_census :
  internal_field_assignment_sites
    JGC_LevelScript._activeAreaIndex jp_generated_definitions =
  [JGC_LevelScript._level_cmd_init_mario;
   JGC_LevelScript._level_cmd_place_object;
   JGC_Graph._geo_obj_init_spawninfo;
   JGC_Helpers._spawn_object_at_origin;
   JGC_Macro._spawn_macro_objects;
   JGC_Macro._spawn_macro_objects_hardcoded;
   JGC_Macro._spawn_special_objects].
Proof. vm_compute. reflexivity. Qed.

Definition jp_mario_area_lifetime_source_shape_claim : Prop :=
  assigns_field_negative_int_constant_s JGC_LevelScript._activeAreaIndex 1
    (fn_body JGC_LevelScript.f_level_cmd_init_mario) = true /\
  assigns_global_ident_s JGC_Objects._gMarioObject
    (fn_body JGC_Objects.f_spawn_objects_from_info) = true /\
  statement_mentions_ident_s JGC_Objects._behaviorArg
    (fn_body JGC_Objects.f_spawn_objects_from_info) = true /\
  statement_mentions_int_s 1
    (fn_body JGC_Objects.f_spawn_objects_from_info) = true /\
  assigns_field_named_s JGC_Graph._activeAreaIndex
    (fn_body JGC_Graph.f_geo_obj_init_spawninfo) = true /\
  statement_mentions_ident_s JGC_Objects._activeAreaIndex
    (fn_body JGC_Objects.f_unload_objects_from_area) = true /\
  calls_ident_s JGC_Objects._unload_object
    (fn_body JGC_Objects.f_unload_objects_from_area) = true.

Theorem jp_mario_area_lifetime_source_shape_checked :
  jp_mario_area_lifetime_source_shape_claim.
Proof.
  unfold jp_mario_area_lifetime_source_shape_claim.
  vm_compute. repeat split.
Qed.

Theorem jp_mario_minus_one_active_area_differs_from_ssl_areas :
  forall area_index,
    1 <= area_index <= 3 ->
    (-1 <> area_index).
Proof. intros area_index Hrange Heq. lia. Qed.

(** A future live-memory proof can use the preceding receipts to establish
    that ordinary Area-1/2/3 unloading cannot select Mario's object slot.
    The missing step is not arithmetic: it is preservation of Mario's
    [activeAreaIndex = -1] and [gMarioObject] identity through actual linked
    calls, including the proof that generic child-spawn writers target fresh
    objects rather than the Mario slot. *)
Definition JPMarioObjectLifetimeRefinementObligation
    (clean_reachable_mario_active_area : Z -> Prop)
    (clean_reachable_g_mario_object_retarget : Prop)
    (child_spawn_aliases_mario_slot : Prop) : Prop :=
  (forall active_area,
      clean_reachable_mario_active_area active_area -> active_area = -1) /\
  ~ clean_reachable_g_mario_object_retarget /\
  ~ child_spawn_aliases_mario_slot.

(** Thus an Area-1 automatic-dialog closure has two independent jobs rather
    than one opaque reachability claim:

    - exclude stock spawning/interaction with the two door constructor
      families; and
    - refine one of the four source-shaped cutscene synchronization paths to
      live Clight memory before allowing the non-reanchoring dialog loop.

    Nonnegative [quicksandDepth] remains necessary: the common sink runs after
    the reanchoring call and can create a small first-frame gap, and repeated
    negative-depth dialog frames can accumulate it. *)
Definition JPArea1AutomaticDialogClosureObligation
    (reachable_door_dialog_constructor : Prop)
    (cutscene_reanchor_refinement_failed : Prop)
    (negative_depth_at_unsynchronized_sink : Prop) : Prop :=
  ~ reachable_door_dialog_constructor /\
  ~ cutscene_reanchor_refinement_failed /\
  ~ negative_depth_at_unsynchronized_sink.

(** Narrow retail residuals after the syntactic classification.  The first
    conjunct is Area-1 door-spawn/object provenance.  The second covers the
    same-frame [sink_mario_in_quicksand] that still executes after a Graphics
    reanchor.  Nothing here assumes nonnegative depth: it must be established
    from clean zero-edge action/depth provenance. *)
Definition JPArea1AutomaticDialogResidualObligation
    {State : Type}
    (clean_zero_edge_area1 : State -> Prop)
    (has_live_dialog_door : State -> Prop)
    (reanchor_then_sink : State -> State -> Prop)
    (depth_before_sink : State -> Z) : Prop :=
  (forall state,
      clean_zero_edge_area1 state -> ~ has_live_dialog_door state) /\
  (forall before after,
      clean_zero_edge_area1 before ->
      reanchor_then_sink before after ->
      0 <= depth_before_sink before).

(** What remains after this census is semantic: prove the designated Mario
    pointer does not alias another field/store destination, prove external
    calls preserve the selected cells, and prove every clean no-edge action
    transition is represented by the generated internal bodies above. *)
Definition JPGeneratedWriterCensusSemanticClosureObligation
    (reachable_unclassified_depth_write : Prop)
    (reachable_forged_long_jump_action : Prop)
    (external_or_aliased_cell_write : Prop) : Prop :=
  ~ reachable_unclassified_depth_write /\
  ~ reachable_forged_long_jump_action /\
  ~ external_or_aliased_cell_write.
