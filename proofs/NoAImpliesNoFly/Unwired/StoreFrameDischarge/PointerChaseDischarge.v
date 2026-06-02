(* spine-root: sub-goal capstone (store-frame discharge over the named handlers). *)
(* PointerChaseDischarge.v -- TYING THE ENGINE TO THE NAMED 111.
 *
 * This file is the scoreboard: for each function in PointerChaseList's machine-checked
 * enumeration of the 111 chase functions, a theorem "executing its REAL body
 * preserves action_sat nonflying" (= Mario's action stays non-flying across the
 * call), discharged with the TempProvenanceInvariant engine + the inverter bricks.
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

From Coq Require Import List PArith.BinPos.
Import ListNotations.
From compcert Require Import Maps AST Integers Values Memory Globalenvs Ctypes Cop Clight ClightBigstep.
From SM64.Generated Require mario.
From SM64.Proofs Require Import Flying ActionValueFrame MarioMemoryWF PointerChaseCount ResetBodystate TempProvenanceInvariant StatementFrame BodyFrameDecider FuncallFrame SetAnimToFrame SetMarioActionMoving UpdateMarioInfoForCam SquishMarioModel StoreFrameSpine StoreFrameHook.

(* ---- #1 / 111 : mario_reset_bodystate (mario.c) ---------------------- *)

(* (a) the function we discharge is LITERALLY one of the enumerated 111. *)
Lemma reset_bodystate_is_one_of_the_111 :
  In mario._mario_reset_bodystate (chase_funcs mario.prog).
Proof. vm_compute. tauto. Qed.

(* (b-spine) THE WIRED FORM: reset_bodystate's bucket-A obligation in the SPINE's
   own currency (StoreFrameSpine.body_preserves_nonflying, eval_funcall level),
   discharged from the engine via StoreFrameHook -- NOT via the abstract
   store_frame_bridge hypothesis. This is the proof that the chase work actually
   feeds the no-A no-fly spine, not a parallel island. *)
Theorem reset_bodystate_discharges_spine_bucketA :
  StoreFrameSpine.body_preserves_nonflying mario.prog reset_wf mario.f_mario_reset_bodystate.
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
   (gMarioState->marioObj is a separate allocation), and tmps_off_bm tracked_ptrs_anim is
   the function-entry condition that the (uninitialised) tracked temps don't alias
   Mario's block -- both honest hypotheses, no axioms. *)
Theorem set_anim_to_frame_preserves_nonflying :
  forall e le m t le' m' out bm,
    le ! mario._m = Some (Vptr bm Ptrofs.zero) ->
    Mem.valid_block m bm ->
    field_loads_off_bm m bm mario._marioObj ->
    tmps_off_bm tracked_ptrs_anim bm mario._m le ->
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
    reach_frame_preserves chased_fields_mov nonflying bm mario_ge ->
    le ! mario._m = Some (Vptr bm Ptrofs.zero) ->
    Mem.valid_block m bm ->
    field_loads_off_bm m bm mario._marioObj ->
    tmps_off_bm tracked_ptrs_mov bm mario._m le ->
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
    reach_frame_preserves chased_fields_cam nonflying bm mario_ge ->
    le ! mario._m = Some (Vptr bm Ptrofs.zero) ->
    Mem.valid_block m bm ->
    field_loads_off_bm m bm mario._marioBodyState ->
    field_loads_off_bm m bm mario._statusForCamera ->
    tmps_off_bm tracked_ptrs_cam bm mario._m le ->
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
    reach_frame_preserves chased_fields_squish nonflying bm mario_ge ->
    le ! mario._m = Some (Vptr bm Ptrofs.zero) ->
    Mem.valid_block m bm ->
    field_loads_off_bm m bm mario._marioObj ->
    tmps_off_bm tracked_ptrs_squish bm mario._m le ->
    action_sat nonflying m bm ->
    exec_stmt function_entry2 mario_ge e le m
      (fn_body mario.f_squish_mario_model) t le' m' out ->
    action_sat nonflying m' bm.
Proof. exact squish_mario_model_preserves. Qed.

(* ==================================================================== *)
(* FUNCALL-LEVEL LIFT (the call-free slice), via the GENERIC bridge.      *)
(*                                                                        *)
(* The (b) entries above are stated at the exec_stmt (body) level and     *)
(* take the entry-`tmps_off_bm` invariant as a HYPOTHESIS. The genuine     *)
(* spine currency is the eval_funcall level (a whole CALL preserves        *)
(* non-flying), with that entry invariant DISCHARGED -- which is what      *)
(* StoreFrameHook did for mario_reset_bodystate, but by a bespoke          *)
(* per-function eval_funcall inversion. FuncallFrame.funcall_body_nf_      *)
(* callfree_preserves does it ONCE and generically for any call-free,      *)
(* `_m`-first-param, fn_vars-free function whose body passes the decidable  *)
(* frame check. Below we apply it to the two call-free scoreboard fns, so   *)
(* their funcall-level preservation now rides the generic engine -- no      *)
(* hand inversion, and tmps_off_bm is no longer an external premise (every  *)
(* tracked temp is Vundef at entry).                                        *)
(* ==================================================================== *)

(* set_anim_to_frame: PT/FS already validated by SetAnimToFrame's body_nf_ok
   _dec check; the only honest premise left is the field-wf for marioObj. *)
Theorem set_anim_to_frame_funcall_preserves_nonflying :
  forall bm rest m m' t res,
    Mem.valid_block m bm ->
    field_loads_off_bm m bm mario._marioObj ->
    action_sat nonflying m bm ->
    eval_funcall function_entry2 mario_ge m (Internal mario.f_set_anim_to_frame)
      (Vptr bm Ptrofs.zero :: rest) t m' res ->
    action_sat nonflying m' bm.
Proof.
  intros bm rest m m' t res Hv Hwf Hsat Hfun.
  eapply (funcall_body_nf_callfree_preserves tracked_ptrs_anim chased_fields_anim
            nonflying bm mario.f_set_anim_to_frame rest m m' t res).
  - reflexivity.                                  (* fn_vars = nil *)
  - reflexivity.                                  (* body_no_calls = true *)
  - exists (Tpointer (Tstruct mario._MarioState noattr) noattr),
           ((mario._animFrame, Tint I16 Signed noattr) :: nil).
    split; [ reflexivity | split ].
    + (* _m is not the second formal *)
      intro Hin; simpl in Hin; destruct Hin as [H|[]]; vm_compute in H; discriminate.
    + (* the tracked temps (_t'6,_animInfo) are not the second formal *)
      intros t0 Hpt Hin; simpl in Hin; destruct Hin as [H|[]];
        subst t0; vm_compute in Hpt; discriminate.
  - intro e. apply body_nf_ok_dec_sound. vm_compute. reflexivity.
  - exact Hv.
  - exact Hsat.
  - unfold mem_wf, chased_fields_anim. intros fid Hin.
    cbn [In] in Hin. destruct Hin as [Heq|[]]. subst fid. exact Hwf.
  - exact Hfun.
Qed.

(* mario_reset_bodystate: re-derived at the funcall level through the SAME
   generic bridge (cf. StoreFrameHook's bespoke inversion). PT = {_bodyState},
   FS = [marioBodyState]; the dec check confirms the body. *)
Definition tracked_ptrs_reset : ident -> bool :=
  fun id => Pos.eqb id mario._bodyState.
Definition chased_fields_reset : list ident := [ mario._marioBodyState ].

Theorem reset_bodystate_funcall_preserves_generic :
  forall bm rest m m' t res,
    Mem.valid_block m bm ->
    field_loads_off_bm m bm mario._marioBodyState ->
    action_sat nonflying m bm ->
    eval_funcall function_entry2 mario_ge m (Internal mario.f_mario_reset_bodystate)
      (Vptr bm Ptrofs.zero :: rest) t m' res ->
    action_sat nonflying m' bm.
Proof.
  intros bm rest m m' t res Hv Hwf Hsat Hfun.
  eapply (funcall_body_nf_callfree_preserves tracked_ptrs_reset chased_fields_reset
            nonflying bm mario.f_mario_reset_bodystate rest m m' t res).
  - reflexivity.                                  (* fn_vars = nil *)
  - reflexivity.                                  (* body_no_calls = true *)
  - exists (Tpointer (Tstruct mario._MarioState noattr) noattr), (@nil (ident * type)).
    split; [ reflexivity | split ].
    + intro Hin; exact Hin.                       (* In _m [] is False *)
    + intros t0 Hpt Hin; exact Hin.
  - intro e. apply body_nf_ok_dec_sound. vm_compute. reflexivity.
  - exact Hv.
  - exact Hsat.
  - unfold mem_wf, chased_fields_reset. intros fid Hin.
    cbn [In] in Hin. destruct Hin as [Heq|[]]. subst fid. exact Hwf.
  - exact Hfun.
Qed.

(* ==================================================================== *)
(* FEEDS THE SPINE. The funcall-level results above land in the spine's   *)
(* OWN currency, StoreFrameSpine.body_preserves_nonflying, with a CONCRETE *)
(* heap-wf carrier (valid + the chased field loads off-bm) instantiating   *)
(* StoreFrameSpine's abstract mario_wf. So these are not a parallel island: *)
(* the generic chase engine discharges the spine's bucket-A obligation,     *)
(* and -- unlike reset_bodystate_discharges_spine_bucketA, which routes      *)
(* through StoreFrameHook's bespoke eval_funcall inversion -- entirely       *)
(* through the reusable bridge. set_anim_to_frame is a NEW spine leaf.       *)
(* ==================================================================== *)

Theorem set_anim_to_frame_discharges_spine_bucketA :
  StoreFrameSpine.body_preserves_nonflying mario.prog
    (fun m bm => Mem.valid_block m bm /\ field_loads_off_bm m bm mario._marioObj)
    mario.f_set_anim_to_frame.
Proof.
  unfold StoreFrameSpine.body_preserves_nonflying.
  intros bm rest m m' t res (Hv & Hwf) Hsat Hfun.
  exact (set_anim_to_frame_funcall_preserves_nonflying bm rest m m' t res Hv Hwf Hsat Hfun).
Qed.

Theorem reset_bodystate_discharges_spine_bucketA_generic :
  StoreFrameSpine.body_preserves_nonflying mario.prog
    (fun m bm => Mem.valid_block m bm /\ field_loads_off_bm m bm mario._marioBodyState)
    mario.f_mario_reset_bodystate.
Proof.
  unfold StoreFrameSpine.body_preserves_nonflying.
  intros bm rest m m' t res (Hv & Hwf) Hsat Hfun.
  exact (reset_bodystate_funcall_preserves_generic bm rest m m' t res Hv Hwf Hsat Hfun).
Qed.

(* ==================================================================== *)
(* FUNCALL-LEVEL LIFT (the call-BEARING slice), via the generic           *)
(* funcall_body_nf_preserves. These three carry calls (switch/array-copy/  *)
(* vec3f_set), so the interprocedural knob reach_frame_preserves is        *)
(* threaded (honest, not discharged) -- but the eval_funcall inversion and *)
(* the entry tmps_off_bm are STILL handled generically, never by hand.     *)
(* Together with the call-free pair above, every discharged scoreboard fn  *)
(* now reaches funcall level through the reusable bridges -- no function    *)
(* keeps a bespoke eval_funcall inversion.                                  *)
(* ==================================================================== *)

Theorem set_mario_action_moving_funcall_preserves_nonflying :
  forall bm rest m m' t res,
    reach_frame_preserves chased_fields_mov nonflying bm mario_ge ->
    Mem.valid_block m bm ->
    field_loads_off_bm m bm mario._marioObj ->
    action_sat nonflying m bm ->
    eval_funcall function_entry2 mario_ge m (Internal mario.f_set_mario_action_moving)
      (Vptr bm Ptrofs.zero :: rest) t m' res ->
    action_sat nonflying m' bm.
Proof.
  intros bm rest m m' t res Hreach Hv Hwf Hsat Hfun.
  eapply (funcall_body_nf_preserves tracked_ptrs_mov chased_fields_mov nonflying bm
            mario.f_set_mario_action_moving rest m m' t res Hreach).
  - reflexivity.
  - exists (Tpointer (Tstruct mario._MarioState noattr) noattr),
           ((mario._action, Tint I32 Unsigned noattr)
              :: (mario._actionArg, Tint I32 Unsigned noattr) :: nil).
    split; [ reflexivity | split ].
    + intro Hin; simpl in Hin; destruct Hin as [H|[H|[]]]; vm_compute in H; discriminate.
    + intros t0 Hpt Hin; simpl in Hin; destruct Hin as [H|[H|[]]];
        subst t0; vm_compute in Hpt; discriminate.
  - intro e. apply body_nf_ok_dec_sound. vm_compute. reflexivity.
  - exact Hv.
  - exact Hsat.
  - unfold mem_wf, chased_fields_mov. intros fid Hin.
    cbn [In] in Hin. destruct Hin as [Heq|[]]. subst fid. exact Hwf.
  - exact Hfun.
Qed.

Theorem update_mario_info_for_cam_funcall_preserves_nonflying :
  forall bm rest m m' t res,
    reach_frame_preserves chased_fields_cam nonflying bm mario_ge ->
    Mem.valid_block m bm ->
    field_loads_off_bm m bm mario._marioBodyState ->
    field_loads_off_bm m bm mario._statusForCamera ->
    action_sat nonflying m bm ->
    eval_funcall function_entry2 mario_ge m (Internal mario.f_update_mario_info_for_cam)
      (Vptr bm Ptrofs.zero :: rest) t m' res ->
    action_sat nonflying m' bm.
Proof.
  intros bm rest m m' t res Hreach Hv Hwf1 Hwf2 Hsat Hfun.
  eapply (funcall_body_nf_preserves tracked_ptrs_cam chased_fields_cam nonflying bm
            mario.f_update_mario_info_for_cam rest m m' t res Hreach).
  - reflexivity.
  - exists (Tpointer (Tstruct mario._MarioState noattr) noattr), (@nil (ident * type)).
    split; [ reflexivity | split ].
    + intro Hin; exact Hin.
    + intros t0 Hpt Hin; exact Hin.
  - intro e. apply body_nf_ok_dec_sound. vm_compute. reflexivity.
  - exact Hv.
  - exact Hsat.
  - unfold mem_wf, chased_fields_cam. intros fid Hin.
    cbn [In] in Hin. destruct Hin as [Heq|[Heq|[]]]; subst fid; [ exact Hwf1 | exact Hwf2 ].
  - exact Hfun.
Qed.

Theorem squish_mario_model_funcall_preserves_nonflying :
  forall bm rest m m' t res,
    reach_frame_preserves chased_fields_squish nonflying bm mario_ge ->
    Mem.valid_block m bm ->
    field_loads_off_bm m bm mario._marioObj ->
    action_sat nonflying m bm ->
    eval_funcall function_entry2 mario_ge m (Internal mario.f_squish_mario_model)
      (Vptr bm Ptrofs.zero :: rest) t m' res ->
    action_sat nonflying m' bm.
Proof.
  intros bm rest m m' t res Hreach Hv Hwf Hsat Hfun.
  eapply (funcall_body_nf_preserves tracked_ptrs_squish chased_fields_squish nonflying bm
            mario.f_squish_mario_model rest m m' t res Hreach).
  - reflexivity.
  - exists (Tpointer (Tstruct mario._MarioState noattr) noattr), (@nil (ident * type)).
    split; [ reflexivity | split ].
    + intro Hin; exact Hin.
    + intros t0 Hpt Hin; exact Hin.
  - intro e. apply body_nf_ok_dec_sound. vm_compute. reflexivity.
  - exact Hv.
  - exact Hsat.
  - unfold mem_wf, chased_fields_squish. intros fid Hin.
    cbn [In] in Hin. destruct Hin as [Heq|[]]. subst fid. exact Hwf.
  - exact Hfun.
Qed.
