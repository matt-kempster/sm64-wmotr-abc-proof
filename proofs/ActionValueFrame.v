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

(* ================================================================== *)
(* BRICK 2: relax "avoid" to "avoid OR store a Q-value".               *)
(*                                                                     *)
(* Brick 1 covers the case where the write misses the action cell (the *)
(* cell's load is literally unchanged). The new content here is the    *)
(* OTHER disjunct: a write that LANDS ON the cell still preserves      *)
(* action_sat, provided the stored value satisfies Q. This is what     *)
(* unchanged_on could never express -- and it is exactly what the raw  *)
(* action writers need: they all store non-flying LITERALS (Flying.v's *)
(* flying_action_writers = [] is that fact syntactically), so with     *)
(* Q := non-flying every raw write preserves "the action is non-flying".*)
(*                                                                     *)
(* Proved at the leaf (one assign_loc): the Mem-level store fact, then *)
(* its Clight assign_loc lift, then the combined avoid|store leaf that  *)
(* the value-aware statement induction will consume per Sassign.       *)
(* ================================================================== *)

(* Brick 2a (memory level): storing a Q-value (Vint w, Q w) into the   *)
(* action cell makes action_sat hold -- the cell now loads exactly that *)
(* value, and Mem.load_store_same pins it. *)
Lemma store_action_cell_sat :
  forall (Q : int -> Prop) m bm w m',
    Mem.store Mint32 m bm 12 (Vint w) = Some m' ->
    Q w ->
    action_sat Q m' bm.
Proof.
  intros Q m bm w m' Hst HQ. unfold action_sat. intros v0 Hld.
  pose proof (Mem.load_store_same _ _ _ _ _ _ Hst) as Hsame.
  cbn [Val.load_result] in Hsame. rewrite Hsame in Hld. inv Hld. exact HQ.
Qed.

(* Brick 2b (Clight level): a By_value Mint32 assign_loc of (Vint w),  *)
(* Q w, into the action cell (offset 12, Full) preserves action_sat.    *)
(* The By_copy/bitfield cases of assign_loc are impossible here (value  *)
(* is a Vint, kind is Full), so inversion leaves only the store case.   *)
Lemma assign_loc_action_sat_store :
  forall (Q : int -> Prop) ce ty m bm ofs v m' w,
    access_mode ty = By_value Mint32 ->
    Ptrofs.unsigned ofs = 12 ->
    v = Vint w ->
    Q w ->
    assign_loc ce ty m bm ofs Full v m' ->
    action_sat Q m' bm.
Proof.
  intros Q ce ty m bm ofs v m' w Ham Hofs Hv HQ Hassign. subst v.
  inv Hassign.
  match goal with
  | Hac : access_mode ty = By_value ?chunk,
    Hs  : Mem.storev ?chunk _ _ _ = Some _ |- _ =>
      assert (Hck : chunk = Mint32) by congruence; subst chunk;
      unfold Mem.storev in Hs; rewrite Hofs in Hs;
      eapply store_action_cell_sat; [ exact Hs | exact HQ ]
  end.
Qed.

(* Brick 2c (the avoid disjunct as a leaf): a write whose byte-range    *)
(* avoids the action cell preserves action_sat (the leaf reading of     *)
(* brick 1, for a single assign_loc rather than a whole statement). *)
Lemma assign_loc_action_sat_avoid :
  forall (Q : int -> Prop) ce ty m bm loc ofs bf v m',
    assign_loc ce ty m loc ofs bf v m' ->
    Mem.valid_block m bm ->
    (forall i, Ptrofs.unsigned ofs <= i < Ptrofs.unsigned ofs + sizeof ce ty ->
               ~ action_cell bm loc i) ->
    action_sat Q m bm ->
    action_sat Q m' bm.
Proof.
  intros Q ce ty m bm loc ofs bf v m' Hassign Hvalid Havoid Hsat.
  unfold action_sat. intros v0 Hld. apply Hsat.
  assert (U : Mem.unchanged_on (action_cell bm) m m')
    by (eapply assign_loc_unchanged_on; eauto).
  assert (Heq : Mem.load Mint32 m' bm 12 = Mem.load Mint32 m bm 12).
  { eapply Mem.load_unchanged_on_1; [ exact U | exact Hvalid | ].
    intros i Hi. split; [ reflexivity | exact Hi ]. }
  rewrite <- Heq. exact Hld.
Qed.

(* Brick 2 (the relaxation, assembled): a single assign_loc preserves   *)
(* action_sat when it EITHER avoids the action cell OR stores a Q-value  *)
(* into it. This is the per-Sassign obligation the value-aware statement *)
(* induction will discharge -- "avoid" for non-action writes, "store a   *)
(* Q-value" for the raw action writers (non-flying literals). *)
Lemma assign_loc_action_sat :
  forall (Q : int -> Prop) ce ty m bm loc ofs bf v m',
    assign_loc ce ty m loc ofs bf v m' ->
    Mem.valid_block m bm ->
    action_sat Q m bm ->
    ( (forall i, Ptrofs.unsigned ofs <= i < Ptrofs.unsigned ofs + sizeof ce ty ->
                 ~ action_cell bm loc i)
      \/ (loc = bm /\ Ptrofs.unsigned ofs = 12 /\ access_mode ty = By_value Mint32
          /\ bf = Full /\ exists w, v = Vint w /\ Q w) ) ->
    action_sat Q m' bm.
Proof.
  intros Q ce ty m bm loc ofs bf v m' Hassign Hvalid Hsat [Havoid | Hstore].
  - eapply assign_loc_action_sat_avoid; eauto.
  - destruct Hstore as (Hloc & Hofs & Ham & Hbf & w & Hv & HQ). subst loc bf.
    eapply assign_loc_action_sat_store; eauto.
Qed.

(* Non-vacuity / the intended use: with Q := "non-flying", storing a     *)
(* non-flying literal into the action cell preserves "the action field   *)
(* is non-flying". This is the value-level statement of why the raw      *)
(* action writers (all non-flying literals) are harmless. *)
Corollary store_nonflying_preserves_nonflying :
  forall m bm w m',
    is_flying_int w = false ->
    Mem.store Mint32 m bm 12 (Vint w) = Some m' ->
    action_sat (fun v => is_flying_int v = false) m' bm.
Proof.
  intros m bm w m' Hnf Hst.
  eapply store_action_cell_sat; [ exact Hst | exact Hnf ].
Qed.
