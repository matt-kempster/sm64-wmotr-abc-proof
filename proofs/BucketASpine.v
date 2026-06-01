(* BucketASpine.v -- the BUCKET A spine: the store-frame side of "no A => no fly".
 *
 * Companion to NoAFlyingSpine.v. There, the whole store-frame argument (every
 * function that does NOT itself fabricate a flying action preserves non-flying) was
 * folded into the single `chokepoint` hole. This file UNFOLDS that fold into a true
 * spine of its own, naming the real clightgen'd functions -- mario_reset_bodystate
 * and friends -- as the leaves.
 *
 * THE STRUCTURE that makes Bucket A tractable. It is NOT N independent proofs. It is
 * ONE semantic engine -- the store-frame BRIDGE -- applied to N function bodies,
 * where each body's only contribution is a DECIDABLE syntactic safety check. So:
 *
 *   - the LEAVES are real `reflexivity` facts (not holes!): `locally_safe f = true`,
 *     reusing Flying.v's `flying_call_s` / `writes_flying_action_s`. By Flying.v's
 *     already-proven `flying_setters mario.prog = [set_jump_from_landing]` and
 *     `flying_action_writers mario.prog = []`, EVERY mario.c function except
 *     set_jump_from_landing is locally safe -- so every Bucket-A leaf below is
 *     machine-checked now, with nothing left to prove at the leaf.
 *
 *   - the single HOLE is the bridge `store_frame_bridge`: a locally-safe body, under
 *     the interprocedural reach closure (`reach_safe`), preserves the non-flying
 *     action invariant across a whole eval_funcall. This is the semantic content of
 *     ActionValueFrame.exec_stmt_value_preserves lifted to eval_funcall + reach. It
 *     is the ONE thing the entire bucket reduces to.
 *
 * WHERE mario_reset_bodystate FITS. It is the FIRST leaf whose bridge instance is
 * being discharged DIRECTLY (ResetBodystate.v: temp-provenance store inverter +
 * MarioMemWF block-distinctness), i.e. the concrete witness that the bridge is real
 * against genuine SM64 pointer-chase aliasing -- the unit test for the engine before
 * we trust it across the reach set. Here it is simply one more `apply
 * store_frame_bridge; reflexivity` leaf; ResetBodystate.v is the proof that that
 * application is sound for a body with real aliasing.
 *
 * SCOPE / honesty (named): `reach_safe` is the residual interprocedural condition
 * (no reached callee fabricates flying; every set_mario_action call carries a
 * non-flying argument -- the ActionGraph computed-argument leak lives here). It is
 * threaded as an explicit premise, not assumed away. The enumerated leaves are a
 * representative slice of Bucket A; the COMPLETE bucket is the whole reach set of
 * execute_mario_action minus buckets B/C, whose mechanical enumeration is future
 * work (the list grows here as each is folded in). No Admitted.
 *)

From compcert Require Import Coqlib Maps AST Integers Values Memory Globalenvs Ctypes Clight ClightBigstep Events.
From SM64.Generated Require mario.
From SM64.Proofs Require Import Flying ActionValueFrame.

Section BucketA.

Variable prog : program.
Let gw : genv := globalenv prog.

(* The non-flying action invariant on Mario's struct block (ActionValueFrame.action_sat
   at the action cell): every action value currently loadable at (bm,12) is non-flying. *)
Definition NF (v : int) : Prop := is_flying_int v = false.

(* ---- the LEAF predicate: DECIDABLE local safety (reused from Flying.v) ---------- *)
(* A body is locally safe if it neither feeds a flying constant into a call
   (flying_call_s) nor directly assigns a flying constant to MarioState.action
   (writes_flying_action_s). Both are decidable, so each leaf below is `reflexivity`. *)
Definition locally_safe (f : function) : bool :=
  negb (flying_call_s (fn_body f))
  && negb (writes_flying_action_s mario._MarioState mario._action (fn_body f)).

(* ---- the residual interprocedural condition (threaded, not assumed away) -------- *)
(* reach_safe f: across the whole call tree of f, no reached callee fabricates a
   flying action and every set_mario_action call is passed a non-flying argument.
   Discharged by Reach.v's closure + ActionGraph.v's edge analysis (the computed-arg
   leak is here). Abstract so it cannot smuggle the conclusion. *)
Variable reach_safe : function -> Prop.

(* ---- the per-body semantic target ------------------------------------------------ *)
(* One whole call of f preserves the non-flying invariant on Mario's block bm. *)
Definition body_preserves_nonflying (f : function) : Prop :=
  forall bm m m' vargs t res,
    action_sat NF m bm ->
    eval_funcall function_entry2 gw m (Internal f) vargs t m' res ->
    action_sat NF m' bm.

(* ============================================================== *)
(*  THE BRIDGE (the one hole). A locally-safe body, under its reach *)
(*  closure, preserves non-flying across a whole funcall. = the     *)
(*  ActionValueFrame.exec_stmt_value_preserves engine lifted to     *)
(*  eval_funcall + interprocedural reach.                           *)
(* ============================================================== *)
Hypothesis store_frame_bridge :
  forall f,
    locally_safe f = true ->
    reach_safe f ->
    body_preserves_nonflying f.

(* ============================================================== *)
(*  THE LEAVES. Each real Bucket-A function: local safety is        *)
(*  machine-checked by reflexivity; preservation then follows from  *)
(*  the bridge given that function's reach closure.                 *)
(* ============================================================== *)

(* --- leaf 0: mario_reset_bodystate -- the primary witness (ResetBodystate.v) ----- *)
Example reset_bodystate_locally_safe :
  locally_safe mario.f_mario_reset_bodystate = true.
Proof. reflexivity. Qed.

Corollary reset_bodystate_preserves :
  reach_safe mario.f_mario_reset_bodystate ->
  body_preserves_nonflying mario.f_mario_reset_bodystate.
Proof. intro Hr. apply store_frame_bridge; [ reflexivity | exact Hr ]. Qed.

(* --- a representative slice of the rest of Bucket A (mario.c) --------------------- *)
(* physics / animation / geometry helpers that never touch the action field *)
Example set_forward_vel_locally_safe :
  locally_safe mario.f_mario_set_forward_vel = true.
Proof. reflexivity. Qed.

Example update_pos_for_anim_locally_safe :
  locally_safe mario.f_update_mario_pos_for_anim = true.
Proof. reflexivity. Qed.

Example floor_is_slippery_locally_safe :
  locally_safe mario.f_mario_floor_is_slippery = true.
Proof. reflexivity. Qed.

Example squish_mario_model_locally_safe :
  locally_safe mario.f_squish_mario_model = true.
Proof. reflexivity. Qed.

Example update_mario_health_locally_safe :
  locally_safe mario.f_update_mario_health = true.
Proof. reflexivity. Qed.

(* functions that DO call set_mario_action -- but only ever with a NON-flying action
   (so flying_call_s = false): the action change they cause is a tracked edge, not a
   body store. These are still Bucket A for the store-frame argument. *)
Example check_common_action_exits_locally_safe :
  locally_safe mario.f_check_common_action_exits = true.
Proof. reflexivity. Qed.

Example set_water_plunge_action_locally_safe :
  locally_safe mario.f_set_water_plunge_action = true.
Proof. reflexivity. Qed.

(* The bridge then gives preservation for each, given its reach closure. We state two
   as the pattern; the rest are identical one-liners as their reach_safe is folded in. *)
Corollary set_forward_vel_preserves :
  reach_safe mario.f_mario_set_forward_vel ->
  body_preserves_nonflying mario.f_mario_set_forward_vel.
Proof. intro Hr. apply store_frame_bridge; [ reflexivity | exact Hr ]. Qed.

Corollary check_common_action_exits_preserves :
  reach_safe mario.f_check_common_action_exits ->
  body_preserves_nonflying mario.f_check_common_action_exits.
Proof. intro Hr. apply store_frame_bridge; [ reflexivity | exact Hr ]. Qed.

(* --- the negative control: the flying SITE is NOT locally safe (it feeds a flying
   constant to set_mario_action), so it is correctly EXCLUDED from Bucket A and the
   bridge does not apply to it -- it belongs to Bucket C (NoAFlyingSpine's sites). --- *)
Example set_jump_from_landing_NOT_locally_safe :
  locally_safe mario.f_set_jump_from_landing = false.
Proof. reflexivity. Qed.

End BucketA.
