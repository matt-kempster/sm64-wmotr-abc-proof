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
  RealFrameValue Taint CensusV2 LocalVarsSurface.

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

  (* the eval_exprlist last-arg extractor for a 4-arg call whose LAST arg is
     the ADDRESS-OF a watched-disjoint stack local (the DIRECT find_floor /
     find_ceil shape -- e.g. find_floor(x,y,z,&_floor) in
     find_floor_height_relative_polar / let_go_of_ledge / perform_hanging_step).
     Locality comes straight from the env binding e!lid (a local_blk under the
     walker's local-safe invariant), not from a temp -- so no temp-provenance
     tracking is needed for the DIRECT callers. *)
  Lemma oc_last_addrof :
    forall e le m a1 a2 a3 lid sz attr tyenv t1 t2 t3 b vargs,
      e ! lid = Some (b, tyenv) ->
      local_blk lp bm SafeB b ->
      eval_exprlist (lp_ge lp) e le m
        (a1 :: a2 :: a3 ::
          Eaddrof (Evar lid (tptr (Tstruct sz attr)))
            (tptr (tptr (Tstruct sz attr))) :: nil)
        (t1 :: t2 :: t3 :: tptr (tptr (Tstruct sz attr)) :: nil) vargs ->
      last_arg_local vargs.
  Proof.
    intros e le m a1 a2 a3 lid sz attr tyenv t1 t2 t3 b vargs Hlid Hloc Hvl.
    repeat match goal with
    | H : eval_exprlist _ _ _ _ (_ :: _) _ _ |- _ => inv H
    end.
    match goal with
    | H : eval_exprlist _ _ _ _ nil _ _ |- _ => inv H
    end.
    (* the 4th eval_expr (Eaddrof (Evar lid ..)): refute the impossible
       eval_lvalue (Eaddrof ..) branch, then the inner Evar is LOCAL. *)
    match goal with
    | He : eval_expr _ _ _ _ (Eaddrof _ _) _ |- _ => inv He
    end;
    try (match goal with
         | Hl : eval_lvalue _ _ _ _ (Eaddrof _ _) _ _ _ |- _ => inv Hl
         end).
    match goal with
    | Hl : eval_lvalue _ _ _ _ (Evar lid _) _ _ _ |- _ => inv Hl
    end;
    [ | match goal with
        | Hn : e ! lid = None |- _ => rewrite Hlid in Hn; discriminate Hn
        end ].
    (* the inv'd Evar-local output block (loc) equals b (Hlid); the shared
       metavar ?loc selects the inv hyp, not Hlid. *)
    match goal with
    | He : e ! lid = Some (?loc, _),
      Hc : sem_cast (Vptr ?loc Ptrofs.zero) _ _ _ = Some _ |- _ =>
        assert (loc = b) by congruence; subst loc;
        cbn in Hc; injection Hc as <-
    end.
    unfold last_arg_local. cbn [last_val]. exists b, Ptrofs.zero.
    split; [ reflexivity | exact Hloc ].
  Qed.

  (* the 2-ARG twin of oc_last_addrof: last arg is &(a stack-local POINTER var)
     -- Eaddrof (Evar lid (tptr ety)) (tptr (tptr ety)) -- with a SCALAR-pointer
     element type ety (not a Tstruct).  This is the retrieve_animation_index
     out-param shape: retrieve_animation_index(animFrame, &animIndex) in
     find_mario_anim_flags_and_translation.  Feeds oc_scall_pres's gate for the
     famft body walk.  Mirror of oc_last_addrof but 2-elt list + tptr-ety. *)
  Lemma oc_last_addrof_ptr2 :
    forall e le m a1 lid ety tyenv t1 b vargs,
      e ! lid = Some (b, tyenv) ->
      local_blk lp bm SafeB b ->
      eval_exprlist (lp_ge lp) e le m
        (a1 :: Eaddrof (Evar lid (tptr ety)) (tptr (tptr ety)) :: nil)
        (t1 :: tptr (tptr ety) :: nil) vargs ->
      last_arg_local vargs.
  Proof.
    intros e le m a1 lid ety tyenv t1 b vargs Hlid Hloc Hvl.
    repeat match goal with
    | H : eval_exprlist _ _ _ _ (_ :: _) _ _ |- _ => inv H
    end.
    match goal with
    | H : eval_exprlist _ _ _ _ nil _ _ |- _ => inv H
    end.
    match goal with
    | He : eval_expr _ _ _ _ (Eaddrof _ _) _ |- _ => inv He
    end;
    try (match goal with
         | Hl : eval_lvalue _ _ _ _ (Eaddrof _ _) _ _ _ |- _ => inv Hl
         end).
    match goal with
    | Hl : eval_lvalue _ _ _ _ (Evar lid _) _ _ _ |- _ => inv Hl
    end;
    [ | match goal with
        | Hn : e ! lid = None |- _ => rewrite Hlid in Hn; discriminate Hn
        end ].
    match goal with
    | He : e ! lid = Some (?loc, _),
      Hc : sem_cast (Vptr ?loc Ptrofs.zero) _ _ _ = Some _ |- _ =>
        assert (loc = b) by congruence; subst loc;
        cbn in Hc; injection Hc as <-
    end.
    unfold last_arg_local. cbn [last_val]. exists b, Ptrofs.zero.
    split; [ reflexivity | exact Hloc ].
  Qed.

  (* THE ENGINE-CALLABLE oc-call unit: a 4-arg out-param call whose last arg is
     &(a stack local lid) -- with lid's locality supplied by the walker's
     local-safe env binding (e!lid = Some(b, ..) /\ local_blk b) -- preserves
     carried, consuming call_pres_ext_oc fid.  This is EXACTLY the unit the
     wwalk_pres Scall oc-case will call (oc_scall_pres composed with the
     &_local recognizer oc_last_addrof); the find_floor / find_ceil shape. *)
  Lemma oc_call_pres :
    forall optid fid a1 a2 a3 ty1 ty2 ty3 lid sz attr tyenv b rty cc
           e le0 m0 tr le1 m1 out0,
      e ! fid = None ->
      call_pres_ext_oc fid ->
      e ! lid = Some (b, tyenv) ->
      local_blk lp bm SafeB b ->
      exec_stmt function_entry2 (lp_ge lp) e le0 m0
        (Scall optid
           (Evar fid (Tfunction (ty1 :: ty2 :: ty3 ::
                       tptr (tptr (Tstruct sz attr)) :: nil) rty cc))
           (a1 :: a2 :: a3 ::
            Eaddrof (Evar lid (tptr (Tstruct sz attr)))
              (tptr (tptr (Tstruct sz attr))) :: nil))
        tr le1 m1 out0 ->
      carried bm NoA MWF m0 ->
      carried bm NoA MWF m1 /\ out0 = Out_normal.
  Proof.
    intros optid fid a1 a2 a3 ty1 ty2 ty3 lid sz attr tyenv b rty cc
           e le0 m0 tr le1 m1 out0
           Hfn Hoc Hlid Hloc Hexec Hc.
    eapply oc_scall_pres; [ exact Hfn | exact Hoc | | exact Hexec | exact Hc ].
    intros vargs Hvl.
    eapply oc_last_addrof; [ exact Hlid | exact Hloc | exact Hvl ].
  Qed.

  (* the 3-arg twin of oc_last_addrof (vec3f_find_ceil's shape: pos, height,
     &ceil).  The proof peels the eval_exprlist generically, so it is the same
     as the 4-arg version with one fewer arg. *)
  Lemma oc_last_addrof3 :
    forall e le m a1 a2 lid sz attr tyenv t1 t2 b vargs,
      e ! lid = Some (b, tyenv) ->
      local_blk lp bm SafeB b ->
      eval_exprlist (lp_ge lp) e le m
        (a1 :: a2 ::
          Eaddrof (Evar lid (tptr (Tstruct sz attr)))
            (tptr (tptr (Tstruct sz attr))) :: nil)
        (t1 :: t2 :: tptr (tptr (Tstruct sz attr)) :: nil) vargs ->
      last_arg_local vargs.
  Proof.
    intros e le m a1 a2 lid sz attr tyenv t1 t2 b vargs Hlid Hloc Hvl.
    repeat match goal with
    | H : eval_exprlist _ _ _ _ (_ :: _) _ _ |- _ => inv H
    end.
    match goal with
    | H : eval_exprlist _ _ _ _ nil _ _ |- _ => inv H
    end.
    match goal with
    | He : eval_expr _ _ _ _ (Eaddrof _ _) _ |- _ => inv He
    end;
    try (match goal with
         | Hl : eval_lvalue _ _ _ _ (Eaddrof _ _) _ _ _ |- _ => inv Hl
         end).
    match goal with
    | Hl : eval_lvalue _ _ _ _ (Evar lid _) _ _ _ |- _ => inv Hl
    end;
    [ | match goal with
        | Hn : e ! lid = None |- _ => rewrite Hlid in Hn; discriminate Hn
        end ].
    match goal with
    | He : e ! lid = Some (?loc, _),
      Hc : sem_cast (Vptr ?loc Ptrofs.zero) _ _ _ = Some _ |- _ =>
        assert (loc = b) by congruence; subst loc;
        cbn in Hc; injection Hc as <-
    end.
    unfold last_arg_local. cbn [last_val]. exists b, Ptrofs.zero.
    split; [ reflexivity | exact Hloc ].
  Qed.

  Lemma oc_call_pres3 :
    forall optid fid a1 a2 ty1 ty2 lid sz attr tyenv b rty cc
           e le0 m0 tr le1 m1 out0,
      e ! fid = None ->
      call_pres_ext_oc fid ->
      e ! lid = Some (b, tyenv) ->
      local_blk lp bm SafeB b ->
      exec_stmt function_entry2 (lp_ge lp) e le0 m0
        (Scall optid
           (Evar fid (Tfunction (ty1 :: ty2 ::
                       tptr (tptr (Tstruct sz attr)) :: nil) rty cc))
           (a1 :: a2 ::
            Eaddrof (Evar lid (tptr (Tstruct sz attr)))
              (tptr (tptr (Tstruct sz attr))) :: nil))
        tr le1 m1 out0 ->
      carried bm NoA MWF m0 ->
      carried bm NoA MWF m1 /\ out0 = Out_normal.
  Proof.
    intros optid fid a1 a2 ty1 ty2 lid sz attr tyenv b rty cc
           e le0 m0 tr le1 m1 out0
           Hfn Hoc Hlid Hloc Hexec Hc.
    eapply oc_scall_pres; [ exact Hfn | exact Hoc | | exact Hexec | exact Hc ].
    intros vargs Hvl.
    eapply oc_last_addrof3; [ exact Hlid | exact Hloc | exact Hvl ].
  Qed.

  (* ---- THE SYNTACTIC RECOGNIZER for the wwalk engine's Scall oc-arm.
     A 4-arg call whose function id is in oc_pids and whose last arg is
     &(a local lid in lids), at the canonical Surface-out-param types. ---- *)
  (* the out-param last-arg shape check, factored so the recognizer accepts
     BOTH find_floor's 4-arg form AND vec3f_find_ceil's 3-arg form (the only
     thing that varies is the prefix arity; the out-param is always the last
     arg = address of a local Surface pointer). *)
  Definition oc_last_ok (lids : list ident) (tylast : type) (alast : expr)
      : bool :=
    match alast with
    | Eaddrof (Evar lid (Tpointer (Tstruct sz attr) pa1)) aoty =>
        mem_id lid lids
        && proj_sumbool (type_eq (Tpointer (Tstruct sz attr) pa1)
                                  (tptr (Tstruct sz attr)))
        && proj_sumbool (type_eq aoty (tptr (tptr (Tstruct sz attr))))
        && proj_sumbool (type_eq tylast (tptr (tptr (Tstruct sz attr))))
    | _ => false
    end.

  Definition oc_call_chk (lids oc_pids : list ident) (fid : ident)
      (fty : type) (al : list expr) : bool :=
    mem_id fid oc_pids
    && match fty, al with
       | Tfunction (_ :: _ :: _ :: ty4 :: nil) _ _,
         _ :: _ :: _ :: alast :: nil => oc_last_ok lids ty4 alast
       | Tfunction (_ :: _ :: ty3 :: nil) _ _,
         _ :: _ :: alast :: nil => oc_last_ok lids ty3 alast
       | _, _ => false
       end.

  Lemma oc_last_ok_decode :
    forall lids tylast alast,
      oc_last_ok lids tylast alast = true ->
      exists lid sz attr,
        mem_id lid lids = true /\
        tylast = tptr (tptr (Tstruct sz attr)) /\
        alast = Eaddrof (Evar lid (tptr (Tstruct sz attr)))
                  (tptr (tptr (Tstruct sz attr))).
  Proof.
    intros lids tylast alast H. unfold oc_last_ok in H.
    destruct alast as [ | | | | | | | einner aoty | | | | | | ];
      try discriminate H.
    destruct einner as [ | | | | lid evty | | | | | | | | | ];
      try discriminate H.
    destruct evty as [ | | | | sbase pa1 | | | | ]; try discriminate H.
    destruct sbase as [ | | | | | | | sz attr | ]; try discriminate H.
    apply andb_true_iff in H as [H Htyl].
    apply andb_true_iff in H as [H Haoty].
    apply andb_true_iff in H as [Hlid Hpa1].
    destruct (type_eq (Tpointer (Tstruct sz attr) pa1) (tptr (Tstruct sz attr)))
      as [Hev | ]; [ | discriminate Hpa1 ].
    destruct (type_eq aoty (tptr (tptr (Tstruct sz attr))))
      as [Hao | ]; [ | discriminate Haoty ].
    destruct (type_eq tylast (tptr (tptr (Tstruct sz attr))))
      as [Ht | ]; [ | discriminate Htyl ].
    exists lid, sz, attr. rewrite Ht, Hev, Hao.
    split; [ exact Hlid | split; reflexivity ].
  Qed.

  Lemma oc_call_chk_decode :
    forall lids oc_pids fid fty al,
      oc_call_chk lids oc_pids fid fty al = true ->
      mem_id fid oc_pids = true /\
      ( (exists a1 a2 a3 lid sz attr ty1 ty2 ty3 rty cc,
           mem_id lid lids = true /\
           fty = Tfunction (ty1 :: ty2 :: ty3 ::
                            tptr (tptr (Tstruct sz attr)) :: nil) rty cc /\
           al = a1 :: a2 :: a3 ::
                Eaddrof (Evar lid (tptr (Tstruct sz attr)))
                  (tptr (tptr (Tstruct sz attr))) :: nil)
        \/
        (exists a1 a2 lid sz attr ty1 ty2 rty cc,
           mem_id lid lids = true /\
           fty = Tfunction (ty1 :: ty2 ::
                            tptr (tptr (Tstruct sz attr)) :: nil) rty cc /\
           al = a1 :: a2 ::
                Eaddrof (Evar lid (tptr (Tstruct sz attr)))
                  (tptr (tptr (Tstruct sz attr))) :: nil) ).
  Proof.
    intros lids oc_pids fid fty al Hchk.
    unfold oc_call_chk in Hchk.
    apply andb_true_iff in Hchk as [Hfid Hchk].
    split; [ exact Hfid | ].
    destruct fty as [ | | | | | | tyl rty cc | | ]; try discriminate Hchk.
    destruct tyl as [|ty1 [|ty2 [|ty3 [|ty4 [|ty5 tyl']]]]]; try discriminate Hchk.
    - (* tyl = ty1::ty2::ty3::nil (3 args): vec3f_find_ceil shape *)
      destruct al as [|a1 [|a2 [|a3 [|a4 al']]]]; try discriminate Hchk.
      destruct (oc_last_ok_decode _ _ _ Hchk) as (lid & sz & attr & Hlid & Ht & Ha).
      right. exists a1, a2, lid, sz, attr, ty1, ty2, rty, cc.
      subst ty3 a3. split; [ exact Hlid | split; reflexivity ].
    - (* tyl = ty1::ty2::ty3::ty4::nil (4 args): find_floor shape *)
      destruct al as [|a1 [|a2 [|a3 [|a4 [|a5 al']]]]]; try discriminate Hchk.
      destruct (oc_last_ok_decode _ _ _ Hchk) as (lid & sz & attr & Hlid & Ht & Ha).
      left. exists a1, a2, a3, lid, sz, attr, ty1, ty2, ty3, rty, cc.
      subst ty4 a4. split; [ exact Hlid | split; reflexivity ].
  Qed.

  (* THE ENGINE-CALLABLE oc-call unit, recognizer-gated: exactly what the
     wwalk_pres Scall oc-arm invokes -- decode oc_call_chk, then oc_call_pres
     with the lid's locality drawn from the walker's local-safe invariant. *)
  Lemma oc_call_chk_pres :
    forall lids oc_pids optid fid fty al e le0 m0 tr le1 m1 out0,
      (forall g, mem_id g oc_pids = true -> call_pres_ext_oc g) ->
      (forall g, mem_id g oc_pids = true -> e ! g = None) ->
      (forall l, mem_id l lids = true ->
         exists lblk tyenv, e ! l = Some (lblk, tyenv) /\
                            local_blk lp bm SafeB lblk) ->
      oc_call_chk lids oc_pids fid fty al = true ->
      exec_stmt function_entry2 (lp_ge lp) e le0 m0
        (Scall optid (Evar fid fty) al) tr le1 m1 out0 ->
      carried bm NoA MWF m0 ->
      carried bm NoA MWF m1 /\ out0 = Out_normal.
  Proof.
    intros lids oc_pids optid fid fty al e le0 m0 tr le1 m1 out0
           Hcp_oc Hnone Hlocal Hchk Hexec Hc.
    destruct (oc_call_chk_decode _ _ _ _ _ Hchk) as (Hfid & [Hsh | Hsh]).
    - (* 4-arg find_floor shape *)
      destruct Hsh as (a1 & a2 & a3 & lid & sz & attr & ty1 & ty2 & ty3 & rty & cc
          & Hlidmem & Hfty & Hal).
      subst fty al.
      destruct (Hlocal lid Hlidmem) as (lblk & tyenv & Hbind & Hloc).
      eapply oc_call_pres;
        [ exact (Hnone fid Hfid) | exact (Hcp_oc fid Hfid)
        | exact Hbind | exact Hloc | exact Hexec | exact Hc ].
    - (* 3-arg vec3f_find_ceil shape *)
      destruct Hsh as (a1 & a2 & lid & sz & attr & ty1 & ty2 & rty & cc
          & Hlidmem & Hfty & Hal).
      subst fty al.
      destruct (Hlocal lid Hlidmem) as (lblk & tyenv & Hbind & Hloc).
      eapply oc_call_pres3;
        [ exact (Hnone fid Hfid) | exact (Hcp_oc fid Hfid)
        | exact Hbind | exact Hloc | exact Hexec | exact Hc ].
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

  (* ====================================================================== *)
  (* THE WINDOW-OUT-PARAM ARC (the f32_find_wall_collision / vec3f_copy /    *)
  (* vec3s_set class).  Unlike find_floor / find_ceil (which write a Surface *)
  (* POINTER through a single LAST out-param -- handled by the oc arm above  *)
  (* with a local_blk gate), these writers take INTERIOR pointers into       *)
  (* Mario's FLOAT window (e.g. f32_find_wall_collision(&m->pos[0],          *)
  (* &m->pos[1], &m->pos[2], c1, c2) in set_pole_position) and write FLOATS  *)
  (* there.  `call_pres_ext f32_find_wall_collision` (forall vargs) is again *)
  (* PHANTOM-FALSE: the adversary aims an out-param at the action cell @12   *)
  (* and the written float's bit-pattern lands a TAINTED action value (the   *)
  (* unconditional call_pres_ext carries action_sat not_tainted, which an    *)
  (* arbitrary 4-byte write to @12 breaks).  THE HONEST GATE (this arc):     *)
  (* every POINTER arg targets a SAFE WINDOW of bm -- the SAME               *)
  (* store_window_ok geometry the engine's safe_mfield_store uses (clears    *)
  (* the action cell @12 and the chase/body watched cells).  TRUE in the     *)
  (* real program, where these out-params are always &m-><float field> (pos  *)
  (* @60 etc.).  This is the faithful replacement for the phantom            *)
  (* call_pres_ext vec3f_copy / vec3s_set ALREADY load-bearing on the        *)
  (* capstone (the Hpres_obj_ext rows in NoAImpliesNoFlyLinked).             *)
  (* ====================================================================== *)

  (* the window gate: every POINTER argument targets a watched-disjoint
     safe-window cell of bm (store_window_ok over a 4-byte write clears the
     action cell @12 and the chase/body watched cells).  Non-pointer args
     (the float thresholds) impose nothing -- they are not Vptr. *)
  Definition args_all_window (vargs : list val) : Prop :=
    forall b ofs, In (Vptr b ofs) vargs ->
      b = bm /\ store_window_ok (Ptrofs.unsigned ofs) 4 = true.

  (* the ARG-AWARE external residual (the honest refinement of the phantom
     call_pres_ext for the WINDOW writers): preserves the carried run facts
     PROVIDED every pointer arg targets a safe window of bm. *)
  Definition call_pres_ext_wc (fid : ident) : Prop :=
    forall fd m0 vargs0 t0 m1 vres0,
      eval_funcall function_entry2 (lp_ge lp) m0 fd vargs0 t0 m1 vres0 ->
      resolves_lp fid fd ->
      args_all_window vargs0 ->
      NoA m0 -> MWF m0 -> Mem.valid_block m0 bm ->
      action_sat not_tainted m0 bm ->
      Mem.valid_block m1 bm /\ action_sat not_tainted m1 bm /\
      MWF m1 /\ NoA m1.

  (* THE CALL-SITE BRICK: a Scall to a window-writer whose every pointer arg
     evaluates to a safe-window cell of bm preserves carried.  This is what
     the wwalk engine's future wc-arm consumes at each f32_find_wall_collision
     / vec3f_copy / vec3s_set call site.  (Structure mirrors oc_scall_pres.) *)
  Lemma wc_scall_pres :
    forall optid fid tyl rty cc args e le0 m0 tr le1 m1 out0,
      e ! fid = None ->
      call_pres_ext_wc fid ->
      (forall vargs, eval_exprlist (lp_ge lp) e le0 m0 args tyl vargs ->
                     args_all_window vargs) ->
      exec_stmt function_entry2 (lp_ge lp) e le0 m0
        (Scall optid (Evar fid (Tfunction tyl rty cc)) args)
        tr le1 m1 out0 ->
      carried bm NoA MWF m0 ->
      carried bm NoA MWF m1 /\ out0 = Out_normal.
  Proof.
    intros optid fid tyl rty cc args e le0 m0 tr le1 m1 out0
           He Hwc Hwin Hexec Hc.
    inv Hexec.
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
        pose proof (Hwin vargs Hvl) as Hww
    end.
    destruct Hc as (HV & HS & HM & HN).
    match goal with
    | Hevf : eval_funcall _ _ _ _ _ _ _ _ |- _ =>
        destruct (Hwc _ _ _ _ _ _ Hevf Hres Hww HN HM HV HS)
          as (HV' & HS' & HM' & HN')
    end.
    split; [ | reflexivity ].
    split; [ exact HV' | split; [ exact HS' | split; [ exact HM' | exact HN' ] ] ].
  Qed.

  (* ====================================================================== *)
  (* THE SAFE-CHASE-TARGET ARC (the SECOND face of vec3f_copy / vec3s_set). *)
  (* In set_pole_position / act_tornado_twirling these writers do NOT aim   *)
  (* at Mario's window -- they write INTO the marioObj graphics node:       *)
  (*   vec3f_copy(m->marioObj->header.gfx.pos, m->pos)      [dst=Object]    *)
  (*   vec3s_set (m->marioObj->header.gfx.angle, ...)       [dst=Object]    *)
  (* The dst pointer chases through m->marioObj into the OBJECT POOL -- a    *)
  (* SafeB block, DISJOINT from bm (HSafeNotBm).  So neither the window     *)
  (* gate (args_all_window, which demands b=bm) nor the oc gate (a local    *)
  (* stack block) fits: the faithful gate is `the dst (first) pointer arg   *)
  (* lands in a SafeB block`.  A write confined to SafeB preserves carried  *)
  (* (action@12 lives in bm<>SafeB; NoA/valid bm survive; MWF survives via  *)
  (* the chase-safe frame).  This is the OTHER honest replacement for the   *)
  (* phantom call_pres_ext vec3f_copy / vec3s_set on the capstone -- the    *)
  (* one the wc arm does NOT cover (its sites in set_pole_position write the *)
  (* Object, not bm).  Mirror of the oc / wc spec + brick. *)
  (* ====================================================================== *)

  (* the safe-chase gate: the FIRST argument (the write destination of the
     copy/set writers) is a pointer into a SafeB block.  The remaining args
     (a read-only src pointer for vec3f_copy, or scalar shorts for vec3s_set)
     are unconstrained -- the external writes only through the dst. *)
  Definition arg0_safe (vargs : list val) : Prop :=
    exists b ofs rest, vargs = Vptr b ofs :: rest /\ SafeB b.

  (* the ARG-AWARE external residual for the OBJECT writers: preserves the
     carried run facts PROVIDED the dst arg lands in a SafeB block. *)
  Definition call_pres_ext_sc (fid : ident) : Prop :=
    forall fd m0 vargs0 t0 m1 vres0,
      eval_funcall function_entry2 (lp_ge lp) m0 fd vargs0 t0 m1 vres0 ->
      resolves_lp fid fd ->
      arg0_safe vargs0 ->
      NoA m0 -> MWF m0 -> Mem.valid_block m0 bm ->
      action_sat not_tainted m0 bm ->
      Mem.valid_block m1 bm /\ action_sat not_tainted m1 bm /\
      MWF m1 /\ NoA m1.

  (* THE CALL-SITE BRICK: a Scall to an object-writer whose dst arg evaluates
     to a SafeB cell preserves carried.  This is what the wwalk engine's
     future sc-arm consumes at each vec3f_copy / vec3s_set OBJECT call site.
     (Structure mirrors wc_scall_pres / oc_scall_pres exactly.) *)
  Lemma sc_scall_pres :
    forall optid fid tyl rty cc args e le0 m0 tr le1 m1 out0,
      e ! fid = None ->
      call_pres_ext_sc fid ->
      (forall vargs, eval_exprlist (lp_ge lp) e le0 m0 args tyl vargs ->
                     arg0_safe vargs) ->
      exec_stmt function_entry2 (lp_ge lp) e le0 m0
        (Scall optid (Evar fid (Tfunction tyl rty cc)) args)
        tr le1 m1 out0 ->
      carried bm NoA MWF m0 ->
      carried bm NoA MWF m1 /\ out0 = Out_normal.
  Proof.
    intros optid fid tyl rty cc args e le0 m0 tr le1 m1 out0
           He Hsc Hsafe Hexec Hc.
    inv Hexec.
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
        pose proof (Hsafe vargs Hvl) as Hsa
    end.
    destruct Hc as (HV & HS & HM & HN).
    match goal with
    | Hevf : eval_funcall _ _ _ _ _ _ _ _ |- _ =>
        destruct (Hsc _ _ _ _ _ _ Hevf Hres Hsa HN HM HV HS)
          as (HV' & HS' & HM' & HN')
    end.
    split; [ | reflexivity ].
    split; [ exact HV' | split; [ exact HS' | split; [ exact HM' | exact HN' ] ] ].
  Qed.

  (* ====================================================================== *)
  (* THE LOCAL-OUT-PARAM-WRITER ARC (ol): the honest gate for an EXTERNAL    *)
  (* that writes FLOATS through an INTERIOR pointer arg that is a STACK      *)
  (* LOCAL (local_blk), and whose pointer arg is NOT the LAST one (so the    *)
  (* oc/last_arg_local arm does not fit) and is NOT a bm-window (so the wc   *)
  (* args_all_window arm does not fit either).                              *)
  (*                                                                        *)
  (* The canonical case is `resolve_and_return_wall_collisions(nextPos,     *)
  (* 1.0f, 1.0f)` in perform_hanging_step (mario_actions_automatic.v:2918): *)
  (* its first arg is `nextPos` (the stack-local out-param the mo-gate pins *)
  (* as local_blk), the other two are FLOAT CONSTANTS (not pointers).  A    *)
  (* phantom-false `call_pres_ext` (forall vargs) would let the adversary   *)
  (* aim nextPos at the action cell @12; the honest gate is that EVERY      *)
  (* pointer arg lands in a local_blk (disjoint from bm and from the chase/ *)
  (* object structure MWF tracks), so the external write preserves carried. *)
  (* Position-INDEPENDENT (like args_all_window), so it does not care which *)
  (* arg slot the pointer occupies.  Mirror of the wc arc, local_blk gate.  *)
  (* ====================================================================== *)

  (* the local gate: every POINTER argument is a stack-local block.  The
     non-pointer args (the float thresholds) impose nothing. *)
  Definition args_all_local (vargs : list val) : Prop :=
    forall b ofs, In (Vptr b ofs) vargs -> local_blk lp bm SafeB b.

  (* the ARG-AWARE external residual (the honest refinement of the phantom
     call_pres_ext for the LOCAL-out-param writers): preserves the carried
     run facts PROVIDED every pointer arg lands in a local_blk. *)
  Definition call_pres_ext_ol (fid : ident) : Prop :=
    forall fd m0 vargs0 t0 m1 vres0,
      eval_funcall function_entry2 (lp_ge lp) m0 fd vargs0 t0 m1 vres0 ->
      resolves_lp fid fd ->
      args_all_local vargs0 ->
      NoA m0 -> MWF m0 -> Mem.valid_block m0 bm ->
      action_sat not_tainted m0 bm ->
      Mem.valid_block m1 bm /\ action_sat not_tainted m1 bm /\
      MWF m1 /\ NoA m1.

  (* THE CALL-SITE BRICK: a Scall to a local-out-param writer whose every
     pointer arg evaluates to a local_blk cell preserves carried.  This is
     what the perform_hanging_step body walk consumes at the
     resolve_and_return_wall_collisions call site.  (Structure mirrors
     wc_scall_pres / oc_scall_pres exactly.) *)
  Lemma ol_scall_pres :
    forall optid fid tyl rty cc args e le0 m0 tr le1 m1 out0,
      e ! fid = None ->
      call_pres_ext_ol fid ->
      (forall vargs, eval_exprlist (lp_ge lp) e le0 m0 args tyl vargs ->
                     args_all_local vargs) ->
      exec_stmt function_entry2 (lp_ge lp) e le0 m0
        (Scall optid (Evar fid (Tfunction tyl rty cc)) args)
        tr le1 m1 out0 ->
      carried bm NoA MWF m0 ->
      carried bm NoA MWF m1 /\ out0 = Out_normal.
  Proof.
    intros optid fid tyl rty cc args e le0 m0 tr le1 m1 out0
           He Hol Hloc Hexec Hc.
    inv Hexec.
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
        pose proof (Hloc vargs Hvl) as Hla
    end.
    destruct Hc as (HV & HS & HM & HN).
    match goal with
    | Hevf : eval_funcall _ _ _ _ _ _ _ _ |- _ =>
        destruct (Hol _ _ _ _ _ _ Hevf Hres Hla HN HM HV HS)
          as (HV' & HS' & HM' & HN')
    end.
    split; [ | reflexivity ].
    split; [ exact HV' | split; [ exact HS' | split; [ exact HM' | exact HN' ] ] ].
  Qed.

  (* The body-level reduction for the ol arc: turns the call_pres_ext_ol
     obligation into a per-body obligation body_pres_ol (the actual walk).
     Used to DISCHARGE call_pres_ext_ol for an INTERNAL out-param writer all
     of whose pointer args are local blocks -- e.g.
     resolve_and_return_wall_collisions, which under args_all_local writes
     only into local blocks (the collisionData fn_var + the pos[] param ptr,
     itself local under the gate) and calls find_wall_collisions(&local).
     Mirror of call_pres_ext_oc2_of_body / call_pres_mo_of_body, args_all_local
     gated. *)
  Definition body_pres_ol (f : Clight.function) : Prop :=
    forall m vargs t m' vres,
      args_all_local vargs ->
      eval_funcall function_entry2 (lp_ge lp) m (Internal f) vargs t m' vres ->
      NoA m -> MWF m -> Mem.valid_block m bm -> action_sat not_tainted m bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m'.

  Lemma call_pres_ext_ol_of_body :
    forall (TU : Clight.program) (fid : ident) (f : Clight.function),
      linkorder TU lp ->
      (prog_defmap TU) ! fid = Some (Gfun (Internal f)) ->
      body_pres_ol f ->
      call_pres_ext_ol fid.
  Proof.
    intros TU fid f LOtu Hdm Hbp fd m0 vargs0 t0 m1 vres0
           Hevf Hres Hgate HN HM HV HS.
    pose proof (resolve_pin_fd TU fid f fd LOtu Hdm Hres) as ->.
    destruct (Hbp m0 vargs0 t0 m1 vres0 Hgate Hevf HN HM HV HS)
      as (HV' & HS' & HM').
    repeat split;
      [ exact HV' | exact HS' | exact HM' | exact (HNoA_of_MWF _ HM') ].
  Qed.

  (* ====================================================================== *)
  (* THE DST-WINDOW-WRITER ARC (w1): the honest gate for an EXTERNAL that    *)
  (* writes through its FIRST (dst) pointer arg into a SAFE WINDOW of bm,    *)
  (* while a LATER pointer arg is a read-only SOURCE in a different block    *)
  (* (so neither the wc args_all_window gate -- which demands EVERY pointer  *)
  (* be a bm-window -- nor the sc arg0_safe gate -- a SafeB dst -- fits).    *)
  (*                                                                        *)
  (* The canonical case is `vec3f_copy(&m->pos, nextPos)` in                *)
  (* perform_hanging_step: dst = &m->pos (a 12-byte float window of bm,      *)
  (* action-cell @12 clear), src = nextPos (the local out-param, read-only). *)
  (* vec3f_copy writes ONLY through its dst, so the honest gate is that the  *)
  (* FIRST pointer arg is a safe 12-byte bm-window; the source arg is        *)
  (* unconstrained.  Mirror of the sc arc, window dst instead of SafeB dst.  *)
  (* ====================================================================== *)

  (* the dst-window gate: the FIRST argument (the write destination) is a
     12-byte safe window of bm (a 3-float vec write clears the action cell
     @12 and the watched cells).  The remaining args (the read-only src,
     scalars) are unconstrained -- the external writes only through dst. *)
  Definition arg0_window (vargs : list val) : Prop :=
    exists ofs rest, vargs = Vptr bm ofs :: rest /\
      store_window_ok (Ptrofs.unsigned ofs) 12 = true.

  (* the ARG-AWARE external residual for the DST-WINDOW writers: preserves
     the carried run facts PROVIDED the dst arg lands in a safe bm-window. *)
  Definition call_pres_ext_w1 (fid : ident) : Prop :=
    forall fd m0 vargs0 t0 m1 vres0,
      eval_funcall function_entry2 (lp_ge lp) m0 fd vargs0 t0 m1 vres0 ->
      resolves_lp fid fd ->
      arg0_window vargs0 ->
      NoA m0 -> MWF m0 -> Mem.valid_block m0 bm ->
      action_sat not_tainted m0 bm ->
      Mem.valid_block m1 bm /\ action_sat not_tainted m1 bm /\
      MWF m1 /\ NoA m1.

  (* THE CALL-SITE BRICK: a Scall to a dst-window writer whose dst arg
     evaluates to a safe bm-window preserves carried.  Consumed by the
     perform_hanging_step body walk at its vec3f_copy(&m->pos, nextPos)
     call site.  (Structure mirrors sc_scall_pres / wc_scall_pres.) *)
  Lemma w1_scall_pres :
    forall optid fid tyl rty cc args e le0 m0 tr le1 m1 out0,
      e ! fid = None ->
      call_pres_ext_w1 fid ->
      (forall vargs, eval_exprlist (lp_ge lp) e le0 m0 args tyl vargs ->
                     arg0_window vargs) ->
      exec_stmt function_entry2 (lp_ge lp) e le0 m0
        (Scall optid (Evar fid (Tfunction tyl rty cc)) args)
        tr le1 m1 out0 ->
      carried bm NoA MWF m0 ->
      carried bm NoA MWF m1 /\ out0 = Out_normal.
  Proof.
    intros optid fid tyl rty cc args e le0 m0 tr le1 m1 out0
           He Hw1 Hwin Hexec Hc.
    inv Hexec.
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
        pose proof (Hwin vargs Hvl) as Hww
    end.
    destruct Hc as (HV & HS & HM & HN).
    match goal with
    | Hevf : eval_funcall _ _ _ _ _ _ _ _ |- _ =>
        destruct (Hw1 _ _ _ _ _ _ Hevf Hres Hww HN HM HV HS)
          as (HV' & HS' & HM' & HN')
    end.
    split; [ | reflexivity ].
    split; [ exact HV' | split; [ exact HS' | split; [ exact HM' | exact HN' ] ] ].
  Qed.

  (* ====================================================================== *)
  (* geo_update_animation_frame's out-param: its dst arg is                  *)
  (* `&obj->header.gfx.animInfo` -- three AGGREGATE Efields over the         *)
  (* Ederef of the _obj temp.  Each aggregate Efield/Ederef hands back the   *)
  (* SAME block (it is an address computation, not a load), so the dst's     *)
  (* block is EXACTLY _obj's pointer block.  Under the oc2 gate _obj is      *)
  (* SafeB-conditional, so this dst lands in SafeB -> feeds sc_scall_pres's  *)
  (* arg0_safe at the geo_update call site in                               *)
  (* find_mario_anim_flags_and_translation.  (The one NEW derivation the     *)
  (* Hoc2famft_real body walk needs; the rest is existing bricks.)          *)
  (* ====================================================================== *)
  Lemma famft_geo_arg0_block :
    forall e le m v,
      eval_expr (lp_ge lp) e le m
        (Eaddrof
          (Efield
            (Efield
              (Efield
                (Ederef
                  (Etempvar mario._obj (tptr (Tstruct mario._Object noattr)))
                  (Tstruct mario._Object noattr))
                mario._header (Tstruct mario._ObjectNode noattr))
              mario._gfx (Tstruct mario._GraphNodeObject noattr))
            mario._animInfo (Tstruct mario._AnimInfo noattr))
          (tptr (Tstruct mario._AnimInfo noattr))) v ->
      exists loc o oo,
        v = Vptr loc o /\ le ! mario._obj = Some (Vptr loc oo).
  Proof.
    intros e le m v Hev.
    (* inv keeps the (impossible) eval_Elvalue case of eval_expr (Eaddrof ..);
       its bogus eval_lvalue (Eaddrof ..) hyp has no constructor -> inv closes it. *)
    inv Hev;
      [ | match goal with
          | H : eval_lvalue _ _ _ _ (Eaddrof _ _) _ _ _ |- _ => inv H
          end ].
    (* peel _animInfo (outermost Efield lvalue) -> eval_expr (.gfx) (Vptr loc _) *)
    match goal with
    | Hlv : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ =>
        apply eval_lvalue_Efield_base in Hlv; destruct Hlv as (o3 & HE3)
    end.
    (* peel _gfx, then _header (both aggregate structs -> By_copy) *)
    destruct (eval_expr_Efield_peel _ _ _ _ _ _ _ _ _
                (or_intror (eq_refl :
                   access_mode (Tstruct mario._GraphNodeObject noattr) = By_copy))
                HE3) as (o2 & HE2).
    destruct (eval_expr_Efield_peel _ _ _ _ _ _ _ _ _
                (or_intror (eq_refl :
                   access_mode (Tstruct mario._ObjectNode noattr) = By_copy))
                HE2) as (o1 & HE1).
    (* peel the Ederef(Object) over Etempvar _obj (struct -> By_copy) *)
    destruct (eval_expr_Ederef_peel _ _ _ _ _ _ _ _
                (or_intror (eq_refl :
                   access_mode (Tstruct mario._Object noattr) = By_copy))
                HE1) as (o0 & HE0).
    (* HE0 : eval_expr (Etempvar _obj) (Vptr loc o0) -> read its le binding *)
    apply eval_expr_Etempvar_val in HE0.
    do 3 eexists; split; [ reflexivity | exact HE0 ].
  Qed.

  (* ====================================================================== *)
  (* THE MULTI-POINTER OUT-PARAM ARC (oc2): the honest gate for an INTERNAL  *)
  (* helper that writes through BOTH an OBJECT pointer (its 1st arg, a chase *)
  (* into m->marioObj -> SafeB) AND a stack-local OUT-PARAM (its last arg).  *)
  (*                                                                        *)
  (* The canonical case is `find_mario_anim_flags_and_translation(obj, yaw, *)
  (* translation)` (mario.v:1782), the sole non-trivial callee of           *)
  (* return_mario_anim_y_translation (the top_of_pole residual Hrmayt_real). *)
  (* It calls geo_update_animation_frame(&obj->animInfo, NULL) -- writing    *)
  (* THROUGH obj -- AND writes *translation.  So neither the single-arg oc   *)
  (* gate (last_arg_local alone: PHANTOM-FALSE, admits obj=&action-cell) nor *)
  (* the single-arg sc gate (arg0_safe alone: admits translation=&action-    *)
  (* cell) is sound.  The faithful gate is the CONJUNCTION: arg0 lands in    *)
  (* SafeB AND the last arg is a watched-disjoint stack local.  Under it the *)
  (* every write stays in SafeB or a local (both disjoint from bm), so       *)
  (* carried survives -- a precise, per-symbol, TRUE-in-model residual       *)
  (* (discipline Step 2 refinement), not the phantom forall.  The SAME gate  *)
  (* serves perform_hanging_step (writes through m AND nextPos) for the      *)
  (* hang/tornado Tier-2 leaves.                                             *)
  (* ====================================================================== *)

  (* the CONDITIONAL arg0 gate: arg0, IF it is a pointer, lands in SafeB.
     (Weaker than arg0_safe -- it does NOT assert arg0 is a Vptr.)  This is
     the form a BARE chase TEMP supports: chase_root_set_sound / chase_inv
     only pin the temp's pointer values to SafeB, never that it holds one.
     It is still SOUND as the spec gate: the spec is conditioned on
     eval_funcall existing, and the helper derefs arg0 internally, forcing a
     genuine pointer there -- so the Vint case never produces a real run. *)
  Definition arg0_cond_safe (vargs : list val) : Prop :=
    match vargs with
    | v0 :: _ => forall b ofs, v0 = Vptr b ofs -> SafeB b
    | nil => True
    end.

  (* the conjoined multi-pointer gate *)
  Definition oc2_gate (vargs : list val) : Prop :=
    arg0_cond_safe vargs /\ last_arg_local vargs.

  (* the ARG-AWARE residual for the multi-pointer internal helpers *)
  Definition call_pres_ext_oc2 (fid : ident) : Prop :=
    forall fd m0 vargs0 t0 m1 vres0,
      eval_funcall function_entry2 (lp_ge lp) m0 fd vargs0 t0 m1 vres0 ->
      resolves_lp fid fd ->
      oc2_gate vargs0 ->
      NoA m0 -> MWF m0 -> Mem.valid_block m0 bm ->
      action_sat not_tainted m0 bm ->
      Mem.valid_block m1 bm /\ action_sat not_tainted m1 bm /\
      MWF m1 /\ NoA m1.

  (* ====================================================================== *)
  (* THE oc2-GATED INTERNAL BODY-WALK PRODUCER.  To DISCHARGE an oc2 residual *)
  (* (Hoc2famft_real = call_pres_ext_oc2 find_mario_anim_flags_and_translation), *)
  (* we must WALK that INTERNAL helper's body under the oc2 gate (obj=SafeB-  *)
  (* cond, translation=local), exactly as set_pole_position was walked under *)
  (* marg (call_pres_of_body, DispatchKit).  This reduction lemma turns the  *)
  (* ext_oc2 obligation into a per-body obligation body_pres_oc2 (the actual *)
  (* walk).  Mirror of DispatchKit.call_pres_of_body but oc2-gated.          *)
  (* ====================================================================== *)
  Definition body_pres_oc2 (f : Clight.function) : Prop :=
    forall m vargs t m' vres,
      oc2_gate vargs ->
      eval_funcall function_entry2 (lp_ge lp) m (Internal f) vargs t m' vres ->
      NoA m -> MWF m -> Mem.valid_block m bm -> action_sat not_tainted m bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m'.

  Lemma call_pres_ext_oc2_of_body :
    forall (TU : Clight.program) (fid : ident) (f : Clight.function),
      linkorder TU lp ->
      (prog_defmap TU) ! fid = Some (Gfun (Internal f)) ->
      body_pres_oc2 f ->
      call_pres_ext_oc2 fid.
  Proof.
    intros TU fid f LOtu Hdm Hbp fd m0 vargs0 t0 m1 vres0
           Hevf Hres Hgate HN HM HV HS.
    pose proof (resolve_pin_fd TU fid f fd LOtu Hdm Hres) as ->.
    destruct (Hbp m0 vargs0 t0 m1 vres0 Hgate Hevf HN HM HV HS)
      as (HV' & HS' & HM').
    repeat split;
      [ exact HV' | exact HS' | exact HM' | exact (HNoA_of_MWF _ HM') ].
  Qed.

  (* THE CALL-SITE BRICK: a Scall to a multi-pointer helper whose arg0 lands
     in SafeB AND whose last arg is a stack local preserves carried.
     (Structure mirrors oc_scall_pres / sc_scall_pres exactly.) *)
  Lemma oc2_scall_pres :
    forall optid fid tyl rty cc args e le0 m0 tr le1 m1 out0,
      e ! fid = None ->
      call_pres_ext_oc2 fid ->
      (forall vargs, eval_exprlist (lp_ge lp) e le0 m0 args tyl vargs ->
                     oc2_gate vargs) ->
      exec_stmt function_entry2 (lp_ge lp) e le0 m0
        (Scall optid (Evar fid (Tfunction tyl rty cc)) args)
        tr le1 m1 out0 ->
      carried bm NoA MWF m0 ->
      carried bm NoA MWF m1 /\ out0 = Out_normal.
  Proof.
    intros optid fid tyl rty cc args e le0 m0 tr le1 m1 out0
           He Hoc2 Hgate Hexec Hc.
    inv Hexec.
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
        pose proof (Hgate vargs Hvl) as Hga
    end.
    destruct Hc as (HV & HS & HM & HN).
    match goal with
    | Hevf : eval_funcall _ _ _ _ _ _ _ _ |- _ =>
        destruct (Hoc2 _ _ _ _ _ _ Hevf Hres Hga HN HM HV HS)
          as (HV' & HS' & HM' & HN')
    end.
    split; [ | reflexivity ].
    split; [ exact HV' | split; [ exact HS' | split; [ exact HM' | exact HN' ] ] ].
  Qed.

  (* the combined eval_exprlist extractor for the canonical 3-arg multi-
     pointer shape: arg0 a chase TEMP holding a SafeB pointer, arg1 a scalar
     (ignored), arg2 a BARE ARRAY Evar of a watched-disjoint stack local
     (decays By_reference to its base address).  This is exactly the
     find_mario_anim_flags_and_translation(_t'2, 0, _translation) call site
     in return_mario_anim_y_translation.  It feeds oc2_scall_pres's gate. *)
  Lemma oc2_extract :
    forall e le m cid sz attr c lid ety n aattr tyenv lb vargs,
      (forall b o, le ! cid = Some (Vptr b o) -> SafeB b) ->
      e ! lid = Some (lb, tyenv) ->
      local_blk lp bm SafeB lb ->
      eval_exprlist (lp_ge lp) e le m
        (Etempvar cid (tptr (Tstruct sz attr))
          :: Econst_int c tint
          :: Evar lid (Tarray ety n aattr) :: nil)
        (tptr (Tstruct sz attr) :: tint :: tptr ety :: nil) vargs ->
      oc2_gate vargs.
  Proof.
    intros e le m cid sz attr c lid ety n aattr tyenv lb vargs
           Hcond Hlid Hloc Hvl.
    (* arg0: the chase tempvar -> value vc (le!cid = Some vc).  Process it
       NOW, while its cast is the ONLY sem_cast hyp (no ambiguity with arg1/2),
       producing the conditional-safe fact about the head value hd. *)
    inv Hvl.
    match goal with
    | He : eval_expr _ _ _ _ (Etempvar cid _) _ |- _ => inv He
    end;
      try (match goal with
           | Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl
           end).
    match goal with
    | Hg : le ! cid = Some ?vc, Hc0 : sem_cast ?vc _ _ _ = Some ?hd |- _ =>
        assert (Hhead : forall bb oo, hd = Vptr bb oo -> SafeB bb);
        [ intros bb oo Hhd; rewrite Hhd in Hc0;
          destruct vc as [ | iv | lv | fv | sv | bv ov ];
          cbn in Hc0; try discriminate Hc0;
          injection Hc0 as <- <-; exact (Hcond _ _ Hg)
        | clear Hc0 Hg ]
    end.
    (* arg1: the scalar const -- step past it (value irrelevant to the gate) *)
    match goal with
    | Hvl1 : eval_exprlist _ _ _ _ (Econst_int _ _ :: _) _ _ |- _ => inv Hvl1
    end.
    (* arg2: the bare array Evar -> Vptr lb 0 (local_blk) *)
    match goal with
    | Hvl2 : eval_exprlist _ _ _ _ (Evar _ _ :: _) _ _ |- _ => inv Hvl2
    end.
    match goal with
    | Hvl3 : eval_exprlist _ _ _ _ nil _ _ |- _ => inv Hvl3
    end.
    match goal with
    | He2 : eval_expr _ _ _ _ (Evar lid _) _ |- _ => inv He2
    end.
    match goal with
    | Hlv : eval_lvalue _ _ _ _ (Evar lid _) _ _ _ |- _ => inv Hlv
    end;
      [ | match goal with
          | He : e ! lid = None |- _ => rewrite Hlid in He; discriminate He
          end ].
    match goal with
    | Hd : deref_loc (typeof _) _ _ _ _ _ |- _ => cbn [typeof] in Hd
    end.
    match goal with
    | Hg : e ! lid = Some (?l, _), Hd : deref_loc (Tarray _ _ _) _ ?l _ _ _ |- _ =>
        assert (Hl : l = lb) by congruence; subst l; inv Hd;
        try (match goal with
             | Hacc : access_mode (Tarray _ _ _) = _ |- _ =>
                 cbn in Hacc; discriminate Hacc
             end)
    end.
    match goal with
    | Hc2 : sem_cast (Vptr lb _) _ _ _ = Some _ |- _ =>
        cbn in Hc2; injection Hc2 as <-
    end.
    (* assemble oc2_gate = arg0_cond_safe /\ last_arg_local *)
    split.
    - (* arg0_cond_safe vargs: vargs = hd :: _, which is exactly Hhead *)
      exact Hhead.
    - red. cbn [last_val]. exists lb, Ptrofs.zero.
      split; [ reflexivity | exact Hloc ].
  Qed.

  (* ====================================================================== *)
  (* THE marg-AND-oc GATE (the INTERNAL twin of oc2).  oc2 gates arg0 on     *)
  (* SafeB (a chased Object pointer); this gates arg0 on MARG -- arg0 is the  *)
  (* Mario state pointer itself = (bm, 0).  Needed for INTERNAL helpers that  *)
  (* take (m, .., outlocal) and write through BOTH m (Mario fields, marg-safe *)
  (* at non-action offsets) AND the last out-param (a caller stack local):    *)
  (* the canonical case is perform_hanging_step(m, nextPos), which directly   *)
  (* stores nextPos[1] = m->ceilHeight-78 and passes nextPos to               *)
  (* resolve_and_return_wall_collisions (which mutates it).  A marg-ONLY      *)
  (* call_pres (DispatchKit) is PHANTOM-FALSE for it (the unconstrained       *)
  (* nextPos could alias bm's action cell); a last-arg-local-ONLY oc is also  *)
  (* phantom-false (unconstrained arg0=m could be anywhere).  The conjoined   *)
  (* gate is the honest one.  Reusable: update_hang_moving's perform_hanging_ *)
  (* step call site AND (later) the act_tornado_twirling helper.             *)
  (* Mirror of call_pres_ext_oc2 / body_pres_oc2 / oc2_scall_pres, arg0       *)
  (* SafeB-cond -> marg=(bm,0).                                               *)
  (* ====================================================================== *)
  (* CONDITIONAL (mirrors marg_ok): the caller's body_pres only knows
     marg_ok bm vargs (arg0 is (bm,0) IF it is a pointer at all), never that
     arg0 IS a pointer -- the callee's own body forces that.  So arg0_marg must
     be the conditional form, or the gate is unprovable at the call site. *)
  Definition arg0_marg (vargs : list val) : Prop :=
    match vargs with
    | v0 :: _ => forall b o, v0 = Vptr b o -> b = bm /\ o = Ptrofs.zero
    | nil => True
    end.

  Definition mo_gate (vargs : list val) : Prop :=
    arg0_marg vargs /\ last_arg_local vargs.

  (* the ARG-AWARE residual for marg-AND-local-out-param internal helpers *)
  Definition call_pres_mo (fid : ident) : Prop :=
    forall fd m0 vargs0 t0 m1 vres0,
      eval_funcall function_entry2 (lp_ge lp) m0 fd vargs0 t0 m1 vres0 ->
      resolves_lp fid fd ->
      mo_gate vargs0 ->
      NoA m0 -> MWF m0 -> Mem.valid_block m0 bm ->
      action_sat not_tainted m0 bm ->
      Mem.valid_block m1 bm /\ action_sat not_tainted m1 bm /\
      MWF m1 /\ NoA m1.

  Definition body_pres_mo (f : Clight.function) : Prop :=
    forall m vargs t m' vres,
      mo_gate vargs ->
      eval_funcall function_entry2 (lp_ge lp) m (Internal f) vargs t m' vres ->
      NoA m -> MWF m -> Mem.valid_block m bm -> action_sat not_tainted m bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m'.

  Lemma call_pres_mo_of_body :
    forall (TU : Clight.program) (fid : ident) (f : Clight.function),
      linkorder TU lp ->
      (prog_defmap TU) ! fid = Some (Gfun (Internal f)) ->
      body_pres_mo f ->
      call_pres_mo fid.
  Proof.
    intros TU fid f LOtu Hdm Hbp fd m0 vargs0 t0 m1 vres0
           Hevf Hres Hgate HN HM HV HS.
    pose proof (resolve_pin_fd TU fid f fd LOtu Hdm Hres) as ->.
    destruct (Hbp m0 vargs0 t0 m1 vres0 Hgate Hevf HN HM HV HS)
      as (HV' & HS' & HM').
    repeat split;
      [ exact HV' | exact HS' | exact HM' | exact (HNoA_of_MWF _ HM') ].
  Qed.

  (* THE CALL-SITE BRICK: a Scall to a marg-and-local helper (arg0 = Mario
     (bm,0), last arg = stack local) preserves carried.  Verbatim mirror of
     oc2_scall_pres (the gate's internal shape is opaque to the proof). *)
  Lemma mo_scall_pres :
    forall optid fid tyl rty cc args e le0 m0 tr le1 m1 out0,
      e ! fid = None ->
      call_pres_mo fid ->
      (forall vargs, eval_exprlist (lp_ge lp) e le0 m0 args tyl vargs ->
                     mo_gate vargs) ->
      exec_stmt function_entry2 (lp_ge lp) e le0 m0
        (Scall optid (Evar fid (Tfunction tyl rty cc)) args)
        tr le1 m1 out0 ->
      carried bm NoA MWF m0 ->
      carried bm NoA MWF m1 /\ out0 = Out_normal.
  Proof.
    intros optid fid tyl rty cc args e le0 m0 tr le1 m1 out0
           He Hmo Hgate Hexec Hc.
    inv Hexec.
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
        pose proof (Hgate vargs Hvl) as Hga
    end.
    destruct Hc as (HV & HS & HM & HN).
    match goal with
    | Hevf : eval_funcall _ _ _ _ _ _ _ _ |- _ =>
        destruct (Hmo _ _ _ _ _ _ Hevf Hres Hga HN HM HV HS)
          as (HV' & HS' & HM' & HN')
    end.
    split; [ | reflexivity ].
    split; [ exact HV' | split; [ exact HS' | split; [ exact HM' | exact HN' ] ] ].
  Qed.

End OutParamArc.

(* ====================================================================== *)
(* THE WINDOW-OR-LOCAL (wol) ARC: the union gate for an external writer    *)
(* whose pointer args MIX safe bm-windows and stack locals in ONE call     *)
(* (push_mario_out_of_object's f32_find_wall_collision(&newMarioX,         *)
(* &m->pos[1], &newMarioZ, c, c)).  Neither the wc gate (ALL ptrs must be  *)
(* bm-windows) nor the ol gate (ALL ptrs local) fits.  The union gate is   *)
(* WEAKER than both, so ONE wol row per symbol REPLACES the wc and ol      *)
(* rows for that symbol (see the _of_wol derivations).                     *)
(* ====================================================================== *)
Section WolArc.
  Variable lp : Clight.program.
  Variable bm : block.
  Variable NoA MWF : mem -> Prop.
  Variable SafeB : block -> Prop.

  (* every POINTER argument is a watched-disjoint 4-byte bm-window OR a
     stack-local block; non-pointer args impose nothing. *)
  Definition args_window_or_local (vargs : list val) : Prop :=
    forall b ofs, In (Vptr b ofs) vargs ->
      (b = bm /\ store_window_ok (Ptrofs.unsigned ofs) 4 = true)
      \/ local_blk lp bm SafeB b.

  Definition call_pres_ext_wol (fid : ident) : Prop :=
    forall fd m0 vargs0 t0 m1 vres0,
      eval_funcall function_entry2 (lp_ge lp) m0 fd vargs0 t0 m1 vres0 ->
      resolves_lp lp fid fd ->
      args_window_or_local vargs0 ->
      NoA m0 -> MWF m0 -> Mem.valid_block m0 bm ->
      action_sat not_tainted m0 bm ->
      Mem.valid_block m1 bm /\ action_sat not_tainted m1 bm /\
      MWF m1 /\ NoA m1.

  (* THE CALL-SITE BRICK (structure mirrors wc_scall_pres verbatim). *)
  Lemma wol_scall_pres :
    forall optid fid tyl rty cc args e le0 m0 tr le1 m1 out0,
      e ! fid = None ->
      call_pres_ext_wol fid ->
      (forall vargs, eval_exprlist (lp_ge lp) e le0 m0 args tyl vargs ->
                     args_window_or_local vargs) ->
      exec_stmt function_entry2 (lp_ge lp) e le0 m0
        (Scall optid (Evar fid (Tfunction tyl rty cc)) args)
        tr le1 m1 out0 ->
      carried bm NoA MWF m0 ->
      carried bm NoA MWF m1 /\ out0 = Out_normal.
  Proof.
    intros optid fid tyl rty cc args e le0 m0 tr le1 m1 out0
           He Hwol Hgate Hexec Hc.
    inv Hexec.
    match goal with
    | Hcf : classify_fun _ = fun_case_f _ _ _ |- _ =>
        cbn in Hcf; injection Hcf as E1 E2 E3; subst
    end.
    match goal with
    | Hv : eval_expr _ _ _ _ (Evar _ _) ?vf |- _ =>
        destruct (eval_Evar_funct lp _ _ _ _ _ _ _ _ He Hv) as (bf & Hsym & ->)
    end.
    match goal with
    | Hff : Genv.find_funct _ (Vptr bf Ptrofs.zero) = Some ?fd |- _ =>
        assert (Hres : resolves_lp lp fid fd) by (exists bf; split; assumption)
    end.
    match goal with
    | Hvl : eval_exprlist _ _ _ _ _ _ ?vargs |- _ =>
        pose proof (Hgate vargs Hvl) as Hww
    end.
    destruct Hc as (HV & HS & HM & HN).
    match goal with
    | Hevf : eval_funcall _ _ _ _ _ _ _ _ |- _ =>
        destruct (Hwol _ _ _ _ _ _ Hevf Hres Hww HN HM HV HS)
          as (HV' & HS' & HM' & HN')
    end.
    split; [ | reflexivity ].
    split; [ exact HV' | split; [ exact HS' | split; [ exact HM' | exact HN' ] ] ].
  Qed.

  (* the union gate REFINES both per-symbol fwc gates: one wol row implies
     the wc row and the ol row for the same symbol. *)
  Lemma call_pres_ext_wc_of_wol :
    forall fid, call_pres_ext_wol fid -> call_pres_ext_wc lp bm NoA MWF fid.
  Proof.
    intros fid H fd m0 vargs0 t0 m1 vres0 Hevf Hres Hg HN HM HV HS.
    assert (Hg' : args_window_or_local vargs0)
      by (intros b ofs Hin; left; exact (Hg b ofs Hin)).
    exact (H _ _ _ _ _ _ Hevf Hres Hg' HN HM HV HS).
  Qed.

  Lemma call_pres_ext_ol_of_wol :
    forall fid,
      call_pres_ext_wol fid -> call_pres_ext_ol lp bm NoA MWF SafeB fid.
  Proof.
    intros fid H fd m0 vargs0 t0 m1 vres0 Hevf Hres Hg HN HM HV HS.
    assert (Hg' : args_window_or_local vargs0)
      by (intros b ofs Hin; right; exact (Hg b ofs Hin)).
    exact (H _ _ _ _ _ _ Hevf Hres Hg' HN HM HV HS).
  Qed.
End WolArc.
