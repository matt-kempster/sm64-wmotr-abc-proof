(* ====================================================================== *)
(* THE STATIONARY-FAMILY LEAF SURFACE                                      *)
(* (SPINE: stationary_leaf_callees_pres shrinks the capstone's            *)
(*  Hpres_sta_callees down to a per-leaf census rest-split).               *)
(*                                                                         *)
(* StationarySurface.stationary_pres walks the 36-arm dispatcher and       *)
(* reduces it to ONE residual: body_pres for every leaf callee in          *)
(* stationary_callee_ids (37 ids).  Here we discharge those leaves one     *)
(* cluster at a time, mirroring AutomaticLeafSurface / ObjectLeafSurface.  *)
(*                                                                         *)
(* SLICE 1 (this file's first cut): the "clean stationary-step" cluster -- *)
(* act_standing_against_wall / act_start_crawling / act_stop_crawling.     *)
(* Their bodies only read m->input, call set_mario_action(untainted const),*)
(* set_mario_animation, is_anim_past_end / check_common_action_exits, and  *)
(* stationary_ground_step -- every callee bottoms out in the smact_pres    *)
(* keystone + the already-understood helper rows (no A-gated cancel helper,*)
(* no caller-action-threading step helper).  The remaining 34 leaves stay  *)
(* under the rest premise sta_rest_ids.                                    *)
(* ====================================================================== *)

From Coq Require Import ZArith Lia List.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking Errors.
From SM64.Generated Require mario mario_step interaction
  mario_actions_airborne mario_actions_stationary.
From SM64.Proofs Require Import SymbolicLinking Flying Taint
  ActionValueFrame RealFrameValue RealFrameLinked AGates.
From SM64.Proofs Require Import CensusV2 EngineV2Consumer RestSurface
  AirborneSurface DispatchKit FloorsSurface.
From SM64.Proofs Require Import ActWriterSurface StationarySurface.

Import ListNotations.

(* ====================================================================== *)
(* Censuses (probe-derived).                                              *)
(* ====================================================================== *)

(* the shared smact-const census: set_mario_action with a vm-checkably
   untainted constant 2nd arg *)
Definition sta_sids : list ident := mario._set_mario_action :: nil.

(* the helper callees the slice-1 leaves invoke (passing m, marg) *)
Definition sta_leaf_ids : list ident :=
  mario._check_common_action_exits
    :: mario._is_anim_past_end
    :: mario._set_mario_animation
    :: mario_step._stationary_ground_step :: nil.

(* the stationary_ground_step sub-tree: msfv + the two sand/wind updaters
   + perform_ground_step, plus the two math-util gfx copiers *)
Definition sta_sgs_ids : list ident :=
  mario._mario_set_forward_vel
    :: mario_step._mario_update_moving_sand
    :: mario_step._mario_update_windy_ground
    :: mario_step._perform_ground_step :: nil.
Definition sta_sgs_xids : list ident :=
  mario_step._vec3f_copy :: mario._vec3s_set :: nil.

(* set_mario_animation's chase temps + the one external it calls *)
Definition sta_sma_cact : list ident :=
  mario._o :: mario._t'13 :: mario._t'12 :: mario._targetAnim :: nil.
Definition sta_sma_xids : list ident :=
  mario._load_patchable_table :: nil.

(* ====================================================================== *)
(* Shape pins (vm_compute reflexivity over the real AST).                 *)
(* ====================================================================== *)

(* ---- is_anim_past_end ---- *)
Example sta_ipae_pin :
  (prog_defmap mario.prog) ! mario._is_anim_past_end
  = Some (Gfun (Internal mario.f_is_anim_past_end)).
Proof. vm_compute. reflexivity. Qed.
Example sta_ipae_vars : fn_vars mario.f_is_anim_past_end = nil.
Proof. vm_compute. reflexivity. Qed.
Example sta_ipae_params_ok :
  match fn_params mario.f_is_anim_past_end with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example sta_ipae_walk :
  wwalk_chk false nil nil nil nil nil nil nil
    (fn_body mario.f_is_anim_past_end) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- check_common_action_exits (four smact-const exits) ---- *)
Example sta_ccae_pin :
  (prog_defmap mario.prog) ! mario._check_common_action_exits
  = Some (Gfun (Internal mario.f_check_common_action_exits)).
Proof. vm_compute. reflexivity. Qed.
Example sta_ccae_vars : fn_vars mario.f_check_common_action_exits = nil.
Proof. vm_compute. reflexivity. Qed.
Example sta_ccae_params_ok :
  match fn_params mario.f_check_common_action_exits with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example sta_ccae_walk :
  wwalk_chk false nil nil nil nil nil sta_sids nil
    (fn_body mario.f_check_common_action_exits) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- set_mario_animation ---- *)
Example sta_sma_pin :
  (prog_defmap mario.prog) ! mario._set_mario_animation
  = Some (Gfun (Internal mario.f_set_mario_animation)).
Proof. vm_compute. reflexivity. Qed.
Example sta_sma_vars : fn_vars mario.f_set_mario_animation = nil.
Proof. vm_compute. reflexivity. Qed.
Example sta_sma_params_ok :
  match fn_params mario.f_set_mario_animation with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example sta_sma_nonparam :
  forallb (fun t' => negb (mem_id t'
             (map fst (fn_params mario.f_set_mario_animation))))
    sta_sma_cact = true.
Proof. vm_compute. reflexivity. Qed.
Example sta_sma_walk :
  wwalk_chk false nil nil nil sta_sma_cact sta_sma_xids nil nil
    (fn_body mario.f_set_mario_animation) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- mario_update_moving_sand / mario_update_windy_ground (pure) ---- *)
Example sta_mums_pin :
  (prog_defmap mario_step.prog) ! mario_step._mario_update_moving_sand
  = Some (Gfun (Internal mario_step.f_mario_update_moving_sand)).
Proof. vm_compute. reflexivity. Qed.
Example sta_mums_vars : fn_vars mario_step.f_mario_update_moving_sand = nil.
Proof. vm_compute. reflexivity. Qed.
Example sta_mums_params_ok :
  match fn_params mario_step.f_mario_update_moving_sand with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example sta_mums_walk :
  wwalk_chk false nil nil nil nil nil nil nil
    (fn_body mario_step.f_mario_update_moving_sand) = true.
Proof. vm_compute. reflexivity. Qed.

Example sta_muwg_pin :
  (prog_defmap mario_step.prog) ! mario_step._mario_update_windy_ground
  = Some (Gfun (Internal mario_step.f_mario_update_windy_ground)).
Proof. vm_compute. reflexivity. Qed.
Example sta_muwg_vars : fn_vars mario_step.f_mario_update_windy_ground = nil.
Proof. vm_compute. reflexivity. Qed.
Example sta_muwg_params_ok :
  match fn_params mario_step.f_mario_update_windy_ground with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example sta_muwg_walk :
  wwalk_chk false nil nil nil nil nil nil nil
    (fn_body mario_step.f_mario_update_windy_ground) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- stationary_ground_step ---- *)
Example sta_sgs_pin :
  (prog_defmap mario_step.prog) ! mario_step._stationary_ground_step
  = Some (Gfun (Internal mario_step.f_stationary_ground_step)).
Proof. vm_compute. reflexivity. Qed.
Example sta_sgs_vars : fn_vars mario_step.f_stationary_ground_step = nil.
Proof. vm_compute. reflexivity. Qed.
Example sta_sgs_params_ok :
  match fn_params mario_step.f_stationary_ground_step with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example sta_sgs_walk :
  wwalk_chk false nil sta_sgs_ids nil nil sta_sgs_xids nil nil
    (fn_body mario_step.f_stationary_ground_step) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- the three slice-1 leaves ---- *)
Example sta_saw_pin :
  (prog_defmap mario_actions_stationary.prog)
    ! mario_actions_stationary._act_standing_against_wall
  = Some (Gfun (Internal mario_actions_stationary.f_act_standing_against_wall)).
Proof. vm_compute. reflexivity. Qed.
Example sta_saw_vars :
  fn_vars mario_actions_stationary.f_act_standing_against_wall = nil.
Proof. vm_compute. reflexivity. Qed.
Example sta_saw_params_ok :
  match fn_params mario_actions_stationary.f_act_standing_against_wall with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example sta_saw_walk :
  wwalk_chk false nil sta_leaf_ids nil nil nil sta_sids nil
    (fn_body mario_actions_stationary.f_act_standing_against_wall) = true.
Proof. vm_compute. reflexivity. Qed.

Example sta_ascr_pin :
  (prog_defmap mario_actions_stationary.prog)
    ! mario_actions_stationary._act_start_crawling
  = Some (Gfun (Internal mario_actions_stationary.f_act_start_crawling)).
Proof. vm_compute. reflexivity. Qed.
Example sta_ascr_vars :
  fn_vars mario_actions_stationary.f_act_start_crawling = nil.
Proof. vm_compute. reflexivity. Qed.
Example sta_ascr_params_ok :
  match fn_params mario_actions_stationary.f_act_start_crawling with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example sta_ascr_walk :
  wwalk_chk false nil sta_leaf_ids nil nil nil sta_sids nil
    (fn_body mario_actions_stationary.f_act_start_crawling) = true.
Proof. vm_compute. reflexivity. Qed.

Example sta_apcr_pin :
  (prog_defmap mario_actions_stationary.prog)
    ! mario_actions_stationary._act_stop_crawling
  = Some (Gfun (Internal mario_actions_stationary.f_act_stop_crawling)).
Proof. vm_compute. reflexivity. Qed.
Example sta_apcr_vars :
  fn_vars mario_actions_stationary.f_act_stop_crawling = nil.
Proof. vm_compute. reflexivity. Qed.
Example sta_apcr_params_ok :
  match fn_params mario_actions_stationary.f_act_stop_crawling with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example sta_apcr_walk :
  wwalk_chk false nil sta_leaf_ids nil nil nil sta_sids nil
    (fn_body mario_actions_stationary.f_act_stop_crawling) = true.
Proof. vm_compute. reflexivity. Qed.

(* act_shivering's one external (play_sound, in the obj_ext model class) *)
Definition sta_psound_xids : list ident := mario._play_sound :: nil.

Example sta_ashv_pin :
  (prog_defmap mario_actions_stationary.prog)
    ! mario_actions_stationary._act_shivering
  = Some (Gfun (Internal mario_actions_stationary.f_act_shivering)).
Proof. vm_compute. reflexivity. Qed.
Example sta_ashv_vars :
  fn_vars mario_actions_stationary.f_act_shivering = nil.
Proof. vm_compute. reflexivity. Qed.
Example sta_ashv_params_ok :
  match fn_params mario_actions_stationary.f_act_shivering with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example sta_ashv_walk :
  wwalk_chk false nil sta_leaf_ids nil nil sta_psound_xids sta_sids nil
    (fn_body mario_actions_stationary.f_act_shivering) = true.
Proof. vm_compute. reflexivity. Qed.

(* the unwalked remainder of stationary_callee_ids (filter, not a
   hand-spelled list -- shrinks automatically as leaves move out) *)
Definition sta_walked_ids : list ident :=
  mario_actions_stationary._act_standing_against_wall
    :: mario_actions_stationary._act_start_crawling
    :: mario_actions_stationary._act_stop_crawling
    :: mario_actions_stationary._act_shivering :: nil.
Definition sta_rest_ids : list ident :=
  filter (fun id => negb (mem_id id sta_walked_ids)) stationary_callee_ids.

(* ====================================================================== *)
(* The walk.                                                              *)
(* ====================================================================== *)

Section StationaryLeafRows.
  Variable lp : Clight.program.
  Hypothesis LO_mario : linkorder mario.prog lp.
  Hypothesis LO_mario_step : linkorder mario_step.prog lp.
  Hypothesis LO_sta : linkorder mario_actions_stationary.prog lp.

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

  (* the externals these leaves' helper sub-trees bottom out in *)
  Hypothesis Hcpx_v3f :
    call_pres_ext lp bm NoA MWF mario_step._vec3f_copy.
  Hypothesis Hcpx_v3s :
    call_pres_ext lp bm NoA MWF mario._vec3s_set.
  Hypothesis Hcpx_lpt :
    call_pres_ext lp bm NoA MWF mario._load_patchable_table.
  (* play_sound: a pure AUDIO external (same model class as the obj_ext rows);
     discharged at the capstone via Hpres_obj_ext (play_sound in obj_ext_ids) *)
  Hypothesis Hcpx_psound :
    call_pres_ext lp bm NoA MWF mario._play_sound.
  (* perform_ground_step: discharged at the capstone (MarioStepSurface) *)
  Hypothesis Hcp_pgs :
    call_pres lp bm NoA MWF mario_step._perform_ground_step.

  (* the keystone, instantiated once *)
  Let Hsmact : call_pres_act lp bm NoA MWF mario._set_mario_action :=
    smact_pres lp LO_mario LO_mario_step bm NoA MWF HNoA_of_MWF
      HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
      HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe.

  Lemma sta_sids_rows : forall fid, mem_id fid sta_sids = true ->
      call_pres_act lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sta_sids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsmact | ].
    discriminate H.
  Qed.

  (* ---- is_anim_past_end (loads only) ---- *)
  Lemma sta_ipae_row : call_pres lp bm NoA MWF mario._is_anim_past_end.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario.prog mario._is_anim_past_end
             mario.f_is_anim_past_end nil nil nil nil
             LO_mario sta_ipae_pin sta_ipae_vars sta_ipae_params_ok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sta_ipae_walk.
  Qed.

  (* ---- check_common_action_exits (four smact-const exits) ---- *)
  Lemma sta_ccae_row :
    call_pres lp bm NoA MWF mario._check_common_action_exits.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario.prog mario._check_common_action_exits
             mario.f_check_common_action_exits nil nil nil sta_sids
             LO_mario sta_ccae_pin sta_ccae_vars sta_ccae_params_ok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sta_sids_rows.
    - exact sta_ccae_walk.
  Qed.

  (* ---- set_mario_animation ---- *)
  Lemma sta_sma_xids_rows : forall fid, mem_id fid sta_sma_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sta_sma_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_lpt | ].
    discriminate H.
  Qed.

  Lemma sta_sma_row :
    call_pres lp bm NoA MWF mario._set_mario_animation.
  Proof.
    apply (call_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario.prog mario._set_mario_animation
             mario.f_set_mario_animation
             nil nil sta_sma_cact sta_sma_xids nil
             LO_mario sta_sma_pin sta_sma_vars sta_sma_params_ok
             sta_sma_nonparam).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sta_sma_xids_rows.
    - intros fid' H. discriminate H.
    - exact sta_sma_walk.
  Qed.

  (* ---- the two sand/wind updaters (pure) ---- *)
  Lemma sta_mums_row :
    call_pres lp bm NoA MWF mario_step._mario_update_moving_sand.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_step.prog mario_step._mario_update_moving_sand
             mario_step.f_mario_update_moving_sand nil nil nil nil
             LO_mario_step sta_mums_pin sta_mums_vars sta_mums_params_ok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sta_mums_walk.
  Qed.

  Lemma sta_muwg_row :
    call_pres lp bm NoA MWF mario_step._mario_update_windy_ground.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_step.prog mario_step._mario_update_windy_ground
             mario_step.f_mario_update_windy_ground nil nil nil nil
             LO_mario_step sta_muwg_pin sta_muwg_vars sta_muwg_params_ok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sta_muwg_walk.
  Qed.

  (* ---- stationary_ground_step ---- *)
  Lemma sta_sgs_ids_rows : forall fid, mem_id fid sta_sgs_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sta_sgs_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid;
        exact (msfv_row lp LO_mario bm NoA MWF HNoA_of_MWF HMWF_window
                 HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
                 HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe) | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sta_mums_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sta_muwg_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_pgs | ].
    discriminate H.
  Qed.

  Lemma sta_sgs_xids_rows : forall fid, mem_id fid sta_sgs_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sta_sgs_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_v3f | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_v3s | ].
    discriminate H.
  Qed.

  Lemma sta_sgs_row :
    call_pres lp bm NoA MWF mario_step._stationary_ground_step.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_step.prog mario_step._stationary_ground_step
             mario_step.f_stationary_ground_step sta_sgs_ids nil sta_sgs_xids nil
             LO_mario_step sta_sgs_pin sta_sgs_vars sta_sgs_params_ok).
    - exact sta_sgs_ids_rows.
    - intros fid' H. discriminate H.
    - exact sta_sgs_xids_rows.
    - intros fid' H. discriminate H.
    - exact sta_sgs_walk.
  Qed.

  (* the leaf-callee helper census discharged by the rows above *)
  Lemma sta_leaf_ids_rows : forall fid, mem_id fid sta_leaf_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sta_leaf_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sta_ccae_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sta_ipae_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sta_sma_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sta_sgs_row | ].
    discriminate H.
  Qed.

  (* ================================================================== *)
  (* THE SLICE-1 LEAVES, PROVED.                                        *)
  (* ================================================================== *)

  Lemma act_standing_against_wall_pres :
    body_pres lp NoA MWF bm
      mario_actions_stationary.f_act_standing_against_wall.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_stationary.f_act_standing_against_wall
             sta_leaf_ids nil nil sta_sids nil
             sta_saw_vars sta_saw_params_ok).
    - exact sta_leaf_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sta_sids_rows.
    - intros fid' H. discriminate H.
    - exact sta_saw_walk.
  Qed.

  Lemma act_start_crawling_pres :
    body_pres lp NoA MWF bm
      mario_actions_stationary.f_act_start_crawling.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_stationary.f_act_start_crawling
             sta_leaf_ids nil nil sta_sids nil
             sta_ascr_vars sta_ascr_params_ok).
    - exact sta_leaf_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sta_sids_rows.
    - intros fid' H. discriminate H.
    - exact sta_ascr_walk.
  Qed.

  Lemma act_stop_crawling_pres :
    body_pres lp NoA MWF bm
      mario_actions_stationary.f_act_stop_crawling.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_stationary.f_act_stop_crawling
             sta_leaf_ids nil nil sta_sids nil
             sta_apcr_vars sta_apcr_params_ok).
    - exact sta_leaf_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sta_sids_rows.
    - intros fid' H. discriminate H.
    - exact sta_apcr_walk.
  Qed.

  (* act_shivering: the animation/particle leaf (m->actionState +
     m->particleFlags window stores, an actionState Sswitch, the
     chase-temp marioObj loads used only as play_sound's pos arg). *)
  Lemma sta_ashv_xids_rows : forall fid, mem_id fid sta_psound_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sta_psound_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_psound | ].
    discriminate H.
  Qed.

  Lemma act_shivering_pres :
    body_pres lp NoA MWF bm
      mario_actions_stationary.f_act_shivering.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_stationary.f_act_shivering
             sta_leaf_ids nil sta_psound_xids sta_sids nil
             sta_ashv_vars sta_ashv_params_ok).
    - exact sta_leaf_ids_rows.
    - intros fid' H. discriminate H.
    - exact sta_ashv_xids_rows.
    - exact sta_sids_rows.
    - intros fid' H. discriminate H.
    - exact sta_ashv_walk.
  Qed.

  (* ================================================================== *)
  (* THE REST-SPLIT: the capstone's Hpres_sta_callees from the walked   *)
  (* leaves + the shrinking sta_rest_ids residual.                      *)
  (* ================================================================== *)
  Lemma stationary_leaf_callees_pres :
    (forall fid f, mem_id fid sta_rest_ids = true ->
       (prog_defmap mario_actions_stationary.prog) ! fid
         = Some (Gfun (Internal f)) ->
       body_pres lp NoA MWF bm f) ->
    forall fid f, mem_id fid stationary_callee_ids = true ->
      (prog_defmap mario_actions_stationary.prog) ! fid
        = Some (Gfun (Internal f)) ->
      body_pres lp NoA MWF bm f.
  Proof.
    intros Hrest fid f H Hdm.
    unfold stationary_callee_ids in H. cbn [mem_id existsb] in H.
    (* 1: check_common_stationary_cancels -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 2: act_idle -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 3: act_start_sleeping -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 4: act_sleeping -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 5: act_waking_up -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 6: act_panting -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 7: act_hold_panting_unused -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 8: act_hold_idle -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 9: act_hold_heavy_idle -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 10: act_in_quicksand -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 11: act_standing_against_wall -- WALKED *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite sta_saw_pin in Hdm. injection Hdm as <-.
      exact act_standing_against_wall_pres. }
    (* 12: act_coughing -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 13: act_shivering -- WALKED *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite sta_ashv_pin in Hdm. injection Hdm as <-.
      exact act_shivering_pres. }
    (* 14: act_crouching -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 15: act_start_crouching -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 16: act_stop_crouching -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 17: act_start_crawling -- WALKED *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite sta_ascr_pin in Hdm. injection Hdm as <-.
      exact act_start_crawling_pres. }
    (* 18: act_stop_crawling -- WALKED *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite sta_apcr_pin in Hdm. injection Hdm as <-.
      exact act_stop_crawling_pres. }
    (* 19: act_slide_kick_slide_stop -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 20: act_shockwave_bounce -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 21: act_first_person -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 22: act_jump_land_stop -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 23: act_double_jump_land_stop -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 24: act_freefall_land_stop -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 25: act_side_flip_land_stop -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 26: act_hold_jump_land_stop -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 27: act_hold_freefall_land_stop -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 28: act_air_throw_land -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 29: act_lava_boost_land -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 30: act_twirl_land -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 31: act_triple_jump_land_stop -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 32: act_backflip_land_stop -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 33: act_long_jump_land_stop -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 34: act_ground_pound_land -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 35: act_braking_stop -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 36: act_butt_slide_stop -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 37: act_hold_butt_slide_stop -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    discriminate H.
  Qed.

End StationaryLeafRows.
