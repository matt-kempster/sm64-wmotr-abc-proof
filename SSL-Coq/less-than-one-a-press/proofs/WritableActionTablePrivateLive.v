(** Carrying writable-action-table privacy through live memory effects.

    [WritableActionTablePrivateInitialization] constructs the filtered
    self-injection at the genuine selected linked initial memory.  This file
    supplies the compositional carrier used after that point.  It covers the
    primitive effects from which [Clight.step2] memory changes are built:
    ordinary stores, byte-copy stores, local allocation, local freeing, and
    CompCert abstract external calls.  Every constructor either keeps the
    filtered injection or returns an extension of it, and every constructor
    gives a full byte frame for the three action-table blocks.

    The premises on a store address, stored value, copied bytes, external-call
    arguments, or freed local block are deliberately explicit.  They are the
    live value-provenance facts supplied by a state-level step classification;
    if one fails, that exact value is the first concrete private alias rather
    than an unidentified whole-game escape. *)

From Coq Require Import Classical_Prop List Lia ZArith.
From compcert Require Import
  AST Clight Coqlib Events Globalenvs Memory Smallstep Values.
From LessThanOneAPress.Proofs Require Import
  GameTypes SelectedClightTarget
  WritableActionTableAliasExternalClosure
  WritableActionTableWholeGameAliases
  WritableActionTablePrivateInitialization.

Import ListNotations.
Local Open Scope Z_scope.

Record ActionTablePrivateMemoryInvariant
    (ge : Senv.t) (protected_blocks : list block)
    (memory : mem) (injection : meminj) : Prop := {
  watpl_symbols_inject : symbols_inject injection ge ge;
  watpl_memory_inject : Mem.inject injection memory memory;
  watpl_blocks_omitted :
    forall protected_block,
      In protected_block protected_blocks ->
      injection protected_block = None;
  watpl_blocks_valid :
    forall protected_block,
      In protected_block protected_blocks ->
      Mem.valid_block memory protected_block;
  watpl_globals_valid : ActionTableGlobalBlocksValid ge memory
}.

Definition ActionTablePrivateMemoryFrame
    (protected_blocks : list block) (before after : mem) : Prop :=
  Mem.unchanged_on
    (fun candidate_block _ => In candidate_block protected_blocks)
    before after.

Lemma watpl_frame_refl :
  forall protected_blocks memory,
    ActionTablePrivateMemoryFrame protected_blocks memory memory.
Proof.
  intros. apply Mem.unchanged_on_refl.
Qed.

Lemma watpl_frame_trans :
  forall protected_blocks first middle last,
    ActionTablePrivateMemoryFrame protected_blocks first middle ->
    ActionTablePrivateMemoryFrame protected_blocks middle last ->
    ActionTablePrivateMemoryFrame protected_blocks first last.
Proof.
  intros. eapply Mem.unchanged_on_trans; eauto.
Qed.

Theorem selected_source_initial_private_memory_invariant :
  forall version (initial_memory : mem) (protected_blocks : list block),
    Genv.init_mem
      (Ctypes.program_of_program (selected_clight_source version)) =
      Some initial_memory ->
    LinkedSourceActionTableBlocks version protected_blocks ->
    exists injection,
      ActionTablePrivateMemoryInvariant
        (Clight.globalenv (selected_clight_source version))
        protected_blocks initial_memory injection.
Proof.
  intros version initial_memory protected_blocks Hinitial Hblocks.
  pose proof (selected_source_initial_private_external_ready
    version initial_memory protected_blocks Hinitial Hblocks) as Hready.
  destruct Hready as
    [injection [Hsymbols [Hmemory [Harguments Homitted]]]].
  exists injection. constructor.
  - exact Hsymbols.
  - exact Hmemory.
  - exact Homitted.
  - eapply linked_source_action_table_blocks_are_valid_at_initialization;
      eauto.
  - eapply initialized_memory_supplies_action_table_global_block_validity;
      eauto.
Qed.

Lemma watpl_self_injected_pointer_block_is_not_protected :
  forall injection protected_blocks pointer_block pointer_offset,
    Val.inject injection
      (Vptr pointer_block pointer_offset) (Vptr pointer_block pointer_offset) ->
    (forall protected_block,
      In protected_block protected_blocks -> injection protected_block = None) ->
    ~ In pointer_block protected_blocks.
Proof.
  intros injection protected_blocks pointer_block pointer_offset
    Hinjected Homitted Hin.
  inversion Hinjected; subst.
  specialize (Homitted pointer_block Hin). congruence.
Qed.

Lemma watpl_storev_valid_block :
  forall chunk before address value after candidate_block,
    Mem.storev chunk before address value = Some after ->
    Mem.valid_block before candidate_block ->
    Mem.valid_block after candidate_block.
Proof.
  intros chunk before address value after candidate_block Hstore Hvalid.
  destruct address; cbn in Hstore; try discriminate.
  eapply Mem.store_valid_block_1; eauto.
Qed.

Lemma watpl_storebytes_global_validity :
  forall ge before target_block target_offset bytes after,
    ActionTableGlobalBlocksValid ge before ->
    Mem.storebytes before target_block target_offset bytes = Some after ->
    ActionTableGlobalBlocksValid ge after.
Proof.
  intros ge before target_block target_offset bytes after
    [Hsymbols Hvolatile] Hstore.
  split; intros.
  - eapply Mem.storebytes_valid_block_1; eauto.
  - eapply Mem.storebytes_valid_block_1; eauto.
Qed.

Theorem watpl_private_storev_carries :
  forall ge protected_blocks before injection chunk address stored_value after,
    ActionTablePrivateMemoryInvariant
      ge protected_blocks before injection ->
    Val.inject injection address address ->
    Val.inject injection stored_value stored_value ->
    Mem.storev chunk before address stored_value = Some after ->
    ActionTablePrivateMemoryInvariant
      ge protected_blocks after injection /\
    ActionTablePrivateMemoryFrame protected_blocks before after.
Proof.
  intros ge protected_blocks before injection chunk address stored_value after
    Hinvariant Haddress Hvalue Hstore.
  destruct Hinvariant as
    [Hsymbols Hmemory Homitted Hprotected_valid Hglobal_valid].
  assert (Hafter_inject : Mem.inject injection after after).
  { destruct (Mem.storev_mapped_inject injection chunk before address
      stored_value after before address stored_value
      Hmemory Hstore Haddress Hvalue)
      as [target_after [Htarget_store Htarget_inject]].
    rewrite Hstore in Htarget_store. inversion Htarget_store; subst target_after.
    exact Htarget_inject. }
  assert (Haddress_pointer : exists target_block target_offset,
    address = Vptr target_block target_offset).
  { destruct address; cbn in Hstore; try discriminate; eauto. }
  destruct Haddress_pointer as [target_block [target_offset ->]].
  assert (Htarget_private : ~ In target_block protected_blocks).
  { eapply watpl_self_injected_pointer_block_is_not_protected; eauto. }
  split.
  - constructor.
    + exact Hsymbols.
    + exact Hafter_inject.
    + exact Homitted.
    + intros protected_block Hin.
      eapply watpl_storev_valid_block; eauto.
    + destruct Hglobal_valid as [Hglobal_symbols Hglobal_volatile].
      split; intros.
      * eapply watpl_storev_valid_block; eauto.
      * eapply watpl_storev_valid_block; eauto.
  - unfold ActionTablePrivateMemoryFrame, Mem.storev in Hstore.
    eapply Mem.store_unchanged_on; eauto.
Qed.

Theorem watpl_private_storebytes_carries :
  forall ge protected_blocks before injection target_block target_offset
      bytes after,
    ActionTablePrivateMemoryInvariant
      ge protected_blocks before injection ->
    injection target_block = Some (target_block, 0) ->
    list_forall2 (memval_inject injection) bytes bytes ->
    Mem.storebytes before target_block target_offset bytes = Some after ->
    ActionTablePrivateMemoryInvariant
      ge protected_blocks after injection /\
    ActionTablePrivateMemoryFrame protected_blocks before after.
Proof.
  intros ge protected_blocks before injection target_block target_offset
    bytes after Hinvariant Htarget Hbytes Hstore.
  destruct Hinvariant as
    [Hsymbols Hmemory Homitted Hprotected_valid Hglobal_valid].
  assert (Htarget_private : ~ In target_block protected_blocks).
  { intro Hin. specialize (Homitted target_block Hin). congruence. }
  assert (Hafter_inject : Mem.inject injection after after).
  { destruct (Mem.storebytes_mapped_inject injection before target_block
      target_offset bytes after before target_block 0 bytes
      Hmemory Hstore Htarget Hbytes)
      as [target_after [Htarget_store Htarget_inject]].
    rewrite Z.add_0_r in Htarget_store.
    rewrite Hstore in Htarget_store. inversion Htarget_store; subst target_after.
    exact Htarget_inject. }
  split.
  - constructor.
    + exact Hsymbols.
    + exact Hafter_inject.
    + exact Homitted.
    + intros protected_block Hin.
      eapply Mem.storebytes_valid_block_1; eauto.
    + eapply watpl_storebytes_global_validity; eauto.
  - unfold ActionTablePrivateMemoryFrame.
    eapply Mem.storebytes_unchanged_on; eauto.
Qed.

Lemma watpl_alloc_extension_is_separated :
  forall before after new_block injection injection' low high,
    Mem.alloc before low high = (after, new_block) ->
    inject_incr injection injection' ->
    injection' new_block = Some (new_block, 0) ->
    (forall block, block <> new_block -> injection' block = injection block) ->
    inject_separated injection injection' before before.
Proof.
  intros before after new_block injection injection' low high Halloc
    Hincr Hnew Hother.
  red. intros source_block target_block delta Hsource Htarget.
  destruct (eq_block source_block new_block) as [-> | Hdifferent].
  - rewrite Hnew in Htarget. inversion Htarget; subst target_block delta.
    split; eapply Mem.fresh_block_alloc; eauto.
  - rewrite Hother in Htarget by exact Hdifferent. congruence.
Qed.

Theorem watpl_private_alloc_carries :
  forall ge protected_blocks before injection low high after new_block,
    ActionTablePrivateMemoryInvariant
      ge protected_blocks before injection ->
    Mem.alloc before low high = (after, new_block) ->
    exists injection',
      ActionTablePrivateMemoryInvariant
        ge protected_blocks after injection' /\
      inject_incr injection injection' /\
      injection' new_block = Some (new_block, 0) /\
      ActionTablePrivateMemoryFrame protected_blocks before after.
Proof.
  intros ge protected_blocks before injection low high after new_block
    Hinvariant Halloc.
  destruct Hinvariant as
    [Hsymbols Hmemory Homitted Hprotected_valid Hglobal_valid].
  destruct (Mem.alloc_parallel_inject injection before before low high
    after new_block low high Hmemory Halloc (Z.le_refl low) (Z.le_refl high))
    as [injection' [target_after [target_block
      [Htarget_alloc [Hafter_inject [Hincr [Hnew Hother]]]]]]].
  rewrite Halloc in Htarget_alloc. inversion Htarget_alloc.
  subst target_after target_block.
  assert (Hseparated :
    inject_separated injection injection' before before).
  { eapply watpl_alloc_extension_is_separated; eauto. }
  exists injection'.
  split.
  - constructor.
    + eapply symbols_inject_preserved_by_separated_extension; eauto.
    + exact Hafter_inject.
    + intros protected_block Hin.
      assert (Hdifferent : protected_block <> new_block).
      { intro Hequal. subst protected_block.
        exact (Mem.fresh_block_alloc before low high after new_block Halloc
          (Hprotected_valid new_block Hin)). }
      rewrite Hother by exact Hdifferent. now apply Homitted.
    + intros protected_block Hin.
      eapply Mem.valid_block_alloc; eauto.
    + destruct Hglobal_valid as [Hglobal_symbols Hglobal_volatile].
      split; intros.
      * eapply Mem.valid_block_alloc; eauto.
      * eapply Mem.valid_block_alloc; eauto.
  - split; [exact Hincr |].
    split; [exact Hnew |].
    unfold ActionTablePrivateMemoryFrame.
    now apply Mem.alloc_unchanged_on with (lo := low) (hi := high)
      (b := new_block).
Qed.

Theorem watpl_private_free_carries :
  forall ge protected_blocks before injection freed_block low high after,
    ActionTablePrivateMemoryInvariant
      ge protected_blocks before injection ->
    injection freed_block = Some (freed_block, 0) ->
    Mem.free before freed_block low high = Some after ->
    ActionTablePrivateMemoryInvariant
      ge protected_blocks after injection /\
    ActionTablePrivateMemoryFrame protected_blocks before after.
Proof.
  intros ge protected_blocks before injection freed_block low high after
    Hinvariant Hfreed Hfree.
  destruct Hinvariant as
    [Hsymbols Hmemory Homitted Hprotected_valid Hglobal_valid].
  assert (Hfreed_private : ~ In freed_block protected_blocks).
  { intro Hin. specialize (Homitted freed_block Hin). congruence. }
  destruct (Mem.free_parallel_inject injection before before freed_block
    low high after freed_block 0 Hmemory Hfree Hfreed)
    as [target_after [Htarget_free Hafter_inject]].
  rewrite ! Z.add_0_r in Htarget_free.
  rewrite Hfree in Htarget_free. inversion Htarget_free. subst target_after.
  split.
  - constructor.
    + exact Hsymbols.
    + exact Hafter_inject.
    + exact Homitted.
    + intros protected_block Hin.
      eapply Mem.valid_block_free_1; eauto.
    + destruct Hglobal_valid as [Hglobal_symbols Hglobal_volatile].
      split; intros.
      * eapply Mem.valid_block_free_1; eauto.
      * eapply Mem.valid_block_free_1; eauto.
  - unfold ActionTablePrivateMemoryFrame.
    eapply Mem.free_unchanged_on; eauto.
Qed.

Theorem watpl_private_external_call_carries :
  forall ge protected_blocks before injection external arguments trace
      result after,
    ActionTablePrivateMemoryInvariant
      ge protected_blocks before injection ->
    Val.inject_list injection arguments arguments ->
    external_call external ge arguments before trace result after ->
    exists injection',
      ActionTablePrivateMemoryInvariant
        ge protected_blocks after injection' /\
      Val.inject injection' result result /\
      inject_incr injection injection' /\
      ActionTablePrivateMemoryFrame protected_blocks before after.
Proof.
  intros ge protected_blocks before injection external arguments trace
    result after Hinvariant Harguments Hcall.
  destruct Hinvariant as
    [Hsymbols Hmemory Homitted Hprotected_valid Hglobal_valid].
  assert (Hready :
    ActionTablePrivateExternalReady ge arguments before protected_blocks).
  { exists injection. split; [exact Hsymbols |].
    split; [exact Hmemory |].
    split; [exact Harguments | exact Homitted]. }
  destruct (abstract_external_call_carries_explicit_private_injection
    ge arguments before trace result after external protected_blocks
    injection Hsymbols Hmemory Harguments Homitted Hglobal_valid
    Hprotected_valid Hcall)
    as [injection'
      [Hsymbols' [Hresult [Hmemory' [Hincr Homitted']]]]].
  assert (Hframe : ActionTablePrivateMemoryFrame protected_blocks before after).
  { unfold ActionTablePrivateMemoryFrame.
    eapply abstract_external_call_preserves_private_action_table_blocks;
      eauto. }
  exists injection'.
  split.
  - constructor.
    + exact Hsymbols'.
    + exact Hmemory'.
    + exact Homitted'.
    + intros protected_block Hin.
      eapply external_call_valid_block; eauto.
    + destruct Hglobal_valid as [Hglobal_symbols Hglobal_volatile].
      split; intros.
      * eapply external_call_valid_block; eauto.
      * eapply external_call_valid_block; eauto.
  - split; [exact Hresult |].
    split.
    + exact Hincr.
    + exact Hframe.
Qed.

(** A Clight function-entry transition allocates all address-taken locals in
    one semantic step.  Iterate the one-block carrier so the live classifier
    can represent that real transition without pretending it is a single
    [Mem.alloc]. *)
Theorem watpl_private_alloc_variables_carries :
  forall (ge : Clight.genv) protected_blocks environment before variables
      environment' after injection,
    Clight.alloc_variables ge environment before variables
      environment' after ->
    ActionTablePrivateMemoryInvariant
      ge protected_blocks before injection ->
    exists injection',
      ActionTablePrivateMemoryInvariant
        ge protected_blocks after injection' /\
      inject_incr injection injection' /\
      ActionTablePrivateMemoryFrame protected_blocks before after.
Proof.
  intros ge protected_blocks environment before variables environment' after
    injection Halloc.
  revert injection.
  induction Halloc as
    [environment memory |
     environment memory identifier variable_type variables middle new_block
       after environment' Hone Hrest IH]; intros injection Hinvariant.
  - exists injection. split; [exact Hinvariant |].
    split; [apply inject_incr_refl | apply watpl_frame_refl].
  - destruct (watpl_private_alloc_carries
      ge protected_blocks memory injection 0 (Ctypes.sizeof ge variable_type)
      middle new_block Hinvariant Hone) as
      [middle_injection
        [Hmiddle [Hincr_middle [Hnew Hframe_middle]]]].
    destruct (IH middle_injection Hmiddle) as
      [after_injection [Hafter [Hincr_after Hframe_after]]].
    exists after_injection. split; [exact Hafter |].
    split.
    + eapply inject_incr_trans; eauto.
    + eapply watpl_frame_trans; eauto.
Qed.

(** Return steps similarly free every local block in one [Mem.free_list].
    Requiring each listed block to be self-mapped is the exact no-private-alias
    premise; the carried invariant then proves no listed block is a table. *)
Theorem watpl_private_free_list_carries :
  forall ge protected_blocks before freed_ranges after injection,
    ActionTablePrivateMemoryInvariant
      ge protected_blocks before injection ->
    (forall freed_block low high,
      In (freed_block, low, high) freed_ranges ->
      injection freed_block = Some (freed_block, 0)) ->
    Mem.free_list before freed_ranges = Some after ->
    ActionTablePrivateMemoryInvariant
      ge protected_blocks after injection /\
    ActionTablePrivateMemoryFrame protected_blocks before after.
Proof.
  intros ge protected_blocks before freed_ranges.
  revert before.
  induction freed_ranges as
    [| [[freed_block low] high] rest IH];
    intros before after injection Hinvariant Hmapped Hfree.
  - cbn in Hfree. inversion Hfree; subst after.
    split; [exact Hinvariant | apply watpl_frame_refl].
  - cbn in Hfree.
    destruct (Mem.free before freed_block low high) as [middle |]
      eqn:Hfree_one; [| discriminate].
    assert (Hhead_mapped :
      injection freed_block = Some (freed_block, 0)).
    { apply Hmapped with (low := low) (high := high). now left. }
    destruct (watpl_private_free_carries
      ge protected_blocks before injection freed_block low high middle
      Hinvariant Hhead_mapped Hfree_one) as [Hmiddle Hframe_middle].
    destruct (IH middle after injection Hmiddle
      (fun rest_block rest_low rest_high Hin =>
        Hmapped rest_block rest_low rest_high (or_intror Hin)) Hfree)
      as [Hafter Hframe_after].
    split; [exact Hafter |].
    eapply watpl_frame_trans; eauto.
Qed.

(** A primitive live effect is certified relative to the injection currently
    carried by the run.  The theorem below constructs the next injection. *)
Inductive ActionTablePrivatePrimitiveEffect
    (ge : Clight.genv) (protected_blocks : list block)
    (injection : meminj) : mem -> mem -> Prop :=
| watpl_effect_same :
    forall memory,
      ActionTablePrivatePrimitiveEffect ge protected_blocks injection
        memory memory
| watpl_effect_storev :
    forall chunk address stored_value before after,
      Val.inject injection address address ->
      Val.inject injection stored_value stored_value ->
      Mem.storev chunk before address stored_value = Some after ->
      ActionTablePrivatePrimitiveEffect ge protected_blocks injection
        before after
| watpl_effect_storebytes :
    forall target_block target_offset bytes before after,
      injection target_block = Some (target_block, 0) ->
      list_forall2 (memval_inject injection) bytes bytes ->
      Mem.storebytes before target_block target_offset bytes = Some after ->
      ActionTablePrivatePrimitiveEffect ge protected_blocks injection
        before after
| watpl_effect_alloc :
    forall low high before after new_block,
      Mem.alloc before low high = (after, new_block) ->
      ActionTablePrivatePrimitiveEffect ge protected_blocks injection
        before after
| watpl_effect_alloc_variables :
    forall environment variables environment' before after,
      Clight.alloc_variables ge environment before variables
        environment' after ->
      ActionTablePrivatePrimitiveEffect ge protected_blocks injection
        before after
| watpl_effect_free :
    forall freed_block low high before after,
      injection freed_block = Some (freed_block, 0) ->
      Mem.free before freed_block low high = Some after ->
      ActionTablePrivatePrimitiveEffect ge protected_blocks injection
        before after
| watpl_effect_free_list :
    forall freed_ranges before after,
      (forall freed_block low high,
        In (freed_block, low, high) freed_ranges ->
        injection freed_block = Some (freed_block, 0)) ->
      Mem.free_list before freed_ranges = Some after ->
      ActionTablePrivatePrimitiveEffect ge protected_blocks injection
        before after
| watpl_effect_external :
    forall external arguments trace result before after,
      Val.inject_list injection arguments arguments ->
      external_call external ge arguments before trace result after ->
      ActionTablePrivatePrimitiveEffect ge protected_blocks injection
        before after.

Theorem watpl_private_primitive_effect_carries :
  forall (ge : Clight.genv) protected_blocks injection before after,
    ActionTablePrivateMemoryInvariant
      ge protected_blocks before injection ->
    ActionTablePrivatePrimitiveEffect
      ge protected_blocks injection before after ->
    exists injection',
      ActionTablePrivateMemoryInvariant
        ge protected_blocks after injection' /\
      inject_incr injection injection' /\
      ActionTablePrivateMemoryFrame protected_blocks before after.
Proof.
  intros ge protected_blocks injection before after Hinvariant Heffect.
  inversion Heffect; subst.
  - exists injection. split; [exact Hinvariant |].
    split; [apply inject_incr_refl | apply watpl_frame_refl].
  - destruct (watpl_private_storev_carries _ _ _ _ _ _ _ _
      Hinvariant H H0 H1) as [Hnext Hframe].
    exists injection. split; [exact Hnext |].
    split; [apply inject_incr_refl | exact Hframe].
  - destruct (watpl_private_storebytes_carries _ _ _ _ _ _ _ _
      Hinvariant H H0 H1) as [Hnext Hframe].
    exists injection. split; [exact Hnext |].
    split; [apply inject_incr_refl | exact Hframe].
  - destruct (watpl_private_alloc_carries
      ge protected_blocks before injection low high after new_block
      Hinvariant H) as
      [injection' [Hnext [Hincr [Hnew Hframe]]]].
    exists injection'. auto.
  - eapply watpl_private_alloc_variables_carries; eauto.
  - destruct (watpl_private_free_carries _ _ _ _ _ _ _ _
      Hinvariant H H0) as [Hnext Hframe].
    exists injection. split; [exact Hnext |].
    split; [apply inject_incr_refl | exact Hframe].
  - destruct (watpl_private_free_list_carries _ _ _ _ _ _
      Hinvariant H H0) as [Hnext Hframe].
    exists injection. split; [exact Hnext |].
    split; [apply inject_incr_refl | exact Hframe].
  - destruct (watpl_private_external_call_carries _ _ _ _ _ _ _ _ _
      Hinvariant H H0) as
      [injection' [Hnext [Hresult [Hincr Hframe]]]].
    exists injection'. auto.
Qed.

(** * Actual Clight executions *)

Definition watpl_clight_state_memory (state : Clight.state) : mem :=
  match state with
  | Clight.State _ _ _ _ _ memory => memory
  | Clight.Callstate _ _ _ memory => memory
  | Clight.Returnstate _ _ memory => memory
  end.

Lemma watpl_same_memory_clight_step_is_classified :
  forall (ge : Clight.genv) protected_blocks injection
      (before : Clight.state) trace (after : Clight.state),
    Clight.step2 ge before trace after ->
    watpl_clight_state_memory after = watpl_clight_state_memory before ->
    ActionTablePrivatePrimitiveEffect ge protected_blocks injection
      (watpl_clight_state_memory before)
      (watpl_clight_state_memory after).
Proof.
  intros ge protected_blocks injection before trace after Hstep Hmemory.
  rewrite Hmemory. constructor.
Qed.

Theorem watpl_internal_function_entry_step_is_classified :
  forall (ge : Clight.genv) protected_blocks injection
      (function : Clight.function) (arguments : list val)
      (continuation : Clight.cont) (before : mem) (trace : Events.trace)
      (after : Clight.state),
    Clight.step2 ge
      (Clight.Callstate (Ctypes.Internal function) arguments continuation before)
      trace after ->
    ActionTablePrivatePrimitiveEffect ge protected_blocks injection before
      (watpl_clight_state_memory after).
Proof.
  intros ge protected_blocks injection function arguments continuation before
    trace after Hstep.
  inversion Hstep; subst.
  match goal with
  | Hentry : Clight.function_entry2 _ _ _ _ _ _ _ |- _ =>
      inversion Hentry; subst;
      eapply watpl_effect_alloc_variables; eauto
  end.
Qed.

Theorem watpl_external_function_step_is_classified :
  forall (ge : Clight.genv) protected_blocks injection
      (external : external_function) (argument_types : list Ctypes.type)
      (result_type : Ctypes.type)
      (calling_convention : AST.calling_convention)
      (arguments : list val) (continuation : Clight.cont) (before : mem)
      (trace : Events.trace) (after : Clight.state),
    Val.inject_list injection arguments arguments ->
    Clight.step2 ge
      (Clight.Callstate
        (Ctypes.External external argument_types result_type calling_convention)
        arguments continuation before)
      trace after ->
    ActionTablePrivatePrimitiveEffect ge protected_blocks injection before
      (watpl_clight_state_memory after).
Proof.
  intros ge protected_blocks injection external argument_types result_type
    calling_convention arguments continuation before trace after Harguments
    Hstep.
  inversion Hstep; subst.
  eapply watpl_effect_external; eauto.
Qed.

Theorem watpl_return_statement_step_is_classified :
  forall (ge : Clight.genv) protected_blocks injection
      (function : Clight.function) (result_expression : option Clight.expr)
      (continuation : Clight.cont) (environment : Clight.env)
      (temporaries : Clight.temp_env) (before : mem) (trace : Events.trace)
      (after : Clight.state),
    (forall freed_block low high,
      In (freed_block, low, high) (Clight.blocks_of_env ge environment) ->
      injection freed_block = Some (freed_block, 0)) ->
    Clight.step2 ge
      (Clight.State function (Clight.Sreturn result_expression) continuation
        environment temporaries before)
      trace after ->
    ActionTablePrivatePrimitiveEffect ge protected_blocks injection before
      (watpl_clight_state_memory after).
Proof.
  intros ge protected_blocks injection function result_expression continuation
    environment temporaries before trace after Hmapped Hstep.
  inversion Hstep; subst.
  all: try (eapply watpl_effect_free_list; eauto).
  all: match goal with
  | Hcases : _ \/ _ |- _ => destruct Hcases; discriminate
  end.
Qed.

(** A step classifier does not replace execution: it consumes an actual
    [Clight.step2] derivation.  Its sole job is to expose which primitive
    memory effect that derivation performed, together with the value-injection
    facts needed by the carrier above. *)
Definition ActionTablePrivateClightStepCoverage
    (ge : Clight.genv) (protected_blocks : list block) : Prop :=
  forall injection before trace after,
    ActionTablePrivateMemoryInvariant ge protected_blocks
      (watpl_clight_state_memory before) injection ->
    Clight.step2 ge before trace after ->
    ActionTablePrivatePrimitiveEffect ge protected_blocks injection
      (watpl_clight_state_memory before)
      (watpl_clight_state_memory after).

Theorem watpl_classified_clight_step_carries :
  forall (ge : Clight.genv) protected_blocks injection
      (before : Clight.state) (trace : Events.trace) (after : Clight.state),
    ActionTablePrivateMemoryInvariant ge protected_blocks
      (watpl_clight_state_memory before) injection ->
    Clight.step2 ge before trace after ->
    ActionTablePrivatePrimitiveEffect ge protected_blocks injection
      (watpl_clight_state_memory before)
      (watpl_clight_state_memory after) ->
    exists injection',
      ActionTablePrivateMemoryInvariant ge protected_blocks
        (watpl_clight_state_memory after) injection' /\
      inject_incr injection injection' /\
      ActionTablePrivateMemoryFrame protected_blocks
        (watpl_clight_state_memory before)
        (watpl_clight_state_memory after).
Proof.
  intros ge protected_blocks injection before trace after Hinvariant Hstep
    Heffect.
  eapply watpl_private_primitive_effect_carries; eauto.
Qed.

(** This theorem makes failure diagnostic.  Once the invariant holds before
    a real step, either the classifier supplies a carried invariant and an
    exact table frame, or that very [before, trace, after] transition is the
    first unresolved alias/effect obligation. *)
Theorem watpl_clight_step_carries_or_exposes_unclassified_effect :
  forall (ge : Clight.genv) protected_blocks injection
      (before : Clight.state) (trace : Events.trace) (after : Clight.state),
    ActionTablePrivateMemoryInvariant ge protected_blocks
      (watpl_clight_state_memory before) injection ->
    Clight.step2 ge before trace after ->
    (exists injection',
      ActionTablePrivateMemoryInvariant ge protected_blocks
        (watpl_clight_state_memory after) injection' /\
      inject_incr injection injection' /\
      ActionTablePrivateMemoryFrame protected_blocks
        (watpl_clight_state_memory before)
        (watpl_clight_state_memory after)) \/
    ~ ActionTablePrivatePrimitiveEffect ge protected_blocks injection
        (watpl_clight_state_memory before)
        (watpl_clight_state_memory after).
Proof.
  intros ge protected_blocks injection before trace after Hinvariant Hstep.
  destruct (classic
    (ActionTablePrivatePrimitiveEffect ge protected_blocks injection
      (watpl_clight_state_memory before)
      (watpl_clight_state_memory after))) as [Heffect | Heffect].
  - left. eapply watpl_classified_clight_step_carries; eauto.
  - now right.
Qed.

(** A single coverage proof now carries the concrete injection through every
    finite Clight execution, including the actual indirect and external calls
    chosen by that execution.  The returned injection is an extension of the
    initial one, and the byte frame composes over the entire run. *)
Theorem watpl_clight_star_carries_private_injection :
  forall (ge : Clight.genv) protected_blocks
      (first : Clight.state) (trace : Events.trace) (last : Clight.state)
      injection,
    ActionTablePrivateClightStepCoverage ge protected_blocks ->
    ActionTablePrivateMemoryInvariant ge protected_blocks
      (watpl_clight_state_memory first) injection ->
    @Smallstep.star _ _ Clight.step2 ge first trace last ->
    exists injection',
      ActionTablePrivateMemoryInvariant ge protected_blocks
        (watpl_clight_state_memory last) injection' /\
      inject_incr injection injection' /\
      ActionTablePrivateMemoryFrame protected_blocks
        (watpl_clight_state_memory first)
        (watpl_clight_state_memory last).
Proof.
  intros ge protected_blocks first trace last injection Hcoverage
    Hinvariant Hstar.
  revert injection Hinvariant.
  induction Hstar as
    [state | first first_trace middle rest_trace last whole_trace
      Hstep Hstar IH Htrace]; intros injection Hinvariant.
  - exists injection. split; [exact Hinvariant |].
    split; [apply inject_incr_refl | apply watpl_frame_refl].
  - pose proof (Hcoverage injection first first_trace middle
      Hinvariant Hstep) as Heffect.
    destruct (watpl_private_primitive_effect_carries
      ge protected_blocks injection
      (watpl_clight_state_memory first)
      (watpl_clight_state_memory middle) Hinvariant Heffect)
      as [middle_injection
        [Hmiddle [Hincr_middle Hframe_middle]]].
    destruct (IH middle_injection Hmiddle) as
      [last_injection [Hlast [Hincr_last Hframe_last]]].
    exists last_injection. split; [exact Hlast |].
    split.
    + eapply inject_incr_trans; eauto.
    + eapply watpl_frame_trans; eauto.
Qed.

(** The selected-program bridge keeps initialization and execution in one
    theorem.  The start state must contain the exact successful initialized
    memory; no endpoint from a different run can be substituted. *)
Theorem selected_source_private_injection_carries_through_clight_run :
  forall version (initial_memory : mem) (protected_blocks : list block)
      (first : Clight.state) (trace : Events.trace) (last : Clight.state),
    Genv.init_mem
      (Ctypes.program_of_program (selected_clight_source version)) =
      Some initial_memory ->
    LinkedSourceActionTableBlocks version protected_blocks ->
    watpl_clight_state_memory first = initial_memory ->
    ActionTablePrivateClightStepCoverage
      (Clight.globalenv (selected_clight_source version)) protected_blocks ->
    @Smallstep.star _ _ Clight.step2
      (Clight.globalenv (selected_clight_source version))
      first trace last ->
    exists initial_injection final_injection,
      ActionTablePrivateMemoryInvariant
        (Clight.globalenv (selected_clight_source version))
        protected_blocks initial_memory initial_injection /\
      ActionTablePrivateMemoryInvariant
        (Clight.globalenv (selected_clight_source version))
        protected_blocks (watpl_clight_state_memory last) final_injection /\
      inject_incr initial_injection final_injection /\
      ActionTablePrivateMemoryFrame protected_blocks initial_memory
        (watpl_clight_state_memory last).
Proof.
  intros version initial_memory protected_blocks first trace last Hinitial
    Hblocks Hfirst Hcoverage Hrun.
  destruct (selected_source_initial_private_memory_invariant
    version initial_memory protected_blocks Hinitial Hblocks)
    as [initial_injection Hprivate].
  assert (Hfirst_private :
    ActionTablePrivateMemoryInvariant
      (Clight.globalenv (selected_clight_source version)) protected_blocks
      (watpl_clight_state_memory first) initial_injection).
  { now rewrite Hfirst. }
  destruct (watpl_clight_star_carries_private_injection
    (Clight.globalenv (selected_clight_source version)) protected_blocks
    first trace last initial_injection Hcoverage Hfirst_private Hrun)
    as [final_injection [Hfinal [Hincr Hframe]]].
  rewrite Hfirst in Hframe.
  exists initial_injection, final_injection.
  split; [exact Hprivate |].
  split; [exact Hfinal |].
  split; [exact Hincr | exact Hframe].
Qed.

(** Finite live executions carry a possibly growing injection explicitly.
    Each link contains an actual primitive memory effect, not a bare assertion
    that the endpoint is safe. *)
Inductive ActionTablePrivateLiveMemoryRun
    (ge : Clight.genv) (protected_blocks : list block) :
    mem -> meminj -> mem -> Prop :=
| watpl_live_run_refl :
    forall memory injection,
      ActionTablePrivateMemoryInvariant
        ge protected_blocks memory injection ->
      ActionTablePrivateLiveMemoryRun
        ge protected_blocks memory injection memory
| watpl_live_run_step :
    forall first injection middle injection' last,
      ActionTablePrivateMemoryInvariant
        ge protected_blocks first injection ->
      ActionTablePrivatePrimitiveEffect
        ge protected_blocks injection first middle ->
      ActionTablePrivateMemoryInvariant
        ge protected_blocks middle injection' ->
      inject_incr injection injection' ->
      ActionTablePrivateLiveMemoryRun
        ge protected_blocks middle injection' last ->
      ActionTablePrivateLiveMemoryRun
        ge protected_blocks first injection last.

Theorem watpl_live_run_preserves_every_table_byte :
  forall (ge : Clight.genv) protected_blocks first injection last,
    ActionTablePrivateLiveMemoryRun
      ge protected_blocks first injection last ->
    ActionTablePrivateMemoryFrame protected_blocks first last.
Proof.
  intros ge protected_blocks first injection last Hrun.
  induction Hrun.
  - apply watpl_frame_refl.
  - eapply watpl_frame_trans.
    + destruct (watpl_private_primitive_effect_carries
        ge protected_blocks injection first middle H H0)
        as [carried [Hcarried [Hincr_carried Hframe]]].
      exact Hframe.
    + exact IHHrun.
Qed.

(** This dichotomy is the exact live-state audit boundary.  For a nonempty
    finite memory timeline, either every adjacent pair has a certified carried
    effect under some current injection, or the result returns the first pair
    for which no such effect exists. *)
Definition ActionTablePrivateAdjacentCertified
    (ge : Clight.genv) (protected_blocks : list block)
    (before after : mem) : Prop :=
  exists injection,
    ActionTablePrivateMemoryInvariant
      ge protected_blocks before injection /\
    ActionTablePrivatePrimitiveEffect
      ge protected_blocks injection before after.

Theorem watpl_finite_live_timeline_is_certified_or_exposes_first_alias :
  forall (ge : Clight.genv) protected_blocks memories,
    memories <> [] ->
    (watwg_all_adjacent
       (ActionTablePrivateAdjacentCertified ge protected_blocks) memories \/
     exists prefix before after suffix,
       memories = prefix ++ before :: after :: suffix /\
       watwg_all_adjacent
         (ActionTablePrivateAdjacentCertified ge protected_blocks)
         (prefix ++ [before]) /\
       ~ ActionTablePrivateAdjacentCertified
           ge protected_blocks before after).
Proof.
  intros ge protected_blocks memories Hnonempty.
  induction memories as [| first rest IH].
  - contradiction.
  - destruct rest as [| second tail].
    + left. constructor.
    + destruct (classic
        (ActionTablePrivateAdjacentCertified
          ge protected_blocks first second)) as [Hstep | Hstep].
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
        split; [reflexivity |]. split; [constructor | exact Hstep].
Qed.

Definition WritableActionTablePrivateLiveClosure : Prop :=
  (forall version (initial_memory : mem) (protected_blocks : list block),
    Genv.init_mem
      (Ctypes.program_of_program (selected_clight_source version)) =
      Some initial_memory ->
    LinkedSourceActionTableBlocks version protected_blocks ->
    exists injection,
      ActionTablePrivateMemoryInvariant
        (Clight.globalenv (selected_clight_source version))
        protected_blocks initial_memory injection) /\
  (forall (ge : Clight.genv) protected_blocks injection before after,
    ActionTablePrivateMemoryInvariant
      ge protected_blocks before injection ->
    ActionTablePrivatePrimitiveEffect
      ge protected_blocks injection before after ->
    exists injection',
      ActionTablePrivateMemoryInvariant
        ge protected_blocks after injection' /\
      inject_incr injection injection' /\
      ActionTablePrivateMemoryFrame protected_blocks before after) /\
  (forall (ge : Clight.genv) protected_blocks first injection last,
    ActionTablePrivateLiveMemoryRun
      ge protected_blocks first injection last ->
    ActionTablePrivateMemoryFrame protected_blocks first last).

Theorem writable_action_table_private_live_closure_holds :
  WritableActionTablePrivateLiveClosure.
Proof.
  unfold WritableActionTablePrivateLiveClosure.
  split.
  - exact selected_source_initial_private_memory_invariant.
  - split.
    + exact watpl_private_primitive_effect_carries.
    + exact watpl_live_run_preserves_every_table_byte.
Qed.

Definition WritableActionTableSelectedLiveBridgeClosure : Prop :=
  forall version (initial_memory : mem) (protected_blocks : list block)
      (first : Clight.state) (trace : Events.trace) (last : Clight.state),
    Genv.init_mem
      (Ctypes.program_of_program (selected_clight_source version)) =
      Some initial_memory ->
    LinkedSourceActionTableBlocks version protected_blocks ->
    watpl_clight_state_memory first = initial_memory ->
    ActionTablePrivateClightStepCoverage
      (Clight.globalenv (selected_clight_source version)) protected_blocks ->
    @Smallstep.star _ _ Clight.step2
      (Clight.globalenv (selected_clight_source version))
      first trace last ->
    exists initial_injection final_injection,
      ActionTablePrivateMemoryInvariant
        (Clight.globalenv (selected_clight_source version))
        protected_blocks initial_memory initial_injection /\
      ActionTablePrivateMemoryInvariant
        (Clight.globalenv (selected_clight_source version))
        protected_blocks (watpl_clight_state_memory last) final_injection /\
      inject_incr initial_injection final_injection /\
      ActionTablePrivateMemoryFrame protected_blocks initial_memory
        (watpl_clight_state_memory last).

Theorem writable_action_table_selected_live_bridge_closure_holds :
  WritableActionTableSelectedLiveBridgeClosure.
Proof.
  exact selected_source_private_injection_carries_through_clight_run.
Qed.
