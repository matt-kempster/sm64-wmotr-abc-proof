(** Faithful indirect-dispatch and byte-overlap closure for timer-131 Ink.

    The ordinary Mario callback graph contains exactly two indirect calls:
    [common_landing_cancels] calls the callback supplied by its landing
    wrapper, and [mario_process_interactions] calls an entry from
    [sInteractionHandlers].  This file resolves both stock target sets and
    recomputes the complete direct closure from those targets.  The enlarged
    graph still contains neither dangerous object-tail writer.

    This is deliberately not a forged-memory theorem.  The interaction table
    is writable, the landing callback value must still be evaluated from live
    memory, and an external or aliased store can evade a named-call graph.
    The final memory lemmas make the alias boundary byte-precise: a defined
    CompCert store can change either dangerous cell only in the Mario object
    block and only by overlapping that cell's four bytes. *)

From Coq Require Import Bool Lia List String ZArith.
From compcert Require Import
  AST Clight Coqlib Ctypes Integers Memory Values export.Ctypesdefs.
From LessThanOneAPress.Generated Require Import
  us_behavior_data us_interaction us_mario_actions_moving
  us_object_helpers us_spawn_object
  jp_behavior_data jp_interaction jp_mario_actions_moving
  jp_object_helpers jp_spawn_object.
From LessThanOneAPress.Proofs Require Import
  ActionDepthAliasCensus Area1WarpTopCloneCensus ASTFacts
  ClightFacts ClightRefinement EntryMemory
  InkTimer131MarioTailClosure LongJumpProvenanceBoundary
  NegativeDepthForgeryBoundary OrdinaryArea1EntryMemory RetailExternalFrames.

Import ListNotations.
Local Open Scope Z_scope.
Local Open Scope string_scope.

Module ITIA_USD := us_behavior_data.
Module ITIA_USI := us_interaction.
Module ITIA_USM := us_mario_actions_moving.
Module ITIA_USH := us_object_helpers.
Module ITIA_USS := us_spawn_object.
Module ITIA_JPD := jp_behavior_data.
Module ITIA_JPI := jp_interaction.
Module ITIA_JPM := jp_mario_actions_moving.
Module ITIA_JPH := jp_object_helpers.
Module ITIA_JPS := jp_spawn_object.

(** Collect the third, function-valued argument supplied to a direct
    three-argument call.  For [common_landing_cancels], this is exactly the
    callback later invoked under [INPUT_A_PRESSED]. *)
Fixpoint ink_third_callback_arguments_s
    (callee : ident) (body : statement) : list ident :=
  match body with
  | Scall _ (Evar found_callee _) [_; _; Evar callback _] =>
      if Pos.eqb found_callee callee then [callback] else []
  | Ssequence first second | Sloop first second =>
      ink_third_callback_arguments_s callee first ++
      ink_third_callback_arguments_s callee second
  | Sifthenelse _ yes no =>
      ink_third_callback_arguments_s callee yes ++
      ink_third_callback_arguments_s callee no
  | Sswitch _ cases => ink_third_callback_arguments_ls callee cases
  | Slabel _ nested => ink_third_callback_arguments_s callee nested
  | _ => []
  end
with ink_third_callback_arguments_ls
    (callee : ident) (cases : labeled_statements) : list ident :=
  match cases with
  | LSnil => []
  | LScons _ body rest =>
      ink_third_callback_arguments_s callee body ++
      ink_third_callback_arguments_ls callee rest
  end.

Fixpoint ink_third_callback_arguments
    (callee : ident)
    (definitions : list (ident * globdef (fundef function) type)) : list ident :=
  match definitions with
  | [] => []
  | (_, Gfun (Internal body)) :: rest =>
      ink_third_callback_arguments_s callee (fn_body body) ++
      ink_third_callback_arguments callee rest
  | _ :: rest => ink_third_callback_arguments callee rest
  end.

Definition ink_expected_us_landing_callbacks : list ident :=
  [ITIA_USM._set_jumping_action; ITIA_USM._set_jumping_action;
   ITIA_USM._set_jumping_action; ITIA_USM._set_jumping_action;
   ITIA_USM._set_jumping_action; ITIA_USM._set_jumping_action;
   ITIA_USM._set_triple_jump_action; ITIA_USM._set_jumping_action;
   ITIA_USM._set_jumping_action].

Definition ink_expected_jp_landing_callbacks : list ident :=
  [ITIA_JPM._set_jumping_action; ITIA_JPM._set_jumping_action;
   ITIA_JPM._set_jumping_action; ITIA_JPM._set_jumping_action;
   ITIA_JPM._set_jumping_action; ITIA_JPM._set_jumping_action;
   ITIA_JPM._set_triple_jump_action; ITIA_JPM._set_jumping_action;
   ITIA_JPM._set_jumping_action].

Theorem ink_landing_callback_arguments_are_exact_bilateral :
  ink_third_callback_arguments ITIA_USM._common_landing_cancels
      ink_us_definitions = ink_expected_us_landing_callbacks /\
  ink_third_callback_arguments ITIA_JPM._common_landing_cancels
      ink_jp_definitions = ink_expected_jp_landing_callbacks /\
  nodup Pos.eq_dec ink_expected_us_landing_callbacks =
    [ITIA_USM._set_triple_jump_action; ITIA_USM._set_jumping_action] /\
  nodup Pos.eq_dec ink_expected_jp_landing_callbacks =
    [ITIA_JPM._set_triple_jump_action; ITIA_JPM._set_jumping_action].
Proof.
  unfold ink_us_definitions, ink_jp_definitions,
    ink_expected_us_landing_callbacks, ink_expected_jp_landing_callbacks.
  vm_compute. repeat split; reflexivity.
Qed.

(** Count every function-valued call in the selected closure, not merely
    calls which visibly receive a [MarioState *]. *)
Fixpoint ink_internal_indirect_sites_in_closure
    (definitions : list (ident * globdef (fundef function) type))
    (closure : list ident) : list (ident * nat) :=
  match definitions with
  | [] => []
  | (id, Gfun (Internal body)) :: rest =>
      let count := direct_indirect_call_count_statement (fn_body body) in
      (if ink_ident_in id closure && negb (Nat.eqb count 0)
       then (id, count) ::
         ink_internal_indirect_sites_in_closure rest closure
       else ink_internal_indirect_sites_in_closure rest closure)
  | _ :: rest => ink_internal_indirect_sites_in_closure rest closure
  end.

(** Select unresolved direct callees which are handed a pointer to a chosen
    struct by a caller in the resolved closure.  Interior pointers and global
    access are deliberately outside this typed handoff recognizer. *)
Fixpoint ink_unresolved_struct_callees_in_closure
    (tag : ident)
    (all_definitions remaining :
      list (ident * globdef (fundef function) type))
    (closure : list ident) : list ident :=
  match remaining with
  | [] => []
  | (caller, Gfun (Internal body)) :: rest =>
      (if ink_ident_in caller closure
       then filter
         (fun callee =>
            negb (identifier_occurs callee
              (internal_function_identifiers all_definitions)))
         (direct_struct_pointer_callees_s tag (fn_body body))
       else []) ++
      ink_unresolved_struct_callees_in_closure
        tag all_definitions rest closure
  | _ :: rest =>
      ink_unresolved_struct_callees_in_closure
        tag all_definitions rest closure
  end.

Definition ink_us_resolved_indirect_roots : list ident :=
  ink_mario_callback_roots ++ ndf_expected_interaction_handlers ++
  [ITIA_USM._set_jumping_action; ITIA_USM._set_triple_jump_action].

Definition ink_jp_resolved_indirect_roots : list ident :=
  ink_mario_callback_roots ++ ndf_expected_interaction_handlers ++
  [ITIA_JPM._set_jumping_action; ITIA_JPM._set_triple_jump_action].

Definition ink_us_resolved_indirect_closure : list ident :=
  ink_direct_call_closure 8 ink_us_definitions
    ink_us_resolved_indirect_roots [].

Definition ink_jp_resolved_indirect_closure : list ident :=
  ink_direct_call_closure 8 ink_jp_definitions
    ink_jp_resolved_indirect_roots [].

Definition ink_expected_us_indirect_sites : list (ident * nat) :=
  [(ITIA_USM._common_landing_cancels, 1%nat);
   (ITIA_USI._mario_process_interactions, 1%nat)].

Definition ink_expected_jp_indirect_sites : list (ident * nat) :=
  [(ITIA_JPM._common_landing_cancels, 1%nat);
   (ITIA_JPI._mario_process_interactions, 1%nat)].

(** The full behavior initializer is included so that "faithful stock
    behavior" has an exact meaning.  In particular it has no opcode 29
    ([DEACTIVATE]), no command for raw slot 21, and only the already-audited
    [OR_INT] at raw slot 1. *)
Definition ink_expected_us_bhv_mario : list init_data :=
  [Init_int32 (Int.repr 0); Init_int32 (Int.repr 268763136);
   Init_int32 (Int.repr 285278464); Init_int32 (Int.repr 285409281);
   Init_int32 (Int.repr 587202560); Init_int32 (Int.repr 2424992);
   Init_int32 (Int.repr 134217728); Init_int32 (Int.repr 201326592);
   Init_addrof ITIA_USD._try_print_debug_mario_level_info (Ptrofs.repr 0);
   Init_int32 (Int.repr 201326592);
   Init_addrof ITIA_USD._bhv_mario_update (Ptrofs.repr 0);
   Init_int32 (Int.repr 201326592);
   Init_addrof ITIA_USD._try_do_mario_debug_object_spawn (Ptrofs.repr 0);
   Init_int32 (Int.repr 150994944)].

Definition ink_expected_jp_bhv_mario : list init_data :=
  [Init_int32 (Int.repr 0); Init_int32 (Int.repr 268763136);
   Init_int32 (Int.repr 285278464); Init_int32 (Int.repr 285409281);
   Init_int32 (Int.repr 587202560); Init_int32 (Int.repr 2424992);
   Init_int32 (Int.repr 134217728); Init_int32 (Int.repr 201326592);
   Init_addrof ITIA_JPD._try_print_debug_mario_level_info (Ptrofs.repr 0);
   Init_int32 (Int.repr 201326592);
   Init_addrof ITIA_JPD._bhv_mario_update (Ptrofs.repr 0);
   Init_int32 (Int.repr 201326592);
   Init_addrof ITIA_JPD._try_do_mario_debug_object_spawn (Ptrofs.repr 0);
   Init_int32 (Int.repr 150994944)].

(** These generic lifecycle functions remain reachable because object
    allocation may evict an unimportant object.  This exact positive result
    is why receiver/slot identity cannot be replaced by a name-only census. *)
Definition ink_lifecycle_function_names : list string :=
  ["clear_objects"; "unload_object"; "deallocate_object";
   "mark_obj_for_deletion"; "bhv_cmd_deactivate"].

Definition ink_lifecycle_functions : list ident :=
  map ident_of_string ink_lifecycle_function_names.

Definition ink_interaction_table_source_claim : Prop :=
  ndf_addrof_initializers
      (gvar_init NDF_USInteraction.v_sInteractionHandlers) =
    ndf_expected_interaction_handlers /\
  ndf_addrof_initializers
      (gvar_init NDF_JPInteraction.v_sInteractionHandlers) =
    ndf_expected_interaction_handlers /\
  gvar_readonly NDF_USInteraction.v_sInteractionHandlers = false /\
  gvar_readonly NDF_JPInteraction.v_sInteractionHandlers = false /\
  internal_function_assignment_sites
      NDF_USInteraction._sInteractionHandlers us_generated_definitions = [] /\
  internal_function_assignment_sites
      NDF_JPInteraction._sInteractionHandlers
      jp_generated_definitions_for_alias = [].

Definition ink_two_indirect_site_source_claim : Prop :=
  internal_indirect_struct_pointer_call_sites
      AD_USMario._MarioState us_generated_definitions =
    [AD_USMove._common_landing_cancels;
     AD_USInteraction._mario_process_interactions] /\
  internal_indirect_struct_pointer_call_sites
      AD_JPMario._MarioState jp_generated_definitions_for_alias =
    [AD_JPMove._common_landing_cancels;
     AD_JPInteraction._mario_process_interactions] /\
  contains_field_mask_guarded_indirect_struct_pointer_call_s
      AD_USMove._input 2 AD_USMario._MarioState
      (fn_body AD_USMove.f_common_landing_cancels) = true /\
  contains_field_mask_guarded_indirect_struct_pointer_call_s
      AD_JPMove._input 2 AD_JPMario._MarioState
      (fn_body AD_JPMove.f_common_landing_cancels) = true.

Definition ink_us_resolved_closure_claim : Prop :=
  ink_call_closure_closedb ink_us_definitions
    ink_us_resolved_indirect_closure = true /\
  List.length ink_us_resolved_indirect_closure = 664%nat /\
  ink_internal_indirect_sites_in_closure ink_us_definitions
    ink_us_resolved_indirect_closure = ink_expected_us_indirect_sites /\
  map (fun id => ink_ident_in id ink_us_resolved_indirect_closure)
    ink_lifecycle_functions = [false; true; true; false; false].

Definition ink_jp_resolved_closure_claim : Prop :=
  ink_call_closure_closedb ink_jp_definitions
    ink_jp_resolved_indirect_closure = true /\
  List.length ink_jp_resolved_indirect_closure = 661%nat /\
  ink_internal_indirect_sites_in_closure ink_jp_definitions
    ink_jp_resolved_indirect_closure = ink_expected_jp_indirect_sites /\
  map (fun id => ink_ident_in id ink_jp_resolved_indirect_closure)
    ink_lifecycle_functions = [false; true; true; false; false].

Definition ink_us_resolved_writer_claim : Prop :=
  ink_writer_intersection ink_us_resolved_indirect_closure
    ink_us_any_view_flag_storage_writers = [] /\
  ink_writer_intersection ink_us_resolved_indirect_closure
    ink_us_any_view_offset_storage_writers = [].

Definition ink_jp_resolved_writer_claim : Prop :=
  ink_writer_intersection ink_jp_resolved_indirect_closure
    ink_jp_any_view_flag_storage_writers = [] /\
  ink_writer_intersection ink_jp_resolved_indirect_closure
    ink_jp_any_view_offset_storage_writers = [].

Theorem ink_us_resolved_closure_is_closed :
  ink_call_closure_closedb ink_us_definitions
    ink_us_resolved_indirect_closure = true.
Proof.
  unfold ink_us_resolved_indirect_closure, ink_us_resolved_indirect_roots,
    ink_us_definitions, ink_mario_callback_roots.
  vm_compute. reflexivity.
Qed.

Theorem ink_us_resolved_closure_length :
  List.length ink_us_resolved_indirect_closure = 664%nat.
Proof.
  unfold ink_us_resolved_indirect_closure, ink_us_resolved_indirect_roots,
    ink_us_definitions, ink_mario_callback_roots.
  vm_compute. reflexivity.
Qed.

Theorem ink_us_resolved_indirect_sites_are_exact :
  ink_internal_indirect_sites_in_closure ink_us_definitions
    ink_us_resolved_indirect_closure = ink_expected_us_indirect_sites.
Proof.
  unfold ink_us_resolved_indirect_closure, ink_us_resolved_indirect_roots,
    ink_expected_us_indirect_sites, ink_us_definitions,
    ink_mario_callback_roots.
  vm_compute. reflexivity.
Qed.

Theorem ink_us_resolved_lifecycle_name_membership :
  map (fun id => ink_ident_in id ink_us_resolved_indirect_closure)
    ink_lifecycle_functions = [false; true; true; false; false].
Proof.
  unfold ink_us_resolved_indirect_closure, ink_us_resolved_indirect_roots,
    ink_lifecycle_functions, ink_lifecycle_function_names,
    ink_us_definitions, ink_mario_callback_roots.
  vm_compute. reflexivity.
Qed.

Theorem ink_us_resolved_closure_checked : ink_us_resolved_closure_claim.
Proof.
  unfold ink_us_resolved_closure_claim.
  split; [exact ink_us_resolved_closure_is_closed |].
  split; [exact ink_us_resolved_closure_length |].
  split; [exact ink_us_resolved_indirect_sites_are_exact |].
  exact ink_us_resolved_lifecycle_name_membership.
Qed.

Theorem ink_jp_resolved_closure_is_closed :
  ink_call_closure_closedb ink_jp_definitions
    ink_jp_resolved_indirect_closure = true.
Proof.
  unfold ink_jp_resolved_indirect_closure, ink_jp_resolved_indirect_roots,
    ink_jp_definitions, ink_mario_callback_roots.
  vm_compute. reflexivity.
Qed.

Theorem ink_jp_resolved_closure_length :
  List.length ink_jp_resolved_indirect_closure = 661%nat.
Proof.
  unfold ink_jp_resolved_indirect_closure, ink_jp_resolved_indirect_roots,
    ink_jp_definitions, ink_mario_callback_roots.
  vm_compute. reflexivity.
Qed.

Theorem ink_jp_resolved_indirect_sites_are_exact :
  ink_internal_indirect_sites_in_closure ink_jp_definitions
    ink_jp_resolved_indirect_closure = ink_expected_jp_indirect_sites.
Proof.
  unfold ink_jp_resolved_indirect_closure, ink_jp_resolved_indirect_roots,
    ink_expected_jp_indirect_sites, ink_jp_definitions,
    ink_mario_callback_roots.
  vm_compute. reflexivity.
Qed.

Theorem ink_jp_resolved_lifecycle_name_membership :
  map (fun id => ink_ident_in id ink_jp_resolved_indirect_closure)
    ink_lifecycle_functions = [false; true; true; false; false].
Proof.
  unfold ink_jp_resolved_indirect_closure, ink_jp_resolved_indirect_roots,
    ink_lifecycle_functions, ink_lifecycle_function_names,
    ink_jp_definitions, ink_mario_callback_roots.
  vm_compute. reflexivity.
Qed.

Theorem ink_jp_resolved_closure_checked : ink_jp_resolved_closure_claim.
Proof.
  unfold ink_jp_resolved_closure_claim.
  split; [exact ink_jp_resolved_closure_is_closed |].
  split; [exact ink_jp_resolved_closure_length |].
  split; [exact ink_jp_resolved_indirect_sites_are_exact |].
  exact ink_jp_resolved_lifecycle_name_membership.
Qed.

Theorem ink_us_resolved_writer_checked : ink_us_resolved_writer_claim.
Proof.
  unfold ink_us_resolved_writer_claim,
    ink_us_resolved_indirect_closure, ink_us_resolved_indirect_roots,
    ink_us_any_view_flag_storage_writers,
    ink_us_any_view_offset_storage_writers,
    ink_us_definitions, ink_mario_callback_roots.
  vm_compute. split; reflexivity.
Qed.

Theorem ink_jp_resolved_writer_checked : ink_jp_resolved_writer_claim.
Proof.
  unfold ink_jp_resolved_writer_claim,
    ink_jp_resolved_indirect_closure, ink_jp_resolved_indirect_roots,
    ink_jp_any_view_flag_storage_writers,
    ink_jp_any_view_offset_storage_writers,
    ink_jp_definitions, ink_mario_callback_roots.
  vm_compute. split; reflexivity.
Qed.

Theorem ink_full_bhv_mario_initializer_is_exact_bilateral :
  gvar_init ITIA_USD.v_bhvMario = ink_expected_us_bhv_mario /\
  gvar_init ITIA_JPD.v_bhvMario = ink_expected_jp_bhv_mario.
Proof.
  unfold ink_expected_us_bhv_mario, ink_expected_jp_bhv_mario.
  vm_compute. split; reflexivity.
Qed.

(** The enlarged closure contains one direct [Object.behavior] writer:
    ordinary [create_object] initialization.  Neither behavior-mutation helper
    nor the area-load respawn writer is reachable from these callback roots,
    and no generated body takes the address of the field.  This does not prove
    that the constructor argument or live command table is uncorrupted. *)
Definition ink_behavior_pointer_writer_source_claim : Prop :=
  ink_writer_intersection ink_us_resolved_indirect_closure
    (internal_object_field_assignment_sites
      CUSO._Object CUSO._behavior us_source_definitions) =
      [ITIA_USS._create_object] /\
  ink_writer_intersection ink_jp_resolved_indirect_closure
    (internal_object_field_assignment_sites
      CJSO._Object CJSO._behavior jp_source_definitions) =
      [ITIA_JPS._create_object] /\
  internal_field_address_sites CUSO._behavior us_source_definitions = [] /\
  internal_field_address_sites CJSO._behavior jp_source_definitions = [].

Theorem ink_us_resolved_behavior_writer_is_constructor :
  ink_writer_intersection ink_us_resolved_indirect_closure
    (internal_object_field_assignment_sites
      CUSO._Object CUSO._behavior us_source_definitions) =
      [ITIA_USS._create_object].
Proof.
  unfold ink_us_resolved_indirect_closure,
    ink_us_resolved_indirect_roots, ink_us_definitions,
    ink_mario_callback_roots, us_source_definitions,
    internal_object_field_assignment_sites.
  vm_compute. reflexivity.
Qed.

Theorem ink_jp_resolved_behavior_writer_is_constructor :
  ink_writer_intersection ink_jp_resolved_indirect_closure
    (internal_object_field_assignment_sites
      CJSO._Object CJSO._behavior jp_source_definitions) =
      [ITIA_JPS._create_object].
Proof.
  unfold ink_jp_resolved_indirect_closure,
    ink_jp_resolved_indirect_roots, ink_jp_definitions,
    ink_mario_callback_roots, jp_source_definitions,
    internal_object_field_assignment_sites.
  vm_compute. reflexivity.
Qed.

Theorem ink_us_behavior_field_address_is_never_taken :
  internal_field_address_sites CUSO._behavior us_source_definitions = [].
Proof.
  unfold us_source_definitions, internal_field_address_sites.
  vm_compute. reflexivity.
Qed.

Theorem ink_jp_behavior_field_address_is_never_taken :
  internal_field_address_sites CJSO._behavior jp_source_definitions = [].
Proof.
  unfold jp_source_definitions, internal_field_address_sites.
  vm_compute. reflexivity.
Qed.

Theorem ink_behavior_pointer_writer_source_checked :
  ink_behavior_pointer_writer_source_claim.
Proof.
  unfold ink_behavior_pointer_writer_source_claim.
  split; [exact ink_us_resolved_behavior_writer_is_constructor |].
  split; [exact ink_jp_resolved_behavior_writer_is_constructor |].
  split; [exact ink_us_behavior_field_address_is_never_taken |].
  exact ink_jp_behavior_field_address_is_never_taken.
Qed.

Definition ink_resolved_indirect_source_claim : Prop :=
  ink_interaction_table_source_claim /\
  ink_two_indirect_site_source_claim /\
  ink_call_closure_closedb ink_us_definitions
    ink_us_resolved_indirect_closure = true /\
  ink_call_closure_closedb ink_jp_definitions
    ink_jp_resolved_indirect_closure = true /\
  List.length ink_us_resolved_indirect_closure = 664%nat /\
  List.length ink_jp_resolved_indirect_closure = 661%nat /\
  ink_internal_indirect_sites_in_closure ink_us_definitions
    ink_us_resolved_indirect_closure = ink_expected_us_indirect_sites /\
  ink_internal_indirect_sites_in_closure ink_jp_definitions
    ink_jp_resolved_indirect_closure = ink_expected_jp_indirect_sites /\
  ink_writer_intersection ink_us_resolved_indirect_closure
    ink_us_any_view_flag_storage_writers = [] /\
  ink_writer_intersection ink_jp_resolved_indirect_closure
    ink_jp_any_view_flag_storage_writers = [] /\
  ink_writer_intersection ink_us_resolved_indirect_closure
    ink_us_any_view_offset_storage_writers = [] /\
  ink_writer_intersection ink_jp_resolved_indirect_closure
    ink_jp_any_view_offset_storage_writers = [] /\
  map (fun id => ink_ident_in id ink_us_resolved_indirect_closure)
    ink_lifecycle_functions = [false; true; true; false; false] /\
  map (fun id => ink_ident_in id ink_jp_resolved_indirect_closure)
    ink_lifecycle_functions = [false; true; true; false; false] /\
  gvar_init ITIA_USD.v_bhvMario = ink_expected_us_bhv_mario /\
  gvar_init ITIA_JPD.v_bhvMario = ink_expected_jp_bhv_mario.

Theorem ink_resolved_indirect_source_checked :
  ink_resolved_indirect_source_claim.
Proof.
  unfold ink_resolved_indirect_source_claim.
  split.
  { exact interaction_handler_table_initializer_is_exact_bilateral. }
  split;
    [exact indirect_mario_state_calls_are_guarded_landing_or_interaction_table |].
  pose proof ink_us_resolved_closure_checked as Hus.
  pose proof ink_jp_resolved_closure_checked as Hjp.
  pose proof ink_us_resolved_writer_checked as Huswriters.
  pose proof ink_jp_resolved_writer_checked as Hjpwriters.
  pose proof ink_full_bhv_mario_initializer_is_exact_bilateral as Hbehavior.
  unfold ink_us_resolved_closure_claim in Hus.
  unfold ink_jp_resolved_closure_claim in Hjp.
  unfold ink_us_resolved_writer_claim in Huswriters.
  unfold ink_jp_resolved_writer_claim in Hjpwriters.
  destruct Hus as [Husclosed [Huslength [Husindirect Huslifecycle]]].
  destruct Hjp as [Hjpclosed [Hjplength [Hjpindirect Hjplifecycle]]].
  destruct Huswriters as [Husflag Husoffset].
  destruct Hjpwriters as [Hjpflag Hjpoffset].
  destruct Hbehavior as [Husbehavior Hjpbehavior].
  split; [exact Husclosed |].
  split; [exact Hjpclosed |].
  split; [exact Huslength |].
  split; [exact Hjplength |].
  split; [exact Husindirect |].
  split; [exact Hjpindirect |].
  split; [exact Husflag |].
  split; [exact Hjpflag |].
  split; [exact Husoffset |].
  split; [exact Hjpoffset |].
  split; [exact Huslifecycle |].
  split; [exact Hjplifecycle |].
  split; [exact Husbehavior |].
  exact Hjpbehavior.
Qed.

Definition ink_external_struct_pointer_handoff_claim : Prop :=
  ink_unresolved_struct_callees_in_closure
      AD_USMario._Object ink_us_definitions ink_us_definitions
      ink_us_resolved_indirect_closure = [] /\
  ink_unresolved_struct_callees_in_closure
      AD_JPMario._Object ink_jp_definitions ink_jp_definitions
      ink_jp_resolved_indirect_closure = [] /\
  unresolved_direct_struct_pointer_callees
      AD_USMario._MarioState us_generated_definitions = [] /\
  unresolved_direct_struct_pointer_callees
      AD_JPMario._MarioState jp_generated_definitions_for_alias = [] /\
  internal_builtin_struct_pointer_sites
      AD_USMario._MarioState us_generated_definitions = [] /\
  internal_builtin_struct_pointer_sites
      AD_JPMario._MarioState jp_generated_definitions_for_alias = [] /\
  internal_builtin_struct_pointer_sites
      AD_USMario._Object us_generated_definitions = [] /\
  internal_builtin_struct_pointer_sites
      AD_JPMario._Object jp_generated_definitions_for_alias = [].

Theorem ink_external_struct_pointer_handoff_checked :
  ink_external_struct_pointer_handoff_claim.
Proof.
  unfold ink_external_struct_pointer_handoff_claim.
  split.
  { unfold ink_us_resolved_indirect_closure,
      ink_us_resolved_indirect_roots, ink_us_definitions,
      ink_mario_callback_roots.
    vm_compute. reflexivity. }
  split.
  { unfold ink_jp_resolved_indirect_closure,
      ink_jp_resolved_indirect_roots, ink_jp_definitions,
      ink_mario_callback_roots.
    vm_compute. reflexivity. }
  pose proof
    us_jp_no_unresolved_direct_or_builtin_mario_state_pointer_handoff
    as Hstate.
  destruct Hstate as [Husdirect [Hjpdirect [Husbuiltin Hjpbuiltin]]].
  split; [exact Husdirect |].
  split; [exact Hjpdirect |].
  split; [exact Husbuiltin |].
  split; [exact Hjpbuiltin |].
  split; vm_compute; reflexivity.
Qed.

(** * Pool-eviction receiver and slot boundary *)

(** Match the complete small body of [find_unimportant_object].  This is
    intentionally stronger than merely finding the literal [12]: it couples
    [gObjectLists + 12], that list head's [next] field, the empty-list NULL
    case, and the returned pointer. *)
Definition is_find_unimportant_object_body_s
    (object_lists next_field : ident) (list_index : Z)
    (body : statement) : bool :=
  match body with
  | Ssequence
      (Ssequence
        (Sset global_temp (Evar found_lists _))
        (Sset head_temp
          (Ebinop Oadd (Etempvar used_global_temp _)
            (Econst_int index_word _) _)))
      (Ssequence
        (Sset object_temp
          (Efield (Ederef (Etempvar used_head_temp _) _) found_next _))
        (Ssequence
          (Sifthenelse
            (Ebinop Oeq (Etempvar compared_head_temp _)
              (Etempvar compared_object_temp _) _)
            (Sset nulled_object_temp
              (Ecast (Econst_int zero_word _) _))
            Sskip)
          (Sreturn (Some
            (Ecast (Etempvar returned_object_temp _) _))))) =>
      andb (Pos.eqb found_lists object_lists)
      (andb (Pos.eqb global_temp used_global_temp)
      (andb (Int.eq index_word (Int.repr list_index))
      (andb (Pos.eqb head_temp used_head_temp)
      (andb (Pos.eqb found_next next_field)
      (andb (Pos.eqb head_temp compared_head_temp)
      (andb (Pos.eqb object_temp compared_object_temp)
      (andb (Pos.eqb object_temp nulled_object_temp)
      (andb (Int.eq zero_word Int.zero)
             (Pos.eqb object_temp returned_object_temp)))))))))
  | _ => false
  end.

Fixpoint temp_set_count_s
    (target : ident) (body : statement) : nat :=
  match body with
  | Sset found _ => if Pos.eqb found target then 1%nat else 0%nat
  | Ssequence first second | Sloop first second =>
      (temp_set_count_s target first + temp_set_count_s target second)%nat
  | Sifthenelse _ yes no =>
      (temp_set_count_s target yes + temp_set_count_s target no)%nat
  | Sswitch _ cases => temp_set_count_ls target cases
  | Slabel _ nested => temp_set_count_s target nested
  | _ => 0%nat
  end
with temp_set_count_ls
    (target : ident) (cases : labeled_statements) : nat :=
  match cases with
  | LSnil => 0%nat
  | LScons _ body rest =>
      (temp_set_count_s target body + temp_set_count_ls target rest)%nat
  end.

Fixpoint contains_unary_temp_call_s
    (callee argument : ident) (body : statement) : bool :=
  match body with
  | Scall _ (Evar found_callee _) [Etempvar found_argument _] =>
      andb (Pos.eqb found_callee callee)
        (Pos.eqb found_argument argument)
  | Ssequence first second | Sloop first second =>
      orb (contains_unary_temp_call_s callee argument first)
        (contains_unary_temp_call_s callee argument second)
  | Sifthenelse _ yes no =>
      orb (contains_unary_temp_call_s callee argument yes)
        (contains_unary_temp_call_s callee argument no)
  | Sswitch _ cases => contains_unary_temp_call_ls callee argument cases
  | Slabel _ nested => contains_unary_temp_call_s callee argument nested
  | _ => false
  end
with contains_unary_temp_call_ls
    (callee argument : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      orb (contains_unary_temp_call_s callee argument body)
        (contains_unary_temp_call_ls callee argument rest)
  end.

Definition find_result_object_temp
    (finder : ident) (body : statement) : option ident :=
  match body with
  | Ssequence
      (Scall (Some result_temp) (Evar found_finder _) [])
      (Sset object_temp (Etempvar copied_result_temp _)) =>
      if andb (Pos.eqb found_finder finder)
           (Pos.eqb result_temp copied_result_temp)
      then Some object_temp else None
  | _ => None
  end.

Fixpoint contains_stable_find_result_to_unload_s
    (finder unload : ident) (body : statement) : bool :=
  match body with
  | Ssequence first continuation =>
      let here :=
        match find_result_object_temp finder first with
        | Some object_temp =>
            andb (contains_unary_temp_call_s unload object_temp continuation)
              (Nat.eqb (temp_set_count_s object_temp continuation) 0)
        | None => false
        end in
      orb here
        (orb (contains_stable_find_result_to_unload_s finder unload first)
             (contains_stable_find_result_to_unload_s
               finder unload continuation))
  | Sloop first second =>
      orb (contains_stable_find_result_to_unload_s finder unload first)
        (contains_stable_find_result_to_unload_s finder unload second)
  | Sifthenelse _ yes no =>
      orb (contains_stable_find_result_to_unload_s finder unload yes)
        (contains_stable_find_result_to_unload_s finder unload no)
  | Sswitch _ cases =>
      contains_stable_find_result_to_unload_ls finder unload cases
  | Slabel _ nested =>
      contains_stable_find_result_to_unload_s finder unload nested
  | _ => false
  end
with contains_stable_find_result_to_unload_ls
    (finder unload : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      orb (contains_stable_find_result_to_unload_s finder unload body)
        (contains_stable_find_result_to_unload_ls finder unload rest)
  end.

Definition behavior_begin_list_index (initializer : list init_data)
    : option Z :=
  match initializer with
  | Init_int32 word :: _ =>
      if Z.eqb (Z.land (Z.shiftr (Int.unsigned word) 24) 255) 0
      then Some (Z.land (Z.shiftr (Int.unsigned word) 16) 65535)
      else None
  | _ => None
  end.

Definition ink_pool_eviction_source_claim : Prop :=
  is_find_unimportant_object_body_s
    ITIA_USH._gObjectLists ITIA_USH._next 12
    (fn_body ITIA_USH.f_find_unimportant_object) = true /\
  is_find_unimportant_object_body_s
    ITIA_JPH._gObjectLists ITIA_JPH._next 12
    (fn_body ITIA_JPH.f_find_unimportant_object) = true /\
  contains_stable_find_result_to_unload_s
    ITIA_USS._find_unimportant_object ITIA_USS._unload_object
    (fn_body ITIA_USS.f_allocate_object) = true /\
  contains_stable_find_result_to_unload_s
    ITIA_JPS._find_unimportant_object ITIA_JPS._unload_object
    (fn_body ITIA_JPS.f_allocate_object) = true /\
  behavior_begin_list_index (gvar_init ITIA_USD.v_bhvMario) = Some 0 /\
  behavior_begin_list_index (gvar_init ITIA_JPD.v_bhvMario) = Some 0.

Theorem ink_pool_eviction_source_checked :
  ink_pool_eviction_source_claim.
Proof.
  unfold ink_pool_eviction_source_claim, behavior_begin_list_index.
  vm_compute. repeat split; reflexivity.
Qed.

(** This record names the one live invariant still needed to turn the source
    receipt into receiver identity.  In a well-formed live list partition,
    one object has one list index and distinct live objects occupy distinct
    pool slots. *)
Record InkLiveObjectListSlotProjection (Object : Type) : Type := {
  ink_live_mario_object : Object;
  ink_live_eviction_object : Object;
  ink_live_object_list_index : Object -> Z;
  ink_live_object_slot : Object -> nat;
  ink_live_mario_is_player_list :
    ink_live_object_list_index ink_live_mario_object = 0;
  ink_live_eviction_is_unimportant_list :
    ink_live_object_list_index ink_live_eviction_object = 12;
  ink_live_distinct_objects_have_distinct_slots :
    forall first second,
      first <> second ->
      ink_live_object_slot first <> ink_live_object_slot second
}.

Theorem live_unimportant_eviction_is_not_mario :
  forall Object (projection : InkLiveObjectListSlotProjection Object),
    ink_live_eviction_object Object projection <>
      ink_live_mario_object Object projection.
Proof.
  intros Object projection Hequal.
  pose proof (ink_live_mario_is_player_list Object projection) as Hmario.
  pose proof
    (ink_live_eviction_is_unimportant_list Object projection) as Heviction.
  rewrite Hequal in Heviction.
  lia.
Qed.

Corollary live_unimportant_eviction_uses_a_distinct_mario_slot :
  forall Object (projection : InkLiveObjectListSlotProjection Object),
    ink_live_object_slot Object projection
        (ink_live_eviction_object Object projection) <>
      ink_live_object_slot Object projection
        (ink_live_mario_object Object projection).
Proof.
  intros Object projection.
  apply ink_live_distinct_objects_have_distinct_slots.
  exact (live_unimportant_eviction_is_not_mario Object projection).
Qed.

(** * Byte-precise alias/OOB boundary *)

Definition ink_object_flag_cell_offset : Z := object_raw_float_offset 1.
Definition ink_object_graph_y_offset_cell_offset : Z :=
  object_raw_float_offset 21.
Definition ink_object_size : Z := 608.

Theorem ink_dangerous_object_cell_offsets :
  ink_object_flag_cell_offset = 140 /\
  ink_object_graph_y_offset_cell_offset = 220 /\
  0 <= ink_object_flag_cell_offset /\
  ink_object_flag_cell_offset + 4 <= ink_object_size /\
  0 <= ink_object_graph_y_offset_cell_offset /\
  ink_object_graph_y_offset_cell_offset + 4 <= ink_object_size.
Proof.
  unfold ink_object_flag_cell_offset,
    ink_object_graph_y_offset_cell_offset, object_raw_float_offset,
    ink_object_size.
  split; [reflexivity |].
  split; [reflexivity |].
  split; [lia |].
  split; [lia |].
  split; lia.
Qed.

Definition ink_object_cell_load
    (chunk : memory_chunk) (cell_offset : Z)
    (memory : Mem.mem) (object_block : block) (object_base : Z) : option val :=
  Mem.load chunk memory object_block (object_base + cell_offset).

Lemma framed_store_preserves_object_cell :
  forall before after read_chunk write_chunk cell_offset
      object_block write_block object_base write_offset value,
    (write_block <> object_block \/
     write_offset + size_chunk write_chunk <= object_base + cell_offset \/
     object_base + cell_offset + size_chunk read_chunk <= write_offset) ->
    Mem.store write_chunk before write_block write_offset value = Some after ->
    ink_object_cell_load read_chunk cell_offset after object_block object_base =
      ink_object_cell_load read_chunk cell_offset before object_block object_base.
Proof.
  intros before after read_chunk write_chunk cell_offset object_block
    write_block object_base write_offset value Hframe Hstore.
  unfold ink_object_cell_load.
  eapply Mem.load_store_other; eauto.
  destruct Hframe as [Hblock | [Hwrite_before | Hcell_before]].
  - left. congruence.
  - right. right. exact Hwrite_before.
  - right. left. exact Hcell_before.
Qed.

Theorem changed_four_byte_object_cell_requires_same_block_and_overlap :
  forall before after read_chunk write_chunk cell_offset
      object_block write_block object_base write_offset value,
    size_chunk read_chunk = 4 ->
    Mem.store write_chunk before write_block write_offset value = Some after ->
    ink_object_cell_load read_chunk cell_offset after object_block object_base <>
      ink_object_cell_load read_chunk cell_offset before object_block object_base ->
    write_block = object_block /\
    write_offset < object_base + cell_offset + 4 /\
    object_base + cell_offset < write_offset + size_chunk write_chunk.
Proof.
  intros before after read_chunk write_chunk cell_offset object_block
    write_block object_base write_offset value Hsize Hstore Hchanged.
  destruct (peq write_block object_block) as [Hblock | Hblock].
  2: exfalso; apply Hchanged;
     eapply framed_store_preserves_object_cell; eauto; left; exact Hblock.
  subst write_block. split; [reflexivity |]. split.
  - destruct (Z_lt_ge_dec write_offset
      (object_base + cell_offset + 4)); auto.
    exfalso. apply Hchanged.
    eapply framed_store_preserves_object_cell; eauto.
    right. right. rewrite Hsize. lia.
  - destruct (Z_lt_ge_dec (object_base + cell_offset)
      (write_offset + size_chunk write_chunk)); auto.
    exfalso. apply Hchanged.
    eapply framed_store_preserves_object_cell; eauto.
    right. left. lia.
Qed.

Corollary changed_timer131_flag_cell_requires_exact_object_overlap :
  forall before after write_chunk object_block write_block object_base
      write_offset value,
    Mem.store write_chunk before write_block write_offset value = Some after ->
    ink_object_cell_load Mint32 ink_object_flag_cell_offset
        after object_block object_base <>
      ink_object_cell_load Mint32 ink_object_flag_cell_offset
        before object_block object_base ->
    write_block = object_block /\
    write_offset < object_base + 144 /\
    object_base + 140 < write_offset + size_chunk write_chunk.
Proof.
  intros. pose proof
    (changed_four_byte_object_cell_requires_same_block_and_overlap
      before after Mint32 write_chunk ink_object_flag_cell_offset
      object_block write_block object_base write_offset value eq_refl H H0)
    as Hoverlap.
  unfold ink_object_flag_cell_offset, object_raw_float_offset in Hoverlap.
  cbn in Hoverlap.
  destruct Hoverlap as [Hblock [Hupper Hlower]].
  split; [exact Hblock |]. split; lia.
Qed.

Corollary changed_timer131_graph_offset_cell_requires_exact_object_overlap :
  forall before after write_chunk object_block write_block object_base
      write_offset value,
    Mem.store write_chunk before write_block write_offset value = Some after ->
    ink_object_cell_load Mfloat32 ink_object_graph_y_offset_cell_offset
        after object_block object_base <>
      ink_object_cell_load Mfloat32 ink_object_graph_y_offset_cell_offset
        before object_block object_base ->
    write_block = object_block /\
    write_offset < object_base + 224 /\
    object_base + 220 < write_offset + size_chunk write_chunk.
Proof.
  intros. pose proof
    (changed_four_byte_object_cell_requires_same_block_and_overlap
      before after Mfloat32 write_chunk ink_object_graph_y_offset_cell_offset
      object_block write_block object_base write_offset value eq_refl H H0)
    as Hoverlap.
  unfold ink_object_graph_y_offset_cell_offset,
    object_raw_float_offset in Hoverlap.
  cbn in Hoverlap.
  destruct Hoverlap as [Hblock [Hupper Hlower]].
  split; [exact Hblock |]. split; lia.
Qed.

(** A store wholly contained in any other Object-pool slot cannot change
    either dangerous four-byte cell in Mario's slot.  This covers all field
    clearing/initialization performed when an evicted slot is immediately
    reused; it deliberately does not cover a forged pointer, an out-of-bounds
    store, or reuse of Mario's own slot. *)
Theorem distinct_object_slot_store_preserves_timer131_cell :
  forall before after pool_block writer_slot mario_slot
      write_chunk write_inner_offset cell_offset value,
    writer_slot <> mario_slot ->
    0 <= write_inner_offset ->
    write_inner_offset + size_chunk write_chunk <= object_size ->
    (cell_offset = ink_object_flag_cell_offset \/
     cell_offset = ink_object_graph_y_offset_cell_offset) ->
    Mem.store write_chunk before pool_block
      (object_slot_offset writer_slot + write_inner_offset) value = Some after ->
    ink_object_cell_load Mfloat32 cell_offset after pool_block
        (object_slot_offset mario_slot) =
      ink_object_cell_load Mfloat32 cell_offset before pool_block
        (object_slot_offset mario_slot).
Proof.
  intros before after pool_block writer_slot mario_slot
    write_chunk write_inner_offset cell_offset value
    Hdistinct Hwrite_lower Hwrite_upper Hcell Hstore.
  assert (Hcell_bounds :
      0 <= cell_offset /\ cell_offset + 4 <= object_size).
  { destruct Hcell as [Hflag | Hoffset]; subst cell_offset;
      unfold ink_object_flag_cell_offset,
        ink_object_graph_y_offset_cell_offset,
        object_raw_float_offset, object_size; cbn; lia. }
  destruct Hcell_bounds as [Hcell_lower Hcell_upper].
  pose proof
    (distinct_object_slot_intervals_are_disjoint
      writer_slot mario_slot Hdistinct) as Hintervals.
  unfold ink_object_cell_load.
  eapply Mem.load_store_other; eauto.
  right.
  destruct Hintervals as [Hwriter_before | Hmario_before].
  - right. cbn [size_chunk]. lia.
  - left. cbn [size_chunk]. lia.
Qed.

Corollary changed_timer131_cell_by_in_slot_store_requires_mario_slot :
  forall before after pool_block writer_slot mario_slot
      write_chunk write_inner_offset cell_offset value,
    0 <= write_inner_offset ->
    write_inner_offset + size_chunk write_chunk <= object_size ->
    (cell_offset = ink_object_flag_cell_offset \/
     cell_offset = ink_object_graph_y_offset_cell_offset) ->
    Mem.store write_chunk before pool_block
      (object_slot_offset writer_slot + write_inner_offset) value = Some after ->
    ink_object_cell_load Mfloat32 cell_offset after pool_block
        (object_slot_offset mario_slot) <>
      ink_object_cell_load Mfloat32 cell_offset before pool_block
        (object_slot_offset mario_slot) ->
    writer_slot = mario_slot.
Proof.
  intros before after pool_block writer_slot mario_slot
    write_chunk write_inner_offset cell_offset value
    Hwrite_lower Hwrite_upper Hcell Hstore Hchanged.
  destruct (Nat.eq_dec writer_slot mario_slot) as [Hequal | Hdistinct].
  - exact Hequal.
  - exfalso. apply Hchanged.
    eapply distinct_object_slot_store_preserves_timer131_cell; eauto.
Qed.

Theorem live_unimportant_slot_reuse_preserves_timer131_cell :
  forall Object (projection : InkLiveObjectListSlotProjection Object)
      before after pool_block write_chunk write_inner_offset cell_offset value,
    0 <= write_inner_offset ->
    write_inner_offset + size_chunk write_chunk <= object_size ->
    (cell_offset = ink_object_flag_cell_offset \/
     cell_offset = ink_object_graph_y_offset_cell_offset) ->
    Mem.store write_chunk before pool_block
      (object_slot_offset
        (ink_live_object_slot Object projection
          (ink_live_eviction_object Object projection)) +
       write_inner_offset) value = Some after ->
    ink_object_cell_load Mfloat32 cell_offset after pool_block
        (object_slot_offset
          (ink_live_object_slot Object projection
            (ink_live_mario_object Object projection))) =
      ink_object_cell_load Mfloat32 cell_offset before pool_block
        (object_slot_offset
          (ink_live_object_slot Object projection
            (ink_live_mario_object Object projection))).
Proof.
  intros Object projection before after pool_block write_chunk
    write_inner_offset cell_offset value Hwrite_lower Hwrite_upper Hcell Hstore.
  exact
    (distinct_object_slot_store_preserves_timer131_cell
      before after pool_block
      (ink_live_object_slot Object projection
        (ink_live_eviction_object Object projection))
      (ink_live_object_slot Object projection
        (ink_live_mario_object Object projection))
      write_chunk write_inner_offset cell_offset value
      (live_unimportant_eviction_uses_a_distinct_mario_slot
        Object projection)
      Hwrite_lower Hwrite_upper Hcell Hstore).
Qed.

Definition InkTimer131IndirectAliasCheckedBoundary : Prop :=
  ink_resolved_indirect_source_claim /\
  ink_external_struct_pointer_handoff_claim /\
  ink_pool_eviction_source_claim /\
  ink_behavior_pointer_writer_source_claim /\
  ink_third_callback_arguments ITIA_USM._common_landing_cancels
      ink_us_definitions = ink_expected_us_landing_callbacks /\
  ink_third_callback_arguments ITIA_JPM._common_landing_cancels
      ink_jp_definitions = ink_expected_jp_landing_callbacks /\
  ink_object_flag_cell_offset = 140 /\
  ink_object_graph_y_offset_cell_offset = 220.

Theorem ink_timer131_indirect_alias_checked_boundary_holds :
  InkTimer131IndirectAliasCheckedBoundary.
Proof.
  unfold InkTimer131IndirectAliasCheckedBoundary.
  split; [exact ink_resolved_indirect_source_checked |].
  split; [exact ink_external_struct_pointer_handoff_checked |].
  split; [exact ink_pool_eviction_source_checked |].
  split; [exact ink_behavior_pointer_writer_source_checked |].
  pose proof ink_landing_callback_arguments_are_exact_bilateral as Hcallbacks.
  destruct Hcallbacks as [Hus [Hjp _]].
  split; [exact Hus |].
  split; [exact Hjp |].
  split; reflexivity.
Qed.

(** Remaining retail bridge after this source/memory tranche.  A faithful
    stock table is now sufficient for indirect-call closure; the unresolved
    cases are precisely mutations of dispatch/identity/memory or the separate
    negative-depth/dialog construction. *)
Record InkTimer131PostIndirectRetailResidual : Type := {
  ink_indirect_live_tables_match_initializers : Prop;
  ink_indirect_live_callback_arguments_match_source : Prop;
  ink_indirect_externals_frame_mario_tail_cells : Prop;
  ink_indirect_no_same_block_overlapping_alias_store : Prop;
  ink_indirect_current_and_mario_object_share_live_slot_epoch : Prop;
  ink_indirect_mario_behavior_pointer_is_stock_and_preserved : Prop;
  ink_indirect_live_object_lists_remain_a_disjoint_partition : Prop;
  ink_indirect_mario_slot_epoch_survives_pool_eviction_and_reuse : Prop;
  ink_indirect_negative_depth_dialog_branch_is_separately_closed : Prop
}.
