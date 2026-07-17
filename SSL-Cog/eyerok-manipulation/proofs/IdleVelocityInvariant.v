From Coq Require Import Bool Lia ZArith.

Local Open Scope Z_scope.

(** A source-shaped control model for the velocity that can be inherited by
    [EYEROK_HAND_ACT_IDLE].  Unlike [AuthenticKernel], this model keeps the
    vertical velocity and the parent boss's active-hand/terminal handshake.

    The relation deliberately over-approximates quiet action changes and
    player timing.  Its restrictive premises correspond to the load-bearing
    source conditions audited by [pipeline/audit_eyerok_source.py]:

    - quiet hand actions contain no positive [oVelY] writer;
    - ATTACKED cannot recover until its 25-frame animation has outlasted the
      seven positive -4-gravity movements;
    - DOUBLE_POUND can launch only while the hand owns ActiveHand;
    - the boss can make Unk104 terminal only while ActiveHand is clear; and
    - ActiveHand is cleared only after the selected hand has landed with
      negative gravity and zero bounciness has cleared [oVelY].  The only
      other source clear is in SHOW_EYE under [NumHands != 2], where no sibling
      hand exists; a surviving single-hand DOUBLE_POUND reasserts its own lock
      before testing the terminal and active branches. *)

Inductive idle_velocity_action : Type :=
| IVSleep
| IVIdle
| IVOpen
| IVShowEye
| IVClose
| IVRetreat
| IVTargetMario
| IVSmash
| IVFistPush
| IVFistSweep
| IVBeginDouble
| IVDouble
| IVAttacked
| IVRecover
| IVBecomeActive
| IVDie.

Definition quiet_action (action : idle_velocity_action) : Prop :=
  match action with
  | IVDouble | IVAttacked | IVDie => False
  | _ => True
  end.

Record idle_velocity_state : Type := {
  iv_action : idle_velocity_action;
  iv_velocity_y : Z;
  iv_gravity : Z;
  iv_grounded : bool;
  iv_active_hand_locked : bool;
  iv_double_terminal : bool
}.

Definition iv_initial : idle_velocity_state :=
  {| iv_action := IVSleep;
     iv_velocity_y := 0;
     iv_gravity := 0;
     iv_grounded := false;
     iv_active_hand_locked := false;
     iv_double_terminal := false |}.

Definition iv_set_action
    (action : idle_velocity_action) (state : idle_velocity_state)
    : idle_velocity_state :=
  {| iv_action := action;
     iv_velocity_y := iv_velocity_y state;
     iv_gravity := iv_gravity state;
     iv_grounded := iv_grounded state;
     iv_active_hand_locked := iv_active_hand_locked state;
     iv_double_terminal := iv_double_terminal state |}.

Definition idle_velocity_safe (state : idle_velocity_state) : Prop :=
  (quiet_action (iv_action state) -> iv_velocity_y state <= 0) /\
  (iv_action state = IVDouble -> iv_gravity state = 0 ->
    iv_velocity_y state <= 0) /\
  (iv_action state = IVDouble -> 0 < iv_velocity_y state ->
    iv_active_hand_locked state = true /\
    iv_double_terminal state = false) /\
  (iv_action state = IVDouble -> iv_double_terminal state = true ->
    iv_velocity_y state <= 0).

Inductive idle_velocity_step
    : idle_velocity_state -> idle_velocity_state -> Prop :=
| iv_step_stutter : forall state,
    idle_velocity_step state state
| iv_step_wake_idle : forall before,
    iv_action before = IVSleep ->
    idle_velocity_step before
      {| iv_action := IVIdle;
         iv_velocity_y := iv_velocity_y before;
         iv_gravity := iv_gravity before;
         iv_grounded := iv_grounded before;
         iv_active_hand_locked := iv_active_hand_locked before;
         iv_double_terminal := iv_double_terminal before |}
| iv_step_quiet_action : forall before action,
    quiet_action (iv_action before) ->
    quiet_action action ->
    idle_velocity_step before (iv_set_action action before)
| iv_step_quiet_move : forall before velocity_y,
    quiet_action (iv_action before) ->
    velocity_y <= iv_velocity_y before ->
    idle_velocity_step before
      {| iv_action := iv_action before;
         iv_velocity_y := velocity_y;
         iv_gravity := iv_gravity before;
         iv_grounded := iv_grounded before;
         iv_active_hand_locked := iv_active_hand_locked before;
         iv_double_terminal := iv_double_terminal before |}
| iv_step_idle_begin_double : forall before,
    iv_action before = IVIdle ->
    iv_double_terminal before = false ->
    idle_velocity_step before
      {| iv_action := IVBeginDouble;
         iv_velocity_y := iv_velocity_y before;
         iv_gravity := 0;
         iv_grounded := iv_grounded before;
         iv_active_hand_locked := iv_active_hand_locked before;
         iv_double_terminal := false |}
| iv_step_idle_target_mario : forall before,
    iv_action before = IVIdle ->
    idle_velocity_step before
      {| iv_action := IVTargetMario;
         iv_velocity_y := iv_velocity_y before;
         iv_gravity := 0;
         iv_grounded := iv_grounded before;
         iv_active_hand_locked := iv_active_hand_locked before;
         iv_double_terminal := iv_double_terminal before |}
| iv_step_begin_double : forall before,
    iv_action before = IVBeginDouble ->
    iv_double_terminal before = false ->
    idle_velocity_step before
      {| iv_action := IVDouble;
         iv_velocity_y := iv_velocity_y before;
         iv_gravity := 0;
         iv_grounded := false;
         iv_active_hand_locked := iv_active_hand_locked before;
         iv_double_terminal := false |}
| iv_step_double_first_descent : forall before,
    iv_action before = IVDouble ->
    iv_gravity before = 0 ->
    iv_velocity_y before <= 0 ->
    iv_double_terminal before = false ->
    idle_velocity_step before
      {| iv_action := IVDouble;
         iv_velocity_y := iv_velocity_y before - 20;
         iv_gravity := -20;
         iv_grounded := false;
         iv_active_hand_locked := iv_active_hand_locked before;
         iv_double_terminal := false |}
| iv_step_double_launch : forall before,
    iv_action before = IVDouble ->
    iv_grounded before = true ->
    iv_gravity before <= -15 ->
    iv_active_hand_locked before = true ->
    iv_double_terminal before = false ->
    idle_velocity_step before
      {| iv_action := IVDouble;
         iv_velocity_y := 100 + iv_gravity before;
         iv_gravity := iv_gravity before;
         iv_grounded := false;
         iv_active_hand_locked := true;
         iv_double_terminal := false |}
| iv_step_double_air : forall before,
    iv_action before = IVDouble ->
    0 < iv_velocity_y before ->
    iv_gravity before <= -15 ->
    iv_active_hand_locked before = true ->
    iv_double_terminal before = false ->
    idle_velocity_step before
      {| iv_action := IVDouble;
         iv_velocity_y := iv_velocity_y before + iv_gravity before;
         iv_gravity := iv_gravity before;
         iv_grounded := false;
         iv_active_hand_locked := true;
         iv_double_terminal := false |}
| iv_step_double_land : forall before,
    iv_action before = IVDouble ->
    iv_velocity_y before <= 0 ->
    iv_gravity before < -15 ->
    iv_active_hand_locked before = true ->
    iv_double_terminal before = false ->
    idle_velocity_step before
      {| iv_action := IVDouble;
         iv_velocity_y := 0;
         iv_gravity := iv_gravity before;
         iv_grounded := true;
         iv_active_hand_locked := true;
         iv_double_terminal := false |}
| iv_step_double_release_lock : forall before,
    iv_action before = IVDouble ->
    iv_velocity_y before = 0 ->
    iv_grounded before = true ->
    iv_gravity before < -15 ->
    iv_active_hand_locked before = true ->
    iv_double_terminal before = false ->
    idle_velocity_step before
      {| iv_action := IVDouble;
         iv_velocity_y := 0;
         iv_gravity := -15;
         iv_grounded := true;
         iv_active_hand_locked := false;
         iv_double_terminal := false |}
| iv_step_boss_select : forall before,
    iv_action before = IVDouble ->
    iv_velocity_y before <= 0 ->
    iv_active_hand_locked before = false ->
    iv_double_terminal before = false ->
    idle_velocity_step before
      {| iv_action := IVDouble;
         iv_velocity_y := iv_velocity_y before;
         iv_gravity := iv_gravity before;
         iv_grounded := iv_grounded before;
         iv_active_hand_locked := true;
         iv_double_terminal := false |}
| iv_step_boss_terminal : forall before,
    iv_action before = IVDouble ->
    iv_velocity_y before <= 0 ->
    iv_active_hand_locked before = false ->
    idle_velocity_step before
      {| iv_action := IVDouble;
         iv_velocity_y := iv_velocity_y before;
         iv_gravity := iv_gravity before;
         iv_grounded := iv_grounded before;
         iv_active_hand_locked := false;
         iv_double_terminal := true |}
| iv_step_double_retreat : forall before,
    iv_action before = IVDouble ->
    iv_double_terminal before = true ->
    iv_velocity_y before <= 0 ->
    idle_velocity_step before
      {| iv_action := IVRetreat;
         iv_velocity_y := iv_velocity_y before;
         iv_gravity := iv_gravity before;
         iv_grounded := iv_grounded before;
         iv_active_hand_locked := iv_active_hand_locked before;
         iv_double_terminal := true |}
| iv_step_retreat_idle : forall before,
    iv_action before = IVRetreat ->
    iv_velocity_y before <= 0 ->
    idle_velocity_step before
      {| iv_action := IVIdle;
         iv_velocity_y := iv_velocity_y before;
         iv_gravity := iv_gravity before;
         iv_grounded := iv_grounded before;
         iv_active_hand_locked := false;
         iv_double_terminal := iv_double_terminal before |}
| iv_step_attacked : forall before,
    iv_action before = IVShowEye ->
    idle_velocity_step before
      {| iv_action := IVAttacked;
         iv_velocity_y := 30;
         iv_gravity := -4;
         iv_grounded := false;
         iv_active_hand_locked := iv_active_hand_locked before;
         iv_double_terminal := iv_double_terminal before |}
| iv_step_attacked_move : forall before,
    iv_action before = IVAttacked ->
    idle_velocity_step before
      {| iv_action := IVAttacked;
         iv_velocity_y := iv_velocity_y before - 4;
         iv_gravity := -4;
         iv_grounded := false;
         iv_active_hand_locked := iv_active_hand_locked before;
         iv_double_terminal := iv_double_terminal before |}
| iv_step_attacked_recover : forall before,
    iv_action before = IVAttacked ->
    iv_velocity_y before <= 0 ->
    idle_velocity_step before
      {| iv_action := IVRecover;
         iv_velocity_y := iv_velocity_y before;
         iv_gravity := -4;
         iv_grounded := iv_grounded before;
         iv_active_hand_locked := iv_active_hand_locked before;
         iv_double_terminal := iv_double_terminal before |}
| iv_step_die : forall before,
    iv_action before = IVShowEye ->
    idle_velocity_step before
      {| iv_action := IVDie;
         iv_velocity_y := 50;
         iv_gravity := -4;
         iv_grounded := false;
         iv_active_hand_locked := iv_active_hand_locked before;
         iv_double_terminal := iv_double_terminal before |}
| iv_step_die_move : forall before,
    iv_action before = IVDie ->
    idle_velocity_step before
      {| iv_action := IVDie;
         iv_velocity_y := iv_velocity_y before - 4;
         iv_gravity := -4;
         iv_grounded := false;
         iv_active_hand_locked := iv_active_hand_locked before;
         iv_double_terminal := iv_double_terminal before |}.

Lemma iv_initial_safe : idle_velocity_safe iv_initial.
Proof.
  unfold idle_velocity_safe, iv_initial, quiet_action; cbn.
  repeat split; intros; try discriminate; lia.
Qed.

Theorem idle_velocity_step_preserves_safe : forall before after,
  idle_velocity_safe before ->
  idle_velocity_step before after ->
  idle_velocity_safe after.
Proof.
  intros before after Hsafe Hstep.
  destruct Hsafe as (Hquiet & Hzero & Hpositive & Hterminal).
  destruct Hstep as
      [ state
      | state Hsleep
      | state action Hstate_quiet Haction_quiet
      | state velocity_y Hstate_quiet Hvelocity_y
      | state Hidle Hnonterminal
      | state Hidle
      | state Hbegin Hnonterminal
      | state Hdouble Hgravity Hvelocity Hnonterminal
      | state Hdouble Hgrounded Hgravity Hlocked Hnonterminal
      | state Hdouble Hvelocity Hgravity Hlocked Hnonterminal
      | state Hdouble Hvelocity Hgravity Hlocked Hnonterminal
      | state Hdouble Hvelocity Hgrounded Hgravity Hlocked Hnonterminal
      | state Hdouble Hvelocity Hlocked Hnonterminal
      | state Hdouble Hvelocity Hunlocked
      | state Hdouble Hterminal_state Hvelocity
      | state Hretreat Hvelocity
      | state Hshow_eye
      | state Hattacked
      | state Hattacked Hvelocity
      | state Hshow_eye
      | state Hdie ].
  - unfold idle_velocity_safe in *. tauto.
  - assert (Hv : iv_velocity_y state <= 0).
    { apply Hquiet. rewrite Hsleep. exact I. }
    unfold idle_velocity_safe, quiet_action; cbn.
    repeat split; intros; try discriminate; lia.
  - assert (Hv : iv_velocity_y state <= 0).
    { apply Hquiet. exact Hstate_quiet. }
    destruct action; unfold idle_velocity_safe, quiet_action, iv_set_action;
      cbn in *; repeat split; intros; try discriminate; lia.
  - assert (Hv : iv_velocity_y state <= 0).
    { apply Hquiet. exact Hstate_quiet. }
    destruct (iv_action state); unfold idle_velocity_safe, quiet_action;
      cbn in *; repeat split; intros; try discriminate; lia.
  - assert (Hv : iv_velocity_y state <= 0).
    { apply Hquiet. rewrite Hidle. exact I. }
    unfold idle_velocity_safe, quiet_action; cbn.
    repeat split; intros; try discriminate; lia.
  - assert (Hv : iv_velocity_y state <= 0).
    { apply Hquiet. rewrite Hidle. exact I. }
    unfold idle_velocity_safe, quiet_action; cbn.
    repeat split; intros; try discriminate; lia.
  - assert (Hv : iv_velocity_y state <= 0).
    { apply Hquiet. rewrite Hbegin. exact I. }
    unfold idle_velocity_safe, quiet_action; cbn.
    repeat split; intros; try discriminate; lia.
  - unfold idle_velocity_safe, quiet_action; cbn.
    repeat split; intros; try discriminate; lia.
  - unfold idle_velocity_safe, quiet_action; cbn.
    repeat split; intros; try discriminate; lia.
  - unfold idle_velocity_safe, quiet_action; cbn.
    repeat split; intros; try discriminate; lia.
  - unfold idle_velocity_safe, quiet_action; cbn.
    repeat split; intros; try discriminate; lia.
  - unfold idle_velocity_safe, quiet_action; cbn.
    repeat split; intros; try discriminate; lia.
  - unfold idle_velocity_safe, quiet_action; cbn.
    repeat split; intros; try discriminate; lia.
  - unfold idle_velocity_safe, quiet_action; cbn.
    repeat split; intros; try discriminate; lia.
  - unfold idle_velocity_safe, quiet_action; cbn.
    repeat split; intros; try discriminate; lia.
  - unfold idle_velocity_safe, quiet_action; cbn.
    repeat split; intros; try discriminate; lia.
  - unfold idle_velocity_safe, quiet_action; cbn.
    repeat split; intros; try discriminate; lia.
  - unfold idle_velocity_safe, quiet_action; cbn.
    repeat split; intros; try discriminate; lia.
  - unfold idle_velocity_safe, quiet_action; cbn.
    repeat split; intros; try discriminate; lia.
  - unfold idle_velocity_safe, quiet_action; cbn.
    repeat split; intros; try discriminate; lia.
  - unfold idle_velocity_safe, quiet_action; cbn.
    repeat split; intros; try discriminate; lia.
Qed.

Inductive idle_velocity_reachable : idle_velocity_state -> Prop :=
| iv_reachable_initial : idle_velocity_reachable iv_initial
| iv_reachable_step : forall before after,
    idle_velocity_reachable before ->
    idle_velocity_step before after ->
    idle_velocity_reachable after.

Theorem every_idle_velocity_reachable_state_safe : forall state,
  idle_velocity_reachable state -> idle_velocity_safe state.
Proof.
  intros state Hreach. induction Hreach.
  - exact iv_initial_safe.
  - eapply idle_velocity_step_preserves_safe; eauto.
Qed.

Definition airborne_zero_gravity_positive_seed
    (state : idle_velocity_state) : Prop :=
  iv_action state = IVDouble /\
  iv_grounded state = false /\
  iv_gravity state = 0 /\
  0 < iv_velocity_y state.

Theorem no_reachable_airborne_zero_gravity_positive_seed : forall state,
  idle_velocity_reachable state ->
  ~ airborne_zero_gravity_positive_seed state.
Proof.
  intros state Hreach (Haction & _ & Hgravity & Hpositive).
  destruct (every_idle_velocity_reachable_state_safe state Hreach)
    as (_ & Hzero & _).
  specialize (Hzero Haction Hgravity). lia.
Qed.

Theorem every_reachable_idle_entry_is_nonpositive : forall state,
  idle_velocity_reachable state ->
  iv_action state = IVIdle ->
  iv_velocity_y state <= 0.
Proof.
  intros state Hreach Hidle.
  destruct (every_idle_velocity_reachable_state_safe state Hreach)
    as (Hquiet & _).
  apply Hquiet. rewrite Hidle. exact I.
Qed.

Theorem reachable_positive_double_holds_nonterminal_lock : forall state,
  idle_velocity_reachable state ->
  iv_action state = IVDouble ->
  0 < iv_velocity_y state ->
  iv_active_hand_locked state = true /\
  iv_double_terminal state = false.
Proof.
  intros state Hreach Haction Hvelocity.
  destruct (every_idle_velocity_reachable_state_safe state Hreach)
    as (_ & _ & Hpositive & _).
  exact (Hpositive Haction Hvelocity).
Qed.

Definition attacked_velocity_after (frames : nat) : Z :=
  30 - 4 * Z.of_nat frames.

Lemma attacked_velocity_nonpositive_by_frame_eight :
  attacked_velocity_after 8 <= 0.
Proof. unfold attacked_velocity_after. cbn. lia. Qed.

Definition idle_velocity_invariant_certificate : Prop :=
  (forall state,
      idle_velocity_reachable state ->
      iv_action state = IVIdle ->
      iv_velocity_y state <= 0) /\
  (forall state,
      idle_velocity_reachable state ->
      ~ airborne_zero_gravity_positive_seed state) /\
  (forall state,
      idle_velocity_reachable state ->
      iv_action state = IVDouble ->
      0 < iv_velocity_y state ->
      iv_active_hand_locked state = true /\
      iv_double_terminal state = false) /\
  attacked_velocity_after 8 <= 0.

Theorem idle_velocity_invariant_certificate_holds :
  idle_velocity_invariant_certificate.
Proof.
  unfold idle_velocity_invariant_certificate.
  split.
  - exact every_reachable_idle_entry_is_nonpositive.
  - split.
    + exact no_reachable_airborne_zero_gravity_positive_seed.
    + split.
      * exact reachable_positive_double_holds_nonterminal_lock.
      * exact attacked_velocity_nonpositive_by_frame_eight.
Qed.
