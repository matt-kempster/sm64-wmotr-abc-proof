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
From Coq Require Import Classical_Prop.
From SM64.Generated Require mario.
From SM64.Proofs Require Import Flying FieldNonInterference ActionValue.

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

(* ================================================================== *)
(* BRICK 3: the ONE call writer, lifted into the value language.       *)
(*                                                                     *)
(* set_mario_action is the single function that writes m->action       *)
(* through a call (the choke point). ActionValue.set_mario_action_field *)
(* already proved the genuinely hard fact -- executing its body with a  *)
(* non-flying action argument leaves m->action holding a NON-FLYING     *)
(* value (the switch picks a group setter that only downgrades, then    *)
(* `m->action = _action`). Brick 3 simply restates that existential-    *)
(* load payoff in the value-aware frame language: the body execution    *)
(* ESTABLISHES action_sat (non-flying). This is the "permitted writer"  *)
(* case -- the counterpart, for the one call site, of brick 2's leaf    *)
(* for raw literal writes. The statement induction's Scall branch will  *)
(* consume it (after wiring eval_funcall -> body via function_entry2,   *)
(* which is the assembly step, not this brick).                         *)
(* ================================================================== *)
Lemma set_mario_action_body_action_sat :
  forall (e : env) (le : temp_env) (m : mem) (a arg : int) (t : trace)
         (le' : temp_env) (m' : mem) (out : outcome) (bm : block),
    e ! mario._set_mario_action_moving    = None ->
    e ! mario._set_mario_action_airborne  = None ->
    e ! mario._set_mario_action_submerged = None ->
    e ! mario._set_mario_action_cutscene  = None ->
    is_flying_int a = false ->
    le ! mario._action    = Some (Vint a) ->
    le ! mario._actionArg = Some (Vint arg) ->
    le ! mario._m = Some (Vptr bm Ptrofs.zero) ->
    exec_stmt function_entry2 set_mario_action_ge e le m (fn_body mario.f_set_mario_action) t le' m' out ->
    action_sat (fun v => is_flying_int v = false) m' bm.
Proof.
  intros e le m a arg t le' m' out bm Hm1 Hm2 Hm3 Hm4 Hnf Hact Harg Hmptr Hexec.
  destruct (set_mario_action_field e le m a arg bm t le' m' out
              Hm1 Hm2 Hm3 Hm4 Hmptr Hact Harg Hnf Hexec) as (Hout & w & Hld & Hwnf).
  unfold action_sat. intros v0 Hv0. rewrite Hld in Hv0. inv Hv0. exact Hwnf.
Qed.

(* ================================================================== *)
(* CAPSTONE part A: the per-Sassign VALUE obligation and its lift over *)
(* a whole statement.                                                   *)
(*                                                                     *)
(* The value analogue of FieldNonInterference's assign_avoids / stmt_assigns_   *)
(* avoid. Where the avoid version demands EVERY Sassign miss the action *)
(* cell, the value version allows a Sassign to LAND on the cell as long *)
(* as the value it stores satisfies Q -- precisely brick 2's disjunct.  *)
(* (This is the strict upgrade that lets the caller's own raw action     *)
(* writers through: they store non-flying literals.)                    *)
(* ================================================================== *)

(* For a single assignment `a1 = a2`: in any state, whatever location    *)
(* the lvalue names and whatever value the rhs casts to, the write       *)
(* EITHER avoids the action cell OR lands on it storing a Q-value. The    *)
(* shape matches exec_stmt's Sassign constructor (eval_lvalue / eval_expr *)
(* / sem_cast), so it is directly consumable there. *)
Definition assign_value_ok (Q : int -> Prop) (bm : block) (ge : genv) (e : env)
                           (a1 a2 : expr) : Prop :=
  forall le m loc ofs bf v2 v,
    eval_lvalue ge e le m a1 loc ofs bf ->
    eval_expr ge e le m a2 v2 ->
    sem_cast v2 (typeof a2) (typeof a1) m = Some v ->
    ( (forall i, Ptrofs.unsigned ofs <= i < Ptrofs.unsigned ofs + sizeof ge (typeof a1) ->
                 ~ action_cell bm loc i)
      \/ (loc = bm /\ Ptrofs.unsigned ofs = 12 /\ access_mode (typeof a1) = By_value Mint32
          /\ bf = Full /\ exists w, v = Vint w /\ Q w) ).

(* Structural lift over a whole statement: every Sassign in s is value-ok. *)
(* (Scall/Sbuiltin map to True -- they are governed by the reach_* call    *)
(* hypotheses, not by the caller's per-Sassign scan.) *)
Fixpoint stmt_value_ok (Q : int -> Prop) (bm : block) (ge : genv) (e : env)
                       (s : statement) : Prop :=
  match s with
  | Sassign a1 a2       => assign_value_ok Q bm ge e a1 a2
  | Ssequence s1 s2     => stmt_value_ok Q bm ge e s1 /\ stmt_value_ok Q bm ge e s2
  | Sifthenelse _ s1 s2 => stmt_value_ok Q bm ge e s1 /\ stmt_value_ok Q bm ge e s2
  | Sloop s1 s2         => stmt_value_ok Q bm ge e s1 /\ stmt_value_ok Q bm ge e s2
  | Slabel _ s1         => stmt_value_ok Q bm ge e s1
  | Sswitch _ ls        => ls_value_ok Q bm ge e ls
  | _                   => True
  end
with ls_value_ok (Q : int -> Prop) (bm : block) (ge : genv) (e : env)
                 (ls : labeled_statements) : Prop :=
  match ls with
  | LSnil           => True
  | LScons _ s rest => stmt_value_ok Q bm ge e s /\ ls_value_ok Q bm ge e rest
  end.

(* select_switch / seq_of_labeled_statement preserve stmt_value_ok -- the   *)
(* switch case of the induction (mirrors FieldNonInterference's *_assigns_avoid).     *)
Lemma ssd_value_ok :
  forall Q bm ge e sl, ls_value_ok Q bm ge e sl ->
    ls_value_ok Q bm ge e (select_switch_default sl).
Proof.
  induction sl as [| o s rest IH]; simpl; intros H; auto.
  destruct o as [c|]; simpl.
  - destruct H as [_ Hrest]. apply IH; exact Hrest.
  - exact H.
Qed.

Lemma ssc_value_ok :
  forall Q bm ge e n sl res,
    ls_value_ok Q bm ge e sl -> select_switch_case n sl = Some res ->
    ls_value_ok Q bm ge e res.
Proof.
  induction sl as [| o s rest IH]; simpl; intros res Hav Hsel; try discriminate.
  destruct Hav as [Hs Hrest]. destruct o as [c|]; simpl in Hsel.
  - destruct (zeq c n).
    + inv Hsel. simpl. split; [ exact Hs | exact Hrest ].
    + eapply IH; eauto.
  - eapply IH; eauto.
Qed.

Lemma select_switch_value_ok :
  forall Q bm ge e n sl,
    ls_value_ok Q bm ge e sl -> ls_value_ok Q bm ge e (select_switch n sl).
Proof.
  intros Q bm ge e n sl H. unfold select_switch.
  destruct (select_switch_case n sl) eqn:E.
  - eapply ssc_value_ok; eauto.
  - apply ssd_value_ok; auto.
Qed.

Lemma seq_of_ls_value_ok :
  forall Q bm ge e ls,
    ls_value_ok Q bm ge e ls -> stmt_value_ok Q bm ge e (seq_of_labeled_statement ls).
Proof.
  induction ls as [| o s rest IH]; simpl; intros H; auto.
  destruct H. split; auto.
Qed.

(* ================================================================== *)
(* AVOIDANCE => VALUE-OK: the bridge from the (proven) pure-aliasing     *)
(* avoidance language to the value language. A Sassign whose lvalue      *)
(* AVOIDS the action cell is value-ok (it takes the LEFT disjunct of     *)
(* assign_value_ok). Hence any body that never writes the action cell is *)
(* value-ok, and leaf-A (reach_value_body_nonwriter) reduces to          *)
(* stmt_assigns_avoid (action_cell bm) ge e (fn_body f) -- the SAME      *)
(* reach_body_avoids-shaped obligation MarioMemWF discharges by block/   *)
(* offset distinctness. This is what makes leaf-A the L1 aliasing fan-out *)
(* (no value reasoning needed for the non-set_mario_action bodies, which *)
(* by the set_mario_action choke point never raw-write the action cell). *)
(* ================================================================== *)
Lemma assign_avoids_value_ok :
  forall Q bm ge e a1 a2,
    assign_avoids (action_cell bm) ge e a1 ->
    assign_value_ok Q bm ge e a1 a2.
Proof.
  intros Q bm ge e a1 a2 Hav le m loc ofs bf v2 v Hlv He Hcast.
  left. intros i Hi. eapply Hav; [ exact Hlv | exact Hi ].
Qed.

Scheme statement_ind2 := Induction for statement Sort Prop
  with ls_ind2 := Induction for labeled_statements Sort Prop.
Combined Scheme stmt_ls_ind from statement_ind2, ls_ind2.

Lemma stmt_assigns_avoid_value_ok :
  forall Q bm ge e,
    (forall s, stmt_assigns_avoid (action_cell bm) ge e s -> stmt_value_ok Q bm ge e s)
    /\ (forall ls, ls_assigns_avoid (action_cell bm) ge e ls -> ls_value_ok Q bm ge e ls).
Proof.
  intros Q bm ge e.
  apply stmt_ls_ind; intros; simpl in *;
    repeat match goal with
           | [ H : _ /\ _ |- _ ] => destruct H
           | [ |- _ /\ _ ] => split
           | [ |- True ] => exact I
           end;
    auto using assign_avoids_value_ok.
Qed.

(* The per-body corollary the capstone's leaf-A discharge will consume:    *)
(* a function body that avoids the action cell is value-ok. *)
Corollary body_avoids_value_ok :
  forall Q bm ge e s,
    stmt_assigns_avoid (action_cell bm) ge e s ->
    stmt_value_ok Q bm ge e s.
Proof. intros Q bm ge e s. apply (proj1 (stmt_assigns_avoid_value_ok Q bm ge e)). Qed.

(* ================================================================== *)
(* CAPSTONE part B: forward-monotonicity helpers + the induction.      *)
(* ================================================================== *)

(* assign_loc never invalidates an existing block (it only stores).     *)
(* Uniform over the three assign_loc kinds, like assign_loc_unchanged_on.*)
Lemma assign_loc_valid_block :
  forall ce ty m loc ofs bf v m' b,
    assign_loc ce ty m loc ofs bf v m' ->
    Mem.valid_block m b ->
    Mem.valid_block m' b.
Proof.
  intros ce ty m loc ofs bf v m' b Hassign Hvalid. inv Hassign.
  - match goal with Hs : Mem.storev _ _ _ _ = Some _ |- _ =>
      unfold Mem.storev in Hs; eapply Mem.store_valid_block_1; eauto end.
  - match goal with Hsb : Mem.storebytes _ _ _ _ = Some _ |- _ =>
      eapply Mem.storebytes_valid_block_1; eauto end.
  - match goal with Hbf : store_bitfield _ _ _ _ _ _ _ _ _ _ |- _ => inv Hbf end.
    match goal with Hs : Mem.storev _ _ _ _ = Some _ |- _ =>
      unfold Mem.storev in Hs; eapply Mem.store_valid_block_1; eauto end.
Qed.

(* unchanged_on the action cell transports action_sat forward (the      *)
(* externals/avoid route -- the load at 12 is unchanged). *)
Lemma action_sat_unchanged_on :
  forall Q m m' bm,
    Mem.unchanged_on (action_cell bm) m m' ->
    Mem.valid_block m bm ->
    action_sat Q m bm ->
    action_sat Q m' bm.
Proof.
  intros Q m m' bm Hu Hvalid Hsat. unfold action_sat. intros v0 Hld. apply Hsat.
  assert (Heq : Mem.load Mint32 m' bm 12 = Mem.load Mint32 m bm 12).
  { eapply Mem.load_unchanged_on_1;
      [ exact Hu | exact Hvalid | intros i Hi; split; [ reflexivity | exact Hi ] ]. }
  rewrite <- Heq. exact Hld.
Qed.

(* The honest boundary at the FUNCALL level (the value analogue of      *)
(* FieldNonInterference.reach_body_avoids, but stated for whole calls so the     *)
(* statement induction below can stay non-mutual). Every reached funcall *)
(* that starts with action_sat holding and bm valid ends the same way.   *)
(* P4's remaining work DISCHARGES this by a case split: set_mario_action  *)
(* via brick 3 (given non-flying args = the P3 ActionReach invariant),    *)
(* every other reached function via brick 1's unchanged_on route. Until   *)
(* then it is an explicit assumption, not hidden. *)
Definition reach_value_preserves (Q : int -> Prop) (bm : block) (ge : genv) : Prop :=
  forall m fd vargs t m' vres,
    eval_funcall function_entry2 ge m fd vargs t m' vres ->
    Mem.valid_block m bm ->
    action_sat Q m bm ->
    Mem.valid_block m' bm /\ action_sat Q m' bm.

(* ====================================================================== *)
(* DECOMPOSING the crux: the writer / non-writer split (no-A conditioned). *)
(*                                                                        *)
(* `reach_value_preserves Q bm mario_ge` (above) is, for the REAL Mario    *)
(* genv, FALSE: set_mario_action(., ACT_FLYING, .) is a reached            *)
(* eval_funcall that turns the action flying. It is ALSO unconditioned --  *)
(* it ignores the no-A precondition that is the whole point. We refine it  *)
(* (decompose, never collapse) along the only real fault line: among ALL   *)
(* reached funcalls, exactly ONE (set_mario_action) writes the action      *)
(* cell; every other leaves it untouched.                                  *)
(*                                                                        *)
(*   reach_nonwriter_unchanged -- every reached funcall that is NOT the     *)
(*     designated `writer` leaves the action cell unchanged_on (=> any      *)
(*     action_sat Q survives, via action_sat_unchanged_on). TRUE; its       *)
(*     discharge is per-function offset-avoidance over the call graph.      *)
(*   reach_writer_preserves_noA -- the writer case, conditioned on a no-A   *)
(*     memory predicate `NoA`. TRUE at the real NoA (a no-A frame calls      *)
(*     set_mario_action only with a non-flying argument -- the taint-       *)
(*     closure crux); NON-VACUOUS because NoA pins it to the real no-A runs. *)
(*                                                                        *)
(* The two compose to the no-A-CONDITIONED reach property below, which is   *)
(* what the per-frame proof can actually supply (the frame carries          *)
(* a_pressed=false). This is how the FALSE unconditional residual leaves    *)
(* the capstone. NoA itself becomes the next thing to GROUND (in the real   *)
(* controller bytes) -- the same honest move as grounding the abstract     *)
(* `step` into the real eval_funcall.                                      *)
(* ====================================================================== *)

Definition reach_value_preserves_noA
    (Q : int -> Prop) (bm : block) (ge : genv) (NoA : mem -> Prop) : Prop :=
  forall m fd vargs t m' vres,
    NoA m ->
    eval_funcall function_entry2 ge m fd vargs t m' vres ->
    Mem.valid_block m bm ->
    action_sat Q m bm ->
    Mem.valid_block m' bm /\ action_sat Q m' bm.

(* WARNING -- FALSE for the real Mario genv (see exec_funcall_reach_value_noA
   below, which RETIRES it). This classifies WHOLE funcalls writer/non-writer,
   but "writes the action cell" is TRANSITIVE: act_walking is not set_mario_action
   yet it CALLS set_mario_action, so a whole-funcall of act_walking DOES change
   the cell -- unchanged_on fails. So in the regime the capstone consumes this
   (the direct callees of execute_mario_action, which transitively write) the
   hypothesis is UNSATISFIABLE, making any reach property built on it vacuous.
   The sound fix classifies DIRECT BODY Sassigns and lets the mutual induction
   handle transitivity (Scall -> funcall IH). Kept only because
   reach_value_preserves_noA_split (above) still references it as a true
   implication; the spine no longer uses that split. *)
Definition reach_nonwriter_unchanged
    (bm : block) (ge : genv) (writer : Clight.fundef -> Prop) : Prop :=
  forall m fd vargs t m' vres,
    eval_funcall function_entry2 ge m fd vargs t m' vres ->
    ~ writer fd ->
    Mem.valid_block m bm ->
    Mem.valid_block m' bm /\ Mem.unchanged_on (action_cell bm) m m'.

Definition reach_writer_preserves_noA
    (Q : int -> Prop) (bm : block) (ge : genv)
    (writer : Clight.fundef -> Prop) (NoA : mem -> Prop) : Prop :=
  forall m fd vargs t m' vres,
    NoA m ->
    eval_funcall function_entry2 ge m fd vargs t m' vres ->
    writer fd ->
    Mem.valid_block m bm ->
    action_sat Q m bm ->
    Mem.valid_block m' bm /\ action_sat Q m' bm.

(* THE GLUE (proved): writer-isolation + the conditioned writer case give    *)
(* the conditioned reach property. A clean case split on `writer fd`         *)
(* (classical, already in the capstone's axiom footprint); the non-writer    *)
(* branch closes by action_sat_unchanged_on. *)
Lemma reach_value_preserves_noA_split :
  forall Q bm ge writer NoA,
    reach_nonwriter_unchanged bm ge writer ->
    reach_writer_preserves_noA Q bm ge writer NoA ->
    reach_value_preserves_noA Q bm ge NoA.
Proof.
  intros Q bm ge writer NoA Hnw Hw m fd vargs t m' vres HnoA Hev Hv Hsat.
  destruct (classic (writer fd)) as [Hwr | Hnwr].
  - eapply Hw; eauto.
  - destruct (Hnw m fd vargs t m' vres Hev Hnwr Hv) as [Hv' Hunch].
    split; [ exact Hv' | ].
    eapply action_sat_unchanged_on; [ exact Hunch | exact Hv | exact Hsat ].
Qed.

(* ====================================================================== *)
(* ARG-PROVENANCE -- the TYPE-FORCED fix for the leaf-A phantom.           *)
(*                                                                        *)
(* reach_value_preserves_noA (above) quantifies `forall vargs`, so it is   *)
(* FALSE for a misaligned Mario arg: Vptr bm (12-delta) handed to a NON-   *)
(* writer makes an `m->field` store land on the action cell (bm,12). Hence *)
(* ANY leaf strong enough to prove reach_value_preserves_noA is itself     *)
(* false-for-misaligned-vargs -- the phantom is TYPE-FORCED, not an        *)
(* accident of leaf-A's shape, so no isolated swap of leaf-A discharges it.*)
(* The honest output must carry an arg-provenance precondition, threaded   *)
(* from execute_mario_action (which loads gMarioState => Vptr bm 0) across *)
(* every reached call. generated/mario.v shows the threading is UNIFORM:   *)
(* every reached call is `Sset t (Evar gMarioState); Scall .. (Etempvar t)`*)
(* so the Mario arg is always a temp freshly loaded from the global.       *)
(*                                                                        *)
(* This section builds the bottom brick of that re-typing: the predicate   *)
(* marg_ok + the genv-light bridge deriving it at a call site whose Mario   *)
(* arg temp is known (bm,0)-or-off-bm. NOT yet consumed by the capstone --  *)
(* the consumer chain (reach_meminv_noA in RealFrameValue, the body census  *)
(* prov_ok's call-arg case, and the value engine motives) must be re-typed  *)
(* to carry marg_ok before this brick replaces reach_value_body_nonwriter.  *)
(* ====================================================================== *)

(* the call's first argument, if it points into bm, is aligned at offset 0.
   (Mario is always passed as arg0 among the reached funcalls.) *)
Definition marg_ok (bm : block) (vargs : list val) : Prop :=
  match vargs with
  | Vptr b o :: _ => b = bm -> o = Ptrofs.zero
  | _ => True
  end.

(* one temp's no-misalignment provenance: if it holds a pointer INTO bm, that
   pointer is (bm,0). The clean SEMANTIC invariant (no per-temp hardwiring) that
   generalises RealFrameValue.tat over all the gMarioState-loaded arg temps. *)
Definition tat0 (bm : block) (le : temp_env) (t : ident) : Prop :=
  forall b o, le ! t = Some (Vptr b o) -> b = bm -> o = Ptrofs.zero.

(* sem_cast of a genuine pointer to a pointer type is the identity: cast_case_
   pointer returns Some v for ANY Vptr, independent of Archi.ptr64. The ptr64
   hazard is Vint-inference, which never bites a real Vptr argument. *)
Lemma sem_cast_ptr_ptr_id :
  forall b o pty1 a1 pty2 a2 m,
    sem_cast (Vptr b o) (Tpointer pty1 a1) (Tpointer pty2 a2) m = Some (Vptr b o).
Proof.
  intros. reflexivity.
Qed.

(* the bridge: at a call whose first argument is a pointer-typed temp known to be
   (bm,0)-or-off-bm, the resulting vargs satisfy marg_ok. Pure eval_exprlist /
   eval_Etempvar / sem_cast reasoning -- genv-cenv is never forced. *)
Lemma eval_exprlist_temp_marg_ok :
  forall ge e le m t pty1 a1 pty2 a2 rest tyl vargs bm,
    tat0 bm le t ->
    eval_exprlist ge e le m
      (Etempvar t (Tpointer pty1 a1) :: rest) (Tpointer pty2 a2 :: tyl) vargs ->
    marg_ok bm vargs.
Proof.
  intros ge e le m t pty1 a1 pty2 a2 rest tyl vargs bm Hat Hel.
  inv Hel.
  match goal with H : eval_expr _ _ _ _ (Etempvar _ _) ?v |- _ =>
    rename H into Heval; rename v into v1 end.
  match goal with H : sem_cast _ _ _ _ = Some ?v |- _ =>
    rename H into Hcast; rename v into v1' end.
  assert (Hget : le ! t = Some v1).
  { inv Heval; [ assumption
               | match goal with H : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv H end ]. }
  (* marg_ok only constrains a Vptr head; case on the cast result v1' *)
  unfold marg_ok. destruct v1' as [| | | | | b o]; auto. intro Hbm; subst b.
  (* a Vptr out of sem_cast from a pointer type forces v1 to be that same Vptr *)
  destruct v1 as [| | | | | b1 o1]; cbn in Hcast; try discriminate.
  inv Hcast. exact (Hat bm o Hget eq_refl).
Qed.

(* THE CAPSTONE: the value-aware statement frame. Executing any clightgen *)
(* statement (calls and loops included) carries action_sat Q FORWARD,      *)
(* given (i) the caller's own Sassigns are value-ok (brick 2: each avoids  *)
(* the cell OR stores a Q-value), (ii) reached funcalls preserve action_sat *)
(* (reach_value_preserves), (iii) reached externals preserve the cell      *)
(* (reach_ext_preserves). Compare FieldNonInterference.exec_funcall_reach_unchanged_*)
(* on: unchanged_on is replaced by the forward value invariant, so the      *)
(* legitimate action writes (raw literals + set_mario_action) are no longer *)
(* fatal -- they are absorbed by the value-ok / reach_value disjuncts.      *)
Theorem exec_stmt_value_preserves :
  forall (Q : int -> Prop) (bm : block) (ge : genv),
    reach_value_preserves Q bm ge ->
    reach_ext_preserves (action_cell bm) ge ->
    forall e le m s t le' m' out,
      exec_stmt function_entry2 ge e le m s t le' m' out ->
      Mem.valid_block m bm ->
      action_sat Q m bm ->
      stmt_value_ok Q bm ge e s ->
      Mem.valid_block m' bm /\ action_sat Q m' bm.
Proof.
  intros Q bm ge Hreach Hext e le m s t le' m' out H.
  induction H; intros Hvalid Hsat Hok.
  - (* Sskip *) split; [ exact Hvalid | exact Hsat ].
  - (* Sassign *)
    simpl in Hok.
    match goal with
    | Hlv : eval_lvalue _ _ _ _ ?a1 ?loc ?ofs ?bf,
      He  : eval_expr _ _ _ _ ?a2 ?v2,
      Hc  : sem_cast ?v2 _ _ _ = Some ?v,
      Has : assign_loc _ _ _ ?loc ?ofs ?bf ?v _ |- _ =>
        split;
        [ eapply assign_loc_valid_block; [ exact Has | exact Hvalid ]
        | eapply assign_loc_action_sat;
            [ exact Has | exact Hvalid | exact Hsat
            | exact (Hok _ _ _ _ _ _ _ Hlv He Hc) ] ]
    end.
  - (* Sset: no memory effect *) split; [ exact Hvalid | exact Hsat ].
  - (* Scall: the funcall boundary hypothesis *)
    match goal with
    | Hfc : eval_funcall function_entry2 ge _ _ _ _ _ _ |- _ =>
        exact (Hreach _ _ _ _ _ _ Hfc Hvalid Hsat)
    end.
  - (* Sbuiltin: external call preserves the cell (and validity) *)
    match goal with
    | Hec : external_call _ _ _ _ _ _ _ |- _ =>
        split;
        [ eapply external_call_valid_block; [ exact Hec | exact Hvalid ]
        | eapply action_sat_unchanged_on;
            [ eapply Hext; exact Hec | exact Hvalid | exact Hsat ] ]
    end.
  - (* Sseq_1: s1 normal then s2 *)
    simpl in Hok;
    match goal with
    | IH1 : Mem.valid_block ?m1 bm -> action_sat _ ?m1 bm -> _,
      IH2 : Mem.valid_block ?m2 bm -> action_sat _ ?m2 bm -> _ -> Mem.valid_block ?mf bm /\ _
      |- Mem.valid_block ?mf bm /\ _ =>
        destruct (IH1 Hvalid Hsat (proj1 Hok)) as [Hv1 Hs1];
        apply (IH2 Hv1 Hs1 (proj2 Hok))
    end.
  - (* Sseq_2: s1 abnormal *)
    simpl in Hok;
    match goal with
    | IH : Mem.valid_block ?mx bm -> action_sat _ ?mx bm -> _ |- _ =>
        apply IH; [ exact Hvalid | exact Hsat | exact (proj1 Hok) ]
    end.
  - (* Sifthenelse *)
    simpl in Hok;
    match goal with
    | IH : Mem.valid_block ?mx bm -> action_sat _ ?mx bm -> _ -> Mem.valid_block ?mf bm /\ _
      |- Mem.valid_block ?mf bm /\ _ =>
        apply IH;
          [ exact Hvalid | exact Hsat
          | destruct b; [ exact (proj1 Hok) | exact (proj2 Hok) ] ]
    end.
  - (* Sreturn_none *) split; [ exact Hvalid | exact Hsat ].
  - (* Sreturn_some *) split; [ exact Hvalid | exact Hsat ].
  - (* Sbreak *) split; [ exact Hvalid | exact Hsat ].
  - (* Scontinue *) split; [ exact Hvalid | exact Hsat ].
  - (* Sloop_stop1: only s1 ran *)
    simpl in Hok;
    match goal with
    | IH : Mem.valid_block ?mx bm -> action_sat _ ?mx bm -> _ |- _ =>
        apply IH; [ exact Hvalid | exact Hsat | exact (proj1 Hok) ]
    end.
  - (* Sloop_stop2: s1 then s2 *)
    simpl in Hok;
    match goal with
    | IH1 : Mem.valid_block ?m1 bm -> action_sat _ ?m1 bm -> _,
      IH2 : Mem.valid_block ?m2 bm -> action_sat _ ?m2 bm -> _ -> Mem.valid_block ?mf bm /\ _
      |- Mem.valid_block ?mf bm /\ _ =>
        destruct (IH1 Hvalid Hsat (proj1 Hok)) as [Hv1 Hs1];
        apply (IH2 Hv1 Hs1 (proj2 Hok))
    end.
  - (* Sloop_loop: s1, s2, then the loop again *)
    simpl in Hok;
    match goal with
    | IH1 : Mem.valid_block ?m1 bm -> action_sat _ ?m1 bm -> _,
      IH2 : Mem.valid_block ?m2 bm -> action_sat _ ?m2 bm -> _,
      IH3 : Mem.valid_block ?m3 bm -> action_sat _ ?m3 bm -> _ -> Mem.valid_block ?mf bm /\ _
      |- Mem.valid_block ?mf bm /\ _ =>
        destruct (IH1 Hvalid Hsat (proj1 Hok)) as [Hv1 Hs1];
        destruct (IH2 Hv1 Hs1 (proj2 Hok)) as [Hv2 Hs2];
        apply (IH3 Hv2 Hs2 (conj (proj1 Hok) (proj2 Hok)))
    end.
  - (* Sswitch: reduce to the selected sequence *)
    simpl in Hok;
    match goal with
    | IH : Mem.valid_block ?mx bm -> action_sat _ ?mx bm -> _ -> Mem.valid_block ?mf bm /\ _
      |- Mem.valid_block ?mf bm /\ _ =>
        apply IH;
          [ exact Hvalid | exact Hsat
          | apply seq_of_ls_value_ok; apply select_switch_value_ok; exact Hok ]
    end.
Qed.

(* ====================================================================== *)
(* THE SOUND eval_funcall VALUE ENGINE (retires reach_nonwriter_unchanged).*)
(*                                                                        *)
(* reach_nonwriter_unchanged (above) is FALSE for the real Mario genv,     *)
(* because "writes the action cell" is a TRANSITIVE property: a funcall of  *)
(* a non-set_mario_action function that CALLS set_mario_action does change   *)
(* the cell, so classifying WHOLE funcalls is unsound as a discharge path.   *)
(*                                                                          *)
(* The fix: the value-twin of FieldNonInterference.exec_funcall_reach_-      *)
(* unchanged_on. Carry (valid /\ action_sat Q) instead of unchanged_on, by   *)
(* the SAME mutual induction (exec_stmt_funcall_ind), so transitivity is     *)
(* handled by the Scall -> funcall IH. The per-function leaf is now about a   *)
(* function's OWN direct Sassigns (stmt_value_ok), never its transitive       *)
(* effects. The single writer (set_mario_action) is the one funcall whose     *)
(* body's direct Sassign stores its argument; it is isolated in a no-A-        *)
(* conditioned funcall hypothesis (reach_writer_preserves_noA). NoA is         *)
(* threaded only to gate that one writer: its sole structural needs are        *)
(* "NoA survives a statement" and "NoA survives function entry" (both TRUE --   *)
(* the frame writes no controller-input bytes; entry only allocs fresh blocks). *)
(* Output: reach_value_preserves_noA, with NO unsatisfiable premise.           *)
(* ====================================================================== *)
Theorem exec_funcall_reach_value_noA :
  forall (Q : int -> Prop) (bm : block) (ge : genv)
         (NoA : mem -> Prop) (writer : Clight.fundef -> Prop),
    (* leaf A (aliasing): every reached NON-writer body's direct Sassigns are
       value-ok (each avoids the action cell or stores a Q-value). No NoA. *)
    (forall f vargs m e le m1,
       function_entry2 ge f vargs m e le m1 ->
       ~ writer (Internal f) ->
       stmt_value_ok Q bm ge e (fn_body f)) ->
    (* leaf B (the crux): the one writer funcall, under NoA, preserves action_sat. *)
    reach_writer_preserves_noA Q bm ge writer NoA ->
    (* externals don't touch the action cell. *)
    reach_ext_preserves (action_cell bm) ge ->
    (* NoA survives any statement execution and any function entry. *)
    (forall e le m s t le' m' out,
       exec_stmt function_entry2 ge e le m s t le' m' out -> NoA m -> NoA m') ->
    (forall f vargs m e le m1,
       function_entry2 ge f vargs m e le m1 -> NoA m -> NoA m1) ->
    reach_value_preserves_noA Q bm ge NoA.
Proof.
  intros Q bm ge NoA writer Hnw Hw Hext Hnoaexec Hnoaentry.
  assert (MAIN :
    (forall e le m s t le' m' out,
       exec_stmt function_entry2 ge e le m s t le' m' out ->
       NoA m -> Mem.valid_block m bm -> action_sat Q m bm ->
       stmt_value_ok Q bm ge e s ->
       Mem.valid_block m' bm /\ action_sat Q m' bm)
    /\
    (forall m fd vargs t m' vres,
       eval_funcall function_entry2 ge m fd vargs t m' vres ->
       NoA m -> Mem.valid_block m bm -> action_sat Q m bm ->
       Mem.valid_block m' bm /\ action_sat Q m' bm)).
  { apply (exec_stmt_funcall_ind function_entry2 ge
      (fun e le m s t le' m' out =>
         NoA m -> Mem.valid_block m bm -> action_sat Q m bm ->
         stmt_value_ok Q bm ge e s ->
         Mem.valid_block m' bm /\ action_sat Q m' bm)
      (fun m fd vargs t m' vres =>
         NoA m -> Mem.valid_block m bm -> action_sat Q m bm ->
         Mem.valid_block m' bm /\ action_sat Q m' bm)).
    - (* Sskip *) intros e le m HnoA Hv Hsat _. split; [ exact Hv | exact Hsat ].
    - (* Sassign *)
      intros e le m a1 a2 loc ofs bf v2 v m' Hlv He Hcast Hassign HnoA Hv Hsat Hok.
      simpl in Hok. split;
      [ eapply assign_loc_valid_block; [ exact Hassign | exact Hv ]
      | eapply assign_loc_action_sat;
          [ exact Hassign | exact Hv | exact Hsat
          | exact (Hok _ _ _ _ _ _ _ Hlv He Hcast) ] ].
    - (* Sset *) intros e le m id a v He HnoA Hv Hsat _. split; [ exact Hv | exact Hsat ].
    - (* Scall: funcall IH *)
      intros e le m optid a al tyargs tyres cconv vf vargs f t m' vres
             Hcf He Hel Hff Htof Hfd IHfun HnoA Hv Hsat _.
      exact (IHfun HnoA Hv Hsat).
    - (* Sbuiltin: external preserves the cell + validity *)
      intros e le m optid ef al tyargs vargs t m' vres Hel Hec HnoA Hv Hsat _.
      split;
      [ eapply external_call_valid_block; [ exact Hec | exact Hv ]
      | eapply action_sat_unchanged_on; [ eapply Hext; exact Hec | exact Hv | exact Hsat ] ].
    - (* Sseq_1 *)
      intros e le m s1 s2 t1 le1 m1 t2 le2 m2 out He1 IH1 He2 IH2 HnoA Hv Hsat Hok.
      simpl in Hok. destruct Hok as [Hok1 Hok2].
      destruct (IH1 HnoA Hv Hsat Hok1) as [Hv1 Hsat1].
      apply (IH2 (Hnoaexec _ _ _ _ _ _ _ _ He1 HnoA) Hv1 Hsat1 Hok2).
    - (* Sseq_2 *)
      intros e le m s1 s2 t1 le1 m1 out He1 IH1 Hout HnoA Hv Hsat Hok.
      simpl in Hok. apply (IH1 HnoA Hv Hsat (proj1 Hok)).
    - (* Sifthenelse *)
      intros e le m a s1 s2 v1 b t le' m' out He Hbool Hexec IH HnoA Hv Hsat Hok.
      simpl in Hok. apply (IH HnoA Hv Hsat).
      destruct b; [ exact (proj1 Hok) | exact (proj2 Hok) ].
    - (* Sreturn_none *) intros e le m HnoA Hv Hsat _. split; [ exact Hv | exact Hsat ].
    - (* Sreturn_some *) intros e le m a v He HnoA Hv Hsat _. split; [ exact Hv | exact Hsat ].
    - (* Sbreak *) intros e le m HnoA Hv Hsat _. split; [ exact Hv | exact Hsat ].
    - (* Scontinue *) intros e le m HnoA Hv Hsat _. split; [ exact Hv | exact Hsat ].
    - (* Sloop_stop1 *)
      intros e le m s1 s2 t le' m' out' out He1 IH1 Hbor HnoA Hv Hsat Hok.
      simpl in Hok. apply (IH1 HnoA Hv Hsat (proj1 Hok)).
    - (* Sloop_stop2 *)
      intros e le m s1 s2 t1 le1 m1 out1 t2 le2 m2 out2 out
             He1 IH1 Hnoc He2 IH2 Hbor HnoA Hv Hsat Hok.
      simpl in Hok. destruct Hok as [Hok1 Hok2].
      destruct (IH1 HnoA Hv Hsat Hok1) as [Hv1 Hsat1].
      apply (IH2 (Hnoaexec _ _ _ _ _ _ _ _ He1 HnoA) Hv1 Hsat1 Hok2).
    - (* Sloop_loop *)
      intros e le m s1 s2 t1 le1 m1 out1 t2 le2 m2 t3 le3 m3 out
             He1 IH1 Hnoc He2 IH2 He3 IH3 HnoA Hv Hsat Hok.
      simpl in Hok. destruct Hok as [Hok1 Hok2].
      destruct (IH1 HnoA Hv Hsat Hok1) as [Hv1 Hsat1].
      pose proof (Hnoaexec _ _ _ _ _ _ _ _ He1 HnoA) as HnoA1.
      destruct (IH2 HnoA1 Hv1 Hsat1 Hok2) as [Hv2 Hsat2].
      pose proof (Hnoaexec _ _ _ _ _ _ _ _ He2 HnoA1) as HnoA2.
      apply (IH3 HnoA2 Hv2 Hsat2). simpl. split; [ exact Hok1 | exact Hok2 ].
    - (* Sswitch *)
      intros e le m a t v n sl le1 m1 out He Hsw Hexec IH HnoA Hv Hsat Hok.
      simpl in Hok. apply (IH HnoA Hv Hsat).
      apply seq_of_ls_value_ok. apply select_switch_value_ok. exact Hok.
    - (* eval_funcall_internal: writer-split *)
      intros m f vargs t e le1 le2 m1 m2 out vres m3
             Hentry Hbexec IHbody Hout Hfree HnoA Hv Hsat.
      destruct (classic (writer (Internal f))) as [Hwr | Hnwr].
      + (* writer: rebuild the funcall, apply the no-A writer hypothesis *)
        eapply Hw;
          [ exact HnoA
          | eapply eval_funcall_internal; [ exact Hentry | exact Hbexec | exact Hout | exact Hfree ]
          | exact Hwr | exact Hv | exact Hsat ].
      + (* non-writer: entry (unchanged) + body IH + free (fresh) *)
        assert (Uentry : Mem.unchanged_on (action_cell bm) m m1)
          by (eapply function_entry2_unchanged_on; eauto).
        assert (Hv1 : Mem.valid_block m1 bm)
          by (eapply Mem.valid_block_unchanged_on; [ exact Uentry | exact Hv ]).
        assert (Hsat1 : action_sat Q m1 bm)
          by (eapply action_sat_unchanged_on; [ exact Uentry | exact Hv | exact Hsat ]).
        assert (HnoA1 : NoA m1) by (eapply Hnoaentry; [ exact Hentry | exact HnoA ]).
        destruct (IHbody HnoA1 Hv1 Hsat1 (Hnw _ _ _ _ _ _ Hentry Hnwr)) as [Hv2 Hsat2].
        assert (Ufree : Mem.unchanged_on (action_cell bm) m2 m3).
        { eapply free_list_unchanged_on; [ exact Hfree | ].
          intros b lo hi i Hin Hac. destruct Hac as [Hb _]. subst b.
          exact (function_entry2_fresh _ _ _ _ _ _ _ Hentry bm lo hi Hin Hv). }
        split;
        [ eapply Mem.valid_block_unchanged_on; [ exact Ufree | exact Hv2 ]
        | eapply action_sat_unchanged_on; [ exact Ufree | exact Hv2 | exact Hsat2 ] ].
    - (* eval_funcall_external *)
      intros m ef targs tres cconv vargs t vres m' Hec HnoA Hv Hsat.
      split;
      [ eapply external_call_valid_block; [ exact Hec | exact Hv ]
      | eapply action_sat_unchanged_on; [ eapply Hext; exact Hec | exact Hv | exact Hsat ] ]. }
  intros m fd vargs t m' vres HnoA Hev Hv Hsat.
  exact (proj2 MAIN m fd vargs t m' vres Hev HnoA Hv Hsat).
Qed.

(* ====================================================================== *)
(* THE MARG-CARRYING VALUE ENGINE -- the type-forced successor of           *)
(* exec_funcall_reach_value_noA.                                            *)
(*                                                                        *)
(* Same 16-case mutual induction, but the funcall motive carries an arg-    *)
(* provenance precondition `marg_ok bm vargs`, and the statement motive     *)
(* carries a temp-invariant `TI : temp_env -> Prop` (the call-arg temps are *)
(* (bm,0)) + a per-body census `C : statement -> Prop`. The Scall case now   *)
(* SUPPLIES marg_ok to the callee from TI + the call-arg census (Hcallmarg) *)
(* -- so the per-non-writer-body leaf (Hbody) is the SATISFIABLE marg-gated  *)
(* census, NOT the forall-le phantom stmt_value_ok. The leaf facts (Hbody,  *)
(* Hassign, Hcallmarg, the HTI preservation facts) are the sharp            *)
(* EXECUTION-RELATIVE residuals                                             *)
(* that replace reach_value_body_nonwriter: each speaks about the actual     *)
(* entry temp env / actual call args, never an adversarial `forall le`.      *)
(* Output: reach_value_preserves_marg, the marg-gated reach property the     *)
(* body engine consumes (supplying marg_ok at execute_mario_action's call    *)
(* sites via its gMarioState-loaded arg temps).                             *)
(* ====================================================================== *)
Definition reach_value_preserves_marg
    (Q : int -> Prop) (bm : block) (ge : genv) (NoA : mem -> Prop) : Prop :=
  forall m fd vargs t m' vres,
    NoA m -> marg_ok bm vargs ->
    eval_funcall function_entry2 ge m fd vargs t m' vres ->
    Mem.valid_block m bm ->
    action_sat Q m bm ->
    Mem.valid_block m' bm /\ action_sat Q m' bm.

Theorem exec_funcall_reach_value_marg :
  forall (Q : int -> Prop) (bm : block) (ge : genv)
         (NoA : mem -> Prop) (writer : Clight.fundef -> Prop)
         (TI : temp_env -> Prop) (C : statement -> Prop),
    (* leaf A (marg-gated, execution-relative): every reached NON-writer body,
       entered with marg_ok args, gives entry-temp-invariant TI + census C. *)
    (forall f vargs m e le m1,
       function_entry2 ge f vargs m e le m1 ->
       ~ writer (Internal f) -> marg_ok bm vargs ->
       TI le /\ C (fn_body f)) ->
    (* the marg-gated store leaf: a direct Sassign under TI+census preserves
       validity + action_sat (it stores off the cell OR a Q-value). *)
    (forall e le m a1 a2 loc ofs bf v2 v m',
       eval_lvalue ge e le m a1 loc ofs bf ->
       eval_expr ge e le m a2 v2 ->
       sem_cast v2 (typeof a2) (typeof a1) m = Some v ->
       assign_loc ge (typeof a1) m loc ofs bf v m' ->
       TI le -> C (Sassign a1 a2) ->
       Mem.valid_block m bm -> action_sat Q m bm ->
       Mem.valid_block m' bm /\ action_sat Q m' bm) ->
    (* the call-arg census: under TI, a reached call's args are marg_ok. *)
    (forall e le m optid a al tyargs vargs,
       TI le -> C (Scall optid a al) ->
       eval_exprlist ge e le m al tyargs vargs -> marg_ok bm vargs) ->
    (* TI is preserved by a censused Sset and by a censused call/builtin result. *)
    (forall e le m id a v,
       eval_expr ge e le m a v -> TI le -> C (Sset id a) -> TI (PTree.set id v le)) ->
    (forall optid a al v le, C (Scall optid a al) -> TI le -> TI (set_opttemp optid v le)) ->
    (forall optid ef tyargs al v le,
       C (Sbuiltin optid ef tyargs al) -> TI le -> TI (set_opttemp optid v le)) ->
    (* leaf B (the crux): the one writer funcall, under NoA, preserves action_sat. *)
    reach_writer_preserves_noA Q bm ge writer NoA ->
    (* externals don't touch the action cell. *)
    reach_ext_preserves (action_cell bm) ge ->
    (* NoA survives any statement execution and any function entry. *)
    (forall e le m s t le' m' out,
       exec_stmt function_entry2 ge e le m s t le' m' out -> NoA m -> NoA m') ->
    (forall f vargs m e le m1,
       function_entry2 ge f vargs m e le m1 -> NoA m -> NoA m1) ->
    (* the census distributes over the compound forms. *)
    (forall s1 s2, C (Ssequence s1 s2) -> C s1 /\ C s2) ->
    (forall a s1 s2, C (Sifthenelse a s1 s2) -> C s1 /\ C s2) ->
    (forall s1 s2, C (Sloop s1 s2) -> C s1 /\ C s2) ->
    (forall a ls n, C (Sswitch a ls) -> C (seq_of_labeled_statement (select_switch n ls))) ->
    reach_value_preserves_marg Q bm ge NoA.
Proof.
  intros Q bm ge NoA writer TI C Hbody Hassign Hcallmarg HTI_set HTI_optc HTI_optb
         Hw Hext Hnoaexec Hnoaentry HCseq HCif HCloop HCsw.
  assert (MAIN :
    (forall e le m s t le' m' out,
       exec_stmt function_entry2 ge e le m s t le' m' out ->
       NoA m -> Mem.valid_block m bm -> action_sat Q m bm -> TI le -> C s ->
       Mem.valid_block m' bm /\ action_sat Q m' bm /\ TI le')
    /\
    (forall m fd vargs t m' vres,
       eval_funcall function_entry2 ge m fd vargs t m' vres ->
       NoA m -> Mem.valid_block m bm -> action_sat Q m bm -> marg_ok bm vargs ->
       Mem.valid_block m' bm /\ action_sat Q m' bm)).
  { apply (exec_stmt_funcall_ind function_entry2 ge
      (fun e le m s t le' m' out =>
         NoA m -> Mem.valid_block m bm -> action_sat Q m bm -> TI le -> C s ->
         Mem.valid_block m' bm /\ action_sat Q m' bm /\ TI le')
      (fun m fd vargs t m' vres =>
         NoA m -> Mem.valid_block m bm -> action_sat Q m bm -> marg_ok bm vargs ->
         Mem.valid_block m' bm /\ action_sat Q m' bm)).
    - (* Sskip *) intros e le m HnoA Hv Hsat HTI _. split; [ exact Hv | split; [ exact Hsat | exact HTI ] ].
    - (* Sassign *)
      intros e le m a1 a2 loc ofs bf v2 v m' Hlv He Hcast Hal HnoA Hv Hsat HTI HC.
      destruct (Hassign e le m a1 a2 loc ofs bf v2 v m' Hlv He Hcast Hal HTI HC Hv Hsat) as [Hv' Hsat'].
      split; [ exact Hv' | split; [ exact Hsat' | exact HTI ] ].
    - (* Sset *)
      intros e le m id a v He HnoA Hv Hsat HTI HC.
      split; [ exact Hv | split; [ exact Hsat | eapply HTI_set; [ exact He | exact HTI | exact HC ] ] ].
    - (* Scall: funcall IH, marg supplied from TI + call census *)
      intros e le m optid a al tyargs tyres cconv vf vargs f t m' vres
             Hcf He Hel Hff Htof Hfd IHfun HnoA Hv Hsat HTI HC.
      assert (Hmarg : marg_ok bm vargs) by (eapply Hcallmarg; [ exact HTI | exact HC | exact Hel ]).
      destruct (IHfun HnoA Hv Hsat Hmarg) as [Hv' Hsat'].
      split; [ exact Hv' | split; [ exact Hsat' | eapply HTI_optc; [ exact HC | exact HTI ] ] ].
    - (* Sbuiltin *)
      intros e le m optid ef al tyargs vargs t m' vres Hel Hec HnoA Hv Hsat HTI HC.
      split;
      [ eapply external_call_valid_block; [ exact Hec | exact Hv ]
      | split;
        [ eapply action_sat_unchanged_on; [ eapply Hext; exact Hec | exact Hv | exact Hsat ]
        | eapply HTI_optb; [ exact HC | exact HTI ] ] ].
    - (* Sseq_1 *)
      intros e le m s1 s2 t1 le1 m1 t2 le2 m2 out He1 IH1 He2 IH2 HnoA Hv Hsat HTI HC.
      destruct (HCseq _ _ HC) as [HC1 HC2].
      destruct (IH1 HnoA Hv Hsat HTI HC1) as [Hv1 [Hsat1 HTI1]].
      apply (IH2 (Hnoaexec _ _ _ _ _ _ _ _ He1 HnoA) Hv1 Hsat1 HTI1 HC2).
    - (* Sseq_2 *)
      intros e le m s1 s2 t1 le1 m1 out He1 IH1 Hout HnoA Hv Hsat HTI HC.
      destruct (HCseq _ _ HC) as [HC1 _]. apply (IH1 HnoA Hv Hsat HTI HC1).
    - (* Sifthenelse *)
      intros e le m a s1 s2 v1 b t le' m' out He Hbool Hexec IH HnoA Hv Hsat HTI HC.
      destruct (HCif _ _ _ HC) as [HC1 HC2]. apply (IH HnoA Hv Hsat HTI).
      destruct b; [ exact HC1 | exact HC2 ].
    - (* Sreturn_none *) intros e le m HnoA Hv Hsat HTI _. split; [ exact Hv | split; [ exact Hsat | exact HTI ] ].
    - (* Sreturn_some *) intros e le m a v He HnoA Hv Hsat HTI _. split; [ exact Hv | split; [ exact Hsat | exact HTI ] ].
    - (* Sbreak *) intros e le m HnoA Hv Hsat HTI _. split; [ exact Hv | split; [ exact Hsat | exact HTI ] ].
    - (* Scontinue *) intros e le m HnoA Hv Hsat HTI _. split; [ exact Hv | split; [ exact Hsat | exact HTI ] ].
    - (* Sloop_stop1 *)
      intros e le m s1 s2 t le' m' out' out He1 IH1 Hbor HnoA Hv Hsat HTI HC.
      destruct (HCloop _ _ HC) as [HC1 _]. apply (IH1 HnoA Hv Hsat HTI HC1).
    - (* Sloop_stop2 *)
      intros e le m s1 s2 t1 le1 m1 out1 t2 le2 m2 out2 out
             He1 IH1 Hnoc He2 IH2 Hbor HnoA Hv Hsat HTI HC.
      destruct (HCloop _ _ HC) as [HC1 HC2].
      destruct (IH1 HnoA Hv Hsat HTI HC1) as [Hv1 [Hsat1 HTI1]].
      apply (IH2 (Hnoaexec _ _ _ _ _ _ _ _ He1 HnoA) Hv1 Hsat1 HTI1 HC2).
    - (* Sloop_loop *)
      intros e le m s1 s2 t1 le1 m1 out1 t2 le2 m2 t3 le3 m3 out
             He1 IH1 Hnoc He2 IH2 He3 IH3 HnoA Hv Hsat HTI HC.
      destruct (HCloop _ _ HC) as [HC1 HC2].
      destruct (IH1 HnoA Hv Hsat HTI HC1) as [Hv1 [Hsat1 HTI1]].
      pose proof (Hnoaexec _ _ _ _ _ _ _ _ He1 HnoA) as HnoA1.
      destruct (IH2 HnoA1 Hv1 Hsat1 HTI1 HC2) as [Hv2 [Hsat2 HTI2]].
      pose proof (Hnoaexec _ _ _ _ _ _ _ _ He2 HnoA1) as HnoA2.
      apply (IH3 HnoA2 Hv2 Hsat2 HTI2 HC).
    - (* Sswitch *)
      intros e le m a t v n sl le1 m1 out He Hsa Hexec IH HnoA Hv Hsat HTI HC.
      apply (IH HnoA Hv Hsat HTI). exact (HCsw _ _ n HC).
    - (* eval_funcall_internal: writer-split *)
      intros m f vargs t e le1 le2 m1 m2 out vres m3
             Hentry Hbexec IHbody Hout Hfree HnoA Hv Hsat Hmarg.
      destruct (classic (writer (Internal f))) as [Hwr | Hnwr].
      + (* writer: rebuild the funcall, apply the no-A writer hypothesis *)
        eapply Hw;
          [ exact HnoA
          | eapply eval_funcall_internal; [ exact Hentry | exact Hbexec | exact Hout | exact Hfree ]
          | exact Hwr | exact Hv | exact Hsat ].
      + (* non-writer: entry (unchanged) + body IH + free (fresh) *)
        assert (Uentry : Mem.unchanged_on (action_cell bm) m m1)
          by (eapply function_entry2_unchanged_on; eauto).
        assert (Hv1 : Mem.valid_block m1 bm)
          by (eapply Mem.valid_block_unchanged_on; [ exact Uentry | exact Hv ]).
        assert (Hsat1 : action_sat Q m1 bm)
          by (eapply action_sat_unchanged_on; [ exact Uentry | exact Hv | exact Hsat ]).
        assert (HnoA1 : NoA m1) by (eapply Hnoaentry; [ exact Hentry | exact HnoA ]).
        destruct (Hbody f vargs m e le1 m1 Hentry Hnwr Hmarg) as [HTI1 HC1].
        destruct (IHbody HnoA1 Hv1 Hsat1 HTI1 HC1) as [Hv2 [Hsat2 _]].
        assert (Ufree : Mem.unchanged_on (action_cell bm) m2 m3).
        { eapply free_list_unchanged_on; [ exact Hfree | ].
          intros b lo hi i Hin Hac. destruct Hac as [Hb _]. subst b.
          exact (function_entry2_fresh _ _ _ _ _ _ _ Hentry bm lo hi Hin Hv). }
        split;
        [ eapply Mem.valid_block_unchanged_on; [ exact Ufree | exact Hv2 ]
        | eapply action_sat_unchanged_on; [ exact Ufree | exact Hv2 | exact Hsat2 ] ].
    - (* eval_funcall_external *)
      intros m ef targs tres cconv vargs t vres m' Hec HnoA Hv Hsat Hmarg.
      split;
      [ eapply external_call_valid_block; [ exact Hec | exact Hv ]
      | eapply action_sat_unchanged_on; [ eapply Hext; exact Hec | exact Hv | exact Hsat ] ]. }
  intros m fd vargs t m' vres HnoA Hmarg Hev Hv Hsat.
  exact (proj2 MAIN m fd vargs t m' vres Hev HnoA Hv Hsat Hmarg).
Qed.

(* ====================================================================== *)
(* THE MEMORY-WF-THREADED VALUE ENGINE -- the successor of the marg engine *)
(* that makes HTI_set SATISFIABLE for chase-pointer loads.                 *)
(*                                                                        *)
(* The marg engine threads only action_sat as its memory invariant, so the *)
(* leaf HTI_set (`Sset id a` preserves the temp invariant TI) is stated     *)
(* forall-m with no memory precondition -- and is therefore FALSE for the    *)
(* real reached bodies, whose chase temps are set by a LOAD `_t = _m->field` *)
(* (e.g. mario_reset_bodystate's `_bodyState = _m->marioBodyState`): knowing  *)
(* the loaded value is off-bm needs a Mario-memory-wellformedness fact about  *)
(* m. This engine carries that fact as a threaded invariant MWF : mem -> Prop *)
(* (the chase fields load off bm) ALONGSIDE action_sat, and HANDS IT to       *)
(* HTI_set -- so the temp-provenance leaf becomes provable: under MWF the      *)
(* chase load yields an off-bm pointer, re-establishing TI. MWF is preserved   *)
(* at stores (Hassign, off-bm), at the writer (Hw), at externals (Hmwf_ext),  *)
(* and across entry/free (Hmwf_unchanged, since both leave bm's cells alone). *)
(* Output: reach_value_preserves_wf, the marg+wf reach property.              *)
(* ====================================================================== *)
Definition reach_writer_preserves_wf
    (Q : int -> Prop) (bm : block) (ge : genv)
    (writer : Clight.fundef -> Prop) (NoA MWF : mem -> Prop) : Prop :=
  forall m fd vargs t m' vres,
    NoA m -> MWF m ->
    eval_funcall function_entry2 ge m fd vargs t m' vres ->
    writer fd ->
    Mem.valid_block m bm -> action_sat Q m bm ->
    Mem.valid_block m' bm /\ action_sat Q m' bm /\ MWF m'.

Definition reach_value_preserves_wf
    (Q : int -> Prop) (bm : block) (ge : genv) (NoA MWF : mem -> Prop) : Prop :=
  forall m fd vargs t m' vres,
    NoA m -> MWF m -> marg_ok bm vargs ->
    eval_funcall function_entry2 ge m fd vargs t m' vres ->
    Mem.valid_block m bm -> action_sat Q m bm ->
    Mem.valid_block m' bm /\ action_sat Q m' bm /\ MWF m'.

Theorem exec_funcall_reach_value_wf :
  forall (Q : int -> Prop) (bm : block) (ge : genv)
         (NoA MWF : mem -> Prop) (writer : Clight.fundef -> Prop)
         (TI : temp_env -> Prop) (C : statement -> Prop),
    (* leaf A (marg-gated): a reached non-writer entered with marg args has
       entry-temp-invariant TI and its body passes census C. *)
    (forall f vargs m e le m1,
       function_entry2 ge f vargs m e le m1 ->
       ~ writer (Internal f) -> marg_ok bm vargs ->
       TI le /\ C (fn_body f)) ->
    (* the store leaf: a direct Sassign under TI+C preserves validity, action_sat
       AND MWF (the store is off the action cell and off the chase fields). *)
    (forall e le m a1 a2 loc ofs bf v2 v m',
       eval_lvalue ge e le m a1 loc ofs bf ->
       eval_expr ge e le m a2 v2 ->
       sem_cast v2 (typeof a2) (typeof a1) m = Some v ->
       assign_loc ge (typeof a1) m loc ofs bf v m' ->
       TI le -> C (Sassign a1 a2) -> MWF m ->
       Mem.valid_block m bm -> action_sat Q m bm ->
       Mem.valid_block m' bm /\ action_sat Q m' bm /\ MWF m') ->
    (* the call-arg census: under TI, a reached call's args are marg_ok. *)
    (forall e le m optid a al tyargs vargs,
       TI le -> C (Scall optid a al) ->
       eval_exprlist ge e le m al tyargs vargs -> marg_ok bm vargs) ->
    (* TI is preserved by a censused Sset -- NOW WITH MWF: the chase load
       `_t = _m->field` yields an off-bm pointer by MWF, re-establishing TI. *)
    (forall e le m id a v,
       MWF m -> eval_expr ge e le m a v -> TI le -> C (Sset id a) ->
       TI (PTree.set id v le)) ->
    (forall optid a al v le, C (Scall optid a al) -> TI le -> TI (set_opttemp optid v le)) ->
    (forall optid ef tyargs al v le,
       C (Sbuiltin optid ef tyargs al) -> TI le -> TI (set_opttemp optid v le)) ->
    (* leaf B (the crux): the one writer funcall, under NoA, preserves action_sat
       AND MWF (set_mario_action writes the action cell, not the chase fields). *)
    reach_writer_preserves_wf Q bm ge writer NoA MWF ->
    (* externals don't touch the action cell, and preserve MWF. *)
    reach_ext_preserves (action_cell bm) ge ->
    (forall ef vargs m t vres m',
       external_call ef ge vargs m t vres m' ->
       Mem.valid_block m bm -> MWF m -> MWF m') ->
    (* MWF survives any operation that leaves bm's cells unchanged (entry+free). *)
    (forall m m', Mem.unchanged_on (fun b _ => b = bm) m m' ->
                  Mem.valid_block m bm -> MWF m -> MWF m') ->
    (* NoA survives any statement execution and any function entry. *)
    (forall e le m s t le' m' out,
       exec_stmt function_entry2 ge e le m s t le' m' out -> NoA m -> NoA m') ->
    (forall f vargs m e le m1,
       function_entry2 ge f vargs m e le m1 -> NoA m -> NoA m1) ->
    (* the census distributes over the compound forms. *)
    (forall s1 s2, C (Ssequence s1 s2) -> C s1 /\ C s2) ->
    (forall a s1 s2, C (Sifthenelse a s1 s2) -> C s1 /\ C s2) ->
    (forall s1 s2, C (Sloop s1 s2) -> C s1 /\ C s2) ->
    (forall a ls n, C (Sswitch a ls) -> C (seq_of_labeled_statement (select_switch n ls))) ->
    reach_value_preserves_wf Q bm ge NoA MWF.
Proof.
  intros Q bm ge NoA MWF writer TI C Hbody Hassign Hcallmarg HTI_set HTI_optc HTI_optb
         Hw Hext Hmwf_ext Hmwf_unch Hnoaexec Hnoaentry HCseq HCif HCloop HCsw.
  assert (MAIN :
    (forall e le m s t le' m' out,
       exec_stmt function_entry2 ge e le m s t le' m' out ->
       NoA m -> MWF m -> Mem.valid_block m bm -> action_sat Q m bm -> TI le -> C s ->
       Mem.valid_block m' bm /\ action_sat Q m' bm /\ MWF m' /\ TI le')
    /\
    (forall m fd vargs t m' vres,
       eval_funcall function_entry2 ge m fd vargs t m' vres ->
       NoA m -> MWF m -> Mem.valid_block m bm -> action_sat Q m bm -> marg_ok bm vargs ->
       Mem.valid_block m' bm /\ action_sat Q m' bm /\ MWF m')).
  { apply (exec_stmt_funcall_ind function_entry2 ge
      (fun e le m s t le' m' out =>
         NoA m -> MWF m -> Mem.valid_block m bm -> action_sat Q m bm -> TI le -> C s ->
         Mem.valid_block m' bm /\ action_sat Q m' bm /\ MWF m' /\ TI le')
      (fun m fd vargs t m' vres =>
         NoA m -> MWF m -> Mem.valid_block m bm -> action_sat Q m bm -> marg_ok bm vargs ->
         Mem.valid_block m' bm /\ action_sat Q m' bm /\ MWF m')).
    - (* Sskip *) intros e le m HnoA HMWF Hv Hsat HTI _.
      split; [ exact Hv | split; [ exact Hsat | split; [ exact HMWF | exact HTI ] ] ].
    - (* Sassign *)
      intros e le m a1 a2 loc ofs bf v2 v m' Hlv He Hcast Hal HnoA HMWF Hv Hsat HTI HC.
      destruct (Hassign e le m a1 a2 loc ofs bf v2 v m' Hlv He Hcast Hal HTI HC HMWF Hv Hsat)
        as (Hv' & Hsat' & HMWF').
      split; [ exact Hv' | split; [ exact Hsat' | split; [ exact HMWF' | exact HTI ] ] ].
    - (* Sset *)
      intros e le m id a v He HnoA HMWF Hv Hsat HTI HC.
      split; [ exact Hv | split; [ exact Hsat | split; [ exact HMWF |
        eapply HTI_set; [ exact HMWF | exact He | exact HTI | exact HC ] ] ] ].
    - (* Scall: funcall IH, marg supplied from TI + call census *)
      intros e le m optid a al tyargs tyres cconv vf vargs f t m' vres
             Hcf He Hel Hff Htof Hfd IHfun HnoA HMWF Hv Hsat HTI HC.
      assert (Hmarg : marg_ok bm vargs) by (eapply Hcallmarg; [ exact HTI | exact HC | exact Hel ]).
      destruct (IHfun HnoA HMWF Hv Hsat Hmarg) as (Hv' & Hsat' & HMWF').
      split; [ exact Hv' | split; [ exact Hsat' | split; [ exact HMWF' |
        eapply HTI_optc; [ exact HC | exact HTI ] ] ] ].
    - (* Sbuiltin *)
      intros e le m optid ef al tyargs vargs t m' vres Hel Hec HnoA HMWF Hv Hsat HTI HC.
      split;
      [ eapply external_call_valid_block; [ exact Hec | exact Hv ]
      | split;
        [ eapply action_sat_unchanged_on; [ eapply Hext; exact Hec | exact Hv | exact Hsat ]
        | split;
          [ eapply Hmwf_ext; [ exact Hec | exact Hv | exact HMWF ]
          | eapply HTI_optb; [ exact HC | exact HTI ] ] ] ].
    - (* Sseq_1 *)
      intros e le m s1 s2 t1 le1 m1 t2 le2 m2 out He1 IH1 He2 IH2 HnoA HMWF Hv Hsat HTI HC.
      destruct (HCseq _ _ HC) as [HC1 HC2].
      destruct (IH1 HnoA HMWF Hv Hsat HTI HC1) as (Hv1 & Hsat1 & HMWF1 & HTI1).
      apply (IH2 (Hnoaexec _ _ _ _ _ _ _ _ He1 HnoA) HMWF1 Hv1 Hsat1 HTI1 HC2).
    - (* Sseq_2 *)
      intros e le m s1 s2 t1 le1 m1 out He1 IH1 Hout HnoA HMWF Hv Hsat HTI HC.
      destruct (HCseq _ _ HC) as [HC1 _]. apply (IH1 HnoA HMWF Hv Hsat HTI HC1).
    - (* Sifthenelse *)
      intros e le m a s1 s2 v1 b t le' m' out He Hbool Hexec IH HnoA HMWF Hv Hsat HTI HC.
      destruct (HCif _ _ _ HC) as [HC1 HC2]. apply (IH HnoA HMWF Hv Hsat HTI).
      destruct b; [ exact HC1 | exact HC2 ].
    - (* Sreturn_none *) intros e le m HnoA HMWF Hv Hsat HTI _.
      split; [ exact Hv | split; [ exact Hsat | split; [ exact HMWF | exact HTI ] ] ].
    - (* Sreturn_some *) intros e le m a v He HnoA HMWF Hv Hsat HTI _.
      split; [ exact Hv | split; [ exact Hsat | split; [ exact HMWF | exact HTI ] ] ].
    - (* Sbreak *) intros e le m HnoA HMWF Hv Hsat HTI _.
      split; [ exact Hv | split; [ exact Hsat | split; [ exact HMWF | exact HTI ] ] ].
    - (* Scontinue *) intros e le m HnoA HMWF Hv Hsat HTI _.
      split; [ exact Hv | split; [ exact Hsat | split; [ exact HMWF | exact HTI ] ] ].
    - (* Sloop_stop1 *)
      intros e le m s1 s2 t le' m' out' out He1 IH1 Hbor HnoA HMWF Hv Hsat HTI HC.
      destruct (HCloop _ _ HC) as [HC1 _]. apply (IH1 HnoA HMWF Hv Hsat HTI HC1).
    - (* Sloop_stop2 *)
      intros e le m s1 s2 t1 le1 m1 out1 t2 le2 m2 out2 out
             He1 IH1 Hnoc He2 IH2 Hbor HnoA HMWF Hv Hsat HTI HC.
      destruct (HCloop _ _ HC) as [HC1 HC2].
      destruct (IH1 HnoA HMWF Hv Hsat HTI HC1) as (Hv1 & Hsat1 & HMWF1 & HTI1).
      apply (IH2 (Hnoaexec _ _ _ _ _ _ _ _ He1 HnoA) HMWF1 Hv1 Hsat1 HTI1 HC2).
    - (* Sloop_loop *)
      intros e le m s1 s2 t1 le1 m1 out1 t2 le2 m2 t3 le3 m3 out
             He1 IH1 Hnoc He2 IH2 He3 IH3 HnoA HMWF Hv Hsat HTI HC.
      destruct (HCloop _ _ HC) as [HC1 HC2].
      destruct (IH1 HnoA HMWF Hv Hsat HTI HC1) as (Hv1 & Hsat1 & HMWF1 & HTI1).
      pose proof (Hnoaexec _ _ _ _ _ _ _ _ He1 HnoA) as HnoA1.
      destruct (IH2 HnoA1 HMWF1 Hv1 Hsat1 HTI1 HC2) as (Hv2 & Hsat2 & HMWF2 & HTI2).
      pose proof (Hnoaexec _ _ _ _ _ _ _ _ He2 HnoA1) as HnoA2.
      apply (IH3 HnoA2 HMWF2 Hv2 Hsat2 HTI2 HC).
    - (* Sswitch *)
      intros e le m a t v n sl le1 m1 out He Hsa Hexec IH HnoA HMWF Hv Hsat HTI HC.
      apply (IH HnoA HMWF Hv Hsat HTI). exact (HCsw _ _ n HC).
    - (* eval_funcall_internal: writer-split *)
      intros m f vargs t e le1 le2 m1 m2 out vres m3
             Hentry Hbexec IHbody Hout Hfree HnoA HMWF Hv Hsat Hmarg.
      destruct (classic (writer (Internal f))) as [Hwr | Hnwr].
      + (* writer: rebuild the funcall, apply the no-A+wf writer hypothesis *)
        eapply Hw;
          [ exact HnoA | exact HMWF
          | eapply eval_funcall_internal; [ exact Hentry | exact Hbexec | exact Hout | exact Hfree ]
          | exact Hwr | exact Hv | exact Hsat ].
      + (* non-writer: entry (unchanged) + body IH + free (fresh) *)
        assert (Uentry_ac : Mem.unchanged_on (action_cell bm) m m1)
          by (eapply function_entry2_unchanged_on; eauto).
        assert (Uentry_bm : Mem.unchanged_on (fun b _ => b = bm) m m1)
          by (eapply function_entry2_unchanged_on; eauto).
        assert (Hv1 : Mem.valid_block m1 bm)
          by (eapply Mem.valid_block_unchanged_on; [ exact Uentry_ac | exact Hv ]).
        assert (Hsat1 : action_sat Q m1 bm)
          by (eapply action_sat_unchanged_on; [ exact Uentry_ac | exact Hv | exact Hsat ]).
        assert (HMWF1 : MWF m1)
          by (eapply Hmwf_unch; [ exact Uentry_bm | exact Hv | exact HMWF ]).
        assert (HnoA1 : NoA m1) by (eapply Hnoaentry; [ exact Hentry | exact HnoA ]).
        destruct (Hbody f vargs m e le1 m1 Hentry Hnwr Hmarg) as [HTI1 HC1].
        destruct (IHbody HnoA1 HMWF1 Hv1 Hsat1 HTI1 HC1) as (Hv2 & Hsat2 & HMWF2 & _).
        assert (Ufree_ac : Mem.unchanged_on (action_cell bm) m2 m3).
        { eapply free_list_unchanged_on; [ exact Hfree | ].
          intros b lo hi i Hin Hac. destruct Hac as [Hb _]. subst b.
          exact (function_entry2_fresh _ _ _ _ _ _ _ Hentry bm lo hi Hin Hv). }
        assert (Ufree_bm : Mem.unchanged_on (fun b _ => b = bm) m2 m3).
        { eapply free_list_unchanged_on; [ exact Hfree | ].
          intros b lo hi i Hin Hb. subst b.
          exact (function_entry2_fresh _ _ _ _ _ _ _ Hentry bm lo hi Hin Hv). }
        split;
        [ eapply Mem.valid_block_unchanged_on; [ exact Ufree_ac | exact Hv2 ]
        | split;
          [ eapply action_sat_unchanged_on; [ exact Ufree_ac | exact Hv2 | exact Hsat2 ]
          | eapply Hmwf_unch; [ exact Ufree_bm | exact Hv2 | exact HMWF2 ] ] ].
    - (* eval_funcall_external *)
      intros m ef targs tres cconv vargs t vres m' Hec HnoA HMWF Hv Hsat Hmarg.
      split;
      [ eapply external_call_valid_block; [ exact Hec | exact Hv ]
      | split;
        [ eapply action_sat_unchanged_on; [ eapply Hext; exact Hec | exact Hv | exact Hsat ]
        | eapply Hmwf_ext; [ exact Hec | exact Hv | exact HMWF ] ] ]. }
  intros m fd vargs t m' vres HnoA HMWF Hmarg Hev Hv Hsat.
  exact (proj2 MAIN m fd vargs t m' vres Hev HnoA HMWF Hv Hsat Hmarg).
Qed.

(* ====================================================================== *)
(* REACHABILITY-ROOTED value engine.                                      *)
(*                                                                        *)
(* Same marg+wf 16-case induction, but the funcall motive now carries a   *)
(* `Reached_fd fd` premise. This escapes the `forall f` phantom in the    *)
(* body leaf: the body leaf only fires for fd ACTUALLY reached, so it is   *)
(* discharged by ENUMERATING the finite reached set (case-split + vm_      *)
(* compute the census) rather than asserting a per-function census for     *)
(* every conceivable f. The writer leaf is likewise Reached-gated, so when *)
(* the sole action-writer is statically unreachable (machine-checked over  *)
(* mario.prog) it is discharged BY VACUITY. The bridge from the statement  *)
(* level (TI/C) to the funcall-level Reached requirement is the single new *)
(* hypothesis `Hcall_reached`: under TI+C a reached call's resolved callee *)
(* is itself Reached -- the semantic image of the decidable callgraph      *)
(* closure (CallgraphReach.reaches), discharged per-call-site downstream.  *)
(* ====================================================================== *)
(* A callee is "marg-exempt" when marg_ok (arg0 aligned-into-bm) is NOT the right
   precondition for analysing it: externals (handled by the ext residual, never
   recursed into), and internal callees whose FIRST parameter is not a MarioState
   pointer (e.g. vec3f_find_ceil, whose _pos/_ceil legitimately receive INTERIOR
   bm-pointers -- TI/marg_ok cannot express those). Exempt internal callees are
   discharged by a focused direct-preservation leaf instead of the marg->TI->body
   path. Keying on the param TYPE (not fundef identity) keeps it decidable. *)
Definition marg_exempt (fd : Clight.fundef) : bool :=
  match fd with
  | Ctypes.External _ _ _ _ => true
  | Ctypes.Internal f =>
      match fn_params f with
      | (_, Tpointer (Tstruct sid _) _) :: _ => negb (Pos.eqb sid mario._MarioState)
      | _ => true
      end
  end.

Definition reach_value_preserves_reached
    (Q : int -> Prop) (bm : block) (ge : genv) (NoA MWF : mem -> Prop)
    (Reached_fd : Clight.fundef -> Prop) : Prop :=
  forall m fd vargs t m' vres,
    Reached_fd fd -> NoA m -> MWF m -> (marg_exempt fd = false -> marg_ok bm vargs) ->
    eval_funcall function_entry2 ge m fd vargs t m' vres ->
    Mem.valid_block m bm -> action_sat Q m bm ->
    Mem.valid_block m' bm /\ action_sat Q m' bm /\ MWF m'.

Theorem exec_funcall_reach_value_reached :
  forall (Q : int -> Prop) (bm : block) (ge : genv)
         (NoA MWF : mem -> Prop) (writer : Clight.fundef -> Prop)
         (Reached_fd : Clight.fundef -> Prop)
         (TI : temp_env -> Prop) (C : statement -> Prop),
    (* leaf A (reached + marg-gated): a REACHED non-writer entered with marg args
       has entry-temp-invariant TI and its body passes census C. Now ENUMERABLE
       (Reached_fd is finite), not a `forall f` phantom. *)
    (forall f vargs m e le m1,
       Reached_fd (Internal f) -> marg_exempt (Internal f) = false ->
       function_entry2 ge f vargs m e le m1 ->
       ~ writer (Internal f) -> marg_ok bm vargs ->
       TI le /\ C (fn_body f)) ->
    (* the store leaf (unchanged from the wf engine). *)
    (forall e le m a1 a2 loc ofs bf v2 v m',
       eval_lvalue ge e le m a1 loc ofs bf ->
       eval_expr ge e le m a2 v2 ->
       sem_cast v2 (typeof a2) (typeof a1) m = Some v ->
       assign_loc ge (typeof a1) m loc ofs bf v m' ->
       TI le -> C (Sassign a1 a2) -> MWF m ->
       Mem.valid_block m bm -> action_sat Q m bm ->
       Mem.valid_block m' bm /\ action_sat Q m' bm /\ MWF m') ->
    (* the call-arg census, now NON-EXEMPT-gated: a reached call into a
       NON-marg-exempt callee (first param a MarioState pointer) has marg_ok args.
       Exempt callees (externals, vec3f) don't need it -- and indeed don't satisfy
       it (they receive interior bm-pointers). *)
    (forall e le m optid a al tyargs vargs vf fd,
       TI le -> C (Scall optid a al) ->
       eval_expr ge e le m a vf -> Genv.find_funct ge vf = Some fd ->
       marg_exempt fd = false ->
       eval_exprlist ge e le m al tyargs vargs -> marg_ok bm vargs) ->
    (* leaf A-exempt: a reached marg-EXEMPT internal callee (vec3f_find_ceil --
       interior-pointer params) preserves validity, action_sat and MWF directly,
       without the marg_ok/TI path. TRUE (vec3f writes only its ceil output at a
       non-action offset and reads pos); discharged later by typed body analysis. *)
    (forall f vargs m t m' vres,
       Reached_fd (Internal f) -> marg_exempt (Internal f) = true ->
       eval_funcall function_entry2 ge m (Internal f) vargs t m' vres ->
       NoA m -> MWF m -> Mem.valid_block m bm -> action_sat Q m bm ->
       Mem.valid_block m' bm /\ action_sat Q m' bm /\ MWF m') ->
    (* TI preserved by a censused Sset, MWF-gated (unchanged). *)
    (forall e le m id a v,
       MWF m -> eval_expr ge e le m a v -> TI le -> C (Sset id a) ->
       TI (PTree.set id v le)) ->
    (* TI preserved when a call/builtin RESULT is stored into optid. NO LONGER a
       `forall v` phantom: the result v is constrained to be a non-bm pointer (or
       non-pointer) -- exactly what the engine threads from the actual callee's
       return value at the Scall/Sbuiltin cases (Hret_call / Hret_builtin below).
       This is what lets a pointer-tracking TI survive set_opttemp: the only way a
       call result could break "no temp points into bm" is by returning a bm ptr,
       which the reached callees never do. *)
    (forall optid a al v le,
       C (Scall optid a al) -> TI le ->
       (forall b o, v = Vptr b o -> b <> bm) -> TI (set_opttemp optid v le)) ->
    (forall optid ef tyargs al v le,
       C (Sbuiltin optid ef tyargs al) -> TI le ->
       (forall b o, v = Vptr b o -> b <> bm) -> TI (set_opttemp optid v le)) ->
    (* the RETURN-PROVENANCE bridges that supply the above. A reached funcall's
       result is never a pointer into bm (the reached callees return scalars /
       off-bm values, never Mario's block); an external/builtin result likewise.
       These replace the discarded `forall v` quantifier with the real fact about
       the actual return value -- precise + per-callee dischargeable. *)
    (forall fd m0 vargs0 t0 m0' vres0,
       Reached_fd fd ->
       eval_funcall function_entry2 ge m0 fd vargs0 t0 m0' vres0 ->
       forall b o, vres0 = Vptr b o -> b <> bm) ->
    (forall ef vargs0 m0 t0 vres0 m0',
       external_call ef ge vargs0 m0 t0 vres0 m0' ->
       forall b o, vres0 = Vptr b o -> b <> bm) ->
    (* NEW: the call-target-reached bridge. Under TI+C a reached call resolves to
       a Reached callee -- the semantic shadow of the decidable callgraph closure. *)
    (forall e le m optid a al vf fd,
       TI le -> C (Scall optid a al) ->
       eval_expr ge e le m a vf -> Genv.find_funct ge vf = Some fd ->
       Reached_fd fd) ->
    (* leaf B (the writer), Reached-gated: dischargeable by vacuity when the sole
       action-writer is statically unreachable. *)
    (forall m fd vargs t m' vres,
       Reached_fd fd -> NoA m -> MWF m ->
       eval_funcall function_entry2 ge m fd vargs t m' vres ->
       writer fd ->
       Mem.valid_block m bm -> action_sat Q m bm ->
       Mem.valid_block m' bm /\ action_sat Q m' bm /\ MWF m') ->
    (* externals don't touch the action cell, and preserve MWF (unchanged). *)
    reach_ext_preserves (action_cell bm) ge ->
    (forall ef vargs m t vres m',
       external_call ef ge vargs m t vres m' ->
       Mem.valid_block m bm -> MWF m -> MWF m') ->
    (forall m m', Mem.unchanged_on (fun b _ => b = bm) m m' ->
                  Mem.valid_block m bm -> MWF m -> MWF m') ->
    (forall e le m s t le' m' out,
       exec_stmt function_entry2 ge e le m s t le' m' out -> NoA m -> NoA m') ->
    (forall f vargs m e le m1,
       function_entry2 ge f vargs m e le m1 -> NoA m -> NoA m1) ->
    (forall s1 s2, C (Ssequence s1 s2) -> C s1 /\ C s2) ->
    (forall a s1 s2, C (Sifthenelse a s1 s2) -> C s1 /\ C s2) ->
    (forall s1 s2, C (Sloop s1 s2) -> C s1 /\ C s2) ->
    (forall a ls n, C (Sswitch a ls) -> C (seq_of_labeled_statement (select_switch n ls))) ->
    reach_value_preserves_reached Q bm ge NoA MWF Reached_fd.
Proof.
  intros Q bm ge NoA MWF writer Reached_fd TI C Hbody Hassign Hcallmarg Hexempt HTI_set HTI_optc HTI_optb
         Hret_call Hret_builtin
         Hcall_reached Hw Hext Hmwf_ext Hmwf_unch Hnoaexec Hnoaentry HCseq HCif HCloop HCsw.
  assert (MAIN :
    (forall e le m s t le' m' out,
       exec_stmt function_entry2 ge e le m s t le' m' out ->
       NoA m -> MWF m -> Mem.valid_block m bm -> action_sat Q m bm -> TI le -> C s ->
       Mem.valid_block m' bm /\ action_sat Q m' bm /\ MWF m' /\ TI le')
    /\
    (forall m fd vargs t m' vres,
       eval_funcall function_entry2 ge m fd vargs t m' vres ->
       Reached_fd fd ->
       NoA m -> MWF m -> Mem.valid_block m bm -> action_sat Q m bm ->
       (marg_exempt fd = false -> marg_ok bm vargs) ->
       Mem.valid_block m' bm /\ action_sat Q m' bm /\ MWF m')).
  { apply (exec_stmt_funcall_ind function_entry2 ge
      (fun e le m s t le' m' out =>
         NoA m -> MWF m -> Mem.valid_block m bm -> action_sat Q m bm -> TI le -> C s ->
         Mem.valid_block m' bm /\ action_sat Q m' bm /\ MWF m' /\ TI le')
      (fun m fd vargs t m' vres =>
         Reached_fd fd ->
         NoA m -> MWF m -> Mem.valid_block m bm -> action_sat Q m bm ->
         (marg_exempt fd = false -> marg_ok bm vargs) ->
         Mem.valid_block m' bm /\ action_sat Q m' bm /\ MWF m')).
    - (* Sskip *) intros e le m HnoA HMWF Hv Hsat HTI _.
      split; [ exact Hv | split; [ exact Hsat | split; [ exact HMWF | exact HTI ] ] ].
    - (* Sassign *)
      intros e le m a1 a2 loc ofs bf v2 v m' Hlv He Hcast Hal HnoA HMWF Hv Hsat HTI HC.
      destruct (Hassign e le m a1 a2 loc ofs bf v2 v m' Hlv He Hcast Hal HTI HC HMWF Hv Hsat)
        as (Hv' & Hsat' & HMWF').
      split; [ exact Hv' | split; [ exact Hsat' | split; [ exact HMWF' | exact HTI ] ] ].
    - (* Sset *)
      intros e le m id a v He HnoA HMWF Hv Hsat HTI HC.
      split; [ exact Hv | split; [ exact Hsat | split; [ exact HMWF |
        eapply HTI_set; [ exact HMWF | exact He | exact HTI | exact HC ] ] ] ].
    - (* Scall: derive Reached_fd of the callee from TI+C, then funcall IH *)
      intros e le m optid a al tyargs tyres cconv vf vargs f t m' vres
             Hcf He Hel Hff Htof Hfd IHfun HnoA HMWF Hv Hsat HTI HC.
      assert (Hmarg : marg_exempt f = false -> marg_ok bm vargs)
        by (intro Hne; eapply Hcallmarg;
            [ exact HTI | exact HC | exact He | exact Hff | exact Hne | exact Hel ]).
      assert (Hreached : Reached_fd f) by (eapply Hcall_reached; [ exact HTI | exact HC | exact He | exact Hff ]).
      destruct (IHfun Hreached HnoA HMWF Hv Hsat Hmarg) as (Hv' & Hsat' & HMWF').
      split; [ exact Hv' | split; [ exact Hsat' | split; [ exact HMWF' |
        eapply HTI_optc;
          [ exact HC | exact HTI
          | exact (Hret_call f m vargs t m' vres Hreached Hfd) ] ] ] ].
    - (* Sbuiltin *)
      intros e le m optid ef al tyargs vargs t m' vres Hel Hec HnoA HMWF Hv Hsat HTI HC.
      split;
      [ eapply external_call_valid_block; [ exact Hec | exact Hv ]
      | split;
        [ eapply action_sat_unchanged_on; [ eapply Hext; exact Hec | exact Hv | exact Hsat ]
        | split;
          [ eapply Hmwf_ext; [ exact Hec | exact Hv | exact HMWF ]
          | eapply HTI_optb;
              [ exact HC | exact HTI
              | exact (Hret_builtin ef vargs m t vres m' Hec) ] ] ] ].
    - (* Sseq_1 *)
      intros e le m s1 s2 t1 le1 m1 t2 le2 m2 out He1 IH1 He2 IH2 HnoA HMWF Hv Hsat HTI HC.
      destruct (HCseq _ _ HC) as [HC1 HC2].
      destruct (IH1 HnoA HMWF Hv Hsat HTI HC1) as (Hv1 & Hsat1 & HMWF1 & HTI1).
      apply (IH2 (Hnoaexec _ _ _ _ _ _ _ _ He1 HnoA) HMWF1 Hv1 Hsat1 HTI1 HC2).
    - (* Sseq_2 *)
      intros e le m s1 s2 t1 le1 m1 out He1 IH1 Hout HnoA HMWF Hv Hsat HTI HC.
      destruct (HCseq _ _ HC) as [HC1 _]. apply (IH1 HnoA HMWF Hv Hsat HTI HC1).
    - (* Sifthenelse *)
      intros e le m a s1 s2 v1 b t le' m' out He Hbool Hexec IH HnoA HMWF Hv Hsat HTI HC.
      destruct (HCif _ _ _ HC) as [HC1 HC2]. apply (IH HnoA HMWF Hv Hsat HTI).
      destruct b; [ exact HC1 | exact HC2 ].
    - (* Sreturn_none *) intros e le m HnoA HMWF Hv Hsat HTI _.
      split; [ exact Hv | split; [ exact Hsat | split; [ exact HMWF | exact HTI ] ] ].
    - (* Sreturn_some *) intros e le m a v He HnoA HMWF Hv Hsat HTI _.
      split; [ exact Hv | split; [ exact Hsat | split; [ exact HMWF | exact HTI ] ] ].
    - (* Sbreak *) intros e le m HnoA HMWF Hv Hsat HTI _.
      split; [ exact Hv | split; [ exact Hsat | split; [ exact HMWF | exact HTI ] ] ].
    - (* Scontinue *) intros e le m HnoA HMWF Hv Hsat HTI _.
      split; [ exact Hv | split; [ exact Hsat | split; [ exact HMWF | exact HTI ] ] ].
    - (* Sloop_stop1 *)
      intros e le m s1 s2 t le' m' out' out He1 IH1 Hbor HnoA HMWF Hv Hsat HTI HC.
      destruct (HCloop _ _ HC) as [HC1 _]. apply (IH1 HnoA HMWF Hv Hsat HTI HC1).
    - (* Sloop_stop2 *)
      intros e le m s1 s2 t1 le1 m1 out1 t2 le2 m2 out2 out
             He1 IH1 Hnoc He2 IH2 Hbor HnoA HMWF Hv Hsat HTI HC.
      destruct (HCloop _ _ HC) as [HC1 HC2].
      destruct (IH1 HnoA HMWF Hv Hsat HTI HC1) as (Hv1 & Hsat1 & HMWF1 & HTI1).
      apply (IH2 (Hnoaexec _ _ _ _ _ _ _ _ He1 HnoA) HMWF1 Hv1 Hsat1 HTI1 HC2).
    - (* Sloop_loop *)
      intros e le m s1 s2 t1 le1 m1 out1 t2 le2 m2 t3 le3 m3 out
             He1 IH1 Hnoc He2 IH2 He3 IH3 HnoA HMWF Hv Hsat HTI HC.
      destruct (HCloop _ _ HC) as [HC1 HC2].
      destruct (IH1 HnoA HMWF Hv Hsat HTI HC1) as (Hv1 & Hsat1 & HMWF1 & HTI1).
      pose proof (Hnoaexec _ _ _ _ _ _ _ _ He1 HnoA) as HnoA1.
      destruct (IH2 HnoA1 HMWF1 Hv1 Hsat1 HTI1 HC2) as (Hv2 & Hsat2 & HMWF2 & HTI2).
      pose proof (Hnoaexec _ _ _ _ _ _ _ _ He2 HnoA1) as HnoA2.
      apply (IH3 HnoA2 HMWF2 Hv2 Hsat2 HTI2 HC).
    - (* Sswitch *)
      intros e le m a t v n sl le1 m1 out He Hsa Hexec IH HnoA HMWF Hv Hsat HTI HC.
      apply (IH HnoA HMWF Hv Hsat HTI). exact (HCsw _ _ n HC).
    - (* eval_funcall_internal: writer-split, now Reached-gated *)
      intros m f vargs t e le1 le2 m1 m2 out vres m3
             Hentry Hbexec IHbody Hout Hfree Hreached HnoA HMWF Hv Hsat Hmarg.
      destruct (classic (writer (Internal f))) as [Hwr | Hnwr].
      + (* writer: rebuild the funcall, apply the Reached+no-A+wf writer hypothesis *)
        eapply Hw;
          [ exact Hreached | exact HnoA | exact HMWF
          | eapply eval_funcall_internal; [ exact Hentry | exact Hbexec | exact Hout | exact Hfree ]
          | exact Hwr | exact Hv | exact Hsat ].
      + (* non-writer: split on marg-exemption of the callee *)
        destruct (marg_exempt (Internal f)) eqn:Hexm.
        * (* marg-exempt internal callee (vec3f): focused direct preservation *)
          eapply Hexempt;
            [ exact Hreached | exact Hexm
            | eapply eval_funcall_internal; [ exact Hentry | exact Hbexec | exact Hout | exact Hfree ]
            | exact HnoA | exact HMWF | exact Hv | exact Hsat ].
        * (* non-exempt: marg_ok available -> leaf A + body IH + free *)
        assert (Hmarg' : marg_ok bm vargs) by (apply Hmarg; reflexivity).
        assert (Uentry_ac : Mem.unchanged_on (action_cell bm) m m1)
          by (eapply function_entry2_unchanged_on; eauto).
        assert (Uentry_bm : Mem.unchanged_on (fun b _ => b = bm) m m1)
          by (eapply function_entry2_unchanged_on; eauto).
        assert (Hv1 : Mem.valid_block m1 bm)
          by (eapply Mem.valid_block_unchanged_on; [ exact Uentry_ac | exact Hv ]).
        assert (Hsat1 : action_sat Q m1 bm)
          by (eapply action_sat_unchanged_on; [ exact Uentry_ac | exact Hv | exact Hsat ]).
        assert (HMWF1 : MWF m1)
          by (eapply Hmwf_unch; [ exact Uentry_bm | exact Hv | exact HMWF ]).
        assert (HnoA1 : NoA m1) by (eapply Hnoaentry; [ exact Hentry | exact HnoA ]).
        destruct (Hbody f vargs m e le1 m1 Hreached Hexm Hentry Hnwr Hmarg') as [HTI1 HC1].
        destruct (IHbody HnoA1 HMWF1 Hv1 Hsat1 HTI1 HC1) as (Hv2 & Hsat2 & HMWF2 & _).
        assert (Ufree_ac : Mem.unchanged_on (action_cell bm) m2 m3).
        { eapply free_list_unchanged_on; [ exact Hfree | ].
          intros b lo hi i Hin Hac. destruct Hac as [Hb _]. subst b.
          exact (function_entry2_fresh _ _ _ _ _ _ _ Hentry bm lo hi Hin Hv). }
        assert (Ufree_bm : Mem.unchanged_on (fun b _ => b = bm) m2 m3).
        { eapply free_list_unchanged_on; [ exact Hfree | ].
          intros b lo hi i Hin Hb. subst b.
          exact (function_entry2_fresh _ _ _ _ _ _ _ Hentry bm lo hi Hin Hv). }
        split;
        [ eapply Mem.valid_block_unchanged_on; [ exact Ufree_ac | exact Hv2 ]
        | split;
          [ eapply action_sat_unchanged_on; [ exact Ufree_ac | exact Hv2 | exact Hsat2 ]
          | eapply Hmwf_unch; [ exact Ufree_bm | exact Hv2 | exact HMWF2 ] ] ].
    - (* eval_funcall_external *)
      intros m ef targs tres cconv vargs t vres m' Hec Hreached HnoA HMWF Hv Hsat Hmarg.
      split;
      [ eapply external_call_valid_block; [ exact Hec | exact Hv ]
      | split;
        [ eapply action_sat_unchanged_on; [ eapply Hext; exact Hec | exact Hv | exact Hsat ]
        | eapply Hmwf_ext; [ exact Hec | exact Hv | exact HMWF ] ] ]. }
  intros m fd vargs t m' vres Hreached HnoA HMWF Hmarg Hev Hv Hsat.
  exact (proj2 MAIN m fd vargs t m' vres Hev Hreached HnoA HMWF Hv Hsat Hmarg).
Qed.

(* ====================================================================== *)
(* ENGINE V2: the INVARIANT-AWARE census engine.                           *)
(*                                                                         *)
(* Same 18-case induction as exec_funcall_reach_value_reached, but the     *)
(* three census leaves that DISCARDED the carried invariant exactly where  *)
(* it pays are restated semantically:                                      *)
(*                                                                         *)
(* - HCif v2 gets the actual guard eval + bool_val + TI + the carried      *)
(*   memory facts: a census C may mark an A-GATED if as "ELSE-only" and    *)
(*   the lp discharge kills the THEN branch via the gate lemmas (AGates    *)
(*   input/ctl kills) -- TI carries "gate temps hold A-clear values",      *)
(*   established at the Sset case (HTI_set v2 now also gets action_sat).   *)
(* - HCsw v2 gets the scrutinee eval + sem_switch_arg + TI: the airborne   *)
(*   dispatch census only needs the NON-T suffixes                         *)
(*   (airborne_dispatch_kill_lp), not forall-n.                            *)
(* - Hw v2 (the writer leaf) gets W vargs, supplied at the actual call     *)
(*   site by the NEW Hcallwriter bridge (TI+C pin the literal arguments    *)
(*   of every censused writer call) -- this retires the forall-vargs       *)
(*   phantom: set_mario_action IS reached, but only with censused-clean    *)
(*   (non-tainted) action arguments.                                       *)
(*                                                                         *)
(* The v1 engine stays; v2 lives alongside until the lp discharge swaps    *)
(* the consumer.                                                           *)
(* ====================================================================== *)

Definition reach_value_preserves_v2
    (Q : int -> Prop) (bm : block) (ge : genv) (NoA MWF : mem -> Prop)
    (writer : Clight.fundef -> Prop) (W : list val -> Prop)
    (Reached_fd : Clight.fundef -> Prop) : Prop :=
  forall m fd vargs t m' vres,
    Reached_fd fd -> NoA m -> MWF m ->
    (marg_exempt fd = false -> marg_ok bm vargs) ->
    (writer fd -> W vargs) ->
    eval_funcall function_entry2 ge m fd vargs t m' vres ->
    Mem.valid_block m bm -> action_sat Q m bm ->
    Mem.valid_block m' bm /\ action_sat Q m' bm /\ MWF m'.

Theorem exec_funcall_reach_value_v2 :
  forall (Q : int -> Prop) (bm : block) (ge : genv)
         (NoA MWF : mem -> Prop) (writer : Clight.fundef -> Prop)
         (W : list val -> Prop)
         (bridged : Clight.fundef -> Prop)
         (Reached_fd : Clight.fundef -> Prop)
         (TI : temp_env -> Prop) (C : statement -> Prop),
    (* leaf A: as in v1, but BRIDGED callees are also excluded from the
       census walk -- a bridged function (e.g. update_mario_button_inputs,
       whose controller A-gate needs a 2-deep memory-dependent provenance
       chain that a temp-only TI cannot carry) is discharged by a direct
       whole-funcall lemma (Hbridged below) instead. *)
    (forall f vargs m e le m1,
       Reached_fd (Internal f) -> marg_exempt (Internal f) = false ->
       function_entry2 ge f vargs m e le m1 ->
       ~ writer (Internal f) -> ~ bridged (Internal f) -> marg_ok bm vargs ->
       TI le /\ C (fn_body f)) ->
    (* the BRIDGED leaf: reached internal functions with their own direct
       preservation lemma (the umbi body walk lifted to funcall level).
       Gets the marg fact -- the walk needs arg0 = Vptr bm 0. *)
    (forall f vargs m t m' vres,
       Reached_fd (Internal f) -> bridged (Internal f) ->
       (marg_exempt (Internal f) = false -> marg_ok bm vargs) ->
       eval_funcall function_entry2 ge m (Internal f) vargs t m' vres ->
       NoA m -> MWF m -> Mem.valid_block m bm -> action_sat Q m bm ->
       Mem.valid_block m' bm /\ action_sat Q m' bm /\ MWF m') ->
    (* the store leaf: unchanged. *)
    (forall e le m a1 a2 loc ofs bf v2 v m',
       eval_lvalue ge e le m a1 loc ofs bf ->
       eval_expr ge e le m a2 v2 ->
       sem_cast v2 (typeof a2) (typeof a1) m = Some v ->
       assign_loc ge (typeof a1) m loc ofs bf v m' ->
       TI le -> C (Sassign a1 a2) -> MWF m ->
       Mem.valid_block m bm -> action_sat Q m bm ->
       Mem.valid_block m' bm /\ action_sat Q m' bm /\ MWF m') ->
    (* the call-arg census: unchanged. *)
    (forall e le m optid a al tyargs vargs vf fd,
       TI le -> C (Scall optid a al) ->
       eval_expr ge e le m a vf -> Genv.find_funct ge vf = Some fd ->
       marg_exempt fd = false ->
       eval_exprlist ge e le m al tyargs vargs -> marg_ok bm vargs) ->
    (* leaf A-exempt: unchanged. *)
    (forall f vargs m t m' vres,
       Reached_fd (Internal f) -> marg_exempt (Internal f) = true ->
       eval_funcall function_entry2 ge m (Internal f) vargs t m' vres ->
       NoA m -> MWF m -> Mem.valid_block m bm -> action_sat Q m bm ->
       Mem.valid_block m' bm /\ action_sat Q m' bm /\ MWF m') ->
    (* HTI_set V2: now ALSO gets action_sat, so a census-marked dispatch
       temp (`t = m->action`) can be recorded in TI as holding a Q-value. *)
    (forall e le m id a v,
       MWF m -> action_sat Q m bm -> eval_expr ge e le m a v ->
       TI le -> C (Sset id a) -> TI (PTree.set id v le)) ->
    (forall optid a al v le,
       C (Scall optid a al) -> TI le ->
       (forall b o, v = Vptr b o -> b <> bm) -> TI (set_opttemp optid v le)) ->
    (forall optid ef tyargs al v le,
       C (Sbuiltin optid ef tyargs al) -> TI le ->
       (forall b o, v = Vptr b o -> b <> bm) -> TI (set_opttemp optid v le)) ->
    (forall fd m0 vargs0 t0 m0' vres0,
       Reached_fd fd ->
       eval_funcall function_entry2 ge m0 fd vargs0 t0 m0' vres0 ->
       forall b o, vres0 = Vptr b o -> b <> bm) ->
    (forall ef vargs0 m0 t0 vres0 m0',
       external_call ef ge vargs0 m0 t0 vres0 m0' ->
       forall b o, vres0 = Vptr b o -> b <> bm) ->
    (forall e le m optid a al vf fd,
       TI le -> C (Scall optid a al) ->
       eval_expr ge e le m a vf -> Genv.find_funct ge vf = Some fd ->
       Reached_fd fd) ->
    (* NEW (Hcallwriter): the call-site bridge for the writer. TI+C pin the
       actual evaluated argument list of every censused call that resolves
       to the writer -- the lp discharge enumerates the (now gate-killed)
       writer call sites and reads off their literal action arguments. *)
    (forall e le m optid a al tyargs vargs vf fd,
       TI le -> C (Scall optid a al) ->
       eval_expr ge e le m a vf -> Genv.find_funct ge vf = Some fd ->
       writer fd ->
       eval_exprlist ge e le m al tyargs vargs -> W vargs) ->
    (* leaf B (the writer) V2: gets W vargs -- no forall-vargs phantom. *)
    (forall m fd vargs t m' vres,
       Reached_fd fd -> NoA m -> MWF m -> W vargs ->
       eval_funcall function_entry2 ge m fd vargs t m' vres ->
       writer fd ->
       Mem.valid_block m bm -> action_sat Q m bm ->
       Mem.valid_block m' bm /\ action_sat Q m' bm /\ MWF m') ->
    reach_ext_preserves (action_cell bm) ge ->
    (forall ef vargs m t vres m',
       external_call ef ge vargs m t vres m' ->
       Mem.valid_block m bm -> MWF m -> MWF m') ->
    (forall m m', Mem.unchanged_on (fun b _ => b = bm) m m' ->
                  Mem.valid_block m bm -> MWF m -> MWF m') ->
    (forall e le m s t le' m' out,
       exec_stmt function_entry2 ge e le m s t le' m' out -> NoA m -> NoA m') ->
    (forall f vargs m e le m1,
       function_entry2 ge f vargs m e le m1 -> NoA m -> NoA m1) ->
    (* HCseq V2, split semantically: the head census is unconditional, but
       the TAIL census is owed only when the head actually completed
       Out_normal. This is what lets a census accept a switch suffix whose
       break-terminated head arm is followed by textually-present but
       semantically-dead T arms (ends_in_break_not_normal refutes the
       Out_normal premise at the discharge). *)
    (forall s1 s2, C (Ssequence s1 s2) -> C s1) ->
    (forall e le m s1 s2 t1 le1 m1,
       C (Ssequence s1 s2) ->
       exec_stmt function_entry2 ge e le m s1 t1 le1 m1 Out_normal ->
       C s2) ->
    (* HCif V2: the branch census obligation is SEMANTIC -- it sees the
       actual guard value, the boolean taken, TI and the carried memory
       facts, so a gate-killed THEN branch never has to pass census. *)
    (forall e le m a s1 s2 v1 b,
       C (Sifthenelse a s1 s2) -> MWF m -> action_sat Q m bm -> TI le ->
       eval_expr ge e le m a v1 -> bool_val v1 (typeof a) m = Some b ->
       C (if b then s1 else s2)) ->
    (forall s1 s2, C (Sloop s1 s2) -> C s1 /\ C s2) ->
    (* HCsw V2: semantic -- sees the scrutinee value and TI, so the
       airborne dispatch only owes census on its non-T suffixes. *)
    (forall e le m a ls v n,
       C (Sswitch a ls) -> MWF m -> action_sat Q m bm -> TI le ->
       eval_expr ge e le m a v -> sem_switch_arg v (typeof a) = Some n ->
       C (seq_of_labeled_statement (select_switch n ls))) ->
    reach_value_preserves_v2 Q bm ge NoA MWF writer W Reached_fd.
Proof.
  intros Q bm ge NoA MWF writer W bridged Reached_fd TI C
         Hbody Hbridged Hassign Hcallmarg Hexempt HTI_set HTI_optc HTI_optb
         Hret_call Hret_builtin Hcall_reached Hcallwriter Hw
         Hext Hmwf_ext Hmwf_unch Hnoaexec Hnoaentry HCseq1 HCseq2 HCif HCloop HCsw.
  assert (MAIN :
    (forall e le m s t le' m' out,
       exec_stmt function_entry2 ge e le m s t le' m' out ->
       NoA m -> MWF m -> Mem.valid_block m bm -> action_sat Q m bm -> TI le -> C s ->
       Mem.valid_block m' bm /\ action_sat Q m' bm /\ MWF m' /\ TI le')
    /\
    (forall m fd vargs t m' vres,
       eval_funcall function_entry2 ge m fd vargs t m' vres ->
       Reached_fd fd ->
       NoA m -> MWF m -> Mem.valid_block m bm -> action_sat Q m bm ->
       (marg_exempt fd = false -> marg_ok bm vargs) ->
       (writer fd -> W vargs) ->
       Mem.valid_block m' bm /\ action_sat Q m' bm /\ MWF m')).
  { apply (exec_stmt_funcall_ind function_entry2 ge
      (fun e le m s t le' m' out =>
         NoA m -> MWF m -> Mem.valid_block m bm -> action_sat Q m bm -> TI le -> C s ->
         Mem.valid_block m' bm /\ action_sat Q m' bm /\ MWF m' /\ TI le')
      (fun m fd vargs t m' vres =>
         Reached_fd fd ->
         NoA m -> MWF m -> Mem.valid_block m bm -> action_sat Q m bm ->
         (marg_exempt fd = false -> marg_ok bm vargs) ->
         (writer fd -> W vargs) ->
         Mem.valid_block m' bm /\ action_sat Q m' bm /\ MWF m')).
    - (* Sskip *) intros e le m HnoA HMWF Hv Hsat HTI _.
      split; [ exact Hv | split; [ exact Hsat | split; [ exact HMWF | exact HTI ] ] ].
    - (* Sassign *)
      intros e le m a1 a2 loc ofs bf v2 v m' Hlv He Hcast Hal HnoA HMWF Hv Hsat HTI HC.
      destruct (Hassign e le m a1 a2 loc ofs bf v2 v m' Hlv He Hcast Hal HTI HC HMWF Hv Hsat)
        as (Hv' & Hsat' & HMWF').
      split; [ exact Hv' | split; [ exact Hsat' | split; [ exact HMWF' | exact HTI ] ] ].
    - (* Sset: HTI_set v2 also receives action_sat *)
      intros e le m id a v He HnoA HMWF Hv Hsat HTI HC.
      split; [ exact Hv | split; [ exact Hsat | split; [ exact HMWF |
        eapply HTI_set; [ exact HMWF | exact Hsat | exact He | exact HTI | exact HC ] ] ] ].
    - (* Scall: derive Reached_fd + the writer-args bridge, then funcall IH *)
      intros e le m optid a al tyargs tyres cconv vf vargs f t m' vres
             Hcf He Hel Hff Htof Hfd IHfun HnoA HMWF Hv Hsat HTI HC.
      assert (Hmarg : marg_exempt f = false -> marg_ok bm vargs)
        by (intro Hne; eapply Hcallmarg;
            [ exact HTI | exact HC | exact He | exact Hff | exact Hne | exact Hel ]).
      assert (Hreached : Reached_fd f) by (eapply Hcall_reached; [ exact HTI | exact HC | exact He | exact Hff ]).
      assert (Hwargs : writer f -> W vargs)
        by (intro Hwr; eapply Hcallwriter;
            [ exact HTI | exact HC | exact He | exact Hff | exact Hwr | exact Hel ]).
      destruct (IHfun Hreached HnoA HMWF Hv Hsat Hmarg Hwargs) as (Hv' & Hsat' & HMWF').
      split; [ exact Hv' | split; [ exact Hsat' | split; [ exact HMWF' |
        eapply HTI_optc;
          [ exact HC | exact HTI
          | exact (Hret_call f m vargs t m' vres Hreached Hfd) ] ] ] ].
    - (* Sbuiltin *)
      intros e le m optid ef al tyargs vargs t m' vres Hel Hec HnoA HMWF Hv Hsat HTI HC.
      split;
      [ eapply external_call_valid_block; [ exact Hec | exact Hv ]
      | split;
        [ eapply action_sat_unchanged_on; [ eapply Hext; exact Hec | exact Hv | exact Hsat ]
        | split;
          [ eapply Hmwf_ext; [ exact Hec | exact Hv | exact HMWF ]
          | eapply HTI_optb;
              [ exact HC | exact HTI
              | exact (Hret_builtin ef vargs m t vres m' Hec) ] ] ] ].
    - (* Sseq_1: the tail census comes from HCseq2 + the head's Out_normal run *)
      intros e le m s1 s2 t1 le1 m1 t2 le2 m2 out He1 IH1 He2 IH2 HnoA HMWF Hv Hsat HTI HC.
      pose proof (HCseq1 _ _ HC) as HC1.
      pose proof (HCseq2 _ _ _ _ _ _ _ _ HC He1) as HC2.
      destruct (IH1 HnoA HMWF Hv Hsat HTI HC1) as (Hv1 & Hsat1 & HMWF1 & HTI1).
      apply (IH2 (Hnoaexec _ _ _ _ _ _ _ _ He1 HnoA) HMWF1 Hv1 Hsat1 HTI1 HC2).
    - (* Sseq_2: only the head ran -- only the head census is needed *)
      intros e le m s1 s2 t1 le1 m1 out He1 IH1 Hout HnoA HMWF Hv Hsat HTI HC.
      apply (IH1 HnoA HMWF Hv Hsat HTI (HCseq1 _ _ HC)).
    - (* Sifthenelse: HCif v2 -- semantic branch census *)
      intros e le m a s1 s2 v1 b t le' m' out He Hbool Hexec IH HnoA HMWF Hv Hsat HTI HC.
      apply (IH HnoA HMWF Hv Hsat HTI).
      eapply HCif; [ exact HC | exact HMWF | exact Hsat | exact HTI | exact He | exact Hbool ].
    - (* Sreturn_none *) intros e le m HnoA HMWF Hv Hsat HTI _.
      split; [ exact Hv | split; [ exact Hsat | split; [ exact HMWF | exact HTI ] ] ].
    - (* Sreturn_some *) intros e le m a v He HnoA HMWF Hv Hsat HTI _.
      split; [ exact Hv | split; [ exact Hsat | split; [ exact HMWF | exact HTI ] ] ].
    - (* Sbreak *) intros e le m HnoA HMWF Hv Hsat HTI _.
      split; [ exact Hv | split; [ exact Hsat | split; [ exact HMWF | exact HTI ] ] ].
    - (* Scontinue *) intros e le m HnoA HMWF Hv Hsat HTI _.
      split; [ exact Hv | split; [ exact Hsat | split; [ exact HMWF | exact HTI ] ] ].
    - (* Sloop_stop1 *)
      intros e le m s1 s2 t le' m' out' out He1 IH1 Hbor HnoA HMWF Hv Hsat HTI HC.
      destruct (HCloop _ _ HC) as [HC1 _]. apply (IH1 HnoA HMWF Hv Hsat HTI HC1).
    - (* Sloop_stop2 *)
      intros e le m s1 s2 t1 le1 m1 out1 t2 le2 m2 out2 out
             He1 IH1 Hnoc He2 IH2 Hbor HnoA HMWF Hv Hsat HTI HC.
      destruct (HCloop _ _ HC) as [HC1 HC2].
      destruct (IH1 HnoA HMWF Hv Hsat HTI HC1) as (Hv1 & Hsat1 & HMWF1 & HTI1).
      apply (IH2 (Hnoaexec _ _ _ _ _ _ _ _ He1 HnoA) HMWF1 Hv1 Hsat1 HTI1 HC2).
    - (* Sloop_loop *)
      intros e le m s1 s2 t1 le1 m1 out1 t2 le2 m2 t3 le3 m3 out
             He1 IH1 Hnoc He2 IH2 He3 IH3 HnoA HMWF Hv Hsat HTI HC.
      destruct (HCloop _ _ HC) as [HC1 HC2].
      destruct (IH1 HnoA HMWF Hv Hsat HTI HC1) as (Hv1 & Hsat1 & HMWF1 & HTI1).
      pose proof (Hnoaexec _ _ _ _ _ _ _ _ He1 HnoA) as HnoA1.
      destruct (IH2 HnoA1 HMWF1 Hv1 Hsat1 HTI1 HC2) as (Hv2 & Hsat2 & HMWF2 & HTI2).
      pose proof (Hnoaexec _ _ _ _ _ _ _ _ He2 HnoA1) as HnoA2.
      apply (IH3 HnoA2 HMWF2 Hv2 Hsat2 HTI2 HC).
    - (* Sswitch: HCsw v2 -- semantic case census *)
      intros e le m a t v n sl le1 m1 out He Hsa Hexec IH HnoA HMWF Hv Hsat HTI HC.
      apply (IH HnoA HMWF Hv Hsat HTI).
      eapply HCsw; [ exact HC | exact HMWF | exact Hsat | exact HTI | exact He | exact Hsa ].
    - (* eval_funcall_internal: bridged-split, then writer-split *)
      intros m f vargs t e le1 le2 m1 m2 out vres m3
             Hentry Hbexec IHbody Hout Hfree Hreached HnoA HMWF Hv Hsat Hmarg Hwargs.
      destruct (classic (bridged (Internal f))) as [Hbr | Hnbr].
      { eapply Hbridged;
          [ exact Hreached | exact Hbr | exact Hmarg
          | eapply eval_funcall_internal; [ exact Hentry | exact Hbexec | exact Hout | exact Hfree ]
          | exact HnoA | exact HMWF | exact Hv | exact Hsat ]. }
      destruct (classic (writer (Internal f))) as [Hwr | Hnwr].
      + eapply Hw;
          [ exact Hreached | exact HnoA | exact HMWF | exact (Hwargs Hwr)
          | eapply eval_funcall_internal; [ exact Hentry | exact Hbexec | exact Hout | exact Hfree ]
          | exact Hwr | exact Hv | exact Hsat ].
      + destruct (marg_exempt (Internal f)) eqn:Hexm.
        * eapply Hexempt;
            [ exact Hreached | exact Hexm
            | eapply eval_funcall_internal; [ exact Hentry | exact Hbexec | exact Hout | exact Hfree ]
            | exact HnoA | exact HMWF | exact Hv | exact Hsat ].
        * assert (Hmarg' : marg_ok bm vargs) by (apply Hmarg; reflexivity).
          assert (Uentry_ac : Mem.unchanged_on (action_cell bm) m m1)
            by (eapply function_entry2_unchanged_on; eauto).
          assert (Uentry_bm : Mem.unchanged_on (fun b _ => b = bm) m m1)
            by (eapply function_entry2_unchanged_on; eauto).
          assert (Hv1 : Mem.valid_block m1 bm)
            by (eapply Mem.valid_block_unchanged_on; [ exact Uentry_ac | exact Hv ]).
          assert (Hsat1 : action_sat Q m1 bm)
            by (eapply action_sat_unchanged_on; [ exact Uentry_ac | exact Hv | exact Hsat ]).
          assert (HMWF1 : MWF m1)
            by (eapply Hmwf_unch; [ exact Uentry_bm | exact Hv | exact HMWF ]).
          assert (HnoA1 : NoA m1) by (eapply Hnoaentry; [ exact Hentry | exact HnoA ]).
          destruct (Hbody f vargs m e le1 m1 Hreached Hexm Hentry Hnwr Hnbr Hmarg') as [HTI1 HC1].
          destruct (IHbody HnoA1 HMWF1 Hv1 Hsat1 HTI1 HC1) as (Hv2 & Hsat2 & HMWF2 & _).
          assert (Ufree_ac : Mem.unchanged_on (action_cell bm) m2 m3).
          { eapply free_list_unchanged_on; [ exact Hfree | ].
            intros b lo hi i Hin Hac. destruct Hac as [Hb _]. subst b.
            exact (function_entry2_fresh _ _ _ _ _ _ _ Hentry bm lo hi Hin Hv). }
          assert (Ufree_bm : Mem.unchanged_on (fun b _ => b = bm) m2 m3).
          { eapply free_list_unchanged_on; [ exact Hfree | ].
            intros b lo hi i Hin Hb. subst b.
            exact (function_entry2_fresh _ _ _ _ _ _ _ Hentry bm lo hi Hin Hv). }
          split;
          [ eapply Mem.valid_block_unchanged_on; [ exact Ufree_ac | exact Hv2 ]
          | split;
            [ eapply action_sat_unchanged_on; [ exact Ufree_ac | exact Hv2 | exact Hsat2 ]
            | eapply Hmwf_unch; [ exact Ufree_bm | exact Hv2 | exact HMWF2 ] ] ].
    - (* eval_funcall_external *)
      intros m ef targs tres cconv vargs t vres m' Hec Hreached HnoA HMWF Hv Hsat Hmarg _.
      split;
      [ eapply external_call_valid_block; [ exact Hec | exact Hv ]
      | split;
        [ eapply action_sat_unchanged_on; [ eapply Hext; exact Hec | exact Hv | exact Hsat ]
        | eapply Hmwf_ext; [ exact Hec | exact Hv | exact HMWF ] ] ]. }
  intros m fd vargs t m' vres Hreached HnoA HMWF Hmarg Hwargs Hev Hv Hsat.
  exact (proj2 MAIN m fd vargs t m' vres Hev Hreached HnoA HMWF Hv Hsat Hmarg Hwargs).
Qed.
