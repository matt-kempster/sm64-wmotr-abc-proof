(* ======================================================================= *)
(*  GOAL-2 PLAYGROUND — the "real frame, but tracking Mario's height".       *)
(*                                                                         *)
(*  THIS FILE IS A SANDBOX.  It is deliberately OUTSIDE proofs/ and NOT in  *)
(*  _CoqProject, so:                                                       *)
(*    - `make proofs` never sees it (zero risk to the GOAL-1 build),        *)
(*    - the discipline audit's admit-grep never scans it,                   *)
(*    - `Admitted` / experiments are FINE here.                            *)
(*  It CAN import all of GOAL-1's machinery (the firewall only forbids the  *)
(*  spine from importing playground/Unwired code, not the reverse).         *)
(*                                                                         *)
(*  Compile by hand:                                                       *)
(*    source pipeline/env.sh                                                *)
(*    coqc -R generated SM64.Generated -R proofs SM64.Proofs \              *)
(*         playground/FramePlayground.v                                     *)
(*                                                                         *)
(*  WHEN an experiment here matures (admit-free, worth keeping) promote it  *)
(*  to proofs/WMotRRequiresA/Unwired/ (in _CoqProject: builds + firewalled, *)
(*  but must be admit-free).                                                *)
(* ======================================================================= *)

(* --- THE CORE IDEA -----------------------------------------------------
   GOAL-1's real frame is `execute_mario_action_step_lp` (RealFrameLinked):
   one big-step eval_funcall of f_execute_mario_action over the linked
   program.  GOAL-1 tracks the ACTION CELL — the 4 bytes at (bm, 12) — and
   proves it stays non-flying.

   GOAL-2 wants the SAME real frame but tracking pos[1] — Mario's y — and
   proving it stays BELOW a height bound (the floor-ladder H* + Delta_pot
   argument in docs/goal2-strategy-v2).  So the shifts are:
     action_cell (bm, 12, size 4, a TAINT bit)  ~~>  pos_y_cell (bm, ?, a
     float whose VALUE we bound by an interval).

   Two things are genuinely new for GOAL-2 and this playground is where to
   feel them out:
     (A) We track a NUMERIC VALUE (a binary32 float), not a taint bit — so
         "preservation" is an interval fact (y' <= H*+Delta), needing Flocq
         reasoning about the physics (gravity, the ballistic step).  The
         action-cell machinery only ever asked "is this cell untouched /
         still non-flying"; here the cell IS touched every frame and we must
         bound the new value.
     (B) "The real frame" may need to grow past execute_mario_action to the
         fuller mario_update step (the thing that actually commits pos), OR
         the position update already lives inside the action handlers
         (perform_air_step/perform_ground_step, which GOAL-1 already walked
         for the action cell).  Deciding the right frame boundary for the
         height argument is the first design question — poke at it below.
   --------------------------------------------------------------------- *)

From Coq Require Import ZArith List.
From compcert Require Import Coqlib Maps AST Integers Floats Values Memory
  Globalenvs Ctypes Clight.
From SM64.Generated Require mario.
From SM64.Proofs Require Import SymbolicLinking RealFrameLinked ActionValueFrame.

Import ListNotations.

Section Goal2Frame.
  (* mirror GOAL-1's real-frame section variables *)
  Variable lp : Clight.program.
  Variable bm : block.    (* Mario's MarioState block *)

  (* ---- the tracked cell: pos[1] instead of action -------------------- *)
  (* action lives at offset 12 (mario_state_members).  pos is a
     `tarray tfloat 3`; pos[1] is the y coordinate.  Compute its byte
     offset EXACTLY the way GOAL-1 computes the action offset — via
     field_offset over the composite env, plus 4 bytes for index 1.
     (Left as an experiment: fill in with the field_offset term / vm value.) *)
  Definition pos_field_offset : option Z :=
    match field_offset (prog_comp_env mario.prog) mario._pos mario_state_members with
    | Errors.OK (d, _) => Some d
    | Errors.Error _ => None
    end.

  (* try: `Compute pos_field_offset.` after coqc'ing, to see the y base;
     pos[1] byte offset = that + 4 (one tfloat).  Then a pos_y_cell mirrors
     action_cell: *)
  (* Definition pos_y_cell (bm : block) : block -> Z -> Prop :=
       fun b z => b = bm /\ POSY <= z < POSY + 4.   (* POSY = base + 4 *) *)

  (* ---- the height invariant (the GOAL-2 analog of "non-flying") -------
     Instead of action_sat (the cell holds a non-flying id), we want:
     the float at pos[1] has real value <= YMAX.  Sketch: *)
  (* Definition y_le (YMAX : R) (m : mem) (bm : block) : Prop :=
       forall v, Mem.load Mfloat32 m bm POSY = Some (Vsingle v) ->
                 (B2R _ _ v <= YMAX)%R.                                    *)

  (* ---- THE FIRST EXPERIMENT ------------------------------------------
     GOAL-1's spine lemma is: execute_mario_action_step_lp preserves
     "action non-flying".  The GOAL-2 analog to feel out:

       one real frame preserves "y <= YMAX"   (given the no-A + geometry
       side-conditions from the height-invariant strategy).

     State it, then try to see WHERE it breaks — that tells us what the
     "real frame" for GOAL-2 must include and what Flocq brick is needed.
     Admitted is fine here; this is the sandbox. *)

  (* Lemma one_frame_keeps_y_bounded :
       forall (YMAX : R) (m m' : mem),
         y_le YMAX m bm ->
         execute_mario_action_step_lp lp bm m m' ->   (* GOAL-1's frame *)
         (* ... the no-A / geometry premises ... *)
         y_le YMAX m' bm.
     Proof. Admitted. *)

End Goal2Frame.

(* Scratch: force the pos offset so we can SEE it. *)
Compute (match field_offset (prog_comp_env mario.prog) mario._pos mario_state_members with
         | Errors.OK (d, _) => Some d | _ => None end).
