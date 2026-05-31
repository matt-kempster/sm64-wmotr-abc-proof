(* ActionValueFrame.v -- P4 Piece A: the VALUE-AWARE frame engine.
 *
 * (docs/r3-action-value-plan.md, phase P4, the "genuinely hard" Axis-2 crux.)
 *
 * THE PROBLEM rung (c) / FlyingFrame left open, stated precisely:
 *   FlyingFrame.frame_preserves_nonflying needs `reach_body_avoids (fly_watched
 *   bg bm)` -- "no reached function writes the action cell". That is FALSE: every
 *   frame, set_mario_action `Sassign`s m->action. So the all-or-nothing
 *   `unchanged_on` (the action cell is never touched) cannot model a real frame.
 *
 * THE FIX (P4 Piece A): track the action cell BY VALUE instead of by no-write.
 * Replace `unchanged_on {action cell}` with the forward value invariant
 *
 *     action_sat Q m bm  :=  forall v, load Mint32 m bm 12 = Some (Vint v) -> Q v
 *
 * "whatever the action field currently loads satisfies Q" (Q := non-flying). This
 * is preserved across a write that EITHER avoids the cell OR stores a Q-value, so
 * unlike unchanged_on it survives the legitimate action writes -- and it composes
 * FORWARD (m -> m1 -> m2) statement by statement, with no unchanged_on
 * transitivity. The per-write obligations are then:
 *   (raw writers)  every direct Sassign of m->action stores a non-flying value
 *                  -- the raw writers all store non-flying LITERALS (Flying.v's
 *                  flying_action_writers = [] is exactly this, syntactically);
 *   (set_mario_action) the one call writer stores its argument's transform, which
 *                  is non-flying when the argument is -- ActionValue.set_mario_action_field.
 *
 * This file builds that engine in bricks. BRICK 1 (here): the avoid-only case --
 * a statement whose assigns all avoid the action cell preserves action_sat (it is
 * the value reading of rung (c)'s unchanged_on). BRICK 2+ (next): permit a safe
 * literal write to the cell; then lift across calls via set_mario_action_field.
 *
 * No Admitted: each brick is proved or its residual is an explicit hypothesis.
 *)

From compcert Require Import Coqlib Maps AST Integers Values Events Memory Globalenvs Ctypes Cop Clight ClightBigstep.
From SM64.Generated Require mario.
From SM64.Proofs Require Import Flying ActionFrame.

(* The action cell as a watched byte-set: 4 bytes at (bm, 12). Reuses the exact
   shape rung (c) consumes (b = bm /\ aofs <= o < aofs + size_chunk Mint32). *)
Definition action_cell (bm : block) : block -> Z -> Prop :=
  fun b o => b = bm /\ 12 <= o < 12 + size_chunk Mint32.

(* The forward value invariant: the action field loads only Q-values. *)
Definition action_sat (Q : int -> Prop) (m : mem) (bm : block) : Prop :=
  forall v, Mem.load Mint32 m bm 12 = Some (Vint v) -> Q v.

(* BRICK 1: a statement whose Sassigns all AVOID the action cell preserves
   action_sat -- because the cell's load is literally unchanged. This is the
   value-level reading of rung (c); the harder bricks relax "avoid" to "avoid or
   store a Q-value". *)
Lemma exec_stmt_action_sat_avoid :
  forall (Q : int -> Prop) ge e le m s t le' m' out bm,
    reach_body_avoids   (action_cell bm) ge ->
    reach_ext_preserves (action_cell bm) ge ->
    exec_stmt function_entry2 ge e le m s t le' m' out ->
    stmt_assigns_avoid (action_cell bm) ge e s ->
    Mem.valid_block m bm ->
    action_sat Q m bm ->
    action_sat Q m' bm.
Proof.
  intros Q ge e le m s t le' m' out bm Hbody Hext Hexec Hav Hvalid Hsat.
  (* the load at the action cell is unchanged across the whole (possibly calling)
     execution, by rung (c)'s interprocedural frame theorem. *)
  assert (Hld : Mem.load Mint32 m' bm 12 = Mem.load Mint32 m bm 12).
  { eapply Mem.load_unchanged_on_1.
    - eapply (proj1 (exec_funcall_reach_unchanged_on (action_cell bm) ge Hbody Hext));
        [ exact Hexec | | exact Hav ].
      intros b o [Hb _]. subst b. exact Hvalid.
    - exact Hvalid.
    - intros i Hi. split; [ reflexivity | exact Hi ]. }
  intros v Hv. apply Hsat. rewrite <- Hld. exact Hv.
Qed.
