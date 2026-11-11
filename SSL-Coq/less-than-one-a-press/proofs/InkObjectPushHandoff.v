(** The proposed same-update object push has a real, narrowly useful tail.

    After its wall correction and local destination-floor query, the generated
    helper either commits X/Z or commits nothing.  Its two actual stores leave
    movement Y, the cached floor, action, and the separate Object pool alone.
    This is NOT a frame for the earlier helper calls or an eligible actor/history
    theorem.  In particular the destination floor is a local, not Mario's cache. *)
From Coq Require Import Bool Lia List ZArith.
From compcert Require Import AST Clight ClightBigstep Clightdefs Cop Ctypes
  Events Floats Integers Maps Memory Values.
From LessThanOneAPress.Generated Require Import us_interaction jp_interaction.
From LessThanOneAPress.Proofs Require Import GameTypes InkBackwardSource
  InkBackwardExecution InkCopyEntry InkCopyCaller InkFloorResetExecution InkFloorHistoryQuery
  ObjectContactNecessity ContactConsumerExecution Area2Rank12BContact
  SelectedClightTarget.
Import ListNotations.
Import Clightdefs.ClightNotations.
Local Open Scope Z_scope.

Module IPH := us_interaction.
Definition iph_body version := match version with
| VersionUS => us_interaction.f_push_mario_out_of_object
| VersionJP => jp_interaction.f_push_mario_out_of_object end.
Definition iph_inside version := match rank12b_drop_sequences 4 (fn_body (iph_body version)) with
| Sifthenelse _ yes _ => yes | _ => Sskip end.
Definition iph_tail version := rank12b_drop_sequences 5 (iph_inside version).
Definition iph_commit version := match iph_tail version with
| Ssequence _ (Sifthenelse _ yes _) => yes | _ => Sskip end.
Definition iph_coord n := Ederef (Ebinop Oadd ibcc_destination
  (Econst_int (Int.repr n) tint) (tptr tfloat)) tfloat.
Definition iph_stage n id local := Ssequence (Sset id (Evar local tfloat))
  (Sassign (iph_coord n) (Etempvar id tfloat)).
Definition iph_guard := Ebinop One
  (Etempvar IPH._t'3 (tptr (Tstruct IPH._Surface noattr)))
  (Ecast (Econst_int Int.zero tint) (tptr tvoid)) tint.

Theorem iph_generated_tail : forall version,
  iph_tail version = Ssequence
    (Sset IPH._t'3 (Evar IPH._floor (tptr (Tstruct IPH._Surface noattr))))
    (Sifthenelse iph_guard (iph_commit version) Sskip) /\
  iph_commit version = Ssequence
    (iph_stage 0 IPH._t'5 IPH._newMarioX)
    (iph_stage 2 IPH._t'4 IPH._newMarioZ).
Proof. intros []; split; reflexivity. Qed.

Lemma iph_coord_location : forall version e le m mb n b ofs bf,
  le ! IPH._m = Some (Vptr mb Ptrofs.zero) ->
  eval_lvalue (Clight.globalenv (selected_clight_target version)) e le m
    (iph_coord n) b ofs bf ->
  b = mb /\ ofs = Ptrofs.add (Ptrofs.repr 60)
    (Ptrofs.mul (Ptrofs.repr 4) (ptrofs_of_int Signed (Int.repr n))) /\ bf = Full.
Proof.
  intros version e le m mb n b ofs bf Hm Hl.
  eapply (ifr_array_index_location _ _ _ _ ibcc_destination n mb (Ptrofs.repr 60));
    [reflexivity| |exact Hl].
  intros v Hr. eapply ifr_state_position_value in Hr; [|exact Hm].
  exact Hr.
Qed.

Lemma iph_stage_stores : forall version e le m mb n id local t le' after out,
  id <> IPH._m -> (n = 0 \/ n = 2) ->
  le ! IPH._m = Some (Vptr mb Ptrofs.zero) ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le m
    (iph_stage n id local) t le' after out ->
  exists f, Mem.store Mfloat32 m mb (60 + 4*n) (Vsingle f) = Some after /\
    le' ! IPH._m = Some (Vptr mb Ptrofs.zero) /\ t = E0 /\ out = Out_normal.
Proof.
  intros version e le m mb n id local t le' after out Hid Hn Hm Hrun.
  unfold iph_stage in Hrun.
  destruct (ibk_split_sequence _ _ _ _ (Sset id (Evar local tfloat)) _ _ _ _ _ eq_refl Hrun)
    as (middle & memory & pre & suf & Htrace & Hset & Hwrite).
  inversion Hset; subst; clear Hset.
  inversion Hwrite; subst; clear Hwrite.
  destruct (iph_coord_location version e (PTree.set id v le) memory mb n loc ofs bf
    ltac:(rewrite PTree.gso by congruence; exact Hm) H1) as (-> & -> & ->).
  match goal with Hcast : sem_cast _ _ _ _ = Some _ |- _ =>
    destruct (ifh_float_cast_identity _ _ _ Hcast) as (f & _ & ->) end.
  match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ =>
    inversion Ha; subst; try discriminate end.
  match goal with Hmode : access_mode _ = By_value _ |- _ =>
    cbn in Hmode; inversion Hmode; subst end.
  eexists. repeat apply conj.
  - destruct Hn as [-> | ->]; eassumption.
  - rewrite PTree.gso by congruence. exact Hm.
  - reflexivity.
  - reflexivity.
Qed.

Definition InkObjectPushCommitStores : Prop :=
  forall version e le m mb t le' after out,
  le ! IPH._m = Some (Vptr mb Ptrofs.zero) ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le m
    (iph_commit version) t le' after out ->
  exists x z middle,
    Mem.store Mfloat32 m mb 60 (Vsingle x) = Some middle /\
    Mem.store Mfloat32 middle mb 68 (Vsingle z) = Some after /\
    Mem.load Mfloat32 after mb 60 = Some (Vsingle x) /\
    Mem.load Mfloat32 after mb 68 = Some (Vsingle z) /\
    t = E0 /\ out = Out_normal.

Theorem iph_commit_has_only_the_two_position_stores : InkObjectPushCommitStores.
Proof.
  unfold InkObjectPushCommitStores.
  intros version e le m mb t le' after out Hm Hrun.
  rewrite (proj2 (iph_generated_tail version)) in Hrun.
  destruct (ibk_split_sequence _ _ _ _ (iph_stage 0 IPH._t'5 IPH._newMarioX)
    _ _ _ _ _ eq_refl Hrun)
    as (middle_le & middle & pre & suf & Htrace & Hx & Hz).
  destruct (iph_stage_stores version e le m mb 0 IPH._t'5 IPH._newMarioX _ _ _ _
    ltac:(discriminate) (or_introl eq_refl) Hm Hx)
    as (x & Hsx & Hm' & Htx & Hox).
  destruct (iph_stage_stores version e middle_le middle mb 2 IPH._t'4 IPH._newMarioZ _ _ _ _
    ltac:(discriminate) (or_intror eq_refl) Hm' Hz)
    as (z & Hsz & _ & Htz & Hoz).
  exists x, z, middle. repeat apply conj; try assumption.
  - rewrite (Mem.load_store_other _ _ _ _ _ _ Hsz) by (right; left; cbn; lia).
    exact (Mem.load_store_same _ _ _ _ _ _ Hsx).
  - exact (Mem.load_store_same _ _ _ _ _ _ Hsz).
  - subst; reflexivity.
Qed.

Definition InkObjectPushCommitFrame : Prop :=
  forall version e le m mb ob t le' after out,
  le ! IPH._m = Some (Vptr mb Ptrofs.zero) -> mb <> ob ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le m
    (iph_commit version) t le' after out ->
  Mem.load Mfloat32 after mb 64 = Mem.load Mfloat32 m mb 64 /\
  Mem.load Mint32 after mb 104 = Mem.load Mint32 m mb 104 /\
  Mem.load Mfloat32 after mb 112 = Mem.load Mfloat32 m mb 112 /\
  Mem.load Mint32 after mb 12 = Mem.load Mint32 m mb 12 /\
  (forall chunk offset, Mem.load chunk after ob offset = Mem.load chunk m ob offset).

Theorem iph_commit_preserves_height_cache_action_and_object : InkObjectPushCommitFrame.
Proof.
  unfold InkObjectPushCommitFrame.
  intros version e le m mb ob t le' after out Hm Hsep Hrun.
  destruct (iph_commit_has_only_the_two_position_stores _ _ _ _ _ _ _ _ _ Hm Hrun)
    as (x & z & middle & Hx & Hz & _).
  assert (forall chunk offset,
    (offset + size_chunk chunk <= 60 \/ 72 <= offset \/
      (64 <= offset /\ offset + size_chunk chunk <= 68)) ->
    Mem.load chunk after mb offset = Mem.load chunk m mb offset) as Hframe.
  { intros chunk offset Hrange.
    rewrite (Mem.load_store_other _ _ _ _ _ _ Hz) by (right; cbn; lia).
    rewrite (Mem.load_store_other _ _ _ _ _ _ Hx) by (right; cbn; lia).
    reflexivity. }
  repeat apply conj; try (apply Hframe; cbn; lia).
  intros chunk offset.
  rewrite (Mem.load_store_other _ _ _ _ _ _ Hz) by (left; congruence).
  rewrite (Mem.load_store_other _ _ _ _ _ _ Hx) by (left; congruence).
  reflexivity.
Qed.

Lemma iph_local_floor_read : forall ge e le m fb value answer,
  e ! IPH._floor = Some (fb, tptr (Tstruct IPH._Surface noattr)) ->
  Mem.load Mint32 m fb 0 = Some value ->
  eval_expr ge e le m (Evar IPH._floor (tptr (Tstruct IPH._Surface noattr))) answer ->
  answer = value.
Proof.
  intros ge e le m fb value answer Hlocal Hload Hr.
  inversion Hr; subst.
  match goal with Hl : eval_lvalue _ _ _ _ _ _ _ _ |- _ =>
    destruct (ibc_local_location _ _ _ _ _ _ _ _ _ _ Hlocal Hl) as (-> & -> & ->) end.
  match goal with Hd : deref_loc _ _ _ _ _ _ |- _ =>
    inversion Hd; subst; try discriminate end.
  match goal with Hmode : access_mode _ = By_value _ |- _ =>
    cbn in Hmode; inversion Hmode; subst end.
  match goal with Hread : Mem.loadv _ _ _ = Some answer |- _ =>
    change (Mem.load Mint32 m fb 0 = Some answer) in Hread; congruence end.
Qed.

Lemma iph_null_disables_commit : forall ge e le m answer,
  le ! IPH._t'3 = Some (Vint Int.zero) ->
  eval_expr ge e le m iph_guard answer -> answer = Vint Int.zero.
Proof.
  intros ge e le m Hanswer Htemp Hr.
  unfold iph_guard in Hr. inversion Hr; subst.
  2: match goal with Hb : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ => inversion Hb end.
  match goal with Hread : eval_expr _ _ _ _ (Etempvar _ _) ?v |- _ =>
    assert (v = Vint Int.zero) by (eapply ocn_temp_value; eauto); subst v end.
  match goal with Hcast : eval_expr _ _ _ _ (Ecast _ _) _ |- _ =>
    apply cce_cast_zero_value in Hcast; subst end.
  match goal with Hsem : sem_binary_operation _ _ _ _ _ _ _ = Some Hanswer |- _ =>
    change (Some (Vint Int.zero) = Some Hanswer) in Hsem; congruence end.
Qed.

(** A missing floor at the HIGH destination prevents this push's commit.
    This says nothing about a LOW query at the same X/Z on the next update. *)
Definition InkObjectPushNullDestination : Prop :=
  forall version ge e le m fb t le' after out,
  e ! IPH._floor = Some (fb, tptr (Tstruct IPH._Surface noattr)) ->
  Mem.load Mint32 m fb 0 = Some (Vint Int.zero) ->
  ocn_exec ge e le m (iph_tail version) t le' after out ->
  after = m /\ t = E0 /\ out = Out_normal.

Theorem iph_null_destination_commits_nothing : InkObjectPushNullDestination.
Proof.
  unfold InkObjectPushNullDestination.
  intros version ge e le m fb t le' after out Hlocal Hload Hrun.
  rewrite (proj1 (iph_generated_tail version)) in Hrun.
  destruct (ibk_split_sequence _ _ _ _
    (Sset IPH._t'3 (Evar IPH._floor (tptr (Tstruct IPH._Surface noattr))))
    _ _ _ _ _ eq_refl Hrun)
    as (middle & memory & pre & suf & Htrace & Hread & Hbranch).
  inversion Hread; subst; clear Hread.
  match goal with Hr : eval_expr _ _ _ _ (Evar IPH._floor _) ?v |- _ =>
    assert (v = Vint Int.zero) by (eapply iph_local_floor_read; eauto); subst v end.
  inversion Hbranch; subst; clear Hbranch.
  match goal with Hr : eval_expr _ _ _ _ iph_guard ?v |- _ =>
    assert (v = Vint Int.zero) by (eapply iph_null_disables_commit;
      [apply PTree.gss|exact Hr]); subst v end.
  match goal with Hb : bool_val (Vint Int.zero) _ _ = Some ?b |- _ =>
    change (Some false = Some b) in Hb; inversion Hb; subst end.
  cbn beta iota in *.
  match goal with Hr : ClightBigstep.exec_stmt _ _ _ _ _ Sskip _ _ _ _ |- _ =>
    inversion Hr; subst end.
  repeat split; reflexivity.
Qed.

Definition InkObjectPushHandoffBoundary : Prop :=
  InkObjectPushCommitStores /\ InkObjectPushCommitFrame /\ InkObjectPushNullDestination.

Theorem iph_object_push_handoff_checked : InkObjectPushHandoffBoundary.
Proof.
  split; [exact iph_commit_has_only_the_two_position_stores|].
  split; [exact iph_commit_preserves_height_cache_action_and_object|
    exact iph_null_destination_commits_nothing].
Qed.
