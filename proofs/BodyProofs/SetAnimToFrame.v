(* SetAnimToFrame.v -- scoreboard entry #2 / 111: set_mario_animation's helper
 * set_anim_to_frame, discharged through the STATEMENT-LEVEL FRAME (exec_body_nf_
 * callfree), not by bespoke inversion. This is the first chase fn cleared by the
 * generic engine after the Obstacle-2 fix, and exercises three things at once:
 *   - a DEEP chase: stores land through `animInfo`, a pointer hoisted by
 *     `animInfo = &m->marioObj->header.gfx.animInfo` (Eaddrof of a field two
 *     struct-steps inside the chased marioObj) -- handled by
 *     set_off_bm_ok_addrof_rooted;
 *   - WORD-sized scalar loads (`t = animInfo->animAccel`, tint -> Mint32) that
 *     under the faithful ppc/N64 model (Archi.ptr64=false) CAN be a Vptr -- these
 *     temps are untracked by PT, so their Sset obligation is vacuous (Obstacle 2);
 *   - CONTROL FLOW (the animAccel!=0 / flag tests) -- the frame recurses through
 *     Sifthenelse.
 * No calls => no reach_frame_preserves assumption (exec_body_nf_callfree).
 *)

From compcert Require Import Coqlib Maps AST Integers Values Memory Globalenvs Ctypes Cop Clight Clightdefs ClightBigstep Events.
From Coq Require Import List Lia.
Import ListNotations.
Import Clightdefs.ClightNotations.
Local Open Scope clight_scope.
From SM64.Generated Require mario.
From SM64.Proofs Require Import Flying FieldNonInterference ActionValueFrame MarioMemoryWF
  ResetBodystate RootedLvalue TempProvenanceInvariant StatementFrame BodyFrameDecider.

(* The TRACKED pointer temps: the chased-object pointer `t'6` (= m->marioObj) and
   the hoisted inner pointer `animInfo` (= &t'6->header.gfx.animInfo) that every
   store in this body chases through. All OTHER temps (the scalar loads
   animAccel/flags/...) are untracked, so their Sset obligation is vacuous. *)
Definition tracked_ptrs_anim : ident -> bool :=
  fun id => orb (Pos.eqb id mario._t'6) (Pos.eqb id mario._animInfo).

(* The single chased pointer field of MarioState this body reads. *)
Definition chased_fields_anim : list ident := [ mario._marioObj ].

Theorem set_anim_to_frame_preserves :
  forall e le m t le' m' out bm,
    le ! mario._m = Some (Vptr bm Ptrofs.zero) ->
    Mem.valid_block m bm ->
    field_loads_off_bm m bm mario._marioObj ->
    tmps_off_bm tracked_ptrs_anim bm mario._m le ->
    action_sat nonflying m bm ->
    exec_stmt function_entry2 mario_ge e le m
      (fn_body mario.f_set_anim_to_frame) t le' m' out ->
    action_sat nonflying m' bm.
Proof.
  intros e le m t le' m' out bm Hm Hv Hwf Htmps Hsat Hexec.
  (* the frame consumes the bundle frame_bundle; assemble it from the hypotheses. *)
  assert (Hfr : frame_bundle tracked_ptrs_anim chased_fields_anim nonflying bm m le).
  { unfold frame_bundle, chased_fields_anim. repeat split.
    - exact Hv.
    - exact Hsat.
    - exact Htmps.
    - unfold mem_wf. intros fid Hin. cbn [In] in Hin.
      destruct Hin as [Heq | []]. subst fid. exact Hwf.
    - exact Hm. }
  (* body_no_calls: straight-line + branches, no Scall/Sloop/Sswitch. *)
  assert (Hnc : body_no_calls (fn_body mario.f_set_anim_to_frame) = true)
    by reflexivity.
  (* body_nf_ok: now via the DECIDABLE checker (BodyFrameDecider) -- one reflexivity. *)
  assert (Hok : body_nf_ok tracked_ptrs_anim chased_fields_anim bm e (fn_body mario.f_set_anim_to_frame)).
  { apply body_nf_ok_dec_sound. vm_compute. reflexivity. }
  (* run the call-free frame; pull action_sat out of the preserved bundle. *)
  pose proof (exec_body_nf_callfree tracked_ptrs_anim chased_fields_anim nonflying bm
                e le m _ t le' m' out Hexec Hnc Hfr Hok) as Hfr'.
  unfold frame_bundle in Hfr'. tauto.
Qed.
