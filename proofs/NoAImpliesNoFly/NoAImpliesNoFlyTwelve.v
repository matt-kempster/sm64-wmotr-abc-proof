(* spine-root: the TWELVE-TU GOAL-1 capstone -- the sharpest statement:
   the 12 LO pins + the 16-id negative pin are DERIVED from the single
   linked12 chain premise (LinkedTwelve), live since the #95 repair. *)
(* ====================================================================== *)
(* LIVE since the #95 repair: the negative pin now covers only the         *)
(* sixteen genuinely-external whitelist ids (exempt_ext_ids), so           *)
(* linked12_ext_pin discharges it for any twelve-TU link.                  *)
(* ====================================================================== *)
(* THE TWELVE-TU CAPSTONE (SPINE: P3 slice 2, the sharpest GOAL-1          *)
(* statement).                                                             *)
(*                                                                        *)
(* Same conclusion as noA_no_spawn_never_flying_real_mwf, but the 12      *)
(* per-TU linkorder pins and the negative pin Hrest_ext_only are GONE     *)
(* from the assumed surface: they are DERIVED (LinkedTwelve.v) from the   *)
(* single structural premise                                              *)
(*                                                                        *)
(*   linked12 lp   --   lp IS a CompCert link of THE twelve               *)
(*                      mechanically-clightgen'd SM64 TUs                 *)
(*                                                                        *)
(* so the theorem now reads: ANY link of the twelve generated TUs, from   *)
(* a well-formed spawn, under never-A inputs, never reaches a flying      *)
(* action.  Assumed surface: 56 -> 43 rows (12 LO_* + Hrest_ext_only      *)
(* deleted; +1 linked12).  The remaining rows are the runtime-layout      *)
(* facts (bm/bc/SafeB distinctness, init validity), the gated             *)
(* terminal-external model boundary, WL_exempt (env hygiene), and the     *)
(* Hret_unsafe / Hext_action / Hmwf_ext engine rows -- see                *)
(* docs/director-roadmap-2026-07-01.md for the ledger.                    *)
(*                                                                        *)
(* Non-vacuity of linked12 (that the twelve TUs actually link) is the     *)
(* explicit remaining P3 question, tracked in LinkedTwelve.v's header.    *)
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
From SM64.Proofs Require Import NoAImpliesNoFlyLinked.

Section NoAImpliesNoFlyTwelve.
  Variable lp : Clight.program.

  (* THE structural premise: lp is a link of the twelve generated TUs. *)
  Hypothesis H12 : linked12 lp.

  Variable bm : block.    (* Mario's MarioState block *)
  Variable bc : block.    (* the controller struct's block *)
  Variable oc0 : ptrofs.  (* the controller struct's offset within bc *)
  Variable SafeB : block -> Prop.  (* blocks the pointer chase can reach *)
  Variable spawn_flying : mem -> bool.

  Notation MWF := (MWF_real lp bm bc oc0 SafeB).

  (* ---- the surviving assumed surface: identical statements to the
     real_mwf capstone's rows (see NoAImpliesNoFlyLinked.v for the
     per-row commentary); ONLY the 12 LO_* pins and Hrest_ext_only are
     absent -- those are now theorems of LinkedTwelve. ---- *)

  Hypothesis Hbc_bm : bc <> bm.
  (* P5 SLICE 3: ONE consolidated SafeB honest-boundary row + the faithful
     spawn condition REPLACE the eight scattered SafeB rows (HSafeB_not_bm,
     HSafeB_not_bc, the five ~SafeB conjuncts of the *_blk rows, Hsfam_safe).
     The real_mwf capstone derives all eight internally (SpawnInit exports).
     HSafeB_sym_iff: the intersection of SafeB with the linked symbol table is
     exactly {sFloorAlignMatrix} (the object pool is external/runtime -- see
     docs/p5-safeb-design.md); non-vacuous via SpawnInit.safeb_wit_sat. *)
  Hypothesis HSafeB_sym_iff :
    forall id b,
      Genv.find_symbol (lp_ge lp) id = Some b ->
      (SafeB b <-> id = mario_actions_moving._sFloorAlignMatrix).
  Hypothesis Hspawn : exists init, spawn_ok lp init bm bc oc0.
  Hypothesis Hbc_sym :
    exists gid, Genv.find_symbol (lp_ge lp) gid = Some bc.
  Hypothesis Hglob_valid :
    forall m, MWF m -> forall gid bg,
        Genv.find_symbol (lp_ge lp) gid = Some bg -> Mem.valid_block m bg.
  Hypothesis Hocp_find_floor :
    call_pres_ext_oc lp bm (NoA_real bm) MWF SafeB mario._find_floor.
  Hypothesis Hocp_find_ceil :
    call_pres_ext_oc lp bm (NoA_real bm) MWF SafeB
      mario_actions_automatic._vec3f_find_ceil.
  Hypothesis Hwolcp_fwc :
    call_pres_ext_wol lp bm (NoA_real bm) MWF SafeB
      mario_actions_automatic._f32_find_wall_collision.
  Hypothesis Hscp_v3f :
    call_pres_ext_sc lp bm (NoA_real bm) MWF SafeB
      mario_actions_automatic._vec3f_copy.
  Hypothesis Hscp_v3s :
    call_pres_ext_sc lp bm (NoA_real bm) MWF SafeB
      mario_actions_automatic._vec3s_set.
  Hypothesis Hwlcp_v3f_real :
    call_pres_ext_wl lp bm (NoA_real bm) MWF SafeB
      mario_actions_automatic._vec3f_copy.
  Hypothesis WL_exempt : forall e le m fid fty vf fd,
      mem_id fid exempt_callees = true ->
      eval_expr (lp_ge lp) e le m (Evar fid fty) vf ->
      Genv.find_funct (lp_ge lp) vf = Some fd ->
      marg_exempt fd = true.
  Hypothesis Hpres_sta_ext : forall fid,
      mem_id fid StationaryLeafSurface.sta_ext_ids = true ->
      call_pres_ext lp bm (NoA_real bm) MWF fid.
  Hypothesis Hpres_mov_ext : forall fid,
      mem_id fid MovingLeafSurface.mov_ext_ids = true ->
      call_pres_ext lp bm (NoA_real bm) MWF fid.
  Hypothesis Hcpx_approach_f32_real :
    call_pres_ext lp bm (NoA_real bm) MWF
      mario_actions_airborne._approach_f32.
  Hypothesis Hw1cp_v3sset_real :
    call_pres_ext_w1 lp bm (NoA_real bm) MWF
      mario._vec3s_set.
  Hypothesis Hglob_obj_root :
    forall g gb m b o,
      mem_id g CutsceneLeafSurface.gobj_ids = true ->
      MWF m ->
      Genv.find_symbol (lp_ge lp) g = Some gb ->
      Mem.loadv Mptr m (Vptr gb Ptrofs.zero) = Some (Vptr b o) ->
      SafeB b.
  Hypothesis Hpres_obj_ext : forall fid,
      mem_id fid obj_ext_ids = true ->
      call_pres_ext lp bm (NoA_real bm) MWF fid.
  Hypothesis Hpres_cut_ext : forall fid,
      mem_id fid CutsceneLeafSurface.cut_ext_ids = true ->
      call_pres_ext lp bm (NoA_real bm) MWF fid.
  Hypothesis Hxcp_fwl_real :
    call_pres_ext lp bm (NoA_real bm) MWF mario_step._find_water_level.
  Hypothesis Hscp_geo_real :
    call_pres_ext_sc lp bm (NoA_real bm) MWF SafeB
      mario._geo_update_animation_frame.
  Hypothesis Hocp_rai_real :
    call_pres_ext_oc lp bm (NoA_real bm) MWF SafeB
      mario._retrieve_animation_index.
  Hypothesis Hcpx_approach_real :
    call_pres_ext lp bm (NoA_real bm) MWF
      mario_actions_automatic._approach_s32.
  Hypothesis Holcp_fwc_real :
    call_pres_ext_ol lp bm (NoA_real bm) MWF SafeB
      mario._find_wall_collisions.
  Hypothesis Hw1cp_v3f_real :
    call_pres_ext_w1 lp bm (NoA_real bm) MWF
      mario_actions_automatic._vec3f_copy.
  Hypothesis Hwolcp_v3f_real :
    call_pres_ext_wol lp bm (NoA_real bm) MWF SafeB
      mario_actions_automatic._vec3f_copy.
  Hypothesis Hw1cp_v3fset_real :
    call_pres_ext_w1 lp bm (NoA_real bm) MWF
      mario_actions_automatic._vec3f_set.
  Hypothesis Hscp_v3fset_real :
    call_pres_ext_sc lp bm (NoA_real bm) MWF SafeB
      mario_actions_automatic._vec3f_set.
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
  Hypothesis Hret_unsafe : forall fd m0 vargs0 t0 m0' vres0,
      reached_v2 lp fd ->
      RetSurface.ret_fd_safe fd = false ->
      RetSurface.fd_is_vint fd = false ->
      eval_funcall function_entry2 (lp_ge lp) m0 fd vargs0 t0 m0' vres0 ->
      forall b o, vres0 = Vptr b o -> b <> bm.
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
      Forall (fun i => spawn_flying i = false) is ->
      reachable mem mem (step_real lp) init is m ->
      ~ mem_flying_lp bm m.
  Proof.
    exact (noA_no_spawn_never_flying_real_mwf lp
             (linked12_LO_mario lp H12)
             bm bc oc0 SafeB spawn_flying
             Hbc_bm HSafeB_sym_iff Hspawn
             Hbc_sym Hglob_valid
             Hocp_find_floor Hocp_find_ceil Hwolcp_fwc Hscp_v3f Hscp_v3s
             Hwlcp_v3f_real WL_exempt
             (linked12_LO_sta lp H12) (linked12_LO_mov lp H12)
             (linked12_LO_air lp H12) (linked12_LO_sub lp H12)
             (linked12_LO_cut lp H12) (linked12_LO_aut lp H12)
             (linked12_LO_obj lp H12) (linked12_LO_int lp H12)
             (linked12_LO_beh lp H12) (linked12_LO_lvl lp H12)
             (linked12_LO_stp lp H12)
             (linked12_ext_pin lp H12)
             Hpres_sta_ext Hpres_mov_ext Hcpx_approach_f32_real
             Hw1cp_v3sset_real Hglob_obj_root Hpres_obj_ext Hpres_cut_ext
             Hxcp_fwl_real Hscp_geo_real Hocp_rai_real Hcpx_approach_real
             Holcp_fwc_real Hw1cp_v3f_real Hwolcp_v3f_real Hw1cp_v3fset_real
             Hscp_v3fset_real Hpres_floors_ext
             Hcp_spawn_real Hcp_savefile_real Hcpx_ibcd_real Hcpx_tbs_real
             Hpres_warp_ext Hret_unsafe Hext_action Hmwf_ext).
  Qed.

End NoAImpliesNoFlyTwelve.
