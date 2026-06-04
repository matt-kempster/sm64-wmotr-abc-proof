(* ====================================================================== *)
(* ENGINE-V2 CONSUMER (Unwired STAGING).                                   *)
(*                                                                         *)
(* Instantiates the invariant-aware census engine                          *)
(* (ActionValueFrame.exec_funcall_reach_value_v2) over the linked          *)
(* program lp and exports the capstone-shaped per-funcall contract         *)
(*   reach_value_preserves_reached not_tainted bm (lp_ge lp) NoA MWF       *)
(*     reached_v2                                                          *)
(* for a CONCRETE reached set: the 15 censused mario.c bodies              *)
(* (CensusV2.censused_body) + the bridged update_mario_button_inputs +     *)
(* the named rest surface (exempt whitelist + the root's residual          *)
(* callees, each keyed by its lp symbol resolution).                       *)
(*                                                                         *)
(* WHAT IS PROVED HERE (no longer assumed):                                *)
(*  - leaf A (Hbody): the 15-body census dispatch (body_TI_C_dispatch);    *)
(*  - the store leaf (chk_assign): every censused store preserves          *)
(*    valid/action_sat/MWF given the per-cell stability premises;          *)
(*  - the call-marg leaf (chk_call_marg) and all TI-maintenance and        *)
(*    census-structure leaves (chk_ti_set/chk_ti_optc/chk_seq*/chk_if/     *)
(*    chk_loop/chk_sw) -- including the gate kill and dispatch kill;       *)
(*  - the umbi bridge: AGates.umbi_funcall_marg_preserves_lp lifts to      *)
(*    the engine's Hbridged (its footprint misses the action cell);        *)
(*  - the WRITER leaf is REFUTED, not assumed: no censused/bridged-umbi    *)
(*    body IS set_mario_action (record inequalities), so at this scope     *)
(*    the engine never owes a writer obligation (W := True).               *)
(*                                                                         *)
(* THE RESIDUAL SURFACE (the section hypotheses below) -- each NAMED,      *)
(* satisfiable, and per-cell/per-symbol dischargeable:                     *)
(*  - MWF projections (input/ctl A-clear) + per-cell stability             *)
(*    (window stores, the A-clear input store, whitelisted globals,        *)
(*    non-pointer SafeB stores, the umbi footprint, unchanged-on-bm,       *)
(*    externals) -- discharged when MWF is INSTANTIATED concretely;        *)
(*  - the chase closure premises (HactVint/HPgms/HchaseRoot/HchaseStep/    *)
(*    HSafeNotBm) -- the SafeB instantiation;                              *)
(*  - WL_exempt + Hrest_pres: per-symbol facts about what the named        *)
(*    callee symbols resolve to in lp (the handlers' preservation is the   *)
(*    REMAINING CRUX -- it is where the A-gating taint closure of          *)
(*    Taint.v/AGates.v gets consumed next);                                *)
(*  - Hcall_resolves: censused calls resolve into reached_v2 (the          *)
(*    census's callee idents are not yet tabled -- the mcallee census      *)
(*    extension discharges this);                                          *)
(*  - return-value and NoA-stability facts (Hret_call/ext, Hnoa_exec/      *)
(*    entry).                                                              *)
(*                                                                         *)
(* NOTHING on the capstone consumes this file yet. The wiring step:        *)
(* NoAImpliesNoFlyLinked instantiates its reached_fd := reached_v2 and     *)
(* its Hreach_val := reach_value_preserves_reached_v2, swapping the        *)
(* monolithic per-funcall residual for the surface above.                  *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia Classical.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking.
From SM64.Generated Require mario.
From SM64.Proofs Require Import SymbolicLinking Flying Taint
  ActionValueFrame RealFrameValue RealFrameLinked AGates.
From SM64.Proofs Require Import MarioModel.Unwired.CensusV2.

Import ListNotations.
Local Open Scope Z_scope.

Section V2Consumer.
  Variable lp : Clight.program.
  Hypothesis LO_mario : linkorder mario.prog lp.
  Variable bm : block.
  Variable SafeB : block -> Prop.
  Variable NoA MWF : mem -> Prop.

  (* ---------------- the concrete reach surface ---------------- *)

  (* a named symbol's lp resolution (zero-offset function pointer) *)
  Definition resolves_lp (fid : ident) (fd : Clight.fundef) : Prop :=
    exists b, Genv.find_symbol (lp_ge lp) fid = Some b /\
              Genv.find_funct (lp_ge lp) (Vptr b Ptrofs.zero) = Some fd.

  (* execute_mario_action's callees that are NOT censused bodies and NOT
     the bridged umbi: the 7 action dispatch handlers + interactions +
     special floors + the two sound/particle helpers not already on the
     exempt whitelist. Extracted from the generated AST of
     f_execute_mario_action (the only Scall callee idents in its body
     besides the censused 8 and play_sound). *)
  Definition root_residual_callees : list ident :=
    mario._mario_execute_stationary_action ::
    mario._mario_execute_moving_action ::
    mario._mario_execute_airborne_action ::
    mario._mario_execute_submerged_action ::
    mario._mario_execute_cutscene_action ::
    mario._mario_execute_automatic_action ::
    mario._mario_execute_object_action ::
    mario._mario_handle_special_floors ::
    mario._mario_process_interactions ::
    mario._spawn_wind_particles ::
    mario._play_infinite_stairs_music :: nil.

  (* the not-yet-walked reach surface, keyed per symbol *)
  Definition rest_fd (fd : Clight.fundef) : Prop :=
    exists fid,
      (mem_id fid exempt_callees = true \/
       mem_id fid root_residual_callees = true) /\
      resolves_lp fid fd.

  Definition bridged_fd (fd : Clight.fundef) : Prop :=
    fd = Internal mario.f_update_mario_button_inputs \/ rest_fd fd.

  (* the writer classification EXCLUDES the bridged surface: a rest-symbol
     resolution is covered by its whole-funcall residual regardless of
     what record it is, so the writer leaf only ever owes the pinned
     internals -- where it is refutable. *)
  Definition writer_fd (fd : Clight.fundef) : Prop :=
    fd = Internal mario.f_set_mario_action /\ ~ bridged_fd fd.

  Definition reached_v2 (fd : Clight.fundef) : Prop :=
    (exists f, fd = Internal f /\ censused_body f) \/ bridged_fd fd.

  (* ---------------- the residual surface ---------------- *)

  (* MWF projections: the run invariant contains the two A-clear cells *)
  Hypothesis Hmwf_inp : forall m, MWF m -> input_a_clear m bm.
  Hypothesis Hmwf_ctl : forall m, MWF m -> ctl_a_clear m bm.

  (* chk_ti_set's per-cell closure premises *)
  Hypothesis HactVint : forall mm, MWF mm -> forall av,
      Mem.load Mint32 mm bm 12 = Some av ->
      av = Vundef \/ exists vi, av = Vint vi.
  Hypothesis HPgms : forall mm, MWF mm ->
      exists gb, Genv.find_symbol (lp_ge lp) mario._gMarioState = Some gb /\
                 Mem.loadv Mptr mm (Vptr gb Ptrofs.zero)
                   = Some (Vptr bm Ptrofs.zero).
  Hypothesis HchaseRoot : forall fld delta mm b' o',
      mem_id fld chase_root_fields = true ->
      field_offset (prog_comp_env mario.prog) fld mario_state_members
        = Errors.OK (delta, Full) ->
      MWF mm ->
      Mem.loadv Mptr mm (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr delta)))
        = Some (Vptr b' o') ->
      SafeB b'.
  Hypothesis HchaseStep : forall mm b ofs b' o',
      MWF mm -> SafeB b ->
      Mem.loadv Mptr mm (Vptr b ofs) = Some (Vptr b' o') -> SafeB b'.
  Hypothesis HSafeNotBm : forall bsafe, SafeB bsafe -> bsafe <> bm.

  (* chk_assign's store-stability premises *)
  Hypothesis Hmwf_window : forall mm mm' ch (delta : Z) vv,
      MWF mm -> store_window_ok delta (size_chunk ch) = true ->
      Mem.store ch mm bm delta vv = Some mm' -> MWF mm'.
  Hypothesis Hmwf_input : forall mm mm' vv,
      MWF mm -> Int.and vv (Int.repr 2) = Int.zero ->
      Mem.store Mint16unsigned mm bm 2 (Vint vv) = Some mm' -> MWF mm'.
  Hypothesis Hmwf_glob : forall gid, mem_id gid stored_globals = true ->
      forall bg, Genv.find_symbol (lp_ge lp) gid = Some bg ->
        bg <> bm /\
        (forall mm mm' ch0 (d : Z) vv,
            MWF mm -> Mem.store ch0 mm bg d vv = Some mm' -> MWF mm').
  Hypothesis Hmwf_chase : forall mm ch bsafe (d : Z) vv mm',
      MWF mm -> SafeB bsafe ->
      (forall bb oo, vv <> Vptr bb oo) ->
      Mem.store ch mm bsafe d vv = Some mm' -> MWF mm'.

  (* umbi stability: MWF survives a change confined to the umbi footprint
     (m->input + framesSinceA/B) that re-establishes input_a_clear *)
  Hypothesis Hmwf_umbi : forall mm mm',
      MWF mm ->
      Mem.unchanged_on (fun b o => ~ umbi_footprint bm b o) mm mm' ->
      input_a_clear mm' bm -> MWF mm'.

  (* per-symbol: the whitelisted callee symbols resolve to marg-exempt
     definitions (their first param is not MarioState* ) *)
  Hypothesis WL_exempt : forall e le m fid fty vf fd,
      mem_id fid exempt_callees = true ->
      eval_expr (lp_ge lp) e le m (Evar fid fty) vf ->
      Genv.find_funct (lp_ge lp) vf = Some fd ->
      marg_exempt fd = true.

  (* per-symbol: the rest surface preserves the carried facts. THIS is the
     remaining crux at this scope: for the 7 dispatch handlers +
     interactions + special floors it is exactly where the A-gating taint
     closure (Taint.v + AGates.v kills) gets consumed; for the exempt
     whitelist it is per-symbol frame reasoning (vec3 family etc.). *)
  Hypothesis Hrest_pres : forall m fd vargs t m' vres,
      rest_fd fd ->
      (marg_exempt fd = false -> marg_ok bm vargs) ->
      eval_funcall function_entry2 (lp_ge lp) m fd vargs t m' vres ->
      NoA m -> MWF m -> Mem.valid_block m bm -> action_sat not_tainted m bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m'.

  (* censused calls resolve into the reach set. Dischargeable once the
     census tables class-M callee idents (the mcallee extension): class-M
     callees are linkorder-pinned mario.c internals (censused or umbi),
     class-E callees resolve into rest_fd by definition. *)
  Hypothesis Hcall_resolves : forall bc e le m optid a al vf fd,
      TI_of not_tainted bm SafeB bc e le ->
      chk bc (Scall optid a al) = true ->
      eval_expr (lp_ge lp) e le m a vf ->
      Genv.find_funct (lp_ge lp) vf = Some fd ->
      reached_v2 fd.

  (* return values never alias Mario's block *)
  Hypothesis Hret_call : forall fd m0 vargs0 t0 m0' vres0,
      reached_v2 fd ->
      eval_funcall function_entry2 (lp_ge lp) m0 fd vargs0 t0 m0' vres0 ->
      forall b o, vres0 = Vptr b o -> b <> bm.
  Hypothesis Hret_ext : forall ef vargs0 m0 t0 vres0 m0',
      external_call ef (lp_ge lp) vargs0 m0 t0 vres0 m0' ->
      forall b o, vres0 = Vptr b o -> b <> bm.

  (* externals: the action cell + MWF survive external calls; MWF only
     reads bm-pinned cells (unchanged-on-bm stability) *)
  Hypothesis Hext_action :
    FieldNonInterference.reach_ext_preserves (action_cell bm) (lp_ge lp).
  Hypothesis Hmwf_ext : forall ef vargs m t vres m',
      external_call ef (lp_ge lp) vargs m t vres m' ->
      Mem.valid_block m bm -> MWF m -> MWF m'.
  Hypothesis Hmwf_unch : forall m m',
      Mem.unchanged_on (fun b (_ : Z) => b = bm) m m' ->
      Mem.valid_block m bm -> MWF m -> MWF m'.

  (* NoA stability (the capstone already carries the equivalent) *)
  Hypothesis Hnoa_exec : forall e le m s t le' m' out,
      exec_stmt function_entry2 (lp_ge lp) e le m s t le' m' out ->
      NoA m -> NoA m'.
  Hypothesis Hnoa_entry : forall f vargs m e le m1,
      function_entry2 (lp_ge lp) f vargs m e le m1 -> NoA m -> NoA m1.

  (* ---------------- the writer refutation bricks ---------------- *)

  (* every censused body has exactly 1 parameter; set_mario_action has 3 *)
  Lemma censused_body_not_writer :
    forall f, censused_body f -> f <> mario.f_set_mario_action.
  Proof.
    intros f HC E. subst f.
    destruct HC as
      [E | [E | [E | [E | [E | [E | [E | [E | [E | [E | [E | [E | [E | [E | E]]]]]]]]]]]]]];
      apply (f_equal (fun g => List.length (fn_params g))) in E;
      vm_compute in E; discriminate E.
  Qed.

  Lemma umbi_not_writer :
    mario.f_update_mario_button_inputs <> mario.f_set_mario_action.
  Proof.
    intro E.
    apply (f_equal (fun g => List.length (fn_params g))) in E.
    vm_compute in E. discriminate E.
  Qed.

  (* ---------------- THE EXPORT ---------------- *)

  Theorem reach_value_preserves_reached_v2 :
    reach_value_preserves_reached not_tainted bm (lp_ge lp) NoA MWF reached_v2.
  Proof.
    assert (HV2 : reach_value_preserves_v2 not_tainted bm (lp_ge lp) NoA MWF
                    writer_fd (fun _ => True) reached_v2).
    { apply (exec_funcall_reach_value_v2 not_tainted bm (lp_ge lp) NoA MWF
               writer_fd (fun _ => True) bridged_fd reached_v2
               body_census (TI_of not_tainted bm SafeB)
               (fun bc s => chk bc s = true)).
      - (* Hbody: censused dispatch *)
        intros f vargs0 m0 e le m1 Hr _ Hentry _ Hnb Hmarg0.
        assert (HC : censused_body f).
        { destruct Hr as [(f0 & Ef & HC0) | Hb].
          - injection Ef as Ef. subst f0. exact HC0.
          - exfalso. exact (Hnb Hb). }
        exact (body_TI_C_dispatch not_tainted bm SafeB (lp_ge lp)
                 f vargs0 m0 e le m1 HC Hentry Hmarg0).
      - (* Hbridged: umbi (proved) / rest (residual) *)
        intros f vargs0 m0 t0 m0' vres0 _ Hb Hmargc Hevf Hno0 Hmwf0 Hv0 Hsat0.
        destruct Hb as [Eumbi | Hrest].
        + injection Eumbi as Eumbi. subst f.
          assert (Hmarg0 : marg_ok bm vargs0) by (apply Hmargc; reflexivity).
          destruct (umbi_funcall_marg_preserves_lp lp LO_mario
                      m0 vargs0 t0 m0' vres0 bm Hmarg0
                      (Hmwf_ctl _ Hmwf0) (Hmwf_inp _ Hmwf0) Hevf)
            as (Hinp' & Hunch).
          assert (Hac : Mem.unchanged_on (action_cell bm) m0 m0').
          { eapply Mem.unchanged_on_implies; [ exact Hunch | ].
            intros b ofs Hcell _. destruct Hcell as [-> Hr'].
            intros (_ & Hor). cbn [size_chunk] in Hr'. lia. }
          split; [ | split ].
          * eapply Mem.valid_block_unchanged_on; [ exact Hac | exact Hv0 ].
          * eapply action_sat_unchanged_on;
              [ exact Hac | exact Hv0 | exact Hsat0 ].
          * eapply Hmwf_umbi; [ exact Hmwf0 | exact Hunch | exact Hinp' ].
        + exact (Hrest_pres m0 (Internal f) vargs0 t0 m0' vres0
                   Hrest Hmargc Hevf Hno0 Hmwf0 Hv0 Hsat0).
      - (* Hassign: the censused store leaf *)
        intros bc e le m0 a1 a2 loc ofs bf v2 v m0'
               Hlv Hev2 Hcast Has HTI HC Hmwf0 Hv0 Hsat0.
        exact (chk_assign lp LO_mario not_tainted MWF bm SafeB bc e le m0
                 a1 a2 loc ofs bf v2 v m0'
                 Hmwf_window Hmwf_input Hmwf_glob HSafeNotBm Hmwf_chase
                 Hlv Hev2 Hcast Has HTI HC Hmwf0 Hv0 Hsat0).
      - (* Hcallmarg *)
        intros bc e le m0 optid a al tyargs vargs0 vf fd0
               HTI HC Hevf Hff Hnex Hargs.
        exact (chk_call_marg lp WL_exempt not_tainted bm SafeB bc e le m0
                 optid a al tyargs vargs0 vf fd0 HTI HC Hevf Hff Hnex Hargs).
      - (* Hexempt: censused/umbi are non-exempt (compute); rest is the
           residual *)
        intros f vargs0 m0 t0 m0' vres0 Hr Hex Hevf Hno0 Hmwf0 Hv0 Hsat0.
        destruct Hr as [(f0 & Ef & HC0) | [Eumbi | Hrest]].
        + exfalso. injection Ef as Ef. subst f0.
          rewrite (censused_body_nonexempt _ HC0) in Hex. discriminate Hex.
        + exfalso. injection Eumbi as Eumbi. subst f.
          vm_compute in Hex. discriminate Hex.
        + apply (Hrest_pres m0 (Internal f) vargs0 t0 m0' vres0
                   Hrest); try assumption.
          intro HF. rewrite Hex in HF. discriminate HF.
      - (* HTI_set *)
        intros bc e le m0 id a v Hmwf0 Hsat0 Hev0 HTI HC.
        exact (chk_ti_set lp LO_mario not_tainted MWF bm SafeB bc e le m0
                 id a v HactVint HPgms HchaseRoot HchaseStep
                 Hmwf0 (Hmwf_inp _ Hmwf0) Hsat0 Hev0 HTI HC).
      - (* HTI_optc *)
        intros bc e optid a al v le HC HTI _.
        exact (chk_ti_optc not_tainted bm SafeB bc e optid a al v le HC HTI).
      - (* HTI_optb: censused bodies have no builtins *)
        intros bc e optid ef tyargs al v le HC _ _.
        cbn in HC. discriminate HC.
      - (* Hret_call *)
        exact Hret_call.
      - (* Hret_builtin *)
        exact Hret_ext.
      - (* Hcall_reached *)
        intros bc e le m0 optid a al vf fd0 HTI HC Hevf Hff.
        exact (Hcall_resolves bc e le m0 optid a al vf fd0 HTI HC Hevf Hff).
      - (* Hcallwriter: W := True *)
        intros. exact I.
      - (* Hw: REFUTED -- the pinned internals are not the writer record *)
        intros m0 fd0 vargs0 t0 m0' vres0 Hr _ _ _ _ Hwr _ _.
        exfalso. destruct Hwr as [Efd Hnb].
        destruct Hr as [(f0 & Ef & HC0) | Hb]; [ | exact (Hnb Hb) ].
        rewrite Efd in Ef. injection Ef as Ef.
        exact (censused_body_not_writer f0 HC0 (eq_sym Ef)).
      - (* reach_ext_preserves (action_cell bm) *)
        exact Hext_action.
      - (* Hmwf_ext *)
        exact Hmwf_ext.
      - (* Hmwf_unch *)
        exact Hmwf_unch.
      - (* Hnoaexec *)
        exact Hnoa_exec.
      - (* Hnoaentry *)
        exact Hnoa_entry.
      - (* HCseq1 *)
        intros bc s1 s2 HC. exact (chk_seq1 bc s1 s2 HC).
      - (* HCseq2 *)
        intros bc e le m0 s1 s2 t1 le1 m1 HC Hex1.
        exact (chk_seq2 lp bc e le m0 s1 s2 t1 le1 m1 HC Hex1).
      - (* HCif: the gate kill *)
        intros bc e le m0 a s1 s2 v1 b HC _ _ HTI Hev0 Hbv.
        exact (chk_if lp not_tainted bm SafeB bc e le m0 a s1 s2 v1 b
                 HC HTI Hev0 Hbv).
      - (* HCloop *)
        exact chk_loop.
      - (* HCsw: the dispatch kill *)
        intros bc e le m0 a ls v n HC _ _ HTI Hev0 Hsa.
        exact (chk_sw lp bm SafeB bc e le m0 a ls v n HC HTI Hev0 Hsa). }
    intros m fd vargs t m' vres Hrf HnoA HMWF Hmarg Hev Hv Hsat.
    exact (HV2 m fd vargs t m' vres Hrf HnoA HMWF Hmarg (fun _ => I)
             Hev Hv Hsat).
  Qed.

End V2Consumer.
