(* ====================================================================== *)
(* ClightClosed: a Clight big-step execution keeps memory closed.           *)
(*                                                                          *)
(* closed_by g m (ClosedMem) says the g-mapped blocks are pointer-closed.   *)
(* THEOREM (funcall_closed): if m is closed by g, every global symbol is    *)
(* g-mapped and the arguments are g-values, then after ANY big-step call   *)
(* (function_entry2, the semantics the frame relations use) the final       *)
(* memory is closed by some g' extending g and the result is a g'-value.    *)
(* Locals are made public at allocation; external calls and builtins go    *)
(* through ext_call_closed, i.e. CompCert's own axioms.  Nothing about any *)
(* particular program is assumed: this is a fact of the semantics.         *)
(* ====================================================================== *)

From Coq Require Import ZArith List Classical_Prop.
From compcert Require Import Coqlib Maps AST Integers Floats Values Memory Events
  Globalenvs Ctypes Cop Clight ClightBigstep.
From SM64.Proofs Require Import Generic.ClosedMem.
Import ListNotations.

Definition vok (g : meminj) (v : val) : Prop := Val.inject g v v.

Lemma vok_incr : forall g g' v, inject_incr g g' -> vok g v -> vok g' v.
Proof. intros g g' v I H. exact (val_inject_incr _ _ _ _ I H). Qed.

Lemma closed_mapped_flat : forall g m b, closed_by g m -> g b <> None -> g b = Some (b, 0).
Proof.
  intros g m b (Hflat & _) H. destruct (g b) as [[b' d]|] eqn:G; [| congruence].
  destruct (Hflat _ _ _ G) as (-> & ->). reflexivity.
Qed.

Lemma vok_ptr : forall g m b o, closed_by g m -> vok g (Vptr b o) -> g b = Some (b, 0).
Proof.
  intros g m b o Hc H. inv H. apply (closed_mapped_flat _ m); [exact Hc | congruence].
Qed.

Lemma vok_mk_ptr : forall g b o, g b = Some (b, 0) -> vok g (Vptr b o).
Proof. intros g b o H. econstructor; [exact H | rewrite Ptrofs.add_zero; reflexivity]. Qed.

Lemma vok_load : forall g m ch b z v, closed_by g m -> g b <> None ->
  Mem.load ch m b z = Some v -> vok g v.
Proof.
  intros g m ch b z v Hc Hb Hl. pose proof (closed_load _ _ _ _ _ _ Hc Hb Hl) as P.
  destruct v; try constructor. apply vok_mk_ptr. exact (closed_mapped_flat _ _ _ Hc P).
Qed.

Section CC.

Variable ge : genv.

Definition syms_mapped (g : meminj) : Prop :=
  forall id b, Genv.find_symbol ge id = Some b -> g b <> None.
Definition env_mapped (g : meminj) (e : env) : Prop :=
  forall id b ty, e ! id = Some (b, ty) -> g b = Some (b, 0).
Definition temps_ok (g : meminj) (le : temp_env) : Prop :=
  forall id v, le ! id = Some v -> vok g v.
Definition out_ok (g : meminj) (o : outcome) : Prop :=
  match o with Out_return (Some (v, _)) => vok g v | _ => True end.

Lemma syms_incr : forall g g', inject_incr g g' -> syms_mapped g -> syms_mapped g'.
Proof.
  intros g g' I H id b S. specialize (H id b S).
  destruct (g b) as [[b2 d]|] eqn:G; [| congruence]. rewrite (I _ _ _ G). discriminate.
Qed.
Lemma env_incr : forall g g' e, inject_incr g g' -> env_mapped g e -> env_mapped g' e.
Proof. intros g g' e I H id b ty E. exact (I _ _ _ (H id b ty E)). Qed.
Lemma temps_incr : forall g g' le, inject_incr g g' -> temps_ok g le -> temps_ok g' le.
Proof. intros g g' le I H id v E. exact (vok_incr _ _ _ I (H id v E)). Qed.
Lemma out_incr : forall g g' o, inject_incr g g' -> out_ok g o -> out_ok g' o.
Proof.
  intros g g' o I H. destruct o as [| | | [[v ty]|]]; cbn in *; auto. exact (vok_incr _ _ _ I H).
Qed.

Lemma temps_set : forall g le id v, temps_ok g le -> vok g v -> temps_ok g (PTree.set id v le).
Proof.
  intros g le id v H Hv id' v' E. rewrite PTree.gsspec in E.
  destruct (peq id' id); [injection E as <-; exact Hv | exact (H _ _ E)].
Qed.

Lemma temps_setopt : forall g le o v, temps_ok g le -> vok g v -> temps_ok g (set_opttemp o v le).
Proof. intros g le [id|] v H Hv; cbn; [exact (temps_set _ _ _ _ H Hv) | exact H]. Qed.

Lemma syms_inject : forall g m, closed_by g m -> syms_mapped g -> symbols_inject g ge ge.
Proof.
  intros g m Hc Hs. split; [reflexivity | split; [| split]].
  - intros id b1 b2 d H S. destruct Hc as (Hflat & _). destruct (Hflat _ _ _ H) as (-> & ->).
    auto.
  - intros id b1 _ S. exists b1. split; [| exact S].
    exact (closed_mapped_flat _ _ _ Hc (Hs id b1 S)).
  - intros b1 b2 d H. destruct Hc as (Hflat & _). destruct (Hflat _ _ _ H) as (-> & ->).
    reflexivity.
Qed.

(* ---- expressions ---- *)

Section EXPR.
Variables (g : meminj) (e : env) (le : temp_env) (m : mem).
Hypothesis HC : closed_by g m.
Hypothesis HS : syms_mapped g.
Hypothesis HE : env_mapped g e.
Hypothesis HT : temps_ok g le.

Lemma eval_ok :
  (forall a v, eval_expr ge e le m a v -> vok g v) /\
  (forall a b o bf, eval_lvalue ge e le m a b o bf -> g b = Some (b, 0)).
Proof.
  pose proof HC as (_ & Hi).
  apply eval_expr_lvalue_ind; intros; try constructor.
  - eapply HT; eauto.
  - apply vok_mk_ptr. assumption.
  - destruct (sem_unary_operation_inject _ _ _ _ _ _ _ _ H1 H0 Hi) as (tv & E & V).
    rewrite H1 in E. injection E as <-. exact V.
  - destruct (sem_binary_operation_inject _ _ _ _ _ _ _ _ _ _ _ _ H3 H0 H2 Hi) as (tv & E & V).
    rewrite H3 in E. injection E as <-. exact V.
  - destruct (sem_cast_inject _ _ _ _ _ _ _ _ H1 H0 Hi) as (tv & E & V).
    rewrite H1 in E. injection E as <-. exact V.
  - inv H1.
    + match goal with Hm : g ?l = Some _, Hl : Mem.loadv _ _ (Vptr ?l _) = Some _ |- _ =>
        eapply vok_load; [exact HC | rewrite Hm; discriminate | exact Hl] end.
    + apply vok_mk_ptr. exact H0.
    + apply vok_mk_ptr. exact H0.
    + inv H2. constructor.
  - eapply HE; eauto.
  - exact (closed_mapped_flat _ _ _ HC (HS _ _ H0)).
  - exact (vok_ptr _ _ _ _ HC H0).
  - exact (vok_ptr _ _ _ _ HC H0).
  - exact (vok_ptr _ _ _ _ HC H0).
Qed.

Lemma eval_exprlist_ok : forall al tys vs, eval_exprlist ge e le m al tys vs -> Forall (vok g) vs.
Proof.
  pose proof HC as (_ & Hi).
  induction 1; constructor; [| exact IHeval_exprlist].
  pose proof (proj1 eval_ok _ _ H) as V.
  destruct (sem_cast_inject _ _ _ _ _ _ _ _ H0 V Hi) as (tv & E & V').
  rewrite H0 in E. injection E as <-. exact V'.
Qed.

End EXPR.

Lemma Forall_inject_list : forall g vs, Forall (vok g) vs -> Val.inject_list g vs vs.
Proof. induction 1; constructor; auto. Qed.

(* ---- memory operations ---- *)

Lemma storebytes_mapped_closed : forall g m b ofs bytes m',
  closed_by g m -> g b = Some (b, 0) -> list_forall2 (memval_inject g) bytes bytes ->
  Mem.storebytes m b ofs bytes = Some m' -> closed_by g m'.
Proof.
  intros g m b ofs bytes m' (Hflat & Hi) Hb Hby Hs.
  destruct (Mem.storebytes_mapped_inject _ _ _ _ _ _ _ _ _ _ Hi Hs Hb Hby) as (n2 & Hs2 & Hi2).
  rewrite Z.add_0_r, Hs in Hs2. injection Hs2 as <-. split; [exact Hflat | exact Hi2].
Qed.

Lemma assign_loc_closed : forall g m ty b o bf v m',
  closed_by g m -> g b = Some (b, 0) -> vok g v ->
  assign_loc ge ty m b o bf v m' -> closed_by g m'.
Proof.
  intros g m ty b o bf v m' Hc Hb Hv H. inv H.
  - match goal with Hs : Mem.storev _ _ _ _ = Some _ |- _ =>
      exact (store_mapped_closed _ _ _ _ _ _ _ Hc Hb Hv Hs) end.
  - pose proof (vok_ptr _ _ _ _ Hc Hv) as Hb'. pose proof Hc as (_ & Hi).
    match goal with Hl : Mem.loadbytes _ _ _ _ = Some _, Hs : Mem.storebytes _ _ _ _ = Some _ |- _ =>
      destruct (Mem.loadbytes_inject _ _ _ _ _ _ _ _ _ Hi Hl Hb') as (by2 & L2 & F);
      rewrite Z.add_0_r, Hl in L2; injection L2 as <-;
      exact (storebytes_mapped_closed _ _ _ _ _ _ Hc Hb F Hs) end.
  - match goal with Hs : store_bitfield _ _ _ _ _ _ _ _ _ _ |- _ => inv Hs end.
    match goal with Hs : Mem.storev _ _ _ _ = Some _ |- _ =>
      eapply store_mapped_closed; [exact Hc | exact Hb | constructor | exact Hs] end.
Qed.

Lemma free_closed : forall g m b lo hi m',
  closed_by g m -> Mem.free m b lo hi = Some m' -> closed_by g m'.
Proof.
  intros g m b lo hi m' (Hflat & Hi) Hf. split; [exact Hflat |].
  destruct (g b) as [[b2 d]|] eqn:G.
  - destruct (Hflat _ _ _ G) as (-> & ->).
    destruct (Mem.free_parallel_inject _ _ _ _ _ _ _ _ _ Hi Hf G) as (m2' & F2 & Hi2).
    rewrite !Z.add_0_r, Hf in F2. injection F2 as <-. exact Hi2.
  - pose proof (Mem.free_left_inject _ _ _ _ _ _ _ Hi Hf) as Hi1.
    eapply Mem.free_right_inject; [exact Hi1 | exact Hf |].
    intros b1 d ofs k p H1 _ _. destruct (Hflat _ _ _ H1) as (-> & ->). congruence.
Qed.

Lemma free_list_closed : forall g l m m',
  closed_by g m -> Mem.free_list m l = Some m' -> closed_by g m'.
Proof.
  intros g l. induction l as [| [[b lo] hi] l IH]; intros m m' Hc H; cbn in H.
  - injection H as <-. exact Hc.
  - destruct (Mem.free m b lo hi) as [m1|] eqn:F; [| discriminate].
    exact (IH _ _ (free_closed _ _ _ _ _ _ Hc F) H).
Qed.

Lemma alloc_vars_closed : forall e m vars e' m', alloc_variables ge e m vars e' m' ->
  forall g, closed_by g m -> env_mapped g e ->
  exists g', inject_incr g g' /\ closed_by g' m' /\ env_mapped g' e'.
Proof.
  induction 1; intros g Hc He.
  - exists g. split; [intros ? ? ? X; exact X | auto].
  - pose proof (alloc_private _ _ _ _ _ _ Hc H) as (_ & Hgb).
    set (g1 := fun x => if peq x b1 then Some (b1, 0) else g x).
    assert (I1 : inject_incr g g1).
    { intros x x' d X. unfold g1. destruct (peq x b1) as [-> | _]; [congruence | exact X]. }
    pose proof (alloc_public _ _ _ _ _ _ Hc H) as Hc1. fold g1 in Hc1.
    assert (He1 : env_mapped g1 (PTree.set id (b1, ty) e)).
    { intros id' b ty' E. rewrite PTree.gsspec in E. destruct (peq id' id).
      - injection E as <- <-. unfold g1. destruct (peq b1 b1); [reflexivity | congruence].
      - exact (I1 _ _ _ (He _ _ _ E)). }
    destruct (IHalloc_variables g1 Hc1 He1) as (g' & I' & Hc' & He').
    exists g'. split; [| auto]. intros x x' d X. exact (I' _ _ _ (I1 _ _ _ X)).
Qed.

Lemma create_undef_ok : forall g l, temps_ok g (create_undef_temps l).
Proof.
  intros g l. induction l as [| [id ty] l IH]; cbn; intros id' v E.
  - rewrite PTree.gempty in E. discriminate.
  - rewrite PTree.gsspec in E. destruct (peq id' id); [injection E as <-; constructor | exact (IH _ _ E)].
Qed.

Lemma bind_ok : forall g ps vs le le', temps_ok g le -> Forall (vok g) vs ->
  bind_parameter_temps ps vs le = Some le' -> temps_ok g le'.
Proof.
  intros g ps. induction ps as [| [id ty] ps IH]; intros vs le le' Ht Hv H; destruct vs; cbn in H;
    try discriminate.
  - injection H as <-. exact Ht.
  - inv Hv. exact (IH _ _ _ (temps_set _ _ _ _ Ht H2) H3 H).
Qed.

(* ---- statements and calls ---- *)

Definition stmt_P (e : env) (le : temp_env) (m : mem) (s : statement) (t : trace)
    (le' : temp_env) (m' : mem) (out : outcome) : Prop :=
  forall g, closed_by g m -> syms_mapped g -> env_mapped g e -> temps_ok g le ->
  exists g', inject_incr g g' /\ closed_by g' m' /\ temps_ok g' le' /\ out_ok g' out.

Definition call_P (m : mem) (fd : fundef) (vs : list val) (t : trace) (m' : mem) (v : val) : Prop :=
  forall g, closed_by g m -> syms_mapped g -> Forall (vok g) vs ->
  exists g', inject_incr g g' /\ closed_by g' m' /\ vok g' v.

Lemma incr_trans : forall f1 f2 f3, inject_incr f1 f2 -> inject_incr f2 f3 -> inject_incr f1 f3.
Proof. intros f1 f2 f3 A B x x' d X. exact (B _ _ _ (A _ _ _ X)). Qed.

Lemma incr_refl : forall f, inject_incr f f.
Proof. intros f x x' d X. exact X. Qed.

Ltac stmt_intro := intros until g; intros HC HS HE HT.
Ltac call_intro := intros until g; intros HC HS HA.
Ltac keep := split; [apply incr_refl | split; [assumption | split; [assumption | exact I]]].

Theorem exec_closed :
  (forall e le m s t le' m' out, exec_stmt function_entry2 ge e le m s t le' m' out ->
     stmt_P e le m s t le' m' out) /\
  (forall m fd vs t m' v, eval_funcall function_entry2 ge m fd vs t m' v -> call_P m fd vs t m' v).
Proof.
  apply exec_stmt_funcall_ind; unfold stmt_P, call_P.
  - (* skip *) stmt_intro. exists g. keep.
  - (* assign *) stmt_intro.
    pose proof HC as (_ & Hi).
    match goal with
    | Hl : eval_lvalue _ _ _ _ _ _ _ _, He : eval_expr _ _ _ _ _ _,
      Hc : sem_cast _ _ _ _ = Some _, Ha : assign_loc _ _ _ _ _ _ _ _ |- _ =>
      pose proof (proj2 (eval_ok g _ _ _ HC HS HE HT) _ _ _ _ Hl) as Hb;
      pose proof (proj1 (eval_ok g _ _ _ HC HS HE HT) _ _ He) as Hv2;
      destruct (sem_cast_inject _ _ _ _ _ _ _ _ Hc Hv2 Hi) as (tv & E & Hv);
      rewrite Hc in E; injection E as <-;
      exists g; split; [apply incr_refl | split; [exact (assign_loc_closed _ _ _ _ _ _ _ _ HC Hb Hv Ha) | split; [exact HT | exact I]]]
    end.
  - (* set *) stmt_intro.
    match goal with He : eval_expr _ _ _ _ _ _ |- _ =>
      exists g; split; [apply incr_refl | split; [exact HC | split; [| exact I]]];
      exact (temps_set _ _ _ _ HT (proj1 (eval_ok g _ _ _ HC HS HE HT) _ _ He)) end.
  - (* call *) stmt_intro.
    match goal with Hl : eval_exprlist _ _ _ _ _ _ _, IH : forall g, closed_by g _ -> _ |- _ =>
      pose proof (eval_exprlist_ok g _ _ _ HC HS HE HT _ _ _ Hl) as Hargs;
      destruct (IH g HC HS Hargs) as (g' & I1 & Hc' & Hv);
      exists g'; split; [exact I1 | split; [exact Hc' | split; [| exact I]]];
      exact (temps_setopt _ _ _ _ (temps_incr _ _ _ I1 HT) Hv) end.
  - (* builtin *) stmt_intro.
    match goal with Hl : eval_exprlist _ _ _ _ _ _ _, Hx : external_call _ _ _ _ _ _ _ |- _ =>
      pose proof (eval_exprlist_ok g _ _ _ HC HS HE HT _ _ _ Hl) as Hargs;
      destruct (ext_call_closed _ _ _ _ _ _ _ _ HC (syms_inject _ _ HC HS) (Forall_inject_list _ _ Hargs) Hx)
        as (g' & Hc' & I1 & Hv & _);
      exists g'; split; [exact I1 | split; [exact Hc' | split; [| exact I]]];
      exact (temps_setopt _ _ _ _ (temps_incr _ _ _ I1 HT) Hv) end.
  - (* seq 1 *) intros e le m s1 s2 t1 le1 m1 t2 le2 m2 out _ IH1 _ IH2. stmt_intro.
    destruct (IH1 g HC HS HE HT) as (g1 & I1 & C1 & T1 & _).
    destruct (IH2 g1 C1 (syms_incr _ _ I1 HS) (env_incr _ _ _ I1 HE) T1) as (g2 & I2 & C2 & T2 & O2).
    exists g2. split; [exact (incr_trans _ _ _ I1 I2) | tauto].
  - (* seq 2 *) intros e le m s1 s2 t1 le1 m1 out _ IH1 _. stmt_intro. exact (IH1 g HC HS HE HT).
  - (* if *) intros e le m a s1 s2 v1 b t le' m' out _ _ _ IH. stmt_intro. exact (IH g HC HS HE HT).
  - (* return none *) stmt_intro. exists g. keep.
  - (* return some *) stmt_intro.
    match goal with He : eval_expr _ _ _ _ _ _ |- _ =>
      exists g; split; [apply incr_refl | split; [exact HC | split; [exact HT |]]];
      exact (proj1 (eval_ok g _ _ _ HC HS HE HT) _ _ He) end.
  - (* break *) stmt_intro. exists g. keep.
  - (* continue *) stmt_intro. exists g. keep.
  - (* loop stop 1 *) intros e le m s1 s2 t le' m' out' out _ IH1 Hbr. stmt_intro.
    destruct (IH1 g HC HS HE HT) as (g1 & I1 & C1 & T1 & O1).
    exists g1. split; [exact I1 | split; [exact C1 | split; [exact T1 |]]].
    inv Hbr; cbn in *; auto.
  - (* loop stop 2 *) intros e le m s1 s2 t1 le1 m1 out1 t2 le2 m2 out2 out _ IH1 _ _ IH2 Hbr. stmt_intro.
    destruct (IH1 g HC HS HE HT) as (g1 & I1 & C1 & T1 & _).
    destruct (IH2 g1 C1 (syms_incr _ _ I1 HS) (env_incr _ _ _ I1 HE) T1) as (g2 & I2 & C2 & T2 & O2).
    exists g2. split; [exact (incr_trans _ _ _ I1 I2) | split; [exact C2 | split; [exact T2 |]]].
    inv Hbr; cbn in *; auto.
  - (* loop loop *) intros e le m s1 s2 t1 le1 m1 out1 t2 le2 m2 t3 le3 m3 out _ IH1 _ _ IH2 _ IH3.
    stmt_intro.
    destruct (IH1 g HC HS HE HT) as (g1 & I1 & C1 & T1 & _).
    destruct (IH2 g1 C1 (syms_incr _ _ I1 HS) (env_incr _ _ _ I1 HE) T1) as (g2 & I2 & C2 & T2 & _).
    destruct (IH3 g2 C2 (syms_incr _ _ (incr_trans _ _ _ I1 I2) HS)
                (env_incr _ _ _ (incr_trans _ _ _ I1 I2) HE) T2) as (g3 & I3 & C3 & T3 & O3).
    exists g3. split; [exact (incr_trans _ _ _ (incr_trans _ _ _ I1 I2) I3) | tauto].
  - (* switch *) intros e le m a t v n sl le1 m1 out _ _ _ IH. stmt_intro.
    destruct (IH g HC HS HE HT) as (g1 & I1 & C1 & T1 & O1).
    exists g1. split; [exact I1 | split; [exact C1 | split; [exact T1 |]]].
    destruct out as [| | | [[]|]]; cbn in *; auto.
  - (* internal call *) intros m f vargs t e le1 le2 m1 m2 out vres m3 Hfe _ IH Hres Hfree.
    call_intro. inv Hfe.
    match goal with Ha : alloc_variables _ _ _ _ _ _, Hb : bind_parameter_temps _ _ _ = Some _ |- _ =>
      destruct (alloc_vars_closed _ _ _ _ _ Ha g HC
                  ltac:(intros id b ty E; rewrite PTree.gempty in E; discriminate))
        as (g1 & I1 & C1 & E1);
      pose proof (bind_ok g1 _ _ _ _ (create_undef_ok g1 _)
                    (Forall_impl _ (fun v => vok_incr _ _ v I1) HA) Hb) as T1 end.
    destruct (IH g1 C1 (syms_incr _ _ I1 HS) E1 T1) as (g2 & I2 & C2 & T2 & O2).
    exists g2. split; [exact (incr_trans _ _ _ I1 I2) | split; [exact (free_list_closed _ _ _ _ C2 Hfree) |]].
    unfold outcome_result_value in Hres.
    destruct out as [| | | [[v' t']|]]; destruct (fn_return f); try contradiction;
      try (subst; constructor); try (destruct Hres as (_ & Hres)).
    all: try (destruct (sem_cast_inject _ _ _ _ _ _ _ _ Hres O2 (proj2 C2)) as (tv & E & V);
              rewrite Hres in E; injection E as <-; exact V).
  - (* external call *) intros m ef targs tres cconv vargs t vres m' Hx. call_intro.
    destruct (ext_call_closed _ _ _ _ _ _ _ _ HC (syms_inject _ _ HC HS) (Forall_inject_list _ _ HA) Hx)
      as (g' & Hc' & I1 & Hv & _).
    exists g'. tauto.
Qed.

Theorem funcall_closed : forall m fd vs t m' v g,
  eval_funcall function_entry2 ge m fd vs t m' v ->
  closed_by g m -> syms_mapped g -> Forall (vok g) vs ->
  exists g', inject_incr g g' /\ closed_by g' m' /\ syms_mapped g' /\ vok g' v.
Proof.
  intros m fd vs t m' v g H Hc Hs Hv.
  destruct (proj2 exec_closed _ _ _ _ _ _ H g Hc Hs Hv) as (g' & I & Hc' & Hv').
  exists g'. split; [exact I | split; [exact Hc' | split; [exact (syms_incr _ _ I Hs) | exact Hv']]].
Qed.

End CC.
