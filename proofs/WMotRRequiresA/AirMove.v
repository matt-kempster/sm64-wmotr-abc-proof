(* ====================================================================== *)
(* AirMove (unwired, GOAL 2): every classified outcome of the real         *)
(* perform_air_step is a HeightMoveCatalog RangedMove of Phi's cells.      *)
(*                                                                          *)
(* AirRun.air_step_outcome: every execution of the real perform_air_step   *)
(* at act_freefall's call (stepArg AIR_STEP_CHECK_LEDGE_GRAB, Mario in     *)
(* ACT_FREEFALL) ends in a memory one outcome describes, and the outcome   *)
(* passes AirMatch.outcome_ok.  Here each class is one step:               *)
(*   Cair (four quarters)            -> S_air                              *)
(*   Ccut k (a ceiling cut)          -> S_air_cut                          *)
(*   a landing                       -> S_attach (needs FloorRefreshOK)    *)
(*   a ledge grab (check_ledge_grab) -> S_attach                           *)
(* and the new cells are in range (InRange).                                *)
(* ====================================================================== *)

From Coq Require Import ZArith Reals List Lia Lra.
From compcert Require Import Coqlib Maps AST Integers Floats Values Memory Ctypes Clight.
From Flocq Require Import Raux.
From SM64.Proofs Require Import Interp.SymExec2 HeightInvariant HeightMoveCatalog WMotRLevel.
From SM64.Proofs.WMotRRequiresA Require Import HeightFloatSteps HeightBudgetArith.
From compcert Require Import ClightBigstep.
From SM64.Generated Require mario_step.
From SM64.Proofs Require Import Interp.LinkGenv MarioModel.LinkedTwelve.
From SM64.Proofs.WMotRRequiresA Require Import FloorList FloorHeight FloorBound AirMatch AirXc AirRun.
Import ListNotations.
Local Open Scope R_scope.

Section AIRMOVE.
Variables (ge : genv) (nbase : positive) (R0 : list (positive * Z)) (gtab : list (ident * positive))
  (kv : list (positive * Z * memory_chunk * sval)) (m0 : mem)
  (uf : positive -> list (option val) -> Prop) (gp : meminj).
Hypothesis gp_old : forall b x, gp b = Some x -> Plt b (Mem.nextblock m0).
Variables (E : senv) (m : mem) (g : gst) (rM rO kH : positive).
Hypothesis MM : MMg ge nbase R0 gtab kv m0 uf gp E m g.
Hypothesis HUH : forall vs, uf kH vs ->
  exists h yv, vs = [Some (Vsingle h); Some yv] /\ HPi (Hit_at ge m0) (ycast yv) h /\ Hit_at ge m0 h.
Hypothesis HbM : e_base E rM = Ptrofs.zero.

(* the entry cells: their terms at the call (AirMatch.IC; m0's cells for
   a caller that changed none), denoting Phi's cells c *)
Variable c : cells.
Local Notation bm := (e_blk E rM).
Variable IC : positive -> Z -> memory_chunk -> sval.
Hypothesis HA : den ge m0 E (IC rM oA Mint32) = Some (Vint (c_action c)).
Hypothesis HS : den ge m0 E (IC rM oS Mint16unsigned) = Some (Vint (c_state c)).
Hypothesis HT : den ge m0 E (IC rM oT Mint16unsigned) = Some (Vint (c_timer c)).
Hypothesis HY : den ge m0 E (IC rM oY Mfloat32) = Some (Vsingle (c_posy c)).
Hypothesis HV : den ge m0 E (IC rM oV Mfloat32) = Some (Vsingle (c_vely c)).
Hypothesis HF : den ge m0 E (IC rM oF Mfloat32) = Some (Vsingle (c_floorh c)).
Hypothesis Hc : budget_ok c.
Hypothesis Hact : pas_entry (c_action c) (state_of c) = true.
Hypothesis FD : floor_data ge m0.

Local Notation LD := (sload nbase R0 kv g).

(* the entry is freefall / plain air, or ground pound's fall *)
Definition is_gpf : Prop := c_action c = ACT_GROUND_POUND /\ state_of c <> 0%Z /\ mode_of c = M_PoundFall.

Lemma mode_fa : mode_of c = M_Freefall \/ mode_of c = M_Air \/ is_gpf.
Proof. exact (pas_entry_mode _ _ Hact). Qed.

Lemma gpf_v : is_gpf -> R2 (c_vely c) <= 0.
Proof.
  intros (Ea & Es & _). destruct Hc as (_ & _ & _ & _ & HG & _). exact (HG Ea Es).
Qed.

Lemma air4 : mode_of c = M_Freefall \/ mode_of c = M_SlideKick \/ mode_of c = M_Air \/ mode_of c = M_PoundFall.
Proof. destruct mode_fa as [X | [X | (_ & _ & X)]]; auto. Qed.

(* a velocity the step may end with: launch_cap of the entry mode *)
Lemma cap_fa : forall t v, R2 v <= 43 -> (is_gpf -> R2 v <= 0) -> launch_cap (mode_of c) t (R2 v).
Proof.
  intros t v H H0. destruct mode_fa as [X | [X | X]];
    [rewrite X; cbn [launch_cap]; lra | rewrite X; cbn [launch_cap]; lra |].
  pose proof X as (_ & _ & X'). rewrite X'. cbn [launch_cap]. exact (H0 X).
Qed.

Lemma gpf_ne : forall a, (a = ACT_FREEFALL \/ a = Int.repr 2215 \/ a = Int.repr 16910518
  \/ a = Int.repr 16910512 \/ a = Int.repr 16910513 \/ a = Int.repr 25692298 \/ a = ACT_GROUND_POUND
  \/ a = ACT_FORWARD_ROLLOUT \/ a = ACT_BACKWARD_ROLLOUT \/ a = ACT_BUTT_SLIDE_AIR) ->
  a <> ACT_SLIDE_KICK /\ a <> ACT_LEDGE_GRAB.
Proof.
  intros a H. destruct H as [Ea | [Ea | [Ea | [Ea | [Ea | [Ea | [Ea | [Ea | [Ea | Ea]]]]]]]]]; rewrite Ea; split;
    intros Eq0; apply (f_equal Int.unsigned) in Eq0;
    unfold ACT_FREEFALL, ACT_SLIDE_KICK, ACT_LEDGE_GRAB, ACT_GROUND_POUND,
      ACT_FORWARD_ROLLOUT, ACT_BACKWARD_ROLLOUT, ACT_BUTT_SLIDE_AIR in Eq0;
    vm_compute in Eq0; discriminate.
Qed.

Lemma act_cases : c_action c = ACT_FREEFALL \/ c_action c = Int.repr 2215 \/ c_action c = Int.repr 16910518
  \/ c_action c = Int.repr 16910512 \/ c_action c = Int.repr 16910513 \/ c_action c = Int.repr 25692298
  \/ c_action c = ACT_GROUND_POUND \/ c_action c = ACT_FORWARD_ROLLOUT \/ c_action c = ACT_BACKWARD_ROLLOUT
  \/ c_action c = ACT_BUTT_SLIDE_AIR.
Proof.
  unfold pas_entry in Hact. apply orb_true_iff in Hact as [H | H];
    [| apply andb_true_iff in H as [H _]; apply Int.same_if_eq in H; auto 10].
  apply orb_true_iff in H as [H | H]; [apply orb_true_iff in H as [H | H] |].
  - destruct (air_entry_cases _ H) as [X | [X | [X | [X | [X | X]]]]]; auto 10.
  - apply andb_true_iff in H as [H _]. apply Int.same_if_eq in H. auto 10.
  - apply andb_true_iff in H as [H _]. destruct (is_roll_cases _ H) as [X | X]; auto 10.
Qed.

Lemma not_sk : c_action c <> ACT_SLIDE_KICK.
Proof. exact (proj1 (gpf_ne _ act_cases)). Qed.

(* the entry ranges *)
Lemma entry_ranges :
  F32 (c_posy c) = true /\ F32 (c_vely c) = true /\ Rabs (R2 (c_posy c)) <= 16000
  /\ Rabs (R2 (c_vely c)) <= 128 /\ R2 (c_vely c) <= 43
  /\ F32 (c_floorh c) = true /\ -11000 <= R2 (c_floorh c).
Proof.
  pose proof (budget_ok_y c Hc) as Hy. unfold PHI_YMAX, PHI_K, PHI_A in Hy.
  destruct Hc as ((Fy & Fv & _ & Ly & _ & (Ff & Lf) & Lv & Hv) & _).
  repeat split; try assumption; try lra; apply Rabs_le; split; lra.
Qed.

(* the new floorHeight is in range *)
Lemma floorh_new : cells_ok LD IC (g_pc g) rM rO kH = true ->
  Mem.load Mint32 m bm oMO = Some (Vptr (e_blk E rO) (e_base E rO))
  /\ exists fh, Mem.load Mfloat32 m bm oF = Some (Vsingle fh)
     /\ F32 fh = true /\ -11000 <= R2 fh.
Proof.
  intros H.
  destruct (cells_sound ge nbase R0 gtab kv m0 uf gp gp_old E m g rM rO kH MM HUH HbM IC H)
    as (LMO & [LF | (x & LF & Hx)]); split; [exact LMO | | exact LMO |].
  - rewrite LF, HF. exists (c_floorh c). pose proof entry_ranges as (_ & _ & _ & _ & _ & Ff & Lf).
    auto.
  - destruct (FD x Hx) as (Fx & _ & Wx). exists x. split; [exact LF |].
    split; [exact Fx | exact (wmotr_floor_low _ Wx)].
Qed.

(* the final pos[1] is above -11000 *)
Lemma pos_low : forall cl p, aclass_of LD IC (g_pc g) rM rO kH = Some cl -> cl <> Ccut 0 ->
  Mem.load Mfloat32 m bm oY = Some (Vsingle p) -> F32 p = true -> -11000 < R2 p.
Proof.
  intros cl p H N LY Fp.
  destruct (aclass_above ge nbase R0 gtab kv m0 uf gp gp_old E m g rM rO kH MM HUH HbM IC cl H)
    as [(-> & _) | (p' & x & LY' & C & Hx & _)]; [congruence |].
  rewrite LY in LY'. injection LY' as <-.
  apply (above_low ge m0 p x FD Fp C).
  destruct Hx as [LF | Hx]; [left | right; exact Hx].
  rewrite HF in LF. injection LF as <-.
  pose proof entry_ranges as (_ & _ & _ & _ & _ & Ff & Lf). auto.
Qed.

Definition RM' := RangedMove wmotr_floor wmotr_pole wmotr_cannon.

(* what an attach outcome says beyond the move: the height it snapped to,
   which a following action switch (landing, ledge grab) reuses *)
Definition AttachInfo (c c' : cells) : Prop :=
  exists h, AttachOK wmotr_floor wmotr_pole wmotr_cannon c h /\ R2 (c_posy c') <= h
            /\ c_gfxy c' = c_posy c'.

(* the four-quarter class: an S_air step *)
Theorem air_move : outcome_ok LD IC (g_pc g) rM rO kH = true ->
  aclass_of LD IC (g_pc g) rM rO kH = Some Cair ->
  exists c', read_cells bm m c' /\ RM' c c'.
Proof.
  intros OK H.
  unfold outcome_ok in OK. apply andb_true_iff in OK as (CO & _).
  destruct entry_ranges as (Fy & Fv & Hy & Hv & Hv43 & Ff & Lf).
  destruct (aclass_air ge nbase R0 gtab kv m0 uf gp gp_old E m g rM rO (c_posy c) (c_vely c) kH
              MM HbM IC HY HV H Fv Hv)
    as ((KA & KS & KT) & LY & LG & (v' & LV & Fv' & Lo & Hi)).
  destruct (floorh_new CO) as (LMO & fh & LF & Ffh & Lfh).
  destruct (quarter_steps_up 4 (c_posy c) (c_vely c) ltac:(lia) Fy Fv Hy Hv) as (Fp & _).
  rewrite <- air_step_y_quarter_steps in Fp.
  pose proof (pos_low Cair _ H ltac:(discriminate) LY Fp) as Lp.
  destruct (gravity_spec2 f4 (c_vely c) F32_f4 Fv (or_intror B2R_f4) Hv) as [(_ & G) | (_ & G)];
    try rewrite B2R_f4 in G.
  all: exists (mkCells (c_action c) (c_state c) (c_timer c) (air_step_y (c_posy c) (c_vely c)) v' fh
                     (air_step_y (c_posy c) (c_vely c))).
  all: split; [ unfold read_cells; cbn [c_action c_state c_timer c_posy c_vely c_floorh c_gfxy];
                rewrite <- HA, <- HS, <- HT; repeat split; try assumption;
                exists (e_blk E rO), (e_base E rO); split; [exact LMO | exact LG] |].
  all: split; [ unfold InRange; cbn [c_posy c_vely c_floorh c_gfxy];
                rewrite B2R_fm75 in Lo; repeat split; try assumption; try lra;
                try apply Rabs_le_inv in G; lra |].
  all: destruct mode_fa as [X | [X | X]].
  1,2,4,5: apply (S_air _ _ _ c _ f4); cbn [c_action c_state c_timer c_posy c_vely c_gfxy];
         first [ left; exact X | right; right; exact X | exact F32_f4 | rewrite X, B2R_f4; reflexivity
               | reflexivity | exact Hi | intros E'; exfalso; exact (not_sk E') ].
  (* ground pound's fall: the same four quarters, as an S_air_cut 4 *)
  all: apply (S_air_cut _ _ _ c _ 4); cbn [c_action c_state c_timer c_posy c_vely c_gfxy];
         first [ exact air4 | lia | reflexivity | rewrite air_step_y_quarter_steps; reflexivity
               | intros E'; exfalso; exact (not_sk E')
               | pose proof (gpf_v X); try apply Rabs_le_inv in G; lra ].
Qed.

(* the cut class: an S_air_cut step *)
Theorem cut_move : forall k, outcome_ok LD IC (g_pc g) rM rO kH = true ->
  aclass_of LD IC (g_pc g) rM rO kH = Some (Ccut k) ->
  exists c', read_cells bm m c' /\ RM' c c'.
Proof.
  intros k OK H.
  unfold outcome_ok in OK. apply andb_true_iff in OK as (CO & _).
  destruct entry_ranges as (Fy & Fv & Hy & Hv & Hv43 & Ff & Lf).
  destruct (aclass_cut ge nbase R0 gtab kv m0 uf gp gp_old E m g rM rO (c_posy c) (c_vely c) kH
              MM HbM IC HY HV k H)
    as ((KA & KS & KT) & Hk & (p & Ep & LY & LG & LV & (j & Ej))).
  destruct (floorh_new CO) as (LMO & fh & LF & Ffh & Lfh).
  destruct (quarter_steps_up k (c_posy c) (c_vely c) Hk Fy Fv Hy Hv) as (Fq & _).
  assert (Fp : F32 p = true) by (rewrite Ej; apply add_zeros_F32; exact Fq).
  assert (Lp : -11000 <= R2 p).
  { destruct k as [| k'].
    - rewrite Ep. cbn [quarter_steps]. destruct Hc as ((_ & _ & _ & Ly & _) & _). exact Ly.
    - pose proof (pos_low (Ccut (S k')) p H ltac:(discriminate) LY Fp). lra. }
  exists (mkCells (c_action c) (c_state c) (c_timer c) p fm4 fh p).
  split; [ unfold read_cells; cbn [c_action c_state c_timer c_posy c_vely c_floorh c_gfxy];
           rewrite <- HA, <- HS, <- HT; repeat split; try assumption;
           exists (e_blk E rO), (e_base E rO); split; [exact LMO | exact LG] |].
  split; [ unfold InRange; cbn [c_posy c_vely c_floorh c_gfxy]; rewrite ?B2R_fm4;
           repeat split; try assumption; try lra; reflexivity |].
  apply (S_air_cut _ _ _ c _ k); cbn [c_action c_state c_timer c_posy c_vely c_gfxy];
    first [ exact air4 | exact Hk | reflexivity | exact Ep
          | rewrite B2R_fm4; lra | intros E'; exfalso; exact (not_sk E') ].
Qed.

Lemma not_ledge : c_action c <> ACT_LEDGE_GRAB.
Proof. exact (proj2 (gpf_ne _ act_cases)). Qed.

(* a landing: an S_attach step.  The frame refreshed floorHeight at this
   pos[1] just before the action ran (update_mario_geometry_inputs; act_freefall
   does not move pos[1] before perform_air_step), so the entry floorHeight
   meets FloorRefreshOK -- a premise the frame-level proof discharges *)
Hypothesis FRO : FloorRefreshOK wmotr_floor (R2 (c_posy c)) (R2 (c_floorh c)).

Theorem land_move : cells_ok LD IC (g_pc g) rM rO kH = true ->
  land_ok LD IC (g_pc g) rM rO kH = true ->
  exists c', read_cells bm m c' /\ RM' c c' /\ AttachInfo c c'.
Proof.
  intros CO OK.
  destruct entry_ranges as (Fy & Fv & Hy & Hv & Hv43 & Ff & Lf).
  pose proof (budget_ok_y c Hc) as Hyhi. unfold PHI_YMAX, PHI_K, PHI_A in Hyhi.
  pose proof Hc as ((_ & _ & _ & Lylo & _) & _).
  destruct (land_sound ge nbase R0 gtab kv m0 uf gp gp_old E m g rM rO (c_posy c) (c_vely c) kH
              MM HUH HbM IC HY HV OK Fv Hv)
    as ((KA & KS & KT) & LG & LP & (v' & LV & Fv' & Lo & Hi)).
  destruct (floorh_new CO) as (LMO & fh & LF & Ffh & Lfh).
  (* the landed height: a finite p >= -11000 that AttachOK accepts *)
  assert (HP : exists p, Mem.load Mfloat32 m bm oY = Some (Vsingle p) /\ F32 p = true
                 /\ -11000 <= R2 p /\ AttachOK wmotr_floor wmotr_pole wmotr_cannon c (R2 p)).
  { destruct LP as [LP | (h & kq & jz & LP & Hk & HPi' & Hh)].
    - rewrite LP, HF. exists (c_floorh c). split; [reflexivity | split; [exact Ff | split; [exact Lf |]]].
      destruct FRO as [Es | FW].
      + right; right; right; right; right; left. exact Es.
      + right; left. exact FW.
    - destruct (FD h Hh) as (Fh & _ & Wh).
      exists h. split; [exact LP | split; [exact Fh | split; [exact (wmotr_floor_low _ Wh) |]]].
      right; left. apply (land_attach ge m0 kq jz (c_posy c) (c_vely c) h FD Hk Fy Fv Hv);
        [split; lra | exact Hv43 | exact HPi' | exact Hh]. }
  destruct HP as (p & LY & Fp & Lp & Hat).
  assert (Hv' : R2 v' <= 43 /\ (is_gpf -> R2 v' <= 0)).
  { destruct Hi as [Hi | ->]; [| rewrite B2R_fm4; split; [lra | intros _; lra]].
    destruct (gravity_spec2 f4 (c_vely c) F32_f4 Fv (or_intror B2R_f4) Hv) as [(_ & G) | (_ & G)];
      [split; [lra | intros _; lra] | rewrite B2R_f4 in G; apply Rabs_le_inv in G].
    split; [lra | intros X; pose proof (gpf_v X); lra]. }
  exists (mkCells (c_action c) (c_state c) (c_timer c) p v' fh p).
  split; [ unfold read_cells; cbn [c_action c_state c_timer c_posy c_vely c_floorh c_gfxy];
           rewrite <- HA, <- HS, <- HT; repeat split; try assumption;
           exists (e_blk E rO), (e_base E rO); split; [exact LMO | transitivity (Mem.load Mfloat32 m bm oY); [exact LG | exact LY]] |].
  split; [| exists (R2 p); split; [exact Hat | split; [apply Rle_refl | reflexivity]]].
  split; [ unfold InRange; cbn [c_posy c_vely c_floorh c_gfxy];
           rewrite B2R_fm75 in Lo; repeat split; try assumption; try lra |].
  apply (S_attach _ _ _ c _ (R2 p)); cbn [c_action c_posy c_vely c_gfxy c_floorh].
  - exact Hat.
  - apply Rle_refl.
  - left. reflexivity.
  - change (mode_of (mkCells (c_action c) (c_state c) (c_timer c) p v' fh p)) with (mode_of c).
    exact (cap_fa _ _ (proj1 Hv') (proj2 Hv')).
  - intros E'. exfalso. exact (not_ledge E').
Qed.

(* a ledge-grab height: AttachOK's freefall-bump case, or (ground pound's
   fall, vel <= 0) the plain floor case *)
Lemma ledge_at : forall h, wmotr_floor h -> h <= R2 (c_posy c) + Rmax 0 (R2 (c_vely c)) / 2 + STEP_UP ->
  AttachOK wmotr_floor wmotr_pole wmotr_cannon c h.
Proof.
  intros h W Le. destruct mode_fa as [X | [X | X]].
  - right; right; right; right; right; right. split; [left; exact X | split; assumption].
  - right; right; right; right; right; right. split; [right; exact X | split; assumption].
  - right; left. split; [exact W |]. pose proof (gpf_v X) as V0.
    rewrite Rmax_left in Le by lra. lra.
Qed.

(* a ledge grab (check_ledge_grab): an S_attach step onto the WMotR floor
   find_floor found 160 above nextPos[1] (vel[1] <= 0, or a ceiling bump
   zeroed it after at most two rising quarters) *)
Theorem ledge_move : cells_ok LD IC (g_pc g) rM rO kH = true ->
  ledge_ok LD IC (g_pc g) rM rO kH = true ->
  exists c', read_cells bm m c' /\ RM' c c' /\ AttachInfo c c'
             /\ (Mem.load Mfloat32 m bm oF = Mem.load Mfloat32 m bm oY ->
                 AttachOK wmotr_floor wmotr_pole wmotr_cannon c (R2 (c_floorh c'))).
Proof.
  intros CO OK.
  destruct entry_ranges as (Fy & Fv & Hy & Hv & Hv43 & Ff & Lf).
  pose proof (budget_ok_y c Hc) as Hyhi. unfold PHI_YMAX, PHI_K, PHI_A in Hyhi.
  pose proof Hc as ((_ & _ & _ & Lylo & _) & _).
  destruct (ledge_sound ge nbase R0 gtab kv m0 uf gp gp_old E m g rM rO (c_posy c) (c_vely c) kH
              MM HUH HbM IC HY HV OK Fv Hv)
    as ((KA & KS & KT) & LG & (h & kq & jz & LP & Hk & Hor & HPi' & Hh) & (v' & LV & Fv' & Lo & Hi)).
  destruct (floorh_new CO) as (LMO & fh & LF & Ffh & Lfh).
  destruct (FD h Hh) as (Fp & _ & Wh).
  pose proof (wmotr_floor_low _ Wh) as Lp.
  assert (Hor' : R2 (c_vely c) <= 0 \/ (kq <= 2)%nat)
    by (destruct Hor as [Cv | K2]; [left; exact (cgt_false_le _ Fv Cv) | right; exact K2]).
  destruct (ledge_attach ge m0 kq jz (c_posy c) (c_vely c) h FD Hk Fy Fv Hv ltac:(split; lra) Hv43 Hor' HPi' Hh)
    as (W & Le).
  assert (Hv' : R2 v' <= 43 /\ (is_gpf -> R2 v' <= 0)).
  { destruct Hi as [Hi | ->]; [| rewrite B2R_fm4; split; [lra | intros _; lra]].
    destruct (gravity_spec2 f4 (c_vely c) F32_f4 Fv (or_intror B2R_f4) Hv) as [(_ & G) | (_ & G)];
      [split; [lra | intros _; lra] | rewrite B2R_f4 in G; apply Rabs_le_inv in G].
    split; [lra | intros X; pose proof (gpf_v X); lra]. }
  exists (mkCells (c_action c) (c_state c) (c_timer c) h v' fh h).
  split; [ unfold read_cells; cbn [c_action c_state c_timer c_posy c_vely c_floorh c_gfxy];
           rewrite <- HA, <- HS, <- HT; repeat split; try assumption;
           exists (e_blk E rO), (e_base E rO); split; [exact LMO | transitivity (Mem.load Mfloat32 m bm oY); [exact LG | exact LP]] |].
  split; [| split; [ exists (R2 h); split; [ exact (ledge_at _ W Le)
                                       | split; [apply Rle_refl | reflexivity]]
                   | intros EqL; cbn [c_floorh]; rewrite LF, LP in EqL; injection EqL as ->;
                     exact (ledge_at _ W Le)]].
  split; [ unfold InRange; cbn [c_posy c_vely c_floorh c_gfxy];
           rewrite B2R_fm75 in Lo; repeat split; try assumption; try lra |].
  apply (S_attach _ _ _ c _ (R2 h)); cbn [c_action c_posy c_vely c_gfxy c_floorh].
  - exact (ledge_at _ W Le).
  - apply Rle_refl.
  - left. reflexivity.
  - change (mode_of (mkCells (c_action c) (c_state c) (c_timer c) h v' fh h)) with (mode_of c).
    exact (cap_fa _ _ (proj1 Hv') (proj2 Hv')).
  - intros E'. exfalso. exact (not_ledge E').
Qed.

(* a step that did not attach (the four-quarter and cut classes) ends as a
   floor refresh: pos[1] above the floorHeight it compared against, which
   is the outcome's own floorHeight (AirMatch.is_above), or nothing moved *)
Theorem class_fro : forall cl c', aclass_of LD IC (g_pc g) rM rO kH = Some cl ->
  read_cells bm m c' -> InRange c' ->
  FloorRefreshOK wmotr_floor (R2 (c_posy c')) (R2 (c_floorh c')).
Proof using gp_old MM HUH HbM HA HS HT HY HV HF Hc Hact FD FRO.
  intros cl c' H RC IR.
  destruct RC as (_ & _ & _ & Y' & _ & F' & _).
  change OFS_POSY with oY in Y'. change OFS_FLOORH with oF in F'.
  destruct IR as (Fy' & _ & _ & _ & _ & (Ff' & _) & _).
  destruct (aclass_above ge nbase R0 gtab kv m0 uf gp gp_old E m g rM rO kH MM HUH HbM IC cl H)
    as [(-> & LF) | (p & x & LY & C & Hx & LF)].
  - destruct (aclass_cut ge nbase R0 gtab kv m0 uf gp gp_old E m g rM rO (c_posy c) (c_vely c) kH
                MM HbM IC HY HV 0 H) as (_ & _ & (p & Ep & LY & _)).
    rewrite Y' in LY. injection LY as <-. cbn [quarter_steps] in Ep.
    rewrite F', HF in LF. injection LF as LF. rewrite Ep, LF. exact FRO.
  - rewrite Y' in LY. injection LY as <-. rewrite F' in LF. injection LF as <-.
    pose proof (cle_false_gt _ _ Fy' Ff' C) as Lt.
    assert (Hs : R2 (c_floorh c') <= R2 (c_posy c') + STEP_UP) by (unfold STEP_UP; lra).
    destruct Hx as [LF0 | Hh].
    + rewrite HF in LF0. injection LF0 as LF0. rewrite <- LF0.
      destruct FRO as [Es | (Wf & _)]; [left; exact Es | right; split; [exact Wf |]].
      rewrite LF0. exact Hs.
    + right. split; [exact (proj2 (proj2 (FD _ Hh))) | exact Hs].
Qed.

(* every classified outcome of the real perform_air_step is one RangedMove *)
Theorem outcome_move : outcome_ok LD IC (g_pc g) rM rO kH = true ->
  exists c', read_cells bm m c' /\ RM' c c'.
Proof.
  intros OK.
  destruct (aclass_of LD IC (g_pc g) rM rO kH) as [[|k]|] eqn:H.
  - exact (air_move OK H).
  - exact (cut_move k OK H).
  - unfold outcome_ok in OK. rewrite H in OK. apply andb_true_iff in OK as (CO & OK).
    apply orb_true_iff in OK as [OK | OK];
      [destruct (land_move CO OK) as (c' & R & M & _) | destruct (ledge_move CO OK) as (c' & R & M & _)]; eauto.
Qed.
End AIRMOVE.

(* ---- the real call: any execution of perform_air_step from ACT_FREEFALL
        is one RangedMove of Phi's cells ---- *)
Section LPM.
Variable lp : Clight.program.
Hypothesis H12 : linked12 lp.
Local Notation G := (globalenv lp).

Theorem air_step_move : forall m0 gp E t m' vres c,
  (forall b x, gp b = Some x -> Plt b (Mem.nextblock m0)) ->
  (forall ch b z v, gp b <> None -> Mem.load ch m0 b z = Some v -> val_old gp v) ->
  env_ok G NB (R0 G) gtab (kv G) m0 gp E ->
  (forall f, In f (pc0 G) -> fact_holds G (R0 G) m0 (ufW G m0 gp) E f) ->
  e_base E RM = Ptrofs.zero ->
  eval_funcall function_entry2 G m0 (Internal mario_step.f_perform_air_step)
    [Vptr (e_blk E RM) (Ptrofs.add (e_base E RM) Ptrofs.zero); Vint Int.one] t m' vres ->
  read_cells (e_blk E RM) m0 c -> budget_ok c ->
  floor_data G m0 -> FloorRefreshOK wmotr_floor (R2 (c_posy c)) (R2 (c_floorh c)) ->
  exists c', read_cells (e_blk E RM) m' c' /\ RM' c c'.
Proof.
  intros m0 gp E t m' vres c GPO MC EO PC HbM EV RC Hc FD FRO.
  destruct (air_step_outcome lp H12 m0 gp E t m' vres GPO MC EO PC EV) as (E' & gs & X & MM & OK).
  destruct (X RM ltac:(unfold Plt, NB, RM; lia)) as (BM & BaM & _).
  destruct (X RO ltac:(unfold Plt, NB, RO; lia)) as (BO & BaO & _).
  rewrite <- BM.
  destruct RC as (HA & HS & HT & HY & HV & HF & _).
  (* the walk's known action cell: m->action = ACT_FREEFALL *)
  assert (Hff : c_action c = ACT_FREEFALL).
  { destruct EO as (_ & _ & _ & _ & KV & _).
    destruct (KV RM 12%Z Mint32 (Sconst (Vint (Int.repr 16779404)))) as (_ & _ & L);
      [cbn [kv]; right; left; reflexivity |].
    unfold addr in L. rewrite HbM, Ptrofs.unsigned_zero, Z.add_0_l in L.
    change OFS_ACTION with 12%Z in HA. rewrite HA in L. cbn [den] in L. injection L as ->.
    reflexivity. }
  assert (Hact : pas_entry (c_action c) (state_of c) = true) by (rewrite Hff; reflexivity).
  pose proof MM as (EO' & _).
  assert (HIC0 : forall o ch,
            den G m0 E' (init_cell (kv G) RM o ch) = Mem.load ch m0 (e_blk E' RM) o).
  { intros o ch. rewrite (proj1 (init_cell_den G NB (R0 G) gtab (kv G) m0 gp E' RM o ch EO')).
    unfold addr. rewrite BaM, HbM, Ptrofs.unsigned_zero. reflexivity. }
  assert (HD : forall o ch w, Mem.load ch m0 (e_blk E RM) o = Some w ->
            den G m0 E' (init_cell (kv G) RM o ch) = Some w).
  { intros o ch w L. rewrite HIC0, BM. exact L. }
  refine (outcome_move G NB (R0 G) gtab (kv G) m0 (ufW G m0 gp) gp GPO E' m' gs RM RO kH MM
           (ufW_kH G m0 gp) _ c (init_cell (kv G)) (HD _ _ _ HA) (HD _ _ _ HS) (HD _ _ _ HT)
           (HD _ _ _ HY) (HD _ _ _ HV) (HD _ _ _ HF) Hc Hact FD _ OK);
    try (rewrite ?BaM, ?BaO; assumption); rewrite ?BM; assumption.
Qed.
End LPM.
