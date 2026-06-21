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
  OutParamSurface LocalVarsSurface AutomaticLeafSurface MovingLeafSurface.

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
    :: C._play_course_clear :: C._play_music :: C._save_file_do_save :: nil.

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
    :: C._act_reading_sign :: C._act_bbh_enter_spin
    :: C._act_reading_automatic_dialog :: C._act_bbh_enter_jump
    :: C._act_star_dance :: C._act_star_dance_water
    :: C._act_squished :: C._act_quicksand_death
    :: C._act_putting_on_cap
    :: C._act_head_stuck_in_ground :: C._act_butt_stuck_in_ground
    :: C._act_feet_stuck_in_ground :: nil.
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
  Hypothesis Hcpx_atan2s :
    call_pres_ext lp bm NoA MWF interaction._atan2s.
  (* approach_s32: a pure-math integer-clamp EF_external (in obj_ext_ids; no
     Mem write).  The capstone feeds the dedicated Hcpx_approach_real -- the
     SAME term the submerged family threads -- so NO new trust.  Consumed only
     by act_reading_npc_dialog (rnd). *)
  Hypothesis Hcpx_approach :
    call_pres_ext lp bm NoA MWF mario_actions_object._approach_s32.
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
      E17, E18, E19, E20, E21, E22, E23, E24, E25, E35, E39, E40, E26, E27, E28, E29, E30, E31,
      E32, E33, E34, E36, E37, E38.
    reflexivity.
  Qed.

End CutsceneLeafRows.
