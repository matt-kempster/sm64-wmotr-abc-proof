(* ====================================================================== *)
(* THE MOVING SURFACE: Hpres_mov DISCHARGED DOWN TO ITS LEAF CALLEES  *)
(* (SPINE: consumed by the MWF-grounded capstone).                        *)
(*                                                                        *)
(* f_mario_execute_moving_action = check_common_moving_cancels +  *)
(* early return; mario_update_quicksand(m, 0.25f) + early return (the      *)
(* callee lives in mario_step.prog -- pinned by LO_stp, its body_pres is  *)
(* the shared Hpres_qsand residual); the 38-arm action dispatch; the      *)
(* two-store particleFlags epilogue (both window-checked); return cancel.          *)
(*                                                                        *)
(* DispatchKit instantiation #4; the residuals that remain are ONE        *)
(* census-keyed hypothesis + the shared quicksand body.                   *)
(* ====================================================================== *)

From Coq Require Import ZArith List.
From compcert Require Import Coqlib Maps AST Integers Floats Values Events
  Memory Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking.
From SM64.Generated Require mario mario_actions_airborne
  mario_actions_moving mario_step.
From SM64.Proofs Require Import SymbolicLinking Flying Taint
  ActionValueFrame RealFrameValue RealFrameLinked AGates.
From SM64.Proofs Require Import CensusV2 EngineV2Consumer RestSurface
  AirborneSurface DispatchKit.

Import ListNotations.

(* ====================================================================== *)
(* The leaf-callee census (top-level: no lp).                             *)
(* ====================================================================== *)

Definition moving_callee_ids : list ident :=
  mario_actions_moving._check_common_moving_cancels ::
  mario_actions_moving._act_walking ::
  mario_actions_moving._act_hold_walking ::
  mario_actions_moving._act_hold_heavy_walking ::
  mario_actions_moving._act_turning_around ::
  mario_actions_moving._act_finish_turning_around ::
  mario_actions_moving._act_braking ::
  mario_actions_moving._act_riding_shell_ground ::
  mario_actions_moving._act_crawling ::
  mario_actions_moving._act_burning_ground ::
  mario_actions_moving._act_decelerating ::
  mario_actions_moving._act_hold_decelerating ::
  mario_actions_moving._act_butt_slide ::
  mario_actions_moving._act_stomach_slide ::
  mario_actions_moving._act_hold_butt_slide ::
  mario_actions_moving._act_hold_stomach_slide ::
  mario_actions_moving._act_dive_slide ::
  mario_actions_moving._act_move_punching ::
  mario_actions_moving._act_crouch_slide ::
  mario_actions_moving._act_slide_kick_slide ::
  mario_actions_moving._act_hard_backward_ground_kb ::
  mario_actions_moving._act_hard_forward_ground_kb ::
  mario_actions_moving._act_backward_ground_kb ::
  mario_actions_moving._act_forward_ground_kb ::
  mario_actions_moving._act_soft_backward_ground_kb ::
  mario_actions_moving._act_soft_forward_ground_kb ::
  mario_actions_moving._act_ground_bonk ::
  mario_actions_moving._act_death_exit_land ::
  mario_actions_moving._act_jump_land ::
  mario_actions_moving._act_freefall_land ::
  mario_actions_moving._act_double_jump_land ::
  mario_actions_moving._act_side_flip_land ::
  mario_actions_moving._act_hold_jump_land ::
  mario_actions_moving._act_hold_freefall_land ::
  mario_actions_moving._act_triple_jump_land ::
  mario_actions_moving._act_backflip_land ::
  mario_actions_moving._act_quicksand_jump_land ::
  mario_actions_moving._act_hold_quicksand_jump_land ::
  mario_actions_moving._act_long_jump_land :: nil.

(* ---- the projections from the generated AST: the body is
   Sseq(check, Sseq(quicksand, Sseq(DISPATCH, Sseq(EPILOGUE, return)))). ---- *)
Definition moving_dispatch_stmt : statement :=
  third_seq (fn_body mario_actions_moving.f_mario_execute_moving_action).

Definition moving_cases : labeled_statements :=
  match moving_dispatch_stmt with
  | Ssequence _ (Sswitch _ ls) => ls
  | _ => LSnil
  end.

Definition moving_epi : statement :=
  match fn_body mario_actions_moving.f_mario_execute_moving_action with
  | Ssequence _ (Ssequence _ (Ssequence _ (Ssequence e _))) => e
  | _ => Sskip
  end.

(* ---- the shape pins (vm_compute reflexivity over the real AST). ---- *)

Example moving_dispatch_shape :
  moving_dispatch_stmt =
  value_gate_stmt mario_actions_moving._t'45 moving_cases.
Proof. vm_compute. reflexivity. Qed.

Example moving_body_shape :
  fn_body mario_actions_moving.f_mario_execute_moving_action =
  Ssequence
    (Ssequence
       (Scall (Some mario_actions_airborne._t'1)
          (Evar mario_actions_moving._check_common_moving_cancels
             tyAct)
          (Etempvar mario_actions_airborne._m tyMSp :: nil))
       (Sifthenelse (Etempvar mario_actions_airborne._t'1 tint)
          (Sreturn (Some (Econst_int (Int.repr 1) tint)))
          Sskip))
    (Ssequence
       (Ssequence
          (Scall (Some mario_actions_airborne._t'2)
             (Evar mario_actions_moving._mario_update_quicksand
                (Tfunction (tyMSp :: tfloat :: nil) tuint cc_default))
             (Etempvar mario_actions_airborne._m tyMSp ::
              Econst_single (Float32.of_bits (Int.repr 1048576000)) tfloat
                :: nil))
          (Sifthenelse (Etempvar mario_actions_airborne._t'2 tuint)
             (Sreturn (Some (Econst_int (Int.repr 1) tint)))
             Sskip))
       (Ssequence
          moving_dispatch_stmt
          (Ssequence
             moving_epi
             (Sreturn (Some (Etempvar mario_actions_airborne._cancel tint)))))).
Proof. vm_compute. reflexivity. Qed.

(* the selector temp is not the Mario param temp *)
Example moving_tmp_ne :
  Pos.eqb mario_actions_moving._t'45 mario_actions_airborne._m = false.
Proof. vm_compute. reflexivity. Qed.

(* ---- the censuses. ---- *)

Example moving_arms_tabled :
  nonT_suffixes_ok (suffix_tabled_in moving_callee_ids) moving_cases
  = true.
Proof. vm_compute. reflexivity. Qed.

(* POSITIVE CONTROL: the census is not vacuous -- an empty table fails. *)
Example moving_arms_census_not_vacuous :
  nonT_suffixes_ok
    (fun sl => match drop_skips sl with
               | LSnil => true
               | LScons _ _ _ => false
               end)
    moving_cases = false.
Proof. vm_compute. reflexivity. Qed.

(* COMPLETENESS PIN: the prologue helper and every callee the PROJECTED
   table can invoke is on the hand-spelled census list. *)
Example moving_callee_ids_complete :
  forallb (fun fid => mem_id fid moving_callee_ids)
    (mario_actions_moving._check_common_moving_cancels
       :: arm_callees moving_cases) = true.
Proof. vm_compute. reflexivity. Qed.

(* every censused callee is defined INTERNAL by the stationary TU itself *)
Example moving_callees_internal :
  forallb (internal_in (prog_defmap mario_actions_moving.prog))
    moving_callee_ids = true.
Proof. vm_compute. reflexivity. Qed.

(* the projected particleFlags epilogue passes the kit's recognizer *)
Example moving_epi_ok : epi_chk moving_epi = true.
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

Section MovingSurface.
  Variable lp : Clight.program.
  Hypothesis LO_mario : linkorder mario.prog lp.
  Hypothesis LO_mov : linkorder mario_actions_moving.prog lp.
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
      mem_id fid moving_callee_ids = true ->
      (prog_defmap mario_actions_moving.prog) ! fid
        = Some (Gfun (Internal f)) ->
      body_pres lp NoA MWF bm f.
  Hypothesis Hpres_qsand :
    body_pres lp NoA MWF bm mario_step.f_mario_update_quicksand.

  Lemma mov_call_pres :
    forall fid, mem_id fid moving_callee_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    exact (call_pres_of_census lp bm NoA MWF HNoA_of_MWF
             mario_actions_moving.prog moving_callee_ids LO_mov
             moving_callees_internal Hpres_callees).
  Qed.

  Lemma mov_qsand_call_pres :
    call_pres lp bm NoA MWF mario_actions_moving._mario_update_quicksand.
  Proof.
    exact (call_pres_of_body lp bm NoA MWF HNoA_of_MWF
             mario_step.prog mario_step._mario_update_quicksand
             mario_step.f_mario_update_quicksand LO_stp
             quicksand_internal Hpres_qsand).
  Qed.

  (* ================================================================== *)
  (* THE PAYOFF: Hpres_mov itself, PROVED from the per-leaf residuals.  *)
  (* ================================================================== *)
  Theorem moving_pres :
    body_pres lp NoA MWF bm
      mario_actions_moving.f_mario_execute_moving_action.
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
                  mario_actions_moving.f_mario_execute_moving_action)
          with (@nil (ident * type)) in Ha;
        inv Ha
    end.
    match goal with
    | Hb : bind_parameter_temps _ _ _ = Some _ |- _ => rename Hb into Hbind
    end.
    change (fn_params
              mario_actions_moving.f_mario_execute_moving_action)
      with ((mario_actions_airborne._m, tyMSp) :: nil) in Hbind.
    cbn [bind_parameter_temps] in Hbind.
    destruct vargs as [| v0 vrest]; [ discriminate Hbind | ].
    destruct vrest; [ | discriminate Hbind ].
    injection Hbind as <-.
    change (blocks_of_env (lp_ge lp) empty_env)
      with (@nil (block * Z * Z)) in Hfree.
    cbn [Mem.free_list] in Hfree. injection Hfree as <-.
    rewrite moving_body_shape in Hbody.
    set (base := create_undef_temps
                   (fn_temps
                      mario_actions_moving.f_mario_execute_moving_action))
      in *.
    (* the param temp's exact provenance (if it is a pointer, it is Mario) *)
    assert (Htat0 : forall b o,
               (PTree.set mario_actions_airborne._m v0 base)
                 ! mario_actions_airborne._m = Some (Vptr b o) ->
               b = bm /\ o = Ptrofs.zero).
    { intros b o Hg. rewrite PTree.gss in Hg. injection Hg as ->.
      cbn in Hmarg. exact Hmarg. }
    assert (Hmem1 : mem_id
                      mario_actions_moving._check_common_moving_cancels
                      moving_callee_ids = true)
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
                    (mov_call_pres _ Hmem1) Htat0 HN HM HV HS)
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
          | H2 : exec_stmt _ _ _ _ _ (Ssequence moving_dispatch_stmt _)
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
                         Hcall2 mov_qsand_call_pres Htat1 HN1 HM1 HV1 HS1')
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
                | Hd : exec_stmt _ _ _ _ _ moving_dispatch_stmt _ _ _ _ |- _ =>
                    rename Hd into Hdisp
                end.
                match goal with
                | Hr : exec_stmt _ _ _ _ _ (Ssequence moving_epi _)
                         _ _ _ _ |- _ => rename Hr into Hrest4
                end.
                rewrite moving_dispatch_shape in Hdisp.
                destruct (kit_dispatch_m_is_ptr lp _ _ _ _ _ _ _ _ Hdisp)
                  as (l & o & Hlm).
                pose proof (Htat2 _ _ Hlm) as [-> ->].
                destruct (value_gate_pres lp LO_mario bm NoA MWF
                            mario_actions_moving._t'45 moving_cases
                            moving_callee_ids
                            moving_tmp_ne moving_arms_tabled
                            mov_call_pres
                            _ _ _ _ _ _ Hlm HN2 HM2 HV2 HS2' Hdisp)
                  as (HV3 & HS3 & HM3 & HN3 & Htat3 & _).
                inv Hrest4.
                ** match goal with
                   | He : exec_stmt _ _ _ _ _ moving_epi _ _ _ _ |- _ =>
                       rename He into Hepi
                   end.
                   match goal with
                   | Hr : exec_stmt _ _ _ _ _ (Sreturn _) _ _ _ _ |- _ =>
                       rename Hr into Hret
                   end.
                   destruct (epi_pres lp LO_mario bm MWF HMWF_window
                               moving_epi _ _ _ _ _ _ _
                               moving_epi_ok Htat3 Hepi HM3 HV3 HS3)
                     as (HV4 & HS4 & HM4 & _ & _).
                   inv Hret.
                   repeat split; assumption.
                ** (* epilogue ended non-normally: refuted by the epi walk *)
                   exfalso.
                   match goal with
                   | He : exec_stmt _ _ _ _ _ moving_epi _ _ _ ?oo,
                     Hn : ?oo <> Out_normal |- _ => rename He into Hepi
                   end.
                   destruct (epi_pres lp LO_mario bm MWF HMWF_window
                               moving_epi _ _ _ _ _ _ _
                               moving_epi_ok Htat3 Hepi HM3 HV3 HS3)
                     as (_ & _ & _ & _ & Hnorm).
                   congruence.
             ++ (* dispatch ended non-normally: refuted by the dispatch walk *)
                exfalso.
                match goal with
                | Hd : exec_stmt _ _ _ _ _ moving_dispatch_stmt _ _ _ ?oo,
                  Hn : ?oo <> Out_normal |- _ => rename Hd into Hdisp
                end.
                rewrite moving_dispatch_shape in Hdisp.
                destruct (kit_dispatch_m_is_ptr lp _ _ _ _ _ _ _ _ Hdisp)
                  as (l & o & Hlm).
                pose proof (Htat2 _ _ Hlm) as [-> ->].
                destruct (value_gate_pres lp LO_mario bm NoA MWF
                            mario_actions_moving._t'45 moving_cases
                            moving_callee_ids
                            moving_tmp_ne moving_arms_tabled
                            mov_call_pres
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
                         Hcall2 mov_qsand_call_pres Htat1 HN1 HM1 HV1 HS1')
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
                    (mov_call_pres _ Hmem1) Htat0 HN HM HV HS)
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

End MovingSurface.
