(* ======================================================================= *)
(* NaSplit (GOAL 2): HeightFrame's per-call row Hseg_call_na, split per    *)
(* call (2026-10-23).                                                      *)
(*                                                                         *)
(* AutoSplit.seg_call_rows_naFA asks every `f(gMarioState)` call of the    *)
(* real execute_mario_action other than the airborne and the automatic     *)
(* dispatchers to keep the frame world (FrameSplit.fworld), move Phi's     *)
(* cells by a MoveChain and meet its post_of.  Read off the generated body *)
(* (ema_calls_eq, computed) those are 15 calls:                            *)
(*   mario_reset_bodystate, update_mario_inputs,                           *)
(*   mario_handle_special_floors, mario_process_interactions,              *)
(*   the stationary / moving / submerged / cutscene / object dispatchers,  *)
(*   sink_mario_in_quicksand, squish_mario_model,                          *)
(*   set_submerged_cam_preset_and_spawn_bubbles, update_mario_health,      *)
(*   update_mario_info_for_cam, mario_update_hitbox_and_cap_model.         *)
(* This file proves seg_call_rows_naFA from one row per call: the calls in *)
(* na_open stay assumed (na_open_rows, HeightFrame.Hseg_na_open), the      *)
(* others are PROVED here from the generated bodies:                       *)
(*   - set_submerged_cam_preset_and_spawn_bubbles: its whole body sits     *)
(*     under (m->action & ACT_GROUP_MASK) == ACT_GROUP_SUBMERGED, and no   *)
(*     action of R_noA is submerged (R_noA_not_sub, computed), so memory   *)
(*     is unchanged;                                                       *)
(*   - mario_execute_submerged_action: since 2026-10-23 a dispatcher's row *)
(*     assumes the action is in its own group (FrameSplit.grp_ok, proved   *)
(*     at the real switch), so this row is vacuous: no R_noA action is in  *)
(*     group 0xC0.  Before, the row ranged over every action (phantom      *)
(*     forall: the real submerged dispatcher on a walking Mario).          *)
(*   - update_mario_health: a walk of the real body (AudioBodies.         *)
(*     lw_body_frame) whose every store is m->health, m->hurtCounter or    *)
(*     m->healCounter (bytes 174..179 of Mario's state) and whose one call *)
(*     is the real play_sound (SndXc.ps_walk: sSoundRequests and its       *)
(*     count).  No conjunct of the frame world, Phi's cells or the floor   *)
(*     refresh reads those bytes or blocks (ProRows' hole lemmas, widened  *)
(*     from m->flags to bytes 4..7 and 174..183).  This holds on EVERY     *)
(*     path, whatever health / counters / action the memory holds, so the *)
(*     row needs no new world fact.                                        *)
(* ======================================================================= *)

From Coq Require Import ZArith List Lia Relations.
From compcert Require Import Coqlib Maps AST Integers Floats Values Events Memory
  Globalenvs Ctypes Ctypesdefs Cop Clight ClightBigstep Linking.
From SM64.Generated Require mario.
From SM64.Proofs Require Import Flying Taint ActionValue ActionValueFrame
  RealFrameValue RealFrameLinked AGates SymbolicLinking.
From SM64.Proofs Require Import CensusV2 EngineV2Consumer RestSurface AirborneSurface.
From SM64.Proofs Require Import NoAImpliesNoFlyLinked.
From SM64.Proofs Require Import HeightInvariant HeightMoveCatalog WMotRLevel WMotRWorld
  NoAActions FrameCalls FrameSplit.
From SM64.Proofs.WMotRRequiresA Require Import FfWorld AirSplit AutoSplit ProRows.
From SM64.Proofs.WMotRRequiresA Require AnimWorld AnimKeep.
From SM64.Proofs Require Import MarioModel.AudioBodies MarioModel.LinkedTwelve.
From SM64.Proofs Require Import Generic.ClosedMem Generic.ClightClosed.
Import ListNotations.

(* ---------------------------------------------------------------------- *)
(* 1. The calls, computed.                                                *)
(* ---------------------------------------------------------------------- *)

Lemma ema_calls_eq : ema_calls =
  [mario._mario_reset_bodystate; mario._update_mario_inputs;
   mario._mario_handle_special_floors; mario._mario_process_interactions;
   mario._mario_execute_stationary_action; mario._mario_execute_moving_action;
   mario._mario_execute_airborne_action; mario._mario_execute_submerged_action;
   mario._mario_execute_cutscene_action; mario._mario_execute_automatic_action;
   mario._mario_execute_object_action;
   mario._sink_mario_in_quicksand; mario._squish_mario_model;
   mario._set_submerged_cam_preset_and_spawn_bubbles; mario._update_mario_health;
   mario._update_mario_info_for_cam; mario._mario_update_hitbox_and_cap_model].
Proof. vm_compute. reflexivity. Qed.

(* the calls whose rows stay assumed *)
Definition na_open : list ident :=
  [mario._mario_reset_bodystate; mario._update_mario_inputs;
   mario._mario_handle_special_floors; mario._mario_process_interactions;
   mario._mario_execute_stationary_action; mario._mario_execute_moving_action;
   mario._mario_execute_cutscene_action; mario._mario_execute_object_action;
   mario._sink_mario_in_quicksand; mario._squish_mario_model;
   mario._update_mario_info_for_cam; mario._mario_update_hitbox_and_cap_model].

(* ---------------------------------------------------------------------- *)
(* 2. No R_noA action is submerged.                                       *)
(* ---------------------------------------------------------------------- *)

Lemma R_noA_grp_chk :
  forallb (fun z => negb (Z.eqb (Int.unsigned (Int.and (Int.repr z) (Int.repr 448))) 192)) R_noA_list
  = true.
Proof. vm_compute. reflexivity. Qed.

Lemma R_noA_not_sub : forall a, R_noA a -> Int.unsigned (Int.and a (Int.repr 448)) <> 192.
Proof.
  intros a Ha E. pose proof R_noA_grp_chk as C. rewrite forallb_forall in C.
  specialize (C _ Ha). rewrite Int.repr_unsigned, E in C. discriminate C.
Qed.

Lemma R_noA_eq_sub : forall a, R_noA a -> Int.eq (Int.and a (Int.repr 448)) (Int.repr 192) = false.
Proof.
  intros a Ha. destruct (Int.eq _ _) eqn:E; [| reflexivity].
  apply Int.same_if_eq in E. exfalso. apply (R_noA_not_sub a Ha). rewrite E. reflexivity.
Qed.

Lemma disp_grp_sub : disp_grp mario._mario_execute_submerged_action = 192.
Proof. vm_compute. reflexivity. Qed.

Lemma sb_eq_ui : forall (ce : composite_env) a b m,
  sem_binary_operation ce Oeq (Vint a) tuint (Vint b) tint m = Some (Val.of_bool (Int.eq a b)).
Proof. reflexivity. Qed.

Lemma sb_shl_3_6 : forall (ce : composite_env) m,
  sem_binary_operation ce Oshl (Vint (Int.repr 3)) tint (Vint (Int.repr 6)) tint m
  = Some (Vint (Int.repr 192)).
Proof. reflexivity. Qed.

Lemma ssc_is : is_umi mario._set_submerged_cam_preset_and_spawn_bubbles = false
  /\ is_fk mario._set_submerged_cam_preset_and_spawn_bubbles = false
  /\ is_disp mario._set_submerged_cam_preset_and_spawn_bubbles = false.
Proof. vm_compute. repeat split; reflexivity. Qed.

Lemma sub_is : is_fk mario._mario_execute_submerged_action = false
  /\ is_disp mario._mario_execute_submerged_action = true.
Proof. vm_compute. split; reflexivity. Qed.

Lemma dm_ssc : (prog_defmap mario.prog) ! mario._set_submerged_cam_preset_and_spawn_bubbles
  = Some (Gfun (Internal mario.f_set_submerged_cam_preset_and_spawn_bubbles)).
Proof. vm_compute. reflexivity. Qed.

(* ---------------------------------------------------------------------- *)
(* 3. update_mario_health's walk: every store is m->health, m->hurtCounter *)
(*    or m->healCounter (in ProRows' hole), the one call play_sound.       *)
(* ---------------------------------------------------------------------- *)

Definition hole_in (d s : Z) : bool :=
  ((4 <=? d) && (d + s <=? 8)) || ((174 <=? d) && (d + s <=? 184)).

Lemma hole_in_spec : forall d s, hole_in d s = true ->
  (4 <= d /\ d + s <= 8) \/ (174 <= d /\ d + s <= 184).
Proof.
  intros d s H. unfold hole_in in H. apply orb_true_iff in H as [H | H];
    apply andb_true_iff in H as [H1 H2]; apply Z.leb_le in H1; apply Z.leb_le in H2; [left | right]; lia.
Qed.

(* a by-value field of Mario's state whose bytes lie in the hole *)
Definition fld_ok (f : ident) (ty : type) : bool :=
  match access_mode ty with
  | By_value ch =>
      match mario_fo mario._MarioState f with
      | Some (d, Full) => hole_in d (size_chunk ch)
      | _ => false
      end
  | _ => false
  end.

Lemma fld_ok_spec : forall f ty, fld_ok f ty = true ->
  exists ch d, access_mode ty = By_value ch /\ mario_fo mario._MarioState f = Some (d, Full)
    /\ hole_in d (size_chunk ch) = true.
Proof.
  intros f ty H. unfold fld_ok in H.
  (* no discriminate on the unreduced match: its hnf computes mario_fo *)
  destruct (access_mode ty) as [ch | | |] eqn:E1; [| exact (False_ind _ (diff_false_true H))
    | exact (False_ind _ (diff_false_true H)) | exact (False_ind _ (diff_false_true H))].
  destruct (mario_fo mario._MarioState f) as [[d bf] |] eqn:E2;
    [| exact (False_ind _ (diff_false_true H))].
  destruct bf as [| sz sg pos w]; [| exact (False_ind _ (diff_false_true H))].
  exists ch, d. split; [reflexivity |]. split; [reflexivity | exact H].
Qed.

(* `pm->f = ...` with pm the MarioState parameter *)
Definition fld_store_ok (pm : ident) (lv rhs : expr) : bool :=
  match lv with
  | Efield (Ederef (Etempvar x _) (Tstruct sid (mk_attr false None))) f ty =>
      Pos.eqb x pm && Pos.eqb sid mario._MarioState && fld_ok f ty
  | _ => false
  end.

Lemma hl_chk : lw_chk (fun id _ => negb (Pos.eqb id mario._m)) (fld_store_ok mario._m) pffs_call_ok
                 (fn_body mario.f_update_mario_health) = true.
Proof. vm_compute. reflexivity. Qed.

Lemma health_is : is_umi mario._update_mario_health = false
  /\ is_fk mario._update_mario_health = false
  /\ is_disp mario._update_mario_health = false.
Proof. vm_compute. repeat split; reflexivity. Qed.

Lemma dm_health : (prog_defmap mario.prog) ! mario._update_mario_health
  = Some (Gfun (Internal mario.f_update_mario_health)).
Proof. vm_compute. reflexivity. Qed.

Section NA.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Variable bm : block.
  Variable MWF : mem -> Prop.
  Hypothesis Hgms : forall m, MWF m -> gms_cond_lp lp m bm.

  Notation ge := (lp_ge lp).

  (* ==================================================================== *)
  (* THE ROWS THAT STAY ASSUMED                                           *)
  (* ==================================================================== *)
  Definition na_open_rows : Prop :=
    forall f fd v, In f na_open -> resolves lp f fd ->
      seg_okR lp bm MWF fd [v] (pre_of lp bm f v) (post_of bm f).

  Lemma marg_of_gms : forall v m, mem_ok_lp bm MWF m -> gms_val lp v m -> marg_ok bm [v].
  Proof.
    intros v m Hok Hgv. destruct v; cbn; try exact I. destruct Hgv as (gb & Hg & Hl).
    exact (Hgms m (proj2 (proj2 Hok)) gb b i Hg Hl).
  Qed.

  (* ==================================================================== *)
  (* set_submerged_cam_preset_and_spawn_bubbles: memory unchanged.        *)
  (* ==================================================================== *)
  Lemma ssc_mem : forall v m t m' vr, marg_ok bm [v] -> action_sat R_noA m bm ->
    eval_funcall function_entry2 ge m
      (Internal mario.f_set_submerged_cam_preset_and_spawn_bubbles) [v] t m' vr ->
    m' = m.
  Proof.
    intros v m t m' vr Hmarg Hsat Hev.
    destruct (fc_entry ge m mario.f_set_submerged_cam_preset_and_spawn_bubbles [v] t m' vr eq_refl Hev)
      as (le0 & le' & t' & out & Hbind & H).
    assert (Hle : le0 ! mario._m = Some v).
    { change (fn_params mario.f_set_submerged_cam_preset_and_spawn_bubbles) with [(mario._m, tyMSp)] in Hbind.
      cbn [bind_parameter_temps] in Hbind. injection Hbind as <-. apply PTree.gss. }
    unfold mario.f_set_submerged_cam_preset_and_spawn_bubbles in H. cbn [fn_body] in H.
    apply (seq_set_inv lp) in H as (va & Ea & H).
    destruct (ev_fld lp H12 bm mario._m le0 m v mario._action tuint Mint32 12 va Hle Hmarg
                action_fo ltac:(lia) eq_refl Ea) as (-> & La).
    apply x_if in H as (vc & bc & Ec & Bc & H).
    apply eval_expr_Ebinop_inv in Ec as (v1 & v2 & E1 & E2 & S1).
    apply eval_expr_Ebinop_inv in E1 as (v3 & v4 & E3 & E4 & S3).
    apply eval_expr_Etempvar_val in E3. rewrite PTree.gss in E3. injection E3 as <-.
    apply eval_expr_Econst_int_val in E4. subst v4.
    cbn [typeof] in S3. destruct (sw_and_448 _ _ _ _ S3) as (a & -> & ->).
    apply eval_expr_Ebinop_inv in E2 as (v5 & v6 & E5 & E6 & S5).
    apply eval_expr_Econst_int_val in E5. apply eval_expr_Econst_int_val in E6. subst v5 v6.
    cbn [typeof] in S5. rewrite sb_shl_3_6 in S5. injection S5 as <-.
    cbn [typeof] in S1, Bc. rewrite sb_eq_ui in S1. injection S1 as <-.
    apply bv_of_bool in Bc. subst bc.
    rewrite (R_noA_eq_sub a (Hsat a La)) in H. cbv iota in H.
    apply x_skip in H as (_ & -> & _). reflexivity.
  Qed.

  Lemma ssc_row : forall fd v,
    resolves lp mario._set_submerged_cam_preset_and_spawn_bubbles fd ->
    seg_okR lp bm MWF fd [v] (pre_of lp bm mario._set_submerged_cam_preset_and_spawn_bubbles v)
      (post_of bm mario._set_submerged_cam_preset_and_spawn_bubbles).
  Proof.
    intros fd v Hr.
    pose proof (resolve_pin_fd lp _ _ _ _ (linked12_LO_mario lp H12) dm_ssc Hr) as ->.
    intros m t m' vr c Hok Hw (Hgv & _) Hok' Hc Hb Hev.
    rewrite (ssc_mem v m t m' vr (marg_of_gms v m Hok Hgv) (proj1 Hw) Hev).
    split; [exact Hw |]. split; [exists c; split; [exact Hc | apply rt_refl] |].
    destruct ssc_is as (Iu & Ik & Id).
    unfold post_of. rewrite Iu, Ik, Id. exact I.
  Qed.

  (* ==================================================================== *)
  (* mario_execute_submerged_action: no R_noA action is in its group.     *)
  (* ==================================================================== *)
  Lemma sub_row : forall fd v,
    seg_okR lp bm MWF fd [v] (pre_of lp bm mario._mario_execute_submerged_action v)
      (post_of bm mario._mario_execute_submerged_action).
  Proof.
    intros fd v m t m' vr c Hok Hw (Hgv & Hx) Hok' Hc Hb Hev.
    destruct sub_is as (Ik & Id).
    unfold xpre in Hx. rewrite Ik, Id in Hx. destruct Hx as (_ & a & La & Ga).
    exfalso. apply (R_noA_not_sub a (proj1 Hw a La)). rewrite Ga. exact disp_grp_sub.
  Qed.

  (* ==================================================================== *)
  (* update_mario_health: a change in m->health / hurtCounter /           *)
  (* healCounter (ProRows' hole, bytes 174..183) and in play_sound's two  *)
  (* queue globals keeps the frame world and the cells.                   *)
  (* ==================================================================== *)
  Lemma fld_store : forall v lv rhs le m0 m1 t le' m2 out bsr bsrc,
    fld_store_ok mario._m lv rhs = true -> le ! mario._m = Some v -> marg_ok bm [v] ->
    exec_stmt function_entry2 ge empty_env le m1 (Sassign lv rhs) t le' m2 out ->
    Qrel bm bsr bsrc m0 m1 -> Qrel bm bsr bsrc m0 m2.
  Proof.
    intros v lv rhs le m0 m1 t le' m2 out bsr bsrc Hok Hle Hmarg Hx (U & N & P).
    unfold fld_store_ok in Hok.
    repeat match type of Hok with
    | match ?x with _ => _ end = true => destruct x; try discriminate Hok
    end.
    repeat rewrite andb_true_iff in Hok. destruct Hok as ((E1 & E2) & E3).
    apply Pos.eqb_eq in E1, E2. subst.
    destruct (fld_ok_spec _ _ E3) as (ch & d & Eam & Efo & Hh).
    apply hole_in_spec in Hh.
    inv Hx.
    match goal with L : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ => rename L into L1 end.
    destruct (lv_field lp (linked12_LO_mario lp H12) _ _ _ _ _ _ _ _ _ _ L1 eq_refl Efo)
      as (o0 & E0 & -> & Hbf).
    cbn [fst snd] in Hbf. subst.
    destruct (ex_agg lp _ _ _ _ _ E0 (or_intror eq_refl) I) as (bf0 & L0).
    apply eval_lvalue_Ederef_base, eval_expr_Etempvar_val in L0.
    rewrite Hle in L0. injection L0 as ->.
    destruct Hmarg as [-> ->].
    match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ => inv Ha end;
      match goal with Hm : access_mode (typeof _) = _ |- _ =>
        cbn [typeof] in Hm; rewrite Eam in Hm; try discriminate Hm end.
    match goal with Hm : By_value _ = By_value _ |- _ => injection Hm as Hch; subst chunk end.
    match goal with Hs : Mem.storev _ _ _ _ = Some _ |- _ => rename Hs into Hst end.
    cbn [fst Mem.storev] in Hst. rewrite Ptrofs.add_zero_l in Hst.
    rewrite Ptrofs.unsigned_repr in Hst
      by (change Ptrofs.max_unsigned with 4294967295; pose proof (size_chunk_pos ch) as Hsz; clear - Hh Hsz; lia).
    split; [| split].
    - eapply Mem.unchanged_on_trans; [exact U |].
      eapply Mem.store_unchanged_on; [exact Hst |].
      intros j Hj (_ & _ & Hn). apply Hn. split; [reflexivity |]. clear - Hj Hh. lia.
    - rewrite (Mem.nextblock_store _ _ _ _ _ _ Hst). exact N.
    - intros b o k p. rewrite <- P. split.
      + intros Hp. exact (Mem.perm_store_2 _ _ _ _ _ _ Hst _ _ _ _ Hp).
      + intros Hp. exact (Mem.perm_store_1 _ _ _ _ _ _ Hst _ _ _ _ Hp).
  Qed.

  Lemma health_row : forall fd v,
    resolves lp mario._update_mario_health fd ->
    seg_okR lp bm MWF fd [v] (pre_of lp bm mario._update_mario_health v)
      (post_of bm mario._update_mario_health).
  Proof.
    intros fd v Hr.
    pose proof (resolve_pin_fd lp _ _ _ _ (linked12_LO_mario lp H12) dm_health Hr) as ->.
    intros m t m' vr c Hok Hw (Hgv & _) Hok' Hc Hb Hev.
    pose proof (marg_of_gms v m Hok Hgv) as Hmarg.
    pose proof Hw as (_ & _ & _ & _ & _ & Hf & _ & Haw & _).
    pose proof Hf as (Hgn & EX & _).
    destruct EX as (gp & bfi & bmiss & bcalls & bsin & ab & biom & bmq & brm & blk & bpc & bsr & bsrc & bsms & bo & oo & bt & ot & fl & ar & inp & ctl &
                    HC & HS & HM & S1 & S2 & S3 & S4 & S5 & S6 & S7 & S8 & SL & SP & SR & SRC & SMS & _).
    assert (HQ : Qrel bm bsr bsrc m m').
    { refine (lw_body_frame ge (Qrel bm bsr bsrc m) mario.f_update_mario_health
                (fun le => le ! mario._m = Some v)
                (fun id _ => negb (Pos.eqb id mario._m)) (fld_store_ok mario._m) pffs_call_ok eq_refl hl_chk
                _ _ _ m [v] t m' vr Hev _ _).
      - intros id a le m1 v1 Hs Hp _ _. cbv beta in *.
        rewrite PTree.gso; [exact Hp |]. intros E. rewrite E, Pos.eqb_refl in Hs. discriminate Hs.
      - intros lv rhs le m1 t1 le1 m2 out Hs Hp Hx HQ1.
        exact (fld_store v lv rhs le m m1 t1 le1 m2 out bsr bsrc Hs Hp Hmarg Hx HQ1).
      - intros optid a al le m1 t1 le1 m2 out Hs Hp Hx HQ1.
        exact (pffs_call lp H12 bm v optid a al le m m1 t1 le1 m2 out bsr bsrc SR SRC Hs Hp Hx HQ1).
      - intros le1 Hb1. change (fn_params mario.f_update_mario_health) with [(mario._m, tyMSp)] in Hb1.
        cbn [bind_parameter_temps] in Hb1. injection Hb1 as <-. apply PTree.gss.
      - split; [apply Mem.unchanged_on_refl | split; [reflexivity | tauto]]. }
    destruct HQ as (U & N & P).
    assert (NB : Mem.nextblock m' = Mem.nextblock m) by exact N.
    assert (PM : forall b o k p, Mem.perm m b o k p -> Mem.perm m' b o k p)
      by (intros b o k p Hp; exact (proj2 (P b o k p) Hp)).
    assert (LD : forall ch b z, b <> bsr -> b <> bsrc -> (b <> bm \/ hz z (size_chunk ch)) ->
               Mem.load ch m' b z = Mem.load ch m b z).
    { intros ch b z N1 N2 Hz.
      destruct (plt b (Mem.nextblock m)) as [V | V].
      - eapply Mem.load_unchanged_on_1; [exact U | exact V |].
        intros i Hi. split; [exact N1 | split; [exact N2 |]].
        intros (-> & Hi'). destruct Hz as [Hz | Hz]; [exact (Hz eq_refl) |].
        unfold hz in Hz. clear - Hi Hi' Hz. lia.
      - rewrite (load_invalid m ch b z V). apply load_invalid.
        unfold Mem.valid_block. rewrite N. exact V. }
    assert (CLK : forall gp, closed_by gp m -> syms_mapped ge gp -> gp bm <> None ->
      exists gp', (forall b, gp b <> None -> gp' b <> None) /\ closed_by gp' m' /\ syms_mapped ge gp').
    { intros gp0 HC0 HS0 HM0.
      assert (Hvok : Forall (vok gp0) [v]).
      { constructor; [| constructor].
        destruct v; try (constructor; fail).
        destruct Hmarg as [-> ->]. apply vok_mk_ptr. exact (closed_mapped_flat _ _ _ HC0 HM0). }
      destruct (funcall_closed ge m _ _ t m' vr gp0 Hev HC0 HS0 Hvok) as (gp' & I & HC' & HS' & _).
      exists gp'. split; [| exact (conj HC' HS')].
      intros b Hb'. destruct (gp0 b) as [[b1 d]|] eqn:E0; [| congruence].
      rewrite (I _ _ _ E0). discriminate. }
    pose proof Haw as (ab' & bga & bauc & btab & otab & bt' & ot' & mb' & mo' & B & _).
    pose proof B as (_ & _ & _ & _ & _ & _ & _ & _ & _ & _ & _ & _
                     & _ & _ & _ & _ & _ & _ & _ & _ & Hbm0).
    assert (NBR : bm <> bsr) by exact (AnimKeep.symne_ids ge _ _ _ _ Hbm0 SR eq_refl).
    assert (NBRC : bm <> bsrc) by exact (AnimKeep.symne_ids ge _ _ _ _ Hbm0 SRC eq_refl).
    split; [eapply hole_fworld; eassumption |].
    split; [exists c; split; [eapply hole_cells; eassumption | apply rt_refl] |].
    destruct health_is as (Iu & Ik & Id).
    unfold post_of. rewrite Iu, Ik, Id. exact I.
  Qed.

  (* ==================================================================== *)
  (* THE SPLIT                                                             *)
  (* ==================================================================== *)
  Ltac in_lit := solve [repeat (first [left; reflexivity | right])].

  Theorem naFA_of_open : na_open_rows -> seg_call_rows_naFA lp bm MWF.
  Proof.
    intros Hop f fd v Hin Hna Hnu Hr.
    assert (Hc : In f ema_calls).
    { (* explicit instance: unifying against the computed call list hangs *)
      pose proof (proj2 (in_flat_map (fun o => match o with OCall f => [f] | _ => [] end)
                           ema_obls f)) as I.
      unfold ema_calls. apply I. clear I.
      exists (OCall f). split; [exact Hin | left; reflexivity]. }
    rewrite ema_calls_eq in Hc.
    repeat match goal with Hc : In _ (_ :: _) |- _ => destruct Hc as [<- | Hc] end;
      [.. | destruct Hc].
    all: first
      [ exfalso; exact (Hna eq_refl)
      | exfalso; exact (Hnu eq_refl)
      | exact (ssc_row fd v Hr)
      | exact (health_row fd v Hr)
      | exact (sub_row fd v)
      | (apply (Hop _ fd v); [unfold na_open; in_lit | exact Hr]) ].
  Qed.
End NA.
