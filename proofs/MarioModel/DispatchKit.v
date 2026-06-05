(* ====================================================================== *)
(* THE DISPATCH KIT: the AirborneSurface walk, made generic.              *)
(* (SPINE: consumed by the per-handler *Surface files.)                   *)
(*                                                                        *)
(* All seven mario_execute_*_action dispatchers share one skeleton:       *)
(*   check call + early return; [quicksand call / m->field stores];       *)
(*   Sset tmp (m->action); Sswitch tmp (uniform arms);                    *)
(*   [particleFlags epilogue]; return cancel.                             *)
(* AirborneSurface walked the airborne instance against a bespoke kill    *)
(* (AGates.airborne_dispatch_kill_lp). This file abstracts the walk over  *)
(*   - the selector temp and the case table (value_gate_stmt + the        *)
(*     generic kill value_gate_kill),                                     *)
(*   - the callee census (call_pres, fed per-handler from a TU defmap     *)
(*     census or a single pinned body),                                   *)
(*   - the epilogue fragments (epi_chk/epi_pres: temp sets, ifs, and      *)
(*     window-checked m->field stores -- CensusV2's class-F geometry).    *)
(* The per-handler files supply only vm_compute censuses + the entry      *)
(* inversion, and export ONE census-keyed Hpres_*_callees residual each.  *)
(*                                                                        *)
(* PIPELINE: nothing here mentions a concrete case table; every concrete  *)
(* shape fact is a vm_compute reflexivity check in the per-handler file.  *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking.
From SM64.Generated Require mario mario_actions_airborne.
From SM64.Proofs Require Import SymbolicLinking Flying Taint
  ActionValueFrame RealFrameValue RealFrameLinked AGates.
From SM64.Proofs Require Import CensusV2 EngineV2Consumer RestSurface
  AirborneSurface.

Import ListNotations.

(* NOTE on idents: clightgen interns idents from source strings, so _m,
   _cancel, _action, _MarioState are the SAME positive in every actions
   TU; we spell them via mario_actions_airborne.* / mario.* throughout
   (matching arm_split / eval_action_load_bm_lp), and each per-handler
   vm_compute shape pin re-checks the agreement on the real AST. *)

(* ====================================================================== *)
(* The canonical dispatch fragment, selector temp and case table abstract *)
(* ====================================================================== *)

Definition value_gate_stmt (tmp : ident) (cases : labeled_statements)
    : statement :=
  Ssequence
    (Sset tmp
       (Efield (Ederef (Etempvar mario_actions_airborne._m
                          (tptr (Tstruct mario._MarioState noattr)))
                  (Tstruct mario._MarioState noattr))
          mario._action tuint))
    (Sswitch (Etempvar tmp tuint) cases).

(* ---- the census combinators, keyed by an abstract callee list.  The
   tmp<>_m check keeps the _m provenance fact alive across the arm's
   call-result Sset. ---- *)
Definition arm_tabled_in (ids : list ident) (s : statement) : bool :=
  match arm_split s with
  | Some (tmp, fid) =>
      negb (Pos.eqb tmp mario_actions_airborne._m) && mem_id fid ids
  | None => false
  end.

Definition suffix_tabled_in (ids : list ident) (sl : labeled_statements)
    : bool :=
  match drop_skips sl with
  | LSnil => true
  | LScons _ s _ => arm_tabled_in ids s
  end.

Lemma suffix_tabled_in_LSnil :
  forall ids, suffix_tabled_in ids LSnil = true.
Proof. reflexivity. Qed.

(* the per-arm callee projection (for the per-handler census COMPLETENESS
   pins: hand-spelled list = prologue helpers ++ arm_callees table). *)
Fixpoint arm_callees (sl : labeled_statements) : list ident :=
  match sl with
  | LSnil => nil
  | LScons _ s rest =>
      match arm_split s with
      | Some (_, fid) => fid :: arm_callees rest
      | None => arm_callees rest
      end
  end.

(* ---- the epilogue recognizer: temp sets (never to _m), skips, ifs over
   those, and window-checked direct m->field stores (CensusV2 class F:
   the byte window provably misses every protected Mario cell). ---- *)
Fixpoint epi_chk (s : statement) : bool :=
  match s with
  | Sskip => true
  | Sset id _ => negb (Pos.eqb id mario_actions_airborne._m)
  | Sassign a1 _ => safe_mfield_store mario_actions_airborne._m a1
  | Ssequence s1 s2 => epi_chk s1 && epi_chk s2
  | Sifthenelse _ s1 s2 => epi_chk s1 && epi_chk s2
  | _ => false
  end.

(* ====================================================================== *)
(* The kit.                                                               *)
(* ====================================================================== *)

Section DispatchKit.
  Variable lp : Clight.program.
  Hypothesis LO_mario : linkorder mario.prog lp.

  Variable bm : block.
  Variable NoA MWF : mem -> Prop.

  (* NoA is a projection of the run invariant (mwf_real_ctl at the
     capstone instantiation). *)
  Hypothesis HNoA_of_MWF : forall m, MWF m -> NoA m.

  (* MWF tolerates window-checked stores into Mario's block (the
     epilogue particleFlags / quicksandDepth stores); instantiated by
     MWFReal.mwf_real_window. *)
  Hypothesis HMWF_window : forall mm mm' ch (delta : Z) vv,
      MWF mm -> store_window_ok delta (size_chunk ch) = true ->
      Mem.store ch mm bm delta vv = Some mm' -> MWF mm'.

  (* ================================================================== *)
  (* The generic dispatch kill (AGates.airborne_dispatch_kill_lp with   *)
  (* the selector temp and case table abstract; the action-load brick   *)
  (* eval_action_load_bm_lp was already generic in the temp).           *)
  (* ================================================================== *)
  Theorem value_gate_kill :
    forall tmp cases e le m tr le' m' out,
      le ! mario_actions_airborne._m = Some (Vptr bm Ptrofs.zero) ->
      action_sat not_tainted m bm ->
      exec_stmt function_entry2 (lp_ge lp) e le m
        (value_gate_stmt tmp cases) tr le' m' out ->
      exists v out1,
        Mem.load Mint32 m bm 12 = Some (Vint v) /\
        not_tainted v /\
        is_T_label (Int.unsigned v) = false /\
        out = outcome_switch out1 /\
        exec_stmt function_entry2 (lp_ge lp) e
          (PTree.set tmp (Vint v) le) m
          (seq_of_labeled_statement (select_switch (Int.unsigned v) cases))
          tr le' m' out1.
  Proof.
    intros tmp cases e le m tr le' m' out Hle Hsat Hexec.
    unfold value_gate_stmt in Hexec.
    inv Hexec.
    2: { match goal with H : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ => inv H end.
         match goal with H : Out_normal <> Out_normal |- _ =>
           contradiction H; reflexivity end. }
    match goal with H : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ => inv H end.
    match goal with H : eval_expr _ _ _ _ (Efield _ _ _) ?vv |- _ =>
      pose proof (eval_action_load_bm_lp lp LO_mario _ _ _ _ _ vv Hle H)
        as Hload end.
    match goal with H : exec_stmt _ _ _ _ _ (Sswitch _ _) _ _ _ _ |- _ => inv H end.
    match goal with H : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
      apply eval_expr_Etempvar_val in H; rename H into Hlet end.
    rewrite PTree.gss in Hlet.
    match goal with H : sem_switch_arg ?vv _ = Some _ |- _ =>
      unfold sem_switch_arg in H; cbn [classify_switch typeof] in H;
      destruct vv; try discriminate H; inv H end.
    inv Hlet.
    pose proof (Hsat _ Hload) as Hnt.
    pose proof (not_tainted_not_T_label _ Hnt) as Hlab.
    eexists i, _.
    split; [ exact Hload | ].
    split; [ exact Hnt | ].
    split; [ exact Hlab | ].
    split; [ reflexivity | ].
    match goal with H : exec_stmt _ _ _ _ _ (seq_of_labeled_statement _) _ _ _ _ |- _ =>
      exact H end.
  Qed.

  (* ================================================================== *)
  (* Per-callee preservation, abstracted over where the body comes from *)
  (* ================================================================== *)
  Definition call_pres (fid : ident) : Prop :=
    forall fd m0 vargs0 t0 m1 vres0,
      eval_funcall function_entry2 (lp_ge lp) m0 fd vargs0 t0 m1 vres0 ->
      resolves_lp lp fid fd ->
      marg_ok bm vargs0 ->
      NoA m0 -> MWF m0 -> Mem.valid_block m0 bm ->
      action_sat not_tainted m0 bm ->
      Mem.valid_block m1 bm /\ action_sat not_tainted m1 bm /\
      MWF m1 /\ NoA m1.

  (* censused-id form: the id is Internal in a linked TU and the per-TU
     residual supplies its body_pres instance. *)
  Lemma call_pres_of_census :
    forall (TU : Clight.program) (ids : list ident),
      linkorder TU lp ->
      forallb (internal_in (prog_defmap TU)) ids = true ->
      (forall fid f, mem_id fid ids = true ->
         (prog_defmap TU) ! fid = Some (Gfun (Internal f)) ->
         body_pres lp NoA MWF bm f) ->
      forall fid, mem_id fid ids = true -> call_pres fid.
  Proof.
    intros TU ids LOtu Hint Hpres fid Hmem fd m0 vargs0 t0 m1 vres0
           Hevf Hres Hmarg HN HM HV HS.
    pose proof (forallb_mem_id _ _ _ Hint Hmem) as Hfid.
    destruct (internal_in_spec _ _ Hfid) as (g & Hdm).
    pose proof (resolve_pin_fd lp _ _ _ _ LOtu Hdm Hres) as ->.
    destruct (Hpres fid g Hmem Hdm m0 vargs0 t0 m1 vres0
                (fun _ => Hmarg) Hevf HN HM HV HS) as (HV' & HS' & HM').
    repeat split;
      [ exact HV' | exact HS' | exact HM' | exact (HNoA_of_MWF _ HM') ].
  Qed.

  (* single-named-body form (mario_update_quicksand lives in
     mario_step.prog, not in the handler TUs). *)
  Lemma call_pres_of_body :
    forall (TU : Clight.program) (fid : ident) (f : Clight.function),
      linkorder TU lp ->
      (prog_defmap TU) ! fid = Some (Gfun (Internal f)) ->
      body_pres lp NoA MWF bm f ->
      call_pres fid.
  Proof.
    intros TU fid f LOtu Hdm Hpres fd m0 vargs0 t0 m1 vres0
           Hevf Hres Hmarg HN HM HV HS.
    pose proof (resolve_pin_fd lp _ _ _ _ LOtu Hdm Hres) as ->.
    destruct (Hpres m0 vargs0 t0 m1 vres0 (fun _ => Hmarg) Hevf HN HM HV HS)
      as (HV' & HS' & HM').
    repeat split;
      [ exact HV' | exact HS' | exact HM' | exact (HNoA_of_MWF _ HM') ].
  Qed.

  (* ================================================================== *)
  (* The uniform call sites at the empty env (the dispatchers have no   *)
  (* fn_vars).  1-arg: `optid := f(m)`.                                 *)
  (* ================================================================== *)
  Lemma kit_scall_pres :
    forall optid fid rty cc le0 m0 tr le1 m1 out0,
      exec_stmt function_entry2 (lp_ge lp) empty_env le0 m0
        (Scall optid (Evar fid (Tfunction (tyMSp :: nil) rty cc))
           (Etempvar mario_actions_airborne._m tyMSp :: nil))
        tr le1 m1 out0 ->
      call_pres fid ->
      (forall b o, le0 ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) ->
      NoA m0 -> MWF m0 -> Mem.valid_block m0 bm ->
      action_sat not_tainted m0 bm ->
      Mem.valid_block m1 bm /\ action_sat not_tainted m1 bm /\
      MWF m1 /\ NoA m1 /\ out0 = Out_normal /\
      exists vr, le1 = set_opttemp optid vr le0.
  Proof.
    intros optid fid rty cc le0 m0 tr le1 m1 out0 Hexec Hcp Htat HN HM HV HS.
    inv Hexec.
    match goal with
    | Hc : classify_fun _ = fun_case_f _ _ _ |- _ =>
        cbn in Hc; injection Hc as Hc1 Hc2 Hc3; subst
    end.
    match goal with
    | Hv : eval_expr _ _ _ _ (Evar _ _) _ |- _ =>
        apply eval_Evar_funct_empty in Hv; destruct Hv as (b & Hsym & ->)
    end.
    match goal with
    | Hff : Genv.find_funct _ (Vptr b Ptrofs.zero) = Some ?fd |- _ =>
        assert (Hres : resolves_lp lp fid fd) by (exists b; split; assumption)
    end.
    match goal with
    | Ha : eval_exprlist _ _ _ _ (_ :: nil) _ _ |- _ => inv Ha
    end.
    match goal with
    | Hl : eval_exprlist _ _ _ _ nil _ _ |- _ => inv Hl
    end.
    match goal with
    | Hv : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
        apply eval_expr_Etempvar_val in Hv; rename Hv into Hv1
    end.
    match goal with
    | Hc : sem_cast _ _ _ _ = Some _ |- _ =>
        apply sem_cast_ptr_ptr_id in Hc; subst
    end.
    match goal with
    | Hv1' : le0 ! _ = Some ?vv |- _ =>
        assert (Hmarg : marg_ok bm (vv :: nil))
          by (destruct vv; cbn; try exact I; exact (Htat _ _ Hv1'))
    end.
    match goal with
    | Hevf : eval_funcall _ _ _ _ (_ :: nil) _ _ _ |- _ =>
        destruct (Hcp _ _ _ _ _ _ Hevf Hres Hmarg HN HM HV HS)
          as (HV' & HS' & HM' & HN')
    end.
    refine (conj HV' (conj HS' (conj HM' (conj HN' (conj eq_refl _))))).
    eexists; reflexivity.
  Qed.

  (* 2-arg: `optid := f(m, a2)` -- the second argument is arbitrary
     (marg_ok constrains only the head; eval_expr never changes memory). *)
  Lemma kit_scall2_pres :
    forall optid fid t2 rty cc a2 le0 m0 tr le1 m1 out0,
      exec_stmt function_entry2 (lp_ge lp) empty_env le0 m0
        (Scall optid (Evar fid (Tfunction (tyMSp :: t2 :: nil) rty cc))
           (Etempvar mario_actions_airborne._m tyMSp :: a2 :: nil))
        tr le1 m1 out0 ->
      call_pres fid ->
      (forall b o, le0 ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) ->
      NoA m0 -> MWF m0 -> Mem.valid_block m0 bm ->
      action_sat not_tainted m0 bm ->
      Mem.valid_block m1 bm /\ action_sat not_tainted m1 bm /\
      MWF m1 /\ NoA m1 /\ out0 = Out_normal /\
      exists vr, le1 = set_opttemp optid vr le0.
  Proof.
    intros optid fid t2 rty cc a2 le0 m0 tr le1 m1 out0 Hexec Hcp Htat HN HM HV HS.
    inv Hexec.
    match goal with
    | Hc : classify_fun _ = fun_case_f _ _ _ |- _ =>
        cbn in Hc; injection Hc as Hc1 Hc2 Hc3; subst
    end.
    match goal with
    | Hv : eval_expr _ _ _ _ (Evar _ _) _ |- _ =>
        apply eval_Evar_funct_empty in Hv; destruct Hv as (b & Hsym & ->)
    end.
    match goal with
    | Hff : Genv.find_funct _ (Vptr b Ptrofs.zero) = Some ?fd |- _ =>
        assert (Hres : resolves_lp lp fid fd) by (exists b; split; assumption)
    end.
    match goal with
    | Ha : eval_exprlist _ _ _ _ (_ :: _ :: nil) _ _ |- _ => inv Ha
    end.
    match goal with
    | Ha : eval_exprlist _ _ _ _ (_ :: nil) _ _ |- _ => inv Ha
    end.
    match goal with
    | Hl : eval_exprlist _ _ _ _ nil _ _ |- _ => inv Hl
    end.
    match goal with
    | Hv : eval_expr _ _ _ _ (Etempvar mario_actions_airborne._m _) _ |- _ =>
        apply eval_expr_Etempvar_val in Hv; rename Hv into Hv1
    end.
    match goal with
    | Hc : sem_cast _ (typeof (Etempvar _ _)) _ _ = Some _ |- _ =>
        apply sem_cast_ptr_ptr_id in Hc; subst
    end.
    match goal with
    | Hv1' : le0 ! mario_actions_airborne._m = Some ?vv,
      Hc2 : sem_cast _ (typeof a2) _ _ = Some ?v2 |- _ =>
        assert (Hmarg : marg_ok bm (vv :: v2 :: nil))
          by (destruct vv; cbn; try exact I; exact (Htat _ _ Hv1'))
    end.
    match goal with
    | Hevf : eval_funcall _ _ _ _ (_ :: _ :: nil) _ _ _ |- _ =>
        destruct (Hcp _ _ _ _ _ _ Hevf Hres Hmarg HN HM HV HS)
          as (HV' & HS' & HM' & HN')
    end.
    refine (conj HV' (conj HS' (conj HM' (conj HN' (conj eq_refl _))))).
    eexists; reflexivity.
  Qed.

  (* ---- the dispatch execution forces the _m temp to hold a pointer
     (its Sset loads m->action through it). ---- *)
  Lemma kit_dispatch_m_is_ptr :
    forall tmp cases le m0 tr le' m' out,
      exec_stmt function_entry2 (lp_ge lp) empty_env le m0
        (value_gate_stmt tmp cases) tr le' m' out ->
      exists l o, le ! mario_actions_airborne._m = Some (Vptr l o).
  Proof.
    intros tmp cases le m0 tr le' m' out Hexec.
    unfold value_gate_stmt in Hexec.
    assert (Hset : exists v,
               eval_expr (lp_ge lp) empty_env le m0
                 (Efield (Ederef
                            (Etempvar mario_actions_airborne._m
                               (tptr (Tstruct mario._MarioState noattr)))
                            (Tstruct mario._MarioState noattr))
                    mario._action tuint) v).
    { inv Hexec;
        match goal with
        | Hs : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ => inv Hs
        end;
        eexists; eassumption. }
    destruct Hset as (v & Hev).
    apply eval_expr_Efield_load in Hev.
    destruct Hev as (loc & ofs & bf & Hlv & _).
    apply eval_lvalue_Efield_inv in Hlv.
    destruct Hlv as (o0 & id & att & co & delta & Hbase & _).
    apply eval_expr_Ederef_load in Hbase.
    destruct Hbase as (l2 & o2 & bf2 & Hlv2 & _).
    apply eval_lvalue_Ederef_base in Hlv2.
    apply eval_expr_Etempvar_val in Hlv2.
    eauto.
  Qed.

  (* ================================================================== *)
  (* THE GENERIC DISPATCH WALK: under the carried invariant the real    *)
  (* dispatch fragment preserves the state, falls through normally, and *)
  (* keeps the _m provenance fact (for the epilogue).                   *)
  (* ================================================================== *)
  Lemma value_gate_pres :
    forall tmp cases (ids : list ident),
      Pos.eqb tmp mario_actions_airborne._m = false ->
      nonT_suffixes_ok (suffix_tabled_in ids) cases = true ->
      (forall fid, mem_id fid ids = true -> call_pres fid) ->
      forall le m0 tr le' m' out,
        le ! mario_actions_airborne._m = Some (Vptr bm Ptrofs.zero) ->
        NoA m0 -> MWF m0 -> Mem.valid_block m0 bm ->
        action_sat not_tainted m0 bm ->
        exec_stmt function_entry2 (lp_ge lp) empty_env le m0
          (value_gate_stmt tmp cases) tr le' m' out ->
        Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\
        MWF m' /\ NoA m' /\
        (forall b o, le' ! mario_actions_airborne._m = Some (Vptr b o) ->
                     b = bm /\ o = Ptrofs.zero) /\
        out = Out_normal.
  Proof.
    intros tmp cases ids Htne Hcensus Hcps le m0 tr le' m' out
           Hle HN HM HV HS Hexec.
    apply Pos.eqb_neq in Htne.
    destruct (value_gate_kill tmp cases empty_env le m0 tr le' m' out
                Hle HS Hexec)
      as (v & out1 & Hload & Hnt & Hlab & Hout & Hrun).
    assert (Htat1 : forall b o,
               (PTree.set tmp (Vint v) le) ! mario_actions_airborne._m
                 = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
    { intros b o Hg.
      rewrite PTree.gso in Hg by congruence.
      rewrite Hle in Hg. injection Hg as Hg1 Hg2. subst.
      split; reflexivity. }
    pose proof (select_switch_nonT_ok (suffix_tabled_in ids) (Int.unsigned v)
                  cases Hcensus Hlab (suffix_tabled_in_LSnil ids)) as Htab.
    apply exec_seq_drop_skips in Hrun.
    unfold suffix_tabled_in in Htab.
    destruct (drop_skips (select_switch (Int.unsigned v) cases))
      as [| o0 s_arm tail] eqn:E.
    - (* no real arm: the switch is a no-op *)
      cbn [seq_of_labeled_statement] in Hrun. inv Hrun. try subst out.
      cbn [outcome_switch].
      refine (conj HV (conj HS (conj HM (conj HN (conj Htat1 eq_refl))))).
    - (* exactly one censused arm *)
      unfold arm_tabled_in in Htab.
      destruct (arm_split s_arm) as [[tmp2 fid] | ] eqn:Esplit;
        [ | discriminate Htab ].
      apply andb_true_iff in Htab as [Htmp2 Hfidmem].
      apply negb_true_iff in Htmp2. apply Pos.eqb_neq in Htmp2.
      apply arm_split_shape in Esplit. subst s_arm.
      cbn [seq_of_labeled_statement] in Hrun.
      inv Hrun.
      + (* the arm finished Out_normal: impossible, it ends in Sbreak *)
        exfalso.
        match goal with
        | Hs : exec_stmt _ _ _ ?le0 _ (Ssequence ?s1 Sbreak) _ _ _ Out_normal |- _ =>
            exact (ends_in_break_not_normal lp _ _ _ (Ssequence s1 Sbreak)
                     _ _ _ _ eq_refl Hs eq_refl)
        end.
      + (* only the arm ran; the textual tail is dead *)
        match goal with
        | Hs : exec_stmt _ _ _ _ _ (Ssequence _ Sbreak) _ _ _ _ |- _ =>
            rename Hs into Harm
        end.
        inv Harm.
        * (* inner normal, then Sbreak *)
          match goal with
          | Hb : exec_stmt _ _ _ _ _ Sbreak _ _ _ _ |- _ => inv Hb
          end.
          match goal with
          | Hi : exec_stmt _ _ _ _ _ (Ssequence _ (Sset _ _)) _ _ _ _ |- _ =>
              rename Hi into Hinner
          end.
          inv Hinner.
          -- (* the call, then the cancel Sset *)
             match goal with
             | Hs : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ =>
                 rename Hs into Hcset
             end.
             match goal with
             | Hc : exec_stmt _ _ _ _ _ (Scall _ _ _) _ _ _ _ |- _ =>
                 rename Hc into Hcall
             end.
             destruct (kit_scall_pres _ _ _ _ _ _ _ _ _ _ Hcall
                         (Hcps _ Hfidmem) Htat1 HN HM HV HS)
               as (HV' & HS' & HM' & HN' & _ & (vr & Hle1)).
             cbn [set_opttemp] in Hle1. subst.
             inv Hcset.
             try subst out.
             cbn [outcome_switch].
             refine (conj HV' (conj HS' (conj HM' (conj HN' (conj _ eq_refl))))).
             intros b o Hg.
             rewrite PTree.gso in Hg
               by (intro HH; vm_compute in HH; discriminate HH).
             rewrite PTree.gso in Hg by congruence.
             exact (Htat1 _ _ Hg).
          -- (* the call alone ended non-normally: Scall is Out_normal *)
             exfalso.
             match goal with
             | Hc : exec_stmt _ _ _ _ _ (Scall _ _ _) _ _ _ ?o,
               Hn : ?o <> Out_normal |- _ => inv Hc; congruence
             end.
        * (* the arm itself ended non-normally before Sbreak: the inner
             call+set sequence is always Out_normal *)
          exfalso.
          match goal with
          | Hi : exec_stmt _ _ _ _ _ (Ssequence _ (Sset _ _)) _ _ _ ?o,
            Hn : ?o <> Out_normal |- _ => rename Hi into Hinner
          end.
          inv Hinner;
            [ match goal with
              | Hs : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ =>
                  inv Hs; congruence
              end
            | match goal with
              | Hc : exec_stmt _ _ _ _ _ (Scall _ _ _) _ _ _ _ |- _ =>
                  inv Hc; congruence
              end ].
  Qed.

  (* ================================================================== *)
  (* The epilogue store brick: a window-checked m->field Sassign.       *)
  (* (CensusV2 chk_assign's class F, restated against exec_stmt with    *)
  (* the conditional _m provenance fact.)                               *)
  (* ================================================================== *)
  Lemma epi_assign_pres :
    forall a1 a2 e le m0 tr le' m' out,
      safe_mfield_store mario_actions_airborne._m a1 = true ->
      (forall b o, le ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) ->
      exec_stmt function_entry2 (lp_ge lp) e le m0 (Sassign a1 a2)
        tr le' m' out ->
      MWF m0 -> Mem.valid_block m0 bm -> action_sat not_tainted m0 bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\
      le' = le /\ out = Out_normal.
  Proof.
    intros a1 a2 e le m0 tr le' m' out Hsf Htat Hexec HM HV HS.
    inv Hexec.
    destruct (safe_mfield_store_shape _ _ Hsf) as (fld & fty & -> & Hgeo).
    destruct (mfield_geom_chk_sound _ _ Hgeo) as (delta & ch & Hfo & Hac & Hwin).
    (* the base temp holds Mario's pointer *)
    match goal with
    | Hlv0 : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ =>
        pose proof Hlv0 as Hpin;
        apply eval_lvalue_Efield_base in Hpin;
        destruct Hpin as (oo0 & Hbase);
        apply eval_expr_Ederef_load in Hbase;
        destruct Hbase as (lb & ob & bfb & Hlvb & _);
        apply eval_lvalue_Ederef_base in Hlvb;
        apply eval_expr_Etempvar_val in Hlvb
    end.
    destruct (Htat _ _ Hlvb) as [E1 E2]. subst lb ob.
    (* the lvalue geometry: Mario's block at the mario.prog field offset *)
    match goal with
    | Hlv0 : eval_lvalue _ _ _ _ (Efield _ _ _) ?loc ?ofs ?bf |- _ =>
        destruct (mfield_lvalue_geom_lp lp LO_mario _ _ _ _ _ _
                    loc ofs bf _ _ _ Hlvb Hfo Hlv0) as (E3 & E4 & E5);
        subst loc ofs bf
    end.
    match goal with
    | Has : assign_loc _ _ _ _ _ _ _ m' |- _ =>
        rewrite Ptrofs.add_zero_l in Has;
        cbn [typeof] in Has;
        inv Has;
        try (match goal with Hac2 : access_mode fty = _ |- _ =>
               rewrite Hac in Hac2; discriminate Hac2 end)
    end.
    match goal with
    | Hsv0 : Mem.storev _ _ _ _ = Some m',
      Hac2 : access_mode fty = By_value ?ch2 |- _ =>
        rewrite Hac in Hac2; injection Hac2 as <-;
        unfold Mem.storev in Hsv0;
        rewrite Ptrofs.unsigned_repr in Hsv0
    end.
    2:{ (* delta in range, from the census bounds *)
        unfold store_window_ok in Hwin.
        repeat (apply andb_true_iff in Hwin; destruct Hwin as [Hwin ?]).
        match goal with
        | Hb1 : (0 <=? delta) = true, Hb2 : (delta + _ <=? _) = true,
          Hb3 : (0 <? _) = true |- _ =>
            apply Z.leb_le in Hb1; apply Z.leb_le in Hb2;
            apply Z.ltb_lt in Hb3; lia
        end. }
    match goal with
    | Hsv : Mem.store _ _ _ _ _ = Some m' |- _ =>
        split; [ eauto using Mem.store_valid_block_1 | split ];
        [ (* action_sat: the window misses [12,16) *)
          intros av Hload;
          rewrite (Mem.load_store_other _ _ _ _ _ _ Hsv) in Hload;
          [ exact (HS av Hload) | right ]
        | split;
          [ exact (HMWF_window _ _ _ _ _ HM Hwin Hsv)
          | split; reflexivity ] ]
    end.
    (* the [12,16) disjointness from the window booleans *)
    unfold store_window_ok in Hwin.
    apply andb_true_iff in Hwin as [Hwin Hw148].
    apply andb_true_iff in Hwin as [Hwin Hw136].
    apply andb_true_iff in Hwin as [Hwin Hw12].
    apply orb_true_iff in Hw12 as [Hw12 | Hw12]; apply Z.leb_le in Hw12;
      [ right; exact Hw12 | left; cbn [size_chunk]; lia ].
  Qed.

  (* ================================================================== *)
  (* THE EPILOGUE WALK: any epi_chk-passing fragment preserves the      *)
  (* carried state, the _m provenance fact, and falls through normally. *)
  (* ================================================================== *)
  Lemma epi_pres :
    forall s e le m0 tr le' m' out,
      epi_chk s = true ->
      (forall b o, le ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) ->
      exec_stmt function_entry2 (lp_ge lp) e le m0 s tr le' m' out ->
      MWF m0 -> Mem.valid_block m0 bm -> action_sat not_tainted m0 bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\
      (forall b o, le' ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) /\
      out = Out_normal.
  Proof.
    induction s; intros ee le m0 tr le' m' out Hchk Htat Hexec HM HV HS;
      try discriminate Hchk.
    - (* Sskip *)
      inv Hexec.
      exact (conj HV (conj HS (conj HM (conj Htat eq_refl)))).
    - (* Sassign: the window-checked m->field store *)
      cbn [epi_chk] in Hchk.
      destruct (epi_assign_pres _ _ _ _ _ _ _ _ _ Hchk Htat Hexec HM HV HS)
        as (HV' & HS' & HM' & Hle' & Hout). subst le'.
      exact (conj HV' (conj HS' (conj HM' (conj Htat Hout)))).
    - (* Sset: never to _m, so the provenance fact survives by gso *)
      cbn [epi_chk] in Hchk. apply negb_true_iff in Hchk. apply Pos.eqb_neq in Hchk.
      inv Hexec.
      refine (conj HV (conj HS (conj HM (conj _ eq_refl)))).
      intros b o Hg.
      rewrite PTree.gso in Hg by congruence.
      exact (Htat _ _ Hg).
    - (* Ssequence *)
      cbn [epi_chk] in Hchk. apply andb_true_iff in Hchk as [H1 H2].
      inv Hexec.
      + match goal with
        | Ha : exec_stmt _ _ _ le _ s1 _ ?lem _ Out_normal,
          Hb : exec_stmt _ _ _ ?lem _ s2 _ _ _ _ |- _ =>
            destruct (IHs1 _ _ _ _ _ _ _ H1 Htat Ha HM HV HS)
              as (HV1 & HS1 & HM1 & Htat1 & _);
            destruct (IHs2 _ _ _ _ _ _ _ H2 Htat1 Hb HM1 HV1 HS1)
              as (HV2 & HS2 & HM2 & Htat2 & Hout2);
            exact (conj HV2 (conj HS2 (conj HM2 (conj Htat2 Hout2))))
        end.
      + exfalso.
        match goal with
        | Ha : exec_stmt _ _ _ _ _ s1 _ _ _ ?oo, Hn : ?oo <> Out_normal |- _ =>
            destruct (IHs1 _ _ _ _ _ _ _ H1 Htat Ha HM HV HS)
              as (_ & _ & _ & _ & Ho);
            exact (Hn Ho)
        end.
    - (* Sifthenelse *)
      cbn [epi_chk] in Hchk. apply andb_true_iff in Hchk as [H1 H2].
      inv Hexec.
      match goal with
      | Hb : exec_stmt _ _ _ _ _ (if ?b then s1 else s2) _ _ _ _ |- _ =>
          destruct b;
          [ destruct (IHs1 _ _ _ _ _ _ _ H1 Htat Hb HM HV HS)
              as (HV1 & HS1 & HM1 & Htat1 & Hout1)
          | destruct (IHs2 _ _ _ _ _ _ _ H2 Htat Hb HM HV HS)
              as (HV1 & HS1 & HM1 & Htat1 & Hout1) ];
          exact (conj HV1 (conj HS1 (conj HM1 (conj Htat1 Hout1))))
      end.
  Qed.

End DispatchKit.
