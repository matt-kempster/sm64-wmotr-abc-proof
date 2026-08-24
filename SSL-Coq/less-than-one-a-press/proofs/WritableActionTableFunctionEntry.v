(** Function-entry provenance for the private writable-action-table
    injection.

    [watpl_private_alloc_variables_carries] already carries the memory
    invariant and protected-block frame through Clight's batched local
    allocation.  The live step invariant also needs the stronger fact that
    every block installed in the returned local environment is self-mapped
    by the returned injection.  This file proves that fact in the same
    allocation induction, then proves that [function_entry2] also installs
    only self-injected temporary values when its incoming arguments are
    self-injected.

    It has no assumptions about the selected SM64 bodies and is reused by the
    reached-state step classifier. *)

From Coq Require Import List ZArith.
From compcert Require Import
  AST Clight Coqlib Ctypes Globalenvs Maps Memory Values.
From LessThanOneAPress.Proofs Require Import
  WritableActionTablePrivateLive.

Import ListNotations.
Local Open Scope Z_scope.

Definition watpa_environment_self_injects
    (injection : meminj) (environment : Clight.env) : Prop :=
  forall identifier local_block local_type,
    environment ! identifier = Some (local_block, local_type) ->
    injection local_block = Some (local_block, 0).

Definition watpa_temps_self_inject
    (injection : meminj) (temporaries : Clight.temp_env) : Prop :=
  forall identifier value,
    temporaries ! identifier = Some value ->
    Val.inject injection value value.

Lemma watpa_environment_self_injects_incr :
  forall injection injection' environment,
    inject_incr injection injection' ->
    watpa_environment_self_injects injection environment ->
    watpa_environment_self_injects injection' environment.
Proof.
  intros injection injection' environment Hincr Henvironment identifier
    local_block local_type Hlookup.
  now apply Hincr, Henvironment with
    (identifier := identifier) (local_type := local_type).
Qed.

Lemma watpa_temps_self_inject_incr :
  forall injection injection' temporaries,
    inject_incr injection injection' ->
    watpa_temps_self_inject injection temporaries ->
    watpa_temps_self_inject injection' temporaries.
Proof.
  intros injection injection' temporaries Hincr Htemporaries identifier value
    Hlookup.
  eapply val_inject_incr; [exact Hincr |].
  now apply Htemporaries with (identifier := identifier).
Qed.

Lemma watpa_value_list_self_injects_incr :
  forall injection injection' values,
    inject_incr injection injection' ->
    Val.inject_list injection values values ->
    Val.inject_list injection' values values.
Proof.
  intros injection injection' values Hincr Hvalues.
  eapply val_inject_list_incr; eauto.
Qed.

Lemma watpa_empty_environment_self_injects :
  forall injection,
    watpa_environment_self_injects injection Clight.empty_env.
Proof.
  intros injection identifier local_block local_type Hlookup.
  rewrite PTree.gempty in Hlookup. discriminate.
Qed.

Lemma watpa_environment_set_self_injects :
  forall injection environment identifier local_block local_type,
    watpa_environment_self_injects injection environment ->
    injection local_block = Some (local_block, 0) ->
    watpa_environment_self_injects injection
      (PTree.set identifier (local_block, local_type) environment).
Proof.
  intros injection environment identifier local_block local_type
    Henvironment Hlocal queried_identifier queried_block queried_type Hlookup.
  destruct (peq queried_identifier identifier) as [Hequal | Hdifferent].
  - subst queried_identifier. rewrite PTree.gss in Hlookup.
    inversion Hlookup; subst. exact Hlocal.
  - rewrite PTree.gso in Hlookup by exact Hdifferent.
    now apply Henvironment with
      (identifier := queried_identifier) (local_type := queried_type).
Qed.

(** This is the strengthened form of
    [watpl_private_alloc_variables_carries].  In addition to the memory
    carrier, every binding in the returned environment names a block mapped
    to itself with displacement zero.  Existing bindings are preserved by
    [inject_incr]; the one fresh binding in the inductive case is supplied by
    [watpl_private_alloc_carries]. *)
Theorem watpa_private_alloc_variables_carries_with_environment :
  forall (ge : Clight.genv) protected_blocks environment before variables
      environment' after injection,
    Clight.alloc_variables ge environment before variables
      environment' after ->
    ActionTablePrivateMemoryInvariant
      ge protected_blocks before injection ->
    watpa_environment_self_injects injection environment ->
    exists injection',
      ActionTablePrivateMemoryInvariant
        ge protected_blocks after injection' /\
      inject_incr injection injection' /\
      ActionTablePrivateMemoryFrame protected_blocks before after /\
      watpa_environment_self_injects injection' environment'.
Proof.
  intros ge protected_blocks environment before variables environment' after
    injection Halloc.
  revert injection.
  induction Halloc as
    [environment memory |
     environment memory identifier variable_type variables middle new_block
       after environment' Hone Hrest IH];
    intros injection Hinvariant Henvironment.
  - exists injection. split; [exact Hinvariant |].
    split; [apply inject_incr_refl |].
    split; [apply watpl_frame_refl | exact Henvironment].
  - destruct (watpl_private_alloc_carries
      ge protected_blocks memory injection 0 (Ctypes.sizeof ge variable_type)
      middle new_block Hinvariant Hone) as
      [middle_injection
        [Hmiddle [Hincr_middle [Hnew Hframe_middle]]]].
    assert (Hset_environment :
      watpa_environment_self_injects middle_injection
        (PTree.set identifier (new_block, variable_type) environment)).
    { apply watpa_environment_set_self_injects.
      - exact (watpa_environment_self_injects_incr
          injection middle_injection environment Hincr_middle Henvironment).
      - exact Hnew. }
    destruct (IH middle_injection Hmiddle Hset_environment) as
      [after_injection
        [Hafter [Hincr_after [Hframe_after Hafter_environment]]]].
    exists after_injection. split; [exact Hafter |].
    split; [eapply inject_incr_trans; eauto |].
    split; [eapply watpl_frame_trans; eauto | exact Hafter_environment].
Qed.

(** Every block in [blocks_of_env] is one of the environment bindings, so
    the strengthened entry invariant directly discharges the self-mapping
    premise needed by [watpl_private_free_list_carries] at return. *)
Lemma watpa_blocks_of_environment_are_self_mapped :
  forall ge injection environment freed_block low high,
    watpa_environment_self_injects injection environment ->
    In (freed_block, low, high) (Clight.blocks_of_env ge environment) ->
    injection freed_block = Some (freed_block, 0).
Proof.
  intros ge injection environment freed_block low high Henvironment Hin.
  unfold Clight.blocks_of_env in Hin.
  apply list_in_map_inv in Hin.
  destruct Hin as [[identifier [local_block local_type]] [Hequal Hin]].
  unfold Clight.block_of_binding in Hequal.
  assert (Hblock : local_block = freed_block) by congruence.
  subst local_block.
  apply Henvironment with
    (identifier := identifier) (local_type := local_type).
  now apply PTree.elements_complete.
Qed.

Lemma watpa_temp_set_self_injects :
  forall injection temporaries identifier value,
    watpa_temps_self_inject injection temporaries ->
    Val.inject injection value value ->
    watpa_temps_self_inject injection
      (PTree.set identifier value temporaries).
Proof.
  intros injection temporaries identifier value Htemporaries Hvalue
    queried_identifier queried_value Hlookup.
  destruct (peq queried_identifier identifier) as [Hequal | Hdifferent].
  - subst queried_identifier. rewrite PTree.gss in Hlookup.
    inversion Hlookup; subst. exact Hvalue.
  - rewrite PTree.gso in Hlookup by exact Hdifferent.
    now apply Htemporaries with (identifier := queried_identifier).
Qed.

Lemma watpa_create_undef_temps_self_injects :
  forall injection temporary_declarations,
    watpa_temps_self_inject injection
      (Clight.create_undef_temps temporary_declarations).
Proof.
  intros injection temporary_declarations.
  induction temporary_declarations as
    [| [identifier temporary_type] remaining IH];
    intros queried_identifier value Hlookup.
  - cbn in Hlookup. discriminate.
  - cbn in Hlookup.
    destruct (peq queried_identifier identifier) as [Hequal | Hdifferent].
    + subst queried_identifier. rewrite PTree.gss in Hlookup.
      inversion Hlookup; subst. constructor.
    + rewrite PTree.gso in Hlookup by exact Hdifferent.
      exact (IH queried_identifier value Hlookup).
Qed.

(** Argument binding only inserts the actual values into the
    temporary tree.  Thus a self-injected argument list and a self-injected
    starting tree produce a self-injected entry tree. *)
Lemma watpa_bind_parameter_temps_self_injects :
  forall injection parameters arguments base_temporaries bound_temporaries,
    Val.inject_list injection arguments arguments ->
    watpa_temps_self_inject injection base_temporaries ->
    Clight.bind_parameter_temps parameters arguments base_temporaries =
      Some bound_temporaries ->
    watpa_temps_self_inject injection bound_temporaries.
Proof.
  intros injection parameters.
  induction parameters as [| [identifier parameter_type] remaining IH];
    intros arguments base_temporaries bound_temporaries Harguments Hbase Hbind;
    destruct arguments as [| argument remaining_arguments]; cbn in Hbind.
  - inversion Hbind; subst. exact Hbase.
  - discriminate.
  - discriminate.
  - inversion Harguments; subst.
    match goal with
    | Hargument : Val.inject injection argument argument,
      Hremaining : Val.inject_list injection remaining_arguments
        remaining_arguments |- _ =>
        eapply IH with
          (base_temporaries := PTree.set identifier argument base_temporaries);
        [exact Hremaining | | exact Hbind];
        eapply watpa_temp_set_self_injects; eauto
    end.
Qed.

(** Full internal function-entry carrier.  The allocation part returns the
    extended injection and local-environment provenance.  The same extension
    still injects every incoming argument, and parameter binding over the
    undef temporary tree therefore supplies temporary-value provenance. *)
Theorem watpa_private_function_entry2_carries :
  forall (ge : Clight.genv) protected_blocks
      (function : Clight.function) arguments before
      entry_environment entry_temporaries after injection,
    Clight.function_entry2 ge function arguments before
      entry_environment entry_temporaries after ->
    ActionTablePrivateMemoryInvariant
      ge protected_blocks before injection ->
    Val.inject_list injection arguments arguments ->
    exists injection',
      ActionTablePrivateMemoryInvariant
        ge protected_blocks after injection' /\
      inject_incr injection injection' /\
      ActionTablePrivateMemoryFrame protected_blocks before after /\
      watpa_environment_self_injects injection' entry_environment /\
      watpa_temps_self_inject injection' entry_temporaries.
Proof.
  intros ge protected_blocks function arguments before entry_environment
    entry_temporaries after injection Hentry Hinvariant Harguments.
  inversion Hentry; subst.
  destruct
    (watpa_private_alloc_variables_carries_with_environment
      ge protected_blocks Clight.empty_env before function.(fn_vars)
      entry_environment after injection H2 Hinvariant
      (watpa_empty_environment_self_injects injection)) as
    [entry_injection
      [Hentry_invariant
        [Hentry_incr [Hentry_frame Hentry_environment]]]].
  assert (Hentry_arguments :
    Val.inject_list entry_injection arguments arguments).
  { eapply watpa_value_list_self_injects_incr; eauto. }
  assert (Hundef :
    watpa_temps_self_inject entry_injection
      (Clight.create_undef_temps function.(fn_temps))).
  { apply watpa_create_undef_temps_self_injects. }
  assert (Hentry_temporaries :
    watpa_temps_self_inject entry_injection entry_temporaries).
  { eapply watpa_bind_parameter_temps_self_injects; eauto. }
  exists entry_injection. split; [exact Hentry_invariant |].
  split; [exact Hentry_incr |].
  split; [exact Hentry_frame |].
  split; [exact Hentry_environment | exact Hentry_temporaries].
Qed.

Corollary watpa_private_function_entry2_maps_return_frame :
  forall (ge : Clight.genv) protected_blocks
      (function : Clight.function) arguments before
      entry_environment entry_temporaries after injection,
    Clight.function_entry2 ge function arguments before
      entry_environment entry_temporaries after ->
    ActionTablePrivateMemoryInvariant
      ge protected_blocks before injection ->
    Val.inject_list injection arguments arguments ->
    exists injection',
      ActionTablePrivateMemoryInvariant
        ge protected_blocks after injection' /\
      inject_incr injection injection' /\
      ActionTablePrivateMemoryFrame protected_blocks before after /\
      watpa_environment_self_injects injection' entry_environment /\
      watpa_temps_self_inject injection' entry_temporaries /\
      (forall freed_block low high,
        In (freed_block, low, high)
          (Clight.blocks_of_env ge entry_environment) ->
        injection' freed_block = Some (freed_block, 0)).
Proof.
  intros ge protected_blocks function arguments before entry_environment
    entry_temporaries after injection Hentry Hinvariant Harguments.
  destruct (watpa_private_function_entry2_carries
    ge protected_blocks function arguments before entry_environment
    entry_temporaries after injection Hentry Hinvariant Harguments) as
    [entry_injection
      [Hentry_invariant
        [Hentry_incr
          [Hentry_frame [Hentry_environment Hentry_temporaries]]]]].
  exists entry_injection. split; [exact Hentry_invariant |].
  split; [exact Hentry_incr |].
  split; [exact Hentry_frame |].
  split; [exact Hentry_environment |].
  split; [exact Hentry_temporaries |].
  intros freed_block low high Hin.
  exact (watpa_blocks_of_environment_are_self_mapped
    ge entry_injection entry_environment freed_block low high
    Hentry_environment Hin).
Qed.

Print Assumptions watpa_private_alloc_variables_carries_with_environment.
Print Assumptions watpa_private_function_entry2_carries.
Print Assumptions watpa_private_function_entry2_maps_return_frame.
