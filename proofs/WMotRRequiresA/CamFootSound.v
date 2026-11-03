(* spine (via CamFootInst, 2026-11-02): the soundness of CamFootKit's footprint walk. *)
(* ====================================================================== *)
(* CamFootSound.v -- CamFootKit's walk is sound, for every state.         *)
(*                                                                        *)
(* THEOREM (cf_good_spec): a function the table vouches for (checked by   *)
(* fchk, or a proved leaf), run from ANY memory whose pins hold, with     *)
(* arguments of its parameter classes,                                    *)
(*   - changes memory only in the blocks of FP's globals, blocks born     *)
(*     during the call, the byte range [co, co+SZ) of cb, and the pins'   *)
(*     cells (Mem.unchanged_on over the rest) -- and, through its LEAVES  *)
(*     only, the blocks of the extra list XP;                             *)
(*   - keeps the carried invariant Inv (which survives any change outside *)
(*     the walk's own targets; the leaves keep it themselves);            *)
(*   - keeps every old permission and leaves new blocks permissionless    *)
(*     (PermWalk.PK);                                                      *)
(*   - keeps the pins, and returns a value of its return class.           *)
(* Indirect calls are not pruned: any function of the call's type may run *)
(* (ItGood).  Nothing is assumed about the stored values but the pins'.   *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia Bool.
From compcert Require Import Coqlib Maps AST Integers Floats Values Events Memory
  Globalenvs Ctypes Cop Clight ClightBigstep.
From SM64.Proofs Require Import CensusV2 Generic.PermWalk.
From SM64.Proofs.WMotRRequiresA Require Import CamFootKit.
From SM64.Proofs Require CameraModeBody MtxfBody RetSurface ActWriterSurface SpawnBodies
  SaveDoSaveBody MathGeomGated MWFReal LocalVarsSurface ObjHelpersBodies PrintBodies.
Import ListNotations.
Local Open Scope Z_scope.

(* ---------------------------------------------------------------------- *)
(* 0. The footprint blocks.                                                *)
(* ---------------------------------------------------------------------- *)

Definition FB0 (ge : genv) (FP : list ident) (b : block) : Prop :=
  exists g, mem_idf g FP = true /\ Genv.find_symbol ge g = Some b.

(* fF's blocks at nextblock nb: an FP global's, or one born since nl and
   already allocated (so a later local is never one of them) *)
Definition FBn (ge : genv) (FP : list ident) (nl nb : block) (b : block) : Prop :=
  FB0 ge FP b \/ (Ple nl b /\ Plt b nb).

Lemma fpc_mono : forall ge FP nl nb nb' cb co SZ c b o, Ple nb nb' ->
    fpc (FBn ge FP nl nb) cb co SZ c b o -> fpc (FBn ge FP nl nb') cb co SZ c b o.
Proof.
  intros ge FP nl nb nb' cb co SZ c b o Hle H.
  assert (K : FBn ge FP nl nb b -> FBn ge FP nl nb' b).
  { intros [F | (F1 & F2)]; [ left; exact F | right; split; [ exact F1 | exact (Plt_Ple_trans _ _ _ F2 Hle) ] ]. }
  destruct c; cbn in *; try tauto.
Qed.

Lemma fvok_mono : forall ge FP nl nb nb' cb co SZ c v, Ple nb nb' ->
    fvok (FBn ge FP nl nb) cb co SZ c v -> fvok (FBn ge FP nl nb') cb co SZ c v.
Proof. intros. intros b o E. eapply fpc_mono; [ eassumption | exact (H0 b o E) ]. Qed.

Lemma forall2_fvok_mono : forall ge FP nl nb nb' cb co SZ pcs vs, Ple nb nb' ->
    Forall2 (fvok (FBn ge FP nl nb) cb co SZ) pcs vs -> Forall2 (fvok (FBn ge FP nl nb') cb co SZ) pcs vs.
Proof.
  intros ge FP nl nb nb' cb co SZ pcs vs Hle H. induction H; constructor; [ | exact IHForall2 ].
  exact (fvok_mono _ _ _ _ _ _ _ _ _ _ Hle H).
Qed.

(* ---------------------------------------------------------------------- *)
(* 1. Class arithmetic.                                                    *)
(* ---------------------------------------------------------------------- *)

Lemma fshift_pc : forall FB cb co SZ c b o d, 0 <= co -> co + SZ <= Ptrofs.max_unsigned ->
    fpc FB cb co SZ c b o -> fpc FB cb co SZ (fshift c d) b (Ptrofs.add o (Ptrofs.repr d)).
Proof.
  intros FB cb co SZ c b o d H0 HM Hc.
  pose proof (Ptrofs.unsigned_range_2 o) as Ro.
  assert (K : forall n, 0 <= d <= n -> co <= Ptrofs.unsigned o -> Ptrofs.unsigned o + n <= co + SZ ->
            co <= Ptrofs.unsigned (Ptrofs.add o (Ptrofs.repr d)) /\
            Ptrofs.unsigned (Ptrofs.add o (Ptrofs.repr d)) + (n - d) <= co + SZ).
  { intros n Hd H1 H2. rewrite Ptrofs.add_unsigned, (Ptrofs.unsigned_repr d) by lia.
    rewrite Ptrofs.unsigned_repr by lia. lia. }
  destruct c as [ | | n | n | ]; cbn [fshift fpc] in *; try exact Hc.
  - destruct ((0 <=? d) && (d <=? n)) eqn:E; [ | exact I ].
    apply andb_prop in E as [E1 E2]. apply Z.leb_le in E1. apply Z.leb_le in E2.
    destruct Hc as (-> & H1 & H2). cbn [fpc]. split; [ reflexivity | ].
    exact (K n (conj E1 E2) H1 H2).
  - destruct ((0 <=? d) && (d <=? n)) eqn:E; [ | exact I ].
    apply andb_prop in E as [E1 E2]. apply Z.leb_le in E1. apply Z.leb_le in E2.
    cbn [fpc]. destruct Hc as [Hc | (-> & H1 & H2)]; [ left; exact Hc | right ].
    split; [ reflexivity | ]. exact (K n (conj E1 E2) H1 H2).
Qed.

Lemma fblk_pc : forall FB cb co SZ c b o o', fpc FB cb co SZ c b o -> fpc FB cb co SZ (fblk c) b o'.
Proof. intros FB cb co SZ [ | | n | n | ] b o o' H; cbn in *; tauto. Qed.

Lemma fblk_idem : forall c, fblk (fblk c) = fblk c.
Proof. intros [ | | n | n | ]; reflexivity. Qed.

Lemma join_blk_pc_l : forall FB cb co SZ c1 c2 b o o', fpc FB cb co SZ c1 b o ->
    fpc FB cb co SZ (fjoin (fblk c1) (fblk c2)) b o'.
Proof. intros. eapply fle_pc; [ apply fle_join_l | eapply fblk_pc; eassumption ]. Qed.

Lemma join_blk_pc_r : forall FB cb co SZ c1 c2 b o o', fpc FB cb co SZ c2 b o ->
    fpc FB cb co SZ (fjoin (fblk c1) (fblk c2)) b o'.
Proof. intros. eapply fle_pc; [ apply fle_join_r | eapply fblk_pc; eassumption ]. Qed.

Lemma fle_l_forall2 : forall (P : fcls -> val -> Prop) l1 l2 vs,
    (forall c d v, fle c d = true -> P c v -> P d v) ->
    fle_l l1 l2 = true -> Forall2 P l1 vs -> Forall2 P l2 vs.
Proof.
  intros P l1 l2 vs Hm. revert l2 vs.
  induction l1 as [| c l1 IH]; intros [| d l2] vs H Hf; try discriminate H.
  - exact Hf.
  - cbn [fle_l] in H. apply andb_prop in H as [H1 H2].
    inv Hf. constructor; [ exact (Hm _ _ _ H1 H3) | exact (IH _ _ H2 H5) ].
Qed.

Lemma fle_l_refl : forall l, fle_l l l = true.
Proof. induction l as [| c l IH]; [ reflexivity | cbn [fle_l]; rewrite fle_refl, IH; reflexivity ]. Qed.

(* a constant non-negative index *)
Lemma int_signed_nonneg : forall i, Int.lt i Int.zero = false -> Int.signed i = Int.unsigned i.
Proof.
  intros i H. unfold Int.lt in H. rewrite Int.signed_zero in H.
  destruct (zlt (Int.signed i) 0) as [_ | Hge]; [ discriminate H | ].
  unfold Int.signed in *. destruct (zlt (Int.unsigned i) Int.half_modulus); [ reflexivity | ].
  pose proof (Int.unsigned_range i). exfalso. lia.
Qed.

Lemma scal_sizeof : forall cenv t sz, scal_size t = Some sz -> sizeof cenv t = sz.
Proof.
  intros cenv t sz H. destruct t as [ | [] ? ? | ? ? | [] ? | ? ? | | | | ]; cbn in H; try discriminate H;
    injection H as <-; reflexivity.
Qed.

Lemma sem_add_cidx : forall (cenv : composite_env) a2 k t1 t sz v1 v2 m bb oo,
    cidx a2 = Some k -> elt_of t1 = Some t -> scal_size t = Some sz ->
    v2 = match a2 with Econst_int n _ => Vint n | _ => Vundef end ->
    sem_add cenv v1 t1 v2 (typeof a2) m = Some (Vptr bb oo) ->
    exists o1, v1 = Vptr bb o1 /\ oo = Ptrofs.add o1 (Ptrofs.repr (k * sz)).
Proof.
  intros cenv a2 k t1 t sz v1 v2 m bb oo Hk Ht Hs Hv H.
  destruct a2; try discriminate Hk.
  destruct t0 as [ | isz sg at0 | | | | | | | ]; try discriminate Hk.
  cbn [cidx] in Hk. destruct (Int.lt i Int.zero) eqn:Hlt; [ discriminate Hk | ].
  injection Hk as <-. subst v2.
  assert (Hm : forall si, ptrofs_of_int si i = Ptrofs.repr (Int.unsigned i)).
  { intros []; unfold ptrofs_of_int; [ unfold Ptrofs.of_ints; rewrite int_signed_nonneg by exact Hlt | ];
      reflexivity. }
  assert (Hmul : forall si, Ptrofs.mul (Ptrofs.repr (sizeof cenv t)) (ptrofs_of_int si i)
                            = Ptrofs.repr (Int.unsigned i * sz)).
  { intros si. rewrite Hm, (scal_sizeof cenv t sz Hs). unfold Ptrofs.mul.
    apply Ptrofs.eqm_samerepr. rewrite Z.mul_comm. apply Ptrofs.eqm_mult;
      apply Ptrofs.eqm_sym; apply Ptrofs.eqm_unsigned_repr. }
  destruct t1; try discriminate Ht; injection Ht as ->;
    unfold sem_add, classify_add in H; cbn [typeof typeconv remove_attributes] in H;
    destruct isz; cbn in H;
    unfold sem_add_ptr_int in H;
    destruct v1; try discriminate H;
    try (unfold Archi.ptr64 in H; discriminate H);
    injection H as <- <-; eexists; (split; [ reflexivity | f_equal; first [ exact (Hmul Signed) | exact (Hmul Unsigned) | exact (Hmul _) ] ]).
Qed.

(* ---------------------------------------------------------------------- *)
(* 2. Soundness of the classifier.                                         *)
(* ---------------------------------------------------------------------- *)

Lemma frv_deref : forall FB cb co SZ ty m loc ofs bf v c,
    deref_loc ty m loc ofs bf v -> fpc FB cb co SZ c loc ofs ->
    fvok FB cb co SZ (frv ty c) v.
Proof.
  intros FB cb co SZ ty m loc ofs bf v c Hd Hc b o Ev. subst v.
  inv Hd.
  - match goal with Ha : access_mode _ = By_value ?ch, Hl : Mem.loadv ?ch _ _ = Some _ |- _ =>
      pose proof Hl as Hl'; cbn in Hl';
      destruct (SpawnBodies.load_vptr_chunk _ _ _ _ _ _ Hl') as [E | [E | E]]; subst ch;
      unfold frv; rewrite Ha; exact I end.
  - match goal with Ha : access_mode _ = By_reference |- _ => unfold frv; rewrite Ha; exact Hc end.
  - match goal with Ha : access_mode _ = By_copy |- _ => unfold frv; rewrite Ha; exact Hc end.
  - match goal with Hl : load_bitfield _ _ _ _ _ _ _ _ |- _ => inv Hl end.
Qed.

Lemma fx_flv_copy : forall ce FP pins lv tc a, access_mode (typeof a) = By_copy ->
    flv ce FP pins lv tc a = fA \/ fx ce FP pins lv tc a = flv ce FP pins lv tc a.
Proof.
  intros ce FP pins lv tc a H.
  destruct a; cbn [typeof] in H; cbn [fx flv]; try (left; reflexivity); right.
  - destruct (mem_idf i lv) eqn:El.
    + unfold frv, fvar. rewrite H, El. reflexivity.
    + rewrite H. destruct (pin_of i pins); unfold frv; rewrite H; reflexivity.
  - unfold frv. rewrite H. reflexivity.
  - unfold frv. rewrite H. reflexivity.
Qed.

Section KS.
  Variable ge : genv.
  Variable e : env.
  Variable le : temp_env.
  Variable m : mem.
  Variable ce : composite_env.
  Variable FP : list ident.
  Variable pins : list (ident * fcls).
  Variable lv : list ident.
  Variable tc : ident -> fcls.
  Variables (cb : block) (co SZ : Z) (nl : block).

  Let FB := FBn ge FP nl (Mem.nextblock m).
  Let pc := fpc FB cb co SZ.
  Let vok := fvok FB cb co SZ.

  Hypothesis Hce : forall id c, ce ! id = Some c -> (genv_cenv ge) ! id = Some c.
  Hypothesis HSZ : 0 <= co /\ co + SZ <= Ptrofs.max_unsigned.
  Hypothesis Hle : forall t v, le ! t = Some v -> vok (tc t) v.
  Hypothesis He : forall x b ty, e ! x = Some (b, ty) ->
      mem_idf x lv = true /\ Ple nl b /\ Plt b (Mem.nextblock m).
  Hypothesis He2 : forall x, mem_idf x lv = true -> e ! x <> None.
  Hypothesis Hpin : forall x c b, pin_of x pins = Some c -> Genv.find_symbol ge x = Some b ->
      forall v, Mem.load Mint32 m b 0 = Some v -> vok c v.

  Notation fx' := (fx ce FP pins lv tc).
  Notation flv' := (flv ce FP pins lv tc).

  Lemma fx_sound_mut :
    (forall a v, eval_expr ge e le m a v -> vok (fx' a) v) /\
    (forall a b o bf, eval_lvalue ge e le m a b o bf ->
       pc (flv' a) b o /\ (bf = Full \/ fblk (flv' a) = flv' a)).
  Proof.
    apply (eval_expr_lvalue_ind ge e le m
             (fun a v => vok (fx' a) v)
             (fun a b o bf => pc (flv' a) b o /\ (bf = Full \/ fblk (flv' a) = flv' a)));
      intros; cbv beta in *.
    - intros bb oo E; discriminate E.
    - intros bb oo E; discriminate E.
    - intros bb oo E; discriminate E.
    - intros bb oo E; discriminate E.
    - cbn [fx]. eapply Hle; eassumption.
    - intros bb oo E. injection E as <- <-. cbn [fx]. exact (proj1 H0).
    - intros bb oo E. subst. exfalso.
      exact (ActWriterSurface.sem_unop_nonptr _ _ _ _ _ H1 bb oo eq_refl).
    - intros bb oo E. subst. cbn [fx].
      match goal with |- context [if CameraModeBody.never_ptr_binop ?o ?x ?y then _ else _] =>
        destruct (CameraModeBody.never_ptr_binop o x y) eqn:Enp;
        [ exfalso; eapply CameraModeBody.never_ptr_binop_sound; eassumption | ] end.
      rename H3 into Hs. pose proof Hs as Hs0.
      destruct op; cbn [sem_binary_operation] in Hs.
      + (* Oadd *)
        assert (Fb : fpc FB cb co SZ (fjoin (fblk (fx' a1)) (fblk (fx' a2))) bb oo).
        { destruct (SaveDoSaveBody.sem_add_vptr_src _ _ _ _ _ _ _ _ Hs) as [(o1 & E1) | (o2 & E2)].
          - exact (join_blk_pc_l _ _ _ _ _ _ _ _ _ (H0 _ _ E1)).
          - exact (join_blk_pc_r _ _ _ _ _ _ _ _ _ (H2 _ _ E2)). }
        destruct (cidx a2) as [k|] eqn:Ek; [ | exact Fb ].
        destruct (elt_of (typeof a1)) as [t|] eqn:Et; [ | exact Fb ].
        destruct (scal_size t) as [sz|] eqn:Es; [ | exact Fb ].
        assert (Hv2 : v2 = match a2 with Econst_int n _ => Vint n | _ => Vundef end).
        { destruct a2; try discriminate Ek. inv H1; [ reflexivity | ].
          match goal with Hl : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv Hl end. }
        destruct (sem_add_cidx _ _ _ _ _ _ _ _ _ _ _ Ek Et Es Hv2 Hs) as (o1 & E1 & ->).
        exact (fshift_pc _ _ _ _ _ _ _ _ (proj1 HSZ) (proj2 HSZ) (H0 _ _ E1)).
      + (* Osub *)
        destruct (SaveDoSaveBody.sem_sub_vptr_src _ _ _ _ _ _ _ _ Hs) as (o1 & E1).
        exact (fblk_pc _ _ _ _ _ _ _ _ (H0 _ _ E1)).
      + exact I.
      + exact I.
      + exact I.
      + exfalso; exact (SpawnBodies.vint_binop_sound _ Oand _ _ _ _ _ _ eq_refl Hs0 bb oo eq_refl).
      + exfalso; exact (SpawnBodies.vint_binop_sound _ Oor _ _ _ _ _ _ eq_refl Hs0 bb oo eq_refl).
      + exfalso; exact (SpawnBodies.vint_binop_sound _ Oxor _ _ _ _ _ _ eq_refl Hs0 bb oo eq_refl).
      + exfalso; exact (SpawnBodies.vint_binop_sound _ Oshl _ _ _ _ _ _ eq_refl Hs0 bb oo eq_refl).
      + exfalso; exact (SpawnBodies.vint_binop_sound _ Oshr _ _ _ _ _ _ eq_refl Hs0 bb oo eq_refl).
      + exfalso; exact (SpawnBodies.vint_binop_sound _ Oeq _ _ _ _ _ _ eq_refl Hs0 bb oo eq_refl).
      + exfalso; exact (SpawnBodies.vint_binop_sound _ One _ _ _ _ _ _ eq_refl Hs0 bb oo eq_refl).
      + exfalso; exact (SpawnBodies.vint_binop_sound _ Olt _ _ _ _ _ _ eq_refl Hs0 bb oo eq_refl).
      + exfalso; exact (SpawnBodies.vint_binop_sound _ Ogt _ _ _ _ _ _ eq_refl Hs0 bb oo eq_refl).
      + exfalso; exact (SpawnBodies.vint_binop_sound _ Ole _ _ _ _ _ _ eq_refl Hs0 bb oo eq_refl).
      + exfalso; exact (SpawnBodies.vint_binop_sound _ Oge _ _ _ _ _ _ eq_refl Hs0 bb oo eq_refl).
    - intros bb oo E. subst. cbn [fx].
      exact (H0 _ _ (sem_cast_vptr_inv _ _ _ _ _ _ H1)).
    - intros bb oo E. unfold Vptrofs in E. destruct Archi.ptr64; discriminate E.
    - intros bb oo E. unfold Vptrofs in E. destruct Archi.ptr64; discriminate E.
    - (* an lvalue read *)
      destruct H0 as (Hpc & _).
      destruct a; try (match goal with Hl : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv Hl end; fail);
        cbn [fx flv typeof] in *.
      + destruct (mem_idf i lv) eqn:El.
        * unfold fvar in Hpc. rewrite El in Hpc. exact (frv_deref _ _ _ _ _ _ _ _ _ _ _ H1 Hpc).
        * destruct (pin_of i pins) as [c|] eqn:Ep; [ | exact (frv_deref _ _ _ _ _ _ _ _ _ _ _ H1 Hpc) ].
          destruct (access_mode t) as [ch | | | ] eqn:Ea;
            try exact (frv_deref _ _ _ _ _ _ _ _ _ _ _ H1 Hpc).
          destruct ch; try exact (frv_deref _ _ _ _ _ _ _ _ _ _ _ H1 Hpc).
          inv H.
          -- exfalso. match goal with Hx : e ! _ = Some _ |- _ =>
               destruct (He _ _ _ Hx) as (E & _); congruence end.
          -- inv H1; try congruence.
             match goal with Hl : Mem.loadv _ _ _ = Some _, Ha : access_mode _ = By_value _,
                             Hs : Genv.find_symbol _ _ = Some _ |- _ =>
               rewrite Ea in Ha; injection Ha as <-; cbn in Hl;
               exact (Hpin _ _ _ Ep Hs _ Hl) end.
      + exact (frv_deref _ _ _ _ _ _ _ _ _ _ _ H1 Hpc).
      + exact (frv_deref _ _ _ _ _ _ _ _ _ _ _ H1 Hpc).
    - (* local *)
      cbn [flv]. unfold fvar. destruct (He _ _ _ H) as (El & H1 & H2). rewrite El.
      split; [ right; split; assumption | left; reflexivity ].
    - (* global *)
      cbn [flv]. unfold fvar.
      destruct (mem_idf id lv) eqn:El; [ exact (False_ind _ (He2 _ El H)) | ].
      split; [ | left; reflexivity ].
      destruct (mem_idf id FP) eqn:Ef; [ | exact I ].
      left. exists id. split; assumption.
    - cbn [flv]. split; [ exact (H0 _ _ eq_refl) | left; reflexivity ].
    - (* struct field *)
      cbn [flv]. rewrite H1. unfold ffield.
      destruct (ce ! id) as [c|] eqn:Ec; [ | split; [ exact I | right; reflexivity ] ].
      rewrite (Hce _ _ Ec) in H2. injection H2 as <-.
      destruct (complete_members ce (co_members c)) eqn:Hc; [ | split; [ exact I | right; reflexivity ] ].
      rewrite (field_offset_stable ce (genv_cenv ge) Hce _ _ Hc) in H3.
      rewrite H3.
      assert (Hp : pc (flv' a) l ofs \/ flv' a = fA).
      { destruct (fx_flv_copy ce FP pins lv tc a ltac:(rewrite H1; reflexivity)) as [E | E].
        - right. exact E.
        - left. rewrite <- E. exact (H0 _ _ eq_refl). }
      destruct bf; [ | split; [ exact I | right; reflexivity ] ].
      split; [ | left; reflexivity ].
      destruct Hp as [Hp | ->].
      + exact (fshift_pc _ _ _ _ _ _ _ _ (proj1 HSZ) (proj2 HSZ) Hp).
      + exact I.
    - (* union field *)
      cbn [flv]. rewrite H1. unfold ffield. split; [ | right; apply fblk_idem ].
      destruct (fx_flv_copy ce FP pins lv tc a ltac:(rewrite H1; reflexivity)) as [E | E].
      + rewrite E. exact I.
      + rewrite <- E. exact (fblk_pc _ _ _ _ _ _ _ _ (H0 _ _ eq_refl)).
  Qed.

  Lemma fx_sound : forall a v, eval_expr ge e le m a v -> vok (fx' a) v.
  Proof. exact (proj1 fx_sound_mut). Qed.

  Lemma flv_sound : forall a b o bf, eval_lvalue ge e le m a b o bf ->
      pc (flv' a) b o /\ (bf = Full \/ fblk (flv' a) = flv' a).
  Proof. exact (proj2 fx_sound_mut). Qed.

  Lemma fargs_sound : forall al tyl vl, eval_exprlist ge e le m al tyl vl ->
      forall pcs, fargs_ok ce FP pins lv tc al pcs = true -> Forall2 vok pcs vl.
  Proof.
    intros al tyl vl Hel. induction Hel; intros pcs Hok;
      destruct pcs as [| c pcs]; cbn [fargs_ok] in Hok; try discriminate Hok; [ constructor | ].
    apply andb_prop in Hok as [H1 H2].
    constructor; [ | exact (IHHel _ H2) ].
    intros bb oo E. subst.
    exact (fle_pc _ _ _ _ _ _ _ _ H1 (fx_sound _ _ H _ _ (sem_cast_vptr_inv _ _ _ _ _ _ H0))).
  Qed.
End KS.

(* ---------------------------------------------------------------------- *)
(* 3. Memory steps.                                                        *)
(* ---------------------------------------------------------------------- *)

Lemma free_list_unchanged_on : forall P l m m', Mem.free_list m l = Some m' ->
    (forall b lo hi i, In (b, lo, hi) l -> lo <= i < hi -> ~ P b i) ->
    Mem.unchanged_on P m m'.
Proof.
  intros P l. induction l as [| [[b lo] hi] l IH]; intros m m' Hf Hn; cbn in Hf.
  - injection Hf as <-. apply Mem.unchanged_on_refl.
  - destruct (Mem.free m b lo hi) as [m1|] eqn:E; [ | discriminate Hf ].
    eapply Mem.unchanged_on_trans.
    + eapply Mem.free_unchanged_on; [ exact E | ]. intros i Hi. exact (Hn b lo hi i (or_introl eq_refl) Hi).
    + apply (IH m1 m' Hf). intros b' lo' hi' i Hin Hi. exact (Hn b' lo' hi' i (or_intror Hin) Hi).
Qed.

Lemma av_unchanged_on : forall ge P e0 m vars e m1, alloc_variables ge e0 m vars e m1 ->
    Mem.unchanged_on P m m1.
Proof.
  intros ge P e0 m vars e m1 H. induction H.
  - apply Mem.unchanged_on_refl.
  - eapply Mem.unchanged_on_trans; [ eapply Mem.alloc_unchanged_on; eassumption | exact IHalloc_variables ].
Qed.

Lemma av_blocks : forall ge e0 m vars e m1 N, alloc_variables ge e0 m vars e m1 ->
    (forall x b ty, e0 ! x = Some (b, ty) -> Ple N b /\ Plt b (Mem.nextblock m)) ->
    Ple N (Mem.nextblock m) ->
    forall x b ty, e ! x = Some (b, ty) -> Ple N b /\ Plt b (Mem.nextblock m1).
Proof.
  intros ge e0 m vars e m1 N H. induction H as [e0 m | e0 m id ty vars0 m1 b1 m2 e2 Hal Hrest IH];
    intros He0 Hn; [ exact He0 | ].
  pose proof (Mem.nextblock_alloc _ _ _ _ _ Hal) as Nb.
  pose proof (Mem.alloc_result _ _ _ _ _ Hal) as Rb.
  apply IH.
  - intros x b ty' Hx. destruct (peq x id) as [-> | Hne].
    + rewrite PTree.gss in Hx. injection Hx as <- _. rewrite Rb, Nb.
      split; [ exact Hn | apply Plt_succ ].
    + rewrite PTree.gso in Hx by exact Hne. destruct (He0 _ _ _ Hx) as (H1 & H2).
      split; [ exact H1 | rewrite Nb; exact (Plt_trans_succ _ _ H2) ].
  - rewrite Nb. eapply Ple_trans; [ exact Hn | apply Ple_succ ].
Qed.

Lemma load_result_vptr : forall v b o, Val.load_result Mint32 v = Vptr b o -> v = Vptr b o.
Proof. intros v b o H. destruct v; cbn in H; try discriminate H; exact H. Qed.

Lemma fpar_ok_nth : forall tc ids pcs i x c,
    fpar_ok tc ids pcs = true -> nth_error ids i = Some x -> nth_error pcs i = Some c ->
    fle c (tc x) = true.
Proof.
  intros tc ids. induction ids as [| y ids IH]; intros pcs i x c H Hi Hc.
  - destruct i; discriminate Hi.
  - destruct pcs as [| d pcs]; [ destruct i; discriminate Hc | ].
    cbn [fpar_ok] in H. apply andb_prop in H as [H1 H2].
    destruct i as [| i]; cbn in Hi, Hc.
    + injection Hi as <-. injection Hc as <-. exact H1.
    + exact (IH _ _ _ _ H2 Hi Hc).
Qed.

Lemma assign_store : forall (ge : genv) ty m loc ofs bf v m', assign_loc ge ty m loc ofs bf v m' ->
    MtxfBody.is_byval ty = true ->
    exists ch v', Mem.store ch m loc (Ptrofs.unsigned ofs) v' = Some m' /\
      (bf = Full -> size_chunk ch = chunk_size_of ty /\ v' = v /\ access_mode ty = By_value ch).
Proof.
  intros ge ty m loc ofs bf v m' Ha Hbv. inv Ha.
  - match goal with Hm : access_mode _ = By_value ?ch, Hs : Mem.storev _ _ _ _ = Some _ |- _ =>
      exists ch, v; split; [ exact Hs | ]; intros _; unfold chunk_size_of; rewrite Hm; auto end.
  - unfold MtxfBody.is_byval in Hbv.
    match goal with Hm : access_mode _ = By_copy |- _ => rewrite Hm in Hbv; discriminate Hbv end.
  - match goal with Hb : store_bitfield _ _ _ _ _ _ _ _ _ _ |- _ => inv Hb end.
    match goal with Hs : Mem.storev _ _ _ _ = Some _ |- _ =>
      eexists; eexists; split; [ exact Hs | intros E; discriminate E ] end.
Qed.

(* ---------------------------------------------------------------------- *)
(* 4. The walk.                                                            *)
(* ---------------------------------------------------------------------- *)

Section WALK.
  Variable ge : genv.
  Variable FP : list ident.
  Variable pins : list (ident * fcls).
  Variables (cb : block) (co SZ : Z) (nl : block).
  Hypothesis HSZ : 0 <= co /\ co + SZ <= Ptrofs.max_unsigned.
  Hypothesis HG : forall g b, Genv.find_symbol ge g = Some b -> Plt b nl.
  Hypothesis HPfp : forall x c, pin_of x pins = Some c -> mem_idf x FP = false.
  Hypothesis HPcb : forall x c b, pin_of x pins = Some c -> Genv.find_symbol ge x = Some b -> b <> cb.

  (* THE CARRIED INVARIANT and THE LEAVES' EXTRA FOOTPRINT (2026-11-02).
     Inv is a memory predicate the walk keeps (CamFootInst: AudioInv); it
     must survive every change outside the walk's own store targets (FP's
     blocks, new blocks, the Camera's bytes, the pin cells) -- HInv.  The
     walked bodies never store outside those targets; a LEAF may also
     change the blocks of XP's globals (CamFootInst: the audio heap and
     sequence-player globals, which only the audio leaves write), and must
     keep Inv itself. *)
  Variable XP : list ident.
  Variable Inv : mem -> Prop.
  Hypothesis HInv : forall m m', Ple nl (Mem.nextblock m) ->
    Mem.unchanged_on (fun b z => ~ (FB0 ge FP b \/ Ple nl b \/ (b = cb /\ co <= z < co + SZ)) /\
                                  ~ (exists x c, pin_of x pins = Some c /\ Genv.find_symbol ge x = Some b /\ 0 <= z < 4))
      m m' -> Inv m -> Inv m'.

  Definition vokm (m : mem) := fvok (FBn ge FP nl (Mem.nextblock m)) cb co SZ.
  Definition pcm (m : mem) := fpc (FBn ge FP nl (Mem.nextblock m)) cb co SZ.

  (* THE PINS: each pin global's cell holds a value of its class; and the
     carried invariant *)
  Definition PinsV (m : mem) : Prop :=
    forall x c b, pin_of x pins = Some c -> Genv.find_symbol ge x = Some b ->
      forall v, Mem.load Mint32 m b 0 = Some v -> vokm m c v.
  Definition Pins (m : mem) : Prop := PinsV m /\ Inv m.

  (* THE FOOTPRINT: FP's blocks, blocks born since nl, the Camera's bytes;
     and the pins' cells *)
  Definition A0 (b : block) (z : Z) : Prop :=
    FB0 ge FP b \/ Ple nl b \/ (b = cb /\ co <= z < co + SZ).
  Definition PCell (b : block) (z : Z) : Prop :=
    exists x c, pin_of x pins = Some c /\ Genv.find_symbol ge x = Some b /\ 0 <= z < 4.
  Definition Qf (b : block) (z : Z) : Prop := ~ A0 b z /\ ~ PCell b z /\ ~ FB0 ge XP b.

  Definition FR (m m' : mem) : Prop := PK m m' /\ Mem.unchanged_on Qf m m'.
  Definition St (m : mem) : Prop := Pins m /\ Ple nl (Mem.nextblock m).

  Lemma FR_refl : forall m, FR m m.
  Proof. intros m. split; [ apply PK_refl | apply Mem.unchanged_on_refl ]. Qed.

  Lemma FR_trans : forall m1 m2 m3, FR m1 m2 -> FR m2 m3 -> FR m1 m3.
  Proof.
    intros m1 m2 m3 (P1 & U1) (P2 & U2).
    split; [ exact (PK_trans _ _ _ P1 P2) | exact (Mem.unchanged_on_trans _ _ _ _ U1 U2) ].
  Qed.

  Lemma FR_nb : forall m m', FR m m' -> Ple (Mem.nextblock m) (Mem.nextblock m').
  Proof. intros m m' (P & _). exact (proj1 P). Qed.

  Lemma pin_not_A0 : forall x c b z, pin_of x pins = Some c -> Genv.find_symbol ge x = Some b -> ~ A0 b z.
  Proof.
    intros x c b z Hp Hs [(g & Hg & Hsg) | [Hl | (E & _)]].
    - assert (E : g = x) by (eapply Genv.genv_vars_inj; eassumption). subst g.
      rewrite (HPfp _ _ Hp) in Hg. discriminate Hg.
    - exact (Plt_strict _ (Plt_Ple_trans _ _ _ (HG _ _ Hs) Hl)).
    - exact (HPcb _ _ _ Hp Hs E).
  Qed.

  Lemma pins_unch : forall m m', Pins m -> Ple nl (Mem.nextblock m) ->
      Mem.unchanged_on (fun b z => ~ A0 b z) m m' -> Pins m'.
  Proof.
    intros m m' (HP & HI) Hnl U. split.
    - intros x c b Hp Hs v Hl.
      assert (Hv : Mem.valid_block m b) by (unfold Mem.valid_block; exact (Plt_Ple_trans _ _ _ (HG _ _ Hs) Hnl)).
      rewrite (Mem.load_unchanged_on_1 _ _ _ _ _ _ U Hv) in Hl.
      + exact (fvok_mono _ _ _ _ _ _ _ _ _ _ (Mem.unchanged_on_nextblock _ _ _ U) (HP _ _ _ Hp Hs _ Hl)).
      + intros i _. exact (pin_not_A0 _ _ _ _ Hp Hs).
    - refine (HInv m m' Hnl _ HI).
      eapply Mem.unchanged_on_implies; [ exact U | ]. intros b z (N & _) _. exact N.
  Qed.

  (* the pin half needs only the pin cells (a leaf that writes XP) *)
  Lemma pinsV_unch : forall m m', PinsV m -> Ple nl (Mem.nextblock m) ->
      Mem.unchanged_on PCell m m' -> PinsV m'.
  Proof.
    intros m m' HP Hnl U x c b Hp Hs v Hl.
    assert (Hv : Mem.valid_block m b) by (unfold Mem.valid_block; exact (Plt_Ple_trans _ _ _ (HG _ _ Hs) Hnl)).
    rewrite (Mem.load_unchanged_on_1 _ _ _ _ _ _ U Hv) in Hl.
    - exact (fvok_mono _ _ _ _ _ _ _ _ _ _ (Mem.unchanged_on_nextblock _ _ _ U) (HP _ _ _ Hp Hs _ Hl)).
    - intros i Hi. exists x, c. cbn in Hi. split; [ exact Hp | split; [ exact Hs | lia ] ].
  Qed.

  Lemma store_A0 : forall ch m b z v m', Mem.store ch m b z v = Some m' ->
      (forall i, z <= i < z + size_chunk ch -> A0 b i) -> St m -> FR m m' /\ St m'.
  Proof.
    intros ch m b z v m' Hst HA (HP & Hnl).
    assert (U : Mem.unchanged_on (fun b z => ~ A0 b z) m m')
      by (eapply Mem.store_unchanged_on; [ exact Hst | intros i Hi N; exact (N (HA i Hi)) ]).
    split; [ split; [ exact (PK_store _ _ _ _ _ _ Hst) | ] | split ].
    - eapply Mem.store_unchanged_on; [ exact Hst | ]. intros i Hi (N & _). exact (N (HA i Hi)).
    - exact (pins_unch _ _ HP Hnl U).
    - rewrite (Mem.nextblock_store _ _ _ _ _ _ Hst). exact Hnl.
  Qed.

  Lemma store_pin : forall x c bg m v m', pin_of x pins = Some c -> Genv.find_symbol ge x = Some bg ->
      Mem.store Mint32 m bg 0 v = Some m' -> vokm m c v -> St m -> FR m m' /\ St m'.
  Proof.
    intros x c bg m v m' Hp Hs Hst Hv ((HP & HI) & Hnl).
    assert (Nb : Mem.nextblock m' = Mem.nextblock m) by exact (Mem.nextblock_store _ _ _ _ _ _ Hst).
    split; [ split; [ exact (PK_store _ _ _ _ _ _ Hst) | ] | split; [ split | ] ].
    - eapply Mem.store_unchanged_on; [ exact Hst | ]. intros i Hi (_ & N & _). apply N.
      exists x, c. cbn in Hi. split; [ exact Hp | split; [ exact Hs | lia ] ].
    - intros x' c' b' Hp' Hs' v' Hl. unfold vokm. rewrite Nb.
      destruct (peq b' bg) as [-> | Hne].
      + assert (E : x' = x) by (eapply Genv.genv_vars_inj; eassumption). subst x'.
        rewrite Hp in Hp'. injection Hp' as <-.
        rewrite (Mem.load_store_same _ _ _ _ _ _ Hst) in Hl. injection Hl as <-.
        intros bb oo E. exact (Hv bb oo (load_result_vptr _ _ _ E)).
      + rewrite (Mem.load_store_other _ _ _ _ _ _ Hst) in Hl by (left; exact Hne).
        exact (HP _ _ _ Hp' Hs' _ Hl).
    - refine (HInv m m' Hnl _ HI).
      eapply Mem.store_unchanged_on; [ exact Hst | ]. intros i Hi (_ & N). apply N.
      exists x, c. cbn in Hi. split; [ exact Hp | split; [ exact Hs | lia ] ].
    - rewrite Nb. exact Hnl.
  Qed.

  (* a store through an address of class c *)
  Lemma cls_store_A0 : forall m c loc ofs bf ch s,
      pcm m c loc ofs -> (bf = Full \/ fblk c = c) -> fstorable c s = true ->
      (bf = Full -> size_chunk ch = s) ->
      forall i, Ptrofs.unsigned ofs <= i < Ptrofs.unsigned ofs + size_chunk ch -> A0 loc i.
  Proof.
    intros m c loc ofs bf ch s Hpc Hbf Hst Hsz i Hi.
    destruct c as [ | | n | n | ]; cbn [fstorable] in Hst; try discriminate Hst.
    - contradiction Hpc.
    - destruct Hpc as [F | (F1 & _)]; [ left; exact F | right; left; exact F1 ].
    - destruct Hbf as [-> | E]; [ | discriminate E ].
      apply Z.leb_le in Hst. specialize (Hsz eq_refl).
      destruct Hpc as (-> & H1 & H2). right; right. split; [ reflexivity | lia ].
    - destruct Hbf as [-> | E]; [ | discriminate E ].
      apply Z.leb_le in Hst. specialize (Hsz eq_refl).
      destruct Hpc as [[F | (F1 & _)] | (-> & H1 & H2)];
        [ left; exact F | right; left; exact F1 | right; right; split; [ reflexivity | lia ] ].
  Qed.

  Definition KTP (m : mem) (tc : ident -> fcls) (le : temp_env) : Prop :=
    forall t v, le ! t = Some v -> vokm m (tc t) v.
  Definition KEIL (m : mem) (lv : list ident) (e : env) : Prop :=
    (forall x b ty, e ! x = Some (b, ty) -> mem_idf x lv = true /\ Ple nl b /\ Plt b (Mem.nextblock m)) /\
    (forall x, mem_idf x lv = true -> e ! x <> None).
  Definition CEok (ce : composite_env) : Prop :=
    forall id c, ce ! id = Some c -> (genv_cenv ge) ! id = Some c.
  Definition out_ok (m : mem) (rc : fcls) (out : outcome) : Prop :=
    match out with Out_return (Some (v, _)) => vokm m rc v | _ => True end.

  Lemma KTP_mono : forall m m' tc le, Ple (Mem.nextblock m) (Mem.nextblock m') -> KTP m tc le -> KTP m' tc le.
  Proof. intros m m' tc le H HP t v Hg. exact (fvok_mono _ _ _ _ _ _ _ _ _ _ H (HP t v Hg)). Qed.

  Lemma KEIL_mono : forall m m' lv e, Ple (Mem.nextblock m) (Mem.nextblock m') -> KEIL m lv e -> KEIL m' lv e.
  Proof.
    intros m m' lv e H (H1 & H2). split; [ | exact H2 ].
    intros x b ty Hx. destruct (H1 _ _ _ Hx) as (A & B & C).
    split; [ exact A | split; [ exact B | exact (Plt_Ple_trans _ _ _ C H) ] ].
  Qed.

  (* the per-function spec *)
  Definition fspec (fd : Clight.fundef) (s : fsig) : Prop :=
    let '(pcs, rc) := s in
    forall m vargs t m' vres,
      eval_funcall function_entry2 ge m fd vargs t m' vres ->
      Forall2 (vokm m) pcs vargs -> St m -> FR m m' /\ St m' /\ vokm m' rc vres.

  (* ---- a function's frame: entry, body, return ---- *)
  Lemma cf_wrap : forall f vargs m e le1 m1 m2 out vres m3 rc,
      function_entry2 ge f vargs m e le1 m1 ->
      outcome_result_value out (fn_return f) vres m2 ->
      Mem.free_list m2 (blocks_of_env ge e) = Some m3 ->
      St m ->
      (St m1 -> FR m1 m2 /\ St m2 /\ out_ok m2 rc out) ->
      FR m m3 /\ St m3 /\ vokm m3 rc vres.
  Proof.
    intros f vargs m e le1 m1 m2 out vres m3 rc Hentry Hor Hfree (HP & Hnl) Hbody.
    inv Hentry.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ => rename Ha into Hav end.
    match goal with Hn : list_norepet (var_names (fn_vars f)) |- _ => rename Hn into Hnr end.
    destruct (av_old ge _ _ _ _ _ Hav) as (N1 & P1).
    pose proof (av_blocks ge _ _ _ _ _ (Mem.nextblock m) Hav
                  ltac:(intros x b ty Hx; rewrite PTree.gempty in Hx; discriminate Hx)
                  (Ple_refl _)) as Hblk.
    assert (Hs1 : St m1).
    { split; [ exact (pins_unch _ _ HP Hnl (av_unchanged_on _ _ _ _ _ _ _ Hav)) | exact (Ple_trans _ _ _ Hnl N1) ]. }
    destruct (Hbody Hs1) as ((PK2 & U2) & (HP2 & Hnl2) & Hout).
    assert (Fr : forall id b ty, e ! id = Some (b, ty) -> ~ Mem.valid_block m b).
    { intros id b ty He. destruct (Hblk _ _ _ He) as (B1 & _). unfold Mem.valid_block.
      intros V. exact (Plt_strict _ (Plt_Ple_trans _ _ _ V B1)). }
    assert (Hfresh : forall b lo hi i, In (b, lo, hi) (blocks_of_env ge e) -> lo <= i < hi -> A0 b i).
    { intros b lo hi i Hin _. destruct (boe_inv ge _ _ _ _ Hin) as (id & ty & He).
      destruct (Hblk _ _ _ He) as (B1 & _). right; left. exact (Ple_trans _ _ _ Hnl B1). }
    assert (Nb3 : Mem.nextblock m3 = Mem.nextblock m2) by exact (fl_next _ _ _ Hfree).
    split; [ split | split; [ split | ] ].
    - destruct PK2 as (N2 & P2 & F2).
      split; [ | split ].
      + rewrite Nb3. exact (Ple_trans _ _ _ N1 N2).
      + intros b o k p Hv.
        assert (Hv1 : Mem.valid_block m1 b) by (unfold Mem.valid_block in *; eapply Plt_Ple_trans; eassumption).
        rewrite (P1 b o k p Hv), (P2 b o k p Hv1).
        split; [ | exact (fl_back _ _ _ _ _ _ _ Hfree) ].
        apply (fl_keep _ _ _ _ _ _ _ Hfree).
        intros lo hi Hin. destruct (boe_inv ge _ _ _ _ Hin) as (id & ty & He). exact (Fr id b ty He Hv).
      + intros b o k p Hv Hp.
        pose proof (fl_back _ _ _ _ _ _ _ Hfree Hp) as Hp2.
        destruct (plt b (Mem.nextblock m1)) as [V1 | V1]; [ | exact (F2 b o k p V1 Hp2) ].
        apply (P2 b o k p V1) in Hp2.
        destruct (av_new ge _ _ _ _ _ (Mem.nextblock m) Hav Hnr
                    ltac:(intros b0 o0 k0 p0 Hn Hp0; exfalso; exact (Hn (Mem.perm_valid_block _ _ _ _ _ Hp0)))
                    b o k p Hv Hp2) as (id & ty & He & R).
        exact (fl_kill _ _ _ _ _ _ _ _ _ Hfree (boe_in ge _ _ _ _ He) R Hp).
    - eapply Mem.unchanged_on_trans; [ exact (av_unchanged_on _ _ _ _ _ _ _ Hav) | ].
      eapply Mem.unchanged_on_trans; [ exact U2 | ].
      apply (free_list_unchanged_on _ _ _ _ Hfree).
      intros b lo hi i Hin Hi (N & _). exact (N (Hfresh _ _ _ _ Hin Hi)).
    - refine (pins_unch _ _ HP2 Hnl2 _).
      apply (free_list_unchanged_on _ _ _ _ Hfree).
      intros b lo hi i Hin Hi N. exact (N (Hfresh _ _ _ _ Hin Hi)).
    - rewrite Nb3. exact Hnl2.
    - intros bb oo Ev. subst vres. unfold vokm. rewrite Nb3.
      destruct out as [ | | | [[v' t']|] ]; cbn in Hor.
      + contradiction Hor.
      + contradiction Hor.
      + destruct (fn_return f); try contradiction Hor; discriminate Hor.
      + destruct Hor as (_ & Hc). exact (Hout _ _ (sem_cast_vptr_inv _ _ _ _ _ _ Hc)).
      + destruct (fn_return f); try contradiction Hor; discriminate Hor.
  Qed.

  (* ---- THE SHADOW LEAVES (the AVOID_UB vec helpers).  The body first
     copies a pointer parameter d into a same-named stack local and then
     reloads it for every access; the walk's loads lose the class, so these
     are proved here: the local holds the parameter's value throughout (no
     store can reach it: every store goes through that value, whose block
     is older than the local), and every store is a constant-index scalar
     store within n bytes of it. *)
  Hypothesis Hcbnl : Plt cb nl.

  Definition sh_set (d : ident) (ds : list ident) (id : ident) (a : expr) : bool :=
    negb (mem_idf id ds) ||
    match a with
    | Evar x tx => Pos.eqb x d && match access_mode tx with By_value Mint32 => true | _ => false end
    | _ => false
    end.

  Definition sh_store (ds : list ident) (n : Z) (l r : expr) : bool :=
    MtxfBody.is_byval (typeof l) &&
    match l with
    | Ederef (Ebinop Oadd (Etempvar x tx) k _) _ =>
        mem_idf x ds &&
        match cidx k, elt_of tx with
        | Some kk, Some t =>
            match scal_size t with
            | Some sz => (0 <=? kk * sz) && (kk * sz + chunk_size_of (typeof l) <=? n)
            | None => false
            end
        | _, _ => false
        end
    | _ => false
    end.

  Definition sh_ret (d : ident) (a : expr) : bool :=
    match a with Eaddrof (Evar x _) _ => Pos.eqb x d | _ => false end.

  Lemma alloc_one : forall m d ty e m1, alloc_variables ge empty_env m [(d, ty)] e m1 ->
      Mem.alloc m 0 (sizeof ge ty) = (m1, Mem.nextblock m) /\ e = PTree.set d (Mem.nextblock m, ty) empty_env.
  Proof.
    intros m d ty e m1 H. inv H.
    match goal with Hn : alloc_variables _ _ _ nil _ _ |- _ => inv Hn end.
    match goal with Ha : Mem.alloc _ _ _ = (_, ?b) |- _ =>
      pose proof (Mem.alloc_result _ _ _ _ _ Ha) as E; subst b; split; [ exact Ha | reflexivity ] end.
  Qed.

  Lemma seq_normal_inv : forall e le m s1 s2 t le' m' out,
      exec_stmt function_entry2 ge e le m (Ssequence s1 s2) t le' m' out ->
      (forall t1 le1 m1 out1, exec_stmt function_entry2 ge e le m s1 t1 le1 m1 out1 -> out1 = Out_normal) ->
      exists t1 le1 m1 t2, exec_stmt function_entry2 ge e le m s1 t1 le1 m1 Out_normal /\
                           exec_stmt function_entry2 ge e le1 m1 s2 t2 le' m' out.
  Proof.
    intros e le m s1 s2 t le' m' out H Hn. inv H.
    - do 4 eexists. split; eassumption.
    - exfalso. match goal with H1 : exec_stmt _ _ _ _ _ s1 _ _ _ ?o, Hne : ?o <> Out_normal |- _ =>
        exact (Hne (Hn _ _ _ _ H1)) end.
  Qed.

  Lemma assign_normal : forall e le m l r t le' m' out,
      exec_stmt function_entry2 ge e le m (Sassign l r) t le' m' out -> out = Out_normal /\ le' = le.
  Proof. intros. inv H. split; reflexivity. Qed.

  Lemma shadow_first : forall e le m d ty L t le' m' out,
      e = PTree.set d (L, ty) empty_env -> access_mode ty = By_value Mint32 ->
      exec_stmt function_entry2 ge e le m (Sassign (Evar d ty) (Etempvar d ty)) t le' m' out ->
      exists v vv, le ! d = Some v /\ sem_cast v ty ty m = Some vv /\
                   Mem.store Mint32 m L 0 vv = Some m' /\ le' = le.
  Proof.
    intros e le m d ty L t le' m' out -> Hty H. inv H.
    match goal with Hl : eval_lvalue _ _ _ _ (Evar d ty) _ _ _ |- _ => inv Hl end.
    - match goal with Hx : (PTree.set d _ _) ! d = Some _ |- _ =>
        rewrite PTree.gss in Hx; injection Hx; intros; subst end.
      match goal with Hr : eval_expr _ _ _ _ (Etempvar d ty) _ |- _ => inv Hr end;
        [ | match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl end ].
      match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ =>
        destruct (assign_store _ _ _ _ _ _ _ _ Ha ltac:(cbn [typeof]; unfold MtxfBody.is_byval; rewrite Hty; reflexivity))
          as (ch & vv & Hst & Hfull) end.
      destruct (Hfull eq_refl) as (_ & -> & Ech). cbn [typeof] in Ech. rewrite Hty in Ech. injection Ech as <-.
      do 2 eexists. split; [ eassumption | split; [ eassumption | split; [ exact Hst | reflexivity ] ] ].
    - match goal with Hx : (PTree.set d _ _) ! d = None |- _ => rewrite PTree.gss in Hx; discriminate Hx end.
  Qed.

  Lemma sh_store_inv : forall ds n l r, sh_store ds n l r = true ->
      exists x tx k tyb ty kk t sz, l = Ederef (Ebinop Oadd (Etempvar x tx) k tyb) ty /\
        mem_idf x ds = true /\ cidx k = Some kk /\ elt_of tx = Some t /\ scal_size t = Some sz /\
        0 <= kk * sz /\ kk * sz + chunk_size_of ty <= n /\ MtxfBody.is_byval ty = true.
  Proof.
    intros ds n l r H. unfold sh_store in H. apply andb_prop in H as [Hb H].
    destruct l as [ | | | | | | a ty | | | | | | | ]; try discriminate H.
    destruct a as [ | | | | | | | | | op a1 k tyb | | | | ]; try discriminate H.
    destruct op; try discriminate H.
    destruct a1 as [ | | | | | x tx | | | | | | | | ]; try discriminate H.
    apply andb_prop in H as [Hx H].
    destruct (cidx k) as [kk|] eqn:Ek; [ | discriminate H ].
    destruct (elt_of tx) as [t|] eqn:Et; [ | discriminate H ].
    destruct (scal_size t) as [sz|] eqn:Es; [ | discriminate H ].
    apply andb_prop in H as [H1 H2]. apply Z.leb_le in H1. apply Z.leb_le in H2.
    exists x, tx, k, tyb, ty, kk, t, sz. cbn [typeof] in *.
    repeat split; assumption.
  Qed.

  Lemma shadow_leaf : forall f d ty n ds pcs rc rest,
      fn_vars f = [(d, ty)] ->
      access_mode ty = By_value Mint32 ->
      fn_body f = Ssequence (Sassign (Evar d ty) (Etempvar d ty)) rest ->
      SpawnBodies.sw_chk (sh_set d ds) (sh_store ds n) (fun _ _ _ => false) (sh_ret d) rest = true ->
      fpar_ok (fun x => if Pos.eqb x d then fFC n else fA) (map fst (fn_params f)) pcs = true ->
      forallb (fun x => negb (mem_idf x (map fst (fn_params f)))) ds = true ->
      fle fF rc = true ->
      fspec (Internal f) (pcs, rc).
  Proof.
    intros f d ty n ds pcs rc rest Hvars Hty Hbody Hchk Hpar Hds Hrc
      m vargs t m3 vres Hev Hva Hs.
    inv Hev.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry end.
    match goal with Ho : outcome_result_value _ _ _ _ |- _ => rename Ho into Hor end.
    match goal with Hf : Mem.free_list _ _ = Some _ |- _ => rename Hf into Hfree end.
    match goal with Hb : exec_stmt _ _ _ _ _ (fn_body f) _ _ _ _ |- _ => rename Hb into Hx end.
    refine (cf_wrap _ _ _ _ _ _ _ _ _ _ _ Hentry Hor Hfree Hs _).
    intros Hs1.
    pose proof Hentry as Hentry'. inv Hentry'.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ => rename Ha into Hav end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ => rename Hb into Hbp end.
    rewrite Hvars in Hav. destruct (alloc_one _ _ _ _ _ Hav) as (Hal & ->).
    set (L := Mem.nextblock m) in *.
    rewrite Hbody in Hx.
    destruct (seq_normal_inv _ _ _ _ _ _ _ _ _ Hx
                (fun t1 le1 m1 out1 H1 => proj1 (assign_normal _ _ _ _ _ _ _ _ _ H1)))
      as (t1 & leA & mA & t2 & Hx1 & Hx2).
    destruct (shadow_first _ _ _ _ _ _ _ _ _ _ eq_refl Hty Hx1) as (v0 & vv & Hd0 & Hc0 & Hst0 & ->).

    destruct Hs as (HPm & Hnlm).
    pose proof (Mem.nextblock_alloc _ _ _ _ _ Hal) as Nb1.
    assert (HnlL : Ple nl L) by exact Hnlm.
    set (dv := Val.load_result Mint32 vv).
    (* the stored pointer's class, at the call's nextblock L *)
    assert (Hdv : forall b o, dv = Vptr b o -> pcm m (fFC n) b o).
    { intros b o E. pose proof (load_result_vptr _ _ _ E) as E1.
      rewrite E1 in Hc0. pose proof (sem_cast_vptr_inv _ _ _ _ _ _ Hc0) as E2. subst v0.
      destruct (ObjHelpersBodies.bind_get _ _ _ _ _ _ Hbp Hd0) as [Hu | (i & Hi & Hvi)].
      - apply MtxfBody.create_undef_temps_get in Hu. discriminate Hu.
      - destruct (PrintBodies.forall2_nth_l _ _ _ _ _ Hva Hvi) as (c & Hc).
        pose proof (fpar_ok_nth _ _ _ _ _ _ Hpar Hi Hc) as Hle. cbv beta in Hle. rewrite Pos.eqb_refl in Hle.
        exact (fle_pc _ _ _ _ _ _ _ _ Hle (PrintBodies.forall2_nth _ _ _ _ _ _ Hva Hc Hvi _ _ eq_refl)). }
    assert (HdL : forall b o, dv = Vptr b o -> b <> L).
    { intros b o E Eb. subst b. pose proof (Hdv _ _ E) as Hp.
      unfold pcm, fpc, FBn in Hp.
      destruct Hp as [[(g & _ & Hsg) | (_ & Hlt)] | (Ecb & _)].
      - exact (Plt_strict _ (Plt_Ple_trans _ _ _ (HG _ _ Hsg) HnlL)).
      - exact (Plt_strict _ Hlt).
      - rewrite Ecb in HnlL. exact (Plt_strict _ (Plt_Ple_trans _ _ _ Hcbnl HnlL)). }
    (* the shadow store *)
    destruct (store_A0 _ _ _ _ _ _ Hst0 ltac:(intros i _; right; left; exact HnlL) Hs1) as (HFA & HsA).
    assert (HLA : Mem.load Mint32 mA L 0 = Some dv) by exact (Mem.load_store_same _ _ _ _ _ _ Hst0).
    set (ShI := fun mm => FR m1 mm /\ St mm /\ Mem.load Mint32 mm L 0 = Some dv).
    set (P := fun le => forall x b o, mem_idf x ds = true -> le ! x = Some (Vptr b o) -> dv = Vptr b o).
    set (Q := fun v => v = Vptr L Ptrofs.zero).
    set (e := PTree.set d (L, ty) empty_env).
    assert (Hloc : forall le mm x tx loc ofs bf, eval_lvalue ge e le mm (Evar x tx) loc ofs bf -> x = d ->
              loc = L /\ ofs = Ptrofs.zero /\ bf = Full).
    { intros le mm x tx loc ofs bf Hl ->. unfold e in Hl. inv Hl.
      - match goal with Hx : (PTree.set d _ _) ! d = Some _ |- _ =>
          rewrite PTree.gss in Hx; injection Hx; intros; subst end.
        auto.
      - match goal with Hx : (PTree.set d _ _) ! d = None |- _ => rewrite PTree.gss in Hx; discriminate Hx end. }
    assert (Hset : forall id a le mm v, sh_set d ds id a = true -> P le -> ShI mm ->
              eval_expr ge e le mm a v -> P (PTree.set id v le)).
    { intros id a le mm v Hok HP0 (_ & _ & HL) Hev x b o Hxm Hg.
      destruct (peq x id) as [-> | Hne].
      - rewrite PTree.gss in Hg. injection Hg as ->.
        unfold sh_set in Hok. rewrite Hxm in Hok. cbn [negb orb] in Hok.
        destruct a; try discriminate Hok. apply andb_prop in Hok as [Ex Hm].
        apply Pos.eqb_eq in Ex. subst i.
        inv Hev.
        match goal with Hl : eval_lvalue _ _ _ _ (Evar d _) _ _ _ |- _ =>
            destruct (Hloc _ _ _ _ _ _ _ Hl eq_refl) as (-> & -> & ->) end.
          match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => inv Hd end; cbn [typeof] in *;
            try (match goal with Ha : access_mode _ = _ |- _ => rewrite Ha in Hm; discriminate Hm end).
          match goal with Ha : access_mode _ = By_value ?ch, Hl : Mem.loadv _ _ _ = Some _ |- _ =>
            rewrite Ha in Hm; destruct ch; try discriminate Hm; unfold Mem.loadv in Hl;
            rewrite Ptrofs.unsigned_zero, HL in Hl;
            injection Hl as <-; reflexivity end.
      - rewrite PTree.gso in Hg by exact Hne. exact (HP0 _ _ _ Hxm Hg). }
    assert (Hstore : forall l r le mm t le' m' out, sh_store ds n l r = true -> P le ->
              exec_stmt function_entry2 ge e le mm (Sassign l r) t le' m' out -> ShI mm -> ShI m').
    { intros l r le mm t0 le0 m0 out0 Hok HP0 Hx0 (HF0 & Hs0 & HL0).
      destruct (sh_store_inv _ _ _ _ Hok) as (x & tx & k & tyb & ty' & kk & t' & sz & -> & Hxd & Ek & Et & Es & Hk0 & Hkn & Hbv).
      inv Hx0.
      match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ => rename Ha into Ha0 end.
      destruct (assign_store _ _ _ _ _ _ _ _ Ha0 Hbv) as (ch & vv' & Hst & Hfull).
      match goal with Hl : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hl end.
      match goal with Hb : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ => inv Hb end;
        [ | match goal with Hl : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ => inv Hl end ].
      match goal with Ht : eval_expr _ _ _ _ (Etempvar x tx) _ |- _ => inv Ht end;
        [ | match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl end ].
      match goal with Hk : eval_expr _ _ _ _ k ?v2, Hs : sem_binary_operation _ Oadd _ _ ?v2 _ _ = Some _ |- _ =>
        assert (Hv2 : v2 = match k with Econst_int n0 _ => Vint n0 | _ => Vundef end)
          by (destruct k; try discriminate Ek; inv Hk; [ reflexivity |
                match goal with Hl : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv Hl end ]);
        cbn [sem_binary_operation] in Hs;
        destruct (sem_add_cidx _ _ _ _ _ _ _ _ _ _ _ Ek Et Es Hv2 Hs) as (o1 & E1 & Eo) end.
      subst.
      match goal with Hg : _ ! x = Some (Vptr ?l ?o) |- _ => pose proof (HP0 _ _ _ Hxd Hg) as Edv end.
      pose proof (Hdv _ _ Edv) as Hpc.
      assert (Hle0 : Ple (Mem.nextblock m) (Mem.nextblock mm)).
      { destruct HF0 as ((N0 & _) & _). rewrite Nb1 in N0. eapply Ple_trans; [ apply Ple_succ | exact N0 ]. }
      pose proof (fshift_pc _ _ _ _ _ _ _ (kk * sz) (proj1 HSZ) (proj2 HSZ) Hpc) as Hsh.
      pose proof (fpc_mono _ _ _ _ _ _ _ _ _ _ _ Hle0 Hsh) as Hsh'.
      assert (Hcs : 0 <= chunk_size_of ty').
      { unfold chunk_size_of. destruct (access_mode ty') as [ch0 | | | ]; try lia. pose proof (size_chunk_pos ch0); lia. }
      assert (Efs : fshift (fFC n) (kk * sz) = fFC (n - kk * sz)).
      { cbn [fshift]. replace ((0 <=? kk * sz) && (kk * sz <=? n)) with true; [ reflexivity | ].
        symmetry. apply andb_true_iff. split; apply Z.leb_le; lia. }
      rewrite Efs in Hsh'.
      destruct (store_A0 _ _ _ _ _ _ Hst
                  (cls_store_A0 mm _ _ _ Full ch (chunk_size_of ty') Hsh' (or_introl eq_refl)
                     ltac:(cbn [fstorable]; apply Z.leb_le; lia)
                     (fun _ => proj1 (Hfull eq_refl)))
                  Hs0) as (HF1 & Hs1').
      split; [ exact (FR_trans _ _ _ HF0 HF1) | split; [ exact Hs1' | ] ].
      rewrite (Mem.load_store_other _ _ _ _ _ _ Hst) by (left; intros E; exact (HdL _ _ Edv (eq_sym E))).
      exact HL0. }
    assert (Hcall : forall optid a al le mm t le' m' out, (fun _ _ _ => false) optid a al = true -> P le ->
              exec_stmt function_entry2 ge e le mm (Scall optid a al) t le' m' out ->
              ShI mm -> ShI m' /\ P le').
    { intros. discriminate. }
    assert (Hret : forall a le mm v, sh_ret d a = true -> P le -> ShI mm -> eval_expr ge e le mm a v -> Q v).
    { intros a le mm v Hok _ _ Hev. unfold sh_ret in Hok.
      destruct a; try discriminate Hok. destruct a; try discriminate Hok.
      apply Pos.eqb_eq in Hok. subst i.
      inv Hev; [ | match goal with Hl : eval_lvalue _ _ _ _ (Eaddrof _ _) _ _ _ |- _ => inv Hl end ].
      match goal with Hl : eval_lvalue _ _ _ _ (Evar d _) _ _ _ |- _ =>
        destruct (Hloc _ _ _ _ _ _ _ Hl eq_refl) as (-> & -> & _) end.
      reflexivity. }
    assert (HP1 : P le1).
    { intros x b o Hxm Hg.
      destruct (ObjHelpersBodies.bind_get _ _ _ _ _ _ Hbp Hg) as [Hu | (i & Hi & Hvi)].
      - apply MtxfBody.create_undef_temps_get in Hu. discriminate Hu.
      - exfalso. pose proof (proj1 (forallb_forall _ _) Hds x (inl_id_In _ _ Hxm)) as Hn.
        apply negb_true_iff in Hn. apply (inl_id_notin _ _ Hn).
        exact (nth_error_In _ _ Hi). }
    destruct (SpawnBodies.sw_walk ge e ShI P Q (sh_set d ds) (sh_store ds n) (fun _ _ _ => false) (sh_ret d)
                Hset Hstore Hcall Hret e _ _ _ _ _ _ _ Hx2 eq_refl Hchk HP1
                (conj HFA (conj HsA HLA))) as ((HF2 & Hs2 & _) & _ & Hout).
    split; [ exact HF2 | split; [ exact Hs2 | ] ].
    destruct out as [ | | | [[v' t']|] ]; cbn in Hout |- *; try exact I.
    rewrite Hout. intros bb oo E. injection E as <- <-.
    refine (fle_pc _ _ _ _ _ _ _ _ Hrc _). cbn [fpc]. right. split; [ exact HnlL | ].
    destruct HF2 as ((N2 & _) & _). rewrite Nb1 in N2.
    exact (Plt_Ple_trans _ _ _ (Plt_succ _) N2).
  Qed.

  Variable tab : ftab.
  Variable it : fitab.
  Variable Leaf : Clight.fundef -> fsig -> Prop.
  Hypothesis HLeaf : forall fd s, Leaf fd s -> fspec fd s.

  Definition Good (fd : Clight.fundef) (s : fsig) : Prop :=
    (exists f ce, fd = Internal f /\ CEok ce /\ fchk ce FP pins tab it s f = true) \/ Leaf fd s.

  Definition TabGood : Prop :=
    forall fid s, ft_find fid tab = Some s ->
      forall b fd, Genv.find_symbol ge fid = Some b ->
        Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd -> Good fd s.

  Definition ItGood : Prop :=
    forall ty s, fit_find ty it = Some s ->
      forall vf fd, Genv.find_funct ge vf = Some fd -> type_of_fundef fd = ty ->
        exists se, Good fd se /\ ffits se s = true.

  Hypothesis HTab : TabGood.
  Hypothesis HIt : ItGood.

  Definition Pstmt (e : env) (le : temp_env) (m : mem) (s : statement) (t : trace)
      (le' : temp_env) (m' : mem) (out : outcome) : Prop :=
    exec_stmt function_entry2 ge e le m s t le' m' out /\
    forall ce lv tc rc, CEok ce -> KEIL m lv e ->
      SpawnBodies.sw_chk (fp_set ce FP pins lv tc) (fp_store ce FP pins lv tc)
        (fp_call ce FP pins tab it lv tc) (fp_ret ce FP pins lv tc rc) s = true ->
      KTP m tc le -> St m ->
      FR m m' /\ St m' /\ KTP m' tc le' /\ out_ok m' rc out.

  Definition Pfun (m : mem) (fd : Clight.fundef) (vargs : list val) (t : trace)
      (m' : mem) (vres : val) : Prop :=
    eval_funcall function_entry2 ge m fd vargs t m' vres /\
    forall s, Good fd s ->
      let '(pcs, rc) := s in
      Forall2 (vokm m) pcs vargs -> St m -> FR m m' /\ St m' /\ vokm m' rc vres.

  Section Fn.
    Variable ce : composite_env.
    Hypothesis Hce : CEok ce.
    Variable lv : list ident.
    Variable tc : ident -> fcls.
    Variable e : env.

    Lemma cf_x : forall le m a v, KEIL m lv e -> KTP m tc le -> St m ->
        eval_expr ge e le m a v -> vokm m (fx ce FP pins lv tc a) v.
    Proof.
      intros le m a v (He & He2) HP ((Hpn & _) & _) Hev.
      exact (fx_sound ge e le m ce FP pins lv tc cb co SZ nl Hce HSZ HP He He2 Hpn a v Hev).
    Qed.

    Lemma cf_lv : forall le m a b o bf, KEIL m lv e -> KTP m tc le -> St m ->
        eval_lvalue ge e le m a b o bf ->
        pcm m (flv ce FP pins lv tc a) b o /\ (bf = Full \/ fblk (flv ce FP pins lv tc a) = flv ce FP pins lv tc a).
    Proof.
      intros le m a b o bf (He & He2) HP ((Hpn & _) & _) Hev.
      exact (flv_sound ge e le m ce FP pins lv tc cb co SZ nl Hce HSZ HP He He2 Hpn a b o bf Hev).
    Qed.

    Lemma cf_set : forall id a le m v,
        fp_set ce FP pins lv tc id a = true -> KEIL m lv e -> KTP m tc le -> St m ->
        eval_expr ge e le m a v -> KTP m tc (PTree.set id v le).
    Proof.
      intros id a le m v Hok HK HP Hs Hev t v' Hg.
      destruct (peq t id) as [-> | Hne].
      - rewrite PTree.gss in Hg. injection Hg as <-.
        exact (fle_vok _ _ _ _ _ _ _ Hok (cf_x _ _ _ _ HK HP Hs Hev)).
      - rewrite PTree.gso in Hg by exact Hne. exact (HP _ _ Hg).
    Qed.

    Lemma cf_store : forall l r le m t le' m' out,
        fp_store ce FP pins lv tc l r = true -> KEIL m lv e -> KTP m tc le -> St m ->
        exec_stmt function_entry2 ge e le m (Sassign l r) t le' m' out ->
        FR m m' /\ St m'.
    Proof.
      intros l r le m t le' m' out Hok HK HP Hs Hx.
      unfold fp_store in Hok. apply andb_prop in Hok as [Hbv Hcl].
      inv Hx.
      match goal with HL : eval_lvalue _ _ _ _ l ?loc ?ofs ?bf,
                      HR : eval_expr _ _ _ _ r ?v2,
                      HC : sem_cast ?v2 _ _ _ = Some ?vv,
                      HA : assign_loc _ _ _ ?loc ?ofs ?bf ?vv _ |- _ =>
        rename HL into Hlv; rename HR into Hre; rename HC into Hc; rename HA into Ha
      end.
      destruct (assign_store _ _ _ _ _ _ _ _ Ha Hbv) as (ch & v' & Hst & Hfull).
      pose proof (cf_lv _ _ _ _ _ _ HK HP Hs Hlv) as (Hpc & Hbf).
      assert (Gen : fstorable (flv ce FP pins lv tc l) (chunk_size_of (typeof l)) = true -> FR m m' /\ St m').
      { intros Hfs. refine (store_A0 _ _ _ _ _ _ Hst _ Hs).
        refine (cls_store_A0 m _ _ _ _ ch _ Hpc Hbf Hfs _).
        intros E. exact (proj1 (Hfull E)). }
      destruct l as [ | | | | x ty | | | | | | | | | ];
        try (apply Gen; exact Hcl).
      destruct (mem_idf x lv || mem_idf x FP) eqn:Elf.
      - apply Gen. cbn [flv]. unfold fvar.
        destruct (mem_idf x lv); [ reflexivity | ]. cbn [orb] in Elf. rewrite Elf. reflexivity.
      - destruct (pin_of x pins) as [c|] eqn:Ep; [ | discriminate Hcl ].
        apply andb_prop in Hcl as [Hfle Hm32].
        apply orb_false_iff in Elf as [Elv Efp].
        destruct (access_mode (typeof (Evar x ty))) as [ch' | | | ] eqn:Ea; try discriminate Hm32.
        destruct ch'; try discriminate Hm32.
        inv Hlv.
        + exfalso. match goal with Hx : e ! x = Some _ |- _ =>
            destruct (proj1 HK _ _ _ Hx) as (E & _); congruence end.
        + destruct (Hfull eq_refl) as (_ & Ev' & Ea').
          assert (Ech : ch = Mint32) by (cbn [typeof] in Ea, Ea'; congruence). subst ch v'.
          match goal with Hsy : Genv.find_symbol _ x = Some ?bg |- _ =>
            refine (store_pin x c bg m _ m' Ep Hsy Hst _ Hs) end.
          intros bb oo E. subst.
          exact (fle_pc _ _ _ _ _ _ _ _ Hfle
                   (cf_x _ _ _ _ HK HP Hs Hre _ _ (sem_cast_vptr_inv _ _ _ _ _ _ Hc))).
    Qed.

    Lemma cf_ret : forall rc a le m v,
        fp_ret ce FP pins lv tc rc a = true -> KEIL m lv e -> KTP m tc le -> St m ->
        eval_expr ge e le m a v -> vokm m rc v.
    Proof.
      intros rc a le m v Hok HK HP Hs Hev.
      exact (fle_vok _ _ _ _ _ _ _ Hok (cf_x _ _ _ _ HK HP Hs Hev)).
    Qed.

    Lemma cf_callee : forall a le m vf fd targs tres cc sg,
        KEIL m lv e ->
        match CameraModeBody.direct_fid a with Some fid => negb (mem_idf fid lv) | None => true end = true ->
        f_call_sig tab it a = Some sg ->
        classify_fun (typeof a) = fun_case_f targs tres cc ->
        eval_expr ge e le m a vf -> Genv.find_funct ge vf = Some fd ->
        type_of_fundef fd = Tfunction targs tres cc ->
        exists se, Good fd se /\ ffits se sg = true.
    Proof.
      intros a le m vf fd targs tres cc sg HK Hnl Hsig Hcf Hev Hff Hty.
      unfold f_call_sig in Hsig.
      destruct (CameraModeBody.direct_fid a) as [fid|] eqn:Ed.
      - destruct (CameraModeBody.direct_fid_inv _ _ Ed) as (targs' & tres' & cc' & ->).
        apply negb_true_iff in Hnl.
        assert (Hnone : e ! fid = None).
        { destruct (e ! fid) as [[b ty]|] eqn:E; [ | reflexivity ].
          destruct (proj1 HK _ _ _ E) as (Hm & _). congruence. }
        destruct (MathGeomGated.evar_fun_val _ _ _ _ _ _ _ _ _ Hev Hnone) as (lf & Hsy & ->).
        exists sg. split; [ exact (HTab _ _ Hsig lf fd Hsy Hff) | ].
        destruct sg as [pcs rc]. unfold ffits. rewrite fle_l_refl, fle_refl. reflexivity.
      - rewrite Hcf in Hsig. exact (HIt _ _ Hsig vf fd Hff Hty).
    Qed.
  End Fn.

  Lemma cf_call_ih : forall ce lv tc e optid a al le m targs tres cc vf vargs fd t m' vres,
      CEok ce -> KEIL m lv e ->
      fp_call ce FP pins tab it lv tc optid a al = true -> KTP m tc le -> St m ->
      classify_fun (typeof a) = fun_case_f targs tres cc ->
      eval_expr ge e le m a vf -> eval_exprlist ge e le m al targs vargs ->
      Genv.find_funct ge vf = Some fd -> type_of_fundef fd = Tfunction targs tres cc ->
      Pfun m fd vargs t m' vres ->
      FR m m' /\ St m' /\ KTP m' tc (set_opttemp optid vres le).
  Proof.
    intros ce lv tc e optid a al le m targs tres cc vf vargs fd t m' vres
      Hce HK Hok HP Hs Hcf Hev Hel Hff Hty (_ & IH).
    unfold fp_call in Hok. apply andb_prop in Hok as [Hnl Hok].
    destruct (f_call_sig tab it a) as [[pcs rc]|] eqn:Hsig; [ | discriminate Hok ].
    apply andb_prop in Hok as [Hal Hopt].
    destruct (cf_callee lv e a le m vf fd targs tres cc _ HK Hnl Hsig Hcf Hev Hff Hty)
      as ([pcs' rc'] & Hgood & Hfit).
    unfold ffits in Hfit. apply andb_prop in Hfit as [Hpl Hrc].
    pose proof (IH _ Hgood) as IH'. cbv beta iota in IH'.
    pose proof (fargs_sound ge e le m ce FP pins lv tc cb co SZ nl Hce HSZ HP (proj1 HK) (proj2 HK)
                  (proj1 (proj1 Hs)) _ _ _ Hel _ Hal) as Hargs.
    assert (Hargs' : Forall2 (vokm m) pcs' vargs).
    { refine (fle_l_forall2 (vokm m) _ _ _ _ Hpl Hargs).
      intros c d v H Hv. exact (fle_vok _ _ _ _ _ _ _ H Hv). }
    destruct (IH' Hargs' Hs) as (HF & Hs' & Hr).
    split; [ exact HF | split; [ exact Hs' | ] ].
    intros t0 v0 Hg. destruct optid as [ti|]; cbn [set_opttemp] in Hg.
    - destruct (peq t0 ti) as [-> | Hne].
      + rewrite PTree.gss in Hg. injection Hg as <-.
        exact (fle_vok _ _ _ _ _ _ _ Hopt (fle_vok _ _ _ _ _ _ _ Hrc Hr)).
      + rewrite PTree.gso in Hg by exact Hne. exact (KTP_mono _ _ _ _ (FR_nb _ _ HF) HP _ _ Hg).
    - exact (KTP_mono _ _ _ _ (FR_nb _ _ HF) HP _ _ Hg).
  Qed.

  Lemma cf_body : forall f vargs m e le1 m1 t le2 m2 out vres m3 ce s,
      function_entry2 ge f vargs m e le1 m1 ->
      Pstmt e le1 m1 (fn_body f) t le2 m2 out ->
      outcome_result_value out (fn_return f) vres m2 ->
      Mem.free_list m2 (blocks_of_env ge e) = Some m3 ->
      CEok ce -> fchk ce FP pins tab it s f = true ->
      let '(pcs, rc) := s in
      Forall2 (vokm m) pcs vargs -> St m -> FR m m3 /\ St m3 /\ vokm m3 rc vres.
  Proof.
    intros f vargs m e le1 m1 t le2 m2 out vres m3 ce [pcs rc] Hentry (_ & IHb) Hor Hfree Hce Hchk
      Hva (HP & Hnl).
    unfold fchk in Hchk. set (tc := ftc_of ce FP pins tab it pcs f) in Hchk.
    apply andb_prop in Hchk as [Hchk Hlen]. apply andb_prop in Hchk as [Hsw Hpar].
    inv Hentry.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ => rename Ha into Hav end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ => rename Hb into Hbp end.
    match goal with Hn : list_norepet (var_names (fn_vars f)) |- _ => rename Hn into Hnr end.
    set (lv := map fst (fn_vars f)) in *.
    destruct (av_old ge _ _ _ _ _ Hav) as (N1 & P1).
    pose proof (av_blocks ge _ _ _ _ _ (Mem.nextblock m) Hav
                  ltac:(intros x b ty Hx; rewrite PTree.gempty in Hx; discriminate Hx)
                  (Ple_refl _)) as Hblk.
    assert (HK : KEIL m1 lv e).
    { split.
      - intros x b ty Hx. destruct (Hblk _ _ _ Hx) as (B1 & B2).
        split; [ | split; [ exact (Ple_trans _ _ _ Hnl B1) | exact B2 ] ].
        destruct (mem_idf x lv) eqn:E; [ reflexivity | exfalso ].
        rewrite (av_unbound ge _ _ _ _ _ Hav x (inl_id_notin _ _ E)) in Hx.
        rewrite PTree.gempty in Hx. discriminate Hx.
      - intros x Hx. destruct (LocalVarsSurface.alloc_variables_in_bound _ _ _ _ _ _ Hav x (inl_id_In _ _ Hx))
          as (b & ty & E). congruence. }
    assert (HP1 : KTP m1 tc le1).
    { intros t0 v Hg.
      destruct (ObjHelpersBodies.bind_get _ _ _ _ _ _ Hbp Hg) as [Hu | (i & Hi & Hvi)].
      - apply MtxfBody.create_undef_temps_get in Hu. subst v. apply fvok_undef.
      - destruct (PrintBodies.forall2_nth_l _ _ _ _ _ Hva Hvi) as (c & Hc).
        refine (fle_vok _ _ _ _ _ _ _ (fpar_ok_nth _ _ _ _ _ _ Hpar Hi Hc) _).
        exact (fvok_mono _ _ _ _ _ _ _ _ _ _ N1 (PrintBodies.forall2_nth _ _ _ _ _ _ Hva Hc Hvi)). }
    assert (Hs1 : St m1).
    { split; [ exact (pins_unch _ _ HP Hnl (av_unchanged_on _ _ _ _ _ _ _ Hav)) | exact (Ple_trans _ _ _ Hnl N1) ]. }
    destruct (IHb ce lv tc rc Hce HK Hsw HP1 Hs1) as ((PK2 & U2) & (HP2 & Hnl2) & _ & Hout).
    assert (Fr : forall id b ty, e ! id = Some (b, ty) -> ~ Mem.valid_block m b).
    { intros id b ty He. destruct (Hblk _ _ _ He) as (B1 & _). unfold Mem.valid_block.
      intros V. exact (Plt_strict _ (Plt_Ple_trans _ _ _ V B1)). }
    assert (Hfresh : forall b lo hi i, In (b, lo, hi) (blocks_of_env ge e) -> lo <= i < hi -> A0 b i).
    { intros b lo hi i Hin _. destruct (boe_inv ge _ _ _ _ Hin) as (id & ty & He).
      destruct (Hblk _ _ _ He) as (B1 & _). right; left. exact (Ple_trans _ _ _ Hnl B1). }
    assert (Nb3 : Mem.nextblock m3 = Mem.nextblock m2) by exact (fl_next _ _ _ Hfree).
    split; [ split | split; [ split | ] ].
    - (* PK *)
      destruct PK2 as (N2 & P2 & F2).
      split; [ | split ].
      + rewrite Nb3. exact (Ple_trans _ _ _ N1 N2).
      + intros b o k p Hv.
        assert (Hv1 : Mem.valid_block m1 b) by (unfold Mem.valid_block in *; eapply Plt_Ple_trans; eassumption).
        rewrite (P1 b o k p Hv), (P2 b o k p Hv1).
        split; [ | exact (fl_back _ _ _ _ _ _ _ Hfree) ].
        apply (fl_keep _ _ _ _ _ _ _ Hfree).
        intros lo hi Hin. destruct (boe_inv ge _ _ _ _ Hin) as (id & ty & He). exact (Fr id b ty He Hv).
      + intros b o k p Hv Hp.
        pose proof (fl_back _ _ _ _ _ _ _ Hfree Hp) as Hp2.
        destruct (plt b (Mem.nextblock m1)) as [V1 | V1]; [ | exact (F2 b o k p V1 Hp2) ].
        apply (P2 b o k p V1) in Hp2.
        destruct (av_new ge _ _ _ _ _ (Mem.nextblock m) Hav Hnr
                    ltac:(intros b0 o0 k0 p0 Hn Hp0; exfalso; exact (Hn (Mem.perm_valid_block _ _ _ _ _ Hp0)))
                    b o k p Hv Hp2) as (id & ty & He & R).
        exact (fl_kill _ _ _ _ _ _ _ _ _ Hfree (boe_in ge _ _ _ _ He) R Hp).
    - eapply Mem.unchanged_on_trans; [ exact (av_unchanged_on _ _ _ _ _ _ _ Hav) | ].
      eapply Mem.unchanged_on_trans; [ exact U2 | ].
      apply (free_list_unchanged_on _ _ _ _ Hfree).
      intros b lo hi i Hin Hi (N & _). exact (N (Hfresh _ _ _ _ Hin Hi)).
    - refine (pins_unch _ _ HP2 Hnl2 _).
      apply (free_list_unchanged_on _ _ _ _ Hfree).
      intros b lo hi i Hin Hi N. exact (N (Hfresh _ _ _ _ Hin Hi)).
    - rewrite Nb3. exact Hnl2.
    - intros bb oo Ev. subst vres. unfold vokm. rewrite Nb3.
      destruct out as [ | | | [[v' t']|] ]; cbn in Hor.
      + contradiction Hor.
      + contradiction Hor.
      + destruct (fn_return f); try contradiction Hor; discriminate Hor.
      + destruct Hor as (_ & Hc). exact (Hout _ _ (sem_cast_vptr_inv _ _ _ _ _ _ Hc)).
      + destruct (fn_return f); try contradiction Hor; discriminate Hor.
  Qed.

  (* THE MUTUAL INDUCTION *)
  Lemma cf_mutual :
    (forall e le m s t le' m' out,
        exec_stmt function_entry2 ge e le m s t le' m' out -> Pstmt e le m s t le' m' out) /\
    (forall m fd vargs t m' vres,
        eval_funcall function_entry2 ge m fd vargs t m' vres -> Pfun m fd vargs t m' vres).
  Proof.
    apply (exec_stmt_funcall_ind function_entry2 ge Pstmt Pfun); unfold Pstmt, Pfun.
    - (* Sskip *)
      intros e le m. split; [ constructor | ].
      intros ce lv tc rc _ _ _ HP Hs. exact (conj (FR_refl m) (conj Hs (conj HP I))).
    - (* Sassign *)
      intros e le m a1 a2 loc ofs bf v2 v m' Hl Hr Hc Ha.
      assert (Hx : exec_stmt function_entry2 ge e le m (Sassign a1 a2) E0 le m' Out_normal)
        by (eapply exec_Sassign; eassumption).
      split; [ exact Hx | ].
      intros ce lv tc rc Hce HK Hchk HP Hs. cbn [SpawnBodies.sw_chk] in Hchk.
      destruct (cf_store ce Hce lv tc e _ _ _ _ _ _ _ _ Hchk HK HP Hs Hx) as (HF & Hs').
      exact (conj HF (conj Hs' (conj (KTP_mono _ _ _ _ (FR_nb _ _ HF) HP) I))).
    - (* Sset *)
      intros e le m id a v Hev.
      split; [ exact (exec_Sset _ _ _ _ _ _ _ _ Hev) | ].
      intros ce lv tc rc Hce HK Hchk HP Hs. cbn [SpawnBodies.sw_chk] in Hchk.
      exact (conj (FR_refl m) (conj Hs (conj (cf_set ce Hce lv tc e _ _ _ _ _ Hchk HK HP Hs Hev) I))).
    - (* Scall *)
      intros e le m optid a al targs tres cc vf vargs fd t m' vres Hcf Hev Hel Hff Hty _ IHf.
      split; [ exact (exec_Scall _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ Hcf Hev Hel Hff Hty (proj1 IHf)) | ].
      intros ce lv tc rc Hce HK Hchk HP Hs. cbn [SpawnBodies.sw_chk] in Hchk.
      destruct (cf_call_ih ce lv tc e optid a al le m targs tres cc vf vargs fd t m' vres
                  Hce HK Hchk HP Hs Hcf Hev Hel Hff Hty IHf) as (HF & Hs' & HP').
      exact (conj HF (conj Hs' (conj HP' I))).
    - (* Sbuiltin *)
      intros e le m optid ef al targs vargs t m' vres Hel Hext.
      split; [ exact (exec_Sbuiltin _ _ _ _ _ _ _ _ _ _ _ _ _ Hel Hext) | ].
      intros ce lv tc rc _ _ Hchk. cbn [SpawnBodies.sw_chk] in Hchk. discriminate Hchk.
    - (* Sseq_1 *)
      intros e le m s1 s2 t1 le1 m1 t2 le2 m2 out D1 (_ & IH1) D2 (_ & IH2).
      split; [ exact (exec_Sseq_1 _ _ _ _ _ _ _ _ _ _ _ _ _ _ D1 D2) | ].
      intros ce lv tc rc Hce HK Hchk HP Hs. cbn [SpawnBodies.sw_chk] in Hchk.
      apply andb_prop in Hchk as [H1 H2].
      destruct (IH1 ce lv tc rc Hce HK H1 HP Hs) as (HF1 & Hs1 & HP1 & _).
      destruct (IH2 ce lv tc rc Hce (KEIL_mono _ _ _ _ (FR_nb _ _ HF1) HK) H2 HP1 Hs1) as (HF2 & Hs2 & HP2 & Ho2).
      exact (conj (FR_trans _ _ _ HF1 HF2) (conj Hs2 (conj HP2 Ho2))).
    - (* Sseq_2 *)
      intros e le m s1 s2 t1 le1 m1 out D1 (_ & IH1) Hne.
      split; [ exact (exec_Sseq_2 _ _ _ _ _ _ _ _ _ _ _ D1 Hne) | ].
      intros ce lv tc rc Hce HK Hchk HP Hs. cbn [SpawnBodies.sw_chk] in Hchk.
      apply andb_prop in Hchk as [H1 _].
      exact (IH1 ce lv tc rc Hce HK H1 HP Hs).
    - (* Sifthenelse *)
      intros e le m a s1 s2 v1 b t le' m' out Hev Hbv D (_ & IH).
      split; [ exact (exec_Sifthenelse _ _ _ _ _ _ _ _ _ _ _ _ _ _ Hev Hbv D) | ].
      intros ce lv tc rc Hce HK Hchk HP Hs. cbn [SpawnBodies.sw_chk] in Hchk.
      apply andb_prop in Hchk as [H1 H2].
      apply (IH ce lv tc rc Hce HK); [ destruct b; assumption | exact HP | exact Hs ].
    - (* Sreturn None *)
      intros e le m. split; [ constructor | ].
      intros ce lv tc rc _ _ _ HP Hs. exact (conj (FR_refl m) (conj Hs (conj HP I))).
    - (* Sreturn Some *)
      intros e le m a v Hev. split; [ exact (exec_Sreturn_some _ _ _ _ _ _ _ Hev) | ].
      intros ce lv tc rc Hce HK Hchk HP Hs. cbn [SpawnBodies.sw_chk] in Hchk.
      exact (conj (FR_refl m) (conj Hs (conj HP (cf_ret ce Hce lv tc e _ _ _ _ _ Hchk HK HP Hs Hev)))).
    - (* Sbreak *)
      intros e le m. split; [ constructor | ].
      intros ce lv tc rc _ _ _ HP Hs. exact (conj (FR_refl m) (conj Hs (conj HP I))).
    - (* Scontinue *)
      intros e le m. split; [ constructor | ].
      intros ce lv tc rc _ _ _ HP Hs. exact (conj (FR_refl m) (conj Hs (conj HP I))).
    - (* Sloop_stop1 *)
      intros e le m s1 s2 t le' m' out' out D (_ & IH) Hbr.
      split; [ exact (exec_Sloop_stop1 _ _ _ _ _ _ _ _ _ _ _ _ D Hbr) | ].
      intros ce lv tc rc Hce HK Hchk HP Hs. cbn [SpawnBodies.sw_chk] in Hchk.
      apply andb_prop in Hchk as [H1 _].
      destruct (IH ce lv tc rc Hce HK H1 HP Hs) as (HF1 & Hs1 & HP1 & Ho1).
      split; [ exact HF1 | split; [ exact Hs1 | split; [ exact HP1 | ] ] ].
      inv Hbr; [ exact I | exact Ho1 ].
    - (* Sloop_stop2 *)
      intros e le m s1 s2 t1 le1 m1 out1 t2 le2 m2 out2 out D1 (_ & IH1) Hnc D2 (_ & IH2) Hbr.
      split; [ eapply exec_Sloop_stop2; [ exact D1 | exact Hnc | exact D2 | exact Hbr ] | ].
      intros ce lv tc rc Hce HK Hchk HP Hs. cbn [SpawnBodies.sw_chk] in Hchk.
      apply andb_prop in Hchk as [H1 H2].
      destruct (IH1 ce lv tc rc Hce HK H1 HP Hs) as (HF1 & Hs1 & HP1 & _).
      destruct (IH2 ce lv tc rc Hce (KEIL_mono _ _ _ _ (FR_nb _ _ HF1) HK) H2 HP1 Hs1) as (HF2 & Hs2 & HP2 & Ho2).
      split; [ exact (FR_trans _ _ _ HF1 HF2) | split; [ exact Hs2 | split; [ exact HP2 | ] ] ].
      inv Hbr; [ exact I | exact Ho2 ].
    - (* Sloop_loop *)
      intros e le m s1 s2 t1 le1 m1 out1 t2 le2 m2 t3 le3 m3 out D1 (_ & IH1) Hnc D2 (_ & IH2) D3 (_ & IH3).
      split; [ eapply exec_Sloop_loop; [ exact D1 | exact Hnc | exact D2 | exact D3 ] | ].
      intros ce lv tc rc Hce HK Hchk HP Hs.
      pose proof Hchk as Hchk'. cbn [SpawnBodies.sw_chk] in Hchk.
      apply andb_prop in Hchk as [H1 H2].
      destruct (IH1 ce lv tc rc Hce HK H1 HP Hs) as (HF1 & Hs1 & HP1 & _).
      pose proof (KEIL_mono _ _ _ _ (FR_nb _ _ HF1) HK) as HK1.
      destruct (IH2 ce lv tc rc Hce HK1 H2 HP1 Hs1) as (HF2 & Hs2 & HP2 & _).
      destruct (IH3 ce lv tc rc Hce (KEIL_mono _ _ _ _ (FR_nb _ _ HF2) HK1) Hchk' HP2 Hs2)
        as (HF3 & Hs3 & HP3 & Ho3).
      exact (conj (FR_trans _ _ _ HF1 (FR_trans _ _ _ HF2 HF3)) (conj Hs3 (conj HP3 Ho3))).
    - (* Sswitch *)
      intros e le m a t v n sl le1 m1 out Hev Hsw D (_ & IH).
      split; [ eapply exec_Sswitch; [ exact Hev | exact Hsw | exact D ] | ].
      intros ce lv tc rc Hce HK Hchk HP Hs. cbn [SpawnBodies.sw_chk] in Hchk.
      destruct (IH ce lv tc rc Hce HK (SpawnBodies.sw_chk_select _ _ _ _ _ _ Hchk) HP Hs)
        as (HF & Hs1 & HP1 & Ho1).
      split; [ exact HF | split; [ exact Hs1 | split; [ exact HP1 | ] ] ].
      destruct out as [ | | | [[vr tyr]|] ]; cbn; auto.
    - (* funcall internal *)
      intros m f vargs t e le1 le2 m1 m2 out vres m3 Hentry _ IHb Hor Hfree.
      assert (D : eval_funcall function_entry2 ge m (Internal f) vargs t m3 vres)
        by (eapply eval_funcall_internal; [ exact Hentry | exact (proj1 IHb) | exact Hor | exact Hfree ]).
      split; [ exact D | ].
      intros [pcs rc] Hg.
      destruct Hg as [(f' & ce & Ef & Hce & Hchk) | Hlf].
      + injection Ef as <-.
        exact (cf_body f vargs m e le1 m1 t le2 m2 out vres m3 ce (pcs, rc) Hentry IHb Hor Hfree Hce Hchk).
      + intros Hva Hs. exact (HLeaf _ _ Hlf _ _ _ _ _ D Hva Hs).
    - (* funcall external *)
      intros m ef targs tres cc vargs t vres m' Hext.
      assert (D : eval_funcall function_entry2 ge m (External ef targs tres cc) vargs t m' vres)
        by (eapply eval_funcall_external; exact Hext).
      split; [ exact D | ].
      intros [pcs rc] Hg.
      destruct Hg as [(f' & ce & Ef & _) | Hlf]; [ discriminate Ef | ].
      intros Hva Hs. exact (HLeaf _ _ Hlf _ _ _ _ _ D Hva Hs).
  Qed.

  (* THE RESULT: every function the table vouches for meets its spec *)
  Theorem cf_good_spec : forall fd s, Good fd s -> fspec fd s.
  Proof.
    intros fd [pcs rc] Hg m vargs t m' vres Hev Hva Hs.
    destruct (proj2 cf_mutual _ _ _ _ _ _ Hev) as (_ & IH).
    exact (IH (pcs, rc) Hg Hva Hs).
  Qed.
End WALK.
