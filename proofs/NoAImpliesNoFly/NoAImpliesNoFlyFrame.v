(* spine-root: GOAL 1 OVER THE WHOLE FRAME -- no A => never flying, where
   one step is GOAL 2's real frame (poll, level slices, the objects phase
   with Mario's execute_mario_action inside it, the render), not
   execute_mario_action alone. *)
(* ====================================================================== *)
(* GOAL 1 OVER THE WHOLE FRAME (2026-10-26, skeleton; TRUST 0.5).         *)
(*                                                                        *)
(* WHAT IT SAYS: on a twelve-TU link, start from a memory with GOAL 1's   *)
(* mem_ok_lp and GOAL 2's frame-boundary facts (PhiW, the platform fact,  *)
(* the object world: met by a memory built from the real boot image,     *)
(* StartSat.goal2_start_sat), and run HeightFrame.frame_step -- the real  *)
(* controller poll, play_mode_normal's level slices around ONE real       *)
(* area_update_objects call (every object's update, and Mario's           *)
(* execute_mario_action inside it), Mario's render call -- with the       *)
(* controller hardware's reply showing A on no live port before every    *)
(* frame.  Then at every frame boundary Mario's action is not a flying    *)
(* one.  GOAL 1's older capstone (NoAImpliesNoFlyTwelve) steps            *)
(* execute_mario_action ALONE: object behaviours, the level code and the  *)
(* camera, which also write Mario's state, were outside its step.         *)
(*                                                                        *)
(* HOW: GOAL 2's frame proof carries GOAL 1's mem_ok through every phase  *)
(* (HeightFrame.wmotr_noA_run_ok_linked12), and mem_ok keeps the action   *)
(* outside the no-A taint set T = {ACT_FLYING, ACT_FLYING_TRIPLE_JUMP,    *)
(* ACT_SHOT_FROM_CANNON} (mem_ok_not_flying_lp).  The phases' GOAL-1      *)
(* carries are PROVED: the poll (PollFlank / PollKeep / MidKeep), the     *)
(* level slices (LevelKeep: update_camera keeps mem_ok by the real        *)
(* camera.c), Mario's frame (GOAL 1's proved frame), the platform call    *)
(* and the render call.  What is OPEN is the rows below, the same rows   *)
(* as GOAL 2's capstone.                                                  *)
(*                                                                        *)
(* WHAT GOAL 1 NEEDS FROM EACH OPEN ROW.  The frame-boundary invariant is *)
(* shared with GOAL 2 (HeightFrame.fb_ok = mem_ok /\ PhiW /\ plat_still   *)
(* /\ obj_w), and GOAL 1 cannot drop PhiW today: the level slices' mem_ok *)
(* carries READ it (LevelKeep.pre_eff / post_split: lvl_w -- no pending   *)
(* warp, no demo -- and floor_safe -- Mario's floor is a WMotR floor type,*)
(* so the instant and painting warp guards are no-ops; FfWorld.area_w for *)
(* update_camera's argument).  So each row is needed in its full form,   *)
(* and its GOAL-1 content is:                                             *)
(*  - Hobj_step_terrain / Hobj_step_nonterrain (one object's update,     *)
(*    cur_obj_update: its behavior script and natives) -- THE KEY ROW:   *)
(*    no object sets Mario's action into T.  MACHINE-CHECKED on the      *)
(*    generated code (ActWriterCensus.census_value, 2026-10-26): in the  *)
(*    closure of area_update_objects and update_camera (Mario's frame    *)
(*    cut; indirect calls by exact function type, a UB-coverage point,  *)
(*    TRUST 3.2) the only action events                                  *)
(*    are set_mario_action's own store and set_mario_npc_dialog's call   *)
(*    with ACT_READING_NPC_DIALOG.  From the C: no object behavior,      *)
(*    object helper or camera code                                       *)
(*    calls set_mario_action on Mario; they reach Mario's action only    *)
(*    through set_mario_npc_dialog (ACT_READING_NPC_DIALOG, not in T;    *)
(*    koopa, bowser, mips, bobomb, yoshi, hoot, ...); mario_set_flag     *)
(*    (gMarioStates[0].flags |= flag) has no caller.  THE CANNON: the    *)
(*    base object only advances its own oAction and position (opening,   *)
(*    rising while Mario is inside); ACT_SHOT_FROM_CANNON is set by       *)
(*    Mario's own act_in_cannon (mario_actions_automatic.c:743), behind  *)
(*    `m->input & INPUT_A_PRESSED`, i.e. inside the hole, where GOAL 1's *)
(*    frame proof covers it.  Plus: the update keeps MWF_real (its       *)
(*    pointer stores into Mario's chase are SafeB pool slots).           *)
(*  - Hobj_collisions (detect_object_collisions): Mario's object's      *)
(*    collided list, which the next Mario frame's interactions read,     *)
(*    holds SafeB pool slots (MWF_real's chase).                          *)
(*  - Hobj_surfaces (clear_dynamic_surfaces): Mario's floor / wall /    *)
(*    ceiling pointers into the dynamic pool stay chase-safe after the   *)
(*    pool counts drop back.                                              *)
(*  - Hobj_unload (unload_deactivated_objects): an unloaded slot that    *)
(*    Mario's usedObj / heldObj / riddenObj names is still a SafeB pool  *)
(*    slot.                                                               *)
(*  - Hobj_mplat (update_mario_platform): writes gMarioPlatform and      *)
(*    Mario's object's platform field only; no MarioState cell.          *)
(*  - Hobj_debug, Hobj_blind / Hobj_fresh / Hobj_noref, Hobj_stores /    *)
(*    Hobj_counter / Hobj_ctr: the debug calls (off) and the phase's own *)
(*    stores (counters, gTimeStopState, the stack array) write no         *)
(*    MarioState cell and no MWF_real cell.                               *)
(*  - Hseg_na_open (Mario's frame, GOAL 2's per-call PhiW rows): GOAL 1  *)
(*    needs only the world part (Mario's floor type, lvl_w, area_w, the  *)
(*    frame world), not the height budget, but FrameSplit carries them   *)
(*    jointly, so the row is needed whole.                                *)
(*  - Hcam_phi (update_camera keeps PhiW): GOAL 1 needs floor_safe and   *)
(*    lvl_w after the camera (the painting call's guard and the next     *)
(*    frame's); the camera's own mem_ok carry is PROVED.                 *)
(*  - Hcam_ow (update_camera keeps obj_w): needed only because the      *)
(*    object rows are stated over a Pobj that contains obj_w.            *)
(*  - Hls, Hdma_floor, Hdma_anim, Hsqrtf, Hsqrtf_float: GOAL 1's own     *)
(*    model-boundary rows (audio load_sequence, the OS DMA floor, sqrtf).*)
(* ====================================================================== *)

From compcert Require Import Coqlib Maps AST Integers Values Events Memory Globalenvs
  Ctypes Clight ClightBigstep.
From Coq Require Import List. Import ListNotations.
From SM64.Generated Require mario level_update object_list_processor.
From SM64.Proofs Require Import ReachableRun RealFrameLinked LinkedTwelve SpawnInit MWFReal.
From SM64.Proofs Require Import NoAImpliesNoFlyLinked.
From SM64.Proofs Require FpuFloor OsDmaFloor.
From SM64.Proofs.WMotRRequiresA Require NaSplit ExtInert LsContract LevelKeep LevelFlank
  ObjPhase ObjLoop ObjWorld FrameCalls PlatformKeep PollFlank HeightFrame.

Section NoAImpliesNoFlyFrame.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Variables (bm bc : block) (oc0 : ptrofs) (SafeB : block -> Prop).

  Notation MWF := (MWF_real lp bm bc oc0 SafeB).
  Notation Phi := (HeightFrame.PhiW lp bm).
  Notation OWl := (ObjWorld.obj_w (lp_ge lp) bm).
  Notation Pobjl := (HeightFrame.Pobj lp bm MWF Phi OWl).

  (* the instantiation (as in GOAL 1's twelve-TU capstone) *)
  Hypothesis HSafeB_syms : SafeB_syms_ok lp SafeB.
  Hypothesis Hbm_sym : Genv.find_symbol (lp_ge lp) level_update._gMarioStates = Some bm.
  Hypothesis Hbc_sym : Genv.find_symbol (lp_ge lp) mario._gControllers = Some bc.
  Hypothesis Hoc0 : oc0 = Ptrofs.zero.

  (* the model-boundary rows *)
  Hypothesis Hls : LsContract.ls_contract lp bm (NoA_real bm) MWF.
  Hypothesis Hdma_floor : OsDmaFloor.os_dma_floor.
  Hypothesis Hseg_na_open : NaSplit.na_open_rows lp bm MWF.
  Hypothesis Hdma_anim : OsDmaFloor.pi_dma_anim_spec.
  Hypothesis Hsqrtf : FpuFloor.sqrtf_spec.
  Hypothesis Hsqrtf_float : ExtInert.sqrtf_float.

  (* the camera rows *)
  Hypothesis Hcam_phi : LevelKeep.cam_phi_row lp bm MWF.

  (* the objects phase's rows (HeightFrame's HeightLinked12 section has the
     commentary; above: what GOAL 1 needs from each) *)
  Hypothesis Hobj_blind : forall b m m', Ple (Genv.genv_next (lp_ge lp)) b -> Pobjl m ->
    ObjPhase.noref b m -> Mem.unchanged_on (fun b' _ => b' <> b) m m' -> Pobjl m'.
  Hypothesis Hobj_fresh : forall sz m m1 b, Pobjl m -> Mem.alloc m 0 sz = (m1, b) ->
    Ple (Genv.genv_next (lp_ge lp)) b /\ ObjPhase.noref b m1.
  Hypothesis Hobj_noref : forall b f, In f ObjPhase.uo_callees -> Ple (Genv.genv_next (lp_ge lp)) b ->
    ObjPhase.call_keeps (lp_ge lp) (ObjPhase.noref b) f.
  Hypothesis Hobj_stores : forall b s, In (FrameCalls.OBlk s) ObjPhase.uo_list ->
    Ple (Genv.genv_next (lp_ge lp)) b ->
    ObjPhase.safeE (lp_ge lp) (fun m => Pobjl m /\ ObjPhase.noref b m) (ObjPhase.uo_env b) s.
  Hypothesis Hobj_counter : forall le m t le' m' out, Pobjl m ->
    exec_stmt function_entry2 (lp_ge lp) empty_env le m ObjPhase.auo_counter t le' m' out -> Pobjl m'.
  Hypothesis Hobj_debug :
    ObjPhase.call_keeps (lp_ge lp) Pobjl object_list_processor._reset_debug_objectinfo
    /\ ObjPhase.call_keeps (lp_ge lp) Pobjl object_list_processor._stub_debug_5
    /\ ObjPhase.call_keeps (lp_ge lp) Pobjl object_list_processor._try_print_debug_mario_object_info.
  Hypothesis Hobj_surfaces : ObjPhase.call_keeps (lp_ge lp) Pobjl object_list_processor._clear_dynamic_surfaces.
  Hypothesis Hobj_collisions : ObjPhase.call_keeps (lp_ge lp) Pobjl object_list_processor._detect_object_collisions.
  Hypothesis Hobj_step_terrain :
    ObjLoop.step_row (lp_ge lp) Pobjl (ObjLoop.in_ring_l (lp_ge lp) bm ObjLoop.ter_ls)
      object_list_processor.f_update_objects_starting_at
    /\ ObjLoop.step_row (lp_ge lp) Pobjl (ObjLoop.in_ring_l (lp_ge lp) bm ObjLoop.ter_ls)
      object_list_processor.f_update_objects_during_time_stop.
  Hypothesis Hobj_step_nonterrain : HeightFrame.mario_hole lp bm MWF Phi ->
    ObjLoop.step_row (lp_ge lp) Pobjl (ObjLoop.in_ring_l (lp_ge lp) bm ObjLoop.nt_ls)
      object_list_processor.f_update_objects_starting_at
    /\ ObjLoop.step_row (lp_ge lp) Pobjl (ObjLoop.in_ring_l (lp_ge lp) bm ObjLoop.nt_ls)
      object_list_processor.f_update_objects_during_time_stop
    /\ ObjLoop.step_nr_row (lp_ge lp) Pobjl (ObjLoop.in_ring_l (lp_ge lp) bm ObjLoop.nt_ls)
      object_list_processor.f_update_objects_starting_at
    /\ ObjLoop.step_nr_row (lp_ge lp) Pobjl (ObjLoop.in_ring_l (lp_ge lp) bm ObjLoop.nt_ls)
      object_list_processor.f_update_objects_during_time_stop.
  Hypothesis Hobj_ctr : forall m b c m', Pobjl m ->
    Genv.find_symbol (lp_ge lp) object_list_processor._gObjectCounter = Some b ->
    Mem.store Mint32 m b 0 (Vint c) = Some m' -> Pobjl m'.
  Hypothesis Hobj_unload : ObjPhase.call_keeps (lp_ge lp) Pobjl object_list_processor._unload_deactivated_objects.
  Hypothesis Hobj_mplat : ObjPhase.call_keeps (lp_ge lp) Pobjl object_list_processor._update_mario_platform.
  Hypothesis Hcam_ow : forall m m', LevelFlank.cam_step lp m m' ->
    mem_ok_lp bm MWF m -> Phi m -> OWl m -> OWl m'.

  (* THE CAPSTONE: GOAL 1 over GOAL 2's real frame *)
  Theorem noA_never_flying_frame_linked12 :
    forall (init : mem) (is : list mem) (m : mem),
      mem_ok_lp bm MWF init -> Phi init -> PlatformKeep.plat_still lp init -> OWl init ->
      Forall (fun i => PollFlank.pif_a_real (lp_ge lp) i = false) is ->
      reachable mem mem (HeightFrame.frame_step lp bm MWF Phi OWl) init is m ->
      ~ mem_flying_lp bm m.
  Proof.
    intros init is m Hok Hphi Hst How HA Hr.
    apply (mem_ok_not_flying_lp bm MWF m).
    exact (proj1 (HeightFrame.wmotr_noA_run_ok_linked12 lp H12 bm bc oc0 SafeB HSafeB_syms
                    Hbm_sym Hbc_sym Hoc0 Hls Hdma_floor Hseg_na_open Hdma_anim Hsqrtf Hsqrtf_float
                    Hcam_phi Hobj_blind Hobj_fresh Hobj_noref Hobj_stores Hobj_counter Hobj_debug
                    Hobj_surfaces Hobj_collisions Hobj_step_terrain Hobj_step_nonterrain Hobj_ctr
                    Hobj_unload Hobj_mplat Hcam_ow
                    init is m Hok Hphi Hst How HA Hr)).
  Qed.
End NoAImpliesNoFlyFrame.
