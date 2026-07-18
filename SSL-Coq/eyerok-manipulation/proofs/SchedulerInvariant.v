From Coq Require Import Bool Lia ZArith.

Local Open Scope Z_scope.

Inductive scheduler_action : Type :=
| SchedIdle
| SchedBeginDouble
| SchedDouble
| SchedOther.

Record scheduler_state : Type := {
  scheduler_action_of : scheduler_action;
  scheduler_gravity : Z;
  scheduler_grounded : bool
}.

Definition initial_scheduler_state : scheduler_state :=
  {| scheduler_action_of := SchedIdle;
     scheduler_gravity := 0;
     scheduler_grounded := true |}.

Definition scheduler_safe (state : scheduler_state) : Prop :=
  (scheduler_action_of state = SchedDouble ->
   scheduler_gravity state = 0 ->
   scheduler_grounded state = false) /\
  (scheduler_action_of state = SchedDouble ->
   scheduler_grounded state = true ->
   scheduler_gravity state <= -15).

Inductive scheduler_step : scheduler_state -> scheduler_state -> Prop :=
| scheduler_stutter : forall state,
    scheduler_step state state
| scheduler_idle_begin : forall before,
    scheduler_action_of before = SchedIdle ->
    scheduler_step before
      {| scheduler_action_of := SchedBeginDouble;
         scheduler_gravity := 0;
         scheduler_grounded := false |}
| scheduler_begin_double : forall before,
    scheduler_action_of before = SchedBeginDouble ->
    scheduler_grounded before = false ->
    scheduler_step before
      {| scheduler_action_of := SchedDouble;
         scheduler_gravity := 0;
         scheduler_grounded := false |}
| scheduler_first_descent : forall before,
    scheduler_action_of before = SchedDouble ->
    scheduler_gravity before = 0 ->
    scheduler_grounded before = false ->
    scheduler_step before
      {| scheduler_action_of := SchedDouble;
         scheduler_gravity := -20;
         scheduler_grounded := false |}
| scheduler_negative_air : forall before gravity,
    gravity <= -15 ->
    scheduler_step before
      {| scheduler_action_of := SchedDouble;
         scheduler_gravity := gravity;
         scheduler_grounded := false |}
| scheduler_negative_land : forall before gravity,
    gravity <= -15 ->
    scheduler_step before
      {| scheduler_action_of := SchedDouble;
         scheduler_gravity := gravity;
         scheduler_grounded := true |}
| scheduler_pound : forall before,
    scheduler_action_of before = SchedDouble ->
    scheduler_gravity before < -15 ->
    scheduler_grounded before = true ->
    scheduler_step before
      {| scheduler_action_of := SchedDouble;
         scheduler_gravity := -15;
         scheduler_grounded := true |}
| scheduler_safe_launch : forall before,
    scheduler_action_of before = SchedDouble ->
    scheduler_gravity before <= -15 ->
    scheduler_grounded before = true ->
    scheduler_step before
      {| scheduler_action_of := SchedDouble;
         scheduler_gravity := scheduler_gravity before;
         scheduler_grounded := false |}
| scheduler_exit : forall before gravity grounded,
    scheduler_step before
      {| scheduler_action_of := SchedOther;
         scheduler_gravity := gravity;
         scheduler_grounded := grounded |}
| scheduler_normalize : forall before,
    scheduler_action_of before = SchedOther ->
    scheduler_step before initial_scheduler_state.

Lemma initial_scheduler_safe : scheduler_safe initial_scheduler_state.
Proof. split; discriminate. Qed.

Theorem scheduler_step_preserves_safe : forall before after,
  scheduler_safe before -> scheduler_step before after -> scheduler_safe after.
Proof.
  intros before after Hsafe Hstep.
  inversion Hstep; subst; simpl in *.
  - exact Hsafe.
  - split; discriminate.
  - split.
    + intros. reflexivity.
    + intros _ Hground. discriminate.
  - split; intros _ Himpossible; discriminate.
  - split.
    + intros. reflexivity.
    + intros _ Hground. discriminate.
  - split.
    + intros _ Hzero. cbn in Hzero. exfalso. lia.
    + intros. cbn. assumption.
  - split.
    + intros _ Hzero. cbn in Hzero. discriminate.
    + intros. cbn. lia.
  - split.
    + intros. reflexivity.
    + intros _ Hground. discriminate.
  - split; discriminate.
  - exact initial_scheduler_safe.
Qed.

Inductive scheduler_reachable : scheduler_state -> Prop :=
| scheduler_reachable_initial : scheduler_reachable initial_scheduler_state
| scheduler_reachable_step : forall before after,
    scheduler_reachable before ->
    scheduler_step before after ->
    scheduler_reachable after.

Theorem scheduler_reachable_safe : forall state,
  scheduler_reachable state -> scheduler_safe state.
Proof.
  intros state Hreach. induction Hreach.
  - exact initial_scheduler_safe.
  - eapply scheduler_step_preserves_safe; eauto.
Qed.

Definition runaway_seed (state : scheduler_state) : Prop :=
  scheduler_action_of state = SchedDouble /\
  scheduler_grounded state = true /\
  scheduler_gravity state = 0.

Theorem scheduler_safe_excludes_runaway_seed : forall state,
  scheduler_safe state -> ~ runaway_seed state.
Proof.
  intros state (Hzero & _) (Haction & Hground & Hgravity).
  specialize (Hzero Haction Hgravity).
  rewrite Hground in Hzero. discriminate.
Qed.

Theorem reachable_scheduler_excludes_runaway_seed : forall state,
  scheduler_reachable state -> ~ runaway_seed state.
Proof.
  intros state Hreach.
  apply scheduler_safe_excludes_runaway_seed.
  exact (scheduler_reachable_safe state Hreach).
Qed.

Theorem reachable_grounded_double_has_negative_gravity : forall state,
  scheduler_reachable state ->
  scheduler_action_of state = SchedDouble ->
  scheduler_grounded state = true ->
  scheduler_gravity state <= -15.
Proof.
  intros state Hreach Haction Hground.
  destruct (scheduler_reachable_safe state Hreach) as (_ & Hnegative).
  exact (Hnegative Haction Hground).
Qed.
