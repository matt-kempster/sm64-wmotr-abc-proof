(* ====================================================================== *)
(* THE AIRBORNE-FAMILY LEAF SURFACE                                        *)
(* (SPINE: airborne_leaf_callees_pres shrinks the capstone's               *)
(*  Hpres_air_callees down to a per-leaf census rest-split).               *)
(*                                                                         *)
(* AirborneSurface.airborne_pres walks the 43-arm dispatcher and reduces   *)
(* it to ONE residual: body_pres for every leaf callee in                  *)
(* airborne_callee_ids (43 ids -- 41 act handlers + 2 prologue helpers).   *)
(* Here we discharge those leaves one cluster at a time, mirroring         *)
(* MovingLeafSurface.v / StationaryLeafSurface.v.                          *)
(*                                                                         *)
(* SLICE A1 (this file's first cut): the TWO PROLOGUE helpers --           *)
(* check_common_airborne_cancels (the common-cancel gate: set_water_       *)
(* plunge_action + drop_and_set_mario_action x2 + the m->quicksandDepth    *)
(* window store) and play_far_fall_sound (play_sound external + the        *)
(* m->flags window store).  Both are clean basic-engine walks.  The        *)
(* remaining 41 act handlers stay under the rest premise airborne_rest_ids.*)
(* ====================================================================== *)

From Coq Require Import ZArith Lia List.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking Errors.
From SM64.Generated Require mario mario_step
  mario_actions_airborne mario_actions_object interaction.
From SM64.Proofs Require Import SymbolicLinking Flying Taint
  ActionValueFrame RealFrameValue RealFrameLinked AGates.
From SM64.Proofs Require Import CensusV2 EngineV2Consumer RestSurface
  AirborneSurface DispatchKit FloorsSurface.
From SM64.Proofs Require Import ActWriterSurface ObjectLeafSurface.
From SM64.Proofs Require Import MWFReal LandingBricks StationaryLeafSurface.
From SM64.Proofs Require Import LocalVarsSurface OutParamSurface.

Import ListNotations.

(* alias + MarioState* notation *)
Module A := mario_actions_airborne.
Local Notation tyMSp := (tptr (Tstruct A._MarioState noattr)).

(* ====================================================================== *)
(* The per-function params-ok check (uniform Mario-arg leaf shape).        *)
(* ====================================================================== *)
Definition air_pok (f : function) : bool :=
  match fn_params f with
  | (i, ty) :: ps =>
      Pos.eqb i A._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id A._m (map fst ps))
  | nil => false
  end.

(* ====================================================================== *)
(* Censuses (probe-derived).                                              *)
(* ====================================================================== *)

(* set_water_plunge_action's externals (set_camera_mode + vec3s_set),
   routed through the capstone's obj_ext boundary -- verbatim the moving
   family's mov_swpa_xids. *)
Definition air_swpa_xids : list ident :=
  mario._set_camera_mode :: mario._vec3s_set :: nil.

(* check_common_airborne_cancels: set_water_plunge_action (call_pres) +
   drop_and_set_mario_action (call_pres_act). *)
Definition air_ccac_ids : list ident :=
  mario._set_water_plunge_action :: nil.
Definition air_ccac_sids : list ident :=
  mario._drop_and_set_mario_action :: nil.

(* play_far_fall_sound: play_sound (external) only. *)
Definition air_pffs_xids : list ident := mario._play_sound :: nil.

(* set_mario_action with a vm-checkably untainted constant 2nd arg *)
Definition air_sids : list ident := mario._set_mario_action :: nil.

(* ---- pin / vars / pok / walk Examples ---- *)

(* set_water_plunge_action (mario.prog) -- same body as the moving reuse *)
Example air_swpa_pin :
  (prog_defmap mario.prog) ! mario._set_water_plunge_action
  = Some (Gfun (Internal mario.f_set_water_plunge_action)).
Proof. vm_compute. reflexivity. Qed.
Example air_swpa_vars : fn_vars mario.f_set_water_plunge_action = nil.
Proof. vm_compute. reflexivity. Qed.
Example air_swpa_pok : air_pok mario.f_set_water_plunge_action = true.
Proof. vm_compute. reflexivity. Qed.
Example air_swpa_walk :
  wwalk_chk false nil nil nil nil air_swpa_xids air_sids nil
    (fn_body mario.f_set_water_plunge_action) = true.
Proof. vm_compute. reflexivity. Qed.

(* check_common_airborne_cancels *)
Example air_ccac_pin :
  (prog_defmap mario_actions_airborne.prog) ! A._check_common_airborne_cancels
  = Some (Gfun (Internal A.f_check_common_airborne_cancels)).
Proof. vm_compute. reflexivity. Qed.
Example air_ccac_vars : fn_vars A.f_check_common_airborne_cancels = nil.
Proof. vm_compute. reflexivity. Qed.
Example air_ccac_pok : air_pok A.f_check_common_airborne_cancels = true.
Proof. vm_compute. reflexivity. Qed.
Example air_ccac_walk :
  wwalk_chk false nil air_ccac_ids nil nil nil air_ccac_sids nil
    (fn_body A.f_check_common_airborne_cancels) = true.
Proof. vm_compute. reflexivity. Qed.

(* play_far_fall_sound *)
Example air_pffs_pin :
  (prog_defmap mario_actions_airborne.prog) ! A._play_far_fall_sound
  = Some (Gfun (Internal A.f_play_far_fall_sound)).
Proof. vm_compute. reflexivity. Qed.
Example air_pffs_vars : fn_vars A.f_play_far_fall_sound = nil.
Proof. vm_compute. reflexivity. Qed.
Example air_pffs_pok : air_pok A.f_play_far_fall_sound = true.
Proof. vm_compute. reflexivity. Qed.
Example air_pffs_walk :
  wwalk_chk false nil nil nil nil air_pffs_xids nil nil
    (fn_body A.f_play_far_fall_sound) = true.
Proof. vm_compute. reflexivity. Qed.

(* ====================================================================== *)
(* SLICE A2: the common_air_action_step jump-cluster.                      *)
(* ====================================================================== *)

(* common_air_action_step is the BIG shared air-physics helper (it walks
   update_air_without_turn / perform_air_step / set_mario_animation /
   check_fall_damage_or_get_stuck / set_mario_action / mario_bonk_reflection
   / mario_set_forward_vel / lava_boost_on_wall / drop_and_set_mario_action;
   all its stores are window/indexed-window + untainted-const actions).  We
   carry it as a residual (call_pres) -- an internal mario_actions_airborne
   .prog function, the air analogue of perform_ground_step's Hcp_pgs --
   discharged later by walking its body.  Its presence shrinks the 11
   common_air_action_step-dependent act handlers from whole-cloth leaves to
   thin wrappers. *)

(* the jump-cluster census: common_air_action_step (Hcp_caas) +
   play_mario_jump_sound (pmjs_row); set_mario_action + drop_and_set_mario_
   action (sids). *)
Definition air_ajc_ids : list ident :=
  A._common_air_action_step :: mario._play_mario_jump_sound :: nil.
Definition air_ajc_sids : list ident :=
  mario._set_mario_action :: mario._drop_and_set_mario_action :: nil.

(* act_freefall: B/Z input-gated set_mario_action + a Sswitch(actionArg)
   choosing the animation (no store) + caas. *)
Example air_ff_pin :
  (prog_defmap mario_actions_airborne.prog) ! A._act_freefall
  = Some (Gfun (Internal A.f_act_freefall)).
Proof. vm_compute. reflexivity. Qed.
Example air_ff_vars : fn_vars A.f_act_freefall = nil.
Proof. vm_compute. reflexivity. Qed.
Example air_ff_pok : air_pok A.f_act_freefall = true.
Proof. vm_compute. reflexivity. Qed.
Example air_ff_walk :
  wwalk_chk false nil air_ajc_ids nil nil nil air_ajc_sids nil
    (fn_body A.f_act_freefall) = true.
Proof. vm_compute. reflexivity. Qed.

(* act_hold_freefall: chase reads (m->marioObj / m->heldObj) + input-gated
   set_mario_action / drop_and_set_mario_action + caas. *)
Example air_hff_pin :
  (prog_defmap mario_actions_airborne.prog) ! A._act_hold_freefall
  = Some (Gfun (Internal A.f_act_hold_freefall)).
Proof. vm_compute. reflexivity. Qed.
Example air_hff_vars : fn_vars A.f_act_hold_freefall = nil.
Proof. vm_compute. reflexivity. Qed.
Example air_hff_pok : air_pok A.f_act_hold_freefall = true.
Proof. vm_compute. reflexivity. Qed.
Example air_hff_walk :
  wwalk_chk false nil air_ajc_ids nil nil nil air_ajc_sids nil
    (fn_body A.f_act_hold_freefall) = true.
Proof. vm_compute. reflexivity. Qed.

(* act_wall_kick_air: input-gated set_mario_action + play_mario_jump_sound
   + caas. *)
Example air_wka_pin :
  (prog_defmap mario_actions_airborne.prog) ! A._act_wall_kick_air
  = Some (Gfun (Internal A.f_act_wall_kick_air)).
Proof. vm_compute. reflexivity. Qed.
Example air_wka_vars : fn_vars A.f_act_wall_kick_air = nil.
Proof. vm_compute. reflexivity. Qed.
Example air_wka_pok : air_pok A.f_act_wall_kick_air = true.
Proof. vm_compute. reflexivity. Qed.
Example air_wka_walk :
  wwalk_chk false nil air_ajc_ids nil nil nil air_ajc_sids nil
    (fn_body A.f_act_wall_kick_air) = true.
Proof. vm_compute. reflexivity. Qed.

(* ====================================================================== *)
(* SLICE A3: three more caas wrappers (play_mario_sound cluster).          *)
(* ====================================================================== *)

(* play_mario_sound's internal callees (all reused ObjectLeafSurface rows:
   pmas_row / pmjs_row / psinf_row, each bottoming out in play_sound). *)
Definition air_pms_ids : list ident :=
  mario._play_mario_action_sound :: mario._play_mario_jump_sound
    :: mario._play_sound_if_no_flag :: nil.

(* the caas + play_mario_sound census (hold_jump / long_jump) *)
Definition air_cps_ids : list ident :=
  A._common_air_action_step :: mario._play_mario_sound :: nil.
Definition air_lj_xids : list ident := mario._play_sound :: nil.

(* play_mario_sound (mario.prog): reads m->flags, dispatches to the 3 audio
   helpers; no stores. *)
Example air_pms_pin :
  (prog_defmap mario.prog) ! mario._play_mario_sound
  = Some (Gfun (Internal mario.f_play_mario_sound)).
Proof. vm_compute. reflexivity. Qed.
Example air_pms_vars : fn_vars mario.f_play_mario_sound = nil.
Proof. vm_compute. reflexivity. Qed.
Example air_pms_pok : air_pok mario.f_play_mario_sound = true.
Proof. vm_compute. reflexivity. Qed.
Example air_pms_walk :
  wwalk_chk false nil air_pms_ids nil nil nil nil nil
    (fn_body mario.f_play_mario_sound) = true.
Proof. vm_compute. reflexivity. Qed.

(* act_top_of_pole_jump: play_mario_jump_sound + caas (the air_ajc census). *)
Example air_tpj_pin :
  (prog_defmap mario_actions_airborne.prog) ! A._act_top_of_pole_jump
  = Some (Gfun (Internal A.f_act_top_of_pole_jump)).
Proof. vm_compute. reflexivity. Qed.
Example air_tpj_vars : fn_vars A.f_act_top_of_pole_jump = nil.
Proof. vm_compute. reflexivity. Qed.
Example air_tpj_pok : air_pok A.f_act_top_of_pole_jump = true.
Proof. vm_compute. reflexivity. Qed.
Example air_tpj_walk :
  wwalk_chk false nil air_ajc_ids nil nil nil air_ajc_sids nil
    (fn_body A.f_act_top_of_pole_jump) = true.
Proof. vm_compute. reflexivity. Qed.

(* act_hold_jump: input-gated set_mario_action / drop_and_set_mario_action +
   play_mario_sound + caas (chase reads marioObj / heldObj). *)
Example air_hj_pin :
  (prog_defmap mario_actions_airborne.prog) ! A._act_hold_jump
  = Some (Gfun (Internal A.f_act_hold_jump)).
Proof. vm_compute. reflexivity. Qed.
Example air_hj_vars : fn_vars A.f_act_hold_jump = nil.
Proof. vm_compute. reflexivity. Qed.
Example air_hj_pok : air_pok A.f_act_hold_jump = true.
Proof. vm_compute. reflexivity. Qed.
Example air_hj_walk :
  wwalk_chk false nil air_cps_ids nil nil nil air_ajc_sids nil
    (fn_body A.f_act_hold_jump) = true.
Proof. vm_compute. reflexivity. Qed.

(* act_long_jump: play_mario_sound + play_sound (ext) + caas; one
   m->actionState window store; chase reads marioObj / floor. *)
Example air_lj_pin :
  (prog_defmap mario_actions_airborne.prog) ! A._act_long_jump
  = Some (Gfun (Internal A.f_act_long_jump)).
Proof. vm_compute. reflexivity. Qed.
Example air_lj_vars : fn_vars A.f_act_long_jump = nil.
Proof. vm_compute. reflexivity. Qed.
Example air_lj_pok : air_pok A.f_act_long_jump = true.
Proof. vm_compute. reflexivity. Qed.
Example air_lj_walk :
  wwalk_chk false nil air_cps_ids nil nil air_lj_xids nil nil
    (fn_body A.f_act_long_jump) = true.
Proof. vm_compute. reflexivity. Qed.

(* ====================================================================== *)
(* SLICE A4: act_triple_jump / act_backflip (play_flip_sounds cluster).    *)
(* ====================================================================== *)

(* play_flip_sounds (airborne.prog): reads marioObj animFrame (chase) + calls
   play_sound; no stores. *)
Definition air_pfs_xids : list ident := mario._play_sound :: nil.

Example air_pfs_pin :
  (prog_defmap mario_actions_airborne.prog) ! A._play_flip_sounds
  = Some (Gfun (Internal A.f_play_flip_sounds)).
Proof. vm_compute. reflexivity. Qed.
Example air_pfs_vars : fn_vars A.f_play_flip_sounds = nil.
Proof. vm_compute. reflexivity. Qed.
Example air_pfs_pok : air_pok A.f_play_flip_sounds = true.
Proof. vm_compute. reflexivity. Qed.
Example air_pfs_walk :
  wwalk_chk false nil nil nil nil air_pfs_xids nil nil
    (fn_body A.f_play_flip_sounds) = true.
Proof. vm_compute. reflexivity. Qed.

(* the caas + play_mario_sound + play_flip_sounds census (triple_jump /
   backflip) *)
Definition air_tjbf_ids : list ident :=
  A._common_air_action_step :: mario._play_mario_sound
    :: A._play_flip_sounds :: nil.

Example air_tj_pin :
  (prog_defmap mario_actions_airborne.prog) ! A._act_triple_jump
  = Some (Gfun (Internal A.f_act_triple_jump)).
Proof. vm_compute. reflexivity. Qed.
Example air_tj_vars : fn_vars A.f_act_triple_jump = nil.
Proof. vm_compute. reflexivity. Qed.
Example air_tj_pok : air_pok A.f_act_triple_jump = true.
Proof. vm_compute. reflexivity. Qed.
Example air_tj_walk :
  wwalk_chk false nil air_tjbf_ids nil nil nil air_ajc_sids nil
    (fn_body A.f_act_triple_jump) = true.
Proof. vm_compute. reflexivity. Qed.

Example air_bf_pin :
  (prog_defmap mario_actions_airborne.prog) ! A._act_backflip
  = Some (Gfun (Internal A.f_act_backflip)).
Proof. vm_compute. reflexivity. Qed.
Example air_bf_vars : fn_vars A.f_act_backflip = nil.
Proof. vm_compute. reflexivity. Qed.
Example air_bf_pok : air_pok A.f_act_backflip = true.
Proof. vm_compute. reflexivity. Qed.
Example air_bf_walk :
  wwalk_chk false nil air_tjbf_ids nil nil nil air_ajc_sids nil
    (fn_body A.f_act_backflip) = true.
Proof. vm_compute. reflexivity. Qed.

(* ====================================================================== *)
(* SLICE A5a: knockback cluster (hard kb leaves) -- common_air_knockback_  *)
(* step carried as residual Hcp_cakbs (2nd airborne keystone, analogue of  *)
(* Hcp_caas).                                                              *)
(* ====================================================================== *)

(* play_knockback_sound (airborne.prog): reads actionArg/forwardVel window,
   calls play_sound_if_no_flag (internal, Hpsinf); no stores. *)
Definition air_pks_ids : list ident := mario._play_sound_if_no_flag :: nil.

Example air_pks_pin :
  (prog_defmap mario_actions_airborne.prog) ! A._play_knockback_sound
  = Some (Gfun (Internal A.f_play_knockback_sound)).
Proof. vm_compute. reflexivity. Qed.
Example air_pks_vars : fn_vars A.f_play_knockback_sound = nil.
Proof. vm_compute. reflexivity. Qed.
Example air_pks_pok : air_pok A.f_play_knockback_sound = true.
Proof. vm_compute. reflexivity. Qed.
Example air_pks_walk :
  wwalk_chk false nil air_pks_ids nil nil nil nil nil
    (fn_body A.f_play_knockback_sound) = true.
Proof. vm_compute. reflexivity. Qed.

(* act_hard_backward_air_kb / act_hard_forward_air_kb: play_knockback_sound +
   common_air_knockback_step; no stores, return const. *)
Definition air_hkb_ids : list ident :=
  A._play_knockback_sound :: A._common_air_knockback_step :: nil.

Example air_hbkb_pin :
  (prog_defmap mario_actions_airborne.prog) ! A._act_hard_backward_air_kb
  = Some (Gfun (Internal A.f_act_hard_backward_air_kb)).
Proof. vm_compute. reflexivity. Qed.
Example air_hbkb_vars : fn_vars A.f_act_hard_backward_air_kb = nil.
Proof. vm_compute. reflexivity. Qed.
Example air_hbkb_pok : air_pok A.f_act_hard_backward_air_kb = true.
Proof. vm_compute. reflexivity. Qed.
Example air_hbkb_walk :
  wwalk_chk false nil air_hkb_ids nil nil nil nil nil
    (fn_body A.f_act_hard_backward_air_kb) = true.
Proof. vm_compute. reflexivity. Qed.

Example air_hfkb_pin :
  (prog_defmap mario_actions_airborne.prog) ! A._act_hard_forward_air_kb
  = Some (Gfun (Internal A.f_act_hard_forward_air_kb)).
Proof. vm_compute. reflexivity. Qed.
Example air_hfkb_vars : fn_vars A.f_act_hard_forward_air_kb = nil.
Proof. vm_compute. reflexivity. Qed.
Example air_hfkb_pok : air_pok A.f_act_hard_forward_air_kb = true.
Proof. vm_compute. reflexivity. Qed.
Example air_hfkb_walk :
  wwalk_chk false nil air_hkb_ids nil nil nil nil nil
    (fn_body A.f_act_hard_forward_air_kb) = true.
Proof. vm_compute. reflexivity. Qed.

(* SLICE A5b: check_wall_kick (m->faceAngle[1] += 0x8000 indexed-window store
   + set_mario_action(ACT_WALL_KICK_AIR) untainted const) gates the soft /
   directional knockback leaves. *)
Definition air_cwk_sids : list ident := mario._set_mario_action :: nil.

Example air_cwk_pin :
  (prog_defmap mario_actions_airborne.prog) ! A._check_wall_kick
  = Some (Gfun (Internal A.f_check_wall_kick)).
Proof. vm_compute. reflexivity. Qed.
Example air_cwk_vars : fn_vars A.f_check_wall_kick = nil.
Proof. vm_compute. reflexivity. Qed.
Example air_cwk_pok : air_pok A.f_check_wall_kick = true.
Proof. vm_compute. reflexivity. Qed.
Example air_cwk_walk :
  wwalk_chk false nil nil nil nil nil air_cwk_sids nil
    (fn_body A.f_check_wall_kick) = true.
Proof. vm_compute. reflexivity. Qed.

(* act_backward_air_kb / act_forward_air_kb / act_soft_bonk:
   check_wall_kick + play_knockback_sound + common_air_knockback_step;
   no stores in the leaf itself. *)
Definition air_bkb_ids : list ident :=
  A._check_wall_kick :: A._play_knockback_sound
    :: A._common_air_knockback_step :: nil.

Example air_bkb_pin :
  (prog_defmap mario_actions_airborne.prog) ! A._act_backward_air_kb
  = Some (Gfun (Internal A.f_act_backward_air_kb)).
Proof. vm_compute. reflexivity. Qed.
Example air_bkb_vars : fn_vars A.f_act_backward_air_kb = nil.
Proof. vm_compute. reflexivity. Qed.
Example air_bkb_pok : air_pok A.f_act_backward_air_kb = true.
Proof. vm_compute. reflexivity. Qed.
Example air_bkb_walk :
  wwalk_chk false nil air_bkb_ids nil nil nil nil nil
    (fn_body A.f_act_backward_air_kb) = true.
Proof. vm_compute. reflexivity. Qed.

Example air_fkb_pin :
  (prog_defmap mario_actions_airborne.prog) ! A._act_forward_air_kb
  = Some (Gfun (Internal A.f_act_forward_air_kb)).
Proof. vm_compute. reflexivity. Qed.
Example air_fkb_vars : fn_vars A.f_act_forward_air_kb = nil.
Proof. vm_compute. reflexivity. Qed.
Example air_fkb_pok : air_pok A.f_act_forward_air_kb = true.
Proof. vm_compute. reflexivity. Qed.
Example air_fkb_walk :
  wwalk_chk false nil air_bkb_ids nil nil nil nil nil
    (fn_body A.f_act_forward_air_kb) = true.
Proof. vm_compute. reflexivity. Qed.

Example air_sb_pin :
  (prog_defmap mario_actions_airborne.prog) ! A._act_soft_bonk
  = Some (Gfun (Internal A.f_act_soft_bonk)).
Proof. vm_compute. reflexivity. Qed.
Example air_sb_vars : fn_vars A.f_act_soft_bonk = nil.
Proof. vm_compute. reflexivity. Qed.
Example air_sb_pok : air_pok A.f_act_soft_bonk = true.
Proof. vm_compute. reflexivity. Qed.
Example air_sb_walk :
  wwalk_chk false nil air_bkb_ids nil nil nil nil nil
    (fn_body A.f_act_soft_bonk) = true.
Proof. vm_compute. reflexivity. Qed.

(* ====================================================================== *)
(* SLICE A6: the air-physics cluster (rollout leaves).                     *)
(* ====================================================================== *)
(* The two rollout handlers (act_backward_rollout / act_forward_rollout)   *)
(* drive the full air-physics helper chain: update_air_without_turn ->     *)
(* check_horizontal_wind (sqrtf/atan2s), perform_air_step (Hcp_pas         *)
(* keystone), set_mario_animation (lpt), play_mario_sound, play_mario_     *)
(* landing_sound (-> play_sound_and_spawn_particles), mario_set_forward_   *)
(* vel, lava_boost_on_wall (-> update_mario_sound_and_camera (rbn/scm) +    *)
(* atan2s + play_sound + drop_and_set_mario_action).  All stores are       *)
(* window/indexed-window (vel[1], actionState, faceAngle[1], forwardVel,   *)
(* hurtCounter) or untainted-const actions; the chase reads (m->wall,      *)
(* m->marioObj) are loads only (cact = nil).                               *)

(* lava_boost_on_wall: update_mario_sound_and_camera (ids), atan2s +       *)
(* play_sound (xids), drop_and_set_mario_action (sids = air_ccac_sids).    *)
Definition air_lbow_ids : list ident :=
  A._update_mario_sound_and_camera :: nil.
Definition air_lbow_xids : list ident :=
  A._atan2s :: mario._play_sound :: nil.
(* check_horizontal_wind: sqrtf + atan2s (the sins/coss are inlined        *)
(* gSineTable reads; the m->floor read is a load).                         *)
Definition air_chw_xids : list ident := A._sqrtf :: A._atan2s :: nil.
(* update_air_without_turn: check_horizontal_wind (ids) + approach_f32.    *)
Definition air_uawt_ids : list ident := A._check_horizontal_wind :: nil.
Definition air_uawt_xids : list ident := A._approach_f32 :: nil.
(* update_mario_sound_and_camera: raise_background_noise + set_camera_mode *)
Definition air_umsc_xids : list ident :=
  mario._raise_background_noise :: mario._set_camera_mode :: nil.
(* act_backward_rollout callees (set_mario_action via air_sids,            *)
(* play_sound via air_pffs_xids). *)
Definition air_bro_ids : list ident :=
  A._update_air_without_turn :: A._perform_air_step
    :: A._set_mario_animation :: A._play_mario_sound
    :: A._play_mario_landing_sound :: A._mario_set_forward_vel
    :: A._lava_boost_on_wall :: nil.
(* act_forward_rollout: backward + is_anim_past_end *)
Definition air_fro_ids : list ident :=
  A._update_air_without_turn :: A._perform_air_step
    :: A._set_mario_animation :: A._play_mario_sound
    :: A._play_mario_landing_sound :: A._mario_set_forward_vel
    :: A._lava_boost_on_wall :: A._is_anim_past_end :: nil.

(* ---- pins / vars / pok / walks ---- *)
Example air_lbow_pin :
  (prog_defmap mario_actions_airborne.prog) ! A._lava_boost_on_wall
  = Some (Gfun (Internal A.f_lava_boost_on_wall)).
Proof. vm_compute. reflexivity. Qed.
Example air_lbow_vars : fn_vars A.f_lava_boost_on_wall = nil.
Proof. vm_compute. reflexivity. Qed.
Example air_lbow_pok : air_pok A.f_lava_boost_on_wall = true.
Proof. vm_compute. reflexivity. Qed.
Example air_lbow_walk :
  wwalk_chk false nil air_lbow_ids nil nil air_lbow_xids air_ccac_sids nil
    (fn_body A.f_lava_boost_on_wall) = true.
Proof. vm_compute. reflexivity. Qed.

Example air_chw_pin :
  (prog_defmap mario_actions_airborne.prog) ! A._check_horizontal_wind
  = Some (Gfun (Internal A.f_check_horizontal_wind)).
Proof. vm_compute. reflexivity. Qed.
Example air_chw_vars : fn_vars A.f_check_horizontal_wind = nil.
Proof. vm_compute. reflexivity. Qed.
Example air_chw_pok : air_pok A.f_check_horizontal_wind = true.
Proof. vm_compute. reflexivity. Qed.
Example air_chw_walk :
  wwalk_chk false nil nil nil nil air_chw_xids nil nil
    (fn_body A.f_check_horizontal_wind) = true.
Proof. vm_compute. reflexivity. Qed.

Example air_uawt_pin :
  (prog_defmap mario_actions_airborne.prog) ! A._update_air_without_turn
  = Some (Gfun (Internal A.f_update_air_without_turn)).
Proof. vm_compute. reflexivity. Qed.
Example air_uawt_vars : fn_vars A.f_update_air_without_turn = nil.
Proof. vm_compute. reflexivity. Qed.
Example air_uawt_pok : air_pok A.f_update_air_without_turn = true.
Proof. vm_compute. reflexivity. Qed.
Example air_uawt_walk :
  wwalk_chk false nil air_uawt_ids nil nil air_uawt_xids nil nil
    (fn_body A.f_update_air_without_turn) = true.
Proof. vm_compute. reflexivity. Qed.

Example air_umsc_pin :
  (prog_defmap mario.prog) ! mario._update_mario_sound_and_camera
  = Some (Gfun (Internal mario.f_update_mario_sound_and_camera)).
Proof. vm_compute. reflexivity. Qed.
Example air_umsc_vars : fn_vars mario.f_update_mario_sound_and_camera = nil.
Proof. vm_compute. reflexivity. Qed.
Example air_umsc_pok : air_pok mario.f_update_mario_sound_and_camera = true.
Proof. vm_compute. reflexivity. Qed.
Example air_umsc_walk :
  wwalk_chk false nil nil nil nil air_umsc_xids nil nil
    (fn_body mario.f_update_mario_sound_and_camera) = true.
Proof. vm_compute. reflexivity. Qed.

Example air_bro_pin :
  (prog_defmap mario_actions_airborne.prog) ! A._act_backward_rollout
  = Some (Gfun (Internal A.f_act_backward_rollout)).
Proof. vm_compute. reflexivity. Qed.
Example air_bro_vars : fn_vars A.f_act_backward_rollout = nil.
Proof. vm_compute. reflexivity. Qed.
Example air_bro_pok : air_pok A.f_act_backward_rollout = true.
Proof. vm_compute. reflexivity. Qed.
Example air_bro_walk :
  wwalk_chk false nil air_bro_ids nil nil air_pffs_xids air_sids nil
    (fn_body A.f_act_backward_rollout) = true.
Proof. vm_compute. reflexivity. Qed.

Example air_fro_pin :
  (prog_defmap mario_actions_airborne.prog) ! A._act_forward_rollout
  = Some (Gfun (Internal A.f_act_forward_rollout)).
Proof. vm_compute. reflexivity. Qed.
Example air_fro_vars : fn_vars A.f_act_forward_rollout = nil.
Proof. vm_compute. reflexivity. Qed.
Example air_fro_pok : air_pok A.f_act_forward_rollout = true.
Proof. vm_compute. reflexivity. Qed.
Example air_fro_walk :
  wwalk_chk false nil air_fro_ids nil nil air_pffs_xids air_sids nil
    (fn_body A.f_act_forward_rollout) = true.
Proof. vm_compute. reflexivity. Qed.

(* ====================================================================== *)
(* SLICE A7: act_butt_slide_air + act_air_hit_wall (reuse the A6 cluster). *)
(* ====================================================================== *)
(* update_air_with_turn is the turning twin of update_air_without_turn --  *)
(* SAME callee census (air_uawt_ids / air_uawt_xids).                      *)
Definition air_bsa_ids : list ident :=
  A._update_air_with_turn :: A._perform_air_step :: A._lava_boost_on_wall
    :: A._play_mario_landing_sound :: A._set_mario_animation :: nil.
Definition air_ahw_ids : list ident :=
  A._mario_drop_held_object :: A._mario_set_forward_vel
    :: A._set_mario_animation :: nil.

Example air_uawith_pin :
  (prog_defmap mario_actions_airborne.prog) ! A._update_air_with_turn
  = Some (Gfun (Internal A.f_update_air_with_turn)).
Proof. vm_compute. reflexivity. Qed.
Example air_uawith_vars : fn_vars A.f_update_air_with_turn = nil.
Proof. vm_compute. reflexivity. Qed.
Example air_uawith_pok : air_pok A.f_update_air_with_turn = true.
Proof. vm_compute. reflexivity. Qed.
Example air_uawith_walk :
  wwalk_chk false nil air_uawt_ids nil nil air_uawt_xids nil nil
    (fn_body A.f_update_air_with_turn) = true.
Proof. vm_compute. reflexivity. Qed.

Example air_bsa_pin :
  (prog_defmap mario_actions_airborne.prog) ! A._act_butt_slide_air
  = Some (Gfun (Internal A.f_act_butt_slide_air)).
Proof. vm_compute. reflexivity. Qed.
Example air_bsa_vars : fn_vars A.f_act_butt_slide_air = nil.
Proof. vm_compute. reflexivity. Qed.
Example air_bsa_pok : air_pok A.f_act_butt_slide_air = true.
Proof. vm_compute. reflexivity. Qed.
Example air_bsa_walk :
  wwalk_chk false nil air_bsa_ids nil nil nil air_sids nil
    (fn_body A.f_act_butt_slide_air) = true.
Proof. vm_compute. reflexivity. Qed.

Example air_ahw_pin :
  (prog_defmap mario_actions_airborne.prog) ! A._act_air_hit_wall
  = Some (Gfun (Internal A.f_act_air_hit_wall)).
Proof. vm_compute. reflexivity. Qed.
Example air_ahw_vars : fn_vars A.f_act_air_hit_wall = nil.
Proof. vm_compute. reflexivity. Qed.
Example air_ahw_pok : air_pok A.f_act_air_hit_wall = true.
Proof. vm_compute. reflexivity. Qed.
Example air_ahw_walk :
  wwalk_chk false nil air_ahw_ids nil nil nil air_sids nil
    (fn_body A.f_act_air_hit_wall) = true.
Proof. vm_compute. reflexivity. Qed.

(* ====================================================================== *)
(* SLICE A8: hold_butt_slide_air + riding_shell_air + side_flip.          *)
(* riding_shell_air / side_flip WRITE a non-pointer (float / s16) THROUGH  *)
(* m->marioObj (a chase_root pointer -> SafeB block, distinct from bm):    *)
(* the cact (chase-action) write-through path.  cact = the marioObj-chase  *)
(* POINTER temps only (NOT the scalar-read temps).                         *)
(* ====================================================================== *)
Definition air_hbsa_ids : list ident :=
  A._update_air_with_turn :: A._lava_boost_on_wall
    :: A._mario_drop_held_object :: A._perform_air_step
    :: A._play_mario_landing_sound :: A._set_mario_animation :: nil.
Definition air_rsa_ids : list ident :=
  A._lava_boost_on_wall :: A._mario_set_forward_vel :: A._perform_air_step
    :: A._play_mario_sound :: A._set_mario_animation
    :: A._update_air_without_turn :: nil.
Definition air_rsa_cact : list ident := A._t'2 :: A._t'3 :: nil.
Definition air_sf_ids : list ident :=
  A._common_air_action_step :: A._play_mario_sound :: nil.
Definition air_sf_cact : list ident :=
  A._t'4 :: A._t'6 :: A._t'7 :: A._t'8 :: nil.

Example air_hbsa_pin :
  (prog_defmap mario_actions_airborne.prog) ! A._act_hold_butt_slide_air
  = Some (Gfun (Internal A.f_act_hold_butt_slide_air)).
Proof. vm_compute. reflexivity. Qed.
Example air_hbsa_vars : fn_vars A.f_act_hold_butt_slide_air = nil.
Proof. vm_compute. reflexivity. Qed.
Example air_hbsa_pok : air_pok A.f_act_hold_butt_slide_air = true.
Proof. vm_compute. reflexivity. Qed.
Example air_hbsa_walk :
  wwalk_chk false nil air_hbsa_ids nil nil nil air_ajc_sids nil
    (fn_body A.f_act_hold_butt_slide_air) = true.
Proof. vm_compute. reflexivity. Qed.

Example air_rsa_pin :
  (prog_defmap mario_actions_airborne.prog) ! A._act_riding_shell_air
  = Some (Gfun (Internal A.f_act_riding_shell_air)).
Proof. vm_compute. reflexivity. Qed.
Example air_rsa_vars : fn_vars A.f_act_riding_shell_air = nil.
Proof. vm_compute. reflexivity. Qed.
Example air_rsa_pok : air_pok A.f_act_riding_shell_air = true.
Proof. vm_compute. reflexivity. Qed.
Example air_rsa_nonparam :
  forallb (fun t' => negb (mem_id t' (map fst (fn_params A.f_act_riding_shell_air))))
    air_rsa_cact = true.
Proof. vm_compute. reflexivity. Qed.
Example air_rsa_walk :
  wwalk_chk false nil air_rsa_ids nil air_rsa_cact nil air_sids nil
    (fn_body A.f_act_riding_shell_air) = true.
Proof. vm_compute. reflexivity. Qed.

Example air_sf_pin :
  (prog_defmap mario_actions_airborne.prog) ! A._act_side_flip
  = Some (Gfun (Internal A.f_act_side_flip)).
Proof. vm_compute. reflexivity. Qed.
Example air_sf_vars : fn_vars A.f_act_side_flip = nil.
Proof. vm_compute. reflexivity. Qed.
Example air_sf_pok : air_pok A.f_act_side_flip = true.
Proof. vm_compute. reflexivity. Qed.
Example air_sf_nonparam :
  forallb (fun t' => negb (mem_id t' (map fst (fn_params A.f_act_side_flip))))
    air_sf_cact = true.
Proof. vm_compute. reflexivity. Qed.
Example air_sf_walk :
  wwalk_chk false nil air_sf_ids nil air_sf_cact air_pffs_xids air_sids nil
    (fn_body A.f_act_side_flip) = true.
Proof. vm_compute. reflexivity. Qed.

(* ====================================================================== *)
(* SLICE A9: mario_bonk_reflection row + act_special_triple_jump.          *)
(* ====================================================================== *)
(* mario_bonk_reflection (mario_step.prog): faceAngle[1] window store +    *)
(* mario_set_forward_vel + atan2s/play_sound externals.                    *)
Definition air_mbr_ids : list ident := mario._mario_set_forward_vel :: nil.
Definition air_mbr_xids : list ident :=
  A._atan2s :: mario._play_sound :: nil.
Definition air_stj_ids : list ident :=
  A._mario_bonk_reflection :: A._perform_air_step
    :: A._play_mario_landing_sound :: A._play_mario_sound
    :: A._set_mario_animation :: A._update_air_without_turn :: nil.

Example air_mbr_pin :
  (prog_defmap mario_step.prog) ! mario_step._mario_bonk_reflection
  = Some (Gfun (Internal mario_step.f_mario_bonk_reflection)).
Proof. vm_compute. reflexivity. Qed.
Example air_mbr_vars : fn_vars mario_step.f_mario_bonk_reflection = nil.
Proof. vm_compute. reflexivity. Qed.
Example air_mbr_pok : air_pok mario_step.f_mario_bonk_reflection = true.
Proof. vm_compute. reflexivity. Qed.
Example air_mbr_walk :
  wwalk_chk false nil air_mbr_ids nil nil air_mbr_xids nil nil
    (fn_body mario_step.f_mario_bonk_reflection) = true.
Proof. vm_compute. reflexivity. Qed.

Example air_stj_pin :
  (prog_defmap mario_actions_airborne.prog) ! A._act_special_triple_jump
  = Some (Gfun (Internal A.f_act_special_triple_jump)).
Proof. vm_compute. reflexivity. Qed.
Example air_stj_vars : fn_vars A.f_act_special_triple_jump = nil.
Proof. vm_compute. reflexivity. Qed.
Example air_stj_pok : air_pok A.f_act_special_triple_jump = true.
Proof. vm_compute. reflexivity. Qed.
Example air_stj_walk :
  wwalk_chk false nil air_stj_ids nil nil air_pffs_xids air_sids nil
    (fn_body A.f_act_special_triple_jump) = true.
Proof. vm_compute. reflexivity. Qed.

(* ====================================================================== *)
(* SLICE A10: act_water_jump + act_hold_water_jump.                        *)
(* ====================================================================== *)
(* Both are thin perform_air_step wrappers: mario_set_forward_vel /        *)
(* play_mario_sound / set_mario_animation / perform_air_step /             *)
(* lava_boost_on_wall (all call_pres), set_camera_mode (call_pres_ext via  *)
(* Hcpx_scm; its m->area->camera args are pure reads), set_mario_action /  *)
(* drop_and_set_mario_action with vm-checkable untainted const actions.    *)
(* hold_water_jump additionally reads m->marioObj->rawData (a chase read,  *)
(* load-only -> no cact needed).                                           *)
Definition air_wj_ids : list ident :=
  mario._mario_set_forward_vel :: mario._play_mario_sound
    :: mario._set_mario_animation :: A._perform_air_step
    :: A._lava_boost_on_wall :: nil.
Definition air_wj_xids : list ident := mario._set_camera_mode :: nil.

Example air_wj_pin :
  (prog_defmap mario_actions_airborne.prog) ! A._act_water_jump
  = Some (Gfun (Internal A.f_act_water_jump)).
Proof. vm_compute. reflexivity. Qed.
Example air_wj_vars : fn_vars A.f_act_water_jump = nil.
Proof. vm_compute. reflexivity. Qed.
Example air_wj_pok : air_pok A.f_act_water_jump = true.
Proof. vm_compute. reflexivity. Qed.
Example air_wj_walk :
  wwalk_chk false nil air_wj_ids nil nil air_wj_xids air_sids nil
    (fn_body A.f_act_water_jump) = true.
Proof. vm_compute. reflexivity. Qed.

Example air_hwj_pin :
  (prog_defmap mario_actions_airborne.prog) ! A._act_hold_water_jump
  = Some (Gfun (Internal A.f_act_hold_water_jump)).
Proof. vm_compute. reflexivity. Qed.
Example air_hwj_vars : fn_vars A.f_act_hold_water_jump = nil.
Proof. vm_compute. reflexivity. Qed.
Example air_hwj_pok : air_pok A.f_act_hold_water_jump = true.
Proof. vm_compute. reflexivity. Qed.
Example air_hwj_walk :
  wwalk_chk false nil air_wj_ids nil nil air_wj_xids air_ajc_sids nil
    (fn_body A.f_act_hold_water_jump) = true.
Proof. vm_compute. reflexivity. Qed.

(* ====================================================================== *)
(* The walked / rest split of airborne_callee_ids.                        *)
(* ====================================================================== *)
Definition airborne_walked_ids : list ident :=
  A._check_common_airborne_cancels ::
  A._play_far_fall_sound ::
  A._act_freefall ::
  A._act_hold_freefall ::
  A._act_wall_kick_air ::
  A._act_top_of_pole_jump ::
  A._act_hold_jump ::
  A._act_long_jump ::
  A._act_triple_jump ::
  A._act_backflip ::
  A._act_hard_backward_air_kb ::
  A._act_hard_forward_air_kb ::
  A._act_backward_air_kb ::
  A._act_forward_air_kb ::
  A._act_soft_bonk ::
  A._act_backward_rollout ::
  A._act_forward_rollout ::
  A._act_butt_slide_air ::
  A._act_air_hit_wall ::
  A._act_hold_butt_slide_air ::
  A._act_riding_shell_air ::
  A._act_side_flip ::
  A._act_special_triple_jump ::
  A._act_water_jump ::
  A._act_hold_water_jump :: nil.

Definition airborne_rest_ids : list ident :=
  A._act_jump ::
  A._act_double_jump ::
  A._act_twirling ::
  A._act_steep_jump ::
  A._act_burning_jump ::
  A._act_burning_fall ::
  A._act_dive ::
  A._act_air_throw ::
  A._act_lava_boost ::
  A._act_getting_blown ::
  A._act_crazy_box_bounce ::
  A._act_ground_pound ::
  A._act_thrown_forward ::
  A._act_thrown_backward ::
  A._act_jump_kick ::
  A._act_riding_hoot ::
  A._act_vertical_wind ::
  A._act_slide_kick :: nil.

(* the rest list is EXACTLY the non-walked complement of the census *)
Example air_rest_check :
  airborne_rest_ids
  = filter (fun id => negb (mem_id id airborne_walked_ids)) airborne_callee_ids.
Proof. vm_compute. reflexivity. Qed.

(* ====================================================================== *)
Section AirborneLeafRows.
  Variable lp : Clight.program.
  Hypothesis LO_mario : linkorder mario.prog lp.
  Hypothesis LO_mario_step : linkorder mario_step.prog lp.
  Hypothesis LO_air : linkorder mario_actions_airborne.prog lp.
  Hypothesis LO_int : linkorder interaction.prog lp.
  Hypothesis LO_obj : linkorder mario_actions_object.prog lp.

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

  (* play_sound: pure audio external, the honest model boundary *)
  Hypothesis Hcpx_psound :
    call_pres_ext lp bm NoA MWF mario._play_sound.
  (* the obj_ext boundary (set_camera_mode/vec3s_set for swpa + the dasma
     trio segmented_to_virtual / stop_shell_music / obj_set_held_state).
     The capstone supplies its own Hpres_obj_ext verbatim. *)
  Hypothesis Hpres_obj_ext : forall fid,
      mem_id fid obj_ext_ids = true -> call_pres_ext lp bm NoA MWF fid.

  (* ==================================================================== *)
  (* Reused rows.                                                         *)
  (* ==================================================================== *)

  (* set_mario_action keystone *)
  Let Hsmact : call_pres_act lp bm NoA MWF mario._set_mario_action :=
    smact_pres lp LO_mario LO_mario_step bm NoA MWF HNoA_of_MWF
      HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
      HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe.

  (* drop_and_set_mario_action -- REUSED from ObjectLeafSurface.dasma_row *)
  Let Hdasma : call_pres_act lp bm NoA MWF mario._drop_and_set_mario_action :=
    dasma_row lp LO_mario LO_mario_step LO_int bm NoA MWF HNoA_of_MWF
      HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
      HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
      (Hpres_obj_ext interaction._segmented_to_virtual eq_refl)
      (Hpres_obj_ext interaction._stop_shell_music eq_refl)
      (Hpres_obj_ext interaction._obj_set_held_state eq_refl).

  (* the set_mario_action sids-rows arm *)
  Lemma air_sids_rows : forall fid, mem_id fid air_sids = true ->
      call_pres_act lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold air_sids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsmact | ].
    discriminate H.
  Qed.

  (* ==================================================================== *)
  (* set_water_plunge_action (call_pres) row.                             *)
  (* ==================================================================== *)
  Lemma air_swpa_xids_rows : forall fid, mem_id fid air_swpa_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold air_swpa_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid;
        exact (Hpres_obj_ext mario._set_camera_mode eq_refl) | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid;
        exact (Hpres_obj_ext mario._vec3s_set eq_refl) | ].
    discriminate H.
  Qed.

  Lemma air_swpa_row : call_pres lp bm NoA MWF mario._set_water_plunge_action.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario.prog mario._set_water_plunge_action
             mario.f_set_water_plunge_action
             nil nil air_swpa_xids air_sids
             LO_mario air_swpa_pin air_swpa_vars air_swpa_pok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact air_swpa_xids_rows.
    - exact air_sids_rows.
    - exact air_swpa_walk.
  Qed.

  (* ==================================================================== *)
  (* check_common_airborne_cancels (the common cancel gate).              *)
  (* ==================================================================== *)
  Lemma air_ccac_ids_rows : forall fid, mem_id fid air_ccac_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold air_ccac_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact air_swpa_row | ].
    discriminate H.
  Qed.

  Lemma air_ccac_sids_rows : forall fid, mem_id fid air_ccac_sids = true ->
      call_pres_act lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold air_ccac_sids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hdasma | ].
    discriminate H.
  Qed.

  Lemma air_ccac_pres :
    body_pres lp NoA MWF bm A.f_check_common_airborne_cancels.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             A.f_check_common_airborne_cancels
             air_ccac_ids nil nil air_ccac_sids nil air_ccac_vars air_ccac_pok).
    - exact air_ccac_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact air_ccac_sids_rows.
    - intros fid' H. discriminate H.
    - exact air_ccac_walk.
  Qed.

  (* ==================================================================== *)
  (* play_far_fall_sound (the peak-fall audio cue).                       *)
  (* ==================================================================== *)
  Lemma air_pffs_xids_rows : forall fid, mem_id fid air_pffs_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold air_pffs_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_psound | ].
    discriminate H.
  Qed.

  Lemma air_pffs_pres :
    body_pres lp NoA MWF bm A.f_play_far_fall_sound.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             A.f_play_far_fall_sound
             nil nil air_pffs_xids nil nil air_pffs_vars air_pffs_pok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact air_pffs_xids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact air_pffs_walk.
  Qed.

  (* ==================================================================== *)
  (* SLICE A2: the common_air_action_step jump-cluster.                   *)
  (* ==================================================================== *)

  (* common_air_action_step: the BIG shared air-physics helper, carried as
     a call_pres residual (internal mario_actions_airborne.prog, the air
     analogue of Hcp_pgs; discharged later by walking its body).  All its
     stores are window / indexed-window + untainted-const actions. *)
  Hypothesis Hcp_caas :
    call_pres lp bm NoA MWF mario_actions_airborne._common_air_action_step.

  (* 2nd airborne keystone: common_air_knockback_step (INTERNAL airborne.prog;
     discharge later by walking its body). *)
  Hypothesis Hcp_cakbs :
    call_pres lp bm NoA MWF mario_actions_airborne._common_air_knockback_step.

  (* ==================================================================== *)
  (* SLICE A6 boundary: the air-physics terminal externals + the          *)
  (* perform_air_step keystone (the honest model boundary -- EF_external   *)
  (* math/audio builtins cannot be proved from CompCert axioms; carried as *)
  (* capstone Hypotheses; perform_air_step is INTERNAL, dischargeable      *)
  (* later by walking its body like Hcp_pgs).                              *)
  (* ==================================================================== *)
  Hypothesis Hcpx_sqrtf : call_pres_ext lp bm NoA MWF A._sqrtf.
  Hypothesis Hcpx_atan2s : call_pres_ext lp bm NoA MWF A._atan2s.
  Hypothesis Hcpx_approach : call_pres_ext lp bm NoA MWF A._approach_f32.
  Hypothesis Hcpx_lpt : call_pres_ext lp bm NoA MWF mario._load_patchable_table.
  Hypothesis Hcpx_rbn :
    call_pres_ext lp bm NoA MWF mario._raise_background_noise.
  Hypothesis Hcpx_scm : call_pres_ext lp bm NoA MWF mario._set_camera_mode.
  Hypothesis Hcp_pas : call_pres lp bm NoA MWF A._perform_air_step.

  (* play_mario_jump_sound -- REUSED from ObjectLeafSurface.pmjs_row *)
  Let Hpmjs : call_pres lp bm NoA MWF mario._play_mario_jump_sound :=
    ObjectLeafSurface.pmjs_row lp LO_mario bm NoA MWF HNoA_of_MWF HMWF_window
      HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot HMWF_chase HMWF_root
      HMWF_sglob HchaseStep HMWF_chase_safe Hcpx_psound.

  Lemma air_ajc_ids_rows : forall fid, mem_id fid air_ajc_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold air_ajc_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_caas | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hpmjs | ].
    discriminate H.
  Qed.

  Lemma air_ajc_sids_rows : forall fid, mem_id fid air_ajc_sids = true ->
      call_pres_act lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold air_ajc_sids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsmact | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hdasma | ].
    discriminate H.
  Qed.

  (* the three clean caas-dependent wrappers *)
  Lemma air_ff_pres : body_pres lp NoA MWF bm A.f_act_freefall.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             A.f_act_freefall
             air_ajc_ids nil nil air_ajc_sids nil air_ff_vars air_ff_pok).
    - exact air_ajc_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact air_ajc_sids_rows.
    - intros fid' H. discriminate H.
    - exact air_ff_walk.
  Qed.

  Lemma air_hff_pres : body_pres lp NoA MWF bm A.f_act_hold_freefall.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             A.f_act_hold_freefall
             air_ajc_ids nil nil air_ajc_sids nil air_hff_vars air_hff_pok).
    - exact air_ajc_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact air_ajc_sids_rows.
    - intros fid' H. discriminate H.
    - exact air_hff_walk.
  Qed.

  Lemma air_wka_pres : body_pres lp NoA MWF bm A.f_act_wall_kick_air.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             A.f_act_wall_kick_air
             air_ajc_ids nil nil air_ajc_sids nil air_wka_vars air_wka_pok).
    - exact air_ajc_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact air_ajc_sids_rows.
    - intros fid' H. discriminate H.
    - exact air_wka_walk.
  Qed.

  (* ==================================================================== *)
  (* SLICE A3: play_mario_sound cluster (top_of_pole_jump / hold_jump /    *)
  (* long_jump).                                                          *)
  (* ==================================================================== *)

  (* play_mario_action_sound / play_sound_if_no_flag -- REUSED top-level
     ObjectLeafSurface rows (both bottom out in play_sound via Hcpx_psound). *)
  Let Hpmas : call_pres lp bm NoA MWF mario._play_mario_action_sound :=
    ObjectLeafSurface.pmas_row lp LO_mario bm NoA MWF HNoA_of_MWF HMWF_window
      HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot HMWF_chase HMWF_root
      HMWF_sglob HchaseStep HMWF_chase_safe Hcpx_psound.
  Let Hpsinf : call_pres lp bm NoA MWF mario._play_sound_if_no_flag :=
    ObjectLeafSurface.psinf_row lp LO_mario bm NoA MWF HNoA_of_MWF HMWF_window
      HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot HMWF_chase HMWF_root
      HMWF_sglob HchaseStep HMWF_chase_safe Hcpx_psound.

  Lemma air_pms_ids_rows : forall fid, mem_id fid air_pms_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold air_pms_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hpmas | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hpmjs | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hpsinf | ].
    discriminate H.
  Qed.

  (* play_mario_sound: no stores, dispatches to the 3 audio helpers. *)
  Lemma air_pms_row : call_pres lp bm NoA MWF mario._play_mario_sound.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario.prog mario._play_mario_sound mario.f_play_mario_sound
             air_pms_ids nil nil nil
             LO_mario air_pms_pin air_pms_vars air_pms_pok).
    - exact air_pms_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact air_pms_walk.
  Qed.

  Lemma air_cps_ids_rows : forall fid, mem_id fid air_cps_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold air_cps_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_caas | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact air_pms_row | ].
    discriminate H.
  Qed.

  Lemma air_lj_xids_rows : forall fid, mem_id fid air_lj_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold air_lj_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_psound | ].
    discriminate H.
  Qed.

  (* act_top_of_pole_jump: caas + play_mario_jump_sound (air_ajc census). *)
  Lemma air_tpj_pres : body_pres lp NoA MWF bm A.f_act_top_of_pole_jump.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             A.f_act_top_of_pole_jump
             air_ajc_ids nil nil air_ajc_sids nil air_tpj_vars air_tpj_pok).
    - exact air_ajc_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact air_ajc_sids_rows.
    - intros fid' H. discriminate H.
    - exact air_tpj_walk.
  Qed.

  (* act_hold_jump: caas + play_mario_sound + sids. *)
  Lemma air_hj_pres : body_pres lp NoA MWF bm A.f_act_hold_jump.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             A.f_act_hold_jump
             air_cps_ids nil nil air_ajc_sids nil air_hj_vars air_hj_pok).
    - exact air_cps_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact air_ajc_sids_rows.
    - intros fid' H. discriminate H.
    - exact air_hj_walk.
  Qed.

  (* act_long_jump: caas + play_mario_sound + play_sound(ext); one
     m->actionState window store. *)
  Lemma air_lj_pres : body_pres lp NoA MWF bm A.f_act_long_jump.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             A.f_act_long_jump
             air_cps_ids nil air_lj_xids nil nil air_lj_vars air_lj_pok).
    - exact air_cps_ids_rows.
    - intros fid' H. discriminate H.
    - exact air_lj_xids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact air_lj_walk.
  Qed.

  (* ==================================================================== *)
  (* SLICE A4: play_flip_sounds cluster (triple_jump / backflip).         *)
  (* ==================================================================== *)
  Lemma air_pfs_xids_rows : forall fid, mem_id fid air_pfs_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold air_pfs_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_psound | ].
    discriminate H.
  Qed.

  (* play_flip_sounds: play_sound ext only, no stores. *)
  Lemma air_pfs_row : call_pres lp bm NoA MWF A._play_flip_sounds.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_airborne.prog A._play_flip_sounds A.f_play_flip_sounds
             nil nil air_pfs_xids nil
             LO_air air_pfs_pin air_pfs_vars air_pfs_pok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact air_pfs_xids_rows.
    - intros fid' H. discriminate H.
    - exact air_pfs_walk.
  Qed.

  Lemma air_tjbf_ids_rows : forall fid, mem_id fid air_tjbf_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold air_tjbf_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_caas | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact air_pms_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact air_pfs_row | ].
    discriminate H.
  Qed.

  Lemma air_tj_pres : body_pres lp NoA MWF bm A.f_act_triple_jump.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             A.f_act_triple_jump
             air_tjbf_ids nil nil air_ajc_sids nil air_tj_vars air_tj_pok).
    - exact air_tjbf_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact air_ajc_sids_rows.
    - intros fid' H. discriminate H.
    - exact air_tj_walk.
  Qed.

  Lemma air_bf_pres : body_pres lp NoA MWF bm A.f_act_backflip.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             A.f_act_backflip
             air_tjbf_ids nil nil air_ajc_sids nil air_bf_vars air_bf_pok).
    - exact air_tjbf_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact air_ajc_sids_rows.
    - intros fid' H. discriminate H.
    - exact air_bf_walk.
  Qed.

  (* -------- SLICE A5a: knockback (hard kb) rows -------- *)

  (* play_knockback_sound: play_sound_if_no_flag (internal) only, no stores. *)
  Lemma air_pks_ids_rows : forall fid, mem_id fid air_pks_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold air_pks_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hpsinf | ].
    discriminate H.
  Qed.

  Lemma air_pks_row : call_pres lp bm NoA MWF A._play_knockback_sound.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_airborne.prog A._play_knockback_sound
             A.f_play_knockback_sound
             air_pks_ids nil nil nil
             LO_air air_pks_pin air_pks_vars air_pks_pok).
    - exact air_pks_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact air_pks_walk.
  Qed.

  (* the hard-kb census: play_knockback_sound + common_air_knockback_step *)
  Lemma air_hkb_ids_rows : forall fid, mem_id fid air_hkb_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold air_hkb_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact air_pks_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_cakbs | ].
    discriminate H.
  Qed.

  Lemma air_hbkb_pres : body_pres lp NoA MWF bm A.f_act_hard_backward_air_kb.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             A.f_act_hard_backward_air_kb
             air_hkb_ids nil nil nil nil air_hbkb_vars air_hbkb_pok).
    - exact air_hkb_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact air_hbkb_walk.
  Qed.

  Lemma air_hfkb_pres : body_pres lp NoA MWF bm A.f_act_hard_forward_air_kb.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             A.f_act_hard_forward_air_kb
             air_hkb_ids nil nil nil nil air_hfkb_vars air_hfkb_pok).
    - exact air_hkb_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact air_hfkb_walk.
  Qed.

  (* -------- SLICE A5b: check_wall_kick + directional/soft kb rows -------- *)

  Lemma air_cwk_sids_rows : forall fid, mem_id fid air_cwk_sids = true ->
      call_pres_act lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold air_cwk_sids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsmact | ].
    discriminate H.
  Qed.

  (* check_wall_kick: faceAngle[1] indexed-window store + set_mario_action
     (ACT_WALL_KICK_AIR const, via Hsmact); returns s32. *)
  Lemma air_cwk_row : call_pres lp bm NoA MWF A._check_wall_kick.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_airborne.prog A._check_wall_kick
             A.f_check_wall_kick
             nil nil nil air_cwk_sids
             LO_air air_cwk_pin air_cwk_vars air_cwk_pok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact air_cwk_sids_rows.
    - exact air_cwk_walk.
  Qed.

  (* the directional/soft-kb census:
     check_wall_kick + play_knockback_sound + common_air_knockback_step *)
  Lemma air_bkb_ids_rows : forall fid, mem_id fid air_bkb_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold air_bkb_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact air_cwk_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact air_pks_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_cakbs | ].
    discriminate H.
  Qed.

  Lemma air_bkb_pres : body_pres lp NoA MWF bm A.f_act_backward_air_kb.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             A.f_act_backward_air_kb
             air_bkb_ids nil nil nil nil air_bkb_vars air_bkb_pok).
    - exact air_bkb_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact air_bkb_walk.
  Qed.

  Lemma air_fkb_pres : body_pres lp NoA MWF bm A.f_act_forward_air_kb.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             A.f_act_forward_air_kb
             air_bkb_ids nil nil nil nil air_fkb_vars air_fkb_pok).
    - exact air_bkb_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact air_fkb_walk.
  Qed.

  Lemma air_sb_pres : body_pres lp NoA MWF bm A.f_act_soft_bonk.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             A.f_act_soft_bonk
             air_bkb_ids nil nil nil nil air_sb_vars air_sb_pok).
    - exact air_bkb_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact air_sb_walk.
  Qed.

  (* ==================================================================== *)
  (* SLICE A6: the air-physics helper rows + the two rollout leaves.      *)
  (* ==================================================================== *)

  (* mario_set_forward_vel / is_anim_past_end -- REUSED top-level rows. *)
  Let Hmsfv : call_pres lp bm NoA MWF mario._mario_set_forward_vel :=
    ActWriterSurface.msfv_row lp LO_mario bm NoA MWF HNoA_of_MWF HMWF_window
      HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot HMWF_chase HMWF_root
      HMWF_sglob HchaseStep HMWF_chase_safe.
  Let Hipae : call_pres lp bm NoA MWF mario._is_anim_past_end :=
    ObjectLeafSurface.ipae_row lp LO_mario bm NoA MWF HNoA_of_MWF HMWF_window
      HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot HMWF_chase HMWF_root
      HMWF_sglob HchaseStep HMWF_chase_safe.

  (* ---- set_mario_animation (deep 2-hop chase cact, sole ext lpt) ---- *)
  Lemma air_sma_xids_rows :
    forall fid, mem_id fid StationaryLeafSurface.sta_sma_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold StationaryLeafSurface.sta_sma_xids in H.
    cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_lpt | ].
    discriminate H.
  Qed.
  Lemma air_sma_row : call_pres lp bm NoA MWF mario._set_mario_animation.
  Proof.
    apply (call_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario.prog mario._set_mario_animation mario.f_set_mario_animation
             nil nil StationaryLeafSurface.sta_sma_cact
             StationaryLeafSurface.sta_sma_xids nil
             LO_mario StationaryLeafSurface.sta_sma_pin
             StationaryLeafSurface.sta_sma_vars
             StationaryLeafSurface.sta_sma_params_ok
             StationaryLeafSurface.sta_sma_nonparam).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact air_sma_xids_rows.
    - intros fid' H. discriminate H.
    - exact StationaryLeafSurface.sta_sma_walk.
  Qed.

  (* ---- play_sound_and_spawn_particles -> play_mario_landing_sound ---- *)
  Lemma air_pssp_row :
    call_pres lp bm NoA MWF mario._play_sound_and_spawn_particles.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario.prog mario._play_sound_and_spawn_particles
             mario.f_play_sound_and_spawn_particles nil nil
             StationaryLeafSurface.sta_psound_xids nil
             LO_mario StationaryLeafSurface.sta_pssp_pin
             StationaryLeafSurface.sta_pssp_vars
             StationaryLeafSurface.sta_pssp_params_ok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. unfold StationaryLeafSurface.sta_psound_xids in H.
      cbn [mem_id existsb] in H.
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hcpx_psound | ].
      discriminate H.
    - intros fid' H. discriminate H.
    - exact StationaryLeafSurface.sta_pssp_walk.
  Qed.
  Lemma air_pmls_ids_rows :
    forall fid, mem_id fid StationaryLeafSurface.sta_pmls_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold StationaryLeafSurface.sta_pmls_ids in H.
    cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact air_pssp_row | ].
    discriminate H.
  Qed.
  Lemma air_pmls_row :
    call_pres lp bm NoA MWF mario._play_mario_landing_sound.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario.prog mario._play_mario_landing_sound
             mario.f_play_mario_landing_sound
             StationaryLeafSurface.sta_pmls_ids nil nil nil
             LO_mario StationaryLeafSurface.sta_pmls_pin
             StationaryLeafSurface.sta_pmls_vars
             StationaryLeafSurface.sta_pmls_params_ok).
    - exact air_pmls_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact StationaryLeafSurface.sta_pmls_walk.
  Qed.

  (* ---- check_horizontal_wind (sqrtf + atan2s) ---- *)
  Lemma air_chw_xids_rows : forall fid, mem_id fid air_chw_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold air_chw_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_sqrtf | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_atan2s | ].
    discriminate H.
  Qed.
  Lemma air_chw_row : call_pres lp bm NoA MWF A._check_horizontal_wind.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_airborne.prog A._check_horizontal_wind
             A.f_check_horizontal_wind
             nil nil air_chw_xids nil
             LO_air air_chw_pin air_chw_vars air_chw_pok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact air_chw_xids_rows.
    - intros fid' H. discriminate H.
    - exact air_chw_walk.
  Qed.

  (* ---- update_air_without_turn (check_horizontal_wind + approach_f32) ---- *)
  Lemma air_uawt_ids_rows : forall fid, mem_id fid air_uawt_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold air_uawt_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact air_chw_row | ].
    discriminate H.
  Qed.
  Lemma air_uawt_xids_rows : forall fid, mem_id fid air_uawt_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold air_uawt_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_approach | ].
    discriminate H.
  Qed.
  Lemma air_uawt_row : call_pres lp bm NoA MWF A._update_air_without_turn.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_airborne.prog A._update_air_without_turn
             A.f_update_air_without_turn
             air_uawt_ids nil air_uawt_xids nil
             LO_air air_uawt_pin air_uawt_vars air_uawt_pok).
    - exact air_uawt_ids_rows.
    - intros fid' H. discriminate H.
    - exact air_uawt_xids_rows.
    - intros fid' H. discriminate H.
    - exact air_uawt_walk.
  Qed.

  (* ---- update_mario_sound_and_camera (rbn + scm) ---- *)
  Lemma air_umsc_pres :
    body_pres lp NoA MWF bm mario.f_update_mario_sound_and_camera.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario.f_update_mario_sound_and_camera
             nil nil air_umsc_xids nil nil air_umsc_vars air_umsc_pok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. unfold air_umsc_xids in H. cbn [mem_id existsb] in H.
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hcpx_rbn | ].
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hcpx_scm | ].
      discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact air_umsc_walk.
  Qed.
  Let Humsc : call_pres lp bm NoA MWF mario._update_mario_sound_and_camera :=
    call_pres_of_body lp bm NoA MWF HNoA_of_MWF mario.prog
      mario._update_mario_sound_and_camera
      mario.f_update_mario_sound_and_camera LO_mario air_umsc_pin air_umsc_pres.

  (* ---- lava_boost_on_wall (umsc + atan2s/play_sound + dasma) ---- *)
  Lemma air_lbow_ids_rows : forall fid, mem_id fid air_lbow_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold air_lbow_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Humsc | ].
    discriminate H.
  Qed.
  Lemma air_lbow_xids_rows : forall fid, mem_id fid air_lbow_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold air_lbow_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_atan2s | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_psound | ].
    discriminate H.
  Qed.
  Lemma air_lbow_row : call_pres lp bm NoA MWF A._lava_boost_on_wall.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_airborne.prog A._lava_boost_on_wall
             A.f_lava_boost_on_wall
             air_lbow_ids nil air_lbow_xids air_ccac_sids
             LO_air air_lbow_pin air_lbow_vars air_lbow_pok).
    - exact air_lbow_ids_rows.
    - intros fid' H. discriminate H.
    - exact air_lbow_xids_rows.
    - exact air_ccac_sids_rows.
    - exact air_lbow_walk.
  Qed.

  (* ---- act_backward_rollout ---- *)
  Lemma air_bro_ids_rows : forall fid, mem_id fid air_bro_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold air_bro_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact air_uawt_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_pas | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact air_sma_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact air_pms_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact air_pmls_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hmsfv | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact air_lbow_row | ].
    discriminate H.
  Qed.
  Lemma air_bro_pres : body_pres lp NoA MWF bm A.f_act_backward_rollout.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             A.f_act_backward_rollout
             air_bro_ids nil air_pffs_xids air_sids nil
             air_bro_vars air_bro_pok).
    - exact air_bro_ids_rows.
    - intros fid' H. discriminate H.
    - exact air_pffs_xids_rows.
    - exact air_sids_rows.
    - intros fid' H. discriminate H.
    - exact air_bro_walk.
  Qed.

  (* ---- act_forward_rollout (= backward + is_anim_past_end) ---- *)
  Lemma air_fro_ids_rows : forall fid, mem_id fid air_fro_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold air_fro_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact air_uawt_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_pas | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact air_sma_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact air_pms_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact air_pmls_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hmsfv | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact air_lbow_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hipae | ].
    discriminate H.
  Qed.
  Lemma air_fro_pres : body_pres lp NoA MWF bm A.f_act_forward_rollout.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             A.f_act_forward_rollout
             air_fro_ids nil air_pffs_xids air_sids nil
             air_fro_vars air_fro_pok).
    - exact air_fro_ids_rows.
    - intros fid' H. discriminate H.
    - exact air_pffs_xids_rows.
    - exact air_sids_rows.
    - intros fid' H. discriminate H.
    - exact air_fro_walk.
  Qed.

  (* ==================================================================== *)
  (* SLICE A7: update_air_with_turn + mdho rows; butt_slide_air / hit_wall *)
  (* ==================================================================== *)

  (* update_air_with_turn: turning twin of uawt -- SAME callee rows. *)
  Lemma air_uawith_row : call_pres lp bm NoA MWF A._update_air_with_turn.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_airborne.prog A._update_air_with_turn
             A.f_update_air_with_turn
             air_uawt_ids nil air_uawt_xids nil
             LO_air air_uawith_pin air_uawith_vars air_uawith_pok).
    - exact air_uawt_ids_rows.
    - intros fid' H. discriminate H.
    - exact air_uawt_xids_rows.
    - intros fid' H. discriminate H.
    - exact air_uawith_walk.
  Qed.

  (* mario_drop_held_object -- REUSED from ObjectLeafSurface.mdho_row. *)
  Let Hmdho : call_pres lp bm NoA MWF interaction._mario_drop_held_object :=
    ObjectLeafSurface.mdho_row lp LO_mario LO_int bm NoA MWF HNoA_of_MWF
      HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
      HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
      (Hpres_obj_ext interaction._segmented_to_virtual eq_refl)
      (Hpres_obj_ext interaction._stop_shell_music eq_refl)
      (Hpres_obj_ext interaction._obj_set_held_state eq_refl).

  (* ---- act_butt_slide_air ---- *)
  Lemma air_bsa_ids_rows : forall fid, mem_id fid air_bsa_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold air_bsa_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact air_uawith_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_pas | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact air_lbow_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact air_pmls_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact air_sma_row | ].
    discriminate H.
  Qed.
  Lemma air_bsa_pres : body_pres lp NoA MWF bm A.f_act_butt_slide_air.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             A.f_act_butt_slide_air
             air_bsa_ids nil nil air_sids nil air_bsa_vars air_bsa_pok).
    - exact air_bsa_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact air_sids_rows.
    - intros fid' H. discriminate H.
    - exact air_bsa_walk.
  Qed.

  (* ---- act_air_hit_wall ---- *)
  Lemma air_ahw_ids_rows : forall fid, mem_id fid air_ahw_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold air_ahw_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hmdho | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hmsfv | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact air_sma_row | ].
    discriminate H.
  Qed.
  Lemma air_ahw_pres : body_pres lp NoA MWF bm A.f_act_air_hit_wall.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             A.f_act_air_hit_wall
             air_ahw_ids nil nil air_sids nil air_ahw_vars air_ahw_pok).
    - exact air_ahw_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact air_sids_rows.
    - intros fid' H. discriminate H.
    - exact air_ahw_walk.
  Qed.

  (* ==================================================================== *)
  (* SLICE A8: hold_butt_slide_air + the two chase-store leaves.          *)
  (* ==================================================================== *)

  (* ---- act_hold_butt_slide_air (cact=nil) ---- *)
  Lemma air_hbsa_ids_rows : forall fid, mem_id fid air_hbsa_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold air_hbsa_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact air_uawith_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact air_lbow_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hmdho | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_pas | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact air_pmls_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact air_sma_row | ].
    discriminate H.
  Qed.
  Lemma air_hbsa_pres : body_pres lp NoA MWF bm A.f_act_hold_butt_slide_air.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             A.f_act_hold_butt_slide_air
             air_hbsa_ids nil nil air_ajc_sids nil
             air_hbsa_vars air_hbsa_pok).
    - exact air_hbsa_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact air_ajc_sids_rows.
    - intros fid' H. discriminate H.
    - exact air_hbsa_walk.
  Qed.

  (* ---- act_riding_shell_air (cact write-through m->marioObj->gfx.pos[1]) ---- *)
  Lemma air_rsa_ids_rows : forall fid, mem_id fid air_rsa_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold air_rsa_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact air_lbow_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hmsfv | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_pas | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact air_pms_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact air_sma_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact air_uawt_row | ].
    discriminate H.
  Qed.
  Lemma air_rsa_pres : body_pres lp NoA MWF bm A.f_act_riding_shell_air.
  Proof.
    apply (body_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             A.f_act_riding_shell_air
             air_rsa_ids nil air_rsa_cact nil air_sids nil
             air_rsa_vars air_rsa_pok air_rsa_nonparam).
    - exact air_rsa_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact air_sids_rows.
    - intros fid' H. discriminate H.
    - exact air_rsa_walk.
  Qed.

  (* ---- act_side_flip (cact write-through m->marioObj) ---- *)
  Lemma air_sf_ids_rows : forall fid, mem_id fid air_sf_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold air_sf_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_caas | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact air_pms_row | ].
    discriminate H.
  Qed.
  Lemma air_sf_pres : body_pres lp NoA MWF bm A.f_act_side_flip.
  Proof.
    apply (body_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             A.f_act_side_flip
             air_sf_ids nil air_sf_cact air_pffs_xids air_sids nil
             air_sf_vars air_sf_pok air_sf_nonparam).
    - exact air_sf_ids_rows.
    - intros fid' H. discriminate H.
    - exact air_pffs_xids_rows.
    - exact air_sids_rows.
    - intros fid' H. discriminate H.
    - exact air_sf_walk.
  Qed.

  (* ==================================================================== *)
  (* SLICE A9: mario_bonk_reflection row + act_special_triple_jump.        *)
  (* ==================================================================== *)
  Lemma air_mbr_ids_rows : forall fid, mem_id fid air_mbr_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold air_mbr_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hmsfv | ].
    discriminate H.
  Qed.
  Lemma air_mbr_xids_rows : forall fid, mem_id fid air_mbr_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold air_mbr_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_atan2s | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_psound | ].
    discriminate H.
  Qed.
  Lemma air_mbr_row : call_pres lp bm NoA MWF mario_step._mario_bonk_reflection.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_step.prog mario_step._mario_bonk_reflection
             mario_step.f_mario_bonk_reflection
             air_mbr_ids nil air_mbr_xids nil
             LO_mario_step air_mbr_pin air_mbr_vars air_mbr_pok).
    - exact air_mbr_ids_rows.
    - intros fid' H. discriminate H.
    - exact air_mbr_xids_rows.
    - intros fid' H. discriminate H.
    - exact air_mbr_walk.
  Qed.

  (* ---- act_special_triple_jump ---- *)
  Lemma air_stj_ids_rows : forall fid, mem_id fid air_stj_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold air_stj_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact air_mbr_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_pas | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact air_pmls_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact air_pms_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact air_sma_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact air_uawt_row | ].
    discriminate H.
  Qed.
  Lemma air_stj_pres : body_pres lp NoA MWF bm A.f_act_special_triple_jump.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             A.f_act_special_triple_jump
             air_stj_ids nil air_pffs_xids air_sids nil
             air_stj_vars air_stj_pok).
    - exact air_stj_ids_rows.
    - intros fid' H. discriminate H.
    - exact air_pffs_xids_rows.
    - exact air_sids_rows.
    - intros fid' H. discriminate H.
    - exact air_stj_walk.
  Qed.

  (* ==================================================================== *)
  (* SLICE A10: act_water_jump + act_hold_water_jump.                      *)
  (* ==================================================================== *)
  Lemma air_wj_ids_rows : forall fid, mem_id fid air_wj_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold air_wj_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hmsfv | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact air_pms_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact air_sma_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_pas | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact air_lbow_row | ].
    discriminate H.
  Qed.
  Lemma air_wj_xids_rows : forall fid, mem_id fid air_wj_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold air_wj_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_scm | ].
    discriminate H.
  Qed.
  Lemma air_wj_pres : body_pres lp NoA MWF bm A.f_act_water_jump.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             A.f_act_water_jump
             air_wj_ids nil air_wj_xids air_sids nil
             air_wj_vars air_wj_pok).
    - exact air_wj_ids_rows.
    - intros fid' H. discriminate H.
    - exact air_wj_xids_rows.
    - exact air_sids_rows.
    - intros fid' H. discriminate H.
    - exact air_wj_walk.
  Qed.
  Lemma air_hwj_pres : body_pres lp NoA MWF bm A.f_act_hold_water_jump.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             A.f_act_hold_water_jump
             air_wj_ids nil air_wj_xids air_ajc_sids nil
             air_hwj_vars air_hwj_pok).
    - exact air_wj_ids_rows.
    - intros fid' H. discriminate H.
    - exact air_wj_xids_rows.
    - exact air_ajc_sids_rows.
    - intros fid' H. discriminate H.
    - exact air_hwj_walk.
  Qed.

  (* ==================================================================== *)
  (* THE REST-SPLIT: the capstone's Hpres_air_callees from the walked     *)
  (* leaves + the shrinking airborne_rest_ids residual.                   *)
  (* ==================================================================== *)
  Lemma airborne_leaf_callees_pres :
    (forall fid f, mem_id fid airborne_rest_ids = true ->
       (prog_defmap mario_actions_airborne.prog) ! fid
         = Some (Gfun (Internal f)) ->
       body_pres lp NoA MWF bm f) ->
    forall fid f, mem_id fid airborne_callee_ids = true ->
      (prog_defmap mario_actions_airborne.prog) ! fid
        = Some (Gfun (Internal f)) ->
      body_pres lp NoA MWF bm f.
  Proof.
    intros Hrest fid f H Hdm.
    unfold airborne_callee_ids in H. cbn [mem_id existsb] in H.
    (* Uniform handler over all 43 census ids.  subst fid pins the concrete
       id into Hdm; the Hrest arm is tried FIRST (cheap vm_compute of the
       membership -- succeeds for the ~33 rest ids, fails fast for walked),
       then the WALKED pin rewrites are only reached by the ~10 walked ids.
       Auto-scales: to walk a new leaf just add its pin alternative. *)
    repeat (apply orb_true_iff in H as [Hm | H];
            [ apply Pos.eqb_eq in Hm; subst fid;
              first
                [ (refine (Hrest _ f _ Hdm); vm_compute; reflexivity)
                | (rewrite air_ccac_pin in Hdm; injection Hdm as <-;
                   exact air_ccac_pres)
                | (rewrite air_pffs_pin in Hdm; injection Hdm as <-;
                   exact air_pffs_pres)
                | (rewrite air_ff_pin in Hdm; injection Hdm as <-;
                   exact air_ff_pres)
                | (rewrite air_hff_pin in Hdm; injection Hdm as <-;
                   exact air_hff_pres)
                | (rewrite air_wka_pin in Hdm; injection Hdm as <-;
                   exact air_wka_pres)
                | (rewrite air_tpj_pin in Hdm; injection Hdm as <-;
                   exact air_tpj_pres)
                | (rewrite air_hj_pin in Hdm; injection Hdm as <-;
                   exact air_hj_pres)
                | (rewrite air_lj_pin in Hdm; injection Hdm as <-;
                   exact air_lj_pres)
                | (rewrite air_tj_pin in Hdm; injection Hdm as <-;
                   exact air_tj_pres)
                | (rewrite air_bf_pin in Hdm; injection Hdm as <-;
                   exact air_bf_pres)
                | (rewrite air_hbkb_pin in Hdm; injection Hdm as <-;
                   exact air_hbkb_pres)
                | (rewrite air_hfkb_pin in Hdm; injection Hdm as <-;
                   exact air_hfkb_pres)
                | (rewrite air_bkb_pin in Hdm; injection Hdm as <-;
                   exact air_bkb_pres)
                | (rewrite air_fkb_pin in Hdm; injection Hdm as <-;
                   exact air_fkb_pres)
                | (rewrite air_sb_pin in Hdm; injection Hdm as <-;
                   exact air_sb_pres)
                | (rewrite air_bro_pin in Hdm; injection Hdm as <-;
                   exact air_bro_pres)
                | (rewrite air_fro_pin in Hdm; injection Hdm as <-;
                   exact air_fro_pres)
                | (rewrite air_bsa_pin in Hdm; injection Hdm as <-;
                   exact air_bsa_pres)
                | (rewrite air_ahw_pin in Hdm; injection Hdm as <-;
                   exact air_ahw_pres)
                | (rewrite air_hbsa_pin in Hdm; injection Hdm as <-;
                   exact air_hbsa_pres)
                | (rewrite air_rsa_pin in Hdm; injection Hdm as <-;
                   exact air_rsa_pres)
                | (rewrite air_sf_pin in Hdm; injection Hdm as <-;
                   exact air_sf_pres)
                | (rewrite air_stj_pin in Hdm; injection Hdm as <-;
                   exact air_stj_pres)
                | (rewrite air_wj_pin in Hdm; injection Hdm as <-;
                   exact air_wj_pres)
                | (rewrite air_hwj_pin in Hdm; injection Hdm as <-;
                   exact air_hwj_pres) ] | ]).
    discriminate H.
  Qed.

End AirborneLeafRows.
