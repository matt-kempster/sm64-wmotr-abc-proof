(** Successful Clight steps cannot enlarge an already allocated block.
    This is a property of CompCert's actual memory operations, including its
    specified external calls, not a gameplay or no-alias assumption.  It is
    used by the Rank-18 copy proof to retain the real global-array bound. *)

From Coq Require Import Lia List ZArith.
From compcert Require Import AST Clight Cop Coqlib Ctypes Events Globalenvs
  Memory Smallstep Values.

Import ListNotations.
Local Open Scope Z_scope.

Definition clight_bound_memory (state : Clight.state) : mem :=
  match state with
  | State _ _ _ _ _ m | Callstate _ _ _ m | Returnstate _ _ m => m
  end.

Definition clight_old_blocks_bounded (before after : mem) : Prop :=
  (forall b, Mem.valid_block before b -> Mem.valid_block after b) /\
  (forall b offset permission,
    Mem.valid_block before b ->
    Mem.perm after b offset Max permission ->
    Mem.perm before b offset Max permission).

Lemma clight_old_blocks_bounded_refl : forall m,
  clight_old_blocks_bounded m m.
Proof. unfold clight_old_blocks_bounded; auto. Qed.

Lemma clight_old_blocks_bounded_trans : forall m1 m2 m3,
  clight_old_blocks_bounded m1 m2 ->
  clight_old_blocks_bounded m2 m3 ->
  clight_old_blocks_bounded m1 m3.
Proof.
  intros m1 m2 m3 [Hv12 Hp12] [Hv23 Hp23]. split; eauto.
Qed.

Lemma clight_store_old_blocks_bounded : forall chunk m b offset value m',
  Mem.store chunk m b offset value = Some m' ->
  clight_old_blocks_bounded m m'.
Proof.
  intros chunk m b offset value m' Hstore. split.
  - eapply Mem.store_valid_block_1; eauto.
  - intros. eapply Mem.perm_store_2; eauto.
Qed.

Lemma clight_storebytes_old_blocks_bounded : forall m b offset bytes m',
  Mem.storebytes m b offset bytes = Some m' ->
  clight_old_blocks_bounded m m'.
Proof.
  intros m b offset bytes m' Hstore. split.
  - eapply Mem.storebytes_valid_block_1; eauto.
  - intros. eapply Mem.perm_storebytes_2; eauto.
Qed.

Lemma clight_assign_old_blocks_bounded : forall ce ty m b offset bits value m',
  assign_loc ce ty m b offset bits value m' ->
  clight_old_blocks_bounded m m'.
Proof.
  intros ce ty m b offset bits value m' Hassign. inversion Hassign; subst.
  - eapply clight_store_old_blocks_bounded; eauto.
  - eapply clight_storebytes_old_blocks_bounded; eauto.
  - match goal with H : store_bitfield _ _ _ _ _ _ _ _ _ _ |- _ =>
      inversion H; subst end.
    eapply clight_store_old_blocks_bounded; eauto.
Qed.

Lemma clight_alloc_old_blocks_bounded : forall m lo hi m' fresh,
  Mem.alloc m lo hi = (m', fresh) ->
  clight_old_blocks_bounded m m'.
Proof.
  intros m lo hi m' fresh Halloc. split.
  - eapply Mem.valid_block_alloc; eauto.
  - intros b offset permission Hvalid Hperm.
    eapply Mem.perm_alloc_4; eauto.
    intro Heq. subst b. exact (Mem.fresh_block_alloc _ _ _ _ _ Halloc Hvalid).
Qed.

Lemma clight_alloc_variables_old_blocks_bounded : forall ge e m variables e' m',
  alloc_variables ge e m variables e' m' ->
  clight_old_blocks_bounded m m'.
Proof.
  intros ge e m variables e' m' Halloc. induction Halloc.
  - apply clight_old_blocks_bounded_refl.
  - eapply clight_old_blocks_bounded_trans; [| exact IHHalloc].
    eapply clight_alloc_old_blocks_bounded; eauto.
Qed.

Lemma clight_free_old_blocks_bounded : forall m b lo hi m',
  Mem.free m b lo hi = Some m' -> clight_old_blocks_bounded m m'.
Proof.
  intros m b lo hi m' Hfree. split.
  - eapply Mem.valid_block_free_1; eauto.
  - intros. eapply Mem.perm_free_3; eauto.
Qed.

Lemma clight_free_list_old_blocks_bounded : forall blocks m m',
  Mem.free_list m blocks = Some m' -> clight_old_blocks_bounded m m'.
Proof.
  induction blocks as [| [[b lo] hi] rest IH]; intros m m' Hfree.
  - cbn in Hfree. inversion Hfree; subst. apply clight_old_blocks_bounded_refl.
  - cbn in Hfree. destruct (Mem.free m b lo hi) as [middle |] eqn:Hmiddle;
      try discriminate.
    eapply clight_old_blocks_bounded_trans.
    + eapply clight_free_old_blocks_bounded; eauto.
    + eapply IH; eauto.
Qed.

Lemma clight_external_old_blocks_bounded : forall ef ge args m trace result m',
  external_call ef ge args m trace result m' ->
  clight_old_blocks_bounded m m'.
Proof.
  intros ef ge args m trace result m' Hcall. split.
  - intros b Hvalid. eapply external_call_valid_block; eauto.
  - intros b offset permission Hvalid Hperm.
    eapply external_call_max_perm; eauto.
Qed.

Theorem clight_step2_old_blocks_bounded : forall ge before trace after,
  Clight.step2 ge before trace after ->
  clight_old_blocks_bounded
    (clight_bound_memory before) (clight_bound_memory after).
Proof.
  intros ge before trace after Hstep. inversion Hstep; subst;
    cbn [clight_bound_memory]; try apply clight_old_blocks_bounded_refl.
  - eapply clight_assign_old_blocks_bounded; eauto.
  - eapply clight_external_old_blocks_bounded; eauto.
  - eapply clight_free_list_old_blocks_bounded; eauto.
  - eapply clight_free_list_old_blocks_bounded; eauto.
  - eapply clight_free_list_old_blocks_bounded; eauto.
  - match goal with H : function_entry2 _ _ _ _ _ _ _ |- _ =>
      inversion H; subst end.
    eapply clight_alloc_variables_old_blocks_bounded; eauto.
  - eapply clight_external_old_blocks_bounded; eauto.
Qed.

Theorem clight_star2_old_blocks_bounded : forall ge before trace after,
  @Smallstep.star _ _ Clight.step2 ge before trace after ->
  clight_old_blocks_bounded
    (clight_bound_memory before) (clight_bound_memory after).
Proof.
  intros ge before trace after Hsteps. induction Hsteps.
  - apply clight_old_blocks_bounded_refl.
  - eapply clight_old_blocks_bounded_trans; [| exact IHHsteps].
    eapply clight_step2_old_blocks_bounded; eauto.
Qed.

Theorem initialized_global_bound_persists_through_clight :
  forall (program : Clight.program) initial start trace last b variable,
    Genv.init_mem program = Some initial ->
    Genv.find_var_info (Clight.globalenv program) b = Some variable ->
    clight_bound_memory start = initial ->
    @Smallstep.star _ _ Clight.step2 (Clight.globalenv program) start trace last ->
    forall offset permission,
      Mem.perm (clight_bound_memory last) b offset Max permission ->
      0 <= offset < init_data_list_size (gvar_init variable).
Proof.
  intros program initial start trace last b variable Hinitial Hvariable
    Hstart Hsteps offset permission Hperm.
  destruct (clight_star2_old_blocks_bounded _ _ _ _ Hsteps) as [_ Hbounds].
  rewrite Hstart in Hbounds.
  assert (Hvalid : Mem.valid_block initial b).
  { eapply Genv.find_var_info_not_fresh; eauto. }
  pose proof (Hbounds b offset permission Hvalid Hperm) as Hinitial_perm.
  exact (proj1 ((proj1 (proj2 (@Genv.init_mem_characterization
    Clight.fundef Ctypes.type program b variable initial Hvariable Hinitial)))
    offset Max permission Hinitial_perm)).
Qed.
