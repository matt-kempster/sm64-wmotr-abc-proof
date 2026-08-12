(** Source-typed refinement of the JP coordinate-lvalue census.

    [JPGeneratedWriterCensus] deliberately classifies lvalues by field names
    only.  This file rechecks every one of those four lvalue shapes against
    the receiver type annotation carried by the generated Clight expression:

    - [pos[1]] receivers are [MarioState], [GraphNodeObject], or
      [PlayerCameraState];
    - [rawData.asF32[7]] and [[10]] receivers are [Object]; and
    - every [throwMatrix] field occurrence in an assignment lvalue has a
      [GraphNodeObject] receiver.

    The audit is split into 38 program-local receipts.  The final theorem
    combines those receipts structurally and reuses the exact receiver-neutral
    function counts; it never evaluates the concatenated whole AST.  These are
    source-type facts, not live pointer provenance, alias freedom, reachability,
    or a count of dynamic stores. *)

From Coq Require Import List ZArith.
From compcert Require Import AST Clight Ctypes.
From LessThanOneAPress.Proofs Require Import
  ASTFacts JPGeneratedWriterCensus.

Import ListNotations.
Local Open Scope Z_scope.

Definition expression_has_struct_tag (tag : ident) (expression : expr)
    : bool :=
  match typeof expression with
  | Tstruct found _ => Pos.eqb found tag
  | _ => false
  end.

Definition expression_has_one_of_struct_tags
    (tags : list ident) (expression : expr) : bool :=
  existsb (fun tag => expression_has_struct_tag tag expression) tags.

(** If [lhs] has exactly the receiver-neutral [field[index]] shape, check the
    type of the expression immediately below [Efield].  Nonmatching lvalues
    are outside this member of the partition and pass unchanged. *)
Definition array_slot_receiver_has_one_of_struct_tags
    (field : ident) (index : Z) (tags : list ident) (lhs : expr) : bool :=
  if expression_is_array_slot field index lhs then
    match lhs with
    | Ederef
        (Ebinop Oadd (Efield receiver _ _) _ _) _ =>
        expression_has_one_of_struct_tags tags receiver
    | _ => false
    end
  else true.

(** The corresponding typed check for
    [receiver.outer_field.array_field[index]]. *)
Definition nested_array_slot_receiver_has_struct_tag
    (outer_field array_field : ident) (index : Z)
    (tag : ident) (lhs : expr) : bool :=
  if expression_is_nested_array_slot outer_field array_field index lhs then
    match lhs with
    | Ederef
        (Ebinop Oadd
          (Efield (Efield receiver _ _) _ _) _ _) _ =>
        expression_has_struct_tag tag receiver
    | _ => false
    end
  else true.

(** Check the receiver annotation at every occurrence of [field] in one
    expression.  This recursive form covers both direct [throwMatrix]
    assignments and matrix-cell stores whose address expression contains the
    field selection. *)
Fixpoint field_occurrences_have_struct_receiver
    (field tag : ident) (expression : expr) : bool :=
  match expression with
  | Ederef inner _ | Eaddrof inner _ | Eunop _ inner _ | Ecast inner _ =>
      field_occurrences_have_struct_receiver field tag inner
  | Ebinop _ lhs rhs _ =>
      field_occurrences_have_struct_receiver field tag lhs &&
      field_occurrences_have_struct_receiver field tag rhs
  | Efield receiver found _ =>
      (if Pos.eqb found field
       then expression_has_struct_tag tag receiver
       else true) &&
      field_occurrences_have_struct_receiver field tag receiver
  | _ => true
  end.

Definition jp_coordinate_assignment_lvalue_receiver_typed
    (lhs : expr) : bool :=
  array_slot_receiver_has_one_of_struct_tags
    JGC_Mario._pos 1
    [JGC_Mario._MarioState; JGC_Mario._GraphNodeObject;
     JGC_Mario._PlayerCameraState] lhs &&
  nested_array_slot_receiver_has_struct_tag
    JGC_Mario._rawData JGC_Mario._asF32 7 JGC_Mario._Object lhs &&
  nested_array_slot_receiver_has_struct_tag
    JGC_Mario._rawData JGC_Mario._asF32 10 JGC_Mario._Object lhs &&
  field_occurrences_have_struct_receiver
    JGC_Mario._throwMatrix JGC_Mario._GraphNodeObject lhs.

Fixpoint jp_coordinate_statement_lvalue_receivers_typed
    (statement_value : statement) : bool :=
  match statement_value with
  | Sassign lhs _ => jp_coordinate_assignment_lvalue_receiver_typed lhs
  | Ssequence first second | Sloop first second =>
      jp_coordinate_statement_lvalue_receivers_typed first &&
      jp_coordinate_statement_lvalue_receivers_typed second
  | Sifthenelse _ yes no =>
      jp_coordinate_statement_lvalue_receivers_typed yes &&
      jp_coordinate_statement_lvalue_receivers_typed no
  | Sswitch _ cases =>
      jp_coordinate_labeled_lvalue_receivers_typed cases
  | Slabel _ body => jp_coordinate_statement_lvalue_receivers_typed body
  | _ => true
  end
with jp_coordinate_labeled_lvalue_receivers_typed
    (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => true
  | LScons _ body rest =>
      jp_coordinate_statement_lvalue_receivers_typed body &&
      jp_coordinate_labeled_lvalue_receivers_typed rest
  end.

Fixpoint jp_coordinate_definitions_lvalue_receivers_typed
    (definitions : list (ident * globdef (fundef function) type)) : bool :=
  match definitions with
  | [] => true
  | (_, Gfun (Internal body)) :: rest =>
      jp_coordinate_statement_lvalue_receivers_typed (fn_body body) &&
      jp_coordinate_definitions_lvalue_receivers_typed rest
  | _ :: rest => jp_coordinate_definitions_lvalue_receivers_typed rest
  end.

Definition jp_coordinate_program_lvalue_receivers_typed
    (program : Clight.program) : bool :=
  jp_coordinate_definitions_lvalue_receivers_typed (prog_defs program).

(** Program-local computation receipts.  Keeping each generated unit as a
    separate theorem bounds reduction to one source file at a time. *)
Theorem jp_game_init_coordinate_receiver_receipt :
  jp_coordinate_program_lvalue_receivers_typed jp_game_init.prog = true.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_mario_coordinate_receiver_receipt :
  jp_coordinate_program_lvalue_receivers_typed jp_mario.prog = true.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_mario_actions_airborne_coordinate_receiver_receipt :
  jp_coordinate_program_lvalue_receivers_typed
    jp_mario_actions_airborne.prog = true.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_mario_actions_automatic_coordinate_receiver_receipt :
  jp_coordinate_program_lvalue_receivers_typed
    jp_mario_actions_automatic.prog = true.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_mario_actions_cutscene_coordinate_receiver_receipt :
  jp_coordinate_program_lvalue_receivers_typed
    jp_mario_actions_cutscene.prog = true.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_mario_actions_moving_coordinate_receiver_receipt :
  jp_coordinate_program_lvalue_receivers_typed
    jp_mario_actions_moving.prog = true.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_mario_actions_object_coordinate_receiver_receipt :
  jp_coordinate_program_lvalue_receivers_typed
    jp_mario_actions_object.prog = true.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_mario_actions_stationary_coordinate_receiver_receipt :
  jp_coordinate_program_lvalue_receivers_typed
    jp_mario_actions_stationary.prog = true.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_mario_actions_submerged_coordinate_receiver_receipt :
  jp_coordinate_program_lvalue_receivers_typed
    jp_mario_actions_submerged.prog = true.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_mario_step_coordinate_receiver_receipt :
  jp_coordinate_program_lvalue_receivers_typed jp_mario_step.prog = true.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_interaction_coordinate_receiver_receipt :
  jp_coordinate_program_lvalue_receivers_typed jp_interaction.prog = true.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_save_file_coordinate_receiver_receipt :
  jp_coordinate_program_lvalue_receivers_typed jp_save_file.prog = true.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_object_collision_coordinate_receiver_receipt :
  jp_coordinate_program_lvalue_receivers_typed jp_object_collision.prog = true.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_object_list_processor_coordinate_receiver_receipt :
  jp_coordinate_program_lvalue_receivers_typed
    jp_object_list_processor.prog = true.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_behavior_script_coordinate_receiver_receipt :
  jp_coordinate_program_lvalue_receivers_typed jp_behavior_script.prog = true.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_level_script_coordinate_receiver_receipt :
  jp_coordinate_program_lvalue_receivers_typed jp_level_script.prog = true.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_graph_node_coordinate_receiver_receipt :
  jp_coordinate_program_lvalue_receivers_typed jp_graph_node.prog = true.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_rendering_graph_node_coordinate_receiver_receipt :
  jp_coordinate_program_lvalue_receivers_typed
    jp_rendering_graph_node.prog = true.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_spawn_object_coordinate_receiver_receipt :
  jp_coordinate_program_lvalue_receivers_typed jp_spawn_object.prog = true.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_object_helpers_coordinate_receiver_receipt :
  jp_coordinate_program_lvalue_receivers_typed jp_object_helpers.prog = true.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_debug_coordinate_receiver_receipt :
  jp_coordinate_program_lvalue_receivers_typed jp_debug.prog = true.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_memory_coordinate_receiver_receipt :
  jp_coordinate_program_lvalue_receivers_typed jp_memory.prog = true.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_mario_misc_coordinate_receiver_receipt :
  jp_coordinate_program_lvalue_receivers_typed jp_mario_misc.prog = true.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_obj_behaviors_coordinate_receiver_receipt :
  jp_coordinate_program_lvalue_receivers_typed jp_obj_behaviors.prog = true.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_obj_behaviors_2_coordinate_receiver_receipt :
  jp_coordinate_program_lvalue_receivers_typed jp_obj_behaviors_2.prog = true.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_behavior_actions_coordinate_receiver_receipt :
  jp_coordinate_program_lvalue_receivers_typed jp_behavior_actions.prog = true.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_behavior_data_coordinate_receiver_receipt :
  jp_coordinate_program_lvalue_receivers_typed jp_behavior_data.prog = true.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_area_coordinate_receiver_receipt :
  jp_coordinate_program_lvalue_receivers_typed jp_area.prog = true.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_level_update_coordinate_receiver_receipt :
  jp_coordinate_program_lvalue_receivers_typed jp_level_update.prog = true.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_platform_displacement_coordinate_receiver_receipt :
  jp_coordinate_program_lvalue_receivers_typed
    jp_platform_displacement.prog = true.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_math_util_coordinate_receiver_receipt :
  jp_coordinate_program_lvalue_receivers_typed jp_math_util.prog = true.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_surface_collision_coordinate_receiver_receipt :
  jp_coordinate_program_lvalue_receivers_typed jp_surface_collision.prog = true.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_surface_load_coordinate_receiver_receipt :
  jp_coordinate_program_lvalue_receivers_typed jp_surface_load.prog = true.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_macro_special_objects_coordinate_receiver_receipt :
  jp_coordinate_program_lvalue_receivers_typed
    jp_macro_special_objects.prog = true.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_ssl_script_coordinate_receiver_receipt :
  jp_coordinate_program_lvalue_receivers_typed jp_ssl_script.prog = true.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_ssl_area1_macro_coordinate_receiver_receipt :
  jp_coordinate_program_lvalue_receivers_typed jp_ssl_area1_macro.prog = true.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_ssl_area2_macro_coordinate_receiver_receipt :
  jp_coordinate_program_lvalue_receivers_typed jp_ssl_area2_macro.prog = true.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_ssl_collision_coordinate_receiver_receipt :
  jp_coordinate_program_lvalue_receivers_typed jp_ssl_collision.prog = true.
Proof. vm_compute. reflexivity. Qed.

Definition jp_coordinate_lvalue_receiver_receipts : list bool :=
  [jp_coordinate_program_lvalue_receivers_typed jp_game_init.prog;
   jp_coordinate_program_lvalue_receivers_typed jp_mario.prog;
   jp_coordinate_program_lvalue_receivers_typed jp_mario_actions_airborne.prog;
   jp_coordinate_program_lvalue_receivers_typed jp_mario_actions_automatic.prog;
   jp_coordinate_program_lvalue_receivers_typed jp_mario_actions_cutscene.prog;
   jp_coordinate_program_lvalue_receivers_typed jp_mario_actions_moving.prog;
   jp_coordinate_program_lvalue_receivers_typed jp_mario_actions_object.prog;
   jp_coordinate_program_lvalue_receivers_typed jp_mario_actions_stationary.prog;
   jp_coordinate_program_lvalue_receivers_typed jp_mario_actions_submerged.prog;
   jp_coordinate_program_lvalue_receivers_typed jp_mario_step.prog;
   jp_coordinate_program_lvalue_receivers_typed jp_interaction.prog;
   jp_coordinate_program_lvalue_receivers_typed jp_save_file.prog;
   jp_coordinate_program_lvalue_receivers_typed jp_object_collision.prog;
   jp_coordinate_program_lvalue_receivers_typed jp_object_list_processor.prog;
   jp_coordinate_program_lvalue_receivers_typed jp_behavior_script.prog;
   jp_coordinate_program_lvalue_receivers_typed jp_level_script.prog;
   jp_coordinate_program_lvalue_receivers_typed jp_graph_node.prog;
   jp_coordinate_program_lvalue_receivers_typed jp_rendering_graph_node.prog;
   jp_coordinate_program_lvalue_receivers_typed jp_spawn_object.prog;
   jp_coordinate_program_lvalue_receivers_typed jp_object_helpers.prog;
   jp_coordinate_program_lvalue_receivers_typed jp_debug.prog;
   jp_coordinate_program_lvalue_receivers_typed jp_memory.prog;
   jp_coordinate_program_lvalue_receivers_typed jp_mario_misc.prog;
   jp_coordinate_program_lvalue_receivers_typed jp_obj_behaviors.prog;
   jp_coordinate_program_lvalue_receivers_typed jp_obj_behaviors_2.prog;
   jp_coordinate_program_lvalue_receivers_typed jp_behavior_actions.prog;
   jp_coordinate_program_lvalue_receivers_typed jp_behavior_data.prog;
   jp_coordinate_program_lvalue_receivers_typed jp_area.prog;
   jp_coordinate_program_lvalue_receivers_typed jp_level_update.prog;
   jp_coordinate_program_lvalue_receivers_typed jp_platform_displacement.prog;
   jp_coordinate_program_lvalue_receivers_typed jp_math_util.prog;
   jp_coordinate_program_lvalue_receivers_typed jp_surface_collision.prog;
   jp_coordinate_program_lvalue_receivers_typed jp_surface_load.prog;
   jp_coordinate_program_lvalue_receivers_typed jp_macro_special_objects.prog;
   jp_coordinate_program_lvalue_receivers_typed jp_ssl_script.prog;
   jp_coordinate_program_lvalue_receivers_typed jp_ssl_area1_macro.prog;
   jp_coordinate_program_lvalue_receivers_typed jp_ssl_area2_macro.prog;
   jp_coordinate_program_lvalue_receivers_typed jp_ssl_collision.prog].

Theorem jp_coordinate_lvalue_receiver_receipts_cover_generated_units :
  jp_coordinate_lvalue_receiver_receipts =
  map jp_coordinate_program_lvalue_receivers_typed
    jp_generated_translation_units.
Proof. reflexivity. Qed.

Theorem jp_coordinate_lvalue_receiver_receipts_all_true :
  jp_coordinate_lvalue_receiver_receipts = repeat true 38.
Proof.
  unfold jp_coordinate_lvalue_receiver_receipts.
  rewrite jp_game_init_coordinate_receiver_receipt.
  rewrite jp_mario_coordinate_receiver_receipt.
  rewrite jp_mario_actions_airborne_coordinate_receiver_receipt.
  rewrite jp_mario_actions_automatic_coordinate_receiver_receipt.
  rewrite jp_mario_actions_cutscene_coordinate_receiver_receipt.
  rewrite jp_mario_actions_moving_coordinate_receiver_receipt.
  rewrite jp_mario_actions_object_coordinate_receiver_receipt.
  rewrite jp_mario_actions_stationary_coordinate_receiver_receipt.
  rewrite jp_mario_actions_submerged_coordinate_receiver_receipt.
  rewrite jp_mario_step_coordinate_receiver_receipt.
  rewrite jp_interaction_coordinate_receiver_receipt.
  rewrite jp_save_file_coordinate_receiver_receipt.
  rewrite jp_object_collision_coordinate_receiver_receipt.
  rewrite jp_object_list_processor_coordinate_receiver_receipt.
  rewrite jp_behavior_script_coordinate_receiver_receipt.
  rewrite jp_level_script_coordinate_receiver_receipt.
  rewrite jp_graph_node_coordinate_receiver_receipt.
  rewrite jp_rendering_graph_node_coordinate_receiver_receipt.
  rewrite jp_spawn_object_coordinate_receiver_receipt.
  rewrite jp_object_helpers_coordinate_receiver_receipt.
  rewrite jp_debug_coordinate_receiver_receipt.
  rewrite jp_memory_coordinate_receiver_receipt.
  rewrite jp_mario_misc_coordinate_receiver_receipt.
  rewrite jp_obj_behaviors_coordinate_receiver_receipt.
  rewrite jp_obj_behaviors_2_coordinate_receiver_receipt.
  rewrite jp_behavior_actions_coordinate_receiver_receipt.
  rewrite jp_behavior_data_coordinate_receiver_receipt.
  rewrite jp_area_coordinate_receiver_receipt.
  rewrite jp_level_update_coordinate_receiver_receipt.
  rewrite jp_platform_displacement_coordinate_receiver_receipt.
  rewrite jp_math_util_coordinate_receiver_receipt.
  rewrite jp_surface_collision_coordinate_receiver_receipt.
  rewrite jp_surface_load_coordinate_receiver_receipt.
  rewrite jp_macro_special_objects_coordinate_receiver_receipt.
  rewrite jp_ssl_script_coordinate_receiver_receipt.
  rewrite jp_ssl_area1_macro_coordinate_receiver_receipt.
  rewrite jp_ssl_area2_macro_coordinate_receiver_receipt.
  rewrite jp_ssl_collision_coordinate_receiver_receipt.
  reflexivity.
Qed.

Definition jp_coordinate_lvalue_receiver_partition_audit : bool :=
  forallb (fun passed => passed)
    (map jp_coordinate_program_lvalue_receivers_typed
      jp_generated_translation_units).

Theorem jp_coordinate_lvalue_receiver_partition_audit_checked :
  jp_coordinate_lvalue_receiver_partition_audit = true.
Proof.
  unfold jp_coordinate_lvalue_receiver_partition_audit.
  rewrite <- jp_coordinate_lvalue_receiver_receipts_cover_generated_units.
  rewrite jp_coordinate_lvalue_receiver_receipts_all_true.
  reflexivity.
Qed.

Theorem jp_coordinate_lvalue_receiver_partition_programwise :
  forall program,
    In program jp_generated_translation_units ->
    jp_coordinate_program_lvalue_receivers_typed program = true.
Proof.
  intros program Hin.
  pose proof jp_coordinate_lvalue_receiver_partition_audit_checked as Haudit.
  unfold jp_coordinate_lvalue_receiver_partition_audit in Haudit.
  rewrite forallb_forall in Haudit.
  assert (Hmember :
      In (jp_coordinate_program_lvalue_receivers_typed program)
        (map jp_coordinate_program_lvalue_receivers_typed
          jp_generated_translation_units)).
  { apply in_map. exact Hin. }
  specialize (Haudit _ Hmember). exact Haudit.
Qed.

Definition JPCoordinateLvalueReceiverPartition : Prop :=
  jp_coordinate_lvalue_receiver_partition_audit = true /\
  assignment_partition_total
    (jp_generated_array_slot_assignment_partition JGC_Mario._pos 1) = 33%nat /\
  assignment_partition_total
    (jp_generated_nested_array_slot_assignment_partition
      JGC_Mario._rawData JGC_Mario._asF32 7) = 215%nat /\
  assignment_partition_total
    (jp_generated_nested_array_slot_assignment_partition
      JGC_Mario._rawData JGC_Mario._asF32 10) = 180%nat /\
  assignment_partition_total
    (jp_generated_assignment_lhs_field_mention_partition
      JGC_Mario._throwMatrix) = 15%nat.

Theorem jp_coordinate_lvalue_receiver_partition_checked :
  JPCoordinateLvalueReceiverPartition.
Proof.
  unfold JPCoordinateLvalueReceiverPartition.
  pose proof jp_generated_pos_y_direct_assignment_counts as [_ Hpos].
  pose proof jp_generated_rawdata_asf32_7_direct_assignment_counts
    as [_ Hraw7].
  pose proof jp_generated_rawdata_asf32_10_direct_assignment_counts
    as [_ Hraw10].
  pose proof jp_generated_throw_matrix_assignment_counts as [_ Hthrow].
  split.
  - exact jp_coordinate_lvalue_receiver_partition_audit_checked.
  - repeat split; assumption.
Qed.

(** Residual boundary: an annotated [Tstruct] receiver identifies the source
    object kind expected by Clight's typechecker, but does not establish which
    runtime block a pointer denotes.  The live proof still needs pointer
    validity, bounds, Mario/Object/Graphics identity and non-aliasing, external
    frames, and reachability of each executed store. *)
