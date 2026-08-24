(** Reached-state control and value provenance for the private action tables.

    A memory invariant alone cannot classify an arbitrary [Clight.step2]: an
    arbitrary state may already contain a private-table pointer in a local or
    temporary, or may contain a forged statement that never came from the
    selected program.  This file records the missing live-execution facts.

    The definitions deliberately do not mention the semantic proof for the
    four legitimate table reads.  They are the reusable control/value half of
    the eventual one-step theorem: local blocks map to themselves, live values
    inject to themselves, every suspended statement passes the source
    checker, and every current or saved function has selected-program
    provenance. *)

From Coq Require Import Bool List Lia ZArith.
From compcert Require Import
  AST Clight Coqlib Ctypes Globalenvs Maps Memory Values.
From LessThanOneAPress.Proofs Require Import
  ClightEndToEndRefinement WritableActionTableAliasExternalClosure.

Import ListNotations.
Local Open Scope Z_scope.

(** * Local environments and live values *)

Definition watc_environment_self_injects
    (injection : meminj) (environment : Clight.env) : Prop :=
  forall identifier local_block local_type,
    environment ! identifier = Some (local_block, local_type) ->
    injection local_block = Some (local_block, 0).

Definition watc_temps_self_inject
    (injection : meminj) (temporaries : Clight.temp_env) : Prop :=
  forall identifier value,
    temporaries ! identifier = Some value ->
    Val.inject injection value value.

Definition watc_values_self_inject
    (injection : meminj) (values : list val) : Prop :=
  Val.inject_list injection values values.

Lemma watc_environment_self_injects_incr :
  forall injection injection' environment,
    inject_incr injection injection' ->
    watc_environment_self_injects injection environment ->
    watc_environment_self_injects injection' environment.
Proof.
  intros injection injection' environment Hincr Henvironment
    identifier local_block local_type Hget.
  apply Hincr. exact (Henvironment identifier local_block local_type Hget).
Qed.

Lemma watc_temps_self_inject_incr :
  forall injection injection' temporaries,
    inject_incr injection injection' ->
    watc_temps_self_inject injection temporaries ->
    watc_temps_self_inject injection' temporaries.
Proof.
  intros injection injection' temporaries Hincr Htemporaries
    identifier value Hget.
  eapply val_inject_incr; [exact Hincr |].
  exact (Htemporaries identifier value Hget).
Qed.

Lemma watc_values_self_inject_incr :
  forall injection injection' values,
    inject_incr injection injection' ->
    watc_values_self_inject injection values ->
    watc_values_self_inject injection' values.
Proof.
  intros injection injection' values Hincr Hvalues.
  eapply val_inject_list_incr; eauto.
Qed.

Lemma watc_environment_set_self_injects :
  forall injection environment identifier local_block local_type,
    injection local_block = Some (local_block, 0) ->
    watc_environment_self_injects injection environment ->
    watc_environment_self_injects injection
      (PTree.set identifier (local_block, local_type) environment).
Proof.
  intros injection environment identifier local_block local_type Hblock
    Henvironment queried found_block found_type Hget.
  rewrite PTree.gsspec in Hget.
  destruct (peq queried identifier) as [Heq | Hneq].
  - inversion Hget; subst. exact Hblock.
  - exact (Henvironment queried found_block found_type Hget).
Qed.

Lemma watc_temps_set_self_injects :
  forall injection temporaries identifier value,
    Val.inject injection value value ->
    watc_temps_self_inject injection temporaries ->
    watc_temps_self_inject injection
      (PTree.set identifier value temporaries).
Proof.
  intros injection temporaries identifier value Hvalue Htemporaries
    queried found Hget.
  rewrite PTree.gsspec in Hget.
  destruct (peq queried identifier) as [Heq | Hneq].
  - inversion Hget; subst. exact Hvalue.
  - exact (Htemporaries queried found Hget).
Qed.

Lemma watc_set_opttemp_self_injects :
  forall injection temporaries destination value,
    Val.inject injection value value ->
    watc_temps_self_inject injection temporaries ->
    watc_temps_self_inject injection
      (Clight.set_opttemp destination value temporaries).
Proof.
  intros injection temporaries [identifier |] value Hvalue Htemporaries;
    cbn [Clight.set_opttemp].
  - now apply watc_temps_set_self_injects.
  - exact Htemporaries.
Qed.

Lemma watc_empty_environment_self_injects :
  forall injection,
    watc_environment_self_injects injection Clight.empty_env.
Proof.
  intros injection identifier local_block local_type Hget.
  rewrite PTree.gempty in Hget. discriminate.
Qed.

Lemma watc_create_undef_temps_self_injects :
  forall injection declarations,
    watc_temps_self_inject injection
      (Clight.create_undef_temps declarations).
Proof.
  intros injection declarations.
  induction declarations as [| [identifier value_type] rest IH]; cbn.
  - intros queried value Hget. rewrite PTree.gempty in Hget. discriminate.
  - apply watc_temps_set_self_injects; [constructor | exact IH].
Qed.

Lemma watc_bind_parameter_temps_self_injects :
  forall injection parameters arguments before after,
    watc_values_self_inject injection arguments ->
    watc_temps_self_inject injection before ->
    Clight.bind_parameter_temps parameters arguments before = Some after ->
    watc_temps_self_inject injection after.
Proof.
  intros injection parameters.
  induction parameters as [| [identifier value_type] rest IH];
    intros [| argument arguments] before after Harguments Hbefore Hbind;
    cbn in Hbind; try discriminate.
  - inversion Hbind; subst. exact Hbefore.
  - inversion Harguments; subst.
    eapply IH with (before := PTree.set identifier argument before).
    + exact H4.
    + eapply watc_temps_set_self_injects; eauto.
    + exact Hbind.
Qed.

(** Every range freed on return comes from an environment binding.  Thus the
    environment invariant supplies exactly the self-map premise expected by
    [watpl_private_free_list_carries]. *)
Lemma watc_blocks_of_env_are_self_mapped :
  forall ge injection environment freed_block low high,
    watc_environment_self_injects injection environment ->
    In (freed_block, low, high) (Clight.blocks_of_env ge environment) ->
    injection freed_block = Some (freed_block, 0).
Proof.
  intros ge injection environment freed_block low high Henvironment Hin.
  unfold Clight.blocks_of_env in Hin.
  apply list_in_map_inv in Hin.
  destruct Hin as [[identifier [found_block found_type]] [Heq Helement]].
  unfold Clight.block_of_binding in Heq.
  assert (Hblock : found_block = freed_block) by congruence.
  subst found_block.
  apply PTree.elements_complete in Helement.
  exact (Henvironment identifier freed_block found_type Helement).
Qed.

(** * Statement-checker decomposition *)

Definition watc_statement_is_private
    (protected_identifiers : list ident) (statement : Clight.statement) : Prop :=
  forall identifier,
    In identifier protected_identifiers ->
    wat_statement_access_safe_s identifier statement = true.

Definition watc_labeled_statements_are_private
    (protected_identifiers : list ident)
    (cases : Clight.labeled_statements) : Prop :=
  forall identifier,
    In identifier protected_identifiers ->
    wat_statement_access_safe_ls identifier cases = true.

Lemma watc_skip_is_private :
  forall protected_identifiers,
    watc_statement_is_private protected_identifiers Clight.Sskip.
Proof. intros protected identifier Hin. reflexivity. Qed.

Lemma watc_break_is_private :
  forall protected_identifiers,
    watc_statement_is_private protected_identifiers Clight.Sbreak.
Proof. intros protected identifier Hin. reflexivity. Qed.

Lemma watc_continue_is_private :
  forall protected_identifiers,
    watc_statement_is_private protected_identifiers Clight.Scontinue.
Proof. intros protected identifier Hin. reflexivity. Qed.

Lemma watc_sequence_private_inv :
  forall protected_identifiers first second,
    watc_statement_is_private protected_identifiers
      (Clight.Ssequence first second) ->
    watc_statement_is_private protected_identifiers first /\
    watc_statement_is_private protected_identifiers second.
Proof.
  intros protected first second Hsafe. split; intros identifier Hin;
    specialize (Hsafe identifier Hin); cbn in Hsafe;
    apply andb_true_iff in Hsafe; tauto.
Qed.

Lemma watc_loop_private_inv :
  forall protected_identifiers body increment,
    watc_statement_is_private protected_identifiers
      (Clight.Sloop body increment) ->
    watc_statement_is_private protected_identifiers body /\
    watc_statement_is_private protected_identifiers increment.
Proof.
  intros protected body increment Hsafe. split; intros identifier Hin;
    specialize (Hsafe identifier Hin); cbn in Hsafe;
    apply andb_true_iff in Hsafe; tauto.
Qed.

Lemma watc_if_private_inv :
  forall protected_identifiers condition yes_branch no_branch,
    watc_statement_is_private protected_identifiers
      (Clight.Sifthenelse condition yes_branch no_branch) ->
    (forall identifier,
      In identifier protected_identifiers ->
      wat_evar_count identifier condition = 0%nat) /\
    watc_statement_is_private protected_identifiers yes_branch /\
    watc_statement_is_private protected_identifiers no_branch.
Proof.
  intros protected condition yes_branch no_branch Hsafe.
  repeat split; intros identifier Hin; specialize (Hsafe identifier Hin);
    cbn in Hsafe; repeat rewrite andb_true_iff in Hsafe;
    destruct Hsafe as [[Hcondition Hyes] Hno].
  - now apply Nat.eqb_eq in Hcondition.
  - exact Hyes.
  - exact Hno.
Qed.

Lemma watc_switch_private_inv :
  forall protected_identifiers selector cases,
    watc_statement_is_private protected_identifiers
      (Clight.Sswitch selector cases) ->
    (forall identifier,
      In identifier protected_identifiers ->
      wat_evar_count identifier selector = 0%nat) /\
    watc_labeled_statements_are_private protected_identifiers cases.
Proof.
  intros protected selector cases Hsafe. split; intros identifier Hin;
    specialize (Hsafe identifier Hin); cbn in Hsafe;
    apply andb_true_iff in Hsafe as [Hselector Hcases].
  - now apply Nat.eqb_eq in Hselector.
  - exact Hcases.
Qed.

Lemma watc_label_private_inv :
  forall protected_identifiers label body,
    watc_statement_is_private protected_identifiers
      (Clight.Slabel label body) ->
    watc_statement_is_private protected_identifiers body.
Proof.
  intros protected label body Hsafe identifier Hin.
  exact (Hsafe identifier Hin).
Qed.

Lemma watc_labeled_private_inv :
  forall protected_identifiers case body rest,
    watc_labeled_statements_are_private protected_identifiers
      (Clight.LScons case body rest) ->
    watc_statement_is_private protected_identifiers body /\
    watc_labeled_statements_are_private protected_identifiers rest.
Proof.
  intros protected case body rest Hsafe. split; intros identifier Hin;
    specialize (Hsafe identifier Hin); cbn in Hsafe;
    apply andb_true_iff in Hsafe; tauto.
Qed.

Inductive watc_set_rhs_classification
    (target : ident) (right_expression : Clight.expr) : Prop :=
| watc_set_rhs_has_no_table :
    wat_evar_count target right_expression = 0%nat ->
    watc_set_rhs_classification target right_expression
| watc_set_rhs_is_terminal_read :
    wat_evar_count target right_expression <> 0%nat ->
    wat_is_terminal_table_read target right_expression = true ->
    watc_set_rhs_classification target right_expression.

Lemma watc_safe_set_rhs_is_absent_or_terminal :
  forall target destination right_expression,
    wat_statement_access_safe_s target
      (Clight.Sset destination right_expression) = true ->
    watc_set_rhs_classification target right_expression.
Proof.
  intros target destination right_expression Hsafe.
  cbn in Hsafe.
  destruct (wat_evar_count target right_expression) as [| count] eqn:Hcount.
  - now apply watc_set_rhs_has_no_table.
  - eapply watc_set_rhs_is_terminal_read; [lia | exact Hsafe].
Qed.

Lemma watc_safe_assign_has_no_table_occurrence :
  forall target left_expression right_expression,
    wat_statement_access_safe_s target
      (Clight.Sassign left_expression right_expression) = true ->
    wat_evar_count target left_expression = 0%nat /\
    wat_evar_count target right_expression = 0%nat.
Proof.
  intros target left right Hsafe. cbn in Hsafe.
  apply Nat.eqb_eq in Hsafe. lia.
Qed.

Lemma watc_safe_call_has_no_table_occurrence :
  forall target destination function_expression arguments,
    wat_statement_access_safe_s target
      (Clight.Scall destination function_expression arguments) = true ->
    wat_evar_count target function_expression = 0%nat /\
    wat_expression_list_evar_count target arguments = 0%nat.
Proof.
  intros target destination function_expression arguments Hsafe.
  cbn in Hsafe. apply Nat.eqb_eq in Hsafe. lia.
Qed.

Lemma watc_expression_list_count_zero_each :
  forall target expressions expression,
    In expression expressions ->
    wat_expression_list_evar_count target expressions = 0%nat ->
    wat_evar_count target expression = 0%nat.
Proof.
  intros target expressions.
  induction expressions as [| head rest IH]; intros expression Hin Hzero.
  - contradiction.
  - unfold wat_expression_list_evar_count in Hzero.
    cbn [fold_right] in Hzero.
    destruct Hin as [Heq | Hin].
    + subst. lia.
    + eapply IH; eauto.
      unfold wat_expression_list_evar_count. lia.
Qed.

Lemma watc_safe_builtin_has_no_table_argument :
  forall target destination external argument_types arguments,
    wat_statement_access_safe_s target
      (Clight.Sbuiltin destination external argument_types arguments) = true ->
    wat_expression_list_evar_count target arguments = 0%nat.
Proof.
  intros target destination external argument_types arguments Hsafe.
  cbn in Hsafe. now apply Nat.eqb_eq in Hsafe.
Qed.

Lemma watc_safe_return_has_no_table_occurrence :
  forall target value,
    wat_statement_access_safe_s target
      (Clight.Sreturn (Some value)) = true ->
    wat_evar_count target value = 0%nat.
Proof.
  intros target value Hsafe. cbn in Hsafe.
  now apply Nat.eqb_eq in Hsafe.
Qed.

(** Switch selection only removes cases.  It cannot manufacture a table use
    not already accepted by the checker. *)
Lemma watc_select_switch_case_target_private :
  forall target selector cases selected,
    Clight.select_switch_case selector cases = Some selected ->
    wat_statement_access_safe_ls target cases = true ->
    wat_statement_access_safe_ls target selected = true.
Proof.
  intros target selector.
  fix IH 1.
  intros cases selected Hselect Hsafe.
  destruct cases as [| case body rest].
  - discriminate.
  - cbn in Hsafe. apply andb_true_iff in Hsafe as [Hbody Hrest].
    destruct case as [candidate |].
    + cbn in Hselect. destruct (zeq candidate selector) as [Heq | Hneq].
      * inversion Hselect; subst. cbn. now rewrite Hbody, Hrest.
      * eapply IH; eauto.
    + cbn in Hselect. eapply IH; eauto.
Qed.

Lemma watc_select_switch_default_target_private :
  forall target cases,
    wat_statement_access_safe_ls target cases = true ->
    wat_statement_access_safe_ls target
      (Clight.select_switch_default cases) = true.
Proof.
  intros target.
  fix IH 1.
  intros cases Hsafe.
  destruct cases as [| case body rest].
  - reflexivity.
  - cbn in Hsafe. apply andb_true_iff in Hsafe as [Hbody Hrest].
    destruct case as [candidate |].
    + cbn. now apply IH.
    + cbn. now rewrite Hbody, Hrest.
Qed.

Lemma watc_select_switch_private :
  forall protected_identifiers selector cases,
    watc_labeled_statements_are_private protected_identifiers cases ->
    watc_labeled_statements_are_private protected_identifiers
      (Clight.select_switch selector cases).
Proof.
  intros protected selector cases Hsafe identifier Hin.
  specialize (Hsafe identifier Hin).
  unfold Clight.select_switch.
  destruct (Clight.select_switch_case selector cases) as [selected |]
    eqn:Hcase.
  - eapply watc_select_switch_case_target_private; eauto.
  - now apply watc_select_switch_default_target_private.
Qed.

Lemma watc_seq_of_labeled_statement_target_private :
  forall target cases,
    wat_statement_access_safe_ls target cases = true ->
    wat_statement_access_safe_s target
      (Clight.seq_of_labeled_statement cases) = true.
Proof.
  intros target.
  fix IH 1.
  intros cases Hsafe.
  destruct cases as [| case body rest].
  - reflexivity.
  - cbn in Hsafe. apply andb_true_iff in Hsafe as [Hbody Hrest].
    cbn. rewrite Hbody. now apply IH.
Qed.

Lemma watc_seq_of_labeled_statements_is_private :
  forall protected_identifiers cases,
    watc_labeled_statements_are_private protected_identifiers cases ->
    watc_statement_is_private protected_identifiers
      (Clight.seq_of_labeled_statement cases).
Proof.
  intros protected cases Hsafe identifier Hin.
  eapply watc_seq_of_labeled_statement_target_private.
  exact (Hsafe identifier Hin).
Qed.

Lemma watc_selected_switch_statement_is_private :
  forall protected_identifiers selector cases,
    watc_labeled_statements_are_private protected_identifiers cases ->
    watc_statement_is_private protected_identifiers
      (Clight.seq_of_labeled_statement
        (Clight.select_switch selector cases)).
Proof.
  intros protected selector cases Hsafe identifier Hin.
  eapply watc_seq_of_labeled_statement_target_private.
  now apply (watc_select_switch_private protected selector cases Hsafe).
Qed.

(** * Continuations and selected-function provenance *)

Definition watc_internal_function_is_reached
    (ge : Clight.genv) (body : Clight.function) : Prop :=
  exists function_block,
    Genv.find_funct_ptr ge function_block = Some (Ctypes.Internal body).

Definition watc_fundef_is_reached
    (ge : Clight.genv) (definition : Clight.fundef) : Prop :=
  exists function_block,
    Genv.find_funct_ptr ge function_block = Some definition.

Definition watc_fundef_is_controlled
    (function_is_controlled : Clight.function -> Prop)
    (definition : Clight.fundef) : Prop :=
  match definition with
  | Ctypes.Internal body => function_is_controlled body
  | Ctypes.External _ _ _ _ => True
  end.

Inductive watc_continuation_is_private
    (ge : Clight.genv) (protected_identifiers : list ident)
    (function_is_controlled : Clight.function -> Prop)
    (injection : meminj) : Clight.cont -> Prop :=
| watc_cont_stop :
    watc_continuation_is_private ge protected_identifiers
      function_is_controlled injection Clight.Kstop
| watc_cont_seq :
    forall next continuation,
      watc_statement_is_private protected_identifiers next ->
      watc_continuation_is_private ge protected_identifiers
        function_is_controlled injection continuation ->
      watc_continuation_is_private ge protected_identifiers
        function_is_controlled injection (Clight.Kseq next continuation)
| watc_cont_loop1 :
    forall body increment continuation,
      watc_statement_is_private protected_identifiers body ->
      watc_statement_is_private protected_identifiers increment ->
      watc_continuation_is_private ge protected_identifiers
        function_is_controlled injection continuation ->
      watc_continuation_is_private ge protected_identifiers
        function_is_controlled injection
        (Clight.Kloop1 body increment continuation)
| watc_cont_loop2 :
    forall body increment continuation,
      watc_statement_is_private protected_identifiers body ->
      watc_statement_is_private protected_identifiers increment ->
      watc_continuation_is_private ge protected_identifiers
        function_is_controlled injection continuation ->
      watc_continuation_is_private ge protected_identifiers
        function_is_controlled injection
        (Clight.Kloop2 body increment continuation)
| watc_cont_switch :
    forall continuation,
      watc_continuation_is_private ge protected_identifiers
        function_is_controlled injection continuation ->
      watc_continuation_is_private ge protected_identifiers
        function_is_controlled injection (Clight.Kswitch continuation)
| watc_cont_call :
    forall destination caller environment temporaries continuation,
      function_is_controlled caller ->
      watc_internal_function_is_reached ge caller ->
      watc_environment_self_injects injection environment ->
      watc_temps_self_inject injection temporaries ->
      watc_continuation_is_private ge protected_identifiers
        function_is_controlled injection continuation ->
      watc_continuation_is_private ge protected_identifiers
        function_is_controlled injection
        (Clight.Kcall destination caller environment temporaries continuation).

Lemma watc_continuation_is_private_incr :
  forall ge protected_identifiers function_is_controlled
      injection injection' continuation,
    inject_incr injection injection' ->
    watc_continuation_is_private ge protected_identifiers
      function_is_controlled injection continuation ->
    watc_continuation_is_private ge protected_identifiers
      function_is_controlled injection' continuation.
Proof.
  intros ge protected function_is_controlled injection injection' continuation
    Hincr Hcontinuation.
  induction Hcontinuation.
  - constructor.
  - econstructor; eauto.
  - econstructor; eauto.
  - econstructor; eauto.
  - econstructor; eauto.
  - econstructor; eauto using watc_environment_self_injects_incr,
      watc_temps_self_inject_incr.
Qed.

Lemma watc_call_cont_is_private :
  forall ge protected_identifiers function_is_controlled injection continuation,
    watc_continuation_is_private ge protected_identifiers
      function_is_controlled injection continuation ->
    watc_continuation_is_private ge protected_identifiers
      function_is_controlled injection (Clight.call_cont continuation).
Proof.
  intros ge protected function_is_controlled injection continuation Hprivate.
  induction Hprivate; cbn [Clight.call_cont];
    eauto using watc_continuation_is_private.
Qed.

Lemma watc_seq_continuation_private_inv :
  forall ge protected function_is_controlled injection next continuation,
    watc_continuation_is_private ge protected function_is_controlled injection
      (Clight.Kseq next continuation) ->
    watc_statement_is_private protected next /\
    watc_continuation_is_private ge protected function_is_controlled injection
      continuation.
Proof. intros. inversion H; subst. auto. Qed.

Lemma watc_loop1_continuation_private_inv :
  forall ge protected function_is_controlled injection body increment continuation,
    watc_continuation_is_private ge protected function_is_controlled injection
      (Clight.Kloop1 body increment continuation) ->
    watc_statement_is_private protected body /\
    watc_statement_is_private protected increment /\
    watc_continuation_is_private ge protected function_is_controlled injection
      continuation.
Proof. intros. inversion H; subst. auto. Qed.

Lemma watc_loop2_continuation_private_inv :
  forall ge protected function_is_controlled injection body increment continuation,
    watc_continuation_is_private ge protected function_is_controlled injection
      (Clight.Kloop2 body increment continuation) ->
    watc_statement_is_private protected body /\
    watc_statement_is_private protected increment /\
    watc_continuation_is_private ge protected function_is_controlled injection
      continuation.
Proof. intros. inversion H; subst. auto. Qed.

Lemma watc_switch_continuation_private_inv :
  forall ge protected function_is_controlled injection continuation,
    watc_continuation_is_private ge protected function_is_controlled injection
      (Clight.Kswitch continuation) ->
    watc_continuation_is_private ge protected function_is_controlled injection
      continuation.
Proof. intros. inversion H; subst. auto. Qed.

Lemma watc_continue_from_loop1_is_private :
  forall ge protected function_is_controlled injection body increment continuation,
    watc_continuation_is_private ge protected function_is_controlled injection
      (Clight.Kloop1 body increment continuation) ->
    watc_statement_is_private protected increment /\
    watc_continuation_is_private ge protected function_is_controlled injection
      (Clight.Kloop2 body increment continuation).
Proof.
  intros. apply watc_loop1_continuation_private_inv in H
    as [Hbody [Hincrement Hcontinuation]].
  split; [exact Hincrement |]. constructor; assumption.
Qed.

Lemma watc_restart_after_loop2_is_private :
  forall ge protected function_is_controlled injection body increment continuation,
    watc_continuation_is_private ge protected function_is_controlled injection
      (Clight.Kloop2 body increment continuation) ->
    watc_statement_is_private protected (Clight.Sloop body increment) /\
    watc_continuation_is_private ge protected function_is_controlled injection
      continuation.
Proof.
  intros. apply watc_loop2_continuation_private_inv in H
    as [Hbody [Hincrement Hcontinuation]].
  split; [|exact Hcontinuation].
  intros identifier Hin. cbn.
  now rewrite (Hbody identifier Hin), (Hincrement identifier Hin).
Qed.

Scheme watc_statement_induction := Induction for statement Sort Prop
  with watc_labeled_statements_induction :=
    Induction for labeled_statements Sort Prop.
Combined Scheme watc_statement_labeled_induction
  from watc_statement_induction, watc_labeled_statements_induction.

(** The source checker is structurally closed under [find_label].  This is the
    non-computational fact needed for [Sgoto]: lookup can rearrange checked
    substatements into a continuation, but it cannot introduce new syntax. *)
Lemma watc_find_label_preserves_private_syntax :
  forall protected_identifiers,
    (forall source_statement,
      watc_statement_is_private protected_identifiers source_statement ->
      forall ge function_is_controlled injection label base_continuation
          selected_statement selected_continuation,
        watc_continuation_is_private ge protected_identifiers
          function_is_controlled injection base_continuation ->
        Clight.find_label label source_statement base_continuation =
          Some (selected_statement, selected_continuation) ->
        watc_statement_is_private protected_identifiers selected_statement /\
        watc_continuation_is_private ge protected_identifiers
          function_is_controlled injection selected_continuation) /\
    (forall source_cases,
      watc_labeled_statements_are_private protected_identifiers source_cases ->
      forall ge function_is_controlled injection label base_continuation
          selected_statement selected_continuation,
        watc_continuation_is_private ge protected_identifiers
          function_is_controlled injection base_continuation ->
        Clight.find_label_ls label source_cases base_continuation =
          Some (selected_statement, selected_continuation) ->
        watc_statement_is_private protected_identifiers selected_statement /\
        watc_continuation_is_private ge protected_identifiers
          function_is_controlled injection selected_continuation).
Proof.
  intros protected.
  apply watc_statement_labeled_induction.
  - intros Hsafe ge controlled injection label base selected selected_cont
      Hbase Hfind. discriminate.
  - intros left right Hsafe ge controlled injection label base selected
      selected_cont Hbase Hfind. discriminate.
  - intros destination value Hsafe ge controlled injection label base selected
      selected_cont Hbase Hfind. discriminate.
  - intros destination function_expression arguments Hsafe ge controlled
      injection label base selected selected_cont Hbase Hfind. discriminate.
  - intros destination external argument_types arguments Hsafe ge controlled
      injection label base selected selected_cont Hbase Hfind. discriminate.
  - intros first IHfirst second IHsecond Hsafe ge controlled injection label
      base selected selected_cont Hbase Hfind.
    destruct (watc_sequence_private_inv _ _ _ Hsafe) as [Hfirst Hsecond].
    cbn in Hfind.
    destruct (Clight.find_label label first (Clight.Kseq second base))
      as [[found found_cont] |] eqn:Hfirst_lookup.
    + inversion Hfind; subst.
      eapply (IHfirst Hfirst ge controlled injection label
        (Clight.Kseq second base) selected selected_cont).
      * constructor; assumption.
      * exact Hfirst_lookup.
    + eapply (IHsecond Hsecond ge controlled injection label base
        selected selected_cont); eauto.
  - intros condition yes_branch IHyes no_branch IHno Hsafe ge controlled
      injection label base selected selected_cont Hbase Hfind.
    destruct (watc_if_private_inv _ _ _ _ Hsafe)
      as [Hcondition [Hyes Hno]].
    cbn in Hfind.
    destruct (Clight.find_label label yes_branch base)
      as [[found found_cont] |] eqn:Hyes_lookup.
    + inversion Hfind; subst.
      eapply IHyes; eauto.
    + eapply IHno; eauto.
  - intros body IHbody increment IHincrement Hsafe ge controlled injection
      label base selected selected_cont Hbase Hfind.
    destruct (watc_loop_private_inv _ _ _ Hsafe) as [Hbody Hincrement].
    cbn in Hfind.
    destruct (Clight.find_label label body
      (Clight.Kloop1 body increment base))
      as [[found found_cont] |] eqn:Hbody_lookup.
    + inversion Hfind; subst.
      eapply (IHbody Hbody ge controlled injection label
        (Clight.Kloop1 body increment base) selected selected_cont).
      * constructor; assumption.
      * exact Hbody_lookup.
    + eapply (IHincrement Hincrement ge controlled injection label
        (Clight.Kloop2 body increment base) selected selected_cont).
      * constructor; assumption.
      * exact Hfind.
  - intros Hsafe ge controlled injection label base selected selected_cont
      Hbase Hfind. discriminate.
  - intros Hsafe ge controlled injection label base selected selected_cont
      Hbase Hfind. discriminate.
  - intros result Hsafe ge controlled injection label base selected selected_cont
      Hbase Hfind. discriminate.
  - intros selector cases IHcases Hsafe ge controlled injection label base
      selected selected_cont Hbase Hfind.
    destruct (watc_switch_private_inv _ _ _ Hsafe) as [Hselector Hcases].
    cbn in Hfind.
    eapply (IHcases Hcases ge controlled injection label
      (Clight.Kswitch base) selected selected_cont).
    + constructor. exact Hbase.
    + exact Hfind.
  - intros source_label body IHbody Hsafe ge controlled injection label base
      selected selected_cont Hbase Hfind.
    pose proof (watc_label_private_inv _ _ _ Hsafe) as Hbody.
    cbn in Hfind.
    destruct (ident_eq label source_label) as [Heq | Hneq].
    + inversion Hfind; subst. auto.
    + eapply IHbody; eauto.
  - intros target_label Hsafe ge controlled injection label base selected
      selected_cont Hbase Hfind. discriminate.
  - intros Hsafe ge controlled injection label base selected selected_cont
      Hbase Hfind. discriminate.
  - intros case body IHbody rest IHrest Hsafe ge controlled injection label
      base selected selected_cont Hbase Hfind.
    destruct (watc_labeled_private_inv _ _ _ _ Hsafe)
      as [Hbody Hrest].
    cbn in Hfind.
    destruct (Clight.find_label label body
      (Clight.Kseq (Clight.seq_of_labeled_statement rest) base))
      as [[found found_cont] |] eqn:Hbody_lookup.
    + inversion Hfind; subst.
      eapply (IHbody Hbody ge controlled injection label
        (Clight.Kseq (Clight.seq_of_labeled_statement rest) base)
        selected selected_cont).
      * constructor; [now apply watc_seq_of_labeled_statements_is_private |].
        exact Hbase.
      * exact Hbody_lookup.
    + eapply (IHrest Hrest ge controlled injection label base
        selected selected_cont); eauto.
Qed.

(** A control certificate is the source-to-live bridge.  It says which
    functions can be reached, that every such body passes the checker, and
    that a [goto] lookup in a checked body returns a checked statement and a
    continuation made only from checked frames.  Keeping the predicate over
    functions explicit lets the US and JP whole-AST receipts instantiate it
    without identifying functions by structural equality. *)
Record watc_function_control_certificate
    (protected_identifiers : list ident)
    (function_is_controlled : Clight.function -> Prop) : Prop := {
  watc_controlled_body_is_private :
    forall body,
      function_is_controlled body ->
      watc_statement_is_private protected_identifiers (Clight.fn_body body);
  watc_controlled_find_label_is_private :
    forall ge injection body label base_continuation
        selected_statement selected_continuation,
      function_is_controlled body ->
      watc_continuation_is_private ge protected_identifiers
        function_is_controlled injection base_continuation ->
      Clight.find_label label (Clight.fn_body body) base_continuation =
        Some (selected_statement, selected_continuation) ->
      watc_statement_is_private protected_identifiers selected_statement /\
      watc_continuation_is_private ge protected_identifiers
        function_is_controlled injection selected_continuation
}.

Theorem watc_body_checker_builds_control_certificate :
  forall protected_identifiers
      (function_is_controlled : Clight.function -> Prop),
    (forall body,
      function_is_controlled body ->
      watc_statement_is_private protected_identifiers (Clight.fn_body body)) ->
    watc_function_control_certificate
      protected_identifiers function_is_controlled.
Proof.
  intros protected controlled Hbodies.
  constructor.
  - exact Hbodies.
  - intros ge injection body label base selected selected_cont Hbody Hbase
      Hfind.
    pose proof (proj1
      (watc_find_label_preserves_private_syntax protected)
      (Clight.fn_body body)) as Hclosure.
    eapply Hclosure; eauto.
Qed.

Lemma watc_goto_from_call_cont_is_private :
  forall protected function_is_controlled
      (certificate : watc_function_control_certificate
        protected function_is_controlled)
      ge injection body label continuation selected_statement
      selected_continuation,
    function_is_controlled body ->
    watc_continuation_is_private ge protected function_is_controlled injection
      continuation ->
    Clight.find_label label (Clight.fn_body body)
      (Clight.call_cont continuation) =
      Some (selected_statement, selected_continuation) ->
    watc_statement_is_private protected selected_statement /\
    watc_continuation_is_private ge protected function_is_controlled injection
      selected_continuation.
Proof.
  intros protected function_is_controlled certificate ge injection body label
    continuation selected_statement selected_continuation Hbody Hcontinuation
    Hfind.
  destruct certificate as [Hbody_private Hlabel_private].
  eapply (Hlabel_private ge injection body label
    (Clight.call_cont continuation) selected_statement selected_continuation).
  - exact Hbody.
  - now apply watc_call_cont_is_private.
  - exact Hfind.
Qed.

(** * Reached Clight states *)

Inductive watc_reached_state_is_private
    (ge : Clight.genv) (protected_identifiers : list ident)
    (function_is_controlled : Clight.function -> Prop)
    (injection : meminj) : Clight.state -> Prop :=
| watc_reached_internal_state :
    forall body statement continuation environment temporaries memory,
      function_is_controlled body ->
      watc_internal_function_is_reached ge body ->
      watc_statement_is_private protected_identifiers statement ->
      watc_continuation_is_private ge protected_identifiers
        function_is_controlled injection continuation ->
      watc_environment_self_injects injection environment ->
      watc_temps_self_inject injection temporaries ->
      watc_reached_state_is_private ge protected_identifiers
        function_is_controlled injection
        (Clight.State body statement continuation environment temporaries memory)
| watc_reached_call_state :
    forall definition arguments continuation memory,
      watc_fundef_is_controlled function_is_controlled definition ->
      watc_fundef_is_reached ge definition ->
      watc_values_self_inject injection arguments ->
      watc_continuation_is_private ge protected_identifiers
        function_is_controlled injection continuation ->
      watc_reached_state_is_private ge protected_identifiers
        function_is_controlled injection
        (Clight.Callstate definition arguments continuation memory)
| watc_reached_return_state :
    forall result continuation memory,
      Val.inject injection result result ->
      watc_continuation_is_private ge protected_identifiers
        function_is_controlled injection continuation ->
      watc_reached_state_is_private ge protected_identifiers
        function_is_controlled injection
        (Clight.Returnstate result continuation memory).

Lemma watc_reached_state_is_private_incr :
  forall ge protected function_is_controlled injection injection' state,
    inject_incr injection injection' ->
    watc_reached_state_is_private ge protected function_is_controlled
      injection state ->
    watc_reached_state_is_private ge protected function_is_controlled
      injection' state.
Proof.
  intros ge protected function_is_controlled injection injection' state Hincr
    Hstate.
  inversion Hstate; subst.
  - econstructor; eauto using watc_continuation_is_private_incr,
      watc_environment_self_injects_incr, watc_temps_self_inject_incr.
  - econstructor; eauto using watc_values_self_inject_incr,
      watc_continuation_is_private_incr.
  - econstructor; eauto using val_inject_incr,
      watc_continuation_is_private_incr.
Qed.

(** These two small constructors are the value-side conclusions used by
    [step_set], [step_builtin], and [step_returnstate]. *)
Lemma watc_reached_internal_state_after_set :
  forall ge protected (function_is_controlled : Clight.function -> Prop) injection
      body continuation environment temporaries memory destination value,
    function_is_controlled body ->
    watc_internal_function_is_reached ge body ->
    watc_continuation_is_private ge protected function_is_controlled injection
      continuation ->
    watc_environment_self_injects injection environment ->
    watc_temps_self_inject injection temporaries ->
    Val.inject injection value value ->
    watc_reached_state_is_private ge protected function_is_controlled injection
      (Clight.State body Clight.Sskip continuation environment
        (PTree.set destination value temporaries) memory).
Proof.
  intros. econstructor; eauto using watc_skip_is_private,
    watc_temps_set_self_injects.
Qed.

Lemma watc_reached_internal_state_after_opttemp :
  forall ge protected (function_is_controlled : Clight.function -> Prop) injection
      body continuation environment temporaries memory destination value,
    function_is_controlled body ->
    watc_internal_function_is_reached ge body ->
    watc_continuation_is_private ge protected function_is_controlled injection
      continuation ->
    watc_environment_self_injects injection environment ->
    watc_temps_self_inject injection temporaries ->
    Val.inject injection value value ->
    watc_reached_state_is_private ge protected function_is_controlled injection
      (Clight.State body Clight.Sskip continuation environment
        (Clight.set_opttemp destination value temporaries) memory).
Proof.
  intros. econstructor; eauto using watc_skip_is_private,
    watc_set_opttemp_self_injects.
Qed.

Print Assumptions watc_blocks_of_env_are_self_mapped.
Print Assumptions watc_selected_switch_statement_is_private.
Print Assumptions watc_reached_state_is_private_incr.
