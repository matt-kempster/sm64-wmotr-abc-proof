From Coq Require Import Lia ZArith.
From SSLEyerok.Proofs Require Import Spec.

Local Open Scope Z_scope.

Record vertical_state : Type := {
  state_rank : hand_rank;
  state_mode : vertical_mode;
  state_y : Z;
  state_budget : Z
}.

Definition initial_vertical_state (rank : hand_rank) : vertical_state :=
  {| state_rank := rank;
     state_mode := Controlled;
     state_y := eyerok_home_y;
     state_budget := 0 |}.

Definition safe_envelope (state : vertical_state) : Prop :=
  state_mode state <> Runaway /\
  0 <= state_budget state <= upward_travel_max /\
  state_y state + state_budget state <= height_ceiling (state_rank state).

Inductive vertical_step : vertical_state -> vertical_state -> Prop :=
| step_controlled_position : forall before target,
    target <= direct_position_y_max ->
    vertical_step before
      {| state_rank := state_rank before;
         state_mode := Controlled;
         state_y := target;
         state_budget := 0 |}
| step_land : forall before floor_y,
    floor_y <= support_ceiling (state_rank before) ->
    vertical_step before
      {| state_rank := state_rank before;
         state_mode := Controlled;
         state_y := floor_y;
         state_budget := 0 |}
| step_launch : forall before budget,
    state_y before <= support_ceiling (state_rank before) ->
    0 <= budget <= upward_travel_max ->
    vertical_step before
      {| state_rank := state_rank before;
         state_mode := Ballistic;
         state_y := state_y before;
         state_budget := budget |}
| step_rise : forall before delta,
    state_mode before = Ballistic ->
    0 <= delta <= state_budget before ->
    vertical_step before
      {| state_rank := state_rank before;
         state_mode := Ballistic;
         state_y := state_y before + delta;
         state_budget := state_budget before - delta |}
| step_nonrise : forall before next_y,
    next_y <= state_y before ->
    vertical_step before
      {| state_rank := state_rank before;
         state_mode := state_mode before;
         state_y := next_y;
         state_budget := state_budget before |}
| step_partial_update : forall state,
    vertical_step state state
| step_delete : forall before,
    vertical_step before
      {| state_rank := state_rank before;
         state_mode := Deleted;
         state_y := state_y before;
         state_budget := 0 |}.

Lemma initial_vertical_state_safe : forall rank,
  safe_envelope (initial_vertical_state rank).
Proof.
  intros rank. destruct rank; repeat split; simpl; try discriminate; lia.
Qed.

Theorem vertical_step_preserves_safe : forall before after,
  safe_envelope before -> vertical_step before after -> safe_envelope after.
Proof.
  intros before after Hsafe Hstep.
  destruct Hsafe as (Hmode & Hbudget & Hsum).
  destruct Hstep; simpl in *.
  - split; [discriminate |]. split.
    + split; [apply Z.le_refl | exact upward_travel_max_nonnegative].
    + destruct (state_rank before); cbv [direct_position_y_max height_ceiling
        support_ceiling upward_travel_max area3_upward_floor_y_max] in *; cbn; lia.
  - split; [discriminate |]. split.
    + split; [apply Z.le_refl | exact upward_travel_max_nonnegative].
    + destruct (state_rank before); cbv [height_ceiling support_ceiling
        upward_travel_max area3_upward_floor_y_max] in *; cbn; lia.
  - split; [discriminate |]. split; [exact H0 |].
    destruct (state_rank before); cbv [height_ceiling support_ceiling
      upward_travel_max area3_upward_floor_y_max] in *; cbn; lia.
  - cbn. split; [discriminate |]. split.
    + split.
      * change (0 <= state_budget before - delta). lia.
      * change (state_budget before - delta <= upward_travel_max). lia.
    + change (state_y before + delta + (state_budget before - delta) <=
        height_ceiling (state_rank before)). lia.
  - cbn. split; [exact Hmode |]. split; [exact Hbudget |].
    change (next_y + state_budget before <= height_ceiling (state_rank before)).
    lia.
  - exact (conj Hmode (conj Hbudget Hsum)).
  - cbn. split; [discriminate |]. split.
    + split; [apply Z.le_refl | exact upward_travel_max_nonnegative].
    + change (state_y before + 0 <= height_ceiling (state_rank before)). lia.
Qed.

Inductive vertically_reachable (rank : hand_rank) : vertical_state -> Prop :=
| vertical_reachable_initial :
    vertically_reachable rank (initial_vertical_state rank)
| vertical_reachable_step : forall before after,
    vertically_reachable rank before ->
    vertical_step before after ->
    vertically_reachable rank after.

Theorem vertically_reachable_safe : forall rank state,
  vertically_reachable rank state -> safe_envelope state.
Proof.
  intros rank state Hreach.
  induction Hreach.
  - apply initial_vertical_state_safe.
  - eapply vertical_step_preserves_safe; eauto.
Qed.
