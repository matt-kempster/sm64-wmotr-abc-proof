(** Compositional Clight execution refinement.

    The cleaned-link proofs construct concrete [Clight.program] values.  To
    use executions of those programs as retail executions, however, one must
    relate complete Clight states rather than merely show that global names
    exist.  This file supplies the reusable, admission-free composition layer:

    - explicit injections for local environments and temporary environments;
    - a recursive continuation relation, including saved caller frames;
    - a complete three-constructor Clight-state injection relation;
    - concrete pointer load/store transport through CompCert memory injection;
    - lockstep one-step-to-trace and initial-to-final composition theorems.

    The file does not assert that the current US or JP programs satisfy the
    component relations.  In particular, unresolved external functions and
    the US viewport tag rewrite must be discharged before the final theorem
    below can be instantiated. *)

From Coq Require Import List ZArith.
From compcert Require Import AST Clight Cop Ctypes Events Globalenvs Maps Memory
  Smallstep Values.

Import ListNotations.
Local Open Scope Z_scope.

(** * Environments and continuations *)

Definition TypeRefinement := type -> type -> Prop.
Definition FunctionRefinement := function -> function -> Prop.
Definition StatementRefinement := statement -> statement -> Prop.
Definition FundefRefinement := Clight.fundef -> Clight.fundef -> Prop.

Definition EnvironmentInjection
    (injection : meminj) (types : TypeRefinement)
    (source target : env) : Prop :=
  forall id source_block source_type,
    source ! id = Some (source_block, source_type) ->
    exists target_block target_type delta,
      target ! id = Some (target_block, target_type) /\
      types source_type target_type /\
      injection source_block = Some (target_block, delta).

Definition TempEnvironmentInjection
    (injection : meminj) (source target : temp_env) : Prop :=
  forall id source_value,
    source ! id = Some source_value ->
    exists target_value,
      target ! id = Some target_value /\
      Val.inject injection source_value target_value.

Inductive ContinuationInjection
    (injection : meminj)
    (types : TypeRefinement)
    (functions : FunctionRefinement)
    (statements : StatementRefinement) : cont -> cont -> Prop :=
| continuation_inject_stop :
    ContinuationInjection injection types functions statements Kstop Kstop
| continuation_inject_seq :
    forall source_statement target_statement source_cont target_cont,
      statements source_statement target_statement ->
      ContinuationInjection injection types functions statements
        source_cont target_cont ->
      ContinuationInjection injection types functions statements
        (Kseq source_statement source_cont)
        (Kseq target_statement target_cont)
| continuation_inject_loop1 :
    forall source_body source_increment target_body target_increment
        source_cont target_cont,
      statements source_body target_body ->
      statements source_increment target_increment ->
      ContinuationInjection injection types functions statements
        source_cont target_cont ->
      ContinuationInjection injection types functions statements
        (Kloop1 source_body source_increment source_cont)
        (Kloop1 target_body target_increment target_cont)
| continuation_inject_loop2 :
    forall source_body source_increment target_body target_increment
        source_cont target_cont,
      statements source_body target_body ->
      statements source_increment target_increment ->
      ContinuationInjection injection types functions statements
        source_cont target_cont ->
      ContinuationInjection injection types functions statements
        (Kloop2 source_body source_increment source_cont)
        (Kloop2 target_body target_increment target_cont)
| continuation_inject_switch :
    forall source_cont target_cont,
      ContinuationInjection injection types functions statements
        source_cont target_cont ->
      ContinuationInjection injection types functions statements
        (Kswitch source_cont) (Kswitch target_cont)
| continuation_inject_call :
    forall destination source_function target_function
        source_environment target_environment source_temps target_temps
        source_cont target_cont,
      functions source_function target_function ->
      EnvironmentInjection injection types
        source_environment target_environment ->
      TempEnvironmentInjection injection source_temps target_temps ->
      ContinuationInjection injection types functions statements
        source_cont target_cont ->
      ContinuationInjection injection types functions statements
        (Kcall destination source_function source_environment source_temps
          source_cont)
        (Kcall destination target_function target_environment target_temps
          target_cont).

Inductive ClightStateInjection
    (injection : meminj)
    (types : TypeRefinement)
    (functions : FunctionRefinement)
    (statements : StatementRefinement)
    (fundefs : FundefRefinement) : Clight.state -> Clight.state -> Prop :=
| clight_state_inject_internal :
    forall source_function target_function source_statement target_statement
        source_cont target_cont source_environment target_environment
        source_temps target_temps source_memory target_memory,
      functions source_function target_function ->
      statements source_statement target_statement ->
      ContinuationInjection injection types functions statements
        source_cont target_cont ->
      EnvironmentInjection injection types
        source_environment target_environment ->
      TempEnvironmentInjection injection source_temps target_temps ->
      Mem.inject injection source_memory target_memory ->
      ClightStateInjection injection types functions statements fundefs
        (State source_function source_statement source_cont source_environment
          source_temps source_memory)
        (State target_function target_statement target_cont target_environment
          target_temps target_memory)
| clight_state_inject_call :
    forall source_fundef target_fundef source_arguments target_arguments
        source_cont target_cont source_memory target_memory,
      fundefs source_fundef target_fundef ->
      Val.inject_list injection source_arguments target_arguments ->
      ContinuationInjection injection types functions statements
        source_cont target_cont ->
      Mem.inject injection source_memory target_memory ->
      ClightStateInjection injection types functions statements fundefs
        (Callstate source_fundef source_arguments source_cont source_memory)
        (Callstate target_fundef target_arguments target_cont target_memory)
| clight_state_inject_return :
    forall source_result target_result source_cont target_cont
        source_memory target_memory,
      Val.inject injection source_result target_result ->
      ContinuationInjection injection types functions statements
        source_cont target_cont ->
      Mem.inject injection source_memory target_memory ->
      ClightStateInjection injection types functions statements fundefs
        (Returnstate source_result source_cont source_memory)
        (Returnstate target_result target_cont target_memory).

Lemma value_injection_incr :
  forall injection injection' source target,
    inject_incr injection injection' ->
    Val.inject injection source target ->
    Val.inject injection' source target.
Proof.
  intros injection injection' source target Hincr Hvalue.
  eapply val_inject_incr; eauto.
Qed.

Lemma temp_environment_injection_incr :
  forall injection injection' source target,
    inject_incr injection injection' ->
    TempEnvironmentInjection injection source target ->
    TempEnvironmentInjection injection' source target.
Proof.
  intros injection injection' source target Hincr Htemps id value Hget.
  destruct (Htemps id value Hget) as [target_value [Htarget Hinject]].
  exists target_value. split; [exact Htarget |].
  eapply value_injection_incr; eauto.
Qed.

Lemma environment_injection_incr :
  forall injection injection' types source target,
    inject_incr injection injection' ->
    EnvironmentInjection injection types source target ->
    EnvironmentInjection injection' types source target.
Proof.
  intros injection injection' types source target Hincr Henvironment
    id block source_type Hget.
  destruct (Henvironment id block source_type Hget)
    as [target_block [target_type [delta
      [Htarget [Htype Hmap]]]]].
  exists target_block, target_type, delta.
  repeat split; auto.
Qed.

Lemma continuation_injection_incr :
  forall injection injection' types functions statements source target,
    inject_incr injection injection' ->
    ContinuationInjection injection types functions statements source target ->
    ContinuationInjection injection' types functions statements source target.
Proof.
  intros injection injection' types functions statements source target
    Hincr Hcontinuation.
  induction Hcontinuation.
  - apply continuation_inject_stop.
  - eapply continuation_inject_seq; eauto.
  - eapply continuation_inject_loop1; eauto.
  - eapply continuation_inject_loop2; eauto.
  - eapply continuation_inject_switch; eauto.
  - eapply continuation_inject_call; eauto using environment_injection_incr,
      temp_environment_injection_incr.
Qed.

(** * Pointer and memory-operation compatibility *)

Theorem mapped_pointer_load_compatibility :
  forall injection source_memory target_memory chunk
      source_address target_address source_value,
    Mem.inject injection source_memory target_memory ->
    Val.inject injection source_address target_address ->
    Mem.loadv chunk source_memory source_address = Some source_value ->
    exists target_value,
      Mem.loadv chunk target_memory target_address = Some target_value /\
      Val.inject injection source_value target_value.
Proof.
  intros injection source_memory target_memory chunk source_address
    target_address source_value Hmemory Haddress Hload.
  eapply Mem.loadv_inject; eauto.
Qed.

Theorem mapped_pointer_store_compatibility :
  forall injection chunk source_memory target_memory
      source_address target_address source_value target_value source_after,
    Mem.inject injection source_memory target_memory ->
    Val.inject injection source_address target_address ->
    Val.inject injection source_value target_value ->
    Mem.storev chunk source_memory source_address source_value =
      Some source_after ->
    exists target_after,
      Mem.storev chunk target_memory target_address target_value =
        Some target_after /\
      Mem.inject injection source_after target_after.
Proof.
  intros injection chunk source_memory target_memory source_address
    target_address source_value target_value source_after Hmemory Haddress
    Hvalue Hstore.
  eapply Mem.storev_mapped_inject; eauto.
Qed.

Theorem injected_pointer_validity :
  forall injection source_memory target_memory source_block target_block
      delta offset,
    Mem.inject injection source_memory target_memory ->
    injection source_block = Some (target_block, delta) ->
    Mem.valid_pointer source_memory source_block offset = true ->
    Mem.valid_pointer target_memory target_block (offset + delta) = true.
Proof.
  intros injection source_memory target_memory source_block target_block
    delta offset Hmemory Hmap Hvalid.
  eapply Mem.valid_pointer_inject; eauto.
Qed.

(** This is the complete same-type rvalue dereference boundary used by a
    future expression induction.  It covers by-value loads, by-reference and
    by-copy composite values, and bitfields. *)
Theorem deref_loc_inject_same_type :
  forall injection ty source_memory target_memory source_block source_offset
      bitfield source_value target_block target_offset,
    deref_loc ty source_memory source_block source_offset bitfield source_value ->
    Val.inject injection (Vptr source_block source_offset)
      (Vptr target_block target_offset) ->
    Mem.inject injection source_memory target_memory ->
    exists target_value,
      deref_loc ty target_memory target_block target_offset bitfield
        target_value /\
      Val.inject injection source_value target_value.
Proof.
  intros injection ty source_memory target_memory source_block source_offset
    bitfield source_value target_block target_offset Hderef Hpointer Hmemory.
  inversion Hderef; subst.
  - destruct (Mem.loadv_inject injection source_memory target_memory chunk
      (Vptr source_block source_offset) (Vptr target_block target_offset)
      source_value Hmemory H0 Hpointer)
      as [target_value [Hload Hinject]].
    exists target_value. split; auto.
    eapply deref_loc_value; eauto.
  - exists (Vptr target_block target_offset). split; auto.
    eapply deref_loc_reference; eauto.
  - exists (Vptr target_block target_offset). split; auto.
    eapply deref_loc_copy; eauto.
  - match goal with
    | Hbitfield : Cop.load_bitfield _ _ _ _ _ source_memory
        (Vptr source_block source_offset) source_value |- _ =>
        inversion Hbitfield; subst
    end.
    match goal with
    | Hload : Mem.loadv ?chunk source_memory
        (Vptr source_block source_offset) = Some (Vint ?raw) |- _ =>
        destruct (Mem.loadv_inject injection source_memory target_memory chunk
          (Vptr source_block source_offset) (Vptr target_block target_offset)
          (Vint raw) Hmemory Hload Hpointer) as [loaded [Htarget Hinject]];
        inversion Hinject; subst;
        eexists; split;
        [ eapply deref_loc_bitfield; econstructor; eauto
        | constructor ]
    end.
Qed.

(** CompCert already proves that the scalar operation layer respects memory
    injection.  These named wrappers make the expression-induction boundary
    explicit: unary operations, binary operations (including finite-width
    pointer arithmetic), and casts do not require a hand-written arithmetic
    model. *)
Theorem unary_operation_respects_memory_injection :
  forall injection source_memory target_memory operation source_operand ty
      source_result target_operand,
    sem_unary_operation operation source_operand ty source_memory =
      Some source_result ->
    Val.inject injection source_operand target_operand ->
    Mem.inject injection source_memory target_memory ->
    exists target_result,
      sem_unary_operation operation target_operand ty target_memory =
        Some target_result /\
      Val.inject injection source_result target_result.
Proof.
  exact sem_unary_operation_inject.
Qed.

Theorem binary_operation_respects_memory_injection :
  forall injection source_memory target_memory composite_environment operation
      source_left left_type source_right right_type source_result
      target_left target_right,
    sem_binary_operation composite_environment operation source_left left_type
      source_right right_type source_memory = Some source_result ->
    Val.inject injection source_left target_left ->
    Val.inject injection source_right target_right ->
    Mem.inject injection source_memory target_memory ->
    exists target_result,
      sem_binary_operation composite_environment operation target_left
        left_type target_right right_type target_memory = Some target_result /\
      Val.inject injection source_result target_result.
Proof.
  exact sem_binary_operation_inject.
Qed.

Theorem cast_respects_memory_injection :
  forall injection source_value source_type target_type source_memory
      source_result injected_source_value target_memory,
    sem_cast source_value source_type target_type source_memory =
      Some source_result ->
    Val.inject injection source_value injected_source_value ->
    Mem.inject injection source_memory target_memory ->
    exists target_result,
      sem_cast injected_source_value source_type target_type target_memory =
        Some target_result /\
      Val.inject injection source_result target_result.
Proof.
  exact sem_cast_inject.
Qed.

(** * Lockstep composition *)

Record ClightLockstepComponents
    (source target : Clight.program) : Type := {
  lockstep_match_states : Clight.state -> Clight.state -> Prop;
  lockstep_public_symbols :
    forall id,
      Senv.public_symbol (Clight.globalenv target) id =
      Senv.public_symbol (Clight.globalenv source) id;
  lockstep_initial_states :
    forall source_state,
      Clight.initial_state source source_state ->
      exists target_state,
        Clight.initial_state target target_state /\
        lockstep_match_states source_state target_state;
  lockstep_final_states :
    forall source_state target_state result,
      lockstep_match_states source_state target_state ->
      Clight.final_state source_state result ->
      Clight.final_state target_state result;
  lockstep_internal_and_external_steps :
    forall source_state trace source_after target_state,
      Clight.step2 (Clight.globalenv source)
        source_state trace source_after ->
      lockstep_match_states source_state target_state ->
      exists target_after,
        Clight.step2 (Clight.globalenv target)
          target_state trace target_after /\
        lockstep_match_states source_after target_after
}.

Theorem clight_lockstep_components_forward_simulation :
  forall source target (components : ClightLockstepComponents source target),
    Smallstep.forward_simulation
      (Clight.semantics2 source) (Clight.semantics2 target).
Proof.
  intros source target components.
  eapply Smallstep.forward_simulation_step with
    (match_states := lockstep_match_states _ _ components).
  - exact (lockstep_public_symbols _ _ components).
  - exact (lockstep_initial_states _ _ components).
  - exact (lockstep_final_states _ _ components).
  - intros source_state trace source_after Hstep target_state Hmatch.
    eapply (lockstep_internal_and_external_steps source target components);
      eauto.
Qed.

Theorem clight_lockstep_star :
  forall source target (components : ClightLockstepComponents source target)
      source_start trace source_final,
    @Smallstep.star _ _ Clight.step2 (Clight.globalenv source)
      source_start trace source_final ->
    forall target_start,
      lockstep_match_states _ _ components source_start target_start ->
      exists target_final,
        @Smallstep.star _ _ Clight.step2 (Clight.globalenv target)
          target_start trace target_final /\
        lockstep_match_states _ _ components source_final target_final.
Proof.
  intros source target components source_start trace source_final Hsteps.
  induction Hsteps; intros target_start Hmatch.
  - exists target_start. split; [constructor | exact Hmatch].
  - destruct (lockstep_internal_and_external_steps source target components
      s1 t1 s2 target_start H Hmatch)
      as [target_middle [Htarget_step Hmiddle_match]].
    destruct (IHHsteps target_middle Hmiddle_match)
      as [target_final [Htarget_steps Hfinal_match]].
    exists target_final. split; [|exact Hfinal_match].
    eapply Smallstep.star_step; eauto.
Qed.

(** End-to-end execution transport from an actual source initial state to a
    target final state.  Unlike an opaque whole-program obligation, every
    premise is one of the four standard forward-simulation components above. *)
Theorem clight_lockstep_initial_to_final_execution :
  forall source target (components : ClightLockstepComponents source target)
      source_start trace source_final result,
    Clight.initial_state source source_start ->
    @Smallstep.star _ _ Clight.step2 (Clight.globalenv source)
      source_start trace source_final ->
    Clight.final_state source_final result ->
    exists target_start target_final,
      Clight.initial_state target target_start /\
      @Smallstep.star _ _ Clight.step2 (Clight.globalenv target)
        target_start trace target_final /\
      Clight.final_state target_final result /\
      lockstep_match_states _ _ components source_final target_final.
Proof.
  intros source target components source_start trace source_final result
    Hinitial Hsteps Hfinal.
  destruct (lockstep_initial_states source target components
    source_start Hinitial) as [target_start [Htarget_initial Hstart_match]].
  destruct (clight_lockstep_star source target components source_start trace
    source_final Hsteps target_start Hstart_match)
    as [target_final [Htarget_steps Hfinal_match]].
  exists target_start, target_final.
  repeat split; auto.
  eapply lockstep_final_states; eauto.
Qed.

(** A concrete instance must provide all four fields.  This explicit boundary
    is intentionally weaker than claiming that structural linking, definition
    provenance, or symbol coverage already gives a retail execution. *)
Definition CleanedToRetailClightExecutionRefinement
    (cleaned retail : Clight.program) : Prop :=
  exists components : ClightLockstepComponents cleaned retail, True.

Theorem cleaned_to_retail_refinement_supplies_forward_simulation :
  forall cleaned retail,
    CleanedToRetailClightExecutionRefinement cleaned retail ->
    Smallstep.forward_simulation
      (Clight.semantics2 cleaned) (Clight.semantics2 retail).
Proof.
  intros cleaned retail [components _].
  exact (clight_lockstep_components_forward_simulation
    cleaned retail components).
Qed.
