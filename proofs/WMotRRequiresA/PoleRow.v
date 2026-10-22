(* ====================================================================== *)
(* PoleRow (GOAL 2): the pole-grab cases of the automatic dispatcher.      *)
(*                                                                        *)
(* KbRow's construction for act_grab_pole_slow / act_grab_pole_fast: from  *)
(* the frame world (whose used_ok gives, in a pole action, usedObj = WMotR *)
(* 's low pole a whole Object away from Mario's object in the same block,  *)
(* oMarioPolePos finite >= -1000 and vel[1] <= 0) the walk's start state   *)
(* on any twelve-TU link, then PoleRun.pfinal (one RangedMove per outcome, *)
(* the kept world, the pole cells kept) and the frame world at the end,    *)
(* used_ok included.                                                       *)
(*                                                                        *)
(* Premises beyond the link: as KbRow (DMA floor, the labeled open audio   *)
(* premise) and PoleXc.find_ceil_height (LABELED OPEN PREMISE).            *)
(* ====================================================================== *)

From Coq Require Import List ZArith Lia Reals Lra.
From compcert Require Import Coqlib Maps AST Integers Floats Values Memory Events Globalenvs
  Ctypes Clight ClightBigstep Linking.
From SM64.Generated Require mario_step mario mario_actions_airborne mario_actions_automatic memory
  surface_collision level_update.
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

(* the case *)
Variable acn : Z.
Variable fK : function.
Hypothesis Hfin : pfinal lp acn fK.
Hypothesis Hpa : In acn [1049409; 1049410]%Z.

Lemma acn_pole : In (Int.unsigned (Int.repr acn)) pole_acts.
Proof. destruct Hpa as [<- | [<- | []]]; cbn; auto 6. Qed.

(* the walk's environment *)
Definition Epl (bo bfi bmiss bcalls bsin ab bt biom bmq brm bau bbt bgp blv : block) (oo uo : ptrofs) : senv :=
  mke (fun r => if Pos.eqb r RM then bm else if Pos.eqb r RO then bo
                else if Pos.eqb r RFI then bfi else if Pos.eqb r RMISS then bmiss
                else if Pos.eqb r RCALLS then bcalls else if Pos.eqb r RSIN then bsin
                else if Pos.eqb r RLD then ab else if Pos.eqb r RBUF then bt
                else if Pos.eqb r RIOM then biom else if Pos.eqb r RMQ then bmq
                else if Pos.eqb r RRM then brm else if Pos.eqb r RAR then bau
                else if Pos.eqb r RU then bo else if Pos.eqb r RBT then bbt
                else if Pos.eqb r RGP then bgp else if Pos.eqb r RLV then blv else bm)
      (fun r => if Pos.eqb r RO then oo else if Pos.eqb r RU then uo else Ptrofs.zero)
      (fun _ => None).

Lemma r0p_size : forall r sz, r0_size (R0P G) r = Some sz ->
  (r = RM /\ sz = szs G mario._MarioState) \/ (r = RO /\ sz = szs G mario._Object)
  \/ (r = RFI /\ sz = 2) \/ (r = RMISS /\ sz = 4) \/ (r = RCALLS /\ sz = 6)
  \/ (r = RLD /\ sz = szs G mario._DmaHandlerList) \/ (r = RBUF /\ sz = Ptrofs.modulus)
  \/ (r = RIOM /\ sz = 20) \/ (r = RMQ /\ sz = 24) \/ (r = RRM /\ sz = 4)
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
  destruct (Pos.eqb RU r) eqn:E11; [apply Pos.eqb_eq in E11; injection H as <-; auto 22 | discriminate].
Qed.

Ltac r0p_cases H :=
  destruct (r0p_size _ _ H) as
    [(-> & ?) | [(-> & ?) | [(-> & ?) | [(-> & ?) | [(-> & ?) | [(-> & ?) | [(-> & ?) | [(-> & ?)
    | [(-> & ?) | [(-> & ?) | (-> & ?)]]]]]]]]]].

Ltac epl := cbn [Epl e_blk e_base];
  cbn [Pos.eqb RM RO RFI RMISS RCALLS RSIN RLD RBUF RIOM RMQ RRM RAR RU RBT RGP RLV].
Ltac epl_in H := cbn [Epl e_blk e_base] in H;
  cbn [Pos.eqb RM RO RFI RMISS RCALLS RSIN RLD RBUF RIOM RMQ RRM RAR RU RBT RGP RLV] in H.

Lemma pl_sizes : forall bo bfi bmiss bcalls bsin ab bt biom bmq brm bau bbt bgp blv oo uo,
  Ptrofs.unsigned oo + SZ_OBJECT <= Ptrofs.modulus -> Ptrofs.unsigned uo + SZ_OBJECT <= Ptrofs.modulus ->
  forall r sz, r0_size (R0P G) r = Some sz ->
    Plt r NBP /\ 0 <= sz
    /\ Ptrofs.unsigned (e_base (Epl bo bfi bmiss bcalls bsin ab bt biom bmq brm bau bbt bgp blv oo uo) r) + sz
       <= Ptrofs.modulus.
Proof.
  intros bo bfi bmiss bcalls bsin ab bt biom bmq brm bau bbt bgp blv oo uo Soo Suo r sz H.
  destruct (KbRow.ff_layout lp H12) as (_ & _ & _ & _ & _ & _ & ZO & _ & _ & ZM & ZD).
  pose proof (Ptrofs.unsigned_range oo) as Ro.
  assert (Mod : Ptrofs.modulus = 4294967296) by reflexivity.
  assert (P1 : 0 <= szs G mario._MarioState)
    by (unfold szs; pose proof (sizeof_pos G (Tstruct mario._MarioState noattr)); lia).
  assert (P2 : 0 <= szs G mario._DmaHandlerList)
    by (unfold szs; pose proof (sizeof_pos G (Tstruct mario._DmaHandlerList noattr)); lia).
  unfold SZ_OBJECT in ZO, Soo, Suo.
  r0p_cases H; subst sz; epl; rewrite ?Ptrofs.unsigned_zero, ?ZO; unfold Plt, NBP; repeat split; lia.
Qed.

(* membership in FfKeepCheck.fk_same *)
Ltac mem_tac := unfold fk_same; repeat (first [left; reflexivity | right]).

(* THE POLE ROW: from the frame world and a fresh floor, the grab's real
   handler keeps the frame world, moves Phi's cells by a MoveChain, and
   returns FALSE or leaves the floor fresh *)
Theorem pole_row : forall m t m' vres c0,
  Plt bm (Mem.nextblock m) -> fworld lp bm m ->
  read_cells bm m c0 -> budget_ok c0 ->
  Mem.load Mint32 m bm 12 = Some (Vint (Int.repr acn)) -> fresh bm m ->
  eval_funcall function_entry2 G m (Internal fK) [Vptr bm Ptrofs.zero] t m' vres ->
  (fworld lp bm m' /\ exists c2, read_cells bm m' c2 /\ MoveChain wmotr_floor wmotr_pole wmotr_cannon c0 c2)
  /\ (vres = Vint Int.zero \/ fresh bm m').
Proof.
  intros m t m' vres c0 Vm (Ha & HW & Han & Hmob & Hd & FW & UO) RC Hbud Hact Hfr EV.
  destruct FW as (Hgn & EX & FD).
  destruct EX as (gp & bfi & bmiss & bcalls & bsin & ab & biom & bmq & brm & bo & oo & bt & ot & fl & ar & inp & ctl &
                  HC & HS & HM & S1 & S2 & S3 & S4 & S5 & S6 & S7 & S8 & Lo & Soo & La & Lb & Sot & D1 & D2 & D3 & D4 &
                  W & Lf & Wf & Wc0 & Lar & War & Li & Ai & Lc & Wc & Co).
  destruct (KbRow.ff_layout lp H12) as (FO & FA & FF & FAr & FH & FR & ZO & ZS & ZA & ZM & ZD).
  destruct (aud_sym lp H12) as (bau & S9).
  destruct (SymbolicLinking.linkorder_resolves_symbol lp AUT.prog _ _ (linked12_LO_aut lp H12) dm_bt)
    as (bbt & Sbt).
  destruct (SymbolicLinking.linkorder_resolves_symbol lp AUT.prog _ _ (linked12_LO_aut lp H12) dm_gpo)
    as (bgp & Sgp).
  destruct (SymbolicLinking.linkorder_resolves_symbol lp AUT.prog _ _ (linked12_LO_aut lp H12) dm_lv)
    as (blv & Slv).
  (* ---- the pole (used_ok, in a pole action) ---- *)
  destruct (UO _ Hact) as (UP & _).
  destruct (UP acn_pole) as (ub & uo & Lu & LP & UA & (Suo & PPm) & VN).
  assert (Lo0 : Mem.load Mint32 m bm MARIOOBJ_OFF = Some (Vptr bo oo)) by exact Lo.
  destruct (PPm bo oo Lo0) as (-> & pp & Lpp & Fpp & Rpp).
  destruct UA as (Ubm & UAm).
  destruct (UAm bo oo Lo0) as [N | Dis]; [congruence |].
  destruct LP as (base & top & Hpl & Ht & P1 & P2 & P3).
  destruct (pole_low base top Hpl Ht) as (-> & ->).
  unfold OBJ_SPAN in Suo, Dis.
  set (E := Epl bo bfi bmiss bcalls bsin ab bt biom bmq brm bau bbt bgp blv oo uo).
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
  pose proof (KbRow.sym_valid lp m _ _ Hgn S1) as V1. pose proof (KbRow.sym_valid lp m _ _ Hgn S2) as V2.
  pose proof (KbRow.sym_valid lp m _ _ Hgn S3) as V3. pose proof (KbRow.sym_valid lp m _ _ Hgn S4) as V4.
  pose proof (KbRow.sym_valid lp m _ _ Hgn S6) as V6. pose proof (KbRow.sym_valid lp m _ _ Hgn S7) as V7.
  pose proof (KbRow.sym_valid lp m _ _ Hgn S8) as V8. pose proof (KbRow.sym_valid lp m _ _ Hgn S9) as V9.
  pose proof (KbRow.sym_valid lp m _ _ Hgn Slv) as V10.
  (* distinctness: symbols, then Mario's object and the buffer *)
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
  destruct (D4 blv (or_intror (or_intror Slv'))) as (OL & TL).
  destruct (D4 bau (or_intror (or_introl S9))) as (O9 & T9).
  destruct (D4 bfi ltac:(left; cbn; auto 10)) as (O1 & T1). destruct (D4 bmiss ltac:(left; cbn; auto 10)) as (O2 & T2).
  destruct (D4 bcalls ltac:(left; cbn; auto 10)) as (O3 & T3). destruct (D4 bsin ltac:(left; cbn; auto 10)) as (O4 & T4).
  destruct (D4 ab ltac:(left; cbn; auto 10)) as (O5 & T5). destruct (D4 biom ltac:(left; cbn; auto 10)) as (O6 & T6).
  destruct (D4 bmq ltac:(left; cbn; auto 10)) as (O7 & T7). destruct (D4 brm ltac:(left; cbn; auto 10)) as (O8 & T8).
  clear DS.
  set (RL0 := ff_rl bm bo oo bfi bmiss bcalls ab bt biom bmq brm) in *.
  assert (Rbo : rblk RL0 bo) by (exists oo; unfold RL0, ff_rl; cbn; auto 12).
  assert (Rbt : rblk RL0 bt) by (exists Ptrofs.zero; unfold RL0, ff_rl; cbn; auto 12).
  (* the region pointer list: ffw's, and the pole *)
  assert (RL : map (den G m E) (wargs (R0P G)) = RL0 ++ [Some (Vptr bo uo)]).
  { unfold wargs, R0P, R0F, RL0, ff_rl. cbn [map app fst den]. unfold E; epl.
    rewrite !Ptrofs.add_zero. reflexivity. }
  assert (RLe : forall b, rblk (RL0 ++ [Some (Vptr bo uo)]) b -> rblk RL0 b)
    by (intros b H; exact (rblk_app1 RL0 bo uo b Rbo H)).
  (* each region's block is on the list *)
  assert (INR : forall r sz, r0_size (R0P G) r = Some sz -> rblk RL0 (e_blk E r)).
  { intros r sz H. r0p_cases H; unfold E; epl; unfold RL0, ff_rl.
    all: first [exact Rbo | eexists; cbn; auto 12]. }
  assert (WW : forall p v n, den G m E p = Some v -> wblk m RL0 v n ->
            fact_holds G (R0P G) m (ufP G m gp) E (Fworld p n)).
  { intros p v n D (b & o & -> & Hp & Hn & Ho & Hr). cbn [fact_holds]. exists b, o.
    repeat split; try assumption. intros r sz Hs. left. intros Eb. apply Hr.
    rewrite <- Eb. exact (INR r sz Hs). }
  assert (DI : forall o ch, den G m E (Sinit RM o ch) = Mem.load ch m bm o).
  { intros o ch. unfold E; cbn [den]; epl. rewrite Ptrofs.unsigned_zero, Z.add_0_l. reflexivity. }
  (* env_ok *)
  assert (EO : env_ok G NBP (R0P G) gtabP (kvP acn G) m gp E).
  { split; [| split; [| split; [| split; [| split]]]].
    - intros r _. unfold E; cbn [Epl e_blk].
      repeat match goal with |- context [if Pos.eqb ?a ?b then _ else _] =>
        destruct (Pos.eqb a b) end;
      first [exact HM | exact Gbo | exact Gab | exact Gbt | exact (HS _ _ S1) | exact (HS _ _ S2)
            | exact (HS _ _ S3) | exact (HS _ _ S4) | exact (HS _ _ S6) | exact (HS _ _ S7) | exact (HS _ _ S8)
            | exact (HS _ _ S9) | exact (HS _ _ Sbt) | exact (HS _ _ Sgp) | exact (HS _ _ Slv)].
    - exact (pl_sizes bo bfi bmiss bcalls bsin ab bt biom bmq brm bau bbt bgp blv oo uo Soo
               ltac:(unfold SZ_OBJECT; lia)).
    - intros r sz r' sz' H H' N.
      r0p_cases H; r0p_cases H'; subst sz sz'; unfold E; epl;
        first [left; congruence | right; rewrite ?ZO; unfold SZ_OBJECT in *; lia].
    - intros id r H. unfold gfind, gtabP, gtabF in H. cbn [app find fst] in H.
      repeat (let Ei := fresh "Ei" in
        match type of H with context [Pos.eqb ?i id] =>
          destruct (Pos.eqb i id) eqn:Ei;
          [ apply Pos.eqb_eq in Ei; subst id; injection H as <-;
            unfold E; epl;
            refine (conj _ (conj eq_refl _)); [unfold Plt, NBP; reflexivity | assumption]
          | ] end).
      cbn in H. discriminate H.
    - intros r o ch sv H. unfold kvP, kvK in H. cbn [app] in H.
      destruct H as [H | [H | [H | [H | [H | [H | [H | [H | [H | []]]]]]]]]]; injection H as <- <- <- <-;
        (split; [unfold Plt, NBP, RM, RU; reflexivity |]); unfold addr; unfold E; epl;
        rewrite ?Ptrofs.unsigned_zero, ?Z.add_0_l.
      + split; [cbn [sok nlt]; split; [cbn [nlt]; unfold Plt, NBP, RO; reflexivity | exact I] |].
        unfold E; cbn [den]; epl. rewrite Ptrofs.add_zero, FO. exact Lo.
      + split; [cbn [sok]; split; [cbn [nlt]; exact I | cbn [dold]; cbn; auto] |]. exact Hact.
      + split; [cbn [sok]; split; [cbn [nlt]; exact I | cbn [dold]; cbn; auto] |].
        rewrite FH. destruct HW as (_ & _ & _ & HH & _). exact HH.
      + split; [cbn [sok]; split; [cbn [nlt]; exact I | cbn [dold]; cbn; auto] |].
        rewrite FR. destruct HW as (_ & _ & _ & _ & HR & _). exact HR.
      + split; [cbn [sok nlt]; split; [cbn [nlt]; unfold Plt, NBP, RLD; reflexivity | exact I] |].
        unfold E; cbn [den]; epl. rewrite Ptrofs.add_zero, FA. exact La.
      + split; [cbn [sok nlt]; split; [cbn [nlt]; unfold Plt, NBP, RU; reflexivity | exact I] |].
        unfold E; cbn [den]; epl. rewrite Ptrofs.add_zero. exact Lu.
      + split; [cbn [sok]; split; [cbn [nlt]; exact I | cbn [dold]; cbn; auto] |]. exact P1.
      + split; [cbn [sok]; split; [cbn [nlt]; exact I | cbn [dold]; cbn; auto] |]. exact P2.
      + split; [cbn [sok]; split; [cbn [nlt]; exact I | cbn [dold]; cbn; auto] |]. exact P3.
    - intros n v H. discriminate H. }
  (* the start facts *)
  assert (PC : forall f, In f (pc0P acn G) -> fact_holds G (R0P G) m (ufP G m gp) E f).
  { intros f Hf. unfold pc0P in Hf. cbn [app In ffacts] in Hf.
    destruct HW as (_ & _ & HFl & _).
    specialize (HFl _ Lf). destruct HFl as (fb & fo' & ft & -> & Lt & Int).
    destruct Hf as [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | []]]]]]]]]]]]].
    - cbn [fact_holds]. rewrite RL. unfold ufP. rewrite ?Pos.eqb_refl. rewrite ZS.
      exact (Wff_rblk G m gp _ RL0 _ RLe W).
    - cbn [fact_holds]. exists inp. rewrite DI. split; [exact Li | exact Ai].
    - apply (WW _ (Vptr fb fo')); [rewrite DI, FF; exact Lf | rewrite ZS; exact Wf].
    - apply (WW _ ar); [rewrite DI, FAr; exact Lar | rewrite ZA; exact War].
    - apply (WW _ (Vptr bsin Ptrofs.zero)).
      + unfold E; cbn [den]; epl. rewrite Ptrofs.add_zero. reflexivity.
      + exists bsin, Ptrofs.zero. split; [reflexivity |]. split; [exact V4 |].
        split; [clear; pose proof Ptrofs.modulus_pos; lia |]. split; [rewrite Ptrofs.unsigned_zero; clear; lia |].
        intros (o & Hin). unfold RL0, ff_rl in Hin. cbn in Hin.
        repeat (destruct Hin as [Hin | Hin]; [injection Hin as Hin _; congruence |]). exact Hin.
    - apply (WW _ (Vptr bau Ptrofs.zero)).
      + unfold E; cbn [den]; epl. rewrite Ptrofs.add_zero. reflexivity.
      + exists bau, Ptrofs.zero. split; [reflexivity |]. split; [exact V9 |].
        split; [clear; lia |]. split; [vm_compute; discriminate |].
        intros (o & Hin). unfold RL0, ff_rl in Hin. cbn in Hin.
        repeat (destruct Hin as [Hin | Hin]; [injection Hin as Hin _; congruence |]). exact Hin.
    - apply (WW _ (Vptr blv Ptrofs.zero)).
      + unfold E; cbn [den]; epl. rewrite Ptrofs.add_zero. reflexivity.
      + exists blv, Ptrofs.zero. split; [reflexivity |]. split; [exact V10 |].
        split; [clear; lia |]. split; [vm_compute; discriminate |].
        intros (o & Hin). unfold RL0, ff_rl in Hin. cbn in Hin.
        repeat (destruct Hin as [Hin | Hin]; [injection Hin as Hin _; congruence |]). exact Hin.
    - cbn [fact_holds map]. unfold ufP. cbn [Pos.eqb kB kW kH kS kL kC kP].
      exists bt, ot, Ptrofs.zero. split; [| exact Sot].
      unfold E; cbn [den]; epl.
      rewrite Ptrofs.unsigned_zero, Z.add_0_l, Ptrofs.add_zero, Lb. reflexivity.
    - cbn [fact_holds map]. rewrite kv_polepos. unfold ufP. cbn [Pos.eqb kB kW kH kS kL kC kP].
      unfold E; cbn [den]; epl. rewrite Lpp. exact (conj Fpp Rpp).
    - cbn [fact_holds map]. unfold ufP. cbn [Pos.eqb kB kW kH kS kL kC kP].
      rewrite RL, DI, FF, Lf. exists fb, fo'. split; [reflexivity |]. split; [exists ft; split; assumption |].
      destruct Wf as (b & o & E1 & _ & _ & _ & Hr). injection E1 as <- <-.
      intros H. exact (Hr (RLe _ H)).
    - refine (fty_holds G (R0P G) m (ufP G m gp) E (Sinit RM (AirRun.fo G mario._MarioState mario._floor) Mint32) fb fo' 56 _ _ _);
        [rewrite DI, FF; exact Lf | exists ft; split; assumption | right; reflexivity].
    - refine (fty_holds G (R0P G) m (ufP G m gp) E (Sinit RM (AirRun.fo G mario._MarioState mario._floor) Mint32) fb fo' 1 _ _ _);
        [rewrite DI, FF; exact Lf | exists ft; split; assumption | left; reflexivity]. }
  assert (EV' : eval_funcall function_entry2 G m (Internal fK)
                  [Vptr (e_blk E RM) (Ptrofs.add (e_base E RM) Ptrofs.zero)] t m' vres).
  { unfold E; epl. rewrite Ptrofs.add_zero. exact EV. }
  assert (IR0 : InRange c0) by exact (proj1 Hbud).
  destruct (Hfin m gp GPO MCg FD E t m' vres c0 EO PC EV' ltac:(exact RC) IR0)
    as (E' & gs & X & MM & FK & NR & RT & c2 & RC2 & RM2 & Hout & Hv & Hk).
  split; [| change (e_blk E RM) with bm in RT; exact (fresh_ret bm m m' vres Hfr RT)].
  split; [| exists c2; split; [exact RC2 | apply Relation_Operators.rt_step; exact RM2]].
  (* ---- the walk's outcome, in terms of the blocks ---- *)
  assert (XB : forall r, Plt r NBP -> e_blk E' r = e_blk E r /\ e_base E' r = e_base E r)
    by (intros r Hr; destruct (X r Hr) as (A & B & _); exact (conj A B)).
  pose proof MM as (_ & _ & _ & _ & VP & NBm & _).
  pose proof (fkp_cell G NBP (R0P G) gtabP (kvP acn G) m (ufP G m gp) gp GPO E' m' gs RM RO RLD kS clokF MM
                (fun vs H => H) FK) as FC.
  pose proof (fkp_frame G NBP (R0P G) gtabP (kvP acn G) m (ufP G m gp) gp GPO E' m' gs RM RO RLD kS clokF MM
                (fun vs H => H) FK) as KR.
  pose proof (fkp_frame_except G NBP (R0P G) gtabP (kvP acn G) m (ufP G m gp) gp GPO E' m' gs RM RO RLD kS clokF MM
                (fun vs H => H) FK RU NR ltac:(cbn; unfold RU, RBUF, RIOM, RMQ, RRM; intuition discriminate)) as KRX.
  pose proof (fkp_action G NBP (R0P G) gtabP (kvP acn G) m (ufP G m gp) gp GPO E' m' gs RM RO RLD kS clokF MM
                (fun vs H => H) FK) as KA.
  pose proof (fkp_floor G NBP (R0P G) gtabP (kvP acn G) m (ufP G m gp) gp GPO E' m' gs RM RO RLD kS clokF MM
                (fun vs H => H) FK) as KF.
  pose proof (fkp_wall G NBP (R0P G) gtabP (kvP acn G) m (ufP G m gp) gp GPO E' m' gs RM RO RLD kS clokF MM
                (fun vs H => H) FK) as FWl.
  destruct (XB RM ltac:(vm_compute; reflexivity)) as (BM1 & BM2).
  destruct (XB RO ltac:(vm_compute; reflexivity)) as (BO1 & BO2).
  destruct (XB RLD ltac:(vm_compute; reflexivity)) as (BL1 & BL2).
  assert (EM : e_blk E' RM = bm /\ forall o, addr E' RM o = o).
  { rewrite BM1. split; [reflexivity |]. intros o. unfold addr. rewrite BM2.
    unfold E; epl. rewrite Ptrofs.unsigned_zero. clear; lia. }
  destruct EM as (EM1 & EM2).
  rewrite EM1, !EM2 in KA, KF, FWl.
  (* the kept cells *)
  assert (CM : forall o ch, In (RM, o, ch) (fk_same RM RO RLD) -> Mem.load ch m' bm o = Mem.load ch m bm o).
  { intros o ch Hin. pose proof (FC _ _ _ Hin) as H. rewrite EM1, EM2 in H. exact H. }
  assert (CO : forall o ch, In (RO, o, ch) (fk_same RM RO RLD) ->
             Mem.load ch m' bo (Ptrofs.unsigned oo + o) = Mem.load ch m bo (Ptrofs.unsigned oo + o)).
  { intros o ch Hin. pose proof (FC _ _ _ Hin) as H. unfold addr in H. rewrite BO1, BO2 in H.
    unfold E in H; epl_in H. exact H. }
  assert (CL : forall o ch, In (RLD, o, ch) (fk_same RM RO RLD) -> Mem.load ch m' ab o = Mem.load ch m ab o).
  { intros o ch Hin. pose proof (FC _ _ _ Hin) as H. unfold addr in H. rewrite BL1, BL2 in H.
    unfold E in H; epl_in H. rewrite Ptrofs.unsigned_zero, Z.add_0_l in H. exact H. }
  (* the frame *)
  assert (OFF : forall ch b z, Plt b (Mem.nextblock m) -> ~ rblk RL0 b -> Mem.load ch m' b z = Mem.load ch m b z).
  { intros ch b z Hp Hr. apply KR; [exact Hp |]. intros r sz Hs. left.
    destruct (XB r (proj1 (pl_sizes bo bfi bmiss bcalls bsin ab bt biom bmq brm bau bbt bgp blv oo uo Soo
                             ltac:(unfold SZ_OBJECT; lia) r sz Hs))) as (B1 & _).
    rewrite B1. intros Eb. apply Hr. rewrite <- Eb. exact (INR r sz Hs). }
  assert (OBJ : forall ch z, z + size_chunk ch <= Ptrofs.unsigned oo \/ Ptrofs.unsigned oo + SZ_OBJECT <= z ->
             Mem.load ch m' bo z = Mem.load ch m bo z).
  { intros ch z Hz. apply KRX; [exact Vo |]. intros r sz Nr Hs.
    destruct (XB r (proj1 (pl_sizes bo bfi bmiss bcalls bsin ab bt biom bmq brm bau bbt bgp blv oo uo Soo
                             ltac:(unfold SZ_OBJECT; lia) r sz Hs))) as (B1 & B2).
    rewrite B1, B2. clear -Hs Hz D1 D3 O1 O2 O3 O5 O6 O7 O8 ZO Nr.
    r0p_cases Hs; subst sz; unfold E; epl;
      first [left; congruence | right; rewrite ?ZO; unfold SZ_OBJECT in *; lia | congruence]. }
  (* the region list, through E' *)
  assert (RL' : map (den G m E') (wargs (R0P G)) = RL0 ++ [Some (Vptr bo uo)]).
  { rewrite <- RL. eapply map_den_ext; [| exact X].
    apply Forall_forall. intros a Hin. unfold wargs, R0P, R0F in Hin. cbn [map app fst] in Hin.
    repeat (destruct Hin as [<- | Hin]; [vm_compute; reflexivity |]). contradiction. }
  (* a stored surface the walk found *)
  assert (NEW : forall p v, fk_surf G (R0P G) m (ufP G m gp) E' p v ->
             exists b o, v = Vptr b o /\ Plt b (Mem.nextblock m) /\ Ptrofs.unsigned o + SZ_SURFACE <= Ptrofs.modulus
               /\ styp m b o /\ ~ rblk RL0 b).
  { intros p v (b & o & -> & D & FWd & St & Nr). cbn [fact_holds] in FWd.
    destruct FWd as (b' & o' & D' & Pb & _ & Ho & _). rewrite D in D'. injection D' as <- <-.
    rewrite RL' in Nr. exists b, o. split; [reflexivity |]. split; [exact Pb |]. split; [exact Ho |].
    split; [exact St |]. intros H. apply Nr. destruct H as (o2 & H). exists o2. apply in_or_app. left. exact H. }
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
    - intros Hty. destruct (Hp Hty) as (base & top & Hb' & Q1 & Q2 & Q3). exists base, top.
      rewrite !SLOT by (first [exact Hco | cbn; auto 6]). auto.
    - intros Hty. destruct (Hc Hty) as (y & Hy & Q1). exists y. rewrite SLOT by (first [exact Hco | cbn; auto]). auto. }
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
  (* ---- usedObj at m' ---- *)
  assert (UO' : WMotRWorld.used_ok bm m').
  { destruct RC2 as (A2 & _ & _ & _ & Vy2 & _). change (e_blk E RM) with bm in A2, Vy2.
    destruct (in_dec Z.eq_dec (Int.unsigned (c_action c2)) POLE_ACTS3) as [H3 | H3].
    - destruct (Hk H3) as (U1 & U2 & (p2 & Lp2 & Fp2 & Rp2)).
      unfold E in U1, U2, Lp2; unfold addr in U2, Lp2; epl_in U1; epl_in U2; epl_in Lp2.
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
        * intros v Lv. rewrite Vy2 in Lv. injection Lv as <-. rewrite Hv.
          destruct RC as (_ & _ & _ & _ & Vy0 & _). exact (VN _ Vy0).
      + intros Hc. exfalso. rewrite Hc in H3. vm_compute in H3.
        repeat (destruct H3 as [H3 | H3]; [discriminate H3 |]). exact H3.
    - apply (WMotRWorld.used_ok_other bm m' (c_action c2) A2).
      intros Hu. apply H3. unfold POLE_OUT in Hout. apply in_app_or in Hout as [Ho | Ho]; [exact Ho |].
      exfalso. unfold used_acts, pole_acts, ACT_IN_CANNON_Z in Hu. cbn in Ho.
      clear - Ho Hu. cbn in Ho, Hu. lia. }
  (* ---- the frame world at m' ---- *)
  split; [| split; [| split; [| split; [| split; [| split; [| exact UO']]]]]].
  - (* the action *)
    destruct KA as (a & La' & Ina). intros v Hl. rewrite La' in Hl. injection Hl as <-. exact Ina.
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
    + exists gp', bfi, bmiss, bcalls, bsin, ab, biom, bmq, brm, bo, oo, bt, ot, fl', ar, inp, ctl.
      split; [exact HC' |]. split; [exact HS' |]. split; [exact (Hinc _ HM) |].
      do 8 (split; [assumption |]).
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
      intros i cb co Hi Hl2. change FFW_COLL with COLL_OFF in Hl2. rewrite COLL in Hl2 by exact Hi.
      exact (Co i cb co Hi Hl2).
    + exact (floor_data_keep2 G m m' RL0 NBm Hperm OFF gp W FD).
Qed.
End POLEROW.

(* ---- the automatic dispatcher's two grab cases ---- *)
From SM64.Proofs.WMotRRequiresA Require Import AutoSplit PoleSlow PoleFast.

Lemma dm_gps : (prog_defmap AUT.prog) ! AUT._act_grab_pole_slow = Some (Gfun (Internal AUT.f_act_grab_pole_slow)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_gpf : (prog_defmap AUT.prog) ! AUT._act_grab_pole_fast = Some (Gfun (Internal AUT.f_act_grab_pole_fast)).
Proof. vm_compute. reflexivity. Qed.

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
Hypothesis Haudio : audio_inert.               (* LABELED OPEN PREMISE: audio, deferred *)
Hypothesis Hceil : find_ceil_height G.         (* LABELED OPEN PREMISE: find_ceil's result (PoleXc) *)
Variable bm : block.
Hypothesis Hbm : Genv.find_symbol G level_update._gMarioStates = Some bm.
Variable MWF : mem -> Prop.

(* the cases still assumed: HOLDING_POLE, CLIMBING_POLE, TOP_OF_POLE_TRANSITION,
   TOP_OF_POLE (their walks need Mario's animation data linked), the five
   ledge cases, and IN_CANNON *)
Definition aut_case_rest_pole : Prop :=
  forall n f fd v, In (n, f) aut_case_list ->
    f <> AUT._act_grab_pole_slow -> f <> AUT._act_grab_pole_fast ->
    resolves lp f fd ->
    seg_okR lp bm MWF fd [v]
      (fun m => v = Vptr bm Ptrofs.zero /\ Mem.load Mint32 m bm 12 = Some (Vint (Int.repr n)) /\ fresh bm m)
      (fun m' vr => vr = Vint Int.zero \/ fresh bm m').

Theorem aut_case_rows_pole : aut_case_rest_pole -> aut_case_rows lp bm MWF.
Proof.
  intros Hrest n f fd v Hin Hr.
  destruct (Pos.eq_dec f AUT._act_grab_pole_slow) as [-> | Hne1].
  { pose proof (gps_label n Hin) as ->.
    pose proof (resolve_pin_fd lp _ _ _ _ (linked12_LO_aut lp H12) dm_gps Hr) as ->.
    intros m t m' vr c Hok Hw (-> & Hact & Hfr) Hok' Hc Hb Hev.
    destruct Hok as (Vm & _).
    exact (KbRow.kb_reshape _ _ _ (pole_row lp H12 bm Hbm _ _
             (pole_pfinal lp H12 Hdma Haudio Hceil _ _ slowcheck12) ltac:(left; reflexivity)
             m t m' vr c Vm Hw Hc Hb Hact Hfr Hev)). }
  destruct (Pos.eq_dec f AUT._act_grab_pole_fast) as [-> | Hne2].
  { pose proof (gpf_label n Hin) as ->.
    pose proof (resolve_pin_fd lp _ _ _ _ (linked12_LO_aut lp H12) dm_gpf Hr) as ->.
    intros m t m' vr c Hok Hw (-> & Hact & Hfr) Hok' Hc Hb Hev.
    destruct Hok as (Vm & _).
    exact (KbRow.kb_reshape _ _ _ (pole_row lp H12 bm Hbm _ _
             (pole_pfinal lp H12 Hdma Haudio Hceil _ _ fastcheck12) ltac:(right; left; reflexivity)
             m t m' vr c Vm Hw Hc Hb Hact Hfr Hev)). }
  exact (Hrest n f fd v Hin Hne1 Hne2 Hr).
Qed.
End POLECASES.
