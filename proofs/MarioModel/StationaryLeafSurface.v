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
From SM64.Proofs Require Import ActWriterSurface ObjectLeafSurface StationarySurface.

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

(* the one shared audio external (play_sound, in the obj_ext model class) --
   used by act_shivering and the landing-sound helper chain *)
Definition sta_psound_xids : list ident := mario._play_sound :: nil.

(* ---- the set_jumping_action arc (gates the 3 crouch leaves + the
   *_cancels helpers).  mario_floor_is_steep's two pure-ish callees;
   set_steep_jump_action's marioObj chase temp, its two math externals
   (sqrtf/atan2s, in obj_ext_ids), and its drop_and_set channel; the
   set_jumping_action ids; and the crouch sids = sma + set_jumping_action. *)
Definition sta_mfis_ids : list ident :=
  mario._mario_facing_downhill :: mario._mario_get_floor_class :: nil.
Definition sta_sssja_cact : list ident := mario._t'10 :: nil.
Definition sta_sssja_xids : list ident :=
  mario._sqrtf :: mario._atan2s :: nil.
Definition sta_sssja_sids : list ident :=
  mario._drop_and_set_mario_action :: nil.
Definition sta_sja_ids : list ident :=
  mario._mario_floor_is_steep :: mario._set_steep_jump_action :: nil.
Definition sta_crouch_sids : list ident :=
  mario._set_mario_action :: mario._set_jumping_action :: nil.

(* ---- SLICE 11: the IDLE cluster (3 of 5: act_in_quicksand / act_coughing /
   act_panting).  Gate = check_common_idle_cancels [call_pres]: it drops the
   held object (mario_drop_held_object, reused via ObjectLeafSurface.mdho_row),
   reads m->floor->normal.y, then input-gated const exits through set_mario_action
   / set_jumping_action / mario_push_off_steep_floor.  push_off threads its
   _action PARAM to set_mario_action -> it is a call_pres_ACT (wact=[_action;_t'2],
   wids=sids=[set_mario_action]), walked here via the writer producer.  The three
   leaves then bottom out in ccic + set_mario_animation + stationary_ground_step
   (+ play_sound for coughing/panting; + a marioBodyState->eyeState chase store
   for panting). ---- *)
Definition sta_pushoff_wact : list ident :=
  mario_step._action :: mario_step._t'2 :: nil.
Definition sta_ccic_ids : list ident :=
  interaction._mario_drop_held_object :: nil.
Definition sta_ccic_sids : list ident :=
  mario._set_mario_action :: mario._set_jumping_action
    :: mario_step._mario_push_off_steep_floor :: nil.
Definition sta_idle_ids : list ident :=
  mario_actions_stationary._check_common_idle_cancels
    :: mario._set_mario_animation
    :: mario_step._stationary_ground_step :: nil.
Definition sta_panting_cact : list ident := mario._t'5 :: nil.

(* ---- SLICE 14: act_idle (the FIFTH idle leaf -- the OC-ARC one).  Beyond the
   ccic/set_mario_animation/stationary_ground_step idle bottom, act_idle also
   calls is_anim_at_end (call_pres, reads only) and find_floor_height_relative_
   polar -- the out-param helper that calls find_floor(x,y,z,&_floor) into a
   STACK LOCAL.  ffhrp is discharged at the capstone by AutomaticLeafSurface.
   Hffhrp (the proved call_pres_of_lwalk2 walk over the oc-arc); here it is the
   section hypothesis Hffhrp_sta.  cact=nil (no chase stores); sids=[sma]. ---- *)
Definition sta_idle2_ids : list ident :=
  mario_actions_stationary._check_common_idle_cancels
    :: mario._set_mario_animation
    :: mario._is_anim_at_end
    :: mario._find_floor_height_relative_polar
    :: mario_step._stationary_ground_step :: nil.

(* ---- SLICE 15: act_sleeping (the sixth / last idle-sleeping leaf).  Like
   act_idle it calls the ffhrp out-param helper + is_anim_at_end +
   set_mario_animation + stationary_ground_step (ids) and set_mario_action(const)
   (sids), but NO ccic; plus FOUR pure audio externals (play_sound via
   Hcpx_psound; lower_background_noise / play_mario_heavy_landing_sound /
   play_sound_if_no_flag via Hpres_sta_ext) and ONE marioBodyState->eyeState=3
   chase store (cact=[_t'19]). ---- *)
Definition sta_sleep_ids : list ident :=
  mario._set_mario_animation
    :: mario._is_anim_at_end
    :: mario._find_floor_height_relative_polar
    :: mario_step._stationary_ground_step :: nil.
Definition sta_sleep_xids : list ident :=
  mario._play_sound
    :: mario_actions_stationary._lower_background_noise
    :: mario_actions_stationary._play_mario_heavy_landing_sound
    :: mario_actions_stationary._play_sound_if_no_flag :: nil.
Definition sta_sleep_cact : list ident := mario._t'19 :: nil.

(* ---- SLICE 12: the HOLD_IDLE cluster (2: act_hold_idle /
   act_hold_panting_unused).  Gate = check_common_hold_idle_cancels
   [call_pres, cact=[_t'20]]: like ccic but clears a held-object flag bit via
   `m->heldObj->rawData.asU32[66] = (s32)(_t'22 & ~64)` -- a chase store whose
   RHS is `Ecast (Ebinop Oand ..) i32`, walked by the nonptr_binop_head Ecast
   arm added to wchase_rhs_ok (ActWriterSurface).  Its const exits add dasma to
   the ccic sids.  The two leaves use sids=[sma;dasma] (sta_dasma_sids), ids=
   [cchic;set_mario_animation;stationary_ground_step]; hold_idle compares a
   segmented_to_virtual pointer (xids=[s2v], Hcpx_s2v); hold_panting has the
   marioBodyState->eyeState chase store (cact=[_t'5]). ---- *)
Definition sta_cchic_cact : list ident := mario._t'20 :: nil.
Definition sta_cchic_sids : list ident :=
  mario._set_mario_action :: mario._set_jumping_action
    :: mario_step._mario_push_off_steep_floor
    :: mario._drop_and_set_mario_action :: nil.
Definition sta_hidle_ids : list ident :=
  mario_actions_stationary._check_common_hold_idle_cancels
    :: mario._set_mario_animation
    :: mario_step._stationary_ground_step :: nil.
Definition sta_s2v_xids : list ident := interaction._segmented_to_virtual :: nil.
Definition sta_hpant_cact : list ident := mario._t'5 :: nil.

(* ---- SLICE 13: act_start_sleeping (the idle/sleeping quick win).  Needs only
   play_anim_sound walked [call_pres: reads m->actionState + m->marioObj->
   ..animFrame, calls play_sound; xids=play_sound].  The leaf calls ccic +
   set_mario_animation + play_anim_sound + is_anim_at_end + stationary_ground_step
   [all call_pres], set_mario_action(const) [sids], play_sound [xids], and two
   marioBodyState->eyeState chase stores [cact=[_t'19;_t'18]]. ---- *)
Definition sta_ssleep_ids : list ident :=
  mario_actions_stationary._check_common_idle_cancels
    :: mario._set_mario_animation
    :: mario_actions_stationary._play_anim_sound
    :: mario._is_anim_at_end
    :: mario_step._stationary_ground_step :: nil.
Definition sta_ssleep_cact : list ident := mario._t'19 :: mario._t'18 :: nil.

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

(* ---- is_anim_at_end (loads only, the at-end twin of is_anim_past_end) ---- *)
Example sta_iae_pin :
  (prog_defmap mario.prog) ! mario._is_anim_at_end
  = Some (Gfun (Internal mario.f_is_anim_at_end)).
Proof. vm_compute. reflexivity. Qed.
Example sta_iae_vars : fn_vars mario.f_is_anim_at_end = nil.
Proof. vm_compute. reflexivity. Qed.
Example sta_iae_params_ok :
  match fn_params mario.f_is_anim_at_end with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example sta_iae_walk :
  wwalk_chk false nil nil nil nil nil nil nil
    (fn_body mario.f_is_anim_at_end) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- stopping_step: the caller-action step helper (the act3 channel).
   Threads its OWN 3rd param _action into set_mario_action(m, _action, 0);
   also calls stationary_ground_step / set_mario_animation(m, _animID) /
   is_anim_at_end.  Proven call_pres_act3 via call_pres_act3_of_wwalk_p
   (params (_m, _animID, _action), the action temp _action seeded into
   wact). ---- *)
Definition sta_ss_wact : list ident := mario_actions_stationary._action :: nil.
Definition sta_ss_ids : list ident :=
  mario_step._stationary_ground_step
    :: mario._set_mario_animation
    :: mario._is_anim_at_end :: nil.
Example sta_ss_pin :
  (prog_defmap mario_actions_stationary.prog)
    ! mario_actions_stationary._stopping_step
  = Some (Gfun (Internal mario_actions_stationary.f_stopping_step)).
Proof. vm_compute. reflexivity. Qed.
Example sta_ss_vars : fn_vars mario_actions_stationary.f_stopping_step = nil.
Proof. vm_compute. reflexivity. Qed.
Example sta_ss_params :
  fn_params mario_actions_stationary.f_stopping_step
  = (mario_actions_airborne._m, tyMSp)
      :: (mario_actions_stationary._animID, tint)
      :: (mario_actions_stationary._action, tuint) :: nil.
Proof. vm_compute. reflexivity. Qed.
Example sta_ss_aid_m :
  mario_actions_stationary._animID <> mario_actions_airborne._m.
Proof. vm_compute. discriminate. Qed.
Example sta_ss_eid_m :
  mario_actions_stationary._action <> mario_actions_airborne._m.
Proof. vm_compute. discriminate. Qed.
Example sta_ss_wa :
  mem_id mario_actions_stationary._action sta_ss_wact = true.
Proof. vm_compute. reflexivity. Qed.
Example sta_ss_wm :
  mem_id mario_actions_airborne._m sta_ss_wact = false.
Proof. vm_compute. reflexivity. Qed.
Example sta_ss_wanim :
  mem_id mario_actions_stationary._animID sta_ss_wact = false.
Proof. vm_compute. reflexivity. Qed.
Example sta_ss_walk :
  wwalk_chk false sta_ss_wact sta_ss_ids nil nil nil sta_sids nil
    (fn_body mario_actions_stationary.f_stopping_step) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- act_braking_stop: calls stopping_step(m, 16, ACT_BRAKING_STOP) via
   the act3 channel (tids), plus smact-const exits + check_common_action_
   exits.  No A-gate, no cancel helper -- the cleanest of the stop cluster. *)
Definition sta_braking_tids : list ident :=
  mario_actions_stationary._stopping_step :: nil.
Example sta_abs_pin :
  (prog_defmap mario_actions_stationary.prog)
    ! mario_actions_stationary._act_braking_stop
  = Some (Gfun (Internal mario_actions_stationary.f_act_braking_stop)).
Proof. vm_compute. reflexivity. Qed.
Example sta_abs_vars :
  fn_vars mario_actions_stationary.f_act_braking_stop = nil.
Proof. vm_compute. reflexivity. Qed.
Example sta_abs_params_ok :
  match fn_params mario_actions_stationary.f_act_braking_stop with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example sta_abs_walk :
  wwalk_chk false nil sta_leaf_ids nil nil nil sta_sids sta_braking_tids
    (fn_body mario_actions_stationary.f_act_braking_stop) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- the landing-sound helper chain (all INTERNAL in mario.prog, walked;
   bottoms out in play_sound, the obj_ext audio external) ---- *)
(* play_sound_and_spawn_particles: reads m->flags, builds a sound id, calls
   play_sound; the 4 stores are particle/window writes the engine accepts *)
Example sta_pssp_pin :
  (prog_defmap mario.prog) ! mario._play_sound_and_spawn_particles
  = Some (Gfun (Internal mario.f_play_sound_and_spawn_particles)).
Proof. vm_compute. reflexivity. Qed.
Example sta_pssp_vars :
  fn_vars mario.f_play_sound_and_spawn_particles = nil.
Proof. vm_compute. reflexivity. Qed.
Example sta_pssp_params_ok :
  match fn_params mario.f_play_sound_and_spawn_particles with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example sta_pssp_walk :
  wwalk_chk false nil nil nil nil sta_psound_xids nil nil
    (fn_body mario.f_play_sound_and_spawn_particles) = true.
Proof. vm_compute. reflexivity. Qed.

(* play_mario_landing_sound: reads m->flags, calls play_sound_and_spawn_particles *)
Definition sta_pmls_ids : list ident :=
  mario._play_sound_and_spawn_particles :: nil.
Example sta_pmls_pin :
  (prog_defmap mario.prog) ! mario._play_mario_landing_sound
  = Some (Gfun (Internal mario.f_play_mario_landing_sound)).
Proof. vm_compute. reflexivity. Qed.
Example sta_pmls_vars :
  fn_vars mario.f_play_mario_landing_sound = nil.
Proof. vm_compute. reflexivity. Qed.
Example sta_pmls_params_ok :
  match fn_params mario.f_play_mario_landing_sound with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example sta_pmls_walk :
  wwalk_chk false nil sta_pmls_ids nil nil nil nil nil
    (fn_body mario.f_play_mario_landing_sound) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- act_butt_slide_stop: stopping_step (act3) + play_mario_landing_sound
   (internal helper, ids) + smact-const exits.  No A-gate, no cancel helper. *)
Definition sta_bss_ids : list ident :=
  mario._play_mario_landing_sound :: sta_leaf_ids.
Example sta_bss_pin :
  (prog_defmap mario_actions_stationary.prog)
    ! mario_actions_stationary._act_butt_slide_stop
  = Some (Gfun (Internal mario_actions_stationary.f_act_butt_slide_stop)).
Proof. vm_compute. reflexivity. Qed.
Example sta_bss_vars :
  fn_vars mario_actions_stationary.f_act_butt_slide_stop = nil.
Proof. vm_compute. reflexivity. Qed.
Example sta_bss_params_ok :
  match fn_params mario_actions_stationary.f_act_butt_slide_stop with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example sta_bss_walk :
  wwalk_chk false nil sta_bss_ids nil nil nil sta_sids sta_braking_tids
    (fn_body mario_actions_stationary.f_act_butt_slide_stop) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- the drop_and_set_mario_action (held-object) sids channel.
   dasma = drop the held object + set an untainted-const action: a
   call_pres_act writer, REUSED from ObjectLeafSurface.dasma_row.  Its
   internal held-object drop bottoms out in three interaction externals
   (segmented_to_virtual / stop_shell_music / obj_set_held_state), all
   already in obj_ext_ids -- so NO new trust. ---- *)
Definition sta_dasma_sids : list ident :=
  mario._set_mario_action :: mario._drop_and_set_mario_action :: nil.

(* act_hold_heavy_idle: drop_and_set_mario_action(m, ACT, 0) x3 (the held
   "heavy" item idle) + smact-const exits + stationary_ground_step. *)
Example sta_hhi_pin :
  (prog_defmap mario_actions_stationary.prog)
    ! mario_actions_stationary._act_hold_heavy_idle
  = Some (Gfun (Internal mario_actions_stationary.f_act_hold_heavy_idle)).
Proof. vm_compute. reflexivity. Qed.
Example sta_hhi_vars :
  fn_vars mario_actions_stationary.f_act_hold_heavy_idle = nil.
Proof. vm_compute. reflexivity. Qed.
Example sta_hhi_params_ok :
  match fn_params mario_actions_stationary.f_act_hold_heavy_idle with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example sta_hhi_walk :
  wwalk_chk false nil sta_leaf_ids nil nil nil sta_dasma_sids nil
    (fn_body mario_actions_stationary.f_act_hold_heavy_idle) = true.
Proof. vm_compute. reflexivity. Qed.

(* act_slide_kick_slide_stop: drop_and_set_mario_action + stopping_step
   (the act3 channel) + smact-const exits. *)
Example sta_skss_pin :
  (prog_defmap mario_actions_stationary.prog)
    ! mario_actions_stationary._act_slide_kick_slide_stop
  = Some (Gfun (Internal mario_actions_stationary.f_act_slide_kick_slide_stop)).
Proof. vm_compute. reflexivity. Qed.
Example sta_skss_vars :
  fn_vars mario_actions_stationary.f_act_slide_kick_slide_stop = nil.
Proof. vm_compute. reflexivity. Qed.
Example sta_skss_params_ok :
  match fn_params mario_actions_stationary.f_act_slide_kick_slide_stop with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example sta_skss_walk :
  wwalk_chk false nil sta_leaf_ids nil nil nil sta_dasma_sids sta_braking_tids
    (fn_body mario_actions_stationary.f_act_slide_kick_slide_stop) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- landing_step: the act3 caller-action twin of stopping_step
   (params (_m, _arg1, _action); same body shape, threads _action into
   set_mario_action).  Reuses sta_ss_wact / sta_ss_ids. ---- *)
Definition sta_landing_tids : list ident :=
  mario_actions_stationary._landing_step :: nil.
Example sta_ls_pin :
  (prog_defmap mario_actions_stationary.prog)
    ! mario_actions_stationary._landing_step
  = Some (Gfun (Internal mario_actions_stationary.f_landing_step)).
Proof. vm_compute. reflexivity. Qed.
Example sta_ls_vars : fn_vars mario_actions_stationary.f_landing_step = nil.
Proof. vm_compute. reflexivity. Qed.
Example sta_ls_params :
  fn_params mario_actions_stationary.f_landing_step
  = (mario_actions_airborne._m, tyMSp)
      :: (mario_actions_stationary._arg1, tint)
      :: (mario_actions_stationary._action, tuint) :: nil.
Proof. vm_compute. reflexivity. Qed.
Example sta_ls_arg1_m :
  mario_actions_stationary._arg1 <> mario_actions_airborne._m.
Proof. vm_compute. discriminate. Qed.
Example sta_ls_arg1_nw :
  mem_id mario_actions_stationary._arg1 sta_ss_wact = false.
Proof. vm_compute. reflexivity. Qed.
Example sta_ls_walk :
  wwalk_chk false sta_ss_wact sta_ss_ids nil nil nil sta_sids nil
    (fn_body mario_actions_stationary.f_landing_step) = true.
Proof. vm_compute. reflexivity. Qed.

(* act_ground_pound_land: drop_and_set_mario_action (dasma) + landing_step
   (act3) + smact-const exits.  No A-gate, no cancel helper. *)
Example sta_gpl_pin :
  (prog_defmap mario_actions_stationary.prog)
    ! mario_actions_stationary._act_ground_pound_land
  = Some (Gfun (Internal mario_actions_stationary.f_act_ground_pound_land)).
Proof. vm_compute. reflexivity. Qed.
Example sta_gpl_vars :
  fn_vars mario_actions_stationary.f_act_ground_pound_land = nil.
Proof. vm_compute. reflexivity. Qed.
Example sta_gpl_params_ok :
  match fn_params mario_actions_stationary.f_act_ground_pound_land with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example sta_gpl_walk :
  wwalk_chk false nil sta_leaf_ids nil nil nil sta_dasma_sids sta_landing_tids
    (fn_body mario_actions_stationary.f_act_ground_pound_land) = true.
Proof. vm_compute. reflexivity. Qed.

(* ====================================================================== *)
(* SLICE 8: the "hold *_stop / *_land_stop" cluster reachable WITHOUT the  *)
(* A-gate.  These three hold leaves bottom out in                          *)
(* check_common_hold_action_exits (a smact-const exit twin of              *)
(* check_common_action_exits -- NO set_jumping_action, NO cancel helper),  *)
(* drop_and_set_mario_action (dasma), and stopping_step / landing_step     *)
(* (the act3 channel).  Every callee already has a row -- the only new      *)
(* brick is the cchae call_pres row (smact-const).  body_pres is MWF-only;  *)
(* the A-gate / flying concern is the SEPARATE Taint/AGates capstone        *)
(* component, irrelevant here.                                              *)
(* ====================================================================== *)

(* check_common_hold_action_exits: four input-gated set_mario_action(CONST)
   exits + return 0.  A loads-only smact-const helper (NO chase, NO store);
   call_pres via the smact channel, exactly like check_common_action_exits. *)
Definition sta_cchae_ids : list ident :=
  mario._check_common_hold_action_exits :: nil.
Example sta_cchae_pin :
  (prog_defmap mario.prog) ! mario._check_common_hold_action_exits
  = Some (Gfun (Internal mario.f_check_common_hold_action_exits)).
Proof. vm_compute. reflexivity. Qed.
Example sta_cchae_vars : fn_vars mario.f_check_common_hold_action_exits = nil.
Proof. vm_compute. reflexivity. Qed.
Example sta_cchae_params_ok :
  match fn_params mario.f_check_common_hold_action_exits with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example sta_cchae_walk :
  wwalk_chk false nil nil nil nil nil sta_sids nil
    (fn_body mario.f_check_common_hold_action_exits) = true.
Proof. vm_compute. reflexivity. Qed.

(* act_hold_butt_slide_stop: cchae + dasma + stopping_step (act3). *)
Example sta_hbss_pin :
  (prog_defmap mario_actions_stationary.prog)
    ! mario_actions_stationary._act_hold_butt_slide_stop
  = Some (Gfun (Internal mario_actions_stationary.f_act_hold_butt_slide_stop)).
Proof. vm_compute. reflexivity. Qed.
Example sta_hbss_vars :
  fn_vars mario_actions_stationary.f_act_hold_butt_slide_stop = nil.
Proof. vm_compute. reflexivity. Qed.
Example sta_hbss_params_ok :
  match fn_params mario_actions_stationary.f_act_hold_butt_slide_stop with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example sta_hbss_walk :
  wwalk_chk false nil sta_cchae_ids nil nil nil sta_dasma_sids sta_braking_tids
    (fn_body mario_actions_stationary.f_act_hold_butt_slide_stop) = true.
Proof. vm_compute. reflexivity. Qed.

(* act_hold_freefall_land_stop: cchae + dasma + landing_step (act3). *)
Example sta_hffls_pin :
  (prog_defmap mario_actions_stationary.prog)
    ! mario_actions_stationary._act_hold_freefall_land_stop
  = Some (Gfun (Internal mario_actions_stationary.f_act_hold_freefall_land_stop)).
Proof. vm_compute. reflexivity. Qed.
Example sta_hffls_vars :
  fn_vars mario_actions_stationary.f_act_hold_freefall_land_stop = nil.
Proof. vm_compute. reflexivity. Qed.
Example sta_hffls_params_ok :
  match fn_params mario_actions_stationary.f_act_hold_freefall_land_stop with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example sta_hffls_walk :
  wwalk_chk false nil sta_cchae_ids nil nil nil sta_dasma_sids sta_landing_tids
    (fn_body mario_actions_stationary.f_act_hold_freefall_land_stop) = true.
Proof. vm_compute. reflexivity. Qed.

(* act_hold_jump_land_stop: cchae + dasma + landing_step (act3). *)
Example sta_hjls_pin :
  (prog_defmap mario_actions_stationary.prog)
    ! mario_actions_stationary._act_hold_jump_land_stop
  = Some (Gfun (Internal mario_actions_stationary.f_act_hold_jump_land_stop)).
Proof. vm_compute. reflexivity. Qed.
Example sta_hjls_vars :
  fn_vars mario_actions_stationary.f_act_hold_jump_land_stop = nil.
Proof. vm_compute. reflexivity. Qed.
Example sta_hjls_params_ok :
  match fn_params mario_actions_stationary.f_act_hold_jump_land_stop with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example sta_hjls_walk :
  wwalk_chk false nil sta_cchae_ids nil nil nil sta_dasma_sids sta_landing_tids
    (fn_body mario_actions_stationary.f_act_hold_jump_land_stop) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- act_twirl_land: the chase-store leaf (cact) ----
   Bottoms out in is_anim_at_end / set_mario_animation / stationary_ground_step
   (= sta_ss_ids) + set_mario_action(CONST) exits.  Its writes are window
   stores (m->actionState; the m->angleVel[1]/faceAngle[1] indexed-window
   shorts) PLUS ONE chase store through marioObj:
     m->marioObj(_t'8)->header.gfx.angle[1] = twirlYaw + ..
   so the marioObj chase temp _t'8 goes in cact and the store is recognised by
   chase_store_chk.  Walked with body_pres_of_wwalk_cact (wact = nil). *)
Definition sta_twl_cact : list ident := mario_actions_stationary._t'8 :: nil.
Example sta_twl_pin :
  (prog_defmap mario_actions_stationary.prog)
    ! mario_actions_stationary._act_twirl_land
  = Some (Gfun (Internal mario_actions_stationary.f_act_twirl_land)).
Proof. vm_compute. reflexivity. Qed.
Example sta_twl_vars : fn_vars mario_actions_stationary.f_act_twirl_land = nil.
Proof. vm_compute. reflexivity. Qed.
Example sta_twl_params_ok :
  match fn_params mario_actions_stationary.f_act_twirl_land with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example sta_twl_nonparam :
  forallb (fun t' => negb (mem_id t'
             (map fst (fn_params mario_actions_stationary.f_act_twirl_land))))
    sta_twl_cact = true.
Proof. vm_compute. reflexivity. Qed.
Example sta_twl_walk :
  wwalk_chk false nil sta_ss_ids nil sta_twl_cact nil sta_sids nil
    (fn_body mario_actions_stationary.f_act_twirl_land) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- SLICE 9: act_air_throw_land via mario_throw_held_object (cact) ----
   act_air_throw_land = set_mario_action(CONST) exits + an m->actionTimer
   window store + mario_throw_held_object(m) + landing_step(m,CONST,CONST)
   (act3).  mario_throw_held_object [interaction.prog] drops + throws the held
   object: it chases m->heldObj / m->marioBodyState and stores through those
   chased pointers (cact = mtho_cact), and its only externals are the THREE
   held-object externals (segmented_to_virtual / stop_shell_music /
   obj_set_held_state) -- ALL in obj_ext_ids, already threaded as Hcpx_s2v /
   Hcpx_ssm / Hcpx_oshs (ZERO new trust). *)
Definition mtho_xids : list ident :=
  interaction._segmented_to_virtual :: interaction._stop_shell_music
    :: interaction._obj_set_held_state :: nil.
Definition mtho_cact : list ident :=
  interaction._t'2 :: interaction._t'3 :: interaction._t'5 :: interaction._t'6
   :: interaction._t'10 :: interaction._t'11 :: interaction._t'13
   :: interaction._t'14 :: interaction._t'18 :: interaction._t'19 :: nil.
Example mtho_pin :
  (prog_defmap interaction.prog) ! interaction._mario_throw_held_object
  = Some (Gfun (Internal interaction.f_mario_throw_held_object)).
Proof. vm_compute. reflexivity. Qed.
Example mtho_vars : fn_vars interaction.f_mario_throw_held_object = nil.
Proof. vm_compute. reflexivity. Qed.
Example mtho_params_ok :
  match fn_params interaction.f_mario_throw_held_object with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example mtho_nonparam :
  forallb (fun t' => negb (mem_id t'
             (map fst (fn_params interaction.f_mario_throw_held_object))))
    mtho_cact = true.
Proof. vm_compute. reflexivity. Qed.
Example mtho_walk :
  wwalk_chk false nil nil nil mtho_cact mtho_xids nil nil
    (fn_body interaction.f_mario_throw_held_object) = true.
Proof. vm_compute. reflexivity. Qed.

Definition sta_atl_ids : list ident :=
  interaction._mario_throw_held_object :: nil.
Example sta_atl_pin :
  (prog_defmap mario_actions_stationary.prog)
    ! mario_actions_stationary._act_air_throw_land
  = Some (Gfun (Internal mario_actions_stationary.f_act_air_throw_land)).
Proof. vm_compute. reflexivity. Qed.
Example sta_atl_vars :
  fn_vars mario_actions_stationary.f_act_air_throw_land = nil.
Proof. vm_compute. reflexivity. Qed.
Example sta_atl_params_ok :
  match fn_params mario_actions_stationary.f_act_air_throw_land with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example sta_atl_walk :
  wwalk_chk false nil sta_atl_ids nil nil nil sta_sids sta_landing_tids
    (fn_body mario_actions_stationary.f_act_air_throw_land) = true.
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

(* the stationary family's OWN external-model-boundary census: the
   background-noise / sound-stop AUDIO externals.  Each is EF_external in
   every generated TU (no Internal definition anywhere -- audio engine,
   outside our linked set), so each writes no Mario state: the SAME honest
   model class as play_sound / the obj_ext_ids audio rows.  Discharged at
   the capstone by the standing Hpres_sta_ext boundary hypothesis. *)
Definition sta_ext_ids : list ident :=
  mario_actions_stationary._raise_background_noise
    :: mario_actions_stationary._lower_background_noise
    :: mario_actions_stationary._stop_sound
    (* SLICE 15: act_sleeping's two extra audio externals -- both EF_external in
       every linked TU (verified Internal/External probe), write no Mario state,
       the SAME honest model-boundary class. *)
    :: mario_actions_stationary._play_mario_heavy_landing_sound
    :: mario_actions_stationary._play_sound_if_no_flag :: nil.

(* act_waking_up's two externals (subset of sta_ext_ids) *)
Definition sta_waking_xids : list ident :=
  mario_actions_stationary._stop_sound
    :: mario_actions_stationary._raise_background_noise :: nil.

Example sta_awku_pin :
  (prog_defmap mario_actions_stationary.prog)
    ! mario_actions_stationary._act_waking_up
  = Some (Gfun (Internal mario_actions_stationary.f_act_waking_up)).
Proof. vm_compute. reflexivity. Qed.
Example sta_awku_vars :
  fn_vars mario_actions_stationary.f_act_waking_up = nil.
Proof. vm_compute. reflexivity. Qed.
Example sta_awku_params_ok :
  match fn_params mario_actions_stationary.f_act_waking_up with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example sta_awku_walk :
  wwalk_chk false nil sta_leaf_ids nil nil sta_waking_xids sta_sids nil
    (fn_body mario_actions_stationary.f_act_waking_up) = true.
Proof. vm_compute. reflexivity. Qed.

(* the unwalked remainder of stationary_callee_ids (filter, not a
   hand-spelled list -- shrinks automatically as leaves move out) *)
Definition sta_walked_ids : list ident :=
  mario_actions_stationary._act_standing_against_wall
    :: mario_actions_stationary._act_start_crawling
    :: mario_actions_stationary._act_stop_crawling
    :: mario_actions_stationary._act_shivering
    :: mario_actions_stationary._act_waking_up
    :: mario_actions_stationary._act_braking_stop
    :: mario_actions_stationary._act_butt_slide_stop
    :: mario_actions_stationary._act_hold_heavy_idle
    :: mario_actions_stationary._act_slide_kick_slide_stop
    :: mario_actions_stationary._act_ground_pound_land
    :: mario_actions_stationary._act_hold_butt_slide_stop
    :: mario_actions_stationary._act_hold_freefall_land_stop
    :: mario_actions_stationary._act_hold_jump_land_stop
    :: mario_actions_stationary._act_twirl_land
    :: mario_actions_stationary._act_air_throw_land
    :: mario_actions_stationary._act_crouching
    :: mario_actions_stationary._act_start_crouching
    :: mario_actions_stationary._act_stop_crouching
    :: mario_actions_stationary._act_in_quicksand
    :: mario_actions_stationary._act_coughing
    :: mario_actions_stationary._act_panting
    :: mario_actions_stationary._act_hold_idle
    :: mario_actions_stationary._act_hold_panting_unused
    :: mario_actions_stationary._act_start_sleeping
    :: mario_actions_stationary._act_idle
    :: mario_actions_stationary._act_sleeping :: nil.
Definition sta_rest_ids : list ident :=
  filter (fun id => negb (mem_id id sta_walked_ids)) stationary_callee_ids.

(* ---- the set_jumping_action arc shape pins ---- *)

(* mario_floor_is_steep: call_pres; loads m->floor into an UNTRACKED
   pointer temp (read-through only, never stored), so cact = nil. *)
Example sta_mfis_pin :
  (prog_defmap mario.prog) ! mario._mario_floor_is_steep
  = Some (Gfun (Internal mario.f_mario_floor_is_steep)).
Proof. vm_compute. reflexivity. Qed.
Example sta_mfis_vars : fn_vars mario.f_mario_floor_is_steep = nil.
Proof. vm_compute. reflexivity. Qed.
Example sta_mfis_params_ok :
  match fn_params mario.f_mario_floor_is_steep with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example sta_mfis_walk :
  wwalk_chk false nil sta_mfis_ids nil nil nil nil nil
    (fn_body mario.f_mario_floor_is_steep) = true.
Proof. vm_compute. reflexivity. Qed.

(* set_steep_jump_action: call_pres; marioObj chase store (cact=[_t'10]),
   sqrtf/atan2s math externals, drop_and_set_mario_action channel. *)
Example sta_sssja_pin :
  (prog_defmap mario.prog) ! mario._set_steep_jump_action
  = Some (Gfun (Internal mario.f_set_steep_jump_action)).
Proof. vm_compute. reflexivity. Qed.
Example sta_sssja_vars : fn_vars mario.f_set_steep_jump_action = nil.
Proof. vm_compute. reflexivity. Qed.
Example sta_sssja_params_ok :
  match fn_params mario.f_set_steep_jump_action with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example sta_sssja_nonparam :
  forallb (fun t' => negb (mem_id t'
             (map fst (fn_params mario.f_set_steep_jump_action))))
    sta_sssja_cact = true.
Proof. vm_compute. reflexivity. Qed.
Example sta_sssja_walk :
  wwalk_chk false nil nil nil sta_sssja_cact sta_sssja_xids sta_sssja_sids nil
    (fn_body mario.f_set_steep_jump_action) = true.
Proof. vm_compute. reflexivity. Qed.

(* set_jumping_action: call_pres_act (threads _action to set_mario_action).
   Its quicksand branch `_t = set_mario_action(m, ACT_QUICKSAND_JUMP_LAND,0);
   return _t` is the const-result-into-wact pattern -- wact=[_action;_t'1;_t'2],
   wids=sids=[set_mario_action], ids=[mfis; sssja].  _t'5 (heldObj) is an
   untracked pointer temp (compared to NULL only), so cact=nil. *)
Example sta_sja_pin :
  (prog_defmap mario.prog) ! mario._set_jumping_action
  = Some (Gfun (Internal mario.f_set_jumping_action)).
Proof. vm_compute. reflexivity. Qed.
Example sta_sja_vars : fn_vars mario.f_set_jumping_action = nil.
Proof. vm_compute. reflexivity. Qed.
Example sta_sja_params :
  fn_params mario.f_set_jumping_action = writer_params.
Proof. vm_compute. reflexivity. Qed.
Example sta_sja_ret : i32_ty (fn_return mario.f_set_jumping_action) = true.
Proof. vm_compute. reflexivity. Qed.
Example sta_sja_walk :
  wwalk_chk true
    (mario._action :: mario._t'1 :: mario._t'2 :: nil)
    sta_sja_ids sta_sids nil nil sta_sids nil
    (fn_body mario.f_set_jumping_action) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- the three crouch leaves (ids = sta_leaf_ids, sids = sma +
   set_jumping_action).  Same shape; input-gated smact/sja const exits +
   stationary_ground_step + set_mario_animation + is_anim_past_end. ---- *)
Example sta_crouch_pin :
  (prog_defmap mario_actions_stationary.prog)
    ! mario_actions_stationary._act_crouching
  = Some (Gfun (Internal mario_actions_stationary.f_act_crouching)).
Proof. vm_compute. reflexivity. Qed.
Example sta_crouch_vars :
  fn_vars mario_actions_stationary.f_act_crouching = nil.
Proof. vm_compute. reflexivity. Qed.
Example sta_crouch_params_ok :
  match fn_params mario_actions_stationary.f_act_crouching with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example sta_crouch_walk :
  wwalk_chk false nil sta_leaf_ids nil nil nil sta_crouch_sids nil
    (fn_body mario_actions_stationary.f_act_crouching) = true.
Proof. vm_compute. reflexivity. Qed.

Example sta_scrouch_pin :
  (prog_defmap mario_actions_stationary.prog)
    ! mario_actions_stationary._act_start_crouching
  = Some (Gfun (Internal mario_actions_stationary.f_act_start_crouching)).
Proof. vm_compute. reflexivity. Qed.
Example sta_scrouch_vars :
  fn_vars mario_actions_stationary.f_act_start_crouching = nil.
Proof. vm_compute. reflexivity. Qed.
Example sta_scrouch_params_ok :
  match fn_params mario_actions_stationary.f_act_start_crouching with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example sta_scrouch_walk :
  wwalk_chk false nil sta_leaf_ids nil nil nil sta_crouch_sids nil
    (fn_body mario_actions_stationary.f_act_start_crouching) = true.
Proof. vm_compute. reflexivity. Qed.

Example sta_pcrouch_pin :
  (prog_defmap mario_actions_stationary.prog)
    ! mario_actions_stationary._act_stop_crouching
  = Some (Gfun (Internal mario_actions_stationary.f_act_stop_crouching)).
Proof. vm_compute. reflexivity. Qed.
Example sta_pcrouch_vars :
  fn_vars mario_actions_stationary.f_act_stop_crouching = nil.
Proof. vm_compute. reflexivity. Qed.
Example sta_pcrouch_params_ok :
  match fn_params mario_actions_stationary.f_act_stop_crouching with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example sta_pcrouch_walk :
  wwalk_chk false nil sta_leaf_ids nil nil nil sta_crouch_sids nil
    (fn_body mario_actions_stationary.f_act_stop_crouching) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- SLICE 11 shape pins ---- *)

(* mario_push_off_steep_floor: call_pres_act -- writer_params, threads
   _action to set_mario_action; stores m->forwardVel + m->faceAngle[1]
   (idx16 window).  wact = [_action; _t'2] (the returned set_mario_action
   result), wids = sids = [set_mario_action].  Lives in mario_step.prog. *)
Example sta_pushoff_pin :
  (prog_defmap mario_step.prog) ! mario_step._mario_push_off_steep_floor
  = Some (Gfun (Internal mario_step.f_mario_push_off_steep_floor)).
Proof. vm_compute. reflexivity. Qed.
Example sta_pushoff_vars :
  fn_vars mario_step.f_mario_push_off_steep_floor = nil.
Proof. vm_compute. reflexivity. Qed.
Example sta_pushoff_params :
  fn_params mario_step.f_mario_push_off_steep_floor = writer_params.
Proof. vm_compute. reflexivity. Qed.
Example sta_pushoff_ret :
  i32_ty (fn_return mario_step.f_mario_push_off_steep_floor) = true.
Proof. vm_compute. reflexivity. Qed.
Example sta_pushoff_walk :
  wwalk_chk true sta_pushoff_wact nil sta_sids nil nil sta_sids nil
    (fn_body mario_step.f_mario_push_off_steep_floor) = true.
Proof. vm_compute. reflexivity. Qed.

(* check_common_idle_cancels: call_pres.  m->floor/heldObj read-through ptr
   temps (UNTRACKED, cact=nil); ids=[mario_drop_held_object]; sids = the
   const-action exits (sma / sja / push_off). *)
Example sta_ccic_pin :
  (prog_defmap mario_actions_stationary.prog)
    ! mario_actions_stationary._check_common_idle_cancels
  = Some (Gfun (Internal mario_actions_stationary.f_check_common_idle_cancels)).
Proof. vm_compute. reflexivity. Qed.
Example sta_ccic_vars :
  fn_vars mario_actions_stationary.f_check_common_idle_cancels = nil.
Proof. vm_compute. reflexivity. Qed.
Example sta_ccic_params_ok :
  match fn_params mario_actions_stationary.f_check_common_idle_cancels with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example sta_ccic_walk :
  wwalk_chk false nil sta_ccic_ids nil nil nil sta_ccic_sids nil
    (fn_body mario_actions_stationary.f_check_common_idle_cancels) = true.
Proof. vm_compute. reflexivity. Qed.

(* the three clean idle leaves *)
Example sta_inqs_pin :
  (prog_defmap mario_actions_stationary.prog)
    ! mario_actions_stationary._act_in_quicksand
  = Some (Gfun (Internal mario_actions_stationary.f_act_in_quicksand)).
Proof. vm_compute. reflexivity. Qed.
Example sta_inqs_vars :
  fn_vars mario_actions_stationary.f_act_in_quicksand = nil.
Proof. vm_compute. reflexivity. Qed.
Example sta_inqs_params_ok :
  match fn_params mario_actions_stationary.f_act_in_quicksand with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example sta_inqs_walk :
  wwalk_chk false nil sta_idle_ids nil nil nil sta_sids nil
    (fn_body mario_actions_stationary.f_act_in_quicksand) = true.
Proof. vm_compute. reflexivity. Qed.

Example sta_cough_pin :
  (prog_defmap mario_actions_stationary.prog)
    ! mario_actions_stationary._act_coughing
  = Some (Gfun (Internal mario_actions_stationary.f_act_coughing)).
Proof. vm_compute. reflexivity. Qed.
Example sta_cough_vars :
  fn_vars mario_actions_stationary.f_act_coughing = nil.
Proof. vm_compute. reflexivity. Qed.
Example sta_cough_params_ok :
  match fn_params mario_actions_stationary.f_act_coughing with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example sta_cough_walk :
  wwalk_chk false nil sta_idle_ids nil nil sta_psound_xids sta_sids nil
    (fn_body mario_actions_stationary.f_act_coughing) = true.
Proof. vm_compute. reflexivity. Qed.

Example sta_pant_pin :
  (prog_defmap mario_actions_stationary.prog)
    ! mario_actions_stationary._act_panting
  = Some (Gfun (Internal mario_actions_stationary.f_act_panting)).
Proof. vm_compute. reflexivity. Qed.
Example sta_pant_vars :
  fn_vars mario_actions_stationary.f_act_panting = nil.
Proof. vm_compute. reflexivity. Qed.
Example sta_pant_params_ok :
  match fn_params mario_actions_stationary.f_act_panting with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example sta_pant_nonparam :
  forallb (fun t' => negb (mem_id t'
             (map fst (fn_params mario_actions_stationary.f_act_panting))))
    sta_panting_cact = true.
Proof. vm_compute. reflexivity. Qed.
Example sta_pant_walk :
  wwalk_chk false nil sta_idle_ids nil sta_panting_cact sta_psound_xids
    sta_sids nil
    (fn_body mario_actions_stationary.f_act_panting) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- SLICE 14 shape pins: act_idle ---- *)
Example sta_idle2_pin :
  (prog_defmap mario_actions_stationary.prog)
    ! mario_actions_stationary._act_idle
  = Some (Gfun (Internal mario_actions_stationary.f_act_idle)).
Proof. vm_compute. reflexivity. Qed.
Example sta_idle2_vars :
  fn_vars mario_actions_stationary.f_act_idle = nil.
Proof. vm_compute. reflexivity. Qed.
Example sta_idle2_params_ok :
  match fn_params mario_actions_stationary.f_act_idle with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example sta_idle2_walk :
  wwalk_chk false nil sta_idle2_ids nil nil nil sta_sids nil
    (fn_body mario_actions_stationary.f_act_idle) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- SLICE 15 shape pins: act_sleeping ---- *)
Example sta_sleep_pin :
  (prog_defmap mario_actions_stationary.prog)
    ! mario_actions_stationary._act_sleeping
  = Some (Gfun (Internal mario_actions_stationary.f_act_sleeping)).
Proof. vm_compute. reflexivity. Qed.
Example sta_sleep_vars :
  fn_vars mario_actions_stationary.f_act_sleeping = nil.
Proof. vm_compute. reflexivity. Qed.
Example sta_sleep_params_ok :
  match fn_params mario_actions_stationary.f_act_sleeping with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example sta_sleep_nonparam :
  forallb (fun t' => negb (mem_id t'
             (map fst (fn_params mario_actions_stationary.f_act_sleeping))))
    sta_sleep_cact = true.
Proof. vm_compute. reflexivity. Qed.
Example sta_sleep_walk :
  wwalk_chk false nil sta_sleep_ids nil sta_sleep_cact sta_sleep_xids
    sta_sids nil
    (fn_body mario_actions_stationary.f_act_sleeping) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- SLICE 12 shape pins ---- *)

(* check_common_hold_idle_cancels: call_pres.  cact=[_t'20] for the held-object
   flag-clear chase store; sids = sma/sja/push_off/dasma const exits. *)
Example sta_cchic_pin :
  (prog_defmap mario_actions_stationary.prog)
    ! mario_actions_stationary._check_common_hold_idle_cancels
  = Some (Gfun (Internal
      mario_actions_stationary.f_check_common_hold_idle_cancels)).
Proof. vm_compute. reflexivity. Qed.
Example sta_cchic_vars :
  fn_vars mario_actions_stationary.f_check_common_hold_idle_cancels = nil.
Proof. vm_compute. reflexivity. Qed.
Example sta_cchic_params_ok :
  match fn_params mario_actions_stationary.f_check_common_hold_idle_cancels with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example sta_cchic_nonparam :
  forallb (fun t' => negb (mem_id t'
             (map fst (fn_params
                mario_actions_stationary.f_check_common_hold_idle_cancels))))
    sta_cchic_cact = true.
Proof. vm_compute. reflexivity. Qed.
Example sta_cchic_walk :
  wwalk_chk false nil nil nil sta_cchic_cact nil sta_cchic_sids nil
    (fn_body mario_actions_stationary.f_check_common_hold_idle_cancels) = true.
Proof. vm_compute. reflexivity. Qed.

(* act_hold_idle: compares a segmented_to_virtual pointer (xids=[s2v]); cact=nil. *)
Example sta_hidle_pin :
  (prog_defmap mario_actions_stationary.prog)
    ! mario_actions_stationary._act_hold_idle
  = Some (Gfun (Internal mario_actions_stationary.f_act_hold_idle)).
Proof. vm_compute. reflexivity. Qed.
Example sta_hidle_vars :
  fn_vars mario_actions_stationary.f_act_hold_idle = nil.
Proof. vm_compute. reflexivity. Qed.
Example sta_hidle_params_ok :
  match fn_params mario_actions_stationary.f_act_hold_idle with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example sta_hidle_walk :
  wwalk_chk false nil sta_hidle_ids nil nil sta_s2v_xids sta_dasma_sids nil
    (fn_body mario_actions_stationary.f_act_hold_idle) = true.
Proof. vm_compute. reflexivity. Qed.

(* act_hold_panting_unused: marioBodyState->eyeState chase store (cact=[_t'5]). *)
Example sta_hpant_pin :
  (prog_defmap mario_actions_stationary.prog)
    ! mario_actions_stationary._act_hold_panting_unused
  = Some (Gfun (Internal mario_actions_stationary.f_act_hold_panting_unused)).
Proof. vm_compute. reflexivity. Qed.
Example sta_hpant_vars :
  fn_vars mario_actions_stationary.f_act_hold_panting_unused = nil.
Proof. vm_compute. reflexivity. Qed.
Example sta_hpant_params_ok :
  match fn_params mario_actions_stationary.f_act_hold_panting_unused with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example sta_hpant_nonparam :
  forallb (fun t' => negb (mem_id t'
             (map fst (fn_params
                mario_actions_stationary.f_act_hold_panting_unused))))
    sta_hpant_cact = true.
Proof. vm_compute. reflexivity. Qed.
Example sta_hpant_walk :
  wwalk_chk false nil sta_hidle_ids nil sta_hpant_cact nil sta_dasma_sids nil
    (fn_body mario_actions_stationary.f_act_hold_panting_unused) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- SLICE 13 shape pins ---- *)

(* play_anim_sound: call_pres.  Params (_m,_actionState,_animFrame,_sound) --
   first is _m so params_ok holds.  Reads only; calls play_sound (xids). *)
Example sta_pas_pin :
  (prog_defmap mario_actions_stationary.prog)
    ! mario_actions_stationary._play_anim_sound
  = Some (Gfun (Internal mario_actions_stationary.f_play_anim_sound)).
Proof. vm_compute. reflexivity. Qed.
Example sta_pas_vars :
  fn_vars mario_actions_stationary.f_play_anim_sound = nil.
Proof. vm_compute. reflexivity. Qed.
Example sta_pas_params_ok :
  match fn_params mario_actions_stationary.f_play_anim_sound with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example sta_pas_walk :
  wwalk_chk false nil nil nil nil sta_psound_xids nil nil
    (fn_body mario_actions_stationary.f_play_anim_sound) = true.
Proof. vm_compute. reflexivity. Qed.

(* act_start_sleeping *)
Example sta_ssleep_pin :
  (prog_defmap mario_actions_stationary.prog)
    ! mario_actions_stationary._act_start_sleeping
  = Some (Gfun (Internal mario_actions_stationary.f_act_start_sleeping)).
Proof. vm_compute. reflexivity. Qed.
Example sta_ssleep_vars :
  fn_vars mario_actions_stationary.f_act_start_sleeping = nil.
Proof. vm_compute. reflexivity. Qed.
Example sta_ssleep_params_ok :
  match fn_params mario_actions_stationary.f_act_start_sleeping with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example sta_ssleep_nonparam :
  forallb (fun t' => negb (mem_id t'
             (map fst (fn_params
                mario_actions_stationary.f_act_start_sleeping))))
    sta_ssleep_cact = true.
Proof. vm_compute. reflexivity. Qed.
Example sta_ssleep_walk :
  wwalk_chk false nil sta_ssleep_ids nil sta_ssleep_cact sta_psound_xids
    sta_sids nil
    (fn_body mario_actions_stationary.f_act_start_sleeping) = true.
Proof. vm_compute. reflexivity. Qed.

(* ====================================================================== *)
(* The walk.                                                              *)
(* ====================================================================== *)

Section StationaryLeafRows.
  Variable lp : Clight.program.
  Hypothesis LO_mario : linkorder mario.prog lp.
  Hypothesis LO_mario_step : linkorder mario_step.prog lp.
  Hypothesis LO_sta : linkorder mario_actions_stationary.prog lp.
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
  (* the stationary family's audio externals (raise/lower_background_noise,
     stop_sound) -- the SAME honest model-boundary class as play_sound; each
     is EF_external in every linked TU.  Discharged at the capstone. *)
  Hypothesis Hpres_sta_ext : forall fid,
      mem_id fid sta_ext_ids = true -> call_pres_ext lp bm NoA MWF fid.
  (* perform_ground_step: discharged at the capstone (MarioStepSurface) *)
  Hypothesis Hcp_pgs :
    call_pres lp bm NoA MWF mario_step._perform_ground_step.
  (* the three interaction externals the dasma (drop_and_set_mario_action)
     held-object drop bottoms out in -- all in obj_ext_ids (NO new trust);
     discharged at the capstone via Hpres_obj_ext. *)
  Hypothesis Hcpx_s2v :
    call_pres_ext lp bm NoA MWF interaction._segmented_to_virtual.
  Hypothesis Hcpx_ssm :
    call_pres_ext lp bm NoA MWF interaction._stop_shell_music.
  Hypothesis Hcpx_oshs :
    call_pres_ext lp bm NoA MWF interaction._obj_set_held_state.
  (* set_steep_jump_action's two math externals (the steep-jump face-angle
     trig): both in obj_ext_ids -- NO new trust, discharged at the capstone
     via Hpres_obj_ext. *)
  Hypothesis Hcpx_sqrtf :
    call_pres_ext lp bm NoA MWF mario._sqrtf.
  Hypothesis Hcpx_atan2s :
    call_pres_ext lp bm NoA MWF mario._atan2s.
  (* SLICE 14: find_floor_height_relative_polar -- the out-param helper act_idle
     calls (it calls find_floor(x,y,z,&_floor) into a stack local).  This is the
     PROVED AutomaticLeafSurface.Hffhrp (call_pres_of_lwalk2 over the oc-arc);
     discharged at the capstone, NOT new trust. *)
  Hypothesis Hffhrp_sta :
    call_pres lp bm NoA MWF mario._find_floor_height_relative_polar.

  (* the keystone, instantiated once *)
  Let Hsmact : call_pres_act lp bm NoA MWF mario._set_mario_action :=
    smact_pres lp LO_mario LO_mario_step bm NoA MWF HNoA_of_MWF
      HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
      HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe.

  (* drop_and_set_mario_action's call_pres_act row, REUSED from
     ObjectLeafSurface.dasma_row. *)
  Let Hdasma : call_pres_act lp bm NoA MWF mario._drop_and_set_mario_action :=
    dasma_row lp LO_mario LO_mario_step LO_int bm NoA MWF HNoA_of_MWF
      HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
      HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
      Hcpx_s2v Hcpx_ssm Hcpx_oshs.

  Lemma sta_dasma_sids_rows : forall fid, mem_id fid sta_dasma_sids = true ->
      call_pres_act lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sta_dasma_sids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsmact | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hdasma | ].
    discriminate H.
  Qed.

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

  (* ---- is_anim_at_end (the loads-only at-end twin of is_anim_past_end) ---- *)
  Lemma sta_iae_row : call_pres lp bm NoA MWF mario._is_anim_at_end.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario.prog mario._is_anim_at_end
             mario.f_is_anim_at_end nil nil nil nil
             LO_mario sta_iae_pin sta_iae_vars sta_iae_params_ok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sta_iae_walk.
  Qed.

  (* ---- stopping_step's ids sub-tree, then its act3 row ---- *)
  Lemma sta_ss_ids_rows : forall fid, mem_id fid sta_ss_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sta_ss_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sta_sgs_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sta_sma_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sta_iae_row | ].
    discriminate H.
  Qed.

  Lemma sta_stopping_step_act3 :
    call_pres_act3 lp bm NoA MWF mario_actions_stationary._stopping_step.
  Proof.
    apply (call_pres_act3_of_wwalk_p lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_stationary.prog
             mario_actions_stationary._stopping_step
             mario_actions_stationary.f_stopping_step
             sta_ss_wact sta_ss_ids nil nil nil sta_sids
             mario_actions_stationary._animID mario_actions_stationary._action
             LO_sta sta_ss_pin sta_ss_vars sta_ss_params
             sta_ss_aid_m sta_ss_eid_m sta_ss_wa sta_ss_wm sta_ss_wanim
             eq_refl eq_refl eq_refl).
    - exact sta_ss_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sta_sids_rows.
    - exact sta_ss_walk.
  Qed.

  Lemma sta_braking_tids_rows :
    forall fid, mem_id fid sta_braking_tids = true ->
      call_pres_act3 lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sta_braking_tids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sta_stopping_step_act3 | ].
    discriminate H.
  Qed.

  Lemma sta_landing_step_act3 :
    call_pres_act3 lp bm NoA MWF mario_actions_stationary._landing_step.
  Proof.
    apply (call_pres_act3_of_wwalk_p lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_stationary.prog
             mario_actions_stationary._landing_step
             mario_actions_stationary.f_landing_step
             sta_ss_wact sta_ss_ids nil nil nil sta_sids
             mario_actions_stationary._arg1 mario_actions_stationary._action
             LO_sta sta_ls_pin sta_ls_vars sta_ls_params
             sta_ls_arg1_m sta_ss_eid_m sta_ss_wa sta_ss_wm sta_ls_arg1_nw
             eq_refl eq_refl eq_refl).
    - exact sta_ss_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sta_sids_rows.
    - exact sta_ls_walk.
  Qed.

  Lemma sta_landing_tids_rows :
    forall fid, mem_id fid sta_landing_tids = true ->
      call_pres_act3 lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sta_landing_tids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sta_landing_step_act3 | ].
    discriminate H.
  Qed.

  (* ---- the landing-sound helper chain ---- *)
  Lemma sta_pssp_row :
    call_pres lp bm NoA MWF mario._play_sound_and_spawn_particles.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario.prog mario._play_sound_and_spawn_particles
             mario.f_play_sound_and_spawn_particles nil nil sta_psound_xids nil
             LO_mario sta_pssp_pin sta_pssp_vars sta_pssp_params_ok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. unfold sta_psound_xids in H. cbn [mem_id existsb] in H.
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hcpx_psound | ].
      discriminate H.
    - intros fid' H. discriminate H.
    - exact sta_pssp_walk.
  Qed.

  Lemma sta_pmls_ids_rows : forall fid, mem_id fid sta_pmls_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sta_pmls_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sta_pssp_row | ].
    discriminate H.
  Qed.

  Lemma sta_pmls_row :
    call_pres lp bm NoA MWF mario._play_mario_landing_sound.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario.prog mario._play_mario_landing_sound
             mario.f_play_mario_landing_sound sta_pmls_ids nil nil nil
             LO_mario sta_pmls_pin sta_pmls_vars sta_pmls_params_ok).
    - exact sta_pmls_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sta_pmls_walk.
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

  (* act_butt_slide_stop's ids = play_mario_landing_sound + the shared leaf
     helper census (dispatched by sta_leaf_ids_rows above) *)
  Lemma sta_bss_ids_rows : forall fid, mem_id fid sta_bss_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sta_bss_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sta_pmls_row | ].
    apply sta_leaf_ids_rows. exact H.
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

  (* act_waking_up: wake-from-sleep.  Calls stop_sound x3 +
     raise_background_noise (the audio externals), set_mario_action x4 with
     constant action ids (the smact-const channel), an m->actionTimer window
     store, set_mario_animation(m, const), and stationary_ground_step. *)
  Lemma sta_awku_xids_rows : forall fid, mem_id fid sta_waking_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sta_waking_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid;
        apply Hpres_sta_ext; vm_compute; reflexivity | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid;
        apply Hpres_sta_ext; vm_compute; reflexivity | ].
    discriminate H.
  Qed.

  Lemma act_waking_up_pres :
    body_pres lp NoA MWF bm
      mario_actions_stationary.f_act_waking_up.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_stationary.f_act_waking_up
             sta_leaf_ids nil sta_waking_xids sta_sids nil
             sta_awku_vars sta_awku_params_ok).
    - exact sta_leaf_ids_rows.
    - intros fid' H. discriminate H.
    - exact sta_awku_xids_rows.
    - exact sta_sids_rows.
    - intros fid' H. discriminate H.
    - exact sta_awku_walk.
  Qed.

  (* act_braking_stop: the cleanest of the *_stop cluster -- it bottoms out
     in stopping_step (the act3-channel caller-action helper) + smact-const
     exits + check_common_action_exits.  No A-gate, no cancel helper. *)
  Lemma act_braking_stop_pres :
    body_pres lp NoA MWF bm
      mario_actions_stationary.f_act_braking_stop.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_stationary.f_act_braking_stop
             sta_leaf_ids nil nil sta_sids sta_braking_tids
             sta_abs_vars sta_abs_params_ok).
    - exact sta_leaf_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sta_sids_rows.
    - exact sta_braking_tids_rows.
    - exact sta_abs_walk.
  Qed.

  (* act_butt_slide_stop: stopping_step (act3) + play_mario_landing_sound
     (the internal landing-sound helper chain) + smact-const exits. *)
  Lemma act_butt_slide_stop_pres :
    body_pres lp NoA MWF bm
      mario_actions_stationary.f_act_butt_slide_stop.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_stationary.f_act_butt_slide_stop
             sta_bss_ids nil nil sta_sids sta_braking_tids
             sta_bss_vars sta_bss_params_ok).
    - exact sta_bss_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sta_sids_rows.
    - exact sta_braking_tids_rows.
    - exact sta_bss_walk.
  Qed.

  (* act_hold_heavy_idle: the held-"heavy"-item idle -- three
     drop_and_set_mario_action(m, ACT_const, 0) exits (the dasma channel) +
     smact-const exits + stationary_ground_step. *)
  Lemma act_hold_heavy_idle_pres :
    body_pres lp NoA MWF bm
      mario_actions_stationary.f_act_hold_heavy_idle.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_stationary.f_act_hold_heavy_idle
             sta_leaf_ids nil nil sta_dasma_sids nil
             sta_hhi_vars sta_hhi_params_ok).
    - exact sta_leaf_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sta_dasma_sids_rows.
    - intros fid' H. discriminate H.
    - exact sta_hhi_walk.
  Qed.

  (* act_slide_kick_slide_stop: drop_and_set_mario_action (dasma) +
     stopping_step (act3) + smact-const exits. *)
  Lemma act_slide_kick_slide_stop_pres :
    body_pres lp NoA MWF bm
      mario_actions_stationary.f_act_slide_kick_slide_stop.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_stationary.f_act_slide_kick_slide_stop
             sta_leaf_ids nil nil sta_dasma_sids sta_braking_tids
             sta_skss_vars sta_skss_params_ok).
    - exact sta_leaf_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sta_dasma_sids_rows.
    - exact sta_braking_tids_rows.
    - exact sta_skss_walk.
  Qed.

  (* act_ground_pound_land: drop_and_set_mario_action (dasma) + landing_step
     (act3) + smact-const exits. *)
  Lemma act_ground_pound_land_pres :
    body_pres lp NoA MWF bm
      mario_actions_stationary.f_act_ground_pound_land.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_stationary.f_act_ground_pound_land
             sta_leaf_ids nil nil sta_dasma_sids sta_landing_tids
             sta_gpl_vars sta_gpl_params_ok).
    - exact sta_leaf_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sta_dasma_sids_rows.
    - exact sta_landing_tids_rows.
    - exact sta_gpl_walk.
  Qed.

  (* ---- SLICE 8: the cchae helper row + the three hold leaves ---- *)
  Lemma sta_cchae_row :
    call_pres lp bm NoA MWF mario._check_common_hold_action_exits.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario.prog mario._check_common_hold_action_exits
             mario.f_check_common_hold_action_exits nil nil nil sta_sids
             LO_mario sta_cchae_pin sta_cchae_vars sta_cchae_params_ok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sta_sids_rows.
    - exact sta_cchae_walk.
  Qed.

  Lemma sta_cchae_ids_rows : forall fid, mem_id fid sta_cchae_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sta_cchae_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sta_cchae_row | ].
    discriminate H.
  Qed.

  (* act_hold_butt_slide_stop: check_common_hold_action_exits (cchae) +
     drop_and_set_mario_action (dasma) + stopping_step (act3).  No A-gate. *)
  Lemma act_hold_butt_slide_stop_pres :
    body_pres lp NoA MWF bm
      mario_actions_stationary.f_act_hold_butt_slide_stop.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_stationary.f_act_hold_butt_slide_stop
             sta_cchae_ids nil nil sta_dasma_sids sta_braking_tids
             sta_hbss_vars sta_hbss_params_ok).
    - exact sta_cchae_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sta_dasma_sids_rows.
    - exact sta_braking_tids_rows.
    - exact sta_hbss_walk.
  Qed.

  (* act_hold_freefall_land_stop: cchae + dasma + landing_step (act3). *)
  Lemma act_hold_freefall_land_stop_pres :
    body_pres lp NoA MWF bm
      mario_actions_stationary.f_act_hold_freefall_land_stop.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_stationary.f_act_hold_freefall_land_stop
             sta_cchae_ids nil nil sta_dasma_sids sta_landing_tids
             sta_hffls_vars sta_hffls_params_ok).
    - exact sta_cchae_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sta_dasma_sids_rows.
    - exact sta_landing_tids_rows.
    - exact sta_hffls_walk.
  Qed.

  (* act_hold_jump_land_stop: cchae + dasma + landing_step (act3). *)
  Lemma act_hold_jump_land_stop_pres :
    body_pres lp NoA MWF bm
      mario_actions_stationary.f_act_hold_jump_land_stop.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_stationary.f_act_hold_jump_land_stop
             sta_cchae_ids nil nil sta_dasma_sids sta_landing_tids
             sta_hjls_vars sta_hjls_params_ok).
    - exact sta_cchae_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sta_dasma_sids_rows.
    - exact sta_landing_tids_rows.
    - exact sta_hjls_walk.
  Qed.

  (* act_twirl_land: the chase-store leaf (marioObj->gfx.angle[1]) -- cact. *)
  Lemma act_twirl_land_pres :
    body_pres lp NoA MWF bm
      mario_actions_stationary.f_act_twirl_land.
  Proof.
    apply (body_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_stationary.f_act_twirl_land
             sta_ss_ids nil sta_twl_cact nil sta_sids nil
             sta_twl_vars sta_twl_params_ok sta_twl_nonparam).
    - exact sta_ss_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sta_sids_rows.
    - intros fid' H. discriminate H.
    - exact sta_twl_walk.
  Qed.

  (* ---- SLICE 9: mario_throw_held_object row + act_air_throw_land ---- *)
  Lemma mtho_row :
    call_pres lp bm NoA MWF interaction._mario_throw_held_object.
  Proof.
    apply (call_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             interaction.prog interaction._mario_throw_held_object
             interaction.f_mario_throw_held_object
             nil nil mtho_cact mtho_xids nil
             LO_int mtho_pin mtho_vars mtho_params_ok mtho_nonparam).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. unfold mtho_xids in H. cbn [mem_id existsb] in H.
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hcpx_s2v | ].
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hcpx_ssm | ].
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hcpx_oshs | ].
      discriminate H.
    - intros fid' H. discriminate H.
    - exact mtho_walk.
  Qed.

  Lemma sta_atl_ids_rows : forall fid, mem_id fid sta_atl_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sta_atl_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact mtho_row | ].
    discriminate H.
  Qed.

  (* act_air_throw_land: cchae-free; mario_throw_held_object (ids) +
     landing_step (act3) + set_mario_action(CONST) exits + actionTimer store. *)
  Lemma act_air_throw_land_pres :
    body_pres lp NoA MWF bm
      mario_actions_stationary.f_act_air_throw_land.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_stationary.f_act_air_throw_land
             sta_atl_ids nil nil sta_sids sta_landing_tids
             sta_atl_vars sta_atl_params_ok).
    - exact sta_atl_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sta_sids_rows.
    - exact sta_landing_tids_rows.
    - exact sta_atl_walk.
  Qed.

  (* ================================================================== *)
  (* SLICE 10: the set_jumping_action arc + the three crouch leaves.    *)
  (* (Consumes the const-result-into-wact engine arm: set_jumping_action *)
  (*  is call_pres_act, not call_pres -- it threads _action to           *)
  (*  set_mario_action.)                                                 *)
  (* ================================================================== *)

  (* mario_floor_is_steep's two callees, REUSED from ActWriterSurface. *)
  Lemma sta_mfis_ids_rows : forall fid, mem_id fid sta_mfis_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sta_mfis_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid;
        exact (mfd_row lp LO_mario bm NoA MWF HNoA_of_MWF HMWF_window
                 HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot HMWF_chase
                 HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe) | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid;
        exact (mgfc_row lp LO_mario bm NoA MWF HNoA_of_MWF HMWF_window
                 HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot HMWF_chase
                 HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe) | ].
    discriminate H.
  Qed.

  Lemma sta_mfis_row :
    call_pres lp bm NoA MWF mario._mario_floor_is_steep.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario.prog mario._mario_floor_is_steep
             mario.f_mario_floor_is_steep sta_mfis_ids nil nil nil
             LO_mario sta_mfis_pin sta_mfis_vars sta_mfis_params_ok).
    - exact sta_mfis_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sta_mfis_walk.
  Qed.

  (* set_steep_jump_action's two math externals (sqrtf/atan2s) and its
     drop_and_set channel. *)
  Lemma sta_sssja_xids_rows : forall fid, mem_id fid sta_sssja_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sta_sssja_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_sqrtf | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_atan2s | ].
    discriminate H.
  Qed.

  Lemma sta_sssja_sids_rows : forall fid, mem_id fid sta_sssja_sids = true ->
      call_pres_act lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sta_sssja_sids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hdasma | ].
    discriminate H.
  Qed.

  Lemma sta_sssja_row :
    call_pres lp bm NoA MWF mario._set_steep_jump_action.
  Proof.
    apply (call_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario.prog mario._set_steep_jump_action
             mario.f_set_steep_jump_action nil nil sta_sssja_cact
             sta_sssja_xids sta_sssja_sids
             LO_mario sta_sssja_pin sta_sssja_vars sta_sssja_params_ok
             sta_sssja_nonparam).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sta_sssja_xids_rows.
    - exact sta_sssja_sids_rows.
    - exact sta_sssja_walk.
  Qed.

  (* set_jumping_action's ids = the two helpers above. *)
  Lemma sta_sja_ids_rows : forall fid, mem_id fid sta_sja_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sta_sja_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sta_mfis_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sta_sssja_row | ].
    discriminate H.
  Qed.

  (* THE KEYSTONE of this slice: set_jumping_action as call_pres_act,
     walked via the const-result-into-wact arm. *)
  Lemma sta_sja_row :
    call_pres_act lp bm NoA MWF mario._set_jumping_action.
  Proof.
    apply (call_pres_act_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario.prog mario._set_jumping_action mario.f_set_jumping_action
             (mario._action :: mario._t'1 :: mario._t'2 :: nil)
             sta_sja_ids sta_sids nil nil sta_sids
             LO_mario sta_sja_pin sta_sja_vars sta_sja_params sta_sja_ret
             eq_refl eq_refl eq_refl eq_refl eq_refl eq_refl).
    - exact sta_sja_ids_rows.
    - exact sta_sids_rows.
    - intros fid' H. discriminate H.
    - exact sta_sids_rows.
    - exact sta_sja_walk.
  Qed.

  (* the crouch leaves' sids: set_mario_action (Hsmact) + the new
     set_jumping_action keystone. *)
  Lemma sta_crouch_sids_rows : forall fid, mem_id fid sta_crouch_sids = true ->
      call_pres_act lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sta_crouch_sids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsmact | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sta_sja_row | ].
    discriminate H.
  Qed.

  Lemma act_crouching_pres :
    body_pres lp NoA MWF bm mario_actions_stationary.f_act_crouching.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_stationary.f_act_crouching
             sta_leaf_ids nil nil sta_crouch_sids nil
             sta_crouch_vars sta_crouch_params_ok).
    - exact sta_leaf_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sta_crouch_sids_rows.
    - intros fid' H. discriminate H.
    - exact sta_crouch_walk.
  Qed.

  Lemma act_start_crouching_pres :
    body_pres lp NoA MWF bm mario_actions_stationary.f_act_start_crouching.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_stationary.f_act_start_crouching
             sta_leaf_ids nil nil sta_crouch_sids nil
             sta_scrouch_vars sta_scrouch_params_ok).
    - exact sta_leaf_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sta_crouch_sids_rows.
    - intros fid' H. discriminate H.
    - exact sta_scrouch_walk.
  Qed.

  Lemma act_stop_crouching_pres :
    body_pres lp NoA MWF bm mario_actions_stationary.f_act_stop_crouching.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_stationary.f_act_stop_crouching
             sta_leaf_ids nil nil sta_crouch_sids nil
             sta_pcrouch_vars sta_pcrouch_params_ok).
    - exact sta_leaf_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sta_crouch_sids_rows.
    - intros fid' H. discriminate H.
    - exact sta_pcrouch_walk.
  Qed.

  (* ================================================================== *)
  (* SLICE 11: the IDLE cluster (act_in_quicksand/act_coughing/act_panting) *)
  (* ================================================================== *)

  (* mario_drop_held_object: call_pres, reused from ObjectLeafSurface. *)
  Let Hmdho : call_pres lp bm NoA MWF interaction._mario_drop_held_object :=
    mdho_row lp LO_mario LO_int bm NoA MWF HNoA_of_MWF
      HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
      HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
      Hcpx_s2v Hcpx_ssm Hcpx_oshs.

  (* mario_push_off_steep_floor: call_pres_act (threads _action to
     set_mario_action; the const-result-into-wact arm tracks _t'2). *)
  Lemma sta_pushoff_row :
    call_pres_act lp bm NoA MWF mario_step._mario_push_off_steep_floor.
  Proof.
    apply (call_pres_act_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_step.prog mario_step._mario_push_off_steep_floor
             mario_step.f_mario_push_off_steep_floor
             sta_pushoff_wact nil sta_sids nil nil sta_sids
             LO_mario_step sta_pushoff_pin sta_pushoff_vars sta_pushoff_params
             sta_pushoff_ret
             eq_refl eq_refl eq_refl eq_refl eq_refl eq_refl).
    - intros fid' H. discriminate H.
    - exact sta_sids_rows.
    - intros fid' H. discriminate H.
    - exact sta_sids_rows.
    - exact sta_pushoff_walk.
  Qed.

  (* check_common_idle_cancels: call_pres. *)
  Lemma sta_ccic_ids_rows : forall fid, mem_id fid sta_ccic_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sta_ccic_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hmdho | ].
    discriminate H.
  Qed.

  Lemma sta_ccic_sids_rows : forall fid, mem_id fid sta_ccic_sids = true ->
      call_pres_act lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sta_ccic_sids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsmact | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sta_sja_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sta_pushoff_row | ].
    discriminate H.
  Qed.

  Lemma sta_ccic_row :
    call_pres lp bm NoA MWF mario_actions_stationary._check_common_idle_cancels.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_stationary.prog
             mario_actions_stationary._check_common_idle_cancels
             mario_actions_stationary.f_check_common_idle_cancels
             sta_ccic_ids nil nil sta_ccic_sids
             LO_sta sta_ccic_pin sta_ccic_vars sta_ccic_params_ok).
    - exact sta_ccic_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sta_ccic_sids_rows.
    - exact sta_ccic_walk.
  Qed.

  (* the idle leaves' ids = ccic + set_mario_animation + stationary_ground_step *)
  Lemma sta_idle_ids_rows : forall fid, mem_id fid sta_idle_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sta_idle_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sta_ccic_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sta_sma_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sta_sgs_row | ].
    discriminate H.
  Qed.

  (* act_idle's ids = ccic + set_mario_animation + is_anim_at_end +
     find_floor_height_relative_polar + stationary_ground_step *)
  Lemma sta_idle2_ids_rows : forall fid, mem_id fid sta_idle2_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sta_idle2_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sta_ccic_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sta_sma_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sta_iae_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hffhrp_sta | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sta_sgs_row | ].
    discriminate H.
  Qed.

  Lemma act_idle_pres :
    body_pres lp NoA MWF bm mario_actions_stationary.f_act_idle.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_stationary.f_act_idle
             sta_idle2_ids nil nil sta_sids nil
             sta_idle2_vars sta_idle2_params_ok).
    - exact sta_idle2_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sta_sids_rows.
    - intros fid' H. discriminate H.
    - exact sta_idle2_walk.
  Qed.

  (* act_sleeping's ids = set_mario_animation + is_anim_at_end +
     find_floor_height_relative_polar + stationary_ground_step (no ccic) *)
  Lemma sta_sleep_ids_rows : forall fid, mem_id fid sta_sleep_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sta_sleep_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sta_sma_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sta_iae_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hffhrp_sta | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sta_sgs_row | ].
    discriminate H.
  Qed.

  (* act_sleeping's xids = play_sound (Hcpx_psound) + three sta_ext audio
     externals (lower_background_noise / play_mario_heavy_landing_sound /
     play_sound_if_no_flag, all in the extended sta_ext_ids) *)
  Lemma sta_sleep_xids_rows : forall fid, mem_id fid sta_sleep_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sta_sleep_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_psound | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid;
        apply Hpres_sta_ext; vm_compute; reflexivity | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid;
        apply Hpres_sta_ext; vm_compute; reflexivity | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid;
        apply Hpres_sta_ext; vm_compute; reflexivity | ].
    discriminate H.
  Qed.

  Lemma act_sleeping_pres :
    body_pres lp NoA MWF bm mario_actions_stationary.f_act_sleeping.
  Proof.
    apply (body_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_stationary.f_act_sleeping
             sta_sleep_ids nil sta_sleep_cact sta_sleep_xids sta_sids nil
             sta_sleep_vars sta_sleep_params_ok sta_sleep_nonparam).
    - exact sta_sleep_ids_rows.
    - intros fid' H. discriminate H.
    - exact sta_sleep_xids_rows.
    - exact sta_sids_rows.
    - intros fid' H. discriminate H.
    - exact sta_sleep_walk.
  Qed.

  Lemma act_in_quicksand_pres :
    body_pres lp NoA MWF bm mario_actions_stationary.f_act_in_quicksand.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_stationary.f_act_in_quicksand
             sta_idle_ids nil nil sta_sids nil
             sta_inqs_vars sta_inqs_params_ok).
    - exact sta_idle_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sta_sids_rows.
    - intros fid' H. discriminate H.
    - exact sta_inqs_walk.
  Qed.

  Lemma act_coughing_pres :
    body_pres lp NoA MWF bm mario_actions_stationary.f_act_coughing.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_stationary.f_act_coughing
             sta_idle_ids nil sta_psound_xids sta_sids nil
             sta_cough_vars sta_cough_params_ok).
    - exact sta_idle_ids_rows.
    - intros fid' H. discriminate H.
    - exact sta_ashv_xids_rows.
    - exact sta_sids_rows.
    - intros fid' H. discriminate H.
    - exact sta_cough_walk.
  Qed.

  Lemma act_panting_pres :
    body_pres lp NoA MWF bm mario_actions_stationary.f_act_panting.
  Proof.
    apply (body_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_stationary.f_act_panting
             sta_idle_ids nil sta_panting_cact sta_psound_xids sta_sids nil
             sta_pant_vars sta_pant_params_ok sta_pant_nonparam).
    - exact sta_idle_ids_rows.
    - intros fid' H. discriminate H.
    - exact sta_ashv_xids_rows.
    - exact sta_sids_rows.
    - intros fid' H. discriminate H.
    - exact sta_pant_walk.
  Qed.

  (* ================================================================== *)
  (* SLICE 12: the HOLD_IDLE cluster (act_hold_idle / hold_panting_unused) *)
  (* ================================================================== *)

  Lemma sta_cchic_sids_rows : forall fid, mem_id fid sta_cchic_sids = true ->
      call_pres_act lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sta_cchic_sids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsmact | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sta_sja_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sta_pushoff_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hdasma | ].
    discriminate H.
  Qed.

  Lemma sta_cchic_row :
    call_pres lp bm NoA MWF
      mario_actions_stationary._check_common_hold_idle_cancels.
  Proof.
    apply (call_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_stationary.prog
             mario_actions_stationary._check_common_hold_idle_cancels
             mario_actions_stationary.f_check_common_hold_idle_cancels
             nil nil sta_cchic_cact nil sta_cchic_sids
             LO_sta sta_cchic_pin sta_cchic_vars sta_cchic_params_ok
             sta_cchic_nonparam).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sta_cchic_sids_rows.
    - exact sta_cchic_walk.
  Qed.

  Lemma sta_s2v_xids_rows : forall fid, mem_id fid sta_s2v_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sta_s2v_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_s2v | ].
    discriminate H.
  Qed.

  Lemma sta_hidle_ids_rows : forall fid, mem_id fid sta_hidle_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sta_hidle_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sta_cchic_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sta_sma_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sta_sgs_row | ].
    discriminate H.
  Qed.

  Lemma act_hold_idle_pres :
    body_pres lp NoA MWF bm mario_actions_stationary.f_act_hold_idle.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_stationary.f_act_hold_idle
             sta_hidle_ids nil sta_s2v_xids sta_dasma_sids nil
             sta_hidle_vars sta_hidle_params_ok).
    - exact sta_hidle_ids_rows.
    - intros fid' H. discriminate H.
    - exact sta_s2v_xids_rows.
    - exact sta_dasma_sids_rows.
    - intros fid' H. discriminate H.
    - exact sta_hidle_walk.
  Qed.

  Lemma act_hold_panting_unused_pres :
    body_pres lp NoA MWF bm
      mario_actions_stationary.f_act_hold_panting_unused.
  Proof.
    apply (body_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_stationary.f_act_hold_panting_unused
             sta_hidle_ids nil sta_hpant_cact nil sta_dasma_sids nil
             sta_hpant_vars sta_hpant_params_ok sta_hpant_nonparam).
    - exact sta_hidle_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sta_dasma_sids_rows.
    - intros fid' H. discriminate H.
    - exact sta_hpant_walk.
  Qed.

  (* ================================================================== *)
  (* SLICE 13: act_start_sleeping (idle/sleeping quick win)             *)
  (* ================================================================== *)

  (* play_anim_sound: call_pres -- reads only, calls play_sound (xids). *)
  Lemma sta_pas_row :
    call_pres lp bm NoA MWF mario_actions_stationary._play_anim_sound.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_stationary.prog
             mario_actions_stationary._play_anim_sound
             mario_actions_stationary.f_play_anim_sound
             nil nil sta_psound_xids nil
             LO_sta sta_pas_pin sta_pas_vars sta_pas_params_ok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sta_ashv_xids_rows.
    - intros fid' H. discriminate H.
    - exact sta_pas_walk.
  Qed.

  Lemma sta_ssleep_ids_rows : forall fid, mem_id fid sta_ssleep_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sta_ssleep_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sta_ccic_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sta_sma_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sta_pas_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sta_iae_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact sta_sgs_row | ].
    discriminate H.
  Qed.

  Lemma act_start_sleeping_pres :
    body_pres lp NoA MWF bm mario_actions_stationary.f_act_start_sleeping.
  Proof.
    apply (body_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_stationary.f_act_start_sleeping
             sta_ssleep_ids nil sta_ssleep_cact sta_psound_xids sta_sids nil
             sta_ssleep_vars sta_ssleep_params_ok sta_ssleep_nonparam).
    - exact sta_ssleep_ids_rows.
    - intros fid' H. discriminate H.
    - exact sta_ashv_xids_rows.
    - exact sta_sids_rows.
    - intros fid' H. discriminate H.
    - exact sta_ssleep_walk.
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
    (* 2: act_idle -- WALKED *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite sta_idle2_pin in Hdm. injection Hdm as <-.
      exact act_idle_pres. }
    (* 3: act_start_sleeping -- WALKED *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite sta_ssleep_pin in Hdm. injection Hdm as <-.
      exact act_start_sleeping_pres. }
    (* 4: act_sleeping -- WALKED *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite sta_sleep_pin in Hdm. injection Hdm as <-.
      exact act_sleeping_pres. }
    (* 5: act_waking_up -- WALKED *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite sta_awku_pin in Hdm. injection Hdm as <-.
      exact act_waking_up_pres. }
    (* 6: act_panting -- WALKED *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite sta_pant_pin in Hdm. injection Hdm as <-.
      exact act_panting_pres. }
    (* 7: act_hold_panting_unused -- WALKED *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite sta_hpant_pin in Hdm. injection Hdm as <-.
      exact act_hold_panting_unused_pres. }
    (* 8: act_hold_idle -- WALKED *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite sta_hidle_pin in Hdm. injection Hdm as <-.
      exact act_hold_idle_pres. }
    (* 9: act_hold_heavy_idle -- WALKED *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite sta_hhi_pin in Hdm. injection Hdm as <-.
      exact act_hold_heavy_idle_pres. }
    (* 10: act_in_quicksand -- WALKED *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite sta_inqs_pin in Hdm. injection Hdm as <-.
      exact act_in_quicksand_pres. }
    (* 11: act_standing_against_wall -- WALKED *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite sta_saw_pin in Hdm. injection Hdm as <-.
      exact act_standing_against_wall_pres. }
    (* 12: act_coughing -- WALKED *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite sta_cough_pin in Hdm. injection Hdm as <-.
      exact act_coughing_pres. }
    (* 13: act_shivering -- WALKED *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite sta_ashv_pin in Hdm. injection Hdm as <-.
      exact act_shivering_pres. }
    (* 14: act_crouching -- WALKED *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite sta_crouch_pin in Hdm. injection Hdm as <-.
      exact act_crouching_pres. }
    (* 15: act_start_crouching -- WALKED *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite sta_scrouch_pin in Hdm. injection Hdm as <-.
      exact act_start_crouching_pres. }
    (* 16: act_stop_crouching -- WALKED *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite sta_pcrouch_pin in Hdm. injection Hdm as <-.
      exact act_stop_crouching_pres. }
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
    (* 19: act_slide_kick_slide_stop -- WALKED *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite sta_skss_pin in Hdm. injection Hdm as <-.
      exact act_slide_kick_slide_stop_pres. }
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
    (* 26: act_hold_jump_land_stop -- WALKED *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite sta_hjls_pin in Hdm. injection Hdm as <-.
      exact act_hold_jump_land_stop_pres. }
    (* 27: act_hold_freefall_land_stop -- WALKED *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite sta_hffls_pin in Hdm. injection Hdm as <-.
      exact act_hold_freefall_land_stop_pres. }
    (* 28: act_air_throw_land -- WALKED *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite sta_atl_pin in Hdm. injection Hdm as <-.
      exact act_air_throw_land_pres. }
    (* 29: act_lava_boost_land -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      refine (Hrest _ f _ Hdm); vm_compute; reflexivity. }
    (* 30: act_twirl_land -- WALKED *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite sta_twl_pin in Hdm. injection Hdm as <-.
      exact act_twirl_land_pres. }
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
    (* 34: act_ground_pound_land -- WALKED *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite sta_gpl_pin in Hdm. injection Hdm as <-.
      exact act_ground_pound_land_pres. }
    (* 35: act_braking_stop -- WALKED *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite sta_abs_pin in Hdm. injection Hdm as <-.
      exact act_braking_stop_pres. }
    (* 36: act_butt_slide_stop -- WALKED *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite sta_bss_pin in Hdm. injection Hdm as <-.
      exact act_butt_slide_stop_pres. }
    (* 37: act_hold_butt_slide_stop -- WALKED *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm; subst fid.
      rewrite sta_hbss_pin in Hdm. injection Hdm as <-.
      exact act_hold_butt_slide_stop_pres. }
    discriminate H.
  Qed.

End StationaryLeafRows.
