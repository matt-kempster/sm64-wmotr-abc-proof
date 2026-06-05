(* ====================================================================== *)
(* THE CUTSCENE SURFACE: Hpres_cut DISCHARGED DOWN TO ITS LEAF CALLEES    *)
(* (SPINE: consumed by the MWF-grounded capstone).                        *)
(*                                                                        *)
(* f_mario_execute_cutscene_action = check_for_instant_quicksand +        *)
(* early return; the 50-arm action dispatch; the particleFlags epilogue   *)
(* (if (!cancel && (m->input & 0x200)) m->particleFlags |= 1<<7 -- a      *)
(* window-checked store through Mario's block); return cancel.            *)
(*                                                                        *)
(* The walk instantiates DispatchKit: the generic value-gate kill +       *)
(* dispatch walk + epilogue walk, against vm_compute censuses over the    *)
(* PROJECTED case table and epilogue.  The residual that remains is ONE   *)
(* census-keyed hypothesis over the 51 concrete callee ids.               *)
(* ====================================================================== *)

From Coq Require Import ZArith List.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking.
From SM64.Generated Require mario mario_actions_airborne mario_actions_cutscene.
From SM64.Proofs Require Import SymbolicLinking Flying Taint
  ActionValueFrame RealFrameValue RealFrameLinked AGates.
From SM64.Proofs Require Import CensusV2 EngineV2Consumer RestSurface
  AirborneSurface DispatchKit.

Import ListNotations.

(* ====================================================================== *)
(* The leaf-callee census (top-level: no lp).                             *)
(* ====================================================================== *)

(* the prologue helper + the 50 act handlers of the dispatch table, in
   table order; checked complete against the PROJECTED table below. *)
Definition cutscene_callee_ids : list ident :=
  mario_actions_cutscene._check_for_instant_quicksand ::
  mario_actions_cutscene._act_disappeared ::
  mario_actions_cutscene._act_intro_cutscene ::
  mario_actions_cutscene._act_star_dance ::
  mario_actions_cutscene._act_star_dance_water ::
  mario_actions_cutscene._act_fall_after_star_grab ::
  mario_actions_cutscene._act_reading_automatic_dialog ::
  mario_actions_cutscene._act_reading_npc_dialog ::
  mario_actions_cutscene._act_debug_free_move ::
  mario_actions_cutscene._act_reading_sign ::
  mario_actions_cutscene._act_jumbo_star_cutscene ::
  mario_actions_cutscene._act_waiting_for_dialog ::
  mario_actions_cutscene._act_standing_death ::
  mario_actions_cutscene._act_quicksand_death ::
  mario_actions_cutscene._act_electrocution ::
  mario_actions_cutscene._act_suffocation ::
  mario_actions_cutscene._act_death_on_stomach ::
  mario_actions_cutscene._act_death_on_back ::
  mario_actions_cutscene._act_eaten_by_bubba ::
  mario_actions_cutscene._act_end_peach_cutscene ::
  mario_actions_cutscene._act_credits_cutscene ::
  mario_actions_cutscene._act_end_waving_cutscene ::
  mario_actions_cutscene._act_going_through_door ::
  mario_actions_cutscene._act_warp_door_spawn ::
  mario_actions_cutscene._act_emerge_from_pipe ::
  mario_actions_cutscene._act_spawn_spin_airborne ::
  mario_actions_cutscene._act_spawn_spin_landing ::
  mario_actions_cutscene._act_exit_airborne ::
  mario_actions_cutscene._act_exit_land_save_dialog ::
  mario_actions_cutscene._act_death_exit ::
  mario_actions_cutscene._act_unused_death_exit ::
  mario_actions_cutscene._act_falling_death_exit ::
  mario_actions_cutscene._act_special_exit_airborne ::
  mario_actions_cutscene._act_special_death_exit ::
  mario_actions_cutscene._act_falling_exit_airborne ::
  mario_actions_cutscene._act_unlocking_key_door ::
  mario_actions_cutscene._act_unlocking_star_door ::
  mario_actions_cutscene._act_entering_star_door ::
  mario_actions_cutscene._act_spawn_no_spin_airborne ::
  mario_actions_cutscene._act_spawn_no_spin_landing ::
  mario_actions_cutscene._act_bbh_enter_jump ::
  mario_actions_cutscene._act_bbh_enter_spin ::
  mario_actions_cutscene._act_teleport_fade_out ::
  mario_actions_cutscene._act_teleport_fade_in ::
  mario_actions_cutscene._act_shocked ::
  mario_actions_cutscene._act_squished ::
  mario_actions_cutscene._act_head_stuck_in_ground ::
  mario_actions_cutscene._act_butt_stuck_in_ground ::
  mario_actions_cutscene._act_feet_stuck_in_ground ::
  mario_actions_cutscene._act_putting_on_cap :: nil.

(* ---- the projections from the generated AST: the body is
   Sseq(prologue, Sseq(DISPATCH, Sseq(EPILOGUE, return))). ---- *)
Definition second_seq (s : statement) : statement :=
  match s with Ssequence _ (Ssequence d _) => d | _ => Sskip end.

Definition cutscene_dispatch_stmt : statement :=
  second_seq (fn_body mario_actions_cutscene.f_mario_execute_cutscene_action).

Definition cutscene_cases : labeled_statements :=
  match cutscene_dispatch_stmt with
  | Ssequence _ (Sswitch _ ls) => ls
  | _ => LSnil
  end.

Definition cutscene_epi : statement :=
  third_seq (fn_body mario_actions_cutscene.f_mario_execute_cutscene_action).

(* ---- the shape pins (vm_compute reflexivity over the real AST). ---- *)

Example cutscene_dispatch_shape :
  cutscene_dispatch_stmt =
  value_gate_stmt mario_actions_cutscene._t'55 cutscene_cases.
Proof. vm_compute. reflexivity. Qed.

Example cutscene_body_shape :
  fn_body mario_actions_cutscene.f_mario_execute_cutscene_action =
  Ssequence
    (Ssequence
       (Scall (Some mario_actions_airborne._t'1)
          (Evar mario_actions_cutscene._check_for_instant_quicksand tyAct)
          (Etempvar mario_actions_airborne._m tyMSp :: nil))
       (Sifthenelse (Etempvar mario_actions_airborne._t'1 tint)
          (Sreturn (Some (Econst_int (Int.repr 1) tint)))
          Sskip))
    (Ssequence
       cutscene_dispatch_stmt
       (Ssequence
          cutscene_epi
          (Sreturn (Some (Etempvar mario_actions_airborne._cancel tint))))).
Proof. vm_compute. reflexivity. Qed.

(* the selector temp is not the Mario param temp *)
Example cutscene_tmp_ne :
  Pos.eqb mario_actions_cutscene._t'55 mario_actions_airborne._m = false.
Proof. vm_compute. reflexivity. Qed.

(* ---- the censuses. ---- *)

(* every suffix a non-T selector can land on resolves (through the
   fall-through skips) to nothing or to a censused uniform arm whose
   call temp is not _m. *)
Example cutscene_arms_tabled :
  nonT_suffixes_ok (suffix_tabled_in cutscene_callee_ids) cutscene_cases
  = true.
Proof. vm_compute. reflexivity. Qed.

(* POSITIVE CONTROL: the census is not vacuous -- an empty table fails. *)
Example cutscene_arms_census_not_vacuous :
  nonT_suffixes_ok
    (fun sl => match drop_skips sl with
               | LSnil => true
               | LScons _ _ _ => false
               end)
    cutscene_cases = false.
Proof. vm_compute. reflexivity. Qed.

(* COMPLETENESS PIN: the prologue helper and every callee the PROJECTED
   table can invoke is on the hand-spelled census list.  (The table has
   duplicate callees -- several labels share an arm body -- so coverage,
   not list equality, is the right pin; per-arm coverage is also enforced
   independently by cutscene_arms_tabled.) *)
Example cutscene_callee_ids_complete :
  forallb (fun fid => mem_id fid cutscene_callee_ids)
    (mario_actions_cutscene._check_for_instant_quicksand
       :: arm_callees cutscene_cases) = true.
Proof. vm_compute. reflexivity. Qed.

(* every censused callee is defined INTERNAL by the cutscene TU itself
   (so LO_cut pins its lp resolution to that real body). *)
Example cutscene_callees_internal :
  forallb (internal_in (prog_defmap mario_actions_cutscene.prog))
    cutscene_callee_ids = true.
Proof. vm_compute. reflexivity. Qed.

(* the projected epilogue passes the kit's recognizer: temp sets, ifs,
   and a window-checked m->particleFlags store only. *)
Example cutscene_epi_ok : epi_chk cutscene_epi = true.
Proof. vm_compute. reflexivity. Qed.

(* ====================================================================== *)
(* The walk.                                                              *)
(* ====================================================================== *)

Section CutsceneSurface.
  Variable lp : Clight.program.
  Hypothesis LO_mario : linkorder mario.prog lp.
  Hypothesis LO_cut : linkorder mario_actions_cutscene.prog lp.

  Variable bm : block.
  Variable NoA MWF : mem -> Prop.

  Hypothesis HNoA_of_MWF : forall m, MWF m -> NoA m.
  Hypothesis HMWF_window : forall mm mm' ch (delta : Z) vv,
      MWF mm -> store_window_ok delta (size_chunk ch) = true ->
      Mem.store ch mm bm delta vv = Some mm' -> MWF mm'.

  (* THE RESIDUAL: per-leaf-callee preservation, keyed by the census. *)
  Hypothesis Hpres_callees : forall fid f,
      mem_id fid cutscene_callee_ids = true ->
      (prog_defmap mario_actions_cutscene.prog) ! fid
        = Some (Gfun (Internal f)) ->
      body_pres lp NoA MWF bm f.

  Lemma cut_call_pres :
    forall fid, mem_id fid cutscene_callee_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    exact (call_pres_of_census lp bm NoA MWF HNoA_of_MWF
             mario_actions_cutscene.prog cutscene_callee_ids LO_cut
             cutscene_callees_internal Hpres_callees).
  Qed.

  (* ================================================================== *)
  (* THE PAYOFF: Hpres_cut itself, PROVED from the per-leaf residuals.  *)
  (* ================================================================== *)
  Theorem cutscene_pres :
    body_pres lp NoA MWF bm
      mario_actions_cutscene.f_mario_execute_cutscene_action.
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
        change (fn_vars mario_actions_cutscene.f_mario_execute_cutscene_action)
          with (@nil (ident * type)) in Ha;
        inv Ha
    end.
    match goal with
    | Hb : bind_parameter_temps _ _ _ = Some _ |- _ => rename Hb into Hbind
    end.
    change (fn_params mario_actions_cutscene.f_mario_execute_cutscene_action)
      with ((mario_actions_airborne._m, tyMSp) :: nil) in Hbind.
    cbn [bind_parameter_temps] in Hbind.
    destruct vargs as [| v0 vrest]; [ discriminate Hbind | ].
    destruct vrest; [ | discriminate Hbind ].
    injection Hbind as <-.
    change (blocks_of_env (lp_ge lp) empty_env)
      with (@nil (block * Z * Z)) in Hfree.
    cbn [Mem.free_list] in Hfree. injection Hfree as <-.
    rewrite cutscene_body_shape in Hbody.
    set (base := create_undef_temps
                   (fn_temps mario_actions_cutscene.f_mario_execute_cutscene_action))
      in *.
    (* the param temp's exact provenance (if it is a pointer, it is Mario) *)
    assert (Htat0 : forall b o,
               (PTree.set mario_actions_airborne._m v0 base)
                 ! mario_actions_airborne._m = Some (Vptr b o) ->
               b = bm /\ o = Ptrofs.zero).
    { intros b o Hg. rewrite PTree.gss in Hg. injection Hg as ->.
      cbn in Hmarg. exact Hmarg. }
    assert (Hmem1 : mem_id mario_actions_cutscene._check_for_instant_quicksand
                      cutscene_callee_ids = true)
      by (vm_compute; reflexivity).
    inv Hbody.
    - (* prologue normal: no early cancel; the frame continues *)
      match goal with
      | H1 : exec_stmt _ _ _ _ _ (Ssequence (Scall _ _ _) (Sifthenelse _ _ _))
               _ _ _ Out_normal |- _ => rename H1 into HS1
      end.
      match goal with
      | H2 : exec_stmt _ _ _ _ _ (Ssequence cutscene_dispatch_stmt _)
               _ _ _ _ |- _ => rename H2 into Hrest2
      end.
      inv HS1.
      + (* the quicksand-check call, then the (not-taken) if *)
        match goal with
        | Hc : exec_stmt _ _ _ _ _ (Scall (Some _) _ _) _ _ _ _ |- _ =>
            rename Hc into Hcall1
        end.
        match goal with
        | Hi : exec_stmt _ _ _ _ _ (Sifthenelse _ _ _) _ _ _ _ |- _ =>
            rename Hi into Hif
        end.
        destruct (kit_scall_pres lp bm NoA MWF _ _ _ _ _ _ _ _ _ _ Hcall1
                    (cut_call_pres _ Hmem1) Htat0 HN HM HV HS)
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
        (* dispatch, then epilogue + return *)
        inv Hrest2.
        * match goal with
          | Hd : exec_stmt _ _ _ _ _ cutscene_dispatch_stmt _ _ _ _ |- _ =>
              rename Hd into Hdisp
          end.
          match goal with
          | Hr : exec_stmt _ _ _ _ _ (Ssequence cutscene_epi _) _ _ _ _ |- _ =>
              rename Hr into Hrest3
          end.
          rewrite cutscene_dispatch_shape in Hdisp.
          destruct (kit_dispatch_m_is_ptr lp _ _ _ _ _ _ _ _ Hdisp)
            as (l & o & Hlm).
          pose proof (Htat1 _ _ Hlm) as [-> ->].
          destruct (value_gate_pres lp LO_mario bm NoA MWF
                      mario_actions_cutscene._t'55 cutscene_cases
                      cutscene_callee_ids
                      cutscene_tmp_ne cutscene_arms_tabled cut_call_pres
                      _ _ _ _ _ _ Hlm HN1 HM1 HV1 HS1' Hdisp)
            as (HV2 & HS2 & HM2 & HN2 & Htat2 & _).
          inv Hrest3.
          -- (* the epilogue, then the return *)
             match goal with
             | He : exec_stmt _ _ _ _ _ cutscene_epi _ _ _ _ |- _ =>
                 rename He into Hepi
             end.
             match goal with
             | Hr : exec_stmt _ _ _ _ _ (Sreturn _) _ _ _ _ |- _ =>
                 rename Hr into Hret
             end.
             destruct (epi_pres lp LO_mario bm MWF HMWF_window
                         cutscene_epi _ _ _ _ _ _ _
                         cutscene_epi_ok Htat2 Hepi HM2 HV2 HS2)
               as (HV3 & HS3 & HM3 & _ & _).
             inv Hret.
             repeat split; assumption.
          -- (* epilogue ended non-normally: refuted by the epi walk *)
             exfalso.
             match goal with
             | He : exec_stmt _ _ _ _ _ cutscene_epi _ _ _ ?oo,
               Hn : ?oo <> Out_normal |- _ => rename He into Hepi
             end.
             destruct (epi_pres lp LO_mario bm MWF HMWF_window
                         cutscene_epi _ _ _ _ _ _ _
                         cutscene_epi_ok Htat2 Hepi HM2 HV2 HS2)
               as (_ & _ & _ & _ & Hnorm).
             congruence.
        * (* dispatch ended non-normally: refuted by the dispatch walk *)
          exfalso.
          match goal with
          | Hd : exec_stmt _ _ _ _ _ cutscene_dispatch_stmt _ _ _ ?oo,
            Hn : ?oo <> Out_normal |- _ => rename Hd into Hdisp
          end.
          rewrite cutscene_dispatch_shape in Hdisp.
          destruct (kit_dispatch_m_is_ptr lp _ _ _ _ _ _ _ _ Hdisp)
            as (l & o & Hlm).
          pose proof (Htat1 _ _ Hlm) as [-> ->].
          destruct (value_gate_pres lp LO_mario bm NoA MWF
                      mario_actions_cutscene._t'55 cutscene_cases
                      cutscene_callee_ids
                      cutscene_tmp_ne cutscene_arms_tabled cut_call_pres
                      _ _ _ _ _ _ Hlm HN1 HM1 HV1 HS1' Hdisp)
            as (_ & _ & _ & _ & _ & Hnorm).
          congruence.
      + (* the check call ended non-normally: Scall is Out_normal *)
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
                    (cut_call_pres _ Hmem1) Htat0 HN HM HV HS)
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

End CutsceneSurface.
