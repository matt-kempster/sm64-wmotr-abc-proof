(** The actual list stores performed by the generated deallocator.  This
    supplies the primitive memory effect needed by a live/free partition;
    it does not assume that an address denotes one permanent allocation. *)
From Coq Require Import Bool List ZArith.
From compcert Require Import AST Clight ClightBigstep Clightdefs Cop Ctypes
  Events Globalenvs Integers Maps Memory Values.
From LessThanOneAPress.Proofs Require Import GameTypes ObjectContactNecessity
  ObjectContactReadback InkBackwardExecution InkCopyCaller ContactConsumerExecution
  SelectedClightTarget Area1AllocationChoice TeleporterObjectLifetime
  TeleporterUnloadTraversal.
Import ListNotations.
Local Open Scope Z_scope.
Module TPP := us_spawn_object.

Definition tpp_address (p : TULPointer) (delta : Z) : Z :=
  Ptrofs.unsigned (Ptrofs.add (snd p) (Ptrofs.repr delta)).
Definition tpp_next_load (memory : mem) (p : TULPointer) :=
  Mem.load Mptr memory (fst p) (tpp_address p 96).
Definition tpp_prev_load (memory : mem) (p : TULPointer) :=
  Mem.load Mptr memory (fst p) (tpp_address p 100).

Definition TPPDeallocationStores (before after : mem)
    (free obj prev next : TULPointer) (old_free : val) : Prop :=
  exists m1 m2 m3,
    Mem.store Mptr before (fst next) (tpp_address next 100)
      (tul_pointer prev) = Some m1 /\
    Mem.store Mptr m1 (fst prev) (tpp_address prev 96)
      (tul_pointer next) = Some m2 /\
    Mem.store Mptr m2 (fst obj) (tpp_address obj 96) old_free = Some m3 /\
    Mem.store Mptr m3 (fst free) (tpp_address free 96)
      (tul_pointer obj) = Some after.

(** The interval formula is about actual CompCert byte addresses. *)
Definition TPPCellSeparate (reader : TULPointer) (read_delta : Z)
    (read_chunk : memory_chunk) (writer : TULPointer) (write_delta : Z) : Prop :=
  fst reader <> fst writer \/
  tpp_address writer write_delta + size_chunk Mptr <= tpp_address reader read_delta \/
  tpp_address reader read_delta + size_chunk read_chunk <= tpp_address writer write_delta.

Lemma tpp_store_preserves_separate_cell : forall before writer delta value after
    reader read_delta chunk,
  Mem.store Mptr before (fst writer) (tpp_address writer delta) value = Some after ->
  TPPCellSeparate reader read_delta chunk writer delta ->
  Mem.load chunk after (fst reader) (tpp_address reader read_delta) =
    Mem.load chunk before (fst reader) (tpp_address reader read_delta).
Proof.
  intros before writer delta value after reader read_delta chunk Hstore Hseparate.
  eapply Mem.load_store_other; [exact Hstore|].
  unfold TPPCellSeparate in Hseparate. intuition congruence.
Qed.

Definition tpp_store lhs field rhs := Sassign (pac_read lhs field) (Etempvar rhs pac_node).
Definition tpp_unlink_next := Ssequence
  (Sset TPP._t'4 (pac_read TPP._obj TPP._next))
  (Ssequence (Sset TPP._t'5 (pac_read TPP._obj TPP._prev))
    (tpp_store TPP._t'4 TPP._prev TPP._t'5)).
Definition tpp_unlink_prev := Ssequence
  (Sset TPP._t'2 (pac_read TPP._obj TPP._prev))
  (Ssequence (Sset TPP._t'3 (pac_read TPP._obj TPP._next))
    (tpp_store TPP._t'2 TPP._next TPP._t'3)).
Definition tpp_save_free := Ssequence
  (Sset TPP._t'1 (pac_read TPP._freeList TPP._next))
  (tpp_store TPP._obj TPP._next TPP._t'1).
Definition tpp_insert_free := tpp_store TPP._freeList TPP._next TPP._obj.

Lemma tpp_deallocator_source_exact : forall version,
  fn_body (tul_deallocate_function version) =
    Ssequence tpp_unlink_next
      (Ssequence tpp_unlink_prev (Ssequence tpp_save_free tpp_insert_free)).
Proof. intros []; reflexivity. Qed.

Lemma tpp_actual_node_store : forall version e le before lhs field rhs delta
    target value tr last after out,
  le ! lhs = Some (tul_pointer target) -> le ! rhs = Some value ->
  ibcc_field_ok (Clight.globalenv (selected_clight_target version))
    TPP._ObjectNode field delta = true ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le before
    (tpp_store lhs field rhs) tr last after out ->
  Mem.store Mptr before (fst target) (tpp_address target delta) value = Some after.
Proof.
  intros version e le before lhs field rhs delta [b ofs] value tr last after out
    Htarget Hvalue Hlayout Hrun.
  unfold tpp_store, pac_read in Hrun. inversion Hrun; subst.
  match goal with Hl : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ =>
    destruct (ibcc_field_location _ _ _ _
      (Ederef (Etempvar lhs pac_node) (Tstruct TPP._ObjectNode noattr))
      TPP._ObjectNode field pac_node b ofs delta _ _ _ eq_refl
      ltac:(intros; eapply ibcc_deref_struct; [exact Htarget|eassumption]) Hlayout Hl)
      as (-> & -> & ->) end.
  match goal with Hr : eval_expr _ _ _ _ (Etempvar rhs _) ?answer |- _ =>
    assert (answer = value) by (eapply ocn_temp_value; eauto); subst answer end.
  match goal with Hcast : sem_cast value _ _ _ = Some ?stored |- _ =>
    assert (stored = value) by
      (unfold sem_cast in Hcast; cbn in Hcast;
       destruct value; try discriminate Hcast; injection Hcast as <-; reflexivity);
    subst stored end.
  match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ =>
    inversion Ha; subst; try discriminate end.
  match goal with Hmode : access_mode _ = By_value _ |- _ =>
    cbn [access_mode] in Hmode; inversion Hmode; subst end.
  assumption.
Qed.

Lemma tpp_actual_unlink_next : forall version e le before obj prev next tr last after out,
  le ! TPP._obj = Some (tul_pointer obj) ->
  tpp_next_load before obj = Some (tul_pointer next) ->
  tpp_prev_load before obj = Some (tul_pointer prev) ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le before
    tpp_unlink_next tr last after out ->
  Mem.store Mptr before (fst next) (tpp_address next 100) (tul_pointer prev) = Some after.
Proof.
  intros version e le before [ob oo] [pb po] [nb no] tr last after out
    Hobj Hnext Hprev Hrun.
  unfold tpp_unlink_next in Hrun.
  unfold ocn_exec, ClightBigstep.Clight2.exec_stmt in Hrun. cce_unroll_loop_free_exec.
  match goal with Hr : eval_expr _ _ _ _ (pac_read TPP._obj TPP._next) ?value |- _ =>
    assert (value = Vptr nb no) by
      (eapply pac_read_field with (delta := 96);
       [exact Hobj|exact (proj1 (pac_node_layout version))|exact Hnext|exact Hr]);
    subst value end.
  lazymatch goal with Hr : eval_expr _ _ _ _ (pac_read TPP._obj TPP._prev) ?value |- _ =>
    assert (value = Vptr pb po) by
      (eapply pac_read_field with (delta := 100)
        (le := PTree.set TPP._t'4 (Vptr nb no) le) (id := TPP._obj);
       [rewrite PTree.gso by discriminate; exact Hobj|
        exact (proj2 (pac_node_layout version))|exact Hprev|exact Hr]); subst value end.
  eapply tpp_actual_node_store with
    (le := PTree.set TPP._t'5 (Vptr pb po) (PTree.set TPP._t'4 (Vptr nb no) le))
    (lhs := TPP._t'4) (rhs := TPP._t'5);
    [| |exact (proj2 (pac_node_layout version))|eassumption].
  - rewrite PTree.gso by discriminate. apply PTree.gss.
  - apply PTree.gss.
Qed.

Lemma tpp_actual_unlink_prev : forall version e le before obj prev next tr last after out,
  le ! TPP._obj = Some (tul_pointer obj) ->
  tpp_next_load before obj = Some (tul_pointer next) ->
  tpp_prev_load before obj = Some (tul_pointer prev) ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le before
    tpp_unlink_prev tr last after out ->
  Mem.store Mptr before (fst prev) (tpp_address prev 96) (tul_pointer next) = Some after.
Proof.
  intros version e le before [ob oo] [pb po] [nb no] tr last after out
    Hobj Hnext Hprev Hrun.
  unfold tpp_unlink_prev in Hrun.
  unfold ocn_exec, ClightBigstep.Clight2.exec_stmt in Hrun. cce_unroll_loop_free_exec.
  match goal with Hr : eval_expr _ _ _ _ (pac_read TPP._obj TPP._prev) ?value |- _ =>
    assert (value = Vptr pb po) by
      (eapply pac_read_field with (delta := 100);
       [exact Hobj|exact (proj2 (pac_node_layout version))|exact Hprev|exact Hr]);
    subst value end.
  match goal with Hr : eval_expr _ _ _ _ (pac_read TPP._obj TPP._next) ?value |- _ =>
    assert (value = Vptr nb no) by
      (eapply pac_read_field with (delta := 96)
        (le := PTree.set TPP._t'2 (Vptr pb po) le) (id := TPP._obj);
       [rewrite PTree.gso by discriminate; exact Hobj|
        exact (proj1 (pac_node_layout version))|exact Hnext|exact Hr]); subst value end.
  eapply tpp_actual_node_store with
    (le := PTree.set TPP._t'3 (Vptr nb no) (PTree.set TPP._t'2 (Vptr pb po) le))
    (lhs := TPP._t'2) (rhs := TPP._t'3);
    [| |exact (proj1 (pac_node_layout version))|eassumption].
  - rewrite PTree.gso by discriminate. apply PTree.gss.
  - apply PTree.gss.
Qed.

Lemma tpp_actual_save_free : forall version e le before free obj old_free tr last after out,
  le ! TPP._obj = Some (tul_pointer obj) ->
  le ! TPP._freeList = Some (tul_pointer free) ->
  tpp_next_load before free = Some old_free ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le before
    tpp_save_free tr last after out ->
  Mem.store Mptr before (fst obj) (tpp_address obj 96) old_free = Some after.
Proof.
  intros version e le before [fb fo] [ob oo] old_free tr last after out Hobj Hfree Hhead Hrun.
  unfold tpp_save_free in Hrun.
  unfold ocn_exec, ClightBigstep.Clight2.exec_stmt in Hrun. cce_unroll_loop_free_exec.
  match goal with Hr : eval_expr _ _ _ _ (pac_read TPP._freeList TPP._next) ?value |- _ =>
    assert (value = old_free) by
      (eapply pac_read_field with (delta := 96);
       [exact Hfree|exact (proj1 (pac_node_layout version))|exact Hhead|exact Hr]);
    subst value end.
  eapply tpp_actual_node_store with
    (le := PTree.set TPP._t'1 old_free le) (lhs := TPP._obj) (rhs := TPP._t'1);
    [| |exact (proj1 (pac_node_layout version))|eassumption].
  - rewrite PTree.gso by discriminate. exact Hobj.
  - apply PTree.gss.
Qed.

Definition TPPEntryCellSeparation (free obj prev next : TULPointer) : Prop :=
  TPPCellSeparate obj 96 Mptr next 100 /\
  TPPCellSeparate obj 100 Mptr next 100 /\
  TPPCellSeparate free 96 Mptr next 100 /\
  TPPCellSeparate free 96 Mptr prev 96.

Lemma tpp_complete_deallocate_body_has_four_stores : forall version e le before
    free obj prev next old_free tr last after out,
  le ! TPP._freeList = Some (tul_pointer free) ->
  le ! TPP._obj = Some (tul_pointer obj) ->
  tpp_next_load before obj = Some (tul_pointer next) ->
  tpp_prev_load before obj = Some (tul_pointer prev) ->
  tpp_next_load before free = Some old_free ->
  TPPEntryCellSeparation free obj prev next ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le before
    (fn_body (tul_deallocate_function version)) tr last after out ->
  TPPDeallocationStores before after free obj prev next old_free.
Proof.
  intros version e le before free obj prev next old_free tr last after out
    Hfree Hobj Hnext Hprev Hhead (Hobjnext & Hobjprev & Hfreenext & Hfreeprev) Hrun.
  rewrite tpp_deallocator_source_exact in Hrun.
  destruct (ibk_split_sequence _ _ _ _ tpp_unlink_next _ _ _ _ _ eq_refl Hrun)
    as (le1 & m1 & t1 & r1 & Htr1 & Hstage1 & Hrest1).
  pose proof (tpp_actual_unlink_next _ _ _ _ _ _ _ _ _ _ _ Hobj Hnext Hprev Hstage1) as Hs1.
  assert (le1 ! TPP._obj = Some (tul_pointer obj)) as Hobj1.
  { rewrite (tul_actual_prefix_keeps_temp _ _ _ _ _ _ _ _ _ Hstage1 TPP._obj eq_refl). exact Hobj. }
  assert (le1 ! TPP._freeList = Some (tul_pointer free)) as Hfree1.
  { rewrite (tul_actual_prefix_keeps_temp _ _ _ _ _ _ _ _ _ Hstage1 TPP._freeList eq_refl). exact Hfree. }
  destruct (ibk_split_sequence _ _ _ _ tpp_unlink_prev _ _ _ _ _ eq_refl Hrest1)
    as (le2 & m2 & t2 & r2 & Htr2 & Hstage2 & Hrest2).
  assert (tpp_next_load m1 obj = Some (tul_pointer next)) as Hnext1.
  { unfold tpp_next_load. rewrite (tpp_store_preserves_separate_cell _ _ _ _ _ _ _ _ Hs1 Hobjnext). exact Hnext. }
  assert (tpp_prev_load m1 obj = Some (tul_pointer prev)) as Hprev1.
  { unfold tpp_prev_load. rewrite (tpp_store_preserves_separate_cell _ _ _ _ _ _ _ _ Hs1 Hobjprev). exact Hprev. }
  pose proof (tpp_actual_unlink_prev _ _ _ _ _ _ _ _ _ _ _ Hobj1 Hnext1 Hprev1 Hstage2) as Hs2.
  assert (le2 ! TPP._obj = Some (tul_pointer obj)) as Hobj2.
  { rewrite (tul_actual_prefix_keeps_temp _ _ _ _ _ _ _ _ _ Hstage2 TPP._obj eq_refl). exact Hobj1. }
  assert (le2 ! TPP._freeList = Some (tul_pointer free)) as Hfree2.
  { rewrite (tul_actual_prefix_keeps_temp _ _ _ _ _ _ _ _ _ Hstage2 TPP._freeList eq_refl). exact Hfree1. }
  assert (tpp_next_load m2 free = Some old_free) as Hhead2.
  { unfold tpp_next_load.
    rewrite (tpp_store_preserves_separate_cell _ _ _ _ _ _ _ _ Hs2 Hfreeprev).
    rewrite (tpp_store_preserves_separate_cell _ _ _ _ _ _ _ _ Hs1 Hfreenext). exact Hhead. }
  destruct (ibk_split_sequence _ _ _ _ tpp_save_free _ _ _ _ _ eq_refl Hrest2)
    as (le3 & m3 & t3 & r3 & Htr3 & Hstage3 & Hstage4).
  pose proof (tpp_actual_save_free _ _ _ _ _ _ _ _ _ _ _ Hobj2 Hfree2 Hhead2 Hstage3) as Hs3.
  assert (le3 ! TPP._obj = Some (tul_pointer obj)) as Hobj3.
  { rewrite (tul_actual_prefix_keeps_temp _ _ _ _ _ _ _ _ _ Hstage3 TPP._obj eq_refl). exact Hobj2. }
  assert (le3 ! TPP._freeList = Some (tul_pointer free)) as Hfree3.
  { rewrite (tul_actual_prefix_keeps_temp _ _ _ _ _ _ _ _ _ Hstage3 TPP._freeList eq_refl). exact Hfree2. }
  pose proof (tpp_actual_node_store _ _ _ _ _ _ _ 96 _ _ _ _ _ _
    Hfree3 Hobj3 (proj1 (pac_node_layout version)) Hstage4) as Hs4.
  exists m1, m2, m3. auto.
Qed.

Definition TPPCompleteDeallocationStores : Prop := forall version before
    free obj prev next old_free tr after result,
  tpp_next_load before obj = Some (tul_pointer next) ->
  tpp_prev_load before obj = Some (tul_pointer prev) ->
  tpp_next_load before free = Some old_free ->
  TPPEntryCellSeparation free obj prev next ->
  ClightBigstep.Clight2.eval_funcall
    (Clight.globalenv (selected_clight_target version)) before
    (Internal (tul_deallocate_function version)) [tul_pointer free; tul_pointer obj]
    tr after result ->
  TPPDeallocationStores before after free obj prev next old_free.

Theorem tpp_complete_deallocate_call_has_four_stores : TPPCompleteDeallocationStores.
Proof.
  intros version before [fb fo] [ob oo] prev next old_free tr after result
    Hnext Hprev Hhead Hseparate Hcall.
  destruct (tul_deallocate_source_cut version) as (_ & _ & _ & _ & Hvars & Hparams).
  inversion Hcall; subst.
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => inversion He; subst; clear He end.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
    rewrite Hvars in Ha; inversion Ha; subst; clear Ha end.
  match goal with Hfree : Mem.free_list ?m (blocks_of_env _ empty_env) = Some ?final |- _ =>
    change (Some m = Some final) in Hfree; inversion Hfree; subst end.
  match goal with Hb : bind_parameter_temps _ _ _ = Some ?temps |- _ =>
    rewrite Hparams in Hb; cbn [bind_parameter_temps] in Hb; inversion Hb; subst temps end.
  eapply tpp_complete_deallocate_body_has_four_stores; [| |exact Hnext|exact Hprev|exact Hhead|exact Hseparate|eassumption].
  - rewrite PTree.gso by discriminate. apply PTree.gss.
  - apply PTree.gss.
Qed.

Theorem tpp_deallocation_stores_preserve_cell : forall before after free obj prev next old_free
    reader delta chunk,
  TPPDeallocationStores before after free obj prev next old_free ->
  TPPCellSeparate reader delta chunk next 100 ->
  TPPCellSeparate reader delta chunk prev 96 ->
  TPPCellSeparate reader delta chunk obj 96 ->
  TPPCellSeparate reader delta chunk free 96 ->
  Mem.load chunk after (fst reader) (tpp_address reader delta) =
    Mem.load chunk before (fst reader) (tpp_address reader delta).
Proof.
  intros before after free obj prev next old_free reader delta chunk
    (m1 & m2 & m3 & Hs1 & Hs2 & Hs3 & Hs4) H1 H2 H3 H4.
  rewrite (tpp_store_preserves_separate_cell _ _ _ _ _ _ _ _ Hs4 H4).
  rewrite (tpp_store_preserves_separate_cell _ _ _ _ _ _ _ _ Hs3 H3).
  rewrite (tpp_store_preserves_separate_cell _ _ _ _ _ _ _ _ Hs2 H2).
  exact (tpp_store_preserves_separate_cell _ _ _ _ _ _ _ _ Hs1 H1).
Qed.

Definition TeleporterPoolPartitionBoundary : Prop := TPPCompleteDeallocationStores.
Theorem teleporter_pool_partition_checked : TeleporterPoolPartitionBoundary.
Proof. exact tpp_complete_deallocate_call_has_four_stores. Qed.
