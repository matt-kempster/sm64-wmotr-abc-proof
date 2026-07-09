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

(* ====================================================================== *)
(* 6. f32_find_wall_collision: the heaviest of the 6 writers (task #90).   *)
(*                                                                        *)
(* STORE-SCOUT VERDICT (per-Sassign classification against the generated  *)
(* surface_collision AST at :1727, verified — NOT trusted from §2b):      *)
(*   fn_vars := [(_collision, Tstruct _WallCollisionData noattr)]  (ONE    *)
(*   own local struct).  9 Sassign total:                                  *)
(*   (a) OWN FN_VAR (into _collision fields, safe own frame):              *)
(*        :1741 collision.offsetY | :1745 collision.radius                 *)
(*        :1751 collision.x       | :1757 collision.y                      *)
(*        :1763 collision.z       | :1767 collision.numWalls (tshort)      *)
(*   (b) OUT-PARAM write-back through *xPtr/*yPtr/*zPtr (3 float pointers): *)
(*        :1786 *xPtr = collision.x | :1794 *yPtr = collision.y            *)
(*        :1802 *zPtr = collision.z                                        *)
(*   (c) STATIC GLOBAL / other: NONE.                                      *)
(*   Callee (RIPPLE, carried as an oracle): _find_wall_collisions at :1772 *)
(*        called with (Eaddrof (Evar _collision)) = &collision — writes    *)
(*        ONLY into the own local struct block; frame-preservation carried *)
(*        as a SATISFIABLE callee oracle (analogue of the atan2s oracle),  *)
(*        discharged at wiring from find_wall_collisions' own body frame.  *)
(* VERDICT: OUT-PARAM-ONLY (no statics).  Gated fact: the 3 out-param      *)
(* pointers are caller-locals <> bm, plus the callee oracle.  Plain        *)
(* body_pres is PHANTOM-FALSE (adversarial *xPtr = Vptr bm 12 hits the     *)
(* action cell) — same class as vec3f_set / the wl/wol keystones.          *)
(* ====================================================================== *)

(* --- ge-generic base bricks (mirrors LocalVarsSurface's lp-specific ones,
   but over an arbitrary genv and the store-off-bm frame, not `carried`) --- *)

(* eval_expr of a local-bound Evar of STRUCT type decays By_reference to its
   env block. *)
Lemma sc_eval_expr_evar_local_struct_block :
  forall ge e le m lid sid sattr b tyenv loc o,
    e ! lid = Some (b, tyenv) ->
    eval_expr ge e le m (Evar lid (Tstruct sid sattr)) (Vptr loc o) ->
    loc = b.
Proof.
  intros ge e le m lid sid sattr b tyenv loc o He Hev.
  inv Hev.
  match goal with Hlv : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ =>
    inv Hlv;
    [ | match goal with Hn : _ ! lid = None |- _ => rewrite He in Hn; discriminate Hn end ]
  end.
  match goal with Hd : deref_loc (typeof _) _ _ _ _ _ |- _ => cbn [typeof] in Hd end.
  match goal with Hd : deref_loc (Tstruct _ _) _ _ _ _ (Vptr _ _) |- _ => inv Hd end;
    try (match goal with Har : access_mode (Tstruct _ _) = _ |- _ =>
           cbn in Har; discriminate Har end);
    congruence.
Qed.

(* One OWN-FRAME field store `collision.fld = rhs` (Efield of a local Evar):
   the store lands in the local block b_coll; b_coll <> bm preserves the frame.
   All three assign_loc modes bottom out in a storev into b_coll (By_copy is
   refuted by access_mode = By_value). *)
Lemma sc_efield_local_store :
  forall (MWF : mem -> Prop) (Q : int -> Prop) bm b_coll sid sattr fld fty ch
         ge e le m a2 t le' m' out,
    (forall c b0 o0 v0 m1 m2,
        b0 <> bm -> Mem.store c m1 b0 o0 v0 = Some m2 -> MWF m1 -> MWF m2) ->
    e ! surface_collision._collision = Some (b_coll, Tstruct sid sattr) ->
    b_coll <> bm ->
    access_mode fty = By_value ch ->
    exec_stmt function_entry2 ge e le m
      (Sassign (Efield (Evar surface_collision._collision (Tstruct sid sattr)) fld fty) a2)
      t le' m' out ->
    Mem.valid_block m bm -> action_sat Q m bm -> MWF m ->
    Mem.valid_block m' bm /\ action_sat Q m' bm /\ MWF m' /\ le' = le /\ out = Out_normal.
Proof.
  intros MWF Q bm b_coll sid sattr fld fty ch ge e le m a2 t le' m' out
         Hstore Hcoll Hbne Hacc Hexec Hv Hsat Hmwf.
  inv Hexec.
  match goal with Hlv : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ =>
    destruct (RealFrameValue.eval_lvalue_Efield_base _ _ _ _ _ _ _ _ _ _ Hlv) as (o0 & Hbase) end.
  pose proof (sc_eval_expr_evar_local_struct_block _ _ _ _ _ _ _ _ _ _ _ Hcoll Hbase) as Hloc.
  subst.
  match goal with Hass : assign_loc _ (typeof _) _ _ _ _ _ m' |- _ =>
    cbn [typeof] in Hass; inv Hass end.
  - match goal with Hstv : Mem.storev _ _ (Vptr _ _) _ = Some m' |- _ =>
      unfold Mem.storev in Hstv;
      destruct (store_off_bm_pres MWF Q bm b_coll _ _ _ m m' Hstore Hbne Hstv Hv Hsat Hmwf)
        as (Hv' & Hsat' & Hmwf') end.
    split;[exact Hv'|split;[exact Hsat'|split;[exact Hmwf'|split;reflexivity]]].
  - match goal with Hco : access_mode fty = By_copy |- _ =>
      rewrite Hacc in Hco; discriminate Hco end.
  - match goal with Hsb : store_bitfield _ _ _ _ _ _ (Vptr _ _) _ _ _ |- _ => inv Hsb end.
    match goal with Hstv : Mem.storev _ _ (Vptr _ _) _ = Some m' |- _ =>
      unfold Mem.storev in Hstv;
      destruct (store_off_bm_pres MWF Q bm b_coll _ _ _ m m' Hstore Hbne Hstv Hv Hsat Hmwf)
        as (Hv' & Hsat' & Hmwf') end.
    split;[exact Hv'|split;[exact Hsat'|split;[exact Hmwf'|split;reflexivity]]].
Qed.

(* One OUT-PARAM write-back `*(Etempvar ptr) = rhs` (Ederef of a param temp):
   the store lands in the block the temp holds (b_out); b_out <> bm preserves
   the frame.  bf = Full (Ederef), so only By_value/By_copy; By_copy refuted. *)
Lemma sc_deref_temp_store :
  forall (MWF : mem -> Prop) (Q : int -> Prop) bm b_out o' T chk
         ge e le m tid a2 t le' m' out,
    (forall c b0 o0 v0 m1 m2,
        b0 <> bm -> Mem.store c m1 b0 o0 v0 = Some m2 -> MWF m1 -> MWF m2) ->
    access_mode T = By_value chk ->
    le ! tid = Some (Vptr b_out o') ->
    b_out <> bm ->
    exec_stmt function_entry2 ge e le m
      (Sassign (Ederef (Etempvar tid (tptr T)) T) a2) t le' m' out ->
    Mem.valid_block m bm -> action_sat Q m bm -> MWF m ->
    Mem.valid_block m' bm /\ action_sat Q m' bm /\ MWF m' /\ le' = le /\ out = Out_normal.
Proof.
  intros MWF Q bm b_out o' T chk ge e le m tid a2 t le' m' out
         Hstore Hacc Htid Hbne Hexec Hv Hsat Hmwf.
  inv Hexec.
  match goal with Hlv : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hlv end.
  match goal with Hev : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
    apply RealFrameValue.eval_expr_Etempvar_val in Hev; rewrite Htid in Hev;
    injection Hev as <- <- end.
  match goal with Hass : assign_loc _ (typeof _) _ _ _ Full _ _ |- _ =>
    cbn [typeof] in Hass; inv Hass end;
  [ | match goal with Hco : access_mode T = By_copy |- _ =>
        rewrite Hacc in Hco; discriminate Hco end ].
  match goal with Hstv : Mem.storev _ _ _ _ = Some _ |- _ =>
    unfold Mem.storev in Hstv;
    destruct (store_off_bm_pres MWF Q bm b_out _ _ _ m m' Hstore Hbne Hstv Hv Hsat Hmwf)
      as (Hv' & Hsat' & Hmwf') end.
  split;[exact Hv'|split;[exact Hsat'|split;[exact Hmwf'|split;reflexivity]]].
Qed.

(* The three out-param pointer temps, preserved across every temp-set. *)
Definition three_ptr (le : temp_env) (bx by_ bz : block) (ox oy oz : ptrofs) : Prop :=
  le ! surface_collision._xPtr = Some (Vptr bx ox) /\
  le ! surface_collision._yPtr = Some (Vptr by_ oy) /\
  le ! surface_collision._zPtr = Some (Vptr bz oz).

Lemma three_ptr_set : forall le q v bx by_ bz ox oy oz,
  q <> surface_collision._xPtr -> q <> surface_collision._yPtr ->
  q <> surface_collision._zPtr ->
  three_ptr le bx by_ bz ox oy oz ->
  three_ptr (PTree.set q v le) bx by_ bz ox oy oz.
Proof.
  intros le q v bx by_ bz ox oy oz H1 H2 H3 (A & B & C).
  unfold three_ptr; repeat split;
    rewrite PTree.gso by (apply not_eq_sym; assumption); assumption.
Qed.

Lemma three_ptr_x : forall le bx by_ bz ox oy oz,
  three_ptr le bx by_ bz ox oy oz -> le ! surface_collision._xPtr = Some (Vptr bx ox).
Proof. unfold three_ptr; intros le bx by_ bz ox oy oz (A & _ & _); exact A. Qed.
Lemma three_ptr_y : forall le bx by_ bz ox oy oz,
  three_ptr le bx by_ bz ox oy oz -> le ! surface_collision._yPtr = Some (Vptr by_ oy).
Proof. unfold three_ptr; intros le bx by_ bz ox oy oz (_ & B & _); exact B. Qed.
Lemma three_ptr_z : forall le bx by_ bz ox oy oz,
  three_ptr le bx by_ bz ox oy oz -> le ! surface_collision._zPtr = Some (Vptr bz oz).
Proof. unfold three_ptr; intros le bx by_ bz ox oy oz (_ & _ & C); exact C. Qed.

(* An Sset of a temp <> the 3 ptrs: memory identity, three_ptr preserved. *)
Lemma sc_sset_tp :
  forall ge e le m id a t le' m' out bx by_ bz ox oy oz,
    exec_stmt function_entry2 ge e le m (Sset id a) t le' m' out ->
    three_ptr le bx by_ bz ox oy oz ->
    id <> surface_collision._xPtr -> id <> surface_collision._yPtr ->
    id <> surface_collision._zPtr ->
    m' = m /\ out = Out_normal /\ three_ptr le' bx by_ bz ox oy oz.
Proof.
  intros ge e le m id a t le' m' out bx by_ bz ox oy oz Hexec Htp H1 H2 H3.
  inv Hexec. split;[reflexivity|split;[reflexivity|]]. apply three_ptr_set; assumption.
Qed.

(* The _find_wall_collisions callee recognizer + its frame oracle. *)
Definition is_fwc_call (a : expr) : bool :=
  match a with
  | Evar id _ => Pos.eqb id surface_collision._find_wall_collisions
  | _ => false
  end.

Lemma sc_fwc_call_frame :
  forall (MWF : mem -> Prop) bm ge
    (Hcall : forall e le m a vf f vargs t m' vres,
        is_fwc_call a = true ->
        eval_expr ge e le m a vf ->
        Genv.find_funct ge vf = Some f ->
        eval_funcall function_entry2 ge m f vargs t m' vres ->
        Mem.valid_block m bm -> action_sat not_tainted m bm -> MWF m ->
        Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m')
    e le m optid tyf al t le' m' out,
    exec_stmt function_entry2 ge e le m
      (Scall optid (Evar surface_collision._find_wall_collisions tyf) al) t le' m' out ->
    Mem.valid_block m bm -> action_sat not_tainted m bm -> MWF m ->
    Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m'
      /\ out = Out_normal /\ exists v, le' = set_opttemp optid v le.
Proof.
  intros MWF bm ge Hcall e le m optid tyf al t le' m' out Hexec Hv Hsat Hmwf.
  assert (Hrec : is_fwc_call (Evar surface_collision._find_wall_collisions tyf) = true)
    by (vm_compute; reflexivity).
  inv Hexec.
  match goal with
  | Hee : eval_expr _ _ _ _ (Evar _ _) ?vf,
    Hff : Genv.find_funct _ ?vf = Some ?f,
    Hfc : eval_funcall _ _ _ ?f _ _ _ _ |- _ =>
      edestruct (Hcall _ _ _ _ _ _ _ _ _ _ Hrec Hee Hff Hfc Hv Hsat Hmwf)
        as (Hv' & Hsat' & Hmwf')
  end.
  split;[exact Hv'|split;[exact Hsat'|split;[exact Hmwf'|split;[reflexivity|eexists;reflexivity]]]].
Qed.

Lemma blocks_of_env_sc_collision : forall ge b sid sattr,
  blocks_of_env ge
    (PTree.set surface_collision._collision (b, Tstruct sid sattr) empty_env)
    = (b, 0, sizeof ge (Tstruct sid sattr)) :: nil.
Proof.
  intros ge b sid sattr. unfold blocks_of_env.
  replace (PTree.elements
             (PTree.set surface_collision._collision (b, Tstruct sid sattr) empty_env))
    with ((surface_collision._collision, (b, Tstruct sid sattr))
            :: (@nil (positive * (block*type))))
    by (vm_compute; reflexivity).
  cbn [map block_of_binding]. reflexivity.
Qed.

(* le!_xPtr/_yPtr/_zPtr = the 3 head args (params norepet). *)
Lemma fwc_bind_three :
  forall a0 a1 a2 a3 a4 tx ty tz to tr te le,
    bind_parameter_temps
      ((surface_collision._xPtr, tx) :: (surface_collision._yPtr, ty) ::
       (surface_collision._zPtr, tz) :: (surface_collision._offsetY, to) ::
       (surface_collision._radius, tr) :: nil)
      (a0 :: a1 :: a2 :: a3 :: a4 :: nil) te = Some le ->
    le ! surface_collision._xPtr = Some a0 /\
    le ! surface_collision._yPtr = Some a1 /\
    le ! surface_collision._zPtr = Some a2.
Proof.
  intros a0 a1 a2 a3 a4 tx ty tz to tr te le Hbp.
  cbn [bind_parameter_temps] in Hbp. injection Hbp as <-.
  repeat split;
    (repeat (rewrite PTree.gso by (vm_compute; discriminate)); apply PTree.gss).
Qed.

(* straight-line-or-call recognizer: refutes the spurious Sseq_2 branch for a
   first-component block that may contain a Scall (vs. sl_chk which cannot). *)
Fixpoint slc_chk (s : statement) : bool :=
  match s with
  | Sset _ _ => true
  | Sassign _ _ => true
  | Scall _ _ _ => true
  | Ssequence s1 s2 => slc_chk s1 && slc_chk s2
  | _ => false
  end.

Lemma sl_out_normal_call :
  forall ge e le m s t le' m' out,
    exec_stmt function_entry2 ge e le m s t le' m' out ->
    slc_chk s = true -> out = Out_normal.
Proof.
  intros ge e le m s t le' m' out Hex.
  induction Hex; intros Hchk; cbn in Hchk; try discriminate Hchk; try reflexivity.
  - (* Sseq_1 *) apply andb_prop in Hchk as [_ H2]. exact (IHHex2 H2).
  - (* Sseq_2 *) apply andb_prop in Hchk as [H1 _]. specialize (IHHex H1). congruence.
Qed.

Ltac peelc H :=
  inv H;
  [ | match goal with
      | Hs : exec_stmt _ _ _ _ _ _ _ _ _ ?o, Hne : ?o <> Out_normal |- _ =>
          exfalso; apply Hne;
          eapply sl_out_normal_call; [ exact Hs | vm_compute; reflexivity ]
      end ].

(* Fully-applied step tactics (no leftover subgoals); reference the ambient
   Hstore/Hecoll/Hcoll_bm/Hacf of the body walk. *)
Ltac ssettp Hset Htp Em Ht :=
  edestruct (sc_sset_tp _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ Hset Htp
    ltac:(vm_compute; discriminate) ltac:(vm_compute; discriminate)
    ltac:(vm_compute; discriminate)) as (Em & _ & Ht).

Ltac efst Hst Hec Hcb Hexec Hac Hv Hs Hm Hv' Hs' Hm' Hr :=
  let Hle := fresh "Hle" in
  edestruct (sc_efield_local_store _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
    Hst Hec Hcb Hac Hexec Hv Hs Hm) as (Hv' & Hs' & Hm' & Hle & _);
  rewrite Hle in Hr; clear Hle.

Ltac drst Hst Hac Hexec Htid Hbne Hv Hs Hm Hv' Hs' Hm' Hr :=
  let Hle := fresh "Hle" in
  edestruct (sc_deref_temp_store _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
    Hst Hac Htid Hbne Hexec Hv Hs Hm) as (Hv' & Hs' & Hm' & Hle & _);
  rewrite Hle in Hr; clear Hle.

(* ---------------------------------------------------------------------- *)
(* f32_find_wall_collision body frame: gated on the 3 out-param pointers    *)
(* (each a caller block <> bm) and the _find_wall_collisions callee oracle. *)
(* ge-generic; consumed at the atomic wiring commit where ge := lp_ge lp,   *)
(* the 3 out-params are caller stack locals (<> bm by the wl/wol local      *)
(* gate) and the oracle is discharged from find_wall_collisions' own frame. *)
(* ---------------------------------------------------------------------- *)
Lemma f32_find_wall_collision_body_frame :
  forall (ge : genv) (MWF : mem -> Prop)
         (bm b_xout b_yout b_zout : block) (oxo oyo ozo : ptrofs),
    (forall m lo hi m'' b, Mem.alloc m lo hi = (m'', b) -> MWF m -> MWF m'') ->
    (forall m2 m3 l, Mem.free_list m2 l = Some m3 -> MWF m2 -> MWF m3) ->
    (forall c b0 o0 v0 m1 m2,
        b0 <> bm -> Mem.store c m1 b0 o0 v0 = Some m2 -> MWF m1 -> MWF m2) ->
    (forall e le m a vf f vargs t m' vres,
        is_fwc_call a = true ->
        eval_expr ge e le m a vf ->
        Genv.find_funct ge vf = Some f ->
        eval_funcall function_entry2 ge m f vargs t m' vres ->
        Mem.valid_block m bm -> action_sat not_tainted m bm -> MWF m ->
        Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m') ->
    forall m vargs t m' vres,
      eval_funcall function_entry2 ge m
        (Internal surface_collision.f_f32_find_wall_collision) vargs t m' vres ->
      nth_error vargs 0 = Some (Vptr b_xout oxo) ->
      nth_error vargs 1 = Some (Vptr b_yout oyo) ->
      nth_error vargs 2 = Some (Vptr b_zout ozo) ->
      b_xout <> bm -> b_yout <> bm -> b_zout <> bm ->
      Mem.valid_block m bm -> action_sat not_tainted m bm -> MWF m ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m'.
Proof.
  intros ge MWF bm b_xout b_yout b_zout oxo oyo ozo Halloc Hfree Hstore Hcall
         m vargs t m' vres Hevf Hn0 Hn1 Hn2 Hbx Hby Hbz Hv Hsat Hmwf.
  assert (Hacf : access_mode tfloat = By_value Mfloat32) by reflexivity.
  assert (Hacs : access_mode tshort = By_value Mint16signed) by reflexivity.
  unfold surface_collision.f_f32_find_wall_collision in Hevf.
  inv Hevf.
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry end.
  match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody end.
  match goal with Hf : Mem.free_list _ _ = Some _ |- _ => rename Hf into Hfl end.
  (* ENTRY: alloc the _collision struct, bind the 5 params *)
  inv Hentry.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ => cbn [fn_vars] in Ha; inv Ha end.
  match goal with Ha : alloc_variables _ _ _ nil _ _ |- _ => inv Ha end.
  match goal with Halc : Mem.alloc _ _ _ = (_, ?bb) |- _ =>
    assert (Hcoll_bm : bb <> bm)
      by (intro EE; subst bb; exact (Mem.fresh_block_alloc _ _ _ _ _ Halc Hv));
    assert (Hecoll : (PTree.set surface_collision._collision
                        (bb, Tstruct surface_collision._WallCollisionData noattr) empty_env)
                       ! surface_collision._collision
                     = Some (bb, Tstruct surface_collision._WallCollisionData noattr))
      by (apply PTree.gss)
  end.
  match goal with Halc : Mem.alloc _ _ _ = (?mm, _) |- _ =>
    assert (HmwfA : MWF mm) by (eapply Halloc;[exact Halc|exact Hmwf]);
    assert (HvA : Mem.valid_block mm bm)
      by (eapply Mem.valid_block_alloc;[exact Halc|exact Hv]);
    assert (HsatA : action_sat not_tainted mm bm)
      by (eapply action_sat_unchanged_on;
          [ eapply Mem.alloc_unchanged_on; exact Halc | exact Hv | exact Hsat ])
  end.
  (* the 3 out-param temps from the bind *)
  match goal with Hbp : bind_parameter_temps _ vargs _ = Some _ |- _ =>
    cbn [fn_params fn_temps] in Hbp;
    destruct vargs as [|a0 [|a1 [|a2 [|a3 [|a4 [|a5 vr]]]]]];
      try (cbn [bind_parameter_temps] in Hbp; discriminate Hbp);
    cbn [nth_error] in Hn0, Hn1, Hn2;
    injection Hn0 as ->; injection Hn1 as ->; injection Hn2 as ->;
    destruct (fwc_bind_three _ _ _ _ _ _ _ _ _ _ _ _ Hbp) as (Hlx & Hly & Hlz)
  end.
  assert (Htp0 : three_ptr _ b_xout b_yout b_zout oxo oyo ozo)
    by (unfold three_ptr; exact (conj Hlx (conj Hly Hlz))).
  cbn [fn_body] in Hbody.
  (* ---- S1: Sset numCollisions 0 ---- *)
  peelc Hbody.
  match goal with H : exec_stmt _ _ _ _ _ (Sset surface_collision._numCollisions _) _ _ _ _ |- _ => rename H into HS1 end.
  match goal with H : exec_stmt _ _ _ _ _ (Ssequence (Sassign (Efield _ surface_collision._offsetY _) _) _) _ _ _ _ |- _ => rename H into R1 end.
  ssettp HS1 Htp0 Em1 Htp1.
  rewrite Em1 in R1.
  (* ---- S2: collision.offsetY = offsetY ---- *)
  peelc R1.
  match goal with H : exec_stmt _ _ _ _ _ (Sassign (Efield _ surface_collision._offsetY _) _) _ _ _ _ |- _ => rename H into HS2 end.
  match goal with H : exec_stmt _ _ _ _ _ (Ssequence (Sassign (Efield _ surface_collision._radius _) _) _) _ _ _ _ |- _ => rename H into R2 end.
  efst Hstore Hecoll Hcoll_bm HS2 Hacf HvA HsatA HmwfA Hv2 Hs2 Hm2 R2.
  (* ---- S3: collision.radius = radius ---- *)
  peelc R2.
  match goal with H : exec_stmt _ _ _ _ _ (Sassign (Efield _ surface_collision._radius _) _) _ _ _ _ |- _ => rename H into HS3 end.
  match goal with H : exec_stmt _ _ _ _ _ (Ssequence (Ssequence (Sset surface_collision._t'7 _) _) _) _ _ _ _ |- _ => rename H into R3 end.
  efst Hstore Hecoll Hcoll_bm HS3 Hacf Hv2 Hs2 Hm2 Hv3 Hs3 Hm3 R3.
  (* ---- S4: t'7 = *xPtr; collision.x = t'7 ---- *)
  peelc R3.
  match goal with H : exec_stmt _ _ _ _ _ (Ssequence (Sset surface_collision._t'7 _) _) _ _ _ _ |- _ => rename H into B4 end.
  match goal with H : exec_stmt _ _ _ _ _ (Ssequence (Ssequence (Sset surface_collision._t'6 _) _) _) _ _ _ _ |- _ => rename H into R4 end.
  peelc B4.
  match goal with H : exec_stmt _ _ _ _ _ (Sset surface_collision._t'7 _) _ _ _ _ |- _ => rename H into HR4 end.
  match goal with H : exec_stmt _ _ _ _ _ (Sassign (Efield _ surface_collision._x _) _) _ _ _ _ |- _ => rename H into HW4 end.
  ssettp HR4 Htp1 Em4 Htp4.
  rewrite Em4 in HW4.
  efst Hstore Hecoll Hcoll_bm HW4 Hacf Hv3 Hs3 Hm3 Hv4 Hs4 Hm4 R4.
  (* ---- S5: t'6 = *yPtr; collision.y = t'6 ---- *)
  peelc R4.
  match goal with H : exec_stmt _ _ _ _ _ (Ssequence (Sset surface_collision._t'6 _) _) _ _ _ _ |- _ => rename H into B5 end.
  match goal with H : exec_stmt _ _ _ _ _ (Ssequence (Ssequence (Sset surface_collision._t'5 _) _) _) _ _ _ _ |- _ => rename H into R5 end.
  peelc B5.
  match goal with H : exec_stmt _ _ _ _ _ (Sset surface_collision._t'6 _) _ _ _ _ |- _ => rename H into HR5 end.
  match goal with H : exec_stmt _ _ _ _ _ (Sassign (Efield _ surface_collision._y _) _) _ _ _ _ |- _ => rename H into HW5 end.
  ssettp HR5 Htp4 Em5 Htp5.
  rewrite Em5 in HW5.
  efst Hstore Hecoll Hcoll_bm HW5 Hacf Hv4 Hs4 Hm4 Hv5 Hs5 Hm5 R5.
  (* ---- S6: t'5 = *zPtr; collision.z = t'5 ---- *)
  peelc R5.
  match goal with H : exec_stmt _ _ _ _ _ (Ssequence (Sset surface_collision._t'5 _) _) _ _ _ _ |- _ => rename H into B6 end.
  match goal with H : exec_stmt _ _ _ _ _ (Ssequence (Sassign (Efield _ surface_collision._numWalls _) _) _) _ _ _ _ |- _ => rename H into R6 end.
  peelc B6.
  match goal with H : exec_stmt _ _ _ _ _ (Sset surface_collision._t'5 _) _ _ _ _ |- _ => rename H into HR6 end.
  match goal with H : exec_stmt _ _ _ _ _ (Sassign (Efield _ surface_collision._z _) _) _ _ _ _ |- _ => rename H into HW6 end.
  ssettp HR6 Htp5 Em6 Htp6.
  rewrite Em6 in HW6.
  efst Hstore Hecoll Hcoll_bm HW6 Hacf Hv5 Hs5 Hm5 Hv6 Hs6 Hm6 R6.
  (* ---- S7: collision.numWalls = 0 (tshort) ---- *)
  peelc R6.
  match goal with H : exec_stmt _ _ _ _ _ (Sassign (Efield _ surface_collision._numWalls _) _) _ _ _ _ |- _ => rename H into HS7 end.
  match goal with H : exec_stmt _ _ _ _ _ (Ssequence (Ssequence (Scall _ _ _) _) _) _ _ _ _ |- _ => rename H into R7 end.
  efst Hstore Hecoll Hcoll_bm HS7 Hacs Hv6 Hs6 Hm6 Hv7 Hs7 Hm7 R7.
  (* ---- S8: t'1 = find_wall_collisions(&collision); numCollisions = t'1 ---- *)
  peelc R7.
  match goal with H : exec_stmt _ _ _ _ _ (Ssequence (Scall _ _ _) _) _ _ _ _ |- _ => rename H into B8 end.
  match goal with H : exec_stmt _ _ _ _ _ (Ssequence (Ssequence (Sset surface_collision._t'4 _) _) _) _ _ _ _ |- _ => rename H into R8 end.
  peelc B8.
  match goal with H : exec_stmt _ _ _ _ _ (Scall _ _ _) _ _ _ _ |- _ => rename H into HC8 end.
  match goal with H : exec_stmt _ _ _ _ _ (Sset surface_collision._numCollisions _) _ _ _ _ |- _ => rename H into HN8 end.
  edestruct (sc_fwc_call_frame _ _ _ Hcall _ _ _ _ _ _ _ _ _ _ HC8 Hv7 Hs7 Hm7)
    as (Hv8 & Hs8 & Hm8 & _ & (vcall & Hlecall)).
  cbn [set_opttemp] in Hlecall.
  assert (Htpcall : three_ptr (PTree.set surface_collision._t'1 vcall _) b_xout b_yout b_zout oxo oyo ozo)
    by (apply three_ptr_set;
        [ vm_compute;discriminate | vm_compute;discriminate | vm_compute;discriminate | exact Htp6 ]).
  rewrite <- Hlecall in Htpcall.
  ssettp HN8 Htpcall Em8 Htp8.
  rewrite Em8 in R8.
  (* ---- S9: t'4 = collision.x; *xPtr = t'4 ---- *)
  peelc R8.
  match goal with H : exec_stmt _ _ _ _ _ (Ssequence (Sset surface_collision._t'4 _) _) _ _ _ _ |- _ => rename H into B9 end.
  match goal with H : exec_stmt _ _ _ _ _ (Ssequence (Ssequence (Sset surface_collision._t'3 _) _) _) _ _ _ _ |- _ => rename H into R9 end.
  peelc B9.
  match goal with H : exec_stmt _ _ _ _ _ (Sset surface_collision._t'4 _) _ _ _ _ |- _ => rename H into HR9 end.
  match goal with H : exec_stmt _ _ _ _ _ (Sassign (Ederef (Etempvar surface_collision._xPtr _) _) _) _ _ _ _ |- _ => rename H into HW9 end.
  ssettp HR9 Htp8 Em9 Htp9.
  rewrite Em9 in HW9.
  drst Hstore Hacf HW9 (three_ptr_x _ _ _ _ _ _ _ Htp9) Hbx Hv8 Hs8 Hm8 Hv9 Hs9 Hm9 R9.
  (* ---- S10: t'3 = collision.y; *yPtr = t'3 ---- *)
  peelc R9.
  match goal with H : exec_stmt _ _ _ _ _ (Ssequence (Sset surface_collision._t'3 _) _) _ _ _ _ |- _ => rename H into B10 end.
  match goal with H : exec_stmt _ _ _ _ _ (Ssequence (Ssequence (Sset surface_collision._t'2 _) _) _) _ _ _ _ |- _ => rename H into R10 end.
  peelc B10.
  match goal with H : exec_stmt _ _ _ _ _ (Sset surface_collision._t'3 _) _ _ _ _ |- _ => rename H into HR10 end.
  match goal with H : exec_stmt _ _ _ _ _ (Sassign (Ederef (Etempvar surface_collision._yPtr _) _) _) _ _ _ _ |- _ => rename H into HW10 end.
  ssettp HR10 Htp9 Em10 Htp10.
  rewrite Em10 in HW10.
  drst Hstore Hacf HW10 (three_ptr_y _ _ _ _ _ _ _ Htp10) Hby Hv9 Hs9 Hm9 Hv10 Hs10 Hm10 R10.
  (* ---- S11: t'2 = collision.z; *zPtr = t'2 ---- *)
  peelc R10.
  match goal with H : exec_stmt _ _ _ _ _ (Ssequence (Sset surface_collision._t'2 _) _) _ _ _ _ |- _ => rename H into B11 end.
  match goal with H : exec_stmt _ _ _ _ _ (Sreturn _) _ _ _ _ |- _ => rename H into HRET end.
  peelc B11.
  match goal with H : exec_stmt _ _ _ _ _ (Sset surface_collision._t'2 _) _ _ _ _ |- _ => rename H into HR11 end.
  match goal with H : exec_stmt _ _ _ _ _ (Sassign (Ederef (Etempvar surface_collision._zPtr _) _) _) _ _ _ _ |- _ => rename H into HW11 end.
  ssettp HR11 Htp10 Em11 Htp11.
  rewrite Em11 in HW11.
  drst Hstore Hacf HW11 (three_ptr_z _ _ _ _ _ _ _ Htp11) Hbz Hv10 Hs10 Hm10 Hv11 Hs11 Hm11 HRET.
  (* ---- S12: return numCollisions (memory unchanged) ---- *)
  inv HRET.
  (* EXIT: free the sole _collision block (bm-distinct) *)
  rewrite blocks_of_env_sc_collision in Hfl.
  match goal with Hfl2 : Mem.free_list _ ?L = Some _ |- _ =>
    assert (Hforall : Forall (fun blh => let '(b,_,_) := blh in b <> bm) L)
      by (constructor; [ exact Hcoll_bm | constructor ]) end.
  destruct (vfc_free_list_frame not_tainted bm _ _ _ Hforall Hfl Hv11 Hs11) as (Hvf & Hsf).
  split; [ exact Hvf | split; [ exact Hsf | eapply Hfree; [ exact Hfl | exact Hm11 ] ] ].
Qed.
