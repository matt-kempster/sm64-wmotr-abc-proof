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
      (forall vargs, eval_exprlist (lp_ge lp) e le0 m0 args tyl vargs ->
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
    (* the call site's declared typelist IS tyl (classify_fun of the Evar). *)
    match goal with
    | Hcf : classify_fun _ = fun_case_f _ _ _ |- _ =>
        cbn in Hcf; injection Hcf as E1 E2 E3; subst
    end.
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
        pose proof (Hlast vargs Hvl) as Hll
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

  (* ====================================================================== *)
  (* END-TO-END VALIDATION: vec3f_find_ceil (mario.prog, store-free) ITSELF *)
  (* satisfies call_pres_ext_oc -- it FORWARDS its own `ceil` param         *)
  (* (locality threaded from its own out-param hypothesis) straight to      *)
  (* find_ceil.  This is the forwarding-helper pattern the pole's           *)
  (* set_pole_position and the hang's perform_hanging_step instantiate.     *)
  (* ====================================================================== *)
  Hypothesis LO_mario : linkorder mario.prog lp.
  Hypothesis Hoc_find_ceil : call_pres_ext_oc mario._find_ceil.

  Example vfc_pin :
    (prog_defmap mario.prog) ! mario._vec3f_find_ceil
    = Some (Gfun (Internal mario.f_vec3f_find_ceil)).
  Proof. vm_compute. reflexivity. Qed.

  (* the body, store-free, only changes memory at the find_ceil call.  Every
     abnormal Ssequence branch is refuted: its leading statement (Sset / Scall)
     always yields Out_normal, contradicting the Out_normal<>x side condition. *)
  Ltac crush_all :=
    repeat match goal with
    | H : ?x <> ?x |- _ => destruct (H eq_refl)
    | H : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ => inv H
    | H : exec_stmt _ _ _ _ _ (Sreturn _) _ _ _ _ |- _ => inv H
    | H : exec_stmt _ _ _ _ _ (Scall _ _ _) _ _ _ _ |- _ => inv H
    | H : exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ |- _ => inv H
    end.

  (* the eval_exprlist last-arg extractor for a 4-arg call whose LAST arg is a
     tempvar holding a watched-disjoint pointer (the find_ceil shape). *)
  Lemma oc_last_tempvar :
    forall e le m a1 a2 a3 tid sz attr t1 t2 t3 b ofs vargs,
      le ! tid = Some (Vptr b ofs) ->
      local_blk lp bm SafeB b ->
      eval_exprlist (lp_ge lp) e le m
        (a1 :: a2 :: a3 :: Etempvar tid (tptr (tptr (Tstruct sz attr))) :: nil)
        (t1 :: t2 :: t3 :: tptr (tptr (Tstruct sz attr)) :: nil) vargs ->
      last_arg_local vargs.
  Proof.
    intros e le m a1 a2 a3 tid sz attr t1 t2 t3 b ofs vargs Htid Hloc Hvl.
    repeat match goal with
    | H : eval_exprlist _ _ _ _ (_ :: _) _ _ |- _ => inv H
    end.
    match goal with
    | H : eval_exprlist _ _ _ _ nil _ _ |- _ => inv H
    end.
    (* the 4th eval_expr (Etempvar): the impossible eval_lvalue branch is refuted *)
    match goal with
    | He : eval_expr _ _ _ _ (Etempvar tid _) _ |- _ => inv He
    end;
    try (match goal with
         | Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl
         end).
    match goal with
    | Hg : le ! tid = Some _ |- _ => rewrite Htid in Hg; injection Hg as <-
    end.
    match goal with
    | Hcast : sem_cast (Vptr b ofs) _ _ _ = Some _ |- _ =>
        cbn in Hcast; injection Hcast as <-
    end.
    unfold last_arg_local. cbn [last_val]. exists b, ofs.
    split; [ reflexivity | exact Hloc ].
  Qed.

  Lemma vec3f_find_ceil_oc : call_pres_ext_oc mario._vec3f_find_ceil.
  Proof.
    intros fd m0 vargs0 t0 m1 vres0 Hevf Hres Hlal HN HM HV HS.
    pose proof (resolve_pin_fd mario.prog _ _ _ LO_mario vfc_pin Hres) as ->.
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ =>
      rename He into Hentry end.
    match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
      rename Hx into Hbody end.
    match goal with Hf : Mem.free_list _ _ = Some _ |- _ =>
      rename Hf into Hfree end.
    inv Hentry.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
      rename Ha into Halloc end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ =>
      rename Hb into Hbind end.
    unfold mario.f_vec3f_find_ceil in Hbody, Hbind, Halloc.
    cbn [fn_body fn_params fn_temps fn_vars] in Hbody, Hbind, Halloc.
    (* name the body env + post-alloc memory *)
    match goal with H : alloc_variables _ _ _ _ ?E ?ME |- _ =>
      set (eloc := E) in *; set (me := ME) in * end.
    (* carried at the post-alloc memory *)
    assert (Hc0 : carried bm NoA MWF m0)
      by (split; [ exact HV | split; [ exact HS | split; [ exact HM | exact HN ] ] ]).
    pose proof (alloc_variables_carried bm NoA MWF HMWF_alloc HNoA_of_MWF
                  _ _ _ _ _ _ Halloc Hc0) as Hce.
    destruct Hce as (HVe & HSe & HMe & HNe).
    (* the ceil param is bound to v3, the local out-param pointer *)
    destruct vargs0 as [| v1 [| v2 [| v3 vrest ]]];
      cbn [bind_parameter_temps] in Hbind; try discriminate Hbind.
    destruct vrest; [ | cbn [bind_parameter_temps] in Hbind; discriminate Hbind ].
    injection Hbind as Hle_init.
    unfold last_arg_local in Hlal; cbn [last_val] in Hlal.
    destruct Hlal as (bc & oc & Hv3 & Hlocbc). injection Hv3 as Hv3eq. subst v3.
    assert (Hfc_none : eloc ! mario._find_ceil = None).
    { rewrite (alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc
                 mario._find_ceil)
        by (cbn; intros [HH | HH]; [ vm_compute in HH; discriminate HH | exact HH ]).
      apply PTree.gempty. }
    (* walk the body: 2 Ssets (mem-neutral) + the find_ceil Scall + Sreturn *)
    inv Hbody; [ | crush_all ].
    match goal with Hret : exec_stmt _ _ _ _ _ (Sreturn _) _ _ _ _ |- _ =>
      inv Hret end.
    match goal with HA : exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ Out_normal |- _ =>
      inv HA; [ | crush_all ] end.
    match goal with Hs2 : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ => inv Hs2 end.
    match goal with HR : exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ Out_normal |- _ =>
      inv HR; [ | crush_all ] end.
    match goal with Hs3 : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ => inv Hs3 end.
    (* Hcall : exec_stmt .. (Scall (Some _t'1) (Evar _find_ceil ..) al) .. *)
    lazymatch goal with
    | Hcall : exec_stmt _ _ _ ?LEC _ (Scall _ (Evar _ _) _) _ _ _ _ |- _ =>
        rename Hcall into Hcall0;
        remember LEC as LEC0 eqn:HLEC
    end.
    assert (Hceil : LEC0 ! mario._ceil = Some (Vptr bc oc)).
    { subst LEC0.
      rewrite ! PTree.gso by (intro EE; vm_compute in EE; discriminate EE).
      apply PTree.gss. }
    subst LEC0.
    destruct (oc_scall_pres _ _ _ _ _ _ _ _ _ _ _ _ _
                Hfc_none Hoc_find_ceil
                ltac:(intros vargs Hvl;
                      eapply oc_last_tempvar;
                      [ exact Hceil | exact Hlocbc | exact Hvl ])
                Hcall0 (conj HVe (conj HSe (conj HMe HNe))))
      as (Hcar2 & _).
    (* exit: free the fresh stack locals *)
    pose proof (blocks_of_env_bm lp bm m0 _ eloc _ Halloc HV) as Hforall.
    pose proof (free_list_carried_bm bm NoA MWF HMWF_free HNoA_of_MWF
                  (blocks_of_env (lp_ge lp) eloc) _ m1 Hforall Hfree Hcar2)
      as (HVf & HSf & HMf & HNf).
    exact (conj HVf (conj HSf (conj HMf HNf))).
  Qed.

End OutParamArc.
