(* ====================================================================== *)
(* AirMove (unwired, GOAL 2): a classified non-landing outcome of the real *)
(* perform_air_step is a HeightMoveCatalog RangedMove of Phi's cells.      *)
(*                                                                          *)
(* AirRun.air_step_outcome: every execution of the real perform_air_step   *)
(* (Mario in ACT_FREEFALL) ends in a memory one outcome describes, and the *)
(* outcome passes AirMatch.outcome_ok.  Here: when that outcome is an air  *)
(* class (Cair: four quarters, vel to gravity's; Ccut k: a ceiling cut),   *)
(* the cells read before and after are an S_air / S_air_cut step, and the *)
(* new cells are in range (InRange): pos[1] ends above the floor height it  *)
(* was compared with (AirMatch.above_low), floorHeight is the entry value  *)
(* or a find_floor hit (a WMotR floor, so >= -11000).                      *)
(* ====================================================================== *)

From Coq Require Import ZArith Reals List Lia Lra.
From compcert Require Import Coqlib Maps AST Integers Floats Values Memory Ctypes Clight.
From Flocq Require Import Raux.
From SM64.Proofs Require Import Interp.SymExec2 HeightInvariant HeightMoveCatalog WMotRLevel.
From SM64.Proofs.WMotRRequiresA Require Import HeightFloatSteps.
From compcert Require Import ClightBigstep.
From SM64.Generated Require mario_step.
From SM64.Proofs Require Import Interp.LinkGenv MarioModel.LinkedTwelve.
From SM64.Proofs.WMotRRequiresA.Unwired Require Import FloorList FloorHeight FloorBound AirMatch AirXc AirRun.
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

(* the entry cells, read at Mario's state block *)
Variable c : cells.
Local Notation bm := (e_blk E rM).
Hypothesis HA : Mem.load Mint32 m0 bm oA = Some (Vint (c_action c)).
Hypothesis HS : Mem.load Mint16unsigned m0 bm oS = Some (Vint (c_state c)).
Hypothesis HT : Mem.load Mint16unsigned m0 bm oT = Some (Vint (c_timer c)).
Hypothesis HY : Mem.load Mfloat32 m0 bm oY = Some (Vsingle (c_posy c)).
Hypothesis HV : Mem.load Mfloat32 m0 bm oV = Some (Vsingle (c_vely c)).
Hypothesis HF : Mem.load Mfloat32 m0 bm oF = Some (Vsingle (c_floorh c)).
Hypothesis Hc : budget_ok c.
Hypothesis Hact : c_action c = ACT_FREEFALL.
Hypothesis FD : floor_data ge m0.

Local Notation LD := (sload nbase R0 kv g).
Local Notation IC := (init_cell kv).

Lemma mode_ff : mode_of c = M_Freefall.
Proof. unfold mode_of, mode_of_action. rewrite Hact, Int.eq_true. reflexivity. Qed.

Lemma not_sk : c_action c <> ACT_SLIDE_KICK.
Proof.
  rewrite Hact. intros Eq0. apply (f_equal Int.unsigned) in Eq0.
  unfold ACT_FREEFALL, ACT_SLIDE_KICK in Eq0. vm_compute in Eq0. discriminate.
Qed.

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
Lemma floorh_new : cells_ok LD (g_pc g) rM rO kH = true ->
  Mem.load Mint32 m bm oMO = Some (Vptr (e_blk E rO) (e_base E rO))
  /\ exists fh, Mem.load Mfloat32 m bm oF = Some (Vsingle fh)
     /\ F32 fh = true /\ -11000 <= R2 fh.
Proof.
  intros H.
  destruct (cells_sound ge nbase R0 gtab kv m0 uf gp gp_old E m g rM rO kH MM HUH HbM H)
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
  destruct (aclass_above ge nbase R0 gtab kv m0 uf gp gp_old E m g rM rO kH MM HUH HbM cl H)
    as [-> | (p' & x & LY' & C & Hx)]; [congruence |].
  rewrite LY in LY'. injection LY' as <-.
  apply (above_low ge m0 p x FD Fp C).
  destruct Hx as [LF | Hx]; [left | right; exact Hx].
  rewrite HF in LF. injection LF as <-.
  pose proof entry_ranges as (_ & _ & _ & _ & _ & Ff & Lf). auto.
Qed.

Definition RM' := RangedMove wmotr_floor wmotr_pole wmotr_cannon.

(* the four-quarter class: an S_air step *)
Theorem air_move : outcome_ok LD IC (g_pc g) rM rO kH = true ->
  aclass_of LD IC (g_pc g) rM rO kH = Some Cair ->
  exists c', read_cells bm m c' /\ RM' c c'.
Proof.
  intros OK H.
  unfold outcome_ok in OK. apply andb_true_iff in OK as (CO & _).
  destruct entry_ranges as (Fy & Fv & Hy & Hv & Hv43 & Ff & Lf).
  destruct (aclass_air ge nbase R0 gtab kv m0 uf gp gp_old E m g rM rO (c_posy c) (c_vely c) kH
              MM HbM HY HV H Fv Hv)
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
  all: apply (S_air _ _ _ c _ f4); cbn [c_action c_state c_timer c_posy c_vely c_gfxy];
         first [ left; exact mode_ff | exact F32_f4 | rewrite mode_ff, B2R_f4; reflexivity
               | reflexivity | exact Hi | intros E'; exfalso; exact (not_sk E') ].
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
              MM HbM HY HV k H)
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
    first [ left; exact mode_ff | exact Hk | reflexivity | exact Ep
          | rewrite B2R_fm4; lra | intros E'; exfalso; exact (not_sk E') ].
Qed.

Lemma not_ledge : c_action c <> ACT_LEDGE_GRAB.
Proof.
  rewrite Hact. intros Eq0. apply (f_equal Int.unsigned) in Eq0.
  unfold ACT_FREEFALL, ACT_LEDGE_GRAB in Eq0. vm_compute in Eq0. discriminate.
Qed.

(* a landing: an S_attach step.  The frame refreshed floorHeight at this
   pos[1] just before the action ran (update_mario_geometry_inputs; act_freefall
   does not move pos[1] before perform_air_step), so the entry floorHeight
   meets FloorRefreshOK -- a premise the frame-level proof discharges *)
Hypothesis FRO : FloorRefreshOK wmotr_floor (R2 (c_posy c)) (R2 (c_floorh c)).

Theorem land_move : outcome_ok LD IC (g_pc g) rM rO kH = true ->
  aclass_of LD IC (g_pc g) rM rO kH = None ->
  exists c', read_cells bm m c' /\ RM' c c'.
Proof.
  intros OK H.
  unfold outcome_ok in OK. apply andb_true_iff in OK as (CO & OK). rewrite H in OK.
  destruct entry_ranges as (Fy & Fv & Hy & Hv & Hv43 & Ff & Lf).
  pose proof (budget_ok_y c Hc) as Hyhi. unfold PHI_YMAX, PHI_K, PHI_A in Hyhi.
  pose proof Hc as ((_ & _ & _ & Lylo & _) & _).
  destruct (land_sound ge nbase R0 gtab kv m0 uf gp gp_old E m g rM rO (c_posy c) (c_vely c) kH
              MM HUH HbM HY HV OK Fv Hv)
    as ((KA & KS & KT) & LG & LP & (v' & LV & Fv' & Lo & Hi)).
  destruct (floorh_new CO) as (LMO & fh & LF & Ffh & Lfh).
  (* the landed height: a finite p >= -11000 that AttachOK accepts *)
  assert (HP : exists p, Mem.load Mfloat32 m bm oY = Some (Vsingle p) /\ F32 p = true
                 /\ -11000 <= R2 p /\ AttachOK wmotr_floor wmotr_pole wmotr_cannon c (R2 p)).
  { destruct LP as [LP | (h & kq & jz & LP & Hk & HPi' & Hh)].
    - rewrite LP, HF. exists (c_floorh c). split; [reflexivity | split; [exact Ff | split; [exact Lf |]]].
      destruct FRO as [Es | FW].
      + right; right; right; right; right. exact Es.
      + right; left. exact FW.
    - destruct (FD h Hh) as (Fh & _ & Wh).
      exists h. split; [exact LP | split; [exact Fh | split; [exact (wmotr_floor_low _ Wh) |]]].
      right; left. apply (land_attach ge m0 kq jz (c_posy c) (c_vely c) h FD Hk Fy Fv Hv);
        [split; lra | exact Hv43 | exact HPi' | exact Hh]. }
  destruct HP as (p & LY & Fp & Lp & Hat).
  assert (Hv' : R2 v' <= 43).
  { destruct Hi as [Hi | ->]; [| rewrite B2R_fm4; lra].
    destruct (gravity_spec2 f4 (c_vely c) F32_f4 Fv (or_intror B2R_f4) Hv) as [(_ & G) | (_ & G)];
      [lra | rewrite B2R_f4 in G; apply Rabs_le_inv in G; lra]. }
  exists (mkCells (c_action c) (c_state c) (c_timer c) p v' fh p).
  split; [ unfold read_cells; cbn [c_action c_state c_timer c_posy c_vely c_floorh c_gfxy];
           rewrite <- HA, <- HS, <- HT; repeat split; try assumption;
           exists (e_blk E rO), (e_base E rO); split; [exact LMO | transitivity (Mem.load Mfloat32 m bm oY); [exact LG | exact LY]] |].
  split; [ unfold InRange; cbn [c_posy c_vely c_floorh c_gfxy];
           rewrite B2R_fm75 in Lo; repeat split; try assumption; try lra |].
  apply (S_attach _ _ _ c _ (R2 p)); cbn [c_action c_posy c_vely c_gfxy c_floorh].
  - exact Hat.
  - apply Rle_refl.
  - left. reflexivity.
  - change (mode_of (mkCells (c_action c) (c_state c) (c_timer c) p v' fh p)) with (mode_of c).
    rewrite mode_ff. exact Hv'.
  - intros E'. exfalso. exact (not_ledge E').
Qed.

(* every classified outcome of the real perform_air_step is one RangedMove *)
Theorem outcome_move : outcome_ok LD IC (g_pc g) rM rO kH = true ->
  exists c', read_cells bm m c' /\ RM' c c'.
Proof.
  intros OK.
  destruct (aclass_of LD IC (g_pc g) rM rO kH) as [[|k]|] eqn:H.
  - exact (air_move OK H).
  - exact (cut_move k OK H).
  - exact (land_move OK H).
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
    [Vptr (e_blk E RM) (Ptrofs.add (e_base E RM) Ptrofs.zero); Vint Int.zero] t m' vres ->
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
  assert (Hact : c_action c = ACT_FREEFALL).
  { destruct EO as (_ & _ & _ & _ & KV & _).
    destruct (KV RM 12%Z Mint32 (Sconst (Vint (Int.repr 16779404)))) as (_ & _ & L);
      [cbn [kv]; right; left; reflexivity |].
    unfold addr in L. rewrite HbM, Ptrofs.unsigned_zero, Z.add_0_l in L.
    change OFS_ACTION with 12%Z in HA. rewrite HA in L. cbn [den] in L. injection L as ->.
    reflexivity. }
  apply (outcome_move G NB (R0 G) gtab (kv G) m0 (ufW G m0 gp) gp GPO E' m' gs RM RO kH MM
           (ufW_kH G m0 gp)); try (rewrite ?BaM, ?BaO; assumption); rewrite ?BM; assumption.
Qed.
End LPM.
