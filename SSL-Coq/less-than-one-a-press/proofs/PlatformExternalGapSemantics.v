(** Generic semantic closure for alias origins and unresolved external calls.

    This module is intentionally independent of the large official retail
    programs.  A later, small specialization supplies the checked US/JP
    address-taking and initializer receipts. *)

From Coq Require Import List ZArith.
From compcert Require Import AST Clight Ctypes Events Memory Smallstep Values.
From LessThanOneAPress.Proofs Require Import
  ASTFacts ClightLinkExecution RetailExternalFrameReachability.

Import ListNotations.
Local Open Scope Z_scope.

Inductive PlatformCellSemanticAliasEscape : Type :=
| PlatformAliasPreexisting
| PlatformAliasExternalProduced
| PlatformAliasIntegerFabricated
| PlatformAliasOutOfBounds.

Inductive PlatformCellAliasOrigin
    (program : Clight.program) (cell : ident) : Type :=
| PlatformAliasInternalAddress :
    forall id body,
      In (id, Gfun (Internal body)) program.(prog_defs) ->
      statement_takes_address_of_ident_s cell (fn_body body) = true ->
      PlatformCellAliasOrigin program cell
| PlatformAliasInitializerRelocation :
    In cell (program_init_addrof_identifiers program) ->
    PlatformCellAliasOrigin program cell
| PlatformAliasSemanticEscape :
    PlatformCellSemanticAliasEscape ->
    PlatformCellAliasOrigin program cell.

Definition semantic_platform_alias_escape
    {program cell} (origin : PlatformCellAliasOrigin program cell)
    : option PlatformCellSemanticAliasEscape :=
  match origin with
  | @PlatformAliasInternalAddress _ _ _ _ _ _ => None
  | @PlatformAliasInitializerRelocation _ _ _ => None
  | @PlatformAliasSemanticEscape _ _ escape => Some escape
  end.

Theorem no_ordinary_platform_alias_source_leaves_semantic_escape :
  forall program cell,
    (forall id body,
      In (id, Gfun (Internal body)) program.(prog_defs) ->
      statement_takes_address_of_ident_s cell (fn_body body) = false) ->
    ~ In cell (program_init_addrof_identifiers program) ->
    forall origin : PlatformCellAliasOrigin program cell,
      exists escape,
        semantic_platform_alias_escape origin = Some escape.
Proof.
  intros program cell Hno_address Hno_initializer origin.
  destruct origin as
      [id body Hin Haddress | Hinitializer | escape].
  - pose proof (Hno_address id body Hin) as Habsent. congruence.
  - exfalso. exact (Hno_initializer Hinitializer).
  - exists escape. reflexivity.
Qed.

(** CompCert blocks make one large alias family impossible in every defined
    store step.  If synchronized Object and State loads become unequal after
    one successful [Mem.store], the store's block is the Object block or the
    State block.  Pointer arithmetic within a third allocation cannot wrap
    across the abstract block boundary. *)
Theorem defined_store_creating_object_state_gap_targets_one_endpoint :
  forall before after write_chunk write_block write_offset write_value
      object_chunk object_block object_offset
      state_chunk state_block state_offset synchronized object_after state_after,
    Mem.store write_chunk before write_block write_offset write_value =
      Some after ->
    Mem.load object_chunk before object_block object_offset =
      Some synchronized ->
    Mem.load state_chunk before state_block state_offset =
      Some synchronized ->
    Mem.load object_chunk after object_block object_offset =
      Some object_after ->
    Mem.load state_chunk after state_block state_offset = Some state_after ->
    object_after <> state_after ->
    write_block = object_block \/ write_block = state_block.
Proof.
  intros before after write_chunk write_block write_offset write_value
    object_chunk object_block object_offset state_chunk state_block state_offset
    synchronized object_after state_after Hstore Hobject_before Hstate_before
    Hobject_after Hstate_after Hgap.
  destruct (Pos.eq_dec write_block object_block) as [Hobject | Hnot_object].
  - now left.
  - destruct (Pos.eq_dec write_block state_block) as [Hstate | Hnot_state].
    + now right.
    + exfalso. apply Hgap.
      assert (Hobject_preserved :
        Mem.load object_chunk after object_block object_offset =
          Some synchronized).
      { rewrite <- Hobject_before.
        eapply Mem.load_store_other; eauto. }
      assert (Hstate_preserved :
        Mem.load state_chunk after state_block state_offset =
          Some synchronized).
      { rewrite <- Hstate_before.
        eapply Mem.load_store_other; eauto. }
      congruence.
Qed.

(** This theorem applies after either a direct or an indirect callsite has
    entered the unresolved external [Callstate]. *)
Theorem reachable_unresolved_external_changed_load_is_refined :
  forall program origin protected writer
      initial reach_trace name signature argument_types result_type
      calling_convention arguments continuation before step_trace result after
      chunk block offset before_value after_value,
    CallsiteSensitiveUnresolvedExternalInventory
      program origin protected writer ->
    origin initial ->
    @Smallstep.star _ _ Clight.step2 (Clight.globalenv program)
      initial reach_trace
      (Callstate (External (EF_external name signature) argument_types
        result_type calling_convention) arguments continuation before) ->
    Clight.step2 (Clight.globalenv program)
      (Callstate (External (EF_external name signature) argument_types
        result_type calling_convention) arguments continuation before)
      step_trace (Returnstate result continuation after) ->
    (forall byte_offset,
      offset <= byte_offset < offset + size_chunk chunk ->
      protected (EF_external name signature) arguments before
        block byte_offset) ->
    Mem.load chunk before block offset = Some before_value ->
    Mem.load chunk after block offset = Some after_value ->
    before_value <> after_value ->
    writer (EF_external name signature) arguments before step_trace result
      after.
Proof.
  intros program origin protected writer initial reach_trace name signature
    argument_types result_type calling_convention arguments continuation
    before step_trace result after chunk block offset before_value after_value
    Hinventory Horigin Hreachable Hstep Hprotected Hbefore Hafter Hchanged.
  destruct Hinventory as [Hclassified].
  destruct (Hclassified initial reach_trace name signature argument_types
    result_type calling_convention arguments continuation before step_trace
    result after Horigin Hreachable Hstep) as [Hframe | Hwriter].
  - exfalso. apply Hchanged.
    assert (Hpreserved :
      Mem.load chunk after block offset = Some before_value).
    { eapply Mem.load_unchanged_on; eauto. }
    congruence.
  - exact Hwriter.
Qed.

(** Starting from equal protected Object and State loads, an unresolved
    external step cannot leave them unequal unless the inventory explicitly
    classifies that exact call as a writer/lifecycle effect. *)
Theorem reachable_unresolved_external_created_object_state_gap_is_refined :
  forall program origin protected writer
      initial reach_trace name signature argument_types result_type
      calling_convention arguments continuation before step_trace result after
      object_chunk object_block object_offset
      state_chunk state_block state_offset synchronized object_after state_after,
    CallsiteSensitiveUnresolvedExternalInventory
      program origin protected writer ->
    origin initial ->
    @Smallstep.star _ _ Clight.step2 (Clight.globalenv program)
      initial reach_trace
      (Callstate (External (EF_external name signature) argument_types
        result_type calling_convention) arguments continuation before) ->
    Clight.step2 (Clight.globalenv program)
      (Callstate (External (EF_external name signature) argument_types
        result_type calling_convention) arguments continuation before)
      step_trace (Returnstate result continuation after) ->
    (forall byte_offset,
      object_offset <= byte_offset <
        object_offset + size_chunk object_chunk ->
      protected (EF_external name signature) arguments before
        object_block byte_offset) ->
    (forall byte_offset,
      state_offset <= byte_offset < state_offset + size_chunk state_chunk ->
      protected (EF_external name signature) arguments before
        state_block byte_offset) ->
    Mem.load object_chunk before object_block object_offset =
      Some synchronized ->
    Mem.load state_chunk before state_block state_offset =
      Some synchronized ->
    Mem.load object_chunk after object_block object_offset =
      Some object_after ->
    Mem.load state_chunk after state_block state_offset = Some state_after ->
    object_after <> state_after ->
    writer (EF_external name signature) arguments before step_trace result
      after.
Proof.
  intros program origin protected writer initial reach_trace name signature
    argument_types result_type calling_convention arguments continuation
    before step_trace result after object_chunk object_block object_offset
    state_chunk state_block state_offset synchronized object_after state_after
    Hinventory Horigin Hreachable Hstep Hobject_protected Hstate_protected
    Hobject_before Hstate_before Hobject_after Hstate_after Hgap.
  destruct Hinventory as [Hclassified].
  destruct (Hclassified initial reach_trace name signature argument_types
    result_type calling_convention arguments continuation before step_trace
    result after Horigin Hreachable Hstep) as [Hframe | Hwriter].
  - exfalso. apply Hgap.
    assert (Hobject_preserved :
      Mem.load object_chunk after object_block object_offset =
        Some synchronized).
    { eapply Mem.load_unchanged_on; eauto. }
    assert (Hstate_preserved :
      Mem.load state_chunk after state_block state_offset =
        Some synchronized).
    { eapply Mem.load_unchanged_on; eauto. }
    congruence.
  - exact Hwriter.
Qed.
