(** Supplied VPU candidate: actual query casts and stopped-quarter tail.
    These are local US/JP Clight claims, not a reachable high crawler, live
    floor traversal, complete Mario update, or Area-2 lifecycle theorem. *)
From Coq Require Import Bool List ZArith.
From compcert Require Import AST Clight ClightBigstep Clightdefs Cop Ctypes
  Events Floats Globalenvs Integers Maps Memory Values.
From LessThanOneAPress.Generated Require Import us_surface_collision jp_surface_collision.
From LessThanOneAPress.Proofs Require Import GameTypes InkCrawlQuarterHandoff
  InkFloorHistorySource InkFloorHistoryExecution InkBackwardSource
  InkBackwardExecution ObjectContactNecessity SelectedClightTarget
  Area2Rank12BContact InkTimer130Geometry.
Import ListNotations.
Local Open Scope Z_scope.
Definition ipv_f32 := icqh_f32.
Lemma ipv_candidate_tests_checked :
  Float32.cmp Cgt (ipv_f32 67277)
    (Float32.add (ipv_f32 1280) ifh_100) = true /\
  Float32.cmp Cge (Float32.add (ipv_f32 67277) ifh_160)
    (ipv_f32 20000) = true /\
  67277 - 768 = 66509.
Proof. vm_compute. repeat split; reflexivity. Qed.

Lemma ipv_high_gap_guard_evaluates : forall ge e le m,
  le ! IFH._t'16 = Some (Vsingle (ipv_f32 67277)) ->
  le ! IFH._floorHeight = Some (Vsingle (ipv_f32 1280)) ->
  eval_expr ge e le m ifh_leave_guard (Vint Int.one).
Proof.
  intros ge e le m Hy Hfloor. unfold ifh_leave_guard.
  eapply eval_Ebinop.
  - apply eval_Etempvar. exact Hy.
  - eapply eval_Ebinop.
    + apply eval_Etempvar. exact Hfloor.
    + constructor.
    + reflexivity.
  - change (Some (Val.of_bool (Float32.cmp Cgt (ipv_f32 67277)
      (Float32.add (ipv_f32 1280) ifh_100))) = Some (Vint Int.one)).
    rewrite (proj1 ipv_candidate_tests_checked). reflexivity.
Qed.

Lemma ipv_ceiling_guard_evaluates : forall ge e le m,
  le ! IFH._t'18 = Some (Vsingle (ipv_f32 67277)) ->
  le ! IFH._ceilHeight = Some (Vsingle (ipv_f32 20000)) ->
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
      (Float32.add (ipv_f32 67277) ifh_160) (ipv_f32 20000))) =
      Some (Vint Int.one)).
    rewrite (proj1 (proj2 ipv_candidate_tests_checked)). reflexivity.
Qed.

Definition ipv_stop_locals le := PTree.set IFH._t'18
  (Vsingle (ipv_f32 67277))
  (PTree.set IFH._t'16 (Vsingle (ipv_f32 67277)) le).

Definition InkVpuQuarterTailExecution : Prop :=
  forall version ge e le m nb no,
  le ! IFH._nextPos = Some (Vptr nb no) ->
  le ! IFH._floorHeight = Some (Vsingle (ipv_f32 1280)) ->
  le ! IFH._ceilHeight = Some (Vsingle (ipv_f32 20000)) ->
  Mem.load Mfloat32 m nb
    (Ptrofs.unsigned (Ptrofs.add no (Ptrofs.repr 4))) =
    Some (Vsingle (ipv_f32 67277)) ->
  ocn_exec ge e le m (ifh_post_water version) E0
    (ipv_stop_locals le) m (ifh_returned 2).

(** Construct the tail execution itself from its ordinary memory/local
    hypotheses. No execution premise, external-call oracle, or axiom is used.
    This still does not construct the preceding live-query prefix. *)
Theorem ipv_vpu_ceiling_stop_executes : InkVpuQuarterTailExecution.
Proof.
  unfold InkVpuQuarterTailExecution.
  intros version ge e le m nb no Hnext Hfloor Hceil Hload.
  assert (ifh_post_water version = Ssequence (ifh_vertical version)
    (Ssequence (ifh_floor_ceil version) (ifh_accept version))) as Hpost
    by (destruct version; reflexivity).
  destruct (ifh_quarter_source_cuts version)
    as (_ & _ & _ & _ & _ & _ & _ & Hvertical & Hleave & _).
  rewrite Hpost, Hvertical, Hleave. unfold ipv_stop_locals.
  eapply exec_Sseq_2; [|discriminate].
  eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
  - apply exec_Sset. eapply icqh_next_y_evaluates; eauto.
  - eapply exec_Sifthenelse with (v1 := Vint Int.one) (b := true).
    + apply ipv_high_gap_guard_evaluates.
      * apply PTree.gss.
      * rewrite PTree.gso by discriminate. exact Hfloor.
    + reflexivity.
    + eapply exec_Sseq_2; [|discriminate].
      eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
      * apply exec_Sset. eapply icqh_next_y_evaluates.
        -- rewrite PTree.gso by discriminate. exact Hnext.
        -- exact Hload.
      * eapply exec_Sifthenelse with (v1 := Vint Int.one) (b := true).
        -- apply ipv_ceiling_guard_evaluates.
           ++ apply PTree.gss.
           ++ repeat rewrite PTree.gso by discriminate. exact Hceil.
        -- reflexivity.
        -- apply exec_Sreturn_some. constructor.
Qed.

Definition InkVpuQuarterMemoryPreservation : Prop :=
  forall version e le m nb no t le' m' out,
  le ! IFH._nextPos = Some (Vptr nb no) ->
  le ! IFH._floorHeight = Some (Vsingle (ipv_f32 1280)) ->
  le ! IFH._ceilHeight = Some (Vsingle (ipv_f32 20000)) ->
  Mem.load Mfloat32 m nb
    (Ptrofs.unsigned (Ptrofs.add no (Ptrofs.repr 4))) =
    Some (Vsingle (ipv_f32 67277)) ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le m
    (ifh_post_water version) t le' m' out ->
  t = E0 /\ m' = m /\ out = ifh_returned 2.

(** Whole-memory preservation includes action, the floor pointer, floorHeight
    768, and movement Y67277 WHEN they hold at this cut. The queried floor1280
    remains a local result: this branch never installs it into MarioState. *)
Theorem ipv_vpu_ceiling_stop_preserves_current_memory :
  InkVpuQuarterMemoryPreservation.
Proof.
  unfold InkVpuQuarterMemoryPreservation.
  intros version e le m nb no t le' m' out Hnext Hfloor Hceil Hload Hrun.
  destruct ipv_candidate_tests_checked as (Hhigh & Hblock & _).
  pose proof (ifh_high_gap_requires_ceiling_block_or_leaves_ground
    version e le m nb no (ipv_f32 67277) (ipv_f32 1280)
    (ipv_f32 20000) t le' m' out Hnext Hfloor Hceil Hload Hhigh Hrun)
    as Hcases.
  destruct Hcases as [(_ & Htrace & Hmemory & Hout)| (Hfalse & _)];
    [repeat split; assumption|congruence].
Qed.


(** The source casts twice to signed short; neither operation writes a
    position. Certify both actual US/JP Y statements, not a substitute
    integer-modulo model. The floor-list traversal remains a separate cut. *)
Module IPV := us_surface_collision.
Definition ipv_query_body version ceiling :=
  match version, ceiling with
  | VersionUS, false => us_surface_collision.f_find_floor
  | VersionUS, true => us_surface_collision.f_find_ceil
  | VersionJP, false => jp_surface_collision.f_find_floor
  | VersionJP, true => jp_surface_collision.f_find_ceil
  end.
Definition ipv_y_input (ceiling : bool) := if ceiling then IPV._posY else IPV._yPos.
Definition ipv_y_statement version ceiling := ibk_head
  (rank12b_drop_sequences 3 (fn_body (ipv_query_body version ceiling))).
Lemma ipv_y_source : forall version ceiling,
  ipv_y_statement version ceiling = Sset IPV._y
    (Ecast (Ecast (Etempvar (ipv_y_input ceiling) tfloat) tshort) tshort).
Proof. intros [] []; reflexivity. Qed.

Definition InkVpuYConversion : Prop := forall version ceiling ge e le m,
  le ! (ipv_y_input ceiling) = Some (Vsingle (ipv_f32 67277)) ->
  ocn_exec ge e le m (ipv_y_statement version ceiling) E0
    (PTree.set IPV._y (Vint (Int.repr 1741)) le) m Out_normal.
Theorem ipv_actual_y_conversion_executes : InkVpuYConversion.
Proof.
  intros version ceiling ge e le m Hy. rewrite ipv_y_source.
  apply exec_Sset. eapply eval_Ecast.
  - eapply eval_Ecast.
    + apply eval_Etempvar. exact Hy.
    + vm_compute. reflexivity.
  - vm_compute. reflexivity.
Qed.

Definition InkPuSampleCasts : Prop := forall m,
  map (fun c => sem_cast (Vsingle (ipv_f32 c)) tfloat tshort m)
    [63586;63654;64597;67277] =
  map (fun c => Some (Vint (Int.repr c))) [-1950;-1882;-939;1741].
Theorem ipv_sample_coordinate_casts_checked : InkPuSampleCasts.
Proof. intro m. vm_compute. reflexivity. Qed.

(** The aliased Y uses the already checked next-phase mesh sample. This
    does not load the dynamic surfaces, contact the warp or construct the
    preceding query results. Those are explicit remaining obligations. *)
Definition InkVpuRetryGeometryConnection : Prop :=
  (forall m, sem_cast (Vsingle (ipv_f32 67277)) tfloat tshort m =
     Some (Vint (Int.repr 1741))) /\ InkTimer130HandoffGeometry.
Theorem ipv_retry_geometry_connection_checked : InkVpuRetryGeometryConnection.
Proof.
  split; [intro m; vm_compute; reflexivity|exact i130_handoff_geometry_checked].
Qed.

Definition InkPuVpuBoundary : Prop :=
  InkVpuQuarterTailExecution /\ InkVpuQuarterMemoryPreservation /\
  InkVpuYConversion /\ InkPuSampleCasts /\ InkVpuRetryGeometryConnection.
Theorem ipv_pu_vpu_boundary_checked : InkPuVpuBoundary.
Proof.
  split; [exact ipv_vpu_ceiling_stop_executes|].
  split; [exact ipv_vpu_ceiling_stop_preserves_current_memory|].
  split; [exact ipv_actual_y_conversion_executes|].
  split; [exact ipv_sample_coordinate_casts_checked|
    exact ipv_retry_geometry_connection_checked].
Qed.
