(* ====================================================================== *)
(* FfRow (GOAL 2): the freefall case of the airborne dispatcher.          *)
(*                                                                        *)
(* AirSplit's row for case ACT_FREEFALL said: the real act_freefall keeps *)
(* the frame world and moves Phi's cells by a MoveChain.  The MoveChain    *)
(* half is now PROVED (ff_moves): the frame world carries FfWorld.ffw, and *)
(* from it, W and Mario's state block this file builds the start state of *)
(* the act_freefall walk (FfRun.ff_move: env_ok over the ten regions and   *)
(* the walk's start facts) on any twelve-TU link.  What stays a row is the *)
(* other half, `ff_keeps`: the call keeps the frame world.                 *)
(*                                                                        *)
(* Premises beyond the link: the DMA floor (TRUST 3.5), the FPU floor      *)
(* (sqrtf_spec, sqrtf_float), and the labeled open audio/camera premises   *)
(* (ExtInert.audio_inert / camera_inert).                                  *)
(* ====================================================================== *)

From Coq Require Import List ZArith Lia Reals.
From compcert Require Import Coqlib Maps AST Integers Floats Values Memory Events Globalenvs
  Ctypes Clight ClightBigstep Linking.
From SM64.Generated Require mario_step mario mario_actions_airborne memory surface_collision level_update.
From SM64.Proofs Require Import Interp.SymExec2 Interp.LinkGenv MarioModel.LinkedTwelve
  MarioModel.OsDmaFloor HeightInvariant HeightMoveCatalog WMotRLevel WMotRWorld.
From SM64.Proofs Require Import RealFrameLinked AirborneSurface NoAImpliesNoFlyLinked.
From SM64.Proofs.WMotRRequiresA Require Import FloorList FloorExec AirRun AirStart AirMatch
  FpuFloor ExtInert FfRun FfWorld FrameSplit AirSplit.
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

(* the case labelled act_freefall is ACT_FREEFALL's *)
Lemma ff_label_b : forallb (fun x => if Pos.eqb (snd x) AIR._act_freefall then Z.eqb (fst x) 16779404 else true)
  air_case_list = true.
Proof. vm_compute. reflexivity. Qed.

Lemma ff_label : forall n, In (n, AIR._act_freefall) air_case_list -> n = 16779404.
Proof.
  intros n H. pose proof (proj1 (forallb_forall _ _) ff_label_b _ H) as X.
  cbn [fst snd] in X. rewrite Pos.eqb_refl in X. apply Z.eqb_eq in X. exact X.
Qed.

Lemma dm_ff : (prog_defmap AIR.prog) ! AIR._act_freefall = Some (Gfun (Internal AIR.f_act_freefall)).
Proof. vm_compute. reflexivity. Qed.

Section FFROW.
Variable lp : Clight.program.
Hypothesis H12 : linked12 lp.
Local Notation G := (globalenv lp).

Hypothesis Hdma : os_dma_floor.
Hypothesis Hsq : sqrtf_spec.
Hypothesis Hsqf : sqrtf_float.
Hypothesis Haudio : audio_inert.      (* LABELED OPEN PREMISE: audio, deferred *)
Hypothesis Hcamera : camera_inert.    (* LABELED OPEN PREMISE: camera, deferred *)

Variable bm : block.
Hypothesis Hbm : Genv.find_symbol G level_update._gMarioStates = Some bm.

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
Definition Eff (bo bfi bmiss bcalls bsin ab bt biom bmq brm : block) (oo : ptrofs) : senv :=
  mke (fun r => if Pos.eqb r RM then bm else if Pos.eqb r RO then bo
                else if Pos.eqb r RFI then bfi else if Pos.eqb r RMISS then bmiss
                else if Pos.eqb r RCALLS then bcalls else if Pos.eqb r RSIN then bsin
                else if Pos.eqb r RLD then ab else if Pos.eqb r RBUF then bt
                else if Pos.eqb r RIOM then biom else if Pos.eqb r RMQ then bmq
                else if Pos.eqb r RRM then brm else bm)
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
  \/ (r = RIOM /\ sz = 20) \/ (r = RMQ /\ sz = 24) \/ (r = RRM /\ sz = 4).
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
  destruct (Pos.eqb RRM r) eqn:E10; [apply Pos.eqb_eq in E10; injection H as <-; auto 20 | discriminate].
Qed.

Lemma ff_sizes : forall bo bfi bmiss bcalls bsin ab bt biom bmq brm oo,
  Ptrofs.unsigned oo + SZ_OBJECT <= Ptrofs.modulus ->
  forall r sz, r0_size (R0F G) r = Some sz ->
    Plt r NBF /\ 0 <= sz
    /\ Ptrofs.unsigned (e_base (Eff bo bfi bmiss bcalls bsin ab bt biom bmq brm oo) r) + sz <= Ptrofs.modulus.
Proof.
  intros bo bfi bmiss bcalls bsin ab bt biom bmq brm oo Soo r sz H.
  destruct ff_layout as (_ & _ & _ & _ & _ & _ & ZO & _ & _ & ZM & ZD).
  pose proof (Ptrofs.unsigned_range oo) as Ro.
  assert (Mod : Ptrofs.modulus = 4294967296) by reflexivity.
  assert (P1 : 0 <= szs G mario._MarioState)
    by (unfold szs; pose proof (sizeof_pos G (Tstruct mario._MarioState noattr)); lia).
  assert (P2 : 0 <= szs G mario._DmaHandlerList)
    by (unfold szs; pose proof (sizeof_pos G (Tstruct mario._DmaHandlerList noattr)); lia).
  unfold SZ_OBJECT in ZO, Soo.
  destruct (r0f_size r sz H) as
    [(-> & ->) | [(-> & ->) | [(-> & ->) | [(-> & ->) | [(-> & ->) | [(-> & ->) | [(-> & ->) | [(-> & ->) | [(-> & ->) | (-> & ->)]]]]]]]]];
    cbn [Eff e_base]; cbn [Pos.eqb RM RO RFI RMISS RCALLS RSIN RLD RBUF RIOM RMQ RRM];
    rewrite ?Ptrofs.unsigned_zero, ?ZO; unfold Plt, NBF; repeat split; lia.
Qed.

(* THE BRIDGE: from the frame world's ffw, W and Mario's state block, the
   real act_freefall moves Phi's cells by a MoveChain *)
Theorem ff_moves : forall m t m' vres c0,
  Plt bm (Mem.nextblock m) -> ffw G bm m -> wmotr_world bm m ->
  read_cells bm m c0 -> budget_ok c0 ->
  Mem.load Mint32 m bm 12 = Some (Vint (Int.repr 16779404)) ->
  eval_funcall function_entry2 G m (Internal AIR.f_act_freefall) [Vptr bm Ptrofs.zero] t m' vres ->
  exists c2, read_cells bm m' c2 /\ MoveChain wmotr_floor wmotr_pole wmotr_cannon c0 c2.
Proof.
  intros m t m' vres c0 Vm FW HW RC Hb Hact EV.
  destruct FW as (HC & Hgn & EX & FD & FRO).
  destruct EX as (bfi & bmiss & bcalls & bsin & ab & biom & bmq & brm & bo & oo & bt & ot & fl & ar & inp &
                  S1 & S2 & S3 & S4 & S5 & S6 & S7 & S8 & Lo & Soo & La & Lb & Sot & D1 & D2 & D3 & D4 &
                  W & Lf & Wf & Lar & War & Li & Ai).
  destruct ff_layout as (FO & FA & FF & FAr & FH & FR & ZO & ZS & ZA & ZM & ZD).
  set (E := Eff bo bfi bmiss bcalls bsin ab bt biom bmq brm oo).
  (* validity *)
  assert (Vo : Plt bo (Mem.nextblock m)) by exact (HC _ _ _ _ _ Vm Lo).
  assert (Vab : Plt ab (Mem.nextblock m)) by exact (sym_valid m _ _ Hgn S5).
  assert (Vbt : Plt bt (Mem.nextblock m)) by exact (HC _ _ _ _ _ Vab Lb).
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
  destruct (D4 bfi ltac:(cbn; auto 10)) as (O1 & T1). destruct (D4 bmiss ltac:(cbn; auto 10)) as (O2 & T2).
  destruct (D4 bcalls ltac:(cbn; auto 10)) as (O3 & T3). destruct (D4 bsin ltac:(cbn; auto 10)) as (O4 & T4).
  destruct (D4 ab ltac:(cbn; auto 10)) as (O5 & T5). destruct (D4 biom ltac:(cbn; auto 10)) as (O6 & T6).
  destruct (D4 bmq ltac:(cbn; auto 10)) as (O7 & T7). destruct (D4 brm ltac:(cbn; auto 10)) as (O8 & T8).
  clear DS D4.
  (* the region pointer list is ffw's *)
  assert (RL : map (den G m E) (wargs (R0F G)) = ff_rl bm bo oo bfi bmiss bcalls ab bt biom bmq brm).
  { unfold wargs, R0F, ff_rl. cbn [map fst den]. unfold E; cbn [Eff e_blk e_base]. cbn [Pos.eqb RM RO RFI RMISS RCALLS RSIN RLD RBUF RIOM RMQ RRM].
    rewrite !Ptrofs.add_zero. reflexivity. }
  (* each region's block is on the list *)
  assert (INR : forall r sz, r0_size (R0F G) r = Some sz ->
            In (Some (Vptr (e_blk E r) (e_base E r))) (ff_rl bm bo oo bfi bmiss bcalls ab bt biom bmq brm)).
  { intros r sz H. destruct (r0f_size r sz H) as
      [(-> & _) | [(-> & _) | [(-> & _) | [(-> & _) | [(-> & _) | [(-> & _) | [(-> & _) | [(-> & _) | [(-> & _) | (-> & _)]]]]]]]]];
      unfold E; cbn; auto 12. }
  assert (WW : forall p v n, den G m E p = Some v ->
            wblk m (ff_rl bm bo oo bfi bmiss bcalls ab bt biom bmq brm) v n ->
            fact_holds G (R0F G) m (ufF G m (gpv m)) E (Fworld p n)).
  { intros p v n D (b & o & -> & Hp & Hn & Ho & Hr). cbn [fact_holds]. exists b, o.
    repeat split; try assumption. intros r sz Hs. left. intros Eb. apply Hr.
    exists (e_base E r). rewrite <- Eb. exact (INR r sz Hs). }
  assert (DI : forall o ch, den G m E (Sinit RM o ch) = Mem.load ch m bm o).
  { intros o ch. unfold E; cbn [den Eff e_blk e_base]. cbn [Pos.eqb RM RO RFI RMISS RCALLS RSIN RLD RBUF RIOM RMQ RRM].
    rewrite Ptrofs.unsigned_zero, Z.add_0_l. reflexivity. }
  (* env_ok *)
  assert (EO : env_ok G NBF (R0F G) gtabF (kvF G) m (gpv m) E).
  { split; [| split; [| split; [| split; [| split]]]].
    - intros r _. apply gpv_valid. unfold E; cbn [Eff e_blk].
      repeat match goal with |- context [if Pos.eqb ?a ?b then _ else _] =>
        destruct (Pos.eqb a b) end; assumption.
    - exact (ff_sizes bo bfi bmiss bcalls bsin ab bt biom bmq brm oo Soo).
    - intros r sz r' sz' H H' N. left.
      destruct (r0f_size r sz H) as
        [(-> & _) | [(-> & _) | [(-> & _) | [(-> & _) | [(-> & _) | [(-> & _) | [(-> & _) | [(-> & _) | [(-> & _) | (-> & _)]]]]]]]]];
      destruct (r0f_size r' sz' H') as
        [(-> & _) | [(-> & _) | [(-> & _) | [(-> & _) | [(-> & _) | [(-> & _) | [(-> & _) | [(-> & _) | [(-> & _) | (-> & _)]]]]]]]]];
        unfold E; cbn [Eff e_blk]; cbn [Pos.eqb RM RO RFI RMISS RCALLS RSIN RLD RBUF RIOM RMQ RRM]; congruence.
    - intros id r H. unfold gfind, gtabF in H. cbn [find fst] in H.
      repeat (let Ei := fresh "Ei" in
        match type of H with context [Pos.eqb ?i id] =>
          destruct (Pos.eqb i id) eqn:Ei;
          [ apply Pos.eqb_eq in Ei; subst id; injection H as <-;
            unfold E; cbn [Eff e_blk e_base]; cbn [Pos.eqb RM RO RFI RMISS RCALLS RSIN RLD RBUF RIOM RMQ RRM];
            refine (conj _ (conj eq_refl _)); [unfold Plt, NBF; reflexivity | assumption]
          | ] end).
      cbn in H. discriminate H.
    - intros r o ch sv H. unfold kvF in H.
      destruct H as [H | [H | [H | [H | [H | []]]]]]; injection H as <- <- <- <-;
        (split; [unfold Plt, NBF, RM; reflexivity |]); unfold addr; unfold E; cbn [Eff e_blk e_base];
        cbn [Pos.eqb RM RO RFI RMISS RCALLS RSIN RLD RBUF RIOM RMQ RRM]; rewrite ?Ptrofs.unsigned_zero, ?Z.add_0_l.
      + split; [cbn [sok nlt]; split; [cbn [nlt]; unfold Plt, NBF, RO; reflexivity | exact I] |].
        unfold E; cbn [den Eff e_blk e_base]; cbn [Pos.eqb RM RO RFI RMISS RCALLS RSIN RLD RBUF RIOM RMQ RRM]. rewrite Ptrofs.add_zero, FO. exact Lo.
      + split; [cbn [sok]; split; [cbn [nlt]; exact I | cbn [dold]; cbn; auto] |]. exact Hact.
      + split; [cbn [sok]; split; [cbn [nlt]; exact I | cbn [dold]; cbn; auto] |].
        rewrite FH. destruct HW as (_ & _ & _ & HH & _). exact HH.
      + split; [cbn [sok]; split; [cbn [nlt]; exact I | cbn [dold]; cbn; auto] |].
        rewrite FR. destruct HW as (_ & _ & _ & _ & HR & _). exact HR.
      + split; [cbn [sok nlt]; split; [cbn [nlt]; unfold Plt, NBF, RLD; reflexivity | exact I] |].
        unfold E; cbn [den Eff e_blk e_base]; cbn [Pos.eqb RM RO RFI RMISS RCALLS RSIN RLD RBUF RIOM RMQ RRM].
        rewrite Ptrofs.add_zero, FA. exact La.
    - intros n v H. discriminate H. }
  (* the start facts *)
  assert (PC : forall f, In f (pc0F G) -> fact_holds G (R0F G) m (ufF G m (gpv m)) E f).
  { intros f Hf. unfold pc0F in Hf. cbn [app In ffacts] in Hf.
    destruct HW as (_ & _ & HFl & _).
    specialize (HFl _ Lf). destruct HFl as (fb & fo' & ft & -> & Lt & Int).
    destruct Hf as [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | []]]]]]]]].
    - cbn [fact_holds]. rewrite RL. unfold ufF. rewrite ?Pos.eqb_refl. rewrite ZS. exact W.
    - cbn [fact_holds]. exists inp. rewrite DI. split; [exact Li | exact Ai].
    - apply (WW _ (Vptr fb fo')); [rewrite DI, FF; exact Lf | rewrite ZS; exact Wf].
    - apply (WW _ ar); [rewrite DI, FAr; exact Lar | rewrite ZA; exact War].
    - apply (WW _ (Vptr bsin Ptrofs.zero)).
      + unfold E; cbn [den Eff e_blk e_base]; cbn [Pos.eqb RM RO RFI RMISS RCALLS RSIN RLD RBUF RIOM RMQ RRM]. rewrite Ptrofs.add_zero. reflexivity.
      + exists bsin, Ptrofs.zero. split; [reflexivity |]. split; [exact V4 |].
        split; [clear; pose proof Ptrofs.modulus_pos; lia |]. split; [rewrite Ptrofs.unsigned_zero; clear; lia |].
        intros (o & Hin). cbn in Hin.
        repeat (destruct Hin as [Hin | Hin]; [injection Hin as Hin _; congruence |]). exact Hin.
    - cbn [fact_holds map]. unfold ufF. cbn [Pos.eqb kB kW kH kM].
      exists bt, ot, Ptrofs.zero. split; [| exact Sot].
      unfold E; cbn [den Eff e_blk e_base]; cbn [Pos.eqb RM RO RFI RMISS RCALLS RSIN RLD RBUF RIOM RMQ RRM].
      rewrite Ptrofs.unsigned_zero, Z.add_0_l, Ptrofs.add_zero, Lb. reflexivity.
    - refine (fty_holds G (R0F G) m (ufF G m (gpv m)) E (Sinit RM (AirRun.fo G mario._MarioState mario._floor) Mint32) fb fo' 56 _ _ _);
        [rewrite DI, FF; exact Lf | exists ft; split; assumption | right; reflexivity].
    - refine (fty_holds G (R0F G) m (ufF G m (gpv m)) E (Sinit RM (AirRun.fo G mario._MarioState mario._floor) Mint32) fb fo' 1 _ _ _);
        [rewrite DI, FF; exact Lf | exists ft; split; assumption | left; reflexivity]. }
  (* the floor refresh *)
  assert (FRO0 : FloorRefreshOK wmotr_floor (R2 (c_posy c0)) (R2 (c_floorh c0))).
  { destruct RC as (_ & _ & _ & Hy & _ & Hf & _). exact (FRO _ _ Hy Hf). }
  assert (EV' : eval_funcall function_entry2 G m (Internal AIR.f_act_freefall)
                  [Vptr (e_blk E RM) (Ptrofs.add (e_base E RM) Ptrofs.zero)] t m' vres).
  { unfold E; cbn [Eff e_blk e_base]; cbn [Pos.eqb RM RO RFI RMISS RCALLS RSIN RLD RBUF RIOM RMQ RRM]. rewrite Ptrofs.add_zero. exact EV. }
  destruct (ff_move lp H12 Hdma Hsq Hsqf Haudio Hcamera m (gpv m) (gpv_old m) (gpv_closed m HC) FD
              E t m' vres c0 EO PC EV' ltac:(exact RC) Hb FRO0) as (c2 & RC2 & MV).
  exists c2. exact (conj RC2 MV).
Qed.

(* ---- the airborne cases, with freefall's MoveChain proved ---- *)
Variable MWF : mem -> Prop.

(* the other ten no-A cases keep their AirSplit row *)
Definition air_case_rest : Prop :=
  forall n f fd v, In (n, f) air_case_list -> f <> AIR._act_freefall -> resolves lp f fd ->
    seg_ok lp bm MWF fd [v]
      (fun m => v = Vptr bm Ptrofs.zero /\ Mem.load Mint32 m bm 12 = Some (Vint (Int.repr n))).

(* THE REMAINING FREEFALL ROW: the real act_freefall keeps the frame world *)
Definition ff_keeps : Prop :=
  forall m t m' vr c,
    mem_ok_lp bm MWF m -> fworld lp bm m ->
    Mem.load Mint32 m bm 12 = Some (Vint (Int.repr 16779404)) -> mem_ok_lp bm MWF m' ->
    read_cells bm m c -> budget_ok c ->
    eval_funcall function_entry2 G m (Internal AIR.f_act_freefall) [Vptr bm Ptrofs.zero] t m' vr ->
    fworld lp bm m'.

Theorem air_case_rows_ff : air_case_rest -> ff_keeps -> air_case_rows lp bm MWF.
Proof.
  intros Hrest Hk n f fd v Hin Hr.
  destruct (Pos.eq_dec f AIR._act_freefall) as [-> | Hne]; [| exact (Hrest n f fd v Hin Hne Hr)].
  pose proof (ff_label n Hin) as ->.
  pose proof (resolve_pin_fd lp _ _ _ _ (linked12_LO_air lp H12) dm_ff Hr) as ->.
  intros m t m' vr c Hok Hw (-> & Hact) Hok' Hc Hb Hev.
  split; [exact (Hk m t m' vr c Hok Hw Hact Hok' Hc Hb Hev) |].
  destruct Hok as (Vm & _).
  destruct Hw as (_ & HW & _ & _ & _ & Hf).
  exact (ff_moves m t m' vr c Vm Hf HW Hc Hb Hact Hev).
Qed.

End FFROW.
