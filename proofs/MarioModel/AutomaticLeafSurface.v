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

Import ListNotations.

(* the leaves NOT yet walked: every slice moves ids out of here *)
Definition automatic_rest_ids : list ident :=
  mario_actions_automatic._act_climbing_pole ::
  mario_actions_automatic._act_top_of_pole_transition ::
  mario_actions_automatic._act_top_of_pole ::
  mario_actions_automatic._act_hang_moving ::
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
  wwalk_chk' lgl_lids lgl_oc_pids nil nil false nil nil nil nil nil lgl_sids nil
    (fn_body mario_actions_automatic.f_let_go_of_ledge) = true.
Proof. vm_compute. reflexivity. Qed.
Example ffhrp_walk :
  wwalk_chk' ffhrp_lids ffhrp_oc_pids nil nil false nil nil nil nil nil nil nil
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
  wwalk_chk' spp_lids spp_oc_pids spp_wc_pids spp_sc_pids false
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
    (* 5..7: pole leaves -- rest *)
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
    (* 10: act_hang_moving -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm. subst fid.
      refine (Hpres_aut_rest _ f _ Hdm); vm_compute; reflexivity. }
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
    (* 16..17: cannon + tornado -- rest *)
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm. subst fid.
      refine (Hpres_aut_rest _ f _ Hdm); vm_compute; reflexivity. }
    apply orb_true_iff in H as [Hm | H].
    { apply Pos.eqb_eq in Hm. subst fid.
      refine (Hpres_aut_rest _ f _ Hdm); vm_compute; reflexivity. }
    discriminate H.
  Qed.

End AutomaticLeafRows.
