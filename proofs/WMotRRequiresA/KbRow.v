(* ====================================================================== *)
(* KbRow (GOAL 2): the soft-bonk and air-knockback cases of the airborne   *)
(* dispatcher.                                                             *)
(*                                                                        *)
(* The same construction as FfRow / AhwRow, generic in the case (kb_row:  *)
(* the action constant acn, its handler fK, its walk theorem              *)
(* (KbRun.kfinal), at any entry state): from the                          *)
(* frame world and the dispatch's floor refresh (FfWorld.fresh, carried   *)
(* to the case by FrameSplit.frame_stage / AirSplit.air_seg), the walk's  *)
(* start state on any twelve-TU link, then the walk theorem (a MoveChain   *)
(* per outcome, and RetOk.RET: FALSE or y/floorHeight untouched) and      *)
(* FfKeepCheck.fk_ok (the world is kept).  The soft bonk and both air     *)
(* knockbacks (KbRun.kb_kfinal), ground pound (GpRun.gp_kfinal), dive     *)
(* (KbDv), both rollouts (RlRun), butt-slide air (BsRun) and slide kick   *)
(* (SkRun), both at any state, are cases: every no-A case                 *)
(* (air_case_rows_ff8); no row is left.                                   *)
(*                                                                        *)
(* Premises beyond the link: as FfRow (DMA floor, FPU floor, the labeled   *)
(* open audio / camera premises).                                          *)
(* ====================================================================== *)

From Coq Require Import List ZArith Lia Reals.
From compcert Require Import Coqlib Maps AST Integers Floats Values Memory Events Globalenvs
  Ctypes Clight ClightBigstep Linking.
From SM64.Generated Require mario_step mario mario_actions_airborne memory surface_collision level_update camera.
From SM64.Proofs Require Import Interp.SymExec2 Interp.LinkGenv MarioModel.LinkedTwelve
  MarioModel.OsDmaFloor HeightInvariant HeightMoveCatalog WMotRLevel WMotRWorld.
From SM64.Proofs Require Import RealFrameLinked AirborneSurface NoAImpliesNoFlyLinked.
From SM64.Proofs.WMotRRequiresA Require Import FloorList FloorExec AirRun AirStart AirMatch
  FpuFloor ExtInert FfRun FfWorld FrameSplit AirSplit FfKeepCheck FfKeep FfClass AhwRun KbRun KbSb KbBkb KbFkb KbDv GpRun RlRun RlF RlB BsRun BsW SkRun SkW
  SbRet0 SbRet0Walk.
From SM64.Proofs.WMotRRequiresA Require FfRow AhwRow.
From SM64.Proofs Require Import Generic.ClosedMem Generic.ClightClosed.
From SM64.Proofs.WMotRRequiresA Require AnimWorld AnimKeep.
Import ListNotations.

Module AIR := mario_actions_airborne.

(* the layout the start needs, pinned on the real link *)
Lemma ff_layout12 : match ge12 with
  | Some g => Z.eqb (AirRun.fo g mario._MarioState mario._marioObj) FFW_OBJ
              && Z.eqb (AirRun.fo g mario._MarioState mario._animList) FFW_ANIM
              && Z.eqb (AirRun.fo g mario._MarioState mario._floor) FFW_FLOOR
              && Z.eqb (AirRun.fo g mario._MarioState mario._area) FFW_AREA
              && Z.eqb (AirRun.fo g mario._MarioState mario._heldObj) HELD_OFF
              && Z.eqb (AirRun.fo g mario._MarioState mario._riddenObj) RIDDEN_OFF
              && Z.eqb (szs g mario._Object) SZ_OBJECT && Z.eqb (szs g mario._Surface) SZ_SURFACE
              && Z.eqb (szs g mario._Area) SZ_AREA
              && Z.leb (szs g mario._MarioState) 4096 && Z.leb (szs g mario._DmaHandlerList) 4096
  | None => false end = true.
Proof. vm_compute. reflexivity. Qed.

(* each case's label *)
Lemma sb_label_b : forallb (fun x => if Pos.eqb (snd x) AIR._act_soft_bonk then Z.eqb (fst x) 16910518 else true)
  air_case_list = true.
Proof. vm_compute. reflexivity. Qed.
Lemma bkb_label_b : forallb (fun x => if Pos.eqb (snd x) AIR._act_backward_air_kb then Z.eqb (fst x) 16910512 else true)
  air_case_list = true.
Proof. vm_compute. reflexivity. Qed.
Lemma fkb_label_b : forallb (fun x => if Pos.eqb (snd x) AIR._act_forward_air_kb then Z.eqb (fst x) 16910513 else true)
  air_case_list = true.
Proof. vm_compute. reflexivity. Qed.

Lemma sb_label : forall n, In (n, AIR._act_soft_bonk) air_case_list -> n = 16910518.
Proof.
  intros n H. pose proof (proj1 (forallb_forall _ _) sb_label_b _ H) as X.
  cbn [fst snd] in X. rewrite Pos.eqb_refl in X. apply Z.eqb_eq in X. exact X.
Qed.
Lemma bkb_label : forall n, In (n, AIR._act_backward_air_kb) air_case_list -> n = 16910512.
Proof.
  intros n H. pose proof (proj1 (forallb_forall _ _) bkb_label_b _ H) as X.
  cbn [fst snd] in X. rewrite Pos.eqb_refl in X. apply Z.eqb_eq in X. exact X.
Qed.
Lemma fkb_label : forall n, In (n, AIR._act_forward_air_kb) air_case_list -> n = 16910513.
Proof.
  intros n H. pose proof (proj1 (forallb_forall _ _) fkb_label_b _ H) as X.
  cbn [fst snd] in X. rewrite Pos.eqb_refl in X. apply Z.eqb_eq in X. exact X.
Qed.

Lemma gp_label_b : forallb (fun x => if Pos.eqb (snd x) AIR._act_ground_pound then Z.eqb (fst x) 8390825 else true)
  air_case_list = true.
Proof. vm_compute. reflexivity. Qed.
Lemma gp_label : forall n, In (n, AIR._act_ground_pound) air_case_list -> n = 8390825.
Proof.
  intros n H. pose proof (proj1 (forallb_forall _ _) gp_label_b _ H) as X.
  cbn [fst snd] in X. rewrite Pos.eqb_refl in X. apply Z.eqb_eq in X. exact X.
Qed.
Lemma dm_gp : (prog_defmap AIR.prog) ! AIR._act_ground_pound = Some (Gfun (Internal AIR.f_act_ground_pound)).
Proof. vm_compute. reflexivity. Qed.

Lemma dv_label_b : forallb (fun x => if Pos.eqb (snd x) AIR._act_dive then Z.eqb (fst x) 25692298 else true)
  air_case_list = true.
Proof. vm_compute. reflexivity. Qed.
Lemma dv_label : forall n, In (n, AIR._act_dive) air_case_list -> n = 25692298.
Proof.
  intros n H. pose proof (proj1 (forallb_forall _ _) dv_label_b _ H) as X.
  cbn [fst snd] in X. rewrite Pos.eqb_refl in X. apply Z.eqb_eq in X. exact X.
Qed.
Lemma dm_dv : (prog_defmap AIR.prog) ! AIR._act_dive = Some (Gfun (Internal AIR.f_act_dive)).
Proof. vm_compute. reflexivity. Qed.

Lemma fr_label_b : forallb (fun x => if Pos.eqb (snd x) AIR._act_forward_rollout then Z.eqb (fst x) 16779430 else true)
  air_case_list = true.
Proof. vm_compute. reflexivity. Qed.
Lemma fr_label : forall n, In (n, AIR._act_forward_rollout) air_case_list -> n = 16779430.
Proof.
  intros n H. pose proof (proj1 (forallb_forall _ _) fr_label_b _ H) as X.
  cbn [fst snd] in X. rewrite Pos.eqb_refl in X. apply Z.eqb_eq in X. exact X.
Qed.
Lemma dm_fr : (prog_defmap AIR.prog) ! AIR._act_forward_rollout = Some (Gfun (Internal AIR.f_act_forward_rollout)).
Proof. vm_compute. reflexivity. Qed.
Lemma br_label_b : forallb (fun x => if Pos.eqb (snd x) AIR._act_backward_rollout then Z.eqb (fst x) 16779437 else true)
  air_case_list = true.
Proof. vm_compute. reflexivity. Qed.
Lemma br_label : forall n, In (n, AIR._act_backward_rollout) air_case_list -> n = 16779437.
Proof.
  intros n H. pose proof (proj1 (forallb_forall _ _) br_label_b _ H) as X.
  cbn [fst snd] in X. rewrite Pos.eqb_refl in X. apply Z.eqb_eq in X. exact X.
Qed.
Lemma dm_br : (prog_defmap AIR.prog) ! AIR._act_backward_rollout = Some (Gfun (Internal AIR.f_act_backward_rollout)).
Proof. vm_compute. reflexivity. Qed.
Lemma bsa_label_b : forallb (fun x => if Pos.eqb (snd x) AIR._act_butt_slide_air then Z.eqb (fst x) 50333838 else true)
  air_case_list = true.
Proof. vm_compute. reflexivity. Qed.
Lemma bsa_label : forall n, In (n, AIR._act_butt_slide_air) air_case_list -> n = 50333838.
Proof.
  intros n H. pose proof (proj1 (forallb_forall _ _) bsa_label_b _ H) as X.
  cbn [fst snd] in X. rewrite Pos.eqb_refl in X. apply Z.eqb_eq in X. exact X.
Qed.
Lemma dm_bsa : (prog_defmap AIR.prog) ! AIR._act_butt_slide_air = Some (Gfun (Internal AIR.f_act_butt_slide_air)).
Proof. vm_compute. reflexivity. Qed.
Lemma sk_label_b : forallb (fun x => if Pos.eqb (snd x) AIR._act_slide_kick then Z.eqb (fst x) 25168042 else true)
  air_case_list = true.
Proof. vm_compute. reflexivity. Qed.
Lemma sk_label : forall n, In (n, AIR._act_slide_kick) air_case_list -> n = 25168042.
Proof.
  intros n H. pose proof (proj1 (forallb_forall _ _) sk_label_b _ H) as X.
  cbn [fst snd] in X. rewrite Pos.eqb_refl in X. apply Z.eqb_eq in X. exact X.
Qed.
Lemma dm_sk : (prog_defmap AIR.prog) ! AIR._act_slide_kick = Some (Gfun (Internal AIR.f_act_slide_kick)).
Proof. vm_compute. reflexivity. Qed.

(* the switch's no-A cases are these eleven handlers, computed from the
   generated air_case_list *)
Definition air_case_fns : list ident :=
  [AIR._act_freefall; AIR._act_air_hit_wall; AIR._act_soft_bonk; AIR._act_backward_air_kb;
   AIR._act_forward_air_kb; AIR._act_ground_pound; AIR._act_dive; AIR._act_forward_rollout;
   AIR._act_backward_rollout; AIR._act_butt_slide_air; AIR._act_slide_kick].
Lemma air_case_fns_b : forallb (fun x => existsb (Pos.eqb (snd x)) air_case_fns) air_case_list = true.
Proof. vm_compute. reflexivity. Qed.
Lemma air_case_fns_in : forall n f, In (n, f) air_case_list -> In f air_case_fns.
Proof.
  intros n f H. pose proof (proj1 (forallb_forall _ _) air_case_fns_b _ H) as X.
  cbn [snd] in X. apply existsb_exists in X as (f' & I & E). apply Pos.eqb_eq in E. subst f'. exact I.
Qed.

Lemma dm_sb : (prog_defmap AIR.prog) ! AIR._act_soft_bonk = Some (Gfun (Internal AIR.f_act_soft_bonk)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_bkb : (prog_defmap AIR.prog) ! AIR._act_backward_air_kb = Some (Gfun (Internal AIR.f_act_backward_air_kb)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_fkb : (prog_defmap AIR.prog) ! AIR._act_forward_air_kb = Some (Gfun (Internal AIR.f_act_forward_air_kb)).
Proof. vm_compute. reflexivity. Qed.

Lemma kb_reshape : forall A B C : Prop, (A /\ B) /\ C -> A /\ B /\ C.
Proof. tauto. Qed.

Section KBROW.
Variable lp : Clight.program.
Hypothesis H12 : linked12 lp.
Local Notation G := (globalenv lp).

Hypothesis Hdma : os_dma_floor.
Hypothesis Hsq : sqrtf_spec.
Hypothesis Hsqf : sqrtf_float.

Variable bm : block.
Hypothesis Hbm : Genv.find_symbol G level_update._gMarioStates = Some bm.

(* the case *)
Variable acn : Z.
Variable fK : function.
Hypothesis Hfin : kfinal lp acn fK.
(* the case is not SOFT_BONK, or its handler returns 0 (SbRet0): what
   FfWorld.fresh's slack needs at a TRUE return *)
Hypothesis Hsb : Int.eq (Int.repr acn) (Int.repr SB_ACT) = false \/ kret0 lp acn fK.

Lemma ff_layout : AirRun.fo G mario._MarioState mario._marioObj = FFW_OBJ
  /\ AirRun.fo G mario._MarioState mario._animList = FFW_ANIM
  /\ AirRun.fo G mario._MarioState mario._floor = FFW_FLOOR
  /\ AirRun.fo G mario._MarioState mario._area = FFW_AREA
  /\ AirRun.fo G mario._MarioState mario._heldObj = HELD_OFF
  /\ AirRun.fo G mario._MarioState mario._riddenObj = RIDDEN_OFF
  /\ szs G mario._Object = SZ_OBJECT /\ szs G mario._Surface = SZ_SURFACE
  /\ szs G mario._Area = SZ_AREA
  /\ szs G mario._MarioState <= 4096 /\ szs G mario._DmaHandlerList <= 4096.
Proof.
  pose proof ff_layout12 as L. rewrite (ge12_ok lp H12) in L.
  repeat rewrite andb_true_iff in L.
  destruct L as ((((((((((A1 & A2) & A3) & A4) & A5) & A6) & A7) & A8) & A9) & A10) & A11).
  apply Z.eqb_eq in A1, A2, A3, A4, A5, A6, A7, A8, A9. apply Z.leb_le in A10, A11.
  auto 12.
Qed.

(* the walk's environment *)
Definition Eff (bo bfi bmiss bcalls bsin ab bt biom bmq brm bau blk bpc bsr bsrc bsms : block) (oo : ptrofs) : senv :=
  mke (fun r => if Pos.eqb r RM then bm else if Pos.eqb r RO then bo
                else if Pos.eqb r RFI then bfi else if Pos.eqb r RMISS then bmiss
                else if Pos.eqb r RCALLS then bcalls else if Pos.eqb r RSIN then bsin
                else if Pos.eqb r RLD then ab else if Pos.eqb r RBUF then bt
                else if Pos.eqb r RIOM then biom else if Pos.eqb r RMQ then bmq
                else if Pos.eqb r RRM then brm else if Pos.eqb r RAR then bau
                else if Pos.eqb r RLK then blk else if Pos.eqb r RPC then bpc
                else if Pos.eqb r RSR then bsr else if Pos.eqb r RSRC then bsrc
                else if Pos.eqb r RSMS then bsms else bm)
      (fun r => if Pos.eqb r RO then oo else Ptrofs.zero)
      (fun _ => None).

Lemma sym_ne : forall i1 i2 b1 b2, Genv.find_symbol G i1 = Some b1 -> Genv.find_symbol G i2 = Some b2 ->
  i1 <> i2 -> b1 <> b2.
Proof.
  intros i1 i2 b1 b2 H1 H2 N. exact (Genv.global_addresses_distinct G N H1 H2).
Qed.

Lemma sym_valid : forall m id b, Ple (Genv.genv_next G) (Mem.nextblock m) ->
  Genv.find_symbol G id = Some b -> Plt b (Mem.nextblock m).
Proof.
  intros m id b Hn Hs. pose proof (Genv.genv_symb_range _ _ Hs) as Hr. unfold Plt, Ple in *. lia.
Qed.

Lemma r0f_size : forall r sz, r0_size (R0F G) r = Some sz ->
  (r = RM /\ sz = szs G mario._MarioState) \/ (r = RO /\ sz = szs G mario._Object)
  \/ (r = RFI /\ sz = 2) \/ (r = RMISS /\ sz = 4) \/ (r = RCALLS /\ sz = 6)
  \/ (r = RLD /\ sz = szs G mario._DmaHandlerList) \/ (r = RBUF /\ sz = Ptrofs.modulus)
  \/ (r = RIOM /\ sz = 20) \/ (r = RMQ /\ sz = 24) \/ (r = RRM /\ sz = 4)
  \/ (r = RLK /\ sz = szs G camera._LakituState) \/ (r = RPC /\ sz = SZ_PCS)
  \/ (r = RSR /\ sz = Ptrofs.modulus) \/ (r = RSRC /\ sz = Ptrofs.modulus)
  \/ (r = RSMS /\ sz = Ptrofs.modulus).
Proof.
  intros r sz H. unfold r0_size, R0F in H. cbn [find fst] in H.
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
  destruct (Pos.eqb RLK r) eqn:E11; [apply Pos.eqb_eq in E11; injection H as <-; auto 22 |].
  destruct (Pos.eqb RPC r) eqn:E12; [apply Pos.eqb_eq in E12; injection H as <-; auto 24 |].
  destruct (Pos.eqb RSR r) eqn:E13; [apply Pos.eqb_eq in E13; injection H as <-; auto 26 |].
  destruct (Pos.eqb RSRC r) eqn:E14; [apply Pos.eqb_eq in E14; injection H as <-; auto 28 |].
  destruct (Pos.eqb RSMS r) eqn:E15; [apply Pos.eqb_eq in E15; injection H as <-; auto 30 | discriminate].
Qed.

Lemma ff_sizes : forall bo bfi bmiss bcalls bsin ab bt biom bmq brm bau blk bpc bsr bsrc bsms oo,
  Ptrofs.unsigned oo + SZ_OBJECT <= Ptrofs.modulus ->
  forall r sz, r0_size (R0F G) r = Some sz ->
    Plt r NBF /\ 0 <= sz
    /\ Ptrofs.unsigned (e_base (Eff bo bfi bmiss bcalls bsin ab bt biom bmq brm bau blk bpc bsr bsrc bsms oo) r) + sz <= Ptrofs.modulus.
Proof.
  intros bo bfi bmiss bcalls bsin ab bt biom bmq brm bau blk bpc bsr bsrc bsms oo Soo r sz H.
  destruct ff_layout as (_ & _ & _ & _ & _ & _ & ZO & _ & _ & ZM & ZD).
  pose proof (Ptrofs.unsigned_range oo) as Ro.
  assert (Mod : Ptrofs.modulus = 4294967296) by reflexivity.
  assert (P1 : 0 <= szs G mario._MarioState)
    by (unfold szs; pose proof (sizeof_pos G (Tstruct mario._MarioState noattr)); lia).
  pose proof (lak_size lp H12) as ZL.
  assert (P2 : 0 <= szs G mario._DmaHandlerList)
    by (unfold szs; pose proof (sizeof_pos G (Tstruct mario._DmaHandlerList noattr)); lia).
  unfold SZ_OBJECT in ZO, Soo.
  destruct (r0f_size r sz H) as
    [(-> & ->) | [(-> & ->) | [(-> & ->) | [(-> & ->) | [(-> & ->) | [(-> & ->) | [(-> & ->) | [(-> & ->) | [(-> & ->) | [(-> & ->) | [(-> & ->) | [(-> & ->) | [(-> & ->) | [(-> & ->) | (-> & ->)]]]]]]]]]]]]]];
    cbn [Eff e_base]; cbn [Pos.eqb RM RO RFI RMISS RCALLS RSIN RLD RBUF RIOM RMQ RRM RAR RLK RPC RSR RSRC RSMS];
    rewrite ?Ptrofs.unsigned_zero, ?ZO; unfold Plt, NBF, SZ_PCS; repeat split; lia.
Qed.

(* membership in FfKeepCheck.fk_same *)
Ltac mem_tac := unfold fk_same; repeat (first [left; reflexivity | right]).

(* THE KNOCKBACK ROW: from the frame world and a fresh floor, the case's
   real handler keeps the frame world, moves Phi's cells by a MoveChain, and
   returns FALSE or leaves the floor fresh *)
Theorem kb_row : forall m t m' vres c0,
  Plt bm (Mem.nextblock m) -> fworld lp bm m ->
  read_cells bm m c0 -> budget_ok c0 ->
  Mem.load Mint32 m bm 12 = Some (Vint (Int.repr acn)) -> fresh bm m ->
  eval_funcall function_entry2 G m (Internal fK) [Vptr bm Ptrofs.zero] t m' vres ->
  (fworld lp bm m' /\ exists c2, read_cells bm m' c2 /\ MoveChain wmotr_floor wmotr_pole wmotr_cannon c0 c2)
  /\ (vres = Vint Int.zero \/ fresh bm m').
Proof.
  intros m t m' vres c0 Vm (Ha & HW & Han & Hmob & Hd & FW & _ & AW & LV) RC Hbud Hact Hfr EV.
  destruct FW as (Hgn & EX & FD).
  destruct EX as (gp & bfi & bmiss & bcalls & bsin & ab & biom & bmq & brm & blk & bpc & bsr & bsrc & bsms & bo & oo & bt & ot & fl & ar & inp & ctl &
                  HC & HS & HM & S1 & S2 & S3 & S4 & S5 & S6 & S7 & S8 & SL & SP & SR & SRC & SMS & Lo & Soo & La & Lb & Sot & D1 & D2 & D3 & D4 &
                  W & Lf & Wf & Wc0 & Lar & War & Li & Ai & Lc & Wc & Co & LPC).
  destruct ff_layout as (FO & FA & FF & FAr & FH & FR & ZO & ZS & ZA & ZM & ZD).
  destruct (aud_sym lp H12) as (bau & S9).
  set (E := Eff bo bfi bmiss bcalls bsin ab bt biom bmq brm bau blk bpc bsr bsrc bsms oo).
  (* validity *)
  assert (GPO : forall b x, gp b = Some x -> Plt b (Mem.nextblock m))
    by (intros b x H; exact (closed_old gp m b x HC H)).
  assert (MCg : forall ch b z v, gp b <> None -> Mem.load ch m b z = Some v -> val_old gp v)
    by (intros ch b z v Hb Hl; exact (closed_load gp m ch b z v HC Hb Hl)).
  assert (GV : forall b, gp b <> None -> Plt b (Mem.nextblock m))
    by (intros b H; destruct (gp b) as [x|] eqn:E0; [exact (GPO b x E0) | congruence]).
  assert (Gbo : gp bo <> None) by exact (closed_load gp m _ _ _ _ HC HM Lo).
  assert (Gab : gp ab <> None) by exact (HS _ _ S5).
  assert (Gbt : gp bt <> None) by exact (closed_load gp m _ _ _ _ HC Gab Lb).
  assert (Vo : Plt bo (Mem.nextblock m)) by exact (GV _ Gbo).
  assert (Vab : Plt ab (Mem.nextblock m)) by exact (GV _ Gab).
  assert (Vbt : Plt bt (Mem.nextblock m)) by exact (GV _ Gbt).
  pose proof (sym_valid m _ _ Hgn S1) as V1. pose proof (sym_valid m _ _ Hgn S2) as V2.
  pose proof (sym_valid m _ _ Hgn S3) as V3. pose proof (sym_valid m _ _ Hgn S4) as V4.
  pose proof (sym_valid m _ _ Hgn S6) as V6. pose proof (sym_valid m _ _ Hgn S7) as V7.
  pose proof (sym_valid m _ _ Hgn S8) as V8.
  (* distinctness: symbols, then Mario's object and the buffer *)
  assert (DS : forall i1 i2 b1 b2, Genv.find_symbol G i1 = Some b1 -> Genv.find_symbol G i2 = Some b2 ->
             Pos.eqb i1 i2 = false -> b1 <> b2)
    by (intros i1 i2 b1 b2 H1 H2 N; apply (sym_ne i1 i2 b1 b2 H1 H2); apply Pos.eqb_neq; exact N).
  pose proof (DS _ _ _ _ Hbm S1 eq_refl) as N01. pose proof (DS _ _ _ _ Hbm S2 eq_refl) as N02.
  pose proof (DS _ _ _ _ Hbm S3 eq_refl) as N03. pose proof (DS _ _ _ _ Hbm S4 eq_refl) as N04.
  pose proof (DS _ _ _ _ Hbm S5 eq_refl) as N05. pose proof (DS _ _ _ _ Hbm S6 eq_refl) as N06.
  pose proof (DS _ _ _ _ Hbm S7 eq_refl) as N07. pose proof (DS _ _ _ _ Hbm S8 eq_refl) as N08.
  pose proof (DS _ _ _ _ S1 S2 eq_refl) as N12. pose proof (DS _ _ _ _ S1 S3 eq_refl) as N13.
  pose proof (DS _ _ _ _ S1 S4 eq_refl) as N14. pose proof (DS _ _ _ _ S1 S5 eq_refl) as N15.
  pose proof (DS _ _ _ _ S1 S6 eq_refl) as N16. pose proof (DS _ _ _ _ S1 S7 eq_refl) as N17.
  pose proof (DS _ _ _ _ S1 S8 eq_refl) as N18.
  pose proof (DS _ _ _ _ S2 S3 eq_refl) as N23. pose proof (DS _ _ _ _ S2 S4 eq_refl) as N24.
  pose proof (DS _ _ _ _ S2 S5 eq_refl) as N25. pose proof (DS _ _ _ _ S2 S6 eq_refl) as N26.
  pose proof (DS _ _ _ _ S2 S7 eq_refl) as N27. pose proof (DS _ _ _ _ S2 S8 eq_refl) as N28.
  pose proof (DS _ _ _ _ S3 S4 eq_refl) as N34. pose proof (DS _ _ _ _ S3 S5 eq_refl) as N35.
  pose proof (DS _ _ _ _ S3 S6 eq_refl) as N36. pose proof (DS _ _ _ _ S3 S7 eq_refl) as N37.
  pose proof (DS _ _ _ _ S3 S8 eq_refl) as N38.
  pose proof (DS _ _ _ _ S4 S5 eq_refl) as N45. pose proof (DS _ _ _ _ S4 S6 eq_refl) as N46.
  pose proof (DS _ _ _ _ S4 S7 eq_refl) as N47. pose proof (DS _ _ _ _ S4 S8 eq_refl) as N48.
  pose proof (DS _ _ _ _ S5 S6 eq_refl) as N56. pose proof (DS _ _ _ _ S5 S7 eq_refl) as N57.
  pose proof (DS _ _ _ _ S5 S8 eq_refl) as N58.
  pose proof (DS _ _ _ _ S6 S7 eq_refl) as N67. pose proof (DS _ _ _ _ S6 S8 eq_refl) as N68.
  pose proof (DS _ _ _ _ S7 S8 eq_refl) as N78.
  pose proof (sym_valid m _ _ Hgn S9) as V9.
  pose proof (DS _ _ _ _ S9 Hbm eq_refl) as N90. pose proof (DS _ _ _ _ S9 S1 eq_refl) as N91.
  pose proof (DS _ _ _ _ S9 S2 eq_refl) as N92. pose proof (DS _ _ _ _ S9 S3 eq_refl) as N93.
  pose proof (DS _ _ _ _ S9 S4 eq_refl) as N94. pose proof (DS _ _ _ _ S9 S5 eq_refl) as N95.
  pose proof (DS _ _ _ _ S9 S6 eq_refl) as N96. pose proof (DS _ _ _ _ S9 S7 eq_refl) as N97.
  pose proof (DS _ _ _ _ S9 S8 eq_refl) as N98.
  destruct (D4 bau (or_intror (or_introl S9))) as (O9 & T9).
  pose proof (sym_valid m _ _ Hgn SL) as VL.
  pose proof (DS _ _ _ _ SL Hbm eq_refl) as NL0. pose proof (DS _ _ _ _ SL S1 eq_refl) as NL1.
  pose proof (DS _ _ _ _ SL S2 eq_refl) as NL2. pose proof (DS _ _ _ _ SL S3 eq_refl) as NL3.
  pose proof (DS _ _ _ _ SL S4 eq_refl) as NL4. pose proof (DS _ _ _ _ SL S5 eq_refl) as NL5.
  pose proof (DS _ _ _ _ SL S6 eq_refl) as NL6. pose proof (DS _ _ _ _ SL S7 eq_refl) as NL7.
  pose proof (DS _ _ _ _ SL S8 eq_refl) as NL8. pose proof (DS _ _ _ _ SL S9 eq_refl) as NL9.
  destruct (D4 blk ltac:(left; cbn; auto 12)) as (OL & TL).
  pose proof (sym_valid m _ _ Hgn SP) as VPC.
  pose proof (DS _ _ _ _ SP Hbm eq_refl) as NP0. pose proof (DS _ _ _ _ SP S1 eq_refl) as NP1.
  pose proof (DS _ _ _ _ SP S2 eq_refl) as NP2. pose proof (DS _ _ _ _ SP S3 eq_refl) as NP3.
  pose proof (DS _ _ _ _ SP S4 eq_refl) as NP4. pose proof (DS _ _ _ _ SP S5 eq_refl) as NP5.
  pose proof (DS _ _ _ _ SP S6 eq_refl) as NP6. pose proof (DS _ _ _ _ SP S7 eq_refl) as NP7.
  pose proof (DS _ _ _ _ SP S8 eq_refl) as NP8. pose proof (DS _ _ _ _ SP S9 eq_refl) as NP9.
  pose proof (DS _ _ _ _ SP SL eq_refl) as NPL.
  destruct (D4 bpc ltac:(left; cbn; auto 14)) as (OP & TP).
  pose proof (DS _ _ _ _ SR Hbm eq_refl) as NsrHbm. pose proof (DS _ _ _ _ SR S1 eq_refl) as NsrS1.
  pose proof (DS _ _ _ _ SR S2 eq_refl) as NsrS2. pose proof (DS _ _ _ _ SR S3 eq_refl) as NsrS3.
  pose proof (DS _ _ _ _ SR S4 eq_refl) as NsrS4. pose proof (DS _ _ _ _ SR S5 eq_refl) as NsrS5.
  pose proof (DS _ _ _ _ SR S6 eq_refl) as NsrS6. pose proof (DS _ _ _ _ SR S7 eq_refl) as NsrS7.
  pose proof (DS _ _ _ _ SR S8 eq_refl) as NsrS8. pose proof (DS _ _ _ _ SR S9 eq_refl) as NsrS9.
  pose proof (DS _ _ _ _ SR SL eq_refl) as NsrSL. pose proof (DS _ _ _ _ SR SP eq_refl) as NsrSP.
  pose proof (DS _ _ _ _ SRC Hbm eq_refl) as NsrcHbm. pose proof (DS _ _ _ _ SRC S1 eq_refl) as NsrcS1.
  pose proof (DS _ _ _ _ SRC S2 eq_refl) as NsrcS2. pose proof (DS _ _ _ _ SRC S3 eq_refl) as NsrcS3.
  pose proof (DS _ _ _ _ SRC S4 eq_refl) as NsrcS4. pose proof (DS _ _ _ _ SRC S5 eq_refl) as NsrcS5.
  pose proof (DS _ _ _ _ SRC S6 eq_refl) as NsrcS6. pose proof (DS _ _ _ _ SRC S7 eq_refl) as NsrcS7.
  pose proof (DS _ _ _ _ SRC S8 eq_refl) as NsrcS8. pose proof (DS _ _ _ _ SRC S9 eq_refl) as NsrcS9.
  pose proof (DS _ _ _ _ SRC SL eq_refl) as NsrcSL. pose proof (DS _ _ _ _ SRC SP eq_refl) as NsrcSP.
  pose proof (DS _ _ _ _ SRC SR eq_refl) as NsrcSR.
  pose proof (DS _ _ _ _ SMS Hbm eq_refl) as NsmsHbm. pose proof (DS _ _ _ _ SMS S1 eq_refl) as NsmsS1.
  pose proof (DS _ _ _ _ SMS S2 eq_refl) as NsmsS2. pose proof (DS _ _ _ _ SMS S3 eq_refl) as NsmsS3.
  pose proof (DS _ _ _ _ SMS S4 eq_refl) as NsmsS4. pose proof (DS _ _ _ _ SMS S5 eq_refl) as NsmsS5.
  pose proof (DS _ _ _ _ SMS S6 eq_refl) as NsmsS6. pose proof (DS _ _ _ _ SMS S7 eq_refl) as NsmsS7.
  pose proof (DS _ _ _ _ SMS S8 eq_refl) as NsmsS8. pose proof (DS _ _ _ _ SMS S9 eq_refl) as NsmsS9.
  pose proof (DS _ _ _ _ SMS SL eq_refl) as NsmsSL. pose proof (DS _ _ _ _ SMS SP eq_refl) as NsmsSP.
  pose proof (DS _ _ _ _ SMS SR eq_refl) as NsmsSR. pose proof (DS _ _ _ _ SMS SRC eq_refl) as NsmsSRC.
  destruct (D4 bsr ltac:(left; cbn; auto 20)) as (OSR & TSR).
  destruct (D4 bsrc ltac:(left; cbn; auto 20)) as (OSRC & TSRC).
  destruct (D4 bsms ltac:(left; cbn; auto 20)) as (OSMS & TSMS).
  destruct (D4 bfi ltac:(left; cbn; auto 10)) as (O1 & T1). destruct (D4 bmiss ltac:(left; cbn; auto 10)) as (O2 & T2).
  destruct (D4 bcalls ltac:(left; cbn; auto 10)) as (O3 & T3). destruct (D4 bsin ltac:(left; cbn; auto 10)) as (O4 & T4).
  destruct (D4 ab ltac:(left; cbn; auto 10)) as (O5 & T5). destruct (D4 biom ltac:(left; cbn; auto 10)) as (O6 & T6).
  destruct (D4 bmq ltac:(left; cbn; auto 10)) as (O7 & T7). destruct (D4 brm ltac:(left; cbn; auto 10)) as (O8 & T8).
  clear DS.
  (* the region pointer list is ffw's *)
  assert (RL : map (den G m E) (wargs (R0F G)) = ff_rl bm bo oo bfi bmiss bcalls ab bt biom bmq brm blk bpc bsr bsrc bsms).
  { unfold wargs, R0F, ff_rl. cbn [map fst den]. unfold E; cbn [Eff e_blk e_base]. cbn [Pos.eqb RM RO RFI RMISS RCALLS RSIN RLD RBUF RIOM RMQ RRM RAR RLK RPC RSR RSRC RSMS].
    rewrite !Ptrofs.add_zero. reflexivity. }
  (* each region's block is on the list *)
  assert (INR : forall r sz, r0_size (R0F G) r = Some sz ->
            In (Some (Vptr (e_blk E r) (e_base E r))) (ff_rl bm bo oo bfi bmiss bcalls ab bt biom bmq brm blk bpc bsr bsrc bsms)).
  { intros r sz H. destruct (r0f_size r sz H) as
      [(-> & _) | [(-> & _) | [(-> & _) | [(-> & _) | [(-> & _) | [(-> & _) | [(-> & _) | [(-> & _) | [(-> & _) | [(-> & _) | [(-> & _) | [(-> & _) | [(-> & _) | [(-> & _) | (-> & _)]]]]]]]]]]]]]];
      unfold E; cbn; auto 17. }
  assert (WW : forall p v n, den G m E p = Some v ->
            wblk m (ff_rl bm bo oo bfi bmiss bcalls ab bt biom bmq brm blk bpc bsr bsrc bsms) v n ->
            fact_holds G (R0F G) m (ufF G m gp) E (Fworld p n)).
  { intros p v n D (b & o & -> & Hp & Hn & Ho & Hr). cbn [fact_holds]. exists b, o.
    repeat split; try assumption. intros r sz Hs. left. intros Eb. apply Hr.
    exists (e_base E r). rewrite <- Eb. exact (INR r sz Hs). }
  assert (DI : forall o ch, den G m E (Sinit RM o ch) = Mem.load ch m bm o).
  { intros o ch. unfold E; cbn [den Eff e_blk e_base]. cbn [Pos.eqb RM RO RFI RMISS RCALLS RSIN RLD RBUF RIOM RMQ RRM RAR RLK RPC RSR RSRC RSMS].
    rewrite Ptrofs.unsigned_zero, Z.add_0_l. reflexivity. }
  (* env_ok *)
  assert (EO : env_ok G NBF (R0F G) gtabF (kvK acn G) m gp E).
  { split; [| split; [| split; [| split; [| split]]]].
    - intros r _. unfold E; cbn [Eff e_blk].
      repeat match goal with |- context [if Pos.eqb ?a ?b then _ else _] =>
        destruct (Pos.eqb a b) end;
      first [exact HM | exact Gbo | exact Gab | exact Gbt | exact (HS _ _ S1) | exact (HS _ _ S2)
            | exact (HS _ _ S3) | exact (HS _ _ S4) | exact (HS _ _ S6) | exact (HS _ _ S7) | exact (HS _ _ S8) | exact (HS _ _ S9) | exact (HS _ _ SL) | exact (HS _ _ SP)
            | exact (HS _ _ SR) | exact (HS _ _ SRC) | exact (HS _ _ SMS)].
    - exact (ff_sizes bo bfi bmiss bcalls bsin ab bt biom bmq brm bau blk bpc bsr bsrc bsms oo Soo).
    - intros r sz r' sz' H H' N. left.
      destruct (r0f_size r sz H) as
        [(-> & _) | [(-> & _) | [(-> & _) | [(-> & _) | [(-> & _) | [(-> & _) | [(-> & _) | [(-> & _) | [(-> & _) | [(-> & _) | [(-> & _) | [(-> & _) | [(-> & _) | [(-> & _) | (-> & _)]]]]]]]]]]]]]];
      destruct (r0f_size r' sz' H') as
        [(-> & _) | [(-> & _) | [(-> & _) | [(-> & _) | [(-> & _) | [(-> & _) | [(-> & _) | [(-> & _) | [(-> & _) | [(-> & _) | [(-> & _) | [(-> & _) | [(-> & _) | [(-> & _) | (-> & _)]]]]]]]]]]]]]];
        unfold E; cbn [Eff e_blk]; cbn [Pos.eqb RM RO RFI RMISS RCALLS RSIN RLD RBUF RIOM RMQ RRM RAR RLK RPC RSR RSRC RSMS]; congruence.
    - intros id r H. unfold gfind, gtabF in H. cbn [find fst] in H.
      repeat (let Ei := fresh "Ei" in
        match type of H with context [Pos.eqb ?i id] =>
          destruct (Pos.eqb i id) eqn:Ei;
          [ apply Pos.eqb_eq in Ei; subst id; injection H as <-;
            unfold E; cbn [Eff e_blk e_base]; cbn [Pos.eqb RM RO RFI RMISS RCALLS RSIN RLD RBUF RIOM RMQ RRM RAR RLK RPC RSR RSRC RSMS];
            refine (conj _ (conj eq_refl _)); [unfold Plt, NBF; reflexivity | assumption]
          | ] end).
      cbn in H. discriminate H.
    - intros r o ch sv H. unfold kvK in H.
      destruct H as [H | [H | [H | [H | [H | [H | []]]]]]]; injection H as <- <- <- <-;
        (split; [unfold Plt, NBF, RM; reflexivity |]); unfold addr; unfold E; cbn [Eff e_blk e_base];
        cbn [Pos.eqb RM RO RFI RMISS RCALLS RSIN RLD RBUF RIOM RMQ RRM RAR RLK RPC RSR RSRC RSMS]; rewrite ?Ptrofs.unsigned_zero, ?Z.add_0_l.
      + split; [cbn [sok nlt]; split; [cbn [nlt]; unfold Plt, NBF, RO; reflexivity | exact I] |].
        unfold E; cbn [den Eff e_blk e_base]; cbn [Pos.eqb RM RO RFI RMISS RCALLS RSIN RLD RBUF RIOM RMQ RRM RAR RLK RPC RSR RSRC RSMS]. rewrite Ptrofs.add_zero, FO. exact Lo.
      + split; [cbn [sok]; split; [cbn [nlt]; exact I | cbn [dold]; cbn; auto] |]. exact Hact.
      + split; [cbn [sok]; split; [cbn [nlt]; exact I | cbn [dold]; cbn; auto] |].
        rewrite FH. destruct HW as (_ & _ & _ & HH & _). exact HH.
      + split; [cbn [sok]; split; [cbn [nlt]; exact I | cbn [dold]; cbn; auto] |].
        rewrite FR. destruct HW as (_ & _ & _ & _ & HR & _). exact HR.
      + split; [cbn [sok nlt]; split; [cbn [nlt]; unfold Plt, NBF, RLD; reflexivity | exact I] |].
        unfold E; cbn [den Eff e_blk e_base]; cbn [Pos.eqb RM RO RFI RMISS RCALLS RSIN RLD RBUF RIOM RMQ RRM RAR RLK RPC RSR RSRC RSMS].
        rewrite Ptrofs.add_zero, FA. exact La.
      + split; [cbn [sok nlt]; split; [cbn [nlt]; unfold Plt, NBF, RPC; reflexivity | exact I] |].
        unfold E; cbn [den Eff e_blk e_base]; cbn [Pos.eqb RM RO RFI RMISS RCALLS RSIN RLD RBUF RIOM RMQ RRM RAR RLK RPC RSR RSRC RSMS].
        rewrite Ptrofs.add_zero. exact LPC.
    - intros n v H. discriminate H. }
  (* the start facts *)
  assert (PC : forall f, In f (pc0F G) -> fact_holds G (R0F G) m (ufF G m gp) E f).
  { intros f Hf. unfold pc0F in Hf. cbn [app In ffacts] in Hf.
    destruct HW as (_ & _ & HFl & _).
    specialize (HFl _ Lf). destruct HFl as (fb & fo' & ft & -> & Lt & Int).
    destruct Hf as [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | []]]]]]]]]]].
    - cbn [fact_holds]. rewrite RL. unfold ufF. rewrite ?Pos.eqb_refl. rewrite ZS. exact W.
    - cbn [fact_holds]. exists inp. rewrite DI. split; [exact Li | exact Ai].
    - apply (WW _ (Vptr fb fo')); [rewrite DI, FF; exact Lf | rewrite ZS; exact Wf].
    - apply (WW _ ar); [rewrite DI, FAr; exact Lar | rewrite ZA; exact War].
    - apply (WW _ (Vptr bsin Ptrofs.zero)).
      + unfold E; cbn [den Eff e_blk e_base]; cbn [Pos.eqb RM RO RFI RMISS RCALLS RSIN RLD RBUF RIOM RMQ RRM RAR RLK RPC RSR RSRC RSMS]. rewrite Ptrofs.add_zero. reflexivity.
      + exists bsin, Ptrofs.zero. split; [reflexivity |]. split; [exact V4 |].
        split; [clear; pose proof Ptrofs.modulus_pos; lia |]. split; [rewrite Ptrofs.unsigned_zero; clear; lia |].
        intros (o & Hin). cbn in Hin.
        repeat (destruct Hin as [Hin | Hin]; [injection Hin as Hin _; congruence |]). exact Hin.
    - apply (WW _ (Vptr bau Ptrofs.zero)).
      + unfold E; cbn [den Eff e_blk e_base]; cbn [Pos.eqb RM RO RFI RMISS RCALLS RSIN RLD RBUF RIOM RMQ RRM RAR RLK RPC RSR RSRC RSMS]. rewrite Ptrofs.add_zero. reflexivity.
      + exists bau, Ptrofs.zero. split; [reflexivity |]. split; [exact V9 |].
        split; [clear; lia |]. split; [vm_compute; discriminate |].
        intros (o & Hin). cbn in Hin.
        repeat (destruct Hin as [Hin | Hin]; [injection Hin as Hin _; congruence |]). exact Hin.
    - cbn [fact_holds map]. unfold ufF. cbn [Pos.eqb kB kW kH kM kS].
      exists bt, ot, Ptrofs.zero. split; [| exact Sot].
      unfold E; cbn [den Eff e_blk e_base]; cbn [Pos.eqb RM RO RFI RMISS RCALLS RSIN RLD RBUF RIOM RMQ RRM RAR RLK RPC RSR RSRC RSMS].
      rewrite Ptrofs.unsigned_zero, Z.add_0_l, Ptrofs.add_zero, Lb. reflexivity.
    - cbn [fact_holds map]. unfold ufF. cbn [Pos.eqb kB kW kH kM kS].
      rewrite RL, DI, FF, Lf. exists fb, fo'. split; [reflexivity |]. split; [exists ft; split; assumption |].
      destruct Wf as (b & o & E1 & _ & _ & _ & Hr). injection E1 as <- <-. exact Hr.
    - refine (fty_holds G (R0F G) m (ufF G m gp) E (Sinit RM (AirRun.fo G mario._MarioState mario._floor) Mint32) fb fo' 56 _ _ _);
        [rewrite DI, FF; exact Lf | exists ft; split; assumption | right; reflexivity].
    - refine (fty_holds G (R0F G) m (ufF G m gp) E (Sinit RM (AirRun.fo G mario._MarioState mario._floor) Mint32) fb fo' 1 _ _ _);
        [rewrite DI, FF; exact Lf | exists ft; split; assumption | left; reflexivity]. }
  (* the floor refresh *)
  assert (FRO0 : FloorRefreshOK wmotr_floor (R2 (c_posy c0)) (R2 (c_floorh c0))).
  { destruct RC as (_ & _ & _ & Hy & _ & Hf & _). exact (fresh_fro bm m _ _ Hfr Hy Hf). }
  assert (EV' : eval_funcall function_entry2 G m (Internal fK)
                  [Vptr (e_blk E RM) (Ptrofs.add (e_base E RM) Ptrofs.zero)] t m' vres).
  { unfold E; cbn [Eff e_blk e_base]; cbn [Pos.eqb RM RO RFI RMISS RCALLS RSIN RLD RBUF RIOM RMQ RRM RAR RLK RPC RSR RSRC RSMS]. rewrite Ptrofs.add_zero. exact EV. }
  destruct (Hfin m gp GPO MCg FD E t m' vres c0 EO PC EV' ltac:(exact RC) Hbud FRO0)
    as (E' & gs & X & MM & FK & RT & c2 & RC2 & MV & FF2).
  (* ---- the walk's outcome, in terms of the blocks ---- *)
  set (RL0 := ff_rl bm bo oo bfi bmiss bcalls ab bt biom bmq brm blk bpc bsr bsrc bsms) in *.
  assert (XB : forall r, Plt r NBF -> e_blk E' r = e_blk E r /\ e_base E' r = e_base E r)
    by (intros r Hr; destruct (X r Hr) as (A & B & _); exact (conj A B)).
  pose proof MM as (_ & _ & _ & _ & VP & NBm & _).
  pose proof (fk_cell G NBF (R0F G) gtabF (kvK acn G) m (ufF G m gp) gp GPO E' m' gs RM RO RLD kS clokF MM
                (fun vs H => H) FK) as FC.
  pose proof (fk_frame G NBF (R0F G) gtabF (kvK acn G) m (ufF G m gp) gp GPO E' m' gs RM RO RLD kS clokF MM
                (fun vs H => H) FK) as KR.
  pose proof (fk_action G NBF (R0F G) gtabF (kvK acn G) m (ufF G m gp) gp GPO E' m' gs RM RO RLD kS clokF MM
                (fun vs H => H) FK) as KA.
  pose proof (fk_floor G NBF (R0F G) gtabF (kvK acn G) m (ufF G m gp) gp GPO E' m' gs RM RO RLD kS clokF MM
                (fun vs H => H) FK) as KF.
  pose proof (fk_wall G NBF (R0F G) gtabF (kvK acn G) m (ufF G m gp) gp GPO E' m' gs RM RO RLD kS clokF MM
                (fun vs H => H) FK) as FWl.
  destruct (XB RM ltac:(vm_compute; reflexivity)) as (BM1 & BM2).
  destruct (XB RO ltac:(vm_compute; reflexivity)) as (BO1 & BO2).
  destruct (XB RLD ltac:(vm_compute; reflexivity)) as (BL1 & BL2).
  assert (EM : e_blk E' RM = bm /\ forall o, addr E' RM o = o).
  { rewrite BM1. split; [reflexivity |]. intros o. unfold addr. rewrite BM2.
    unfold E; cbn [Eff e_base]; cbn [Pos.eqb RO RM]. rewrite Ptrofs.unsigned_zero. clear; lia. }
  destruct EM as (EM1 & EM2).
  rewrite EM1, !EM2 in KA, KF, FWl.
  (* the kept cells *)
  assert (CM : forall o ch, In (RM, o, ch) (fk_same RM RO RLD) -> Mem.load ch m' bm o = Mem.load ch m bm o).
  { intros o ch Hin. pose proof (FC _ _ _ Hin) as H. rewrite EM1, EM2 in H. exact H. }
  (* the outcome: FALSE, or the floor and the input cells kept *)
  split.
  2:{ change (e_blk E RM) with bm in RT. apply (fresh_ret bm m m' vres Hfr RT); [| exact (CM WL_OFF Mint16signed ltac:(mem_tac)) | exact (CM 2 Mint16unsigned ltac:(mem_tac))]. intros Lsb.
      destruct Hsb as [N | K].
      - rewrite Hact in Lsb. assert (Eq : Int.repr acn = Int.repr SB_ACT) by congruence. rewrite Eq, Int.eq_true in N. discriminate N.
      - exact (K m gp GPO MCg FD E t m' vres EO PC EV'). }
  split; [| exists c2; exact (conj RC2 MV)].
  assert (CO : forall o ch, In (RO, o, ch) (fk_same RM RO RLD) ->
             Mem.load ch m' bo (Ptrofs.unsigned oo + o) = Mem.load ch m bo (Ptrofs.unsigned oo + o)).
  { intros o ch Hin. pose proof (FC _ _ _ Hin) as H. unfold addr in H. rewrite BO1, BO2 in H.
    unfold E in H; cbn [Eff e_blk e_base] in H; cbn [Pos.eqb RM RO] in H. exact H. }
  assert (CL : forall o ch, In (RLD, o, ch) (fk_same RM RO RLD) -> Mem.load ch m' ab o = Mem.load ch m ab o).
  { intros o ch Hin. pose proof (FC _ _ _ Hin) as H. unfold addr in H. rewrite BL1, BL2 in H.
    unfold E in H; cbn [Eff e_blk e_base] in H; cbn [Pos.eqb RM RO RFI RMISS RCALLS RSIN RLD] in H.
    rewrite Ptrofs.unsigned_zero, Z.add_0_l in H. exact H. }
  (* the frame *)
  assert (OFF : forall ch b z, Plt b (Mem.nextblock m) -> ~ rblk RL0 b -> Mem.load ch m' b z = Mem.load ch m b z).
  { intros ch b z Hp Hr. apply KR; [exact Hp |]. intros r sz Hs. left.
    destruct (XB r (proj1 (ff_sizes bo bfi bmiss bcalls bsin ab bt biom bmq brm bau blk bpc bsr bsrc bsms oo Soo r sz Hs))) as (B1 & _).
    rewrite B1. intros Eb. apply Hr. exists (e_base E r). rewrite <- Eb. exact (INR r sz Hs). }
  assert (OBJ : forall ch z, z + size_chunk ch <= Ptrofs.unsigned oo \/ Ptrofs.unsigned oo + SZ_OBJECT <= z ->
             Mem.load ch m' bo z = Mem.load ch m bo z).
  { intros ch z Hz. apply KR; [exact Vo |]. intros r sz Hs.
    destruct (XB r (proj1 (ff_sizes bo bfi bmiss bcalls bsin ab bt biom bmq brm bau blk bpc bsr bsrc bsms oo Soo r sz Hs))) as (B1 & B2).
    rewrite B1, B2. clear -Hs Hz D1 D3 O1 O2 O3 O5 O6 O7 O8 OL OP OSR OSRC OSMS ZO.
    destruct (r0f_size r sz Hs) as
      [(-> & _) | [(-> & ->) | [(-> & _) | [(-> & _) | [(-> & _) | [(-> & _) | [(-> & _) | [(-> & _) | [(-> & _) | [(-> & _) | [(-> & _) | [(-> & _) | [(-> & _) | [(-> & _) | (-> & _)]]]]]]]]]]]]]];
      unfold E; cbn [Eff e_blk e_base]; cbn [Pos.eqb RM RO RFI RMISS RCALLS RSIN RLD RBUF RIOM RMQ RRM RAR RLK RPC RSR RSRC RSMS];
      first [left; congruence | right; rewrite ZO; lia]. }
  (* the region list, through E' *)
  assert (RL' : map (den G m E') (wargs (R0F G)) = RL0).
  { rewrite <- RL. eapply map_den_ext; [| exact X].
    apply Forall_forall. intros a Hin. unfold wargs, R0F in Hin. cbn [map fst] in Hin.
    repeat (destruct Hin as [<- | Hin]; [vm_compute; reflexivity |]). contradiction. }
  (* a stored surface the walk found *)
  assert (NEW : forall p v, fk_surf G (R0F G) m (ufF G m gp) E' p v ->
             exists b o, v = Vptr b o /\ Plt b (Mem.nextblock m) /\ Ptrofs.unsigned o + SZ_SURFACE <= Ptrofs.modulus
               /\ styp m b o /\ ~ rblk RL0 b).
  { intros p v (b & o & -> & D & FWd & St & Nr). cbn [fact_holds] in FWd.
    destruct FWd as (b' & o' & D' & Pb & _ & Ho & _). rewrite D in D'. injection D' as <- <-.
    rewrite RL' in Nr. exists b, o. auto. }
  assert (VB : forall ch b z v, Mem.load ch m b z = Some v -> Plt b (Mem.nextblock m)).
  { intros ch b z v Hl. eapply Mem.valid_access_valid_block.
    eapply Mem.valid_access_implies; [eapply Mem.load_valid_access; exact Hl | constructor]. }
  assert (SOK : forall v, (forall sb so, v = Vptr sb so -> ~ rblk RL0 sb) -> surface_ok m v -> surface_ok m' v).
  { intros v Hr [Hn | (b & o & ty & -> & Hl & Hin)]; [left; exact Hn |].
    right. exists b, o, ty. split; [reflexivity |]. split; [| exact Hin].
    rewrite OFF; [exact Hl | exact (VB _ _ _ _ Hl) | exact (Hr b o eq_refl)]. }
  assert (SNN : forall v, (forall sb so, v = Vptr sb so -> ~ rblk RL0 sb) ->
             surface_nonnull_ok m v -> surface_nonnull_ok m' v).
  { intros v Hr (b & o & ty & -> & Hl & Hin).
    exists b, o, ty. split; [reflexivity |]. split; [| exact Hin].
    rewrite OFF; [exact Hl | exact (VB _ _ _ _ Hl) | exact (Hr b o eq_refl)]. }
  assert (STY : forall b o, Plt b (Mem.nextblock m) -> ~ rblk RL0 b -> styp m b o ->
             surface_nonnull_ok m' (Vptr b o)).
  { intros b o Hp Hr (ty & Hl & Hin). exists b, o, ty. split; [reflexivity |]. split; [| exact Hin].
    rewrite OFF by assumption. exact Hl. }
  (* the three surface cells at m' *)
  assert (SV : forall off v, off = FFW_WALL \/ off = FFW_CEIL \/ off = FFW_FLOOR ->
             Mem.load Mint32 m' bm off = Some v ->
             Mem.load Mint32 m bm off = Some v \/ v = Vint Int.zero
             \/ exists b o, v = Vptr b o /\ Plt b (Mem.nextblock m)
                  /\ Ptrofs.unsigned o + SZ_SURFACE <= Ptrofs.modulus /\ styp m b o /\ ~ rblk RL0 b).
  { intros off v [-> | [-> | ->]] Hl.
    - change FFW_WALL with 96 in Hl |- *. destruct FWl as [E0 | [E0 | (p & v' & E0 & Hs)]]; rewrite Hl in E0.
      + left. symmetry. exact E0.
      + right; left. injection E0 as <-. reflexivity.
      + right; right. injection E0 as <-. exact (NEW p v Hs).
    - left. rewrite <- Hl. symmetry. apply CM. mem_tac.
    - change FFW_FLOOR with 104 in Hl |- *. destruct KF as [E0 | (p & v' & E0 & Hs)]; rewrite Hl in E0.
      + left. symmetry. exact E0.
      + right; right. injection E0 as <-. exact (NEW p v Hs). }
  assert (SB : forall off sb so, off = FFW_WALL \/ off = FFW_CEIL \/ off = FFW_FLOOR ->
             Mem.load Mint32 m' bm off = Some (Vptr sb so) ->
             Mem.load Mint32 m bm off = Some (Vptr sb so) \/ ~ rblk RL0 sb).
  { intros off sb so Hoff Hl. destruct (SV off _ Hoff Hl) as [H | [H | (b & o & E0 & _ & _ & _ & Hr)]].
    - left. exact H.
    - discriminate H.
    - right. injection E0 as -> _. exact Hr. }
  assert (Rbo : rblk RL0 bo) by (exists oo; unfold RL0, ff_rl; cbn; auto 12).
  assert (Rbt : rblk RL0 bt) by (exists Ptrofs.zero; unfold RL0, ff_rl; cbn; auto 12).
  (* Mario's object *)
  assert (Lo' : Mem.load Mint32 m' bm FFW_OBJ = Some (Vptr bo oo)) by (rewrite CM by mem_tac; exact Lo).
  assert (COLL : forall i, 0 <= i < 4 ->
             Mem.load Mint32 m' bo (Ptrofs.unsigned oo + COLL_OFF + 4 * i)
             = Mem.load Mint32 m bo (Ptrofs.unsigned oo + COLL_OFF + 4 * i)).
  { intros i Hi. rewrite <- Z.add_assoc.
    assert (Hc : i = 0 \/ i = 1 \/ i = 2 \/ i = 3) by (clear - Hi; lia).
    destruct Hc as [-> | [-> | [-> | ->]]]; apply CO; mem_tac. }
  assert (SLOT : forall co z ch, co = oo \/ Ptrofs.unsigned co + OBJ_SIZE <= Ptrofs.unsigned oo
                   \/ Ptrofs.unsigned oo + OBJ_SIZE <= Ptrofs.unsigned co ->
             In (z, ch) [(O_INTERACT_TYPE, Mint32); (O_POSY, Mfloat32); (HITBOX_DOWN_OFF, Mfloat32);
                         (HITBOX_H_OFF, Mfloat32)] ->
             Mem.load ch m' bo (Ptrofs.unsigned co + z) = Mem.load ch m bo (Ptrofs.unsigned co + z)).
  { intros co z ch Hco Hin.
    destruct Hco as [-> | Hco].
    - destruct Hin as [E0 | [E0 | [E0 | [E0 | []]]]]; injection E0 as <- <-; apply CO; mem_tac.
    - apply OBJ. pose proof (Ptrofs.unsigned_range co) as Rco. clear - Hin Hco Rco.
      destruct Hin as [E0 | [E0 | [E0 | [E0 | []]]]]; injection E0 as <- <-;
        cbn [size_chunk]; unfold O_INTERACT_TYPE, O_POSY, HITBOX_DOWN_OFF, HITBOX_H_OFF, RAW_OFF, OBJ_SIZE, SZ_OBJECT in *;
        lia. }
  assert (COK : forall i v, 0 <= i < 4 ->
             Mem.load Mint32 m bo (Ptrofs.unsigned oo + COLL_OFF + 4 * i) = Some v ->
             coll_obj_ok m v -> coll_obj_ok m' v).
  { intros i v Hi Hl (cb & co & ty & -> & Lt & Hin & Hp & Hc).
    pose proof (Co i cb co Hi Hl) as ->.
    destruct (Hmob bo oo Lo) as (_ & _ & Hm3).
    destruct (Hm3 i bo co Hi Hl) as [N | Hco]; [congruence |].
    exists bo, co, ty. split; [reflexivity |].
    rewrite SLOT by (first [exact Hco | cbn; auto]). split; [exact Lt |]. split; [exact Hin |].
    split.
    - intros Ht. destruct (Hp Ht) as (base & top & Hb' & P1 & P2 & P3). exists base, top.
      rewrite !SLOT by (first [exact Hco | cbn; auto 6]). auto.
    - intros Ht. destruct (Hc Ht) as (y & Hy & P1). exists y. rewrite SLOT by (first [exact Hco | cbn; auto]). auto. }
  (* the new floor *)
  assert (FLR : exists fl', Mem.load Mint32 m' bm FFW_FLOOR = Some fl' /\ wblk m RL0 fl' SZ_SURFACE
                  /\ surface_nonnull_ok m' fl').
  { destruct KF as [E0 | (p & v & E0 & Hs)].
    - exists fl. change FFW_FLOOR with 104. rewrite E0. split; [exact Lf |]. split; [exact Wf |].
      destruct HW as (_ & _ & Hf & _). apply SNN; [| exact (Hf fl Lf)].
      destruct Wf as (b & o & -> & _ & _ & _ & Hr). intros sb so E1. injection E1 as <- _. exact Hr.
    - destruct (NEW p v Hs) as (b & o & -> & Pb & Hsz & St & Hr). exists (Vptr b o).
      split; [exact E0 |]. split; [| exact (STY b o Pb Hr St)].
      exists b, o. split; [reflexivity |]. split; [exact Pb |]. split; [clear; unfold SZ_SURFACE; lia |].
      split; [exact Hsz | exact Hr]. }
  destruct FLR as (fl' & Lf' & Wf' & Sf').
  (* ---- the frame world at m' ---- *)
  assert (UO : WMotRWorld.used_ok bm m')
    by (destruct KA as (a & La' & _ & Nu); exact (WMotRWorld.used_ok_other bm m' a La' Nu)).
  (* the animation world: kept (the action after is no pole action) *)
  assert (AW' : AnimWorld.anim_w G bm m').
  { destruct KA as (a & La' & _ & Nu).
    apply (AnimKeep.anim_w_keep G bm m m' gp bfi bmiss bcalls ab biom bmq brm blk bpc bsr bsrc bsms bo oo bt ot
             S1 S2 S3 S5 S6 S7 S8 SL SP SR SRC SMS Lo Lb W AW NBm
             (fun b ofs k p Hp Hq => proj2 (VP b ofs k p Hp) Hq) OFF);
      [ apply CM; mem_tac | apply CL; mem_tac | apply CL; mem_tac | apply CM; mem_tac | apply CM; mem_tac | ].
    left. intros a' La2. rewrite La' in La2. injection La2 as <-. exact (AnimKeep.not_used_not_anim _ Nu). }
  (* the level cells (FfWorld.lvl_w): globals' blocks off the regions *)
  assert (LV' : lvl_w G m')
    by exact (AnimKeep.lvl_w_keep G bm m m' bfi bmiss bcalls ab biom bmq brm blk bpc bsr bsrc bsms bo oo bt
                S1 S2 S3 S5 S6 S7 S8 SL SP SR SRC SMS AW (fun b H => D4 b (or_intror (or_intror H)))
                Hgn OFF LV).
  split; [| split; [| split; [| split; [| split; [| split; [| exact (conj UO (conj AW' LV'))]]]]]].
  - (* the action *)
    destruct KA as (a & La' & Ina & _). intros v Hl. rewrite La' in Hl. injection Hl as <-. exact Ina.
  - (* W *)
    destruct HW as (Hw & Hc & Hf & Hh & Hr & Hq & Ho).
    split; [| split; [| split; [| split; [| split; [| split]]]]].
    + intros v Hl. destruct (SV FFW_WALL v (or_introl eq_refl) Hl) as [Hl0 | [-> | (b & o & -> & Pb & _ & St & Nr)]].
      * apply SOK; [| exact (Hw v Hl0)]. intros sb so ->. exact (Wc0 FFW_WALL sb so (or_introl eq_refl) Hl0).
      * left. reflexivity.
      * right. destruct (STY b o Pb Nr St) as (b' & o' & ty & E1 & L1 & I1). exists b', o', ty. auto.
    + intros v Hl. rewrite CM in Hl by mem_tac. apply SOK; [| exact (Hc v Hl)].
      intros sb so ->. exact (Wc0 FFW_CEIL sb so (or_intror eq_refl) Hl).
    + intros v Hl. change FLOOR_OFF with FFW_FLOOR in Hl. rewrite Lf' in Hl. injection Hl as <-. exact Sf'.
    + rewrite CM by mem_tac. exact Hh.
    + rewrite CM by mem_tac. exact Hr.
    + rewrite CM by mem_tac. exact Hq.
    + destruct Ho as (mb' & mo' & s0 & n & Lmo & Ls & Hz & Ln & Hn4 & Hall).
      change MARIOOBJ_OFF with FFW_OBJ in Lmo. rewrite Lo in Lmo. injection Lmo as <- <-.
      exists bo, oo, s0, n. split; [exact Lo' |].
      split; [rewrite CO by mem_tac; exact Ls |]. split; [exact Hz |].
      split; [rewrite CO by mem_tac; exact Ln |]. split; [exact Hn4 |].
      intros i v Hi Hl. assert (Hi4 : 0 <= i < 4) by (clear - Hi Hn4; lia).
      rewrite COLL in Hl by exact Hi4. exact (COK i v Hi4 Hl (Hall i v Hi Hl)).
  - (* the animation buffer stays off the surfaces and collided objects *)
    intros ab' bt' ot' Hab' Hl.
    assert (ab' = ab) by congruence. subst ab'.
    assert (Lb0 : Mem.load Mint32 m ab 8 = Some (Vptr bt' ot')).
    { rewrite <- (CL 8 Mint32) by mem_tac. exact Hl. }
    rewrite Lb in Lb0. injection Lb0 as <- <-.
    destruct (Han ab bt ot S5 Lb) as (A1 & A2). split.
    + intros off sb so Hoff Hl2. destruct (SB off sb so Hoff Hl2) as [H | Hr].
      * exact (A1 off sb so Hoff H).
      * intros ->. exact (Hr Rbt).
    + intros mb' mo' i cb co Hl1 Hi Hl2. change MARIOOBJ_OFF with FFW_OBJ in Hl1.
      rewrite Lo' in Hl1. injection Hl1 as <- <-. rewrite COLL in Hl2 by exact Hi.
      exact (A2 bo oo i cb co Lo Hi Hl2).
  - (* Mario's object stays off the world *)
    intros mb' mo' Hl1. change MARIOOBJ_OFF with FFW_OBJ in Hl1.
    rewrite Lo' in Hl1. injection Hl1 as <- <-.
    destruct (Hmob bo oo Lo) as (A1 & A2 & A3). split; [exact A1 |]. split.
    + intros off sb so Hoff Hl2. destruct (SB off sb so Hoff Hl2) as [H | Hr].
      * exact (A2 off sb so Hoff H).
      * intros ->. exact (Hr Rbo).
    + intros i cb co Hi Hl2. rewrite COLL in Hl2 by exact Hi. exact (A3 i cb co Hi Hl2).
  - (* the A button *)
    unfold AGates.a_down_real in Hd |- *.
    rewrite (CM 156 Mptr) by mem_tac.
    assert (Lc' : Mem.load Mptr m bm 156 = Some ctl) by exact Lc.
    rewrite Lc' in Hd |- *.
    destruct Wc as (bc & oc & -> & Pc & _ & _ & Nc).
    rewrite OFF by assumption. exact Hd.
  - (* the walk's world *)
    assert (Hvok : Forall (vok gp) [Vptr bm Ptrofs.zero]).
    { constructor; [| constructor]. apply vok_mk_ptr. exact (closed_mapped_flat _ _ _ HC HM). }
    destruct (funcall_closed G m _ _ t m' vres gp EV HC HS Hvok) as (gp' & I & HC' & HS' & _).
    assert (Hinc : forall b, gp b <> None -> gp' b <> None).
    { intros b Hb'. destruct (gp b) as [[b1 d]|] eqn:E0; [| congruence].
      rewrite (I _ _ _ E0). discriminate. }
    assert (Hperm : forall b ofs k p, Plt b (Mem.nextblock m) -> Mem.perm m b ofs k p -> Mem.perm m' b ofs k p)
      by (intros b ofs k p Hp Hq; exact (proj2 (VP b ofs k p Hp) Hq)).
    split; [exact (Ple_trans _ _ _ Hgn NBm) |].
    split.
    + exists gp', bfi, bmiss, bcalls, bsin, ab, biom, bmq, brm, blk, bpc, bsr, bsrc, bsms, bo, oo, bt, ot, fl', ar, inp, ctl.
      split; [exact HC' |]. split; [exact HS' |]. split; [exact (Hinc _ HM) |].
      do 13 (split; [assumption |]).
      split; [exact Lo' |]. split; [exact Soo |].
      split; [rewrite CM by mem_tac; exact La |].
      split; [rewrite CL by mem_tac; exact Lb |].
      do 5 (split; [assumption |]).
      split; [exact (Wff_keep2 G m m' RL0 NBm Hperm OFF gp gp' Hinc W) |].
      split; [exact Lf' |].
      split; [exact (wblk_keep2 m m' RL0 NBm Hperm OFF RL0 fl' SZ_SURFACE Wf') |].
      split.
      { intros off sb so Hoff Hl2.
        destruct (SB off sb so ltac:(destruct Hoff as [-> | ->]; auto) Hl2) as [H | Hr]; [| exact Hr].
        exact (Wc0 off sb so Hoff H). }
      split; [rewrite CM by mem_tac; exact Lar |].
      split; [exact (wblk_keep2 m m' RL0 NBm Hperm OFF RL0 ar SZ_AREA War) |].
      split; [rewrite CM by mem_tac; exact Li |]. split; [exact Ai |].
      split; [rewrite CM by mem_tac; exact Lc |].
      split; [exact (wblk_keep2 m m' RL0 NBm Hperm OFF RL0 ctl SZ_CTL Wc) |].
      split; [intros i cb co Hi Hl2; change FFW_COLL with COLL_OFF in Hl2; rewrite COLL in Hl2 by exact Hi;
              exact (Co i cb co Hi Hl2) |].
      rewrite CM by mem_tac; exact LPC.
    + exact (floor_data_keep2 G m m' RL0 NBm Hperm OFF gp W FD).
Qed.


End KBROW.

(* ---- the airborne cases, with five rows proved ---- *)
Section KBCASES.
Variable lp : Clight.program.
Hypothesis H12 : linked12 lp.
Local Notation G := (globalenv lp).
Hypothesis Hdma : os_dma_floor.
Hypothesis Hsq : sqrtf_spec.
Hypothesis Hsqf : sqrtf_float.
Variable bm : block.
Hypothesis Hbm : Genv.find_symbol G level_update._gMarioStates = Some bm.
Variable MWF : mem -> Prop.

(* the other six no-A cases keep their AirSplit row *)
Definition air_case_rest3 : Prop :=
  forall n f fd v, In (n, f) air_case_list -> f <> AIR._act_freefall -> f <> AIR._act_air_hit_wall ->
    f <> AIR._act_soft_bonk -> f <> AIR._act_backward_air_kb -> f <> AIR._act_forward_air_kb ->
    resolves lp f fd ->
    seg_okR lp bm MWF fd [v]
      (fun m => v = Vptr bm Ptrofs.zero /\ Mem.load Mint32 m bm 12 = Some (Vint (Int.repr n)) /\ fresh bm m)
      (fun m' vr => vr = Vint Int.zero \/ fresh bm m').

Theorem air_case_rows_ff3 : air_case_rest3 -> air_case_rows lp bm MWF.
Proof.
  intros Hrest.
  apply (AhwRow.air_case_rows_ff2 lp H12 Hdma Hsq Hsqf bm Hbm MWF).
  intros n f fd v Hin Hne Hne1 Hr.
  destruct (Pos.eq_dec f AIR._act_soft_bonk) as [-> | Hne2].
  { pose proof (sb_label n Hin) as ->.
    pose proof (resolve_pin_fd lp _ _ _ _ (linked12_LO_air lp H12) dm_sb Hr) as ->.
    intros m t m' vr c Hok Hw (-> & Hact & Hfr) Hok' Hc Hb Hev.
    destruct Hok as (Vm & _).
    exact (kb_reshape _ _ _ (kb_row lp H12 bm Hbm _ _ (kb_kfinal lp H12 Hdma Hsq Hsqf _ _ sbcheck12 eq_refl)
             (or_intror (kb_kret0 lp H12 Hdma Hsq Hsqf _ _ sb0check12)) m t m' vr c Vm Hw Hc Hb Hact Hfr Hev)). }
  destruct (Pos.eq_dec f AIR._act_backward_air_kb) as [-> | Hne3].
  { pose proof (bkb_label n Hin) as ->.
    pose proof (resolve_pin_fd lp _ _ _ _ (linked12_LO_air lp H12) dm_bkb Hr) as ->.
    intros m t m' vr c Hok Hw (-> & Hact & Hfr) Hok' Hc Hb Hev.
    destruct Hok as (Vm & _).
    exact (kb_reshape _ _ _ (kb_row lp H12 bm Hbm _ _ (kb_kfinal lp H12 Hdma Hsq Hsqf _ _ bkbcheck12 eq_refl)
             (or_introl eq_refl) m t m' vr c Vm Hw Hc Hb Hact Hfr Hev)). }
  destruct (Pos.eq_dec f AIR._act_forward_air_kb) as [-> | Hne4].
  { pose proof (fkb_label n Hin) as ->.
    pose proof (resolve_pin_fd lp _ _ _ _ (linked12_LO_air lp H12) dm_fkb Hr) as ->.
    intros m t m' vr c Hok Hw (-> & Hact & Hfr) Hok' Hc Hb Hev.
    destruct Hok as (Vm & _).
    exact (kb_reshape _ _ _ (kb_row lp H12 bm Hbm _ _ (kb_kfinal lp H12 Hdma Hsq Hsqf _ _ fkbcheck12 eq_refl)
             (or_introl eq_refl) m t m' vr c Vm Hw Hc Hb Hact Hfr Hev)). }
  exact (Hrest n f fd v Hin Hne Hne1 Hne2 Hne3 Hne4 Hr).
Qed.

(* the other five no-A cases (dive, both rollouts, butt-slide air, slide
   kick) keep their AirSplit row *)
Definition air_case_rest4 : Prop :=
  forall n f fd v, In (n, f) air_case_list -> f <> AIR._act_freefall -> f <> AIR._act_air_hit_wall ->
    f <> AIR._act_soft_bonk -> f <> AIR._act_backward_air_kb -> f <> AIR._act_forward_air_kb ->
    f <> AIR._act_ground_pound ->
    resolves lp f fd ->
    seg_okR lp bm MWF fd [v]
      (fun m => v = Vptr bm Ptrofs.zero /\ Mem.load Mint32 m bm 12 = Some (Vint (Int.repr n)) /\ fresh bm m)
      (fun m' vr => vr = Vint Int.zero \/ fresh bm m').

Theorem air_case_rows_ff4 : air_case_rest4 -> air_case_rows lp bm MWF.
Proof.
  intros Hrest. apply air_case_rows_ff3.
  intros n f fd v Hin Hne Hne1 Hne2 Hne3 Hne4 Hr.
  destruct (Pos.eq_dec f AIR._act_ground_pound) as [-> | Hne5].
  { pose proof (gp_label n Hin) as ->.
    pose proof (resolve_pin_fd lp _ _ _ _ (linked12_LO_air lp H12) dm_gp Hr) as ->.
    intros m t m' vr c Hok Hw (-> & Hact & Hfr) Hok' Hc Hb Hev.
    destruct Hok as (Vm & _).
    exact (kb_reshape _ _ _ (kb_row lp H12 bm Hbm _ _ (gp_kfinal lp H12 Hdma Hsq Hsqf)
             (or_introl eq_refl) m t m' vr c Vm Hw Hc Hb Hact Hfr Hev)). }
  exact (Hrest n f fd v Hin Hne Hne1 Hne2 Hne3 Hne4 Hne5 Hr).
Qed.

(* the other four no-A cases (both rollouts, butt-slide air, slide kick)
   keep their AirSplit row *)
Definition air_case_rest5 : Prop :=
  forall n f fd v, In (n, f) air_case_list -> f <> AIR._act_freefall -> f <> AIR._act_air_hit_wall ->
    f <> AIR._act_soft_bonk -> f <> AIR._act_backward_air_kb -> f <> AIR._act_forward_air_kb ->
    f <> AIR._act_ground_pound -> f <> AIR._act_dive ->
    resolves lp f fd ->
    seg_okR lp bm MWF fd [v]
      (fun m => v = Vptr bm Ptrofs.zero /\ Mem.load Mint32 m bm 12 = Some (Vint (Int.repr n)) /\ fresh bm m)
      (fun m' vr => vr = Vint Int.zero \/ fresh bm m').

Theorem air_case_rows_ff5 : air_case_rest5 -> air_case_rows lp bm MWF.
Proof.
  intros Hrest. apply air_case_rows_ff4.
  intros n f fd v Hin Hne Hne1 Hne2 Hne3 Hne4 Hne5 Hr.
  destruct (Pos.eq_dec f AIR._act_dive) as [-> | Hne6].
  { pose proof (dv_label n Hin) as ->.
    pose proof (resolve_pin_fd lp _ _ _ _ (linked12_LO_air lp H12) dm_dv Hr) as ->.
    intros m t m' vr c Hok Hw (-> & Hact & Hfr) Hok' Hc Hb Hev.
    destruct Hok as (Vm & _).
    exact (kb_reshape _ _ _ (kb_row lp H12 bm Hbm _ _ (kb_kfinal lp H12 Hdma Hsq Hsqf _ _ dvcheck12 eq_refl)
             (or_introl eq_refl) m t m' vr c Vm Hw Hc Hb Hact Hfr Hev)). }
  exact (Hrest n f fd v Hin Hne Hne1 Hne2 Hne3 Hne4 Hne5 Hne6 Hr).
Qed.
(* the other two no-A cases (butt-slide air, slide kick) keep their
   AirSplit row *)
Definition air_case_rest6 : Prop :=
  forall n f fd v, In (n, f) air_case_list -> f <> AIR._act_freefall -> f <> AIR._act_air_hit_wall ->
    f <> AIR._act_soft_bonk -> f <> AIR._act_backward_air_kb -> f <> AIR._act_forward_air_kb ->
    f <> AIR._act_ground_pound -> f <> AIR._act_dive ->
    f <> AIR._act_forward_rollout -> f <> AIR._act_backward_rollout ->
    resolves lp f fd ->
    seg_okR lp bm MWF fd [v]
      (fun m => v = Vptr bm Ptrofs.zero /\ Mem.load Mint32 m bm 12 = Some (Vint (Int.repr n)) /\ fresh bm m)
      (fun m' vr => vr = Vint Int.zero \/ fresh bm m').

Theorem air_case_rows_ff6 : air_case_rest6 -> air_case_rows lp bm MWF.
Proof.
  intros Hrest. apply air_case_rows_ff5.
  intros n f fd v Hin Hne Hne1 Hne2 Hne3 Hne4 Hne5 Hne6 Hr.
  destruct (Pos.eq_dec f AIR._act_forward_rollout) as [-> | Hne7].
  { pose proof (fr_label n Hin) as ->.
    pose proof (resolve_pin_fd lp _ _ _ _ (linked12_LO_air lp H12) dm_fr Hr) as ->.
    intros m t m' vr c Hok Hw (-> & Hact & Hfr) Hok' Hc Hb Hev.
    destruct Hok as (Vm & _).
    exact (kb_reshape _ _ _ (kb_row lp H12 bm Hbm _ _ (rl_kfinal_all lp H12 Hdma Hsq Hsqf _ _ rlfcheck12)
             (or_introl eq_refl) m t m' vr c Vm Hw Hc Hb Hact Hfr Hev)). }
  destruct (Pos.eq_dec f AIR._act_backward_rollout) as [-> | Hne8].
  { pose proof (br_label n Hin) as ->.
    pose proof (resolve_pin_fd lp _ _ _ _ (linked12_LO_air lp H12) dm_br Hr) as ->.
    intros m t m' vr c Hok Hw (-> & Hact & Hfr) Hok' Hc Hb Hev.
    destruct Hok as (Vm & _).
    exact (kb_reshape _ _ _ (kb_row lp H12 bm Hbm _ _ (rl_kfinal_all lp H12 Hdma Hsq Hsqf _ _ rlbcheck12)
             (or_introl eq_refl) m t m' vr c Vm Hw Hc Hb Hact Hfr Hev)). }
  exact (Hrest n f fd v Hin Hne Hne1 Hne2 Hne3 Hne4 Hne5 Hne6 Hne7 Hne8 Hr).
Qed.

(* the one other no-A case (slide kick) keeps its AirSplit row *)
Definition air_case_rest7 : Prop :=
  forall n f fd v, In (n, f) air_case_list -> f <> AIR._act_freefall -> f <> AIR._act_air_hit_wall ->
    f <> AIR._act_soft_bonk -> f <> AIR._act_backward_air_kb -> f <> AIR._act_forward_air_kb ->
    f <> AIR._act_ground_pound -> f <> AIR._act_dive ->
    f <> AIR._act_forward_rollout -> f <> AIR._act_backward_rollout -> f <> AIR._act_butt_slide_air ->
    resolves lp f fd ->
    seg_okR lp bm MWF fd [v]
      (fun m => v = Vptr bm Ptrofs.zero /\ Mem.load Mint32 m bm 12 = Some (Vint (Int.repr n)) /\ fresh bm m)
      (fun m' vr => vr = Vint Int.zero \/ fresh bm m').

(* butt-slide air, at any state: from the dispatch's floor refresh (the
   bounce's stale floorHeight is refreshed by update_mario_inputs before the
   next dispatch, FrameSplit.frame_stage) *)
Theorem air_case_rows_ff7 : air_case_rest7 -> air_case_rows lp bm MWF.
Proof.
  intros Hrest. apply air_case_rows_ff6.
  intros n f fd v Hin Hne Hne1 Hne2 Hne3 Hne4 Hne5 Hne6 Hne7 Hne8 Hr.
  destruct (Pos.eq_dec f AIR._act_butt_slide_air) as [-> | Hne9].
  { pose proof (bsa_label n Hin) as ->.
    pose proof (resolve_pin_fd lp _ _ _ _ (linked12_LO_air lp H12) dm_bsa Hr) as ->.
    intros m t m' vr c Hok Hw (-> & Hact & Hfr) Hok' Hc Hb Hev.
    destruct Hok as (Vm & _).
    exact (kb_reshape _ _ _ (kb_row lp H12 bm Hbm _ _ (bs_kfinal_all lp H12 Hdma Hsq Hsqf _ bscheck12)
             (or_introl eq_refl) m t m' vr c Vm Hw Hc Hb Hact Hfr Hev)). }
  exact (Hrest n f fd v Hin Hne Hne1 Hne2 Hne3 Hne4 Hne5 Hne6 Hne7 Hne8 Hne9 Hr).
Qed.

(* every no-A case: slide kick, at any state (SkRun: past its bounce the
   step is S_sk_bounced, from the dispatch's floor refresh), is the last; no
   case is left over (air_case_fns_in) *)
Theorem air_case_rows_ff8 : air_case_rows lp bm MWF.
Proof.
  apply air_case_rows_ff7.
  intros n f fd v Hin Hne Hne1 Hne2 Hne3 Hne4 Hne5 Hne6 Hne7 Hne8 Hne9 Hr.
  destruct (Pos.eq_dec f AIR._act_slide_kick) as [-> | Hne10].
  { pose proof (sk_label n Hin) as ->.
    pose proof (resolve_pin_fd lp _ _ _ _ (linked12_LO_air lp H12) dm_sk Hr) as ->.
    intros m t m' vr c Hok Hw (-> & Hact & Hfr) Hok' Hc Hb Hev.
    destruct Hok as (Vm & _).
    exact (kb_reshape _ _ _ (kb_row lp H12 bm Hbm _ _ (sk_kfinal_all lp H12 Hdma Hsq Hsqf _ skcheck12)
             (or_introl eq_refl) m t m' vr c Vm Hw Hc Hb Hact Hfr Hev)). }
  exfalso. pose proof (air_case_fns_in n f Hin) as I. unfold air_case_fns in I.
  repeat (destruct I as [I | I]; [symmetry in I; contradiction |]). exact I.
Qed.
End KBCASES.
