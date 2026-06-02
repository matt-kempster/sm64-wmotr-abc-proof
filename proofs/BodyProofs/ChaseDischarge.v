(* ChaseDischarge.v -- TYING THE ENGINE TO THE NAMED 111.
 *
 * This file is the scoreboard: for each function in ChaseList's machine-checked
 * enumeration of the 111 chase functions, a theorem "executing its REAL body
 * preserves action_sat nonflying" (= Mario's action stays non-flying across the
 * call), discharged with the ValueFrameINV engine + the inverter bricks.
 *
 * Each entry is tied to the enumeration by a machine-checked membership fact
 * `In <fn> (chase_funcs mario.prog)`, so "we proved function F" is provably "F is
 * one of the 111", not a function we picked off-list.
 *
 * SCOREBOARD (mario.c, 14 chase fns):
 *   [x] mario_reset_bodystate     -- DONE (real body; single-Efield chase via bodyState)
 *   [x] set_anim_to_frame         -- DONE via the GENERIC frame (exec_body_nf_callfree):
 *       deep chase through animInfo = &m->marioObj->header.gfx.animInfo, word-scalar
 *       loads (Obstacle 2), and control flow -- all handled by the engine.
 *   [x] set_mario_action_moving   -- DONE via the FULL frame (exec_body_nf): CALLS
 *       (reach_frame_preserves), a SWITCH, a direct m->forwardVel store (Obstacle 1),
 *       and a rooted marioObj->rawData[34] store. Conditional on the callee knob.
 *   [x] update_mario_info_for_cam -- DONE: multi-field FS (marioBodyState +
 *       statusForCamera), two rooted ->action stores (off-bm), two array-copy calls.
 *   [x] squish_mario_model        -- DONE: direct m->squishTimer (Obstacle 1) +
 *       rooted marioObj->scale[i] x3 + vec3f_set calls + nested control flow.
 *   [ ] set_mario_animation, set_mario_anim_with_accel,
 *       set_steep_jump_action, set_mario_action_airborne, sink_mario_in_quicksand,
 *       mario_update_hitbox_and_cap_model, execute_mario_action, init_mario,
 *       init_mario_from_save_file
 *
 * THE NEXT BRICK (to clear the rest): the remaining 13 mario.c chase fns chase
 * through m->marioObj into DEEPLY NESTED object-graphics fields, e.g.
 *   (o->header.gfx.pos)[1] = ...      and      (t4->throwMatrix)[3][1] = ...
 * The store's lvalue is rooted at a TEMP (o, t4 -- pointer loads are hoisted to
 * their own Ssets), wrapped in struct-Efield (By_copy) / array-Ederef-Ebinop
 * (By_reference) accessors that all PRESERVE the block. So the store lands in the
 * root temp's block, which is off-bm once the temp is established off-bm. What is
 * missing is a GENERAL "store through an lvalue rooted at temp p lands in p's
 * block" inverter (induction over the field/array accessor chain), generalizing
 * exec_field_store_block (single Efield) and ArrayStore (single m->fld[i]). With
 * that brick + per-field field_loads_off_bm clauses, these discharge mechanically.
 *)

From Coq Require Import List.
Import ListNotations.
From compcert Require Import Maps AST Integers Values Memory Globalenvs Ctypes Cop Clight ClightBigstep.
From SM64.Generated Require mario.
From SM64.Proofs Require Import Flying ActionValueFrame MarioMemWF ChaseCount ResetBodystate ValueFrameINV ValueFrameStmt SetAnimToFrame SetMarioActionMoving UpdateMarioInfoForCam SquishMarioModel BucketASpine BucketAHook.

(* ---- #1 / 111 : mario_reset_bodystate (mario.c) ---------------------- *)

(* (a) the function we discharge is LITERALLY one of the enumerated 111. *)
Lemma reset_bodystate_is_one_of_the_111 :
  In mario._mario_reset_bodystate (chase_funcs mario.prog).
Proof. vm_compute. tauto. Qed.

(* (b-spine) THE WIRED FORM: reset_bodystate's bucket-A obligation in the SPINE's
   own currency (BucketASpine.body_preserves_nonflying, eval_funcall level),
   discharged from the engine via BucketAHook -- NOT via the abstract
   store_frame_bridge hypothesis. This is the proof that the chase work actually
   feeds the no-A no-fly spine, not a parallel island. *)
Theorem reset_bodystate_discharges_spine_bucketA :
  BucketASpine.body_preserves_nonflying mario.prog reset_wf mario.f_mario_reset_bodystate.
Proof. exact reset_bodystate_discharges_bucketA. Qed.

(* (b) its REAL body preserves nonflying (re-exporting the ResetBodystate proof
   as the canonical scoreboard entry). *)
Theorem reset_bodystate_preserves_nonflying :
  forall e le m t le' m' out bm bbs,
    le ! mario._m = Some (Vptr bm Ptrofs.zero) ->
    Mem.valid_block m bm ->
    mario_mem_wf m bm bbs ->
    action_sat nonflying m bm ->
    exec_stmt function_entry2 mario_ge e le m
      (fn_body mario.f_mario_reset_bodystate) t le' m' out ->
    action_sat nonflying m' bm.
Proof. exact mario_reset_bodystate_preserves. Qed.

(* ---- #2 / 111 : set_anim_to_frame (mario.c) ------------------------- *)

(* (a) one of the enumerated 111. *)
Lemma set_anim_to_frame_is_one_of_the_111 :
  In mario._set_anim_to_frame (chase_funcs mario.prog).
Proof. vm_compute. tauto. Qed.

(* (b) its REAL body preserves nonflying. Cleared through the generic statement
   frame (SetAnimToFrame.set_anim_to_frame_preserves): no bespoke inversion, just
   the FS of chased fields ([marioObj]) + the tracked store-root temps. The
   field_loads_off_bm marioObj clause is this body's anti-aliasing assumption
   (gMarioState->marioObj is a separate allocation), and tmps_off_bm PT_anim is
   the function-entry condition that the (uninitialised) tracked temps don't alias
   Mario's block -- both honest hypotheses, no axioms. *)
Theorem set_anim_to_frame_preserves_nonflying :
  forall e le m t le' m' out bm,
    le ! mario._m = Some (Vptr bm Ptrofs.zero) ->
    Mem.valid_block m bm ->
    field_loads_off_bm m bm mario._marioObj ->
    tmps_off_bm PT_anim bm mario._m le ->
    action_sat nonflying m bm ->
    exec_stmt function_entry2 mario_ge e le m
      (fn_body mario.f_set_anim_to_frame) t le' m' out ->
    action_sat nonflying m' bm.
Proof. exact set_anim_to_frame_preserves. Qed.

(* ---- #3 / 111 : set_mario_action_moving (mario.c) ------------------- *)

(* (a) one of the enumerated 111. *)
Lemma set_mario_action_moving_is_one_of_the_111 :
  In mario._set_mario_action_moving (chase_funcs mario.prog).
Proof. vm_compute. tauto. Qed.

(* (b) its REAL body preserves nonflying. Cleared through the FULL frame
   (exec_body_nf), the first entry with both CALLS and a SWITCH: it calls
   mario_get_floor_class / mario_facing_downhill (read-only re: the action
   field -- the reach_frame_preserves hypothesis is the honest callee knob),
   switches on the action argument, writes m->forwardVel DIRECTLY (Obstacle 1:
   forwardVel@84 misses the action cell [12,16) and the marioObj load), and
   writes m->marioObj->rawData[34] through a rooted temp. It only RETURNS the
   action value, never storing m->action -- so nonflying survives. *)
Theorem set_mario_action_moving_preserves_nonflying :
  forall e le m t le' m' out bm,
    reach_frame_preserves FS_mov nonflying bm mario_ge ->
    le ! mario._m = Some (Vptr bm Ptrofs.zero) ->
    Mem.valid_block m bm ->
    field_loads_off_bm m bm mario._marioObj ->
    tmps_off_bm PT_mov bm mario._m le ->
    action_sat nonflying m bm ->
    exec_stmt function_entry2 mario_ge e le m
      (fn_body mario.f_set_mario_action_moving) t le' m' out ->
    action_sat nonflying m' bm.
Proof. exact set_mario_action_moving_preserves. Qed.

(* ---- #4 / 111 : update_mario_info_for_cam (mario.c) ----------------- *)
Lemma update_mario_info_for_cam_is_one_of_the_111 :
  In mario._update_mario_info_for_cam (chase_funcs mario.prog).
Proof. vm_compute. tauto. Qed.

(* Multi-field FS: writes the action field of m->marioBodyState and
   m->statusForCamera (both off-bm), never m->action; two array-copy calls ride
   the reach knob. *)
Theorem update_mario_info_for_cam_preserves_nonflying :
  forall e le m t le' m' out bm,
    reach_frame_preserves FS_cam nonflying bm mario_ge ->
    le ! mario._m = Some (Vptr bm Ptrofs.zero) ->
    Mem.valid_block m bm ->
    field_loads_off_bm m bm mario._marioBodyState ->
    field_loads_off_bm m bm mario._statusForCamera ->
    tmps_off_bm PT_cam bm mario._m le ->
    action_sat nonflying m bm ->
    exec_stmt function_entry2 mario_ge e le m
      (fn_body mario.f_update_mario_info_for_cam) t le' m' out ->
    action_sat nonflying m' bm.
Proof. exact update_mario_info_for_cam_preserves. Qed.

(* ---- #5 / 111 : squish_mario_model (mario.c) ------------------------ *)
Lemma squish_mario_model_is_one_of_the_111 :
  In mario._squish_mario_model (chase_funcs mario.prog).
Proof. vm_compute. tauto. Qed.

(* Direct m->squishTimer decrement (Obstacle 1) + rooted marioObj->...scale[i]
   rescale through three temps + vec3f_set calls; never writes m->action. *)
Theorem squish_mario_model_preserves_nonflying :
  forall e le m t le' m' out bm,
    reach_frame_preserves FS_squish nonflying bm mario_ge ->
    le ! mario._m = Some (Vptr bm Ptrofs.zero) ->
    Mem.valid_block m bm ->
    field_loads_off_bm m bm mario._marioObj ->
    tmps_off_bm PT_squish bm mario._m le ->
    action_sat nonflying m bm ->
    exec_stmt function_entry2 mario_ge e le m
      (fn_body mario.f_squish_mario_model) t le' m' out ->
    action_sat nonflying m' bm.
Proof. exact squish_mario_model_preserves. Qed.
