(** A source-level transport cut, before any emulator-specific behavior.
    The current area's concrete index supplies the real unload-scan argument.
    This is a cut of one completed execution, not an assertion of a reachable
    live/free partition or an allocation-history invariant. *)
From Coq Require Import List ZArith.
From compcert Require Import AST Clight ClightBigstep Clightdefs Cop Ctypes
  Events Globalenvs Integers Maps Memory Values.
From LessThanOneAPress.Proofs Require Import GameTypes ObjectContactNecessity
  ObjectContactReadback InkBackwardExecution InkCopyCaller SelectedClightTarget
  EyerokRank15LiveMovement TeleporterEarlierAreaChange TeleporterObjectLifetime
  TeleporterUnloadTraversal TeleporterWrongWarpBoundary TeleporterWholeScan
  TeleporterMixedTraversal.
Import ListNotations.
Local Open Scope Z_scope.

Lemma ttc_current_area_read : forall (ge : genv) e le memory cell ab ao answer,
  e ! TEA._gCurrentArea = None ->
  Genv.find_symbol ge TEA._gCurrentArea = Some cell ->
  Mem.load Mptr memory cell 0 = Some (Vptr ab ao) ->
  eval_expr ge e le memory tea_current_read answer -> answer = Vptr ab ao.
Proof.
  intros ge e le memory cell ab ao answer Hlocal Hsymbol Hload Hread.
  inversion Hread; subst.
  match goal with Hl : eval_lvalue _ _ _ _ _ _ _ _ |- _ =>
    inversion Hl; subst; try congruence end.
  match goal with Hfind : Genv.find_symbol _ _ = Some ?found |- _ =>
    assert (found = cell) by congruence; subst found end.
  match goal with Hd : deref_loc _ _ _ _ _ _ |- _ =>
    inversion Hd; subst; try discriminate end.
  match goal with Hmode : access_mode _ = By_value _ |- _ =>
    cbn [access_mode] in Hmode; inversion Hmode; subst end.
  match goal with Hr : Mem.loadv _ _ _ = Some answer |- _ =>
    change (Mem.load Mptr memory cell 0 = Some answer) in Hr; congruence end.
Qed.

Lemma ttc_selected_area_index_layout : forall version,
  ibcc_field_ok (Clight.globalenv (selected_clight_target version))
    TEA._Area TEA._index 0 = true.
Proof.
  intro version.
  change (ibcc_field_ok (prog_comp_env (selected_clight_target version))
    TEA._Area TEA._index 0 = true).
  rewrite <- rank15_selected_header_environment_exact.
  destruct version; vm_compute; reflexivity.
Qed.

Lemma ttc_scan_area_index_read : forall version e le memory ab ao area answer,
  le ! TEA._t'5 = Some (Vptr ab ao) ->
  Mem.load Mint8signed memory ab (Ptrofs.unsigned ao) = Some (Vint area) ->
  eval_expr (Clight.globalenv (selected_clight_target version)) e le memory
    tea_scan_index answer -> answer = Vint area.
Proof.
  intros version e le memory ab ao area answer Htemp Hload Hread.
  unfold tea_scan_index in Hread. inversion Hread; subst.
  match goal with Hl : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ =>
    destruct (ibcc_field_location (Clight.globalenv (selected_clight_target version))
      e le memory (Ederef (Etempvar TEA._t'5 (tptr (Tstruct TEA._Area noattr)))
        (Tstruct TEA._Area noattr)) TEA._Area TEA._index tschar ab ao 0
      _ _ _ eq_refl ltac:(intros; eapply ibcc_deref_struct; eauto)
      (ttc_selected_area_index_layout version) Hl) as (Hblock & Hoffset & Hbit);
      subst end.
  rewrite Ptrofs.add_zero in *.
  match goal with Hd : deref_loc _ _ _ _ _ _ |- _ =>
    inversion Hd; subst; try discriminate end.
  match goal with Hmode : access_mode _ = By_value _ |- _ =>
    cbn [access_mode] in Hmode; inversion Hmode; subst end.
  match goal with Hr : Mem.loadv _ _ _ = Some answer |- _ =>
    change (Mem.load Mint8signed memory ab (Ptrofs.unsigned ao) = Some answer)
      in Hr; congruence end.
Qed.

Lemma ttc_nonnull_area_cannot_skip : forall ge e le memory ab ao,
  le ! TEA._t'1 = Some (Vptr ab ao) ->
  ~ ocn_test_value ge e le memory tea_unload_guard false.
Proof.
  intros ge e le memory ab ao Htemp [answer [Hread Hbool]].
  unfold tea_unload_guard in Hread. inversion Hread; subst.
  - match goal with Hr : eval_expr _ _ _ _ (Etempvar TEA._t'1 _) ?v |- _ =>
      assert (v = Vptr ab ao) by (eapply ocn_temp_value; eauto); subst v end.
    match goal with Hr : eval_expr _ _ _ _ (Ecast (Econst_int _ _) _) ?v |- _ =>
      assert (v = Vint Int.zero) by (eapply tww_null_cast_has_null_value; eauto);
      subst v end.
    match goal with Hsem : sem_binary_operation _ _ _ _ _ _ _ = Some answer |- _ =>
      cbn [sem_binary_operation sem_cmp classify_cmp] in Hsem;
      change (option_map Val.of_bool
        (Val.cmpu_bool (Mem.valid_pointer memory) Cne (Vptr ab ao)
          (Vint Int.zero)) = Some answer) in Hsem;
      cbn [Val.cmpu_bool] in Hsem;
      repeat match type of Hsem with context [if ?test then _ else _] =>
        destruct test eqn:?; cbn in Hsem; try discriminate end;
      inversion Hsem; subst; discriminate end.
  - match goal with Hl : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ =>
      inversion Hl end.
Qed.

Definition TTCUnloadAreaHasConcreteScan : Prop :=
  forall version before tr after result cell ab ao area,
  Genv.find_symbol (Clight.globalenv (selected_clight_target version))
    TEA._gCurrentArea = Some cell ->
  Mem.load Mptr before cell 0 = Some (Vptr ab ao) ->
  Mem.load Mint8signed before ab (Ptrofs.unsigned ao) = Some (Vint area) ->
  ClightBigstep.Clight2.eval_funcall
    (Clight.globalenv (selected_clight_target version)) before
    (Internal (tea_unload_function version)) [] tr after result ->
  exists scan_trace scanned scan_result suffix scan_le final out,
    tr = scan_trace ++ suffix /\
    ClightBigstep.Clight2.eval_funcall
      (Clight.globalenv (selected_clight_target version)) before
      (Internal (tol_scan_function version)) [Vint Int.zero; Vint area]
      scan_trace scanned scan_result /\
    ocn_exec (Clight.globalenv (selected_clight_target version)) empty_env
      scan_le scanned (tea_after_scan version) suffix final after out.

Theorem ttc_complete_unload_has_concrete_scan : TTCUnloadAreaHasConcreteScan.
Proof.
  intros version before tr after result cell ab ao area Hsymbol Hcurrent Harea Hcall.
  destruct (tea_complete_unload_call_has_body _ _ _ _ _ Hcall)
    as (entry & last & out & Hbody).
  destruct (tea_actual_unload_area_chronology _ _ _ _ _ _ _ _ _ Hbody)
    as (current & Hread & Hcases).
  assert (current = Vptr ab ao) as Ecurrent.
  { eapply ttc_current_area_read; eauto. apply PTree.gempty. }
  subst current. destruct Hcases as [(Hskip & Hsame)|(_ & again & index & scan_le & scanned
    & scan_trace & suffix & Hag & Hindex & Htrace & Hscan & Htail)].
  - exfalso. eapply ttc_nonnull_area_cannot_skip; [apply PTree.gss|exact Hskip].
  - assert (again = Vptr ab ao) as Eagain.
    { eapply ttc_current_area_read; eauto. apply PTree.gempty. }
    subst again.
    assert (index = Vint area) as Eindex.
    { eapply ttc_scan_area_index_read; eauto. apply PTree.gss. }
    subst index.
    destruct (tea_reached_scan_uses_real_body version empty_env
      (PTree.set TEA._t'6 (Vint area) (PTree.set TEA._t'5 (Vptr ab ao)
        (PTree.set TEA._t'1 (Vptr ab ao) entry))) before area
      scan_trace scan_le scanned Out_normal (PTree.gempty _ _)
      (PTree.gss _ _ _) Hscan) as (scan_result & Hreal).
    exists scan_trace, scanned, scan_result, suffix, scan_le, last, out.
    repeat split; assumption.
Qed.

(** The full outer execution and third inner pass belong to this same unload
    call. This removes a separately assumed reached list-2 scan. *)
Definition TTCUnloadAreaHasBobombPass : Prop :=
  forall version before tr after result cell ab ao area,
  Genv.find_symbol (Clight.globalenv (selected_clight_target version))
    TEA._gCurrentArea = Some cell ->
  Mem.load Mptr before cell 0 = Some (Vptr ab ao) ->
  Mem.load Mint8signed before ab (Ptrofs.unsigned ao) = Some (Vint area) ->
  ClightBigstep.Clight2.eval_funcall
    (Clight.globalenv (selected_clight_target version)) before
    (Internal (tea_unload_function version)) [] tr after result ->
  exists scan_trace scanned scan_result suffix scan_le final out passes pass,
    tr = scan_trace ++ suffix /\
    TWSCallPasses version before (Vint Int.zero) area scan_trace scanned scan_result passes /\
    nth_error passes 2 = Some pass /\
    TWSActualPass version empty_env area pass /\
    (tws_inner_entry pass) ! TUL._i = Some (Vint (Int.repr 2)) /\
    (tws_inner_entry pass) ! TUL._areaIndex = Some (Vint area) /\
    ocn_exec (Clight.globalenv (selected_clight_target version)) empty_env
      scan_le scanned (tea_after_scan version) suffix final after out.
Theorem ttc_complete_unload_has_bobomb_pass : TTCUnloadAreaHasBobombPass.
Proof.
  intros version before tr after result cell ab ao area Hsymbol Hcurrent Harea Hcall.
  destruct (ttc_complete_unload_has_concrete_scan _ _ _ _ _ _ _ _ _
    Hsymbol Hcurrent Harea Hcall)
    as (scan_trace & scanned & scan_result & suffix & scan_le & final & out &
      Htrace & Hscan & Htail).
  destruct (tws_complete_scan_call_has_bobomb_pass _ _ _ _ _ _ _ Hscan)
    as (passes & pass & Hprovenance & Hnth & Hpass & Hi & Hinneri & Hinnerarea).
  exists scan_trace, scanned, scan_result, suffix, scan_le, final, out, passes, pass.
  split; [exact Htrace|]. split; [exact Hprovenance|].
  split; [exact Hnth|]. split; [exact Hpass|].
  split; [exact Hinneri|]. split; assumption.
Qed.

(** Start still earlier, at the real changed branch.  The direct unload
    call, its real function call and its post-scan suffix retain the same
    memories as the subsequent load. *)
Definition TTCChangedBranchPassReceipt version (e : env) (le : temp_env)
    (before : mem) (tr : trace) (last : temp_env) (after : mem)
    (out : outcome) (area : int) (passes : list TWSPass) (pass : TWSPass) : Prop :=
  exists unload_le unloaded unload_trace unload_result load_le loaded load_trace rest
      scan_trace scanned scan_result suffix scan_le scan_last scan_out,
    tr = unload_trace ++ (load_trace ++ rest) /\
    unload_trace = scan_trace ++ suffix /\
    ocn_exec (Clight.globalenv (selected_clight_target version)) e le before
      tea_unload_call unload_trace unload_le unloaded Out_normal /\
    ClightBigstep.Clight2.eval_funcall
      (Clight.globalenv (selected_clight_target version)) before
      (Internal (tea_unload_function version)) [] unload_trace unloaded unload_result /\
    TWSCallPasses version before (Vint Int.zero) area scan_trace scanned scan_result passes /\
    nth_error passes 2 = Some pass /\
    TWSActualPass version empty_env area pass /\
    (tws_inner_entry pass) ! TUL._i = Some (Vint (Int.repr 2)) /\
    (tws_inner_entry pass) ! TUL._areaIndex = Some (Vint area) /\
    ocn_exec (Clight.globalenv (selected_clight_target version)) empty_env
      scan_le scanned (tea_after_scan version) suffix scan_last unloaded scan_out /\
    ocn_exec (Clight.globalenv (selected_clight_target version)) e
      unload_le unloaded tea_load_call load_trace load_le loaded Out_normal /\
    ocn_exec (Clight.globalenv (selected_clight_target version)) e
      load_le loaded (tea_after_load version) rest last after out.

Definition TTCChangedBranchHasBobombPass : Prop :=
  forall version e le before tr last after out cell ab ao area,
  e ! TEA._unload_area = None ->
  Genv.find_symbol (Clight.globalenv (selected_clight_target version))
    TEA._gCurrentArea = Some cell ->
  Mem.load Mptr before cell 0 = Some (Vptr ab ao) ->
  Mem.load Mint8signed before ab (Ptrofs.unsigned ao) = Some (Vint area) ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le before
    (tea_changed_branch version) tr last after out ->
  exists passes pass,
    TTCChangedBranchPassReceipt version e le before tr last after out area passes pass.
Theorem ttc_changed_branch_has_bobomb_pass : TTCChangedBranchHasBobombPass.
Proof.
  intros version e le before tr last after out cell ab ao area
    Hlocal Hsymbol Hcurrent Harea Hrun.
  destruct (tea_changed_branch_unloads_before_loading _ _ _ _ _ _ _ _ _ Hrun)
    as (ul & um & ut & ll & lm & lt & rest & Htrace & Hunload & Hload & Htail).
  destruct (tea_reached_unload_uses_real_body _ _ _ _ _ _ _ _ Hlocal Hunload)
    as (result & Hcall & Htemps & Hout).
  destruct (ttc_complete_unload_has_bobomb_pass _ _ _ _ _ _ _ _ _
    Hsymbol Hcurrent Harea Hcall)
    as (st & sm & sr & suffix & sl & final & bodyout & passes & pass &
      Hscantrace & Hprovenance & Hnth & Hpass & Hi & Hidx & Hsuffix).
  exists passes, pass. unfold TTCChangedBranchPassReceipt.
  exists ul, um, ut, result, ll, lm, lt, rest, st, sm, sr, suffix, sl, final, bodyout.
  split; [exact Htrace|]. split; [exact Hscantrace|].
  split; [exact Hunload|]. split; [exact Hcall|].
  split; [exact Hprovenance|]. split; [exact Hnth|].
  split; [exact Hpass|]. split; [exact Hi|].
  split; [exact Hidx|]. split; [exact Hsuffix|]. split; assumption.
Qed.

(** The consumer uses the actual third pass and actual visits supplied by
    that same complete scan. The remaining hypotheses name the entry path
    and reads across earlier real unload calls. They do not assert death,
    survival, or a future allocation history. *)
Definition TTCWatchedCutForPass version (area : int) (pass : TWSPass) : Prop :=
  forall prefix watched sb sofs fb,
      (tws_inner_entry pass) ! TUL._node =
        Some (tul_pointer (tul_path_head prefix watched)) ->
      (tws_inner_entry pass) ! TUL._list = Some (Vptr sb sofs) ->
      tmt_owner_path (tws_inner_before pass) (Vptr sb sofs) area prefix watched ->
      Forall (TULReachedUnloadFrame version prefix watched) (tws_inner_visits pass) ->
      Genv.find_symbol (Clight.globalenv (selected_clight_target version))
        us_spawn_object._gFreeObjectList = Some fb ->
      exists visit unload_result deactivated,
        In visit (tws_inner_visits pass) /\
        ClightBigstep.Clight2.eval_funcall
          (Clight.globalenv (selected_clight_target version)) (tul_before visit)
          (Internal (tol_unload_function version)) [tul_pointer watched]
          (tul_trace visit) (tul_after visit) unload_result /\
        Mem.load Mint16signed deactivated (fst watched)
          (Ptrofs.unsigned (Ptrofs.add (snd watched) (Ptrofs.repr 116))) =
          Some (Vint Int.zero) /\
        Mem.store Mint16signed (tul_before visit) (fst watched)
          (Ptrofs.unsigned (Ptrofs.add (snd watched) (Ptrofs.repr 116)))
          (Vint Int.zero) = Some deactivated /\
        Mem.load Mptr (tul_after visit) fb 96 = Some (tul_pointer watched).

Lemma ttc_actual_pass_has_watched_cut : forall version area pass,
  TWSActualPass version empty_env area pass ->
  (tws_inner_entry pass) ! TUL._areaIndex = Some (Vint area) ->
  TTCWatchedCutForPass version area pass.
Proof.
  intros version area pass Hpass Harea.
  intros prefix watched sb sofs fb Hnode Hlist Hpath Hframes Hsymbol.
  destruct Hpass as (Hsetup & Hloop & Hwalk & Hrest).
  assert (TULWatchedDeactivation version watched (tws_inner_visits pass)) as Hwatched.
  { eapply tmt_actual_mixed_walk_reaches_watched_deactivation with
      (prefix := prefix) (original := prefix) (front := [])
      (le := tws_inner_entry pass) (before := tws_inner_before pass)
      (sentinel_b := sb) (sentinel_ofs := sofs) (area := area).
    - reflexivity.
    - apply PTree.gempty.
    - exact Hnode.
    - exact Hlist.
    - exact Harea.
    - exact Hpath.
    - exact Hwalk.
    - exact Hframes. }
  destruct Hwatched as (visit & ur & deactivated & Hin & Hreal & Hstore & Hzero).
  exists visit, ur, deactivated. repeat split; try assumption.
  destruct watched as [ob oo].
  eapply tul_complete_unload_call_returns_free_head; eauto.
Qed.

Definition TTCWholeScanWatchedCut : Prop :=
  forall version before unused area tr after result,
  ClightBigstep.Clight2.eval_funcall
    (Clight.globalenv (selected_clight_target version)) before
    (Internal (tol_scan_function version)) [unused; Vint area] tr after result ->
  exists passes pass,
    TWSCallPasses version before unused area tr after result passes /\
    nth_error passes 2 = Some pass /\
    TWSActualPass version empty_env area pass /\
    TTCWatchedCutForPass version area pass.
Theorem ttc_whole_scan_watched_cut : TTCWholeScanWatchedCut.
Proof.
  intros version before unused area tr after result Hcall.
  destruct (tws_complete_scan_call_has_bobomb_pass _ _ _ _ _ _ _ Hcall)
    as (passes & pass & Hprovenance & Hnth & Hpass & Hi & Hinneri & Harea).
  exists passes, pass. split; [exact Hprovenance|]. split; [exact Hnth|].
  split; [exact Hpass|]. eapply ttc_actual_pass_has_watched_cut; eassumption.
Qed.

(** The watched cut is attached to the same pass already extracted from the
    completed changed branch, rather than to a second existential scan. *)
Definition TTCChangedBranchWatchedCut : Prop :=
  forall version e le before tr last after out cell ab ao area,
  e ! TEA._unload_area = None ->
  Genv.find_symbol (Clight.globalenv (selected_clight_target version))
    TEA._gCurrentArea = Some cell ->
  Mem.load Mptr before cell 0 = Some (Vptr ab ao) ->
  Mem.load Mint8signed before ab (Ptrofs.unsigned ao) = Some (Vint area) ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le before
    (tea_changed_branch version) tr last after out ->
  exists passes pass,
    TTCChangedBranchPassReceipt version e le before tr last after out area passes pass /\
    TTCWatchedCutForPass version area pass.

Theorem ttc_changed_branch_watched_cut : TTCChangedBranchWatchedCut.
Proof.
  intros version e le before tr last after out cell ab ao area
    Hlocal Hsymbol Hcurrent Harea Hrun.
  destruct (ttc_changed_branch_has_bobomb_pass _ _ _ _ _ _ _ _ _ _ _ _
    Hlocal Hsymbol Hcurrent Harea Hrun) as (passes & pass & Hreceipt).
  exists passes, pass. split; [exact Hreceipt|].
  destruct Hreceipt as (ul & um & ut & ur & ll & lm & lt & rest &
    st & sm & sr & suffix & sl & final & scan_out &
    Htrace & Hscantrace & Hunload & Hcall & Hprovenance & Hnth & Hpass & Hi & Hidx & Hsuffix & Hload & Htail).
  eapply ttc_actual_pass_has_watched_cut; eassumption.
Qed.

Definition TeleporterTransportCutBoundary : Prop :=
  TTCUnloadAreaHasConcreteScan /\ TTCUnloadAreaHasBobombPass /\
  TTCChangedBranchHasBobombPass /\ TTCWholeScanWatchedCut /\ TTCChangedBranchWatchedCut.
Theorem teleporter_transport_cut_checked : TeleporterTransportCutBoundary.
Proof.
  split; [exact ttc_complete_unload_has_concrete_scan|].
  split; [exact ttc_complete_unload_has_bobomb_pass|].
  split; [exact ttc_changed_branch_has_bobomb_pass|].
  split; [exact ttc_whole_scan_watched_cut|].
  exact ttc_changed_branch_watched_cut.
Qed.
