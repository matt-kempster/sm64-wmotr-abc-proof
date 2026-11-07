(* ====================================================================== *)
(* UnloadKeep (GOAL 2 objects, 2026-11-03): unload_deactivated_objects    *)
(* (object_list_processor.c:587-600), its real body walked.               *)
(*                                                                        *)
(*   for (i = 0; (listIndex = sObjectListUpdateOrder[i]) != -1; i++)      *)
(*       unload_deactivated_objects_in_list(&gObjectLists[listIndex]);    *)
(*   gTimeStopState &= ~TIME_STOP_UNLOAD_OBJECTS? (bit 0 cleared)         *)
(*                                                                        *)
(* 1. unload_outer: over any invariant P that carries obj_w, the whole    *)
(*    call keeps P from (a) P kept by unload_deactivated_objects_in_list *)
(*    on each list head the order table names (i = 0..9; obj_w's        *)
(*    ow_order pins the table, its 11th entry -1 ends the loop), (b) an  *)
(*    int store into gTimeStopState, (c) the frame block of the unused   *)
(*    local filler[4]: fresh (Hfresh), kept unreferenced by the whole     *)
(*    call (Hnoref; Mem.free keeps contents), invisible to P (Hblind).    *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia Bool.
From compcert Require Import Coqlib Maps AST Integers Floats Values Memory
  Globalenvs Ctypes Cop Clight ClightBigstep Clightdefs Events Errors.
From compcert Require Linking.
From SM64.Generated Require object_list_processor.
From SM64.Proofs Require Import SymbolicLinking LinkedTwelve RealFrameLinked.
From SM64.Proofs.WMotRRequiresA Require Import RenderAnim.
From SM64.Proofs.WMotRRequiresA Require ObjPhase ObjWorld ObjLoop.

Import ListNotations.
Local Open Scope Z_scope.
Local Transparent Archi.ptr64.

Module OLP := SM64.Generated.object_list_processor.
Module OW := SM64.Proofs.WMotRRequiresA.ObjWorld.

(* Mem.free changes permissions only *)
Section TrFree.
Local Transparent Mem.free.
Lemma free_contents : forall m b lo hi m', Mem.free m b lo hi = Some m' -> Mem.mem_contents m' = Mem.mem_contents m.
Proof.
  intros m b lo hi m' H. unfold Mem.free in H.
  destruct (Mem.range_perm_dec m b lo hi Cur Freeable); [ | discriminate H ].
  injection H as <-. reflexivity.
Qed.
End TrFree.

Lemma noref_free : forall m b lo hi m' fb, Mem.free m b lo hi = Some m' -> ObjPhase.noref fb m' -> ObjPhase.noref fb m.
Proof.
  intros m b lo hi m' fb H N b' ofs Hne. specialize (N b' ofs Hne). rewrite (free_contents _ _ _ _ _ H) in N. exact N.
Qed.

Section Real.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Notation G := (lp_ge lp).
  Variable bm : block.

  Ltac kill_abn :=
    match goal with
    | A : exec_stmt _ _ _ _ _ ?s _ _ _ ?o, Hn : ?o <> Out_normal |- _ =>
        exfalso; exact (Hn (ObjLoop.plain_out _ _ _ _ _ _ _ _ _ A eq_refl))
    end.

  Definition ud_loop_body : statement :=
    match fn_body OLP.f_unload_deactivated_objects with Ssequence _ (Ssequence (Sloop b _) _) => b | _ => Sskip end.
  Definition ud_head : statement := match ud_loop_body with Ssequence h _ => h | _ => Sskip end.
  Definition ud_rest : statement := match ud_loop_body with Ssequence _ r => r | _ => Sskip end.
  Definition ud_tail : statement :=
    match fn_body OLP.f_unload_deactivated_objects with Ssequence _ (Ssequence _ t) => t | _ => Sskip end.

  Lemma ud_shape : fn_body OLP.f_unload_deactivated_objects
    = Ssequence (Sset OLP._i (Econst_int (Int.repr 0) tint))
        (Ssequence (Sloop (Ssequence ud_head ud_rest) Sskip) ud_tail).
  Proof. reflexivity. Qed.

  Lemma dm_ud : (prog_defmap OLP.prog) ! OLP._unload_deactivated_objects
    = Some (Gfun (Internal OLP.f_unload_deactivated_objects)).
  Proof. vm_compute. reflexivity. Qed.
  Lemma dm_udl : (prog_defmap OLP.prog) ! OLP._unload_deactivated_objects_in_list
    = Some (Gfun (Internal OLP.f_unload_deactivated_objects_in_list)).
  Proof. vm_compute. reflexivity. Qed.

  (* the indices the loop visits: the first ten entries of the order table *)
  Lemma ud_idx : forall n, (n < 10)%nat ->
    exists idx, nth n OW.upd_order 0 = Z.of_nat idx /\ (idx < 13)%nat.
  Proof.
    intros n H. destruct n as [|[|[|[|[|[|[|[|[|[|n]]]]]]]]]]; try lia.
    1: exists 11%nat. 2: exists 9%nat. 3: exists 10%nat. 4: exists 0%nat. 5: exists 5%nat.
    6: exists 4%nat. 7: exists 2%nat. 8: exists 6%nat. 9: exists 8%nat. 10: exists 12%nat.
    all: split; [ reflexivity | lia ].
  Qed.

  (* the loop head: t'4 = sObjectListUpdateOrder[i]; t'1 = (int) t'4;
     listIndex = t'1; if (t'1 == -1) break *)
  Lemma head_ud : forall e le m t le1 m1 out n ob,
    e ! OLP._sObjectListUpdateOrder = None ->
    Genv.find_symbol G OLP._sObjectListUpdateOrder = Some ob ->
    (forall j, (j < 11)%nat -> Mem.load Mint8signed m ob (Z.of_nat j) = Some (Vint (Int.repr (nth j OW.upd_order 0)))) ->
    le ! OLP._i = Some (Vint (Int.repr (Z.of_nat n))) -> (n <= 10)%nat ->
    exec_stmt function_entry2 G e le m ud_head t le1 m1 out ->
    m1 = m /\ le1 ! OLP._i = le ! OLP._i /\
    ((n = 10%nat /\ out = Out_break) \/
     ((n < 10)%nat /\ out = Out_normal /\ le1 ! OLP._listIndex = Some (Vint (Int.repr (nth n OW.upd_order 0))))).
  Proof.
    intros e le m t le1 m1 out n ob He Hs Hord Hi Hn H.
    unfold ud_head, ud_loop_body, OLP.f_unload_deactivated_objects in H. cbn [fn_body] in H.
    apply seq_inv in H as [(t1 & le2 & m2 & t2 & H1 & H2) | (H1 & Hn')]; [ | kill_abn ].
    apply seq_inv in H1 as [(t3 & le3 & m3 & t4 & H3 & H4) | (H3 & Hn')]; [ | kill_abn ].
    apply seq_inv in H3 as [(t5 & le5 & m5 & t6 & H5 & H6) | (H5 & Hn')]; [ | kill_abn ].
    apply set_inv in H5 as (v5 & Ev5 & -> & -> & _).
    pose proof (ObjLoop.ev_order lp e le m n v5 ob He Hs Hi ltac:(lia) Ev5) as Hl5.
    rewrite Hord in Hl5 by lia. injection Hl5 as <-.
    apply set_inv in H6 as (v1 & Ev1 & -> & -> & _).
    apply ev_cast in Ev1 as (u & Eu & Cu). apply ev_temp in Eu. rewrite PTree.gss in Eu. injection Eu as <-.
    cbn [typeof] in Cu. apply ObjLoop.cast_sc in Cu. subst v1.
    apply set_inv in H4 as (v2 & Ev2 & -> & -> & _).
    apply ev_temp in Ev2. rewrite PTree.gss in Ev2. injection Ev2 as <-.
    apply if_inv in H2 as (cv & bb & Ecv & Hbv & H2).
    apply ev_binop in Ecv as (w1 & w2 & W1 & W2 & W3).
    apply ev_temp in W1. rewrite PTree.gso, PTree.gss in W1 by neq. injection W1 as <-.
    apply (ObjLoop.ev_unop lp) in W2 as (u1 & U1 & U2). apply ev_const in U1. subst u1.
    cbn [typeof] in W3, U2, Hbv.
    destruct (ObjLoop.ifsb lp _ _ _ _ _ _ _ _ H2) as (-> & -> & ->).
    split; [ reflexivity | ].
    split; [ rewrite !PTree.gso by neq; reflexivity | ].
    destruct n as [|[|[|[|[|[|[|[|[|[|[|n]]]]]]]]]]]; try lia.
    all: vm_compute in U2; injection U2 as <-; vm_compute in W3; injection W3 as <-;
         vm_compute in Hbv; injection Hbv as <-.
    all: first [ (left; split; reflexivity) | (right; split; [ lia | split; [ reflexivity | apply PTree.gss ] ]) ].
  Qed.

  Section Outer.
    Variable P : mem -> Prop.
    Hypothesis HPow : forall m, P m -> OW.obj_w G bm m.
    (* (a) the per-list call, on a head the order table names *)
    Hypothesis Hil : forall la idx m t m' vr, (idx < 13)%nat ->
      Genv.find_symbol G OLP._gObjectListArray = Some la -> P m ->
      eval_funcall function_entry2 G m (Internal OLP.f_unload_deactivated_objects_in_list)
        [ObjLoop.head_v la idx] t m' vr -> P m'.
    (* (b) gTimeStopState = <an int> *)
    Hypothesis Hts : forall m b c m', P m -> Genv.find_symbol G OLP._gTimeStopState = Some b ->
      Mem.store Mint32 m b 0 (Vint c) = Some m' -> P m'.
    (* (c) the frame block *)
    Hypothesis Hblind : forall b m m', Ple (Genv.genv_next G) b -> P m -> ObjPhase.noref b m ->
      Mem.unchanged_on (fun b' _ => b' <> b) m m' -> P m'.
    Hypothesis Hfresh : forall m m1 b, P m -> Mem.alloc m 0 4 = (m1, b) ->
      Ple (Genv.genv_next G) b /\ ObjPhase.noref b m1.
    Hypothesis Hnoref : forall b, Ple (Genv.genv_next G) b ->
      ObjPhase.call_keeps G (ObjPhase.noref b) OLP._unload_deactivated_objects.

    Section Frame.
      Variable e : env.
      Hypothesis He1 : e ! OLP._gObjectLists = None.
      Hypothesis He2 : e ! OLP._unload_deactivated_objects_in_list = None.
      Hypothesis He4 : e ! OLP._sObjectListUpdateOrder = None.

      Definition Kud (le : temp_env) (m : mem) : Prop :=
        P m /\ exists n, le ! OLP._i = Some (Vint (Int.repr (Z.of_nat n))) /\ (n <= 10)%nat.

      Lemma it_ud : forall le m t le1 m1 out,
        exec_stmt function_entry2 G e le m (Ssequence ud_head ud_rest) t le1 m1 out -> Kud le m ->
        P m1 /\ (out = Out_break \/ (out = Out_normal /\ Kud le1 m1)).
      Proof.
        intros le m t le1 m1 out H (HP & n & Hi & Hn).
        destruct (HPow m HP) as (pool & la & fl & gol & gmo & sdp & gdi & rs & fs & S1 & S2 & S3 & S4 & S5 & S6 & S7 & Hc).
        destruct (OW.ow_order _ _ _ _ _ _ _ _ _ _ _ _ Hc) as (ob & Hob & Hord).
        apply seq_inv in H as [(t1 & le2 & m2 & t2 & H1 & H2) | (H1 & Hn')].
        2: { destruct (head_ud _ _ _ _ _ _ _ n ob He4 Hob Hord Hi Hn H1) as (-> & _ & [(_ & ->) | (_ & E & _)]);
             [ split; [ exact HP | left; reflexivity ] | exfalso; exact (Hn' E) ]. }
        destruct (head_ud _ _ _ _ _ _ _ n ob He4 Hob Hord Hi Hn H1) as (-> & Hi2 & [(_ & E) | (Hlt & _ & Hli)]);
          [ discriminate E | ].
        destruct (ud_idx n Hlt) as (idx & Eidx & Hidx).
        unfold ud_rest, ud_loop_body, OLP.f_unload_deactivated_objects in H2. cbn [fn_body] in H2.
        apply seq_inv in H2 as [(t3 & le3 & m3 & t4 & H3 & H4) | (H3 & Hn')]; [ | kill_abn ].
        apply seq_inv in H3 as [(t5 & le5 & m5 & t6 & H5 & H6) | (H5 & Hn')]; [ | kill_abn ].
        apply set_inv in H5 as (gv & Egv & -> & -> & _).
        destruct (ev_gvar G e m le2 OLP._gObjectLists ObjLoop.tnode gv Mint32 He1 eq_refl Egv) as (bg & Hbg & Hlg).
        rewrite Hbg in S4. injection S4 as <-.
        cbn [Mem.loadv] in Hlg. rewrite Ptrofs.unsigned_zero, (OW.ow_gol _ _ _ _ _ _ _ _ _ _ _ _ Hc) in Hlg.
        injection Hlg as <-.
        apply call_inv in H6 as (tya & tyr & cc & vf & vargs & fd & vres & Hcf & Evf & Eal & Hff & _ & Hcall & -> & _).
        cbn in Hcf. injection Hcf as <- <- <-.
        destruct (ev_fun G e m _ OLP._unload_deactivated_objects_in_list (Tfunction [tptr (Tstruct OLP._ObjectNode noattr)] tint cc_default) vf He2 eq_refl Evf) as (bf & Hs & ->).
        rewrite (ObjLoop.fun_olp lp H12 _ _ dm_udl bf fd Hs Hff) in Hcall.
        destruct (ObjLoop.exl1 _ _ _ _ _ _ _ Eal) as (ty1 & v1 & w1 & E1 & -> & Ev1 & C1). injection E1 as <-.
        apply ev_binop in Ev1 as (x1 & x2 & X1 & X2 & X3).
        apply ev_temp in X1. rewrite PTree.gss in X1. injection X1 as <-.
        apply ev_temp in X2. rewrite PTree.gso in X2 by neq. rewrite Hli, Eidx in X2. injection X2 as <-.
        cbn [typeof] in X3.
        assert (E : sem_binary_operation G Oadd (Vptr la Ptrofs.zero) (tptr (Tstruct OLP._ObjectNode noattr)) (Vint (Int.repr (Z.of_nat idx))) tint m
                    = Some (Vptr la (Ptrofs.add Ptrofs.zero (Ptrofs.mul (Ptrofs.repr (sizeof G (Tstruct OLP._ObjectNode noattr)))
                                                                      (Ptrofs.of_ints (Int.repr (Z.of_nat idx))))))) by reflexivity.
        rewrite E, (ObjLoop.sz_node lp H12), (ObjLoop.ofs_idx _ Hidx) in X3. injection X3 as <-.
        cbn [typeof] in C1. apply ObjLoop.cast_tnode in C1. subst w1.
        pose proof (Hil la idx m _ m3 vres Hidx S2 HP Hcall) as HP3.
        apply set_inv in H4 as (vi & Evi & -> & -> & ->).
        apply ev_binop in Evi as (z1 & z2 & Z1 & Z2 & Z3).
        apply ev_temp in Z1. cbn [set_opttemp] in Z1. rewrite !PTree.gso in Z1 by neq. rewrite Hi2, Hi in Z1. injection Z1 as <-.
        apply ev_const in Z2. subst z2. cbn [typeof] in Z3.
        assert (E2 : sem_binary_operation G Oadd (Vint (Int.repr (Z.of_nat n))) tint (Vint (Int.repr 1)) tint m3
                    = Some (Vint (Int.add (Int.repr (Z.of_nat n)) (Int.repr 1)))) by reflexivity.
        rewrite E2 in Z3. injection Z3 as <-.
        split; [ exact HP3 | right; split; [ reflexivity | ] ].
        split; [ exact HP3 | exists (S n); split; [ rewrite PTree.gss, (ObjLoop.add1 n ltac:(lia)); reflexivity | lia ] ].
      Qed.

      Lemma loop_ud : forall le m t le' m' out,
        exec_stmt function_entry2 G e le m (Sloop (Ssequence ud_head ud_rest) Sskip) t le' m' out ->
        Kud le m -> P m' /\ out = Out_normal.
      Proof.
        intros le m t le' m' out H. pose proof it_ud as IT.
        remember (Sloop (Ssequence ud_head ud_rest) Sskip) as S eqn:ES.
        revert ES. induction H; intros ES HK; try discriminate ES; injection ES as E1 E2; subst.
        - destruct (IT _ _ _ _ _ _ H HK) as (HP1 & [-> | (-> & _)]); inv H0. split; [ exact HP1 | reflexivity ].
        - apply skip_inv in H1 as (_ & _ & ->). inv H2.
        - destruct (IT _ _ _ _ _ _ H HK) as (HP1 & [-> | (-> & HK1)]); [ inv H0 | ].
          apply skip_inv in H1 as (-> & -> & _).
          eapply IHexec_stmt3; eauto.
      Qed.

      (* t'2 = gTimeStopState; gTimeStopState = t'2 & ~1 *)
      Lemma tail_ud : forall le m t le' m' out, P m ->
        e ! OLP._gTimeStopState = None ->
        exec_stmt function_entry2 G e le m ud_tail t le' m' out -> P m' /\ out = Out_normal.
      Proof.
        intros le m t le' m' out HP He H.
        unfold ud_tail, OLP.f_unload_deactivated_objects in H. cbn [fn_body] in H.
        apply seq_inv in H as [(t1 & le1 & m1 & t2 & H1 & H2) | (H1 & Hn')]; [ | kill_abn ].
        apply set_inv in H1 as (tv & Etv & -> & -> & _).
        apply assign_inv in H2 as (b & o & bf & v2 & v & Hlv & Ev & Hcast & Has & -> & ->).
        destruct (lv_gvar G e m _ _ _ _ _ _ He Hlv) as (Hs & -> & ->).
        apply ev_binop in Ev as (y1 & y2 & Y1 & Y2 & Y3).
        apply ev_temp in Y1. rewrite PTree.gss in Y1. injection Y1 as <-.
        cbn [typeof] in Y3.
        assert (Hv : exists c, v2 = Vint c).
        { destruct tv, y2; cbn in Y3; try (unfold Archi.ptr64 in Y3; cbn in Y3); try discriminate Y3; try (injection Y3 as <-; eauto; fail). all: unfold sem_and, sem_binarith, sem_cast in Y3; cbn in Y3; unfold Archi.ptr64 in Y3; cbn in Y3; injection Y3 as <-; eauto. }
        destruct Hv as (c & ->). cbn [typeof] in Hcast. cbn in Hcast. injection Hcast as <-.
        pose proof (store_by_value G tuint m b Ptrofs.zero Full (Vint c) m' Mint32 eq_refl eq_refl Has) as Hst.
        rewrite Ptrofs.unsigned_zero in Hst.
        exact (conj (Hts _ _ _ _ HP Hs Hst) eq_refl).
      Qed.
    End Frame.

    Ltac envtac := rewrite PTree.gso by neq; apply PTree.gempty.

    (* unload_deactivated_objects: PROVED from the per-list row *)
    Theorem unload_outer : ObjPhase.call_keeps G P OLP._unload_deactivated_objects.
    Proof.
      intros bf fd m vargs t m' vr Hs Hf HP Hev.
      pose proof Hev as Hev0.
      rewrite (ObjLoop.fun_olp lp H12 _ _ dm_ud bf fd Hs Hf) in Hev.
      remember (Internal OLP.f_unload_deactivated_objects) as fd' eqn:Efd.
      destruct Hev as [mm ff va tt ee lea leb mm1 mm2 oo vv mm3 Hfe Hx Hor Hfr | ];
        [ injection Efd as Eff; subst ff | discriminate Efd ].
      destruct Hfe as [_ _ _ Hav Hb].
      cbn [fn_vars OLP.f_unload_deactivated_objects] in Hav.
      inversion Hav as [ | e0 m0 id0 ty0 vs0 m1 b1 m2 e2 Hal Hrest ]; subst.
      inversion Hrest; subst.
      change (sizeof G (tarray tuchar 4)) with 4 in Hal.
      destruct (Hfresh _ _ _ HP Hal) as (Hple & Hn1).
      match type of Hal with Mem.alloc _ 0 4 = (?mx, _) => rename mx into ma end.
      assert (Hn0 : ObjPhase.noref b1 mm) by exact (ObjPhase.noref_alloc _ _ _ _ _ Hal Hn1).
      assert (HP1 : P ma).
      { apply (Hblind b1 _ _ Hple HP Hn0).
        apply (Mem.unchanged_on_implies (fun _ _ => True)); [ | intros; exact I ].
        exact (Mem.alloc_unchanged_on _ _ _ _ _ _ Hal). }
      (* the whole call keeps b1 unreferenced; the free keeps contents *)
      pose proof (Hnoref b1 Hple bf fd mm va tt mm3 vv Hs Hf Hn0 Hev0) as Hn'.
      rewrite ud_shape in Hx.
      apply seq_inv in Hx as [(t1 & le1 & m3 & t2 & X1 & X2) | (X1 & Xn)]; [ | kill_abn ].
      apply set_inv in X1 as (iv & Eiv & -> & -> & _). apply ev_const in Eiv. subst iv.
      set (e := PTree.set OLP._filler (b1, tarray tuchar 4) empty_env) in *.
      apply seq_inv in X2 as [(t3 & le3 & m4 & t4 & X3 & X4) | (X3 & Xn)].
      2: { exfalso. apply Xn. refine (proj2 (loop_ud e ltac:(unfold e; envtac) ltac:(unfold e; envtac) ltac:(unfold e; envtac) _ _ _ _ _ _ X3 _)).
           split; [ exact HP1 | exists 0%nat; split; [ apply PTree.gss | lia ] ]. }
      destruct (loop_ud e ltac:(unfold e; envtac) ltac:(unfold e; envtac) ltac:(unfold e; envtac) _ _ _ _ _ _ X3) as (HP4 & _).
      { split; [ exact HP1 | exists 0%nat; split; [ apply PTree.gss | lia ] ]. }
      destruct (tail_ud e _ _ _ _ _ _ HP4 ltac:(unfold e; envtac) X4) as (HP5 & _).
      change (blocks_of_env G e) with [(b1, 0, 4)] in Hfr.
      apply ObjPhase.free_list_one in Hfr.
      apply (Hblind b1 _ _ Hple HP5 (noref_free _ _ _ _ _ _ Hfr Hn')).
      apply (Mem.free_unchanged_on _ _ _ _ _ _ Hfr). intros i _ N. exact (N eq_refl).
    Qed.
  End Outer.
End Real.
