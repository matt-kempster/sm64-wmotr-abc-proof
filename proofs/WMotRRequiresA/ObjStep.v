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
(* TERRAIN (2026-11-08): the same walk generic in the ghost fact (rest_saX *)
(* / rest_tsX); with XT (ring + ter_abd, ter_post minus the counter) it    *)
(* gives ObjStepSplit.ter_rest_row from cou_keeps_t and the counter row    *)
(* ter_ctr_row (census: TerCtrCensus).                                     *)
(* HSafeB_scr (the scripts are SafeB) is a section hypothesis here; the    *)
(* capstones discharge it from SafeB_syms_ok (d) (scr_safe below).         *)
(* ======================================================================= *)

From Coq Require Import ZArith Lia List Bool.
From compcert Require Import Coqlib Integers Floats Values AST Ctypes Cop Clight
  ClightBigstep Clightdefs Memory Maps Globalenvs Events Errors Linking.
From SM64.Generated Require object_list_processor level_update mario behavior_script surface_load.
From SM64.Proofs Require Import SymbolicLinking RealFrameLinked LinkedTwelve MWFReal NoAImpliesNoFlyLinked AGates.
From SM64.Proofs Require Interp.CMem.
From SM64.Proofs Require CensusV2 SpawnInit ActionValueFrame Taint.
From SM64.Proofs.WMotRRequiresA Require Import BhvVM.
From SM64.Proofs.WMotRRequiresA Require ObjWorld ObjRing PollKeep ClearKeep BhvStep ObjFamily ObjLoop
  ObjStepSplit UnloadRows RenderAnim RenderKeep FpuFloor ObjSelf.
From SM64.Proofs.WMotRRequiresA Require ObjInv ObjExit ObjRows ObjGfl ObjFld FieldWin FieldWinCensus.
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
(* 3b. The terrain bookkeeping: ObjLoop.ter_post without the counter       *)
(*     (a) tail growth by budget-0 nodes, (b) the 11 / 9 budgets, (d) the  *)
(*     time-stop gate -- composable along the step's memories.             *)
(* ---------------------------------------------------------------------- *)
Definition ter_abd (G : genv) (m m' : mem) : Prop :=
  OW.tsa G m' = OW.tsa G m /\
  forall pool la rs rs', Genv.find_symbol G OLP._gObjectPool = Some pool ->
    Genv.find_symbol G OLP._gObjectListArray = Some la ->
    OW.rings m pool la = Some rs -> OW.rings m' pool la = Some rs' ->
    (forall L, In L ObjLoop.ter_ls -> exists ext, nth L rs' [] = nth L rs [] ++ ext
                                    /\ Forall (fun k => OW.sdyn G pool m' k = 0) ext)
    /\ (forall k, In k (nth 11 rs []) \/ In k (nth 9 rs []) -> OW.sdyn G pool m' k = OW.sdyn G pool m k).

Lemma ter_abd_refl : forall G m, ter_abd G m m.
Proof.
  intros G m. split; [ reflexivity | ]. intros pool la rs rs' _ _ R R'. rewrite R in R'. injection R' as <-.
  split; [ intros L _; exists []; split; [ rewrite app_nil_r; reflexivity | constructor ] | intros k _; reflexivity ].
Qed.

Lemma ter_abd_same : forall G m m', OW.tsa G m' = OW.tsa G m ->
  (forall pool la, Genv.find_symbol G OLP._gObjectPool = Some pool ->
     Genv.find_symbol G OLP._gObjectListArray = Some la -> OW.rings m' pool la = OW.rings m pool la) ->
  (forall pool k, Genv.find_symbol G OLP._gObjectPool = Some pool -> OW.sdyn G pool m' k = OW.sdyn G pool m k) ->
  ter_abd G m m'.
Proof.
  intros G m m' T R D. split; [ exact T | ]. intros pool la rs rs' Sp Sl E E'.
  rewrite (R pool la Sp Sl), E in E'. injection E' as <-.
  split.
  - intros L _. exists []. split; [ rewrite app_nil_r; reflexivity | constructor ].
  - intros k _. exact (D pool k Sp).
Qed.

Lemma ter_ls_in : forall L (rs : list (list Z)) k, In L ObjLoop.ter_ls -> In k (nth L rs []) ->
  In k (nth 11 rs []) \/ In k (nth 9 rs []).
Proof.
  intros L rs k HL Hk. unfold ObjLoop.ter_ls in HL. cbn [In] in HL.
  destruct HL as [<- | [<- | []]]; [ left | right ]; exact Hk.
Qed.

Lemma ter_abd_tr : forall G m m1 m2, ter_abd G m m1 -> ter_abd G m1 m2 ->
  (forall pool la, Genv.find_symbol G OLP._gObjectPool = Some pool ->
     Genv.find_symbol G OLP._gObjectListArray = Some la -> exists rs1, OW.rings m1 pool la = Some rs1) ->
  ter_abd G m m2.
Proof.
  intros G m m1 m2 (T1 & A1) (T2 & A2) Hr. split; [ congruence | ].
  intros pool la rs rs2 Sp Sl R R2.
  destruct (Hr pool la Sp Sl) as (rs1 & R1).
  destruct (A1 pool la rs rs1 Sp Sl R R1) as (E1 & D1).
  destruct (A2 pool la rs1 rs2 Sp Sl R1 R2) as (E2 & D2).
  split.
  - intros L HL. destruct (E1 L HL) as (e1 & Q1 & F1). destruct (E2 L HL) as (e2 & Q2 & F2).
    exists (e1 ++ e2). split; [ rewrite Q2, Q1, app_assoc; reflexivity | ].
    apply Forall_app. split; [ | exact F2 ].
    rewrite Forall_forall in F1 |- *. intros k Hk.
    assert (Hk1 : In k (nth L rs1 [])) by (rewrite Q1; apply in_or_app; right; exact Hk).
    rewrite (D2 k (ter_ls_in L rs1 k HL Hk1)). exact (F1 k Hk).
  - intros k Hk.
    assert (Hk1 : In k (nth 11 rs1 []) \/ In k (nth 9 rs1 [])).
    { destruct Hk as [Hk | Hk].
      - left. destruct (E1 11%nat ltac:(unfold ObjLoop.ter_ls; cbn [In]; tauto)) as (e & Q & _).
        rewrite Q. apply in_or_app. left. exact Hk.
      - right. destruct (E1 9%nat ltac:(unfold ObjLoop.ter_ls; cbn [In]; tauto)) as (e & Q & _).
        rewrite Q. apply in_or_app. left. exact Hk. }
    rewrite (D2 k Hk1). exact (D1 k Hk).
Qed.

Lemma ter_post_of : forall G m m' v, ter_abd G m m' ->
  (forall pool k, Genv.find_symbol G OLP._gObjectPool = Some pool -> v = OW.slot_v pool k ->
     OW.ctrv G m' <= OW.ctrv G m + OW.dyn G pool m k) ->
  ObjLoop.ter_post G m m' v.
Proof.
  intros G m m' v (T & A) C pool la rs rs' Sp Sl R R'.
  destruct (A pool la rs rs' Sp Sl R R') as (A1 & A2).
  exact (conj A1 (conj A2 (conj (fun k Ev => C pool k Sp Ev) T))).
Qed.

Lemma runs_ld : forall G pool m m' j x,
  OW.ld32 m' pool (j * OW.OSZ + OW.O_CMD) = OW.ld32 m pool (j * OW.OSZ + OW.O_CMD) ->
  OW.runs G pool m' j x = OW.runs G pool m j x.
Proof. intros G pool m m' j x E. unfold OW.runs. rewrite E. reflexivity. Qed.

Lemma sdyn_runs : forall G pool m m' j, (forall x, OW.runs G pool m' j x = OW.runs G pool m j x) ->
  OW.sdyn G pool m' j = OW.sdyn G pool m j.
Proof. intros G pool m m' j E. unfold OW.sdyn. rewrite !E. reflexivity. Qed.

Lemma tsa_ld : forall (G : genv) m m', (forall b, Genv.find_symbol G surface_load._gTimeStopState = Some b ->
    Mem.load Mint32 m' b 0 = Mem.load Mint32 m b 0) -> OW.tsa G m' = OW.tsa G m.
Proof.
  intros G m m' H. unfold OW.tsa.
  destruct (Genv.find_symbol G surface_load._gTimeStopState) as [b|] eqn:E; [ rewrite (H b eq_refl) | ]; reflexivity.
Qed.

(* the budget of the slot whose VM state is st reads st's script *)
Lemma runs_Vo : forall lp pool k m st x, BhvStep.Vo lp pool (k * OW.OSZ) m st ->
  (OW.runs (lp_ge lp) pool m k x = true <-> v_s st = x).
Proof.
  intros lp pool k m st x ((b & Hb & L) & _). unfold OW.runs. rewrite ld32_load, L. unfold OW.sym_is.
  split.
  - destruct (Genv.find_symbol (lp_ge lp) x) as [b'|] eqn:E; [ | discriminate ].
    intros Eb. apply Pos.eqb_eq in Eb. subst b'. eapply Genv.genv_vars_inj; eassumption.
  - intros <-. rewrite Hb. exact (Pos.eqb_refl b).
Qed.

(* the family keeps the budget's scripts (ObjFamily.Qfam_id) *)
Lemma sdyn_Vo : forall lp pool k g m' st0 st', BhvStep.Vo lp pool (k * OW.OSZ) g st0 ->
  BhvStep.Vo lp pool (k * OW.OSZ) m' st' -> ObjFamily.Qfam (v_s st0) st' ->
  OW.sdyn (lp_ge lp) pool m' k = OW.sdyn (lp_ge lp) pool g k.
Proof.
  intros lp pool k g m' st0 st' V0 V1 HQ.
  assert (E : forall x, In x [OW.BOXS; OW.LIDS; OW.COINF] ->
            OW.runs (lp_ge lp) pool m' k x = OW.runs (lp_ge lp) pool g k x).
  { intros x Hx. apply eq_true_iff_eq. split; intros H.
    - apply (proj2 (runs_Vo lp pool k g st0 x V0)). apply (proj1 (ObjFamily.Qfam_id (v_s st0) st' x Hx HQ)).
      exact (proj1 (runs_Vo lp pool k m' st' x V1) H).
    - apply (proj2 (runs_Vo lp pool k m' st' x V1)). apply (proj2 (ObjFamily.Qfam_id (v_s st0) st' x Hx HQ)).
      exact (proj1 (runs_Vo lp pool k g st0 x V0) H). }
  unfold OW.sdyn.
  rewrite (E OW.BOXS (or_introl eq_refl)), (E OW.LIDS (or_intror (or_introl eq_refl))). reflexivity.
Qed.

(* slot k's VM state survives any change off its VM cells [460, 500) *)
Lemma vo_unch : forall lp pool oc m m1 st0, (List.length (v_k st0) <= 8)%nat ->
  Mem.unchanged_on (fun b o => b = pool /\ oc + OW.O_CMD <= o < oc + OW.O_CMD + 40) m m1 ->
  BhvStep.Vo lp pool oc m st0 -> BhvStep.Vo lp pool oc m1 st0.
Proof.
  intros lp pool oc m m1 st0 Hk0 U' HV.
  destruct HV as ((b & Hb & Hl) & Hsi & Hk).
  split; [ exists b; split; [ exact Hb | ] | split ].
  - refine (Mem.load_unchanged_on _ _ _ _ _ _ _ U' _ Hl).
    intros i Hi. split; [ reflexivity | ]. cbn [size_chunk] in Hi. lia.
  - refine (Mem.load_unchanged_on _ _ _ _ _ _ _ U' _ Hsi).
    intros i Hi. split; [ reflexivity | ]. cbn [size_chunk] in Hi. unfold OW.O_SIDX, OW.O_CMD in *. lia.
  - intros j f Hj. pose proof (Hk j f Hj) as Hf.
    assert (Hlt : (j < List.length (v_k st0))%nat) by (apply nth_error_Some; rewrite Hj; discriminate).
    assert (R : forall i, oc + OW.O_STK + 4 * (Z.of_nat (List.length (v_k st0)) - 1 - Z.of_nat j) <= i
                < oc + OW.O_STK + 4 * (Z.of_nat (List.length (v_k st0)) - 1 - Z.of_nat j) + size_chunk Mint32 ->
                pool = pool /\ oc + OW.O_CMD <= i < oc + OW.O_CMD + 40).
    { intros i Hi. split; [ reflexivity | ]. cbn [size_chunk] in Hi. unfold OW.O_STK, OW.O_CMD in *. lia. }
    destruct f as [s0 i0 |];
      [ destruct Hf as (b0 & Hb0 & Hl0); exists b0; split; [ exact Hb0 | ] | destruct Hf as (c & Hl0); exists c ];
      exact (Mem.load_unchanged_on _ _ _ _ _ _ _ U' R Hl0).
Qed.

(* THE COUNTER ROW (2026-11-08): the terrain step's surface counter grows by
   at most the object's budget -- clause (c) of ObjLoop.ter_post, alone.  A
   counter-only claim about the real update; the census behind it is
   TerCtrCensus (one load_object_collision_model per update per terrain
   script, none for the coin formation). *)
Definition ter_ctr_row (G : genv) (bm : block) (P : mem -> Prop) (f : function) : Prop :=
  forall hd v le m t le' m' out, P m -> ObjLoop.in_ring_l G bm ObjLoop.ter_ls m hd v -> ObjLoop.vbud G m v ->
    le ! OLP._firstObj = Some v -> le ! OLP._objList = Some hd ->
    exec_stmt function_entry2 G empty_env le m (ObjLoop.app_seq (ObjLoop.loop_pre f) Sskip) t le' m' out ->
    ActionValueFrame.action_sat Taint.not_tainted m' bm ->
    forall pool k, Genv.find_symbol G OLP._gObjectPool = Some pool -> v = OW.slot_v pool k ->
      OW.ctrv G m' <= OW.ctrv G m + OW.dyn G pool m k.

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
  Notation Pobjl := (ClearKeep.Pobjc lp bm bc oc0 SafeB).
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

  (* ---- THE PREMISE: slot k's update keeps INV_k, with a ghost fact XF
     (non-terrain: XR, "slot k is in the ring of list head hd"; terrain: XT,
     XR plus the bookkeeping ter_abd from the step's start) ---- *)
  Definition XR (ls : list nat) (hd : val) (pool : block) (k : Z) : mem -> Prop :=
    fun g => ObjLoop.in_ring_l G bm ls g hd (OW.slot_v pool k).

  Definition cou_keeps_g (XF : val -> block -> Z -> mem -> Prop) : Prop :=
    forall go pool bcc sb hd k st0 nb0,
      Genv.find_symbol G BS._gCurrentObject = Some go -> Genv.find_symbol G OLP._gObjectPool = Some pool ->
      Genv.find_symbol G BS._gCurBhvCommand = Some bcc -> Genv.find_symbol G BS._gRandomSeed16 = Some sb ->
      0 <= k < OW.NSLOT -> In st0 vm_tab ->
      ObjRows.ghost_keeps_r lp bm bc oc0 SafeB go pool (k * OW.OSZ) sb st0 (XF hd pool k)
      /\ ObjRows.rest_keeps lp bm bc oc0 SafeB go pool (k * OW.OSZ) bcc sb st0 nb0 (XF hd pool k)
      /\ BhvStep.pre_keep lp pool (k * OW.OSZ) (INV go pool (k * OW.OSZ) bcc st0 nb0 (XF hd pool k))
      /\ BhvStep.post_keep lp pool (k * OW.OSZ) (INV go pool (k * OW.OSZ) bcc st0 nb0 (XF hd pool k)).

  Definition cou_keeps (ls : list nat) : Prop := cou_keeps_g (XR ls).

  (* the ghost fact carries from the ghost to the exit memory (cou_real's
     exit: unchanged off the slot's VM cells and the command cell) and
     across the loop's own stores *)
  Definition xf_cou (XF : val -> block -> Z -> mem -> Prop) : Prop :=
    forall pool bcc hd k st0 st' g m',
      Genv.find_symbol G OLP._gObjectPool = Some pool -> Genv.find_symbol G BS._gCurBhvCommand = Some bcc ->
      0 <= k < OW.NSLOT -> ObjFamily.Qfam (v_s st0) st' ->
      Pobjl g -> BhvStep.Vo lp pool (k * OW.OSZ) g st0 ->
      Mem.unchanged_on (BhvStep.Pfr pool (k * OW.OSZ) bcc) g m' ->
      Pobjl m' -> BhvStep.Vo lp pool (k * OW.OSZ) m' st' ->
      XF hd pool k g -> XF hd pool k m'.

  Definition xf_st (XF : val -> block -> Z -> mem -> Prop) : Prop :=
    forall pool hd k m m1, Genv.find_symbol G OLP._gObjectPool = Some pool -> Pobjl m -> Pobjl m1 ->
      (forall la, Genv.find_symbol G OLP._gObjectListArray = Some la -> OW.rings m1 pool la = OW.rings m pool la) ->
      (forall j, OW.ld32 m1 pool (j * OW.OSZ + OW.O_CMD) = OW.ld32 m pool (j * OW.OSZ + OW.O_CMD)) ->
      OW.tsa G m1 = OW.tsa G m ->
      XF hd pool k m -> XF hd pool k m1.

  Lemma rings_unch : forall pool bcc k g m' la, Genv.find_symbol G OLP._gObjectPool = Some pool ->
    Genv.find_symbol G BS._gCurBhvCommand = Some bcc -> Genv.find_symbol G OLP._gObjectListArray = Some la ->
    Pobjl g -> Mem.unchanged_on (BhvStep.Pfr pool (k * OW.OSZ) bcc) g m' ->
    OW.rings m' pool la = OW.rings g pool la.
  Proof.
    intros pool bcc k g m' la2 Hp Hbcc Sl2 Hg U.
    assert (Hbp : bcc <> pool) by (apply (SNE _ _ _ _ Hbcc Hp); idne).
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

  Lemma rings_some : forall m pool la, Pobjl m -> Genv.find_symbol G OLP._gObjectPool = Some pool ->
    Genv.find_symbol G OLP._gObjectListArray = Some la -> exists rs, OW.rings m pool la = Some rs.
  Proof.
    intros m pool la HP Sp Sl.
    destruct (ObjLoop.ow_at_of G bm m (proj2 (proj2 (proj2 (proj2 (proj2 HP))))))
      as (pool' & la' & rs & (Sp' & Sl' & (fl & gol & gmo & sdp & gdi & fs & S3 & S4 & S5 & S6 & S7 & C))).
    rewrite Sp in Sp'. injection Sp' as <-. rewrite Sl in Sl'. injection Sl' as <-.
    exists rs. exact (OW.ow_rings _ _ _ _ _ _ _ _ _ _ _ _ C).
  Qed.

  Lemma xr_tr : forall ls hd pool k m m1, XR ls hd pool k m -> Pobjl m1 ->
    (forall la, Genv.find_symbol G OLP._gObjectListArray = Some la -> OW.rings m1 pool la = OW.rings m pool la) ->
    Genv.find_symbol G OLP._gObjectPool = Some pool -> XR ls hd pool k m1.
  Proof.
    intros ls hd pool k m m1 HX HP1 R Hp.
    apply (in_ring_tr G bm ls m m1 hd _ HX (proj2 (proj2 (proj2 (proj2 (proj2 HP1)))))).
    intros pool2 la Sp2 Sl. rewrite Hp in Sp2. injection Sp2 as <-. exact (R la Sl).
  Qed.

  Lemma xr_cou : forall ls, xf_cou (XR ls).
  Proof.
    intros ls pool bcc hd k st0 st' g m' Hp Hbcc _ _ Hg _ U HP' _ HXg.
    apply (in_ring_tr G bm ls g m' hd _ HXg (proj2 (proj2 (proj2 (proj2 (proj2 HP')))))).
    intros pool2 la2 Sp2 Sl2. rewrite Hp in Sp2. injection Sp2 as <-.
    exact (rings_unch pool bcc k g m' la2 Hp Hbcc Sl2 Hg U).
  Qed.

  Lemma xr_st : forall ls, xf_st (XR ls).
  Proof. intros ls pool hd k m m1 Hp _ HP1 R _ _ HX. exact (xr_tr ls hd pool k m m1 HX HP1 R Hp). Qed.

  (* ---- the terrain ghost fact: the ring, and the bookkeeping from m0 ---- *)
  Definition XT (ls : list nat) (m0 : mem) (hd : val) (pool : block) (k : Z) : mem -> Prop :=
    fun g => XR ls hd pool k g /\ ter_abd G m0 g.

  Definition cou_keeps_t (ls : list nat) : Prop := forall m0, cou_keeps_g (XT ls m0).

  Lemma xt_st : forall ls m0, xf_st (XT ls m0).
  Proof.
    intros ls m0 pool hd k m m1 Hp HP HP1 R C T (HX & A).
    split; [ exact (xr_st ls pool hd k m m1 Hp HP HP1 R C T HX) | ].
    apply (ter_abd_tr G m0 m m1 A); [ | intros pool2 la Sp2 Sl; exact (rings_some m pool2 la HP Sp2 Sl) ].
    apply ter_abd_same; [ exact T | | ].
    - intros pool2 la Sp2 Sl. rewrite Hp in Sp2. injection Sp2 as <-. exact (R la Sl).
    - intros pool2 j Sp2. rewrite Hp in Sp2. injection Sp2 as <-.
      apply sdyn_runs. intros x. apply runs_ld. exact (C j).
  Qed.

  Lemma xt_cou : forall ls m0, xf_cou (XT ls m0).
  Proof.
    intros ls m0 pool bcc hd k st0 st' g m' Hp Hbcc Hk HQ Hg V0 U HP' V1 (HX & A).
    split; [ exact (xr_cou ls pool bcc hd k st0 st' g m' Hp Hbcc Hk HQ Hg V0 U HP' V1 HX) | ].
    assert (Hbp : bcc <> pool) by (apply (SNE _ _ _ _ Hbcc Hp); idne).
    apply (ter_abd_tr G m0 g m' A); [ | intros pool2 la Sp2 Sl; exact (rings_some g pool2 la Hg Sp2 Sl) ].
    apply ter_abd_same.
    - apply tsa_ld. intros b Sb.
      apply (Mem.load_unchanged_on_1 _ _ _ _ _ _ U (sym_valid_P g _ _ Hg Sb)).
      intros z _. unfold BhvStep.Pfr. split.
      + apply (SNE _ _ _ _ Sb Hbcc); idne.
      + intros (E & _). apply (SNE _ _ _ _ Sb Hp); [ idne | exact E ].
    - intros pool2 la Sp2 Sl. rewrite Hp in Sp2. injection Sp2 as <-.
      exact (rings_unch pool bcc k g m' la Hp Hbcc Sl Hg U).
    - intros pool2 j Sp2. rewrite Hp in Sp2. injection Sp2 as <-.
      destruct (Z.eq_dec j k) as [-> | Njk].
      + exact (sdyn_Vo lp pool k g m' st0 st' V0 V1 HQ).
      + apply sdyn_runs. intros x. apply runs_ld. rewrite !ld32_load.
        apply (Mem.load_unchanged_on_1 _ _ _ _ _ _ U (sym_valid_P g _ _ Hg Hp)).
        intros z Hz. unfold BhvStep.Pfr. split; [ exact (fun E => Hbp (eq_sym E)) | intros (_ & Hz') ].
        unfold OW.O_CMD, OW.O_STK, OW.OSZ in *. cbn [size_chunk] in Hz. lia.
  Qed.

  (* ---- the ghost keeps PROVED here: an s16 store into slot k's
     graph-node flags (@2: BILLBOARD, DISABLE_RENDERING) keeps the ghost
     (ObjGfl.gfl_pc; the VM cells, the rings, the budgets, the gate) ---- *)
  Lemma gfl_g : forall XF, xf_st XF -> forall pool hd k st0 m m1 i,
    Genv.find_symbol G OLP._gObjectPool = Some pool -> 0 <= k < OW.NSLOT -> (List.length (v_k st0) <= 8)%nat ->
    ObjRows.GP lp bm bc oc0 SafeB pool (k * OW.OSZ) st0 (XF hd pool k) m ->
    Mem.store Mint16signed m pool (k * OW.OSZ + 2) (Vint i) = Some m1 ->
    ObjRows.GP lp bm bc oc0 SafeB pool (k * OW.OSZ) st0 (XF hd pool k) m1.
  Proof.
    intros XF Hxs pool hd k st0 m m1 i Hp Hk Hd (HP & HV & HX) S.
    assert (Hz : k * OW.OSZ <= k * OW.OSZ + 2 /\ k * OW.OSZ + 2 + size_chunk Mint16signed <= k * OW.OSZ + 4)
      by (cbn [size_chunk]; lia).
    pose proof (P_of_pc _ (ObjGfl.gfl_pc lp bm Hbm_sym bc oc0 SafeB Hbc_sym pool k Hp m m1 Mint16signed _ i
                             (pc_of_P _ HP) Hz S)) as HP1.
    split; [ exact HP1 | split ].
    - apply (vo_unch lp pool (k * OW.OSZ) m m1 st0 Hd); [ | exact HV ].
      apply (Mem.store_unchanged_on _ _ _ _ _ _ _ S). intros z Hz' (_ & Hz2).
      unfold OW.O_CMD in Hz2. cbn [size_chunk] in Hz'. lia.
    - apply (Hxs pool hd k m m1 Hp HP HP1); [ | | | exact HX ].
      + intros la Sl. apply (ObjGfl.gfl_rings pool k m m1 Mint16signed _ i Hz S la). apply (SNE _ _ _ _ Sl Hp); idne.
      + intros j. rewrite !ld32_load. apply (Mem.load_store_other _ _ _ _ _ _ S). right.
        unfold OW.OSZ, OW.O_CMD. cbn [size_chunk]. lia.
      + apply tsa_ld. intros b Sb. apply (Mem.load_store_other _ _ _ _ _ _ S). left. apply (SNE _ _ _ _ Sb Hp); idne.
  Qed.

  Lemma bb_g : forall XF, xf_st XF -> forall pool hd k st0,
    Genv.find_symbol G OLP._gObjectPool = Some pool -> 0 <= k < OW.NSLOT -> In st0 vm_tab ->
    BhvStep.bb_keep pool (k * OW.OSZ) (ObjRows.GP lp bm bc oc0 SafeB pool (k * OW.OSZ) st0 (XF hd pool k))
      (ObjFamily.Qfam (v_s st0)).
  Proof.
    intros XF Hxs pool hd k st0 Hp Hk H0 m st w old m1 HG _ _ _ _ _ S.
    exact (gfl_g XF Hxs pool hd k st0 m m1 _ Hp Hk (PK.vm_depth st0 H0) HG S).
  Qed.

  Lemma dr_g : forall XF, xf_st XF -> forall pool hd k st0,
    Genv.find_symbol G OLP._gObjectPool = Some pool -> 0 <= k < OW.NSLOT -> In st0 vm_tab ->
    BhvStep.dr_keep pool (k * OW.OSZ) (ObjRows.GP lp bm bc oc0 SafeB pool (k * OW.OSZ) st0 (XF hd pool k))
      (ObjFamily.Qfam (v_s st0)).
  Proof.
    intros XF Hxs pool hd k st0 Hp Hk H0 m st w old m1 HG _ _ _ _ _ S.
    exact (gfl_g XF Hxs pool hd k st0 m m1 _ Hp Hk (PK.vm_depth st0 H0) HG S).
  Qed.

  (* ---- the field form (ObjFld, 2026-11-08): a non-pointer store into
     slot k's bytes [d, n), off every frame read (the census windows of
     FieldWinCensus), keeps the ghost ---- *)
  Lemma fld_g : forall XF, xf_st XF -> forall pool hd k js st0 m m1 ch z0 v d n,
    Genv.find_symbol G OLP._gObjectPool = Some pool -> 0 <= k < OW.NSLOT -> 0 <= js < OW.NSLOT ->
    (List.length (v_k st0) <= 8)%nat ->
    (136 <= d /\ d <= n <= 460
     /\ forall off e, (e <= 156 \/ 160 <= off) -> (e <= 400 \/ 404 <= off) -> FieldWin.ucl off e ->
          e <= d \/ n <= off) ->
    js * OW.OSZ + d <= z0 /\ z0 + size_chunk ch <= js * OW.OSZ + n ->
    BhvStep.cvok (fun _ => False) ch v ->
    ObjRows.GP lp bm bc oc0 SafeB pool (k * OW.OSZ) st0 (XF hd pool k) m ->
    Mem.store ch m pool z0 v = Some m1 ->
    ObjRows.GP lp bm bc oc0 SafeB pool (k * OW.OSZ) st0 (XF hd pool k) m1.
  Proof.
    intros XF Hxs pool hd k js st0 m m1 ch z0 v d n Hp Hk Hj Hd Hdn Hz Hv (HP & HV & HX) S.
    pose proof (pc_of_P _ HP) as Hpc.
    assert (HP1 : Pobjl m1) by (apply P_of_pc; eapply ObjFld.fld_pc; eassumption).
    split; [ exact HP1 | split ].
    - apply (vo_unch lp pool (k * OW.OSZ) m m1 st0 Hd); [ | exact HV ].
      apply (Mem.store_unchanged_on _ _ _ _ _ _ _ S). intros z Hz' (_ & Hz2).
      destruct Hdn as (D1 & D2 & _). cbn [size_chunk] in Hz'. pose proof (size_chunk_pos ch).
      unfold OW.O_CMD, OW.OSZ, OW.NSLOT in *. lia.
    - apply (Hxs pool hd k m m1 Hp HP HP1); [ | | | exact HX ].
      + intros la Sl. eapply ObjFld.fld_rings; try eassumption. apply (SNE _ _ _ _ Sl Hp); idne.
      + intros j. rewrite !ld32_load. eapply ObjFld.fld_vm; try eassumption; unfold OW.O_CMD, OW.OSZ; cbn [size_chunk]; lia.
      + apply tsa_ld. intros b Sb. apply (Mem.load_store_other _ _ _ _ _ _ S). left. apply (SNE _ _ _ _ Sb Hp); idne.
  Qed.

  (* a census window field's 4 bytes *)
  Lemma fld_win_g : forall XF, xf_st XF -> forall pool hd k st0 m m1 ch f v,
    Genv.find_symbol G OLP._gObjectPool = Some pool -> 0 <= k < OW.NSLOT -> In st0 vm_tab ->
    In f FieldWinCensus.win_fields -> size_chunk ch <= 4 -> BhvStep.cvok (fun _ => False) ch v ->
    ObjRows.GP lp bm bc oc0 SafeB pool (k * OW.OSZ) st0 (XF hd pool k) m ->
    Mem.store ch m pool (k * OW.OSZ + 136 + 4 * f) v = Some m1 ->
    ObjRows.GP lp bm bc oc0 SafeB pool (k * OW.OSZ) st0 (XF hd pool k) m1.
  Proof.
    intros XF Hxs pool hd k st0 m m1 ch f v Hp Hk H0 Hf Hs Hv HG S.
    apply (fld_g XF Hxs pool hd k k st0 m m1 ch (k * OW.OSZ + 136 + 4 * f) v (136 + 4 * f) (140 + 4 * f) Hp Hk Hk (PK.vm_depth st0 H0)
             (ObjFld.field_dn f Hf)); [ lia | exact Hv | exact HG | exact S ].
  Qed.

  (* the census (FieldWinCensus): every reachable SET_FLOAT / ADD_INT /
     OR_INT / SET_INT_RAND_RSHIFT / ANIMATE_TEXTURE word writes a window
     field.  PERF TRAP: stated inline (see BhvStep.chk42_ok) *)
  Lemma win_ops_ok :
    forallb (fun st => if existsb (Z.eqb (opc st)) [14; 15; 17; 19; 51; 52]
                       then existsb (Z.eqb (byte2 (w0 st)))
                              [1; 3; 10; 12; 16; 18; 19; 20; 21; 22; 23; 26; 28; 29; 38; 40; 41; 47; 52;
                               55; 56; 57; 58; 59; 61; 67]
                       else true) vm_tab = true.
  Proof. vm_compute. reflexivity. Qed.

  Lemma win_op : forall st w, In st vm_tab -> word_at (v_s st) (v_i st) = Some w ->
    In (Z.shiftr w 24) [14; 15; 17; 19; 51; 52] -> In (byte2 w) FieldWinCensus.win_fields.
  Proof.
    intros st w Hst Hw Ho. pose proof win_ops_ok as A. rewrite forallb_forall in A. specialize (A st Hst).
    unfold opc, w0 in A. rewrite Hw in A.
    assert (E : existsb (Z.eqb (Z.shiftr w 24)) [14; 15; 17; 19; 51; 52] = true)
      by (apply existsb_exists; exists (Z.shiftr w 24); split; [ exact Ho | apply Z.eqb_refl ]).
    rewrite E in A. apply existsb_exists in A as (f & Hf & Ef). apply Z.eqb_eq in Ef.
    rewrite FieldWinCensus.win_fields_value, Ef. exact Hf.
  Qed.

  (* SET_INT's reachable fields: 5, 42, or a window *)
  Lemma set_ops_ok :
    forallb (fun st => if opc st =? 16
                       then existsb (Z.eqb (byte2 (w0 st)))
                              [5; 42; 1; 3; 10; 12; 16; 18; 19; 20; 21; 22; 23; 26; 28; 29; 38; 40; 41; 47; 52;
                               55; 56; 57; 58; 59; 61; 67]
                       else true) vm_tab = true.
  Proof. vm_compute. reflexivity. Qed.

  Lemma set_op : forall st w, In st vm_tab -> word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 16 ->
    byte2 w = 5 \/ byte2 w = 42 \/ In (byte2 w) FieldWinCensus.win_fields.
  Proof.
    intros st w Hst Hw Ho. pose proof set_ops_ok as A. rewrite forallb_forall in A. specialize (A st Hst).
    unfold opc, w0 in A. rewrite Hw, Ho in A. cbn [Z.eqb] in A.
    apply existsb_exists in A as (f & Hf & Ef). apply Z.eqb_eq in Ef.
    rewrite FieldWinCensus.win_fields_value, Ef.
    cbn [In] in Hf. destruct Hf as [<- | [<- | Hf]]; [ left; reflexivity | right; left; reflexivity | right; right; exact Hf ].
  Qed.

  Ltac wf_side := first [ rewrite FieldWinCensus.win_fields_value; cbn [In]; tauto
                        | cbn [size_chunk]; lia | exact I | cbn; exact I ].

  (* ---- the window-field ghost keeps PROVED (ObjFld + the census) ---- *)
  Lemma setf_g : forall XF, xf_st XF -> forall pool hd k st0,
    Genv.find_symbol G OLP._gObjectPool = Some pool -> 0 <= k < OW.NSLOT -> In st0 vm_tab ->
    BhvStep.setf_keep pool (k * OW.OSZ) (ObjRows.GP lp bm bc oc0 SafeB pool (k * OW.OSZ) st0 (XF hd pool k))
      (ObjFamily.Qfam (v_s st0)).
  Proof.
    intros XF Hxs pool hd k st0 Hp Hk H0 m st w m1 HG Hst _ Hw Ho S.
    refine (fld_win_g XF Hxs pool hd k st0 m m1 _ (byte2 w) _ Hp Hk H0 _ _ _ HG S); [ | wf_side | wf_side ].
    apply (win_op st w Hst Hw). rewrite Ho. cbn [In]. repeat (first [ left; reflexivity | right ]).
  Qed.

  Lemma addi_g : forall XF, xf_st XF -> forall pool hd k st0,
    Genv.find_symbol G OLP._gObjectPool = Some pool -> 0 <= k < OW.NSLOT -> In st0 vm_tab ->
    BhvStep.addi_keep pool (k * OW.OSZ) (ObjRows.GP lp bm bc oc0 SafeB pool (k * OW.OSZ) st0 (XF hd pool k))
      (ObjFamily.Qfam (v_s st0)).
  Proof.
    intros XF Hxs pool hd k st0 Hp Hk H0 m st w old m1 HG Hst _ Hw Ho _ S.
    refine (fld_win_g XF Hxs pool hd k st0 m m1 _ (byte2 w) _ Hp Hk H0 _ _ _ HG S); [ | wf_side | wf_side ].
    apply (win_op st w Hst Hw). rewrite Ho. cbn [In]. repeat (first [ left; reflexivity | right ]).
  Qed.

  Lemma ori_g : forall XF, xf_st XF -> forall pool hd k st0,
    Genv.find_symbol G OLP._gObjectPool = Some pool -> 0 <= k < OW.NSLOT -> In st0 vm_tab ->
    BhvStep.ori_keep pool (k * OW.OSZ) (ObjRows.GP lp bm bc oc0 SafeB pool (k * OW.OSZ) st0 (XF hd pool k))
      (ObjFamily.Qfam (v_s st0)).
  Proof.
    intros XF Hxs pool hd k st0 Hp Hk H0 m st w old m1 HG Hst _ Hw Ho _ S.
    refine (fld_win_g XF Hxs pool hd k st0 m m1 _ (byte2 w) _ Hp Hk H0 _ _ _ HG S); [ | wf_side | wf_side ].
    apply (win_op st w Hst Hw). rewrite Ho. cbn [In]. repeat (first [ left; reflexivity | right ]).
  Qed.

  Lemma atex_g : forall XF, xf_st XF -> forall pool hd k st0,
    Genv.find_symbol G OLP._gObjectPool = Some pool -> 0 <= k < OW.NSLOT -> In st0 vm_tab ->
    BhvStep.atex_keep pool (k * OW.OSZ) (ObjRows.GP lp bm bc oc0 SafeB pool (k * OW.OSZ) st0 (XF hd pool k))
      (ObjFamily.Qfam (v_s st0)).
  Proof.
    intros XF Hxs pool hd k st0 Hp Hk H0 m st w old m1 HG Hst _ Hw Ho _ S.
    refine (fld_win_g XF Hxs pool hd k st0 m m1 _ (byte2 w) _ Hp Hk H0 _ _ _ HG S); [ | wf_side | wf_side ].
    apply (win_op st w Hst Hw). rewrite Ho. cbn [In]. repeat (first [ left; reflexivity | right ]).
  Qed.

  (* SET_INT: field 5 (bytes 156..160, which both frames exclude) and the
     windows PROVED; field 42 is the residual set42_keep *)
  Lemma set_g : forall XF, xf_st XF -> forall pool hd k st0,
    Genv.find_symbol G OLP._gObjectPool = Some pool -> 0 <= k < OW.NSLOT -> In st0 vm_tab ->
    ObjRows.set42_keep lp bm bc oc0 SafeB pool (k * OW.OSZ) st0 (XF hd pool k) ->
    BhvStep.set_keep pool (k * OW.OSZ) (ObjRows.GP lp bm bc oc0 SafeB pool (k * OW.OSZ) st0 (XF hd pool k))
      (ObjFamily.Qfam (v_s st0)).
  Proof.
    intros XF Hxs pool hd k st0 Hp Hk H0 K42 m st w m1 HG Hst HQ Hw Ho S.
    destruct (set_op st w Hst Hw Ho) as [E5 | [E42 | Hf]].
    - rewrite E5 in S.
      refine (fld_g XF Hxs pool hd k k st0 m m1 _ _ _ 156 160 Hp Hk Hk (PK.vm_depth st0 H0) _ _ _ HG S);
        [ | cbn [size_chunk]; lia | exact I ].
      split; [ lia | split; [ lia | ] ]. intros off e A _ _. exact A.
    - rewrite E42 in S. exact (K42 m st w m1 HG Hst HQ Hw Ho E42 S).
    - refine (fld_win_g XF Hxs pool hd k st0 m m1 _ (byte2 w) _ Hp Hk H0 Hf _ _ HG S); wf_side.
  Qed.

  (* PARENT_BIT_CLEAR: the store into the PARENT's field 22 (a window).
     The parent is a whole slot: obj_w's par_ok (clause 1) makes slot k's
     non-NULL parentObj a slot_v *)
  Lemma pbc_g : forall XF, xf_st XF -> forall pool hd k st0,
    Genv.find_symbol G OLP._gObjectPool = Some pool -> 0 <= k < OW.NSLOT -> In st0 vm_tab ->
    BhvStep.pbc_keep pool (k * OW.OSZ) (ObjRows.GP lp bm bc oc0 SafeB pool (k * OW.OSZ) st0 (XF hd pool k))
      (ObjFamily.Qfam (v_s st0)).
  Proof.
    intros XF Hxs pool hd k st0 Hp Hk H0 m st w po a old m1 HG Hst _ Hw Ho Lp Hpo _ _ _ S.
    pose proof HG as ((_ & _ & _ & _ & _ & How) & _).
    pose proof How as (pool' & la & fl & gol & gmo' & sdp & gdi & rs & fs & S1 & S2 & S3 & S4 & S5 & S6 & S7 & C).
    rewrite Hp in S1. injection S1 as <-.
    destruct (OW.ow_par _ _ _ _ _ _ _ _ _ _ _ _ C) as (P1 & _).
    unfold OW.O_PARENT in P1.
    destruct (P1 k Hk) as [Lz | (j & Hj & Lj)]; rewrite Lp in *; [ discriminate Lz | ].
    unfold OW.slot_v in Lj. assert (Ej : Ptrofs.repr po = Ptrofs.repr (j * OW.OSZ))
      by exact (f_equal (fun ov => match ov with Some (Vptr _ o) => o | _ => Ptrofs.zero end) Lj).
    assert (Epo : po = j * OW.OSZ).
    { apply (f_equal Ptrofs.unsigned) in Ej.
      rewrite !Ptrofs.unsigned_repr in Ej by (change Ptrofs.max_unsigned with 4294967295; unfold OW.OSZ, OW.NSLOT in *; lia).
      exact Ej. }
    subst po.
    refine (fld_g XF Hxs pool hd k j st0 m m1 _ _ _ (136 + 4 * byte2 w) (140 + 4 * byte2 w) Hp Hk Hj
              (PK.vm_depth st0 H0) _ _ _ HG S); [ | cbn [size_chunk]; lia | exact I ].
    apply ObjFld.field_dn. apply (win_op st w Hst Hw). rewrite Ho. cbn [In]. repeat (first [ left; reflexivity | right ]).
  Qed.

  Lemma home_g : forall XF, xf_st XF -> forall pool hd k st0,
    Genv.find_symbol G OLP._gObjectPool = Some pool -> 0 <= k < OW.NSLOT -> In st0 vm_tab ->
    BhvStep.home_keep pool (k * OW.OSZ) (ObjRows.GP lp bm bc oc0 SafeB pool (k * OW.OSZ) st0 (XF hd pool k))
      (ObjFamily.Qfam (v_s st0)).
  Proof.
    intros XF Hxs pool hd k st0 Hp Hk H0 m st w f1 f2 f3 m1 m2 m3 HG _ _ _ _ _ S1 _ S2 _ S3.
    refine (fld_win_g XF Hxs pool hd k st0 m2 m3 _ 57 _ Hp Hk H0 _ _ _ _ S3); [ wf_side | wf_side | wf_side | ].
    refine (fld_win_g XF Hxs pool hd k st0 m1 m2 _ 56 _ Hp Hk H0 _ _ _ _ S2); [ wf_side | wf_side | wf_side | ].
    refine (fld_win_g XF Hxs pool hd k st0 m m1 _ 55 _ Hp Hk H0 _ _ _ HG S1); [ wf_side | wf_side | wf_side ].
  Qed.

  Lemma phys_g : forall XF, xf_st XF -> forall pool hd k st0,
    Genv.find_symbol G OLP._gObjectPool = Some pool -> 0 <= k < OW.NSLOT -> In st0 vm_tab ->
    BhvStep.phys_keep pool (k * OW.OSZ) (ObjRows.GP lp bm bc oc0 SafeB pool (k * OW.OSZ) st0 (XF hd pool k))
      (ObjFamily.Qfam (v_s st0)).
  Proof.
    intros XF Hxs pool hd k st0 Hp Hk H0 m st w z1 z2 z3 m1 m2 m3 m4 m5 m6 HG _ _ _ _ _ _ _ S1 S2 S3 S4 S5 S6.
    refine (fld_win_g XF Hxs pool hd k st0 m5 m6 _ 59 _ Hp Hk H0 _ _ _ _ S6); [ wf_side | wf_side | wf_side | ].
    refine (fld_win_g XF Hxs pool hd k st0 m4 m5 _ 58 _ Hp Hk H0 _ _ _ _ S5); [ wf_side | wf_side | wf_side | ].
    refine (fld_win_g XF Hxs pool hd k st0 m3 m4 _ 41 _ Hp Hk H0 _ _ _ _ S4); [ wf_side | wf_side | wf_side | ].
    refine (fld_win_g XF Hxs pool hd k st0 m2 m3 _ 52 _ Hp Hk H0 _ _ _ _ S3); [ wf_side | wf_side | wf_side | ].
    refine (fld_win_g XF Hxs pool hd k st0 m1 m2 _ 23 _ Hp Hk H0 _ _ _ _ S2); [ wf_side | wf_side | wf_side | ].
    refine (fld_win_g XF Hxs pool hd k st0 m m1 _ 40 _ Hp Hk H0 _ _ _ HG S1); [ wf_side | wf_side | wf_side ].
  Qed.

  (* ---- cur_obj_update on slot k: entry, cou_real, exit ---- *)
  Theorem cou_step_g : forall XF, xf_cou XF -> xf_st XF -> cou_keeps_g XF ->
    forall ls go pool hd k m t m' vr,
      Genv.find_symbol G BS._gCurrentObject = Some go -> Genv.find_symbol G OLP._gObjectPool = Some pool ->
      0 <= k < OW.NSLOT -> Pobjl m -> XR ls hd pool k m -> XF hd pool k m -> BhvStep.cur go pool (k * OW.OSZ) m ->
      eval_funcall function_entry2 G m (Internal BS.f_cur_obj_update) [] t m' vr ->
      Pobjl m' /\ XF hd pool k m'.
  Proof.
    intros XF Hxc Hxs K ls go pool hd k m t m' vr Hgo Hp Hk HP HX HF Hc Hev.
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
    destruct (K go pool bcc sb hd k st0 (Mem.nextblock m) Hgo Hp Hbcc Hsb Hk Hst0) as (GKr & RK & KPRE & KPOST).
    pose proof (ObjRows.ghost_keeps_of lp bm bc oc0 SafeB go pool (k * OW.OSZ) sb st0 (XF hd pool k)
                  (set_g XF Hxs pool hd k st0 Hp Hk Hst0 (proj1 GKr))
                  (bb_g XF Hxs pool hd k st0 Hp Hk Hst0) (dr_g XF Hxs pool hd k st0 Hp Hk Hst0)
                  (setf_g XF Hxs pool hd k st0 Hp Hk Hst0) (addi_g XF Hxs pool hd k st0 Hp Hk Hst0)
                  (ori_g XF Hxs pool hd k st0 Hp Hk Hst0) (atex_g XF Hxs pool hd k st0 Hp Hk Hst0)
                  (pbc_g XF Hxs pool hd k st0 Hp Hk Hst0)
                  (home_g XF Hxs pool hd k st0 Hp Hk Hst0) (phys_g XF Hxs pool hd k st0 Hp Hk Hst0) GKr) as GK.
    pose proof (ObjInv.inv_entry lp bm bc oc0 SafeB go pool (k * OW.OSZ) bcc st0 (Mem.nextblock m) (XF hd pool k) m
                  eq_refl HP HV0 Hc HF) as HI.
    pose proof (ObjRows.rows_k lp bm bc oc0 SafeB go pool (k * OW.OSZ) bcc sb Hbcc Hp Hpg Hbp st0 (Mem.nextblock m)
                  (XF hd pool k) Hsp Hsc Hsg Hoc (PK.vm_depth st0 Hst0) GK RK) as KR.
    destruct (BhvStep.cou_real lp H12 go pool (k * OW.OSZ) Hgo Hoc Hpg bcc Hbcc Hbp Hbg Hps sb Hsb
                (fun E => Hsp (eq_sym E))
                (INV go pool (k * OW.OSZ) bcc st0 (Mem.nextblock m) (XF hd pool k)) (ObjFamily.Qfam (v_s st0))
                (ObjFamily.Qfam_closed (v_s st0))
                (ObjInv.inv_scr lp bm bc oc0 SafeB go pool (k * OW.OSZ) bcc Hbcc Hp Hpg Hbg Hps st0 (Mem.nextblock m) (XF hd pool k))
                (ObjInv.inv_cur lp bm bc oc0 SafeB go pool (k * OW.OSZ) bcc st0 (Mem.nextblock m) (XF hd pool k))
                (ObjInv.inv_frame lp bm bc oc0 SafeB go pool (k * OW.OSZ) bcc Hpg Hbg st0 (Mem.nextblock m) (XF hd pool k))
                Hsq Hp (fun _ => SafeB) KR KPRE KPOST
                (ObjInv.inv_free lp bm bc oc0 SafeB go pool (k * OW.OSZ) bcc Hgo Hpg Hbg st0 (Mem.nextblock m) (XF hd pool k))
                m t m' vr st0 Hst0 HQ0 HV0 HI Hev) as (st' & Hst' & HQ' & HV' & HI').
    pose proof (ObjExit.inv_exit lp bm bc oc0 SafeB go pool bcc k st0 (Mem.nextblock m) (XF hd pool k) m' st'
                  Hbm_sym Hbc_sym Hp Hbcc HSafeB_scr Hst0 Hst' HQ' HI' HV') as HP'.
    split; [ exact HP' | ].
    destruct HI' as (_ & _ & g & Hg & HVg & _ & U & _ & HXg).
    exact (Hxc pool bcc hd k st0 st' g m' Hp Hbcc Hk HQ' Hg HVg U HP' HV' HXg).
  Qed.

  Theorem cou_step : forall ls, cou_keeps ls ->
    forall go pool hd k m t m' vr,
      Genv.find_symbol G BS._gCurrentObject = Some go -> Genv.find_symbol G OLP._gObjectPool = Some pool ->
      0 <= k < OW.NSLOT -> Pobjl m -> XR ls hd pool k m -> BhvStep.cur go pool (k * OW.OSZ) m ->
      eval_funcall function_entry2 G m (Internal BS.f_cur_obj_update) [] t m' vr ->
      Pobjl m' /\ XR ls hd pool k m'.
  Proof.
    intros ls K go pool hd k m t m' vr Hgo Hp Hk HP HX Hc Hev.
    exact (cou_step_g (XR ls) (xr_cou ls) (xr_st ls) K ls go pool hd k m t m' vr Hgo Hp Hk HP HX HX Hc Hev).
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

  Lemma gco_side : forall go pool m m1 v, Genv.find_symbol G BS._gCurrentObject = Some go ->
    Genv.find_symbol G OLP._gObjectPool = Some pool -> Mem.store Mint32 m go 0 v = Some m1 ->
    (forall j, OW.ld32 m1 pool (j * OW.OSZ + OW.O_CMD) = OW.ld32 m pool (j * OW.OSZ + OW.O_CMD))
    /\ OW.tsa G m1 = OW.tsa G m.
  Proof.
    intros go pool m m1 v Hgo Hp S. split.
    - intros j. rewrite !ld32_load. apply (Mem.load_store_other _ _ _ _ _ _ S). left.
      apply (SNE _ _ _ _ Hp Hgo); idne.
    - apply tsa_ld. intros b Sb. apply (Mem.load_store_other _ _ _ _ _ _ S). left.
      apply (SNE _ _ _ _ Sb Hgo); idne.
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

  Lemma flg_side : forall pool k m m1 i, Genv.find_symbol G OLP._gObjectPool = Some pool ->
    Mem.store Mint16signed m pool (k * OW.OSZ + 2) (Vint i) = Some m1 ->
    (forall j, OW.ld32 m1 pool (j * OW.OSZ + OW.O_CMD) = OW.ld32 m pool (j * OW.OSZ + OW.O_CMD))
    /\ OW.tsa G m1 = OW.tsa G m.
  Proof.
    intros pool k m m1 i Hp S. split.
    - intros j. rewrite !ld32_load. apply (Mem.load_store_other _ _ _ _ _ _ S). right.
      unfold OW.OSZ, OW.O_CMD. cbn [size_chunk]. lia.
    - apply tsa_ld. intros b Sb. apply (Mem.load_store_other _ _ _ _ _ _ S). left.
      apply (SNE _ _ _ _ Sb Hp); idne.
  Qed.

  Lemma ring_slot : forall ls m hd v, ObjLoop.in_ring_l G bm ls m hd v ->
    exists pool k, Genv.find_symbol G OLP._gObjectPool = Some pool /\ 0 <= k < OW.NSLOT /\ v = OW.slot_v pool k.
  Proof.
    intros ls m hd v ((pool & la & rs & i & k & (Sp & Sl & (fl & gol & gmo & sdp & gdi & fs & S3 & S4 & S5 & S6 & S7 & C))
                       & Hi & _ & Hk & Ev) & _).
    exists pool, k. split; [ exact Sp | split; [ | exact Ev ] ].
    exact (ObjLoop.ring_k m pool la rs i k (OW.ow_rings _ _ _ _ _ _ _ _ _ _ _ _ C) Hi Hk).
  Qed.

  (* the flag store and the call, from gCurrentObject = slot k *)
  Lemma upd_step_g : forall XF, xf_cou XF -> xf_st XF -> cou_keeps_g XF ->
    forall ls go pool hd k ta tb tc le m t1 le1 m1 t2 le2 m2 out,
    Genv.find_symbol G BS._gCurrentObject = Some go -> Genv.find_symbol G OLP._gObjectPool = Some pool ->
    0 <= k < OW.NSLOT -> tc <> ta ->
    Pobjl m -> XR ls hd pool k m -> XF hd pool k m -> BhvStep.cur go pool (k * OW.OSZ) m ->
    exec_stmt function_entry2 G empty_env le m (FLG ta tb tc (OR5 tc)) t1 le1 m1 Out_normal ->
    exec_stmt function_entry2 G empty_env le1 m1 CALL t2 le2 m2 out ->
    Pobjl m2 /\ XF hd pool k m2 /\ out = Out_normal.
  Proof.
    intros XF Hxc Hxs K ls go pool hd k ta tb tc le m t1 le1 m1 t2 le2 m2 out Hgo Hp Hk Hne HP HX HF Hc X1 X2.
    assert (Hpg : pool <> go) by (apply (SNE _ _ _ _ Hp Hgo); idne).
    assert (Hoc : 0 <= k * OW.OSZ <= 145312) by (unfold OW.OSZ, OW.NSLOT in *; lia).
    destruct (x_flg go pool _ ta tb tc (OR5 tc) le m t1 le1 m1 _ Hgo Hoc Hpg Hne eq_refl Hc X1) as (i & S & _).
    destruct (flg_step go pool k m m1 i Hp Hpg S HP Hc) as (HP1 & Hc1 & R1).
    destruct (flg_side pool k m m1 i Hp S) as (C1 & T1).
    destruct (x_call _ _ _ _ _ _ X2) as ((vr & Hev) & ->).
    destruct (cou_step_g XF Hxc Hxs K ls go pool hd k m1 t2 m2 vr Hgo Hp Hk HP1 (xr_tr ls hd pool k m m1 HX HP1 R1 Hp)
                (Hxs pool hd k m m1 Hp HP HP1 R1 C1 T1 HF) Hc1 Hev) as (HP' & HF').
    exact (conj HP' (conj HF' eq_refl)).
  Qed.

  (* ---- THE REST ROWS, for any carried ghost fact ---- *)
  Theorem rest_saX : forall XF, xf_cou XF -> xf_st XF -> cou_keeps_g XF ->
    forall ls hd pool k le m t le' m' out,
    Genv.find_symbol G OLP._gObjectPool = Some pool -> 0 <= k < OW.NSLOT ->
    Pobjl m -> XR ls hd pool k m -> XF hd pool k m -> le ! OLP._firstObj = Some (OW.slot_v pool k) ->
    exec_stmt function_entry2 G empty_env le m
      (ObjLoop.app_seq (ObjLoop.loop_pre OLP.f_update_objects_starting_at) Sskip) t le' m' out ->
    Pobjl m' /\ XF hd pool k m'.
  Proof.
    intros XF Hxc Hxs K ls hd pool k le m t le' m' out Hp Hk HP Hin HF Hv Hx.
    rewrite sa_shape in Hx.
    assert (Hpt : exists b o, OW.slot_v pool k = Vptr b o) by (eexists; eexists; reflexivity).
    apply RA.seq_inv in Hx as [(t1 & le1 & m1 & t2 & X1 & X2) | (X1 & Xn)];
      [ | exfalso; destruct (x_gco _ _ _ _ _ _ _ Hv Hpt X1) as (_ & _ & _ & _ & E); exact (Xn E) ].
    destruct (x_gco _ _ _ _ _ _ _ Hv Hpt X1) as (go & Hgo & S1 & -> & _).
    destruct (gco_step go pool k m m1 Hgo Hp S1 HP) as (HP1 & Hc1 & R1).
    destruct (gco_side go pool m m1 _ Hgo Hp S1) as (C1 & T1).
    pose proof (xr_tr ls hd pool k m m1 Hin HP1 R1 Hp) as HX1.
    pose proof (Hxs pool hd k m m1 Hp HP HP1 R1 C1 T1 HF) as HF1.
    assert (Hpg : pool <> go) by (apply (SNE _ _ _ _ Hp Hgo); idne).
    assert (Hoc : 0 <= k * OW.OSZ <= 145312) by (unfold OW.OSZ, OW.NSLOT in *; lia).
    assert (Hne : OLP._t'3 <> OLP._t'1) by idne.
    apply RA.seq_inv in X2 as [(t3 & le3 & m3 & t4 & X3 & X4) | (X3 & Xn)];
      [ | exfalso; destruct (x_flg go pool _ _ _ _ (OR5 OLP._t'3) _ _ _ _ _ _ Hgo Hoc Hpg Hne eq_refl Hc1 X3) as (_ & _ & E);
          exact (Xn E) ].
    apply RA.seq_inv in X4 as [(t5 & le5 & m5 & t6 & X5 & X6) | (X5 & Xn)];
      [ | exfalso; destruct (x_call _ _ _ _ _ _ X5) as (_ & E); exact (Xn E) ].
    inv X6.
    destruct (upd_step_g XF Hxc Hxs K ls go pool hd k _ _ _ _ _ _ _ _ _ _ _ _ Hgo Hp Hk Hne HP1 HX1 HF1 Hc1 X3 X5)
      as (HP' & HF' & _).
    exact (conj HP' HF').
  Qed.

  Theorem rest_tsX : forall XF, xf_cou XF -> xf_st XF -> cou_keeps_g XF ->
    forall ls hd pool k le m t le' m' out,
    Genv.find_symbol G OLP._gObjectPool = Some pool -> 0 <= k < OW.NSLOT ->
    Pobjl m -> XR ls hd pool k m -> XF hd pool k m -> le ! OLP._firstObj = Some (OW.slot_v pool k) ->
    exec_stmt function_entry2 G empty_env le m
      (ObjLoop.app_seq (ObjLoop.loop_pre OLP.f_update_objects_during_time_stop) Sskip) t le' m' out ->
    Pobjl m' /\ XF hd pool k m'.
  Proof.
    intros XF Hxc Hxs K ls hd pool k le m t le' m' out Hp Hk HP Hin HF Hv Hx.
    change (ObjLoop.loop_pre OLP.f_update_objects_during_time_stop) with TSL in Hx.
    rewrite ts_shape in Hx. destruct ts_pure as (P1 & P2).
    assert (Hpt : exists b o, OW.slot_v pool k = Vptr b o) by (eexists; eexists; reflexivity).
    apply RA.seq_inv in Hx as [(t1 & le1 & m1 & t2 & X1 & X2) | (X1 & Xn)];
      [ | exfalso; destruct (x_gco _ _ _ _ _ _ _ Hv Hpt X1) as (_ & _ & _ & _ & E); exact (Xn E) ].
    destruct (x_gco _ _ _ _ _ _ _ Hv Hpt X1) as (go & Hgo & S1 & -> & _).
    destruct (gco_step go pool k m m1 Hgo Hp S1 HP) as (HP1 & Hc1 & R1).
    destruct (gco_side go pool m m1 _ Hgo Hp S1) as (C1 & T1).
    pose proof (xr_tr ls hd pool k m m1 Hin HP1 R1 Hp) as HX1.
    pose proof (Hxs pool hd k m m1 Hp HP HP1 R1 C1 T1 HF) as HF1.
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
      + destruct (upd_step_g XF Hxc Hxs K ls go pool hd k _ _ _ _ _ _ _ _ _ _ _ _ Hgo Hp Hk Hne8 HP1 HX1 HF1 Hc1 XA XB)
          as (HP' & HF' & _).
        exact (conj HP' HF').
      + exfalso.
        destruct (x_flg go pool _ _ _ _ (OR5 OLP._t'8) _ _ _ _ _ _ Hgo Hoc Hpg Hne8 eq_refl Hc1 XA) as (_ & _ & E).
        exact (Xn E).
    - destruct (x_flg go pool _ _ _ _ (AND5 OLP._t'5) _ _ _ _ _ _ Hgo Hoc Hpg Hne5 eq_refl Hc1 XX) as (i & S & _).
      destruct (flg_step go pool k m1 _ i Hp Hpg S HP1 Hc1) as (HP2 & _ & R2).
      destruct (flg_side pool k m1 _ i Hp S) as (C2 & T2).
      exact (conj HP2 (Hxs pool hd k m1 _ Hp HP1 HP2 R2 C2 T2 HF1)).
  Qed.

  (* ---- THE NON-TERRAIN REST ROWS (XF := XR) ---- *)
  Theorem rest_sa : forall ls, cou_keeps ls ->
    ObjStepSplit.step_rest_row G bm Pobjl (ObjLoop.in_ring_l G bm ls) OLP.f_update_objects_starting_at.
  Proof.
    intros ls K hd v le m t le' m' out HP Hin Hv _ Hx _.
    destruct (ring_slot ls m hd v Hin) as (pool & k & Hp & Hk & ->).
    exact (rest_saX (XR ls) (xr_cou ls) (xr_st ls) K ls hd pool k le m t le' m' out Hp Hk HP Hin Hin Hv Hx).
  Qed.

  Theorem rest_ts : forall ls, cou_keeps ls ->
    ObjStepSplit.step_rest_row G bm Pobjl (ObjLoop.in_ring_l G bm ls) OLP.f_update_objects_during_time_stop.
  Proof.
    intros ls K hd v le m t le' m' out HP Hin Hv _ Hx _.
    destruct (ring_slot ls m hd v Hin) as (pool & k & Hp & Hk & ->).
    exact (rest_tsX (XR ls) (xr_cou ls) (xr_st ls) K ls hd pool k le m t le' m' out Hp Hk HP Hin Hin Hv Hx).
  Qed.

  (* ---- THE TERRAIN REST ROWS (XF := XT, from the step's start m):
     ter_post's (a), (b), (d) are carried by the ghost; (c), the counter,
     is the counter row ter_ctr_row ---- *)
  Theorem ter_rest_sa : cou_keeps_t ObjLoop.ter_ls -> ter_ctr_row G bm Pobjl OLP.f_update_objects_starting_at ->
    ObjStepSplit.ter_rest_row G bm Pobjl OLP.f_update_objects_starting_at.
  Proof.
    intros K Cr hd v le m t le' m' out HP Hin Hb Hv Hh Hx Ha.
    pose proof (Cr hd v le m t le' m' out HP Hin Hb Hv Hh Hx Ha) as Hc.
    destruct (ring_slot ObjLoop.ter_ls m hd v Hin) as (pool & k & Hp & Hk & ->).
    destruct (rest_saX (XT ObjLoop.ter_ls m) (xt_cou ObjLoop.ter_ls m) (xt_st ObjLoop.ter_ls m) (K m)
                ObjLoop.ter_ls hd pool k le m t le' m' out Hp Hk HP Hin (conj Hin (ter_abd_refl G m)) Hv Hx)
      as (HP' & HX' & A).
    exact (conj HP' (conj HX' (ter_post_of G m m' _ A Hc))).
  Qed.

  Theorem ter_rest_ts : cou_keeps_t ObjLoop.ter_ls -> ter_ctr_row G bm Pobjl OLP.f_update_objects_during_time_stop ->
    ObjStepSplit.ter_rest_row G bm Pobjl OLP.f_update_objects_during_time_stop.
  Proof.
    intros K Cr hd v le m t le' m' out HP Hin Hb Hv Hh Hx Ha.
    pose proof (Cr hd v le m t le' m' out HP Hin Hb Hv Hh Hx Ha) as Hc.
    destruct (ring_slot ObjLoop.ter_ls m hd v Hin) as (pool & k & Hp & Hk & ->).
    destruct (rest_tsX (XT ObjLoop.ter_ls m) (xt_cou ObjLoop.ter_ls m) (xt_st ObjLoop.ter_ls m) (K m)
                ObjLoop.ter_ls hd pool k le m t le' m' out Hp Hk HP Hin (conj Hin (ter_abd_refl G m)) Hv Hx)
      as (HP' & HX' & A).
    exact (conj HP' (conj HX' (ter_post_of G m m' _ A Hc))).
  Qed.
End STEP.

(* ---------------------------------------------------------------------- *)
(* 5. The scripts are SafeB: SafeB_syms_ok (d) names behavior_data's       *)
(*    globals, and every script of the VM table is one (vm).               *)
(* ---------------------------------------------------------------------- *)
Lemma fb_mem : forall (P : ident -> bool) (l : list ident), forallb P l = true ->
  forall s, In s l -> P s = true.
Proof. intros P l H s Hs. exact (proj1 (forallb_forall P l) H s Hs). Qed.

Lemma scr_bd_b : forallb (fun s => CensusV2.mem_id s SpawnInit.bhv_data_syms) (map v_s vm_tab) = true.
Proof. vm_compute. reflexivity. Qed.

Theorem scr_safe : forall lp (SafeB : block -> Prop),
  (forall id b, CensusV2.mem_id id SpawnInit.bhv_data_syms = true ->
     Genv.find_symbol (lp_ge lp) id = Some b -> SafeB b) ->
  forall b, BhvStep.scr_b lp b -> SafeB b.
Proof.
  intros lp SafeB H b (s & Hs & Hf).
  exact (H s b (fb_mem (fun s => CensusV2.mem_id s SpawnInit.bhv_data_syms) (map v_s vm_tab) scr_bd_b s Hs) Hf).
Qed.
