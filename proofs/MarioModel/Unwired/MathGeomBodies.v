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
From SM64.Proofs Require CensusV2 RealFrameValue.

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

(* ====================================================================== *)
(* 5. vec3f_set / vec3f_copy / vec3s_copy: OUT-PARAM WRITERS (task #90).   *)
(*                                                                        *)
(* STORE-SCOUT VERDICT (per-Sassign classification against the generated  *)
(* math_util AST, verified — NOT trusted from the design comment):        *)
(*   - vec3f_set  (math_util.v:6129): fn_vars=[(_dest,tptr tfloat)].       *)
(*       4 Sassign: #1 `Evar _dest` = OWN-FRAME shadow (class a); #2..#4   *)
(*       `Ederef(_t'k+i)` = OUT-PARAM dest[0..2] (class b).  0 statics,    *)
(*       0 callees.  CLEAN out-param-only.                                 *)
(*   - vec3f_copy (math_util.v:6075): same 4 Sassign shape (reads src[i]   *)
(*       via temps, writes dest[i]); 0 statics, 0 callees.  CLEAN.         *)
(*   - vec3s_copy (math_util.v:6322): tshort twin of vec3f_copy; 0 statics,*)
(*       0 callees.  CLEAN.                                                *)
(* UNLIKE find_floor/find_ceil (design §8), these write NO static global,  *)
(* so a pure GATED (out-param block <> bm) fact is SOUND — no stored_globals*)
(* oracle needed.  The clightgen address-taken shadow `_dest` is written   *)
(* once (own fresh frame block) then reloaded into a temp per store; each  *)
(* deref store therefore lands in the OUT-PARAM block, gated <> bm.        *)
(* ====================================================================== *)

(* Generic frame: a store into a block <> bm preserves valid_block /
   action_sat / MWF (the store-off-Mario brick; MWF via the caller's
   store oracle, discharged at wiring from MWFReal's off-bm store rows). *)
Lemma store_off_bm_pres :
  forall (MWF : mem -> Prop) (Q : int -> Prop) bm b chunk ofs v m m',
    (forall ch b0 o0 v0 m1 m2,
        b0 <> bm -> Mem.store ch m1 b0 o0 v0 = Some m2 -> MWF m1 -> MWF m2) ->
    b <> bm ->
    Mem.store chunk m b ofs v = Some m' ->
    Mem.valid_block m bm -> action_sat Q m bm -> MWF m ->
    Mem.valid_block m' bm /\ action_sat Q m' bm /\ MWF m'.
Proof.
  intros MWF Q bm b chunk ofs v m m' Hstore Hbne Hst Hv Hsat Hmwf.
  split; [ | split ].
  - eapply Mem.store_valid_block_1; eauto.
  - eapply action_sat_unchanged_on with (m := m); [ | exact Hv | exact Hsat ].
    eapply Mem.store_unchanged_on; [ exact Hst | ].
    intros i _ [Hb _]. exact (Hbne Hb).
  - eapply Hstore; eauto.
Qed.

(* bind_parameter_temps preserves a binding for an ident absent from the
   remaining parameter names (used to read le!_dest = first arg). *)
Lemma bind_parameter_temps_gso :
  forall ps args te le p,
    bind_parameter_temps ps args te = Some le ->
    ~ In p (var_names ps) ->
    le ! p = te ! p.
Proof.
  induction ps as [|[q tq] ps IH]; intros args te le p Hbp Hni.
  - destruct args as [|a args]; cbn in Hbp; try discriminate. inv Hbp. reflexivity.
  - destruct args as [|a args]; cbn in Hbp; try discriminate.
    erewrite IH; [ | exact Hbp | ].
    + rewrite PTree.gso; [ reflexivity | ].
      intro Heq; subst q; apply Hni; left; reflexivity.
    + intro HH; apply Hni; right; exact HH.
Qed.

(* One SHADOW store `Sassign (Evar _dest) (Etempvar _dest)`: writes the
   out-param value into the own fresh frame block b_dest; frame preserved
   (b_dest <> bm) and the block now loads back the out-param pointer. *)
Lemma vec_shadow_store :
  forall (MWF : mem -> Prop) (Q : int -> Prop) bm b_dest b_out oo T ge e le m t le' m' out,
    (forall ch b0 o0 v0 m1 m2,
        b0 <> bm -> Mem.store ch m1 b0 o0 v0 = Some m2 -> MWF m1 -> MWF m2) ->
    e ! math_util._dest = Some (b_dest, tptr T) ->
    le ! math_util._dest = Some (Vptr b_out oo) ->
    b_dest <> bm ->
    exec_stmt function_entry2 ge e le m
      (Sassign (Evar math_util._dest (tptr T)) (Etempvar math_util._dest (tptr T)))
      t le' m' out ->
    Mem.valid_block m bm -> action_sat Q m bm -> MWF m ->
    Mem.valid_block m' bm /\ action_sat Q m' bm /\ MWF m'
      /\ Mem.load Mptr m' b_dest 0 = Some (Vptr b_out oo).
Proof.
  intros MWF Q bm b_dest b_out oo T ge e le m t le' m' out
         Hstore Hedest Hledest Hbne Hexec Hv Hsat Hmwf.
  inv Hexec.
  (* eval_lvalue (Evar _dest) : local -> b_dest, 0, Full *)
  match goal with Hlv : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inv Hlv end;
    [ | match goal with Hnone : e ! math_util._dest = None |- _ =>
          rewrite Hedest in Hnone; discriminate Hnone end ].
  match goal with He : e ! math_util._dest = Some (?loc, _) |- _ =>
    assert (loc = b_dest) by congruence; subst loc end.
  (* eval_expr (Etempvar _dest) = Vptr b_out oo *)
  match goal with Hev : eval_expr _ _ _ _ (Etempvar _ _) ?v2 |- _ =>
    apply RealFrameValue.eval_expr_Etempvar_val in Hev;
    assert (Hv2e : v2 = Vptr b_out oo) by congruence; rewrite Hv2e in * end.
  (* sem_cast of a pointer to the same pointer type is the identity *)
  match goal with Hc : sem_cast (Vptr b_out oo) _ _ _ = Some ?v |- _ =>
    assert (Hvv : v = Vptr b_out oo) by (cbn in Hc; congruence); rewrite Hvv in * end.
  (* assign_loc By_value Mptr Full: a store into (b_dest, 0) *)
  match goal with Hass : assign_loc _ _ _ _ _ Full _ _ |- _ => inv Hass end;
  [ match goal with Ham : access_mode _ = By_value _ |- _ =>
      cbn [access_mode typeof] in Ham; injection Ham as Hchunk; subst end
  | match goal with Ham : access_mode _ = By_copy |- _ =>
      cbn [access_mode typeof] in Ham; discriminate Ham end ].
  match goal with Hsv : Mem.storev _ _ _ _ = Some _ |- _ =>
    unfold Mem.storev in Hsv; rewrite Ptrofs.unsigned_zero in Hsv end.
  match goal with Hsv : Mem.store Mptr _ b_dest 0 _ = Some m' |- _ =>
    destruct (store_off_bm_pres MWF Q bm b_dest Mptr 0 (Vptr b_out oo) m m'
                Hstore Hbne Hsv Hv Hsat Hmwf) as (Hv' & Hsat' & Hmwf');
    split; [ exact Hv' | split; [ exact Hsat' | split; [ exact Hmwf' | ] ] ];
    pose proof (Mem.load_store_same _ _ _ _ _ _ Hsv) as Hls end.
  replace (Val.load_result Mptr (Vptr b_out oo)) with (Vptr b_out oo) in Hls
    by (unfold Mptr; reflexivity).
  exact Hls.
Qed.

(* One SHADOW READ `Sset tid (Evar _dest)`: memory unchanged; the temp now
   holds the out-param pointer reloaded from the shadow block b_dest. *)
Lemma sset_shadow_reads :
  forall ge e le m T tid b_dest b_out oo t le' m' out,
    e ! math_util._dest = Some (b_dest, tptr T) ->
    Mem.load Mptr m b_dest 0 = Some (Vptr b_out oo) ->
    exec_stmt function_entry2 ge e le m
      (Sset tid (Evar math_util._dest (tptr T))) t le' m' out ->
    m' = m /\ out = Out_normal /\ le' ! tid = Some (Vptr b_out oo).
Proof.
  intros ge e le m T tid b_dest b_out oo t le' m' out Hedest Hload Hexec.
  inv Hexec.
  match goal with Hev : eval_expr _ _ _ _ (Evar _ _) _ |- _ => inv Hev end.
  match goal with Hlv : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inv Hlv end;
    [ | match goal with Hn : e ! math_util._dest = None |- _ =>
          rewrite Hedest in Hn; discriminate Hn end ].
  match goal with He : e ! math_util._dest = Some (?loc, _) |- _ =>
    assert (loc = b_dest) by congruence; subst loc end.
  match goal with Hd : deref_loc _ _ _ _ Full ?v |- _ => inv Hd end;
  [ match goal with Ham : access_mode _ = By_value _ |- _ =>
      cbn [access_mode typeof] in Ham; injection Ham as Hchunk; subst end
  | match goal with Ham : access_mode _ = By_reference |- _ =>
      cbn [access_mode typeof] in Ham; discriminate Ham end
  | match goal with Ham : access_mode _ = By_copy |- _ =>
      cbn [access_mode typeof] in Ham; discriminate Ham end ].
  match goal with Hlv2 : Mem.loadv _ _ _ = Some _ |- _ =>
    unfold Mem.loadv in Hlv2; rewrite Ptrofs.unsigned_zero, Hload in Hlv2;
    injection Hlv2 as <- end.
  split; [ reflexivity | split; [ reflexivity | rewrite PTree.gss; reflexivity ] ].
Qed.

(* One OUT-PARAM STORE `Sassign (Ederef (Etempvar tid + i)) rhs`: the store
   target block is exactly the block the root temp `tid` holds (chain_root_l);
   if that block is <> bm the frame is preserved and every off-target block's
   Mptr-load is unchanged (so the shadow reload survives). *)
Lemma out_store_avoids :
  forall (MWF : mem -> Prop) (Q : int -> Prop) (bm b_out : block) (o' : ptrofs)
         (T : type) (chk : memory_chunk) ge e le m tid ii rhs t le' m' out,
    (forall ch b0 o0 v0 m1 m2,
        b0 <> bm -> Mem.store ch m1 b0 o0 v0 = Some m2 -> MWF m1 -> MWF m2) ->
    access_mode T = By_value chk ->
    le ! tid = Some (Vptr b_out o') ->
    b_out <> bm ->
    exec_stmt function_entry2 ge e le m
      (Sassign
        (Ederef (Ebinop Oadd (Etempvar tid (tptr T)) (Econst_int ii tint) (tptr T)) T)
        rhs) t le' m' out ->
    Mem.valid_block m bm -> action_sat Q m bm -> MWF m ->
    Mem.valid_block m' bm /\ action_sat Q m' bm /\ MWF m'
      /\ (forall bx ox, bx <> b_out -> Mem.load Mptr m' bx ox = Mem.load Mptr m bx ox).
Proof.
  intros MWF Q bm b_out o' T chk ge e le m tid ii rhs t le' m' out
         Hstore Hac Htid Hbne Hexec Hv Hsat Hmwf.
  inv Hexec.
  match goal with Hlv : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ =>
    rename Hlv into Hlvx end.
  assert (Hcr : CensusV2.chain_root_l
      (Ederef (Ebinop Oadd (Etempvar tid (tptr T)) (Econst_int ii tint) (tptr T)) T)
      = Some tid) by reflexivity.
  destruct (CensusV2.chain_root_l_block _ _ _ _ _ _ _ _ _ Hcr Hlvx) as (o0 & Hle).
  rewrite Htid in Hle. injection Hle as E1 E2. subst loc.
  (* pin bf = Full by inverting the Ederef lvalue *)
  match goal with Hlv : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hlv end.
  match goal with Hass : assign_loc _ _ _ _ _ Full _ _ |- _ => inv Hass end;
  [ match goal with Ham : access_mode _ = By_value _ |- _ =>
      cbn [typeof] in Ham; rewrite Hac in Ham; injection Ham as Hchunk; subst end
  | match goal with Ham : access_mode _ = By_copy |- _ =>
      cbn [typeof] in Ham; rewrite Hac in Ham; discriminate Ham end ].
  match goal with Hsv : Mem.storev _ _ _ _ = Some _ |- _ =>
    rename Hsv into Hstv end.
  unfold Mem.storev in Hstv.
  destruct (store_off_bm_pres MWF Q bm b_out _ _ _ m m'
              Hstore Hbne Hstv Hv Hsat Hmwf) as (Hv' & Hsat' & Hmwf').
  split; [ exact Hv' | split; [ exact Hsat' | split; [ exact Hmwf' | ] ] ].
  intros bx ox Hbx. eapply Mem.load_store_other; [ exact Hstv | left; exact Hbx ].
Qed.

(* blocks_of_env of the singleton _dest env (the sole entry var, float/short). *)
Lemma blocks_of_env_mu_dest : forall ge b T,
  blocks_of_env ge (PTree.set math_util._dest (b, tptr T) empty_env)
    = (b, 0, sizeof ge (tptr T)) :: nil.
Proof.
  intros ge b T. unfold blocks_of_env.
  replace (PTree.elements (PTree.set math_util._dest (b, tptr T) empty_env))
    with ((math_util._dest, (b, tptr T)) :: (@nil (positive * (block*type))))
    by (vm_compute; reflexivity).
  cbn [map block_of_binding]. reflexivity.
Qed.


(* A straight-line body (only Sset/Sassign/Ssequence) exits Out_normal.
   Refutes the spurious Sseq_2 (first-stmt-abnormal) branch of a body walk. *)
Fixpoint sl_chk (s : statement) : bool :=
  match s with
  | Sset _ _ => true
  | Sassign _ _ => true
  | Ssequence s1 s2 => sl_chk s1 && sl_chk s2
  | _ => false
  end.

Lemma sl_out_normal :
  forall ge e le m s t le' m' out,
    exec_stmt function_entry2 ge e le m s t le' m' out ->
    sl_chk s = true -> out = Out_normal.
Proof.
  intros ge e le m s t le' m' out Hex.
  induction Hex; intros Hchk; cbn in Hchk; try discriminate Hchk; try reflexivity.
  - (* Sseq_1 *) apply andb_prop in Hchk as [_ H2]. exact (IHHex2 H2).
  - (* Sseq_2 *) apply andb_prop in Hchk as [H1 _]. specialize (IHHex H1). congruence.
Qed.

Ltac peelseq :=
  match goal with
  | H : exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ |- _ =>
      inv H;
      [ | match goal with
          | Hs : exec_stmt _ _ _ _ _ _ _ _ _ ?o, Hne : ?o <> Out_normal |- _ =>
              exfalso; apply Hne;
              eapply sl_out_normal; [ exact Hs | vm_compute; reflexivity ]
          end ]
  end.

(* ONE vec3f_set-shape store block: `Sset tid (Evar _dest); *(tid+i) = rhs`. *)
Lemma vec_block_set :
  forall (MWF : mem -> Prop) (Q : int -> Prop) bm b_dest b_out oo T chk ge e le m
         tid ii rhs t le' m' out,
    (forall ch b0 o0 v0 m1 m2,
        b0 <> bm -> Mem.store ch m1 b0 o0 v0 = Some m2 -> MWF m1 -> MWF m2) ->
    access_mode T = By_value chk ->
    e ! math_util._dest = Some (b_dest, tptr T) ->
    Mem.load Mptr m b_dest 0 = Some (Vptr b_out oo) ->
    b_out <> bm -> b_out <> b_dest ->
    exec_stmt function_entry2 ge e le m
      (Ssequence (Sset tid (Evar math_util._dest (tptr T)))
        (Sassign
          (Ederef (Ebinop Oadd (Etempvar tid (tptr T)) (Econst_int ii tint) (tptr T)) T)
          rhs)) t le' m' out ->
    Mem.valid_block m bm -> action_sat Q m bm -> MWF m ->
    Mem.valid_block m' bm /\ action_sat Q m' bm /\ MWF m'
      /\ Mem.load Mptr m' b_dest 0 = Some (Vptr b_out oo).
Proof.
  intros MWF Q bm b_dest b_out oo T chk ge e le m tid ii rhs t le' m' out
         Hstore Hac Hedest Hload Hbne Hbdne Hexec Hv Hsat Hmwf.
  peelseq.
  match goal with HSset : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ =>
    rename HSset into HSset0 end.
  match goal with HStore : exec_stmt _ _ _ _ _ (Sassign (Ederef _ _) _) _ _ _ _ |- _ =>
    rename HStore into HStore0 end.
  destruct (sset_shadow_reads _ _ _ _ _ _ _ _ _ _ _ _ _ Hedest Hload HSset0)
    as (Em & Hout & Htid).
  subst.
  destruct (out_store_avoids _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
              Hstore Hac Htid Hbne HStore0 Hv Hsat Hmwf)
    as (Hv' & Hsat' & Hmwf' & Hpres).
  split; [ exact Hv' | split; [ exact Hsat' | split; [ exact Hmwf' | ] ] ].
  rewrite (Hpres b_dest 0 (not_eq_sym Hbdne)). exact Hload.
Qed.

(* ONE vec3f_copy/vec3s_copy-shape store block:
   `Sset tid1 (Evar _dest); Sset tid2 srcexpr; *(tid1+i) = tid2`. *)
Lemma vec_block_copy :
  forall (MWF : mem -> Prop) (Q : int -> Prop) bm b_dest b_out oo T chk ge e le m
         tid1 tid2 srcexpr ii t le' m' out,
    (forall ch b0 o0 v0 m1 m2,
        b0 <> bm -> Mem.store ch m1 b0 o0 v0 = Some m2 -> MWF m1 -> MWF m2) ->
    access_mode T = By_value chk ->
    e ! math_util._dest = Some (b_dest, tptr T) ->
    Mem.load Mptr m b_dest 0 = Some (Vptr b_out oo) ->
    b_out <> bm -> b_out <> b_dest -> tid1 <> tid2 ->
    exec_stmt function_entry2 ge e le m
      (Ssequence (Sset tid1 (Evar math_util._dest (tptr T)))
        (Ssequence (Sset tid2 srcexpr)
          (Sassign
            (Ederef (Ebinop Oadd (Etempvar tid1 (tptr T)) (Econst_int ii tint) (tptr T)) T)
            (Etempvar tid2 T)))) t le' m' out ->
    Mem.valid_block m bm -> action_sat Q m bm -> MWF m ->
    Mem.valid_block m' bm /\ action_sat Q m' bm /\ MWF m'
      /\ Mem.load Mptr m' b_dest 0 = Some (Vptr b_out oo).
Proof.
  intros MWF Q bm b_dest b_out oo T chk ge e le m tid1 tid2 srcexpr ii t le' m' out
         Hstore Hac Hedest Hload Hbne Hbdne Htne Hexec Hv Hsat Hmwf.
  peelseq.
  match goal with HSset : exec_stmt _ _ _ _ _ (Sset tid1 _) _ _ _ _ |- _ =>
    rename HSset into HSset0 end.
  destruct (sset_shadow_reads _ _ _ _ _ _ _ _ _ _ _ _ _ Hedest Hload HSset0)
    as (Em & Hout & Htid1).
  subst.
  peelseq.
  (* the src-deref Sset: memory unchanged, tid1 binding survives (tid1 <> tid2) *)
  match goal with HSset2 : exec_stmt _ _ _ _ _ (Sset tid2 _) _ _ _ _ |- _ => inv HSset2 end.
  match goal with HStore : exec_stmt _ _ _ ?lenv _ (Sassign (Ederef _ _) _) _ _ _ _ |- _ =>
    rename HStore into HStore0;
    assert (Htid1' : lenv ! tid1 = Some (Vptr b_out oo))
      by (rewrite PTree.gso by exact Htne; exact Htid1) end.
  destruct (out_store_avoids _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
              Hstore Hac Htid1' Hbne HStore0 Hv Hsat Hmwf)
    as (Hv' & Hsat' & Hmwf' & Hpres).
  split; [ exact Hv' | split; [ exact Hsat' | split; [ exact Hmwf' | ] ] ].
  rewrite (Hpres b_dest 0 (not_eq_sym Hbdne)). exact Hload.
Qed.

(* le!_dest = the first argument (params are norepet, _dest is head). *)
Lemma bind_parameter_temps_head :
  forall q tq ps a args te le,
    ~ In q (var_names ps) ->
    bind_parameter_temps ((q, tq) :: ps) (a :: args) te = Some le ->
    le ! q = Some a.
Proof.
  intros q tq ps a args te le Hni Hbp.
  cbn [bind_parameter_temps] in Hbp.
  erewrite bind_parameter_temps_gso; [ | exact Hbp | exact Hni ].
  apply PTree.gss.
Qed.

(* ---------------------------------------------------------------------- *)
(* vec3f_set body frame: gated on the out-param (arg0 = Vptr b_out oo,     *)
(* a caller block <> bm) -- the phantom-false plain body_pres restated     *)
(* with the honest wc/oc-style local gate.  ge-generic; consumed at the    *)
(* atomic wiring commit as the vec3f_set case (b_out is a caller stack     *)
(* local, so b_out <> bm holds by the local gate).                         *)
(* ---------------------------------------------------------------------- *)
Lemma vec3f_set_body_frame :
  forall (ge : genv) (MWF : mem -> Prop) (bm b_out : block) (oo : ptrofs),
    (forall m lo hi m'' b, Mem.alloc m lo hi = (m'', b) -> MWF m -> MWF m'') ->
    (forall m2 m3 l, Mem.free_list m2 l = Some m3 -> MWF m2 -> MWF m3) ->
    (forall ch b0 o0 v0 m1 m2,
        b0 <> bm -> Mem.store ch m1 b0 o0 v0 = Some m2 -> MWF m1 -> MWF m2) ->
    forall m vargs t m' vres,
      eval_funcall function_entry2 ge m
        (Internal math_util.f_vec3f_set) vargs t m' vres ->
      hd_error vargs = Some (Vptr b_out oo) ->
      b_out <> bm -> Mem.valid_block m b_out ->
      Mem.valid_block m bm -> action_sat not_tainted m bm -> MWF m ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m'.
Proof.
  intros ge MWF bm b_out oo Halloc Hfree Hstore m vargs t m' vres
         Hevf Hhd Hbne Hbov Hv Hsat Hmwf.
  assert (Hacf : access_mode tfloat = By_value Mfloat32) by reflexivity.
  unfold math_util.f_vec3f_set in Hevf.
  inv Hevf.
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry end.
  match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody end.
  match goal with Hf : Mem.free_list _ _ = Some _ |- _ => rename Hf into Hfl end.
  (* ENTRY: alloc the _dest shadow, bind params *)
  inv Hentry.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ => cbn [fn_vars] in Ha; inv Ha end.
  match goal with Ha : alloc_variables _ _ _ nil _ _ |- _ => inv Ha end.
  match goal with Halc : Mem.alloc _ _ _ = (_, ?bb) |- _ =>
    assert (Hbd_bm : bb <> bm)
      by (intro EE; subst bb; exact (Mem.fresh_block_alloc _ _ _ _ _ Halc Hv));
    assert (Hbd_bo : bb <> b_out)
      by (intro EE; subst bb; exact (Mem.fresh_block_alloc _ _ _ _ _ Halc Hbov));
    assert (Hedest : (PTree.set math_util._dest (bb, tptr tfloat) empty_env)
                       ! math_util._dest = Some (bb, tptr tfloat)) by (apply PTree.gss)
  end.
  match goal with Halc : Mem.alloc _ _ _ = (?mm, _) |- _ =>
    assert (HmwfA : MWF mm) by (eapply Halloc; [ exact Halc | exact Hmwf ]);
    assert (HvA : Mem.valid_block mm bm)
      by (eapply Mem.valid_block_alloc; [ exact Halc | exact Hv ]);
    assert (HsatA : action_sat not_tainted mm bm)
      by (eapply action_sat_unchanged_on;
          [ eapply Mem.alloc_unchanged_on; exact Halc | exact Hv | exact Hsat ])
  end.
  (* le!_dest = Vptr b_out oo *)
  destruct vargs as [| a0 vargs1]; cbn [hd_error] in Hhd; [ discriminate Hhd | ].
  injection Hhd as ->.
  match goal with Hbp : bind_parameter_temps _ _ _ = Some ?LE |- _ =>
    cbn [fn_params] in Hbp;
    assert (Hled : LE ! math_util._dest = Some (Vptr b_out oo))
      by (eapply bind_parameter_temps_head; [ | exact Hbp ];
          cbn [var_names map fst]; intros [E|[E|[E|E]]]; try discriminate E; exact E)
  end.
  (* WALK: shadow store, then three vec3f_set store blocks, then Sreturn+free *)
  cbn [fn_body] in Hbody.
  peelseq.
  match goal with HA : exec_stmt _ _ _ _ _ (Sassign (Evar _ _) _) _ _ _ _ |- _ =>
    rename HA into HA0 end.
  destruct (vec_shadow_store _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
              Hstore Hedest Hled Hbd_bm HA0 HvA HsatA HmwfA)
    as (Hv1 & Hs1 & Hm1 & Hload1).
  peelseq.
  match goal with HB : exec_stmt _ _ _ _ _ (Ssequence (Sset _ _) (Sassign (Ederef _ _) _)) _ _ _ _ |- _ =>
    rename HB into HB0 end.
  destruct (vec_block_set _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
              Hstore Hacf Hedest Hload1 Hbne (not_eq_sym Hbd_bo) HB0 Hv1 Hs1 Hm1)
    as (Hv2 & Hs2 & Hm2 & Hload2).
  peelseq.
  match goal with HC : exec_stmt _ _ _ _ _ (Ssequence (Sset _ _) (Sassign (Ederef _ _) _)) _ _ _ _ |- _ =>
    rename HC into HC0 end.
  destruct (vec_block_set _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
              Hstore Hacf Hedest Hload2 Hbne (not_eq_sym Hbd_bo) HC0 Hv2 Hs2 Hm2)
    as (Hv3 & Hs3 & Hm3 & Hload3).
  peelseq.
  match goal with HD : exec_stmt _ _ _ _ _ (Ssequence (Sset _ _) (Sassign (Ederef _ _) _)) _ _ _ _ |- _ =>
    rename HD into HD0 end.
  destruct (vec_block_set _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
              Hstore Hacf Hedest Hload3 Hbne (not_eq_sym Hbd_bo) HD0 Hv3 Hs3 Hm3)
    as (Hv4 & Hs4 & Hm4 & Hload4).
  (* Sreturn: memory unchanged *)
  match goal with HRet : exec_stmt _ _ _ _ _ (Sreturn _) _ _ _ _ |- _ => inv HRet end.
  (* EXIT: free the sole shadow block (bm-distinct) *)
  rewrite blocks_of_env_mu_dest in Hfl.
  match goal with |- _ =>
    assert (Hforall : Forall (fun blh => let '(b,_,_) := blh in b <> bm)
                        ((_, 0, sizeof ge (tptr tfloat)) :: nil))
      by (constructor; [ exact Hbd_bm | constructor ])
  end.
  destruct (vfc_free_list_frame not_tainted bm _ _ _ Hforall Hfl Hv4 Hs4) as (Hvf & Hsf).
  split; [ exact Hvf | split; [ exact Hsf | ] ].
  eapply Hfree; [ exact Hfl | exact Hm4 ].
Qed.

(* ---------------------------------------------------------------------- *)
(* vec3f_copy body frame: same out-param gate; each store block reads      *)
(* src[i] into a temp then writes dest[i] through the shadow-reloaded      *)
(* out-param pointer (vec_block_copy shape).                               *)
(* ---------------------------------------------------------------------- *)
Lemma vec3f_copy_body_frame :
  forall (ge : genv) (MWF : mem -> Prop) (bm b_out : block) (oo : ptrofs),
    (forall m lo hi m'' b, Mem.alloc m lo hi = (m'', b) -> MWF m -> MWF m'') ->
    (forall m2 m3 l, Mem.free_list m2 l = Some m3 -> MWF m2 -> MWF m3) ->
    (forall ch b0 o0 v0 m1 m2,
        b0 <> bm -> Mem.store ch m1 b0 o0 v0 = Some m2 -> MWF m1 -> MWF m2) ->
    forall m vargs t m' vres,
      eval_funcall function_entry2 ge m
        (Internal math_util.f_vec3f_copy) vargs t m' vres ->
      hd_error vargs = Some (Vptr b_out oo) ->
      b_out <> bm -> Mem.valid_block m b_out ->
      Mem.valid_block m bm -> action_sat not_tainted m bm -> MWF m ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m'.
Proof.
  intros ge MWF bm b_out oo Halloc Hfree Hstore m vargs t m' vres
         Hevf Hhd Hbne Hbov Hv Hsat Hmwf.
  assert (Hacf : access_mode tfloat = By_value Mfloat32) by reflexivity.
  assert (Hne56 : math_util._t'5 <> math_util._t'6) by (cbv; discriminate).
  assert (Hne34 : math_util._t'3 <> math_util._t'4) by (cbv; discriminate).
  assert (Hne12 : math_util._t'1 <> math_util._t'2) by (cbv; discriminate).
  unfold math_util.f_vec3f_copy in Hevf.
  inv Hevf.
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry end.
  match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody end.
  match goal with Hf : Mem.free_list _ _ = Some _ |- _ => rename Hf into Hfl end.
  inv Hentry.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ => cbn [fn_vars] in Ha; inv Ha end.
  match goal with Ha : alloc_variables _ _ _ nil _ _ |- _ => inv Ha end.
  match goal with Halc : Mem.alloc _ _ _ = (_, ?bb) |- _ =>
    assert (Hbd_bm : bb <> bm)
      by (intro EE; subst bb; exact (Mem.fresh_block_alloc _ _ _ _ _ Halc Hv));
    assert (Hbd_bo : bb <> b_out)
      by (intro EE; subst bb; exact (Mem.fresh_block_alloc _ _ _ _ _ Halc Hbov));
    assert (Hedest : (PTree.set math_util._dest (bb, tptr tfloat) empty_env)
                       ! math_util._dest = Some (bb, tptr tfloat)) by (apply PTree.gss)
  end.
  match goal with Halc : Mem.alloc _ _ _ = (?mm, _) |- _ =>
    assert (HmwfA : MWF mm) by (eapply Halloc; [ exact Halc | exact Hmwf ]);
    assert (HvA : Mem.valid_block mm bm)
      by (eapply Mem.valid_block_alloc; [ exact Halc | exact Hv ]);
    assert (HsatA : action_sat not_tainted mm bm)
      by (eapply action_sat_unchanged_on;
          [ eapply Mem.alloc_unchanged_on; exact Halc | exact Hv | exact Hsat ])
  end.
  destruct vargs as [| a0 vargs1]; cbn [hd_error] in Hhd; [ discriminate Hhd | ].
  injection Hhd as ->.
  match goal with Hbp : bind_parameter_temps _ _ _ = Some ?LE |- _ =>
    cbn [fn_params] in Hbp;
    assert (Hled : LE ! math_util._dest = Some (Vptr b_out oo))
      by (eapply bind_parameter_temps_head; [ | exact Hbp ];
          cbn [var_names map fst]; intros [E|E]; try discriminate E; exact E)
  end.
  cbn [fn_body] in Hbody.
  peelseq.
  match goal with HA : exec_stmt _ _ _ _ _ (Sassign (Evar _ _) _) _ _ _ _ |- _ =>
    rename HA into HA0 end.
  destruct (vec_shadow_store _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
              Hstore Hedest Hled Hbd_bm HA0 HvA HsatA HmwfA)
    as (Hv1 & Hs1 & Hm1 & Hload1).
  peelseq.
  match goal with HB : exec_stmt _ _ _ _ _ (Ssequence (Sset _ _) (Ssequence (Sset _ _) (Sassign (Ederef _ _) _))) _ _ _ _ |- _ =>
    rename HB into HB0 end.
  destruct (vec_block_copy _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
              Hstore Hacf Hedest Hload1 Hbne (not_eq_sym Hbd_bo) Hne56 HB0 Hv1 Hs1 Hm1)
    as (Hv2 & Hs2 & Hm2 & Hload2).
  peelseq.
  match goal with HC : exec_stmt _ _ _ _ _ (Ssequence (Sset _ _) (Ssequence (Sset _ _) (Sassign (Ederef _ _) _))) _ _ _ _ |- _ =>
    rename HC into HC0 end.
  destruct (vec_block_copy _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
              Hstore Hacf Hedest Hload2 Hbne (not_eq_sym Hbd_bo) Hne34 HC0 Hv2 Hs2 Hm2)
    as (Hv3 & Hs3 & Hm3 & Hload3).
  peelseq.
  match goal with HD : exec_stmt _ _ _ _ _ (Ssequence (Sset _ _) (Ssequence (Sset _ _) (Sassign (Ederef _ _) _))) _ _ _ _ |- _ =>
    rename HD into HD0 end.
  destruct (vec_block_copy _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
              Hstore Hacf Hedest Hload3 Hbne (not_eq_sym Hbd_bo) Hne12 HD0 Hv3 Hs3 Hm3)
    as (Hv4 & Hs4 & Hm4 & Hload4).
  match goal with HRet : exec_stmt _ _ _ _ _ (Sreturn _) _ _ _ _ |- _ => inv HRet end.
  rewrite blocks_of_env_mu_dest in Hfl.
  assert (Hforall : Forall (fun blh => let '(b,_,_) := blh in b <> bm)
                      ((_, 0, sizeof ge (tptr tfloat)) :: nil))
    by (constructor; [ exact Hbd_bm | constructor ]).
  destruct (vfc_free_list_frame not_tainted bm _ _ _ Hforall Hfl Hv4 Hs4) as (Hvf & Hsf).
  split; [ exact Hvf | split; [ exact Hsf | ] ].
  eapply Hfree; [ exact Hfl | exact Hm4 ].
Qed.

(* ---------------------------------------------------------------------- *)
(* vec3s_copy body frame: tshort twin of vec3f_copy (Mint16signed store).  *)
(* ---------------------------------------------------------------------- *)
Lemma vec3s_copy_body_frame :
  forall (ge : genv) (MWF : mem -> Prop) (bm b_out : block) (oo : ptrofs),
    (forall m lo hi m'' b, Mem.alloc m lo hi = (m'', b) -> MWF m -> MWF m'') ->
    (forall m2 m3 l, Mem.free_list m2 l = Some m3 -> MWF m2 -> MWF m3) ->
    (forall ch b0 o0 v0 m1 m2,
        b0 <> bm -> Mem.store ch m1 b0 o0 v0 = Some m2 -> MWF m1 -> MWF m2) ->
    forall m vargs t m' vres,
      eval_funcall function_entry2 ge m
        (Internal math_util.f_vec3s_copy) vargs t m' vres ->
      hd_error vargs = Some (Vptr b_out oo) ->
      b_out <> bm -> Mem.valid_block m b_out ->
      Mem.valid_block m bm -> action_sat not_tainted m bm -> MWF m ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m'.
Proof.
  intros ge MWF bm b_out oo Halloc Hfree Hstore m vargs t m' vres
         Hevf Hhd Hbne Hbov Hv Hsat Hmwf.
  assert (Hacs : access_mode tshort = By_value Mint16signed) by reflexivity.
  assert (Hne56 : math_util._t'5 <> math_util._t'6) by (cbv; discriminate).
  assert (Hne34 : math_util._t'3 <> math_util._t'4) by (cbv; discriminate).
  assert (Hne12 : math_util._t'1 <> math_util._t'2) by (cbv; discriminate).
  unfold math_util.f_vec3s_copy in Hevf.
  inv Hevf.
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry end.
  match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody end.
  match goal with Hf : Mem.free_list _ _ = Some _ |- _ => rename Hf into Hfl end.
  inv Hentry.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ => cbn [fn_vars] in Ha; inv Ha end.
  match goal with Ha : alloc_variables _ _ _ nil _ _ |- _ => inv Ha end.
  match goal with Halc : Mem.alloc _ _ _ = (_, ?bb) |- _ =>
    assert (Hbd_bm : bb <> bm)
      by (intro EE; subst bb; exact (Mem.fresh_block_alloc _ _ _ _ _ Halc Hv));
    assert (Hbd_bo : bb <> b_out)
      by (intro EE; subst bb; exact (Mem.fresh_block_alloc _ _ _ _ _ Halc Hbov));
    assert (Hedest : (PTree.set math_util._dest (bb, tptr tshort) empty_env)
                       ! math_util._dest = Some (bb, tptr tshort)) by (apply PTree.gss)
  end.
  match goal with Halc : Mem.alloc _ _ _ = (?mm, _) |- _ =>
    assert (HmwfA : MWF mm) by (eapply Halloc; [ exact Halc | exact Hmwf ]);
    assert (HvA : Mem.valid_block mm bm)
      by (eapply Mem.valid_block_alloc; [ exact Halc | exact Hv ]);
    assert (HsatA : action_sat not_tainted mm bm)
      by (eapply action_sat_unchanged_on;
          [ eapply Mem.alloc_unchanged_on; exact Halc | exact Hv | exact Hsat ])
  end.
  destruct vargs as [| a0 vargs1]; cbn [hd_error] in Hhd; [ discriminate Hhd | ].
  injection Hhd as ->.
  match goal with Hbp : bind_parameter_temps _ _ _ = Some ?LE |- _ =>
    cbn [fn_params] in Hbp;
    assert (Hled : LE ! math_util._dest = Some (Vptr b_out oo))
      by (eapply bind_parameter_temps_head; [ | exact Hbp ];
          cbn [var_names map fst]; intros [E|E]; try discriminate E; exact E)
  end.
  cbn [fn_body] in Hbody.
  peelseq.
  match goal with HA : exec_stmt _ _ _ _ _ (Sassign (Evar _ _) _) _ _ _ _ |- _ =>
    rename HA into HA0 end.
  destruct (vec_shadow_store _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
              Hstore Hedest Hled Hbd_bm HA0 HvA HsatA HmwfA)
    as (Hv1 & Hs1 & Hm1 & Hload1).
  peelseq.
  match goal with HB : exec_stmt _ _ _ _ _ (Ssequence (Sset _ _) (Ssequence (Sset _ _) (Sassign (Ederef _ _) _))) _ _ _ _ |- _ =>
    rename HB into HB0 end.
  destruct (vec_block_copy _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
              Hstore Hacs Hedest Hload1 Hbne (not_eq_sym Hbd_bo) Hne56 HB0 Hv1 Hs1 Hm1)
    as (Hv2 & Hs2 & Hm2 & Hload2).
  peelseq.
  match goal with HC : exec_stmt _ _ _ _ _ (Ssequence (Sset _ _) (Ssequence (Sset _ _) (Sassign (Ederef _ _) _))) _ _ _ _ |- _ =>
    rename HC into HC0 end.
  destruct (vec_block_copy _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
              Hstore Hacs Hedest Hload2 Hbne (not_eq_sym Hbd_bo) Hne34 HC0 Hv2 Hs2 Hm2)
    as (Hv3 & Hs3 & Hm3 & Hload3).
  peelseq.
  match goal with HD : exec_stmt _ _ _ _ _ (Ssequence (Sset _ _) (Ssequence (Sset _ _) (Sassign (Ederef _ _) _))) _ _ _ _ |- _ =>
    rename HD into HD0 end.
  destruct (vec_block_copy _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
              Hstore Hacs Hedest Hload3 Hbne (not_eq_sym Hbd_bo) Hne12 HD0 Hv3 Hs3 Hm3)
    as (Hv4 & Hs4 & Hm4 & Hload4).
  match goal with HRet : exec_stmt _ _ _ _ _ (Sreturn _) _ _ _ _ |- _ => inv HRet end.
  rewrite blocks_of_env_mu_dest in Hfl.
  assert (Hforall : Forall (fun blh => let '(b,_,_) := blh in b <> bm)
                      ((_, 0, sizeof ge (tptr tshort)) :: nil))
    by (constructor; [ exact Hbd_bm | constructor ]).
  destruct (vfc_free_list_frame not_tainted bm _ _ _ Hforall Hfl Hv4 Hs4) as (Hvf & Hsf).
  split; [ exact Hvf | split; [ exact Hsf | ] ].
  eapply Hfree; [ exact Hfl | exact Hm4 ].
Qed.
