(* ====================================================================== *)
(* PermWalk.v -- the generic PERMISSION frame of a Clight call             *)
(* (2026-10-26).                                                          *)
(*                                                                        *)
(* THEOREM (pk_body): a function whose body has no builtin and no switch, *)
(* and calls only listed functions by name (Evar of function type, not a  *)
(* local), each of which keeps permissions (PS), keeps them too: after    *)
(* the call every block valid before has exactly its old permissions, and *)
(* a block born during the call (a stack local, freed on return) has     *)
(* none.  Stores, allocation and the return's free_list do the rest;      *)
(* nothing about any particular program is assumed.                      *)
(*                                                                        *)
(* GOAL 2 uses it for the footprint relation LevelWalk.fx (whose second   *)
(* and third clauses are exactly PK), on the controller poll's call       *)
(* trees, whose leaves are the OS floor calls (OsDmaFloor: same_perms).   *)
(* ====================================================================== *)

From Coq Require Import ZArith List Bool.
From compcert Require Import Coqlib Maps AST Integers Values Memory Events
  Globalenvs Ctypes Cop Clight ClightBigstep.
Import ListNotations.
Local Open Scope Z_scope.

Definition inl_id (x : ident) (l : list ident) : bool := existsb (Pos.eqb x) l.

Lemma inl_id_In : forall x l, inl_id x l = true -> In x l.
Proof.
  intros x l H. apply existsb_exists in H as (y & Hy & E). apply Pos.eqb_eq in E. subst. exact Hy.
Qed.

Lemma inl_id_notin : forall x l, inl_id x l = false -> ~ In x l.
Proof.
  intros x l H Hin. assert (inl_id x l = true) by (apply existsb_exists; exists x; split; [ exact Hin | apply Pos.eqb_refl ]).
  congruence.
Qed.

(* the permission frame *)
Definition PK (m m' : mem) : Prop :=
  Ple (Mem.nextblock m) (Mem.nextblock m')
  /\ (forall b o k p, Mem.valid_block m b -> (Mem.perm m b o k p <-> Mem.perm m' b o k p))
  /\ (forall b o k p, ~ Mem.valid_block m b -> ~ Mem.perm m' b o k p).

Lemma PK_refl : forall m, PK m m.
Proof.
  intros m. split; [ apply Ple_refl | split; [ tauto | ] ].
  intros b o k p Hv Hp. exact (Hv (Mem.perm_valid_block _ _ _ _ _ Hp)).
Qed.

Lemma PK_trans : forall m1 m2 m3, PK m1 m2 -> PK m2 m3 -> PK m1 m3.
Proof.
  intros m1 m2 m3 (N1 & P1 & F1) (N2 & P2 & F2).
  split; [ exact (Ple_trans _ _ _ N1 N2) | split ].
  - intros b o k p Hv. rewrite (P1 b o k p Hv). apply P2.
    unfold Mem.valid_block in *. eapply Plt_Ple_trans; eassumption.
  - intros b o k p Hv Hp.
    destruct (plt b (Mem.nextblock m2)) as [V2 | V2].
    + apply (F1 b o k p Hv). apply (P2 b o k p V2). exact Hp.
    + exact (F2 b o k p V2 Hp).
Qed.

(* a memory with the same permissions everywhere *)
Lemma PK_same : forall m m', Mem.nextblock m' = Mem.nextblock m ->
  (forall b o k p, Mem.perm m' b o k p <-> Mem.perm m b o k p) -> PK m m'.
Proof.
  intros m m' N P. split; [ rewrite N; apply Ple_refl | split ].
  - intros b o k p _. rewrite P. tauto.
  - intros b o k p Hv Hp. apply P in Hp. exact (Hv (Mem.perm_valid_block _ _ _ _ _ Hp)).
Qed.

Lemma PK_store : forall ch m b z v m', Mem.store ch m b z v = Some m' -> PK m m'.
Proof.
  intros ch m b z v m' Hs. apply PK_same; [ exact (Mem.nextblock_store _ _ _ _ _ _ Hs) | ].
  intros b' o k p. split; [ eapply Mem.perm_store_2 | eapply Mem.perm_store_1 ]; eauto.
Qed.

Lemma PK_storebytes : forall m b z l m', Mem.storebytes m b z l = Some m' -> PK m m'.
Proof.
  intros m b z l m' Hs. apply PK_same; [ exact (Mem.nextblock_storebytes _ _ _ _ _ Hs) | ].
  intros b' o k p. split; [ eapply Mem.perm_storebytes_2 | eapply Mem.perm_storebytes_1 ]; eauto.
Qed.

Lemma PK_assign : forall ge ty m loc ofs bf v m', assign_loc ge ty m loc ofs bf v m' -> PK m m'.
Proof.
  intros ge ty m loc ofs bf v m' Ha. inv Ha.
  - match goal with H : Mem.storev _ _ _ _ = Some _ |- _ => exact (PK_store _ _ _ _ _ _ H) end.
  - match goal with H : Mem.storebytes _ _ _ _ = Some _ |- _ => exact (PK_storebytes _ _ _ _ _ H) end.
  - match goal with H : store_bitfield _ _ _ _ _ _ _ _ _ _ |- _ => inv H end.
    match goal with H : Mem.storev _ _ _ _ = Some _ |- _ => exact (PK_store _ _ _ _ _ _ H) end.
Qed.

(* ---------------------------------------------------------------------- *)
(* The checker.                                                            *)
(* ---------------------------------------------------------------------- *)
Fixpoint pk_chk (lv ids : list ident) (s : statement) : bool :=
  match s with
  | Sskip | Sassign _ _ | Sset _ _ | Sbreak | Scontinue | Sreturn _ => true
  | Scall _ (Evar fid (Tfunction _ _ _)) _ => negb (inl_id fid lv) && inl_id fid ids
  | Scall _ _ _ => false
  | Sbuiltin _ _ _ _ => false
  | Ssequence a b | Sifthenelse _ a b | Sloop a b => pk_chk lv ids a && pk_chk lv ids b
  | Sswitch _ _ => false
  | Slabel _ a => pk_chk lv ids a
  | Sgoto _ => true
  end.

Section PW.
  Variable ge : genv.

  (* a function that keeps permissions *)
  Definition PS (fd : fundef) : Prop :=
    forall m vargs t m' vres, eval_funcall function_entry2 ge m fd vargs t m' vres -> PK m m'.

  (* every listed name resolves only to such functions *)
  Definition psym (ids : list ident) : Prop :=
    forall id b fd, inl_id id ids = true -> Genv.find_symbol ge id = Some b ->
      Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd -> PS fd.

  Variable ids : list ident.
  Hypothesis Hids : psym ids.

  Lemma pk_stmt : forall lv e le m s t le' m' out,
      exec_stmt function_entry2 ge e le m s t le' m' out ->
      (forall x, inl_id x lv = false -> e ! x = None) ->
      pk_chk lv ids s = true -> PK m m'.
  Proof.
    intros lv e le m s t le' m' out H Hlv.
    induction H; intros Hc; cbn [pk_chk] in Hc;
      try (apply PK_refl); try discriminate Hc.
    - exact (PK_assign _ _ _ _ _ _ _ _ H2).
    - (* a call by name *)
      destruct a as [ | | | | fid fty | | | | | | | | | ]; try discriminate Hc.
      destruct fty as [ | | | | | | targs tres tcc | | ]; try discriminate Hc.
      apply andb_prop in Hc as [Hnl Hin]. apply negb_true_iff in Hnl.
      assert (Hx : exec_stmt function_entry2 ge e le m (Scall optid (Evar fid (Tfunction targs tres tcc)) al)
                     t (set_opttemp optid vres le) m' Out_normal)
        by (econstructor; eassumption).
      clear - Hx Hlv Hnl Hin Hids.
      inv Hx.
      match goal with Hev : eval_expr _ _ _ _ (Evar _ _) _ |- _ => inv Hev end.
      match goal with Hl : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inv Hl end.
      + match goal with He : e ! fid = Some _ |- _ => rewrite (Hlv fid Hnl) in He; discriminate He end.
      + match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => inv Hd end;
          try (match goal with Ha : access_mode _ = _ |- _ => cbn in Ha; discriminate Ha end).
        match goal with Hs : Genv.find_symbol _ fid = Some ?b, Hf : Genv.find_funct _ _ = Some ?fd,
                        Hc : eval_funcall _ _ _ ?fd _ _ _ _ |- _ =>
          exact (Hids fid b fd Hin Hs Hf _ _ _ _ _ Hc) end.
    - apply andb_prop in Hc as [A B]. exact (PK_trans _ _ _ (IHexec_stmt1 Hlv A) (IHexec_stmt2 Hlv B)).
    - apply andb_prop in Hc as [A _]. exact (IHexec_stmt Hlv A).
    - apply andb_prop in Hc as [A B]. apply IHexec_stmt; [ exact Hlv | ]. destruct b; assumption.
    - apply andb_prop in Hc as [A _]. exact (IHexec_stmt Hlv A).
    - apply andb_prop in Hc as [A B]. exact (PK_trans _ _ _ (IHexec_stmt1 Hlv A) (IHexec_stmt2 Hlv B)).
    - pose proof Hc as Hc'. apply andb_prop in Hc as [A B].
      exact (PK_trans _ _ _ (IHexec_stmt1 Hlv A) (PK_trans _ _ _ (IHexec_stmt2 Hlv B) (IHexec_stmt3 Hlv Hc'))).
  Qed.
End PW.

(* ---------------------------------------------------------------------- *)
(* Entry and return.                                                       *)
(* ---------------------------------------------------------------------- *)
Section ENV.
  Variable ge : genv.

  Lemma av_old : forall e0 m vars e m1, alloc_variables ge e0 m vars e m1 ->
    Ple (Mem.nextblock m) (Mem.nextblock m1)
    /\ forall b o k p, Mem.valid_block m b -> (Mem.perm m b o k p <-> Mem.perm m1 b o k p).
  Proof.
    intros e0 m vars e m1 H. induction H as [ | e0 m id ty vars0 m1 b1 m2 e2 Ha Hr (N & P) ].
    - split; [ apply Ple_refl | tauto ].
    - pose proof (Mem.nextblock_alloc _ _ _ _ _ Ha) as Na.
      split.
      + eapply Ple_trans; [ | exact N ]. rewrite Na. apply Ple_succ.
      + intros b o k p Hv.
        assert (Hv1 : Mem.valid_block m1 b) by exact (Mem.valid_block_alloc _ _ _ _ _ Ha _ Hv).
        rewrite <- (P b o k p Hv1).
        assert (Ne : b <> b1) by (intros ->; exact (Mem.fresh_block_alloc _ _ _ _ _ Ha Hv)).
        split; intros Hp;
          [ exact (Mem.perm_alloc_1 _ _ _ _ _ Ha _ _ _ _ Hp) | exact (Mem.perm_alloc_4 _ _ _ _ _ Ha _ _ _ _ Hp Ne) ].
  Qed.

  Lemma av_new : forall e0 m vars e m1 (N : block), alloc_variables ge e0 m vars e m1 ->
    list_norepet (var_names vars) ->
    (forall b o k p, ~ Plt b N -> Mem.perm m b o k p ->
       exists id ty, e0 ! id = Some (b, ty) /\ ~ In id (var_names vars) /\ 0 <= o < sizeof ge ty) ->
    forall b o k p, ~ Plt b N -> Mem.perm m1 b o k p ->
       exists id ty, e ! id = Some (b, ty) /\ 0 <= o < sizeof ge ty.
  Proof.
    intros e0 m vars e m1 N H. induction H as [ e0 m | e0 m id ty vars0 m1 b1 m2 e2 Ha Hr IH ];
      intros Hnr Hi.
    - intros b o k p Hn Hp. destruct (Hi b o k p Hn Hp) as (id & ty & E & _ & R). eauto.
    - cbn [var_names map] in Hnr. inv Hnr.
      apply IH; [ assumption | ].
      intros b o k p Hn Hp.
      destruct (peq b b1) as [-> | Ne].
      + exists id, ty. split; [ apply PTree.gss | split; [ assumption | ] ].
        pose proof (Mem.perm_alloc_3 _ _ _ _ _ Ha _ _ _ Hp) as R. exact R.
      + pose proof (Mem.perm_alloc_4 _ _ _ _ _ Ha _ _ _ _ Hp Ne) as Hp0.
        destruct (Hi b o k p Hn Hp0) as (id' & ty' & E & Nin & R).
        assert (Nid : id' <> id) by (intros ->; apply Nin; left; reflexivity).
        exists id', ty'. split; [ rewrite PTree.gso by exact Nid; exact E | split; [ | exact R ] ].
        intros Hin. apply Nin. right. exact Hin.
  Qed.

  Lemma av_fresh : forall e0 m vars e m1, alloc_variables ge e0 m vars e m1 ->
    forall id b ty, e ! id = Some (b, ty) -> e0 ! id = Some (b, ty) \/ ~ Mem.valid_block m b.
  Proof.
    intros e0 m vars e m1 H. induction H as [ | e0 m id ty vars0 m1 b1 m2 e2 Ha Hr IH ];
      intros x b t Hx; [ left; exact Hx | ].
    destruct (IH x b t Hx) as [E | Nv].
    - destruct (peq x id) as [-> | Ne].
      + rewrite PTree.gss in E. injection E as <- <-. right.
        exact (Mem.fresh_block_alloc _ _ _ _ _ Ha).
      + rewrite PTree.gso in E by exact Ne. left. exact E.
    - right. intros V. apply Nv. exact (Mem.valid_block_alloc _ _ _ _ _ Ha _ V).
  Qed.

  Lemma av_unbound : forall e0 m vars e m1, alloc_variables ge e0 m vars e m1 ->
    forall x, ~ In x (var_names vars) -> e ! x = e0 ! x.
  Proof.
    intros e0 m vars e m1 H. induction H as [ | e0 m id ty vars0 m1 b1 m2 e2 Ha Hr IH ];
      intros x Hx; [ reflexivity | ].
    rewrite IH by (intros Hin; apply Hx; right; exact Hin).
    apply PTree.gso. intros ->. apply Hx. left. reflexivity.
  Qed.

  Lemma fl_back : forall l m m' b o k p, Mem.free_list m l = Some m' ->
    Mem.perm m' b o k p -> Mem.perm m b o k p.
  Proof.
    induction l as [ | [[b0 lo] hi] l IH ]; intros m m' b o k p Hf Hp; cbn in Hf.
    - injection Hf as <-. exact Hp.
    - destruct (Mem.free m b0 lo hi) as [m1|] eqn:E; [ | discriminate Hf ].
      exact (Mem.perm_free_3 _ _ _ _ _ E _ _ _ _ (IH _ _ _ _ _ _ Hf Hp)).
  Qed.

  Lemma fl_kill : forall l m m' b lo hi o k p, Mem.free_list m l = Some m' ->
    In (b, lo, hi) l -> lo <= o < hi -> ~ Mem.perm m' b o k p.
  Proof.
    induction l as [ | [[b0 lo0] hi0] l IH ]; intros m m' b lo hi o k p Hf Hin Ho Hp; cbn in Hf.
    - destruct Hin.
    - destruct (Mem.free m b0 lo0 hi0) as [m1|] eqn:E; [ | discriminate Hf ].
      destruct Hin as [Eq | Hin].
      + injection Eq as -> -> ->.
        exact (Mem.perm_free_2 _ _ _ _ _ E o k p Ho (fl_back _ _ _ _ _ _ _ Hf Hp)).
      + exact (IH _ _ _ _ _ _ _ _ Hf Hin Ho Hp).
  Qed.

  Lemma fl_keep : forall l m m' b o k p, Mem.free_list m l = Some m' ->
    (forall lo hi, ~ In (b, lo, hi) l) -> Mem.perm m b o k p -> Mem.perm m' b o k p.
  Proof.
    induction l as [ | [[b0 lo0] hi0] l IH ]; intros m m' b o k p Hf Hn Hp; cbn in Hf.
    - injection Hf as <-. exact Hp.
    - destruct (Mem.free m b0 lo0 hi0) as [m1|] eqn:E; [ | discriminate Hf ].
      apply (IH m1 m' b o k p Hf); [ intros lo hi Hin; exact (Hn lo hi (or_intror Hin)) | ].
      eapply Mem.perm_free_1; [ exact E | | exact Hp ].
      left. intros ->. exact (Hn lo0 hi0 (or_introl eq_refl)).
  Qed.

  Lemma fl_next : forall l m m', Mem.free_list m l = Some m' -> Mem.nextblock m' = Mem.nextblock m.
  Proof.
    induction l as [ | [[b0 lo0] hi0] l IH ]; intros m m' Hf; cbn in Hf.
    - injection Hf as <-. reflexivity.
    - destruct (Mem.free m b0 lo0 hi0) as [m1|] eqn:E; [ | discriminate Hf ].
      rewrite (IH _ _ Hf). exact (Mem.nextblock_free _ _ _ _ _ E).
  Qed.

  Lemma boe_in : forall e id b ty, e ! id = Some (b, ty) -> In (b, 0, sizeof ge ty) (blocks_of_env ge e).
  Proof.
    intros e id b ty H. unfold blocks_of_env. apply in_map_iff.
    exists (id, (b, ty)). split; [ reflexivity | exact (PTree.elements_correct _ _ H) ].
  Qed.

  Lemma boe_inv : forall e b lo hi, In (b, lo, hi) (blocks_of_env ge e) ->
    exists id ty, e ! id = Some (b, ty).
  Proof.
    intros e b lo hi H. unfold blocks_of_env in H. apply in_map_iff in H as ([id [b' ty]] & E & Hin).
    cbn in E. injection E as -> _ _. exists id, ty. exact (PTree.elements_complete _ _ _ Hin).
  Qed.
End ENV.

Section BODY.
  Variable ge : genv.
  Variable ids : list ident.
  Hypothesis Hids : psym ge ids.

  (* THE THEOREM *)
  Theorem pk_body : forall f,
      pk_chk (var_names (fn_vars f)) ids (fn_body f) = true -> PS ge (Internal f).
  Proof.
    intros f Hc m vargs t m' vres Hev.
    inv Hev.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => inv He end.
    match goal with
    | Hav : alloc_variables _ _ _ _ ?E ?M1,
      Hbody : exec_stmt _ _ ?E _ ?M1 _ _ _ ?M2 _,
      Hfree : Mem.free_list ?M2 _ = Some _ |- _ =>
      rename Hav into Av; rename Hbody into Hb; rename Hfree into Hf;
      remember E as ee eqn:Eee; remember M1 as mm1 eqn:Em1; remember M2 as mm2 eqn:Em2
    end.
    clear Eee Em1 Em2.
    destruct (av_old ge _ _ _ _ _ Av) as (N1 & P1).
    assert (Hlv : forall x, inl_id x (var_names (fn_vars f)) = false -> ee ! x = None).
    { intros x Hx. rewrite (av_unbound ge _ _ _ _ _ Av x (inl_id_notin _ _ Hx)). apply PTree.gempty. }
    destruct (pk_stmt ge ids Hids _ _ _ _ _ _ _ _ _ Hb Hlv Hc) as (N2 & P2 & F2).
    assert (Fr : forall id b ty, ee ! id = Some (b, ty) -> ~ Mem.valid_block m b).
    { intros id b ty He. destruct (av_fresh ge _ _ _ _ _ Av id b ty He) as [E0 | Nv];
        [ rewrite PTree.gempty in E0; discriminate E0 | exact Nv ]. }
    split; [ | split ].
    - rewrite (fl_next _ _ _ Hf). exact (Ple_trans _ _ _ N1 N2).
    - intros b o k p Hv.
      assert (Hv1 : Mem.valid_block mm1 b) by (unfold Mem.valid_block in *; eapply Plt_Ple_trans; eassumption).
      rewrite (P1 b o k p Hv), (P2 b o k p Hv1).
      split; [ | exact (fl_back _ _ _ _ _ _ _ Hf) ].
      apply (fl_keep _ _ _ _ _ _ _ Hf).
      intros lo hi Hin. destruct (boe_inv ge _ _ _ _ Hin) as (id & ty & He). exact (Fr id b ty He Hv).
    - intros b o k p Hv Hp.
      pose proof (fl_back _ _ _ _ _ _ _ Hf Hp) as Hp2.
      destruct (plt b (Mem.nextblock mm1)) as [V1 | V1]; [ | exact (F2 b o k p V1 Hp2) ].
      apply (P2 b o k p V1) in Hp2.
      destruct (av_new ge _ _ _ _ _ (Mem.nextblock m) Av ltac:(assumption)
                  ltac:(intros b0 o0 k0 p0 Hn Hp0; exfalso; exact (Hn (Mem.perm_valid_block _ _ _ _ _ Hp0)))
                  b o k p Hv Hp2) as (id & ty & He & R).
      exact (fl_kill _ _ _ _ _ _ _ _ _ Hf (boe_in ge _ _ _ _ He) R Hp).
  Qed.
End BODY.

(* an external call that keeps every permission and the block count *)
Lemma PS_external : forall (ge : genv) ef targs tres cc,
  (forall vargs m t vres m', external_call ef ge vargs m t vres m' ->
     Mem.nextblock m' = Mem.nextblock m /\ (forall b o k p, Mem.perm m' b o k p <-> Mem.perm m b o k p)) ->
  PS ge (External ef targs tres cc).
Proof.
  intros ge ef targs tres cc H m vargs t m' vres Hev. inv Hev.
  match goal with Hx : external_call _ _ _ _ _ _ _ |- _ => destruct (H _ _ _ _ _ Hx) as (N & P) end.
  exact (PK_same _ _ N P).
Qed.
