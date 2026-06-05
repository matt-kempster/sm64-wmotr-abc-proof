(* ====================================================================== *)
(* THE AUTOMATIC SURFACE: Hpres_aut DISCHARGED DOWN TO ITS LEAF CALLEES   *)
(* (SPINE: consumed by the MWF-grounded capstone).                        *)
(*                                                                        *)
(* f_mario_execute_automatic_action = check_common_automatic_cancels +    *)
(* early return; m->quicksandDepth := 0.0f (a window-checked store        *)
(* through Mario's block, offset 192); the 17-arm action dispatch         *)
(* (including act_in_cannon -- whose own leaf discharge is where the      *)
(* cannon-fire kill gets consumed); return cancel.                        *)
(*                                                                        *)
(* DispatchKit instantiation #2; ONE census-keyed residual remains.       *)
(* ====================================================================== *)

From Coq Require Import ZArith List.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking.
From SM64.Generated Require mario mario_actions_airborne mario_actions_automatic.
From SM64.Proofs Require Import SymbolicLinking Flying Taint
  ActionValueFrame RealFrameValue RealFrameLinked AGates.
From SM64.Proofs Require Import CensusV2 EngineV2Consumer RestSurface
  AirborneSurface DispatchKit.

Import ListNotations.

(* ====================================================================== *)
(* The leaf-callee census (top-level: no lp).                             *)
(* ====================================================================== *)

(* the prologue helper + the act handlers of the dispatch table, in table
   order; coverage-checked against the PROJECTED table below. *)
Definition automatic_callee_ids : list ident :=
  mario_actions_automatic._check_common_automatic_cancels ::
  mario_actions_automatic._act_holding_pole ::
  mario_actions_automatic._act_grab_pole_slow ::
  mario_actions_automatic._act_grab_pole_fast ::
  mario_actions_automatic._act_climbing_pole ::
  mario_actions_automatic._act_top_of_pole_transition ::
  mario_actions_automatic._act_top_of_pole ::
  mario_actions_automatic._act_start_hanging ::
  mario_actions_automatic._act_hanging ::
  mario_actions_automatic._act_hang_moving ::
  mario_actions_automatic._act_ledge_grab ::
  mario_actions_automatic._act_ledge_climb_slow ::
  mario_actions_automatic._act_ledge_climb_down ::
  mario_actions_automatic._act_ledge_climb_fast ::
  mario_actions_automatic._act_grabbed ::
  mario_actions_automatic._act_in_cannon ::
  mario_actions_automatic._act_tornado_twirling :: nil.

(* ---- the projections from the generated AST: the body is
   Sseq(prologue, Sseq(QSD-store, Sseq(DISPATCH, return))). ---- *)
Definition automatic_qsd : statement :=
  match fn_body mario_actions_automatic.f_mario_execute_automatic_action with
  | Ssequence _ (Ssequence q _) => q
  | _ => Sskip
  end.

Definition automatic_dispatch_stmt : statement :=
  third_seq (fn_body mario_actions_automatic.f_mario_execute_automatic_action).

Definition automatic_cases : labeled_statements :=
  match automatic_dispatch_stmt with
  | Ssequence _ (Sswitch _ ls) => ls
  | _ => LSnil
  end.

(* ---- the shape pins (vm_compute reflexivity over the real AST). ---- *)

Example automatic_dispatch_shape :
  automatic_dispatch_stmt =
  value_gate_stmt mario_actions_automatic._t'19 automatic_cases.
Proof. vm_compute. reflexivity. Qed.

Example automatic_body_shape :
  fn_body mario_actions_automatic.f_mario_execute_automatic_action =
  Ssequence
    (Ssequence
       (Scall (Some mario_actions_airborne._t'1)
          (Evar mario_actions_automatic._check_common_automatic_cancels tyAct)
          (Etempvar mario_actions_airborne._m tyMSp :: nil))
       (Sifthenelse (Etempvar mario_actions_airborne._t'1 tint)
          (Sreturn (Some (Econst_int (Int.repr 1) tint)))
          Sskip))
    (Ssequence
       automatic_qsd
       (Ssequence
          automatic_dispatch_stmt
          (Sreturn (Some (Etempvar mario_actions_airborne._cancel tint))))).
Proof. vm_compute. reflexivity. Qed.

(* the selector temp is not the Mario param temp *)
Example automatic_tmp_ne :
  Pos.eqb mario_actions_automatic._t'19 mario_actions_airborne._m = false.
Proof. vm_compute. reflexivity. Qed.

(* ---- the censuses. ---- *)

Example automatic_arms_tabled :
  nonT_suffixes_ok (suffix_tabled_in automatic_callee_ids) automatic_cases
  = true.
Proof. vm_compute. reflexivity. Qed.

(* POSITIVE CONTROL: the census is not vacuous -- an empty table fails. *)
Example automatic_arms_census_not_vacuous :
  nonT_suffixes_ok
    (fun sl => match drop_skips sl with
               | LSnil => true
               | LScons _ _ _ => false
               end)
    automatic_cases = false.
Proof. vm_compute. reflexivity. Qed.

(* COMPLETENESS PIN: the prologue helper and every callee the PROJECTED
   table can invoke is on the hand-spelled census list. *)
Example automatic_callee_ids_complete :
  forallb (fun fid => mem_id fid automatic_callee_ids)
    (mario_actions_automatic._check_common_automatic_cancels
       :: arm_callees automatic_cases) = true.
Proof. vm_compute. reflexivity. Qed.

(* every censused callee is defined INTERNAL by the automatic TU itself *)
Example automatic_callees_internal :
  forallb (internal_in (prog_defmap mario_actions_automatic.prog))
    automatic_callee_ids = true.
Proof. vm_compute. reflexivity. Qed.

(* the projected quicksandDepth store passes the kit's recognizer (the
   byte window [192,196) misses every protected Mario cell). *)
Example automatic_qsd_ok : epi_chk automatic_qsd = true.
Proof. vm_compute. reflexivity. Qed.

(* ====================================================================== *)
(* The walk.                                                              *)
(* ====================================================================== *)

Section AutomaticSurface.
  Variable lp : Clight.program.
  Hypothesis LO_mario : linkorder mario.prog lp.
  Hypothesis LO_aut : linkorder mario_actions_automatic.prog lp.

  Variable bm : block.
  Variable NoA MWF : mem -> Prop.

  Hypothesis HNoA_of_MWF : forall m, MWF m -> NoA m.
  Hypothesis HMWF_window : forall mm mm' ch (delta : Z) vv,
      MWF mm -> store_window_ok delta (size_chunk ch) = true ->
      Mem.store ch mm bm delta vv = Some mm' -> MWF mm'.

  (* THE RESIDUAL: per-leaf-callee preservation, keyed by the census. *)
  Hypothesis Hpres_callees : forall fid f,
      mem_id fid automatic_callee_ids = true ->
      (prog_defmap mario_actions_automatic.prog) ! fid
        = Some (Gfun (Internal f)) ->
      body_pres lp NoA MWF bm f.

  Lemma aut_call_pres :
    forall fid, mem_id fid automatic_callee_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    exact (call_pres_of_census lp bm NoA MWF HNoA_of_MWF
             mario_actions_automatic.prog automatic_callee_ids LO_aut
             automatic_callees_internal Hpres_callees).
  Qed.

  (* ================================================================== *)
  (* THE PAYOFF: Hpres_aut itself, PROVED from the per-leaf residuals.  *)
  (* ================================================================== *)
  Theorem automatic_pres :
    body_pres lp NoA MWF bm
      mario_actions_automatic.f_mario_execute_automatic_action.
  Proof.
    intros m vargs t m' vres Hmargp Hevf HN HM HV HS.
    assert (Hmarg : marg_ok bm vargs).
    { apply Hmargp. vm_compute. reflexivity. }
    inv Hevf.
    match goal with
    | He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry
    end.
    match goal with
    | Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody
    end.
    match goal with
    | Hf : Mem.free_list _ _ = Some _ |- _ => rename Hf into Hfree
    end.
    inv Hentry.
    match goal with
    | Ha : alloc_variables _ _ _ _ _ _ |- _ =>
        change (fn_vars mario_actions_automatic.f_mario_execute_automatic_action)
          with (@nil (ident * type)) in Ha;
        inv Ha
    end.
    match goal with
    | Hb : bind_parameter_temps _ _ _ = Some _ |- _ => rename Hb into Hbind
    end.
    change (fn_params mario_actions_automatic.f_mario_execute_automatic_action)
      with ((mario_actions_airborne._m, tyMSp) :: nil) in Hbind.
    cbn [bind_parameter_temps] in Hbind.
    destruct vargs as [| v0 vrest]; [ discriminate Hbind | ].
    destruct vrest; [ | discriminate Hbind ].
    injection Hbind as <-.
    change (blocks_of_env (lp_ge lp) empty_env)
      with (@nil (block * Z * Z)) in Hfree.
    cbn [Mem.free_list] in Hfree. injection Hfree as <-.
    rewrite automatic_body_shape in Hbody.
    set (base := create_undef_temps
                   (fn_temps mario_actions_automatic.f_mario_execute_automatic_action))
      in *.
    (* the param temp's exact provenance (if it is a pointer, it is Mario) *)
    assert (Htat0 : forall b o,
               (PTree.set mario_actions_airborne._m v0 base)
                 ! mario_actions_airborne._m = Some (Vptr b o) ->
               b = bm /\ o = Ptrofs.zero).
    { intros b o Hg. rewrite PTree.gss in Hg. injection Hg as ->.
      cbn in Hmarg. exact Hmarg. }
    assert (Hmem1 : mem_id
                      mario_actions_automatic._check_common_automatic_cancels
                      automatic_callee_ids = true)
      by (vm_compute; reflexivity).
    inv Hbody.
    - (* prologue normal: no early cancel; the frame continues *)
      match goal with
      | H1 : exec_stmt _ _ _ _ _ (Ssequence (Scall _ _ _) (Sifthenelse _ _ _))
               _ _ _ Out_normal |- _ => rename H1 into HS1
      end.
      match goal with
      | H2 : exec_stmt _ _ _ _ _ (Ssequence automatic_qsd _) _ _ _ _ |- _ =>
          rename H2 into Hrest2
      end.
      inv HS1.
      + (* the cancel-check call, then the (not-taken) if *)
        match goal with
        | Hc : exec_stmt _ _ _ _ _ (Scall (Some _) _ _) _ _ _ _ |- _ =>
            rename Hc into Hcall1
        end.
        match goal with
        | Hi : exec_stmt _ _ _ _ _ (Sifthenelse _ _ _) _ _ _ _ |- _ =>
            rename Hi into Hif
        end.
        destruct (kit_scall_pres lp bm NoA MWF _ _ _ _ _ _ _ _ _ _ Hcall1
                    (aut_call_pres _ Hmem1) Htat0 HN HM HV HS)
          as (HV1 & HS1' & HM1 & HN1 & _ & (vr1 & ->)).
        cbn [set_opttemp] in *.
        inv Hif.
        match goal with
        | Hbr : exec_stmt _ _ _ _ _ (if ?b then _ else _) _ _ _ Out_normal |- _ =>
            destruct b; [ inv Hbr | ]
        end.
        match goal with
        | Hbr : exec_stmt _ _ _ _ _ Sskip _ _ _ Out_normal |- _ => inv Hbr
        end.
        (* the post-prologue provenance fact *)
        assert (Htat1 : forall b o,
                   (PTree.set mario_actions_airborne._t'1 vr1
                      (PTree.set mario_actions_airborne._m v0 base))
                     ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero).
        { intros b o Hg.
          rewrite PTree.gso in Hg
            by (intro HH; vm_compute in HH; discriminate HH).
          exact (Htat0 _ _ Hg). }
        (* the quicksandDepth store, then dispatch + return *)
        inv Hrest2.
        * match goal with
          | Hq : exec_stmt _ _ _ _ _ automatic_qsd _ _ _ Out_normal |- _ =>
              rename Hq into Hqsd
          end.
          match goal with
          | Hr : exec_stmt _ _ _ _ _ (Ssequence automatic_dispatch_stmt _)
                   _ _ _ _ |- _ => rename Hr into Hrest3
          end.
          destruct (epi_pres lp LO_mario bm MWF HMWF_window
                      automatic_qsd _ _ _ _ _ _ _
                      automatic_qsd_ok Htat1 Hqsd HM1 HV1 HS1')
            as (HV2 & HS2 & HM2 & Htat2 & _).
          pose proof (HNoA_of_MWF _ HM2) as HN2.
          inv Hrest3.
          -- (* dispatch, then the return *)
             match goal with
             | Hd : exec_stmt _ _ _ _ _ automatic_dispatch_stmt _ _ _ _ |- _ =>
                 rename Hd into Hdisp
             end.
             match goal with
             | Hr : exec_stmt _ _ _ _ _ (Sreturn _) _ _ _ _ |- _ =>
                 rename Hr into Hret
             end.
             rewrite automatic_dispatch_shape in Hdisp.
             destruct (kit_dispatch_m_is_ptr lp _ _ _ _ _ _ _ _ Hdisp)
               as (l & o & Hlm).
             pose proof (Htat2 _ _ Hlm) as [-> ->].
             destruct (value_gate_pres lp LO_mario bm NoA MWF
                         mario_actions_automatic._t'19 automatic_cases
                         automatic_callee_ids
                         automatic_tmp_ne automatic_arms_tabled aut_call_pres
                         _ _ _ _ _ _ Hlm HN2 HM2 HV2 HS2 Hdisp)
               as (HV3 & HS3 & HM3 & HN3 & _ & _).
             inv Hret.
             repeat split; assumption.
          -- (* dispatch ended non-normally: refuted by the dispatch walk *)
             exfalso.
             match goal with
             | Hd : exec_stmt _ _ _ _ _ automatic_dispatch_stmt _ _ _ ?oo,
               Hn : ?oo <> Out_normal |- _ => rename Hd into Hdisp
             end.
             rewrite automatic_dispatch_shape in Hdisp.
             destruct (kit_dispatch_m_is_ptr lp _ _ _ _ _ _ _ _ Hdisp)
               as (l & o & Hlm).
             pose proof (Htat2 _ _ Hlm) as [-> ->].
             destruct (value_gate_pres lp LO_mario bm NoA MWF
                         mario_actions_automatic._t'19 automatic_cases
                         automatic_callee_ids
                         automatic_tmp_ne automatic_arms_tabled aut_call_pres
                         _ _ _ _ _ _ Hlm HN2 HM2 HV2 HS2 Hdisp)
               as (_ & _ & _ & _ & _ & Hnorm).
             congruence.
        * (* the quicksandDepth store ended non-normally: refuted *)
          exfalso.
          match goal with
          | Hq : exec_stmt _ _ _ _ _ automatic_qsd _ _ _ ?oo,
            Hn : ?oo <> Out_normal |- _ => rename Hq into Hqsd
          end.
          destruct (epi_pres lp LO_mario bm MWF HMWF_window
                      automatic_qsd _ _ _ _ _ _ _
                      automatic_qsd_ok Htat1 Hqsd HM1 HV1 HS1')
            as (_ & _ & _ & _ & Hnorm).
          congruence.
      + (* the cancel-check call ended non-normally: Scall is Out_normal *)
        exfalso.
        match goal with
        | Hc : exec_stmt _ _ _ _ _ (Scall (Some _) _ _) _ _ _ ?oo,
          Hn : ?oo <> Out_normal |- _ => inv Hc; congruence
        end.
    - (* prologue non-normal: the early `return 1` cancel path *)
      match goal with
      | H1 : exec_stmt _ _ _ _ _ (Ssequence (Scall _ _ _) (Sifthenelse _ _ _))
               _ _ _ _ |- _ => rename H1 into HS1
      end.
      inv HS1.
      + (* call normal; the if returns *)
        match goal with
        | Hc : exec_stmt _ _ _ _ _ (Scall (Some _) _ _) _ _ _ _ |- _ =>
            rename Hc into Hcall1
        end.
        match goal with
        | Hi : exec_stmt _ _ _ _ _ (Sifthenelse _ _ _) _ _ _ _ |- _ =>
            rename Hi into Hif
        end.
        destruct (kit_scall_pres lp bm NoA MWF _ _ _ _ _ _ _ _ _ _ Hcall1
                    (aut_call_pres _ Hmem1) Htat0 HN HM HV HS)
          as (HV1 & HS1' & HM1 & HN1 & _ & (vr1 & ->)).
        inv Hif.
        match goal with
        | Hbr : exec_stmt _ _ _ _ _ (if ?b then _ else _) _ _ _ _ |- _ =>
            destruct b
        end.
        * (* return 1: memory is the post-call memory *)
          match goal with
          | Hbr : exec_stmt _ _ _ _ _ (Sreturn _) _ _ _ _ |- _ => inv Hbr
          end.
          repeat split; assumption.
        * (* skip is Out_normal: contradicts the non-normal outcome *)
          exfalso.
          match goal with
          | Hbr : exec_stmt _ _ _ _ _ Sskip _ _ _ ?oo,
            Hn : ?oo <> Out_normal |- _ => inv Hbr; congruence
          end.
      + (* the call ended non-normally: Scall is Out_normal *)
        exfalso.
        match goal with
        | Hc : exec_stmt _ _ _ _ _ (Scall (Some _) _ _) _ _ _ ?oo,
          Hn : ?oo <> Out_normal |- _ => inv Hc; congruence
        end.
  Qed.

End AutomaticSurface.
