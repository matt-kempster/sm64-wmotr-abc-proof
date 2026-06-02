(* UpdateMarioInfoForCam.v -- scoreboard entry #4 / 111: update_mario_info_for_cam.
 * First entry with a MULTI-FIELD chased set: it loads m->marioBodyState and
 * m->statusForCamera (two distinct off-bm allocations) and writes the `action`
 * field OF THOSE structs (bodyState->action, statusForCamera->action) -- NOT
 * Mario's own action field. Both stores are rooted at the loaded temps, so they
 * land off-bm. Two calls (vec3s_copy / vec3f_copy, copying face-angle / position
 * arrays into the camera status, off-bm) ride the reach_frame_preserves knob, and
 * the flags test is control flow. No store ever touches m->action, so nonflying
 * is preserved.
 *)

From compcert Require Import Coqlib Maps AST Integers Values Memory Globalenvs Ctypes Cop Clight Clightdefs ClightBigstep Events.
From Coq Require Import List Lia.
Import ListNotations.
Import Clightdefs.ClightNotations.
Local Open Scope clight_scope.
From SM64.Generated Require mario.
From SM64.Proofs Require Import Flying FieldNonInterference ActionValueFrame MarioMemoryWF
  ResetBodystate RootedLvalue TempProvenanceInvariant StatementFrame FuncallFrame BodyFrameDecider.

(* Tracked store-root temps: t'6 = m->marioBodyState, t'4 = m->statusForCamera. *)
Definition PT_cam : ident -> bool :=
  fun id => orb (Pos.eqb id mario._t'6) (Pos.eqb id mario._t'4).
Definition FS_cam : list ident := [ mario._marioBodyState; mario._statusForCamera ].

Theorem update_mario_info_for_cam_preserves :
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
Proof.
  intros e le m t le' m' out bm Hreach Hm Hv Hwf1 Hwf2 Htmps Hsat Hexec.
  assert (Hfr : fr PT_cam FS_cam nonflying bm m le).
  { unfold fr, FS_cam. repeat split.
    - exact Hv.
    - exact Hsat.
    - exact Htmps.
    - unfold mem_wf. intros fid Hin. cbn [In] in Hin.
      destruct Hin as [Heq | [Heq | []]]; subst fid; [ exact Hwf1 | exact Hwf2 ].
    - exact Hm. }
  assert (Hok : body_nf_ok PT_cam FS_cam bm e (fn_body mario.f_update_mario_info_for_cam)).
  { unfold FS_cam, mario.f_update_mario_info_for_cam, fn_body.
    cbn [body_nf_ok ls_body_nf_ok].
    repeat apply conj.
    all: try solve [ exact I ].
    all: try solve [ intro Hx; vm_compute in Hx; discriminate Hx ].
    (* chase-loads (marioBodyState / statusForCamera in FS) *)
    all: try solve [ intros _; apply set_off_bm_ok_chase_load;
                     cbn [In]; solve [ repeat first [ left; reflexivity | right ] ] ].
    (* rooted store through t'6 = marioBodyState *)
    all: try solve [ left; exists mario._t'6;
                     split; [ apply Pos.eqb_neq; reflexivity | split; reflexivity ] ].
    (* rooted store through t'4 = statusForCamera *)
    all: try solve [ left; exists mario._t'4;
                     split; [ apply Pos.eqb_neq; reflexivity | split; reflexivity ] ]. }
  pose proof (exec_body_nf PT_cam FS_cam nonflying bm Hreach
                e le m _ t le' m' out Hexec Hfr Hok) as Hfr'.
  unfold fr in Hfr'. tauto.
Qed.

(* The body_nf_ok obligation as a standalone (bm/e-generic) lemma, so the generic
   funcall bridge can consume it. *)
(* body_nf_ok now via the DECIDABLE checker -- the hand-written dispatcher is
   replaced by `apply body_nf_ok_dec_sound; vm_compute; reflexivity`. *)
Lemma umifc_body_nf_ok :
  forall bm e, body_nf_ok PT_cam FS_cam bm e (fn_body mario.f_update_mario_info_for_cam).
Proof.
  intros bm e. apply body_nf_ok_dec_sound. vm_compute. reflexivity.
Qed.

(* FUNCALL-LEVEL preservation via the GENERIC bridge funcall_body_nf_preserves --
   NO bespoke eval_funcall inversion, unlike StoreFrameHook. This is the pattern every
   chase fn now follows: body_nf_ok (the dispatcher) + reach + field wf, fed to one
   generic lemma. Demonstrates the bridge on a call-bearing, multi-field function. *)
Theorem update_mario_info_for_cam_funcall_preserves :
  forall bm rest m m' t res,
    reach_frame_preserves FS_cam nonflying bm mario_ge ->
    Mem.valid_block m bm ->
    field_loads_off_bm m bm mario._marioBodyState ->
    field_loads_off_bm m bm mario._statusForCamera ->
    action_sat nonflying m bm ->
    eval_funcall function_entry2 mario_ge m (Internal mario.f_update_mario_info_for_cam)
      (Vptr bm Ptrofs.zero :: rest) t m' res ->
    action_sat nonflying m' bm.
Proof.
  intros bm rest m m' t res Hreach Hv Hwf1 Hwf2 Hsat Hfun.
  eapply (funcall_body_nf_preserves PT_cam FS_cam nonflying bm
            mario.f_update_mario_info_for_cam rest m m' t res Hreach).
  - reflexivity.
  - exists (tptr (Tstruct mario._MarioState noattr)), (@nil (ident * type)).
    split; [ reflexivity | split; [ simpl; tauto | intros t0 _; simpl; tauto ] ].
  - intro e. apply umifc_body_nf_ok.
  - exact Hv.
  - exact Hsat.
  - unfold mem_wf, FS_cam. intros fid Hin. cbn [In] in Hin.
    destruct Hin as [<- | [<- | []]]; [ exact Hwf1 | exact Hwf2 ].
  - exact Hfun.
Qed.
