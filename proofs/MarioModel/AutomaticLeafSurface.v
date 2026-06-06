(* ====================================================================== *)
(* THE AUTOMATIC-FAMILY LEAF SURFACE (SPINE: automatic_leaf_callees_pres   *)
(* SHRINKS the capstone's automatic census via an incremental rest-split). *)
(*                                                                        *)
(* automatic_callee_ids (AutomaticSurface) is the 17 act_* leaves the     *)
(* automatic dispatcher delegates to. This file walks them one cluster at *)
(* a time: the capstone consumes the proved leaves and assumes only the   *)
(* shrinking automatic_rest_ids (the object-family rest-split pattern).    *)
(*                                                                        *)
(* WALKED so far:                                                         *)
(*   check_common_automatic_cancels  (slice 1: sole callee                *)
(*                                    set_water_plunge_action, swpa_row)  *)
(*   act_hanging, act_start_hanging  (slice 2, the HANG cluster: callees  *)
(*                                    set_mario_action(const) +           *)
(*                                    set_mario_animation +               *)
(*                                    update_hang_stationary [+ iaae +    *)
(*                                    psinf for start])                   *)
(* The two new internal helper rows (this file):                         *)
(*   set_mario_animation     (mario.prog; DEEP-chase cact body: writes    *)
(*                            through _o=marioObj and _targetAnim 2-hop;   *)
(*                            sole ext callee load_patchable_table)        *)
(*   update_hang_stationary  (mario_actions_automatic.prog; 1-hop chase    *)
(*                            cact=[_t'1]; ext callee vec3f_copy)          *)
(* DEFERRED: act_hang_moving (its helper update_hang_moving has a local    *)
(*   array _nextPos -- fn_vars<>nil blocker); act_grabbed (wact temp       *)
(*   action arg); act_in_cannon (A-gated flying write); act_tornado        *)
(*   (local _floor var). Plus the pole + ledge clusters.                  *)
(* ====================================================================== *)

From Coq Require Import ZArith Lia List.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking Errors.
From SM64.Generated Require mario mario_step mario_actions_automatic.
From SM64.Proofs Require Import SymbolicLinking Flying Taint
  ActionValueFrame RealFrameValue RealFrameLinked AGates.
From SM64.Proofs Require Import CensusV2 EngineV2Consumer RestSurface
  AirborneSurface DispatchKit FloorsSurface AutomaticSurface.
From SM64.Proofs Require Import ActWriterSurface ObjectLeafSurface.

Import ListNotations.

(* the leaves NOT yet walked: every slice moves ids out of here *)
Definition automatic_rest_ids : list ident :=
  mario_actions_automatic._act_holding_pole ::
  mario_actions_automatic._act_grab_pole_slow ::
  mario_actions_automatic._act_grab_pole_fast ::
  mario_actions_automatic._act_climbing_pole ::
  mario_actions_automatic._act_top_of_pole_transition ::
  mario_actions_automatic._act_top_of_pole ::
  mario_actions_automatic._act_hang_moving ::
  mario_actions_automatic._act_ledge_grab ::
  mario_actions_automatic._act_ledge_climb_slow ::
  mario_actions_automatic._act_ledge_climb_down ::
  mario_actions_automatic._act_ledge_climb_fast ::
  mario_actions_automatic._act_grabbed ::
  mario_actions_automatic._act_in_cannon ::
  mario_actions_automatic._act_tornado_twirling :: nil.

(* ---- censuses ---- *)
Definition ccac_ids : list ident := mario._set_water_plunge_action :: nil.
(* set_mario_animation: deep 2-hop chase, sole ext callee lpt *)
Definition sma_cact : list ident :=
  mario._o :: mario._targetAnim :: mario._t'13 :: mario._t'12
    :: mario._t'11 :: mario._t'10 :: nil.
Definition sma_xids : list ident := mario._load_patchable_table :: nil.
(* update_hang_stationary: 1-hop chase _t'1, ext vec3f_copy *)
Definition uhs_cact : list ident := mario_actions_automatic._t'1 :: nil.
Definition uhs_xids : list ident := mario_actions_automatic._vec3f_copy :: nil.
(* the hang leaves' internal Mario-arg callees *)
Definition hang_ids : list ident :=
  mario._set_mario_animation
    :: mario_actions_automatic._update_hang_stationary :: nil.
Definition shang_ids : list ident :=
  mario._set_mario_animation
    :: mario_actions_automatic._update_hang_stationary
    :: mario._is_anim_at_end :: mario._play_sound_if_no_flag :: nil.
Definition hang_sids : list ident := mario._set_mario_action :: nil.

(* ---- pins ---- *)
Example ccac_pin :
  (prog_defmap mario_actions_automatic.prog)
    ! mario_actions_automatic._check_common_automatic_cancels
  = Some (Gfun (Internal
      mario_actions_automatic.f_check_common_automatic_cancels)).
Proof. vm_compute. reflexivity. Qed.
Example sma_pin :
  (prog_defmap mario.prog) ! mario._set_mario_animation
  = Some (Gfun (Internal mario.f_set_mario_animation)).
Proof. vm_compute. reflexivity. Qed.
Example uhs_pin :
  (prog_defmap mario_actions_automatic.prog)
    ! mario_actions_automatic._update_hang_stationary
  = Some (Gfun (Internal mario_actions_automatic.f_update_hang_stationary)).
Proof. vm_compute. reflexivity. Qed.
Example hang_pin :
  (prog_defmap mario_actions_automatic.prog) ! mario_actions_automatic._act_hanging
  = Some (Gfun (Internal mario_actions_automatic.f_act_hanging)).
Proof. vm_compute. reflexivity. Qed.
Example shang_pin :
  (prog_defmap mario_actions_automatic.prog)
    ! mario_actions_automatic._act_start_hanging
  = Some (Gfun (Internal mario_actions_automatic.f_act_start_hanging)).
Proof. vm_compute. reflexivity. Qed.

(* ---- shapes ---- *)
Definition aut_pok (f : function) : bool :=
  match fn_params f with
  | (i, ty) :: ps =>
      (Pos.eqb i mario_actions_airborne._m
       && proj_sumbool (type_eq ty tyMSp)
       && negb (mem_id mario_actions_airborne._m (map fst ps)))%bool
  | nil => false
  end.
Example ccac_vars :
  fn_vars mario_actions_automatic.f_check_common_automatic_cancels = nil.
Proof. reflexivity. Qed.
Example sma_vars : fn_vars mario.f_set_mario_animation = nil.
Proof. reflexivity. Qed.
Example uhs_vars : fn_vars mario_actions_automatic.f_update_hang_stationary = nil.
Proof. reflexivity. Qed.
Example hang_vars : fn_vars mario_actions_automatic.f_act_hanging = nil.
Proof. reflexivity. Qed.
Example shang_vars : fn_vars mario_actions_automatic.f_act_start_hanging = nil.
Proof. reflexivity. Qed.
Example ccac_params_ok :
  aut_pok mario_actions_automatic.f_check_common_automatic_cancels = true.
Proof. vm_compute. reflexivity. Qed.
Example sma_params_ok : aut_pok mario.f_set_mario_animation = true.
Proof. vm_compute. reflexivity. Qed.
Example uhs_params_ok :
  aut_pok mario_actions_automatic.f_update_hang_stationary = true.
Proof. vm_compute. reflexivity. Qed.
Example hang_params_ok : aut_pok mario_actions_automatic.f_act_hanging = true.
Proof. vm_compute. reflexivity. Qed.
Example shang_params_ok :
  aut_pok mario_actions_automatic.f_act_start_hanging = true.
Proof. vm_compute. reflexivity. Qed.
Example sma_nonparam :
  forallb (fun t' => negb (mem_id t' (map fst (fn_params mario.f_set_mario_animation))))
    sma_cact = true.
Proof. vm_compute. reflexivity. Qed.
Example uhs_nonparam :
  forallb (fun t' => negb (mem_id t'
    (map fst (fn_params mario_actions_automatic.f_update_hang_stationary)))) uhs_cact = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- walks ---- *)
Example ccac_walk :
  wwalk_chk false nil ccac_ids nil nil nil nil nil
    (fn_body mario_actions_automatic.f_check_common_automatic_cancels) = true.
Proof. vm_compute. reflexivity. Qed.
Example sma_walk :
  wwalk_chk false nil nil nil sma_cact sma_xids nil nil
    (fn_body mario.f_set_mario_animation) = true.
Proof. vm_compute. reflexivity. Qed.
Example uhs_walk :
  wwalk_chk false nil nil nil uhs_cact uhs_xids nil nil
    (fn_body mario_actions_automatic.f_update_hang_stationary) = true.
Proof. vm_compute. reflexivity. Qed.
Example hang_walk :
  wwalk_chk false nil hang_ids nil nil nil hang_sids nil
    (fn_body mario_actions_automatic.f_act_hanging) = true.
Proof. vm_compute. reflexivity. Qed.
Example shang_walk :
  wwalk_chk false nil shang_ids nil nil nil hang_sids nil
    (fn_body mario_actions_automatic.f_act_start_hanging) = true.
Proof. vm_compute. reflexivity. Qed.

(* ====================================================================== *)
(* The rows.                                                              *)
(* ====================================================================== *)

Section AutomaticLeafRows.
  Variable lp : Clight.program.
  Hypothesis LO_mario : linkorder mario.prog lp.
  Hypothesis LO_mario_step : linkorder mario_step.prog lp.
  Hypothesis LO_aut : linkorder mario_actions_automatic.prog lp.

  Variable bm : block.
  Variable NoA MWF : mem -> Prop.

  Hypothesis HNoA_of_MWF : forall m, MWF m -> NoA m.
  Hypothesis HMWF_window : forall mm mm' ch (delta : Z) vv,
      MWF mm -> store_window_ok delta (size_chunk ch) = true ->
      Mem.store ch mm bm delta vv = Some mm' -> MWF mm'.
  Hypothesis HMWF_glob : forall gid,
      mem_id gid stored_globals = true ->
      forall bg, Genv.find_symbol (lp_ge lp) gid = Some bg ->
      bg <> bm /\
      (forall mm mm' ch0 (d : Z) vv,
          MWF mm -> Mem.store ch0 mm bg d vv = Some mm' -> MWF mm').
  Hypothesis HMWF_act : forall mm mm' vv,
      MWF mm ->
      (forall bb oo, vv <> Vptr bb oo) ->
      Mem.store Mint32 mm bm 12 vv = Some mm' -> MWF mm'.

  Variable SafeB : block -> Prop.
  Hypothesis HSafeNotBm : forall b, SafeB b -> b <> bm.
  Hypothesis HchaseRoot : forall fld delta m b' o',
      mem_id fld chase_root_fields = true ->
      field_offset (prog_comp_env mario.prog) fld mario_state_members
        = OK (delta, Full) ->
      MWF m ->
      Mem.loadv Mptr m
        (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr delta)))
        = Some (Vptr b' o') ->
      SafeB b'.
  Hypothesis HMWF_chase : forall mm ch bsafe (d : Z) vv mm',
      MWF mm -> SafeB bsafe ->
      (forall bb oo, vv <> Vptr bb oo) ->
      Mem.store ch mm bsafe d vv = Some mm' -> MWF mm'.
  Hypothesis HMWF_root : forall mm mm' fld (delta : Z) vv,
      mem_id fld chase_root_fields = true ->
      field_offset (prog_comp_env mario.prog) fld mario_state_members
        = OK (delta, Full) ->
      (forall bb oo, vv = Vptr bb oo -> SafeB bb) ->
      MWF mm ->
      Mem.store Mptr mm bm delta vv = Some mm' -> MWF mm'.
  Hypothesis HMWF_sglob : forall m gb v,
      MWF m ->
      Genv.find_symbol (lp_ge lp) interaction._gGlobalTimer = Some gb ->
      Mem.load Mint32 m gb 0 = Some v ->
      forall bb oo, v <> Vptr bb oo.
  Hypothesis HchaseStep : forall m b ofs b' o',
      MWF m -> SafeB b ->
      Mem.loadv Mptr m (Vptr b ofs) = Some (Vptr b' o') ->
      SafeB b'.
  Hypothesis HMWF_chase_safe : forall mm ch bsafe (d : Z) vv mm',
      MWF mm -> SafeB bsafe ->
      (forall bb oo, vv = Vptr bb oo -> SafeB bb) ->
      Mem.store ch mm bsafe d vv = Some mm' -> MWF mm'.

  (* ext rows (obj_ext_ids: SHARED with the object family) *)
  Hypothesis Hcpx_v3s :
    call_pres_ext lp bm NoA MWF mario._vec3s_set.
  Hypothesis Hcpx_scm :
    call_pres_ext lp bm NoA MWF mario._set_camera_mode.
  Hypothesis Hcpx_lpt :
    call_pres_ext lp bm NoA MWF mario._load_patchable_table.
  Hypothesis Hcpx_v3f :
    call_pres_ext lp bm NoA MWF mario_step._vec3f_copy.
  Hypothesis Hcpx_psound :
    call_pres_ext lp bm NoA MWF mario._play_sound.

  (* the shrinking residual: the leaves not yet walked *)
  Hypothesis Hpres_aut_rest : forall fid f,
      mem_id fid automatic_rest_ids = true ->
      (prog_defmap mario_actions_automatic.prog) ! fid
        = Some (Gfun (Internal f)) ->
      body_pres lp NoA MWF bm f.

  (* ---- reused rows from the object family + the keystone ---- *)
  Let Hsmact : call_pres_act lp bm NoA MWF mario._set_mario_action :=
    smact_pres lp LO_mario LO_mario_step bm NoA MWF HNoA_of_MWF
      HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
      HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe.
  Let Hswpa : call_pres lp bm NoA MWF mario._set_water_plunge_action :=
    swpa_row lp LO_mario LO_mario_step bm NoA MWF HNoA_of_MWF HMWF_window
      HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot HMWF_chase HMWF_root
      HMWF_sglob HchaseStep HMWF_chase_safe Hcpx_v3s Hcpx_scm.
  Let Hiaae : call_pres lp bm NoA MWF mario._is_anim_at_end :=
    iaae_row lp LO_mario bm NoA MWF HNoA_of_MWF HMWF_window HMWF_glob
      HMWF_act SafeB HSafeNotBm HchaseRoot HMWF_chase HMWF_root HMWF_sglob
      HchaseStep HMWF_chase_safe.
  Let Hpsinf : call_pres lp bm NoA MWF mario._play_sound_if_no_flag :=
    psinf_row lp LO_mario bm NoA MWF HNoA_of_MWF HMWF_window HMWF_glob
      HMWF_act SafeB HSafeNotBm HchaseRoot HMWF_chase HMWF_root HMWF_sglob
      HchaseStep HMWF_chase_safe Hcpx_psound.

  (* ---- the two NEW helper rows (this file) ---- *)
  Lemma sma_xids_rows :
    forall fid, mem_id fid sma_xids = true -> call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sma_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_lpt | ].
    discriminate H.
  Qed.
  Lemma Hsma : call_pres lp bm NoA MWF mario._set_mario_animation.
  Proof.
    apply (call_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario.prog mario._set_mario_animation mario.f_set_mario_animation
             nil nil sma_cact sma_xids nil
             LO_mario sma_pin sma_vars sma_params_ok sma_nonparam).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sma_xids_rows.
    - intros fid' H. discriminate H.
    - exact sma_walk.
  Qed.

  Lemma uhs_xids_rows :
    forall fid, mem_id fid uhs_xids = true -> call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold uhs_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_v3f | ].
    discriminate H.
  Qed.
  Lemma Huhs :
    call_pres lp bm NoA MWF mario_actions_automatic._update_hang_stationary.
  Proof.
    apply (call_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_automatic.prog
             mario_actions_automatic._update_hang_stationary
             mario_actions_automatic.f_update_hang_stationary
             nil nil uhs_cact uhs_xids nil
             LO_aut uhs_pin uhs_vars uhs_params_ok uhs_nonparam).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact uhs_xids_rows.
    - intros fid' H. discriminate H.
    - exact uhs_walk.
  Qed.

  (* ---- ids dispatch for the leaves ---- *)
  Lemma ccac_ids_rows :
    forall fid, mem_id fid ccac_ids = true -> call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold ccac_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hswpa | ].
    discriminate H.
  Qed.
  Lemma hang_ids_rows :
    forall fid, mem_id fid hang_ids = true -> call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold hang_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsma | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Huhs | ].
    discriminate H.
  Qed.
  Lemma shang_ids_rows :
    forall fid, mem_id fid shang_ids = true -> call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold shang_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsma | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Huhs | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hiaae | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hpsinf | ].
    discriminate H.
  Qed.
  Lemma hang_sids_rows :
    forall fid, mem_id fid hang_sids = true -> call_pres_act lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold hang_sids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsmact | ].
    discriminate H.
  Qed.

  (* ---- the leaves ---- *)
  Lemma ccac_pres :
    body_pres lp NoA MWF bm
      mario_actions_automatic.f_check_common_automatic_cancels.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_automatic.f_check_common_automatic_cancels
             ccac_ids nil nil nil nil ccac_vars ccac_params_ok).
    - exact ccac_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact ccac_walk.
  Qed.
  Lemma act_hanging_pres :
    body_pres lp NoA MWF bm mario_actions_automatic.f_act_hanging.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_automatic.f_act_hanging
             hang_ids nil nil hang_sids nil hang_vars hang_params_ok).
    - exact hang_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact hang_sids_rows.
    - intros fid' H. discriminate H.
    - exact hang_walk.
  Qed.
  Lemma act_start_hanging_pres :
    body_pres lp NoA MWF bm mario_actions_automatic.f_act_start_hanging.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_automatic.f_act_start_hanging
             shang_ids nil nil hang_sids nil shang_vars shang_params_ok).
    - exact shang_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact hang_sids_rows.
    - intros fid' H. discriminate H.
    - exact shang_walk.
  Qed.

  (* ================================================================== *)
  (* THE PAYOFF: ccac + the hang pair PROVED; the remaining 14 deferred   *)
  (* to the (smaller) rest residual.                                      *)
  (* ================================================================== *)
  Lemma automatic_leaf_callees_pres :
    forall fid f,
      mem_id fid automatic_callee_ids = true ->
      (prog_defmap mario_actions_automatic.prog) ! fid
        = Some (Gfun (Internal f)) ->
      body_pres lp NoA MWF bm f.
  Proof.
    intros fid f H Hdm.
    unfold automatic_callee_ids in H. cbn [mem_id existsb] in H.
    (* 1: check_common_automatic_cancels -- WALKED *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm. subst fid.
      rewrite ccac_pin in Hdm. injection Hdm as <-. exact ccac_pres. }
    (* 2..7: pole leaves -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm. subst fid.
      refine (Hpres_aut_rest _ f _ Hdm); vm_compute; reflexivity. }
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm. subst fid.
      refine (Hpres_aut_rest _ f _ Hdm); vm_compute; reflexivity. }
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm. subst fid.
      refine (Hpres_aut_rest _ f _ Hdm); vm_compute; reflexivity. }
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm. subst fid.
      refine (Hpres_aut_rest _ f _ Hdm); vm_compute; reflexivity. }
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm. subst fid.
      refine (Hpres_aut_rest _ f _ Hdm); vm_compute; reflexivity. }
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm. subst fid.
      refine (Hpres_aut_rest _ f _ Hdm); vm_compute; reflexivity. }
    (* 8: act_start_hanging -- WALKED *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm. subst fid.
      rewrite shang_pin in Hdm. injection Hdm as <-. exact act_start_hanging_pres. }
    (* 9: act_hanging -- WALKED *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm. subst fid.
      rewrite hang_pin in Hdm. injection Hdm as <-. exact act_hanging_pres. }
    (* 10..17: hang_moving + ledge + grabbed + cannon + tornado -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm. subst fid.
      refine (Hpres_aut_rest _ f _ Hdm); vm_compute; reflexivity. }
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm. subst fid.
      refine (Hpres_aut_rest _ f _ Hdm); vm_compute; reflexivity. }
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm. subst fid.
      refine (Hpres_aut_rest _ f _ Hdm); vm_compute; reflexivity. }
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm. subst fid.
      refine (Hpres_aut_rest _ f _ Hdm); vm_compute; reflexivity. }
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm. subst fid.
      refine (Hpres_aut_rest _ f _ Hdm); vm_compute; reflexivity. }
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm. subst fid.
      refine (Hpres_aut_rest _ f _ Hdm); vm_compute; reflexivity. }
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm. subst fid.
      refine (Hpres_aut_rest _ f _ Hdm); vm_compute; reflexivity. }
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm. subst fid.
      refine (Hpres_aut_rest _ f _ Hdm); vm_compute; reflexivity. }
    discriminate H.
  Qed.

End AutomaticLeafRows.
