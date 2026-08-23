(** Whole-game stored-alias and transition-lifetime census for the writable
    interaction tables.

    A writable global can be reached by an indirect defined store only after
    some value identifies its CompCert block.  For these three private arrays,
    the possible source-level origins of such a value are finite:

    - a second definition or public export of the same identifier;
    - an [Init_addrof] relocation in any global initializer;
    - a function-body occurrence that stores, returns, or passes the array
      address; or
    - the transient array address used by a checked terminal read.

    This file checks those classes over the complete 38-unit US and JP
    gameplay source unions used to build the selected Clight programs.  Each
    table has exactly one private definition, no initializer anywhere points
    to it, and the only body occurrences are the four terminal reads already
    decoded in [WritableActionTableAliasExternalClosure].  In particular, the
    handler read produces a stock function pointer stored in a temporary; it
    does not produce a pointer back into the table.  The knockback reads
    produce integer action words.

    The final lemmas state the semantic payoff used for cross-level
    carryover.  A store whose address self-injects under an injection omitting
    the table blocks cannot target a table block, and therefore preserves all
    table loads.  Frames compose across arbitrarily many area/level steps.
    Consequently a hypothetical mutation after engine initialization would
    survive an ordinary transition into SSL unless a real step breaks the
    private invariant; the source census supplies no such step.

    The separate retail-MIPS questions—flat-address out-of-bounds writes,
    DMA, ACE, and continuations after undefined behavior—remain outside this
    CompCert result. *)

From Coq Require Import Bool Classical_Prop List ZArith.
From compcert Require Import
  AST Clight Coqlib Ctypes Globalenvs Integers Linking Memory Values.
From LessThanOneAPress.Generated Require Import
  us_area us_interaction us_level_update us_object_list_processor
  jp_area jp_interaction jp_level_update jp_object_list_processor.
From LessThanOneAPress.Proofs Require Import
  ASTFacts CleanedClightPrograms ClightLinkExecution ClightRefinement GameTypes
  InkTimer131MarioTailClosure
  JPSourceSymbolTransport
  LinkedClightPrograms NormalizedClightPrograms
  SelectedClightTarget
  WritableActionTableAliasExternalClosure.

Import ListNotations.
Local Open Scope Z_scope.

Module WATWG_USA := us_area.
Module WATWG_USI := us_interaction.
Module WATWG_USL := us_level_update.
Module WATWG_USO := us_object_list_processor.
Module WATWG_JPA := jp_area.
Module WATWG_JPI := jp_interaction.
Module WATWG_JPL := jp_level_update.
Module WATWG_JPO := jp_object_list_processor.

Definition watwg_us_table_ids : list ident :=
  [WATWG_USI._sInteractionHandlers;
   WATWG_USI._sForwardKnockbackActions;
   WATWG_USI._sBackwardKnockbackActions].

Definition watwg_jp_table_ids : list ident :=
  [WATWG_JPI._sInteractionHandlers;
   WATWG_JPI._sForwardKnockbackActions;
   WATWG_JPI._sBackwardKnockbackActions].

Definition watwg_init_datum_mentions_any
    (targets : list ident) (datum : init_data) : bool :=
  existsb (fun target => initializer_mentions_addrof target datum) targets.

Definition watwg_global_has_no_initializer_alias
    (targets : list ident)
    (entry : ident * globdef Clight.fundef type) : bool :=
  match snd entry with
  | Gvar variable =>
      negb (existsb (watwg_init_datum_mentions_any targets)
        (gvar_init variable))
  | _ => true
  end.

Definition watwg_program_has_no_initializer_alias
    (targets : list ident) (program : Clight.program) : bool :=
  forallb (watwg_global_has_no_initializer_alias targets)
    (prog_defs program).

Definition watwg_program_does_not_export
    (targets : list ident) (program : Clight.program) : bool :=
  forallb
    (fun target => negb (ident_mem target (prog_public program))) targets.

(** Evaluate one translation unit at a time.  This is extensionally the
    desired whole-union check but avoids constructing and normalizing one
    enormous concatenated definition list in the proof kernel. *)
Fixpoint watwg_nlist_all {A : Type}
    (predicate : A -> bool) (values : nlist A) : bool :=
  match values with
  | nbase value => predicate value
  | ncons value rest => predicate value && watwg_nlist_all predicate rest
  end.

Definition watwg_program_is_private
    (targets : list ident) (program : Clight.program) : bool :=
  watwg_program_has_no_initializer_alias targets program &&
  watwg_program_does_not_export targets program.

Lemma watwg_nlist_all_private_split :
  forall targets values,
    watwg_nlist_all (watwg_program_is_private targets) values = true ->
    watwg_nlist_all
      (watwg_program_has_no_initializer_alias targets) values = true /\
    watwg_nlist_all
      (watwg_program_does_not_export targets) values = true.
Proof.
  intros targets values. induction values as [value | value rest IH].
  - cbn. unfold watwg_program_is_private.
    now intros H; apply andb_true_iff in H.
  - cbn. intros H.
    apply andb_true_iff in H as [Hvalue Hrest].
    unfold watwg_program_is_private in Hvalue.
    apply andb_true_iff in Hvalue as [Hinitial Hexport].
    destruct (IH Hrest) as [Hrest_initial Hrest_export].
    split; apply andb_true_iff; auto.
Qed.

(** Each theorem below checks one US/JP translation-unit pair.  Sharding is
    proof-engineering only: the aggregate theorems unfold the exact [us_units]
    and [jp_units] lists and rewrite all 38 receipts, so no unit is sampled or
    silently omitted. *)
Theorem watwg_game_init_unit_is_private :
  watwg_program_is_private watwg_us_table_ids us_game_init.prog = true /\
  watwg_program_is_private watwg_jp_table_ids jp_game_init.prog = true.
Proof.
  vm_compute. split; reflexivity.
Qed.

Theorem watwg_mario_unit_is_private :
  watwg_program_is_private watwg_us_table_ids us_mario.prog = true /\
  watwg_program_is_private watwg_jp_table_ids jp_mario.prog = true.
Proof.
  vm_compute. split; reflexivity.
Qed.

Theorem watwg_mario_actions_airborne_unit_is_private :
  watwg_program_is_private watwg_us_table_ids us_mario_actions_airborne.prog = true /\
  watwg_program_is_private watwg_jp_table_ids jp_mario_actions_airborne.prog = true.
Proof.
  vm_compute. split; reflexivity.
Qed.

Theorem watwg_mario_actions_automatic_unit_is_private :
  watwg_program_is_private watwg_us_table_ids us_mario_actions_automatic.prog = true /\
  watwg_program_is_private watwg_jp_table_ids jp_mario_actions_automatic.prog = true.
Proof.
  vm_compute. split; reflexivity.
Qed.

Theorem watwg_mario_actions_cutscene_unit_is_private :
  watwg_program_is_private watwg_us_table_ids us_mario_actions_cutscene.prog = true /\
  watwg_program_is_private watwg_jp_table_ids jp_mario_actions_cutscene.prog = true.
Proof.
  vm_compute. split; reflexivity.
Qed.

Theorem watwg_mario_actions_moving_unit_is_private :
  watwg_program_is_private watwg_us_table_ids us_mario_actions_moving.prog = true /\
  watwg_program_is_private watwg_jp_table_ids jp_mario_actions_moving.prog = true.
Proof.
  vm_compute. split; reflexivity.
Qed.

Theorem watwg_mario_actions_object_unit_is_private :
  watwg_program_is_private watwg_us_table_ids us_mario_actions_object.prog = true /\
  watwg_program_is_private watwg_jp_table_ids jp_mario_actions_object.prog = true.
Proof.
  vm_compute. split; reflexivity.
Qed.

Theorem watwg_mario_actions_stationary_unit_is_private :
  watwg_program_is_private watwg_us_table_ids us_mario_actions_stationary.prog = true /\
  watwg_program_is_private watwg_jp_table_ids jp_mario_actions_stationary.prog = true.
Proof.
  vm_compute. split; reflexivity.
Qed.

Theorem watwg_mario_actions_submerged_unit_is_private :
  watwg_program_is_private watwg_us_table_ids us_mario_actions_submerged.prog = true /\
  watwg_program_is_private watwg_jp_table_ids jp_mario_actions_submerged.prog = true.
Proof.
  vm_compute. split; reflexivity.
Qed.

Theorem watwg_mario_step_unit_is_private :
  watwg_program_is_private watwg_us_table_ids us_mario_step.prog = true /\
  watwg_program_is_private watwg_jp_table_ids jp_mario_step.prog = true.
Proof.
  vm_compute. split; reflexivity.
Qed.

Theorem watwg_interaction_unit_is_private :
  watwg_program_is_private watwg_us_table_ids us_interaction.prog = true /\
  watwg_program_is_private watwg_jp_table_ids jp_interaction.prog = true.
Proof.
  vm_compute. split; reflexivity.
Qed.

Theorem watwg_save_file_unit_is_private :
  watwg_program_is_private watwg_us_table_ids us_save_file.prog = true /\
  watwg_program_is_private watwg_jp_table_ids jp_save_file.prog = true.
Proof.
  vm_compute. split; reflexivity.
Qed.

Theorem watwg_object_collision_unit_is_private :
  watwg_program_is_private watwg_us_table_ids us_object_collision.prog = true /\
  watwg_program_is_private watwg_jp_table_ids jp_object_collision.prog = true.
Proof.
  vm_compute. split; reflexivity.
Qed.

Theorem watwg_object_list_processor_unit_is_private :
  watwg_program_is_private watwg_us_table_ids us_object_list_processor.prog = true /\
  watwg_program_is_private watwg_jp_table_ids jp_object_list_processor.prog = true.
Proof.
  vm_compute. split; reflexivity.
Qed.

Theorem watwg_behavior_script_unit_is_private :
  watwg_program_is_private watwg_us_table_ids us_behavior_script.prog = true /\
  watwg_program_is_private watwg_jp_table_ids jp_behavior_script.prog = true.
Proof.
  vm_compute. split; reflexivity.
Qed.

Theorem watwg_level_script_unit_is_private :
  watwg_program_is_private watwg_us_table_ids us_level_script.prog = true /\
  watwg_program_is_private watwg_jp_table_ids jp_level_script.prog = true.
Proof.
  vm_compute. split; reflexivity.
Qed.

Theorem watwg_graph_node_unit_is_private :
  watwg_program_is_private watwg_us_table_ids us_graph_node.prog = true /\
  watwg_program_is_private watwg_jp_table_ids jp_graph_node.prog = true.
Proof.
  vm_compute. split; reflexivity.
Qed.

Theorem watwg_rendering_graph_node_unit_is_private :
  watwg_program_is_private watwg_us_table_ids us_rendering_graph_node.prog = true /\
  watwg_program_is_private watwg_jp_table_ids jp_rendering_graph_node.prog = true.
Proof.
  vm_compute. split; reflexivity.
Qed.

Theorem watwg_spawn_object_unit_is_private :
  watwg_program_is_private watwg_us_table_ids us_spawn_object.prog = true /\
  watwg_program_is_private watwg_jp_table_ids jp_spawn_object.prog = true.
Proof.
  vm_compute. split; reflexivity.
Qed.

Theorem watwg_object_helpers_unit_is_private :
  watwg_program_is_private watwg_us_table_ids us_object_helpers.prog = true /\
  watwg_program_is_private watwg_jp_table_ids jp_object_helpers.prog = true.
Proof.
  vm_compute. split; reflexivity.
Qed.

Theorem watwg_debug_unit_is_private :
  watwg_program_is_private watwg_us_table_ids us_debug.prog = true /\
  watwg_program_is_private watwg_jp_table_ids jp_debug.prog = true.
Proof.
  vm_compute. split; reflexivity.
Qed.

Theorem watwg_memory_unit_is_private :
  watwg_program_is_private watwg_us_table_ids us_memory.prog = true /\
  watwg_program_is_private watwg_jp_table_ids jp_memory.prog = true.
Proof.
  vm_compute. split; reflexivity.
Qed.

Theorem watwg_mario_misc_unit_is_private :
  watwg_program_is_private watwg_us_table_ids us_mario_misc.prog = true /\
  watwg_program_is_private watwg_jp_table_ids jp_mario_misc.prog = true.
Proof.
  vm_compute. split; reflexivity.
Qed.

Theorem watwg_obj_behaviors_unit_is_private :
  watwg_program_is_private watwg_us_table_ids us_obj_behaviors.prog = true /\
  watwg_program_is_private watwg_jp_table_ids jp_obj_behaviors.prog = true.
Proof.
  vm_compute. split; reflexivity.
Qed.

Theorem watwg_obj_behaviors_2_unit_is_private :
  watwg_program_is_private watwg_us_table_ids us_obj_behaviors_2.prog = true /\
  watwg_program_is_private watwg_jp_table_ids jp_obj_behaviors_2.prog = true.
Proof.
  vm_compute. split; reflexivity.
Qed.

Theorem watwg_behavior_actions_unit_is_private :
  watwg_program_is_private watwg_us_table_ids us_behavior_actions.prog = true /\
  watwg_program_is_private watwg_jp_table_ids jp_behavior_actions.prog = true.
Proof.
  vm_compute. split; reflexivity.
Qed.

Theorem watwg_behavior_data_unit_is_private :
  watwg_program_is_private watwg_us_table_ids us_behavior_data.prog = true /\
  watwg_program_is_private watwg_jp_table_ids jp_behavior_data.prog = true.
Proof.
  vm_compute. split; reflexivity.
Qed.

Theorem watwg_area_unit_is_private :
  watwg_program_is_private watwg_us_table_ids us_area.prog = true /\
  watwg_program_is_private watwg_jp_table_ids jp_area.prog = true.
Proof.
  vm_compute. split; reflexivity.
Qed.

Theorem watwg_level_update_unit_is_private :
  watwg_program_is_private watwg_us_table_ids us_level_update.prog = true /\
  watwg_program_is_private watwg_jp_table_ids jp_level_update.prog = true.
Proof.
  vm_compute. split; reflexivity.
Qed.

Theorem watwg_platform_displacement_unit_is_private :
  watwg_program_is_private watwg_us_table_ids us_platform_displacement.prog = true /\
  watwg_program_is_private watwg_jp_table_ids jp_platform_displacement.prog = true.
Proof.
  vm_compute. split; reflexivity.
Qed.

Theorem watwg_math_util_unit_is_private :
  watwg_program_is_private watwg_us_table_ids us_math_util.prog = true /\
  watwg_program_is_private watwg_jp_table_ids jp_math_util.prog = true.
Proof.
  vm_compute. split; reflexivity.
Qed.

Theorem watwg_surface_collision_unit_is_private :
  watwg_program_is_private watwg_us_table_ids us_surface_collision.prog = true /\
  watwg_program_is_private watwg_jp_table_ids jp_surface_collision.prog = true.
Proof.
  vm_compute. split; reflexivity.
Qed.

Theorem watwg_surface_load_unit_is_private :
  watwg_program_is_private watwg_us_table_ids us_surface_load.prog = true /\
  watwg_program_is_private watwg_jp_table_ids jp_surface_load.prog = true.
Proof.
  vm_compute. split; reflexivity.
Qed.

Theorem watwg_macro_special_objects_unit_is_private :
  watwg_program_is_private watwg_us_table_ids us_macro_special_objects.prog = true /\
  watwg_program_is_private watwg_jp_table_ids jp_macro_special_objects.prog = true.
Proof.
  vm_compute. split; reflexivity.
Qed.

Theorem watwg_ssl_script_unit_is_private :
  watwg_program_is_private watwg_us_table_ids us_ssl_script.prog = true /\
  watwg_program_is_private watwg_jp_table_ids jp_ssl_script.prog = true.
Proof.
  vm_compute. split; reflexivity.
Qed.

Theorem watwg_ssl_area1_macro_unit_is_private :
  watwg_program_is_private watwg_us_table_ids us_ssl_area1_macro.prog = true /\
  watwg_program_is_private watwg_jp_table_ids jp_ssl_area1_macro.prog = true.
Proof.
  vm_compute. split; reflexivity.
Qed.

Theorem watwg_ssl_area2_macro_unit_is_private :
  watwg_program_is_private watwg_us_table_ids us_ssl_area2_macro.prog = true /\
  watwg_program_is_private watwg_jp_table_ids jp_ssl_area2_macro.prog = true.
Proof.
  vm_compute. split; reflexivity.
Qed.

Theorem watwg_ssl_collision_unit_is_private :
  watwg_program_is_private watwg_us_table_ids us_ssl_collision.prog = true /\
  watwg_program_is_private watwg_jp_table_ids jp_ssl_collision.prog = true.
Proof.
  vm_compute. split; reflexivity.
Qed.

Theorem watwg_us_source_units_are_private :
  watwg_nlist_all
    (watwg_program_is_private watwg_us_table_ids) us_units = true.
Proof.
  unfold us_units, watwg_nlist_all.
  rewrite
    (proj1 watwg_game_init_unit_is_private),
    (proj1 watwg_mario_unit_is_private),
    (proj1 watwg_mario_actions_airborne_unit_is_private),
    (proj1 watwg_mario_actions_automatic_unit_is_private),
    (proj1 watwg_mario_actions_cutscene_unit_is_private),
    (proj1 watwg_mario_actions_moving_unit_is_private),
    (proj1 watwg_mario_actions_object_unit_is_private),
    (proj1 watwg_mario_actions_stationary_unit_is_private),
    (proj1 watwg_mario_actions_submerged_unit_is_private),
    (proj1 watwg_mario_step_unit_is_private),
    (proj1 watwg_interaction_unit_is_private),
    (proj1 watwg_save_file_unit_is_private),
    (proj1 watwg_object_collision_unit_is_private),
    (proj1 watwg_object_list_processor_unit_is_private),
    (proj1 watwg_behavior_script_unit_is_private),
    (proj1 watwg_level_script_unit_is_private),
    (proj1 watwg_graph_node_unit_is_private),
    (proj1 watwg_rendering_graph_node_unit_is_private),
    (proj1 watwg_spawn_object_unit_is_private),
    (proj1 watwg_object_helpers_unit_is_private),
    (proj1 watwg_debug_unit_is_private),
    (proj1 watwg_memory_unit_is_private),
    (proj1 watwg_mario_misc_unit_is_private),
    (proj1 watwg_obj_behaviors_unit_is_private),
    (proj1 watwg_obj_behaviors_2_unit_is_private),
    (proj1 watwg_behavior_actions_unit_is_private),
    (proj1 watwg_behavior_data_unit_is_private),
    (proj1 watwg_area_unit_is_private),
    (proj1 watwg_level_update_unit_is_private),
    (proj1 watwg_platform_displacement_unit_is_private),
    (proj1 watwg_math_util_unit_is_private),
    (proj1 watwg_surface_collision_unit_is_private),
    (proj1 watwg_surface_load_unit_is_private),
    (proj1 watwg_macro_special_objects_unit_is_private),
    (proj1 watwg_ssl_script_unit_is_private),
    (proj1 watwg_ssl_area1_macro_unit_is_private),
    (proj1 watwg_ssl_area2_macro_unit_is_private),
    (proj1 watwg_ssl_collision_unit_is_private).
  reflexivity.
Qed.

Theorem watwg_jp_source_units_are_private :
  watwg_nlist_all
    (watwg_program_is_private watwg_jp_table_ids) jp_units = true.
Proof.
  unfold jp_units, watwg_nlist_all.
  rewrite
    (proj2 watwg_game_init_unit_is_private),
    (proj2 watwg_mario_unit_is_private),
    (proj2 watwg_mario_actions_airborne_unit_is_private),
    (proj2 watwg_mario_actions_automatic_unit_is_private),
    (proj2 watwg_mario_actions_cutscene_unit_is_private),
    (proj2 watwg_mario_actions_moving_unit_is_private),
    (proj2 watwg_mario_actions_object_unit_is_private),
    (proj2 watwg_mario_actions_stationary_unit_is_private),
    (proj2 watwg_mario_actions_submerged_unit_is_private),
    (proj2 watwg_mario_step_unit_is_private),
    (proj2 watwg_interaction_unit_is_private),
    (proj2 watwg_save_file_unit_is_private),
    (proj2 watwg_object_collision_unit_is_private),
    (proj2 watwg_object_list_processor_unit_is_private),
    (proj2 watwg_behavior_script_unit_is_private),
    (proj2 watwg_level_script_unit_is_private),
    (proj2 watwg_graph_node_unit_is_private),
    (proj2 watwg_rendering_graph_node_unit_is_private),
    (proj2 watwg_spawn_object_unit_is_private),
    (proj2 watwg_object_helpers_unit_is_private),
    (proj2 watwg_debug_unit_is_private),
    (proj2 watwg_memory_unit_is_private),
    (proj2 watwg_mario_misc_unit_is_private),
    (proj2 watwg_obj_behaviors_unit_is_private),
    (proj2 watwg_obj_behaviors_2_unit_is_private),
    (proj2 watwg_behavior_actions_unit_is_private),
    (proj2 watwg_behavior_data_unit_is_private),
    (proj2 watwg_area_unit_is_private),
    (proj2 watwg_level_update_unit_is_private),
    (proj2 watwg_platform_displacement_unit_is_private),
    (proj2 watwg_math_util_unit_is_private),
    (proj2 watwg_surface_collision_unit_is_private),
    (proj2 watwg_surface_load_unit_is_private),
    (proj2 watwg_macro_special_objects_unit_is_private),
    (proj2 watwg_ssl_script_unit_is_private),
    (proj2 watwg_ssl_area1_macro_unit_is_private),
    (proj2 watwg_ssl_area2_macro_unit_is_private),
    (proj2 watwg_ssl_collision_unit_is_private).
  reflexivity.
Qed.


(** Indices 147--149 are the three consecutive storage definitions in each
    generated interaction translation unit.  The two recursive Boolean
    receipts then inspect every one of the 38 source units without flattening
    their large ASTs. *)
Definition WritableActionTableWholeGameStorageReceipt : Prop :=
  nth_error WATWG_USI.global_definitions 147%nat =
    Some (WATWG_USI._sInteractionHandlers,
      Gvar WATWG_USI.v_sInteractionHandlers) /\
  nth_error WATWG_USI.global_definitions 148%nat =
    Some (WATWG_USI._sForwardKnockbackActions,
      Gvar WATWG_USI.v_sForwardKnockbackActions) /\
  nth_error WATWG_USI.global_definitions 149%nat =
    Some (WATWG_USI._sBackwardKnockbackActions,
      Gvar WATWG_USI.v_sBackwardKnockbackActions) /\
  nth_error WATWG_JPI.global_definitions 147%nat =
    Some (WATWG_JPI._sInteractionHandlers,
      Gvar WATWG_JPI.v_sInteractionHandlers) /\
  nth_error WATWG_JPI.global_definitions 148%nat =
    Some (WATWG_JPI._sForwardKnockbackActions,
      Gvar WATWG_JPI.v_sForwardKnockbackActions) /\
  nth_error WATWG_JPI.global_definitions 149%nat =
    Some (WATWG_JPI._sBackwardKnockbackActions,
      Gvar WATWG_JPI.v_sBackwardKnockbackActions) /\
  identifiers_unique
    (definitive_variable_identifiers
      (unit_global_definitions us_units)) = true /\
  identifiers_unique
    (definitive_variable_identifiers
      (unit_global_definitions jp_units)) = true /\
  watwg_nlist_all
    (watwg_program_has_no_initializer_alias watwg_us_table_ids)
    us_units = true /\
  watwg_nlist_all
    (watwg_program_has_no_initializer_alias watwg_jp_table_ids)
    jp_units = true /\
  watwg_nlist_all
    (watwg_program_does_not_export watwg_us_table_ids)
    us_units = true /\
  watwg_nlist_all
    (watwg_program_does_not_export watwg_jp_table_ids)
    jp_units = true.

Theorem writable_action_tables_have_no_whole_game_stored_initial_alias :
  WritableActionTableWholeGameStorageReceipt.
Proof.
  destruct (watwg_nlist_all_private_split watwg_us_table_ids us_units
    watwg_us_source_units_are_private) as [Hus_initial Hus_export].
  destruct (watwg_nlist_all_private_split watwg_jp_table_ids jp_units
    watwg_jp_source_units_are_private) as [Hjp_initial Hjp_export].
  unfold WritableActionTableWholeGameStorageReceipt.
  split; [vm_compute; reflexivity |].
  split; [vm_compute; reflexivity |].
  split; [vm_compute; reflexivity |].
  split; [vm_compute; reflexivity |].
  split; [vm_compute; reflexivity |].
  split; [vm_compute; reflexivity |].
  split; [exact us_definitive_identifiers_are_unique_checked |].
  split; [exact jp_definitive_identifiers_are_unique_checked |].
  split; [exact Hus_initial |].
  split; [exact Hjp_initial |].
  split; [exact Hus_export | exact Hjp_export].
Qed.

(** The area-change routines are listed separately because they answer the
    cross-level question directly.  Their bodies do not even name a table;
    the stronger whole-corpus occurrence theorem limits all names to the
    dispatch/knockback consumers. *)
Definition watwg_us_transition_bodies : list statement :=
  [fn_body WATWG_USO.f_clear_objects;
   fn_body WATWG_USA.f_clear_areas;
   fn_body WATWG_USA.f_clear_area_graph_nodes;
   fn_body WATWG_USA.f_load_area;
   fn_body WATWG_USA.f_unload_area;
   fn_body WATWG_USA.f_load_mario_area;
   fn_body WATWG_USA.f_unload_mario_area;
   fn_body WATWG_USA.f_change_area;
   fn_body WATWG_USL.f_level_trigger_warp].

Definition watwg_jp_transition_bodies : list statement :=
  [fn_body WATWG_JPO.f_clear_objects;
   fn_body WATWG_JPA.f_clear_areas;
   fn_body WATWG_JPA.f_clear_area_graph_nodes;
   fn_body WATWG_JPA.f_load_area;
   fn_body WATWG_JPA.f_unload_area;
   fn_body WATWG_JPA.f_load_mario_area;
   fn_body WATWG_JPA.f_unload_mario_area;
   fn_body WATWG_JPA.f_change_area;
   fn_body WATWG_JPL.f_level_trigger_warp].

Definition watwg_bodies_do_not_name
    (target : ident) (bodies : list statement) : bool :=
  forallb (fun body => negb (statement_mentions_ident_s target body)) bodies.

Definition WritableActionTableTransitionSyntaxReceipt : Prop :=
  forallb
    (fun target => watwg_bodies_do_not_name target watwg_us_transition_bodies)
    watwg_us_table_ids = true /\
  forallb
    (fun target => watwg_bodies_do_not_name target watwg_jp_transition_bodies)
    watwg_jp_table_ids = true.

Theorem ordinary_area_and_level_transition_bodies_do_not_name_action_tables :
  WritableActionTableTransitionSyntaxReceipt.
Proof.
  unfold WritableActionTableTransitionSyntaxReceipt,
    watwg_bodies_do_not_name, watwg_us_transition_bodies,
    watwg_jp_transition_bodies, watwg_us_table_ids, watwg_jp_table_ids.
  vm_compute. split; reflexivity.
Qed.

(** This bundles the complete source conclusion.  The occurrence-sensitive
    receipt is what rejects persistence through a store, return, call/builtin
    handoff, or a nonterminal temporary.  The initializer-wide receipt closes
    the only source location not represented by a statement body. *)
Definition WritableActionTableWholeGameAliasCensus : Prop :=
  WritableActionTableNoAliasSourceReceipt /\
  WritableActionTableWholeGameStorageReceipt /\
  WritableActionTableTransitionSyntaxReceipt.

Theorem writable_action_table_whole_game_alias_census_holds :
  WritableActionTableWholeGameAliasCensus.
Proof.
  unfold WritableActionTableWholeGameAliasCensus.
  split; [exact writable_action_tables_have_only_terminal_private_reads |].
  split.
  - exact writable_action_tables_have_no_whole_game_stored_initial_alias.
  - exact ordinary_area_and_level_transition_bodies_do_not_name_action_tables.
Qed.

(** * Semantic persistence and first-alias boundary *)

Definition watwg_linked_source_table_ids (version : GameVersion) : list ident :=
  match version with
  | VersionUS => watwg_us_table_ids
  | VersionJP => watwg_jp_table_ids
  end.

Lemma watwg_us_interaction_table_definitions :
  In (WATWG_USI._sInteractionHandlers,
      Gvar WATWG_USI.v_sInteractionHandlers)
      (prog_defs WATWG_USI.prog) /\
  In (WATWG_USI._sForwardKnockbackActions,
      Gvar WATWG_USI.v_sForwardKnockbackActions)
      (prog_defs WATWG_USI.prog) /\
  In (WATWG_USI._sBackwardKnockbackActions,
      Gvar WATWG_USI.v_sBackwardKnockbackActions)
      (prog_defs WATWG_USI.prog).
Proof.
  pose proof writable_action_tables_have_no_whole_game_stored_initial_alias
    as [Hhandler [Hforward [Hbackward _]]].
  split.
  - eapply nth_error_In. exact Hhandler.
  - split.
    + eapply nth_error_In. exact Hforward.
    + eapply nth_error_In. exact Hbackward.
Qed.

Lemma watwg_jp_interaction_table_definitions :
  In (WATWG_JPI._sInteractionHandlers,
      Gvar WATWG_JPI.v_sInteractionHandlers)
      (prog_defs WATWG_JPI.prog) /\
  In (WATWG_JPI._sForwardKnockbackActions,
      Gvar WATWG_JPI.v_sForwardKnockbackActions)
      (prog_defs WATWG_JPI.prog) /\
  In (WATWG_JPI._sBackwardKnockbackActions,
      Gvar WATWG_JPI.v_sBackwardKnockbackActions)
      (prog_defs WATWG_JPI.prog).
Proof.
  pose proof writable_action_tables_have_no_whole_game_stored_initial_alias
    as [_ [_ [_ [Hhandler [Hforward [Hbackward _]]]]]].
  split.
  - eapply nth_error_In. exact Hhandler.
  - split.
    + eapply nth_error_In. exact Hforward.
    + eapply nth_error_In. exact Hbackward.
Qed.

Record LinkedSourceActionTableBlocks
    (version : GameVersion) (blocks : list block) : Prop := {
  linked_source_action_table_block_count : length blocks = 3%nat;
  linked_source_action_table_blocks_resolve :
    Forall2
      (fun identifier global_block =>
        Genv.find_symbol
          (Clight.globalenv (selected_clight_source version)) identifier =
        Some global_block)
      (watwg_linked_source_table_ids version) blocks
}.

Theorem linked_source_action_table_blocks_exist :
  forall version,
    exists blocks, LinkedSourceActionTableBlocks version blocks.
Proof.
  intros []; cbn.
  - destruct watwg_us_interaction_table_definitions as
      [Hhandler_definition [Hforward_definition Hbackward_definition]].
    assert (Hunit : nIn WATWG_USI.prog us_units).
    { unfold us_units. do 10 right. left. reflexivity. }
    assert (Hhandler := source_unit_definition_has_official_link_symbol
      us_units us_cleaned_units us_official_cleaned_slice WATWG_USI.prog
      WATWG_USI._sInteractionHandlers
      (Gvar WATWG_USI.v_sInteractionHandlers) Hunit Hhandler_definition
      us_source_union_identifier_coverage_for_cleaned_units
      us_cleaned_units_official_link).
    assert (Hforward := source_unit_definition_has_official_link_symbol
      us_units us_cleaned_units us_official_cleaned_slice WATWG_USI.prog
      WATWG_USI._sForwardKnockbackActions
      (Gvar WATWG_USI.v_sForwardKnockbackActions) Hunit Hforward_definition
      us_source_union_identifier_coverage_for_cleaned_units
      us_cleaned_units_official_link).
    assert (Hbackward := source_unit_definition_has_official_link_symbol
      us_units us_cleaned_units us_official_cleaned_slice WATWG_USI.prog
      WATWG_USI._sBackwardKnockbackActions
      (Gvar WATWG_USI.v_sBackwardKnockbackActions) Hunit Hbackward_definition
      us_source_union_identifier_coverage_for_cleaned_units
      us_cleaned_units_official_link).
    destruct Hhandler as [handler_block Hhandler].
    destruct Hforward as [forward_block Hforward].
    destruct Hbackward as [backward_block Hbackward].
    exists [handler_block; forward_block; backward_block].
    constructor; [reflexivity |].
    repeat constructor; assumption.
  - destruct watwg_jp_interaction_table_definitions as
      [Hhandler_definition [Hforward_definition Hbackward_definition]].
    assert (Hunit : nIn WATWG_JPI.prog jp_units).
    { unfold jp_units. do 10 right. left. reflexivity. }
    assert (Hhandler := source_unit_definition_has_official_link_symbol
      jp_units jp_cleaned_units jp_official_cleaned_slice WATWG_JPI.prog
      WATWG_JPI._sInteractionHandlers
      (Gvar WATWG_JPI.v_sInteractionHandlers) Hunit Hhandler_definition
      jp_source_union_identifier_coverage_for_cleaned_units
      jp_cleaned_units_official_link).
    assert (Hforward := source_unit_definition_has_official_link_symbol
      jp_units jp_cleaned_units jp_official_cleaned_slice WATWG_JPI.prog
      WATWG_JPI._sForwardKnockbackActions
      (Gvar WATWG_JPI.v_sForwardKnockbackActions) Hunit Hforward_definition
      jp_source_union_identifier_coverage_for_cleaned_units
      jp_cleaned_units_official_link).
    assert (Hbackward := source_unit_definition_has_official_link_symbol
      jp_units jp_cleaned_units jp_official_cleaned_slice WATWG_JPI.prog
      WATWG_JPI._sBackwardKnockbackActions
      (Gvar WATWG_JPI.v_sBackwardKnockbackActions) Hunit Hbackward_definition
      jp_source_union_identifier_coverage_for_cleaned_units
      jp_cleaned_units_official_link).
    destruct Hhandler as [handler_block Hhandler].
    destruct Hforward as [forward_block Hforward].
    destruct Hbackward as [backward_block Hbackward].
    exists [handler_block; forward_block; backward_block].
    constructor; [reflexivity |].
    repeat constructor; assumption.
Qed.

Lemma watwg_forall2_right_has_left :
  forall (A B : Type) (relation : A -> B -> Prop)
      left_values right_values right_value,
    Forall2 relation left_values right_values ->
    In right_value right_values ->
    exists left_value,
      In left_value left_values /\ relation left_value right_value.
Proof.
  intros A B relation left_values right_values right_value Hrelation.
  induction Hrelation as
      [| left_value right_head left_tail right_tail Hhead Htail IH]; cbn.
  - contradiction.
  - intros [Hequal | Hin].
    + subst right_head. exists left_value. auto.
    + destruct (IH Hin) as [found [Hfound Hrelated]].
      exists found. auto.
Qed.

Theorem linked_source_action_table_blocks_are_valid_at_initialization :
  forall version memory blocks,
    Genv.init_mem (selected_clight_source version) = Some memory ->
    LinkedSourceActionTableBlocks version blocks ->
    forall protected_block,
      In protected_block blocks -> Mem.valid_block memory protected_block.
Proof.
  intros version memory blocks Hinitial Hblocks protected_block Hin.
  destruct Hblocks as [_ Hresolved].
  destruct (watwg_forall2_right_has_left _ _ _ _ _ _ Hresolved Hin)
    as [identifier [_ Hlookup]].
  eapply Genv.find_symbol_not_fresh; eauto.
Qed.

(** The ordinary global/volatile validity premise used by the external-call
    injection theorem is not an additional gameplay assumption at program
    initialization.  It follows for every successful CompCert initial
    memory from the global environment's block bounds. *)
Theorem initialized_memory_supplies_action_table_global_block_validity :
  forall (program : Clight.program) memory,
    Genv.init_mem program = Some memory ->
    ActionTableGlobalBlocksValid (Clight.globalenv program) memory.
Proof.
  intros program memory Hinitial. split.
  - intros identifier global_block Hsymbol.
    change (Genv.find_symbol (Clight.globalenv program) identifier =
      Some global_block) in Hsymbol.
    eapply Genv.find_symbol_not_fresh; eauto.
  - intros global_block Hvolatile.
    change (Genv.block_is_volatile (Clight.globalenv program) global_block =
      true) in Hvolatile.
    unfold Mem.valid_block.
    erewrite <- Genv.init_mem_genv_next by exact Hinitial.
    eapply Genv.block_is_volatile_below; eauto.
Qed.

Definition ActionTableBlocksUnchanged
    (protected_blocks : list block) (before after : mem) : Prop :=
  Mem.unchanged_on
    (fun target_block _ => In target_block protected_blocks) before after.

Inductive watwg_all_adjacent {A : Type} (relation : A -> A -> Prop) :
    list A -> Prop :=
| watwg_adjacent_nil : watwg_all_adjacent relation []
| watwg_adjacent_one :
    forall value, watwg_all_adjacent relation [value]
| watwg_adjacent_cons :
    forall first second rest,
      relation first second ->
      watwg_all_adjacent relation (second :: rest) ->
      watwg_all_adjacent relation (first :: second :: rest).

Lemma action_table_blocks_unchanged_refl :
  forall protected_blocks memory,
    ActionTableBlocksUnchanged protected_blocks memory memory.
Proof.
  intros. apply Mem.unchanged_on_refl.
Qed.

Lemma action_table_blocks_unchanged_trans :
  forall protected_blocks first middle last,
    ActionTableBlocksUnchanged protected_blocks first middle ->
    ActionTableBlocksUnchanged protected_blocks middle last ->
    ActionTableBlocksUnchanged protected_blocks first last.
Proof.
  intros. eapply Mem.unchanged_on_trans; eauto.
Qed.

Lemma action_table_frame_preserves_every_load :
  forall protected_blocks before after protected_block
      chunk offset value,
    ActionTableBlocksUnchanged protected_blocks before after ->
    In protected_block protected_blocks ->
    Mem.load chunk before protected_block offset = Some value ->
    Mem.load chunk after protected_block offset = Some value.
Proof.
  intros protected_blocks before after protected_block chunk offset value
    Hunchanged Hin Hload.
  eapply Mem.load_unchanged_on; eauto.
Qed.

Lemma self_injected_store_preserves_every_private_table_load :
  forall injection protected_blocks protected_block
      store_block store_offset stored_chunk stored_value before after
      loaded_chunk loaded_offset,
    (forall block,
      In block protected_blocks -> injection block = None) ->
    In protected_block protected_blocks ->
    Val.inject injection (Vptr store_block (Ptrofs.repr store_offset))
      (Vptr store_block (Ptrofs.repr store_offset)) ->
    Mem.store stored_chunk before store_block store_offset stored_value =
      Some after ->
    Mem.load loaded_chunk after protected_block loaded_offset =
      Mem.load loaded_chunk before protected_block loaded_offset.
Proof.
  intros injection protected_blocks protected_block store_block store_offset
    stored_chunk stored_value before after loaded_chunk loaded_offset
    Homitted Hin Hinjected Hstore.
  eapply Mem.load_store_other; [exact Hstore |].
  left. intro Hequal. subst store_block.
  eapply (self_injected_value_is_not_a_private_pointer
    injection (Vptr protected_block (Ptrofs.repr store_offset))
    protected_blocks protected_block (Ptrofs.repr store_offset)); eauto.
Qed.

(** If a purported area/level transition changes a table byte, it is exactly
    the first step that is not covered by the private frame.  This theorem is
    intentionally data-bearing: it returns the adjacent memories rather than
    replacing the failed induction with an existential "alias" assumption. *)
Theorem finite_memory_timeline_preserves_tables_or_exposes_first_failure :
  forall protected_blocks memories,
    memories <> [] ->
    (watwg_all_adjacent (ActionTableBlocksUnchanged protected_blocks)
       memories \/
     exists prefix before after suffix,
       memories = prefix ++ before :: after :: suffix /\
       watwg_all_adjacent (ActionTableBlocksUnchanged protected_blocks)
         (prefix ++ [before]) /\
       ~ ActionTableBlocksUnchanged protected_blocks before after).
Proof.
  intros protected_blocks memories Hnonempty.
  induction memories as [| first rest IH].
  - contradiction.
  - destruct rest as [| second tail].
    + left. constructor.
    + destruct (classic
        (ActionTableBlocksUnchanged protected_blocks first second)) as
        [Hstep | Hstep].
      * assert (Htail_nonempty : second :: tail <> []) by discriminate.
        specialize (IH Htail_nonempty).
        destruct IH as [Hall | Hfailure].
        -- left. now constructor.
        -- right.
           destruct Hfailure as
             (prefix & before & after & suffix & Heq & Hprefix & Hbad).
           exists (first :: prefix), before, after, suffix.
           split.
           ++ cbn. now rewrite Heq.
           ++ split.
              ** destruct prefix as [| prefix_head prefix_tail].
                 --- cbn in Heq, Hprefix |- *.
                     inversion Heq; subst before.
                     constructor; [exact Hstep | constructor].
                 --- cbn in Heq, Hprefix |- *.
                     inversion Heq; subst prefix_head.
                     constructor; [exact Hstep | exact Hprefix].
              ** exact Hbad.
      * right. exists [], first, second, tail.
        split; [reflexivity |].
        split; [constructor | exact Hstep].
Qed.

Definition WritableActionTableWholeGameAliasBoundary : Prop :=
  WritableActionTableWholeGameAliasCensus /\
  (forall version,
    exists blocks, LinkedSourceActionTableBlocks version blocks) /\
  (forall version memory blocks,
    Genv.init_mem (selected_clight_source version) = Some memory ->
    LinkedSourceActionTableBlocks version blocks ->
    forall protected_block,
      In protected_block blocks -> Mem.valid_block memory protected_block) /\
  (forall protected_blocks before after protected_block
      store_block store_offset stored_chunk stored_value loaded_chunk
      loaded_offset injection,
    (forall block,
      In block protected_blocks -> injection block = None) ->
    In protected_block protected_blocks ->
    Val.inject injection (Vptr store_block (Ptrofs.repr store_offset))
      (Vptr store_block (Ptrofs.repr store_offset)) ->
    Mem.store stored_chunk before store_block store_offset stored_value =
      Some after ->
    Mem.load loaded_chunk after protected_block loaded_offset =
      Mem.load loaded_chunk before protected_block loaded_offset).

Theorem writable_action_table_whole_game_alias_boundary_holds :
  WritableActionTableWholeGameAliasBoundary.
Proof.
  split.
  - exact writable_action_table_whole_game_alias_census_holds.
  - split.
    + exact linked_source_action_table_blocks_exist.
    + split.
      * exact linked_source_action_table_blocks_are_valid_at_initialization.
      * intros. eapply self_injected_store_preserves_every_private_table_load;
          eauto.
Qed.
