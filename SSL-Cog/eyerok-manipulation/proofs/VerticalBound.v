From Coq Require Import Lia ZArith.
From SSLEyerok.Proofs Require Import Spec StateMachine.

Local Open Scope Z_scope.

Lemma vertical_step_preserves_rank : forall before after,
  vertical_step before after -> state_rank after = state_rank before.
Proof. intros before after Hstep. destruct Hstep; reflexivity. Qed.

Lemma vertically_reachable_rank : forall rank state,
  vertically_reachable rank state -> state_rank state = rank.
Proof.
  intros rank state Hreach.
  induction Hreach.
  - reflexivity.
  - rewrite (vertical_step_preserves_rank before after H).
    exact IHHreach.
Qed.

Theorem every_reachable_hand_below_rank_ceiling : forall rank state,
  vertically_reachable rank state ->
  state_y state <= height_ceiling rank.
Proof.
  intros rank state Hreach.
  pose proof (vertically_reachable_safe rank state Hreach) as Hsafe.
  destruct Hsafe as (_ & Hbudget & Hsum).
  pose proof (vertically_reachable_rank rank state Hreach) as Hrank.
  rewrite <- Hrank.
  lia.
Qed.

Theorem every_reachable_hand_below_global_ceiling : forall rank state,
  vertically_reachable rank state -> state_y state <= global_height_ceiling.
Proof.
  intros rank state Hreach.
  pose proof (every_reachable_hand_below_rank_ceiling rank state Hreach).
  pose proof (height_ceiling_le_global rank).
  lia.
Qed.

Definition vertical_run (rank : hand_rank) (run : nat -> vertical_state) : Prop :=
  run 0%nat = initial_vertical_state rank /\
  forall frame, vertical_step (run frame) (run (S frame)).

Definition rises_unboundedly (run : nat -> vertical_state) : Prop :=
  forall bound, exists frame, bound < state_y (run frame).

Lemma vertical_run_state_reachable : forall rank run frame,
  vertical_run rank run -> vertically_reachable rank (run frame).
Proof.
  intros rank run frame (Hinitial & Hstep).
  induction frame as [| frame IH].
  - rewrite Hinitial. constructor.
  - econstructor; [exact IH | exact (Hstep frame)].
Qed.

Theorem no_safe_vertical_run_rises_unboundedly : forall rank run,
  vertical_run rank run -> ~ rises_unboundedly run.
Proof.
  intros rank run Hrun Hunbounded.
  destruct (Hunbounded global_height_ceiling) as (frame & Hhigher).
  pose proof (vertical_run_state_reachable rank run frame Hrun) as Hreach.
  pose proof (every_reachable_hand_below_global_ceiling rank (run frame) Hreach).
  lia.
Qed.

Fixpoint runaway_height_after (frames : nat) (initial_y : Z) : Z :=
  match frames with
  | O => initial_y
  | S rest => runaway_height_after rest initial_y + runaway_delta
  end.

Theorem runaway_height_formula : forall frames initial_y,
  runaway_height_after frames initial_y =
    initial_y + runaway_delta * Z.of_nat frames.
Proof.
  induction frames as [| frames IH]; intros initial_y; simpl.
  - lia.
  - rewrite IH. unfold runaway_delta. lia.
Qed.

Theorem runaway_lasso_is_unbounded : forall initial_y bound,
  exists frames, bound < runaway_height_after frames initial_y.
Proof.
  intros initial_y bound.
  set (k := Z.max 0 (bound - initial_y) + 1).
  assert (Hk : 0 <= k) by (unfold k; lia).
  exists (Z.to_nat k).
  rewrite runaway_height_formula, Z2Nat.id by exact Hk.
  unfold runaway_delta, k.
  lia.
Qed.
