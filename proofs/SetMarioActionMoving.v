(* SetMarioActionMoving.v -- scoreboard entry #3 / 111: set_mario_action_moving,
 * the first chase fn cleared through the FULL frame (exec_body_nf, with calls and
 * a switch). It exercises every capability at once:
 *   - CALLS (mario_get_floor_class, mario_facing_downhill x2) -- handled by the
 *     honest reach_frame_preserves knob (these read floor/facing, never touch the
 *     action field, so they preserve action_sat; discharged elsewhere by the
 *     callee analysis, here an explicit hypothesis);
 *   - a SWITCH on the action argument (exec_body_nf recurses through Sswitch);
 *   - a DIRECT store m->forwardVel (Obstacle 1: assign_avoids_m_field, forwardVel
 *     @84 disjoint from the action cell [12,16) and the marioObj load [136,140));
 *   - a ROOTED array store (t'7->rawData.asS32[34], t'7 = m->marioObj, off-bm).
 * Crucially the function only RETURNS the (possibly-adjusted) action value; it
 * never writes m->action, so nonflying is preserved.
 *)

From compcert Require Import Coqlib Maps AST Integers Values Memory Globalenvs Ctypes Cop Clight Clightdefs ClightBigstep Events.
From Coq Require Import List Lia.
Import ListNotations.
Import Clightdefs.ClightNotations.
Local Open Scope clight_scope.
From SM64.Generated Require mario.
From SM64.Proofs Require Import Flying ActionFrame ActionValueFrame MarioMemWF
  ResetBodystate RootedLvalue ValueFrameINV ValueFrameStmt.

(* The one tracked store-root temp: t'7 = m->marioObj (the rawData[34] store
   chases through it). forwardVel is written DIRECTLY into m, so it is handled by
   the avoid disjunct, not by a tracked temp. *)
Definition PT_mov : ident -> bool := fun id => Pos.eqb id mario._t'7.
Definition FS_mov : list ident := [ mario._marioObj ].

Theorem set_mario_action_moving_preserves :
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
Proof.
  intros e le m t le' m' out bm Hreach Hm Hv Hwf Htmps Hsat Hexec.
  assert (Hfr : fr PT_mov FS_mov nonflying bm m le).
  { unfold fr, FS_mov. repeat split.
    - exact Hv.
    - exact Hsat.
    - exact Htmps.
    - unfold mem_wf. intros fid Hin. cbn [In] in Hin.
      destruct Hin as [Heq | []]. subst fid. exact Hwf.
    - exact Hm. }
  assert (Hok : body_nf_ok PT_mov FS_mov bm e (fn_body mario.f_set_mario_action_moving)).
  { unfold FS_mov, mario.f_set_mario_action_moving, fn_body.
    cbn [body_nf_ok ls_body_nf_ok].
    repeat apply conj.
    (* True leaves (Sreturn / Sbreak) *)
    all: try solve [ exact I ].
    (* id <> _m, OR an untracked temp's vacuous Sset/Scall obligation *)
    all: try solve [ intro Hx; vm_compute in Hx; discriminate Hx ].
    (* tracked chase-load  t'7 = m->marioObj *)
    all: try solve [ intros _; apply set_off_bm_ok_chase_load; cbn [In]; left; reflexivity ].
    (* rooted array store through t'7 *)
    all: try solve [ left; exists mario._t'7;
                     split; [ apply Pos.eqb_neq; reflexivity
                            | split; reflexivity ] ].
    (* direct store m->forwardVel: avoid the watch set *)
    all: right; eapply assign_avoids_m_field;
      [ vm_compute; reflexivity
      | vm_compute; split; intro Hc; discriminate Hc
      | intros i Hi;
        assert (Hsz : sizeof mario_ge tfloat = 4) by reflexivity;
        rewrite Hsz in Hi;
        intro Hw; unfold watch in Hw; destruct Hw as [Hac | Hch];
        [ destruct Hac as [_ Hr]; change (size_chunk Mint32) with 4 in Hr; lia
        | destruct Hch as (_ & fid & off & Hin & Hfo & Hrange);
          cbn [In] in Hin; destruct Hin as [Hfid | Hempty]; [ | exact Hempty ];
          subst fid;
          assert (Hoff : off = 136) by (clear - Hfo; vm_compute in Hfo; congruence);
          rewrite Hoff in Hrange; change (size_chunk Mptr) with 4 in Hrange; lia ] ]. }
  pose proof (exec_body_nf PT_mov FS_mov nonflying bm Hreach
                e le m _ t le' m' out Hexec Hfr Hok) as Hfr'.
  unfold fr in Hfr'. tauto.
Qed.
