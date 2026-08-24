(** Reached-state one-step coverage for the private writable action tables.

    The old memory-only coverage predicate quantified over fabricated Clight
    states and was therefore too strong: a fabricated temporary, environment,
    continuation, or call argument could already contain a protected-table
    pointer.  This module states the sound replacement over
    [watc_reached_state_is_private], and closes the data-producing cases that
    need more than a same-memory control argument:

      - [Sassign], including scalar/bitfield stores and block copies;
      - ordinary [Sset] expressions and the checker-recognized terminal reads;
      - direct [Sbuiltin] argument evaluation and its external-call carrier;
      - ordinary [Scall] function and argument evaluation;
      - internal and external function entry.

    The final theorem then inverts the real [Clight.step2] derivation and
    discharges every data, control, call-entry, return, and external-call
    constructor.  The cumulative entry frame and exact filtered initial
    injection remain explicit because a current-memory invariant alone does
    not constrain bytes in deliberately omitted table blocks. *)

From Coq Require Import Bool Classical List Lia ZArith.
From compcert Require Import
  AST Clight Coqlib Cop Ctypes Events Globalenvs Maps Memory Values.
From LessThanOneAPress.Proofs Require Import
  ClightEndToEndRefinement
  ClightLinkExecution
  SelectedClightTarget
  WritableActionTableAliasExternalClosure
  WritableActionTablePrivateInitialization
  WritableActionTablePrivateLive
  WritableActionTableSyntaxCoverage
  WritableActionTableWholeGameAliases
  WritableActionTableReachedControl
  WritableActionTableFunctionEntry
  WritableActionTableExpressionCoverage
  WritableActionTableTerminalReads.

Import ListNotations.
Local Open Scope Z_scope.

(** The supporting modules intentionally use separately named copies of
    the same pointwise predicates.  These conversion lemmas make the intended
    definitional equality explicit at their boundaries. *)
Lemma watps_control_environment_is_expression_environment :
  forall injection environment,
    watc_environment_self_injects injection environment ->
    watpc_environment_self_injects injection environment.
Proof. intros; exact H. Qed.

Lemma watps_control_temps_are_expression_temps :
  forall injection temporaries,
    watc_temps_self_inject injection temporaries ->
    watpc_temps_self_inject injection temporaries.
Proof. intros; exact H. Qed.

Lemma watps_entry_environment_is_control_environment :
  forall injection environment,
    watpa_environment_self_injects injection environment ->
    watc_environment_self_injects injection environment.
Proof. intros; exact H. Qed.

Lemma watps_entry_temps_are_control_temps :
  forall injection temporaries,
    watpa_temps_self_inject injection temporaries ->
    watc_temps_self_inject injection temporaries.
Proof. intros; exact H. Qed.

(** A checked [Sset] either contains no unshadowed protected global at all,
    or one concrete unshadowed protected identifier occurs and the checker
    has accepted the entire RHS as a terminal read rooted at that table. *)
Lemma watps_safe_set_rhs_is_ordinary_or_terminal :
  forall protected environment destination right_expression,
    watc_statement_is_private protected
      (Clight.Sset destination right_expression) ->
    watpc_expression_globals_avoid protected environment right_expression \/
    exists identifier,
      In identifier protected /\
      environment ! identifier = None /\
      wat_evar_count identifier right_expression <> 0%nat /\
      wat_is_terminal_table_read identifier right_expression = true.
Proof.
  intros protected environment destination right_expression Hsafe.
  destruct (classic
    (watpc_expression_globals_avoid
      protected environment right_expression)) as [Hordinary | Hnot].
  - now left.
  - right.
    assert (Hexists : exists identifier,
      In identifier protected /\
      environment ! identifier = None /\
      wat_evar_count identifier right_expression <> 0%nat).
    { apply NNPP. intros Hnone. apply Hnot.
      intros identifier Hin Hlocal.
      destruct (Nat.eq_dec
        (wat_evar_count identifier right_expression) 0%nat) as [Hzero | Hnz];
        [exact Hzero |].
      exfalso. apply Hnone. exists identifier. auto. }
    destruct Hexists as [identifier [Hin [Hlocal Hcount]]].
    exists identifier. repeat split; try assumption.
    pose proof (watc_safe_set_rhs_is_absent_or_terminal
      identifier destination right_expression (Hsafe identifier Hin))
      as Hclassification.
    inversion Hclassification; subst; [contradiction | assumption].
Qed.

(** Turn the whole-statement checker result into the environment-sensitive
    no-protected-global predicate consumed by the expression-injection proof. *)
Lemma watps_safe_assign_expressions_avoid_globals :
  forall protected environment left_expression right_expression,
    watc_statement_is_private protected
      (Clight.Sassign left_expression right_expression) ->
    watpc_expression_globals_avoid protected environment left_expression /\
    watpc_expression_globals_avoid protected environment right_expression.
Proof.
  intros protected environment left right Hsafe. split;
    intros identifier Hin Hlocal;
    destruct (watc_safe_assign_has_no_table_occurrence
      identifier left right (Hsafe identifier Hin)); assumption.
Qed.

Lemma watps_safe_call_expressions_avoid_globals :
  forall protected environment destination function_expression arguments,
    watc_statement_is_private protected
      (Clight.Scall destination function_expression arguments) ->
    watpc_expression_globals_avoid protected environment function_expression /\
    (forall argument,
      In argument arguments ->
      watpc_expression_globals_avoid protected environment argument).
Proof.
  intros protected environment destination function_expression arguments
    Hsafe. split.
  - intros identifier Hin Hlocal.
    now destruct (watc_safe_call_has_no_table_occurrence identifier destination
      function_expression arguments (Hsafe identifier Hin)).
  - intros argument Hargument identifier Hin Hlocal.
    destruct (watc_safe_call_has_no_table_occurrence identifier destination
      function_expression arguments (Hsafe identifier Hin)) as [_ Hzero].
    exact (watc_expression_list_count_zero_each
      identifier arguments argument Hargument Hzero).
Qed.

Lemma watps_safe_builtin_arguments_avoid_globals :
  forall protected environment destination external argument_types arguments,
    watc_statement_is_private protected
      (Clight.Sbuiltin destination external argument_types arguments) ->
    forall argument,
      In argument arguments ->
      watpc_expression_globals_avoid protected environment argument.
Proof.
  intros protected environment destination external argument_types arguments
    Hsafe argument Hargument identifier Hin Hlocal.
  eapply watc_expression_list_count_zero_each; [exact Hargument |].
  exact (watc_safe_builtin_has_no_table_argument
    identifier destination external argument_types arguments
    (Hsafe identifier Hin)).
Qed.

(** Assignment/copy classification.  [watpc_assign_loc_is_private_effect]
    performs the important split: scalar store, bitfield store, zero-sized
    copy, and positive-sized copy. *)
Theorem watps_reached_assignment_is_classified :
  forall program protected protected_blocks injection
      environment temporaries before
      left_expression right_expression target_block target_offset bitfield
      evaluated_value stored_value after,
    inject_incr
      (watpi_private_initial_injection program protected) injection ->
    ActionTablePrivateMemoryInvariant
      (Clight.globalenv program) protected_blocks before injection ->
    watc_environment_self_injects injection environment ->
    watc_temps_self_inject injection temporaries ->
    watc_statement_is_private protected
      (Clight.Sassign left_expression right_expression) ->
    Clight.eval_lvalue (Clight.globalenv program) environment temporaries before
      left_expression target_block target_offset bitfield ->
    Clight.eval_expr (Clight.globalenv program) environment temporaries before
      right_expression evaluated_value ->
    sem_cast evaluated_value (typeof right_expression) (typeof left_expression)
      before = Some stored_value ->
    Clight.assign_loc (Clight.globalenv program) (typeof left_expression)
      before target_block target_offset bitfield stored_value after ->
    ActionTablePrivatePrimitiveEffect
      (Clight.globalenv program) protected_blocks injection before after.
Proof.
  intros program protected protected_blocks injection
    environment temporaries before left right target_block target_offset
    bitfield evaluated_value stored_value after Hincr Hinvariant Henvironment
    Htemporaries Hsafe Hleft Hright Hcast Hassign.
  destruct (watps_safe_assign_expressions_avoid_globals
    protected environment left right Hsafe) as [Hleft_safe Hright_safe].
  assert (Hleft_inject : Val.inject injection
    (Vptr target_block target_offset) (Vptr target_block target_offset)).
  { eapply watpc_eval_lvalue_private with
      (program := program)
      (protected_identifiers := protected)
      (initial_injection :=
        watpi_private_initial_injection program protected)
      (environment := environment) (temporaries := temporaries)
      (memory := before).
    all: try reflexivity.
    all: try exact Hincr.
    all: try exact (watpl_memory_inject _ _ _ _ Hinvariant).
    all: try now apply watps_control_environment_is_expression_environment.
    all: try now apply watps_control_temps_are_expression_temps.
    all: eauto. }
  assert (Hevaluated_inject :
    Val.inject injection evaluated_value evaluated_value).
  { eapply watpc_eval_expr_private with
      (program := program)
      (protected_identifiers := protected)
      (initial_injection :=
        watpi_private_initial_injection program protected)
      (environment := environment) (temporaries := temporaries)
      (memory := before).
    all: try reflexivity.
    all: try exact Hincr.
    all: try exact (watpl_memory_inject _ _ _ _ Hinvariant).
    all: try now apply watps_control_environment_is_expression_environment.
    all: try now apply watps_control_temps_are_expression_temps.
    all: eauto. }
  assert (Hvalue_inject : Val.inject injection stored_value stored_value).
  { destruct (cast_respects_memory_injection injection evaluated_value
      (typeof right) (typeof left) before stored_value evaluated_value before
      Hcast Hevaluated_inject (watpl_memory_inject _ _ _ _ Hinvariant))
      as [target_value [Htarget_cast Htarget_inject]].
    rewrite Hcast in Htarget_cast. inversion Htarget_cast; subst.
    exact Htarget_inject. }
  eapply watpc_assign_loc_is_private_effect; eauto.
Qed.

(** Ordinary RHS evaluation for [Sset]. *)
Theorem watps_reached_ordinary_set_value_injects :
  forall program protected protected_blocks injection environment temporaries
      memory expression value,
    inject_incr
      (watpi_private_initial_injection program protected) injection ->
    ActionTablePrivateMemoryInvariant
      (Clight.globalenv program) protected_blocks memory injection ->
    watc_environment_self_injects injection environment ->
    watc_temps_self_inject injection temporaries ->
    watpc_expression_globals_avoid protected environment expression ->
    Clight.eval_expr (Clight.globalenv program) environment temporaries memory
      expression value ->
    Val.inject injection value value.
Proof.
  intros program protected protected_blocks injection environment temporaries
    memory expression value Hincr Hinvariant Henvironment Htemporaries Havoid
    Heval.
  eapply watpc_eval_expr_private with
    (program := program)
    (protected_identifiers := protected)
    (initial_injection := watpi_private_initial_injection program protected)
    (environment := environment) (temporaries := temporaries)
    (memory := memory).
  all: try reflexivity.
  all: try exact Hincr.
  all: try exact (watpl_memory_inject _ _ _ _ Hinvariant).
  all: try now apply watps_control_environment_is_expression_environment.
  all: try now apply watps_control_temps_are_expression_temps.
  all: eauto.
Qed.

(** All checker-recognized terminal reads, including the four actual source
    occurrences, read from the exact linked table block and therefore inject
    to themselves under the private injection. *)
Theorem watps_reached_terminal_set_value_injects :
  forall version protected_blocks initial_memory memory injection environment
      temporaries identifier expression value,
    Genv.init_mem
      (selected_clight_source version) =
      Some initial_memory ->
    LinkedSourceActionTableBlocks version protected_blocks ->
    ActionTablePrivateMemoryFrame protected_blocks initial_memory memory ->
    inject_incr
      (watpi_private_initial_injection
        (selected_clight_source version)
        (watwg_linked_source_table_ids version)) injection ->
    In identifier (watwg_linked_source_table_ids version) ->
    environment ! identifier = None ->
    wat_is_terminal_table_read identifier expression = true ->
    Clight.eval_expr
      (Clight.globalenv (selected_clight_source version))
      environment temporaries memory expression value ->
    Val.inject injection value value.
Proof.
  intros version protected_blocks initial_memory memory injection environment
    temporaries identifier expression value Hinitial Hblocks Hframe Hincr
    Hidentifier Hlocal Hterminal Heval.
  destruct (watpr_selected_table_identifier_resolves_exact_variable
    version protected_blocks identifier Hblocks Hidentifier)
    as [block [variable [Hblock [Hsymbol Hvariable]]]].
  eapply watpr_recognized_terminal_table_read_inject; eauto.
  exact (proj1 (watpi_selected_initialization_facts version)).
Qed.

(** This is the complete [Sset] value split. *)
Theorem watps_reached_set_value_injects :
  forall version protected_blocks initial_memory memory injection environment
      temporaries destination expression value,
    Genv.init_mem
      (selected_clight_source version) =
      Some initial_memory ->
    LinkedSourceActionTableBlocks version protected_blocks ->
    ActionTablePrivateMemoryFrame protected_blocks initial_memory memory ->
    ActionTablePrivateMemoryInvariant
      (Clight.globalenv (selected_clight_source version))
      protected_blocks memory injection ->
    inject_incr
      (watpi_private_initial_injection
        (selected_clight_source version)
        (watwg_linked_source_table_ids version)) injection ->
    watc_environment_self_injects injection environment ->
    watc_temps_self_inject injection temporaries ->
    watc_statement_is_private (watwg_linked_source_table_ids version)
      (Clight.Sset destination expression) ->
    Clight.eval_expr
      (Clight.globalenv (selected_clight_source version))
      environment temporaries memory expression value ->
    Val.inject injection value value.
Proof.
  intros version protected_blocks initial_memory memory injection environment
    temporaries destination expression value Hinitial Hblocks Hframe
    Hinvariant Hincr Henvironment Htemporaries Hsafe Heval.
  destruct (watps_safe_set_rhs_is_ordinary_or_terminal
    (watwg_linked_source_table_ids version) environment destination expression
    Hsafe) as [Hordinary | [identifier
      [Hidentifier [Hlocal [Hcount Hterminal]]]]].
  - eapply watps_reached_ordinary_set_value_injects; eauto.
  - eapply watps_reached_terminal_set_value_injects; eauto.
Qed.

(** Direct builtins are absent from both selected retail ASTs, but this
    stronger theorem classifies one anyway.  It proves the argument list is
    self-injected, invokes the exact CompCert external-call carrier, and keeps
    the returned value under the extended injection. *)
Theorem watps_reached_direct_builtin_carries :
  forall program protected protected_blocks injection environment temporaries
      before destination external argument_types arguments argument_values
      trace result after,
    inject_incr
      (watpi_private_initial_injection program protected) injection ->
    ActionTablePrivateMemoryInvariant
      (Clight.globalenv program) protected_blocks before injection ->
    watc_environment_self_injects injection environment ->
    watc_temps_self_inject injection temporaries ->
    watc_statement_is_private protected
      (Clight.Sbuiltin destination external argument_types arguments) ->
    Clight.eval_exprlist (Clight.globalenv program) environment temporaries
      before arguments argument_types argument_values ->
    external_call external (Clight.globalenv program) argument_values before
      trace result after ->
    exists injection',
      ActionTablePrivatePrimitiveEffect
        (Clight.globalenv program) protected_blocks injection before after /\
      ActionTablePrivateMemoryInvariant
        (Clight.globalenv program) protected_blocks after injection' /\
      Val.inject injection' result result /\
      inject_incr injection injection' /\
      ActionTablePrivateMemoryFrame protected_blocks before after.
Proof.
  intros program protected protected_blocks injection environment temporaries
    before destination external argument_types arguments argument_values trace
    result after Hincr Hinvariant Henvironment Htemporaries Hsafe Heval Hcall.
  assert (Harguments : Val.inject_list injection argument_values argument_values).
  { eapply watpc_eval_exprlist_private with
      (program := program)
      (protected_identifiers := protected)
      (initial_injection :=
        watpi_private_initial_injection program protected)
      (environment := environment) (temporaries := temporaries)
      (memory := before).
    all: try reflexivity.
    all: try exact Hincr.
    all: try exact (watpl_memory_inject _ _ _ _ Hinvariant).
    all: try now apply watps_control_environment_is_expression_environment.
    all: try now apply watps_control_temps_are_expression_temps.
    all: eauto using watps_safe_builtin_arguments_avoid_globals. }
  destruct (watpl_private_external_call_carries
    (Clight.globalenv program) protected_blocks before injection external
    argument_values trace result after Hinvariant Harguments Hcall)
    as [injection' [Hafter [Hresult [Hextension Hframe]]]].
  exists injection'. split.
  - exact (watpl_effect_external
      (Clight.globalenv program) protected_blocks injection
      external argument_values trace result before after Harguments Hcall).
  - split; [exact Hafter |].
    split; [exact Hresult |].
    split; [exact Hextension | exact Hframe].
Qed.

(** Ordinary call expression/argument evaluation cannot synthesize a private
    pointer.  Dispatch-table resolution is therefore reduced to ordinary
    [Genv.find_funct] on a self-injected function value. *)
Theorem watps_reached_call_values_inject :
  forall program protected protected_blocks injection environment temporaries
      memory destination function_expression arguments argument_types
      function_value argument_values,
    inject_incr
      (watpi_private_initial_injection program protected) injection ->
    ActionTablePrivateMemoryInvariant
      (Clight.globalenv program) protected_blocks memory injection ->
    watc_environment_self_injects injection environment ->
    watc_temps_self_inject injection temporaries ->
    watc_statement_is_private protected
      (Clight.Scall destination function_expression arguments) ->
    Clight.eval_expr (Clight.globalenv program) environment temporaries memory
      function_expression function_value ->
    Clight.eval_exprlist (Clight.globalenv program) environment temporaries
      memory arguments argument_types argument_values ->
    Val.inject injection function_value function_value /\
    Val.inject_list injection argument_values argument_values.
Proof.
  intros program protected protected_blocks injection environment temporaries
    memory destination function_expression arguments argument_types
    function_value argument_values Hincr Hinvariant Henvironment Htemporaries
    Hsafe Hfunction Harguments.
  destruct (watps_safe_call_expressions_avoid_globals protected environment
    destination function_expression arguments Hsafe)
    as [Hfunction_safe Harguments_safe].
  split.
  - eapply watpc_eval_expr_private with
      (program := program)
      (protected_identifiers := protected)
      (initial_injection :=
        watpi_private_initial_injection program protected)
      (environment := environment) (temporaries := temporaries)
      (memory := memory).
    all: try reflexivity.
    all: try exact Hincr.
    all: try exact (watpl_memory_inject _ _ _ _ Hinvariant).
    all: try now apply watps_control_environment_is_expression_environment.
    all: try now apply watps_control_temps_are_expression_temps.
    all: eauto.
  - eapply watpc_eval_exprlist_private with
      (program := program)
      (protected_identifiers := protected)
      (initial_injection :=
        watpi_private_initial_injection program protected)
      (environment := environment) (temporaries := temporaries)
      (memory := memory).
    all: try reflexivity.
    all: try exact Hincr.
    all: try exact (watpl_memory_inject _ _ _ _ Hinvariant).
    all: try now apply watps_control_environment_is_expression_environment.
    all: try now apply watps_control_temps_are_expression_temps.
    all: eauto.
Qed.

(** Return expressions have the same two-stage semantics as assignments:
    evaluate the expression, then cast it to the function return type. *)
Theorem watps_reached_return_value_injects :
  forall program protected protected_blocks injection environment temporaries
      memory expression return_type evaluated_value returned_value,
    inject_incr
      (watpi_private_initial_injection program protected) injection ->
    ActionTablePrivateMemoryInvariant
      (Clight.globalenv program) protected_blocks memory injection ->
    watc_environment_self_injects injection environment ->
    watc_temps_self_inject injection temporaries ->
    watc_statement_is_private protected
      (Clight.Sreturn (Some expression)) ->
    Clight.eval_expr (Clight.globalenv program) environment temporaries memory
      expression evaluated_value ->
    sem_cast evaluated_value (typeof expression) return_type memory =
      Some returned_value ->
    Val.inject injection returned_value returned_value.
Proof.
  intros program protected protected_blocks injection environment temporaries
    memory expression return_type evaluated_value returned_value Hincr
    Hinvariant Henvironment Htemporaries Hsafe Heval Hcast.
  assert (Havoid :
    watpc_expression_globals_avoid protected environment expression).
  { intros identifier Hidentifier Hlocal.
    exact (watc_safe_return_has_no_table_occurrence identifier expression
      (Hsafe identifier Hidentifier)). }
  assert (Hevaluated : Val.inject injection evaluated_value evaluated_value).
  { eapply watpc_eval_expr_private with
      (program := program) (protected_identifiers := protected)
      (initial_injection :=
        watpi_private_initial_injection program protected)
      (environment := environment) (temporaries := temporaries)
      (memory := memory).
    all: try reflexivity.
    all: try exact Hincr.
    all: try exact (watpl_memory_inject _ _ _ _ Hinvariant).
    all: try now apply watps_control_environment_is_expression_environment.
    all: try now apply watps_control_temps_are_expression_temps.
    all: eauto. }
  destruct (cast_respects_memory_injection injection evaluated_value
    (typeof expression) return_type memory returned_value evaluated_value
    memory Hcast Hevaluated (watpl_memory_inject _ _ _ _ Hinvariant))
    as [target_value [Htarget_cast Htarget_inject]].
  rewrite Hcast in Htarget_cast. inversion Htarget_cast; subst.
  exact Htarget_inject.
Qed.

(** Internal entry allocates locals, extends the injection, and establishes
    self-injection for every local block and temporary. *)
Theorem watps_reached_internal_entry_carries :
  forall (ge : Clight.genv) protected_blocks injection function arguments
      before entry_environment entry_temporaries after,
    ActionTablePrivateMemoryInvariant ge protected_blocks before injection ->
    Val.inject_list injection arguments arguments ->
    Clight.function_entry2 ge function arguments before
      entry_environment entry_temporaries after ->
    exists injection',
      ActionTablePrivateMemoryInvariant ge protected_blocks after injection' /\
      inject_incr injection injection' /\
      ActionTablePrivateMemoryFrame protected_blocks before after /\
      watc_environment_self_injects injection' entry_environment /\
      watc_temps_self_inject injection' entry_temporaries.
Proof.
  intros ge protected_blocks injection function arguments before
    entry_environment entry_temporaries after Hinvariant Harguments Hentry.
  destruct (watpa_private_function_entry2_carries ge protected_blocks function
    arguments before entry_environment entry_temporaries after injection
    Hentry Hinvariant Harguments) as
    [injection' [Hafter [Hextension [Hframe [Henv Htemps]]]]].
  exists injection'. split; [exact Hafter |].
  split; [exact Hextension |].
  split; [exact Hframe |].
  split.
  - now apply watps_entry_environment_is_control_environment.
  - now apply watps_entry_temps_are_control_temps.
Qed.

(** The sound reached-state replacement for the obsolete memory-only schema.
    It returns the effect relative to the old injection, the carried memory
    invariant and frame, and control/value provenance for the exact successor
    state. *)
Definition ActionTablePrivateCumulativeClightStepCoverage
    (program : Clight.program) (protected : list ident)
    (protected_blocks : list block)
    (function_is_controlled : Clight.function -> Prop) : Prop :=
  forall initial_memory injection before trace after,
    Genv.init_mem program = Some initial_memory ->
    ActionTablePrivateMemoryFrame protected_blocks initial_memory
      (watpl_clight_state_memory before) ->
    inject_incr (watpi_private_initial_injection program protected) injection ->
    ActionTablePrivateMemoryInvariant (Clight.globalenv program)
      protected_blocks (watpl_clight_state_memory before) injection ->
    watc_reached_state_is_private (Clight.globalenv program) protected
      function_is_controlled injection before ->
    Clight.step2 (Clight.globalenv program) before trace after ->
    exists injection',
      ActionTablePrivatePrimitiveEffect (Clight.globalenv program)
        protected_blocks injection (watpl_clight_state_memory before)
        (watpl_clight_state_memory after) /\
      ActionTablePrivateMemoryInvariant (Clight.globalenv program)
        protected_blocks (watpl_clight_state_memory after) injection' /\
      inject_incr injection injection' /\
      ActionTablePrivateMemoryFrame protected_blocks
        (watpl_clight_state_memory before) (watpl_clight_state_memory after) /\
      ActionTablePrivateMemoryFrame protected_blocks initial_memory
        (watpl_clight_state_memory after) /\
      watc_reached_state_is_private (Clight.globalenv program) protected
        function_is_controlled injection' after.

(** Selected-program form of the sound contract.  Notice that the exact
    filtered initial injection and cumulative frame are inputs.  Omitting
    either is unsound for a terminal read because the current injection maps
    each protected table block to [None], so [Mem.inject] alone deliberately
    imposes no relation on that block's current bytes. *)
Definition ActionTablePrivateSelectedReachedStepClassification : Prop :=
  forall version protected_blocks initial_memory current_injection
      function_is_controlled before trace after,
    LinkedSourceActionTableBlocks version protected_blocks ->
    watc_function_control_certificate
      (watwg_linked_source_table_ids version) function_is_controlled ->
    (forall body,
      watc_internal_function_is_reached
        (Clight.globalenv (selected_clight_source version)) body ->
      function_is_controlled body) ->
    Genv.init_mem
      (selected_clight_source version) =
      Some initial_memory ->
    inject_incr
      (watpi_private_initial_injection
        (selected_clight_source version)
        (watwg_linked_source_table_ids version))
      current_injection ->
    ActionTablePrivateMemoryFrame protected_blocks initial_memory
      (watpl_clight_state_memory before) ->
    ActionTablePrivateMemoryInvariant
      (Clight.globalenv (selected_clight_source version)) protected_blocks
      (watpl_clight_state_memory before) current_injection ->
    watc_reached_state_is_private
      (Clight.globalenv (selected_clight_source version))
      (watwg_linked_source_table_ids version)
      function_is_controlled current_injection before ->
    Clight.step2 (Clight.globalenv (selected_clight_source version))
      before trace after ->
    exists next_injection,
      ActionTablePrivatePrimitiveEffect
        (Clight.globalenv (selected_clight_source version)) protected_blocks
        current_injection (watpl_clight_state_memory before)
        (watpl_clight_state_memory after) /\
      ActionTablePrivateMemoryInvariant
        (Clight.globalenv (selected_clight_source version)) protected_blocks
        (watpl_clight_state_memory after) next_injection /\
      inject_incr current_injection next_injection /\
      ActionTablePrivateMemoryFrame protected_blocks
        (watpl_clight_state_memory before)
        (watpl_clight_state_memory after) /\
      ActionTablePrivateMemoryFrame protected_blocks initial_memory
        (watpl_clight_state_memory after) /\
      watc_reached_state_is_private
        (Clight.globalenv (selected_clight_source version))
        (watwg_linked_source_table_ids version)
        function_is_controlled next_injection after.

Lemma watps_carry_effect_and_successor_provenance :
  forall (ge : Clight.genv) (protected : list ident) protected_blocks
      (function_is_controlled : Clight.function -> Prop)
      initial_memory current_injection (before : Clight.state)
      (trace : Events.trace) (after : Clight.state),
    ActionTablePrivateMemoryFrame protected_blocks initial_memory
      (watpl_clight_state_memory before) ->
    ActionTablePrivateMemoryInvariant ge protected_blocks
      (watpl_clight_state_memory before) current_injection ->
    Clight.step2 ge before trace after ->
    ActionTablePrivatePrimitiveEffect ge protected_blocks current_injection
      (watpl_clight_state_memory before) (watpl_clight_state_memory after) ->
    (forall next_injection,
      inject_incr current_injection next_injection ->
      watc_reached_state_is_private ge protected function_is_controlled
        next_injection after) ->
    exists next_injection,
      ActionTablePrivatePrimitiveEffect ge protected_blocks current_injection
        (watpl_clight_state_memory before) (watpl_clight_state_memory after) /\
      ActionTablePrivateMemoryInvariant ge protected_blocks
        (watpl_clight_state_memory after) next_injection /\
      inject_incr current_injection next_injection /\
      ActionTablePrivateMemoryFrame protected_blocks
        (watpl_clight_state_memory before) (watpl_clight_state_memory after) /\
      ActionTablePrivateMemoryFrame protected_blocks initial_memory
        (watpl_clight_state_memory after) /\

      watc_reached_state_is_private ge protected function_is_controlled
        next_injection after.
Proof.
  intros ge protected protected_blocks function_is_controlled
    initial_memory current_injection before trace after Hprefix Hinvariant
    Hstep Heffect Hsuccessor.
  destruct (watpl_private_primitive_effect_carries ge protected_blocks
    current_injection (watpl_clight_state_memory before)
    (watpl_clight_state_memory after) Hinvariant Heffect)
    as [next_injection [Hnext [Hincr Hframe]]].
  exists next_injection. split; [exact Heffect |].
  split; [exact Hnext |].
  split; [exact Hincr |].
  split; [exact Hframe |].
  split.
  - exact (watpl_frame_trans protected_blocks initial_memory
      (watpl_clight_state_memory before) (watpl_clight_state_memory after)
      Hprefix Hframe).
  - exact (Hsuccessor next_injection Hincr).
Qed.

Lemma watps_free_current_environment_is_effect :
  forall ge protected_blocks injection environment before after,
    watc_environment_self_injects injection environment ->
    Mem.free_list before (Clight.blocks_of_env ge environment) = Some after ->
    ActionTablePrivatePrimitiveEffect ge protected_blocks injection
      before after.
Proof.
  intros ge protected_blocks injection environment before after Henvironment
    Hfree.
  eapply watpl_effect_free_list; [| exact Hfree].
  intros freed_block low high Hin.
  exact (watc_blocks_of_env_are_self_mapped ge injection environment
    freed_block low high Henvironment Hin).
Qed.

(** Complete selected-program constructor dispatcher.  This proof is kept
    separate from the small semantic lemmas above so each inversion branch
    corresponds one-for-one with a constructor of [Clight.step2]. *)
Theorem action_table_private_selected_one_step_theorem_holds :
  ActionTablePrivateSelectedReachedStepClassification.
Proof.
  unfold ActionTablePrivateSelectedReachedStepClassification.
  intros version protected_blocks initial_memory current_injection
    function_is_controlled before trace after Hblocks Hcertificate
    Hall_internal_controlled Hinitial Hexact_incr Hprefix Hcurrent Hreached
    Hstep.
  destruct Hreached as
    [body statement continuation environment temporaries memory
      Hbody_controlled Hbody_reached Hstatement_private
      Hcontinuation_private Henvironment_private Htemporaries_private
    | definition arguments continuation memory Hdefinition_controlled
      Hdefinition_reached Harguments_private Hcontinuation_private
    | result continuation memory Hresult_private Hcontinuation_private].
  - inversion Hstep; subst.
    + (* step_assign *)
      match goal with
      | Hleft : Clight.eval_lvalue _ _ _ _ ?left ?target_block
          ?target_offset ?bitfield,
        Hright : Clight.eval_expr _ _ _ _ ?right ?evaluated,
        Hcast : sem_cast ?evaluated (typeof ?right) (typeof ?left) _ =
          Some ?stored,
        Hassign : Clight.assign_loc _ (typeof ?left) _ ?target_block
          ?target_offset ?bitfield ?stored ?next_memory |- _ =>
          pose proof (watps_reached_assignment_is_classified
            (selected_clight_source version)
            (watwg_linked_source_table_ids version) protected_blocks
            current_injection environment temporaries memory left right
            target_block target_offset bitfield evaluated stored next_memory
            Hexact_incr Hcurrent Henvironment_private Htemporaries_private
            Hstatement_private Hleft Hright Hcast Hassign) as Heffect
      end.
      eapply watps_carry_effect_and_successor_provenance; eauto.
      intros next_injection Hincr.
      econstructor; eauto using watc_continuation_is_private_incr,
        watc_environment_self_injects_incr, watc_temps_self_inject_incr,
        watc_skip_is_private.
    + (* step_set *)
      match goal with
      | Heval : Clight.eval_expr _ _ _ _ ?expression ?value |- _ =>
          pose proof (watps_reached_set_value_injects version protected_blocks
            initial_memory memory current_injection environment temporaries
            _ expression value Hinitial Hblocks Hprefix Hcurrent Hexact_incr
            Henvironment_private Htemporaries_private Hstatement_private
            Heval) as Hvalue
      end.
      eapply watps_carry_effect_and_successor_provenance; eauto.
      * constructor.
      * intros next_injection Hincr.
        eapply watc_reached_internal_state_after_set; eauto using
          val_inject_incr, watc_continuation_is_private_incr,
          watc_environment_self_injects_incr, watc_temps_self_inject_incr.
    + (* step_call *)
      match goal with
      | Hfunction : Clight.eval_expr _ _ _ _ ?function_expression
          ?function_value,
        Harguments : Clight.eval_exprlist _ _ _ _ ?argument_expressions
          ?argument_types ?argument_values |- _ =>
          destruct (watps_reached_call_values_inject
            (selected_clight_source version)
            (watwg_linked_source_table_ids version) protected_blocks
            current_injection environment temporaries memory _
            function_expression argument_expressions argument_types
            function_value argument_values Hexact_incr Hcurrent
            Henvironment_private Htemporaries_private Hstatement_private
             Hfunction Harguments) as [Hfunction_private Hcall_arguments]
      end.
      assert (Hcalled_reached :
        watc_fundef_is_reached
          (Clight.globalenv (selected_clight_source version)) fd).
      { unfold watc_fundef_is_reached.
        eapply clight_step_target_callstate_resolved; eauto. }
      assert (Hcalled_controlled :
        watc_fundef_is_controlled function_is_controlled fd).
      { destruct fd; cbn in *; auto. }
      eapply watps_carry_effect_and_successor_provenance; eauto.
      * constructor.
      * intros next_injection Hincr.
        apply watc_reached_call_state.
        -- exact Hcalled_controlled.
        -- exact Hcalled_reached.
        -- exact (watc_values_self_inject_incr current_injection
             next_injection vargs Hincr Hcall_arguments).
        -- constructor; eauto using watc_continuation_is_private_incr,
            watc_environment_self_injects_incr,
            watc_temps_self_inject_incr.
    + (* step_builtin *)
      match goal with
      | Heval : Clight.eval_exprlist _ _ _ _ ?argument_expressions
          ?argument_types ?argument_values,
        Hcall : external_call ?external _ ?argument_values ?before_memory
          ?call_trace ?call_result ?after_memory |- _ =>
          destruct (watps_reached_direct_builtin_carries
            (selected_clight_source version)
            (watwg_linked_source_table_ids version) protected_blocks
            current_injection environment temporaries before_memory _ external
            argument_types argument_expressions argument_values call_trace
            call_result after_memory Hexact_incr Hcurrent
            Henvironment_private Htemporaries_private Hstatement_private
            Heval Hcall) as
            [next_injection
              [Heffect [Hnext [Hresult [Hincr Hframe]]]]]
      end.
      exists next_injection. split; [exact Heffect |].
      split; [exact Hnext |].
      split; [exact Hincr |].
      split; [exact Hframe |].
      split.
      * eapply watpl_frame_trans; eauto.
      * eapply watc_reached_internal_state_after_opttemp; eauto using
          watc_continuation_is_private_incr,
          watc_environment_self_injects_incr, watc_temps_self_inject_incr.
    + (* step_seq *)
      destruct (watc_sequence_private_inv _ _ _ Hstatement_private)
        as [Hfirst Hsecond].
      eapply watps_carry_effect_and_successor_provenance; eauto.
      * constructor.
      * intros next_injection Hincr. econstructor; eauto using
          watc_continuation_is_private_incr,
          watc_environment_self_injects_incr, watc_temps_self_inject_incr.
        constructor; eauto using watc_continuation_is_private_incr.
    + (* step_skip_seq *)
      destruct (watc_seq_continuation_private_inv _ _ _ _ _ _
        Hcontinuation_private) as [Hnext_statement Hnext_continuation].
      eapply watps_carry_effect_and_successor_provenance; eauto.
      * constructor.
      * intros next_injection Hincr. econstructor; eauto using
          watc_continuation_is_private_incr,
          watc_environment_self_injects_incr, watc_temps_self_inject_incr.
    + (* step_continue_seq *)
      destruct (watc_seq_continuation_private_inv _ _ _ _ _ _
        Hcontinuation_private) as [_ Hnext_continuation].
      eapply watps_carry_effect_and_successor_provenance; eauto.
      * constructor.
      * intros next_injection Hincr. econstructor; eauto using
          watc_continue_is_private, watc_continuation_is_private_incr,
          watc_environment_self_injects_incr, watc_temps_self_inject_incr.
    + (* step_break_seq *)
      destruct (watc_seq_continuation_private_inv _ _ _ _ _ _
        Hcontinuation_private) as [_ Hnext_continuation].
      eapply watps_carry_effect_and_successor_provenance; eauto.
      * constructor.
      * intros next_injection Hincr. econstructor; eauto using
          watc_break_is_private, watc_continuation_is_private_incr,
          watc_environment_self_injects_incr, watc_temps_self_inject_incr.
    + (* step_ifthenelse *)
      destruct (watc_if_private_inv _ _ _ _ Hstatement_private)
        as [_ [Hyes Hno]].
      eapply watps_carry_effect_and_successor_provenance; eauto.
      * constructor.
      * intros next_injection Hincr. econstructor; eauto using
          watc_continuation_is_private_incr,
          watc_environment_self_injects_incr, watc_temps_self_inject_incr.
        match goal with
        | |- watc_statement_is_private _
            (if ?selected_branch then _ else _) =>
            destruct selected_branch; assumption
        end.
    + (* step_loop *)
      destruct (watc_loop_private_inv _ _ _ Hstatement_private)
        as [Hloop_body Hincrement].
      eapply watps_carry_effect_and_successor_provenance; eauto.
      * constructor.
      * intros next_injection Hincr. econstructor; eauto using
          watc_continuation_is_private_incr,
          watc_environment_self_injects_incr, watc_temps_self_inject_incr.
        constructor; eauto using watc_continuation_is_private_incr.
    + (* step_skip_or_continue_loop1 *)
      destruct (watc_continue_from_loop1_is_private _ _ _ _ _ _ _
        Hcontinuation_private) as [Hincrement Hloop_continuation].
      eapply watps_carry_effect_and_successor_provenance; eauto.
      * constructor.
      * intros next_injection Hincr. econstructor; eauto using
          watc_continuation_is_private_incr,
          watc_environment_self_injects_incr, watc_temps_self_inject_incr.
    + (* step_break_loop1 *)
      destruct (watc_loop1_continuation_private_inv _ _ _ _ _ _ _
        Hcontinuation_private) as [_ [_ Hnext_continuation]].
      eapply watps_carry_effect_and_successor_provenance; eauto.
      * constructor.
      * intros next_injection Hincr. econstructor; eauto using
          watc_skip_is_private, watc_continuation_is_private_incr,
          watc_environment_self_injects_incr, watc_temps_self_inject_incr.
    + (* step_skip_loop2 *)
      destruct (watc_restart_after_loop2_is_private _ _ _ _ _ _ _
        Hcontinuation_private) as [Hloop Hnext_continuation].
      eapply watps_carry_effect_and_successor_provenance; eauto.
      * constructor.
      * intros next_injection Hincr. econstructor; eauto using
          watc_continuation_is_private_incr,
          watc_environment_self_injects_incr, watc_temps_self_inject_incr.
    + (* step_break_loop2 *)
      destruct (watc_loop2_continuation_private_inv _ _ _ _ _ _ _
        Hcontinuation_private) as [_ [_ Hnext_continuation]].
      eapply watps_carry_effect_and_successor_provenance; eauto.
      * constructor.
      * intros next_injection Hincr. econstructor; eauto using
          watc_skip_is_private, watc_continuation_is_private_incr,
          watc_environment_self_injects_incr, watc_temps_self_inject_incr.
    + (* step_return_0 *)
      match goal with
      | Hfree : Mem.free_list memory
          (Clight.blocks_of_env
            (Clight.globalenv (selected_clight_source version)) environment) =
          Some ?next_memory |- _ =>
          pose proof (watps_free_current_environment_is_effect
            (Clight.globalenv (selected_clight_source version))
            protected_blocks current_injection environment memory next_memory
            Henvironment_private Hfree) as Heffect
      end.
      eapply watps_carry_effect_and_successor_provenance; eauto.
      intros next_injection Hincr. apply watc_reached_return_state.
      * constructor.
      * eapply watc_continuation_is_private_incr; [exact Hincr |].
        now apply watc_call_cont_is_private.
    + (* step_return_1 *)
      match goal with
      | Heval : Clight.eval_expr _ _ _ _ ?expression ?evaluated,
        Hcast : sem_cast ?evaluated (typeof ?expression) _ memory =
          Some ?returned,
        Hfree : Mem.free_list memory
          (Clight.blocks_of_env
            (Clight.globalenv (selected_clight_source version)) environment) =
          Some ?next_memory |- _ =>
          pose proof (watps_reached_return_value_injects
            (selected_clight_source version)
            (watwg_linked_source_table_ids version) protected_blocks
            current_injection environment temporaries memory expression
            (fn_return body) evaluated returned Hexact_incr Hcurrent
            Henvironment_private Htemporaries_private Hstatement_private
            Heval Hcast) as Hreturned;
          pose proof (watps_free_current_environment_is_effect
            (Clight.globalenv (selected_clight_source version))
            protected_blocks current_injection environment memory next_memory
            Henvironment_private Hfree) as Heffect
      end.
      eapply watps_carry_effect_and_successor_provenance; eauto.
      intros next_injection Hincr. apply watc_reached_return_state.
      * exact (val_inject_incr current_injection next_injection _ _
          Hincr Hreturned).
      * eapply watc_continuation_is_private_incr; [exact Hincr |].
        now apply watc_call_cont_is_private.
    + (* step_skip_call *)
      match goal with
      | Hfree : Mem.free_list memory
          (Clight.blocks_of_env
            (Clight.globalenv (selected_clight_source version)) environment) =
          Some ?next_memory |- _ =>
          pose proof (watps_free_current_environment_is_effect
            (Clight.globalenv (selected_clight_source version))
            protected_blocks current_injection environment memory next_memory
            Henvironment_private Hfree) as Heffect
      end.
      eapply watps_carry_effect_and_successor_provenance; eauto.
      intros next_injection Hincr. apply watc_reached_return_state.
      * constructor.
      * eapply watc_continuation_is_private_incr; [exact Hincr |].
        exact Hcontinuation_private.
    + (* step_switch *)
      destruct (watc_switch_private_inv _ _ _ Hstatement_private)
        as [_ Hcases].
      pose proof (watc_selected_switch_statement_is_private
        (watwg_linked_source_table_ids version) n sl Hcases) as Hselected.
      eapply watps_carry_effect_and_successor_provenance; eauto.
      * constructor.
      * intros next_injection Hincr. econstructor; eauto using
          watc_continuation_is_private_incr,
          watc_environment_self_injects_incr, watc_temps_self_inject_incr.
        constructor.
        eapply watc_continuation_is_private_incr;
          [exact Hincr | exact Hcontinuation_private].
    + (* step_skip_break_switch *)
      pose proof (watc_switch_continuation_private_inv _ _ _ _ _
        Hcontinuation_private) as Hnext_continuation.
      eapply watps_carry_effect_and_successor_provenance; eauto.
      * constructor.
      * intros next_injection Hincr. econstructor; eauto using
          watc_skip_is_private, watc_continuation_is_private_incr,
          watc_environment_self_injects_incr, watc_temps_self_inject_incr.
    + (* step_continue_switch *)
      pose proof (watc_switch_continuation_private_inv _ _ _ _ _
        Hcontinuation_private) as Hnext_continuation.
      eapply watps_carry_effect_and_successor_provenance; eauto.
      * constructor.
      * intros next_injection Hincr. econstructor; eauto using
          watc_continue_is_private, watc_continuation_is_private_incr,
          watc_environment_self_injects_incr, watc_temps_self_inject_incr.
    + (* step_label *)
      pose proof (watc_label_private_inv _ _ _ Hstatement_private) as Hbody.
      eapply watps_carry_effect_and_successor_provenance; eauto.
      * constructor.
      * intros next_injection Hincr. econstructor; eauto using
          watc_continuation_is_private_incr,
          watc_environment_self_injects_incr, watc_temps_self_inject_incr.
    + (* step_goto *)
      match goal with
      | Hfind : Clight.find_label _ (fn_body body)
          (Clight.call_cont continuation) = Some (?next_statement, ?next_cont)
          |- _ =>
          destruct (watc_goto_from_call_cont_is_private
            (watwg_linked_source_table_ids version) function_is_controlled
            Hcertificate
            (Clight.globalenv (selected_clight_source version))
            current_injection body _ continuation next_statement next_cont
            Hbody_controlled Hcontinuation_private Hfind)
            as [Hnext_statement Hnext_continuation]
      end.
      eapply watps_carry_effect_and_successor_provenance; eauto.
      * constructor.
      * intros next_injection Hincr. econstructor; eauto using
          watc_continuation_is_private_incr,
          watc_environment_self_injects_incr, watc_temps_self_inject_incr.
  - inversion Hstep; subst.
    + (* step_internal_function *)
      destruct (watps_reached_internal_entry_carries
        (Clight.globalenv (selected_clight_source version))
        protected_blocks current_injection f arguments memory e le m1 Hcurrent
        Harguments_private H5) as
        [next_injection
          [Hnext [Hincr [Hframe [Hentry_env Hentry_temps]]]]].
      pose proof (watpl_internal_function_entry_step_is_classified
        (Clight.globalenv (selected_clight_source version)) protected_blocks
        current_injection f arguments continuation memory E0
        (Clight.State f (fn_body f) continuation e le m1) Hstep) as Heffect.
      assert (Hcomposed : ActionTablePrivateMemoryFrame protected_blocks
        initial_memory m1).
      { exact (watpl_frame_trans protected_blocks initial_memory memory m1
          Hprefix Hframe). }
      exists next_injection. split; [exact Heffect |].
      split; [exact Hnext |].
      split; [exact Hincr |].
      split; [exact Hframe |].
      split; [exact Hcomposed |].
      apply watc_reached_internal_state.
      * exact Hdefinition_controlled.
      * exact Hdefinition_reached.
      * exact (watc_controlled_body_is_private _ _ Hcertificate f
          Hdefinition_controlled).
      * exact (watc_continuation_is_private_incr _ _ _ _ _ _ Hincr
          Hcontinuation_private).
      * exact Hentry_env.
      * exact Hentry_temps.
    + (* step_external_function *)
      destruct (watpl_private_external_call_carries
        (Clight.globalenv (selected_clight_source version))
        protected_blocks memory current_injection ef arguments trace vres m'
        Hcurrent Harguments_private H5) as
        [next_injection [Hnext [Hresult [Hincr Hframe]]]].
      assert (Heffect : ActionTablePrivatePrimitiveEffect
        (Clight.globalenv (selected_clight_source version)) protected_blocks
        current_injection memory m').
      { exact (watpl_effect_external
          (Clight.globalenv (selected_clight_source version)) protected_blocks
          current_injection ef arguments trace vres memory m'
          Harguments_private H5). }
      assert (Hcomposed : ActionTablePrivateMemoryFrame protected_blocks
        initial_memory m').
      { exact (watpl_frame_trans protected_blocks initial_memory memory m'
          Hprefix Hframe). }
      exists next_injection. split; [exact Heffect |].
      split; [exact Hnext |].
      split; [exact Hincr |].
      split; [exact Hframe |].
      split; [exact Hcomposed |].
      apply watc_reached_return_state; [exact Hresult |].
      exact (watc_continuation_is_private_incr _ _ _ _ _ _ Hincr
        Hcontinuation_private).
  - inversion Hstep; subst.
    (* step_returnstate *)
    eapply watps_carry_effect_and_successor_provenance; eauto.
    + constructor.
    + intros next_injection Hincr.
      inversion Hcontinuation_private; subst.
      eapply watc_reached_internal_state_after_opttemp; eauto using
        val_inject_incr, watc_continuation_is_private_incr,
        watc_environment_self_injects_incr, watc_temps_self_inject_incr.
Qed.

Print Assumptions watps_reached_assignment_is_classified.
Print Assumptions watps_reached_set_value_injects.
Print Assumptions watps_reached_direct_builtin_carries.
Print Assumptions action_table_private_selected_one_step_theorem_holds.
