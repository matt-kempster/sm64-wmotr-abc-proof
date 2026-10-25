(* ====================================================================== *)
(* PoleRow (GOAL 2): the pole rows' shared pieces.                         *)
(*                                                                        *)
(* The walk environment Epl (CannonRow's), WMotR's low pole (pole_low),    *)
(* the grab and holding handlers' label facts, and the rest predicate     *)
(* LedgeRow builds on.  The pole rows themselves are PoleRowT.pole_rowT   *)
(* (2026-10-23: walked with the real animation data, keeping               *)
(* AnimWorld.anim_w); the earlier PoleRow.pole_row, which could not keep  *)
(* the animation world, is retired.                                       *)
(* ====================================================================== *)

From Coq Require Import List ZArith Lia Reals Lra.
From compcert Require Import Coqlib Maps AST Integers Floats Values Memory Events Globalenvs
  Ctypes Clight ClightBigstep Linking.
From SM64.Generated Require mario_step mario mario_actions_airborne mario_actions_automatic memory
  surface_collision level_update camera.
From SM64.Proofs Require Import Interp.SymExec2 Interp.LinkGenv MarioModel.LinkedTwelve
  MarioModel.OsDmaFloor HeightInvariant HeightMoveCatalog WMotRLevel WMotRWorld.
From SM64.Proofs Require Import RealFrameLinked AirborneSurface NoAImpliesNoFlyLinked.
From SM64.Proofs.WMotRRequiresA Require Import FloorList FloorExec AirRun AirStart AirMatch
  ExtInert FfRun FfWorld FrameSplit AirSplit FfKeepCheck FfKeep FfClass KbRun
  PoleXc PoleClass PoleKeep PoleSound PoleRun.
From SM64.Proofs.WMotRRequiresA Require KbRow FloorHeight.
From SM64.Proofs Require Import Generic.ClosedMem Generic.ClightClosed.
From SM64.Proofs Require Generic.SymbolicLinking.
Import ListNotations.

Module AUT := mario_actions_automatic.

Lemma dm_bt : (prog_defmap AUT.prog) ! AUT._bhvTree = Some (Gvar AUT.v_bhvTree).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_gpo : (prog_defmap AUT.prog) ! AUT._bhvGiantPole = Some (Gvar AUT.v_bhvGiantPole).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_lv : (prog_defmap AUT.prog) ! AUT._gCurrLevelNum = Some (Gvar AUT.v_gCurrLevelNum).
Proof. vm_compute. reflexivity. Qed.
Lemma lv_ident : AUT._gCurrLevelNum = mario._gCurrLevelNum.
Proof. reflexivity. Qed.

(* the world fact with more pointers into blocks already on the list *)
Lemma Wff_rblk : forall G m gp sz vs vs', (forall b, rblk vs' b -> rblk vs b) ->
  Wff G m gp sz vs -> Wff G m gp sz vs'.
Proof.
  intros G m gp sz vs vs' Hr (W1 & W2 & W3 & W4 & W5 & W6 & W7).
  refine (conj W1 (conj _ (conj _ (conj _ (conj W5 (conj W6 W7)))))).
  - intros id bp Hin Hs. destruct (W2 id bp Hin Hs) as (A & B & C). split; [exact A |].
    split; [intros H; exact (B (Hr _ H)) | exact C].
  - intros hd Hh. eapply FloorHeight.wf_weaken; [exact (W3 hd Hh) |].
    intros b _ N [A | A]; apply N; [left; exact A | right; exact (Hr _ A)].
  - intros hd s Hh Ho. destruct (W4 hd s Hh Ho) as (b & o & E1 & A & B & C & D).
    exists b, o. repeat split; try assumption. intros H; exact (C (Hr _ H)).
Qed.

Lemma rblk_app1 : forall vs b o b', rblk vs b -> rblk (vs ++ [Some (Vptr b o)]) b' -> rblk vs b'.
Proof.
  intros vs b o b' Hb (o' & Hin). apply in_app_or in Hin as [Hin | [Hin | []]].
  - exists o'. exact Hin.
  - injection Hin as <- _. exact Hb.
Qed.

Lemma pole_low : forall base top, In (base, top) wmotr_pole_list -> top + 160 <= 2424 ->
  base = (-2739)%Z /\ top = (-1919)%Z.
Proof.
  intros base top Hin Ht. rewrite pole_list_value in Hin.
  repeat (destruct Hin as [Hin | Hin]; [injection Hin as <- <-; (split; reflexivity) || lia |]).
  destruct Hin.
Qed.

Lemma kv_polepos : forall acn g, init_cell (kvP acn g) RO POLEPOS_OFF Mfloat32 = Sinit RO POLEPOS_OFF Mfloat32.
Proof. intros. reflexivity. Qed.

Section POLEROW.
Variable lp : Clight.program.
Hypothesis H12 : linked12 lp.
Local Notation G := (globalenv lp).

Variable bm : block.
Hypothesis Hbm : Genv.find_symbol G level_update._gMarioStates = Some bm.

(* the walk's environment *)
Definition Epl (bo bfi bmiss bcalls bsin ab bt biom bmq brm bau blk bpc bsr bsrc bsms bbs bfa bbt bgp blv : block) (oo uo : ptrofs) : senv :=
  mke (fun r => if Pos.eqb r RM then bm else if Pos.eqb r RO then bo
                else if Pos.eqb r RFI then bfi else if Pos.eqb r RMISS then bmiss
                else if Pos.eqb r RCALLS then bcalls else if Pos.eqb r RSIN then bsin
                else if Pos.eqb r RLD then ab else if Pos.eqb r RBUF then bt
                else if Pos.eqb r RIOM then biom else if Pos.eqb r RMQ then bmq
                else if Pos.eqb r RRM then brm else if Pos.eqb r RAR then bau
                else if Pos.eqb r RLK then blk else if Pos.eqb r RPC then bpc
                else if Pos.eqb r RSR then bsr else if Pos.eqb r RSRC then bsrc
                else if Pos.eqb r RSMS then bsms else if Pos.eqb r RBS then bbs else if Pos.eqb r RFA then bfa
                else if Pos.eqb r RU then bo else if Pos.eqb r RBT then bbt
                else if Pos.eqb r RGP then bgp else if Pos.eqb r RLV then blv else bm)
      (fun r => if Pos.eqb r RO then oo else if Pos.eqb r RU then uo else Ptrofs.zero)
      (fun _ => None).

Lemma r0p_size : forall r sz, r0_size (R0P G) r = Some sz ->
  (r = RM /\ sz = szs G mario._MarioState) \/ (r = RO /\ sz = szs G mario._Object)
  \/ (r = RFI /\ sz = 2) \/ (r = RMISS /\ sz = 4) \/ (r = RCALLS /\ sz = 6)
  \/ (r = RLD /\ sz = szs G mario._DmaHandlerList) \/ (r = RBUF /\ sz = Ptrofs.modulus)
  \/ (r = RIOM /\ sz = 20) \/ (r = RMQ /\ sz = 24) \/ (r = RRM /\ sz = 4)
  \/ (r = RLK /\ sz = szs G camera._LakituState) \/ (r = RPC /\ sz = SZ_PCS)
  \/ (r = RSR /\ sz = Ptrofs.modulus) \/ (r = RSRC /\ sz = Ptrofs.modulus)
  \/ (r = RSMS /\ sz = Ptrofs.modulus) \/ (r = RBS /\ sz = Ptrofs.modulus)
  \/ (r = RFA /\ sz = Ptrofs.modulus)
  \/ (r = RU /\ sz = szs G mario._Object).
Proof.
  intros r sz H. unfold r0_size, R0P, R0F in H. cbn [app find fst] in H.
  destruct (Pos.eqb RM r) eqn:E1; [apply Pos.eqb_eq in E1; injection H as <-; auto |].
  destruct (Pos.eqb RO r) eqn:E2; [apply Pos.eqb_eq in E2; injection H as <-; auto |].
  destruct (Pos.eqb RFI r) eqn:E3; [apply Pos.eqb_eq in E3; injection H as <-; auto 6 |].
  destruct (Pos.eqb RMISS r) eqn:E4; [apply Pos.eqb_eq in E4; injection H as <-; auto 8 |].
  destruct (Pos.eqb RCALLS r) eqn:E5; [apply Pos.eqb_eq in E5; injection H as <-; auto 10 |].
  destruct (Pos.eqb RLD r) eqn:E6; [apply Pos.eqb_eq in E6; injection H as <-; auto 12 |].
  destruct (Pos.eqb RBUF r) eqn:E7; [apply Pos.eqb_eq in E7; injection H as <-; auto 14 |].
  destruct (Pos.eqb RIOM r) eqn:E8; [apply Pos.eqb_eq in E8; injection H as <-; auto 16 |].
  destruct (Pos.eqb RMQ r) eqn:E9; [apply Pos.eqb_eq in E9; injection H as <-; auto 18 |].
  destruct (Pos.eqb RRM r) eqn:E10; [apply Pos.eqb_eq in E10; injection H as <-; auto 20 |].
  destruct (Pos.eqb RLK r) eqn:E12; [apply Pos.eqb_eq in E12; injection H as <-; auto 22 |].
  destruct (Pos.eqb RPC r) eqn:E13; [apply Pos.eqb_eq in E13; injection H as <-; auto 24 |].
  destruct (Pos.eqb RSR r) eqn:E14; [apply Pos.eqb_eq in E14; injection H as <-; auto 26 |].
  destruct (Pos.eqb RSRC r) eqn:E15; [apply Pos.eqb_eq in E15; injection H as <-; auto 28 |].
  destruct (Pos.eqb RSMS r) eqn:E16; [apply Pos.eqb_eq in E16; injection H as <-; auto 30 |].
  destruct (Pos.eqb RBS r) eqn:E17; [apply Pos.eqb_eq in E17; injection H as <-; auto 32 |].
  destruct (Pos.eqb RFA r) eqn:E18; [apply Pos.eqb_eq in E18; injection H as <-; auto 34 |].
  destruct (Pos.eqb RU r) eqn:E11; [apply Pos.eqb_eq in E11; injection H as <-; auto 36 | discriminate].
Qed.

Ltac r0p_cases H :=
  destruct (r0p_size _ _ H) as
    [(-> & ?) | [(-> & ?) | [(-> & ?) | [(-> & ?) | [(-> & ?) | [(-> & ?) | [(-> & ?) | [(-> & ?)
    | [(-> & ?) | [(-> & ?) | [(-> & ?) | [(-> & ?) | [(-> & ?) | [(-> & ?) | [(-> & ?)
    | [(-> & ?) | [(-> & ?) | (-> & ?)]]]]]]]]]]]]]]]]].

Ltac epl := cbn [Epl e_blk e_base];
  cbn [Pos.eqb RM RO RFI RMISS RCALLS RSIN RLD RBUF RIOM RMQ RRM RAR RLK RPC RSR RSRC RSMS RBS RFA RU RBT RGP RLV]
.
Ltac epl_in H := cbn [Epl e_blk e_base] in H;
  cbn [Pos.eqb RM RO RFI RMISS RCALLS RSIN RLD RBUF RIOM RMQ RRM RAR RLK RPC RSR RSRC RSMS RBS RFA RU RBT RGP RLV]
 in H.

Lemma pl_sizes : forall bo bfi bmiss bcalls bsin ab bt biom bmq brm bau blk bpc bsr bsrc bsms bbs bfa bbt bgp blv oo uo,
  Ptrofs.unsigned oo + SZ_OBJECT <= Ptrofs.modulus -> Ptrofs.unsigned uo + SZ_OBJECT <= Ptrofs.modulus ->
  forall r sz, r0_size (R0P G) r = Some sz ->
    Plt r NBP /\ 0 <= sz
    /\ Ptrofs.unsigned (e_base (Epl bo bfi bmiss bcalls bsin ab bt biom bmq brm bau blk bpc bsr bsrc bsms bbs bfa bbt bgp blv oo uo) r) + sz
       <= Ptrofs.modulus.
Proof.
  intros bo bfi bmiss bcalls bsin ab bt biom bmq brm bau blk bpc bsr bsrc bsms bbs bfa bbt bgp blv oo uo Soo Suo r sz H.
  destruct (KbRow.ff_layout lp H12) as (_ & _ & _ & _ & _ & _ & ZO & _ & _ & ZM & ZD).
  pose proof (Ptrofs.unsigned_range oo) as Ro.
  assert (Mod : Ptrofs.modulus = 4294967296) by reflexivity.
  assert (P1 : 0 <= szs G mario._MarioState)
    by (unfold szs; pose proof (sizeof_pos G (Tstruct mario._MarioState noattr)); lia).
  pose proof (lak_size lp H12) as ZL.
  assert (P2 : 0 <= szs G mario._DmaHandlerList)
    by (unfold szs; pose proof (sizeof_pos G (Tstruct mario._DmaHandlerList noattr)); lia).
  unfold SZ_OBJECT in ZO, Soo, Suo.
  r0p_cases H; subst sz; epl; rewrite ?Ptrofs.unsigned_zero, ?ZO; unfold Plt, NBP, SZ_PCS; repeat split; lia.
Qed.

End POLEROW.

(* ---- the automatic dispatcher's grab and holding cases: handlers, labels ---- *)
From SM64.Proofs.WMotRRequiresA Require Import AutoSplit.

Lemma dm_gps : (prog_defmap AUT.prog) ! AUT._act_grab_pole_slow = Some (Gfun (Internal AUT.f_act_grab_pole_slow)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_gpf : (prog_defmap AUT.prog) ! AUT._act_grab_pole_fast = Some (Gfun (Internal AUT.f_act_grab_pole_fast)).
Proof. vm_compute. reflexivity. Qed.

Lemma dm_hp : (prog_defmap AUT.prog) ! AUT._act_holding_pole = Some (Gfun (Internal AUT.f_act_holding_pole)).
Proof. vm_compute. reflexivity. Qed.
Lemma hp_label_b : forallb (fun x => if Pos.eqb (snd x) AUT._act_holding_pole then Z.eqb (fst x) 135267136 else true)
  aut_case_list = true.
Proof. vm_compute. reflexivity. Qed.
Lemma hp_label : forall n, In (n, AUT._act_holding_pole) aut_case_list -> n = 135267136.
Proof.
  intros n H. pose proof (proj1 (forallb_forall _ _) hp_label_b _ H) as X.
  cbn [fst snd] in X. rewrite Pos.eqb_refl in X. apply Z.eqb_eq in X. exact X.
Qed.

Lemma gps_label_b : forallb (fun x => if Pos.eqb (snd x) AUT._act_grab_pole_slow then Z.eqb (fst x) 1049409 else true)
  aut_case_list = true.
Proof. vm_compute. reflexivity. Qed.
Lemma gpf_label_b : forallb (fun x => if Pos.eqb (snd x) AUT._act_grab_pole_fast then Z.eqb (fst x) 1049410 else true)
  aut_case_list = true.
Proof. vm_compute. reflexivity. Qed.
Lemma gps_label : forall n, In (n, AUT._act_grab_pole_slow) aut_case_list -> n = 1049409.
Proof.
  intros n H. pose proof (proj1 (forallb_forall _ _) gps_label_b _ H) as X.
  cbn [fst snd] in X. rewrite Pos.eqb_refl in X. apply Z.eqb_eq in X. exact X.
Qed.
Lemma gpf_label : forall n, In (n, AUT._act_grab_pole_fast) aut_case_list -> n = 1049410.
Proof.
  intros n H. pose proof (proj1 (forallb_forall _ _) gpf_label_b _ H) as X.
  cbn [fst snd] in X. rewrite Pos.eqb_refl in X. apply Z.eqb_eq in X. exact X.
Qed.

Section POLECASES.
Variable lp : Clight.program.
Hypothesis H12 : linked12 lp.
Local Notation G := (globalenv lp).
Hypothesis Hdma : os_dma_floor.
Variable bm : block.
Hypothesis Hbm : Genv.find_symbol G level_update._gMarioStates = Some bm.
Variable MWF : mem -> Prop.

(* the cases but the two grabs and HOLDING_POLE (LedgeRow's start; PoleCasesT
   proves those three and closes the rest) *)
Definition aut_case_rest_pole : Prop :=
  forall n f fd v, In (n, f) aut_case_list ->
    f <> AUT._act_grab_pole_slow -> f <> AUT._act_grab_pole_fast -> f <> AUT._act_holding_pole ->
    resolves lp f fd ->
    seg_okR lp bm MWF fd [v]
      (fun m => v = Vptr bm Ptrofs.zero /\ Mem.load Mint32 m bm 12 = Some (Vint (Int.repr n)) /\ fresh bm m)
      (fun m' vr => vr = Vint Int.zero \/ fresh bm m').

End POLECASES.
