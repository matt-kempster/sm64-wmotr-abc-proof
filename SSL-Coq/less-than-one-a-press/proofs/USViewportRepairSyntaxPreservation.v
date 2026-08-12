(** Identifier-level syntax invariants of the viewport composite-tag repair. *)

From Coq Require Import List.
From compcert Require Import AST Clight Ctypes.
From LessThanOneAPress.Proofs Require Import
  ClightLinkExecution USWholeASTTagRepair.

Lemma rename_expr_tag_preserves_evar_identifiers :
  forall old fresh expression,
    expression_evar_identifiers
      (rename_expr_tag old fresh expression) =
    expression_evar_identifiers expression.
Proof.
  intros old fresh expression. induction expression; cbn; try reflexivity.
  all: repeat match goal with
       | IH : ?lhs = ?rhs |- context[?lhs] => rewrite IH
       end; reflexivity.
Qed.

Lemma rename_expr_list_tag_preserves_evar_identifiers :
  forall old fresh expressions,
    expression_list_evar_identifiers
      (map (rename_expr_tag old fresh) expressions) =
    expression_list_evar_identifiers expressions.
Proof.
  intros old fresh expressions.
  unfold expression_list_evar_identifiers.
  rewrite map_map.
  f_equal. apply map_ext. intros expression.
  apply rename_expr_tag_preserves_evar_identifiers.
Qed.

Scheme us_audit_statement_ind := Induction for statement Sort Prop
  with us_audit_labeled_statements_ind :=
    Induction for labeled_statements Sort Prop.
Combined Scheme us_audit_statement_labeled_ind
  from us_audit_statement_ind, us_audit_labeled_statements_ind.

Lemma rename_statement_labeled_tag_preserves_evar_identifiers :
  forall old fresh,
    (forall statement,
      statement_evar_identifiers
        (rename_statement_tag old fresh statement) =
      statement_evar_identifiers statement) /\
    (forall cases,
      labeled_statements_evar_identifiers
        (rename_labeled_statements_tag old fresh cases) =
      labeled_statements_evar_identifiers cases).
Proof.
  intros old fresh.
  apply us_audit_statement_labeled_ind; intros; cbn;
    repeat match goal with
    | value : option expr |- _ => destruct value; cbn
    end;
    repeat rewrite rename_expr_tag_preserves_evar_identifiers;
    repeat rewrite rename_expr_list_tag_preserves_evar_identifiers;
    congruence.
Qed.

Lemma rename_statement_tag_preserves_evar_identifiers :
  forall old fresh statement,
    statement_evar_identifiers
      (rename_statement_tag old fresh statement) =
    statement_evar_identifiers statement.
Proof.
  intros old fresh statement.
  exact (proj1
    (rename_statement_labeled_tag_preserves_evar_identifiers old fresh)
    statement).
Qed.

Lemma rename_statement_labeled_tag_preserves_direct_sbuiltins :
  forall old fresh,
    (forall statement,
      statement_direct_sbuiltins
        (rename_statement_tag old fresh statement) =
      statement_direct_sbuiltins statement) /\
    (forall cases,
      labeled_statements_direct_sbuiltins
        (rename_labeled_statements_tag old fresh cases) =
      labeled_statements_direct_sbuiltins cases).
Proof.
  intros old fresh.
  apply us_audit_statement_labeled_ind; intros; cbn; congruence.
Qed.

Lemma rename_statement_tag_preserves_direct_sbuiltins :
  forall old fresh statement,
    statement_direct_sbuiltins
      (rename_statement_tag old fresh statement) =
    statement_direct_sbuiltins statement.
Proof.
  intros old fresh statement.
  exact (proj1
    (rename_statement_labeled_tag_preserves_direct_sbuiltins old fresh)
    statement).
Qed.

Lemma map_fst_rename_typed_ident_tag :
  forall old fresh entries,
    map fst (map (rename_typed_ident_tag old fresh) entries) =
    map fst entries.
Proof.
  intros old fresh entries.
  induction entries as [| [id ty] rest IH]; cbn; [reflexivity |].
  now rewrite IH.
Qed.

Lemma rename_function_tag_preserves_local_identifiers :
  forall old fresh body,
    function_local_identifiers (rename_function_tag old fresh body) =
    function_local_identifiers body.
Proof.
  intros old fresh body.
  unfold function_local_identifiers, rename_function_tag. cbn.
  rewrite !map_app, !map_fst_rename_typed_ident_tag.
  reflexivity.
Qed.

Lemma repair_us_selected_global_definition_preserves_direct_sbuiltins :
  forall entry,
    global_definition_direct_sbuiltins
      (repair_us_selected_global_definition entry) =
    global_definition_direct_sbuiltins entry.
Proof.
  intros [id definition]. unfold repair_us_selected_global_definition.
  destruct (us_selected_definition_needs_viewport_repair (id, definition));
    [|reflexivity].
  destruct definition as [[body | external arguments result convention]
    | variable]; cbn [rename_globdef_tag rename_fundef_tag
      rename_function_tag]; try reflexivity.
  apply rename_statement_tag_preserves_direct_sbuiltins.
Qed.

Lemma repair_us_selected_global_definition_preserves_init_addrofs :
  forall entry,
    global_definition_init_addrof_identifiers
      (repair_us_selected_global_definition entry) =
    global_definition_init_addrof_identifiers entry.
Proof.
  intros [id definition]. unfold repair_us_selected_global_definition.
  destruct (us_selected_definition_needs_viewport_repair (id, definition));
    [|reflexivity].
  destruct definition as [[body | external arguments result convention]
    | variable]; reflexivity.
Qed.

Lemma repair_us_selected_global_definition_preserves_external_constructor :
  forall entry,
    external_global_has_supported_constructor
      (repair_us_selected_global_definition entry) =
    external_global_has_supported_constructor entry.
Proof.
  intros [id definition]. unfold repair_us_selected_global_definition.
  destruct (us_selected_definition_needs_viewport_repair (id, definition));
    [|reflexivity].
  destruct definition as [[body | external arguments result convention]
    | variable]; reflexivity.
Qed.
