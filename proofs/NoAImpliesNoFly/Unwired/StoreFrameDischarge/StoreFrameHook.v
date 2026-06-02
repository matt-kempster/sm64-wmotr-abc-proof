(* StoreFrameHook.v -- WIRING the chase engine into the spine's funcall-level target.
 *
 * StoreFrameSpine's bucket-A obligation is `body_preserves_nonflying f`, stated at the
 * eval_funcall level:  a whole call of f preserves the non-flying action invariant.
 * The chase engine (ResetBodystate / StatementFrame) proves preservation at the
 * exec_stmt (body) level, under a `le!_m = Vptr bm 0` entry hypothesis. This file
 * closes the gap for the witness function, mario_reset_bodystate, by inverting
 * eval_funcall -> function_entry2 -> exec_stmt:
 *   - fn_vars = nil, so alloc_variables is empty (m unchanged, env = empty_env);
 *   - bind_parameter_temps binds _m to the (sole) argument and Vundef-initialises
 *     the temps -- so the engine's `le!_m = Vptr bm 0` entry hypothesis is
 *     DISCHARGED here, not assumed downstream;
 *   - blocks_of_env empty_env = [], so the trailing free_list is identity.
 *
 * HONEST PREMISES (the interface the spine's bridge must carry, and which the
 * current StoreFrameSpine.body_preserves_nonflying is missing): the Mario heap is
 * well-formed at bm (mario_mem_wf) and the call is on Mario's own pointer
 * (Vptr bm 0 :: nil). The fully-general `forall vargs` form is FALSE without a
 * global heap invariant -- a call whose _m argument aliased bm through a chased
 * sub-pointer could clobber the action cell -- which is exactly why the bridge
 * needs the wf premise threaded, not dropped.
 *)

From compcert Require Import Coqlib Maps AST Integers Values Memory Globalenvs
  Ctypes Clight ClightBigstep Events.
From Coq Require Import List.
Import ListNotations.
From SM64.Generated Require mario.
From SM64.Proofs Require Import Flying ActionValueFrame MarioMemoryWF ResetBodystate StoreFrameSpine.

(* The spine's body_preserves_nonflying, realised for mario_reset_bodystate:
   proven, not assumed -- the chase work is now wired to the funcall level. *)
Theorem reset_bodystate_funcall_preserves_nonflying :
  forall bm bbs m m' t res,
    mario_mem_wf m bm bbs ->
    Mem.valid_block m bm ->
    action_sat nonflying m bm ->
    eval_funcall function_entry2 mario_ge m
      (Internal mario.f_mario_reset_bodystate) (Vptr bm Ptrofs.zero :: nil) t m' res ->
    action_sat nonflying m' bm.
Proof.
  intros bm bbs m m' t res Hwf Hv Hsat Hfun.
  inv Hfun.
  (* function_entry2: alloc empty vars, bind _m, undef temps *)
  match goal with Hfe : function_entry2 _ _ _ _ _ _ _ |- _ => inv Hfe end.
  match goal with Hav : alloc_variables _ _ _ _ _ _ |- _ =>
    cbn [mario.f_mario_reset_bodystate fn_vars] in Hav; inv Hav end.
  match goal with Hbp : bind_parameter_temps _ _ _ = Some _ |- _ =>
    cbn [mario.f_mario_reset_bodystate fn_params bind_parameter_temps] in Hbp;
    inv Hbp end.
  (* free_list over the empty env is identity: m' = m2 (the body's result memory) *)
  match goal with Hfree : Mem.free_list _ _ = Some _ |- _ =>
    assert (Hbe : blocks_of_env mario_ge empty_env = nil) by reflexivity;
    rewrite Hbe in Hfree; cbn [Mem.free_list] in Hfree; inv Hfree end.
  (* now apply the exec_stmt-level engine: le!_m = Vptr bm 0 holds by PTree.gss *)
  eapply mario_reset_bodystate_preserves;
    [ rewrite PTree.gss; reflexivity
    | exact Hv
    | exact Hwf
    | exact Hsat
    | eassumption ].
Qed.

(* The concrete Mario-heap well-formedness that instantiates StoreFrameSpine's abstract
   mario_wf carrier: Mario's block is valid and his pointer fields are off-block. *)
Definition reset_wf (m : mem) (bm : block) : Prop :=
  Mem.valid_block m bm /\ exists bbs, mario_mem_wf m bm bbs.

(* THE HOOK, fully wired: this DISCHARGES StoreFrameSpine's per-function bucket-A
   obligation `body_preserves_nonflying` for mario_reset_bodystate, at prog = mario.prog
   with mario_wf := reset_wf. No abstract store_frame_bridge hypothesis is used -- the
   preservation comes straight from the chase engine (ResetBodystate) through the
   eval_funcall hook above. The non-nil-argument case is impossible (reset_bodystate
   takes one parameter, so bind_parameter_temps rejects extra args). *)
Theorem reset_bodystate_discharges_bucketA :
  StoreFrameSpine.body_preserves_nonflying mario.prog reset_wf mario.f_mario_reset_bodystate.
Proof.
  unfold StoreFrameSpine.body_preserves_nonflying, reset_wf.
  intros bm rest m m' t res (Hv & bbs & Hmwf) Hsat Hfun.
  destruct rest as [| a rest'].
  - exact (reset_bodystate_funcall_preserves_nonflying bm bbs m m' t res Hmwf Hv Hsat Hfun).
  - exfalso. inv Hfun.
    match goal with Hfe : function_entry2 _ _ _ _ _ _ _ |- _ => inv Hfe end.
    match goal with Hbp : bind_parameter_temps _ _ _ = Some _ |- _ =>
      cbn [mario.f_mario_reset_bodystate fn_params bind_parameter_temps] in Hbp;
      discriminate Hbp end.
Qed.
