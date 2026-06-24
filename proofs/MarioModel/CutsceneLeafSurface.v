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
From SM64.Proofs Require ObjectLeafSurface SubmergedLeafSurface
  OutParamSurface LocalVarsSurface AutomaticLeafSurface MovingLeafSurface
  WindSurface SpawnObjSurface.

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
(* act_standing_death (body_pres_of_wwalk, cact=nil -- the marioObj deep
   animFrame read is NOT stored through): psinf + common_death_handler +
   play_mario_landing_sound, sids=set_mario_action (const 135956, result
   returned w/ rt=false). *)
Definition sd_ids : list ident :=
  mario._play_sound_if_no_flag :: C._common_death_handler
    :: mario._play_mario_landing_sound :: nil.
(* act_fall_after_star_grab: a body_pres_of_wwalk_wact leaf.  _t'2 is the
   cond?4871:4866 untainted-action temp feeding the 2nd set_mario_action;
   ids = perform_air_step + play_mario_landing_sound + set_mario_animation;
   xids = play_sound (marioObj cameraToObject float* arg, ignored); the marioObj
   read is NOT stored through (cact=nil); m-field stores only (particleFlags). *)
Definition fasg_wact : list ident := C._t'2 :: nil.
Definition fasg_ids : list ident :=
  mario_step._perform_air_step :: mario._play_mario_landing_sound
    :: mario._set_mario_animation :: nil.
Definition fasg_xids : list ident := mario._play_sound :: nil.

(* act_spawn_spin_airborne: the airborne twin of spawn_spin_landing.  Plain
   body_pres_of_wwalk (wact=nil, cact=nil): the marioObj read feeds play_sound
   only; m-field stores (actionState) + indexed window stores (vel[1]).
   ids = set_water_plunge_action / mario_set_forward_vel / perform_air_step /
   play_mario_landing_sound / set_mario_animation; xids = load_level_init_text
   (Hcpx_llit) + play_sound (Hcpx_psound); sids = set_mario_action (const 4901). *)
Definition ssa_ids : list ident :=
  mario._set_water_plunge_action :: mario._mario_set_forward_vel
    :: mario_step._perform_air_step :: mario._play_mario_landing_sound
    :: mario._set_mario_animation :: nil.
Definition ssa_xids : list ident :=
  C._load_level_init_text :: mario._play_sound :: nil.

(* act_warp_door_spawn: body_pres_of_wwalk_cact.  cact = [_t'9;_t'8] = the
   usedObj chase temps stored THROUGH (m->usedObj->rawData.asS32[43] = const);
   ids = set_mario_animation / stop_and_set_height_to_floor; sids =
   set_mario_action (consts 536875781, 205521409); xids = nil. *)
Definition wds_cact : list ident := C._t'9 :: C._t'8 :: nil.
Definition wds_ids : list ident :=
  mario._set_mario_animation :: mario_step._stop_and_set_height_to_floor :: nil.

(* SLICE 17: act_going_through_door.  body_pres_of_wwalk_cact.  Structural twin
   of act_warp_door_spawn (wds): the interactObj/usedObj chase temps stored
   THROUGH (obj->rawData.asS32[43] = 1<<n const), plus the usedObj-window reads
   feeding m->faceAngle[1] / m->pos[0] / m->pos[2] / m->actionTimer window
   stores.  cact = [_t'16;_t'15;_t'11;_t'9;_t'7] (the five interactObj/usedObj
   chase roots); ids = update_mario_pos_for_anim (Hcp_umpfa, the new WALKED
   helper) / stop_and_set_height_to_floor / is_anim_at_end / set_mario_animation
   / level_trigger_warp; sids = set_mario_action (const 205521409); xids = nil. *)
Definition gtd_cact : list ident :=
  C._t'16 :: C._t'15 :: C._t'11 :: C._t'9 :: C._t'7 :: nil.
Definition gtd_ids : list ident :=
  mario._update_mario_pos_for_anim
    :: mario_step._stop_and_set_height_to_floor
    :: mario._is_anim_at_end :: mario._set_mario_animation
    :: level_update._level_trigger_warp :: nil.

(* SLICE 19: act_entering_star_door (esd).  The FIRST cutscene leaf that
   needs the np3 channel: it calls set_mario_anim_with_accel(m, ANIM, 0x28000)
   -- a chase-writer whose 3rd arg (an animation accel) is stored RAW into the
   marioObj block, so plain call_pres is phantom-FALSE (an adversary 3rd-arg
   pointer would forge a SafeB pointer).  The honest row is call_pres_np3
   (3rd-arg non-pointer gated, REUSING MovingLeafSurface.mov_smawa_row); the
   constant 0x28000 satisfies the gate (nsrc_chk Econst_int).  body_pres_of_
   wwalk_NIDS (np3_ids = [smawa]).  fn_vars=nil (targetDX/DZ/targetAngle are
   SSA temps).  cact = the 9 marioObj/usedObj chase temps stored THROUGH
   (m->marioObj->oMarioReadingSignDPosX/Z = const) and read for the m->pos
   window updates; ids = set_mario_animation / stop_and_set_height_to_floor;
   xids = atan2s; sids = set_mario_action (const ACT_IDLE). *)
Definition esd_cact : list ident :=
  C._t'14 :: C._t'17 :: C._t'20 :: C._t'22 :: C._t'23 :: C._t'24
    :: C._t'28 :: C._t'33 :: C._t'35 :: nil.
Definition esd_ids : list ident :=
  mario._set_mario_animation :: mario_step._stop_and_set_height_to_floor :: nil.
Definition esd_np3 : list ident := mario._set_mario_anim_with_accel :: nil.
Definition esd_xids : list ident := interaction._atan2s :: nil.

(* SLICE 20: act_reading_npc_dialog (rnd).  fn_vars=nil (headTurnAmount/
   angleToNPC are SSA temps).  cact=nil -- the marioObj/marioBodyState writes
   all happen INSIDE vec3f_copy/vec3s_set (xids out-params), so the body has
   no direct chase store.  The `set_mario_action(m, _t'4, 0)` call where _t'4 =
   (heldObj==NULL ? ACT_IDLE : ACT_HOLD_IDLE) needs the WACT channel: _t'4 is a
   LOCAL temp set from UNTAINTED action constants, recognized by wsrc_chk
   (Ecast of an untainted const), so the smact_call_chk action-arg gate passes
   (body_pres_of_wwalk_wact seeds _t'4 = Vundef at entry).  ids = moato
   (cut_moato_row, in-section twin of ObjectLeafSurface.moato_row) + sma; xids =
   approach_s32 (Hcpx_approach, obj_ext) + vec3f_copy + vec3s_set; sids =
   set_mario_action (the 4925 = ACT_PUTTING_ON_CAP branch is a const arg). *)
Definition rnd_wact : list ident := C._t'4 :: nil.
Definition rnd_ids : list ident :=
  interaction._mario_obj_angle_to_object :: mario._set_mario_animation :: nil.
Definition rnd_xids : list ident :=
  mario_actions_object._approach_s32 :: mario._vec3f_copy :: mario._vec3s_set :: nil.

(* SLICE 21: act_unlocking_star_door (usd).  body_pres_of_wwalk_cact.  fn_vars=
   nil.  cact = the marioObj/usedObj chase temps stored THROUGH (m->marioObj->
   oMarioReadingSignDPosX/Z = m->pos[i]) and read back for the m->pos window
   updates.  ids = set_mario_animation / update_mario_pos_for_anim /
   stop_and_set_height_to_floor / is_anim_at_end; xids = spawn_object (the star
   into the SafeB object pool) / save_file_set_flags (save-buffer writer) /
   get_door_save_file_flag (a STORELESS internal -> cut_gdsff_row, the in-section
   twin of InterSurface.gdsff_row); sids = set_mario_action (const ACT_READING_
   AUTOMATIC_DIALOG).  ALL xids rows reuse standing capstone boundaries. *)
Definition usd_cact : list ident :=
  C._t'5 :: C._t'7 :: C._t'10 :: C._t'13 :: C._t'15 :: C._t'17 :: C._t'21 :: nil.
Definition usd_ids : list ident :=
  mario._set_mario_animation :: mario._update_mario_pos_for_anim
    :: mario_step._stop_and_set_height_to_floor :: mario._is_anim_at_end :: nil.
Definition usd_xids : list ident :=
  interaction._spawn_object :: interaction._save_file_set_flags
    :: interaction._get_door_save_file_flag :: nil.

(* SLICE 22: check_for_instant_quicksand (cfiq).  body_pres_of_wwalk -- a
   READ-ONLY body (every Sset is a load: m->floor, m->floor->type, m->action;
   NO stores at all, so cact = nil).  The two memory effects are calls:
   update_mario_sound_and_camera (ids -- rides the SAME floors-family call_pres
   the capstone already builds) and drop_and_set_mario_action(m, 135954, 0)
   (sids -- 135954 = ACT_QUICKSAND_DEATH, an UNTAINTED I32 constant; routed
   through the keystone dasma_row).  NO new capstone trust: dasma's three
   externals (segmented_to_virtual / stop_shell_music / obj_set_held_state) all
   ride obj_ext_ids, and umsc reuses the floors-family term. *)
Definition cfiq_ids : list ident :=
  mario._update_mario_sound_and_camera :: nil.
Definition cfiq_sids : list ident :=
  mario._drop_and_set_mario_action :: nil.

(* SLICE 23: act_unlocking_key_door (ukd).  body_pres_of_wwalk -- a body whose
   Object* temps (the door/key objects) are LOADED only (chase reads), so every
   store is a direct window write into m->faceAngle/pos/actionTimer (cact=nil).
   ids = spawn_obj_at_mario_rel_yaw (the in-TU spawn helper, walked in
   SpawnObjSurface) + set_mario_animation + update_mario_pos_for_anim +
   stop_and_set_height_to_floor + is_anim_at_end.  xids = play_sound +
   save_file_set_flags + save_file_clear_flags (all in obj_ext_ids; Hpres_obj_ext).
   sids = set_mario_action(m, 67109952, 0) (67109952 = ACT_UNLOCKING_KEY_DOOR's
   successor const, UNTAINTED I32).  NO new capstone trust: the spawn helper's
   own residual (spawn_object via call_pres_ext_sr) is the standing Hcp_spawn_real,
   and save_file_clear_flags rides obj_ext_ids. *)
Definition ukd_ids : list ident :=
  C._spawn_obj_at_mario_rel_yaw :: mario._set_mario_animation
    :: mario._update_mario_pos_for_anim
    :: mario_step._stop_and_set_height_to_floor :: mario._is_anim_at_end :: nil.
Definition ukd_xids : list ident :=
  mario._play_sound :: interaction._save_file_set_flags
    :: interaction._save_file_clear_flags :: nil.

(* act_credits_cutscene: chase stores (statusForCamera->cameraEvent,
   marioObj->gfx.angle[1]), safe m-field stores (particleFlags/actionState/
   actionTimer), the DEEP global viewport stores (sEndCutsceneVp.vp.vscale[i]/
   .vtrans[i] via the new glob_store_chk deep arm), a simple global store
   (sDispCreditsEntry), marg internal calls and pure externals. *)
Definition cred_ids : list ident :=
  mario._set_mario_animation
    :: mario_step._stop_and_set_height_to_floor
    :: level_update._level_trigger_warp :: nil.
Definition cred_xids : list ident :=
  mario._set_camera_mode :: mario_step._vec3f_copy :: mario._vec3s_copy
    :: C._override_viewport_and_clip :: C._reset_cutscene_msg_fade :: nil.
(* the two chase-store temps: _t'32 <- m->statusForCamera (cameraEvent store),
   _t'4 <- m->marioObj (the deep gfx.angle[1] indexed chase store). *)
Definition cred_cact : list ident := C._t'32 :: C._t'4 :: nil.

(* get_door_save_file_flag support (the in-section twin of InterSurface's
   gdsff_row -- a STORELESS internal reading the door object through its only
   param, calling the save_file_get_flags boundary).  CutsceneLeafSurface does
   not Require InterSurface, so these globals are re-derived locally. *)
Definition cut_gdsff_xids : list ident :=
  interaction._save_file_get_flags :: nil.
Lemma cut_gdsff_pin :
  (prog_defmap interaction.prog) ! interaction._get_door_save_file_flag
  = Some (Gfun (Internal interaction.f_get_door_save_file_flag)).
Proof. vm_compute. reflexivity. Qed.
Lemma cut_gdsff_vars : fn_vars interaction.f_get_door_save_file_flag = nil.
Proof. vm_compute. reflexivity. Qed.
Lemma cut_gdsff_no_m :
  negb (mem_id mario_actions_airborne._m
          (map fst (fn_params interaction.f_get_door_save_file_flag)))
  = true.
Proof. vm_compute. reflexivity. Qed.
Lemma cut_gdsff_walk :
  wwalk_chk false nil nil nil nil cut_gdsff_xids nil nil
    (fn_body interaction.f_get_door_save_file_flag) = true.
Proof. vm_compute. reflexivity. Qed.

(* SLICE 12: the dialog-cluster external boundary.  cut_ext_ids = the
   cutscene DIALOG / TIME-STOP externals: EF_external in EVERY linked TU
   (verified -- no Internal body anywhere under generated/), the honest
   model-boundary class (same as obj_ext/sta_ext/mov_ext).  They drive the
   dialog-box renderer and the global time-stop flag; none of them takes a
   MarioState pointer or writes gMarioState->action, so call_pres_ext holds.
   Supplied at the capstone by the new Hpres_cut_ext boundary; grows as
   further dialog/save/spawn leaves discharge. *)
Definition cut_ext_ids : list ident :=
  C._create_dialog_inverted_box :: C._trigger_cutscene_dialog
    :: C._enable_time_stop :: C._disable_time_stop
    (* SLICE 12c automatic-dialog externals: the dialog-box constructors,
       the dialog-id reader, and the cutscene-music cue -- all EF_external
       in every linked TU, same boundary class as the four above. *)
    :: C._create_dialog_box :: C._create_dialog_box_with_var
    :: C._get_dialog_id :: C._play_cutscene_music
    (* SLICE 13 star-dance externals: the star-collection feedback set --
       object spawn, the response dialog box, the bg-sound mute/unmute, the
       course-clear / music cues, and the save commit.  EF_external in EVERY
       linked TU (verified -- no Internal body anywhere under generated/),
       same honest model-boundary class. *)
    :: C._spawn_object :: C._create_dialog_box_with_response
    :: C._disable_background_sound :: C._enable_background_sound
    :: C._play_course_clear :: C._play_music :: C._save_file_do_save
    (* SLICE 26 act_exit_land_save_dialog externals: the save-menu commit
       (set_menu_mode), peach's-jingle audio cue, and the two
       level-transition audio externals reached through the NON-Mario
       fade_into_special_warp body (fadeout_music / play_transition).  All
       EF_external in EVERY linked TU (verified -- no Internal body anywhere
       under generated/), same honest model-boundary class. *)
    :: C._set_menu_mode :: C._play_peachs_jingle
    :: level_update._fadeout_music :: level_update._play_transition
    (* act_intro_cutscene subhandler externals (peach_lakitu / raise_pipe /
       jump_out_of_pipe / lower_pipe): the object-spawn / camera-approach /
       sound-bank / object-deletion externals.  EF_external in EVERY linked TU
       (verified -- no Internal body anywhere under generated/); each writes
       camera/sound/object-pool state, never Mario's bm action cell.  Same
       honest model-boundary class as the dialog/time-stop externals above. *)
    :: C._spawn_object_abs_with_rot :: C._camera_approach_f32_symmetric
    :: C._sound_banks_enable :: C._obj_mark_for_deletion :: nil.

(* act_reading_sign: body_pres_of_wwalk (wact=nil, cact=nil -- marioObj/usedObj
   chase temps are only LOADED; the only stores are direct non-action m-fields:
   actionState / faceAngle[1] / pos[0,2] / actionTimer).  ids = psinf + sma;
   xids = the 4 dialog/time-stop externals (Hcut_ext) + vec3f_copy / vec3s_set
   (obj_ext); sids = set_mario_action (const 205521409). *)
Definition rs_ids : list ident :=
  mario._play_sound_if_no_flag :: mario._set_mario_animation :: nil.
Definition rs_xids : list ident :=
  C._trigger_cutscene_dialog :: C._enable_time_stop
    :: C._create_dialog_inverted_box :: C._disable_time_stop
    :: mario._vec3f_copy :: mario._vec3s_set :: nil.

(* act_bbh_enter_spin: body_pres_of_wwalk_cact.  cact = [_t'18;_t'10] = the
   marioObj chase temps stored THROUGH (rawData angle[0] / node flags);
   ids = mario_set_forward_vel / set_mario_animation / perform_air_step /
   level_trigger_warp / play_sound_if_no_flag / stop_and_set_height_to_floor;
   xids = sqrtf / atan2s / play_sound (obj_ext) + vec3f_set (now obj_ext);
   sids = nil (NO set_mario_action). *)
Definition bbhs_cact : list ident := C._t'18 :: C._t'10 :: nil.
Definition bbhs_ids : list ident :=
  mario._mario_set_forward_vel :: mario._set_mario_animation
    :: mario_step._perform_air_step :: level_update._level_trigger_warp
    :: mario._play_sound_if_no_flag
    :: mario_step._stop_and_set_height_to_floor :: nil.
Definition bbhs_xids : list ident :=
  mario._sqrtf :: interaction._atan2s :: mario._play_sound
    :: mario._vec3f_set :: nil.

(* act_reading_automatic_dialog: body_pres_of_wwalk_wact.  wact = [_t'3] = the
   untainted action-const temp (Ecast 67109952 / 205521409 -> 2nd set_mario_action;
   1st set_mario_action uses const 939532992 directly).  cact = nil (marioBodyState
   t'4 is LOADED only, passed to vec3s_set).  ids = set_mario_animation; xids = the
   6 dialog/time-stop externals (Hcut_ext) + vec3s_set (obj_ext); sids =
   set_mario_action.  The only global store is gNeverEnteredCastle = 0
   (glob_store_chk via stored_globals); m-field stores are actionState/actionTimer
   arithmetic (non-action). *)
Definition rad_wact : list ident := C._t'3 :: nil.
Definition rad_ids : list ident := mario._set_mario_animation :: nil.
Definition rad_xids : list ident :=
  C._enable_time_stop :: C._create_dialog_box :: C._create_dialog_box_with_var
    :: C._get_dialog_id :: C._disable_time_stop :: C._play_cutscene_music
    :: mario._vec3s_set :: nil.

(* act_bbh_enter_jump: body_pres_of_wwalk (wact=nil, cact=nil -- usedObj LOADED
   only for the cage-distance read; all stores are direct m-fields vel[1]/flags/
   actionState/actionTimer).  ids = mario_set_forward_vel / set_mario_animation /
   perform_air_step / play_mario_action_sound / play_mario_jump_sound; xids =
   sqrtf / atan2s (obj_ext); sids = set_mario_action (const 5429). *)
Definition bbhj_ids : list ident :=
  mario._mario_set_forward_vel :: mario._set_mario_animation
    :: mario_step._perform_air_step :: mario._play_mario_action_sound
    :: mario._play_mario_jump_sound :: nil.
Definition bbhj_xids : list ident :=
  mario._sqrtf :: interaction._atan2s :: nil.

(* SLICE 13: the star-dance cluster.  Two leaf act handlers (act_star_dance,
   act_star_dance_water) share two internal helpers that must be WALKED (both
   have Internal bodies in mario_actions_cutscene -> NOT honest externals):

     get_star_collection_dialog   -- pure near-leaf: reads the global
       sStarsNeededForDialog, stores m->prevNumStarsForDialog (non-action).
       all-nil censuses (call_pres_of_wwalk).
     general_star_dance_handler   -- the body that fires the star feedback.
       wact = [_t'5] (untainted action-const temp); ids = is_anim_at_end /
       level_trigger_warp / get_star_collection_dialog; xids = the 10
       star-feedback externals (play_sound -> Hcpx_psound, the other 9 ->
       Hcut_ext); sids = set_mario_action.  3 stores all direct m-fields
       (actionTimer / actionState x2 -- non-action). *)
Definition gscd_ids  : list ident := nil.
Definition gsdh_wact : list ident := C._t'5 :: nil.
Definition gsdh_ids  : list ident :=
  mario._is_anim_at_end :: level_update._level_trigger_warp
    :: C._get_star_collection_dialog :: nil.
Definition gsdh_xids : list ident :=
  C._spawn_object :: mario._play_sound :: C._create_dialog_box_with_response
    :: C._disable_background_sound :: C._enable_background_sound
    :: C._play_course_clear :: C._play_music :: C._save_file_do_save
    :: C._enable_time_stop :: C._disable_time_stop :: nil.

(* act_star_dance: body_pres_of_wwalk_cact.  cact = [_t'3] = the marioObj
   chase temp stored THROUGH (marioBodyState->handState = 2); other stores
   are m->faceAngle[1] (direct, non-action).  ids = general_star_dance_handler
   / set_mario_animation / stop_and_set_height_to_floor. *)
Definition sdn_cact : list ident := C._t'3 :: nil.
Definition sdn_ids  : list ident :=
  C._general_star_dance_handler :: mario._set_mario_animation
    :: mario_step._stop_and_set_height_to_floor :: nil.

(* act_star_dance_water: body_pres_of_wwalk_cact.  cact = [_t'3] (same
   marioBodyState->handState = 2 chase store); marioObj LOADED for the
   vec3f_copy / vec3s_set args.  ids = general_star_dance_handler /
   set_mario_animation; xids = vec3f_copy / vec3s_set (obj_ext). *)
Definition sdw_cact : list ident := C._t'3 :: nil.
Definition sdw_ids  : list ident :=
  C._general_star_dance_handler :: mario._set_mario_animation :: nil.
Definition sdw_xids : list ident :=
  mario._vec3f_copy :: mario._vec3s_set :: nil.

(* SLICE 14: act_squished.  A body_pres_of_lwalk leaf -- its only oddity is a
   DEAD stack-local `filler[4]` (never stored through, so lids=nil and the
   unprimed walk suffices, but fn_vars is non-nil).  No chase stores (the two
   marioObj loads feed vec3f_set's window out-param, an obj_ext), no action
   temps (all 5 set_mario_action 2nd-args are untainted consts -> sids).
   ids = perform_ground_step / set_mario_animation / play_sound_if_no_flag /
   stop_and_set_height_to_floor / level_trigger_warp; xids = atan2s / vec3f_set
   (obj_ext); sids = set_mario_action. *)
Definition sq_ids : list ident :=
  mario_step._perform_ground_step :: mario._set_mario_animation
    :: mario._play_sound_if_no_flag :: mario_step._stop_and_set_height_to_floor
    :: level_update._level_trigger_warp :: nil.
Definition sq_xids : list ident :=
  interaction._atan2s :: mario._vec3f_set :: nil.

(* SLICE 15: act_quicksand_death.  body_pres_of_wwalk (fn_vars=nil).  The one
   formerly-blocking callee stationary_ground_step (sgs) is now WALKABLE in-file
   -- its sub-tree (mario_set_forward_vel / mario_update_moving_sand /
   mario_update_windy_ground / perform_ground_step + vec3f_copy/vec3s_set) all
   resolve to existing section terms now that Hcp_pgs is present.  mums/muwg/
   set_anim_to_frame are pure all-nil near-leaves (walked in-file). *)
Definition sgs_ids : list ident :=
  mario._mario_set_forward_vel :: mario_step._mario_update_moving_sand
    :: mario_step._mario_update_windy_ground
    :: mario_step._perform_ground_step :: nil.
Definition sgs_xids : list ident :=
  mario._vec3f_copy :: mario._vec3s_set :: nil.
Definition qsd_ids : list ident :=
  level_update._level_trigger_warp :: mario._play_sound_if_no_flag
    :: mario._set_anim_to_frame :: mario._set_mario_animation
    :: mario_step._stationary_ground_step :: nil.
Definition qsd_xids : list ident := mario._play_sound :: nil.

(* SLICE 16: act_putting_on_cap.  body_pres_of_wwalk (fn_vars=nil, cact=nil:
   marioObj/usedObj loaded only, never stored through).  The only callee not
   yet in-section is the tiny helper cutscene_put_cap_on (2 m->flags window
   stores of untainted uint masks + play_sound, marioObj read-only) -- walked
   in-file (cpco_row).  enable/disable_time_stop ride the cut_ext boundary
   (Hcut_ext); stationary_ground_step is now in-section (cut_sgs_row). *)
Definition cpco_xids : list ident := mario._play_sound :: nil.
Definition poc_ids : list ident :=
  mario._set_mario_animation :: C._cutscene_put_cap_on
    :: mario._is_anim_at_end :: mario_step._stationary_ground_step :: nil.
Definition poc_xids : list ident :=
  C._enable_time_stop :: C._disable_time_stop :: nil.

(* the WALKED leaves (SLICE 1 + SLICE 2 + SLICE 3 + SLICE 4 + SLICE 5
   + SLICE 12 + SLICE 13 + SLICE 14). *)
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
    :: C._act_spawn_no_spin_landing :: C._act_standing_death
    :: C._act_fall_after_star_grab :: C._act_spawn_spin_airborne
    :: C._act_warp_door_spawn :: C._act_going_through_door
    :: C._act_entering_star_door :: C._act_reading_npc_dialog
    :: C._act_unlocking_star_door
    :: C._act_reading_sign :: C._act_bbh_enter_spin
    :: C._act_reading_automatic_dialog :: C._act_bbh_enter_jump
    :: C._act_star_dance :: C._act_star_dance_water
    :: C._act_squished :: C._act_quicksand_death
    :: C._act_putting_on_cap
    :: C._act_head_stuck_in_ground :: C._act_butt_stuck_in_ground
    :: C._act_feet_stuck_in_ground
    :: C._check_for_instant_quicksand
    :: C._act_unlocking_key_door
    :: C._act_credits_cutscene
    :: C._act_jumbo_star_cutscene
    :: C._act_exit_land_save_dialog
    :: C._act_debug_free_move
    :: C._act_intro_cutscene
    :: C._act_end_waving_cutscene :: nil.
Definition cut_rest_ids : list ident :=
  filter (fun id => negb (mem_id id cut_walked_ids)) cutscene_callee_ids.

(* the cutscene GLOBAL object-pointer roots: stores THROUGH a value loaded from
   one of these land in the SafeB object pool (the intro warp-pipe / end-peach
   objects are spawn_object'd into the pool).  Used by the bespoke glob-obj
   chase walker that closes intro/end_peach/end_waving. *)
Definition gobj_ids : list ident :=
  mario_actions_cutscene._sIntroWarpPipeObj
    :: mario_actions_cutscene._sEndPeachObj
    :: mario_actions_cutscene._sEndRightToadObj
    :: mario_actions_cutscene._sEndLeftToadObj :: nil.

(* ====================================================================== *)
(* INTRO CUTSCENE family (act_intro_cutscene + 7 subhandlers).  Closing    *)
(* this leaf takes cut_rest 3->2.  The 4 standard subhandlers walk via the *)
(* generic engine (call_pres_of_wwalk); the 3 glob-obj ones (raise_pipe /  *)
(* lower_pipe store THROUGH sIntroWarpPipeObj; peach_lakitu SETS it) use a  *)
(* bespoke walker keyed on glob_obj_seed.  See [[cutscene-globobj-campaign]].*)
(* ---- subhandler #5 land_outside_pipe: no stores, 4 marg calls. ---- *)
Definition lop_ids : list ident :=
  mario._set_mario_animation :: mario._is_anim_at_end
    :: mario_actions_cutscene._advance_cutscene_step
    :: mario_step._stop_and_set_height_to_floor :: nil.
Example lop_pin :
  (prog_defmap mario_actions_cutscene.prog)
    ! mario_actions_cutscene._intro_cutscene_land_outside_pipe
  = Some (Gfun (Internal mario_actions_cutscene.f_intro_cutscene_land_outside_pipe)).
Proof. vm_compute. reflexivity. Qed.
Example lop_vars :
  fn_vars mario_actions_cutscene.f_intro_cutscene_land_outside_pipe = nil.
Proof. vm_compute. reflexivity. Qed.
Example lop_pok :
  match fn_params mario_actions_cutscene.f_intro_cutscene_land_outside_pipe with
  | (i, ty) :: ps =>
      Pos.eqb i Am && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id Am (map fst ps))
  | nil => false end = true.
Proof. vm_compute. reflexivity. Qed.
Example lop_walk :
  wwalk_chk false nil lop_ids nil nil nil nil nil
    (fn_body mario_actions_cutscene.f_intro_cutscene_land_outside_pipe) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- subhandler #1 hide_hud_and_mario: gHudDisplay glob store + chase    *)
(* stores through statusForCamera/marioObj + advance_cutscene_step. ---- *)
Definition hhm_ids : list ident :=
  mario_actions_cutscene._advance_cutscene_step :: nil.
Definition hhm_cact : list ident :=
  mario_actions_cutscene._t'4 :: mario_actions_cutscene._t'1
    :: mario_actions_cutscene._t'2 :: nil.
Example hhm_pin :
  (prog_defmap mario_actions_cutscene.prog)
    ! mario_actions_cutscene._intro_cutscene_hide_hud_and_mario
  = Some (Gfun (Internal mario_actions_cutscene.f_intro_cutscene_hide_hud_and_mario)).
Proof. vm_compute. reflexivity. Qed.
Example hhm_vars :
  fn_vars mario_actions_cutscene.f_intro_cutscene_hide_hud_and_mario = nil.
Proof. vm_compute. reflexivity. Qed.
Example hhm_pok :
  match fn_params mario_actions_cutscene.f_intro_cutscene_hide_hud_and_mario with
  | (i, ty) :: ps =>
      Pos.eqb i Am && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id Am (map fst ps))
  | nil => false end = true.
Proof. vm_compute. reflexivity. Qed.
Example hhm_walk :
  wwalk_chk false nil hhm_ids nil hhm_cact nil nil nil
    (fn_body mario_actions_cutscene.f_intro_cutscene_hide_hud_and_mario) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- subhandler #4 jump_out_of_pipe: m->actionTimer window + gHudDisplay  *)
(* glob + marioObj chase store + 6 marg calls + play_sound/sound_banks_enable *)
(* externals (perform_air_step lands AIR_STEP_LANDED branch). ---- *)
Definition jop_ids : list ident :=
  mario._play_sound_if_no_flag :: mario._set_mario_animation
    :: mario._mario_set_forward_vel :: mario_step._perform_air_step
    :: mario._play_mario_landing_sound
    :: mario_actions_cutscene._advance_cutscene_step :: nil.
Definition jop_xids : list ident :=
  mario_actions_cutscene._sound_banks_enable :: mario._play_sound :: nil.
Definition jop_cact : list ident :=
  mario_actions_cutscene._t'4 :: mario_actions_cutscene._t'5
    :: mario_actions_cutscene._t'3 :: nil.
Example jop_pin :
  (prog_defmap mario_actions_cutscene.prog)
    ! mario_actions_cutscene._intro_cutscene_jump_out_of_pipe
  = Some (Gfun (Internal mario_actions_cutscene.f_intro_cutscene_jump_out_of_pipe)).
Proof. vm_compute. reflexivity. Qed.
Example jop_vars :
  fn_vars mario_actions_cutscene.f_intro_cutscene_jump_out_of_pipe = nil.
Proof. vm_compute. reflexivity. Qed.
Example jop_pok :
  match fn_params mario_actions_cutscene.f_intro_cutscene_jump_out_of_pipe with
  | (i, ty) :: ps =>
      Pos.eqb i Am && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id Am (map fst ps))
  | nil => false end = true.
Proof. vm_compute. reflexivity. Qed.
Example jop_walk :
  wwalk_chk false nil jop_ids nil jop_cact jop_xids nil nil
    (fn_body mario_actions_cutscene.f_intro_cutscene_jump_out_of_pipe) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- subhandler #7 set_mario_to_idle: gCamera read (scratch temps,        *)
(* auto-accepted) + gCameraMovementFlags glob store + set_mario_action       *)
(* (sids) + stop_and_set_height_to_floor. ---- *)
Definition smti_ids : list ident :=
  mario_step._stop_and_set_height_to_floor :: nil.
Definition smti_sids : list ident := mario._set_mario_action :: nil.
Example smti_pin :
  (prog_defmap mario_actions_cutscene.prog)
    ! mario_actions_cutscene._intro_cutscene_set_mario_to_idle
  = Some (Gfun (Internal mario_actions_cutscene.f_intro_cutscene_set_mario_to_idle)).
Proof. vm_compute. reflexivity. Qed.
Example smti_vars :
  fn_vars mario_actions_cutscene.f_intro_cutscene_set_mario_to_idle = nil.
Proof. vm_compute. reflexivity. Qed.
Example smti_pok :
  match fn_params mario_actions_cutscene.f_intro_cutscene_set_mario_to_idle with
  | (i, ty) :: ps =>
      Pos.eqb i Am && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id Am (map fst ps))
  | nil => false end = true.
Proof. vm_compute. reflexivity. Qed.
Example smti_walk :
  wwalk_chk false nil smti_ids nil nil nil smti_sids nil
    (fn_body mario_actions_cutscene.f_intro_cutscene_set_mario_to_idle) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- subhandler #2 peach_lakitu_scene: a GENERIC walk.  The glob-obj SET   *)
(* store `Sassign (Evar sIntroWarpPipeObj) (Etempvar t'1)` is the generic     *)
(* glob_store_chk arm now that sIntroWarpPipeObj is in stored_globals -- the  *)
(* rvalue (the spawn_object_abs_with_rot result) is unconstrained, MWF        *)
(* tolerates any store into the off-Mario static cell (Hglob_blk).            *)
(* gCurrentObject is READ-only (Sset t'5, scratch); the m->actionTimer        *)
(* increment is a Mario window store; advance_cutscene_step is a marg call    *)
(* (ids); spawn_object_abs_with_rot is a terminal external (xids). ---- *)
Definition pk_ids : list ident :=
  mario_actions_cutscene._advance_cutscene_step :: nil.
Definition pk_xids : list ident :=
  mario_actions_cutscene._spawn_object_abs_with_rot :: nil.
Example pk_pin :
  (prog_defmap mario_actions_cutscene.prog)
    ! mario_actions_cutscene._intro_cutscene_peach_lakitu_scene
  = Some (Gfun (Internal mario_actions_cutscene.f_intro_cutscene_peach_lakitu_scene)).
Proof. vm_compute. reflexivity. Qed.
Example pk_vars :
  fn_vars mario_actions_cutscene.f_intro_cutscene_peach_lakitu_scene = nil.
Proof. vm_compute. reflexivity. Qed.
Example pk_pok :
  match fn_params mario_actions_cutscene.f_intro_cutscene_peach_lakitu_scene with
  | (i, ty) :: ps =>
      Pos.eqb i Am && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id Am (map fst ps))
  | nil => false end = true.
Proof. vm_compute. reflexivity. Qed.
Example pk_walk :
  wwalk_chk false nil pk_ids nil nil pk_xids nil nil
    (fn_body mario_actions_cutscene.f_intro_cutscene_peach_lakitu_scene) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- the dispatcher: act_intro_cutscene is a switch(m->actionArg) over the *)
(* 7 subhandlers (each a marg call in ids), returning FALSE (Econst_int 0,    *)
(* rt=false so the return arm is unconstrained).  jumbo_pres precedent. ---- *)
Definition intro_ids : list ident :=
  mario_actions_cutscene._intro_cutscene_hide_hud_and_mario
    :: mario_actions_cutscene._intro_cutscene_peach_lakitu_scene
    :: mario_actions_cutscene._intro_cutscene_raise_pipe
    :: mario_actions_cutscene._intro_cutscene_jump_out_of_pipe
    :: mario_actions_cutscene._intro_cutscene_land_outside_pipe
    :: mario_actions_cutscene._intro_cutscene_lower_pipe
    :: mario_actions_cutscene._intro_cutscene_set_mario_to_idle :: nil.
Example intro_pin :
  (prog_defmap mario_actions_cutscene.prog) ! C._act_intro_cutscene
  = Some (Gfun (Internal C.f_act_intro_cutscene)).
Proof. vm_compute. reflexivity. Qed.
Example intro_walk :
  wwalk_chk false nil intro_ids nil nil nil nil nil
    (fn_body C.f_act_intro_cutscene) = true.
Proof. vm_compute. reflexivity. Qed.

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
Example sd_pin :
  (prog_defmap C.prog) ! C._act_standing_death
  = Some (Gfun (Internal C.f_act_standing_death)).
Proof. vm_compute. reflexivity. Qed.
Example fasg_pin :
  (prog_defmap C.prog) ! C._act_fall_after_star_grab
  = Some (Gfun (Internal C.f_act_fall_after_star_grab)).
Proof. vm_compute. reflexivity. Qed.
Example ssa_pin :
  (prog_defmap C.prog) ! C._act_spawn_spin_airborne
  = Some (Gfun (Internal C.f_act_spawn_spin_airborne)).
Proof. vm_compute. reflexivity. Qed.
Example wds_pin :
  (prog_defmap C.prog) ! C._act_warp_door_spawn
  = Some (Gfun (Internal C.f_act_warp_door_spawn)).
Proof. vm_compute. reflexivity. Qed.
Example gtd_pin :
  (prog_defmap C.prog) ! C._act_going_through_door
  = Some (Gfun (Internal C.f_act_going_through_door)).
Proof. vm_compute. reflexivity. Qed.
Example esd_pin :
  (prog_defmap C.prog) ! C._act_entering_star_door
  = Some (Gfun (Internal C.f_act_entering_star_door)).
Proof. vm_compute. reflexivity. Qed.
Example rnd_pin :
  (prog_defmap C.prog) ! C._act_reading_npc_dialog
  = Some (Gfun (Internal C.f_act_reading_npc_dialog)).
Proof. vm_compute. reflexivity. Qed.
Example usd_pin :
  (prog_defmap C.prog) ! C._act_unlocking_star_door
  = Some (Gfun (Internal C.f_act_unlocking_star_door)).
Proof. vm_compute. reflexivity. Qed.
Example cfiq_pin :
  (prog_defmap C.prog) ! C._check_for_instant_quicksand
  = Some (Gfun (Internal C.f_check_for_instant_quicksand)).
Proof. vm_compute. reflexivity. Qed.
Example ukd_pin :
  (prog_defmap C.prog) ! C._act_unlocking_key_door
  = Some (Gfun (Internal C.f_act_unlocking_key_door)).
Proof. vm_compute. reflexivity. Qed.
Example cred_pin :
  (prog_defmap C.prog) ! C._act_credits_cutscene
  = Some (Gfun (Internal C.f_act_credits_cutscene)).
Proof. vm_compute. reflexivity. Qed.
Example rs_pin :
  (prog_defmap C.prog) ! C._act_reading_sign
  = Some (Gfun (Internal C.f_act_reading_sign)).
Proof. vm_compute. reflexivity. Qed.
Example bbhs_pin :
  (prog_defmap C.prog) ! C._act_bbh_enter_spin
  = Some (Gfun (Internal C.f_act_bbh_enter_spin)).
Proof. vm_compute. reflexivity. Qed.
Example rad_pin :
  (prog_defmap C.prog) ! C._act_reading_automatic_dialog
  = Some (Gfun (Internal C.f_act_reading_automatic_dialog)).
Proof. vm_compute. reflexivity. Qed.
Example bbhj_pin :
  (prog_defmap C.prog) ! C._act_bbh_enter_jump
  = Some (Gfun (Internal C.f_act_bbh_enter_jump)).
Proof. vm_compute. reflexivity. Qed.
Example gscd_pin :
  (prog_defmap C.prog) ! C._get_star_collection_dialog
  = Some (Gfun (Internal C.f_get_star_collection_dialog)).
Proof. vm_compute. reflexivity. Qed.
Example gsdh_pin :
  (prog_defmap C.prog) ! C._general_star_dance_handler
  = Some (Gfun (Internal C.f_general_star_dance_handler)).
Proof. vm_compute. reflexivity. Qed.
Example sdn_pin :
  (prog_defmap C.prog) ! C._act_star_dance
  = Some (Gfun (Internal C.f_act_star_dance)).
Proof. vm_compute. reflexivity. Qed.
Example sdw_pin :
  (prog_defmap C.prog) ! C._act_star_dance_water
  = Some (Gfun (Internal C.f_act_star_dance_water)).
Proof. vm_compute. reflexivity. Qed.
Example sq_pin :
  (prog_defmap C.prog) ! C._act_squished
  = Some (Gfun (Internal C.f_act_squished)).
Proof. vm_compute. reflexivity. Qed.
(* SLICE 15 pins/shapes: the sgs sub-tree near-leaves + the leaf. *)
Example mums_pin :
  (prog_defmap mario_step.prog) ! mario_step._mario_update_moving_sand
  = Some (Gfun (Internal mario_step.f_mario_update_moving_sand)).
Proof. vm_compute. reflexivity. Qed.
Example mums_vars : fn_vars mario_step.f_mario_update_moving_sand = nil.
Proof. vm_compute. reflexivity. Qed.
Example mums_pok :
  match fn_params mario_step.f_mario_update_moving_sand with
  | (i, ty) :: ps =>
      Pos.eqb i Am && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id Am (map fst ps))
  | nil => false end = true.
Proof. vm_compute. reflexivity. Qed.
Example muwg_pin :
  (prog_defmap mario_step.prog) ! mario_step._mario_update_windy_ground
  = Some (Gfun (Internal mario_step.f_mario_update_windy_ground)).
Proof. vm_compute. reflexivity. Qed.
Example muwg_vars : fn_vars mario_step.f_mario_update_windy_ground = nil.
Proof. vm_compute. reflexivity. Qed.
Example muwg_pok :
  match fn_params mario_step.f_mario_update_windy_ground with
  | (i, ty) :: ps =>
      Pos.eqb i Am && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id Am (map fst ps))
  | nil => false end = true.
Proof. vm_compute. reflexivity. Qed.
Example satf_pin :
  (prog_defmap mario.prog) ! mario._set_anim_to_frame
  = Some (Gfun (Internal mario.f_set_anim_to_frame)).
Proof. vm_compute. reflexivity. Qed.
Example satf_vars : fn_vars mario.f_set_anim_to_frame = nil.
Proof. vm_compute. reflexivity. Qed.
Example satf_pok :
  match fn_params mario.f_set_anim_to_frame with
  | (i, ty) :: ps =>
      Pos.eqb i Am && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id Am (map fst ps))
  | nil => false end = true.
Proof. vm_compute. reflexivity. Qed.
Example sgs_pin :
  (prog_defmap mario_step.prog) ! mario_step._stationary_ground_step
  = Some (Gfun (Internal mario_step.f_stationary_ground_step)).
Proof. vm_compute. reflexivity. Qed.
Example sgs_vars : fn_vars mario_step.f_stationary_ground_step = nil.
Proof. vm_compute. reflexivity. Qed.
Example sgs_pok :
  match fn_params mario_step.f_stationary_ground_step with
  | (i, ty) :: ps =>
      Pos.eqb i Am && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id Am (map fst ps))
  | nil => false end = true.
Proof. vm_compute. reflexivity. Qed.
Example qsd_pin :
  (prog_defmap C.prog) ! C._act_quicksand_death
  = Some (Gfun (Internal C.f_act_quicksand_death)).
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

(* advance_cutscene_step: the cutscene-step bumper -- three safe-window
   stores (actionState / actionTimer / actionArg, all outside the protected
   input/action/chase cells) + one load, no calls.  All-nil census. *)
Example acs_pin :
  (prog_defmap mario_actions_cutscene.prog)
    ! mario_actions_cutscene._advance_cutscene_step
  = Some (Gfun (Internal mario_actions_cutscene.f_advance_cutscene_step)).
Proof. vm_compute. reflexivity. Qed.
Example acs_vars : fn_vars mario_actions_cutscene.f_advance_cutscene_step = nil.
Proof. vm_compute. reflexivity. Qed.
Example acs_pok :
  match fn_params mario_actions_cutscene.f_advance_cutscene_step with
  | (i, ty) :: ps =>
      Pos.eqb i Am && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id Am (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Example acs_walk :
  wwalk_chk false nil nil nil nil nil nil nil
    (fn_body mario_actions_cutscene.f_advance_cutscene_step) = true.
Proof. vm_compute. reflexivity. Qed.

(* SLICE 16 pins: cutscene_put_cap_on (tiny flags-store helper) and
   act_putting_on_cap. *)
Example cpco_pin :
  (prog_defmap C.prog) ! C._cutscene_put_cap_on
  = Some (Gfun (Internal C.f_cutscene_put_cap_on)).
Proof. vm_compute. reflexivity. Qed.
Example cpco_vars : fn_vars C.f_cutscene_put_cap_on = nil.
Proof. vm_compute. reflexivity. Qed.
Example cpco_pok :
  match fn_params C.f_cutscene_put_cap_on with
  | (i, ty) :: ps =>
      Pos.eqb i Am && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id Am (map fst ps))
  | nil => false end = true.
Proof. vm_compute. reflexivity. Qed.
Example cpco_walk :
  wwalk_chk false nil nil nil nil cpco_xids nil nil
    (fn_body C.f_cutscene_put_cap_on) = true.
Proof. vm_compute. reflexivity. Qed.
Example poc_pin :
  (prog_defmap C.prog) ! C._act_putting_on_cap
  = Some (Gfun (Internal C.f_act_putting_on_cap)).
Proof. vm_compute. reflexivity. Qed.
Example poc_vars : fn_vars C.f_act_putting_on_cap = nil.
Proof. vm_compute. reflexivity. Qed.
Example poc_pok :
  match fn_params C.f_act_putting_on_cap with
  | (i, ty) :: ps =>
      Pos.eqb i Am && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id Am (map fst ps))
  | nil => false end = true.
Proof. vm_compute. reflexivity. Qed.
Example poc_walk :
  wwalk_chk false nil poc_ids nil nil poc_xids tfi_sids nil
    (fn_body C.f_act_putting_on_cap) = true.
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

(* ---------------------------------------------------------------------- *)
(* Pure CompCert helpers for the index-5 stuck-in-ground wrapper rows.     *)
(* (section-independent: no genv/section vars).                            *)
(* ---------------------------------------------------------------------- *)
Lemma sem_cast_tint_tint_id :
  forall n m, sem_cast (Vint n) tint tint m = Some (Vint n).
Proof. intros. reflexivity. Qed.

(* a 6-arg exprlist whose 6th arg is a CONST int (Econst_int ACT tint) with
   last typelist entry tint yields a 6-elt vargs ending in Vint ACT. *)
Lemma exprlist_action6 :
  forall ge e le m a0 a1 a2 a3 a4 ACT t0 t1 t2 t3 t4 vargs,
    eval_exprlist ge e le m
      (a0 :: a1 :: a2 :: a3 :: a4 :: Econst_int ACT tint :: nil)
      (t0 :: t1 :: t2 :: t3 :: t4 :: tint :: nil) vargs ->
    exists v0 v1 v2 v3 v4,
      vargs = v0 :: v1 :: v2 :: v3 :: v4 :: Vint ACT :: nil.
Proof.
  intros ge e le m a0 a1 a2 a3 a4 ACT t0 t1 t2 t3 t4 vargs Hel.
  do 5 (match goal with H : eval_exprlist _ _ _ _ (_ :: _ :: _) _ _ |- _ =>
          inv H end).
  match goal with H : eval_exprlist _ _ _ _ (Econst_int _ _ :: nil) _ _ |- _ =>
    inv H end.
  match goal with H : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ => inv H end.
  2: { match goal with Hl : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ =>
         inv Hl end. }
  match goal with H : eval_exprlist _ _ _ _ nil _ _ |- _ => inv H end.
  match goal with H : sem_cast (Vint _) _ tint _ = Some _ |- _ =>
    cbn in H; injection H as <- end.
  do 5 eexists; reflexivity.
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
  (* INTRO-cutscene terminal externals (sound_banks_enable / camera_approach_
     f32_symmetric / obj_mark_for_deletion / spawn_object_abs_with_rot): the
     honest model boundary, EF_external in every linked TU, each writing
     camera/sound/object-pool state and never Mario's bm action cell.  They are
     in cut_ext_ids, so the Hcpx_* rows below (after Hcut_ext) are PROVED via
     Hcut_ext -- NO new capstone trust beyond the existing cutscene-external
     boundary (Hpres_cut_ext).  spawn_object_abs_with_rot's result is stored
     into sIntroWarpPipeObj via the unconstrained glob_store arm. *)
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
  (* SLICE 12 dialog cluster.  Hcut_ext = the new cutscene dialog/time-stop
     external boundary (cut_ext_ids): EF_external in every linked TU, fed at
     the capstone by Hpres_cut_ext (the honest model boundary, same class as
     obj_ext/sta_ext/mov_ext).  atan2s / sqrtf / vec3f_set are the pure
     math/vector externals (all three now in obj_ext_ids), fed via
     Hpres_obj_ext -- NO new trust. *)
  Hypothesis Hcut_ext : forall fid,
      mem_id fid cut_ext_ids = true -> call_pres_ext lp bm NoA MWF fid.
  (* the 4 INTRO-cutscene externals, PROVED from Hcut_ext (all in cut_ext_ids):
     spawn_object_abs_with_rot / camera_approach_f32_symmetric /
     sound_banks_enable / obj_mark_for_deletion.  NO new capstone trust. *)
  Lemma Hcpx_sbe :
    call_pres_ext lp bm NoA MWF mario_actions_cutscene._sound_banks_enable.
  Proof. apply Hcut_ext; vm_compute; reflexivity. Qed.
  Lemma Hcpx_caf :
    call_pres_ext lp bm NoA MWF mario_actions_cutscene._camera_approach_f32_symmetric.
  Proof. apply Hcut_ext; vm_compute; reflexivity. Qed.
  Lemma Hcpx_omfd :
    call_pres_ext lp bm NoA MWF mario_actions_cutscene._obj_mark_for_deletion.
  Proof. apply Hcut_ext; vm_compute; reflexivity. Qed.
  Lemma Hcpx_soawr :
    call_pres_ext lp bm NoA MWF mario_actions_cutscene._spawn_object_abs_with_rot.
  Proof. apply Hcut_ext; vm_compute; reflexivity. Qed.
  Hypothesis Hcpx_atan2s :
    call_pres_ext lp bm NoA MWF interaction._atan2s.
  (* approach_s32: a pure-math integer-clamp EF_external (in obj_ext_ids; no
     Mem write).  The capstone feeds the dedicated Hcpx_approach_real -- the
     SAME term the submerged family threads -- so NO new trust.  Consumed only
     by act_reading_npc_dialog (rnd). *)
  Hypothesis Hcpx_approach :
    call_pres_ext lp bm NoA MWF mario_actions_object._approach_s32.
  (* act_unlocking_star_door (usd) externals -- ALL honest boundaries the
     capstone ALREADY supplies (NO new capstone hypothesis):
     - spawn_object: the object-pool allocator (Hcpx_so_real, derived from the
       standing Hcp_spawn_real);
     - save_file_get_flags / save_file_set_flags: save-buffer reader/writer
       externals in obj_ext_ids (Hpres_obj_ext).  Hcpx_sfgf is consumed only by
       cut_gdsff_row (the in-section twin of InterSurface.gdsff_row). *)
  Hypothesis Hcpx_spawn :
    call_pres_ext lp bm NoA MWF interaction._spawn_object.
  Hypothesis Hcpx_sfgf :
    call_pres_ext lp bm NoA MWF interaction._save_file_get_flags.
  Hypothesis Hcpx_sfsf :
    call_pres_ext lp bm NoA MWF interaction._save_file_set_flags.
  Hypothesis Hcpx_sqrtf : call_pres_ext lp bm NoA MWF mario._sqrtf.
  Hypothesis Hcpx_v3fset : call_pres_ext lp bm NoA MWF mario._vec3f_set.
  (* SLICE 14 (act_squished): perform_ground_step, DISCHARGED at the capstone
     (MarioStepSurface) -- supplied here as a section hyp, zero new trust. *)
  Hypothesis Hcp_pgs :
    call_pres lp bm NoA MWF mario_step._perform_ground_step.
  (* the stack-frame MWF rows for the body_pres_of_lwalk leaf (act_squished's
     dead filler[4]).  Discharged at the capstone from MWFReal:
     HMWF_alloc <- mwf_real_alloc, HMWF_free <- mwf_real_free. *)
  Hypothesis HMWF_alloc : forall m lo hi m' b,
      Mem.alloc m lo hi = (m', b) -> MWF m -> MWF m'.
  Hypothesis HMWF_free : forall m l m',
      Mem.free_list m l = Some m' -> MWF m -> MWF m'.
  (* SLICE 17 (act_going_through_door): the SafeB/global stack-frame validity
     projections that update_mario_pos_for_anim's WALK consumes (it allocs the
     _translation local + calls find_mario_anim_flags_and_translation, the
     oc2 out-param helper).  Discharged at the capstone from MWFReal:
     HSafeValid <- mwf_real_safe_valid, HGlobValid <- Hglob_valid -- the SAME
     terms the automatic family already threads, NO new trust. *)
  Hypothesis HSafeValid :
    forall m, MWF m -> forall b, SafeB b -> Mem.valid_block m b.
  Hypothesis HGlobValid :
    forall m, MWF m -> forall gid bg,
        Genv.find_symbol (lp_ge lp) gid = Some bg -> Mem.valid_block m bg.
  (* update_mario_pos_for_anim's WALK (Humpfa) also bottoms out in: the
     stack-local store->MWF brick (Hls_real <- aut_local_store), and the three
     terminal externals of its find_mario_anim_flags_and_translation callee --
     segmented_to_virtual (call_pres_ext), geo_update_animation_frame (sc-gated
     out-param) and retrieve_animation_index (oc-gated out-param).  Discharged
     at the capstone from the SAME automatic-family terms (aut_local_store,
     Hpres_obj_ext, Hscp_geo_real, Hocp_rai_real) -- NO new trust. *)
  Hypothesis Hls_real :
    forall m ch b (d : Z) v m',
      LocalVarsSurface.local_blk lp bm SafeB b ->
      Mem.store ch m b d v = Some m' -> MWF m -> MWF m'.
  Hypothesis Hcpx_s2v :
    call_pres_ext lp bm NoA MWF interaction._segmented_to_virtual.
  Hypothesis Hscp_geo :
    OutParamSurface.call_pres_ext_sc lp bm NoA MWF SafeB
      mario._geo_update_animation_frame.
  Hypothesis Hocp_rai :
    OutParamSurface.call_pres_ext_oc lp bm NoA MWF SafeB
      mario._retrieve_animation_index.
  (* SLICE 22 (check_for_instant_quicksand): the keystone dasma_row needs two
     more honest externals beyond Hcpx_s2v (stop_shell_music, obj_set_held_state
     -- both ride obj_ext_ids at the capstone), and update_mario_sound_and_camera
     rides the SAME floors-family call_pres the capstone already builds.  NO new
     trust. *)
  Hypothesis Hcpx_ssm :
    call_pres_ext lp bm NoA MWF interaction._stop_shell_music.
  Hypothesis Hcpx_oshs :
    call_pres_ext lp bm NoA MWF interaction._obj_set_held_state.
  Hypothesis Hcp_umsc :
    call_pres lp bm NoA MWF mario._update_mario_sound_and_camera.
  (* SLICE 23 (act_unlocking_key_door) externals -- both honest boundaries the
     capstone ALREADY supplies (NO new capstone hypothesis):
     - save_file_clear_flags: the save-buffer WRITER twin of save_file_set_flags,
       in obj_ext_ids (fed via Hpres_obj_ext);
     - spawn_object (SafeB-RETURN form): the standing Hcp_spawn_real, threaded
       into the in-TU spawn_obj_at_mario_rel_yaw helper (SpawnObjSurface). *)
  Hypothesis Hcpx_sfcf :
    call_pres_ext lp bm NoA MWF interaction._save_file_clear_flags.
  Hypothesis Hcpx_spawn_sr :
    WindSurface.call_pres_ext_sr lp bm NoA MWF SafeB C._spawn_object.
  (* SLICE 24 (act_credits_cutscene) externals -- all honest boundaries now in
     obj_ext_ids, fed at the capstone via Hpres_obj_ext (NO new capstone trust):
     - vec3s_copy: the s16-vector copy twin of vec3f_copy / vec3s_set (writes the
       Object's interior, never bm);
     - override_viewport_and_clip / reset_cutscene_msg_fade: the cutscene HUD/
       viewport EF_external boundaries (write rendering state, never Mario). *)
  Hypothesis Hcpx_v3sc : call_pres_ext lp bm NoA MWF mario._vec3s_copy.
  Hypothesis Hcpx_ovac :
    call_pres_ext lp bm NoA MWF C._override_viewport_and_clip.
  Hypothesis Hcpx_rcmf :
    call_pres_ext lp bm NoA MWF C._reset_cutscene_msg_fade.

  (* cutscene jumbo-star (flying): the spline-keyframe animator externals --
     EF_external terminal boundary, supplied at the capstone by Hpres_obj_ext
     (both now in ObjectLeafSurface.obj_ext_ids).  NO new capstone trust. *)
  Hypothesis Hcpx_asi : call_pres_ext lp bm NoA MWF C._anim_spline_init.
  Hypothesis Hcpx_asp : call_pres_ext lp bm NoA MWF C._anim_spline_poll.

  (* cutscene jumbo-star (falling) input-OR-store keystones (NO new trust:
     both are PROVED MWFReal projections at the capstone).  jumbo_star_cutscene_
     falling does `m->input |= INPUT_SQUISHED` (0x80) -- a store into the input
     cell [2,4) that store_window_ok deliberately EXCLUDES (it is the A-clear
     cell).  The store is sound because 0x80 & 0x2 = 0, so it preserves
     input_a_clear (and hence MWF and NoA = ctl_a_clear, whose cells -- bm@156
     + the controller block -- are disjoint from [2,4)).  HMWF_inp is the
     input_a_clear projection (mwf_real_inp); HMWF_inp_store is the input-cell
     store-tolerance row (mwf_real_input). *)
  Hypothesis HMWF_inp : forall m, MWF m -> AGates.input_a_clear m bm.
  Hypothesis HMWF_inp_store : forall mm mm' vv,
      MWF mm -> Int.and vv (Int.repr 2) = Int.zero ->
      Mem.store Mint16unsigned mm bm 2 (Vint vv) = Some mm' -> MWF mm'.

  (* SLICE 17: update_mario_pos_for_anim is WALKED (AutomaticLeafSurface.Humpfa,
     a HYBRID walk: the famft out-param call via oc2 + the two pos[i] window
     stores).  Fed here from the section hyps above -- NO new trust. *)
  Lemma Hcp_umpfa :
    call_pres lp bm NoA MWF mario._update_mario_pos_for_anim.
  Proof. eapply AutomaticLeafSurface.Humpfa; eassumption. Qed.

  Lemma Hcp_psinf : call_pres lp bm NoA MWF mario._play_sound_if_no_flag.
  Proof. eapply ObjectLeafSurface.psinf_row; eassumption. Qed.
  Lemma Hcp_sma : call_pres lp bm NoA MWF mario._set_mario_animation.
  Proof. eapply ObjectLeafSurface.sma_row; eassumption. Qed.
  (* is_anim_past_end: the loads-only "anim past end?" helper (twin of
     is_anim_at_end), reused from ObjectLeafSurface -- NO new trust. *)
  Lemma Hcp_ipae : call_pres lp bm NoA MWF mario._is_anim_past_end.
  Proof. eapply ObjectLeafSurface.ipae_row; eassumption. Qed.
  (* advance_cutscene_step: three safe-window stores, no calls (walked in-file,
     all-nil censuses). *)
  Lemma cut_acs_row :
    call_pres lp bm NoA MWF mario_actions_cutscene._advance_cutscene_step.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_cutscene.prog
             mario_actions_cutscene._advance_cutscene_step
             mario_actions_cutscene.f_advance_cutscene_step nil nil nil nil
             LO_cut acs_pin acs_vars acs_pok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact acs_walk.
  Qed.
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

  (* ---- INTRO subhandler #5: land_outside_pipe (4 marg calls, no stores). ---- *)
  Lemma lop_ids_rows : forall fid, mem_id fid lop_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold lop_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_sma | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact cut_iae_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact cut_acs_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_sashf | discriminate H ].
  Qed.

  Lemma lop_row :
    call_pres lp bm NoA MWF mario_actions_cutscene._intro_cutscene_land_outside_pipe.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_cutscene.prog
             mario_actions_cutscene._intro_cutscene_land_outside_pipe
             mario_actions_cutscene.f_intro_cutscene_land_outside_pipe
             lop_ids nil nil nil
             LO_cut lop_pin lop_vars lop_pok).
    - exact lop_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact lop_walk.
  Qed.

  (* ---- INTRO subhandler #1: hide_hud_and_mario (gHudDisplay glob store +
     chase stores through statusForCamera/marioObj + advance_cutscene_step). ---- *)
  Lemma hhm_ids_rows : forall fid, mem_id fid hhm_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold hhm_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact cut_acs_row | discriminate H ].
  Qed.

  Lemma hhm_row :
    call_pres lp bm NoA MWF mario_actions_cutscene._intro_cutscene_hide_hud_and_mario.
  Proof.
    apply (call_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_cutscene.prog
             mario_actions_cutscene._intro_cutscene_hide_hud_and_mario
             mario_actions_cutscene.f_intro_cutscene_hide_hud_and_mario
             hhm_ids nil hhm_cact nil nil
             LO_cut hhm_pin hhm_vars hhm_pok).
    - vm_compute. reflexivity.
    - exact hhm_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact hhm_walk.
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
  (* SLICE 22: the const-action keystone for check_for_instant_quicksand --
     reused verbatim from ObjectLeafSurface, gated on the three honest externals
     (Hcpx_s2v/ssm/oshs).  ZERO new trust. *)
  Let Hdasma : call_pres_act lp bm NoA MWF mario._drop_and_set_mario_action :=
    ObjectLeafSurface.dasma_row lp LO_mario LO_stp LO_int bm NoA MWF HNoA_of_MWF
      HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
      HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
      Hcpx_s2v Hcpx_ssm Hcpx_oshs.
  (* set_water_plunge_action: a plain window/out-param helper (vec3s_set +
     set_camera_mode), reused from ObjectLeafSurface.swpa_row -- no new trust. *)
  Let Hswpa : call_pres lp bm NoA MWF mario._set_water_plunge_action :=
    ObjectLeafSurface.swpa_row lp LO_mario LO_stp bm NoA MWF HNoA_of_MWF
      HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
      HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
      Hcpx_v3ss Hcpx_scm.
  (* SLICE 23: the in-TU spawn_obj_at_mario_rel_yaw helper (SpawnObjSurface), the
     spawn-then-store-through-spawned-obj arc.  Its only residual, spawn_object's
     SafeB-return boundary, is the section hyp Hcpx_spawn_sr (= Hcp_spawn_real at
     the capstone).  ZERO new trust. *)
  Let Hcp_spawn_obj : call_pres lp bm NoA MWF C._spawn_obj_at_mario_rel_yaw :=
    SpawnObjSurface.spawn_obj_cp lp LO_cut bm NoA MWF SafeB HNoA_of_MWF
      HSafeNotBm HMWF_chase Hcpx_spawn_sr.

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

  (* ---- INTRO subhandler #4: jump_out_of_pipe (window + glob + marioObj
     chase stores, 6 marg calls, sound_banks_enable/play_sound externals). ---- *)
  Lemma jop_ids_rows : forall fid, mem_id fid jop_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold jop_ids in H. cbn [mem_id existsb] in H.
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
      [ apply Pos.eqb_eq in Hm; subst fid; exact cut_acs_row | discriminate H ].
  Qed.
  Lemma jop_xids_rows : forall fid, mem_id fid jop_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold jop_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_sbe | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_psound | discriminate H ].
  Qed.
  Lemma jop_row :
    call_pres lp bm NoA MWF mario_actions_cutscene._intro_cutscene_jump_out_of_pipe.
  Proof.
    apply (call_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_cutscene.prog
             mario_actions_cutscene._intro_cutscene_jump_out_of_pipe
             mario_actions_cutscene.f_intro_cutscene_jump_out_of_pipe
             jop_ids nil jop_cact jop_xids nil
             LO_cut jop_pin jop_vars jop_pok).
    - vm_compute. reflexivity.
    - exact jop_ids_rows.
    - intros fid' H. discriminate H.
    - exact jop_xids_rows.
    - intros fid' H. discriminate H.
    - exact jop_walk.
  Qed.

  (* ---- INTRO subhandler #7: set_mario_to_idle (gCamera read + glob store +
     set_mario_action [sids] + stop_and_set_height_to_floor). ---- *)
  Lemma smti_ids_rows : forall fid, mem_id fid smti_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold smti_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_sashf | discriminate H ].
  Qed.
  Lemma smti_sids_rows : forall fid, mem_id fid smti_sids = true ->
      call_pres_act lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold smti_sids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsmact | discriminate H ].
  Qed.
  Lemma smti_row :
    call_pres lp bm NoA MWF mario_actions_cutscene._intro_cutscene_set_mario_to_idle.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_cutscene.prog
             mario_actions_cutscene._intro_cutscene_set_mario_to_idle
             mario_actions_cutscene.f_intro_cutscene_set_mario_to_idle
             smti_ids nil nil smti_sids
             LO_cut smti_pin smti_vars smti_pok).
    - exact smti_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact smti_sids_rows.
    - exact smti_walk.
  Qed.

  (* ---- subhandler #2 peach_lakitu_scene: generic walk (the glob-obj SET     *)
  (* store rides the unconstrained glob_store arm; spawn is a terminal ext). ---- *)
  Lemma pk_ids_rows : forall fid, mem_id fid pk_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold pk_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact cut_acs_row | discriminate H ].
  Qed.
  Lemma pk_xids_rows : forall fid, mem_id fid pk_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold pk_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_soawr | discriminate H ].
  Qed.
  Lemma pk_row :
    call_pres lp bm NoA MWF mario_actions_cutscene._intro_cutscene_peach_lakitu_scene.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_cutscene.prog
             mario_actions_cutscene._intro_cutscene_peach_lakitu_scene
             mario_actions_cutscene.f_intro_cutscene_peach_lakitu_scene
             pk_ids nil pk_xids nil
             LO_cut pk_pin pk_vars pk_pok).
    - exact pk_ids_rows.
    - intros fid' H. discriminate H.
    - exact pk_xids_rows.
    - intros fid' H. discriminate H.
    - exact pk_walk.
  Qed.

  (* (intro_ids_rows + intro_pres live after lzp_row -- they consume the
     raise_pipe / lower_pipe rows defined in the glob-obj bespoke block.) *)

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

  (* act_standing_death: body_pres_of_wwalk, sids=set_mario_action. *)
  Lemma sd_ids_rows : forall fid, mem_id fid sd_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sd_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_psinf | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact cdh_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact pmls_row | discriminate H ].
  Qed.
  Example sd_vars : fn_vars C.f_act_standing_death = nil.
  Proof. vm_compute. reflexivity. Qed.
  Example sd_pok :
    match fn_params C.f_act_standing_death with
    | (i, ty) :: ps =>
        Pos.eqb i Am && proj_sumbool (type_eq ty tyMSp)
        && negb (mem_id Am (map fst ps))
    | nil => false end = true.
  Proof. vm_compute. reflexivity. Qed.
  Example sd_walk :
    wwalk_chk false nil sd_ids nil nil nil tfi_sids nil
      (fn_body C.f_act_standing_death) = true.
  Proof. vm_compute. reflexivity. Qed.
  Lemma sd_pres : body_pres lp NoA MWF bm C.f_act_standing_death.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             C.f_act_standing_death sd_ids nil nil tfi_sids nil
             sd_vars sd_pok).
    - exact sd_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. unfold tfi_sids in H. cbn [mem_id existsb] in H.
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hsmact | discriminate H ].
    - intros fid' H. discriminate H.
    - exact sd_walk.
  Qed.

  (* act_fall_after_star_grab: body_pres_of_wwalk_wact (wact=[_t'2]). *)
  Lemma fasg_ids_rows : forall fid, mem_id fid fasg_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold fasg_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_pas | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact pmls_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_sma | discriminate H ].
  Qed.
  Example fasg_vars : fn_vars C.f_act_fall_after_star_grab = nil.
  Proof. vm_compute. reflexivity. Qed.
  Example fasg_pok :
    match fn_params C.f_act_fall_after_star_grab with
    | (i, ty) :: ps =>
        Pos.eqb i Am && proj_sumbool (type_eq ty tyMSp)
        && negb (mem_id Am (map fst ps))
    | nil => false end = true.
  Proof. vm_compute. reflexivity. Qed.
  Example fasg_nonparam_wact :
    forallb (fun t' => negb (mem_id t' (map fst (fn_params C.f_act_fall_after_star_grab))))
      fasg_wact = true.
  Proof. vm_compute. reflexivity. Qed.
  Example fasg_nonparam_cact :
    forallb (fun t' => negb (mem_id t' (map fst (fn_params C.f_act_fall_after_star_grab))))
      nil = true.
  Proof. vm_compute. reflexivity. Qed.
  Example fasg_walk :
    wwalk_chk false fasg_wact fasg_ids nil nil fasg_xids tfi_sids nil
      (fn_body C.f_act_fall_after_star_grab) = true.
  Proof. vm_compute. reflexivity. Qed.
  Lemma fasg_pres : body_pres lp NoA MWF bm C.f_act_fall_after_star_grab.
  Proof.
    apply (body_pres_of_wwalk_wact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             C.f_act_fall_after_star_grab fasg_wact fasg_ids nil nil fasg_xids
             tfi_sids nil
             fasg_vars fasg_pok fasg_nonparam_cact fasg_nonparam_wact).
    - exact fasg_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. unfold fasg_xids in H. cbn [mem_id existsb] in H.
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hcpx_psound | discriminate H ].
    - intros fid' H. unfold tfi_sids in H. cbn [mem_id existsb] in H.
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hsmact | discriminate H ].
    - intros fid' H. discriminate H.
    - exact fasg_walk.
  Qed.

  (* act_spawn_spin_airborne: body_pres_of_wwalk, the airborne twin of
     spawn_spin_landing.  cact=nil (marioObj read feeds play_sound only). *)
  Lemma ssa_ids_rows : forall fid, mem_id fid ssa_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold ssa_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hswpa | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hmsfv | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_pas | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact pmls_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_sma | discriminate H ].
  Qed.
  Lemma ssa_xids_rows : forall fid, mem_id fid ssa_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold ssa_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_llit | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_psound | discriminate H ].
  Qed.
  Example ssa_vars : fn_vars C.f_act_spawn_spin_airborne = nil.
  Proof. vm_compute. reflexivity. Qed.
  Example ssa_pok :
    match fn_params C.f_act_spawn_spin_airborne with
    | (i, ty) :: ps =>
        Pos.eqb i Am && proj_sumbool (type_eq ty tyMSp)
        && negb (mem_id Am (map fst ps))
    | nil => false end = true.
  Proof. vm_compute. reflexivity. Qed.
  Example ssa_walk :
    wwalk_chk false nil ssa_ids nil nil ssa_xids tfi_sids nil
      (fn_body C.f_act_spawn_spin_airborne) = true.
  Proof. vm_compute. reflexivity. Qed.
  Lemma ssa_pres : body_pres lp NoA MWF bm C.f_act_spawn_spin_airborne.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             C.f_act_spawn_spin_airborne ssa_ids nil ssa_xids tfi_sids nil
             ssa_vars ssa_pok).
    - exact ssa_ids_rows.
    - intros fid' H. discriminate H.
    - exact ssa_xids_rows.
    - intros fid' H. unfold tfi_sids in H. cbn [mem_id existsb] in H.
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hsmact | discriminate H ].
    - intros fid' H. discriminate H.
    - exact ssa_walk.
  Qed.

  (* act_warp_door_spawn: body_pres_of_wwalk_cact.  cact = [_t'9;_t'8] = the
     usedObj chase temps stored through (rawData.asS32[43] = const). *)
  Lemma wds_ids_rows : forall fid, mem_id fid wds_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold wds_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_sma | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_sashf | discriminate H ].
  Qed.
  Example wds_vars : fn_vars C.f_act_warp_door_spawn = nil.
  Proof. vm_compute. reflexivity. Qed.
  Example wds_pok :
    match fn_params C.f_act_warp_door_spawn with
    | (i, ty) :: ps =>
        Pos.eqb i Am && proj_sumbool (type_eq ty tyMSp)
        && negb (mem_id Am (map fst ps))
    | nil => false end = true.
  Proof. vm_compute. reflexivity. Qed.
  Example wds_nonparam :
    forallb (fun t' => negb (mem_id t' (map fst (fn_params C.f_act_warp_door_spawn))))
      wds_cact = true.
  Proof. vm_compute. reflexivity. Qed.
  Example wds_walk :
    wwalk_chk false nil wds_ids nil wds_cact nil tfi_sids nil
      (fn_body C.f_act_warp_door_spawn) = true.
  Proof. vm_compute. reflexivity. Qed.
  Lemma wds_pres : body_pres lp NoA MWF bm C.f_act_warp_door_spawn.
  Proof.
    apply (body_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             C.f_act_warp_door_spawn wds_ids nil wds_cact nil tfi_sids nil
             wds_vars wds_pok wds_nonparam).
    - exact wds_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. unfold tfi_sids in H. cbn [mem_id existsb] in H.
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hsmact | discriminate H ].
    - intros fid' H. discriminate H.
    - exact wds_walk.
  Qed.

  Lemma gtd_ids_rows : forall fid, mem_id fid gtd_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold gtd_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_umpfa | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_sashf | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact cut_iae_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_sma | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_ltw | discriminate H ].
  Qed.
  Example gtd_vars : fn_vars C.f_act_going_through_door = nil.
  Proof. vm_compute. reflexivity. Qed.
  Example gtd_pok :
    match fn_params C.f_act_going_through_door with
    | (i, ty) :: ps =>
        Pos.eqb i Am && proj_sumbool (type_eq ty tyMSp)
        && negb (mem_id Am (map fst ps))
    | nil => false end = true.
  Proof. vm_compute. reflexivity. Qed.
  Example gtd_nonparam :
    forallb (fun t' => negb (mem_id t' (map fst (fn_params C.f_act_going_through_door))))
      gtd_cact = true.
  Proof. vm_compute. reflexivity. Qed.
  Example gtd_walk :
    wwalk_chk false nil gtd_ids nil gtd_cact nil tfi_sids nil
      (fn_body C.f_act_going_through_door) = true.
  Proof. vm_compute. reflexivity. Qed.
  Lemma gtd_pres : body_pres lp NoA MWF bm C.f_act_going_through_door.
  Proof.
    apply (body_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             C.f_act_going_through_door gtd_ids nil gtd_cact nil tfi_sids nil
             gtd_vars gtd_pok gtd_nonparam).
    - exact gtd_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. unfold tfi_sids in H. cbn [mem_id existsb] in H.
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hsmact | discriminate H ].
    - intros fid' H. discriminate H.
    - exact gtd_walk.
  Qed.

  (* SLICE 19: act_entering_star_door via the np3 channel. *)
  Lemma esd_smawa_row :
    call_pres_np3 lp bm NoA MWF mario._set_mario_anim_with_accel.
  Proof.
    exact (MovingLeafSurface.mov_smawa_row lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot HMWF_chase
             HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe Hcpx_lpt).
  Qed.
  Lemma esd_ids_rows : forall fid, mem_id fid esd_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold esd_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_sma | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_sashf | discriminate H ].
  Qed.
  Lemma esd_xids_rows : forall fid, mem_id fid esd_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold esd_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_atan2s | discriminate H ].
  Qed.
  Lemma esd_np3_rows : forall fid, mem_id fid esd_np3 = true ->
      call_pres_np3 lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold esd_np3 in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact esd_smawa_row | discriminate H ].
  Qed.
  Example esd_vars : fn_vars C.f_act_entering_star_door = nil.
  Proof. vm_compute. reflexivity. Qed.
  Example esd_pok :
    match fn_params C.f_act_entering_star_door with
    | (i, ty) :: ps =>
        Pos.eqb i Am && proj_sumbool (type_eq ty tyMSp)
        && negb (mem_id Am (map fst ps))
    | nil => false end = true.
  Proof. vm_compute. reflexivity. Qed.
  Example esd_nonparam :
    forallb (fun t' => negb (mem_id t' (map fst (fn_params C.f_act_entering_star_door))))
      esd_cact = true.
  Proof. vm_compute. reflexivity. Qed.
  Example esd_nonparam_np3 :
    forallb (fun t' => negb (mem_id t' (map fst (fn_params C.f_act_entering_star_door))))
      (@nil ident) = true.
  Proof. reflexivity. Qed.
  Example esd_walk :
    wwalk_chk' nil nil nil nil nil esd_np3 false
      nil esd_ids nil esd_cact esd_xids tfi_sids nil
      (fn_body C.f_act_entering_star_door) = true.
  Proof. vm_compute. reflexivity. Qed.
  Lemma esd_pres : body_pres lp NoA MWF bm C.f_act_entering_star_door.
  Proof.
    apply (body_pres_of_wwalk_nids lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             C.f_act_entering_star_door esd_ids nil esd_cact esd_xids tfi_sids
             nil nil esd_np3
             esd_vars esd_pok esd_nonparam esd_nonparam_np3).
    - exact esd_ids_rows.
    - intros fid' H. discriminate H.
    - exact esd_xids_rows.
    - intros fid' H. unfold tfi_sids in H. cbn [mem_id existsb] in H.
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hsmact | discriminate H ].
    - intros fid' H. discriminate H.
    - exact esd_np3_rows.
    - exact esd_walk.
  Qed.

  (* SLICE 20: act_reading_npc_dialog (rnd).  cut_moato_row = the in-section
     twin of ObjectLeafSurface.moato_row (mario_obj_angle_to_object is a pure
     getter; its only callee is atan2s -> Hcpx_atan2s).  ZERO new trust. *)
  Lemma cut_moato_row :
    call_pres lp bm NoA MWF interaction._mario_obj_angle_to_object.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             interaction.prog interaction._mario_obj_angle_to_object
             interaction.f_mario_obj_angle_to_object
             nil nil ObjectLeafSurface.moato_xids nil
             LO_int ObjectLeafSurface.moato_pin ObjectLeafSurface.moato_vars
             ObjectLeafSurface.moato_params_ok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. unfold ObjectLeafSurface.moato_xids in H.
      cbn [mem_id existsb] in H.
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hcpx_atan2s | discriminate H ].
    - intros fid' H. discriminate H.
    - exact ObjectLeafSurface.moato_walk.
  Qed.
  Lemma rnd_ids_rows : forall fid, mem_id fid rnd_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold rnd_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact cut_moato_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_sma | discriminate H ].
  Qed.
  Lemma rnd_xids_rows : forall fid, mem_id fid rnd_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold rnd_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_approach | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_v3fc | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_v3ss | discriminate H ].
  Qed.
  Example rnd_vars : fn_vars C.f_act_reading_npc_dialog = nil.
  Proof. vm_compute. reflexivity. Qed.
  Example rnd_pok :
    match fn_params C.f_act_reading_npc_dialog with
    | (i, ty) :: ps =>
        Pos.eqb i Am && proj_sumbool (type_eq ty tyMSp)
        && negb (mem_id Am (map fst ps))
    | nil => false end = true.
  Proof. vm_compute. reflexivity. Qed.
  Example rnd_nonparam_cact :
    forallb (fun t' => negb (mem_id t' (map fst (fn_params C.f_act_reading_npc_dialog))))
      (@nil ident) = true.
  Proof. reflexivity. Qed.
  Example rnd_nonparam_wact :
    forallb (fun t' => negb (mem_id t' (map fst (fn_params C.f_act_reading_npc_dialog))))
      rnd_wact = true.
  Proof. vm_compute. reflexivity. Qed.
  Example rnd_walk :
    wwalk_chk false rnd_wact rnd_ids nil nil rnd_xids tfi_sids nil
      (fn_body C.f_act_reading_npc_dialog) = true.
  Proof. vm_compute. reflexivity. Qed.
  Lemma rnd_pres : body_pres lp NoA MWF bm C.f_act_reading_npc_dialog.
  Proof.
    apply (body_pres_of_wwalk_wact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             C.f_act_reading_npc_dialog rnd_wact rnd_ids nil nil rnd_xids
             tfi_sids nil
             rnd_vars rnd_pok rnd_nonparam_cact rnd_nonparam_wact).
    - exact rnd_ids_rows.
    - intros fid' H. discriminate H.
    - exact rnd_xids_rows.
    - intros fid' H. unfold tfi_sids in H. cbn [mem_id existsb] in H.
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hsmact | discriminate H ].
    - intros fid' H. discriminate H.
    - exact rnd_walk.
  Qed.

  (* SLICE 21: act_unlocking_star_door (usd).  cut_gdsff_row = the in-section
     twin of InterSurface.gdsff_row (call_pres_ext_of_wwalk: marg-free, its only
     callee is the save_file_get_flags boundary -> Hcpx_sfgf).  ZERO new trust. *)
  Lemma cut_gdsff_row :
    call_pres_ext lp bm NoA MWF interaction._get_door_save_file_flag.
  Proof.
    apply (call_pres_ext_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             interaction.prog interaction._get_door_save_file_flag
             interaction.f_get_door_save_file_flag
             nil nil cut_gdsff_xids nil
             LO_int cut_gdsff_pin cut_gdsff_vars cut_gdsff_no_m).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. unfold cut_gdsff_xids in H. cbn [mem_id existsb] in H.
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hcpx_sfgf | discriminate H ].
    - intros fid' H. discriminate H.
    - exact cut_gdsff_walk.
  Qed.
  Lemma usd_ids_rows : forall fid, mem_id fid usd_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold usd_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_sma | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_umpfa | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_sashf | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact cut_iae_row | discriminate H ].
  Qed.
  Lemma usd_xids_rows : forall fid, mem_id fid usd_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold usd_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_spawn | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_sfsf | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact cut_gdsff_row | discriminate H ].
  Qed.
  Example usd_vars : fn_vars C.f_act_unlocking_star_door = nil.
  Proof. vm_compute. reflexivity. Qed.
  Example usd_pok :
    match fn_params C.f_act_unlocking_star_door with
    | (i, ty) :: ps =>
        Pos.eqb i Am && proj_sumbool (type_eq ty tyMSp)
        && negb (mem_id Am (map fst ps))
    | nil => false end = true.
  Proof. vm_compute. reflexivity. Qed.
  Example usd_nonparam :
    forallb (fun t' => negb (mem_id t' (map fst (fn_params C.f_act_unlocking_star_door))))
      usd_cact = true.
  Proof. vm_compute. reflexivity. Qed.
  Example usd_walk :
    wwalk_chk false nil usd_ids nil usd_cact usd_xids tfi_sids nil
      (fn_body C.f_act_unlocking_star_door) = true.
  Proof. vm_compute. reflexivity. Qed.
  Lemma usd_pres : body_pres lp NoA MWF bm C.f_act_unlocking_star_door.
  Proof.
    apply (body_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             C.f_act_unlocking_star_door usd_ids nil usd_cact usd_xids tfi_sids nil
             usd_vars usd_pok usd_nonparam).
    - exact usd_ids_rows.
    - intros fid' H. discriminate H.
    - exact usd_xids_rows.
    - intros fid' H. unfold tfi_sids in H. cbn [mem_id existsb] in H.
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hsmact | discriminate H ].
    - intros fid' H. discriminate H.
    - exact usd_walk.
  Qed.

  (* SLICE 22: check_for_instant_quicksand.  body_pres_of_wwalk; read-only body
     (cact=nil), ids = update_mario_sound_and_camera, sids = drop_and_set_mario_
     action (const ACT_QUICKSAND_DEATH = 135954, untainted). *)
  Lemma cfiq_ids_rows : forall fid, mem_id fid cfiq_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold cfiq_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_umsc | discriminate H ].
  Qed.
  Example cfiq_vars : fn_vars C.f_check_for_instant_quicksand = nil.
  Proof. vm_compute. reflexivity. Qed.
  Example cfiq_pok :
    match fn_params C.f_check_for_instant_quicksand with
    | (i, ty) :: ps =>
        Pos.eqb i Am && proj_sumbool (type_eq ty tyMSp)
        && negb (mem_id Am (map fst ps))
    | nil => false end = true.
  Proof. vm_compute. reflexivity. Qed.
  Example cfiq_walk :
    wwalk_chk false nil cfiq_ids nil nil nil cfiq_sids nil
      (fn_body C.f_check_for_instant_quicksand) = true.
  Proof. vm_compute. reflexivity. Qed.
  Lemma cfiq_pres : body_pres lp NoA MWF bm C.f_check_for_instant_quicksand.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             C.f_check_for_instant_quicksand cfiq_ids nil nil cfiq_sids nil
             cfiq_vars cfiq_pok).
    - exact cfiq_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. unfold cfiq_sids in H. cbn [mem_id existsb] in H.
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hdasma | discriminate H ].
    - intros fid' H. discriminate H.
    - exact cfiq_walk.
  Qed.

  (* SLICE 23: act_unlocking_key_door.  body_pres_of_wwalk; the door/key Object*
     temps are LOADED only (chase reads), so every store is a direct window write
     into m->faceAngle/pos/actionTimer (cact=nil).  ids = spawn_obj_at_mario_rel_
     yaw + set_mario_animation + update_mario_pos_for_anim + stop_and_set_height_
     to_floor + is_anim_at_end.  xids = play_sound + save_file_set_flags +
     save_file_clear_flags.  sids = set_mario_action(m, 67109952, 0) (untainted). *)
  Lemma ukd_ids_rows : forall fid, mem_id fid ukd_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold ukd_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_spawn_obj | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_sma | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_umpfa | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_sashf | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact cut_iae_row | discriminate H ].
  Qed.
  Lemma ukd_xids_rows : forall fid, mem_id fid ukd_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold ukd_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_psound | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_sfsf | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_sfcf | discriminate H ].
  Qed.
  Example ukd_vars : fn_vars C.f_act_unlocking_key_door = nil.
  Proof. vm_compute. reflexivity. Qed.
  Example ukd_pok :
    match fn_params C.f_act_unlocking_key_door with
    | (i, ty) :: ps =>
        Pos.eqb i Am && proj_sumbool (type_eq ty tyMSp)
        && negb (mem_id Am (map fst ps))
    | nil => false end = true.
  Proof. vm_compute. reflexivity. Qed.
  Example ukd_walk :
    wwalk_chk false nil ukd_ids nil nil ukd_xids tfi_sids nil
      (fn_body C.f_act_unlocking_key_door) = true.
  Proof. vm_compute. reflexivity. Qed.
  Lemma ukd_pres : body_pres lp NoA MWF bm C.f_act_unlocking_key_door.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             C.f_act_unlocking_key_door ukd_ids nil ukd_xids tfi_sids nil
             ukd_vars ukd_pok).
    - exact ukd_ids_rows.
    - intros fid' H. discriminate H.
    - exact ukd_xids_rows.
    - intros fid' H. unfold tfi_sids in H. cbn [mem_id existsb] in H.
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hsmact | discriminate H ].
    - intros fid' H. discriminate H.
    - exact ukd_walk.
  Qed.

  (* SLICE 12a: act_reading_sign.  body_pres_of_wwalk (wact=nil, cact=nil --
     marioObj/usedObj are LOADED only; stores are direct non-action m-fields).
     ids = psinf + sma; xids = the 4 dialog/time-stop externals (Hcut_ext)
     + vec3f_copy / vec3s_set (obj_ext); sids = set_mario_action (const). *)
  Lemma rs_ids_rows : forall fid, mem_id fid rs_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold rs_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_psinf | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_sma | discriminate H ].
  Qed.
  Lemma rs_xids_rows : forall fid, mem_id fid rs_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold rs_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; apply Hcut_ext; reflexivity | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; apply Hcut_ext; reflexivity | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; apply Hcut_ext; reflexivity | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; apply Hcut_ext; reflexivity | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_v3fc | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_v3ss | discriminate H ].
  Qed.
  Example rs_vars : fn_vars C.f_act_reading_sign = nil.
  Proof. vm_compute. reflexivity. Qed.
  Example rs_pok :
    match fn_params C.f_act_reading_sign with
    | (i, ty) :: ps =>
        Pos.eqb i Am && proj_sumbool (type_eq ty tyMSp)
        && negb (mem_id Am (map fst ps))
    | nil => false end = true.
  Proof. vm_compute. reflexivity. Qed.
  Example rs_walk :
    wwalk_chk false nil rs_ids nil nil rs_xids tfi_sids nil
      (fn_body C.f_act_reading_sign) = true.
  Proof. vm_compute. reflexivity. Qed.
  Lemma rs_pres : body_pres lp NoA MWF bm C.f_act_reading_sign.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             C.f_act_reading_sign rs_ids nil rs_xids tfi_sids nil
             rs_vars rs_pok).
    - exact rs_ids_rows.
    - intros fid' H. discriminate H.
    - exact rs_xids_rows.
    - intros fid' H. unfold tfi_sids in H. cbn [mem_id existsb] in H.
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hsmact | discriminate H ].
    - intros fid' H. discriminate H.
    - exact rs_walk.
  Qed.

  (* SLICE 12b: act_bbh_enter_spin.  body_pres_of_wwalk_cact.  cact =
     [_t'18;_t'10] = the marioObj chase temps stored THROUGH; ids = msfv / sma
     / pas / ltw / psinf / sashf; xids = sqrtf / atan2s / play_sound / vec3f_set
     (all obj_ext); sids = nil. *)
  Lemma bbhs_ids_rows : forall fid, mem_id fid bbhs_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold bbhs_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hmsfv | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_sma | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_pas | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_ltw | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_psinf | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_sashf | discriminate H ].
  Qed.
  Lemma bbhs_xids_rows : forall fid, mem_id fid bbhs_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold bbhs_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_sqrtf | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_atan2s | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_psound | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_v3fset | discriminate H ].
  Qed.
  Example bbhs_vars : fn_vars C.f_act_bbh_enter_spin = nil.
  Proof. vm_compute. reflexivity. Qed.
  Example bbhs_pok :
    match fn_params C.f_act_bbh_enter_spin with
    | (i, ty) :: ps =>
        Pos.eqb i Am && proj_sumbool (type_eq ty tyMSp)
        && negb (mem_id Am (map fst ps))
    | nil => false end = true.
  Proof. vm_compute. reflexivity. Qed.
  Example bbhs_nonparam :
    forallb (fun t' => negb (mem_id t' (map fst (fn_params C.f_act_bbh_enter_spin))))
      bbhs_cact = true.
  Proof. vm_compute. reflexivity. Qed.
  Example bbhs_walk :
    wwalk_chk false nil bbhs_ids nil bbhs_cact bbhs_xids nil nil
      (fn_body C.f_act_bbh_enter_spin) = true.
  Proof. vm_compute. reflexivity. Qed.
  Lemma bbhs_pres : body_pres lp NoA MWF bm C.f_act_bbh_enter_spin.
  Proof.
    apply (body_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             C.f_act_bbh_enter_spin bbhs_ids nil bbhs_cact bbhs_xids nil nil
             bbhs_vars bbhs_pok bbhs_nonparam).
    - exact bbhs_ids_rows.
    - intros fid' H. discriminate H.
    - exact bbhs_xids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact bbhs_walk.
  Qed.

  (* SLICE 12c: act_reading_automatic_dialog.  body_pres_of_wwalk_wact.  wact =
     [_t'3] (untainted action-const temp); cact = nil (marioBodyState LOADED only);
     ids = sma; xids = 6 dialog/time-stop externals (Hcut_ext) + vec3s_set (obj_ext);
     sids = set_mario_action; gNeverEnteredCastle store via stored_globals. *)
  Lemma rad_ids_rows : forall fid, mem_id fid rad_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold rad_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_sma | discriminate H ].
  Qed.
  Lemma rad_xids_rows : forall fid, mem_id fid rad_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold rad_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; apply Hcut_ext; reflexivity | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; apply Hcut_ext; reflexivity | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; apply Hcut_ext; reflexivity | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; apply Hcut_ext; reflexivity | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; apply Hcut_ext; reflexivity | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; apply Hcut_ext; reflexivity | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_v3ss | discriminate H ].
  Qed.
  Example rad_vars : fn_vars C.f_act_reading_automatic_dialog = nil.
  Proof. vm_compute. reflexivity. Qed.
  Example rad_pok :
    match fn_params C.f_act_reading_automatic_dialog with
    | (i, ty) :: ps =>
        Pos.eqb i Am && proj_sumbool (type_eq ty tyMSp)
        && negb (mem_id Am (map fst ps))
    | nil => false end = true.
  Proof. vm_compute. reflexivity. Qed.
  Example rad_nonparam_cact :
    forallb (fun t' => negb (mem_id t' (map fst (fn_params C.f_act_reading_automatic_dialog))))
      nil = true.
  Proof. vm_compute. reflexivity. Qed.
  Example rad_nonparam_wact :
    forallb (fun t' => negb (mem_id t' (map fst (fn_params C.f_act_reading_automatic_dialog))))
      rad_wact = true.
  Proof. vm_compute. reflexivity. Qed.
  Example rad_walk :
    wwalk_chk false rad_wact rad_ids nil nil rad_xids tfi_sids nil
      (fn_body C.f_act_reading_automatic_dialog) = true.
  Proof. vm_compute. reflexivity. Qed.
  Lemma rad_pres : body_pres lp NoA MWF bm C.f_act_reading_automatic_dialog.
  Proof.
    apply (body_pres_of_wwalk_wact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             C.f_act_reading_automatic_dialog rad_wact rad_ids nil nil rad_xids
             tfi_sids nil rad_vars rad_pok rad_nonparam_cact rad_nonparam_wact).
    - exact rad_ids_rows.
    - intros fid' H. discriminate H.
    - exact rad_xids_rows.
    - intros fid' H. unfold tfi_sids in H. cbn [mem_id existsb] in H.
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hsmact | discriminate H ].
    - intros fid' H. discriminate H.
    - exact rad_walk.
  Qed.

  (* SLICE 12d: act_bbh_enter_jump.  body_pres_of_wwalk.  The two mario sound
     helpers are REUSED from ObjectLeafSurface (both bottom out in play_sound =
     Hcpx_psound, ZERO new trust): pmas_row / pmjs_row. *)
  Let Hpmas : call_pres lp bm NoA MWF mario._play_mario_action_sound :=
    ObjectLeafSurface.pmas_row lp LO_mario bm NoA MWF HNoA_of_MWF HMWF_window
      HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot HMWF_chase HMWF_root
      HMWF_sglob HchaseStep HMWF_chase_safe Hcpx_psound.
  Let Hpmjs : call_pres lp bm NoA MWF mario._play_mario_jump_sound :=
    ObjectLeafSurface.pmjs_row lp LO_mario bm NoA MWF HNoA_of_MWF HMWF_window
      HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot HMWF_chase HMWF_root
      HMWF_sglob HchaseStep HMWF_chase_safe Hcpx_psound.
  Lemma bbhj_ids_rows : forall fid, mem_id fid bbhj_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold bbhj_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hmsfv | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_sma | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_pas | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hpmas | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hpmjs | discriminate H ].
  Qed.
  Lemma bbhj_xids_rows : forall fid, mem_id fid bbhj_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold bbhj_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_sqrtf | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_atan2s | discriminate H ].
  Qed.
  Example bbhj_vars : fn_vars C.f_act_bbh_enter_jump = nil.
  Proof. vm_compute. reflexivity. Qed.
  Example bbhj_pok :
    match fn_params C.f_act_bbh_enter_jump with
    | (i, ty) :: ps =>
        Pos.eqb i Am && proj_sumbool (type_eq ty tyMSp)
        && negb (mem_id Am (map fst ps))
    | nil => false end = true.
  Proof. vm_compute. reflexivity. Qed.
  Example bbhj_walk :
    wwalk_chk false nil bbhj_ids nil nil bbhj_xids tfi_sids nil
      (fn_body C.f_act_bbh_enter_jump) = true.
  Proof. vm_compute. reflexivity. Qed.
  Lemma bbhj_pres : body_pres lp NoA MWF bm C.f_act_bbh_enter_jump.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             C.f_act_bbh_enter_jump bbhj_ids nil bbhj_xids tfi_sids nil
             bbhj_vars bbhj_pok).
    - exact bbhj_ids_rows.
    - intros fid' H. discriminate H.
    - exact bbhj_xids_rows.
    - intros fid' H. unfold tfi_sids in H. cbn [mem_id existsb] in H.
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hsmact | discriminate H ].
    - intros fid' H. discriminate H.
    - exact bbhj_walk.
  Qed.

  (* SLICE 13: the star-dance cluster.  get_star_collection_dialog (all-nil
     near-leaf) -> general_star_dance_handler (wact action-const, 10 externals)
     -> act_star_dance / act_star_dance_water (body_pres_of_wwalk_cact). *)
  Example gscd_vars : fn_vars C.f_get_star_collection_dialog = nil.
  Proof. vm_compute. reflexivity. Qed.
  Example gscd_pok :
    match fn_params C.f_get_star_collection_dialog with
    | (i, ty) :: ps =>
        Pos.eqb i Am && proj_sumbool (type_eq ty tyMSp)
        && negb (mem_id Am (map fst ps))
    | nil => false end = true.
  Proof. vm_compute. reflexivity. Qed.
  Example gscd_walk :
    wwalk_chk false nil nil nil nil nil nil nil
      (fn_body C.f_get_star_collection_dialog) = true.
  Proof. vm_compute. reflexivity. Qed.
  Lemma gscd_row : call_pres lp bm NoA MWF C._get_star_collection_dialog.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_cutscene.prog C._get_star_collection_dialog
             C.f_get_star_collection_dialog nil nil nil nil
             LO_cut gscd_pin gscd_vars gscd_pok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact gscd_walk.
  Qed.

  Lemma gsdh_ids_rows : forall fid, mem_id fid gsdh_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold gsdh_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact cut_iae_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_ltw | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact gscd_row | discriminate H ].
  Qed.
  Lemma gsdh_xids_rows : forall fid, mem_id fid gsdh_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold gsdh_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; apply Hcut_ext; reflexivity | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_psound | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; apply Hcut_ext; reflexivity | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; apply Hcut_ext; reflexivity | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; apply Hcut_ext; reflexivity | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; apply Hcut_ext; reflexivity | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; apply Hcut_ext; reflexivity | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; apply Hcut_ext; reflexivity | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; apply Hcut_ext; reflexivity | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; apply Hcut_ext; reflexivity
      | discriminate H ].
  Qed.
  Example gsdh_vars : fn_vars C.f_general_star_dance_handler = nil.
  Proof. vm_compute. reflexivity. Qed.
  Example gsdh_pok :
    match fn_params C.f_general_star_dance_handler with
    | (i, ty) :: ps =>
        Pos.eqb i Am && proj_sumbool (type_eq ty tyMSp)
        && negb (mem_id Am (map fst ps))
    | nil => false end = true.
  Proof. vm_compute. reflexivity. Qed.
  Example gsdh_nonparam_cact :
    forallb (fun t' => negb (mem_id t' (map fst (fn_params C.f_general_star_dance_handler))))
      nil = true.
  Proof. vm_compute. reflexivity. Qed.
  Example gsdh_nonparam_wact :
    forallb (fun t' => negb (mem_id t' (map fst (fn_params C.f_general_star_dance_handler))))
      gsdh_wact = true.
  Proof. vm_compute. reflexivity. Qed.
  Example gsdh_walk :
    wwalk_chk false gsdh_wact gsdh_ids nil nil gsdh_xids tfi_sids nil
      (fn_body C.f_general_star_dance_handler) = true.
  Proof. vm_compute. reflexivity. Qed.
  Lemma gsdh_row :
    call_pres lp bm NoA MWF C._general_star_dance_handler.
  Proof.
    apply (call_pres_of_wwalk_wact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_cutscene.prog C._general_star_dance_handler
             C.f_general_star_dance_handler
             gsdh_wact gsdh_ids nil nil gsdh_xids tfi_sids
             LO_cut gsdh_pin gsdh_vars gsdh_pok gsdh_nonparam_cact
             gsdh_nonparam_wact).
    - exact gsdh_ids_rows.
    - intros fid' H. discriminate H.
    - exact gsdh_xids_rows.
    - intros fid' H. unfold tfi_sids in H. cbn [mem_id existsb] in H.
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hsmact | discriminate H ].
    - exact gsdh_walk.
  Qed.

  Lemma sdn_ids_rows : forall fid, mem_id fid sdn_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sdn_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact gsdh_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_sma | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_sashf | discriminate H ].
  Qed.
  Example sdn_vars : fn_vars C.f_act_star_dance = nil.
  Proof. vm_compute. reflexivity. Qed.
  Example sdn_pok :
    match fn_params C.f_act_star_dance with
    | (i, ty) :: ps =>
        Pos.eqb i Am && proj_sumbool (type_eq ty tyMSp)
        && negb (mem_id Am (map fst ps))
    | nil => false end = true.
  Proof. vm_compute. reflexivity. Qed.
  Example sdn_nonparam :
    forallb (fun t' => negb (mem_id t' (map fst (fn_params C.f_act_star_dance))))
      sdn_cact = true.
  Proof. vm_compute. reflexivity. Qed.
  Example sdn_walk :
    wwalk_chk false nil sdn_ids nil sdn_cact nil nil nil
      (fn_body C.f_act_star_dance) = true.
  Proof. vm_compute. reflexivity. Qed.
  Lemma sdn_pres : body_pres lp NoA MWF bm C.f_act_star_dance.
  Proof.
    apply (body_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             C.f_act_star_dance sdn_ids nil sdn_cact nil nil nil
             sdn_vars sdn_pok sdn_nonparam).
    - exact sdn_ids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sdn_walk.
  Qed.

  Lemma sdw_ids_rows : forall fid, mem_id fid sdw_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sdw_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact gsdh_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_sma | discriminate H ].
  Qed.
  Lemma sdw_xids_rows : forall fid, mem_id fid sdw_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sdw_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_v3fc | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_v3ss | discriminate H ].
  Qed.
  Example sdw_vars : fn_vars C.f_act_star_dance_water = nil.
  Proof. vm_compute. reflexivity. Qed.
  Example sdw_pok :
    match fn_params C.f_act_star_dance_water with
    | (i, ty) :: ps =>
        Pos.eqb i Am && proj_sumbool (type_eq ty tyMSp)
        && negb (mem_id Am (map fst ps))
    | nil => false end = true.
  Proof. vm_compute. reflexivity. Qed.
  Example sdw_nonparam :
    forallb (fun t' => negb (mem_id t' (map fst (fn_params C.f_act_star_dance_water))))
      sdw_cact = true.
  Proof. vm_compute. reflexivity. Qed.
  Example sdw_walk :
    wwalk_chk false nil sdw_ids nil sdw_cact sdw_xids nil nil
      (fn_body C.f_act_star_dance_water) = true.
  Proof. vm_compute. reflexivity. Qed.
  Lemma sdw_pres : body_pres lp NoA MWF bm C.f_act_star_dance_water.
  Proof.
    apply (body_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             C.f_act_star_dance_water sdw_ids nil sdw_cact sdw_xids nil nil
             sdw_vars sdw_pok sdw_nonparam).
    - exact sdw_ids_rows.
    - intros fid' H. discriminate H.
    - exact sdw_xids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact sdw_walk.
  Qed.

  (* SLICE 24: act_credits_cutscene -- the FIRST deep-global-store leaf.  The
     body writes the cutscene viewport union sEndCutsceneVp.vp.vscale[i]/.vtrans[i]
     (recognized by glob_store_chk's new deep Ederef arm) plus a simple global
     sDispCreditsEntry, two safe chase stores (cameraEvent / gfx.angle[1]) via
     cred_cact, marg internal calls and pure externals.  No new engine arm. *)
  Lemma cred_ids_rows : forall fid, mem_id fid cred_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold cred_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_sma | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_sashf | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_ltw | discriminate H ].
  Qed.
  Lemma cred_xids_rows : forall fid, mem_id fid cred_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold cred_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_scm | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_v3fc | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_v3sc | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_ovac | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_rcmf | discriminate H ].
  Qed.
  Example cred_vars : fn_vars C.f_act_credits_cutscene = nil.
  Proof. vm_compute. reflexivity. Qed.
  Example cred_pok :
    match fn_params C.f_act_credits_cutscene with
    | (i, ty) :: ps =>
        Pos.eqb i Am && proj_sumbool (type_eq ty tyMSp)
        && negb (mem_id Am (map fst ps))
    | nil => false end = true.
  Proof. vm_compute. reflexivity. Qed.
  Example cred_nonparam :
    forallb (fun t' => negb (mem_id t' (map fst (fn_params C.f_act_credits_cutscene))))
      cred_cact = true.
  Proof. vm_compute. reflexivity. Qed.
  Example cred_walk :
    wwalk_chk false nil cred_ids nil cred_cact cred_xids nil nil
      (fn_body C.f_act_credits_cutscene) = true.
  Proof. vm_compute. reflexivity. Qed.
  Lemma cred_pres : body_pres lp NoA MWF bm C.f_act_credits_cutscene.
  Proof.
    apply (body_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             C.f_act_credits_cutscene cred_ids nil cred_cact cred_xids nil nil
             cred_vars cred_pok cred_nonparam).
    - exact cred_ids_rows.
    - intros fid' H. discriminate H.
    - exact cred_xids_rows.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact cred_walk.
  Qed.

  (* SLICE 14: act_squished -- the FIRST body_pres_of_lwalk leaf (dead
     filler[4] stack local, lids=nil).  perform_ground_step via the new
     Hcp_pgs section hyp. *)
  Lemma sq_ids_rows : forall fid, mem_id fid sq_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sq_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_pgs | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_sma | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_psinf | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_sashf | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_ltw | discriminate H ].
  Qed.
  Lemma sq_xids_rows : forall fid, mem_id fid sq_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sq_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_atan2s | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_v3fset | discriminate H ].
  Qed.
  Example sq_pok :
    match fn_params C.f_act_squished with
    | (i, ty) :: ps =>
        Pos.eqb i Am && proj_sumbool (type_eq ty tyMSp)
        && negb (mem_id Am (map fst ps))
    | nil => false end = true.
  Proof. vm_compute. reflexivity. Qed.
  Example sq_walk :
    wwalk_chk false nil sq_ids nil nil sq_xids tfi_sids nil
      (fn_body C.f_act_squished) = true.
  Proof. vm_compute. reflexivity. Qed.
  Lemma sq_pres : body_pres lp NoA MWF bm C.f_act_squished.
  Proof.
    apply (body_pres_of_lwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             HMWF_alloc HMWF_free
             C.f_act_squished sq_ids nil sq_xids tfi_sids sq_pok).
    - intros g Hg HIn. vm_compute in HIn.
      destruct HIn as [E | []]. subst g. vm_compute in Hg. discriminate Hg.
    - intros g Hg HIn. vm_compute in HIn.
      destruct HIn as [E | []]. subst g. vm_compute in Hg. discriminate Hg.
    - intros g Hg. discriminate Hg.
    - intros g Hg HIn. vm_compute in HIn.
      destruct HIn as [E | []]. subst g. vm_compute in Hg. discriminate Hg.
    - intros g Hg HIn. vm_compute in HIn.
      destruct HIn as [E | []]. subst g. vm_compute in Hg. discriminate Hg.
    - intro HIn. vm_compute in HIn. destruct HIn as [E | []]. discriminate E.
    - exact sq_ids_rows.
    - intros fid' H. discriminate H.
    - exact sq_xids_rows.
    - intros fid' H. unfold tfi_sids in H. cbn [mem_id existsb] in H.
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hsmact | discriminate H ].
    - exact sq_walk.
  Qed.

  (* SLICE 15: act_quicksand_death.  The sgs sub-tree, walked in-file (no new
     trust -- every callee resolves to an existing section term now that Hcp_pgs
     is present).  mums / muwg / set_anim_to_frame = pure all-nil near-leaves. *)
  Example cut_mums_walk :
    wwalk_chk false nil nil nil nil nil nil nil
      (fn_body mario_step.f_mario_update_moving_sand) = true.
  Proof. vm_compute. reflexivity. Qed.
  Lemma cut_mums_row :
    call_pres lp bm NoA MWF mario_step._mario_update_moving_sand.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_step.prog mario_step._mario_update_moving_sand
             mario_step.f_mario_update_moving_sand nil nil nil nil
             LO_stp mums_pin mums_vars mums_pok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact cut_mums_walk.
  Qed.
  Example cut_muwg_walk :
    wwalk_chk false nil nil nil nil nil nil nil
      (fn_body mario_step.f_mario_update_windy_ground) = true.
  Proof. vm_compute. reflexivity. Qed.
  Lemma cut_muwg_row :
    call_pres lp bm NoA MWF mario_step._mario_update_windy_ground.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_step.prog mario_step._mario_update_windy_ground
             mario_step.f_mario_update_windy_ground nil nil nil nil
             LO_stp muwg_pin muwg_vars muwg_pok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact cut_muwg_walk.
  Qed.
  (* set_anim_to_frame is CALL-FREE but has a marioObj->animInfo chase store
     that the standard wwalk_chk engine does not accept; SubmergedLeafSurface
     discharged it via a bespoke walk (sub_satf_body).  Reuse it cross-section
     exactly like Hcp_sashf above. *)
  Lemma cut_satf_row : call_pres lp bm NoA MWF mario._set_anim_to_frame.
  Proof. eapply SubmergedLeafSurface.sub_satf_row; eassumption. Qed.
  Lemma cut_sgs_ids_rows : forall fid, mem_id fid sgs_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sgs_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hmsfv | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact cut_mums_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact cut_muwg_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_pgs | discriminate H ].
  Qed.
  Lemma cut_sgs_xids_rows : forall fid, mem_id fid sgs_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sgs_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_v3fc | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_v3ss | discriminate H ].
  Qed.
  Example cut_sgs_walk :
    wwalk_chk false nil sgs_ids nil nil sgs_xids nil nil
      (fn_body mario_step.f_stationary_ground_step) = true.
  Proof. vm_compute. reflexivity. Qed.
  Lemma cut_sgs_row :
    call_pres lp bm NoA MWF mario_step._stationary_ground_step.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_step.prog mario_step._stationary_ground_step
             mario_step.f_stationary_ground_step sgs_ids nil sgs_xids nil
             LO_stp sgs_pin sgs_vars sgs_pok).
    - exact cut_sgs_ids_rows.
    - intros fid' H. discriminate H.
    - exact cut_sgs_xids_rows.
    - intros fid' H. discriminate H.
    - exact cut_sgs_walk.
  Qed.
  Lemma qsd_ids_rows : forall fid, mem_id fid qsd_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold qsd_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_ltw | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_psinf | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact cut_satf_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_sma | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact cut_sgs_row | discriminate H ].
  Qed.
  Lemma qsd_xids_rows : forall fid, mem_id fid qsd_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold qsd_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_psound | discriminate H ].
  Qed.
  Example qsd_vars : fn_vars C.f_act_quicksand_death = nil.
  Proof. vm_compute. reflexivity. Qed.
  Example qsd_pok :
    match fn_params C.f_act_quicksand_death with
    | (i, ty) :: ps =>
        Pos.eqb i Am && proj_sumbool (type_eq ty tyMSp)
        && negb (mem_id Am (map fst ps))
    | nil => false end = true.
  Proof. vm_compute. reflexivity. Qed.
  Example qsd_walk :
    wwalk_chk false nil qsd_ids nil nil qsd_xids tfi_sids nil
      (fn_body C.f_act_quicksand_death) = true.
  Proof. vm_compute. reflexivity. Qed.
  Lemma qsd_pres : body_pres lp NoA MWF bm C.f_act_quicksand_death.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             C.f_act_quicksand_death qsd_ids nil qsd_xids tfi_sids nil
             qsd_vars qsd_pok).
    - exact qsd_ids_rows.
    - intros fid' H. discriminate H.
    - exact qsd_xids_rows.
    - intros fid' H. unfold tfi_sids in H. cbn [mem_id existsb] in H.
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hsmact | discriminate H ].
    - intros fid' H. discriminate H.
    - exact qsd_walk.
  Qed.

  (* ---- SLICE 16: act_putting_on_cap ---- *)
  (* cutscene_put_cap_on: 2 m->flags window stores + play_sound, marioObj
     read-only.  Plain call_pres via call_pres_of_wwalk (xids=[play_sound]). *)
  Lemma cpco_xids_rows : forall fid, mem_id fid cpco_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold cpco_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_psound | discriminate H ].
  Qed.
  Lemma cpco_row : call_pres lp bm NoA MWF C._cutscene_put_cap_on.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_cutscene.prog C._cutscene_put_cap_on
             C.f_cutscene_put_cap_on nil nil cpco_xids nil
             LO_cut cpco_pin cpco_vars cpco_pok).
    - intros fid' H. discriminate H.
    - intros fid' H. discriminate H.
    - exact cpco_xids_rows.
    - intros fid' H. discriminate H.
    - exact cpco_walk.
  Qed.
  Lemma poc_ids_rows : forall fid, mem_id fid poc_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold poc_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_sma | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact cpco_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact cut_iae_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact cut_sgs_row | discriminate H ].
  Qed.
  Lemma poc_xids_rows : forall fid, mem_id fid poc_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold poc_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; apply Hcut_ext; reflexivity | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; apply Hcut_ext; reflexivity
      | discriminate H ].
  Qed.
  Lemma poc_pres : body_pres lp NoA MWF bm C.f_act_putting_on_cap.
  Proof.
    apply (body_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             C.f_act_putting_on_cap poc_ids nil poc_xids tfi_sids nil
             poc_vars poc_pok).
    - exact poc_ids_rows.
    - intros fid' H. discriminate H.
    - exact poc_xids_rows.
    - intros fid' H. unfold tfi_sids in H. cbn [mem_id existsb] in H.
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hsmact | discriminate H ].
    - intros fid' H. discriminate H.
    - exact poc_walk.
  Qed.

  (* ==================================================================== *)
  (* SLICE 18: the stuck-in-ground cluster (head/butt/feet).  Each leaf is *)
  (* a tiny wrapper `stuck_in_ground_handler(m, anim, c1,c2,c3, ACT_const)`*)
  (* + return FALSE.  stuck_in_ground_handler is a VOID-return action      *)
  (* writer whose endAction is at PARAM INDEX 5 -- no call_pres_act_of_    *)
  (* wwalk producer fits (all fix the action at index 1), so we prove a    *)
  (* bespoke index-5 gate Hsig (model: call_pres_act_of_wwalk4g).  Body    *)
  (* walk PROBED green; ZERO new externals (all 6 callees already          *)
  (* call_pres-available: sma/satf/sashf/iae/psasp/pmls).                  *)
  (* ==================================================================== *)
  Definition sig_ids : list ident :=
    mario._set_mario_animation :: mario._set_anim_to_frame
      :: mario_step._stop_and_set_height_to_floor :: mario._is_anim_at_end
      :: mario._play_sound_and_spawn_particles
      :: mario._play_mario_landing_sound :: nil.
  Example sig_pin :
    (prog_defmap C.prog) ! C._stuck_in_ground_handler
    = Some (Gfun (Internal C.f_stuck_in_ground_handler)).
  Proof. vm_compute. reflexivity. Qed.
  Example sig_vars : fn_vars C.f_stuck_in_ground_handler = nil.
  Proof. vm_compute. reflexivity. Qed.
  Example sig_params :
    fn_params C.f_stuck_in_ground_handler
    = (Am, tyMSp) :: (C._animation, tint) :: (C._unstuckFrame, tint)
        :: (C._target2, tint) :: (C._target3, tint) :: (C._endAction, tint) :: nil.
  Proof. vm_compute. reflexivity. Qed.
  Example sig_walk :
    wwalk_chk false (C._endAction :: nil) sig_ids nil nil nil
      (mario._set_mario_action :: nil) nil
      (fn_body C.f_stuck_in_ground_handler) = true.
  Proof. vm_compute. reflexivity. Qed.
  Lemma sig_ids_rows : forall fid, mem_id fid sig_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sig_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_sma | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact cut_satf_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_sashf | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact cut_iae_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_psasp | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact pmls_row | discriminate H ].
  Qed.

  (* the bespoke INDEX-5 action-gate contract for stuck_in_ground_handler:
     Mario ptr first, four scalars, the UNTAINTED action SIXTH; void return
     (no return-value claim).  Proof = call_pres_act_of_wwalk4g adapted to
     6 params + rt=false. *)
  Lemma Hsig :
    forall fd m0 v0 v1 v2 v3 v4 aval rest t0 m1 vres0,
      eval_funcall function_entry2 (lp_ge lp) m0 fd
        (v0 :: v1 :: v2 :: v3 :: v4 :: aval :: rest) t0 m1 vres0 ->
      resolves_lp lp C._stuck_in_ground_handler fd ->
      marg_ok bm (v0 :: v1 :: v2 :: v3 :: v4 :: aval :: rest) ->
      untainted_scalar aval ->
      NoA m0 -> MWF m0 -> Mem.valid_block m0 bm ->
      action_sat not_tainted m0 bm ->
      Mem.valid_block m1 bm /\ action_sat not_tainted m1 bm /\
      MWF m1 /\ NoA m1.
  Proof.
    intros fd m0 v0 v1 v2 v3 v4 aval rest t0 m1 vres0
           Hevf Hres Hmarg Hu HN HM HV HS.
    pose proof (OutParamSurface.resolve_pin_fd lp _ _ _ _ LO_cut sig_pin Hres) as ->.
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ =>
      rename He into Hentry end.
    match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
      rename Hx into Hbody end.
    match goal with Hf : Mem.free_list _ _ = Some _ |- _ =>
      rename Hf into Hfree end.
    inv Hentry.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
      rewrite sig_vars in Ha; inv Ha end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ =>
      rename Hb into Hbind end.
    rewrite sig_params in Hbind. cbn [bind_parameter_temps] in Hbind.
    destruct rest as [| vr restr]; cbn [bind_parameter_temps] in Hbind;
      [ injection Hbind as <- | discriminate Hbind ].
    set (base := create_undef_temps (fn_temps C.f_stuck_in_ground_handler)) in *.
    assert (Htat0 : forall b o,
               (PTree.set C._endAction aval
                  (PTree.set C._target3 v4
                     (PTree.set C._target2 v3
                        (PTree.set C._unstuckFrame v2
                           (PTree.set C._animation v1
                              (PTree.set Am v0 base)))))) ! Am
                 = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
    { intros b o Hg.
      rewrite PTree.gso in Hg by (intro E; vm_compute in E; discriminate E).
      rewrite PTree.gso in Hg by (intro E; vm_compute in E; discriminate E).
      rewrite PTree.gso in Hg by (intro E; vm_compute in E; discriminate E).
      rewrite PTree.gso in Hg by (intro E; vm_compute in E; discriminate E).
      rewrite PTree.gso in Hg by (intro E; vm_compute in E; discriminate E).
      rewrite PTree.gss in Hg. injection Hg as ->. cbn in Hmarg.
      exact Hmarg. }
    assert (Hact0 : act_inv (C._endAction :: nil)
               (PTree.set C._endAction aval
                  (PTree.set C._target3 v4
                     (PTree.set C._target2 v3
                        (PTree.set C._unstuckFrame v2
                           (PTree.set C._animation v1
                              (PTree.set Am v0 base))))))).
    { intros t' Hmem' x Hg'.
      unfold mem_id in Hmem'. cbn [existsb] in Hmem'.
      rewrite Bool.orb_false_r in Hmem'. apply Pos.eqb_eq in Hmem'. subst t'.
      rewrite PTree.gss in Hg'. injection Hg' as <-. exact Hu. }
    assert (Hch0 : chase_inv SafeB nil
               (PTree.set C._endAction aval
                  (PTree.set C._target3 v4
                     (PTree.set C._target2 v3
                        (PTree.set C._unstuckFrame v2
                           (PTree.set C._animation v1
                              (PTree.set Am v0 base))))))).
    { intros t' Hmem' b o Hg'. discriminate Hmem'. }
    change (blocks_of_env (lp_ge lp) empty_env)
      with (@nil (block * Z * Z)) in Hfree.
    cbn [Mem.free_list] in Hfree. injection Hfree as <-.
    assert (Hcpa_nil : forall fid, mem_id fid (@nil ident) = true ->
                       call_pres_act lp bm NoA MWF fid)
      by (intros fid HH; discriminate HH).
    assert (Hcpx_nil : forall fid, mem_id fid (@nil ident) = true ->
                       call_pres_ext lp bm NoA MWF fid)
      by (intros fid HH; discriminate HH).
    assert (Hcp3_nil : forall fid, mem_id fid (@nil ident) = true ->
                       call_pres_act3 lp bm NoA MWF fid)
      by (intros fid HH; discriminate HH).
    assert (Hcps_sma : forall fid,
               mem_id fid (mario._set_mario_action :: nil) = true ->
               call_pres_act lp bm NoA MWF fid).
    { intros fid HH. unfold mem_id in HH. cbn [existsb] in HH.
      rewrite Bool.orb_false_r in HH. apply Pos.eqb_eq in HH. subst fid.
      exact Hsmact. }
    destruct (wwalk_pres0 lp LO_mario bm NoA MWF HNoA_of_MWF HMWF_window
                HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot HMWF_chase
                HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
                false (C._endAction :: nil) sig_ids nil nil nil
                (mario._set_mario_action :: nil) nil
                sig_ids_rows Hcpa_nil Hcpx_nil
                (fun fid HH => call_pres_act_weaken (Hcps_sma fid HH)) Hcp3_nil
                _ _ _ _ _ _ _ _ Hbody
                (empty_env_unbound _) (empty_env_unbound _) (empty_env_unbound _)
                (empty_env_unbound _) (empty_env_unbound _) (empty_env_unbound _)
                (PTree.gempty _ _) sig_walk Htat0 Hact0 Hch0
                HN HM HV HS)
      as (HV' & HS' & HM' & HN' & _).
    exact (conj HV' (conj HS' (conj HM' HN'))).
  Qed.

  (* ==================================================================== *)
  (* The three stuck_in_ground WRAPPERS (head/butt/feet): each is a       *)
  (* 1-param leaf whose body is                                            *)
  (*   Ssequence (Scall stuck_in_ground_handler(m, c1,c2,c3,c4, ACT))      *)
  (*             (Sreturn 0)                                               *)
  (* with ACT a NON-FLYING action constant (ACT_IDLE / ACT_GROUND_POUND_  *)
  (* _LAND).  The handler call is index-5-action -- no engine channel      *)
  (* fits -- so we invert the body by hand and discharge the inner call    *)
  (* with the keystone Hsig, feeding the const action through its          *)
  (* untainted_scalar gate (wact_const_sound).                             *)
  (* ==================================================================== *)
  Lemma sig_wrapper_pres :
    forall f a1 a2 a3 a4 ACT,
      marg_exempt (Internal f) = false ->
      fn_params f = (Am, tyMSp) :: nil ->
      fn_vars f = nil ->
      fn_temps f = nil ->
      fn_body f =
        Ssequence
          (Scall None
             (Evar C._stuck_in_ground_handler
                (Tfunction (tyMSp :: tint :: tint :: tint :: tint :: tint :: nil)
                   tvoid cc_default))
             (Etempvar Am tyMSp :: a1 :: a2 :: a3 :: a4
                :: Econst_int ACT tint :: nil))
          (Sreturn (Some (Econst_int (Int.repr 0) tint))) ->
      wact_const ACT = true ->
      body_pres lp NoA MWF bm f.
  Proof.
    intros f a1 a2 a3 a4 ACT Hnex Hpar Hvar Htmp Hbod Hwc.
    intros m vargs t m' vres Hmi Hevf HN HM HV HS.
    specialize (Hmi Hnex).
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ =>
      rename He into Hentry end.
    match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
      rename Hx into Hbody end.
    match goal with Hf : Mem.free_list _ _ = Some _ |- _ =>
      rename Hf into Hfree end.
    inv Hentry.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
      rewrite Hvar in Ha; inv Ha end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ =>
      rename Hb into Hbind end.
    rewrite Hpar in Hbind. cbn [bind_parameter_temps] in Hbind.
    destruct vargs as [| v0 vr]; [ discriminate Hbind | ].
    destruct vr as [| vr0 vrr]; cbn [bind_parameter_temps] in Hbind;
      [ injection Hbind as <- | discriminate Hbind ].
    set (le0 := PTree.set Am v0 (create_undef_temps (fn_temps f))) in *.
    assert (Htat : forall b o, le0 ! Am = Some (Vptr b o) ->
                               b = bm /\ o = Ptrofs.zero).
    { intros b o Hg. unfold le0 in Hg. rewrite PTree.gss in Hg.
      injection Hg as ->. cbn in Hmi. exact Hmi. }
    change (blocks_of_env (lp_ge lp) empty_env)
      with (@nil (block * Z * Z)) in Hfree.
    cbn [Mem.free_list] in Hfree. injection Hfree as <-.
    rewrite Hbod in Hbody.
    inv Hbody.
    (* close the Sseq_2 branch (Scall yields Out_normal, contradicting the
       out <> Out_normal premise) wherever inversion placed it. *)
    all: try (match goal with
              | Hne : _ <> Out_normal |- _ =>
                  match goal with
                  | Hsc : exec_stmt _ _ _ _ _ (Scall _ _ _) _ _ _ _ |- _ =>
                      exfalso; inv Hsc; exact (Hne eq_refl)
                  end
              end).
    match goal with Hsc : exec_stmt _ _ _ _ _ (Scall _ _ _) _ _ _ _ |- _ =>
      rename Hsc into Hscall end.
    match goal with Hsr : exec_stmt _ _ _ _ _ (Sreturn _) _ _ _ _ |- _ =>
      rename Hsr into Hsret end.
    inv Hsret.
    inv Hscall.
    match goal with Hcf : classify_fun _ = fun_case_f _ _ _ |- _ =>
      cbn in Hcf; injection Hcf as E1 E2 E3; subst end.
    match goal with Hv : eval_expr _ _ _ _ (Evar _ _) _ |- _ =>
      destruct (OutParamSurface.eval_Evar_funct lp _ _ _ _ _ _ _ _
                  (PTree.gempty _ _) Hv) as (bf & Hsym & ->) end.
    match goal with
    | Hvl : eval_exprlist _ _ _ _ (Etempvar _ _ :: _) _ _ |- _ =>
        rename Hvl into Hel end.
    pose proof Hel as Hel2.
    assert (Hmarg_h : marg_ok bm _)
      by (eapply ActionValueFrame.eval_exprlist_temp_marg_ok;
          [ exact Htat | exact Hel ]).
    apply exprlist_action6 in Hel2.
    destruct Hel2 as (w0 & w1 & w2 & w3 & w4 & Hva). subst.
    assert (Hu : untainted_scalar (Vint ACT))
      by (apply wact_const_sound; exact Hwc).
    match goal with
    | Hff : Genv.find_funct _ (Vptr bf Ptrofs.zero) = Some ?fd,
      Hevf : eval_funcall _ _ _ ?fd _ _ _ _ |- _ =>
        assert (Hres_h : resolves_lp lp C._stuck_in_ground_handler fd)
          by (red; exists bf; split; [ exact Hsym | exact Hff ]);
        destruct (Hsig fd _ w0 w1 w2 w3 w4 (Vint ACT) nil _ _ _
                    Hevf Hres_h Hmarg_h Hu HN HM HV HS)
          as (HV' & HS' & HM' & HN') end.
    exact (conj HV' (conj HS' HM')).
  Qed.

  (* prog_defmap pins for the three wrappers. *)
  Example ghd_pin :
    (prog_defmap mario_actions_cutscene.prog) ! C._act_head_stuck_in_ground
      = Some (Gfun (Internal C.f_act_head_stuck_in_ground)).
  Proof. vm_compute. reflexivity. Qed.
  Example gbs_pin :
    (prog_defmap mario_actions_cutscene.prog) ! C._act_butt_stuck_in_ground
      = Some (Gfun (Internal C.f_act_butt_stuck_in_ground)).
  Proof. vm_compute. reflexivity. Qed.
  Example gfs_pin :
    (prog_defmap mario_actions_cutscene.prog) ! C._act_feet_stuck_in_ground
      = Some (Gfun (Internal C.f_act_feet_stuck_in_ground)).
  Proof. vm_compute. reflexivity. Qed.

  (* the three wrapper body_pres rows (ACT_IDLE / ACT_GROUND_POUND_LAND). *)
  Lemma ghd_pres : body_pres lp NoA MWF bm C.f_act_head_stuck_in_ground.
  Proof.
    apply (sig_wrapper_pres C.f_act_head_stuck_in_ground
             (Econst_int (Int.repr 57) tint) (Econst_int (Int.repr 96) tint)
             (Econst_int (Int.repr 105) tint) (Econst_int (Int.repr 135) tint)
             (Int.repr 205521409));
      vm_compute; reflexivity.
  Qed.
  Lemma gbs_pres : body_pres lp NoA MWF bm C.f_act_butt_stuck_in_ground.
  Proof.
    apply (sig_wrapper_pres C.f_act_butt_stuck_in_ground
             (Econst_int (Int.repr 62) tint) (Econst_int (Int.repr 127) tint)
             (Econst_int (Int.repr 136) tint)
             (Eunop Oneg (Econst_int (Int.repr 2) tint) tint)
             (Int.repr 8389180));
      vm_compute; reflexivity.
  Qed.
  Lemma gfs_pres : body_pres lp NoA MWF bm C.f_act_feet_stuck_in_ground.
  Proof.
    apply (sig_wrapper_pres C.f_act_feet_stuck_in_ground
             (Econst_int (Int.repr 85) tint) (Econst_int (Int.repr 116) tint)
             (Econst_int (Int.repr 129) tint)
             (Eunop Oneg (Econst_int (Int.repr 2) tint) tint)
             (Int.repr 205521409));
      vm_compute; reflexivity.
  Qed.

  (* ==================================================================== *)
  (* JUMBO-STAR CUTSCENE (act_jumbo_star_cutscene): an actionArg Sswitch    *)
  (* dispatcher over three subhandlers (falling / taking_off / flying).     *)
  (* The dispatcher + subhandlers shrink cut_rest by ONE (act_jumbo_star_   *)
  (* cutscene becomes a cut_walked_id).                                     *)
  (* --------------------------------------------------------------------- *)
  (* falling is the HYBRID leaf: its `m->input |= INPUT_SQUISHED` store     *)
  (* lands in the input cell [2,4) that store_window_ok deliberately        *)
  (* EXCLUDES (the A-clear cell).  Everything else is the generic census;   *)
  (* the one input-OR-store site gets a bespoke arm consuming HMWF_inp /    *)
  (* HMWF_inp_store (PROVED MWFReal projections -- NO new trust).           *)
  (* ==================================================================== *)

  (* the generated offset of MarioState.input *)
  Example input_field_off :
    field_offset (prog_comp_env mario.prog) mario._input mario_state_members
    = OK (2, Full).
  Proof. vm_compute. reflexivity. Qed.

  Definition fall_ids : list ident :=
    mario._mario_set_forward_vel :: mario._set_mario_animation
      :: mario_step._perform_air_step :: mario._play_mario_landing_sound
      :: mario._is_anim_at_end
      :: mario_actions_cutscene._advance_cutscene_step :: nil.
  Definition fall_cact : list ident := C._t'4 :: nil.
  Definition fall_xids : list ident := C._play_cutscene_music :: nil.

  Lemma fall_ids_rows : forall fid, mem_id fid fall_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold fall_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hmsfv | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_sma | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_pas | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact pmls_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact cut_iae_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact cut_acs_row | discriminate H ].
  Qed.
  Lemma fall_xids_rows : forall fid, mem_id fid fall_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold fall_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid;
        apply Hcut_ext; vm_compute; reflexivity | discriminate H ].
  Qed.

  (* the generic census base (no sc / no lids -- falling's only non-generic
     site is the input-OR-store, handled by the special arm). *)
  Definition fall_gen (s : statement) : bool :=
    wwalk_chk' nil nil nil nil nil nil false nil fall_ids nil fall_cact
      fall_xids nil nil s.

  (* the input-OR-store recognizer: m->input := (load m->input) | const,
     with const & INPUT_A_PRESSED(=2) = 0. *)
  Definition fall_input_field (a : expr) : bool :=
    match a with
    | Efield (Ederef (Etempvar p pty) sty) fld faty =>
        Pos.eqb p C._m
        && proj_sumbool (type_eq pty (tptr (Tstruct mario._MarioState noattr)))
        && proj_sumbool (type_eq sty (Tstruct mario._MarioState noattr))
        && Pos.eqb fld mario._input
        && proj_sumbool (type_eq faty tushort)
    | _ => false
    end.
  Definition fall_input_chk (s : statement) : bool :=
    match s with
    | Ssequence (Sset t src)
                (Sassign dst (Ebinop Oor (Etempvar q qty) (Econst_int c cty) bty)) =>
        fall_input_field src && fall_input_field dst
        && Pos.eqb q t
        && proj_sumbool (type_eq qty tushort)
        && proj_sumbool (type_eq cty tint)
        && proj_sumbool (type_eq bty tint)
        && proj_sumbool (Int.eq_dec (Int.and c (Int.repr 2)) Int.zero)
        && negb (Pos.eqb t C._m)
        && negb (mem_id t fall_cact)
    | _ => false
    end.

  Lemma fall_input_field_shape : forall a,
      fall_input_field a = true ->
      exists pty faty,
        a = Efield (Ederef (Etempvar C._m pty) (Tstruct mario._MarioState noattr))
              mario._input faty
        /\ pty = tptr (Tstruct mario._MarioState noattr)
        /\ faty = tushort.
  Proof.
    intros a H.
    destruct a as [ | | | | | | | | | | | e0 fld faty | | ]; try discriminate H.
    destruct e0 as [ | | | | | | e1 sty | | | | | | | ]; try discriminate H.
    destruct e1 as [ | | | | | p pty | | | | | | | | ]; try discriminate H.
    unfold fall_input_field in H.
    apply andb_true_iff in H as [H Hfa].
    apply andb_true_iff in H as [H Hfld].
    apply andb_true_iff in H as [H Hsty].
    apply andb_true_iff in H as [Hp Hpty].
    apply Pos.eqb_eq in Hp; subst p.
    apply Pos.eqb_eq in Hfld; subst fld.
    destruct (type_eq pty (tptr (Tstruct mario._MarioState noattr)));
      [ subst pty | discriminate Hpty ].
    destruct (type_eq sty (Tstruct mario._MarioState noattr));
      [ subst sty | discriminate Hsty ].
    destruct (type_eq faty tushort); [ subst faty | discriminate Hfa ].
    eauto.
  Qed.

  Lemma fall_input_shape : forall s,
      fall_input_chk s = true ->
      exists t c,
        s = Ssequence
              (Sset t (Efield (Ederef (Etempvar C._m
                          (tptr (Tstruct mario._MarioState noattr)))
                          (Tstruct mario._MarioState noattr)) mario._input tushort))
              (Sassign (Efield (Ederef (Etempvar C._m
                          (tptr (Tstruct mario._MarioState noattr)))
                          (Tstruct mario._MarioState noattr)) mario._input tushort)
                 (Ebinop Oor (Etempvar t tushort) (Econst_int c tint) tint))
        /\ Int.and c (Int.repr 2) = Int.zero
        /\ Pos.eqb t C._m = false /\ mem_id t fall_cact = false.
  Proof.
    intros s H. unfold fall_input_chk in H.
    destruct s as [ | | | | | s1 s2 | | | | | | | | ]; try discriminate H.
    destruct s1 as [ | | t src | | | | | | | | | | | ]; try discriminate H.
    destruct s2 as [ | dst rhs | | | | | | | | | | | | ]; try discriminate H.
    destruct rhs as [ | | | | | | | | | op b1 b2 bty | | | | ]; try discriminate H.
    destruct op; try discriminate H.
    destruct b1 as [ | | | | | q qty | | | | | | | | ]; try discriminate H.
    destruct b2 as [ c cty | | | | | | | | | | | | | ]; try discriminate H.
    apply andb_true_iff in H as [H Hnmem].
    apply andb_true_iff in H as [H Hnm].
    apply andb_true_iff in H as [H Hand2].
    apply andb_true_iff in H as [H Hbty].
    apply andb_true_iff in H as [H Hcty].
    apply andb_true_iff in H as [H Hqty].
    apply andb_true_iff in H as [H Hqt].
    apply andb_true_iff in H as [Hsrc Hdst].
    apply Pos.eqb_eq in Hqt; subst q.
    destruct (fall_input_field_shape _ Hsrc) as (pty1 & faty1 & -> & -> & ->).
    destruct (fall_input_field_shape _ Hdst) as (pty2 & faty2 & -> & -> & ->).
    destruct (type_eq qty tushort); [ subst qty | discriminate Hqty ].
    destruct (type_eq cty tint); [ subst cty | discriminate Hcty ].
    destruct (type_eq bty tint); [ subst bty | discriminate Hbty ].
    destruct (Int.eq_dec (Int.and c (Int.repr 2)) Int.zero) as [Heq | ];
      [ | discriminate Hand2 ].
    apply negb_true_iff in Hnm.
    apply negb_true_iff in Hnmem.
    exists t, c. split; [ reflexivity | ].
    split; [ exact Heq | ].
    split; [ exact Hnm | exact Hnmem ].
  Qed.

  Fixpoint fall_chk (s : statement) : bool :=
    fall_gen s
    || match s with
       | Ssequence s1 s2 => fall_input_chk s || (fall_chk s1 && fall_chk s2)
       | Sifthenelse _ s1 s2 => fall_chk s1 && fall_chk s2
       | _ => false
       end.

  (* the generic-subtree discharger: ONE wwalk_pres call, falling census. *)
  Lemma fall_generic :
    forall s e le m0 tr le' m' out,
      (forall g, mem_id g stored_globals = true -> e ! g = None) ->
      (forall g, mem_id g fall_ids = true -> e ! g = None) ->
      (forall g, mem_id g fall_xids = true -> e ! g = None) ->
      e ! interaction._gGlobalTimer = None ->
      fall_gen s = true ->
      (forall b o, le ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) ->
      act_inv nil le ->
      chase_inv SafeB fall_cact le ->
      NoA m0 -> MWF m0 -> Mem.valid_block m0 bm ->
      action_sat not_tainted m0 bm ->
      exec_stmt function_entry2 (lp_ge lp) e le m0 s tr le' m' out ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\
      NoA m' /\
      (forall b o, le' ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) /\
      act_inv nil le' /\ chase_inv SafeB fall_cact le'.
  Proof.
    intros s e le m0 tr le' m' out Hub_g Hub_i Hub_x Hubgt
           Hchk Htat Hact Hch HN HM HV HS Hexec.
    unfold fall_gen in Hchk.
    destruct (wwalk_pres lp LO_mario bm NoA MWF HNoA_of_MWF HMWF_window
                HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot HMWF_chase
                HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
                false nil fall_ids nil fall_cact fall_xids nil nil
                nil nil nil nil nil nil
                fall_ids_rows
                (fun fid HH => match Bool.diff_false_true HH with end)
                fall_xids_rows
                (fun fid HH => match Bool.diff_false_true HH with end)
                (fun fid HH => match Bool.diff_false_true HH with end)
                (fun fid HH => match Bool.diff_false_true HH with end)
                (fun fid HH => match Bool.diff_false_true HH with end)
                (fun fid HH => match Bool.diff_false_true HH with end)
                (fun fid HH => match Bool.diff_false_true HH with end)
                _ _ _ _ _ _ _ _
                (fun _ => Hls_real)
                (fun lid HH => match Bool.diff_false_true HH with end)
                Hexec
                Hub_g Hub_i
                (fun g HH => match Bool.diff_false_true HH with end)
                Hub_x
                (fun g HH => match Bool.diff_false_true HH with end)
                (fun g HH => match Bool.diff_false_true HH with end)
                (fun g HH => match Bool.diff_false_true HH with end)
                (fun g HH => match Bool.diff_false_true HH with end)
                (fun g HH => match Bool.diff_false_true HH with end)
                (fun g HH => match Bool.diff_false_true HH with end)
                Hubgt
                Hchk Htat Hact Hch
                (fun t HH => match Bool.diff_false_true HH with end)
                HN HM HV HS)
      as (HV' & HS' & HM' & HN' & Htat' & Hact' & Hch' & _ & _).
    exact (conj HV' (conj HS' (conj HM' (conj HN'
             (conj Htat' (conj Hact' Hch')))))).
  Qed.

  (* THE INPUT-OR-STORE ARM: m->input := (load m->input) | const, with
     const & 2 = 0.  The loaded value `old` is A-clear (HMWF_inp); OR-ing a
     2-clear const keeps it 2-clear, so the store preserves MWF (HMWF_inp_
     store) and hence NoA = ctl_a_clear (HNoA_of_MWF).  The action cell @12 is
     disjoint from the input cell @2, so action_sat survives. *)
  Lemma fall_input_pres :
    forall t c e le m0 tr le' m' out,
      Pos.eqb t C._m = false ->
      mem_id t fall_cact = false ->
      Int.and c (Int.repr 2) = Int.zero ->
      exec_stmt function_entry2 (lp_ge lp) e le m0
        (Ssequence
           (Sset t (Efield (Ederef (Etempvar C._m
                       (tptr (Tstruct mario._MarioState noattr)))
                     (Tstruct mario._MarioState noattr)) mario._input tushort))
           (Sassign (Efield (Ederef (Etempvar C._m
                       (tptr (Tstruct mario._MarioState noattr)))
                     (Tstruct mario._MarioState noattr)) mario._input tushort)
              (Ebinop Oor (Etempvar t tushort) (Econst_int c tint) tint)))
        tr le' m' out ->
      (forall b o, le ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) ->
      act_inv nil le -> chase_inv SafeB fall_cact le ->
      NoA m0 -> MWF m0 -> Mem.valid_block m0 bm ->
      action_sat not_tainted m0 bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\
      NoA m' /\
      (forall b o, le' ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) /\
      act_inv nil le' /\ chase_inv SafeB fall_cact le'.
  Proof.
    intros t c e le m0 tr le' m' out Hneq Hnmem Hc Hexec Htat Hact Hch
           HN HM HV HS.
    inv Hexec.
    2:{ (* Sseq_2: the Sset never exits non-normally *)
        match goal with
        | Hs : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ => inv Hs
        end.
        match goal with
        | Hne : Out_normal <> Out_normal |- _ => destruct (Hne eq_refl)
        end. }
    (* --- the Sset: t <- load m->input --- *)
    match goal with
    | Hset : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ Out_normal |- _ =>
        inv Hset
    end.
    match goal with
    | Hev : eval_expr _ _ _ _ (Efield _ _ _) _ |- _ => inv Hev
    end.
    match goal with
    | Hlv0 : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ =>
        pose proof Hlv0 as Hpin;
        apply eval_lvalue_Efield_base in Hpin;
        destruct Hpin as (oo0 & Hbase);
        apply eval_expr_Ederef_load in Hbase;
        destruct Hbase as (lb & ob & bfb & Hlvb & _);
        apply eval_lvalue_Ederef_base in Hlvb;
        apply eval_expr_Etempvar_val in Hlvb
    end.
    destruct (Htat _ _ Hlvb) as [E1 E2]. subst lb ob.
    match goal with
    | Hlv0 : eval_lvalue _ _ _ _ (Efield _ _ _) ?loc ?ofs ?bf |- _ =>
        destruct (mfield_lvalue_geom_lp lp LO_mario _ _ _ _ _ _
                    loc ofs bf _ _ _ Hlvb input_field_off Hlv0)
          as (E3 & E4 & E5);
        subst loc ofs bf
    end.
    match goal with
    | Hd : deref_loc (typeof _) _ _ _ _ _ |- _ => cbn [typeof] in Hd
    end.
    match goal with
    | Hd : deref_loc tushort _ _ _ _ _ |- _ =>
        inv Hd;
        try (match goal with
             | Hac : access_mode tushort = _ |- _ => cbn in Hac; discriminate Hac
             end);
        try (match goal with
             | Hlb : load_bitfield tushort _ _ _ _ _ _ _ |- _ => inv Hlb
             end)
    end.
    match goal with
    | Hac : access_mode tushort = By_value ?ch |- _ =>
        change (access_mode tushort) with (By_value Mint16unsigned) in Hac;
        injection Hac as <-
    end.
    match goal with
    | Hlr : Mem.loadv _ _ _ = Some _ |- _ =>
        unfold Mem.loadv in Hlr; rewrite Ptrofs.add_zero_l in Hlr;
        change (Ptrofs.unsigned (Ptrofs.repr 2)) with 2 in Hlr;
        rename Hlr into Hload
    end.
    (* --- the Sassign: m->input := t | c --- *)
    match goal with
    | Hasn : exec_stmt _ _ _ _ _ (Sassign _ _) _ _ _ _ |- _ => inv Hasn
    end.
    (* the store lvalue geometry: (bm, 2) *)
    match goal with
    | Hlv1 : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ =>
        pose proof Hlv1 as Hpin1;
        apply eval_lvalue_Efield_base in Hpin1;
        destruct Hpin1 as (oo1 & Hbase1);
        apply eval_expr_Ederef_load in Hbase1;
        destruct Hbase1 as (lb1 & ob1 & bfb1 & Hlvb1 & _);
        apply eval_lvalue_Ederef_base in Hlvb1;
        apply eval_expr_Etempvar_val in Hlvb1
    end.
    (* the store base loads in (PTree.set t v le); peel a COPY to pin bm,
       keeping the original Hlvb1 in the le1 env that the lvalue uses. *)
    pose proof Hlvb1 as Hlvb1c.
    rewrite PTree.gso in Hlvb1c
      by (intro EE; rewrite <- EE in Hneq; vm_compute in Hneq; discriminate Hneq).
    destruct (Htat _ _ Hlvb1c) as [E1' E2']. subst lb1 ob1.
    match goal with
    | Hlv1 : eval_lvalue _ _ _ _ (Efield _ _ _) ?loc ?ofs ?bf |- _ =>
        destruct (mfield_lvalue_geom_lp lp LO_mario _ _ _ _ _ _
                    loc ofs bf _ _ _ Hlvb1 input_field_off Hlv1)
          as (F3 & F4 & F5);
        subst loc ofs bf
    end.
    (* the RHS eval: Oor (Etempvar t) (Econst_int c) *)
    match goal with
    | Hev : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ =>
        inv Hev;
        try (match goal with
             | Hlv : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ => inv Hlv
             end)
    end.
    match goal with
    | Ht : eval_expr _ _ _ _ (Etempvar t _) _ |- _ =>
        inv Ht;
        try (match goal with
             | Hlv : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hlv
             end)
    end.
    match goal with
    | Hcst : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
        inv Hcst;
        try (match goal with
             | Hlv : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ => inv Hlv
             end)
    end.
    (* the temp t holds the loaded value v *)
    match goal with
    | Hget : (PTree.set t ?vv le) ! t = Some _ |- _ =>
        rewrite PTree.gss in Hget; injection Hget as <-
    end.
    (* a Mint16unsigned load is Vint or Vundef; sem_or forces Vint old *)
    match goal with
    | Hsem : sem_binary_operation _ Oor ?v0 _ _ _ _ = Some _ |- _ =>
        destruct v0 as [ | old | | | | ];
        try (cbn in Hsem; discriminate Hsem)
    end.
    assert (Hold2 : Int.and old (Int.repr 2) = Int.zero)
      by (apply (HMWF_inp _ HM); exact Hload).
    match goal with
    | Hsem : sem_binary_operation _ Oor _ _ _ _ _ = Some _ |- _ =>
        cbn in Hsem; injection Hsem as <-
    end.
    match goal with
    | Hcast : sem_cast _ _ _ _ = Some _ |- _ =>
        cbn in Hcast; injection Hcast as <-
    end.
    (* the assign_loc By_value store at (bm, 2) *)
    match goal with
    | Has : assign_loc _ _ _ _ _ _ _ m' |- _ =>
        cbn [typeof] in Has; inv Has;
        try (match goal with
             | Hac : access_mode tushort = By_reference |- _ => discriminate Hac
             end);
        try (match goal with
             | Hac : access_mode tushort = By_copy |- _ => discriminate Hac
             end)
    end.
    match goal with
    | Hac : access_mode tushort = By_value ?ch |- _ =>
        change (access_mode tushort) with (By_value Mint16unsigned) in Hac;
        injection Hac as <-
    end.
    match goal with
    | Hsv : Mem.storev _ _ _ _ = Some m' |- _ =>
        unfold Mem.storev in Hsv; rewrite Ptrofs.add_zero_l in Hsv;
        change (Ptrofs.unsigned (Ptrofs.repr 2)) with 2 in Hsv;
        rename Hsv into Hstore
    end.
    assert (Hvv : Int.and (Int.zero_ext 16 (Int.or old c)) (Int.repr 2)
                  = Int.zero)
      by (rewrite and2_zero_ext16; apply and2_or_clear; assumption).
    assert (HM' : MWF m')
      by (eapply HMWF_inp_store; [ exact HM | exact Hvv | exact Hstore ]).
    split; [ exact (Mem.store_valid_block_1 _ _ _ _ _ _ Hstore _ HV) | ].
    split.
    { intros av Hl.
      rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore) in Hl;
        [ exact (HS av Hl) | right; right; cbn [size_chunk]; lia ]. }
    split; [ exact HM' | ].
    split; [ exact (HNoA_of_MWF _ HM') | ].
    split.
    { intros b o Hg.
      rewrite PTree.gso in Hg
        by (intro EE; rewrite <- EE in Hneq; vm_compute in Hneq;
            discriminate Hneq).
      exact (Htat _ _ Hg). }
    split.
    { intros t' Hmem' x Hg'; discriminate Hmem'. }
    { intros t' Hmem' b o Hg'.
      rewrite PTree.gso in Hg'
        by (intro EE; rewrite EE in Hmem'; rewrite Hmem' in Hnmem;
            discriminate Hnmem).
      exact (Hch _ Hmem' _ _ Hg'). }
  Qed.

  (* THE HYBRID WALK: exec-derivation induction.  Generic subtrees go to
     fall_generic wholesale; the input-OR-store Ssequence goes to
     fall_input_pres (the novel arm). *)
  Lemma fall_pres :
    forall s e le m0 tr le' m' out,
      exec_stmt function_entry2 (lp_ge lp) e le m0 s tr le' m' out ->
      (forall g, mem_id g stored_globals = true -> e ! g = None) ->
      (forall g, mem_id g fall_ids = true -> e ! g = None) ->
      (forall g, mem_id g fall_xids = true -> e ! g = None) ->
      e ! interaction._gGlobalTimer = None ->
      fall_chk s = true ->
      (forall b o, le ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) ->
      act_inv nil le ->
      chase_inv SafeB fall_cact le ->
      NoA m0 -> MWF m0 -> Mem.valid_block m0 bm ->
      action_sat not_tainted m0 bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\
      NoA m' /\
      (forall b o, le' ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) /\
      act_inv nil le' /\ chase_inv SafeB fall_cact le'.
  Proof.
    intros s e le m0 tr le' m' out Hexec.
    induction Hexec;
      intros Hub_g Hub_i Hub_x Hubgt
             Hchk Htat Hact Hch HN HM HV HS.
    - (* Sskip *)
      exact (conj HV (conj HS (conj HM (conj HN
               (conj Htat (conj Hact Hch)))))).
    - (* Sassign: generic only *)
      cbn [fall_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hrest]; [ | discriminate Hrest ].
      eapply (fall_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hubgt
                Hg Htat Hact Hch HN HM HV HS);
        eapply exec_Sassign; eauto.
    - (* Sset: generic only *)
      cbn [fall_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hrest]; [ | discriminate Hrest ].
      eapply (fall_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hubgt
                Hg Htat Hact Hch HN HM HV HS);
        eapply exec_Sset; eauto.
    - (* Scall: generic censused arm *)
      cbn [fall_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hrest]; [ | discriminate Hrest ].
      eapply (fall_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hubgt
                Hg Htat Hact Hch HN HM HV HS);
        eapply exec_Scall; eauto.
    - (* Sbuiltin: rejected by both arms *)
      cbn [fall_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hrest];
        [ unfold fall_gen in Hg; cbn [wwalk_chk'] in Hg; discriminate Hg
        | discriminate Hrest ].
    - (* Sseq_1: generic, the input-OR-store, or recurse *)
      cbn [fall_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hrest].
      { eapply (fall_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hubgt
                  Hg Htat Hact Hch HN HM HV HS);
          eapply exec_Sseq_1; eauto. }
      apply orb_true_iff in Hrest as [Hinput | Hand].
      + (* THE INPUT-OR-STORE *)
        destruct (fall_input_shape _ Hinput)
          as (t6 & c6 & Es & Hand2 & Hneq & Hnmem).
        injection Es as -> ->.
        eapply fall_input_pres; try eassumption.
        eapply exec_Sseq_1; eauto.
      + apply andb_prop in Hand as [H1 H2].
        destruct (IHHexec1 Hub_g Hub_i Hub_x Hubgt H1
                    Htat Hact Hch HN HM HV HS)
          as (HV1 & HS1 & HM1 & HN1 & Htat1 & Hact1 & Hch1).
        exact (IHHexec2 Hub_g Hub_i Hub_x Hubgt H2
                 Htat1 Hact1 Hch1 HN1 HM1 HV1 HS1).
    - (* Sseq_2 *)
      cbn [fall_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hrest].
      { eapply (fall_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hubgt
                  Hg Htat Hact Hch HN HM HV HS);
          eapply exec_Sseq_2; eauto. }
      apply orb_true_iff in Hrest as [Hinput | Hand].
      + (* the input-store's Sset cannot exit non-normally *)
        exfalso.
        destruct (fall_input_shape _ Hinput)
          as (t6 & c6 & Es & _ & _ & _).
        injection Es as -> ->.
        match goal with
        | H1 : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ => inv H1
        end.
        match goal with
        | Hne : Out_normal <> Out_normal |- _ => exact (Hne eq_refl)
        end.
      + apply andb_prop in Hand as [H1 _].
        exact (IHHexec Hub_g Hub_i Hub_x Hubgt H1
                 Htat Hact Hch HN HM HV HS).
    - (* Sifthenelse *)
      cbn [fall_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp].
      { eapply (fall_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hubgt
                  Hg Htat Hact Hch HN HM HV HS);
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
      cbn [fall_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hrest]; [ | discriminate Hrest ].
      eapply (fall_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hubgt
                Hg Htat Hact Hch HN HM HV HS);
        eapply exec_Sloop_stop1; eauto.
    - (* Sloop stop2: generic only *)
      cbn [fall_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hrest]; [ | discriminate Hrest ].
      eapply (fall_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hubgt
                Hg Htat Hact Hch HN HM HV HS);
        eapply exec_Sloop_stop2; eauto.
    - (* Sloop loop: generic only *)
      cbn [fall_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hrest]; [ | discriminate Hrest ].
      eapply (fall_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hubgt
                Hg Htat Hact Hch HN HM HV HS);
        eapply exec_Sloop_loop; eauto.
    - (* Sswitch: generic only *)
      cbn [fall_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hrest]; [ | discriminate Hrest ].
      eapply (fall_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hubgt
                Hg Htat Hact Hch HN HM HV HS);
        eapply exec_Sswitch; eauto.
  Qed.

  (* the falling subhandler is Internal in mario_actions_cutscene.prog *)
  Lemma fall_pin :
    (prog_defmap mario_actions_cutscene.prog)
      ! mario_actions_cutscene._jumbo_star_cutscene_falling
    = Some (Gfun (Internal
                    mario_actions_cutscene.f_jumbo_star_cutscene_falling)).
  Proof. vm_compute. reflexivity. Qed.

  (* NON-VACUITY: the hybrid recognizer accepts the REAL falling body. *)
  Lemma fall_walk :
    fall_chk (fn_body mario_actions_cutscene.f_jumbo_star_cutscene_falling)
    = true.
  Proof. vm_compute. reflexivity. Qed.

  (* THE LEAF: fn_vars = nil, 1 param _m; the body goes to fall_pres. *)
  Lemma falling_body_pres :
    body_pres lp NoA MWF bm
      mario_actions_cutscene.f_jumbo_star_cutscene_falling.
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
    assert (Hc0 : LocalVarsSurface.carried bm NoA MWF m0)
      by (split; [ exact HV | split; [ exact HS
                 | split; [ exact HM | exact HN ] ] ]).
    pose proof (LocalVarsSurface.alloc_variables_carried
                  bm NoA MWF HMWF_alloc HNoA_of_MWF
                  _ _ _ _ _ _ Halloc Hc0) as Hca.
    destruct Hca as (HVa & HSa & HMa & HNa).
    assert (Hps : match
                    fn_params
                      mario_actions_cutscene.f_jumbo_star_cutscene_falling
                  with
                  | (i, ty) :: ps =>
                      (Pos.eqb i mario_actions_airborne._m
                       && proj_sumbool (type_eq ty tyMSp)
                       && negb (mem_id mario_actions_airborne._m
                                  (map fst ps)))%bool
                  | nil => false
                  end = true) by (vm_compute; reflexivity).
    assert (Hnpc : forallb
              (fun t' => negb (mem_id t'
                 (map fst (fn_params
                    mario_actions_cutscene.f_jumbo_star_cutscene_falling))))
              fall_cact = true) by (vm_compute; reflexivity).
    assert (Hmarg : marg_ok bm vargs0)
      by (apply Hmargf; vm_compute; reflexivity).
    destruct (fn_params mario_actions_cutscene.f_jumbo_star_cutscene_falling)
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
        assert (Hch0 : chase_inv SafeB fall_cact le1)
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
    assert (Hub_g : forall g, mem_id g stored_globals = true ->
                    eloc ! g = None).
    { intros g Hg.
      rewrite (LocalVarsSurface.alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc g)
        by (intro Hin; vm_compute in Hin; exact Hin).
      apply PTree.gempty. }
    assert (Hub_i : forall g, mem_id g fall_ids = true -> eloc ! g = None).
    { intros g Hg.
      rewrite (LocalVarsSurface.alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc g)
        by (intro Hin; vm_compute in Hin; exact Hin).
      apply PTree.gempty. }
    assert (Hub_x : forall g, mem_id g fall_xids = true -> eloc ! g = None).
    { intros g Hg.
      rewrite (LocalVarsSurface.alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc g)
        by (intro Hin; vm_compute in Hin; exact Hin).
      apply PTree.gempty. }
    assert (Hub_gt : eloc ! interaction._gGlobalTimer = None).
    { rewrite (LocalVarsSurface.alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc
                 interaction._gGlobalTimer)
        by (intro Hin; vm_compute in Hin; exact Hin).
      apply PTree.gempty. }
    destruct (fall_pres _ _ _ _ _ _ _ _ Hbody
                Hub_g Hub_i Hub_x Hub_gt
                fall_walk Htat0 Hact0 Hch0 HNa HMa HVa HSa)
      as (HVb & HSb & HMb & HNb & _ & _ & _).
    pose proof (LocalVarsSurface.blocks_of_env_bm lp bm m0 _ eloc _ Halloc HV) as Hforall.
    pose proof (LocalVarsSurface.free_list_carried_bm bm NoA MWF HMWF_free HNoA_of_MWF
                  (blocks_of_env (lp_ge lp) eloc) _ mF Hforall Hfree
                  (conj HVb (conj HSb (conj HMb HNb))))
      as (HVf & HSf & HMf & HNf).
    exact (conj HVf (conj HSf HMf)).
  Qed.

  (* --------- taking_off subhandler: clean generic walk (no input store) --- *)
  (* All stores are either window m-fields (actionState++, particleFlags|=) or *)
  (* chase stores through marioObj (marioObj->rawData.asF32[34]).  Callees are *)
  (* the ids rows (sma/ipae/pmls/psasp/umpfa/acs) + xids (play_sound/vec3f_set *)
  (* /vec3f_copy/vec3s_set).  marioObj/t'13/t'11/t'10 are the chase temps.     *)
  Definition tko_ids : list ident :=
    mario._set_mario_animation :: mario._is_anim_past_end
      :: mario._play_mario_landing_sound :: mario._play_sound_and_spawn_particles
      :: mario._update_mario_pos_for_anim
      :: mario_actions_cutscene._advance_cutscene_step :: nil.
  Definition tko_cact : list ident :=
    C._marioObj :: C._t'13 :: C._t'11 :: C._t'10 :: nil.
  Definition tko_xids : list ident :=
    mario._play_sound :: mario._vec3f_set :: mario._vec3f_copy
      :: mario._vec3s_set :: nil.

  Example tko_walk_probe :
    wwalk_chk false nil tko_ids nil tko_cact tko_xids nil nil
      (fn_body mario_actions_cutscene.f_jumbo_star_cutscene_taking_off) = true.
  Proof. vm_compute; reflexivity. Qed.

  Lemma tko_ids_rows : forall fid, mem_id fid tko_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold tko_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_sma | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_ipae | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact pmls_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_psasp | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_umpfa | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact cut_acs_row | discriminate H ].
  Qed.
  Lemma tko_xids_rows : forall fid, mem_id fid tko_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold tko_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_psound | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_v3fset | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_v3fc | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_v3ss | discriminate H ].
  Qed.

  Lemma taking_off_body_pres :
    body_pres lp NoA MWF bm C.f_jumbo_star_cutscene_taking_off.
  Proof.
    apply (body_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             C.f_jumbo_star_cutscene_taking_off
             tko_ids nil tko_cact tko_xids nil nil).
    - vm_compute; reflexivity.
    - vm_compute; reflexivity.
    - vm_compute; reflexivity.
    - exact tko_ids_rows.
    - intros fid' H; discriminate H.
    - exact tko_xids_rows.
    - intros fid' H; discriminate H.
    - intros fid' H; discriminate H.
    - exact tko_walk_probe.
  Qed.

  (* --------- flying subhandler: lwalk (fn_vars=[targetPos]) generic walk --- *)
  (* Two chase roots: marioObj (gfx.angle stores) AND marioBodyState (handState *)
  (* via t'8).  sids = set_mario_action(m, 16779404, 0) -- the const must be    *)
  (* untainted (NOT a flying/FTJ/cannon action).  level_trigger_warp = the      *)
  (* SHARED warp trigger (Hcp_ltw).  externals: anim_spline_init/poll, sqrtf,   *)
  (* atan2s, vec3f_copy.  targetPos is a LOCAL float[3] (out-param to            *)
  (* anim_spline_poll + read for the angle math), so block != bm.               *)
  Definition fly_ids : list ident :=
    mario._set_mario_animation :: level_update._level_trigger_warp :: nil.
  Definition fly_cact : list ident :=
    C._marioObj :: C._t'13 :: C._t'12 :: C._t'10 :: C._t'8 :: C._t'7 :: nil.
  Definition fly_xids : list ident :=
    C._anim_spline_init :: C._anim_spline_poll :: mario._sqrtf
      :: interaction._atan2s :: mario._vec3f_copy :: nil.
  Definition fly_sids : list ident := mario._set_mario_action :: nil.

  Example fly_walk_probe :
    wwalk_chk false nil fly_ids nil fly_cact fly_xids fly_sids nil
      (fn_body mario_actions_cutscene.f_jumbo_star_cutscene_flying) = true.
  Proof. vm_compute; reflexivity. Qed.

  Lemma fly_ids_rows : forall fid, mem_id fid fly_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold fly_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_sma | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_ltw | discriminate H ].
  Qed.
  Lemma fly_xids_rows : forall fid, mem_id fid fly_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold fly_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_asi | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_asp | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_sqrtf | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_atan2s | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_v3fc | discriminate H ].
  Qed.

  Lemma flying_body_pres :
    body_pres lp NoA MWF bm C.f_jumbo_star_cutscene_flying.
  Proof.
    apply (body_pres_of_lwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             HMWF_alloc HMWF_free
             C.f_jumbo_star_cutscene_flying
             fly_ids nil fly_cact fly_xids fly_sids).
    - vm_compute; reflexivity.                          (* params shape *)
    - intros g Hg HIn. vm_compute in HIn.               (* stored_globals not in vars *)
      destruct HIn as [E | []]. subst g. vm_compute in Hg. discriminate Hg.
    - intros g Hg HIn. vm_compute in HIn.               (* ids not in vars *)
      destruct HIn as [E | []]. subst g. vm_compute in Hg. discriminate Hg.
    - intros g Hg. discriminate Hg.                     (* wids = nil *)
    - intros g Hg HIn. vm_compute in HIn.               (* xids not in vars *)
      destruct HIn as [E | []]. subst g. vm_compute in Hg. discriminate Hg.
    - intros g Hg HIn. vm_compute in HIn.               (* sids not in vars *)
      destruct HIn as [E | []]. subst g. vm_compute in Hg. discriminate Hg.
    - intro HIn. vm_compute in HIn.                     (* gGlobalTimer not in vars *)
      destruct HIn as [E | []]. discriminate E.
    - vm_compute; reflexivity.                          (* cact not in params *)
    - exact fly_ids_rows.
    - intros fid' H; discriminate H.                    (* wids rows *)
    - exact fly_xids_rows.
    - intros fid' H. unfold fly_sids in H. cbn [mem_id existsb] in H.
      apply orb_true_iff in H as [Hm | H];
        [ apply Pos.eqb_eq in Hm; subst fid'; exact Hsmact | discriminate H ].
    - exact fly_walk_probe.
  Qed.

  (* --------- the dispatcher: act_jumbo_star_cutscene reads m->actionArg --- *)
  (* and Sswitches over {0->falling, 1->taking_off, 2->flying}, each called   *)
  (* with (m).  Lift the 3 subhandler body_pres to call_pres (LO_cut) and     *)
  (* walk the dispatcher generically (no stores; ids = the 3 subhandlers).    *)
  Lemma falling_pin :
    (prog_defmap mario_actions_cutscene.prog)
      ! C._jumbo_star_cutscene_falling
      = Some (Gfun (Internal C.f_jumbo_star_cutscene_falling)).
  Proof. vm_compute. reflexivity. Qed.
  Lemma taking_off_pin :
    (prog_defmap mario_actions_cutscene.prog)
      ! C._jumbo_star_cutscene_taking_off
      = Some (Gfun (Internal C.f_jumbo_star_cutscene_taking_off)).
  Proof. vm_compute. reflexivity. Qed.
  Lemma flying_pin :
    (prog_defmap mario_actions_cutscene.prog)
      ! C._jumbo_star_cutscene_flying
      = Some (Gfun (Internal C.f_jumbo_star_cutscene_flying)).
  Proof. vm_compute. reflexivity. Qed.

  Definition jumbo_ids : list ident :=
    C._jumbo_star_cutscene_falling :: C._jumbo_star_cutscene_taking_off
      :: C._jumbo_star_cutscene_flying :: nil.

  Lemma jumbo_ids_rows : forall fid, mem_id fid jumbo_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold jumbo_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid;
        exact (call_pres_of_body lp bm NoA MWF HNoA_of_MWF
                 mario_actions_cutscene.prog _ _ LO_cut falling_pin
                 falling_body_pres) | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid;
        exact (call_pres_of_body lp bm NoA MWF HNoA_of_MWF
                 mario_actions_cutscene.prog _ _ LO_cut taking_off_pin
                 taking_off_body_pres) | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid;
        exact (call_pres_of_body lp bm NoA MWF HNoA_of_MWF
                 mario_actions_cutscene.prog _ _ LO_cut flying_pin
                 flying_body_pres)
      | discriminate H ].
  Qed.

  Example jumbo_walk :
    wwalk_chk false nil jumbo_ids nil nil nil nil nil
      (fn_body C.f_act_jumbo_star_cutscene) = true.
  Proof. vm_compute; reflexivity. Qed.

  Lemma jumbo_pin :
    (prog_defmap mario_actions_cutscene.prog) ! C._act_jumbo_star_cutscene
      = Some (Gfun (Internal C.f_act_jumbo_star_cutscene)).
  Proof. vm_compute. reflexivity. Qed.

  Lemma jumbo_pres : body_pres lp NoA MWF bm C.f_act_jumbo_star_cutscene.
  Proof.
    apply (body_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             C.f_act_jumbo_star_cutscene jumbo_ids nil nil nil nil nil).
    - vm_compute; reflexivity.
    - vm_compute; reflexivity.
    - vm_compute; reflexivity.
    - exact jumbo_ids_rows.
    - intros fid' H; discriminate H.
    - intros fid' H; discriminate H.
    - intros fid' H; discriminate H.
    - intros fid' H; discriminate H.
    - exact jumbo_walk.
  Qed.

  (* ==================================================================== *)
  (* SLICE 26: act_exit_land_save_dialog (eld).  The save-menu landing     *)
  (* leaf.  Three NON-Mario level-transition glob-setters in the          *)
  (* handle_save_menu subtree -- fade_into_special_warp -> { warp_special, *)
  (* level_set_transition } (level_update.prog) -- only store into          *)
  (* bm-disjoint statics (stored_globals, Hglob_blk), so each is walked as  *)
  (* call_pres_ext via the marg-FREE call_pres_ext_of_wwalk producer (NO m  *)
  (* param: the m->bm chase invariant is vacuous).  cutscene_take_cap_off   *)
  (* is the cpco twin (2 m->flags stores + play_sound).  The leaf itself    *)
  (* chases m->marioBodyState (handState/eyeState) + m->marioObj            *)
  (* (gfx.angle[1] deep indexed store) -- cact = [t'17;t'16;t'11].          *)
  (* gSaveOptSelectIndex + the 5 transition statics ride stored_globals;    *)
  (* the 4 dialog/audio externals ride cut_ext_ids (Hcut_ext).  NO new      *)
  (* capstone hypothesis: every brick is an existing section term.          *)
  (* ==================================================================== *)

  (* --- warp_special: 3 glob stores (sCurrPlayMode/D_80339ECA/D_80339EE0),
     NON-Mario param _arg, no callees.  call_pres_ext_of_wwalk. --- *)
  Example wsp_pin :
    (prog_defmap level_update.prog) ! level_update._warp_special
    = Some (Gfun (Internal level_update.f_warp_special)).
  Proof. vm_compute. reflexivity. Qed.
  Example wsp_vars : fn_vars level_update.f_warp_special = nil.
  Proof. vm_compute. reflexivity. Qed.
  Example wsp_no_m :
    negb (mem_id Am (map fst (fn_params level_update.f_warp_special))) = true.
  Proof. vm_compute. reflexivity. Qed.
  Example wsp_walk :
    wwalk_chk false nil nil nil nil nil nil nil
      (fn_body level_update.f_warp_special) = true.
  Proof. vm_compute. reflexivity. Qed.
  Lemma wsp_row : call_pres_ext lp bm NoA MWF level_update._warp_special.
  Proof.
    apply (call_pres_ext_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             level_update.prog level_update._warp_special
             level_update.f_warp_special nil nil nil nil
             LO_lvl wsp_pin wsp_vars wsp_no_m).
    - intros fid' H; discriminate H.
    - intros fid' H; discriminate H.
    - intros fid' H; discriminate H.
    - intros fid' H; discriminate H.
    - exact wsp_walk.
  Qed.

  (* --- level_set_transition: 2 glob stores (sTransitionTimer = length,
     sTransitionUpdate = updateFunction, a funptr -> By_value Mptr store),
     NON-Mario params, no callees.  call_pres_ext_of_wwalk. --- *)
  Example lst_pin :
    (prog_defmap level_update.prog) ! level_update._level_set_transition
    = Some (Gfun (Internal level_update.f_level_set_transition)).
  Proof. vm_compute. reflexivity. Qed.
  Example lst_vars : fn_vars level_update.f_level_set_transition = nil.
  Proof. vm_compute. reflexivity. Qed.
  Example lst_no_m :
    negb (mem_id Am (map fst (fn_params level_update.f_level_set_transition)))
    = true.
  Proof. vm_compute. reflexivity. Qed.
  Example lst_walk :
    wwalk_chk false nil nil nil nil nil nil nil
      (fn_body level_update.f_level_set_transition) = true.
  Proof. vm_compute. reflexivity. Qed.
  Lemma lst_row :
    call_pres_ext lp bm NoA MWF level_update._level_set_transition.
  Proof.
    apply (call_pres_ext_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             level_update.prog level_update._level_set_transition
             level_update.f_level_set_transition nil nil nil nil
             LO_lvl lst_pin lst_vars lst_no_m).
    - intros fid' H; discriminate H.
    - intros fid' H; discriminate H.
    - intros fid' H; discriminate H.
    - intros fid' H; discriminate H.
    - exact lst_walk.
  Qed.

  (* --- fade_into_special_warp: local Sset of param _color + 4 calls
     (fadeout_music/play_transition externals + level_set_transition/
     warp_special internals), NO stores, NON-Mario params.  Walked as
     call_pres_ext; xids = the 4 callees. --- *)
  Definition fiw_xids : list ident :=
    level_update._fadeout_music :: level_update._play_transition
      :: level_update._level_set_transition :: level_update._warp_special :: nil.
  Example fiw_pin :
    (prog_defmap level_update.prog) ! level_update._fade_into_special_warp
    = Some (Gfun (Internal level_update.f_fade_into_special_warp)).
  Proof. vm_compute. reflexivity. Qed.
  Example fiw_vars : fn_vars level_update.f_fade_into_special_warp = nil.
  Proof. vm_compute. reflexivity. Qed.
  Example fiw_no_m :
    negb (mem_id Am (map fst (fn_params level_update.f_fade_into_special_warp)))
    = true.
  Proof. vm_compute. reflexivity. Qed.
  Example fiw_walk :
    wwalk_chk false nil nil nil nil fiw_xids nil nil
      (fn_body level_update.f_fade_into_special_warp) = true.
  Proof. vm_compute. reflexivity. Qed.
  Lemma fiw_xids_rows : forall fid, mem_id fid fiw_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold fiw_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; apply Hcut_ext; reflexivity | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; apply Hcut_ext; reflexivity | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact lst_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact wsp_row | discriminate H ].
  Qed.
  Lemma fiw_row :
    call_pres_ext lp bm NoA MWF level_update._fade_into_special_warp.
  Proof.
    apply (call_pres_ext_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             level_update.prog level_update._fade_into_special_warp
             level_update.f_fade_into_special_warp nil nil fiw_xids nil
             LO_lvl fiw_pin fiw_vars fiw_no_m).
    - intros fid' H; discriminate H.
    - intros fid' H; discriminate H.
    - exact fiw_xids_rows.
    - intros fid' H; discriminate H.
    - exact fiw_walk.
  Qed.

  (* --- cutscene_take_cap_off: the cpco twin (flags &= ~16; flags |= 32;
     play_sound), marioObj read-only.  call_pres_of_wwalk. --- *)
  Definition ctco_xids : list ident := mario._play_sound :: nil.
  Example ctco_pin :
    (prog_defmap C.prog) ! C._cutscene_take_cap_off
    = Some (Gfun (Internal C.f_cutscene_take_cap_off)).
  Proof. vm_compute. reflexivity. Qed.
  Example ctco_vars : fn_vars C.f_cutscene_take_cap_off = nil.
  Proof. vm_compute. reflexivity. Qed.
  Example ctco_pok :
    match fn_params C.f_cutscene_take_cap_off with
    | (i, ty) :: ps =>
        Pos.eqb i Am && proj_sumbool (type_eq ty tyMSp)
        && negb (mem_id Am (map fst ps))
    | nil => false end = true.
  Proof. vm_compute. reflexivity. Qed.
  Example ctco_walk :
    wwalk_chk false nil nil nil nil ctco_xids nil nil
      (fn_body C.f_cutscene_take_cap_off) = true.
  Proof. vm_compute. reflexivity. Qed.
  Lemma ctco_xids_rows : forall fid, mem_id fid ctco_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold ctco_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_psound | discriminate H ].
  Qed.
  Lemma ctco_row : call_pres lp bm NoA MWF C._cutscene_take_cap_off.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_cutscene.prog C._cutscene_take_cap_off
             C.f_cutscene_take_cap_off nil nil ctco_xids nil
             LO_cut ctco_pin ctco_vars ctco_pok).
    - intros fid' H; discriminate H.
    - intros fid' H; discriminate H.
    - exact ctco_xids_rows.
    - intros fid' H; discriminate H.
    - exact ctco_walk.
  Qed.

  (* --- handle_save_menu: reads gSaveOptSelectIndex/gCurrSaveFileNum, one
     m->faceAngle[1] idx16 window store, calls is_anim_past_end /
     get_star_collection_dialog (ids), save_file_do_save / fade_into_special_
     warp / disable_time_stop / play_peachs_jingle (xids), set_mario_action
     (sids, const action UNTAINTED).  cact = nil (no chase store).
     call_pres_of_wwalk. --- *)
  Definition hsm_ids : list ident :=
    mario._is_anim_past_end :: C._get_star_collection_dialog :: nil.
  Definition hsm_xids : list ident :=
    C._save_file_do_save :: level_update._fade_into_special_warp
      :: C._disable_time_stop :: C._play_peachs_jingle :: nil.
  Definition hsm_sids : list ident := mario._set_mario_action :: nil.
  Example hsm_pin :
    (prog_defmap C.prog) ! C._handle_save_menu
    = Some (Gfun (Internal C.f_handle_save_menu)).
  Proof. vm_compute. reflexivity. Qed.
  Example hsm_vars : fn_vars C.f_handle_save_menu = nil.
  Proof. vm_compute. reflexivity. Qed.
  Example hsm_pok :
    match fn_params C.f_handle_save_menu with
    | (i, ty) :: ps =>
        Pos.eqb i Am && proj_sumbool (type_eq ty tyMSp)
        && negb (mem_id Am (map fst ps))
    | nil => false end = true.
  Proof. vm_compute. reflexivity. Qed.
  Example hsm_walk :
    wwalk_chk false nil hsm_ids nil nil hsm_xids hsm_sids nil
      (fn_body C.f_handle_save_menu) = true.
  Proof. vm_compute. reflexivity. Qed.
  Lemma hsm_ids_rows : forall fid, mem_id fid hsm_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold hsm_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_ipae | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact gscd_row | discriminate H ].
  Qed.
  Lemma hsm_xids_rows : forall fid, mem_id fid hsm_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold hsm_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; apply Hcut_ext; reflexivity | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact fiw_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; apply Hcut_ext; reflexivity | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; apply Hcut_ext; reflexivity | discriminate H ].
  Qed.
  Lemma hsm_sids_rows : forall fid, mem_id fid hsm_sids = true ->
      call_pres_act lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold hsm_sids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsmact | discriminate H ].
  Qed.
  Lemma hsm_row : call_pres lp bm NoA MWF C._handle_save_menu.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_cutscene.prog C._handle_save_menu
             C.f_handle_save_menu hsm_ids nil hsm_xids hsm_sids
             LO_cut hsm_pin hsm_vars hsm_pok).
    - exact hsm_ids_rows.
    - intros fid' H; discriminate H.
    - exact hsm_xids_rows.
    - exact hsm_sids_rows.
    - exact hsm_walk.
  Qed.

  (* --- act_exit_land_save_dialog: the leaf.  ids = stationary_ground_step /
     set_mario_animation / is_anim_past_end / spawn_obj_at_mario_rel_yaw /
     handle_save_menu / cutscene_take_cap_off / cutscene_put_cap_on; cact =
     [t'17;t'16;t'11] (marioBodyState handState/eyeState + marioObj gfx.angle[1]);
     xids = play_mario_landing_sound_once / enable_time_stop / set_menu_mode /
     play_sound; sids = nil.  Stores: m->actionState (window) +
     gSaveOptSelectIndex = 0 (glob). --- *)
  Definition eld_ids : list ident :=
    mario_step._stationary_ground_step :: mario._set_mario_animation
      :: mario._is_anim_past_end :: C._spawn_obj_at_mario_rel_yaw
      :: C._handle_save_menu :: C._cutscene_take_cap_off
      :: C._cutscene_put_cap_on :: nil.
  Definition eld_cact : list ident :=
    C._t'17 :: C._t'16 :: C._t'11 :: nil.
  Definition eld_xids : list ident :=
    C._play_mario_landing_sound_once :: C._enable_time_stop
      :: C._set_menu_mode :: mario._play_sound :: nil.
  Example eld_walk :
    wwalk_chk false nil eld_ids nil eld_cact eld_xids nil nil
      (fn_body C.f_act_exit_land_save_dialog) = true.
  Proof. vm_compute. reflexivity. Qed.
  Lemma eld_ids_rows : forall fid, mem_id fid eld_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold eld_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact cut_sgs_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_sma | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_ipae | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_spawn_obj | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact hsm_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact ctco_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact cpco_row | discriminate H ].
  Qed.
  Lemma eld_xids_rows : forall fid, mem_id fid eld_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold eld_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_pmlso | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; apply Hcut_ext; reflexivity | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; apply Hcut_ext; reflexivity | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_psound | discriminate H ].
  Qed.
  Lemma eld_pin :
    (prog_defmap mario_actions_cutscene.prog) ! C._act_exit_land_save_dialog
      = Some (Gfun (Internal C.f_act_exit_land_save_dialog)).
  Proof. vm_compute. reflexivity. Qed.
  Lemma eld_pres : body_pres lp NoA MWF bm C.f_act_exit_land_save_dialog.
  Proof.
    apply (body_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             C.f_act_exit_land_save_dialog eld_ids nil eld_cact eld_xids nil nil).
    - vm_compute; reflexivity.
    - vm_compute; reflexivity.
    - vm_compute; reflexivity.
    - exact eld_ids_rows.
    - intros fid' H; discriminate H.
    - exact eld_xids_rows.
    - intros fid' H; discriminate H.
    - intros fid' H; discriminate H.
    - exact eld_walk.
  Qed.

  (* ==================================================================== *)
  (* ==================================================================== *)
  (* SLICE 21: act_debug_free_move (dfm) -- the FIRST cutscene HYBRID walk *)
  (* (mirror of AutomaticLeafSurface.twl).  The ~400-line body is          *)
  (* wwalk-clean EXCEPT three vec3f_copy/rwc call sites, distinguished by  *)
  (* their dst SHAPE:                                                       *)
  (*   - resolve_and_return_wall_collisions(pos, c, c)  [ol gate, pos a    *)
  (*       stack-local working copy]                                       *)
  (*   - vec3f_copy(pos, m->pos)  [wl gate, dst=local pos, src=m->pos      *)
  (*       window -- the NEW OutParamSurface arc]                          *)
  (*   - vec3f_copy(m->pos, pos)  [w1 gate, dst=m->pos window, src=local]  *)
  (* Its marioObj vec3f_copy/vec3s_set (dst chases _t'9/_t'7 into the      *)
  (* Object) ride the GENERIC sc arm; its A-gate                          *)
  (* (gPlayer1Controller->buttonPressed == 0x8000) walks GENERICALLY --    *)
  (* the THEN's set_mario_action(m, _action, 0) is gated by smact_call_chk *)
  (* with _action in wact (the inner water-level if sets _action to one of *)
  (* two UNTAINTED action consts ACT_WATER_IDLE / ACT_IDLE), so NO         *)
  (* controller-clear fact is needed.                                      *)
  (* ==================================================================== *)

  Definition dfm_lids : list ident := C._pos :: C._surf :: nil.
  Definition dfm_oc : list ident := mario._find_floor :: nil.
  Definition dfm_sc : list ident :=
    mario._vec3f_copy :: mario._vec3s_set :: nil.
  Definition dfm_ids : list ident := mario._set_mario_animation :: nil.
  Definition dfm_wact : list ident := C._action :: nil.
  Definition dfm_cact : list ident := C._t'9 :: C._t'7 :: nil.
  Definition dfm_sids : list ident := mario._set_mario_action :: nil.

  Definition dfm_gen (s : statement) : bool :=
    wwalk_chk' dfm_lids dfm_oc nil dfm_sc nil nil false
      dfm_wact dfm_ids nil dfm_cact nil dfm_sids nil s.

  (* one whole-array local decay arg: `pos` (a stack-local fn_var). *)
  Definition dfm_pos_arg (a : expr) : bool :=
    match a with
    | Evar lid aty =>
        Pos.eqb lid C._pos && proj_sumbool (type_eq aty (tarray tfloat 3))
    | _ => false
    end.

  (* the m->pos window arg. *)
  Definition dfm_mpos_arg (a : expr) : bool :=
    match a with
    | Efield (Ederef (Etempvar p pty) sty) fld faty =>
        Pos.eqb p C._m
        && proj_sumbool (type_eq pty (tptr (Tstruct C._MarioState noattr)))
        && proj_sumbool (type_eq sty (Tstruct C._MarioState noattr))
        && Pos.eqb fld C._pos
        && proj_sumbool (type_eq faty (tarray tfloat 3))
    | _ => false
    end.

  Definition dfm_sg_arg (a : expr) : bool :=
    match a with Econst_single _ _ => true | _ => false end.

  Definition dfm_rwc_fty : type :=
    Tfunction (tptr tfloat :: tfloat :: tfloat :: nil)
      (tptr (Tstruct C._Surface noattr)) cc_default.
  Definition dfm_v3f_fty : type :=
    Tfunction (tptr tfloat :: tptr tfloat :: nil) (tptr tvoid) cc_default.

  (* the THREE special call shapes (everything else is generic). *)
  Definition dfm_sp_chk (s : statement) : bool :=
    match s with
    | Scall None (Evar fid fty) al =>
        (Pos.eqb fid C._resolve_and_return_wall_collisions
         && proj_sumbool (type_eq fty dfm_rwc_fty)
         && match al with
            | a0 :: a1 :: a2 :: nil =>
                dfm_pos_arg a0 && dfm_sg_arg a1 && dfm_sg_arg a2
            | _ => false
            end)
        || (Pos.eqb fid C._vec3f_copy
            && proj_sumbool (type_eq fty dfm_v3f_fty)
            && match al with
               | d0 :: d1 :: nil =>
                   (dfm_pos_arg d0 && dfm_mpos_arg d1)   (* SITE B: wl *)
                   || (dfm_mpos_arg d0 && dfm_pos_arg d1) (* SITE C: w1 *)
               | _ => false
               end)
    | _ => false
    end.

  Fixpoint dfm_chk (s : statement) : bool :=
    dfm_gen s
    || match s with
       | Ssequence s1 s2 => dfm_chk s1 && dfm_chk s2
       | Sifthenelse _ s1 s2 => dfm_chk s1 && dfm_chk s2
       | _ => dfm_sp_chk s
       end.

  (* the syntactic probe: the hybrid recognizer accepts the REAL body. *)
  Example dfm_walk : dfm_chk (fn_body C.f_act_debug_free_move) = true.
  Proof. vm_compute. reflexivity. Qed.

  (* ---- the gated-external rows the dfm walk consumes.  Of these, only  *)
  (* Hwlcp_v3f (the NEW wl arc) is fresh capstone trust; sc/w1/oc/ol over *)
  (* $"vec3f_copy"/$"vec3s_set"/$"find_floor"/$"resolve_..." are ALREADY  *)
  (* trusted by the automatic/step/inter families (same idents). ---- *)
  Hypothesis Hscp_v3f :
    OutParamSurface.call_pres_ext_sc lp bm NoA MWF SafeB mario._vec3f_copy.
  Hypothesis Hscp_v3s :
    OutParamSurface.call_pres_ext_sc lp bm NoA MWF SafeB mario._vec3s_set.
  Hypothesis Hw1cp_v3f :
    OutParamSurface.call_pres_ext_w1 lp bm NoA MWF mario._vec3f_copy.
  Hypothesis Hwlcp_v3f :
    OutParamSurface.call_pres_ext_wl lp bm NoA MWF SafeB mario._vec3f_copy.
  Hypothesis Hocp_find_floor :
    OutParamSurface.call_pres_ext_oc lp bm NoA MWF SafeB mario._find_floor.
  Hypothesis Hocp_resolve :
    OutParamSurface.call_pres_ext_ol lp bm NoA MWF SafeB
      mario._resolve_and_return_wall_collisions.

  (* ==================================================================== *)
  (* GLOB-OBJ-CHASE FOUNDATION (for closing the cutscene tail: intro /     *)
  (* end_peach / end_waving store THROUGH a value loaded from a GLOBAL     *)
  (* object-pointer variable in gobj_ids).  This is the honest per-symbol  *)
  (* reach-closure row + the seed lemma; the bespoke per-leaf walker that  *)
  (* CONSUMES them is built next.  [scaffolding -- no spine lemma uses it   *)
  (* yet; see [[cutscene-globobj-campaign]].]                              *)
  (* ==================================================================== *)
  (* HGlobObjRoot: each global obj-ptr in gobj_ids, IF a pointer, points   *)
  (* into the SafeB object pool (the warp-pipe / end-peach objects are     *)
  (* spawn_object'd into the pool).  Honest, per-symbol, dischargeable in   *)
  (* principle (NOT provable from current MWFReal: SafeB is abstract and    *)
  (* there is no per-symbol global-obj membership row -- this becomes a     *)
  (* new R11-style capstone assumption when consumed). *)
  Hypothesis HGlobObjRoot :
    forall g gb m b o,
      mem_id g gobj_ids = true ->
      MWF m ->
      Genv.find_symbol (lp_ge lp) g = Some gb ->
      Mem.loadv Mptr m (Vptr gb Ptrofs.zero) = Some (Vptr b o) ->
      SafeB b.

  (* the glob-obj SEED recognizer (only the POINTER-ness of the type matters
     -- the load is By_value Mptr regardless of the pointed-to struct). *)
  Definition gobj_seed_chk (t : ident) (s : statement) : bool :=
    match s with
    | Sset id (Evar g (Tpointer _ _)) =>
        Pos.eqb id t && Pos.eqb g mario_actions_cutscene._sIntroWarpPipeObj
    | _ => false
    end.

  (* the SEED (eval-core): evaluating `Evar g (Tpointer _ _)` for g in        *)
  (* gobj_ids yields a value that, IF a pointer, is SafeB -- so the temp it   *)
  (* is set into can join the chase set.  The bespoke walker's Sset seed arm  *)
  (* consumes this directly.  (Eval-core of RealFrameValue.sset_gms_bm,       *)
  (* concluding SafeB via HGlobObjRoot rather than =bm.) *)
  Lemma glob_obj_val :
    forall g e le m t1 a1 v,
      mem_id g gobj_ids = true ->
      e ! g = None ->
      MWF m ->
      eval_expr (lp_ge lp) e le m (Evar g (Tpointer t1 a1)) v ->
      forall b o, v = Vptr b o -> SafeB b.
  Proof.
    intros g e le m t1 a1 v Hg He HM Hev b o Hbo.
    apply RealFrameValue.eval_expr_Evar_load in Hev
      as (loc & ofs & bf & Hlv & Hd).
    apply RealFrameValue.eval_lvalue_Evar_global_loc in Hlv as [Hfs Hofs];
      [ | exact He ].
    subst ofs.
    inv Hd;
      try (match goal with Hac : access_mode _ = By_reference |- _ =>
             cbn in Hac; discriminate end);
      try (match goal with Hac : access_mode _ = By_copy |- _ =>
             cbn in Hac; discriminate end);
      try (match goal with Hlb : load_bitfield _ _ _ _ _ _ _ _ |- _ => inv Hlb end).
    match goal with
    | Hac : access_mode _ = By_value _,
      Hl : Mem.loadv _ _ _ = Some (Vptr b o) |- _ =>
        cbn in Hac; inv Hac; eapply HGlobObjRoot; eassumption
    end.
  Qed.

  (* the seed-Sset shape: gobj_seed_chk pins the temp and the Evar symbol
     (the pointer type is left existential -- only its pointer-ness matters). *)
  Lemma gobj_seed_shape : forall t id a,
      gobj_seed_chk t (Sset id a) = true ->
      id = t /\ exists t1 a1,
        a = Evar mario_actions_cutscene._sIntroWarpPipeObj (Tpointer t1 a1).
  Proof.
    intros t id a H. unfold gobj_seed_chk in H.
    destruct a as [ | | | | g gty | | | | | | | | | ]; try discriminate H.
    destruct gty as [ | | | | tt aa | | | | ]; try discriminate H.
    apply andb_prop in H as [Hid Hg'].
    apply Pos.eqb_eq in Hid. apply Pos.eqb_eq in Hg'.
    subst id g. split; [ reflexivity | ].
    exists tt, aa. reflexivity.
  Qed.

  (* ---- the MULTI-temp / MULTI-global generalization of gobj_seed_chk:     *)
  (* recognizes `Sset id (Evar g (Tpointer ..))` for ANY id in `ts` and ANY  *)
  (* g in gobj_ids (the end-cutscene leaves load sEndPeachObj / sEndRight-    *)
  (* ToadObj / sEndLeftToadObj into several distinct chase temps).  Consumed  *)
  (* by the eaw walker's seed arm via glob_obj_val (which is already general  *)
  (* over g in gobj_ids). *)
  Definition gobj_seed_chk2 (ts : list ident) (s : statement) : bool :=
    match s with
    | Sset id (Evar g (Tpointer _ _)) => mem_id id ts && mem_id g gobj_ids
    | _ => false
    end.

  Lemma gobj_seed_shape2 : forall ts id a,
      gobj_seed_chk2 ts (Sset id a) = true ->
      mem_id id ts = true /\
      exists g t1 a1, mem_id g gobj_ids = true /\ a = Evar g (Tpointer t1 a1).
  Proof.
    intros ts id a H. unfold gobj_seed_chk2 in H.
    destruct a as [ | | | | g gty | | | | | | | | | ]; try discriminate H.
    destruct gty as [ | | | | tt aa | | | | ]; try discriminate H.
    apply andb_prop in H as [Hid Hg].
    split; [ exact Hid | ]. exists g, tt, aa. split; [ exact Hg | reflexivity ].
  Qed.

  Lemma dfm_ids_rows : forall fid, mem_id fid dfm_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold dfm_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_sma | discriminate H ].
  Qed.
  Lemma dfm_sids_rows : forall fid, mem_id fid dfm_sids = true ->
      call_pres_act lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold dfm_sids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsmact | discriminate H ].
  Qed.
  Lemma dfm_oc_rows : forall fid, mem_id fid dfm_oc = true ->
      OutParamSurface.call_pres_ext_oc lp bm NoA MWF SafeB fid.
  Proof.
    intros fid H. unfold dfm_oc in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hocp_find_floor
      | discriminate H ].
  Qed.
  Lemma dfm_sc_rows : forall fid, mem_id fid dfm_sc = true ->
      OutParamSurface.call_pres_ext_sc lp bm NoA MWF SafeB fid.
  Proof.
    intros fid H. unfold dfm_sc in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hscp_v3f | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hscp_v3s | discriminate H ].
  Qed.

  (* whole-array local decay: `Evar pos (tarray tfloat 3)` as an rvalue
     hands back a pointer to the bound local block's base. *)
  Lemma dfm_pos_val :
    forall e le m lblk tyenv v,
      e ! C._pos = Some (lblk, tyenv) ->
      eval_expr (lp_ge lp) e le m (Evar C._pos (tarray tfloat 3)) v ->
      v = Vptr lblk Ptrofs.zero.
  Proof.
    intros e le m lblk tyenv v Hbind Hev.
    inv Hev.
    match goal with
    | Hlv : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv Hlv
    end;
      [ | match goal with
          | Hn : e ! C._pos = None |- _ => rewrite Hbind in Hn; discriminate Hn
          end ].
    match goal with
    | He : e ! C._pos = Some (?loc, _) |- _ =>
        assert (Hloc : loc = lblk) by congruence; subst loc
    end.
    match goal with
    | Hd : deref_loc _ _ lblk _ _ _ |- _ =>
        cbn [typeof] in Hd; apply array_decay_ptr in Hd; exact Hd
    end.
  Qed.

  (* ---- the special-call shape extraction (mirror of twl_sp_call_shape,
     three cases: rwc/ol, vec3f_copy/wl, vec3f_copy/w1). ---- *)
  Lemma dfm_pos_arg_shape : forall a, dfm_pos_arg a = true ->
      a = Evar C._pos (tarray tfloat 3).
  Proof.
    intros a H. unfold dfm_pos_arg in H.
    destruct a as [ | | | | lid aty | | | | | | | | | ]; try discriminate H.
    apply andb_prop in H as [Hlid Haty].
    apply Pos.eqb_eq in Hlid. subst lid.
    destruct (type_eq aty (tarray tfloat 3)); [ subst aty | discriminate Haty ].
    reflexivity.
  Qed.
  Lemma dfm_mpos_arg_shape : forall a, dfm_mpos_arg a = true ->
      a = Efield (Ederef (Etempvar C._m (tptr (Tstruct C._MarioState noattr)))
                    (Tstruct C._MarioState noattr)) C._pos (tarray tfloat 3).
  Proof.
    intros a H. unfold dfm_mpos_arg in H.
    destruct a as [ | | | | | | | | | | | einner fld faty | | ];
      try discriminate H.
    destruct einner as [ | | | | | | ebase sty | | | | | | | ];
      try discriminate H.
    destruct ebase as [ | | | | | p pty | | | | | | | | ]; try discriminate H.
    apply andb_prop in H as [H Hfaty].
    apply andb_prop in H as [H Hfld].
    apply andb_prop in H as [H Hsty].
    apply andb_prop in H as [Hp Hpty].
    apply Pos.eqb_eq in Hp. subst p.
    apply Pos.eqb_eq in Hfld. subst fld.
    destruct (type_eq pty (tptr (Tstruct C._MarioState noattr)));
      [ subst pty | discriminate Hpty ].
    destruct (type_eq sty (Tstruct C._MarioState noattr));
      [ subst sty | discriminate Hsty ].
    destruct (type_eq faty (tarray tfloat 3)); [ subst faty | discriminate Hfaty ].
    reflexivity.
  Qed.

  Lemma dfm_sp_call_shape :
    forall optid a al,
      dfm_sp_chk (Scall optid a al) = true ->
      optid = None /\
      ( (exists c1 t1 c2 t2,
           a = Evar C._resolve_and_return_wall_collisions dfm_rwc_fty /\
           al = Evar C._pos (tarray tfloat 3)
                :: Econst_single c1 t1 :: Econst_single c2 t2 :: nil)
        \/ (a = Evar C._vec3f_copy dfm_v3f_fty /\
            al = Evar C._pos (tarray tfloat 3)
                 :: Efield (Ederef (Etempvar C._m
                                      (tptr (Tstruct C._MarioState noattr)))
                             (Tstruct C._MarioState noattr))
                      C._pos (tarray tfloat 3) :: nil)
        \/ (a = Evar C._vec3f_copy dfm_v3f_fty /\
            al = Efield (Ederef (Etempvar C._m
                                   (tptr (Tstruct C._MarioState noattr)))
                          (Tstruct C._MarioState noattr))
                   C._pos (tarray tfloat 3)
                 :: Evar C._pos (tarray tfloat 3) :: nil) ).
  Proof.
    intros optid a al H.
    destruct optid as [t'|]; [ discriminate H | ].
    split; [ reflexivity | ].
    destruct a as [ | | | | cid fty | | | | | | | | | ]; try discriminate H.
    unfold dfm_sp_chk in H.
    apply orb_true_iff in H as [Hrwc | Hv].
    - left.
      apply andb_prop in Hrwc as [Hrwc Hal].
      apply andb_prop in Hrwc as [Hfid Hfty].
      apply Pos.eqb_eq in Hfid. subst cid.
      destruct (type_eq fty dfm_rwc_fty); [ subst fty | discriminate Hfty ].
      destruct al as [|a0 [|a1 [|a2 [|a3 al']]]]; try discriminate Hal.
      apply andb_prop in Hal as [Hal Hsg2].
      apply andb_prop in Hal as [Ha0 Hsg1].
      apply dfm_pos_arg_shape in Ha0.
      destruct a1 as [ | | c1 t1 | | | | | | | | | | | ]; try discriminate Hsg1.
      destruct a2 as [ | | c2 t2 | | | | | | | | | | | ]; try discriminate Hsg2.
      subst a0. exists c1, t1, c2, t2. split; reflexivity.
    - apply andb_prop in Hv as [Hv Hal].
      apply andb_prop in Hv as [Hfid Hfty].
      apply Pos.eqb_eq in Hfid. subst cid.
      destruct (type_eq fty dfm_v3f_fty); [ subst fty | discriminate Hfty ].
      destruct al as [|d0 [|d1 [|d2 al']]]; try discriminate Hal.
      apply orb_true_iff in Hal as [Hwl | Hw1].
      + right; left.
        apply andb_prop in Hwl as [H0 H1].
        apply dfm_pos_arg_shape in H0. apply dfm_mpos_arg_shape in H1.
        subst d0 d1. split; reflexivity.
      + right; right.
        apply andb_prop in Hw1 as [H0 H1].
        apply dfm_mpos_arg_shape in H0. apply dfm_pos_arg_shape in H1.
        subst d0 d1. split; reflexivity.
  Qed.

  (* a single float constant evaluates to its Vsingle value (refutes that a
     float-const arg could be a pointer in the rwc ol gate). *)
  Lemma dfm_single_val : forall e le m c ty v,
    eval_expr (lp_ge lp) e le m (Econst_single c ty) v -> v = Vsingle c.
  Proof.
    intros e le m c ty v H; inv H; [ reflexivity | ].
    match goal with
    | Hlv : eval_lvalue _ _ _ _ (Econst_single _ _) _ _ _ |- _ => inv Hlv
    end.
  Qed.

  (* m->pos as an rvalue decays By_reference to its base address Vptr bm 60,
     a safe 12-byte window (action cell @12 clear) -- the w1 gate's arg0.
     Local copy of AutomaticLeafSurface.pos_window_val with C idents. *)
  Lemma dfm_mpos_val :
    forall e le m v,
      (forall b o, le ! C._m = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero) ->
      eval_expr (lp_ge lp) e le m
        (Efield
           (Ederef (Etempvar C._m (tptr (Tstruct C._MarioState noattr)))
              (Tstruct C._MarioState noattr))
           C._pos (tarray tfloat 3)) v ->
      exists o, v = Vptr bm o /\ store_window_ok (Ptrofs.unsigned o) 12 = true.
  Proof.
    intros e le m v Htat Hev.
    assert (Hfo : field_offset (prog_comp_env mario.prog)
                    C._pos mario_state_members = OK (60, Full))
      by (vm_compute; reflexivity).
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

  (* the generic-subtree discharger: ONE wwalk_pres call, dfm census, with
     the wact=[_action] channel threaded (mirror of twl_generic). *)
  Lemma dfm_generic :
    forall s e le m0 tr le' m' out,
      (forall lid, mem_id lid dfm_lids = true ->
         exists lblk tyenv, e ! lid = Some (lblk, tyenv) /\
                            LocalVarsSurface.local_blk lp bm SafeB lblk) ->
      (forall g, mem_id g stored_globals = true -> e ! g = None) ->
      (forall g, mem_id g dfm_ids = true -> e ! g = None) ->
      (forall g, mem_id g (@nil ident) = true -> e ! g = None) ->
      (forall g, mem_id g dfm_sids = true -> e ! g = None) ->
      (forall g, mem_id g dfm_oc = true -> e ! g = None) ->
      (forall g, mem_id g dfm_sc = true -> e ! g = None) ->
      e ! interaction._gGlobalTimer = None ->
      wwalk_chk' dfm_lids dfm_oc nil dfm_sc nil nil false
        dfm_wact dfm_ids nil dfm_cact nil dfm_sids nil s = true ->
      (forall b o, le ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) ->
      act_inv dfm_wact le ->
      chase_inv SafeB dfm_cact le ->
      NoA m0 -> MWF m0 -> Mem.valid_block m0 bm ->
      action_sat not_tainted m0 bm ->
      exec_stmt function_entry2 (lp_ge lp) e le m0 s tr le' m' out ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\
      NoA m' /\
      (forall b o, le' ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) /\
      act_inv dfm_wact le' /\ chase_inv SafeB dfm_cact le'.
  Proof.
    intros s e le m0 tr le' m' out Hlocal Hub_g Hub_i Hub_x Hub_s Hub_oc
           Hub_sc Hubgt Hchk Htat Hact Hch HN HM HV HS Hexec.
    destruct (wwalk_pres lp LO_mario bm NoA MWF HNoA_of_MWF HMWF_window
                HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot HMWF_chase
                HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
                false dfm_wact dfm_ids nil dfm_cact nil dfm_sids nil
                dfm_lids dfm_oc nil dfm_sc nil nil
                dfm_ids_rows
                (fun fid HH => match Bool.diff_false_true HH with end)
                (fun fid HH => match Bool.diff_false_true HH with end)
                (fun fid HH => call_pres_act_weaken (dfm_sids_rows fid HH))
                (fun fid HH => match Bool.diff_false_true HH with end)
                dfm_oc_rows
                (fun fid HH => match Bool.diff_false_true HH with end)
                dfm_sc_rows
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

  (* the hybrid walk prover: exec-derivation induction.  Generic subtrees
     go to dfm_generic wholesale; the three special call sites get their
     gate discharges (rwc/ol, vec3f_copy/wl, vec3f_copy/w1). *)
  Lemma dfm_pres_stmt :
    forall s e le m0 tr le' m' out,
      (forall lid, mem_id lid dfm_lids = true ->
         exists lblk tyenv, e ! lid = Some (lblk, tyenv) /\
                            LocalVarsSurface.local_blk lp bm SafeB lblk) ->
      exec_stmt function_entry2 (lp_ge lp) e le m0 s tr le' m' out ->
      (forall g, mem_id g stored_globals = true -> e ! g = None) ->
      (forall g, mem_id g dfm_ids = true -> e ! g = None) ->
      (forall g, mem_id g (@nil ident) = true -> e ! g = None) ->
      (forall g, mem_id g dfm_sids = true -> e ! g = None) ->
      (forall g, mem_id g dfm_oc = true -> e ! g = None) ->
      (forall g, mem_id g dfm_sc = true -> e ! g = None) ->
      e ! C._resolve_and_return_wall_collisions = None ->
      e ! C._vec3f_copy = None ->
      e ! interaction._gGlobalTimer = None ->
      dfm_chk s = true ->
      (forall b o, le ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) ->
      act_inv dfm_wact le ->
      chase_inv SafeB dfm_cact le ->
      NoA m0 -> MWF m0 -> Mem.valid_block m0 bm ->
      action_sat not_tainted m0 bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\
      NoA m' /\
      (forall b o, le' ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) /\
      act_inv dfm_wact le' /\ chase_inv SafeB dfm_cact le'.
  Proof.
    intros s e le m0 tr le' m' out Hlocal Hexec.
    induction Hexec;
      intros Hub_g Hub_i Hub_x Hub_s Hub_oc Hub_sc Hrwc Hvc Hubgt
             Hchk Htat Hact Hch HN HM HV HS.
    - (* Sskip *)
      exact (conj HV (conj HS (conj HM (conj HN
               (conj Htat (conj Hact Hch)))))).
    - (* Sassign: generic only *)
      cbn [dfm_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp];
        [ | cbn [dfm_sp_chk] in Hsp; discriminate Hsp ].
      eapply (dfm_generic _ _ _ _ _ _ _ _ Hlocal Hub_g Hub_i Hub_x Hub_s
                Hub_oc Hub_sc Hubgt Hg Htat Hact Hch HN HM HV HS);
        eapply exec_Sassign; eauto.
    - (* Sset: generic only *)
      cbn [dfm_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp];
        [ | cbn [dfm_sp_chk] in Hsp; discriminate Hsp ].
      eapply (dfm_generic _ _ _ _ _ _ _ _ Hlocal Hub_g Hub_i Hub_x Hub_s
                Hub_oc Hub_sc Hubgt Hg Htat Hact Hch HN HM HV HS);
        eapply exec_Sset; eauto.
    - (* Scall: generic, or one of the THREE special sites *)
      cbn [dfm_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp].
      { eapply (dfm_generic _ _ _ _ _ _ _ _ Hlocal Hub_g Hub_i Hub_x Hub_s
                  Hub_oc Hub_sc Hubgt Hg Htat Hact Hch HN HM HV HS);
          eapply exec_Scall; eauto. }
      destruct (dfm_sp_call_shape _ _ _ Hsp) as [-> Hcase].
      cbn [set_opttemp].
      assert (Hc0 : LocalVarsSurface.carried bm NoA MWF m)
        by (split; [ exact HV | split; [ exact HS
                   | split; [ exact HM | exact HN ] ] ]).
      destruct Hcase
        as [ (c1 & t1 & c2 & t2 & -> & ->) | [ (-> & ->) | (-> & ->) ] ].
      + (* rwc(pos, c, c): the ol gate *)
        unfold dfm_rwc_fty in *.
        assert (Hex : exec_stmt function_entry2 (lp_ge lp) e le m
                        (Scall None
                           (Evar C._resolve_and_return_wall_collisions
                              (Tfunction (tptr tfloat :: tfloat :: tfloat :: nil)
                                 (tptr (Tstruct C._Surface noattr)) cc_default))
                           (Evar C._pos (tarray tfloat 3)
                            :: Econst_single c1 t1 :: Econst_single c2 t2 :: nil))
                        t (set_opttemp None vres le) m' Out_normal)
          by (eapply exec_Scall; eauto).
        assert (Hgate : forall vargs1,
            eval_exprlist (lp_ge lp) e le m
              (Evar C._pos (tarray tfloat 3)
               :: Econst_single c1 t1 :: Econst_single c2 t2 :: nil)
              (tptr tfloat :: tfloat :: tfloat :: nil) vargs1 ->
            OutParamSurface.args_all_local lp bm SafeB vargs1).
        { intros vargs1 Hvl.
          destruct (Hlocal C._pos eq_refl) as (lblk & tyenv & Hbind & Hlb).
          inversion Hvl as [ | x1 bl1 ty1 tyl1 v1a v2a vl1 Hev_a Hsc_a Htl1 ];
            subst; clear Hvl.
          inversion Htl1 as [ | x2 bl2 ty2 tyl2 v1b v2b vl2 Hev_b Hsc_b Htl2 ];
            subst; clear Htl1.
          inversion Htl2 as [ | x3 bl3 ty3 tyl3 v1c v2c vl3 Hev_c Hsc_c Htl3 ];
            subst; clear Htl2.
          inversion Htl3; subst; clear Htl3.
          pose proof (dfm_pos_val _ _ _ _ _ _ Hbind Hev_a) as Ev0. subst v1a.
          apply dfm_single_val in Hev_b; subst v1b.
          apply dfm_single_val in Hev_c; subst v1c.
          intros bb oo Hin; cbn in Hin.
          destruct Hin as [E | [E | [E | []]]]; subst;
            [ apply RealFrameValue.sem_cast_ptr_result_inv in Hsc_a;
              injection Hsc_a as <- <-; exact Hlb
            | apply RealFrameValue.sem_cast_ptr_result_inv in Hsc_b;
              discriminate Hsc_b
            | apply RealFrameValue.sem_cast_ptr_result_inv in Hsc_c;
              discriminate Hsc_c ]. }
        destruct (OutParamSurface.ol_scall_pres lp bm NoA MWF SafeB None
                    C._resolve_and_return_wall_collisions
                    (tptr tfloat :: tfloat :: tfloat :: nil)
                    (tptr (Tstruct C._Surface noattr)) cc_default
                    (Evar C._pos (tarray tfloat 3)
                     :: Econst_single c1 t1 :: Econst_single c2 t2 :: nil)
                    e le m _ _ m' _
                    Hrwc Hocp_resolve Hgate Hex Hc0) as (Hc' & _).
        destruct Hc' as (HV' & HS' & HM' & HN').
        exact (conj HV' (conj HS' (conj HM' (conj HN'
                 (conj Htat (conj Hact Hch)))))).
      + (* vec3f_copy(pos, m->pos): the dst-local wl gate *)
        unfold dfm_v3f_fty in *.
        assert (Hex : exec_stmt function_entry2 (lp_ge lp) e le m
                        (Scall None
                           (Evar C._vec3f_copy
                              (Tfunction (tptr tfloat :: tptr tfloat :: nil)
                                 (tptr tvoid) cc_default))
                           (Evar C._pos (tarray tfloat 3)
                            :: Efield (Ederef (Etempvar C._m
                                                 (tptr (Tstruct C._MarioState
                                                          noattr)))
                                        (Tstruct C._MarioState noattr))
                                 C._pos (tarray tfloat 3) :: nil))
                        t (set_opttemp None vres le) m' Out_normal)
          by (eapply exec_Scall; eauto).
        assert (Hgate : forall vargs1,
            eval_exprlist (lp_ge lp) e le m
              (Evar C._pos (tarray tfloat 3)
               :: Efield (Ederef (Etempvar C._m
                                    (tptr (Tstruct C._MarioState noattr)))
                           (Tstruct C._MarioState noattr))
                    C._pos (tarray tfloat 3) :: nil)
              (tptr tfloat :: tptr tfloat :: nil) vargs1 ->
            OutParamSurface.arg0_local lp bm SafeB vargs1).
        { intros vargs1 Hvl.
          destruct (Hlocal C._pos eq_refl) as (lblk & tyenv & Hbind & Hlb).
          inversion Hvl as [ | x1 bl1 ty1 tyl1 v1a v2a vl1 Hev_a Hsc_a Htl1 ];
            subst; clear Hvl.
          pose proof (dfm_pos_val _ _ _ _ _ _ Hbind Hev_a) as Ev0. subst v1a.
          cbn in Hsc_a. injection Hsc_a as <-.
          red. exists lblk, Ptrofs.zero, vl1. split; [ reflexivity | exact Hlb ]. }
        destruct (OutParamSurface.wl_scall_pres lp bm NoA MWF SafeB None
                    C._vec3f_copy (tptr tfloat :: tptr tfloat :: nil)
                    (tptr tvoid) cc_default
                    (Evar C._pos (tarray tfloat 3)
                     :: Efield (Ederef (Etempvar C._m
                                          (tptr (Tstruct C._MarioState noattr)))
                                 (Tstruct C._MarioState noattr))
                          C._pos (tarray tfloat 3) :: nil)
                    e le m _ _ m' _
                    Hvc Hwlcp_v3f Hgate Hex Hc0) as (Hc' & _).
        destruct Hc' as (HV' & HS' & HM' & HN').
        exact (conj HV' (conj HS' (conj HM' (conj HN'
                 (conj Htat (conj Hact Hch)))))).
      + (* vec3f_copy(m->pos, pos): the dst-window w1 gate *)
        unfold dfm_v3f_fty in *.
        assert (Hex : exec_stmt function_entry2 (lp_ge lp) e le m
                        (Scall None
                           (Evar C._vec3f_copy
                              (Tfunction (tptr tfloat :: tptr tfloat :: nil)
                                 (tptr tvoid) cc_default))
                           (Efield (Ederef (Etempvar C._m
                                              (tptr (Tstruct C._MarioState
                                                       noattr)))
                                      (Tstruct C._MarioState noattr))
                              C._pos (tarray tfloat 3)
                            :: Evar C._pos (tarray tfloat 3) :: nil))
                        t (set_opttemp None vres le) m' Out_normal)
          by (eapply exec_Scall; eauto).
        assert (Hgate : forall vargs1,
            eval_exprlist (lp_ge lp) e le m
              (Efield (Ederef (Etempvar C._m
                                 (tptr (Tstruct C._MarioState noattr)))
                        (Tstruct C._MarioState noattr))
                 C._pos (tarray tfloat 3)
               :: Evar C._pos (tarray tfloat 3) :: nil)
              (tptr tfloat :: tptr tfloat :: nil) vargs1 ->
            OutParamSurface.arg0_window bm vargs1).
        { intros vargs1 Hvl.
          inversion Hvl as [ | x1 bl1 ty1 tyl1 v1a v2a vl1 Hev_a Hsc_a Htl1 ];
            subst; clear Hvl.
          destruct (dfm_mpos_val _ _ _ _ Htat Hev_a) as (o0 & Ev0 & Hwin0).
          subst v1a. cbn in Hsc_a. injection Hsc_a as <-.
          red. exists o0, vl1. split; [ reflexivity | exact Hwin0 ]. }
        destruct (OutParamSurface.w1_scall_pres lp bm NoA MWF None
                    C._vec3f_copy (tptr tfloat :: tptr tfloat :: nil)
                    (tptr tvoid) cc_default
                    (Efield (Ederef (Etempvar C._m
                                       (tptr (Tstruct C._MarioState noattr)))
                              (Tstruct C._MarioState noattr))
                       C._pos (tarray tfloat 3)
                     :: Evar C._pos (tarray tfloat 3) :: nil)
                    e le m _ _ m' _
                    Hvc Hw1cp_v3f Hgate Hex Hc0) as (Hc' & _).
        destruct Hc' as (HV' & HS' & HM' & HN').
        exact (conj HV' (conj HS' (conj HM' (conj HN'
                 (conj Htat (conj Hact Hch)))))).
    - (* Sbuiltin: rejected by both arms *)
      cbn [dfm_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp];
        [ cbn [wwalk_chk'] in Hg; discriminate Hg
        | cbn [dfm_sp_chk] in Hsp; discriminate Hsp ].
    - (* Sseq_1 *)
      cbn [dfm_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp].
      { eapply (dfm_generic _ _ _ _ _ _ _ _ Hlocal Hub_g Hub_i Hub_x Hub_s
                  Hub_oc Hub_sc Hubgt Hg Htat Hact Hch HN HM HV HS);
          eapply exec_Sseq_1; eauto. }
      apply andb_prop in Hsp as [H1 H2].
      destruct (IHHexec1 Hlocal Hub_g Hub_i Hub_x Hub_s Hub_oc Hub_sc Hrwc Hvc
                  Hubgt H1 Htat Hact Hch HN HM HV HS)
        as (HV1 & HS1 & HM1 & HN1 & Htat1 & Hact1 & Hch1).
      exact (IHHexec2 Hlocal Hub_g Hub_i Hub_x Hub_s Hub_oc Hub_sc Hrwc Hvc
               Hubgt H2 Htat1 Hact1 Hch1 HN1 HM1 HV1 HS1).
    - (* Sseq_2 *)
      cbn [dfm_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp].
      { eapply (dfm_generic _ _ _ _ _ _ _ _ Hlocal Hub_g Hub_i Hub_x Hub_s
                  Hub_oc Hub_sc Hubgt Hg Htat Hact Hch HN HM HV HS);
          eapply exec_Sseq_2; eauto. }
      apply andb_prop in Hsp as [H1 _].
      exact (IHHexec Hlocal Hub_g Hub_i Hub_x Hub_s Hub_oc Hub_sc Hrwc Hvc
               Hubgt H1 Htat Hact Hch HN HM HV HS).
    - (* Sifthenelse *)
      cbn [dfm_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp].
      { eapply (dfm_generic _ _ _ _ _ _ _ _ Hlocal Hub_g Hub_i Hub_x Hub_s
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
      cbn [dfm_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp];
        [ | cbn [dfm_sp_chk] in Hsp; discriminate Hsp ].
      eapply (dfm_generic _ _ _ _ _ _ _ _ Hlocal Hub_g Hub_i Hub_x Hub_s
                Hub_oc Hub_sc Hubgt Hg Htat Hact Hch HN HM HV HS);
        eapply exec_Sloop_stop1; eauto.
    - (* Sloop stop2: generic only *)
      cbn [dfm_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp];
        [ | cbn [dfm_sp_chk] in Hsp; discriminate Hsp ].
      eapply (dfm_generic _ _ _ _ _ _ _ _ Hlocal Hub_g Hub_i Hub_x Hub_s
                Hub_oc Hub_sc Hubgt Hg Htat Hact Hch HN HM HV HS);
        eapply exec_Sloop_stop2; eauto.
    - (* Sloop loop: generic only *)
      cbn [dfm_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp];
        [ | cbn [dfm_sp_chk] in Hsp; discriminate Hsp ].
      eapply (dfm_generic _ _ _ _ _ _ _ _ Hlocal Hub_g Hub_i Hub_x Hub_s
                Hub_oc Hub_sc Hubgt Hg Htat Hact Hch HN HM HV HS);
        eapply exec_Sloop_loop; eauto.
    - (* Sswitch: generic only *)
      cbn [dfm_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp];
        [ | cbn [dfm_sp_chk] in Hsp; discriminate Hsp ].
      eapply (dfm_generic _ _ _ _ _ _ _ _ Hlocal Hub_g Hub_i Hub_x Hub_s
                Hub_oc Hub_sc Hubgt Hg Htat Hact Hch HN HM HV HS);
        eapply exec_Sswitch; eauto.
  Qed.

  (* act_debug_free_move is Internal in mario_actions_cutscene.prog *)
  Example dfm_pin :
    (prog_defmap mario_actions_cutscene.prog) ! C._act_debug_free_move
    = Some (Gfun (Internal C.f_act_debug_free_move)).
  Proof. vm_compute. reflexivity. Qed.

  (* THE LEAF: fn_vars = [_surf; _pos], 1 param _m; hybrid body -> dfm_pres_stmt.
     (dfm_walk above is the NON-VACUITY probe.) *)
  Lemma dfm_pres : body_pres lp NoA MWF bm C.f_act_debug_free_move.
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
    assert (Hc0 : LocalVarsSurface.carried bm NoA MWF m0)
      by (split; [ exact HV | split; [ exact HS
                 | split; [ exact HM | exact HN ] ] ]).
    pose proof (LocalVarsSurface.alloc_variables_carried
                  bm NoA MWF HMWF_alloc HNoA_of_MWF
                  _ _ _ _ _ _ Halloc Hc0) as Hca.
    destruct Hca as (HVa & HSa & HMa & HNa).
    pose proof (LocalVarsSurface.alloc_variables_hlocal lp bm SafeB m0 _ eloc _
                  dfm_lids Halloc HV (HSafeValid m0 HM) (HGlobValid m0 HM)
                  ltac:(intros lid Hl; unfold dfm_lids, mem_id in Hl;
                        cbn [existsb] in Hl;
                        apply Bool.orb_true_iff in Hl;
                        destruct Hl as [Hm1 | Hl];
                        [ apply Pos.eqb_eq in Hm1; subst lid;
                          vm_compute; right; left; reflexivity | ];
                        apply Bool.orb_true_iff in Hl;
                        destruct Hl as [Hm1 | Hl];
                        [ apply Pos.eqb_eq in Hm1; subst lid;
                          vm_compute; left; reflexivity
                        | discriminate Hl ]))
      as Hlocal.
    (* the Mario-head param shape + entry env facts *)
    assert (Hps : match fn_params C.f_act_debug_free_move with
                  | (i, ty) :: ps =>
                      (Pos.eqb i mario_actions_airborne._m
                       && proj_sumbool (type_eq ty tyMSp)
                       && negb (mem_id mario_actions_airborne._m
                                  (map fst ps)))%bool
                  | nil => false
                  end = true) by (vm_compute; reflexivity).
    assert (Hnpa : forallb
              (fun t' => negb (mem_id t'
                 (map fst (fn_params C.f_act_debug_free_move))))
              dfm_wact = true) by (vm_compute; reflexivity).
    assert (Hnpc : forallb
              (fun t' => negb (mem_id t'
                 (map fst (fn_params C.f_act_debug_free_move))))
              dfm_cact = true) by (vm_compute; reflexivity).
    assert (Hmarg : marg_ok bm vargs0)
      by (apply Hmargf; vm_compute; reflexivity).
    destruct (fn_params C.f_act_debug_free_move)
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
        assert (Hact0 : act_inv dfm_wact le1)
          by (intros t' Hmem' x Hg';
              pose proof (forallb_negb_mem_id _ _ _ Hnpa Hmem') as Hf';
              unfold mem_id in Hf'; cbn [map fst existsb] in Hf';
              apply orb_false_iff in Hf' as [Hne_m' Hnps];
              rewrite (bind_params_other _ _ _ _ _ Hbind' Hnps) in Hg';
              rewrite PTree.gso in Hg'
                by (intro EE; rewrite EE, Pos.eqb_refl in Hne_m';
                    discriminate Hne_m');
              pose proof (create_undef_temps_val _ _ _ Hg') as EE;
              rewrite EE; unfold untainted_scalar; left; reflexivity);
        assert (Hch0 : chase_inv SafeB dfm_cact le1)
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
      rewrite (LocalVarsSurface.alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc g)
        by (intro Hin; vm_compute in Hin;
            destruct Hin as [E | [E | []]]; subst g;
            vm_compute in Hg; discriminate Hg).
      apply PTree.gempty. }
    assert (Hub_i : forall g, mem_id g dfm_ids = true -> eloc ! g = None).
    { intros g Hg.
      rewrite (LocalVarsSurface.alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc g)
        by (intro Hin; vm_compute in Hin;
            destruct Hin as [E | [E | []]]; subst g;
            vm_compute in Hg; discriminate Hg).
      apply PTree.gempty. }
    assert (Hub_x : forall g, mem_id g (@nil ident) = true -> eloc ! g = None).
    { intros g Hg. discriminate Hg. }
    assert (Hub_s : forall g, mem_id g dfm_sids = true -> eloc ! g = None).
    { intros g Hg.
      rewrite (LocalVarsSurface.alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc g)
        by (intro Hin; vm_compute in Hin;
            destruct Hin as [E | [E | []]]; subst g;
            vm_compute in Hg; discriminate Hg).
      apply PTree.gempty. }
    assert (Hub_oc : forall g, mem_id g dfm_oc = true -> eloc ! g = None).
    { intros g Hg.
      rewrite (LocalVarsSurface.alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc g)
        by (intro Hin; vm_compute in Hin;
            destruct Hin as [E | [E | []]]; subst g;
            vm_compute in Hg; discriminate Hg).
      apply PTree.gempty. }
    assert (Hub_sc : forall g, mem_id g dfm_sc = true -> eloc ! g = None).
    { intros g Hg.
      rewrite (LocalVarsSurface.alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc g)
        by (intro Hin; vm_compute in Hin;
            destruct Hin as [E | [E | []]]; subst g;
            vm_compute in Hg; discriminate Hg).
      apply PTree.gempty. }
    assert (Hrwc : eloc ! C._resolve_and_return_wall_collisions = None).
    { rewrite (LocalVarsSurface.alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc
                 C._resolve_and_return_wall_collisions)
        by (intro Hin; vm_compute in Hin;
            destruct Hin as [E | [E | []]]; discriminate E).
      apply PTree.gempty. }
    assert (Hvc : eloc ! C._vec3f_copy = None).
    { rewrite (LocalVarsSurface.alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc
                 C._vec3f_copy)
        by (intro Hin; vm_compute in Hin;
            destruct Hin as [E | [E | []]]; discriminate E).
      apply PTree.gempty. }
    assert (Hub_gt : eloc ! interaction._gGlobalTimer = None).
    { rewrite (LocalVarsSurface.alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc
                 interaction._gGlobalTimer)
        by (intro Hin; vm_compute in Hin;
            destruct Hin as [E | [E | []]]; discriminate E).
      apply PTree.gempty. }
    destruct (dfm_pres_stmt _ _ _ _ _ _ _ _ Hlocal Hbody
                Hub_g Hub_i Hub_x Hub_s Hub_oc Hub_sc Hrwc Hvc Hub_gt
                dfm_walk Htat0 Hact0 Hch0 HNa HMa HVa HSa)
      as (HVb & HSb & HMb & HNb & _ & _ & _).
    pose proof (LocalVarsSurface.blocks_of_env_bm lp bm m0 _ eloc _ Halloc HV) as Hforall.
    pose proof (LocalVarsSurface.free_list_carried_bm bm NoA MWF HMWF_free HNoA_of_MWF
                  (blocks_of_env (lp_ge lp) eloc) _ mF Hforall Hfree
                  (conj HVb (conj HSb (conj HMb HNb))))
      as (HVf & HSf & HMf & HNf).
    exact (conj HVf (conj HSf HMf)).
  Qed.

  (* ==================================================================== *)
  (* GLOB-OBJ store-THROUGH leaves (raise_pipe / lower_pipe).  A bespoke    *)
  (* hybrid walker (dfm precedent): the ONE special site is the glob-obj    *)
  (* SEED `Sset t'5 (Evar sIntroWarpPipeObj)`, which the generic engine     *)
  (* rejects (an Evar-global load into a cact temp is not a chase-root      *)
  (* load).  The seed arm re-establishes chase_inv [t'5] via glob_obj_seed; *)
  (* the float store THROUGH t'5 then walks GENERICALLY (chase_store_chk,   *)
  (* with nonptr_scalar tfloat laundering the value).  Every other site --  *)
  (* the scratch glob-obj SEEDS (read-only, feed external args), the loads, *)
  (* the window stores, the externals, the marg calls -- is generic. ---- *)
  Definition rzp_cact : list ident := mario_actions_cutscene._t'5 :: nil.
  Definition rzp_ids : list ident :=
    mario_actions_cutscene._advance_cutscene_step :: nil.
  Definition rzp_xids : list ident :=
    mario_actions_cutscene._camera_approach_f32_symmetric :: mario._play_sound :: nil.

  Definition rzp_gen (s : statement) : bool :=
    wwalk_chk' nil nil nil nil nil nil false
      nil rzp_ids nil rzp_cact rzp_xids nil nil s.

  (* (gobj_seed_chk is defined up with glob_obj_val; the scratch seeds
     t'6/t'4 land in NO census, so rzp_gen auto-accepts them.) *)
  Fixpoint rzp_chk (s : statement) : bool :=
    rzp_gen s
    || match s with
       | Ssequence s1 s2 => rzp_chk s1 && rzp_chk s2
       | Sifthenelse _ s1 s2 => rzp_chk s1 && rzp_chk s2
       | _ => gobj_seed_chk mario_actions_cutscene._t'5 s
       end.

  Example rzp_walk :
    rzp_chk (fn_body mario_actions_cutscene.f_intro_cutscene_raise_pipe) = true.
  Proof. vm_compute. reflexivity. Qed.

  Lemma rzp_ids_rows : forall fid, mem_id fid rzp_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold rzp_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact cut_acs_row | discriminate H ].
  Qed.
  Lemma rzp_xids_rows : forall fid, mem_id fid rzp_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold rzp_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_caf | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_psound | discriminate H ].
  Qed.

  (* the generic-subtree discharger: ONE wwalk_pres call with the rzp census
     (ids = advance_cutscene_step; xids = camera_approach / play_sound;
     cact = [t'5]; everything else nil).  Mirror of dfm_generic. *)
  Lemma rzp_generic :
    forall s e le m0 tr le' m' out,
      (forall g, mem_id g stored_globals = true -> e ! g = None) ->
      (forall g, mem_id g rzp_ids = true -> e ! g = None) ->
      (forall g, mem_id g rzp_xids = true -> e ! g = None) ->
      e ! interaction._gGlobalTimer = None ->
      rzp_gen s = true ->
      (forall b o, le ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) ->
      chase_inv SafeB rzp_cact le ->
      NoA m0 -> MWF m0 -> Mem.valid_block m0 bm ->
      action_sat not_tainted m0 bm ->
      exec_stmt function_entry2 (lp_ge lp) e le m0 s tr le' m' out ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\
      NoA m' /\
      (forall b o, le' ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) /\
      chase_inv SafeB rzp_cact le'.
  Proof.
    intros s e le m0 tr le' m' out Hub_g Hub_i Hub_x Hubgt Hchk Htat Hch
           HN HM HV HS Hexec.
    destruct (wwalk_pres lp LO_mario bm NoA MWF HNoA_of_MWF HMWF_window
                HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot HMWF_chase
                HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
                false nil rzp_ids nil rzp_cact rzp_xids nil nil
                nil nil nil nil nil nil
                rzp_ids_rows
                (fun fid HH => match Bool.diff_false_true HH with end)
                rzp_xids_rows
                (fun fid HH => match Bool.diff_false_true HH with end)
                (fun fid HH => match Bool.diff_false_true HH with end)
                (fun fid HH => match Bool.diff_false_true HH with end)
                (fun fid HH => match Bool.diff_false_true HH with end)
                (fun fid HH => match Bool.diff_false_true HH with end)
                (fun fid HH => match Bool.diff_false_true HH with end)
                s e le m0 tr le' m' out
                (fun HH => match HH eq_refl with end)
                (fun lid HH => match Bool.diff_false_true HH with end)
                Hexec
                Hub_g Hub_i
                (fun g HH => match Bool.diff_false_true HH with end)
                Hub_x
                (fun g HH => match Bool.diff_false_true HH with end)
                (fun g HH => match Bool.diff_false_true HH with end)
                (fun g HH => match Bool.diff_false_true HH with end)
                (fun g HH => match Bool.diff_false_true HH with end)
                (fun g HH => match Bool.diff_false_true HH with end)
                (fun g HH => match Bool.diff_false_true HH with end)
                Hubgt
                Hchk Htat
                (fun t HH => match Bool.diff_false_true HH with end)
                Hch
                (fun t HH => match Bool.diff_false_true HH with end)
                HN HM HV HS)
      as (HV' & HS' & HM' & HN' & Htat' & _ & Hch' & _ & _).
    exact (conj HV' (conj HS' (conj HM' (conj HN' (conj Htat' Hch'))))).
  Qed.

  (* the hybrid walk prover: exec-derivation induction.  Generic subtrees go
     to rzp_generic wholesale; the ONE special site is the glob-obj SEED
     `Sset t'5 (Evar sIntroWarpPipeObj)`, which establishes chase_inv [t'5]
     via glob_obj_val (so the float store THROUGH t'5 then walks generically). *)
  Lemma rzp_pres_stmt :
    forall s e le m0 tr le' m' out,
      exec_stmt function_entry2 (lp_ge lp) e le m0 s tr le' m' out ->
      (forall g, mem_id g stored_globals = true -> e ! g = None) ->
      (forall g, mem_id g rzp_ids = true -> e ! g = None) ->
      (forall g, mem_id g rzp_xids = true -> e ! g = None) ->
      e ! interaction._gGlobalTimer = None ->
      e ! mario_actions_cutscene._sIntroWarpPipeObj = None ->
      rzp_chk s = true ->
      (forall b o, le ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) ->
      chase_inv SafeB rzp_cact le ->
      NoA m0 -> MWF m0 -> Mem.valid_block m0 bm ->
      action_sat not_tainted m0 bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\
      NoA m' /\
      (forall b o, le' ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) /\
      chase_inv SafeB rzp_cact le'.
  Proof.
    intros s e le m0 tr le' m' out Hexec.
    induction Hexec;
      intros Hub_g Hub_i Hub_x Hubgt Hub_seed Hchk Htat Hch HN HM HV HS.
    - (* Sskip *)
      exact (conj HV (conj HS (conj HM (conj HN (conj Htat Hch))))).
    - (* Sassign: generic only *)
      cbn [rzp_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp];
        [ | cbn [gobj_seed_chk] in Hsp; discriminate Hsp ].
      eapply (rzp_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hubgt Hg
                Htat Hch HN HM HV HS);
        eapply exec_Sassign; eauto.
    - (* Sset: generic OR the glob-obj seed *)
      cbn [rzp_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp].
      { eapply (rzp_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hubgt Hg
                  Htat Hch HN HM HV HS);
          eapply exec_Sset; eauto. }
      (* the SEED arm: glob_obj_val gives the loaded value SafeB-if-ptr *)
      apply gobj_seed_shape in Hsp as [Hid Hex]. subst id.
      destruct Hex as (t1 & a1 & Ha). subst a.
      pose proof (glob_obj_val mario_actions_cutscene._sIntroWarpPipeObj
                    e le m t1 a1 v ltac:(vm_compute; reflexivity) Hub_seed HM H)
        as Hvsafe.
      split; [ exact HV | split; [ exact HS | split; [ exact HM |
        split; [ exact HN | split ] ] ] ].
      + intros b o Hb. rewrite PTree.gso in Hb by (intro EE; discriminate EE).
        exact (Htat b o Hb).
      + intros t Htmem b o Hb.
        unfold rzp_cact in Htmem. cbn [mem_id existsb] in Htmem.
        apply orb_true_iff in Htmem as [Heq | Hf]; [ | discriminate Hf ].
        apply Pos.eqb_eq in Heq. subst t.
        rewrite PTree.gss in Hb. injection Hb as Hb'.
        exact (Hvsafe b o Hb').
    - (* Scall: generic only *)
      cbn [rzp_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp];
        [ | cbn [gobj_seed_chk] in Hsp; discriminate Hsp ].
      eapply (rzp_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hubgt Hg
                Htat Hch HN HM HV HS);
        eapply exec_Scall; eauto.
    - (* Sbuiltin: rejected by both arms *)
      cbn [rzp_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp];
        [ cbn [rzp_gen wwalk_chk'] in Hg; discriminate Hg
        | cbn [gobj_seed_chk] in Hsp; discriminate Hsp ].
    - (* Sseq_1 *)
      cbn [rzp_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp].
      { eapply (rzp_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hubgt Hg
                  Htat Hch HN HM HV HS);
          eapply exec_Sseq_1; eauto. }
      apply andb_prop in Hsp as [H1 H2].
      destruct (IHHexec1 Hub_g Hub_i Hub_x Hubgt Hub_seed H1 Htat Hch
                  HN HM HV HS)
        as (HV1 & HS1 & HM1 & HN1 & Htat1 & Hch1).
      exact (IHHexec2 Hub_g Hub_i Hub_x Hubgt Hub_seed H2 Htat1 Hch1
               HN1 HM1 HV1 HS1).
    - (* Sseq_2 *)
      cbn [rzp_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp].
      { eapply (rzp_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hubgt Hg
                  Htat Hch HN HM HV HS);
          eapply exec_Sseq_2; eauto. }
      apply andb_prop in Hsp as [H1 _].
      exact (IHHexec Hub_g Hub_i Hub_x Hubgt Hub_seed H1 Htat Hch
               HN HM HV HS).
    - (* Sifthenelse *)
      cbn [rzp_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp].
      { eapply (rzp_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hubgt Hg
                  Htat Hch HN HM HV HS);
          eapply exec_Sifthenelse; eauto. }
      apply andb_prop in Hsp as [H1 H2].
      apply IHHexec; try assumption.
      destruct b; assumption.
    - (* Sreturn None *)
      exact (conj HV (conj HS (conj HM (conj HN (conj Htat Hch))))).
    - (* Sreturn (Some a) *)
      exact (conj HV (conj HS (conj HM (conj HN (conj Htat Hch))))).
    - (* Sbreak *)
      exact (conj HV (conj HS (conj HM (conj HN (conj Htat Hch))))).
    - (* Scontinue *)
      exact (conj HV (conj HS (conj HM (conj HN (conj Htat Hch))))).
    - (* Sloop stop1: generic only *)
      cbn [rzp_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp];
        [ | cbn [gobj_seed_chk] in Hsp; discriminate Hsp ].
      eapply (rzp_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hubgt Hg
                Htat Hch HN HM HV HS);
        eapply exec_Sloop_stop1; eauto.
    - (* Sloop stop2: generic only *)
      cbn [rzp_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp];
        [ | cbn [gobj_seed_chk] in Hsp; discriminate Hsp ].
      eapply (rzp_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hubgt Hg
                Htat Hch HN HM HV HS);
        eapply exec_Sloop_stop2; eauto.
    - (* Sloop loop: generic only *)
      cbn [rzp_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp];
        [ | cbn [gobj_seed_chk] in Hsp; discriminate Hsp ].
      eapply (rzp_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hubgt Hg
                Htat Hch HN HM HV HS);
        eapply exec_Sloop_loop; eauto.
    - (* Sswitch: generic only *)
      cbn [rzp_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp];
        [ | cbn [gobj_seed_chk] in Hsp; discriminate Hsp ].
      eapply (rzp_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hubgt Hg
                Htat Hch HN HM HV HS);
        eapply exec_Sswitch; eauto.
  Qed.

  (* raise_pipe is Internal in mario_actions_cutscene.prog *)
  Example rzp_pin :
    (prog_defmap mario_actions_cutscene.prog) ! C._intro_cutscene_raise_pipe
    = Some (Gfun (Internal C.f_intro_cutscene_raise_pipe)).
  Proof. vm_compute. reflexivity. Qed.

  (* THE LEAF entry wrapper: fn_vars = nil (so eloc = empty_env, no alloc,
     free_list is trivial); 1 param _m; hybrid body -> rzp_pres_stmt. *)
  Lemma rzp_pres : body_pres lp NoA MWF bm C.f_intro_cutscene_raise_pipe.
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
    assert (Hfvnil : fn_vars C.f_intro_cutscene_raise_pipe = nil) by reflexivity.
    rewrite Hfvnil in Halloc. inv Halloc.
    (* env is empty_env, mem unchanged; free_list over empty env is trivial *)
    assert (Hbe : blocks_of_env (lp_ge lp) empty_env = nil) by reflexivity.
    rewrite Hbe in Hfree. cbn [Mem.free_list] in Hfree. inv Hfree.
    (* param shape + marg facts (mirror dfm, no wact/act_inv) *)
    assert (Hps : match fn_params C.f_intro_cutscene_raise_pipe with
                  | (i, ty) :: ps =>
                      (Pos.eqb i mario_actions_airborne._m
                       && proj_sumbool (type_eq ty tyMSp)
                       && negb (mem_id mario_actions_airborne._m
                                  (map fst ps)))%bool
                  | nil => false
                  end = true) by (vm_compute; reflexivity).
    assert (Hnpc : forallb
              (fun t' => negb (mem_id t'
                 (map fst (fn_params C.f_intro_cutscene_raise_pipe))))
              rzp_cact = true) by (vm_compute; reflexivity).
    assert (Hmarg : marg_ok bm vargs0)
      by (apply Hmargf; vm_compute; reflexivity).
    destruct (fn_params C.f_intro_cutscene_raise_pipe)
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
        assert (Hch0 : chase_inv SafeB rzp_cact le1)
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
    (* unbound-global facts at empty_env (all trivial) *)
    assert (Hub_g : forall g, mem_id g stored_globals = true ->
                    empty_env ! g = None) by (intros; apply PTree.gempty).
    assert (Hub_i : forall g, mem_id g rzp_ids = true ->
                    empty_env ! g = None) by (intros; apply PTree.gempty).
    assert (Hub_x : forall g, mem_id g rzp_xids = true ->
                    empty_env ! g = None) by (intros; apply PTree.gempty).
    assert (Hubgt : empty_env ! interaction._gGlobalTimer = None)
      by (apply PTree.gempty).
    assert (Hub_seed :
              empty_env ! mario_actions_cutscene._sIntroWarpPipeObj = None)
      by (apply PTree.gempty).
    destruct (rzp_pres_stmt _ _ _ _ _ _ _ _ Hbody
                Hub_g Hub_i Hub_x Hubgt Hub_seed rzp_walk Htat0 Hch0 HN HM HV HS)
      as (HVb & HSb & HMb & _ & _ & _).
    exact (conj HVb (conj HSb HMb)).
  Qed.

  Lemma rzp_row :
    call_pres lp bm NoA MWF mario_actions_cutscene._intro_cutscene_raise_pipe.
  Proof.
    exact (call_pres_of_body lp bm NoA MWF HNoA_of_MWF
             mario_actions_cutscene.prog _ _ LO_cut rzp_pin rzp_pres).
  Qed.

  (* ==================================================================== *)
  (* lower_pipe: near-clone of raise_pipe.  Same glob-obj store-THROUGH    *)
  (* temp _t'5, same SEED special site (Sset _t'5 (Evar sIntroWarpPipeObj));*)
  (* differs only in census: ids = set_mario_animation / advance_cutscene_ *)
  (* step / stop_and_set_height_to_floor; xids = play_sound /              *)
  (* obj_mark_for_deletion.  (Scratch seeds t'8/t'6/t'2/t'4 land in NO     *)
  (* census, so lzp_gen auto-accepts them; the chase LOADS through them    *)
  (* into non-cact temps t'7/t'3 are auto-accepted Ssets.) ---- *)
  Definition lzp_cact : list ident := mario_actions_cutscene._t'5 :: nil.
  Definition lzp_ids : list ident :=
    mario._set_mario_animation
      :: mario_actions_cutscene._advance_cutscene_step
      :: mario_step._stop_and_set_height_to_floor :: nil.
  Definition lzp_xids : list ident :=
    mario._play_sound :: mario_actions_cutscene._obj_mark_for_deletion :: nil.

  Definition lzp_gen (s : statement) : bool :=
    wwalk_chk' nil nil nil nil nil nil false
      nil lzp_ids nil lzp_cact lzp_xids nil nil s.

  Fixpoint lzp_chk (s : statement) : bool :=
    lzp_gen s
    || match s with
       | Ssequence s1 s2 => lzp_chk s1 && lzp_chk s2
       | Sifthenelse _ s1 s2 => lzp_chk s1 && lzp_chk s2
       | _ => gobj_seed_chk mario_actions_cutscene._t'5 s
       end.

  Example lzp_walk :
    lzp_chk (fn_body mario_actions_cutscene.f_intro_cutscene_lower_pipe) = true.
  Proof. vm_compute. reflexivity. Qed.

  Lemma lzp_ids_rows : forall fid, mem_id fid lzp_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold lzp_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_sma | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact cut_acs_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_sashf | discriminate H ].
  Qed.
  Lemma lzp_xids_rows : forall fid, mem_id fid lzp_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold lzp_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_psound | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_omfd | discriminate H ].
  Qed.

  Lemma lzp_generic :
    forall s e le m0 tr le' m' out,
      (forall g, mem_id g stored_globals = true -> e ! g = None) ->
      (forall g, mem_id g lzp_ids = true -> e ! g = None) ->
      (forall g, mem_id g lzp_xids = true -> e ! g = None) ->
      e ! interaction._gGlobalTimer = None ->
      lzp_gen s = true ->
      (forall b o, le ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) ->
      chase_inv SafeB lzp_cact le ->
      NoA m0 -> MWF m0 -> Mem.valid_block m0 bm ->
      action_sat not_tainted m0 bm ->
      exec_stmt function_entry2 (lp_ge lp) e le m0 s tr le' m' out ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\
      NoA m' /\
      (forall b o, le' ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) /\
      chase_inv SafeB lzp_cact le'.
  Proof.
    intros s e le m0 tr le' m' out Hub_g Hub_i Hub_x Hubgt Hchk Htat Hch
           HN HM HV HS Hexec.
    destruct (wwalk_pres lp LO_mario bm NoA MWF HNoA_of_MWF HMWF_window
                HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot HMWF_chase
                HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
                false nil lzp_ids nil lzp_cact lzp_xids nil nil
                nil nil nil nil nil nil
                lzp_ids_rows
                (fun fid HH => match Bool.diff_false_true HH with end)
                lzp_xids_rows
                (fun fid HH => match Bool.diff_false_true HH with end)
                (fun fid HH => match Bool.diff_false_true HH with end)
                (fun fid HH => match Bool.diff_false_true HH with end)
                (fun fid HH => match Bool.diff_false_true HH with end)
                (fun fid HH => match Bool.diff_false_true HH with end)
                (fun fid HH => match Bool.diff_false_true HH with end)
                s e le m0 tr le' m' out
                (fun HH => match HH eq_refl with end)
                (fun lid HH => match Bool.diff_false_true HH with end)
                Hexec
                Hub_g Hub_i
                (fun g HH => match Bool.diff_false_true HH with end)
                Hub_x
                (fun g HH => match Bool.diff_false_true HH with end)
                (fun g HH => match Bool.diff_false_true HH with end)
                (fun g HH => match Bool.diff_false_true HH with end)
                (fun g HH => match Bool.diff_false_true HH with end)
                (fun g HH => match Bool.diff_false_true HH with end)
                (fun g HH => match Bool.diff_false_true HH with end)
                Hubgt
                Hchk Htat
                (fun t HH => match Bool.diff_false_true HH with end)
                Hch
                (fun t HH => match Bool.diff_false_true HH with end)
                HN HM HV HS)
      as (HV' & HS' & HM' & HN' & Htat' & _ & Hch' & _ & _).
    exact (conj HV' (conj HS' (conj HM' (conj HN' (conj Htat' Hch'))))).
  Qed.

  Lemma lzp_pres_stmt :
    forall s e le m0 tr le' m' out,
      exec_stmt function_entry2 (lp_ge lp) e le m0 s tr le' m' out ->
      (forall g, mem_id g stored_globals = true -> e ! g = None) ->
      (forall g, mem_id g lzp_ids = true -> e ! g = None) ->
      (forall g, mem_id g lzp_xids = true -> e ! g = None) ->
      e ! interaction._gGlobalTimer = None ->
      e ! mario_actions_cutscene._sIntroWarpPipeObj = None ->
      lzp_chk s = true ->
      (forall b o, le ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) ->
      chase_inv SafeB lzp_cact le ->
      NoA m0 -> MWF m0 -> Mem.valid_block m0 bm ->
      action_sat not_tainted m0 bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\
      NoA m' /\
      (forall b o, le' ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) /\
      chase_inv SafeB lzp_cact le'.
  Proof.
    intros s e le m0 tr le' m' out Hexec.
    induction Hexec;
      intros Hub_g Hub_i Hub_x Hubgt Hub_seed Hchk Htat Hch HN HM HV HS.
    - (* Sskip *)
      exact (conj HV (conj HS (conj HM (conj HN (conj Htat Hch))))).
    - (* Sassign: generic only *)
      cbn [lzp_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp];
        [ | cbn [gobj_seed_chk] in Hsp; discriminate Hsp ].
      eapply (lzp_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hubgt Hg
                Htat Hch HN HM HV HS);
        eapply exec_Sassign; eauto.
    - (* Sset: generic OR the glob-obj seed *)
      cbn [lzp_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp].
      { eapply (lzp_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hubgt Hg
                  Htat Hch HN HM HV HS);
          eapply exec_Sset; eauto. }
      (* the SEED arm: glob_obj_val gives the loaded value SafeB-if-ptr *)
      apply gobj_seed_shape in Hsp as [Hid Hex]. subst id.
      destruct Hex as (t1 & a1 & Ha). subst a.
      pose proof (glob_obj_val mario_actions_cutscene._sIntroWarpPipeObj
                    e le m t1 a1 v ltac:(vm_compute; reflexivity) Hub_seed HM H)
        as Hvsafe.
      split; [ exact HV | split; [ exact HS | split; [ exact HM |
        split; [ exact HN | split ] ] ] ].
      + intros b o Hb. rewrite PTree.gso in Hb by (intro EE; discriminate EE).
        exact (Htat b o Hb).
      + intros t Htmem b o Hb.
        unfold lzp_cact in Htmem. cbn [mem_id existsb] in Htmem.
        apply orb_true_iff in Htmem as [Heq | Hf]; [ | discriminate Hf ].
        apply Pos.eqb_eq in Heq. subst t.
        rewrite PTree.gss in Hb. injection Hb as Hb'.
        exact (Hvsafe b o Hb').
    - (* Scall: generic only *)
      cbn [lzp_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp];
        [ | cbn [gobj_seed_chk] in Hsp; discriminate Hsp ].
      eapply (lzp_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hubgt Hg
                Htat Hch HN HM HV HS);
        eapply exec_Scall; eauto.
    - (* Sbuiltin: rejected by both arms *)
      cbn [lzp_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp];
        [ cbn [lzp_gen wwalk_chk'] in Hg; discriminate Hg
        | cbn [gobj_seed_chk] in Hsp; discriminate Hsp ].
    - (* Sseq_1 *)
      cbn [lzp_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp].
      { eapply (lzp_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hubgt Hg
                  Htat Hch HN HM HV HS);
          eapply exec_Sseq_1; eauto. }
      apply andb_prop in Hsp as [H1 H2].
      destruct (IHHexec1 Hub_g Hub_i Hub_x Hubgt Hub_seed H1 Htat Hch
                  HN HM HV HS)
        as (HV1 & HS1 & HM1 & HN1 & Htat1 & Hch1).
      exact (IHHexec2 Hub_g Hub_i Hub_x Hubgt Hub_seed H2 Htat1 Hch1
               HN1 HM1 HV1 HS1).
    - (* Sseq_2 *)
      cbn [lzp_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp].
      { eapply (lzp_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hubgt Hg
                  Htat Hch HN HM HV HS);
          eapply exec_Sseq_2; eauto. }
      apply andb_prop in Hsp as [H1 _].
      exact (IHHexec Hub_g Hub_i Hub_x Hubgt Hub_seed H1 Htat Hch
               HN HM HV HS).
    - (* Sifthenelse *)
      cbn [lzp_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp].
      { eapply (lzp_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hubgt Hg
                  Htat Hch HN HM HV HS);
          eapply exec_Sifthenelse; eauto. }
      apply andb_prop in Hsp as [H1 H2].
      apply IHHexec; try assumption.
      destruct b; assumption.
    - (* Sreturn None *)
      exact (conj HV (conj HS (conj HM (conj HN (conj Htat Hch))))).
    - (* Sreturn (Some a) *)
      exact (conj HV (conj HS (conj HM (conj HN (conj Htat Hch))))).
    - (* Sbreak *)
      exact (conj HV (conj HS (conj HM (conj HN (conj Htat Hch))))).
    - (* Scontinue *)
      exact (conj HV (conj HS (conj HM (conj HN (conj Htat Hch))))).
    - (* Sloop stop1: generic only *)
      cbn [lzp_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp];
        [ | cbn [gobj_seed_chk] in Hsp; discriminate Hsp ].
      eapply (lzp_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hubgt Hg
                Htat Hch HN HM HV HS);
        eapply exec_Sloop_stop1; eauto.
    - (* Sloop stop2: generic only *)
      cbn [lzp_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp];
        [ | cbn [gobj_seed_chk] in Hsp; discriminate Hsp ].
      eapply (lzp_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hubgt Hg
                Htat Hch HN HM HV HS);
        eapply exec_Sloop_stop2; eauto.
    - (* Sloop loop: generic only *)
      cbn [lzp_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp];
        [ | cbn [gobj_seed_chk] in Hsp; discriminate Hsp ].
      eapply (lzp_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hubgt Hg
                Htat Hch HN HM HV HS);
        eapply exec_Sloop_loop; eauto.
    - (* Sswitch: generic only *)
      cbn [lzp_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp];
        [ | cbn [gobj_seed_chk] in Hsp; discriminate Hsp ].
      eapply (lzp_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hubgt Hg
                Htat Hch HN HM HV HS);
        eapply exec_Sswitch; eauto.
  Qed.

  (* lower_pipe is Internal in mario_actions_cutscene.prog *)
  Example lzp_pin :
    (prog_defmap mario_actions_cutscene.prog) ! C._intro_cutscene_lower_pipe
    = Some (Gfun (Internal C.f_intro_cutscene_lower_pipe)).
  Proof. vm_compute. reflexivity. Qed.

  Lemma lzp_pres : body_pres lp NoA MWF bm C.f_intro_cutscene_lower_pipe.
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
    assert (Hfvnil : fn_vars C.f_intro_cutscene_lower_pipe = nil) by reflexivity.
    rewrite Hfvnil in Halloc. inv Halloc.
    assert (Hbe : blocks_of_env (lp_ge lp) empty_env = nil) by reflexivity.
    rewrite Hbe in Hfree. cbn [Mem.free_list] in Hfree. inv Hfree.
    assert (Hps : match fn_params C.f_intro_cutscene_lower_pipe with
                  | (i, ty) :: ps =>
                      (Pos.eqb i mario_actions_airborne._m
                       && proj_sumbool (type_eq ty tyMSp)
                       && negb (mem_id mario_actions_airborne._m
                                  (map fst ps)))%bool
                  | nil => false
                  end = true) by (vm_compute; reflexivity).
    assert (Hnpc : forallb
              (fun t' => negb (mem_id t'
                 (map fst (fn_params C.f_intro_cutscene_lower_pipe))))
              lzp_cact = true) by (vm_compute; reflexivity).
    assert (Hmarg : marg_ok bm vargs0)
      by (apply Hmargf; vm_compute; reflexivity).
    destruct (fn_params C.f_intro_cutscene_lower_pipe)
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
        assert (Hch0 : chase_inv SafeB lzp_cact le1)
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
    assert (Hub_g : forall g, mem_id g stored_globals = true ->
                    empty_env ! g = None) by (intros; apply PTree.gempty).
    assert (Hub_i : forall g, mem_id g lzp_ids = true ->
                    empty_env ! g = None) by (intros; apply PTree.gempty).
    assert (Hub_x : forall g, mem_id g lzp_xids = true ->
                    empty_env ! g = None) by (intros; apply PTree.gempty).
    assert (Hubgt : empty_env ! interaction._gGlobalTimer = None)
      by (apply PTree.gempty).
    assert (Hub_seed :
              empty_env ! mario_actions_cutscene._sIntroWarpPipeObj = None)
      by (apply PTree.gempty).
    destruct (lzp_pres_stmt _ _ _ _ _ _ _ _ Hbody
                Hub_g Hub_i Hub_x Hubgt Hub_seed lzp_walk Htat0 Hch0 HN HM HV HS)
      as (HVb & HSb & HMb & _ & _ & _).
    exact (conj HVb (conj HSb HMb)).
  Qed.

  Lemma lzp_row :
    call_pres lp bm NoA MWF mario_actions_cutscene._intro_cutscene_lower_pipe.
  Proof.
    exact (call_pres_of_body lp bm NoA MWF HNoA_of_MWF
             mario_actions_cutscene.prog _ _ LO_cut lzp_pin lzp_pres).
  Qed.

  (* ---- the act_intro_cutscene dispatcher row + body_pres (consumes all 7
     subhandler rows; placed here so the raise_pipe / lower_pipe rows above
     are in scope). ---- *)
  Lemma intro_ids_rows : forall fid, mem_id fid intro_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold intro_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact hhm_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact pk_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact rzp_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact jop_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact lop_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact lzp_row | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact smti_row | discriminate H ].
  Qed.
  Lemma intro_pres : body_pres lp NoA MWF bm C.f_act_intro_cutscene.
  Proof.
    apply (body_pres_of_wwalk_cact lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             C.f_act_intro_cutscene intro_ids nil nil nil nil nil).
    - vm_compute; reflexivity.
    - vm_compute; reflexivity.
    - vm_compute; reflexivity.
    - exact intro_ids_rows.
    - intros fid' H; discriminate H.
    - intros fid' H; discriminate H.
    - intros fid' H; discriminate H.
    - intros fid' H; discriminate H.
    - exact intro_walk.
  Qed.

  (* ==================================================================== *)
  (* act_end_waving_cutscene: a single body (NOT a dispatcher).  When       *)
  (* actionState==0 it spawns the end-peach/toad objects into globals       *)
  (* (sEndPeachObj/sEndRightToadObj/sEndLeftToadObj = spawn result; generic *)
  (* glob SET stores), stores THROUGH the loaded object pointers            *)
  (* (rawData.asS32[61]=255; glob-obj chase via the SEED arm), writes the   *)
  (* end anim statics (sEndPeachAnimation = 11, sEndToadAnims[i]; generic   *)
  (* glob/glob-array stores), and chase-stores Mario fields.  After the     *)
  (* branch: set_mario_animation / stop_and_set_height_to_floor (marg),     *)
  (* marioObj/marioBodyState chase stores, actionTimer++, and a gated       *)
  (* level_trigger_warp.  Returns FALSE.  The ONLY bespoke sites are the    *)
  (* glob-obj SEEDs `Sset t (Evar sEnd*Obj)`; everything else is generic    *)
  (* (the glob-array store rides the new glob_store_chk bare-Evar arm).      *)
  (* Closes act_end_waving_cutscene -> cut_rest 2->1.                        *)
  (* ==================================================================== *)
  Definition eaw_cact : list ident :=
    C._t'19 :: C._t'15 :: C._t'14 :: C._t'13 :: C._t'9 :: C._t'6 :: C._t'5 :: nil.
  Definition eaw_gobj_seeds : list ident :=
    C._t'15 :: C._t'14 :: C._t'13 :: nil.
  Definition eaw_ids : list ident :=
    mario._set_mario_animation :: mario_step._stop_and_set_height_to_floor
      :: level_update._level_trigger_warp :: nil.
  Definition eaw_xids : list ident :=
    C._spawn_object_abs_with_rot :: nil.

  Lemma eaw_seed_ne_m : forall id,
      mem_id id eaw_gobj_seeds = true -> id <> mario_actions_airborne._m.
  Proof.
    intros id H. unfold eaw_gobj_seeds in H. cbn [mem_id existsb] in H.
    repeat (apply orb_true_iff in H as [E | H];
            [ apply Pos.eqb_eq in E; subst id; discriminate | ]).
    discriminate H.
  Qed.

  Definition eaw_gen (s : statement) : bool :=
    wwalk_chk' nil nil nil nil nil nil false
      nil eaw_ids nil eaw_cact eaw_xids nil nil s.

  Fixpoint eaw_chk (s : statement) : bool :=
    eaw_gen s
    || match s with
       | Ssequence s1 s2 => eaw_chk s1 && eaw_chk s2
       | Sifthenelse _ s1 s2 => eaw_chk s1 && eaw_chk s2
       | _ => gobj_seed_chk2 eaw_gobj_seeds s
       end.

  Example eaw_walk :
    eaw_chk (fn_body C.f_act_end_waving_cutscene) = true.
  Proof. vm_compute. reflexivity. Qed.

  Lemma eaw_ids_rows : forall fid, mem_id fid eaw_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold eaw_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_sma | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_sashf | ].
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcp_ltw | discriminate H ].
  Qed.

  Lemma eaw_xids_rows : forall fid, mem_id fid eaw_xids = true ->
      call_pres_ext lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold eaw_xids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hcpx_soawr | discriminate H ].
  Qed.

  Lemma eaw_generic :
    forall s e le m0 tr le' m' out,
      (forall g, mem_id g stored_globals = true -> e ! g = None) ->
      (forall g, mem_id g eaw_ids = true -> e ! g = None) ->
      (forall g, mem_id g eaw_xids = true -> e ! g = None) ->
      e ! interaction._gGlobalTimer = None ->
      eaw_gen s = true ->
      (forall b o, le ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) ->
      chase_inv SafeB eaw_cact le ->
      NoA m0 -> MWF m0 -> Mem.valid_block m0 bm ->
      action_sat not_tainted m0 bm ->
      exec_stmt function_entry2 (lp_ge lp) e le m0 s tr le' m' out ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\
      NoA m' /\
      (forall b o, le' ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) /\
      chase_inv SafeB eaw_cact le'.
  Proof.
    intros s e le m0 tr le' m' out Hub_g Hub_i Hub_x Hubgt Hchk Htat Hch
           HN HM HV HS Hexec.
    destruct (wwalk_pres lp LO_mario bm NoA MWF HNoA_of_MWF HMWF_window
                HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot HMWF_chase
                HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
                false nil eaw_ids nil eaw_cact eaw_xids nil nil
                nil nil nil nil nil nil
                eaw_ids_rows
                (fun fid HH => match Bool.diff_false_true HH with end)
                eaw_xids_rows
                (fun fid HH => match Bool.diff_false_true HH with end)
                (fun fid HH => match Bool.diff_false_true HH with end)
                (fun fid HH => match Bool.diff_false_true HH with end)
                (fun fid HH => match Bool.diff_false_true HH with end)
                (fun fid HH => match Bool.diff_false_true HH with end)
                (fun fid HH => match Bool.diff_false_true HH with end)
                s e le m0 tr le' m' out
                (fun HH => match HH eq_refl with end)
                (fun lid HH => match Bool.diff_false_true HH with end)
                Hexec
                Hub_g Hub_i
                (fun g HH => match Bool.diff_false_true HH with end)
                Hub_x
                (fun g HH => match Bool.diff_false_true HH with end)
                (fun g HH => match Bool.diff_false_true HH with end)
                (fun g HH => match Bool.diff_false_true HH with end)
                (fun g HH => match Bool.diff_false_true HH with end)
                (fun g HH => match Bool.diff_false_true HH with end)
                (fun g HH => match Bool.diff_false_true HH with end)
                Hubgt
                Hchk Htat
                (fun t HH => match Bool.diff_false_true HH with end)
                Hch
                (fun t HH => match Bool.diff_false_true HH with end)
                HN HM HV HS)
      as (HV' & HS' & HM' & HN' & Htat' & _ & Hch' & _ & _).
    exact (conj HV' (conj HS' (conj HM' (conj HN' (conj Htat' Hch'))))).
  Qed.

  (* the hybrid walk prover: generic subtrees go to eaw_generic wholesale;
     the special sites are the glob-obj SEEDs `Sset t (Evar sEnd*Obj)` (t in
     eaw_gobj_seeds, sEnd*Obj in gobj_ids), each establishing chase_inv[t] via
     glob_obj_val so the THROUGH store walks generically. *)
  Lemma eaw_pres_stmt :
    forall s e le m0 tr le' m' out,
      exec_stmt function_entry2 (lp_ge lp) e le m0 s tr le' m' out ->
      (forall g, mem_id g stored_globals = true -> e ! g = None) ->
      (forall g, mem_id g eaw_ids = true -> e ! g = None) ->
      (forall g, mem_id g eaw_xids = true -> e ! g = None) ->
      e ! interaction._gGlobalTimer = None ->
      (forall g, mem_id g gobj_ids = true -> e ! g = None) ->
      eaw_chk s = true ->
      (forall b o, le ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) ->
      chase_inv SafeB eaw_cact le ->
      NoA m0 -> MWF m0 -> Mem.valid_block m0 bm ->
      action_sat not_tainted m0 bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\
      NoA m' /\
      (forall b o, le' ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) /\
      chase_inv SafeB eaw_cact le'.
  Proof.
    intros s e le m0 tr le' m' out Hexec.
    induction Hexec;
      intros Hub_g Hub_i Hub_x Hubgt Hub_gobj Hchk Htat Hch HN HM HV HS.
    - (* Sskip *)
      exact (conj HV (conj HS (conj HM (conj HN (conj Htat Hch))))).
    - (* Sassign: generic only *)
      cbn [eaw_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp];
        [ | cbn [gobj_seed_chk2] in Hsp; discriminate Hsp ].
      eapply (eaw_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hubgt Hg
                Htat Hch HN HM HV HS);
        eapply exec_Sassign; eauto.
    - (* Sset: generic OR the glob-obj seed *)
      cbn [eaw_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp].
      { eapply (eaw_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hubgt Hg
                  Htat Hch HN HM HV HS);
          eapply exec_Sset; eauto. }
      (* the SEED arm: glob_obj_val gives the loaded value SafeB-if-ptr *)
      apply gobj_seed_shape2 in Hsp as [Hid Hex].
      destruct Hex as (g & t1 & a1 & Hg & Ha). subst a.
      pose proof (glob_obj_val g e le m t1 a1 v Hg (Hub_gobj g Hg) HM H)
        as Hvsafe.
      split; [ exact HV | split; [ exact HS | split; [ exact HM |
        split; [ exact HN | split ] ] ] ].
      + intros b o Hb.
        rewrite PTree.gso in Hb by (apply not_eq_sym; exact (eaw_seed_ne_m id Hid)).
        exact (Htat b o Hb).
      + intros t Htmem b o Hb.
        destruct (Pos.eqb t id) eqn:Et.
        * apply Pos.eqb_eq in Et. subst t.
          rewrite PTree.gss in Hb. injection Hb as Hb'.
          exact (Hvsafe b o Hb').
        * apply Pos.eqb_neq in Et.
          rewrite PTree.gso in Hb by (exact Et).
          exact (Hch t Htmem b o Hb).
    - (* Scall: generic only *)
      cbn [eaw_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp];
        [ | cbn [gobj_seed_chk2] in Hsp; discriminate Hsp ].
      eapply (eaw_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hubgt Hg
                Htat Hch HN HM HV HS);
        eapply exec_Scall; eauto.
    - (* Sbuiltin: rejected by both arms *)
      cbn [eaw_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp];
        [ cbn [eaw_gen wwalk_chk'] in Hg; discriminate Hg
        | cbn [gobj_seed_chk2] in Hsp; discriminate Hsp ].
    - (* Sseq_1 *)
      cbn [eaw_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp].
      { eapply (eaw_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hubgt Hg
                  Htat Hch HN HM HV HS);
          eapply exec_Sseq_1; eauto. }
      apply andb_prop in Hsp as [H1 H2].
      destruct (IHHexec1 Hub_g Hub_i Hub_x Hubgt Hub_gobj H1 Htat Hch
                  HN HM HV HS)
        as (HV1 & HS1 & HM1 & HN1 & Htat1 & Hch1).
      exact (IHHexec2 Hub_g Hub_i Hub_x Hubgt Hub_gobj H2 Htat1 Hch1
               HN1 HM1 HV1 HS1).
    - (* Sseq_2 *)
      cbn [eaw_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp].
      { eapply (eaw_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hubgt Hg
                  Htat Hch HN HM HV HS);
          eapply exec_Sseq_2; eauto. }
      apply andb_prop in Hsp as [H1 _].
      exact (IHHexec Hub_g Hub_i Hub_x Hubgt Hub_gobj H1 Htat Hch
               HN HM HV HS).
    - (* Sifthenelse *)
      cbn [eaw_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp].
      { eapply (eaw_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hubgt Hg
                  Htat Hch HN HM HV HS);
          eapply exec_Sifthenelse; eauto. }
      apply andb_prop in Hsp as [H1 H2].
      apply IHHexec; try assumption.
      destruct b; assumption.
    - (* Sreturn None *)
      exact (conj HV (conj HS (conj HM (conj HN (conj Htat Hch))))).
    - (* Sreturn (Some a) *)
      exact (conj HV (conj HS (conj HM (conj HN (conj Htat Hch))))).
    - (* Sbreak *)
      exact (conj HV (conj HS (conj HM (conj HN (conj Htat Hch))))).
    - (* Scontinue *)
      exact (conj HV (conj HS (conj HM (conj HN (conj Htat Hch))))).
    - (* Sloop stop1: generic only *)
      cbn [eaw_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp];
        [ | cbn [gobj_seed_chk2] in Hsp; discriminate Hsp ].
      eapply (eaw_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hubgt Hg
                Htat Hch HN HM HV HS);
        eapply exec_Sloop_stop1; eauto.
    - (* Sloop stop2: generic only *)
      cbn [eaw_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp];
        [ | cbn [gobj_seed_chk2] in Hsp; discriminate Hsp ].
      eapply (eaw_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hubgt Hg
                Htat Hch HN HM HV HS);
        eapply exec_Sloop_stop2; eauto.
    - (* Sloop loop: generic only *)
      cbn [eaw_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp];
        [ | cbn [gobj_seed_chk2] in Hsp; discriminate Hsp ].
      eapply (eaw_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hubgt Hg
                Htat Hch HN HM HV HS);
        eapply exec_Sloop_loop; eauto.
    - (* Sswitch: generic only *)
      cbn [eaw_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hg | Hsp];
        [ | cbn [gobj_seed_chk2] in Hsp; discriminate Hsp ].
      eapply (eaw_generic _ _ _ _ _ _ _ _ Hub_g Hub_i Hub_x Hubgt Hg
                Htat Hch HN HM HV HS);
        eapply exec_Sswitch; eauto.
  Qed.

  Example eaw_pin :
    (prog_defmap mario_actions_cutscene.prog) ! C._act_end_waving_cutscene
    = Some (Gfun (Internal C.f_act_end_waving_cutscene)).
  Proof. vm_compute. reflexivity. Qed.

  Lemma eaw_pres : body_pres lp NoA MWF bm C.f_act_end_waving_cutscene.
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
    assert (Hfvnil : fn_vars C.f_act_end_waving_cutscene = nil) by reflexivity.
    rewrite Hfvnil in Halloc. inv Halloc.
    assert (Hbe : blocks_of_env (lp_ge lp) empty_env = nil) by reflexivity.
    rewrite Hbe in Hfree. cbn [Mem.free_list] in Hfree. inv Hfree.
    assert (Hps : match fn_params C.f_act_end_waving_cutscene with
                  | (i, ty) :: ps =>
                      (Pos.eqb i mario_actions_airborne._m
                       && proj_sumbool (type_eq ty tyMSp)
                       && negb (mem_id mario_actions_airborne._m
                                  (map fst ps)))%bool
                  | nil => false
                  end = true) by (vm_compute; reflexivity).
    assert (Hnpc : forallb
              (fun t' => negb (mem_id t'
                 (map fst (fn_params C.f_act_end_waving_cutscene))))
              eaw_cact = true) by (vm_compute; reflexivity).
    assert (Hmarg : marg_ok bm vargs0)
      by (apply Hmargf; vm_compute; reflexivity).
    destruct (fn_params C.f_act_end_waving_cutscene)
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
        assert (Hch0 : chase_inv SafeB eaw_cact le1)
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
    assert (Hub_g : forall g, mem_id g stored_globals = true ->
                    empty_env ! g = None) by (intros; apply PTree.gempty).
    assert (Hub_i : forall g, mem_id g eaw_ids = true ->
                    empty_env ! g = None) by (intros; apply PTree.gempty).
    assert (Hub_x : forall g, mem_id g eaw_xids = true ->
                    empty_env ! g = None) by (intros; apply PTree.gempty).
    assert (Hubgt : empty_env ! interaction._gGlobalTimer = None)
      by (apply PTree.gempty).
    assert (Hub_gobj : forall g, mem_id g gobj_ids = true ->
                    empty_env ! g = None) by (intros; apply PTree.gempty).
    destruct (eaw_pres_stmt _ _ _ _ _ _ _ _ Hbody
                Hub_g Hub_i Hub_x Hubgt Hub_gobj eaw_walk Htat0 Hch0 HN HM HV HS)
      as (HVb & HSb & HMb & _ & _ & _).
    exact (conj HVb (conj HSb HMb)).
  Qed.

  Lemma eaw_row :
    call_pres lp bm NoA MWF C._act_end_waving_cutscene.
  Proof.
    exact (call_pres_of_body lp bm NoA MWF HNoA_of_MWF
             mario_actions_cutscene.prog _ _ LO_cut eaw_pin eaw_pres).
  Qed.

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
    destruct (Pos.eqb fid C._act_standing_death) eqn:E22.
    { apply Pos.eqb_eq in E22; subst fid.
      rewrite sd_pin in Hdm. injection Hdm as <-. exact sd_pres. }
    destruct (Pos.eqb fid C._act_fall_after_star_grab) eqn:E23.
    { apply Pos.eqb_eq in E23; subst fid.
      rewrite fasg_pin in Hdm. injection Hdm as <-. exact fasg_pres. }
    destruct (Pos.eqb fid C._act_spawn_spin_airborne) eqn:E24.
    { apply Pos.eqb_eq in E24; subst fid.
      rewrite ssa_pin in Hdm. injection Hdm as <-. exact ssa_pres. }
    destruct (Pos.eqb fid C._act_warp_door_spawn) eqn:E25.
    { apply Pos.eqb_eq in E25; subst fid.
      rewrite wds_pin in Hdm. injection Hdm as <-. exact wds_pres. }
    destruct (Pos.eqb fid C._act_going_through_door) eqn:E35.
    { apply Pos.eqb_eq in E35; subst fid.
      rewrite gtd_pin in Hdm. injection Hdm as <-. exact gtd_pres. }
    destruct (Pos.eqb fid C._act_entering_star_door) eqn:E39.
    { apply Pos.eqb_eq in E39; subst fid.
      rewrite esd_pin in Hdm. injection Hdm as <-. exact esd_pres. }
    destruct (Pos.eqb fid C._act_reading_npc_dialog) eqn:E40.
    { apply Pos.eqb_eq in E40; subst fid.
      rewrite rnd_pin in Hdm. injection Hdm as <-. exact rnd_pres. }
    destruct (Pos.eqb fid C._act_unlocking_star_door) eqn:E41.
    { apply Pos.eqb_eq in E41; subst fid.
      rewrite usd_pin in Hdm. injection Hdm as <-. exact usd_pres. }
    destruct (Pos.eqb fid C._check_for_instant_quicksand) eqn:E42.
    { apply Pos.eqb_eq in E42; subst fid.
      rewrite cfiq_pin in Hdm. injection Hdm as <-. exact cfiq_pres. }
    destruct (Pos.eqb fid C._act_unlocking_key_door) eqn:E43.
    { apply Pos.eqb_eq in E43; subst fid.
      rewrite ukd_pin in Hdm. injection Hdm as <-. exact ukd_pres. }
    destruct (Pos.eqb fid C._act_credits_cutscene) eqn:E44.
    { apply Pos.eqb_eq in E44; subst fid.
      rewrite cred_pin in Hdm. injection Hdm as <-. exact cred_pres. }
    destruct (Pos.eqb fid C._act_jumbo_star_cutscene) eqn:E45.
    { apply Pos.eqb_eq in E45; subst fid.
      rewrite jumbo_pin in Hdm. injection Hdm as <-. exact jumbo_pres. }
    destruct (Pos.eqb fid C._act_exit_land_save_dialog) eqn:E46.
    { apply Pos.eqb_eq in E46; subst fid.
      rewrite eld_pin in Hdm. injection Hdm as <-. exact eld_pres. }
    destruct (Pos.eqb fid C._act_debug_free_move) eqn:E47.
    { apply Pos.eqb_eq in E47; subst fid.
      rewrite dfm_pin in Hdm. injection Hdm as <-. exact dfm_pres. }
    destruct (Pos.eqb fid C._act_intro_cutscene) eqn:E48.
    { apply Pos.eqb_eq in E48; subst fid.
      rewrite intro_pin in Hdm. injection Hdm as <-. exact intro_pres. }
    destruct (Pos.eqb fid C._act_end_waving_cutscene) eqn:E49.
    { apply Pos.eqb_eq in E49; subst fid.
      rewrite eaw_pin in Hdm. injection Hdm as <-. exact eaw_pres. }
    destruct (Pos.eqb fid C._act_reading_sign) eqn:E26.
    { apply Pos.eqb_eq in E26; subst fid.
      rewrite rs_pin in Hdm. injection Hdm as <-. exact rs_pres. }
    destruct (Pos.eqb fid C._act_bbh_enter_spin) eqn:E27.
    { apply Pos.eqb_eq in E27; subst fid.
      rewrite bbhs_pin in Hdm. injection Hdm as <-. exact bbhs_pres. }
    destruct (Pos.eqb fid C._act_reading_automatic_dialog) eqn:E28.
    { apply Pos.eqb_eq in E28; subst fid.
      rewrite rad_pin in Hdm. injection Hdm as <-. exact rad_pres. }
    destruct (Pos.eqb fid C._act_bbh_enter_jump) eqn:E29.
    { apply Pos.eqb_eq in E29; subst fid.
      rewrite bbhj_pin in Hdm. injection Hdm as <-. exact bbhj_pres. }
    destruct (Pos.eqb fid C._act_star_dance) eqn:E30.
    { apply Pos.eqb_eq in E30; subst fid.
      rewrite sdn_pin in Hdm. injection Hdm as <-. exact sdn_pres. }
    destruct (Pos.eqb fid C._act_star_dance_water) eqn:E31.
    { apply Pos.eqb_eq in E31; subst fid.
      rewrite sdw_pin in Hdm. injection Hdm as <-. exact sdw_pres. }
    destruct (Pos.eqb fid C._act_squished) eqn:E32.
    { apply Pos.eqb_eq in E32; subst fid.
      rewrite sq_pin in Hdm. injection Hdm as <-. exact sq_pres. }
    destruct (Pos.eqb fid C._act_quicksand_death) eqn:E33.
    { apply Pos.eqb_eq in E33; subst fid.
      rewrite qsd_pin in Hdm. injection Hdm as <-. exact qsd_pres. }
    destruct (Pos.eqb fid C._act_putting_on_cap) eqn:E34.
    { apply Pos.eqb_eq in E34; subst fid.
      rewrite poc_pin in Hdm. injection Hdm as <-. exact poc_pres. }
    destruct (Pos.eqb fid C._act_head_stuck_in_ground) eqn:E36.
    { apply Pos.eqb_eq in E36; subst fid.
      rewrite ghd_pin in Hdm. injection Hdm as <-. exact ghd_pres. }
    destruct (Pos.eqb fid C._act_butt_stuck_in_ground) eqn:E37.
    { apply Pos.eqb_eq in E37; subst fid.
      rewrite gbs_pin in Hdm. injection Hdm as <-. exact gbs_pres. }
    destruct (Pos.eqb fid C._act_feet_stuck_in_ground) eqn:E38.
    { apply Pos.eqb_eq in E38; subst fid.
      rewrite gfs_pin in Hdm. injection Hdm as <-. exact gfs_pres. }
    (* REST: fid is in the census and not a walked id. *)
    apply (Hrest fid f); [ | exact Hdm ].
    unfold cut_rest_ids.
    apply mem_id_filter_true; [ exact H | ].
    unfold cut_walked_ids. cbn [mem_id existsb].
    rewrite E1, E2, E3, E4, E5, E6, E7, E8, E9, E10, E11, E12, E13, E14, E15, E16,
      E17, E18, E19, E20, E21, E22, E23, E24, E25, E35, E39, E40, E41, E42, E43, E44, E45, E46, E47, E48, E49, E26, E27, E28, E29, E30, E31,
      E32, E33, E34, E36, E37, E38.
    reflexivity.
  Qed.

End CutsceneLeafRows.
