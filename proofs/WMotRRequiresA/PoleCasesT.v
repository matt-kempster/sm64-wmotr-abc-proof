(* ====================================================================== *)
(* PoleCasesT (GOAL 2): ALL TWELVE cases of the automatic dispatcher       *)
(* (2026-10-23).                                                           *)
(*                                                                        *)
(* The six pole actions (GRAB_POLE_SLOW / _FAST, HOLDING_POLE,             *)
(* CLIMBING_POLE, TOP_OF_POLE_TRANSITION, TOP_OF_POLE) by                  *)
(* PoleRowT.pole_rowT on the real handlers' walks (PoleSlowT ... PoleTopT2,*)
(* one per start variant of PoleStartT.avars); the ledge cases by          *)
(* LedgeRow, IN_CANNON by CannonRow.  aut_cov: the dispatcher's computed   *)
(* case list names no other handler, so nothing is left assumed.           *)
(*                                                                        *)
(* Premises beyond the link: the DMA floor, the PI DMA copying the ROM     *)
(* bytes (OsDmaFloor.pi_dma_anim_spec, TRUST 0.8(f)).  No audio premise:  *)
(* play_sound is its real body (SndXc).                                   *)
(* ====================================================================== *)

From Coq Require Import List ZArith.
From compcert Require Import Coqlib Maps AST Integers Values Memory Events Globalenvs Ctypes Clight ClightBigstep Linking.
From SM64.Generated Require mario_actions_automatic level_update.
From SM64.Proofs Require Import Interp.LinkGenv MarioModel.LinkedTwelve MarioModel.OsDmaFloor.
From SM64.Proofs Require Import RealFrameLinked AirborneSurface.
From SM64.Proofs.WMotRRequiresA Require Import ExtInert FrameSplit AutoSplit PoleRunT PoleStartT
  PoleSlowT PoleFastT PoleHoldT PoleClimbT PoleTrT1 PoleTrT2 PoleTrT3 PoleTopT1 PoleTopT2 PoleRow PoleRowT.
From SM64.Proofs.WMotRRequiresA Require KbRow LedgeRow CannonRow.
Import ListNotations.

Module AUT := mario_actions_automatic.

Lemma dm_tpt : (prog_defmap AUT.prog) ! AUT._act_top_of_pole_transition
  = Some (Gfun (Internal AUT.f_act_top_of_pole_transition)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_tp : (prog_defmap AUT.prog) ! AUT._act_top_of_pole = Some (Gfun (Internal AUT.f_act_top_of_pole)).
Proof. vm_compute. reflexivity. Qed.

Lemma tpt_label_b : forallb (fun x => if Pos.eqb (snd x) AUT._act_top_of_pole_transition
                                      then Z.eqb (fst x) 1049412 else true) aut_case_list = true.
Proof. vm_compute. reflexivity. Qed.
Lemma tp_label_b : forallb (fun x => if Pos.eqb (snd x) AUT._act_top_of_pole then Z.eqb (fst x) 1049413 else true)
  aut_case_list = true.
Proof. vm_compute. reflexivity. Qed.
Lemma tpt_label : forall n, In (n, AUT._act_top_of_pole_transition) aut_case_list -> n = 1049412%Z.
Proof.
  intros n H. pose proof (proj1 (forallb_forall _ _) tpt_label_b _ H) as X.
  cbn [fst snd] in X. rewrite Pos.eqb_refl in X. apply Z.eqb_eq in X. exact X.
Qed.
Lemma tp_label : forall n, In (n, AUT._act_top_of_pole) aut_case_list -> n = 1049413%Z.
Proof.
  intros n H. pose proof (proj1 (forallb_forall _ _) tp_label_b _ H) as X.
  cbn [fst snd] in X. rewrite Pos.eqb_refl in X. apply Z.eqb_eq in X. exact X.
Qed.

(* the dispatcher's handlers: every case is one of these eleven *)
Definition aut_handlers : list ident :=
  [AUT._act_grab_pole_slow; AUT._act_grab_pole_fast; AUT._act_holding_pole;
   AUT._act_ledge_grab; AUT._act_ledge_climb_down; AUT._act_ledge_climb_slow; AUT._act_ledge_climb_fast;
   AUT._act_in_cannon; AUT._act_climbing_pole; AUT._act_top_of_pole_transition; AUT._act_top_of_pole].

Lemma aut_cov_b : forallb (fun x => existsb (Pos.eqb (snd x)) aut_handlers) aut_case_list = true.
Proof. vm_compute. reflexivity. Qed.

Lemma aut_cov : forall n f, In (n, f) aut_case_list -> In f aut_handlers.
Proof.
  intros n f H. pose proof (proj1 (forallb_forall _ _) aut_cov_b _ H) as X. cbn [snd] in X.
  apply existsb_exists in X as (g & Hg & E). apply Pos.eqb_eq in E. subst g. exact Hg.
Qed.

Section POLECASEST.
Variable lp : Clight.program.
Hypothesis H12 : linked12 lp.
Local Notation G := (globalenv lp).
Hypothesis Hdma : os_dma_floor.
Hypothesis Hanim : pi_dma_anim_spec.          (* TRUST 0.8(f): the PI DMA copies the ROM bytes *)
Variable bm : block.
Hypothesis Hbm : Genv.find_symbol G level_update._gMarioStates = Some bm.
Variable MWF : mem -> Prop.

Local Notation FIN := (pole_pfinalT lp H12 Hdma Hanim).

(* each pole action's walks, one per start variant *)
Lemma fin_slow : forall v, In v (avars 1049409) -> pfinalT lp 1049409 v AUT.f_act_grab_pole_slow.
Proof. intros v Hv. simpl in Hv. destruct Hv as [<- | []]. exact (FIN _ _ _ slowT). Qed.
Lemma fin_fast : forall v, In v (avars 1049410) -> pfinalT lp 1049410 v AUT.f_act_grab_pole_fast.
Proof. intros v Hv. simpl in Hv. destruct Hv as [<- | []]. exact (FIN _ _ _ fastT). Qed.
Lemma fin_hold : forall v, In v (avars 135267136) -> pfinalT lp 135267136 v AUT.f_act_holding_pole.
Proof. intros v Hv. simpl in Hv. destruct Hv as [<- | []]. exact (FIN _ _ _ holdT). Qed.
Lemma fin_climb : forall v, In v (avars 1049411) -> pfinalT lp 1049411 v AUT.f_act_climbing_pole.
Proof. intros v Hv. simpl in Hv. destruct Hv as [<- | []]. exact (FIN _ _ _ climbT). Qed.
Lemma fin_tr : forall v, In v (avars 1049412) -> pfinalT lp 1049412 v AUT.f_act_top_of_pole_transition.
Proof.
  intros v Hv. simpl in Hv. destruct Hv as [<- | [<- | [<- | []]]].
  - exact (FIN _ _ _ trT_l11).
  - exact (FIN _ _ _ trT_l12).
  - exact (FIN _ _ _ trT_r).
Qed.
Lemma fin_top : forall v, In v (avars 1049413) -> pfinalT lp 1049413 v AUT.f_act_top_of_pole.
Proof.
  intros v Hv. simpl in Hv. destruct Hv as [<- | [<- | []]].
  - exact (FIN _ _ _ topT_l9).
  - exact (FIN _ _ _ topT_r9).
Qed.

Ltac pole_case lbl dm fin :=
  match goal with Hin : In (?n, _) aut_case_list, Hr : resolves _ _ _ |- _ =>
    pose proof (lbl n Hin) as ->;
    pose proof (resolve_pin_fd lp _ _ _ _ (linked12_LO_aut lp H12) dm Hr) as ->
  end;
  intros m t m' vr c Hok Hw (-> & Hact & Hfr) Hok' Hc Hb Hev;
  destruct Hok as (Vm & _);
  exact (KbRow.kb_reshape _ _ _ (pole_rowT lp H12 bm Hbm _ _ fin ltac:(unfold POLE6; cbn [In]; auto 8)
           m t m' vr c Vm Hw Hc Hb Hact Hfr Hev)).

(* the cases CannonRow leaves: the three later pole actions *)
Lemma rest_cannon : CannonRow.aut_case_rest_cannon lp bm MWF.
Proof.
  intros n f fd v Hin N1 N2 N3 N4 N5 N6 N7 N8 Hr.
  pose proof (aut_cov n f Hin) as C. unfold aut_handlers in C.
  destruct C as [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | []]]]]]]]]]]];
    try (exfalso; match goal with N : ?a <> ?a |- _ => exact (N eq_refl) end).
  - pole_case CannonRow.cp_label CannonRow.dm_cp fin_climb.
  - pole_case tpt_label dm_tpt fin_tr.
  - pole_case tp_label dm_tp fin_top.
Qed.

(* THE AUTOMATIC DISPATCHER'S CASES, all proved *)
Theorem aut_case_rows_T : aut_case_rows lp bm MWF.
Proof.
  intros n f fd v Hin Hr.
  destruct (Pos.eq_dec f AUT._act_grab_pole_slow) as [-> | Hne1].
  { pole_case gps_label dm_gps fin_slow. }
  destruct (Pos.eq_dec f AUT._act_grab_pole_fast) as [-> | Hne2].
  { pole_case gpf_label dm_gpf fin_fast. }
  destruct (Pos.eq_dec f AUT._act_holding_pole) as [-> | Hne3].
  { pole_case hp_label dm_hp fin_hold. }
  exact (LedgeRow.aut_case_rest_pole_ledge lp H12 Hdma bm Hbm MWF
           (LedgeRow.aut_case_rest_ledge_climb lp H12 Hdma bm Hbm MWF
              (CannonRow.aut_case_rest_climb_cannon lp H12 Hdma bm Hbm MWF rest_cannon))
           n f fd v Hin Hne1 Hne2 Hne3 Hr).
Qed.
End POLECASEST.
