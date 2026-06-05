(* ====================================================================== *)
(* THE OBJECT SURFACE: Hpres_obj DISCHARGED DOWN TO ITS LEAF CALLEES  *)
(* (SPINE: consumed by the MWF-grounded capstone).                        *)
(*                                                                        *)
(* f_mario_execute_object_action = check_common_object_cancels +  *)
(* early return; mario_update_quicksand(m, 0.5f) + early return (the      *)
(* callee lives in mario_step.prog -- pinned by LO_stp, its body_pres is  *)
(* the shared Hpres_qsand residual); the 10-arm action dispatch; the      *)
(* particleFlags epilogue (window-checked store); return cancel.          *)
(*                                                                        *)
(* DispatchKit instantiation #5; the residuals that remain are ONE        *)
(* census-keyed hypothesis + the shared quicksand body.                   *)
(* ====================================================================== *)

From Coq Require Import ZArith List.
From compcert Require Import Coqlib Maps AST Integers Floats Values Events
  Memory Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking.
From SM64.Generated Require mario mario_actions_airborne
  mario_actions_object mario_step.
From SM64.Proofs Require Import SymbolicLinking Flying Taint
  ActionValueFrame RealFrameValue RealFrameLinked AGates.
From SM64.Proofs Require Import CensusV2 EngineV2Consumer RestSurface
  AirborneSurface DispatchKit.

Import ListNotations.

(* ====================================================================== *)
(* The leaf-callee census (top-level: no lp).                             *)
(* ====================================================================== *)

Definition object_callee_ids : list ident :=
  mario_actions_object._check_common_object_cancels ::
  mario_actions_object._act_punching ::
  mario_actions_object._act_picking_up ::
  mario_actions_object._act_dive_picking_up ::
  mario_actions_object._act_stomach_slide_stop ::
  mario_actions_object._act_placing_down ::
  mario_actions_object._act_throwing ::
  mario_actions_object._act_heavy_throw ::
  mario_actions_object._act_picking_up_bowser ::
  mario_actions_object._act_holding_bowser ::
  mario_actions_object._act_releasing_bowser :: nil.

(* ---- the projections from the generated AST: the body is
   Sseq(check, Sseq(quicksand, Sseq(DISPATCH, Sseq(EPILOGUE, return)))). ---- *)
Definition object_dispatch_stmt : statement :=
  third_seq (fn_body mario_actions_object.f_mario_execute_object_action).

Definition object_cases : labeled_statements :=
  match object_dispatch_stmt with
  | Ssequence _ (Sswitch _ ls) => ls
  | _ => LSnil
  end.

Definition object_epi : statement :=
  match fn_body mario_actions_object.f_mario_execute_object_action with
  | Ssequence _ (Ssequence _ (Ssequence _ (Ssequence e _))) => e
  | _ => Sskip
  end.

(* ---- the shape pins (vm_compute reflexivity over the real AST). ---- *)

Example object_dispatch_shape :
  object_dispatch_stmt =
  value_gate_stmt mario_actions_object._t'16 object_cases.
Proof. vm_compute. reflexivity. Qed.

Example object_body_shape :
  fn_body mario_actions_object.f_mario_execute_object_action =
  Ssequence
    (Ssequence
       (Scall (Some mario_actions_airborne._t'1)
          (Evar mario_actions_object._check_common_object_cancels
             tyAct)
          (Etempvar mario_actions_airborne._m tyMSp :: nil))
       (Sifthenelse (Etempvar mario_actions_airborne._t'1 tint)
          (Sreturn (Some (Econst_int (Int.repr 1) tint)))
          Sskip))
    (Ssequence
       (Ssequence
          (Scall (Some mario_actions_airborne._t'2)
             (Evar mario_actions_object._mario_update_quicksand
                (Tfunction (tyMSp :: tfloat :: nil) tuint cc_default))
             (Etempvar mario_actions_airborne._m tyMSp ::
              Econst_single (Float32.of_bits (Int.repr 1056964608)) tfloat
                :: nil))
          (Sifthenelse (Etempvar mario_actions_airborne._t'2 tuint)
             (Sreturn (Some (Econst_int (Int.repr 1) tint)))
             Sskip))
       (Ssequence
          object_dispatch_stmt
          (Ssequence
             object_epi
             (Sreturn (Some (Etempvar mario_actions_airborne._cancel tint)))))).
Proof. vm_compute. reflexivity. Qed.

(* the selector temp is not the Mario param temp *)
Example object_tmp_ne :
  Pos.eqb mario_actions_object._t'16 mario_actions_airborne._m = false.
Proof. vm_compute. reflexivity. Qed.

(* ---- the censuses. ---- *)

Example object_arms_tabled :
  nonT_suffixes_ok (suffix_tabled_in object_callee_ids) object_cases
  = true.
Proof. vm_compute. reflexivity. Qed.

(* POSITIVE CONTROL: the census is not vacuous -- an empty table fails. *)
Example object_arms_census_not_vacuous :
  nonT_suffixes_ok
    (fun sl => match drop_skips sl with
               | LSnil => true
               | LScons _ _ _ => false
               end)
    object_cases = false.
Proof. vm_compute. reflexivity. Qed.

(* COMPLETENESS PIN: the prologue helper and every callee the PROJECTED
   table can invoke is on the hand-spelled census list. *)
Example object_callee_ids_complete :
  forallb (fun fid => mem_id fid object_callee_ids)
    (mario_actions_object._check_common_object_cancels
       :: arm_callees object_cases) = true.
Proof. vm_compute. reflexivity. Qed.

(* every censused callee is defined INTERNAL by the stationary TU itself *)
Example object_callees_internal :
  forallb (internal_in (prog_defmap mario_actions_object.prog))
    object_callee_ids = true.
Proof. vm_compute. reflexivity. Qed.

(* the projected particleFlags epilogue passes the kit's recognizer *)
Example object_epi_ok : epi_chk object_epi = true.
Proof. vm_compute. reflexivity. Qed.

(* mario_update_quicksand is defined INTERNAL by mario_step.prog (so
   LO_stp pins its lp resolution to that real generated body). *)
Example quicksand_internal :
  (prog_defmap mario_step.prog) ! mario_step._mario_update_quicksand
  = Some (Gfun (Internal mario_step.f_mario_update_quicksand)).
Proof. vm_compute. reflexivity. Qed.

(* ====================================================================== *)
(* The walk.                                                              *)
(* ====================================================================== *)

Section ObjectSurface.
  Variable lp : Clight.program.
  Hypothesis LO_mario : linkorder mario.prog lp.
  Hypothesis LO_obj : linkorder mario_actions_object.prog lp.
  Hypothesis LO_stp : linkorder mario_step.prog lp.

  Variable bm : block.
  Variable NoA MWF : mem -> Prop.

  Hypothesis HNoA_of_MWF : forall m, MWF m -> NoA m.
  Hypothesis HMWF_window : forall mm mm' ch (delta : Z) vv,
      MWF mm -> store_window_ok delta (size_chunk ch) = true ->
      Mem.store ch mm bm delta vv = Some mm' -> MWF mm'.

  (* THE RESIDUALS: per-leaf-callee preservation, keyed by the census,
     plus the shared quicksand body (mario_step.prog). *)
  Hypothesis Hpres_callees : forall fid f,
      mem_id fid object_callee_ids = true ->
      (prog_defmap mario_actions_object.prog) ! fid
        = Some (Gfun (Internal f)) ->
      body_pres lp NoA MWF bm f.
  Hypothesis Hpres_qsand :
    body_pres lp NoA MWF bm mario_step.f_mario_update_quicksand.

  Lemma obj_call_pres :
    forall fid, mem_id fid object_callee_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    exact (call_pres_of_census lp bm NoA MWF HNoA_of_MWF
             mario_actions_object.prog object_callee_ids LO_obj
             object_callees_internal Hpres_callees).
  Qed.

  Lemma obj_qsand_call_pres :
    call_pres lp bm NoA MWF mario_actions_object._mario_update_quicksand.
  Proof.
    exact (call_pres_of_body lp bm NoA MWF HNoA_of_MWF
             mario_step.prog mario_step._mario_update_quicksand
             mario_step.f_mario_update_quicksand LO_stp
             quicksand_internal Hpres_qsand).
  Qed.

  (* ================================================================== *)
  (* THE PAYOFF: Hpres_obj itself, PROVED from the per-leaf residuals.  *)
  (* ================================================================== *)
  Theorem object_pres :
    body_pres lp NoA MWF bm
      mario_actions_object.f_mario_execute_object_action.
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
        change (fn_vars
                  mario_actions_object.f_mario_execute_object_action)
          with (@nil (ident * type)) in Ha;
        inv Ha
    end.
    match goal with
    | Hb : bind_parameter_temps _ _ _ = Some _ |- _ => rename Hb into Hbind
    end.
    change (fn_params
              mario_actions_object.f_mario_execute_object_action)
      with ((mario_actions_airborne._m, tyMSp) :: nil) in Hbind.
    cbn [bind_parameter_temps] in Hbind.
    destruct vargs as [| v0 vrest]; [ discriminate Hbind | ].
    destruct vrest; [ | discriminate Hbind ].
    injection Hbind as <-.
    change (blocks_of_env (lp_ge lp) empty_env)
      with (@nil (block * Z * Z)) in Hfree.
    cbn [Mem.free_list] in Hfree. injection Hfree as <-.
    rewrite object_body_shape in Hbody.
    set (base := create_undef_temps
                   (fn_temps
                      mario_actions_object.f_mario_execute_object_action))
      in *.
    (* the param temp's exact provenance (if it is a pointer, it is Mario) *)
    assert (Htat0 : forall b o,
               (PTree.set mario_actions_airborne._m v0 base)
                 ! mario_actions_airborne._m = Some (Vptr b o) ->
               b = bm /\ o = Ptrofs.zero).
    { intros b o Hg. rewrite PTree.gss in Hg. injection Hg as ->.
      cbn in Hmarg. exact Hmarg. }
    assert (Hmem1 : mem_id
                      mario_actions_object._check_common_object_cancels
                      object_callee_ids = true)
      by (vm_compute; reflexivity).
    inv Hbody.
    - (* check prologue normal: the frame continues *)
      match goal with
      | H1 : exec_stmt _ _ _ _ _ (Ssequence (Scall _ _ _) (Sifthenelse _ _ _))
               _ _ _ Out_normal |- _ => rename H1 into HS1
      end.
      match goal with
      | H2 : exec_stmt _ _ _ _ _
               (Ssequence (Ssequence (Scall _ _ _) (Sifthenelse _ _ _)) _)
               _ _ _ _ |- _ => rename H2 into Hrest2
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
                    (obj_call_pres _ Hmem1) Htat0 HN HM HV HS)
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
        assert (Htat1 : forall b o,
                   (PTree.set mario_actions_airborne._t'1 vr1
                      (PTree.set mario_actions_airborne._m v0 base))
                     ! mario_actions_airborne._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero).
        { intros b o Hg.
          rewrite PTree.gso in Hg
            by (intro HH; vm_compute in HH; discriminate HH).
          exact (Htat0 _ _ Hg). }
        (* the quicksand prologue *)
        inv Hrest2.
        * match goal with
          | H1 : exec_stmt _ _ _ _ _
                   (Ssequence (Scall _ _ _) (Sifthenelse _ _ _))
                   _ _ _ Out_normal |- _ => rename H1 into HS2
          end.
          match goal with
          | H2 : exec_stmt _ _ _ _ _ (Ssequence object_dispatch_stmt _)
                   _ _ _ _ |- _ => rename H2 into Hrest3
          end.
          inv HS2.
          -- match goal with
             | Hc : exec_stmt _ _ _ _ _ (Scall (Some _) _ _) _ _ _ _ |- _ =>
                 rename Hc into Hcall2
             end.
             match goal with
             | Hi : exec_stmt _ _ _ _ _ (Sifthenelse _ _ _) _ _ _ _ |- _ =>
                 rename Hi into Hif2
             end.
             destruct (kit_scall2_pres lp bm NoA MWF _ _ _ _ _ _ _ _ _ _ _ _
                         Hcall2 obj_qsand_call_pres Htat1 HN1 HM1 HV1 HS1')
               as (HV2 & HS2' & HM2 & HN2 & _ & (vr2 & ->)).
             cbn [set_opttemp] in *.
             inv Hif2.
             match goal with
             | Hbr : exec_stmt _ _ _ _ _ (if ?b then _ else _) _ _ _ Out_normal |- _ =>
                 destruct b; [ inv Hbr | ]
             end.
             match goal with
             | Hbr : exec_stmt _ _ _ _ _ Sskip _ _ _ Out_normal |- _ => inv Hbr
             end.
             assert (Htat2 : forall b o,
                        (PTree.set mario_actions_airborne._t'2 vr2
                           (PTree.set mario_actions_airborne._t'1 vr1
                              (PTree.set mario_actions_airborne._m v0 base)))
                          ! mario_actions_airborne._m = Some (Vptr b o) ->
                        b = bm /\ o = Ptrofs.zero).
             { intros b o Hg.
               rewrite PTree.gso in Hg
                 by (intro HH; vm_compute in HH; discriminate HH).
               exact (Htat1 _ _ Hg). }
             (* dispatch, then epilogue + return *)
             inv Hrest3.
             ++ match goal with
                | Hd : exec_stmt _ _ _ _ _ object_dispatch_stmt _ _ _ _ |- _ =>
                    rename Hd into Hdisp
                end.
                match goal with
                | Hr : exec_stmt _ _ _ _ _ (Ssequence object_epi _)
                         _ _ _ _ |- _ => rename Hr into Hrest4
                end.
                rewrite object_dispatch_shape in Hdisp.
                destruct (kit_dispatch_m_is_ptr lp _ _ _ _ _ _ _ _ Hdisp)
                  as (l & o & Hlm).
                pose proof (Htat2 _ _ Hlm) as [-> ->].
                destruct (value_gate_pres lp LO_mario bm NoA MWF
                            mario_actions_object._t'16 object_cases
                            object_callee_ids
                            object_tmp_ne object_arms_tabled
                            obj_call_pres
                            _ _ _ _ _ _ Hlm HN2 HM2 HV2 HS2' Hdisp)
                  as (HV3 & HS3 & HM3 & HN3 & Htat3 & _).
                inv Hrest4.
                ** match goal with
                   | He : exec_stmt _ _ _ _ _ object_epi _ _ _ _ |- _ =>
                       rename He into Hepi
                   end.
                   match goal with
                   | Hr : exec_stmt _ _ _ _ _ (Sreturn _) _ _ _ _ |- _ =>
                       rename Hr into Hret
                   end.
                   destruct (epi_pres lp LO_mario bm MWF HMWF_window
                               object_epi _ _ _ _ _ _ _
                               object_epi_ok Htat3 Hepi HM3 HV3 HS3)
                     as (HV4 & HS4 & HM4 & _ & _).
                   inv Hret.
                   repeat split; assumption.
                ** (* epilogue ended non-normally: refuted by the epi walk *)
                   exfalso.
                   match goal with
                   | He : exec_stmt _ _ _ _ _ object_epi _ _ _ ?oo,
                     Hn : ?oo <> Out_normal |- _ => rename He into Hepi
                   end.
                   destruct (epi_pres lp LO_mario bm MWF HMWF_window
                               object_epi _ _ _ _ _ _ _
                               object_epi_ok Htat3 Hepi HM3 HV3 HS3)
                     as (_ & _ & _ & _ & Hnorm).
                   congruence.
             ++ (* dispatch ended non-normally: refuted by the dispatch walk *)
                exfalso.
                match goal with
                | Hd : exec_stmt _ _ _ _ _ object_dispatch_stmt _ _ _ ?oo,
                  Hn : ?oo <> Out_normal |- _ => rename Hd into Hdisp
                end.
                rewrite object_dispatch_shape in Hdisp.
                destruct (kit_dispatch_m_is_ptr lp _ _ _ _ _ _ _ _ Hdisp)
                  as (l & o & Hlm).
                pose proof (Htat2 _ _ Hlm) as [-> ->].
                destruct (value_gate_pres lp LO_mario bm NoA MWF
                            mario_actions_object._t'16 object_cases
                            object_callee_ids
                            object_tmp_ne object_arms_tabled
                            obj_call_pres
                            _ _ _ _ _ _ Hlm HN2 HM2 HV2 HS2' Hdisp)
                  as (_ & _ & _ & _ & _ & Hnorm).
                congruence.
          -- (* the quicksand call ended non-normally: Scall is Out_normal *)
             exfalso.
             match goal with
             | Hc : exec_stmt _ _ _ _ _ (Scall (Some _) _ _) _ _ _ ?oo,
               Hn : ?oo <> Out_normal |- _ => inv Hc; congruence
             end.
        * (* quicksand prologue non-normal: the early `return 1` path *)
          match goal with
          | H1 : exec_stmt _ _ _ _ _
                   (Ssequence (Scall _ _ _) (Sifthenelse _ _ _)) _ _ _ _ |- _ =>
              rename H1 into HS2
          end.
          inv HS2.
          -- match goal with
             | Hc : exec_stmt _ _ _ _ _ (Scall (Some _) _ _) _ _ _ _ |- _ =>
                 rename Hc into Hcall2
             end.
             match goal with
             | Hi : exec_stmt _ _ _ _ _ (Sifthenelse _ _ _) _ _ _ _ |- _ =>
                 rename Hi into Hif2
             end.
             destruct (kit_scall2_pres lp bm NoA MWF _ _ _ _ _ _ _ _ _ _ _ _
                         Hcall2 obj_qsand_call_pres Htat1 HN1 HM1 HV1 HS1')
               as (HV2 & HS2' & HM2 & HN2 & _ & (vr2 & ->)).
             inv Hif2.
             match goal with
             | Hbr : exec_stmt _ _ _ _ _ (if ?b then _ else _) _ _ _ _ |- _ =>
                 destruct b
             end.
             ++ (* return 1: memory is the post-call memory *)
                match goal with
                | Hbr : exec_stmt _ _ _ _ _ (Sreturn _) _ _ _ _ |- _ => inv Hbr
                end.
                repeat split; assumption.
             ++ (* skip is Out_normal: contradicts the non-normal outcome *)
                exfalso.
                match goal with
                | Hbr : exec_stmt _ _ _ _ _ Sskip _ _ _ ?oo,
                  Hn : ?oo <> Out_normal |- _ => inv Hbr; congruence
                end.
          -- (* the quicksand call ended non-normally: Scall is Out_normal *)
             exfalso.
             match goal with
             | Hc : exec_stmt _ _ _ _ _ (Scall (Some _) _ _) _ _ _ ?oo,
               Hn : ?oo <> Out_normal |- _ => inv Hc; congruence
             end.
      + (* the check call ended non-normally: Scall is Out_normal *)
        exfalso.
        match goal with
        | Hc : exec_stmt _ _ _ _ _ (Scall (Some _) _ _) _ _ _ ?oo,
          Hn : ?oo <> Out_normal |- _ => inv Hc; congruence
        end.
    - (* check prologue non-normal: the early `return 1` cancel path *)
      match goal with
      | H1 : exec_stmt _ _ _ _ _ (Ssequence (Scall _ _ _) (Sifthenelse _ _ _))
               _ _ _ _ |- _ => rename H1 into HS1
      end.
      inv HS1.
      + match goal with
        | Hc : exec_stmt _ _ _ _ _ (Scall (Some _) _ _) _ _ _ _ |- _ =>
            rename Hc into Hcall1
        end.
        match goal with
        | Hi : exec_stmt _ _ _ _ _ (Sifthenelse _ _ _) _ _ _ _ |- _ =>
            rename Hi into Hif
        end.
        destruct (kit_scall_pres lp bm NoA MWF _ _ _ _ _ _ _ _ _ _ Hcall1
                    (obj_call_pres _ Hmem1) Htat0 HN HM HV HS)
          as (HV1 & HS1' & HM1 & HN1 & _ & (vr1 & ->)).
        inv Hif.
        match goal with
        | Hbr : exec_stmt _ _ _ _ _ (if ?b then _ else _) _ _ _ _ |- _ =>
            destruct b
        end.
        * match goal with
          | Hbr : exec_stmt _ _ _ _ _ (Sreturn _) _ _ _ _ |- _ => inv Hbr
          end.
          repeat split; assumption.
        * exfalso.
          match goal with
          | Hbr : exec_stmt _ _ _ _ _ Sskip _ _ _ ?oo,
            Hn : ?oo <> Out_normal |- _ => inv Hbr; congruence
          end.
      + exfalso.
        match goal with
        | Hc : exec_stmt _ _ _ _ _ (Scall (Some _) _ _) _ _ _ ?oo,
          Hn : ?oo <> Out_normal |- _ => inv Hc; congruence
        end.
  Qed.

End ObjectSurface.
