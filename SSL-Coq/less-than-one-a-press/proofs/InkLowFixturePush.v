(** Backward obstruction for a low, floorless Ink destination.

    The destination query in the real object-push helper uses movement Y,
    irrespective of a retained high display. If that actual query returns
    a null floor, the query and the following branch preserve every MarioState
    observation. The completed-call result also accounts for local cleanup.

    This is not an all-history exclusion. It starts after the helper's math
    and wall correction, and does not identify the live surface lists with
    a recorded geometry snapshot. No cap-interior assumption is used. *)
From Coq Require Import List ZArith.
From compcert Require Import AST Clight ClightBigstep Ctypes Events Floats
  Globalenvs Integers Maps Memory Values.
From LessThanOneAPress.Generated Require Import us_object_list_processor.
From LessThanOneAPress.Proofs Require Import GameTypes InkObjectPushHandoff
  InkObjectPushQuery InkBackwardExecution InkFloorCallEffects ObjectContactNecessity
  UpperElevatorQueryResolution SelectedClightTarget.
Import ListNotations.
Local Open Scope Z_scope.
Local Opaque selected_clight_target.

(** Unlike a premise saying that a query has no effects, the frame below is
    obtained from the real selected find_floor call, including its internal
    allocations, global scratch writes and cleanup. *)
Definition InkLowPushQueryCut : Prop :=
  forall version e le before mb fb height trace last after out,
  e ! IPH._find_floor = None -> e ! IPH._floor = Some (fb, ipq_surface) ->
  Genv.find_symbol (Clight.globalenv (selected_clight_target version))
    us_object_list_processor._gMarioStates = Some mb -> mb <> fb ->
  le ! IPH._m = Some (Vptr mb Ptrofs.zero) ->
  Mem.load Mfloat32 before mb 64 = Some (Vsingle height) ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le before
    (ipq_after_wall version) trace last after out ->
  exists x z queried result,
    ClightBigstep.Clight2.eval_funcall (Clight.globalenv (selected_clight_target version))
      before (Internal (ueqr_native_body version UEQRFindFloor))
      [Vsingle x; Vsingle height; Vsingle z; Vptr fb Ptrofs.zero] E0 queried result /\
    (Mem.load Mint32 queried fb 0 = Some (Vint Int.zero) ->
      trace = E0 /\ out = Out_normal /\
      forall chunk offset,
        Mem.load chunk after mb offset = Mem.load chunk before mb offset).

Theorem ilfp_real_null_query_preserves_all_mario_cells : InkLowPushQueryCut.
Proof.
  intros version e le before mb fb height trace last after out
    Hlocal Hfloor Hsymbol Hapart Hm Hy Hrun.
  destruct (ipq_source version) as (Hshape & _ & Hnormal & _).
  rewrite Hshape in Hrun.
  destruct (ibk_split_sequence _ _ _ _ _ _ _ _ _ _ Hnormal Hrun)
    as (query_le & queried & query_trace & tail_trace & Htrace & Hquery & Htail).
  destruct (ipq_actual_destination_query _ _ _ _ _ _ _ _ _ _ _
    Hlocal Hfloor Hm Hy Hquery) as (x & z & result & Hcall & _).
  destruct (ipq_actual_query_frames_mario _ _ _ _ _ _ _ _ _ _ _
    Hlocal Hfloor Hsymbol Hapart Hm Hy Hquery) as (Ht & _ & _ & Hframe).
  subst query_trace. exists x, z, queried, result. split; [exact Hcall|].
  intro Hnull.
  destruct (iph_null_destination_commits_nothing version
    (Clight.globalenv (selected_clight_target version)) e query_le queried fb
    tail_trace last after out Hfloor Hnull Htail) as (-> & -> & ->).
  split; [exact Htrace|]. split; [reflexivity|exact Hframe].
Qed.

(** A backward statement about ONE completed actual helper call. Its source
    distance test may reject the actor; otherwise the live floor query is
    exposed at the cut reached by that call. The all-cell frame holds through
    the caller's freeing of local variables, not just through the branch.

    A proposed sideward producer must consequently supply a non-null query
    result, or already have made its change in the earlier exposed prefix.
    Neither an old cached floor nor the display height substitutes for the
    local destination-query result. *)
Definition InkLowPushCompletedCallCut : Prop :=
  forall version before mb actor padding trace after result,
  Mem.valid_block before mb ->
  ClightBigstep.Clight2.eval_funcall (Clight.globalenv (selected_clight_target version))
    before (Internal (iph_body version)) [Vptr mb Ptrofs.zero; actor; padding]
    trace after result ->
  exists e entry_le entry_m choice_le choice_m pre rest body_m,
    function_entry2 (Clight.globalenv (selected_clight_target version))
      (iph_body version) [Vptr mb Ptrofs.zero; actor; padding]
      before e entry_le entry_m /\
    trace = pre ++ rest /\
    ocn_exec (Clight.globalenv (selected_clight_target version)) e entry_le entry_m
      (ocn_prepend (ipq_before_choice version) Sskip) pre choice_le choice_m Out_normal /\
    ((ocn_test_value (Clight.globalenv (selected_clight_target version))
        e choice_le choice_m ipq_distance_guard false /\ body_m = choice_m) \/
     exists cut_le cut_m wall_trace query_trace last out,
      rest = wall_trace ++ query_trace /\
      ocn_test_value (Clight.globalenv (selected_clight_target version))
        e choice_le choice_m ipq_distance_guard true /\
      ocn_exec (Clight.globalenv (selected_clight_target version)) e choice_le choice_m
        (ocn_prepend (ipq_before_query version) Sskip) wall_trace cut_le cut_m Out_normal /\
      ocn_exec (Clight.globalenv (selected_clight_target version)) e cut_le cut_m
        (ipq_after_wall version) query_trace last body_m out /\
      (forall fb height,
        e ! IPH._find_floor = None -> e ! IPH._floor = Some (fb, ipq_surface) ->
        Genv.find_symbol (Clight.globalenv (selected_clight_target version))
          us_object_list_processor._gMarioStates = Some mb ->
        Mem.load Mfloat32 cut_m mb 64 = Some (Vsingle height) ->
        exists x z queried query_result,
          ClightBigstep.Clight2.eval_funcall (Clight.globalenv (selected_clight_target version))
            cut_m (Internal (ueqr_native_body version UEQRFindFloor))
            [Vsingle x; Vsingle height; Vsingle z; Vptr fb Ptrofs.zero]
            E0 queried query_result /\
          (Mem.load Mint32 queried fb 0 = Some (Vint Int.zero) ->
            forall chunk offset,
              Mem.load chunk after mb offset = Mem.load chunk cut_m mb offset))).

Theorem ilfp_completed_push_exposes_floorless_obstruction : InkLowPushCompletedCallCut.
Proof.
  intros version before mb actor padding trace after result Hvalid Hcall.
  destruct (ipq_completed_push_exposes_actual_query_cut _ _ _ _ _ _ _ _ Hvalid Hcall)
    as (e & entry_le & entry_m & choice_le & choice_m & pre & rest & body_m &
      Hentry & Htrace & Hprefix & Hfree & Hchoice).
  exists e, entry_le, entry_m, choice_le, choice_m, pre, rest, body_m.
  split; [exact Hentry|]. split; [exact Htrace|]. split; [exact Hprefix|].
  destruct Hchoice as [Hmiss|Hhit]; [left; exact Hmiss|right].
  destruct Hhit as (cut_le & cut_m & wall_trace & query_trace & last & out &
    Hrest & Hguard & Hwall & Hquery & HcutM & _).
  exists cut_le, cut_m, wall_trace, query_trace, last, out.
  split; [exact Hrest|]. split; [exact Hguard|].
  split; [exact Hwall|]. split; [exact Hquery|].
  intros fb height Hlocal Hfloor Hsymbol Hy.
  pose proof (ipq_entry_locals_separate _ _ _ _ _ _ _ _ _ Hvalid Hentry) as Hlocals.
  assert (mb <> fb) as Hapart by (pose proof (Hlocals _ _ _ Hfloor); congruence).
  destruct (ilfp_real_null_query_preserves_all_mario_cells _ _ _ _ _ _ _ _ _ _ _
    Hlocal Hfloor Hsymbol Hapart HcutM Hy Hquery)
    as (x & z & queried & query_result & Hcall_query & Hnull_frame).
  exists x, z, queried, query_result. split; [exact Hcall_query|].
  intros Hnull chunk offset.
  rewrite (ifc_free_list_frame _ _ _ chunk mb offset
    (ipq_env_free_blocks _ _ _ Hlocals) Hfree).
  exact (proj2 (proj2 (Hnull_frame Hnull)) chunk offset).
Qed.

Definition InkLowFixturePushBoundary : Prop :=
  InkLowPushQueryCut /\ InkLowPushCompletedCallCut.

Theorem ilfp_low_fixture_push_checked : InkLowFixturePushBoundary.
Proof.
  split; [exact ilfp_real_null_query_preserves_all_mario_cells|
    exact ilfp_completed_push_exposes_floorless_obstruction].
Qed.
