(* ====================================================================== *)
(* TerrainBound (GOAL 2): find_floor's binary32 plane height on one       *)
(* triangle, bounded by a per-triangle check.                              *)
(*                                                                          *)
(* A hit (FloorList.ffl_hit, FloorHeight.ffl_hit16) is                     *)
(*   h = plane_h X Z nx ny nz oo                                           *)
(*     = -( (float)X*nx + nz*(float)Z + oo ) / ny        (binary32)        *)
(* at an s16 (X, Z) that passed the three int32 edge tests of the          *)
(* surface's (x, z) vertices.  [tri_chk] is a boolean over the surface's   *)
(* stored ints and floats (exact rationals); [tri_chk_sound] says that     *)
(* when it holds, every such h is finite, |h| <= 16384, and h lies in      *)
(* [lo, hi].                                                                *)
(*                                                                          *)
(* The math: (1) with the vertex ranges checked, the edge tests do not     *)
(* wrap, so (X, Z) is in the closed triangle; (2) a point of the triangle *)
(* is a convex combination of the vertices (the edge values are the       *)
(* weights; their sum is the cross product D > 0), so the EXACT plane      *)
(* value P(X, Z) is between the plane values at the vertices; (3) the five *)
(* binary32 roundings move h from P by at most E (relative error 2^-24    *)
(* per step plus 2^-144 for the subnormal range), computed per triangle.  *)
(* ====================================================================== *)

From Coq Require Import ZArith Reals Lra Lia QArith Qreals.
From compcert Require Import Coqlib Floats Integers.
From Flocq Require Import Binary Bits Defs Raux Zaux Generic_fmt FLT Ulp Round_NE Relative.
From SM64.Proofs Require Import HeightInvariant.
From SM64.Proofs.WMotRRequiresA Require Import HeightFloatSteps FloorList FloorBound.

Local Open Scope R_scope.
Local Transparent Float32.mul Float32.add Float32.div Float32.neg.

Local Instance prec_gt_0_tb : FLX.Prec_gt_0 24.
Proof. red. lia. Qed.

(* ---------------------------------------------------------------------- *)
(* 1. Rounding: relative error.                                            *)
(* ---------------------------------------------------------------------- *)
Definition uR : R := bpow radix2 (-24).
Definition eR : R := bpow radix2 (-144).

Lemma rnd_rel : forall x, Rabs (rnd x - x) <= uR * Rabs x + eR.
Proof.
  intros x. unfold uR, eR.
  pose proof (bpow_ge_0 radix2 (-144)) as He.
  pose proof (bpow_ge_0 radix2 (-24)) as Hu.
  pose proof (Rabs_pos x) as Hx0.
  destruct (Rle_or_lt (bpow radix2 (-126)) (Rabs x)) as [H|H].
  - assert (R : Rabs (round radix2 (FLT_exp (-149) 24) (Znearest (fun z => negb (Z.even z))) x - x)
                <= / 2 * bpow radix2 (- 24 + 1) * Rabs x).
    { apply (@relative_error_N_FLT radix2 (-149) 24 prec_gt_0_tb). exact H. }
    assert (E : / 2 * bpow radix2 (- 24 + 1) = bpow radix2 (-24)).
    { rewrite bpow_plus. change (bpow radix2 1) with 2. lra. }
    rewrite E in R. change (round radix2 (FLT_exp (-149) 24) (Znearest (fun z => negb (Z.even z))) x)
      with (rnd x) in R. lra.
  - assert (Hx : Rabs x <= bpow radix2 (-120)).
    { apply Rlt_le. eapply Rlt_le_trans; [ exact H | apply bpow_le; lia ]. }
    pose proof (rnd_err x (-120) ltac:(lia) Hx) as R.
    replace (-120 - 24)%Z with (-144)%Z in R by lia.
    pose proof (Rmult_le_pos _ _ Hu Hx0). lra.
Qed.

Lemma uR_small : 0 <= uR <= / 1000.
Proof.
  unfold uR. split; [ apply bpow_ge_0 | ].
  change (bpow radix2 (-24)) with (/ IZR (Z.pow_pos 2 24)). simpl.
  apply Rinv_le_contravar; lra.
Qed.

Lemma eR_small : 0 <= eR <= / 1000.
Proof.
  unfold eR. split; [ apply bpow_ge_0 | ].
  change (bpow radix2 (-144)) with (/ IZR (Z.pow_pos 2 144)). simpl.
  apply Rinv_le_contravar; lra.
Qed.

Lemma f32_mul_val : forall a b, F32 a = true -> F32 b = true ->
  Rabs (R2 a * R2 b) <= bpow radix2 100 ->
  R2 (Float32.mul a b) = rnd (R2 a * R2 b) /\ F32 (Float32.mul a b) = true.
Proof.
  intros a b Fa Fb Hovf. unfold Float32.mul.
  match goal with |- context[Binary.Bmult ?p ?e ?g1 ?g2 ?nan ?md a b] =>
    pose proof (Binary.Bmult_correct p e g1 g2 nan md a b) as HB end.
  rewrite (no_overflow _ Hovf) in HB.
  destruct HB as (Hval & Hfin & _). split; [ exact Hval | ].
  rewrite Hfin, Fa, Fb. reflexivity.
Qed.

Lemma b30_le_b100 : forall z, Rabs z <= 1073741824 -> Rabs z <= bpow radix2 100.
Proof.
  intros z Hz. eapply Rle_trans; [ exact Hz | ].
  change 1073741824 with (bpow radix2 30). apply bpow_le. lia.
Qed.

(* ---------------------------------------------------------------------- *)
(* 2. Barycentric bound (exact reals).                                     *)
(* ---------------------------------------------------------------------- *)
Definition edge_r (X Z xi zi xj zj : R) : R := (zi - Z) * (xj - xi) - (xi - X) * (zj - zi).

Lemma bary : forall a b c X Z x1 z1 x2 z2 x3 z3,
  (edge_r X Z x1 z1 x2 z2 + edge_r X Z x2 z2 x3 z3 + edge_r X Z x3 z3 x1 z1) * (a * X + b * Z + c)
  = edge_r X Z x1 z1 x2 z2 * (a * x3 + b * z3 + c) + edge_r X Z x2 z2 x3 z3 * (a * x1 + b * z1 + c)
    + edge_r X Z x3 z3 x1 z1 * (a * x2 + b * z2 + c).
Proof. intros. unfold edge_r. ring. Qed.

Lemma bary_le : forall a b c X Z x1 z1 x2 z2 x3 z3 hi,
  0 <= edge_r X Z x1 z1 x2 z2 -> 0 <= edge_r X Z x2 z2 x3 z3 -> 0 <= edge_r X Z x3 z3 x1 z1 ->
  0 < edge_r X Z x1 z1 x2 z2 + edge_r X Z x2 z2 x3 z3 + edge_r X Z x3 z3 x1 z1 ->
  a * x1 + b * z1 + c <= hi -> a * x2 + b * z2 + c <= hi -> a * x3 + b * z3 + c <= hi ->
  a * X + b * Z + c <= hi.
Proof.
  intros a b c X Z x1 z1 x2 z2 x3 z3 hi E1 E2 E3 D F1 F2 F3.
  pose proof (bary a b c X Z x1 z1 x2 z2 x3 z3) as B.
  set (e1 := edge_r X Z x1 z1 x2 z2) in *. set (e2 := edge_r X Z x2 z2 x3 z3) in *.
  set (e3 := edge_r X Z x3 z3 x1 z1) in *.
  assert (P1 : 0 <= e1 * (hi - (a * x3 + b * z3 + c))) by (apply Rmult_le_pos; lra).
  assert (P2 : 0 <= e2 * (hi - (a * x1 + b * z1 + c))) by (apply Rmult_le_pos; lra).
  assert (P3 : 0 <= e3 * (hi - (a * x2 + b * z2 + c))) by (apply Rmult_le_pos; lra).
  destruct (Rle_or_lt (a * X + b * Z + c) hi) as [Hle|Hlt]; [ exact Hle | exfalso ].
  assert (0 < (e1 + e2 + e3) * (a * X + b * Z + c - hi)) by (apply Rmult_lt_0_compat; lra).
  nra.
Qed.

Lemma bary_ge : forall a b c X Z x1 z1 x2 z2 x3 z3 lo,
  0 <= edge_r X Z x1 z1 x2 z2 -> 0 <= edge_r X Z x2 z2 x3 z3 -> 0 <= edge_r X Z x3 z3 x1 z1 ->
  0 < edge_r X Z x1 z1 x2 z2 + edge_r X Z x2 z2 x3 z3 + edge_r X Z x3 z3 x1 z1 ->
  lo <= a * x1 + b * z1 + c -> lo <= a * x2 + b * z2 + c -> lo <= a * x3 + b * z3 + c ->
  lo <= a * X + b * Z + c.
Proof.
  intros a b c X Z x1 z1 x2 z2 x3 z3 lo E1 E2 E3 D F1 F2 F3.
  pose proof (bary_le (- a) (- b) (- c) X Z x1 z1 x2 z2 x3 z3 (- lo) E1 E2 E3 D
                ltac:(lra) ltac:(lra) ltac:(lra)). lra.
Qed.

(* ---------------------------------------------------------------------- *)
(* 3. Error accumulation of  rnd(rnd(rnd(A) + rnd(B)) + O).                 *)
(* ---------------------------------------------------------------------- *)
Definition ed_R (K : R) : R := 4 * (uR * (2 * K + 1) + eR).
Definition E_R (K NY : R) : R := ed_R K / NY + uR * (16384 + ed_R K / NY) + eR.

Lemma mul_abs_le : forall u a K, 0 <= u -> Rabs a <= K -> u * Rabs a <= u * K.
Proof. intros. apply Rmult_le_compat_l; assumption. Qed.

Lemma chain_err : forall A B O K,
  Rabs A + Rabs B + Rabs O <= K ->
  Rabs (rnd (rnd (rnd A + rnd B) + O) - (A + B + O)) <= ed_R K
  /\ Rabs (rnd A + rnd B) <= 2 * K + 1 /\ Rabs (rnd (rnd A + rnd B) + O) <= 2 * K + 1.
Proof.
  intros A B O K HK.
  pose proof uR_small as [Hu0 Hu1]. pose proof eR_small as [He0 He1].
  pose proof (Rabs_pos A). pose proof (Rabs_pos B). pose proof (Rabs_pos O).
  assert (HK0 : 0 <= K) by lra.
  pose proof (rnd_rel A) as RA. pose proof (rnd_rel B) as RB.
  assert (uA : uR * Rabs A <= uR * K) by (apply mul_abs_le; [ lra | lra ]).
  assert (uB : uR * Rabs B <= uR * K) by (apply mul_abs_le; [ lra | lra ]).
  assert (uK : uR * K <= K / 1000) by nra.
  assert (uK1 : uR * (2 * K + 1) <= (2 * K + 1) / 1000) by nra.
  set (a := rnd A) in *. set (b := rnd B) in *.
  assert (Hab : Rabs (a + b) <= 2 * K + 1).
  { apply Rabs_le_inv in RA. apply Rabs_le_inv in RB.
    pose proof (Rabs_triang (a - A) A). pose proof (Rabs_triang (b - B) B).
    assert (Rabs (a + b) <= Rabs a + Rabs b) by apply Rabs_triang.
    replace (a - A + A) with a in * by ring. replace (b - B + B) with b in * by ring.
    assert (Rabs (a - A) <= uR * Rabs A + eR) by (apply Rabs_le; lra).
    assert (Rabs (b - B) <= uR * Rabs B + eR) by (apply Rabs_le; lra).
    lra. }
  pose proof (rnd_rel (a + b)) as RC.
  assert (uC : uR * Rabs (a + b) <= uR * (2 * K + 1)) by (apply mul_abs_le; lra).
  set (c := rnd (a + b)) in *.
  assert (Hc : Rabs (c - (A + B)) <= 2 * (uR * K + eR) + uR * (2 * K + 1) + eR).
  { replace (c - (A + B)) with ((c - (a + b)) + (a - A) + (b - B)) by ring.
    pose proof (Rabs_triang ((c - (a + b)) + (a - A)) (b - B)).
    pose proof (Rabs_triang (c - (a + b)) (a - A)). lra. }
  assert (Hco : Rabs (c + O) <= 2 * K + 1).
  { replace (c + O) with ((c - (A + B)) + A + B + O) by ring.
    pose proof (Rabs_triang ((c - (A + B)) + A + B) O).
    pose proof (Rabs_triang ((c - (A + B)) + A) B).
    pose proof (Rabs_triang (c - (A + B)) A). lra. }
  pose proof (rnd_rel (c + O)) as RD.
  assert (uD : uR * Rabs (c + O) <= uR * (2 * K + 1)) by (apply mul_abs_le; lra).
  split; [ | split; [ exact Hab | exact Hco ] ].
  unfold ed_R.
  replace (rnd (c + O) - (A + B + O)) with ((rnd (c + O) - (c + O)) + (c - (A + B))) by ring.
  assert (uKK : uR * K <= uR * (2 * K + 1)) by (apply Rmult_le_compat_l; lra).
  pose proof (Rabs_triang (rnd (c + O) - (c + O)) (c - (A + B))). lra.
Qed.

(* the final division and rounding *)
Lemma div_err : forall d T NY K,
  0 < NY -> Rabs (d - T) <= ed_R K -> Rabs (- T / NY) <= 16384 -> ed_R K / NY <= 1 ->
  Rabs (rnd (- d / NY) - (- T / NY)) <= E_R K NY /\ Rabs (- d / NY) <= 16385.
Proof.
  intros d T NY K HNY Hd HP Hq.
  pose proof uR_small as [Hu0 Hu1]. pose proof eR_small as [He0 He1].
  assert (Hq1 : Rabs (- d / NY - - T / NY) <= ed_R K / NY).
  { replace (- d / NY - - T / NY) with (- (d - T) / NY) by (field; lra).
    unfold Rdiv. rewrite Rabs_mult, Rabs_Ropp, (Rabs_pos_eq (/ NY)) by (left; apply Rinv_0_lt_compat; lra).
    apply Rmult_le_compat_r; [ left; apply Rinv_0_lt_compat; lra | exact Hd ]. }
  assert (Hqb : Rabs (- d / NY) <= 16384 + ed_R K / NY).
  { replace (- d / NY) with ((- d / NY - - T / NY) + - T / NY) by ring.
    pose proof (Rabs_triang (- d / NY - - T / NY) (- T / NY)). lra. }
  pose proof (rnd_rel (- d / NY)) as R.
  assert (uq : uR * Rabs (- d / NY) <= uR * (16384 + ed_R K / NY)) by (apply mul_abs_le; lra).
  split; [ | lra ].
  unfold E_R.
  replace (rnd (- d / NY) - - T / NY) with ((rnd (- d / NY) - - d / NY) + (- d / NY - - T / NY)) by ring.
  pose proof (Rabs_triang (rnd (- d / NY) - - d / NY) (- d / NY - - T / NY)). lra.
Qed.

(* ---------------------------------------------------------------------- *)
(* 4. The real-number theorem for one triangle.                            *)
(* ---------------------------------------------------------------------- *)
Definition Pv (NX NY NZ OO x z : R) : R := - (x * NX + NZ * z + OO) / NY.

Lemma Pv_affine : forall NX NY NZ OO x z, NY <> 0 ->
  Pv NX NY NZ OO x z = (- NX / NY) * x + (- NZ / NY) * z + (- OO / NY).
Proof. intros. unfold Pv. field. assumption. Qed.

Lemma plane_real : forall NX NY NZ OO X Z x1 z1 x2 z2 x3 z3 K lo hi,
  0 < NY -> 0 <= K ->
  0 <= edge_r X Z x1 z1 x2 z2 -> 0 <= edge_r X Z x2 z2 x3 z3 -> 0 <= edge_r X Z x3 z3 x1 z1 ->
  0 < edge_r X Z x1 z1 x2 z2 + edge_r X Z x2 z2 x3 z3 + edge_r X Z x3 z3 x1 z1 ->
  ed_R K / NY <= 1 ->
  (forall x z, (x = x1 /\ z = z1) \/ (x = x2 /\ z = z2) \/ (x = x3 /\ z = z3) ->
     lo + E_R K NY <= Pv NX NY NZ OO x z <= hi - E_R K NY
     /\ - 16384 + E_R K NY <= Pv NX NY NZ OO x z <= 16384 - E_R K NY) ->
  forall d, Rabs (d - (X * NX + NZ * Z + OO)) <= ed_R K ->
  lo <= rnd (- d / NY) <= hi /\ Rabs (rnd (- d / NY)) <= 16384 /\ Rabs (- d / NY) <= 16385.
Proof.
  intros NX NY NZ OO X Z x1 z1 x2 z2 x3 z3 K lo hi HNY HK0 E1 E2 E3 D Hed Hv d Hd.
  assert (NY0 : NY <> 0) by lra.
  destruct (Hv x1 z1 ltac:(auto)) as [[L1 H1] [M1 N1]].
  destruct (Hv x2 z2 ltac:(auto)) as [[L2 H2] [M2 N2]].
  destruct (Hv x3 z3 ltac:(auto)) as [[L3 H3] [M3 N3]].
  clear Hv. rewrite Pv_affine in * by exact NY0.
  set (a := - NX / NY) in *. set (b := - NZ / NY) in *. set (c := - OO / NY) in *.
  pose proof (bary_le a b c X Z x1 z1 x2 z2 x3 z3 _ E1 E2 E3 D H1 H2 H3) as Hhi.
  pose proof (bary_ge a b c X Z x1 z1 x2 z2 x3 z3 _ E1 E2 E3 D L1 L2 L3) as Hlo.
  pose proof (bary_le a b c X Z x1 z1 x2 z2 x3 z3 _ E1 E2 E3 D N1 N2 N3) as Nhi.
  pose proof (bary_ge a b c X Z x1 z1 x2 z2 x3 z3 _ E1 E2 E3 D M1 M2 M3) as Nlo.
  assert (HP : - (X * NX + NZ * Z + OO) / NY = a * X + b * Z + c) by (unfold a, b, c; field; exact NY0).
  assert (HE : 0 <= E_R K NY).
  { pose proof uR_small. pose proof eR_small.
    assert (Hi : 0 <= / NY) by (left; apply Rinv_0_lt_compat; lra).
    assert (He : 0 <= ed_R K) by (unfold ed_R; nra).
    unfold E_R. unfold Rdiv. assert (0 <= ed_R K * / NY) by (apply Rmult_le_pos; lra). nra. }
  assert (HPa : Rabs (- (X * NX + NZ * Z + OO) / NY) <= 16384) by (rewrite HP; apply Rabs_le; lra).
  destruct (div_err d (X * NX + NZ * Z + OO) NY K HNY Hd HPa Hed) as [Herr Hq].
  apply Rabs_le_inv in Herr. rewrite HP in Herr.
  split; [ lra | split; [ apply Rabs_le; lra | exact Hq ] ].
Qed.

(* ---------------------------------------------------------------------- *)
(* 5. The int32 edge tests do not wrap.                                    *)
(* ---------------------------------------------------------------------- *)
Definition edge_z (x z xi zi xj zj : Z) : Z := (zi - z) * (xj - xi) - (xi - x) * (zj - zi).
Definition cross_z (x1 z1 x2 z2 x3 z3 : Z) : Z := (z2 - z1) * (x3 - x2) - (x2 - x1) * (z3 - z2).

Lemma edge_sum : forall x z x1 z1 x2 z2 x3 z3,
  (edge_z x z x1 z1 x2 z2 + edge_z x z x2 z2 x3 z3 + edge_z x z x3 z3 x1 z1)%Z = cross_z x1 z1 x2 z2 x3 z3.
Proof. intros. unfold edge_z, cross_z. ring. Qed.

Lemma edge_IZR : forall x z xi zi xj zj,
  IZR (edge_z x z xi zi xj zj) = edge_r (IZR x) (IZR z) (IZR xi) (IZR zi) (IZR xj) (IZR zj).
Proof. intros. unfold edge_z, edge_r. repeat rewrite ?minus_IZR, ?mult_IZR. reflexivity. Qed.

Lemma abs_mul_le : forall a b A B, (Z.abs a <= A -> Z.abs b <= B -> Z.abs (a * b) <= A * B)%Z.
Proof. intros. rewrite Z.abs_mul. apply Z.mul_le_mono_nonneg; lia. Qed.

Lemma signed_sub : forall a b,
  (Int.min_signed <= Int.signed a - Int.signed b <= Int.max_signed)%Z ->
  Int.signed (Int.sub a b) = (Int.signed a - Int.signed b)%Z.
Proof. intros. rewrite Int.sub_signed. apply Int.signed_repr. exact H. Qed.

Lemma signed_mul : forall a b,
  (Int.min_signed <= Int.signed a * Int.signed b <= Int.max_signed)%Z ->
  Int.signed (Int.mul a b) = (Int.signed a * Int.signed b)%Z.
Proof. intros. rewrite Int.mul_signed. apply Int.signed_repr. exact H. Qed.

Lemma edge_ok_z : forall (X Z xi zi xj zj : int) V dm,
  (Z.abs (Int.signed X) <= 32768)%Z -> (Z.abs (Int.signed Z) <= 32768)%Z ->
  (0 <= V <= 32768)%Z -> (0 <= dm)%Z ->
  (Z.abs (Int.signed xi) <= V)%Z -> (Z.abs (Int.signed zi) <= V)%Z ->
  (Z.abs (Int.signed xj - Int.signed xi) <= dm)%Z -> (Z.abs (Int.signed zj - Int.signed zi) <= dm)%Z ->
  (2 * ((V + 32768) * dm) < 2147483648)%Z ->
  edge_ok X Z xi zi xj zj = true ->
  (0 <= edge_z (Int.signed X) (Int.signed Z) (Int.signed xi) (Int.signed zi)
               (Int.signed xj) (Int.signed zj))%Z.
Proof.
  intros X Z xi zi xj zj V dm HX HZ HV Hdm Hxi Hzi Hdx Hdz Hb E.
  unfold edge_ok in E.
  change Int.zero with (Int.repr 0) in E.
  assert (Hmin : Int.min_signed = (-2147483648)%Z) by reflexivity.
  assert (Hmax : Int.max_signed = 2147483647%Z) by reflexivity.
  assert (S1 : Int.signed (Int.sub zi Z) = (Int.signed zi - Int.signed Z)%Z)
    by (apply signed_sub; lia).
  assert (S2 : Int.signed (Int.sub xj xi) = (Int.signed xj - Int.signed xi)%Z)
    by (apply signed_sub; lia).
  assert (S3 : Int.signed (Int.sub xi X) = (Int.signed xi - Int.signed X)%Z)
    by (apply signed_sub; lia).
  assert (S4 : Int.signed (Int.sub zj zi) = (Int.signed zj - Int.signed zi)%Z)
    by (apply signed_sub; lia).
  assert (B1 : (Z.abs ((Int.signed zi - Int.signed Z) * (Int.signed xj - Int.signed xi))
                <= (V + 32768) * dm)%Z) by (apply abs_mul_le; lia).
  assert (B2 : (Z.abs ((Int.signed xi - Int.signed X) * (Int.signed zj - Int.signed zi))
                <= (V + 32768) * dm)%Z) by (apply abs_mul_le; lia).
  assert (M1 : Int.signed (Int.mul (Int.sub zi Z) (Int.sub xj xi))
               = ((Int.signed zi - Int.signed Z) * (Int.signed xj - Int.signed xi))%Z)
    by (rewrite signed_mul; rewrite ?S1, ?S2; [ reflexivity | lia ]).
  assert (M2 : Int.signed (Int.mul (Int.sub xi X) (Int.sub zj zi))
               = ((Int.signed xi - Int.signed X) * (Int.signed zj - Int.signed zi))%Z)
    by (rewrite signed_mul; rewrite ?S3, ?S4; [ reflexivity | lia ]).
  assert (M3 : Int.signed (Int.sub (Int.mul (Int.sub zi Z) (Int.sub xj xi))
                                   (Int.mul (Int.sub xi X) (Int.sub zj zi)))
               = edge_z (Int.signed X) (Int.signed Z) (Int.signed xi) (Int.signed zi)
                        (Int.signed xj) (Int.signed zj)).
  { rewrite signed_sub; rewrite M1, M2; [ reflexivity | lia ]. }
  unfold Int.lt in E. rewrite M3, Int.signed_repr in E by (rewrite Hmin, Hmax; lia).
  destruct (zlt _ 0); [ discriminate | lia ].
Qed.

(* ---------------------------------------------------------------------- *)
(* 6. The per-triangle check, in exact rationals.                          *)
(* ---------------------------------------------------------------------- *)
Definition qabs (q : Q) : Q := if Qle_bool 0 q then q else (- q)%Q.

(* a finite binary32 as the exact rational it denotes *)
Definition f2q (f : float32) : Q :=
  match f with
  | B754_finite _ _ s m e _ =>
      let n := cond_Zopp s (Zpos m) in
      match e with
      | Z0 => inject_Z n
      | Zpos p => inject_Z (n * Z.pow_pos 2 p)
      | Zneg p => Qmake n (Pos.pow 2 p)
      end
  | _ => 0%Q
  end.

Definition uQ : Q := Qmake 1 (Pos.pow 2 24).
Definition eQ : Q := Qmake 1 (Pos.pow 2 144).
Definition edQ (K : Q) : Q := (4 * (uQ * (2 * K + 1) + eQ))%Q.
Definition EQ (K NY : Q) : Q := (edQ K / NY + uQ * (16384 + edQ K / NY) + eQ)%Q.
Definition PQ (NX NY NZ OO : Q) (x z : Z) : Q := (- (inject_Z x * NX + NZ * inject_Z z + OO) / NY)%Q.

Lemma Q2R_inject : forall z, Q2R (inject_Z z) = IZR z.
Proof. intros. unfold Q2R. simpl. rewrite Rinv_1. ring. Qed.

Lemma Q2R_num : forall z, Q2R (Qmake z 1) = IZR z.
Proof. intros. unfold Q2R. simpl. rewrite Rinv_1. ring. Qed.

Lemma Q2R_0 : Q2R 0 = 0.
Proof. unfold Q2R. simpl. ring. Qed.

Lemma Q2R_qabs : forall q, Q2R (qabs q) = Rabs (Q2R q).
Proof.
  intros q. unfold qabs. destruct (Qle_bool 0 q) eqn:E.
  - apply Qle_bool_iff in E. apply Qle_Rle in E. rewrite Q2R_0 in E.
    rewrite Rabs_pos_eq by exact E. reflexivity.
  - assert (L : (q < 0)%Q).
    { apply Qnot_le_lt. intros C. apply Qle_bool_iff in C. congruence. }
    apply Qlt_Rlt in L. rewrite Q2R_0 in L.
    rewrite Q2R_opp, Rabs_left by exact L. reflexivity.
Qed.

Lemma Q2R_uQ : Q2R uQ = uR.
Proof.
  unfold uQ, uR, Q2R. cbn [Qnum Qden bpow]. rewrite Pos2Z.inj_pow_pos. simpl (radix_val radix2).
  rewrite Rmult_1_l. reflexivity.
Qed.

Lemma Q2R_eQ : Q2R eQ = eR.
Proof.
  unfold eQ, eR, Q2R. cbn [Qnum Qden bpow]. rewrite Pos2Z.inj_pow_pos. simpl (radix_val radix2).
  rewrite Rmult_1_l. reflexivity.
Qed.

Lemma f2q_ok : forall f, F32 f = true -> Q2R (f2q f) = R2 f.
Proof.
  intros [s|s| |s m e Hb] F; try discriminate.
  - simpl. rewrite Q2R_0. reflexivity.
  - unfold f2q, Binary.B2R, F2R. cbn [Fnum Fexp].
    destruct e as [|p|p].
    + rewrite Q2R_inject. simpl (bpow radix2 0). ring.
    + rewrite Q2R_inject, mult_IZR. reflexivity.
    + unfold Q2R. cbn [Qnum Qden]. rewrite Pos2Z.inj_pow_pos. reflexivity.
Qed.

Lemma Q2R_edQ : forall K, Q2R (edQ K) = ed_R (Q2R K).
Proof.
  intros. unfold edQ, ed_R.
  rewrite Q2R_mult, Q2R_plus, Q2R_mult, Q2R_plus, Q2R_mult, Q2R_uQ, Q2R_eQ, !Q2R_num.
  reflexivity.
Qed.

Lemma Q2R_EQ : forall K NY, ~ (NY == 0)%Q -> Q2R (EQ K NY) = E_R (Q2R K) (Q2R NY).
Proof.
  intros K NY H. unfold EQ, E_R.
  rewrite !Q2R_plus, Q2R_mult, Q2R_plus, !Q2R_div by exact H.
  rewrite Q2R_edQ, Q2R_uQ, Q2R_eQ, Q2R_num. reflexivity.
Qed.

Lemma Q2R_PQ : forall NX NY NZ OO x z, ~ (NY == 0)%Q ->
  Q2R (PQ NX NY NZ OO x z) = Pv (Q2R NX) (Q2R NY) (Q2R NZ) (Q2R OO) (IZR x) (IZR z).
Proof.
  intros. unfold PQ, Pv.
  rewrite Q2R_div by assumption. rewrite Q2R_opp, !Q2R_plus, !Q2R_mult, !Q2R_inject.
  reflexivity.
Qed.

Lemma Qle_R : forall a b, Qle_bool a b = true -> Q2R a <= Q2R b.
Proof. intros a b H. apply Qle_Rle. apply Qle_bool_iff. exact H. Qed.

Definition vtx_ok (NX NY NZ OO K : Q) (ylo yhi x z : Z) : bool :=
  let P := PQ NX NY NZ OO x z in
  let E := EQ K NY in
  Qle_bool (inject_Z (ylo - 1) + E) P && Qle_bool P (inject_Z (yhi + 1) - E)
  && Qle_bool (-16384 + E) P && Qle_bool P (16384 - E).

Lemma vtx_ok_sound : forall NX NY NZ OO K ylo yhi x z, ~ (NY == 0)%Q ->
  vtx_ok NX NY NZ OO K ylo yhi x z = true ->
  (IZR ylo - 1 + E_R (Q2R K) (Q2R NY) <= Pv (Q2R NX) (Q2R NY) (Q2R NZ) (Q2R OO) (IZR x) (IZR z)
     <= IZR yhi + 1 - E_R (Q2R K) (Q2R NY))
  /\ (- 16384 + E_R (Q2R K) (Q2R NY) <= Pv (Q2R NX) (Q2R NY) (Q2R NZ) (Q2R OO) (IZR x) (IZR z)
     <= 16384 - E_R (Q2R K) (Q2R NY)).
Proof.
  intros NX NY NZ OO K ylo yhi x z HNY H. unfold vtx_ok in H.
  apply andb_prop in H as [H H4]. apply andb_prop in H as [H H3]. apply andb_prop in H as [H1 H2].
  apply Qle_R in H1, H2, H3, H4.
  rewrite Q2R_PQ in H1, H2, H3, H4 by exact HNY.
  cbv zeta in H1, H2, H3, H4.
  rewrite Q2R_plus in H1, H3. rewrite Q2R_minus in H2, H4.
  rewrite Q2R_EQ in H1, H2, H3, H4 by exact HNY.
  assert (A1 : Q2R (inject_Z (ylo - 1)) = IZR ylo - 1)
    by (unfold Q2R, inject_Z; cbn [Qnum Qden]; rewrite minus_IZR; simpl; lra).
  assert (A2 : Q2R (inject_Z (yhi + 1)) = IZR yhi + 1)
    by (unfold Q2R, inject_Z; cbn [Qnum Qden]; rewrite plus_IZR; simpl; lra).
  assert (A3 : Q2R (-16384) = -16384) by (unfold Q2R; simpl; lra).
  assert (A4 : Q2R 16384 = 16384) by (unfold Q2R; simpl; lra).
  rewrite A1 in H1. rewrite A2 in H2. rewrite A3 in H3. rewrite A4 in H4.
  repeat split; lra.
Qed.

Definition zmax3 (a b c : Z) : Z := Z.max a (Z.max b c).

(* the largest |coordinate| and the largest |edge delta| *)
Definition XMf (x1 x2 x3 : int) : Z :=
  zmax3 (Z.abs (Int.signed x1)) (Z.abs (Int.signed x2)) (Z.abs (Int.signed x3)).
Definition dmf (x1 z1 x2 z2 x3 z3 : int) : Z :=
  Z.max (zmax3 (Z.abs (Int.signed x2 - Int.signed x1)) (Z.abs (Int.signed x3 - Int.signed x2))
               (Z.abs (Int.signed x1 - Int.signed x3)))
        (zmax3 (Z.abs (Int.signed z2 - Int.signed z1)) (Z.abs (Int.signed z3 - Int.signed z2))
               (Z.abs (Int.signed z1 - Int.signed z3))).
Definition Kq (XM ZM : Z) (nx nz oo : float32) : Q :=
  (inject_Z XM * qabs (f2q nx) + inject_Z ZM * qabs (f2q nz) + qabs (f2q oo))%Q.

Definition tri_chk (x1 z1 x2 z2 x3 z3 : int) (nx ny nz oo : float32) (ylo yhi : Z) : bool :=
  F32 nx && F32 ny && F32 nz && F32 oo
  && (Z.max (XMf x1 x2 x3) (XMf z1 z2 z3) <=? 32768)%Z
  && (2 * ((Z.max (XMf x1 x2 x3) (XMf z1 z2 z3) + 32768) * dmf x1 z1 x2 z2 x3 z3) <? 2147483648)%Z
  && (0 <? cross_z (Int.signed x1) (Int.signed z1) (Int.signed x2) (Int.signed z2)
                   (Int.signed x3) (Int.signed z3))%Z
  && negb (Qle_bool (f2q ny) 0)
  && Qle_bool (Kq (XMf x1 x2 x3) (XMf z1 z2 z3) nx nz oo) 268435456
  && Qle_bool (edQ (Kq (XMf x1 x2 x3) (XMf z1 z2 z3) nx nz oo) / f2q ny) 1
  && vtx_ok (f2q nx) (f2q ny) (f2q nz) (f2q oo) (Kq (XMf x1 x2 x3) (XMf z1 z2 z3) nx nz oo)
            ylo yhi (Int.signed x1) (Int.signed z1)
  && vtx_ok (f2q nx) (f2q ny) (f2q nz) (f2q oo) (Kq (XMf x1 x2 x3) (XMf z1 z2 z3) nx nz oo)
            ylo yhi (Int.signed x2) (Int.signed z2)
  && vtx_ok (f2q nx) (f2q ny) (f2q nz) (f2q oo) (Kq (XMf x1 x2 x3) (XMf z1 z2 z3) nx nz oo)
            ylo yhi (Int.signed x3) (Int.signed z3).

Lemma s16_abs : forall X, Int.sign_ext 16 X = X -> (Z.abs (Int.signed X) <= 32768)%Z.
Proof.
  intros X H. rewrite <- H.
  pose proof (Int.sign_ext_range 16 X ltac:(cbn; lia)) as R.
  change (two_p (16 - 1)) with 32768%Z in R. lia.
Qed.

Lemma XMf_ge : forall x1 x2 x3,
  (Z.abs (Int.signed x1) <= XMf x1 x2 x3 /\ Z.abs (Int.signed x2) <= XMf x1 x2 x3
   /\ Z.abs (Int.signed x3) <= XMf x1 x2 x3 /\ 0 <= XMf x1 x2 x3)%Z.
Proof. intros. unfold XMf, zmax3. lia. Qed.

Lemma dmf_ge : forall x1 z1 x2 z2 x3 z3,
  (Z.abs (Int.signed x2 - Int.signed x1) <= dmf x1 z1 x2 z2 x3 z3
   /\ Z.abs (Int.signed x3 - Int.signed x2) <= dmf x1 z1 x2 z2 x3 z3
   /\ Z.abs (Int.signed x1 - Int.signed x3) <= dmf x1 z1 x2 z2 x3 z3
   /\ Z.abs (Int.signed z2 - Int.signed z1) <= dmf x1 z1 x2 z2 x3 z3
   /\ Z.abs (Int.signed z3 - Int.signed z2) <= dmf x1 z1 x2 z2 x3 z3
   /\ Z.abs (Int.signed z1 - Int.signed z3) <= dmf x1 z1 x2 z2 x3 z3
   /\ 0 <= dmf x1 z1 x2 z2 x3 z3)%Z.
Proof. intros. unfold dmf, zmax3. lia. Qed.

Lemma edge_ok_tri : forall (X Z xi zi xj zj : int) XM ZM dm,
  (Z.abs (Int.signed X) <= 32768)%Z -> (Z.abs (Int.signed Z) <= 32768)%Z ->
  (0 <= XM)%Z -> (0 <= ZM)%Z -> (Z.max XM ZM <= 32768)%Z -> (0 <= dm)%Z ->
  (2 * ((Z.max XM ZM + 32768) * dm) < 2147483648)%Z ->
  (Z.abs (Int.signed xi) <= XM)%Z -> (Z.abs (Int.signed zi) <= ZM)%Z ->
  (Z.abs (Int.signed xj - Int.signed xi) <= dm)%Z -> (Z.abs (Int.signed zj - Int.signed zi) <= dm)%Z ->
  edge_ok X Z xi zi xj zj = true ->
  (0 <= edge_z (Int.signed X) (Int.signed Z) (Int.signed xi) (Int.signed zi)
               (Int.signed xj) (Int.signed zj))%Z.
Proof.
  intros X Z xi zi xj zj XM ZM dm AX AZ H1 H2 H3 H4 H5 H6 H7 H8 H9 E.
  apply (edge_ok_z X Z xi zi xj zj (Z.max XM ZM) dm AX AZ ltac:(lia) H4 ltac:(lia) ltac:(lia)
           H8 H9 H5 E).
Qed.

Lemma Q2R_Kq : forall XM ZM nx nz oo, F32 nx = true -> F32 nz = true -> F32 oo = true ->
  Q2R (Kq XM ZM nx nz oo) = IZR XM * Rabs (R2 nx) + IZR ZM * Rabs (R2 nz) + Rabs (R2 oo).
Proof.
  intros. unfold Kq. rewrite !Q2R_plus, !Q2R_mult, !Q2R_inject, !Q2R_qabs, !f2q_ok by assumption.
  reflexivity.
Qed.

(* the vertex range bounds the point, through the barycentric lemma *)
Lemma in_tri_abs : forall X Z x1 z1 x2 z2 x3 z3 M (sel : R -> R -> R),
  (forall x z, sel x z = x) \/ (forall x z, sel x z = z) ->
  0 <= edge_r X Z x1 z1 x2 z2 -> 0 <= edge_r X Z x2 z2 x3 z3 -> 0 <= edge_r X Z x3 z3 x1 z1 ->
  0 < edge_r X Z x1 z1 x2 z2 + edge_r X Z x2 z2 x3 z3 + edge_r X Z x3 z3 x1 z1 ->
  Rabs (sel x1 z1) <= M -> Rabs (sel x2 z2) <= M -> Rabs (sel x3 z3) <= M ->
  Rabs (sel X Z) <= M.
Proof.
  intros X Z x1 z1 x2 z2 x3 z3 M sel Hs G1 G2 G3 GD B1 B2 B3.
  apply Rabs_le_inv in B1, B2, B3. apply Rabs_le.
  destruct Hs as [Hs|Hs]; rewrite !Hs in *.
  - pose proof (bary_le 1 0 0 _ _ _ _ _ _ _ _ M G1 G2 G3 GD ltac:(lra) ltac:(lra) ltac:(lra)).
    pose proof (bary_ge 1 0 0 _ _ _ _ _ _ _ _ (- M) G1 G2 G3 GD ltac:(lra) ltac:(lra) ltac:(lra)).
    lra.
  - pose proof (bary_le 0 1 0 _ _ _ _ _ _ _ _ M G1 G2 G3 GD ltac:(lra) ltac:(lra) ltac:(lra)).
    pose proof (bary_ge 0 1 0 _ _ _ _ _ _ _ _ (- M) G1 G2 G3 GD ltac:(lra) ltac:(lra) ltac:(lra)).
    lra.
Qed.

Lemma IZR_abs_le : forall a M, (Z.abs a <= M)%Z -> Rabs (IZR a) <= IZR M.
Proof. intros. rewrite <- abs_IZR. apply IZR_le. exact H. Qed.

Theorem tri_chk_sound : forall (X Z x1 z1 x2 z2 x3 z3 : int) nx ny nz oo ylo yhi,
  tri_chk x1 z1 x2 z2 x3 z3 nx ny nz oo ylo yhi = true ->
  Int.sign_ext 16 X = X -> Int.sign_ext 16 Z = Z ->
  edge_ok X Z x1 z1 x2 z2 = true -> edge_ok X Z x2 z2 x3 z3 = true ->
  edge_ok X Z x3 z3 x1 z1 = true ->
  F32 (plane_h X Z nx ny nz oo) = true
  /\ Rabs (R2 (plane_h X Z nx ny nz oo)) <= 16384
  /\ IZR ylo - 1 <= R2 (plane_h X Z nx ny nz oo) <= IZR yhi + 1.
Proof.
  intros X Z x1 z1 x2 z2 x3 z3 nx ny nz oo ylo yhi C SX SZ E1 E2 E3.
  unfold tri_chk in C.
  apply andb_prop in C as [C V3]. apply andb_prop in C as [C V2]. apply andb_prop in C as [C V1].
  apply andb_prop in C as [C Hedq]. apply andb_prop in C as [C HKq].
  apply andb_prop in C as [C HNYq]. apply andb_prop in C as [C HD].
  apply andb_prop in C as [C Hwrap]. apply andb_prop in C as [C HV].
  apply andb_prop in C as [C Foo]. apply andb_prop in C as [C Fnz]. apply andb_prop in C as [Fnx Fny].
  apply Z.leb_le in HV. apply Z.ltb_lt in Hwrap. apply Z.ltb_lt in HD.
  apply Qle_R in HKq, Hedq.
  set (XM := XMf x1 x2 x3) in *. set (ZM := XMf z1 z2 z3) in *.
  set (dm := dmf x1 z1 x2 z2 x3 z3) in *.
  set (K := Kq XM ZM nx nz oo) in *.
  pose proof (XMf_ge x1 x2 x3) as (Ax1 & Ax2 & Ax3 & AX0). fold XM in Ax1, Ax2, Ax3, AX0.
  pose proof (XMf_ge z1 z2 z3) as (Az1 & Az2 & Az3 & AZ0). fold ZM in Az1, Az2, Az3, AZ0.
  pose proof (dmf_ge x1 z1 x2 z2 x3 z3) as (D1 & D2 & D3 & D4 & D5 & D6 & D0).
  fold dm in D1, D2, D3, D4, D5, D6, D0.
  (* the floats as reals *)
  assert (NYpos : (0 < f2q ny)%Q).
  { apply Qnot_le_lt. intros Cn. apply Qle_bool_iff in Cn. rewrite Cn in HNYq. discriminate. }
  assert (NY0 : ~ (f2q ny == 0)%Q).
  { intros Ce. rewrite Ce in NYpos. discriminate. }
  apply Qlt_Rlt in NYpos. rewrite Q2R_0, (f2q_ok ny Fny) in NYpos.
  apply (vtx_ok_sound _ _ _ _ _ _ _ _ _ NY0) in V1, V2, V3.
  rewrite Q2R_div, Q2R_edQ in Hedq by exact NY0.
  assert (E1q : Q2R 1 = 1) by (unfold Q2R; simpl; lra).
  assert (E2q : Q2R 268435456 = 268435456) by (unfold Q2R; simpl; lra).
  rewrite E1q in Hedq. rewrite E2q in HKq.
  rewrite !(f2q_ok _ Fnx), !(f2q_ok _ Fny), !(f2q_ok _ Fnz), !(f2q_ok _ Foo) in V1, V2, V3.
  rewrite (f2q_ok _ Fny) in Hedq.
  pose proof (Q2R_Kq XM ZM nx nz oo Fnx Fnz Foo) as HK. fold K in HK.
  (* the edges *)
  pose proof (s16_abs X SX) as AX. pose proof (s16_abs Z SZ) as AZ.
  pose proof (edge_ok_tri X Z x1 z1 x2 z2 XM ZM dm AX AZ AX0 AZ0 HV D0 Hwrap Ax1 Az1 D1 D4 E1) as G1.
  pose proof (edge_ok_tri X Z x2 z2 x3 z3 XM ZM dm AX AZ AX0 AZ0 HV D0 Hwrap Ax2 Az2 D2 D5 E2) as G2.
  pose proof (edge_ok_tri X Z x3 z3 x1 z1 XM ZM dm AX AZ AX0 AZ0 HV D0 Hwrap Ax3 Az3 D3 D6 E3) as G3.
  pose proof (edge_sum (Int.signed X) (Int.signed Z) (Int.signed x1) (Int.signed z1)
                (Int.signed x2) (Int.signed z2) (Int.signed x3) (Int.signed z3)) as GS.
  apply IZR_le in G1, G2, G3. rewrite edge_IZR in G1, G2, G3.
  assert (GD : 0 < edge_r (IZR (Int.signed X)) (IZR (Int.signed Z)) (IZR (Int.signed x1))
                          (IZR (Int.signed z1)) (IZR (Int.signed x2)) (IZR (Int.signed z2))
               + edge_r (IZR (Int.signed X)) (IZR (Int.signed Z)) (IZR (Int.signed x2))
                          (IZR (Int.signed z2)) (IZR (Int.signed x3)) (IZR (Int.signed z3))
               + edge_r (IZR (Int.signed X)) (IZR (Int.signed Z)) (IZR (Int.signed x3))
                          (IZR (Int.signed z3)) (IZR (Int.signed x1)) (IZR (Int.signed z1))).
  { rewrite <- !edge_IZR, <- !plus_IZR, GS. apply IZR_lt. exact HD. }
  (* (X, Z) is in the triangle, so |X| <= XM, |Z| <= ZM *)
  assert (BX : Rabs (IZR (Int.signed X)) <= IZR XM).
  { apply (in_tri_abs _ _ _ _ _ _ _ _ _ (fun x _ => x) (or_introl (fun _ _ => eq_refl))
             G1 G2 G3 GD); apply IZR_abs_le; assumption. }
  assert (BZ : Rabs (IZR (Int.signed Z)) <= IZR ZM).
  { apply (in_tri_abs _ _ _ _ _ _ _ _ _ (fun _ z => z) (or_intror (fun _ _ => eq_refl))
             G1 G2 G3 GD); apply IZR_abs_le; assumption. }
  (* the binary32 chain *)
  assert (AA : Rabs (IZR (Int.signed X) * R2 nx) <= IZR XM * Rabs (R2 nx)).
  { rewrite Rabs_mult. apply Rmult_le_compat_r; [ apply Rabs_pos | exact BX ]. }
  assert (AB : Rabs (R2 nz * IZR (Int.signed Z)) <= IZR ZM * Rabs (R2 nz)).
  { rewrite Rabs_mult, Rmult_comm. apply Rmult_le_compat_r; [ apply Rabs_pos | exact BZ ]. }
  assert (HKs : Rabs (IZR (Int.signed X) * R2 nx) + Rabs (R2 nz * IZR (Int.signed Z)) + Rabs (R2 oo)
                <= Q2R K) by lra.
  pose proof (Rabs_pos (IZR (Int.signed X) * R2 nx)).
  pose proof (Rabs_pos (R2 nz * IZR (Int.signed Z))). pose proof (Rabs_pos (R2 oo)).
  assert (KR0 : 0 <= Q2R K) by lra.
  assert (XMb : IZR XM <= 32768) by (apply IZR_le; eapply Z.le_trans; [ apply Z.le_max_l | exact HV ]).
  assert (ZMb : IZR ZM <= 32768) by (apply IZR_le; eapply Z.le_trans; [ apply Z.le_max_r | exact HV ]).
  destruct (of_int_val X ltac:(lra)) as [RX FX].
  destruct (of_int_val Z ltac:(lra)) as [RZ FZ].
  destruct (chain_err (IZR (Int.signed X) * R2 nx) (R2 nz * IZR (Int.signed Z)) (R2 oo) (Q2R K) HKs)
    as (Hed & Hab & Hco).
  unfold plane_h.
  destruct (f32_mul_val (Float32.of_int X) nx FX Fnx) as [Ra Fa].
  { rewrite RX. apply b30_le_b100. lra. }
  destruct (f32_mul_val nz (Float32.of_int Z) Fnz FZ) as [Rb Fb].
  { rewrite RZ. apply b30_le_b100. lra. }
  rewrite RX in Ra. rewrite RZ in Rb.
  destruct (f32_add_val _ _ Fa Fb) as [Rc Fc].
  { rewrite Ra, Rb. apply b30_le_b100. lra. }
  rewrite Ra, Rb in Rc.
  destruct (f32_add_val _ oo Fc Foo) as [Rd Fd].
  { rewrite Rc. apply b30_le_b100. lra. }
  rewrite Rc in Rd.
  destruct (neg_val (Float32.add (Float32.add (Float32.mul (Float32.of_int X) nx)
                                              (Float32.mul nz (Float32.of_int Z))) oo)) as [Rn Fn].
  rewrite Fd in Fn. rewrite Rd in Rn.
  assert (Hv : forall x z,
      (x = IZR (Int.signed x1) /\ z = IZR (Int.signed z1))
      \/ (x = IZR (Int.signed x2) /\ z = IZR (Int.signed z2))
      \/ (x = IZR (Int.signed x3) /\ z = IZR (Int.signed z3)) ->
      IZR ylo - 1 + E_R (Q2R K) (R2 ny) <= Pv (R2 nx) (R2 ny) (R2 nz) (R2 oo) x z
        <= IZR yhi + 1 - E_R (Q2R K) (R2 ny)
      /\ - 16384 + E_R (Q2R K) (R2 ny) <= Pv (R2 nx) (R2 ny) (R2 nz) (R2 oo) x z
        <= 16384 - E_R (Q2R K) (R2 ny)).
  { intros x z [[-> ->]|[[-> ->]|[-> ->]]]; assumption. }
  destruct (plane_real (R2 nx) (R2 ny) (R2 nz) (R2 oo) _ _ _ _ _ _ _ _ (Q2R K) (IZR ylo - 1) (IZR yhi + 1)
              NYpos KR0 G1 G2 G3 GD Hedq Hv _ Hed) as (Hlh & Habs & Hq).
  destruct (f32_div_val _ ny Fn ltac:(lra)) as [Rh Fh].
  { rewrite Rn. apply b30_le_b100. lra. }
  rewrite Rh, Rn.
  split; [ exact Fh | split; [ exact Habs | exact Hlh ] ].
Qed.
