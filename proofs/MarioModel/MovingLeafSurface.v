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
  mario_actions_airborne mario_actions_moving
  mario_actions_object interaction.
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

(* SLICE M2: act_death_exit_land -- the ONE landing-family leaf that does
   NOT route through common_landing_cancels (the AGates-blocked FTJ gate).
   Its callees are all already-proven rows: apply_landing_accel (mov_ala_row)
   + set_mario_animation (mov_sma_row) + is_anim_at_end (mov_iae_row), audio
   (play_sound obj_ext + play_mario_{heavy_,}landing_sound mov_ext), and
   set_mario_action with an untainted const (205521409 = ACT_DEATH_EXIT_LAND;
   the engine's wact_const gate confirms non-flying). *)
Definition mov_del_ids : list ident :=
  mario_actions_moving._apply_landing_accel
    :: mario._set_mario_animation :: mario._is_anim_at_end :: nil.
Definition mov_del_xids : list ident :=
  mario._play_sound
    :: mario_actions_moving._play_mario_heavy_landing_sound_once
    :: mario_actions_moving._play_mario_landing_sound :: nil.

(* SLICE M3: act_finish_turning_around -- the FIRST walking-cluster leaf.
   KEY: set_jumping_action is call_pres_act (it threads its _action arg to
   set_mario_action), NOT a param-action blocker -- so the leaf supplies an
   untainted const and set_jumping_action sits in the sids channel.  The
   set_jumping_action arc (mario_floor_is_steep -> mario_facing_downhill +
   mario_get_floor_class; set_steep_jump_action -> sqrtf/atan2s + drop_and_set
   _mario_action) is replicated from StationaryLeafSurface's sta_sja arc.
   update_walking_speed = window stores + approach_s32(ext) + apply_slope_accel.
   The leaf's one store is a NON-ptr chase store marioObj->header.gfx.angle[i]
   (cact=[_t'5] absorbs it). *)
Definition mov_mfist_ids : list ident :=
  mario._mario_facing_downhill :: mario._mario_get_floor_class :: nil.
Definition mov_sssja_cact : list ident := mario._t'10 :: nil.
Definition mov_sssja_xids : list ident :=
  mario._sqrtf :: mario._atan2s :: nil.
Definition mov_sssja_sids : list ident :=
  mario._drop_and_set_mario_action :: nil.
Definition mov_sja_ids : list ident :=
  mario._mario_floor_is_steep :: mario._set_steep_jump_action :: nil.
Definition mov_uws_ids : list ident :=
  mario_actions_moving._apply_slope_accel :: nil.
Definition mov_uws_xids : list ident :=
  mario_actions_object._approach_s32 :: nil.
Definition mov_ftn_ids : list ident :=
  mario_actions_moving._update_walking_speed :: mario._set_mario_animation
    :: mario._is_anim_at_end :: mario_step._perform_ground_step :: nil.
Definition mov_ftn_cact : list ident := mario_actions_moving._t'5 :: nil.
Definition mov_ftn_sids : list ident :=
  mario._set_mario_action :: mario._set_jumping_action :: nil.

(* SLICE M4: check_common_moving_cancels -- the moving dispatcher's common
   cancel gate (callee #1).  0 stores; calls drop_and_set_mario_action (sids ->
   Hdasma) + set_water_plunge_action (sets ACT_WATER_PLUNGE, untainted; window
   stores + set_camera_mode/vec3s_set externals, BOTH in obj_ext_ids).  REUSES
   the StationaryLeafSurface SLICE-16 set_water_plunge_action recipe verbatim. *)
Definition mov_swpa_xids : list ident :=
  mario._set_camera_mode :: mario._vec3s_set :: nil.
Definition mov_ccmc_ids : list ident :=
  mario._set_water_plunge_action :: nil.
Definition mov_ccmc_sids : list ident :=
  mario._drop_and_set_mario_action :: nil.

(* SLICE M5: act_hold_walking + the SHARED walk/decel anim-audio subtree.
   anim_and_audio_for_hold_walk calls set_mario_anim_with_accel (the np3
   class: 3rd arg val0C = (s32)(speed*0x10000), a float-cast non-Vptr) inside
   a while/switch loop -- walked via the NEW call_pres_of_wwalk_nids producer
   (nids=[val0C], np3_ids=[smawa]).  smawa's np3 row reuses ActWriterSurface's
   call_pres_np3_of_wwalk (cact=[_o;_t'14;_t'13;_targetAnim], xids=[load_
   patchable_table]).  The anim/audio helpers (smawa / is_anim_past_frame /
   play_sound_and_spawn_particles / play_step_sound) are SHARED infrastructure
   -- reused by hold_heavy_walking / burning_ground / hold_decelerating. *)
Definition mov_smawa_cact : list ident :=
  mario._o :: mario._t'14 :: mario._t'13 :: mario._targetAnim :: nil.
Definition mov_smawa_xids : list ident := mario._load_patchable_table :: nil.
Definition mov_pssp_xids : list ident := mario._play_sound :: nil.
Definition mov_pss_ids : list ident :=
  mario._is_anim_past_frame :: mario._play_sound_and_spawn_particles :: nil.
Definition mov_aahw_ids : list ident :=
  mario_actions_moving._play_step_sound :: nil.
Definition mov_aahw_nids : list ident := mario_actions_moving._val0C :: nil.
Definition mov_aahw_np3 : list ident := mario._set_mario_anim_with_accel :: nil.
Definition mov_sbs_ids : list ident := mario._mario_facing_downhill :: nil.
Definition mov_ahw_ids : list ident :=
  mario_actions_moving._anim_and_audio_for_hold_walk
    :: mario._mario_set_forward_vel
    :: mario_step._perform_ground_step
    :: mario_actions_moving._should_begin_sliding
    :: mario_actions_moving._update_walking_speed :: nil.
Definition mov_ahw_xids : list ident := interaction._segmented_to_virtual :: nil.
Definition mov_ahw_sids : list ident :=
  mario._set_mario_action :: mario._set_jumping_action
    :: mario._drop_and_set_mario_action :: nil.

(* the walked leaves (this slice) and the shrinking rest *)
Definition mov_walked_ids : list ident :=
  mario_actions_moving._check_common_moving_cancels
    :: mario_actions_moving._act_hold_walking
    :: mario_actions_moving._act_backward_ground_kb
    :: mario_actions_moving._act_forward_ground_kb
    :: mario_actions_moving._act_soft_backward_ground_kb
    :: mario_actions_moving._act_soft_forward_ground_kb
    :: mario_actions_moving._act_hard_backward_ground_kb
    :: mario_actions_moving._act_hard_forward_ground_kb
    :: mario_actions_moving._act_ground_bonk
    :: mario_actions_moving._act_death_exit_land
    :: mario_actions_moving._act_finish_turning_around :: nil.
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

(* ---- SLICE M2: act_death_exit_land ---- *)
Example mov_del_pin :
  (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._act_death_exit_land
  = Some (Gfun (Internal mario_actions_moving.f_act_death_exit_land)).
Proof. vm_compute. reflexivity. Qed.
Example mov_del_vars : fn_vars mario_actions_moving.f_act_death_exit_land = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_del_pok : mov_pok mario_actions_moving.f_act_death_exit_land = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_del_walk :
  wwalk_chk false nil mov_del_ids nil nil mov_del_xids
    (mario._set_mario_action :: nil) nil
    (fn_body mario_actions_moving.f_act_death_exit_land) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- SLICE M3 pins ---- *)
Example mov_mfist_pin :
  (prog_defmap mario.prog) ! mario._mario_floor_is_steep
  = Some (Gfun (Internal mario.f_mario_floor_is_steep)).
Proof. vm_compute. reflexivity. Qed.
Example mov_mfist_vars : fn_vars mario.f_mario_floor_is_steep = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_mfist_pok : mov_pok mario.f_mario_floor_is_steep = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_mfist_walk :
  wwalk_chk false nil mov_mfist_ids nil nil nil nil nil
    (fn_body mario.f_mario_floor_is_steep) = true.
Proof. vm_compute. reflexivity. Qed.

Example mov_sssja_pin :
  (prog_defmap mario.prog) ! mario._set_steep_jump_action
  = Some (Gfun (Internal mario.f_set_steep_jump_action)).
Proof. vm_compute. reflexivity. Qed.
Example mov_sssja_vars : fn_vars mario.f_set_steep_jump_action = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_sssja_pok : mov_pok mario.f_set_steep_jump_action = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_sssja_nonparam :
  forallb (fun t' => negb (mem_id t' (map fst (fn_params mario.f_set_steep_jump_action))))
    mov_sssja_cact = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_sssja_walk :
  wwalk_chk false nil nil nil mov_sssja_cact mov_sssja_xids mov_sssja_sids nil
    (fn_body mario.f_set_steep_jump_action) = true.
Proof. vm_compute. reflexivity. Qed.

Example mov_sja_pin :
  (prog_defmap mario.prog) ! mario._set_jumping_action
  = Some (Gfun (Internal mario.f_set_jumping_action)).
Proof. vm_compute. reflexivity. Qed.
Example mov_sja_vars : fn_vars mario.f_set_jumping_action = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_sja_params : fn_params mario.f_set_jumping_action = writer_params.
Proof. vm_compute. reflexivity. Qed.
Example mov_sja_ret : i32_ty (fn_return mario.f_set_jumping_action) = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_sja_walk :
  wwalk_chk true
    (mario._action :: mario._t'1 :: mario._t'2 :: nil)
    mov_sja_ids mov_sids nil nil mov_sids nil
    (fn_body mario.f_set_jumping_action) = true.
Proof. vm_compute. reflexivity. Qed.

Example mov_uws_pin :
  (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._update_walking_speed
  = Some (Gfun (Internal mario_actions_moving.f_update_walking_speed)).
Proof. vm_compute. reflexivity. Qed.
Example mov_uws_vars : fn_vars mario_actions_moving.f_update_walking_speed = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_uws_pok : mov_pok mario_actions_moving.f_update_walking_speed = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_uws_walk :
  wwalk_chk false nil mov_uws_ids nil nil mov_uws_xids nil nil
    (fn_body mario_actions_moving.f_update_walking_speed) = true.
Proof. vm_compute. reflexivity. Qed.

Example mov_ftn_pin :
  (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._act_finish_turning_around
  = Some (Gfun (Internal mario_actions_moving.f_act_finish_turning_around)).
Proof. vm_compute. reflexivity. Qed.
Example mov_ftn_vars : fn_vars mario_actions_moving.f_act_finish_turning_around = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_ftn_pok : mov_pok mario_actions_moving.f_act_finish_turning_around = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_ftn_nonparam :
  forallb (fun t' => negb (mem_id t' (map fst (fn_params mario_actions_moving.f_act_finish_turning_around))))
    mov_ftn_cact = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_ftn_walk :
  wwalk_chk false nil mov_ftn_ids nil mov_ftn_cact nil mov_ftn_sids nil
    (fn_body mario_actions_moving.f_act_finish_turning_around) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- SLICE M4 pins ---- *)
Example mov_swpa_pin :
  (prog_defmap mario.prog) ! mario._set_water_plunge_action
  = Some (Gfun (Internal mario.f_set_water_plunge_action)).
Proof. vm_compute. reflexivity. Qed.
Example mov_swpa_vars : fn_vars mario.f_set_water_plunge_action = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_swpa_pok : mov_pok mario.f_set_water_plunge_action = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_swpa_walk :
  wwalk_chk false nil nil nil nil mov_swpa_xids mov_sids nil
    (fn_body mario.f_set_water_plunge_action) = true.
Proof. vm_compute. reflexivity. Qed.

Example mov_ccmc_pin :
  (prog_defmap mario_actions_moving.prog)
    ! mario_actions_moving._check_common_moving_cancels
  = Some (Gfun (Internal mario_actions_moving.f_check_common_moving_cancels)).
Proof. vm_compute. reflexivity. Qed.
Example mov_ccmc_vars :
  fn_vars mario_actions_moving.f_check_common_moving_cancels = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_ccmc_pok :
  mov_pok mario_actions_moving.f_check_common_moving_cancels = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_ccmc_walk :
  wwalk_chk false nil mov_ccmc_ids nil nil nil mov_ccmc_sids nil
    (fn_body mario_actions_moving.f_check_common_moving_cancels) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- SLICE M5 pins ---- *)
(* set_mario_anim_with_accel: the np3 leaf (reuses call_pres_np3_of_wwalk) *)
Example mov_smawa_pin :
  (prog_defmap mario.prog) ! mario._set_mario_anim_with_accel
  = Some (Gfun (Internal mario.f_set_mario_anim_with_accel)).
Proof. vm_compute. reflexivity. Qed.
Example mov_smawa_vars : fn_vars mario.f_set_mario_anim_with_accel = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_smawa_params : fn_params mario.f_set_mario_anim_with_accel = np3_params.
Proof. vm_compute. reflexivity. Qed.
Example mov_smawa_cm : mem_id mario_actions_airborne._m mov_smawa_cact = false.
Proof. vm_compute. reflexivity. Qed.
Example mov_smawa_canim : mem_id mario._targetAnimID mov_smawa_cact = false.
Proof. vm_compute. reflexivity. Qed.
Example mov_smawa_cacc : mem_id mario._accel mov_smawa_cact = false.
Proof. vm_compute. reflexivity. Qed.
Example mov_smawa_walk :
  wwalk_chk' nil nil nil nil (mario._accel :: nil) nil false
    nil nil nil mov_smawa_cact mov_smawa_xids nil nil
    (fn_body mario.f_set_mario_anim_with_accel) = true.
Proof. vm_compute. reflexivity. Qed.

(* is_anim_past_frame: pure read-only (no callees, no stores) *)
Example mov_iapf_pin :
  (prog_defmap mario.prog) ! mario._is_anim_past_frame
  = Some (Gfun (Internal mario.f_is_anim_past_frame)).
Proof. vm_compute. reflexivity. Qed.
Example mov_iapf_vars : fn_vars mario.f_is_anim_past_frame = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_iapf_pok : mov_pok mario.f_is_anim_past_frame = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_iapf_walk :
  wwalk_chk false nil nil nil nil nil nil nil
    (fn_body mario.f_is_anim_past_frame) = true.
Proof. vm_compute. reflexivity. Qed.

(* play_sound_and_spawn_particles: window stores + play_sound external *)
Example mov_pssp_pin :
  (prog_defmap mario.prog) ! mario._play_sound_and_spawn_particles
  = Some (Gfun (Internal mario.f_play_sound_and_spawn_particles)).
Proof. vm_compute. reflexivity. Qed.
Example mov_pssp_vars : fn_vars mario.f_play_sound_and_spawn_particles = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_pssp_pok : mov_pok mario.f_play_sound_and_spawn_particles = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_pssp_walk :
  wwalk_chk false nil nil nil nil mov_pssp_xids nil nil
    (fn_body mario.f_play_sound_and_spawn_particles) = true.
Proof. vm_compute. reflexivity. Qed.

(* play_step_sound: is_anim_past_frame + play_sound_and_spawn_particles + play_sound *)
Example mov_pss_pin :
  (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._play_step_sound
  = Some (Gfun (Internal mario_actions_moving.f_play_step_sound)).
Proof. vm_compute. reflexivity. Qed.
Example mov_pss_vars : fn_vars mario_actions_moving.f_play_step_sound = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_pss_pok : mov_pok mario_actions_moving.f_play_step_sound = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_pss_walk :
  wwalk_chk false nil mov_pss_ids nil nil mov_pssp_xids nil nil
    (fn_body mario_actions_moving.f_play_step_sound) = true.
Proof. vm_compute. reflexivity. Qed.

(* anim_and_audio_for_hold_walk: the np3 caller (loop+switch; nids=[val0C]) *)
Example mov_aahw_pin :
  (prog_defmap mario_actions_moving.prog)
    ! mario_actions_moving._anim_and_audio_for_hold_walk
  = Some (Gfun (Internal mario_actions_moving.f_anim_and_audio_for_hold_walk)).
Proof. vm_compute. reflexivity. Qed.
Example mov_aahw_vars :
  fn_vars mario_actions_moving.f_anim_and_audio_for_hold_walk = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_aahw_pok :
  mov_pok mario_actions_moving.f_anim_and_audio_for_hold_walk = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_aahw_nonparam_n :
  forallb (fun t' => negb (mem_id t'
    (map fst (fn_params mario_actions_moving.f_anim_and_audio_for_hold_walk))))
    mov_aahw_nids = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_aahw_walk :
  wwalk_chk' nil nil nil nil mov_aahw_nids mov_aahw_np3 false
    nil mov_aahw_ids nil nil nil nil nil
    (fn_body mario_actions_moving.f_anim_and_audio_for_hold_walk) = true.
Proof. vm_compute. reflexivity. Qed.

(* should_begin_sliding: mario_facing_downhill (read-only) *)
Example mov_sbs_pin :
  (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._should_begin_sliding
  = Some (Gfun (Internal mario_actions_moving.f_should_begin_sliding)).
Proof. vm_compute. reflexivity. Qed.
Example mov_sbs_vars : fn_vars mario_actions_moving.f_should_begin_sliding = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_sbs_pok : mov_pok mario_actions_moving.f_should_begin_sliding = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_sbs_walk :
  wwalk_chk false nil mov_sbs_ids nil nil nil nil nil
    (fn_body mario_actions_moving.f_should_begin_sliding) = true.
Proof. vm_compute. reflexivity. Qed.

(* the leaf: act_hold_walking *)
Example mov_ahw_pin :
  (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._act_hold_walking
  = Some (Gfun (Internal mario_actions_moving.f_act_hold_walking)).
Proof. vm_compute. reflexivity. Qed.
Example mov_ahw_vars : fn_vars mario_actions_moving.f_act_hold_walking = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_ahw_pok : mov_pok mario_actions_moving.f_act_hold_walking = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_ahw_walk :
  wwalk_chk false nil mov_ahw_ids nil nil mov_ahw_xids mov_ahw_sids nil
    (fn_body mario_actions_moving.f_act_hold_walking) = true.
Proof. vm_compute. reflexivity. Qed.

(* ====================================================================== *)
(* The rows + the rest-split (one section, the full 12-hyp MWF kit).      *)
(* ====================================================================== *)

Section MovingLeafRows.
  Variable lp : Clight.program.
  Hypothesis LO_mario : linkorder mario.prog lp.
  Hypothesis LO_mario_step : linkorder mario_step.prog lp.
  Hypothesis LO_mov : linkorder mario_actions_moving.prog lp.
  (* SLICE M3: the interaction TU linkorder (dasma's drop-held-object subtree
     reaches interaction helpers); supplied by the capstone (it already pins
     interaction.prog as part of the linked program lp). *)
  Hypothesis LO_int : linkorder interaction.prog lp.

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
  (* SLICE M3: the obj_ext boundary (atan2s + approach_s32 + the dasma trio
     segmented_to_virtual / stop_shell_music / obj_set_held_state).  ALL in
     obj_ext_ids; the capstone supplies its own Hpres_obj_ext verbatim. *)
  Hypothesis Hpres_obj_ext : forall fid,
      mem_id fid obj_ext_ids = true -> call_pres_ext lp bm NoA MWF fid.

  (* the set_mario_action keystone, instantiated once *)
  Let Hsmact : call_pres_act lp bm NoA MWF mario._set_mario_action :=
    smact_pres lp LO_mario LO_mario_step bm NoA MWF HNoA_of_MWF
      HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
      HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe.

  (* SLICE M3: drop_and_set_mario_action -- REUSED from ObjectLeafSurface
     .dasma_row (the dasma trio externals routed through Hpres_obj_ext). *)
  Let Hdasma : call_pres_act lp bm NoA MWF mario._drop_and_set_mario_action :=
    dasma_row lp LO_mario LO_mario_step LO_int bm NoA MWF HNoA_of_MWF
      HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
      HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
      (Hpres_obj_ext interaction._segmented_to_virtual eq_refl)
      (Hpres_obj_ext interaction._stop_shell_music eq_refl)
      (Hpres_obj_ext interaction._obj_set_held_state eq_refl).

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

  (* ---- SLICE M2: act_death_exit_land (body_pres) ---- *)
  Lemma mov_del_ids_rows : forall fid, mem_id fid mov_del_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_del_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_ala_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_sma_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_iae_row | ].
    discriminate H.
  Qed.

  Lemma mov_del_xids_rows : forall fid, mem_id fid mov_del_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_del_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_psound | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid;
        apply Hpres_mov_ext; vm_compute; reflexivity | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid;
        apply Hpres_mov_ext; vm_compute; reflexivity | ].
    discriminate H.
  Qed.

  Lemma mov_del_pres :
    body_pres lp NoA MWF bm mario_actions_moving.f_act_death_exit_land.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_moving.f_act_death_exit_land
             mov_del_ids nil mov_del_xids mov_sids nil
             mov_del_vars mov_del_pok).
    - exact mov_del_ids_rows.
    - intros fid' H. discriminate H.
    - exact mov_del_xids_rows.
    - exact mov_sids_rows.
    - intros fid' H. discriminate H.
    - exact mov_del_walk.
  Qed.

  (* ================================================================== *)
  (* SLICE M3: the set_jumping_action arc + act_finish_turning_around.  *)
  (* ================================================================== *)

  (* mario_floor_is_steep: mario_facing_downhill + mario_get_floor_class
     (the two generic ActWriterSurface rows). *)
  Lemma mov_mfist_ids_rows : forall fid, mem_id fid mov_mfist_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_mfist_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid;
        exact (mfd_row lp LO_mario bm NoA MWF HNoA_of_MWF HMWF_window
                 HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot HMWF_chase
                 HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe) | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_mgfc_row | ].
    discriminate H.
  Qed.

  Lemma mov_mfist_row : call_pres lp bm NoA MWF mario._mario_floor_is_steep.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario.prog mario._mario_floor_is_steep mario.f_mario_floor_is_steep
             mov_mfist_ids nil nil nil
             LO_mario mov_mfist_pin mov_mfist_vars mov_mfist_pok).
    - exact mov_mfist_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact mov_mfist_walk.
  Qed.

  (* set_steep_jump_action: marioObj chase store (cact=[_t'10]) + sqrtf/atan2s
     + drop_and_set_mario_action (Hdasma). *)
  Lemma mov_sssja_xids_rows : forall fid, mem_id fid mov_sssja_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_sssja_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_sqrtf | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid;
        exact (Hpres_obj_ext mario._atan2s eq_refl) | ].
    discriminate H.
  Qed.

  Lemma mov_sssja_sids_rows : forall fid, mem_id fid mov_sssja_sids = true ->
      call_pres_act lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_sssja_sids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hdasma | ].
    discriminate H.
  Qed.

  Lemma mov_sssja_row : call_pres lp bm NoA MWF mario._set_steep_jump_action.
  Proof.
    apply (call_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario.prog mario._set_steep_jump_action mario.f_set_steep_jump_action
             nil nil mov_sssja_cact mov_sssja_xids mov_sssja_sids
             LO_mario mov_sssja_pin mov_sssja_vars mov_sssja_pok mov_sssja_nonparam).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact mov_sssja_xids_rows.
    - exact mov_sssja_sids_rows.
    - exact mov_sssja_walk.
  Qed.

  (* set_jumping_action: call_pres_act (threads _action to set_mario_action). *)
  Lemma mov_sja_ids_rows : forall fid, mem_id fid mov_sja_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_sja_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_mfist_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_sssja_row | ].
    discriminate H.
  Qed.

  Lemma mov_sja_row : call_pres_act lp bm NoA MWF mario._set_jumping_action.
  Proof.
    apply (call_pres_act_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario.prog mario._set_jumping_action mario.f_set_jumping_action
             (mario._action :: mario._t'1 :: mario._t'2 :: nil)
             mov_sja_ids mov_sids nil nil mov_sids
             LO_mario mov_sja_pin mov_sja_vars mov_sja_params mov_sja_ret
             eq_refl eq_refl eq_refl eq_refl eq_refl eq_refl).
    - exact mov_sja_ids_rows.
    - exact mov_sids_rows.
    - intros fid' H. discriminate H.
    - exact mov_sids_rows.
    - exact mov_sja_walk.
  Qed.

  (* update_walking_speed: apply_slope_accel + approach_s32(ext) + window. *)
  Lemma mov_uws_ids_rows : forall fid, mem_id fid mov_uws_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_uws_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_asa_row | ].
    discriminate H.
  Qed.

  Lemma mov_uws_xids_rows : forall fid, mem_id fid mov_uws_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_uws_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid;
        exact (Hpres_obj_ext mario_actions_object._approach_s32 eq_refl) | ].
    discriminate H.
  Qed.

  Lemma mov_uws_row : call_pres lp bm NoA MWF mario_actions_moving._update_walking_speed.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_moving.prog mario_actions_moving._update_walking_speed
             mario_actions_moving.f_update_walking_speed
             mov_uws_ids nil mov_uws_xids nil
             LO_mov mov_uws_pin mov_uws_vars mov_uws_pok).
    - exact mov_uws_ids_rows.
    - intros fid' H. discriminate H.
    - exact mov_uws_xids_rows.
    - intros fid' H. discriminate H.
    - exact mov_uws_walk.
  Qed.

  (* the leaf: ids + the marioObj non-ptr chase store (cact=[_t'5]) +
     sids = set_mario_action + set_jumping_action. *)
  Lemma mov_ftn_ids_rows : forall fid, mem_id fid mov_ftn_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_ftn_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_uws_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_sma_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_iae_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_pgs | ].
    discriminate H.
  Qed.

  Lemma mov_ftn_sids_rows : forall fid, mem_id fid mov_ftn_sids = true ->
      call_pres_act lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_ftn_sids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsmact | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_sja_row | ].
    discriminate H.
  Qed.

  Lemma mov_ftn_pres :
    body_pres lp NoA MWF bm mario_actions_moving.f_act_finish_turning_around.
  Proof.
    apply (body_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_moving.f_act_finish_turning_around
             mov_ftn_ids nil mov_ftn_cact nil mov_ftn_sids nil
             mov_ftn_vars mov_ftn_pok mov_ftn_nonparam).
    - exact mov_ftn_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact mov_ftn_sids_rows.
    - intros fid' H. discriminate H.
    - exact mov_ftn_walk.
  Qed.

  (* ---- SLICE M4: check_common_moving_cancels (the common cancel gate) ---- *)
  Lemma mov_swpa_xids_rows : forall fid, mem_id fid mov_swpa_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_swpa_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid;
        exact (Hpres_obj_ext mario._set_camera_mode eq_refl) | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid;
        exact (Hpres_obj_ext mario._vec3s_set eq_refl) | ].
    discriminate H.
  Qed.

  Lemma mov_swpa_row : call_pres lp bm NoA MWF mario._set_water_plunge_action.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario.prog mario._set_water_plunge_action mario.f_set_water_plunge_action
             nil nil mov_swpa_xids mov_sids
             LO_mario mov_swpa_pin mov_swpa_vars mov_swpa_pok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact mov_swpa_xids_rows.
    - exact mov_sids_rows.
    - exact mov_swpa_walk.
  Qed.

  Lemma mov_ccmc_ids_rows : forall fid, mem_id fid mov_ccmc_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_ccmc_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_swpa_row | ].
    discriminate H.
  Qed.

  Lemma mov_ccmc_sids_rows : forall fid, mem_id fid mov_ccmc_sids = true ->
      call_pres_act lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_ccmc_sids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hdasma | ].
    discriminate H.
  Qed.

  Lemma mov_ccmc_pres :
    body_pres lp NoA MWF bm mario_actions_moving.f_check_common_moving_cancels.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_moving.f_check_common_moving_cancels
             mov_ccmc_ids nil nil mov_ccmc_sids nil mov_ccmc_vars mov_ccmc_pok).
    - exact mov_ccmc_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact mov_ccmc_sids_rows.
    - intros fid' H. discriminate H.
    - exact mov_ccmc_walk.
  Qed.

  (* ---- SLICE M5: act_hold_walking + the shared anim/audio np3 subtree ---- *)
  (* set_mario_anim_with_accel: the np3 leaf (val0C 3rd arg = float-cast). *)
  Lemma mov_smawa_xids_rows : forall fid, mem_id fid mov_smawa_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_smawa_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_lpt | ].
    discriminate H.
  Qed.

  Lemma mov_smawa_row :
    call_pres_np3 lp bm NoA MWF mario._set_mario_anim_with_accel.
  Proof.
    apply (call_pres_np3_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario.prog mario._set_mario_anim_with_accel
             mario.f_set_mario_anim_with_accel
             nil nil mov_smawa_cact mov_smawa_xids nil
             LO_mario mov_smawa_pin mov_smawa_vars mov_smawa_params
             mov_smawa_cm mov_smawa_canim mov_smawa_cacc).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact mov_smawa_xids_rows.
    - intros fid' H. discriminate H.
    - exact mov_smawa_walk.
  Qed.

  (* play_sound_and_spawn_particles: window stores + play_sound external. *)
  Lemma mov_pssp_xids_rows : forall fid, mem_id fid mov_pssp_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_pssp_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_psound | ].
    discriminate H.
  Qed.

  Lemma mov_pssp_row :
    call_pres lp bm NoA MWF mario._play_sound_and_spawn_particles.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario.prog mario._play_sound_and_spawn_particles
             mario.f_play_sound_and_spawn_particles
             nil nil mov_pssp_xids nil
             LO_mario mov_pssp_pin mov_pssp_vars mov_pssp_pok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact mov_pssp_xids_rows.
    - intros fid' H. discriminate H.
    - exact mov_pssp_walk.
  Qed.

  Lemma mov_iapf_row : call_pres lp bm NoA MWF mario._is_anim_past_frame.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario.prog mario._is_anim_past_frame mario.f_is_anim_past_frame
             nil nil nil nil LO_mario mov_iapf_pin mov_iapf_vars mov_iapf_pok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact mov_iapf_walk.
  Qed.

  (* play_step_sound: is_anim_past_frame + play_sound_and_spawn_particles + play_sound. *)
  Lemma mov_pss_ids_rows : forall fid, mem_id fid mov_pss_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_pss_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_iapf_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_pssp_row | ].
    discriminate H.
  Qed.

  Lemma mov_pss_row :
    call_pres lp bm NoA MWF mario_actions_moving._play_step_sound.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_moving.prog mario_actions_moving._play_step_sound
             mario_actions_moving.f_play_step_sound
             mov_pss_ids nil mov_pssp_xids nil
             LO_mov mov_pss_pin mov_pss_vars mov_pss_pok).
    - exact mov_pss_ids_rows.
    - intros fid' H. discriminate H.
    - exact mov_pssp_xids_rows.
    - intros fid' H. discriminate H.
    - exact mov_pss_walk.
  Qed.

  (* should_begin_sliding: mario_facing_downhill (read-only). *)
  Lemma mov_sbs_ids_rows : forall fid, mem_id fid mov_sbs_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_sbs_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid;
        exact (mfd_row lp LO_mario bm NoA MWF HNoA_of_MWF HMWF_window
                 HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot HMWF_chase
                 HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe) | ].
    discriminate H.
  Qed.

  Lemma mov_sbs_row :
    call_pres lp bm NoA MWF mario_actions_moving._should_begin_sliding.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_moving.prog mario_actions_moving._should_begin_sliding
             mario_actions_moving.f_should_begin_sliding
             mov_sbs_ids nil nil nil
             LO_mov mov_sbs_pin mov_sbs_vars mov_sbs_pok).
    - exact mov_sbs_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact mov_sbs_walk.
  Qed.

  (* anim_and_audio_for_hold_walk: the np3 caller via call_pres_of_wwalk_nids. *)
  Lemma mov_aahw_ids_rows : forall fid, mem_id fid mov_aahw_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_aahw_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_pss_row | ].
    discriminate H.
  Qed.

  Lemma mov_aahw_np3_rows : forall fid, mem_id fid mov_aahw_np3 = true ->
      call_pres_np3 lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_aahw_np3 in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_smawa_row | ].
    discriminate H.
  Qed.

  Lemma mov_aahw_row :
    call_pres lp bm NoA MWF mario_actions_moving._anim_and_audio_for_hold_walk.
  Proof.
    apply (call_pres_of_wwalk_nids lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_moving.prog
             mario_actions_moving._anim_and_audio_for_hold_walk
             mario_actions_moving.f_anim_and_audio_for_hold_walk
             mov_aahw_ids nil nil nil nil nil mov_aahw_nids mov_aahw_np3
             LO_mov mov_aahw_pin mov_aahw_vars mov_aahw_pok
             eq_refl mov_aahw_nonparam_n).
    - exact mov_aahw_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact mov_aahw_np3_rows.
    - exact mov_aahw_walk.
  Qed.

  (* the leaf: act_hold_walking. *)
  Lemma mov_ahw_ids_rows : forall fid, mem_id fid mov_ahw_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_ahw_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_aahw_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_msfv_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_pgs | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_sbs_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_uws_row | ].
    discriminate H.
  Qed.

  Lemma mov_ahw_xids_rows : forall fid, mem_id fid mov_ahw_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_ahw_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid;
        exact (Hpres_obj_ext interaction._segmented_to_virtual eq_refl) | ].
    discriminate H.
  Qed.

  Lemma mov_ahw_sids_rows : forall fid, mem_id fid mov_ahw_sids = true ->
      call_pres_act lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_ahw_sids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsmact | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_sja_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hdasma | ].
    discriminate H.
  Qed.

  Lemma mov_ahw_pres :
    body_pres lp NoA MWF bm mario_actions_moving.f_act_hold_walking.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_moving.f_act_hold_walking
             mov_ahw_ids nil mov_ahw_xids mov_ahw_sids nil
             mov_ahw_vars mov_ahw_pok).
    - exact mov_ahw_ids_rows.
    - intros fid' H. discriminate H.
    - exact mov_ahw_xids_rows.
    - exact mov_ahw_sids_rows.
    - intros fid' H. discriminate H.
    - exact mov_ahw_walk.
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
    (* 1: check_common_moving_cancels -- WALKED *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite mov_ccmc_pin in Hdm. injection Hdm as <-. exact mov_ccmc_pres. }
    (* 2: act_walking -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 3: act_hold_walking -- WALKED *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite mov_ahw_pin in Hdm. injection Hdm as <-. exact mov_ahw_pres. }
    (* 4: act_hold_heavy_walking -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 5: act_turning_around -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 6: act_finish_turning_around -- WALKED *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite mov_ftn_pin in Hdm. injection Hdm as <-. exact mov_ftn_pres. }
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
    (* 28: act_death_exit_land -- WALKED *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite mov_del_pin in Hdm. injection Hdm as <-. exact mov_del_pres. }
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
