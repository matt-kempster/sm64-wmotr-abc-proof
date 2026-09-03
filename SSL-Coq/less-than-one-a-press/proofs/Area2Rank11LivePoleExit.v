(** Memory-executed Rank 11 pole release cases.

    These are executions of generated fragments in the selected US/JP genv.
    No controller-to-input invariant, collision result, animation offset or
    outside-call frame is assumed to follow merely from the source census.
    In particular, preserving an incoming velocity is NOT a proof that an
    arbitrary incoming velocity was zero. *)

From Coq Require Import Bool Lia List ZArith.
From compcert Require Import AST Clight ClightBigstep Clightdefs Cop Coqlib
  Ctypes Errors Events Floats Globalenvs Integers Maps Memory Smallstep Values.
From LessThanOneAPress.Proofs Require Import
  Area2Rank11PoleExitSplit Area2Rank11BodyResolution
  EyerokRank15LiveMovement GameTypes SelectedClightTarget.

Import ListNotations.
Import Clightdefs.ClightNotations.
Local Open Scope Z_scope.

(** Reuse the cached selected-header transport instead of evaluating either
    entire linked program.  Every numeric offset is independently checked. *)
Definition rank11_mario_fields : list (ident * Z) :=
  [(R11MU._input, 2); (R11MU._flags, 4); (R11MU._action, 12); (R11MU._pos, 60);
   (R11MU._squishTimer, 180); (R11MU._peakHeight, 188);
   (R11MU._quicksandDepth, 192)].

Definition rank11_field_offset_check environment fields field offset : bool :=
  match field_offset environment field fields with
  | OK (found, Full) => Z.eqb found offset
  | _ => false
  end.

Definition rank11_mario_layout_check environment : bool :=
  match environment ! R11MU._MarioState with
  | Some description => forallb (fun entry =>
      rank11_field_offset_check environment (co_members description)
        (fst entry) (snd entry)) rank11_mario_fields
  | None => false
  end.

Lemma rank11_selected_mario_layout_checked : forall version,
  rank11_mario_layout_check (rank15_selected_header_environment version) = true.
Proof. intros []; vm_compute; reflexivity. Qed.

Lemma rank11_field_offset_check_sound : forall environment fields field offset,
  rank11_field_offset_check environment fields field offset = true ->
  field_offset environment field fields = OK (offset, Full).
Proof.
  intros environment fields field offset H.
  unfold rank11_field_offset_check in H.
  destruct (field_offset environment field fields) as [[found bits] |] eqn:E;
    try discriminate.
  destruct bits; try discriminate. apply Z.eqb_eq in H. subst. reflexivity.
Qed.

Lemma rank11_selected_mario_field : forall version field offset,
  In (field, offset) rank11_mario_fields ->
  exists description,
    (genv_cenv (Clight.globalenv (selected_clight_target version))) !
      R11MU._MarioState = Some description /\
    field_offset (Clight.globalenv (selected_clight_target version)) field
      (co_members description) = OK (offset, Full).
Proof.
  intros version field offset Hin.
  pose proof (rank11_selected_mario_layout_checked version) as H.
  rewrite rank15_selected_header_environment_exact in H.
  unfold rank11_mario_layout_check in H.
  destruct ((prog_comp_env (selected_clight_target version)) ! R11MU._MarioState)
    as [description |] eqn:E; try discriminate.
  exists description. split; [exact E |].
  apply rank11_field_offset_check_sound.
  rewrite forallb_forall in H. exact (H (field, offset) Hin).
Qed.

Definition rank11_mario_field_expression (field : ident) (field_type : type) :=
  Efield (Ederef (Etempvar R11MU._m rank11_mario_pointer_type)
    (Tstruct R11MU._MarioState noattr)) field field_type.

Definition rank11_mario_y_expression :=
  Ederef (Ebinop Oadd (rank11_mario_field_expression R11MU._pos (tarray tfloat 3))
    (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat.

Ltac rank11_temp :=
  repeat (rewrite PTree.gss || rewrite PTree.gso by discriminate); reflexivity.

Section FIELD_EXECUTION.
Variable version : GameVersion.
Let ge := Clight.globalenv (selected_clight_target version).

Lemma rank11_mario_field_lvalue : forall environment locals memory mario field ty offset,
  locals ! R11MU._m = Some (Vptr mario Ptrofs.zero) ->
  In (field, offset) rank11_mario_fields ->
  eval_lvalue ge environment locals memory
    (rank11_mario_field_expression field ty) mario (Ptrofs.repr offset) Full.
Proof.
  intros environment locals memory mario field ty offset Hm Hin.
  destruct (rank11_selected_mario_field version field offset Hin)
    as (description & Hdescription & Hoffset).
  replace (Ptrofs.repr offset) with
    (Ptrofs.add Ptrofs.zero (Ptrofs.repr offset)) by
    (rewrite Ptrofs.add_zero_l; reflexivity).
  unfold rank11_mario_field_expression.
  eapply eval_Efield_struct with (co := description).
  - eapply eval_Elvalue.
    + apply eval_Ederef. apply eval_Etempvar. exact Hm.
    + apply deref_loc_copy. reflexivity.
  - reflexivity.
  - exact Hdescription.
  - exact Hoffset.
Qed.

Lemma rank11_mario_field_read :
  forall environment locals memory mario field ty offset chunk value,
    locals ! R11MU._m = Some (Vptr mario Ptrofs.zero) ->
    In (field, offset) rank11_mario_fields ->
    access_mode ty = By_value chunk -> type_is_volatile ty = false ->
    Mem.load chunk memory mario offset = Some value ->
    eval_expr ge environment locals memory
      (rank11_mario_field_expression field ty) value.
Proof.
  intros environment locals memory mario field ty offset chunk value
    Hm Hin Hmode Hvolatile Hload.
  assert (Hrange : 0 <= offset <= Ptrofs.max_unsigned).
  { unfold rank11_mario_fields in Hin. cbn in Hin.
    repeat destruct Hin as [Hin | Hin]; try contradiction;
      inversion Hin; subst; vm_compute; intuition discriminate. }
  eapply eval_Elvalue.
  - eapply rank11_mario_field_lvalue; eauto.
  - eapply deref_loc_value with (chunk := chunk); eauto.
    cbn [Mem.loadv]. rewrite Ptrofs.unsigned_repr by exact Hrange. exact Hload.
Qed.

Lemma rank11_mario_y_read : forall environment locals memory mario y,
  locals ! R11MU._m = Some (Vptr mario Ptrofs.zero) ->
  Mem.load Mfloat32 memory mario 64 = Some (Vsingle y) ->
  eval_expr ge environment locals memory rank11_mario_y_expression (Vsingle y).
Proof.
  intros environment locals memory mario y Hm Hload.
  unfold rank11_mario_y_expression.
  eapply eval_Elvalue with (ofs := Ptrofs.repr 64) (bf := Full).
  - apply eval_Ederef. eapply eval_Ebinop.
    + eapply eval_Elvalue.
      * eapply rank11_mario_field_lvalue; [exact Hm | cbn; auto].
      * apply deref_loc_reference. reflexivity.
    + constructor.
    + reflexivity.
  - eapply deref_loc_value with (chunk := Mfloat32); eauto.
Qed.

(** No callbacks or stores intervene between this input read and its test.
    The result is one connected execution of the original fragment with the
    original, arbitrary true branch present but unexecuted. *)
Theorem rank11_no_a_test_executes_the_skip :
  forall environment locals memory mario input temporary yes,
    locals ! R11MU._m = Some (Vptr mario Ptrofs.zero) ->
    Mem.load Mint16unsigned memory mario 2 = Some (Vint input) ->
    Int.and input (Int.repr 2) = Int.zero ->
    ClightBigstep.Clight2.exec_stmt ge environment locals memory
      (rank11_a_guard_block temporary yes) E0
      (PTree.set temporary (Vint input) locals) memory Out_normal.
Proof.
  intros environment locals memory mario input temporary yes Hm Hinput Hnoa.
  unfold rank11_a_guard_block.
  eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
  - eapply exec_Sset with (v := Vint input).
    change (eval_expr ge environment locals memory
      (rank11_mario_field_expression R11MU._input tushort) (Vint input)).
    eapply rank11_mario_field_read; eauto; try reflexivity; cbn; auto.
  - eapply exec_Sifthenelse with (v1 := Vint Int.zero) (b := false).
    + eapply eval_Ebinop.
      * apply eval_Etempvar. apply PTree.gss.
      * constructor.
      * change (Some (Vint (Int.and input (Int.repr 2))) = Some (Vint Int.zero)).
        rewrite Hnoa. reflexivity.
    + reflexivity.
    + constructor.
Qed.

Theorem rank11_no_a_test_is_connected_selected_execution :
  forall environment locals memory mario input temporary yes handler continuation,
    locals ! R11MU._m = Some (Vptr mario Ptrofs.zero) ->
    Mem.load Mint16unsigned memory mario 2 = Some (Vint input) ->
    Int.and input (Int.repr 2) = Int.zero ->
    @Smallstep.star _ _ Clight.step2 ge
      (State (rank11_pole_body version handler)
        (rank11_a_guard_block temporary yes) continuation environment locals memory)
      E0 (State (rank11_pole_body version handler) Sskip continuation environment
        (PTree.set temporary (Vint input) locals) memory).
Proof.
  intros environment locals memory mario input temporary yes handler continuation
    Hm Hinput Hnoa.
  pose proof (rank11_no_a_test_executes_the_skip environment locals memory mario
    input temporary yes Hm Hinput Hnoa) as Hexecute.
  destruct (ClightBigstep.exec_stmt_steps Clight.function_entry2
    (selected_clight_target version) _ _ _ _ _ _ _ _ Hexecute
    (rank11_pole_body version handler) continuation) as (last & Hsteps & Houtcome).
  inversion Houtcome; subst last. exact Hsteps.
Qed.

End FIELD_EXECUTION.

Definition Rank11NoATestBoundary : Prop :=
  forall version handler body environment locals memory mario input continuation,
    In body (rank11_a_guard_blocks (fn_body (rank11_pole_body version handler))) ->
    locals ! R11MU._m = Some (Vptr mario Ptrofs.zero) ->
    Mem.load Mint16unsigned memory mario 2 = Some (Vint input) ->
    Int.and input (Int.repr 2) = Int.zero ->
    exists after_locals,
      @Smallstep.star _ _ Clight.step2
        (Clight.globalenv (selected_clight_target version))
        (State (rank11_pole_body version handler) body continuation
          environment locals memory) E0
        (State (rank11_pole_body version handler) Sskip continuation
          environment after_locals memory).

Theorem rank11_every_source_a_test_is_closed_at_a_no_a_memory_read :
  Rank11NoATestBoundary.
Proof.
  intros version handler body environment locals memory mario input continuation
    Hin Hm Hinput Hnoa.
  destruct (rank11_all_removed_guards_have_the_executed_shape version handler body Hin)
    as (temporary & yes & ->).
  eexists. eapply rank11_no_a_test_is_connected_selected_execution; eauto.
Qed.
