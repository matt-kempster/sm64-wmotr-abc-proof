From Coq Require Import Lia List ZArith.
From SSLPoleBypass.Proofs Require Import PoleArithmetic Spec.

Import ListNotations.
Local Open Scope Z_scope.

Inductive route_event : Type := HoldOrClimb | NonAExit | APress | AirTick.

Definition event_a_cost (event : route_event) : nat :=
  match event with APress => 1%nat | _ => 0%nat end.

Fixpoint a_count (trace : list route_event) : nat :=
  match trace with
  | [] => 0%nat
  | event :: rest => (event_a_cost event + a_count rest)%nat
  end.

Inductive route_state : Type :=
| NormalizedPole
| SoftBonk (frames : Z)
| PoleJump (frames : Z)
| SixthFloor.

Inductive route_step : route_state -> route_event -> route_state -> Prop :=
| step_hold_or_climb : route_step NormalizedPole HoldOrClimb NormalizedPole
| step_non_a_exit : route_step NormalizedPole NonAExit (SoftBonk 0)
| step_a_exit : route_step NormalizedPole APress (PoleJump 0)
| step_soft_air : forall frames, 0 <= frames ->
    route_step (SoftBonk frames) AirTick (SoftBonk (frames + 1))
| step_soft_floor : forall frames, 0 <= frames -> soft_clearable frames ->
    route_step (SoftBonk frames) AirTick SixthFloor
| step_jump_air : forall frames, 0 <= frames ->
    route_step (PoleJump frames) AirTick (PoleJump (frames + 1))
| step_jump_floor : forall frames, 0 <= frames -> jump_landing_window frames ->
    route_step (PoleJump frames) AirTick SixthFloor.

Inductive executes : route_state -> list route_event -> route_state -> Prop :=
| executes_nil : forall state, executes state [] state
| executes_cons : forall before event middle rest after,
    route_step before event middle -> executes middle rest after ->
    executes before (event :: rest) after.

Definition unpowered (state : route_state) : Prop :=
  match state with
  | NormalizedPole | SoftBonk _ => True
  | PoleJump _ | SixthFloor => False
  end.

Lemma zero_cost_step_preserves_unpowered :
  forall before event after, route_step before event after ->
    event_a_cost event = 0%nat -> unpowered before -> unpowered after.
Proof.
  intros before event after Hstep Hcost Hunpowered.
  destruct Hstep; simpl in *; try contradiction; try exact I.
  - discriminate.
  - exfalso. exact (soft_bonk_never_clearable frames H H0).
Qed.

Lemma zero_a_execution_preserves_unpowered :
  forall before trace after, executes before trace after ->
    a_count trace = 0%nat -> unpowered before -> unpowered after.
Proof.
  intros before trace after Hexec.
  induction Hexec as [state | before event middle rest after Hstep Hrest IH];
    intros Hcount Hunpowered.
  - exact Hunpowered.
  - simpl in Hcount.
    assert (Hevent : event_a_cost event = 0%nat) by lia.
    assert (Hrest_count : a_count rest = 0%nat) by lia.
    apply IH; try exact Hrest_count.
    eapply zero_cost_step_preserves_unpowered; eauto.
Qed.

Theorem zero_a_cannot_reach_sixth :
  forall trace, executes NormalizedPole trace SixthFloor -> a_count trace <> 0%nat.
Proof.
  intros trace Hexec Hzero.
  pose proof (zero_a_execution_preserves_unpowered
    NormalizedPole trace SixthFloor Hexec Hzero I) as Hfalse.
  exact Hfalse.
Qed.

Theorem every_pole_route_uses_a :
  forall trace, executes NormalizedPole trace SixthFloor -> (1 <= a_count trace)%nat.
Proof. intros trace Hexec; pose proof (zero_a_cannot_reach_sixth trace Hexec); lia. Qed.

Lemma executes_app : forall before first middle second after,
  executes before first middle -> executes middle second after ->
  executes before (first ++ second) after.
Proof.
  intros before first middle second after Hfirst Hsecond.
  induction Hfirst; [exact Hsecond | simpl; econstructor; eauto].
Qed.

Lemma jump_ticks : forall count frames, 0 <= frames ->
  executes (PoleJump frames) (repeat AirTick count)
    (PoleJump (frames + Z.of_nat count)).
Proof.
  induction count as [| count IH]; intros frames Hframes.
  - simpl. replace (frames + 0) with frames by lia. constructor.
  - simpl. econstructor.
    + apply step_jump_air; exact Hframes.
    + assert (Hnext : 0 <= frames + 1) by lia.
      specialize (IH (frames + 1) Hnext).
      replace (frames + Z.pos (Pos.of_succ_nat count))
        with ((frames + 1) + Z.of_nat count) by lia.
      exact IH.
Qed.

Definition one_a_trace : list route_event :=
  HoldOrClimb :: APress :: (repeat AirTick 33 ++ [AirTick]).

Lemma one_a_trace_executes : executes NormalizedPole one_a_trace SixthFloor.
Proof.
  unfold one_a_trace.
  econstructor; [apply step_hold_or_climb |].
  econstructor; [apply step_a_exit |].
  eapply executes_app with (middle := PoleJump 33).
  - replace 33 with (0 + Z.of_nat 33) by reflexivity.
    apply jump_ticks; lia.
  - simpl. econstructor.
    + apply step_jump_floor; try lia. exact jump_landing_certificate.
    + constructor.
Qed.

Lemma one_a_trace_count : a_count one_a_trace = 1%nat.
Proof. vm_compute; reflexivity. Qed.

Theorem closed_world_pole_route_minimum_a_is_one :
  (forall trace, executes NormalizedPole trace SixthFloor ->
      (1 <= a_count trace)%nat) /\
  exists trace, executes NormalizedPole trace SixthFloor /\ a_count trace = 1%nat.
Proof.
  split; [exact every_pole_route_uses_a |].
  exists one_a_trace; split; [exact one_a_trace_executes | exact one_a_trace_count].
Qed.
