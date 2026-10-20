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
(* WL_exempt (env hygiene), and the Hext_action / Hmwf_ext engine rows.   *)
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
  interaction behavior_actions level_update mario_step.
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
From SM64.Proofs Require OsDmaFloor LptBody BootMWF.

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
  Hypothesis Hscp_mtxf_real :
    call_pres_ext_sc lp bm (NoA_real bm) MWF SafeB
      mario_actions_moving._mtxf_align_terrain_triangle.
  Hypothesis Hcsp_omfd_real :
    call_pres_ext_cs lp bm (NoA_real bm) MWF SafeB
      mario_actions_cutscene._obj_mark_for_deletion.
  Hypothesis Hcsp_scale_real :
    call_pres_ext_cs lp bm (NoA_real bm) MWF SafeB
      mario_actions_cutscene._obj_scale.
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
  Hypothesis WL_exempt : forall e le m fid fty vf fd,
      mem_id fid exempt_callees = true ->
      eval_expr (lp_ge lp) e le m (Evar fid fty) vf ->
      Genv.find_funct (lp_ge lp) vf = Some fd ->
      marg_exempt fd = true.
  Hypothesis Hpres_sta_ext : forall fid,
      mem_id fid StationaryLeafSurface.sta_ext_ids = true ->
      call_pres_ext lp bm (NoA_real bm) MWF fid.
  Hypothesis Hglob_obj_root :
    forall g gb m b o,
      mem_id g CutsceneLeafSurface.gobj_ids = true ->
      MWF m ->
      Genv.find_symbol (lp_ge lp) g = Some gb ->
      Mem.loadv Mptr m (Vptr gb Ptrofs.zero) = Some (Vptr b o) ->
      SafeB b.
  Hypothesis Hpres_obj_ext_open : forall fid,
      mem_id fid NoAImpliesNoFlyLinked.obj_ext_open_ids = true ->
      call_pres_ext lp bm (NoA_real bm) MWF fid.
  Hypothesis Hpres_cut_ext : forall fid,
      mem_id fid CutsceneLeafSurface.cut_ext_ids = true ->
      call_pres_ext lp bm (NoA_real bm) MWF fid.
  Hypothesis Hgeo_real :
    call_pres_ext_geo lp bm (NoA_real bm) MWF SafeB
      mario._geo_update_animation_frame.
  Hypothesis Hocp_rai_real :
    call_pres_ext_oc lp bm (NoA_real bm) MWF SafeB
      mario._retrieve_animation_index.
  Hypothesis Hpres_floors_ext : forall fid,
      mem_id fid floors_ext_ids = true ->
      call_pres_ext lp bm (NoA_real bm) MWF fid.
  Hypothesis Hcp_spawn_real : call_pres_ext_sr lp bm (NoA_real bm) MWF SafeB
      behavior_actions._spawn_object.
  Hypothesis Hcp_savefile_real :
    call_pres_ext lp bm (NoA_real bm) MWF interaction._save_file_set_cap_pos.
  Hypothesis Hcpx_ibcd_real :
    call_pres_ext_wl lp bm (NoA_real bm) MWF SafeB
      interaction._init_bully_collision_data.
  Hypothesis Hcpx_tbs_real :
    call_pres_ext_ol lp bm (NoA_real bm) MWF SafeB
      interaction._transfer_bully_speed.
  Hypothesis Hpres_warp_ext : forall fid,
      mem_id fid warp_ext_ids = true ->
      call_pres_ext lp bm (NoA_real bm) MWF fid.
  (* Hret_unsafe REMOVED (task #99): the v2 engine no longer consumes any
     return-value row (it was dead plumbing / a latent vacuity -- see
     NoAImpliesNoFlyLinked). *)
  Hypothesis Hext_action : forall ef targs tres cc vargs m t vres m',
      reached_v2 lp (External ef targs tres cc) ->
      external_call ef (lp_ge lp) vargs m t vres m' ->
      Mem.unchanged_on (action_cell bm) m m'.
  Hypothesis Hmwf_ext : forall ef targs tres cc vargs m t vres m',
      reached_v2 lp (External ef targs tres cc) ->
      external_call ef (lp_ge lp) vargs m t vres m' ->
      Mem.valid_block m bm -> MWF m -> MWF m'.

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
             Hscp_mtxf_real Hcsp_omfd_real Hcsp_scale_real Hsma_real Hsmawa_real WL_exempt
             (linked12_LO_sta lp H12) (linked12_LO_mov lp H12)
             (linked12_LO_air lp H12) (linked12_LO_sub lp H12)
             (linked12_LO_cut lp H12) (linked12_LO_aut lp H12)
             (linked12_LO_obj lp H12) (linked12_LO_int lp H12)
             (linked12_LO_beh lp H12) (linked12_LO_lvl lp H12)
             (linked12_LO_stp lp H12)
             (linked12_ext_pin lp H12)
             Hpres_sta_ext
             Hglob_obj_root Hpres_obj_ext_open Hpres_cut_ext
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
             Hscp_mtxf_real Hcsp_omfd_real Hcsp_scale_real Hsma_real Hsmawa_real WL_exempt
             (linked12_LO_sta lp H12) (linked12_LO_mov lp H12)
             (linked12_LO_air lp H12) (linked12_LO_sub lp H12)
             (linked12_LO_cut lp H12) (linked12_LO_aut lp H12)
             (linked12_LO_obj lp H12) (linked12_LO_int lp H12)
             (linked12_LO_beh lp H12) (linked12_LO_lvl lp H12)
             (linked12_LO_stp lp H12)
             (linked12_ext_pin lp H12)
             Hpres_sta_ext
             Hglob_obj_root Hpres_obj_ext_open Hpres_cut_ext
             Hgeo_real Hocp_rai_real
             Hpres_floors_ext
             Hcp_spawn_real Hcp_savefile_real Hcpx_ibcd_real Hcpx_tbs_real
             Hpres_warp_ext Hext_action Hmwf_ext).
  Qed.

  (* ==================================================================== *)
  (* FROM BOOT (2026-10-19, phantom-forall guard): the capstone's start   *)
  (* premise mem_ok_lp is not just assumed -- it HOLDS of the memory the  *)
  (* real game builds: the 12-TU boot image (Genv.init_mem lp) followed  *)
  (* by one real call of init_mario_from_save_file (BootMWF.boot_init_ok, *)
  (* proved from the generated Clight; every store and the one call in   *)
  (* its body walked).  SafeB is instantiated to BootMWF.SafeB_boot (all *)
  (* blocks but the non_safeb_syms globals), which satisfies HSafeB_syms. *)
  (* The star-count call is the capstone's own object-external row.      *)
  (* ==================================================================== *)
  Lemma sfstar_open :
    mem_id mario._save_file_get_total_star_count
      NoAImpliesNoFlyLinked.obj_ext_open_ids = true.
  Proof. vm_compute. reflexivity. Qed.

  Lemma boot_init_mem_ok : SafeB = BootMWF.SafeB_boot lp ->
    forall m0 fd t m1 vres,
      Genv.init_mem lp = Some m0 ->
      eval_funcall function_entry2 (lp_ge lp) m0 fd nil t m1 vres ->
      resolves_lp lp mario._init_mario_from_save_file fd ->
      mem_ok_lp bm MWF m1.
  Proof.
    intros HSB m0 fd t m1 vres Hinit Hev Hres.
    pose proof (Hpres_obj_ext_open _ sfstar_open) as Hsf.
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
