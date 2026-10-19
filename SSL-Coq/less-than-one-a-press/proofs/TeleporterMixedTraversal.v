(** Mixed-owner traversal of the actual generated unload scan.  Prefix
    nodes may have any defined integer owner.  Nonmatching visits execute
    the real skip arm and preserve memory; only actual matching unload
    calls retain the pending-read frame obligation. *)
From Coq Require Import Bool List ZArith.
From compcert Require Import AST Clight ClightBigstep Clightdefs Cop Ctypes
  Events Globalenvs Integers Maps Memory Values.
From LessThanOneAPress.Proofs Require Import GameTypes ObjectContactNecessity
  ObjectContactReadback InkBackwardExecution TeleporterWarpClassification
  SelectedClightTarget TeleporterObjectLifetime TeleporterUnloadTraversal.
Import ListNotations.
Local Open Scope Z_scope.

Lemma tmt_matching_area_forces_unload : forall version e le before b ofs area
    tr last after out,
  le ! TUL._obj = Some (Vptr b ofs) ->
  le ! TUL._areaIndex = Some (Vint area) ->
  Mem.load Mint8signed before b
    (Ptrofs.unsigned (Ptrofs.add ofs (Ptrofs.repr 25))) = Some (Vint area) ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le before
    (tol_match_choice version) tr last after out ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e
    (PTree.set TUL._t'1 (Vint area) le) before
    tol_unload_call tr last after out.
Proof.
  intros version e le before b ofs area tr last after out Hobj Hindex Hload Hrun.
  rewrite (proj1 (tol_generated_unload_cuts_exact version)) in Hrun.
  destruct (twc_read_prefix_exec _ _ _ _ _ _ _ _ _ _ _ Hrun)
    as (index & Hread & Hrest).
  pose proof (tol_actual_area_read_value _ _ _ _ _ _ _ _ Hobj Hload Hread) as E.
  subst index.
  assert (eval_expr (Clight.globalenv (selected_clight_target version)) e
    (PTree.set TUL._t'1 (Vint area) le) before
    tol_area_guard (Vint Int.one)) as Hguard.
  { unfold tol_area_guard. eapply eval_Ebinop.
    - apply eval_Etempvar. apply PTree.gss.
    - apply eval_Etempvar. rewrite PTree.gso by discriminate. exact Hindex.
    - change (Some (Val.of_bool (Int.eq area area)) = Some (Vint Int.one)).
      rewrite Int.eq_true. reflexivity. }
  inversion Hrest; subst.
  match goal with Hv : eval_expr _ _ _ _ tol_area_guard ?v |- _ =>
    assert (v = Vint Int.one) by (eapply ocr_expr_unique; eauto); subst v end.
  match goal with Hb : bool_val (Vint Int.one) _ _ = Some ?b |- _ =>
    change (Some true = Some b) in Hb; inversion Hb; subst b end.
  assumption.
Qed.

Lemma tmt_nonmatching_choice_is_memory_identity : forall version e le before b ofs owner area
    tr last after out,
  le ! TUL._obj = Some (Vptr b ofs) ->
  le ! TUL._areaIndex = Some (Vint area) ->
  Mem.load Mint8signed before b
    (Ptrofs.unsigned (Ptrofs.add ofs (Ptrofs.repr 25))) = Some (Vint owner) ->
  owner <> area ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le before
    (tol_match_choice version) tr last after out ->
  tr = E0 /\ last = PTree.set TUL._t'1 (Vint owner) le /\
  after = before /\ out = Out_normal.
Proof.
  intros version e le before b ofs owner area tr last after out
    Hobj Hindex Hload Hneq Hrun.
  rewrite (proj1 (tol_generated_unload_cuts_exact version)) in Hrun.
  destruct (twc_read_prefix_exec _ _ _ _ _ _ _ _ _ _ _ Hrun)
    as (index & Hread & Hrest).
  pose proof (tol_actual_area_read_value _ _ _ _ _ _ _ _ Hobj Hload Hread) as E.
  subst index.
  assert (eval_expr (Clight.globalenv (selected_clight_target version)) e
    (PTree.set TUL._t'1 (Vint owner) le) before
    tol_area_guard (Vint Int.zero)) as Hguard.
  { unfold tol_area_guard. eapply eval_Ebinop.
    - apply eval_Etempvar. apply PTree.gss.
    - apply eval_Etempvar. rewrite PTree.gso by discriminate. exact Hindex.
    - change (Some (Val.of_bool (Int.eq owner area)) = Some (Vint Int.zero)).
      rewrite Int.eq_false by exact Hneq. reflexivity. }
  inversion Hrest; subst.
  match goal with Hv : eval_expr _ _ _ _ tol_area_guard ?v |- _ =>
    assert (v = Vint Int.zero) by (eapply ocr_expr_unique; eauto); subst v end.
  match goal with Hb : bool_val (Vint Int.zero) _ _ = Some ?b |- _ =>
    change (Some false = Some b) in Hb; inversion Hb; subst b end.
  match goal with Hskip : ClightBigstep.exec_stmt _ _ _ _ _ Sskip _ _ _ _ |- _ =>
    inversion Hskip; subst end.
  repeat split; reflexivity.
Qed.

Lemma tmt_matching_visit_reaches_real_unload : forall version e le before
    b ofs area tr last after,
  e ! TUL._unload_object = None ->
  le ! TUL._node = Some (Vptr b ofs) ->
  le ! TUL._areaIndex = Some (Vint area) ->
  Mem.load Mint8signed before b
    (Ptrofs.unsigned (Ptrofs.add ofs (Ptrofs.repr 25))) = Some (Vint area) ->
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
  intros version e le before b ofs area tr last after Hlocal Hnode Hindex Harea Hrun.
  destruct (tul_scan_body_has_saved_next_cut _ _ _ _ _ _ _ _ _ Hnode Hrun)
    as (next & Hread & Hmatch).
  assert ((tul_saved_locals le (Vptr b ofs) next) ! TUL._obj = Some (Vptr b ofs)) as Hobj.
  { unfold tul_saved_locals. rewrite PTree.gso by discriminate. apply PTree.gss. }
  assert ((tul_saved_locals le (Vptr b ofs) next) ! TUL._areaIndex = Some (Vint area)) as HareaIndex.
  { unfold tul_saved_locals. repeat rewrite PTree.gso by discriminate. exact Hindex. }
  pose proof (tmt_matching_area_forces_unload _ _ _ _ _ _ _ _ _ _ _
    Hobj HareaIndex Harea Hmatch) as Hcall.
  destruct (tol_reached_call_uses_real_unload version e
    (PTree.set TUL._t'1 (Vint area) (tul_saved_locals le (Vptr b ofs) next))
    before b ofs tr last after Out_normal Hlocal
    ltac:(rewrite PTree.gso by discriminate; exact Hobj) Hcall) as (result & Hreal).
  destruct (tol_unload_call_entry _ _ _ _ _ _ _ Hreal)
    as (entry & final & outcome & Hentry & Hbody).
  destruct (tol_completed_unload_reaches_deactivation _ _ _ _ _ _ _ _ _ _ Hentry Hbody)
    as (deactivated & tail & _ & Hstore & Hzero & _).
  destruct (tul_match_choice_preserves_cursor_temps _ _ _ _ _ _ _ _ Hmatch)
    as (Hnext & Hlist & Hkeep).
  exists next, result. repeat split; try assumption.
  - rewrite Hnext. unfold tul_saved_locals. apply PTree.gss.
  - rewrite Hlist. unfold tul_saved_locals. repeat rewrite PTree.gso by discriminate. reflexivity.
  - rewrite Hkeep. unfold tul_saved_locals. repeat rewrite PTree.gso by discriminate. reflexivity.
  - exists deactivated. auto.
Qed.

Lemma tmt_nonmatching_visit_is_memory_identity : forall version e le before
    b ofs owner area tr last after,
  le ! TUL._node = Some (Vptr b ofs) ->
  le ! TUL._areaIndex = Some (Vint area) ->
  Mem.load Mint8signed before b
    (Ptrofs.unsigned (Ptrofs.add ofs (Ptrofs.repr 25))) = Some (Vint owner) ->
  owner <> area ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le before
    (tol_scan_iteration version) tr last after Out_normal ->
  exists next,
    eval_expr (Clight.globalenv (selected_clight_target version)) e
      (PTree.set TUL._obj (Vptr b ofs) le) before tul_next_read next /\
    last ! TUL._node = Some next /\
    last ! TUL._list = le ! TUL._list /\
    last ! TUL._areaIndex = le ! TUL._areaIndex /\ after = before.
Proof.
  intros version e le before b ofs owner area tr last after Hnode Hindex Harea Hneq Hrun.
  destruct (tul_scan_body_has_saved_next_cut _ _ _ _ _ _ _ _ _ Hnode Hrun)
    as (next & Hread & Hmatch).
  assert ((tul_saved_locals le (Vptr b ofs) next) ! TUL._obj = Some (Vptr b ofs)) as Hobj.
  { unfold tul_saved_locals. rewrite PTree.gso by discriminate. apply PTree.gss. }
  assert ((tul_saved_locals le (Vptr b ofs) next) ! TUL._areaIndex = Some (Vint area)) as HareaIndex.
  { unfold tul_saved_locals. repeat rewrite PTree.gso by discriminate. exact Hindex. }
  destruct (tmt_nonmatching_choice_is_memory_identity _ _ _ _ _ _ _ _ _ _ _ _
    Hobj HareaIndex Harea Hneq Hmatch) as (Htrace & Hlast & Hmemory & _).
  exists next. split; [exact Hread|]. rewrite Hlast.
  unfold tul_saved_locals. repeat split; try assumption.
  - rewrite PTree.gso by discriminate. apply PTree.gss.
  - repeat rewrite PTree.gso by discriminate. reflexivity.
  - repeat rewrite PTree.gso by discriminate. reflexivity.
Qed.

Fixpoint tmt_owner_path (memory : mem) (sentinel : val) (area : int)
    (prefix : list TULPointer) (watched : TULPointer) : Prop :=
  match prefix with
  | [] => tul_pointer watched <> sentinel /\
      tul_area_load memory watched = Some (Vint area)
  | current :: remaining => tul_pointer current <> sentinel /\
      (exists owner, tul_area_load memory current = Some (Vint owner)) /\
      tul_next_load memory current = Some (tul_pointer (tul_path_head remaining watched)) /\
      tmt_owner_path memory sentinel area remaining watched
  end.

Lemma tmt_matching_path_is_owner_path : forall prefix watched memory sentinel,
  tul_matching_path memory sentinel prefix watched ->
  tmt_owner_path memory sentinel Int.one prefix watched.
Proof.
  induction prefix as [|current remaining IH]; intros watched memory sentinel Hpath;
    cbn in *.
  - exact Hpath.
  - destruct Hpath as (Hneq & Harea & Hnext & Htail).
    split; [exact Hneq|]. split; [exists Int.one; exact Harea|].
    split; [exact Hnext|]. apply IH; exact Htail.
Qed.

Lemma tmt_pending_reads_preserve_path : forall prefix watched sentinel area before after,
  TULPendingReadFrame before after prefix watched ->
  tmt_owner_path before sentinel area prefix watched ->
  tmt_owner_path after sentinel area prefix watched.
Proof.
  induction prefix as [|current remaining IH];
    intros watched sentinel area before after [Harea Hnext] Hpath; cbn in *.
  - destruct Hpath as [Hneq Hload]. split; [assumption|].
    rewrite Harea; [assumption|auto].
  - destruct Hpath as (Hneq & [owner Hload] & Hlink & Htail).
    repeat split; try assumption.
    + exists owner. rewrite Harea; [assumption|auto].
    + rewrite Hnext; [assumption|auto].
    + eapply IH; [|exact Htail]. split.
      * intros p Hin. apply Harea. right; assumption.
      * intros p Hin. apply Hnext. right; assumption.
Qed.

Theorem tmt_actual_mixed_walk_reaches_watched_deactivation : forall prefix,
  forall version e original front watched sentinel_b sentinel_ofs area
    le before visits last after,
  original = front ++ prefix ->
  e ! TUL._unload_object = None ->
  le ! TUL._node = Some (tul_pointer (tul_path_head prefix watched)) ->
  le ! TUL._list = Some (Vptr sentinel_b sentinel_ofs) ->
  le ! TUL._areaIndex = Some (Vint area) ->
  tmt_owner_path before (Vptr sentinel_b sentinel_ofs) area prefix watched ->
  TULWalk version e le before visits last after ->
  Forall (TULReachedUnloadFrame version original watched) visits ->
  TULWatchedDeactivation version watched visits.
Proof.
  induction prefix as [|current remaining IH];
    intros version e original front watched sb sofs area le before visits last after
      Horiginal Hlocal Hnode Hlist Hindex Hpath Hwalk Hframes.
  - destruct watched as [b ofs]. cbn [tul_path_head tul_pointer] in Hnode.
    destruct Hpath as [Hneq Harea].
    inversion Hwalk; subst.
    + exfalso. eapply tul_pointer_guard_cannot_stop; eauto.
    + destruct (tmt_matching_visit_reaches_real_unload _ _ _ _ _ _ _ _ _ _
        Hlocal Hnode Hindex Harea ltac:(eassumption))
        as (next & result & Hread & Hreal & Hnext & Hkeep & Hidx & deactivated & Hstore & Hzero).
      unfold TULWatchedDeactivation. eexists; exists result, deactivated.
      split; [left; reflexivity|]. cbn. repeat split; assumption.
  - destruct Hpath as (Hneq & [owner Harea] & Hlink & Htail).
    cbn [tul_path_head] in Hnode.
    destruct current as [b ofs]. cbn [tul_pointer] in Hnode, Hneq, Harea, Hlink.
    inversion Hwalk; subst.
    + exfalso. eapply tul_pointer_guard_cannot_stop; eauto.
    + inversion Hframes as [|visit rest Hframe Hremaining]; subst.
      destruct (Int.eq_dec owner area) as [Eowner|Hdifferentowner].
      * subst owner.
        destruct (tmt_matching_visit_reaches_real_unload _ _ _ _ _ _ _ _ _ _
          Hlocal Hnode Hindex Harea ltac:(eassumption))
          as (next & result & Hread & Hreal & Hnext & Hkeep & Hidx & deactivated & Hstore & Hzero).
        destruct (tul_pointer_eq_dec (b, ofs) watched) as [Ewatch|Hdifferent].
        -- subst watched. unfold TULWatchedDeactivation.
           eexists; exists result, deactivated.
           split; [left; reflexivity|]. cbn. repeat split; assumption.
        -- assert (next = tul_pointer (tul_path_head remaining watched)) as Enext.
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
             - eapply tmt_pending_reads_preserve_path; eauto. }
           destruct Hwatched as (visit & result' & deactivated' & Hin & Hreal' & Hstore' & Hzero').
           exists visit, result', deactivated'. split; [right; exact Hin|]. auto.
      * destruct (tmt_nonmatching_visit_is_memory_identity _ _ _ _ _ _ _ _ _ _ _
          Hnode Hindex Harea Hdifferentowner ltac:(eassumption))
          as (next & Hread & Hnext & Hkeep & Hidx & Hmemory).
        assert (next = tul_pointer (tul_path_head remaining watched)) as Enext.
        { eapply tul_actual_next_read; [|exact Hlink|exact Hread].
          rewrite PTree.gso by discriminate. exact Hnode. }
        subst next. subst next_memory.
        assert (TULWatchedDeactivation version watched visits0) as Hwatched.
        { eapply IH with (front := front ++ [(b, ofs)])
            (original := front ++ (b, ofs) :: remaining)
            (le := next_le) (before := before) (visits := visits0);
            try eassumption.
          - rewrite <- app_assoc. reflexivity.
          - rewrite Hkeep. exact Hlist.
          - rewrite Hidx. exact Hindex. }
        destruct Hwatched as (visit & result' & deactivated' & Hin & Hreal' & Hstore' & Hzero').
        exists visit, result', deactivated'. split; [right; exact Hin|]. auto.
Qed.

Definition TMTActualMixedTraversal : Prop := forall version e le before tr
    last after out prefix watched sentinel_b sentinel_ofs area,
  e ! TUL._unload_object = None ->
  le ! TUL._node = Some (tul_pointer (tul_path_head prefix watched)) ->
  le ! TUL._list = Some (Vptr sentinel_b sentinel_ofs) ->
  le ! TUL._areaIndex = Some (Vint area) ->
  tmt_owner_path before (Vptr sentinel_b sentinel_ofs) area prefix watched ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le before
    (tul_loop version) tr last after out ->
  exists visits,
    TULWalk version e le before visits last after /\
    (Forall (TULReachedUnloadFrame version prefix watched) visits ->
      TULWatchedDeactivation version watched visits).

Theorem tmt_actual_mixed_traversal_reaches_watched : TMTActualMixedTraversal.
Proof.
  intros version e le before tr last after out prefix watched sb sofs area
    Hlocal Hnode Hlist Hindex Hpath Hrun.
  destruct (tul_completed_inner_loop_has_actual_walk _ _ _ _ _ _ _ _ Hrun)
    as (Hnormal & visits & Hwalk).
  exists visits. split; [exact Hwalk|]. intro Hframes.
  eapply tmt_actual_mixed_walk_reaches_watched_deactivation with
    (original := prefix) (front := []) (prefix := prefix); eauto.
Qed.

Definition TMTActualMixedTraversalReturnsToFreeList : Prop := forall version e le before tr
    last after out prefix watched sentinel_b sentinel_ofs area fb,
  e ! TUL._unload_object = None ->
  le ! TUL._node = Some (tul_pointer (tul_path_head prefix watched)) ->
  le ! TUL._list = Some (Vptr sentinel_b sentinel_ofs) ->
  le ! TUL._areaIndex = Some (Vint area) ->
  tmt_owner_path before (Vptr sentinel_b sentinel_ofs) area prefix watched ->
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

Theorem tmt_actual_mixed_traversal_returns_watched_to_free_list :
  TMTActualMixedTraversalReturnsToFreeList.
Proof.
  intros version e le before tr last after out prefix [b ofs] sb sofs area fb
    Hlocal Hnode Hlist Hindex Hpath Hsymbol Hrun.
  destruct (tmt_actual_mixed_traversal_reaches_watched _ _ _ _ _ _ _ _ _ _ _ _ _
    Hlocal Hnode Hlist Hindex Hpath Hrun) as (visits & Hwalk & Hresult).
  exists visits. split; [exact Hwalk|]. intro Hframes.
  destruct (Hresult Hframes) as (visit & result & deactivated & Hin & Hreal & Hstore & Hzero).
  exists visit, result. split; [exact Hin|]. split; [exact Hreal|].
  eapply tul_complete_unload_call_returns_free_head; eauto.
Qed.

Definition TeleporterMixedTraversalBoundary : Prop :=
  TMTActualMixedTraversal /\ TMTActualMixedTraversalReturnsToFreeList.
Theorem teleporter_mixed_traversal_checked : TeleporterMixedTraversalBoundary.
Proof.
  split; [exact tmt_actual_mixed_traversal_reaches_watched|].
  exact tmt_actual_mixed_traversal_returns_watched_to_free_list.
Qed.
