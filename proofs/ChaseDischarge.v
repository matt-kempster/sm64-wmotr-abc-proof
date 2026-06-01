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
 *   [ ] set_mario_animation, set_mario_anim_with_accel,
 *       set_steep_jump_action, set_mario_action_airborne, set_mario_action_moving,
 *       squish_mario_model, update_mario_info_for_cam, sink_mario_in_quicksand,
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
From SM64.Proofs Require Import Flying ActionValueFrame MarioMemWF ChaseCount ResetBodystate ValueFrameINV SetAnimToFrame.

(* ---- #1 / 111 : mario_reset_bodystate (mario.c) ---------------------- *)

(* (a) the function we discharge is LITERALLY one of the enumerated 111. *)
Lemma reset_bodystate_is_one_of_the_111 :
  In mario._mario_reset_bodystate (chase_funcs mario.prog).
Proof. vm_compute. tauto. Qed.

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
