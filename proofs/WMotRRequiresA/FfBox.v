(* ====================================================================== *)
(* FfBox (GOAL 2, chunk B-xz): a floor find_floor finds lies in the box.   *)
(*                                                                          *)
(* find_floor (surface_collision.c:513) casts xPos / zPos to s16           *)
(* (TerrainData) and, when either is <= -LEVEL_BOUNDARY_MAX or >=          *)
(* LEVEL_BOUNDARY_MAX (8192), returns with *pfloor = NULL.  So a non-NULL  *)
(* floor means BOTH s16 casts are in (-8192, 8192): `s16box`.              *)
(*                                                                          *)
(* The box is on the s16 CAST, not on the float: a float x of 65536 + 100  *)
(* casts to 100 and passes the test (parallel universes).  The proof       *)
(* claims nothing about |x| itself.                                        *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia.
From compcert Require Import Coqlib Errors Maps AST Integers Floats Values Memory Events
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep.
From SM64.Generated Require surface_collision.
From SM64.Proofs.WMotRRequiresA Require Import FloorList FloorHeight FfComplete.
Import ListNotations.

(* THE BOX: the s16 cast find_floor computes is strictly inside
   +-LEVEL_BOUNDARY_MAX *)
Definition s16box (v : val) : Prop :=
  exists X, ycast v = Vint X /\ (-8192 < Int.signed X < 8192)%Z.

Local Tactic Notation "sq" ident(S) ident(L) ident(M) :=
  try clear S;
  match goal with Hx : exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ |- _ =>
    let Hn := fresh "Hn" in
    apply x_seq in Hx as [(? & L & M & ? & S & Hx) | (S & Hn)]; [| noab S Hn]
  end.

Local Ltac lk H := ptg; exact H.

Lemma repr1_nz: Int.repr 1 <> Int.zero.
Proof. intro E. apply (f_equal Int.unsigned) in E. vm_compute in E. discriminate E. Qed.

(* one bounds block: memory unchanged; it falls through only in bounds *)
Lemma bnd_cases : forall (ge : genv) e le M xid t1 tr v t le' M' out,
    le ! xid = Some v ->
    exec_stmt function_entry2 ge e le M (bnd_blk xid t1 tr) t le' M' out ->
    M' = M /\ (out = Out_normal -> exists X, v = Vint X /\ (-8192 < Int.signed X < 8192)%Z
                                     /\ exists w, le' = PTree.set t1 w le).
Proof.
  intros ge e le M xid t1 tr v t le' M' out Hx H. unfold bnd_blk in H.
  assert (T1 : forall t0 le1 M1 o, exec_stmt function_entry2 ge e le M
      (Sifthenelse (Ebinop Ole (Etempvar xid tshort)
                   (Eunop Oneg (Econst_int (Int.repr 8192) tint) tint) tint)
      (Sset t1 (Econst_int (Int.repr 1) tint))
      (Sset t1 (Ecast (Ebinop Oge (Etempvar xid tshort) (Econst_int (Int.repr 8192) tint) tint) tbool)))
      t0 le1 M1 o -> o = Out_normal /\ M1 = M /\
      exists X c, v = Vint X /\ le1 = PTree.set t1 (Vint c) le
        /\ (c = Int.zero -> (-8192 < Int.signed X < 8192)%Z)).
  { intros t0 le1 M1 o S.
    apply x_ite in S as (w & b & Hw & Hb & S).
    inv Hw; [| match goal with Hl : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv Hl end].
    match goal with Ha : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
      apply ev_tv in Ha; rewrite Hx in Ha; injection Ha as <- end.
    match goal with Ha : eval_expr _ _ _ _ (Eunop _ _ _) _ |- _ =>
      inv Ha; [| match goal with Hl : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv Hl end] end.
    match goal with Ha : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ => apply ev_ci in Ha; subst end.
    match goal with Hu : sem_unary_operation _ _ _ _ = Some _ |- _ => cbn in Hu; injection Hu as <- end.
    destruct v as [| X | | | | ];
      try (match goal with Hs : sem_binary_operation _ Ole _ _ _ _ _ = Some _ |- _ =>
             cbn in Hs; discriminate Hs end).
    match goal with Hs : sem_binary_operation _ Ole _ _ _ _ _ = Some ?w |- _ =>
      assert (Ew : Some w = Some (Val.of_bool (Int.cmp Cle X (Int.neg (Int.repr 8192)))))
        by (rewrite <- Hs; reflexivity);
      injection Ew as ->; clear Hs end.
    cbn [Int.cmp] in Hb.
    destruct (Int.lt (Int.neg (Int.repr 8192)) X) eqn:C1;
      cbn in Hb; injection Hb as <-; cbv beta iota in S.
    2:{ apply x_set in S as (w & Hw & -> & -> & ->).
        apply ev_ci in Hw. subst w.
        split; [reflexivity | split; [reflexivity |]].
        exists X, (Int.repr 1). split; [reflexivity | split; [reflexivity |]].
        intros E. exfalso. exact (repr1_nz E). }
    - apply x_set in S as (w & Hw & -> & -> & ->).
      split; [reflexivity | split; [reflexivity |]].
      inv Hw; [| match goal with Hl : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv Hl end].
      match goal with Ha : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ =>
        inv Ha; [| match goal with Hl : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv Hl end] end.
      match goal with Ha : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
        apply ev_tv in Ha; rewrite Hx in Ha; injection Ha as <- end.
      match goal with Ha : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ => apply ev_ci in Ha; subst end.
      match goal with Hs : sem_binary_operation _ Oge _ _ _ _ _ = Some ?w |- _ =>
        assert (Ew : Some w = Some (Val.of_bool (Int.cmp Cge X (Int.repr 8192))))
          by (rewrite <- Hs; reflexivity);
        injection Ew as ->; clear Hs end.
      cbn [Int.cmp] in *.
      destruct (Int.lt X (Int.repr 8192)) eqn:C2; cbn [negb] in *.
      2:{ match goal with Hc : sem_cast _ _ _ _ = Some ?w |- _ =>
          assert (Ew : Some w = Some (Vint Int.one)) by (rewrite <- Hc; reflexivity);
          injection Ew as ->; clear Hc end.
        exists X, Int.one. split; [reflexivity | split; [reflexivity |]].
        intros E. exfalso. exact (repr1_nz E). }
      + match goal with Hc : sem_cast _ _ _ _ = Some ?w |- _ =>
          assert (Ew : Some w = Some (Vint Int.zero)) by (rewrite <- Hc; reflexivity);
          injection Ew as ->; clear Hc end.
        exists X, Int.zero. split; [reflexivity | split; [reflexivity |]].
        intros _. unfold Int.lt in C1, C2.
        change (Int.signed (Int.neg (Int.repr 8192))) with (-8192)%Z in C1.
        change (Int.signed (Int.repr 8192)) with 8192%Z in C2.
        destruct (zlt (-8192) (Int.signed X)); [| discriminate C1].
        destruct (zlt (Int.signed X) 8192); [| discriminate C2].
        lia. }
  apply x_seq in H as [(ta & le1 & M1 & tb & H1 & H2) | (H1 & Hn)].
  - destruct (T1 _ _ _ _ H1) as (_ & -> & X & c & -> & -> & Hc).
    apply x_ite in H2 as (w & b & Hw & Hb & H2).
    apply ev_tv in Hw. rewrite PTree.gss in Hw. injection Hw as <-.
    cbn in Hb. injection Hb as <-.
    destruct (Int.eq c Int.zero) eqn:Ec; cbn [negb] in H2; cbv beta iota in H2.
    + inv H2. split; [reflexivity |]. intros _. exists X. split; [reflexivity |].
      split; [apply Hc; exact (Int.same_if_eq _ _ Ec) | eexists; reflexivity].
    + apply x_seq in H2 as [(? & ? & ? & ? & S1 & S2) | (S1 & Hn)].
      * apply x_set in S1 as (? & _ & ? & EM & _). subst. inv S2.
        split; [reflexivity | intros E; discriminate E].
      * apply x_set in S1 as (_ & _ & _ & _ & ->). congruence.
  - destruct (T1 _ _ _ _ H1) as (-> & _). congruence.
Qed.

(* THE WALK: find_floor's body either stores NULL into *pfloor and ends
   there, or gets past both bounds tests *)
Lemma body_box : forall (ge : genv) bpf opf bH bD xv yv zv le0 M0 t le' M' out,
    le0 ! surface_collision._xPos = Some xv -> le0 ! surface_collision._yPos = Some yv ->
    le0 ! surface_collision._zPos = Some zv ->
    le0 ! surface_collision._pfloor = Some (Vptr bpf opf) ->
    exec_stmt function_entry2 ge (ffe bH bD) le0 M0 (fn_body surface_collision.f_find_floor)
      t le' M' out ->
    (s16box xv /\ s16box zv)
    \/ Mem.load Mint32 M' bpf (Ptrofs.unsigned opf) = Some (Vint Int.zero).
Proof.
  intros ge bpf opf bH bD xv yv zv le0 M0 t le' M' out Lx Ly Lz Lp Hx.
  cbn [fn_body surface_collision.f_find_floor] in Hx.
  sq S le1 M1. apply x_asg in S as (_ & _ & _ & _ & _ & _ & _ & _ & _ & -> & _).
  sq S le2 M2. apply x_asg in S as (_ & _ & _ & _ & _ & _ & _ & _ & _ & -> & _).
  sq S le3 M3. apply x_set in S as (vx & Evx & -> & -> & _).
  eapply ev_s16 in Evx; [| exact Lx]. subst vx.
  sq S le4 M4. apply x_set in S as (vy & _ & -> & -> & _).
  sq S le5 M5. apply x_set in S as (vz & Evz & -> & -> & _).
  eapply ev_s16 in Evz; [| lk Lz]. subst vz.
  (* *pfloor := NULL *)
  sq S le6 M6.
  apply x_asg in S as (b6 & o6 & bf6 & v6 & v6' & Hl6 & Hv6 & Hc6 & Ha6 & -> & _).
  eapply lv_deref_tv in Hl6 as (E6a & E6b & E6c); [| lk Lp]. subst b6 o6 bf6.
  inv Hv6; [| match goal with Hl : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv Hl end].
  match goal with Ha : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ => apply ev_ci in Ha; subst end.
  match goal with Hc : sem_cast (Vint _) _ _ _ = Some _ |- _ => cbn in Hc; injection Hc as <- end.
  cbn [typeof] in Hc6. cbn in Hc6. injection Hc6 as <-.
  cbn [typeof] in Ha6.
  eapply (asg_store _ _ _ _ _ _ _ Mint32) in Ha6; [| reflexivity].
  assert (L6 : Mem.load Mint32 M6 bpf (Ptrofs.unsigned opf) = Some (Vint Int.zero))
    by (rewrite (Mem.load_store_same _ _ _ _ _ _ Ha6); reflexivity).
  (* the x bounds test *)
  apply x_seq in Hx as [(? & le7 & M7 & ? & S & Hx) | (S & Hn)].
  2:{ right. eapply bnd_cases in S as (-> & _); [exact L6 | ptg; reflexivity]. }
  eapply bnd_cases in S as (-> & BX); [| ptg; reflexivity].
  destruct (BX eq_refl) as (X & EX & HX & w7 & ->).
  (* the z bounds test *)
  apply x_seq in Hx as [(? & le8 & M8 & ? & S & Hx) | (S & Hn)].
  2:{ right. eapply bnd_cases in S as (-> & _); [exact L6 | ptg; reflexivity]. }
  eapply bnd_cases in S as (-> & BZ); [| ptg; reflexivity].
  destruct (BZ eq_refl) as (Z & EZ & HZ & _).
  left. split; [exists X | exists Z]; split; assumption.
Qed.

(* THE HIT FACT: a non-NULL floor means both s16 casts are in the box *)
Theorem ff_hit_box : forall (ge : genv) m xv yv zv bpf opf t m' vres,
    Mem.valid_block m bpf ->
    eval_funcall function_entry2 ge m (Internal surface_collision.f_find_floor)
      [xv; yv; zv; Vptr bpf opf] t m' vres ->
    forall F, Mem.loadv Mint32 m' (Vptr bpf opf) = Some F -> F <> Vint Int.zero ->
    s16box xv /\ s16box zv.
Proof.
  intros ge m xv yv zv bpf opf t m' vres Hpv H F LF NF.
  inv H.
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => inv He end.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
    cbn [surface_collision.f_find_floor fn_vars] in Ha; inv Ha end.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ => inv Ha end.
  match goal with Ha : alloc_variables _ _ _ [] _ _ |- _ => inv Ha end.
  match goal with
  | A1 : Mem.alloc m 0 _ = (?M1, ?b1), A2 : Mem.alloc ?M1 0 _ = (?M2, ?b2) |- _ =>
      rename b1 into bH, b2 into bD, A1 into HA1, A2 into HA2, M1 into mA, M2 into mB
  end.
  assert (HnvH : ~ Mem.valid_block m bH) by exact (Mem.fresh_block_alloc _ _ _ _ _ HA1).
  assert (HnvD : ~ Mem.valid_block m bD)
    by (intro HH; exact (Mem.fresh_block_alloc _ _ _ _ _ HA2 (Mem.valid_block_alloc _ _ _ _ _ HA1 _ HH))).
  assert (NpH : bpf <> bH) by (intros ->; contradiction).
  assert (NpD : bpf <> bD) by (intros ->; contradiction).
  match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ =>
    cbn [bind_parameter_temps surface_collision.f_find_floor fn_params] in Hb; injection Hb as <- end.
  match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody end.
  eapply body_box in Hbody;
    [| ptg; reflexivity | ptg; reflexivity | ptg; reflexivity | ptg; reflexivity].
  destruct Hbody as [B | L].
  - exact B.
  - exfalso. apply NF.
    match goal with Hf : Mem.free_list ?M _ = Some ?R |- _ =>
      first [ change (Mem.free_list M [(bH, 0, 4); (bD, 0, 4)] = Some R) in Hf
            | change (Mem.free_list M [(bD, 0, 4); (bH, 0, 4)] = Some R) in Hf ];
      cbn [Mem.free_list] in Hf end.
    match goal with Hf : (match Mem.free ?M ?b1 0 4 with Some _ => _ | None => _ end) = Some _ |- _ =>
      destruct (Mem.free M b1 0 4) as [M4|] eqn:F1; [| discriminate Hf] end.
    match goal with Hf : (match Mem.free ?M ?b1 0 4 with Some _ => _ | None => _ end) = Some _ |- _ =>
      destruct (Mem.free M b1 0 4) as [M5|] eqn:F2; [| discriminate Hf]; injection Hf as <- end.
    cbn [Mem.loadv] in LF.
    rewrite (Mem.load_free _ _ _ _ _ F2) in LF by (left; first [exact NpH | exact NpD]).
    rewrite (Mem.load_free _ _ _ _ _ F1) in LF by (left; first [exact NpH | exact NpD]).
    rewrite L in LF. injection LF as <-. reflexivity.
Qed.
