(* kept: general tool -- frame facts for runs of the sound Clight interpreter
   (ClightInterp), and computable memory comparisons.

   - [ex_keep]: a finished interpreter run never changes the permissions of a
     block that was valid when it started (its own stack frames are fresh
     blocks, freed on return), and never shrinks nextblock -- provided the
     oracle's answers do neither.  Stated on the access map itself, so loads
     and permissions of an old block in the final memory are decided by its
     contents alone.
   - [blk_eqb]: a computable test that two memories hold the same bytes in a
     block; with [ex_keep] it gives load equality ([load_same]).
   - [blk_ptrs]: a computable test that every pointer fragment stored in a
     block (at ANY offset, so whatever a load reads) aims at a block accepted
     by a boolean filter. *)

From Coq Require Import List Lia.
From compcert Require Import Coqlib Maps Integers Floats Values AST Memory Memdata Events
  Globalenvs Ctypes Cop Clight.
From SM64.Proofs Require Import Interp.ClightInterp.
From SM64.Proofs Require Interp.CMem.
Module CM := SM64.Proofs.Interp.CMem.
Import ListNotations.
Arguments Done {A}.
Arguments Stuck {A}.

(* ---------------------------------------------------------------------- *)
(* Access maps of old blocks                                               *)
(* ---------------------------------------------------------------------- *)
Definition acc_keep (m m' : mem) : Prop :=
  Ple (Mem.nextblock m) (Mem.nextblock m')
  /\ forall b, Plt b (Mem.nextblock m) -> (Mem.mem_access m') !! b = (Mem.mem_access m) !! b.

Lemma acc_keep_refl : forall m, acc_keep m m.
Proof. intros m. split; [ apply Ple_refl | reflexivity ]. Qed.

Lemma acc_keep_trans : forall m1 m2 m3, acc_keep m1 m2 -> acc_keep m2 m3 -> acc_keep m1 m3.
Proof.
  intros m1 m2 m3 [N1 A1] [N2 A2]. split; [ eapply Ple_trans; eauto | ].
  intros b Hb. rewrite A2 by (eapply Plt_Ple_trans; eauto). apply A1; exact Hb.
Qed.

Lemma store_raw_keep : forall m b ofs l, acc_keep m (CM.store_raw m b ofs l).
Proof. intros. split; [ apply Ple_refl | intros; reflexivity ]. Qed.

Lemma cm_store_keep : forall ch m b ofs v m', CM.store ch m b ofs v = Some m' -> acc_keep m m'.
Proof.
  intros ch m b ofs v m' H. unfold CM.store in H.
  destruct (CM.valid_access_b _ _ _ _ _); [ injection H as <-; apply store_raw_keep | discriminate ].
Qed.

Lemma cm_storev_keep : forall ch m a v m', CM.storev ch m a v = Some m' -> acc_keep m m'.
Proof. intros ch m a v m' H. destruct a; try discriminate. exact (cm_store_keep _ _ _ _ _ _ H). Qed.

Lemma cm_storebytes_keep : forall m b ofs l m', CM.storebytes m b ofs l = Some m' -> acc_keep m m'.
Proof.
  intros m b ofs l m' H. unfold CM.storebytes in H.
  destruct (CM.range_perm_b _ _ _ _ _ _); [ injection H as <-; apply store_raw_keep | discriminate ].
Qed.

Section TR_ALLOC.
Local Transparent Mem.alloc.
Lemma alloc_keep : forall m lo hi m' b, Mem.alloc m lo hi = (m', b) -> acc_keep m m'.
Proof.
  intros m lo hi m' b H.
  split.
  - rewrite (Mem.nextblock_alloc _ _ _ _ _ H). apply Ple_succ.
  - intros b' Hb'. unfold Mem.alloc in H. injection H as <- _. cbn [Mem.mem_access].
    rewrite PMap.gso; [ reflexivity | ]. intro E. subst b'. exact (Plt_strict _ Hb').
Qed.

End TR_ALLOC.

Lemma alloc_keep_new : forall m lo hi m' b, Mem.alloc m lo hi = (m', b) -> b = Mem.nextblock m.
Proof. intros m lo hi m' b H. exact (Mem.alloc_result _ _ _ _ _ H). Qed.

Section GE.
Variable ge : genv.

Lemma ev_assign_keep : forall ty m b ofs bf v m',
    ev_assign ge ty m b ofs bf v = Some m' -> acc_keep m m'.
Proof.
  intros ty m b ofs bf v m' H. unfold ev_assign in H.
  destruct bf; [ | discriminate ].
  destruct (access_mode ty); try discriminate.
  - exact (cm_storev_keep _ _ _ _ _ H).
  - destruct v; try discriminate.
    destruct (copy_ok ge ty b ofs b0 i); [ | discriminate ].
    destruct (CM.loadbytes m b0 (Ptrofs.unsigned i) (sizeof ge ty)); [ | discriminate ].
    exact (cm_storebytes_keep _ _ _ _ _ H).
Qed.

Lemma ev_alloc_keep : forall vars e m e' m', ev_alloc ge e m vars = (e', m') ->
    acc_keep m m'
    /\ forall id b ty, e' ! id = Some (b, ty) -> e ! id = Some (b, ty) \/ Ple (Mem.nextblock m) b.
Proof.
  induction vars as [| [id ty] vars IH]; intros e m e' m' H; cbn in H.
  - injection H as <- <-. split; [ apply acc_keep_refl | left; exact H ].
  - destruct (Mem.alloc m 0 (sizeof ge ty)) as [m1 b1] eqn:A.
    destruct (IH _ _ _ _ H) as (K & B).
    pose proof (alloc_keep _ _ _ _ _ A) as K1.
    split; [ exact (acc_keep_trans _ _ _ K1 K) | ].
    intros id' b ty' Hg. destruct (B _ _ _ Hg) as [Hs | Hle].
    + rewrite PTree.gsspec in Hs. destruct (peq id' id).
      * injection Hs as <- _. right. rewrite (alloc_keep_new _ _ _ _ _ A). apply Ple_refl.
      * left; exact Hs.
    + right. eapply Ple_trans; [ | exact Hle ]. exact (proj1 K1).
Qed.

Lemma ev_entry_keep : forall f vargs m e le m1, ev_entry ge f vargs m = Some (e, le, m1) ->
    acc_keep m m1 /\ forall id b ty, e ! id = Some (b, ty) -> Ple (Mem.nextblock m) b.
Proof.
  intros f vargs m e le m1 H. unfold ev_entry in H.
  destruct (list_norepet_dec _ _); [ | discriminate ].
  destruct (list_norepet_dec _ _); [ | discriminate ].
  destruct (list_disjoint_dec _ _ _); [ | discriminate ].
  destruct (ev_alloc ge empty_env m (fn_vars f)) as [e0 m0] eqn:A.
  destruct (bind_parameter_temps _ _ _); [ | discriminate ].
  injection H as <- _ <-.
  destruct (ev_alloc_keep _ _ _ _ _ A) as (K & B). split; [ exact K | ].
  intros id b ty Hg. destruct (B _ _ _ Hg) as [Hs | Hle]; [ rewrite PTree.gempty in Hs; discriminate | exact Hle ].
Qed.

Section TR_FREE.
Local Transparent Mem.unchecked_free.
Lemma cm_free_list_keep : forall l m m' N, CM.free_list m l = Some m' ->
    (forall b lo hi, In (b, lo, hi) l -> Ple N b) ->
    Mem.nextblock m' = Mem.nextblock m
    /\ forall b, Plt b N -> (Mem.mem_access m') !! b = (Mem.mem_access m) !! b.
Proof.
  induction l as [| [[b0 lo] hi] l IH]; intros m m' N H Hin; cbn in H.
  - injection H as <-. split; reflexivity.
  - destruct (CM.free m b0 lo hi) as [m1|] eqn:F; [ | discriminate ].
    destruct (IH _ _ N H (fun b lo' hi' I => Hin b lo' hi' (or_intror I))) as (Nb & A).
    unfold CM.free in F. destruct (CM.range_perm_b _ _ _ _ _ _); [ | discriminate ].
    injection F as <-.
    split; [ rewrite Nb; reflexivity | ].
    intros b Hb. rewrite A by exact Hb. unfold Mem.unchecked_free. cbn [Mem.mem_access].
    rewrite PMap.gso; [ reflexivity | ].
    intro E. subst b. pose proof (Hin b0 lo hi (or_introl eq_refl)) as Hle.
    exact (Plt_strict _ (Plt_Ple_trans _ _ _ Hb Hle)).
Qed.

End TR_FREE.

Lemma blocks_of_env_in : forall e b lo hi, In (b, lo, hi) (blocks_of_env ge e) ->
    exists id ty, e ! id = Some (b, ty).
Proof.
  intros e b lo hi H. unfold blocks_of_env in H. apply list_in_map_inv in H.
  destruct H as ([id [bb ty]] & Heq & Hin). unfold block_of_binding in Heq.
  injection Heq as -> _ _. exists id, ty. exact (PTree.elements_complete _ _ _ Hin).
Qed.

Variable extcall : external_function -> list val -> mem -> option (trace * val * mem).
Hypothesis ext_keep : forall ef vargs m t v m', extcall ef vargs m = Some (t, v, m') -> acc_keep m m'.

Theorem ex_keep : forall fuel,
    (forall e le m s t le' m' out,
        ex_stmt ge extcall fuel e le m s = Done (t, le', m', out) -> acc_keep m m') /\
    (forall m f vargs t m' vres,
        ex_call ge extcall fuel m f vargs = Done (t, m', vres) -> acc_keep m m').
Proof.
  induction fuel as [|fuel IH]; split; intros; simpl in H; try discriminate;
    destruct IH as [IHs IHc].
  - destruct s; simpl in H; try discriminate.
    + inv H. apply acc_keep_refl.
    + destruct (need (ev_lvalue ge e le m e0) _ _) as [[[loc ofs] bf]| ? ? ?]; [ | discriminate].
      destruct (need (ev_expr ge e le m e1) _ _) as [v2| ? ? ?]; [ | discriminate].
      destruct (need (sem_cast v2 _ _ m) _ _) as [v| ? ? ?]; [ | discriminate].
      destruct (need (ev_assign ge _ m loc ofs bf v) _ _) as [m1| ? ? ?] eqn:Has; [ | discriminate].
      apply need_ok in Has. inv H. exact (ev_assign_keep _ _ _ _ _ _ _ Has).
    + destruct (need (ev_expr ge e le m e0) _ _) as [v| ? ? ?]; [ | discriminate].
      inv H. apply acc_keep_refl.
    + destruct (classify_fun (typeof e0)) as [tyargs tyres cconv| ]; try discriminate.
      destruct (need (ev_expr ge e le m e0) _ _) as [vf| ? ? ?]; [ | discriminate].
      destruct (need (ev_exprlist ge e le m l tyargs) _ _) as [vargs| ? ? ?]; [ | discriminate].
      destruct (need (Genv.find_funct ge vf) _ _) as [f| ? ? ?]; [ | discriminate].
      destruct (type_eq (type_of_fundef f) (Tfunction tyargs tyres cconv)); [ | discriminate].
      destruct (ex_call ge extcall fuel m f vargs) as [[[t0 m1] vres]| ? ? ?] eqn:Hcall; [ | discriminate].
      inv H. exact (IHc _ _ _ _ _ _ Hcall).
    + destruct (need (ev_exprlist ge e le m l0 l) _ _) as [vargs| ? ? ?]; [ | discriminate].
      destruct (extcall e0 vargs m) as [[[t0 vres] m1]|] eqn:Hx; [ | discriminate].
      inv H. exact (ext_keep _ _ _ _ _ _ Hx).
    + destruct (ex_stmt ge extcall fuel e le m s1) as [[[[t1 le1] m1] out1]| ? ? ?] eqn:H1; [ | discriminate].
      pose proof (IHs _ _ _ _ _ _ _ _ H1) as K1.
      destruct out1; try (inv H; exact K1).
      destruct (ex_stmt ge extcall fuel e le1 m1 s2) as [[[[t2 le2] m2] out2]| ? ? ?] eqn:H2; [ | discriminate].
      inv H. exact (acc_keep_trans _ _ _ K1 (IHs _ _ _ _ _ _ _ _ H2)).
    + destruct (need (ev_expr ge e le m e0) _ _) as [v1| ? ? ?]; [ | discriminate].
      destruct (need (bool_val v1 (typeof e0) m) _ _) as [b| ? ? ?]; [ | discriminate].
      exact (IHs _ _ _ _ _ _ _ _ H).
    + destruct (ex_stmt ge extcall fuel e le m s1) as [[[[t1 le1] m1] out1]| ? ? ?] eqn:H1; [ | discriminate].
      pose proof (IHs _ _ _ _ _ _ _ _ H1) as K1.
      destruct out1;
        try (inv H; exact K1);
        (destruct (ex_stmt ge extcall fuel e le1 m1 s2) as [[[[t2 le2] m2] out2]| ? ? ?] eqn:H2; [ | discriminate];
         pose proof (IHs _ _ _ _ _ _ _ _ H2) as K2;
         destruct out2; try discriminate;
         [ inv H; exact (acc_keep_trans _ _ _ K1 K2)
         | destruct (ex_stmt ge extcall fuel e le2 m2 (Sloop s1 s2)) as [[[[t3 le3] m3] out3]| ? ? ?] eqn:H3;
             [ | discriminate];
           inv H; exact (acc_keep_trans _ _ _ K1 (acc_keep_trans _ _ _ K2 (IHs _ _ _ _ _ _ _ _ H3)))
         | inv H; exact (acc_keep_trans _ _ _ K1 K2) ]).
    + inv H. apply acc_keep_refl.
    + inv H. apply acc_keep_refl.
    + destruct o as [a|].
      * destruct (need (ev_expr ge e le m a) _ _) as [v| ? ? ?]; [ | discriminate].
        inv H. apply acc_keep_refl.
      * inv H. apply acc_keep_refl.
    + destruct (need (ev_expr ge e le m e0) _ _) as [v| ? ? ?]; [ | discriminate].
      destruct (need (sem_switch_arg v (typeof e0)) _ _) as [n| ? ? ?]; [ | discriminate].
      destruct (ex_stmt ge extcall fuel e le m (seq_of_labeled_statement (select_switch n l)))
        as [[[[t1 le1] m1] out1]| ? ? ?] eqn:H1; [ | discriminate].
      inv H. exact (IHs _ _ _ _ _ _ _ _ H1).
  - destruct f as [fn | ef targs tres cconv].
    + destruct (need (ev_entry ge fn vargs m) _ _) as [[[e le1] m1]| ? ? ?] eqn:Hen; [ | discriminate].
      destruct (ex_stmt ge extcall fuel e le1 m1 (fn_body fn)) as [[[[t1 le2] m2] out]| ? ? ?] eqn:Hb;
        [ | discriminate].
      destruct (need (ev_result out (fn_return fn) m2) _ _) as [v| ? ? ?]; [ | discriminate].
      destruct (need (CM.free_list m2 (blocks_of_env ge e)) _ _) as [m3| ? ? ?] eqn:Hfr;
        [ | discriminate].
      apply need_ok in Hen. apply need_ok in Hfr. inv H.
      destruct (ev_entry_keep _ _ _ _ _ _ Hen) as (K1 & Fr).
      pose proof (IHs _ _ _ _ _ _ _ _ Hb) as K2.
      destruct (cm_free_list_keep _ _ _ (Mem.nextblock m) Hfr) as (Nb & A3).
      { intros b lo hi Hin. destruct (blocks_of_env_in _ _ _ _ Hin) as (id & ty & Hg). exact (Fr _ _ _ Hg). }
      pose proof (acc_keep_trans _ _ _ K1 K2) as (N12 & A12).
      split; [ rewrite Nb; exact N12 | ].
      intros b Hb'. rewrite (A3 b Hb'). exact (A12 b Hb').
    + destruct (extcall ef vargs m) as [[[t0 v] m1]|] eqn:Hx; [ | discriminate].
      inv H. exact (ext_keep _ _ _ _ _ _ Hx).
Qed.

Corollary ex_call_keep : forall fuel m f vargs t m' vres,
    ex_call ge extcall fuel m f vargs = Done (t, m', vres) -> acc_keep m m'.
Proof. intros. exact (proj2 (ex_keep fuel) _ _ _ _ _ _ H). Qed.

End GE.

(* ---------------------------------------------------------------------- *)
(* Same access, same bytes: same loads and permissions                     *)
(* ---------------------------------------------------------------------- *)
Lemma getN_ext : forall n p (c1 c2 : ZMap.t memval),
    (forall z, ZMap.get z c1 = ZMap.get z c2) -> Mem.getN n p c1 = Mem.getN n p c2.
Proof.
  induction n as [| n IH]; intros p c1 c2 H; cbn; [ reflexivity | ].
  rewrite H, (IH (p + 1) c1 c2 H). reflexivity.
Qed.

Lemma perm_same : forall m m' b z k p,
    (Mem.mem_access m) !! b = (Mem.mem_access m') !! b ->
    Mem.perm m b z k p <-> Mem.perm m' b z k p.
Proof. intros m m' b z k p E. unfold Mem.perm. rewrite E. tauto. Qed.

Section TR_LOAD.
Local Transparent Mem.load.
Lemma load_same : forall ch m m' b z,
    (Mem.mem_access m) !! b = (Mem.mem_access m') !! b ->
    (forall o, ZMap.get o ((Mem.mem_contents m) !! b) = ZMap.get o ((Mem.mem_contents m') !! b)) ->
    Mem.load ch m b z = Mem.load ch m' b z.
Proof.
  intros ch m m' b z Ea Ec.
  assert (V : Mem.valid_access m ch b z Readable <-> Mem.valid_access m' ch b z Readable).
  { unfold Mem.valid_access, Mem.range_perm.
    split; intros (R & Al); (split; [ | exact Al ]); intros o Ho;
      [ apply (perm_same m m' b o Cur Readable Ea) | apply (perm_same m m' b o Cur Readable Ea) ];
      apply R; exact Ho. }
  unfold Mem.load.
  destruct (Mem.valid_access_dec m ch b z Readable) as [H1 | H1];
    destruct (Mem.valid_access_dec m' ch b z Readable) as [H2 | H2]; try tauto.
  rewrite (getN_ext _ _ _ _ Ec). reflexivity.
Qed.

End TR_LOAD.

(* ---------------------------------------------------------------------- *)
(* Computable comparisons of a block's bytes                               *)
(* ---------------------------------------------------------------------- *)
Definition quantity_eqb (q1 q2 : quantity) : bool :=
  match q1, q2 with Q32, Q32 | Q64, Q64 => true | _, _ => false end.

Definition memval_eqb (a b : memval) : bool :=
  match a, b with
  | Undef, Undef => true
  | Byte x, Byte y => if Byte.eq_dec x y then true else false
  | Fragment v q n, Fragment v' q' n' =>
      (if Val.eq v v' then true else false) && quantity_eqb q q' && Nat.eqb n n'
  | _, _ => false
  end.

Lemma memval_eqb_eq : forall a b, memval_eqb a b = true -> a = b.
Proof.
  intros [| x | v q n] [| y | v' q' n'] H; cbn in H; try discriminate; try reflexivity.
  - destruct (Byte.eq_dec x y); [ subst; reflexivity | discriminate ].
  - destruct (Val.eq v v'); [ subst | discriminate ].
    apply andb_prop in H as [H1 H2]. apply Nat.eqb_eq in H2. subst.
    destruct q, q'; cbn in H1; congruence.
Qed.

Definition blk_eqb (c1 c2 : ZMap.t memval) : bool :=
  memval_eqb (fst c1) (fst c2) && PTree.beq memval_eqb (snd c1) (snd c2).

Lemma blk_eqb_get : forall c1 c2, blk_eqb c1 c2 = true -> forall o, ZMap.get o c1 = ZMap.get o c2.
Proof.
  intros [d1 t1] [d2 t2] H o. unfold blk_eqb in H. cbn [fst snd] in H.
  apply andb_prop in H as [Hd Ht]. apply memval_eqb_eq in Hd. subst d2.
  rewrite PTree.beq_correct in Ht. specialize (Ht (ZIndexed.index o)).
  unfold ZMap.get, PMap.get. cbn [fst snd].
  destruct (t1 ! (ZIndexed.index o)), (t2 ! (ZIndexed.index o)); try contradiction; try reflexivity.
  f_equal. exact (memval_eqb_eq _ _ Ht).
Qed.

(* every pointer fragment of a block aims at an accepted block *)
Definition mv_ok (ok : block -> bool) (mv : memval) : bool :=
  match mv with Fragment (Vptr b _) _ _ => ok b | _ => true end.

Definition blk_ptrs (ok : block -> bool) (c : ZMap.t memval) : bool :=
  mv_ok ok (fst c) && forallb (fun p => mv_ok ok (snd p)) (PTree.elements (snd c)).

Lemma blk_ptrs_get : forall ok c, blk_ptrs ok c = true -> forall o, mv_ok ok (ZMap.get o c) = true.
Proof.
  intros ok [d t] H o. unfold blk_ptrs in H. cbn [fst snd] in H.
  apply andb_prop in H as [Hd Ht]. rewrite forallb_forall in Ht.
  unfold ZMap.get, PMap.get. cbn [fst snd].
  destruct (t ! (ZIndexed.index o)) as [x|] eqn:E; [ | exact Hd ].
  exact (Ht _ (PTree.elements_correct _ _ E)).
Qed.

(* a pointer an Mint32 load reads is the fragment stored at its offset *)
Section TR_PTR.
Local Transparent Archi.ptr64.
Lemma load_ptr_frag : forall m b z b' o',
    Mem.load Mint32 m b z = Some (Vptr b' o') ->
    exists q n, ZMap.get z ((Mem.mem_contents m) !! b) = Fragment (Vptr b' o') q n.
Proof.
  intros m b z b' o' H. apply Mem.load_result in H.
  change (size_chunk_nat Mint32) with 4%nat in H.
  unfold decode_val in H. cbn [Mem.getN] in H.
  destruct (ZMap.get z (Mem.mem_contents m) !! b) as [| x | v q n] eqn:E.
  - cbn in H. discriminate.
  - cbn in H. repeat (match type of H with context [match ?x with _ => _ end] => destruct x end);
      discriminate.
  - cbn [proj_bytes] in H. unfold proj_value in H.
    match type of H with context [check_value ?a ?b ?c ?d] => destruct (check_value a b c d) end;
      [ | cbn in H; discriminate ].
    destruct v; cbn in H; try discriminate.
    injection H as -> ->. exists q, n. reflexivity.
Qed.
End TR_PTR.

Lemma load_ptr_ok : forall ok m b z b' o',
    (forall o, mv_ok ok (ZMap.get o ((Mem.mem_contents m) !! b)) = true) ->
    Mem.load Mint32 m b z = Some (Vptr b' o') -> ok b' = true.
Proof.
  intros ok m b z b' o' H L. destruct (load_ptr_frag _ _ _ _ _ L) as (q & n & E).
  specialize (H z). rewrite E in H. exact H.
Qed.
