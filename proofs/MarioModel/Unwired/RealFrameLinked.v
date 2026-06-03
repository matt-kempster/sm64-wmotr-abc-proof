(* ====================================================================== *)
(* RE-ROOTING THE FRAME OVER THE LINKED PROGRAM (work in progress).        *)
(*                                                                        *)
(* RealFrameValue.v threads `mario_ge = globalenv mario.prog` through the  *)
(* whole frame: over that single-TU genv the action dispatchers            *)
(* (mario_execute_*_action) are underspecified Externals, which is why the *)
(* capstone must assume the FALSE reach_ext_action_cell. The fix is to      *)
(* re-root the frame over `globalenv lp` for a LINKED program lp (lp kept   *)
(* ABSTRACT -- a linkorder hypothesis, never vm_compute'd, so no OOM).      *)
(* Over globalenv lp those dispatcher Scalls resolve to real Internal       *)
(* bodies (SymbolicLinking.linkorder_resolves_funct) and the engine         *)
(* TRAVERSES them instead of bouncing off the external bucket.             *)
(*                                                                        *)
(* This file is the staging area for that re-derivation. It re-states the   *)
(* frame's genv-facing predicates over an abstract `lp_ge := globalenv lp`  *)
(* and re-proves the eval bricks, consuming the three-part genv interface   *)
(* proved in SymbolicLinking.v (funcall resolution / field-offset agreement *)
(* / symbol preservation). It lives under Unwired/ until the full wrapper   *)
(* is re-rooted and can replace RealFrameValue's mario_ge wrapper on the    *)
(* spine. NOTHING here is consumed by the capstone yet.                     *)
(* ====================================================================== *)

From compcert Require Import Coqlib Errors Maps AST Integers Values Memory Globalenvs
  Ctypes Cop Clightdefs Clight Linking.
From SM64.Generated Require mario.
From SM64.Proofs Require Import SymbolicLinking.

Section ReRoot.
  (* The linked program -- ABSTRACT. The only thing we know is that mario.prog
     links into it (linkorder mario.prog lp). Every cross-TU fact comes from
     this via the SymbolicLinking interface; lp's defmap/cenv are never forced. *)
  Variable lp : Clight.program.
  Hypothesis LO_mario : linkorder mario.prog lp.

  Definition lp_ge : genv := globalenv lp.

  (* ---- genv-facing frame predicates, re-rooted at lp_ge. These are the
     RealFrameValue predicates with mario_ge replaced by lp_ge. The carried
     memory facts (the pointer chase) are identical; only the genv used to
     resolve gMarioState's symbol changes. ---- *)

  Definition gMarioState_wf_lp (m : mem) (bm : block) : Prop :=
    exists gb, Genv.find_symbol lp_ge mario._gMarioState = Some gb /\
               Mem.loadv Mptr m (Vptr gb Ptrofs.zero) = Some (Vptr bm Ptrofs.zero).

  (* The re-rooted gMarioState invariant is SATISFIABLE over lp_ge: the symbol
     resolves there (it is a defined gvar in mario.prog, preserved by linking).
     So re-rooting does not vacuously strand this predicate. *)
  Lemma gMarioState_symbol_resolves_lp :
    exists gb, Genv.find_symbol lp_ge mario._gMarioState = Some gb.
  Proof. unfold lp_ge. apply linking_resolves_gMarioState; exact LO_mario. Qed.

  (* THE FIRST RE-ROOTED EVAL BRICK: `gMarioState` (a pointer-typed global read)
     evaluates to Vptr bm 0 over lp_ge, given the re-rooted wf and that the symbol
     is not shadowed by a local. Identical script to RealFrameValue's
     eval_Evar_gMarioState_bm, but over lp_ge -- the proof is genv-parametric;
     all it needs from the genv is find_symbol, supplied by gMarioState_wf_lp. *)
  Lemma eval_Evar_gMarioState_bm_lp :
    forall e le m bm,
      e ! mario._gMarioState = None ->
      gMarioState_wf_lp m bm ->
      eval_expr lp_ge e le m
        (Evar mario._gMarioState (tptr (Tstruct mario._MarioState noattr)))
        (Vptr bm Ptrofs.zero).
  Proof.
    intros e le m bm He (gb & Hsym & Hload).
    eapply eval_Elvalue.
    - eapply eval_Evar_global; eauto.
    - eapply deref_loc_value with (chunk := Mptr); [ reflexivity | ].
      unfold Mem.loadv. exact Hload.
  Qed.

  (* Offset faithfulness, packaged for this section: over lp_ge the action cell
     is still byte 12 of MarioState (linking does not move it). This is what lets
     the re-rooted engine keep RealFrameValue's concrete action@12 reasoning. *)
  Lemma action_offset_lp :
    field_offset (prog_comp_env lp) mario._action mario_state_members
      = Errors.OK (12, Full).
  Proof. apply linking_preserves_action_offset; exact LO_mario. Qed.

End ReRoot.
