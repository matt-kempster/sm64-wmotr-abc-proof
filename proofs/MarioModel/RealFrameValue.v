(* RealFrameValue.v -- the funcall->value bridge for the REAL per-frame entry.
 *
 * GOAL-1 tethering step. NoAImpliesNoFly's capstone rested on an ABSTRACT
 * `step` and a black-box `frame_preserves_nonflying`. This file replaces that
 * with the value engine applied to the REAL clightgen'd per-frame function
 * `mario.f_execute_mario_action`, reducing the per-frame obligation to the
 * value engine's named reach residuals over the real Mario genv.
 *
 * WHY A NEW BRIDGE (vs. FuncallFrame.funcall_body_nf_preserves). The existing
 * store-frame funcall bridge REQUIRES `_m` (Mario's pointer) as the function's
 * first formal, because its engine tracks a `tmps_off_bm` provenance invariant
 * over pointer temps. The real entry `execute_mario_action(struct Object *o)`
 * takes an OBJECT pointer and finds Mario by loading the `gMarioState` global
 * INTERNALLY -- so a temp DOES hold bm, and that engine's invariant is the
 * wrong fit. The VALUE engine (ActionValueFrame.exec_stmt_value_preserves)
 * tracks only `action_sat Q m bm` -- a fact about the watched cell (bm,12),
 * independent of params and temps. So the value bridge below needs NO
 * param-shape and NO temp hypotheses: it works for ANY `f` with no stack vars.
 *
 * WHAT IS TETHERED / WHAT REMAINS (no buried lede):
 *   - `funcall_value_preserves` (generic): a whole eval_funcall of any
 *     fn_vars=nil function carries `action_sat Q` forward, GIVEN the value
 *     engine's reach residuals + the function body's own per-Sassign value-ok.
 *     This is the entry inversion (function_entry2 -> exec_stmt of the body ->
 *     free_list), proved here, with no admit.
 *   - The residuals it leaves, specialized to execute_mario_action, are the
 *     interprocedural reach closure over the REAL genv:
 *       reach_value_preserves nonflying bm mario_ge   (THE CRUX)
 *       reach_ext_preserves (action_cell bm) mario_ge
 *     plus the body-local `stmt_value_ok` of execute_mario_action. NB (audited
 *     2026-06-02): that last one is NOT the "decidable" win it looks like -- the
 *     body's two Sassigns store through gMarioState->marioObj (the Object block),
 *     and assign_value_ok's `forall le m` is over-strong (an adversarial temp can
 *     alias bm). Its honest content is the marioObj-off-bm memory invariant, so it
 *     wants a value(+)provenance engine merge. See execute_mario_action_step below.
 *
 * THE CRUX, named honestly. `reach_value_preserves nonflying bm mario_ge`
 * (every reached funcall preserves the non-flying action) is the interprocedural
 * generalization the value engine inducts on. As stated UNCONDITIONALLY it is
 * still too strong -- `set_mario_action(m, ACT_FLYING, _)` is a reached funcall
 * that does NOT preserve non-flying. Closing it needs the no-A carve-out (the
 * only action writer is set_mario_action; under a no-A frame its argument is
 * non-flying -- ActionValue.set_mario_action_field + the ActionWriters corpus).
 * That conditioning is the next crux; here we reduce the capstone TO it, over
 * the real callgraph, with the entry inversion fully discharged.
 *
 * No Admitted.
 *)

From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep.
From Coq Require Import List.
Import ListNotations.
From SM64.Generated Require mario.
From SM64.Proofs Require Import Flying ActionValue FieldNonInterference ActionValueFrame.

(* ================================================================== *)
(* THE GENERIC FUNCALL -> VALUE BRIDGE.                                 *)
(*                                                                     *)
(* For ANY function f with no stack vars (fn_vars = nil, the clightgen- *)
(* normalised shape), a whole eval_funcall preserves `action_sat Q`     *)
(* at the watched block bm, GIVEN the value engine's reach residuals     *)
(* (reach_value_preserves / reach_ext_preserves over the call genv) and  *)
(* the function body's own per-Sassign value-ok check. Unlike the store- *)
(* frame bridge this needs NO param-shape and NO temp invariant -- the    *)
(* value invariant is about the cell (bm,12) alone, so the params/temps   *)
(* the entry sets up are irrelevant to it.                                *)
(* ================================================================== *)
Theorem funcall_value_preserves :
  forall (Q : int -> Prop) (bm : block) (ge : genv) (f : function)
         vargs m m' t res,
    reach_value_preserves Q bm ge ->
    reach_ext_preserves (action_cell bm) ge ->
    fn_vars f = nil ->
    (forall e, stmt_value_ok Q bm ge e (fn_body f)) ->
    Mem.valid_block m bm ->
    action_sat Q m bm ->
    eval_funcall function_entry2 ge m (Internal f) vargs t m' res ->
    Mem.valid_block m' bm /\ action_sat Q m' bm.
Proof.
  intros Q bm ge f vargs m m' t res Hreach Hext Hvars Hok Hv Hsat Hfun.
  inv Hfun.
  (* entry: fn_vars = nil makes alloc_variables trivial (e = empty_env, mem kept) *)
  match goal with Hfe : function_entry2 _ _ _ _ _ _ _ |- _ => inv Hfe end.
  match goal with Hav : alloc_variables _ _ _ _ _ _ |- _ =>
    rewrite Hvars in Hav; inv Hav end.
  (* run the value engine over the body (e = empty_env, le = the bound temps) *)
  match goal with
  | Hexec : exec_stmt function_entry2 ge empty_env _ _ (fn_body f) _ _ _ _ |- _ =>
      destruct (exec_stmt_value_preserves Q bm ge Hreach Hext
                  _ _ _ _ _ _ _ _
                  Hexec Hv Hsat (Hok empty_env)) as [Hv2 Hsat2]
  end.
  (* free_list of the empty env touches nothing: result mem = body's m2 *)
  match goal with Hfree : Mem.free_list _ _ = Some _ |- _ =>
    assert (Hbe : blocks_of_env ge empty_env = nil) by reflexivity;
    rewrite Hbe in Hfree; cbn [Mem.free_list] in Hfree; inv Hfree end.
  exact (conj Hv2 Hsat2).
Qed.

(* ================================================================== *)
(* THE REAL PER-FRAME ENTRY, specialized.                              *)
(*                                                                     *)
(* `mario.f_execute_mario_action` is the per-frame Mario action dispatch *)
(* (one game tick's Mario update). It has fn_vars = nil (clightgen-       *)
(* normalised), so the generic bridge applies with NO param-shape side    *)
(* condition -- even though its formal is an Object pointer and it finds   *)
(* Mario via the gMarioState global internally. A whole frame therefore    *)
(* carries the non-flying action invariant forward, reduced to the value    *)
(* engine's reach residuals over the REAL Mario genv.                       *)
(* ================================================================== *)

Definition mario_ge : genv := globalenv mario.prog.

(* The non-flying action predicate (Q for the value engine). *)
Definition nonflying (v : int) : Prop := is_flying_int v = false.

(* One real per-frame Mario update: a CompCert big-step of the actual
   f_execute_mario_action on an Object pointer. (The input is latched in
   memory; the value-engine preservation below holds for ANY input -- the
   no-A carve-out lives inside reach_value_preserves, not here.) *)
Definition execute_mario_action_step (m m' : mem) : Prop :=
  exists (b_o : block) (t : trace) (res : val),
    eval_funcall function_entry2 mario_ge m
      (Internal mario.f_execute_mario_action)
      (Vptr b_o Ptrofs.zero :: nil) t m' res.

(* THE REDUCTION: a real frame preserves (valid bm /\ non-flying action),
   GIVEN exactly the value engine's three named residuals over mario_ge:
     - reach_value_preserves nonflying bm mario_ge   (THE interprocedural crux)
     - reach_ext_preserves (action_cell bm) mario_ge
     - the body-local per-Sassign value-ok of execute_mario_action's own body
       (the action writes proper happen in CALLEES, governed by
       reach_value_preserves, not here). HONEST SCOPE: this body residual is
       OVER-STRONG as a bare `forall e, stmt_value_ok ...`. The body has exactly
       two Sassigns and BOTH store through gMarioState->marioObj -- the Mario
       Object block -- (`...->header.gfx.node.flags`, tshort; and
       `...->rawData.asS32[43]`, tint). Since assign_value_ok quantifies
       `forall le m` with no link between the base temp and memory, an adversarial
       le (temp |-> Vptr bm delta) drives the field offset onto byte 12 and both
       disjuncts fail. Its TRUE content is the memory-wf fact that marioObj's block
       != bm -- the StoreFrameDischarge tmps_off_bm invariant. So the bridge here
       needs no param-shape for the ENTRY inversion, but fully removing this body
       residual wants a value(+)provenance engine merge. *)
Theorem execute_mario_action_preserves_nonflying :
  forall (bm : block) m m',
    reach_value_preserves nonflying bm mario_ge ->
    reach_ext_preserves (action_cell bm) mario_ge ->
    (forall e, stmt_value_ok nonflying bm mario_ge e
                 (fn_body mario.f_execute_mario_action)) ->
    Mem.valid_block m bm ->
    action_sat nonflying m bm ->
    execute_mario_action_step m m' ->
    Mem.valid_block m' bm /\ action_sat nonflying m' bm.
Proof.
  intros bm m m' Hreach Hext Hok Hv Hsat (b_o & t & res & Hfun).
  exact (funcall_value_preserves nonflying bm mario_ge
           mario.f_execute_mario_action (Vptr b_o Ptrofs.zero :: nil) m m' t res
           Hreach Hext eq_refl Hok Hv Hsat Hfun).
Qed.

(* ================================================================== *)
(* SHARPENING residual (3): the body's TWO real stores, named.          *)
(*                                                                     *)
(* f_execute_mario_action's body contains EXACTLY two Sassigns (53 Sset, *)
(* 22 Scall, the rest control flow). Both store through gMarioState->     *)
(* marioObj -- the Mario OBJECT block -- transcribed here LITERALLY from   *)
(* the clightgen'd AST (generated/mario.v, body lines 98 and 588). This    *)
(* replaces the vague "the whole body is value-ok" residual with these two  *)
(* precise, real-AST obligations; body_value_ok_from_stores PROVES (by cbn   *)
(* over the concrete body) that they are the body's only value content --    *)
(* a machine-checked census, not a claim. *)

(* store 1: `_t'49->header.gfx.node.flags = _t'52 & ~(1<<4)` (tshort). *)
Definition store1_lval : expr :=
  Efield
    (Efield
      (Efield
        (Efield
          (Ederef (Etempvar mario._t'49 (tptr (Tstruct mario._Object noattr)))
                  (Tstruct mario._Object noattr))
          mario._header (Tstruct mario._ObjectNode noattr))
        mario._gfx (Tstruct mario._GraphNodeObject noattr))
      mario._node (Tstruct mario._GraphNode noattr))
    mario._flags tshort.
Definition store1_rval : expr :=
  Ebinop Oand (Etempvar mario._t'52 tshort)
    (Eunop Onotint
      (Ebinop Oshl (Econst_int (Int.repr 1) tint) (Econst_int (Int.repr 4) tint) tint)
      tint)
    tint.

(* store 2: `_t'13->rawData.asS32[43] = 0` (tint). *)
Definition store2_lval : expr :=
  Ederef
    (Ebinop Oadd
      (Efield
        (Efield
          (Ederef (Etempvar mario._t'13 (tptr (Tstruct mario._Object noattr)))
                  (Tstruct mario._Object noattr))
          mario._rawData (Tunion mario.__764 noattr))
        mario._asS32 (tarray tint 80))
      (Econst_int (Int.repr 43) tint) (tptr tint))
    tint.
Definition store2_rval : expr := Econst_int (Int.repr 0) tint.

(* The PRECISE residual (3): the two real body stores are each value-ok.
   Still over-strong as a bare `forall e` (assign_value_ok quantifies forall
   le m, admitting an adversarial temp aliasing bm) -- its honest content is the
   provenance fact that _t'49/_t'13 hold the marioObj pointer (block != bm). But
   it is now NAMED and LOCALIZED to the two actual stores, the discharge target
   for the value(+)provenance engine merge. *)
Definition body_stores_value_ok (bm : block) : Prop :=
  forall e : env,
    assign_value_ok nonflying bm mario_ge e store1_lval store1_rval /\
    assign_value_ok nonflying bm mario_ge e store2_lval store2_rval.

(* THE CENSUS, machine-checked: the two named stores ARE the whole body's
   value-ok content. cbn unfolds stmt_value_ok over the concrete body to a
   conjunction of Trues (every Sset/Scall/control node) and exactly these two
   assign_value_ok leaves. So whoever discharges the two stores discharges the
   body -- there is no third hidden write. *)
Lemma body_value_ok_from_stores :
  forall bm, body_stores_value_ok bm ->
  forall e, stmt_value_ok nonflying bm mario_ge e (fn_body mario.f_execute_mario_action).
Proof.
  intros bm Hs e. destruct (Hs e) as [H1 H2].
  unfold store1_lval, store1_rval, store2_lval, store2_rval in H1, H2.
  cbn [stmt_value_ok ls_value_ok].
  repeat split; try exact I; first [ exact H1 | exact H2 ].
Qed.

(* ================================================================== *)
(* THE PROVENANCE PAYOFF: the two real stores land in their base TEMP's *)
(* block, so they AVOID the action cell (bm,12) whenever that temp holds *)
(* an off-bm pointer. This is the brick the value(+)provenance engine    *)
(* merge consumes -- it discharges assign_value_ok's AVOID disjunct for   *)
(* the two body stores GIVEN provenance (_t'49/_t'13 hold the marioObj    *)
(* pointer, block != bm). Proved here against the LITERAL clightgen'd      *)
(* lvalues; what remains for full discharge is THREADING that provenance   *)
(* through the body exec (re-established at the `_t = gMarioState->marioObj`*)
(* Ssets from marioObj memory-wf) -- the engine merge, not these lemmas.   *)
(* ================================================================== *)

(* ---- eval_lvalue/eval_expr inversion helpers (block-tracking) ---- *)

(* Efield's base evaluates (as an EXPRESSION) to a Vptr at the SAME block:
   both Efield rules have premise `eval_expr a (Vptr l ofs)` with conclusion
   block l (only the offset shifts by the field delta). *)
Lemma eval_lvalue_Efield_base :
  forall ge e le m a i ty loc ofs bf,
    eval_lvalue ge e le m (Efield a i ty) loc ofs bf ->
    exists o0, eval_expr ge e le m a (Vptr loc o0).
Proof. intros until bf; intro H; inv H; eauto. Qed.

(* Ederef's base evaluates to exactly the Vptr it dereferences. *)
Lemma eval_lvalue_Ederef_base :
  forall ge e le m a ty loc ofs bf,
    eval_lvalue ge e le m (Ederef a ty) loc ofs bf ->
    eval_expr ge e le m a (Vptr loc ofs).
Proof. intros until bf; intro H; inv H; auto. Qed.

(* A temp evaluates to exactly its le binding (Etempvar is never an lvalue,
   so eval_Elvalue cannot fire -- only eval_Etempvar). *)
Lemma eval_expr_Etempvar_val :
  forall ge e le m id ty v,
    eval_expr ge e le m (Etempvar id ty) v -> le ! id = Some v.
Proof.
  intros until v; intro H; inv H; auto.
  match goal with Hlv : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hlv end.
Qed.

(* deref_loc of an AGGREGATE type (struct/union/array: By_copy or
   By_reference) returns the SAME block it was given -- it hands back the
   address, it does not chase a stored pointer. (By_value WOULD chase, hence
   the side condition; the bitfield case yields a Vint, not a Vptr.) *)
Lemma deref_loc_aggregate_block :
  forall ty m b ofs bf loc o,
    (access_mode ty = By_reference \/ access_mode ty = By_copy) ->
    deref_loc ty m b ofs bf (Vptr loc o) ->
    loc = b.
Proof.
  intros ty m b ofs bf loc o Hmode H; inv H.
  - destruct Hmode as [Hm|Hm]; congruence.
  - reflexivity.
  - reflexivity.
  - match goal with Hlb : load_bitfield _ _ _ _ _ _ _ _ |- _ => inv Hlb end.
Qed.

(* Peel one aggregate Efield at the eval_expr layer (used as expression). *)
Lemma eval_expr_Efield_peel :
  forall ge e le m a i ty loc o,
    (access_mode ty = By_reference \/ access_mode ty = By_copy) ->
    eval_expr ge e le m (Efield a i ty) (Vptr loc o) ->
    exists o0, eval_expr ge e le m a (Vptr loc o0).
Proof.
  intros ge e le m a i ty loc o Hmode H; inv H.
  match goal with
  | Hlv : eval_lvalue _ _ _ _ (Efield a i ty) ?b ?of ?bff,
    Hd  : deref_loc _ _ ?b ?of ?bff (Vptr loc o) |- _ =>
      cbn [typeof] in Hd;
      apply deref_loc_aggregate_block in Hd;
        [ subst; eapply eval_lvalue_Efield_base; exact Hlv | exact Hmode ]
  end.
Qed.

(* Peel one aggregate Ederef at the eval_expr layer. *)
Lemma eval_expr_Ederef_peel :
  forall ge e le m a ty loc o,
    (access_mode ty = By_reference \/ access_mode ty = By_copy) ->
    eval_expr ge e le m (Ederef a ty) (Vptr loc o) ->
    exists o0, eval_expr ge e le m a (Vptr loc o0).
Proof.
  intros ge e le m a ty loc o Hmode H; inv H.
  match goal with
  | Hlv : eval_lvalue _ _ _ _ (Ederef a ty) ?b ?of ?bff,
    Hd  : deref_loc _ _ ?b ?of ?bff (Vptr loc o) |- _ =>
      cbn [typeof] in Hd;
      apply deref_loc_aggregate_block in Hd;
        [ subst; apply eval_lvalue_Ederef_base in Hlv; eauto | exact Hmode ]
  end.
Qed.

(* STORE 1 geometry: its location block is whatever _t'49 holds. The chain is
   Efield(_flags) over three aggregate Efields (_node/_gfx/_header, all
   Tstruct = By_copy) over Ederef(Object) over Etempvar _t'49. *)
Lemma store1_loc_is_t49 :
  forall e le m loc ofs bf,
    eval_lvalue mario_ge e le m store1_lval loc ofs bf ->
    exists d, le ! mario._t'49 = Some (Vptr loc d).
Proof.
  unfold store1_lval. intros e le m loc ofs bf H.
  apply eval_lvalue_Efield_base in H as (?&H).
  apply eval_expr_Efield_peel in H as (?&H); [ | cbn; auto ].
  apply eval_expr_Efield_peel in H as (?&H); [ | cbn; auto ].
  apply eval_expr_Efield_peel in H as (?&H); [ | cbn; auto ].
  apply eval_expr_Ederef_peel in H as (?&H); [ | cbn; auto ].
  apply eval_expr_Etempvar_val in H. eauto.
Qed.

(* STORE 1 avoidance: if _t'49 is off bm, store 1 misses the action cell. *)
Lemma store1_avoids_action_cell :
  forall bm e le m loc ofs bf b d,
    le ! mario._t'49 = Some (Vptr b d) -> b <> bm ->
    eval_lvalue mario_ge e le m store1_lval loc ofs bf ->
    forall i, ~ action_cell bm loc i.
Proof.
  intros bm e le m loc ofs bf b d Hle Hne Hlv i [Hb _].
  apply store1_loc_is_t49 in Hlv as (d' & Hle').
  rewrite Hle in Hle'. inv Hle'. congruence.
Qed.

(* Store 2 adds array indexing: `base[43]` = Ederef(Ebinop Oadd base 43). The
   pointer arithmetic keeps the pointer operand's BLOCK -- adding an int to a
   pointer never changes its block. We need this only for base : array, idx :
   int, the add_case_pi shape. *)
Lemma sem_add_array_int_block :
  forall cenv v1 n m loc o,
    sem_binary_operation cenv Oadd v1 (tarray tint 80) (Vint n) tint m
      = Some (Vptr loc o) ->
    exists o1, v1 = Vptr loc o1.
Proof.
  intros cenv v1 n m loc o H. cbn in H.
  destruct v1; try discriminate. inv H. eauto.
Qed.

(* Clean single-conclusion inversions (each kills the spurious eval_Elvalue
   branch that inv on a non-lvalue eval_expr would otherwise leave). *)
Lemma eval_expr_Econst_int_val :
  forall ge e le m i ty v, eval_expr ge e le m (Econst_int i ty) v -> v = Vint i.
Proof.
  intros until v; intro H; inv H; auto.
  match goal with Hl : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ => inv Hl end.
Qed.

Lemma eval_expr_Ebinop_inv :
  forall ge e le m op a1 a2 ty v,
    eval_expr ge e le m (Ebinop op a1 a2 ty) v ->
    exists v1 v2,
      eval_expr ge e le m a1 v1 /\ eval_expr ge e le m a2 v2 /\
      sem_binary_operation ge op v1 (typeof a1) v2 (typeof a2) m = Some v.
Proof.
  intros until v; intro H; inv H.
  - eauto 7.
  - match goal with Hl : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ => inv Hl end.
Qed.

(* STORE 2 geometry: its location block is whatever _t'13 holds. Chain:
   Ederef(Ebinop Oadd (asS32[array] . rawData[union] . (Ederef _t'13)) 43). *)
Lemma store2_loc_is_t13 :
  forall e le m loc ofs bf,
    eval_lvalue mario_ge e le m store2_lval loc ofs bf ->
    exists d, le ! mario._t'13 = Some (Vptr loc d).
Proof.
  unfold store2_lval. intros e le m loc ofs bf H.
  apply eval_lvalue_Ederef_base in H.
  apply eval_expr_Ebinop_inv in H as (v1 & v2 & Hb & Hidx & Hsem).
  apply eval_expr_Econst_int_val in Hidx; subst v2.
  apply sem_add_array_int_block in Hsem as (?&?); subst v1.
  apply eval_expr_Efield_peel in Hb as (?&Hb); [ | cbn; auto ].   (* _asS32 : array  *)
  apply eval_expr_Efield_peel in Hb as (?&Hb); [ | cbn; auto ].   (* _rawData : union *)
  apply eval_expr_Ederef_peel in Hb as (?&Hb); [ | cbn; auto ].   (* Ederef Object   *)
  apply eval_expr_Etempvar_val in Hb. eauto.
Qed.

(* STORE 2 avoidance: if _t'13 is off bm, store 2 misses the action cell. *)
Lemma store2_avoids_action_cell :
  forall bm e le m loc ofs bf b d,
    le ! mario._t'13 = Some (Vptr b d) -> b <> bm ->
    eval_lvalue mario_ge e le m store2_lval loc ofs bf ->
    forall i, ~ action_cell bm loc i.
Proof.
  intros bm e le m loc ofs bf b d Hle Hne Hlv i [Hb _].
  apply store2_loc_is_t13 in Hlv as (d' & Hle').
  rewrite Hle in Hle'. inv Hle'. congruence.
Qed.

(* ================================================================== *)
(* ENGINE-PLUGGABLE FORM: each store satisfies assign_value_ok's BODY   *)
(* (its disjunction) GIVEN the base temp is off-bm. This is EXACTLY the  *)
(* obligation the value engine discharges at its Sassign case -- the     *)
(* future value(+)provenance engine supplies `le!_t = Vptr b d, b<>bm`   *)
(* from its tmps_off_bm invariant, and these lemmas close the goal via    *)
(* the AVOID disjunct. So the only thing between these and residual (3)    *)
(* being DISCHARGED is threading that provenance through the body exec.   *)
(* ================================================================== *)
Lemma store1_value_ok_offbm :
  forall bm e le m loc ofs bf v2 v b d,
    le ! mario._t'49 = Some (Vptr b d) -> b <> bm ->
    eval_lvalue mario_ge e le m store1_lval loc ofs bf ->
    eval_expr mario_ge e le m store1_rval v2 ->
    sem_cast v2 (typeof store1_rval) (typeof store1_lval) m = Some v ->
    (forall i, Ptrofs.unsigned ofs <= i < Ptrofs.unsigned ofs + sizeof mario_ge (typeof store1_lval) ->
               ~ action_cell bm loc i)
    \/ (loc = bm /\ Ptrofs.unsigned ofs = 12 /\ access_mode (typeof store1_lval) = By_value Mint32
        /\ bf = Full /\ exists w, v = Vint w /\ nonflying w).
Proof.
  intros bm e le m loc ofs bf v2 v b d Hle Hne Hlv _ _.
  left; intros i _. eapply store1_avoids_action_cell; eauto.
Qed.

Lemma store2_value_ok_offbm :
  forall bm e le m loc ofs bf v2 v b d,
    le ! mario._t'13 = Some (Vptr b d) -> b <> bm ->
    eval_lvalue mario_ge e le m store2_lval loc ofs bf ->
    eval_expr mario_ge e le m store2_rval v2 ->
    sem_cast v2 (typeof store2_rval) (typeof store2_lval) m = Some v ->
    (forall i, Ptrofs.unsigned ofs <= i < Ptrofs.unsigned ofs + sizeof mario_ge (typeof store2_lval) ->
               ~ action_cell bm loc i)
    \/ (loc = bm /\ Ptrofs.unsigned ofs = 12 /\ access_mode (typeof store2_lval) = By_value Mint32
        /\ bf = Full /\ exists w, v = Vint w /\ nonflying w).
Proof.
  intros bm e le m loc ofs bf v2 v b d Hle Hne Hlv _ _.
  left; intros i _. eapply store2_avoids_action_cell; eauto.
Qed.
