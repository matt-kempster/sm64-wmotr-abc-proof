(* ====================================================================== *)
(* PoleSound (GOAL 2): PoleClass's terms denote what they say.             *)
(*                                                                        *)
(* From the path facts (Fbool comparisons, and the consumer facts kP:     *)
(* oMarioPolePos finite >= -1000, kC: a find_ceil height, kH / kL: a      *)
(* find_floor height HPi) and floor_data:                                  *)
(*   ppt  -> a finite float in [-1016, 720]    (polePos, maybe slid)      *)
(*   tb   -> a finite float in [-3757, -2018]  (oPosY + polePos + 0)       *)
(*   cb   -> a finite float in [-3918, -2018]  (ceilHeight - 160)          *)
(*   db   -> a finite float in [-3918, -1938]  (a floor above pos[1])      *)
(*   posb -> a finite float in [-11000, -1759]                             *)
(*   ppb  -> a finite float >= -1000            (oMarioPolePos after)      *)
(* ====================================================================== *)

From Coq Require Import ZArith Reals List Lia Lra Bool.
From compcert Require Import Coqlib Maps AST Integers Floats Values Memory Ctypes Cop Clight.
From Flocq Require Import Binary Bits Defs Raux Zaux Generic_fmt FLT.
From SM64.Proofs Require Import Interp.SymExec2 HeightInvariant HeightMoveCatalog WMotRLevel.
From SM64.Proofs.WMotRRequiresA Require Import HeightFloatSteps FloorList FloorHeight FloorBound AirMatch
  FfClass WMotRWorld PoleXc PoleFloat PoleClass.
Import ListNotations.

Local Open Scope R_scope.

(* ---- constants ---- *)
Lemma f32i_val : forall z, (-16777216 <= z <= 16777216)%Z -> R2 (f32i z) = IZR z /\ F32 (f32i z) = true.
Proof.
  intros z Hz. unfold f32i.
  assert (S : Int.signed (Int.repr z) = z)
    by (apply Int.signed_repr; unfold Int.min_signed, Int.max_signed; cbn; lia).
  destruct (of_int_val (Int.repr z)) as (A & B).
  { rewrite S. pose proof (IZR_le (-16777216) z ltac:(lia)). pose proof (IZR_le z 16777216 ltac:(lia)).
    apply Rabs_le. split; lra. }
  rewrite S in A. exact (conj A B).
Qed.

Lemma B2R_f80 : R2 f80 = 80.
Proof. unfold f80. vm_compute (Float32.of_bits _). unfold Binary.B2R, F2R. simpl. lra. Qed.
Lemma F32_f80 : F32 f80 = true.  Proof. vm_compute. reflexivity. Qed.

Lemma cfin_sound : forall s lo hi, (-16777216 <= lo)%Z -> (hi <= 16777216)%Z -> (lo <= hi)%Z ->
  cfin s lo hi = true -> exists k, s = Sconst (Vsingle k) /\ F32 k = true /\ IZR lo <= R2 k <= IZR hi.
Proof.
  intros s lo hi L H LH C. destruct s as [v | | | | | | | | |]; try discriminate C.
  destruct v; try discriminate C. cbn [cfin] in C. unfold fin_in in C.
  repeat rewrite andb_true_iff in C. destruct C as [[Fk G] Le].
  destruct (f32i_val lo ltac:(lia)) as (Rl & Fl). destruct (f32i_val hi ltac:(lia)) as (Rh & Fh).
  exists f. split; [reflexivity |]. split; [exact Fk |].
  pose proof (cmp_ge_true _ _ Fk Fl G). pose proof (cmp_le_true _ _ Fk Fh Le). lra.
Qed.

Lemma is_pz_sound : forall s, is_pz s = true -> exists z, s = Sconst (Vsingle z) /\ F32 z = true /\ R2 z = 0.
Proof.
  intros s H. destruct s as [v | | | | | | | | |]; try discriminate H.
  destruct v; try discriminate H. cbn [is_pz] in H. destruct (ceq_zero f H) as (A & B).
  exists f. auto.
Qed.

Lemma tyeqb_eq : forall a b, tyeqb a b = true -> a = b.
Proof. intros a b H. unfold tyeqb in H. destruct (type_eq a b); [exact e | discriminate H]. Qed.

Lemma hasf_in : forall pc f, hasf pc f = true -> In f pc.
Proof.
  intros pc f H. unfold hasf in H. apply existsb_exists in H as (x & Hx & Hb).
  unfold fbeq in Hb. destruct (fact_eq f x) as [<- |]; [exact Hx | discriminate Hb].
Qed.

(* Ltac: take apart a successful pattern test *)
Ltac crush H :=
  repeat match type of H with
  | context [match ?x with _ => _ end] => destruct x; try discriminate H
  end.

Ltac band H := repeat rewrite andb_true_iff in H.

Lemma tyeqb_eq' : forall a b, tyeqb a b = true -> a = b.
Proof. intros a b H. unfold tyeqb in H. destruct (type_eq a b); [exact e | discriminate H]. Qed.

Ltac norm := repeat match goal with
  | H : _ && _ = true |- _ => apply andb_true_iff in H as [? ?]
  | H : sveqb _ _ = true |- _ => apply sveqb_eq in H; try subst
  | H : is_tf _ = true |- _ => apply is_tf_eq in H; try subst
  | H : tyeqb _ _ = true |- _ => apply tyeqb_eq' in H; try subst
  end.

Section PS.
Variables (ge : genv) (R0 : list (positive * Z)) (m0 : mem) (uf : positive -> list (option val) -> Prop)
  (E : senv).
Variables (kv : list (positive * Z * memory_chunk * sval)) (rO kP kC kH kL : positive).
Variable pc : list fact.
Hypothesis PC : forall f, In f pc -> fact_holds ge R0 m0 uf E f.
Hypothesis HUP : forall vs, uf kP vs -> exists p, vs = [Some (Vsingle p)] /\ F32 p = true /\ -1000 <= R2 p.
Hypothesis HUC : forall vs, uf kC vs -> exists h yv, vs = [Some (Vsingle h); Some yv] /\ ceil_ok yv h.
Hypothesis HUH : forall vs, uf kH vs -> exists h yv, vs = [Some (Vsingle h); Some yv]
                                              /\ HPi (Hit_at ge m0) (ycast yv) h.
Hypothesis HUL : forall vs, uf kL vs -> exists h yv, vs = [Some (Vsingle h); Some yv]
                                              /\ HPi (Hit_at ge m0) (ycast yv) h.
Hypothesis FD : floor_data ge m0.

Local Notation den := (SymExec2.den ge m0 E).
Local Notation sP := (PoleClass.sP kv rO).

Lemma den_cmp : forall a b x y op c,
  den a = Some (Vsingle x) -> den b = Some (Vsingle y) ->
  (op = Ogt /\ c = Cgt) \/ (op = Olt /\ c = Clt) ->
  den (Sbinop op a tf b tf) = Some (Val.of_bool (Float32.cmp c x y)).
Proof.
  intros a b x y op c Da Db Hop. cbn [SymExec2.den]. rewrite Da, Db. cbn.
  destruct Hop as [(-> & ->) | (-> & ->)]; reflexivity.
Qed.

Lemma fbool_cmp : forall a b x y op c bv,
  In (Fbool (Sbinop op a tf b tf) ti32 bv) pc ->
  den a = Some (Vsingle x) -> den b = Some (Vsingle y) ->
  (op = Ogt /\ c = Cgt) \/ (op = Olt /\ c = Clt) ->
  Float32.cmp c x y = bv.
Proof.
  intros a b x y op c bv I Da Db Hop. pose proof (PC _ I) as (v & D & B).
  rewrite (den_cmp a b x y op c Da Db Hop) in D. injection D as <-.
  destruct (Float32.cmp c x y), bv; try reflexivity; exfalso;
    unfold Val.of_bool, bool_val in B; cbn in B; discriminate B.
Qed.

Lemma kP_sound : hasf pc (Fuser kP [sP]) = true ->
  exists p, den sP = Some (Vsingle p) /\ F32 p = true /\ -1000 <= R2 p.
Proof.
  intros H. pose proof (PC _ (hasf_in _ _ H)) as U. cbn [fact_holds map] in U.
  destruct (HUP _ U) as (p & E1 & F & L). injection E1 as E1. exists p. auto.
Qed.

Lemma le720_cmp : forall a x, den a = Some (Vsingle x) -> le720 pc a = true ->
  exists k, F32 k = true /\ R2 k <= 720 /\ Float32.cmp Cgt x k = false.
Proof.
  intros a x D H. unfold le720 in H. apply existsb_exists in H as (f & I & H).
  crush H. band H. destruct H as ((((Ea & T1) & T2) & K) & Ty).
  apply sveqb_eq in Ea. apply is_tf_eq in T1. apply is_tf_eq in T2. apply tyeqb_eq in Ty. subst.
  destruct (cfin_sound _ (-100000) 720 ltac:(lia) ltac:(lia) ltac:(lia) K) as (k & -> & Fk & Rk).
  exists k. split; [exact Fk |]. split; [lra |].
  exact (fbool_cmp _ _ x k Ogt Cgt false I D eq_refl (or_introl (conj eq_refl eq_refl))).
Qed.

Lemma le720_sound : forall a p, den a = Some (Vsingle p) -> F32 p = true -> le720 pc a = true -> R2 p <= 720.
Proof.
  intros a p D F H. destruct (le720_cmp a p D H) as (k & Fk & Rk & G).
  pose proof (cmp_gt_false _ _ F Fk G). lra.
Qed.

Lemma quot256_bound : forall z, (-2147483648 <= z <= 4096)%Z ->
  (-8388608 <= Z.quot z 256 <= 16)%Z.
Proof.
  intros z Hz. pose proof (Z.quot_rem' z 256) as Eq.
  pose proof (Z.rem_bound_abs z 256 ltac:(lia)) as B.
  destruct (Z.abs_spec (Z.rem z 256)) as [(_ & A) | (_ & A)]; rewrite A in B; lia.
Qed.

Lemma int_gt_den : forall i j m,
  sem_binary_operation ge Ogt (Vint i) ti32 (Vint j) ti32 m = Some (Val.of_bool (Int.lt j i)).
Proof. intros i j m. reflexivity. Qed.

Lemma bool_val_false : forall b m, bool_val (Val.of_bool b) ti32 m = Some false -> b = false.
Proof. intros [] m H; [vm_compute in H; discriminate H | reflexivity]. Qed.

Lemma cast_ii : forall i m, sem_cast (Vint i) ti32 ti32 m = Some (Vint i).
Proof. intros i m. vm_compute. reflexivity. Qed.

Lemma div256_den : forall i m,
  sem_binary_operation ge Odiv (Vint i) ti32 (Vint (Int.repr 256)) ti32 m
  = Some (Vint (Int.divs i (Int.repr 256))).
Proof.
  intros i m. unfold sem_binary_operation, sem_div, sem_binarith.
  change (classify_binarith ti32 ti32) with (bin_case_i Signed).
  change (binarith_type (bin_case_i Signed)) with ti32.
  rewrite !cast_ii.
  destruct (Int.eq i (Int.repr Int.min_signed)); reflexivity.
Qed.

(* the slide amount yawVel / 0x100 (yawVel <= 0x1000), or a folded constant *)
Lemma dec_ok_sound : forall d, dec_ok pc d = true ->
  exists q, den d = Some (Vint q) /\ (-8388608 <= Int.signed q <= 16)%Z.
Proof.
  intros d H. unfold dec_ok in H. destruct d as [v | | | | | | | op a1 t1 a2 t2 | |]; try discriminate H.
  - destruct v; try discriminate H. band H. destruct H as (A & B).
    apply Z.leb_le in A. apply Z.leb_le in B. exists i. split; [reflexivity | lia].
  - destruct op; try discriminate H. band H. destruct H as (((T1 & T2) & K) & EX).
    apply tyeqb_eq in T1. apply tyeqb_eq in T2. subst t1 t2.
    unfold cint in K. destruct a2; try discriminate K. destruct v; try discriminate K.
    apply Z.eqb_eq in K. assert (Ei : i = Int.repr 256) by (rewrite <- K; symmetry; apply Int.repr_signed).
    subst i. apply existsb_exists in EX as (f & I & Hm). crush Hm. band Hm.
    destruct Hm as ((((Ey & T3) & T4) & K') & Ty).
    apply sveqb_eq in Ey. apply tyeqb_eq in T3. apply tyeqb_eq in T4. apply tyeqb_eq in Ty. subst.
    unfold cint in K'. crush K'. apply Z.eqb_eq in K'.
    match type of K' with Int.signed ?j = _ =>
      assert (Ei : j = Int.repr 4096) by (rewrite <- K'; symmetry; apply Int.repr_signed); subst j end.
    pose proof (PC _ I) as (v & D & B). cbn [SymExec2.den] in D.
    match type of D with context [SymExec2.den _ _ _ ?y] =>
      destruct (den y) as [vy |] eqn:Dy; [| discriminate D] end.
    destruct vy as [| i | | | | ]; try (cbn in D; discriminate D).
    rewrite int_gt_den in D. injection D as <-. apply bool_val_false in B. rename B into Lt.
    unfold Int.lt in Lt. rewrite Int.signed_repr in Lt by (cbn; lia).
    destruct (zlt 4096 (Int.signed i)) as [_ | Le]; [discriminate Lt |].
    exists (Int.divs i (Int.repr 256)). split.
    + cbn [SymExec2.den]. rewrite Dy. exact (div256_den i m0).
    + unfold Int.divs. rewrite (Int.signed_repr 256) by (cbn; lia).
      pose proof (Int.signed_range i) as Ri. unfold Int.min_signed, Int.max_signed in Ri. cbn in Ri.
      pose proof (quot256_bound (Int.signed i) ltac:(lia)) as Q.
      rewrite Int.signed_repr by (unfold Int.min_signed, Int.max_signed; cbn; lia). exact Q.
Qed.

(* oMarioPolePos before set_pole_position: the entry's, or slid *)
Lemma ppt_sound : forall a, hasf pc (Fuser kP [sP]) = true -> ppt kv rO pc a = true -> le720 pc a = true ->
  exists p, den a = Some (Vsingle p) /\ F32 p = true /\ -1016 <= R2 p <= 720.
Proof.
  intros a HP H L. destruct (kP_sound HP) as (p & Dp & Fp & Lp).
  unfold ppt in H. apply orb_true_iff in H as [E0 | H].
  - apply sveqb_eq in E0. subst a. exists p. split; [exact Dp |]. split; [exact Fp |].
    pose proof (le720_sound _ p Dp Fp L). lra.
  - destruct a; try discriminate H. destruct op; try discriminate H. band H.
    destruct H as (((E0 & T1) & T2) & DO). apply sveqb_eq in E0. apply is_tf_eq in T1.
    apply tyeqb_eq in T2. subst.
    destruct (dec_ok_sound _ DO) as (q & Dq & Bq).
    assert (Ds : den (Sbinop Osub sP tf a2 ti32) = Some (Vsingle (Float32.sub p (Float32.of_int q)))).
    { cbn [SymExec2.den]. rewrite Dp, Dq. reflexivity. }
    destruct (le720_cmp _ _ Ds L) as (k & Fk & Rk & G).
    destruct (dec_val p q k Fp Lp Bq Fk Rk G) as (F & R).
    exists (Float32.sub p (Float32.of_int q)). split; [exact Ds |]. split; [exact F | exact R].
Qed.

(* tight: oPosY + polePos + 0.0f *)
Lemma tb_sound : forall s, tb kv rO kP pc s = true ->
  exists y, den s = Some (Vsingle y) /\ F32 y = true /\ -3757 <= R2 y <= -2018.
Proof.
  intros s H. unfold tb in H. apply orb_true_iff in H as [C | H].
  - destruct (cfin_sound s (-3757) (-2018) ltac:(lia) ltac:(lia) ltac:(lia) C) as (k & -> & Fk & Rk).
    exists k. split; [reflexivity |]. split; [exact Fk | exact Rk].
  - crush H. norm.
    match goal with Ka : cfin _ _ _ = true |- _ =>
      destruct (cfin_sound _ (-2739) (-2739) ltac:(lia) ltac:(lia) ltac:(lia) Ka) as (ka & -> & Fa & Ra) end.
    match goal with Kz : is_pz _ = true |- _ => destruct (is_pz_sound _ Kz) as (z & -> & Fz & Rz) end.
    match goal with HP : hasf _ _ = true, PP : ppt _ _ _ _ = true, L7 : le720 _ _ = true |- _ =>
      destruct (ppt_sound _ HP PP L7) as (p & Dp & Fp & Lp) end.
    destruct (y0_bound ka p z Fa ltac:(lra) Fp ltac:(lra) Fz Rz) as (F & B).
    exists (Float32.add (Float32.add ka p) z). split; [| exact (conj F B)].
    cbn [SymExec2.den]. rewrite Dp. reflexivity.
Qed.

Lemma plus80_den : forall y Y, den y = Some (Vsingle Y) -> den (plus80 y) = Some (Vsingle (Float32.add Y f80)).
Proof.
  intros y Y D. destruct y as [v | | | | | | | | |].
  { destruct v; cbn [SymExec2.den] in D; try discriminate D. injection D as ->. reflexivity. }
  all: cbn [plus80 SymExec2.den] in D |- *; first [discriminate D | rewrite D; reflexivity].
Qed.

Lemma plus80_cast : forall Y, F32 Y = true -> -3757 <= R2 Y <= -2018 ->
  exists yi, ycast (Vsingle (Float32.add Y f80)) = Vint yi /\ (-3678 <= Int.signed yi <= -1)%Z.
Proof.
  intros Y FY RY.
  destruct (f32_add_val Y f80 FY F32_f80) as (A & F).
  { rewrite B2R_f80. eapply Rle_trans; [| apply (bpow_le radix2 12 100); lia]. simpl. apply Rabs_le. lra. }
  rewrite B2R_f80 in A.
  assert (L1 : -3677 <= R2 (Float32.add Y f80)).
  { rewrite A. apply (rnd_ge_int _ (-3677)); [lia | lra]. }
  assert (L2 : R2 (Float32.add Y f80) <= -1938).
  { rewrite A. apply (rnd_le_int _ (-1938)); [lia | lra]. }
  destruct (ycast_val _ F ltac:(apply Rabs_le; lra)) as (yi & Ey & B1 & B2).
  exists yi. split; [exact Ey |].
  assert (Q1 : IZR (-3679) < IZR (Int.signed yi)) by lra.
  assert (Q2 : IZR (Int.signed yi) < IZR 0) by lra.
  apply lt_IZR in Q1, Q2. lia.
Qed.

Lemma c20000_gt : forall Y, F32 Y = true -> R2 Y <= 0 ->
  Float32.cmp Cgt Y (Float32.sub c20000 c160) = false.
Proof.
  intros Y FY RY.
  assert (F : F32 (Float32.sub c20000 c160) = true) by (vm_compute; reflexivity).
  assert (R : R2 (Float32.sub c20000 c160) = 19840).
  { change (Float32.sub c20000 c160) with ltac:(let x := eval vm_compute in (Float32.sub c20000 c160) in exact x). unfold Binary.B2R, F2R. simpl. lra. }
  destruct (Float32.cmp Cgt Y (Float32.sub c20000 c160)) eqn:G; [| reflexivity].
  pose proof (cmp_gt_true _ _ FY F G). lra.
Qed.

(* below a ceiling: ceilHeight - 160 *)
Lemma cb_sound : forall s, cb kv rO kP kC pc s = true ->
  exists y, den s = Some (Vsingle y) /\ F32 y = true /\ -3918 <= R2 y <= -2018.
Proof.
  intros s H. unfold cb in H. crush H. norm.
  match goal with H : existsb _ _ = true |- _ => apply existsb_exists in H as (f & I & Hm) end.
  crush Hm. norm.
  match goal with TB : tb _ _ _ _ _ = true |- _ => destruct (tb_sound _ TB) as (Y & DY & FY & RY) end.
  match goal with HC : hasf _ _ = true |- _ => pose proof (PC _ (hasf_in _ _ HC)) as U end.
  cbn [fact_holds map] in U.
  rewrite (plus80_den _ _ DY) in U.
  destruct (HUC _ U) as (C & yv & E1 & CO). injection E1 as DC <-.
  assert (Ds : den (Sbinop Osub s1 tf (Sconst (Vsingle c160)) tf) = Some (Vsingle (Float32.sub C c160))).
  { cbn [SymExec2.den]. rewrite DC. reflexivity. }
  pose proof (fbool_cmp _ _ Y _ Ogt Cgt true I DY Ds (or_introl (conj eq_refl eq_refl))) as G.
  destruct CO as (yi & Ey & [-> | Hc]).
  - rewrite (c20000_gt Y FY ltac:(lra)) in G. discriminate G.
  - destruct (plus80_cast Y FY RY) as (yi' & Ey' & Byi). rewrite Ey' in Ey. injection Ey as <-.
    destruct (ceil_clamp Y C yi' FY ltac:(lra) ltac:(lia) Hc G) as (Fs & B1 & B2).
    exists (Float32.sub C c160). split; [exact Ds |]. split; [exact Fs |].
    pose proof (IZR_le (-3678) (Int.signed yi') ltac:(lia)). lra.
Qed.

Lemma yb_sound : forall y, tb kv rO kP pc y || cb kv rO kP kC pc y = true ->
  exists Y, den y = Some (Vsingle Y) /\ F32 Y = true /\ -3918 <= R2 Y <= -2018.
Proof.
  intros y H. apply orb_true_iff in H as [H | H];
    [destruct (tb_sound _ H) as (Y & D & F & R) | destruct (cb_sound _ H) as (Y & D & F & R)];
    exists Y; split; [exact D | | exact D |]; split; [exact F | lra | exact F | lra].
Qed.

Lemma hl_sound : forall s y, hasf pc (Fuser kH [s; y]) || hasf pc (Fuser kL [s; y]) = true ->
  exists h yv, den s = Some (Vsingle h) /\ den y = Some yv /\ HPi (Hit_at ge m0) (ycast yv) h.
Proof.
  intros s y H. apply orb_true_iff in H as [H | H];
    pose proof (PC _ (hasf_in _ _ H)) as U; cbn [fact_holds map] in U;
    [destruct (HUH _ U) as (h & yv & E1 & P) | destruct (HUL _ U) as (h & yv & E1 & P)];
    injection E1 as D1 D2; exists h, yv; auto.
Qed.

Lemma hitb : HitB (Hit_at ge m0).
Proof. intros x H. destruct (FD x H) as (A & B & _). exact (conj A B). Qed.

(* a floor above pos[1], found by find_floor at pos[1] *)
Lemma db_sound : forall s, db kv rO kP kC kH kL pc s = true ->
  exists y, den s = Some (Vsingle y) /\ F32 y = true /\ -3918 <= R2 y <= -1938.
Proof.
  intros s H. unfold db in H. apply existsb_exists in H as (f & I & Hm). crush Hm. norm.
  match goal with Hy : tb _ _ _ _ _ || cb _ _ _ _ _ _ = true |- _ =>
    destruct (yb_sound _ Hy) as (Y & DY & FY & RY) end.
  match goal with Hl : hasf _ _ || hasf _ _ = true |- _ =>
    destruct (hl_sound _ _ Hl) as (h & yv & Dh & Dyv & P) end.
  rewrite DY in Dyv. injection Dyv as <-.
  pose proof (fbool_cmp _ _ Y h Olt Clt true I DY Dh (or_intror (conj eq_refl eq_refl))) as G.
  destruct (ff_height_bound _ Y h hitb FY ltac:(lra) P) as [-> | (Hh & Le)].
  - pose proof (cmp_lt_true _ _ FY F32_c11000 G). rewrite B2R_c11000 in H. lra.
  - destruct (FD h Hh) as (Fh & _ & _).
    pose proof (cmp_lt_true _ _ FY Fh G).
    rewrite Rmax_left in Le by lra.
    exists h. split; [exact Dh |]. split; [exact Fh | lra].
Qed.

Theorem posb_sound : forall s, posb kv rO kP kC kH kL pc s = true ->
  exists y, den s = Some (Vsingle y) /\ F32 y = true /\ -11000 <= R2 y <= -1759.
Proof.
  intros s H. unfold posb in H. repeat rewrite orb_true_iff in H.
  destruct H as [[[H | H] | H] | H].
  - destruct (cfin_sound s (-11000) (-1759) ltac:(lia) ltac:(lia) ltac:(lia) H) as (k & -> & F & R).
    exists k. split; [reflexivity |]. split; [exact F | lra].
  - destruct (tb_sound _ H) as (y & D & F & R). exists y. split; [exact D |]. split; [exact F | lra].
  - destruct (cb_sound _ H) as (y & D & F & R). exists y. split; [exact D |]. split; [exact F | lra].
  - destruct (db_sound _ H) as (y & D & F & R). exists y. split; [exact D |]. split; [exact F | lra].
Qed.

Theorem ppb_sound : forall s, ppb kv rO kP kC pc s = true ->
  exists p, den s = Some (Vsingle p) /\ F32 p = true /\ -1000 <= R2 p.
Proof.
  intros s H. unfold ppb in H. repeat rewrite orb_true_iff in H. destruct H as [[[H | H] | H] | H].
  - apply andb_true_iff in H as [E1 H]. apply sveqb_eq in E1. subst s. exact (kP_sound H).
  - band H. destruct H as (((PP & HP) & L7) & NN).
    destruct (ppt_sound _ HP PP L7) as (p & Dp & Fp & Rp).
    unfold nneg in NN. apply existsb_exists in NN as (f & I & Hm). crush Hm. norm.
    match goal with Kz : is_pz _ = true |- _ => destruct (is_pz_sound _ Kz) as (z & -> & Fz & Rz) end.
    pose proof (fbool_cmp _ _ p z Olt Clt false I Dp eq_refl (or_intror (conj eq_refl eq_refl))) as G.
    pose proof (cmp_lt_false _ _ Fp Fz G).
    exists p. split; [exact Dp |]. split; [exact Fp | lra].
  - destruct (cfin_sound s (-1000) 100000 ltac:(lia) ltac:(lia) ltac:(lia) H) as (k & -> & F & R).
    exists k. split; [reflexivity |]. split; [exact F | lra].
  - crush H. norm.
    match goal with K : cfin _ _ _ = true |- _ =>
      destruct (cfin_sound _ (-2739) (-2739) ltac:(lia) ltac:(lia) ltac:(lia) K) as (kk & -> & Fk & Rk) end.
    match goal with C : cb _ _ _ _ _ _ = true |- _ => destruct (cb_sound _ C) as (X & DX & FX & RX) end.
    match goal with H : existsb _ _ = true |- _ => apply existsb_exists in H as (f & I & Hm) end.
    crush Hm. norm.
    match goal with Kz : is_pz _ = true |- _ => destruct (is_pz_sound _ Kz) as (z & -> & Fz & Rz) end.
    destruct (f32_sub_dom X kk X FX Fk) as (A & F).
    { assert (Rk' : R2 kk = -2739) by lra. rewrite Rk'. rewrite (Rabs_left (R2 X)) by lra.
      apply Rabs_le. lra. }
    match goal with |- exists p, den (Sbinop Osub ?x _ _ _) = _ /\ _ =>
      assert (Ds : den (Sbinop Osub x tf (Sconst (Vsingle kk)) tf) = Some (Vsingle (Float32.sub X kk)))
        by (cbn [SymExec2.den]; rewrite DX; reflexivity) end.
    pose proof (fbool_cmp _ _ (Float32.sub X kk) z Olt Clt false I Ds eq_refl
                  (or_intror (conj eq_refl eq_refl))) as G.
    pose proof (cmp_lt_false _ _ F Fz G).
    exists (Float32.sub X kk). split; [exact Ds |]. split; [exact F | lra].
Qed.
End PS.

(* ---- the outcome actions' modes ---- *)
Lemma pole_out_cap : forall a st tm v, In (Int.unsigned a) POLE_OUT -> v <= 43 ->
  launch_cap (mode_of_action a st) tm v.
Proof.
  intros a st tm v H Hv. rewrite <- (Int.repr_unsigned a).
  unfold POLE_OUT, POLE_ACTS3 in H. cbn [app] in H.
  repeat (destruct H as [H | H]; [rewrite <- H;
    first [ replace (mode_of_action _ st) with M_Ground
              by (unfold mode_of_action, roll_prep; vm_compute; reflexivity); exact I
          | replace (mode_of_action _ st) with M_Freefall
              by (unfold mode_of_action, roll_prep; vm_compute; reflexivity); cbn; lra
          | replace (mode_of_action _ st) with M_Air
              by (unfold mode_of_action, roll_prep; vm_compute; reflexivity); cbn; lra ] |]).
  destruct H.
Qed.

Lemma pole_out_not_ledge : forall a, In (Int.unsigned a) POLE_OUT -> a <> ACT_LEDGE_GRAB.
Proof.
  intros a H ->. unfold POLE_OUT, POLE_ACTS3 in H. vm_compute in H.
  repeat (destruct H as [H | H]; [discriminate H |]). exact H.
Qed.

Lemma acts3_ground : forall a st, In (Int.unsigned a) POLE_ACTS3 -> mode_of_action a st = M_Ground.
Proof.
  intros a st H. rewrite <- (Int.repr_unsigned a). unfold POLE_ACTS3 in H.
  repeat (destruct H as [H | H]; [rewrite <- H; unfold mode_of_action, roll_prep; vm_compute; reflexivity |]).
  destruct H.
Qed.

Lemma zin_in : forall z l, zin z l = true -> In z l.
Proof.
  intros z l H. unfold zin in H. apply existsb_exists in H as (x & Hx & E). apply Z.eqb_eq in E. subst. exact Hx.
Qed.

Lemma low_pole_attach : forall c, AttachOK wmotr_floor wmotr_pole wmotr_cannon c (-1759).
Proof.
  intros c. right; right; right; left.
  exists (-2739), (-1919). split.
  - exists (-2739)%Z, (-1919)%Z. split; [rewrite pole_list_value; left; reflexivity |]. split; reflexivity.
  - rewrite POLE_UP_val. unfold PHI_K. split; [right |]; lra.
Qed.

(* ---- PoleClass.pole_ok, at the outcome's memory ---- *)
Section PC2.
Variables (ge : genv) (nbase : positive) (R0 : list (positive * Z)) (gtab : list (ident * positive))
  (kv : list (positive * Z * memory_chunk * sval)) (m0 : mem)
  (uf : positive -> list (option val) -> Prop) (gp : meminj).
Hypothesis gp_old : forall b x, gp b = Some x -> Plt b (Mem.nextblock m0).
Variables (rM rO rU kP kC kH kL : positive).
Hypothesis HUP : forall vs, uf kP vs -> exists p, vs = [Some (Vsingle p)] /\ F32 p = true /\ -1000 <= R2 p.
Hypothesis HUC : forall vs, uf kC vs -> exists h yv, vs = [Some (Vsingle h); Some yv] /\ ceil_ok yv h.
Hypothesis HUH : forall vs, uf kH vs -> exists h yv, vs = [Some (Vsingle h); Some yv]
                                              /\ HPi (Hit_at ge m0) (ycast yv) h.
Hypothesis HUL : forall vs, uf kL vs -> exists h yv, vs = [Some (Vsingle h); Some yv]
                                              /\ HPi (Hit_at ge m0) (ycast yv) h.
Hypothesis FD : floor_data ge m0.
Variables (E : senv) (m : mem) (g : gst).
Hypothesis MM : MMg ge nbase R0 gtab kv m0 uf gp E m g.
Hypothesis HbM : e_base E rM = Ptrofs.zero.
Local Notation bm := (e_blk E rM).
Local Notation den := (SymExec2.den ge m0 E).
Local Notation LD := (sload nbase R0 kv g).

Lemma pld : forall r o ch s, LD r o ch = Some s -> Mem.load ch m (e_blk E r) (addr E r o) = den s.
Proof.
  intros r o ch s L.
  exact (proj1 (sload_sound ge nbase R0 gtab kv (fun _ => None) (fun _ => false) m0 uf gp gp_old
                  E m g r o ch s MM L)).
Qed.

Lemma pic : forall r o ch, den (init_cell kv r o ch) = Mem.load ch m0 (e_blk E r) (addr E r o).
Proof.
  intros r o ch. destruct MM as (EO & _).
  exact (proj1 (init_cell_den ge nbase R0 gtab kv m0 gp E r o ch EO)).
Qed.

Lemma pAM : forall o, addr E rM o = o.
Proof. intros o. unfold addr. rewrite HbM, Ptrofs.unsigned_zero. reflexivity. Qed.

Lemma ppc : forall f, In f (g_pc g) -> fact_holds ge R0 m0 uf E f.
Proof. intros f Hx. destruct MM as (_ & _ & _ & _ & _ & _ & PC & _). exact (proj2 (PC f Hx)). Qed.

(* a kept cell *)
Lemma pkept : forall r o ch, match LD r o ch with
  | Some u => sveqb u (init_cell kv r o ch) | None => false end = true ->
  Mem.load ch m (e_blk E r) (addr E r o) = Mem.load ch m0 (e_blk E r) (addr E r o).
Proof.
  intros r o ch H. destruct (LD r o ch) as [u|] eqn:L; [| discriminate H].
  apply sveqb_eq in H. subst u. rewrite (pld _ _ _ _ L). apply pic.
Qed.

Theorem pole_keep_sound : pole_keep nbase R0 kv rM rO rU kP kC g = true ->
  Mem.load Mint32 m bm USED_OFF = Mem.load Mint32 m0 bm USED_OFF
  /\ (forall z, z = O_POSY \/ z = HITBOX_DOWN_OFF \/ z = HITBOX_H_OFF ->
        Mem.load Mfloat32 m (e_blk E rU) (addr E rU z) = Mem.load Mfloat32 m0 (e_blk E rU) (addr E rU z))
  /\ exists p, Mem.load Mfloat32 m (e_blk E rO) (addr E rO POLEPOS_OFF) = Some (Vsingle p)
       /\ F32 p = true /\ -1000 <= R2 p.
Proof.
  intros H. unfold pole_keep in H. cbv zeta in H. repeat rewrite andb_true_iff in H.
  destruct H as ((((U & P1) & P2) & P3) & PP).
  split; [rewrite <- (pAM USED_OFF); exact (pkept _ _ _ U) |].
  split; [intros z [-> | [-> | ->]]; apply pkept; assumption |].
  destruct (LD rO POLEPOS_OFF Mfloat32) as [p|] eqn:L; [| discriminate PP].
  destruct (ppb_sound ge R0 m0 uf E kv rO kP kC (g_pc g) ppc HUP HUC p PP)
    as (v & D & F & R).
  exists v. rewrite (pld _ _ _ _ L). auto.
Qed.

Variable c0 : cells.
Hypothesis RC0 : read_cells bm m0 c0.
Hypothesis IR0 : InRange c0.

Theorem pole_sound : pole_ok nbase R0 kv rM rO rU kP kC kH kL g = true ->
  exists c2, read_cells bm m c2
    /\ RangedMove wmotr_floor wmotr_pole wmotr_cannon c0 c2
    /\ In (Int.unsigned (c_action c2)) POLE_OUT
    /\ c_vely c2 = c_vely c0
    /\ (In (Int.unsigned (c_action c2)) POLE_ACTS3 -> pole_keep nbase R0 kv rM rO rU kP kC g = true).
Proof.
  intros OK. unfold pole_ok in OK. cbv zeta in OK.
  repeat match type of OK with
  | context [match ?x with _ => _ end] => let Ex := fresh "Ex" in destruct x eqn:Ex; try discriminate OK
  end.
  subst.
  repeat rewrite andb_true_iff in OK.
  destruct OK as ((((((((R1 & Z0) & Zin) & IS) & IT) & EV) & EF) & YB) & KP).
  apply Pos.eqb_eq in R1. subst. apply Ptrofs.same_if_eq in Z0. subst.
  apply sveqb_eq in EV, EF. subst.
  destruct RC0 as (A0 & S0 & T0 & Y0 & V0 & F0 & bo0 & oo0 & LO0 & GY0).
  assert (DS0 : den (init_cell kv rM oS Mint16unsigned) = Some (Vint (c_state c0)))
    by (rewrite pic, pAM; exact S0).
  assert (DT0 : den (init_cell kv rM oT Mint16unsigned) = Some (Vint (c_timer c0)))
    by (rewrite pic, pAM; exact T0).
  match goal with H : int_sv _ ?s = true, H' : LD rM oS _ = Some ?s |- _ =>
    destruct (int_sv_den ge m0 E _ _ DS0 s H) as (js & Ds); pose proof (pld _ _ _ _ H') as LS end.
  match goal with H : int_sv _ ?s = true, H' : LD rM oT _ = Some ?s |- _ =>
    destruct (int_sv_den ge m0 E _ _ DT0 s H) as (jt & Dt); pose proof (pld _ _ _ _ H') as LT end.
  rewrite pAM, Ds in LS. rewrite pAM, Dt in LT.
  match goal with H' : LD rM oV _ = Some _ |- _ => pose proof (pld _ _ _ _ H') as LV end.
  rewrite pAM, pic, pAM in LV.
  match goal with H' : LD rM oF _ = Some _ |- _ => pose proof (pld _ _ _ _ H') as LF end.
  rewrite pAM, pic, pAM in LF.
  match goal with H' : LD rM oA _ = Some _ |- _ => pose proof (pld _ _ _ _ H') as LA end.
  rewrite pAM in LA. cbn [SymExec2.den] in LA.
  match goal with H' : LD rM oMO _ = Some _ |- _ => pose proof (pld _ _ _ _ H') as LM end.
  rewrite pAM in LM. cbn [SymExec2.den] in LM. rewrite Ptrofs.add_zero in LM.
  assert (Hin : In (Int.unsigned i) POLE_OUT) by exact (zin_in _ _ Zin).
  match goal with H' : LD rM oY _ = Some ?s |- _ => pose proof (pld _ _ _ _ H') as LY end.
  match goal with H' : LD rO oG _ = Some _ |- _ => pose proof (pld _ _ _ _ H') as LG end.
  rewrite pAM in LY.
  (* the two shapes of pos[1]: set_pole_position's, or untouched *)
  assert (MV : exists y gy, Mem.load Mfloat32 m bm oY = Some (Vsingle y)
             /\ Mem.load Mfloat32 m (e_blk E rO) (addr E rO oG) = Some (Vsingle gy)
             /\ F32 y = true /\ F32 gy = true /\ -11000 <= R2 y /\ -11000 <= R2 gy
             /\ forall c2, c_posy c2 = y -> c_gfxy c2 = gy -> c_action c2 = i -> c_vely c2 = c_vely c0 ->
                  c_floorh c2 = c_floorh c0 -> Move wmotr_floor wmotr_pole wmotr_cannon c0 c2).
  { destruct IR0 as (FY0 & FV0 & FG0 & LY0 & LG0 & (FF0 & LF0) & VR0).
    apply orb_true_iff in YB as [YB | YB].
    - apply andb_true_iff in YB as [EG PB]. apply sveqb_eq in EG. subst.
      destruct (posb_sound ge R0 m0 uf E kv rO kP kC kH kL (g_pc g) ppc HUP HUC HUH HUL FD _ PB)
        as (y & Dy & Fy & Ry & Ry2).
      rewrite Dy in LY, LG. exists y, y.
      split; [exact LY |]. split; [exact LG |]. split; [exact Fy |]. split; [exact Fy |]. split; [lra |]. split; [lra |].
      intros c2 E1 E2 E3 E4 E5.
      apply S_attach with (h := -1759).
      + exact (low_pole_attach c0).
      + rewrite E1. lra.
      + left. congruence.
      + unfold mode_of. rewrite E3, E4. apply pole_out_cap; [exact Hin | lra].
      + intros H. exfalso. rewrite E3 in H. exact (pole_out_not_ledge _ Hin H).
    - apply andb_true_iff in YB as [YB G0]. apply andb_true_iff in YB as [EY EG].
      apply sveqb_eq in EY, EG. subst.
      unfold ground0 in G0. apply andb_true_iff in G0 as [GA GM]. apply sveqb_eq in GM.
      destruct (init_cell kv rM oA Mint32) as [[| a0 | | | |] | | | | | | | | |] eqn:IA;
        try discriminate GA.
      assert (DA : den (init_cell kv rM oA Mint32) = Mem.load Mint32 m0 bm oA) by (rewrite pic, pAM; reflexivity).
      rewrite IA in DA. cbn [SymExec2.den] in DA. change OFS_ACTION with oA in A0.
      rewrite A0 in DA. injection DA as Ea0.
      assert (MG : mode_of c0 = M_Ground).
      { unfold mode_of. rewrite <- Ea0. exact (acts3_ground _ _ (zin_in _ _ GA)). }
      assert (DM : den (init_cell kv rM oMO Mint32) = Mem.load Mint32 m0 bm oMO) by (rewrite pic, pAM; reflexivity).
      rewrite GM in DM. cbn [SymExec2.den] in DM. rewrite Ptrofs.add_zero in DM.
      change Mptr with Mint32 in LO0. change OFS_MARIOOBJ with oMO in LO0.
      rewrite LO0 in DM. injection DM as <- <-.
      rewrite pic, pAM in LY. change OFS_POSY with oY in Y0. rewrite Y0 in LY.
      rewrite pic in LG. unfold addr in LG. change OFS_GFXY with oG in GY0. rewrite GY0 in LG.
      exists (c_posy c0), (c_gfxy c0).
      refine (conj LY (conj LG (conj FY0 (conj FG0 (conj LY0 (conj LG0 _)))))).
      intros c2 E1 E2 E3 E4 E5.
      apply S_attach with (h := R2 (c_posy c0)).
      + left. split; [exact MG | lra].
      + rewrite E1. lra.
      + right. split; [exact E2 | exact MG].
      + unfold mode_of. rewrite E3, E4. apply pole_out_cap; [exact Hin | lra].
      + intros H. exfalso. rewrite E3 in H. exact (pole_out_not_ledge _ Hin H). }
  destruct MV as (y & gy & LY' & LG' & Fy & Fg & Ry & Rg & MV).
  set (c2 := mkCells i js jt y (c_vely c0) (c_floorh c0) gy).
  exists c2.
  split.
  { unfold read_cells. cbn [c2 c_action c_state c_timer c_posy c_vely c_floorh c_gfxy].
    change OFS_ACTION with oA. change OFS_ASTATE with oS. change OFS_ATIMER with oT.
    change OFS_POSY with oY. change OFS_VELY with oV. change OFS_FLOORH with oF.
    change OFS_VELY with oV in V0. change OFS_FLOORH with oF in F0.
    refine (conj LA (conj LS (conj LT (conj LY' (conj _ (conj _ _)))))).
    - rewrite LV. exact V0.
    - rewrite LF. exact F0.
    - exists (e_blk E rO), (e_base E rO). change Mptr with Mint32. change OFS_MARIOOBJ with oMO.
      split; [exact LM |]. unfold addr in LG'. change OFS_GFXY with oG. exact LG'. }
  split.
  { destruct IR0 as (FY0 & FV0 & FG0 & LY0 & LG0 & (FF0 & LF0) & VR0).
    split.
    - unfold InRange. cbn [c2 c_posy c_vely c_gfxy c_floorh].
      repeat split; try assumption; lra.
    - apply MV; reflexivity. }
  split; [exact Hin |]. split; [reflexivity |].
  intros H3. cbn [c2 c_action] in H3.
  apply orb_true_iff in KP as [N | K]; [| exact K].
  assert (Z3 : zin (Int.unsigned i) POLE_ACTS3 = true).
  { apply existsb_exists. exists (Int.unsigned i). split; [exact H3 | apply Z.eqb_refl]. }
  rewrite Z3 in N. discriminate N.
Qed.
End PC2.
