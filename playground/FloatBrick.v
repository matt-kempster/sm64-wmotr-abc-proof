(** * FloatBrick.v — GOAL-2 track T2: the Flocq binary32 interval brick.

    SANDBOX (playground/) — NOT on any spine, NOT imported by proofs/.
    This is the numeric core the GOAL-2 ballistic height bound (G2-I) needs.
    See docs/goal2-real-frame-plan.md (T2) and
    docs/goal2-strategy-v2-2026-07-01.md (the float layer, section 5).

    Everything is stated over CompCert's [float32] = Flocq [binary32]
    ([Binary.binary_float 24 128]), so that a Clight walk (T3) can consume a
    lemma directly on a value loaded from a [Vsingle] memory cell.

    THE REAL OPERATIONS this brick bounds (verified against the generated AST
    and vendor/sm64/src/game/mario_step.c):

      - perform_air_step (mario_step.c:618-621), the per-quarter-step y write:
            intendedPos[1] = m->pos[1] + m->vel[1] / 4.0f;
        In Clight (generated/mario_step.v, f_perform_air_step body ~L4529):
            Ebinop Oadd (pos) (Ebinop Odiv (vel) (Econst_single 4.0f))
        i.e. [Float32.add pos (Float32.div vel <4.0f>)].  The 4.0f literal is
        [Float32.of_bits (Int.repr 1082130432)] (= 0x40800000). The written
        value is then committed by [m->pos[1] = nextPos[1]] in the
        no-collision branch of perform_air_quarter_step (mario_step.c:482 /
        generated ~L. of the AIR_STEP_NONE fall-through).

      - apply_gravity, default airborne case (mario_step.c:576):
            m->vel[1] -= 4.0f;   ( = [Float32.sub vel <4.0f>] )
        followed by the terminal-velocity clamp [if (vel < -75) vel = -75],
        which only RAISES the value, so it preserves any UPPER bound on vel. *)

From compcert Require Import Floats Integers.
From Flocq Require Import Binary Bits Defs Raux Zaux Generic_fmt FLT.
From Flocq Require Import BinarySingleNaN.
Require Import Reals Lra Lia.

Open Scope R_scope.

(** binary32 format parameters. [SpecFloat.fexp 24 128] is the exponent
    function Bplus/Bminus/Bdiv_correct round with; it is definitionally
    [FLT_exp (-149) 24 = fun e => Z.max (e - 24) (-149)]. *)

Notation R2   := (Binary.B2R 24 128).
Notation fexp32 := (SpecFloat.fexp 24 128).
Notation rnd  := (round radix2 fexp32 (round_mode mode_NE)).

(** The format is a valid FLT exponent; [Prec_gt_0 24] is [eq_refl] because
    [0 < 24] computes to [Lt = Lt] (same trick CompCert uses in Floats.v). *)
Local Instance prec_gt_0_32 : FLX.Prec_gt_0 24.
Proof. red. lia. Qed.
Local Instance valid_exp_32 : Valid_exp fexp32 :=
  @FLT_exp_valid (-149) 24 prec_gt_0_32.
(* Valid_rnd (round_mode mode_NE) is the global instance valid_rnd_round_mode. *)

(* --------------------------------------------------------------------- *)
(** ** The 4.0f constant                                                  *)
(* --------------------------------------------------------------------- *)

(* CompCert seals these with Opaque; we need to unfold them to Bplus/Bminus/
   Bdiv to apply Flocq's correctness lemmas. *)
Local Transparent Float32.add Float32.sub Float32.div.

Definition f4 : float32 := Float32.of_bits (Int.repr 1082130432).

Lemma B2R_f4 : R2 f4 = 4%R.
Proof.
  unfold f4.
  vm_compute (Float32.of_bits (Int.repr 1082130432)).
  unfold Binary.B2R, F2R. simpl (Fnum _). simpl (Fexp _).
  change (IZR 8388608) with (bpow radix2 23).
  rewrite <- bpow_plus.
  change (23 + -21)%Z with 2%Z.
  reflexivity.
Qed.

Lemma finite_f4 : Binary.is_finite 24 128 f4 = true.
Proof. vm_compute. reflexivity. Qed.

Lemma f4_nonzero : R2 f4 <> 0%R.
Proof. rewrite B2R_f4. lra. Qed.

(* --------------------------------------------------------------------- *)
(** ** Rounding stays in a representable box (no-overflow engine)         *)
(* --------------------------------------------------------------------- *)

(** If [|z|] is bounded by a nonnegative representable [B], then [|rnd z|] is
    too — round-to-nearest cannot escape a representable envelope. *)
Lemma rnd_abs_le : forall B z,
  generic_format radix2 fexp32 B -> (0 <= B)%R -> (Rabs z <= B)%R ->
  (Rabs (rnd z) <= B)%R.
Proof.
  intros B z HfB HB Hz.
  apply Rabs_le_inv in Hz. destruct Hz as [Hlo Hhi].
  assert (HfoB : generic_format radix2 fexp32 (- B))
    by (apply generic_format_opp; exact HfB).
  apply Rabs_le. split.
  - rewrite <- (round_generic radix2 fexp32 (round_mode mode_NE) (- B) HfoB).
    apply round_le; [ exact _ | exact _ | lra ].
  - rewrite <- (round_generic radix2 fexp32 (round_mode mode_NE) B HfB).
    apply round_le; [ exact _ | exact _ | lra ].
Qed.

(** bpow 100 is representable and a convenient overflow cushion:
    binary32's largest finite is < bpow 128, and every game magnitude is
    << bpow 100 (~1.3e30). *)
Lemma gf_bpow100 : generic_format radix2 fexp32 (bpow radix2 100).
Proof.
  apply generic_format_bpow. unfold SpecFloat.fexp, SpecFloat.emin. lia.
Qed.

Lemma bpow100_lt_128 : (bpow radix2 100 < bpow radix2 128)%R.
Proof. apply bpow_lt. lia. Qed.

(** The overflow side condition of Bplus/Bminus_correct, discharged from a
    magnitude bound by bpow 100. *)
Lemma no_overflow_of_bpow100 : forall z,
  (Rabs z <= bpow radix2 100)%R ->
  Rlt_bool (Rabs (rnd z)) (bpow radix2 128) = true.
Proof.
  intros z Hz. apply Rlt_bool_true.
  eapply Rle_lt_trans.
  - apply rnd_abs_le; [ apply gf_bpow100 | apply bpow_ge_0 | exact Hz ].
  - apply bpow100_lt_128.
Qed.

(* --------------------------------------------------------------------- *)
(** ** 1. Addition upper bound                                            *)
(* --------------------------------------------------------------------- *)

(** General (always-valid) version: the result is at most the rounded sum of
    the input bounds. No representability of [bx+by_] required. *)
Lemma f32_add_le_round : forall x y bx by_,
  Binary.is_finite 24 128 x = true ->
  Binary.is_finite 24 128 y = true ->
  (R2 x <= bx)%R -> (R2 y <= by_)%R ->
  (Rabs (R2 x + R2 y) <= bpow radix2 100)%R ->
  (R2 (Float32.add x y) <= rnd (bx + by_))%R
  /\ Binary.is_finite 24 128 (Float32.add x y) = true.
Proof.
  intros x y bx by_ Fx Fy Hx Hy Hovf.
  unfold Float32.add.
  (* grab the exact proof terms from the goal so HB matches syntactically *)
  match goal with |- context[Binary.Bplus ?p ?e ?g1 ?g2 ?nan ?md x y] =>
    pose proof (Binary.Bplus_correct p e g1 g2 nan md x y Fx Fy) as HB end.
  rewrite (no_overflow_of_bpow100 _ Hovf) in HB.
  destruct HB as (Hval & Hfin & _).
  split; [ | exact Hfin ].
  rewrite Hval.
  apply round_le; [ exact _ | exact _ | lra ].
Qed.

(** Tight version: given a representable ceiling [B] on [bx + by_], the
    result is [<= B].  With [B = bx + by_] (when that is representable) this
    is the exact-bound form [round_le + round_generic]. *)
Lemma f32_add_le_bound : forall x y bx by_ B,
  Binary.is_finite 24 128 x = true ->
  Binary.is_finite 24 128 y = true ->
  (R2 x <= bx)%R -> (R2 y <= by_)%R ->
  (Rabs (R2 x + R2 y) <= bpow radix2 100)%R ->
  generic_format radix2 fexp32 B ->
  (bx + by_ <= B)%R ->
  (R2 (Float32.add x y) <= B)%R
  /\ Binary.is_finite 24 128 (Float32.add x y) = true.
Proof.
  intros x y bx by_ B Fx Fy Hx Hy Hovf HfB Hle.
  destruct (f32_add_le_round x y bx by_ Fx Fy Hx Hy Hovf) as [Hr Hfin].
  split; [ | exact Hfin ].
  eapply Rle_trans; [ exact Hr | ].
  rewrite <- (round_generic radix2 fexp32 (round_mode mode_NE) B HfB).
  apply round_le; [ exact _ | exact _ | exact Hle ].
Qed.

(* --------------------------------------------------------------------- *)
(** ** 2. Gravity step:  vel' = vel - 4.0f                                *)
(* --------------------------------------------------------------------- *)

(** Upper bound after subtracting 4. The subsequent terminal-velocity clamp
    only raises the value, so this bounds the whole gravity step from above. *)
Lemma f32_sub4_le_round : forall vel bv,
  Binary.is_finite 24 128 vel = true ->
  (R2 vel <= bv)%R ->
  (Rabs (R2 vel - 4) <= bpow radix2 100)%R ->
  (R2 (Float32.sub vel f4) <= rnd (bv - 4))%R
  /\ Binary.is_finite 24 128 (Float32.sub vel f4) = true.
Proof.
  intros vel bv Fv Hv Hovf.
  unfold Float32.sub.
  match goal with |- context[Binary.Bminus ?p ?e ?g1 ?g2 ?nan ?md vel f4] =>
    pose proof (Binary.Bminus_correct p e g1 g2 nan md vel f4 Fv finite_f4) as HB end.
  rewrite B2R_f4 in HB.
  rewrite (no_overflow_of_bpow100 _ Hovf) in HB.
  destruct HB as (Hval & Hfin & _).
  split; [ | exact Hfin ].
  rewrite Hval.
  apply round_le; [ exact _ | exact _ | lra ].
Qed.

(** Tight/exact version: with a representable ceiling on [bv - 4]. *)
Lemma f32_sub4_le_bound : forall vel bv B,
  Binary.is_finite 24 128 vel = true ->
  (R2 vel <= bv)%R ->
  (Rabs (R2 vel - 4) <= bpow radix2 100)%R ->
  generic_format radix2 fexp32 B ->
  (bv - 4 <= B)%R ->
  (R2 (Float32.sub vel f4) <= B)%R
  /\ Binary.is_finite 24 128 (Float32.sub vel f4) = true.
Proof.
  intros vel bv B Fv Hv Hovf HfB Hle.
  destruct (f32_sub4_le_round vel bv Fv Hv Hovf) as [Hr Hfin].
  split; [ | exact Hfin ].
  eapply Rle_trans; [ exact Hr | ].
  rewrite <- (round_generic radix2 fexp32 (round_mode mode_NE) B HfB).
  apply round_le; [ exact _ | exact _ | exact Hle ].
Qed.

(* --------------------------------------------------------------------- *)
(** ** 3. Quarter step:  vel / 4.0f  is EXACT                             *)
(* --------------------------------------------------------------------- *)

(** Dividing a binary32 by the power-of-two 4.0f is an exponent shift and
    hence exact, PROVIDED the exact quotient [R2 vel / 4] is representable
    (i.e. no underflow into subnormal loss — always true for the game's
    non-tiny velocities; stated as the honest side condition [Hgf]). *)
Lemma f32_quarter_exact : forall vel,
  Binary.is_finite 24 128 vel = true ->
  generic_format radix2 fexp32 (R2 vel / 4) ->
  R2 (Float32.div vel f4) = (R2 vel / 4)%R
  /\ Binary.is_finite 24 128 (Float32.div vel f4) = true.
Proof.
  intros vel Hfin Hgf.
  unfold Float32.div.
  match goal with |- context[Binary.Bdiv ?p ?e ?g1 ?g2 ?nan ?md vel f4] =>
    pose proof (Binary.Bdiv_correct p e g1 g2 nan md vel f4 f4_nonzero) as HB end.
  rewrite B2R_f4 in HB.
  (* round (R2 vel / 4) = R2 vel / 4 by representability *)
  assert (Hround : rnd (R2 vel / 4) = R2 vel / 4)
    by (exact (round_generic radix2 fexp32 (round_mode mode_NE) (R2 vel / 4) Hgf)).
  assert (Hovf : Rlt_bool (Rabs (rnd (R2 vel / 4))) (bpow radix2 128) = true).
  { apply Rlt_bool_true. rewrite Hround.
    eapply Rle_lt_trans; [ | apply (Binary.abs_B2R_lt_emax 24 128 vel) ].
    unfold Rdiv. rewrite Rabs_mult.
    rewrite (Rabs_right (/ 4)) by lra.
    (* |R2 vel| * /4 <= |R2 vel| *)
    rewrite <- (Rmult_1_r (Rabs (R2 vel))) at 2.
    apply Rmult_le_compat_l; [ apply Rabs_pos | lra ]. }
  rewrite Hovf in HB.
  destruct HB as (Hval & Hfin2 & _).
  split.
  - rewrite Hval. exact Hround.
  - rewrite Hfin2. exact Hfin.
Qed.

(* --------------------------------------------------------------------- *)
(** ** 4. The composed corollary T3 consumes:                            *)
(**       one quarter-step's y write  pos + vel/4  is bounded.           *)
(* --------------------------------------------------------------------- *)

(** [y <= Y] and [vel <= V]  ==>  the written y' = pos + vel/4  is <= Y + V/4,
    through the real float operations [Float32.add pos (Float32.div vel 4.0f)].
    Side conditions: quarter exactness ([Hq]), representability of the ceiling
    [Y + V/4] ([HB]), and the (trivial) no-overflow cushion ([Hovf]). *)
Lemma f32_quarter_step_y_bound : forall pos vel Y V,
  Binary.is_finite 24 128 pos = true ->
  Binary.is_finite 24 128 vel = true ->
  (R2 pos <= Y)%R ->
  (R2 vel <= V)%R ->
  generic_format radix2 fexp32 (R2 vel / 4) ->
  generic_format radix2 fexp32 (Y + V / 4) ->
  (Rabs (R2 pos + R2 vel / 4) <= bpow radix2 100)%R ->
  (R2 (Float32.add pos (Float32.div vel f4)) <= Y + V / 4)%R
  /\ Binary.is_finite 24 128 (Float32.add pos (Float32.div vel f4)) = true.
Proof.
  intros pos vel Y V Fpos Fvel HY HV Hq HB Hovf.
  destruct (f32_quarter_exact vel Fvel Hq) as [Hqval Hqfin].
  (* B2R of the quotient equals vel/4, so it is <= V/4 *)
  assert (Hqle : (R2 (Float32.div vel f4) <= V / 4)%R).
  { rewrite Hqval. apply Rmult_le_compat_r; [ lra | exact HV ]. }
  eapply f32_add_le_bound with (bx := Y) (by_ := V / 4) (B := Y + V / 4).
  - exact Fpos.
  - exact Hqfin.
  - exact HY.
  - exact Hqle.
  - rewrite Hqval. exact Hovf.
  - exact HB.
  - lra.
Qed.

(* Sanity: force the key results into the checked cone. *)
Check f32_add_le_bound.
Check f32_add_le_round.
Check f32_sub4_le_bound.
Check f32_quarter_exact.
Check f32_quarter_step_y_bound.
