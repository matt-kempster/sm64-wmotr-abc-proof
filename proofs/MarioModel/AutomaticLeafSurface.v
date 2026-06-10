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
From SM64.Generated Require mario mario_step mario_actions_automatic
  mario_actions_object.
From SM64.Proofs Require Import SymbolicLinking Flying Taint
  ActionValueFrame RealFrameValue RealFrameLinked AGates.
From SM64.Proofs Require Import CensusV2 EngineV2Consumer RestSurface
  AirborneSurface DispatchKit FloorsSurface AutomaticSurface.
From SM64.Proofs Require Import ActWriterSurface ObjectLeafSurface.
From SM64.Proofs Require Import LocalVarsSurface OutParamSurface.
From SM64.Proofs Require Import RealFrameValue.

Import ListNotations.

(* the leaves NOT yet walked: every slice moves ids out of here.
   act_tornado_twirling is now WALKED (the hybrid twl walker below);
   the LAST holdout is act_in_cannon (the engine-v2 cannon-fire kill). *)
Definition automatic_rest_ids : list ident :=
  mario_actions_automatic._act_in_cannon :: nil.

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
(* act_grabbed: action arg to set_mario_action is the TEMP _t'1, set from
   ACT_THROWN_FORWARD/BACKWARD (untainted const) -> the wact mechanism.
   Deep chase cact = the four marioObj/usedObj loads. *)
Definition grabbed_wact : list ident := mario_actions_automatic._t'1 :: nil.
Definition grabbed_ids : list ident := mario._set_mario_animation :: nil.
Definition grabbed_cact : list ident :=
  mario_actions_automatic._t'3 :: mario_actions_automatic._t'9
    :: mario_actions_automatic._t'7 :: mario_actions_automatic._t'6 :: nil.
Definition grabbed_xids : list ident := mario._vec3f_copy :: nil.

(* B10 pole-cluster helpers (shared by act_holding_pole + act_climbing_pole):
   - is_anim_past_frame: a PURE anim reader (0 callees, 0 stores) -> all-nil walk.
   - play_climbing_sounds: NO stores; calls is_anim_past_frame(m,..) (ids) plus
     the audio externals play_sound + segmented_to_virtual (xids). *)
Definition pcs_ids : list ident := mario._is_anim_past_frame :: nil.
Definition pcs_xids : list ident :=
  mario._play_sound :: interaction._segmented_to_virtual :: nil.

(* act_holding_pole: window stores (forwardVel/faceAngle[1]/particleFlags via m)
   + 4 marioObj chase stores into rawData.asS32[33]/asF32[34] (const 0/4096 and
   Osub-of-numerics RHS -- the gated arithmetic chase arm).  cact=[_marioObj].
   ids = play_climbing_sounds/set_pole_position/set_mario_animation/
   add_tree_leaf_particles; sids reuses hang_sids=[set_mario_action];
   xids = set_sound_moving_speed/segmented_to_virtual/virtual_to_segmented. *)
Definition ahp_ids : list ident :=
  mario_actions_automatic._play_climbing_sounds
    :: mario_actions_automatic._set_pole_position
    :: mario._set_mario_animation
    :: mario_actions_automatic._add_tree_leaf_particles :: nil.
Definition ahp_xids : list ident :=
  mario._set_sound_moving_speed
    :: interaction._segmented_to_virtual
    :: interaction._virtual_to_segmented :: nil.
Definition ahp_cact : list ident :=
  mario_actions_automatic._marioObj :: nil.

(* B12 act_climbing_pole (the LAST pole leaf): window stores (forwardVel,
   faceAngle[1] x2) + 2 marioObj chase stores (asF32[34] float Oadd,
   asS32[33] const 0); the blocker was set_mario_anim_with_accel's third
   arg _sp24 -- a stick-derived raw scalar with no act_inv story.  The
   np3 channel carries exactly what the MWF chase row needs: _sp24 is
   non-Vptr (float-to-int cast = cast_case_s2i, never the ptr32
   passthrough), threaded from the call site into smawa's animAccel
   store.  ids = atlp/pcs/spp; xids = approach_s32; sids = hang_sids. *)
Definition acp_ids : list ident :=
  mario_actions_automatic._add_tree_leaf_particles
    :: mario_actions_automatic._play_climbing_sounds
    :: mario_actions_automatic._set_pole_position :: nil.
Definition acp_xids : list ident :=
  mario_actions_automatic._approach_s32 :: nil.
Definition acp_cact : list ident :=
  mario_actions_automatic._marioObj :: nil.
Definition acp_nids : list ident :=
  mario_actions_automatic._sp24 :: nil.
Definition acp_np3_ids : list ident :=
  mario._set_mario_anim_with_accel :: nil.
(* set_mario_anim_with_accel (mario.prog): set_mario_animation's accel
   twin -- same deep-chase cact shape, same sole ext callee (sma_xids =
   [load_patchable_table], REUSED), plus the one nids-gated store
   o->animInfo.animAccel = accel. *)
Definition smawa_cact : list ident :=
  mario._o :: mario._targetAnim :: mario._t'14 :: mario._t'13
    :: mario._t'12 :: mario._t'11 :: nil.

(* B11 act_top_of_pole: marioObj load (no chase stores) + ONE window store
   (faceAngle[1]); callees set_mario_action(sids)/set_mario_animation(Hsma)/
   return_mario_anim_y_translation(Hrmayt)/set_pole_position(Hcp_spp). *)
Definition atop_ids : list ident :=
  mario._set_mario_animation
    :: mario._return_mario_anim_y_translation
    :: mario_actions_automatic._set_pole_position :: nil.
Definition atop_cact : list ident :=
  mario_actions_automatic._marioObj :: nil.
(* B11 act_top_of_pole_transition: ONE chase store (asS32[33]=const 0); callees
   add is_anim_at_end(Hiaae). *)
Definition atopt_ids : list ident :=
  mario._set_mario_animation
    :: mario._is_anim_at_end
    :: mario._return_mario_anim_y_translation
    :: mario_actions_automatic._set_pole_position :: nil.
Definition atopt_cact : list ident :=
  mario_actions_automatic._marioObj :: nil.

(* B11 act_hang_moving: ONE window store (m->actionArg = Oxor(t,1) -- actionArg
   is at offset 28, OUTSIDE the protected action cell [12,16), so a value-blind
   window store); two marioObj LOADS (read-only, into non-cact temps -> no chase
   store, cact = nil); callees set_mario_action x4 (const action 2nd arg, sids)/
   set_mario_animation x2 (Hsma)/play_sound (ext, Hcpx_psound)/is_anim_past_end
   (Hiape, pure reader)/update_hang_moving (Huhm -- the SOLE hard residual, a
   single-param hang-physics helper, true-in-model under marg).  Decompose, not
   collapse: the whole leaf body reduces to Huhm.  automatic_rest_ids 4 -> 3. *)
Definition ahm_ids : list ident :=
  mario._set_mario_animation
    :: mario._is_anim_past_end
    :: mario_actions_automatic._update_hang_moving :: nil.
Definition ahm_xids : list ident := mario._play_sound :: nil.

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

(* act_grabbed pins/shapes/walk (wact mechanism) *)
Example grabbed_pin :
  (prog_defmap mario_actions_automatic.prog) ! mario_actions_automatic._act_grabbed
  = Some (Gfun (Internal mario_actions_automatic.f_act_grabbed)).
Proof. vm_compute. reflexivity. Qed.
Example grabbed_vars : fn_vars mario_actions_automatic.f_act_grabbed = nil.
Proof. reflexivity. Qed.
Example grabbed_params_ok : aut_pok mario_actions_automatic.f_act_grabbed = true.
Proof. vm_compute. reflexivity. Qed.
Example grabbed_nonparam_c :
  forallb (fun t' => negb (mem_id t'
    (map fst (fn_params mario_actions_automatic.f_act_grabbed)))) grabbed_cact = true.
Proof. vm_compute. reflexivity. Qed.
Example grabbed_nonparam_w :
  forallb (fun t' => negb (mem_id t'
    (map fst (fn_params mario_actions_automatic.f_act_grabbed)))) grabbed_wact = true.
Proof. vm_compute. reflexivity. Qed.
Example grabbed_walk :
  wwalk_chk false grabbed_wact grabbed_ids nil grabbed_cact grabbed_xids hang_sids nil
    (fn_body mario_actions_automatic.f_act_grabbed) = true.
Proof. vm_compute. reflexivity. Qed.

(* ====================================================================== *)
(* THE LEDGE CLUSTER (B9 slice 4): act_ledge_grab WALKED -- the FIRST      *)
(* consumer of the local-vars arc (ActWriterSurface.call_pres_of_lwalk).   *)
(* Two Tier-1 helpers with stack locals (let_go_of_ledge,                  *)
(* find_floor_height_relative_polar -- both fn_vars=[_floor], whose only    *)
(* local-touching call is the external find_floor out-param), one wwalk     *)
(* helper (stop_and_set_height_to_floor in mario_step), bottoming out in    *)
(* the keystone (set_mario_action) + already-proven rows (sma / psinf /     *)
(* msfv + the v3f/v3s ext rows).  act_ledge_grab itself writes only bm      *)
(* windows (actionTimer / hurtCounter) and calls set_mario_action with      *)
(* untainted CONSTANTS (1359 / 1356).  Census 13 -> 12.                     *)
(* ====================================================================== *)

(* ---- censuses ---- *)
(* OUT-PARAM ARC (find_floor): the local _floor and the out-param-writer
   find_floor.  Replaces the phantom-false `call_pres_ext find_floor` (xids)
   with the faithful gated `call_pres_ext_oc find_floor` (oc_pids), the
   out-param &_floor being a stack local (lids). *)
Definition lgl_lids : list ident := mario_actions_automatic._floor :: nil.
Definition lgl_oc_pids : list ident := mario._find_floor :: nil.
Definition lgl_sids : list ident := mario._set_mario_action :: nil.
Definition ffhrp_lids : list ident := mario._floor :: nil.
Definition ffhrp_oc_pids : list ident := mario._find_floor :: nil.
Definition sasthf_ids : list ident := mario._mario_set_forward_vel :: nil.
Definition sasthf_xids : list ident :=
  mario_step._vec3f_copy :: mario._vec3s_set :: nil.
Definition alg_ids : list ident :=
  mario_actions_automatic._let_go_of_ledge
    :: mario._find_floor_height_relative_polar
    :: mario_step._stop_and_set_height_to_floor
    :: mario._set_mario_animation
    :: mario._play_sound_if_no_flag :: nil.
Definition alg_sids : list ident := mario._set_mario_action :: nil.

(* ---- pins ---- *)
Example lgl_pin :
  (prog_defmap mario_actions_automatic.prog)
    ! mario_actions_automatic._let_go_of_ledge
  = Some (Gfun (Internal mario_actions_automatic.f_let_go_of_ledge)).
Proof. vm_compute. reflexivity. Qed.
Example ffhrp_pin :
  (prog_defmap mario.prog) ! mario._find_floor_height_relative_polar
  = Some (Gfun (Internal mario.f_find_floor_height_relative_polar)).
Proof. vm_compute. reflexivity. Qed.
Example sasthf_pin :
  (prog_defmap mario_step.prog) ! mario_step._stop_and_set_height_to_floor
  = Some (Gfun (Internal mario_step.f_stop_and_set_height_to_floor)).
Proof. vm_compute. reflexivity. Qed.
Example alg_pin :
  (prog_defmap mario_actions_automatic.prog)
    ! mario_actions_automatic._act_ledge_grab
  = Some (Gfun (Internal mario_actions_automatic.f_act_ledge_grab)).
Proof. vm_compute. reflexivity. Qed.

(* ---- shapes ---- *)
Example sasthf_vars : fn_vars mario_step.f_stop_and_set_height_to_floor = nil.
Proof. reflexivity. Qed.
Example alg_vars : fn_vars mario_actions_automatic.f_act_ledge_grab = nil.
Proof. reflexivity. Qed.
Example lgl_params_ok :
  aut_pok mario_actions_automatic.f_let_go_of_ledge = true.
Proof. vm_compute. reflexivity. Qed.
Example ffhrp_params_ok :
  aut_pok mario.f_find_floor_height_relative_polar = true.
Proof. vm_compute. reflexivity. Qed.
Example sasthf_params_ok :
  aut_pok mario_step.f_stop_and_set_height_to_floor = true.
Proof. vm_compute. reflexivity. Qed.
Example alg_params_ok :
  aut_pok mario_actions_automatic.f_act_ledge_grab = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- walks ---- *)
Example lgl_walk :
  wwalk_chk' lgl_lids lgl_oc_pids nil nil nil nil false nil nil nil nil nil lgl_sids nil
    (fn_body mario_actions_automatic.f_let_go_of_ledge) = true.
Proof. vm_compute. reflexivity. Qed.
Example ffhrp_walk :
  wwalk_chk' ffhrp_lids ffhrp_oc_pids nil nil nil nil false nil nil nil nil nil nil nil
    (fn_body mario.f_find_floor_height_relative_polar) = true.
Proof. vm_compute. reflexivity. Qed.
Example sasthf_walk :
  wwalk_chk false nil sasthf_ids nil nil sasthf_xids nil nil
    (fn_body mario_step.f_stop_and_set_height_to_floor) = true.
Proof. vm_compute. reflexivity. Qed.
Example alg_walk :
  wwalk_chk false nil alg_ids nil nil nil alg_sids nil
    (fn_body mario_actions_automatic.f_act_ledge_grab) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- set_pole_position census: the 730-line SHARED pole helper, now fully
   recognized once the oc arm accepts vec3f_find_ceil's 3-arg out-param shape
   (the localizer pinned that as the single gap).  Feeds Hspp below. ---- *)
Definition spp_lids : list ident :=
  mario_actions_automatic._floor :: mario_actions_automatic._ceil :: nil.
Definition spp_oc_pids : list ident :=
  mario_actions_automatic._find_floor
  :: mario_actions_automatic._vec3f_find_ceil :: nil.
Definition spp_wc_pids : list ident :=
  mario_actions_automatic._f32_find_wall_collision :: nil.
Definition spp_sc_pids : list ident :=
  mario_actions_automatic._vec3f_copy
  :: mario_actions_automatic._vec3s_set :: nil.
Definition spp_sids : list ident :=
  mario_actions_automatic._set_mario_action :: nil.
Definition spp_cact : list ident :=
  mario_actions_automatic._marioObj
  :: mario_actions_automatic._t'37 :: mario_actions_automatic._t'34
  :: mario_actions_automatic._t'32 :: mario_actions_automatic._t'29
  :: mario_actions_automatic._t'26 :: mario_actions_automatic._t'19
  :: mario_actions_automatic._t'17 :: mario_actions_automatic._t'14
  :: mario_actions_automatic._t'11 :: mario_actions_automatic._t'9
  :: mario_actions_automatic._t'6  :: mario_actions_automatic._t'5 :: nil.
Example spp_walk :
  wwalk_chk' spp_lids spp_oc_pids spp_wc_pids spp_sc_pids nil nil false
    nil nil nil spp_cact nil spp_sids nil
    (fn_body mario_actions_automatic.f_set_pole_position) = true.
Proof. vm_compute. reflexivity. Qed.
Example spp_pin :
  (prog_defmap mario_actions_automatic.prog)
    ! mario_actions_automatic._set_pole_position
  = Some (Gfun (Internal mario_actions_automatic.f_set_pole_position)).
Proof. vm_compute. reflexivity. Qed.
Example spp_params_ok :
  aut_pok mario_actions_automatic.f_set_pole_position = true.
Proof. vm_compute. reflexivity. Qed.
(* the chase-temp census is param-disjoint (every cact temp is a non-param,
   so Vundef at entry -> chase_inv holds vacuously). *)
Example spp_npc :
  forallb (fun t' => negb (mem_id t'
             (map fst (fn_params mario_actions_automatic.f_set_pole_position))))
    spp_cact = true.
Proof. vm_compute. reflexivity. Qed.

(* ====================================================================== *)
(* B10: POLE-CLUSTER SCAFFOLD -- act_grab_pole_slow WALKED (rest-split).    *)
(* fn_vars=nil, ZERO stores: 6 calls -- play_sound_if_no_flag /             *)
(* set_pole_position / set_mario_animation / is_anim_at_end /               *)
(* set_mario_action(untainted const) / add_tree_leaf_particles.            *)
(* set_pole_position (the 730-line SHARED pole helper: out-param            *)
(* find_floor/vec3f_find_ceil + _filler local + chase stores) is NAMED as   *)
(* the residual Hcp_spp (twin of Hcp_pgs).  add_tree_leaf_particles is      *)
(* walked here (its sole ext callee is segmented_to_virtual).  Census       *)
(* 9 -> 8; the Hcp_spp / Hcpx_stv / Hatlp scaffold is reused by the other   *)
(* five pole leaves later.                                                  *)
(* ====================================================================== *)

(* ---- censuses ---- *)
Definition atlp_xids : list ident := interaction._segmented_to_virtual :: nil.
Definition agps_ids : list ident :=
  mario._play_sound_if_no_flag
    :: mario_actions_automatic._set_pole_position
    :: mario._set_mario_animation
    :: mario._is_anim_at_end
    :: mario_actions_automatic._add_tree_leaf_particles :: nil.
Definition agps_sids : list ident := mario._set_mario_action :: nil.

(* ---- pins ---- *)
Example atlp_pin :
  (prog_defmap mario_actions_automatic.prog)
    ! mario_actions_automatic._add_tree_leaf_particles
  = Some (Gfun (Internal mario_actions_automatic.f_add_tree_leaf_particles)).
Proof. vm_compute. reflexivity. Qed.
Example agps_pin :
  (prog_defmap mario_actions_automatic.prog)
    ! mario_actions_automatic._act_grab_pole_slow
  = Some (Gfun (Internal mario_actions_automatic.f_act_grab_pole_slow)).
Proof. vm_compute. reflexivity. Qed.

(* ---- shapes ---- *)
Example atlp_vars :
  fn_vars mario_actions_automatic.f_add_tree_leaf_particles = nil.
Proof. reflexivity. Qed.
Example agps_vars :
  fn_vars mario_actions_automatic.f_act_grab_pole_slow = nil.
Proof. reflexivity. Qed.
Example atlp_params_ok :
  aut_pok mario_actions_automatic.f_add_tree_leaf_particles = true.
Proof. vm_compute. reflexivity. Qed.
Example agps_params_ok :
  aut_pok mario_actions_automatic.f_act_grab_pole_slow = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- walks ---- *)
Example atlp_walk :
  wwalk_chk false nil nil nil nil atlp_xids nil nil
    (fn_body mario_actions_automatic.f_add_tree_leaf_particles) = true.
Proof. vm_compute. reflexivity. Qed.
Example agps_walk :
  wwalk_chk false nil agps_ids nil nil nil agps_sids nil
    (fn_body mario_actions_automatic.f_act_grab_pole_slow) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- act_grab_pole_fast: SAME callee census as agps (set_pole_position,
   set_mario_animation, is_anim_at_end, play_sound_if_no_flag,
   add_tree_leaf_particles, set_mario_action), but the body chases
   m->marioObj into a local _marioObj temp and stores a COMPUTED integer
   `(_t'4 * 8) / 10` into marioObj->rawData.asS32[33].  That arithmetic RHS
   (Ebinop Omul/Odiv) rides the chase-store arm's new pointer-stuck-binop
   recognizer (wchase_rhs_ok).  cact = [_marioObj]. *)
Definition agpf_cact : list ident :=
  mario_actions_automatic._marioObj :: nil.
Example agpf_pin :
  (prog_defmap mario_actions_automatic.prog)
    ! mario_actions_automatic._act_grab_pole_fast
  = Some (Gfun (Internal mario_actions_automatic.f_act_grab_pole_fast)).
Proof. vm_compute. reflexivity. Qed.
Example agpf_vars :
  fn_vars mario_actions_automatic.f_act_grab_pole_fast = nil.
Proof. reflexivity. Qed.
Example agpf_params_ok :
  aut_pok mario_actions_automatic.f_act_grab_pole_fast = true.
Proof. vm_compute. reflexivity. Qed.
Example agpf_nonparam_c :
  forallb (fun t' => negb (mem_id t'
    (map fst (fn_params mario_actions_automatic.f_act_grab_pole_fast))))
    agpf_cact = true.
Proof. vm_compute. reflexivity. Qed.
Example agpf_walk :
  wwalk_chk false nil agps_ids nil agpf_cact nil agps_sids nil
    (fn_body mario_actions_automatic.f_act_grab_pole_fast) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- is_anim_past_frame: pure anim reader, all-nil census ---- *)
Example iapf_pin :
  (prog_defmap mario.prog) ! mario._is_anim_past_frame
  = Some (Gfun (Internal mario.f_is_anim_past_frame)).
Proof. vm_compute. reflexivity. Qed.
Example iapf_vars : fn_vars mario.f_is_anim_past_frame = nil.
Proof. reflexivity. Qed.
Example iapf_params_ok : aut_pok mario.f_is_anim_past_frame = true.
Proof. vm_compute. reflexivity. Qed.
Example iapf_walk :
  wwalk_chk false nil nil nil nil nil nil nil
    (fn_body mario.f_is_anim_past_frame) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- is_anim_past_end: pure anim reader (sibling of is_anim_past_frame),
   all-nil census ---- *)
Example iape_pin :
  (prog_defmap mario.prog) ! mario._is_anim_past_end
  = Some (Gfun (Internal mario.f_is_anim_past_end)).
Proof. vm_compute. reflexivity. Qed.
Example iape_vars : fn_vars mario.f_is_anim_past_end = nil.
Proof. reflexivity. Qed.
Example iape_params_ok : aut_pok mario.f_is_anim_past_end = true.
Proof. vm_compute. reflexivity. Qed.
Example iape_walk :
  wwalk_chk false nil nil nil nil nil nil nil
    (fn_body mario.f_is_anim_past_end) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- play_climbing_sounds: ids=[is_anim_past_frame], xids=[play_sound,
   segmented_to_virtual], no stores ---- *)
Example pcs_pin :
  (prog_defmap mario_actions_automatic.prog)
    ! mario_actions_automatic._play_climbing_sounds
  = Some (Gfun (Internal mario_actions_automatic.f_play_climbing_sounds)).
Proof. vm_compute. reflexivity. Qed.
Example pcs_vars :
  fn_vars mario_actions_automatic.f_play_climbing_sounds = nil.
Proof. reflexivity. Qed.
Example pcs_params_ok :
  aut_pok mario_actions_automatic.f_play_climbing_sounds = true.
Proof. vm_compute. reflexivity. Qed.
Example pcs_walk :
  wwalk_chk false nil pcs_ids nil nil pcs_xids nil nil
    (fn_body mario_actions_automatic.f_play_climbing_sounds) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- act_holding_pole ---- *)
Example ahp_pin :
  (prog_defmap mario_actions_automatic.prog)
    ! mario_actions_automatic._act_holding_pole
  = Some (Gfun (Internal mario_actions_automatic.f_act_holding_pole)).
Proof. vm_compute. reflexivity. Qed.
Example ahp_vars :
  fn_vars mario_actions_automatic.f_act_holding_pole = nil.
Proof. reflexivity. Qed.
Example ahp_params_ok :
  aut_pok mario_actions_automatic.f_act_holding_pole = true.
Proof. vm_compute. reflexivity. Qed.
Example ahp_nonparam_c :
  forallb (fun t' => negb (mem_id t'
    (map fst (fn_params mario_actions_automatic.f_act_holding_pole))))
    ahp_cact = true.
Proof. vm_compute. reflexivity. Qed.
Example ahp_walk :
  wwalk_chk false nil ahp_ids nil ahp_cact ahp_xids hang_sids nil
    (fn_body mario_actions_automatic.f_act_holding_pole) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- B12 set_mario_anim_with_accel (mario.prog, the np3 body) ---- *)
Example smawa_pin :
  (prog_defmap mario.prog) ! mario._set_mario_anim_with_accel
  = Some (Gfun (Internal mario.f_set_mario_anim_with_accel)).
Proof. vm_compute. reflexivity. Qed.
Example smawa_vars : fn_vars mario.f_set_mario_anim_with_accel = nil.
Proof. reflexivity. Qed.
Example smawa_params :
  fn_params mario.f_set_mario_anim_with_accel = np3_params.
Proof. vm_compute. reflexivity. Qed.
Example smawa_cact_m :
  mem_id mario_actions_airborne._m smawa_cact = false.
Proof. vm_compute. reflexivity. Qed.
Example smawa_cact_anim : mem_id mario._targetAnimID smawa_cact = false.
Proof. vm_compute. reflexivity. Qed.
Example smawa_cact_acc : mem_id mario._accel smawa_cact = false.
Proof. vm_compute. reflexivity. Qed.
Example smawa_walk :
  wwalk_chk' nil nil nil nil (mario._accel :: nil) nil false
    nil nil nil smawa_cact sma_xids nil nil
    (fn_body mario.f_set_mario_anim_with_accel) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- B12 act_climbing_pole ---- *)
Example acp_pin :
  (prog_defmap mario_actions_automatic.prog)
    ! mario_actions_automatic._act_climbing_pole
  = Some (Gfun (Internal mario_actions_automatic.f_act_climbing_pole)).
Proof. vm_compute. reflexivity. Qed.
Example acp_vars :
  fn_vars mario_actions_automatic.f_act_climbing_pole = nil.
Proof. reflexivity. Qed.
Example acp_params_ok :
  aut_pok mario_actions_automatic.f_act_climbing_pole = true.
Proof. vm_compute. reflexivity. Qed.
Example acp_nonparam_c :
  forallb (fun t' => negb (mem_id t'
    (map fst (fn_params mario_actions_automatic.f_act_climbing_pole))))
    acp_cact = true.
Proof. vm_compute. reflexivity. Qed.
Example acp_nonparam_n :
  forallb (fun t' => negb (mem_id t'
    (map fst (fn_params mario_actions_automatic.f_act_climbing_pole))))
    acp_nids = true.
Proof. vm_compute. reflexivity. Qed.
Example acp_walk :
  wwalk_chk' nil nil nil nil acp_nids acp_np3_ids false
    nil acp_ids nil acp_cact acp_xids hang_sids nil
    (fn_body mario_actions_automatic.f_act_climbing_pole) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- B11 act_top_of_pole ---- *)
Example atop_pin :
  (prog_defmap mario_actions_automatic.prog)
    ! mario_actions_automatic._act_top_of_pole
  = Some (Gfun (Internal mario_actions_automatic.f_act_top_of_pole)).
Proof. vm_compute. reflexivity. Qed.
Example atop_vars :
  fn_vars mario_actions_automatic.f_act_top_of_pole = nil.
Proof. reflexivity. Qed.
Example atop_params_ok :
  aut_pok mario_actions_automatic.f_act_top_of_pole = true.
Proof. vm_compute. reflexivity. Qed.
Example atop_nonparam_c :
  forallb (fun t' => negb (mem_id t'
    (map fst (fn_params mario_actions_automatic.f_act_top_of_pole))))
    atop_cact = true.
Proof. vm_compute. reflexivity. Qed.
Example atop_walk :
  wwalk_chk false nil atop_ids nil atop_cact nil hang_sids nil
    (fn_body mario_actions_automatic.f_act_top_of_pole) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- B11 act_top_of_pole_transition ---- *)
Example atopt_pin :
  (prog_defmap mario_actions_automatic.prog)
    ! mario_actions_automatic._act_top_of_pole_transition
  = Some (Gfun (Internal mario_actions_automatic.f_act_top_of_pole_transition)).
Proof. vm_compute. reflexivity. Qed.
Example atopt_vars :
  fn_vars mario_actions_automatic.f_act_top_of_pole_transition = nil.
Proof. reflexivity. Qed.
Example atopt_params_ok :
  aut_pok mario_actions_automatic.f_act_top_of_pole_transition = true.
Proof. vm_compute. reflexivity. Qed.
Example atopt_nonparam_c :
  forallb (fun t' => negb (mem_id t'
    (map fst (fn_params mario_actions_automatic.f_act_top_of_pole_transition))))
    atopt_cact = true.
Proof. vm_compute. reflexivity. Qed.
Example atopt_walk :
  wwalk_chk false nil atopt_ids nil atopt_cact nil hang_sids nil
    (fn_body mario_actions_automatic.f_act_top_of_pole_transition) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- B11 act_hang_moving (cact = nil: marioObj loads are read-only) ---- *)
Example ahm_pin :
  (prog_defmap mario_actions_automatic.prog)
    ! mario_actions_automatic._act_hang_moving
  = Some (Gfun (Internal mario_actions_automatic.f_act_hang_moving)).
Proof. vm_compute. reflexivity. Qed.
Example ahm_vars :
  fn_vars mario_actions_automatic.f_act_hang_moving = nil.
Proof. reflexivity. Qed.
Example ahm_params_ok :
  aut_pok mario_actions_automatic.f_act_hang_moving = true.
Proof. vm_compute. reflexivity. Qed.
Example ahm_walk :
  wwalk_chk false nil ahm_ids nil nil ahm_xids hang_sids nil
    (fn_body mario_actions_automatic.f_act_hang_moving) = true.
Proof. vm_compute. reflexivity. Qed.

(* ====================================================================== *)
(* THE LEDGE-CLIMB CLUSTER (B9 slice 5): act_ledge_climb_down WALKED via    *)
(* the EXISTING act3 path -- update_ledge_climb's action is in 3rd-param     *)
(* position (set_mario_action(m,_animation?,_endAction... no: m,_endAction,  *)
(* 0)), matching call_pres_act3 exactly (the asgs_row pattern).  No engine   *)
(* change: the caller's tids/act3_call_chk machinery checks the untainted    *)
(* constant action at each climb call site.  climb_up_ledge + the ledge      *)
(* cluster's stop_and_set_height_to_floor are reused.  Census 12 -> 11.      *)
(* ====================================================================== *)

(* ---- censuses ---- *)
Definition cul_ids : list ident := mario._set_mario_animation :: nil.
Definition cul_xids : list ident := mario_step._vec3f_copy :: nil.
Definition ulc_wact : list ident := mario_actions_object._endAction :: nil.
Definition ulc_ids : list ident :=
  mario_step._stop_and_set_height_to_floor
    :: mario._set_mario_animation
    :: mario._is_anim_at_end
    :: mario_actions_automatic._climb_up_ledge :: nil.
Definition ulc_sids : list ident := mario._set_mario_action :: nil.
Definition alcd_ids : list ident :=
  mario_actions_automatic._let_go_of_ledge
    :: mario._play_sound_if_no_flag :: nil.
Definition alcd_tids : list ident :=
  mario_actions_automatic._update_ledge_climb :: nil.

(* ---- pins ---- *)
Example cul_pin :
  (prog_defmap mario_actions_automatic.prog)
    ! mario_actions_automatic._climb_up_ledge
  = Some (Gfun (Internal mario_actions_automatic.f_climb_up_ledge)).
Proof. vm_compute. reflexivity. Qed.
Example ulc_pin :
  (prog_defmap mario_actions_automatic.prog)
    ! mario_actions_automatic._update_ledge_climb
  = Some (Gfun (Internal mario_actions_automatic.f_update_ledge_climb)).
Proof. vm_compute. reflexivity. Qed.
Example alcd_pin :
  (prog_defmap mario_actions_automatic.prog)
    ! mario_actions_automatic._act_ledge_climb_down
  = Some (Gfun (Internal mario_actions_automatic.f_act_ledge_climb_down)).
Proof. vm_compute. reflexivity. Qed.

(* ---- shapes ---- *)
Example cul_vars : fn_vars mario_actions_automatic.f_climb_up_ledge = nil.
Proof. reflexivity. Qed.
Example ulc_vars : fn_vars mario_actions_automatic.f_update_ledge_climb = nil.
Proof. reflexivity. Qed.
Example alcd_vars :
  fn_vars mario_actions_automatic.f_act_ledge_climb_down = nil.
Proof. reflexivity. Qed.
Example cul_params_ok :
  aut_pok mario_actions_automatic.f_climb_up_ledge = true.
Proof. vm_compute. reflexivity. Qed.
Example ulc_params :
  fn_params mario_actions_automatic.f_update_ledge_climb = act3_params.
Proof. vm_compute. reflexivity. Qed.
Example alcd_params_ok :
  aut_pok mario_actions_automatic.f_act_ledge_climb_down = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- walks ---- *)
Example cul_walk :
  wwalk_chk false nil cul_ids nil nil cul_xids nil nil
    (fn_body mario_actions_automatic.f_climb_up_ledge) = true.
Proof. vm_compute. reflexivity. Qed.
Example ulc_walk :
  wwalk_chk false ulc_wact ulc_ids nil nil nil ulc_sids nil
    (fn_body mario_actions_automatic.f_update_ledge_climb) = true.
Proof. vm_compute. reflexivity. Qed.
Example alcd_walk :
  wwalk_chk false nil alcd_ids nil nil nil nil alcd_tids
    (fn_body mario_actions_automatic.f_act_ledge_climb_down) = true.
Proof. vm_compute. reflexivity. Qed.

(* ====================================================================== *)
(* THE LEDGE-CLIMB FAST cluster (B9 slice 6): act_ledge_climb_fast WALKED. *)
(* Reuses the act3 helper update_ledge_climb (Hulc), let_go_of_ledge       *)
(* (Hlgl) and play_sound_if_no_flag (Hpsinf).  NEW helper rows here:        *)
(*   update_ledge_climb_camera (CHASE-STORE leaf: writes through            *)
(*     m->statusForCamera = an indexed camera-pos store, cact chain handled *)
(*     by chase_store_chk + window stores to actionTimer/flags); +          *)
(*   play_mario_landing_sound -> play_sound_and_spawn_particles -> the      *)
(*     audio external play_sound.                                           *)
(* act_ledge_climb_fast itself reads m->marioObj (cact=[_t'2]) to gate the  *)
(* landing-sound call.  No direct action store -> NO engine change.         *)
(* Census 11 -> 10.                                                         *)
(* ====================================================================== *)

(* ---- censuses ---- *)
Definition ulcc_cact : list ident :=
  mario_actions_automatic._t'9 :: mario_actions_automatic._t'5
    :: mario_actions_automatic._t'3 :: nil.
Definition psasp_xids : list ident := mario._play_sound :: nil.
Definition pmls_ids : list ident :=
  mario._play_sound_and_spawn_particles :: nil.
Definition alcf_ids : list ident :=
  mario_actions_automatic._let_go_of_ledge
    :: mario._play_sound_if_no_flag
    :: mario._play_mario_landing_sound
    :: mario_actions_automatic._update_ledge_climb_camera :: nil.
Definition alcf_cact : list ident := mario_actions_automatic._t'2 :: nil.
Definition alcf_tids : list ident :=
  mario_actions_automatic._update_ledge_climb :: nil.

(* ---- pins ---- *)
Example ulcc_pin :
  (prog_defmap mario_actions_automatic.prog)
    ! mario_actions_automatic._update_ledge_climb_camera
  = Some (Gfun (Internal mario_actions_automatic.f_update_ledge_climb_camera)).
Proof. vm_compute. reflexivity. Qed.
Example psasp_pin :
  (prog_defmap mario.prog) ! mario._play_sound_and_spawn_particles
  = Some (Gfun (Internal mario.f_play_sound_and_spawn_particles)).
Proof. vm_compute. reflexivity. Qed.
Example pmls_pin :
  (prog_defmap mario.prog) ! mario._play_mario_landing_sound
  = Some (Gfun (Internal mario.f_play_mario_landing_sound)).
Proof. vm_compute. reflexivity. Qed.
Example alcf_pin :
  (prog_defmap mario_actions_automatic.prog)
    ! mario_actions_automatic._act_ledge_climb_fast
  = Some (Gfun (Internal mario_actions_automatic.f_act_ledge_climb_fast)).
Proof. vm_compute. reflexivity. Qed.

(* ---- shapes ---- *)
Example ulcc_vars :
  fn_vars mario_actions_automatic.f_update_ledge_climb_camera = nil.
Proof. reflexivity. Qed.
Example psasp_vars : fn_vars mario.f_play_sound_and_spawn_particles = nil.
Proof. reflexivity. Qed.
Example pmls_vars : fn_vars mario.f_play_mario_landing_sound = nil.
Proof. reflexivity. Qed.
Example alcf_vars : fn_vars mario_actions_automatic.f_act_ledge_climb_fast = nil.
Proof. reflexivity. Qed.
Example ulcc_params_ok :
  aut_pok mario_actions_automatic.f_update_ledge_climb_camera = true.
Proof. vm_compute. reflexivity. Qed.
Example psasp_params_ok : aut_pok mario.f_play_sound_and_spawn_particles = true.
Proof. vm_compute. reflexivity. Qed.
Example pmls_params_ok : aut_pok mario.f_play_mario_landing_sound = true.
Proof. vm_compute. reflexivity. Qed.
Example alcf_params_ok : aut_pok mario_actions_automatic.f_act_ledge_climb_fast = true.
Proof. vm_compute. reflexivity. Qed.
Example ulcc_nonparam :
  forallb (fun t' => negb (mem_id t'
    (map fst (fn_params mario_actions_automatic.f_update_ledge_climb_camera))))
    ulcc_cact = true.
Proof. vm_compute. reflexivity. Qed.
Example alcf_nonparam_c :
  forallb (fun t' => negb (mem_id t'
    (map fst (fn_params mario_actions_automatic.f_act_ledge_climb_fast))))
    alcf_cact = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- walks ---- *)
Example ulcc_walk :
  wwalk_chk false nil nil nil ulcc_cact nil nil nil
    (fn_body mario_actions_automatic.f_update_ledge_climb_camera) = true.
Proof. vm_compute. reflexivity. Qed.
Example psasp_walk :
  wwalk_chk false nil nil nil nil psasp_xids nil nil
    (fn_body mario.f_play_sound_and_spawn_particles) = true.
Proof. vm_compute. reflexivity. Qed.
Example pmls_walk :
  wwalk_chk false nil pmls_ids nil nil nil nil nil
    (fn_body mario.f_play_mario_landing_sound) = true.
Proof. vm_compute. reflexivity. Qed.
Example alcf_walk :
  wwalk_chk false nil alcf_ids nil alcf_cact nil nil alcf_tids
    (fn_body mario_actions_automatic.f_act_ledge_climb_fast) = true.
Proof. vm_compute. reflexivity. Qed.

(* ====================================================================== *)
(* THE LEDGE-CLIMB SLOW cluster (B9 slice 7): act_ledge_climb_slow WALKED. *)
(* Reuses Hlgl / Hcul / Hpsinf / Hulc / Hulcc; ONE new helper row         *)
(* check_common_action_exits (Hccae, sids=[set_mario_action], the four    *)
(* smact-const exits -- mirrors ObjectLeafSurface.ccae_row).  The body has *)
(* a DIRECT inline action store m->action = 1357 (ACT_LEDGE_CLIMB_SLOW_1,  *)
(* statically untainted) -- discharged by the NEW const_act_store_chk      *)
(* walker arm in ActWriterSurface (const_act_assign_pres).  cact=[_t'4]    *)
(* (the marioObj gate read for the animFrame==17 branch).  Census 10 -> 9. *)
(* ====================================================================== *)

(* ---- censuses ---- *)
Definition cs_ids : list ident :=
  mario_actions_automatic._let_go_of_ledge
    :: mario_actions_automatic._climb_up_ledge
    :: mario._check_common_action_exits
    :: mario._play_sound_if_no_flag
    :: mario_actions_automatic._update_ledge_climb_camera :: nil.
Definition cs_cact : list ident := mario_actions_automatic._t'4 :: nil.
Definition cs_tids : list ident :=
  mario_actions_automatic._update_ledge_climb :: nil.

(* ---- pins ---- *)
Example ccae_pin :
  (prog_defmap mario.prog) ! mario._check_common_action_exits
  = Some (Gfun (Internal mario.f_check_common_action_exits)).
Proof. vm_compute. reflexivity. Qed.
Example cs_pin :
  (prog_defmap mario_actions_automatic.prog)
    ! mario_actions_automatic._act_ledge_climb_slow
  = Some (Gfun (Internal mario_actions_automatic.f_act_ledge_climb_slow)).
Proof. vm_compute. reflexivity. Qed.

(* ---- shapes ---- *)
Example ccae_vars : fn_vars mario.f_check_common_action_exits = nil.
Proof. reflexivity. Qed.
Example cs_vars : fn_vars mario_actions_automatic.f_act_ledge_climb_slow = nil.
Proof. reflexivity. Qed.
Example ccae_params_ok : aut_pok mario.f_check_common_action_exits = true.
Proof. vm_compute. reflexivity. Qed.
Example cs_params_ok :
  aut_pok mario_actions_automatic.f_act_ledge_climb_slow = true.
Proof. vm_compute. reflexivity. Qed.
Example cs_nonparam_c :
  forallb (fun t' => negb (mem_id t'
    (map fst (fn_params mario_actions_automatic.f_act_ledge_climb_slow))))
    cs_cact = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- walks (ccae sids reuses lgl_sids = [set_mario_action]) ---- *)
Example ccae_walk :
  wwalk_chk false nil nil nil nil nil lgl_sids nil
    (fn_body mario.f_check_common_action_exits) = true.
Proof. vm_compute. reflexivity. Qed.
Example cs_walk :
  wwalk_chk false nil cs_ids nil cs_cact nil nil cs_tids
    (fn_body mario_actions_automatic.f_act_ledge_climb_slow) = true.
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
  (* find_floor: a genuine external in lp (surface collision, not in any
     generated TU).  It is a write-only OUT-PARAM writer: the two Tier-1
     ledge helpers call it as find_floor(x,y,z,&_floor) with the Surface*
     out-param pointing at a caller STACK LOCAL.  The honest, faithful spec
     is `call_pres_ext_oc` (GATED on the out-param being a local_blk) -- NOT
     the phantom-false `call_pres_ext` (which would allow &(action cell) as
     the out-param, a vargs the real program never produces). *)
  Hypothesis Hocp_find_floor :
    call_pres_ext_oc lp bm NoA MWF SafeB mario._find_floor.
  (* the SHARED pole/tornado/hang external residuals -- the HONEST gated
     refinements of the phantom call_pres_ext rows, consumed by Hcp_spp (the
     set_pole_position walk) and reused by every pole/tornado leaf:
       - vec3f_find_ceil: a write-only OUT-PARAM writer (sibling of find_floor;
         called as vec3f_find_ceil(pos,&_ceil)) -> call_pres_ext_oc;
       - f32_find_wall_collision: a WINDOW writer (its collision-data arg targets
         a safe window of bm) -> call_pres_ext_wc;
       - vec3f_copy / vec3s_set: OBJECT writers whose dst chases m->marioObj into
         the SafeB object pool -> call_pres_ext_sc. *)
  Hypothesis Hocp_find_ceil :
    call_pres_ext_oc lp bm NoA MWF SafeB mario_actions_automatic._vec3f_find_ceil.
  Hypothesis Hwcp_fwc :
    call_pres_ext_wc lp bm NoA MWF mario_actions_automatic._f32_find_wall_collision.
  Hypothesis Hscp_v3f :
    call_pres_ext_sc lp bm NoA MWF SafeB mario_actions_automatic._vec3f_copy.
  Hypothesis Hscp_v3s :
    call_pres_ext_sc lp bm NoA MWF SafeB mario_actions_automatic._vec3s_set.
  (* f32_find_wall_collision's SECOND call shape (act_tornado_twirling): all
     three out-ptrs aim at the stack-local _nextPos elems, NOT the m->pos
     window, so the wc (args_all_window) gate above does NOT fit -- the
     honest gate is args_all_local (the ol class, same as
     find_wall_collisions/Holcp_fwc below).  f32_find_wall_collision is
     EF_external in EVERY generated TU (mario.v:12228, interaction.v:12264,
     mario_actions_automatic.v:8857), so this row is a terminal external
     model boundary, not a deferred internal walk. *)
  Hypothesis Holcp_f32fwc :
    call_pres_ext_ol lp bm NoA MWF SafeB
      mario_actions_automatic._f32_find_wall_collision.

  (* the stack-frame MWF rows for the local-vars arc (Tier-1 leaves with
     fn_vars = [_floor]).  Discharge at the capstone from MWFReal:
     HMWF_alloc <- mwf_real_alloc, HMWF_free <- mwf_real_free. *)
  Hypothesis HMWF_alloc : forall m lo hi m' b,
      Mem.alloc m lo hi = (m', b) -> MWF m -> MWF m'.
  Hypothesis HMWF_free : forall m l m',
      Mem.free_list m l = Some m' -> MWF m -> MWF m'.

  (* the local-store validity + preservation helpers for the out-param arc:
     SafeB/global blocks are valid under MWF (R0), and a store into a
     watched-disjoint stack block (local_blk) preserves MWF.  Discharged at
     the capstone from MWF_real's R0 + mwf_real_local_store. *)
  Hypothesis HSafeValid :
    forall m, MWF m -> forall b, SafeB b -> Mem.valid_block m b.
  Hypothesis HGlobValid :
    forall m, MWF m -> forall gid bg,
        Genv.find_symbol (lp_ge lp) gid = Some bg -> Mem.valid_block m bg.
  Hypothesis Hls_real :
    forall m ch b (d : Z) v m',
      local_blk lp bm SafeB b ->
      Mem.store ch m b d v = Some m' -> MWF m -> MWF m'.

  (* B10 pole-cluster scaffold:
     - Hcpx_stv: segmented_to_virtual (obj_ext_ids ext row, SHARED with the
       object family -- it is an address translation, writes no memory). *)
  Hypothesis Hcpx_stv :
    call_pres_ext lp bm NoA MWF interaction._segmented_to_virtual.
  (* - Hcp_spp: set_pole_position, the 730-line SHARED pole helper, is no
       longer ASSUMED -- it is now PROVED below (Lemma Hcp_spp) by WALKING the
       whole body via call_pres_of_lwalk3 (the lids+cact producer), resting on
       the gated leaf-external residuals Hocp_find_floor / Hocp_find_ceil (oc),
       Hwcp_fwc (wc), Hscp_v3f / Hscp_v3s (sc) + Hsmact (set_mario_action).
       The opaque whole-function residual is decomposed into those precise,
       true-in-model, dischargeable leaf residuals. *)

  (* B10 act_holding_pole externals (provided at the capstone by Hpres_obj_ext
     over obj_ext_ids -- both are write-no-Mario audio / address-translation
     externals):
       - Hcpx_ssms: set_sound_moving_speed (audio register, model class of
         play_sound);
       - Hcpx_vts:  virtual_to_segmented (segment address translation). *)
  Hypothesis Hcpx_ssms :
    call_pres_ext lp bm NoA MWF mario._set_sound_moving_speed.
  Hypothesis Hcpx_vts :
    call_pres_ext lp bm NoA MWF interaction._virtual_to_segmented.

  (* B11 top-of-pole pair: return_mario_anim_y_translation is the SOLE shared
     helper gating BOTH act_top_of_pole and act_top_of_pole_transition (each
     calls it as return_mario_anim_y_translation(m), feeding set_pole_position).
     Its whole body is now WALKED (Lemma Hrmayt below): one chase-root load
     (_t'2 = m->marioObj, SafeB), the find_mario_anim_flags_and_translation
     call (the multi-pointer out-param helper), a translation[1] read, a return.
     It REDUCES to find_mario_anim_flags_and_translation's preservation -- and
     THAT internal helper is now ITSELF WALKED (Lemma famft_body_pres_oc2 +
     Lemma Hoc2_famft below).  Its body's only memory writers are THREE genuine
     EF_external callees in mario.prog (verified Gfun(External ..)), so the walk
     DECOMPOSES the oc2 internal residual into TWO honest terminal-external
     residuals (segmented_to_virtual reuses the existing Hcpx_stv obj-ext row):
       - Hscp_geo : geo_update_animation_frame writes THROUGH obj->animInfo
         (obj = SafeB-if-ptr by the oc2 arg0 gate)  -> call_pres_ext_sc; and
       - Hocp_rai : retrieve_animation_index writes THROUGH &animIndex (this
         helper's own stack-local fn_var)            -> call_pres_ext_oc.
     decompose, not collapse: famft's whole-body residual is replaced by two
     gated leaf-external residuals one call-graph level down -- the SAME shape
     as the existing Hocp_find_floor / Hscp_v3f leaves. *)
  Hypothesis Hscp_geo :
    call_pres_ext_sc lp bm NoA MWF SafeB mario._geo_update_animation_frame.
  Hypothesis Hocp_rai :
    call_pres_ext_oc lp bm NoA MWF SafeB mario._retrieve_animation_index.

  (* the abnormal-Ssequence branch killer (crush_all is section-local to
     OutParamArc, so re-declare it here). *)
  Ltac crush_all_r :=
    repeat match goal with
    | H : ?x <> ?x |- _ => destruct (H eq_refl)
    | H : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ => inv H
    | H : exec_stmt _ _ _ _ _ (Sreturn _) _ _ _ _ |- _ => inv H
    | H : exec_stmt _ _ _ _ _ (Sassign _ _) _ _ _ _ |- _ => inv H
    | H : exec_stmt _ _ _ _ _ (Scall _ _ _) _ _ _ _ |- _ => inv H
    | H : exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ |- _ => inv H
    | H : exec_stmt _ _ _ _ _ Sskip _ _ _ _ |- _ => inv H
    | H : exec_stmt _ _ _ _ _ (Sifthenelse _ _ _) _ _ _ _ |- _ => inv H
    | H : exec_stmt _ _ _ _ _ (if ?b then _ else _) _ _ _ _ |- _ => destruct b
    end.

  (* ====================================================================== *)
  (* famft_body_pres_oc2: WALK find_mario_anim_flags_and_translation's body  *)
  (* under the oc2 gate (obj=SafeB-if-ptr, translation=stack local).  This   *)
  (* DISCHARGES the Hoc2_famft hypothesis (and capstone Hoc2famft_real) into  *)
  (* THREE honest terminal EXTERNAL residuals (all EF_external in mario.prog):*)
  (*   - geo_update_animation_frame: writes through &obj->..animInfo (obj in  *)
  (*     SafeB by the gate)            -> call_pres_ext_sc (arg0_safe);        *)
  (*   - retrieve_animation_index: writes through &animIndex (own fn_var      *)
  (*     stack local)                  -> call_pres_ext_oc (last_arg_local);   *)
  (*   - segmented_to_virtual: pure address translation, no Mem write         *)
  (*                                    -> call_pres_ext (unconditional).      *)
  (* The body's own stores are the animIndex fn_var (Sassign Evar) and the    *)
  (* *(translation+i) out-param (Sassign Ederef), both into watched-disjoint  *)
  (* stack locals (block <> bm) -> Hls_real / localstore_carried.  decompose, *)
  (* not collapse: one oc2 internal residual -> 3 leaf externals one          *)
  (* call-graph level down.  Staged as a standalone lemma (the 3 externals as *)
  (* its own premises) so the section signature is unperturbed until the swap.*)
  (* ====================================================================== *)
  Lemma famft_pin :
    (prog_defmap mario.prog) ! mario._find_mario_anim_flags_and_translation
    = Some (Gfun (Internal mario.f_find_mario_anim_flags_and_translation)).
  Proof. vm_compute. reflexivity. Qed.

  (* store brick 1: a direct Sassign into a watched-disjoint local Evar
     (the `animIndex = t'2` fn_var store) preserves carried.  Value-blind:
     localstore_carried only needs the target block <> bm. *)
  Lemma evar_store_carried :
    forall e lid pty a le m0 tr le' m' out lblk tyenv ch,
      e ! lid = Some (lblk, tyenv) ->
      local_blk lp bm SafeB lblk ->
      access_mode pty = By_value ch ->
      exec_stmt function_entry2 (lp_ge lp) e le m0
        (Sassign (Evar lid pty) a) tr le' m' out ->
      carried bm NoA MWF m0 ->
      carried bm NoA MWF m' /\ out = Out_normal.
  Proof.
    intros e lid pty a le m0 tr le' m' out lblk tyenv ch
           Hlid Hlb Hacc Hexec Hc.
    inv Hexec.
    match goal with
    | Hev : eval_lvalue _ _ _ _ (Evar _ _) ?l ?of ?bf |- _ =>
        assert (Hpin : l = lblk /\ bf = Full)
          by (eapply eval_lvalue_Evar_local_pin'; [ exact Hlid | exact Hev ]);
        destruct Hpin as [-> ->]
    end.
    match goal with
    | Has : assign_loc _ (typeof _) _ _ _ _ _ m' |- _ =>
        cbn [typeof] in Has; inv Has
    end;
    [ split; [ | reflexivity ];
      match goal with
      | Hstv : Mem.storev _ _ (Vptr lblk _) _ = Some m' |- _ =>
          unfold Mem.storev in Hstv;
          eapply localstore_carried;
            first [ exact Hls_real | exact HNoA_of_MWF
                  | exact Hlb | exact Hstv | exact Hc ]
      end
    | match goal with
      | Hco : access_mode pty = By_copy |- _ =>
          rewrite Hacc in Hco; discriminate Hco
      end ].
  Qed.

  (* store brick 2: an indexed Sassign through a POINTER tempvar holding a
     watched-disjoint local block (the `*(translation+i) = short` out-param
     store) preserves carried.  Twin of local_idx_assign_pres' but the base
     is a bare pointer Etempvar (rvalue, no deref_loc), not an array Evar. *)
  Lemma tempptr_idx_store_carried :
    forall e tid ety idxN ity ety2 a2 le m0 tr le' m' out b ofs ch,
      le ! tid = Some (Vptr b ofs) ->
      local_blk lp bm SafeB b ->
      access_mode ety2 = By_value ch ->
      exec_stmt function_entry2 (lp_ge lp) e le m0
        (Sassign (Ederef (Ebinop Oadd (Etempvar tid (tptr ety))
                            (Econst_int idxN tint) ity) ety2) a2)
        tr le' m' out ->
      carried bm NoA MWF m0 ->
      carried bm NoA MWF m' /\ out = Out_normal.
  Proof.
    intros e tid ety idxN ity ety2 a2 le m0 tr le' m' out b ofs ch
           Htid Hlb Hacc Hexec Hc.
    inv Hexec.
    match goal with
    | Hlv : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hlv
    end.
    match goal with
    | Hp : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ => inv Hp
    end.
    2:{ match goal with
        | Hlv2 : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ => inv Hlv2
        end. }
    match goal with
    | Hi : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
        inv Hi;
        try (match goal with
             | Hlv3 : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ => inv Hlv3
             end)
    end.
    (* derive the base value WITHOUT inv (inv would subst the tid variable):
       apply eval_expr_Etempvar_val, then pin v1 = Vptr b ofs via Htid. *)
    match goal with
    | Hb : eval_expr _ _ _ _ (Etempvar tid _) ?vb |- _ =>
        apply eval_expr_Etempvar_val in Hb;
        rewrite Htid in Hb; injection Hb as Hvb; subst vb
    end.
    match goal with
    | Hsem : sem_binary_operation _ Oadd _ _ _ _ _ = Some (Vptr ?l2 _) |- _ =>
        cbn in Hsem; injection Hsem as Hbl Hof; subst l2
    end.
    match goal with
    | Has : assign_loc _ (typeof _) _ _ _ _ _ m' |- _ =>
        cbn [typeof] in Has; inv Has
    end;
    [ split; [ | reflexivity ];
      match goal with
      | Hstv : Mem.storev _ _ (Vptr b _) _ = Some m' |- _ =>
          unfold Mem.storev in Hstv;
          eapply localstore_carried;
            first [ exact Hls_real | exact HNoA_of_MWF
                  | exact Hlb | exact Hstv | exact Hc ]
      end
    | match goal with
      | Hco : access_mode ety2 = By_copy |- _ =>
          rewrite Hacc in Hco; discriminate Hco
      end ].
  Qed.

  (* plain external Scall (no out-param gate) preserves carried -- the
     segmented_to_virtual call sites (pure segment->virtual address
     translation, write-free).  Wraps ActWriterSurface.kit_scallx_pres,
     bundling carried in/out. *)
  Lemma stv_scall_pres :
    forall optid fid targs tres tcc al e le0 m0 tr le1 m1 out0,
      e ! fid = None ->
      call_pres_ext lp bm NoA MWF fid ->
      exec_stmt function_entry2 (lp_ge lp) e le0 m0
        (Scall optid (Evar fid (Tfunction targs tres tcc)) al) tr le1 m1 out0 ->
      carried bm NoA MWF m0 ->
      carried bm NoA MWF m1 /\ out0 = Out_normal.
  Proof.
    intros optid fid targs tres tcc al e le0 m0 tr le1 m1 out0
           He Hext Hexec (HV & HS & HM & HN).
    destruct (kit_scallx_pres lp bm NoA MWF optid fid targs tres tcc al
                e le0 m0 tr le1 m1 out0 He Hexec Hext HN HM HV HS)
      as (HV' & HS' & HM' & HN' & Hout & _).
    split; [ split; [ exact HV' | split; [ exact HS'
           | split; [ exact HM' | exact HN' ] ] ] | exact Hout ].
  Qed.

  (* env-shape recovery for a Scall leaf: the *scall_pres bricks discard the
     output temp-env relationship, leaving it an OPAQUE variable.  This recovers
     `le1 = set_opttemp optid vres le0` from the leaf itself so the env chain
     stays CONCRETE (a tower of PTree.set over the entry env le1) -- without it,
     the *(translation+i) out-param stores (which need le ! _translation by
     gso-peel) hit an opaque post-call env and cannot resolve. *)
  Lemma call_le_form :
    forall optid a al e le0 m0 tr le1 m1 out0,
      exec_stmt function_entry2 (lp_ge lp) e le0 m0
        (Scall optid a al) tr le1 m1 out0 ->
      exists vr, le1 = set_opttemp optid vr le0.
  Proof. intros. inv H. eexists; reflexivity. Qed.

  (* env-shape recovery for an Sassign leaf: a store leaves the temp-env
     UNCHANGED (exec_Sassign concludes with output env = input env), but the
     store bricks discard that, leaving the post-store env an OPAQUE seq-boundary
     variable.  This recovers le1 = le0 so the chain stays concrete past stores
     (the _animIndex store would otherwise sever the tower above the params). *)
  Lemma assign_le_eq :
    forall a1 a2 e le0 m0 tr le1 m1 out0,
      exec_stmt function_entry2 (lp_ge lp) e le0 m0
        (Sassign a1 a2) tr le1 m1 out0 ->
      le1 = le0.
  Proof. intros. inv H. reflexivity. Qed.

  (* ====================================================================== *)
  (* famft_body_pres_oc2: WALK find_mario_anim_flags_and_translation's body  *)
  (* under the oc2 gate.  Its only memory writers are 6 external Scalls (1   *)
  (* geo_update_animation_frame, 2 segmented_to_virtual, 3 retrieve_anim..)  *)
  (* and 4 watched-disjoint local stores (1 animIndex fn_var, 3 *translation *)
  (* out-param).  PHASE 1 peels the whole nested-Ssequence body, inverting   *)
  (* every Sset/Sreturn (memory-neutral) and killing the abnormal branches,  *)
  (* leaving the 10 mem-changing leaves as a linear chain me -> ... -> m2.    *)
  (* PHASE 2 threads `carried` along that chain (each leaf matched by INPUT   *)
  (* mem against the running carried hyp -> order is automatic): the geo call *)
  (* via sc_scall_pres (its dst &obj->animInfo lands in _obj's block, SafeB   *)
  (* by the oc2 arg0 gate -- famft_geo_arg0_block + Hcond), the seg2v calls   *)
  (* via stv_scall_pres (plain, Hcpx_stv), the retrieve calls via            *)
  (* oc_scall_pres (last arg &animIndex local -- oc_last_addrof_ptr2 + Heai), *)
  (* the animIndex store via evar_store_carried, the *translation stores via  *)
  (* tempptr_idx_store_carried (le!_translation = v_trans by gso-peel of      *)
  (* Htrans1, local_blk by the oc2 last-arg gate).  Exit: free_list the       *)
  (* _animIndex stack block (free_list_carried_bm + blocks_of_env_bm).        *)
  (* decompose, not collapse: famft's oc2 internal residual is now reduced    *)
  (* to Hscp_geo (sc) + Hocp_rai (oc) [+ existing Hcpx_stv], terminal         *)
  (* EF_external residuals one call-graph level down. *)
  (* ====================================================================== *)
  Lemma famft_body_pres_oc2 :
    body_pres_oc2 lp bm NoA MWF SafeB
      mario.f_find_mario_anim_flags_and_translation.
  Proof.
    intros m vargs t mF vres Hgate Hevf HN HM HV HS.
    destruct Hgate as (Hcond & Hlast).
    (* ---- entry: alloc _animIndex, bind _obj/_yaw/_translation ---- *)
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ =>
      rename He into Hentry end.
    match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
      rename Hx into Hbody end.
    match goal with Hf : Mem.free_list _ _ = Some _ |- _ =>
      rename Hf into Hfree end.
    inv Hentry.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
      rename Ha into Halloc end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ =>
      rename Hb into Hbind end.
    unfold mario.f_find_mario_anim_flags_and_translation in Hbody, Hbind, Halloc.
    cbn [fn_body fn_params fn_temps fn_vars] in Hbody, Hbind, Halloc.
    match goal with H : alloc_variables _ _ _ _ ?E ?ME |- _ =>
      set (eloc := E) in *; set (me := ME) in * end.
    assert (Hc0 : carried bm NoA MWF m)
      by (split; [ exact HV | split; [ exact HS
                 | split; [ exact HM | exact HN ] ] ]).
    pose proof (alloc_variables_carried bm NoA MWF HMWF_alloc HNoA_of_MWF
                  _ _ _ _ _ _ Halloc Hc0) as Hce.
    destruct Hce as (HVe & HSe & HMe & HNe).
    (* the _animIndex fn_var is a watched-disjoint stack block *)
    pose proof (alloc_variables_hlocal lp bm SafeB m _ eloc _
                  (mario._animIndex :: nil) Halloc HV
                  (HSafeValid m HM) (HGlobValid m HM)
                  ltac:(intros lid Hm; unfold mem_id in Hm; cbn [existsb] in Hm;
                        apply Bool.orb_true_iff in Hm; destruct Hm as [He | Hf];
                        [ apply Pos.eqb_eq in He; subst lid; cbn [map fst];
                          apply in_eq
                        | discriminate Hf ]))
      as Hlocal_fn.
    destruct (Hlocal_fn mario._animIndex eq_refl) as (aib & aity & Heai & Hailoc).
    (* bind the 3 params: _obj, _yaw, _translation *)
    destruct vargs as [| v_obj vr1];
      cbn [bind_parameter_temps] in Hbind; [ discriminate Hbind | ].
    destruct vr1 as [| v_yaw vr2];
      cbn [bind_parameter_temps] in Hbind; [ discriminate Hbind | ].
    destruct vr2 as [| v_trans vr3];
      cbn [bind_parameter_temps] in Hbind; [ discriminate Hbind | ].
    destruct vr3; [ | cbn [bind_parameter_temps] in Hbind; discriminate Hbind ].
    injection Hbind as Hle_init.
    assert (Hobj1 : le1 ! mario._obj = Some v_obj)
      by (rewrite <- Hle_init;
          repeat (rewrite PTree.gso by (vm_compute; discriminate));
          apply PTree.gss).
    assert (Htrans1 : le1 ! mario._translation = Some v_trans)
      by (rewrite <- Hle_init; apply PTree.gss).
    (* oc2 gate: last arg local => v_trans = Vptr tlb tlo with local_blk tlb *)
    cbn [last_val] in Hlast.
    destruct Hlast as (tlb & tlo & Hvtr & Htlloc).
    injection Hvtr as Hvtr; subst v_trans.
    (* the 3 external callees are globals, unbound in the entry env *)
    assert (Hgeo_none : eloc ! mario._geo_update_animation_frame = None).
    { rewrite (alloc_variables_unbound (lp_ge lp) m _ empty_env _ _ Halloc
                 mario._geo_update_animation_frame)
        by (cbn; intros [HH | []]; vm_compute in HH; discriminate HH).
      apply PTree.gempty. }
    assert (Hstv_none : eloc ! mario._segmented_to_virtual = None).
    { rewrite (alloc_variables_unbound (lp_ge lp) m _ empty_env _ _ Halloc
                 mario._segmented_to_virtual)
        by (cbn; intros [HH | []]; vm_compute in HH; discriminate HH).
      apply PTree.gempty. }
    assert (Hrai_none : eloc ! mario._retrieve_animation_index = None).
    { rewrite (alloc_variables_unbound (lp_ge lp) m _ empty_env _ _ Halloc
                 mario._retrieve_animation_index)
        by (cbn; intros [HH | []]; vm_compute in HH; discriminate HH).
      apply PTree.gempty. }
    assert (Hcar : carried bm NoA MWF me)
      by (split; [ exact HVe | split; [ exact HSe
                 | split; [ exact HMe | exact HNe ] ] ]).
    clear Hc0 HVe HSe HMe HNe.
    (* ---- PHASE 1: peel the body to the 10 mem-changing leaves ---- *)
    repeat first
      [ match goal with
        | H : exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ |- _ =>
            inv H; [ | crush_all_r ]
        end
      | match goal with
        | H : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ => inv H
        | H : exec_stmt _ _ _ _ _ (Sreturn _) _ _ _ _ |- _ => inv H
        end ].
    (* ---- PHASE 2: thread carried along the leaf chain (input-mem matched) ---- *)
    repeat
      match goal with
      (* geo_update_animation_frame: dst &obj->animInfo in _obj's block (SafeB) *)
      | Hc : carried bm NoA MWF ?mc,
        H : exec_stmt _ _ ?E ?L ?mc
              (Scall _ (Evar mario._geo_update_animation_frame
                          (Tfunction ?TYL _ _)) ?ARGS) _ ?Lo ?mn _ |- _ =>
          let Hg := fresh "Hgate_geo" in
          assert (Hg : forall vargs,
                    eval_exprlist (lp_ge lp) E L mc ARGS TYL vargs ->
                    arg0_safe SafeB vargs);
          [ intros vargs Hvl; inv Hvl;
            match goal with
            | Hexpr : eval_expr _ _ _ _ (Eaddrof _ _) ?v0,
              Hcast : sem_cast ?v0 _ _ _ = Some ?vh |- arg0_safe _ (?vh :: ?rest) =>
                destruct (famft_geo_arg0_block lp E L mc v0 Hexpr)
                  as (gloc & go & goo & Hgv0 & Hgobj);
                rewrite Hgv0 in Hcast; cbn in Hcast; injection Hcast as Hcast;
                assert (Hgo : L ! mario._obj = Some v_obj)
                  by (repeat (rewrite PTree.gso by (vm_compute; discriminate));
                      apply PTree.gss);
                rewrite Hgobj in Hgo; injection Hgo as Hgoeq;
                exists gloc, go, rest; split;
                  [ rewrite Hcast; reflexivity
                  | exact (Hcond gloc goo (eq_sym Hgoeq)) ]
            end
          | destruct (sc_scall_pres lp bm NoA MWF SafeB _
                        mario._geo_update_animation_frame TYL _ _ ARGS E L mc
                        _ Lo mn _ Hgeo_none Hscp_geo Hg H Hc) as (Hc' & _);
            destruct (call_le_form _ _ _ _ _ _ _ _ _ _ H) as (? & Hle_);
            cbn [set_opttemp] in Hle_;
            clear Hc H Hg; rename Hc' into Hc; subst Lo ]
      (* segmented_to_virtual: plain external, write-free *)
      | Hc : carried bm NoA MWF ?mc,
        H : exec_stmt _ _ _ _ ?mc
              (Scall _ (Evar mario._segmented_to_virtual _) _) _ ?Lo ?mn _ |- _ =>
          destruct (stv_scall_pres _ _ _ _ _ _ _ _ _ _ _ _ _
                      Hstv_none Hcpx_stv H Hc) as (Hc' & _);
          destruct (call_le_form _ _ _ _ _ _ _ _ _ _ H) as (? & Hle_);
          cbn [set_opttemp] in Hle_;
          clear Hc H; rename Hc' into Hc; subst Lo
      (* retrieve_animation_index: last arg &animIndex (local) *)
      | Hc : carried bm NoA MWF ?mc,
        H : exec_stmt _ _ ?E ?L ?mc
              (Scall _ (Evar mario._retrieve_animation_index
                          (Tfunction ?TYL _ _)) ?ARGS) _ ?Lo ?mn _ |- _ =>
          let Hg := fresh "Hgate_rai" in
          assert (Hg : forall vargs,
                    eval_exprlist (lp_ge lp) E L mc ARGS TYL vargs ->
                    last_arg_local lp bm SafeB vargs)
            by (intros vargs Hvl;
                eapply oc_last_addrof_ptr2; [ exact Heai | exact Hailoc | exact Hvl ]);
          destruct (oc_scall_pres lp bm NoA MWF SafeB _
                      mario._retrieve_animation_index TYL _ _ ARGS E L mc
                      _ Lo mn _ Hrai_none Hocp_rai Hg H Hc) as (Hc' & _);
          destruct (call_le_form _ _ _ _ _ _ _ _ _ _ H) as (? & Hle_);
          cbn [set_opttemp] in Hle_;
          clear Hc H Hg; rename Hc' into Hc; subst Lo
      (* animIndex fn_var store (local Evar) *)
      | Hc : carried bm NoA MWF ?mc,
        H : exec_stmt _ _ _ _ ?mc
              (Sassign (Evar mario._animIndex ?pty) _) _ ?Lo ?mn _ |- _ =>
          destruct (evar_store_carried _ mario._animIndex pty _ _ _ _ _ _ _
                      aib aity _ Heai Hailoc eq_refl H Hc) as (Hc' & _);
          pose proof (assign_le_eq _ _ _ _ _ _ _ _ _ H) as Hle_;
          clear Hc H; rename Hc' into Hc; subst Lo
      (* *(translation+i) out-param store (local pointer Etempvar base) *)
      | Hc : carried bm NoA MWF ?mc,
        H : exec_stmt _ _ ?E ?L ?mc
              (Sassign (Ederef (Ebinop Oadd (Etempvar mario._translation _)
                                 _ _) _) _) _ ?Lo ?mn _ |- _ =>
          destruct (tempptr_idx_store_carried E mario._translation tshort _
                      (tptr tshort) tshort _ L _ _ _ _ _ tlb tlo _
                      ltac:(repeat (rewrite PTree.gso by (vm_compute; discriminate));
                            apply PTree.gss)
                      Htlloc eq_refl H Hc) as (Hc' & _);
          pose proof (assign_le_eq _ _ _ _ _ _ _ _ _ H) as Hle_;
          clear Hc H; rename Hc' into Hc; subst Lo
      end.
    (* ---- exit: free the _animIndex stack block ---- *)
    destruct Hcar as (HVb & HSb & HMb & HNb).
    pose proof (blocks_of_env_bm lp bm m _ eloc _ Halloc HV) as Hforall.
    pose proof (free_list_carried_bm bm NoA MWF HMWF_free HNoA_of_MWF
                  (blocks_of_env (lp_ge lp) eloc) _ mF Hforall Hfree
                  (conj HVb (conj HSb (conj HMb HNb))))
      as (HVf & HSf & HMf & HNf).
    exact (conj HVf (conj HSf HMf)).
  Qed.

  (* THE DISCHARGE: lift the per-body walk to the oc2 residual via the
     producer + the prog_defmap pin -- Hoc2_famft is now PROVED (no longer a
     Hypothesis), resting on Hscp_geo / Hocp_rai / Hcpx_stv. *)
  Lemma Hoc2_famft :
    call_pres_ext_oc2 lp bm NoA MWF SafeB
      mario._find_mario_anim_flags_and_translation.
  Proof.
    exact (call_pres_ext_oc2_of_body lp bm NoA MWF SafeB HNoA_of_MWF
             mario.prog _ mario.f_find_mario_anim_flags_and_translation
             LO_mario famft_pin famft_body_pres_oc2).
  Qed.

  Lemma rmayt_pin :
    (prog_defmap mario.prog) ! mario._return_mario_anim_y_translation
    = Some (Gfun (Internal mario.f_return_mario_anim_y_translation)).
  Proof. vm_compute. reflexivity. Qed.

  Lemma Hrmayt :
    call_pres lp bm NoA MWF mario._return_mario_anim_y_translation.
  Proof.
    apply (call_pres_of_body lp bm NoA MWF HNoA_of_MWF mario.prog
             _ mario.f_return_mario_anim_y_translation LO_mario rmayt_pin).
    intros m0 vargs0 t0 mF vres0 Hmargf Hevf HN HM HV HS.
    assert (Hmarg : marg_ok bm vargs0)
      by (apply Hmargf; vm_compute; reflexivity).
    (* ---- entry: alloc the _translation local, bind the _m param ---- *)
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ =>
      rename He into Hentry end.
    match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
      rename Hx into Hbody end.
    match goal with Hf : Mem.free_list _ _ = Some _ |- _ =>
      rename Hf into Hfree end.
    inv Hentry.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
      rename Ha into Halloc end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ =>
      rename Hb into Hbind end.
    unfold mario.f_return_mario_anim_y_translation in Hbody, Hbind, Halloc.
    cbn [fn_body fn_params fn_temps fn_vars] in Hbody, Hbind, Halloc.
    match goal with H : alloc_variables _ _ _ _ ?E ?ME |- _ =>
      set (eloc := E) in *; set (me := ME) in * end.
    assert (Hc0 : carried bm NoA MWF m0)
      by (split; [ exact HV | split; [ exact HS | split; [ exact HM | exact HN ] ] ]).
    pose proof (alloc_variables_carried bm NoA MWF HMWF_alloc HNoA_of_MWF
                  _ _ _ _ _ _ Halloc Hc0) as Hce.
    destruct Hce as (HVe & HSe & HMe & HNe).
    (* the _translation local is a watched-disjoint stack block *)
    pose proof (alloc_variables_hlocal lp bm SafeB m0 _ eloc _
                  (mario._translation :: nil) Halloc HV
                  (HSafeValid m0 HM) (HGlobValid m0 HM)
                  ltac:(intros lid Hm; unfold mem_id in Hm; cbn [existsb] in Hm;
                        apply Bool.orb_true_iff in Hm; destruct Hm as [He | Hf];
                        [ apply Pos.eqb_eq in He; subst lid; cbn [map fst]; apply in_eq
                        | discriminate Hf ]))
      as Hlocal_fn.
    destruct (Hlocal_fn mario._translation eq_refl)
      as (tb & tty & Hetrans & Htloc).
    (* the _m param is bound to v1 = (bm,0) by marg *)
    destruct vargs0 as [| v1 vrest];
      cbn [bind_parameter_temps] in Hbind; [ discriminate Hbind | ].
    destruct vrest; [ | cbn [bind_parameter_temps] in Hbind; discriminate Hbind ].
    injection Hbind as Hle_init.
    (* le1 ! _m = Some v1 (the marg-pinned Mario pointer) *)
    assert (Hmeq : le1 ! mario_actions_airborne._m = Some v1)
      by (rewrite <- Hle_init; apply PTree.gss).
    assert (Htat : forall b o,
               le1 ! mario_actions_airborne._m = Some (Vptr b o) ->
               b = bm /\ o = Ptrofs.zero)
      by (intros b o Hg; rewrite Hmeq in Hg; injection Hg as Hv1;
          rewrite Hv1 in Hmarg; cbn in Hmarg; exact Hmarg).
    (* famft is a global, unbound in the entry env *)
    assert (Hfamft_none :
              eloc ! mario._find_mario_anim_flags_and_translation = None).
    { rewrite (alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc
                 mario._find_mario_anim_flags_and_translation)
        by (cbn; intros [HH | []]; vm_compute in HH; discriminate HH).
      apply PTree.gempty. }
    (* ---- walk the body: A = (Sset _t'2 chase ; Scall famft) ; B = (Sset _t'1 read ; Sreturn) ---- *)
    inv Hbody; [ | crush_all_r ].
    match goal with
    | HA : exec_stmt _ _ _ _ _ (Ssequence (Sset _ _) (Scall _ _ _)) _ _ _ Out_normal |- _ =>
        inv HA; [ | crush_all_r ]
    end.
    (* the chase-root Sset: le -> set _t'2 v2, mem unchanged; v2 is SafeB-if-ptr *)
    match goal with
    | HA1 : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ => inv HA1
    end.
    assert (Hchk :
      chase_root_chk
        (Efield
           (Ederef (Etempvar mario._m (tptr (Tstruct mario._MarioState noattr)))
              (Tstruct mario._MarioState noattr)) mario._marioObj
           (tptr (Tstruct mario._Object noattr))) = true)
      by (vm_compute; reflexivity).
    match goal with
    | H : eval_expr _ _ _ _ (Efield _ _ _) _ |- _ => rename H into HevalE
    end.
    pose proof (chase_root_set_sound lp LO_mario bm MWF
                  HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm
                  HchaseRoot HMWF_root
                  _ eloc _ me _ Hchk Htat HMe HevalE) as Hsafe_t2.
    (* the famft Scall: carried preserved (multi-ptr out-param gate).
       Prove the gate as a standalone Hgate with the call's envs/args matched
       CONCRETELY from HA2 -- this pins le0 (so `rewrite PTree.gss` in the
       arg0-cond proof works) and lets the forward `destruct` resolve the
       oc2_scall_pres evars from Hgate's own type. *)
    match goal with
    | H : exec_stmt _ _ _ _ _ (Scall _ _ _) _ _ _ _ |- _ => rename H into HA2
    end.
    match type of HA2 with
    | exec_stmt _ _ ?E ?L ?M
        (Scall _ (Evar _ (Tfunction ?TYL _ _)) ?ARGS) _ _ _ _ =>
        assert (Hgate : forall vargs,
                  eval_exprlist (lp_ge lp) E L M ARGS TYL vargs ->
                  oc2_gate lp bm SafeB vargs)
          by (intros vargs Hvl;
              eapply (oc2_extract lp bm SafeB E L M
                        mario._t'2 _ _ _ mario._translation _ _ _ tty tb vargs);
              [ intros bb oo Hg; rewrite PTree.gss in Hg;
                injection Hg as Hv; exact (Hsafe_t2 bb oo Hv)
              | exact Hetrans | exact Htloc | exact Hvl ])
    end.
    destruct (oc2_scall_pres lp bm NoA MWF SafeB
                None mario._find_mario_anim_flags_and_translation
                _ _ _ _ _ _ _ _ _ _ _
                Hfamft_none Hoc2_famft Hgate
                HA2 (conj HVe (conj HSe (conj HMe HNe))))
      as (Hcar2 & _).
    (* B = (Sset _t'1 read ; Sreturn) -- neither touches memory *)
    match goal with
    | HB : exec_stmt _ _ _ _ _ (Ssequence (Sset _ _) (Sreturn _)) _ _ _ _ |- _ =>
        inv HB; [ | crush_all_r ]
    end.
    match goal with
    | HB1 : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ => inv HB1
    end.
    match goal with
    | HB2 : exec_stmt _ _ _ _ _ (Sreturn _) _ _ _ _ |- _ => inv HB2
    end.
    (* ---- exit: free the _translation stack block ---- *)
    destruct Hcar2 as (HVb & HSb & HMb & HNb).
    pose proof (blocks_of_env_bm lp bm m0 _ eloc _ Halloc HV) as Hforall.
    pose proof (free_list_carried_bm bm NoA MWF HMWF_free HNoA_of_MWF
                  (blocks_of_env (lp_ge lp) eloc) _ mF Hforall Hfree
                  (conj HVb (conj HSb (conj HMb HNb))))
      as (HVf & HSf & HMf & HNf).
    exact (conj HVf (conj HSf HMf)).
  Qed.

  (* ====================================================================== *)
  (* B11 update_hang_moving: WALKED.  This DISCHARGES the old opaque Huhm    *)
  (* whole-helper Hypothesis into TWO honest leaf-callee residuals one       *)
  (* call-graph level down (decompose, not collapse):                        *)
  (*   - approach_s32 : a pure-math integer-clamp EF_external (no Mem write)  *)
  (*                    -> call_pres_ext (Hcpx_approach);                     *)
  (*   - perform_hanging_step : the INTERNAL hang-physics helper, called as   *)
  (*     perform_hanging_step(m, nextPos) with arg0 = Mario (bm,0) AND the    *)
  (*     last arg = the caller's _nextPos stack local.  Its body DIRECTLY     *)
  (*     stores nextPos[1], so a marg-only call_pres is phantom-FALSE; the    *)
  (*     honest residual is the marg-AND-local gate call_pres_mo (Hcp_php).   *)
  (* update_hang_moving's own writers are all marg-pinned Mario-field stores  *)
  (* (forwardVel/slideYaw/slideVelX/slideVelZ direct, faceAngle[1] idx16,     *)
  (* vel[0..2] idx), watched-disjoint _nextPos[0..2] local stores, and the    *)
  (* two graphics OBJECT writers vec3f_copy/vec3s_set chasing m->marioObj     *)
  (* into the SafeB object pool (Hscp_v3f / Hscp_v3s).  Same decompose shape  *)
  (* as famft / set_pole_position. *)
  (* ====================================================================== *)
  Hypothesis Hcpx_approach :
    call_pres_ext lp bm NoA MWF mario_actions_automatic._approach_s32.
  (* Hcp_php was a Hypothesis here; it is now the PROVED Lemma Hcp_php below
     (after php_walk_pres + php_body_pres_mo), resting on the ol/w1/oc leaf
     externals.  uhm_tail_pres / uhm_body_pres consume the proved version. *)

  (* ====================================================================== *)
  (* STAGE 1 (additive, no new hyps): the perform_hanging_step body         *)
  (* RECOGNIZER + its validation on the real generated AST.  php_chk        *)
  (* accepts exactly the body's leaf vocabulary so the exec-derivation      *)
  (* induction (php_walk_pres, below) can reject Sbuiltin/Sloop/Sswitch.    *)
  (* ====================================================================== *)
  Definition php_call_chk (fid : ident) (fty : type) (al : list expr) : bool :=
    oc_call_chk
      (mario_actions_automatic._floor :: mario_actions_automatic._ceil :: nil)
      (mario_actions_automatic._find_floor
         :: mario_actions_automatic._vec3f_find_ceil :: nil) fid fty al
    || (Pos.eqb fid mario_actions_automatic._resolve_and_return_wall_collisions
        && proj_sumbool
             (type_eq fty
                (Tfunction (tptr tfloat :: tfloat :: tfloat :: nil)
                   (tptr (Tstruct mario_actions_automatic._Surface noattr))
                   cc_default))
        && match al with
           | Etempvar q tq :: Econst_single _ _ :: Econst_single _ _ :: nil =>
               Pos.eqb q mario_actions_automatic._nextPos
               && proj_sumbool (type_eq tq (tptr tfloat))
           | _ => false
           end)
    || (Pos.eqb fid mario_actions_automatic._vec3f_copy
        && proj_sumbool
             (type_eq fty
                (Tfunction (tptr tfloat :: tptr tfloat :: nil) (tptr tvoid)
                   cc_default))
        && match al with
           | Efield (Ederef (Etempvar mp tmp) tsm) fld tfa :: Etempvar q tq :: nil =>
               Pos.eqb mp mario_actions_automatic._m
               && Pos.eqb fld mario_actions_automatic._pos
               && Pos.eqb q mario_actions_automatic._nextPos
               && proj_sumbool
                    (type_eq tmp
                       (tptr (Tstruct mario_actions_automatic._MarioState noattr)))
               && proj_sumbool
                    (type_eq tsm
                       (Tstruct mario_actions_automatic._MarioState noattr))
               && proj_sumbool (type_eq tfa (tarray tfloat 3))
           | _ => false
           end).

  (* the per-leaf Sassign recognizer: a marg Mario-field store (value-blind)
     OR the nextPos[1] indexed local-out-param store. *)
  Definition php_assign_chk (a1 : expr) : bool :=
    safe_mfield_store mario_actions_automatic._m a1
    || match a1 with
       | Ederef (Ebinop Oadd (Etempvar q tq) (Econst_int _ tci) _) ety =>
           Pos.eqb q mario_actions_automatic._nextPos
           && proj_sumbool (type_eq tq (tptr tfloat))
           && proj_sumbool (type_eq tci tint)
           && proj_sumbool (type_eq ety tfloat)
       | _ => false
       end.

  Definition php_optid_ok (optid : option ident) : bool :=
    match optid with
    | Some id => negb (Pos.eqb id mario_actions_automatic._m)
                 && negb (Pos.eqb id mario_actions_automatic._nextPos)
    | None => true
    end.

  Fixpoint php_chk (s : statement) : bool :=
    match s with
    | Sskip | Sbreak | Scontinue => true
    | Sreturn _ => true
    | Ssequence s1 s2 => php_chk s1 && php_chk s2
    | Sifthenelse _ s1 s2 => php_chk s1 && php_chk s2
    | Sset id _ => php_optid_ok (Some id)
    | Sassign a1 _ => php_assign_chk a1
    | Scall optid (Evar fid fty) al => php_optid_ok optid && php_call_chk fid fty al
    | _ => false
    end.

  Lemma php_pin :
    (prog_defmap mario_actions_automatic.prog)
      ! mario_actions_automatic._perform_hanging_step
    = Some (Gfun (Internal mario_actions_automatic.f_perform_hanging_step)).
  Proof. vm_compute. reflexivity. Qed.

  (* NON-VACUITY: the recognizer accepts the REAL generated body. *)
  Lemma php_chk_body :
    php_chk (fn_body mario_actions_automatic.f_perform_hanging_step) = true.
  Proof. vm_compute. reflexivity. Qed.

  (* ====================================================================== *)
  (* STAGE 2: the w1 (dst-window) gate construction for the vec3f_copy call *)
  (* site -- the bare m->pos array field, as an RVALUE, decays By_reference *)
  (* to its base address Vptr bm 60, a safe 12-byte window (action cell @12 *)
  (* clear).  Mirror of window_addr_val but for the whole-array decay.      *)
  (* ====================================================================== *)
  Lemma pos_window_val :
    forall e le m v,
      (forall b o, le ! mario_actions_automatic._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) ->
      eval_expr (lp_ge lp) e le m
        (Efield
           (Ederef (Etempvar mario_actions_automatic._m
                      (tptr (Tstruct mario_actions_automatic._MarioState noattr)))
              (Tstruct mario_actions_automatic._MarioState noattr))
           mario_actions_automatic._pos (tarray tfloat 3)) v ->
      exists o, v = Vptr bm o /\ store_window_ok (Ptrofs.unsigned o) 12 = true.
  Proof.
    intros e le m v Htat Hev.
    assert (Hfo : field_offset (prog_comp_env mario.prog)
                    mario_actions_automatic._pos mario_state_members
                  = OK (60, Full)) by (vm_compute; reflexivity).
    assert (Hwin : store_window_ok 60 12 = true) by (vm_compute; reflexivity).
    inv Hev.
    match goal with
    | Hd : deref_loc (typeof _) _ _ _ _ _ |- _ => cbn [typeof] in Hd
    end.
    match goal with
    | Hd : deref_loc (tarray tfloat 3) _ _ _ _ _ |- _ =>
        inv Hd;
        try (match goal with Hacc : access_mode (tarray tfloat 3) = _ |- _ =>
               cbn in Hacc; discriminate Hacc end);
        try (match goal with Hlb : load_bitfield (tarray tfloat 3) _ _ _ _ _ _ _ |- _ =>
               inv Hlb end)
    end.
    match goal with
    | Hflv : eval_lvalue _ _ _ _ (Efield _ _ _) ?lf ?of ?bff |- _ =>
        pose proof Hflv as Hpin;
        apply eval_lvalue_Efield_base in Hpin;
        destruct Hpin as (oo0 & Hbase);
        apply eval_expr_Ederef_load in Hbase;
        destruct Hbase as (lb & ob & bfb & Hlvb & _);
        apply eval_lvalue_Ederef_base in Hlvb;
        apply eval_expr_Etempvar_val in Hlvb;
        destruct (Htat _ _ Hlvb) as [E1 E2]; subst lb ob;
        destruct (mfield_lvalue_geom_lp lp LO_mario _ _ _ _ _ _
                    lf of bff _ _ _ Hlvb Hfo Hflv) as (E3 & E4 & _);
        subst lf of
    end.
    eexists. split; [ reflexivity | ].
    rewrite Ptrofs.add_zero_l.
    rewrite Ptrofs.unsigned_repr by (vm_compute; split; discriminate).
    exact Hwin.
  Qed.

  (* a single-constant always evaluates to its Vsingle value (mirror of
     eval_expr_Etempvar_val): used in the resolve gate to refute that a
     float-constant argument could be a pointer.  Proving it as a lemma
     avoids inverting eval_expr inline (which spawns a spurious eval_lvalue
     case that would leak extra goals into the gate). *)
  Lemma eval_Econst_single_val : forall e le m c ty v,
    eval_expr (lp_ge lp) e le m (Econst_single c ty) v -> v = Vsingle c.
  Proof.
    intros e le m c ty v H; inv H; auto.
    match goal with
    | Hlv : eval_lvalue _ _ _ _ (Econst_single _ _) _ _ _ |- _ => inv Hlv
    end.
  Qed.

  (* ====================================================================== *)
  (* resolve_and_return_wall_collisions: WALKED, not assumed.               *)
  (* Hocp_resolve used to be a section Hypothesis (the ol residual that the *)
  (* perform_hanging_step discharge introduced); it is now the PROVED Lemma *)
  (* Hocp_resolve below.  resolve resolves IN lp to the INTERNAL body       *)
  (* f_resolve_and_return_wall_collisions (mario.prog, generated/mario.v:   *)
  (* 3270), so the residual is dischargeable by walking that body under the *)
  (* args_all_local gate.  Census of the body's writers: 5 stores into the  *)
  (* LOCAL fn_var struct _collisionData (Efield of a local Evar); 3 stores  *)
  (* through the _pos param pointer (local-if-pointer under the gate); the  *)
  (* rest is Ssets, one store-free Sifthenelse, a Sreturn, and ONE call     *)
  (* find_wall_collisions(&_collisionData).  find_wall_collisions has NO    *)
  (* internal body in ANY TU (EF_external everywhere: mario.v:12235,        *)
  (* mario_actions_moving.v:13675) -> the walk bottoms out in exactly ONE   *)
  (* honest terminal-external leaf, ol-gated on its sole pointer arg =      *)
  (* &(stack-local collisionData).  Decompose, not collapse: the opaque     *)
  (* internal whole-body residual is replaced by a walked body + 1 gated    *)
  (* terminal external one call-graph level down.                           *)
  (* ====================================================================== *)
  Hypothesis Holcp_fwc :
    call_pres_ext_ol lp bm NoA MWF SafeB mario._find_wall_collisions.
  Hypothesis Hw1cp_v3f :
    call_pres_ext_w1 lp bm NoA MWF mario_actions_automatic._vec3f_copy.

  (* ---- the resolve-body RECOGNIZER (the real AST's leaf vocabulary) ---- *)
  Definition rwc_call_chk (fid : ident) (fty : type) (al : list expr) : bool :=
    Pos.eqb fid mario._find_wall_collisions
    && proj_sumbool
         (type_eq fty
            (Tfunction (tptr (Tstruct mario._WallCollisionData noattr) :: nil)
               tint cc_default))
    && match al with
       | Eaddrof (Evar cd cdt) tya :: nil =>
           Pos.eqb cd mario._collisionData
           && proj_sumbool
                (type_eq cdt (Tstruct mario._WallCollisionData noattr))
           && proj_sumbool
                (type_eq tya (tptr (Tstruct mario._WallCollisionData noattr)))
       | _ => false
       end.

  (* per-leaf Sassign recognizer: a field store into the LOCAL collisionData
     struct, OR a pos[i] indexed store through the param pointer. *)
  Definition rwc_assign_chk (a1 : expr) : bool :=
    match a1 with
    | Efield (Evar cd cdt) fld fty =>
        Pos.eqb cd mario._collisionData
        && proj_sumbool (type_eq cdt (Tstruct mario._WallCollisionData noattr))
        && proj_sumbool (type_eq fty tfloat)
    | Ederef (Ebinop Oadd (Etempvar q tq) (Econst_int _ tci) _) ety =>
        Pos.eqb q mario._pos
        && proj_sumbool (type_eq tq (tptr tfloat))
        && proj_sumbool (type_eq tci tint)
        && proj_sumbool (type_eq ety tfloat)
    | _ => false
    end.

  Definition rwc_optid_ok (optid : option ident) : bool :=
    match optid with
    | Some id => negb (Pos.eqb id mario._pos)
    | None => true
    end.

  Fixpoint rwc_chk (s : statement) : bool :=
    match s with
    | Sskip | Sbreak | Scontinue => true
    | Sreturn _ => true
    | Ssequence s1 s2 => rwc_chk s1 && rwc_chk s2
    | Sifthenelse _ s1 s2 => rwc_chk s1 && rwc_chk s2
    | Sset id _ => rwc_optid_ok (Some id)
    | Sassign a1 _ => rwc_assign_chk a1
    | Scall optid (Evar fid fty) al =>
        rwc_optid_ok optid && rwc_call_chk fid fty al
    | _ => false
    end.

  (* the prog_defmap pin: resolve lives INTERNAL in mario.prog.  Keyed by the
     automatic-TU ident alias (idents are string-hashed, so it is the same
     positive as mario._resolve_and_return_wall_collisions). *)
  Lemma rwc_pin :
    (prog_defmap mario.prog)
      ! mario_actions_automatic._resolve_and_return_wall_collisions
    = Some (Gfun (Internal mario.f_resolve_and_return_wall_collisions)).
  Proof. vm_compute. reflexivity. Qed.

  (* NON-VACUITY: the recognizer accepts the REAL generated body. *)
  Lemma rwc_chk_body :
    rwc_chk (fn_body mario.f_resolve_and_return_wall_collisions) = true.
  Proof. vm_compute. reflexivity. Qed.

  Lemma rwc_assign_decode :
    forall a1, rwc_assign_chk a1 = true ->
      (exists fld,
          a1 = Efield (Evar mario._collisionData
                         (Tstruct mario._WallCollisionData noattr)) fld tfloat)
      \/
      (exists idxN ity,
          a1 = Ederef (Ebinop Oadd (Etempvar mario._pos (tptr tfloat))
                         (Econst_int idxN tint) ity) tfloat).
  Proof.
    intros a1 H. unfold rwc_assign_chk in H.
    destruct a1 as [ | | | | | | ed ety | | | | | base fld fty | | ];
      try discriminate H.
    - (* Ederef: the pos[i] arm *)
      right.
      destruct ed as [ | | | | | | | | | bop e1 e2 bty | | | | ];
        try discriminate H.
      destruct bop; try discriminate H.
      destruct e1 as [ | | | | | q tq | | | | | | | | ]; try discriminate H.
      destruct e2 as [ idxN tci | | | | | | | | | | | | | ];
        try discriminate H.
      apply andb_true_iff in H as [H Hety].
      apply andb_true_iff in H as [H Htci].
      apply andb_true_iff in H as [Hq Htq].
      apply Pos.eqb_eq in Hq; subst q.
      destruct (type_eq tq (tptr tfloat)) as [-> | ]; [ | discriminate Htq ].
      destruct (type_eq tci tint) as [-> | ]; [ | discriminate Htci ].
      destruct (type_eq ety tfloat) as [-> | ]; [ | discriminate Hety ].
      exists idxN, bty. reflexivity.
    - (* Efield: the collisionData.fld arm *)
      left.
      destruct base as [ | | | | cd cdt | | | | | | | | | ];
        try discriminate H.
      apply andb_true_iff in H as [H Hfty].
      apply andb_true_iff in H as [Hcd Hcdt].
      apply Pos.eqb_eq in Hcd; subst cd.
      destruct (type_eq cdt (Tstruct mario._WallCollisionData noattr))
        as [-> | ]; [ | discriminate Hcdt ].
      destruct (type_eq fty tfloat) as [-> | ]; [ | discriminate Hfty ].
      exists fld. reflexivity.
  Qed.

  Lemma rwc_call_decode :
    forall fid fty al, rwc_call_chk fid fty al = true ->
      fid = mario._find_wall_collisions /\
      fty = Tfunction (tptr (Tstruct mario._WallCollisionData noattr) :: nil)
              tint cc_default /\
      al = Eaddrof (Evar mario._collisionData
                      (Tstruct mario._WallCollisionData noattr))
             (tptr (Tstruct mario._WallCollisionData noattr)) :: nil.
  Proof.
    intros fid fty al H. unfold rwc_call_chk in H.
    apply andb_true_iff in H as [H Hal].
    apply andb_true_iff in H as [Hfid Hfty].
    apply Pos.eqb_eq in Hfid.
    destruct (type_eq fty
                (Tfunction
                   (tptr (Tstruct mario._WallCollisionData noattr) :: nil)
                   tint cc_default)) as [Efty | ]; [ | discriminate Hfty ].
    split; [ exact Hfid | ]. split; [ exact Efty | ].
    destruct al as [ | a0 al0 ]; try discriminate Hal.
    destruct a0 as [ | | | | | | | ae tya | | | | | | ];
      try discriminate Hal.
    destruct ae as [ | | | | cd cdt | | | | | | | | | ];
      try discriminate Hal.
    destruct al0; try discriminate Hal.
    apply andb_true_iff in Hal as [Hal Htya].
    apply andb_true_iff in Hal as [Hcd Hcdt].
    apply Pos.eqb_eq in Hcd; subst cd.
    destruct (type_eq cdt (Tstruct mario._WallCollisionData noattr))
      as [-> | ]; [ | discriminate Hcdt ].
    destruct (type_eq tya (tptr (Tstruct mario._WallCollisionData noattr)))
      as [-> | ]; [ | discriminate Htya ].
    reflexivity.
  Qed.

  (* base-pointer extraction: an EXECUTED q[i] indexed store forces le!q to
     hold a POINTER.  On ptr64=false an int base would make sem_add yield a
     Vint, never the Vptr the Ederef lvalue evaluation produced -- so the
     derivation itself pins the temp to some Vptr.  This is what lets the
     walker thread only the CONDITIONAL locality fact for the _pos param
     (the args_all_local gate constrains _pos only IF it is a pointer,
     unlike the mo-gate's unconditional last_arg_local binding). *)
  Lemma idx_base_ptr_of_exec :
    forall e q idxN itya ety2 a2 le m0 tr le' m' out,
      exec_stmt function_entry2 (lp_ge lp) e le m0
        (Sassign (Ederef (Ebinop Oadd (Etempvar q (tptr tfloat))
                            (Econst_int idxN tint) itya) ety2) a2)
        tr le' m' out ->
      exists lb oo, le ! q = Some (Vptr lb oo).
  Proof.
    intros e q idxN itya ety2 a2 le m0 tr le' m' out Hexec.
    inv Hexec.
    match goal with
    | Hlv : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hlv
    end.
    match goal with
    | Hp : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ => inv Hp
    end.
    2:{ match goal with
        | Hlv2 : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ => inv Hlv2
        end. }
    match goal with
    | Hi : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
        inv Hi;
        try (match goal with
             | Hlv3 : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ =>
                 inv Hlv3
             end)
    end.
    match goal with
    | Ha : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
        apply RealFrameValue.eval_expr_Etempvar_val in Ha
    end.
    match goal with
    | Hsem : sem_binary_operation _ _ ?V _ _ _ _ = Some (Vptr _ _),
      Hq : _ ! _ = Some ?V |- _ =>
        destruct V; cbn in Hsem;
        [ discriminate Hsem
        | destruct Archi.ptr64; discriminate Hsem
        | discriminate Hsem
        | discriminate Hsem
        | discriminate Hsem
        | eexists; eexists; exact Hq ]
    end.
  Qed.

  (* the CONDITIONAL twin of local_ptr_idx_assign_pres: locality of the base
     temp is assumed only IF it holds a pointer (the gate's honest shape for
     a pointer PARAM), and the executed derivation supplies the pointer. *)
  Lemma local_ptr_idx_assign_pres_cond :
    forall e q idxN itya ety2 a2 le m0 tr le' m' out ch,
      (forall b o, le ! q = Some (Vptr b o) -> local_blk lp bm SafeB b) ->
      access_mode ety2 = By_value ch ->
      exec_stmt function_entry2 (lp_ge lp) e le m0
        (Sassign (Ederef (Ebinop Oadd (Etempvar q (tptr tfloat))
                            (Econst_int idxN tint) itya) ety2) a2)
        tr le' m' out ->
      carried bm NoA MWF m0 ->
      carried bm NoA MWF m' /\ le' = le /\ out = Out_normal.
  Proof.
    intros e q idxN itya ety2 a2 le m0 tr le' m' out ch Hcond Hacc Hexec Hc.
    destruct (idx_base_ptr_of_exec _ _ _ _ _ _ _ _ _ _ _ _ Hexec)
      as (lb & oo & Hq).
    exact (local_ptr_idx_assign_pres lp bm NoA MWF SafeB Hls_real HNoA_of_MWF
             _ _ _ _ _ _ _ _ _ _ _ _ lb oo _
             Hq (Hcond _ _ Hq) Hacc Hexec Hc).
  Qed.

  (* ====================================================================== *)
  (* THE rwc WALKER: any rwc_chk-passing statement, executed under the      *)
  (* resolve entry env (e!_collisionData = a local stack block, _pos local- *)
  (* if-pointer, find_wall_collisions unbound), preserves carried.          *)
  (* ====================================================================== *)
  Lemma rwc_walk_pres :
    forall lcd tycd,
      local_blk lp bm SafeB lcd ->
      forall s e le m0 tr le' m' out,
        exec_stmt function_entry2 (lp_ge lp) e le m0 s tr le' m' out ->
        rwc_chk s = true ->
        e ! mario._find_wall_collisions = None ->
        e ! mario._collisionData = Some (lcd, tycd) ->
        (forall b o, le ! mario._pos = Some (Vptr b o) ->
                     local_blk lp bm SafeB b) ->
        carried bm NoA MWF m0 ->
        carried bm NoA MWF m' /\
        (forall b o, le' ! mario._pos = Some (Vptr b o) ->
                     local_blk lp bm SafeB b).
  Proof.
    intros lcd tycd Hlcd s e le m0 tr le' m' out Hexec.
    induction Hexec; intros Hchk Hfwc Hcd Hpos Hc.
    - (* Sskip *) exact (conj Hc Hpos).
    - (* Sassign a1 a2 *)
      cbn [rwc_chk] in Hchk.
      assert (Hex : exec_stmt function_entry2 (lp_ge lp) e le m
                      (Sassign a1 a2) E0 le m' Out_normal)
        by (econstructor; eauto).
      destruct (rwc_assign_decode _ Hchk)
        as [ (fld & ->) | (idxN & ity & ->) ].
      + (* collisionData.fld = a2 : store into the local struct *)
        destruct (local_field_assign_pres lp bm NoA MWF SafeB Hls_real
                    HNoA_of_MWF e mario._collisionData
                    mario._WallCollisionData noattr tycd fld tfloat
                    a2 le m _ _ m' _ lcd Mfloat32
                    Hcd Hlcd eq_refl Hex Hc) as (Hc' & _ & _).
        exact (conj Hc' Hpos).
      + (* pos[i] = a2 : store through the conditionally-local param ptr *)
        destruct (local_ptr_idx_assign_pres_cond e mario._pos idxN ity tfloat
                    a2 le m _ _ m' _ Mfloat32 Hpos eq_refl Hex Hc)
          as (Hc' & _ & _).
        exact (conj Hc' Hpos).
    - (* Sset id a: id <> _pos (rwc_optid_ok) *)
      cbn [rwc_chk rwc_optid_ok] in Hchk.
      apply negb_true_iff in Hchk.
      refine (conj Hc _).
      intros b o Hg.
      rewrite PTree.gso in Hg
        by (intro EE; subst id; rewrite Pos.eqb_refl in Hchk;
            discriminate Hchk).
      exact (Hpos b o Hg).
    - (* Scall optid a al *)
      cbn [rwc_chk] in Hchk.
      destruct a as [ | | | | fid fty | | | | | | | | | ];
        try discriminate Hchk.
      apply andb_true_iff in Hchk as [Hopt Hcc].
      assert (Hex : exec_stmt function_entry2 (lp_ge lp) e le m
                      (Scall optid (Evar fid fty) al) t
                      (set_opttemp optid vres le) m' Out_normal)
        by (econstructor; eauto).
      assert (HposL : forall b o,
                 (set_opttemp optid vres le) ! mario._pos = Some (Vptr b o) ->
                 local_blk lp bm SafeB b).
      { cbn [rwc_optid_ok] in Hopt.
        destruct optid as [oid | ]; cbn [set_opttemp].
        - apply negb_true_iff in Hopt.
          intros b o Hg.
          rewrite PTree.gso in Hg
            by (intro EE; subst oid; rewrite Pos.eqb_refl in Hopt;
                discriminate Hopt).
          exact (Hpos b o Hg).
        - exact Hpos. }
      destruct (rwc_call_decode _ _ _ Hcc) as (-> & -> & ->).
      assert (Hgate : forall vargs,
          eval_exprlist (lp_ge lp) e le m
            (Eaddrof (Evar mario._collisionData
                        (Tstruct mario._WallCollisionData noattr))
               (tptr (Tstruct mario._WallCollisionData noattr)) :: nil)
            (tptr (Tstruct mario._WallCollisionData noattr) :: nil) vargs ->
          args_all_local lp bm SafeB vargs).
      { intros vargs0 Hvl.
        inversion Hvl as [ | a1 bl1 ty1 tyl1 v1a v2a vl1 Hev_a Hsc_a Htl1 ];
          subst; clear Hvl.
        inversion Htl1; subst; clear Htl1.
        intros bb oo Hin; cbn in Hin.
        destruct Hin as [E | []]; subst v2a.
        apply RealFrameValue.sem_cast_ptr_result_inv in Hsc_a; subst v1a.
        inv Hev_a;
          [ | match goal with
              | Hlv : eval_lvalue _ _ _ _ (Eaddrof _ _) _ _ _ |- _ =>
                  inv Hlv
              end ].
        match goal with
        | Hlv : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inv Hlv
        end;
        [ match goal with
          | Hb : e ! mario._collisionData = Some _ |- _ =>
              rewrite Hcd in Hb; injection Hb as <- _; exact Hlcd
          end
        | match goal with
          | Hn : e ! mario._collisionData = None |- _ =>
              rewrite Hcd in Hn; discriminate Hn
          end ]. }
      destruct (ol_scall_pres lp bm NoA MWF SafeB optid
                  mario._find_wall_collisions
                  (tptr (Tstruct mario._WallCollisionData noattr) :: nil)
                  tint cc_default
                  (Eaddrof (Evar mario._collisionData
                              (Tstruct mario._WallCollisionData noattr))
                     (tptr (Tstruct mario._WallCollisionData noattr)) :: nil)
                  e le m _ _ m' _ Hfwc Holcp_fwc Hgate Hex Hc) as (Hc' & _).
      exact (conj Hc' HposL).
    - (* Sbuiltin: rejected *)
      cbn [rwc_chk] in Hchk. discriminate Hchk.
    - (* Sseq_1 *)
      cbn [rwc_chk] in Hchk. apply andb_true_iff in Hchk as [H1 H2].
      destruct (IHHexec1 H1 Hfwc Hcd Hpos Hc) as (Hc1 & Hpos1).
      exact (IHHexec2 H2 Hfwc Hcd Hpos1 Hc1).
    - (* Sseq_2 *)
      cbn [rwc_chk] in Hchk. apply andb_true_iff in Hchk as [H1 _].
      exact (IHHexec H1 Hfwc Hcd Hpos Hc).
    - (* Sifthenelse *)
      cbn [rwc_chk] in Hchk. apply andb_true_iff in Hchk as [H1 H2].
      apply IHHexec; try assumption.
      destruct b; assumption.
    - (* Sreturn None *) exact (conj Hc Hpos).
    - (* Sreturn (Some _) *) exact (conj Hc Hpos).
    - (* Sbreak *) exact (conj Hc Hpos).
    - (* Scontinue *) exact (conj Hc Hpos).
    - (* Sloop stop1 *) cbn [rwc_chk] in Hchk. discriminate Hchk.
    - (* Sloop stop2 *) cbn [rwc_chk] in Hchk. discriminate Hchk.
    - (* Sloop loop *) cbn [rwc_chk] in Hchk. discriminate Hchk.
    - (* Sswitch: rejected *)
      cbn [rwc_chk] in Hchk. discriminate Hchk.
  Qed.

  (* ====================================================================== *)
  (* THE ENTRY LEMMA: resolve's whole body preserves carried under the      *)
  (* args_all_local gate.  function_entry2 allocs the ONE fn_var            *)
  (* _collisionData (alloc_variables_hlocal -> local stack block) and binds *)
  (* _pos/_offset/_radius; the gate gives _pos's conditional locality; the  *)
  (* walker walks the body; free_list at exit.                              *)
  (* ====================================================================== *)
  Lemma rwc_body_pres_ol :
    body_pres_ol lp bm NoA MWF SafeB
      mario.f_resolve_and_return_wall_collisions.
  Proof.
    intros m0 vargs0 t0 mF vres0 Hgate Hevf HN HM HV HS.
    (* ---- entry ---- *)
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ =>
      rename He into Hentry end.
    match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
      rename Hx into Hbody end.
    match goal with Hf : Mem.free_list _ _ = Some _ |- _ =>
      rename Hf into Hfree end.
    inv Hentry.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
      rename Ha into Halloc end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ =>
      rename Hb into Hbind end.
    unfold mario.f_resolve_and_return_wall_collisions in Hbind, Halloc.
    cbn [fn_params fn_temps fn_vars] in Hbind, Halloc.
    match goal with H : alloc_variables _ _ _ _ ?E ?ME |- _ =>
      set (eloc := E) in *; set (me := ME) in * end.
    assert (Hc0 : carried bm NoA MWF m0)
      by (split; [ exact HV | split; [ exact HS
                 | split; [ exact HM | exact HN ] ] ]).
    pose proof (alloc_variables_carried bm NoA MWF HMWF_alloc HNoA_of_MWF
                  _ _ _ _ _ _ Halloc Hc0) as Hcar.
    (* the _collisionData fn_var is a watched-disjoint stack block *)
    assert (Hcdx : exists lblk tyenv,
               eloc ! mario._collisionData = Some (lblk, tyenv) /\
               local_blk lp bm SafeB lblk).
    { apply (alloc_variables_hlocal lp bm SafeB m0 _ eloc _
               (mario._collisionData :: nil)
               Halloc HV (HSafeValid m0 HM) (HGlobValid m0 HM)
               ltac:(intros lid Hmem; unfold mem_id in Hmem;
                     cbn [existsb] in Hmem;
                     apply Bool.orb_true_iff in Hmem;
                     destruct Hmem as [He | Hf];
                     [ apply Pos.eqb_eq in He; subst lid; cbn [map fst];
                       apply in_eq
                     | discriminate Hf ])).
      vm_compute. reflexivity. }
    destruct Hcdx as (lcd & tycd & Hcd & Hlcd).
    (* bind the 3 params _pos / _offset / _radius *)
    destruct vargs0 as [| v_pos vr1];
      cbn [bind_parameter_temps] in Hbind; [ discriminate Hbind | ].
    destruct vr1 as [| v_off vr2];
      cbn [bind_parameter_temps] in Hbind; [ discriminate Hbind | ].
    destruct vr2 as [| v_rad vr3];
      cbn [bind_parameter_temps] in Hbind; [ discriminate Hbind | ].
    destruct vr3; [ | cbn [bind_parameter_temps] in Hbind;
                      discriminate Hbind ].
    injection Hbind as Hle_init.
    assert (Hposeq : le1 ! mario._pos = Some v_pos)
      by (rewrite <- Hle_init;
          rewrite PTree.gso by (vm_compute; discriminate);
          rewrite PTree.gso by (vm_compute; discriminate);
          apply PTree.gss).
    (* _pos's CONDITIONAL locality from the args_all_local gate *)
    unfold args_all_local in Hgate.
    assert (Hposc : forall b o, le1 ! mario._pos = Some (Vptr b o) ->
                    local_blk lp bm SafeB b).
    { intros b o Hg. rewrite Hposeq in Hg. injection Hg as Hg.
      apply (Hgate b o). rewrite Hg. apply in_eq. }
    (* the callee is an unbound global in the entry env *)
    assert (Hfwc : eloc ! mario._find_wall_collisions = None).
    { rewrite (alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc
                 mario._find_wall_collisions)
        by (cbn; intros [HH | []]; vm_compute in HH; discriminate HH).
      apply PTree.gempty. }
    (* ---- WALK the body ---- *)
    destruct (rwc_walk_pres lcd tycd Hlcd _ _ _ _ _ _ _ _
                Hbody rwc_chk_body Hfwc Hcd Hposc Hcar)
      as (Hcarr & _).
    (* ---- exit: free the fn_var stack block ---- *)
    destruct Hcarr as (HVb & HSb & HMb & HNb).
    pose proof (blocks_of_env_bm lp bm m0 _ eloc _ Halloc HV) as Hforall.
    pose proof (free_list_carried_bm bm NoA MWF HMWF_free HNoA_of_MWF
                  (blocks_of_env (lp_ge lp) eloc) _ mF Hforall Hfree
                  (conj HVb (conj HSb (conj HMb HNb))))
      as (HVf & HSf & HMf & HNf).
    exact (conj HVf (conj HSf HMf)).
  Qed.

  (* THE DISCHARGE: lift the per-body walk to the ol residual via the
     producer + the prog_defmap pin.  Hocp_resolve is now PROVED (was a
     Hypothesis), resting on the ONE terminal-external row Holcp_fwc.
     php_walk_pres below consumes it verbatim. *)
  Lemma Hocp_resolve :
    call_pres_ext_ol lp bm NoA MWF SafeB
      mario_actions_automatic._resolve_and_return_wall_collisions.
  Proof.
    eapply call_pres_ext_ol_of_body.
    - exact HNoA_of_MWF.
    - exact LO_mario.
    - exact rwc_pin.
    - exact rwc_body_pres_ol.
  Qed.

  (* ---- STAGE 3 decode helpers + the exec-derivation WALKER (php) ---- *)

  Lemma php_assign_decode :
    forall a1, php_assign_chk a1 = true ->
      safe_mfield_store mario_actions_automatic._m a1 = true \/
      exists idxN ity,
        a1 = Ederef (Ebinop Oadd
                       (Etempvar mario_actions_automatic._nextPos (tptr tfloat))
                       (Econst_int idxN tint) ity) tfloat.
  Proof.
    intros a1 H. unfold php_assign_chk in H.
    apply orb_true_iff in H as [Hsf | Hns]; [ left; exact Hsf | right ].
    destruct a1 as [ | | | | | | ed ety | | | | | | | ]; try discriminate Hns.
    destruct ed as [ | | | | | | | | | bop e1 e2 bty | | | | ]; try discriminate Hns.
    destruct bop; try discriminate Hns.
    destruct e1 as [ | | | | | q tq | | | | | | | | ]; try discriminate Hns.
    destruct e2 as [ idxN tci | | | | | | | | | | | | | ]; try discriminate Hns.
    apply andb_true_iff in Hns as [Hns Hety].
    apply andb_true_iff in Hns as [Hns Htci].
    apply andb_true_iff in Hns as [Hq Htq].
    apply Pos.eqb_eq in Hq; subst q.
    destruct (type_eq tq (tptr tfloat)) as [Eq1 | ]; [ | discriminate Htq ].
    destruct (type_eq tci tint) as [Eq2 | ]; [ | discriminate Htci ].
    destruct (type_eq ety tfloat) as [Eq3 | ]; [ | discriminate Hety ].
    subst tq tci ety. exists idxN, bty. reflexivity.
  Qed.

  Lemma php_call_decode :
    forall fid fty al, php_call_chk fid fty al = true ->
      oc_call_chk
        (mario_actions_automatic._floor :: mario_actions_automatic._ceil :: nil)
        (mario_actions_automatic._find_floor
           :: mario_actions_automatic._vec3f_find_ceil :: nil) fid fty al = true
      \/ (fid = mario_actions_automatic._resolve_and_return_wall_collisions /\
          fty = Tfunction (tptr tfloat :: tfloat :: tfloat :: nil)
                  (tptr (Tstruct mario_actions_automatic._Surface noattr)) cc_default /\
          exists c1 t1 c2 t2,
            al = Etempvar mario_actions_automatic._nextPos (tptr tfloat)
                 :: Econst_single c1 t1 :: Econst_single c2 t2 :: nil)
      \/ (fid = mario_actions_automatic._vec3f_copy /\
          fty = Tfunction (tptr tfloat :: tptr tfloat :: nil) (tptr tvoid) cc_default /\
          exists q tq,
            al = Efield
                   (Ederef (Etempvar mario_actions_automatic._m
                              (tptr (Tstruct mario_actions_automatic._MarioState noattr)))
                      (Tstruct mario_actions_automatic._MarioState noattr))
                   mario_actions_automatic._pos (tarray tfloat 3)
                 :: Etempvar q tq :: nil).
  Proof.
    intros fid fty al H. unfold php_call_chk in H.
    apply orb_true_iff in H as [H | Hv3f].
    apply orb_true_iff in H as [Hoc | Hres].
    - left; exact Hoc.
    - right; left.
      apply andb_true_iff in Hres as [Hr12 Hres].
      apply andb_true_iff in Hr12 as [Hfid Hfty].
      apply Pos.eqb_eq in Hfid.
      destruct (type_eq fty
                  (Tfunction (tptr tfloat :: tfloat :: tfloat :: nil)
                     (tptr (Tstruct mario_actions_automatic._Surface noattr))
                     cc_default)) as [Efty | ]; [ | discriminate Hfty ].
      split; [ exact Hfid | ]. split; [ exact Efty | ].
      destruct al as [ | a0 al0 ]; try discriminate Hres.
      destruct a0 as [ | | | | | q tq | | | | | | | | ]; try discriminate Hres.
      destruct al0 as [ | a1 al1 ]; try discriminate Hres.
      destruct a1 as [ | | c1 t1 | | | | | | | | | | | ]; try discriminate Hres.
      destruct al1 as [ | a2 al2 ]; try discriminate Hres.
      destruct a2 as [ | | c2 t2 | | | | | | | | | | | ]; try discriminate Hres.
      destruct al2; try discriminate Hres.
      apply andb_true_iff in Hres as [Hq Htq].
      apply Pos.eqb_eq in Hq; subst q.
      destruct (type_eq tq (tptr tfloat)) as [Eq | ]; [ subst tq | discriminate Htq ].
      exists c1, t1, c2, t2. reflexivity.
    - right; right.
      apply andb_true_iff in Hv3f as [Hv12 Hv3f].
      apply andb_true_iff in Hv12 as [Hfid Hfty].
      apply Pos.eqb_eq in Hfid.
      destruct (type_eq fty
                  (Tfunction (tptr tfloat :: tptr tfloat :: nil) (tptr tvoid)
                     cc_default)) as [Efty | ]; [ | discriminate Hfty ].
      split; [ exact Hfid | ]. split; [ exact Efty | ].
      destruct al as [ | a0 al0 ]; try discriminate Hv3f.
      destruct a0 as [ | | | | | | | | | | | inner efd eft2 | | ]; try discriminate Hv3f.
      destruct inner as [ | | | | | | edb edt | | | | | | | ]; try discriminate Hv3f.
      destruct edb as [ | | | | | mp tmp | | | | | | | | ]; try discriminate Hv3f.
      destruct al0 as [ | a1 al1 ]; try discriminate Hv3f.
      destruct a1 as [ | | | | | q tq | | | | | | | | ]; try discriminate Hv3f.
      destruct al1; try discriminate Hv3f.
      apply andb_true_iff in Hv3f as [Hv3f Htfa].
      apply andb_true_iff in Hv3f as [Hv3f Htsm].
      apply andb_true_iff in Hv3f as [Hv3f Htmp].
      apply andb_true_iff in Hv3f as [Hv3f _].
      apply andb_true_iff in Hv3f as [Hmp Hfld].
      apply Pos.eqb_eq in Hmp; subst mp.
      apply Pos.eqb_eq in Hfld; subst efd.
      destruct (type_eq tmp (tptr (Tstruct mario_actions_automatic._MarioState noattr)))
        as [E1 | ]; [ subst tmp | discriminate Htmp ].
      destruct (type_eq edt (Tstruct mario_actions_automatic._MarioState noattr))
        as [E2 | ]; [ subst edt | discriminate Htsm ].
      destruct (type_eq eft2 (tarray tfloat 3))
        as [E3 | ]; [ subst eft2 | discriminate Htfa ].
      exists q, tq. reflexivity.
  Qed.

  (* ====================================================================== *)
  (* THE WALKER: any php_chk-passing statement, executed under the mo-gate  *)
  (* env (le!_m = (bm,0), le!_nextPos = a local, the _floor/_ceil fn_vars   *)
  (* local, the 4 callees unbound), preserves carried -- WHATEVER its       *)
  (* outcome.  Induction over the EXEC DERIVATION absorbs the 6 early-return *)
  (* guards uniformly (each Sreturn/Sif is a base/IH case).                  *)
  (* ====================================================================== *)
  Lemma php_walk_pres :
    forall npb npo,
      local_blk lp bm SafeB npb ->
      forall s e le m0 tr le' m' out,
        exec_stmt function_entry2 (lp_ge lp) e le m0 s tr le' m' out ->
        php_chk s = true ->
        e ! mario_actions_automatic._resolve_and_return_wall_collisions = None ->
        e ! mario_actions_automatic._find_floor = None ->
        e ! mario_actions_automatic._vec3f_find_ceil = None ->
        e ! mario_actions_automatic._vec3f_copy = None ->
        (forall l, mem_id l (mario_actions_automatic._floor
                             :: mario_actions_automatic._ceil :: nil) = true ->
           exists lblk tyenv, e ! l = Some (lblk, tyenv) /\
                              local_blk lp bm SafeB lblk) ->
        (forall b o, le ! mario_actions_automatic._m = Some (Vptr b o) ->
                     b = bm /\ o = Ptrofs.zero) ->
        le ! mario_actions_automatic._nextPos = Some (Vptr npb npo) ->
        carried bm NoA MWF m0 ->
        carried bm NoA MWF m' /\
        (forall b o, le' ! mario_actions_automatic._m = Some (Vptr b o) ->
                     b = bm /\ o = Ptrofs.zero) /\
        le' ! mario_actions_automatic._nextPos = Some (Vptr npb npo).
  Proof.
    intros npb npo Hnploc s e le m0 tr le' m' out Hexec.
    induction Hexec; intros Hchk Hrn Hff Hvfc Hvc Hlids Hm Hnp Hc.
    - (* Sskip *) exact (conj Hc (conj Hm Hnp)).
    - (* Sassign a1 a2 *)
      cbn [php_chk] in Hchk.
      assert (Hex : exec_stmt function_entry2 (lp_ge lp) e le m
                      (Sassign a1 a2) E0 le m' Out_normal)
        by (econstructor; eauto).
      destruct (php_assign_decode _ Hchk) as [Hsf | (idxN & ity & ->)].
      + (* marg Mario-field store: value-blind epi *)
        destruct Hc as (HV & HS & HM & HN).
        destruct (epi_assign_pres lp LO_mario bm MWF HMWF_window
                    a1 a2 _ _ _ _ _ _ _ Hsf Hm Hex HM HV HS)
          as (HV' & HS' & HM' & _ & _).
        exact (conj (conj HV' (conj HS' (conj HM' (HNoA_of_MWF _ HM'))))
                 (conj Hm Hnp)).
      + (* nextPos[i] indexed local-out-param store *)
        destruct (local_ptr_idx_assign_pres lp bm NoA MWF SafeB Hls_real
                    HNoA_of_MWF e mario_actions_automatic._nextPos idxN ity tfloat
                    a2 le m _ _ m' _ npb npo Mfloat32
                    Hnp Hnploc eq_refl Hex Hc) as (Hc' & _ & _).
        exact (conj Hc' (conj Hm Hnp)).
    - (* Sset id a: id <> _m, _nextPos (php_optid_ok) *)
      cbn [php_chk php_optid_ok] in Hchk.
      apply andb_true_iff in Hchk as [Hnm Hnnp].
      apply negb_true_iff in Hnm; apply negb_true_iff in Hnnp.
      refine (conj Hc (conj _ _)).
      + intros b o Hg.
        rewrite PTree.gso in Hg by (intro EE; subst id; rewrite Pos.eqb_refl in Hnm;
                                    discriminate Hnm).
        exact (Hm b o Hg).
      + rewrite PTree.gso by (intro EE; subst id; rewrite Pos.eqb_refl in Hnnp;
                              discriminate Hnnp).
        exact Hnp.
    - (* Scall optid a tyargs el vargs *)
      cbn [php_chk] in Hchk.
      destruct a as [ | | | | fid fty | | | | | | | | | ]; try discriminate Hchk.
      (* a = Evar fid fty *)
      apply andb_true_iff in Hchk as [Hopt Hcc].
      assert (Hex : exec_stmt function_entry2 (lp_ge lp) e le m
                      (Scall optid (Evar fid fty) al) t (set_opttemp optid vres le)
                      m' Out_normal)
        by (econstructor; eauto).
      (* le' = set_opttemp optid vres le; optid avoids _m,_nextPos via Hopt *)
      assert (HmL : (forall b o,
                       (set_opttemp optid vres le) ! mario_actions_automatic._m
                       = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero) /\
                    (set_opttemp optid vres le) ! mario_actions_automatic._nextPos
                    = Some (Vptr npb npo)).
      { cbn [php_optid_ok] in Hopt.
        destruct optid as [oid | ]; cbn [set_opttemp].
        - apply andb_true_iff in Hopt as [Hom Honp].
          apply negb_true_iff in Hom; apply negb_true_iff in Honp.
          split.
          + intros b o Hg. rewrite PTree.gso in Hg by (intro EE; subst oid;
              rewrite Pos.eqb_refl in Hom; discriminate Hom). exact (Hm b o Hg).
          + rewrite PTree.gso by (intro EE; subst oid;
              rewrite Pos.eqb_refl in Honp; discriminate Honp). exact Hnp.
        - split; [ exact Hm | exact Hnp ]. }
      destruct (php_call_decode _ _ _ Hcc)
        as [Hoc | [ (Hfeq & Hftyeq & c1 & t1 & c2 & t2 & ->)
                  | (Hfeq & Hftyeq & q & tq & ->) ]].
      + (* oc: find_floor / vec3f_find_ceil *)
        assert (Hcp_oc : forall g,
                  mem_id g (mario_actions_automatic._find_floor
                            :: mario_actions_automatic._vec3f_find_ceil :: nil)
                    = true -> call_pres_ext_oc lp bm NoA MWF SafeB g).
        { intros g Hg. cbn [mem_id existsb] in Hg.
          apply orb_true_iff in Hg as [Eg | Hg];
            [ apply Pos.eqb_eq in Eg; subst g; exact Hocp_find_floor | ].
          apply orb_true_iff in Hg as [Eg | F];
            [ apply Pos.eqb_eq in Eg; subst g; exact Hocp_find_ceil
            | discriminate F ]. }
        assert (Hnone : forall g,
                  mem_id g (mario_actions_automatic._find_floor
                            :: mario_actions_automatic._vec3f_find_ceil :: nil)
                    = true -> e ! g = None).
        { intros g Hg. cbn [mem_id existsb] in Hg.
          apply orb_true_iff in Hg as [Eg | Hg];
            [ apply Pos.eqb_eq in Eg; subst g; exact Hff | ].
          apply orb_true_iff in Hg as [Eg | F];
            [ apply Pos.eqb_eq in Eg; subst g; exact Hvfc | discriminate F ]. }
        destruct (oc_call_chk_pres lp bm NoA MWF SafeB
                    (mario_actions_automatic._floor
                       :: mario_actions_automatic._ceil :: nil)
                    (mario_actions_automatic._find_floor
                       :: mario_actions_automatic._vec3f_find_ceil :: nil)
                    optid fid fty al e le m _ _ m' _
                    Hcp_oc Hnone Hlids Hoc Hex Hc) as (Hc' & _).
        exact (conj Hc' (conj (proj1 HmL) (proj2 HmL))).
      + (* ol: resolve_and_return_wall_collisions(nextPos, 1.0f, 1.0f) *)
        subst fid fty.
        assert (Hgate : forall vargs,
            eval_exprlist (lp_ge lp) e le m
              (Etempvar mario_actions_automatic._nextPos (tptr tfloat)
               :: Econst_single c1 t1 :: Econst_single c2 t2 :: nil)
              (tptr tfloat :: tfloat :: tfloat :: nil) vargs ->
            args_all_local lp bm SafeB vargs).
        { intros vargs0 Hvl.
          inversion Hvl as [ | a1 bl1 ty1 tyl1 v1a v2a vl1 Hev_a Hsc_a Htl1 ];
            subst; clear Hvl.
          inversion Htl1 as [ | a2 bl2 ty2 tyl2 v1b v2b vl2 Hev_b Hsc_b Htl2 ];
            subst; clear Htl1.
          inversion Htl2 as [ | a3 bl3 ty3 tyl3 v1c v2c vl3 Hev_c Hsc_c Htl3 ];
            subst; clear Htl2.
          inversion Htl3; subst; clear Htl3.
          apply RealFrameValue.eval_expr_Etempvar_val in Hev_a;
            rewrite Hnp in Hev_a; injection Hev_a as <-.
          apply eval_Econst_single_val in Hev_b; subst v1b.
          apply eval_Econst_single_val in Hev_c; subst v1c.
          intros bb oo Hin; cbn in Hin.
          destruct Hin as [E | [E | [E | []]]]; subst;
          [ apply RealFrameValue.sem_cast_ptr_result_inv in Hsc_a;
            injection Hsc_a as <- <-; exact Hnploc
          | apply RealFrameValue.sem_cast_ptr_result_inv in Hsc_b; discriminate Hsc_b
          | apply RealFrameValue.sem_cast_ptr_result_inv in Hsc_c; discriminate Hsc_c ]. }
        destruct (ol_scall_pres lp bm NoA MWF SafeB optid
                    mario_actions_automatic._resolve_and_return_wall_collisions
                    (tptr tfloat :: tfloat :: tfloat :: nil)
                    (tptr (Tstruct mario_actions_automatic._Surface noattr)) cc_default
                    (Etempvar mario_actions_automatic._nextPos (tptr tfloat)
                     :: Econst_single c1 t1 :: Econst_single c2 t2 :: nil)
                    e le m _ _ m' _ Hrn Hocp_resolve Hgate
                    Hex Hc) as (Hc' & _).
        exact (conj Hc' (conj (proj1 HmL) (proj2 HmL))).
      + (* w1: vec3f_copy(&m->pos, nextPos), dst = m->pos window *)
        subst fid fty.
        assert (Hgate : forall vargs,
            eval_exprlist (lp_ge lp) e le m
              (Efield
                 (Ederef (Etempvar mario_actions_automatic._m
                            (tptr (Tstruct mario_actions_automatic._MarioState noattr)))
                    (Tstruct mario_actions_automatic._MarioState noattr))
                 mario_actions_automatic._pos (tarray tfloat 3)
               :: Etempvar q tq :: nil)
              (tptr tfloat :: tptr tfloat :: nil) vargs ->
            arg0_window bm vargs).
        { intros vargs0 Hvl.
          inversion Hvl as [ | a1 bl1 ty1 tyl1 v1a v2a vl1 Hev_a Hsc_a Htl1 ];
            subst; clear Hvl.
          destruct (pos_window_val _ _ _ _ Hm Hev_a) as (o0 & Ev0 & Hwin0).
          subst v1a. cbn in Hsc_a. injection Hsc_a as <-.
          red. exists o0, vl1. split; [ reflexivity | exact Hwin0 ]. }
        destruct (w1_scall_pres lp bm NoA MWF optid mario_actions_automatic._vec3f_copy
                    (tptr tfloat :: tptr tfloat :: nil) (tptr tvoid) cc_default
                    (Efield
                       (Ederef (Etempvar mario_actions_automatic._m
                                  (tptr (Tstruct mario_actions_automatic._MarioState noattr)))
                          (Tstruct mario_actions_automatic._MarioState noattr))
                       mario_actions_automatic._pos (tarray tfloat 3)
                     :: Etempvar q tq :: nil)
                    e le m _ _ m' _ Hvc Hw1cp_v3f Hgate
                    Hex Hc) as (Hc' & _).
        exact (conj Hc' (conj (proj1 HmL) (proj2 HmL))).
    - (* Sbuiltin: rejected *)
      cbn [php_chk] in Hchk. discriminate Hchk.
    - (* Sseq_1 *)
      cbn [php_chk] in Hchk. apply andb_true_iff in Hchk as [H1 H2].
      destruct (IHHexec1 H1 Hrn Hff Hvfc Hvc Hlids Hm Hnp Hc)
        as (Hc1 & Hm1 & Hnp1).
      exact (IHHexec2 H2 Hrn Hff Hvfc Hvc Hlids Hm1 Hnp1 Hc1).
    - (* Sseq_2 *)
      cbn [php_chk] in Hchk. apply andb_true_iff in Hchk as [H1 _].
      exact (IHHexec H1 Hrn Hff Hvfc Hvc Hlids Hm Hnp Hc).
    - (* Sifthenelse *)
      cbn [php_chk] in Hchk. apply andb_true_iff in Hchk as [H1 H2].
      apply IHHexec; try assumption.
      destruct b; assumption.
    - (* Sreturn None *) exact (conj Hc (conj Hm Hnp)).
    - (* Sreturn (Some _) *) exact (conj Hc (conj Hm Hnp)).
    - (* Sbreak *) exact (conj Hc (conj Hm Hnp)).
    - (* Scontinue *) exact (conj Hc (conj Hm Hnp)).
    - (* Sloop stop1 *) cbn [php_chk] in Hchk. discriminate Hchk.
    - (* Sloop stop2 *) cbn [php_chk] in Hchk. discriminate Hchk.
    - (* Sloop loop *) cbn [php_chk] in Hchk. discriminate Hchk.
    - (* Sswitch: rejected *)
      cbn [php_chk] in Hchk. discriminate Hchk.
  Qed.

  (* ====================================================================== *)
  (* THE ENTRY LEMMA: perform_hanging_step's whole body preserves carried   *)
  (* under the mo-gate.  function_entry2 allocs _filler/_ceil/_floor and     *)
  (* binds _m/_nextPos; arg0_marg gives the _m conditional, last_arg_local   *)
  (* the _nextPos = local out-param; alloc_variables_hlocal gives the        *)
  (* _floor/_ceil fn_var locality (the walker's Hlids); the 4 callees are    *)
  (* unbound globals.  php_walk_pres then walks the body; free at exit.      *)
  (* ====================================================================== *)
  Lemma php_body_pres_mo :
    body_pres_mo lp bm NoA MWF SafeB
      mario_actions_automatic.f_perform_hanging_step.
  Proof.
    intros m0 vargs0 t0 mF vres0 Hgate Hevf HN HM HV HS.
    destruct Hgate as (Hcond & Hlast).
    (* ---- entry ---- *)
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ =>
      rename He into Hentry end.
    match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
      rename Hx into Hbody end.
    match goal with Hf : Mem.free_list _ _ = Some _ |- _ =>
      rename Hf into Hfree end.
    inv Hentry.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
      rename Ha into Halloc end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ =>
      rename Hb into Hbind end.
    unfold mario_actions_automatic.f_perform_hanging_step in Hbind, Halloc.
    cbn [fn_params fn_temps fn_vars] in Hbind, Halloc.
    match goal with H : alloc_variables _ _ _ _ ?E ?ME |- _ =>
      set (eloc := E) in *; set (me := ME) in * end.
    assert (Hc0 : carried bm NoA MWF m0)
      by (split; [ exact HV | split; [ exact HS
                 | split; [ exact HM | exact HN ] ] ]).
    pose proof (alloc_variables_carried bm NoA MWF HMWF_alloc HNoA_of_MWF
                  _ _ _ _ _ _ Halloc Hc0) as Hce.
    destruct Hce as (HVe & HSe & HMe & HNe).
    (* the _floor/_ceil fn_vars are watched-disjoint stack blocks (Hlids) *)
    pose proof (alloc_variables_hlocal lp bm SafeB m0 _ eloc _
                  (mario_actions_automatic._floor
                     :: mario_actions_automatic._ceil :: nil)
                  Halloc HV (HSafeValid m0 HM) (HGlobValid m0 HM)
                  ltac:(intros lid Hmem; unfold mem_id in Hmem;
                        cbn [existsb] in Hmem;
                        apply Bool.orb_true_iff in Hmem; destruct Hmem as [He | Hmem];
                        [ apply Pos.eqb_eq in He; subst lid; cbn [map fst];
                          apply in_cons; apply in_cons; apply in_eq
                        | apply Bool.orb_true_iff in Hmem; destruct Hmem as [He | Hf];
                          [ apply Pos.eqb_eq in He; subst lid; cbn [map fst];
                            apply in_cons; apply in_eq
                          | discriminate Hf ] ]))
      as Hlids.
    (* bind the 2 params _m, _nextPos *)
    destruct vargs0 as [| v_m vr1];
      cbn [bind_parameter_temps] in Hbind; [ discriminate Hbind | ].
    destruct vr1 as [| v_np vr2];
      cbn [bind_parameter_temps] in Hbind; [ discriminate Hbind | ].
    destruct vr2; [ | cbn [bind_parameter_temps] in Hbind; discriminate Hbind ].
    injection Hbind as Hle_init.
    assert (Hmeq : le1 ! mario_actions_automatic._m = Some v_m)
      by (rewrite <- Hle_init;
          rewrite PTree.gso by (vm_compute; discriminate); apply PTree.gss).
    assert (Hnpeq : le1 ! mario_actions_automatic._nextPos = Some v_np)
      by (rewrite <- Hle_init; apply PTree.gss).
    (* _m conditional from arg0_marg *)
    cbn [arg0_marg] in Hcond.
    assert (Hmcond : forall b o,
               le1 ! mario_actions_automatic._m = Some (Vptr b o) ->
               b = bm /\ o = Ptrofs.zero)
      by (intros b o Hg; rewrite Hmeq in Hg; injection Hg as Hg;
          apply (Hcond b o Hg)).
    (* _nextPos local from last_arg_local *)
    cbn [last_val] in Hlast.
    destruct Hlast as (npb & npo & Hvnp & Hnploc).
    injection Hvnp as Hvnp; subst v_np.
    (* the 4 callees are unbound globals in the entry env *)
    assert (Hrn : eloc !
              mario_actions_automatic._resolve_and_return_wall_collisions = None).
    { rewrite (alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc
                 mario_actions_automatic._resolve_and_return_wall_collisions)
        by (cbn; intros [HH | [HH | [HH | []]]]; vm_compute in HH; discriminate HH).
      apply PTree.gempty. }
    assert (Hff : eloc ! mario_actions_automatic._find_floor = None).
    { rewrite (alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc
                 mario_actions_automatic._find_floor)
        by (cbn; intros [HH | [HH | [HH | []]]]; vm_compute in HH; discriminate HH).
      apply PTree.gempty. }
    assert (Hvfc : eloc ! mario_actions_automatic._vec3f_find_ceil = None).
    { rewrite (alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc
                 mario_actions_automatic._vec3f_find_ceil)
        by (cbn; intros [HH | [HH | [HH | []]]]; vm_compute in HH; discriminate HH).
      apply PTree.gempty. }
    assert (Hvc : eloc ! mario_actions_automatic._vec3f_copy = None).
    { rewrite (alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc
                 mario_actions_automatic._vec3f_copy)
        by (cbn; intros [HH | [HH | [HH | []]]]; vm_compute in HH; discriminate HH).
      apply PTree.gempty. }
    assert (Hcar : carried bm NoA MWF me)
      by (split; [ exact HVe | split; [ exact HSe
                 | split; [ exact HMe | exact HNe ] ] ]).
    (* ---- WALK the body ---- *)
    destruct (php_walk_pres npb npo Hnploc _ _ _ _ _ _ _ _
                Hbody php_chk_body Hrn Hff Hvfc Hvc Hlids Hmcond Hnpeq Hcar)
      as (Hcarr & _ & _).
    (* ---- exit: free the 3 fn_var stack blocks ---- *)
    destruct Hcarr as (HVb & HSb & HMb & HNb).
    pose proof (blocks_of_env_bm lp bm m0 _ eloc _ Halloc HV) as Hforall.
    pose proof (free_list_carried_bm bm NoA MWF HMWF_free HNoA_of_MWF
                  (blocks_of_env (lp_ge lp) eloc) _ mF Hforall Hfree
                  (conj HVb (conj HSb (conj HMb HNb))))
      as (HVf & HSf & HMf & HNf).
    exact (conj HVf (conj HSf HMf)).
  Qed.

  (* THE DISCHARGE: lift the per-body walk to the mo residual via the
     producer + the prog_defmap pin.  Hcp_php is now PROVED (was a Hypothesis),
     resting on the resolve (ol) / vec3f_copy (w1) / find_floor & find_ceil (oc)
     leaf-external rows. *)
  Lemma Hcp_php :
    call_pres_mo lp bm NoA MWF SafeB
      mario_actions_automatic._perform_hanging_step.
  Proof.
    eapply call_pres_mo_of_body.
    - exact HNoA_of_MWF.
    - exact LO_aut.
    - exact php_pin.
    - exact php_body_pres_mo.
  Qed.

  (* ---- memory split: peel the body's back HALF into a separate Qed ----
     update_hang_moving's body walk is the biggest single proof term in the repo;
     its monolithic Qed peaks ~7.3GB RSS (over the 6.5GB WSL guardrail).  The back
     half -- the 3 m->vel[i] indexed stores, the 3 nextPos[i] local stores, and
     the perform_hanging_step / vec3f_copy / vec3s_set object-writer TAIL -- form a
     clean right-nested suffix starting at top-level block 7 (the first m->vel
     store, drop_blocks 7).  Proving that suffix in its own lemma (uhm_tail_pres)
     lets Coq free that term before uhm_body_pres's Qed, so peak ~= max(prefix,
     suffix) instead of the whole walk.  Pure refactor: same bricks, same
     assumptions -- only the Qed boundary moved. *)
  Fixpoint drop_blocks (n : nat) (s : statement) : statement :=
    match n, s with
    | S k, Ssequence _ r => drop_blocks k r
    | _, _ => s
    end.

  (* NB: keep this SYMBOLIC (no Eval) -- pre-reducing with vm_compute would turn
     the ident CONSTANTS (_perform_hanging_step, _marioObj, _t'5, ...) into raw
     positives, breaking the by-name pattern matching in the tail walk.  The
     helper reduces it in-place with the same cbn the body uses. *)
  Definition uhm_tail : statement :=
    drop_blocks 3 mario_actions_automatic.f_update_hang_moving.(fn_body).

  Lemma uhm_pin :
    (prog_defmap mario_actions_automatic.prog)
      ! mario_actions_automatic._update_hang_moving
    = Some (Gfun (Internal mario_actions_automatic.f_update_hang_moving)).
  Proof. vm_compute. reflexivity. Qed.

  (* An Sifthenelse whose BOTH branches preserve carried preserves carried --
     non-branching (returns a single goal), unlike `inv H; destruct b` which
     leaves two goals the surrounding linear walk cannot absorb.  Used for the
     forwardVel clamp (then = m->forwardVel = maxSpeed store, else = Sskip). *)
  Lemma sif_carried :
    forall e le m c s1 s2 t le' m' out,
      (forall t2 le2 m2 out2,
         exec_stmt function_entry2 (lp_ge lp) e le m s1 t2 le2 m2 out2 ->
         carried bm NoA MWF m -> carried bm NoA MWF m2 /\ le2 = le) ->
      (forall t2 le2 m2 out2,
         exec_stmt function_entry2 (lp_ge lp) e le m s2 t2 le2 m2 out2 ->
         carried bm NoA MWF m -> carried bm NoA MWF m2 /\ le2 = le) ->
      exec_stmt function_entry2 (lp_ge lp) e le m (Sifthenelse c s1 s2)
        t le' m' out ->
      carried bm NoA MWF m -> carried bm NoA MWF m' /\ le' = le.
  Proof.
    intros e le m c s1 s2 t le' m' out Hthen Helse Hex Hc.
    inv Hex.
    lazymatch goal with
    | Hb : exec_stmt _ _ _ _ _ (if ?bb then _ else _) _ _ _ _ |- _ =>
        destruct bb;
        [ exact (Hthen _ _ _ _ Hb Hc) | exact (Helse _ _ _ _ Hb Hc) ]
    end.
  Qed.

  (* gate extractor for the perform_hanging_step(m, nextPos) Scall: arg0 is the
     Mario pointer temp (marg, (bm,0)) and the last arg is the _nextPos array
     local (By_reference array decay -> Vptr npb 0, local_blk).  Establishes
     mo_gate so mo_scall_pres can fire. *)
  Lemma php_mo_gate :
    forall e le m v1 npb npty vargs,
      le ! mario_actions_automatic._m = Some v1 ->
      (forall b o, le ! mario_actions_automatic._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) ->
      e ! mario_actions_automatic._nextPos = Some (npb, npty) ->
      local_blk lp bm SafeB npb ->
      eval_exprlist (lp_ge lp) e le m
        (Etempvar mario_actions_automatic._m
           (tptr (Tstruct mario_actions_automatic._MarioState noattr))
          :: Evar mario_actions_automatic._nextPos (tarray tfloat 3) :: nil)
        (tptr (Tstruct mario_actions_automatic._MarioState noattr)
          :: tptr tfloat :: nil) vargs ->
      mo_gate lp bm SafeB vargs.
  Proof.
    intros e le m v1 npb npty vargs Hmval Hmarg Henp Hnploc Hvl.
    (* peel the two-arg list *)
    inv Hvl.
    match goal with H : eval_exprlist _ _ _ _ (_ :: nil) _ _ |- _ => inv H end.
    match goal with H : eval_exprlist _ _ _ _ nil _ _ |- _ => inv H end.
    (* arg0 = Etempvar _m -> its eval value v0 (le!_m = Some v0); the cast to
       (tptr MarioState) keeps a Vptr a Vptr, and Hmarg pins it to (bm,0). *)
    match goal with
    | He : eval_expr _ _ _ _ (Etempvar _ _) ?v0 |- _ =>
        apply eval_expr_Etempvar_val in He
    end.
    match goal with
    | He : le ! mario_actions_automatic._m = Some ?v0,
      Hc : sem_cast ?v0 _ _ _ = Some ?vc |- _ =>
        assert (Hv0 : forall b o, vc = Vptr b o -> b = bm /\ o = Ptrofs.zero)
          by (intros b o Heqvc; rewrite Heqvc in Hc; cbn in Hc;
              destruct v0 as [| ? | ? | ? | ? | b1 o1 ]; cbn in Hc;
              try discriminate Hc;
              injection Hc as Hb Ho; subst b1 o1; exact (Hmarg b o He))
    end.
    (* arg1 = Evar _nextPos (array) -> By_reference Vptr npb 0 *)
    match goal with
    | He : eval_expr _ _ _ _ (Evar _ _) ?v1 |- _ => inv He
    end.
    match goal with
    | Hlv : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inv Hlv
    end;
    [ | match goal with
        | Hn : e ! mario_actions_automatic._nextPos = None |- _ =>
            rewrite Henp in Hn; discriminate Hn
        end ].
    match goal with
    | He : e ! mario_actions_automatic._nextPos = Some (?loc, _) |- _ =>
        assert (loc = npb) by congruence; subst loc
    end.
    match goal with
    | Hd : deref_loc _ _ npb _ _ _ |- _ =>
        cbn [typeof] in Hd; inv Hd;
        try (match goal with
             | Hac : access_mode _ = By_value _ |- _ =>
                 cbn in Hac; discriminate Hac
             end);
        try (match goal with
             | Hac : access_mode _ = By_copy |- _ =>
                 cbn in Hac; discriminate Hac
             end);
        try (match goal with
             | Hlb : load_bitfield _ _ _ _ _ _ _ _ |- _ => inv Hlb
             end)
    end.
    match goal with
    | Hc : sem_cast (Vptr npb _) _ _ _ = Some _ |- _ =>
        cbn in Hc; injection Hc as <-
    end.
    (* mo_gate = arg0_marg /\ last_arg_local *)
    split.
    - cbn [arg0_marg]. exact Hv0.
    - red. cbn [last_val]. exists npb, Ptrofs.zero.
      split; [ reflexivity | exact Hnploc ].
  Qed.

  (* the two graphics object-writers are SHARED obj-family sc rows *)
  Lemma uhm_sc_rows :
    forall fid,
      mem_id fid (mario_actions_automatic._vec3f_copy
                  :: mario_actions_automatic._vec3s_set :: nil) = true ->
      call_pres_ext_sc lp bm NoA MWF SafeB fid.
  Proof.
    intros fid H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hscp_v3f | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hscp_v3s | ].
    discriminate H.
  Qed.

  (* The split-off TAIL: php(m,nextPos) ; vec3f_copy(obj,m->pos) ;
     vec3s_set(obj,..) ; return.  Quantifies the env/temp facts the three arms
     need (marg over le!_m, nextPos local, the callee globals unbound) so it is
     env-agnostic; uhm_body_pres supplies them at the cut point.  Separate Qed =
     its (heavy) proof term is freed before uhm_body_pres's Qed. *)
  Lemma uhm_tail_pres :
    forall E le m v1 npb npty t le' m' out,
      E ! mario_actions_automatic._nextPos = Some (npb, npty) ->
      local_blk lp bm SafeB npb ->
      E ! mario_actions_automatic._approach_s32 = None ->
      E ! mario_actions_automatic._perform_hanging_step = None ->
      (forall g,
          mem_id g (mario_actions_automatic._vec3f_copy
                    :: mario_actions_automatic._vec3s_set :: nil) = true ->
          E ! g = None) ->
      le ! mario_actions_automatic._m = Some v1 ->
      (forall b o, le ! mario_actions_automatic._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) ->
      carried bm NoA MWF m ->
      exec_stmt function_entry2 (lp_ge lp) E le m uhm_tail t le' m' out ->
      carried bm NoA MWF m'.
  Proof.
    intros E le m v1 npb npty t le' m' out
           Henp Hnploc Happ_none Hphp_none Hsc_none Hmeq Hmarg_fact Hcar Hexec.
    unfold uhm_tail, mario_actions_automatic.f_update_hang_moving in Hexec.
    cbn [drop_blocks fn_body fn_params fn_temps fn_vars] in Hexec.
    (* PHASE 1: peel the tail's Ssequences / Ssets / the final Sreturn *)
    repeat first
      [ match goal with
        | H : exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ |- _ =>
            inv H; [ | crush_all_r ]
        end
      | match goal with
        | H : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ => inv H
        | H : exec_stmt _ _ _ _ _ (Sreturn _) _ _ _ _ |- _ => inv H
        end ].
    (* PHASE 2: thread carried through php, vec3f_copy, vec3s_set.
       NB `try subst Lo`: here the calls are the leading statements, so each
       call's output env is abstract (the Scall is never inv'd) and has no
       equation to subst -- unlike in uhm_body_pres where a prefix precedes them.*)
    repeat
      lazymatch goal with
      (* nextPos[i] local store -- watched-disjoint stack block (SPECIFIC: must
         precede the generic Sassign arm below) *)
      | Hc : carried bm NoA MWF ?mc,
        H : exec_stmt _ _ _ ?Le ?mc
              (Sassign (Ederef (Ebinop Oadd
                          (Evar mario_actions_automatic._nextPos _) _ _)
                          ?ety2) _)
              _ ?Lo ?mn _ |- _ =>
          destruct (local_idx_assign_pres' lp bm NoA MWF SafeB Hls_real
                      HNoA_of_MWF E mario_actions_automatic._nextPos
                      _ _ _ _ _ ety2 _ Le mc _ Lo mn _ npb npty _
                      Henp Hnploc ltac:(cbn; reflexivity) H Hc) as (Hc' & Hleq' & _);
          clear Hc H; rename Hc' into Hc; subst Lo
      (* m->vel[i] indexed float field store (GENERIC Sassign).  Capture le'=le
         and subst Lo: a bare vel[i]=const store has NO preceding Sset to rebuild
         a concrete tower, so the next store's marg gate would hit the opaque
         post-store env -- keep the chain concrete on the param le. *)
      | Hc : carried bm NoA MWF ?mc,
        H : exec_stmt _ _ _ ?Le ?mc (Sassign ?a1 _) _ ?Lo ?mn _ |- _ =>
          destruct Hc as (HVc & HSc & HMc & HNc);
          first
            [ destruct (idx_assign_pres lp LO_mario bm MWF HMWF_window
                          a1 _ _ Le mc _ _ _ _
                          ltac:(vm_compute; reflexivity)
                          ltac:(intros b o Hg;
                                repeat (rewrite PTree.gso in Hg
                                          by (vm_compute; discriminate));
                                exact (Hmarg_fact b o Hg))
                          H HMc HVc HSc) as (HV' & HS' & HM' & Hleq & _)
            | destruct (idx16_assign_pres lp LO_mario bm MWF HMWF_window
                          a1 _ _ Le mc _ _ _ _
                          ltac:(vm_compute; reflexivity)
                          ltac:(intros b o Hg;
                                repeat (rewrite PTree.gso in Hg
                                          by (vm_compute; discriminate));
                                exact (Hmarg_fact b o Hg))
                          H HMc HVc HSc) as (HV' & HS' & HM' & Hleq & _)
            | destruct (epi_assign_pres lp LO_mario bm MWF HMWF_window
                          a1 _ _ Le mc _ _ _ _
                          ltac:(vm_compute; reflexivity)
                          ltac:(intros b o Hg;
                                repeat (rewrite PTree.gso in Hg
                                          by (vm_compute; discriminate));
                                exact (Hmarg_fact b o Hg))
                          H HMc HVc HSc) as (HV' & HS' & HM' & Hleq & _) ];
          assert (Hc' : carried bm NoA MWF mn)
            by (split; [ exact HV' | split; [ exact HS'
                       | split; [ exact HM' | exact (HNoA_of_MWF _ HM') ] ] ]);
          clear Hc HVc HSc HMc HNc H HV' HS' HM'; rename Hc' into Hc; subst Lo
      (* approach_s32(..): pure-math external, write-free (block3 leaf) *)
      | Hc : carried bm NoA MWF ?mc,
        H : exec_stmt _ _ _ _ ?mc
              (Scall _ (Evar mario_actions_automatic._approach_s32 _) _)
              _ ?Lo ?mn _ |- _ =>
          destruct (stv_scall_pres _ mario_actions_automatic._approach_s32
                      _ _ _ _ _ _ _ _ _ _ _
                      Happ_none Hcpx_approach H Hc) as (Hc' & _);
          destruct (call_le_form _ _ _ _ _ _ _ _ _ _ H) as (? & Hle_);
          cbn [set_opttemp] in Hle_;
          clear Hc H; rename Hc' into Hc; subst Lo
      (* perform_hanging_step(m, nextPos): the marg-AND-local internal helper *)
      | Hc : carried bm NoA MWF ?mc,
        H : exec_stmt _ _ ?E ?Le ?mc
              (Scall _ (Evar mario_actions_automatic._perform_hanging_step _)
                 _) _ ?Lo ?mn _ |- _ =>
          destruct (mo_scall_pres lp bm NoA MWF SafeB _
                      mario_actions_automatic._perform_hanging_step _ _ _ _
                      E Le mc _ Lo mn _ Hphp_none Hcp_php
                      ltac:(intros vargs Hvl;
                            eapply (php_mo_gate E Le mc);
                            [ repeat (rewrite PTree.gso by (vm_compute; discriminate));
                              exact Hmeq
                            | intros b o Hg;
                              repeat (rewrite PTree.gso in Hg
                                        by (vm_compute; discriminate));
                              exact (Hmarg_fact b o Hg)
                            | exact Henp | exact Hnploc | exact Hvl ])
                      H Hc) as (Hc' & _);
          destruct (call_le_form _ _ _ _ _ _ _ _ _ _ H) as (? & Hle_);
          cbn [set_opttemp] in Hle_;
          clear Hc H; rename Hc' into Hc; subst Lo
      (* vec3f_copy(marioObj->gfx.pos, m->pos): sc object writer (cact = _t'5) *)
      | Hc : carried bm NoA MWF ?mc,
        H : exec_stmt _ _ ?E ?Le ?mc
              (Scall _ (Evar mario_actions_automatic._vec3f_copy ?cfty) ?cal)
              _ ?Lo ?mn _,
        Hev5 : eval_expr _ _ ?Lev ?mc
                 (Efield (Ederef (Etempvar mario_actions_automatic._m ?pty) ?sty)
                    mario_actions_automatic._marioObj ?fty) ?v5 |- _ =>
          destruct Hc as (HVc & HSc & HMc & HNc);
          pose proof (chase_root_set_sound lp LO_mario bm MWF HMWF_window
                        HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot HMWF_root
                        (Efield (Ederef (Etempvar mario_actions_automatic._m pty) sty)
                           mario_actions_automatic._marioObj fty)
                        E Lev mc v5 ltac:(vm_compute; reflexivity)
                        ltac:(intros b o Hg;
                              repeat (rewrite PTree.gso in Hg
                                        by (vm_compute; discriminate));
                              exact (Hmarg_fact b o Hg))
                        HMc Hev5) as Hsafe5;
          assert (Hchinv : chase_inv SafeB
                    (mario_actions_automatic._t'5 :: nil) Le)
            by (intros tt Htt b o Hget; cbn [mem_id existsb] in Htt;
                apply orb_true_iff in Htt as [E5 | F]; [ | discriminate F ];
                apply Pos.eqb_eq in E5; subst tt;
                rewrite PTree.gss in Hget; injection Hget as Hget;
                exact (Hsafe5 b o Hget));
          assert (Hc'' : carried bm NoA MWF mc)
            by (split; [ exact HVc | split; [ exact HSc
                       | split; [ exact HMc | exact HNc ] ] ]);
          destruct (sc_call_chk_pres lp bm NoA MWF SafeB
                      (mario_actions_automatic._vec3f_copy
                       :: mario_actions_automatic._vec3s_set :: nil)
                      (mario_actions_automatic._t'5 :: nil)
                      None mario_actions_automatic._vec3f_copy cfty cal
                      E Le mc _ Lo mn _ uhm_sc_rows Hsc_none Hchinv
                      ltac:(vm_compute; reflexivity) H Hc'') as (Hc' & _);
          destruct (call_le_form _ _ _ _ _ _ _ _ _ _ H) as (? & Hle_);
          cbn [set_opttemp] in Hle_;
          clear Hc'' HVc HSc HMc HNc H Hev5 Hsafe5 Hchinv;
          rename Hc' into Hc; subst Lo
      (* vec3s_set(marioObj->gfx.angle, ..): sc object writer (cact = _t'3) *)
      | Hc : carried bm NoA MWF ?mc,
        H : exec_stmt _ _ ?E ?Le ?mc
              (Scall _ (Evar mario_actions_automatic._vec3s_set ?cfty) ?cal)
              _ ?Lo ?mn _,
        Hev3 : eval_expr _ _ ?Lev ?mc
                 (Efield (Ederef (Etempvar mario_actions_automatic._m ?pty) ?sty)
                    mario_actions_automatic._marioObj ?fty) ?v3 |- _ =>
          destruct Hc as (HVc & HSc & HMc & HNc);
          pose proof (chase_root_set_sound lp LO_mario bm MWF HMWF_window
                        HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot HMWF_root
                        (Efield (Ederef (Etempvar mario_actions_automatic._m pty) sty)
                           mario_actions_automatic._marioObj fty)
                        E Lev mc v3 ltac:(vm_compute; reflexivity)
                        ltac:(intros b o Hg;
                              repeat (rewrite PTree.gso in Hg
                                        by (vm_compute; discriminate));
                              exact (Hmarg_fact b o Hg))
                        HMc Hev3) as Hsafe3;
          assert (Hchinv : chase_inv SafeB
                    (mario_actions_automatic._t'3 :: nil) Le)
            by (intros tt Htt b o Hget; cbn [mem_id existsb] in Htt;
                apply orb_true_iff in Htt as [E3 | F]; [ | discriminate F ];
                apply Pos.eqb_eq in E3; subst tt;
                repeat (rewrite PTree.gso in Hget by (vm_compute; discriminate));
                rewrite PTree.gss in Hget; injection Hget as Hget;
                exact (Hsafe3 b o Hget));
          assert (Hc'' : carried bm NoA MWF mc)
            by (split; [ exact HVc | split; [ exact HSc
                       | split; [ exact HMc | exact HNc ] ] ]);
          destruct (sc_call_chk_pres lp bm NoA MWF SafeB
                      (mario_actions_automatic._vec3f_copy
                       :: mario_actions_automatic._vec3s_set :: nil)
                      (mario_actions_automatic._t'3 :: nil)
                      None mario_actions_automatic._vec3s_set cfty cal
                      E Le mc _ Lo mn _ uhm_sc_rows Hsc_none Hchinv
                      ltac:(vm_compute; reflexivity) H Hc'') as (Hc' & _);
          destruct (call_le_form _ _ _ _ _ _ _ _ _ _ H) as (? & Hle_);
          cbn [set_opttemp] in Hle_;
          clear Hc'' HVc HSc HMc HNc H Hev3 Hsafe3 Hchinv;
          rename Hc' into Hc; subst Lo
      end.
    (* all leaves threaded; the tail's residual carried is exactly Hcar *)
    exact Hcar.
  Qed.

  Lemma uhm_body_pres :
    body_pres lp NoA MWF bm mario_actions_automatic.f_update_hang_moving.
  Proof.
    intros m0 vargs0 t0 mF vres0 Hmargf Hevf HN HM HV HS.
    assert (Hmarg : marg_ok bm vargs0)
      by (apply Hmargf; vm_compute; reflexivity).
    (* ---- entry: alloc _nextPos, bind _m ---- *)
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ =>
      rename He into Hentry end.
    match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
      rename Hx into Hbody end.
    match goal with Hf : Mem.free_list _ _ = Some _ |- _ =>
      rename Hf into Hfree end.
    inv Hentry.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
      rename Ha into Halloc end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ =>
      rename Hb into Hbind end.
    unfold mario_actions_automatic.f_update_hang_moving in Hbody, Hbind, Halloc.
    cbn [fn_body fn_params fn_temps fn_vars] in Hbody, Hbind, Halloc.
    match goal with H : alloc_variables _ _ _ _ ?E ?ME |- _ =>
      set (eloc := E) in *; set (me := ME) in * end.
    assert (Hc0 : carried bm NoA MWF m0)
      by (split; [ exact HV | split; [ exact HS
                 | split; [ exact HM | exact HN ] ] ]).
    pose proof (alloc_variables_carried bm NoA MWF HMWF_alloc HNoA_of_MWF
                  _ _ _ _ _ _ Halloc Hc0) as Hce.
    destruct Hce as (HVe & HSe & HMe & HNe).
    (* _nextPos fn_var is a watched-disjoint stack block *)
    pose proof (alloc_variables_hlocal lp bm SafeB m0 _ eloc _
                  (mario_actions_automatic._nextPos :: nil) Halloc HV
                  (HSafeValid m0 HM) (HGlobValid m0 HM)
                  ltac:(intros lid Hm; unfold mem_id in Hm; cbn [existsb] in Hm;
                        apply Bool.orb_true_iff in Hm; destruct Hm as [He | Hf];
                        [ apply Pos.eqb_eq in He; subst lid; cbn [map fst];
                          apply in_eq
                        | discriminate Hf ]))
      as Hlocal_fn.
    destruct (Hlocal_fn mario_actions_automatic._nextPos eq_refl)
      as (npb & npty & Henp & Hnploc).
    (* bind the _m param *)
    destruct vargs0 as [| v1 vrest];
      cbn [bind_parameter_temps] in Hbind; [ discriminate Hbind | ].
    destruct vrest; [ | cbn [bind_parameter_temps] in Hbind; discriminate Hbind ].
    injection Hbind as Hle_init.
    assert (Hmeq : le1 ! mario_actions_automatic._m = Some v1)
      by (rewrite <- Hle_init; apply PTree.gss).
    assert (Hmarg_fact : forall b o,
               le1 ! mario_actions_automatic._m = Some (Vptr b o) ->
               b = bm /\ o = Ptrofs.zero)
      by (intros b o Hg; rewrite Hmeq in Hg; injection Hg as Hv1;
          rewrite Hv1 in Hmarg; cbn in Hmarg; exact Hmarg).
    (* the four globals are unbound in the entry env *)
    assert (Happ_none :
              eloc ! mario_actions_automatic._approach_s32 = None).
    { rewrite (alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc
                 mario_actions_automatic._approach_s32)
        by (cbn; intros [HH | []]; vm_compute in HH; discriminate HH).
      apply PTree.gempty. }
    assert (Hv3f_none :
              eloc ! mario_actions_automatic._vec3f_copy = None).
    { rewrite (alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc
                 mario_actions_automatic._vec3f_copy)
        by (cbn; intros [HH | []]; vm_compute in HH; discriminate HH).
      apply PTree.gempty. }
    assert (Hv3s_none :
              eloc ! mario_actions_automatic._vec3s_set = None).
    { rewrite (alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc
                 mario_actions_automatic._vec3s_set)
        by (cbn; intros [HH | []]; vm_compute in HH; discriminate HH).
      apply PTree.gempty. }
    assert (Hphp_none :
              eloc ! mario_actions_automatic._perform_hanging_step = None).
    { rewrite (alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc
                 mario_actions_automatic._perform_hanging_step)
        by (cbn; intros [HH | []]; vm_compute in HH; discriminate HH).
      apply PTree.gempty. }
    (* sc rows + e!fid=None bundle for the two object writers *)
    assert (Hsc_none : forall g,
               mem_id g (mario_actions_automatic._vec3f_copy
                         :: mario_actions_automatic._vec3s_set :: nil) = true ->
               eloc ! g = None).
    { intros g Hg; cbn [mem_id existsb] in Hg;
        apply orb_true_iff in Hg as [Eg | Hg];
        [ apply Pos.eqb_eq in Eg; subst g; exact Hv3f_none | ];
        apply orb_true_iff in Hg as [Eg | F];
        [ apply Pos.eqb_eq in Eg; subst g; exact Hv3s_none | discriminate F ]. }
    assert (Hcar : carried bm NoA MWF me)
      by (split; [ exact HVe | split; [ exact HSe
                 | split; [ exact HMe | exact HNe ] ] ]).
    clear Hc0 HVe HSe HMe HNe.
    (* ---- PHASE 1: peel the body to the mem-changing leaves, but STOP at the
       split-off suffix (the Ssequence whose head block is the first m->vel[i]
       store); that whole back half -- vel[0..2], nextPos[0..2], and the
       perform_hanging_step/vec3f/vec3s tail -- goes to uhm_tail_pres so its proof
       term is freed before this Qed.  (_vel is absent from blocks 0..6, which
       touch only forwardVel/slideYaw/slideVelX/slideVelZ.) ---- *)
    repeat first
      [ match goal with
        | H : exec_stmt _ _ _ _ _ (Ssequence ?s1 _) _ _ _ _ |- _ =>
            lazymatch s1 with
            | context[mario_actions_automatic._approach_s32] => fail
            | _ => inv H; [ | crush_all_r ]
            end
        end
      | match goal with
        | H : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ => inv H
        | H : exec_stmt _ _ _ _ _ (Sreturn _) _ _ _ _ |- _ => inv H
        end ].
    (* ---- PHASE 2: thread carried along the PREFIX leaf chain (the php/vec3f/
       vec3s tail is handled by uhm_tail_pres, below) ---- *)
    repeat
      match goal with
      (* approach_s32(..): pure-math external, write-free *)
      | Hc : carried bm NoA MWF ?mc,
        H : exec_stmt _ _ _ _ ?mc
              (Scall _ (Evar mario_actions_automatic._approach_s32 _) _)
              _ ?Lo ?mn _ |- _ =>
          destruct (stv_scall_pres _ mario_actions_automatic._approach_s32
                      _ _ _ _ _ _ _ _ _ _ _
                      Happ_none Hcpx_approach H Hc) as (Hc' & _);
          destruct (call_le_form _ _ _ _ _ _ _ _ _ _ H) as (? & Hle_);
          cbn [set_opttemp] in Hle_;
          clear Hc H; rename Hc' into Hc; subst Lo
      (* nextPos[i] local store *)
      | Hc : carried bm NoA MWF ?mc,
        H : exec_stmt _ _ _ ?Le ?mc
              (Sassign (Ederef (Ebinop Oadd
                          (Evar mario_actions_automatic._nextPos _) _ _) _) _)
              _ ?Lo ?mn _ |- _ =>
          destruct (local_idx_assign_pres' lp bm NoA MWF SafeB Hls_real
                      HNoA_of_MWF eloc mario_actions_automatic._nextPos
                      _ _ _ _ _ _ _ Le mc _ Lo mn _ npb npty _
                      Henp Hnploc ltac:(cbn; reflexivity) H Hc) as (Hc' & _ & _);
          clear Hc H; rename Hc' into Hc; subst Lo
      (* m->vel[i] indexed float field store *)
      | Hc : carried bm NoA MWF ?mc,
        H : exec_stmt _ _ _ ?Le ?mc (Sassign ?a1 _) _ ?Lo ?mn _ |- _ =>
          destruct Hc as (HVc & HSc & HMc & HNc);
          first
            [ destruct (idx_assign_pres lp LO_mario bm MWF HMWF_window
                          a1 _ _ Le mc _ _ _ _
                          ltac:(vm_compute; reflexivity)
                          ltac:(intros b o Hg;
                                repeat (rewrite PTree.gso in Hg
                                          by (vm_compute; discriminate));
                                exact (Hmarg_fact b o Hg))
                          H HMc HVc HSc) as (HV' & HS' & HM' & Hleq & _)
            | destruct (idx16_assign_pres lp LO_mario bm MWF HMWF_window
                          a1 _ _ Le mc _ _ _ _
                          ltac:(vm_compute; reflexivity)
                          ltac:(intros b o Hg;
                                repeat (rewrite PTree.gso in Hg
                                          by (vm_compute; discriminate));
                                exact (Hmarg_fact b o Hg))
                          H HMc HVc HSc) as (HV' & HS' & HM' & Hleq & _)
            | destruct (epi_assign_pres lp LO_mario bm MWF HMWF_window
                          a1 _ _ Le mc _ _ _ _
                          ltac:(vm_compute; reflexivity)
                          ltac:(intros b o Hg;
                                repeat (rewrite PTree.gso in Hg
                                          by (vm_compute; discriminate));
                                exact (Hmarg_fact b o Hg))
                          H HMc HVc HSc) as (HV' & HS' & HM' & Hleq & _) ];
          assert (Hc' : carried bm NoA MWF mn)
            by (split; [ exact HV' | split; [ exact HS'
                       | split; [ exact HM' | exact (HNoA_of_MWF _ HM') ] ] ]);
          clear Hc HVc HSc HMc HNc H HV' HS' HM'; rename Hc' into Hc; subst Lo
      end.
    (* the forwardVel clamp Sifthenelse (block2): both branches preserve carried
       (then = m->forwardVel = maxSpeed store, else = Sskip).  Threaded
       NON-branching via sif_carried, explicitly (outside the backtracking match)
       so a sub-proof error surfaces instead of being swallowed. *)
    lazymatch goal with
    | Hc : carried bm NoA MWF ?mc,
      H : exec_stmt _ _ ?Een ?Le ?mc (Sifthenelse ?cc ?s1 ?s2)
            _ ?Lo ?mn _ |- _ =>
        assert (Hcle : carried bm NoA MWF mn /\ Lo = Le);
        [ eapply (sif_carried Een Le mc cc s1 s2);
          [ (* then: m->forwardVel = maxSpeed store -- preserves carried AND le *)
            intros tcl lecl mcl ocl Hbcl Hc0cl;
            lazymatch type of Hbcl with
            | exec_stmt _ _ _ ?Le2 ?M2 (Sassign ?a1 _) _ _ _ _ =>
                destruct Hc0cl as (HVc & HSc & HMc & HNc);
                destruct (epi_assign_pres lp LO_mario bm MWF HMWF_window
                            a1 _ _ Le2 M2 _ _ _ _
                            ltac:(vm_compute; reflexivity)
                            ltac:(intros b o Hg;
                                  repeat (rewrite PTree.gso in Hg
                                            by (vm_compute; discriminate));
                                  exact (Hmarg_fact b o Hg))
                            Hbcl HMc HVc HSc) as (HV' & HS' & HM' & Hle_eq & _);
                split;
                [ split; [ exact HV' | split; [ exact HS'
                         | split; [ exact HM' | exact (HNoA_of_MWF _ HM') ] ] ]
                | exact Hle_eq ]
            end
          | (* else: Sskip -- preserves carried AND le trivially *)
            intros tcl lecl mcl ocl Hbcl Hc0cl; inv Hbcl;
            split; [ exact Hc0cl | reflexivity ]
          | exact H
          | exact Hc ]
        | destruct Hcle as (Hc' & HloEq); subst Lo;
          clear Hc H; rename Hc' into Hc ]
    end.
    (* ---- discharge the php/vec3f/vec3s TAIL via its own (separately-Qed'd)
       lemma; carried advances from the prefix's final memory to the body's.
       lek!_m and its marg fact transfer from the entry env le1 by stripping the
       prefix temps (none alias _m). ---- *)
    lazymatch goal with
    | Htail : exec_stmt _ _ ?E ?lek ?mpre (Ssequence _ _) _ ?lf ?mbody ?o |- _ =>
        assert (Hmeqk : lek ! mario_actions_automatic._m = Some v1)
          by (repeat (rewrite PTree.gso by (vm_compute; discriminate)); exact Hmeq);
        assert (Hmargk : forall b oo,
                   lek ! mario_actions_automatic._m = Some (Vptr b oo) ->
                   b = bm /\ oo = Ptrofs.zero)
          by (intros b oo Hg; rewrite Hmeqk in Hg; injection Hg as Hg;
              apply (Hmarg_fact b oo); rewrite Hmeq, Hg; reflexivity);
        pose proof (uhm_tail_pres E lek mpre v1 npb npty _ lf mbody o
                      Henp Hnploc Happ_none Hphp_none Hsc_none Hmeqk Hmargk Hcar Htail)
          as Hfin;
        clear Hcar Htail Hmeqk Hmargk; rename Hfin into Hcar
    end.
    (* ---- exit: free the _nextPos stack block ---- *)
    destruct Hcar as (HVb & HSb & HMb & HNb).
    pose proof (blocks_of_env_bm lp bm m0 _ eloc _ Halloc HV) as Hforall.
    pose proof (free_list_carried_bm bm NoA MWF HMWF_free HNoA_of_MWF
                  (blocks_of_env (lp_ge lp) eloc) _ mF Hforall Hfree
                  (conj HVb (conj HSb (conj HMb HNb))))
      as (HVf & HSf & HMf & HNf).
    exact (conj HVf (conj HSf HMf)).
  Qed.

  (* B11 act_hang_moving: update_hang_moving is the SOLE hard helper gating the
     leaf (act_hang_moving calls it as update_hang_moving(m), branching on its
     i32 result).  Now WALKED (Lemma Huhm below) -- decompose, not collapse:
     the whole helper body reduces to Hcpx_approach + Hcp_php (its two leaf
     callees) + the existing chase/field/sc rows. *)
  Lemma Huhm :
    call_pres lp bm NoA MWF mario_actions_automatic._update_hang_moving.
  Proof.
    apply (call_pres_of_body lp bm NoA MWF HNoA_of_MWF
             mario_actions_automatic.prog _
             mario_actions_automatic.f_update_hang_moving LO_aut uhm_pin).
    exact uhm_body_pres.
  Qed.

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

  (* ---- B10 pole-cluster helper rows ---- *)
  Lemma Hiapf : call_pres lp bm NoA MWF mario._is_anim_past_frame.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario.prog mario._is_anim_past_frame mario.f_is_anim_past_frame
             nil nil nil nil
             LO_mario iapf_pin iapf_vars iapf_params_ok).
    - intros fid' H; discriminate H.
    - intros fid' H; discriminate H.
    - intros fid' H; discriminate H.
    - intros fid' H; discriminate H.
    - exact iapf_walk.
  Qed.
  Lemma Hiape : call_pres lp bm NoA MWF mario._is_anim_past_end.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario.prog mario._is_anim_past_end mario.f_is_anim_past_end
             nil nil nil nil
             LO_mario iape_pin iape_vars iape_params_ok).
    - intros fid' H; discriminate H.
    - intros fid' H; discriminate H.
    - intros fid' H; discriminate H.
    - intros fid' H; discriminate H.
    - exact iape_walk.
  Qed.
  Lemma pcs_ids_rows :
    forall fid, mem_id fid pcs_ids = true -> call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold pcs_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hiapf | ].
    discriminate H.
  Qed.
  Lemma pcs_xids_rows :
    forall fid, mem_id fid pcs_xids = true -> call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold pcs_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_psound | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_stv | ].
    discriminate H.
  Qed.
  Lemma Hpcs :
    call_pres lp bm NoA MWF mario_actions_automatic._play_climbing_sounds.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_automatic.prog
             mario_actions_automatic._play_climbing_sounds
             mario_actions_automatic.f_play_climbing_sounds
             pcs_ids nil pcs_xids nil
             LO_aut pcs_pin pcs_vars pcs_params_ok).
    - exact pcs_ids_rows.
    - intros fid' H; discriminate H.
    - exact pcs_xids_rows.
    - intros fid' H; discriminate H.
    - exact pcs_walk.
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
  Lemma grabbed_ids_rows :
    forall fid, mem_id fid grabbed_ids = true -> call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold grabbed_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsma | ].
    discriminate H.
  Qed.
  Lemma grabbed_xids_rows :
    forall fid, mem_id fid grabbed_xids = true -> call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold grabbed_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_v3f | ].
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
  (* act_grabbed: the wact-mechanism leaf (untainted temp action arg _t'1) *)
  Lemma act_grabbed_pres :
    body_pres lp NoA MWF bm mario_actions_automatic.f_act_grabbed.
  Proof.
    apply (body_pres_of_wwalk_wact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_automatic.f_act_grabbed
             grabbed_wact grabbed_ids nil grabbed_cact grabbed_xids hang_sids nil
             grabbed_vars grabbed_params_ok grabbed_nonparam_c grabbed_nonparam_w).
    - exact grabbed_ids_rows.
    - intros fid' H. discriminate H.
    - exact grabbed_xids_rows.
    - exact hang_sids_rows.
    - intros fid' H. discriminate H.
    - exact grabbed_walk.
  Qed.

  (* ---- the LEDGE CLUSTER rows (the local-vars arc consumer) ---- *)
  Let Hmsfv : call_pres lp bm NoA MWF mario._mario_set_forward_vel :=
    msfv_row lp LO_mario bm NoA MWF HNoA_of_MWF HMWF_window HMWF_glob
      HMWF_act SafeB HSafeNotBm HchaseRoot HMWF_chase HMWF_root HMWF_sglob
      HchaseStep HMWF_chase_safe.

  Lemma lgl_oc_rows :
    forall fid, mem_id fid lgl_oc_pids = true ->
                call_pres_ext_oc lp bm NoA MWF SafeB fid.
  Proof.
    intros fid H. unfold lgl_oc_pids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hocp_find_floor | ].
    discriminate H.
  Qed.
  Lemma ffhrp_oc_rows :
    forall fid, mem_id fid ffhrp_oc_pids = true ->
                call_pres_ext_oc lp bm NoA MWF SafeB fid.
  Proof.
    intros fid H. unfold ffhrp_oc_pids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hocp_find_floor | ].
    discriminate H.
  Qed.
  Lemma lgl_sids_rows :
    forall fid, mem_id fid lgl_sids = true -> call_pres_act lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold lgl_sids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsmact | ].
    discriminate H.
  Qed.
  Lemma sasthf_ids_rows :
    forall fid, mem_id fid sasthf_ids = true -> call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sasthf_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hmsfv | ].
    discriminate H.
  Qed.
  Lemma sasthf_xids_rows :
    forall fid, mem_id fid sasthf_xids = true -> call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sasthf_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_v3f | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_v3s | ].
    discriminate H.
  Qed.

  (* the two Tier-1 lwalk helpers (fn_vars = [_floor]) *)
  Lemma Hlgl :
    call_pres lp bm NoA MWF mario_actions_automatic._let_go_of_ledge.
  Proof.
    apply (call_pres_of_lwalk2 lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             HMWF_alloc HMWF_free
             mario_actions_automatic.prog
             mario_actions_automatic._let_go_of_ledge
             mario_actions_automatic.f_let_go_of_ledge
             nil nil nil lgl_sids lgl_lids lgl_oc_pids nil nil
             LO_aut lgl_pin lgl_params_ok).
    - (* Hdg: stored_globals disjoint from fn_vars=[_floor] *)
      intros g Hg Hin; vm_compute in Hin;
        destruct Hin as [Heq | []]; subst g; vm_compute in Hg; discriminate.
    - intros g HH; discriminate HH.   (* Hdi: ids=nil *)
    - intros g HH; discriminate HH.   (* Hdw: wids=nil *)
    - intros g HH; discriminate HH.   (* Hdx: xids=nil *)
    - (* Hds: sids=lgl_sids disjoint from fn_vars *)
      intros g Hg Hin; vm_compute in Hin;
        destruct Hin as [Heq | []]; subst g; vm_compute in Hg; discriminate.
    - (* Hdoc: oc_pids=[find_floor] disjoint from fn_vars *)
      intros g Hg Hin; vm_compute in Hin;
        destruct Hin as [Heq | []]; subst g; vm_compute in Hg; discriminate.
    - intros g HH; discriminate HH.   (* Hdwc: wc_pids=nil *)
    - intros g HH; discriminate HH.   (* Hdsc: sc_pids=nil *)
    - (* Hdgt: gGlobalTimer not a local *)
      vm_compute; intro Hin; destruct Hin as [Heq | []]; discriminate Heq.
    - (* Hlsub: lids=[_floor] subset of fn_vars *)
      intros lid Hl; unfold lgl_lids in Hl; cbn [mem_id existsb] in Hl;
        apply orb_true_iff in Hl as [Hm | Hf];
        [ apply Pos.eqb_eq in Hm; subst lid; vm_compute; left; reflexivity
        | discriminate Hf ].
    - exact HSafeValid.
    - exact HGlobValid.
    - exact Hls_real.
    - intros fid' H; discriminate H.   (* Hcp: ids=nil *)
    - intros fid' H; discriminate H.   (* Hcpa: wids=nil *)
    - intros fid' H; discriminate H.   (* Hcpx: xids=nil *)
    - exact lgl_sids_rows.             (* Hcps: sids *)
    - exact lgl_oc_rows.               (* Hcpoc: oc_pids *)
    - intros fid' H; discriminate H.   (* Hcpwc: wc_pids=nil *)
    - intros fid' H; discriminate H.   (* Hcpsc: sc_pids=nil *)
    - exact lgl_walk.                  (* Hchk *)
  Qed.
  Lemma Hffhrp :
    call_pres lp bm NoA MWF mario._find_floor_height_relative_polar.
  Proof.
    apply (call_pres_of_lwalk2 lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             HMWF_alloc HMWF_free
             mario.prog mario._find_floor_height_relative_polar
             mario.f_find_floor_height_relative_polar
             nil nil nil nil ffhrp_lids ffhrp_oc_pids nil nil
             LO_mario ffhrp_pin ffhrp_params_ok).
    - (* Hdg: stored_globals disjoint *)
      intros g Hg Hin; vm_compute in Hin;
        destruct Hin as [Heq | []]; subst g; vm_compute in Hg; discriminate.
    - intros g HH; discriminate HH.   (* Hdi: ids=nil *)
    - intros g HH; discriminate HH.   (* Hdw: wids=nil *)
    - intros g HH; discriminate HH.   (* Hdx: xids=nil *)
    - intros g HH; discriminate HH.   (* Hds: sids=nil *)
    - (* Hdoc: oc_pids=[find_floor] disjoint from fn_vars *)
      intros g Hg Hin; vm_compute in Hin;
        destruct Hin as [Heq | []]; subst g; vm_compute in Hg; discriminate.
    - intros g HH; discriminate HH.   (* Hdwc: wc_pids=nil *)
    - intros g HH; discriminate HH.   (* Hdsc: sc_pids=nil *)
    - (* Hdgt: gGlobalTimer not a local *)
      vm_compute; intro Hin; destruct Hin as [Heq | []]; discriminate Heq.
    - (* Hlsub: lids=[_floor] subset of fn_vars *)
      intros lid Hl; unfold ffhrp_lids in Hl; cbn [mem_id existsb] in Hl;
        apply orb_true_iff in Hl as [Hm | Hf];
        [ apply Pos.eqb_eq in Hm; subst lid; vm_compute; left; reflexivity
        | discriminate Hf ].
    - exact HSafeValid.
    - exact HGlobValid.
    - exact Hls_real.
    - intros fid' H; discriminate H.   (* Hcp: ids=nil *)
    - intros fid' H; discriminate H.   (* Hcpa: wids=nil *)
    - intros fid' H; discriminate H.   (* Hcpx: xids=nil *)
    - intros fid' H; discriminate H.   (* Hcps: sids=nil *)
    - exact ffhrp_oc_rows.             (* Hcpoc: oc_pids *)
    - intros fid' H; discriminate H.   (* Hcpwc: wc_pids=nil *)
    - intros fid' H; discriminate H.   (* Hcpsc: sc_pids=nil *)
    - exact ffhrp_walk.                (* Hchk *)
  Qed.
  (* the wwalk helper (fn_vars = nil, in mario_step) *)
  Lemma Hsasthf :
    call_pres lp bm NoA MWF mario_step._stop_and_set_height_to_floor.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_step.prog mario_step._stop_and_set_height_to_floor
             mario_step.f_stop_and_set_height_to_floor
             sasthf_ids nil sasthf_xids nil
             LO_mario_step sasthf_pin sasthf_vars sasthf_params_ok).
    - exact sasthf_ids_rows.
    - intros fid' H; discriminate H.
    - exact sasthf_xids_rows.
    - intros fid' H; discriminate H.
    - exact sasthf_walk.
  Qed.

  (* ---- B10: add_tree_leaf_particles + act_grab_pole_slow (rest-split) ---- *)
  Lemma atlp_xids_rows :
    forall fid, mem_id fid atlp_xids = true -> call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold atlp_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_stv | ].
    discriminate H.
  Qed.
  Lemma Hatlp :
    call_pres lp bm NoA MWF mario_actions_automatic._add_tree_leaf_particles.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_automatic.prog
             mario_actions_automatic._add_tree_leaf_particles
             mario_actions_automatic.f_add_tree_leaf_particles
             nil nil atlp_xids nil
             LO_aut atlp_pin atlp_vars atlp_params_ok).
    - intros fid' H; discriminate H.
    - intros fid' H; discriminate H.
    - exact atlp_xids_rows.
    - intros fid' H; discriminate H.
    - exact atlp_walk.
  Qed.

  (* ---- set_pole_position: the 730-line SHARED pole helper, WALKED.  This
     DISCHARGES the old Hcp_spp residual (was an opaque whole-function
     Hypothesis) by walking the entire body via call_pres_of_lwalk3 (the
     lids+cact producer): out-param writers find_floor/vec3f_find_ceil into the
     _floor/_ceil stack locals (oc), window writer f32_find_wall_collision (wc),
     object writers vec3f_copy/vec3s_set chasing m->marioObj into SafeB (sc),
     set_mario_action (sids/Hsmact), chase temps (cact) + stack out-param
     locals (lids).  The single opaque assumption decomposes into the precise,
     true-in-model, dischargeable gated-external residuals. ---- *)
  Lemma spp_oc_rows :
    forall fid, mem_id fid spp_oc_pids = true ->
                call_pres_ext_oc lp bm NoA MWF SafeB fid.
  Proof.
    intros fid H. unfold spp_oc_pids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hocp_find_floor | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hocp_find_ceil | ].
    discriminate H.
  Qed.
  Lemma spp_wc_rows :
    forall fid, mem_id fid spp_wc_pids = true ->
                call_pres_ext_wc lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold spp_wc_pids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hwcp_fwc | ].
    discriminate H.
  Qed.
  Lemma spp_sc_rows :
    forall fid, mem_id fid spp_sc_pids = true ->
                call_pres_ext_sc lp bm NoA MWF SafeB fid.
  Proof.
    intros fid H. unfold spp_sc_pids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hscp_v3f | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hscp_v3s | ].
    discriminate H.
  Qed.
  Lemma spp_sids_rows :
    forall fid, mem_id fid spp_sids = true -> call_pres_act lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold spp_sids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsmact | ].
    discriminate H.
  Qed.
  Lemma Hcp_spp :
    call_pres lp bm NoA MWF mario_actions_automatic._set_pole_position.
  Proof.
    apply (call_pres_of_lwalk3 lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             HMWF_alloc HMWF_free
             mario_actions_automatic.prog
             mario_actions_automatic._set_pole_position
             mario_actions_automatic.f_set_pole_position
             nil nil spp_cact nil spp_sids spp_lids spp_oc_pids spp_wc_pids
             spp_sc_pids
             LO_aut spp_pin spp_params_ok spp_npc).
    - (* Hdg: stored_globals disjoint from fn_vars=[_filler;_floor;_ceil] *)
      intros g Hg Hin; vm_compute in Hin;
        repeat (destruct Hin as [Heq | Hin];
                [ subst g; vm_compute in Hg; discriminate | ]); exact Hin.
    - intros g HH; discriminate HH.   (* Hdi: ids=nil *)
    - intros g HH; discriminate HH.   (* Hdw: wids=nil *)
    - intros g HH; discriminate HH.   (* Hdx: xids=nil *)
    - (* Hds: sids disjoint from fn_vars *)
      intros g Hg Hin; vm_compute in Hin;
        repeat (destruct Hin as [Heq | Hin];
                [ subst g; vm_compute in Hg; discriminate | ]); exact Hin.
    - (* Hdoc: oc_pids disjoint from fn_vars *)
      intros g Hg Hin; vm_compute in Hin;
        repeat (destruct Hin as [Heq | Hin];
                [ subst g; vm_compute in Hg; discriminate | ]); exact Hin.
    - (* Hdwc: wc_pids disjoint from fn_vars *)
      intros g Hg Hin; vm_compute in Hin;
        repeat (destruct Hin as [Heq | Hin];
                [ subst g; vm_compute in Hg; discriminate | ]); exact Hin.
    - (* Hdsc: sc_pids disjoint from fn_vars *)
      intros g Hg Hin; vm_compute in Hin;
        repeat (destruct Hin as [Heq | Hin];
                [ subst g; vm_compute in Hg; discriminate | ]); exact Hin.
    - (* Hdgt: gGlobalTimer not a local *)
      vm_compute; intro Hin;
        repeat (destruct Hin as [Heq | Hin]; [ discriminate Heq | ]); exact Hin.
    - (* Hlsub: lids=[_floor;_ceil] subset of fn_vars *)
      intros lid Hl; unfold spp_lids in Hl; cbn [mem_id existsb] in Hl;
        repeat (apply orb_true_iff in Hl as [Hm | Hl];
                [ apply Pos.eqb_eq in Hm; subst lid; vm_compute; auto 10 | ]);
        discriminate Hl.
    - exact HSafeValid.
    - exact HGlobValid.
    - exact Hls_real.
    - intros fid' H; discriminate H.   (* Hcp: ids=nil *)
    - intros fid' H; discriminate H.   (* Hcpa: wids=nil *)
    - intros fid' H; discriminate H.   (* Hcpx: xids=nil *)
    - exact spp_sids_rows.             (* Hcps: sids *)
    - exact spp_oc_rows.               (* Hcpoc: oc_pids *)
    - exact spp_wc_rows.               (* Hcpwc: wc_pids *)
    - exact spp_sc_rows.               (* Hcpsc: sc_pids *)
    - exact spp_walk.                  (* Hchk *)
  Qed.

  (* ---- act_holding_pole rows + the leaf (after Hcp_spp, which ahp_ids
     consumes for the set_pole_position call) ---- *)
  Lemma ahp_ids_rows :
    forall fid, mem_id fid ahp_ids = true -> call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold ahp_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hpcs | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_spp | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsma | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hatlp | ].
    discriminate H.
  Qed.
  Lemma ahp_xids_rows :
    forall fid, mem_id fid ahp_xids = true -> call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold ahp_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_ssms | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_stv | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_vts | ].
    discriminate H.
  Qed.
  Lemma act_holding_pole_pres :
    body_pres lp NoA MWF bm mario_actions_automatic.f_act_holding_pole.
  Proof.
    apply (body_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_automatic.f_act_holding_pole
             ahp_ids nil ahp_cact ahp_xids hang_sids nil
             ahp_vars ahp_params_ok ahp_nonparam_c).
    - exact ahp_ids_rows.
    - intros fid' H; discriminate H.
    - exact ahp_xids_rows.
    - (* sids = hang_sids = [set_mario_action]; inline (hang_sids_rows is
         declared later in the file) *)
      intros fid' H'. unfold hang_sids in H'. cbn [mem_id existsb] in H'.
      apply orb_true_iff in H' as [Hm | H'];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hsmact | ].
      discriminate H'.
    - intros fid' H; discriminate H.
    - exact ahp_walk.
  Qed.

  (* ---- B12 act_climbing_pole: the LAST pole leaf.  The blocker was
     set_mario_anim_with_accel's third arg (the stick-derived _sp24): a
     raw scalar with no act_inv/untainted story.  The np3 channel threads
     exactly the fact the MWF chase row needs -- the value is non-Vptr
     (float-to-int cast = cast_case_s2i; never the ptr32 i2i passthrough)
     -- from the call-site census (nids) into smawa's animAccel store.
     automatic_rest_ids 3 -> 2. ---- *)
  Lemma Hsmawa :
    call_pres_np3 lp bm NoA MWF mario._set_mario_anim_with_accel.
  Proof.
    apply (call_pres_np3_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario.prog mario._set_mario_anim_with_accel
             mario.f_set_mario_anim_with_accel
             nil nil smawa_cact sma_xids nil
             LO_mario smawa_pin smawa_vars smawa_params
             smawa_cact_m smawa_cact_anim smawa_cact_acc).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sma_xids_rows.
    - intros fid' H. discriminate H.
    - exact smawa_walk.
  Qed.
  Lemma acp_ids_rows :
    forall fid, mem_id fid acp_ids = true -> call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold acp_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hatlp | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hpcs | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_spp | ].
    discriminate H.
  Qed.
  Lemma acp_xids_rows :
    forall fid, mem_id fid acp_xids = true -> call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold acp_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_approach | ].
    discriminate H.
  Qed.
  Lemma act_climbing_pole_pres :
    body_pres lp NoA MWF bm mario_actions_automatic.f_act_climbing_pole.
  Proof.
    apply (body_pres_of_wwalk_nids lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_automatic.f_act_climbing_pole
             acp_ids nil acp_cact acp_xids hang_sids nil acp_nids acp_np3_ids
             acp_vars acp_params_ok acp_nonparam_c acp_nonparam_n).
    - exact acp_ids_rows.
    - intros fid' H; discriminate H.
    - exact acp_xids_rows.
    - intros fid' H'. unfold hang_sids in H'. cbn [mem_id existsb] in H'.
      apply orb_true_iff in H' as [Hm | H'];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hsmact | ].
      discriminate H'.
    - intros fid' H; discriminate H.
    - intros fid' H'. unfold acp_np3_ids in H'. cbn [mem_id existsb] in H'.
      apply orb_true_iff in H' as [Hm | H'];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hsmawa | ].
      discriminate H'.
    - exact acp_walk.
  Qed.

  (* ---- B11 top-of-pole pair: BOTH reduce to the single Hrmayt helper ---- *)
  Lemma atop_ids_rows :
    forall fid, mem_id fid atop_ids = true -> call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold atop_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsma | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hrmayt | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_spp | ].
    discriminate H.
  Qed.
  Lemma act_top_of_pole_pres :
    body_pres lp NoA MWF bm mario_actions_automatic.f_act_top_of_pole.
  Proof.
    apply (body_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_automatic.f_act_top_of_pole
             atop_ids nil atop_cact nil hang_sids nil
             atop_vars atop_params_ok atop_nonparam_c).
    - exact atop_ids_rows.
    - intros fid' H; discriminate H.
    - intros fid' H; discriminate H.
    - intros fid' H'. unfold hang_sids in H'. cbn [mem_id existsb] in H'.
      apply orb_true_iff in H' as [Hm | H'];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hsmact | ].
      discriminate H'.
    - intros fid' H; discriminate H.
    - exact atop_walk.
  Qed.
  Lemma atopt_ids_rows :
    forall fid, mem_id fid atopt_ids = true -> call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold atopt_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsma | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hiaae | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hrmayt | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_spp | ].
    discriminate H.
  Qed.
  Lemma act_top_of_pole_transition_pres :
    body_pres lp NoA MWF bm mario_actions_automatic.f_act_top_of_pole_transition.
  Proof.
    apply (body_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_automatic.f_act_top_of_pole_transition
             atopt_ids nil atopt_cact nil hang_sids nil
             atopt_vars atopt_params_ok atopt_nonparam_c).
    - exact atopt_ids_rows.
    - intros fid' H; discriminate H.
    - intros fid' H; discriminate H.
    - intros fid' H'. unfold hang_sids in H'. cbn [mem_id existsb] in H'.
      apply orb_true_iff in H' as [Hm | H'];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hsmact | ].
      discriminate H'.
    - intros fid' H; discriminate H.
    - exact atopt_walk.
  Qed.

  (* ---- B11 act_hang_moving rows ---- *)
  Lemma ahm_ids_rows :
    forall fid, mem_id fid ahm_ids = true -> call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold ahm_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsma | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hiape | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Huhm | ].
    discriminate H.
  Qed.
  Lemma ahm_xids_rows :
    forall fid, mem_id fid ahm_xids = true -> call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold ahm_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_psound | ].
    discriminate H.
  Qed.
  Lemma act_hang_moving_pres :
    body_pres lp NoA MWF bm mario_actions_automatic.f_act_hang_moving.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_automatic.f_act_hang_moving
             ahm_ids nil ahm_xids hang_sids nil ahm_vars ahm_params_ok).
    - exact ahm_ids_rows.
    - intros fid' H; discriminate H.
    - exact ahm_xids_rows.
    - intros fid' H'. unfold hang_sids in H'. cbn [mem_id existsb] in H'.
      apply orb_true_iff in H' as [Hm | H'];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hsmact | ].
      discriminate H'.
    - intros fid' H; discriminate H.
    - exact ahm_walk.
  Qed.

  Lemma agps_ids_rows :
    forall fid, mem_id fid agps_ids = true -> call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold agps_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hpsinf | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_spp | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsma | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hiaae | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hatlp | ].
    discriminate H.
  Qed.
  Lemma agps_sids_rows :
    forall fid, mem_id fid agps_sids = true -> call_pres_act lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold agps_sids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsmact | ].
    discriminate H.
  Qed.
  Lemma Hagps :
    body_pres lp NoA MWF bm mario_actions_automatic.f_act_grab_pole_slow.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_automatic.f_act_grab_pole_slow
             agps_ids nil nil agps_sids nil agps_vars agps_params_ok).
    - exact agps_ids_rows.
    - intros fid' H; discriminate H.
    - intros fid' H; discriminate H.
    - exact agps_sids_rows.
    - intros fid' H; discriminate H.
    - exact agps_walk.
  Qed.

  (* act_grab_pole_fast: same callee rows as agps, plus the cact chase
     ([_marioObj]) carrying the computed-i32 store into marioObj->rawData. *)
  Lemma act_grab_pole_fast_pres :
    body_pres lp NoA MWF bm mario_actions_automatic.f_act_grab_pole_fast.
  Proof.
    apply (body_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_automatic.f_act_grab_pole_fast
             agps_ids nil agpf_cact nil agps_sids nil
             agpf_vars agpf_params_ok agpf_nonparam_c).
    - exact agps_ids_rows.
    - intros fid' H; discriminate H.
    - intros fid' H; discriminate H.
    - exact agps_sids_rows.
    - intros fid' H; discriminate H.
    - exact agpf_walk.
  Qed.

  (* the act_ledge_grab leaf: ids = the cluster, sids = set_mario_action *)
  Lemma alg_ids_rows :
    forall fid, mem_id fid alg_ids = true -> call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold alg_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hlgl | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hffhrp | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsasthf | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsma | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hpsinf | ].
    discriminate H.
  Qed.
  Lemma alg_sids_rows :
    forall fid, mem_id fid alg_sids = true -> call_pres_act lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold alg_sids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsmact | ].
    discriminate H.
  Qed.
  Lemma act_ledge_grab_pres :
    body_pres lp NoA MWF bm mario_actions_automatic.f_act_ledge_grab.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_automatic.f_act_ledge_grab
             alg_ids nil nil alg_sids nil alg_vars alg_params_ok).
    - exact alg_ids_rows.
    - intros fid' H; discriminate H.
    - intros fid' H; discriminate H.
    - exact alg_sids_rows.
    - intros fid' H; discriminate H.
    - exact alg_walk.
  Qed.

  (* ---- the LEDGE-CLIMB cluster rows (the act3 path) ---- *)
  Lemma cul_ids_rows :
    forall fid, mem_id fid cul_ids = true -> call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold cul_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsma | ].
    discriminate H.
  Qed.
  Lemma cul_xids_rows :
    forall fid, mem_id fid cul_xids = true -> call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold cul_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_v3f | ].
    discriminate H.
  Qed.
  Lemma Hcul : call_pres lp bm NoA MWF mario_actions_automatic._climb_up_ledge.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_automatic.prog
             mario_actions_automatic._climb_up_ledge
             mario_actions_automatic.f_climb_up_ledge
             cul_ids nil cul_xids nil
             LO_aut cul_pin cul_vars cul_params_ok).
    - exact cul_ids_rows.
    - intros fid' H; discriminate H.
    - exact cul_xids_rows.
    - intros fid' H; discriminate H.
    - exact cul_walk.
  Qed.

  Lemma ulc_ids_rows :
    forall fid, mem_id fid ulc_ids = true -> call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold ulc_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsasthf | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsma | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hiaae | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcul | ].
    discriminate H.
  Qed.
  Lemma ulc_sids_rows :
    forall fid, mem_id fid ulc_sids = true -> call_pres_act lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold ulc_sids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsmact | ].
    discriminate H.
  Qed.
  (* update_ledge_climb: the 3rd-position action writer (call_pres_act3) *)
  Lemma Hulc :
    call_pres_act3 lp bm NoA MWF mario_actions_automatic._update_ledge_climb.
  Proof.
    apply (call_pres_act3_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_automatic.prog _
             mario_actions_automatic.f_update_ledge_climb
             ulc_wact ulc_ids nil nil nil ulc_sids
             LO_aut ulc_pin ulc_vars ulc_params
             eq_refl eq_refl eq_refl eq_refl eq_refl eq_refl).
    - exact ulc_ids_rows.
    - intros fid' H; discriminate H.
    - intros fid' H; discriminate H.
    - exact ulc_sids_rows.
    - exact ulc_walk.
  Qed.

  (* the act_ledge_climb_down leaf: ids=[lgl,psinf], tids=[update_ledge_climb] *)
  Lemma alcd_ids_rows :
    forall fid, mem_id fid alcd_ids = true -> call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold alcd_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hlgl | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hpsinf | ].
    discriminate H.
  Qed.
  Lemma alcd_tids_rows :
    forall fid, mem_id fid alcd_tids = true -> call_pres_act3 lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold alcd_tids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hulc | ].
    discriminate H.
  Qed.
  Lemma act_ledge_climb_down_pres :
    body_pres lp NoA MWF bm mario_actions_automatic.f_act_ledge_climb_down.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_automatic.f_act_ledge_climb_down
             alcd_ids nil nil nil alcd_tids alcd_vars alcd_params_ok).
    - exact alcd_ids_rows.
    - intros fid' H; discriminate H.
    - intros fid' H; discriminate H.
    - intros fid' H; discriminate H.
    - exact alcd_tids_rows.
    - exact alcd_walk.
  Qed.

  (* ---- the LEDGE-CLIMB FAST cluster rows (chase-store camera + sound) ---- *)
  (* update_ledge_climb_camera: a CHASE-STORE leaf -- writes through
     m->statusForCamera (a tabled chase root); cact=[_t'9;_t'5;_t'3]. *)
  Lemma Hulcc :
    call_pres lp bm NoA MWF mario_actions_automatic._update_ledge_climb_camera.
  Proof.
    apply (call_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_automatic.prog
             mario_actions_automatic._update_ledge_climb_camera
             mario_actions_automatic.f_update_ledge_climb_camera
             nil nil ulcc_cact nil nil
             LO_aut ulcc_pin ulcc_vars ulcc_params_ok ulcc_nonparam).
    - intros fid' H; discriminate H.
    - intros fid' H; discriminate H.
    - intros fid' H; discriminate H.
    - intros fid' H; discriminate H.
    - exact ulcc_walk.
  Qed.

  (* the sound chain: play_mario_landing_sound -> play_sound_and_spawn_
     particles -> the audio external play_sound *)
  Lemma psasp_xids_rows :
    forall fid, mem_id fid psasp_xids = true -> call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold psasp_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_psound | ].
    discriminate H.
  Qed.
  Lemma Hpsasp :
    call_pres lp bm NoA MWF mario._play_sound_and_spawn_particles.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario.prog mario._play_sound_and_spawn_particles
             mario.f_play_sound_and_spawn_particles
             nil nil psasp_xids nil
             LO_mario psasp_pin psasp_vars psasp_params_ok).
    - intros fid' H; discriminate H.
    - intros fid' H; discriminate H.
    - exact psasp_xids_rows.
    - intros fid' H; discriminate H.
    - exact psasp_walk.
  Qed.
  Lemma pmls_ids_rows :
    forall fid, mem_id fid pmls_ids = true -> call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold pmls_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hpsasp | ].
    discriminate H.
  Qed.
  Lemma Hpmls :
    call_pres lp bm NoA MWF mario._play_mario_landing_sound.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario.prog mario._play_mario_landing_sound
             mario.f_play_mario_landing_sound
             pmls_ids nil nil nil
             LO_mario pmls_pin pmls_vars pmls_params_ok).
    - exact pmls_ids_rows.
    - intros fid' H; discriminate H.
    - intros fid' H; discriminate H.
    - intros fid' H; discriminate H.
    - exact pmls_walk.
  Qed.

  (* the act_ledge_climb_fast leaf: ids=[lgl;psinf;pmls;ulcc],
     cact=[_t'2] (marioObj gate read), tids=[update_ledge_climb] *)
  Lemma alcf_ids_rows :
    forall fid, mem_id fid alcf_ids = true -> call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold alcf_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hlgl | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hpsinf | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hpmls | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hulcc | ].
    discriminate H.
  Qed.
  Lemma alcf_tids_rows :
    forall fid, mem_id fid alcf_tids = true -> call_pres_act3 lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold alcf_tids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hulc | ].
    discriminate H.
  Qed.
  Lemma act_ledge_climb_fast_pres :
    body_pres lp NoA MWF bm mario_actions_automatic.f_act_ledge_climb_fast.
  Proof.
    apply (body_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_automatic.f_act_ledge_climb_fast
             alcf_ids nil alcf_cact nil nil alcf_tids
             alcf_vars alcf_params_ok alcf_nonparam_c).
    - exact alcf_ids_rows.
    - intros fid' H; discriminate H.
    - intros fid' H; discriminate H.
    - intros fid' H; discriminate H.
    - exact alcf_tids_rows.
    - exact alcf_walk.
  Qed.

  (* ---- the LEDGE-CLIMB SLOW cluster rows (const-action-store leaf) ---- *)
  (* check_common_action_exits: the four smact-const exits (sids reuses
     lgl_sids = [set_mario_action]); mirrors ObjectLeafSurface.ccae_row. *)
  Lemma Hccae : call_pres lp bm NoA MWF mario._check_common_action_exits.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario.prog mario._check_common_action_exits
             mario.f_check_common_action_exits
             nil nil nil lgl_sids
             LO_mario ccae_pin ccae_vars ccae_params_ok).
    - intros fid' H; discriminate H.
    - intros fid' H; discriminate H.
    - intros fid' H; discriminate H.
    - exact lgl_sids_rows.
    - exact ccae_walk.
  Qed.

  (* the act_ledge_climb_slow leaf: ids=[lgl;cul;ccae;psinf;ulcc],
     cact=[_t'4] (marioObj gate read), tids=[update_ledge_climb]; the
     m->action=1357 inline store rides the const_act_store_chk arm. *)
  Lemma cs_ids_rows :
    forall fid, mem_id fid cs_ids = true -> call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold cs_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hlgl | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcul | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hccae | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hpsinf | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hulcc | ].
    discriminate H.
  Qed.
  Lemma cs_tids_rows :
    forall fid, mem_id fid cs_tids = true -> call_pres_act3 lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold cs_tids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hulc | ].
    discriminate H.
  Qed.
  Lemma act_ledge_climb_slow_pres :
    body_pres lp NoA MWF bm mario_actions_automatic.f_act_ledge_climb_slow.
  Proof.
    apply (body_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_automatic.f_act_ledge_climb_slow
             cs_ids nil cs_cact nil nil cs_tids
             cs_vars cs_params_ok cs_nonparam_c).
    - exact cs_ids_rows.
    - intros fid' H; discriminate H.
    - intros fid' H; discriminate H.
    - intros fid' H; discriminate H.
    - exact cs_tids_rows.
    - exact cs_walk.
  Qed.

  (* ================================================================== *)
  (* act_tornado_twirling (the Tier-2 consumer): the ~900-line leaf body  *)
  (* is wwalk-clean EXCEPT three call sites --                           *)
  (*   f32_find_wall_collision(&nextPos[0..2], c, c)  (all out-ptrs into  *)
  (*     the stack-local _nextPos -> the ol/args_all_local gate,          *)
  (*     Holcp_f32fwc, a terminal external in EVERY TU), and              *)
  (*   vec3f_copy(m->pos, nextPos)  (dst = the 12-byte m->pos bm-window   *)
  (*     -> the w1/arg0_window gate, the EXISTING Hw1cp_v3f row; its      *)
  (*     OTHER site vec3f_copy(marioObj->..gfx.pos, m->pos) rides the     *)
  (*     generic sc arm with _t'9 censused).                              *)
  (* Rather than threading two new pid channels through the whole wwalk   *)
  (* engine (14 producers, 7 files), the leaf gets a HYBRID walker:       *)
  (* twl_chk falls back on wwalk_chk' for every generic subtree and       *)
  (* special-cases exactly those two call shapes; twl_pres mirrors        *)
  (* wwalk_pres's invariant tuple, so each generic subtree is discharged  *)
  (* by ONE wwalk_pres call and only the special sites get bespoke gate   *)
  (* discharges (local_arr_elem_val / pos_window_val).                    *)
  (* ================================================================== *)

  Definition twl_lids : list ident :=
    mario_actions_automatic._floor :: mario_actions_automatic._nextPos :: nil.
  Definition twl_oc : list ident := mario._find_floor :: nil.
  Definition twl_sc : list ident :=
    mario_actions_automatic._vec3s_set
      :: mario_actions_automatic._vec3f_copy :: nil.
  Definition twl_ids : list ident :=
    mario._set_mario_animation :: mario._is_anim_past_end :: nil.
  Definition twl_cact : list ident :=
    mario_actions_automatic._marioObj :: mario_actions_automatic._t'6
      :: mario_actions_automatic._t'9 :: nil.
  Definition twl_xids : list ident := mario._play_sound :: nil.
  Definition twl_sids : list ident := mario._set_mario_action :: nil.

  (* one stack-local array-elem out-ptr arg: &nextPos[i] *)
  Definition twl_lc_arg (a : expr) : bool :=
    match a with
    | Ebinop Oadd (Evar lid aty) (Econst_int _ ity) pty =>
        Pos.eqb lid mario_actions_automatic._nextPos
        && proj_sumbool (type_eq aty (tarray tfloat 3))
        && proj_sumbool (type_eq ity tint)
        && proj_sumbool (type_eq pty (tptr tfloat))
    | _ => false
    end.

  (* one float-constant arg (the wall-collision radius/offset thresholds) *)
  Definition twl_sg_arg (a : expr) : bool :=
    match a with Econst_single _ _ => true | _ => false end.

  (* the m->pos dst of the w1 vec3f_copy site (the whole-array decay) *)
  Definition twl_v3f_dst (a : expr) : bool :=
    match a with
    | Efield (Ederef (Etempvar p pty) sty) fld faty =>
        Pos.eqb p mario_actions_automatic._m
        && proj_sumbool
             (type_eq pty
                (tptr (Tstruct mario_actions_automatic._MarioState noattr)))
        && proj_sumbool
             (type_eq sty (Tstruct mario_actions_automatic._MarioState noattr))
        && Pos.eqb fld mario_actions_automatic._pos
        && proj_sumbool (type_eq faty (tarray tfloat 3))
    | _ => false
    end.

  (* the two SPECIAL call shapes (result-less; everything else is generic).
     The list patterns bind plain VARIABLES with per-element helper booleans
     -- a multi-column deep pattern leaves STUCK all-false matches the
     decode's discriminate cannot kill (the wind-walk recognizer gotcha). *)
  Definition twl_sp_chk (s : statement) : bool :=
    match s with
    | Scall None (Evar fid fty) al =>
        (Pos.eqb fid mario_actions_automatic._f32_find_wall_collision
         && proj_sumbool
              (type_eq fty
                 (Tfunction (tptr tfloat :: tptr tfloat :: tptr tfloat ::
                             tfloat :: tfloat :: nil) tint cc_default))
         && match al with
            | a0 :: a1 :: a2 :: a3 :: a4 :: nil =>
                twl_lc_arg a0 && twl_lc_arg a1 && twl_lc_arg a2
                && twl_sg_arg a3 && twl_sg_arg a4
            | _ => false
            end)
        || (Pos.eqb fid mario_actions_automatic._vec3f_copy
            && proj_sumbool
                 (type_eq fty
                    (Tfunction (tptr tfloat :: tptr tfloat :: nil)
                       (tptr tvoid) cc_default))
            && match al with
               | d0 :: d1 :: nil => twl_v3f_dst d0
               | _ => false
               end)
    | _ => false
    end.

  Fixpoint twl_chk (s : statement) : bool :=
    wwalk_chk' twl_lids twl_oc nil twl_sc nil nil false
      nil twl_ids nil twl_cact twl_xids twl_sids nil s
    || match s with
       | Ssequence s1 s2 => twl_chk s1 && twl_chk s2
       | Sifthenelse _ s1 s2 => twl_chk s1 && twl_chk s2
       | _ => twl_sp_chk s
       end.

  Lemma twl_lc_arg_shape :
    forall a, twl_lc_arg a = true ->
      exists i, a = Ebinop Oadd
                      (Evar mario_actions_automatic._nextPos (tarray tfloat 3))
                      (Econst_int i tint) (tptr tfloat).
  Proof.
    intros a H. unfold twl_lc_arg in H.
    destruct a as [ | | | | | | | | | op b1 b2 bty | | | | ];
      try discriminate H.
    destruct op; try discriminate H.
    destruct b1 as [ | | | | lid aty | | | | | | | | | ]; try discriminate H.
    destruct b2 as [ i ity | | | | | | | | | | | | | ]; try discriminate H.
    apply andb_prop in H as [H Hpty].
    apply andb_prop in H as [H Hity].
    apply andb_prop in H as [Hlid Haty].
    apply Pos.eqb_eq in Hlid. subst lid.
    destruct (type_eq aty (tarray tfloat 3)); [ subst aty | discriminate Haty ].
    destruct (type_eq ity tint); [ subst ity | discriminate Hity ].
    destruct (type_eq bty (tptr tfloat)); [ subst bty | discriminate Hpty ].
    exists i. reflexivity.
  Qed.

  Lemma twl_sp_call_shape :
    forall optid a al,
      twl_sp_chk (Scall optid a al) = true ->
      optid = None /\
      ( (exists i0 i1 i2 c3 t3 c4 t4,
           a = Evar mario_actions_automatic._f32_find_wall_collision
                 (Tfunction (tptr tfloat :: tptr tfloat :: tptr tfloat
                             :: tfloat :: tfloat :: nil) tint cc_default) /\
           al = Ebinop Oadd (Evar mario_actions_automatic._nextPos
                               (tarray tfloat 3)) (Econst_int i0 tint)
                  (tptr tfloat)
                :: Ebinop Oadd (Evar mario_actions_automatic._nextPos
                                  (tarray tfloat 3)) (Econst_int i1 tint)
                     (tptr tfloat)
                :: Ebinop Oadd (Evar mario_actions_automatic._nextPos
                                  (tarray tfloat 3)) (Econst_int i2 tint)
                     (tptr tfloat)
                :: Econst_single c3 t3 :: Econst_single c4 t4 :: nil)
        \/ (exists arest,
           a = Evar mario_actions_automatic._vec3f_copy
                 (Tfunction (tptr tfloat :: tptr tfloat :: nil)
                    (tptr tvoid) cc_default) /\
           al = Efield (Ederef (Etempvar mario_actions_automatic._m
                                  (tptr (Tstruct
                                           mario_actions_automatic._MarioState
                                           noattr)))
                          (Tstruct mario_actions_automatic._MarioState noattr))
                  mario_actions_automatic._pos (tarray tfloat 3)
                :: arest :: nil) ).
  Proof.
    intros optid a al H.
    destruct optid as [t'|]; [ discriminate H | ].
    split; [ reflexivity | ].
    destruct a as [ | | | | cid ftyv | | | | | | | | | ];
      try discriminate H.
    unfold twl_sp_chk in H.
    apply orb_true_iff in H as [Hf | Hv].
    - left.
      apply andb_prop in Hf as [Hf Hal].
      apply andb_prop in Hf as [Hfid Hfty].
      apply Pos.eqb_eq in Hfid. subst cid.
      destruct (type_eq ftyv (Tfunction (tptr tfloat :: tptr tfloat
                  :: tptr tfloat :: tfloat :: tfloat :: nil) tint cc_default));
        [ subst ftyv | discriminate Hfty ].
      destruct al as [|a0 [|a1 [|a2 [|a3 [|a4 [|a5 al']]]]]];
        try discriminate Hal.
      apply andb_prop in Hal as [Hal Hsg4].
      apply andb_prop in Hal as [Hal Hsg3].
      apply andb_prop in Hal as [Hal Ha2].
      apply andb_prop in Hal as [Ha0 Ha1].
      destruct a3 as [ | | c3 t3 | | | | | | | | | | | ];
        try discriminate Hsg3.
      destruct a4 as [ | | c4 t4 | | | | | | | | | | | ];
        try discriminate Hsg4.
      destruct (twl_lc_arg_shape _ Ha0) as (i0 & ->).
      destruct (twl_lc_arg_shape _ Ha1) as (i1 & ->).
      destruct (twl_lc_arg_shape _ Ha2) as (i2 & ->).
      exists i0, i1, i2, c3, t3, c4, t4. split; reflexivity.
    - right.
      apply andb_prop in Hv as [Hv Hal].
      apply andb_prop in Hv as [Hfid Hfty].
      apply Pos.eqb_eq in Hfid. subst cid.
      destruct (type_eq ftyv (Tfunction (tptr tfloat :: tptr tfloat :: nil)
                  (tptr tvoid) cc_default));
        [ subst ftyv | discriminate Hfty ].
      destruct al as [|d0 [|d1 [|d2 al']]]; try discriminate Hal.
      unfold twl_v3f_dst in Hal.
      destruct d0 as [ | | | | | | | | | | | e0 fld faty | | ];
        try discriminate Hal.
      destruct e0 as [ | | | | | | e1 sty | | | | | | | ];
        try discriminate Hal.
      destruct e1 as [ | | | | | p pty | | | | | | | | ];
        try discriminate Hal.
      apply andb_prop in Hal as [Hal Hfaty].
      apply andb_prop in Hal as [Hal Hfld].
      apply andb_prop in Hal as [Hal Hsty].
      apply andb_prop in Hal as [Hp Hpty].
      apply Pos.eqb_eq in Hp. subst p.
      apply Pos.eqb_eq in Hfld. subst fld.
      destruct (type_eq pty (tptr (Tstruct mario_actions_automatic._MarioState
                                     noattr)));
        [ subst pty | discriminate Hpty ].
      destruct (type_eq sty (Tstruct mario_actions_automatic._MarioState
                               noattr));
        [ subst sty | discriminate Hsty ].
      destruct (type_eq faty (tarray tfloat 3));
        [ subst faty | discriminate Hfaty ].
      exists d1. split; reflexivity.
  Qed.

  (* eval of &nextPos[i] (a local-array element address): the value is a
     pointer INTO the bound local block, whatever the index -- the
     args_all_local gate needs only the block, not offset geometry. *)
  Lemma local_arr_elem_val :
    forall e le m lid lblk tyenv i v,
      e ! lid = Some (lblk, tyenv) ->
      eval_expr (lp_ge lp) e le m
        (Ebinop Oadd (Evar lid (tarray tfloat 3)) (Econst_int i tint)
           (tptr tfloat)) v ->
      exists o, v = Vptr lblk o.
  Proof.
    intros e le m lid lblk tyenv i v Hbind Hev.
    inv Hev;
      [ | match goal with
          | Hlv : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ => inv Hlv
          end ].
    match goal with
    | Hi : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
        inv Hi;
        try (match goal with
             | Hlv : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ => inv Hlv
             end)
    end.
    match goal with
    | Ha : eval_expr _ _ _ _ (Evar _ _) _ |- _ => inv Ha
    end.
    match goal with
    | Hev2 : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ =>
        destruct (eval_lvalue_Evar_local_pin' lp _ _ _ _ _ _ _ _ _ _
                    Hbind Hev2) as [-> ->]
    end.
    match goal with
    | Hd : deref_loc (typeof _) _ _ _ _ _ |- _ => cbn [typeof] in Hd
    end.
    match goal with
    | Hd : deref_loc (tarray tfloat 3) _ _ _ _ _ |- _ =>
        inv Hd;
        try (match goal with
             | Hacc : access_mode (tarray tfloat 3) = _ |- _ =>
                 cbn in Hacc; discriminate Hacc
             end);
        try (match goal with
             | Hlb2 : load_bitfield (tarray tfloat 3) _ _ _ _ _ _ _ |- _ =>
                 inv Hlb2
             end)
    end.
    match goal with
    | Hsem : sem_binary_operation _ Oadd _ _ _ _ _ = Some _ |- _ =>
        cbn in Hsem; injection Hsem as <-
    end.
    eexists; reflexivity.
  Qed.

  (* ---- the tornado census rows ---- *)
  Lemma twl_ids_rows :
    forall fid, mem_id fid twl_ids = true -> call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold twl_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsma | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hiape | ].
    discriminate H.
  Qed.
  Lemma twl_xids_rows :
    forall fid, mem_id fid twl_xids = true -> call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold twl_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_psound | ].
    discriminate H.
  Qed.
  Lemma twl_sids_rows :
    forall fid, mem_id fid twl_sids = true -> call_pres_act lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold twl_sids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsmact | ].
    discriminate H.
  Qed.
  Lemma twl_oc_rows :
    forall fid, mem_id fid twl_oc = true ->
                call_pres_ext_oc lp bm NoA MWF SafeB fid.
  Proof.
    intros fid H. unfold twl_oc in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hocp_find_floor | ].
    discriminate H.
  Qed.
  Lemma twl_sc_rows :
    forall fid, mem_id fid twl_sc = true ->
                call_pres_ext_sc lp bm NoA MWF SafeB fid.
  Proof.
    intros fid H. unfold twl_sc in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hscp_v3s | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hscp_v3f | ].
    discriminate H.
  Qed.

  (* the generic-subtree discharger: ONE wwalk_pres call, tornado census *)
  Lemma twl_generic :
    forall s e le m0 tr le' m' out,
      (forall lid, mem_id lid twl_lids = true ->
         exists lblk tyenv, e ! lid = Some (lblk, tyenv) /\
                            local_blk lp bm SafeB lblk) ->
      (forall g, mem_id g stored_globals = true -> e ! g = None) ->
      (forall g, mem_id g twl_ids = true -> e ! g = None) ->
      (forall g, mem_id g twl_xids = true -> e ! g = None) ->
      (forall g, mem_id g twl_sids = true -> e ! g = None) ->
      (forall g, mem_id g twl_oc = true -> e ! g = None) ->
      (forall g, mem_id g twl_sc = true -> e ! g = None) ->
      e ! interaction._gGlobalTimer = None ->
      wwalk_chk' twl_lids twl_oc nil twl_sc nil nil false
        nil twl_ids nil twl_cact twl_xids twl_sids nil s = true ->
      (forall b o, le ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) ->
      act_inv nil le ->
      chase_inv SafeB twl_cact le ->
      NoA m0 -> MWF m0 -> Mem.valid_block m0 bm ->
      action_sat not_tainted m0 bm ->
      exec_stmt function_entry2 (lp_ge lp) e le m0 s tr le' m' out ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\
      NoA m' /\
      (forall b o, le' ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) /\
      act_inv nil le' /\ chase_inv SafeB twl_cact le'.
  Proof.
    intros s e le m0 tr le' m' out Hlocal Hub_g Hub_i Hub_x Hub_s Hub_oc
           Hub_sc Hubgt Hchk Htat Hact Hch HN HM HV HS Hexec.
    destruct (wwalk_pres lp LO_mario bm NoA MWF HNoA_of_MWF HMWF_window
                HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot HMWF_chase
                HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
                false nil twl_ids nil twl_cact twl_xids twl_sids nil
                twl_lids twl_oc nil twl_sc nil nil
                twl_ids_rows
                (fun fid HH => match Bool.diff_false_true HH with end)
                twl_xids_rows twl_sids_rows
                (fun fid HH => match Bool.diff_false_true HH with end)
                twl_oc_rows
                (fun fid HH => match Bool.diff_false_true HH with end)
                twl_sc_rows
                (fun fid HH => match Bool.diff_false_true HH with end)
                _ _ _ _ _ _ _ _
                (fun _ => Hls_real) Hlocal Hexec
                Hub_g Hub_i
                (fun g HH => match Bool.diff_false_true HH with end)
                Hub_x Hub_s
                (fun g HH => match Bool.diff_false_true HH with end)
                Hub_oc
                (fun g HH => match Bool.diff_false_true HH with end)
                Hub_sc
                (fun g HH => match Bool.diff_false_true HH with end)
                Hubgt
                Hchk Htat Hact Hch
                (fun t HH => match Bool.diff_false_true HH with end)
                HN HM HV HS)
      as (HV' & HS' & HM' & HN' & Htat' & Hact' & Hch' & _ & _).
    exact (conj HV' (conj HS' (conj HM' (conj HN'
             (conj Htat' (conj Hact' Hch')))))).
  Qed.

  (* the hybrid walk prover: exec-derivation induction; generic subtrees
     go to twl_generic wholesale, the two special call sites get their
     gate discharges (ol via local_arr_elem_val, w1 via pos_window_val). *)
  Lemma twl_pres :
    forall s e le m0 tr le' m' out,
      (forall lid, mem_id lid twl_lids = true ->
         exists lblk tyenv, e ! lid = Some (lblk, tyenv) /\
                            local_blk lp bm SafeB lblk) ->
      exec_stmt function_entry2 (lp_ge lp) e le m0 s tr le' m' out ->
      (forall g, mem_id g stored_globals = true -> e ! g = None) ->
      (forall g, mem_id g twl_ids = true -> e ! g = None) ->
      (forall g, mem_id g twl_xids = true -> e ! g = None) ->
      (forall g, mem_id g twl_sids = true -> e ! g = None) ->
      (forall g, mem_id g twl_oc = true -> e ! g = None) ->
      (forall g, mem_id g twl_sc = true -> e ! g = None) ->
      e ! mario_actions_automatic._f32_find_wall_collision = None ->
      e ! interaction._gGlobalTimer = None ->
      twl_chk s = true ->
      (forall b o, le ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) ->
      act_inv nil le ->
      chase_inv SafeB twl_cact le ->
      NoA m0 -> MWF m0 -> Mem.valid_block m0 bm ->
      action_sat not_tainted m0 bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\
      NoA m' /\
      (forall b o, le' ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) /\
      act_inv nil le' /\ chase_inv SafeB twl_cact le'.
  Proof.
    intros s e le m0 tr le' m' out Hlocal Hexec.
    induction Hexec;
      intros Hub_g Hub_i Hub_x Hub_s Hub_oc Hub_sc Hf32 Hubgt
             Hchk Htat Hact Hch HN HM HV HS.
    - (* Sskip *)
      exact (conj HV (conj HS (conj HM (conj HN
               (conj Htat (conj Hact Hch)))))).
    - (* Sassign: generic only *)
      cbn [twl_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp];
        [ | cbn [twl_sp_chk] in Hsp; discriminate Hsp ].
      eapply (twl_generic _ _ _ _ _ _ _ _ Hlocal Hub_g Hub_i Hub_x Hub_s
                Hub_oc Hub_sc Hubgt Hg Htat Hact Hch HN HM HV HS);
        eapply exec_Sassign; eauto.
    - (* Sset: generic only *)
      cbn [twl_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp];
        [ | cbn [twl_sp_chk] in Hsp; discriminate Hsp ].
      eapply (twl_generic _ _ _ _ _ _ _ _ Hlocal Hub_g Hub_i Hub_x Hub_s
                Hub_oc Hub_sc Hubgt Hg Htat Hact Hch HN HM HV HS);
        eapply exec_Sset; eauto.
    - (* Scall: generic censused arm, or one of the TWO special sites *)
      cbn [twl_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp].
      { eapply (twl_generic _ _ _ _ _ _ _ _ Hlocal Hub_g Hub_i Hub_x Hub_s
                  Hub_oc Hub_sc Hubgt Hg Htat Hact Hch HN HM HV HS);
          eapply exec_Scall; eauto. }
      destruct (twl_sp_call_shape _ _ _ Hsp) as [-> Hcase].
      cbn [set_opttemp].
      assert (Hc0 : carried bm NoA MWF m)
        by (split; [ exact HV | split; [ exact HS
                   | split; [ exact HM | exact HN ] ] ]).
      destruct Hcase as [ (i0 & i1 & i2 & c3 & t3 & c4 & t4 & -> & ->)
                        | (arest & -> & ->) ].
      + (* f32_find_wall_collision(&nextPos[0..2], c, c): the ol gate *)
        assert (Hex : exec_stmt function_entry2 (lp_ge lp) e le m
                        (Scall None
                           (Evar mario_actions_automatic._f32_find_wall_collision
                              (Tfunction (tptr tfloat :: tptr tfloat
                                          :: tptr tfloat :: tfloat :: tfloat
                                          :: nil) tint cc_default))
                           (Ebinop Oadd (Evar mario_actions_automatic._nextPos
                                           (tarray tfloat 3))
                              (Econst_int i0 tint) (tptr tfloat)
                            :: Ebinop Oadd (Evar mario_actions_automatic._nextPos
                                              (tarray tfloat 3))
                                 (Econst_int i1 tint) (tptr tfloat)
                            :: Ebinop Oadd (Evar mario_actions_automatic._nextPos
                                              (tarray tfloat 3))
                                 (Econst_int i2 tint) (tptr tfloat)
                            :: Econst_single c3 t3 :: Econst_single c4 t4 :: nil))
                        t (set_opttemp None vres le) m' Out_normal)
          by (eapply exec_Scall; eauto).
        assert (Hgate : forall vargs1,
            eval_exprlist (lp_ge lp) e le m
              (Ebinop Oadd (Evar mario_actions_automatic._nextPos
                              (tarray tfloat 3))
                 (Econst_int i0 tint) (tptr tfloat)
               :: Ebinop Oadd (Evar mario_actions_automatic._nextPos
                                 (tarray tfloat 3))
                    (Econst_int i1 tint) (tptr tfloat)
               :: Ebinop Oadd (Evar mario_actions_automatic._nextPos
                                 (tarray tfloat 3))
                    (Econst_int i2 tint) (tptr tfloat)
               :: Econst_single c3 t3 :: Econst_single c4 t4 :: nil)
              (tptr tfloat :: tptr tfloat :: tptr tfloat
               :: tfloat :: tfloat :: nil) vargs1 ->
            args_all_local lp bm SafeB vargs1).
        { intros vargs1 Hvl.
          destruct (Hlocal mario_actions_automatic._nextPos eq_refl)
            as (lblk & tyenv & Hbind & Hlb).
          inversion Hvl as [ | x1 bl1 ty1 tyl1 v1a v2a vl1 Hev_a Hsc_a Htl1 ];
            subst; clear Hvl.
          inversion Htl1 as [ | x2 bl2 ty2 tyl2 v1b v2b vl2 Hev_b Hsc_b Htl2 ];
            subst; clear Htl1.
          inversion Htl2 as [ | x3 bl3 ty3 tyl3 v1c v2c vl3 Hev_c Hsc_c Htl3 ];
            subst; clear Htl2.
          inversion Htl3 as [ | x4 bl4 ty4 tyl4 v1d v2d vl4 Hev_d Hsc_d Htl4 ];
            subst; clear Htl3.
          inversion Htl4 as [ | x5 bl5 ty5 tyl5 v1e v2e vl5 Hev_e Hsc_e Htl5 ];
            subst; clear Htl4.
          inversion Htl5; subst; clear Htl5.
          destruct (local_arr_elem_val _ _ _ _ _ _ _ _ Hbind Hev_a)
            as (o0 & Ev0).
          destruct (local_arr_elem_val _ _ _ _ _ _ _ _ Hbind Hev_b)
            as (o1 & Ev1).
          destruct (local_arr_elem_val _ _ _ _ _ _ _ _ Hbind Hev_c)
            as (o2 & Ev2).
          subst v1a v1b v1c.
          apply eval_Econst_single_val in Hev_d; subst v1d.
          apply eval_Econst_single_val in Hev_e; subst v1e.
          intros bb oo Hin; cbn in Hin.
          destruct Hin as [E | [E | [E | [E | [E | []]]]]]; subst;
            [ apply RealFrameValue.sem_cast_ptr_result_inv in Hsc_a;
              injection Hsc_a as <- <-; exact Hlb
            | apply RealFrameValue.sem_cast_ptr_result_inv in Hsc_b;
              injection Hsc_b as <- <-; exact Hlb
            | apply RealFrameValue.sem_cast_ptr_result_inv in Hsc_c;
              injection Hsc_c as <- <-; exact Hlb
            | apply RealFrameValue.sem_cast_ptr_result_inv in Hsc_d;
              discriminate Hsc_d
            | apply RealFrameValue.sem_cast_ptr_result_inv in Hsc_e;
              discriminate Hsc_e ]. }
        destruct (ol_scall_pres lp bm NoA MWF SafeB None
                    mario_actions_automatic._f32_find_wall_collision
                    (tptr tfloat :: tptr tfloat :: tptr tfloat
                     :: tfloat :: tfloat :: nil) tint cc_default
                    (Ebinop Oadd (Evar mario_actions_automatic._nextPos
                                    (tarray tfloat 3))
                       (Econst_int i0 tint) (tptr tfloat)
                     :: Ebinop Oadd (Evar mario_actions_automatic._nextPos
                                       (tarray tfloat 3))
                          (Econst_int i1 tint) (tptr tfloat)
                     :: Ebinop Oadd (Evar mario_actions_automatic._nextPos
                                       (tarray tfloat 3))
                          (Econst_int i2 tint) (tptr tfloat)
                     :: Econst_single c3 t3 :: Econst_single c4 t4 :: nil)
                    e le m _ _ m' _
                    Hf32 Holcp_f32fwc Hgate Hex Hc0) as (Hc' & _).
        destruct Hc' as (HV' & HS' & HM' & HN').
        exact (conj HV' (conj HS' (conj HM' (conj HN'
                 (conj Htat (conj Hact Hch)))))).
      + (* vec3f_copy(m->pos, _): the dst-window w1 gate *)
        assert (Hex : exec_stmt function_entry2 (lp_ge lp) e le m
                        (Scall None
                           (Evar mario_actions_automatic._vec3f_copy
                              (Tfunction (tptr tfloat :: tptr tfloat :: nil)
                                 (tptr tvoid) cc_default))
                           (Efield (Ederef (Etempvar mario_actions_automatic._m
                                              (tptr (Tstruct
                                                       mario_actions_automatic._MarioState
                                                       noattr)))
                                      (Tstruct mario_actions_automatic._MarioState
                                         noattr))
                              mario_actions_automatic._pos (tarray tfloat 3)
                            :: arest :: nil))
                        t (set_opttemp None vres le) m' Out_normal)
          by (eapply exec_Scall; eauto).
        assert (Hgate : forall vargs1,
            eval_exprlist (lp_ge lp) e le m
              (Efield (Ederef (Etempvar mario_actions_automatic._m
                                 (tptr (Tstruct
                                          mario_actions_automatic._MarioState
                                          noattr)))
                         (Tstruct mario_actions_automatic._MarioState noattr))
                 mario_actions_automatic._pos (tarray tfloat 3)
               :: arest :: nil)
              (tptr tfloat :: tptr tfloat :: nil) vargs1 ->
            arg0_window bm vargs1).
        { intros vargs1 Hvl.
          inversion Hvl as [ | x1 bl1 ty1 tyl1 v1a v2a vl1 Hev_a Hsc_a Htl1 ];
            subst; clear Hvl.
          destruct (pos_window_val _ _ _ _ Htat Hev_a) as (o0 & Ev0 & Hwin0).
          subst v1a. cbn in Hsc_a. injection Hsc_a as <-.
          red. exists o0, vl1. split; [ reflexivity | exact Hwin0 ]. }
        assert (Hvcn : e ! mario_actions_automatic._vec3f_copy = None)
          by (apply Hub_sc; reflexivity).
        destruct (w1_scall_pres lp bm NoA MWF None
                    mario_actions_automatic._vec3f_copy
                    (tptr tfloat :: tptr tfloat :: nil) (tptr tvoid) cc_default
                    (Efield (Ederef (Etempvar mario_actions_automatic._m
                                       (tptr (Tstruct
                                                mario_actions_automatic._MarioState
                                                noattr)))
                               (Tstruct mario_actions_automatic._MarioState
                                  noattr))
                       mario_actions_automatic._pos (tarray tfloat 3)
                     :: arest :: nil)
                    e le m _ _ m' _
                    Hvcn Hw1cp_v3f Hgate Hex Hc0) as (Hc' & _).
        destruct Hc' as (HV' & HS' & HM' & HN').
        exact (conj HV' (conj HS' (conj HM' (conj HN'
                 (conj Htat (conj Hact Hch)))))).
    - (* Sbuiltin: rejected by BOTH arms *)
      cbn [twl_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp];
        [ cbn [wwalk_chk'] in Hg; discriminate Hg
        | cbn [twl_sp_chk] in Hsp; discriminate Hsp ].
    - (* Sseq_1 *)
      cbn [twl_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp].
      { eapply (twl_generic _ _ _ _ _ _ _ _ Hlocal Hub_g Hub_i Hub_x Hub_s
                  Hub_oc Hub_sc Hubgt Hg Htat Hact Hch HN HM HV HS);
          eapply exec_Sseq_1; eauto. }
      apply andb_prop in Hsp as [H1 H2].
      destruct (IHHexec1 Hlocal Hub_g Hub_i Hub_x Hub_s Hub_oc Hub_sc Hf32
                  Hubgt H1 Htat Hact Hch HN HM HV HS)
        as (HV1 & HS1 & HM1 & HN1 & Htat1 & Hact1 & Hch1).
      exact (IHHexec2 Hlocal Hub_g Hub_i Hub_x Hub_s Hub_oc Hub_sc Hf32
               Hubgt H2 Htat1 Hact1 Hch1 HN1 HM1 HV1 HS1).
    - (* Sseq_2 *)
      cbn [twl_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp].
      { eapply (twl_generic _ _ _ _ _ _ _ _ Hlocal Hub_g Hub_i Hub_x Hub_s
                  Hub_oc Hub_sc Hubgt Hg Htat Hact Hch HN HM HV HS);
          eapply exec_Sseq_2; eauto. }
      apply andb_prop in Hsp as [H1 _].
      exact (IHHexec Hlocal Hub_g Hub_i Hub_x Hub_s Hub_oc Hub_sc Hf32
               Hubgt H1 Htat Hact Hch HN HM HV HS).
    - (* Sifthenelse *)
      cbn [twl_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp].
      { eapply (twl_generic _ _ _ _ _ _ _ _ Hlocal Hub_g Hub_i Hub_x Hub_s
                  Hub_oc Hub_sc Hubgt Hg Htat Hact Hch HN HM HV HS);
          eapply exec_Sifthenelse; eauto. }
      apply andb_prop in Hsp as [H1 H2].
      apply IHHexec; try assumption.
      destruct b; assumption.
    - (* Sreturn None *)
      exact (conj HV (conj HS (conj HM (conj HN
               (conj Htat (conj Hact Hch)))))).
    - (* Sreturn (Some a) *)
      exact (conj HV (conj HS (conj HM (conj HN
               (conj Htat (conj Hact Hch)))))).
    - (* Sbreak *)
      exact (conj HV (conj HS (conj HM (conj HN
               (conj Htat (conj Hact Hch)))))).
    - (* Scontinue *)
      exact (conj HV (conj HS (conj HM (conj HN
               (conj Htat (conj Hact Hch)))))).
    - (* Sloop stop1: generic only *)
      cbn [twl_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp];
        [ | cbn [twl_sp_chk] in Hsp; discriminate Hsp ].
      eapply (twl_generic _ _ _ _ _ _ _ _ Hlocal Hub_g Hub_i Hub_x Hub_s
                Hub_oc Hub_sc Hubgt Hg Htat Hact Hch HN HM HV HS);
        eapply exec_Sloop_stop1; eauto.
    - (* Sloop stop2: generic only *)
      cbn [twl_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp];
        [ | cbn [twl_sp_chk] in Hsp; discriminate Hsp ].
      eapply (twl_generic _ _ _ _ _ _ _ _ Hlocal Hub_g Hub_i Hub_x Hub_s
                Hub_oc Hub_sc Hubgt Hg Htat Hact Hch HN HM HV HS);
        eapply exec_Sloop_stop2; eauto.
    - (* Sloop loop: generic only *)
      cbn [twl_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp];
        [ | cbn [twl_sp_chk] in Hsp; discriminate Hsp ].
      eapply (twl_generic _ _ _ _ _ _ _ _ Hlocal Hub_g Hub_i Hub_x Hub_s
                Hub_oc Hub_sc Hubgt Hg Htat Hact Hch HN HM HV HS);
        eapply exec_Sloop_loop; eauto.
    - (* Sswitch: generic only *)
      cbn [twl_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp];
        [ | cbn [twl_sp_chk] in Hsp; discriminate Hsp ].
      eapply (twl_generic _ _ _ _ _ _ _ _ Hlocal Hub_g Hub_i Hub_x Hub_s
                Hub_oc Hub_sc Hubgt Hg Htat Hact Hch HN HM HV HS);
        eapply exec_Sswitch; eauto.
  Qed.

  Lemma att_pin :
    (prog_defmap mario_actions_automatic.prog)
      ! mario_actions_automatic._act_tornado_twirling
    = Some (Gfun (Internal mario_actions_automatic.f_act_tornado_twirling)).
  Proof. vm_compute. reflexivity. Qed.

  (* NON-VACUITY + the walk: the hybrid recognizer accepts the REAL body. *)
  Lemma att_walk :
    twl_chk (fn_body mario_actions_automatic.f_act_tornado_twirling) = true.
  Proof. vm_compute. reflexivity. Qed.

  (* THE LEAF: entry mirrors call_pres_of_lwalk2 (alloc _floor/_nextPos,
     bind _m, the Hlocal constructor, free at exit) + the marg/cact entry
     handling of body_pres_of_wwalk_cact; the body goes to twl_pres. *)
  Lemma act_tornado_twirling_pres :
    body_pres lp NoA MWF bm mario_actions_automatic.f_act_tornado_twirling.
  Proof.
    intros m0 vargs0 t0 mF vres0 Hmargf Hevf HN HM HV HS.
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ =>
      rename He into Hentry end.
    match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
      rename Hx into Hbody end.
    match goal with Hf : Mem.free_list _ _ = Some _ |- _ =>
      rename Hf into Hfree end.
    inv Hentry.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
      rename Ha into Halloc end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ =>
      rename Hb into Hbind end.
    match goal with
    | Hb : exec_stmt _ _ ?E _ _ _ _ _ _ _ |- _ => set (eloc := E) in *
    end.
    assert (Hc0 : carried bm NoA MWF m0)
      by (split; [ exact HV | split; [ exact HS
                 | split; [ exact HM | exact HN ] ] ]).
    pose proof (alloc_variables_carried bm NoA MWF HMWF_alloc HNoA_of_MWF
                  _ _ _ _ _ _ Halloc Hc0) as Hca.
    destruct Hca as (HVa & HSa & HMa & HNa).
    pose proof (alloc_variables_hlocal lp bm SafeB m0 _ eloc _ twl_lids
                  Halloc HV (HSafeValid m0 HM) (HGlobValid m0 HM)
                  ltac:(intros lid Hl; unfold twl_lids, mem_id in Hl;
                        cbn [existsb] in Hl;
                        apply Bool.orb_true_iff in Hl;
                        destruct Hl as [Hm1 | Hl];
                        [ apply Pos.eqb_eq in Hm1; subst lid;
                          vm_compute; left; reflexivity | ];
                        apply Bool.orb_true_iff in Hl;
                        destruct Hl as [Hm1 | Hl];
                        [ apply Pos.eqb_eq in Hm1; subst lid;
                          vm_compute; right; left; reflexivity
                        | discriminate Hl ]))
      as Hlocal.
    (* the Mario-head param shape + entry env facts *)
    assert (Hps : match fn_params mario_actions_automatic.f_act_tornado_twirling
                  with
                  | (i, ty) :: ps =>
                      (Pos.eqb i mario_actions_airborne._m
                       && proj_sumbool (type_eq ty tyMSp)
                       && negb (mem_id mario_actions_airborne._m (map fst ps)))%bool
                  | nil => false
                  end = true) by (vm_compute; reflexivity).
    assert (Hnpc : forallb
              (fun t' => negb (mem_id t'
                 (map fst (fn_params
                             mario_actions_automatic.f_act_tornado_twirling))))
              twl_cact = true) by (vm_compute; reflexivity).
    assert (Hmarg : marg_ok bm vargs0)
      by (apply Hmargf; vm_compute; reflexivity).
    destruct (fn_params mario_actions_automatic.f_act_tornado_twirling)
      as [| [i ty] ps ] eqn:Eps; [ discriminate Hps | ].
    apply andb_prop in Hps as [Hps Hnm].
    apply andb_prop in Hps as [Hi Hty].
    apply Pos.eqb_eq in Hi. subst i.
    destruct (type_eq ty tyMSp); [ subst ty | discriminate Hty ].
    apply negb_true_iff in Hnm.
    destruct vargs0 as [| v0 vrest];
      cbn [bind_parameter_temps] in Hbind; [ discriminate Hbind | ].
    match goal with
    | Hbind' : bind_parameter_temps _ _ _ = Some ?le1 |- _ =>
        assert (Htat0 : forall b o,
                   le1 ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero)
          by (intros b o Hg;
              rewrite (bind_params_other _ _ _ _ _ Hbind' Hnm) in Hg;
              rewrite PTree.gss in Hg; injection Hg as ->;
              cbn in Hmarg; exact Hmarg);
        assert (Hact0 : act_inv nil le1)
          by (intros t' Hmem' x Hg'; discriminate Hmem');
        assert (Hch0 : chase_inv SafeB twl_cact le1)
          by (intros t' Hmem' b o Hg';
              pose proof (forallb_negb_mem_id _ _ _ Hnpc Hmem') as Hf';
              unfold mem_id in Hf'; cbn [map fst existsb] in Hf';
              apply orb_false_iff in Hf' as [Hne_m' Hnps];
              rewrite (bind_params_other _ _ _ _ _ Hbind' Hnps) in Hg';
              rewrite PTree.gso in Hg'
                by (intro EE; rewrite EE, Pos.eqb_refl in Hne_m';
                    discriminate Hne_m');
              pose proof (create_undef_temps_val _ _ _ Hg') as EE;
              discriminate EE)
    end.
    (* the unbound-global facts at the entry env *)
    assert (Hub_g : forall g, mem_id g stored_globals = true ->
                    eloc ! g = None).
    { intros g Hg.
      rewrite (alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc g)
        by (intro Hin; vm_compute in Hin;
            destruct Hin as [E | [E | []]]; subst g;
            vm_compute in Hg; discriminate Hg).
      apply PTree.gempty. }
    assert (Hub_i : forall g, mem_id g twl_ids = true -> eloc ! g = None).
    { intros g Hg.
      rewrite (alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc g)
        by (intro Hin; vm_compute in Hin;
            destruct Hin as [E | [E | []]]; subst g;
            vm_compute in Hg; discriminate Hg).
      apply PTree.gempty. }
    assert (Hub_x : forall g, mem_id g twl_xids = true -> eloc ! g = None).
    { intros g Hg.
      rewrite (alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc g)
        by (intro Hin; vm_compute in Hin;
            destruct Hin as [E | [E | []]]; subst g;
            vm_compute in Hg; discriminate Hg).
      apply PTree.gempty. }
    assert (Hub_s : forall g, mem_id g twl_sids = true -> eloc ! g = None).
    { intros g Hg.
      rewrite (alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc g)
        by (intro Hin; vm_compute in Hin;
            destruct Hin as [E | [E | []]]; subst g;
            vm_compute in Hg; discriminate Hg).
      apply PTree.gempty. }
    assert (Hub_oc : forall g, mem_id g twl_oc = true -> eloc ! g = None).
    { intros g Hg.
      rewrite (alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc g)
        by (intro Hin; vm_compute in Hin;
            destruct Hin as [E | [E | []]]; subst g;
            vm_compute in Hg; discriminate Hg).
      apply PTree.gempty. }
    assert (Hub_sc : forall g, mem_id g twl_sc = true -> eloc ! g = None).
    { intros g Hg.
      rewrite (alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc g)
        by (intro Hin; vm_compute in Hin;
            destruct Hin as [E | [E | []]]; subst g;
            vm_compute in Hg; discriminate Hg).
      apply PTree.gempty. }
    assert (Hf32n : eloc ! mario_actions_automatic._f32_find_wall_collision
                    = None).
    { rewrite (alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc
                 mario_actions_automatic._f32_find_wall_collision)
        by (intro Hin; vm_compute in Hin;
            destruct Hin as [E | [E | []]]; discriminate E).
      apply PTree.gempty. }
    assert (Hub_gt : eloc ! interaction._gGlobalTimer = None).
    { rewrite (alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc
                 interaction._gGlobalTimer)
        by (intro Hin; vm_compute in Hin;
            destruct Hin as [E | [E | []]]; discriminate E).
      apply PTree.gempty. }
    (* the body walk *)
    destruct (twl_pres _ _ _ _ _ _ _ _ Hlocal Hbody
                Hub_g Hub_i Hub_x Hub_s Hub_oc Hub_sc Hf32n Hub_gt
                att_walk Htat0 Hact0 Hch0 HNa HMa HVa HSa)
      as (HVb & HSb & HMb & HNb & _ & _ & _).
    (* the exit free_list frees only the FRESH local blocks *)
    pose proof (blocks_of_env_bm lp bm m0 _ eloc _ Halloc HV) as Hforall.
    pose proof (free_list_carried_bm bm NoA MWF HMWF_free HNoA_of_MWF
                  (blocks_of_env (lp_ge lp) eloc) _ mF Hforall Hfree
                  (conj HVb (conj HSb (conj HMb HNb))))
      as (HVf & HSf & HMf & HNf).
    exact (conj HVf (conj HSf HMf)).
  Qed.

  (* ================================================================== *)
  (* THE PAYOFF: ccac + the hang pair + act_ledge_grab + act_ledge_climb_  *)
  (* down PROVED; the remaining 11 deferred to the (smaller) rest residual. *)
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
    (* 2: act_holding_pole -- WALKED (chase arm + gated Osub + pcs/iapf chain) *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm. subst fid.
      rewrite ahp_pin in Hdm. injection Hdm as <-.
      exact act_holding_pole_pres. }
    (* 3: act_grab_pole_slow -- WALKED (B10 rest-split; set_pole_position = Hcp_spp) *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm. subst fid.
      rewrite agps_pin in Hdm. injection Hdm as <-. exact Hagps. }
    (* 4: act_grab_pole_fast -- WALKED (chase-store arm + arithmetic-i32 RHS) *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm. subst fid.
      rewrite agpf_pin in Hdm. injection Hdm as <-.
      exact act_grab_pole_fast_pres. }
    (* 5: act_climbing_pole -- WALKED (B12: np3 non-ptr channel; the
       smawa gated row carries the stick-derived accel) *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm. subst fid.
      rewrite acp_pin in Hdm. injection Hdm as <-.
      exact act_climbing_pole_pres. }
    (* 6: act_top_of_pole_transition -- WALKED (B11; reduces to Hrmayt) *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm. subst fid.
      rewrite atopt_pin in Hdm. injection Hdm as <-.
      exact act_top_of_pole_transition_pres. }
    (* 7: act_top_of_pole -- WALKED (B11; reduces to Hrmayt) *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm. subst fid.
      rewrite atop_pin in Hdm. injection Hdm as <-.
      exact act_top_of_pole_pres. }
    (* 8: act_start_hanging -- WALKED *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm. subst fid.
      rewrite shang_pin in Hdm. injection Hdm as <-. exact act_start_hanging_pres. }
    (* 9: act_hanging -- WALKED *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm. subst fid.
      rewrite hang_pin in Hdm. injection Hdm as <-. exact act_hanging_pres. }
    (* 10: act_hang_moving -- WALKED (B11; reduces to Huhm) *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm. subst fid.
      rewrite ahm_pin in Hdm. injection Hdm as <-.
      exact act_hang_moving_pres. }
    (* 11: act_ledge_grab -- WALKED (local-vars arc: call_pres_of_lwalk) *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm. subst fid.
      rewrite alg_pin in Hdm. injection Hdm as <-. exact act_ledge_grab_pres. }
    (* 12: act_ledge_climb_slow -- WALKED (const-action-store arm) *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm. subst fid.
      rewrite cs_pin in Hdm. injection Hdm as <-.
      exact act_ledge_climb_slow_pres. }
    (* 13: act_ledge_climb_down -- WALKED (act3 path: update_ledge_climb) *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm. subst fid.
      rewrite alcd_pin in Hdm. injection Hdm as <-.
      exact act_ledge_climb_down_pres. }
    (* 14: act_ledge_climb_fast -- WALKED (act3 + chase-store camera/sound) *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm. subst fid.
      rewrite alcf_pin in Hdm. injection Hdm as <-.
      exact act_ledge_climb_fast_pres. }
    (* 15: act_grabbed -- WALKED (wact mechanism) *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm. subst fid.
      rewrite grabbed_pin in Hdm. injection Hdm as <-. exact act_grabbed_pres. }
    (* 16: act_in_cannon -- the LAST rest holdout (engine-v2 cannon kill) *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm. subst fid.
      refine (Hpres_aut_rest _ f _ Hdm); vm_compute; reflexivity. }
    (* 17: act_tornado_twirling -- WALKED (the hybrid twl walker: wwalk
       fallback + the ol/w1 special call sites) *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm. subst fid.
      rewrite att_pin in Hdm. injection Hdm as <-.
      exact act_tornado_twirling_pres. }
    discriminate H.
  Qed.

End AutomaticLeafRows.
