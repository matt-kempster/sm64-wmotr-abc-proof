(* ====================================================================== *)
(* PoleRowT (GOAL 2): the six pole cases of the automatic dispatcher,      *)
(* walked with Mario's REAL animation data (2026-10-23).                   *)
(*                                                                        *)
(* PoleRow's construction over PoleRunT's walks: set_mario_animation is    *)
(* walked inline, reading the DMA table and gMarioAnims, and the top-of-  *)
(* pole actions' set_pole_position takes return_mario_anim_y_translation. *)
(* The start state comes from the frame world, which now carries          *)
(* AnimWorld.anim_w (the table, gMarioAnims, the buffer, and in a pole    *)
(* action after the grab the animation state anim_st); PoleStartT.pick    *)
(* chooses the variant the action's walks cover.  At the end the frame    *)
(* world holds again, anim_w included: the table is not written (no_reg   *)
(* RTAB), the base is kept (AnimWorld.anim_base_keep) and the walk's      *)
(* AnimEnd check gives anim_st when the action is still a pole action.    *)
(*                                                                        *)
(* Premises beyond the link: the DMA floor and the PI DMA copying the ROM *)
(* bytes (OsDmaFloor.pi_dma_anim_spec, TRUST 0.8(f)).  The audio calls   *)
(* are their real bodies (SndXc clobbers, regions RSR / RSRC / RSMS).      *)
(* ====================================================================== *)

From Coq Require Import List ZArith Lia Reals Lra.
From compcert Require Import Coqlib Maps AST Integers Floats Values Memory Events Globalenvs
  Ctypes Clight ClightBigstep Linking.
From SM64.Generated Require mario_step mario mario_actions_airborne mario_actions_automatic memory
  surface_collision level_update camera game_init graph_node.
From SM64.Proofs Require Import Interp.SymExec2 Interp.LinkGenv MarioModel.LinkedTwelve
  MarioModel.OsDmaFloor HeightInvariant HeightMoveCatalog WMotRLevel WMotRWorld.
From SM64.Proofs Require Import RealFrameLinked AirborneSurface NoAImpliesNoFlyLinked.
From SM64.Proofs.WMotRRequiresA Require Import FloorList FloorExec AirRun AirStart AirMatch
  ExtInert FfRun FfWorld FrameSplit AirSplit FfKeepCheck FfKeep FfClass KbRun
  PoleXc PoleClass PoleKeep PoleSound PoleRun AnimData AnimWorld AnimEnd PoleRunT PoleStartT PoleRow.
From SM64.Proofs.WMotRRequiresA Require KbRow FloorHeight AnimKeep.
From SM64.Proofs Require Import Generic.ClosedMem Generic.ClightClosed.
From SM64.Proofs Require Generic.SymbolicLinking.
Import ListNotations.

Module AUT := mario_actions_automatic.

Lemma rblk_sub : forall vs vs', (forall b o, In (Some (Vptr b o)) vs' -> rblk vs b) ->
  forall b, rblk vs' b -> rblk vs b.
Proof. intros vs vs' H b (o & Hin). exact (H b o Hin). Qed.

Section POLEROWT.
Variable lp : Clight.program.
Hypothesis H12 : linked12 lp.
Local Notation G := (globalenv lp).

Variable bm : block.
Hypothesis Hbm : Genv.find_symbol G level_update._gMarioStates = Some bm.

(* the case: each start variant's walk *)
Variable acn : Z.
Variable fK : function.
Hypothesis Hfin : forall v, In v (avars acn) -> pfinalT lp acn v fK.
Hypothesis Hpa : In acn POLE6.

Lemma acnT_u : Int.unsigned (Int.repr acn) = acn.
Proof. destruct Hpa as [<- | [<- | [<- | [<- | [<- | [<- | []]]]]]]; reflexivity. Qed.

Lemma acnT_pole : In (Int.unsigned (Int.repr acn)) pole_acts.
Proof.
  rewrite acnT_u. destruct Hpa as [<- | [<- | [<- | [<- | [<- | [<- | []]]]]]]; unfold pole_acts; cbn [In]; auto 8.
Qed.

(* the walk's environment *)
Definition EplT (bo bfi bmiss bcalls bsin ab bt biom bmq brm bau blk bpc bsr bsrc bsms bbt bgp blv btab bga bauc : block)
    (oo uo ot otab : ptrofs) : senv :=
  mke (fun r => if Pos.eqb r RM then bm else if Pos.eqb r RO then bo
                else if Pos.eqb r RFI then bfi else if Pos.eqb r RMISS then bmiss
                else if Pos.eqb r RCALLS then bcalls else if Pos.eqb r RSIN then bsin
                else if Pos.eqb r RLD then ab else if Pos.eqb r RBUF then bt
                else if Pos.eqb r RIOM then biom else if Pos.eqb r RMQ then bmq
                else if Pos.eqb r RRM then brm else if Pos.eqb r RAR then bau
                else if Pos.eqb r RLK then blk else if Pos.eqb r RPC then bpc
                else if Pos.eqb r RSR then bsr else if Pos.eqb r RSRC then bsrc
                else if Pos.eqb r RSMS then bsms
                else if Pos.eqb r RU then bo else if Pos.eqb r RBT then bbt
                else if Pos.eqb r RGP then bgp else if Pos.eqb r RLV then blv
                else if Pos.eqb r RTAB then btab else if Pos.eqb r RGA then bga
                else if Pos.eqb r RAUC then bauc else bm)
      (fun r => if Pos.eqb r RO then oo else if Pos.eqb r RU then uo
                else if Pos.eqb r RBUF then ot else if Pos.eqb r RTAB then otab else Ptrofs.zero)
      (fun _ => None).

Lemma R0T_eq : R0T G =
  [(RM, szs G mario._MarioState); (RO, szs G mario._Object); (RFI, 2); (RMISS, 4); (RCALLS, 6);
   (RLD, szs G mario._DmaHandlerList); (RBUF, BUFSZ); (RIOM, 20); (RMQ, 24); (RRM, 4);
   (RLK, szs G camera._LakituState); (RPC, SZ_PCS);
   (RSR, Ptrofs.modulus); (RSRC, Ptrofs.modulus); (RSMS, Ptrofs.modulus);
   (RTAB, TABSZ); (RU, szs G mario._Object)].
Proof. reflexivity. Qed.

Lemma r0t_size : forall r sz, r0_size (R0T G) r = Some sz ->
  (r = RM /\ sz = szs G mario._MarioState) \/ (r = RO /\ sz = szs G mario._Object)
  \/ (r = RFI /\ sz = 2) \/ (r = RMISS /\ sz = 4) \/ (r = RCALLS /\ sz = 6)
  \/ (r = RLD /\ sz = szs G mario._DmaHandlerList) \/ (r = RBUF /\ sz = BUFSZ)
  \/ (r = RIOM /\ sz = 20) \/ (r = RMQ /\ sz = 24) \/ (r = RRM /\ sz = 4)
  \/ (r = RLK /\ sz = szs G camera._LakituState) \/ (r = RPC /\ sz = SZ_PCS)
  \/ (r = RSR /\ sz = Ptrofs.modulus) \/ (r = RSRC /\ sz = Ptrofs.modulus)
  \/ (r = RSMS /\ sz = Ptrofs.modulus)
  \/ (r = RTAB /\ sz = TABSZ) \/ (r = RU /\ sz = szs G mario._Object).
Proof.
  intros r sz H. rewrite R0T_eq in H. unfold r0_size in H. cbn [find fst] in H.
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
  destruct (Pos.eqb RSR r) eqn:E15; [apply Pos.eqb_eq in E15; injection H as <-; auto 26 |].
  destruct (Pos.eqb RSRC r) eqn:E16; [apply Pos.eqb_eq in E16; injection H as <-; auto 28 |].
  destruct (Pos.eqb RSMS r) eqn:E17; [apply Pos.eqb_eq in E17; injection H as <-; auto 30 |].
  destruct (Pos.eqb RTAB r) eqn:E14; [apply Pos.eqb_eq in E14; injection H as <-; auto 32 |].
  destruct (Pos.eqb RU r) eqn:E11; [apply Pos.eqb_eq in E11; injection H as <-; auto 34 | discriminate].
Qed.

Ltac r0t_cases H :=
  destruct (r0t_size _ _ H) as
    [(-> & ?) | [(-> & ?) | [(-> & ?) | [(-> & ?) | [(-> & ?) | [(-> & ?) | [(-> & ?) | [(-> & ?)
    | [(-> & ?) | [(-> & ?) | [(-> & ?) | [(-> & ?) | [(-> & ?) | [(-> & ?) | [(-> & ?) | [(-> & ?)
    | (-> & ?)]]]]]]]]]]]]]]]].

Ltac eplT := cbn [EplT e_blk e_base];
  cbn [Pos.eqb RM RO RFI RMISS RCALLS RSIN RLD RBUF RIOM RMQ RRM RAR RLK RPC RSR RSRC RSMS RU RBT RGP RLV RTAB RGA RAUC].
Ltac eplT_in H := cbn [EplT e_blk e_base] in H;
  cbn [Pos.eqb RM RO RFI RMISS RCALLS RSIN RLD RBUF RIOM RMQ RRM RAR RLK RPC RSR RSRC RSMS RU RBT RGP RLV RTAB RGA RAUC] in H.

(* membership in FfKeepCheck.fk_same *)
Ltac mem_tac := unfold fk_same; repeat (first [left; reflexivity | right]).

(* THE POLE ROW, with the animation world *)
Theorem pole_rowT : forall m t m' vres c0,
  Plt bm (Mem.nextblock m) -> fworld lp bm m ->
  read_cells bm m c0 -> budget_ok c0 ->
  Mem.load Mint32 m bm 12 = Some (Vint (Int.repr acn)) -> fresh bm m ->
  eval_funcall function_entry2 G m (Internal fK) [Vptr bm Ptrofs.zero] t m' vres ->
  (fworld lp bm m' /\ exists c2, read_cells bm m' c2 /\ MoveChain wmotr_floor wmotr_pole wmotr_cannon c0 c2)
  /\ (vres = Vint Int.zero \/ fresh bm m').
Proof.
  intros m t m' vres c0 Vm (Ha & HW & Han & Hmob & Hd & FW & UO & AW & LV) RC Hbud Hact Hfr EV.
  pose proof FW as (Hgn & EX & FD).
  destruct EX as (gp & bfi & bmiss & bcalls & bsin & ab & biom & bmq & brm & blk & bpc & bsr & bsrc & bsms & bo & oo & bt & ot & fl & ar & inp & ctl &
                  HC & HS & HM & S1 & S2 & S3 & S4 & S5 & S6 & S7 & S8 & SL & SP & SR & SRC & SMS & Lo & Soo & La & Lb & Sot & D1 & D2 & D3 & D4 &
                  W & Lf & Wf & Wc0 & Lar & War & Li & Ai & Lc & Wc & Co & LPC).
  destruct (KbRow.ff_layout lp H12) as (FO & FA & FF & FAr & FH & FR & ZO & ZS & ZA & ZM & ZD).
  destruct (aud_sym lp H12) as (bau & S9).
  destruct (SymbolicLinking.linkorder_resolves_symbol lp AUT.prog _ _ (linked12_LO_aut lp H12) dm_bt)
    as (bbt & Sbt).
  destruct (SymbolicLinking.linkorder_resolves_symbol lp AUT.prog _ _ (linked12_LO_aut lp H12) dm_gpo)
    as (bgp & Sgp).
  destruct (SymbolicLinking.linkorder_resolves_symbol lp AUT.prog _ _ (linked12_LO_aut lp H12) dm_lv)
    as (blv & Slv).
  (* ---- the animation world ---- *)
  pose proof AW as (ab' & bga & bauc & btab & otab & bt' & ot' & mb & mo & AB & ST).
  pose proof AB as (Sab & Sga & Sau & L0 & L8 & Lm & Sy & DA1 & DA2 & DA3 & DA4 & DA5 & Z1 & Z2 & Z3 & Pbt
                    & TOK & GA & TA & AC & _).
  assert (ab' = ab) by congruence. subst ab'.
  rewrite Lb in L8. injection L8 as <- <-.
  assert (Lm' : Mem.load Mint32 m bm FFW_OBJ = Some (Vptr mb mo)) by exact Lm.
  rewrite Lo in Lm'. injection Lm' as <- <-.
  (* the start variant *)
  assert (STa : In acn anim_acts -> anim_st m ab bga bt ot bo oo).
  { intros Ia. apply (ST _ Hact). rewrite acnT_u. exact Ia. }
  destruct (pick acn m ab bga bt ot bo oo Hpa STa) as (v & Hv & Vok).
  (* ---- the pole (used_ok, in a pole action) ---- *)
  destruct (UO _ Hact) as (UP & _).
  destruct (UP acnT_pole) as (ub & uo & Lu & LP & UA & (Suo & PPm) & VN).
  assert (Lo0 : Mem.load Mint32 m bm MARIOOBJ_OFF = Some (Vptr bo oo)) by exact Lo.
  destruct (PPm bo oo Lo0) as (-> & pp & Lpp & Fpp & Rpp).
  destruct UA as (Ubm & UAm).
  destruct (UAm bo oo Lo0) as [N | Dis]; [congruence |].
  destruct LP as (base & top & Hpl & Ht & P1 & P2 & P3).
  destruct (pole_low base top Hpl Ht) as (-> & ->).
  unfold OBJ_SPAN in Suo, Dis.
  set (E := EplT bo bfi bmiss bcalls bsin ab bt biom bmq brm bau blk bpc bsr bsrc bsms bbt bgp blv btab bga bauc oo uo ot otab).
  (* validity *)
  assert (GPO : forall b x, gp b = Some x -> Plt b (Mem.nextblock m))
    by (intros b x H; exact (closed_old gp m b x HC H)).
  assert (MCg : forall ch b z v, gp b <> None -> Mem.load ch m b z = Some v -> val_old gp v)
    by (intros ch b z v' Hb Hl; exact (closed_load gp m ch b z v' HC Hb Hl)).
  assert (GV : forall b, gp b <> None -> Plt b (Mem.nextblock m))
    by (intros b H; destruct (gp b) as [x|] eqn:E0; [exact (GPO b x E0) | congruence]).
  assert (Gbo : gp bo <> None) by exact (closed_load gp m _ _ _ _ HC HM Lo).
  assert (Gab : gp ab <> None) by exact (HS _ _ S5).
  assert (Gbt : gp bt <> None) by exact (closed_load gp m _ _ _ _ HC Gab Lb).
  assert (Gtab : gp btab <> None) by exact (closed_load gp m _ _ _ _ HC Gab L0).
  assert (Vo : Plt bo (Mem.nextblock m)) by exact (GV _ Gbo).
  assert (Vab : Plt ab (Mem.nextblock m)) by exact (GV _ Gab).
  assert (Vbt : Plt bt (Mem.nextblock m)) by exact (GV _ Gbt).
  assert (Vtab : Plt btab (Mem.nextblock m)) by exact (GV _ Gtab).
  pose proof (KbRow.sym_valid lp m _ _ Hgn S1) as V1. pose proof (KbRow.sym_valid lp m _ _ Hgn S2) as V2.
  pose proof (KbRow.sym_valid lp m _ _ Hgn S3) as V3. pose proof (KbRow.sym_valid lp m _ _ Hgn S4) as V4.
  pose proof (KbRow.sym_valid lp m _ _ Hgn S6) as V6. pose proof (KbRow.sym_valid lp m _ _ Hgn S7) as V7.
  pose proof (KbRow.sym_valid lp m _ _ Hgn S8) as V8. pose proof (KbRow.sym_valid lp m _ _ Hgn S9) as V9.
  pose proof (KbRow.sym_valid lp m _ _ Hgn Slv) as V10.
  pose proof (KbRow.sym_valid lp m _ _ Hgn Sga) as VGA. pose proof (KbRow.sym_valid lp m _ _ Hgn Sau) as VAU.
  (* distinctness: symbols, then Mario's object, the buffer and the table *)
  assert (DS : forall i1 i2 b1 b2, Genv.find_symbol G i1 = Some b1 -> Genv.find_symbol G i2 = Some b2 ->
             Pos.eqb i1 i2 = false -> b1 <> b2)
    by (intros i1 i2 b1 b2 H1 H2 N; apply (KbRow.sym_ne lp i1 i2 b1 b2 H1 H2); apply Pos.eqb_neq; exact N).
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
  pose proof (DS _ _ _ _ S9 Hbm eq_refl) as N90. pose proof (DS _ _ _ _ S9 S1 eq_refl) as N91.
  pose proof (DS _ _ _ _ S9 S2 eq_refl) as N92. pose proof (DS _ _ _ _ S9 S3 eq_refl) as N93.
  pose proof (DS _ _ _ _ S9 S4 eq_refl) as N94. pose proof (DS _ _ _ _ S9 S5 eq_refl) as N95.
  pose proof (DS _ _ _ _ S9 S6 eq_refl) as N96. pose proof (DS _ _ _ _ S9 S7 eq_refl) as N97.
  pose proof (DS _ _ _ _ S9 S8 eq_refl) as N98.
  pose proof (DS _ _ _ _ Slv S4 eq_refl) as NL4. pose proof (DS _ _ _ _ Slv S9 eq_refl) as NL9.
  pose proof (DS _ _ _ _ Slv Hbm eq_refl) as NL0. pose proof (DS _ _ _ _ Slv S1 eq_refl) as NL1.
  pose proof (DS _ _ _ _ Slv S2 eq_refl) as NL2. pose proof (DS _ _ _ _ Slv S3 eq_refl) as NL3.
  pose proof (DS _ _ _ _ Slv S5 eq_refl) as NL5. pose proof (DS _ _ _ _ Slv S6 eq_refl) as NL6.
  pose proof (DS _ _ _ _ Slv S7 eq_refl) as NL7. pose proof (DS _ _ _ _ Slv S8 eq_refl) as NL8.
  assert (Slv' : Genv.find_symbol G mario._gCurrLevelNum = Some blv) by exact Slv.
  destruct (D4 blv (or_intror (or_intror (or_introl Slv')))) as (OL & TL).
  destruct (D4 bau (or_intror (or_introl S9))) as (O9 & T9).
  pose proof (KbRow.sym_valid lp m _ _ Hgn SL) as VK.
  pose proof (DS _ _ _ _ SL Hbm eq_refl) as NK0. pose proof (DS _ _ _ _ SL S1 eq_refl) as NK1.
  pose proof (DS _ _ _ _ SL S2 eq_refl) as NK2. pose proof (DS _ _ _ _ SL S3 eq_refl) as NK3.
  pose proof (DS _ _ _ _ SL S4 eq_refl) as NK4. pose proof (DS _ _ _ _ SL S5 eq_refl) as NK5.
  pose proof (DS _ _ _ _ SL S6 eq_refl) as NK6. pose proof (DS _ _ _ _ SL S7 eq_refl) as NK7.
  pose proof (DS _ _ _ _ SL S8 eq_refl) as NK8. pose proof (DS _ _ _ _ SL S9 eq_refl) as NK9.
  pose proof (DS _ _ _ _ SL Slv eq_refl) as NKL. pose proof (DS _ _ _ _ SL Sbt eq_refl) as NKT.
  pose proof (DS _ _ _ _ SL Sgp eq_refl) as NKG.
  destruct (D4 blk ltac:(left; cbn; auto 12)) as (OK & TK).
  pose proof (KbRow.sym_valid lp m _ _ Hgn SP) as VPC.
  pose proof (DS _ _ _ _ SP Hbm eq_refl) as NP0. pose proof (DS _ _ _ _ SP S1 eq_refl) as NP1.
  pose proof (DS _ _ _ _ SP S2 eq_refl) as NP2. pose proof (DS _ _ _ _ SP S3 eq_refl) as NP3.
  pose proof (DS _ _ _ _ SP S4 eq_refl) as NP4. pose proof (DS _ _ _ _ SP S5 eq_refl) as NP5.
  pose proof (DS _ _ _ _ SP S6 eq_refl) as NP6. pose proof (DS _ _ _ _ SP S7 eq_refl) as NP7.
  pose proof (DS _ _ _ _ SP S8 eq_refl) as NP8. pose proof (DS _ _ _ _ SP S9 eq_refl) as NP9.
  pose proof (DS _ _ _ _ SP SL eq_refl) as NPK. pose proof (DS _ _ _ _ SP Slv eq_refl) as NPL.
  pose proof (DS _ _ _ _ SP Sbt eq_refl) as NPT. pose proof (DS _ _ _ _ SP Sgp eq_refl) as NPG.
  (* gMarioAnims and gAreaUpdateCounter against the other symbols *)
  pose proof (DS _ _ _ _ Sga Hbm eq_refl) as NG0. pose proof (DS _ _ _ _ Sga S1 eq_refl) as NG1.
  pose proof (DS _ _ _ _ Sga S2 eq_refl) as NG2. pose proof (DS _ _ _ _ Sga S3 eq_refl) as NG3.
  pose proof (DS _ _ _ _ Sga S5 eq_refl) as NG5.
  pose proof (DS _ _ _ _ Sga S6 eq_refl) as NG6. pose proof (DS _ _ _ _ Sga S7 eq_refl) as NG7.
  pose proof (DS _ _ _ _ Sga S8 eq_refl) as NG8.
  pose proof (DS _ _ _ _ Sga SL eq_refl) as NGK. pose proof (DS _ _ _ _ Sga SP eq_refl) as NGP.
  pose proof (DS _ _ _ _ Sau Hbm eq_refl) as NA0. pose proof (DS _ _ _ _ Sau S1 eq_refl) as NA1.
  pose proof (DS _ _ _ _ Sau S2 eq_refl) as NA2. pose proof (DS _ _ _ _ Sau S3 eq_refl) as NA3.
  pose proof (DS _ _ _ _ Sau S5 eq_refl) as NA5.
  pose proof (DS _ _ _ _ Sau S6 eq_refl) as NA6. pose proof (DS _ _ _ _ Sau S7 eq_refl) as NA7.
  pose proof (DS _ _ _ _ Sau S8 eq_refl) as NA8.
  pose proof (DS _ _ _ _ Sau SL eq_refl) as NAK. pose proof (DS _ _ _ _ Sau SP eq_refl) as NAP.
  pose proof (proj2 (Sy _ _ Sga)) as GT. pose proof (proj2 (Sy _ _ Sau)) as AT.
  (* the table's block against the others *)
  pose proof (proj1 (Sy _ _ Hbm)) as T00. pose proof (proj1 (Sy _ _ S1)) as T01.
  pose proof (proj1 (Sy _ _ S2)) as T02. pose proof (proj1 (Sy _ _ S3)) as T03.
  pose proof (proj1 (Sy _ _ S4)) as T04. pose proof (proj1 (Sy _ _ S5)) as T05.
  pose proof (proj1 (Sy _ _ S6)) as T06. pose proof (proj1 (Sy _ _ S7)) as T07.
  pose proof (proj1 (Sy _ _ S8)) as T08. pose proof (proj1 (Sy _ _ S9)) as T09.
  pose proof (proj1 (Sy _ _ SL)) as T0K. pose proof (proj1 (Sy _ _ SP)) as T0P.
  pose proof (proj1 (Sy _ _ Slv)) as T0L. pose proof (proj1 (Sy _ _ Sga)) as T0G.
  pose proof (proj1 (Sy _ _ Sau)) as T0A.
  destruct (D4 bpc ltac:(left; cbn; auto 14)) as (OP & TP).
  (* the audio regions (sSoundRequests, sSoundRequestCount, sSoundMovingSpeed) *)
  pose proof (DS _ _ _ _ SR Hbm eq_refl) as NsrHbm. pose proof (DS _ _ _ _ SR S1 eq_refl) as NsrS1.
  pose proof (DS _ _ _ _ SR S2 eq_refl) as NsrS2. pose proof (DS _ _ _ _ SR S3 eq_refl) as NsrS3.
  pose proof (DS _ _ _ _ SR S4 eq_refl) as NsrS4. pose proof (DS _ _ _ _ SR S5 eq_refl) as NsrS5.
  pose proof (DS _ _ _ _ SR S6 eq_refl) as NsrS6. pose proof (DS _ _ _ _ SR S7 eq_refl) as NsrS7.
  pose proof (DS _ _ _ _ SR S8 eq_refl) as NsrS8. pose proof (DS _ _ _ _ SR S9 eq_refl) as NsrS9.
  pose proof (DS _ _ _ _ SR SL eq_refl) as NsrSL. pose proof (DS _ _ _ _ SR SP eq_refl) as NsrSP.
  pose proof (DS _ _ _ _ SR Slv eq_refl) as NsrSlv. pose proof (DS _ _ _ _ SR Sbt eq_refl) as NsrSbt.
  pose proof (DS _ _ _ _ SR Sgp eq_refl) as NsrSgp.
  pose proof (DS _ _ _ _ SR Sga eq_refl) as NsrSga. pose proof (DS _ _ _ _ SR Sau eq_refl) as NsrSau.
  pose proof (DS _ _ _ _ SRC Hbm eq_refl) as NsrcHbm. pose proof (DS _ _ _ _ SRC S1 eq_refl) as NsrcS1.
  pose proof (DS _ _ _ _ SRC S2 eq_refl) as NsrcS2. pose proof (DS _ _ _ _ SRC S3 eq_refl) as NsrcS3.
  pose proof (DS _ _ _ _ SRC S4 eq_refl) as NsrcS4. pose proof (DS _ _ _ _ SRC S5 eq_refl) as NsrcS5.
  pose proof (DS _ _ _ _ SRC S6 eq_refl) as NsrcS6. pose proof (DS _ _ _ _ SRC S7 eq_refl) as NsrcS7.
  pose proof (DS _ _ _ _ SRC S8 eq_refl) as NsrcS8. pose proof (DS _ _ _ _ SRC S9 eq_refl) as NsrcS9.
  pose proof (DS _ _ _ _ SRC SL eq_refl) as NsrcSL. pose proof (DS _ _ _ _ SRC SP eq_refl) as NsrcSP.
  pose proof (DS _ _ _ _ SRC Slv eq_refl) as NsrcSlv. pose proof (DS _ _ _ _ SRC Sbt eq_refl) as NsrcSbt.
  pose proof (DS _ _ _ _ SRC Sgp eq_refl) as NsrcSgp. pose proof (DS _ _ _ _ SRC SR eq_refl) as NsrcSR.
  pose proof (DS _ _ _ _ SRC Sga eq_refl) as NsrcSga. pose proof (DS _ _ _ _ SRC Sau eq_refl) as NsrcSau.
  pose proof (DS _ _ _ _ SMS Hbm eq_refl) as NsmsHbm. pose proof (DS _ _ _ _ SMS S1 eq_refl) as NsmsS1.
  pose proof (DS _ _ _ _ SMS S2 eq_refl) as NsmsS2. pose proof (DS _ _ _ _ SMS S3 eq_refl) as NsmsS3.
  pose proof (DS _ _ _ _ SMS S4 eq_refl) as NsmsS4. pose proof (DS _ _ _ _ SMS S5 eq_refl) as NsmsS5.
  pose proof (DS _ _ _ _ SMS S6 eq_refl) as NsmsS6. pose proof (DS _ _ _ _ SMS S7 eq_refl) as NsmsS7.
  pose proof (DS _ _ _ _ SMS S8 eq_refl) as NsmsS8. pose proof (DS _ _ _ _ SMS S9 eq_refl) as NsmsS9.
  pose proof (DS _ _ _ _ SMS SL eq_refl) as NsmsSL. pose proof (DS _ _ _ _ SMS SP eq_refl) as NsmsSP.
  pose proof (DS _ _ _ _ SMS Slv eq_refl) as NsmsSlv. pose proof (DS _ _ _ _ SMS Sbt eq_refl) as NsmsSbt.
  pose proof (DS _ _ _ _ SMS Sgp eq_refl) as NsmsSgp. pose proof (DS _ _ _ _ SMS SR eq_refl) as NsmsSR.
  pose proof (DS _ _ _ _ SMS SRC eq_refl) as NsmsSRC.
  pose proof (DS _ _ _ _ SMS Sga eq_refl) as NsmsSga. pose proof (DS _ _ _ _ SMS Sau eq_refl) as NsmsSau.
  pose proof (proj1 (Sy _ _ SR)) as T0SR. pose proof (proj1 (Sy _ _ SRC)) as T0SRC.
  pose proof (proj1 (Sy _ _ SMS)) as T0SMS.
  destruct (D4 bsr ltac:(left; cbn; auto 20)) as (OSR & TSR).
  destruct (D4 bsrc ltac:(left; cbn; auto 20)) as (OSRC & TSRC).
  destruct (D4 bsms ltac:(left; cbn; auto 20)) as (OSMS & TSMS).
  pose proof (KbRow.sym_valid lp m _ _ Hgn SR) as VSR. pose proof (KbRow.sym_valid lp m _ _ Hgn SRC) as VSRC.
  pose proof (KbRow.sym_valid lp m _ _ Hgn SMS) as VSMS.
  destruct (D4 bfi ltac:(left; cbn; auto 10)) as (O1 & T1). destruct (D4 bmiss ltac:(left; cbn; auto 10)) as (O2 & T2).
  destruct (D4 bcalls ltac:(left; cbn; auto 10)) as (O3 & T3). destruct (D4 bsin ltac:(left; cbn; auto 10)) as (O4 & T4).
  destruct (D4 ab ltac:(left; cbn; auto 10)) as (O5 & T5). destruct (D4 biom ltac:(left; cbn; auto 10)) as (O6 & T6).
  destruct (D4 bmq ltac:(left; cbn; auto 10)) as (O7 & T7). destruct (D4 brm ltac:(left; cbn; auto 10)) as (O8 & T8).
  clear DS.
  set (RL0 := ff_rl bm bo oo bfi bmiss bcalls ab bt biom bmq brm blk bpc bsr bsrc bsms) in *.
  assert (Rbo : rblk RL0 bo) by (exists oo; unfold RL0, ff_rl; cbn; auto 12).
  assert (Rbt : rblk RL0 bt) by (exists Ptrofs.zero; unfold RL0, ff_rl; cbn; auto 12).
  assert (Ntab : ~ rblk RL0 btab).
  { intros (o & Hin). unfold RL0, ff_rl in Hin. cbn in Hin.
    repeat (destruct Hin as [Hin | Hin]; [injection Hin as Hin _; congruence |]). exact Hin. }
  assert (Nga : ~ rblk RL0 bga).
  { intros (o & Hin). unfold RL0, ff_rl in Hin. cbn in Hin.
    repeat (destruct Hin as [Hin | Hin]; [injection Hin as Hin _; congruence |]). exact Hin. }
  (* the region pointer list: ffw's (the buffer at ot), the table, the pole *)
  assert (RL : map (den G m E) (wargs (R0T G))
               = map Some [Vptr bm Ptrofs.zero; Vptr bo oo; Vptr bfi Ptrofs.zero; Vptr bmiss Ptrofs.zero;
                           Vptr bcalls Ptrofs.zero; Vptr ab Ptrofs.zero; Vptr bt ot;
                           Vptr biom Ptrofs.zero; Vptr bmq Ptrofs.zero; Vptr brm Ptrofs.zero;
                           Vptr blk Ptrofs.zero; Vptr bpc Ptrofs.zero; Vptr bsr Ptrofs.zero; Vptr bsrc Ptrofs.zero;
                           Vptr bsms Ptrofs.zero; Vptr btab otab; Vptr bo uo]).
  { rewrite R0T_eq. unfold wargs. cbn [map fst den]. unfold E; eplT.
    rewrite !Ptrofs.add_zero. reflexivity. }
  assert (RLe : forall b, rblk (map Some [Vptr bm Ptrofs.zero; Vptr bo oo; Vptr bfi Ptrofs.zero; Vptr bmiss Ptrofs.zero;
                           Vptr bcalls Ptrofs.zero; Vptr ab Ptrofs.zero; Vptr bt ot;
                           Vptr biom Ptrofs.zero; Vptr bmq Ptrofs.zero; Vptr brm Ptrofs.zero;
                           Vptr blk Ptrofs.zero; Vptr bpc Ptrofs.zero; Vptr bsr Ptrofs.zero; Vptr bsrc Ptrofs.zero;
                           Vptr bsms Ptrofs.zero; Vptr btab otab; Vptr bo uo]) b ->
                      rblk (RL0 ++ [Some (Vptr btab otab)]) b).
  { apply rblk_sub. intros b o Hin. cbn in Hin.
    repeat (destruct Hin as [Hin | Hin];
            [ injection Hin as <- <-;
              first [ exists otab; apply in_or_app; right; left; reflexivity
                    | destruct Rbo as (o1 & Ho1); exists o1; apply in_or_app; left; exact Ho1
                    | destruct Rbt as (o1 & Ho1); exists o1; apply in_or_app; left; exact Ho1
                    | exists Ptrofs.zero; apply in_or_app; left; unfold RL0, ff_rl; cbn; auto 17 ] | ]).
    contradiction. }
  (* each region's block but the table's is on the list *)
  assert (INR : forall r sz, r0_size (R0T G) r = Some sz -> r <> RTAB -> rblk RL0 (e_blk E r)).
  { intros r sz H Nr. r0t_cases H; try (exfalso; apply Nr; reflexivity); unfold E; eplT; unfold RL0, ff_rl.
    all: first [exact Rbo | exact Rbt | eexists; cbn; auto 17]. }
  assert (WW : forall p v n, den G m E p = Some v -> wblk m RL0 v n -> (forall b o, v = Vptr b o -> b <> btab) ->
            fact_holds G (R0T G) m (ufT G m gp) E (Fworld p n)).
  { intros p v' n D (b & o & -> & Hp & Hn & Ho & Hr) Nt. cbn [fact_holds]. exists b, o.
    repeat split; try assumption. intros r sz Hs. left. intros Eb.
    destruct (Pos.eq_dec r RTAB) as [-> | Nr].
    - apply (Nt b o eq_refl). rewrite <- Eb. unfold E; eplT. reflexivity.
    - apply Hr. rewrite <- Eb. exact (INR r sz Hs Nr). }
  assert (DI : forall o ch, den G m E (Sinit RM o ch) = Mem.load ch m bm o).
  { intros o ch. unfold E; cbn [den]; eplT. rewrite Ptrofs.unsigned_zero, Z.add_0_l. reflexivity. }
  assert (DO : forall o ch, den G m E (Sinit RO o ch) = Mem.load ch m bo (Ptrofs.unsigned oo + o)).
  { intros o ch. unfold E; cbn [den]; eplT. reflexivity. }
  (* the region sizes *)
  assert (SZ : forall r sz, r0_size (R0T G) r = Some sz ->
            Plt r NBT /\ 0 <= sz /\ Ptrofs.unsigned (e_base E r) + sz <= Ptrofs.modulus).
  { intros r sz H. clear - H12 H Soo Suo ZO ZM ZD Z1 Z2. pose proof (Ptrofs.unsigned_range oo) as Ro.
    assert (Mod : Ptrofs.modulus = 4294967296) by reflexivity.
    assert (Q1 : 0 <= szs G mario._MarioState)
      by (unfold szs; pose proof (sizeof_pos G (Tstruct mario._MarioState noattr)); lia).
    pose proof (lak_size lp H12) as ZL.
    assert (Q2 : 0 <= szs G mario._DmaHandlerList)
      by (unfold szs; pose proof (sizeof_pos G (Tstruct mario._DmaHandlerList noattr)); lia).
    unfold SZ_OBJECT in ZO, Soo, Suo.
    r0t_cases H; subst sz; unfold E; eplT; rewrite ?Ptrofs.unsigned_zero, ?ZO;
      unfold Plt, NBT, SZ_PCS, BUFSZ, TABSZ, ANIM_COUNT in *; repeat split; lia. }
  (* env_ok *)
  assert (EO : env_ok G NBT (R0T G) gtabT (kvT acn G v) m gp E).
  { split; [| split; [| split; [| split; [| split]]]].
    - intros r _. unfold E; cbn [EplT e_blk].
      repeat match goal with |- context [if Pos.eqb ?a ?b then _ else _] =>
        destruct (Pos.eqb a b) end;
      first [exact HM | exact Gbo | exact Gab | exact Gbt | exact Gtab | exact (HS _ _ S1) | exact (HS _ _ S2)
            | exact (HS _ _ S3) | exact (HS _ _ S4) | exact (HS _ _ S6) | exact (HS _ _ S7) | exact (HS _ _ S8)
            | exact (HS _ _ S9) | exact (HS _ _ Sbt) | exact (HS _ _ Sgp) | exact (HS _ _ Slv) | exact (HS _ _ SL)
            | exact (HS _ _ SP) | exact (HS _ _ Sga) | exact (HS _ _ Sau)
            | exact (HS _ _ SR) | exact (HS _ _ SRC) | exact (HS _ _ SMS)].
    - exact SZ.
    - intros r sz r' sz' H H' N.
      r0t_cases H; r0t_cases H'; subst sz sz'; unfold E; eplT;
        first [left; congruence | right; rewrite ?ZO; unfold SZ_OBJECT in *; lia].
    - intros id r H. unfold gfind, gtabT, gtabP, gtabF in H. cbn [app find fst] in H.
      repeat (let Ei := fresh "Ei" in
        match type of H with context [Pos.eqb ?i id] =>
          destruct (Pos.eqb i id) eqn:Ei;
          [ apply Pos.eqb_eq in Ei; subst id; injection H as <-;
            unfold E; eplT;
            refine (conj _ (conj eq_refl _)); [unfold Plt, NBT; reflexivity | assumption]
          | ] end).
      cbn in H. discriminate H.
    - intros r o ch sv H. unfold kvT in H. apply in_app_or in H as [H | H].
      { unfold kvP, kvK in H. cbn [app] in H.
        destruct H as [H | [H | [H | [H | [H | [H | [H | [H | [H | [H | []]]]]]]]]]]; injection H as <- <- <- <-;
          (split; [unfold Plt, NBT, RM, RU; reflexivity |]); unfold addr; unfold E; eplT;
          rewrite ?Ptrofs.unsigned_zero, ?Z.add_0_l.
        + split; [cbn [sok nlt]; split; [cbn [nlt]; unfold Plt, NBT, RO; reflexivity | exact I] |].
          unfold E; cbn [den]; eplT. rewrite Ptrofs.add_zero, FO. exact Lo.
        + split; [cbn [sok]; split; [cbn [nlt]; exact I | cbn [dold]; cbn; auto] |]. exact Hact.
        + split; [cbn [sok]; split; [cbn [nlt]; exact I | cbn [dold]; cbn; auto] |].
          rewrite FH. destruct HW as (_ & _ & _ & HH & _). exact HH.
        + split; [cbn [sok]; split; [cbn [nlt]; exact I | cbn [dold]; cbn; auto] |].
          rewrite FR. destruct HW as (_ & _ & _ & _ & HR & _). exact HR.
        + split; [cbn [sok nlt]; split; [cbn [nlt]; unfold Plt, NBT, RLD; reflexivity | exact I] |].
          unfold E; cbn [den]; eplT. rewrite Ptrofs.add_zero, FA. exact La.
        + split; [cbn [sok nlt]; split; [cbn [nlt]; unfold Plt, NBT, RPC; reflexivity | exact I] |].
          unfold E; cbn [den]; eplT. rewrite Ptrofs.add_zero. exact LPC.
        + split; [cbn [sok nlt]; split; [cbn [nlt]; unfold Plt, NBT, RU; reflexivity | exact I] |].
          unfold E; cbn [den]; eplT. rewrite Ptrofs.add_zero. exact Lu.
        + split; [cbn [sok]; split; [cbn [nlt]; exact I | cbn [dold]; cbn; auto] |]. exact P1.
        + split; [cbn [sok]; split; [cbn [nlt]; exact I | cbn [dold]; cbn; auto] |]. exact P2.
        + split; [cbn [sok]; split; [cbn [nlt]; exact I | cbn [dold]; cbn; auto] |]. exact P3. }
      apply in_app_or in H as [H | H].
      { (* the list's dmaTable and bufTarget *)
        destruct H as [H | [H | []]]; injection H as <- <- <- <-;
          (split; [unfold Plt, NBT, RLD; reflexivity |]);
          (split; [cbn [sok nlt]; split; [unfold Plt, NBT; reflexivity | exact I] |]);
          unfold addr; unfold E; cbn [den]; eplT; rewrite ?Ptrofs.unsigned_zero, ?Z.add_0_l, ?Ptrofs.add_zero.
        + exact L0.
        + exact Lb. }
      apply in_app_or in H as [H | H].
      { (* the DMA table *)
        destruct TOK as (TK1 & TK2 & TK3).
        unfold tab_kv in H. destruct H as [H | [H | H]].
        - injection H as <- <- <- <-. split; [unfold Plt, NBT, RTAB; reflexivity |].
          split; [cbn [sok]; split; [exact I | cbn [dold]; cbn; auto] |].
          unfold addr; unfold E; cbn [den]; eplT. rewrite Z.add_0_r. exact TK1.
        - injection H as <- <- <- <-. split; [unfold Plt, NBT, RTAB; reflexivity |].
          split; [cbn [sok nlt]; split; [unfold Plt, NBT; reflexivity | exact I] |].
          unfold addr; unfold E; cbn [den]; eplT. rewrite Ptrofs.add_zero. exact TK2.
        - apply in_flat_map in H as ([[j o'] s] & Hj & H).
          destruct (TK3 j o' s Hj) as (TA1 & TA2).
          destruct H as [H | [H | []]]; injection H as <- <- <- <-;
            (split; [unfold Plt, NBT, RTAB; reflexivity |]);
            (split; [cbn [sok]; split; [exact I | cbn [dold]; cbn; auto] |]);
            unfold addr; unfold E; cbn [den]; eplT.
          + rewrite <- Z.add_assoc in TA1. exact TA1.
          + rewrite <- Z.add_assoc in TA2. exact TA2. }
      { (* the start variant's cells *)
        destruct v as [st | k | ks]; cbn [av_kv] in H; [contradiction | | contradiction].
        destruct Vok as (L4 & L56 & L60 & L72 & _ & BO).
        unfold loaded_kv in H. apply in_app_or in H as [H | H].
        - destruct H as [H | [H | [H | [H | []]]]]; injection H as <- <- <- <-;
            (split; [unfold Plt, NBT, RO, RLD; reflexivity |]);
            (split; [cbn [sok nlt dold]; split; [first [exact I | unfold Plt, NBT; reflexivity] | cbn; auto] |]);
            unfold addr; unfold E; cbn [den]; eplT; rewrite ?Ptrofs.unsigned_zero, ?Z.add_0_l, ?Ptrofs.add_zero.
          + exact L56.
          + exact L60.
          + exact L72.
          + rewrite Ptrofs.add_zero_l. exact L4.
        - unfold buf_kv in H. apply in_map_iff in H as ([[rel ch'] bv] & E1 & Hin).
          injection E1 as <- <- <- <-.
          split; [unfold Plt, NBT, RBUF; reflexivity |].
          pose proof (BO rel ch' bv Hin) as Hl.
          destruct bv as [z | rr]; cbn [bsv bval] in Hl |- *.
          + split; [cbn [sok]; split; [exact I | cbn [dold]; cbn; auto] |].
            unfold addr; unfold E; cbn [den]; eplT. exact Hl.
          + split; [cbn [sok nlt]; split; [unfold Plt, NBT; reflexivity | exact I] |].
            unfold addr; unfold E; cbn [den]; eplT. exact Hl. }
    - intros n v' H. discriminate H. }
  (* the start facts *)
  assert (PC : forall f, In f (pc0T acn G v) ->
                 fact_nlt NBT f /\ fact_holds G (R0T G) m (ufT G m gp) E f).
  { intros f Hf. split; [exact (pc0T_nlt acn G v f Hf) |].
    unfold pc0T in Hf. apply in_app_or in Hf as [Hf | Hf].
    - cbn [In] in Hf.
      destruct Hf as [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | []]]]]]]]]]]]].
      + cbn [fact_holds]. rewrite RL. unfold ufT. rewrite ?Pos.eqb_refl. rewrite ZS.
        apply (AnimWorld.Wff_mono G m gp _ (RL0 ++ [Some (Vptr btab otab)]) _ RLe).
        apply AnimWorld.Wff_tab; [intros id b Hs Eb; exact (proj1 (Sy id b Hs) Eb) | exact TA | exact W].
      + cbn [fact_holds]. exists inp. rewrite DI. split; [exact Li | exact Ai].
      + apply (WW _ ar); [rewrite DI, FAr; exact Lar | rewrite ZA; exact War |].
        intros b o ->. exact (AC 144 b o (or_introl eq_refl) Lar).
      + apply (WW _ (Vptr bsin Ptrofs.zero)).
        * unfold E; cbn [den]; eplT. rewrite Ptrofs.add_zero. reflexivity.
        * exists bsin, Ptrofs.zero. split; [reflexivity |]. split; [exact V4 |].
          split; [clear; pose proof Ptrofs.modulus_pos; lia |]. split; [rewrite Ptrofs.unsigned_zero; clear; lia |].
          intros (o & Hin). unfold RL0, ff_rl in Hin. cbn in Hin.
          repeat (destruct Hin as [Hin | Hin]; [injection Hin as Hin _; congruence |]). exact Hin.
        * intros b o E1. injection E1 as <- _. exact T04.
      + apply (WW _ (Vptr bau Ptrofs.zero)).
        * unfold E; cbn [den]; eplT. rewrite Ptrofs.add_zero. reflexivity.
        * exists bau, Ptrofs.zero. split; [reflexivity |]. split; [exact V9 |].
          split; [clear; lia |]. split; [vm_compute; discriminate |].
          intros (o & Hin). unfold RL0, ff_rl in Hin. cbn in Hin.
          repeat (destruct Hin as [Hin | Hin]; [injection Hin as Hin _; congruence |]). exact Hin.
        * intros b o E1. injection E1 as <- _. exact T09.
      + apply (WW _ (Vptr blv Ptrofs.zero)).
        * unfold E; cbn [den]; eplT. rewrite Ptrofs.add_zero. reflexivity.
        * exists blv, Ptrofs.zero. split; [reflexivity |]. split; [exact V10 |].
          split; [clear; lia |]. split; [vm_compute; discriminate |].
          intros (o & Hin). unfold RL0, ff_rl in Hin. cbn in Hin.
          repeat (destruct Hin as [Hin | Hin]; [injection Hin as Hin _; congruence |]). exact Hin.
        * intros b o E1. injection E1 as <- _. exact T0L.
      + cbn [fact_holds map]. rewrite kv_polepos. unfold ufT. cbn [Pos.eqb kB kW kH kS kL kC kP].
        rewrite DO. rewrite Lpp. exact (conj Fpp Rpp).
      + (* m->controller *)
        apply (WW _ ctl); [rewrite DI; exact Lc | exact Wc |].
        intros b o ->. exact (AC 156 b o (or_intror eq_refl) Lc).
      + apply (WW _ (Vptr bauc Ptrofs.zero)).
        * unfold E; cbn [den]; eplT. rewrite Ptrofs.add_zero. reflexivity.
        * exists bauc, Ptrofs.zero. split; [reflexivity |]. split; [exact VAU |].
          split; [clear; lia |]. split; [vm_compute; discriminate |].
          intros (o & Hin). unfold RL0, ff_rl in Hin. cbn in Hin.
          repeat (destruct Hin as [Hin | Hin]; [injection Hin as Hin _; congruence |]). exact Hin.
        * intros b o E1. injection E1 as <- _. exact T0A.
      + apply (WW _ (Vptr bga Ptrofs.zero)).
        * unfold E; cbn [den]; eplT. rewrite Ptrofs.add_zero. reflexivity.
        * exists bga, Ptrofs.zero. split; [reflexivity |]. split; [exact VGA |].
          split; [clear; pose proof Ptrofs.modulus_pos; lia |]. split; [rewrite Ptrofs.unsigned_zero; clear; lia |].
          intros (o & Hin). unfold RL0, ff_rl in Hin. cbn in Hin.
          repeat (destruct Hin as [Hin | Hin]; [injection Hin as Hin _; congruence |]). exact Hin.
        * intros b o E1. injection E1 as <- _. exact T0G.
      + cbn [fact_holds map]. unfold ufT. cbn [Pos.eqb kB kW kH kS kL kC kP kF kYp kBUF kGA].
        exists bt, ot. unfold E; cbn [den]; eplT. rewrite Ptrofs.add_zero.
        split; [reflexivity |]. split; [intros id b' Hs; exact (proj2 (Sy id b' Hs)) |].
        split; [exact Pbt |]. split; [exact Z3 | exact Z2].
      + cbn [fact_holds map]. unfold ufT. cbn [Pos.eqb kB kW kH kS kL kC kP kF kYp kBUF kGA].
        exists bga. unfold E; cbn [den]; eplT. rewrite Ptrofs.add_zero.
        split; [reflexivity | exact (proj1 GA)].
    - destruct v as [st | k | ks]; cbn [av_pc] in Hf; [contradiction | |].
      + destruct Hf as [<- | []]. destruct Vok as (_ & L56 & _ & _ & (f0 & Rf & L64) & _).
        cbn [fact_holds map kF_fact]. unfold ufT. cbn [Pos.eqb kB kW kH kS kL kC kP kF].
        rewrite DO. exists (Int.repr f0). split; [exact L64 |].
        destruct (avars_AL _ _ Hv) as [-> | [-> | ->]];
          [change (hs_le 9) with 52 in * | change (hs_le 11) with 17 in * | change (hs_le 12) with 17 in *];
          rewrite !Int.signed_repr by (unfold Int.min_signed, Int.max_signed; cbn; lia); lia.
      + unfold vfacts in Hf. apply in_flat_map in Hf as (k & Hk & Hf).
        destruct (Vok k Hk) as ((i & L56 & Ni) & C).
        pose proof (avars_AR _ _ Hv k Hk) as Ik.
        destruct Hf as [<- | [<- | []]].
        * unfold nid_true. cbn [fact_holds den]. unfold E; eplT. rewrite L56. cbn beta iota.
          exact (nid_holds G m i k Ik Ni).
        * unfold caddr_true. cbn [fact_holds den]. unfold E; eplT.
          rewrite Ptrofs.unsigned_zero, Z.add_0_l, Ptrofs.add_zero_l.
          destruct C as [C | (o & C & Ho & No)]; rewrite C; cbn beta iota.
          -- apply (caddr_holds G m bga (hs_off k) _ (proj2 GA));
               [ destruct (hs_ids_cases _ Ik) as [-> | [-> | ->]]; cbn; unfold GA_SIZE; lia | left; reflexivity ].
          -- apply (caddr_holds G m bga (hs_off k) _ (proj2 GA));
               [ destruct (hs_ids_cases _ Ik) as [-> | [-> | ->]]; cbn; unfold GA_SIZE; lia | right ].
             exists o. split; [reflexivity |]. split; [exact Ho | exact No]. }
  assert (EV' : eval_funcall function_entry2 G m (Internal fK)
                  [Vptr (e_blk E RM) (Ptrofs.add (e_base E RM) Ptrofs.zero)] t m' vres).
  { unfold E; eplT. rewrite Ptrofs.add_zero. exact EV. }
  assert (IR0 : InRange c0) by exact (proj1 Hbud).
  assert (STv : av_st v = true -> ast E m).
  { intros Hs. destruct v as [st | k | ks]; cbn [av_st] in Hs.
    - subst st. unfold ast, E; eplT. exact Vok.
    - unfold ast, E; eplT. apply STa. apply (avars_LR acn _ Hv). intros st N; discriminate N.
    - unfold ast, E; eplT. apply STa. apply (avars_LR acn _ Hv). intros st N; discriminate N. }
  destruct (Hfin v Hv m gp GPO MCg FD E t m' vres c0 EO PC STv EV' ltac:(exact RC) IR0)
    as (E' & gs & X & MM & FK & NR & NTb & RT & AST & c2 & RC2 & RM2 & Hout & Hvy & Hk).
  (* ---- the walk's outcome, in terms of the blocks ---- *)
  assert (XB : forall r, Plt r NBT -> e_blk E' r = e_blk E r /\ e_base E' r = e_base E r)
    by (intros r Hr; destruct (X r Hr) as (A & B & _); exact (conj A B)).
  pose proof MM as (_ & _ & _ & _ & VP & NBm & _).
  pose proof (fkp_cell G NBT (R0T G) gtabT (kvT acn G v) m (ufT G m gp) gp GPO E' m' gs RM RO RLD kS clokF MM
                (fun vs H => H) FK) as FC.
  pose proof (fkp_frame_except G NBT (R0T G) gtabT (kvT acn G v) m (ufT G m gp) gp GPO E' m' gs RM RO RLD kS clokF MM
                (fun vs H => H) FK RTAB NTb ltac:(cbn; unfold RTAB, RBUF, RIOM, RMQ, RRM; intuition discriminate)) as KRT.
  pose proof (fkp_frame_except G NBT (R0T G) gtabT (kvT acn G v) m (ufT G m gp) gp GPO E' m' gs RM RO RLD kS clokF MM
                (fun vs H => H) FK RU NR ltac:(cbn; unfold RU, RBUF, RIOM, RMQ, RRM; intuition discriminate)) as KRX.
  pose proof (fkp_action G NBT (R0T G) gtabT (kvT acn G v) m (ufT G m gp) gp GPO E' m' gs RM RO RLD kS clokF MM
                (fun vs H => H) FK) as KA.
  pose proof (fkp_floor G NBT (R0T G) gtabT (kvT acn G v) m (ufT G m gp) gp GPO E' m' gs RM RO RLD kS clokF MM
                (fun vs H => H) FK) as KF.
  pose proof (fkp_wall G NBT (R0T G) gtabT (kvT acn G v) m (ufT G m gp) gp GPO E' m' gs RM RO RLD kS clokF MM
                (fun vs H => H) FK) as FWl.
  destruct (XB RM ltac:(vm_compute; reflexivity)) as (BM1 & BM2).
  destruct (XB RO ltac:(vm_compute; reflexivity)) as (BO1 & BO2).
  destruct (XB RLD ltac:(vm_compute; reflexivity)) as (BL1 & BL2).
  assert (EM : e_blk E' RM = bm /\ forall o, addr E' RM o = o).
  { rewrite BM1. split; [reflexivity |]. intros o. unfold addr. rewrite BM2.
    unfold E; eplT. rewrite Ptrofs.unsigned_zero. clear; lia. }
  destruct EM as (EM1 & EM2).
  rewrite EM1, !EM2 in KA, KF, FWl.
  (* the kept cells *)
  assert (CM : forall o ch, In (RM, o, ch) (fk_same RM RO RLD) -> Mem.load ch m' bm o = Mem.load ch m bm o).
  { intros o ch Hin. pose proof (FC _ _ _ Hin) as H. rewrite EM1, EM2 in H. exact H. }
  (* the outcome: FALSE, or the floor and the input cells kept *)
  split; [| change (e_blk E RM) with bm in RT;
            exact (fresh_ret_ns bm m m' vres acn Hact
                     ltac:(destruct Hpa as [E0 | [E0 | [E0 | [E0 | [E0 | [E0 | []]]]]]]; rewrite <- E0; reflexivity)
                     Hfr RT (CM WL_OFF Mint16signed ltac:(mem_tac)) (CM 2 Mint16unsigned ltac:(mem_tac)))].
  split; [| exists c2; split; [exact RC2 | apply Relation_Operators.rt_step; exact RM2]].
  assert (CO : forall o ch, In (RO, o, ch) (fk_same RM RO RLD) ->
             Mem.load ch m' bo (Ptrofs.unsigned oo + o) = Mem.load ch m bo (Ptrofs.unsigned oo + o)).
  { intros o ch Hin. pose proof (FC _ _ _ Hin) as H. unfold addr in H. rewrite BO1, BO2 in H.
    unfold E in H; eplT_in H. exact H. }
  assert (CL : forall o ch, In (RLD, o, ch) (fk_same RM RO RLD) -> Mem.load ch m' ab o = Mem.load ch m ab o).
  { intros o ch Hin. pose proof (FC _ _ _ Hin) as H. unfold addr in H. rewrite BL1, BL2 in H.
    unfold E in H; eplT_in H. rewrite Ptrofs.unsigned_zero, Z.add_0_l in H. exact H. }
  (* the frame: off the list (and off the table, which the walk did not write) *)
  assert (OFF : forall ch b z, Plt b (Mem.nextblock m) -> ~ rblk RL0 b -> Mem.load ch m' b z = Mem.load ch m b z).
  { intros ch b z Hp Hr. apply KRT; [exact Hp |]. intros r sz Nr Hs. left.
    destruct (XB r (proj1 (SZ r sz Hs))) as (B1 & _).
    rewrite B1. intros Eb. apply Hr. rewrite <- Eb. exact (INR r sz Hs Nr). }
  assert (OBJ : forall ch z, z + size_chunk ch <= Ptrofs.unsigned oo \/ Ptrofs.unsigned oo + SZ_OBJECT <= z ->
             Mem.load ch m' bo z = Mem.load ch m bo z).
  { intros ch z Hz. apply KRX; [exact Vo |]. intros r sz Nr Hs.
    destruct (XB r (proj1 (SZ r sz Hs))) as (B1 & B2).
    rewrite B1, B2. clear -Hs Hz D1 D3 O1 O2 O3 O5 O6 O7 O8 OL OK OP OSR OSRC OSMS ZO Nr DA2.
    r0t_cases Hs; subst sz; unfold E; eplT;
      first [left; congruence | right; rewrite ?ZO; unfold SZ_OBJECT in *; lia | congruence]. }
  (* the region list, through E' *)
  assert (RL' : map (den G m E') (wargs (R0T G)) = map (den G m E) (wargs (R0T G))).
  { eapply map_den_ext; [| exact X].
    apply Forall_forall. intros a Hin. rewrite R0T_eq in Hin. unfold wargs in Hin. cbn [map fst] in Hin.
    repeat (destruct Hin as [<- | Hin]; [vm_compute; reflexivity |]). contradiction. }
  rewrite RL in RL'.
  assert (RLs : forall b, rblk RL0 b -> rblk (map Some [Vptr bm Ptrofs.zero; Vptr bo oo; Vptr bfi Ptrofs.zero;
                           Vptr bmiss Ptrofs.zero; Vptr bcalls Ptrofs.zero; Vptr ab Ptrofs.zero; Vptr bt ot;
                           Vptr biom Ptrofs.zero; Vptr bmq Ptrofs.zero; Vptr brm Ptrofs.zero;
                           Vptr blk Ptrofs.zero; Vptr bpc Ptrofs.zero; Vptr bsr Ptrofs.zero; Vptr bsrc Ptrofs.zero;
                           Vptr bsms Ptrofs.zero; Vptr btab otab; Vptr bo uo]) b).
  { apply rblk_sub. intros b o Hin. unfold RL0, ff_rl in Hin. cbn in Hin.
    repeat (destruct Hin as [Hin | Hin]; [injection Hin as <- <-; eexists; cbn; auto 20 |]). contradiction. }
  (* a stored surface the walk found *)
  assert (NEW : forall p v, fk_surf G (R0T G) m (ufT G m gp) E' p v ->
             exists b o, v = Vptr b o /\ Plt b (Mem.nextblock m) /\ Ptrofs.unsigned o + SZ_SURFACE <= Ptrofs.modulus
               /\ styp m b o /\ ~ rblk RL0 b).
  { intros p v' (b & o & -> & D & FWd & St & Nr). cbn [fact_holds] in FWd.
    destruct FWd as (b' & o' & D' & Pb & _ & Ho & _). rewrite D in D'. injection D' as <- <-.
    rewrite RL' in Nr. exists b, o. split; [reflexivity |]. split; [exact Pb |]. split; [exact Ho |].
    split; [exact St |]. intros H. apply Nr. exact (RLs b H). }
  assert (VB : forall ch b z v, Mem.load ch m b z = Some v -> Plt b (Mem.nextblock m)).
  { intros ch b z v' Hl. eapply Mem.valid_access_valid_block.
    eapply Mem.valid_access_implies; [eapply Mem.load_valid_access; exact Hl | constructor]. }
  assert (SOK : forall v, (forall sb so, v = Vptr sb so -> ~ rblk RL0 sb) -> surface_ok m v -> surface_ok m' v).
  { intros v' Hr [Hn | (b & o & ty & -> & Hl & Hin)]; [left; exact Hn |].
    right. exists b, o, ty. split; [reflexivity |]. split; [| exact Hin].
    rewrite OFF; [exact Hl | exact (VB _ _ _ _ Hl) | exact (Hr b o eq_refl)]. }
  assert (SNN : forall v, (forall sb so, v = Vptr sb so -> ~ rblk RL0 sb) ->
             surface_nonnull_ok m v -> surface_nonnull_ok m' v).
  { intros v' Hr (b & o & ty & -> & Hl & Hin).
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
  { intros off v' [-> | [-> | ->]] Hl.
    - change FFW_WALL with 96 in Hl |- *. destruct FWl as [E0 | [E0 | (p & v'' & E0 & Hs)]]; rewrite Hl in E0.
      + left. symmetry. exact E0.
      + right; left. injection E0 as <-. reflexivity.
      + right; right. injection E0 as <-. exact (NEW p v' Hs).
    - left. rewrite <- Hl. symmetry. apply CM. mem_tac.
    - change FFW_FLOOR with 104 in Hl |- *. destruct KF as [E0 | (p & v'' & E0 & Hs)]; rewrite Hl in E0.
      + left. symmetry. exact E0.
      + right; right. injection E0 as <-. exact (NEW p v' Hs). }
  assert (SB : forall off sb so, off = FFW_WALL \/ off = FFW_CEIL \/ off = FFW_FLOOR ->
             Mem.load Mint32 m' bm off = Some (Vptr sb so) ->
             Mem.load Mint32 m bm off = Some (Vptr sb so) \/ ~ rblk RL0 sb).
  { intros off sb so Hoff Hl. destruct (SV off _ Hoff Hl) as [H | [H | (b & o & E0 & _ & _ & _ & Hr)]].
    - left. exact H.
    - discriminate H.
    - right. injection E0 as -> _. exact Hr. }
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
  { intros i v' Hi Hl (cb & co & ty & -> & Lt & Hin & Hp & Hc).
    pose proof (Co i cb co Hi Hl) as ->.
    destruct (Hmob bo oo Lo) as (_ & _ & Hm3).
    destruct (Hm3 i bo co Hi Hl) as [N | Hco]; [congruence |].
    exists bo, co, ty. split; [reflexivity |].
    rewrite SLOT by (first [exact Hco | cbn; auto]). split; [exact Lt |]. split; [exact Hin |].
    split.
    - intros Hty. destruct (Hp Hty) as (base & top & Hb' & Q1 & Q2 & Q3). exists base, top.
      rewrite !SLOT by (first [exact Hco | cbn; auto 6]). auto.
    - intros Hty. destruct (Hc Hty) as (y & Hy & Q1). exists y. rewrite SLOT by (first [exact Hco | cbn; auto]). auto. }
  (* the new floor *)
  assert (FLR : exists fl', Mem.load Mint32 m' bm FFW_FLOOR = Some fl' /\ wblk m RL0 fl' SZ_SURFACE
                  /\ surface_nonnull_ok m' fl').
  { destruct KF as [E0 | (p & v' & E0 & Hs)].
    - exists fl. change FFW_FLOOR with 104. rewrite E0. split; [exact Lf |]. split; [exact Wf |].
      destruct HW as (_ & _ & Hf & _). apply SNN; [| exact (Hf fl Lf)].
      destruct Wf as (b & o & -> & _ & _ & _ & Hr). intros sb so E1. injection E1 as <- _. exact Hr.
    - destruct (NEW p v' Hs) as (b & o & -> & Pb & Hsz & St & Hr). exists (Vptr b o).
      split; [exact E0 |]. split; [| exact (STY b o Pb Hr St)].
      exists b, o. split; [reflexivity |]. split; [exact Pb |]. split; [clear; unfold SZ_SURFACE; lia |].
      split; [exact Hsz | exact Hr]. }
  destruct FLR as (fl' & Lf' & Wf' & Sf').
  (* ---- usedObj at m' ---- *)
  assert (UO' : WMotRWorld.used_ok bm m').
  { destruct RC2 as (A2 & _ & _ & _ & Vy2 & _). change (e_blk E RM) with bm in A2, Vy2.
    destruct (in_dec Z.eq_dec (Int.unsigned (c_action c2)) POLE_ACTS3) as [H3 | H3].
    - destruct (Hk H3) as (U1 & U2 & (p2 & Lp2 & Fp2 & Rp2)).
      unfold E in U1, U2, Lp2; unfold addr in U2, Lp2; eplT_in U1; eplT_in U2; eplT_in Lp2.
      intros a La'. change OFS_ACTION with 12 in A2. rewrite A2 in La'. injection La' as <-.
      split.
      + intros _. exists bo, uo. split; [rewrite U1; exact Lu |].
        split; [| split; [| split]].
        * exists (-2739)%Z, (-1919)%Z. split; [rewrite pole_list_value; left; reflexivity |].
          split; [lia |].
          rewrite !U2 by auto. split; [exact P1 |]. split; [exact P2 | exact P3].
        * split; [exact Ubm |]. intros mb mo Hl. change MARIOOBJ_OFF with FFW_OBJ in Hl.
          rewrite Lo' in Hl. injection Hl as <- <-. right. exact Dis.
        * split; [unfold OBJ_SPAN; lia |]. intros mb mo Hl. change MARIOOBJ_OFF with FFW_OBJ in Hl.
          rewrite Lo' in Hl. injection Hl as <- <-. split; [reflexivity |].
          exists p2. split; [exact Lp2 |]. split; [exact Fp2 | exact Rp2].
        * intros v' Lv. rewrite Vy2 in Lv. injection Lv as <-. rewrite Hvy.
          destruct RC as (_ & _ & _ & _ & Vy0 & _). exact (VN _ Vy0).
      + intros Hc. exfalso. rewrite Hc in H3. vm_compute in H3.
        repeat (destruct H3 as [H3 | H3]; [discriminate H3 |]). exact H3.
    - apply (WMotRWorld.used_ok_other bm m' (c_action c2) A2).
      intros Hu. apply H3. unfold POLE_OUT in Hout. apply in_app_or in Hout as [Ho | Ho]; [exact Ho |].
      exfalso. unfold used_acts, pole_acts, ACT_IN_CANNON_Z in Hu. cbn in Ho.
      clear - Ho Hu. cbn in Ho, Hu. lia. }
  (* ---- the animation world at m' ---- *)
  assert (AW' : anim_w G bm m').
  { assert (B' : anim_base G bm m' ab bga bauc btab otab bt ot bo oo).
    { apply (anim_base_keep G bm m m' gp RL0 ab bga bauc btab otab bt ot bo oo AB W Ntab Nga NBm
               (fun b ofs k p Hp Hq => proj2 (VP b ofs k p Hp) Hq) OFF);
        [apply CM; mem_tac | apply CL; mem_tac | apply CL; mem_tac | apply CM; mem_tac | apply CM; mem_tac]. }
    exists ab, bga, bauc, btab, otab, bt, ot, bo, oo. split; [exact B' |].
    intros a La2 Ia. change (e_blk E RM) with bm in AST.
    pose proof (AST a La2 Ia) as A2. unfold ast, E in A2; eplT_in A2. exact A2. }
  (* ---- the frame world at m' ---- *)
  (* the level cells (FfWorld.lvl_w): globals' blocks off the regions *)
  assert (LV' : lvl_w G m')
    by exact (AnimKeep.lvl_w_keep G bm m m' bfi bmiss bcalls ab biom bmq brm blk bpc bsr bsrc bsms bo oo bt
                S1 S2 S3 S5 S6 S7 S8 SL SP SR SRC SMS AW (fun b H => D4 b (or_intror (or_intror H)))
                Hgn OFF LV).
  split; [| split; [| split; [| split; [| split; [| split; [| exact (conj UO' (conj AW' LV'))]]]]]].
  - (* the action *)
    destruct KA as (a & La' & Ina). intros v' Hl. rewrite La' in Hl. injection Hl as <-. exact Ina.
  - (* W *)
    destruct HW as (Hw & Hc & Hf & Hh & Hr & Hq & Ho).
    split; [| split; [| split; [| split; [| split; [| split]]]]].
    + intros v' Hl. destruct (SV FFW_WALL v' (or_introl eq_refl) Hl) as [Hl0 | [-> | (b & o & -> & Pb & _ & St & Nr)]].
      * apply SOK; [| exact (Hw v' Hl0)]. intros sb so ->. exact (Wc0 FFW_WALL sb so (or_introl eq_refl) Hl0).
      * left. reflexivity.
      * right. destruct (STY b o Pb Nr St) as (b' & o' & ty & E1 & L1 & I1). exists b', o', ty. auto.
    + intros v' Hl. rewrite CM in Hl by mem_tac. apply SOK; [| exact (Hc v' Hl)].
      intros sb so ->. exact (Wc0 FFW_CEIL sb so (or_intror eq_refl) Hl).
    + intros v' Hl. change FLOOR_OFF with FFW_FLOOR in Hl. rewrite Lf' in Hl. injection Hl as <-. exact Sf'.
    + rewrite CM by mem_tac. exact Hh.
    + rewrite CM by mem_tac. exact Hr.
    + rewrite CM by mem_tac. exact Hq.
    + destruct Ho as (mb' & mo' & s0 & n & Lmo & Ls & Hz & Ln & Hn4 & Hall).
      change MARIOOBJ_OFF with FFW_OBJ in Lmo. rewrite Lo in Lmo. injection Lmo as <- <-.
      exists bo, oo, s0, n. split; [exact Lo' |].
      split; [rewrite CO by mem_tac; exact Ls |]. split; [exact Hz |].
      split; [rewrite CO by mem_tac; exact Ln |]. split; [exact Hn4 |].
      intros i v' Hi Hl. assert (Hi4 : 0 <= i < 4) by (clear - Hi Hn4; lia).
      rewrite COLL in Hl by exact Hi4. exact (COK i v' Hi4 Hl (Hall i v' Hi Hl)).
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
End POLEROWT.
