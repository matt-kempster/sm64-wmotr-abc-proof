(* spine-root: the TWELVE-TU GOAL-1 capstone -- the sharpest statement:
   the 12 LO pins + the 16-id negative pin are DERIVED from the single
   linked12 chain premise (LinkedTwelve), live since the #95 repair. *)
(* ====================================================================== *)
(* LIVE since the #95 repair: the negative pin now covers only the         *)
(* sixteen genuinely-external whitelist ids (exempt_ext_ids), so           *)
(* linked12_ext_pin discharges it for any twelve-TU link.                  *)
(* ====================================================================== *)
(* THE TWELVE-TU CAPSTONE (the sharpest GOAL-1 statement).                *)
(*                                                                        *)
(* WHAT IT SAYS, exactly: let lp be a CompCert link of the twelve         *)
(* clightgen'd SM64 TUs (linked12 lp).  Start from a memory satisfying    *)
(* mem_ok_lp, and repeatedly apply ONE step = one real eval_funcall of     *)
(* execute_mario_action over globalenv lp, with the controller's A bit     *)
(* clear before every step.  Then Mario's action is never a flying one.   *)
(*                                                                        *)
(* WHAT IT DOES NOT SAY: the step is execute_mario_action ONLY -- not the *)
(* rest of the game loop.  Object behaviours, level scripts and warps     *)
(* run between Mario frames in the real game and also write Mario's       *)
(* state; they are outside this step relation.  Functions outside the     *)
(* twelve TUs (collision, math_util, audio, ...) are CompCert externals,  *)
(* constrained only by the Hocp_/Hpres_/Hext_ rows below.                 *)
(*                                                                        *)
(* NON-VACUITY: linked12 is inhabited (Linked12Sat.linked12_inhabited),   *)
(* and the step relation really can reach flying WITH A pressed           *)
(* (PositiveControl.A_pressed_frame_reaches_flying) -- so the no-A        *)
(* premise is what does the work.  Still open: that mem_ok_lp and the     *)
(* rows below are jointly satisfiable by a memory the step accepts.       *)
(*                                                                        *)
(* The per-TU linkorder pins and the negative pin are DERIVED from        *)
(* linked12 (LinkedTwelve.v).  The remaining rows are the runtime-layout  *)
(* facts (SafeB), the external-call model boundary (Hocp_/Hpres_/...),    *)
(* and the Hext_action / Hmwf_ext engine rows (WL_exempt is a lemma since  *)
(* 2026-10-22; as an assumed row it was FALSE, WLExempt.v).               *)
(* The spawn-exclusion input of the underlying real_mwf capstone is       *)
(* instantiated to "never" here: that theorem holds for EVERY choice of   *)
(* it, so the premise was decorative and dropping it loses nothing.       *)
(* ====================================================================== *)

From compcert Require Import Coqlib Maps AST Integers Values Events Memory Globalenvs
  Ctypes Clight ClightBigstep Linking.
From Coq Require Import List. Import ListNotations.
From SM64.Generated Require mario mario_actions_stationary
  mario_actions_moving mario_actions_airborne mario_actions_submerged
  mario_actions_cutscene mario_actions_automatic mario_actions_object
  interaction behavior_actions level_update mario_step camera audio_external sound_init math_util
  print.
From SM64.Proofs Require BullyBodies SpawnBodies AudioBodies PrintBodies CameraModeBody.
From SM64.Proofs Require Import Flying Taint ActionValue ActionValueFrame ReachableRun
  RealFrameValue RealFrameLinked AGates SymbolicLinking FieldNonInterference.
From SM64.Proofs Require Import CensusV2 EngineV2Consumer.
From SM64.Proofs Require Import MWFReal RestSurface FloorsSurface
  OutParamSurface RetSurface StationaryLeafSurface MovingLeafSurface
  ObjectLeafSurface CutsceneLeafSurface WindSurface WarpSurface
  FloorsLeafSurface.
From SM64.Proofs Require Import LinkedTwelve.
From SM64.Proofs Require Import SpawnInit.
From SM64.Proofs Require Import InitMemSat.
From SM64.Proofs Require Import NoAImpliesNoFlyLinked.
From SM64.Proofs Require WLExempt CameraBodies FpuFloor.
From SM64.Proofs Require GraphNodeBodies MtxfBody SaveFileBody ObjHelpersBodies FpuFloor OsDmaFloor
  LptBody BootMWF MathBodies ObjExtBodies SaveDoSaveBody.

(* The open any-argument object-external list, minus memory.c's two
   segment converters: those are linked (the 15th TU) and pure, so their
   entries are PROVED (MathBodies.Hcpx_s2v_proved / _v2s_proved; found
   2026-10-20 in the premise sweep). *)
Definition obj_ext_mem (i : ident) : bool :=
  Pos.eqb i interaction._segmented_to_virtual || Pos.eqb i interaction._virtual_to_segmented.
(* PROVED 2026-10-21 (premise sweep): the seven entries whose bodies are
   linked -- the six save_file.c readers / flag writers and behavior_actions'
   bhv_spawn_star_no_level_exit -- are walked from their real bodies
   (ObjExtBodies).  Every store is a global-rooted chain into a stored global,
   or (bhv_spawn_star) an integer store through spawn_object's SafeB result
   (its gated row, SpawnBodies.Hcp_spawn_sg). *)
Definition obj_ext_body (i : ident) : bool :=
  Pos.eqb i interaction._save_file_get_flags
  || Pos.eqb i level_update._save_file_get_star_flags
  || Pos.eqb i interaction._save_file_get_total_star_count
  || Pos.eqb i interaction._save_file_collect_star_or_key
  || Pos.eqb i interaction._save_file_set_flags
  || Pos.eqb i interaction._save_file_clear_flags
  || Pos.eqb i interaction._bhv_spawn_star_no_level_exit
  (* 2026-10-21: area.c is linked (the 23rd TU); override_viewport_and_clip
     stores gFBSetColor (an integer, a global MWF does not read) and its two
     pointer args into the stored globals D_8032CE74 / D_8032CE78 *)
  || Pos.eqb i mario_actions_cutscene._override_viewport_and_clip.
(* PROVED 2026-10-22 (premise sweep): sqrtf, from the FPU floor the
   capstone already takes (Hsq : sqrtf_spec: the call leaves memory as it
   was); set_camera_shake_from_hit, walked from its real camera.c body (the
   35th TU; CameraBodies: s16 / f32 stores into gLakituState / sFOVState).
   Its SHAKE_SHOCK arm calls random_float (engine/behavior_script.c, not
   linked), whose any-argument row takes its place below: a void-argument
   RNG instead of the whole shake dispatcher. *)
Definition obj_ext_cam (i : ident) : bool :=
  Pos.eqb i mario._sqrtf || Pos.eqb i interaction._set_camera_shake_from_hit.
(* PROVED 2026-10-23 (the audio link, TUs 40 and 41): every audio entry
   (play_sound, set_sound_moving_speed, stop_shell_music) is walked from its
   real audio/external.c / sound_init.c body (AudioBodies.audio_rows). *)
Definition obj_ext_open2_ids : list ident :=
  camera._random_float ::
  filter (fun i => negb (obj_ext_mem i || obj_ext_body i || obj_ext_cam i
                         || AudioBodies.audio_id i))
    NoAImpliesNoFlyLinked.obj_ext_open_ids.

Lemma obj_ext_open_of2 : forall lp bm bc oc0 SafeB, linked12 lp ->
    SafeB_syms_ok lp SafeB -> (exists init, spawn_ok lp init bm bc oc0) ->
    FpuFloor.sqrtf_spec ->
    call_pres_ext_sg lp bm (NoA_real bm) (MWF_real lp bm bc oc0 SafeB) SafeB
      behavior_actions._spawn_object ->
    FloorsSurface.call_pres_ext lp bm (NoA_real bm) (MWF_real lp bm bc oc0 SafeB)
      audio_external._load_sequence ->
    (forall fid, mem_id fid obj_ext_open2_ids = true ->
       FloorsSurface.call_pres_ext lp bm (NoA_real bm) (MWF_real lp bm bc oc0 SafeB) fid) ->
    forall fid, mem_id fid NoAImpliesNoFlyLinked.obj_ext_open_ids = true ->
      FloorsSurface.call_pres_ext lp bm (NoA_real bm) (MWF_real lp bm bc oc0 SafeB) fid.
Proof.
  intros lp bm bc oc0 SafeB H12 Hsy Hsp Hsq Hspn Hls Hrow fid H.
  assert (Hrf : FloorsSurface.call_pres_ext lp bm (NoA_real bm) (MWF_real lp bm bc oc0 SafeB)
                  camera._random_float)
    by (apply Hrow; cbn [obj_ext_open2_ids mem_id existsb]; rewrite Pos.eqb_refl; reflexivity).
  destruct (NoAImpliesNoFlyLinked.mem_id_filter_split
              (fun i => obj_ext_mem i || obj_ext_body i || obj_ext_cam i
                        || AudioBodies.audio_id i) fid _ H) as [Hm | Ho];
    [ | apply Hrow; cbn [obj_ext_open2_ids mem_id existsb];
        apply orb_true_iff; right; exact Ho ].
  apply orb_true_iff in Hm as [Hm | Ha];
    [ | exact (AudioBodies.audio_rows lp H12 bm bc oc0 SafeB Hsy Hsp Hls fid Ha) ].
  apply orb_true_iff in Hm as [Hm | Hc];
    [ | unfold obj_ext_cam in Hc;
        apply orb_true_iff in Hc as [Hc | Hc]; apply Pos.eqb_eq in Hc; subst fid;
        [ exact (CameraBodies.Hpx_sqrtf lp H12 bm bc oc0 SafeB Hsq)
        | exact (CameraBodies.Hpx_csh lp H12 bm bc oc0 SafeB Hsy Hsp Hrf) ] ].
  apply orb_true_iff in Hm as [Hm | Hb].
  - unfold obj_ext_mem in Hm.
    apply orb_true_iff in Hm as [Hm | Hm]; apply Pos.eqb_eq in Hm; subst fid.
    + exact (MathBodies.Hcpx_s2v_proved lp bm _ _ (linked12_LO_math lp H12) (linked12_LO_memory lp H12)).
    + exact (MathBodies.Hcpx_v2s_proved lp bm _ _ (linked12_LO_math lp H12) (linked12_LO_memory lp H12)).
  - unfold obj_ext_body in Hb.
    repeat (apply orb_true_iff in Hb as [Hb | Hb]); apply Pos.eqb_eq in Hb; subst fid.
    + exact (ObjExtBodies.Hpx_get_flags lp H12 bm bc oc0 SafeB Hsy Hsp).
    + exact (ObjExtBodies.Hpx_get_star_flags lp H12 bm bc oc0 SafeB Hsy Hsp).
    + exact (ObjExtBodies.Hpx_total_star_count lp H12 bm bc oc0 SafeB Hsy Hsp).
    + exact (ObjExtBodies.Hpx_collect lp H12 bm bc oc0 SafeB Hsy Hsp).
    + exact (ObjExtBodies.Hpx_set_flags lp H12 bm bc oc0 SafeB Hsy Hsp).
    + exact (ObjExtBodies.Hpx_clear_flags lp H12 bm bc oc0 SafeB Hsy Hsp).
    + exact (ObjExtBodies.Hpx_bs lp H12 bm bc oc0 SafeB Hsy Hsp Hspn).
    + exact (ObjExtBodies.Hpx_ovac lp H12 bm bc oc0 SafeB Hsy Hsp).
Qed.

(* PROVED 2026-10-21: the time-stop pair of the any-argument cutscene list
   (object_helpers.c bodies: one read-modify-write of the stored global
   gTimeStopState each). *)
Definition cut_ext_body (i : ident) : bool :=
  Pos.eqb i mario_actions_cutscene._enable_time_stop
  || Pos.eqb i mario_actions_cutscene._disable_time_stop
  (* 2026-10-21: area.c's play_transition stores only non-pointers into
     gWarpTransition / gWarpTrans{Red,Green,Blue,FBSetColor}, globals MWF
     does not read (through the real set_warp_transition_rgb) *)
  || Pos.eqb i level_update._play_transition
  (* 2026-10-21: save_file_do_save, walked from its real body through the
     linked libultra EEPROM C (osEepromLongWrite / osEepromWrite /
     __osEepStatus / __osPackEepWriteData / the SI access queue /
     osCreateMesgQueue) down to the hardware/OS floor (bcopy,
     __osSiRawStartDma, osRecvMesg / osSendMesg, osSetTimer: TRUST 3.5).
     Every store lands in a block MWF and action_sat never read
     (SaveDoSaveBody) *)
  || Pos.eqb i mario_actions_cutscene._save_file_do_save
  (* 2026-10-22: camera.c is linked (the 35th TU): camera_approach_f32_symmetric
     is pure float arithmetic, and trigger_cutscene_dialog's only store path
     (start_object_cutscene_without_focus) writes two bytes of camera.c
     statics MWF does not read (CameraBodies) *)
  || Pos.eqb i mario_actions_cutscene._camera_approach_f32_symmetric
  || Pos.eqb i mario_actions_cutscene._trigger_cutscene_dialog.
(* PROVED 2026-10-23: the eleven audio entries (the music / jingle cues, the
   background-sound mute pair, sound_banks_enable, the volume duck pair,
   fadeout_music, play_sound) are walked from their real bodies
   (AudioBodies.audio_rows). *)
Definition cut_ext_open2_ids : list ident :=
  filter (fun i => negb (cut_ext_body i || AudioBodies.audio_id i))
    NoAImpliesNoFlyLinked.cut_ext_open_ids.

Lemma cut_ext_open_of2 : forall lp bm bc oc0 SafeB, linked12 lp ->
    SafeB_syms_ok lp SafeB -> (exists init, spawn_ok lp init bm bc oc0) ->
    OsDmaFloor.os_dma_floor ->
    FloorsSurface.call_pres_ext lp bm (NoA_real bm) (MWF_real lp bm bc oc0 SafeB)
      audio_external._load_sequence ->
    (forall fid, mem_id fid cut_ext_open2_ids = true ->
       FloorsSurface.call_pres_ext lp bm (NoA_real bm) (MWF_real lp bm bc oc0 SafeB) fid) ->
    forall fid, mem_id fid NoAImpliesNoFlyLinked.cut_ext_open_ids = true ->
      FloorsSurface.call_pres_ext lp bm (NoA_real bm) (MWF_real lp bm bc oc0 SafeB) fid.
Proof.
  intros lp bm bc oc0 SafeB H12 Hsy Hsp Hfl Hls Hrow fid H.
  destruct (NoAImpliesNoFlyLinked.mem_id_filter_split
              (fun i => cut_ext_body i || AudioBodies.audio_id i) fid _ H) as [Hm | Ho];
    [ | exact (Hrow fid Ho) ].
  apply orb_true_iff in Hm as [Hm | Ha];
    [ | exact (AudioBodies.audio_rows lp H12 bm bc oc0 SafeB Hsy Hsp Hls fid Ha) ].
  unfold cut_ext_body in Hm.
  repeat (apply orb_true_iff in Hm as [Hm | Hm]); apply Pos.eqb_eq in Hm; subst fid.
  - exact (ObjExtBodies.Hpx_ets lp H12 bm bc oc0 SafeB Hsy Hsp).
  - exact (ObjExtBodies.Hpx_dts lp H12 bm bc oc0 SafeB Hsy Hsp).
  - exact (ObjExtBodies.Hpx_ptr lp H12 bm bc oc0 SafeB Hsy Hsp).
  - exact (SaveDoSaveBody.Hpx_sfds lp H12 bm bc oc0 SafeB Hsy Hsp Hfl).
  - exact (CameraBodies.Hpx_cafs lp H12 bm bc oc0 SafeB Hsy Hsp).
  - exact (CameraBodies.Hpx_tcd lp H12 bm bc oc0 SafeB Hsy Hsp).
Qed.

(* PROVED 2026-10-21: the two warp-trigger entries whose bodies are linked
   area.c bodies (area_get_warp_node: a load-only list walk; play_transition:
   non-pointer stores into globals MWF does not read). *)
Definition warp_ext_body (i : ident) : bool :=
  Pos.eqb i level_update._area_get_warp_node || Pos.eqb i level_update._play_transition.
(* PROVED 2026-10-23: fadeout_music, play_sound, get_current_background_music
   (AudioBodies.audio_rows). *)
Definition warp_ext_open_ids : list ident :=
  filter (fun i => negb (warp_ext_body i || AudioBodies.audio_id i)) warp_ext_ids.

Lemma warp_ext_of_open : forall lp bm bc oc0 SafeB, linked12 lp ->
    SafeB_syms_ok lp SafeB -> (exists init, spawn_ok lp init bm bc oc0) ->
    FloorsSurface.call_pres_ext lp bm (NoA_real bm) (MWF_real lp bm bc oc0 SafeB)
      audio_external._load_sequence ->
    (forall fid, mem_id fid warp_ext_open_ids = true ->
       FloorsSurface.call_pres_ext lp bm (NoA_real bm) (MWF_real lp bm bc oc0 SafeB) fid) ->
    forall fid, mem_id fid warp_ext_ids = true ->
      FloorsSurface.call_pres_ext lp bm (NoA_real bm) (MWF_real lp bm bc oc0 SafeB) fid.
Proof.
  intros lp bm bc oc0 SafeB H12 Hsy Hsp Hls Hrow fid H.
  destruct (NoAImpliesNoFlyLinked.mem_id_filter_split
              (fun i => warp_ext_body i || AudioBodies.audio_id i) fid _ H) as [Hm | Ho];
    [ | exact (Hrow fid Ho) ].
  apply orb_true_iff in Hm as [Hm | Ha];
    [ | exact (AudioBodies.audio_rows lp H12 bm bc oc0 SafeB Hsy Hsp Hls fid Ha) ].
  unfold warp_ext_body in Hm.
  apply orb_true_iff in Hm as [Hm | Hm]; apply Pos.eqb_eq in Hm; subst fid.
  - exact (ObjExtBodies.Hpx_agwn lp H12 bm bc oc0 SafeB Hsy Hsp).
  - exact (ObjExtBodies.Hpx_ptr lp H12 bm bc oc0 SafeB Hsy Hsp).
Qed.

(* PROVED 2026-10-23: raise_background_noise (AudioBodies.audio_rows); the
   open floors-external list is spawn_default_star alone. *)
Definition floors_ext_open_ids : list ident :=
  filter (fun i => negb (AudioBodies.audio_id i)) floors_ext_ids.

Section NoAImpliesNoFlyTwelve.
  Variable lp : Clight.program.

  (* THE structural premise: lp is a link of the twelve generated TUs. *)
  Hypothesis H12 : linked12 lp.

  Variable bm : block.    (* Mario's MarioState block *)
  Variable bc : block.    (* the controller struct's block *)
  Variable oc0 : ptrofs.  (* the controller struct's offset within bc *)
  Variable SafeB : block -> Prop.  (* blocks the pointer chase can reach *)

  Notation MWF := (MWF_real lp bm bc oc0 SafeB).

  (* ---- the surviving assumed surface: identical statements to the
     real_mwf capstone's rows (see NoAImpliesNoFlyLinked.v for the
     per-row commentary); ONLY the 12 LO_* pins and Hrest_ext_only are
     absent -- those are now theorems of LinkedTwelve. ---- *)

  (* task #92 tail: Hbc_bm and Hbc_sym are no longer assumed here -- the
     real_mwf capstone DERIVES both internally from the faithful spawn
     condition (Hspawn), so they are absent from this consolidated surface. *)
  (* P5 SLICE 3: ONE consolidated SafeB honest-boundary row + the faithful
     spawn condition REPLACE the eight scattered SafeB rows (HSafeB_not_bm,
     HSafeB_not_bc, the five ~SafeB conjuncts of the *_blk rows, Hsfam_safe).
     The real_mwf capstone derives all eight internally (SpawnInit exports).
     HSafeB_syms (SpawnInit.SafeB_syms_ok): on the linked symbol table SafeB
     avoids SpawnInit.non_safeb_syms (gMarioStates, gControllers, gMarioState,
     gGlobalTimer, the handler / knockback tables, the stored globals) and
     contains sFloorAlignMatrix.  REPAIRED 2026-10-19: it was an iff pinning
     the symbol part to {sFloorAlignMatrix}, which made MWF false of every real
     post-init memory (init_mario_from_save_file stores &gMarioAnimsBuf,
     &gBodyStates[0], &gPlayerCameraState[0] into chase roots; objects point at
     behavior scripts).  Non-vacuous via SpawnInit.safeb_wit_sat. *)
  Hypothesis HSafeB_syms : SafeB_syms_ok lp SafeB.
  (* task #92 slice 6: Hspawn is NO LONGER assumed.  The `exists init,
     init_mem lp = Some init` conjunct of spawn_ok is now a THEOREM for every
     twelve-TU link (InitMemSat.linked12_init_mem, the certificate-shaped
     analogue of linked12_inhabited).  What remains are the three FAITHFUL
     instantiation choices pinning bm/bc/oc0 to the gMarioStates / gControllers
     symbol blocks and offset zero -- each itself provable from linked12
     (SpawnInit.spawn_symbols_resolve) but supplied here because bm/bc/oc0 are
     the capstone's free run-blocks.  From them + linked12_init_mem, Hspawn is
     DERIVED as a Lemma below.  Net: the last dischargeable bucket-B residual
     (init_mem existence) is removed from the assumed surface. *)
  Hypothesis Hbm_sym :
    Genv.find_symbol (lp_ge lp) level_update._gMarioStates = Some bm.
  Hypothesis Hbc_sym :
    Genv.find_symbol (lp_ge lp) mario._gControllers = Some bc.
  Hypothesis Hoc0 : oc0 = Ptrofs.zero.

  Lemma Hspawn : exists init, spawn_ok lp init bm bc oc0.
  Proof.
    destruct (linked12_init_mem lp H12) as (init & Hinit).
    exists init. unfold spawn_ok.
    split; [ exact Hinit | ].
    split; [ exact Hbm_sym | ].
    split; [ exact Hbc_sym | exact Hoc0 ].
  Qed.
  (* P5 SLICE 4: Hglob_valid is DISCHARGED at the real_mwf capstone (from the
     R0 nextblock-bound conjunct via glob_valid_of_nextbound), so it is no
     longer an assumed row here either. *)
  (* the dst-gated writer rows (dg): see NoAImpliesNoFlyLinked *)
  (* PROVED 2026-10-21 (was a row): mtxf_align_terrain_triangle is walked from
     its real math_util body (MtxfBody): it stores floats through its never-
     reassigned arg0 (the gate's SafeB matrix) and into its own stack arrays,
     and its callees (find_floor with &sp74, vec3f_set / _normalize / _cross,
     find_vector_perpendicular_to_plane) are real bodies with stack-local
     destinations.  vec3f_normalize re-reads its saved dest after the external
     sqrtf, so the proof rests on the FPU floor sqrtf_spec (TRUST 3.5), which
     takes the row's place. *)
  Hypothesis Hsq : FpuFloor.sqrtf_spec.
  Lemma Hscp_mtxf_real :
    call_pres_ext_sc lp bm (NoA_real bm) MWF SafeB
      mario_actions_moving._mtxf_align_terrain_triangle.
  Proof. exact (MtxfBody.Hscp_mtxf_proved lp H12 bm bc oc0 SafeB HSafeB_syms Hspawn Hsq). Qed.
  (* PROVED 2026-10-21 (were rows): object_helpers.c is linked (the 20th TU),
     so obj_mark_for_deletion, obj_scale and obj_set_held_state are walked
     from their real bodies (ObjHelpersBodies).  Every store goes through
     arg0, a SafeB block under the cs gate; obj_set_held_state's two pointer
     stores write gCurrentObject's value (a SafeB symbol, so SafeB by MWF's
     load closure) and segmented_to_virtual(arg1).  2026-10-19: obj_set_held_state
     writes through arg0, so its any-argument obj_ext row was false; it was
     restated arg0-gated.  2026-10-21: segmented_to_virtual is now the decomp's
     NO_SEGMENTED_MEMORY identity (TRUST 2.2), so heldBehavior's value is arg1
     itself; an arbitrary arg1 would break R7 (SafeB load-closed), so the row
     was FALSE as stated.  Restated (cs_gate): arg1 is one of the
     bhvCarrySomething3/4/5 symbols, which every real call site passes. *)
  Lemma Hcsp_omfd_real :
    call_pres_ext_cs lp bm (NoA_real bm) MWF SafeB
      mario_actions_cutscene._obj_mark_for_deletion.
  Proof. exact (ObjHelpersBodies.Hcsp_omfd_proved lp H12 bm bc oc0 SafeB HSafeB_syms Hspawn). Qed.
  Lemma Hcsp_scale_real :
    call_pres_ext_cs lp bm (NoA_real bm) MWF SafeB
      mario_actions_cutscene._obj_scale.
  Proof. exact (ObjHelpersBodies.Hcsp_scale_proved lp H12 bm bc oc0 SafeB HSafeB_syms Hspawn). Qed.
  Lemma Hcsp_osh_real :
    call_pres_ext_cs lp bm (NoA_real bm) MWF SafeB
      interaction._obj_set_held_state.
  Proof. exact (ObjHelpersBodies.Hcsp_osh_proved lp H12 bm bc oc0 SafeB HSafeB_syms Hspawn). Qed.
  (* set_camera_mode(c, mode, frames) writes c->mode (and, through the mode
     transition, more of *c) via arg0 (camera.c:2854), so the any-argument
     obj_ext row was FALSE (found 2026-10-20).  Restated arg0-gated (cs):
     every real site passes the chase m->area->camera.  The camera stays a
     labeled deferred premise (docs/TRUST.md 4.1). *)
  (* THE CAMERA LINK (2026-10-22): camera.c is the 35th TU, so the call
     above now resolves to the REAL camera.c body (the row is about that
     body, not an external).  The rest-surface twin: set_camera_mode reached
     from mario.c is a pinned rest case (RestSurface, LO_camera) owing this
     gated residual over the same real body.  PROVED (2026-10-23) from the
     real set_camera_mode body and its callees, 60 bodies (CameraModeBody). *)
  Lemma Hscm_body_real :
    RestSurface.body_pres_w lp MWF bm SafeB camera.f_set_camera_mode.
  Proof.
    exact (CameraModeBody.Hscm_body_proved lp H12 bm bc oc0 SafeB HSafeB_syms Hspawn Hsq).
  Qed.
  (* Hcsp_scm_real is no longer a row (2026-10-22): the call resolves to
     the real camera.c body (camera_defmap_scm, LO_camera), cs_gate's
     arg0_cond_safe IS wgate's T_scm arm (osafe at size 0), and NoA after
     the call is read off MWF (mwf_real_ctl).  So the arg0-gated call row is
     DERIVED from the single gated body row Hscm_body_real. *)
  Lemma wgate_scm : forall vargs,
    arg0_cond_safe SafeB vargs ->
    wgate bm SafeB (type_of_fundef (Internal camera.f_set_camera_mode)) vargs.
  Proof.
    intros vargs Ha. rewrite camera_scm_type. unfold wgate.
    destruct (type_eq T_scm T_ffc) as [E | _];
      [ exfalso; assert (B0 : proj_sumbool (type_eq T_scm T_ffc) = false) by (vm_compute; reflexivity);
        rewrite E in B0; destruct (type_eq T_ffc T_ffc) as [Ee | N]; [ discriminate B0 | exact (N eq_refl) ] | ].
    destruct (type_eq T_scm T_f32w) as [E | _];
      [ exfalso; assert (B0 : proj_sumbool (type_eq T_scm T_f32w) = false) by (vm_compute; reflexivity);
        rewrite E in B0; destruct (type_eq T_f32w T_f32w) as [Ee | N]; [ discriminate B0 | exact (N eq_refl) ] | ].
    destruct (type_eq T_scm T_v3fcopy) as [E | _];
      [ exfalso; assert (B0 : proj_sumbool (type_eq T_scm T_v3fcopy) = false) by (vm_compute; reflexivity);
        rewrite E in B0; destruct (type_eq T_v3fcopy T_v3fcopy) as [Ee | N]; [ discriminate B0 | exact (N eq_refl) ] | ].
    destruct (type_eq T_scm T_v3fset) as [E | _];
      [ exfalso; assert (B0 : proj_sumbool (type_eq T_scm T_v3fset) = false) by (vm_compute; reflexivity);
        rewrite E in B0; destruct (type_eq T_v3fset T_v3fset) as [Ee | N]; [ discriminate B0 | exact (N eq_refl) ] | ].
    destruct (type_eq T_scm T_v3scopy) as [E | _];
      [ exfalso; assert (B0 : proj_sumbool (type_eq T_scm T_v3scopy) = false) by (vm_compute; reflexivity);
        rewrite E in B0; destruct (type_eq T_v3scopy T_v3scopy) as [Ee | N]; [ discriminate B0 | exact (N eq_refl) ] | ].
    destruct (type_eq T_scm T_vfc) as [E | _];
      [ exfalso; assert (B0 : proj_sumbool (type_eq T_scm T_vfc) = false) by (vm_compute; reflexivity);
        rewrite E in B0; destruct (type_eq T_vfc T_vfc) as [Ee | N]; [ discriminate B0 | exact (N eq_refl) ] | ].
    destruct (type_eq T_scm T_scm) as [_ | N]; [ | exfalso; exact (N eq_refl) ].
    intros b o Hv. right.
    destruct vargs as [ | v0 vargs ]; [ discriminate Hv | ].
    exact (Ha b o Hv).
  Qed.
  Lemma Hcsp_scm_real :
    call_pres_ext_cs lp bm (NoA_real bm) MWF SafeB
      interaction._set_camera_mode.
  Proof.
    intros fd m0 vargs0 t0 m1 vres0 Hevf Hres Harg _ HM Hv Hsat.
    rewrite (resolves_pin_fd lp _ _ _ _ (linked12_LO_camera lp H12) camera_defmap_scm Hres)
      in Hevf.
    destruct (Hscm_body_real _ _ _ _ _ (wgate_scm _ (proj1 Harg)) Hevf HM Hv Hsat)
      as (Hv' & Hs' & HM').
    exact (conj Hv' (conj Hs' (conj HM' (mwf_real_ctl lp bm bc oc0 SafeB _ HM')))).
  Qed.
  (* THE ONE OPEN AUDIO PREMISE (labeled, TRUST 4.1; the audio link,
     2026-10-23): load_sequence (audio/load.c, not linked: the sequence DMA
     into the audio heap) keeps the carried facts.  Every music-starting audio
     body reaches it through seq_player_play_sequence (AudioBodies). *)
  Hypothesis Hls : call_pres_ext lp bm (NoA_real bm) MWF audio_external._load_sequence.
  (* THE AUDIO LINK (2026-10-23): the four audio rest bodies, PROVED from
     their real Clight (AudioBodies; play_infinite_stairs_music and
     stop_cap_music reach load_sequence). *)
  Lemma Hps_body_real :
    RestSurface.body_pres_w lp MWF bm SafeB audio_external.f_play_sound.
  Proof. exact (AudioBodies.Hps_body_proved lp H12 bm bc oc0 SafeB HSafeB_syms Hspawn). Qed.
  Lemma Hstcm_body_real :
    RestSurface.body_pres_w lp MWF bm SafeB sound_init.f_stop_cap_music.
  Proof. exact (AudioBodies.Hstcm_body_proved lp H12 bm bc oc0 SafeB HSafeB_syms Hspawn Hls). Qed.
  Lemma Hfcm_body_real :
    RestSurface.body_pres_w lp MWF bm SafeB sound_init.f_fadeout_cap_music.
  Proof. exact (AudioBodies.Hfcm_body_proved lp H12 bm bc oc0 SafeB HSafeB_syms Hspawn). Qed.
  Lemma Hpism_body_real :
    RestSurface.body_pres_w lp MWF bm SafeB sound_init.f_play_infinite_stairs_music.
  Proof. exact (AudioBodies.Hpism_body_proved lp H12 bm bc oc0 SafeB HSafeB_syms Hspawn Hls). Qed.
  (* load_patchable_table: PROVED from its real memory.c body and dma_read's
     (LptBody), down to the libultra DMA calls, whose effect is the
     hardware/OS floor spec (OsDmaFloor, TRUST 3.5). *)
  Hypothesis Hdma_floor : OsDmaFloor.os_dma_floor.
  Lemma Hsma_real :
    DispatchKit.call_pres lp bm (NoA_real bm) MWF mario._set_mario_animation.
  Proof.
    exact (LptBody.sma_row_linked12 lp bm bc oc0 SafeB H12 HSafeB_syms
             Hspawn Hdma_floor).
  Qed.
  Lemma Hsmawa_real :
    ActWriterSurface.call_pres_np3 lp bm (NoA_real bm) MWF mario._set_mario_anim_with_accel.
  Proof.
    exact (LptBody.smawa_row_linked12 lp bm bc oc0 SafeB H12 HSafeB_syms
             Hspawn Hdma_floor).
  Qed.
  (* PROVED 2026-10-22 (was a row, and FALSE as stated): the old row
     quantified over every environment e and type fty, and an env binding
     `sqrtf` to set_mario_action's block refutes it for every twelve-TU link
     (WLExempt.wl_exempt_old_refuted), so this capstone was VACUOUS.  Restated
     at the censused bodies' empty_env and a function-typed Evar (its only
     consumer, CensusV2.chk_call_marg), it is a theorem of the link. *)
  Lemma WL_exempt : wl_exempt_ok lp.
  Proof. exact (WLExempt.wl_exempt_linked12 lp H12). Qed.
  (* PROVED 2026-10-23 (was a row): raise_background_noise,
     lower_background_noise and stop_sound are walked from their real
     sound_init.c / audio/external.c bodies (AudioBodies.audio_rows). *)
  Lemma Hpres_sta_ext : forall fid,
      mem_id fid StationaryLeafSurface.sta_ext_ids = true ->
      call_pres_ext lp bm (NoA_real bm) MWF fid.
  Proof.
    intros fid H. apply (AudioBodies.audio_rows lp H12 bm bc oc0 SafeB HSafeB_syms Hspawn Hls).
    unfold StationaryLeafSurface.sta_ext_ids, mem_id in H. cbn [existsb] in H.
    repeat (apply orb_true_iff in H as [H | H]; [ apply Pos.eqb_eq in H; subst fid; vm_compute; reflexivity | ]).
    discriminate H.
  Qed.
  (* PROVED 2026-10-21 (were rows): spawn_object.c is linked (the 31st TU),
     so spawn_object and spawn_object_abs_with_rot are walked from their
     real bodies (SpawnBodies: create_object / allocate_object /
     try_allocate_object / unload_object / geo_obj_init and the
     object_helpers / math_util / graph_node callees).  FOUND FALSE: their
     any-argument rows (spawn_object stores parent and behavior into a SafeB
     pool object, so an arbitrary pointer argument breaks MWF's load closure
     R7).  Restated all-argument gated (call_pres_ext_sg); every walker
     checks its real call sites.  The walk bottoms out in one unlinked audio
     external, stop_sounds_from_source (unload_object), whose effect is the
     LABELED OPEN AUDIO PREMISE Hsss (audio is deferred; TRUST 4.1): it
     changes no valid block and returns no pointer. *)
  Lemma Hcp_soawr_real : call_pres_ext_sg lp bm (NoA_real bm) MWF SafeB
      mario_actions_cutscene._spawn_object_abs_with_rot.
  Proof.
    exact (SpawnBodies.Hcp_soawr_sg lp H12 bm bc oc0 SafeB HSafeB_syms Hspawn
             (NoA_real bm)).
  Qed.
  (* the any-argument object externals still unlinked (obj_ext_open2_ids:
     the linked entries are proved, obj_ext_open_of2) *)
  Hypothesis Hpres_obj_ext_open2 : forall fid,
      mem_id fid obj_ext_open2_ids = true ->
      call_pres_ext lp bm (NoA_real bm) MWF fid.
  (* the any-argument cutscene externals minus the proved entries
     (cut_ext_open_of2: the time-stop pair, play_transition, and
     save_file_do_save, the last down to the libultra floor Hdma_floor) *)
  Hypothesis Hpres_cut_ext_open2 : forall fid,
      mem_id fid cut_ext_open2_ids = true ->
      call_pres_ext lp bm (NoA_real bm) MWF fid.
  Lemma Hpres_cut_ext_open : forall fid,
      mem_id fid NoAImpliesNoFlyLinked.cut_ext_open_ids = true ->
      call_pres_ext lp bm (NoA_real bm) MWF fid.
  Proof.
    exact (cut_ext_open_of2 lp bm bc oc0 SafeB H12 HSafeB_syms Hspawn Hdma_floor Hls
             Hpres_cut_ext_open2).
  Qed.
  (* PROVED 2026-10-20 (were rows): graph_node.c is linked (the 19th TU), so
     both animation externals are real bodies.  geo_update_animation_frame
     stores only through accelAssist, which the gate pins NULL;
     retrieve_animation_index stores only through its last parameter, which
     the gate puts in a caller stack block (GraphNodeBodies). *)
  Lemma Hgeo_real :
    call_pres_ext_geo lp bm (NoA_real bm) MWF SafeB
      mario._geo_update_animation_frame.
  Proof.
    exact (GraphNodeBodies.Hgeo_proved lp bm bc oc0 SafeB (linked12_LO_graph_node lp H12)).
  Qed.
  Lemma Hocp_rai_real :
    call_pres_ext_oc lp bm (NoA_real bm) MWF SafeB
      mario._retrieve_animation_index.
  Proof.
    destruct Hspawn as (init & Hs).
    exact (GraphNodeBodies.Hocp_rai_proved lp bm bc oc0 SafeB
             (spawn_Hbc_bm lp init bm bc oc0 Hs) (linked12_LO_graph_node lp H12)
             (spawn_Hbc_sym lp init bm bc oc0 Hs)).
  Qed.
  Hypothesis Hpres_floors_ext_open : forall fid,
      mem_id fid floors_ext_open_ids = true ->
      call_pres_ext lp bm (NoA_real bm) MWF fid.
  Lemma Hpres_floors_ext : forall fid,
      mem_id fid floors_ext_ids = true ->
      call_pres_ext lp bm (NoA_real bm) MWF fid.
  Proof.
    intros fid H.
    destruct (NoAImpliesNoFlyLinked.mem_id_filter_split AudioBodies.audio_id fid _ H)
      as [Ha | Ho]; [ | exact (Hpres_floors_ext_open fid Ho) ].
    exact (AudioBodies.audio_rows lp H12 bm bc oc0 SafeB HSafeB_syms Hspawn Hls fid Ha).
  Qed.
  Lemma Hcp_spawn_real : call_pres_ext_sg lp bm (NoA_real bm) MWF SafeB
      behavior_actions._spawn_object.
  Proof.
    exact (SpawnBodies.Hcp_spawn_sg lp H12 bm bc oc0 SafeB HSafeB_syms Hspawn
             (NoA_real bm)).
  Qed.
  Lemma Hpres_obj_ext_open : forall fid,
      mem_id fid NoAImpliesNoFlyLinked.obj_ext_open_ids = true ->
      call_pres_ext lp bm (NoA_real bm) MWF fid.
  Proof.
    exact (obj_ext_open_of2 lp bm bc oc0 SafeB H12 HSafeB_syms Hspawn Hsq Hcp_spawn_real
             Hls Hpres_obj_ext_open2).
  Qed.
  (* PROVED 2026-10-21 (was a row): save_file.c and buffers.c are linked
     (TUs 20 and 21).  save_file_set_cap_pos stores capLevel / capArea through
     saveFile = &gSaveBuffer.files[gCurrSaveFileNum - 1][0] (a pointer into
     gSaveBuffer's block, whatever the file number), then calls the real
     vec3s_set on saveFile->capPos and the real save_file_set_flags, which
     stores the file's flags and gSaveFileModified.  Both globals are
     CensusV2.stored_globals, so every store keeps MWF (SaveFileBody). *)
  Lemma Hcp_savefile_real :
    call_pres_ext lp bm (NoA_real bm) MWF interaction._save_file_set_cap_pos.
  Proof. exact (SaveFileBody.Hcp_savefile_proved lp H12 bm bc oc0 SafeB HSafeB_syms Hspawn). Qed.
  (* PROVED 2026-10-20 (were rows): init_bully_collision_data and
     transfer_bully_speed are mario_step.c bodies, in the link; they store
     only through their pointer parameters, which the gates put in caller
     stack blocks (BullyBodies.Hcpx_ibcd_proved / Hcpx_tbs_proved). *)
  Lemma Hcpx_ibcd_real :
    call_pres_ext_wl lp bm (NoA_real bm) MWF SafeB
      interaction._init_bully_collision_data.
  Proof.
    destruct Hspawn as (init & Hs).
    exact (BullyBodies.Hcpx_ibcd_proved lp bm bc oc0 SafeB
             (spawn_Hbc_bm lp init bm bc oc0 Hs) (linked12_LO_stp lp H12)
             (spawn_Hbc_sym lp init bm bc oc0 Hs)).
  Qed.
  Lemma Hcpx_tbs_real :
    call_pres_ext_ol lp bm (NoA_real bm) MWF SafeB
      interaction._transfer_bully_speed.
  Proof.
    destruct Hspawn as (init & Hs).
    exact (BullyBodies.Hcpx_tbs_proved lp bm bc oc0 SafeB
             (spawn_Hbc_bm lp init bm bc oc0 Hs) (linked12_LO_stp lp H12)
             (spawn_Hbc_sym lp init bm bc oc0 Hs)).
  Qed.
  (* the warp-trigger externals minus the two linked area.c entries
     (warp_ext_of_open) *)
  Hypothesis Hpres_warp_ext_open : forall fid,
      mem_id fid warp_ext_open_ids = true ->
      call_pres_ext lp bm (NoA_real bm) MWF fid.
  Lemma Hpres_warp_ext : forall fid,
      mem_id fid warp_ext_ids = true ->
      call_pres_ext lp bm (NoA_real bm) MWF fid.
  Proof. exact (warp_ext_of_open lp bm bc oc0 SafeB H12 HSafeB_syms Hspawn Hls Hpres_warp_ext_open). Qed.
  (* Hret_unsafe REMOVED (task #99): the v2 engine no longer consumes any
     return-value row (it was dead plumbing / a latent vacuity -- see
     NoAImpliesNoFlyLinked). *)
  (* 2026-10-23 (the print link): print.c is linked (the 42nd TU), so
     print_text_fmt_int resolves to its real body, a pinned rest case whose
     gated residual is PROVED below (PrintBodies).  The two engine rows it
     left, Hext_action_ptfi / Hmwf_ext_ptfi, are GONE:
     RestSurface.rest_external_cases now shows a reached External is a
     resolution of sqrtf alone, the FPU floor (Hsq). *)
  Lemma reached_ext_sqrtf : forall ef targs tres cc,
      reached_v2 lp (External ef targs tres cc) -> CameraBodies.is_sqrtf_ef ef.
  Proof.
    intros ef targs tres cc Hr.
    destruct Hr as [(f & E & _) | [E | Hrest]]; [ discriminate E | discriminate E | ].
    pose proof (rest_external_cases lp
                (linked12_LO_mario lp H12) (linked12_LO_sta lp H12) (linked12_LO_mov lp H12)
                (linked12_LO_air lp H12) (linked12_LO_sub lp H12) (linked12_LO_cut lp H12)
                (linked12_LO_aut lp H12) (linked12_LO_obj lp H12) (linked12_LO_int lp H12)
                (linked12_LO_beh lp H12) (linked12_LO_lvl lp H12) (linked12_LO_stp lp H12)
                (linked12_LO_surf lp H12) (linked12_LO_math lp H12) (linked12_LO_camera lp H12)
                (linked12_LO_audio_external lp H12) (linked12_LO_sound_init lp H12)
                (linked12_LO_print lp H12)
                ef targs tres cc Hrest) as Hs.
    destruct Hs as (b & Hsym & Hff).
    destruct (MtxfBody.xresolve lp math_util.prog math_util._sqrtf [math_util._sqrtf] "sqrtf" b _
                H12 (linked12_LO_math lp H12) ltac:(vm_compute; reflexivity)
                MtxfBody.sqrtf_ni MtxfBody.sqrtf_named Hsym Hff)
      as (sg & targs' & tres' & cc' & E).
    injection E as -> _ _ _. exists sg. reflexivity.
  Qed.
  (* the print_text_fmt_int body, PROVED from print.c + memory.c's
     mem_pool_alloc (PrintBodies): every store lands in a SafeB pool label /
     header (through gEffectsMemoryPool / sTextLabels, CensusV2.print_safe_syms)
     or in a stack local of the print tree *)
  Lemma Hptfi_body_real :
    RestSurface.body_pres_w lp MWF bm SafeB print.f_print_text_fmt_int.
  Proof. exact (PrintBodies.Hptfi_body_proved lp H12 bm bc oc0 SafeB HSafeB_syms Hspawn). Qed.
  Lemma Hext_action_ns : forall ef targs tres cc vargs m t vres m',
      reached_v2 lp (External ef targs tres cc) ->
      ~ CameraBodies.is_sqrtf_ef ef ->
      wgate bm SafeB (type_of_fundef (External ef targs tres cc)) vargs ->
      external_call ef (lp_ge lp) vargs m t vres m' ->
      Mem.unchanged_on (action_cell bm) m m'.
  Proof.
    intros ef targs tres cc vargs m t vres m' Hr Hne.
    exfalso. exact (Hne (reached_ext_sqrtf _ _ _ _ Hr)).
  Qed.
  Lemma Hmwf_ext_ns : forall ef targs tres cc vargs m t vres m',
      reached_v2 lp (External ef targs tres cc) ->
      ~ CameraBodies.is_sqrtf_ef ef ->
      wgate bm SafeB (type_of_fundef (External ef targs tres cc)) vargs ->
      external_call ef (lp_ge lp) vargs m t vres m' ->
      Mem.valid_block m bm -> MWF m -> MWF m'.
  Proof.
    intros ef targs tres cc vargs m t vres m' Hr Hne.
    exfalso. exact (Hne (reached_ext_sqrtf _ _ _ _ Hr)).
  Qed.
  Lemma Hext_action : forall ef targs tres cc vargs m t vres m',
      reached_v2 lp (External ef targs tres cc) ->
      wgate bm SafeB (type_of_fundef (External ef targs tres cc)) vargs ->
      external_call ef (lp_ge lp) vargs m t vres m' ->
      Mem.unchanged_on (action_cell bm) m m'.
  Proof.
    intros ef targs tres cc vargs m t vres m' Hr Hg Hx.
    destruct (CameraBodies.ef_sqrtf_dec ef) as [(sg & ->) | Hne].
    - rewrite (Hsq _ _ _ _ _ _ _ Hx). apply Mem.unchanged_on_refl.
    - exact (Hext_action_ns ef targs tres cc vargs m t vres m' Hr Hne Hg Hx).
  Qed.
  Lemma Hmwf_ext : forall ef targs tres cc vargs m t vres m',
      reached_v2 lp (External ef targs tres cc) ->
      wgate bm SafeB (type_of_fundef (External ef targs tres cc)) vargs ->
      external_call ef (lp_ge lp) vargs m t vres m' ->
      Mem.valid_block m bm -> MWF m -> MWF m'.
  Proof.
    intros ef targs tres cc vargs m t vres m' Hr Hg Hx.
    destruct (CameraBodies.ef_sqrtf_dec ef) as [(sg & ->) | Hne].
    - rewrite (Hsq _ _ _ _ _ _ _ Hx). tauto.
    - exact (Hmwf_ext_ns ef targs tres cc vargs m t vres m' Hr Hne Hg Hx).
  Qed.

  (* ==================================================================== *)
  (* THE TWELVE-TU THEOREM: the real_mwf capstone instantiated with the   *)
  (* link-derived LO pins and negative pin.                               *)
  (* ==================================================================== *)
  Theorem noA_no_spawn_never_flying_linked12 :
    forall (init : mem) (is : list mem) (m : mem),
      mem_ok_lp bm MWF init ->
      Forall (fun i => a_pressed_real bm i = false) is ->
      reachable mem mem (step_real lp) init is m ->
      ~ mem_flying_lp bm m.
  Proof.
    intros init is m Hok HA Hr.
    refine (noA_no_spawn_never_flying_real_mwf lp
             (linked12_LO_mario lp H12)
             bm bc oc0 SafeB (fun _ => false)
             HSafeB_syms Hspawn
             (linked12_LO_surf lp H12) (linked12_LO_math lp H12)
             Hscp_mtxf_real Hcsp_omfd_real Hcsp_scale_real Hcsp_osh_real Hcsp_scm_real Hsma_real Hsmawa_real WL_exempt
             (linked12_LO_sta lp H12) (linked12_LO_mov lp H12)
             (linked12_LO_air lp H12) (linked12_LO_sub lp H12)
             (linked12_LO_cut lp H12) (linked12_LO_aut lp H12)
             (linked12_LO_obj lp H12) (linked12_LO_int lp H12)
             (linked12_LO_beh lp H12) (linked12_LO_lvl lp H12)
             (linked12_LO_stp lp H12)
             (linked12_ext_pin lp H12) (linked12_LO_camera lp H12) Hscm_body_real
             (linked12_LO_audio_external lp H12) (linked12_LO_sound_init lp H12)
             Hstcm_body_real Hfcm_body_real Hps_body_real Hpism_body_real
             (linked12_LO_print lp H12) Hptfi_body_real
             Hpres_sta_ext
             Hcp_soawr_real Hpres_obj_ext_open Hpres_cut_ext_open
             Hgeo_real Hocp_rai_real
             Hpres_floors_ext
             Hcp_spawn_real Hcp_savefile_real Hcpx_ibcd_real Hcpx_tbs_real
             Hpres_warp_ext Hext_action Hmwf_ext
             init is m Hok HA _ Hr).
    apply Forall_forall; reflexivity.
  Qed.

  (* THE PER-FRAME EXPORT over any twelve-TU link (GOAL 2's seg_action
     middle): one real execute_mario_action frame preserves mem_ok_lp,
     on exactly the assumed surface of the capstone above. *)
  Lemma frame_ok_linked12 :
    forall m m',
      mem_ok_lp bm MWF m ->
      execute_mario_action_step_lp lp m m' ->
      mem_ok_lp bm MWF m'.
  Proof.
    exact (frame_ok_real_mwf lp
             (linked12_LO_mario lp H12)
             bm bc oc0 SafeB
             HSafeB_syms Hspawn
             (linked12_LO_surf lp H12) (linked12_LO_math lp H12)
             Hscp_mtxf_real Hcsp_omfd_real Hcsp_scale_real Hcsp_osh_real Hcsp_scm_real Hsma_real Hsmawa_real WL_exempt
             (linked12_LO_sta lp H12) (linked12_LO_mov lp H12)
             (linked12_LO_air lp H12) (linked12_LO_sub lp H12)
             (linked12_LO_cut lp H12) (linked12_LO_aut lp H12)
             (linked12_LO_obj lp H12) (linked12_LO_int lp H12)
             (linked12_LO_beh lp H12) (linked12_LO_lvl lp H12)
             (linked12_LO_stp lp H12)
             (linked12_ext_pin lp H12) (linked12_LO_camera lp H12) Hscm_body_real
             (linked12_LO_audio_external lp H12) (linked12_LO_sound_init lp H12)
             Hstcm_body_real Hfcm_body_real Hps_body_real Hpism_body_real
             (linked12_LO_print lp H12) Hptfi_body_real
             Hpres_sta_ext
             Hcp_soawr_real Hpres_obj_ext_open Hpres_cut_ext_open
             Hgeo_real Hocp_rai_real
             Hpres_floors_ext
             Hcp_spawn_real Hcp_savefile_real Hcpx_ibcd_real Hcpx_tbs_real
             Hpres_warp_ext Hext_action Hmwf_ext).
  Qed.

  (* with its per-call core: every reached call keeps mem_ok (GOAL 2's
     frame split), and MWF pins gMarioState's cell to Mario's block *)
  Lemma frame_call_ok_linked12 :
    (forall m m', mem_ok_lp bm MWF m -> execute_mario_action_step_lp lp m m' ->
                  mem_ok_lp bm MWF m')
    /\ reach_value_preserves_reached_g not_tainted bm (lp_ge lp) (NoA_real bm) MWF
         (call_gate bm SafeB) (reached_v2 lp)
    /\ (forall m, MWF m -> gms_cond_lp lp m bm)
    /\ chase_safe_stmt bm SafeB MWF /\ store_safe_stmt lp bm SafeB MWF.
  Proof.
    exact (frame_call_ok_real_mwf lp
             (linked12_LO_mario lp H12)
             bm bc oc0 SafeB
             HSafeB_syms Hspawn
             (linked12_LO_surf lp H12) (linked12_LO_math lp H12)
             Hscp_mtxf_real Hcsp_omfd_real Hcsp_scale_real Hcsp_osh_real Hcsp_scm_real Hsma_real Hsmawa_real WL_exempt
             (linked12_LO_sta lp H12) (linked12_LO_mov lp H12)
             (linked12_LO_air lp H12) (linked12_LO_sub lp H12)
             (linked12_LO_cut lp H12) (linked12_LO_aut lp H12)
             (linked12_LO_obj lp H12) (linked12_LO_int lp H12)
             (linked12_LO_beh lp H12) (linked12_LO_lvl lp H12)
             (linked12_LO_stp lp H12)
             (linked12_ext_pin lp H12) (linked12_LO_camera lp H12) Hscm_body_real
             (linked12_LO_audio_external lp H12) (linked12_LO_sound_init lp H12)
             Hstcm_body_real Hfcm_body_real Hps_body_real Hpism_body_real
             (linked12_LO_print lp H12) Hptfi_body_real
             Hpres_sta_ext
             Hcp_soawr_real Hpres_obj_ext_open Hpres_cut_ext_open
             Hgeo_real Hocp_rai_real
             Hpres_floors_ext
             Hcp_spawn_real Hcp_savefile_real Hcpx_ibcd_real Hcpx_tbs_real
             Hpres_warp_ext Hext_action Hmwf_ext).
  Qed.

  (* the airborne handlers one by one, for GOAL 2's dispatcher split *)
  Lemma air_leaves_linked12 :
    forall fid f, mem_id fid AirborneSurface.airborne_callee_ids = true ->
      (prog_defmap mario_actions_airborne.prog) ! fid = Some (Gfun (Internal f)) ->
      body_pres lp (NoA_real bm) MWF bm f.
  Proof.
    exact (air_leaves_real_mwf lp (linked12_LO_mario lp H12) bm bc oc0 SafeB
             HSafeB_syms Hspawn (linked12_LO_surf lp H12) (linked12_LO_math lp H12)
             Hcsp_osh_real Hcsp_scm_real Hsma_real (linked12_LO_air lp H12) (linked12_LO_int lp H12)
             (linked12_LO_lvl lp H12) (linked12_LO_stp lp H12)
             Hpres_obj_ext_open Hpres_floors_ext Hcp_spawn_real Hcp_savefile_real
             Hpres_warp_ext).
  Qed.

  (* GOAL 2's AutoSplit: the automatic handlers one by one, and the
     window store (quicksandDepth = 0) *)
  Lemma auto_leaves_linked12 :
    forall fid f, mem_id fid AutomaticSurface.automatic_callee_ids = true ->
      (prog_defmap mario_actions_automatic.prog) ! fid = Some (Gfun (Internal f)) ->
      body_pres lp (NoA_real bm) MWF bm f.
  Proof.
    exact (auto_leaves_real_mwf lp (linked12_LO_mario lp H12) bm bc oc0 SafeB
             HSafeB_syms Hspawn (linked12_LO_surf lp H12) (linked12_LO_math lp H12)
             Hcsp_scm_real Hsma_real Hsmawa_real (linked12_LO_aut lp H12)
             (linked12_LO_stp lp H12) Hpres_obj_ext_open Hgeo_real Hocp_rai_real).
  Qed.

  Lemma mwf_window_linked12 : forall mm mm' ch (delta : Z) vv,
      MWF mm -> store_window_ok delta (size_chunk ch) = true ->
      Mem.store ch mm bm delta vv = Some mm' -> MWF mm'.
  Proof. exact (mwf_window_real_mwf lp bm bc oc0 SafeB HSafeB_syms Hspawn). Qed.

  (* ==================================================================== *)
  (* FROM BOOT (2026-10-19, phantom-forall guard): the capstone's start   *)
  (* premise mem_ok_lp is not just assumed -- it HOLDS of the memory the  *)
  (* real game builds: the 12-TU boot image (Genv.init_mem lp) followed  *)
  (* by one real call of init_mario_from_save_file (BootMWF.boot_init_ok, *)
  (* proved from the generated Clight; every store and the one call in   *)
  (* its body walked).  SafeB is instantiated to BootMWF.SafeB_boot (all *)
  (* blocks but the non_safeb_syms globals), which satisfies HSafeB_syms. *)
  (* The star-count call is the real save_file.c reader, proved          *)
  (* (ObjExtBodies.Hpx_total_star_count, 2026-10-21).                    *)
  (* ==================================================================== *)
  Lemma boot_init_mem_ok : SafeB = BootMWF.SafeB_boot lp ->
    forall m0 fd t m1 vres,
      Genv.init_mem lp = Some m0 ->
      eval_funcall function_entry2 (lp_ge lp) m0 fd nil t m1 vres ->
      resolves_lp lp mario._init_mario_from_save_file fd ->
      mem_ok_lp bm MWF m1.
  Proof.
    intros HSB m0 fd t m1 vres Hinit Hev Hres.
    pose proof (ObjExtBodies.Hpx_total_star_count lp H12 bm bc oc0 SafeB HSafeB_syms Hspawn)
      as Hsf.
    unfold mem_ok_lp. rewrite Hoc0, HSB in *.
    exact (BootMWF.boot_init_ok lp H12 m0 bm bc Hinit Hbm_sym Hbc_sym Hsf
             fd t m1 vres Hev Hres).
  Qed.

  Theorem noA_never_flying_from_boot : SafeB = BootMWF.SafeB_boot lp ->
    forall m0 fd t m1 vres (is : list mem) (m : mem),
      Genv.init_mem lp = Some m0 ->
      eval_funcall function_entry2 (lp_ge lp) m0 fd nil t m1 vres ->
      resolves_lp lp mario._init_mario_from_save_file fd ->
      Forall (fun i => a_pressed_real bm i = false) is ->
      reachable mem mem (step_real lp) m1 is m ->
      ~ mem_flying_lp bm m.
  Proof.
    intros HSB m0 fd t m1 vres is m Hinit Hev Hres HA Hr.
    exact (noA_no_spawn_never_flying_linked12 m1 is m
             (boot_init_mem_ok HSB m0 fd t m1 vres Hinit Hev Hres) HA Hr).
  Qed.

End NoAImpliesNoFlyTwelve.
