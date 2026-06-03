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

From compcert Require Import Coqlib Errors Maps AST Integers Values Events Memory
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

(* ---- Concrete genv layout: SM64 is ONE program, so these are facts, not
   universals. The MarioState composite + the marioObj field offset come
   straight from the clightgen'd composite env. ---- *)
Definition mario_ce : composite_env := prog_comp_env mario.prog.
Definition mario_members : members :=
  match mario_ce ! mario._MarioState with
  | Some co => co_members co
  | None => nil
  end.

(* The genv's composite env IS prog_comp_env. Proved for ABSTRACT p (a record
   projection, no materialization), then instantiated -- so it is fast, unlike
   `reflexivity`/`vm_compute` over genv_cenv mario_ge (which forces the whole
   composite env). Used to rewrite the eval-produced field offsets onto mario_ce
   (where field_offset is a cheap targeted lookup). *)
Lemma genv_cenv_globalenv : forall p, genv_cenv (globalenv p) = prog_comp_env p.
Proof. reflexivity. Qed.

Lemma cenv_eq : genv_cenv mario_ge = mario_ce.
Proof. unfold mario_ge, mario_ce. apply genv_cenv_globalenv. Qed.

(* marioObj memory well-formedness: gMarioState->marioObj loads a pointer into a
   block DISTINCT from Mario's own block bm. This is the honest CARRIED invariant
   (the marioObj pointer is wired up at init by render/graph code we don't trace);
   it is exactly what makes the body's two pointer-chase stores land off the
   action cell. NOT a `forall le` -- a concrete fact about one field of one
   struct in the real memory. *)
Definition marioObj_wf (m : mem) (bm : block) : Prop :=
  exists off bobj ofs,
    field_offset mario_ce mario._marioObj mario_members = OK (off, Full) /\
    Mem.loadv Mptr m (Vptr bm (Ptrofs.repr off)) = Some (Vptr bobj ofs) /\
    bobj <> bm /\
    (forall gb, Genv.find_symbol mario_ge mario._gMarioState = Some gb -> bobj <> gb).

(* gMarioState is a global POINTER; gMarioState_wf says it points to bm (the
   MarioState struct). So the action cell bm is the block the pointer targets --
   a carried fact about real memory, wired up at init. *)
Definition gMarioState_wf (m : mem) (bm : block) : Prop :=
  exists gb, Genv.find_symbol mario_ge mario._gMarioState = Some gb /\
             Mem.loadv Mptr m (Vptr gb Ptrofs.zero) = Some (Vptr bm Ptrofs.zero).

(* ---- the two concrete field-load eval bricks (the Sset RHS evaluations) ---- *)

(* deref_loc of an aggregate type returns the SAME (block, offset) it was given. *)
Lemma deref_loc_aggregate_eq :
  forall ty m b ofs bf loc o,
    (access_mode ty = By_reference \/ access_mode ty = By_copy) ->
    deref_loc ty m b ofs bf (Vptr loc o) -> loc = b /\ o = ofs.
Proof.
  intros ty m b ofs bf loc o Hmode H; inv H.
  - destruct Hmode as [Hm|Hm]; congruence.
  - auto.
  - auto.
  - match goal with Hlb : load_bitfield _ _ _ _ _ _ _ _ |- _ => inv Hlb end.
Qed.

(* `_t'48 = gMarioState` (a pointer-typed global var read) evaluates to Vptr bm 0,
   given gMarioState_wf and that the symbol isn't shadowed by a local. *)
Lemma eval_Evar_gMarioState_bm :
  forall e le m bm,
    e ! mario._gMarioState = None ->
    gMarioState_wf m bm ->
    eval_expr mario_ge e le m
      (Evar mario._gMarioState (tptr (Tstruct mario._MarioState noattr)))
      (Vptr bm Ptrofs.zero).
Proof.
  intros e le m bm He (gb & Hsym & Hload).
  eapply eval_Elvalue.
  - eapply eval_Evar_global; eauto.
  - eapply deref_loc_value with (chunk := Mptr); [ reflexivity | ].
    unfold Mem.loadv. exact Hload.
Qed.

(* The other field-load brick -- `_t'49 = _t'48->marioObj` evaluates off-bm --
   is `eval_marioObj_off_bm`, proved near the end of this file (it needs the
   abstract-ge eval helpers defined in the geometry section). It is built ENTIRELY
   from abstract-ge helper APPLICATIONS (never a direct `inv` over the concrete
   mario_ge, which is pathologically slow) -- so it compiles in <1s. *)

(* One real per-frame Mario update: a CompCert big-step of the actual
   f_execute_mario_action on an Object pointer. (The input is latched in
   memory; the value-engine preservation below holds for ANY input -- the
   no-A carve-out lives inside reach_value_preserves, not here.) *)
Definition execute_mario_action_step (m m' : mem) : Prop :=
  exists (b_o : block) (t : trace) (res : val),
    eval_funcall function_entry2 mario_ge m
      (Internal mario.f_execute_mario_action)
      (Vptr b_o Ptrofs.zero :: nil) t m' res.

(* a non-parameter temp keeps its base value through bind_parameter_temps:
   the only keys bind_parameter_temps writes are the formal parameters. *)
Lemma bind_parameter_temps_other :
  forall params vargs base le id,
    bind_parameter_temps params vargs base = Some le ->
    ~ In id (var_names params) ->
    le ! id = base ! id.
Proof.
  induction params as [|[p ty] ps IH]; intros vargs base le id Hbind Hnin; simpl in *.
  - destruct vargs; inv Hbind; reflexivity.
  - destruct vargs as [|v vs]; [ discriminate | ].
    apply Decidable.not_or in Hnin. destruct Hnin as (Hne & Hnin').
    erewrite IH; [ | exact Hbind | exact Hnin' ].
    rewrite PTree.gso; [ reflexivity | congruence ].
Qed.

(* ENTRY LIFT (concrete, no adversarial `forall le`): a whole eval_funcall of a
   no-stack-var function preserves whatever its BODY's exec_stmt preserves --
   AND it hands the body predicate the function-entry temp binding, so the
   caller can establish entry facts (e.g. tprov, vacuous at create_undef_temps).
   Trivial entry inversion: fn_vars=nil -> empty_env, free_list of nil is id. *)
Theorem funcall_from_body_preserves_entry :
  forall (P : mem -> Prop) (ge : genv) (f : function) vargs m m' t res,
    fn_vars f = nil ->
    (forall le mm tt le' mm' out,
       bind_parameter_temps (fn_params f) vargs (create_undef_temps (fn_temps f)) = Some le ->
       P mm ->
       exec_stmt function_entry2 ge empty_env le mm (fn_body f) tt le' mm' out ->
       P mm') ->
    P m ->
    eval_funcall function_entry2 ge m (Internal f) vargs t m' res ->
    P m'.
Proof.
  intros P ge f vargs m m' t res Hvars Hbody HP Hfun.
  inv Hfun.
  match goal with Hfe : function_entry2 _ _ _ _ _ _ _ |- _ => inv Hfe end.
  match goal with Hav : alloc_variables _ _ _ _ _ _ |- _ =>
    rewrite Hvars in Hav; inv Hav end.
  match goal with
  | Hexec : exec_stmt function_entry2 ge empty_env ?le _ (fn_body f) _ _ _ _,
    Hbind : bind_parameter_temps _ _ _ = Some ?le |- _ =>
      assert (HP2 : P _) by (eapply Hbody; [ exact Hbind | exact HP | exact Hexec ])
  end.
  match goal with Hfree : Mem.free_list _ _ = Some _ |- _ =>
    assert (Hbe : blocks_of_env ge empty_env = nil) by reflexivity;
    rewrite Hbe in Hfree; cbn [Mem.free_list] in Hfree; inv Hfree end.
  exact HP2.
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

(* ================================================================== *)
(* THE Sassign CASE of the augmented engine, at the EXECUTION level.    *)
(* Executing either real store, from a state where its base temp is     *)
(* off-bm, preserves (valid bm /\ action_sat nonflying). This is the     *)
(* concrete-execution discharge of the body's two writes -- no `forall   *)
(* le`: le is the one the real run produced, with _t'49/_t'13 holding     *)
(* the marioObj pointer. Consumes the geometry/avoidance bricks. *)
Lemma store1_exec_preserves :
  forall bm e le m t le' m' out b d,
    le ! mario._t'49 = Some (Vptr b d) -> b <> bm ->
    Mem.valid_block m bm -> action_sat nonflying m bm ->
    exec_stmt function_entry2 mario_ge e le m (Sassign store1_lval store1_rval) t le' m' out ->
    Mem.valid_block m' bm /\ action_sat nonflying m' bm.
Proof.
  intros bm e le m t le' m' out b d Hle Hne Hv Hsat Hexec.
  inv Hexec.
  match goal with
  | Hlv : eval_lvalue _ _ _ _ store1_lval ?loc ?ofs ?bf,
    Has : assign_loc _ _ _ ?loc ?ofs ?bf _ _ |- _ =>
      split;
      [ eapply assign_loc_valid_block; [ exact Has | exact Hv ]
      | eapply assign_loc_action_sat_avoid;
          [ exact Has | exact Hv | | exact Hsat ];
          intros i _; eapply store1_avoids_action_cell;
          [ exact Hle | exact Hne | exact Hlv ] ]
  end.
Qed.

Lemma store2_exec_preserves :
  forall bm e le m t le' m' out b d,
    le ! mario._t'13 = Some (Vptr b d) -> b <> bm ->
    Mem.valid_block m bm -> action_sat nonflying m bm ->
    exec_stmt function_entry2 mario_ge e le m (Sassign store2_lval store2_rval) t le' m' out ->
    Mem.valid_block m' bm /\ action_sat nonflying m' bm.
Proof.
  intros bm e le m t le' m' out b d Hle Hne Hv Hsat Hexec.
  inv Hexec.
  match goal with
  | Hlv : eval_lvalue _ _ _ _ store2_lval ?loc ?ofs ?bf,
    Has : assign_loc _ _ _ ?loc ?ofs ?bf _ _ |- _ =>
      split;
      [ eapply assign_loc_valid_block; [ exact Has | exact Hv ]
      | eapply assign_loc_action_sat_avoid;
          [ exact Has | exact Hv | | exact Hsat ];
          intros i _; eapply store2_avoids_action_cell;
          [ exact Hle | exact Hne | exact Hlv ] ]
  end.
Qed.

(* ================================================================== *)
(* THE marioObj FIELD-LOAD BRICK (fast: abstract-ge helpers only).      *)
(*                                                                     *)
(* `_t'49 = _t'48->marioObj` (with _t'48 = Vptr bm 0) evaluates to an    *)
(* off-bm pointer, by marioObj_wf. The proof NEVER inverts an eval       *)
(* relation at the concrete mario_ge (that is minutes-slow); it applies  *)
(* abstract-ge inversion helpers, then matches the eval-produced field   *)
(* offset onto mario_ce via cenv_eq (a cheap targeted field_offset).     *)
(* ================================================================== *)

(* split eval_expr of a By_value Efield into its lvalue + the load. *)
Lemma eval_expr_Efield_load :
  forall ge e le m a i ty v,
    eval_expr ge e le m (Efield a i ty) v ->
    exists loc ofs bf,
      eval_lvalue ge e le m (Efield a i ty) loc ofs bf /\ deref_loc ty m loc ofs bf v.
Proof. intros ge e le m a i ty v H; inv H; do 3 eexists; eauto. Qed.

Lemma eval_expr_Ederef_load :
  forall ge e le m a ty v,
    eval_expr ge e le m (Ederef a ty) v ->
    exists loc ofs bf,
      eval_lvalue ge e le m (Ederef a ty) loc ofs bf /\ deref_loc ty m loc ofs bf v.
Proof. intros ge e le m a ty v H; inv H; do 3 eexists; eauto. Qed.

(* invert an Efield lvalue into its base eval + the field offset (struct/union). *)
Lemma eval_lvalue_Efield_inv :
  forall ge e le m a i ty loc ofs bf,
    eval_lvalue ge e le m (Efield a i ty) loc ofs bf ->
    exists o0 id att co delta,
      eval_expr ge e le m a (Vptr loc o0) /\
      (genv_cenv ge) ! id = Some co /\
      ofs = Ptrofs.add o0 (Ptrofs.repr delta) /\
      ( (typeof a = Tstruct id att /\ field_offset (genv_cenv ge) i (co_members co) = OK (delta, bf))
        \/ (typeof a = Tunion id att /\ union_field_offset (genv_cenv ge) i (co_members co) = OK (delta, bf)) ).
Proof.
  intros ge e le m a i ty loc ofs bf H; inv H.
  - do 5 eexists; repeat split; try eassumption. left; split; eassumption.
  - do 5 eexists; repeat split; try eassumption. right; split; eassumption.
Qed.

Lemma eval_marioObj_off_bm :
  forall stid e le m bm bobj o,
    (forall b o', le ! stid = Some (Vptr b o') -> b = bm /\ o' = Ptrofs.zero) ->
    marioObj_wf m bm ->
    eval_expr mario_ge e le m
      (Efield (Ederef (Etempvar stid (tptr (Tstruct mario._MarioState noattr)))
                      (Tstruct mario._MarioState noattr))
              mario._marioObj (tptr (Tstruct mario._Object noattr)))
      (Vptr bobj o) ->
    bobj <> bm /\ (forall gb, Genv.find_symbol mario_ge mario._gMarioState = Some gb -> bobj <> gb).
Proof.
  intros stid e le m bm bobj o Ht48 (off & bobj0 & ofs0w & Hfo & Hload & Hne & Hng) Hev.
  apply eval_expr_Efield_load in Hev as (loc & ofs & bf & Hlv & Hderef).
  apply eval_lvalue_Efield_inv in Hlv as (o0 & id & att & co & delta & Hbase & Hco & Hofs & Hcase).
  apply eval_expr_Ederef_load in Hbase as (lb & ob & bfb & Hlvb & Hderefb).
  apply deref_loc_aggregate_eq in Hderefb as [? ?]; [ | right; reflexivity ]. subst lb ob.
  apply eval_lvalue_Ederef_base in Hlvb.
  apply eval_expr_Etempvar_val in Hlvb. destruct (Ht48 _ _ Hlvb) as [Hl Ho]. subst.
  destruct Hcase as [ (Hty & Hfo2) | (Hty & Hfo2) ]; [ | cbn in Hty; discriminate ].
  cbn in Hty; inv Hty.
  rewrite cenv_eq in Hco, Hfo2.
  assert (Hmm : mario_members = co_members co)
    by (unfold mario_members; rewrite Hco; reflexivity).
  rewrite Hmm in Hfo. rewrite Hfo in Hfo2. inv Hfo2.
  rewrite Ptrofs.add_zero_l in Hderef.
  inv Hderef;
    try (match goal with Hac : access_mode _ = By_reference |- _ => cbn in Hac; discriminate end);
    try (match goal with Hac : access_mode _ = By_copy |- _ => cbn in Hac; discriminate end);
    try (match goal with Hlb : load_bitfield _ _ _ _ _ _ _ _ |- _ => inv Hlb end);
    match goal with
    | Hac : access_mode _ = By_value ?chunk,
      Hlv3 : Mem.loadv ?chunk _ _ = Some (Vptr bobj o) |- _ =>
        cbn in Hac; inv Hac; rewrite Hlv3 in Hload; inv Hload; split; [ exact Hne | exact Hng ]
    end.
Qed.

(* ================================================================== *)
(* PER-Sset PROVENANCE ESTABLISHMENT (the temp-defining steps).         *)
(*                                                                     *)
(* The body sets the four tracked temps only in two shapes:             *)
(*   `t = gMarioState`        -> t holds Vptr bm 0   (sset_gms_bm)       *)
(*   `t = stid->marioObj`     -> t holds an off-bm ptr (sset_marioObj)   *)
(* Both are proved by APPLYING the eval bricks (no slow inv at mario_ge).*)
(* These are what the augmented engine uses to re-establish the temp-    *)
(* provenance invariant across the body's Ssets.                        *)
(* ================================================================== *)

Lemma eval_expr_Evar_load :
  forall ge e le m id ty v,
    eval_expr ge e le m (Evar id ty) v ->
    exists loc ofs bf, eval_lvalue ge e le m (Evar id ty) loc ofs bf /\ deref_loc ty m loc ofs bf v.
Proof. intros ge e le m id ty v H; inv H; do 3 eexists; eauto. Qed.

Lemma eval_lvalue_Evar_global_loc :
  forall ge e le m id ty loc ofs bf,
    e ! id = None ->
    eval_lvalue ge e le m (Evar id ty) loc ofs bf ->
    Genv.find_symbol ge id = Some loc /\ ofs = Ptrofs.zero.
Proof. intros ge e le m id ty loc ofs bf He H; inv H; [ congruence | auto ]. Qed.

(* `t = gMarioState` makes t hold Vptr bm 0. *)
Lemma sset_gms_bm :
  forall tid e le m t le' m' out bm,
    e ! mario._gMarioState = None ->
    gMarioState_wf m bm ->
    exec_stmt function_entry2 mario_ge e le m
      (Sset tid (Evar mario._gMarioState (tptr (Tstruct mario._MarioState noattr)))) t le' m' out ->
    le' ! tid = Some (Vptr bm Ptrofs.zero).
Proof.
  intros tid e le m t le' m' out bm He (gb & Hsym & Hload) H. inv H.
  match goal with Hev : eval_expr _ _ _ _ (Evar _ _) _ |- _ =>
    apply eval_expr_Evar_load in Hev as (loc & ofs & bf & Hlv & Hd) end.
  apply eval_lvalue_Evar_global_loc in Hlv as [Hfs Hofs]; [ | exact He ].
  assert (loc = gb) by congruence. subst.
  inv Hd;
    try (match goal with Hac : access_mode _ = By_reference |- _ => cbn in Hac; discriminate end);
    try (match goal with Hac : access_mode _ = By_copy |- _ => cbn in Hac; discriminate end);
    try (match goal with Hlb : load_bitfield _ _ _ _ _ _ _ _ |- _ => inv Hlb end).
  match goal with
  | Hac : access_mode _ = By_value ?chunk, Hl : Mem.loadv ?chunk _ _ = _ |- _ =>
      cbn in Hac; inv Hac; rewrite Hl in Hload; inv Hload
  end.
  rewrite PTree.gss; reflexivity.
Qed.

(* `t = stid->marioObj` (stid = Vptr bm 0) makes t hold an off-{bm,gb} pointer. *)
Lemma sset_marioObj_offbm :
  forall tid stid e le m t le' m' out bm gb,
    Genv.find_symbol mario_ge mario._gMarioState = Some gb ->
    (forall b o', le ! stid = Some (Vptr b o') -> b = bm /\ o' = Ptrofs.zero) ->
    marioObj_wf m bm ->
    exec_stmt function_entry2 mario_ge e le m
      (Sset tid (Efield (Ederef (Etempvar stid (tptr (Tstruct mario._MarioState noattr)))
                                (Tstruct mario._MarioState noattr))
                        mario._marioObj (tptr (Tstruct mario._Object noattr)))) t le' m' out ->
    forall b o, le' ! tid = Some (Vptr b o) -> b <> bm /\ b <> gb.
Proof.
  intros tid stid e le m t le' m' out bm gb Hgb Hstid Hwf H b o Hle'. inv H.
  rewrite PTree.gss in Hle'. inv Hle'.
  match goal with Hev : eval_expr _ _ _ _ _ (Vptr b o) |- _ =>
    pose proof (eval_marioObj_off_bm _ _ _ _ _ _ _ Hstid Hwf Hev) as [Hbm Hgbfn] end.
  split; [ exact Hbm | exact (Hgbfn gb Hgb) ].
Qed.

(* ================================================================== *)
(* THE AUGMENTED ENGINE (value + temp-provenance), for body_preserves. *)
(*                                                                     *)
(* The value engine alone cannot discharge the body (its two stores go  *)
(* through off-bm temps, which assign_value_ok's `forall le` cannot see).*)
(* This engine threads, alongside action_sat, a memory invariant        *)
(* (marioObj_wf, gMarioState_wf) and a temp-provenance invariant, and    *)
(* dispatches the two stores to the geometry lemmas. Built bottom-up;    *)
(* the Sassign case (both stores) is below.                             *)
(* ================================================================== *)

(* a successful loadv witnesses a valid block. *)
Lemma loadv_valid_block : forall chunk m b o v,
  Mem.loadv chunk m (Vptr b o) = Some v -> Mem.valid_block m b.
Proof.
  intros chunk m b o v H. unfold Mem.loadv in H. apply Mem.load_valid_access in H.
  destruct H as [Hrp _]. eapply Mem.perm_valid_block.
  apply (Hrp (Ptrofs.unsigned o)). generalize (size_chunk_pos chunk); lia.
Qed.

(* a store to block loc leaves a loadv at any OTHER block unchanged. *)
Lemma assign_loc_off_loadv :
  forall ce ty m loc ofs bf v m' bp op chunk vv,
    assign_loc ce ty m loc ofs bf v m' ->
    bp <> loc -> Mem.valid_block m bp ->
    Mem.loadv chunk m (Vptr bp op) = Some vv ->
    Mem.loadv chunk m' (Vptr bp op) = Some vv.
Proof.
  intros ce ty m loc ofs bf v m' bp op chunk vv Has Hne Hval Hld.
  assert (U : Mem.unchanged_on (fun b _ => b = bp) m m')
    by (eapply assign_loc_unchanged_on; [ exact Has | intros i _ Heq; congruence ]).
  unfold Mem.loadv in *.
  erewrite Mem.load_unchanged_on_1; [ exact Hld | exact U | exact Hval | intros i _; reflexivity ].
Qed.

Section ProvEngine.
  Variable bm gb : block.
  Hypothesis Hgb : Genv.find_symbol mario_ge mario._gMarioState = Some gb.

  (* the carried memory invariant: bm valid, action non-flying, and the two
     Mario pointers well-formed (marioObj off-bm, gMarioState -> bm). *)
  Definition meminv (m : mem) : Prop :=
    Mem.valid_block m bm /\ action_sat nonflying m bm /\
    marioObj_wf m bm /\ gMarioState_wf m bm.

  (* temp-provenance: a temp holds either nothing-relevant or an off-{bm,gb} ptr
     (the marioObj chase temps), resp. exactly Vptr bm 0 (the gMarioState temps). *)
  Definition toff (le : temp_env) (t : ident) : Prop :=
    forall b o, le ! t = Some (Vptr b o) -> b <> bm /\ b <> gb.
  Definition tat (le : temp_env) (t : ident) : Prop :=
    forall b o, le ! t = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero.

  (* THE Sassign CASE: a body store (store1 or store2) preserves meminv. Its
     location is its base temp's block (geometry), which is off {bm,gb} (toff),
     so the action cell, the marioObj field, and the gMarioState pointer are all
     left unchanged; action_sat survives via the avoid disjunct. *)
  Lemma store_preserves_meminv :
    forall a1 a2 (tid : ident)
      (Hgeom : forall e le m loc ofs bf,
         eval_lvalue mario_ge e le m a1 loc ofs bf -> exists d, le ! tid = Some (Vptr loc d)),
    forall e le m t le' m' out,
      meminv m -> toff le tid ->
      exec_stmt function_entry2 mario_ge e le m (Sassign a1 a2) t le' m' out ->
      meminv m'.
  Proof.
    intros a1 a2 tid Hgeom e le m t le' m' out (Hv & Hsat & Hmwf & Hgwf) Hoff Hexec. inv Hexec.
    match goal with H : eval_lvalue _ _ _ _ a1 _ _ _ |- _ => rename H into Hlv end.
    match goal with H : assign_loc _ _ _ _ _ _ _ _ |- _ => rename H into Has end.
    apply Hgeom in Hlv as (d & Htmp). destruct (Hoff _ _ Htmp) as [Hnbm Hngb].
    split; [ eapply assign_loc_valid_block; [ exact Has | exact Hv ] | ].
    split; [ eapply assign_loc_action_sat_avoid; [ exact Has | exact Hv | intros i _ [Hb _]; congruence | exact Hsat ] | ].
    split.
    - destruct Hmwf as (off & bobj & ofs0 & Hfo & Hldv & Hbobj & Hng).
      exists off, bobj, ofs0. split; [ exact Hfo | ].
      split; [ | split; [ exact Hbobj | exact Hng ] ].
      eapply assign_loc_off_loadv; [ exact Has | exact (not_eq_sym Hnbm) | exact Hv | exact Hldv ].
    - destruct Hgwf as (gb' & Hsym & Hldv). assert (gb' = gb) by congruence. subst gb'.
      exists gb. split; [ exact Hsym | ].
      eapply assign_loc_off_loadv; [ exact Has | exact (not_eq_sym Hngb) | eapply loadv_valid_block; exact Hldv | exact Hldv ].
  Qed.

  (* the full temp-provenance invariant over the four tracked temps. *)
  Definition tprov (le : temp_env) : Prop :=
    tat le mario._t'48 /\ tat le mario._t'12 /\ toff le mario._t'49 /\ toff le mario._t'13.

  (* the two RHS shapes the body uses to set tracked temps. *)
  Definition gms_expr : expr :=
    Evar mario._gMarioState (tptr (Tstruct mario._MarioState noattr)).
  Definition marioObj_expr (stid : ident) : expr :=
    Efield (Ederef (Etempvar stid (tptr (Tstruct mario._MarioState noattr)))
                   (Tstruct mario._MarioState noattr))
           mario._marioObj (tptr (Tstruct mario._Object noattr)).

  (* per-Sset check: each tracked temp, if set here, is set to its expected RHS.
     For untracked temps all four implications are vacuous. *)
  Definition prov_sset_ok (id : ident) (a : expr) : Prop :=
    (id = mario._t'48 -> a = gms_expr) /\
    (id = mario._t'12 -> a = gms_expr) /\
    (id = mario._t'49 -> a = marioObj_expr mario._t'48) /\
    (id = mario._t'13 -> a = marioObj_expr mario._t'12).

  (* THE Sset CASE: memory is untouched (so meminv trivially survives); the
     provenance invariant is re-established by the sset_* lemmas for a tracked
     temp, or preserved by PTree.gso for an untracked one. *)
  Lemma sset_case_preserves :
    forall e le m id a t le' m' out,
      e ! mario._gMarioState = None ->
      meminv m -> tprov le -> prov_sset_ok id a ->
      exec_stmt function_entry2 mario_ge e le m (Sset id a) t le' m' out ->
      meminv m' /\ tprov le'.
  Proof.
    intros e le m id a t le' m' out He Hmem Htp Hck Hexec.
    inversion Hexec; subst.
    split; [ exact Hmem | ].
    destruct Hmem as (Hv & Hsat & Hmwf & Hgwf).
    destruct Htp as (T48 & T12 & T49 & T13).
    destruct Hck as (C48 & C12 & C49 & C13).
    unfold tprov; split; [ | split; [ | split ] ].
    (* each tracked temp: re-established here (sset lemma) or preserved (gso) *)
    - unfold tat. intros bb oo Hs. destruct (Pos.eq_dec id mario._t'48) as [E|N].
      + subst id. rewrite (C48 eq_refl) in Hexec.
        rewrite (sset_gms_bm _ _ _ _ _ _ _ _ _ He Hgwf Hexec) in Hs. inv Hs; auto.
      + rewrite PTree.gso in Hs by congruence. exact (T48 _ _ Hs).
    - unfold tat. intros bb oo Hs. destruct (Pos.eq_dec id mario._t'12) as [E|N].
      + subst id. rewrite (C12 eq_refl) in Hexec.
        rewrite (sset_gms_bm _ _ _ _ _ _ _ _ _ He Hgwf Hexec) in Hs. inv Hs; auto.
      + rewrite PTree.gso in Hs by congruence. exact (T12 _ _ Hs).
    - unfold toff. intros bb oo Hs. destruct (Pos.eq_dec id mario._t'49) as [E|N].
      + subst id. rewrite (C49 eq_refl) in Hexec.
        eapply sset_marioObj_offbm; [ exact Hgb | exact T48 | exact Hmwf | exact Hexec | exact Hs ].
      + rewrite PTree.gso in Hs by congruence. exact (T49 _ _ Hs).
    - unfold toff. intros bb oo Hs. destruct (Pos.eq_dec id mario._t'13) as [E|N].
      + subst id. rewrite (C13 eq_refl) in Hexec.
        eapply sset_marioObj_offbm; [ exact Hgb | exact T12 | exact Hmwf | exact Hexec | exact Hs ].
      + rewrite PTree.gso in Hs by congruence. exact (T13 _ _ Hs).
  Qed.

  (* a call/builtin result temp that is none of the tracked temps. *)
  Definition optid_untracked (oid : option ident) : Prop :=
    forall id, oid = Some id ->
      id <> mario._t'48 /\ id <> mario._t'12 /\ id <> mario._t'49 /\ id <> mario._t'13.

  (* setting an untracked result temp preserves the provenance invariant. *)
  Lemma tprov_set_opttemp :
    forall oid v le, optid_untracked oid -> tprov le -> tprov (set_opttemp oid v le).
  Proof.
    intros oid v le Hut (T48 & T12 & T49 & T13). destruct oid as [id|]; [ | exact (conj T48 (conj T12 (conj T49 T13))) ].
    destruct (Hut id eq_refl) as (N48 & N12 & N49 & N13).
    unfold set_opttemp, tprov. split; [ | split; [ | split ] ];
      [ unfold tat | unfold tat | unfold toff | unfold toff ];
      intros bb oo Hs; rewrite PTree.gso in Hs by congruence;
      first [ exact (T48 _ _ Hs) | exact (T12 _ _ Hs) | exact (T49 _ _ Hs) | exact (T13 _ _ Hs) ].
  Qed.

  (* the per-statement check: stores are the two body stores; tracked-temp Ssets
     have their expected RHS; call/builtin result temps are untracked. *)
  Fixpoint prov_ok (s : statement) : Prop :=
    match s with
    | Sassign a1 a2 => (a1 = store1_lval /\ a2 = store1_rval) \/ (a1 = store2_lval /\ a2 = store2_rval)
    | Sset id a => prov_sset_ok id a
    | Scall oid _ _ => optid_untracked oid
    | Sbuiltin oid _ _ _ => optid_untracked oid
    | Ssequence s1 s2 => prov_ok s1 /\ prov_ok s2
    | Sifthenelse _ s1 s2 => prov_ok s1 /\ prov_ok s2
    | Sloop s1 s2 => prov_ok s1 /\ prov_ok s2
    | Slabel _ s1 => prov_ok s1
    | Sswitch _ ls => prov_ok_ls ls
    | _ => True
    end
  with prov_ok_ls (ls : labeled_statements) : Prop :=
    match ls with
    | LSnil => True
    | LScons _ s rest => prov_ok s /\ prov_ok_ls rest
    end.

  (* ================================================================== *)
  (* Switch-case helpers: select_switch / seq_of_labeled_statement      *)
  (* preserve prov_ok (genv-free, structural). Mirrors the analogous     *)
  (* *_value_ok lemmas in ActionValueFrame.                              *)
  (* ================================================================== *)
  Lemma ssd_prov_ok : forall sl, prov_ok_ls sl -> prov_ok_ls (select_switch_default sl).
  Proof.
    clear Hgb.
    induction sl as [| o s rest IH]; simpl; intros H; auto.
    destruct o as [c|]; simpl; [ destruct H as [_ Hr]; apply IH; exact Hr | exact H ].
  Qed.

  Lemma ssc_prov_ok : forall n sl res,
    prov_ok_ls sl -> select_switch_case n sl = Some res -> prov_ok_ls res.
  Proof.
    clear Hgb.
    induction sl as [| o s rest IH]; simpl; intros res Hav Hsel; try discriminate.
    destruct Hav as [Hs Hr]. destruct o as [c|]; simpl in Hsel.
    - destruct (zeq c n).
      + inv Hsel. simpl. split; [ exact Hs | exact Hr ].
      + exact (IH res Hr Hsel).
    - exact (IH res Hr Hsel).
  Qed.

  Lemma seq_of_prov_ok : forall ls, prov_ok_ls ls -> prov_ok (seq_of_labeled_statement ls).
  Proof.
    clear Hgb.
    induction ls as [| o s rest IH]; simpl; intros H; auto. destruct H. split; auto.
  Qed.

  Lemma select_switch_prov_ok : forall n sl,
    prov_ok_ls sl -> prov_ok_ls (select_switch n sl).
  Proof.
    clear Hgb.
    intros n sl H. unfold select_switch.
    destruct (select_switch_case n sl) eqn:E.
    - exact (ssc_prov_ok n sl l H E).
    - apply ssd_prov_ok; exact H.
  Qed.

  (* ================================================================== *)
  (* THE GENERIC ENGINE: the structural exec_stmt induction run over an   *)
  (* ABSTRACT ge / e / P. This is the performance win -- the induction    *)
  (* never hauls the concrete mario_ge / meminv around, so its 16 cases   *)
  (* are trivial. The leaf cases (Sassign/Sset/Scall/Sbuiltin) are        *)
  (* delegated to abstract per-case hypotheses; the structural cases      *)
  (* thread P via the induction hypotheses, decomposing prov_ok.          *)
  (* ================================================================== *)
  Lemma body_prov_generic :
    forall (ge : genv) (e : env) (P : mem -> temp_env -> Prop),
      (forall le m a1 a2 t le' m' out,
         P m le -> prov_ok (Sassign a1 a2) ->
         exec_stmt function_entry2 ge e le m (Sassign a1 a2) t le' m' out -> P m' le') ->
      (forall le m id a t le' m' out,
         P m le -> prov_ok (Sset id a) ->
         exec_stmt function_entry2 ge e le m (Sset id a) t le' m' out -> P m' le') ->
      (forall le m oid a al t le' m' out,
         P m le -> prov_ok (Scall oid a al) ->
         exec_stmt function_entry2 ge e le m (Scall oid a al) t le' m' out -> P m' le') ->
      (forall le m oid ef tyl al t le' m' out,
         P m le -> prov_ok (Sbuiltin oid ef tyl al) ->
         exec_stmt function_entry2 ge e le m (Sbuiltin oid ef tyl al) t le' m' out -> P m' le') ->
      forall le m s t le' m' out,
        exec_stmt function_entry2 ge e le m s t le' m' out -> P m le -> prov_ok s -> P m' le'.
  Proof.
    clear Hgb.
    intros ge e P HA HS HC HB le m s t le' m' out H.
    induction H; intros HP Hck; cbn [prov_ok prov_ok_ls] in Hck;
      repeat match goal with
             | IH : (forall _ _ _ _ _ _ _ _, P _ _ -> _) -> _ |- _ =>
                 specialize (IH HA HS HC HB)
             end.
    - (* Sskip *) exact HP.
    - (* Sassign *) eapply HA; [ exact HP | cbn [prov_ok]; exact Hck | solve [ econstructor; eauto ] ].
    - (* Sset *) eapply HS; [ exact HP | cbn [prov_ok]; exact Hck | solve [ econstructor; eauto ] ].
    - (* Scall *) eapply HC; [ exact HP | cbn [prov_ok]; exact Hck | solve [ econstructor; eauto ] ].
    - (* Sbuiltin *) eapply HB; [ exact HP | cbn [prov_ok]; exact Hck | solve [ econstructor; eauto ] ].
    - (* Sseq normal *) destruct Hck as [Hck1 Hck2]. apply IHexec_stmt2; [ apply IHexec_stmt1; assumption | exact Hck2 ].
    - (* Sseq abnormal *) destruct Hck as [Hck1 _]. apply IHexec_stmt; [ exact HP | exact Hck1 ].
    - (* Sifthenelse *) destruct Hck as [Hck1 Hck2]. apply IHexec_stmt; [ exact HP | destruct b; assumption ].
    - (* Sreturn none *) exact HP.
    - (* Sreturn some *) exact HP.
    - (* Sbreak *) exact HP.
    - (* Scontinue *) exact HP.
    - (* Sloop stop1 *) destruct Hck as [Hck1 _]. apply IHexec_stmt; [ exact HP | exact Hck1 ].
    - (* Sloop stop2 *) destruct Hck as [Hck1 Hck2].
      apply IHexec_stmt2; [ apply IHexec_stmt1; assumption | exact Hck2 ].
    - (* Sloop loop *) destruct Hck as [Hck1 Hck2].
      apply IHexec_stmt3; [ apply IHexec_stmt2; [ apply IHexec_stmt1; assumption | exact Hck2 ]
                          | cbn [prov_ok]; split; assumption ].
    - (* Sswitch *) apply IHexec_stmt; [ exact HP | apply seq_of_prov_ok; apply select_switch_prov_ok; exact Hck ].
  Qed.

  (* ================================================================== *)
  (* THE NO-A-THREADED REACH RESIDUALS. The unconditional `meminv m ->     *)
  (* meminv m'` for every reached funcall is FALSE: set_mario_action with   *)
  (* an ACT_FLYING argument is a reached eval_funcall that breaks action_sat.*)
  (* So the engine carries the no-A predicate NoA in its invariant and uses *)
  (* the NO-A-CONDITIONED form -- the one a no-A frame can actually supply.  *)
  (* The capstone builds reach_meminv_noA from the sharp action-cell        *)
  (* decomposition (reach_nonwriter + reach_writer_noA, preserving valid +   *)
  (* action_sat) PLUS the struct/NoA reach pieces; see reach_meminv_noA_build*)
  (* below. NoA is threaded only so it is available at each reached call --   *)
  (* the capstone discards the output NoA m'.                                *)
  (* ================================================================== *)
  Variable NoA : mem -> Prop.

  Hypothesis reach_meminv_noA :
    forall m fd vargs t m' vres,
      NoA m -> meminv m ->
      eval_funcall function_entry2 mario_ge m fd vargs t m' vres ->
      NoA m' /\ meminv m'.
  Hypothesis ext_meminv_noA :
    forall ef vargs m t vres m',
      NoA m -> meminv m ->
      external_call ef mario_ge vargs m t vres m' ->
      NoA m' /\ meminv m'.
  (* the body's two off-bm stores (store1/store2, certified by the census)
     leave the controller bytes NoA reads alone. *)
  Hypothesis noA_store_pres :
    forall e le m a1 a2 t le' m' out,
      NoA m -> prov_ok (Sassign a1 a2) ->
      exec_stmt function_entry2 mario_ge e le m (Sassign a1 a2) t le' m' out ->
      NoA m'.

  (* ================================================================== *)
  (* THE ENGINE over mario_ge with P = NoA /\ meminv /\ tprov. Same        *)
  (* body_prov_generic instantiation as before, now carrying NoA; the leaf  *)
  (* facts are the committed per-case lemmas + the NoA-conditioned reach.   *)
  (* ================================================================== *)
  Theorem exec_body_prov_noA :
    forall e le m s t le' m' out,
      e ! mario._gMarioState = None ->
      exec_stmt function_entry2 mario_ge e le m s t le' m' out ->
      NoA m -> meminv m -> tprov le -> prov_ok s ->
      NoA m' /\ meminv m' /\ tprov le'.
  Proof.
    intros e le m s t le' m' out He H Hno Hmem Htp Hck.
    apply (body_prov_generic mario_ge e (fun mm ll => NoA mm /\ meminv mm /\ tprov ll))
      with (le := le) (m := m) (s := s) (t := t) (le' := le') (m' := m') (out := out);
      try assumption; try (split; [ exact Hno | split; assumption ]).
    - (* Sassign leaf *)
      clear He reach_meminv_noA ext_meminv_noA Hmem Htp Hck H Hno le m s t le' m' out.
      intros le0 m0 a1 a2 t0 le0' m0' out0 (Hno0 & Hmem0 & Htp0) Hck' Hexec.
      assert (Hle : le0' = le0) by (inversion Hexec; reflexivity). subst le0'.
      split; [ eapply noA_store_pres; [ exact Hno0 | exact Hck' | exact Hexec ] | ].
      split; [ | exact Htp0 ].
      cbn [prov_ok] in Hck'.
      destruct Htp0 as (T48 & T12 & T49 & T13).
      destruct Hck' as [ [Ha1 Ha2] | [Ha1 Ha2] ]; subst.
      + eapply (store_preserves_meminv store1_lval store1_rval mario._t'49 store1_loc_is_t49);
          [ exact Hmem0 | exact T49 | exact Hexec ].
      + eapply (store_preserves_meminv store2_lval store2_rval mario._t'13 store2_loc_is_t13);
          [ exact Hmem0 | exact T13 | exact Hexec ].
    - (* Sset leaf *)
      clear reach_meminv_noA ext_meminv_noA noA_store_pres Hmem Htp Hck H Hno le m s t le' m' out.
      intros le0 m0 id a t0 le0' m0' out0 (Hno0 & Hmem0 & Htp0) Hck' Hexec.
      cbn [prov_ok] in Hck'.
      assert (Hm : m0' = m0) by (inversion Hexec; reflexivity).
      split; [ rewrite Hm; exact Hno0 | ].
      eapply sset_case_preserves; [ exact He | exact Hmem0 | exact Htp0 | exact Hck' | exact Hexec ].
    - (* Scall leaf *)
      clear He ext_meminv_noA noA_store_pres Hgb Hmem Htp Hck H Hno le m s t le' m' out.
      intros le0 m0 oid a al t0 le0' m0' out0 (Hno0 & Hmem0 & Htp0) Hck' Hexec.
      cbn [prov_ok] in Hck'.
      inversion Hexec; subst.
      match goal with Hf : eval_funcall _ _ _ _ _ _ _ _ |- _ =>
        destruct (reach_meminv_noA _ _ _ _ _ _ Hno0 Hmem0 Hf) as (Hno0' & Hmem0') end.
      split; [ exact Hno0' | split; [ exact Hmem0' | apply tprov_set_opttemp; assumption ] ].
    - (* Sbuiltin leaf *)
      clear He reach_meminv_noA noA_store_pres Hgb Hmem Htp Hck H Hno le m s t le' m' out.
      intros le0 m0 oid ef tyl al t0 le0' m0' out0 (Hno0 & Hmem0 & Htp0) Hck' Hexec.
      cbn [prov_ok] in Hck'.
      inversion Hexec; subst.
      match goal with Hec : external_call _ _ _ _ _ _ _ |- _ =>
        destruct (ext_meminv_noA _ _ _ _ _ _ Hno0 Hmem0 Hec) as (Hno0' & Hmem0') end.
      split; [ exact Hno0' | split; [ exact Hmem0' | apply tprov_set_opttemp; assumption ] ].
  Qed.

End ProvEngine.

(* ================================================================== *)
(* THE CENSUS (machine-checked, genv-free): the prov_ok per-statement   *)
(* check holds over the ACTUAL clightgen'd body of f_execute_mario_action.*)
(* This is what makes exec_body_prov applicable to the REAL body -- it    *)
(* certifies, by cbn over the concrete AST, that the body's only value    *)
(* content is store1/store2 (both off-bm), that the four tracked temps    *)
(* _t'48/_t'12/_t'49/_t'13 are set only to their expected provenance RHS,  *)
(* and that no call/builtin result temp collides with a tracked temp.      *)
(* prov_ok is genv-free, so this is fast and carries no section data.       *)
Lemma execute_mario_action_body_prov_ok :
  prov_ok (fn_body mario.f_execute_mario_action).
Proof.
  (* unfold only the recursive STRUCTURE of the check; leave the per-leaf
     predicates (prov_sset_ok / optid_untracked / the store exprs) folded so
     cbn cannot re-fold mid-term -- the match arms below unfold them on demand. *)
  cbn [prov_ok prov_ok_ls fn_body mario.f_execute_mario_action Swhile].
  repeat
    (match goal with
     | |- True => exact I
     | |- _ /\ _ => split
     | |- prov_sset_ok _ _ => unfold prov_sset_ok, gms_expr, marioObj_expr
     | |- optid_untracked _ => unfold optid_untracked
     | |- _ \/ _ =>
         unfold store1_lval, store1_rval, store2_lval, store2_rval;
         first [ left; split; reflexivity | right; split; reflexivity ]
     | |- _ <> _ => let H := fresh in intro H; vm_compute in H; discriminate H
     | |- ?a = ?b => reflexivity
     | |- _ -> _ =>
         let H := fresh in intro H;
         first [ (vm_compute in H; discriminate H)
               | (injection H as H; subst)
               | idtac ]
     | |- forall _, _ => intro
     end).
Qed.

(* ================================================================== *)
(* WIRING exec_body_prov_noA TO THE REAL FRAME.                         *)
(*                                                                     *)
(* The engine's single reach obligation (reach_meminv_noA: every reached *)
(* funcall, in a no-A state, preserves NoA AND the full meminv) is BUILT  *)
(* from the sharp action-cell decomposition the capstone already isolates *)
(* (reach_value_preserves_noA = valid + action_sat, no-A-conditioned)     *)
(* PLUS the remaining struct/NoA reach piece below. This keeps the no-A    *)
(* crux (set_mario_action's argument) isolated where it was, rather than   *)
(* lumping it into one broad assumption.                                    *)
(* ================================================================== *)

(* every reached funcall preserves NoA and the two Mario-pointer invariants
   (marioObj off bm, gMarioState -> bm). The value part (valid + action_sat)
   is the SEPARATE reach_value_preserves_noA; together they give full meminv. *)
Definition reach_rest_noA (bm : block) (NoA : mem -> Prop) : Prop :=
  forall m fd vargs t m' vres,
    NoA m ->
    eval_funcall function_entry2 mario_ge m fd vargs t m' vres ->
    marioObj_wf m bm -> gMarioState_wf m bm ->
    NoA m' /\ marioObj_wf m' bm /\ gMarioState_wf m' bm.

Lemma reach_meminv_noA_build :
  forall bm NoA,
    reach_value_preserves_noA nonflying bm mario_ge NoA ->
    reach_rest_noA bm NoA ->
    forall m fd vargs t m' vres,
      NoA m -> meminv bm m ->
      eval_funcall function_entry2 mario_ge m fd vargs t m' vres ->
      NoA m' /\ meminv bm m'.
Proof.
  intros bm NoA Hval Hrest m fd vargs t m' vres Hno Hmem Hev.
  unfold meminv in Hmem. destruct Hmem as (Hv & Hsat & Hmwf & Hgwf).
  destruct (Hval m fd vargs t m' vres Hno Hev Hv Hsat) as (Hv' & Hsat').
  destruct (Hrest m fd vargs t m' vres Hno Hev Hmwf Hgwf) as (Hno' & Hmwf' & Hgwf').
  split; [ exact Hno' | unfold meminv; repeat split; assumption ].
Qed.

(* tprov holds at function entry, VACUOUSLY: the four tracked temps are not
   parameters, so they keep their create_undef_temps value (Vundef), which is
   not a Vptr -- the tat/toff implications are vacuously true. *)
Lemma tprov_entry :
  forall bm gb vargs le,
    bind_parameter_temps (fn_params mario.f_execute_mario_action) vargs
       (create_undef_temps (fn_temps mario.f_execute_mario_action)) = Some le ->
    tprov bm gb le.
Proof.
  intros bm gb vargs le Hbind.
  assert (Hother : forall id, ~ In id (var_names (fn_params mario.f_execute_mario_action)) ->
            le ! id = (create_undef_temps (fn_temps mario.f_execute_mario_action)) ! id)
    by (intros id Hnin; eapply bind_parameter_temps_other; [ exact Hbind | exact Hnin ]).
  unfold tprov, tat, toff;
  split; [ | split; [ | split ] ];
    intros b o Hlk;
    rewrite Hother in Hlk by (vm_compute; intuition discriminate);
    vm_compute in Hlk; discriminate Hlk.
Qed.

(* THE REDUCTION (concrete, fully PROVED): a real frame preserves NoA and the
   full memory invariant. body_preserves_real is no longer ASSUMED -- the body
   is discharged by exec_body_prov_noA over the census, with the entry facts
   (e = empty_env, tprov vacuous) established here and the gb/Hgb the engine
   needs extracted from gMarioState_wf. The only remaining premises are the
   no-A-conditioned reach/ext/store residuals about the REACHED call graph. *)
Theorem execute_mario_action_preserves_real :
  forall (bm : block) (NoA : mem -> Prop) m m',
    reach_value_preserves_noA nonflying bm mario_ge NoA ->
    reach_rest_noA bm NoA ->
    (forall ef vargs mm tt vres mm',
        NoA mm -> meminv bm mm ->
        external_call ef mario_ge vargs mm tt vres mm' -> NoA mm' /\ meminv bm mm') ->
    (forall e le mm a1 a2 tt le' mm' out,
        NoA mm -> prov_ok (Sassign a1 a2) ->
        exec_stmt function_entry2 mario_ge e le mm (Sassign a1 a2) tt le' mm' out -> NoA mm') ->
    NoA m ->
    Mem.valid_block m bm -> action_sat nonflying m bm ->
    marioObj_wf m bm -> gMarioState_wf m bm ->
    execute_mario_action_step m m' ->
    NoA m' /\ Mem.valid_block m' bm /\ action_sat nonflying m' bm /\
    marioObj_wf m' bm /\ gMarioState_wf m' bm.
Proof.
  intros bm NoA m m' Hval Hrest Hext Hstore HnoA Hv Hsat Hmwf Hgwf
         (b_o & t & res & Hfun).
  pose proof Hgwf as Hgwf2. destruct Hgwf2 as (gb & Hgb & Hload).
  pose proof (reach_meminv_noA_build bm NoA Hval Hrest) as Hreachmem.
  assert (HPm' :
    NoA m' /\ Mem.valid_block m' bm /\ action_sat nonflying m' bm /\
    marioObj_wf m' bm /\ gMarioState_wf m' bm).
  { eapply (funcall_from_body_preserves_entry
              (fun mm => NoA mm /\ Mem.valid_block mm bm /\ action_sat nonflying mm bm /\
                         marioObj_wf mm bm /\ gMarioState_wf mm bm)
              mario_ge mario.f_execute_mario_action (Vptr b_o Ptrofs.zero :: nil)
              m m' t res eq_refl);
      [ | exact (conj HnoA (conj Hv (conj Hsat (conj Hmwf Hgwf)))) | exact Hfun ].
    intros le mm tt le' mm' out Hbind (Hn & Hvv & Hss & Hmw & Hgw) Hexec.
    edestruct (exec_body_prov_noA bm gb Hgb NoA Hreachmem Hext Hstore
                 empty_env le mm (fn_body mario.f_execute_mario_action) tt le' mm' out)
      as (Hn' & Hmem' & _);
      [ apply PTree.gempty
      | exact Hexec
      | exact Hn
      | exact (conj Hvv (conj Hss (conj Hmw Hgw)))
      | eapply tprov_entry; exact Hbind
      | exact execute_mario_action_body_prov_ok
      | ].
    unfold meminv in Hmem'. destruct Hmem' as (Hvv' & Hss' & Hmw' & Hgw').
    exact (conj Hn' (conj Hvv' (conj Hss' (conj Hmw' Hgw')))). }
  exact HPm'.
Qed.
