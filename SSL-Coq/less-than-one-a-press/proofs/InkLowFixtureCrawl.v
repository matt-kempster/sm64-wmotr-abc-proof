(** Lower supplied crawl/push candidates for the original low fixture.

    These sampled heights suffice for the actual stopped-quarter branch,
    while their display retries miss the top in the recorded timer-131
    surface snapshot. The local stop is constructed from post-query reads;
    the finite geometry screen is not a live-memory execution theorem.
    No clean production of the crawling state, actor, or fresh floor768 is
    asserted. Height1423 is a boundary diagnostic: it is not certified as
    keeping the entire crawl hitbox below the preceding timer129 underside. *)
From Coq Require Import Bool List ZArith.
From compcert Require Import AST Clight ClightBigstep Ctypes Events Floats
  Integers Maps Memory Values.
From LessThanOneAPress.Proofs Require Import GameTypes InkCrawlQuarterHandoff
  InkFloorHistorySource InkFloorHistoryExecution InkVerticalLiveSelection
  InkBackwardExecution ObjectContactNecessity SelectedClightTarget.
Import ListNotations.
Local Open Scope Z_scope.

Definition ilfc_heights : list Z := [1381; 1400; 1418; 1423].

Lemma ilfc_sample_tests : forall y, In y ilfc_heights ->
  Float32.cmp Cgt (icqh_f32 y)
    (Float32.add (icqh_f32 1280) ifh_100) = true /\
  Float32.cmp Cge (Float32.add (icqh_f32 y) ifh_160)
    (icqh_f32 1523) = true.
Proof.
  intros y [<-|[<-|[<-|[<-|[]]]]]; vm_compute; split; reflexivity.
Qed.

Lemma ilfc_high_guard : forall ge e le m y,
  le ! IFH._t'16 = Some (Vsingle y) ->
  le ! IFH._floorHeight = Some (Vsingle (icqh_f32 1280)) ->
  Float32.cmp Cgt y (Float32.add (icqh_f32 1280) ifh_100) = true ->
  eval_expr ge e le m ifh_leave_guard (Vint Int.one).
Proof.
  intros ge e le m y Hy Hfloor Htest. unfold ifh_leave_guard.
  eapply eval_Ebinop.
  - apply eval_Etempvar. exact Hy.
  - eapply eval_Ebinop.
    + apply eval_Etempvar. exact Hfloor.
    + constructor.
    + reflexivity.
  - change (Some (Val.of_bool (Float32.cmp Cgt y
      (Float32.add (icqh_f32 1280) ifh_100))) = Some (Vint Int.one)).
    rewrite Htest. reflexivity.
Qed.

Lemma ilfc_ceiling_guard : forall ge e le m y,
  le ! IFH._t'18 = Some (Vsingle y) ->
  le ! IFH._ceilHeight = Some (Vsingle (icqh_f32 1523)) ->
  Float32.cmp Cge (Float32.add y ifh_160) (icqh_f32 1523) = true ->
  eval_expr ge e le m ifh_y_ceil_guard (Vint Int.one).
Proof.
  intros ge e le m y Hy Hceil Htest. unfold ifh_y_ceil_guard.
  eapply eval_Ebinop.
  - eapply eval_Ebinop.
    + apply eval_Etempvar. exact Hy.
    + constructor.
    + reflexivity.
  - apply eval_Etempvar. exact Hceil.
  - change (Some (Val.of_bool (Float32.cmp Cge
      (Float32.add y ifh_160) (icqh_f32 1523))) = Some (Vint Int.one)).
    rewrite Htest. reflexivity.
Qed.

Definition ilfc_stop_locals le y := PTree.set IFH._t'18 (Vsingle (icqh_f32 y))
  (PTree.set IFH._t'16 (Vsingle (icqh_f32 y)) le).

Definition InkLowCrawlTailExecution : Prop :=
  forall version ge e le m nb no y,
  In y ilfc_heights ->
  le ! IFH._nextPos = Some (Vptr nb no) ->
  le ! IFH._floorHeight = Some (Vsingle (icqh_f32 1280)) ->
  le ! IFH._ceilHeight = Some (Vsingle (icqh_f32 1523)) ->
  Mem.load Mfloat32 m nb
    (Ptrofs.unsigned (Ptrofs.add no (Ptrofs.repr 4))) = Some (Vsingle (icqh_f32 y)) ->
  ocn_exec ge e le m (ifh_post_water version) E0
    (ilfc_stop_locals le y) m (ifh_returned 2).

Theorem ilfc_lower_crawl_ceiling_stop_executes : InkLowCrawlTailExecution.
Proof.
  intros version ge e le m nb no y Hin Hnext Hfloor Hceil Hload.
  destruct (ilfc_sample_tests y Hin) as (Hhigh & Hblock).
  assert (ifh_post_water version = Ssequence (ifh_vertical version)
    (Ssequence (ifh_floor_ceil version) (ifh_accept version))) as Hpost
    by (destruct version; reflexivity).
  destruct (ifh_quarter_source_cuts version)
    as (_ & _ & _ & _ & _ & _ & _ & Hvertical & Hleave & _).
  rewrite Hpost, Hvertical, Hleave. unfold ilfc_stop_locals.
  eapply exec_Sseq_2; [|discriminate].
  eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
  - apply exec_Sset. eapply icqh_next_y_evaluates; eauto.
  - eapply exec_Sifthenelse with (v1 := Vint Int.one) (b := true).
    + apply ilfc_high_guard with (y := icqh_f32 y); [apply PTree.gss| |exact Hhigh].
      rewrite PTree.gso by discriminate. exact Hfloor.
    + reflexivity.
    + eapply exec_Sseq_2; [|discriminate].
      eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
      * apply exec_Sset. eapply icqh_next_y_evaluates.
        -- rewrite PTree.gso by discriminate. exact Hnext.
        -- exact Hload.
      * eapply exec_Sifthenelse with (v1 := Vint Int.one) (b := true).
        -- apply ilfc_ceiling_guard with (y := icqh_f32 y); [apply PTree.gss| |exact Hblock].
           repeat rewrite PTree.gso by discriminate. exact Hceil.
        -- reflexivity.
        -- apply exec_Sreturn_some. constructor.
Qed.

Definition InkLowCrawlTailFrame : Prop :=
  forall version e le m nb no y t last after out,
  In y ilfc_heights ->
  le ! IFH._nextPos = Some (Vptr nb no) ->
  le ! IFH._floorHeight = Some (Vsingle (icqh_f32 1280)) ->
  le ! IFH._ceilHeight = Some (Vsingle (icqh_f32 1523)) ->
  Mem.load Mfloat32 m nb
    (Ptrofs.unsigned (Ptrofs.add no (Ptrofs.repr 4))) = Some (Vsingle (icqh_f32 y)) ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le m
    (ifh_post_water version) t last after out ->
  t = E0 /\ after = m /\ out = ifh_returned 2.

Theorem ilfc_lower_crawl_stop_preserves_memory : InkLowCrawlTailFrame.
Proof.
  intros version e le m nb no y t last after out Hin Hnext Hfloor Hceil Hy Hrun.
  destruct (ilfc_sample_tests y Hin) as (Hhigh & Hblock).
  destruct (ifh_high_gap_requires_ceiling_block_or_leaves_ground version e le m
    nb no (icqh_f32 y) (icqh_f32 1280) (icqh_f32 1523) t last after out
    Hnext Hfloor Hceil Hy Hhigh Hrun)
    as [(_ & Ht & Hm & Ho)|(Hfalse & _)]; [auto|congruence].
Qed.

(** This reuses the recorded surface lists at original X/Z(-2200,-1024)
    and scalar expressions extracted from the generated floor search. Their
    installation in live memory is not asserted. The result tuple identifies
    static surface address2149152368, binary32 height bits1151336448 (Y1280),
    and owner0: the roof, not the top's owner. *)
Definition InkLowCrawlSnapshotScreen : Prop := forall version y,
  In y ilfc_heights ->
  ivl_first version 768 ivl_dynamic = None /\
  ivl_first version 768 ivl_static = None /\
  ivl_first version y ivl_dynamic = None /\
  ivl_first version y ivl_static = Some (2149152368, 1151336448, 0).

Theorem ilfc_lower_display_retries_only_static_roof : InkLowCrawlSnapshotScreen.
Proof.
  intros [] y [<-|[<-|[<-|[<-|[]]]]]; vm_compute; repeat split; reflexivity.
Qed.

Definition InkLowFixtureCrawlBoundary : Prop :=
  InkLowCrawlTailExecution /\ InkLowCrawlTailFrame /\ InkLowCrawlSnapshotScreen.

Theorem ilfc_low_fixture_crawl_checked : InkLowFixtureCrawlBoundary.
Proof.
  split; [exact ilfc_lower_crawl_ceiling_stop_executes|].
  split; [exact ilfc_lower_crawl_stop_preserves_memory|
    exact ilfc_lower_display_retries_only_static_roof].
Qed.
