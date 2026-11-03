(* kept: groundwork for BhvStep's Hobj_unload row (the respawn bits and
   the two unload loops); consumed once Pobj's per-slot keep lands. *)
(* OBJECTS -- unload_deactivated_objects (object_list_processor.c:379-423,
   587-600), run by its real bodies.
     - resp_walk: set_object_respawn_info_bits(obj, bits) on slot k does
       nothing, or ORs into the one cell respawnInfo names: a Mint32 for
       respawnInfoType 1, a Mint16unsigned for type 2, an int value.
     - inlist_ok: unload_deactivated_objects_in_list(&gObjectListArray[i]),
       its while loop walked over the real ring.  Over any world W that
       decodes the rings and is kept by (a) the gCurrentObject store, (b) a
       respawn call on an inactive slot, (c) an unload call on an inactive
       slot k of ring i (which becomes ring i minus k), W is kept.  The walk
       reads k's next BEFORE the unload, so the loop invariant is a split
       l1 ++ l2 of ring i with obj = the head of l2.  "inactive" is the
       real test: activeFlags & ACTIVE_FLAG_ACTIVE != ACTIVE_FLAG_ACTIVE.
   Still open: the outer loop over sObjectListUpdateOrder (ObjLoop's NT
   template) and the per-slot keep of Pobj that instantiates W. *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia Bool.
From compcert Require Import Coqlib Maps AST Integers Floats Values Memory
  Globalenvs Ctypes Cop Clight ClightBigstep Clightdefs Events Errors.
From compcert Require Linking.
From SM64.Generated Require object_list_processor.
From SM64.Proofs Require Import SymbolicLinking LinkedTwelve RealFrameLinked.
From SM64.Proofs.WMotRRequiresA Require Import ObjWorld ObjRing ObjAlloc.
From SM64.Proofs.WMotRRequiresA Require RenderAnim ObjLoop.

Import ListNotations.
Local Open Scope Z_scope.
Local Transparent Archi.ptr64.

Module RA := RenderAnim.
Module OLP := SM64.Generated.object_list_processor.

Section RESP.
  Variable ge : genv.
  Hypothesis Hco : forall id co, (prog_comp_env OLP.prog) ! id = Some co -> (genv_cenv ge) ! id = Some co.
  Variable pool : block.
  Notation xs := (exec_stmt function_entry2 ge empty_env).

  Lemma fo_rtype : FO ge OLP._Object OLP._respawnInfoType O_RTYPE.
  Proof. unfold FO. apply (RA.fo_ok_lift (prog_comp_env OLP.prog)); [ vm_compute; reflexivity | exact Hco ]. Qed.
  Lemma fo_rinfo : FO ge OLP._Object OLP._respawnInfo O_RINFO.
  Proof. unfold FO. apply (RA.fo_ok_lift (prog_comp_env OLP.prog)); [ vm_compute; reflexivity | exact Hco ]. Qed.

  (* *p = (cast) (t | (bits << 8)), p a temp: one int store through p *)
  Lemma rmw_store : forall le m p ty tmp e2 t le' m' out ch,
    access_mode ty = By_value ch ->
    xs le m (Sassign (Ederef (Etempvar p (tptr ty)) ty) e2) t le' m' out ->
    (forall v, eval_expr ge empty_env le m e2 v -> forall v', sem_cast v (typeof e2) ty m = Some v' -> exists i, v' = Vint i) ->
    le ! p = Some tmp ->
    exists b o i, tmp = Vptr b o /\ Mem.store ch m b (Ptrofs.unsigned o) (Vint i) = Some m' /\ le' = le /\ out = Out_normal.
  Proof.
    intros le m p ty tmp e2 t le' m' out ch Ham H Hint Hp.
    apply RA.assign_inv in H as (b & o & bf & v2 & v & Hlv & Ev & Hc & Has & -> & ->).
    inv Hlv; match goal with Ht : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ => apply RA.ev_temp in Ht; rewrite Hp in Ht; injection Ht as -> end.
    cbn [typeof] in Hc. destruct (Hint _ Ev _ Hc) as (i & ->).
    exists b, o, i. split; [ reflexivity | split; [ | auto ] ].
    exact (RA.store_by_value ge ty m b o Full (Vint i) m' ch Ham eq_refl Has).
  Qed.

  Lemma brk_case : forall A R le m t le' m' out,
    ObjLoop.plain A = true -> ObjLoop.plain R = true ->
    xs le m (Ssequence A (Ssequence R Sbreak)) t le' m' out ->
    exists le1 m1 t1 t2, xs le m A t1 le1 m1 Out_normal /\ xs le1 m1 R t2 le' m' Out_normal /\ out = Out_break.
  Proof.
    intros A R le m t le' m' out PA PR H.
    apply RA.seq_inv in H as [(t1 & le1 & m1 & t2 & H1 & H2) | (H1 & Hn)];
      [ | exfalso; exact (Hn (ObjLoop.plain_out _ _ _ _ _ _ _ _ _ H1 PA)) ].
    apply RA.seq_inv in H2 as [(t3 & le3 & m3 & t4 & H3 & H4) | (H3 & Hn)];
      [ | exfalso; exact (Hn (ObjLoop.plain_out _ _ _ _ _ _ _ _ _ H3 PR)) ].
    inv H4. exists le1, m1, t1, t3. auto.
  Qed.

  Lemma brk_first : forall A R rest le m t le' m' out,
    ObjLoop.plain A = true -> ObjLoop.plain R = true ->
    xs le m (Ssequence (Ssequence A (Ssequence R Sbreak)) rest) t le' m' out ->
    exists le1 m1 t1 t2, xs le m A t1 le1 m1 Out_normal /\ xs le1 m1 R t2 le' m' Out_normal.
  Proof.
    intros A R rest le m t le' m' out PA PR H.
    apply RA.seq_inv in H as [(t1 & le1 & m1 & t2 & H1 & H2) | (H1 & Hn)].
    - destruct (brk_case _ _ _ _ _ _ _ _ PA PR H1) as (_ & _ & _ & _ & _ & _ & E). discriminate E.
    - destruct (brk_case _ _ _ _ _ _ _ _ PA PR H1) as (le2 & m2 & u1 & u2 & H2 & H3 & _). exists le2, m2, u1, u2. exact (conj H2 H3).
  Qed.

  Lemma or_int : forall v1 v2 ty1 m v, (ty1 = tuint \/ ty1 = tushort) ->
    sem_binary_operation ge Oor v1 ty1 v2 tint m = Some v -> exists i, v = Vint i.
  Proof.
    intros v1 v2 ty1 m v Ht H. destruct Ht as [-> | ->];
    destruct v1, v2; cbn in H; try discriminate H; injection H as <-; eauto.
  Qed.

  Theorem resp_walk : forall m k bits t m' vr, 0 <= k < NSLOT ->
    eval_funcall function_entry2 ge m (Internal OLP.f_set_object_respawn_info_bits)
      [slot_v pool k; Vint bits] t m' vr ->
    m' = m
    \/ exists tt b o ch i, Mem.load Mint16signed m pool (k * OSZ + O_RTYPE) = Some (Vint tt)
         /\ ((Int.unsigned tt = 1 /\ ch = Mint32) \/ (Int.unsigned tt = 2 /\ ch = Mint16unsigned))
         /\ Mem.load Mint32 m pool (k * OSZ + O_RINFO) = Some (Vptr b o)
         /\ Mem.store ch m b (Ptrofs.unsigned o) (Vint i) = Some m'.
  Proof.
    intros m k bits t m' vr Hk H.
    apply fcall_inv0 in H as (le & le' & out & Hb & Hx & _); [ | reflexivity ].
    cbn [bind_parameter_temps fn_params OLP.f_set_object_respawn_info_bits] in Hb. injection Hb as <-.
    cbn [fn_body OLP.f_set_object_respawn_info_bits] in Hx.
    apply RA.seq_inv in Hx as [(t1 & le1 & m1 & t2 & X1 & X2) | (X1 & Xn)]; [ | kill_sq0 X1 Xn ].
    apply RA.set_inv in X1 as (v1 & Ev1 & -> & -> & _).
    destruct (RA.ev_fld ge empty_env m _ _ _ _ tshort _ Mint16signed _ fo_rtype eq_refl Ev1) as (b1 & o1 & Hy1 & L1).
    tmp_in Hy1. unfold slot_v in Hy1. injection Hy1 as <- <-.
    cbn [Mem.loadv] in L1. rewrite slot_fld in L1 by (exact Hk || (unfold O_RTYPE, OSZ; lia)).
    inv X2.
    match goal with Ha : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ => apply RA.ev_temp in Ha; rewrite PTree.gss in Ha; injection Ha as <- end.
    pose proof (Mem.load_type _ _ _ _ _ L1) as Ty.
    destruct v1 as [| tt | | | |]; try (cbn in Ty; contradiction);
      try (match goal with Hs : sem_switch_arg _ _ = Some _ |- _ => cbn in Hs; discriminate Hs end).
    match goal with Hs : sem_switch_arg (Vint tt) _ = Some ?n |- _ => cbn in Hs; injection Hs as <- end.
    (* the common prefix of a case: t' = obj->respawnInfo; info = (cast) t' *)
    assert (PRE : forall tA tB (tyB : type) le0 mA t0 le2 m2,
      le0 ! OLP._obj = Some (slot_v pool k) ->
      xs le0 m (Ssequence (Sset tA (Efield (Ederef (Etempvar OLP._obj (tptr (Tstruct OLP._Object noattr))) (Tstruct OLP._Object noattr)) OLP._respawnInfo (tptr tvoid)))
                          (Sset tB (Ecast (Etempvar tA (tptr tvoid)) (tptr tyB)))) t0 le2 m2 Out_normal ->
      mA = m -> exists v, Mem.load Mint32 m pool (k * OSZ + O_RINFO) = Some v /\ le2 ! tB = Some v /\ m2 = m).
    { intros tA tB tyB le0 mA t0 le2 m2 Hob X _.
      apply RA.seq_inv in X as [(u1 & lu1 & mu1 & u2 & Z1 & Z2) | (Z1 & Zn)]; [ | exfalso; exact (Zn eq_refl) ].
      apply RA.set_inv in Z1 as (v5 & Ev5 & -> & -> & _).
      destruct (RA.ev_fld ge empty_env m _ _ _ _ (tptr tvoid) _ Mint32 _ fo_rinfo eq_refl Ev5) as (b5 & o5 & Hy5 & L5).
      rewrite Hob in Hy5. unfold slot_v in Hy5. injection Hy5 as <- <-.
      cbn [Mem.loadv] in L5. rewrite slot_fld in L5 by (exact Hk || (unfold O_RINFO, OSZ; lia)).
      apply RA.set_inv in Z2 as (v6 & Ev6 & -> & -> & _).
      apply RA.ev_cast in Ev6 as (w6 & Ew6 & C6). apply RA.ev_temp in Ew6. rewrite PTree.gss in Ew6. injection Ew6 as <-.
      cbn [typeof] in C6. apply RA.cast_ptr_id in C6. subst v6.
      exists v5. split; [ exact L5 | split; [ apply PTree.gss | reflexivity ] ]. }
    destruct (zeq (Int.unsigned tt) 1) as [E1 | N1]; [ | destruct (zeq (Int.unsigned tt) 2) as [E2 | N2] ].
    - (* type 1 *)
      match goal with Hz : exec_stmt _ _ _ _ _ (seq_of_labeled_statement _) _ _ _ _ |- _ => rewrite E1 in Hz; cbn in Hz end.
      match goal with Hz : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
        pose proof (fun PA PR => brk_first _ _ _ _ _ _ _ _ _ PA PR Hz) as BF end;
      specialize (BF eq_refl eq_refl); destruct BF as (le2 & m2 & u1 & u2 & Z1 & Z2).
      match type of Z1 with exec_stmt _ _ _ ?L _ _ _ _ _ _ =>
        assert (Hob : L ! OLP._obj = Some (slot_v pool k)) by (rewrite PTree.gso by RA.neq; rewrite PTree.gso by RA.neq; apply PTree.gss) end.
      destruct (PRE _ _ tuint _ m _ _ _ Hob Z1 eq_refl) as (v5 & L5 & H5 & ->).
      apply RA.seq_inv in Z2 as [(u3 & lu3 & mu3 & u4 & Z3 & Z4) | (Z3 & Zn)]; [ | exfalso; exact (Zn eq_refl) ].
      apply RA.set_inv in Z3 as (v9 & _ & -> & -> & _).
      destruct (rmw_store _ _ _ tuint v5 _ _ _ _ _ Mint32 eq_refl Z4) as (b & o & i & -> & St & _ & _).
      { intros v Ev v' Hc. apply RA.ev_binop in Ev as (x1 & x2 & _ & _ & Hb').
        destruct (or_int _ _ _ _ _ (or_introl eq_refl) Hb') as (j & ->). cbn in Hc. injection Hc as <-. eauto. }
      { rewrite PTree.gso by RA.neq. exact H5. }
      right. exists tt, b, o, Mint32, i. split; [ exact L1 | split; [ left; auto | split; [ exact L5 | exact St ] ] ].
    - (* type 2 *)
      match goal with Hz : exec_stmt _ _ _ _ _ (seq_of_labeled_statement _) _ _ _ _ |- _ => rewrite E2 in Hz; cbn in Hz end.
      match goal with Hz : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
        pose proof (fun PA PR => brk_first _ _ _ _ _ _ _ _ _ PA PR Hz) as BF end;
      specialize (BF eq_refl eq_refl); destruct BF as (le2 & m2 & u1 & u2 & Z1 & Z2).
      match type of Z1 with exec_stmt _ _ _ ?L _ _ _ _ _ _ =>
        assert (Hob : L ! OLP._obj = Some (slot_v pool k)) by (rewrite PTree.gso by RA.neq; rewrite PTree.gso by RA.neq; apply PTree.gss) end.
      destruct (PRE _ _ tushort _ m _ _ _ Hob Z1 eq_refl) as (v5 & L5 & H5 & ->).
      apply RA.seq_inv in Z2 as [(u3 & lu3 & mu3 & u4 & Z3 & Z4) | (Z3 & Zn)]; [ | exfalso; exact (Zn eq_refl) ].
      apply RA.set_inv in Z3 as (v9 & _ & -> & -> & _).
      destruct (rmw_store _ _ _ tushort v5 _ _ _ _ _ Mint16unsigned eq_refl Z4) as (b & o & i & -> & St & _ & _).
      { intros v Ev v' Hc. apply RA.ev_binop in Ev as (x1 & x2 & _ & _ & Hb').
        destruct (or_int _ _ _ _ _ (or_intror eq_refl) Hb') as (j & ->). cbn in Hc. injection Hc as <-. eauto. }
      { rewrite PTree.gso by RA.neq. exact H5. }
      right. exists tt, b, o, Mint16unsigned, i. split; [ exact L1 | split; [ right; auto | split; [ exact L5 | exact St ] ] ].
    - (* no case *)
      left.
      match goal with Hz : exec_stmt _ _ _ _ _ (seq_of_labeled_statement (select_switch _ ?LS)) _ _ _ _ |- _ =>
        replace (select_switch (Int.unsigned tt) LS) with LSnil in Hz
          by (unfold select_switch; cbn [select_switch_case];
              destruct (zeq 1 (Int.unsigned tt)); [ lia | ];
              destruct (zeq 2 (Int.unsigned tt)); [ lia | ]; reflexivity);
        cbn [seq_of_labeled_statement] in Hz; inv Hz end.
      reflexivity.
  Qed.
End RESP.

Lemma chain_mid : forall pool m E l1 prev k l2, chain pool m E prev (l1 ++ k :: l2) ->
  0 <= k < NSLOT /\ ld32 m pool (k * OSZ + O_NEXT) = Some (next_of pool E l2).
Proof.
  intros pool m E l1. induction l1 as [|a l1 IH]; intros prev k l2 H; cbn [app chain] in H.
  - destruct H as (Hk & _ & Ln & _). exact (conj Hk Ln).
  - exact (IH _ _ _ (proj2 (proj2 (proj2 H)))).
Qed.

(* the in_list walk: a world W over the rings, kept by the gCurrentObject
   store, the respawn call and the unload call (each on an inactive slot) *)
Section INL.
  Variable ge : genv.
  Hypothesis Hco : forall id co, (prog_comp_env OLP.prog) ! id = Some co -> (genv_cenv ge) ! id = Some co.
  Variables pool la gco : block.
  Hypothesis Hpl : pool <> la.
  Hypothesis Hgco : Genv.find_symbol ge OLP._gCurrentObject = Some gco.
  Variable i : nat.
  Hypothesis Hi : (i < NLIST)%nat.
  Notation xs := (exec_stmt function_entry2 ge empty_env).
  Ltac lk := repeat first [ rewrite PTree.gss | rewrite PTree.gso by neq0 ]; first [ reflexivity | assumption ].

  Definition inactive (m : mem) (k : Z) : Prop :=
    exists a, Mem.load Mint16signed m pool (k * OSZ + O_FLAGS) = Some (Vint a)
      /\ Int.eq (Int.and a Int.one) Int.one = false.

  Variable W : mem -> list (list Z) -> Prop.
  Hypothesis Wr : forall m rs, W m rs -> rings m pool la = Some rs.
  Hypothesis Wg : forall m rs k m', W m rs -> In k (nth i rs []) ->
    Mem.store Mint32 m gco 0 (slot_v pool k) = Some m' -> W m' rs.
  Hypothesis Wresp : forall b fd, Genv.find_symbol ge OLP._set_object_respawn_info_bits = Some b ->
    Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd ->
    forall m rs l1 k l2 t m' vr, W m rs -> nth i rs [] = l1 ++ k :: l2 -> inactive m k ->
      Mem.load Mint32 m gco 0 = Some (slot_v pool k) ->
      eval_funcall function_entry2 ge m fd [slot_v pool k; Vint (Int.repr 255)] t m' vr ->
      W m' rs /\ Mem.load Mint32 m' gco 0 = Some (slot_v pool k) /\ inactive m' k.
  Hypothesis Wunl : forall b fd, Genv.find_symbol ge OLP._unload_object = Some b ->
    Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd ->
    forall m rs l1 k l2 t m' vr, W m rs -> nth i rs [] = l1 ++ k :: l2 -> inactive m k ->
      eval_funcall function_entry2 ge m fd [slot_v pool k] t m' vr -> W m' (upd rs i (l1 ++ l2)).

  Definition HV : val := Vptr la (Ptrofs.repr (hoff i)).
  Definition Kin (le : temp_env) (m : mem) : Prop :=
    exists rs l1 l2, W m rs /\ nth i rs [] = l1 ++ l2
      /\ le ! OLP._objList = Some HV /\ le ! OLP._obj = Some (next_of pool HV l2).

  Lemma fo_onx : FO ge OLP._ObjectNode OLP._next O_NEXT.
  Proof. unfold FO. apply (RA.fo_ok_lift (prog_comp_env OLP.prog)); [ vm_compute; reflexivity | exact Hco ]. Qed.
  Lemma fo_afl : FO ge OLP._Object OLP._activeFlags O_FLAGS.
  Proof. unfold FO. apply (RA.fo_ok_lift (prog_comp_env OLP.prog)); [ vm_compute; reflexivity | exact Hco ]. Qed.

  Lemma rd_gco : forall le m x v le' m' t out,
    Mem.load Mint32 m gco 0 = Some v ->
    xs le m (Sset x (Evar OLP._gCurrentObject (tptr (Tstruct OLP._Object noattr)))) t le' m' out ->
    le' = PTree.set x v le /\ m' = m /\ out = Out_normal.
  Proof.
    intros le m x v le' m' t out L H. apply RA.set_inv in H as (w & Ew & -> & -> & ->).
    destruct (RA.ev_gvar ge empty_env m _ _ (tptr (Tstruct OLP._Object noattr)) _ Mint32 (PTree.gempty _ _) eq_refl Ew) as (b & Hs & Lw).
    rewrite Hgco in Hs. injection Hs as <-. cbn [Mem.loadv] in Lw. rewrite Ptrofs.unsigned_zero, L in Lw.
    injection Lw as <-. auto.
  Qed.

  Lemma call0 : forall le m id tyargs args t le' m' out,
    xs le m (Scall None (Evar id (Tfunction tyargs tvoid cc_default)) args) t le' m' out ->
    exists b fd vargs vr, Genv.find_symbol ge id = Some b /\ Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd
      /\ eval_exprlist ge empty_env le m args tyargs vargs
      /\ eval_funcall function_entry2 ge m fd vargs t m' vr /\ le' = le /\ out = Out_normal.
  Proof.
    intros le m id tyargs args t le' m' out H.
    apply RA.call_inv in H as (ta & tr & cc & vf & va & fd & vr & Cf & Ef & El & Ff & _ & Ex & -> & ->).
    cbn in Cf. injection Cf as <- <- <-.
    destruct (RA.ev_fun ge empty_env m _ _ (Tfunction tyargs tvoid cc_default) _ (PTree.gempty _ _) eq_refl Ef) as (b & Hs & ->).
    exists b, fd, va, vr. auto 10.
  Qed.

  Lemma it_in : forall le m t le1 m1 out,
    xs le m (Ssequence (Sifthenelse (Ebinop One (Etempvar OLP._objList ObjLoop.tnode) (Etempvar OLP._obj ObjLoop.tnode) tint) Sskip Sbreak)
                 (match fn_body OLP.f_unload_deactivated_objects_in_list with
                  | Ssequence _ (Ssequence (Sloop (Ssequence _ b) _) _) => b | _ => Sskip end)) t le1 m1 out ->
    Kin le m -> (exists rs, W m1 rs) /\ (out = Out_break \/ (out = Out_normal /\ Kin le1 m1)).
  Proof.
    intros le m t le1 m1 out H (rs & l1 & l2 & HW & El & Hol & Hob).
    apply RA.seq_inv in H as [(t1 & le2 & m2 & t2 & C1 & B) | (C1 & Hn)].
    2: { apply RA.if_inv in C1 as (v & b & _ & _ & C1). destruct b.
         - apply RA.skip_inv in C1 as (_ & _ & E). exfalso; exact (Hn E).
         - inv C1. split; [ exists rs; exact HW | left; reflexivity ]. }
    apply RA.if_inv in C1 as (v & b & Ev & Bv & C1).
    destruct b; [ | inv C1 ].
    apply RA.skip_inv in C1 as (-> & -> & _).
    destruct l2 as [| k l2].
    { exfalso. apply RA.ev_binop in Ev as (x1 & x2 & X1 & X2 & X3).
      apply RA.ev_temp in X1. apply RA.ev_temp in X2. rewrite Hol in X1. rewrite Hob in X2. cbn [next_of] in X2.
      injection X1 as <-. injection X2 as <-. cbn [typeof] in X3.
      apply ObjLoop.cmp_self in X3. subst v. cbn in Bv. discriminate Bv. }
    pose proof (proj2 (proj1 (rings_iff pool m la rs Hpl) (Wr _ _ HW)) i Hi) as (_ & Hc & _).
    rewrite El in Hc. destruct (chain_mid _ _ _ _ _ _ _ Hc) as (Hk & _).
    assert (Hin : In k (nth i rs [])) by (rewrite El; apply in_or_app; right; left; reflexivity).
    cbn [fn_body OLP.f_unload_deactivated_objects_in_list] in B.
    (* gCurrentObject = obj *)
    apply RA.seq_inv in B as [(t3 & le3 & m3 & t4 & B1 & B2) | (B1 & Hn)]; [ | kill_sq0 B1 Hn ].
    apply RA.assign_inv in B1 as (b0 & o0 & bf0 & v2 & v0 & Lv & Ev2 & Hc0 & As & -> & _).
    destruct (RA.lv_gvar ge empty_env m le _ _ _ _ _ (PTree.gempty _ _) Lv) as (Hs0 & -> & ->).
    rewrite Hgco in Hs0. injection Hs0 as <-.
    apply RA.ev_cast in Ev2 as (w & Ew & C). apply RA.ev_temp in Ew. rewrite Hob in Ew. injection Ew as <-.
    cbn [typeof] in C. apply RA.cast_ptr_id in C. subst v2.
    cbn [typeof] in Hc0. apply RA.cast_ptr_id in Hc0. subst v0.
    pose proof (RA.store_by_value ge (tptr (Tstruct OLP._Object noattr)) m gco Ptrofs.zero Full _ m3 Mint32 eq_refl eq_refl As) as St.
    rewrite Ptrofs.unsigned_zero in St.
    pose proof (Wg _ _ _ _ HW Hin St) as HW3.
    assert (Lg : Mem.load Mint32 m3 gco 0 = Some (slot_v pool k))
      by (rewrite (Mem.load_store_same _ _ _ _ _ _ St); reflexivity).
    (* obj = obj->next *)
    apply RA.seq_inv in B2 as [(t5 & le5 & m5 & t6 & B3 & B4) | (B3 & Hn)]; [ | kill_sq0 B3 Hn ].
    apply RA.set_inv in B3 as (nv & Env & -> & -> & _).
    destruct (RA.ev_fld ge empty_env m3 _ OLP._obj OLP._ObjectNode OLP._next ObjLoop.tnode nv Mint32 O_NEXT fo_onx eq_refl Env)
      as (b5 & o5 & Hy & Ln).
    rewrite Hob in Hy. cbn [next_of] in Hy. unfold sv, slot_v in Hy. injection Hy as <- <-.
    cbn [Mem.loadv] in Ln. rewrite slot_fld in Ln by (exact Hk || (unfold O_NEXT, OSZ; lia)).
    pose proof (proj2 (proj1 (rings_iff pool m3 la rs Hpl) (Wr _ _ HW3)) i Hi) as (_ & Hc3 & _).
    rewrite El in Hc3. destruct (chain_mid _ _ _ _ _ _ _ Hc3) as (_ & Ln3).
    unfold ld32 in Ln3. rewrite CM.load_eq, Ln in Ln3. injection Ln3 as ->.
    (* t'1 = gCurrentObject; t'2 = t'1->activeFlags *)
    apply RA.seq_inv in B4 as [(t7 & le7 & m7 & t8 & B5 & B6) | (B5 & Hn)]; [ | kill_sq0 B5 Hn ].
    destruct (rd_gco _ _ _ _ _ _ _ _ Lg B5) as (-> & -> & _).
    apply RA.seq_inv in B6 as [(t9 & le9 & m9 & t10 & B7 & B8) | (B7 & Hn)]; [ | kill_sq0 B7 Hn ].
    apply RA.set_inv in B7 as (fv & Efv & -> & -> & _).
    destruct (RA.ev_fld ge empty_env m3 _ OLP._t'1 OLP._Object OLP._activeFlags tshort fv Mint16signed O_FLAGS fo_afl eq_refl Efv)
      as (b6 & o6 & Hy & Lf).
    rewrite PTree.gss in Hy. unfold slot_v in Hy. injection Hy as <- <-.
    cbn [Mem.loadv] in Lf. rewrite slot_fld in Lf by (exact Hk || (unfold O_FLAGS, OSZ; lia)).
    set (le9 := PTree.set OLP._t'2 fv (PTree.set OLP._t'1 (slot_v pool k) (PTree.set OLP._obj (next_of pool HV l2) le))) in *.
    assert (Kn : forall le' m', W m' rs -> le' ! OLP._objList = Some HV -> le' ! OLP._obj = Some (next_of pool HV l2) ->
                   Kin le' m').
    { intros le' m' HW' Ho1 Ho2. exists rs, (l1 ++ [k]), l2. rewrite <- app_assoc. auto. }
    apply RA.if_inv in B8 as (cv & cb & Ecv & Bcv & B8). destruct cb.
    2: { apply RA.skip_inv in B8 as (-> & -> & ->). split; [ exists rs; exact HW3 | right; split; [ reflexivity | ] ].
         apply Kn; [ exact HW3 | | ]; unfold le9; lk. }
    (* the slot is inactive *)
    assert (Ina : inactive m3 k).
    { pose proof (Mem.load_type _ _ _ _ _ Lf) as Ty.
      apply RA.ev_binop in Ecv as (y1 & y2 & Y1 & Y2 & Y3).
      apply RA.ev_binop in Y1 as (z1 & z2 & Z1 & Z2 & Z3).
      apply RA.ev_temp in Z1. unfold le9 in Z1. rewrite PTree.gss in Z1. injection Z1 as <-.
      apply RA.ev_binop in Z2 as (w1 & w2 & W1 & W2 & W3). apply RA.ev_const in W1. apply RA.ev_const in W2. subst w1 w2.
      assert (Ew : z2 = Vint Int.one) by (vm_compute in W3; injection W3 as <-; reflexivity). subst z2.
      apply RA.ev_binop in Y2 as (q1 & q2 & Q1 & Q2 & Q3). apply RA.ev_const in Q1. apply RA.ev_const in Q2. subst q1 q2.
      assert (Eq : y2 = Vint Int.one) by (vm_compute in Q3; injection Q3 as <-; reflexivity). subst y2.
      destruct fv as [| a | | | |]; try (cbn in Ty; contradiction); try (cbn in Z3; discriminate Z3).
      cbn in Z3. injection Z3 as <-. cbn in Y3. injection Y3 as <-.
      exists a. split; [ exact Lf | ].
      destruct (Int.eq (Int.and a Int.one) Int.one) eqn:E; [ cbn in Bcv; discriminate Bcv | reflexivity ]. }
    (* the respawn branch, then the unload *)
    apply RA.seq_inv in B8 as [(u1 & lu1 & mu1 & u2 & R1 & R2) | (R1 & Hn)]; [ | kill_sq0 R1 Hn ].
    assert (RS : exists le' m', W m' rs /\ Mem.load Mint32 m' gco 0 = Some (slot_v pool k) /\ inactive m' k
                   /\ lu1 = le' /\ mu1 = m' /\ le' ! OLP._objList = Some HV /\ le' ! OLP._obj = Some (next_of pool HV l2)).
    { apply RA.seq_inv in R1 as [(u3 & lu3 & mu3 & u4 & R3 & R4) | (R3 & Hn)]; [ | kill_sq0 R3 Hn ].
      destruct (rd_gco _ _ _ _ _ _ _ _ Lg R3) as (-> & -> & _).
      apply RA.seq_inv in R4 as [(u5 & lu5 & mu5 & u6 & R5 & R6) | (R5 & Hn)]; [ | kill_sq0 R5 Hn ].
      apply RA.set_inv in R5 as (rv & _ & -> & -> & _).
      apply RA.if_inv in R6 as (dv & db & _ & _ & R6). destruct db.
      - apply RA.seq_inv in R6 as [(u7 & lu7 & mu7 & u8 & R7 & R8) | (R7 & Hn)]; [ | kill_sq0 R7 Hn ].
        destruct (rd_gco _ _ _ _ _ _ _ _ Lg R7) as (-> & -> & _).
        destruct (call0 _ _ _ _ _ _ _ _ _ R8) as (b & fd & va & vr & Hs & Hf & Ea & Ex & -> & _).
        inv Ea. match goal with H2 : eval_exprlist _ _ _ _ _ _ _ |- _ => inv H2 end.
        match goal with H3 : eval_exprlist _ _ _ _ _ _ _ |- _ => inv H3 end.
        repeat match goal with
               | Ht : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ => apply RA.ev_temp in Ht; rewrite PTree.gss in Ht; injection Ht as <-
               | Ht : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ => apply RA.ev_const in Ht; subst
               end.
        repeat match goal with Hq : sem_cast _ _ _ _ = Some _ |- _ => cbn [typeof] in Hq end.
        match goal with Hq : sem_cast (slot_v pool k) _ _ _ = Some _ |- _ => apply RA.cast_ptr_id in Hq; subst end.
        match goal with Hq : sem_cast (Vint _) _ _ _ = Some _ |- _ => vm_compute in Hq; injection Hq as <- end.
        destruct (Wresp b fd Hs Hf m3 rs l1 k l2 _ _ vr HW3 El Ina Lg Ex) as (HW' & Lg' & Ina').
        do 2 eexists. split; [ exact HW' | split; [ exact Lg' | split; [ exact Ina' | split; [ reflexivity | split; [ reflexivity | ] ] ] ] ].
        unfold le9. split; lk.
      - apply RA.skip_inv in R6 as (-> & -> & _).
        do 2 eexists. split; [ exact HW3 | split; [ exact Lg | split; [ exact Ina | split; [ reflexivity | split; [ reflexivity | ] ] ] ] ].
        unfold le9. split; lk. }
    destruct RS as (le' & m' & HW' & Lg' & Ina' & -> & -> & Ho1 & Ho2).
    apply RA.seq_inv in R2 as [(u3 & lu3 & mu3 & u4 & R3 & R4) | (R3 & Hn)]; [ | kill_sq0 R3 Hn ].
    destruct (rd_gco _ _ _ _ _ _ _ _ Lg' R3) as (-> & -> & _).
    destruct (call0 _ _ _ _ _ _ _ _ _ R4) as (b & fd & va & vr & Hs & Hf & Ea & Ex & -> & ->).
    inv Ea. match goal with H2 : eval_exprlist _ _ _ _ _ _ _ |- _ => inv H2 end.
    match goal with Ht : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ => apply RA.ev_temp in Ht; rewrite PTree.gss in Ht; injection Ht as <- end.
    match goal with Hq : sem_cast _ _ _ _ = Some _ |- _ => cbn [typeof] in Hq; apply RA.cast_ptr_id in Hq; subst end.
    pose proof (Wunl b fd Hs Hf m' rs l1 k l2 _ _ vr HW' El Ina' Ex) as HW1.
    split; [ eexists; exact HW1 | right; split; [ reflexivity | ] ].
    assert (Hlen : List.length rs = NLIST) by exact (proj1 (proj1 (rings_iff pool m3 la rs Hpl) (Wr _ _ HW3))).
    exists (upd rs i (l1 ++ l2)), l1, l2. split; [ exact HW1 | split; [ apply upd_nth_eq; rewrite Hlen; exact Hi | ] ].
    split; rewrite PTree.gso by RA.neq; assumption.
  Qed.
  Definition il_c : statement :=
    Sifthenelse (Ebinop One (Etempvar OLP._objList ObjLoop.tnode) (Etempvar OLP._obj ObjLoop.tnode) tint) Sskip Sbreak.
  Definition il_b : statement :=
    match fn_body OLP.f_unload_deactivated_objects_in_list with
    | Ssequence _ (Ssequence (Sloop (Ssequence _ b) _) _) => b | _ => Sskip end.
  Lemma il_shape : fn_body OLP.f_unload_deactivated_objects_in_list =
    Ssequence (Sset OLP._obj (Efield (Ederef (Etempvar OLP._objList ObjLoop.tnode) (Tstruct OLP._ObjectNode noattr)) OLP._next ObjLoop.tnode))
      (Ssequence (Sloop (Ssequence il_c il_b) Sskip) (Sreturn (Some (Econst_int (Int.repr 0) tint)))).
  Proof. reflexivity. Qed.

  Lemma loop_in : forall le m t le' m' out,
    xs le m (Sloop (Ssequence il_c il_b) Sskip) t le' m' out ->
    Kin le m -> (exists rs, W m' rs) /\ out = Out_normal.
  Proof.
    intros le m t le' m' out H.
    remember (Sloop (Ssequence il_c il_b) Sskip) as S eqn:ES.
    remember empty_env as e0 eqn:Ee.
    revert ES Ee. induction H; intros ES Ee HK; try discriminate ES; injection ES as E1 E2; subst.
    - destruct (it_in _ _ _ _ _ _ H HK) as (HW & [-> | (-> & _)]); inv H0. split; [ exact HW | reflexivity ].
    - apply RA.skip_inv in H1 as (_ & _ & ->). inv H2.
    - destruct (it_in _ _ _ _ _ _ H HK) as (HW & [-> | (-> & HK1)]); [ inv H0 | ].
      apply RA.skip_inv in H1 as (-> & -> & _).
      eapply IHexec_stmt3; eauto.
  Qed.

  (* unload_deactivated_objects_in_list(&gObjectListArray[i]) keeps W *)
  Theorem inlist_ok : forall m rs t m' vr, W m rs ->
    eval_funcall function_entry2 ge m (Internal OLP.f_unload_deactivated_objects_in_list) [HV] t m' vr ->
    exists rs', W m' rs'.
  Proof.
    intros m rs t m' vr HW H.
    apply fcall_inv0 in H as (le & le' & out & Hb & Hx & _); [ | reflexivity ].
    cbn [bind_parameter_temps fn_params OLP.f_unload_deactivated_objects_in_list] in Hb. injection Hb as <-.
    rewrite il_shape in Hx.
    apply RA.seq_inv in Hx as [(t1 & le1 & m1 & t2 & X1 & X2) | (X1 & Xn)]; [ | kill_sq0 X1 Xn ].
    apply RA.set_inv in X1 as (v1 & Ev1 & -> & -> & _).
    destruct (RA.ev_fld ge empty_env m _ OLP._objList OLP._ObjectNode OLP._next ObjLoop.tnode v1 Mint32 O_NEXT fo_onx eq_refl Ev1)
      as (b1 & o1 & Hy & L1).
    rewrite PTree.gss in Hy. unfold HV in Hy. injection Hy as <- <-.
    cbn [Mem.loadv] in L1.
    rewrite uadd0 in L1 by (unfold hoff, O_NEXT, NODESZ, NLIST in *; rewrite ?maxu32; lia).
    pose proof (proj2 (proj1 (rings_iff pool m la rs Hpl) (Wr _ _ HW)) i Hi) as (Ln & _).
    unfold ld32 in Ln. rewrite CM.load_eq, L1 in Ln. injection Ln as ->.
    apply RA.seq_inv in X2 as [(t3 & le3 & m3 & t4 & X3 & X4) | (X3 & Xn)].
    - destruct (loop_in _ _ _ _ _ _ X3) as ((rs' & HW') & _).
      { exists rs, [], (nth i rs []). split; [ exact HW | split; [ reflexivity | ] ].
        split; [ rewrite PTree.gso by neq0; apply PTree.gss | apply PTree.gss ]. }
      apply RA.ret_inv in X4 as (-> & _). exists rs'. exact HW'.
    - exfalso. apply Xn. refine (proj2 (loop_in _ _ _ _ _ _ X3 _)).
      exists rs, [], (nth i rs []). split; [ exact HW | split; [ reflexivity | ] ].
      split; [ rewrite PTree.gso by neq0; apply PTree.gss | apply PTree.gss ].
  Qed.
End INL.
