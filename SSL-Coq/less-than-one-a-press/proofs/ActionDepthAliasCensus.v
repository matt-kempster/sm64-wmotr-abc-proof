(** Bilateral syntax boundary for forged action/depth state.

    The existing JP depth census enumerates direct field assignments.  This
    file adds the matching US computation and separates two other source-level
    escape routes:

    - forming a pointer to one sensitive scalar field; and
    - calling through a function-valued expression while passing a
      [MarioState *].

    These are receiver-neutral generated-AST facts.  In particular, absence of
    an explicit [address-of] expression does not prove that a whole-structure
    pointer is non-aliased, and an indirect call-site census does not prove the
    runtime target table or receiver.  External-call frames, defined pointer
    arithmetic, live action-table contents, and the linked-memory identity of
    [gMarioState] remain semantic obligations. *)

From Coq Require Import List ZArith.
From compcert Require Import AST Clight Cop Ctypes Integers.
From LessThanOneAPress.Generated Require Import us_mario jp_mario
  us_mario_actions_airborne us_mario_actions_automatic
  us_mario_actions_cutscene us_mario_actions_moving
  us_mario_actions_object us_mario_actions_stationary
  us_mario_actions_submerged us_mario_step us_interaction us_mario_misc
  jp_mario_actions_airborne jp_mario_actions_automatic
  jp_mario_actions_cutscene jp_mario_actions_moving
  jp_mario_actions_object jp_mario_actions_stationary
  jp_mario_actions_submerged jp_mario_step jp_interaction jp_mario_misc.
From LessThanOneAPress.Proofs Require Import
  ASTFacts LinkedClightPrograms NormalizedClightPrograms JPQuicksandDepth.

Import ListNotations.

Module AD_USMario := us_mario.
Module AD_USAir := us_mario_actions_airborne.
Module AD_USAuto := us_mario_actions_automatic.
Module AD_USCut := us_mario_actions_cutscene.
Module AD_USMove := us_mario_actions_moving.
Module AD_USObject := us_mario_actions_object.
Module AD_USStationary := us_mario_actions_stationary.
Module AD_USSubmerged := us_mario_actions_submerged.
Module AD_USStep := us_mario_step.
Module AD_USInteraction := us_interaction.
Module AD_USMisc := us_mario_misc.
Module AD_JPMario := jp_mario.
Module AD_JPAir := jp_mario_actions_airborne.
Module AD_JPAuto := jp_mario_actions_automatic.
Module AD_JPCut := jp_mario_actions_cutscene.
Module AD_JPMove := jp_mario_actions_moving.
Module AD_JPObject := jp_mario_actions_object.
Module AD_JPStationary := jp_mario_actions_stationary.
Module AD_JPSubmerged := jp_mario_actions_submerged.
Module AD_JPStep := jp_mario_step.
Module AD_JPInteraction := jp_interaction.
Module AD_JPMisc := jp_mario_misc.

Definition us_generated_definitions := unit_global_definitions us_units.
Definition jp_generated_definitions_for_alias :=
  unit_global_definitions jp_units.

(** Detect an explicit address-of whose operand contains the selected field.
    Recursive descent is retained because [clightgen] can wrap the lvalue in
    casts or nested field/dereference expressions. *)
Fixpoint expression_takes_address_of_field
    (field : ident) (expression : expr) : bool :=
  match expression with
  | Eaddrof inner _ =>
      expression_mentions_field field inner ||
      expression_takes_address_of_field field inner
  | Ederef inner _ | Eunop _ inner _ | Ecast inner _
  | Efield inner _ _ => expression_takes_address_of_field field inner
  | Ebinop _ left_expression right_expression _ =>
      expression_takes_address_of_field field left_expression ||
      expression_takes_address_of_field field right_expression
  | _ => false
  end.

Definition expression_list_takes_address_of_field
    (field : ident) (expressions : list expr) : bool :=
  existsb (expression_takes_address_of_field field) expressions.

Fixpoint statement_takes_address_of_field_s
    (field : ident) (statement : statement) : bool :=
  match statement with
  | Sskip | Sbreak | Scontinue | Sreturn None | Sgoto _ => false
  | Sassign left_expression right_expression =>
      expression_takes_address_of_field field left_expression ||
      expression_takes_address_of_field field right_expression
  | Sset _ right_expression =>
      expression_takes_address_of_field field right_expression
  | Scall _ function arguments =>
      expression_takes_address_of_field field function ||
      expression_list_takes_address_of_field field arguments
  | Sbuiltin _ _ _ arguments =>
      expression_list_takes_address_of_field field arguments
  | Ssequence first second | Sloop first second =>
      statement_takes_address_of_field_s field first ||
      statement_takes_address_of_field_s field second
  | Sifthenelse condition yes_branch no_branch =>
      expression_takes_address_of_field field condition ||
      statement_takes_address_of_field_s field yes_branch ||
      statement_takes_address_of_field_s field no_branch
  | Sreturn (Some value) => expression_takes_address_of_field field value
  | Sswitch value cases =>
      expression_takes_address_of_field field value ||
      statement_takes_address_of_field_ls field cases
  | Slabel _ body => statement_takes_address_of_field_s field body
  end
with statement_takes_address_of_field_ls
    (field : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      statement_takes_address_of_field_s field body ||
      statement_takes_address_of_field_ls field rest
  end.

Fixpoint internal_field_address_sites
    (field : ident)
    (definitions : list (ident * globdef (fundef function) type)) :
    list ident :=
  match definitions with
  | [] => []
  | (id, Gfun (Internal body)) :: rest =>
      if statement_takes_address_of_field_s field (fn_body body)
      then id :: internal_field_address_sites field rest
      else internal_field_address_sites field rest
  | _ :: rest => internal_field_address_sites field rest
  end.

Fixpoint expression_is_pointer_derived_from_struct
    (tag : ident) (expression : expr) : bool :=
  match typeof expression with
  | Tpointer (Tstruct found _) _ => Pos.eqb found tag
  | _ =>
      match expression with
      | Ecast inner _ => expression_is_pointer_derived_from_struct tag inner
      | Ebinop Oadd left_expression right_expression _
      | Ebinop Osub left_expression right_expression _ =>
          expression_is_pointer_derived_from_struct tag left_expression ||
          expression_is_pointer_derived_from_struct tag right_expression
      | _ => false
      end
  end.

Definition has_pointer_to_struct_argument
    (tag : ident) (arguments : list expr) : bool :=
  existsb (expression_is_pointer_derived_from_struct tag) arguments.

Definition is_indirect_call_with_struct_pointer_s
    (tag : ident) (statement : statement) : bool :=
  match statement with
  | Scall _ (Evar _ _) _ => false
  | Scall _ _ arguments => has_pointer_to_struct_argument tag arguments
  | _ => false
  end.

Fixpoint contains_indirect_call_with_struct_pointer_s
    (tag : ident) (statement : statement) : bool :=
  match statement with
  | Scall _ _ _ => is_indirect_call_with_struct_pointer_s tag statement
  | Ssequence first second | Sloop first second =>
      contains_indirect_call_with_struct_pointer_s tag first ||
      contains_indirect_call_with_struct_pointer_s tag second
  | Sifthenelse _ yes_branch no_branch =>
      contains_indirect_call_with_struct_pointer_s tag yes_branch ||
      contains_indirect_call_with_struct_pointer_s tag no_branch
  | Sswitch _ cases =>
      contains_indirect_call_with_struct_pointer_ls tag cases
  | Slabel _ body => contains_indirect_call_with_struct_pointer_s tag body
  | _ => false
  end
with contains_indirect_call_with_struct_pointer_ls
    (tag : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      contains_indirect_call_with_struct_pointer_s tag body ||
      contains_indirect_call_with_struct_pointer_ls tag rest
  end.

Fixpoint indirect_struct_pointer_call_count_s
    (tag : ident) (statement : statement) : nat :=
  match statement with
  | Scall _ _ _ =>
      if is_indirect_call_with_struct_pointer_s tag statement then 1 else 0
  | Ssequence first second | Sloop first second =>
      (indirect_struct_pointer_call_count_s tag first +
       indirect_struct_pointer_call_count_s tag second)%nat
  | Sifthenelse _ yes_branch no_branch =>
      (indirect_struct_pointer_call_count_s tag yes_branch +
       indirect_struct_pointer_call_count_s tag no_branch)%nat
  | Sswitch _ cases => indirect_struct_pointer_call_count_ls tag cases
  | Slabel _ body => indirect_struct_pointer_call_count_s tag body
  | _ => 0%nat
  end
with indirect_struct_pointer_call_count_ls
    (tag : ident) (cases : labeled_statements) : nat :=
  match cases with
  | LSnil => 0%nat
  | LScons _ body rest =>
      (indirect_struct_pointer_call_count_s tag body +
       indirect_struct_pointer_call_count_ls tag rest)%nat
  end.

Definition is_field_mask_guarded_indirect_struct_pointer_call_s
    (field : ident) (mask : Z) (tag : ident)
    (statement : statement) : bool :=
  match statement with
  | Ssequence
      (Sset guard_temp
        (Efield
          (Ederef (Etempvar _ _) _) found_field _))
      (Sifthenelse
        (Ebinop Oand (Etempvar found_guard_temp _)
          (Econst_int found_mask _) _)
        yes_branch _) =>
      Pos.eqb found_field field &&
      Pos.eqb found_guard_temp guard_temp &&
      Int.eq found_mask (Int.repr mask) &&
      contains_indirect_call_with_struct_pointer_s tag yes_branch
  | _ => false
  end.

Fixpoint contains_field_mask_guarded_indirect_struct_pointer_call_s
    (field : ident) (mask : Z) (tag : ident)
    (statement : statement) : bool :=
  is_field_mask_guarded_indirect_struct_pointer_call_s
    field mask tag statement ||
  match statement with
  | Ssequence first second | Sloop first second =>
      contains_field_mask_guarded_indirect_struct_pointer_call_s
        field mask tag first ||
      contains_field_mask_guarded_indirect_struct_pointer_call_s
        field mask tag second
  | Sifthenelse _ yes_branch no_branch =>
      contains_field_mask_guarded_indirect_struct_pointer_call_s
        field mask tag yes_branch ||
      contains_field_mask_guarded_indirect_struct_pointer_call_s
        field mask tag no_branch
  | Sswitch _ cases =>
      contains_field_mask_guarded_indirect_struct_pointer_call_ls
        field mask tag cases
  | Slabel _ body =>
      contains_field_mask_guarded_indirect_struct_pointer_call_s
        field mask tag body
  | _ => false
  end
with contains_field_mask_guarded_indirect_struct_pointer_call_ls
    (field : ident) (mask : Z) (tag : ident)
    (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      contains_field_mask_guarded_indirect_struct_pointer_call_s
        field mask tag body ||
      contains_field_mask_guarded_indirect_struct_pointer_call_ls
        field mask tag rest
  end.

Fixpoint internal_indirect_struct_pointer_call_sites
    (tag : ident)
    (definitions : list (ident * globdef (fundef function) type)) :
    list ident :=
  match definitions with
  | [] => []
  | (id, Gfun (Internal body)) :: rest =>
      if contains_indirect_call_with_struct_pointer_s tag (fn_body body)
      then id :: internal_indirect_struct_pointer_call_sites tag rest
      else internal_indirect_struct_pointer_call_sites tag rest
  | _ :: rest => internal_indirect_struct_pointer_call_sites tag rest
  end.

Fixpoint direct_struct_pointer_callees_s
    (tag : ident) (statement : statement) : list ident :=
  match statement with
  | Scall _ (Evar callee _) arguments =>
      if has_pointer_to_struct_argument tag arguments then [callee] else []
  | Ssequence first second | Sloop first second =>
      direct_struct_pointer_callees_s tag first ++
      direct_struct_pointer_callees_s tag second
  | Sifthenelse _ yes_branch no_branch =>
      direct_struct_pointer_callees_s tag yes_branch ++
      direct_struct_pointer_callees_s tag no_branch
  | Sswitch _ cases => direct_struct_pointer_callees_ls tag cases
  | Slabel _ body => direct_struct_pointer_callees_s tag body
  | _ => []
  end
with direct_struct_pointer_callees_ls
    (tag : ident) (cases : labeled_statements) : list ident :=
  match cases with
  | LSnil => []
  | LScons _ body rest =>
      direct_struct_pointer_callees_s tag body ++
      direct_struct_pointer_callees_ls tag rest
  end.

Fixpoint internal_function_identifiers
    (definitions : list (ident * globdef (fundef function) type)) :
    list ident :=
  match definitions with
  | [] => []
  | (id, Gfun (Internal _)) :: rest =>
      id :: internal_function_identifiers rest
  | _ :: rest => internal_function_identifiers rest
  end.

Fixpoint all_direct_struct_pointer_callees
    (tag : ident)
    (definitions : list (ident * globdef (fundef function) type)) :
    list ident :=
  match definitions with
  | [] => []
  | (_, Gfun (Internal body)) :: rest =>
      direct_struct_pointer_callees_s tag (fn_body body) ++
      all_direct_struct_pointer_callees tag rest
  | _ :: rest => all_direct_struct_pointer_callees tag rest
  end.

Definition identifier_occurs (needle : ident) (haystack : list ident) : bool :=
  existsb (Pos.eqb needle) haystack.

Definition unresolved_direct_struct_pointer_callees
    (tag : ident)
    (definitions : list (ident * globdef (fundef function) type)) :
    list ident :=
  filter
    (fun callee =>
       negb (identifier_occurs callee
         (internal_function_identifiers definitions)))
    (all_direct_struct_pointer_callees tag definitions).

Fixpoint contains_builtin_with_struct_pointer_s
    (tag : ident) (statement : statement) : bool :=
  match statement with
  | Sbuiltin _ _ _ arguments =>
      has_pointer_to_struct_argument tag arguments
  | Ssequence first second | Sloop first second =>
      contains_builtin_with_struct_pointer_s tag first ||
      contains_builtin_with_struct_pointer_s tag second
  | Sifthenelse _ yes_branch no_branch =>
      contains_builtin_with_struct_pointer_s tag yes_branch ||
      contains_builtin_with_struct_pointer_s tag no_branch
  | Sswitch _ cases => contains_builtin_with_struct_pointer_ls tag cases
  | Slabel _ body => contains_builtin_with_struct_pointer_s tag body
  | _ => false
  end
with contains_builtin_with_struct_pointer_ls
    (tag : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      contains_builtin_with_struct_pointer_s tag body ||
      contains_builtin_with_struct_pointer_ls tag rest
  end.

Fixpoint internal_builtin_struct_pointer_sites
    (tag : ident)
    (definitions : list (ident * globdef (fundef function) type)) :
    list ident :=
  match definitions with
  | [] => []
  | (id, Gfun (Internal body)) :: rest =>
      if contains_builtin_with_struct_pointer_s tag (fn_body body)
      then id :: internal_builtin_struct_pointer_sites tag rest
      else internal_builtin_struct_pointer_sites tag rest
  | _ :: rest => internal_builtin_struct_pointer_sites tag rest
  end.

(** * Whole-program typed-alias and untyped-derivation census *)

Definition expression_has_struct_pointer_type
    (tag : ident) (expression : expr) : bool :=
  match typeof expression with
  | Tpointer (Tstruct found _) _ => Pos.eqb found tag
  | _ => false
  end.

Definition type_is_struct_pointer (tag : ident) (value_type : type) : bool :=
  match value_type with
  | Tpointer (Tstruct found _) _ => Pos.eqb found tag
  | _ => false
  end.

(** Flag casts either from or to the selected structure pointer and arithmetic
    whose operand is already such a pointer.  Ordinary [array[index]] address
    formation rooted at a structure array is deliberately not flagged: its
    operand has array type and remains subject to CompCert's normal bounds and
    access checks. *)
Fixpoint expression_has_untyped_struct_pointer_derivation
    (tag : ident) (expression : expr) : bool :=
  match expression with
  | Ecast inner target_type =>
      expression_has_struct_pointer_type tag inner ||
      type_is_struct_pointer tag target_type ||
      expression_has_untyped_struct_pointer_derivation tag inner
  | Ebinop operator left_expression right_expression _ =>
      match operator with
      | Oadd | Osub =>
          expression_has_struct_pointer_type tag left_expression ||
          expression_has_struct_pointer_type tag right_expression ||
          expression_has_untyped_struct_pointer_derivation
            tag left_expression ||
          expression_has_untyped_struct_pointer_derivation
            tag right_expression
      | _ =>
          expression_has_untyped_struct_pointer_derivation
            tag left_expression ||
          expression_has_untyped_struct_pointer_derivation
            tag right_expression
      end
  | Ederef inner _ | Eaddrof inner _ | Eunop _ inner _
  | Efield inner _ _ =>
      expression_has_untyped_struct_pointer_derivation tag inner
  | _ => false
  end.

Definition expression_list_has_untyped_struct_pointer_derivation
    (tag : ident) (expressions : list expr) : bool :=
  existsb (expression_has_untyped_struct_pointer_derivation tag) expressions.

Fixpoint statement_has_untyped_struct_pointer_derivation_s
    (tag : ident) (statement : statement) : bool :=
  match statement with
  | Sskip | Sbreak | Scontinue | Sreturn None | Sgoto _ => false
  | Sassign left_expression right_expression =>
      expression_has_untyped_struct_pointer_derivation tag left_expression ||
      expression_has_untyped_struct_pointer_derivation tag right_expression
  | Sset _ right_expression =>
      expression_has_untyped_struct_pointer_derivation tag right_expression
  | Scall _ function arguments =>
      expression_has_untyped_struct_pointer_derivation tag function ||
      expression_list_has_untyped_struct_pointer_derivation tag arguments
  | Sbuiltin _ _ _ arguments =>
      expression_list_has_untyped_struct_pointer_derivation tag arguments
  | Ssequence first second | Sloop first second =>
      statement_has_untyped_struct_pointer_derivation_s tag first ||
      statement_has_untyped_struct_pointer_derivation_s tag second
  | Sifthenelse condition yes_branch no_branch =>
      expression_has_untyped_struct_pointer_derivation tag condition ||
      statement_has_untyped_struct_pointer_derivation_s tag yes_branch ||
      statement_has_untyped_struct_pointer_derivation_s tag no_branch
  | Sreturn (Some value) =>
      expression_has_untyped_struct_pointer_derivation tag value
  | Sswitch value cases =>
      expression_has_untyped_struct_pointer_derivation tag value ||
      statement_has_untyped_struct_pointer_derivation_ls tag cases
  | Slabel _ body =>
      statement_has_untyped_struct_pointer_derivation_s tag body
  end
with statement_has_untyped_struct_pointer_derivation_ls
    (tag : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      statement_has_untyped_struct_pointer_derivation_s tag body ||
      statement_has_untyped_struct_pointer_derivation_ls tag rest
  end.

Fixpoint internal_untyped_struct_pointer_derivation_sites
    (tag : ident)
    (definitions : list (ident * globdef (fundef function) type)) :
    list ident :=
  match definitions with
  | [] => []
  | (id, Gfun (Internal body)) :: rest =>
      if statement_has_untyped_struct_pointer_derivation_s
           tag (fn_body body)
      then id :: internal_untyped_struct_pointer_derivation_sites tag rest
      else internal_untyped_struct_pointer_derivation_sites tag rest
  | _ :: rest => internal_untyped_struct_pointer_derivation_sites tag rest
  end.

Definition expression_has_struct_type
    (tag : ident) (expression : expr) : bool :=
  match typeof expression with
  | Tstruct found _ => Pos.eqb found tag
  | _ => false
  end.

Fixpoint statement_assigns_whole_struct_s
    (tag : ident) (statement : statement) : bool :=
  match statement with
  | Sassign left_expression _ =>
      expression_has_struct_type tag left_expression
  | Ssequence first second | Sloop first second =>
      statement_assigns_whole_struct_s tag first ||
      statement_assigns_whole_struct_s tag second
  | Sifthenelse _ yes_branch no_branch =>
      statement_assigns_whole_struct_s tag yes_branch ||
      statement_assigns_whole_struct_s tag no_branch
  | Sswitch _ cases => statement_assigns_whole_struct_ls tag cases
  | Slabel _ body => statement_assigns_whole_struct_s tag body
  | _ => false
  end
with statement_assigns_whole_struct_ls
    (tag : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      statement_assigns_whole_struct_s tag body ||
      statement_assigns_whole_struct_ls tag rest
  end.

Fixpoint statement_stores_struct_pointer_s
    (tag : ident) (statement : statement) : bool :=
  match statement with
  | Sassign _ right_expression =>
      expression_has_struct_pointer_type tag right_expression
  | Ssequence first second | Sloop first second =>
      statement_stores_struct_pointer_s tag first ||
      statement_stores_struct_pointer_s tag second
  | Sifthenelse _ yes_branch no_branch =>
      statement_stores_struct_pointer_s tag yes_branch ||
      statement_stores_struct_pointer_s tag no_branch
  | Sswitch _ cases => statement_stores_struct_pointer_ls tag cases
  | Slabel _ body => statement_stores_struct_pointer_s tag body
  | _ => false
  end
with statement_stores_struct_pointer_ls
    (tag : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      statement_stores_struct_pointer_s tag body ||
      statement_stores_struct_pointer_ls tag rest
  end.

Fixpoint statement_returns_struct_pointer_s
    (tag : ident) (statement : statement) : bool :=
  match statement with
  | Sreturn (Some value) => expression_has_struct_pointer_type tag value
  | Ssequence first second | Sloop first second =>
      statement_returns_struct_pointer_s tag first ||
      statement_returns_struct_pointer_s tag second
  | Sifthenelse _ yes_branch no_branch =>
      statement_returns_struct_pointer_s tag yes_branch ||
      statement_returns_struct_pointer_s tag no_branch
  | Sswitch _ cases => statement_returns_struct_pointer_ls tag cases
  | Slabel _ body => statement_returns_struct_pointer_s tag body
  | _ => false
  end
with statement_returns_struct_pointer_ls
    (tag : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      statement_returns_struct_pointer_s tag body ||
      statement_returns_struct_pointer_ls tag rest
  end.

Fixpoint internal_statement_predicate_sites
    (predicate : statement -> bool)
    (definitions : list (ident * globdef (fundef function) type)) :
    list ident :=
  match definitions with
  | [] => []
  | (id, Gfun (Internal body)) :: rest =>
      if predicate (fn_body body)
      then id :: internal_statement_predicate_sites predicate rest
      else internal_statement_predicate_sites predicate rest
  | _ :: rest => internal_statement_predicate_sites predicate rest
  end.

Fixpoint initializer_addrof_offsets
    (target : ident) (data : list init_data) : list Z :=
  match data with
  | [] => []
  | Init_addrof found offset :: rest =>
      if Pos.eqb found target
      then Ptrofs.unsigned offset :: initializer_addrof_offsets target rest
      else initializer_addrof_offsets target rest
  | _ :: rest => initializer_addrof_offsets target rest
  end.

Fixpoint global_definition_initializer_addrof_offsets
    (target : ident)
    (definitions : list (ident * globdef (fundef function) type)) : list Z :=
  match definitions with
  | [] => []
  | (_, Gvar variable) :: rest =>
      initializer_addrof_offsets target (gvar_init variable) ++
      global_definition_initializer_addrof_offsets target rest
  | _ :: rest =>
      global_definition_initializer_addrof_offsets target rest
  end.

Definition us_depth_direct_writer_sites :=
  internal_field_assignment_sites
    AD_USMario._quicksandDepth us_generated_definitions.
Definition jp_depth_direct_writer_sites :=
  internal_field_assignment_sites
    AD_JPMario._quicksandDepth jp_generated_definitions_for_alias.
Definition us_action_direct_writer_sites :=
  internal_field_assignment_sites AD_USMario._action us_generated_definitions.
Definition jp_action_direct_writer_sites :=
  internal_field_assignment_sites
    AD_JPMario._action jp_generated_definitions_for_alias.

Definition us_action_state_direct_writer_sites :=
  internal_field_assignment_sites
    AD_USMario._actionState us_generated_definitions.
Definition jp_action_state_direct_writer_sites :=
  internal_field_assignment_sites
    AD_JPMario._actionState jp_generated_definitions_for_alias.
Definition us_action_timer_direct_writer_sites :=
  internal_field_assignment_sites
    AD_USMario._actionTimer us_generated_definitions.
Definition jp_action_timer_direct_writer_sites :=
  internal_field_assignment_sites
    AD_JPMario._actionTimer jp_generated_definitions_for_alias.
Definition us_action_arg_direct_writer_sites :=
  internal_field_assignment_sites
    AD_USMario._actionArg us_generated_definitions.
Definition jp_action_arg_direct_writer_sites :=
  internal_field_assignment_sites
    AD_JPMario._actionArg jp_generated_definitions_for_alias.

(** Exact direct writer identities for the two cells that matter directly to
    the negative-depth escape.  The repeated identifier atoms are stable
    across the US and JP generated units. *)
Theorem us_quicksand_depth_direct_writer_census :
  us_depth_direct_writer_sites =
    [AD_USMario._init_mario;
     AD_USAir._check_common_airborne_cancels;
     AD_USAuto._mario_execute_automatic_action;
     AD_USCut._act_quicksand_death;
     AD_USMove._common_landing_action;
     AD_USMove._quicksand_jump_land_action;
     AD_USSubmerged._mario_execute_submerged_action;
     AD_USStep._mario_update_quicksand].
Proof. vm_compute. reflexivity. Qed.

Theorem jp_quicksand_depth_direct_writer_census_bilateral :
  jp_depth_direct_writer_sites =
    [AD_JPMario._init_mario;
     AD_JPAir._check_common_airborne_cancels;
     AD_JPAuto._mario_execute_automatic_action;
     AD_JPCut._act_quicksand_death;
     AD_JPMove._common_landing_action;
     AD_JPMove._quicksand_jump_land_action;
     AD_JPSubmerged._mario_execute_submerged_action;
     AD_JPStep._mario_update_quicksand].
Proof. vm_compute. reflexivity. Qed.

Theorem us_action_direct_writer_census :
  us_action_direct_writer_sites =
    [AD_USMario._set_mario_action;
     AD_USMario._update_mario_info_for_cam;
     AD_USMario._init_mario;
     AD_USMario._init_mario_from_save_file;
     AD_USAir._act_air_throw;
     AD_USAuto._act_ledge_climb_slow;
     AD_USInteraction._bounce_back_from_attack;
     AD_USInteraction._check_kick_or_punch_wall].
Proof. vm_compute. reflexivity. Qed.

Theorem jp_action_direct_writer_census_bilateral :
  jp_action_direct_writer_sites =
    [AD_JPMario._set_mario_action;
     AD_JPMario._update_mario_info_for_cam;
     AD_JPMario._init_mario;
     AD_JPMario._init_mario_from_save_file;
     AD_JPAir._act_air_throw;
     AD_JPAuto._act_ledge_climb_slow;
     AD_JPInteraction._bounce_back_from_attack;
     AD_JPInteraction._check_kick_or_punch_wall].
Proof. vm_compute. reflexivity. Qed.

(** The complete receiver-neutral writer sets for action-state, action-timer,
    and action-argument are identical between versions.  Their exact computed
    cardinalities make the remaining control-flow audit finite without
    pretending that every same-named field belongs to Mario's live state. *)
Theorem us_jp_action_state_timer_argument_writer_censuses_agree :
  us_action_state_direct_writer_sites = jp_action_state_direct_writer_sites /\
  us_action_timer_direct_writer_sites = jp_action_timer_direct_writer_sites /\
  us_action_arg_direct_writer_sites = jp_action_arg_direct_writer_sites /\
  length us_action_state_direct_writer_sites = 60%nat /\
  length us_action_timer_direct_writer_sites = 74%nat /\
  length us_action_arg_direct_writer_sites = 14%nat.
Proof. vm_compute. repeat split; reflexivity. Qed.

(** No generated internal body explicitly forms the address of any of the five
    sensitive scalar fields.  This excludes the ordinary [helper(&m->field)]
    escape, but not a forged pointer derived from the base of [MarioState], an
    already-present alias, or an undefined/out-of-bounds store. *)
Theorem us_jp_sensitive_scalar_address_taking_census_is_empty :
  map (fun field => internal_field_address_sites field us_generated_definitions)
    [AD_USMario._action; AD_USMario._actionState; AD_USMario._actionTimer;
     AD_USMario._actionArg; AD_USMario._quicksandDepth] =
      [[]; []; []; []; []] /\
  map (fun field =>
         internal_field_address_sites field jp_generated_definitions_for_alias)
    [AD_JPMario._action; AD_JPMario._actionState; AD_JPMario._actionTimer;
     AD_JPMario._actionArg; AD_JPMario._quicksandDepth] =
      [[]; []; []; []; []].
Proof. vm_compute. split; reflexivity. Qed.

(** These are the only generated call bodies which invoke a function-valued
    expression while handing it a [MarioState *] (including a direct cast or
    immediate pointer-arithmetic derivation).  Both are real residuals: the
    landing callback needs its A-guard and callback-argument provenance; the
    interaction dispatcher needs its static table/index provenance. *)
Theorem us_jp_indirect_mario_state_call_site_census :
  internal_indirect_struct_pointer_call_sites
      AD_USMario._MarioState us_generated_definitions =
    [AD_USMove._common_landing_cancels;
     AD_USInteraction._mario_process_interactions] /\
  internal_indirect_struct_pointer_call_sites
      AD_JPMario._MarioState jp_generated_definitions_for_alias =
    [AD_JPMove._common_landing_cancels;
     AD_JPInteraction._mario_process_interactions].
Proof. vm_compute. split; reflexivity. Qed.

(** The landing-cancel function contains exactly one such indirect call, and
    the generated AST places it in the branch guarded by
    [m->input & INPUT_A_PRESSED] (mask 2).  Turning this receipt into
    unreachability needs the live-memory input projection; it does not follow
    from the lexical recognizer alone.  The interaction dispatch contains the
    other unique call and is not A-edge guarded. *)
Theorem us_jp_two_indirect_mario_state_calls_have_exact_source_shapes :
  indirect_struct_pointer_call_count_s AD_USMario._MarioState
      (fn_body AD_USMove.f_common_landing_cancels) = 1%nat /\
  contains_field_mask_guarded_indirect_struct_pointer_call_s
      AD_USMove._input 2 AD_USMario._MarioState
      (fn_body AD_USMove.f_common_landing_cancels) = true /\
  indirect_struct_pointer_call_count_s AD_USMario._MarioState
      (fn_body AD_USInteraction.f_mario_process_interactions) = 1%nat /\
  indirect_struct_pointer_call_count_s AD_JPMario._MarioState
      (fn_body AD_JPMove.f_common_landing_cancels) = 1%nat /\
  contains_field_mask_guarded_indirect_struct_pointer_call_s
      AD_JPMove._input 2 AD_JPMario._MarioState
      (fn_body AD_JPMove.f_common_landing_cancels) = true /\
  indirect_struct_pointer_call_count_s AD_JPMario._MarioState
      (fn_body AD_JPInteraction.f_mario_process_interactions) = 1%nat.
Proof. vm_compute. repeat split; reflexivity. Qed.

(** Every directly named call that receives a [MarioState *] resolves to an
    internal definition somewhere in the generated 38-unit source union, and
    no [Sbuiltin] receives such a pointer.  This is not an external-memory
    frame: CompCert external semantics and globals reachable without an
    explicit state argument remain to be constrained. *)
Theorem us_jp_no_unresolved_direct_or_builtin_mario_state_pointer_handoff :
  unresolved_direct_struct_pointer_callees
      AD_USMario._MarioState us_generated_definitions = [] /\
  unresolved_direct_struct_pointer_callees
      AD_JPMario._MarioState jp_generated_definitions_for_alias = [] /\
  internal_builtin_struct_pointer_sites
      AD_USMario._MarioState us_generated_definitions = [] /\
  internal_builtin_struct_pointer_sites
      AD_JPMario._MarioState jp_generated_definitions_for_alias = [].
Proof. vm_compute. repeat split; reflexivity. Qed.

(** The selected generated source has no internal syntax which can manufacture
    an interior or untyped [MarioState *] or [LandingAction *], copy either
    whole structure, retain either pointer in writable storage, or return one
    to an unknown caller.  Initializers retain exactly one MarioState alias:
    the intended [gMarioState = &gMarioStates[0]] base pointer.  No initializer
    retains any of the nine landing-descriptor addresses.

    This closes the generated *producer* side of the alias search.  It does
    not by itself prove that a live parameter has the intended identity, nor
    does it frame an unresolved external which can name public writable
    globals without receiving a pointer argument. *)
Definition ActionDepthDefinedAliasSourceClosure : Prop :=
  internal_untyped_struct_pointer_derivation_sites
      AD_USMario._MarioState us_generated_definitions = [] /\
  internal_untyped_struct_pointer_derivation_sites
      AD_JPMario._MarioState jp_generated_definitions_for_alias = [] /\
  internal_untyped_struct_pointer_derivation_sites
      AD_USMove._LandingAction us_generated_definitions = [] /\
  internal_untyped_struct_pointer_derivation_sites
      AD_JPMove._LandingAction jp_generated_definitions_for_alias = [] /\
  internal_statement_predicate_sites
      (statement_assigns_whole_struct_s AD_USMario._MarioState)
      us_generated_definitions = [] /\
  internal_statement_predicate_sites
      (statement_assigns_whole_struct_s AD_JPMario._MarioState)
      jp_generated_definitions_for_alias = [] /\
  internal_statement_predicate_sites
      (statement_assigns_whole_struct_s AD_USMove._LandingAction)
      us_generated_definitions = [] /\
  internal_statement_predicate_sites
      (statement_assigns_whole_struct_s AD_JPMove._LandingAction)
      jp_generated_definitions_for_alias = [] /\
  internal_statement_predicate_sites
      (statement_stores_struct_pointer_s AD_USMario._MarioState)
      us_generated_definitions = [] /\
  internal_statement_predicate_sites
      (statement_stores_struct_pointer_s AD_JPMario._MarioState)
      jp_generated_definitions_for_alias = [] /\
  internal_statement_predicate_sites
      (statement_stores_struct_pointer_s AD_USMove._LandingAction)
      us_generated_definitions = [] /\
  internal_statement_predicate_sites
      (statement_stores_struct_pointer_s AD_JPMove._LandingAction)
      jp_generated_definitions_for_alias = [] /\
  internal_statement_predicate_sites
      (statement_returns_struct_pointer_s AD_USMario._MarioState)
      us_generated_definitions = [] /\
  internal_statement_predicate_sites
      (statement_returns_struct_pointer_s AD_JPMario._MarioState)
      jp_generated_definitions_for_alias = [] /\
  internal_statement_predicate_sites
      (statement_returns_struct_pointer_s AD_USMove._LandingAction)
      us_generated_definitions = [] /\
  internal_statement_predicate_sites
      (statement_returns_struct_pointer_s AD_JPMove._LandingAction)
      jp_generated_definitions_for_alias = [] /\
  global_definition_initializer_addrof_offsets
      AD_USMisc._gMarioStates us_generated_definitions = [0%Z] /\
  global_definition_initializer_addrof_offsets
      AD_JPMisc._gMarioStates jp_generated_definitions_for_alias = [0%Z] /\
  map
    (fun descriptor =>
       global_definition_initializer_addrof_offsets
         descriptor us_generated_definitions)
    [AD_USMove._sJumpLandAction; AD_USMove._sFreefallLandAction;
     AD_USMove._sSideFlipLandAction; AD_USMove._sHoldJumpLandAction;
     AD_USMove._sHoldFreefallLandAction; AD_USMove._sLongJumpLandAction;
     AD_USMove._sDoubleJumpLandAction; AD_USMove._sTripleJumpLandAction;
     AD_USMove._sBackflipLandAction] =
    [[]; []; []; []; []; []; []; []; []] /\
  map
    (fun descriptor =>
       global_definition_initializer_addrof_offsets
         descriptor jp_generated_definitions_for_alias)
    [AD_JPMove._sJumpLandAction; AD_JPMove._sFreefallLandAction;
     AD_JPMove._sSideFlipLandAction; AD_JPMove._sHoldJumpLandAction;
     AD_JPMove._sHoldFreefallLandAction; AD_JPMove._sLongJumpLandAction;
     AD_JPMove._sDoubleJumpLandAction; AD_JPMove._sTripleJumpLandAction;
     AD_JPMove._sBackflipLandAction] =
    [[]; []; []; []; []; []; []; []; []].

Theorem action_depth_defined_alias_source_closure_holds :
  ActionDepthDefinedAliasSourceClosure.
Proof.
  unfold ActionDepthDefinedAliasSourceClosure.
  vm_compute. repeat split; reflexivity.
Qed.

(** The ordinary central setter writes all four action-control cells and resets
    state/timer to zero.  The action and argument values themselves come from
    parameters; this receipt therefore does not prove their caller provenance. *)
Theorem us_jp_set_mario_action_resets_control_state_source_shape :
  assigns_field_named_s AD_USMario._action
      (fn_body AD_USMario.f_set_mario_action) = true /\
  assigns_field_int_constant_s AD_USMario._actionState 0
      (fn_body AD_USMario.f_set_mario_action) = true /\
  assigns_field_int_constant_s AD_USMario._actionTimer 0
      (fn_body AD_USMario.f_set_mario_action) = true /\
  assigns_field_named_s AD_USMario._actionArg
      (fn_body AD_USMario.f_set_mario_action) = true /\
  assigns_field_named_s AD_JPMario._action
      (fn_body AD_JPMario.f_set_mario_action) = true /\
  assigns_field_int_constant_s AD_JPMario._actionState 0
      (fn_body AD_JPMario.f_set_mario_action) = true /\
  assigns_field_int_constant_s AD_JPMario._actionTimer 0
      (fn_body AD_JPMario.f_set_mario_action) = true /\
  assigns_field_named_s AD_JPMario._actionArg
      (fn_body AD_JPMario.f_set_mario_action) = true.
Proof. vm_compute. repeat split; reflexivity. Qed.

(** [sLongJumpLandAction] is source-treated as a constant descriptor but is
    emitted as writable storage.  Its initial [numFrames] is 6 and the only
    explicit address-taking body is [act_long_jump_land].  There is no normal
    generated direct assignment to the descriptor global, [numFrames], or any
    transition-valued [LandingAction] field.  This does *not* make the
    descriptor immutable:
    aliases, pointer arithmetic, out-of-bounds stores, and external effects can
    target its writable block until a linked memory-frame theorem excludes
    them.  Corrupting [numFrames] above 6 would extend the timer window in
    which [common_landing_action]'s depth delta becomes increasingly negative;
    corrupting an action field could instead forge a transition value. *)
Theorem us_jp_long_jump_landing_descriptor_source_boundary :
  gvar_readonly AD_USMove.v_sLongJumpLandAction = false /\
  gvar_init AD_USMove.v_sLongJumpLandAction =
    [Init_int16 (Int.repr 6); Init_int16 (Int.repr 5);
     Init_int32 (Int.repr 16779404); Init_int32 (Int.repr 134218299);
     Init_int32 (Int.repr 50333832); Init_int32 (Int.repr 16779404);
     Init_int32 (Int.repr 80)] /\
  internal_function_assignment_sites
      AD_USMove._sLongJumpLandAction us_generated_definitions = [] /\
  internal_function_address_sites
      AD_USMove._sLongJumpLandAction us_generated_definitions =
    [AD_USMove._act_long_jump_land] /\
  map (fun field =>
         internal_field_assignment_sites field us_generated_definitions)
    [AD_USMove._numFrames; AD_USMove._verySteepAction; AD_USMove._endAction;
     AD_USMove._aPressedAction; AD_USMove._offFloorAction;
     AD_USMove._slideAction] =
    [[]; []; []; []; []; []] /\
  map (fun field => internal_field_address_sites field us_generated_definitions)
    [AD_USMove._numFrames; AD_USMove._unk02;
     AD_USMove._verySteepAction; AD_USMove._endAction;
     AD_USMove._aPressedAction; AD_USMove._offFloorAction;
     AD_USMove._slideAction] =
    [[]; []; []; []; []; []; []] /\
  gvar_readonly AD_JPMove.v_sLongJumpLandAction = false /\
  gvar_init AD_JPMove.v_sLongJumpLandAction =
    [Init_int16 (Int.repr 6); Init_int16 (Int.repr 5);
     Init_int32 (Int.repr 16779404); Init_int32 (Int.repr 134218299);
     Init_int32 (Int.repr 50333832); Init_int32 (Int.repr 16779404);
     Init_int32 (Int.repr 80)] /\
  internal_function_assignment_sites
      AD_JPMove._sLongJumpLandAction jp_generated_definitions_for_alias = [] /\
  internal_function_address_sites
      AD_JPMove._sLongJumpLandAction jp_generated_definitions_for_alias =
    [AD_JPMove._act_long_jump_land] /\
  map (fun field =>
         internal_field_assignment_sites
           field jp_generated_definitions_for_alias)
    [AD_JPMove._numFrames; AD_JPMove._verySteepAction; AD_JPMove._endAction;
     AD_JPMove._aPressedAction; AD_JPMove._offFloorAction;
     AD_JPMove._slideAction] =
    [[]; []; []; []; []; []] /\
  map (fun field =>
         internal_field_address_sites
           field jp_generated_definitions_for_alias)
    [AD_JPMove._numFrames; AD_JPMove._unk02;
     AD_JPMove._verySteepAction; AD_JPMove._endAction;
     AD_JPMove._aPressedAction; AD_JPMove._offFloorAction;
     AD_JPMove._slideAction] =
    [[]; []; []; []; []; []; []].
Proof. vm_compute. repeat split; reflexivity. Qed.

Definition ActionDepthAliasSyntaxBoundary : Prop :=
  us_depth_direct_writer_sites =
    [AD_USMario._init_mario;
     AD_USAir._check_common_airborne_cancels;
     AD_USAuto._mario_execute_automatic_action;
     AD_USCut._act_quicksand_death;
     AD_USMove._common_landing_action;
     AD_USMove._quicksand_jump_land_action;
     AD_USSubmerged._mario_execute_submerged_action;
     AD_USStep._mario_update_quicksand] /\
  length us_action_state_direct_writer_sites = 60%nat /\
  length us_action_timer_direct_writer_sites = 74%nat /\
  length us_action_arg_direct_writer_sites = 14%nat /\
  internal_indirect_struct_pointer_call_sites
      AD_USMario._MarioState us_generated_definitions =
    [AD_USMove._common_landing_cancels;
     AD_USInteraction._mario_process_interactions] /\
  internal_indirect_struct_pointer_call_sites
      AD_JPMario._MarioState jp_generated_definitions_for_alias =
    [AD_JPMove._common_landing_cancels;
     AD_JPInteraction._mario_process_interactions] /\
  gvar_readonly AD_USMove.v_sLongJumpLandAction = false /\
  gvar_readonly AD_JPMove.v_sLongJumpLandAction = false /\
  internal_function_assignment_sites
      AD_USMove._sLongJumpLandAction us_generated_definitions = [] /\
  internal_function_assignment_sites
      AD_JPMove._sLongJumpLandAction jp_generated_definitions_for_alias = [].

Theorem action_depth_alias_syntax_boundary_holds :
  ActionDepthAliasSyntaxBoundary.
Proof.
  unfold ActionDepthAliasSyntaxBoundary.
  repeat split; vm_compute; reflexivity.
Qed.
