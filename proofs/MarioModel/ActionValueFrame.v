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
    exec_stmt function_entry2 sma_ge e le m (fn_body mario.f_set_mario_action) t le' m' out ->
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
