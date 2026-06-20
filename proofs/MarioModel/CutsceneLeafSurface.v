(* ====================================================================== *)
(* THE CUTSCENE-FAMILY LEAF SURFACE                                        *)
(* (SPINE: cutscene_leaf_callees_pres shrinks the capstone's               *)
(*  Hpres_cut_callees down to a per-leaf census rest-split).               *)
(*                                                                         *)
(* CutsceneSurface.cutscene_pres walks the 50-arm dispatcher and reduces   *)
(* it to ONE residual: body_pres for every leaf callee in                  *)
(* cutscene_callee_ids (51 ids -- the prologue helper + 50 act handlers).  *)
(* Here we begin discharging those leaves cluster by cluster, mirroring    *)
(* SubmergedLeafSurface.v / AirborneLeafSurface.v.                         *)
(*                                                                         *)
(* SLICE 1 (this file's first cut): the DEATH cluster prologue helper      *)
(* common_death_handler (set_mario_animation + level_trigger_warp + the    *)
(* m->marioBodyState->eyeState chase store + stop_and_set_height_to_floor) *)
(* and the two cleanest death leaves act_electrocution / act_suffocation   *)
(* (play_sound_if_no_flag + common_death_handler + return 0).  The other   *)
(* 49 leaves stay under the rest premise cut_rest_ids.                     *)
(* ====================================================================== *)

From Coq Require Import ZArith Lia List.
From compcert Require Import Coqlib Maps AST Integers Floats Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking Errors.
From SM64.Generated Require mario mario_step mario_actions_airborne
  mario_actions_cutscene level_update interaction.
From SM64.Proofs Require Import SymbolicLinking Flying Taint
  ActionValueFrame RealFrameValue RealFrameLinked AGates.
From SM64.Proofs Require Import CensusV2 EngineV2Consumer RestSurface
  DispatchKit FloorsSurface ActWriterSurface CutsceneSurface.
(* Require (not Import): reuse the proved psinf_row / sma_row / sub_sashf_row
   rows, referenced qualified -- avoids name shadowing. *)
From SM64.Proofs Require ObjectLeafSurface SubmergedLeafSurface.

Import ListNotations.

Module C := mario_actions_cutscene.
Local Notation Am := mario_actions_airborne._m.
Local Notation tyMSp := (tptr (Tstruct mario_actions_airborne._MarioState noattr)).

(* ====================================================================== *)
(* Censuses.                                                              *)
(* ====================================================================== *)

(* common_death_handler's callees (a plain call_pres helper). *)
Definition cdh_ids : list ident :=
  mario._set_mario_animation :: level_update._level_trigger_warp
    :: mario_step._stop_and_set_height_to_floor :: nil.
(* the m->marioBodyState chase temp it stores eyeState through. *)
Definition cdh_cact : list ident := C._t'2 :: nil.

(* the two cleanest death leaves: play_sound_if_no_flag + common_death_handler. *)
Definition death_ids : list ident :=
  mario._play_sound_if_no_flag :: C._common_death_handler :: nil.

(* play_mario_heavy_landing_sound's sole callee (a plain call_pres helper). *)
Definition pmhls_ids : list ident :=
  mario._play_sound_and_spawn_particles :: nil.

(* the two heavier death leaves (SLICE 2): psinf + common_death_handler +
   (animFrame==K -> play_mario_heavy_landing_sound) + return 0. *)
Definition death_ids3 : list ident :=
  mario._play_sound_if_no_flag :: C._common_death_handler
    :: mario._play_mario_heavy_landing_sound :: nil.

(* SLICE 3: the two "warp helper only" leaves (act_disappeared /
   act_teleport_fade_out) -- both call ONLY rows already proved here:
   play_sound_if_no_flag, set_mario_animation, level_trigger_warp,
   stop_and_set_height_to_floor.  (disappeared omits psinf; the superset
   census still accepts it.) *)
Definition slice3_ids : list ident :=
  mario._play_sound_if_no_flag :: mario._set_mario_animation
    :: level_update._level_trigger_warp
    :: mario_step._stop_and_set_height_to_floor :: nil.
(* the marioObj chase temps act_disappeared stores the graphnode flags through. *)
Definition disap_cact : list ident := C._t'5 :: C._t'6 :: nil.

(* SLICE 4: two more "covered-callee" leaves.
   act_eaten_by_bubba: psinf + sma + ltw (a slice3_ids subset) + the same
     marioObj-graphnode-flags chase store as disappeared (ebb_cact).
   act_waiting_for_dialog: sma + the two out-param externals vec3f_copy /
     vec3s_set (already carried), writing the marioObj gfx pos/angle through
     its chase temps (wfd_cact). *)
Definition wfd_xids : list ident :=
  mario._vec3f_copy :: mario._vec3s_set :: nil.
Definition ebb_cact : list ident := C._t'2 :: C._t'3 :: nil.
Definition wfd_cact : list ident := C._t'4 :: C._t'2 :: nil.

(* ---- LAUNCH ARC (SLICE 5): the launch_mario_until_land helper + its
   exit/death-airborne callers.  launch is a 4-param action writer
   (m, endAction-CONST, animation, forwardVel); call_pres_act_of_wwalk4g
   walks its body -- mario_set_forward_vel / set_mario_animation /
   perform_air_step in ids (plain call_pres helpers), the const-action
   set_mario_action in sids (smact_call_chk), and the airStepLanded
   comparison (always 0/1, hence untainted) seeded into wact via the
   wsrc_chk comparison arm and RETURNED.  Each exit/death leaf carries
   launch in its OWN sids (smact_call_chk gates the const endAction it
   passes) and otherwise stores only marioObj graphnode fields (chase
   temps) and non-action MarioState fields. *)
Definition launch_ids : list ident :=
  mario._mario_set_forward_vel :: mario._set_mario_animation
    :: mario_step._perform_air_step :: nil.
Definition launch_wact : list ident :=
  C._endAction :: C._airStepLanded :: nil.
Definition launch_sids : list ident := mario._set_mario_action :: nil.
(* the leaves' sids: launch itself (a const-action writer). *)
Definition exit_launch_sids : list ident := C._launch_mario_until_land :: nil.
(* the play_sound-calling death leaves' xids; the special leaf's psinf ids. *)
Definition dex_xids : list ident := mario._play_sound :: nil.
Definition sexair_ids : list ident := mario._play_sound_if_no_flag :: nil.
(* per-leaf marioObj graphnode chase temps. *)
Definition exair_cact : list ident := C._t'5 :: C._t'6 :: nil.
Definition fexair_cact : list ident := C._t'3 :: C._t'4 :: nil.
Definition dex_cact : list ident := C._t'5 :: nil.
Definition udfdex_cact : list ident := C._t'3 :: nil.
Definition mo_cact : list ident := C._marioObj :: nil.
(* act_spawn_no_spin_airborne: launch (sids) + set_water_plunge_action (ids);
   reads m->pos[1] / m->waterLevel (non-pointer m fields, np channel). *)
Definition snsa_ids : list ident := mario._set_water_plunge_action :: nil.
(* play_mario_landing_sound's sole callee (twin of pmhls). *)
Definition pmls_ids : list ident :=
  mario._play_sound_and_spawn_particles :: nil.
(* act_emerge_from_pipe: launch (sids) + psinf/msfv/play_mario_landing_sound
   (ids) + marioObj graphnode chase store (mo_cact) + global gCurrLevelNum/
   gCurrAreaIndex scalar reads (np channel). *)
Definition efp_ids : list ident :=
  mario._play_sound_if_no_flag :: mario._mario_set_forward_vel
    :: mario._play_mario_landing_sound :: nil.
(* act_shocked: a body_pres_of_wwalk_wact leaf.  _t'3 is an untainted
   action-const temp (m->health<256 ? 135955 : 205521409, both via Ecast),
   _t'9 the marioObj chase temp; set_camera_shake_from_hit is an obj_ext
   terminal external (1-arg, writes camera state, never bm). *)
Definition sh_wact : list ident := C._t'3 :: nil.
Definition sh_cact : list ident := C._t'9 :: nil.
Definition sh_ids : list ident :=
  mario._play_sound_if_no_flag :: mario._set_mario_animation
    :: mario._mario_set_forward_vel :: mario_step._perform_air_step
    :: mario._play_mario_landing_sound
    :: mario_step._stop_and_set_height_to_floor :: nil.
Definition sh_xids : list ident :=
  mario._play_sound :: interaction._set_camera_shake_from_hit :: nil.
Definition sh_sids : list ident := mario._set_mario_action :: nil.
(* act_teleport_fade_in: a body_pres_of_wwalk leaf (wact=nil, cact=nil).  It
   reads m->actionTimer/flags/pos[1]/waterLevel (np channel) and the area->
   camera chain ONLY to pass the Camera* to set_camera_mode (obj_ext, args
   unchecked -- never stored through, so no cact); both set_mario_action
   targets (939532992, 205521409) are untainted action constants. *)
Definition tfi_ids : list ident :=
  mario._play_sound_if_no_flag :: mario._set_mario_animation
    :: mario_step._stop_and_set_height_to_floor :: nil.
Definition tfi_xids : list ident := mario._set_camera_mode :: nil.
Definition tfi_sids : list ident := mario._set_mario_action :: nil.
(* act_spawn_spin_landing + act_spawn_no_spin_landing: body_pres_of_wwalk
   leaves gated on the is_anim_at_end "anim done?" check (walked in-file,
   loads-only).  load_level_init_text (the dialog-text IO external, sta_ext
   boundary) and play_mario_landing_sound_once (mov_ext audio boundary) ride
   the honest terminal-external boundary; the only set_mario_action target
   (205521409) is an untainted action const. *)
Definition ssl_ids : list ident :=
  mario_step._stop_and_set_height_to_floor :: mario._set_mario_animation
    :: mario._is_anim_at_end :: nil.
Definition ssl_xids : list ident := C._load_level_init_text :: nil.
Definition snsl_ids : list ident :=
  mario._set_mario_animation :: mario_step._stop_and_set_height_to_floor
    :: mario._is_anim_at_end :: nil.
Definition snsl_xids : list ident :=
  C._load_level_init_text :: C._play_mario_landing_sound_once :: nil.

(* the WALKED leaves (SLICE 1 + SLICE 2 + SLICE 3 + SLICE 4 + SLICE 5). *)
Definition cut_walked_ids : list ident :=
  C._act_electrocution :: C._act_suffocation
    :: C._act_death_on_back :: C._act_death_on_stomach
    :: C._act_disappeared :: C._act_teleport_fade_out
    :: C._act_eaten_by_bubba :: C._act_waiting_for_dialog
    :: C._act_exit_airborne :: C._act_falling_exit_airborne
    :: C._act_death_exit :: C._act_unused_death_exit
    :: C._act_falling_death_exit :: C._act_special_exit_airborne
    :: C._act_special_death_exit :: C._act_spawn_no_spin_airborne
    :: C._act_emerge_from_pipe :: C._act_shocked
    :: C._act_teleport_fade_in :: C._act_spawn_spin_landing
    :: C._act_spawn_no_spin_landing :: nil.
Definition cut_rest_ids : list ident :=
  filter (fun id => negb (mem_id id cut_walked_ids)) cutscene_callee_ids.

(* ---- the AST shape pins (vm_compute reflexivity). ---- *)
Example cdh_pin :
  (prog_defmap C.prog) ! C._common_death_handler
  = Some (Gfun (Internal C.f_common_death_handler)).
Proof. vm_compute. reflexivity. Qed.
Example cdh_vars : fn_vars C.f_common_death_handler = nil.
Proof. vm_compute. reflexivity. Qed.
Example cdh_pok :
  match fn_params C.f_common_death_handler with
  | (i, ty) :: ps =>
      Pos.eqb i Am && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id Am (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example cdh_nonparam :
  forallb (fun t' => negb (mem_id t' (map fst (fn_params C.f_common_death_handler))))
    cdh_cact = true.
Proof. vm_compute. reflexivity. Qed.
Example cdh_walk :
  wwalk_chk false nil cdh_ids nil cdh_cact nil nil nil
    (fn_body C.f_common_death_handler) = true.
Proof. vm_compute. reflexivity. Qed.

Example elec_pin :
  (prog_defmap C.prog) ! C._act_electrocution
  = Some (Gfun (Internal C.f_act_electrocution)).
Proof. vm_compute. reflexivity. Qed.
Example elec_vars : fn_vars C.f_act_electrocution = nil.
Proof. vm_compute. reflexivity. Qed.
Example elec_pok :
  match fn_params C.f_act_electrocution with
  | (i, ty) :: ps =>
      Pos.eqb i Am && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id Am (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example elec_walk :
  wwalk_chk false nil death_ids nil nil nil nil nil
    (fn_body C.f_act_electrocution) = true.
Proof. vm_compute. reflexivity. Qed.

Example suff_pin :
  (prog_defmap C.prog) ! C._act_suffocation
  = Some (Gfun (Internal C.f_act_suffocation)).
Proof. vm_compute. reflexivity. Qed.
Example suff_vars : fn_vars C.f_act_suffocation = nil.
Proof. vm_compute. reflexivity. Qed.
Example suff_pok :
  match fn_params C.f_act_suffocation with
  | (i, ty) :: ps =>
      Pos.eqb i Am && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id Am (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example suff_walk :
  wwalk_chk false nil death_ids nil nil nil nil nil
    (fn_body C.f_act_suffocation) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- SLICE 2: play_mario_heavy_landing_sound + the two heavy death leaves. ---- *)
Example pmhls_pin :
  (prog_defmap mario.prog) ! mario._play_mario_heavy_landing_sound
  = Some (Gfun (Internal mario.f_play_mario_heavy_landing_sound)).
Proof. vm_compute. reflexivity. Qed.
Example pmhls_vars : fn_vars mario.f_play_mario_heavy_landing_sound = nil.
Proof. vm_compute. reflexivity. Qed.
Example pmhls_pok :
  match fn_params mario.f_play_mario_heavy_landing_sound with
  | (i, ty) :: ps =>
      Pos.eqb i Am && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id Am (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example pmhls_walk :
  wwalk_chk false nil pmhls_ids nil nil nil nil nil
    (fn_body mario.f_play_mario_heavy_landing_sound) = true.
Proof. vm_compute. reflexivity. Qed.

Example dob_pin :
  (prog_defmap C.prog) ! C._act_death_on_back
  = Some (Gfun (Internal C.f_act_death_on_back)).
Proof. vm_compute. reflexivity. Qed.
Example dob_vars : fn_vars C.f_act_death_on_back = nil.
Proof. vm_compute. reflexivity. Qed.
Example dob_pok :
  match fn_params C.f_act_death_on_back with
  | (i, ty) :: ps =>
      Pos.eqb i Am && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id Am (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example dob_walk :
  wwalk_chk false nil death_ids3 nil nil nil nil nil
    (fn_body C.f_act_death_on_back) = true.
Proof. vm_compute. reflexivity. Qed.

Example dos_pin :
  (prog_defmap C.prog) ! C._act_death_on_stomach
  = Some (Gfun (Internal C.f_act_death_on_stomach)).
Proof. vm_compute. reflexivity. Qed.
Example dos_vars : fn_vars C.f_act_death_on_stomach = nil.
Proof. vm_compute. reflexivity. Qed.
Example dos_pok :
  match fn_params C.f_act_death_on_stomach with
  | (i, ty) :: ps =>
      Pos.eqb i Am && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id Am (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example dos_walk :
  wwalk_chk false nil death_ids3 nil nil nil nil nil
    (fn_body C.f_act_death_on_stomach) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- SLICE 3: act_disappeared + act_teleport_fade_out. ---- *)
Example disap_pin :
  (prog_defmap C.prog) ! C._act_disappeared
  = Some (Gfun (Internal C.f_act_disappeared)).
Proof. vm_compute. reflexivity. Qed.
Example disap_vars : fn_vars C.f_act_disappeared = nil.
Proof. vm_compute. reflexivity. Qed.
Example disap_pok :
  match fn_params C.f_act_disappeared with
  | (i, ty) :: ps =>
      Pos.eqb i Am && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id Am (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example disap_nonparam :
  forallb (fun t' => negb (mem_id t' (map fst (fn_params C.f_act_disappeared))))
    disap_cact = true.
Proof. vm_compute. reflexivity. Qed.
Example disap_walk :
  wwalk_chk false nil slice3_ids nil disap_cact nil nil nil
    (fn_body C.f_act_disappeared) = true.
Proof. vm_compute. reflexivity. Qed.

Example tfo_pin :
  (prog_defmap C.prog) ! C._act_teleport_fade_out
  = Some (Gfun (Internal C.f_act_teleport_fade_out)).
Proof. vm_compute. reflexivity. Qed.
Example tfo_vars : fn_vars C.f_act_teleport_fade_out = nil.
Proof. vm_compute. reflexivity. Qed.
Example tfo_pok :
  match fn_params C.f_act_teleport_fade_out with
  | (i, ty) :: ps =>
      Pos.eqb i Am && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id Am (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example tfo_walk :
  wwalk_chk false nil slice3_ids nil nil nil nil nil
    (fn_body C.f_act_teleport_fade_out) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- SLICE 4: act_eaten_by_bubba + act_waiting_for_dialog. ---- *)
Example ebb_pin :
  (prog_defmap C.prog) ! C._act_eaten_by_bubba
  = Some (Gfun (Internal C.f_act_eaten_by_bubba)).
Proof. vm_compute. reflexivity. Qed.
Example ebb_vars : fn_vars C.f_act_eaten_by_bubba = nil.
Proof. vm_compute. reflexivity. Qed.
Example ebb_pok :
  match fn_params C.f_act_eaten_by_bubba with
  | (i, ty) :: ps =>
      Pos.eqb i Am && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id Am (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example ebb_nonparam :
  forallb (fun t' => negb (mem_id t' (map fst (fn_params C.f_act_eaten_by_bubba))))
    ebb_cact = true.
Proof. vm_compute. reflexivity. Qed.
Example ebb_walk :
  wwalk_chk false nil slice3_ids nil ebb_cact nil nil nil
    (fn_body C.f_act_eaten_by_bubba) = true.
Proof. vm_compute. reflexivity. Qed.

Example wfd_pin :
  (prog_defmap C.prog) ! C._act_waiting_for_dialog
  = Some (Gfun (Internal C.f_act_waiting_for_dialog)).
Proof. vm_compute. reflexivity. Qed.
Example wfd_vars : fn_vars C.f_act_waiting_for_dialog = nil.
Proof. vm_compute. reflexivity. Qed.
Example wfd_pok :
  match fn_params C.f_act_waiting_for_dialog with
  | (i, ty) :: ps =>
      Pos.eqb i Am && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id Am (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example wfd_nonparam :
  forallb (fun t' => negb (mem_id t' (map fst (fn_params C.f_act_waiting_for_dialog))))
    wfd_cact = true.
Proof. vm_compute. reflexivity. Qed.
Example wfd_walk :
  wwalk_chk false nil slice3_ids nil wfd_cact wfd_xids nil nil
    (fn_body C.f_act_waiting_for_dialog) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- SLICE 5: the launch helper + its AST pins. ---- *)
Example launch_pin :
  (prog_defmap C.prog) ! C._launch_mario_until_land
  = Some (Gfun (Internal C.f_launch_mario_until_land)).
Proof. vm_compute. reflexivity. Qed.
Example launch_vars : fn_vars C.f_launch_mario_until_land = nil.
Proof. vm_compute. reflexivity. Qed.
Example launch_params :
  fn_params C.f_launch_mario_until_land
  = (mario_actions_airborne._m, tyMSp) :: (C._endAction, tint)
      :: (C._animation, tint) :: (C._forwardVel, tfloat) :: nil.
Proof. vm_compute. reflexivity. Qed.
Example launch_ret : i32_ty (fn_return C.f_launch_mario_until_land) = true.
Proof. vm_compute. reflexivity. Qed.
Example launch_walk :
  wwalk_chk true launch_wact launch_ids nil nil nil launch_sids nil
    (fn_body C.f_launch_mario_until_land) = true.
Proof. vm_compute. reflexivity. Qed.

Example exair_pin :
  (prog_defmap C.prog) ! C._act_exit_airborne
  = Some (Gfun (Internal C.f_act_exit_airborne)).
Proof. vm_compute. reflexivity. Qed.
Example fexair_pin :
  (prog_defmap C.prog) ! C._act_falling_exit_airborne
  = Some (Gfun (Internal C.f_act_falling_exit_airborne)).
Proof. vm_compute. reflexivity. Qed.
Example dex_pin :
  (prog_defmap C.prog) ! C._act_death_exit
  = Some (Gfun (Internal C.f_act_death_exit)).
Proof. vm_compute. reflexivity. Qed.
Example udex_pin :
  (prog_defmap C.prog) ! C._act_unused_death_exit
  = Some (Gfun (Internal C.f_act_unused_death_exit)).
Proof. vm_compute. reflexivity. Qed.
Example fdex_pin :
  (prog_defmap C.prog) ! C._act_falling_death_exit
  = Some (Gfun (Internal C.f_act_falling_death_exit)).
Proof. vm_compute. reflexivity. Qed.
Example sexair_pin :
  (prog_defmap C.prog) ! C._act_special_exit_airborne
  = Some (Gfun (Internal C.f_act_special_exit_airborne)).
Proof. vm_compute. reflexivity. Qed.
Example sdex_pin :
  (prog_defmap C.prog) ! C._act_special_death_exit
  = Some (Gfun (Internal C.f_act_special_death_exit)).
Proof. vm_compute. reflexivity. Qed.
Example snsa_pin :
  (prog_defmap C.prog) ! C._act_spawn_no_spin_airborne
  = Some (Gfun (Internal C.f_act_spawn_no_spin_airborne)).
Proof. vm_compute. reflexivity. Qed.
Example pmls_pin :
  (prog_defmap mario.prog) ! mario._play_mario_landing_sound
  = Some (Gfun (Internal mario.f_play_mario_landing_sound)).
Proof. vm_compute. reflexivity. Qed.
Example pmls_vars : fn_vars mario.f_play_mario_landing_sound = nil.
Proof. vm_compute. reflexivity. Qed.
Example pmls_pok :
  match fn_params mario.f_play_mario_landing_sound with
  | (i, ty) :: ps =>
      Pos.eqb i Am && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id Am (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example pmls_walk :
  wwalk_chk false nil pmls_ids nil nil nil nil nil
    (fn_body mario.f_play_mario_landing_sound) = true.
Proof. vm_compute. reflexivity. Qed.
Example efp_pin :
  (prog_defmap C.prog) ! C._act_emerge_from_pipe
  = Some (Gfun (Internal C.f_act_emerge_from_pipe)).
Proof. vm_compute. reflexivity. Qed.
Example sh_pin :
  (prog_defmap C.prog) ! C._act_shocked
  = Some (Gfun (Internal C.f_act_shocked)).
Proof. vm_compute. reflexivity. Qed.
Example tfi_pin :
  (prog_defmap C.prog) ! C._act_teleport_fade_in
  = Some (Gfun (Internal C.f_act_teleport_fade_in)).
Proof. vm_compute. reflexivity. Qed.
Example ssl_pin :
  (prog_defmap C.prog) ! C._act_spawn_spin_landing
  = Some (Gfun (Internal C.f_act_spawn_spin_landing)).
Proof. vm_compute. reflexivity. Qed.
Example snsl_pin :
  (prog_defmap C.prog) ! C._act_spawn_no_spin_landing
  = Some (Gfun (Internal C.f_act_spawn_no_spin_landing)).
Proof. vm_compute. reflexivity. Qed.
(* is_anim_at_end: the loads-only "anim done?" helper (walked in-file). *)
Example cut_iae_pin :
  (prog_defmap mario.prog) ! mario._is_anim_at_end
  = Some (Gfun (Internal mario.f_is_anim_at_end)).
Proof. vm_compute. reflexivity. Qed.
Example cut_iae_vars : fn_vars mario.f_is_anim_at_end = nil.
Proof. vm_compute. reflexivity. Qed.
Example cut_iae_pok :
  match fn_params mario.f_is_anim_at_end with
  | (i, ty) :: ps =>
      Pos.eqb i Am && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id Am (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example cut_iae_walk :
  wwalk_chk false nil nil nil nil nil nil nil
    (fn_body mario.f_is_anim_at_end) = true.
Proof. vm_compute. reflexivity. Qed.

(* membership of the un-walked rest. *)
Lemma mem_id_filter_true :
  forall (P : ident -> bool) (l : list ident) (fid : ident),
    mem_id fid l = true -> P fid = true ->
    mem_id fid (filter P l) = true.
Proof.
  intros P l fid. unfold mem_id. induction l as [| a l IH]; intros Hin HP.
  - discriminate Hin.
  - cbn [existsb] in Hin. cbn [filter].
    destruct (Pos.eqb fid a) eqn:Ea.
    + apply Pos.eqb_eq in Ea; subst a. rewrite HP. cbn [existsb].
      rewrite Pos.eqb_refl. reflexivity.
    + cbn [orb] in Hin. specialize (IH Hin HP).
      destruct (P a); [ cbn [existsb]; rewrite Ea; cbn [orb]; exact IH | exact IH ].
Qed.

(* ====================================================================== *)
Section CutsceneLeafRows.
  Variable lp : Clight.program.
  Hypothesis LO_mario : linkorder mario.prog lp.
  Hypothesis LO_stp : linkorder mario_step.prog lp.
  Hypothesis LO_int : linkorder interaction.prog lp.
  Hypothesis LO_lvl : linkorder level_update.prog lp.
  Hypothesis LO_cut : linkorder mario_actions_cutscene.prog lp.

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

  (* the death-cluster helper rows.  Three are PROVED ELSEWHERE and reused
     here (apply + assumption threads the standard MWF block); they bottom out
     in terminal externals carried as section hyps (discharged at the capstone
     via the obj_ext boundary -- NO new trust):
       - play_sound_if_no_flag        (ObjectLeafSurface.psinf_row;  play_sound)
       - set_mario_animation          (ObjectLeafSurface.sma_row;     load_patchable_table)
       - stop_and_set_height_to_floor (SubmergedLeafSurface.sub_sashf_row;
                                       vec3f_copy / vec3s_set)
     level_trigger_warp is the SHARED warp-trigger body (the capstone supplies
     the floors/warp call_pres_of_body term). *)
  Hypothesis Hcpx_psound : call_pres_ext lp bm NoA MWF mario._play_sound.
  Hypothesis Hcpx_lpt : call_pres_ext lp bm NoA MWF mario._load_patchable_table.
  Hypothesis Hcpx_v3fc : call_pres_ext lp bm NoA MWF mario._vec3f_copy.
  Hypothesis Hcpx_v3ss : call_pres_ext lp bm NoA MWF mario._vec3s_set.
  Hypothesis Hcp_ltw :
    call_pres lp bm NoA MWF level_update._level_trigger_warp.
  (* perform_air_step: the air step (writes pos/vel, returns the step
     result; the CALLER dispatches the result).  ALREADY PROVED
     (PerformAirStepSurface.pas_cp); the capstone feeds its existing
     Hcp_pas Lemma -- NO new trust.  Consumed only via launch's ids. *)
  Hypothesis Hcp_pas :
    call_pres lp bm NoA MWF mario_step._perform_air_step.
  (* set_camera_mode: a terminal obj_ext external (in obj_ext_ids); the
     capstone feeds (Hpres_obj_ext mario._set_camera_mode eq_refl) -- NO new
     trust.  Consumed only by set_water_plunge_action's row (swpa). *)
  Hypothesis Hcpx_scm :
    call_pres_ext lp bm NoA MWF mario._set_camera_mode.
  (* set_camera_shake_from_hit: a terminal obj_ext external (in obj_ext_ids;
     the capstone already feeds it elsewhere); writes camera state, never bm.
     Consumed only by act_shocked. *)
  Hypothesis Hcpx_scsfh :
    call_pres_ext lp bm NoA MWF interaction._set_camera_shake_from_hit.
  (* load_level_init_text: the dialog-text IO external (in sta_ext_ids; the
     capstone feeds it via Hpres_sta_ext) -- EF_external in every TU, writes no
     Mario state.  play_mario_landing_sound_once: the once-guarded landing-sound
     external (in mov_ext_ids; fed via Hpres_mov_ext).  Both honest model
     boundaries; consumed only by the two spawn-landing leaves. *)
  Hypothesis Hcpx_llit :
    call_pres_ext lp bm NoA MWF C._load_level_init_text.
  Hypothesis Hcpx_pmlso :
    call_pres_ext lp bm NoA MWF C._play_mario_landing_sound_once.

  Lemma Hcp_psinf : call_pres lp bm NoA MWF mario._play_sound_if_no_flag.
  Proof. eapply ObjectLeafSurface.psinf_row; eassumption. Qed.
  Lemma Hcp_sma : call_pres lp bm NoA MWF mario._set_mario_animation.
  Proof. eapply ObjectLeafSurface.sma_row; eassumption. Qed.
  Lemma Hcp_sashf :
    call_pres lp bm NoA MWF mario_step._stop_and_set_height_to_floor.
  Proof. eapply SubmergedLeafSurface.sub_sashf_row; eassumption. Qed.
  (* is_anim_at_end: loads-only, walked in-file (all-nil censuses). *)
  Lemma cut_iae_row : call_pres lp bm NoA MWF mario._is_anim_at_end.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario.prog mario._is_anim_at_end
             mario.f_is_anim_at_end nil nil nil nil
             LO_mario cut_iae_pin cut_iae_vars cut_iae_pok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact cut_iae_walk.
  Qed.

  (* common_death_handler: set_mario_animation + (animFrame==warpFrame ->
     level_trigger_warp) + m->marioBodyState->eyeState = 8 (chase store) +
     stop_and_set_height_to_floor.  NEVER the action cell -> genuine call_pres. *)
  Lemma cdh_ids_rows : forall fid, mem_id fid cdh_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold cdh_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_sma | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_ltw | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_sashf | ].
    discriminate H.
  Qed.

  Lemma cdh_row :
    call_pres lp bm NoA MWF C._common_death_handler.
  Proof.
    apply (call_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_cutscene.prog C._common_death_handler
             C.f_common_death_handler
             cdh_ids nil cdh_cact nil nil
             LO_cut cdh_pin cdh_vars cdh_pok cdh_nonparam).
    - exact cdh_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact cdh_walk.
  Qed.

  (* the two death leaves. *)
  Lemma death_ids_rows : forall fid, mem_id fid death_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold death_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_psinf | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact cdh_row | ].
    discriminate H.
  Qed.

  Lemma elec_pres : body_pres lp NoA MWF bm C.f_act_electrocution.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             C.f_act_electrocution death_ids nil nil nil nil
             elec_vars elec_pok).
    - exact death_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact elec_walk.
  Qed.

  Lemma suff_pres : body_pres lp NoA MWF bm C.f_act_suffocation.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             C.f_act_suffocation death_ids nil nil nil nil
             suff_vars suff_pok).
    - exact death_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact suff_walk.
  Qed.

  (* ---- SLICE 2: play_mario_heavy_landing_sound + death_on_back/stomach. ---- *)
  (* play_sound_and_spawn_particles is the sole callee of pmhls; its row is
     PROVED in ObjectLeafSurface and reused here (window stores to
     m->particleFlags + the play_sound external).  NO new trust. *)
  Lemma Hcp_psasp :
    call_pres lp bm NoA MWF mario._play_sound_and_spawn_particles.
  Proof. eapply ObjectLeafSurface.psasp_row; eassumption. Qed.

  Lemma pmhls_ids_rows : forall fid, mem_id fid pmhls_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold pmhls_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_psasp | ].
    discriminate H.
  Qed.

  Lemma pmhls_row :
    call_pres lp bm NoA MWF mario._play_mario_heavy_landing_sound.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario.prog mario._play_mario_heavy_landing_sound
             mario.f_play_mario_heavy_landing_sound
             pmhls_ids nil nil nil
             LO_mario pmhls_pin pmhls_vars pmhls_pok).
    - exact pmhls_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact pmhls_walk.
  Qed.

  (* the two heavy death leaves: psinf + common_death_handler + pmhls. *)
  Lemma death_ids3_rows : forall fid, mem_id fid death_ids3 = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold death_ids3 in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_psinf | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact cdh_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact pmhls_row | ].
    discriminate H.
  Qed.

  Lemma dob_pres : body_pres lp NoA MWF bm C.f_act_death_on_back.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             C.f_act_death_on_back death_ids3 nil nil nil nil
             dob_vars dob_pok).
    - exact death_ids3_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact dob_walk.
  Qed.

  Lemma dos_pres : body_pres lp NoA MWF bm C.f_act_death_on_stomach.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             C.f_act_death_on_stomach death_ids3 nil nil nil nil
             dos_vars dos_pok).
    - exact death_ids3_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact dos_walk.
  Qed.

  (* ---- SLICE 3: act_disappeared + act_teleport_fade_out. ---- *)
  (* both call only the four already-proved helper rows; disappeared also
     stores the marioObj graphnode flags through its chase temps (disap_cact). *)
  Lemma slice3_ids_rows : forall fid, mem_id fid slice3_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold slice3_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_psinf | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_sma | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_ltw | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_sashf | ].
    discriminate H.
  Qed.

  Lemma disap_pres : body_pres lp NoA MWF bm C.f_act_disappeared.
  Proof.
    apply (body_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             C.f_act_disappeared slice3_ids nil disap_cact nil nil nil
             disap_vars disap_pok disap_nonparam).
    - exact slice3_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact disap_walk.
  Qed.

  Lemma tfo_pres : body_pres lp NoA MWF bm C.f_act_teleport_fade_out.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             C.f_act_teleport_fade_out slice3_ids nil nil nil nil
             tfo_vars tfo_pok).
    - exact slice3_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact tfo_walk.
  Qed.

  (* ---- SLICE 4: act_eaten_by_bubba + act_waiting_for_dialog. ---- *)
  Lemma wfd_xids_rows : forall fid, mem_id fid wfd_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold wfd_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_v3fc | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_v3ss | ].
    discriminate H.
  Qed.

  Lemma ebb_pres : body_pres lp NoA MWF bm C.f_act_eaten_by_bubba.
  Proof.
    apply (body_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             C.f_act_eaten_by_bubba slice3_ids nil ebb_cact nil nil nil
             ebb_vars ebb_pok ebb_nonparam).
    - exact slice3_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact ebb_walk.
  Qed.

  Lemma wfd_pres : body_pres lp NoA MWF bm C.f_act_waiting_for_dialog.
  Proof.
    apply (body_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             C.f_act_waiting_for_dialog slice3_ids nil wfd_cact wfd_xids nil nil
             wfd_vars wfd_pok wfd_nonparam).
    - exact slice3_ids_rows.
    - intros fid' H. discriminate H.
    - exact wfd_xids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact wfd_walk.
  Qed.

  (* ==================================================================== *)
  (* SLICE 5: the LAUNCH arc.                                             *)
  (* ==================================================================== *)
  (* launch's plain callees + the const-action writer, reused from the
     keystones (no new trust): msfv_row / smact_pres are PROVED rows. *)
  Let Hmsfv : call_pres lp bm NoA MWF mario._mario_set_forward_vel :=
    msfv_row lp LO_mario bm NoA MWF HNoA_of_MWF HMWF_window HMWF_glob
      HMWF_act SafeB HSafeNotBm HchaseRoot HMWF_chase HMWF_root HMWF_sglob
      HchaseStep HMWF_chase_safe.
  Let Hsmact : call_pres_act lp bm NoA MWF mario._set_mario_action :=
    smact_pres lp LO_mario LO_stp bm NoA MWF HNoA_of_MWF
      HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
      HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe.
  (* set_water_plunge_action: a plain window/out-param helper (vec3s_set +
     set_camera_mode), reused from ObjectLeafSurface.swpa_row -- no new trust. *)
  Let Hswpa : call_pres lp bm NoA MWF mario._set_water_plunge_action :=
    ObjectLeafSurface.swpa_row lp LO_mario LO_stp bm NoA MWF HNoA_of_MWF
      HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
      HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
      Hcpx_v3ss Hcpx_scm.

  (* the launch_mario_until_land producer: a 4-param const-action writer
     whose airStepLanded return (a comparison, always 0/1) is untainted. *)
  Lemma Hcpa_launch :
    call_pres_act lp bm NoA MWF C._launch_mario_until_land.
  Proof.
    apply (call_pres_act_of_wwalk4g lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_cutscene.prog C._launch_mario_until_land
             C.f_launch_mario_until_land
             launch_wact launch_ids nil nil nil launch_sids
             C._endAction C._animation C._forwardVel tint tint tfloat
             LO_cut launch_pin launch_vars launch_params launch_ret).
    - intro EE; vm_compute in EE; discriminate EE.
    - intro EE; vm_compute in EE; discriminate EE.
    - intro EE; vm_compute in EE; discriminate EE.
    - vm_compute; reflexivity.
    - vm_compute; reflexivity.
    - vm_compute; reflexivity.
    - vm_compute; reflexivity.
    - vm_compute; reflexivity.
    - vm_compute; reflexivity.
    - vm_compute; reflexivity.
    - vm_compute; reflexivity.
    - intros fid' H. unfold launch_ids in H. cbn [mem_id existsb] in H.
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hmsfv | ].
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hcp_sma | ].
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hcp_pas | discriminate H ].
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. unfold launch_sids in H. cbn [mem_id existsb] in H.
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hsmact | discriminate H ].
    - exact launch_walk.
  Qed.

  (* the sids row reused by every exit/death leaf (launch in its sids). *)
  Lemma exit_launch_sids_rows : forall fid,
      mem_id fid exit_launch_sids = true -> call_pres_act lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold exit_launch_sids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpa_launch | discriminate H ].
  Qed.

  (* per-leaf AST shape pins (vars / param-ok / cact-nonparam / walk). *)
  Example exair_vars : fn_vars C.f_act_exit_airborne = nil.
  Proof. vm_compute. reflexivity. Qed.
  Example exair_pok :
    match fn_params C.f_act_exit_airborne with
    | (i, ty) :: ps =>
        Pos.eqb i Am && proj_sumbool (type_eq ty tyMSp)
        && negb (mem_id Am (map fst ps))
    | nil => false end = true.
  Proof. vm_compute. reflexivity. Qed.
  Example exair_nonparam :
    forallb (fun t' => negb (mem_id t' (map fst (fn_params C.f_act_exit_airborne))))
      exair_cact = true.
  Proof. vm_compute. reflexivity. Qed.
  Example exair_walk :
    wwalk_chk false nil nil nil exair_cact nil exit_launch_sids nil
      (fn_body C.f_act_exit_airborne) = true.
  Proof. vm_compute. reflexivity. Qed.

  Example fexair_vars : fn_vars C.f_act_falling_exit_airborne = nil.
  Proof. vm_compute. reflexivity. Qed.
  Example fexair_pok :
    match fn_params C.f_act_falling_exit_airborne with
    | (i, ty) :: ps =>
        Pos.eqb i Am && proj_sumbool (type_eq ty tyMSp)
        && negb (mem_id Am (map fst ps))
    | nil => false end = true.
  Proof. vm_compute. reflexivity. Qed.
  Example fexair_nonparam :
    forallb (fun t' => negb (mem_id t' (map fst (fn_params C.f_act_falling_exit_airborne))))
      fexair_cact = true.
  Proof. vm_compute. reflexivity. Qed.
  Example fexair_walk :
    wwalk_chk false nil nil nil fexair_cact nil exit_launch_sids nil
      (fn_body C.f_act_falling_exit_airborne) = true.
  Proof. vm_compute. reflexivity. Qed.

  Example dex_vars : fn_vars C.f_act_death_exit = nil.
  Proof. vm_compute. reflexivity. Qed.
  Example dex_pok :
    match fn_params C.f_act_death_exit with
    | (i, ty) :: ps =>
        Pos.eqb i Am && proj_sumbool (type_eq ty tyMSp)
        && negb (mem_id Am (map fst ps))
    | nil => false end = true.
  Proof. vm_compute. reflexivity. Qed.
  Example dex_nonparam :
    forallb (fun t' => negb (mem_id t' (map fst (fn_params C.f_act_death_exit))))
      dex_cact = true.
  Proof. vm_compute. reflexivity. Qed.
  Example dex_walk :
    wwalk_chk false nil nil nil dex_cact dex_xids exit_launch_sids nil
      (fn_body C.f_act_death_exit) = true.
  Proof. vm_compute. reflexivity. Qed.

  Example udex_vars : fn_vars C.f_act_unused_death_exit = nil.
  Proof. vm_compute. reflexivity. Qed.
  Example udex_pok :
    match fn_params C.f_act_unused_death_exit with
    | (i, ty) :: ps =>
        Pos.eqb i Am && proj_sumbool (type_eq ty tyMSp)
        && negb (mem_id Am (map fst ps))
    | nil => false end = true.
  Proof. vm_compute. reflexivity. Qed.
  Example udex_nonparam :
    forallb (fun t' => negb (mem_id t' (map fst (fn_params C.f_act_unused_death_exit))))
      udfdex_cact = true.
  Proof. vm_compute. reflexivity. Qed.
  Example udex_walk :
    wwalk_chk false nil nil nil udfdex_cact dex_xids exit_launch_sids nil
      (fn_body C.f_act_unused_death_exit) = true.
  Proof. vm_compute. reflexivity. Qed.

  Example fdex_vars : fn_vars C.f_act_falling_death_exit = nil.
  Proof. vm_compute. reflexivity. Qed.
  Example fdex_pok :
    match fn_params C.f_act_falling_death_exit with
    | (i, ty) :: ps =>
        Pos.eqb i Am && proj_sumbool (type_eq ty tyMSp)
        && negb (mem_id Am (map fst ps))
    | nil => false end = true.
  Proof. vm_compute. reflexivity. Qed.
  Example fdex_nonparam :
    forallb (fun t' => negb (mem_id t' (map fst (fn_params C.f_act_falling_death_exit))))
      udfdex_cact = true.
  Proof. vm_compute. reflexivity. Qed.
  Example fdex_walk :
    wwalk_chk false nil nil nil udfdex_cact dex_xids exit_launch_sids nil
      (fn_body C.f_act_falling_death_exit) = true.
  Proof. vm_compute. reflexivity. Qed.

  Example sexair_vars : fn_vars C.f_act_special_exit_airborne = nil.
  Proof. vm_compute. reflexivity. Qed.
  Example sexair_pok :
    match fn_params C.f_act_special_exit_airborne with
    | (i, ty) :: ps =>
        Pos.eqb i Am && proj_sumbool (type_eq ty tyMSp)
        && negb (mem_id Am (map fst ps))
    | nil => false end = true.
  Proof. vm_compute. reflexivity. Qed.
  Example sexair_nonparam :
    forallb (fun t' => negb (mem_id t' (map fst (fn_params C.f_act_special_exit_airborne))))
      mo_cact = true.
  Proof. vm_compute. reflexivity. Qed.
  Example sexair_walk :
    wwalk_chk false nil sexair_ids nil mo_cact nil exit_launch_sids nil
      (fn_body C.f_act_special_exit_airborne) = true.
  Proof. vm_compute. reflexivity. Qed.

  Example sdex_vars : fn_vars C.f_act_special_death_exit = nil.
  Proof. vm_compute. reflexivity. Qed.
  Example sdex_pok :
    match fn_params C.f_act_special_death_exit with
    | (i, ty) :: ps =>
        Pos.eqb i Am && proj_sumbool (type_eq ty tyMSp)
        && negb (mem_id Am (map fst ps))
    | nil => false end = true.
  Proof. vm_compute. reflexivity. Qed.
  Example sdex_nonparam :
    forallb (fun t' => negb (mem_id t' (map fst (fn_params C.f_act_special_death_exit))))
      mo_cact = true.
  Proof. vm_compute. reflexivity. Qed.
  Example sdex_walk :
    wwalk_chk false nil nil nil mo_cact nil exit_launch_sids nil
      (fn_body C.f_act_special_death_exit) = true.
  Proof. vm_compute. reflexivity. Qed.

  (* the 7 exit/death leaves: each stores marioObj graphnode fields (chase
     temps) + non-action MarioState fields, and dispatches launch in sids. *)
  Lemma exair_pres : body_pres lp NoA MWF bm C.f_act_exit_airborne.
  Proof.
    apply (body_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             C.f_act_exit_airborne nil nil exair_cact nil exit_launch_sids nil
             exair_vars exair_pok exair_nonparam).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact exit_launch_sids_rows.
    - intros fid' H. discriminate H.
    - exact exair_walk.
  Qed.

  Lemma fexair_pres : body_pres lp NoA MWF bm C.f_act_falling_exit_airborne.
  Proof.
    apply (body_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             C.f_act_falling_exit_airborne nil nil fexair_cact nil
             exit_launch_sids nil
             fexair_vars fexair_pok fexair_nonparam).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact exit_launch_sids_rows.
    - intros fid' H. discriminate H.
    - exact fexair_walk.
  Qed.

  Lemma dex_pres : body_pres lp NoA MWF bm C.f_act_death_exit.
  Proof.
    apply (body_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             C.f_act_death_exit nil nil dex_cact dex_xids exit_launch_sids nil
             dex_vars dex_pok dex_nonparam).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. unfold dex_xids in H. cbn [mem_id existsb] in H.
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hcpx_psound | discriminate H ].
    - exact exit_launch_sids_rows.
    - intros fid' H. discriminate H.
    - exact dex_walk.
  Qed.

  Lemma udex_pres : body_pres lp NoA MWF bm C.f_act_unused_death_exit.
  Proof.
    apply (body_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             C.f_act_unused_death_exit nil nil udfdex_cact dex_xids
             exit_launch_sids nil
             udex_vars udex_pok udex_nonparam).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. unfold dex_xids in H. cbn [mem_id existsb] in H.
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hcpx_psound | discriminate H ].
    - exact exit_launch_sids_rows.
    - intros fid' H. discriminate H.
    - exact udex_walk.
  Qed.

  Lemma fdex_pres : body_pres lp NoA MWF bm C.f_act_falling_death_exit.
  Proof.
    apply (body_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             C.f_act_falling_death_exit nil nil udfdex_cact dex_xids
             exit_launch_sids nil
             fdex_vars fdex_pok fdex_nonparam).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. unfold dex_xids in H. cbn [mem_id existsb] in H.
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hcpx_psound | discriminate H ].
    - exact exit_launch_sids_rows.
    - intros fid' H. discriminate H.
    - exact fdex_walk.
  Qed.

  Lemma sexair_pres : body_pres lp NoA MWF bm C.f_act_special_exit_airborne.
  Proof.
    apply (body_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             C.f_act_special_exit_airborne sexair_ids nil mo_cact nil
             exit_launch_sids nil
             sexair_vars sexair_pok sexair_nonparam).
    - intros fid' H. unfold sexair_ids in H. cbn [mem_id existsb] in H.
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hcp_psinf | discriminate H ].
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact exit_launch_sids_rows.
    - intros fid' H. discriminate H.
    - exact sexair_walk.
  Qed.

  Lemma sdex_pres : body_pres lp NoA MWF bm C.f_act_special_death_exit.
  Proof.
    apply (body_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             C.f_act_special_death_exit nil nil mo_cact nil exit_launch_sids nil
             sdex_vars sdex_pok sdex_nonparam).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact exit_launch_sids_rows.
    - intros fid' H. discriminate H.
    - exact sdex_walk.
  Qed.

  (* act_spawn_no_spin_airborne: launch (sids) + set_water_plunge_action (ids),
     cact=nil (reads m->pos[1]/waterLevel via the np channel). *)
  Lemma snsa_ids_rows : forall fid,
      mem_id fid snsa_ids = true -> call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold snsa_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hswpa | discriminate H ].
  Qed.
  Example snsa_vars : fn_vars C.f_act_spawn_no_spin_airborne = nil.
  Proof. vm_compute. reflexivity. Qed.
  Example snsa_pok :
    match fn_params C.f_act_spawn_no_spin_airborne with
    | (i, ty) :: ps =>
        Pos.eqb i Am && proj_sumbool (type_eq ty tyMSp)
        && negb (mem_id Am (map fst ps))
    | nil => false end = true.
  Proof. vm_compute. reflexivity. Qed.
  Example snsa_walk :
    wwalk_chk false nil snsa_ids nil nil nil exit_launch_sids nil
      (fn_body C.f_act_spawn_no_spin_airborne) = true.
  Proof. vm_compute. reflexivity. Qed.
  Lemma snsa_pres : body_pres lp NoA MWF bm C.f_act_spawn_no_spin_airborne.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             C.f_act_spawn_no_spin_airborne snsa_ids nil nil exit_launch_sids nil
             snsa_vars snsa_pok).
    - exact snsa_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact exit_launch_sids_rows.
    - intros fid' H. discriminate H.
    - exact snsa_walk.
  Qed.

  (* play_mario_landing_sound: the non-heavy twin of pmhls (sole callee
     play_sound_and_spawn_particles); built inline from Hcp_psasp. *)
  Lemma pmls_ids_rows : forall fid, mem_id fid pmls_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold pmls_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_psasp | discriminate H ].
  Qed.
  Lemma pmls_row :
    call_pres lp bm NoA MWF mario._play_mario_landing_sound.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario.prog mario._play_mario_landing_sound
             mario.f_play_mario_landing_sound
             pmls_ids nil nil nil
             LO_mario pmls_pin pmls_vars pmls_pok).
    - exact pmls_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact pmls_walk.
  Qed.

  (* act_emerge_from_pipe: the last launch caller. *)
  Lemma efp_ids_rows : forall fid, mem_id fid efp_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold efp_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_psinf | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hmsfv | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact pmls_row | discriminate H ].
  Qed.
  Example efp_vars : fn_vars C.f_act_emerge_from_pipe = nil.
  Proof. vm_compute. reflexivity. Qed.
  Example efp_pok :
    match fn_params C.f_act_emerge_from_pipe with
    | (i, ty) :: ps =>
        Pos.eqb i Am && proj_sumbool (type_eq ty tyMSp)
        && negb (mem_id Am (map fst ps))
    | nil => false end = true.
  Proof. vm_compute. reflexivity. Qed.
  Example efp_nonparam :
    forallb (fun t' => negb (mem_id t' (map fst (fn_params C.f_act_emerge_from_pipe))))
      mo_cact = true.
  Proof. vm_compute. reflexivity. Qed.
  Example efp_walk :
    wwalk_chk false nil efp_ids nil mo_cact nil exit_launch_sids nil
      (fn_body C.f_act_emerge_from_pipe) = true.
  Proof. vm_compute. reflexivity. Qed.
  Lemma efp_pres : body_pres lp NoA MWF bm C.f_act_emerge_from_pipe.
  Proof.
    apply (body_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             C.f_act_emerge_from_pipe efp_ids nil mo_cact nil exit_launch_sids nil
             efp_vars efp_pok efp_nonparam).
    - exact efp_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact exit_launch_sids_rows.
    - intros fid' H. discriminate H.
    - exact efp_walk.
  Qed.

  (* act_shocked: a body_pres_of_wwalk_wact leaf.  _t'3 is the untainted
     action-const temp written into m->action via set_mario_action;
     set_camera_shake_from_hit is an obj_ext terminal external. *)
  Lemma sh_ids_rows : forall fid, mem_id fid sh_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sh_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_psinf | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_sma | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hmsfv | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_pas | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact pmls_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_sashf | discriminate H ].
  Qed.
  Lemma sh_xids_rows : forall fid, mem_id fid sh_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sh_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_psound | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_scsfh | discriminate H ].
  Qed.
  Example sh_vars : fn_vars C.f_act_shocked = nil.
  Proof. vm_compute. reflexivity. Qed.
  Example sh_pok :
    match fn_params C.f_act_shocked with
    | (i, ty) :: ps =>
        Pos.eqb i Am && proj_sumbool (type_eq ty tyMSp)
        && negb (mem_id Am (map fst ps))
    | nil => false end = true.
  Proof. vm_compute. reflexivity. Qed.
  Example sh_nonparam_cact :
    forallb (fun t' => negb (mem_id t' (map fst (fn_params C.f_act_shocked))))
      sh_cact = true.
  Proof. vm_compute. reflexivity. Qed.
  Example sh_nonparam_wact :
    forallb (fun t' => negb (mem_id t' (map fst (fn_params C.f_act_shocked))))
      sh_wact = true.
  Proof. vm_compute. reflexivity. Qed.
  Example sh_walk :
    wwalk_chk false sh_wact sh_ids nil sh_cact sh_xids sh_sids nil
      (fn_body C.f_act_shocked) = true.
  Proof. vm_compute. reflexivity. Qed.
  Lemma sh_pres : body_pres lp NoA MWF bm C.f_act_shocked.
  Proof.
    apply (body_pres_of_wwalk_wact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             C.f_act_shocked sh_wact sh_ids nil sh_cact sh_xids sh_sids nil
             sh_vars sh_pok sh_nonparam_cact sh_nonparam_wact).
    - exact sh_ids_rows.
    - intros fid' H. discriminate H.
    - exact sh_xids_rows.
    - intros fid' H. unfold sh_sids in H. cbn [mem_id existsb] in H.
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hsmact | discriminate H ].
    - intros fid' H. discriminate H.
    - exact sh_walk.
  Qed.

  (* act_teleport_fade_in: a body_pres_of_wwalk leaf.  set_camera_mode is the
     obj_ext (Hcpx_scm); set_mario_action is the keystone (Hsmact). *)
  Lemma tfi_ids_rows : forall fid, mem_id fid tfi_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold tfi_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_psinf | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_sma | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_sashf | discriminate H ].
  Qed.
  Example tfi_vars : fn_vars C.f_act_teleport_fade_in = nil.
  Proof. vm_compute. reflexivity. Qed.
  Example tfi_pok :
    match fn_params C.f_act_teleport_fade_in with
    | (i, ty) :: ps =>
        Pos.eqb i Am && proj_sumbool (type_eq ty tyMSp)
        && negb (mem_id Am (map fst ps))
    | nil => false end = true.
  Proof. vm_compute. reflexivity. Qed.
  Example tfi_walk :
    wwalk_chk false nil tfi_ids nil nil tfi_xids tfi_sids nil
      (fn_body C.f_act_teleport_fade_in) = true.
  Proof. vm_compute. reflexivity. Qed.
  Lemma tfi_pres : body_pres lp NoA MWF bm C.f_act_teleport_fade_in.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             C.f_act_teleport_fade_in tfi_ids nil tfi_xids tfi_sids nil
             tfi_vars tfi_pok).
    - exact tfi_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. unfold tfi_xids in H. cbn [mem_id existsb] in H.
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hcpx_scm | discriminate H ].
    - intros fid' H. unfold tfi_sids in H. cbn [mem_id existsb] in H.
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hsmact | discriminate H ].
    - intros fid' H. discriminate H.
    - exact tfi_walk.
  Qed.

  (* act_spawn_spin_landing: body_pres_of_wwalk.  ids = sashf/sma/iae;
     xids = load_level_init_text (Hcpx_llit); sids = set_mario_action. *)
  Lemma ssl_ids_rows : forall fid, mem_id fid ssl_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold ssl_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_sashf | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_sma | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact cut_iae_row | discriminate H ].
  Qed.
  Example ssl_vars : fn_vars C.f_act_spawn_spin_landing = nil.
  Proof. vm_compute. reflexivity. Qed.
  Example ssl_pok :
    match fn_params C.f_act_spawn_spin_landing with
    | (i, ty) :: ps =>
        Pos.eqb i Am && proj_sumbool (type_eq ty tyMSp)
        && negb (mem_id Am (map fst ps))
    | nil => false end = true.
  Proof. vm_compute. reflexivity. Qed.
  Example ssl_walk :
    wwalk_chk false nil ssl_ids nil nil ssl_xids tfi_sids nil
      (fn_body C.f_act_spawn_spin_landing) = true.
  Proof. vm_compute. reflexivity. Qed.
  Lemma ssl_pres : body_pres lp NoA MWF bm C.f_act_spawn_spin_landing.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             C.f_act_spawn_spin_landing ssl_ids nil ssl_xids tfi_sids nil
             ssl_vars ssl_pok).
    - exact ssl_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. unfold ssl_xids in H. cbn [mem_id existsb] in H.
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hcpx_llit | discriminate H ].
    - intros fid' H. unfold tfi_sids in H. cbn [mem_id existsb] in H.
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hsmact | discriminate H ].
    - intros fid' H. discriminate H.
    - exact ssl_walk.
  Qed.

  (* act_spawn_no_spin_landing: same shape + play_mario_landing_sound_once
     (Hcpx_pmlso) in xids. *)
  Lemma snsl_ids_rows : forall fid, mem_id fid snsl_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold snsl_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_sma | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_sashf | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact cut_iae_row | discriminate H ].
  Qed.
  Lemma snsl_xids_rows : forall fid, mem_id fid snsl_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold snsl_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_llit | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_pmlso | discriminate H ].
  Qed.
  Example snsl_vars : fn_vars C.f_act_spawn_no_spin_landing = nil.
  Proof. vm_compute. reflexivity. Qed.
  Example snsl_pok :
    match fn_params C.f_act_spawn_no_spin_landing with
    | (i, ty) :: ps =>
        Pos.eqb i Am && proj_sumbool (type_eq ty tyMSp)
        && negb (mem_id Am (map fst ps))
    | nil => false end = true.
  Proof. vm_compute. reflexivity. Qed.
  Example snsl_walk :
    wwalk_chk false nil snsl_ids nil nil snsl_xids tfi_sids nil
      (fn_body C.f_act_spawn_no_spin_landing) = true.
  Proof. vm_compute. reflexivity. Qed.
  Lemma snsl_pres : body_pres lp NoA MWF bm C.f_act_spawn_no_spin_landing.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             C.f_act_spawn_no_spin_landing snsl_ids nil snsl_xids tfi_sids nil
             snsl_vars snsl_pok).
    - exact snsl_ids_rows.
    - intros fid' H. discriminate H.
    - exact snsl_xids_rows.
    - intros fid' H. unfold tfi_sids in H. cbn [mem_id existsb] in H.
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hsmact | discriminate H ].
    - intros fid' H. discriminate H.
    - exact snsl_walk.
  Qed.

  (* ==================================================================== *)
  (* The family rest-split: discharge the SLICE 1-5 leaves, leaving the   *)
  (* other 36 under cut_rest_ids.                                         *)
  (* ==================================================================== *)
  Lemma cutscene_leaf_callees_pres :
    (forall fid f, mem_id fid cut_rest_ids = true ->
       (prog_defmap mario_actions_cutscene.prog) ! fid
         = Some (Gfun (Internal f)) ->
       body_pres lp NoA MWF bm f) ->
    forall fid f, mem_id fid cutscene_callee_ids = true ->
      (prog_defmap mario_actions_cutscene.prog) ! fid
        = Some (Gfun (Internal f)) ->
      body_pres lp NoA MWF bm f.
  Proof.
    intros Hrest fid f H Hdm.
    destruct (Pos.eqb fid C._act_electrocution) eqn:E1.
    { apply Pos.eqb_eq in E1; subst fid.
      rewrite elec_pin in Hdm. injection Hdm as <-. exact elec_pres. }
    destruct (Pos.eqb fid C._act_suffocation) eqn:E2.
    { apply Pos.eqb_eq in E2; subst fid.
      rewrite suff_pin in Hdm. injection Hdm as <-. exact suff_pres. }
    destruct (Pos.eqb fid C._act_death_on_back) eqn:E3.
    { apply Pos.eqb_eq in E3; subst fid.
      rewrite dob_pin in Hdm. injection Hdm as <-. exact dob_pres. }
    destruct (Pos.eqb fid C._act_death_on_stomach) eqn:E4.
    { apply Pos.eqb_eq in E4; subst fid.
      rewrite dos_pin in Hdm. injection Hdm as <-. exact dos_pres. }
    destruct (Pos.eqb fid C._act_disappeared) eqn:E5.
    { apply Pos.eqb_eq in E5; subst fid.
      rewrite disap_pin in Hdm. injection Hdm as <-. exact disap_pres. }
    destruct (Pos.eqb fid C._act_teleport_fade_out) eqn:E6.
    { apply Pos.eqb_eq in E6; subst fid.
      rewrite tfo_pin in Hdm. injection Hdm as <-. exact tfo_pres. }
    destruct (Pos.eqb fid C._act_eaten_by_bubba) eqn:E7.
    { apply Pos.eqb_eq in E7; subst fid.
      rewrite ebb_pin in Hdm. injection Hdm as <-. exact ebb_pres. }
    destruct (Pos.eqb fid C._act_waiting_for_dialog) eqn:E8.
    { apply Pos.eqb_eq in E8; subst fid.
      rewrite wfd_pin in Hdm. injection Hdm as <-. exact wfd_pres. }
    destruct (Pos.eqb fid C._act_exit_airborne) eqn:E9.
    { apply Pos.eqb_eq in E9; subst fid.
      rewrite exair_pin in Hdm. injection Hdm as <-. exact exair_pres. }
    destruct (Pos.eqb fid C._act_falling_exit_airborne) eqn:E10.
    { apply Pos.eqb_eq in E10; subst fid.
      rewrite fexair_pin in Hdm. injection Hdm as <-. exact fexair_pres. }
    destruct (Pos.eqb fid C._act_death_exit) eqn:E11.
    { apply Pos.eqb_eq in E11; subst fid.
      rewrite dex_pin in Hdm. injection Hdm as <-. exact dex_pres. }
    destruct (Pos.eqb fid C._act_unused_death_exit) eqn:E12.
    { apply Pos.eqb_eq in E12; subst fid.
      rewrite udex_pin in Hdm. injection Hdm as <-. exact udex_pres. }
    destruct (Pos.eqb fid C._act_falling_death_exit) eqn:E13.
    { apply Pos.eqb_eq in E13; subst fid.
      rewrite fdex_pin in Hdm. injection Hdm as <-. exact fdex_pres. }
    destruct (Pos.eqb fid C._act_special_exit_airborne) eqn:E14.
    { apply Pos.eqb_eq in E14; subst fid.
      rewrite sexair_pin in Hdm. injection Hdm as <-. exact sexair_pres. }
    destruct (Pos.eqb fid C._act_special_death_exit) eqn:E15.
    { apply Pos.eqb_eq in E15; subst fid.
      rewrite sdex_pin in Hdm. injection Hdm as <-. exact sdex_pres. }
    destruct (Pos.eqb fid C._act_spawn_no_spin_airborne) eqn:E16.
    { apply Pos.eqb_eq in E16; subst fid.
      rewrite snsa_pin in Hdm. injection Hdm as <-. exact snsa_pres. }
    destruct (Pos.eqb fid C._act_emerge_from_pipe) eqn:E17.
    { apply Pos.eqb_eq in E17; subst fid.
      rewrite efp_pin in Hdm. injection Hdm as <-. exact efp_pres. }
    destruct (Pos.eqb fid C._act_shocked) eqn:E18.
    { apply Pos.eqb_eq in E18; subst fid.
      rewrite sh_pin in Hdm. injection Hdm as <-. exact sh_pres. }
    destruct (Pos.eqb fid C._act_teleport_fade_in) eqn:E19.
    { apply Pos.eqb_eq in E19; subst fid.
      rewrite tfi_pin in Hdm. injection Hdm as <-. exact tfi_pres. }
    destruct (Pos.eqb fid C._act_spawn_spin_landing) eqn:E20.
    { apply Pos.eqb_eq in E20; subst fid.
      rewrite ssl_pin in Hdm. injection Hdm as <-. exact ssl_pres. }
    destruct (Pos.eqb fid C._act_spawn_no_spin_landing) eqn:E21.
    { apply Pos.eqb_eq in E21; subst fid.
      rewrite snsl_pin in Hdm. injection Hdm as <-. exact snsl_pres. }
    (* REST: fid is in the census and not a walked id. *)
    apply (Hrest fid f); [ | exact Hdm ].
    unfold cut_rest_ids.
    apply mem_id_filter_true; [ exact H | ].
    unfold cut_walked_ids. cbn [mem_id existsb].
    rewrite E1, E2, E3, E4, E5, E6, E7, E8, E9, E10, E11, E12, E13, E14, E15, E16,
      E17, E18, E19, E20, E21.
    reflexivity.
  Qed.

End CutsceneLeafRows.
