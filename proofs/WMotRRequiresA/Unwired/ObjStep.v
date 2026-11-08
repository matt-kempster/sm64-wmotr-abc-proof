(* ======================================================================= *)
(* ObjStep.v -- the objects step's REST ROW from the real loop body         *)
(* (GOAL 2 objects, W3, 2026-11-07).                                       *)
(*                                                                         *)
(* ObjStepSplit.step_rest_row (one object's update keeps Pobjl and leaves  *)
(* the object in its ring) for the REAL update_objects_starting_at and     *)
(* update_objects_during_time_stop, whose loop body up to the cursor       *)
(* advance (ObjLoop.loop_pre) is, read off the generated AST (vm):         *)
(*   gCurrentObject = obj;                                    (GCO_ASG)    *)
(*   [time stop: unfrozen = ...; pure temps / branches]                    *)
(*   gCurrentObject->header.gfx.node.flags |= 1 << 5;        (FLG .. OR5)  *)
(*   cur_obj_update();                                        (CALL)       *)
(*   [time stop, frozen: flags &= ~(1 << 5)]                  (FLG .. AND5) *)
(* PROVED here: the gCurrentObject store (UnloadRows.gco_keep), the flag  *)
(* stores (ObjGfl.gfl_pc), the rings across both, and cur_obj_update      *)
(* itself through BhvStep.cou_real with INV := ObjInv.INVk (entry          *)
(* inv_entry, the row keeps ObjRows.rows_k, exit ObjExit.inv_exit), the    *)
(* ghost fact X := "the object is in its ring" (in_ring_tr: the links are  *)
(* off the VM cells, so the ghost's rings are the real memory's).          *)
(* What remains is cou_keeps: the keeps INV_k's dispatch loop reads       *)
(* (ObjRows.ghost_keeps at the ghost, ObjRows.rest_keeps at INV_k) and the *)
(* code around the segment (BhvStep.pre_keep / post_keep at INV_k), per    *)
(* slot k, its start VM state st0, the entry's nextblock and the ring the  *)
(* object runs in -- premises about Pobjl / INV_k memories only.           *)
(* LABELED: HSafeB_scr (the scripts are SafeB), ObjExit's.                 *)
(* ======================================================================= *)

From Coq Require Import ZArith Lia List Bool.
From compcert Require Import Coqlib Integers Floats Values AST Ctypes Cop Clight
  ClightBigstep Clightdefs Memory Maps Globalenvs Events Errors Linking.
From SM64.Generated Require object_list_processor level_update mario behavior_script.
From SM64.Proofs Require Import SymbolicLinking RealFrameLinked LinkedTwelve MWFReal NoAImpliesNoFlyLinked AGates.
From SM64.Proofs Require Interp.CMem.
From SM64.Proofs.WMotRRequiresA Require Import BhvVM.
From SM64.Proofs.WMotRRequiresA Require ObjWorld ObjRing PollKeep ClearKeep BhvStep ObjFamily ObjLoop
  ObjStepSplit UnloadRows RenderAnim RenderKeep FpuFloor HeightFrame ObjSelf.
From SM64.Proofs.WMotRRequiresA.Unwired Require ObjInv ObjExit ObjRows ObjGfl.
Import ListNotations.
Local Open Scope Z_scope.
Local Transparent Archi.ptr64.

Module OW := ObjWorld.
Module OLP := object_list_processor.
Module BS := behavior_script.
Module RA := RenderAnim.
Module PK := PollKeep.
Module CM := SM64.Proofs.Interp.CMem.

(* ---------------------------------------------------------------------- *)
(* 1. Statements that only set temps.                                      *)
(* ---------------------------------------------------------------------- *)
Fixpoint pure (s : statement) : bool :=
  match s with
  | Sskip | Sset _ _ => true
  | Ssequence a b => pure a && pure b
  | Sifthenelse _ a b => pure a && pure b
  | _ => false
  end.

Lemma pure_exec : forall ge e s le m t le' m' out, pure s = true ->
  exec_stmt function_entry2 ge e le m s t le' m' out -> m' = m /\ out = Out_normal.
Proof.
  intros ge e s. induction s; intros le m t le' m' out Hp H; cbn [pure] in Hp; try discriminate Hp.
  - inv H. auto.
  - apply RA.set_inv in H as (_ & _ & _ & -> & ->). auto.
  - apply andb_prop in Hp as (P1 & P2).
    apply RA.seq_inv in H as [(t1 & le1 & m1 & t2 & X1 & X2) | (X1 & Xn)].
    + destruct (IHs1 _ _ _ _ _ _ P1 X1) as (-> & _). exact (IHs2 _ _ _ _ _ _ P2 X2).
    + destruct (IHs1 _ _ _ _ _ _ P1 X1) as (_ & E). exfalso. exact (Xn E).
  - apply andb_prop in Hp as (P1 & P2). inv H.
    match goal with X : exec_stmt _ _ _ _ _ (if ?b then _ else _) _ _ _ _ |- _ =>
      destruct b; [ exact (IHs1 _ _ _ _ _ _ P1 X) | exact (IHs2 _ _ _ _ _ _ P2 X) ] end.
Qed.

(* ---------------------------------------------------------------------- *)
(* 2. The loop bodies, read off the generated AST.                         *)
(* ---------------------------------------------------------------------- *)
Notation pObj := (tptr (Tstruct BS._Object noattr)).

Definition GCO_ASG : statement :=
  Sassign (Evar BS._gCurrentObject pObj)
    (Ecast (Etempvar OLP._firstObj (tptr (Tstruct OLP._ObjectNode noattr))) pObj).

Definition CALL : statement :=
  Scall None (Evar BS._cur_obj_update (Tfunction nil tvoid cc_default)) nil.

Definition FLG (ta tb tc : ident) (rhs : expr) : statement :=
  Ssequence (Sset ta (Evar BS._gCurrentObject pObj))
    (Ssequence (Sset tb (Evar BS._gCurrentObject pObj))
      (Ssequence (Sset tc (BhvStep.GFL tb)) (Sassign (BhvStep.GFL ta) rhs))).

Definition B5 : expr := Ebinop Oshl (Econst_int (Int.repr 1) tint) (Econst_int (Int.repr 5) tint) tint.
Definition OR5 (tc : ident) : expr := Ebinop Oor (Etempvar tc tshort) B5 tint.
Definition AND5 (tc : ident) : expr := Ebinop Oand (Etempvar tc tshort) (Eunop Onotint B5 tint) tint.

Lemma sa_shape : ObjLoop.app_seq (ObjLoop.loop_pre OLP.f_update_objects_starting_at) Sskip
  = Ssequence GCO_ASG (Ssequence (FLG OLP._t'1 OLP._t'2 OLP._t'3 (OR5 OLP._t'3)) (Ssequence CALL Sskip)).
Proof. vm_compute. reflexivity. Qed.

Definition TSL : list statement := ObjLoop.loop_pre OLP.f_update_objects_during_time_stop.

Lemma ts_shape : ObjLoop.app_seq TSL Sskip
  = Ssequence GCO_ASG (Ssequence (nth 1 TSL Sskip) (Ssequence (nth 2 TSL Sskip)
      (Ssequence (Sifthenelse (Etempvar OLP._unfrozen tint)
                   (Ssequence (FLG OLP._t'6 OLP._t'7 OLP._t'8 (OR5 OLP._t'8)) CALL)
                   (FLG OLP._t'3 OLP._t'4 OLP._t'5 (AND5 OLP._t'5))) Sskip))).
Proof. vm_compute. reflexivity. Qed.

Lemma ts_pure : pure (nth 1 TSL Sskip) = true /\ pure (nth 2 TSL Sskip) = true.
Proof. split; vm_compute; reflexivity. Qed.

Lemma dm_bcc : exists gd, (prog_defmap BS.prog) ! BS._gCurBhvCommand = Some gd.
Proof.
  destruct ((prog_defmap BS.prog) ! BS._gCurBhvCommand) as [gd|] eqn:E;
    [ exists gd; reflexivity | vm_compute in E; discriminate E ].
Qed.

Lemma dm_sb : exists gd, (prog_defmap BS.prog) ! BS._gRandomSeed16 = Some gd.
Proof.
  destruct ((prog_defmap BS.prog) ! BS._gRandomSeed16) as [gd|] eqn:E;
    [ exists gd; reflexivity | vm_compute in E; discriminate E ].
Qed.

Lemma dm_cou : (prog_defmap BS.prog) ! BS._cur_obj_update = Some (Gfun (Internal BS.f_cur_obj_update)).
Proof. vm_compute. reflexivity. Qed.

(* ---------------------------------------------------------------------- *)
(* 3. The rings read only the list links (96 / 100) and the list heads.   *)
(* ---------------------------------------------------------------------- *)
Section RL.
  Variables (m m' : mem) (pool hb : block).
  Hypothesis Kp : forall k, 0 <= k < OW.NSLOT ->
    OW.ld32 m' pool (k * OW.OSZ + OW.O_PREV) = OW.ld32 m pool (k * OW.OSZ + OW.O_PREV)
    /\ OW.ld32 m' pool (k * OW.OSZ + OW.O_NEXT) = OW.ld32 m pool (k * OW.OSZ + OW.O_NEXT).
  Hypothesis Kh : forall z, OW.ld32 m' hb z = OW.ld32 m hb z.

  Lemma ring_from_link : forall n ho prev cur,
    OW.ring_from m' pool hb ho prev cur n = OW.ring_from m pool hb ho prev cur n.
  Proof.
    intros n. induction n as [| n IH]; intros ho prev cur; cbn [OW.ring_from]; [ reflexivity | ].
    destruct cur; try reflexivity.
    destruct (eq_block b hb && Z.eqb (Ptrofs.unsigned i) ho); [ rewrite Kh; reflexivity | ].
    destruct (eq_block b pool); [ | reflexivity ].
    destruct (OW.slot_of (Ptrofs.unsigned i)) eqn:E; [ | reflexivity ].
    destruct (PK.slot_of_eq _ _ E) as (Eo & Hz). rewrite Eo.
    destruct (Kp z Hz) as (K1 & K2). rewrite K1, K2.
    destruct (OW.ld32 m pool (z * OW.OSZ + OW.O_PREV)); [ | reflexivity ].
    destruct (OW.ld32 m pool (z * OW.OSZ + OW.O_NEXT)); [ | reflexivity ].
    destruct (OW.veqb v prev); [ | reflexivity ].
    rewrite IH. reflexivity.
  Qed.
End RL.

Lemma rings_link : forall m m' pool la,
  (forall k, 0 <= k < OW.NSLOT ->
    OW.ld32 m' pool (k * OW.OSZ + OW.O_PREV) = OW.ld32 m pool (k * OW.OSZ + OW.O_PREV)
    /\ OW.ld32 m' pool (k * OW.OSZ + OW.O_NEXT) = OW.ld32 m pool (k * OW.OSZ + OW.O_NEXT)) ->
  (forall z, OW.ld32 m' la z = OW.ld32 m la z) ->
  OW.rings m' pool la = OW.rings m pool la.
Proof.
  intros m m' pool la Kp Kl. unfold OW.rings.
  assert (E : map (OW.ring_i m' pool la) (seq 0 OW.NLIST) = map (OW.ring_i m pool la) (seq 0 OW.NLIST)).
  { apply map_ext. intros i. unfold OW.ring_i. rewrite Kl.
    destruct (OW.ld32 m la (Z.of_nat i * OW.NODESZ + OW.O_NEXT)); [ | reflexivity ].
    apply ring_from_link; assumption. }
  rewrite E. reflexivity.
Qed.

(* ring membership carries to a memory with the same rings and an object world *)
Lemma in_ring_tr : forall (G : genv) bm ls g m' hd v,
  ObjLoop.in_ring_l G bm ls g hd v -> OW.obj_w G bm m' ->
  (forall pool la, Genv.find_symbol G OLP._gObjectPool = Some pool ->
     Genv.find_symbol G OLP._gObjectListArray = Some la -> OW.rings m' pool la = OW.rings g pool la) ->
  ObjLoop.in_ring_l G bm ls m' hd v.
Proof.
  intros G bm ls g m' hd v ((pool & la & rs & i & k & (Sp & Sl & (fl & gol & gmo & sdp & gdi & fs & S3 & S4 & S5 & S6 & S7 & C))
                                & Hi & Ehd & Hk & Ev) & Hd) How R.
  destruct (ObjLoop.ow_at_of G bm m' How) as (pool' & la' & rs' & (Sp' & Sl' & (fl' & gol' & gmo' & sdp' & gdi' & fs' & S3' & S4' & S5' & S6' & S7' & C'))).
  rewrite Sp in Sp'. injection Sp' as <-. rewrite Sl in Sl'. injection Sl' as <-.
  pose proof (OW.ow_rings _ _ _ _ _ _ _ _ _ _ _ _ C) as R1. pose proof (OW.ow_rings _ _ _ _ _ _ _ _ _ _ _ _ C') as R2.
  rewrite (R pool la Sp Sl), R1 in R2. injection R2 as <-.
  split; [ | exact Hd ].
  exists pool, la, rs, i, k. split; [ | exact (conj Hi (conj Ehd (conj Hk Ev))) ].
  split; [ exact Sp | split; [ exact Sl | ] ].
  exists fl', gol', gmo', sdp', gdi', fs'. exact (conj S3' (conj S4' (conj S5' (conj S6' (conj S7' C'))))).
Qed.

Lemma ld32_load : forall m b z, OW.ld32 m b z = Mem.load Mint32 m b z.
Proof. intros m b z. unfold OW.ld32. apply CM.load_eq. Qed.

(* ---------------------------------------------------------------------- *)
(* 4. The step.                                                            *)
(* ---------------------------------------------------------------------- *)
Section STEP.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Notation G := (lp_ge lp).
  Variable bm : block.
  Hypothesis Hbm_sym : Genv.find_symbol G level_update._gMarioStates = Some bm.
  Variables (bc : block) (oc0 : ptrofs) (SafeB : block -> Prop).
  Hypothesis Hbc_sym : Genv.find_symbol G mario._gControllers = Some bc.
  Hypothesis Hoc0 : oc0 = Ptrofs.zero.
  Hypothesis Hsq : FpuFloor.sqrtf_spec.
  (* LABELED (ObjExit): the scripts are SafeB *)
  Hypothesis HSafeB_scr : forall b, BhvStep.scr_b lp b -> SafeB b.
  Notation MWF := (MWF_real lp bm bc oc0 SafeB).
  Notation Pobjl := (HeightFrame.Pobj lp bm MWF (HeightFrame.PhiW lp bm) (OW.obj_w G bm)).
  Notation Pc := (ClearKeep.Pc lp bm bc oc0 SafeB).
  Notation INV go pool oc bcc st0 nb0 X := (ObjInv.INVk lp bm bc oc0 SafeB go pool oc bcc st0 nb0 X).

  Lemma pc_of_P : forall m, Pobjl m -> Pc m.
  Proof. intros m (Hok & Hphi & HD & Hst & _ & How). exact (conj Hok (conj Hphi (conj HD (conj Hst How)))). Qed.
  Lemma P_of_pc : forall m, Pc m -> Pobjl m.
  Proof.
    intros m (Hok & Hphi & HD & Hst & How).
    exact (conj Hok (conj Hphi (conj HD (conj Hst (conj (RenderKeep.phiw_surf_apart lp bm _ m Hphi) How))))).
  Qed.

  Lemma SNE : forall id1 id2 b1 b2, Genv.find_symbol G id1 = Some b1 -> Genv.find_symbol G id2 = Some b2 ->
    id1 <> id2 -> b1 <> b2.
  Proof. intros id1 id2 b1 b2 H1 H2 Ne ->. apply Ne. eapply Genv.genv_vars_inj; eassumption. Qed.

  Lemma sym_valid_P : forall g id b, Pobjl g -> Genv.find_symbol G id = Some b -> Mem.valid_block g b.
  Proof.
    intros g id b (Hok & _) Hs. pose proof Hok as (_ & _ & HM).
    pose proof HM as ((_ & _ & _ & _ & _ & _ & _ & Hgn) & _).
    pose proof (Genv.genv_symb_range _ _ Hs) as R. unfold Mem.valid_block, Plt, Ple in *. lia.
  Qed.

  (* ---- the statements ---- *)
  Lemma x_gco : forall le m t le' m' out v, le ! OLP._firstObj = Some v -> (exists b o, v = Vptr b o) ->
    exec_stmt function_entry2 G empty_env le m GCO_ASG t le' m' out ->
    exists go, Genv.find_symbol G BS._gCurrentObject = Some go /\ Mem.store Mint32 m go 0 v = Some m'
      /\ le' = le /\ out = Out_normal.
  Proof.
    intros le m t le' m' out v Hv (b & o & ->) H. unfold GCO_ASG in H.
    apply RA.assign_inv in H as (b1 & o1 & bf & v2 & v3 & Hlv & Ev & Hc & Has & -> & ->).
    apply (RA.lv_gvar G empty_env m) in Hlv as (Hb & -> & ->); [ | apply PTree.gempty ].
    apply RA.ev_cast in Ev as (v0 & Ev0 & C0). apply RA.ev_temp in Ev0. rewrite Hv in Ev0. injection Ev0 as <-.
    cbn [typeof] in C0, Hc. rewrite BhvStep.cast_pp in C0. injection C0 as <-.
    rewrite BhvStep.cast_pp in Hc. injection Hc as <-.
    pose proof (RA.store_by_value _ pObj _ _ _ _ _ _ Mint32 eq_refl eq_refl Has) as Hs.
    rewrite Ptrofs.unsigned_zero in Hs. exists b1. auto.
  Qed.

  Lemma x_flg : forall go pool oc ta tb tc rhs le m t le' m' out,
    Genv.find_symbol G BhvStep.BS._gCurrentObject = Some go ->
    0 <= oc <= 145312 -> pool <> go -> tc <> ta -> typeof rhs = tint ->
    BhvStep.cur go pool oc m ->
    exec_stmt function_entry2 G empty_env le m (FLG ta tb tc rhs) t le' m' out ->
    exists i, Mem.store Mint16signed m pool (oc + 2) (Vint i) = Some m' /\ out = Out_normal.
  Proof.
    intros go pool oc ta tb tc rhs le m t le' m' out Hgo Hoc Hpg Hne Hty Hc H. unfold FLG in H.
    apply RA.seq_inv in H as [(t1 & le1 & m1 & t2 & X1 & X2) | (X1 & Xn)];
      [ | exfalso; apply (BhvStep.ld_cur lp go pool oc Hgo) in X1 as (_ & _ & E); [ exact (Xn E) | exact Hc ] ].
    apply (BhvStep.ld_cur lp go pool oc Hgo) in X1 as (-> & -> & _); [ | exact Hc ].
    apply RA.seq_inv in X2 as [(t3 & le3 & m3 & t4 & X3 & X4) | (X3 & Xn)];
      [ | exfalso; apply (BhvStep.ld_cur lp go pool oc Hgo) in X3 as (_ & _ & E); [ exact (Xn E) | exact Hc ] ].
    apply (BhvStep.ld_cur lp go pool oc Hgo) in X3 as (-> & -> & _); [ | exact Hc ].
    apply RA.seq_inv in X4 as [(t5 & le5 & m5 & t6 & X5 & X6) | (X5 & Xn)];
      [ | exfalso; apply RA.set_inv in X5 as (_ & _ & _ & _ & E); exact (Xn E) ].
    apply RA.set_inv in X5 as (v3 & _ & -> & -> & _).
    apply RA.assign_inv in X6 as (b & o & bf & v2 & v & Hlv & _ & Hcst & Has & _ & ->).
    assert (Hta : (PTree.set tc v3 (PTree.set tb (Vptr pool (Ptrofs.repr oc))
                    (PTree.set ta (Vptr pool (Ptrofs.repr oc)) le))) ! ta = Some (Vptr pool (Ptrofs.repr oc))).
    { rewrite PTree.gso by (intros E; exact (Hne (eq_sym E))).
      destruct (peq ta tb) as [-> | Nab]; [ apply PTree.gss | ].
      rewrite PTree.gso by exact Nab. apply PTree.gss. }
    destruct (BhvStep.lv_gflags lp H12 go pool oc Hoc Hpg m _ ta b o bf Hta Hlv) as (-> & Ho & ->).
    pose proof (RA.store_by_value _ tshort _ _ _ _ _ _ Mint16signed eq_refl eq_refl Has) as Hs. rewrite Ho in Hs.
    unfold BhvStep.GFL in Hcst. cbn [typeof] in Hcst. rewrite Hty in Hcst.
    destruct v2; cbn in Hcst; try discriminate Hcst. injection Hcst as <-.
    eexists. split; [ exact Hs | reflexivity ].
  Qed.

  Lemma x_call : forall le m t le' m' out,
    exec_stmt function_entry2 G empty_env le m CALL t le' m' out ->
    (exists vr, eval_funcall function_entry2 G m (Internal BS.f_cur_obj_update) [] t m' vr) /\ out = Out_normal.
  Proof.
    intros le m t le' m' out H. unfold CALL in H.
    destruct (RA.call_inv G empty_env le m None _ nil t le' m' out H)
      as (tyargs & tyres & cconv & vf & vargs & fd & vres & _ & Ef & Eal & Hff & _ & Hev & _ & ->).
    inv Eal. split; [ | reflexivity ].
    inv Ef.
    match goal with Hl : eval_lvalue _ _ _ _ (Evar _ _) _ _ _, Hd : deref_loc _ _ _ _ _ _ |- _ =>
      apply (RA.lv_gvar G empty_env m) in Hl as (Hb & -> & ->); [ | apply PTree.gempty ];
      inv Hd; try (match goal with Ha : access_mode _ = _ |- _ => cbn in Ha; discriminate Ha end) end.
    match goal with Hb : Genv.find_symbol _ _ = Some ?b |- _ =>
      rewrite (BhvStep.fun_bs lp H12 BS._cur_obj_update BS.f_cur_obj_update dm_cou b fd Hb Hff) in Hev end.
    exists vres. exact Hev.
  Qed.

  Ltac idne := let E := fresh "E" in intro E; vm_compute in E; discriminate E.

  (* ---- THE PREMISE: slot k's update keeps INV_k, with the ghost fact
     "slot k is in the ring of list head hd" (X) ---- *)
  Definition XR (ls : list nat) (hd : val) (pool : block) (k : Z) : mem -> Prop :=
    fun g => ObjLoop.in_ring_l G bm ls g hd (OW.slot_v pool k).

  Definition cou_keeps (ls : list nat) : Prop :=
    forall go pool bcc sb hd k st0 nb0,
      Genv.find_symbol G BS._gCurrentObject = Some go -> Genv.find_symbol G OLP._gObjectPool = Some pool ->
      Genv.find_symbol G BS._gCurBhvCommand = Some bcc -> Genv.find_symbol G BS._gRandomSeed16 = Some sb ->
      0 <= k < OW.NSLOT -> In st0 vm_tab ->
      ObjRows.ghost_keeps lp bm bc oc0 SafeB go pool (k * OW.OSZ) sb st0 (XR ls hd pool k)
      /\ ObjRows.rest_keeps lp bm bc oc0 SafeB go pool (k * OW.OSZ) bcc sb st0 nb0 (XR ls hd pool k)
      /\ BhvStep.pre_keep lp pool (k * OW.OSZ) (INV go pool (k * OW.OSZ) bcc st0 nb0 (XR ls hd pool k))
      /\ BhvStep.post_keep lp pool (k * OW.OSZ) (INV go pool (k * OW.OSZ) bcc st0 nb0 (XR ls hd pool k)).

  (* ---- cur_obj_update on slot k: entry, cou_real, exit ---- *)
  Theorem cou_step : forall ls, cou_keeps ls ->
    forall go pool hd k m t m' vr,
      Genv.find_symbol G BS._gCurrentObject = Some go -> Genv.find_symbol G OLP._gObjectPool = Some pool ->
      0 <= k < OW.NSLOT -> Pobjl m -> XR ls hd pool k m -> BhvStep.cur go pool (k * OW.OSZ) m ->
      eval_funcall function_entry2 G m (Internal BS.f_cur_obj_update) [] t m' vr ->
      Pobjl m' /\ XR ls hd pool k m'.
  Proof.
    intros ls K go pool hd k m t m' vr Hgo Hp Hk HP HX Hc Hev.
    destruct dm_bcc as (gd1 & D1). destruct dm_sb as (gd2 & D2).
    destruct (linkorder_resolves_symbol lp BS.prog _ _ (linked12_LO_behavior_script lp H12) D1) as (bcc & Hbcc).
    destruct (linkorder_resolves_symbol lp BS.prog _ _ (linked12_LO_behavior_script lp H12) D2) as (sb & Hsb).
    assert (Hpg : pool <> go) by (apply (SNE _ _ _ _ Hp Hgo); idne).
    assert (Hbp : bcc <> pool) by (apply (SNE _ _ _ _ Hbcc Hp); idne).
    assert (Hbg : bcc <> go) by (apply (SNE _ _ _ _ Hbcc Hgo); idne).
    assert (Hsp : sb <> pool) by (apply (SNE _ _ _ _ Hsb Hp); idne).
    assert (Hsc : sb <> bcc) by (apply (SNE _ _ _ _ Hsb Hbcc); idne).
    assert (Hsg : sb <> go) by (apply (SNE _ _ _ _ Hsb Hgo); idne).
    assert (Hps : forall st b, In st vm_tab -> Genv.find_symbol G (v_s st) = Some b -> b <> pool).
    { intros st b Hst Hs. destruct (ObjExit.scr_ids_ne (v_s st) (in_map v_s vm_tab st Hst)) as (_ & N2).
      exact (SNE _ _ _ _ Hs Hp N2). }
    assert (Hoc : 0 <= k * OW.OSZ <= 145312) by (unfold OW.OSZ, OW.NSLOT in *; lia).
    (* slot k's start state: obj_w's VM clause; its script is live (ow_script) *)
    pose proof HX as ((pool' & la & rs & i & k' & (Sp & Sl & (fl & gol & gmo & sdp & gdi & fs & S3 & S4 & S5 & S6 & S7 & C))
                       & Hi & Ehd & Hk' & Ev) & _).
    rewrite Hp in Sp. injection Sp as <-.
    assert (Hpl : pool <> la) by (apply (SNE _ _ _ _ Hp Sl); idne).
    pose proof (OW.ow_rings _ _ _ _ _ _ _ _ _ _ _ _ C) as Hr.
    assert (Ek : k' = k).
    { pose proof (ObjLoop.ring_k m pool la rs i k' Hr Hi Hk') as Rk'.
      assert (Eo : Ptrofs.repr (k * OW.OSZ) = Ptrofs.repr (k' * OW.OSZ)) by (unfold OW.slot_v in Ev; congruence).
      assert (U1 : Ptrofs.unsigned (Ptrofs.repr (k * OW.OSZ)) = k * OW.OSZ)
        by (apply Ptrofs.unsigned_repr; rewrite BhvStep.maxu; unfold OW.OSZ, OW.NSLOT in *; lia).
      assert (U2 : Ptrofs.unsigned (Ptrofs.repr (k' * OW.OSZ)) = k' * OW.OSZ)
        by (apply Ptrofs.unsigned_repr; rewrite BhvStep.maxu; unfold OW.OSZ, OW.NSLOT in *; lia).
      rewrite Eo, U2 in U1. unfold OW.OSZ in U1. lia. }
    subst k'.
    assert (Hkc : In k (concat rs)).
    { destruct (proj1 (ObjRing.rings_iff pool m la rs Hpl) Hr) as (Hlen & _).
      apply (UnloadRows.in_nth_concat rs i k); [ rewrite Hlen; exact Hi | exact Hk' ]. }
    destruct (BhvStep.vm_ok_Vo lp pool (k * OW.OSZ) m k eq_refl (OW.ow_vm _ _ _ _ _ _ _ _ _ _ _ _ C k Hkc))
      as (st0 & Hst0 & HV0).
    assert (HQ0 : ObjFamily.Qfam (v_s st0) st0).
    { apply (ObjFamily.Qfam_start (v_s st0) st0 eq_refl).
      destruct (OW.ow_script _ _ _ _ _ _ _ _ _ _ _ _ C k Hkc) as (id & b & o & Hid & Hb & Lb).
      pose proof HV0 as ((b0 & Hb0 & L0) & _).
      rewrite Lb in L0. injection L0 as Eb _. subst b0.
      assert (Ei : v_s st0 = id) by (eapply Genv.genv_vars_inj; [ exact Hb0 | exact Hb ]). rewrite Ei. exact Hid. }
    destruct (K go pool bcc sb hd k st0 (Mem.nextblock m) Hgo Hp Hbcc Hsb Hk Hst0) as (GK & RK & KPRE & KPOST).
    pose proof (ObjInv.inv_entry lp bm bc oc0 SafeB go pool (k * OW.OSZ) bcc st0 (Mem.nextblock m) (XR ls hd pool k) m
                  eq_refl HP HV0 Hc HX) as HI.
    pose proof (ObjRows.rows_k lp bm bc oc0 SafeB go pool (k * OW.OSZ) bcc sb Hbcc Hp Hpg Hbp st0 (Mem.nextblock m)
                  (XR ls hd pool k) Hsp Hsc Hsg Hoc (PK.vm_depth st0 Hst0) GK RK) as KR.
    destruct (BhvStep.cou_real lp H12 go pool (k * OW.OSZ) Hgo Hoc Hpg bcc Hbcc Hbp Hbg Hps sb Hsb
                (fun E => Hsp (eq_sym E))
                (INV go pool (k * OW.OSZ) bcc st0 (Mem.nextblock m) (XR ls hd pool k)) (ObjFamily.Qfam (v_s st0))
                (ObjFamily.Qfam_closed (v_s st0))
                (ObjInv.inv_scr lp bm bc oc0 SafeB go pool (k * OW.OSZ) bcc Hbcc Hp Hpg Hbg Hps st0 (Mem.nextblock m) (XR ls hd pool k))
                (ObjInv.inv_cur lp bm bc oc0 SafeB go pool (k * OW.OSZ) bcc st0 (Mem.nextblock m) (XR ls hd pool k))
                (ObjInv.inv_frame lp bm bc oc0 SafeB go pool (k * OW.OSZ) bcc Hpg Hbg st0 (Mem.nextblock m) (XR ls hd pool k))
                Hsq Hp (fun _ => SafeB) KR KPRE KPOST
                (ObjInv.inv_free lp bm bc oc0 SafeB go pool (k * OW.OSZ) bcc Hgo Hpg Hbg st0 (Mem.nextblock m) (XR ls hd pool k))
                m t m' vr st0 Hst0 HQ0 HV0 HI Hev) as (st' & Hst' & HQ' & HV' & HI').
    pose proof (ObjExit.inv_exit lp bm bc oc0 SafeB go pool bcc k st0 (Mem.nextblock m) (XR ls hd pool k) m' st'
                  Hbm_sym Hbc_sym Hp Hbcc HSafeB_scr Hst0 Hst' HQ' HI' HV') as HP'.
    split; [ exact HP' | ].
    destruct HI' as (_ & _ & g & Hg & _ & _ & U & _ & HXg).
    apply (in_ring_tr G bm ls g m' hd _ HXg (proj2 (proj2 (proj2 (proj2 (proj2 HP')))))).
    intros pool2 la2 Sp2 Sl2. rewrite Hp in Sp2. injection Sp2 as <-.
    assert (Hpl2 : pool <> la2) by (apply (SNE _ _ _ _ Hp Sl2); idne).
    assert (Hbl2 : la2 <> bcc) by (apply (SNE _ _ _ _ Sl2 Hbcc); idne).
    pose proof (sym_valid_P g _ _ Hg Hp) as Vp. pose proof (sym_valid_P g _ _ Hg Sl2) as Vl.
    apply rings_link.
    - intros j Hj. rewrite !ld32_load.
      split; apply (Mem.load_unchanged_on_1 _ _ _ _ _ _ U Vp); intros z Hz; unfold BhvStep.Pfr;
        (split; [ exact (fun E => Hbp (eq_sym E)) | intros (_ & Hz') ]);
        unfold OW.O_PREV, OW.O_NEXT, OW.O_CMD, OW.O_STK, OW.OSZ, OW.NSLOT in *; cbn [size_chunk] in Hz; lia.
    - intros z. rewrite !ld32_load. apply (Mem.load_unchanged_on_1 _ _ _ _ _ _ U Vl).
      intros z' _. unfold BhvStep.Pfr. split; [ exact Hbl2 | intros (E & _); exact (Hpl2 (eq_sym E)) ].
  Qed.

  (* ---- the loop's own stores ---- *)
  Lemma gco_step : forall go pool k m m1, Genv.find_symbol G BS._gCurrentObject = Some go ->
    Genv.find_symbol G OLP._gObjectPool = Some pool ->
    Mem.store Mint32 m go 0 (OW.slot_v pool k) = Some m1 -> Pobjl m ->
    Pobjl m1 /\ BhvStep.cur go pool (k * OW.OSZ) m1
    /\ forall la, Genv.find_symbol G OLP._gObjectListArray = Some la -> OW.rings m1 pool la = OW.rings m pool la.
  Proof.
    intros go pool k m m1 Hgo Hp S HP.
    split; [ exact (P_of_pc _ (UnloadRows.gco_keep lp H12 bm Hbm_sym bc oc0 SafeB Hbc_sym Hoc0 go pool k m m1
                                 Hgo Hp S (pc_of_P _ HP))) | split ].
    - unfold BhvStep.cur. rewrite (Mem.load_store_same _ _ _ _ _ _ S). reflexivity.
    - intros la Sl. apply rings_link.
      + intros j _. rewrite !ld32_load.
        split; apply (Mem.load_store_other _ _ _ _ _ _ S); left; apply (SNE _ _ _ _ Hp Hgo); idne.
      + intros z. rewrite !ld32_load. apply (Mem.load_store_other _ _ _ _ _ _ S). left.
        apply (SNE _ _ _ _ Sl Hgo); idne.
  Qed.

  Lemma flg_step : forall go pool k m m1 i, Genv.find_symbol G OLP._gObjectPool = Some pool ->
    pool <> go -> Mem.store Mint16signed m pool (k * OW.OSZ + 2) (Vint i) = Some m1 -> Pobjl m ->
    BhvStep.cur go pool (k * OW.OSZ) m ->
    Pobjl m1 /\ BhvStep.cur go pool (k * OW.OSZ) m1
    /\ forall la, Genv.find_symbol G OLP._gObjectListArray = Some la -> OW.rings m1 pool la = OW.rings m pool la.
  Proof.
    intros go pool k m m1 i Hp Hpg S HP Hc.
    assert (Hz : k * OW.OSZ <= k * OW.OSZ + 2 /\ k * OW.OSZ + 2 + size_chunk Mint16signed <= k * OW.OSZ + 4)
      by (cbn [size_chunk]; lia).
    split; [ exact (P_of_pc _ (ObjGfl.gfl_pc lp bm Hbm_sym bc oc0 SafeB Hbc_sym pool k Hp m m1 Mint16signed _ i
                                 (pc_of_P _ HP) Hz S)) | split ].
    - unfold BhvStep.cur in *. rewrite (Mem.load_store_other _ _ _ _ _ _ S); [ exact Hc | left; exact (fun E => Hpg (eq_sym E)) ].
    - intros la Sl. apply (ObjGfl.gfl_rings pool k m m1 Mint16signed _ i Hz S la).
      apply (SNE _ _ _ _ Sl Hp); idne.
  Qed.

  Lemma ring_slot : forall ls m hd v, ObjLoop.in_ring_l G bm ls m hd v ->
    exists pool k, Genv.find_symbol G OLP._gObjectPool = Some pool /\ 0 <= k < OW.NSLOT /\ v = OW.slot_v pool k.
  Proof.
    intros ls m hd v ((pool & la & rs & i & k & (Sp & Sl & (fl & gol & gmo & sdp & gdi & fs & S3 & S4 & S5 & S6 & S7 & C))
                       & Hi & _ & Hk & Ev) & _).
    exists pool, k. split; [ exact Sp | split; [ | exact Ev ] ].
    exact (ObjLoop.ring_k m pool la rs i k (OW.ow_rings _ _ _ _ _ _ _ _ _ _ _ _ C) Hi Hk).
  Qed.

  Lemma xr_tr : forall ls hd pool k m m1, XR ls hd pool k m -> Pobjl m1 ->
    (forall la, Genv.find_symbol G OLP._gObjectListArray = Some la -> OW.rings m1 pool la = OW.rings m pool la) ->
    Genv.find_symbol G OLP._gObjectPool = Some pool -> XR ls hd pool k m1.
  Proof.
    intros ls hd pool k m m1 HX HP1 R Hp.
    apply (in_ring_tr G bm ls m m1 hd _ HX (proj2 (proj2 (proj2 (proj2 (proj2 HP1)))))).
    intros pool2 la Sp2 Sl. rewrite Hp in Sp2. injection Sp2 as <-. exact (R la Sl).
  Qed.

  (* the flag store and the call, from gCurrentObject = slot k *)
  Lemma upd_step : forall ls, cou_keeps ls -> forall go pool hd k ta tb tc le m t1 le1 m1 t2 le2 m2 out,
    Genv.find_symbol G BS._gCurrentObject = Some go -> Genv.find_symbol G OLP._gObjectPool = Some pool ->
    0 <= k < OW.NSLOT -> tc <> ta ->
    Pobjl m -> XR ls hd pool k m -> BhvStep.cur go pool (k * OW.OSZ) m ->
    exec_stmt function_entry2 G empty_env le m (FLG ta tb tc (OR5 tc)) t1 le1 m1 Out_normal ->
    exec_stmt function_entry2 G empty_env le1 m1 CALL t2 le2 m2 out ->
    Pobjl m2 /\ XR ls hd pool k m2 /\ out = Out_normal.
  Proof.
    intros ls K go pool hd k ta tb tc le m t1 le1 m1 t2 le2 m2 out Hgo Hp Hk Hne HP HX Hc X1 X2.
    assert (Hpg : pool <> go) by (apply (SNE _ _ _ _ Hp Hgo); idne).
    assert (Hoc : 0 <= k * OW.OSZ <= 145312) by (unfold OW.OSZ, OW.NSLOT in *; lia).
    destruct (x_flg go pool _ ta tb tc (OR5 tc) le m t1 le1 m1 _ Hgo Hoc Hpg Hne eq_refl Hc X1) as (i & S & _).
    destruct (flg_step go pool k m m1 i Hp Hpg S HP Hc) as (HP1 & Hc1 & R1).
    destruct (x_call _ _ _ _ _ _ X2) as ((vr & Hev) & ->).
    destruct (cou_step ls K go pool hd k m1 t2 m2 vr Hgo Hp Hk HP1 (xr_tr ls hd pool k m m1 HX HP1 R1 Hp) Hc1 Hev)
      as (HP' & HX').
    exact (conj HP' (conj HX' eq_refl)).
  Qed.

  (* ---- THE REST ROWS ---- *)
  Theorem rest_sa : forall ls, cou_keeps ls ->
    ObjStepSplit.step_rest_row G bm Pobjl (ObjLoop.in_ring_l G bm ls) OLP.f_update_objects_starting_at.
  Proof.
    intros ls K hd v le m t le' m' out HP Hin Hv _ Hx _.
    destruct (ring_slot ls m hd v Hin) as (pool & k & Hp & Hk & ->).
    rewrite sa_shape in Hx.
    assert (Hpt : exists b o, OW.slot_v pool k = Vptr b o) by (eexists; eexists; reflexivity).
    apply RA.seq_inv in Hx as [(t1 & le1 & m1 & t2 & X1 & X2) | (X1 & Xn)];
      [ | exfalso; destruct (x_gco _ _ _ _ _ _ _ Hv Hpt X1) as (_ & _ & _ & _ & E); exact (Xn E) ].
    destruct (x_gco _ _ _ _ _ _ _ Hv Hpt X1) as (go & Hgo & S1 & -> & _).
    destruct (gco_step go pool k m m1 Hgo Hp S1 HP) as (HP1 & Hc1 & R1).
    pose proof (xr_tr ls hd pool k m m1 Hin HP1 R1 Hp) as HX1.
    assert (Hpg : pool <> go) by (apply (SNE _ _ _ _ Hp Hgo); idne).
    assert (Hoc : 0 <= k * OW.OSZ <= 145312) by (unfold OW.OSZ, OW.NSLOT in *; lia).
    assert (Hne : OLP._t'3 <> OLP._t'1) by idne.
    apply RA.seq_inv in X2 as [(t3 & le3 & m3 & t4 & X3 & X4) | (X3 & Xn)];
      [ | exfalso; destruct (x_flg go pool _ _ _ _ (OR5 OLP._t'3) _ _ _ _ _ _ Hgo Hoc Hpg Hne eq_refl Hc1 X3) as (_ & _ & E);
          exact (Xn E) ].
    apply RA.seq_inv in X4 as [(t5 & le5 & m5 & t6 & X5 & X6) | (X5 & Xn)];
      [ | exfalso; destruct (x_call _ _ _ _ _ _ X5) as (_ & E); exact (Xn E) ].
    inv X6.
    destruct (upd_step ls K go pool hd k _ _ _ _ _ _ _ _ _ _ _ _ Hgo Hp Hk Hne HP1 HX1 Hc1 X3 X5) as (HP' & HX' & _).
    exact (conj HP' HX').
  Qed.

  Theorem rest_ts : forall ls, cou_keeps ls ->
    ObjStepSplit.step_rest_row G bm Pobjl (ObjLoop.in_ring_l G bm ls) OLP.f_update_objects_during_time_stop.
  Proof.
    intros ls K hd v le m t le' m' out HP Hin Hv _ Hx _.
    destruct (ring_slot ls m hd v Hin) as (pool & k & Hp & Hk & ->).
    change (ObjLoop.loop_pre OLP.f_update_objects_during_time_stop) with TSL in Hx.
    rewrite ts_shape in Hx. destruct ts_pure as (P1 & P2).
    assert (Hpt : exists b o, OW.slot_v pool k = Vptr b o) by (eexists; eexists; reflexivity).
    apply RA.seq_inv in Hx as [(t1 & le1 & m1 & t2 & X1 & X2) | (X1 & Xn)];
      [ | exfalso; destruct (x_gco _ _ _ _ _ _ _ Hv Hpt X1) as (_ & _ & _ & _ & E); exact (Xn E) ].
    destruct (x_gco _ _ _ _ _ _ _ Hv Hpt X1) as (go & Hgo & S1 & -> & _).
    destruct (gco_step go pool k m m1 Hgo Hp S1 HP) as (HP1 & Hc1 & R1).
    pose proof (xr_tr ls hd pool k m m1 Hin HP1 R1 Hp) as HX1.
    assert (Hpg : pool <> go) by (apply (SNE _ _ _ _ Hp Hgo); idne).
    assert (Hoc : 0 <= k * OW.OSZ <= 145312) by (unfold OW.OSZ, OW.NSLOT in *; lia).
    assert (Hne8 : OLP._t'8 <> OLP._t'6) by idne.
    assert (Hne5 : OLP._t'5 <> OLP._t'3) by idne.
    (* the pure prefix *)
    apply RA.seq_inv in X2 as [(t3 & le3 & m3 & t4 & X3 & X4) | (X3 & Xn)];
      [ | exfalso; exact (Xn (proj2 (pure_exec _ _ _ _ _ _ _ _ _ P1 X3))) ].
    destruct (pure_exec _ _ _ _ _ _ _ _ _ P1 X3) as (-> & _).
    apply RA.seq_inv in X4 as [(t5 & le5 & m5 & t6 & X5 & X6) | (X5 & Xn)];
      [ | exfalso; exact (Xn (proj2 (pure_exec _ _ _ _ _ _ _ _ _ P2 X5))) ].
    destruct (pure_exec _ _ _ _ _ _ _ _ _ P2 X5) as (-> & _).
    (* the branch, then the trailing skip *)
    apply RA.seq_inv in X6 as [(t7 & le7 & m7 & t8 & X7 & X8) | (X7 & Xn)].
    2: { exfalso. inv X7.
         match goal with H : exec_stmt _ _ _ _ _ (if ?b then _ else _) _ _ _ _ |- _ => rename H into XX; destruct b end.
         - apply RA.seq_inv in XX as [(ta & lea & ma & tb & XA & XB) | (XA & Xn')].
           + destruct (x_call _ _ _ _ _ _ XB) as (_ & E). exact (Xn E).
           + destruct (x_flg go pool _ _ _ _ (OR5 OLP._t'8) _ _ _ _ _ _ Hgo Hoc Hpg Hne8 eq_refl Hc1 XA) as (_ & _ & E).
             exact (Xn' E).
         - destruct (x_flg go pool _ _ _ _ (AND5 OLP._t'5) _ _ _ _ _ _ Hgo Hoc Hpg Hne5 eq_refl Hc1 XX) as (_ & _ & E).
           exact (Xn E). }
    inv X8.
    inv X7.
    match goal with H : exec_stmt _ _ _ _ _ (if ?b then _ else _) _ _ _ _ |- _ => rename H into XX; destruct b end.
    - apply RA.seq_inv in XX as [(ta & lea & ma & tb & XA & XB) | (XA & Xn)].
      + destruct (upd_step ls K go pool hd k _ _ _ _ _ _ _ _ _ _ _ _ Hgo Hp Hk Hne8 HP1 HX1 Hc1 XA XB) as (HP' & HX' & _).
        exact (conj HP' HX').
      + exfalso.
        destruct (x_flg go pool _ _ _ _ (OR5 OLP._t'8) _ _ _ _ _ _ Hgo Hoc Hpg Hne8 eq_refl Hc1 XA) as (_ & _ & E).
        exact (Xn E).
    - destruct (x_flg go pool _ _ _ _ (AND5 OLP._t'5) _ _ _ _ _ _ Hgo Hoc Hpg Hne5 eq_refl Hc1 XX) as (i & S & _).
      destruct (flg_step go pool k m1 _ i Hp Hpg S HP1 Hc1) as (HP2 & _ & R2).
      exact (conj HP2 (xr_tr ls hd pool k m1 _ HX1 HP2 R2 Hp)).
  Qed.
End STEP.
