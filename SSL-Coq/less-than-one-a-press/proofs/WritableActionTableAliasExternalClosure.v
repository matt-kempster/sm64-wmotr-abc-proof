(** Defined-alias and abstract-external closure for the writable action tables.

    The earlier table audit used [statement_assigns_ident_s].  That predicate
    intentionally recognizes only a direct assignment whose left side is the
    selected [Evar]; it does not recognize an array-element lvalue rooted at
    that global.  The occurrence-sensitive checker below closes that gap.  It
    accepts a table occurrence only when the complete right-hand side of an
    [Sset] is a terminal by-value load.  In particular it rejects occurrences
    in an assignment, call target, call argument, builtin argument, branch
    condition, return value, or a non-load temporary expression.

    The computed US and JP receipts show that all four source occurrences per
    version are the expected reads: two handler-record loads in
    [mario_process_interactions], and one read from each knockback table in
    [determine_knockback_action].  The tables are also absent from the owning
    translation unit's public interface and from every initializer relocation
    in that unit.  Consequently another separately compiled unit cannot name
    the owning global block through CompCert's public-symbol interface.

    The semantic half uses CompCert's actual [external_call_mem_inject_gen]
    consequence.  If a private valid table block is deliberately omitted from
    a self-injection, an abstract external call preserves every byte of that
    block and cannot return a pointer to it.  A self-injected store address
    likewise cannot be a pointer into an omitted block.  Thus an outside call
    is not an independent table-writer escape: it would first need a table
    alias in its arguments or violate CompCert's external-call axioms.

    This file does not cover out-of-bounds machine stores, ACE, DMA, or a
    continuation after C undefined behavior. *)

From Coq Require Import List ZArith.
From compcert Require Import
  AST Clight Cop Ctypes Events Globalenvs Memory Values.
From LessThanOneAPress.Generated Require Import us_interaction jp_interaction.
From LessThanOneAPress.Proofs Require Import
  ASTFacts ClightLinkExecution InkTimer131CorruptionClosure
  NegativeDepthInteractionClosure.

Import ListNotations.
Local Open Scope Z_scope.

Module WATAE_US := us_interaction.
Module WATAE_JP := jp_interaction.

(** * Occurrence-sensitive source audit *)

Fixpoint wat_evar_count (target : ident) (expression : expr) : nat :=
  match expression with
  | Evar found _ => if Pos.eqb found target then 1%nat else 0%nat
  | Ederef inner _ | Eaddrof inner _ | Eunop _ inner _ | Ecast inner _ =>
      wat_evar_count target inner
  | Efield inner _ _ => wat_evar_count target inner
  | Ebinop _ left_expression right_expression _ =>
      (wat_evar_count target left_expression +
       wat_evar_count target right_expression)%nat
  | _ => 0%nat
  end.

Definition wat_expression_list_evar_count
    (target : ident) (expressions : list expr) : nat :=
  fold_right
    (fun expression count =>
      (wat_evar_count target expression + count)%nat)
    0%nat expressions.

(** A protected table address is allowed to flow only through pointer
    addition and through a by-reference/by-copy array or record dereference.
    This is the exact address grammar used by the generated two-dimensional
    knockback reads and the interaction-record reads.  In particular, a
    by-value dereference cannot be used as an intermediate address producer. *)
Definition wat_access_mode_is_pointer_result (value_type : type) : bool :=
  match access_mode value_type with
  | By_reference | By_copy => true
  | _ => false
  end.

Definition wat_access_mode_is_value_read (value_type : type) : bool :=
  match access_mode value_type with
  | By_value _ => true
  | _ => false
  end.

Fixpoint wat_is_table_rooted_pointer
    (target : ident) (expression : expr) : bool :=
  match expression with
  | Evar found value_type =>
      Pos.eqb found target &&
      wat_access_mode_is_pointer_result value_type
  | Ebinop Oadd left_expression right_expression _ =>
      wat_is_table_rooted_pointer target left_expression &&
      Nat.eqb (wat_evar_count target right_expression) 0 &&
      match classify_add (typeof left_expression) (typeof right_expression) with
      | add_case_pi _ _ => true
      | _ => false
      end
  | Ederef address value_type =>
      wat_is_table_rooted_pointer target address &&
      wat_access_mode_is_pointer_result value_type
  | _ => false
  end.

(** The generated readers have one of these two shapes:

    - [Ederef address value_type] for a knockback action word;
    - [Efield (Ederef address record_type) field value_type] for a handler
      record field.

    Requiring exactly one occurrence prevents this recognizer from hiding a
    second use elsewhere in the same expression. *)
Definition wat_is_terminal_table_read
    (target : ident) (expression : expr) : bool :=
  match expression with
  | Ederef address value_type =>
      Nat.eqb (wat_evar_count target address) 1 &&
      wat_is_table_rooted_pointer target address &&
      wat_access_mode_is_value_read value_type
  | Efield record_expression _ value_type =>
      Nat.eqb (wat_evar_count target record_expression) 1 &&
      wat_is_table_rooted_pointer target record_expression &&
      wat_access_mode_is_value_read value_type
  | _ => false
  end.

Fixpoint wat_statement_access_safe_s
    (target : ident) (statement : statement) : bool :=
  match statement with
  | Sskip | Sbreak | Scontinue | Sreturn None | Sgoto _ => true
  | Sassign left_expression right_expression =>
      Nat.eqb
        (wat_evar_count target left_expression +
         wat_evar_count target right_expression) 0
  | Sset _ right_expression =>
      match wat_evar_count target right_expression with
      | O => true
      | _ => wat_is_terminal_table_read target right_expression
      end
  | Scall _ function arguments =>
      Nat.eqb
        (wat_evar_count target function +
         wat_expression_list_evar_count target arguments) 0
  | Sbuiltin _ _ _ arguments =>
      Nat.eqb (wat_expression_list_evar_count target arguments) 0
  | Ssequence first second | Sloop first second =>
      wat_statement_access_safe_s target first &&
      wat_statement_access_safe_s target second
  | Sifthenelse condition yes_branch no_branch =>
      Nat.eqb (wat_evar_count target condition) 0 &&
      wat_statement_access_safe_s target yes_branch &&
      wat_statement_access_safe_s target no_branch
  | Sreturn (Some value) => Nat.eqb (wat_evar_count target value) 0
  | Sswitch value cases =>
      Nat.eqb (wat_evar_count target value) 0 &&
      wat_statement_access_safe_ls target cases
  | Slabel _ body => wat_statement_access_safe_s target body
  end
with wat_statement_access_safe_ls
    (target : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => true
  | LScons _ body rest =>
      wat_statement_access_safe_s target body &&
      wat_statement_access_safe_ls target rest
  end.

Fixpoint wat_terminal_read_count_s
    (target : ident) (statement : statement) : nat :=
  match statement with
  | Sset _ right_expression =>
      if wat_is_terminal_table_read target right_expression
      then 1%nat else 0%nat
  | Ssequence first second | Sloop first second =>
      (wat_terminal_read_count_s target first +
       wat_terminal_read_count_s target second)%nat
  | Sifthenelse _ yes_branch no_branch =>
      (wat_terminal_read_count_s target yes_branch +
       wat_terminal_read_count_s target no_branch)%nat
  | Sswitch _ cases => wat_terminal_read_count_ls target cases
  | Slabel _ body => wat_terminal_read_count_s target body
  | _ => 0%nat
  end
with wat_terminal_read_count_ls
    (target : ident) (cases : labeled_statements) : nat :=
  match cases with
  | LSnil => 0%nat
  | LScons _ body rest =>
      (wat_terminal_read_count_s target body +
       wat_terminal_read_count_ls target rest)%nat
  end.

Definition wat_ident_in_unit_init_addrof
    (target : ident) (program : Clight.program) : bool :=
  ident_mem target (program_init_addrof_identifiers program).

Definition WritableActionTableNoAliasSourceReceipt : Prop :=
  ink_dispatch_table_named_source_claim /\
  ndi_knockback_table_named_source_claim /\
  wat_statement_access_safe_s WATAE_US._sInteractionHandlers
      (fn_body WATAE_US.f_mario_process_interactions) = true /\
  wat_terminal_read_count_s WATAE_US._sInteractionHandlers
      (fn_body WATAE_US.f_mario_process_interactions) = 2%nat /\
  wat_statement_access_safe_s WATAE_JP._sInteractionHandlers
      (fn_body WATAE_JP.f_mario_process_interactions) = true /\
  wat_terminal_read_count_s WATAE_JP._sInteractionHandlers
      (fn_body WATAE_JP.f_mario_process_interactions) = 2%nat /\
  wat_statement_access_safe_s WATAE_US._sForwardKnockbackActions
      (fn_body WATAE_US.f_determine_knockback_action) = true /\
  wat_terminal_read_count_s WATAE_US._sForwardKnockbackActions
      (fn_body WATAE_US.f_determine_knockback_action) = 1%nat /\
  wat_statement_access_safe_s WATAE_US._sBackwardKnockbackActions
      (fn_body WATAE_US.f_determine_knockback_action) = true /\
  wat_terminal_read_count_s WATAE_US._sBackwardKnockbackActions
      (fn_body WATAE_US.f_determine_knockback_action) = 1%nat /\
  wat_statement_access_safe_s WATAE_JP._sForwardKnockbackActions
      (fn_body WATAE_JP.f_determine_knockback_action) = true /\
  wat_terminal_read_count_s WATAE_JP._sForwardKnockbackActions
      (fn_body WATAE_JP.f_determine_knockback_action) = 1%nat /\
  wat_statement_access_safe_s WATAE_JP._sBackwardKnockbackActions
      (fn_body WATAE_JP.f_determine_knockback_action) = true /\
  wat_terminal_read_count_s WATAE_JP._sBackwardKnockbackActions
      (fn_body WATAE_JP.f_determine_knockback_action) = 1%nat /\
  ident_mem WATAE_US._sInteractionHandlers WATAE_US.public_idents = false /\
  ident_mem WATAE_US._sForwardKnockbackActions WATAE_US.public_idents = false /\
  ident_mem WATAE_US._sBackwardKnockbackActions WATAE_US.public_idents = false /\
  ident_mem WATAE_JP._sInteractionHandlers WATAE_JP.public_idents = false /\
  ident_mem WATAE_JP._sForwardKnockbackActions WATAE_JP.public_idents = false /\
  ident_mem WATAE_JP._sBackwardKnockbackActions WATAE_JP.public_idents = false /\
  wat_ident_in_unit_init_addrof
      WATAE_US._sInteractionHandlers WATAE_US.prog = false /\
  wat_ident_in_unit_init_addrof
      WATAE_US._sForwardKnockbackActions WATAE_US.prog = false /\
  wat_ident_in_unit_init_addrof
      WATAE_US._sBackwardKnockbackActions WATAE_US.prog = false /\
  wat_ident_in_unit_init_addrof
      WATAE_JP._sInteractionHandlers WATAE_JP.prog = false /\
  wat_ident_in_unit_init_addrof
      WATAE_JP._sForwardKnockbackActions WATAE_JP.prog = false /\
  wat_ident_in_unit_init_addrof
      WATAE_JP._sBackwardKnockbackActions WATAE_JP.prog = false.

Theorem writable_action_tables_have_only_terminal_private_reads :
  WritableActionTableNoAliasSourceReceipt.
Proof.
  unfold WritableActionTableNoAliasSourceReceipt,
    wat_ident_in_unit_init_addrof.
  split; [exact ink_dispatch_tables_have_only_stock_named_source_uses |].
  split; [exact knockback_action_tables_have_no_named_source_writer |].
  vm_compute. repeat split; reflexivity.
Qed.

(** * Store and external-call semantic closure *)

Definition ActionTablePrivateExternalReady
    (ge : Senv.t) (arguments : list val) (before : mem)
    (protected_blocks : list block) : Prop :=
  exists injection,
    symbols_inject injection ge ge /\
    Mem.inject injection before before /\
    Val.inject_list injection arguments arguments /\
    forall protected_block,
      In protected_block protected_blocks ->
      injection protected_block = None.

(** This is the ordinary global-memory fact needed to carry
    [symbols_inject] when an external call extends an injection.  A block that
    names a global or is marked volatile by the same symbol environment is
    already valid in the pre-call memory, so [inject_separated] prevents it
    from acquiring a brand-new mapping. *)
Definition ActionTableGlobalBlocksValid (ge : Senv.t) (before : mem) : Prop :=
  (forall identifier global_block,
    Senv.find_symbol ge identifier = Some global_block ->
    Mem.valid_block before global_block) /\
  (forall global_block,
    Senv.block_is_volatile ge global_block = true ->
    Mem.valid_block before global_block).

Lemma symbols_inject_preserved_by_separated_extension :
  forall ge before injection injection',
    symbols_inject injection ge ge ->
    inject_incr injection injection' ->
    inject_separated injection injection' before before ->
    ActionTableGlobalBlocksValid ge before ->
    symbols_inject injection' ge ge.
Proof.
  intros ge before injection injection'
    [Hpublic [Hmapped [Hpublic_mapped Hvolatile]]]
    Hincr Hseparated [Hsymbol_valid Hvolatile_valid].
  unfold symbols_inject.
  split; [exact Hpublic |].
  split.
  - intros identifier source_block target_block delta
      Htarget_mapping Hsymbol.
    destruct (injection source_block) as [[old_target old_delta] |]
      eqn:Hsource_mapping.
    + assert (Hsame : injection' source_block = Some (old_target, old_delta)).
      { now apply Hincr. }
      rewrite Hsame in Htarget_mapping.
      inversion Htarget_mapping. subst target_block delta.
      now apply (Hmapped identifier source_block old_target old_delta).
    + exfalso.
      destruct (Hseparated source_block target_block delta
        Hsource_mapping Htarget_mapping) as [Hinvalid _].
      exact (Hinvalid (Hsymbol_valid identifier source_block Hsymbol)).
  - split.
    + intros identifier source_block Hidentifier_public Hsymbol.
      destruct (Hpublic_mapped identifier source_block
        Hidentifier_public Hsymbol) as [target_block [Hmapping Htarget_symbol]].
      exists target_block. split; [now apply Hincr | exact Htarget_symbol].
    + intros source_block target_block delta Htarget_mapping.
      destruct (injection source_block) as [[old_target old_delta] |]
        eqn:Hsource_mapping.
      * assert (Hsame :
          injection' source_block = Some (old_target, old_delta)).
        { now apply Hincr. }
        rewrite Hsame in Htarget_mapping.
        inversion Htarget_mapping. subst target_block delta.
        now apply (Hvolatile source_block old_target old_delta).
      * destruct (Hseparated source_block target_block delta
          Hsource_mapping Htarget_mapping) as [Hsource_invalid Htarget_invalid].
        assert (Hsource_not_volatile :
          Senv.block_is_volatile ge source_block = false).
        { destruct (Senv.block_is_volatile ge source_block) eqn:Hsource;
            [| reflexivity].
          exfalso. exact (Hsource_invalid
            (Hvolatile_valid source_block Hsource)). }
        assert (Htarget_not_volatile :
          Senv.block_is_volatile ge target_block = false).
        { destruct (Senv.block_is_volatile ge target_block) eqn:Htarget;
            [| reflexivity].
          exfalso. exact (Htarget_invalid
            (Hvolatile_valid target_block Htarget)). }
        now rewrite Hsource_not_volatile, Htarget_not_volatile.
Qed.

Theorem self_injected_value_is_not_a_private_pointer :
  forall injection value protected_blocks protected_block offset,
    Val.inject injection value value ->
    (forall block, In block protected_blocks -> injection block = None) ->
    In protected_block protected_blocks ->
    value <> Vptr protected_block offset.
Proof.
  intros injection value protected_blocks protected_block offset
    Hinjected Homitted Hin Hvalue.
  subst value. inversion Hinjected; subst.
  specialize (Homitted protected_block Hin). congruence.
Qed.

Theorem self_injected_store_address_cannot_target_private_block :
  forall injection address value chunk before after
      protected_blocks protected_block offset,
    Val.inject injection address address ->
    (forall block, In block protected_blocks -> injection block = None) ->
    In protected_block protected_blocks ->
    Mem.storev chunk before address value = Some after ->
    address <> Vptr protected_block offset.
Proof.
  intros injection address value chunk before after protected_blocks
    protected_block offset Hinjected Homitted Hin _.
  eapply self_injected_value_is_not_a_private_pointer; eauto.
Qed.

Theorem abstract_external_call_preserves_private_action_table_blocks :
  forall ge arguments before trace result after external protected_blocks,
    ActionTablePrivateExternalReady ge arguments before protected_blocks ->
    external_call external ge arguments before trace result after ->
    Mem.unchanged_on
      (fun block _ => In block protected_blocks) before after.
Proof.
  intros ge arguments before trace result after external protected_blocks
    [injection [Hsymbols [Hmemory [Harguments Homitted]]]] Hcall.
  destruct (external_call_executes_under_memory_injection
    external ge ge arguments before trace result after injection before
    arguments Hsymbols Hcall Hmemory Harguments)
    as [injection' [target_result [target_after
      [Htarget_call [Hresult [Hafter [Hunmapped Hrest]]]]]]].
  eapply Mem.unchanged_on_implies; eauto.
  intros block offset Hin Hvalid.
  unfold loc_unmapped.
  now apply Homitted.
Qed.

Theorem abstract_external_call_cannot_return_private_action_table_pointer :
  forall ge arguments before trace result after external protected_blocks
      protected_block offset,
    ActionTablePrivateExternalReady ge arguments before protected_blocks ->
    external_call external ge arguments before trace result after ->
    In protected_block protected_blocks ->
    Mem.valid_block before protected_block ->
    result <> Vptr protected_block offset.
Proof.
  intros ge arguments before trace result after external protected_blocks
    protected_block offset
    [injection [Hsymbols [Hmemory [Harguments Homitted]]]]
    Hcall Hin Hvalid Hresult_value.
  subst result.
  destruct (external_call_executes_under_memory_injection
    external ge ge arguments before trace (Vptr protected_block offset) after
    injection before arguments Hsymbols Hcall Hmemory Harguments)
    as (injection' & target_result & target_after & Htarget_call & Hresult &
      Hafter & Hunmapped & Hout_of_reach & Hincr & Hseparated).
  inversion Hresult; subst.
  match goal with
  | Hmapped : injection' protected_block = Some (?target_block, ?delta) |- _ =>
      destruct (Hseparated protected_block target_block delta
        (Homitted protected_block Hin) Hmapped) as [Hinvalid _];
      exact (Hinvalid Hvalid)
  end.
Qed.

(** Because CompCert external calls are deterministic when the trace is held
    fixed, the target execution manufactured by the injection theorem is the
    very same execution.  Hence the post-call memory and result inject into
    themselves under an extended injection.  [inject_separated] additionally
    proves that an already-valid omitted table block stays omitted.  This is
    stronger than a byte frame: the call cannot hide a fresh table pointer in
    its result or in any mapped post-call memory block. *)
Theorem abstract_external_call_preserves_private_injection :
  forall ge arguments before trace result after external protected_blocks,
    ActionTablePrivateExternalReady ge arguments before protected_blocks ->
    ActionTableGlobalBlocksValid ge before ->
    (forall protected_block,
      In protected_block protected_blocks ->
      Mem.valid_block before protected_block) ->
    external_call external ge arguments before trace result after ->
    exists injection',
      symbols_inject injection' ge ge /\
      Val.inject injection' result result /\
      Mem.inject injection' after after /\
      (forall protected_block,
        In protected_block protected_blocks ->
        injection' protected_block = None).
Proof.
  intros ge arguments before trace result after external protected_blocks
    [injection [Hsymbols [Hmemory [Harguments Homitted]]]]
    Hglobal_valid Hprotected_valid Hcall.
  destruct (external_call_executes_under_memory_injection
    external ge ge arguments before trace result after injection before
    arguments Hsymbols Hcall Hmemory Harguments)
    as (injection' & target_result & target_after & Htarget_call & Hresult &
      Hafter & Hunmapped & Hout_of_reach & Hincr & Hseparated).
  destruct (external_call_deterministic
    external ge arguments before trace result after
    target_result target_after Hcall Htarget_call)
    as [Hresult_equal Hafter_equal].
  subst target_result. subst target_after.
  exists injection'.
  split.
  { eapply symbols_inject_preserved_by_separated_extension; eauto. }
  split; [exact Hresult |].
  split; [exact Hafter |].
  intros protected_block Hin.
  destruct (injection' protected_block) as [[target_block delta] |]
    eqn:Hmapped; [| reflexivity].
  exfalso.
  destruct (Hseparated protected_block target_block delta
    (Homitted protected_block Hin) Hmapped) as [Hinvalid _].
  exact (Hinvalid (Hprotected_valid protected_block Hin)).
Qed.

(** The compositional form keeps the incoming witness explicit and returns
    the very extension manufactured by CompCert's external-call simulation.
    This extra [inject_incr] fact is what permits consecutive live steps to
    share one growing injection instead of choosing unrelated witnesses. *)
Theorem abstract_external_call_carries_explicit_private_injection :
  forall ge arguments before trace result after external protected_blocks
      injection,
    symbols_inject injection ge ge ->
    Mem.inject injection before before ->
    Val.inject_list injection arguments arguments ->
    (forall protected_block,
      In protected_block protected_blocks ->
      injection protected_block = None) ->
    ActionTableGlobalBlocksValid ge before ->
    (forall protected_block,
      In protected_block protected_blocks ->
      Mem.valid_block before protected_block) ->
    external_call external ge arguments before trace result after ->
    exists injection',
      symbols_inject injection' ge ge /\
      Val.inject injection' result result /\
      Mem.inject injection' after after /\
      inject_incr injection injection' /\
      (forall protected_block,
        In protected_block protected_blocks ->
        injection' protected_block = None).
Proof.
  intros ge arguments before trace result after external protected_blocks
    injection Hsymbols Hmemory Harguments Homitted Hglobal_valid
    Hprotected_valid Hcall.
  destruct (external_call_executes_under_memory_injection
    external ge ge arguments before trace result after injection before
    arguments Hsymbols Hcall Hmemory Harguments)
    as (injection' & target_result & target_after & Htarget_call & Hresult &
      Hafter & Hunmapped & Hout_of_reach & Hincr & Hseparated).
  destruct (external_call_deterministic
    external ge arguments before trace result after
    target_result target_after Hcall Htarget_call)
    as [Hresult_equal Hafter_equal].
  subst target_result. subst target_after.
  exists injection'.
  split.
  { eapply symbols_inject_preserved_by_separated_extension; eauto. }
  split; [exact Hresult |].
  split; [exact Hafter |].
  split; [exact Hincr |].
  intros protected_block Hin.
  destruct (injection' protected_block) as [[target_block delta] |]
    eqn:Hmapped; [| reflexivity].
  exfalso.
  destruct (Hseparated protected_block target_block delta
    (Homitted protected_block Hin) Hmapped) as [Hinvalid _].
  exact (Hinvalid (Hprotected_valid protected_block Hin)).
Qed.

(** This is the exact current-model disposition.  The source half establishes
    that no table pointer is installed or handed off by any generated body or
    initializer.  The semantic half says that, once represented by the
    private-block self-injection, neither a defined store nor any CompCert
    abstract external can be the first producer. *)
Definition WritableActionTableDefinedProducerClosure : Prop :=
  WritableActionTableNoAliasSourceReceipt /\
  (forall injection value protected_blocks protected_block offset,
    Val.inject injection value value ->
    (forall block, In block protected_blocks -> injection block = None) ->
    In protected_block protected_blocks ->
    value <> Vptr protected_block offset) /\
  (forall ge arguments before trace result after external protected_blocks,
    ActionTablePrivateExternalReady ge arguments before protected_blocks ->
    external_call external ge arguments before trace result after ->
    Mem.unchanged_on
      (fun block _ => In block protected_blocks) before after) /\
  (forall ge arguments before trace result after external protected_blocks,
    ActionTablePrivateExternalReady ge arguments before protected_blocks ->
    ActionTableGlobalBlocksValid ge before ->
    (forall protected_block,
      In protected_block protected_blocks ->
      Mem.valid_block before protected_block) ->
    external_call external ge arguments before trace result after ->
    exists injection',
      symbols_inject injection' ge ge /\
      Val.inject injection' result result /\
      Mem.inject injection' after after /\
      (forall protected_block,
        In protected_block protected_blocks ->
        injection' protected_block = None)).

Theorem writable_action_table_defined_producer_closure_holds :
  WritableActionTableDefinedProducerClosure.
Proof.
  unfold WritableActionTableDefinedProducerClosure.
  split; [exact writable_action_tables_have_only_terminal_private_reads |].
  split.
  - exact self_injected_value_is_not_a_private_pointer.
  - split.
    + exact abstract_external_call_preserves_private_action_table_blocks.
    + exact abstract_external_call_preserves_private_injection.
Qed.
