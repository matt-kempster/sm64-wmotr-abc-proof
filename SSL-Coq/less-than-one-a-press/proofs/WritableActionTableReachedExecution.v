(** Capstone for reached Clight action-table privacy.

    The state-level proof is intentionally split in two.  The one-step
    theorem classifies the semantic cases (assignments, byte copies, the
    selected program's direct-builtin case, and the four legitimate terminal
    table reads).  This file supplies the part that must not be hidden in that
    case analysis: a genuine selected-program start, one common invariant for
    every reached state, and induction over an arbitrary finite [star].

    In particular, [ActionTablePrivateClightStepCoverage] is not the old
    memory-only statement over fabricated Clight states.  Its premise carries
    selected-function/control provenance, self-injection of every live value,
    the exact initialized private injection, and the cumulative protected-byte
    frame.  [WritableActionTableClightStepCoverage] proves the selected one-step
    classification; the capstone below turns that local theorem into the
    requested reached-step and reached-run results. *)

From Coq Require Import List ZArith.
From compcert Require Import
  AST Clight Ctypes Events Globalenvs Memory Smallstep Values.
From LessThanOneAPress.Proofs Require Import
  CleanedClightPrograms GameTypes SelectedClightTarget
  WritableActionTablePrivateLive
  WritableActionTablePrivateInitialization
  WritableActionTableSyntaxBase WritableActionTableSyntaxCoverage
  WritableActionTableWholeGameAliases
  WritableActionTableReachedControl
  WritableActionTableClightStepCoverage.

Import ListNotations.
Local Open Scope Z_scope.

(** * The selected source and its checked function bodies *)

Definition watcap_selected_ge (version : GameVersion) : Clight.genv :=
  Clight.globalenv (selected_clight_source version).

Definition watcap_selected_protected_identifiers
    (version : GameVersion) : list ident :=
  match version with
  | VersionUS => watsc_us_table_ids
  | VersionJP => watsc_jp_table_ids
  end.

Definition watcap_selected_initial_injection
    (version : GameVersion) : meminj :=
  watpi_private_initial_injection
    (selected_clight_source version)
    (watcap_selected_protected_identifiers version).

(** Structural membership in the selected whole linked program is the
    function-provenance predicate used in live states and saved call frames.
    Unlike equality with a generated standalone-unit body, this admits exactly
    the bodies resolved by the selected global environment. *)
Definition watcap_us_function_is_controlled
    (body : Clight.function) : Prop :=
  exists function_identifier,
    In (function_identifier, Gfun (Internal body))
      (prog_defs us_official_cleaned_slice).

Definition watcap_jp_function_is_controlled
    (body : Clight.function) : Prop :=
  exists function_identifier,
    In (function_identifier, Gfun (Internal body))
      (prog_defs jp_official_cleaned_slice).

Definition watcap_selected_function_is_controlled
    (version : GameVersion) (body : Clight.function) : Prop :=
  exists function_identifier,
    In (function_identifier, Gfun (Internal body))
      (prog_defs (selected_clight_source version)).

Lemma watcap_selected_reached_internal_is_controlled :
  forall version body,
    watc_internal_function_is_reached (watcap_selected_ge version) body ->
    watcap_selected_function_is_controlled version body.
Proof.
  intros version body [function_block Hfunction].
  unfold watcap_selected_ge in Hfunction.
  now apply Genv.find_funct_ptr_inversion in Hfunction.
Qed.

(** The sharded 38-unit receipts cover every internal definition in either
    selected source.  Consequently the generic control-provenance machinery
    may follow sequences, loops, switches and gotos without introducing an
    unchecked statement. *)
Lemma watcap_us_control_certificate :
  watc_function_control_certificate
    watsc_us_table_ids watcap_us_function_is_controlled.
Proof.
  apply watc_body_checker_builds_control_certificate.
  intros body [function_identifier Hbody] protected_identifier Hprotected.
  exact (us_selected_source_internal_bodies_action_table_safe
    function_identifier body protected_identifier Hbody Hprotected).
Qed.

Lemma watcap_jp_control_certificate :
  watc_function_control_certificate
    watsc_jp_table_ids watcap_jp_function_is_controlled.
Proof.
  apply watc_body_checker_builds_control_certificate.
  intros body [function_identifier Hbody] protected_identifier Hprotected.
  exact (jp_selected_source_internal_bodies_action_table_safe
    function_identifier body protected_identifier Hbody Hprotected).
Qed.

Definition watcap_selected_control_certificate (version : GameVersion) :
  watc_function_control_certificate
    (watcap_selected_protected_identifiers version)
    (watcap_selected_function_is_controlled version) :=
  match version with
  | VersionUS => watcap_us_control_certificate
  | VersionJP => watcap_jp_control_certificate
  end.

(** * One common invariant from task entry onward *)

(** Keep the concrete filtered injection visible.  An existentially chosen
    self-injection is insufficient for a terminal table read: because the
    table blocks are deliberately omitted, current [Mem.inject] alone places
    no constraint on their bytes.  The selected initialized memory and this
    exact injection are the anchors used by the cumulative frame. *)
Theorem watcap_selected_initial_memory_has_exact_private_invariant :
  forall version initial_memory protected_blocks,
    Genv.init_mem (selected_clight_source version) = Some initial_memory ->
    LinkedSourceActionTableBlocks version protected_blocks ->
    ActionTablePrivateMemoryInvariant
      (watcap_selected_ge version) protected_blocks initial_memory
      (watcap_selected_initial_injection version).
Proof.
  intros version initial_memory protected_blocks Hinitial Hblocks.
  destruct (watpi_selected_initialization_facts version)
    as [Hinitializers Hidentifiers_private].
  constructor.
  - unfold watcap_selected_ge, watcap_selected_initial_injection,
      watcap_selected_protected_identifiers.
    now apply watpi_private_initial_injection_symbols.
  - unfold watcap_selected_initial_injection,
      watcap_selected_protected_identifiers.
    now apply watpi_private_initial_memory_injects.
  - intros protected_block Hin.
    unfold watcap_selected_initial_injection,
      watcap_selected_protected_identifiers.
    exact (watpi_forall2_resolved_block_is_omitted
      (selected_clight_source version)
      (watwg_linked_source_table_ids version) protected_blocks
      (linked_source_action_table_blocks_resolve
        version protected_blocks Hblocks)
      protected_block Hin).
  - eapply linked_source_action_table_blocks_are_valid_at_initialization;
      eauto.
  - unfold watcap_selected_ge.
    now eapply initialized_memory_supplies_action_table_global_block_validity.
Qed.

Record ActionTablePrivateReachedStateInvariant
    (version : GameVersion) (protected_blocks : list block)
    (initial_memory : mem) (initial_injection current_injection : meminj)
    (state : Clight.state) : Prop := {
  watcap_initial_memory_is_selected_initial_memory :
    Genv.init_mem (selected_clight_source version) = Some initial_memory;
  watcap_initial_injection_is_exact :
    initial_injection = watcap_selected_initial_injection version;
  watcap_initial_memory_private :
    ActionTablePrivateMemoryInvariant
      (watcap_selected_ge version) protected_blocks
      initial_memory initial_injection;
  watcap_current_memory_private :
    ActionTablePrivateMemoryInvariant
      (watcap_selected_ge version) protected_blocks
      (watpl_clight_state_memory state) current_injection;
  watcap_injection_extends_initial :
    inject_incr initial_injection current_injection;
  watcap_initial_to_current_table_frame :
    ActionTablePrivateMemoryFrame protected_blocks initial_memory
      (watpl_clight_state_memory state);
  watcap_current_state_reached_and_private :
    watc_reached_state_is_private
      (watcap_selected_ge version)
      (watcap_selected_protected_identifiers version)
      (watcap_selected_function_is_controlled version)
      current_injection state
}.

(** The accepted boundary is [SelectedRuntimeTaskStart], not an arbitrary
    memory packaged with a separately chosen entry function.  The start
    witness supplies one initialized memory, the resolved selected internal
    function, the null argument and [Kstop] in the same state. *)
Theorem watcap_selected_runtime_task_start_establishes_invariant :
  forall version protected_blocks start,
    LinkedSourceActionTableBlocks version protected_blocks ->
    SelectedRuntimeTaskStart version (selected_clight_source version) start ->
    exists initial_memory initial_injection,
      ActionTablePrivateReachedStateInvariant
        version protected_blocks initial_memory initial_injection
        initial_injection start.
Proof.
  intros version protected_blocks start Hblocks Hstart.
  destruct Hstart as
    [initial_memory [entry_block [entry_function
      [Hinitial [Hsymbol [Hfunction [Hstate Hfirst_step]]]]]]].
  subst start.
  pose proof (watcap_selected_initial_memory_has_exact_private_invariant
    version initial_memory protected_blocks Hinitial Hblocks) as Hprivate.
  exists initial_memory, (watcap_selected_initial_injection version).
  constructor.
  - exact Hinitial.
  - reflexivity.
  - exact Hprivate.
  - exact Hprivate.
  - apply inject_incr_refl.
  - apply watpl_frame_refl.
  - apply watc_reached_call_state.
    + cbn. eapply watcap_selected_reached_internal_is_controlled.
      exists entry_block. exact Hfunction.
    + exists entry_block. exact Hfunction.
    + repeat constructor.
    + constructor.
Qed.

(** * The interface supplied by the semantic one-step proof *)

(** This is the deliberately narrow signature expected from
    [WritableActionTableClightStepCoverage].  It begins with the full reached
    invariant--in
    particular the selected initialized memory, exact filtered injection and
    cumulative table frame needed by terminal reads--classifies the actual
    step by a primitive effect, and returns all facts newly created by the
    step.  The capstone composes those facts below. *)
Definition ActionTablePrivateReachedStepClassification
    (version : GameVersion) (protected_blocks : list block) : Prop :=
  forall initial_memory initial_injection current_injection
      before step_trace after,
    ActionTablePrivateReachedStateInvariant
      version protected_blocks initial_memory initial_injection
      current_injection before ->
    Clight.step2 (watcap_selected_ge version) before step_trace after ->
    exists next_injection,
      ActionTablePrivatePrimitiveEffect
        (watcap_selected_ge version) protected_blocks current_injection
        (watpl_clight_state_memory before)
        (watpl_clight_state_memory after) /\
      ActionTablePrivateMemoryInvariant
        (watcap_selected_ge version) protected_blocks
        (watpl_clight_state_memory after) next_injection /\
      inject_incr current_injection next_injection /\
      ActionTablePrivateMemoryFrame protected_blocks
        (watpl_clight_state_memory before)
        (watpl_clight_state_memory after) /\
      watc_reached_state_is_private
        (watcap_selected_ge version)
        (watcap_selected_protected_identifiers version)
        (watcap_selected_function_is_controlled version)
        next_injection after.

(** This is the requested reached-step coverage statement.  Besides the
    primitive-effect witness, its conclusion carries the complete common
    invariant, including the composed start-to-current frame. *)
Definition ActionTablePrivateClightStepCoverage
    (version : GameVersion) (protected_blocks : list block) : Prop :=
  forall initial_memory initial_injection current_injection
      before step_trace after,
    ActionTablePrivateReachedStateInvariant
      version protected_blocks initial_memory initial_injection
      current_injection before ->
    Clight.step2 (watcap_selected_ge version) before step_trace after ->
    exists next_injection,
      ActionTablePrivatePrimitiveEffect
        (watcap_selected_ge version) protected_blocks current_injection
        (watpl_clight_state_memory before)
        (watpl_clight_state_memory after) /\
      inject_incr current_injection next_injection /\
      ActionTablePrivateMemoryFrame protected_blocks
        (watpl_clight_state_memory before)
        (watpl_clight_state_memory after) /\
      ActionTablePrivateReachedStateInvariant
        version protected_blocks initial_memory initial_injection
        next_injection after.

Theorem watcap_step_classification_closes_step_coverage :
  forall version protected_blocks,
    ActionTablePrivateReachedStepClassification version protected_blocks ->
    ActionTablePrivateClightStepCoverage version protected_blocks.
Proof.
  intros version protected_blocks Hclassification
    initial_memory initial_injection current_injection
    before step_trace after Hinvariant Hstep.
  destruct (Hclassification initial_memory initial_injection
    current_injection before step_trace after Hinvariant Hstep) as
    [next_injection
      [Heffect [Hnext [Hstep_incr [Hstep_frame Hnext_reached]]]]].
  destruct Hinvariant as
    [Hselected_initial Hexact Hinitial Hcurrent Hinitial_incr
      Hinitial_frame Hreached].
  exists next_injection.
  split; [exact Heffect |].
  split; [exact Hstep_incr |].
  split; [exact Hstep_frame |].
  constructor.
    + exact Hselected_initial.
    + exact Hexact.
    + exact Hinitial.
    + exact Hnext.
    + eapply inject_incr_trans; eauto.
    + eapply watpl_frame_trans; eauto.
    + exact Hnext_reached.
Qed.

(** This is the single proposition the one-step classifier module exports.
    Its proof is precisely where reached assignments/copies, direct builtins,
    and the four legal reads are enumerated. *)
Definition ActionTablePrivateSelectedOneStepTheorem : Prop :=
  forall version protected_blocks,
    LinkedSourceActionTableBlocks version protected_blocks ->
    ActionTablePrivateReachedStepClassification version protected_blocks.

(** The step module states the same sound contract without bundling the
    entry-history facts into a record.  This adapter is the only integration
    layer: it projects those facts from the reached invariant, fixes the
    selected function-provenance predicate, and discards only the redundant
    already-composed frame returned by the generic contract. *)
Theorem watcap_selected_step_contract_adapts :
  ActionTablePrivateSelectedReachedStepClassification ->
  ActionTablePrivateSelectedOneStepTheorem.
Proof.
  intros Hselected version protected_blocks Hblocks
    initial_memory initial_injection current_injection
    before step_trace after Hinvariant Hstep.
  destruct Hinvariant as
    [Hinitial Hexact Hinitial_private Hcurrent Hincr Hframe Hreached].
  subst initial_injection.
  destruct (Hselected version protected_blocks initial_memory
    current_injection (watcap_selected_function_is_controlled version)
    before step_trace after Hblocks (watcap_selected_control_certificate version)
    (watcap_selected_reached_internal_is_controlled version)
    Hinitial Hincr Hframe Hcurrent Hreached Hstep) as
    [next_injection
      [Heffect [Hnext [Hstep_incr
        [Hstep_frame [Hcomposed_frame Hnext_reached]]]]]].
  exists next_injection.
  split; [exact Heffect |].
  split; [exact Hnext |].
  split; [exact Hstep_incr |].
  split; [exact Hstep_frame |].
  exact Hnext_reached.
Qed.

Theorem watcap_selected_one_step_theorem_closes_coverage :
  ActionTablePrivateSelectedOneStepTheorem ->
  forall version protected_blocks,
    LinkedSourceActionTableBlocks version protected_blocks ->
    ActionTablePrivateClightStepCoverage version protected_blocks.
Proof.
  intros Hone_step version protected_blocks Hblocks.
  apply watcap_step_classification_closes_step_coverage.
  exact (Hone_step version protected_blocks Hblocks).
Qed.

(** Premise-free integration with the exhaustive 25-constructor dispatcher
    exported by the step module. *)
Theorem action_table_private_clight_step_coverage_holds :
  forall version protected_blocks,
    LinkedSourceActionTableBlocks version protected_blocks ->
    ActionTablePrivateClightStepCoverage version protected_blocks.
Proof.
  intros version protected_blocks Hblocks.
  exact (watcap_selected_one_step_theorem_closes_coverage
    (watcap_selected_step_contract_adapts
      action_table_private_selected_one_step_theorem_holds)
    version protected_blocks Hblocks).
Qed.

(** * Reached finite execution *)

Theorem watcap_reached_star_preserves_private_state :
  forall version protected_blocks initial_memory initial_injection
      first current_injection whole_trace last,
    ActionTablePrivateClightStepCoverage version protected_blocks ->
    ActionTablePrivateReachedStateInvariant
      version protected_blocks initial_memory initial_injection
      current_injection first ->
    @Smallstep.star _ _ Clight.step2 (watcap_selected_ge version)
      first whole_trace last ->
    exists final_injection,
      ActionTablePrivateReachedStateInvariant
        version protected_blocks initial_memory initial_injection
        final_injection last.
Proof.
  intros version protected_blocks initial_memory initial_injection first
    current_injection whole_trace last Hcoverage Hinvariant Hrun.
  revert current_injection Hinvariant.
  induction Hrun as
    [state |
     first first_trace middle rest_trace last whole_trace
       Hstep Hrest IH Htrace];
    intros current_injection Hinvariant.
  - exists current_injection. exact Hinvariant.
  - destruct (Hcoverage initial_memory initial_injection current_injection
      first first_trace middle Hinvariant Hstep) as
      [middle_injection
        [Heffect [Hincr [Hstep_frame Hmiddle_invariant]]]].
    exact (IH middle_injection Hmiddle_invariant).
Qed.

(** Starting at the accepted task boundary and using the same execution all
    the way to [last], the endpoint retains every protected byte.  No castle
    entry, alternate initialized memory, or fabricated intermediate state is
    admitted by this theorem. *)
Theorem watcap_selected_runtime_task_run_is_private :
  forall version protected_blocks start whole_trace last,
    LinkedSourceActionTableBlocks version protected_blocks ->
    SelectedRuntimeTaskStart version (selected_clight_source version) start ->
    ActionTablePrivateClightStepCoverage version protected_blocks ->
    @Smallstep.star _ _ Clight.step2 (watcap_selected_ge version)
      start whole_trace last ->
    exists initial_memory initial_injection final_injection,
      ActionTablePrivateReachedStateInvariant
        version protected_blocks initial_memory initial_injection
        final_injection last /\
      ActionTablePrivateMemoryFrame protected_blocks initial_memory
        (watpl_clight_state_memory last).
Proof.
  intros version protected_blocks start whole_trace last Hblocks Hstart
    Hcoverage Hrun.
  destruct (watcap_selected_runtime_task_start_establishes_invariant
    version protected_blocks start Hblocks Hstart) as
    [initial_memory [initial_injection Hinitial]].
  destruct (watcap_reached_star_preserves_private_state
    version protected_blocks initial_memory initial_injection start
    initial_injection whole_trace last Hcoverage Hinitial Hrun) as
    [final_injection Hfinal].
  exists initial_memory, initial_injection, final_injection.
  split; [exact Hfinal |].
  exact (watcap_initial_to_current_table_frame _ _ _ _ _ _ Hfinal).
Qed.

(** Abstract assembly lemma, retained for clients that supply a different
    selected one-step classifier. *)
Theorem watcap_one_step_theorem_closes_every_selected_task_run :
  ActionTablePrivateSelectedOneStepTheorem ->
  forall version protected_blocks start whole_trace last,
    LinkedSourceActionTableBlocks version protected_blocks ->
    SelectedRuntimeTaskStart version (selected_clight_source version) start ->
    @Smallstep.star _ _ Clight.step2 (watcap_selected_ge version)
      start whole_trace last ->
    exists initial_memory initial_injection final_injection,
      ActionTablePrivateReachedStateInvariant
        version protected_blocks initial_memory initial_injection
        final_injection last /\
      ActionTablePrivateMemoryFrame protected_blocks initial_memory
        (watpl_clight_state_memory last).
Proof.
  intros Hone_step version protected_blocks start whole_trace last Hblocks
    Hstart Hrun.
  eapply watcap_selected_runtime_task_run_is_private; eauto.
  eapply watcap_selected_one_step_theorem_closes_coverage; eauto.
Qed.

(** Final premise-free reached-run theorem.  All semantic one-step work is
    consumed from [action_table_private_selected_one_step_theorem_holds]; the
    only hypotheses left identify the genuine selected start and the actual
    finite execution being analyzed. *)
Theorem action_table_private_every_selected_task_run_is_private :
  forall version protected_blocks start whole_trace last,
    LinkedSourceActionTableBlocks version protected_blocks ->
    SelectedRuntimeTaskStart version (selected_clight_source version) start ->
    @Smallstep.star _ _ Clight.step2 (watcap_selected_ge version)
      start whole_trace last ->
    exists initial_memory initial_injection final_injection,
      ActionTablePrivateReachedStateInvariant
        version protected_blocks initial_memory initial_injection
        final_injection last /\
      ActionTablePrivateMemoryFrame protected_blocks initial_memory
        (watpl_clight_state_memory last).
Proof.
  intros version protected_blocks start whole_trace last Hblocks Hstart Hrun.
  eapply watcap_selected_runtime_task_run_is_private; eauto.
  now apply action_table_private_clight_step_coverage_holds.
Qed.

(** Stable capstone interface used by [MainTheorem].  This is exactly the
    successful, defined, in-bounds selected Clight execution boundary: the
    initialized private table blocks remain byte-for-byte framed throughout
    every finite reached run. *)
Definition WritableActionTableReachedExecutionClosure : Prop :=
  forall version protected_blocks start whole_trace last,
    LinkedSourceActionTableBlocks version protected_blocks ->
    SelectedRuntimeTaskStart version (selected_clight_source version) start ->
    @Smallstep.star _ _ Clight.step2 (watcap_selected_ge version)
      start whole_trace last ->
    exists initial_memory initial_injection final_injection,
      ActionTablePrivateReachedStateInvariant
        version protected_blocks initial_memory initial_injection
        final_injection last /\
      ActionTablePrivateMemoryFrame protected_blocks initial_memory
        (watpl_clight_state_memory last).

Theorem writable_action_table_reached_execution_closure_holds :
  WritableActionTableReachedExecutionClosure.
Proof.
  exact action_table_private_every_selected_task_run_is_private.
Qed.

Print Assumptions watcap_selected_control_certificate.
Print Assumptions watcap_selected_runtime_task_start_establishes_invariant.
Print Assumptions watcap_step_classification_closes_step_coverage.
Print Assumptions watcap_reached_star_preserves_private_state.
Print Assumptions watcap_one_step_theorem_closes_every_selected_task_run.
Print Assumptions action_table_private_clight_step_coverage_holds.
Print Assumptions action_table_private_every_selected_task_run_is_private.
Print Assumptions writable_action_table_reached_execution_closure_holds.
