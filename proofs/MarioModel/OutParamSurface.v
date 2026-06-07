(* kept: reusable out-param-aliasing brick for the pointer-writing helpers
   (find_ceil / find_floor) -- NOT yet load-bearing; the wiring step is a
   `pids` call-site arm in the wwalk engine (ActWriterSurface) + the
   perform_hanging_step / set_pole_position walks that consume it.  See the
   header below. *)
(* ====================================================================== *)
(* THE OUT-PARAM-ALIASING SURFACE (the automatic-family keystone).         *)
(*                                                                        *)
(* 8 of the 9 remaining automatic leaves (the 6 pole leaves, act_hang_     *)
(* moving, act_tornado_twirling) route -- via set_pole_position /          *)
(* perform_hanging_step -- through a POINTER-writing out-param helper:      *)
(*   find_ceil (vargs ..,ceil:**Surface)  writes *ceil = <Surface ptr>     *)
(*   find_floor(vargs..,floor:**Surface)  writes *floor = <Surface ptr>    *)
(* (both EF_external in lp; mario.v:12238/12245).  Unlike the FLOAT/short   *)
(* out-param writers (vec3f_copy / vec3s_set / vec3f_set), which can use    *)
(* the UNCONDITIONAL call_pres_ext (a pointer-free write keeps MWF's R4     *)
(* "action cell holds no pointer" even if aimed at the action cell), a     *)
(* find_ceil aimed at the action cell would write a Surface POINTER there   *)
(* and break R4.  So `call_pres_ext find_ceil` (forall vargs) is a         *)
(* PHANTOM-FALSE forall -- the discipline's exact anti-pattern.            *)
(*                                                                        *)
(* THE HONEST REFINEMENT (this file): call_pres_ext_oc -- the same         *)
(* preservation but GATED on the out-param target being a watched-disjoint  *)
(* stack block (local_blk).  In the real program find_ceil's `ceil` is      *)
(* always &(a caller stack-local), so this gate is satisfiable per call     *)
(* site; the phantom forall is replaced by a precise, per-symbol,           *)
(* dischargeable residual (discipline Step 2, refinement).                  *)
(*                                                                        *)
(* `oc_scall_pres` (PROVED here) is the reusable CALL-SITE brick: a         *)
(* `Scall optid (Evar fid ..) args` whose LAST arg evaluates to a          *)
(* local_blk pointer preserves carried, from `call_pres_ext_oc fid`.  This *)
(* is exactly what the wwalk engine's future `pids` arm consumes at each    *)
(* find_ceil / find_floor call site.                                        *)
(* ====================================================================== *)

From Coq Require Import ZArith List.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking.
From SM64.Generated Require mario mario_actions_airborne.
From SM64.Proofs Require Import SymbolicLinking ActionValueFrame RealFrameLinked
  Taint CensusV2 LocalVarsSurface.

Import ListNotations.

Section OutParamArc.
  Variable lp : Clight.program.
  Variable bm : block.
  Variable NoA MWF : mem -> Prop.
  Variable SafeB : block -> Prop.

  Hypothesis HNoA_of_MWF : forall m, MWF m -> NoA m.
  Hypothesis HMWF_alloc : forall m lo hi m' b,
      Mem.alloc m lo hi = (m', b) -> MWF m -> MWF m'.
  Hypothesis HMWF_free : forall m l m',
      Mem.free_list m l = Some m' -> MWF m -> MWF m'.

  (* ---- the out-param target predicate: the LAST argument is a pointer
     into a watched-disjoint stack block (find_ceil/find_floor write only
     through that last out-param). ---- *)
  Fixpoint last_val (vs : list val) : option val :=
    match vs with
    | nil => None
    | x :: nil => Some x
    | _ :: rest => last_val rest
    end.

  Definition last_arg_local (vargs : list val) : Prop :=
    exists b ofs, last_val vargs = Some (Vptr b ofs) /\ local_blk lp bm SafeB b.

  (* a named symbol's lp resolution (zero-offset function pointer) *)
  Definition resolves_lp (fid : ident) (fd : Clight.fundef) : Prop :=
    exists b, Genv.find_symbol (lp_ge lp) fid = Some b /\
              Genv.find_funct (lp_ge lp) (Vptr b Ptrofs.zero) = Some fd.

  (* ---- the ARG-AWARE external residual (the honest refinement of the
     phantom call_pres_ext): preserves the carried run facts PROVIDED the
     out-param target (last arg) is watched-disjoint. ---- *)
  Definition call_pres_ext_oc (fid : ident) : Prop :=
    forall fd m0 vargs0 t0 m1 vres0,
      eval_funcall function_entry2 (lp_ge lp) m0 fd vargs0 t0 m1 vres0 ->
      resolves_lp fid fd ->
      last_arg_local vargs0 ->
      NoA m0 -> MWF m0 -> Mem.valid_block m0 bm ->
      action_sat not_tainted m0 bm ->
      Mem.valid_block m1 bm /\ action_sat not_tainted m1 bm /\
      MWF m1 /\ NoA m1.

  (* ---- a pinned symbol's lp resolution IS its real generated fundef. ---- *)
  Lemma resolve_pin_fd :
    forall (q : Clight.program) (fid : ident) (f_real : Clight.function)
           (fd : Clight.fundef),
      linkorder q lp ->
      (prog_defmap q) ! fid = Some (Gfun (Internal f_real)) ->
      resolves_lp fid fd ->
      fd = Internal f_real.
  Proof.
    intros q fid f_real fd LOq Hdm Hres.
    destruct Hres as (b & Hsym & Hff).
    destruct (linkorder_resolves_funct lp q fid f_real LOq Hdm)
      as (b' & Hsym' & Hff').
    unfold lp_ge in Hsym, Hff.
    rewrite Hsym in Hsym'. injection Hsym' as <-.
    rewrite Hff in Hff'. injection Hff' as <-. reflexivity.
  Qed.

  (* ---- eval_expr of a function-typed Evar whose id is NOT a local in e
     resolves to its symbol pointer (the local branch is refuted by e!id). ---- *)
  Lemma eval_Evar_funct :
    forall e le m fid tyl rty cc vf,
      e ! fid = None ->
      eval_expr (lp_ge lp) e le m (Evar fid (Tfunction tyl rty cc)) vf ->
      exists b, Genv.find_symbol (lp_ge lp) fid = Some b /\
                vf = Vptr b Ptrofs.zero.
  Proof.
    intros e le m fid tyl rty cc vf He Hev.
    inv Hev.
    match goal with
    | Hl : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inv Hl
    end.
    - match goal with
      | Hb : e ! _ = Some _ |- _ => rewrite He in Hb; discriminate Hb
      end.
    - match goal with
      | Hd : deref_loc _ _ _ _ _ _ |- _ => inv Hd
      end;
        try (match goal with
             | Hac : access_mode _ = _ |- _ => cbn in Hac; discriminate Hac
             end).
      eexists. split; [ eassumption | reflexivity ].
  Qed.

  (* ====================================================================== *)
  (* THE CALL-SITE BRICK: a Scall to an out-param helper whose LAST arg     *)
  (* evaluates to a watched-disjoint stack block preserves carried.  This   *)
  (* is what the wwalk engine's future `pids` arm consumes at each          *)
  (* find_ceil / find_floor call site.                                       *)
  (* ====================================================================== *)
  Lemma oc_scall_pres :
    forall optid fid tyl rty cc args e le0 m0 tr le1 m1 out0,
      e ! fid = None ->
      call_pres_ext_oc fid ->
      (forall ty vargs, eval_exprlist (lp_ge lp) e le0 m0 args ty vargs ->
                        last_arg_local vargs) ->
      exec_stmt function_entry2 (lp_ge lp) e le0 m0
        (Scall optid (Evar fid (Tfunction tyl rty cc)) args)
        tr le1 m1 out0 ->
      carried bm NoA MWF m0 ->
      carried bm NoA MWF m1 /\ out0 = Out_normal.
  Proof.
    intros optid fid tyl rty cc args e le0 m0 tr le1 m1 out0
           He Hoc Hlast Hexec Hc.
    inv Hexec.
    match goal with
    | Hv : eval_expr _ _ _ _ (Evar _ _) ?vf |- _ =>
        destruct (eval_Evar_funct _ _ _ _ _ _ _ _ He Hv) as (bf & Hsym & ->)
    end.
    match goal with
    | Hff : Genv.find_funct _ (Vptr bf Ptrofs.zero) = Some ?fd |- _ =>
        assert (Hres : resolves_lp fid fd) by (exists bf; split; assumption)
    end.
    match goal with
    | Hvl : eval_exprlist _ _ _ _ _ _ ?vargs |- _ =>
        pose proof (Hlast _ vargs Hvl) as Hll
    end.
    destruct Hc as (HV & HS & HM & HN).
    match goal with
    | Hevf : eval_funcall _ _ _ _ _ _ _ _ |- _ =>
        destruct (Hoc _ _ _ _ _ _ Hevf Hres Hll HN HM HV HS)
          as (HV' & HS' & HM' & HN')
    end.
    split; [ | reflexivity ].
    split; [ exact HV' | split; [ exact HS' | split; [ exact HM' | exact HN' ] ] ].
  Qed.

End OutParamArc.
