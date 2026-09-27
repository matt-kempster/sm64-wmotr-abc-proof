(* ======================================================================= *)
(* GOAL 2: the ballistic arm of the height frame moves (binary32).         *)
(*                                                                          *)
(* One no-collision air frame, in binary32, does not raise Phi's budget     *)
(* quantity  y + bal_g(v)  (HeightPhi.bal: energy + EPS per ascent frame).  *)
(* The frame is the real sequence of operations                             *)
(*   perform_air_step (mario_step.c:618-623), 4 times:                      *)
(*       intendedPos[1] = m->pos[1] + m->vel[1] / 4.0f;  pos := intended    *)
(*   apply_gravity (mario_step.c:543-548 for g = 2, :575-579 for g = 4):    *)
(*       m->vel[1] -= g;  if (m->vel[1] < -75.0f) m->vel[1] = -75.0f;       *)
(* transcribed as Float32 operations below.  That the generated Clight      *)
(* computes exactly these values is the T3 value walk's job; this file is   *)
(* the arithmetic that walk will consume.                                   *)
(*                                                                          *)
(* Consumed by HeightMove.v (Phi_of_move, the air-step constructors).      *)
(* ======================================================================= *)

From Coq Require Import ZArith Reals Lra Lia.
From compcert Require Import Floats Integers.
From Flocq Require Import Binary Bits Defs Raux Zaux Generic_fmt FLT Ulp Round_NE.
From Flocq Require Import BinarySingleNaN.
From SM64.Proofs Require Import HeightPhi.

Local Open Scope R_scope.

Notation fexp32 := (SpecFloat.fexp 24 128).
Notation rnd := (round radix2 fexp32 (round_mode mode_NE)).

Local Instance prec_gt_0_32 : FLX.Prec_gt_0 24.
Proof. red. lia. Qed.
Local Instance valid_exp_32 : Valid_exp fexp32 :=
  @FLT_exp_valid (-149) 24 prec_gt_0_32.
Local Instance mono_exp_32 : Monotone_exp fexp32 := FLT_exp_monotone (-149) 24.

Local Transparent Float32.add Float32.sub Float32.div Float32.cmp Float32.compare.

(* ----------------------------------------------------------------------- *)
(* 1. Rounding facts.                                                       *)
(* ----------------------------------------------------------------------- *)

(* |x| <= 2^e  ==>  round-to-nearest moves x by at most 2^(e-24) *)
Lemma rnd_err : forall x e, (-120 <= e)%Z ->
  Rabs x <= bpow radix2 e -> Rabs (rnd x - x) <= bpow radix2 (e - 24).
Proof.
  intros x e He Hx.
  eapply Rle_trans; [ apply (error_le_half_ulp radix2 fexp32 (fun z => negb (Z.even z)) x) | ].
  assert (Hu : ulp radix2 fexp32 x <= ulp radix2 fexp32 (bpow radix2 e)).
  { apply (@ulp_le radix2 fexp32 valid_exp_32 mono_exp_32).
    rewrite (Rabs_pos_eq (bpow radix2 e)) by apply bpow_ge_0. exact Hx. }
  rewrite ulp_bpow in Hu.
  replace (fexp32 (e + 1)) with (e - 23)%Z in Hu
    by (unfold SpecFloat.fexp, SpecFloat.emin; lia).
  replace (e - 23)%Z with (e - 24 + 1)%Z in Hu by lia.
  rewrite bpow_plus in Hu. simpl (bpow radix2 1) in Hu.
  pose proof (bpow_ge_0 radix2 (e - 24)). lra.
Qed.

Lemma rnd_B2R : forall f, rnd (R2 f) = R2 f.
Proof. intros f. apply round_generic; [ exact _ | apply Binary.generic_format_B2R ]. Qed.

Lemma rnd_0 : rnd 0 = 0.
Proof. apply round_0. exact _. Qed.

Lemma rnd_mono : forall a b, a <= b -> rnd a <= rnd b.
Proof. intros a b H. apply round_le; [ exact _ | exact _ | exact H ]. Qed.

Lemma rnd_abs_le : forall B z,
  generic_format radix2 fexp32 B -> 0 <= B -> Rabs z <= B -> Rabs (rnd z) <= B.
Proof.
  intros B z HfB HB Hz.
  apply Rabs_le_inv in Hz. destruct Hz as [Hlo Hhi].
  assert (HfoB : generic_format radix2 fexp32 (- B))
    by (apply generic_format_opp; exact HfB).
  apply Rabs_le. split.
  - rewrite <- (round_generic radix2 fexp32 (round_mode mode_NE) (- B) HfoB).
    apply rnd_mono. lra.
  - rewrite <- (round_generic radix2 fexp32 (round_mode mode_NE) B HfB).
    apply rnd_mono. lra.
Qed.

Lemma no_overflow : forall z, Rabs z <= bpow radix2 100 ->
  Rlt_bool (Rabs (rnd z)) (bpow radix2 128) = true.
Proof.
  intros z Hz. apply Rlt_bool_true.
  eapply Rle_lt_trans.
  - apply rnd_abs_le; [ | apply bpow_ge_0 | exact Hz ].
    apply generic_format_bpow. unfold SpecFloat.fexp, SpecFloat.emin. lia.
  - apply bpow_lt. lia.
Qed.

Lemma small_le_bpow100 : forall z, Rabs z <= bpow radix2 14 -> Rabs z <= bpow radix2 100.
Proof.
  intros z Hz. eapply Rle_trans; [ exact Hz | ]. apply bpow_le. lia.
Qed.

(* ----------------------------------------------------------------------- *)
(* 2. The three Float32 operations, as roundings of the real result.        *)
(* ----------------------------------------------------------------------- *)
Lemma f32_add_val : forall a b, F32 a = true -> F32 b = true ->
  Rabs (R2 a + R2 b) <= bpow radix2 100 ->
  R2 (Float32.add a b) = rnd (R2 a + R2 b) /\ F32 (Float32.add a b) = true.
Proof.
  intros a b Fa Fb Hovf. unfold Float32.add.
  match goal with |- context[Binary.Bplus ?p ?e ?g1 ?g2 ?nan ?md a b] =>
    pose proof (Binary.Bplus_correct p e g1 g2 nan md a b Fa Fb) as HB end.
  rewrite (no_overflow _ Hovf) in HB.
  destruct HB as (Hval & Hfin & _). split; [ exact Hval | ].
  first [ exact Hfin | rewrite Hfin; exact Fa | rewrite Hfin, Fa; reflexivity ].
Qed.

Lemma f32_sub_val : forall a b, F32 a = true -> F32 b = true ->
  Rabs (R2 a - R2 b) <= bpow radix2 100 ->
  R2 (Float32.sub a b) = rnd (R2 a - R2 b) /\ F32 (Float32.sub a b) = true.
Proof.
  intros a b Fa Fb Hovf. unfold Float32.sub.
  match goal with |- context[Binary.Bminus ?p ?e ?g1 ?g2 ?nan ?md a b] =>
    pose proof (Binary.Bminus_correct p e g1 g2 nan md a b Fa Fb) as HB end.
  rewrite (no_overflow _ Hovf) in HB.
  destruct HB as (Hval & Hfin & _). split; [ exact Hval | ].
  first [ exact Hfin | rewrite Hfin; exact Fa | rewrite Hfin, Fa; reflexivity ].
Qed.

Lemma f32_div_val : forall a b, F32 a = true -> R2 b <> 0 ->
  Rabs (R2 a / R2 b) <= bpow radix2 100 ->
  R2 (Float32.div a b) = rnd (R2 a / R2 b) /\ F32 (Float32.div a b) = true.
Proof.
  intros a b Fa Hb Hovf. unfold Float32.div.
  match goal with |- context[Binary.Bdiv ?p ?e ?g1 ?g2 ?nan ?md a b] =>
    pose proof (Binary.Bdiv_correct p e g1 g2 nan md a b Hb) as HB end.
  rewrite (no_overflow _ Hovf) in HB.
  destruct HB as (Hval & Hfin & _). split; [ exact Hval | ].
  first [ exact Hfin | rewrite Hfin; exact Fa | rewrite Hfin, Fa; reflexivity ].
Qed.

(* ----------------------------------------------------------------------- *)
(* 3. The constants 4.0f, 2.0f, -75.0f (bit patterns as clightgen emits).   *)
(* ----------------------------------------------------------------------- *)
Definition f4  : float32 := Float32.of_bits (Int.repr 1082130432).   (* 0x40800000 *)
Definition f2  : float32 := Float32.of_bits (Int.repr 1073741824).   (* 0x40000000 *)
Definition fm75 : float32 := Float32.of_bits (Int.repr 3264610304).  (* 0xC2960000 *)

Lemma B2R_f4 : R2 f4 = 4.
Proof. unfold f4. vm_compute (Float32.of_bits _). unfold Binary.B2R, F2R. simpl. lra. Qed.
Lemma B2R_f2 : R2 f2 = 2.
Proof. unfold f2. vm_compute (Float32.of_bits _). unfold Binary.B2R, F2R. simpl. lra. Qed.
Lemma B2R_fm75 : R2 fm75 = -75.
Proof. unfold fm75. vm_compute (Float32.of_bits _). unfold Binary.B2R, F2R. simpl. lra. Qed.
Lemma F32_f4 : F32 f4 = true.   Proof. vm_compute. reflexivity. Qed.
Lemma F32_f2 : F32 f2 = true.   Proof. vm_compute. reflexivity. Qed.
Lemma F32_fm75 : F32 fm75 = true. Proof. vm_compute. reflexivity. Qed.

(* ----------------------------------------------------------------------- *)
(* 4. The frame.                                                            *)
(* ----------------------------------------------------------------------- *)
Definition qstep (y q : float32) : float32 := Float32.add y q.

Definition air_y4 (y v : float32) : float32 :=
  let q := Float32.div v f4 in qstep (qstep (qstep (qstep y q) q) q) q.

Definition gravity (gf v : float32) : float32 :=
  let v1 := Float32.sub v gf in
  if Float32.cmp Clt v1 fm75 then fm75 else v1.

(* one quarter step: within 2^-10 of the exact sum, and monotone in q's sign *)
Lemma qstep_spec : forall y q, F32 y = true -> F32 q = true ->
  Rabs (R2 y + R2 q) <= bpow radix2 14 ->
  F32 (qstep y q) = true
  /\ Rabs (R2 (qstep y q) - (R2 y + R2 q)) <= / 1024
  /\ (R2 q <= 0 -> R2 (qstep y q) <= R2 y).
Proof.
  intros y q Fy Fq Hb.
  destruct (f32_add_val y q Fy Fq (small_le_bpow100 _ Hb)) as [Hv Hf].
  unfold qstep. rewrite Hv. split; [ exact Hf | split ].
  - pose proof (rnd_err (R2 y + R2 q) 14 ltac:(lia) Hb) as He.
    replace (bpow radix2 (14 - 24)) with (/ 1024) in He
      by (simpl; lra). exact He.
  - intros Hq. rewrite <- (rnd_B2R y) at 2. apply rnd_mono. lra.
Qed.

(* the quarter velocity: within 2^-17 of v/4, sign-preserving *)
Lemma quarter_spec : forall v, F32 v = true -> Rabs (R2 v) <= 128 ->
  F32 (Float32.div v f4) = true
  /\ Rabs (R2 (Float32.div v f4) - R2 v / 4) <= / 131072
  /\ (R2 v <= 0 -> R2 (Float32.div v f4) <= 0)
  /\ (0 <= R2 v -> 0 <= R2 (Float32.div v f4)).
Proof.
  intros v Fv Hv.
  assert (Hq : Rabs (R2 v / 4) <= bpow radix2 7).
  { simpl. unfold Rdiv. rewrite Rabs_mult, (Rabs_pos_eq (/ 4)) by lra. lra. }
  assert (H4 : R2 f4 <> 0) by (rewrite B2R_f4; lra).
  destruct (f32_div_val v f4 Fv H4) as [Hval Hf].
  { rewrite B2R_f4. eapply Rle_trans; [ exact Hq | apply bpow_le; lia ]. }
  rewrite B2R_f4 in Hval. rewrite Hval.
  split; [ exact Hf | split; [ | split ] ].
  - pose proof (rnd_err (R2 v / 4) 7 ltac:(lia) Hq) as He.
    replace (bpow radix2 (7 - 24)) with (/ 131072) in He by (simpl; lra). exact He.
  - intros H. rewrite <- rnd_0. apply rnd_mono. lra.
  - intros H. rewrite <- rnd_0. apply rnd_mono. lra.
Qed.

(* gravity: the result is either rnd(v - g), within 2^-16 of v - g, or -75 *)
Lemma gravity_spec : forall gf v, F32 gf = true -> F32 v = true ->
  (R2 gf = 2 \/ R2 gf = 4) -> Rabs (R2 v) <= 128 ->
  (R2 (gravity gf v) = -75
   \/ (R2 (gravity gf v) = rnd (R2 v - R2 gf)
       /\ Rabs (R2 (gravity gf v) - (R2 v - R2 gf)) <= / 65536)).
Proof.
  intros gf v Fg Fv Hg Hv.
  assert (Hb : Rabs (R2 v - R2 gf) <= bpow radix2 8).
  { simpl. apply Rabs_le. apply Rabs_le_inv in Hv. split; lra. }
  destruct (f32_sub_val v gf Fv Fg) as [Hval _].
  { eapply Rle_trans; [ exact Hb | apply bpow_le; lia ]. }
  unfold gravity. destruct (Float32.cmp Clt (Float32.sub v gf) fm75).
  - left. exact B2R_fm75.
  - right. rewrite Hval. split; [ reflexivity | ].
    pose proof (rnd_err (R2 v - R2 gf) 8 ltac:(lia) Hb) as He.
    replace (bpow radix2 (8 - 24)) with (/ 65536) in He by (simpl; lra). exact He.
Qed.

(* ----------------------------------------------------------------------- *)
(* 5. The real-number core: rising, the EPS allowance pays for rounding.    *)
(* ----------------------------------------------------------------------- *)
Lemma energy_step : forall g w, 0 < g ->
  energy g (w - g) = energy g w - w.
Proof. intros g w Hg. unfold energy. field. lra. Qed.

Lemma energy_mono : forall g a b, 0 < g -> - (g / 2) <= a <= b ->
  energy g a <= energy g b.
Proof.
  intros g a b Hg Hab. unfold energy, Rdiv.
  apply Rmult_le_compat_r; [ left; apply Rinv_0_lt_compat; lra | ].
  apply pow_incr. lra.
Qed.

Lemma energy_ge_v : forall g v, 0 < g -> v <= energy g v.
Proof.
  intros g v Hg.
  assert (energy g v - v = (v - g / 2) ^ 2 / (2 * g)) by (unfold energy; field; lra).
  assert (0 <= (v - g / 2) ^ 2 / (2 * g)).
  { unfold Rdiv. apply Rmult_le_pos; [ apply pow2_ge_0 | left; apply Rinv_0_lt_compat; lra ]. }
  lra.
Qed.

Lemma ballistic_real : forall g y v y4 v',
  (g = 2 \/ g = 4) -> 0 < v -> v <= 128 ->
  y4 <= y + v + / 128 ->
  (v' = -75 \/ Rabs (v' - (v - g)) <= / 65536) ->
  y4 + bal g v' <= y + bal g v.
Proof.
  intros g y v y4 v' Hg Hv0 Hv Hy Hv'.
  assert (Hg0 : 0 < g) by lra.
  unfold bal at 2. destruct (Rle_dec v 0) as [ | _ ]; [ lra | ].
  assert (Hvg : 0 <= v / g)
    by (unfold Rdiv; apply Rmult_le_pos; [ lra | left; apply Rinv_0_lt_compat; lra ]).
  pose proof (energy_ge_v g v Hg0).
  unfold bal. destruct (Rle_dec v' 0) as [Hle | Hgt].
  - (* the frame ends descending: Pot' = y4 <= y + v + 1/128 *)
    unfold EPS. nra.
  - (* still rising: energy pays for the height, EPS for the rounding *)
    destruct Hv' as [Hc | Hd]; [ lra | ].
    apply Rabs_le_inv in Hd.
    assert (Hmono : energy g v' <= energy g (v - g + / 65536)).
    { apply energy_mono; [ exact Hg0 | lra ]. }
    assert (Hid : energy g (v - g + / 65536)
                  = energy g v - v + (2 * v - g + / 65536) * / 65536 / (2 * g)).
    { unfold energy. field. lra. }
    assert (Hsmall : (2 * v - g + / 65536) * / 65536 / (2 * g) <= / 512).
    { apply (Rmult_le_reg_r (2 * g)); [ lra | ].
      unfold Rdiv. rewrite Rmult_assoc, Rinv_l, Rmult_1_r by lra.
      destruct Hg as [-> | ->]; lra. }
    assert (Hdv0 : v' / g <= (v - g + / 65536) / g).
    { unfold Rdiv. apply Rmult_le_compat_r; [ left; apply Rinv_0_lt_compat; lra | lra ]. }
    assert (Heq : (v - g + / 65536) / g = v / g - 1 + / 65536 / g) by (field; lra).
    assert (Hdv : v' / g <= v / g - 1 + / 65536 / g) by lra.
    assert (Hdg : / 65536 / g <= / 131072).
    { destruct Hg as [-> | ->]; lra. }
    unfold EPS. nra.
Qed.

(* ----------------------------------------------------------------------- *)
(* 6. THE BALLISTIC FRAME LEMMA.                                            *)
(* ----------------------------------------------------------------------- *)
Theorem ballistic_frame : forall gf y v,
  F32 gf = true -> F32 y = true -> F32 v = true ->
  (R2 gf = 2 \/ R2 gf = 4) ->
  Rabs (R2 y) <= 16000 -> Rabs (R2 v) <= 128 ->
  F32 (air_y4 y v) = true
  /\ R2 (air_y4 y v) + bal (R2 gf) (R2 (gravity gf v))
       <= R2 y + bal (R2 gf) (R2 v).
Proof.
  intros gf y v Fg Fy Fv Hg Hy Hv.
  destruct (quarter_spec v Fv Hv) as (Fq & Hqe & Hqn & Hqp).
  set (q := Float32.div v f4) in *.
  assert (Hqb : Rabs (R2 q) <= 33).
  { apply Rabs_le_inv in Hqe. apply Rabs_le_inv in Hv. apply Rabs_le. split; lra. }
  apply Rabs_le_inv in Hqb. apply Rabs_le_inv in Hy.
  (* four quarter steps, each within 2^-10, staying inside |.| <= 2^14 *)
  assert (B14 : forall z, -16384 <= z <= 16384 -> Rabs z <= bpow radix2 14)
    by (intros z Hz; simpl; apply Rabs_le; split; lra).
  destruct (qstep_spec y q Fy Fq ltac:(apply B14; lra)) as (F1 & E1 & D1).
  set (y1 := qstep y q) in *. apply Rabs_le_inv in E1.
  destruct (qstep_spec y1 q F1 Fq ltac:(apply B14; lra)) as (F2 & E2 & D2).
  set (y2 := qstep y1 q) in *. apply Rabs_le_inv in E2.
  destruct (qstep_spec y2 q F2 Fq ltac:(apply B14; lra)) as (F3 & E3 & D3).
  set (y3 := qstep y2 q) in *. apply Rabs_le_inv in E3.
  destruct (qstep_spec y3 q F3 Fq ltac:(apply B14; lra)) as (F4 & E4 & D4).
  set (y4 := qstep y3 q) in *. apply Rabs_le_inv in E4.
  assert (Hy4 : R2 (air_y4 y v) = R2 y4) by reflexivity.
  split; [ exact F4 | rewrite Hy4 ].
  pose proof (gravity_spec gf v Fg Fv Hg Hv) as Hgr.
  destruct (Rle_dec (R2 v) 0) as [Hneg | Hpos].
  - (* descending: every quarter step rounds down-safely, and vel stays <= 0 *)
    specialize (Hqn Hneg).
    assert (R2 y4 <= R2 y) by (specialize (D1 Hqn); specialize (D2 Hqn);
                                specialize (D3 Hqn); specialize (D4 Hqn); lra).
    assert (Hvn : R2 (gravity gf v) <= 0).
    { destruct Hgr as [-> | [-> _]]; [ lra | ].
      rewrite <- rnd_0. apply rnd_mono. lra. }
    unfold bal. destruct (Rle_dec (R2 (gravity gf v)) 0); [ | lra ].
    destruct (Rle_dec (R2 v) 0); [ lra | contradiction ].
  - (* rising *)
    apply Rnot_le_lt in Hpos.
    apply Rabs_le_inv in Hqe.
    apply ballistic_real.
    + exact Hg.
    + exact Hpos.
    + apply Rabs_le_inv in Hv. lra.
    + lra.
    + destruct Hgr as [H | [_ H]]; [ left; exact H | right; exact H ].
Qed.

(* ----------------------------------------------------------------------- *)
(* 7. Descending variant: no lower bound on y beyond finiteness.            *)
(* ----------------------------------------------------------------------- *)
Lemma qstep_spec_e : forall e y q, (-120 <= e <= 100)%Z ->
  F32 y = true -> F32 q = true ->
  Rabs (R2 y + R2 q) <= bpow radix2 e ->
  F32 (qstep y q) = true
  /\ Rabs (R2 (qstep y q) - (R2 y + R2 q)) <= bpow radix2 (e - 24)
  /\ (R2 q <= 0 -> R2 (qstep y q) <= R2 y).
Proof.
  intros e y q He Fy Fq Hb.
  assert (H100 : Rabs (R2 y + R2 q) <= bpow radix2 100)
    by (eapply Rle_trans; [ exact Hb | apply bpow_le; lia ]).
  destruct (f32_add_val y q Fy Fq H100) as [Hv Hf].
  unfold qstep. rewrite Hv. split; [ exact Hf | split ].
  - apply rnd_err; [ lia | exact Hb ].
  - intros Hq. rewrite <- (rnd_B2R y) at 2. apply rnd_mono. lra.
Qed.

Theorem ballistic_frame_desc : forall gf y v,
  F32 gf = true -> F32 y = true -> F32 v = true ->
  (R2 gf = 2 \/ R2 gf = 4) ->
  Rabs (R2 y) <= 1048576 -> -128 <= R2 v <= 0 ->
  F32 (air_y4 y v) = true
  /\ R2 (air_y4 y v) + bal (R2 gf) (R2 (gravity gf v))
       <= R2 y + bal (R2 gf) (R2 v).
Proof.
  intros gf y v Fg Fy Fv Hg Hy Hv0.
  assert (Hv : Rabs (R2 v) <= 128) by (apply Rabs_le; lra).
  destruct (quarter_spec v Fv Hv) as (Fq & Hqe & Hqn & _).
  set (q := Float32.div v f4) in *.
  assert (Hneg : R2 v <= 0) by lra.
  specialize (Hqn Hneg).
  assert (Hqb : Rabs (R2 q) <= 33).
  { apply Rabs_le_inv in Hqe. apply Rabs_le. split; lra. }
  apply Rabs_le_inv in Hqb. apply Rabs_le_inv in Hy.
  assert (B21 : forall z, -2097152 <= z <= 2097152 -> Rabs z <= bpow radix2 21)
    by (intros z Hz; simpl; apply Rabs_le; split; lra).
  assert (Ee : bpow radix2 (21 - 24) = / 8) by (simpl; lra).
  destruct (qstep_spec_e 21 y q ltac:(lia) Fy Fq ltac:(apply B21; lra)) as (F1 & E1 & D1).
  rewrite Ee in E1. set (y1 := qstep y q) in *. apply Rabs_le_inv in E1.
  specialize (D1 Hqn).
  destruct (qstep_spec_e 21 y1 q ltac:(lia) F1 Fq ltac:(apply B21; lra)) as (F2 & E2 & D2).
  rewrite Ee in E2. set (y2 := qstep y1 q) in *. apply Rabs_le_inv in E2.
  specialize (D2 Hqn).
  destruct (qstep_spec_e 21 y2 q ltac:(lia) F2 Fq ltac:(apply B21; lra)) as (F3 & E3 & D3).
  rewrite Ee in E3. set (y3 := qstep y2 q) in *. apply Rabs_le_inv in E3.
  specialize (D3 Hqn).
  destruct (qstep_spec_e 21 y3 q ltac:(lia) F3 Fq ltac:(apply B21; lra)) as (F4 & E4 & D4).
  set (y4 := qstep y3 q) in *.
  specialize (D4 Hqn).
  assert (Hy4 : R2 (air_y4 y v) = R2 y4) by reflexivity.
  split; [ exact F4 | rewrite Hy4 ].
  pose proof (gravity_spec gf v Fg Fv Hg Hv) as Hgr.
  assert (R2 y4 <= R2 y) by lra.
  assert (Hvn : R2 (gravity gf v) <= 0).
  { destruct Hgr as [-> | [-> _]]; [ lra | ].
    rewrite <- rnd_0. apply rnd_mono. lra. }
  unfold bal. destruct (Rle_dec (R2 (gravity gf v)) 0); [ | lra ].
  destruct (Rle_dec (R2 v) 0); [ lra | contradiction ].
Qed.

(* ----------------------------------------------------------------------- *)
(* 8. For HeightMove: partial air steps, the -75 clamp, the slide-kick     *)
(*    signed-energy frame, and one ground-pound windup add.                 *)
(* ----------------------------------------------------------------------- *)

(* k quarter steps.  A ceiling hit at vel >= 0 zeroes vel (mario_step.c:
   446-452), so the remaining quarters add 0: y' = qiter k y q, k <= 4. *)
Fixpoint qiter (k : nat) (y q : float32) : float32 :=
  match k with O => y | S k' => qstep (qiter k' y q) q end.

Lemma air_y4_qiter : forall y v, air_y4 y v = qiter 4 y (Float32.div v f4).
Proof. reflexivity. Qed.

Lemma qiter_spec : forall k y q, (k <= 4)%nat ->
  F32 y = true -> F32 q = true -> Rabs (R2 y) <= 16000 -> Rabs (R2 q) <= 33 ->
  F32 (qiter k y q) = true
  /\ R2 y + INR k * R2 q - INR k / 1024 <= R2 (qiter k y q)
                                       <= R2 y + INR k * R2 q + INR k / 1024
  /\ (R2 q <= 0 -> R2 (qiter k y q) <= R2 y).
Proof.
  induction k as [ | k IH ]; intros y q Hk Fy Fq Hy Hq.
  - simpl. split; [ exact Fy | split; [ lra | intros; lra ] ].
  - destruct (IH y q ltac:(lia) Fy Fq Hy Hq) as (Fk & Ek & Dk).
    set (yk := qiter k y q) in *.
    assert (Hk3 : INR k <= 3) by (replace 3 with (INR 3) by (simpl; lra); apply le_INR; lia).
    pose proof (pos_INR k) as Hk0.
    pose proof (Rabs_le_inv _ _ Hy) as Hy'. pose proof (Rabs_le_inv _ _ Hq) as Hq'.
    assert (Hkq : -99 <= INR k * R2 q <= 99) by (split; nra).
    assert (B14 : Rabs (R2 yk + R2 q) <= bpow radix2 14)
      by (simpl; apply Rabs_le; split; lra).
    destruct (qstep_spec yk q Fk Fq B14) as (F1 & E1 & D1).
    apply Rabs_le_inv in E1.
    simpl qiter. fold yk. rewrite S_INR.
    split; [ exact F1 | split; [ split; nra | ] ].
    intros Hn. specialize (Dk Hn). specialize (D1 Hn). lra.
Qed.

(* the budget-facing form: rising adds at most v + 1/128; falling never
   rises; the full four quarters add at most v + 1/128 (any sign of v) *)
Lemma qiter_up : forall k y v, (k <= 4)%nat ->
  F32 y = true -> F32 v = true -> Rabs (R2 y) <= 16000 -> Rabs (R2 v) <= 128 ->
  F32 (qiter k y (Float32.div v f4)) = true
  /\ (0 <= R2 v -> R2 (qiter k y (Float32.div v f4)) <= R2 y + R2 v + / 128)
  /\ (R2 v <= 0 -> R2 (qiter k y (Float32.div v f4)) <= R2 y)
  /\ (k = 4%nat -> R2 (qiter k y (Float32.div v f4)) <= R2 y + R2 v + / 128).
Proof.
  intros k y v Hk Fy Fv Hy Hv.
  destruct (quarter_spec v Fv Hv) as (Fq & Hqe & Hqn & Hqp).
  set (q := Float32.div v f4) in *.
  apply Rabs_le_inv in Hqe.
  assert (Hqb : Rabs (R2 q) <= 33).
  { apply Rabs_le_inv in Hv. apply Rabs_le. split; lra. }
  destruct (qiter_spec k y q Hk Fy Fq Hy Hqb) as (Fk & Ek & Dk).
  assert (Hk4 : INR k <= 4) by (replace 4 with (INR 4) by (simpl; lra); apply le_INR; lia).
  pose proof (pos_INR k) as Hk0.
  split; [ exact Fk | split; [ | split ] ].
  - intros H0. specialize (Hqp H0).
    assert (INR k * R2 q <= 4 * R2 q) by nra. lra.
  - intros H0. exact (Dk (Hqn H0)).
  - intros ->. simpl INR in Ek. lra.
Qed.

(* the clamp fires only when v - g really is below -75 *)
Lemma gravity_spec2 : forall gf v, F32 gf = true -> F32 v = true ->
  (R2 gf = 2 \/ R2 gf = 4) -> Rabs (R2 v) <= 128 ->
  (R2 v - R2 gf < -75 /\ R2 (gravity gf v) = -75)
  \/ (-75 <= R2 (gravity gf v)
      /\ Rabs (R2 (gravity gf v) - (R2 v - R2 gf)) <= / 65536).
Proof.
  intros gf v Fg Fv Hg Hv.
  assert (Hb : Rabs (R2 v - R2 gf) <= bpow radix2 8).
  { simpl. apply Rabs_le. apply Rabs_le_inv in Hv. split; lra. }
  destruct (f32_sub_val v gf Fv Fg) as [Hval Hfin].
  { eapply Rle_trans; [ exact Hb | apply bpow_le; lia ]. }
  assert (Hr75 : rnd (-75) = -75) by (rewrite <- B2R_fm75; apply rnd_B2R).
  unfold gravity.
  destruct (Float32.cmp Clt (Float32.sub v gf) fm75) eqn:Hc.
  - left. split; [ | exact B2R_fm75 ].
    unfold Float32.cmp, Float32.compare in Hc.
    rewrite Binary.Bcompare_correct in Hc by (auto using F32_fm75).
    rewrite B2R_fm75, Hval in Hc.
    destruct (Rcompare_spec (rnd (R2 v - R2 gf)) (-75)) as [H | H | H];
      simpl in Hc; try discriminate.
    destruct (Rlt_or_le (R2 v - R2 gf) (-75)) as [ | Hge ]; [ assumption | ].
    exfalso. assert (rnd (-75) <= rnd (R2 v - R2 gf)) by (apply rnd_mono; lra). lra.
  - right. rewrite Hval. split.
    + unfold Float32.cmp, Float32.compare in Hc.
      rewrite Binary.Bcompare_correct in Hc by (auto using F32_fm75).
      rewrite B2R_fm75, Hval in Hc.
      destruct (Rcompare_spec (rnd (R2 v - R2 gf)) (-75)) as [H | H | H];
        simpl in Hc; try discriminate; lra.
    + pose proof (rnd_err (R2 v - R2 gf) 8 ltac:(lia) Hb) as He.
      replace (bpow radix2 (8 - 24)) with (/ 65536) in He by (simpl; lra). exact He.
Qed.

(* the post-bounce slide kick frame (g = 2) over the SIGNED energy *)
Theorem sk1_frame : forall y v,
  F32 y = true -> F32 v = true -> Rabs (R2 y) <= 16000 -> -75 <= R2 v <= 128 ->
  R2 (air_y4 y v) + sk1_credit (R2 (gravity f2 v)) <= R2 y + sk1_credit (R2 v).
Proof.
  intros y v Fy Fv Hy Hv.
  assert (Hva : Rabs (R2 v) <= 128) by (apply Rabs_le; lra).
  destruct (qiter_up 4 y v ltac:(lia) Fy Fv Hy Hva) as (_ & _ & _ & H4).
  rewrite air_y4_qiter. specialize (H4 eq_refl).
  set (y4 := R2 (qiter 4 y (Float32.div v f4))) in *.
  pose proof (gravity_spec2 f2 v F32_f2 Fv (or_introl B2R_f2) Hva) as Hg.
  rewrite B2R_f2 in Hg.
  set (w := R2 (gravity f2 v)) in *.
  unfold sk1_credit, energy, EPS, SK_BONK.
  destruct Hg as [[Hlt Hw] | [Hw Hd]].
  - rewrite Hw.
    rewrite (Rmax_right 0 ((-75 + 75) / 2 + 1)) by lra.
    rewrite (Rmax_right 0 ((R2 v + 75) / 2 + 1)) by lra.
    destruct (Rle_dec (-75) (-1)); [ | lra ].
    destruct (Rle_dec (R2 v) (-1)); [ | lra ].
    assert ((R2 v - 1) ^ 2 >= 5476 + 148 * (-73 - R2 v)) by nra.
    assert ((R2 v + 2 / 2) ^ 2 / (2 * 2) = R2 v + (R2 v - 1) ^ 2 / 4) by field.
    lra.
  - apply Rabs_le_inv in Hd.
    rewrite (Rmax_right 0 ((w + 75) / 2 + 1)) by lra.
    rewrite (Rmax_right 0 ((R2 v + 75) / 2 + 1)) by lra.
    set (d := w - (R2 v - 2)).
    assert (Hwd : w = R2 v - 2 + d) by (unfold d; ring).
    assert (Hdb : - / 65536 <= d <= / 65536) by (unfold d; lra).
    assert (Hdv : d * (R2 v - 1) <= 128 / 65536).
    { destruct (Rle_dec 0 (R2 v - 1)); nra. }
    assert (Hd2 : d * d <= / 65536) by nra.
    assert (Hid : (w + 2 / 2) ^ 2 / (2 * 2)
                  = (R2 v + 2 / 2) ^ 2 / (2 * 2) - R2 v + d * (R2 v - 1) / 2 + d * d / 4)
      by (rewrite Hwd; field).
    destruct (Rle_dec w (-1)); destruct (Rle_dec (R2 v) (-1)); lra.
Qed.

(* one windup add, pos[1] += yOffset (0 <= yOffset <= 20): rounds by < EPS *)
Lemma windup_add : forall y o, F32 y = true -> F32 o = true ->
  0 <= R2 o <= 20 -> -8192 <= R2 y <= 2744 ->
  F32 (Float32.add y o) = true /\ R2 (Float32.add y o) <= R2 y + R2 o + EPS.
Proof.
  intros y o Fy Fo Ho Hy.
  assert (B13 : Rabs (R2 y + R2 o) <= bpow radix2 13)
    by (simpl; apply Rabs_le; split; lra).
  destruct (f32_add_val y o Fy Fo) as [Hv Hf].
  { eapply Rle_trans; [ exact B13 | apply bpow_le; lia ]. }
  split; [ exact Hf | rewrite Hv ].
  pose proof (rnd_err (R2 y + R2 o) 13 ltac:(lia) B13) as He.
  replace (bpow radix2 (13 - 24)) with (/ 2048) in He by (simpl; lra).
  apply Rabs_le_inv in He. unfold EPS. lra.
Qed.
