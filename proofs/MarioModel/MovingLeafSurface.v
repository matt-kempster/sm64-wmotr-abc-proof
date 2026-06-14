(* ====================================================================== *)
(* THE MOVING-FAMILY LEAF SURFACE                                          *)
(* (SPINE: moving_leaf_callees_pres shrinks the capstone's                 *)
(*  Hpres_mov_callees down to a per-leaf census rest-split).               *)
(*                                                                         *)
(* MovingSurface.moving_pres walks the 39-arm dispatcher and reduces it to *)
(* ONE residual: body_pres for every leaf callee in moving_callee_ids (39  *)
(* ids).  Here we discharge those leaves one cluster at a time, mirroring  *)
(* StationaryLeafSurface.v.                                                *)
(*                                                                         *)
(* SLICE M1 (this file's first cut): the KNOCKBACK cluster -- the 7        *)
(* ground-knockback leaves (act_{,soft_,hard_}{backward,forward}_ground_kb *)
(* + act_ground_bonk).  All bottom out in common_ground_knockback_action   *)
(* (consts all untainted) + the shared ground-physics helper subtree       *)
(* (apply_landing_accel / apply_slope_accel / mario_floor_is_slope /       *)
(* mario_get_floor_class / mario_set_forward_vel / mario_update_moving_sand *)
(* / mario_update_windy_ground) + perform_ground_step + audio externals.   *)
(* The remaining 32 leaves stay under the rest premise moving_rest_ids.    *)
(* ====================================================================== *)

From Coq Require Import ZArith Lia List.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking Errors.
From SM64.Generated Require mario mario_step
  mario_actions_airborne mario_actions_moving.
From SM64.Proofs Require Import SymbolicLinking Flying Taint
  ActionValueFrame RealFrameValue RealFrameLinked AGates.
From SM64.Proofs Require Import CensusV2 EngineV2Consumer RestSurface
  AirborneSurface DispatchKit FloorsSurface.
From SM64.Proofs Require Import ActWriterSurface ObjectLeafSurface MovingSurface.

Import ListNotations.

(* ====================================================================== *)
(* Censuses (probe-derived).                                              *)
(* ====================================================================== *)

(* set_mario_action with a vm-checkably untainted constant 2nd arg *)
Definition mov_sids : list ident := mario._set_mario_action :: nil.

(* the moving family's pure audio externals -- EF_external in every linked
   TU, write no Mario state: the honest model-boundary class (like the
   stationary sta_ext_ids / the obj_ext audio rows). *)
Definition mov_ext_ids : list ident :=
  mario_actions_moving._play_mario_heavy_landing_sound_once
    :: mario_actions_moving._play_sound_if_no_flag
    :: mario_actions_moving._play_mario_landing_sound_once
    :: mario_actions_moving._play_mario_landing_sound :: nil.

(* set_mario_animation's chase temps + its load_patchable_table external *)
Definition mov_sma_cact : list ident :=
  mario._o :: mario._t'13 :: mario._t'12 :: mario._targetAnim :: nil.
Definition mov_sma_xids : list ident := mario._load_patchable_table :: nil.

(* apply_slope_accel's internal helper ids + its sqrtf external *)
Definition mov_asa_ids : list ident :=
  mario._mario_floor_is_slope :: mario._mario_get_floor_class
    :: mario_step._mario_update_moving_sand
    :: mario_step._mario_update_windy_ground :: nil.
Definition mov_asa_xids : list ident := mario._sqrtf :: nil.

(* apply_landing_accel's internal helper ids *)
Definition mov_ala_ids : list ident :=
  mario_actions_moving._apply_slope_accel
    :: mario._mario_floor_is_slope :: mario._mario_set_forward_vel :: nil.

(* common_ground_knockback_action's internal ids + audio xids *)
Definition mov_cgka_ids : list ident :=
  mario_actions_moving._apply_landing_accel
    :: mario._is_anim_at_end :: mario._mario_set_forward_vel
    :: mario_step._perform_ground_step :: mario._set_mario_animation :: nil.
Definition mov_cgka_xids : list ident :=
  mario_actions_moving._play_mario_heavy_landing_sound_once
    :: mario_actions_moving._play_sound_if_no_flag :: nil.

(* each knockback leaf calls common_ground_knockback_action (call_pres) *)
Definition mov_cgka_only : list ident :=
  mario_actions_moving._common_ground_knockback_action :: nil.
Definition mov_hard_back_xids : list ident :=
  mario_actions_moving._play_mario_landing_sound_once :: mario._play_sound :: nil.
Definition mov_gbonk_xids : list ident :=
  mario_actions_moving._play_mario_landing_sound :: nil.

(* the walked leaves (this slice) and the shrinking rest *)
Definition mov_walked_ids : list ident :=
  mario_actions_moving._act_backward_ground_kb
    :: mario_actions_moving._act_forward_ground_kb
    :: mario_actions_moving._act_soft_backward_ground_kb
    :: mario_actions_moving._act_soft_forward_ground_kb
    :: mario_actions_moving._act_hard_backward_ground_kb
    :: mario_actions_moving._act_hard_forward_ground_kb
    :: mario_actions_moving._act_ground_bonk :: nil.
Definition mov_rest_ids : list ident :=
  filter (fun id => negb (mem_id id mov_walked_ids)) moving_callee_ids.

(* ====================================================================== *)
(* Shape pins (vm_compute reflexivity over the real AST).                 *)
(* ====================================================================== *)

Definition mov_pok (f : function) : bool :=
  match fn_params f with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end.

(* ---- shared mario.prog / mario_step.prog helpers ---- *)
Example mov_mgfc_pin :
  (prog_defmap mario.prog) ! mario._mario_get_floor_class
  = Some (Gfun (Internal mario.f_mario_get_floor_class)).
Proof. vm_compute. reflexivity. Qed.
Example mov_mgfc_vars : fn_vars mario.f_mario_get_floor_class = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_mgfc_pok : mov_pok mario.f_mario_get_floor_class = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_mgfc_walk :
  wwalk_chk false nil nil nil nil nil nil nil
    (fn_body mario.f_mario_get_floor_class) = true.
Proof. vm_compute. reflexivity. Qed.

Example mov_mfis_pin :
  (prog_defmap mario.prog) ! mario._mario_floor_is_slope
  = Some (Gfun (Internal mario.f_mario_floor_is_slope)).
Proof. vm_compute. reflexivity. Qed.
Example mov_mfis_vars : fn_vars mario.f_mario_floor_is_slope = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_mfis_pok : mov_pok mario.f_mario_floor_is_slope = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_mfis_walk :
  wwalk_chk false nil (mario._mario_get_floor_class :: nil) nil nil nil nil nil
    (fn_body mario.f_mario_floor_is_slope) = true.
Proof. vm_compute. reflexivity. Qed.

Example mov_msfv_pin :
  (prog_defmap mario.prog) ! mario._mario_set_forward_vel
  = Some (Gfun (Internal mario.f_mario_set_forward_vel)).
Proof. vm_compute. reflexivity. Qed.
Example mov_msfv_vars : fn_vars mario.f_mario_set_forward_vel = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_msfv_pok : mov_pok mario.f_mario_set_forward_vel = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_msfv_walk :
  wwalk_chk false nil nil nil nil nil nil nil
    (fn_body mario.f_mario_set_forward_vel) = true.
Proof. vm_compute. reflexivity. Qed.

Example mov_iae_pin :
  (prog_defmap mario.prog) ! mario._is_anim_at_end
  = Some (Gfun (Internal mario.f_is_anim_at_end)).
Proof. vm_compute. reflexivity. Qed.
Example mov_iae_vars : fn_vars mario.f_is_anim_at_end = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_iae_pok : mov_pok mario.f_is_anim_at_end = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_iae_walk :
  wwalk_chk false nil nil nil nil nil nil nil
    (fn_body mario.f_is_anim_at_end) = true.
Proof. vm_compute. reflexivity. Qed.

Example mov_sma_pin :
  (prog_defmap mario.prog) ! mario._set_mario_animation
  = Some (Gfun (Internal mario.f_set_mario_animation)).
Proof. vm_compute. reflexivity. Qed.
Example mov_sma_vars : fn_vars mario.f_set_mario_animation = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_sma_pok : mov_pok mario.f_set_mario_animation = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_sma_nonparam :
  forallb (fun t' => negb (mem_id t'
             (map fst (fn_params mario.f_set_mario_animation)))) mov_sma_cact = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_sma_walk :
  wwalk_chk false nil nil nil mov_sma_cact mov_sma_xids nil nil
    (fn_body mario.f_set_mario_animation) = true.
Proof. vm_compute. reflexivity. Qed.

Example mov_mums_pin :
  (prog_defmap mario_step.prog) ! mario_step._mario_update_moving_sand
  = Some (Gfun (Internal mario_step.f_mario_update_moving_sand)).
Proof. vm_compute. reflexivity. Qed.
Example mov_mums_vars : fn_vars mario_step.f_mario_update_moving_sand = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_mums_pok : mov_pok mario_step.f_mario_update_moving_sand = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_mums_walk :
  wwalk_chk false nil nil nil nil nil nil nil
    (fn_body mario_step.f_mario_update_moving_sand) = true.
Proof. vm_compute. reflexivity. Qed.

Example mov_muwg_pin :
  (prog_defmap mario_step.prog) ! mario_step._mario_update_windy_ground
  = Some (Gfun (Internal mario_step.f_mario_update_windy_ground)).
Proof. vm_compute. reflexivity. Qed.
Example mov_muwg_vars : fn_vars mario_step.f_mario_update_windy_ground = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_muwg_pok : mov_pok mario_step.f_mario_update_windy_ground = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_muwg_walk :
  wwalk_chk false nil nil nil nil nil nil nil
    (fn_body mario_step.f_mario_update_windy_ground) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- moving.prog physics helpers ---- *)
Example mov_asa_pin :
  (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._apply_slope_accel
  = Some (Gfun (Internal mario_actions_moving.f_apply_slope_accel)).
Proof. vm_compute. reflexivity. Qed.
Example mov_asa_vars : fn_vars mario_actions_moving.f_apply_slope_accel = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_asa_pok : mov_pok mario_actions_moving.f_apply_slope_accel = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_asa_walk :
  wwalk_chk false nil mov_asa_ids nil nil mov_asa_xids nil nil
    (fn_body mario_actions_moving.f_apply_slope_accel) = true.
Proof. vm_compute. reflexivity. Qed.

Example mov_ala_pin :
  (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._apply_landing_accel
  = Some (Gfun (Internal mario_actions_moving.f_apply_landing_accel)).
Proof. vm_compute. reflexivity. Qed.
Example mov_ala_vars : fn_vars mario_actions_moving.f_apply_landing_accel = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_ala_pok : mov_pok mario_actions_moving.f_apply_landing_accel = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_ala_walk :
  wwalk_chk false nil mov_ala_ids nil nil nil nil nil
    (fn_body mario_actions_moving.f_apply_landing_accel) = true.
Proof. vm_compute. reflexivity. Qed.

Example mov_cgka_pin :
  (prog_defmap mario_actions_moving.prog)
    ! mario_actions_moving._common_ground_knockback_action
  = Some (Gfun (Internal mario_actions_moving.f_common_ground_knockback_action)).
Proof. vm_compute. reflexivity. Qed.
Example mov_cgka_vars :
  fn_vars mario_actions_moving.f_common_ground_knockback_action = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_cgka_pok :
  mov_pok mario_actions_moving.f_common_ground_knockback_action = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_cgka_walk :
  wwalk_chk false nil mov_cgka_ids nil nil mov_cgka_xids mov_sids nil
    (fn_body mario_actions_moving.f_common_ground_knockback_action) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- the 7 knockback leaves ---- *)
Example mov_bkb_pin :
  (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._act_backward_ground_kb
  = Some (Gfun (Internal mario_actions_moving.f_act_backward_ground_kb)).
Proof. vm_compute. reflexivity. Qed.
Example mov_bkb_vars : fn_vars mario_actions_moving.f_act_backward_ground_kb = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_bkb_pok : mov_pok mario_actions_moving.f_act_backward_ground_kb = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_bkb_walk :
  wwalk_chk false nil mov_cgka_only nil nil nil nil nil
    (fn_body mario_actions_moving.f_act_backward_ground_kb) = true.
Proof. vm_compute. reflexivity. Qed.

Example mov_fkb_pin :
  (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._act_forward_ground_kb
  = Some (Gfun (Internal mario_actions_moving.f_act_forward_ground_kb)).
Proof. vm_compute. reflexivity. Qed.
Example mov_fkb_vars : fn_vars mario_actions_moving.f_act_forward_ground_kb = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_fkb_pok : mov_pok mario_actions_moving.f_act_forward_ground_kb = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_fkb_walk :
  wwalk_chk false nil mov_cgka_only nil nil nil nil nil
    (fn_body mario_actions_moving.f_act_forward_ground_kb) = true.
Proof. vm_compute. reflexivity. Qed.

Example mov_sbkb_pin :
  (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._act_soft_backward_ground_kb
  = Some (Gfun (Internal mario_actions_moving.f_act_soft_backward_ground_kb)).
Proof. vm_compute. reflexivity. Qed.
Example mov_sbkb_vars : fn_vars mario_actions_moving.f_act_soft_backward_ground_kb = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_sbkb_pok : mov_pok mario_actions_moving.f_act_soft_backward_ground_kb = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_sbkb_walk :
  wwalk_chk false nil mov_cgka_only nil nil nil nil nil
    (fn_body mario_actions_moving.f_act_soft_backward_ground_kb) = true.
Proof. vm_compute. reflexivity. Qed.

Example mov_sfkb_pin :
  (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._act_soft_forward_ground_kb
  = Some (Gfun (Internal mario_actions_moving.f_act_soft_forward_ground_kb)).
Proof. vm_compute. reflexivity. Qed.
Example mov_sfkb_vars : fn_vars mario_actions_moving.f_act_soft_forward_ground_kb = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_sfkb_pok : mov_pok mario_actions_moving.f_act_soft_forward_ground_kb = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_sfkb_walk :
  wwalk_chk false nil mov_cgka_only nil nil nil nil nil
    (fn_body mario_actions_moving.f_act_soft_forward_ground_kb) = true.
Proof. vm_compute. reflexivity. Qed.

Example mov_hbkb_pin :
  (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._act_hard_backward_ground_kb
  = Some (Gfun (Internal mario_actions_moving.f_act_hard_backward_ground_kb)).
Proof. vm_compute. reflexivity. Qed.
Example mov_hbkb_vars : fn_vars mario_actions_moving.f_act_hard_backward_ground_kb = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_hbkb_pok : mov_pok mario_actions_moving.f_act_hard_backward_ground_kb = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_hbkb_walk :
  wwalk_chk false nil mov_cgka_only nil nil mov_hard_back_xids mov_sids nil
    (fn_body mario_actions_moving.f_act_hard_backward_ground_kb) = true.
Proof. vm_compute. reflexivity. Qed.

Example mov_hfkb_pin :
  (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._act_hard_forward_ground_kb
  = Some (Gfun (Internal mario_actions_moving.f_act_hard_forward_ground_kb)).
Proof. vm_compute. reflexivity. Qed.
Example mov_hfkb_vars : fn_vars mario_actions_moving.f_act_hard_forward_ground_kb = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_hfkb_pok : mov_pok mario_actions_moving.f_act_hard_forward_ground_kb = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_hfkb_walk :
  wwalk_chk false nil mov_cgka_only nil nil nil mov_sids nil
    (fn_body mario_actions_moving.f_act_hard_forward_ground_kb) = true.
Proof. vm_compute. reflexivity. Qed.

Example mov_gbonk_pin :
  (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._act_ground_bonk
  = Some (Gfun (Internal mario_actions_moving.f_act_ground_bonk)).
Proof. vm_compute. reflexivity. Qed.
Example mov_gbonk_vars : fn_vars mario_actions_moving.f_act_ground_bonk = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_gbonk_pok : mov_pok mario_actions_moving.f_act_ground_bonk = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_gbonk_walk :
  wwalk_chk false nil mov_cgka_only nil nil mov_gbonk_xids nil nil
    (fn_body mario_actions_moving.f_act_ground_bonk) = true.
Proof. vm_compute. reflexivity. Qed.

(* ====================================================================== *)
(* The rows + the rest-split (one section, the full 12-hyp MWF kit).      *)
(* ====================================================================== *)

Section MovingLeafRows.
  Variable lp : Clight.program.
  Hypothesis LO_mario : linkorder mario.prog lp.
  Hypothesis LO_mario_step : linkorder mario_step.prog lp.
  Hypothesis LO_mov : linkorder mario_actions_moving.prog lp.

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

  (* obj_ext externals the knockback subtree bottoms out in *)
  Hypothesis Hcpx_sqrtf :
    call_pres_ext lp bm NoA MWF mario._sqrtf.
  Hypothesis Hcpx_psound :
    call_pres_ext lp bm NoA MWF mario._play_sound.
  Hypothesis Hcpx_lpt :
    call_pres_ext lp bm NoA MWF mario._load_patchable_table.
  (* the moving family's pure audio externals (mov_ext_ids) -- the honest
     model boundary; discharged at the capstone. *)
  Hypothesis Hpres_mov_ext : forall fid,
      mem_id fid mov_ext_ids = true -> call_pres_ext lp bm NoA MWF fid.
  (* perform_ground_step: discharged at the capstone (MarioStepSurface) *)
  Hypothesis Hcp_pgs :
    call_pres lp bm NoA MWF mario_step._perform_ground_step.

  (* the set_mario_action keystone, instantiated once *)
  Let Hsmact : call_pres_act lp bm NoA MWF mario._set_mario_action :=
    smact_pres lp LO_mario LO_mario_step bm NoA MWF HNoA_of_MWF
      HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
      HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe.

  Lemma mov_sids_rows : forall fid, mem_id fid mov_sids = true ->
      call_pres_act lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_sids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsmact | ].
    discriminate H.
  Qed.

  Lemma mov_sma_xids_rows : forall fid, mem_id fid mov_sma_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_sma_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_lpt | ].
    discriminate H.
  Qed.

  Lemma mov_asa_xids_rows : forall fid, mem_id fid mov_asa_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_asa_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_sqrtf | ].
    discriminate H.
  Qed.

  Lemma mov_cgka_xids_rows : forall fid, mem_id fid mov_cgka_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_cgka_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid;
        apply Hpres_mov_ext; vm_compute; reflexivity | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid;
        apply Hpres_mov_ext; vm_compute; reflexivity | ].
    discriminate H.
  Qed.

  Lemma mov_hard_back_xids_rows : forall fid, mem_id fid mov_hard_back_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_hard_back_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid;
        apply Hpres_mov_ext; vm_compute; reflexivity | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_psound | ].
    discriminate H.
  Qed.

  Lemma mov_gbonk_xids_rows : forall fid, mem_id fid mov_gbonk_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_gbonk_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid;
        apply Hpres_mov_ext; vm_compute; reflexivity | ].
    discriminate H.
  Qed.

  (* ---- the shared mario.prog / mario_step.prog helper rows ---- *)
  Lemma mov_mgfc_row : call_pres lp bm NoA MWF mario._mario_get_floor_class.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario.prog mario._mario_get_floor_class mario.f_mario_get_floor_class
             nil nil nil nil LO_mario mov_mgfc_pin mov_mgfc_vars mov_mgfc_pok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact mov_mgfc_walk.
  Qed.

  Lemma mov_mfis_ids_rows : forall fid,
      mem_id fid (mario._mario_get_floor_class :: nil) = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_mgfc_row | ].
    discriminate H.
  Qed.

  Lemma mov_mfis_row : call_pres lp bm NoA MWF mario._mario_floor_is_slope.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario.prog mario._mario_floor_is_slope mario.f_mario_floor_is_slope
             (mario._mario_get_floor_class :: nil) nil nil nil
             LO_mario mov_mfis_pin mov_mfis_vars mov_mfis_pok).
    - exact mov_mfis_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact mov_mfis_walk.
  Qed.

  Lemma mov_msfv_row : call_pres lp bm NoA MWF mario._mario_set_forward_vel.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario.prog mario._mario_set_forward_vel mario.f_mario_set_forward_vel
             nil nil nil nil LO_mario mov_msfv_pin mov_msfv_vars mov_msfv_pok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact mov_msfv_walk.
  Qed.

  Lemma mov_iae_row : call_pres lp bm NoA MWF mario._is_anim_at_end.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario.prog mario._is_anim_at_end mario.f_is_anim_at_end
             nil nil nil nil LO_mario mov_iae_pin mov_iae_vars mov_iae_pok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact mov_iae_walk.
  Qed.

  Lemma mov_sma_row : call_pres lp bm NoA MWF mario._set_mario_animation.
  Proof.
    apply (call_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario.prog mario._set_mario_animation mario.f_set_mario_animation
             nil nil mov_sma_cact mov_sma_xids nil
             LO_mario mov_sma_pin mov_sma_vars mov_sma_pok mov_sma_nonparam).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact mov_sma_xids_rows.
    - intros fid' H. discriminate H.
    - exact mov_sma_walk.
  Qed.

  Lemma mov_mums_row :
    call_pres lp bm NoA MWF mario_step._mario_update_moving_sand.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_step.prog mario_step._mario_update_moving_sand
             mario_step.f_mario_update_moving_sand
             nil nil nil nil LO_mario_step mov_mums_pin mov_mums_vars mov_mums_pok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact mov_mums_walk.
  Qed.

  Lemma mov_muwg_row :
    call_pres lp bm NoA MWF mario_step._mario_update_windy_ground.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_step.prog mario_step._mario_update_windy_ground
             mario_step.f_mario_update_windy_ground
             nil nil nil nil LO_mario_step mov_muwg_pin mov_muwg_vars mov_muwg_pok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact mov_muwg_walk.
  Qed.

  (* ---- apply_slope_accel: ids = floor helpers + moving_sand/windy_ground ---- *)
  Lemma mov_asa_ids_rows : forall fid, mem_id fid mov_asa_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_asa_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_mfis_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_mgfc_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_mums_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_muwg_row | ].
    discriminate H.
  Qed.

  Lemma mov_asa_row : call_pres lp bm NoA MWF mario_actions_moving._apply_slope_accel.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_moving.prog mario_actions_moving._apply_slope_accel
             mario_actions_moving.f_apply_slope_accel
             mov_asa_ids nil mov_asa_xids nil
             LO_mov mov_asa_pin mov_asa_vars mov_asa_pok).
    - exact mov_asa_ids_rows.
    - intros fid' H. discriminate H.
    - exact mov_asa_xids_rows.
    - intros fid' H. discriminate H.
    - exact mov_asa_walk.
  Qed.

  (* ---- apply_landing_accel: ids = apply_slope_accel + floor + set_fwd_vel ---- *)
  Lemma mov_ala_ids_rows : forall fid, mem_id fid mov_ala_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_ala_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_asa_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_mfis_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_msfv_row | ].
    discriminate H.
  Qed.

  Lemma mov_ala_row : call_pres lp bm NoA MWF mario_actions_moving._apply_landing_accel.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_moving.prog mario_actions_moving._apply_landing_accel
             mario_actions_moving.f_apply_landing_accel
             mov_ala_ids nil nil nil
             LO_mov mov_ala_pin mov_ala_vars mov_ala_pok).
    - exact mov_ala_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact mov_ala_walk.
  Qed.

  (* ---- common_ground_knockback_action: the cluster keystone ---- *)
  Lemma mov_cgka_ids_rows : forall fid, mem_id fid mov_cgka_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_cgka_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_ala_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_iae_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_msfv_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_pgs | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_sma_row | ].
    discriminate H.
  Qed.

  Lemma mov_cgka_row :
    call_pres lp bm NoA MWF mario_actions_moving._common_ground_knockback_action.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_moving.prog
             mario_actions_moving._common_ground_knockback_action
             mario_actions_moving.f_common_ground_knockback_action
             mov_cgka_ids nil mov_cgka_xids mov_sids
             LO_mov mov_cgka_pin mov_cgka_vars mov_cgka_pok).
    - exact mov_cgka_ids_rows.
    - intros fid' H. discriminate H.
    - exact mov_cgka_xids_rows.
    - exact mov_sids_rows.
    - exact mov_cgka_walk.
  Qed.

  (* the leaves' ids = common_ground_knockback_action (call_pres) *)
  Lemma mov_cgka_only_rows : forall fid, mem_id fid mov_cgka_only = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_cgka_only in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_cgka_row | ].
    discriminate H.
  Qed.

  (* ---- the 7 knockback leaves (body_pres) ---- *)
  Lemma mov_bkb_pres :
    body_pres lp NoA MWF bm mario_actions_moving.f_act_backward_ground_kb.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_moving.f_act_backward_ground_kb
             mov_cgka_only nil nil nil nil mov_bkb_vars mov_bkb_pok).
    - exact mov_cgka_only_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact mov_bkb_walk.
  Qed.

  Lemma mov_fkb_pres :
    body_pres lp NoA MWF bm mario_actions_moving.f_act_forward_ground_kb.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_moving.f_act_forward_ground_kb
             mov_cgka_only nil nil nil nil mov_fkb_vars mov_fkb_pok).
    - exact mov_cgka_only_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact mov_fkb_walk.
  Qed.

  Lemma mov_sbkb_pres :
    body_pres lp NoA MWF bm mario_actions_moving.f_act_soft_backward_ground_kb.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_moving.f_act_soft_backward_ground_kb
             mov_cgka_only nil nil nil nil mov_sbkb_vars mov_sbkb_pok).
    - exact mov_cgka_only_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact mov_sbkb_walk.
  Qed.

  Lemma mov_sfkb_pres :
    body_pres lp NoA MWF bm mario_actions_moving.f_act_soft_forward_ground_kb.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_moving.f_act_soft_forward_ground_kb
             mov_cgka_only nil nil nil nil mov_sfkb_vars mov_sfkb_pok).
    - exact mov_cgka_only_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact mov_sfkb_walk.
  Qed.

  Lemma mov_hbkb_pres :
    body_pres lp NoA MWF bm mario_actions_moving.f_act_hard_backward_ground_kb.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_moving.f_act_hard_backward_ground_kb
             mov_cgka_only nil mov_hard_back_xids mov_sids nil
             mov_hbkb_vars mov_hbkb_pok).
    - exact mov_cgka_only_rows.
    - intros fid' H. discriminate H.
    - exact mov_hard_back_xids_rows.
    - exact mov_sids_rows.
    - intros fid' H. discriminate H.
    - exact mov_hbkb_walk.
  Qed.

  Lemma mov_hfkb_pres :
    body_pres lp NoA MWF bm mario_actions_moving.f_act_hard_forward_ground_kb.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_moving.f_act_hard_forward_ground_kb
             mov_cgka_only nil nil mov_sids nil
             mov_hfkb_vars mov_hfkb_pok).
    - exact mov_cgka_only_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact mov_sids_rows.
    - intros fid' H. discriminate H.
    - exact mov_hfkb_walk.
  Qed.

  Lemma mov_gbonk_pres :
    body_pres lp NoA MWF bm mario_actions_moving.f_act_ground_bonk.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_moving.f_act_ground_bonk
             mov_cgka_only nil mov_gbonk_xids nil nil
             mov_gbonk_vars mov_gbonk_pok).
    - exact mov_cgka_only_rows.
    - intros fid' H. discriminate H.
    - exact mov_gbonk_xids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact mov_gbonk_walk.
  Qed.

  (* ================================================================== *)
  (* THE REST-SPLIT: the capstone's Hpres_mov_callees from the walked   *)
  (* leaves + the shrinking mov_rest_ids residual.                      *)
  (* ================================================================== *)
  Lemma moving_leaf_callees_pres :
    (forall fid f, mem_id fid mov_rest_ids = true ->
       (prog_defmap mario_actions_moving.prog) ! fid
         = Some (Gfun (Internal f)) ->
       body_pres lp NoA MWF bm f) ->
    forall fid f, mem_id fid moving_callee_ids = true ->
      (prog_defmap mario_actions_moving.prog) ! fid
        = Some (Gfun (Internal f)) ->
      body_pres lp NoA MWF bm f.
  Proof.
    intros Hrest fid f H Hdm.
    unfold moving_callee_ids in H. cbn [mem_id existsb] in H.
    (* 1: check_common_moving_cancels -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 2: act_walking -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 3: act_hold_walking -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 4: act_hold_heavy_walking -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 5: act_turning_around -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 6: act_finish_turning_around -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 7: act_braking -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 8: act_riding_shell_ground -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 9: act_crawling -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 10: act_burning_ground -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 11: act_decelerating -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 12: act_hold_decelerating -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 13: act_butt_slide -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 14: act_stomach_slide -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 15: act_hold_butt_slide -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 16: act_hold_stomach_slide -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 17: act_dive_slide -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 18: act_move_punching -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 19: act_crouch_slide -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 20: act_slide_kick_slide -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 21: act_hard_backward_ground_kb -- WALKED *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite mov_hbkb_pin in Hdm. injection Hdm as <-. exact mov_hbkb_pres. }
    (* 22: act_hard_forward_ground_kb -- WALKED *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite mov_hfkb_pin in Hdm. injection Hdm as <-. exact mov_hfkb_pres. }
    (* 23: act_backward_ground_kb -- WALKED *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite mov_bkb_pin in Hdm. injection Hdm as <-. exact mov_bkb_pres. }
    (* 24: act_forward_ground_kb -- WALKED *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite mov_fkb_pin in Hdm. injection Hdm as <-. exact mov_fkb_pres. }
    (* 25: act_soft_backward_ground_kb -- WALKED *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite mov_sbkb_pin in Hdm. injection Hdm as <-. exact mov_sbkb_pres. }
    (* 26: act_soft_forward_ground_kb -- WALKED *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite mov_sfkb_pin in Hdm. injection Hdm as <-. exact mov_sfkb_pres. }
    (* 27: act_ground_bonk -- WALKED *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite mov_gbonk_pin in Hdm. injection Hdm as <-. exact mov_gbonk_pres. }
    (* 28: act_death_exit_land -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 29: act_jump_land -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 30: act_freefall_land -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 31: act_double_jump_land -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 32: act_side_flip_land -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 33: act_hold_jump_land -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 34: act_hold_freefall_land -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 35: act_triple_jump_land -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 36: act_backflip_land -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 37: act_quicksand_jump_land -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 38: act_hold_quicksand_jump_land -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 39: act_long_jump_land -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    discriminate H.
  Qed.

End MovingLeafRows.
