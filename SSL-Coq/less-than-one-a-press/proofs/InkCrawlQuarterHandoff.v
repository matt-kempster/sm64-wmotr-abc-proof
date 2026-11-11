(** A bounded first-quarter handoff for the 973-unit candidate.

    This is a conditional statement about the actual selected Clight tail,
    together with exact source-expression and loop-exit certificates. The
    local floor/ceiling results and the remembered Mario state are hypotheses
    at the post-water cut. In particular, this file does not frame away the
    preceding wall, floor, ceiling, or water calls; it does not produce an
    already-established crawl, the push, or the required input history. *)
From Coq Require Import Bool List ZArith.
From compcert Require Import AST Clight ClightBigstep Clightdefs Cop Ctypes
  Events Floats Globalenvs Integers Maps Memory Values.
From LessThanOneAPress.Proofs Require Import GameTypes InkFloorHistorySource
  InkFloorHistoryExecution InkGroundBackwardSource InkBackwardSource
  InkBackwardExecution InkCopyCaller InkFloorResetSource ObjectContactNecessity
  ContactConsumerExecution SelectedClightTarget Area2Rank12BContact
  UpperElevatorQueryResolution.
Import ListNotations.
Import Clightdefs.ClightNotations.
Local Open Scope Z_scope.

Definition icqh_f32 (n : Z) := Float32.of_int (Int.repr n).
Definition icqh_four := Float32.of_bits (Int.repr 1082130432).
Definition icqh_eighty := Float32.of_bits (Int.repr 1117782016).

(** These are the binary32 tests used by the actual high-gap branch. A
    1280 floor does not make the quarter fall: the 1523 ceiling blocks first. *)
Theorem icqh_candidate_tests_checked :
  Float32.cmp Cgt (icqh_f32 1741)
    (Float32.add (icqh_f32 1280) ifh_100) = true /\
  Float32.cmp Cge (Float32.add (icqh_f32 1741) ifh_160)
    (icqh_f32 1523) = true /\
  Float32.to_bits (Float32.add (icqh_f32 1280) icqh_eighty) =
    Float32.to_bits (icqh_f32 1360).
Proof. vm_compute. repeat split; reflexivity. Qed.

Lemma icqh_next_y_evaluates : forall ge e le m nb no y,
  le ! IFH._nextPos = Some (Vptr nb no) ->
  Mem.load Mfloat32 m nb
    (Ptrofs.unsigned (Ptrofs.add no (Ptrofs.repr 4))) = Some (Vsingle y) ->
  eval_expr ge e le m (ifh_next 1) (Vsingle y).
Proof.
  intros ge e le m nb no y Hnext Hload. unfold ifh_next.
  eapply eval_Elvalue.
  - apply eval_Ederef. eapply eval_Ebinop.
    + apply eval_Etempvar. exact Hnext.
    + constructor.
    + reflexivity.
  - eapply deref_loc_value with (chunk := Mfloat32).
    + reflexivity.
    + exact Hload.
Qed.

Lemma icqh_high_gap_guard_evaluates : forall ge e le m,
  le ! IFH._t'16 = Some (Vsingle (icqh_f32 1741)) ->
  le ! IFH._floorHeight = Some (Vsingle (icqh_f32 1280)) ->
  eval_expr ge e le m ifh_leave_guard (Vint Int.one).
Proof.
  intros ge e le m Hy Hfloor. unfold ifh_leave_guard.
  eapply eval_Ebinop.
  - apply eval_Etempvar. exact Hy.
  - eapply eval_Ebinop.
    + apply eval_Etempvar. exact Hfloor.
    + constructor.
    + reflexivity.
  - change (Some (Val.of_bool (Float32.cmp Cgt (icqh_f32 1741)
      (Float32.add (icqh_f32 1280) ifh_100))) = Some (Vint Int.one)).
    rewrite (proj1 icqh_candidate_tests_checked). reflexivity.
Qed.

Lemma icqh_ceiling_guard_evaluates : forall ge e le m,
  le ! IFH._t'18 = Some (Vsingle (icqh_f32 1741)) ->
  le ! IFH._ceilHeight = Some (Vsingle (icqh_f32 1523)) ->
  eval_expr ge e le m ifh_y_ceil_guard (Vint Int.one).
Proof.
  intros ge e le m Hy Hceil. unfold ifh_y_ceil_guard.
  eapply eval_Ebinop.
  - eapply eval_Ebinop.
    + apply eval_Etempvar. exact Hy.
    + constructor.
    + reflexivity.
  - apply eval_Etempvar. exact Hceil.
  - change (Some (Val.of_bool (Float32.cmp Cge
      (Float32.add (icqh_f32 1741) ifh_160) (icqh_f32 1523))) =
      Some (Vint Int.one)).
    rewrite (proj1 (proj2 icqh_candidate_tests_checked)). reflexivity.
Qed.

Definition icqh_stop_locals le := PTree.set IFH._t'18
  (Vsingle (icqh_f32 1741))
  (PTree.set IFH._t'16 (Vsingle (icqh_f32 1741)) le).

Definition InkCrawlQuarter973TailExecution : Prop :=
  forall version ge e le m nb no,
  le ! IFH._nextPos = Some (Vptr nb no) ->
  le ! IFH._floorHeight = Some (Vsingle (icqh_f32 1280)) ->
  le ! IFH._ceilHeight = Some (Vsingle (icqh_f32 1523)) ->
  Mem.load Mfloat32 m nb
    (Ptrofs.unsigned (Ptrofs.add no (Ptrofs.repr 4))) =
    Some (Vsingle (icqh_f32 1741)) ->
  ocn_exec ge e le m (ifh_post_water version) E0
    (icqh_stop_locals le) m (ifh_returned 2).

(** Construct the tail execution itself from its ordinary memory/local
    hypotheses. No execution premise, external-call oracle, or axiom is used.
    This still does not construct the preceding live-query prefix. *)
Theorem icqh_973_ceiling_stop_executes : InkCrawlQuarter973TailExecution.
Proof.
  unfold InkCrawlQuarter973TailExecution.
  intros version ge e le m nb no Hnext Hfloor Hceil Hload.
  assert (ifh_post_water version = Ssequence (ifh_vertical version)
    (Ssequence (ifh_floor_ceil version) (ifh_accept version))) as Hpost
    by (destruct version; reflexivity).
  destruct (ifh_quarter_source_cuts version)
    as (_ & _ & _ & _ & _ & _ & _ & Hvertical & Hleave & _).
  rewrite Hpost, Hvertical, Hleave. unfold icqh_stop_locals.
  eapply exec_Sseq_2; [|discriminate].
  eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
  - apply exec_Sset. eapply icqh_next_y_evaluates; eauto.
  - eapply exec_Sifthenelse with (v1 := Vint Int.one) (b := true).
    + apply icqh_high_gap_guard_evaluates.
      * apply PTree.gss.
      * rewrite PTree.gso by discriminate. exact Hfloor.
    + reflexivity.
    + eapply exec_Sseq_2; [|discriminate].
      eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
      * apply exec_Sset. eapply icqh_next_y_evaluates.
        -- rewrite PTree.gso by discriminate. exact Hnext.
        -- exact Hload.
      * eapply exec_Sifthenelse with (v1 := Vint Int.one) (b := true).
        -- apply icqh_ceiling_guard_evaluates.
           ++ apply PTree.gss.
           ++ repeat rewrite PTree.gso by discriminate. exact Hceil.
        -- reflexivity.
        -- apply exec_Sreturn_some. constructor.
Qed.

Definition InkCrawlQuarterPreserves973Cache : Prop :=
  forall version e le m nb no t le' m' out,
  le ! IFH._nextPos = Some (Vptr nb no) ->
  le ! IFH._floorHeight = Some (Vsingle (icqh_f32 1280)) ->
  le ! IFH._ceilHeight = Some (Vsingle (icqh_f32 1523)) ->
  Mem.load Mfloat32 m nb
    (Ptrofs.unsigned (Ptrofs.add no (Ptrofs.repr 4))) =
    Some (Vsingle (icqh_f32 1741)) ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le m
    (ifh_post_water version) t le' m' out ->
  t = E0 /\ m' = m /\ out = ifh_returned 2.

(** Whole-memory preservation includes action, the floor pointer, floorHeight
    768, and movement Y1741 WHEN they hold at this cut. The queried floor1280
    remains a local result: this branch never installs it into MarioState. *)
Theorem icqh_973_ceiling_stop_preserves_current_memory :
  InkCrawlQuarterPreserves973Cache.
Proof.
  unfold InkCrawlQuarterPreserves973Cache.
  intros version e le m nb no t le' m' out Hnext Hfloor Hceil Hload Hrun.
  destruct icqh_candidate_tests_checked as (Hhigh & Hblock & _).
  pose proof (ifh_high_gap_requires_ceiling_block_or_leaves_ground
    version e le m nb no (icqh_f32 1741) (icqh_f32 1280)
    (icqh_f32 1523) t le' m' out Hnext Hfloor Hceil Hload Hhigh Hrun)
    as Hcases.
  destruct Hcases as [(_ & Htrace & Hmemory & Hout)| (Hfalse & _)];
    [repeat split; assumption|congruence].
Qed.

(** The same tail theorem transports any remembered load, not only one
    hard-coded offset. This is useful for the concrete floor pointer, action,
    movement coordinates, and remembered height without an alias assumption. *)
Corollary icqh_stopped_tail_preserves_cached_load :
  forall version e le m nb no t le' m' out chunk b ofs value,
  le ! IFH._nextPos = Some (Vptr nb no) ->
  le ! IFH._floorHeight = Some (Vsingle (icqh_f32 1280)) ->
  le ! IFH._ceilHeight = Some (Vsingle (icqh_f32 1523)) ->
  Mem.load Mfloat32 m nb
    (Ptrofs.unsigned (Ptrofs.add no (Ptrofs.repr 4))) =
    Some (Vsingle (icqh_f32 1741)) ->
  Mem.load chunk m b ofs = Some value ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le m
    (ifh_post_water version) t le' m' out ->
  Mem.load chunk m' b ofs = Some value.
Proof.
  intros version e le m nb no t le' m' out chunk b ofs value
    Hnext Hfloor Hceil Hy Hcached Hrun.
  destruct (icqh_973_ceiling_stop_preserves_current_memory version e le m nb no
    t le' m' out Hnext Hfloor Hceil Hy Hrun) as (_ & -> & _).
  exact Hcached.
Qed.

(** Extract only small selected source fragments; no whole-program reduction. *)
Definition icqh_loop_body version := match igb_first version with
  | Ssequence _ (Sloop body _) => body | _ => Sskip end.
Definition icqh_iteration version :=
  rank12b_drop_sequences 1 (icqh_loop_body version).
Definition icqh_x_setup version := ibk_head (icqh_iteration version).
Definition icqh_z_setup version :=
  ibk_head (rank12b_drop_sequences 1 (icqh_iteration version)).
Definition icqh_y_setup version :=
  ibk_head (rank12b_drop_sequences 2 (icqh_iteration version)).
Definition icqh_break_gate version :=
  rank12b_drop_sequences 4 (icqh_iteration version).
Definition icqh_intended_coord n := Ederef
  (Ebinop Oadd (Evar IFR._intendedPos (tarray tfloat 3))
    (Econst_int (Int.repr n) tint) (tptr tfloat)) tfloat.
Definition icqh_quarter_expression position normal velocity :=
  Ebinop Oadd (Etempvar position tfloat)
    (Ebinop Omul (Etempvar normal tfloat)
      (Ebinop Odiv (Etempvar velocity tfloat)
        (Econst_single icqh_four tfloat) tfloat) tfloat) tfloat.
Definition icqh_step_eq n := Ebinop Oeq (Etempvar IFR._stepResult tuint)
  (Econst_int (Int.repr n) tint) tint.
Definition icqh_break_source := Ssequence
  (Sifthenelse (icqh_step_eq 0)
    (Sset IFR._t'2 (Econst_int (Int.repr 1) tint))
    (Sset IFR._t'2 (Ecast (icqh_step_eq 2) tbool)))
  (Sifthenelse (Etempvar IFR._t'2 tint) Sbreak Sskip).

Definition icqh_ceil_query_call version := rank12b_drop_sequences 2
  (ibk_head (fn_body (ueqr_native_body version UEQRVecCeil))).

(** The ceiling wrapper's Y comes from its floor-height argument plus80;
    it does not query at intendedY+80. Native-body selection is provided by
    the existing UpperElevatorQueryResolution development. *)
Theorem icqh_selected_ceiling_query_source : forall version,
  icqh_ceil_query_call version = Scall (Some UEQR_UM._t'1)
    (Evar UEQR_UM._find_ceil (Tfunction
      [tfloat; tfloat; tfloat; tptr (tptr (Tstruct UEQR_UM._Surface noattr))]
      tfloat cc_default))
    [Etempvar UEQR_UM._t'2 tfloat;
     Ebinop Oadd (Etempvar UEQR_UM._height tfloat)
       (Econst_single icqh_eighty tfloat) tfloat;
     Etempvar UEQR_UM._t'3 tfloat;
     Etempvar UEQR_UM._ceil (tptr (tptr (Tstruct UEQR_UM._Surface noattr)))].
Proof. intros []; reflexivity. Qed.

(** The two horizontal coordinates use the CURRENT cached floor normal and
    post-walking-speed velocity. Y is copied from movement position, not the
    remembered floorHeight. This certificate identifies the actual stores. *)
Theorem icqh_selected_first_quarter_source : forall version,
  rank12b_drop_sequences 4 (icqh_x_setup version) =
    Sassign (icqh_intended_coord 0)
      (icqh_quarter_expression IFR._t'12 IFR._t'14 IFR._t'15) /\
  rank12b_drop_sequences 4 (icqh_z_setup version) =
    Sassign (icqh_intended_coord 2)
      (icqh_quarter_expression IFR._t'8 IFR._t'10 IFR._t'11) /\
  icqh_y_setup version = Ssequence
    (Sset IFR._t'7 (ifh_state_coord 1))
    (Sassign (icqh_intended_coord 1) (Etempvar IFR._t'7 tfloat)) /\
  icqh_break_gate version = icqh_break_source.
Proof. intros []; repeat split; reflexivity. Qed.

(** A deliberately bounded velocity example, not a reachable controller
    state: normalY1, velocityX4, velocityZ0 gives the +1X query. *)
Theorem icqh_one_unit_quarter_checked :
  Float32.to_bits (Float32.add (icqh_f32 (-1882))
    (Float32.mul (icqh_f32 1) (Float32.div (icqh_f32 4) icqh_four))) =
    Float32.to_bits (icqh_f32 (-1881)) /\
  Float32.to_bits (Float32.add (icqh_f32 (-939))
    (Float32.mul (icqh_f32 1) (Float32.div (icqh_f32 0) icqh_four))) =
    Float32.to_bits (icqh_f32 (-939)).
Proof. vm_compute. split; reflexivity. Qed.

Lemma icqh_quarter_expression_evaluates :
  forall ge e le m p n v position normal velocity,
  le ! p = Some (Vsingle position) ->
  le ! n = Some (Vsingle normal) ->
  le ! v = Some (Vsingle velocity) ->
  eval_expr ge e le m (icqh_quarter_expression p n v)
    (Vsingle (Float32.add position
      (Float32.mul normal (Float32.div velocity icqh_four)))).
Proof.
  intros ge e le m p n v position normal velocity Hp Hn Hv.
  unfold icqh_quarter_expression.
  eapply eval_Ebinop.
  - apply eval_Etempvar. exact Hp.
  - eapply eval_Ebinop.
    + apply eval_Etempvar. exact Hn.
    + eapply eval_Ebinop.
      * apply eval_Etempvar. exact Hv.
      * constructor.
      * reflexivity.
    + reflexivity.
  - reflexivity.
Qed.

(** Nonvacuous source-expression execution for the chosen +1X case. These
    local values must result from the preceding actual cached-floor and
    velocity loads; no claim about update_walking_speed producing 4 is made. *)
Theorem icqh_one_unit_expression_evaluates : forall ge e le m,
  le ! IFR._t'12 = Some (Vsingle (icqh_f32 (-1882))) ->
  le ! IFR._t'14 = Some (Vsingle (icqh_f32 1)) ->
  le ! IFR._t'15 = Some (Vsingle (icqh_f32 4)) ->
  eval_expr ge e le m
    (icqh_quarter_expression IFR._t'12 IFR._t'14 IFR._t'15)
    (Vsingle (icqh_f32 (-1881))).
Proof.
  intros ge e le m Hx Hnormal Hvelocity.
  pose proof (icqh_quarter_expression_evaluates ge e le m
    IFR._t'12 IFR._t'14 IFR._t'15 (icqh_f32 (-1882))
    (icqh_f32 1) (icqh_f32 4) Hx Hnormal Hvelocity) as Hexpr.
  assert (Float32.add (icqh_f32 (-1882))
    (Float32.mul (icqh_f32 1) (Float32.div (icqh_f32 4) icqh_four)) =
    icqh_f32 (-1881)) as Heq.
  { rewrite <- (Float32.of_to_bits
      (Float32.add (icqh_f32 (-1882))
        (Float32.mul (icqh_f32 1) (Float32.div (icqh_f32 4) icqh_four)))),
      (proj1 icqh_one_unit_quarter_checked), Float32.of_to_bits. reflexivity. }
  rewrite Heq in Hexpr. exact Hexpr.
Qed.

(** Return2 exits this loop on the very first iteration; it does not perform
    three later quarters which might install a different floor. This builds
    an execution of the exact generated gate for every memory. *)
Theorem icqh_result_two_executes_break : forall version ge e le m,
  le ! IFR._stepResult = Some (Vint (Int.repr 2)) ->
  ocn_exec ge e le m (icqh_break_gate version) E0
    (PTree.set IFR._t'2 (Vint Int.one) le) m Out_break.
Proof.
  intros version ge e le m Hresult.
  destruct (icqh_selected_first_quarter_source version) as (_ & _ & _ & Hgate).
  rewrite Hgate. unfold icqh_break_source, icqh_step_eq.
  eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
  - eapply exec_Sifthenelse with (v1 := Vint Int.zero) (b := false).
    + eapply eval_Ebinop.
      * apply eval_Etempvar. exact Hresult.
      * constructor.
      * reflexivity.
    + reflexivity.
    + apply exec_Sset. eapply eval_Ecast.
      * eapply eval_Ebinop.
        -- apply eval_Etempvar. exact Hresult.
        -- constructor.
        -- reflexivity.
      * reflexivity.
  - eapply exec_Sifthenelse with (v1 := Vint Int.one) (b := true).
    + apply eval_Etempvar. apply PTree.gss.
    + reflexivity.
    + constructor.
Qed.

(** A receipt-informed calculation, not an observation inside the quarter:
    using the supplied post-push position, normalY1 and velocity words from
    ink-timer130-crawl-receipt.json gives these binary32 intended coordinates.
    The actual wall calls and persistence of these velocities until the
    quarter remain outside this finite expression/cast certificate. *)
Definition icqh_recorded_quarter_x := Float32.add (icqh_f32 (-1882))
  (Float32.mul (icqh_f32 1)
    (Float32.div (Float32.of_bits (Int.repr 1081808062)) icqh_four)).
Definition icqh_recorded_quarter_z := Float32.add (icqh_f32 (-939))
  (Float32.mul (icqh_f32 1)
    (Float32.div (Float32.of_bits (Int.repr 3209151938)) icqh_four)).
Definition InkCrawlRecordedQuarterCalculation : Prop :=
  Float32.to_bits icqh_recorded_quarter_x = Int.repr 3303743645 /\
  Float32.to_bits icqh_recorded_quarter_z = Int.repr 3295333500 /\
  forall m,
    Cop.sem_cast (Vsingle icqh_recorded_quarter_x) tfloat tshort m =
      Some (Vint (Int.repr (-1881))) /\
    Cop.sem_cast (Vsingle icqh_recorded_quarter_z) tfloat tshort m =
      Some (Vint (Int.repr (-939))).
Theorem icqh_recorded_quarter_calculation_checked : InkCrawlRecordedQuarterCalculation.
Proof. split; [vm_compute; reflexivity|].
  split; [vm_compute; reflexivity|]. intro m. vm_compute. split; reflexivity. Qed.

Definition InkCrawlQuarterSourceBoundary : Prop :=
  (forall version,
    icqh_ceil_query_call version = Scall (Some UEQR_UM._t'1)
      (Evar UEQR_UM._find_ceil (Tfunction
        [tfloat; tfloat; tfloat; tptr (tptr (Tstruct UEQR_UM._Surface noattr))]
        tfloat cc_default))
      [Etempvar UEQR_UM._t'2 tfloat;
       Ebinop Oadd (Etempvar UEQR_UM._height tfloat)
         (Econst_single icqh_eighty tfloat) tfloat;
       Etempvar UEQR_UM._t'3 tfloat;
       Etempvar UEQR_UM._ceil (tptr (tptr (Tstruct UEQR_UM._Surface noattr)))]) /\
  (forall version,
    rank12b_drop_sequences 4 (icqh_x_setup version) =
      Sassign (icqh_intended_coord 0)
        (icqh_quarter_expression IFR._t'12 IFR._t'14 IFR._t'15) /\
    rank12b_drop_sequences 4 (icqh_z_setup version) =
      Sassign (icqh_intended_coord 2)
        (icqh_quarter_expression IFR._t'8 IFR._t'10 IFR._t'11) /\
    icqh_y_setup version = Ssequence
      (Sset IFR._t'7 (ifh_state_coord 1))
      (Sassign (icqh_intended_coord 1) (Etempvar IFR._t'7 tfloat)) /\
    icqh_break_gate version = icqh_break_source) /\
  (forall ge e le m,
    le ! IFR._t'12 = Some (Vsingle (icqh_f32 (-1882))) ->
    le ! IFR._t'14 = Some (Vsingle (icqh_f32 1)) ->
    le ! IFR._t'15 = Some (Vsingle (icqh_f32 4)) ->
    eval_expr ge e le m
      (icqh_quarter_expression IFR._t'12 IFR._t'14 IFR._t'15)
      (Vsingle (icqh_f32 (-1881)))) /\
  InkCrawlRecordedQuarterCalculation.

Theorem icqh_quarter_source_boundary_checked : InkCrawlQuarterSourceBoundary.
Proof.
  split; [exact icqh_selected_ceiling_query_source|].
  split; [exact icqh_selected_first_quarter_source|].
  split; [exact icqh_one_unit_expression_evaluates|].
  exact icqh_recorded_quarter_calculation_checked.
Qed.

Definition InkCrawlQuarterHandoffBoundary : Prop :=
  InkCrawlQuarterPreserves973Cache /\ InkCrawlQuarter973TailExecution /\
  (forall version ge e le m,
    le ! IFR._stepResult = Some (Vint (Int.repr 2)) ->
    ocn_exec ge e le m (icqh_break_gate version) E0
      (PTree.set IFR._t'2 (Vint Int.one) le) m Out_break) /\
  InkCrawlQuarterSourceBoundary.

Theorem icqh_crawl_quarter_handoff_checked : InkCrawlQuarterHandoffBoundary.
Proof.
  split; [exact icqh_973_ceiling_stop_preserves_current_memory|].
  split; [exact icqh_973_ceiling_stop_executes|].
  split; [exact icqh_result_two_executes_break|].
  exact icqh_quarter_source_boundary_checked.
Qed.
