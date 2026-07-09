(* kept: P1' Unwired pre-stage — standalone math/geometry body facts, consumed at the future atomic fourteen-TU link commit; NOT yet capstone-wired. *)

(* ====================================================================== *)
(* P1' PRE-STAGE (task #90).  Two of the three PURE geometry bodies of      *)
(* surface_collision, proved as STANDALONE facts about the generated AST    *)
(* objects -- provable WITHOUT linking surface_collision into lp (they      *)
(* quantify over an arbitrary Clight genv `ge`, touch `lp` NOWHERE).        *)
(*                                                                        *)
(* Per docs/p1prime-fourteen-tu-design.md §7.3, the retire-first ordering  *)
(* is impossible: the widen + the 9 exempt-list retirements must be ONE     *)
(* atomic commit.  This file is the freely-committable Unwired pre-stage of *)
(* that commit -- honest facts about the real bodies (the CONTENT the       *)
(* atomic commit consumes), NOT yet consumed by any capstone.  The wiring   *)
(* step (future) instantiates `ge := lp_ge lp` (the widened 14-TU link) and *)
(* feeds these as the new `body_pres` cases of RestSurface.rest_pres_decompose. *)
(*                                                                        *)
(* STORE-SCOUT VERDICT (per-Sassign classification against the generated    *)
(* AST, not audit-by-comment):                                              *)
(*   - find_water_level      (surface_collision.v:3339): fn_vars := nil,    *)
(*       0 Sassign, 0 Scall, reads gEnvironmentRegions -> PURE-SCALAR.      *)
(*       Memory-IDENTITY across the whole funcall (m' = m).                  *)
(*   - find_poison_gas_level (surface_collision.v:3494): fn_vars :=          *)
(*       [(_filler, tarray tuchar 4)] (one entry alloc, vec3f_find_ceil     *)
(*       shape), 0 Sassign, 0 Scall -> PURE + own-frame filler.  NOT a      *)
(*       memory identity (alloc+free), but valid_block/action_sat/MWF are   *)
(*       PRESERVED across the funcall (the vfc_pres alloc/free frame, minus  *)
(*       the find_ceil call).                                               *)
(* ====================================================================== *)

From Coq Require Import ZArith List.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking.
From SM64.Generated Require surface_collision math_util.
From SM64.Proofs Require Import ActionValueFrame Taint MarioStepSurface RestSurface.

Import ListNotations.

(* ====================================================================== *)
(* 1. find_water_level: PURE, fn_vars = nil => MEMORY IDENTITY.            *)
(* ====================================================================== *)

(* NON-VACUITY: the pure_chk recognizer accepts the REAL generated body. *)
Lemma find_water_pure_chk :
  pure_chk (fn_body surface_collision.f_find_water_level) = true.
Proof. vm_compute. reflexivity. Qed.

(* THE SHARP FACT: the whole funcall returns the SAME memory.
   Entry allocs nothing (fn_vars = nil => empty_env), the body is
   memory-pure (pure_walk), and the exit frees the empty env (nothing). *)
Lemma find_water_level_memid :
  forall (ge : genv) m vargs t m' vres,
    eval_funcall function_entry2 ge m
      (Internal surface_collision.f_find_water_level) vargs t m' vres ->
    m' = m.
Proof.
  intros ge m vargs t m' vres Hevf.
  unfold surface_collision.f_find_water_level in Hevf.
  inv Hevf.
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry end.
  match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody end.
  match goal with Hf : Mem.free_list _ _ = Some _ |- _ => rename Hf into Hfree end.
  inv Hentry.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
    cbn [fn_vars] in Ha; inv Ha end.
  pose proof (pure_walk _ _ _ _ _ _ _ _ _ Hbody find_water_pure_chk) as Em.
  subst m1.
  assert (Hben : blocks_of_env ge empty_env = nil) by reflexivity.
  rewrite Hben in Hfree. cbn [Mem.free_list] in Hfree.
  injection Hfree as <-. reflexivity.
Qed.

(* THE CONSUMER-FACING FRAME COROLLARY (body_pres shape, ge-generic).
   Drop-in for RestSurface.body_pres at the widened link: instantiate
   ge := lp_ge lp; the marg premise of body_pres is dropped (the body
   writes no memory, so it is irrelevant). *)
Lemma find_water_level_body_frame :
  forall (ge : genv) (NoA MWF : mem -> Prop) (bm : block) m vargs t m' vres,
    eval_funcall function_entry2 ge m
      (Internal surface_collision.f_find_water_level) vargs t m' vres ->
    NoA m -> MWF m -> Mem.valid_block m bm -> action_sat not_tainted m bm ->
    Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m'.
Proof.
  intros ge NoA MWF bm m vargs t m' vres Hevf Hno Hmwf Hv Hsat.
  rewrite (find_water_level_memid ge m vargs t m' vres Hevf).
  exact (conj Hv (conj Hsat Hmwf)).
Qed.

(* ====================================================================== *)
(* 2. find_poison_gas_level: PURE, one own-frame _filler alloc.           *)
(*    NOT a memory identity (alloc+free), but valid_block/action_sat/MWF  *)
(*    are PRESERVED -- the vfc_pres frame, minus the find_ceil call.       *)
(* ====================================================================== *)

(* NON-VACUITY: the pure_chk recognizer accepts the REAL generated body. *)
Lemma find_poison_pure_chk :
  pure_chk (fn_body surface_collision.f_find_poison_gas_level) = true.
Proof. vm_compute. reflexivity. Qed.

(* blocks_of_env of the singleton _filler env (the sole entry var). *)
Lemma blocks_of_env_sc_filler : forall ge bfil,
  blocks_of_env ge
    (PTree.set surface_collision._filler (bfil, tarray tuchar 4) empty_env)
    = (bfil, 0, sizeof ge (tarray tuchar 4)) :: nil.
Proof.
  intros ge bfil. unfold blocks_of_env.
  replace (PTree.elements
             (PTree.set surface_collision._filler
                (bfil, tarray tuchar 4) empty_env))
    with ((surface_collision._filler, (bfil, tarray tuchar 4))
            :: (@nil (positive * (block*type))))
    by (vm_compute; reflexivity).
  cbn [map block_of_binding]. reflexivity.
Qed.

(* THE CONSUMER-FACING FRAME (body_pres shape, ge-generic).  The alloc/free
   MWF-preservation bricks are the SAME two the capstone already supplies to
   vfc_pres (RestSurface.vfc_pres premises 1-2); NO external-call bricks are
   needed because this body performs NO calls. *)
Lemma find_poison_gas_level_body_frame :
  forall (ge : genv) (NoA MWF : mem -> Prop) (bm : block),
    (forall m lo hi m'' b, Mem.alloc m lo hi = (m'', b) -> MWF m -> MWF m'') ->
    (forall m2 m3 l, Mem.free_list m2 l = Some m3 -> MWF m2 -> MWF m3) ->
    forall m vargs t m' vres,
      eval_funcall function_entry2 ge m
        (Internal surface_collision.f_find_poison_gas_level) vargs t m' vres ->
      NoA m -> MWF m -> Mem.valid_block m bm -> action_sat not_tainted m bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m'.
Proof.
  intros ge NoA MWF bm Halloc Hfree m vargs t m' vres Hevf Hno Hmwf Hv Hsat.
  unfold surface_collision.f_find_poison_gas_level in Hevf.
  inv Hevf.
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry end.
  match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody end.
  match goal with Hf : Mem.free_list _ _ = Some _ |- _ => rename Hf into Hfl end.
  (* ENTRY: one alloc of the filler *)
  inv Hentry.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
    cbn [fn_vars] in Ha; inv Ha end.
  match goal with Ha : alloc_variables _ _ _ nil _ _ |- _ => inv Ha end.
  match goal with Hal : Mem.alloc _ _ _ = _ |- _ => rename Hal into Halc end.
  match goal with Halc : Mem.alloc _ _ _ = (?mA, ?bfil) |- _ =>
    assert (HmwfA : MWF mA) by (eapply Halloc; [ exact Halc | exact Hmwf ]);
    assert (HvA : Mem.valid_block mA bm)
      by (eapply Mem.valid_block_alloc; [ exact Halc | exact Hv ]);
    assert (Hunch_al : Mem.unchanged_on (action_cell bm) m mA)
      by (eapply Mem.alloc_unchanged_on; exact Halc);
    assert (Hbfil_ne : bfil <> bm)
      by (intro EE; subst bfil;
          exact (Mem.fresh_block_alloc _ _ _ _ _ Halc Hv));
    assert (HsatA : action_sat not_tainted mA bm)
      by (eapply action_sat_unchanged_on; [ exact Hunch_al | exact Hv | exact Hsat ])
  end.
  (* BODY: memory-pure => the body leaves mA untouched *)
  pose proof (pure_walk _ _ _ _ _ _ _ _ _ Hbody find_poison_pure_chk) as Em.
  subst m1.
  (* EXIT: free the sole filler block (bm-distinct) *)
  rewrite blocks_of_env_sc_filler in Hfl.
  split; [ | split ].
  - refine (proj1 (vfc_free_list_frame not_tainted bm _ _ _ _ Hfl HvA HsatA)).
    constructor; [ exact Hbfil_ne | constructor ].
  - refine (proj2 (vfc_free_list_frame not_tainted bm _ _ _ _ Hfl HvA HsatA)).
    constructor; [ exact Hbfil_ne | constructor ].
  - exact (Hfree _ _ _ Hfl HmwfA).
Qed.

(* ====================================================================== *)
(* 3. atan2_lookup: PURE, fn_vars = nil => MEMORY IDENTITY.               *)
(*    (math_util.v:12515).  Body is nested Sifthenelse over Sset temps     *)
(*    reading the static gArctanTable, then Sreturn -- 0 Sassign,          *)
(*    0 Scall.  Store class: PURE-SCALAR (same as find_water_level).       *)
(* ====================================================================== *)

(* NON-VACUITY: the pure_chk recognizer accepts the REAL generated body. *)
Lemma atan2_lookup_pure_chk :
  pure_chk (fn_body math_util.f_atan2_lookup) = true.
Proof. vm_compute. reflexivity. Qed.

(* THE SHARP FACT: the whole funcall returns the SAME memory. *)
Lemma atan2_lookup_memid :
  forall (ge : genv) m vargs t m' vres,
    eval_funcall function_entry2 ge m
      (Internal math_util.f_atan2_lookup) vargs t m' vres ->
    m' = m.
Proof.
  intros ge m vargs t m' vres Hevf.
  unfold math_util.f_atan2_lookup in Hevf.
  inv Hevf.
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry end.
  match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody end.
  match goal with Hf : Mem.free_list _ _ = Some _ |- _ => rename Hf into Hfree end.
  inv Hentry.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
    cbn [fn_vars] in Ha; inv Ha end.
  pose proof (pure_walk _ _ _ _ _ _ _ _ _ Hbody atan2_lookup_pure_chk) as Em.
  subst m1.
  assert (Hben : blocks_of_env ge empty_env = nil) by reflexivity.
  rewrite Hben in Hfree. cbn [Mem.free_list] in Hfree.
  injection Hfree as <-. reflexivity.
Qed.

(* THE CONSUMER-FACING FRAME COROLLARY (body_pres shape, ge-generic). *)
Lemma atan2_lookup_body_frame :
  forall (ge : genv) (NoA MWF : mem -> Prop) (bm : block) m vargs t m' vres,
    eval_funcall function_entry2 ge m
      (Internal math_util.f_atan2_lookup) vargs t m' vres ->
    NoA m -> MWF m -> Mem.valid_block m bm -> action_sat not_tainted m bm ->
    Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m'.
Proof.
  intros ge NoA MWF bm m vargs t m' vres Hevf Hno Hmwf Hv Hsat.
  rewrite (atan2_lookup_memid ge m vargs t m' vres Hevf).
  exact (conj Hv (conj Hsat Hmwf)).
Qed.

(* ====================================================================== *)
(* 4. atan2s: PURE-SCALAR (fn_vars = nil, 0 Sassign) but its 8 octant     *)
(*    leaves each call atan2_lookup (math_util.v:12546).  Store class:     *)
(*    PURE-SCALAR-WITH-INTERNAL-CALL.  In a ge-GENERIC setting the symbol  *)
(*    _atan2_lookup cannot be resolved, so the funcall in the Scall case   *)
(*    is opaque.  We therefore carry a SPECIFIC call-memory-identity       *)
(*    oracle for the _atan2_lookup callee expression (SATISFIABLE, unlike  *)
(*    a blanket all-calls oracle): at the wiring point ge := lp_ge lp the  *)
(*    symbol resolves to Internal f_atan2_lookup and the oracle is         *)
(*    discharged from atan2_lookup_memid.  This is the exact analogue of   *)
(*    find_poison_gas_level_body_frame carrying its alloc/free oracles.     *)
(* ====================================================================== *)

(* Recognizer for the _atan2_lookup callee expression. *)
Definition is_atan2_lookup_call (a : expr) : bool :=
  match a with
  | Evar id _ => Pos.eqb id math_util._atan2_lookup
  | _ => false
  end.

(* pure_chk widened to accept Scall to _atan2_lookup (no Sswitch/Sassign). *)
Fixpoint cpure_chk (s : statement) : bool :=
  match s with
  | Sskip | Sbreak | Scontinue | Sreturn _ => true
  | Sset _ _ => true
  | Scall _ a _ => is_atan2_lookup_call a
  | Ssequence s1 s2 => cpure_chk s1 && cpure_chk s2
  | Sifthenelse _ s1 s2 => cpure_chk s1 && cpure_chk s2
  | Sloop s1 s2 => cpure_chk s1 && cpure_chk s2
  | _ => false
  end.

(* NON-VACUITY: the widened recognizer accepts the REAL generated body. *)
Lemma atan2s_cpure_chk :
  cpure_chk (fn_body math_util.f_atan2s) = true.
Proof. vm_compute. reflexivity. Qed.

(* THE CALL-AWARE WALK: a cpure_chk-accepted statement leaves memory
   IDENTICAL, GIVEN the _atan2_lookup callee preserves memory (Hcall). *)
Lemma cpure_walk :
  forall (ge : genv)
    (Hcall : forall e le m a vf f vargs t m' vres,
        is_atan2_lookup_call a = true ->
        eval_expr ge e le m a vf ->
        Genv.find_funct ge vf = Some f ->
        eval_funcall function_entry2 ge m f vargs t m' vres -> m' = m)
    s e le m tr le' m' out,
    exec_stmt function_entry2 ge e le m s tr le' m' out ->
    cpure_chk s = true -> m' = m.
Proof.
  intros ge Hcall s e le m tr le' m' out Hexec.
  induction Hexec; intros Hchk; try reflexivity; try discriminate Hchk.
  - (* Scall *)
    cbn [cpure_chk] in Hchk.
    eapply Hcall; [ exact Hchk | eassumption | eassumption | eassumption ].
  - (* Sseq_1 *)
    cbn [cpure_chk] in Hchk. apply andb_prop in Hchk as [H1 H2].
    rewrite (IHHexec2 H2). exact (IHHexec1 H1).
  - (* Sseq_2 *)
    cbn [cpure_chk] in Hchk. apply andb_prop in Hchk as [H1 _].
    exact (IHHexec H1).
  - (* Sifthenelse *)
    cbn [cpure_chk] in Hchk. apply andb_prop in Hchk as [H1 H2].
    apply IHHexec. destruct b; assumption.
  - (* Sloop stop1 *)
    cbn [cpure_chk] in Hchk. apply andb_prop in Hchk as [H1 _].
    exact (IHHexec H1).
  - (* Sloop stop2 *)
    cbn [cpure_chk] in Hchk. apply andb_prop in Hchk as [H1 H2].
    rewrite (IHHexec2 H2). exact (IHHexec1 H1).
  - (* Sloop loop *)
    cbn [cpure_chk] in Hchk.
    pose proof Hchk as Hchk0.
    apply andb_prop in Hchk as [H1 H2].
    rewrite (IHHexec3 Hchk0), (IHHexec2 H2). exact (IHHexec1 H1).
Qed.

(* THE SHARP FACT: given the _atan2_lookup call oracle, the whole atan2s
   funcall returns the SAME memory (fn_vars = nil => empty_env, exit frees
   nothing). *)
Lemma atan2s_memid :
  forall (ge : genv)
    (Hcall : forall e le m a vf f vargs t m' vres,
        is_atan2_lookup_call a = true ->
        eval_expr ge e le m a vf ->
        Genv.find_funct ge vf = Some f ->
        eval_funcall function_entry2 ge m f vargs t m' vres -> m' = m)
    m vargs t m' vres,
    eval_funcall function_entry2 ge m
      (Internal math_util.f_atan2s) vargs t m' vres ->
    m' = m.
Proof.
  intros ge Hcall m vargs t m' vres Hevf.
  unfold math_util.f_atan2s in Hevf.
  inv Hevf.
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry end.
  match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody end.
  match goal with Hf : Mem.free_list _ _ = Some _ |- _ => rename Hf into Hfree end.
  inv Hentry.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
    cbn [fn_vars] in Ha; inv Ha end.
  pose proof (cpure_walk ge Hcall _ _ _ _ _ _ _ _ Hbody atan2s_cpure_chk) as Em.
  subst m1.
  assert (Hben : blocks_of_env ge empty_env = nil) by reflexivity.
  rewrite Hben in Hfree. cbn [Mem.free_list] in Hfree.
  injection Hfree as <-. reflexivity.
Qed.

(* THE CONSUMER-FACING FRAME COROLLARY (body_pres shape, ge-generic).
   Carries the _atan2_lookup call oracle as a premise -- the exact analogue
   of find_poison_gas_level_body_frame's alloc/free oracles.  At the wiring
   point the oracle is discharged from atan2_lookup_memid (once the symbol
   _atan2_lookup resolves to Internal f_atan2_lookup in lp_ge). *)
Lemma atan2s_body_frame :
  forall (ge : genv) (NoA MWF : mem -> Prop) (bm : block),
    (forall e le m a vf f vargs t m' vres,
        is_atan2_lookup_call a = true ->
        eval_expr ge e le m a vf ->
        Genv.find_funct ge vf = Some f ->
        eval_funcall function_entry2 ge m f vargs t m' vres -> m' = m) ->
    forall m vargs t m' vres,
      eval_funcall function_entry2 ge m
        (Internal math_util.f_atan2s) vargs t m' vres ->
      NoA m -> MWF m -> Mem.valid_block m bm -> action_sat not_tainted m bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m'.
Proof.
  intros ge NoA MWF bm Hcall m vargs t m' vres Hevf Hno Hmwf Hv Hsat.
  rewrite (atan2s_memid ge Hcall m vargs t m' vres Hevf).
  exact (conj Hv (conj Hsat Hmwf)).
Qed.
