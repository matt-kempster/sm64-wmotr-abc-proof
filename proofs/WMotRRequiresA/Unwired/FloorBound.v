(* ====================================================================== *)
(* FloorBound (unwired, GOAL 2): the real-number content of find_floor's  *)
(* height test.                                                             *)
(*                                                                          *)
(* find_floor_from_list keeps a floor only when                            *)
(*     y - (h + -78.0f) < 0.0f                                              *)
(* is false (FloorList.hok), in binary32 with y an int.  For a finite      *)
(* height of moderate size that means h <= y + 79 as reals ([hok_bound]).  *)
(* Over find_floor's whole height set HPi (FloorHeight), including the    *)
(* SURFACE_INTANGIBLE re-search at (s32)(h0 - 200), every member is       *)
(* -11000 or a hit at most y + 79 ([HPi_bound]), provided the hits         *)
(* themselves are finite and moderate (a fact about the level's floors).   *)
(* ====================================================================== *)

From Coq Require Import ZArith Reals Lra Lia.
From compcert Require Import Coqlib Floats Integers Values IEEE754_extra.
From Flocq Require Import Binary Bits Defs Raux Zaux Generic_fmt FLT.
From SM64.Proofs Require Import HeightInvariant.
From SM64.Proofs.WMotRRequiresA Require Import HeightFloatSteps.
From SM64.Proofs.WMotRRequiresA.Unwired Require Import FloorList FloorHeight.

Local Open Scope R_scope.
Local Transparent Float32.add Float32.sub Float32.neg Float32.cmp Float32.compare
  Float32.of_int Float32.to_int.

Lemma B2R_c78 : R2 c78 = 78.
Proof. unfold c78. vm_compute (Float32.of_bits _). unfold Binary.B2R, F2R. simpl. lra. Qed.
Lemma F32_c78 : F32 c78 = true.  Proof. vm_compute. reflexivity. Qed.
Lemma B2R_c200 : R2 c200 = 200.
Proof. unfold c200. vm_compute (Float32.of_bits _). unfold Binary.B2R, F2R. simpl. lra. Qed.
Lemma F32_c200 : F32 c200 = true.  Proof. vm_compute. reflexivity. Qed.

Lemma neg_val : forall x, R2 (Float32.neg x) = - R2 x /\ F32 (Float32.neg x) = F32 x.
Proof.
  intros x. unfold Float32.neg. split.
  - apply Binary.B2R_Bopp.
  - apply Binary.is_finite_Bopp.
Qed.

Lemma of_int_val : forall i, Rabs (IZR (Int.signed i)) <= 16777216 ->
  R2 (Float32.of_int i) = IZR (Int.signed i) /\ F32 (Float32.of_int i) = true.
Proof.
  intros i Hi. unfold Float32.of_int.
  apply Rabs_le_inv in Hi. destruct Hi as (H1 & H2).
  assert (Z1 : (-16777216 <= Int.signed i)%Z) by (apply le_IZR; lra).
  assert (Z2 : (Int.signed i <= 16777216)%Z) by (apply le_IZR; lra).
  destruct (BofZ_exact 24 128 eq_refl eq_refl (Int.signed i)) as (A & B & _).
  { cbn. lia. }
  split; [exact A | exact B].
Qed.

Lemma c11000_val : R2 c11000 = -11000 /\ F32 c11000 = true.
Proof.
  unfold c11000.
  assert (E : Int.signed (Int.neg (Int.repr 11000)) = (-11000)%Z) by reflexivity.
  destruct (of_int_val (Int.neg (Int.repr 11000))) as (A & B);
    [rewrite E; apply Rabs_le; lra | ].
  rewrite A, E. split; [reflexivity | exact B].
Qed.
Lemma B2R_c11000 : R2 c11000 = -11000.  Proof. exact (proj1 c11000_val). Qed.
Lemma F32_c11000 : F32 c11000 = true.  Proof. exact (proj2 c11000_val). Qed.

Lemma cmp_lt_false : forall a b, F32 a = true -> F32 b = true ->
  Float32.cmp Clt a b = false -> R2 b <= R2 a.
Proof.
  intros a b Fa Fb H. unfold Float32.cmp, Float32.compare in H.
  rewrite Binary.Bcompare_correct in H by assumption.
  destruct (Rcompare_spec (R2 a) (R2 b)) as [L | L | L]; cbn in H; try discriminate; lra.
Qed.

(* the height test, as reals *)
Theorem hok_bound : forall yi h, hok (Vint yi) h -> F32 h = true ->
  Rabs (R2 h) <= 65536 -> Rabs (IZR (Int.signed yi)) <= 65536 ->
  R2 h <= IZR (Int.signed yi) + 79.
Proof.
  intros yi h (yi' & Ey & Hc) Fh Hh Hy. injection Ey as <-.
  set (y := IZR (Int.signed yi)) in *.
  destruct (neg_val c78) as (Nv & Nf). rewrite B2R_c78 in Nv. rewrite F32_c78 in Nf.
  destruct (f32_add_val h (Float32.neg c78) Fh Nf) as (Av & Af).
  { rewrite Nv. eapply Rle_trans; [| apply (bpow_le radix2 17 100); lia].
    simpl. apply Rabs_le. apply Rabs_le_inv in Hh. lra. }
  rewrite Nv in Av.
  pose proof (rnd_err (R2 h + - 78) 17 ltac:(lia)
                ltac:(simpl; apply Rabs_le; apply Rabs_le_inv in Hh; lra)) as Ea.
  replace (bpow radix2 (17 - 24)) with (/ 128) in Ea by (simpl; lra).
  assert (Ea' : Rabs (R2 (Float32.add h (Float32.neg c78)) - (R2 h + - 78)) <= / 128)
    by (rewrite Av; exact Ea).
  clear Ea; rename Ea' into Ea.
  set (a := Float32.add h (Float32.neg c78)) in *.
  assert (Ha : Rabs (R2 a) <= 65536 + 79)
    by (apply Rabs_le; apply Rabs_le_inv in Hh; apply Rabs_le_inv in Ea; lra).
  destruct (of_int_val yi) as (Iv & If).
  { apply Rabs_le_inv in Hy. apply Rabs_le. fold y. lra. }
  fold y in Iv.
  destruct (f32_sub_val (Float32.of_int yi) a If Af) as (Dv & Df).
  { rewrite Iv. eapply Rle_trans; [| apply (bpow_le radix2 18 100); lia].
    simpl. apply Rabs_le. apply Rabs_le_inv in Hy, Ha. lra. }
  rewrite Iv in Dv.
  pose proof (rnd_err (y - R2 a) 18 ltac:(lia)
                ltac:(simpl; apply Rabs_le; apply Rabs_le_inv in Hy, Ha; lra)) as Ed.
  replace (bpow radix2 (18 - 24)) with (/ 64) in Ed by (simpl; lra).
  assert (Ed' : Rabs (R2 (Float32.sub (Float32.of_int yi) a) - (y - R2 a)) <= / 64)
    by (rewrite Dv; exact Ed).
  clear Ed; rename Ed' into Ed.
  pose proof (cmp_lt_false _ Float32.zero Df eq_refl Hc) as Hz.
  replace (R2 Float32.zero) with 0 in Hz by reflexivity.
  apply Rabs_le_inv in Ea, Ed. lra.
Qed.

Lemma ztrunc_near : forall x, x - 1 < IZR (Ztrunc x) < x + 1.
Proof.
  intros x. destruct (Rle_or_lt 0 x) as [P | N].
  - rewrite Ztrunc_floor by exact P.
    pose proof (Zfloor_lb x). pose proof (Zfloor_ub x). lra.
  - rewrite Ztrunc_ceil by lra.
    pose proof (Zceil_ub x). pose proof (Zceil_lb x). lra.
Qed.

(* (s32) truncation moves a value by less than 1 *)
Lemma to_int_val : forall f i, Float32.to_int f = Some i ->
  F32 f = true /\ R2 f - 1 < IZR (Int.signed i) < R2 f + 1.
Proof.
  intros f i H. unfold Float32.to_int in H.
  rewrite ZofB_range_correct in H.
  destruct (Binary.is_finite 24 128 f) eqn:Ff; [| discriminate H].
  destruct (Z.leb Int.min_signed (Ztrunc (R2 f))) eqn:L1; [| discriminate H].
  destruct (Z.leb (Ztrunc (R2 f)) Int.max_signed) eqn:L2; [| discriminate H].
  cbn in H. injection H as <-.
  apply Z.leb_le in L1. apply Z.leb_le in L2.
  rewrite Int.signed_repr by lia.
  split; [reflexivity | apply ztrunc_near].
Qed.

Lemma to_int_some : forall f, F32 f = true -> Rabs (R2 f) <= 1000000 ->
  exists i, Float32.to_int f = Some i.
Proof.
  intros f Ff Hf. unfold Float32.to_int. rewrite ZofB_range_correct, Ff.
  pose proof (ztrunc_near (R2 f)) as (T1 & T2). apply Rabs_le_inv in Hf.
  assert (A : (-1000001 < Ztrunc (R2 f) < 1000001)%Z) by (split; apply lt_IZR; lra).
  replace (Z.leb Int.min_signed (Ztrunc (R2 f))) with true by (symmetry; apply Z.leb_le; cbn; lia).
  replace (Z.leb (Ztrunc (R2 f)) Int.max_signed) with true by (symmetry; apply Z.leb_le; cbn; lia).
  eexists. reflexivity.
Qed.

(* the s16 cast is the identity on s16 values *)
Lemma sext16_small : forall x, (-32768 <= Int.signed x < 32768)%Z -> Int.sign_ext 16 x = x.
Proof.
  intros x Hx.
  destruct (Int.eqmod_sign_ext 16 x ltac:(cbn; lia)) as (k & Ek).
  pose proof (Int.sign_ext_range 16 x ltac:(cbn; lia)) as R.
  pose proof (Int.unsigned_signed x) as U.
  change (two_p 16) with 65536%Z in Ek. change (two_p (16 - 1)) with 32768%Z in R.
  assert (S : Int.signed (Int.sign_ext 16 x) = Int.signed x).
  { destruct (Int.lt x Int.zero); rewrite U in Ek; change Int.modulus with 4294967296%Z in Ek; lia. }
  rewrite <- (Int.repr_signed (Int.sign_ext 16 x)), S. apply Int.repr_signed.
Qed.

(* find_floor's y: the s16 cast of yPos, within 1 of it *)
Lemma ycast_val : forall f, F32 f = true -> Rabs (R2 f) <= 30000 ->
  exists yi, ycast (Vsingle f) = Vint yi /\ R2 f - 1 < IZR (Int.signed yi) < R2 f + 1.
Proof.
  intros f Ff Hf. destruct (to_int_some f Ff ltac:(apply Rabs_le_inv in Hf; apply Rabs_le; lra)) as (i & Ti).
  destruct (to_int_val f i Ti) as (_ & T1 & T2). apply Rabs_le_inv in Hf.
  assert (A : (-32768 <= Int.signed i < 32768)%Z) by (split; [apply le_IZR | apply lt_IZR]; lra).
  exists i. cbn [ycast]. rewrite Ti, (sext16_small i A), (sext16_small i A). split; [reflexivity | lra].
Qed.

(* the hits find_floor_from_list can store: finite, moderate *)
Definition HitB (Hit : float32 -> Prop) : Prop :=
  forall x, Hit x -> F32 x = true /\ Rabs (R2 x) <= 16384.

(* every height find_floor can return *)
Theorem HPi_bound : forall Hit yi h, HitB Hit ->
  -11000 <= IZR (Int.signed yi) <= 16384 ->
  HPi Hit (Vint yi) h ->
  h = c11000 \/ (Hit h /\ R2 h <= IZR (Int.signed yi) + 79).
Proof.
  intros Hit yi h HB Hy H. induction H as [| h Hk Ht | h0 y' h H0 IH Ti Hk Ht].
  - left. reflexivity.
  - right. split; [exact Ht |]. destruct (HB h Ht) as (Fh & Bh).
    apply (hok_bound yi h Hk Fh); [apply Rabs_le; apply Rabs_le_inv in Bh; lra |].
    apply Rabs_le. lra.
  - right. split; [exact Ht |]. destruct (HB h Ht) as (Fh & Bh).
    (* the re-search's y: (s32)(h0 - 200), with h0 = -11000 or a hit <= y + 79 *)
    assert (H0b : F32 h0 = true /\ -16384 <= R2 h0 <= 16384 /\ R2 h0 <= IZR (Int.signed yi) + 79).
    { destruct IH as [-> | (Ht0 & B0)].
      - rewrite B2R_c11000, F32_c11000. lra.
      - destruct (HB h0 Ht0) as (F0 & A0). apply Rabs_le_inv in A0.
        split; [exact F0 |]. lra. }
    destruct H0b as (F0 & R0 & B0).
    destruct (f32_sub_val h0 c200 F0 F32_c200) as (Sv & Sf).
    { rewrite B2R_c200. eapply Rle_trans; [| apply (bpow_le radix2 15 100); lia].
      simpl. apply Rabs_le. lra. }
    rewrite B2R_c200 in Sv.
    pose proof (rnd_err (R2 h0 - 200) 15 ltac:(lia) ltac:(simpl; apply Rabs_le; lra)) as Es.
    replace (bpow radix2 (15 - 24)) with (/ 512) in Es by (simpl; lra).
    assert (Es' : Rabs (R2 (Float32.sub h0 c200) - (R2 h0 - 200)) <= / 512)
      by (rewrite Sv; exact Es).
    clear Es; rename Es' into Es. apply Rabs_le_inv in Es.
    destruct (to_int_val _ _ Ti) as (_ & T1 & T2).
    assert (Hk' := hok_bound y' h Hk Fh).
    assert (Hb : R2 h <= IZR (Int.signed y') + 79).
    { apply Hk'; [apply Rabs_le; apply Rabs_le_inv in Bh; lra | apply Rabs_le; lra]. }
    lra.
Qed.

(* THE LANDING BOUND: a height find_floor returns for a finite yPos in the
   world's range is -11000 or a hit at most yPos + 80 *)
Theorem ff_height_bound : forall Hit f h, HitB Hit -> F32 f = true ->
  -10000 <= R2 f <= 16000 ->
  HPi Hit (ycast (Vsingle f)) h ->
  h = c11000 \/ (Hit h /\ R2 h <= R2 f + 80).
Proof.
  intros Hit f h HB Ff Hf H.
  destruct (ycast_val f Ff ltac:(apply Rabs_le; lra)) as (yi & Ey & Y1 & Y2).
  rewrite Ey in H.
  destruct (HPi_bound Hit yi h HB ltac:(lra) H) as [E | (Ht & B)]; [left; exact E | right].
  split; [exact Ht | lra].
Qed.
