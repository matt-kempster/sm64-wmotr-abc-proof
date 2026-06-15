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
From SM64.Proofs Require Import MWFReal LandingBricks.

Import ListNotations.

(* alias + MarioState* notation for the landing-keystone leaf machinery *)
Module M := mario_actions_moving.
Local Notation tyMSp := (tptr (Tstruct M._MarioState noattr)).

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
    :: mario_actions_moving._play_mario_landing_sound
    (* the float `approach` math builtin: EF_external in every TU, 4
       tfloat args, no Mario pointer -- the SAME honest pure-math model
       boundary as approach_s32 / sqrtf / atan2s. *)
    :: mario_actions_moving._approach_f32 :: nil.

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

(* SLICE M6: act_hold_heavy_walking -- the heavy-object twin of M5.  REUSES
   the whole anim/audio np3 subtree; its only new helper is anim_and_audio_
   for_heavy_walk (no loop; nids=[val04], np3_ids=[smawa], ids=[play_step_
   sound]).  The leaf has no segmented_to_virtual / set_jumping_action. *)
Definition mov_aahh_nids : list ident := mario_actions_moving._val04 :: nil.
Definition mov_ahhw_ids : list ident :=
  mario_actions_moving._anim_and_audio_for_heavy_walk
    :: mario._mario_set_forward_vel
    :: mario_step._perform_ground_step
    :: mario_actions_moving._should_begin_sliding
    :: mario_actions_moving._update_walking_speed :: nil.
Definition mov_ahhw_sids : list ident :=
  mario._set_mario_action :: mario._drop_and_set_mario_action :: nil.

(* the walked leaves (this slice) and the shrinking rest *)
Definition mov_walked_ids : list ident :=
  mario_actions_moving._check_common_moving_cancels
    :: mario_actions_moving._act_hold_walking
    :: mario_actions_moving._act_hold_heavy_walking
    :: mario_actions_moving._act_backward_ground_kb
    :: mario_actions_moving._act_forward_ground_kb
    :: mario_actions_moving._act_soft_backward_ground_kb
    :: mario_actions_moving._act_soft_forward_ground_kb
    :: mario_actions_moving._act_hard_backward_ground_kb
    :: mario_actions_moving._act_hard_forward_ground_kb
    :: mario_actions_moving._act_ground_bonk
    :: mario_actions_moving._act_death_exit_land
    :: mario_actions_moving._act_finish_turning_around
    :: mario_actions_moving._act_slide_kick_slide
    :: mario_actions_moving._act_hold_decelerating
    :: mario_actions_moving._act_turning_around
    (* LANDING KEYSTONE: the 3 clean common_landing_cancels leaves *)
    :: mario_actions_moving._act_jump_land
    :: mario_actions_moving._act_freefall_land
    :: mario_actions_moving._act_double_jump_land
    (* LANDING KEYSTONE part 2: the HOLD leaves (leading drop-object block) *)
    :: mario_actions_moving._act_hold_jump_land
    :: mario_actions_moving._act_hold_freefall_land
    (* LANDING KEYSTONE part 3: the INPUT-STORE leaves (input clear + sound) *)
    :: mario_actions_moving._act_triple_jump_land
    :: mario_actions_moving._act_backflip_land
    :: mario_actions_moving._act_long_jump_land :: nil.
Definition mov_rest_ids : list ident :=
  filter (fun id => negb (mem_id id mov_walked_ids)) moving_callee_ids.

(* ---------------------------------------------------------------------- *)
(* SLICE M7: the slide helper subtree + act_slide_kick_slide.             *)
(* mario_bonk_reflection / update_sliding / update_sliding_angle are all  *)
(* clean window-store-only helpers (no np3, no param-action, no AGates).  *)
(* ---------------------------------------------------------------------- *)

(* mario_bonk_reflection (mario_step.prog): faceAngle[1] window store +
   atan2s/play_sound ext + mario_set_forward_vel. *)
Definition mov_mbr_ids : list ident := mario._mario_set_forward_vel :: nil.
Definition mov_mbr_xids : list ident :=
  interaction._atan2s :: mario._play_sound :: nil.

(* update_sliding_angle: slideVel/faceAngle window stores + atan2s/sqrtf ext
   + mario_update_moving_sand / mario_update_windy_ground. *)
Definition mov_usa_ids : list ident :=
  mario_step._mario_update_moving_sand
    :: mario_step._mario_update_windy_ground :: nil.
Definition mov_usa_xids : list ident := interaction._atan2s :: mario._sqrtf :: nil.

(* update_sliding: forwardVel window store + sqrtf ext + floor helpers. *)
Definition mov_usl_ids : list ident :=
  mario._mario_get_floor_class
    :: mario_actions_moving._update_sliding_angle
    :: mario._mario_floor_is_slope
    :: mario._mario_set_forward_vel :: nil.
Definition mov_usl_xids : list ident := mario._sqrtf :: nil.

(* act_slide_kick_slide leaf: const-action sids + the slide helper subtree. *)
Definition mov_sks_ids : list ident :=
  mario._set_mario_animation
    :: mario._is_anim_at_end
    :: mario_actions_moving._update_sliding
    :: mario_step._perform_ground_step
    :: mario_step._mario_bonk_reflection :: nil.
Definition mov_sks_sids : list ident :=
  mario._set_jumping_action :: mario._set_mario_action :: nil.
Definition mov_sks_xids : list ident := mario._play_sound :: nil.

(* ---------------------------------------------------------------------- *)
(* SLICE M8: the val0C np3 leaf act_hold_decelerating.                     *)
(* The new engine arm (recursive/copy/literal nsrc_chk) lets the nids      *)
(* channel certify the `val0C = (int)(int)(fv*0x10000); if(...) val0C=...` *)
(* idiom; the np3 channel then carries set_mario_anim_with_accel.  Two new *)
(* clean helper rows: update_decelerating_speed (approach_f32 ext +        *)
(* window/sand/wind) and adjust_sound_for_speed (set_sound_moving_speed    *)
(* obj_ext).                                                               *)
(* ---------------------------------------------------------------------- *)

(* update_decelerating_speed: m->forwardVel = approach_f32(..) window store
   + mario_set_forward_vel + mario_update_moving_sand/windy_ground. *)
Definition mov_uds_ids : list ident :=
  mario._mario_set_forward_vel
    :: mario_step._mario_update_moving_sand
    :: mario_step._mario_update_windy_ground :: nil.
Definition mov_uds_xids : list ident := mario_actions_moving._approach_f32 :: nil.

(* adjust_sound_for_speed (mario.prog, the Internal one): read-only +
   set_sound_moving_speed (obj_ext). *)
Definition mov_asfs_xids : list ident := mario._set_sound_moving_speed :: nil.

(* act_hold_decelerating leaf (body_pres, np3 channel). *)
Definition mov_ahd_ids : list ident :=
  mario._mario_get_floor_class
    :: mario_actions_moving._should_begin_sliding
    :: mario_actions_moving._update_decelerating_speed
    :: mario_step._perform_ground_step
    :: mario_step._mario_bonk_reflection
    :: mario._mario_set_forward_vel
    :: mario._set_mario_animation
    :: mario._adjust_sound_for_speed
    :: mario_actions_moving._play_step_sound :: nil.
Definition mov_ahd_sids : list ident :=
  mario._set_mario_action
    :: mario._set_jumping_action
    :: mario._drop_and_set_mario_action :: nil.
Definition mov_ahd_xids : list ident := mario._play_sound :: nil.
Definition mov_ahd_nids : list ident :=
  mario_actions_moving._t'12 :: mario_actions_moving._val0C :: nil.
Definition mov_ahd_np3 : list ident := mario._set_mario_anim_with_accel :: nil.

(* ---------------------------------------------------------------------- *)
(* SLICE M9: the param-action leaf act_turning_around.                     *)
(* begin_walking_action(m, <float forwardVel>, ACT_X, 0) is an act3-class  *)
(* call whose action arg (args[1]) is an untainted const and whose arg[0]  *)
(* (forwardVel) is a FLOAT -- value-irrelevant for call_pres_act3.  The    *)
(* generalized act3_call_chk arm (relaxed arg0, routed to                   *)
(* kit_scall3_anim_pres) recognizes it; the 4-param position-3 producer     *)
(* call_pres_act3_of_wwalk_p4 discharges begin_walking_action's own body    *)
(* (it threads its _action PARAM through wact into set_mario_action).  Two  *)
(* new clean helper rows: analog_stick_held_back (read-only) and            *)
(* apply_slope_decel (floor-class + approach_f32 ext + apply_slope_accel,   *)
(* the last already proved as mov_asa_row).                                 *)
(* ---------------------------------------------------------------------- *)

(* apply_slope_decel: mario_get_floor_class + apply_slope_accel (ids) +
   approach_f32 (ext); switch sets _decel; m->forwardVel window store. *)
Definition mov_asd_ids : list ident :=
  mario._mario_get_floor_class
    :: mario_actions_moving._apply_slope_accel :: nil.
Definition mov_asd_xids : list ident := mario_actions_moving._approach_f32 :: nil.

(* ---------------------------------------------------------------------- *)
(* common_landing_action: the LANDING-family helper EVERY _land leaf       *)
(* calls after common_landing_cancels.  It writes m->action only at its    *)
(* switch-case-0 set_mario_action(m, airAction, 0) -- airAction is the 3rd *)
(* PARAM, the UNTAINTED const each leaf passes (16779404, ...).  So it is  *)
(* NOT a generic call_pres (false for a tainted airAction); the engine     *)
(* threads _airAction through wact and the leaf supplies untainted_scalar. *)
(* Its non-action callees all have rows already: perform_ground_step (Hcp_ *)
(* pgs), apply_landing_accel (mov_ala_row), apply_slope_decel (mov_asd_    *)
(* row), set_mario_animation (mov_sma_row); play_mario_landing_sound_once  *)
(* is an mov_ext external; set_mario_action is the sids keystone.          *)
Definition cla_ids : list ident :=
  mario_step._perform_ground_step :: mario_actions_moving._apply_landing_accel
    :: mario_actions_moving._apply_slope_decel :: mario._set_mario_animation
    :: nil.
Definition cla_xids : list ident :=
  mario_actions_moving._play_mario_landing_sound_once :: nil.
Definition cla_sids : list ident := mario._set_mario_action :: nil.

(* begin_walking_action producer: wact threads the _action PARAM + the
   set_mario_action result temp _t'1; ids = mario_set_forward_vel;
   wids = set_mario_action.  Output: call_pres_act3. *)
Definition mov_bwa_wact : list ident :=
  mario_actions_moving._action :: mario_actions_moving._t'1 :: nil.
Definition mov_bwa_ids : list ident := mario._mario_set_forward_vel :: nil.
Definition mov_bwa_wids : list ident := mario._set_mario_action :: nil.

(* act_turning_around leaf (body_pres, tids/act3 channel). *)
Definition mov_ata_ids : list ident :=
  mario_actions_moving._analog_stick_held_back
    :: mario_actions_moving._apply_slope_decel
    :: mario_step._perform_ground_step
    :: mario._set_mario_animation
    :: mario._is_anim_at_end
    :: mario._adjust_sound_for_speed :: nil.
Definition mov_ata_sids : list ident :=
  mario._set_mario_action :: mario._set_jumping_action :: nil.
Definition mov_ata_tids : list ident :=
  mario_actions_moving._begin_walking_action :: nil.
Definition mov_ata_xids : list ident := mario._play_sound :: nil.

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

(* ---- SLICE M6 pins ---- *)
Example mov_aahh_pin :
  (prog_defmap mario_actions_moving.prog)
    ! mario_actions_moving._anim_and_audio_for_heavy_walk
  = Some (Gfun (Internal mario_actions_moving.f_anim_and_audio_for_heavy_walk)).
Proof. vm_compute. reflexivity. Qed.
Example mov_aahh_vars :
  fn_vars mario_actions_moving.f_anim_and_audio_for_heavy_walk = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_aahh_pok :
  mov_pok mario_actions_moving.f_anim_and_audio_for_heavy_walk = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_aahh_nonparam_n :
  forallb (fun t' => negb (mem_id t'
    (map fst (fn_params mario_actions_moving.f_anim_and_audio_for_heavy_walk))))
    mov_aahh_nids = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_aahh_walk :
  wwalk_chk' nil nil nil nil mov_aahh_nids mov_aahw_np3 false
    nil mov_aahw_ids nil nil nil nil nil
    (fn_body mario_actions_moving.f_anim_and_audio_for_heavy_walk) = true.
Proof. vm_compute. reflexivity. Qed.

Example mov_ahhw_pin :
  (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._act_hold_heavy_walking
  = Some (Gfun (Internal mario_actions_moving.f_act_hold_heavy_walking)).
Proof. vm_compute. reflexivity. Qed.
Example mov_ahhw_vars : fn_vars mario_actions_moving.f_act_hold_heavy_walking = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_ahhw_pok : mov_pok mario_actions_moving.f_act_hold_heavy_walking = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_ahhw_walk :
  wwalk_chk false nil mov_ahhw_ids nil nil nil mov_ahhw_sids nil
    (fn_body mario_actions_moving.f_act_hold_heavy_walking) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- SLICE M7 pins ---- *)
Example mov_mbr_pin :
  (prog_defmap mario_step.prog) ! mario_step._mario_bonk_reflection
  = Some (Gfun (Internal mario_step.f_mario_bonk_reflection)).
Proof. vm_compute. reflexivity. Qed.
Example mov_mbr_vars : fn_vars mario_step.f_mario_bonk_reflection = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_mbr_pok : mov_pok mario_step.f_mario_bonk_reflection = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_mbr_walk :
  wwalk_chk false nil mov_mbr_ids nil nil mov_mbr_xids nil nil
    (fn_body mario_step.f_mario_bonk_reflection) = true.
Proof. vm_compute. reflexivity. Qed.

Example mov_usa_pin :
  (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._update_sliding_angle
  = Some (Gfun (Internal mario_actions_moving.f_update_sliding_angle)).
Proof. vm_compute. reflexivity. Qed.
Example mov_usa_vars : fn_vars mario_actions_moving.f_update_sliding_angle = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_usa_pok : mov_pok mario_actions_moving.f_update_sliding_angle = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_usa_walk :
  wwalk_chk false nil mov_usa_ids nil nil mov_usa_xids nil nil
    (fn_body mario_actions_moving.f_update_sliding_angle) = true.
Proof. vm_compute. reflexivity. Qed.

Example mov_usl_pin :
  (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._update_sliding
  = Some (Gfun (Internal mario_actions_moving.f_update_sliding)).
Proof. vm_compute. reflexivity. Qed.
Example mov_usl_vars : fn_vars mario_actions_moving.f_update_sliding = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_usl_pok : mov_pok mario_actions_moving.f_update_sliding = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_usl_walk :
  wwalk_chk false nil mov_usl_ids nil nil mov_usl_xids nil nil
    (fn_body mario_actions_moving.f_update_sliding) = true.
Proof. vm_compute. reflexivity. Qed.

Example mov_sks_pin :
  (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._act_slide_kick_slide
  = Some (Gfun (Internal mario_actions_moving.f_act_slide_kick_slide)).
Proof. vm_compute. reflexivity. Qed.
Example mov_sks_vars : fn_vars mario_actions_moving.f_act_slide_kick_slide = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_sks_pok : mov_pok mario_actions_moving.f_act_slide_kick_slide = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_sks_walk :
  wwalk_chk false nil mov_sks_ids nil nil mov_sks_xids mov_sks_sids nil
    (fn_body mario_actions_moving.f_act_slide_kick_slide) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- SLICE M8 pins/walks ---- *)
Example mov_uds_pin :
  (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._update_decelerating_speed
  = Some (Gfun (Internal mario_actions_moving.f_update_decelerating_speed)).
Proof. vm_compute. reflexivity. Qed.
Example mov_uds_vars : fn_vars mario_actions_moving.f_update_decelerating_speed = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_uds_pok : mov_pok mario_actions_moving.f_update_decelerating_speed = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_uds_walk :
  wwalk_chk false nil mov_uds_ids nil nil mov_uds_xids nil nil
    (fn_body mario_actions_moving.f_update_decelerating_speed) = true.
Proof. vm_compute. reflexivity. Qed.

Example mov_asfs_pin :
  (prog_defmap mario.prog) ! mario._adjust_sound_for_speed
  = Some (Gfun (Internal mario.f_adjust_sound_for_speed)).
Proof. vm_compute. reflexivity. Qed.
Example mov_asfs_vars : fn_vars mario.f_adjust_sound_for_speed = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_asfs_pok : mov_pok mario.f_adjust_sound_for_speed = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_asfs_walk :
  wwalk_chk false nil nil nil nil mov_asfs_xids nil nil
    (fn_body mario.f_adjust_sound_for_speed) = true.
Proof. vm_compute. reflexivity. Qed.

Example mov_ahd_pin :
  (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._act_hold_decelerating
  = Some (Gfun (Internal mario_actions_moving.f_act_hold_decelerating)).
Proof. vm_compute. reflexivity. Qed.
Example mov_ahd_vars : fn_vars mario_actions_moving.f_act_hold_decelerating = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_ahd_pok : mov_pok mario_actions_moving.f_act_hold_decelerating = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_ahd_nonparam_n :
  forallb (fun t' => negb (mem_id t'
    (map fst (fn_params mario_actions_moving.f_act_hold_decelerating))))
    mov_ahd_nids = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_ahd_walk :
  wwalk_chk' nil nil nil nil mov_ahd_nids mov_ahd_np3 false
    nil mov_ahd_ids nil nil mov_ahd_xids mov_ahd_sids nil
    (fn_body mario_actions_moving.f_act_hold_decelerating) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- SLICE M9 pins/walks ---- *)
Example mov_ashb_pin :
  (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._analog_stick_held_back
  = Some (Gfun (Internal mario_actions_moving.f_analog_stick_held_back)).
Proof. vm_compute. reflexivity. Qed.
Example mov_ashb_vars : fn_vars mario_actions_moving.f_analog_stick_held_back = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_ashb_pok : mov_pok mario_actions_moving.f_analog_stick_held_back = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_ashb_walk :
  wwalk_chk false nil nil nil nil nil nil nil
    (fn_body mario_actions_moving.f_analog_stick_held_back) = true.
Proof. vm_compute. reflexivity. Qed.

Example mov_asd_pin :
  (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._apply_slope_decel
  = Some (Gfun (Internal mario_actions_moving.f_apply_slope_decel)).
Proof. vm_compute. reflexivity. Qed.
Example mov_asd_vars : fn_vars mario_actions_moving.f_apply_slope_decel = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_asd_pok : mov_pok mario_actions_moving.f_apply_slope_decel = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_asd_walk :
  wwalk_chk false nil mov_asd_ids nil nil mov_asd_xids nil nil
    (fn_body mario_actions_moving.f_apply_slope_decel) = true.
Proof. vm_compute. reflexivity. Qed.

Example mov_bwa_pin :
  (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._begin_walking_action
  = Some (Gfun (Internal mario_actions_moving.f_begin_walking_action)).
Proof. vm_compute. reflexivity. Qed.
Example mov_bwa_vars : fn_vars mario_actions_moving.f_begin_walking_action = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_bwa_params :
  fn_params mario_actions_moving.f_begin_walking_action
  = (mario_actions_airborne._m, tyMSp)
      :: (mario_actions_moving._forwardVel, tfloat)
      :: (mario_actions_moving._action, tuint)
      :: (mario_actions_moving._actionArg, tuint) :: nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_bwa_aid_m :
  mario_actions_moving._forwardVel <> mario_actions_airborne._m.
Proof. vm_compute. discriminate. Qed.
Example mov_bwa_eid_m :
  mario_actions_moving._action <> mario_actions_airborne._m.
Proof. vm_compute. discriminate. Qed.
Example mov_bwa_harg_m :
  mario_actions_moving._actionArg <> mario_actions_airborne._m.
Proof. vm_compute. discriminate. Qed.
Example mov_bwa_wa : mem_id mario_actions_moving._action mov_bwa_wact = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_bwa_wm : mem_id mario_actions_airborne._m mov_bwa_wact = false.
Proof. vm_compute. reflexivity. Qed.
Example mov_bwa_wanim :
  mem_id mario_actions_moving._forwardVel mov_bwa_wact = false.
Proof. vm_compute. reflexivity. Qed.
Example mov_bwa_wharg :
  mem_id mario_actions_moving._actionArg mov_bwa_wact = false.
Proof. vm_compute. reflexivity. Qed.
Example mov_bwa_walk :
  wwalk_chk false mov_bwa_wact mov_bwa_ids mov_bwa_wids nil nil nil nil
    (fn_body mario_actions_moving.f_begin_walking_action) = true.
Proof. vm_compute. reflexivity. Qed.

Example mov_ata_pin :
  (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._act_turning_around
  = Some (Gfun (Internal mario_actions_moving.f_act_turning_around)).
Proof. vm_compute. reflexivity. Qed.
Example mov_ata_vars : fn_vars mario_actions_moving.f_act_turning_around = nil.
Proof. vm_compute. reflexivity. Qed.
Example mov_ata_pok : mov_pok mario_actions_moving.f_act_turning_around = true.
Proof. vm_compute. reflexivity. Qed.
Example mov_ata_walk :
  wwalk_chk false nil mov_ata_ids nil nil mov_ata_xids mov_ata_sids mov_ata_tids
    (fn_body mario_actions_moving.f_act_turning_around) = true.
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

  (* LANDING KEYSTONE kit (clc walk).  An Mint32 load from a knockback_table_ids
     block is an untainted scalar (the LandingAction globals were folded into
     knockback_table_ids); the carried MWF pins Mario's input halfword A-clear.
     Both discharged at the capstone via MWFReal.mwf_real_ktab / mwf_real_inp --
     NO new trust. *)
  Hypothesis HMWF_ktab : forall m gid kb (ofs : Z) v,
      MWF m -> mem_id gid knockback_table_ids = true ->
      Genv.find_symbol (lp_ge lp) gid = Some kb ->
      Mem.load Mint32 m kb ofs = Some v ->
      v = Vundef \/ exists vi, v = Vint vi /\ not_tainted vi.
  Hypothesis HMWF_inp : forall m, MWF m -> input_a_clear m bm.
  (* the input-store MWF preservation: storing an A-clear halfword at the input
     cell [2,4) keeps MWF (store_window_ok EXCLUDES [2,4), so HMWF_window does
     not cover this -- a separate row, discharged at the capstone via
     MWFReal.mwf_real_input; NO new trust). *)
  Hypothesis HMWF_input : forall mm mm' vv,
      MWF mm -> Int.and vv (Int.repr 2) = Int.zero ->
      Mem.store Mint16unsigned mm bm 2 (Vint vv) = Some mm' -> MWF mm'.

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

  (* play_sound_if_no_flag -- REUSED from ObjectLeafSurface.psinf_row (its
     internal walk routes the only external, mario._play_sound, through
     Hcpx_psound).  The landing leaves' optional sound site. *)
  Let Hpsinf : call_pres lp bm NoA MWF mario._play_sound_if_no_flag :=
    ObjectLeafSurface.psinf_row lp LO_mario bm NoA MWF HNoA_of_MWF HMWF_window
      HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot HMWF_chase HMWF_root
      HMWF_sglob HchaseStep HMWF_chase_safe Hcpx_psound.

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

  (* ---- SLICE M6: act_hold_heavy_walking (reuses the M5 subtree) ---- *)
  Lemma mov_aahh_row :
    call_pres lp bm NoA MWF mario_actions_moving._anim_and_audio_for_heavy_walk.
  Proof.
    apply (call_pres_of_wwalk_nids lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_moving.prog
             mario_actions_moving._anim_and_audio_for_heavy_walk
             mario_actions_moving.f_anim_and_audio_for_heavy_walk
             mov_aahw_ids nil nil nil nil nil mov_aahh_nids mov_aahw_np3
             LO_mov mov_aahh_pin mov_aahh_vars mov_aahh_pok
             eq_refl mov_aahh_nonparam_n).
    - exact mov_aahw_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact mov_aahw_np3_rows.
    - exact mov_aahh_walk.
  Qed.

  Lemma mov_ahhw_ids_rows : forall fid, mem_id fid mov_ahhw_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_ahhw_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_aahh_row | ].
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

  Lemma mov_ahhw_sids_rows : forall fid, mem_id fid mov_ahhw_sids = true ->
      call_pres_act lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_ahhw_sids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsmact | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hdasma | ].
    discriminate H.
  Qed.

  Lemma mov_ahhw_pres :
    body_pres lp NoA MWF bm mario_actions_moving.f_act_hold_heavy_walking.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_moving.f_act_hold_heavy_walking
             mov_ahhw_ids nil nil mov_ahhw_sids nil
             mov_ahhw_vars mov_ahhw_pok).
    - exact mov_ahhw_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact mov_ahhw_sids_rows.
    - intros fid' H. discriminate H.
    - exact mov_ahhw_walk.
  Qed.

  (* ================================================================== *)
  (* SLICE M7: the slide helper subtree + act_slide_kick_slide.         *)
  (* ================================================================== *)

  (* mario_bonk_reflection: faceAngle[1] window store + atan2s/play_sound ext
     + mario_set_forward_vel (mario_step.prog). *)
  Lemma mov_mbr_ids_rows : forall fid, mem_id fid mov_mbr_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_mbr_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_msfv_row | ].
    discriminate H.
  Qed.

  Lemma mov_mbr_xids_rows : forall fid, mem_id fid mov_mbr_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_mbr_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid;
        apply Hpres_obj_ext; vm_compute; reflexivity | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_psound | ].
    discriminate H.
  Qed.

  Lemma mov_mbr_row :
    call_pres lp bm NoA MWF mario_step._mario_bonk_reflection.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_step.prog mario_step._mario_bonk_reflection
             mario_step.f_mario_bonk_reflection
             mov_mbr_ids nil mov_mbr_xids nil
             LO_mario_step mov_mbr_pin mov_mbr_vars mov_mbr_pok).
    - exact mov_mbr_ids_rows.
    - intros fid' H. discriminate H.
    - exact mov_mbr_xids_rows.
    - intros fid' H. discriminate H.
    - exact mov_mbr_walk.
  Qed.

  (* update_sliding_angle: window stores + atan2s/sqrtf ext + sand/wind. *)
  Lemma mov_usa_ids_rows : forall fid, mem_id fid mov_usa_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_usa_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_mums_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_muwg_row | ].
    discriminate H.
  Qed.

  Lemma mov_usa_xids_rows : forall fid, mem_id fid mov_usa_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_usa_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid;
        apply Hpres_obj_ext; vm_compute; reflexivity | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_sqrtf | ].
    discriminate H.
  Qed.

  Lemma mov_usa_row :
    call_pres lp bm NoA MWF mario_actions_moving._update_sliding_angle.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_moving.prog mario_actions_moving._update_sliding_angle
             mario_actions_moving.f_update_sliding_angle
             mov_usa_ids nil mov_usa_xids nil
             LO_mov mov_usa_pin mov_usa_vars mov_usa_pok).
    - exact mov_usa_ids_rows.
    - intros fid' H. discriminate H.
    - exact mov_usa_xids_rows.
    - intros fid' H. discriminate H.
    - exact mov_usa_walk.
  Qed.

  (* update_sliding: forwardVel window store + sqrtf ext + floor helpers
     + update_sliding_angle. *)
  Lemma mov_usl_ids_rows : forall fid, mem_id fid mov_usl_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_usl_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_mgfc_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_usa_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_mfis_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_msfv_row | ].
    discriminate H.
  Qed.

  Lemma mov_usl_xids_rows : forall fid, mem_id fid mov_usl_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_usl_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_sqrtf | ].
    discriminate H.
  Qed.

  Lemma mov_usl_row :
    call_pres lp bm NoA MWF mario_actions_moving._update_sliding.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_moving.prog mario_actions_moving._update_sliding
             mario_actions_moving.f_update_sliding
             mov_usl_ids nil mov_usl_xids nil
             LO_mov mov_usl_pin mov_usl_vars mov_usl_pok).
    - exact mov_usl_ids_rows.
    - intros fid' H. discriminate H.
    - exact mov_usl_xids_rows.
    - intros fid' H. discriminate H.
    - exact mov_usl_walk.
  Qed.

  (* act_slide_kick_slide leaf (body_pres): const-action sids + slide subtree. *)
  Lemma mov_sks_ids_rows : forall fid, mem_id fid mov_sks_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_sks_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_sma_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_iae_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_usl_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_pgs | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_mbr_row | ].
    discriminate H.
  Qed.

  Lemma mov_sks_sids_rows : forall fid, mem_id fid mov_sks_sids = true ->
      call_pres_act lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_sks_sids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_sja_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsmact | ].
    discriminate H.
  Qed.

  Lemma mov_sks_xids_rows : forall fid, mem_id fid mov_sks_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_sks_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_psound | ].
    discriminate H.
  Qed.

  Lemma mov_sks_pres :
    body_pres lp NoA MWF bm mario_actions_moving.f_act_slide_kick_slide.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_moving.f_act_slide_kick_slide
             mov_sks_ids nil mov_sks_xids mov_sks_sids nil
             mov_sks_vars mov_sks_pok).
    - exact mov_sks_ids_rows.
    - intros fid' H. discriminate H.
    - exact mov_sks_xids_rows.
    - exact mov_sks_sids_rows.
    - intros fid' H. discriminate H.
    - exact mov_sks_walk.
  Qed.

  (* ---- SLICE M8: update_decelerating_speed + adjust_sound_for_speed
     + act_hold_decelerating (the val0C np3 leaf). ---- *)
  Lemma mov_uds_ids_rows : forall fid, mem_id fid mov_uds_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_uds_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_msfv_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_mums_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_muwg_row | ].
    discriminate H.
  Qed.

  Lemma mov_uds_xids_rows : forall fid, mem_id fid mov_uds_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_uds_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid;
        apply Hpres_mov_ext; vm_compute; reflexivity | ].
    discriminate H.
  Qed.

  Lemma mov_uds_row :
    call_pres lp bm NoA MWF mario_actions_moving._update_decelerating_speed.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_moving.prog mario_actions_moving._update_decelerating_speed
             mario_actions_moving.f_update_decelerating_speed
             mov_uds_ids nil mov_uds_xids nil
             LO_mov mov_uds_pin mov_uds_vars mov_uds_pok).
    - exact mov_uds_ids_rows.
    - intros fid' H. discriminate H.
    - exact mov_uds_xids_rows.
    - intros fid' H. discriminate H.
    - exact mov_uds_walk.
  Qed.

  Lemma mov_asfs_xids_rows : forall fid, mem_id fid mov_asfs_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_asfs_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid;
        apply Hpres_obj_ext; vm_compute; reflexivity | ].
    discriminate H.
  Qed.

  Lemma mov_asfs_row :
    call_pres lp bm NoA MWF mario._adjust_sound_for_speed.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario.prog mario._adjust_sound_for_speed
             mario.f_adjust_sound_for_speed
             nil nil mov_asfs_xids nil
             LO_mario mov_asfs_pin mov_asfs_vars mov_asfs_pok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact mov_asfs_xids_rows.
    - intros fid' H. discriminate H.
    - exact mov_asfs_walk.
  Qed.

  Lemma mov_ahd_ids_rows : forall fid, mem_id fid mov_ahd_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_ahd_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_mgfc_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_sbs_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_uds_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_pgs | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_mbr_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_msfv_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_sma_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_asfs_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_pss_row | ].
    discriminate H.
  Qed.

  Lemma mov_ahd_sids_rows : forall fid, mem_id fid mov_ahd_sids = true ->
      call_pres_act lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_ahd_sids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsmact | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_sja_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hdasma | ].
    discriminate H.
  Qed.

  Lemma mov_ahd_xids_rows : forall fid, mem_id fid mov_ahd_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_ahd_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_psound | ].
    discriminate H.
  Qed.

  Lemma mov_ahd_pres :
    body_pres lp NoA MWF bm mario_actions_moving.f_act_hold_decelerating.
  Proof.
    apply (body_pres_of_wwalk_nids lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_moving.f_act_hold_decelerating
             mov_ahd_ids nil nil mov_ahd_xids mov_ahd_sids nil
             mov_ahd_nids mov_ahd_np3
             mov_ahd_vars mov_ahd_pok eq_refl mov_ahd_nonparam_n).
    - exact mov_ahd_ids_rows.
    - intros fid' H. discriminate H.
    - exact mov_ahd_xids_rows.
    - exact mov_ahd_sids_rows.
    - intros fid' H. discriminate H.
    - exact mov_aahw_np3_rows.
    - exact mov_ahd_walk.
  Qed.

  (* ---- SLICE M9: the param-action leaf act_turning_around ---- *)

  (* analog_stick_held_back: pure read-only (reads intendedYaw/faceAngle[1]) *)
  Lemma mov_ashb_row :
    call_pres lp bm NoA MWF mario_actions_moving._analog_stick_held_back.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_moving.prog mario_actions_moving._analog_stick_held_back
             mario_actions_moving.f_analog_stick_held_back
             nil nil nil nil LO_mov mov_ashb_pin mov_ashb_vars mov_ashb_pok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact mov_ashb_walk.
  Qed.

  (* apply_slope_decel: mario_get_floor_class + apply_slope_accel + approach_f32 *)
  Lemma mov_asd_ids_rows : forall fid, mem_id fid mov_asd_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_asd_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_mgfc_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_asa_row | ].
    discriminate H.
  Qed.

  Lemma mov_asd_xids_rows : forall fid, mem_id fid mov_asd_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_asd_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid;
        apply Hpres_mov_ext; vm_compute; reflexivity | ].
    discriminate H.
  Qed.

  Lemma mov_asd_row :
    call_pres lp bm NoA MWF mario_actions_moving._apply_slope_decel.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_moving.prog mario_actions_moving._apply_slope_decel
             mario_actions_moving.f_apply_slope_decel
             mov_asd_ids nil mov_asd_xids nil
             LO_mov mov_asd_pin mov_asd_vars mov_asd_pok).
    - exact mov_asd_ids_rows.
    - intros fid' H. discriminate H.
    - exact mov_asd_xids_rows.
    - intros fid' H. discriminate H.
    - exact mov_asd_walk.
  Qed.

  (* ================================================================== *)
  (* common_landing_action: the bespoke funcall lift (airAction = an     *)
  (* untainted const).  Its body walks under the wwalk engine with        *)
  (* _airAction in wact; the non-action callees route through the rows    *)
  (* above.  NOT a generic call_pres -- it is keyed to untainted aval.    *)
  (* ================================================================== *)
  Lemma cla_ids_rows : forall fid, mem_id fid cla_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold cla_ids in H. cbn [mem_id existsb] in H.
    repeat (apply orb_true_iff in H as [Hm | H];
            [ apply Pos.eqb_eq in Hm; subst fid | ]).
    - exact Hcp_pgs.
    - exact mov_ala_row.
    - exact mov_asd_row.
    - exact mov_sma_row.
    - discriminate H.
  Qed.

  Lemma cla_xids_rows : forall fid, mem_id fid cla_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold cla_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid
      | discriminate H ].
    exact (Hpres_mov_ext mario_actions_moving._play_mario_landing_sound_once
             eq_refl).
  Qed.

  Lemma cla_sids_rows : forall fid, mem_id fid cla_sids = true ->
      call_pres_act lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold cla_sids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsmact | discriminate H ].
  Qed.

  (* MARG form: first arg via tat0, so a non-pointer m is handled vacuously
     by the engine (wwalk_pres0's tat precondition is itself marg-shaped). *)
  Lemma cla_funcall_pres :
    forall fd m0 v0 vanim av t0 m1 vres0,
      resolves_lp lp mario_actions_moving._common_landing_action fd ->
      eval_funcall function_entry2 (lp_ge lp) m0 fd
        (v0 :: vanim :: Vint av :: nil) t0 m1 vres0 ->
      (forall b o, v0 = Vptr b o -> b = bm /\ o = Ptrofs.zero) ->
      untainted_scalar (Vint av) ->
      NoA m0 -> MWF m0 -> Mem.valid_block m0 bm -> action_sat not_tainted m0 bm ->
      Mem.valid_block m1 bm /\ action_sat not_tainted m1 bm /\ MWF m1 /\ NoA m1.
  Proof.
    intros fd m0 v0 vanim av t0 m1 vres0 Hres Hevf Htat Huav HN HM HV HS.
    pose proof (resolve_pin_fd lp mario_actions_moving.prog
                  mario_actions_moving._common_landing_action
                  mario_actions_moving.f_common_landing_action fd
                  LO_mov ltac:(vm_compute; reflexivity) Hres) as ->.
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ =>
      rename He into Hentry end.
    match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
      rename Hx into Hbody end.
    match goal with Hf : Mem.free_list _ _ = Some _ |- _ =>
      rename Hf into Hfree end.
    inv Hentry.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
      change (fn_vars mario_actions_moving.f_common_landing_action)
        with (@nil (ident * type)) in Ha; inv Ha end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ =>
      rename Hb into Hbind end.
    change (fn_params mario_actions_moving.f_common_landing_action)
      with ((mario_actions_moving._m,
             tptr (Tstruct mario_actions_moving._MarioState noattr)) ::
            (mario_actions_moving._animation, tshort) ::
            (mario_actions_moving._airAction, tuint) :: nil) in Hbind.
    cbn [bind_parameter_temps] in Hbind.
    injection Hbind as <-.
    change (blocks_of_env (lp_ge lp) empty_env)
      with (@nil (block * Z * Z)) in Hfree.
    cbn [Mem.free_list] in Hfree. injection Hfree as <-.
    set (base := create_undef_temps
                   (fn_temps mario_actions_moving.f_common_landing_action)) in *.
    assert (Htat0 : forall b o,
       (PTree.set mario_actions_moving._airAction (Vint av)
          (PTree.set mario_actions_moving._animation vanim
             (PTree.set mario_actions_moving._m v0 base)))
         ! mario_actions_airborne._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
    { intros b o Hg.
      rewrite PTree.gso in Hg by (vm_compute; congruence).
      rewrite PTree.gso in Hg by (vm_compute; congruence).
      rewrite PTree.gss in Hg. injection Hg as Hg. exact (Htat b o Hg). }
    assert (Hact0 : act_inv (mario_actions_moving._airAction :: nil)
       (PTree.set mario_actions_moving._airAction (Vint av)
          (PTree.set mario_actions_moving._animation vanim
             (PTree.set mario_actions_moving._m v0 base)))).
    { intros t' Hmem' x Hg'.
      cbn [mem_id existsb] in Hmem'.
      apply orb_true_iff in Hmem' as [Ht | Hf]; [ | discriminate Hf ].
      apply Pos.eqb_eq in Ht; subst t'.
      rewrite PTree.gss in Hg'. injection Hg' as <-. exact Huav. }
    assert (Hch0 : chase_inv SafeB nil
       (PTree.set mario_actions_moving._airAction (Vint av)
          (PTree.set mario_actions_moving._animation vanim
             (PTree.set mario_actions_moving._m v0 base))))
      by (intros t' Hmem'; discriminate Hmem').
    destruct (wwalk_pres0 lp LO_mario bm NoA MWF HNoA_of_MWF HMWF_window
                HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot HMWF_chase
                HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
                false (mario_actions_moving._airAction :: nil) cla_ids nil nil
                cla_xids cla_sids nil
                cla_ids_rows ltac:(intros fid HH; discriminate HH)
                cla_xids_rows cla_sids_rows ltac:(intros fid HH; discriminate HH)
                _ _ _ _ _ _ _ _ Hbody
                (empty_env_unbound _) (empty_env_unbound _) (empty_env_unbound _)
                (empty_env_unbound _) (empty_env_unbound _) (empty_env_unbound _)
                (PTree.gempty _ _) ltac:(vm_compute; reflexivity) Htat0 Hact0 Hch0
                HN HM HV HS)
      as (HV' & HS' & HM' & HN' & _).
    exact (conj HV' (conj HS' (conj HM' HN'))).
  Qed.

  (* ================================================================== *)
  (* LANDING KEYSTONE: the 3 CLEAN _land leaves (jump/freefall/double).   *)
  (* Each body = clc(m,&sXLandAction,setX); if(t'1) return 1;             *)
  (*             cla(m,anim,UNTAINTED); return 0.                          *)
  (* clc lifted by LandingBricks.clc_funcall_pres_marg (the knockback-     *)
  (* global landingAction walk); cla by the marg-form cla_funcall_pres.    *)
  (* ================================================================== *)
  Let clc_marg := LandingBricks.clc_funcall_pres_marg lp LO_mario
    LO_mario_step LO_mov bm NoA MWF HNoA_of_MWF HMWF_window HMWF_glob
    HMWF_act SafeB HSafeNotBm HchaseRoot HMWF_chase HMWF_root HMWF_sglob
    HchaseStep HMWF_chase_safe HMWF_ktab HMWF_inp.

  (* local clean exec_stmt inversion helpers (lnd_-prefixed: AGates and
     LandingBricks each have a section-local exec_seq_cases). *)
  Lemma lnd_exec_seq_cases :
    forall e le m s1 s2 tr le' m' out,
      exec_stmt function_entry2 (lp_ge lp) e le m (Ssequence s1 s2) tr le' m' out ->
      (exists tr1 le1 m1 tr2,
          exec_stmt function_entry2 (lp_ge lp) e le m s1 tr1 le1 m1 Out_normal /\
          exec_stmt function_entry2 (lp_ge lp) e le1 m1 s2 tr2 le' m' out)
      \/ (exec_stmt function_entry2 (lp_ge lp) e le m s1 tr le' m' out /\
          out <> Out_normal).
  Proof.
    intros e le m s1 s2 tr le' m' out H; inv H.
    - left; do 4 eexists; split; eassumption.
    - right; split; assumption.
  Qed.

  Lemma lnd_exec_if_inv :
    forall e le m c s1 s2 tr le' m' out,
      exec_stmt function_entry2 (lp_ge lp) e le m (Sifthenelse c s1 s2) tr le' m' out ->
      exists b, exec_stmt function_entry2 (lp_ge lp) e le m (if b : bool then s1 else s2)
                  tr le' m' out.
  Proof. intros; match goal with H : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => inv H end;
           eexists; eassumption. Qed.

  Lemma lnd_exec_skip_inv :
    forall e le m tr le' m' out,
      exec_stmt function_entry2 (lp_ge lp) e le m Sskip tr le' m' out ->
      le' = le /\ m' = m /\ out = Out_normal.
  Proof. intros; match goal with H : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => inv H end; auto. Qed.

  Lemma lnd_exec_return_inv :
    forall e le m a tr le' m' out,
      exec_stmt function_entry2 (lp_ge lp) e le m (Sreturn a) tr le' m' out ->
      le' = le /\ m' = m /\ out <> Out_normal.
  Proof. intros; match goal with H : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => inv H end;
           (split; [ reflexivity | split; [ reflexivity | discriminate ] ]). Qed.

  Lemma lnd_exec_set_inv :
    forall e le m id a tr le' m' out,
      exec_stmt function_entry2 (lp_ge lp) e le m (Sset id a) tr le' m' out ->
      m' = m /\ out = Out_normal /\ exists v, le' = PTree.set id v le.
  Proof. intros; match goal with H : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => inv H end;
           (split; [ reflexivity | split; [ reflexivity | eexists; reflexivity ] ]). Qed.

  (* the clean clc call site: Scall (Some _t'1) of common_landing_cancels with
     args (Etempvar _m, &gid, Evar sap).  gid in knockback_table_ids; sap the
     (arbitrary, used vacuously) setAPressAction.  Preserves + reads off le!_m. *)
  Lemma clc_site_pres :
    forall dst gid sap le m tr le' m' out,
      dst <> M._m ->
      mem_id gid knockback_table_ids = true ->
      (forall b o, le ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero) ->
      exec_stmt function_entry2 (lp_ge lp) empty_env le m
        (Scall (Some dst)
           (Evar M._common_landing_cancels
              (Tfunction (tyMSp :: tptr (Tstruct M._LandingAction noattr)
                          :: tptr (Tfunction (tyMSp :: tuint :: tuint :: nil) tint cc_default)
                          :: nil) tint cc_default))
           (Etempvar M._m tyMSp
            :: Eaddrof (Evar gid (Tstruct M._LandingAction noattr))
                 (tptr (Tstruct M._LandingAction noattr))
            :: Evar sap
                 (Tfunction (tyMSp :: tuint :: tuint :: nil) tint cc_default)
            :: nil))
        tr le' m' out ->
      NoA m -> MWF m -> Mem.valid_block m bm -> action_sat not_tainted m bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\ NoA m'
      /\ out = Out_normal
      /\ (forall b o, le' ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
  Proof.
    intros dst gid sap le m tr le' m' out Hdst Hgid Htat Hexec HN HM HV HS.
    inv Hexec.
    match goal with Hcf : classify_fun _ = _ |- _ => cbn in Hcf; inv Hcf end.
    match goal with Hv : eval_expr _ _ _ _ (Evar _ _) _ |- _ =>
      apply eval_Evar_funct_empty in Hv; destruct Hv as (fb & Hsym & ->) end.
    match goal with Hff : Genv.find_funct _ (Vptr fb Ptrofs.zero) = Some ?fd |- _ =>
      assert (Hres : resolves_lp lp M._common_landing_cancels fd)
        by (exists fb; split; assumption) end.
    match goal with Hel : eval_exprlist _ _ _ _ (_ :: _ :: _ :: nil) _ _ |- _ => inv Hel end.
    match goal with Hv : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
      apply eval_expr_Etempvar_val in Hv; rename Hv into Hv1 end.
    match goal with Hc : sem_cast _ _ _ _ = Some _ |- _ =>
      apply AirborneSurface.sem_cast_ptr_ptr_id in Hc; subst end.
    match goal with Hel : eval_exprlist _ _ _ _ (_ :: _ :: nil) _ _ |- _ => inv Hel end.
    match goal with Hv : eval_expr _ _ _ _ (Eaddrof _ _) _ |- _ => inv Hv;
      [ | match goal with Hlv : eval_lvalue _ _ _ _ (Eaddrof _ _) _ _ _ |- _ => inv Hlv end ] end.
    match goal with Hlv : eval_lvalue _ _ _ _ (Evar gid _) _ _ _ |- _ =>
      apply eval_lvalue_Evar_global_loc in Hlv as [Hfs Hofs]; [ subst | apply PTree.gempty ] end.
    match goal with Hc : sem_cast _ _ _ _ = Some _ |- _ =>
      apply AirborneSurface.sem_cast_ptr_ptr_id in Hc; subst end.
    match goal with Hel : eval_exprlist _ _ _ _ (_ :: nil) _ _ |- _ => inv Hel end.
    match goal with Hel : eval_exprlist _ _ _ _ nil _ _ |- _ => inv Hel end.
    match goal with Hv1 : le ! M._m = Some ?v1 |- _ =>
      assert (Htat1 : forall b o, v1 = Vptr b o -> b = bm /\ o = Ptrofs.zero)
        by (intros b o EE; rewrite EE in Hv1; exact (Htat b o Hv1)) end.
    match goal with
    | Hevf : eval_funcall _ _ _ _ _ _ _ _ |- _ =>
        destruct (clc_marg _ _ _ _ _ _ _ _ _ Hgid Hfs Hres Hevf Htat1 HN HM HV HS)
          as (HV' & HS' & HM' & HN')
    end.
    refine (conj HV' (conj HS' (conj HM' (conj HN' (conj eq_refl _))))).
    intros b o Hg. cbn [set_opttemp] in Hg.
    rewrite PTree.gso in Hg by (exact (fun e => Hdst (eq_sym e))).
    exact (Htat b o Hg).
  Qed.

  (* the cla call site: Scall None of common_landing_action with args
     (Etempvar _m, Econst_int anim, Econst_int 16779404).  Preserves. *)
  Lemma cla_site_pres :
    forall anim act le m tr le' m' out,
      wact_const (Int.repr act) = true ->
      (forall b o, le ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero) ->
      exec_stmt function_entry2 (lp_ge lp) empty_env le m
        (Scall None
           (Evar M._common_landing_action
              (Tfunction (tyMSp :: tshort :: tuint :: nil) tuint cc_default))
           (Etempvar M._m tyMSp
            :: Econst_int (Int.repr anim) tint
            :: Econst_int (Int.repr act) tint :: nil))
        tr le' m' out ->
      NoA m -> MWF m -> Mem.valid_block m bm -> action_sat not_tainted m bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\ NoA m'.
  Proof.
    intros anim act le m tr le' m' out Hact Htat Hexec HN HM HV HS.
    inv Hexec.
    match goal with Hcf : classify_fun _ = _ |- _ => cbn in Hcf; inv Hcf end.
    match goal with Hv : eval_expr _ _ _ _ (Evar _ _) _ |- _ =>
      apply eval_Evar_funct_empty in Hv; destruct Hv as (fb & Hsym & ->) end.
    match goal with Hff : Genv.find_funct _ (Vptr fb Ptrofs.zero) = Some ?fd |- _ =>
      assert (Hres : resolves_lp lp M._common_landing_action fd)
        by (exists fb; split; assumption) end.
    match goal with Hel : eval_exprlist _ _ _ _ (_ :: _ :: _ :: nil) _ _ |- _ => inv Hel end.
    match goal with Hv : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
      apply eval_expr_Etempvar_val in Hv; rename Hv into Hv1 end.
    match goal with Hc : sem_cast _ _ _ _ = Some _ |- _ =>
      apply AirborneSurface.sem_cast_ptr_ptr_id in Hc; subst end.
    match goal with Hel : eval_exprlist _ _ _ _ (_ :: _ :: nil) _ _ |- _ => inv Hel end.
    match goal with Hv : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
      inv Hv; try (match goal with Hlv : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ =>
                     inv Hlv end) end.
    match goal with Hel : eval_exprlist _ _ _ _ (_ :: nil) _ _ |- _ => inv Hel end.
    match goal with Hv : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
      inv Hv; try (match goal with Hlv : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ =>
                     inv Hlv end) end.
    match goal with Hc : sem_cast (Vint (Int.repr act)) _ _ _ = Some _ |- _ =>
      cbn in Hc; injection Hc as <- end.
    match goal with Hel : eval_exprlist _ _ _ _ nil _ _ |- _ => inv Hel end.
    match goal with Hv1 : le ! M._m = Some ?v1 |- _ =>
      assert (Htat1 : forall b o, v1 = Vptr b o -> b = bm /\ o = Ptrofs.zero)
        by (intros b o EE; rewrite EE in Hv1; exact (Htat b o Hv1)) end.
    match goal with
    | Hevf : eval_funcall _ _ _ _ _ _ _ _ |- _ =>
        destruct (cla_funcall_pres _ _ _ _ _ _ _ _ Hres Hevf Htat1
                    (wact_const_sound _ Hact)
                    HN HM HV HS)
          as (HV' & HS' & HM' & HN')
    end.
    exact (conj HV' (conj HS' (conj HM' HN'))).
  Qed.

  (* ================================================================== *)
  (* LANDING KEYSTONE, part 3: the INPUT-STORE leaves (triple_jump,       *)
  (* backflip, long_jump).  Each opens with an input-clear store          *)
  (*   m->input &= ~INPUT_B_PRESSED;   (some guarded by !(input&0x4000))   *)
  (* then the clc/if template, then an OPTIONAL play_sound_if_no_flag      *)
  (* (gated on !(input&1)), then cla (long_jump's anim is a chase-derived  *)
  (* temp instead of a const).                                            *)
  (* ================================================================== *)

  Lemma inp_field_off :
    field_offset (prog_comp_env mario.prog) M._input mario_state_members
      = OK (2, Full).
  Proof. vm_compute. reflexivity. Qed.

  (* set-inversion that EXPOSES the rhs eval_expr (needed for the input load). *)
  Lemma p_exec_set_inv :
    forall e le m id a tr le' m' out,
      exec_stmt function_entry2 (lp_ge lp) e le m (Sset id a) tr le' m' out ->
      exists v, eval_expr (lp_ge lp) e le m a v /\ m' = m /\
                le' = PTree.set id v le /\ out = Out_normal.
  Proof. intros; match goal with H : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => inv H end;
           eauto. Qed.

  (* the m->input &= mask pair: Sset t (m->input); m->input = t & mask.
     mask of type tint, arbitrary; the loaded input is A-clear (HMWF_inp), so
     the masked store keeps INPUT_A_PRESSED clear (and2_and_left) and the
     offset-2 store misses both the action cell [12,16) and never forges a
     pointer -- preserving the carried run facts + the _m tat. *)
  Lemma inp_aclear_pair_pres :
    forall t mexpr le m tr le' m' out,
      t <> M._m ->
      typeof mexpr = tint ->
      (forall b o, le ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero) ->
      exec_stmt function_entry2 (lp_ge lp) empty_env le m
        (Ssequence
           (Sset t (Efield (Ederef (Etempvar M._m tyMSp)
                      (Tstruct M._MarioState noattr)) M._input tushort))
           (Sassign (Efield (Ederef (Etempvar M._m tyMSp)
                       (Tstruct M._MarioState noattr)) M._input tushort)
              (Ebinop Oand (Etempvar t tushort) mexpr tint)))
        tr le' m' out ->
      NoA m -> MWF m -> Mem.valid_block m bm -> action_sat not_tainted m bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\ NoA m'
      /\ out = Out_normal
      /\ (forall b o, le' ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
  Proof.
    intros t mexpr le m tr le' m' out Hne Htype Htat Hexec HN HM HV HS.
    apply lnd_exec_seq_cases in Hexec
      as [ (tr1 & le1 & m1 & tr2 & HSet & HAsn) | (HSet & Hnn) ].
    2:{ apply lnd_exec_set_inv in HSet as (_ & Ho & _). congruence. }
    apply p_exec_set_inv in HSet as (v & Hevset & -> & -> & _).
    (* ---- load half: extract le!_m = (bm,0) and HldInput ---- *)
    destruct (eval_expr_Efield_load _ _ _ _ _ _ _ _ Hevset)
      as (loc & ofs & bf & Hlv & Hd).
    pose proof Hlv as Hbase0.
    apply eval_lvalue_Efield_base in Hbase0. destruct Hbase0 as (oo0 & Hbase).
    apply eval_expr_Ederef_load in Hbase. destruct Hbase as (lb & ob & bfb & Hlvb & _).
    apply eval_lvalue_Ederef_base in Hlvb. apply eval_expr_Etempvar_val in Hlvb.
    pose proof Hlvb as Hle_m.
    destruct (Htat _ _ Hlvb) as [E1 E2]. subst lb ob.
    destruct (mfield_lvalue_geom_lp lp LO_mario _ _ _ _ _ _
                loc ofs bf _ _ _ Hlvb inp_field_off Hlv) as (E3 & E4 & E5).
    subst loc ofs bf. clear Hlv.
    inv Hd.
    2:{ match goal with Hac : access_mode _ = By_reference |- _ =>
          cbn in Hac; discriminate Hac end. }
    2:{ match goal with Hac : access_mode _ = By_copy |- _ =>
          cbn in Hac; discriminate Hac end. }
    match goal with Hac : access_mode _ = By_value _ |- _ =>
      cbn in Hac; injection Hac as <- end.
    match goal with Hldv : Mem.loadv _ _ _ = Some _ |- _ =>
      unfold Mem.loadv in Hldv;
      change (Ptrofs.unsigned (Ptrofs.add Ptrofs.zero (Ptrofs.repr 2))) with 2 in Hldv;
      rename Hldv into HldInput end.
    (* ---- store half ---- *)
    inv HAsn.
    match goal with Hlv2 : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ =>
      pose proof Hlv2 as Hbase2; apply eval_lvalue_Efield_base in Hbase2;
      destruct Hbase2 as (oo2 & Hbase2'); apply eval_expr_Ederef_load in Hbase2';
      destruct Hbase2' as (lb2 & ob2 & bfb2 & Hlvb2 & _);
      apply eval_lvalue_Ederef_base in Hlvb2; apply eval_expr_Etempvar_val in Hlvb2 end.
    pose proof Hlvb2 as Hm0.
    rewrite PTree.gso in Hm0 by (exact (fun e => Hne (eq_sym e))).
    destruct (Htat _ _ Hm0) as [F1 F2]. subst lb2 ob2.
    match goal with Hlv2 : eval_lvalue _ _ _ _ (Efield _ _ _) ?loc2 ?ofs2 ?bf2 |- _ =>
      destruct (mfield_lvalue_geom_lp lp LO_mario _ _ _ _ _ _
                  loc2 ofs2 bf2 _ _ _ Hlvb2 inp_field_off Hlv2) as (F3 & F4 & F5);
      subst loc2 ofs2 bf2 end.
    (* rhs: t & mexpr -> Vint (vi & mv) with le1!t = Vint vi *)
    match goal with Hev2 : eval_expr _ _ _ _ (Ebinop Oand _ _ _) _ |- _ =>
      assert (HH := Hev2) end.
    destruct (and_temp_form lp _ _ _ _ _ _ Htype HH) as (vi & mv & Hlet & ->). clear HH.
    rewrite PTree.gss in Hlet. injection Hlet as Hv. subst v.
    pose proof (HMWF_inp _ HM _ HldInput) as Hvi2.
    (* cast i32 -> u16 = zero_ext 16 *)
    match goal with Hcast : sem_cast _ _ _ _ = Some _ |- _ =>
      cbn [typeof] in Hcast; unfold sem_cast in Hcast;
      cbn [classify_cast cast_int_int] in Hcast; injection Hcast as <- end.
    (* the store at (bm,2) *)
    match goal with Has : assign_loc _ _ _ _ _ _ _ m' |- _ => inv Has end;
      try (match goal with Hac : access_mode _ = By_copy |- _ =>
             cbn in Hac; discriminate Hac end).
    match goal with Hac : access_mode _ = By_value _ |- _ => cbn in Hac; injection Hac as <- end.
    match goal with Hsv : Mem.storev _ _ _ _ = Some m' |- _ =>
      unfold Mem.storev in Hsv;
      change (Ptrofs.unsigned (Ptrofs.add Ptrofs.zero (Ptrofs.repr 2))) with 2 in Hsv;
      rename Hsv into Hst end.
    assert (Hst2 : Int.and (Int.zero_ext 16 (Int.and vi mv)) (Int.repr 2) = Int.zero)
      by (rewrite and2_zero_ext16; apply and2_and_left; exact Hvi2).
    split; [ exact (Mem.store_valid_block_1 _ _ _ _ _ _ Hst _ HV) | ].
    split;
      [ intros av Hload;
        rewrite (Mem.load_store_other _ _ _ _ _ _ Hst) in Hload;
        [ exact (HS av Hload) | right; right; cbn; lia ] | ].
    split; [ exact (HMWF_input _ _ _ HM Hst2 Hst) | ].
    split; [ exact (HNoA_of_MWF _ (HMWF_input _ _ _ HM Hst2 Hst)) | ].
    split; [ reflexivity | ].
    intros b o Hg. rewrite PTree.gso in Hg by (exact (fun e => Hne (eq_sym e))).
    exact (Htat b o Hg).
  Qed.

  (* the guarded form: Sset tg (m->input); if cond { input pair on tw } else skip.
     (backflip/long_jump guard the input clear on !(input & 0x4000).) *)
  Lemma guarded_input_pres :
    forall tg tw cond le m tr le' m' out,
      tg <> M._m -> tw <> M._m ->
      (forall b o, le ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero) ->
      exec_stmt function_entry2 (lp_ge lp) empty_env le m
        (Ssequence
           (Sset tg (Efield (Ederef (Etempvar M._m tyMSp)
                      (Tstruct M._MarioState noattr)) M._input tushort))
           (Sifthenelse cond
              (Ssequence
                 (Sset tw (Efield (Ederef (Etempvar M._m tyMSp)
                            (Tstruct M._MarioState noattr)) M._input tushort))
                 (Sassign (Efield (Ederef (Etempvar M._m tyMSp)
                             (Tstruct M._MarioState noattr)) M._input tushort)
                    (Ebinop Oand (Etempvar tw tushort)
                       (Eunop Onotint (Econst_int (Int.repr 2) tint) tint) tint)))
              Sskip))
        tr le' m' out ->
      NoA m -> MWF m -> Mem.valid_block m bm -> action_sat not_tainted m bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\ NoA m'
      /\ out = Out_normal
      /\ (forall b o, le' ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
  Proof.
    intros tg tw cond le m tr le' m' out Hg Hw Htat Hexec HN HM HV HS.
    apply lnd_exec_seq_cases in Hexec
      as [ (tr1 & le1 & m1 & tr2 & Hset & Hif) | (Hset & Hne) ].
    2:{ exfalso. apply Hne. apply lnd_exec_set_inv in Hset as (_ & -> & _). reflexivity. }
    apply lnd_exec_set_inv in Hset as (-> & _ & vg & ->).
    assert (Htatg : forall b o,
       (PTree.set tg vg le) ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
    { intros b o Hgg. rewrite PTree.gso in Hgg by (exact (fun e => Hg (eq_sym e))).
      exact (Htat b o Hgg). }
    apply lnd_exec_if_inv in Hif as [bb Hif].
    destruct bb.
    - destruct (inp_aclear_pair_pres tw
                  (Eunop Onotint (Econst_int (Int.repr 2) tint) tint)
                  _ _ _ _ _ _ Hw eq_refl Htatg Hif HN HM HV HS)
        as (HV' & HS' & HM' & HN' & Ho & Htat').
      exact (conj HV' (conj HS' (conj HM' (conj HN' (conj Ho Htat'))))).
    - apply lnd_exec_skip_inv in Hif as (-> & -> & ->).
      exact (conj HV (conj HS (conj HM (conj HN (conj eq_refl Htatg))))).
  Qed.

  (* n-ary Mario-head call at the empty env: the TAIL is arbitrary (marg_ok
     constrains only the head; eval_exprlist is pure).  Mirrors
     ActWriterSurface.kit_scalln_pres but instantiated for this section. *)
  Lemma mhead_scall_pres :
    forall optid fid tys rty cc args le0 m0 tr le1 m1 out0,
      call_pres lp bm NoA MWF fid ->
      exec_stmt function_entry2 (lp_ge lp) empty_env le0 m0
        (Scall optid (Evar fid (Tfunction (tyMSp :: tys) rty cc))
           (Etempvar M._m tyMSp :: args))
        tr le1 m1 out0 ->
      (forall b o, le0 ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero) ->
      NoA m0 -> MWF m0 -> Mem.valid_block m0 bm -> action_sat not_tainted m0 bm ->
      Mem.valid_block m1 bm /\ action_sat not_tainted m1 bm /\
      MWF m1 /\ NoA m1 /\ out0 = Out_normal /\
      exists vr, le1 = set_opttemp optid vr le0.
  Proof.
    intros optid fid tys rty cc args le0 m0 tr le1 m1 out0 Hcp Hexec Htat HN HM HV HS.
    inv Hexec.
    match goal with Hcf : classify_fun _ = _ |- _ => cbn in Hcf; inv Hcf end.
    match goal with Hv : eval_expr _ _ _ _ (Evar _ _) _ |- _ =>
      apply eval_Evar_funct_empty in Hv; destruct Hv as (fb & Hsym & ->) end.
    match goal with Hff : Genv.find_funct _ (Vptr fb Ptrofs.zero) = Some ?fd |- _ =>
      assert (Hres : resolves_lp lp fid fd) by (exists fb; split; assumption) end.
    match goal with Hel : eval_exprlist _ _ _ _ (_ :: _) _ _ |- _ => inv Hel end.
    match goal with Hv : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
      apply eval_expr_Etempvar_val in Hv; rename Hv into Hv1 end.
    match goal with Hc : sem_cast _ _ _ _ = Some _ |- _ =>
      apply AirborneSurface.sem_cast_ptr_ptr_id in Hc; subst end.
    match goal with
    | Hv1' : le0 ! _ = Some ?vv, Hevf : eval_funcall _ _ _ _ (?vv :: ?vrest) _ _ _ |- _ =>
        assert (Hmarg : marg_ok bm (vv :: vrest))
          by (unfold marg_ok; destruct vv as [| | | | | bb oo]; auto;
              exact (Htat _ _ Hv1')) end.
    match goal with Hevf : eval_funcall _ _ _ _ (_ :: _) _ _ _ |- _ =>
      destruct (Hcp _ _ _ _ _ _ Hevf Hres Hmarg HN HM HV HS)
        as (HV' & HS' & HM' & HN') end.
    refine (conj HV' (conj HS' (conj HM' (conj HN' (conj eq_refl _))))).
    eexists; reflexivity.
  Qed.

  (* the optional play_sound block: Sset tg (m->input); if cond { psinf(...) }.
     The middle play-sound argument is arbitrary (the big OR flag expr). *)
  Lemma psinf_block_pres :
    forall tg cond arg le m tr le' m' out,
      tg <> M._m ->
      (forall b o, le ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero) ->
      exec_stmt function_entry2 (lp_ge lp) empty_env le m
        (Ssequence
           (Sset tg (Efield (Ederef (Etempvar M._m tyMSp)
                      (Tstruct M._MarioState noattr)) M._input tushort))
           (Sifthenelse cond
              (Scall None
                 (Evar M._play_sound_if_no_flag
                    (Tfunction (tyMSp :: tuint :: tuint :: nil) tvoid cc_default))
                 (Etempvar M._m tyMSp :: arg
                  :: Econst_int (Int.repr 131072) tint :: nil))
              Sskip))
        tr le' m' out ->
      NoA m -> MWF m -> Mem.valid_block m bm -> action_sat not_tainted m bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\ NoA m'
      /\ out = Out_normal
      /\ (forall b o, le' ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
  Proof.
    intros tg cond arg le m tr le' m' out Hg Htat Hexec HN HM HV HS.
    apply lnd_exec_seq_cases in Hexec
      as [ (tr1 & le1 & m1 & tr2 & Hset & Hif) | (Hset & Hne) ].
    2:{ exfalso. apply Hne. apply lnd_exec_set_inv in Hset as (_ & -> & _). reflexivity. }
    apply lnd_exec_set_inv in Hset as (-> & _ & vg & ->).
    assert (Htatg : forall b o,
       (PTree.set tg vg le) ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
    { intros b o Hgg. rewrite PTree.gso in Hgg by (exact (fun e => Hg (eq_sym e))).
      exact (Htat b o Hgg). }
    apply lnd_exec_if_inv in Hif as [bb Hif].
    destruct bb.
    - destruct (mhead_scall_pres None M._play_sound_if_no_flag
                  (tuint :: tuint :: nil) tvoid cc_default
                  (arg :: Econst_int (Int.repr 131072) tint :: nil)
                  _ _ _ _ _ _ Hpsinf Hif Htatg HN HM HV HS)
        as (HV' & HS' & HM' & HN' & Ho & vr & Hle).
      cbn [set_opttemp] in Hle. subst le'.
      exact (conj HV' (conj HS' (conj HM' (conj HN' (conj Ho Htatg))))).
    - apply lnd_exec_skip_inv in Hif as (-> & -> & ->).
      exact (conj HV (conj HS (conj HM (conj HN (conj eq_refl Htatg))))).
  Qed.

  (* cla with an ARBITRARY anim expression (long_jump's anim is the chase-
     derived temp _t'2, not a const).  Only the 3rd arg (the action const)
     is constrained -- untainted. *)
  Lemma cla_site_pres_e :
    forall animexpr act le m tr le' m' out,
      wact_const (Int.repr act) = true ->
      (forall b o, le ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero) ->
      exec_stmt function_entry2 (lp_ge lp) empty_env le m
        (Scall None
           (Evar M._common_landing_action
              (Tfunction (tyMSp :: tshort :: tuint :: nil) tuint cc_default))
           (Etempvar M._m tyMSp :: animexpr
            :: Econst_int (Int.repr act) tint :: nil))
        tr le' m' out ->
      NoA m -> MWF m -> Mem.valid_block m bm -> action_sat not_tainted m bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\ NoA m'.
  Proof.
    intros animexpr act le m tr le' m' out Hact Htat Hexec HN HM HV HS.
    inv Hexec.
    match goal with Hcf : classify_fun _ = _ |- _ => cbn in Hcf; inv Hcf end.
    match goal with Hv : eval_expr _ _ _ _ (Evar _ _) _ |- _ =>
      apply eval_Evar_funct_empty in Hv; destruct Hv as (fb & Hsym & ->) end.
    match goal with Hff : Genv.find_funct _ (Vptr fb Ptrofs.zero) = Some ?fd |- _ =>
      assert (Hres : resolves_lp lp M._common_landing_action fd)
        by (exists fb; split; assumption) end.
    match goal with Hel : eval_exprlist _ _ _ _ (Etempvar _ _ :: _) _ _ |- _ => inv Hel end.
    match goal with Hv : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
      apply eval_expr_Etempvar_val in Hv; rename Hv into Hv1 end.
    match goal with Hc : sem_cast _ _ _ _ = Some _ |- _ =>
      apply AirborneSurface.sem_cast_ptr_ptr_id in Hc; subst end.
    match goal with Hel : eval_exprlist _ _ _ _ (animexpr :: _) _ _ |- _ => inv Hel end.
    match goal with Hel : eval_exprlist _ _ _ _ (Econst_int _ _ :: nil) _ _ |- _ => inv Hel end.
    match goal with Hv : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
      inv Hv; try (match goal with Hlv : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ =>
                     inv Hlv end) end.
    match goal with Hc : sem_cast (Vint (Int.repr act)) _ _ _ = Some _ |- _ =>
      cbn in Hc; injection Hc as <- end.
    match goal with Hel : eval_exprlist _ _ _ _ nil _ _ |- _ => inv Hel end.
    match goal with Hv1 : le ! M._m = Some ?v1 |- _ =>
      assert (Htat1 : forall b o, v1 = Vptr b o -> b = bm /\ o = Ptrofs.zero)
        by (intros b o EE; rewrite EE in Hv1; exact (Htat b o Hv1)) end.
    match goal with
    | Hevf : eval_funcall _ _ _ _ _ _ _ _ |- _ =>
        destruct (cla_funcall_pres _ _ _ _ _ _ _ _ Hres Hevf Htat1
                    (wact_const_sound _ Hact) HN HM HV HS)
          as (HV' & HS' & HM' & HN')
    end.
    exact (conj HV' (conj HS' (conj HM' HN'))).
  Qed.

  (* long_jump's animation-select block: 3 temp sets (marioObj chase-load of
     rawData.asS32[34], then anim := 17/18) -- NO memory write.  Preserves. *)
  Lemma animsel_pres :
    forall e3 e4 e2t e2f cond le m tr le' m' out,
      (forall b o, le ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero) ->
      exec_stmt function_entry2 (lp_ge lp) empty_env le m
        (Ssequence (Sset M._t'3 e3)
          (Ssequence (Sset M._t'4 e4)
            (Sifthenelse cond (Sset M._t'2 e2t) (Sset M._t'2 e2f))))
        tr le' m' out ->
      NoA m -> MWF m -> Mem.valid_block m bm -> action_sat not_tainted m bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\ NoA m'
      /\ out = Out_normal
      /\ (forall b o, le' ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
  Proof.
    intros e3 e4 e2t e2f cond le m tr le' m' out Htat Hexec HN HM HV HS.
    apply lnd_exec_seq_cases in Hexec
      as [ (tr1 & le1 & m1 & tr2 & Hs3 & Hr) | (Hs3 & Hne) ].
    2:{ exfalso. apply Hne. apply lnd_exec_set_inv in Hs3 as (_ & -> & _). reflexivity. }
    apply lnd_exec_set_inv in Hs3 as (-> & _ & v3 & ->).
    apply lnd_exec_seq_cases in Hr
      as [ (tr3 & le2 & m2 & tr4 & Hs4 & Hif) | (Hs4 & Hne) ].
    2:{ exfalso. apply Hne. apply lnd_exec_set_inv in Hs4 as (_ & -> & _). reflexivity. }
    apply lnd_exec_set_inv in Hs4 as (-> & _ & v4 & ->).
    assert (Htat2 : forall b o,
       (PTree.set M._t'4 v4 (PTree.set M._t'3 v3 le)) ! M._m = Some (Vptr b o) ->
       b = bm /\ o = Ptrofs.zero).
    { intros b o Hg. rewrite PTree.gso in Hg by (vm_compute; congruence).
      rewrite PTree.gso in Hg by (vm_compute; congruence). exact (Htat b o Hg). }
    apply lnd_exec_if_inv in Hif as [bb Hif]; destruct bb;
      apply lnd_exec_set_inv in Hif as (-> & -> & v2 & ->);
      (refine (conj HV (conj HS (conj HM (conj HN (conj eq_refl _)))));
       intros b o Hg; rewrite PTree.gso in Hg by (vm_compute; congruence);
       exact (Htat2 b o Hg)).
  Qed.

  Example mov_jland_pin :
    (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._act_jump_land
    = Some (Gfun (Internal mario_actions_moving.f_act_jump_land)).
  Proof. vm_compute. reflexivity. Qed.
  Example mov_ffland_pin :
    (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._act_freefall_land
    = Some (Gfun (Internal mario_actions_moving.f_act_freefall_land)).
  Proof. vm_compute. reflexivity. Qed.
  Example mov_djland_pin :
    (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._act_double_jump_land
    = Some (Gfun (Internal mario_actions_moving.f_act_double_jump_land)).
  Proof. vm_compute. reflexivity. Qed.

  Lemma mov_jland_pres : body_pres lp NoA MWF bm M.f_act_jump_land.
  Proof.
    intros m vargs t mEnd vres Hmarg Hevf HN HM HV HS.
    assert (Hmarg' : marg_ok bm vargs) by (apply Hmarg; vm_compute; reflexivity).
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry end.
    match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody end.
    match goal with Hf : Mem.free_list _ _ = Some _ |- _ => rename Hf into Hfree end.
    inv Hentry.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
      change (fn_vars M.f_act_jump_land) with (@nil (ident * type)) in Ha; inv Ha end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ => rename Hb into Hbind end.
    change (fn_params M.f_act_jump_land) with ((M._m, tyMSp) :: nil) in Hbind.
    cbn [bind_parameter_temps] in Hbind.
    destruct vargs as [| vhead vrest]; [ discriminate Hbind | ].
    destruct vrest as [|]; [ | discriminate Hbind ].
    injection Hbind as <-.
    change (blocks_of_env (lp_ge lp) empty_env) with (@nil (block * Z * Z)) in Hfree.
    cbn [Mem.free_list] in Hfree. injection Hfree as <-.
    set (base := create_undef_temps (fn_temps M.f_act_jump_land)) in *.
    assert (Htat : forall b o,
       (PTree.set M._m vhead base) ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
    { intros b o Hg. rewrite PTree.gss in Hg. injection Hg as Hvh.
      rewrite Hvh in Hmarg'. cbn in Hmarg'. exact Hmarg'. }
    unfold M.f_act_jump_land in Hbody; cbn [fn_body] in Hbody.
    apply lnd_exec_seq_cases in Hbody
      as [ (trF & leF & mF & trS & Hfirst & Hsecond) | (Hfirst & Hne) ].
    - apply lnd_exec_seq_cases in Hfirst
        as [ (trA & leA & mA & trB & Hclc_c & Hif) | (Hclc_c & Hne0) ].
      2:{ exfalso. apply Hne0. inv Hclc_c. reflexivity. }
      destruct (clc_site_pres M._t'1 mario_actions_moving._sJumpLandAction
                  _ _ _ _ _ _ _ ltac:(vm_compute; congruence)
                  ltac:(vm_compute; reflexivity) Htat Hclc_c HN HM HV HS)
        as (HVa & HSa & HMa & HNa & _ & Htat_a).
      apply lnd_exec_if_inv in Hif as [bb Hif].
      destruct bb.
      + apply lnd_exec_return_inv in Hif as (_ & _ & Hne1). congruence.
      + apply lnd_exec_skip_inv in Hif as (-> & -> & _).
        apply lnd_exec_seq_cases in Hsecond
          as [ (trC & leC & mC & trD & Hcla_c & Hret) | (Hcla_c & Hne2) ].
        * destruct (cla_site_pres 78 16779404 _ _ _ _ _ _
            ltac:(vm_compute; reflexivity) Htat_a Hcla_c HNa HMa HVa HSa)
            as (HVc & HSc & HMc & HNc).
          apply lnd_exec_return_inv in Hret as (_ & -> & _).
          exact (conj HVc (conj HSc HMc)).
        * destruct (cla_site_pres 78 16779404 _ _ _ _ _ _
            ltac:(vm_compute; reflexivity) Htat_a Hcla_c HNa HMa HVa HSa)
            as (HVc & HSc & HMc & HNc).
          exact (conj HVc (conj HSc HMc)).
    - apply lnd_exec_seq_cases in Hfirst
        as [ (trA & leA & mA & trB & Hclc_c & Hif) | (Hclc_c & Hne0) ].
      2:{ exfalso. apply Hne0. inv Hclc_c. reflexivity. }
      destruct (clc_site_pres M._t'1 mario_actions_moving._sJumpLandAction
                  _ _ _ _ _ _ _ ltac:(vm_compute; congruence)
                  ltac:(vm_compute; reflexivity) Htat Hclc_c HN HM HV HS)
        as (HVa & HSa & HMa & HNa & _ & _).
      apply lnd_exec_if_inv in Hif as [bb Hif].
      destruct bb.
      + apply lnd_exec_return_inv in Hif as (_ & -> & _).
        exact (conj HVa (conj HSa HMa)).
      + apply lnd_exec_skip_inv in Hif as (_ & -> & Hnn). congruence.
  Qed.

  Lemma mov_ffland_pres : body_pres lp NoA MWF bm M.f_act_freefall_land.
  Proof.
    intros m vargs t mEnd vres Hmarg Hevf HN HM HV HS.
    assert (Hmarg' : marg_ok bm vargs) by (apply Hmarg; vm_compute; reflexivity).
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry end.
    match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody end.
    match goal with Hf : Mem.free_list _ _ = Some _ |- _ => rename Hf into Hfree end.
    inv Hentry.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
      change (fn_vars M.f_act_freefall_land) with (@nil (ident * type)) in Ha; inv Ha end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ => rename Hb into Hbind end.
    change (fn_params M.f_act_freefall_land) with ((M._m, tyMSp) :: nil) in Hbind.
    cbn [bind_parameter_temps] in Hbind.
    destruct vargs as [| vhead vrest]; [ discriminate Hbind | ].
    destruct vrest as [|]; [ | discriminate Hbind ].
    injection Hbind as <-.
    change (blocks_of_env (lp_ge lp) empty_env) with (@nil (block * Z * Z)) in Hfree.
    cbn [Mem.free_list] in Hfree. injection Hfree as <-.
    set (base := create_undef_temps (fn_temps M.f_act_freefall_land)) in *.
    assert (Htat : forall b o,
       (PTree.set M._m vhead base) ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
    { intros b o Hg. rewrite PTree.gss in Hg. injection Hg as Hvh.
      rewrite Hvh in Hmarg'. cbn in Hmarg'. exact Hmarg'. }
    unfold M.f_act_freefall_land in Hbody; cbn [fn_body] in Hbody.
    apply lnd_exec_seq_cases in Hbody
      as [ (trF & leF & mF & trS & Hfirst & Hsecond) | (Hfirst & Hne) ].
    - apply lnd_exec_seq_cases in Hfirst
        as [ (trA & leA & mA & trB & Hclc_c & Hif) | (Hclc_c & Hne0) ].
      2:{ exfalso. apply Hne0. inv Hclc_c. reflexivity. }
      destruct (clc_site_pres M._t'1 mario_actions_moving._sFreefallLandAction
                  _ _ _ _ _ _ _ ltac:(vm_compute; congruence)
                  ltac:(vm_compute; reflexivity) Htat Hclc_c HN HM HV HS)
        as (HVa & HSa & HMa & HNa & _ & Htat_a).
      apply lnd_exec_if_inv in Hif as [bb Hif].
      destruct bb.
      + apply lnd_exec_return_inv in Hif as (_ & _ & Hne1). congruence.
      + apply lnd_exec_skip_inv in Hif as (-> & -> & _).
        apply lnd_exec_seq_cases in Hsecond
          as [ (trC & leC & mC & trD & Hcla_c & Hret) | (Hcla_c & Hne2) ].
        * destruct (cla_site_pres 87 16779404 _ _ _ _ _ _
            ltac:(vm_compute; reflexivity) Htat_a Hcla_c HNa HMa HVa HSa)
            as (HVc & HSc & HMc & HNc).
          apply lnd_exec_return_inv in Hret as (_ & -> & _).
          exact (conj HVc (conj HSc HMc)).
        * destruct (cla_site_pres 87 16779404 _ _ _ _ _ _
            ltac:(vm_compute; reflexivity) Htat_a Hcla_c HNa HMa HVa HSa)
            as (HVc & HSc & HMc & HNc).
          exact (conj HVc (conj HSc HMc)).
    - apply lnd_exec_seq_cases in Hfirst
        as [ (trA & leA & mA & trB & Hclc_c & Hif) | (Hclc_c & Hne0) ].
      2:{ exfalso. apply Hne0. inv Hclc_c. reflexivity. }
      destruct (clc_site_pres M._t'1 mario_actions_moving._sFreefallLandAction
                  _ _ _ _ _ _ _ ltac:(vm_compute; congruence)
                  ltac:(vm_compute; reflexivity) Htat Hclc_c HN HM HV HS)
        as (HVa & HSa & HMa & HNa & _ & _).
      apply lnd_exec_if_inv in Hif as [bb Hif].
      destruct bb.
      + apply lnd_exec_return_inv in Hif as (_ & -> & _).
        exact (conj HVa (conj HSa HMa)).
      + apply lnd_exec_skip_inv in Hif as (_ & -> & Hnn). congruence.
  Qed.

  Lemma mov_djland_pres : body_pres lp NoA MWF bm M.f_act_double_jump_land.
  Proof.
    intros m vargs t mEnd vres Hmarg Hevf HN HM HV HS.
    assert (Hmarg' : marg_ok bm vargs) by (apply Hmarg; vm_compute; reflexivity).
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry end.
    match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody end.
    match goal with Hf : Mem.free_list _ _ = Some _ |- _ => rename Hf into Hfree end.
    inv Hentry.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
      change (fn_vars M.f_act_double_jump_land) with (@nil (ident * type)) in Ha; inv Ha end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ => rename Hb into Hbind end.
    change (fn_params M.f_act_double_jump_land) with ((M._m, tyMSp) :: nil) in Hbind.
    cbn [bind_parameter_temps] in Hbind.
    destruct vargs as [| vhead vrest]; [ discriminate Hbind | ].
    destruct vrest as [|]; [ | discriminate Hbind ].
    injection Hbind as <-.
    change (blocks_of_env (lp_ge lp) empty_env) with (@nil (block * Z * Z)) in Hfree.
    cbn [Mem.free_list] in Hfree. injection Hfree as <-.
    set (base := create_undef_temps (fn_temps M.f_act_double_jump_land)) in *.
    assert (Htat : forall b o,
       (PTree.set M._m vhead base) ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
    { intros b o Hg. rewrite PTree.gss in Hg. injection Hg as Hvh.
      rewrite Hvh in Hmarg'. cbn in Hmarg'. exact Hmarg'. }
    unfold M.f_act_double_jump_land in Hbody; cbn [fn_body] in Hbody.
    apply lnd_exec_seq_cases in Hbody
      as [ (trF & leF & mF & trS & Hfirst & Hsecond) | (Hfirst & Hne) ].
    - apply lnd_exec_seq_cases in Hfirst
        as [ (trA & leA & mA & trB & Hclc_c & Hif) | (Hclc_c & Hne0) ].
      2:{ exfalso. apply Hne0. inv Hclc_c. reflexivity. }
      destruct (clc_site_pres M._t'1 mario_actions_moving._sDoubleJumpLandAction
                  _ _ _ _ _ _ _ ltac:(vm_compute; congruence)
                  ltac:(vm_compute; reflexivity) Htat Hclc_c HN HM HV HS)
        as (HVa & HSa & HMa & HNa & _ & Htat_a).
      apply lnd_exec_if_inv in Hif as [bb Hif].
      destruct bb.
      + apply lnd_exec_return_inv in Hif as (_ & _ & Hne1). congruence.
      + apply lnd_exec_skip_inv in Hif as (-> & -> & _).
        apply lnd_exec_seq_cases in Hsecond
          as [ (trC & leC & mC & trD & Hcla_c & Hret) | (Hcla_c & Hne2) ].
        * destruct (cla_site_pres 75 16779404 _ _ _ _ _ _
            ltac:(vm_compute; reflexivity) Htat_a Hcla_c HNa HMa HVa HSa)
            as (HVc & HSc & HMc & HNc).
          apply lnd_exec_return_inv in Hret as (_ & -> & _).
          exact (conj HVc (conj HSc HMc)).
        * destruct (cla_site_pres 75 16779404 _ _ _ _ _ _
            ltac:(vm_compute; reflexivity) Htat_a Hcla_c HNa HMa HVa HSa)
            as (HVc & HSc & HMc & HNc).
          exact (conj HVc (conj HSc HMc)).
    - apply lnd_exec_seq_cases in Hfirst
        as [ (trA & leA & mA & trB & Hclc_c & Hif) | (Hclc_c & Hne0) ].
      2:{ exfalso. apply Hne0. inv Hclc_c. reflexivity. }
      destruct (clc_site_pres M._t'1 mario_actions_moving._sDoubleJumpLandAction
                  _ _ _ _ _ _ _ ltac:(vm_compute; congruence)
                  ltac:(vm_compute; reflexivity) Htat Hclc_c HN HM HV HS)
        as (HVa & HSa & HMa & HNa & _ & _).
      apply lnd_exec_if_inv in Hif as [bb Hif].
      destruct bb.
      + apply lnd_exec_return_inv in Hif as (_ & -> & _).
        exact (conj HVa (conj HSa HMa)).
      + apply lnd_exec_skip_inv in Hif as (_ & -> & Hnn). congruence.
  Qed.

  (* ================================================================== *)
  (* LANDING KEYSTONE, part 2: the HOLD _land leaves (hold_jump,         *)
  (* hold_freefall).  Each opens with a leading drop-held-object block   *)
  (*   t3 = m->marioObj; t4 = t3->oInteractStatus;                       *)
  (*   if (t4 & INT_STATUS_MARIO_DROP_OBJECT)                            *)
  (*       return drop_and_set_mario_action(m, ACT_*_LAND_STOP, 0);      *)
  (* (a chase-temp READ pair -- m unchanged -- + an UNTAINTED drop call  *)
  (*  lifted by Hdasma), then the same clc/cla template as the clean     *)
  (* leaves (clc result temp is _t'2 here, not _t'1).                    *)
  (* ================================================================== *)

  (* drop_and_set_mario_action(m, UNTAINTED_CONST, 0) -> _t'1. *)
  Lemma dasma_site_pres :
    forall dconst le m tr le' m' out,
      wact_const (Int.repr dconst) = true ->
      (forall b o, le ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero) ->
      exec_stmt function_entry2 (lp_ge lp) empty_env le m
        (Scall (Some M._t'1)
           (Evar M._drop_and_set_mario_action
              (Tfunction (tyMSp :: tuint :: tuint :: nil) tint cc_default))
           (Etempvar M._m tyMSp
            :: Econst_int (Int.repr dconst) tint
            :: Econst_int (Int.repr 0) tint :: nil))
        tr le' m' out ->
      NoA m -> MWF m -> Mem.valid_block m bm -> action_sat not_tainted m bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\ NoA m'
      /\ out = Out_normal
      /\ (forall b o, le' ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
  Proof.
    intros dconst le m tr le' m' out Hdconst Htat Hexec HN HM HV HS.
    inv Hexec.
    match goal with Hcf : classify_fun _ = _ |- _ => cbn in Hcf; inv Hcf end.
    match goal with Hv : eval_expr _ _ _ _ (Evar _ _) _ |- _ =>
      apply eval_Evar_funct_empty in Hv; destruct Hv as (fb & Hsym & ->) end.
    match goal with Hff : Genv.find_funct _ (Vptr fb Ptrofs.zero) = Some ?fd |- _ =>
      assert (Hres : resolves_lp lp M._drop_and_set_mario_action fd)
        by (exists fb; split; assumption) end.
    match goal with Hel : eval_exprlist _ _ _ _ (_ :: _ :: _ :: nil) _ _ |- _ => inv Hel end.
    match goal with Hv : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
      apply eval_expr_Etempvar_val in Hv; rename Hv into Hv1 end.
    match goal with Hc : sem_cast _ _ _ _ = Some _ |- _ =>
      apply AirborneSurface.sem_cast_ptr_ptr_id in Hc; subst end.
    match goal with Hel : eval_exprlist _ _ _ _ (_ :: _ :: nil) _ _ |- _ => inv Hel end.
    match goal with Hv : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
      inv Hv; try (match goal with Hlv : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ =>
                     inv Hlv end) end.
    match goal with Hc : sem_cast (Vint (Int.repr dconst)) _ _ _ = Some _ |- _ =>
      cbn in Hc; injection Hc as <- end.
    match goal with Hel : eval_exprlist _ _ _ _ (_ :: nil) _ _ |- _ => inv Hel end.
    match goal with Hv : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
      inv Hv; try (match goal with Hlv : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ =>
                     inv Hlv end) end.
    match goal with Hc : sem_cast (Vint (Int.repr 0)) _ _ _ = Some _ |- _ =>
      cbn in Hc; injection Hc as <- end.
    match goal with Hel : eval_exprlist _ _ _ _ nil _ _ |- _ => inv Hel end.
    match goal with Hv1 : le ! M._m = Some ?v1 |- _ =>
      assert (Hmarg : marg_ok bm (v1 :: Vint (Int.repr dconst) :: Vint (Int.repr 0) :: nil))
        by (unfold marg_ok; destruct v1 as [| | | | | b o]; auto; exact (Htat b o Hv1)) end.
    match goal with
    | Hevf : eval_funcall _ _ _ _ _ _ _ _ |- _ =>
        destruct (Hdasma _ _ _ _ _ _ _ _ Hevf Hres Hmarg
                    (wact_const_sound _ Hdconst) HN HM HV HS)
          as (HV' & HS' & HM' & HN' & _)
    end.
    refine (conj HV' (conj HS' (conj HM' (conj HN' (conj eq_refl _))))).
    intros b o Hg. cbn [set_opttemp] in Hg.
    rewrite PTree.gso in Hg by (vm_compute; congruence).
    exact (Htat b o Hg).
  Qed.

  (* the hold_*_land leading drop-block (shared, parametric over dconst and
     the two opaque Sset rvalues + the if-condition).  Preserves the carried
     run facts and the _m tat across BOTH exits (drop-return + fall-through). *)
  Lemma hold_lead_pres :
    forall dconst a3 a4 cond le m tr le' m' out,
      wact_const (Int.repr dconst) = true ->
      (forall b o, le ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero) ->
      exec_stmt function_entry2 (lp_ge lp) empty_env le m
        (Ssequence (Sset M._t'3 a3)
          (Ssequence (Sset M._t'4 a4)
            (Sifthenelse cond
              (Ssequence
                 (Scall (Some M._t'1)
                    (Evar M._drop_and_set_mario_action
                       (Tfunction (tyMSp :: tuint :: tuint :: nil) tint cc_default))
                    (Etempvar M._m tyMSp
                     :: Econst_int (Int.repr dconst) tint
                     :: Econst_int (Int.repr 0) tint :: nil))
                 (Sreturn (Some (Etempvar M._t'1 tint))))
              Sskip)))
        tr le' m' out ->
      NoA m -> MWF m -> Mem.valid_block m bm -> action_sat not_tainted m bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\ NoA m'
      /\ (forall b o, le' ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
  Proof.
    intros dconst a3 a4 cond le m tr le' m' out Hdconst Htat Hexec HN HM HV HS.
    apply lnd_exec_seq_cases in Hexec
      as [ (tr1 & le1 & m1 & tr2 & Hs3 & Hrest) | (Hs3 & Hne) ].
    2:{ exfalso. apply Hne. apply lnd_exec_set_inv in Hs3 as (_ & -> & _). reflexivity. }
    apply lnd_exec_set_inv in Hs3 as (-> & _ & v3 & ->).
    apply lnd_exec_seq_cases in Hrest
      as [ (tr3 & le2 & m2 & tr4 & Hs4 & Hif) | (Hs4 & Hne) ].
    2:{ exfalso. apply Hne. apply lnd_exec_set_inv in Hs4 as (_ & -> & _). reflexivity. }
    apply lnd_exec_set_inv in Hs4 as (-> & _ & v4 & ->).
    assert (Htat2 : forall b o,
       (PTree.set M._t'4 v4 (PTree.set M._t'3 v3 le)) ! M._m = Some (Vptr b o) ->
       b = bm /\ o = Ptrofs.zero).
    { intros b o Hg.
      rewrite PTree.gso in Hg by (vm_compute; congruence).
      rewrite PTree.gso in Hg by (vm_compute; congruence).
      exact (Htat b o Hg). }
    apply lnd_exec_if_inv in Hif as [bb Hif].
    destruct bb.
    - apply lnd_exec_seq_cases in Hif
        as [ (tr5 & le3 & m3 & tr6 & Hcall & Hret) | (Hcall & Hne) ].
      2:{ exfalso. apply Hne. inv Hcall. reflexivity. }
      destruct (dasma_site_pres _ _ _ _ _ _ _ Hdconst Htat2 Hcall HN HM HV HS)
        as (HV' & HS' & HM' & HN' & _ & Htat3).
      apply lnd_exec_return_inv in Hret as (-> & -> & _).
      exact (conj HV' (conj HS' (conj HM' (conj HN' Htat3)))).
    - apply lnd_exec_skip_inv in Hif as (-> & -> & _).
      exact (conj HV (conj HS (conj HM (conj HN Htat2)))).
  Qed.

  Example mov_hjland_pin :
    (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._act_hold_jump_land
    = Some (Gfun (Internal mario_actions_moving.f_act_hold_jump_land)).
  Proof. vm_compute. reflexivity. Qed.
  Example mov_hfland_pin :
    (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._act_hold_freefall_land
    = Some (Gfun (Internal mario_actions_moving.f_act_hold_freefall_land)).
  Proof. vm_compute. reflexivity. Qed.

  Lemma mov_hjland_pres : body_pres lp NoA MWF bm M.f_act_hold_jump_land.
  Proof.
    intros m vargs t mEnd vres Hmarg Hevf HN HM HV HS.
    assert (Hmarg' : marg_ok bm vargs) by (apply Hmarg; vm_compute; reflexivity).
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry end.
    match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody end.
    match goal with Hf : Mem.free_list _ _ = Some _ |- _ => rename Hf into Hfree end.
    inv Hentry.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
      change (fn_vars M.f_act_hold_jump_land) with (@nil (ident * type)) in Ha; inv Ha end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ => rename Hb into Hbind end.
    change (fn_params M.f_act_hold_jump_land) with ((M._m, tyMSp) :: nil) in Hbind.
    cbn [bind_parameter_temps] in Hbind.
    destruct vargs as [| vhead vrest]; [ discriminate Hbind | ].
    destruct vrest as [|]; [ | discriminate Hbind ].
    injection Hbind as <-.
    change (blocks_of_env (lp_ge lp) empty_env) with (@nil (block * Z * Z)) in Hfree.
    cbn [Mem.free_list] in Hfree. injection Hfree as <-.
    set (base := create_undef_temps (fn_temps M.f_act_hold_jump_land)) in *.
    assert (Htat : forall b o,
       (PTree.set M._m vhead base) ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
    { intros b o Hg. rewrite PTree.gss in Hg. injection Hg as Hvh.
      rewrite Hvh in Hmarg'. cbn in Hmarg'. exact Hmarg'. }
    unfold M.f_act_hold_jump_land in Hbody; cbn [fn_body] in Hbody.
    apply lnd_exec_seq_cases in Hbody
      as [ (trF & leF & mF & trS & Hlead & Hmain) | (Hlead & Hne) ].
    - destruct (hold_lead_pres 201327152 _ _ _ _ _ _ _ _ _
                  ltac:(vm_compute; reflexivity) Htat Hlead HN HM HV HS)
        as (HVl & HSl & HMl & HNl & Htatl).
      apply lnd_exec_seq_cases in Hmain
        as [ (trA & leA & mA & trB & Hclcblk & Hcla_blk) | (Hclcblk & Hne) ].
      + apply lnd_exec_seq_cases in Hclcblk
          as [ (trC & leC & mC & trD & Hclc_c & Hif) | (Hclc_c & Hne0) ].
        2:{ exfalso. apply Hne0. inv Hclc_c. reflexivity. }
        destruct (clc_site_pres M._t'2 M._sHoldJumpLandAction
                    _ _ _ _ _ _ _ ltac:(vm_compute; congruence)
                    ltac:(vm_compute; reflexivity) Htatl Hclc_c HNl HMl HVl HSl)
          as (HVa & HSa & HMa & HNa & _ & Htat_a).
        apply lnd_exec_if_inv in Hif as [bb Hif].
        destruct bb.
        * apply lnd_exec_return_inv in Hif as (_ & _ & Hne1). congruence.
        * apply lnd_exec_skip_inv in Hif as (-> & -> & _).
          apply lnd_exec_seq_cases in Hcla_blk
            as [ (trE & leE & mE & trG & Hcla_c & Hret) | (Hcla_c & Hne2) ].
          -- destruct (cla_site_pres 64 16779425 _ _ _ _ _ _
                         ltac:(vm_compute; reflexivity) Htat_a Hcla_c HNa HMa HVa HSa)
               as (HVc & HSc & HMc & HNc).
             apply lnd_exec_return_inv in Hret as (_ & -> & _).
             exact (conj HVc (conj HSc HMc)).
          -- destruct (cla_site_pres 64 16779425 _ _ _ _ _ _
                         ltac:(vm_compute; reflexivity) Htat_a Hcla_c HNa HMa HVa HSa)
               as (HVc & HSc & HMc & HNc).
             exact (conj HVc (conj HSc HMc)).
      + apply lnd_exec_seq_cases in Hclcblk
          as [ (trC & leC & mC & trD & Hclc_c & Hif) | (Hclc_c & Hne0) ].
        2:{ exfalso. apply Hne0. inv Hclc_c. reflexivity. }
        destruct (clc_site_pres M._t'2 M._sHoldJumpLandAction
                    _ _ _ _ _ _ _ ltac:(vm_compute; congruence)
                    ltac:(vm_compute; reflexivity) Htatl Hclc_c HNl HMl HVl HSl)
          as (HVa & HSa & HMa & HNa & _ & _).
        apply lnd_exec_if_inv in Hif as [bb Hif].
        destruct bb.
        * apply lnd_exec_return_inv in Hif as (_ & -> & _).
          exact (conj HVa (conj HSa HMa)).
        * apply lnd_exec_skip_inv in Hif as (_ & -> & Hnn). congruence.
    - destruct (hold_lead_pres 201327152 _ _ _ _ _ _ _ _ _
                  ltac:(vm_compute; reflexivity) Htat Hlead HN HM HV HS)
        as (HVl & HSl & HMl & HNl & Htatl).
      exact (conj HVl (conj HSl HMl)).
  Qed.

  Lemma mov_hfland_pres : body_pres lp NoA MWF bm M.f_act_hold_freefall_land.
  Proof.
    intros m vargs t mEnd vres Hmarg Hevf HN HM HV HS.
    assert (Hmarg' : marg_ok bm vargs) by (apply Hmarg; vm_compute; reflexivity).
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry end.
    match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody end.
    match goal with Hf : Mem.free_list _ _ = Some _ |- _ => rename Hf into Hfree end.
    inv Hentry.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
      change (fn_vars M.f_act_hold_freefall_land) with (@nil (ident * type)) in Ha; inv Ha end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ => rename Hb into Hbind end.
    change (fn_params M.f_act_hold_freefall_land) with ((M._m, tyMSp) :: nil) in Hbind.
    cbn [bind_parameter_temps] in Hbind.
    destruct vargs as [| vhead vrest]; [ discriminate Hbind | ].
    destruct vrest as [|]; [ | discriminate Hbind ].
    injection Hbind as <-.
    change (blocks_of_env (lp_ge lp) empty_env) with (@nil (block * Z * Z)) in Hfree.
    cbn [Mem.free_list] in Hfree. injection Hfree as <-.
    set (base := create_undef_temps (fn_temps M.f_act_hold_freefall_land)) in *.
    assert (Htat : forall b o,
       (PTree.set M._m vhead base) ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
    { intros b o Hg. rewrite PTree.gss in Hg. injection Hg as Hvh.
      rewrite Hvh in Hmarg'. cbn in Hmarg'. exact Hmarg'. }
    unfold M.f_act_hold_freefall_land in Hbody; cbn [fn_body] in Hbody.
    apply lnd_exec_seq_cases in Hbody
      as [ (trF & leF & mF & trS & Hlead & Hmain) | (Hlead & Hne) ].
    - destruct (hold_lead_pres 201327154 _ _ _ _ _ _ _ _ _
                  ltac:(vm_compute; reflexivity) Htat Hlead HN HM HV HS)
        as (HVl & HSl & HMl & HNl & Htatl).
      apply lnd_exec_seq_cases in Hmain
        as [ (trA & leA & mA & trB & Hclcblk & Hcla_blk) | (Hclcblk & Hne) ].
      + apply lnd_exec_seq_cases in Hclcblk
          as [ (trC & leC & mC & trD & Hclc_c & Hif) | (Hclc_c & Hne0) ].
        2:{ exfalso. apply Hne0. inv Hclc_c. reflexivity. }
        destruct (clc_site_pres M._t'2 M._sHoldFreefallLandAction
                    _ _ _ _ _ _ _ ltac:(vm_compute; congruence)
                    ltac:(vm_compute; reflexivity) Htatl Hclc_c HNl HMl HVl HSl)
          as (HVa & HSa & HMa & HNa & _ & Htat_a).
        apply lnd_exec_if_inv in Hif as [bb Hif].
        destruct bb.
        * apply lnd_exec_return_inv in Hif as (_ & _ & Hne1). congruence.
        * apply lnd_exec_skip_inv in Hif as (-> & -> & _).
          apply lnd_exec_seq_cases in Hcla_blk
            as [ (trE & leE & mE & trG & Hcla_c & Hret) | (Hcla_c & Hne2) ].
          -- destruct (cla_site_pres 66 16779425 _ _ _ _ _ _
                         ltac:(vm_compute; reflexivity) Htat_a Hcla_c HNa HMa HVa HSa)
               as (HVc & HSc & HMc & HNc).
             apply lnd_exec_return_inv in Hret as (_ & -> & _).
             exact (conj HVc (conj HSc HMc)).
          -- destruct (cla_site_pres 66 16779425 _ _ _ _ _ _
                         ltac:(vm_compute; reflexivity) Htat_a Hcla_c HNa HMa HVa HSa)
               as (HVc & HSc & HMc & HNc).
             exact (conj HVc (conj HSc HMc)).
      + apply lnd_exec_seq_cases in Hclcblk
          as [ (trC & leC & mC & trD & Hclc_c & Hif) | (Hclc_c & Hne0) ].
        2:{ exfalso. apply Hne0. inv Hclc_c. reflexivity. }
        destruct (clc_site_pres M._t'2 M._sHoldFreefallLandAction
                    _ _ _ _ _ _ _ ltac:(vm_compute; congruence)
                    ltac:(vm_compute; reflexivity) Htatl Hclc_c HNl HMl HVl HSl)
          as (HVa & HSa & HMa & HNa & _ & _).
        apply lnd_exec_if_inv in Hif as [bb Hif].
        destruct bb.
        * apply lnd_exec_return_inv in Hif as (_ & -> & _).
          exact (conj HVa (conj HSa HMa)).
        * apply lnd_exec_skip_inv in Hif as (_ & -> & Hnn). congruence.
    - destruct (hold_lead_pres 201327154 _ _ _ _ _ _ _ _ _
                  ltac:(vm_compute; reflexivity) Htat Hlead HN HM HV HS)
        as (HVl & HSl & HMl & HNl & Htatl).
      exact (conj HVl (conj HSl HMl)).
  Qed.

  Example mov_tjland_pin :
    (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._act_triple_jump_land
    = Some (Gfun (Internal mario_actions_moving.f_act_triple_jump_land)).
  Proof. vm_compute. reflexivity. Qed.
  Example mov_bfland_pin :
    (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._act_backflip_land
    = Some (Gfun (Internal mario_actions_moving.f_act_backflip_land)).
  Proof. vm_compute. reflexivity. Qed.
  Example mov_ljland_pin :
    (prog_defmap mario_actions_moving.prog) ! mario_actions_moving._act_long_jump_land
    = Some (Gfun (Internal mario_actions_moving.f_act_long_jump_land)).
  Proof. vm_compute. reflexivity. Qed.

  (* triple_jump_land: UNCONDITIONAL input clear, then clc/if, then optional
     play_sound, then cla(192, UNTAINTED). *)
  Lemma mov_tjland_pres : body_pres lp NoA MWF bm M.f_act_triple_jump_land.
  Proof.
    intros m vargs t mEnd vres Hmarg Hevf HN HM HV HS.
    assert (Hmarg' : marg_ok bm vargs) by (apply Hmarg; vm_compute; reflexivity).
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry end.
    match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody end.
    match goal with Hf : Mem.free_list _ _ = Some _ |- _ => rename Hf into Hfree end.
    inv Hentry.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
      change (fn_vars M.f_act_triple_jump_land) with (@nil (ident * type)) in Ha; inv Ha end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ => rename Hb into Hbind end.
    change (fn_params M.f_act_triple_jump_land) with ((M._m, tyMSp) :: nil) in Hbind.
    cbn [bind_parameter_temps] in Hbind.
    destruct vargs as [| vhead vrest]; [ discriminate Hbind | ].
    destruct vrest as [|]; [ | discriminate Hbind ].
    injection Hbind as <-.
    change (blocks_of_env (lp_ge lp) empty_env) with (@nil (block * Z * Z)) in Hfree.
    cbn [Mem.free_list] in Hfree. injection Hfree as <-.
    set (base := create_undef_temps (fn_temps M.f_act_triple_jump_land)) in *.
    assert (Htat : forall b o,
       (PTree.set M._m vhead base) ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
    { intros b o Hg. rewrite PTree.gss in Hg. injection Hg as Hvh.
      rewrite Hvh in Hmarg'. cbn in Hmarg'. exact Hmarg'. }
    unfold M.f_act_triple_jump_land in Hbody; cbn [fn_body] in Hbody.
    (* ---- input pair ---- *)
    apply lnd_exec_seq_cases in Hbody
      as [ (tr0 & le0 & m0 & trR & Hinp & Hrest1) | (Hinp & Hne) ].
    2:{ exfalso. apply Hne.
        destruct (inp_aclear_pair_pres M._t'3
                    (Eunop Onotint (Econst_int (Int.repr 2) tint) tint)
                    _ _ _ _ _ _ ltac:(vm_compute; congruence) eq_refl Htat Hinp HN HM HV HS)
          as (_ & _ & _ & _ & Ho & _). exact Ho. }
    destruct (inp_aclear_pair_pres M._t'3
                (Eunop Onotint (Econst_int (Int.repr 2) tint) tint)
                _ _ _ _ _ _ ltac:(vm_compute; congruence) eq_refl Htat Hinp HN HM HV HS)
      as (HVi & HSi & HMi & HNi & _ & Htati).
    (* ---- clc block ---- *)
    apply lnd_exec_seq_cases in Hrest1
      as [ (trA & leA & mA & trB & Hclcblk & Hrest2) | (Hclcblk & Hne1) ].
    - apply lnd_exec_seq_cases in Hclcblk
        as [ (trC & leC & mC & trD & Hclc_c & Hif) | (Hclc_c & Hne0) ].
      2:{ exfalso. apply Hne0. inv Hclc_c. reflexivity. }
      destruct (clc_site_pres M._t'1 M._sTripleJumpLandAction
                  _ _ _ _ _ _ _ ltac:(vm_compute; congruence)
                  ltac:(vm_compute; reflexivity) Htati Hclc_c HNi HMi HVi HSi)
        as (HVa & HSa & HMa & HNa & _ & Htat_a).
      apply lnd_exec_if_inv in Hif as [bb Hif].
      destruct bb.
      + apply lnd_exec_return_inv in Hif as (_ & _ & Hne2). congruence.
      + apply lnd_exec_skip_inv in Hif as (-> & -> & _).
        (* ---- optional play_sound block ---- *)
        apply lnd_exec_seq_cases in Hrest2
          as [ (trE & leE & mE & trG & Hpsblk & Hclablk) | (Hpsblk & Hne3) ].
        * destruct (psinf_block_pres M._t'2 _ _ _ _ _ _ _ _
                      ltac:(vm_compute; congruence) Htat_a Hpsblk HNa HMa HVa HSa)
            as (HVp & HSp & HMp & HNp & _ & Htat_p).
          apply lnd_exec_seq_cases in Hclablk
            as [ (trH & leH & mH & trI & Hcla_c & Hret) | (Hcla_c & Hne4) ].
          -- destruct (cla_site_pres 192 16779404 _ _ _ _ _ _
                         ltac:(vm_compute; reflexivity) Htat_p Hcla_c HNp HMp HVp HSp)
               as (HVc & HSc & HMc & HNc).
             apply lnd_exec_return_inv in Hret as (_ & -> & _).
             exact (conj HVc (conj HSc HMc)).
          -- destruct (cla_site_pres 192 16779404 _ _ _ _ _ _
                         ltac:(vm_compute; reflexivity) Htat_p Hcla_c HNp HMp HVp HSp)
               as (HVc & HSc & HMc & HNc).
             exact (conj HVc (conj HSc HMc)).
        * destruct (psinf_block_pres M._t'2 _ _ _ _ _ _ _ _
                      ltac:(vm_compute; congruence) Htat_a Hpsblk HNa HMa HVa HSa)
            as (_ & _ & _ & _ & Ho & _). congruence.
    - apply lnd_exec_seq_cases in Hclcblk
        as [ (trC & leC & mC & trD & Hclc_c & Hif) | (Hclc_c & Hne0) ].
      2:{ exfalso. apply Hne0. inv Hclc_c. reflexivity. }
      destruct (clc_site_pres M._t'1 M._sTripleJumpLandAction
                  _ _ _ _ _ _ _ ltac:(vm_compute; congruence)
                  ltac:(vm_compute; reflexivity) Htati Hclc_c HNi HMi HVi HSi)
        as (HVa & HSa & HMa & HNa & _ & _).
      apply lnd_exec_if_inv in Hif as [bb Hif].
      destruct bb.
      + apply lnd_exec_return_inv in Hif as (_ & -> & _).
        exact (conj HVa (conj HSa HMa)).
      + apply lnd_exec_skip_inv in Hif as (_ & -> & Hnn). congruence.
  Qed.

  (* backflip_land: GUARDED input clear (on !(input&0x4000)), then the same
     clc/if + optional play_sound + cla(192, UNTAINTED) template. *)
  Lemma mov_bfland_pres : body_pres lp NoA MWF bm M.f_act_backflip_land.
  Proof.
    intros m vargs t mEnd vres Hmarg Hevf HN HM HV HS.
    assert (Hmarg' : marg_ok bm vargs) by (apply Hmarg; vm_compute; reflexivity).
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry end.
    match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody end.
    match goal with Hf : Mem.free_list _ _ = Some _ |- _ => rename Hf into Hfree end.
    inv Hentry.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
      change (fn_vars M.f_act_backflip_land) with (@nil (ident * type)) in Ha; inv Ha end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ => rename Hb into Hbind end.
    change (fn_params M.f_act_backflip_land) with ((M._m, tyMSp) :: nil) in Hbind.
    cbn [bind_parameter_temps] in Hbind.
    destruct vargs as [| vhead vrest]; [ discriminate Hbind | ].
    destruct vrest as [|]; [ | discriminate Hbind ].
    injection Hbind as <-.
    change (blocks_of_env (lp_ge lp) empty_env) with (@nil (block * Z * Z)) in Hfree.
    cbn [Mem.free_list] in Hfree. injection Hfree as <-.
    set (base := create_undef_temps (fn_temps M.f_act_backflip_land)) in *.
    assert (Htat : forall b o,
       (PTree.set M._m vhead base) ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
    { intros b o Hg. rewrite PTree.gss in Hg. injection Hg as Hvh.
      rewrite Hvh in Hmarg'. cbn in Hmarg'. exact Hmarg'. }
    unfold M.f_act_backflip_land in Hbody; cbn [fn_body] in Hbody.
    apply lnd_exec_seq_cases in Hbody
      as [ (tr0 & le0 & m0 & trR & Hinp & Hrest1) | (Hinp & Hne) ].
    2:{ exfalso. apply Hne.
        destruct (guarded_input_pres M._t'3 M._t'4 _ _ _ _ _ _ _
                    ltac:(vm_compute; congruence) ltac:(vm_compute; congruence)
                    Htat Hinp HN HM HV HS)
          as (_ & _ & _ & _ & Ho & _). exact Ho. }
    destruct (guarded_input_pres M._t'3 M._t'4 _ _ _ _ _ _ _
                ltac:(vm_compute; congruence) ltac:(vm_compute; congruence)
                Htat Hinp HN HM HV HS)
      as (HVi & HSi & HMi & HNi & _ & Htati).
    apply lnd_exec_seq_cases in Hrest1
      as [ (trA & leA & mA & trB & Hclcblk & Hrest2) | (Hclcblk & Hne1) ].
    - apply lnd_exec_seq_cases in Hclcblk
        as [ (trC & leC & mC & trD & Hclc_c & Hif) | (Hclc_c & Hne0) ].
      2:{ exfalso. apply Hne0. inv Hclc_c. reflexivity. }
      destruct (clc_site_pres M._t'1 M._sBackflipLandAction
                  _ _ _ _ _ _ _ ltac:(vm_compute; congruence)
                  ltac:(vm_compute; reflexivity) Htati Hclc_c HNi HMi HVi HSi)
        as (HVa & HSa & HMa & HNa & _ & Htat_a).
      apply lnd_exec_if_inv in Hif as [bb Hif].
      destruct bb.
      + apply lnd_exec_return_inv in Hif as (_ & _ & Hne2). congruence.
      + apply lnd_exec_skip_inv in Hif as (-> & -> & _).
        apply lnd_exec_seq_cases in Hrest2
          as [ (trE & leE & mE & trG & Hpsblk & Hclablk) | (Hpsblk & Hne3) ].
        * destruct (psinf_block_pres M._t'2 _ _ _ _ _ _ _ _
                      ltac:(vm_compute; congruence) Htat_a Hpsblk HNa HMa HVa HSa)
            as (HVp & HSp & HMp & HNp & _ & Htat_p).
          apply lnd_exec_seq_cases in Hclablk
            as [ (trH & leH & mH & trI & Hcla_c & Hret) | (Hcla_c & Hne4) ].
          -- destruct (cla_site_pres 192 16779404 _ _ _ _ _ _
                         ltac:(vm_compute; reflexivity) Htat_p Hcla_c HNp HMp HVp HSp)
               as (HVc & HSc & HMc & HNc).
             apply lnd_exec_return_inv in Hret as (_ & -> & _).
             exact (conj HVc (conj HSc HMc)).
          -- destruct (cla_site_pres 192 16779404 _ _ _ _ _ _
                         ltac:(vm_compute; reflexivity) Htat_p Hcla_c HNp HMp HVp HSp)
               as (HVc & HSc & HMc & HNc).
             exact (conj HVc (conj HSc HMc)).
        * destruct (psinf_block_pres M._t'2 _ _ _ _ _ _ _ _
                      ltac:(vm_compute; congruence) Htat_a Hpsblk HNa HMa HVa HSa)
            as (_ & _ & _ & _ & Ho & _). congruence.
    - apply lnd_exec_seq_cases in Hclcblk
        as [ (trC & leC & mC & trD & Hclc_c & Hif) | (Hclc_c & Hne0) ].
      2:{ exfalso. apply Hne0. inv Hclc_c. reflexivity. }
      destruct (clc_site_pres M._t'1 M._sBackflipLandAction
                  _ _ _ _ _ _ _ ltac:(vm_compute; congruence)
                  ltac:(vm_compute; reflexivity) Htati Hclc_c HNi HMi HVi HSi)
        as (HVa & HSa & HMa & HNa & _ & _).
      apply lnd_exec_if_inv in Hif as [bb Hif].
      destruct bb.
      + apply lnd_exec_return_inv in Hif as (_ & -> & _).
        exact (conj HVa (conj HSa HMa)).
      + apply lnd_exec_skip_inv in Hif as (_ & -> & Hnn). congruence.
  Qed.

  (* long_jump_land: GUARDED input clear, then clc/if, then optional play_sound,
     then an anim-SELECT block (3 temp sets, NO write), then cla(_t'2, UNTAINTED). *)
  Lemma mov_ljland_pres : body_pres lp NoA MWF bm M.f_act_long_jump_land.
  Proof.
    intros m vargs t mEnd vres Hmarg Hevf HN HM HV HS.
    assert (Hmarg' : marg_ok bm vargs) by (apply Hmarg; vm_compute; reflexivity).
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry end.
    match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody end.
    match goal with Hf : Mem.free_list _ _ = Some _ |- _ => rename Hf into Hfree end.
    inv Hentry.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
      change (fn_vars M.f_act_long_jump_land) with (@nil (ident * type)) in Ha; inv Ha end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ => rename Hb into Hbind end.
    change (fn_params M.f_act_long_jump_land) with ((M._m, tyMSp) :: nil) in Hbind.
    cbn [bind_parameter_temps] in Hbind.
    destruct vargs as [| vhead vrest]; [ discriminate Hbind | ].
    destruct vrest as [|]; [ | discriminate Hbind ].
    injection Hbind as <-.
    change (blocks_of_env (lp_ge lp) empty_env) with (@nil (block * Z * Z)) in Hfree.
    cbn [Mem.free_list] in Hfree. injection Hfree as <-.
    set (base := create_undef_temps (fn_temps M.f_act_long_jump_land)) in *.
    assert (Htat : forall b o,
       (PTree.set M._m vhead base) ! M._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
    { intros b o Hg. rewrite PTree.gss in Hg. injection Hg as Hvh.
      rewrite Hvh in Hmarg'. cbn in Hmarg'. exact Hmarg'. }
    unfold M.f_act_long_jump_land in Hbody; cbn [fn_body] in Hbody.
    apply lnd_exec_seq_cases in Hbody
      as [ (tr0 & le0 & m0 & trR & Hinp & Hrest1) | (Hinp & Hne) ].
    2:{ exfalso. apply Hne.
        destruct (guarded_input_pres M._t'6 M._t'7 _ _ _ _ _ _ _
                    ltac:(vm_compute; congruence) ltac:(vm_compute; congruence)
                    Htat Hinp HN HM HV HS)
          as (_ & _ & _ & _ & Ho & _). exact Ho. }
    destruct (guarded_input_pres M._t'6 M._t'7 _ _ _ _ _ _ _
                ltac:(vm_compute; congruence) ltac:(vm_compute; congruence)
                Htat Hinp HN HM HV HS)
      as (HVi & HSi & HMi & HNi & _ & Htati).
    apply lnd_exec_seq_cases in Hrest1
      as [ (trA & leA & mA & trB & Hclcblk & Hrest2) | (Hclcblk & Hne1) ].
    - apply lnd_exec_seq_cases in Hclcblk
        as [ (trC & leC & mC & trD & Hclc_c & Hif) | (Hclc_c & Hne0) ].
      2:{ exfalso. apply Hne0. inv Hclc_c. reflexivity. }
      destruct (clc_site_pres M._t'1 M._sLongJumpLandAction
                  _ _ _ _ _ _ _ ltac:(vm_compute; congruence)
                  ltac:(vm_compute; reflexivity) Htati Hclc_c HNi HMi HVi HSi)
        as (HVa & HSa & HMa & HNa & _ & Htat_a).
      apply lnd_exec_if_inv in Hif as [bb Hif].
      destruct bb.
      + apply lnd_exec_return_inv in Hif as (_ & _ & Hne2). congruence.
      + apply lnd_exec_skip_inv in Hif as (-> & -> & _).
        apply lnd_exec_seq_cases in Hrest2
          as [ (trE & leE & mE & trG & Hpsblk & Hclablk) | (Hpsblk & Hne3) ].
        * destruct (psinf_block_pres M._t'5 _ _ _ _ _ _ _ _
                      ltac:(vm_compute; congruence) Htat_a Hpsblk HNa HMa HVa HSa)
            as (HVp & HSp & HMp & HNp & _ & Htat_p).
          (* ---- anim-select + cla ---- *)
          apply lnd_exec_seq_cases in Hclablk
            as [ (trH & leH & mH & trI & Hanimcla & Hret) | (Hanimcla & Hne4) ].
          -- apply lnd_exec_seq_cases in Hanimcla
               as [ (trJ & leJ & mJ & trK & Hanimsel & Hcla) | (Hanimsel & Hne5) ].
             ++ destruct (animsel_pres _ _ _ _ _ _ _ _ _ _ _ Htat_p Hanimsel HNp HMp HVp HSp)
                  as (HVan & HSan & HMan & HNan & _ & Htat_an).
                destruct (cla_site_pres_e (Etempvar M._t'2 tint) 16779404 _ _ _ _ _ _
                            ltac:(vm_compute; reflexivity) Htat_an Hcla HNan HMan HVan HSan)
                  as (HVc & HSc & HMc & HNc).
                apply lnd_exec_return_inv in Hret as (_ & -> & _).
                exact (conj HVc (conj HSc HMc)).
             ++ destruct (animsel_pres _ _ _ _ _ _ _ _ _ _ _ Htat_p Hanimsel HNp HMp HVp HSp)
                  as (_ & _ & _ & _ & Ho & _). congruence.
          -- apply lnd_exec_seq_cases in Hanimcla
               as [ (trJ & leJ & mJ & trK & Hanimsel & Hcla) | (Hanimsel & Hne5) ].
             ++ destruct (animsel_pres _ _ _ _ _ _ _ _ _ _ _ Htat_p Hanimsel HNp HMp HVp HSp)
                  as (HVan & HSan & HMan & HNan & _ & Htat_an).
                destruct (cla_site_pres_e (Etempvar M._t'2 tint) 16779404 _ _ _ _ _ _
                            ltac:(vm_compute; reflexivity) Htat_an Hcla HNan HMan HVan HSan)
                  as (HVc & HSc & HMc & HNc).
                exact (conj HVc (conj HSc HMc)).
             ++ destruct (animsel_pres _ _ _ _ _ _ _ _ _ _ _ Htat_p Hanimsel HNp HMp HVp HSp)
                  as (_ & _ & _ & _ & Ho & _). congruence.
        * destruct (psinf_block_pres M._t'5 _ _ _ _ _ _ _ _
                      ltac:(vm_compute; congruence) Htat_a Hpsblk HNa HMa HVa HSa)
            as (_ & _ & _ & _ & Ho & _). congruence.
    - apply lnd_exec_seq_cases in Hclcblk
        as [ (trC & leC & mC & trD & Hclc_c & Hif) | (Hclc_c & Hne0) ].
      2:{ exfalso. apply Hne0. inv Hclc_c. reflexivity. }
      destruct (clc_site_pres M._t'1 M._sLongJumpLandAction
                  _ _ _ _ _ _ _ ltac:(vm_compute; congruence)
                  ltac:(vm_compute; reflexivity) Htati Hclc_c HNi HMi HVi HSi)
        as (HVa & HSa & HMa & HNa & _ & _).
      apply lnd_exec_if_inv in Hif as [bb Hif].
      destruct bb.
      + apply lnd_exec_return_inv in Hif as (_ & -> & _).
        exact (conj HVa (conj HSa HMa)).
      + apply lnd_exec_skip_inv in Hif as (_ & -> & Hnn). congruence.
  Qed.

  Lemma mov_bwa_ids_rows : forall fid, mem_id fid mov_bwa_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_bwa_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_msfv_row | ].
    discriminate H.
  Qed.

  Lemma mov_bwa_wids_rows : forall fid, mem_id fid mov_bwa_wids = true ->
      call_pres_act lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_bwa_wids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsmact | ].
    discriminate H.
  Qed.

  (* begin_walking_action: the PARAM-action producer.  Its _action param is
     threaded through wact into set_mario_action(m, _action, _actionArg);
     the call_pres_act3 obligation (untainted aval) discharges its body. *)
  Lemma mov_bwa_row :
    call_pres_act3 lp bm NoA MWF mario_actions_moving._begin_walking_action.
  Proof.
    apply (call_pres_act3_of_wwalk_p4 lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_moving.prog
             mario_actions_moving._begin_walking_action
             mario_actions_moving.f_begin_walking_action
             mov_bwa_wact mov_bwa_ids mov_bwa_wids nil nil nil
             mario_actions_moving._forwardVel mario_actions_moving._action
             mario_actions_moving._actionArg tfloat tuint
             LO_mov mov_bwa_pin mov_bwa_vars mov_bwa_params
             mov_bwa_aid_m mov_bwa_eid_m mov_bwa_harg_m
             mov_bwa_wa mov_bwa_wm mov_bwa_wanim mov_bwa_wharg
             eq_refl eq_refl eq_refl eq_refl).
    - exact mov_bwa_ids_rows.
    - exact mov_bwa_wids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact mov_bwa_walk.
  Qed.

  Lemma mov_ata_ids_rows : forall fid, mem_id fid mov_ata_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_ata_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_ashb_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_asd_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_pgs | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_sma_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_iae_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_asfs_row | ].
    discriminate H.
  Qed.

  Lemma mov_ata_sids_rows : forall fid, mem_id fid mov_ata_sids = true ->
      call_pres_act lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_ata_sids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsmact | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_sja_row | ].
    discriminate H.
  Qed.

  Lemma mov_ata_xids_rows : forall fid, mem_id fid mov_ata_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_ata_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_psound | ].
    discriminate H.
  Qed.

  Lemma mov_ata_tids_rows : forall fid, mem_id fid mov_ata_tids = true ->
      call_pres_act3 lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold mov_ata_tids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mov_bwa_row | ].
    discriminate H.
  Qed.

  Lemma mov_ata_pres :
    body_pres lp NoA MWF bm mario_actions_moving.f_act_turning_around.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_moving.f_act_turning_around
             mov_ata_ids nil mov_ata_xids mov_ata_sids mov_ata_tids
             mov_ata_vars mov_ata_pok).
    - exact mov_ata_ids_rows.
    - intros fid' H. discriminate H.
    - exact mov_ata_xids_rows.
    - exact mov_ata_sids_rows.
    - exact mov_ata_tids_rows.
    - exact mov_ata_walk.
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
    (* 4: act_hold_heavy_walking -- WALKED *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite mov_ahhw_pin in Hdm. injection Hdm as <-. exact mov_ahhw_pres. }
    (* 5: act_turning_around -- WALKED (param-action / begin_walking_action) *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite mov_ata_pin in Hdm. injection Hdm as <-. exact mov_ata_pres. }
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
    (* 12: act_hold_decelerating -- WALKED (val0C np3 leaf) *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite mov_ahd_pin in Hdm. injection Hdm as <-. exact mov_ahd_pres. }
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
    (* 20: act_slide_kick_slide -- WALKED *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite mov_sks_pin in Hdm. injection Hdm as <-. exact mov_sks_pres. }
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
    (* 29: act_jump_land -- WALKED (landing keystone) *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite mov_jland_pin in Hdm. injection Hdm as <-. exact mov_jland_pres. }
    (* 30: act_freefall_land -- WALKED (landing keystone) *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite mov_ffland_pin in Hdm. injection Hdm as <-. exact mov_ffland_pres. }
    (* 31: act_double_jump_land -- WALKED (landing keystone) *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite mov_djland_pin in Hdm. injection Hdm as <-. exact mov_djland_pres. }
    (* 32: act_side_flip_land -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 33: act_hold_jump_land -- WALKED (landing keystone part 2) *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite mov_hjland_pin in Hdm. injection Hdm as <-. exact mov_hjland_pres. }
    (* 34: act_hold_freefall_land -- WALKED (landing keystone part 2) *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite mov_hfland_pin in Hdm. injection Hdm as <-. exact mov_hfland_pres. }
    (* 35: act_triple_jump_land -- WALKED (landing keystone part 3) *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite mov_tjland_pin in Hdm. injection Hdm as <-. exact mov_tjland_pres. }
    (* 36: act_backflip_land -- WALKED (landing keystone part 3) *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite mov_bfland_pin in Hdm. injection Hdm as <-. exact mov_bfland_pres. }
    (* 37: act_quicksand_jump_land -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 38: act_hold_quicksand_jump_land -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 39: act_long_jump_land -- WALKED (landing keystone part 3) *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite mov_ljland_pin in Hdm. injection Hdm as <-. exact mov_ljland_pres. }
    discriminate H.
  Qed.

End MovingLeafRows.
