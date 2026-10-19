(** Traversal of the actual generated area-unload inner loop.  An entry
    forward path is a list of concrete pointers and memory loads, not an
    abstract game transition.  The final theorem removes the formerly
    assumed reached watched scan node.  Entry ownership/list provenance and
    the exact preceding unload-call frames remain explicit obligations. *)
From Coq Require Import Bool List ZArith.
From compcert Require Import AST Clight ClightBigstep Clightdefs Cop Ctypes
  Events Globalenvs Integers Maps Memory Values.
From LessThanOneAPress.Proofs Require Import GameTypes ObjectContactNecessity
  ObjectContactReadback InkBackwardExecution InkCopyCaller
  EyerokRank15LiveMovement SelectedClightTarget TeleporterObjectLifetime
  ContactConsumerExecution UpperElevatorQueryResolution CleanedClightPrograms
  ClightLinkExecution GlobalInterfaceStructural JPSourceSymbolTransport
  JPWarpLevelEntryResolution LinkedClightPrograms NormalizedClightPrograms
  SuccessfulMakeProgramResolution USViewportRepairedNamesNorepet
  USViewportRepairedProgramSelection USWarpLevelRepairReceipt
  USWarpLevelSourceUnionReceipt USWholeASTTagRepair SecretContactExecution.
From LessThanOneAPress.Generated Require Import us_spawn_object jp_spawn_object.
Import ListNotations.
Local Open Scope Z_scope.
Local Opaque normalize_global_definition_map.
Module TUL := us_object_list_processor.

Definition tul_guard := Ebinop One
  (Etempvar TUL._node (tptr (Tstruct TUL._ObjectNode noattr)))
  (Etempvar TUL._list (tptr (Tstruct TUL._ObjectNode noattr))) tint.
Definition tul_iteration version := Ssequence
  (Sifthenelse tul_guard Sskip Sbreak) (tol_scan_iteration version).
Definition tul_loop version := Sloop (tul_iteration version) Sskip.
Definition tul_next_read := Efield
  (Ederef (Etempvar TUL._node (tptr (Tstruct TUL._ObjectNode noattr)))
    (Tstruct TUL._ObjectNode noattr)) TUL._next
  (tptr (Tstruct TUL._ObjectNode noattr)).
Definition tul_saved_locals (le : temp_env) (current next : val) :=
  PTree.set TUL._node next (PTree.set TUL._obj current le).

Lemma tul_generated_inner_loop : forall version,
  (match fn_body (tol_scan_function version) with
   | Ssequence _ (Ssequence _
       (Sloop (Ssequence _ (Ssequence _ (Ssequence _ inner))) _)) => inner
   | _ => Sskip end) = tul_loop version /\
  tol_scan_iteration version = Ssequence
    (Sset TUL._obj
      (Ecast (Etempvar TUL._node (tptr (Tstruct TUL._ObjectNode noattr)))
        (tptr (Tstruct TUL._Object noattr))))
    (Ssequence (Sset TUL._node tul_next_read) (tol_match_choice version)) /\
  ibk_normal (tol_scan_iteration version) = true.
Proof. intros []; repeat split; reflexivity. Qed.

Record TULVisit : Type := {
  tul_entry : temp_env;
  tul_before : mem;
  tul_trace : trace;
  tul_last : temp_env;
  tul_after : mem
}.

(** Every visit below is an actual execution of the generated scan body.
    The stopping receipt retains the actual false comparison. *)
Inductive TULWalk version (e : env) : temp_env -> mem ->
    list TULVisit -> temp_env -> mem -> Prop :=
| tul_walk_stop : forall le memory,
    ocn_test_value (Clight.globalenv (selected_clight_target version))
      e le memory tul_guard false ->
    TULWalk version e le memory [] le memory
| tul_walk_step : forall le memory tr next_le next_memory visits last after,
    ocn_test_value (Clight.globalenv (selected_clight_target version))
      e le memory tul_guard true ->
    ocn_exec (Clight.globalenv (selected_clight_target version)) e le memory
      (tol_scan_iteration version) tr next_le next_memory Out_normal ->
    TULWalk version e next_le next_memory visits last after ->
    TULWalk version e le memory
      ({| tul_entry := le; tul_before := memory; tul_trace := tr;
          tul_last := next_le; tul_after := next_memory |} :: visits) last after.

Lemma tul_iteration_cases : forall version e le before tr last after out,
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le before
    (tul_iteration version) tr last after out ->
  (ocn_test_value (Clight.globalenv (selected_clight_target version))
      e le before tul_guard false /\
    tr = E0 /\ last = le /\ after = before /\ out = Out_break) \/
  (ocn_test_value (Clight.globalenv (selected_clight_target version))
      e le before tul_guard true /\ out = Out_normal /\
    ocn_exec (Clight.globalenv (selected_clight_target version)) e le before
      (tol_scan_iteration version) tr last after Out_normal).
Proof.
  intros version e le before tr last after out Hrun.
  unfold tul_iteration in Hrun. inversion Hrun; subst.
  - match goal with Hif : ClightBigstep.exec_stmt _ _ _ _ _
      (Sifthenelse _ _ _) _ _ _ _ |- _ => inversion Hif; subst end.
    destruct b; cbn in *.
    + match goal with Hskip : ClightBigstep.exec_stmt _ _ _ _ _ Sskip _ _ _ _ |- _ =>
        inversion Hskip; subst end.
      right. repeat split; try assumption.
      * eexists; eauto.
      * eapply ibk_normal_outcome; [exact (proj2 (proj2 (tul_generated_inner_loop version)))|eassumption].
      * pose proof (ibk_normal_outcome _ _ _ _ _ _ _ _ _
          (proj2 (proj2 (tul_generated_inner_loop version))) ltac:(eassumption));
        subst; assumption.
    + match goal with Hbreak : ClightBigstep.exec_stmt _ _ _ _ _ Sbreak _ _ _ _ |- _ => inversion Hbreak end.
  - match goal with Hif : ClightBigstep.exec_stmt _ _ _ _ _
      (Sifthenelse _ _ _) _ _ _ _ |- _ => inversion Hif; subst end.
    destruct b; cbn in *.
    + match goal with Hskip : ClightBigstep.exec_stmt _ _ _ _ _ Sskip _ _ _ _ |- _ =>
        inversion Hskip; subst end. contradiction.
    + match goal with Hbreak : ClightBigstep.exec_stmt _ _ _ _ _ Sbreak _ _ _ _ |- _ =>
        inversion Hbreak; subst end.
      left. repeat split; try reflexivity. eexists; eauto.
Qed.

Theorem tul_completed_inner_loop_has_actual_walk : forall version e le before
    tr last after out,
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le before
    (tul_loop version) tr last after out ->
  out = Out_normal /\ exists visits, TULWalk version e le before visits last after.
Proof.
  intros version e le before tr last after out Hrun.
  remember (tul_loop version) as statement eqn:Hstatement.
  induction Hrun; inversion Hstatement; subst; try discriminate.
  - destruct (tul_iteration_cases _ _ _ _ _ _ _ _ Hrun)
      as [(Htest & -> & -> & -> & ->)|(Htest & -> & Hbody)].
    + inversion H; subst. split; [reflexivity|]. exists []; constructor; assumption.
    + inversion H.
  - match goal with Hskip : ClightBigstep.exec_stmt _ _ _ _ _ Sskip _ _ _ _ |- _ =>
      inversion Hskip; subst end. inversion H0.
  - destruct (tul_iteration_cases _ _ _ _ _ _ _ _ Hrun1)
      as [(Htest & -> & -> & -> & ->)|(Htest & -> & Hbody)].
    + inversion H.
    + match goal with Hskip : ClightBigstep.exec_stmt _ _ _ _ _ Sskip _ _ _ _ |- _ =>
        inversion Hskip; subst end.
      destruct (IHHrun3 eq_refl) as (-> & visits & Hwalk).
      split; [reflexivity|]. eexists. eapply tul_walk_step; eauto.
Qed.

Lemma tul_selected_next_layout : forall version,
  ibcc_field_ok (Clight.globalenv (selected_clight_target version))
    TUL._ObjectNode TUL._next 96 = true.
Proof.
  intro version.
  change (ibcc_field_ok (prog_comp_env (selected_clight_target version))
    TUL._ObjectNode TUL._next 96 = true).
  rewrite <- rank15_selected_header_environment_exact.
  destruct version; vm_compute; reflexivity.
Qed.

Lemma tul_actual_next_read : forall version e le memory b ofs next answer,
  le ! TUL._node = Some (Vptr b ofs) ->
  Mem.load Mptr memory b (Ptrofs.unsigned (Ptrofs.add ofs (Ptrofs.repr 96))) = Some next ->
  eval_expr (Clight.globalenv (selected_clight_target version)) e le memory
    tul_next_read answer -> answer = next.
Proof.
  intros version e le memory b ofs next answer Hnode Hload Hread.
  unfold tul_next_read in Hread. inversion Hread; subst.
  match goal with Hl : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ =>
    destruct (ibcc_field_location _ _ _ _
      (Ederef (Etempvar TUL._node (tptr (Tstruct TUL._ObjectNode noattr)))
        (Tstruct TUL._ObjectNode noattr)) TUL._ObjectNode TUL._next
      (tptr (Tstruct TUL._ObjectNode noattr)) b ofs 96 _ _ _ eq_refl
      ltac:(intros; eapply ibcc_deref_struct; [exact Hnode|eassumption])
      (tul_selected_next_layout version) Hl) as (-> & -> & ->) end.
  match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => inversion Hd; subst; try discriminate end.
  match goal with Hmode : access_mode _ = By_value _ |- _ =>
    cbn [access_mode] in Hmode; inversion Hmode; subst end.
  match goal with Hr : Mem.loadv _ _ _ = Some _ |- _ =>
    change (Mem.load Mptr memory b
      (Ptrofs.unsigned (Ptrofs.add ofs (Ptrofs.repr 96))) = Some answer) in Hr;
    congruence end.
Qed.

Lemma tul_scan_body_has_saved_next_cut : forall version e le before b ofs
    tr last after,
  le ! TUL._node = Some (Vptr b ofs) ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le before
    (tol_scan_iteration version) tr last after Out_normal ->
  exists next,
    eval_expr (Clight.globalenv (selected_clight_target version)) e
      (PTree.set TUL._obj (Vptr b ofs) le) before tul_next_read next /\
    ocn_exec (Clight.globalenv (selected_clight_target version)) e
      (tul_saved_locals le (Vptr b ofs) next) before
      (tol_match_choice version) tr last after Out_normal.
Proof.
  intros version e le before b ofs tr last after Hnode Hrun.
  rewrite (proj1 (proj2 (tul_generated_inner_loop version))) in Hrun.
  unfold ocn_exec, ClightBigstep.Clight2.exec_stmt in Hrun.
  cce_unroll_loop_free_exec.
  match goal with Hr : eval_expr ?ge ?env ?temps ?memory (Ecast ?arg ?ty) ?v |- _ =>
    assert (eval_expr ge env temps memory (Ecast arg ty) (Vptr b ofs)) as HcastValue
      by (eapply eval_Ecast; [apply eval_Etempvar; exact Hnode|reflexivity]);
    assert (v = Vptr b ofs) by (eapply ocr_expr_unique; eauto); subst v end.
  eexists; split; eassumption.
Qed.

Lemma tul_match_choice_preserves_cursor_temps : forall version e le before
    tr last after out,
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le before
    (tol_match_choice version) tr last after out ->
  last ! TUL._node = le ! TUL._node /\
  last ! TUL._list = le ! TUL._list /\
  last ! TUL._areaIndex = le ! TUL._areaIndex.
Proof.
  intros version e le before tr last after out Hrun.
  rewrite (proj1 (tol_generated_unload_cuts_exact version)) in Hrun.
  unfold tol_unload_call in Hrun.
  unfold ocn_exec, ClightBigstep.Clight2.exec_stmt in Hrun.
  cce_unroll_loop_free_exec;
    repeat match goal with Hcall : ClightBigstep.exec_stmt _ _ _ _ _
      (Scall None _ _) _ _ _ _ |- _ => inversion Hcall; subst; clear Hcall end;
    repeat split; apply PTree.gso; discriminate.
Qed.

Lemma tul_pointer_guard_cannot_stop : forall version e le memory b ofs sb sofs,
  le ! TUL._node = Some (Vptr b ofs) ->
  le ! TUL._list = Some (Vptr sb sofs) ->
  Vptr b ofs <> Vptr sb sofs ->
  ~ ocn_test_value (Clight.globalenv (selected_clight_target version))
    e le memory tul_guard false.
Proof.
  intros version e le memory b ofs sb sofs Hnode Hlist Hneq [answer [Hread Hbool]].
  unfold tul_guard in Hread. inversion Hread; subst.
  - match goal with Hr : eval_expr _ _ _ _ (Etempvar TUL._node _) ?v |- _ =>
      assert (v = Vptr b ofs) by (eapply ocn_temp_value; eauto); subst v end.
    match goal with Hr : eval_expr _ _ _ _ (Etempvar TUL._list _) ?v |- _ =>
      assert (v = Vptr sb sofs) by (eapply ocn_temp_value; eauto); subst v end.
    match goal with Hsem : sem_binary_operation _ _ _ _ _ _ _ = Some answer |- _ =>
      change (option_map Val.of_bool
        (Val.cmpu_bool (Mem.valid_pointer memory) Cne (Vptr b ofs)
          (Vptr sb sofs)) = Some answer) in Hsem;
      cbn [Val.cmpu_bool] in Hsem;
      repeat match type of Hsem with context [if ?test then _ else _] =>
        destruct test eqn:?; cbn in Hsem; try discriminate end;
      inversion Hsem; subst; try discriminate
    end.
    all: try (apply Hneq; f_equal; congruence).
    all: destruct (Ptrofs.eq ofs sofs) eqn:Hoffset; cbn in Hbool; try discriminate.
    all: apply Ptrofs.same_if_eq in Hoffset; subst; apply Hneq; reflexivity.
  - match goal with Hl : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ => inversion Hl end.
Qed.

Definition TULPointer := (block * ptrofs)%type.
Definition tul_pointer (p : TULPointer) := Vptr (fst p) (snd p).
Definition tul_pointer_eq_dec (p q : TULPointer) : {p = q} + {p <> q}.
Proof. decide equality; [apply Ptrofs.eq_dec|apply Pos.eq_dec]. Defined.
Definition tul_area_load (memory : mem) (p : TULPointer) :=
  Mem.load Mint8signed memory (fst p)
    (Ptrofs.unsigned (Ptrofs.add (snd p) (Ptrofs.repr 25))).
Definition tul_next_load (memory : mem) (p : TULPointer) :=
  Mem.load Mptr memory (fst p)
    (Ptrofs.unsigned (Ptrofs.add (snd p) (Ptrofs.repr 96))).
Definition tul_path_head (prefix : list TULPointer) (watched : TULPointer) :=
  match prefix with [] => watched | first :: _ => first end.

(** The prefix is an actual finite path in entry memory, ending at the
    watched object. Matching ownership is required for this bounded theorem;
    it is not asserted for an arbitrary reachable object list. *)
Fixpoint tul_matching_path (memory : mem) (sentinel : val)
    (prefix : list TULPointer) (watched : TULPointer) : Prop :=
  match prefix with
  | [] => tul_pointer watched <> sentinel /\
      tul_area_load memory watched = Some (Vint Int.one)
  | current :: remaining => tul_pointer current <> sentinel /\
      tul_area_load memory current = Some (Vint Int.one) /\
      tul_next_load memory current =
        Some (tul_pointer (tul_path_head remaining watched)) /\
      tul_matching_path memory sentinel remaining watched
  end.

Definition TULPendingReadFrame (before after : mem)
    (pending : list TULPointer) (watched : TULPointer) : Prop :=
  (forall p, In p (pending ++ [watched]) ->
    tul_area_load after p = tul_area_load before p) /\
  (forall p, In p pending -> tul_next_load after p = tul_next_load before p).

Lemma tul_pending_reads_preserve_path : forall prefix watched sentinel before after,
  TULPendingReadFrame before after prefix watched ->
  tul_matching_path before sentinel prefix watched ->
  tul_matching_path after sentinel prefix watched.
Proof.
  induction prefix as [|current remaining IH];
    intros watched sentinel before after [Harea Hnext] Hpath; cbn in *.
  - destruct Hpath as [Hneq Hload]. split; [assumption|].
    rewrite Harea; [assumption|auto].
  - destruct Hpath as (Hneq & Hload & Hlink & Htail).
    repeat split; try assumption.
    + rewrite Harea; [assumption|auto].
    + rewrite Hnext; [assumption|auto].
    + eapply IH; [|exact Htail]. split.
      * intros p Hin. apply Harea. right; assumption.
      * intros p Hin. apply Hnext. right; assumption.
Qed.

(** A frame obligation names only an actual visit's endpoints, trace,
    selected real unload body, concrete receiver and pending finite suffix.
    It concerns next links and owner bytes; it does not assume survival or
    deactivation of the watched object. *)
Definition TULReachedUnloadFrame version (original : list TULPointer)
    (watched : TULPointer) (visit : TULVisit) : Prop :=
  forall front current pending result,
    original = front ++ current :: pending ->
    (tul_entry visit) ! TUL._node = Some (tul_pointer current) ->
    current <> watched ->
    ClightBigstep.Clight2.eval_funcall
      (Clight.globalenv (selected_clight_target version)) (tul_before visit)
      (Internal (tol_unload_function version)) [tul_pointer current]
      (tul_trace visit) (tul_after visit) result ->
    TULPendingReadFrame (tul_before visit) (tul_after visit) pending watched.

Lemma tul_matching_visit_reaches_real_unload : forall version e le before
    b ofs tr last after,
  e ! TUL._unload_object = None ->
  le ! TUL._node = Some (Vptr b ofs) ->
  le ! TUL._areaIndex = Some (Vint Int.one) ->
  Mem.load Mint8signed before b
    (Ptrofs.unsigned (Ptrofs.add ofs (Ptrofs.repr 25))) = Some (Vint Int.one) ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le before
    (tol_scan_iteration version) tr last after Out_normal ->
  exists next result,
    eval_expr (Clight.globalenv (selected_clight_target version)) e
      (PTree.set TUL._obj (Vptr b ofs) le) before tul_next_read next /\
    ClightBigstep.Clight2.eval_funcall
      (Clight.globalenv (selected_clight_target version)) before
      (Internal (tol_unload_function version)) [Vptr b ofs] tr after result /\
    last ! TUL._node = Some next /\
    last ! TUL._list = le ! TUL._list /\
    last ! TUL._areaIndex = le ! TUL._areaIndex /\
    exists deactivated,
      Mem.store Mint16signed before b
        (Ptrofs.unsigned (Ptrofs.add ofs (Ptrofs.repr 116))) (Vint Int.zero) =
        Some deactivated /\
      Mem.load Mint16signed deactivated b
        (Ptrofs.unsigned (Ptrofs.add ofs (Ptrofs.repr 116))) = Some (Vint Int.zero).
Proof.
  intros version e le before b ofs tr last after Hlocal Hnode Hindex Harea Hrun.
  destruct (tul_scan_body_has_saved_next_cut _ _ _ _ _ _ _ _ _ Hnode Hrun)
    as (next & Hread & Hmatch).
  assert ((tul_saved_locals le (Vptr b ofs) next) ! TUL._obj = Some (Vptr b ofs)) as Hobj.
  { unfold tul_saved_locals. rewrite PTree.gso by discriminate. apply PTree.gss. }
  assert ((tul_saved_locals le (Vptr b ofs) next) ! TUL._areaIndex = Some (Vint Int.one)) as HareaIndex.
  { unfold tul_saved_locals. repeat rewrite PTree.gso by discriminate. exact Hindex. }
  pose proof (tol_matching_area_forces_unload _ _ _ _ _ _ _ _ _ _
    Hobj HareaIndex Harea Hmatch) as Hcall.
  destruct (tol_reached_call_uses_real_unload version e
    (PTree.set TUL._t'1 (Vint Int.one) (tul_saved_locals le (Vptr b ofs) next))
    before b ofs tr last after Out_normal Hlocal
    ltac:(rewrite PTree.gso by discriminate; exact Hobj) Hcall) as (result & Hreal).
  destruct (tol_matched_area_reaches_real_deactivation _ _ _ _ _ _ _ _ _ _
    Hlocal Hobj HareaIndex Harea Hmatch) as (deactivated & Hstore & Hzero).
  destruct (tul_match_choice_preserves_cursor_temps _ _ _ _ _ _ _ _ Hmatch)
    as (Hnext & Hlist & Hkeep).
  exists next, result. repeat split; try assumption.
  - rewrite Hnext. unfold tul_saved_locals. apply PTree.gss.
  - rewrite Hlist. unfold tul_saved_locals. repeat rewrite PTree.gso by discriminate. reflexivity.
  - rewrite Hkeep. unfold tul_saved_locals. repeat rewrite PTree.gso by discriminate. reflexivity.
  - exists deactivated. auto.
Qed.

Definition TULWatchedDeactivation (version : GameVersion) (watched : TULPointer)
    (visits : list TULVisit) : Prop :=
  exists visit result deactivated,
    In visit visits /\
    ClightBigstep.Clight2.eval_funcall
      (Clight.globalenv (selected_clight_target version)) (tul_before visit)
      (Internal (tol_unload_function version)) [tul_pointer watched]
      (tul_trace visit) (tul_after visit) result /\
    Mem.store Mint16signed (tul_before visit) (fst watched)
      (Ptrofs.unsigned (Ptrofs.add (snd watched) (Ptrofs.repr 116)))
      (Vint Int.zero) = Some deactivated /\
    Mem.load Mint16signed deactivated (fst watched)
      (Ptrofs.unsigned (Ptrofs.add (snd watched) (Ptrofs.repr 116))) =
      Some (Vint Int.zero).

Theorem tul_actual_walk_reaches_watched_deactivation : forall prefix,
  forall version e original front watched sentinel_b sentinel_ofs
    le before visits last after,
  original = front ++ prefix ->
  e ! TUL._unload_object = None ->
  le ! TUL._node = Some (tul_pointer (tul_path_head prefix watched)) ->
  le ! TUL._list = Some (Vptr sentinel_b sentinel_ofs) ->
  le ! TUL._areaIndex = Some (Vint Int.one) ->
  tul_matching_path before (Vptr sentinel_b sentinel_ofs) prefix watched ->
  TULWalk version e le before visits last after ->
  Forall (TULReachedUnloadFrame version original watched) visits ->
  TULWatchedDeactivation version watched visits.
Proof.
  induction prefix as [|current remaining IH];
    intros version e original front watched sb sofs le before visits last after
      Horiginal Hlocal Hnode Hlist Hindex Hpath Hwalk Hframes.
  - destruct watched as [b ofs]. cbn [tul_path_head tul_pointer] in Hnode.
    destruct Hpath as [Hneq Harea].
    inversion Hwalk; subst.
    + exfalso. eapply tul_pointer_guard_cannot_stop; eauto.
    + destruct (tul_matching_visit_reaches_real_unload _ _ _ _ _ _ _ _ _
        Hlocal Hnode Hindex Harea ltac:(eassumption))
        as (next & result & Hread & Hreal & Hnext & Hkeep & Hidx & deactivated & Hstore & Hzero).
      unfold TULWatchedDeactivation. eexists; exists result, deactivated.
      split; [left; reflexivity|]. cbn. repeat split; assumption.
  - destruct Hpath as (Hneq & Harea & Hlink & Htail).
    cbn [tul_path_head] in Hnode.
    destruct current as [b ofs]. cbn [tul_pointer] in Hnode, Hneq, Harea, Hlink.
    inversion Hwalk; subst.
    + exfalso. eapply tul_pointer_guard_cannot_stop; eauto.
    + inversion Hframes as [|visit rest Hframe Hremaining]; subst.
      destruct (tul_matching_visit_reaches_real_unload _ _ _ _ _ _ _ _ _
        Hlocal Hnode Hindex Harea ltac:(eassumption))
        as (next & result & Hread & Hreal & Hnext & Hkeep & Hidx & deactivated & Hstore & Hzero).
      destruct (tul_pointer_eq_dec (b, ofs) watched) as [Ewatch|Hdifferent].
      * subst watched. unfold TULWatchedDeactivation.
        eexists; exists result, deactivated.
        split; [left; reflexivity|]. cbn. repeat split; assumption.
      * assert (next = tul_pointer (tul_path_head remaining watched)) as Enext.
        { eapply tul_actual_next_read; [|exact Hlink|exact Hread].
          rewrite PTree.gso by discriminate. exact Hnode. }
        subst next.
        assert (TULPendingReadFrame before next_memory remaining watched) as HframeReads.
        { eapply Hframe with (front := front) (current := (b, ofs)) (result := result).
          - reflexivity.
          - exact Hnode.
          - exact Hdifferent.
          - exact Hreal. }
        assert (TULWatchedDeactivation version watched visits0) as Hwatched.
        { eapply IH with (front := front ++ [(b, ofs)])
            (original := front ++ (b, ofs) :: remaining)
            (le := next_le) (before := next_memory) (visits := visits0);
            try eassumption.
          - rewrite <- app_assoc. reflexivity.
          - rewrite Hkeep. exact Hlist.
          - rewrite Hidx. exact Hindex.
          - eapply tul_pending_reads_preserve_path; eauto. }
        destruct Hwatched as (visit & result' & deactivated' & Hin & Hreal' & Hstore' & Hzero').
        exists visit, result', deactivated'. split; [right; exact Hin|]. auto.
Qed.

(** A complete loop, not a separately assumed watched scan node, now supplies
    the deactivation checkpoint. The call-frame receipts are tied to the
    actual chronological visits extracted from that completed execution. *)
Definition TULActualTraversalBoundary : Prop := forall version e le before tr
    last after out prefix watched sentinel_b sentinel_ofs,
  e ! TUL._unload_object = None ->
  le ! TUL._node = Some (tul_pointer (tul_path_head prefix watched)) ->
  le ! TUL._list = Some (Vptr sentinel_b sentinel_ofs) ->
  le ! TUL._areaIndex = Some (Vint Int.one) ->
  tul_matching_path before (Vptr sentinel_b sentinel_ofs) prefix watched ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le before
    (tul_loop version) tr last after out ->
  exists visits,
    TULWalk version e le before visits last after /\
    (Forall (TULReachedUnloadFrame version prefix watched) visits ->
      TULWatchedDeactivation version watched visits).
Theorem teleporter_unload_traversal_boundary_checked : TULActualTraversalBoundary.
Proof.
  intros version e le before tr last after out prefix watched sb sofs
    Hlocal Hnode Hlist Hindex Hpath Hrun.
  destruct (tul_completed_inner_loop_has_actual_walk _ _ _ _ _ _ _ _ Hrun)
    as (Hnormal & visits & Hwalk).
  exists visits. split; [exact Hwalk|]. intro Hframes.
  eapply tul_actual_walk_reaches_watched_deactivation with
    (original := prefix) (front := []) (prefix := prefix); eauto.
Qed.

(** Callees receive values, not aliases of the caller's temporary map.
    This finite source check handles the actual store/call prefixes below. *)
Fixpoint tul_keeps_temp (keep : ident) (s : statement) : bool := match s with
| Sskip | Sassign _ _ | Sbreak | Scontinue | Sreturn _ => true
| Sset id _ => negb (Pos.eqb id keep)
| Scall None _ _ | Sbuiltin None _ _ _ => true
| Scall (Some id) _ _ | Sbuiltin (Some id) _ _ _ => negb (Pos.eqb id keep)
| Ssequence first rest | Sifthenelse _ first rest | Sloop first rest =>
    tul_keeps_temp keep first && tul_keeps_temp keep rest
| _ => false end.
Lemma tul_actual_prefix_keeps_temp : forall ge e le memory s tr last after out,
  ocn_exec ge e le memory s tr last after out ->
  forall keep, tul_keeps_temp keep s = true -> last ! keep = le ! keep.
Proof.
  intros ge e le memory s tr last after out Hrun. induction Hrun;
    intros keep Hshape; cbn in Hshape; try discriminate; try reflexivity.
  - apply negb_true_iff in Hshape. apply Pos.eqb_neq in Hshape.
    apply PTree.gso. congruence.
  - destruct optid as [id|]; [|reflexivity].
    apply negb_true_iff in Hshape. apply Pos.eqb_neq in Hshape.
    apply PTree.gso. congruence.
  - destruct optid as [id|]; [|reflexivity].
    apply negb_true_iff in Hshape. apply Pos.eqb_neq in Hshape.
    apply PTree.gso. congruence.
  - apply andb_true_iff in Hshape as [Hfirst Hrest].
    rewrite (IHHrun2 keep Hrest). apply IHHrun1; assumption.
  - apply andb_true_iff in Hshape as [Hfirst Hrest]. auto.
  - apply andb_true_iff in Hshape as [Hfirst Hrest]. destruct b; auto.
  - apply andb_true_iff in Hshape as [Hfirst Hrest]. auto.
  - apply andb_true_iff in Hshape as [Hfirst Hrest].
    rewrite (IHHrun2 keep Hrest). apply IHHrun1; assumption.
  - apply andb_true_iff in Hshape as [Hfirst Hrest].
    rewrite (IHHrun3 keep (andb_true_intro (conj Hfirst Hrest))).
    rewrite (IHHrun2 keep Hrest). apply IHHrun1; assumption.
Qed.

Definition tul_deallocate_function version := match version with
| VersionUS => us_spawn_object.f_deallocate_object
| VersionJP => jp_spawn_object.f_deallocate_object end.
Definition tul_free_head_store := Sassign
  (Efield
    (Ederef (Etempvar us_spawn_object._freeList
      (tptr (Tstruct TUL._ObjectNode noattr))) (Tstruct TUL._ObjectNode noattr))
    TUL._next (tptr (Tstruct TUL._ObjectNode noattr)))
  (Etempvar TUL._obj (tptr (Tstruct TUL._ObjectNode noattr))).
Definition tul_deallocate_prefix version :=
  ocn_prefix_items 3 (fn_body (tul_deallocate_function version)).
Lemma tul_deallocate_source_cut : forall version,
  fn_body (tul_deallocate_function version) =
    ocn_prepend (tul_deallocate_prefix version) tul_free_head_store /\
  forallb ibk_normal (tul_deallocate_prefix version) = true /\
  tul_keeps_temp us_spawn_object._freeList
    (ocn_prepend (tul_deallocate_prefix version) Sskip) = true /\
  tul_keeps_temp TUL._obj
    (ocn_prepend (tul_deallocate_prefix version) Sskip) = true /\
  fn_vars (tul_deallocate_function version) = [] /\
  fn_params (tul_deallocate_function version) =
    [(us_spawn_object._freeList, tptr (Tstruct TUL._ObjectNode noattr));
     (TUL._obj, tptr (Tstruct TUL._ObjectNode noattr))].
Proof. intros []; repeat split; reflexivity. Qed.

Lemma tul_final_free_head_store : forall version e le before fb fo ob oo tr last after out,
  le ! us_spawn_object._freeList = Some (Vptr fb fo) ->
  le ! TUL._obj = Some (Vptr ob oo) ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le before
    tul_free_head_store tr last after out ->
  Mem.load Mptr after fb
    (Ptrofs.unsigned (Ptrofs.add fo (Ptrofs.repr 96))) = Some (Vptr ob oo).
Proof.
  intros version e le before fb fo ob oo tr last after out Hfree Hobj Hrun.
  unfold tul_free_head_store in Hrun. inversion Hrun; subst.
  match goal with Hl : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ =>
    destruct (ibcc_field_location _ _ _ _
      (Ederef (Etempvar us_spawn_object._freeList (tptr (Tstruct TUL._ObjectNode noattr)))
        (Tstruct TUL._ObjectNode noattr)) TUL._ObjectNode TUL._next
      (tptr (Tstruct TUL._ObjectNode noattr)) fb fo 96 _ _ _ eq_refl
      ltac:(intros; eapply ibcc_deref_struct; [exact Hfree|eassumption])
      (tul_selected_next_layout version) Hl) as (-> & -> & ->) end.
  match goal with Hr : eval_expr _ _ _ _ (Etempvar TUL._obj _) ?v |- _ =>
    assert (v = Vptr ob oo) by (eapply ocn_temp_value; eauto); subst v end.
  match goal with Hcast : sem_cast (Vptr ob oo) _ _ _ = Some ?v |- _ =>
    change (Some (Vptr ob oo) = Some v) in Hcast; inversion Hcast; subst v end.
  match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ =>
    inversion Ha; subst; try discriminate end.
  match goal with Hmode : access_mode _ = By_value _ |- _ =>
    cbn [access_mode] in Hmode; inversion Hmode; subst end.
  match goal with Hstore : Mem.storev _ _ _ _ = Some after |- _ =>
    change (Mem.store Mptr before fb
      (Ptrofs.unsigned (Ptrofs.add fo (Ptrofs.repr 96))) (Vptr ob oo) = Some after)
      in Hstore;
    rewrite (Mem.load_store_same _ _ _ _ _ _ Hstore); reflexivity end.
Qed.

Theorem tul_complete_deallocate_body_returns_free_head : forall version e le before
    fb fo ob oo tr last after out,
  le ! us_spawn_object._freeList = Some (Vptr fb fo) ->
  le ! TUL._obj = Some (Vptr ob oo) ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le before
    (fn_body (tul_deallocate_function version)) tr last after out ->
  Mem.load Mptr after fb
    (Ptrofs.unsigned (Ptrofs.add fo (Ptrofs.repr 96))) = Some (Vptr ob oo).
Proof.
  intros version e le before fb fo ob oo tr last after out Hfree Hobj Hrun.
  destruct (tul_deallocate_source_cut version) as (Hbody & Hnormal & HkeepFree & HkeepObj & _).
  rewrite Hbody in Hrun.
  destruct (ibk_split_prefix _ _ _ _ _ _ _ _ _ _ Hnormal Hrun)
    as (middle & memory & pre & tail & Htrace & Hprefix & Hstore).
  eapply tul_final_free_head_store; [| |exact Hstore].
  - rewrite (tul_actual_prefix_keeps_temp _ _ _ _ _ _ _ _ _ Hprefix _ HkeepFree). exact Hfree.
  - rewrite (tul_actual_prefix_keeps_temp _ _ _ _ _ _ _ _ _ Hprefix _ HkeepObj). exact Hobj.
Qed.

Theorem tul_complete_deallocate_call_returns_free_head : forall version before fb fo ob oo
    tr after result,
  ClightBigstep.Clight2.eval_funcall
    (Clight.globalenv (selected_clight_target version)) before
    (Internal (tul_deallocate_function version)) [Vptr fb fo; Vptr ob oo] tr after result ->
  Mem.load Mptr after fb
    (Ptrofs.unsigned (Ptrofs.add fo (Ptrofs.repr 96))) = Some (Vptr ob oo).
Proof.
  intros version before fb fo ob oo tr after result Hcall.
  destruct (tul_deallocate_source_cut version) as (_ & _ & _ & _ & Hvars & Hparams).
  inversion Hcall; subst.
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => inversion He; subst; clear He end.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
    rewrite Hvars in Ha; inversion Ha; subst; clear Ha end.
  match goal with Hfree : Mem.free_list ?m (blocks_of_env _ empty_env) = Some ?m' |- _ =>
    change (Some m = Some m') in Hfree; inversion Hfree; subst end.
  match goal with Hb : bind_parameter_temps _ _ _ = Some ?temps |- _ =>
    rewrite Hparams in Hb; cbn [bind_parameter_temps] in Hb; inversion Hb; subst temps end.
  eapply tul_complete_deallocate_body_returns_free_head; [| |eassumption].
  - rewrite PTree.gso by discriminate. apply PTree.gss.
  - apply PTree.gss.
Qed.

Lemma tul_us_deallocate_source :
  nth_error us_spawn_object.global_definitions
    (ueqr_definition_index us_spawn_object._deallocate_object us_spawn_object.global_definitions) =
  Some (us_spawn_object._deallocate_object,
    Gfun (Internal (tul_deallocate_function VersionUS))).
Proof. vm_compute; reflexivity. Qed.
Lemma tul_us_deallocate_member :
  In (us_spawn_object._deallocate_object, Gfun (Internal (tul_deallocate_function VersionUS)))
    (unit_global_definitions us_units).
Proof.
  eapply source_unit_definition_enters_source_union with (unit := us_nlist_at 18 us_units).
  - exact (us_nlist_at_nIn _ 18 us_units).
  - change (In (us_spawn_object._deallocate_object,
      Gfun (Internal (tul_deallocate_function VersionUS))) us_spawn_object.global_definitions).
    eapply nth_error_In. exact tul_us_deallocate_source.
Qed.
Lemma tul_us_deallocate_selection :
  us_normalized_global_definition_map ! us_spawn_object._deallocate_object =
    Some (Gfun (Internal (tul_deallocate_function VersionUS))).
Proof.
  eapply (checked_internal_selection_is_exact
    (unit_global_definitions us_units) us_normalized_global_definition_map).
  - exact us_internal_identifiers_are_unique_checked.
  - exact us_all_internal_identifiers_selected_checked.
  - exact (normalized_definition_map_has_source_provenance (unit_global_definitions us_units)).
  - exact tul_us_deallocate_member.
Qed.
Lemma tul_us_deallocate_selected_member :
  In (us_spawn_object._deallocate_object, Gfun (Internal (tul_deallocate_function VersionUS)))
    us_viewport_repaired_global_definitions.
Proof.
  unfold us_viewport_repaired_global_definitions. apply fixed_point_enters_mapped_list.
  - unfold repair_us_selected_global_definition.
    assert (us_selected_definition_needs_viewport_repair
      (us_spawn_object._deallocate_object, Gfun (Internal (tul_deallocate_function VersionUS))) = false)
      as Hrepair by (vm_compute; reflexivity).
    rewrite Hrepair. reflexivity.
  - apply every_selected_internal_body_is_preserved_verbatim. exact tul_us_deallocate_selection.
Qed.
Theorem tul_selected_deallocate_resolves : forall version, exists b,
  Genv.find_symbol (Clight.globalenv (selected_clight_target version))
    us_spawn_object._deallocate_object = Some b /\
  Genv.find_funct_ptr (Clight.globalenv (selected_clight_target version)) b =
    Some (Internal (tul_deallocate_function version)).
Proof.
  intros [].
  - eapply program_definitions_resolve_internal_globalenv.
    + exact us_viewport_repaired_program_definitions_checked.
    + exact us_viewport_repaired_definition_names_norepet.
    + exact tul_us_deallocate_selected_member.
  - eapply (official_link_resolves_internal_globalenv jp_cleaned_units
      jp_official_cleaned_slice jp_cleaned_units_official_link (nlist_at 18 jp_cleaned_units)).
    + exact (nlist_at_nIn _ 18 jp_cleaned_units).
    + vm_compute; reflexivity.
Qed.

Definition tul_deallocate_call := Scall None
  (Evar us_spawn_object._deallocate_object
    (Tfunction [tptr (Tstruct TUL._ObjectNode noattr);
      tptr (Tstruct TUL._ObjectNode noattr)] tvoid cc_default))
  [Eaddrof (Evar us_spawn_object._gFreeObjectList (Tstruct TUL._ObjectNode noattr))
     (tptr (Tstruct TUL._ObjectNode noattr));
   Eaddrof
     (Efield
       (Ederef (Etempvar TUL._obj (tptr (Tstruct TUL._Object noattr)))
         (Tstruct TUL._Object noattr)) TUL._header (Tstruct TUL._ObjectNode noattr))
     (tptr (Tstruct TUL._ObjectNode noattr))].
Definition tul_unload_prefix version := ocn_prefix_items 8 (fn_body (tol_unload_function version)).
Lemma tul_unload_final_call_source : forall version,
  fn_body (tol_unload_function version) =
    ocn_prepend (tul_unload_prefix version) tul_deallocate_call /\
  forallb ibk_normal (tul_unload_prefix version) = true /\
  tul_keeps_temp TUL._obj (ocn_prepend (tul_unload_prefix version) Sskip) = true.
Proof. intros []; repeat split; reflexivity. Qed.

Lemma tul_actual_free_list_address : forall (ge : genv) e le memory fb answer,
  e ! us_spawn_object._gFreeObjectList = None ->
  Genv.find_symbol ge us_spawn_object._gFreeObjectList = Some fb ->
  eval_expr ge e le memory
    (Eaddrof (Evar us_spawn_object._gFreeObjectList (Tstruct TUL._ObjectNode noattr))
      (tptr (Tstruct TUL._ObjectNode noattr))) answer ->
  answer = Vptr fb Ptrofs.zero.
Proof.
  intros ge e le memory fb answer Hlocal Hsymbol Hread. inversion Hread; subst.
  match goal with Hl : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ =>
    inversion Hl; subst; try congruence end.
  all: match goal with Hbad : eval_lvalue _ _ _ _ (Eaddrof _ _) _ _ _ |- _ =>
    inversion Hbad end.
Qed.
Lemma tul_actual_object_header_address : forall version e le memory ob oo answer,
  le ! TUL._obj = Some (Vptr ob oo) ->
  eval_expr (Clight.globalenv (selected_clight_target version)) e le memory
    (Eaddrof
      (Efield
        (Ederef (Etempvar TUL._obj (tptr (Tstruct TUL._Object noattr)))
          (Tstruct TUL._Object noattr)) TUL._header (Tstruct TUL._ObjectNode noattr))
      (tptr (Tstruct TUL._ObjectNode noattr))) answer -> answer = Vptr ob oo.
Proof.
  intros version e le memory ob oo answer Hobj Hread. inversion Hread; subst.
  lazymatch goal with Hl : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ =>
    destruct (ibcc_field_location (Clight.globalenv (selected_clight_target version))
      e le memory tol_object TUL._Object TUL._header
      (Tstruct TUL._ObjectNode noattr) ob oo 0 _ _ _ eq_refl
      ltac:(intros; eapply (ibcc_deref_struct
        (Clight.globalenv (selected_clight_target version)) e le memory
        TUL._obj TUL._Object ob oo); [exact Hobj|eassumption])
      (proj1 (tol_selected_layout version)) Hl) as (Hblock & Hoffset & Hbit);
    subst end.
  - rewrite Ptrofs.add_zero. reflexivity.
  - match goal with Hbad : eval_lvalue _ _ _ _ (Eaddrof _ _) _ _ _ |- _ =>
      inversion Hbad end.
Qed.

Lemma tul_reached_deallocate_call_returns_free_head : forall version e le before fb ob oo
    tr last after out,
  e ! us_spawn_object._deallocate_object = None ->
  e ! us_spawn_object._gFreeObjectList = None ->
  Genv.find_symbol (Clight.globalenv (selected_clight_target version))
    us_spawn_object._gFreeObjectList = Some fb ->
  le ! TUL._obj = Some (Vptr ob oo) ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le before
    tul_deallocate_call tr last after out ->
  Mem.load Mptr after fb 96 = Some (Vptr ob oo).
Proof.
  intros version e le before fb ob oo tr last after out Hlocal HfreeLocal Hsymbol Hobj Hrun.
  destruct (tul_selected_deallocate_resolves version) as (b & HfunctionSymbol & Hfunction).
  unfold tul_deallocate_call in Hrun. inversion Hrun; subst.
  match goal with Hclass : classify_fun _ = _ |- _ => cbn in Hclass; inversion Hclass; subst end.
  lazymatch goal with Hexpr : eval_expr ?ge0 ?env0 ?temps0 ?memory0
      (Evar ?id (Tfunction ?args ?ret ?cc)) ?vf |- _ =>
    assert (vf = Vptr b Ptrofs.zero) by
      (exact (sce_function_name_value ge0 env0 temps0 memory0 id args ret cc b vf
        Hlocal HfunctionSymbol Hexpr)); subst vf end.
  match goal with Hfind : Genv.find_funct _ (Vptr _ _) = Some ?fd |- _ =>
    change (Genv.find_funct_ptr (Clight.globalenv (selected_clight_target version)) b = Some fd)
      in Hfind; rewrite Hfunction in Hfind; inversion Hfind; subst fd end.
  match goal with Hty : type_of_fundef _ = _ |- _ =>
    assert (type_of_fundef (Internal (tul_deallocate_function version)) =
      Tfunction [tptr (Tstruct TUL._ObjectNode noattr);
        tptr (Tstruct TUL._ObjectNode noattr)] tvoid cc_default) as Ety
      by (destruct version; reflexivity);
    rewrite Ety in Hty; inversion Hty; subst end.
  repeat match goal with Ha : eval_exprlist _ _ _ _ _ _ _ |- _ => inversion Ha; subst; clear Ha end.
  match goal with Hr : eval_expr _ _ _ _ (Eaddrof (Evar _ _) _) ?v |- _ =>
    assert (v = Vptr fb Ptrofs.zero) by (eapply tul_actual_free_list_address; eauto); subst v end.
  match goal with Hr : eval_expr _ _ _ _ (Eaddrof (Efield _ _ _) _) ?v |- _ =>
    assert (v = Vptr ob oo) by (eapply tul_actual_object_header_address; eauto); subst v end.
  repeat match goal with Hcast : sem_cast (Vptr ?vb ?vo) _ _ _ = Some ?v |- _ =>
    change (Some (Vptr vb vo) = Some v) in Hcast; inversion Hcast; subst v; clear Hcast end.
  eapply (tul_complete_deallocate_call_returns_free_head version before fb
    Ptrofs.zero ob oo tr after). eassumption.
Qed.

Definition TULCompleteUnloadFreeHead : Prop := forall version e le before fb ob oo
    tr last after out,
  e ! us_spawn_object._deallocate_object = None ->
  e ! us_spawn_object._gFreeObjectList = None ->
  Genv.find_symbol (Clight.globalenv (selected_clight_target version))
    us_spawn_object._gFreeObjectList = Some fb ->
  le ! TUL._obj = Some (Vptr ob oo) ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le before
    (fn_body (tol_unload_function version)) tr last after out ->
  Mem.load Mptr after fb 96 = Some (Vptr ob oo).
Theorem tul_complete_unload_body_returns_free_head : TULCompleteUnloadFreeHead.
Proof.
  intros version e le before fb ob oo tr last after out Hlocal HfreeLocal Hsymbol Hobj Hrun.
  destruct (tul_unload_final_call_source version) as (Hbody & Hnormal & Hkeep).
  rewrite Hbody in Hrun.
  destruct (ibk_split_prefix _ _ _ _ _ _ _ _ _ _ Hnormal Hrun)
    as (middle & memory & pre & tail & Htrace & Hprefix & Hcall).
  eapply (tul_reached_deallocate_call_returns_free_head version e middle memory
    fb ob oo tail last after out); eauto.
  rewrite (tul_actual_prefix_keeps_temp _ _ _ _ _ _ _ _ _ Hprefix _ Hkeep). exact Hobj.
Qed.

Definition TULCompleteUnloadCallFreeHead : Prop := forall version before fb ob oo
    tr after result,
  Genv.find_symbol (Clight.globalenv (selected_clight_target version))
    us_spawn_object._gFreeObjectList = Some fb ->
  ClightBigstep.Clight2.eval_funcall
    (Clight.globalenv (selected_clight_target version)) before
    (Internal (tol_unload_function version)) [Vptr ob oo] tr after result ->
  Mem.load Mptr after fb 96 = Some (Vptr ob oo).
Theorem tul_complete_unload_call_returns_free_head : TULCompleteUnloadCallFreeHead.
Proof.
  intros version before fb ob oo tr after result Hsymbol Hcall.
  destruct (tol_unload_call_entry _ _ _ _ _ _ _ Hcall)
    as (le & last & out & Hobj & Hbody).
  eapply tul_complete_unload_body_returns_free_head; eauto; apply PTree.gempty.
Qed.

Definition TULActualTraversalReturnsWatchedToFreeList : Prop :=
  forall version e le before tr last after out prefix watched sb sofs fb,
  e ! TUL._unload_object = None ->
  le ! TUL._node = Some (tul_pointer (tul_path_head prefix watched)) ->
  le ! TUL._list = Some (Vptr sb sofs) ->
  le ! TUL._areaIndex = Some (Vint Int.one) ->
  tul_matching_path before (Vptr sb sofs) prefix watched ->
  Genv.find_symbol (Clight.globalenv (selected_clight_target version))
    us_spawn_object._gFreeObjectList = Some fb ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le before
    (tul_loop version) tr last after out ->
  exists visits,
    TULWalk version e le before visits last after /\
    (Forall (TULReachedUnloadFrame version prefix watched) visits ->
      exists visit result,
        In visit visits /\
        ClightBigstep.Clight2.eval_funcall
          (Clight.globalenv (selected_clight_target version)) (tul_before visit)
          (Internal (tol_unload_function version)) [tul_pointer watched]
          (tul_trace visit) (tul_after visit) result /\
        Mem.load Mptr (tul_after visit) fb 96 = Some (tul_pointer watched)).
Theorem tul_actual_traversal_returns_watched_to_free_list :
  TULActualTraversalReturnsWatchedToFreeList.
Proof.
  intros version e le before tr last after out prefix [ob oo] sb sofs fb
    Hlocal Hnode Hlist Hindex Hpath Hsymbol Hrun.
  destruct (teleporter_unload_traversal_boundary_checked _ _ _ _ _ _ _ _ _ _ _ _
    Hlocal Hnode Hlist Hindex Hpath Hrun) as (visits & Hwalk & Hresult).
  exists visits. split; [exact Hwalk|]. intro Hframes.
  destruct (Hresult Hframes) as (visit & result & deactivated & Hin & Hcall & Hstore & Hzero).
  exists visit, result. split; [exact Hin|]. split; [exact Hcall|].
  eapply tul_complete_unload_call_returns_free_head; eauto.
Qed.

Definition TeleporterUnloadTraversalBoundary : Prop :=
  TULActualTraversalBoundary /\ TULCompleteUnloadFreeHead /\
  TULCompleteUnloadCallFreeHead /\ TULActualTraversalReturnsWatchedToFreeList.
Theorem teleporter_unload_traversal_checked : TeleporterUnloadTraversalBoundary.
Proof.
  split; [exact teleporter_unload_traversal_boundary_checked|].
  split; [exact tul_complete_unload_body_returns_free_head|].
  split; [exact tul_complete_unload_call_returns_free_head|].
  exact tul_actual_traversal_returns_watched_to_free_list.
Qed.
