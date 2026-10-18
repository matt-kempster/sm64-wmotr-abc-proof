(* ====================================================================== *)
(* AirMatch (unwired, GOAL 2): reading the air-step walk's outcomes as     *)
(* catalog moves.  Piece 1: the pos[1] terms.                               *)
(*                                                                          *)
(* The walk (SymExec2 over the real perform_air_step) leaves pos[1] as one *)
(* of: the 4-quarter sum, k real quarter adds followed by j adds of +0.0f  *)
(* (a ceiling zeroed vel; each remaining quarter computes pos + 0/4), or a *)
(* floor height.  [qrec] recognises the quarter sums syntactically, and    *)
(* [qrec_den] says what they denote: exactly quarter_steps k y q when j=0, *)
(* and the same REAL otherwise (x + 0.0f = x as a real, for every float).  *)
(* ====================================================================== *)

From Coq Require Import ZArith Reals List Lia Lra.
From compcert Require Import Coqlib Maps AST Integers Floats Values Memory Ctypes Cop Clight.
From Flocq Require Import Binary Bits Defs Raux Zaux Generic_fmt FLT.
From SM64.Proofs Require Import Interp.SymExec2 HeightInvariant.
From SM64.Proofs.WMotRRequiresA Require Import HeightFloatSteps.
Import ListNotations.

Local Open Scope R_scope.
Local Transparent Float32.add Float32.div Float32.cmp Float32.compare.

(* ---- x + 0.0f is x, as a real ---- *)

Lemma add_zero_R2 : forall x, R2 (Float32.add x Float32.zero) = R2 x.
Proof.
  intros [s | s | s pl Hpl | s mx ex Hx].
  - destruct s; reflexivity.
  - destruct s; reflexivity.
  - reflexivity.
  - unfold Float32.add.
    set (x := B754_finite 24 128 s mx ex Hx).
    assert (Fx : is_finite 24 128 x = true) by reflexivity.
    pose proof (Bplus_correct 24 128 eq_refl eq_refl Float32.binop_nan BinarySingleNaN.mode_NE x Float32.zero Fx eq_refl) as HB.
    replace (R2 Float32.zero) with 0%R in HB by reflexivity.
    rewrite Rplus_0_r in HB.
    rewrite (round_generic radix2 (SpecFloat.fexp 24 128) (BinarySingleNaN.round_mode BinarySingleNaN.mode_NE) (B2R 24 128 x)
               (generic_format_B2R 24 128 x)) in HB.
    rewrite Rlt_bool_true in HB by exact (abs_B2R_lt_emax 24 128 x).
    exact (proj1 HB).
Qed.

Lemma add_zero_F32 : forall x, F32 x = true -> F32 (Float32.add x Float32.zero) = true.
Proof.
  intros x Fx. unfold Float32.add.
  pose proof (Bplus_correct 24 128 eq_refl eq_refl Float32.binop_nan BinarySingleNaN.mode_NE x Float32.zero Fx eq_refl) as HB.
  replace (R2 Float32.zero) with 0%R in HB by reflexivity.
  rewrite Rplus_0_r in HB.
  rewrite (round_generic radix2 (SpecFloat.fexp 24 128) (BinarySingleNaN.round_mode BinarySingleNaN.mode_NE) (B2R 24 128 x)
             (generic_format_B2R 24 128 x)) in HB.
  rewrite Rlt_bool_true in HB by exact (abs_B2R_lt_emax 24 128 x).
  destruct HB as (_ & H & _). first [exact H | rewrite H; exact Fx | rewrite H, Fx; reflexivity].
Qed.

(* ---- the pos[1] term recogniser ---- *)

Definition tf : type := Tfloat Ctypes.F32 noattr.

Definition is_tf (t : type) : bool := if type_eq t tf then true else false.

Definition is_f (v : val) (f : float32) : bool :=
  match v with Vsingle g => if Float32.eq_dec g f then true else false | _ => false end.

(* the quarter q = vel[1] / 4.0f, with vel[1] the entry cell (rM, oV) *)
Definition is_q (rM : positive) (oV : Z) (a : sval) : bool :=
  match a with
  | Sbinop Cop.Odiv (Sinit r o Mfloat32) t1 (Sconst v) t2 =>
      Pos.eqb r rM && Z.eqb o oV && is_tf t1 && is_tf t2 && is_f v f4
  | _ => false
  end.

(* k real quarter adds on the entry cell (rM, oY), then j adds of +0.0f *)
Fixpoint qrec (rM : positive) (oY oV : Z) (a : sval) : option (nat * nat) :=
  match a with
  | Sinit r o Mfloat32 => if Pos.eqb r rM && Z.eqb o oY then Some (O, O) else None
  | Sbinop Cop.Oadd a1 t1 a2 t2 =>
      if is_tf t1 && is_tf t2 then
        match qrec rM oY oV a1 with
        | Some (k, j) =>
            if is_q rM oV a2 then (match j with O => Some (S k, O) | _ => None end)
            else match a2 with
                 | Sconst v => if is_f v Float32.zero then Some (k, S j) else None
                 | _ => None
                 end
        | None => None
        end
      else None
  | _ => None
  end.

Fixpoint add_zeros (j : nat) (x : float32) : float32 :=
  match j with O => x | S j' => Float32.add (add_zeros j' x) Float32.zero end.

Lemma add_zeros_R2 : forall j x, R2 (add_zeros j x) = R2 x.
Proof. induction j; intros x; cbn [add_zeros]; [reflexivity | rewrite add_zero_R2; apply IHj]. Qed.

Lemma add_zeros_F32 : forall j x, F32 x = true -> F32 (add_zeros j x) = true.
Proof. induction j; intros x H; cbn [add_zeros]; [exact H | apply add_zero_F32, IHj, H]. Qed.

Lemma is_tf_eq : forall t, is_tf t = true -> t = tf.
Proof. unfold is_tf; intros t H. destruct (type_eq t tf); [exact e | discriminate]. Qed.

Lemma is_f_eq : forall v f, is_f v f = true -> v = Vsingle f.
Proof.
  unfold is_f; intros w f H. destruct w as [| | | | g |]; try discriminate.
  destruct (Float32.eq_dec g f); [subst; reflexivity | discriminate].
Qed.

Section DEN.
Variables (ge : genv) (m0 : mem) (E : senv) (bm : block) (rM : positive) (oY oV : Z) (y v : float32).
Hypothesis HbM : e_blk E rM = bm.
Hypothesis Hbase : e_base E rM = Ptrofs.zero.
Hypothesis HY : Mem.load Mfloat32 m0 bm oY = Some (Vsingle y).
Hypothesis HV : Mem.load Mfloat32 m0 bm oV = Some (Vsingle v).

Lemma is_q_den : forall a, is_q rM oV a = true -> den ge m0 E a = Some (Vsingle (Float32.div v f4)).
Proof.
  intros a H. destruct a; try discriminate. destruct op; try discriminate.
  destruct a1; try discriminate. destruct ch; try discriminate. destruct a2; try discriminate.
  cbn [is_q] in H. repeat rewrite andb_true_iff in H.
  destruct H as ((((Hr & Ho) & H1) & H2) & Hf).
  apply Pos.eqb_eq in Hr. apply Z.eqb_eq in Ho. apply is_tf_eq in H1. apply is_tf_eq in H2.
  apply is_f_eq in Hf. rewrite Hr, Ho, H1, H2, Hf.
  cbn [den]. unfold addr. rewrite HbM, Hbase, Ptrofs.unsigned_zero, Z.add_0_l, HV. reflexivity.
Qed.

Lemma qrec_den : forall a kq jz, qrec rM oY oV a = Some (kq, jz) ->
  den ge m0 E a = Some (Vsingle (add_zeros jz (quarter_steps kq y (Float32.div v f4)))).
Proof.
  induction a; intros kq jz H; cbn [qrec] in H; try discriminate.
  - destruct ch; try discriminate.
    destruct (Pos.eqb r rM && Z.eqb ofs oY) eqn:E1; [| discriminate]. injection H as <- <-.
    apply andb_true_iff in E1 as (Hr & Ho). apply Pos.eqb_eq in Hr. apply Z.eqb_eq in Ho. rewrite Hr, Ho.
    cbn [den]. unfold addr. rewrite HbM, Hbase, Ptrofs.unsigned_zero, Z.add_0_l, HY. reflexivity.
  - destruct op; try discriminate.
    destruct (is_tf t1 && is_tf t2) eqn:T; [| discriminate].
    apply andb_true_iff in T as (T1 & T2). apply is_tf_eq in T1. apply is_tf_eq in T2. rewrite T1, T2.
    destruct (qrec rM oY oV a1) as [[k1 j1]|] eqn:R1; [| discriminate].
    specialize (IHa1 _ _ eq_refl).
    destruct (is_q rM oV a2) eqn:Q.
    + destruct j1; [| discriminate]. injection H as <- <-.
      cbn [den]. rewrite IHa1, (is_q_den _ Q). reflexivity.
    + destruct a2; try discriminate. destruct (is_f v0 Float32.zero) eqn:Z0; [| discriminate].
      apply is_f_eq in Z0. rewrite Z0. injection H as <- <-.
      cbn [den]. rewrite IHa1. reflexivity.
Qed.

End DEN.

(* ---- the vel[1] outcomes sit at or below gravity's ---- *)

(* the walk leaves vel[1] as -75 (the clamp branch) or vel - 4.0f (the other
   one); both are <= gravity f4 vel as reals, branch facts not needed *)
Lemma vel_clamp_le : forall v, F32 v = true -> Rabs (R2 v) <= 128 ->
  R2 fm75 <= R2 (gravity f4 v).
Proof.
  intros v Fv Hv. rewrite B2R_fm75.
  destruct (gravity_spec2 f4 v F32_f4 Fv (or_intror B2R_f4) Hv) as [(_ & H) | (H & _)]; lra.
Qed.

Lemma vel_sub_le : forall v, F32 v = true -> Rabs (R2 v) <= 128 ->
  R2 (Float32.sub v f4) <= R2 (gravity f4 v).
Proof.
  intros v Fv Hv.
  destruct (f32_sub_val v f4 Fv F32_f4) as [Hval Hfin].
  { rewrite B2R_f4. eapply Rle_trans; [| apply (bpow_le radix2 8 100); lia].
    simpl. apply Rabs_le. apply Rabs_le_inv in Hv. split; lra. }
  unfold gravity. destruct (Float32.cmp Clt (Float32.sub v f4) fm75) eqn:Hc; [| lra].
  unfold Float32.cmp, Float32.compare in Hc.
  rewrite Binary.Bcompare_correct in Hc by first [exact Hfin | exact F32_fm75].
  rewrite Hval in Hc |- *.
  destruct (Rcompare_spec (rnd (R2 v - R2 f4)) (R2 fm75)) as [H | H | H];
    simpl in Hc; try discriminate; lra.
Qed.
