From Coq Require Import Lia ZArith.

Local Open Scope Z_scope.

Definition ssl_area2 : Z := 2.
Definition ssl_area2_min : Z := -8192.
Definition ssl_area2_max : Z := 8191.
Definition first_parallel_universe : Z := 32768.
Definition max_normal_step : Z := 4096.

Record pu_state : Type := {
  state_area : Z;
  state_x : Z;
  state_z : Z
}.

Definition coord_in_area2_bounds (coord : Z) : Prop :=
  ssl_area2_min <= coord <= ssl_area2_max.

Definition state_in_area2_bounds (state : pu_state) : Prop :=
  state_area state = ssl_area2 /\
  coord_in_area2_bounds (state_x state) /\
  coord_in_area2_bounds (state_z state).

Definition parallel_universe_coord (coord : Z) : Prop :=
  first_parallel_universe <= Z.abs coord.

Definition state_in_parallel_universe (state : pu_state) : Prop :=
  parallel_universe_coord (state_x state) \/
  parallel_universe_coord (state_z state).

Definition clamp_area2_coord (value : Z) : Z :=
  if value <? ssl_area2_min then ssl_area2_min
  else if ssl_area2_max <? value then ssl_area2_max
  else value.

Definition clamp_normal_step (delta : Z) : Z :=
  if delta <? -max_normal_step then -max_normal_step
  else if max_normal_step <? delta then max_normal_step
  else delta.

Definition ssl_area2_normal_step
    (state : pu_state) (dx dz : Z) : pu_state :=
  if state_area state =? ssl_area2 then
    {|
      state_area := state_area state;
      state_x :=
        clamp_area2_coord
          (state_x state + clamp_normal_step dx);
      state_z :=
        clamp_area2_coord
          (state_z state + clamp_normal_step dz)
    |}
  else state.

Record ssl_area2_transition_certificate
    (before after : pu_state) (dx dz : Z) : Prop := {
  certificate_before_in_area2 :
    state_in_area2_bounds before;
  certificate_after_is_normal_step :
    after = ssl_area2_normal_step before dx dz
}.

Lemma area2_bound_abs_lt_first_pu :
  forall coord,
    coord_in_area2_bounds coord ->
    Z.abs coord < first_parallel_universe.
Proof.
  intros coord Hbounds.
  unfold coord_in_area2_bounds, ssl_area2_min, ssl_area2_max,
    first_parallel_universe in *.
  assert (Z.abs coord <= 8192).
  { apply Z.abs_le. lia. }
  lia.
Qed.

Theorem area2_bound_not_parallel_universe_coord :
  forall coord,
    coord_in_area2_bounds coord ->
    ~ parallel_universe_coord coord.
Proof.
  intros coord Hbounds Hpu.
  unfold parallel_universe_coord in Hpu.
  pose proof (area2_bound_abs_lt_first_pu coord Hbounds).
  lia.
Qed.

Theorem area2_bounds_not_parallel_universe :
  forall state,
    state_in_area2_bounds state ->
    ~ state_in_parallel_universe state.
Proof.
  intros state (_ & Hx & Hz) [Hpu_x | Hpu_z].
  - exact (area2_bound_not_parallel_universe_coord
      (state_x state) Hx Hpu_x).
  - exact (area2_bound_not_parallel_universe_coord
      (state_z state) Hz Hpu_z).
Qed.

Lemma clamp_area2_coord_in_bounds :
  forall value,
    coord_in_area2_bounds (clamp_area2_coord value).
Proof.
  intros value.
  unfold clamp_area2_coord, coord_in_area2_bounds.
  destruct (value <? ssl_area2_min) eqn:Hmin.
  - apply Z.ltb_lt in Hmin.
    unfold ssl_area2_min, ssl_area2_max in *.
    lia.
  - apply Z.ltb_ge in Hmin.
    destruct (ssl_area2_max <? value) eqn:Hmax.
    + apply Z.ltb_lt in Hmax.
      unfold ssl_area2_min, ssl_area2_max in *.
      lia.
    + apply Z.ltb_ge in Hmax.
      unfold ssl_area2_min, ssl_area2_max in *.
      lia.
Qed.

Theorem normal_step_preserves_area2_bounds :
  forall before dx dz,
    state_in_area2_bounds before ->
    state_in_area2_bounds (ssl_area2_normal_step before dx dz).
Proof.
  intros before dx dz (Harea & _ & _).
  unfold ssl_area2_normal_step.
  rewrite Harea.
  rewrite Z.eqb_refl.
  repeat split; try exact Harea; apply clamp_area2_coord_in_bounds.
Qed.

Theorem certified_transition_preserves_area2_bounds :
  forall before after dx dz,
    ssl_area2_transition_certificate before after dx dz ->
    state_in_area2_bounds after.
Proof.
  intros before after dx dz Hcertificate.
  destruct Hcertificate as [Hbefore Hafter].
  rewrite Hafter.
  exact (normal_step_preserves_area2_bounds before dx dz Hbefore).
Qed.

Theorem certified_transition_forbids_parallel_universe :
  forall before after dx dz,
    ssl_area2_transition_certificate before after dx dz ->
    ~ state_in_parallel_universe after.
Proof.
  intros before after dx dz Hcertificate.
  apply area2_bounds_not_parallel_universe.
  exact (certified_transition_preserves_area2_bounds
    before after dx dz Hcertificate).
Qed.
