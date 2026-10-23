(* ====================================================================== *)
(* PoleFloat (GOAL 2): the binary32 content of set_pole_position's height *)
(* (mario_actions_automatic.c), for the pole walks' classifier PoleClass. *)
(*                                                                        *)
(*   y0_bound    pos[1] = oPosY + oMarioPolePos + 0.0f on the low pole     *)
(*               (oPosY = -2739, polePos in [-1016, 720]) is in            *)
(*               [-3757, -2018].                                           *)
(*   dec_val     act_holding_pole's slide polePos - (yawVel / 0x100),      *)
(*               yawVel <= 0x1000, is finite and >= -1016.                 *)
(*   ceil_clamp  pos[1] = ceilHeight - 160.0f, taken only when it is below *)
(*               the old pos[1], with ceilHeight a height find_ceil can    *)
(*               return (PoleXc.ceil_ok: 20000 or one that passed          *)
(*               find_ceil_from_list's `y - (h - -78.0f) > 0` test FALSE  *)
(*               at y = (s16)(pos[1] + 80.0f)), is finite and at most 240  *)
(*               below that y.  Infinite or NaN heights are excluded by    *)
(*               the two comparisons themselves.                            *)
(* ====================================================================== *)

From Coq Require Import ZArith Reals Lra Lia.
From compcert Require Import Coqlib Floats Integers Values IEEE754_extra.
From Flocq Require Import Binary Bits Defs Raux Zaux Generic_fmt FLT Float_prop.
From SM64.Proofs Require Import HeightInvariant.
From SM64.Proofs.WMotRRequiresA Require Import HeightFloatSteps FloorList FloorHeight FloorBound AirMatch PoleXc.

Local Open Scope R_scope.
Local Transparent Float32.add Float32.sub Float32.neg Float32.cmp Float32.compare Float32.of_int.

Local Instance prec_gt_0_32' : FLX.Prec_gt_0 24.
Proof. red. lia. Qed.
Local Instance valid_exp_32' : Valid_exp fexp32 := @FLT_exp_valid (-149) 24 prec_gt_0_32'.

(* ---- a float bounds a rounding: no overflow ---- *)
Lemma gen_abs : forall c, generic_format radix2 fexp32 (Rabs (R2 c)).
Proof. intros c. apply generic_format_abs. apply Binary.generic_format_B2R. Qed.

Lemma no_overflow_dom : forall z c, Rabs z <= Rabs (R2 c) ->
  Rlt_bool (Rabs (rnd z)) (bpow radix2 128) = true.
Proof.
  intros z c Hz. apply Rlt_bool_true.
  eapply Rle_lt_trans; [apply rnd_abs_le; [exact (gen_abs c) | apply Rabs_pos | exact Hz] |].
  exact (Binary.abs_B2R_lt_emax 24 128 c).
Qed.

Lemma f32_sub_dom : forall a b c, F32 a = true -> F32 b = true ->
  Rabs (R2 a - R2 b) <= Rabs (R2 c) ->
  R2 (Float32.sub a b) = rnd (R2 a - R2 b) /\ F32 (Float32.sub a b) = true.
Proof.
  intros a b c Fa Fb Hovf. unfold Float32.sub.
  match goal with |- context[Binary.Bminus ?p ?e ?g1 ?g2 ?nan ?md a b] =>
    pose proof (Binary.Bminus_correct p e g1 g2 nan md a b Fa Fb) as HB end.
  rewrite (no_overflow_dom _ c Hovf) in HB.
  destruct HB as (Hval & Hfin & _). split; [ exact Hval | exact Hfin ].
Qed.

(* integers of moderate size are binary32 values *)
Lemma rnd_IZR : forall z, (-16777216 <= z <= 16777216)%Z -> rnd (IZR z) = IZR z.
Proof.
  intros z Hz.
  destruct (of_int_val (Int.repr z)) as (A & _).
  { rewrite Int.signed_repr by (cbn; lia). apply Rabs_le.
    pose proof (IZR_le (-16777216) z ltac:(lia)) as L1. pose proof (IZR_le z 16777216 ltac:(lia)) as L2.
    split; lra. }
  rewrite Int.signed_repr in A by (cbn; lia).
  rewrite <- A. apply rnd_B2R.
Qed.

Lemma rnd_le_int : forall x z, (-16777216 <= z <= 16777216)%Z -> x <= IZR z -> rnd x <= IZR z.
Proof. intros x z Hz H. rewrite <- (rnd_IZR z Hz). apply rnd_mono. exact H. Qed.
Lemma rnd_ge_int : forall x z, (-16777216 <= z <= 16777216)%Z -> IZR z <= x -> IZR z <= rnd x.
Proof. intros x z Hz H. rewrite <- (rnd_IZR z Hz). apply rnd_mono. exact H. Qed.

(* ---- comparisons as reals ---- *)
Lemma cmp_gt_true : forall a b, F32 a = true -> F32 b = true ->
  Float32.cmp Cgt a b = true -> R2 b < R2 a.
Proof.
  intros a b Fa Fb H. unfold Float32.cmp, Float32.compare in H.
  rewrite Binary.Bcompare_correct in H by assumption.
  destruct (Rcompare_spec (R2 a) (R2 b)) as [L | L | L]; cbn in H; try discriminate; lra.
Qed.

Lemma cmp_gt_false : forall a b, F32 a = true -> F32 b = true ->
  Float32.cmp Cgt a b = false -> R2 a <= R2 b.
Proof.
  intros a b Fa Fb H. unfold Float32.cmp, Float32.compare in H.
  rewrite Binary.Bcompare_correct in H by assumption.
  destruct (Rcompare_spec (R2 a) (R2 b)) as [L | L | L]; cbn in H; try discriminate; lra.
Qed.

Lemma cmp_lt_true : forall a b, F32 a = true -> F32 b = true ->
  Float32.cmp Clt a b = true -> R2 a < R2 b.
Proof.
  intros a b Fa Fb H. unfold Float32.cmp, Float32.compare in H.
  rewrite Binary.Bcompare_correct in H by assumption.
  destruct (Rcompare_spec (R2 a) (R2 b)) as [L | L | L]; cbn in H; try discriminate; lra.
Qed.

Lemma cmp_ge_true : forall a b, F32 a = true -> F32 b = true ->
  Float32.cmp Cge a b = true -> R2 b <= R2 a.
Proof.
  intros a b Fa Fb H. unfold Float32.cmp, Float32.compare in H.
  rewrite Binary.Bcompare_correct in H by assumption.
  destruct (Rcompare_spec (R2 a) (R2 b)) as [L | L | L]; cbn in H; try discriminate; lra.
Qed.

Lemma cmp_le_true : forall a b, F32 a = true -> F32 b = true ->
  Float32.cmp Cle a b = true -> R2 a <= R2 b.
Proof.
  intros a b Fa Fb H. unfold Float32.cmp, Float32.compare in H.
  rewrite Binary.Bcompare_correct in H by assumption.
  destruct (Rcompare_spec (R2 a) (R2 b)) as [L | L | L]; cbn in H; try discriminate; lra.
Qed.

(* a float equal to zero is a (signed) zero *)
Lemma ceq_zero : forall z, Float32.cmp Ceq z Float32.zero = true -> F32 z = true /\ R2 z = 0.
Proof.
  intros [s|s|s pl Hpl|s mm e He] H;
    [split; reflexivity | exfalso; destruct s; cbn in H; discriminate H
    | exfalso; cbn in H; discriminate H | exfalso; destruct s; cbn in H; discriminate H].
Qed.

(* a comparison that holds rules out NaN on its right *)
Lemma cmp_true_r_nan : forall a b, Float32.cmp Cgt a b = true -> Binary.is_nan 24 128 b = false.
Proof.
  intros a [s|s|s pl Hpl|s mm e He] H; try reflexivity.
  destruct a as [s'|s'|s' pl' Hpl'|s' mm' e' He']; cbn in H; discriminate H.
Qed.

(* ---- the low pole's start height ---- *)
Lemma y0_bound : forall ka P z, F32 ka = true -> R2 ka = -2739 -> F32 P = true -> -1016 <= R2 P <= 720 ->
  F32 z = true -> R2 z = 0 ->
  F32 (Float32.add (Float32.add ka P) z) = true
  /\ -3757 <= R2 (Float32.add (Float32.add ka P) z) <= -2018.
Proof.
  intros ka P z Fk Rk FP RP Fz Rz.
  destruct (f32_add_val ka P Fk FP) as (A1 & F1).
  { rewrite Rk. eapply Rle_trans; [| apply (bpow_le radix2 12 100); lia]. simpl. apply Rabs_le. lra. }
  rewrite Rk in A1.
  pose proof (rnd_err (-2739 + R2 P) 12 ltac:(lia) ltac:(simpl; apply Rabs_le; lra)) as E1.
  replace (bpow radix2 (12 - 24)) with (/ 4096) in E1 by (simpl; lra).
  rewrite <- A1 in E1. apply Rabs_le_inv in E1.
  set (x := Float32.add ka P) in *.
  destruct (f32_add_val x z F1 Fz) as (A2 & F2).
  { rewrite Rz. eapply Rle_trans; [| apply (bpow_le radix2 12 100); lia]. simpl. apply Rabs_le. lra. }
  rewrite Rz, Rplus_0_r, rnd_B2R in A2.
  split; [exact F2 | rewrite A2; lra].
Qed.

(* ---- act_holding_pole's slide: oMarioPolePos - (yawVel / 0x100) ---- *)
Lemma cmp_pinf_fin : forall k, F32 k = true -> Float32.cmp Cgt (Binary.B754_infinity 24 128 false) k = true.
Proof. intros [s|s|s pl Hpl|s mm e He] H; try discriminate H; destruct s; reflexivity. Qed.

Lemma pos_sign : forall p, F32 p = true -> 0 < R2 p -> Binary.Bsign 24 128 p = false.
Proof.
  intros [s|s|s pl Hpl|s mm e He] F H; try discriminate F.
  - cbn in H. lra.
  - destruct s; [exfalso | reflexivity]. cbn in H.
    assert (F2R (Float radix2 (Z.neg mm) e) < 0) by (apply F2R_lt_0; cbn; lia).
    unfold F2R in *. cbn in *. lra.
Qed.

Lemma dec_val : forall p q k, F32 p = true -> -1000 <= R2 p ->
  (-8388608 <= Int.signed q <= 16)%Z -> F32 k = true -> R2 k <= 720 ->
  Float32.cmp Cgt (Float32.sub p (Float32.of_int q)) k = false ->
  F32 (Float32.sub p (Float32.of_int q)) = true
  /\ -1016 <= R2 (Float32.sub p (Float32.of_int q)) <= 720.
Proof.
  intros p q k Fp Rp Hq Fk Rk G.
  pose proof (IZR_le (-8388608) (Int.signed q) ltac:(lia)) as Q1.
  pose proof (IZR_le (Int.signed q) 16 ltac:(lia)) as Q2.
  destruct (of_int_val q) as (Iv & If); [apply Rabs_le; split; lra |].
  destruct (of_int_val (Int.repr 16777216)) as (Cv & Cf);
    [rewrite Int.signed_repr by (cbn; lia); apply Rabs_le; split; lra |].
  rewrite Int.signed_repr in Cv by (cbn; lia).
  destruct (Rle_or_lt (R2 p) 8000000) as [Small | Big].
  - destruct (f32_sub_dom p (Float32.of_int q) (Float32.of_int (Int.repr 16777216)) Fp If) as (Sv & Sf).
    { rewrite Iv, Cv. rewrite (Rabs_right (IZR 16777216)) by (apply Rle_ge; apply IZR_le; lia).
      apply Rabs_le. split; lra. }
    split; [exact Sf |]. split.
    + rewrite Sv, Iv. apply (rnd_ge_int _ (-1016)); [lia | lra].
    + pose proof (cmp_gt_false _ _ Sf Fk G). lra.
  - exfalso.
    unfold Float32.sub in G.
    match type of G with context[Binary.Bminus ?p0 ?e0 ?g1 ?g2 ?nan ?md p (Float32.of_int q)] =>
      pose proof (Binary.Bminus_correct p0 e0 g1 g2 nan md p (Float32.of_int q) Fp If) as HB end.
    destruct (Rlt_bool _ _).
    + destruct HB as (Hv & Hf & _).
      pose proof (cmp_gt_false _ _ Hf Fk G) as L. rewrite Hv in L.
      assert (rnd (R2 p - R2 (Float32.of_int q)) >= 7999984) by
        (apply Rle_ge; apply (rnd_ge_int _ 7999984); [lia | rewrite Iv; lra]).
      lra.
    + destruct HB as (Ho & _).
      rewrite (pos_sign p Fp ltac:(lra)) in Ho.
      match type of G with context[Binary.Bminus ?p0 ?e0 ?g1 ?g2 ?nan ?md p ?y] =>
        destruct (Binary.Bminus p0 e0 g1 g2 nan md p y) as [s|s|s pl Hpl|s mm e He] eqn:Z end;
        cbn in Ho; try discriminate Ho.
      injection Ho as ->. try rewrite Z in G. rewrite (cmp_pinf_fin k Fk) in G. discriminate G.
Qed.

(* ---- the ceiling clamp ---- *)
Lemma sub_inf : forall s, Float32.sub (Binary.B754_infinity 24 128 s) c160 = Binary.B754_infinity 24 128 s.
Proof. intros []; reflexivity. Qed.

Lemma sub_inf78 : forall s, Float32.sub (Binary.B754_infinity 24 128 s) (Float32.neg c78)
  = Binary.B754_infinity 24 128 s.
Proof. intros []; reflexivity. Qed.

Lemma sub_fin_minf : forall x, F32 x = true ->
  Float32.sub x (Binary.B754_infinity 24 128 true) = Binary.B754_infinity 24 128 false.
Proof. intros [s|s|s pl Hpl|s mm e He] H; try discriminate H; reflexivity. Qed.

Lemma cmp_pinf_zero : Float32.cmp Cgt (Binary.B754_infinity 24 128 false) Float32.zero = true.
Proof. reflexivity. Qed.

Lemma cmp_fin_pinf : forall Y, F32 Y = true -> Float32.cmp Cgt Y (Binary.B754_infinity 24 128 false) = false.
Proof. intros [s|s|s pl Hpl|s mm e He] H; try discriminate H; destruct s; reflexivity. Qed.

Lemma sub_nan : forall s pl H b, Binary.is_nan 24 128 (Float32.sub (Binary.B754_nan 24 128 s pl H) b) = true.
Proof. intros s pl H b. unfold Float32.sub, Binary.Bminus. rewrite is_nan_BSN2B. reflexivity. Qed.

Theorem ceil_clamp : forall Y C yi, F32 Y = true -> R2 Y <= 0 ->
  (-40000 <= Int.signed yi <= -1)%Z ->
  Float32.cmp Cgt (Float32.sub (Float32.of_int yi) (Float32.sub C (Float32.neg c78))) Float32.zero = false ->
  Float32.cmp Cgt Y (Float32.sub C c160) = true ->
  F32 (Float32.sub C c160) = true
  /\ IZR (Int.signed yi) - 240 <= R2 (Float32.sub C c160) < R2 Y.
Proof.
  intros Y C yi FY RY Hyi T G.
  destruct (of_int_val yi) as (Iv & If).
  { pose proof (IZR_le (-16777216) (Int.signed yi) ltac:(lia)). pose proof (IZR_le (Int.signed yi) 16777216 ltac:(lia)). apply Rabs_le. split; lra. }
  (* C is finite *)
  assert (FC : F32 C = true).
  { destruct C as [s|s|s pl Hpl|s mm e He]; try reflexivity; exfalso.
    - destruct s.
      + rewrite sub_inf78, (sub_fin_minf _ If) in T. rewrite cmp_pinf_zero in T. discriminate T.
      + rewrite sub_inf, (cmp_fin_pinf _ FY) in G. discriminate G.
    - pose proof (cmp_true_r_nan _ _ G) as N. rewrite sub_nan in N. discriminate N. }
  destruct (neg_val c78) as (Nv & Nf). rewrite B2R_c78 in Nv. rewrite F32_c78 in Nf.
  set (y := IZR (Int.signed yi)) in *.
  assert (Yr : -40000 <= y <= -1) by (unfold y; pose proof (IZR_le (-40000) (Int.signed yi) ltac:(lia)); pose proof (IZR_le (Int.signed yi) (-1) ltac:(lia)); split; lra).
  (* the test bounds C below *)
  assert (LC : y - 79 <= R2 C).
  { destruct (Rle_or_lt (y - 79) (R2 C)) as [L | L]; [exact L | exfalso].
    destruct (f32_sub_dom C (Float32.neg c78) C FC Nf) as (Av & Af).
    { rewrite Nv. apply Rabs_le. rewrite Rabs_left by lra. lra. }
    rewrite Nv in Av.
    set (a := Float32.sub C (Float32.neg c78)) in *.
    assert (Ra : R2 C <= R2 a <= y - 1).
    { rewrite Av. split.
      - rewrite <- (rnd_B2R C) at 1. apply rnd_mono. lra.
      - replace (y - 1) with (IZR (Int.signed yi - 1)) by (rewrite minus_IZR; reflexivity).
        apply rnd_le_int; [lia | rewrite minus_IZR; fold y; lra]. }
    destruct (f32_sub_dom (Float32.of_int yi) a C If Af) as (Dv & Df).
    { rewrite Iv. fold y. apply Rabs_le. rewrite Rabs_left by lra. lra. }
    rewrite Iv in Dv. fold y in Dv.
    assert (R1 : 1 <= R2 (Float32.sub (Float32.of_int yi) a)).
    { rewrite Dv. apply (rnd_ge_int _ 1); [lia | simpl; lra]. }
    pose proof (cmp_gt_false _ Float32.zero Df eq_refl T) as Z.
    replace (R2 Float32.zero) with 0 in Z by reflexivity. lra. }
  (* C - 160 *)
  destruct (Rle_or_lt (R2 C) 1048576) as [Small | Big].
  - destruct (f32_sub_val C c160 FC F32_c160) as (Sv & Sf).
    { rewrite B2R_c160. eapply Rle_trans; [| apply (bpow_le radix2 21 100); lia].
      simpl. apply Rabs_le. lra. }
    rewrite B2R_c160 in Sv.
    split; [exact Sf |]. split.
    + rewrite Sv. replace (y - 240) with (IZR (Int.signed yi - 240)) by (rewrite minus_IZR; reflexivity).
      apply rnd_ge_int; [lia | rewrite minus_IZR; fold y; lra].
    + exact (cmp_gt_true _ _ FY Sf G).
  - exfalso.
    destruct (f32_sub_dom C c160 C FC F32_c160) as (Sv & Sf).
    { rewrite B2R_c160. apply Rabs_le. rewrite (Rabs_right (R2 C)) by lra. lra. }
    rewrite B2R_c160 in Sv.
    assert (P : 0 < R2 (Float32.sub C c160)).
    { rewrite Sv. apply Rlt_le_trans with 1; [lra |].
      apply (rnd_ge_int _ 1); [lia | simpl; lra]. }
    pose proof (cmp_gt_true _ _ FY Sf G). lra.
Qed.

(* ---- act_climbing_pole's climb: polePos + stickY / 8.0f (2026-10-22) ----
   A finite sum or quotient has finite operands; when finite it is the
   rounding of the real one.  With !(stickY < 8.0f) and the sum finite (the
   path's find_ceil cast), the climb does not lower polePos. *)
Local Transparent Float32.div Float32.to_int.

Lemma add_fin_l : forall x c, F32 c = true -> F32 (Float32.add x c) = true -> F32 x = true.
Proof.
  intros [s|s|s pl Hpl|s m e He] [s'|s'|s' pl' Hpl'|s' m' e' He'] Fc H; try reflexivity; try discriminate Fc;
    unfold Float32.add in H; cbn in H; try destruct s; try destruct s'; cbn in H; discriminate H.
Qed.

Lemma add_fin_r : forall x c, F32 c = true -> F32 (Float32.add c x) = true -> F32 x = true.
Proof.
  intros [s|s|s pl Hpl|s m e He] [s'|s'|s' pl' Hpl'|s' m' e' He'] Fc H; try reflexivity; try discriminate Fc;
    unfold Float32.add in H; cbn in H; try destruct s; try destruct s'; cbn in H; discriminate H.
Qed.

Lemma div_fin_l : forall x c, F32 c = true -> F32 (Float32.div x c) = true -> F32 x = true.
Proof.
  intros [s|s|s pl Hpl|s m e He] [s'|s'|s' pl' Hpl'|s' m' e' He'] Fc H; try reflexivity; try discriminate Fc;
    unfold Float32.div in H; cbn in H; try destruct s; try destruct s'; cbn in H; discriminate H.
Qed.

Lemma add_fin_val : forall a b, F32 a = true -> F32 b = true -> F32 (Float32.add a b) = true ->
  R2 (Float32.add a b) = rnd (R2 a + R2 b).
Proof.
  intros a b Fa Fb F. unfold Float32.add in *.
  match type of F with context[Binary.Bplus ?p ?e ?g1 ?g2 ?nan ?md a b] =>
    pose proof (Binary.Bplus_correct p e g1 g2 nan md a b Fa Fb) as HB end.
  destruct (Rlt_bool _ _).
  - destruct HB as (Hv & _). exact Hv.
  - destruct HB as (Ho & _).
    match type of F with context[Binary.Bplus ?p0 ?e0 ?g1 ?g2 ?nan ?md a b] =>
      destruct (Binary.Bplus p0 e0 g1 g2 nan md a b) as [s|s|s pl Hpl|s mm e He] end;
      cbn in Ho, F; try discriminate F; unfold binary_overflow in Ho;
      simpl in Ho; discriminate Ho.
Qed.

Lemma div_fin_val : forall a b, R2 b <> 0 -> F32 (Float32.div a b) = true ->
  R2 (Float32.div a b) = rnd (R2 a / R2 b).
Proof.
  intros a b Hb F. unfold Float32.div in *.
  match type of F with context[Binary.Bdiv ?p ?e ?g1 ?g2 ?nan ?md a b] =>
    pose proof (Binary.Bdiv_correct p e g1 g2 nan md a b Hb) as HB end.
  destruct (Rlt_bool _ _).
  - destruct HB as (Hv & _). exact Hv.
  - rename HB into Ho.
    match type of F with context[Binary.Bdiv ?p0 ?e0 ?g1 ?g2 ?nan ?md a b] =>
      destruct (Binary.Bdiv p0 e0 g1 g2 nan md a b) as [s|s|s pl Hpl|s mm e He] end;
      cbn in Ho, F; try discriminate F; unfold binary_overflow in Ho;
      simpl in Ho; discriminate Ho.
Qed.

(* a float the s16 cast accepts is finite *)
Lemma to_int_fin : forall f i, Float32.to_int f = Some i -> F32 f = true.
Proof. intros [s|s|s pl Hpl|s m e He] i H; try reflexivity; cbn in H; discriminate H. Qed.

Lemma ycast_fin : forall f i, ycast (Vsingle f) = Vint i -> F32 f = true.
Proof.
  intros f i H. unfold ycast in H. destruct (Float32.to_int f) eqn:T; [| discriminate H].
  exact (to_int_fin _ _ T).
Qed.

Lemma climb_val : forall p s k8, F32 p = true -> F32 k8 = true -> R2 k8 = 8 ->
  Float32.cmp Clt s k8 = false -> F32 (Float32.add p (Float32.div s k8)) = true ->
  R2 p <= R2 (Float32.add p (Float32.div s k8)).
Proof.
  intros p s k8 Fp Fk Rk L F.
  pose proof (add_fin_r _ _ Fp F) as Fq.
  pose proof (div_fin_l _ _ Fk Fq) as Fs.
  pose proof (cmp_lt_false _ _ Fs Fk L) as Ls. rewrite Rk in Ls.
  rewrite (add_fin_val _ _ Fp Fq F), (div_fin_val s k8 ltac:(lra) Fq), Rk.
  rewrite <- (rnd_B2R p) at 1. apply rnd_mono.
  assert (0 <= rnd (R2 s / 8)).
  { rewrite <- rnd_0. apply rnd_mono. unfold Rdiv. apply Rmult_le_pos; lra. }
  lra.
Qed.
