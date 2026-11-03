(* ===================================================================== *)
(* ClearRun (GOAL 2): the real clear_dynamic_surfaces, inverted          *)
(* (2026-11-03).                                                          *)
(*                                                                       *)
(* surface_load.c:79-89 / 643-650 (generated/surface_load.v,              *)
(* f_clear_spatial_partition / f_clear_dynamic_surfaces): unless          *)
(* TIME_STOP_ACTIVE (gTimeStopState & 0x40) the clear copies              *)
(* gNumStaticSurfaces into gSurfacesAllocated and gNumStaticSurfaceNodes  *)
(* into gSurfaceNodesAllocated, then runs clear_spatial_partition on      *)
(* &gDynamicSurfacePartition[0][0]: 256 cells, each three SurfaceNode     *)
(* heads (8 bytes, next at 0), whose next words are set to NULL.          *)
(* cds_run states exactly that memory trace (cl_done: the 768 head words  *)
(* 8 j, j < 768, now hold NULL; every other byte, every permission and    *)
(* nextblock as before); ClearKeep reads the invariants off it.           *)
(* ===================================================================== *)
From Coq Require Import ZArith Lia List.
From compcert Require Import Coqlib Integers Floats Values AST Ctypes Cop Clight
  ClightBigstep Clightdefs Memory Maps Globalenvs Events Errors.
From SM64.Generated Require surface_load.
From SM64.Proofs.WMotRRequiresA Require Import RenderAnim.
Import ListNotations.
Local Open Scope Z_scope.

Module SL := surface_load.

Definition SNT : type := Tstruct SL._SurfaceNode noattr.
Definition ART : type := tarray SNT 3.

(* the clear's footprint after w head words (three per cell) *)
Definition cl_keep (bd : block) (w : Z) (b : block) (z : Z) : Prop :=
  b <> bd \/ ~ (0 <= z < 8 * w /\ z mod 8 < 4).

(* m is m0 after a chain of head stores (NULL into a word 8 w, w < 768):
   any property every such store keeps holds of m *)
Definition cl_reach (bd : block) (m0 m : mem) : Prop :=
  forall P : mem -> Prop,
    (forall m1 w m2, 0 <= w < 768 -> P m1 -> Mem.store Mint32 m1 bd (8 * w) (Vint Int.zero) = Some m2 -> P m2) ->
    P m0 -> P m.

Definition cl_done (bd : block) (m0 m : mem) (w : Z) : Prop :=
  Mem.nextblock m = Mem.nextblock m0
  /\ (forall b o k p, Mem.perm m b o k p <-> Mem.perm m0 b o k p)
  /\ Mem.unchanged_on (cl_keep bd w) m0 m
  /\ (forall j, 0 <= j < w -> Mem.load Mint32 m bd (8 * j) = Some (Vint Int.zero))
  /\ cl_reach bd m0 m.

Lemma cl_done_0 : forall bd m, cl_done bd m m 0.
Proof.
  intros bd m. split; [ reflexivity | split; [ tauto | split; [ | split ] ] ].
  - apply Mem.unchanged_on_refl.
  - intros j Hj. lia.
  - intros P _ H. exact H.
Qed.

Lemma cl_keep_mono : forall bd n n' b z, n <= n' -> cl_keep bd n' b z -> cl_keep bd n b z.
Proof. intros bd n n' b z H [H1 | H1]; [ left; exact H1 | right; intros (H2 & H3); apply H1; lia ]. Qed.

(* one head store: w words done, then w + 1 *)
Lemma cl_step : forall bd m0 m m2 w, 0 <= w < 768 -> cl_done bd m0 m w ->
  Mem.store Mint32 m bd (8 * w) (Vint Int.zero) = Some m2 -> cl_done bd m0 m2 (w + 1).
Proof.
  intros bd m0 m m2 w Hw (N & P & U & L & R) S.
  split; [ rewrite (Mem.nextblock_store _ _ _ _ _ _ S); exact N | split; [ | split; [ | split ] ] ].
  - intros b o k p. rewrite <- (P b o k p).
    split; [ eapply Mem.perm_store_2; eauto | eapply Mem.perm_store_1; eauto ].
  - eapply Mem.unchanged_on_trans.
    + eapply Mem.unchanged_on_implies; [ exact U | ].
      intros b z Hk _. eapply cl_keep_mono; [ | exact Hk ]. lia.
    + eapply Mem.store_unchanged_on; [ exact S | ].
      intros i Hi [Hb | Hb]; [ exact (Hb eq_refl) | apply Hb ]. cbn [size_chunk] in Hi.
      assert (E : i mod 8 = i - 8 * w) by (symmetry; apply (Z.mod_unique i 8 w); lia).
      rewrite E. lia.
  - intros j Hj. destruct (Z.eq_dec j w) as [-> | Ne].
    + rewrite (Mem.load_store_same _ _ _ _ _ _ S). reflexivity.
    + rewrite (Mem.load_store_other _ _ _ _ _ _ S) by (right; left; cbn [size_chunk]; lia).
      apply L. lia.
  - intros Q HQ H0. exact (HQ m w m2 Hw (R Q HQ H0) S).
Qed.

Lemma ptr_rng : forall z, 0 <= z <= 1000000 -> Ptrofs.unsigned (Ptrofs.repr z) = z.
Proof. intros z H. apply Ptrofs.unsigned_repr. change Ptrofs.max_unsigned with 4294967295. lia. Qed.

Lemma ofs_ints : forall j, 0 <= j < 1000 -> Ptrofs.of_ints (Int.repr j) = Ptrofs.repr j.
Proof.
  intros j H. unfold Ptrofs.of_ints. rewrite Int.signed_repr; [ reflexivity | ].
  change Int.min_signed with (-2147483648). change Int.max_signed with 2147483647. lia.
Qed.

(* the head word's offset *)
Lemma off_eq : forall c j, 0 <= c <= 256 -> 0 <= j < 3 ->
  Ptrofs.unsigned (Ptrofs.add (Ptrofs.add (Ptrofs.repr (24 * c))
     (Ptrofs.mul (Ptrofs.repr 8) (Ptrofs.of_ints (Int.repr j)))) (Ptrofs.repr 0)) = 8 * (3 * c + j).
Proof.
  intros c j Hc Hj. rewrite ofs_ints by lia. unfold Ptrofs.add, Ptrofs.mul.
  rewrite (ptr_rng 8), (ptr_rng j), (ptr_rng (8 * j)), (ptr_rng (24 * c)), (ptr_rng (24 * c + 8 * j)), (ptr_rng 0) by lia.
  rewrite Z.add_0_r, ptr_rng by lia. lia.
Qed.

(* the cell pointer's step *)
Lemma cell_step : forall c, 0 <= c < 256 ->
  Ptrofs.add (Ptrofs.repr (24 * c)) (Ptrofs.mul (Ptrofs.repr 24) (Ptrofs.of_ints (Int.repr 1)))
  = Ptrofs.repr (24 * (c + 1)).
Proof.
  intros c Hc. rewrite ofs_ints by lia. unfold Ptrofs.add, Ptrofs.mul.
  rewrite (ptr_rng 24), (ptr_rng 1), (ptr_rng (24 * 1)), (ptr_rng (24 * c)) by lia.
  f_equal. lia.
Qed.

Section CR.
Variable ge : genv.
Hypothesis Hcenv : forall id co, (prog_comp_env SL.prog) ! id = Some co -> (genv_cenv ge) ! id = Some co.

Lemma fo_next : forall co, (genv_cenv ge) ! SL._SurfaceNode = Some co ->
  field_offset ge SL._next (co_members co) = OK (0, Full).
Proof. apply (fo_ok_lift (prog_comp_env SL.prog)); [ vm_compute; reflexivity | exact Hcenv ]. Qed.

Lemma sz_sn : sizeof ge SNT = 8.
Proof.
  unfold SNT. cbn [sizeof].
  assert (B : match (prog_comp_env SL.prog) ! SL._SurfaceNode with
              | Some co => Z.eqb (co_sizeof co) 8 | None => false end = true) by (vm_compute; reflexivity).
  destruct ((prog_comp_env SL.prog) ! SL._SurfaceNode) as [co|] eqn:E; [ | discriminate B ].
  rewrite (Hcenv _ _ E). apply Z.eqb_eq. exact B.
Qed.

Lemma sz_art : sizeof ge ART = 24.
Proof. unfold ART. change (sizeof ge (tarray SNT 3)) with (sizeof ge SNT * Z.max 0 3). rewrite sz_sn. reflexivity. Qed.

(* the head store's lvalue: ( *cells)[j].next *)
Lemma lv_cell : forall e le m j b o b' o' bf,
  le ! SL._cells = Some (Vptr b o) ->
  eval_lvalue ge e le m
    (Efield (Ederef (Ebinop Oadd (Ederef (Etempvar SL._cells (tptr ART)) ART)
                       (Econst_int (Int.repr j) tint) (tptr SNT)) SNT) SL._next (tptr SNT)) b' o' bf ->
  b' = b /\ o' = Ptrofs.add (Ptrofs.add o (Ptrofs.mul (Ptrofs.repr 8) (Ptrofs.of_ints (Int.repr j)))) (Ptrofs.repr 0)
  /\ bf = Full.
Proof.
  intros e le m j b o b' o' bf Hc H.
  inv H. all: try (match goal with Ht : typeof _ = Tunion _ _ |- _ => cbn in Ht; discriminate Ht end).
  match goal with Ht : typeof _ = Tstruct _ _ |- _ => cbn in Ht; injection Ht as <- <- end.
  match goal with Hcc : (genv_cenv ge) ! _ = Some ?co, Hf : field_offset _ _ _ = OK _ |- _ =>
    rewrite (fo_next _ Hcc) in Hf; injection Hf; intros; subst end.
  match goal with He : eval_expr _ _ _ _ (Ederef _ _) _ |- _ => inv He end.
  match goal with Hl : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hl end.
  match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => inv Hd end; cbn in *; try discriminate.
  match goal with Hb : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ =>
    apply ev_binop in Hb; destruct Hb as (v1 & v2 & E1 & E2 & E3) end.
  apply ev_const in E2. subst v2.
  (* the array-valued *cells is the pointer itself *)
  inv E1.
  all: try (match goal with Hx : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hx end).
  all: try (match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => inv Hd end; cbn in *; try discriminate).
  match goal with Ht : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ => inv Ht end.
  match goal with Hl : le ! SL._cells = Some (Vptr _ _) |- _ => rewrite Hc in Hl; injection Hl; intros; subst end.
  pose proof sz_sn as Hs. unfold SNT in Hs. cbn [sizeof] in Hs.
  match goal with Hcc : (genv_cenv ge) ! SL._SurfaceNode = Some _ |- _ => rewrite Hcc in Hs, E3 end.
  rewrite Hs in E3. injection E3; intros; subst.
  split; [ reflexivity | split; reflexivity ].
  match goal with Hx : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hx end.
Qed.

Section RUN.
Variable e : env.
Notation xs := (exec_stmt function_entry2 ge e).

Definition HDR : statement :=
  Ssequence
    (Ssequence (Sset SL._t'1 (Etempvar SL._i tint))
       (Sset SL._i (Ebinop Osub (Etempvar SL._t'1 tint) (Econst_int (Int.repr 1) tint) tint)))
    (Sifthenelse (Etempvar SL._t'1 tint) Sskip Sbreak).

Definition ASG (j : Z) : statement :=
  Sassign (Efield (Ederef (Ebinop Oadd (Ederef (Etempvar SL._cells (tptr ART)) ART)
                             (Econst_int (Int.repr j) tint) (tptr SNT)) SNT) SL._next (tptr SNT))
          (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)).

Definition BODY : statement :=
  Ssequence (ASG 0) (Ssequence (ASG 1) (Ssequence (ASG 2)
    (Sset SL._cells (Ebinop Oadd (Etempvar SL._cells (tptr ART)) (Econst_int (Int.repr 1) tint) (tptr ART))))).

Definition LOOP : statement := Sloop (Ssequence HDR BODY) Sskip.

(* the generated function is the init then LOOP *)
Lemma csp_shape : exists a, fn_body SL.f_clear_spatial_partition = Ssequence (Sset SL._i a) LOOP.
Proof. eexists. reflexivity. Qed.

Lemma hdr_run : forall le m t le' m' out ii, le ! SL._i = Some (Vint ii) ->
  xs le m HDR t le' m' out ->
  m' = m /\ le' ! SL._i = Some (Vint (Int.sub ii (Int.repr 1)))
  /\ (forall x, x <> SL._i -> x <> SL._t'1 -> le' ! x = le ! x)
  /\ ((out = Out_normal /\ Int.eq ii Int.zero = false) \/ (out = Out_break /\ Int.eq ii Int.zero = true)).
Proof.
  intros le m t le' m' out ii Hi H. unfold HDR in H.
  apply seq_inv in H as [(t1 & le1 & m1 & t2 & H1 & H2) | (H1 & Hn)].
  - apply seq_inv in H1 as [(ta & lea & ma & tb & A & B) | (A & Hn)];
      [ | apply set_inv in A as (? & _ & _ & _ & ?); congruence ].
    apply set_inv in A as (va & Ea & -> & -> & _). apply ev_temp in Ea. rewrite Hi in Ea. injection Ea as <-.
    apply set_inv in B as (vb & Eb & -> & -> & _).
    apply ev_binop in Eb as (v1 & v2 & E1 & E2 & E3). apply ev_temp in E1. rewrite PTree.gss in E1. injection E1 as <-.
    apply ev_const in E2. subst v2.
    assert (Es : sem_binary_operation ge Osub (Vint ii) tint (Vint (Int.repr 1)) tint m
               = Some (Vint (Int.sub ii (Int.repr 1)))) by reflexivity.
    cbn [typeof] in E3. rewrite Es in E3. injection E3 as <-.
    apply if_inv in H2 as (vc & bc & Ec & Bc & H2). apply ev_temp in Ec.
    rewrite PTree.gso, PTree.gss in Ec by neq. injection Ec as <-.
    cbn in Bc. injection Bc as <-.
    destruct (Int.eq ii Int.zero) eqn:Ez; cbn [negb] in H2.
    + inv H2. split; [ reflexivity | split; [ apply PTree.gss | split ] ].
      * intros x N1 N2. rewrite !PTree.gso by assumption. reflexivity.
      * right. split; reflexivity.
    + apply skip_inv in H2 as (-> & -> & ->).
      split; [ reflexivity | split; [ apply PTree.gss | split ] ].
      * intros x N1 N2. rewrite !PTree.gso by assumption. reflexivity.
      * left. split; reflexivity.
  - exfalso. apply Hn. apply seq_inv in H1 as [(? & ? & ? & ? & A & B) | (A & _)].
    + apply set_inv in B. destruct B as (? & _ & _ & _ & ?). exfalso; congruence.
    + apply set_inv in A. destruct A as (? & _ & _ & _ & ?). exfalso; congruence.
Qed.

Lemma asg_run : forall le m t le' m' out b o j, le ! SL._cells = Some (Vptr b o) ->
  xs le m (ASG j) t le' m' out ->
  le' = le /\ out = Out_normal
  /\ Mem.store Mint32 m b (Ptrofs.unsigned (Ptrofs.add (Ptrofs.add o (Ptrofs.mul (Ptrofs.repr 8)
         (Ptrofs.of_ints (Int.repr j)))) (Ptrofs.repr 0))) (Vint Int.zero) = Some m'.
Proof.
  intros le m t le' m' out b o j Hc H. unfold ASG in H.
  apply assign_inv in H as (b' & o' & bf & v2 & v & Hl & Hv & Hcs & Ha & -> & ->).
  destruct (lv_cell _ _ _ _ _ _ _ _ _ Hc Hl) as (-> & -> & ->).
  apply ev_cast in Hv as (v1 & E1 & C1). apply ev_const in E1. subst v1.
  cbn in C1. injection C1 as <-. cbn in Hcs. injection Hcs as <-.
  split; [ reflexivity | split; [ reflexivity | ] ].
  exact (store_by_value ge (tptr SNT) m b _ Full _ m' Mint32 eq_refl eq_refl Ha).
Qed.

Lemma asg_normal : forall le m t le' m' out b o j, le ! SL._cells = Some (Vptr b o) ->
  xs le m (ASG j) t le' m' out -> out = Out_normal.
Proof. intros. eapply asg_run in H0; [ | eassumption ]. tauto. Qed.

Lemma body_run : forall bd le m t le' m' out c, 0 <= c < 256 ->
  le ! SL._cells = Some (Vptr bd (Ptrofs.repr (24 * c))) ->
  xs le m BODY t le' m' out ->
  out = Out_normal /\ le' = PTree.set SL._cells (Vptr bd (Ptrofs.repr (24 * (c + 1)))) le
  /\ exists m1 m2, Mem.store Mint32 m bd (8 * (3 * c)) (Vint Int.zero) = Some m1
       /\ Mem.store Mint32 m1 bd (8 * (3 * c + 1)) (Vint Int.zero) = Some m2
       /\ Mem.store Mint32 m2 bd (8 * (3 * c + 2)) (Vint Int.zero) = Some m'.
Proof.
  intros bd le m t le' m' out c Hc Hl H. unfold BODY in H.
  apply seq_inv in H as [(t1 & le1 & m1 & t2 & A0 & H) | (A0 & Hn)];
    [ | exfalso; exact (Hn (asg_normal _ _ _ _ _ _ _ _ _ Hl A0)) ].
  apply (asg_run _ _ _ _ _ _ _ _ _ Hl) in A0 as (-> & _ & S0).
  apply seq_inv in H as [(t3 & le2 & m2 & t4 & A1 & H) | (A1 & Hn)];
    [ | exfalso; exact (Hn (asg_normal _ _ _ _ _ _ _ _ _ Hl A1)) ].
  apply (asg_run _ _ _ _ _ _ _ _ _ Hl) in A1 as (-> & _ & S1).
  apply seq_inv in H as [(t5 & le3 & m3 & t6 & A2 & H) | (A2 & Hn)];
    [ | exfalso; exact (Hn (asg_normal _ _ _ _ _ _ _ _ _ Hl A2)) ].
  apply (asg_run _ _ _ _ _ _ _ _ _ Hl) in A2 as (-> & _ & S2).
  apply set_inv in H as (v & Ev & -> & -> & ->).
  apply ev_binop in Ev as (v1 & v2 & E1 & E2 & E3). apply ev_temp in E1. rewrite Hl in E1. injection E1 as <-.
  apply ev_const in E2. subst v2.
  assert (Ea : forall mm, sem_binary_operation ge Oadd (Vptr bd (Ptrofs.repr (24 * c))) (tptr ART) (Vint (Int.repr 1)) tint mm
             = Some (Vptr bd (Ptrofs.add (Ptrofs.repr (24 * c))
                     (Ptrofs.mul (Ptrofs.repr (sizeof ge ART)) (Ptrofs.of_ints (Int.repr 1)))))) by (intros; reflexivity).
  cbn [typeof] in E3. rewrite Ea, sz_art, cell_step in E3 by lia. injection E3 as <-.
  rewrite off_eq in S0, S1, S2 by lia. rewrite Z.add_0_r in S0.
  split; [ reflexivity | split; [ reflexivity | exists m1, m2; auto ] ].
Qed.

Lemma eq_nz : forall k, (S k <= 256)%nat -> Int.eq (Int.repr (Z.of_nat (S k))) Int.zero = false.
Proof.
  intros k Hk. unfold Int.eq. rewrite Int.unsigned_zero.
  rewrite Int.unsigned_repr by (change Int.max_unsigned with 4294967295; lia).
  destruct (zeq _ 0); [ lia | reflexivity ].
Qed.

Lemma sub_one : forall k, (S k <= 256)%nat ->
  Int.sub (Int.repr (Z.of_nat (S k))) (Int.repr 1) = Int.repr (Z.of_nat k).
Proof.
  intros k Hk. unfold Int.sub.
  rewrite !Int.unsigned_repr by (change Int.max_unsigned with 4294967295; lia).
  f_equal. lia.
Qed.

(* the loop, k cells to go *)
Lemma loop_run : forall bd m0 k le m t le' m' out, (k <= 256)%nat ->
  le ! SL._i = Some (Vint (Int.repr (Z.of_nat k))) ->
  le ! SL._cells = Some (Vptr bd (Ptrofs.repr (24 * (256 - Z.of_nat k)))) ->
  cl_done bd m0 m (3 * (256 - Z.of_nat k)) ->
  xs le m LOOP t le' m' out -> cl_done bd m0 m' 768 /\ out = Out_normal.
Proof.
  intros bd m0 k. induction k as [| k IH]; intros le m t le' m' out Hk Hi Hc Hd H; unfold LOOP in H.
  - inv H.
    + match goal with Hx : xs _ _ (Ssequence HDR BODY) _ _ _ ?o, Hb : out_break_or_return ?o _ |- _ =>
        apply seq_inv in Hx as [(t1 & le1 & m1 & t2 & H1 & _) | (H1 & Hn)] end.
      * apply (hdr_run _ _ _ _ _ _ _ Hi) in H1 as (_ & _ & _ & [(_ & E) | (E & _)]);
          vm_compute in E; discriminate E.
      * apply (hdr_run _ _ _ _ _ _ _ Hi) in H1 as (-> & _ & _ & [(E & _) | (-> & _)]);
          [ exact (False_ind _ (Hn E)) | ].
        match goal with Hb : out_break_or_return Out_break _ |- _ => inv Hb end.
        split; [ exact Hd | reflexivity ].
    + match goal with Hs : xs _ _ Sskip _ _ _ ?o2, Hb : out_break_or_return ?o2 _ |- _ =>
        apply skip_inv in Hs as (_ & _ & ->); inv Hb end.
    + match goal with Hx : xs _ _ (Ssequence HDR BODY) _ _ _ ?o, Ho : out_normal_or_continue ?o |- _ =>
        apply seq_inv in Hx as [(tq & leq & mq & tr & H1 & _) | (H1 & Hn)];
        [ apply (hdr_run _ _ _ _ _ _ _ Hi) in H1 as (_ & _ & _ & [(_ & E) | (E & _)]);
            vm_compute in E; discriminate E
        | apply (hdr_run _ _ _ _ _ _ _ Hi) in H1 as (_ & _ & _ & [(E & _) | (E & _)]);
            [ exact (False_ind _ (Hn E)) | subst; inv Ho ] ] end.
  - inv H.
    + match goal with Hx : xs _ _ (Ssequence HDR BODY) _ _ _ ?o, Hb : out_break_or_return ?o _ |- _ =>
        apply seq_inv in Hx as [(ta & leh & mh & tb & H1 & H2) | (H1 & Hn)] end.
      * apply (hdr_run _ _ _ _ _ _ _ Hi) in H1 as (-> & _ & Ho' & _).
        apply (body_run bd _ _ _ _ _ _ (256 - Z.of_nat (S k))) in H2;
          [ | lia | rewrite Ho' by neq; exact Hc ].
        destruct H2 as (-> & _).
        match goal with Hb : out_break_or_return Out_normal _ |- _ => inv Hb end.
      * apply (hdr_run _ _ _ _ _ _ _ Hi) in H1 as (_ & _ & _ & [(E & _) | (_ & E)]);
          [ exact (False_ind _ (Hn E)) | rewrite eq_nz in E by lia; discriminate E ].
    + match goal with Hs : xs _ _ Sskip _ _ _ ?o2, Hb : out_break_or_return ?o2 _ |- _ =>
        apply skip_inv in Hs as (_ & _ & ->); inv Hb end.
    + match goal with Hx : xs _ _ (Ssequence HDR BODY) _ _ _ ?o, Hs : xs _ _ Sskip _ _ _ Out_normal,
                      Hl : xs _ _ (Sloop _ _) _ _ _ _ |- _ =>
        apply seq_inv in Hx as [(ta & leh & mh & tb & H1 & H2) | (H1 & Hn)];
        [ apply skip_inv in Hs as (-> & -> & _); revert Hl | ] end.
      * apply (hdr_run _ _ _ _ _ _ _ Hi) in H1 as (-> & Hi' & Ho' & _).
        apply (body_run bd _ _ _ _ _ _ (256 - Z.of_nat (S k))) in H2;
          [ | lia | rewrite Ho' by neq; exact Hc ].
        destruct H2 as (_ & -> & ma & mb & S0 & S1 & S2). intros Hl.
        remember (256 - Z.of_nat (S k)) as c eqn:Ec.
        refine (IH _ _ _ _ _ _ _ _ _ _ Hl); [ lia | | | ].
        -- rewrite PTree.gso by neq. rewrite Hi', sub_one by lia. reflexivity.
        -- rewrite PTree.gss. replace (24 * (c + 1)) with (24 * (256 - Z.of_nat k)) by lia. reflexivity.
        -- pose proof (cl_step bd m0 _ _ (3 * c) ltac:(lia) Hd S0) as D1.
           pose proof (cl_step bd m0 _ _ (3 * c + 1) ltac:(lia) D1 S1) as D2.
           replace (3 * c + 1 + 1) with (3 * c + 2) in D2 by lia.
           pose proof (cl_step bd m0 _ _ (3 * c + 2) ltac:(lia) D2 S2) as D3.
           replace (3 * c + 2 + 1) with (3 * (256 - Z.of_nat k)) in D3 by lia. exact D3.
      * match goal with Ho : out_normal_or_continue _ |- _ =>
          apply (hdr_run _ _ _ _ _ _ _ Hi) in H1 as (_ & _ & _ & [(E & _) | (E & _)]);
          [ exact (False_ind _ (Hn E)) | subst; inv Ho ] end.
Qed.
End RUN.

Definition INIT : expr :=
  match fn_body SL.f_clear_spatial_partition with Ssequence (Sset _ a) _ => a | _ => Etempvar xH tint end.

Lemma csp_body : fn_body SL.f_clear_spatial_partition = Ssequence (Sset SL._i INIT) LOOP.
Proof. reflexivity. Qed.

(* the cell count, as the C computes it: (2 * LEVEL_BOUNDARY_MAX / CELL_SIZE)^2 = 256 *)
Lemma init_256 : forall e le m v, eval_expr ge e le m INIT v -> v = Vint (Int.repr 256).
Proof.
  intros e le m v H. unfold INIT in H. cbn [fn_body SL.f_clear_spatial_partition] in H.
  repeat match goal with
  | Hx : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ => apply ev_binop in Hx; destruct Hx as (? & ? & ? & ? & ?)
  | Hx : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ => apply ev_const in Hx; subst
  end.
  repeat match goal with
  | Hs : sem_binary_operation _ _ (Vint _) _ (Vint _) _ _ = Some _ |- _ =>
      vm_compute in Hs; injection Hs as <-
  end.
  f_equal; apply Int.same_if_eq; vm_compute; reflexivity.
Qed.

(* THE CLEAR: clear_spatial_partition(&p[0][0]) zeroes the 768 head words *)
Theorem csp_run : forall bd m t m' vr,
  eval_funcall function_entry2 ge m (Internal SL.f_clear_spatial_partition) [Vptr bd Ptrofs.zero] t m' vr ->
  cl_done bd m m' 768.
Proof.
  intros bd m t m' vr H. inv H.
  match goal with Hfe : function_entry2 _ _ _ _ _ _ _ |- _ => inv Hfe end.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ => cbn [fn_vars SL.f_clear_spatial_partition] in Ha; inv Ha end.
  match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ => cbn in Hb; injection Hb as <- end.
  match goal with Hf : Mem.free_list _ _ = Some _ |- _ => cbn in Hf; injection Hf as -> end.
  match goal with Hx : exec_stmt _ _ _ _ _ (fn_body _) _ _ _ _ |- _ => rewrite csp_body in Hx;
    apply seq_inv in Hx as [(tq & leq & mq & tr & X1 & X2) | (X1 & Hn)] end.
  - apply set_inv in X1 as (v & Ev & -> & -> & _). apply init_256 in Ev. subst v.
    refine (proj1 (loop_run empty_env bd _ 256 _ _ _ _ _ _ ltac:(lia) _ _ _ X2)).
    + apply PTree.gss.
    + rewrite PTree.gso by neq. apply PTree.gss.
    + apply cl_done_0.
  - apply set_inv in X1 as (? & _ & _ & _ & E). exfalso. exact (Hn E).
Qed.

(* &gDynamicSurfacePartition[0][0], as clear_dynamic_surfaces passes it *)
Definition ARG : expr :=
  Ebinop Oadd
    (Ederef
      (Ebinop Oadd
        (Evar SL._gDynamicSurfacePartition (tarray (tarray (tarray SNT 3) 16) 16))
        (Econst_int (Int.repr 0) tint)
        (tptr (tarray (tarray SNT 3) 16)))
      (tarray (tarray SNT 3) 16))
    (Econst_int (Int.repr 0) tint)
    (tptr (tarray SNT 3)).

Lemma arg_val : forall le m v, eval_expr ge empty_env le m ARG v ->
  exists bdp, Genv.find_symbol ge SL._gDynamicSurfacePartition = Some bdp /\ v = Vptr bdp Ptrofs.zero.
Proof.
  intros le m v H. unfold ARG in H.
  apply ev_binop in H as (v1 & v2 & E1 & E2 & E3). apply ev_const in E2. subst v2.
  inv E1. all: try (match goal with Hx : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hx end).
  all: try (match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => inv Hd end; cbn in *; try discriminate).
  rewrite ptr_add0 in E3. injection E3 as <-.
  match goal with Hx : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ =>
    apply ev_binop in Hx as (w1 & w2 & F1 & F2 & F3) end.
  apply ev_const in F2. subst w2.
  inv F1. all: try (match goal with Hx : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ =>
    apply lv_gvar in Hx as (Hs' & -> & ->); [ | reflexivity ] end).
  all: try (match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => inv Hd end; cbn in *; try discriminate).
  rewrite ptr_add0 in F3. injection F3 as <- <-. eauto.
Qed.

(* a global int cell copied: t = g_src; g_dst = t *)
Lemma copy_run : forall le m t le' m' out tmp src dst,
  exec_stmt function_entry2 ge empty_env le m
    (Ssequence (Sset tmp (Evar src tint)) (Sassign (Evar dst tint) (Etempvar tmp tint))) t le' m' out ->
  out = Out_normal /\ exists bs bd v w, Genv.find_symbol ge src = Some bs /\ Genv.find_symbol ge dst = Some bd
    /\ Mem.load Mint32 m bs 0 = Some v /\ sem_cast v tint tint m = Some w
    /\ Mem.store Mint32 m bd 0 w = Some m' /\ le' = PTree.set tmp v le.
Proof.
  intros le m t le' m' out tmp src dst H.
  apply seq_inv in H as [(ta & le1 & m1 & tb & A & B) | (A & Hn)];
    [ | apply set_inv in A as (? & _ & _ & _ & E); exfalso; exact (Hn E) ].
  apply set_inv in A as (v & Ev & -> & -> & _).
  apply (ev_gvar _ _ _ _ _ _ _ Mint32) in Ev as (bs & Ss & Ls); [ | reflexivity | reflexivity ].
  apply assign_inv in B as (b' & o' & bf & v2 & w & Hl & Hv & Hc & Ha & -> & ->).
  apply lv_gvar in Hl as (Sd & -> & ->); [ | reflexivity ].
  apply ev_temp in Hv. rewrite PTree.gss in Hv. injection Hv as <-.
  apply (store_by_value ge tint _ _ _ _ _ _ Mint32 eq_refl eq_refl) in Ha. cbn [typeof] in Hc.
  rewrite Ptrofs.unsigned_zero in Ha. cbn [Mem.loadv] in Ls. rewrite Ptrofs.unsigned_zero in Ls.
  split; [ reflexivity | exists bs, b', v, w; auto 10 ].
Qed.

Section CDS.
Hypothesis Hcsp : forall b fd, Genv.find_symbol ge SL._clear_spatial_partition = Some b ->
  Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd -> fd = Internal SL.f_clear_spatial_partition.

(* THE CLEAR, the real clear_dynamic_surfaces: either nothing (time stop) or
   gSurfacesAllocated = gNumStaticSurfaces; gSurfaceNodesAllocated =
   gNumStaticSurfaceNodes; the 768 dynamic heads NULL *)
Theorem cds_run : forall m t m' vr,
  eval_funcall function_entry2 ge m (Internal SL.f_clear_dynamic_surfaces) [] t m' vr ->
  (m' = m /\ exists bts x, Genv.find_symbol ge SL._gTimeStopState = Some bts
      /\ Mem.load Mint32 m bts 0 = Some (Vint x) /\ Int.eq (Int.and x (Int.repr 64)) Int.zero = false)
  \/ exists bns bsa v1 w1 m1 bnn bna v2 w2 m2 bdp,
       Genv.find_symbol ge SL._gNumStaticSurfaces = Some bns
       /\ Genv.find_symbol ge SL._gSurfacesAllocated = Some bsa
       /\ Mem.load Mint32 m bns 0 = Some v1 /\ sem_cast v1 tint tint m = Some w1
       /\ Mem.store Mint32 m bsa 0 w1 = Some m1
       /\ Genv.find_symbol ge SL._gNumStaticSurfaceNodes = Some bnn
       /\ Genv.find_symbol ge SL._gSurfaceNodesAllocated = Some bna
       /\ Mem.load Mint32 m1 bnn 0 = Some v2 /\ sem_cast v2 tint tint m1 = Some w2
       /\ Mem.store Mint32 m1 bna 0 w2 = Some m2
       /\ Genv.find_symbol ge SL._gDynamicSurfacePartition = Some bdp
       /\ cl_done bdp m2 m' 768.
Proof.
  intros m t m' vr H. inv H.
  match goal with Hfe : function_entry2 _ _ _ _ _ _ _ |- _ => inv Hfe end.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ => cbn [fn_vars SL.f_clear_dynamic_surfaces] in Ha; inv Ha end.
  match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ => cbn in Hb; injection Hb as <- end.
  match goal with Hf : Mem.free_list _ _ = Some _ |- _ => cbn in Hf; injection Hf as -> end.
  match goal with Hx : exec_stmt _ _ _ _ _ (fn_body _) _ _ _ _ |- _ =>
    cbn [fn_body SL.f_clear_dynamic_surfaces] in Hx;
    apply seq_inv in Hx as [(tq & leq & mq & tr & X1 & X2) | (X1 & Hn)];
    [ | apply set_inv in X1 as (? & _ & _ & _ & E); exfalso; exact (Hn E) ] end.
  apply set_inv in X1 as (v0 & Ev0 & -> & -> & _).
  apply (ev_gvar _ _ _ _ _ _ _ Mint32) in Ev0 as (bts & Sts & Lts); [ | reflexivity | reflexivity ].
  cbn [Mem.loadv] in Lts. rewrite Ptrofs.unsigned_zero in Lts.
  apply if_inv in X2 as (vc & bc & Ec & Bc & X2). destruct bc.
  - right.
    apply seq_inv in X2 as [(tc & leA & mA & td & X3 & X4) | (X3 & Hn)];
      [ | apply copy_run in X3 as (E & _); exfalso; exact (Hn E) ].
    apply copy_run in X3 as (_ & bns & bsa & v1 & w1 & S1 & S2 & L1 & C1 & St1 & ->).
    apply seq_inv in X4 as [(te & leB & mB & tf & X5 & X6) | (X5 & Hn)];
      [ | apply copy_run in X5 as (E & _); exfalso; exact (Hn E) ].
    apply copy_run in X5 as (_ & bnn & bna & v2 & w2 & S3 & S4 & L2 & C2 & St2 & ->).
    apply call_inv in X6 as (tyargs & tyres & cc & vf & vargs & fd & vres & Hcl & Ef & Eal & Hff & _ & Hev & _ & _).
    cbn in Hcl. injection Hcl as <- <- <-.
    apply ev_fun in Ef as (bf & Sf & ->); [ | reflexivity | reflexivity ].
    rewrite (Hcsp _ _ Sf Hff) in Hev.
    inv Eal. match goal with Hx : eval_exprlist _ _ _ _ nil _ _ |- _ => inv Hx end.
    match goal with Ha : eval_expr _ _ _ _ _ _ |- _ =>
      apply arg_val in Ha as (bdp & Sd & ->) end.
    match goal with Hc : sem_cast _ _ _ _ = Some _ |- _ => cbn in Hc; injection Hc as <- end.
    exists bns, bsa, v1, w1, mA, bnn, bna, v2, w2, mB, bdp.
    repeat (split; [ assumption | ]). exact (csp_run _ _ _ _ _ Hev).
  - left. apply skip_inv in X2 as (-> & _ & _). split; [ reflexivity | ].
    inv Ec. 2: { match goal with Hx : eval_lvalue _ _ _ _ (Eunop _ _ _) _ _ _ |- _ => inv Hx end. }
    match goal with Hx : eval_expr _ _ _ _ (Ebinop Oand _ _ _) _ |- _ =>
      apply ev_binop in Hx as (a1 & a2 & A1 & A2 & A3) end.
    apply ev_temp in A1. rewrite PTree.gss in A1. injection A1 as <-.
    apply ev_binop in A2 as (c1 & c2 & C1 & C2 & C3). apply ev_const in C1. apply ev_const in C2. subst c1 c2.
    vm_compute in C3. injection C3 as <-.
    exists bts. destruct v0 as [| x | | | | ]; try (cbn in A3; discriminate A3).
    exists x. split; [ exact Sts | split; [ exact Lts | ] ].
    assert (Ha : forall a r, sem_binary_operation ge Oand (Vint a) tuint (Vint r) tint m1 = Some (Vint (Int.and a r)))
      by (intros; reflexivity).
    cbn [typeof] in A3. rewrite Ha in A3. injection A3 as <-.
    assert (Hn : forall a, sem_unary_operation Onotbool (Vint a) tuint m1 = Some (Val.of_bool (negb (negb (Int.eq a Int.zero)))))
      by (intros; reflexivity).
    match goal with Hu : sem_unary_operation _ _ _ _ = Some _ |- _ => cbn [typeof] in Hu; rewrite Hn in Hu; injection Hu as <- end.
    assert (Bb : forall z, bool_val (Val.of_bool z) tint m1 = Some z) by (intros [|]; reflexivity).
    cbn [typeof] in Bc. rewrite Bb in Bc. injection Bc as Bc. rewrite Bool.negb_involutive in Bc.
    match type of Bc with Int.eq (Int.and x ?r) Int.zero = false =>
      assert (Er : r = Int.repr 64) by (apply Int.same_if_eq; vm_compute; reflexivity); rewrite Er in Bc end.
    exact Bc.
Qed.
End CDS.

End CR.
