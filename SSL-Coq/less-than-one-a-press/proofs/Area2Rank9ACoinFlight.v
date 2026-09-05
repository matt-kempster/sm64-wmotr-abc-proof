(** Rank 9A: the final Goomba attack and coin flight, not an installer.
    Gameplay glitches remain in scope. In particular an airborne Goomba
    re-jump or a higher selected floor invalidates a single-flight premise;
    it is NOT classified as memory corruption by this file. *)
From Coq Require Import Bool Lia List ZArith Reals Lra.
From Flocq Require Import BinarySingleNaN Binary Core.
From compcert Require Import AST Clight Clightdefs Cop Ctypes Floats
  IEEE754_extra Integers.
From LessThanOneAPress.Generated Require Import us_obj_behaviors_2
  jp_obj_behaviors_2 us_object_helpers jp_object_helpers.
From LessThanOneAPress.Proofs Require Import ASTFacts GameTypes
  Area2Rank9ACoinProducers Area2Rank9ACoinLaunch Area2Rank9AStarGeometry
  EyerokRank15LiveMovement.

Import ListNotations.
Import Clightdefs.ClightNotations.
Local Open Scope Z_scope.
Local Transparent Float32.of_int Float32.add Float32.mul Float32.cmp Float32.compare.

Definition rank9cf_real := B2R 24 128.
Definition rank9cf_finite f := is_finite 24 128 f = true.
Definition rank9cf_round :=
  round radix2 (FLT_exp (3 - 128 - 24) 24) (round_mode mode_NE).
Definition rank9cf_integer z := Float32.of_int (Int.repr z).

Lemma rank9cf_bits_injective : forall x y,
  Float32.to_bits x = Float32.to_bits y -> x = y.
Proof.
  intros x y H. rewrite <- (Float32.of_to_bits x), <- (Float32.of_to_bits y).
  now rewrite H.
Qed.

Lemma rank9cf_integer_exact : forall z,
  -65536 <= z <= 65536 ->
  rank9cf_real (rank9cf_integer z) = IZR z /\
  rank9cf_finite (rank9cf_integer z).
Proof.
  intros z Hz. unfold rank9cf_real, rank9cf_finite, rank9cf_integer,
    Float32.of_int.
  rewrite Int.signed_repr by (change (-2147483648 <= z <= 2147483647); lia).
  pose proof (BofZ_exact 24 128 eq_refl eq_refl z) as H.
  destruct H as [Hr [Hf _]]; [lia | auto].
Qed.

Lemma rank9cf_round_integer : forall z,
  -65536 <= z <= 65536 -> rank9cf_round (IZR z) = IZR z.
Proof.
  intros z Hz. destruct (rank9cf_integer_exact z Hz) as [H _].
  rewrite <- H. unfold rank9cf_round, rank9cf_real.
  apply round_generic.
  - apply valid_rnd_round_mode.
  - apply generic_format_B2R.
Qed.

Lemma rank9cf_round_range : forall lo hi x,
  -65536 <= lo -> hi <= 65536 -> lo <= hi ->
  (IZR lo <= x <= IZR hi)%R ->
  (IZR lo <= rank9cf_round x <= IZR hi)%R.
Proof.
  intros lo hi x Hl Hh Horder Hx. split.
  - rewrite <- (rank9cf_round_integer lo) by lia.
    unfold rank9cf_round. apply round_le;
      [apply FLT_exp_valid; reflexivity | apply valid_rnd_round_mode | lra].
  - rewrite <- (rank9cf_round_integer hi) by lia.
    unfold rank9cf_round. apply round_le;
      [apply FLT_exp_valid; reflexivity | apply valid_rnd_round_mode | lra].
Qed.

Lemma rank9cf_round_no_overflow : forall lo hi x,
  -65536 <= lo -> hi <= 65536 -> lo <= hi ->
  (IZR lo <= x <= IZR hi)%R ->
  (Rabs (rank9cf_round x) < bpow radix2 128)%R.
Proof.
  intros lo hi x Hl Hh Ho Hx.
  pose proof (rank9cf_round_range lo hi x Hl Hh Ho Hx) as Hr.
  assert (Hlo : (-65536 <= IZR lo)%R) by (apply IZR_le; exact Hl).
  assert (Hhi : (IZR hi <= 65536)%R) by (apply IZR_le; exact Hh).
  replace (bpow radix2 128) with (340282366920938463463374607431768211456)%R
    by (unfold bpow; simpl; reflexivity).
  apply Rabs_lt; lra.
Qed.

(** Bounds are on actual binary32 values. Monotone rounding to representable
    INTEGER endpoints avoids assuming translation-invariant float rounding. *)
Lemma rank9cf_add_range : forall x y lo hi,
  rank9cf_finite x -> rank9cf_finite y ->
  -65536 <= lo -> hi <= 65536 -> lo <= hi ->
  (IZR lo <= rank9cf_real x + rank9cf_real y <= IZR hi)%R ->
  rank9cf_finite (Float32.add x y) /\
  (IZR lo <= rank9cf_real (Float32.add x y) <= IZR hi)%R.
Proof.
  intros x y lo hi Fx Fy Hl Hh Ho Hxy.
  pose proof (Bplus_correct 24 128 (eq_refl Datatypes.Lt) (eq_refl Datatypes.Lt) Float32.binop_nan
    mode_NE x y Fx Fy) as H.
  fold rank9cf_round in H.
  rewrite Rlt_bool_true in H by
    (eapply rank9cf_round_no_overflow; eauto).
  destruct H as [Hr [Hf _]]. split; [exact Hf |].
  change (rank9cf_real (Float32.add x y) =
    rank9cf_round (rank9cf_real x + rank9cf_real y)) in Hr.
  rewrite Hr.
  eapply rank9cf_round_range; eauto.
Qed.

Lemma rank9cf_mul_range : forall x y lo hi,
  rank9cf_finite x -> rank9cf_finite y ->
  -65536 <= lo -> hi <= 65536 -> lo <= hi ->
  (IZR lo <= rank9cf_real x * rank9cf_real y <= IZR hi)%R ->
  rank9cf_finite (Float32.mul x y) /\
  (IZR lo <= rank9cf_real (Float32.mul x y) <= IZR hi)%R.
Proof.
  intros x y lo hi Fx Fy Hl Hh Ho Hxy.
  pose proof (Bmult_correct 24 128 (eq_refl Datatypes.Lt) (eq_refl Datatypes.Lt) Float32.binop_nan
    mode_NE x y) as H.
  fold rank9cf_round in H.
  rewrite Rlt_bool_true in H by
    (eapply rank9cf_round_no_overflow; eauto).
  destruct H as [Hr [Hf _]].
  unfold rank9cf_finite in Fx, Fy. rewrite Fx, Fy in Hf.
  split; [exact Hf |].
  change (rank9cf_real (Float32.mul x y) =
    rank9cf_round (rank9cf_real x * rank9cf_real y)) in Hr.
  rewrite Hr.
  eapply rank9cf_round_range; eauto.
Qed.

Theorem rank9cf_every_bounded_random_launch : forall random,
  rank9cf_finite random -> (0 <= rank9cf_real random <= 1)%R ->
  rank9cf_finite (rank9ac_launch_velocity random (rank9cf_integer 20)) /\
  (50 <= rank9cf_real
    (rank9ac_launch_velocity random (rank9cf_integer 20)) <= 60)%R.
Proof.
  intros random Fr Hr.
  destruct (rank9cf_integer_exact 10 ltac:(lia)) as [R10 F10].
  destruct (rank9cf_integer_exact 30 ltac:(lia)) as [R30 F30].
  destruct (rank9cf_integer_exact 20 ltac:(lia)) as [R20 F20].
  assert (H10 : rank9ac_f32 1092616192 = rank9cf_integer 10)
    by (apply rank9cf_bits_injective; vm_compute; reflexivity).
  assert (H30 : rank9ac_f32 1106247680 = rank9cf_integer 30)
    by (apply rank9cf_bits_injective; vm_compute; reflexivity).
  unfold rank9ac_launch_velocity. rewrite H10, H30.
  destruct (rank9cf_mul_range random (rank9cf_integer 10) 0 10
    Fr F10 ltac:(lia) ltac:(lia) ltac:(lia) ltac:(rewrite R10; lra))
    as [Fm Hm].
  destruct (rank9cf_add_range _ (rank9cf_integer 30) 30 40
    Fm F30 ltac:(lia) ltac:(lia) ltac:(lia) ltac:(rewrite R30; lra))
    as [Fa Ha].
  exact (rank9cf_add_range _ (rank9cf_integer 20) 50 60
    Fa F20 ltac:(lia) ltac:(lia) ltac:(lia) ltac:(rewrite R20; lra)).
Qed.

(** The generated Y movement first applies gravity, clamps the fall speed,
    then adds that resulting velocity. The existing linked position theorem
    executes the same Y addition for either a Goomba or its released coin. *)
Definition rank9cf_gravity_fragment version : statement :=
  Ssequence (Sset R9CH._t'16 rank15_current_object_expression)
  (Ssequence (Sset R9CH._t'17 rank15_current_object_expression)
  (Ssequence (Sset R9CH._t'18
    (rank15_raw_float_expression version R9CH._t'17
      (Econst_int (Int.repr 10) tint)))
    (Sassign (rank15_raw_float_expression version R9CH._t'16
      (Econst_int (Int.repr 10) tint))
      (Ebinop Oadd (Etempvar R9CH._t'18 tfloat)
        (Ebinop Oadd (Etempvar R9CH._gravity tfloat)
          (Etempvar R9CH._buoyancy tfloat) tfloat) tfloat)))).

Theorem rank9cf_gravity_prefix_is_generated : forall version,
  exists tail, fn_body (rank15_movement_body version) =
    Ssequence (rank9cf_gravity_fragment version) tail.
Proof. intros []; eexists; reflexivity. Qed.

Definition rank9cf_negative_terminal_expression : expr :=
  Eunop Oneg (Econst_single (rank9ac_f32 1117519872) tfloat) tfloat.

Definition rank9cf_clamp_fragment version : statement :=
  Ssequence (Sset R9CH._t'13 rank15_current_object_expression)
  (Ssequence (Sset R9CH._t'14
    (rank15_raw_float_expression version R9CH._t'13
      (Econst_int (Int.repr 10) tint)))
    (Sifthenelse (Ebinop Olt (Etempvar R9CH._t'14 tfloat)
      rank9cf_negative_terminal_expression tint)
      (Ssequence (Sset R9CH._t'15 rank15_current_object_expression)
        (Sassign (rank15_raw_float_expression version R9CH._t'15
          (Econst_int (Int.repr 10) tint)) rank9cf_negative_terminal_expression))
      Sskip)).

Theorem rank9cf_full_vertical_prefix_is_generated : forall version,
  exists tail, fn_body (rank15_movement_body version) =
    Ssequence (rank9cf_gravity_fragment version)
      (Ssequence (rank9cf_clamp_fragment version)
        (Ssequence (rank15_position_update_fragment version) tail)).
Proof. intros []; eexists; reflexivity. Qed.

Theorem rank9cf_nonwater_constants_checked :
  Float32.to_bits (Float32.add (rank9cf_integer (-4)) Float32.zero) =
    Float32.to_bits (rank9cf_integer (-4)) /\
  Float32.to_bits (Float32.neg (rank9ac_f32 1117519872)) =
    Float32.to_bits (rank9cf_integer (-78)).
Proof. vm_compute. split; reflexivity. Qed.

Definition rank9cf_flight_step (yv : float32 * float32) :=
  let next_v := Float32.add (snd yv) (rank9cf_integer (-4)) in
  let clamped := if Float32.cmp Clt next_v (rank9cf_integer (-78))
    then rank9cf_integer (-78) else next_v in
  (Float32.add (fst yv) clamped, clamped).

Lemma rank9cf_less_false : forall x y,
  rank9cf_finite x -> rank9cf_finite y ->
  Float32.cmp Clt x y = false -> (rank9cf_real y <= rank9cf_real x)%R.
Proof.
  intros x y Fx Fy H. unfold Float32.cmp, Float32.compare in H.
  rewrite (Bcompare_correct 24 128 x y Fx Fy) in H.
  unfold rank9cf_real. destruct (Rcompare_spec (B2R 24 128 x) (B2R 24 128 y));
    simpl in H; try discriminate; lra.
Qed.

Definition rank9cf_rise budget n := 4 * budget * n - 2 * n * (n + 1).
Definition rank9cf_peak budget := 2 * budget * (budget - 1).

Definition rank9cf_envelope origin budget n (yv : float32 * float32) : Prop :=
  0 <= n <= budget /\
  rank9cf_finite (fst yv) /\ rank9cf_finite (snd yv) /\
  (-32768 <= rank9cf_real (fst yv) <= IZR (origin + rank9cf_rise budget n))%R /\
  (-78 <= rank9cf_real (snd yv) <= IZR (4 * (budget - n)))%R.

Lemma rank9cf_rise_bounds : forall budget n,
  1 <= budget <= 15 -> 0 <= n <= budget ->
  0 <= rank9cf_rise budget n <= rank9cf_peak budget /\
  rank9cf_peak budget <= 420.
Proof.
  unfold rank9cf_rise, rank9cf_peak. intros budget n Hb Hn.
  assert (0 <= n * (2 * budget - n - 1)) by nia.
  assert (0 <= (budget - n) * (budget - n - 1)).
  { destruct (Z.eq_dec n budget); [subst; nia | assert (n < budget) by lia; nia]. }
  assert (0 <= (15 - budget) * (budget + 14)) by nia.
  split; nia.
Qed.

Theorem rank9cf_float32_move_preserves_envelope : forall origin budget n y v,
  -16000 <= origin <= 16000 -> 1 <= budget <= 15 ->
  rank9cf_envelope origin budget n (y, v) ->
  (-32768 <= rank9cf_real (fst (rank9cf_flight_step (y, v))))%R ->
  rank9cf_envelope origin budget (Z.min (n + 1) budget)
    (rank9cf_flight_step (y, v)).
Proof.
  intros origin budget n y v Ho Hb (Hn & Fy & Fv & Hy & Hv) Hafter.
  pose proof (rank9cf_rise_bounds budget n Hb Hn) as [Hrise Hpeak].
  destruct (rank9cf_integer_exact (-4) ltac:(lia)) as [Rm4 Fm4].
  destruct (rank9cf_integer_exact (-78) ltac:(lia)) as [Rm78 Fm78].
  assert (Hvu : (rank9cf_real v + rank9cf_real (rank9cf_integer (-4)) <=
      IZR (4 * (budget - n) - 4))%R).
  { rewrite Rm4, minus_IZR. cbn [fst snd] in Hv. lra. }
  destruct (rank9cf_add_range v (rank9cf_integer (-4)) (-82)
    (4 * (budget - n) - 4) Fv Fm4 ltac:(lia) ltac:(lia) ltac:(lia)
    ltac:(split; [rewrite Rm4; cbn [fst snd] in Hv; lra | exact Hvu])) as [Fnext Hnext].
  set (next_v := Float32.add v (rank9cf_integer (-4))) in *.
  set (clamped := if Float32.cmp Clt next_v (rank9cf_integer (-78))
    then rank9cf_integer (-78) else next_v).
  assert (Fc : rank9cf_finite clamped).
  { unfold clamped. destruct (Float32.cmp Clt next_v (rank9cf_integer (-78))); auto. }
  assert (Hc : (-78 <= rank9cf_real clamped <= IZR (4 * (budget - n) - 4))%R).
  { unfold clamped. destruct (Float32.cmp Clt next_v (rank9cf_integer (-78))) eqn:E.
    - rewrite Rm78. split; [lra | apply IZR_le; lia].
    - split; [| exact (proj2 Hnext)].
      pose proof (rank9cf_less_false next_v (rank9cf_integer (-78)) Fnext Fm78 E).
      rewrite Rm78 in H. exact H. }
  assert (Hnextn : 0 <= Z.min (n + 1) budget <= budget) by lia.
  assert (Hcv : (rank9cf_real clamped <=
      IZR (4 * (budget - Z.min (n + 1) budget)))%R).
  { eapply Rle_trans; [exact (proj2 Hc) |]. apply IZR_le. lia. }
  assert (Hs : (rank9cf_real y + rank9cf_real clamped <=
      IZR (origin + rank9cf_rise budget (Z.min (n + 1) budget)))%R).
  { eapply Rle_trans with (IZR (origin + rank9cf_rise budget n) +
      IZR (4 * (budget - n) - 4))%R; [cbn [fst snd] in Hy; lra |].
    rewrite <- plus_IZR. apply IZR_le. unfold rank9cf_rise.
    destruct (Z_lt_ge_dec n budget).
    - rewrite Z.min_l by lia. nia.
    - rewrite Z.min_r by lia. assert (n = budget) by lia. subst. nia. }
  pose proof (rank9cf_rise_bounds budget (Z.min (n + 1) budget) Hb Hnextn)
    as [Hrise' _].
  destruct (rank9cf_add_range y clamped (-32846)
    (origin + rank9cf_rise budget (Z.min (n + 1) budget)) Fy Fc
    ltac:(lia) ltac:(lia) ltac:(lia) ltac:(split; [cbn [fst snd] in Hy; lra | exact Hs]))
    as [Fsum Hsum].
  change (-32768 <= rank9cf_real (Float32.add y clamped))%R in Hafter.
  change (rank9cf_envelope origin budget (Z.min (n + 1) budget)
    (Float32.add y clamped, clamped)).
  unfold rank9cf_envelope; cbn [fst snd]. repeat split; try tauto; try lra; try lia.
Qed.

(** Vertical projection of the checked physics cases. No controller history
    is assumed here. A real trajectory must classify EVERY intervening update:
    a suppressed update preserves Y/V; an air update uses the exact binary32
    recurrence; a support/bounce reset stays below the same chosen ceiling and
    does not exceed the launch envelope. Higher supports and airborne re-jumps
    are explicit departures from this relation, not excluded gameplay. *)
Inductive Rank9CFFlightReach (origin budget : Z) : (float32 * float32) -> Prop :=
| rank9cf_flight_start : forall yv,
    rank9cf_envelope origin budget 0 yv -> Rank9CFFlightReach origin budget yv
| rank9cf_flight_move : forall yv,
    Rank9CFFlightReach origin budget yv ->
    (-32768 <= rank9cf_real (fst (rank9cf_flight_step yv)))%R ->
    Rank9CFFlightReach origin budget (rank9cf_flight_step yv)
| rank9cf_flight_pause : forall yv,
    Rank9CFFlightReach origin budget yv -> Rank9CFFlightReach origin budget yv
| rank9cf_flight_support : forall before after,
    Rank9CFFlightReach origin budget before ->
    rank9cf_envelope origin budget 0 after -> Rank9CFFlightReach origin budget after.

Theorem rank9cf_normal_launch_enters_flight : forall origin y random,
  rank9cf_finite y -> (-32768 <= rank9cf_real y <= IZR origin)%R ->
  rank9cf_finite random -> (0 <= rank9cf_real random <= 1)%R ->
  Rank9CFFlightReach origin 15
    (y, rank9ac_launch_velocity random (rank9cf_integer 20)).
Proof.
  intros origin y random Fy Hy Fr Hr.
  destruct (rank9cf_every_bounded_random_launch random Fr Hr) as [Fv Hv].
  apply rank9cf_flight_start. unfold rank9cf_envelope.
  replace (origin + rank9cf_rise 15 0) with origin by (unfold rank9cf_rise; lia).
  cbn [fst snd]. repeat split; try tauto; try lra; try lia.
Qed.

Lemma rank9cf_flight_has_envelope : forall origin budget yv,
  -16000 <= origin <= 16000 -> 1 <= budget <= 15 ->
  Rank9CFFlightReach origin budget yv ->
  exists n, rank9cf_envelope origin budget n yv.
Proof.
  intros origin budget yv Ho Hb Hreach.
  induction Hreach.
  - exists 0. exact H.
  - destruct IHHreach as [n Henv]. exists (Z.min (n + 1) budget).
    destruct yv as [y v]. eapply rank9cf_float32_move_preserves_envelope; eauto.
  - exact IHHreach.
  - exists 0. exact H.
Qed.

Theorem rank9cf_flight_height_bound : forall origin budget yv,
  -16000 <= origin <= 16000 -> 1 <= budget <= 15 ->
  Rank9CFFlightReach origin budget yv ->
  (rank9cf_real (fst yv) <= IZR (origin + rank9cf_peak budget))%R.
Proof.
  intros origin budget yv Ho Hb Hreach.
  pose proof (rank9cf_flight_has_envelope origin budget yv Ho Hb Hreach) as Henv.
  destruct Henv as [n (Hn & _ & _ & Hy & _)].
  pose proof (rank9cf_rise_bounds budget n Hb Hn) as [Hrise _].
  eapply Rle_trans; [exact (proj2 Hy) |]. apply IZR_le. lia.
Qed.

Definition rank9cf_coin_top (coin : float32 * float32) :=
  rank9cf_real (Float32.add (fst coin) (rank9cf_integer 64)).

Lemma rank9cf_coin_top_bound : forall origin coin,
  -16000 <= origin <= 16000 -> Rank9CFFlightReach origin 15 coin ->
  (rank9cf_coin_top coin <= IZR (origin + 484))%R.
Proof.
  intros origin coin Ho Hc.
  pose proof (rank9cf_flight_height_bound origin 15 coin Ho ltac:(lia) Hc) as Hheight.
  change (rank9cf_real (fst coin) <= IZR (origin + 420))%R in Hheight.
  destruct (rank9cf_flight_has_envelope origin 15 coin Ho ltac:(lia) Hc)
    as [n (_ & Fy & _ & Hy & _)].
  destruct (rank9cf_integer_exact 64 ltac:(lia)) as [R64 F64].
  destruct (rank9cf_add_range (fst coin) (rank9cf_integer 64) (-32704)
    (origin + 484) Fy F64 ltac:(lia) ltac:(lia) ltac:(lia)
    ltac:(rewrite R64; rewrite !plus_IZR in *; lra)) as [_ Htop].
  exact (proj2 Htop).
Qed.

Theorem rank9cf_pauses_do_not_rescue_low_drop : forall coin,
  Rank9CFFlightReach 2907 15 coin ->
  (rank9cf_real (fst coin) <= 3327)%R /\
  (rank9cf_real (fst coin) + 64 < 3505)%R.
Proof.
  intros coin H. pose proof (rank9cf_flight_height_bound 2907 15 coin ltac:(lia) ltac:(lia) H).
  change (rank9cf_real (fst coin) <= 3327)%R in H0. split; lra.
Qed.

(** Audit all direct Y-velocity assignments in the finishing-attack setter,
    rather than merely finding the literals 30 and 50 somewhere in its body. *)
Fixpoint rank9cf_velocity_rhs (body : statement) : list expr := match body with
| Sassign lhs rhs => if expression_is_array_slot R9CH._asF32 10 lhs
    then [rhs] else []
| Ssequence a b | Sloop a b | Sifthenelse _ a b =>
    rank9cf_velocity_rhs a ++ rank9cf_velocity_rhs b
| Sswitch _ cases => rank9cf_velocity_rhs_cases cases
| Slabel _ body => rank9cf_velocity_rhs body
| _ => [] end
with rank9cf_velocity_rhs_cases (cases : labeled_statements) : list expr :=
  match cases with | LSnil => [] | LScons _ body rest =>
    rank9cf_velocity_rhs body ++ rank9cf_velocity_rhs_cases rest end.

Definition rank9cf_knockback_body version := match version with
| VersionUS => us_obj_behaviors_2.f_obj_set_knockback_action
| VersionJP => jp_obj_behaviors_2.f_obj_set_knockback_action end.

Theorem rank9cf_finishing_attack_velocity_census : forall version,
  rank9cf_velocity_rhs (fn_body (rank9cf_knockback_body version)) =
    [Econst_single (rank9ac_f32 1112014848) tfloat;
     Econst_single (rank9ac_f32 1106247680) tfloat] /\
  direct_callees_s (fn_body (rank9cf_knockback_body version)) =
    [us_obj_behaviors_2._obj_angle_to_object] /\
  (forall bits, In bits [1112014848; 1106247680] ->
    rank9cf_finite (rank9ac_f32 bits) /\
    (0 <= rank9cf_real (rank9ac_f32 bits) <= 52)%R).
Proof.
  intros version. split; [destruct version; reflexivity |]. split.
  - destruct version; reflexivity.
  - intros bits [<- | [<- | []]].
    + replace (rank9ac_f32 1112014848) with (rank9cf_integer 50)
        by (apply rank9cf_bits_injective; vm_compute; reflexivity).
      destruct (rank9cf_integer_exact 50 ltac:(lia)) as [Hr Hf].
      split; [exact Hf | rewrite Hr; lra].
    + replace (rank9ac_f32 1106247680) with (rank9cf_integer 30)
        by (apply rank9cf_bits_injective; vm_compute; reflexivity).
      destruct (rank9cf_integer_exact 30 ltac:(lia)) as [Hr Hf].
      split; [exact Hf | rewrite Hr; lra].
Qed.

(** 52 is a deliberately generous replacement for the real 50-or-30 attack
    launch. It yields an integer-aligned 312-unit bound; using the exact 50
    trajectory would tighten this to 288, but is unnecessary for this cut.
    The possible +78 LOOT floor lift is separately exposed, not silently
    inferred for signed-16 aliases or an unexpected moving-floor selection. *)
Theorem rank9cf_defeat_to_coin_seed_bound : forall origin enemy spawn_y,
  -16000 <= origin <= 16000 -> Rank9CFFlightReach origin 13 enemy ->
  (spawn_y <= rank9cf_real (fst enemy) + 78)%R ->
  (spawn_y <= IZR (origin + 390))%R.
Proof.
  intros origin enemy spawn_y Ho He Hs.
  pose proof (rank9cf_flight_height_bound origin 13 enemy Ho ltac:(lia) He) as H.
  change (rank9cf_real (fst enemy) <= IZR (origin + 312))%R in H.
  rewrite !plus_IZR in *. lra.
Qed.

Theorem rank9cf_direct_gate_contact_requires_raised_enemy :
  forall origin coin mario_y,
    -16000 <= origin <= 15610 ->
    Rank9CFFlightReach (origin + 390) 15 coin ->
    (mario_y <= rank9cf_coin_top coin)%R ->
    (mario_y <= IZR (origin + 874))%R /\
    ((3505 <= mario_y)%R -> 2631 <= origin).
Proof.
  intros origin coin mario_y Ho Hc Hm.
  pose proof (rank9cf_coin_top_bound (origin + 390) coin ltac:(lia) Hc) as H.
  assert (Hbound : (mario_y <= IZR (origin + 874))%R).
  { rewrite !plus_IZR in *. lra. }
  split; [exact Hbound |]. intros Hgate.
  assert (2631 <= origin)%Z.
  { apply le_IZR. rewrite plus_IZR in Hbound. lra. }
  exact H0.
Qed.

Theorem rank9cf_spindel_station_needs_extra_height : forall coin mario_y home_y,
  Rank9CFFlightReach 2907 15 coin ->
  (mario_y <= rank9cf_coin_top coin)%R ->
  (3505 <= home_y)%R -> (114 <= home_y - mario_y)%R.
Proof.
  intros coin mario_y home_y Hc Hm Hhome.
  pose proof (rank9cf_coin_top_bound 2907 coin ltac:(lia) Hc) as H.
  change (rank9cf_coin_top coin <= 3391)%R in H. lra.
Qed.

Definition Rank9ACoinFlightBoundary : Prop :=
  (forall version,
    rank9cf_velocity_rhs (fn_body (rank9cf_knockback_body version)) =
      [Econst_single (rank9ac_f32 1112014848) tfloat;
       Econst_single (rank9ac_f32 1106247680) tfloat]) /\
  (forall version, exists tail, fn_body (rank15_movement_body version) =
    Ssequence (rank9cf_gravity_fragment version)
      (Ssequence (rank9cf_clamp_fragment version)
        (Ssequence (rank15_position_update_fragment version) tail))) /\
  (forall random, rank9cf_finite random -> (0 <= rank9cf_real random <= 1)%R ->
    rank9cf_finite (rank9ac_launch_velocity random (rank9cf_integer 20)) /\
    (50 <= rank9cf_real (rank9ac_launch_velocity random (rank9cf_integer 20)) <= 60)%R) /\
  (forall origin y random,
    rank9cf_finite y -> (-32768 <= rank9cf_real y <= IZR origin)%R ->
    rank9cf_finite random -> (0 <= rank9cf_real random <= 1)%R ->
    Rank9CFFlightReach origin 15
      (y, rank9ac_launch_velocity random (rank9cf_integer 20))) /\
  (forall origin budget yv,
    -16000 <= origin <= 16000 -> 1 <= budget <= 15 ->
    Rank9CFFlightReach origin budget yv ->
    (rank9cf_real (fst yv) <= IZR (origin + rank9cf_peak budget))%R) /\
  (forall origin enemy spawn_y,
    -16000 <= origin <= 16000 -> Rank9CFFlightReach origin 13 enemy ->
    (spawn_y <= rank9cf_real (fst enemy) + 78)%R ->
    (spawn_y <= IZR (origin + 390))%R) /\
  (forall origin coin mario_y,
    -16000 <= origin <= 15610 -> Rank9CFFlightReach (origin + 390) 15 coin ->
    (mario_y <= rank9cf_coin_top coin)%R ->
    (mario_y <= IZR (origin + 874))%R /\
    ((3505 <= mario_y)%R -> 2631 <= origin)) /\
  (forall coin mario_y home_y,
    Rank9CFFlightReach 2907 15 coin ->
    (mario_y <= rank9cf_coin_top coin)%R ->
    (3505 <= home_y)%R -> (114 <= home_y - mario_y)%R).

Theorem rank9cf_coin_flight_boundary_checked : Rank9ACoinFlightBoundary.
Proof.
  split.
  - intro version. exact (proj1 (rank9cf_finishing_attack_velocity_census version)).
  - split; [exact rank9cf_full_vertical_prefix_is_generated |].
    split; [exact rank9cf_every_bounded_random_launch |].
    split; [exact rank9cf_normal_launch_enters_flight |].
    split; [exact rank9cf_flight_height_bound |].
    split; [exact rank9cf_defeat_to_coin_seed_bound |].
    split; [exact rank9cf_direct_gate_contact_requires_raised_enemy |
      exact rank9cf_spindel_station_needs_extra_height].
Qed.
