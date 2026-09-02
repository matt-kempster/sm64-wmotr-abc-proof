(** The first read of the real State-to-Object copy.  Index one addresses
    byte 272 of a global whose entire allocation is at most 200 bytes.
    The read has no successful Clight step in any initialization-rooted run;
    this is not an assertion about a flat-address MIPS continuation. *)

From Coq Require Import Bool Lia List ZArith.
From compcert Require Import AST Clight Clightdefs Cop Coqlib Ctypes Errors
  Events Globalenvs Integers Maps Memory Smallstep Values.
From LessThanOneAPress.Proofs Require Import
  Area1Rank18StateArrayBound ClightAllocationBounds EyerokRank15LiveMovement
  GameTypes SelectedClightTarget.

Import ListNotations.
Import Clightdefs.ClightNotations.
Local Open Scope Z_scope.

Definition rank18_copy_body version :=
  match version with
  | VersionUS => R18U.f_copy_mario_state_to_object
  | VersionJP => R18J.f_copy_mario_state_to_object
  end.

Definition rank18_first_velocity_expression : expr :=
  Ederef (Ebinop Oadd
    (Efield (Ederef (Ebinop Oadd
      (Evar R18U._gMarioStates (tarray (Tstruct R18U._MarioState noattr) 0))
      (Etempvar R18U._i tint) (tptr (Tstruct R18U._MarioState noattr)))
      (Tstruct R18U._MarioState noattr)) R18U._vel (tarray tfloat 3))
    (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat.

Definition rank18_index_test : statement :=
  Ssequence
    (Sset R18U._t'37 (Evar R18U._gCurrentObject (tptr (Tstruct R18U._Object noattr))))
    (Ssequence
      (Sset R18U._t'38 (Evar R18U._gMarioObject (tptr (Tstruct R18U._Object noattr))))
      (Sifthenelse (Ebinop One
        (Etempvar R18U._t'37 (tptr (Tstruct R18U._Object noattr)))
        (Etempvar R18U._t'38 (tptr (Tstruct R18U._Object noattr))) tint)
        (Sset R18U._i (Ebinop Oadd (Etempvar R18U._i tint)
          (Econst_int (Int.repr 1) tint) tint)) Sskip)).

Definition Rank18CopyFirstReadPrefix (version : GameVersion) : Prop :=
  exists first_store remaining_stores,
    fn_vars (rank18_copy_body version) = [] /\
    fn_body (rank18_copy_body version) =
      Ssequence (Sset R18U._i (Econst_int (Int.repr 0) tint))
        (Ssequence rank18_index_test
          (Ssequence
            (Ssequence (Sset R18U._t'35
              (Evar R18U._gCurrentObject (tptr (Tstruct R18U._Object noattr))))
              (Ssequence (Sset R18U._t'36 rank18_first_velocity_expression)
                first_store)) remaining_stores)).

Lemma rank18_first_read_is_the_generated_copy_prefix : forall version,
  Rank18CopyFirstReadPrefix version.
Proof. intros []; do 2 eexists; split; reflexivity. Qed.

Lemma rank18_copy_entry_has_empty_locals :
  forall version ge arguments memory environment temporaries after,
    function_entry2 ge (rank18_copy_body version) arguments memory
      environment temporaries after ->
    environment = empty_env /\ after = memory.
Proof.
  intros version ge arguments memory environment temporaries after Hentry.
  destruct (rank18_first_read_is_the_generated_copy_prefix version)
    as [first_store [remaining [Hvars Hbody]]].
  inversion Hentry; subst.
  match goal with H : alloc_variables _ _ _ _ _ _ |- _ =>
    rewrite Hvars in H; inversion H; subst
  end.
  auto.
Qed.

Definition rank18_state_layout_ok environment : bool :=
  match environment ! R18U._MarioState with
  | Some description =>
      Z.eqb (co_sizeof description) 200 &&
      match field_offset environment R18U._vel (co_members description) with
      | OK (offset, Full) => Z.eqb offset 72
      | _ => false
      end
  | None => false
  end.

Lemma rank18_selected_state_layout_checked : forall version,
  rank18_state_layout_ok (rank15_selected_header_environment version) = true.
Proof. intros []; vm_compute; reflexivity. Qed.

Lemma rank18_selected_state_layout : forall version,
  let ge := Clight.globalenv (selected_clight_target version) in
  sizeof ge (Tstruct R18U._MarioState noattr) = 200 /\
  exists description,
    (genv_cenv ge) ! R18U._MarioState = Some description /\
    field_offset ge R18U._vel (co_members description) = OK (72, Full).
Proof.
  intros version ge.
  pose proof (rank18_selected_state_layout_checked version) as H.
  rewrite rank15_selected_header_environment_exact in H.
  unfold rank18_state_layout_ok in H.
  destruct ((prog_comp_env (selected_clight_target version)) ! R18U._MarioState)
    as [description |] eqn:E; try discriminate.
  apply andb_true_iff in H. destruct H as [Hsize Hfield].
  apply Z.eqb_eq in Hsize.
  destruct (field_offset (prog_comp_env (selected_clight_target version))
    R18U._vel (co_members description)) as [[offset bits] |] eqn:Hoffset;
    try discriminate.
  destruct bits; try discriminate. apply Z.eqb_eq in Hfield. subst offset.
  split.
  - change ((match (prog_comp_env (selected_clight_target version)) ! R18U._MarioState with
      | Some co => co_sizeof co | None => 0 end) = 200).
    rewrite E. exact Hsize.
  - exists description. auto.
Qed.

Lemma rank18_index_one_pointer_add : forall version memory b,
  sem_binary_operation (Clight.globalenv (selected_clight_target version)) Oadd
    (Vptr b Ptrofs.zero) (tarray (Tstruct R18U._MarioState noattr) 0)
    (Vint (Int.repr 1)) tint memory = Some (Vptr b (Ptrofs.repr 200)).
Proof.
  intros version memory b.
  pose proof (proj1 (rank18_selected_state_layout version)) as Hsize.
  change (Some (Vptr b (Ptrofs.add Ptrofs.zero
    (Ptrofs.mul (Ptrofs.repr (sizeof
      (Clight.globalenv (selected_clight_target version))
      (Tstruct R18U._MarioState noattr))) (Ptrofs.of_ints (Int.repr 1))))) =
    Some (Vptr b (Ptrofs.repr 200))).
  rewrite Hsize. reflexivity.
Qed.

Lemma rank18_first_velocity_read_at_index_one_requires_load :
  forall version locals memory b value,
    Genv.find_symbol (Clight.globalenv (selected_clight_target version))
      R18U._gMarioStates = Some b ->
    locals ! R18U._i = Some (Vint (Int.repr 1)) ->
    eval_expr (Clight.globalenv (selected_clight_target version))
      empty_env locals memory rank18_first_velocity_expression value ->
    Mem.load Mfloat32 memory b 272 = Some value.
Proof.
  intros version locals memory b value Hsymbol Hindex Hread.
  destruct (rank18_selected_state_layout version) as
    [Hsize [description [Hdescription Hfield]]].
  unfold rank18_first_velocity_expression in Hread.
  repeat match goal with
  | H : eval_expr _ _ _ _ _ _ |- _ => inversion H; clear H; subst
  | H : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inversion H; clear H; subst
  end.
  all: repeat match goal with
  | H : deref_loc _ _ _ _ _ _ |- _ => inversion H; clear H; subst
  end; try discriminate.
  all: try congruence.
  all: try solve [match goal with
  | H : empty_env ! _ = Some _ |- _ =>
      unfold empty_env in H; rewrite PTree.gempty in H; discriminate
  end].
  all: repeat match goal with
  | H : typeof _ = _ |- _ => cbn [typeof] in H; inversion H; clear H; subst
  | H : access_mode _ = _ |- _ =>
      cbn [typeof access_mode] in H; inversion H; clear H; subst
  end.
  all: assert (Hco : co = description) by congruence.
  all: subst co.
  all: try congruence.
  assert (Hdelta : delta = 72) by congruence. subst delta.
  assert (Hvalue : v2 = Vint (Int.repr 1)) by congruence. subst v2.
  assert (Hblock : loc2 = b) by congruence. subst loc2.
  cbn [typeof] in H14. rewrite rank18_index_one_pointer_add in H14.
  inversion H14; subst loc0 ofs1.
  change (Some (Vptr b (Ptrofs.repr 272)) = Some (Vptr loc ofs)) in H8.
  inversion H8; subst loc ofs. exact H3.
Qed.

Definition Rank18ReachedIndexOneReadHasNoStep : Prop :=
  forall version initial start prefix memory locals k b step_trace next,
    Genv.init_mem (selected_clight_target version) = Some initial ->
    clight_bound_memory start = initial ->
    @Smallstep.star _ _ Clight.step2
      (Clight.globalenv (selected_clight_target version)) start prefix
      (State (rank18_copy_body version)
        (Sset R18U._t'36 rank18_first_velocity_expression)
        k empty_env locals memory) ->
    Genv.find_symbol (Clight.globalenv (selected_clight_target version))
      R18U._gMarioStates = Some b ->
    locals ! R18U._i = Some (Vint (Int.repr 1)) ->
    ~ Clight.step2 (Clight.globalenv (selected_clight_target version))
      (State (rank18_copy_body version)
        (Sset R18U._t'36 rank18_first_velocity_expression)
        k empty_env locals memory) step_trace next.

Theorem rank18_reached_index_one_copy_read_has_no_step :
  Rank18ReachedIndexOneReadHasNoStep.
Proof.
  unfold Rank18ReachedIndexOneReadHasNoStep.
  intros version initial start prefix memory locals k b step_trace next
    Hinitial Hstart Hprefix Hsymbol Hindex Hstep.
  pose proof (rank18_reached_index_one_first_velocity_load_fails
    _ _ _ _ _ _ Hinitial Hstart Hprefix Hsymbol) as Hfailed.
  inversion Hstep; subst.
  all: try solve [match goal with
  | H : _ \/ _ |- _ => destruct H; discriminate
  end].
  match goal with H : eval_expr _ _ _ _ rank18_first_velocity_expression _ |- _ =>
    pose proof (rank18_first_velocity_read_at_index_one_requires_load
      _ _ _ _ _ Hsymbol Hindex H) as Hload
  end.
  cbn [clight_bound_memory] in Hfailed. congruence.
Qed.
