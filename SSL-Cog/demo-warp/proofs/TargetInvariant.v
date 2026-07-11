From Coq Require Import List ZArith Lia.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Clight ClightBigstep.
From DemoWarp.Proofs Require Import PointerProvenanceKernel HardwareContracts
  OperationalCallgraph.

Import ListNotations.
Local Open Scope Z_scope.

Definition target_pointer_cells
    (curr_cell handler_block : block) : memory_region :=
  fun b ofs =>
    (b = curr_cell /\ 0 <= ofs < size_chunk Mptr) \/
    (b = handler_block /\ 8 <= ofs < 8 + size_chunk Mptr).

Definition target_pointer_invariant
    (demo_block curr_cell handler_block : block) (m : mem) : Prop :=
  Mem.valid_block m demo_block /\
  Mem.valid_block m curr_cell /\
  Mem.valid_block m handler_block /\
  (exists current,
    Mem.load Mptr m curr_cell 0 = Some current /\
    safe_demo_pointer_value demo_block current) /\
  (exists ofs,
    Mem.load Mptr m handler_block 8 = Some (Vptr demo_block ofs)).

Lemma target_pointer_invariant_unchanged :
  forall demo_block curr_cell handler_block before after,
    Mem.unchanged_on (target_pointer_cells curr_cell handler_block) before after ->
    target_pointer_invariant demo_block curr_cell handler_block before ->
    target_pointer_invariant demo_block curr_cell handler_block after.
Proof.
  intros demo_block curr_cell handler_block before after Hunchanged
    [Hdemo [Hcurr [Hhandler [[current [Hload Hsafe]] [ofs Hbuf]]]]].
  repeat split.
  - eapply Mem.valid_block_unchanged_on; eauto.
  - eapply Mem.valid_block_unchanged_on; eauto.
  - eapply Mem.valid_block_unchanged_on; eauto.
  - exists current. split; [| exact Hsafe].
    assert (Heq : Mem.load Mptr after curr_cell 0 =
        Mem.load Mptr before curr_cell 0).
    { eapply Mem.load_unchanged_on_1.
      - exact Hunchanged.
      - exact Hcurr.
      - intros i Hi. left. split; [reflexivity | exact Hi]. }
    rewrite Heq. exact Hload.
  - exists ofs.
    assert (Heq : Mem.load Mptr after handler_block 8 =
        Mem.load Mptr before handler_block 8).
    { eapply Mem.load_unchanged_on_1.
      - exact Hunchanged.
      - exact Hhandler.
      - intros i Hi. right. split; [reflexivity | exact Hi]. }
    rewrite Heq. exact Hbuf.
Qed.

Lemma target_alloc_variables_unchanged :
  forall protected ge vars e0 before e1 after,
    alloc_variables ge e0 before vars e1 after ->
    Mem.unchanged_on protected before after.
Proof.
  intros protected ge vars e0 before e1 after Halloc.
  induction Halloc.
  - apply Mem.unchanged_on_refl.
  - eapply Mem.unchanged_on_trans; [| exact IHHalloc].
    eapply Mem.alloc_unchanged_on; eauto.
Qed.

Lemma target_function_entry_unchanged :
  forall protected ge f vargs before e le after,
    function_entry2 ge f vargs before e le after ->
    Mem.unchanged_on protected before after.
Proof.
  intros protected ge f vargs before e le after Hentry.
  inv Hentry. eapply target_alloc_variables_unchanged; eauto.
Qed.

Lemma target_alloc_variables_fresh :
  forall ge vars e0 before e1 after,
    alloc_variables ge e0 before vars e1 after ->
    forall id b ty,
      e1 ! id = Some (b, ty) ->
      Mem.valid_block before b ->
      e0 ! id = Some (b, ty).
Proof.
  intros ge vars e0 before e1 after Halloc.
  induction Halloc; intros id0 b0 ty0 Hget Hvalid.
  - exact Hget.
  - assert (Hvalid1 : Mem.valid_block m1 b0)
      by (eapply Mem.valid_block_alloc; eauto).
    specialize (IHHalloc id0 b0 ty0 Hget Hvalid1).
    assert (Hfresh : ~ Mem.valid_block m b1)
      by (eapply Mem.fresh_block_alloc; eauto).
    destruct (peq id0 id).
    + subst id0. rewrite PTree.gss in IHHalloc. inv IHHalloc.
      exfalso. apply Hfresh. exact Hvalid.
    + rewrite PTree.gso in IHHalloc by auto. exact IHHalloc.
Qed.

Lemma target_function_entry_fresh :
  forall ge f vargs before e le after,
    function_entry2 ge f vargs before e le after ->
    forall b lo hi,
      In (b, lo, hi) (blocks_of_env ge e) ->
      ~ Mem.valid_block before b.
Proof.
  intros ge f vargs before e le after Hentry b lo hi Hin Hvalid.
  inv Hentry.
  unfold blocks_of_env in Hin.
  apply list_in_map_inv in Hin.
  destruct Hin as [[id [bb ty]] [Heq Hin]].
  unfold block_of_binding in Heq.
  apply PTree.elements_complete in Hin.
  assert (Hbb : bb = b) by congruence. subst bb.
  pose proof (target_alloc_variables_fresh _ _ _ _ _ _ H2 id b ty Hin Hvalid)
    as Hempty.
  rewrite PTree.gempty in Hempty. discriminate.
Qed.

Lemma target_free_list_unchanged :
  forall protected blocks before after,
    Mem.free_list before blocks = Some after ->
    (forall b lo hi ofs,
      In (b, lo, hi) blocks -> ~ protected b ofs) ->
    Mem.unchanged_on protected before after.
Proof.
  intros protected blocks.
  induction blocks as [| [[b lo] hi] rest IH]; intros before after Hfree Havoid.
  - simpl in Hfree. inv Hfree. apply Mem.unchanged_on_refl.
  - simpl in Hfree.
    destruct (Mem.free before b lo hi) as [middle |] eqn:Hfirst;
      try discriminate.
    eapply Mem.unchanged_on_trans.
    + eapply Mem.free_unchanged_on; [exact Hfirst |].
      intros ofs Hofs. eapply Havoid. left. reflexivity.
    + eapply IH; [exact Hfree |].
      intros b' lo' hi' ofs Hin. eapply Havoid. right. exact Hin.
Qed.

Theorem target_function_entries_preserve :
  forall ge demo_block curr_cell handler_block,
    function_entries_preserve
      (target_pointer_invariant demo_block curr_cell handler_block) ge.
Proof.
  intros ge demo_block curr_cell handler_block f vargs before e le after
    Hentry Hinvariant.
  eapply target_pointer_invariant_unchanged; [| exact Hinvariant].
  eapply target_function_entry_unchanged; exact Hentry.
Qed.

Theorem target_function_frees_preserve :
  forall ge demo_block curr_cell handler_block,
    function_frees_preserve
      (target_pointer_invariant demo_block curr_cell handler_block) ge.
Proof.
  intros ge demo_block curr_cell handler_block f vargs call_before e le
    after_entry before_free after Hentry Hfree Hcall Hbefore.
  eapply target_pointer_invariant_unchanged; [| exact Hbefore].
  eapply target_free_list_unchanged; [exact Hfree |].
  intros b lo hi ofs Hin Hprotected.
  pose proof (target_function_entry_fresh _ _ _ _ _ _ _ Hentry b lo hi Hin)
    as Hfresh.
  destruct Hcall as [Hdemo [Hcurr [Hhandler _]]].
  unfold target_pointer_cells in Hprotected.
  destruct Hprotected as [[Heq _] | [Heq _]]; subst b;
    [exact (Hfresh Hcurr) | exact (Hfresh Hhandler)].
Qed.

Definition target_external_arguments_avoid
    (ge : genv) (curr_cell handler_block : block) : Prop :=
  forall ef args before trace result after,
    external_call ef ge args before trace result after ->
    arguments_avoid_region (target_pointer_cells curr_cell handler_block) args.

Theorem normal_target_externals_preserve :
  forall (ge : genv) (demo_block curr_cell handler_block : block),
    normal_n64_external_locality
      (target_pointer_cells curr_cell handler_block) ge ->
    target_external_arguments_avoid ge curr_cell handler_block ->
    reached_externals_preserve
      (target_pointer_invariant demo_block curr_cell handler_block) ge.
Proof.
  intros ge demo_block curr_cell handler_block Hlocal Hargs
    ef args before trace result after Hcall Hinvariant.
  eapply target_pointer_invariant_unchanged; [| exact Hinvariant].
  eapply Hlocal; [exact Hcall |].
  eapply Hargs; exact Hcall.
Qed.

Definition target_frame_boundary_claim : Prop :=
  forall ge demo_block curr_cell handler_block,
    function_entries_preserve
      (target_pointer_invariant demo_block curr_cell handler_block) ge /\
    function_frees_preserve
      (target_pointer_invariant demo_block curr_cell handler_block) ge.

Theorem target_frame_boundary_certificate : target_frame_boundary_claim.
Proof.
  intros. split; [apply target_function_entries_preserve |
                  apply target_function_frees_preserve].
Qed.
