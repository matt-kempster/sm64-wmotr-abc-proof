(** Expression evaluation and store/copy coverage for the private writable
    action tables. *)

From Coq Require Import Bool List Lia ZArith.
From compcert Require Import
  AST Clight Coqlib Cop Ctypes Events Globalenvs Integers Maps Memory Values.
From LessThanOneAPress.Proofs Require Import
  ClightEndToEndRefinement WritableActionTablePrivateLive
  WritableActionTableAliasExternalClosure
  WritableActionTablePrivateInitialization.

Import ListNotations.
Local Open Scope Z_scope.

Definition watpc_expression_globals_avoid
    (protected_identifiers : list ident) (environment : Clight.env)
    (expression : expr) : Prop :=
  forall identifier,
    In identifier protected_identifiers ->
    environment ! identifier = None ->
    wat_evar_count identifier expression = 0%nat.

Definition watpc_environment_self_injects
    (injection : meminj) (environment : Clight.env) : Prop :=
  forall identifier local_block local_type,
    environment ! identifier = Some (local_block, local_type) ->
    injection local_block = Some (local_block, 0).

Definition watpc_temps_self_inject
    (injection : meminj) (temporaries : Clight.temp_env) : Prop :=
  forall identifier value,
    temporaries ! identifier = Some value ->
    Val.inject injection value value.

Lemma watpc_environment_self_injects_incr :
  forall injection injection' environment,
    inject_incr injection injection' ->
    watpc_environment_self_injects injection environment ->
    watpc_environment_self_injects injection' environment.
Proof.
  intros injection injection' environment Hincr Henv identifier block ty Hget.
  now apply Hincr, Henv with (identifier := identifier) (local_type := ty).
Qed.

Lemma watpc_temps_self_inject_incr :
  forall injection injection' temporaries,
    inject_incr injection injection' ->
    watpc_temps_self_inject injection temporaries ->
    watpc_temps_self_inject injection' temporaries.
Proof.
  intros injection injection' temporaries Hincr Htemps identifier value Hget.
  eapply val_inject_incr; [exact Hincr | now apply Htemps with identifier].
Qed.

Lemma watpc_expression_globals_avoid_child :
  forall protected_identifiers environment child parent,
    (forall identifier,
      wat_evar_count identifier child <= wat_evar_count identifier parent)%nat ->
    watpc_expression_globals_avoid protected_identifiers environment parent ->
    watpc_expression_globals_avoid protected_identifiers environment child.
Proof.
  intros protected_identifiers environment child parent Hle Havoid identifier
    Hin Hlocal.
  specialize (Havoid identifier Hin Hlocal).
  specialize (Hle identifier). lia.
Qed.

Lemma watpc_global_identifier_not_protected :
  forall protected_identifiers environment identifier ty,
    environment ! identifier = None ->
    watpc_expression_globals_avoid protected_identifiers environment
      (Evar identifier ty) ->
    ~ In identifier protected_identifiers.
Proof.
  intros protected_identifiers environment identifier ty Hlocal Havoid Hin.
  specialize (Havoid identifier Hin Hlocal).
  cbn [wat_evar_count] in Havoid.
  now rewrite Pos.eqb_refl in Havoid.
Qed.

Lemma watpc_deref_loc_deterministic :
  forall ty memory block offset bitfield first second,
    @deref_loc ty memory block offset bitfield first ->
    @deref_loc ty memory block offset bitfield second ->
    first = second.
Proof.
  intros ty memory block offset bitfield first second Hfirst Hsecond.
  inversion Hfirst; subst; inversion Hsecond; subst; try congruence.
  all: match goal with
  | Hleft : load_bitfield _ _ _ _ _ _ _ _,
    Hright : load_bitfield _ _ _ _ _ _ _ _ |- _ =>
      inversion Hleft; subst; inversion Hright; subst; congruence
  end.
Qed.

Section PRIVATE_EXPRESSION.

Variable program : Clight.program.
Variable protected_identifiers : list ident.
Variable initial_injection injection : meminj.
Variable environment : Clight.env.
Variable temporaries : Clight.temp_env.
Variable memory : mem.

Hypothesis Hinitial_injection :
  initial_injection =
    watpi_private_initial_injection program protected_identifiers.
Hypothesis Hincr : inject_incr initial_injection injection.
Hypothesis Hmemory :
  Mem.inject injection memory memory.
Hypothesis Henvironment :
  watpc_environment_self_injects injection environment.
Hypothesis Htemporaries :
  watpc_temps_self_inject injection temporaries.

Lemma watpc_eval_expr_private :
  forall expression value,
    @eval_expr (Clight.globalenv program) environment temporaries memory
      expression value ->
    watpc_expression_globals_avoid
      protected_identifiers environment expression ->
    Val.inject injection value value
with watpc_eval_lvalue_private :
  forall expression block offset bitfield,
    @eval_lvalue (Clight.globalenv program) environment temporaries memory
      expression block offset bitfield ->
    watpc_expression_globals_avoid
      protected_identifiers environment expression ->
    Val.inject injection (Vptr block offset) (Vptr block offset).
Proof.
  - destruct 1; intros Havoid.
    + constructor.
    + constructor.
    + constructor.
    + constructor.
    + now apply Htemporaries with id.
    + eapply watpc_eval_lvalue_private; eauto.
    + assert (Hoperand : watpc_expression_globals_avoid
        protected_identifiers environment a).
      { eapply watpc_expression_globals_avoid_child; [| exact Havoid].
        intros identifier. cbn. lia. }
      pose proof (watpc_eval_expr_private _ _ H Hoperand) as Hinjected.
      destruct (unary_operation_respects_memory_injection
        injection memory memory op v1 (typeof a) v v1 H0 Hinjected Hmemory)
        as [target [Htarget Hresult]].
      rewrite H0 in Htarget. inversion Htarget; subst target; exact Hresult.
    + assert (Hleft : watpc_expression_globals_avoid
        protected_identifiers environment a1).
      { eapply watpc_expression_globals_avoid_child; [| exact Havoid].
        intros identifier. cbn. lia. }
      assert (Hright : watpc_expression_globals_avoid
        protected_identifiers environment a2).
      { eapply watpc_expression_globals_avoid_child; [| exact Havoid].
        intros identifier. cbn. lia. }
      pose proof (watpc_eval_expr_private _ _ H Hleft) as Hinjected_left.
      pose proof (watpc_eval_expr_private _ _ H0 Hright) as Hinjected_right.
      destruct (binary_operation_respects_memory_injection
        injection memory memory (Clight.globalenv program) op
        v1 (typeof a1) v2 (typeof a2) v v1 v2 H1
        Hinjected_left Hinjected_right Hmemory)
        as [target [Htarget Hresult]].
      rewrite H1 in Htarget. inversion Htarget; subst target; exact Hresult.
    + assert (Hoperand : watpc_expression_globals_avoid
        protected_identifiers environment a).
      { eapply watpc_expression_globals_avoid_child; [| exact Havoid].
        intros identifier. cbn. lia. }
      pose proof (watpc_eval_expr_private _ _ H Hoperand) as Hinjected.
      destruct (cast_respects_memory_injection injection v1 (typeof a) ty
        memory v v1 memory H0 Hinjected Hmemory)
        as [target [Htarget Hresult]].
      rewrite H0 in Htarget. inversion Htarget; subst target; exact Hresult.
    + destruct Archi.ptr64; constructor.
    + destruct Archi.ptr64; constructor.
    + assert (Hlvalue : watpc_expression_globals_avoid
        protected_identifiers environment a).
      { exact Havoid. }
      pose proof (watpc_eval_lvalue_private _ _ _ _ H Hlvalue) as Hpointer.
      destruct (deref_loc_inject_same_type injection (typeof a) memory memory
        loc ofs bf v loc ofs H0 Hpointer Hmemory)
        as [target [Hderef Hresult]].
      assert (target = v).
      { eapply watpc_deref_loc_deterministic; eauto. }
      now subst target.
  - destruct 1; intros Havoid.
    + specialize (Henvironment id l ty H).
      econstructor; [exact Henvironment | now rewrite Ptrofs.add_zero].
    + assert (Hnot_protected : ~ In id protected_identifiers).
      { now apply watpc_global_identifier_not_protected with
          (environment := environment) (ty := ty). }
      subst initial_injection.
      pose proof (watpi_private_initial_injection_eq
        program protected_identifiers id l H0 Hnot_protected) as Hmapped.
      specialize (Hincr l l 0 Hmapped).
      econstructor; [exact Hincr | now rewrite Ptrofs.add_zero].
    + assert (Hinner : watpc_expression_globals_avoid
        protected_identifiers environment a).
      { eapply watpc_expression_globals_avoid_child; [| exact Havoid].
        intros identifier. cbn. lia. }
      exact (watpc_eval_expr_private _ _ H Hinner).
    + assert (Hinner : watpc_expression_globals_avoid
        protected_identifiers environment a).
      { eapply watpc_expression_globals_avoid_child; [| exact Havoid].
        intros identifier. cbn. lia. }
      pose proof (watpc_eval_expr_private _ _ H Hinner) as Hpointer.
      change (Val.inject injection
        (Val.offset_ptr (Vptr l ofs) (Ptrofs.repr delta))
        (Val.offset_ptr (Vptr l ofs) (Ptrofs.repr delta))).
      now apply Val.offset_ptr_inject.
    + assert (Hinner : watpc_expression_globals_avoid
        protected_identifiers environment a).
      { eapply watpc_expression_globals_avoid_child; [| exact Havoid].
        intros identifier. cbn. lia. }
      pose proof (watpc_eval_expr_private _ _ H Hinner) as Hpointer.
      change (Val.inject injection
        (Val.offset_ptr (Vptr l ofs) (Ptrofs.repr delta))
        (Val.offset_ptr (Vptr l ofs) (Ptrofs.repr delta))).
      now apply Val.offset_ptr_inject.
Qed.

Lemma watpc_eval_exprlist_private :
  forall expressions types values,
    @eval_exprlist (Clight.globalenv program) environment temporaries memory
      expressions types values ->
    (forall expression,
      In expression expressions ->
      watpc_expression_globals_avoid
        protected_identifiers environment expression) ->
    Val.inject_list injection values values.
Proof.
  intros expressions types values Heval.
  induction Heval; intros Havoids.
  - constructor.
  - assert (Hexpr : watpc_expression_globals_avoid
      protected_identifiers environment a).
    { apply Havoids. now left. }
    pose proof (watpc_eval_expr_private _ _ H Hexpr) as Hvalue.
    destruct (cast_respects_memory_injection injection v1 (typeof a) ty
      memory v2 v1 memory H0 Hvalue Hmemory)
      as [target [Htarget Hcast]].
    rewrite H0 in Htarget. inversion Htarget; subst target.
    constructor; [exact Hcast |].
    apply IHHeval. intros expression Hin. apply Havoids. now right.
Qed.

End PRIVATE_EXPRESSION.

Lemma watpc_self_pointer_mapping_has_zero_delta :
  forall injection memory pointer_block pointer_offset delta,
    Mem.inject injection memory memory ->
    Mem.perm memory pointer_block (Ptrofs.unsigned pointer_offset)
      Cur Nonempty ->
    injection pointer_block = Some (pointer_block, delta) ->
    pointer_offset = Ptrofs.add pointer_offset (Ptrofs.repr delta) ->
    delta = 0.
Proof.
  intros injection memory pointer_block pointer_offset delta Hmemory
    Hpermission Hmapping Hoffset.
  pose proof (Mem.address_inject injection memory memory pointer_block
    pointer_offset pointer_block delta Nonempty Hmemory Hpermission Hmapping)
    as Hunsigned.
  rewrite <- Hoffset in Hunsigned. lia.
Qed.

(** This is the complete reached-[Sassign] memory classifier.  It includes
    scalar stores, positive-size block copies, harmless zero-size copies, and
    bitfield read/modify/write stores. *)
Theorem watpc_assign_loc_is_private_effect :
  forall (ge : Clight.genv) protected_blocks injection memory value_type
      target_block target_offset bitfield value after,
    ActionTablePrivateMemoryInvariant
      ge protected_blocks memory injection ->
    Val.inject injection
      (Vptr target_block target_offset) (Vptr target_block target_offset) ->
    Val.inject injection value value ->
    assign_loc ge value_type memory target_block target_offset bitfield
      value after ->
    ActionTablePrivatePrimitiveEffect
      ge protected_blocks injection memory after.
Proof.
  intros ge protected_blocks injection memory value_type target_block
    target_offset bitfield value after Hinvariant Htarget Hvalue Hassign.
  pose proof (watpl_memory_inject _ _ _ _ Hinvariant) as Hmemory.
  inversion Hassign; subst.
  - eapply watpl_effect_storev with
      (address := Vptr target_block target_offset)
      (stored_value := value); eauto.
  - destruct (zeq (sizeof ge value_type) 0) as [Hsize_zero | Hsize_nonzero].
    + assert (bytes = []) as ->.
      { pose proof (Mem.loadbytes_length _ _ _ _ _ H3) as Hlength.
        rewrite Hsize_zero in Hlength. cbn in Hlength.
        now apply length_zero_iff_nil. }
      now apply watpl_effect_storebytes_empty with
        (target_block := target_block) (target_offset := Ptrofs.unsigned target_offset).
    + assert (Hsize_positive : sizeof ge value_type > 0).
      { generalize (sizeof_pos ge value_type). lia. }
      assert (Hsource_range :
        Mem.range_perm memory b' (Ptrofs.unsigned ofs')
          (Ptrofs.unsigned ofs' + sizeof ge value_type) Cur Nonempty).
      { eapply Mem.range_perm_implies.
        - eapply Mem.loadbytes_range_perm; eauto.
        - auto with mem. }
      assert (Htarget_range :
        Mem.range_perm memory target_block (Ptrofs.unsigned target_offset)
          (Ptrofs.unsigned target_offset + sizeof ge value_type) Cur Nonempty).
      { pose proof (Mem.loadbytes_length _ _ _ _ _ H3) as Hlength.
        replace (sizeof ge value_type) with (Z.of_nat (length bytes)).
        - eapply Mem.range_perm_implies.
          + eapply Mem.storebytes_range_perm; eauto.
          + auto with mem.
        - rewrite Hlength. now rewrite Z2Nat.id by lia. }
      assert (Hsource_permission :
        Mem.perm memory b' (Ptrofs.unsigned ofs') Cur Nonempty).
      { apply Hsource_range. lia. }
      assert (Htarget_permission :
        Mem.perm memory target_block (Ptrofs.unsigned target_offset)
          Cur Nonempty).
      { apply Htarget_range. lia. }
      inversion Hvalue as
        [| | | | source_block source_offset source_target source_target_offset
          source_delta Hsource_map Hsource_offset |]; subst.
      inversion Htarget as
        [| | | | destination_block destination_offset destination_target
          destination_target_offset destination_delta Htarget_map Htarget_offset
         |]; subst.
      assert (Hsource_delta_zero : source_delta = 0).
      { eapply watpc_self_pointer_mapping_has_zero_delta with
          (pointer_block := b') (pointer_offset := ofs').
        - exact Hmemory.
        - exact Hsource_permission.
        - exact Hsource_map.
        - exact Hsource_offset. }
      assert (Htarget_delta_zero : destination_delta = 0).
      { eapply watpc_self_pointer_mapping_has_zero_delta with
          (pointer_block := target_block) (pointer_offset := target_offset).
        - exact Hmemory.
        - exact Htarget_permission.
        - exact Htarget_map.
        - exact Htarget_offset. }
      subst source_delta destination_delta.
      rewrite Ptrofs.add_zero in Hsource_offset, Htarget_offset.
      destruct (Mem.loadbytes_inject injection memory memory
        b' (Ptrofs.unsigned ofs') (sizeof ge value_type) b' 0 bytes
        Hmemory H3 Hsource_map) as [target_bytes [Htarget_load Hbytes]].
      rewrite Z.add_0_r, H3 in Htarget_load.
      inversion Htarget_load; subst target_bytes.
      eapply watpl_effect_storebytes; eauto.
  - match goal with
    | Hbitfield : store_bitfield _ _ _ _ _ _ _ _ _ _ |- _ =>
        inversion Hbitfield; subst
    end.
    eapply watpl_effect_storev with
      (chunk := chunk_for_carrier sz)
      (address := Vptr target_block target_offset)
      (stored_value := Vint
        (Int.bitfield_insert (first_bit sz pos width) width c n)).
    + exact Htarget.
    + constructor.
    + exact H5.
Qed.
