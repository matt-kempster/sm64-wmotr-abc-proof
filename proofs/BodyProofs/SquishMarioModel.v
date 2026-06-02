(* SquishMarioModel.v -- scoreboard entry #5 / 111: squish_mario_model.
 * Decrements m->squishTimer (direct scalar store, Obstacle 1: squishTimer@180,
 * clear of the action cell [12,16) and the marioObj load [136,140)) and rescales
 * the model by writing m->marioObj->header.gfx.scale[0/1/2] through three rooted
 * temps (t'6, t'9, t'12), plus two vec3f_set calls (writing the scale array,
 * off-bm) on the reach knob, under nested control flow. Never writes m->action.
 *)

From compcert Require Import Coqlib Maps AST Integers Values Memory Globalenvs Ctypes Cop Clight Clightdefs ClightBigstep Events.
From Coq Require Import List Lia.
Import ListNotations.
Import Clightdefs.ClightNotations.
Local Open Scope clight_scope.
From SM64.Generated Require mario.
From SM64.Proofs Require Import Flying ActionFrame ActionValueFrame MarioMemWF
  ResetBodystate RootedLvalue ValueFrameINV ValueFrameStmt BodyNfDec.

Definition PT_squish : ident -> bool :=
  fun id => orb (Pos.eqb id mario._t'6)
                (orb (Pos.eqb id mario._t'9) (Pos.eqb id mario._t'12)).
Definition FS_squish : list ident := [ mario._marioObj ].

Theorem squish_mario_model_preserves :
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
Proof.
  intros e le m t le' m' out bm Hreach Hm Hv Hwf Htmps Hsat Hexec.
  assert (Hfr : fr PT_squish FS_squish nonflying bm m le).
  { unfold fr, FS_squish. repeat split.
    - exact Hv.
    - exact Hsat.
    - exact Htmps.
    - unfold mem_wf. intros fid Hin. cbn [In] in Hin.
      destruct Hin as [Heq | []]. subst fid. exact Hwf.
    - exact Hm. }
  (* body_nf_ok now via the DECIDABLE checker (direct squishTimer store + rooted
     scale stores + chase-loads all decided structurally). *)
  assert (Hok : body_nf_ok PT_squish FS_squish bm e (fn_body mario.f_squish_mario_model)).
  { apply body_nf_ok_dec_sound. vm_compute. reflexivity. }
  pose proof (exec_body_nf PT_squish FS_squish nonflying bm Hreach
                e le m _ t le' m' out Hexec Hfr Hok) as Hfr'.
  unfold fr in Hfr'. tauto.
Qed.
