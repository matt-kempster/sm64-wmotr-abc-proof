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
From SM64.Proofs Require Import Interp.SymExec2 HeightInvariant HeightBudgetArith WMotRLevel.
From SM64.Proofs.WMotRRequiresA Require Import HeightFloatSteps.
From SM64.Proofs.WMotRRequiresA Require Import FloorList FloorHeight FloorBound.
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

Definition sveqb (a b : sval) : bool := if sval_eq a b then true else false.

Lemma sveqb_eq : forall a b, sveqb a b = true -> a = b.
Proof. unfold sveqb; intros a b H. destruct (sval_eq a b); [exact e | discriminate]. Qed.

(* the entry cells are terms: ey for pos[1], ev for vel[1] (m0's cells, or
   what a caller stored before the step, e.g. a rollout's launch).  The
   quarter vel[1] / 4.0f and gravity's vel[1] - gk (4.0f, or 2.0f for slide
   kick), as the walker builds them: folded to a constant when the entry vel
   is one *)
Definition f4c : sval := Sconst (Vsingle f4).
Definition qv (ev : sval) : sval :=
  match ev with
  | Sconst (Vsingle x) => Sconst (Vsingle (Float32.div x f4))
  | _ => Sbinop Cop.Odiv ev tf f4c tf
  end.
Definition gv (gk : float32) (ev : sval) : sval :=
  match ev with
  | Sconst (Vsingle x) => Sconst (Vsingle (Float32.sub x gk))
  | _ => Sbinop Cop.Osub ev tf (Sconst (Vsingle gk)) tf
  end.

Definition is_q (ev : sval) (a : sval) : bool := sveqb a (qv ev).

(* k real quarter adds on the entry pos[1] term ey, then j adds of +0.0f *)
Fixpoint qrec (ey ev : sval) (a : sval) : option (nat * nat) :=
  if sveqb a ey then Some (O, O) else
  match a with
  | Sbinop Cop.Oadd a1 t1 a2 t2 =>
      if is_tf t1 && is_tf t2 then
        match qrec ey ev a1 with
        | Some (k, j) =>
            if is_q ev a2 then (match j with O => Some (S k, O) | _ => None end)
            else match a2 with
                 | Sconst v => if is_f v Float32.zero then Some (k, S j) else None
                 | _ => None
                 end
        | None => None
        end
      else None
  | _ => None
  end.

Lemma qrec_eq : forall ey ev a, qrec ey ev a =
  if sveqb a ey then Some (O, O) else
  match a with
  | Sbinop Cop.Oadd a1 t1 a2 t2 =>
      if is_tf t1 && is_tf t2 then
        match qrec ey ev a1 with
        | Some (k, j) =>
            if is_q ev a2 then (match j with O => Some (S k, O) | _ => None end)
            else match a2 with
                 | Sconst v => if is_f v Float32.zero then Some (k, S j) else None
                 | _ => None
                 end
        | None => None
        end
      else None
  | _ => None
  end.
Proof. intros ey ev a. destruct a; reflexivity. Qed.

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

Lemma qv_den : forall ge m0 E ev v, den ge m0 E ev = Some (Vsingle v) ->
  den ge m0 E (qv ev) = Some (Vsingle (Float32.div v f4)).
Proof.
  intros ge m0 E ev v HV.
  assert (G : den ge m0 E (Sbinop Cop.Odiv ev tf f4c tf) = Some (Vsingle (Float32.div v f4)))
    by (cbn [den]; rewrite HV; reflexivity).
  unfold qv. destruct ev as [w | | | | | | | | |]; try exact G.
  all: destruct w; try exact G; cbn [den] in HV; injection HV as ->; reflexivity.
Qed.

Lemma gv_den : forall ge m0 E gk ev v, den ge m0 E ev = Some (Vsingle v) ->
  den ge m0 E (gv gk ev) = Some (Vsingle (Float32.sub v gk)).
Proof.
  intros ge m0 E gk ev v HV.
  assert (G : den ge m0 E (Sbinop Cop.Osub ev tf (Sconst (Vsingle gk)) tf) = Some (Vsingle (Float32.sub v gk)))
    by (cbn [den]; rewrite HV; reflexivity).
  unfold gv. destruct ev as [w | | | | | | | | |]; try exact G.
  all: destruct w; try exact G; cbn [den] in HV; injection HV as ->; reflexivity.
Qed.

Section DEN.
Variables (ge : genv) (m0 : mem) (E : senv) (ey ev : sval) (y v : float32).
Hypothesis HY : den ge m0 E ey = Some (Vsingle y).
Hypothesis HV : den ge m0 E ev = Some (Vsingle v).

Lemma is_q_den : forall a, is_q ev a = true -> den ge m0 E a = Some (Vsingle (Float32.div v f4)).
Proof. intros a H. apply sveqb_eq in H. subst a. exact (qv_den ge m0 E ev v HV). Qed.

Lemma qrec_den : forall a kq jz, qrec ey ev a = Some (kq, jz) ->
  den ge m0 E a = Some (Vsingle (add_zeros jz (quarter_steps kq y (Float32.div v f4)))).
Proof.
  induction a; intros kq jz H; rewrite qrec_eq in H;
    (match type of H with context [sveqb ?x ey] => destruct (sveqb x ey) eqn:SE end);
    cbv beta iota in H;
    try (injection H as <- <-; apply sveqb_eq in SE; rewrite SE; exact HY);
    try discriminate H.
  destruct op; cbv beta iota in H; try discriminate H.
  destruct (is_tf t1 && is_tf t2) eqn:T; [| discriminate].
  apply andb_true_iff in T as (T1 & T2). apply is_tf_eq in T1. apply is_tf_eq in T2. rewrite T1, T2.
  destruct (qrec ey ev a1) as [[k1 j1]|] eqn:R1; [| discriminate].
  specialize (IHa1 _ _ eq_refl).
  destruct (is_q ev a2) eqn:Q.
  + destruct j1; [| discriminate]. injection H as <- <-.
    cbn [den]. rewrite IHa1, (is_q_den _ Q). reflexivity.
  + destruct a2; try discriminate. destruct (is_f v0 Float32.zero) eqn:Z0; [| discriminate].
    apply is_f_eq in Z0. rewrite Z0. injection H as <- <-.
    cbn [den]. rewrite IHa1. reflexivity.
Qed.

End DEN.

(* ---- the vel[1] outcomes sit at or below gravity's ---- *)

(* the walk leaves vel[1] as -75 (the clamp branch) or vel - gk (the other
   one); both are <= gravity gk vel as reals, branch facts not needed.  gk is
   apply_gravity's 4.0f, or 2.0f for slide kick *)
Section GK.
Variable gk : float32.
Hypothesis Fgk : F32 gk = true.
Hypothesis Hgk : R2 gk = 2 \/ R2 gk = 4.

Lemma sub_gk_val : forall v, F32 v = true -> Rabs (R2 v) <= 128 ->
  R2 (Float32.sub v gk) = rnd (R2 v - R2 gk) /\ F32 (Float32.sub v gk) = true.
Proof.
  intros v Fv Hv. apply (f32_sub_val v gk Fv Fgk).
  eapply Rle_trans; [| apply (bpow_le radix2 8 100); lia].
  simpl. apply Rabs_le. apply Rabs_le_inv in Hv. destruct Hgk as [G | G]; rewrite G; split; lra.
Qed.

Lemma vel_clamp_le : forall v, F32 v = true -> Rabs (R2 v) <= 128 ->
  R2 fm75 <= R2 (gravity gk v).
Proof.
  intros v Fv Hv. rewrite B2R_fm75.
  destruct (gravity_spec2 gk v Fgk Fv Hgk Hv) as [(_ & H) | (H & _)]; lra.
Qed.

Lemma vel_sub_le : forall v, F32 v = true -> Rabs (R2 v) <= 128 ->
  R2 (Float32.sub v gk) <= R2 (gravity gk v).
Proof.
  intros v Fv Hv.
  destruct (sub_gk_val v Fv Hv) as [Hval Hfin].
  unfold gravity. destruct (Float32.cmp Clt (Float32.sub v gk) fm75) eqn:Hc; [| lra].
  unfold Float32.cmp, Float32.compare in Hc.
  rewrite Binary.Bcompare_correct in Hc by first [exact Hfin | exact F32_fm75].
  rewrite Hval in Hc |- *.
  destruct (Rcompare_spec (rnd (R2 v - R2 gk)) (R2 fm75)) as [H | H | H];
    simpl in Hc; try discriminate; lra.
Qed.

Lemma sub_ge_m75 : forall v, F32 v = true -> Rabs (R2 v) <= 128 ->
  Float32.cmp Clt (Float32.sub v gk) fm75 = false ->
  R2 fm75 <= R2 (Float32.sub v gk) /\ F32 (Float32.sub v gk) = true.
Proof.
  intros v Fv Hv Hc.
  destruct (sub_gk_val v Fv Hv) as [Hval Hfin].
  split; [| exact Hfin].
  unfold Float32.cmp, Float32.compare in Hc.
  rewrite Binary.Bcompare_correct in Hc by first [exact Hfin | exact F32_fm75].
  destruct (Rcompare_spec (R2 (Float32.sub v gk)) (R2 fm75)) as [H | H | H];
    simpl in Hc; try discriminate; lra.
Qed.
End GK.

Definition c20 : float32 := Float32.of_bits (Int.repr 1101004800).  (* 0x41A00000 = 20.0f *)
Definition tI32 : type := Tint I32 Signed noattr.
Definition tbool : type := Tint IBool Unsigned noattr.

Lemma B2R_c20 : R2 c20 = 20.
Proof. unfold c20. vm_compute (Float32.of_bits _). unfold Binary.B2R, F2R. simpl. lra. Qed.
Lemma F32_c20 : F32 c20 = true.  Proof. vm_compute. reflexivity. Qed.

(* the jump-ascent quarter of a vel > 20 is in [-75, gravity's] *)
Lemma vel_div_ok : forall gk, F32 gk = true -> R2 gk = 2 \/ R2 gk = 4 ->
  forall v, F32 v = true -> Rabs (R2 v) <= 128 -> Float32.cmp Cgt v c20 = true ->
  F32 (Float32.div v f4) = true /\ R2 fm75 <= R2 (Float32.div v f4)
  /\ R2 (Float32.div v f4) <= R2 (gravity gk v).
Proof.
  intros gk Fgk Hgk v Fv Hv Hc.
  assert (V20 : 20 < R2 v).
  { unfold Float32.cmp, Float32.compare in Hc.
    rewrite Binary.Bcompare_correct in Hc by first [exact Fv | exact F32_c20].
    rewrite B2R_c20 in Hc.
    destruct (Rcompare_spec (R2 v) 20) as [H | H | H]; simpl in Hc; try discriminate; lra. }
  destruct (quarter_spec v Fv Hv) as (Fq & Hq & _ & Hq0).
  apply Rabs_le_inv in Hq. pose proof (Hq0 ltac:(lra)) as Q0.
  split; [exact Fq | split; [rewrite B2R_fm75; lra |]].
  destruct (gravity_spec2 gk v Fgk Fv Hgk Hv) as [(L & _) | (_ & G)];
    [destruct Hgk as [Hg | Hg]; rewrite Hg in L; lra |].
  apply Rabs_le_inv in G. destruct Hgk as [Hg | Hg]; rewrite Hg in G; lra.
Qed.

(* ---- classifying one walk outcome ---- *)

Definition fm4 : float32 := Float32.of_bits (Int.repr 3229614080).  (* 0xC0800000 *)

Lemma B2R_fm4 : R2 fm4 = -4.
Proof. unfold fm4. vm_compute (Float32.of_bits _). unfold Binary.B2R, F2R. simpl. lra. Qed.

(* apply_gravity's constant for the entry's action term (mario_step.c:543-548):
   2.0f for slide kick, else 4.0f.  A symbolic term gets 4.0f: the class
   then only claims what the walk's terms denote, for that constant *)
Definition gk_of (ta : sval) : float32 :=
  match ta with Sconst (Vint a) => if Int.eq a ACT_SLIDE_KICK then f2 else f4 | _ => f4 end.
Definition is_skt (ta : sval) : bool :=
  match ta with Sconst (Vint a) => Int.eq a ACT_SLIDE_KICK | _ => false end.

Lemma gk_cases : forall ta, gk_of ta = f2 \/ gk_of ta = f4.
Proof.
  intros ta. unfold gk_of. destruct ta as [w | | | | | | | | |]; auto.
  destruct w; auto. destruct (Int.eq _ _); auto.
Qed.
Lemma F32_gk : forall ta, F32 (gk_of ta) = true.
Proof. intros ta. destruct (gk_cases ta) as [-> | ->]; [exact F32_f2 | exact F32_f4]. Qed.
Lemma R2_gk : forall ta, R2 (gk_of ta) = 2 \/ R2 (gk_of ta) = 4.
Proof. intros ta. destruct (gk_cases ta) as [-> | ->]; [left; exact B2R_f2 | right; exact B2R_f4]. Qed.
Lemma gk_skt : forall ta, is_skt ta = true -> gk_of ta = f2.
Proof.
  intros ta. unfold is_skt, gk_of. destruct ta as [w | | | | | | | | |]; try discriminate.
  destruct w; try discriminate. intros ->. reflexivity.
Qed.
Lemma gk_nskt : forall ta, is_skt ta = false -> gk_of ta = f4.
Proof.
  intros ta. unfold is_skt, gk_of. destruct ta as [w | | | | | | | | |]; try reflexivity.
  destruct w; try reflexivity. intros ->. reflexivity.
Qed.

(* a ceiling cut zeroes vel[1]; gravity then leaves 0.0f - gk *)
Definition cutv (gk : float32) : float32 := Float32.sub Float32.zero gk.
Lemma B2R_cutv4 : R2 (cutv f4) = -4.
Proof. unfold cutv. vm_compute (Float32.sub _ _). unfold Binary.B2R, F2R. simpl. lra. Qed.
Lemma B2R_cutv2 : R2 (cutv f2) = -2.
Proof. unfold cutv. vm_compute (Float32.sub _ _). unfold Binary.B2R, F2R. simpl. lra. Qed.
Lemma F32_cutv : forall ta, F32 (cutv (gk_of ta)) = true.
Proof. intros ta. destruct (gk_cases ta) as [-> | ->]; vm_compute; reflexivity. Qed.
Lemma R2_cutv : forall ta, R2 (cutv (gk_of ta)) = - R2 (gk_of ta).
Proof.
  intros ta. destruct (gk_cases ta) as [-> | ->];
    [rewrite B2R_cutv2, B2R_f2 | rewrite B2R_cutv4, B2R_f4]; ring.
Qed.

(* the MarioState / Object cells the classes speak about *)
Definition oA : Z := 12.   Definition oS : Z := 24.   Definition oT : Z := 26.
Definition oY : Z := 64.   Definition oV : Z := 76.   Definition oG : Z := 36.

Inductive aclass : Type :=
  | Cair                 (* 4 real quarters, vel to gravity's or below *)
  | Ccut (k : nat).      (* k real quarters then +0.0f adds, vel = -4 *)

Definition is_fm75 (a : sval) : bool := match a with Sconst c => is_f c fm75 | _ => false end.

(* gravity's vel - gk on the entry vel term ev, or the -75 clamp *)
Definition vel_grav (gk : float32) (ev : sval) (a : sval) : bool := sveqb a (gv gk ev) || is_fm75 a.

(* the path's fact that the clamp branch was not taken: !(vel - gk < -75.0f) *)
Definition is_gfact (gk : float32) (ev : sval) (f : fact) : bool :=
  match f with
  | Fbool (Sbinop Cop.Olt x t3 (Sconst c2) t4) _ false =>
      sveqb x (gv gk ev) && is_tf t3 && is_tf t4 && is_f c2 fm75
  | _ => false
  end.
(* ... or, for a constant entry vel (the walker folded the test), computed *)
Definition nclamp (gk : float32) (ev : sval) (pc : list fact) : bool :=
  match ev with
  | Sconst (Vsingle x) => negb (Float32.cmp Clt (Float32.sub x gk) fm75)
  | _ => existsb (is_gfact gk ev) pc
  end.

(* the jump-ascent branch of apply_gravity (an ACT_FLAG_CONTROL_JUMP_HEIGHT
   action, A not held, vel[1] > 20.0f: mario_step.c:528,559): vel[1] /= 4.0f.
   should_strengthen_gravity_for_jump_ascent tests (_Bool)(vel[1] > 20.0f) *)
Definition is_v20 (ev : sval) (f : fact) : bool :=
  match f with
  | Fbool (Scast (Sbinop Cop.Ogt x t1 (Sconst c) t2) t3 t4) ty true =>
      sveqb x ev && is_tf t1 && is_tf t2 && is_f c c20
      && (if type_eq t3 tI32 then true else false) && (if type_eq t4 tbool then true else false)
      && (if type_eq ty tI32 then true else false)
  | _ => false
  end.
Definition v20 (ev : sval) (pc : list fact) : bool :=
  match ev with
  | Sconst (Vsingle x) => Float32.cmp Cgt x c20
  | _ => existsb (is_v20 ev) pc
  end.
Definition vel_div (ev : sval) (pc : list fact) (a : sval) : bool := sveqb a (qv ev) && v20 ev pc.

(* vel[1] is the clamp, or vel - gk on a path that did not clamp, or the
   jump-ascent quarter *)
Definition vel_ok (gk : float32) (ev : sval) (pc : list fact) (a : sval) : bool :=
  is_fm75 a || (sveqb a (gv gk ev) && nclamp gk ev pc) || vel_div ev pc a.

Definition vel_cut (gk : float32) (a : sval) : bool :=
  match a with Sconst c => is_f c (cutv gk) | _ => false end.

(* the path's fact that the clamp branch was taken: vel - gk < -75.0f *)
Definition is_cfact (gk : float32) (ev : sval) (f : fact) : bool :=
  match f with
  | Fbool (Sbinop Cop.Olt x t3 (Sconst c2) t4) _ true =>
      sveqb x (gv gk ev) && is_tf t3 && is_tf t4 && is_f c2 fm75
  | _ => false
  end.
(* ... or, for a constant entry vel (the walker folded the test), computed *)
Definition clampc (gk : float32) (ev : sval) (pc : list fact) : bool :=
  match ev with
  | Sconst (Vsingle x) => Float32.cmp Clt (Float32.sub x gk) fm75
  | _ => existsb (is_cfact gk ev) pc
  end.
(* vel[1] is exactly apply_gravity's (HeightFloatSteps.gravity): the clamp
   on a path that took it, or vel - gk on a path that did not.  Slide kick's
   branch of apply_gravity (mario_step.c:543-548) has no jump-ascent case,
   and its post-bounce catalog step (S_sk_bounced) reads vel exactly *)
Definition vel_ex (gk : float32) (ev : sval) (pc : list fact) (a : sval) : bool :=
  (is_fm75 a && clampc gk ev pc) || (sveqb a (gv gk ev) && nclamp gk ev pc).

Section CLS.
Variable ld : positive -> Z -> memory_chunk -> option sval.  (* the outcome's cells *)
Variable ic : positive -> Z -> memory_chunk -> sval.          (* the entry's cells *)
Variable pc : list fact.                                      (* the outcome's path facts *)
Variables rM rO : positive.

Definition same_cell (o : Z) (ch : memory_chunk) : bool :=
  match ld rM o ch with Some a => sveqb a (ic rM o ch) | None => false end.

(* a landing: pos[1] = gfx.pos[1] := the entry floorHeight cell, or a value
   find_floor returned (a fresh name), named by find_floor's height fact
   Fuser kH [height; yPos] (FloorExec.c_ff) with yPos a quarter-step term *)
Variable kH : positive.
Definition oF : Z := 112.
Definition hfact (n : positive) (f : fact) : bool :=
  match f with
  | Fuser k [Sfresh n'; ya] =>
      Pos.eqb k kH && Pos.eqb n' n
      && match qrec (ic rM oY Mfloat32) (ic rM oV Mfloat32) ya with Some (kq, _) => Nat.leb kq 4 | None => false end
  | _ => false
  end.
Definition is_land (a : sval) : bool :=
  sveqb a (ic rM oF Mfloat32) || match a with Sfresh n => existsb (hfact n) pc | _ => false end.

(* the step did not land: the path took the branch
   !(nextPos[1] <= floorHeight) (mario_step.c perform_air_quarter_step),
   with floorHeight the entry m->floorHeight (a floorless quarter) or a
   find_floor height (is_land's two forms); a zero-quarter cut leaves pos *)
Definition is_above (py pf : sval) (f : fact) : bool :=
  match f with
  | Fbool (Sbinop Cop.Ole a t1 x t2) _ false =>
      sveqb a py && sveqb x pf && is_tf t1 && is_tf t2 && is_land x
  | _ => false
  end.
(* the compared height must be the outcome's floorHeight cell: then the
   step ends with pos[1] above its own floorHeight (a floor refresh) *)
Definition above (py : sval) : bool :=
  match ld rM oF Mfloat32 with Some pf => existsb (is_above py pf) pc | None => false end.

(* the ceiling cut's branch fact vel[1] >= 0.0f (mario_step.c:446) on the
   entry vel term, or computed for a constant entry vel; slide kick's
   catalog cut (S_air_cut) needs it *)
Definition vge0 (f : fact) : bool :=
  match f with
  | Fbool (Sbinop Cop.Oge x t1 (Sconst c) t2) _ true =>
      sveqb x (ic rM oV Mfloat32) && is_tf t1 && is_tf t2 && is_f c Float32.zero
  | _ => false
  end.
Definition vge0c : bool :=
  match ic rM oV Mfloat32 with
  | Sconst (Vsingle x) => Float32.cmp Cge x Float32.zero
  | _ => existsb vge0 pc
  end.

Definition aclass_of : option aclass :=
  if same_cell oA Mint32 && same_cell oS Mint16unsigned && same_cell oT Mint16unsigned then
    match ld rM oY Mfloat32, ld rM oV Mfloat32, ld rO oG Mfloat32 with
    | Some py, Some vy, Some gy =>
        if sveqb gy py then
          match qrec (ic rM oY Mfloat32) (ic rM oV Mfloat32) py with
          | Some (k, j) =>
              if vel_cut (gk_of (ic rM oA Mint32)) vy then
                (if Nat.leb k 4 && (negb (is_skt (ic rM oA Mint32)) || vge0c)
                    && ((Nat.eqb k 0 && same_cell oF Mfloat32) || above py)
                 then Some (Ccut k) else None)
              else if vel_ok (gk_of (ic rM oA Mint32)) (ic rM oV Mfloat32) pc vy then
                (match k, j with 4%nat, O => if above py then Some Cair else None | _, _ => None end)
              else None
          | None => None
          end
        else None
    | _, _, _ => None
    end
  else None.

Definition land_ok : bool :=
  same_cell oA Mint32 && same_cell oS Mint16unsigned && same_cell oT Mint16unsigned
  && match ld rM oY Mfloat32, ld rM oV Mfloat32, ld rO oG Mfloat32 with
     | Some py, Some vy, Some gy =>
         sveqb gy py && is_land py
         && (vel_cut (gk_of (ic rM oA Mint32)) vy || vel_ok (gk_of (ic rM oA Mint32)) (ic rM oV Mfloat32) pc vy)
     | _, _, _ => false
     end.

(* any find_floor height (a fresh name with a height fact) *)
Definition is_hf (a : sval) : bool :=
  match a with
  | Sfresh n => existsb (fun f => match f with
                                  | Fuser k [Sfresh n'; _] => Pos.eqb k kH && Pos.eqb n' n
                                  | _ => false end) pc
  | _ => false
  end.

(* every outcome: m->marioObj still points at Mario's object, and
   floorHeight is the entry cell or a find_floor height *)
Definition oMO : Z := 136.
Definition cells_ok : bool :=
  match ld rM oMO Mint32 with
  | Some (Sptr r o) => Pos.eqb r rO && Ptrofs.eq o Ptrofs.zero
  | _ => false
  end
  && match ld rM oF Mfloat32 with Some a => is_land a || is_hf a | None => false end.

(* a ledge grab (mario_step.c check_ledge_grab, AIR_STEP_CHECK_LEDGE_GRAB):
   pos[1] = gfx = find_floor's height searched from nextPos[1] + 160.0f, on a
   path that passed !(vel[1] > 0) with vel[1] the entry cell (any quarter), or
   after a ceiling bump zeroed vel[1] (the search y is at most two quarters up) *)
Definition c160 : float32 := Float32.of_bits (Int.repr 1126170624).   (* 160.0f *)
Definition lfact (km : nat) (n : positive) (f : fact) : bool :=
  match f with
  | Fuser k [Sfresh n'; Sbinop Cop.Oadd q t1 (Sconst c) t2] =>
      Pos.eqb k kH && Pos.eqb n' n && is_tf t1 && is_tf t2 && is_f c c160
      && match qrec (ic rM oY Mfloat32) (ic rM oV Mfloat32) q with Some (kq, _) => Nat.leb kq km | None => false end
  | _ => false
  end.
Definition ti32 : type := Tint I32 Signed noattr.
Definition vle0 (f : fact) : bool :=
  match f with
  | Fbool (Sbinop Cop.Ogt x t1 (Sconst (Vint i)) t2) _ false =>
      sveqb x (ic rM oV Mfloat32) && is_tf t1 && (if type_eq t2 ti32 then true else false)
      && Int.eq i Int.zero
  | _ => false
  end.
(* vel[1] <= 0 at entry: a path fact, or computed for a constant entry vel *)
Definition vle0c : bool :=
  match ic rM oV Mfloat32 with
  | Sconst (Vsingle x) => negb (Float32.cmp Cgt x (Float32.of_int Int.zero))
  | _ => existsb vle0 pc
  end.
Definition ledge_ok : bool :=
  same_cell oA Mint32 && same_cell oS Mint16unsigned && same_cell oT Mint16unsigned
  && match ld rM oY Mfloat32, ld rM oV Mfloat32, ld rO oG Mfloat32 with
     | Some py, Some vy, Some gy =>
         sveqb gy py
         && match py with
            | Sfresh n => existsb (lfact (if vle0c then 4%nat else 2%nat) n) pc
            | _ => false end
         && (vel_cut (gk_of (ic rM oA Mint32)) vy || vel_ok (gk_of (ic rM oA Mint32)) (ic rM oV Mfloat32) pc vy)
     | _, _, _ => false
     end.

Definition outcome_ok : bool :=
  cells_ok && match aclass_of with Some _ => true | None => land_ok || ledge_ok end.

(* the outcome's vel[1] is the cut's, or exactly gravity's (vel_ex) *)
Definition vel_exc : bool :=
  match ld rM oV Mfloat32 with
  | Some vy => vel_cut (gk_of (ic rM oA Mint32)) vy
               || vel_ex (gk_of (ic rM oA Mint32)) (ic rM oV Mfloat32) pc vy
  | None => false
  end.
End CLS.

(* ---- what a class says about the outcome's memory ---- *)

Section CLS_SOUND.
Variables (ge : genv) (nbase : positive) (R0 : list (positive * Z)) (gtab : list (ident * positive))
  (kv : list (positive * Z * memory_chunk * sval)) (m0 : mem)
  (uf : positive -> list (option val) -> Prop) (gp : meminj).
Hypothesis gp_old : forall b x, gp b = Some x -> Plt b (Mem.nextblock m0).
Variables (E : senv) (m : mem) (g : gst) (rM rO : positive) (y v : float32).
Variable kH : positive.
Hypothesis MM : MMg ge nbase R0 gtab kv m0 uf gp E m g.
(* the height fact's meaning (AirRun.ufW) *)
Hypothesis HUH : forall vs, uf kH vs ->
  exists h yv, vs = [Some (Vsingle h); Some yv] /\ HPi (Hit_at ge m0) (ycast yv) h /\ Hit_at ge m0 h.
Hypothesis HbM : e_base E rM = Ptrofs.zero.

Local Notation LD := (sload nbase R0 kv g).
(* the entry cells: their terms at the call (m0's cells for a caller that
   changed none; the timer, state or vel[1] for one that ticked or set them),
   with pos[1] = y and vel[1] = v *)
Variable IC : positive -> Z -> memory_chunk -> sval.
Hypothesis HY : den ge m0 E (IC rM oY Mfloat32) = Some (Vsingle y).
Hypothesis HV : den ge m0 E (IC rM oV Mfloat32) = Some (Vsingle v).
(* the step's gravity constant, read off the entry action term *)
Local Notation GK := (gk_of (IC rM oA Mint32)).

Lemma ld_sound : forall r o ch a, LD r o ch = Some a ->
  Mem.load ch m (e_blk E r) (addr E r o) = den ge m0 E a.
Proof.
  intros r o ch a L.
  exact (proj1 (sload_sound ge nbase R0 gtab kv (fun _ => None) (fun _ => false) m0 uf gp gp_old
                  E m g r o ch a MM L)).
Qed.

Lemma addr_M : forall o, addr E rM o = o.
Proof. intros o. unfold addr. rewrite HbM, Ptrofs.unsigned_zero. lia. Qed.

Lemma same_cell_den : forall o ch, same_cell LD IC rM o ch = true ->
  Mem.load ch m (e_blk E rM) o = den ge m0 E (IC rM o ch).
Proof.
  intros o ch H. unfold same_cell in H.
  destruct (LD rM o ch) as [a|] eqn:L; [| discriminate].
  unfold sveqb in H. destruct (sval_eq a (IC rM o ch)) as [->|]; [| discriminate].
  pose proof (ld_sound _ _ _ _ L) as D. rewrite addr_M in D. exact D.
Qed.

(* entry cells unchanged: action, state and timer hold their entry terms' values *)
Definition keeps_asT : Prop :=
  Mem.load Mint32 m (e_blk E rM) oA = den ge m0 E (IC rM oA Mint32)
  /\ Mem.load Mint16unsigned m (e_blk E rM) oS = den ge m0 E (IC rM oS Mint16unsigned)
  /\ Mem.load Mint16unsigned m (e_blk E rM) oT = den ge m0 E (IC rM oT Mint16unsigned).

(* the three integer entry cells, kept *)
Lemma same3 : same_cell LD IC rM oA Mint32 = true -> same_cell LD IC rM oS Mint16unsigned = true ->
  same_cell LD IC rM oT Mint16unsigned = true -> keeps_asT.
Proof.
  intros A S T. split; [exact (same_cell_den _ _ A) |].
  split; [exact (same_cell_den _ _ S) | exact (same_cell_den _ _ T)].
Qed.

Lemma vel_grav_den : forall a, vel_grav GK (IC rM oV Mfloat32) a = true ->
  den ge m0 E a = Some (Vsingle (Float32.sub v GK)) \/ den ge m0 E a = Some (Vsingle fm75).
Proof.
  intros a H. unfold vel_grav in H. apply orb_true_iff in H as [H | H].
  - left. apply sveqb_eq in H. subst a. exact (gv_den ge m0 E _ _ v HV).
  - right. destruct a; try discriminate. cbn [is_fm75] in H. apply is_f_eq in H. subst. reflexivity.
Qed.

(* a vel > 20 fact on the entry vel term *)
Lemma v20_fact : forall ev, den ge m0 E ev = Some (Vsingle v) ->
  existsb (is_v20 ev) (g_pc g) = true -> Float32.cmp Cgt v c20 = true.
Proof.
  intros ev HVe Hx.
  apply existsb_exists in Hx as (f & Hin & Hf').
  destruct MM as (_ & _ & _ & _ & _ & _ & PC & _).
  destruct (PC f Hin) as [_ FH].
  destruct f as [c ty b | | |]; try discriminate.
  destruct c as [ | | | | | | | | c t3 t4 | ]; try discriminate.
  destruct c as [ | | | | | | | op x t1 c2 t2 | | ]; try discriminate.
  destruct op; try discriminate. destruct c2 as [w | | | | | | | | |]; try discriminate.
  destruct b; try discriminate.
  cbn [is_v20] in Hf'. repeat rewrite andb_true_iff in Hf'.
  destruct Hf' as ((((((Hx & T1) & T2) & Hc) & T3) & T4) & Ty).
  apply sveqb_eq in Hx. apply is_tf_eq in T1. apply is_tf_eq in T2. apply is_f_eq in Hc. subst.
  repeat match goal with
         | Hq : (if type_eq ?x ?y then true else false) = true |- _ =>
             destruct (type_eq x y) as [-> |]; [clear Hq | discriminate Hq]
         end.
  destruct FH as (w & Dw & Bw).
  cbn [den] in Dw. rewrite HVe in Dw.
  destruct (Float32.cmp Cgt v c20) eqn:C; [reflexivity | exfalso].
  cbn in Dw. unfold Float32.cmp, cmp_of_comparison in C.
  destruct (Float32.compare v c20) as [[]|]; cbn in Dw, C; try discriminate C;
    injection Dw as <-; cbn in Bw; discriminate Bw.
Qed.

Lemma vel_div_den : forall a, vel_div (IC rM oV Mfloat32) (g_pc g) a = true ->
  den ge m0 E a = Some (Vsingle (Float32.div v f4)) /\ Float32.cmp Cgt v c20 = true.
Proof.
  intros a H. unfold vel_div in H. apply andb_true_iff in H as [Q V].
  apply sveqb_eq in Q. subst a. split; [exact (qv_den ge m0 E _ v HV) |].
  pose proof (v20_fact _ HV) as Hgen.
  unfold v20 in V. destruct (IC rM oV Mfloat32) as [w | | | | | | | | |] eqn:EV; try exact (Hgen V).
  destruct w; try exact (Hgen V).
  cbn [den] in HV. injection HV as ->. exact V.
Qed.

(* the no-clamp fact on the entry vel term *)
Lemma gfact_sound : forall gk ev, den ge m0 E ev = Some (Vsingle v) ->
  existsb (is_gfact gk ev) (g_pc g) = true -> Float32.cmp Clt (Float32.sub v gk) fm75 = false.
Proof.
  intros gk ev HVe GF.
  apply existsb_exists in GF as (f & Hin & Hf).
  destruct MM as (_ & _ & _ & _ & _ & _ & PC & _).
  destruct (PC f Hin) as [_ FH].
  destruct f as [c ty b | | |]; try discriminate.
  destruct c as [ | | | | | | | op x t3 c2 t4 | | ]; try discriminate.
  destruct op; try discriminate. destruct c2 as [w | | | | | | | | |]; try discriminate.
  destruct b; try discriminate.
  cbn [is_gfact] in Hf. repeat rewrite andb_true_iff in Hf.
  destruct Hf as (((Hx & H3) & H4) & Hc2).
  apply sveqb_eq in Hx. apply is_tf_eq in H3. apply is_tf_eq in H4. apply is_f_eq in Hc2. subst.
  destruct FH as (w & Dw & Bw).
  cbn [den] in Dw. rewrite (gv_den ge m0 E gk ev v HVe) in Dw.
  cbn in Dw. injection Dw as <-.
  unfold Float32.cmp, cmp_of_comparison.
  destruct (Float32.compare (Float32.sub v gk) fm75) as [[]|]; try reflexivity.
  exfalso. revert Bw. unfold bool_val. destruct (classify_bool ty); cbn;
    try rewrite (Int.eq_false _ _ Int.one_not_zero); cbn; congruence.
Qed.

Lemma nclamp_sound : forall gk, nclamp gk (IC rM oV Mfloat32) (g_pc g) = true ->
  Float32.cmp Clt (Float32.sub v gk) fm75 = false.
Proof.
  intros gk N. pose proof (gfact_sound gk _ HV) as Hgen.
  unfold nclamp in N. destruct (IC rM oV Mfloat32) as [w | | | | | | | | |] eqn:EV; try exact (Hgen N).
  destruct w; try exact (Hgen N).
  cbn [den] in HV. injection HV as ->. apply negb_true_iff in N. exact N.
Qed.

Lemma vel_ok_den : forall gk a, vel_ok gk (IC rM oV Mfloat32) (g_pc g) a = true ->
  (den ge m0 E a = Some (Vsingle (Float32.sub v gk))
   /\ Float32.cmp Clt (Float32.sub v gk) fm75 = false)
  \/ den ge m0 E a = Some (Vsingle fm75)
  \/ (den ge m0 E a = Some (Vsingle (Float32.div v f4)) /\ Float32.cmp Cgt v c20 = true).
Proof.
  intros gk a H. unfold vel_ok in H.
  apply orb_true_iff in H as [H | H]; [apply orb_true_iff in H as [H | H] |].
  - right; left. destruct a; try discriminate. cbn [is_fm75] in H. apply is_f_eq in H. subst. reflexivity.
  - left. apply andb_true_iff in H as [Q N]. apply sveqb_eq in Q. subst a.
    split; [exact (gv_den ge m0 E _ _ v HV) | exact (nclamp_sound gk N)].
  - right; right. exact (vel_div_den a H).
Qed.

Lemma vel_cut_den : forall gk a, vel_cut gk a = true -> den ge m0 E a = Some (Vsingle (cutv gk)).
Proof.
  intros gk a H. destruct a; try discriminate. cbn [vel_cut] in H. apply is_f_eq in H.
  cbn [den]. rewrite H. reflexivity.
Qed.

(* the cut's vel[1] >= 0.0f fact on the entry vel term *)
Lemma vge0_sound : forall f, In f (g_pc g) -> vge0 IC rM f = true ->
  Float32.cmp Cge v Float32.zero = true.
Proof.
  intros f If Hf.
  pose proof MM as (_ & _ & _ & _ & _ & _ & PC & _). destruct (PC f If) as [_ FH].
  destruct f as [c ty b | | |]; try discriminate.
  destruct c as [ | | | | | | | op a1 t1 a2 t2 | | ]; try discriminate.
  destruct op; try discriminate.
  destruct a2 as [w | | | | | | | | |]; try discriminate. destruct b; try discriminate.
  cbn [vge0] in Hf. repeat rewrite andb_true_iff in Hf.
  destruct Hf as (((Hx & H1) & H2) & Hc).
  apply sveqb_eq in Hx. apply is_tf_eq in H1. apply is_tf_eq in H2. apply is_f_eq in Hc. subst.
  cbn [fact_holds] in FH. destruct FH as (w & Dw & Bw).
  cbn [den] in Dw. rewrite HV in Dw.
  cbn in Dw. injection Dw as <-.
  unfold Float32.cmp, cmp_of_comparison in *.
  destruct (Float32.compare v Float32.zero) as [[| |]|]; try reflexivity.
  all: exfalso; revert Bw; unfold bool_val; destruct (classify_bool ty); cbn;
    try rewrite Int.eq_true; cbn; congruence.
Qed.

Lemma vge0c_sound : vge0c IC (g_pc g) rM = true -> Float32.cmp Cge v Float32.zero = true.
Proof.
  intros N. unfold vge0c in N.
  assert (Hgen : existsb (vge0 IC rM) (g_pc g) = true -> Float32.cmp Cge v Float32.zero = true)
    by (intros X; apply existsb_exists in X as (f & If & Hf); exact (vge0_sound f If Hf)).
  destruct (IC rM oV Mfloat32) as [w | | | | | | | | |] eqn:EV; try exact (Hgen N).
  destruct w; try exact (Hgen N).
  cbn [den] in HV. injection HV as ->. exact N.
Qed.

(* the clamp fact on the entry vel term *)
Lemma cfact_sound : forall gk ev, den ge m0 E ev = Some (Vsingle v) ->
  existsb (is_cfact gk ev) (g_pc g) = true -> Float32.cmp Clt (Float32.sub v gk) fm75 = true.
Proof.
  intros gk ev HVe GF.
  apply existsb_exists in GF as (f & Hin & Hf).
  destruct MM as (_ & _ & _ & _ & _ & _ & PC & _).
  destruct (PC f Hin) as [_ FH].
  destruct f as [c ty b | | |]; try discriminate.
  destruct c as [ | | | | | | | op x t3 c2 t4 | | ]; try discriminate.
  destruct op; try discriminate. destruct c2 as [w | | | | | | | | |]; try discriminate.
  destruct b; try discriminate.
  cbn [is_cfact] in Hf. repeat rewrite andb_true_iff in Hf.
  destruct Hf as (((Hx & H3) & H4) & Hc2).
  apply sveqb_eq in Hx. apply is_tf_eq in H3. apply is_tf_eq in H4. apply is_f_eq in Hc2. subst.
  destruct FH as (w & Dw & Bw).
  cbn [den] in Dw. rewrite (gv_den ge m0 E gk ev v HVe) in Dw.
  cbn in Dw. injection Dw as <-.
  unfold Float32.cmp, cmp_of_comparison.
  destruct (Float32.compare (Float32.sub v gk) fm75) as [[]|]; try reflexivity.
  all: exfalso; revert Bw; unfold bool_val; destruct (classify_bool ty); cbn;
    try rewrite Int.eq_true; cbn; congruence.
Qed.

Lemma clampc_sound : forall gk, clampc gk (IC rM oV Mfloat32) (g_pc g) = true ->
  Float32.cmp Clt (Float32.sub v gk) fm75 = true.
Proof.
  intros gk N. pose proof (cfact_sound gk _ HV) as Hgen.
  unfold clampc in N. destruct (IC rM oV Mfloat32) as [w | | | | | | | | |] eqn:EV; try exact (Hgen N).
  destruct w; try exact (Hgen N).
  cbn [den] in HV. injection HV as ->. exact N.
Qed.

Lemma vel_ex_den : forall gk a, vel_ex gk (IC rM oV Mfloat32) (g_pc g) a = true ->
  den ge m0 E a = Some (Vsingle (gravity gk v)).
Proof.
  intros gk a H. unfold vel_ex in H. unfold gravity.
  apply orb_true_iff in H as [H | H]; apply andb_true_iff in H as [Q N].
  - rewrite (clampc_sound gk N).
    destruct a; try discriminate. cbn [is_fm75] in Q. apply is_f_eq in Q. subst. reflexivity.
  - rewrite (nclamp_sound gk N). apply sveqb_eq in Q. subst a. exact (gv_den ge m0 E _ _ v HV).
Qed.

(* a four-quarter outcome whose vel passes vel_exc ends with gravity's vel *)
Theorem aclass_air_ex : aclass_of LD IC (g_pc g) rM rO kH = Some Cair ->
  vel_exc LD IC (g_pc g) rM = true ->
  Mem.load Mfloat32 m (e_blk E rM) oV = Some (Vsingle (gravity GK v)).
Proof.
  intros H X. unfold aclass_of in H.
  destruct (same_cell LD IC rM oA Mint32 && same_cell LD IC rM oS Mint16unsigned
            && same_cell LD IC rM oT Mint16unsigned); [| discriminate].
  destruct (LD rM oY Mfloat32) as [py|]; [| discriminate].
  destruct (LD rM oV Mfloat32) as [vy|] eqn:LV; [| discriminate].
  destruct (LD rO oG Mfloat32) as [gy|]; [| discriminate].
  destruct (sveqb gy py); [| discriminate].
  destruct (qrec (IC rM oY Mfloat32) (IC rM oV Mfloat32) py) as [[k j]|]; [| discriminate].
  destruct (vel_cut GK vy) eqn:VC;
    [match type of H with (if ?b then _ else _) = _ => destruct b; discriminate end |].
  unfold vel_exc in X. rewrite LV, VC in X. cbn [orb] in X.
  pose proof (ld_sound _ _ _ _ LV) as DV. rewrite addr_M in DV.
  rewrite DV. exact (vel_ex_den _ _ X).
Qed.

Theorem aclass_air : aclass_of LD IC (g_pc g) rM rO kH = Some Cair ->
  F32 v = true -> Rabs (R2 v) <= 128 ->
  keeps_asT
  /\ Mem.load Mfloat32 m (e_blk E rM) oY = Some (Vsingle (air_step_y y v))
  /\ Mem.load Mfloat32 m (e_blk E rO) (addr E rO oG) = Some (Vsingle (air_step_y y v))
  /\ exists v', Mem.load Mfloat32 m (e_blk E rM) oV = Some (Vsingle v')
                /\ F32 v' = true /\ R2 fm75 <= R2 v' <= R2 (gravity GK v).
Proof.
  intros H Fv Hv. unfold aclass_of in H.
  destruct (same_cell LD IC rM oA Mint32) eqn:SA; [| discriminate].
  destruct (same_cell LD IC rM oS Mint16unsigned) eqn:SS; [| discriminate].
  destruct (same_cell LD IC rM oT Mint16unsigned) eqn:ST; [| discriminate].
  cbn [andb] in H.
  destruct (LD rM oY Mfloat32) as [py|] eqn:LY; [| discriminate].
  destruct (LD rM oV Mfloat32) as [vy|] eqn:LV; [| discriminate].
  destruct (LD rO oG Mfloat32) as [gy|] eqn:LG; [| discriminate].
  destruct (sveqb gy py) eqn:GE; [| discriminate].
  unfold sveqb in GE. destruct (sval_eq gy py) as [->|]; [| discriminate].
  destruct (qrec (IC rM oY Mfloat32) (IC rM oV Mfloat32) py) as [[k j]|] eqn:Q; [| discriminate].
  destruct (vel_cut GK vy); [match type of H with (if ?b then _ else _) = _ => destruct b; discriminate end |].
  destruct (vel_ok GK (IC rM oV Mfloat32) (g_pc g) vy) eqn:VG; [| discriminate].
  destruct k as [|[|[|[|[|k]]]]]; try discriminate. destruct j; [| discriminate].
  match type of H with (if ?b then _ else _) = _ => destruct b; [| discriminate] end.
  pose proof (qrec_den ge m0 E _ _ y v HY HV py 4 0 Q) as QD.
  cbn [add_zeros] in QD. rewrite <- air_step_y_quarter_steps in QD.
  pose proof (ld_sound _ _ _ _ LY) as DY. pose proof (ld_sound _ _ _ _ LV) as DV.
  pose proof (ld_sound _ _ _ _ LG) as DG.
  rewrite addr_M in DY, DV. rewrite QD in DY, DG.
  split; [exact (same3 SA SS ST) |].
  split; [exact DY | split; [exact DG |]].
  pose proof (F32_gk (IC rM oA Mint32)) as FG. pose proof (R2_gk (IC rM oA Mint32)) as RG.
  destruct (vel_ok_den _ _ VG) as [(D & C) | [D | (D & C)]]; rewrite D in DV.
  - destruct (sub_ge_m75 _ FG RG v Fv Hv C) as [L F].
    eexists; split; [exact DV | split; [exact F | split; [exact L | apply vel_sub_le; assumption]]].
  - eexists; split; [exact DV | split; [exact F32_fm75 | split; [lra | apply vel_clamp_le; assumption]]].
  - destruct (vel_div_ok _ FG RG v Fv Hv C) as (F & L & U).
    eexists; split; [exact DV | split; [exact F | split; [exact L | exact U]]].
Qed.

Theorem aclass_cut : forall k, aclass_of LD IC (g_pc g) rM rO kH = Some (Ccut k) ->
  keeps_asT /\ (k <= 4)%nat
  /\ (is_skt (IC rM oA Mint32) = true -> Float32.cmp Cge v Float32.zero = true)
  /\ exists p, R2 p = R2 (quarter_steps k y (Float32.div v f4))
     /\ Mem.load Mfloat32 m (e_blk E rM) oY = Some (Vsingle p)
     /\ Mem.load Mfloat32 m (e_blk E rO) (addr E rO oG) = Some (Vsingle p)
     /\ Mem.load Mfloat32 m (e_blk E rM) oV = Some (Vsingle (cutv GK))
     /\ exists j, p = add_zeros j (quarter_steps k y (Float32.div v f4)).
Proof.
  intros k0 H. unfold aclass_of in H.
  destruct (same_cell LD IC rM oA Mint32) eqn:SA; [| discriminate].
  destruct (same_cell LD IC rM oS Mint16unsigned) eqn:SS; [| discriminate].
  destruct (same_cell LD IC rM oT Mint16unsigned) eqn:ST; [| discriminate].
  cbn [andb] in H.
  destruct (LD rM oY Mfloat32) as [py|] eqn:LY; [| discriminate].
  destruct (LD rM oV Mfloat32) as [vy|] eqn:LV; [| discriminate].
  destruct (LD rO oG Mfloat32) as [gy|] eqn:LG; [| discriminate].
  destruct (sveqb gy py) eqn:GE; [| discriminate].
  unfold sveqb in GE. destruct (sval_eq gy py) as [->|]; [| discriminate].
  destruct (qrec (IC rM oY Mfloat32) (IC rM oV Mfloat32) py) as [[k j]|] eqn:Q; [| discriminate].
  destruct (vel_cut GK vy) eqn:VC.
  2:{ destruct (vel_ok GK (IC rM oV Mfloat32) (g_pc g) vy); [| discriminate].
      destruct k as [|[|[|[|[|k]]]]]; try discriminate; destruct j; try discriminate;
      match type of H with (if ?b then _ else _) = _ => destruct b; discriminate end. }
  destruct (Nat.leb k 4) eqn:K4; [| discriminate]. cbn [andb] in H.
  destruct (negb (is_skt (IC rM oA Mint32)) || vge0c IC (g_pc g) rM) eqn:SK0; [| discriminate].
  cbn [andb] in H.
  match type of H with (if ?b then _ else _) = _ => destruct b; [| discriminate] end.
  injection H as <-.
  apply Nat.leb_le in K4.
  assert (Hge : is_skt (IC rM oA Mint32) = true -> Float32.cmp Cge v Float32.zero = true).
  { intros S1. rewrite S1 in SK0. exact (vge0c_sound SK0). }
  pose proof (qrec_den ge m0 E _ _ y v HY HV py k j Q) as QD.
  pose proof (ld_sound _ _ _ _ LY) as DY. pose proof (ld_sound _ _ _ _ LV) as DV.
  pose proof (ld_sound _ _ _ _ LG) as DG.
  rewrite addr_M in DY, DV. rewrite QD in DY, DG.
  rewrite (vel_cut_den _ _ VC) in DV.
  split; [exact (same3 SA SS ST) |]. split; [exact K4 |]. split; [exact Hge |].
  eexists; split; [apply add_zeros_R2 | split; [exact DY | split; [exact DG | split; [exact DV | eexists; reflexivity]]]].
Qed.
Lemma ole_den : forall vp x w,
  sem_binary_operation ge Cop.Ole vp tf (Vsingle x) tf m0 = Some w ->
  exists p, vp = Vsingle p /\ w = Val.of_bool (Float32.cmp Cle p x).
Proof.
  intros vp x w H. destruct vp; cbn in H; try discriminate.
  injection H as <-. eexists; split; reflexivity.
Qed.

(* a height fact's height: a find_floor hit *)
Lemma hfact_hit : forall n f, In f (g_pc g) -> hfact IC rM kH n f = true ->
  exists h, den ge m0 E (Sfresh n) = Some (Vsingle h) /\ Hit_at ge m0 h.
Proof.
  intros n f If Hf.
  destruct f as [| | | k args]; cbn [hfact] in Hf; try discriminate.
  destruct args as [| a0 [| ya [|]]]; cbn [hfact] in Hf; try discriminate;
    destruct a0; cbn [hfact] in Hf; try discriminate.
  repeat rewrite andb_true_iff in Hf. destruct Hf as ((Hk & Hn) & _).
  apply Pos.eqb_eq in Hk. apply Pos.eqb_eq in Hn. subst.
  pose proof MM as (_ & _ & _ & _ & _ & _ & PC & _).
  destruct (PC _ If) as (_ & FH). cbn [fact_holds map] in FH.
  destruct (HUH _ FH) as (h & yv & Evs & _ & HT). injection Evs as E1 _.
  exists h. split; [exact E1 | exact HT].
Qed.

(* the non-landing fact: pos[1] ended NOT <= the floor height it was
   compared with, the entry floorHeight term or a find_floor hit *)
Lemma above_sound : forall py, LD rM oY Mfloat32 = Some py ->
  above LD IC (g_pc g) rM kH py = true ->
  exists p x, Mem.load Mfloat32 m (e_blk E rM) oY = Some (Vsingle p)
    /\ Float32.cmp Cle p x = false
    /\ (den ge m0 E (IC rM oF Mfloat32) = Some (Vsingle x) \/ Hit_at ge m0 x)
    /\ Mem.load Mfloat32 m (e_blk E rM) oF = Some (Vsingle x).
Proof.
  intros py LY AB. unfold above in AB.
  destruct (LD rM oF Mfloat32) as [pf|] eqn:LFx; [| discriminate].
  apply existsb_exists in AB as (f & If & Hf).
  pose proof MM as (_ & _ & _ & _ & _ & _ & PC & _).
  destruct (PC f If) as [_ FH].
  destruct f as [c ty b | | |]; try discriminate.
  destruct c as [ | | | | | | | op a t1 x t2 | | ]; try discriminate.
  destruct op; try discriminate. destruct b; try discriminate.
  cbn [is_above] in Hf. repeat rewrite andb_true_iff in Hf.
  destruct Hf as ((((Ha & Hx') & H1) & H2) & HL).
  unfold sveqb in Ha. destruct (sval_eq a py) as [->|]; [| discriminate].
  apply sveqb_eq in Hx'. subst pf.
  pose proof (ld_sound _ _ _ _ LFx) as DF. rewrite addr_M in DF.
  apply is_tf_eq in H1. apply is_tf_eq in H2. subst t1 t2.
  cbn [fact_holds] in FH. destruct FH as (w & Dw & Bw).
  pose proof (ld_sound _ _ _ _ LY) as DY. rewrite addr_M in DY.
  assert (DX : exists xv, den ge m0 E x = Some (Vsingle xv)
             /\ (den ge m0 E (IC rM oF Mfloat32) = Some (Vsingle xv) \/ Hit_at ge m0 xv)).
  { unfold is_land in HL. apply orb_true_iff in HL as [HL | HL].
    - apply sveqb_eq in HL. subst x.
      cbn [den] in Dw.
      destruct (den ge m0 E (IC rM oF Mfloat32)) as [xv|] eqn:DXv;
        [| destruct (den ge m0 E py); discriminate].
      destruct xv as [| | | | f |];
        try (destruct (den ge m0 E py) as [vp|]; [| discriminate]; destruct vp; cbn in Dw; discriminate).
      exists f. split; [reflexivity | left; reflexivity].
    - destruct x; try discriminate.
      apply existsb_exists in HL as (f & If' & Hf').
      destruct (hfact_hit _ _ If' Hf') as (h & E1 & HT).
      exists h. split; [exact E1 | right; exact HT]. }
  destruct DX as (xv & Dx & Hx).
  cbn [den] in Dw. rewrite Dx, <- DY in Dw.
  destruct (Mem.load Mfloat32 m (e_blk E rM) oY) as [vp|]; [| discriminate].
  cbn in Dw. destruct (ole_den vp xv w Dw) as (p & -> & ->).
  exists p, xv. split; [reflexivity | split; [| split; [exact Hx | rewrite DF; exact Dx]]].
  destruct (Float32.cmp Cle p xv); [| reflexivity].
  exfalso. revert Bw. unfold bool_val. destruct (classify_bool ty); cbn;
    try rewrite (Int.eq_false _ _ Int.one_not_zero); cbn; congruence.
Qed.

Theorem aclass_above : forall c, aclass_of LD IC (g_pc g) rM rO kH = Some c ->
  (c = Ccut 0 /\ Mem.load Mfloat32 m (e_blk E rM) oF = den ge m0 E (IC rM oF Mfloat32)) \/
  exists p x, Mem.load Mfloat32 m (e_blk E rM) oY = Some (Vsingle p)
    /\ Float32.cmp Cle p x = false
    /\ (den ge m0 E (IC rM oF Mfloat32) = Some (Vsingle x) \/ Hit_at ge m0 x)
    /\ Mem.load Mfloat32 m (e_blk E rM) oF = Some (Vsingle x).
Proof.
  intros c H. unfold aclass_of in H.
  destruct (same_cell LD IC rM oA Mint32 && same_cell LD IC rM oS Mint16unsigned
            && same_cell LD IC rM oT Mint16unsigned); [| discriminate].
  destruct (LD rM oY Mfloat32) as [py|] eqn:LY; [| discriminate].
  destruct (LD rM oV Mfloat32) as [vy|]; [| discriminate].
  destruct (LD rO oG Mfloat32) as [gy|]; [| discriminate].
  destruct (sveqb gy py); [| discriminate].
  destruct (qrec (IC rM oY Mfloat32) (IC rM oV Mfloat32) py) as [[k j]|]; [| discriminate].
  destruct (vel_cut (gk_of (IC rM oA Mint32)) vy).
  - destruct (Nat.leb k 4); [| discriminate]. cbn [andb] in H.
    destruct (negb (is_skt (IC rM oA Mint32)) || vge0c IC (g_pc g) rM); [| discriminate].
    cbn [andb] in H.
    destruct (above LD IC (g_pc g) rM kH py) eqn:AB; [right; exact (above_sound py LY AB) |].
    rewrite orb_false_r in H.
    destruct (Nat.eqb k 0 && same_cell LD IC rM oF Mfloat32) eqn:K0; [| discriminate].
    apply andb_true_iff in K0 as (K0 & EF). apply Nat.eqb_eq in K0. subst.
    injection H as <-. left. split; [reflexivity | exact (same_cell_den oF Mfloat32 EF)].
  - destruct (vel_ok (gk_of (IC rM oA Mint32)) (IC rM oV Mfloat32) (g_pc g) vy); [| discriminate].
    destruct k as [|[|[|[|[|k]]]]]; try discriminate; destruct j; try discriminate.
    destruct (above LD IC (g_pc g) rM kH py) eqn:AB; [| discriminate].
    right. exact (above_sound py LY AB).
Qed.

Lemma cells_sound : cells_ok LD IC (g_pc g) rM rO kH = true ->
  Mem.load Mint32 m (e_blk E rM) oMO = Some (Vptr (e_blk E rO) (e_base E rO))
  /\ (Mem.load Mfloat32 m (e_blk E rM) oF = den ge m0 E (IC rM oF Mfloat32)
      \/ exists x, Mem.load Mfloat32 m (e_blk E rM) oF = Some (Vsingle x) /\ Hit_at ge m0 x).
Proof.
  intros H. unfold cells_ok in H. apply andb_true_iff in H as (H1 & H2).
  split.
  - destruct (LD rM oMO Mint32) as [a|] eqn:L; [| discriminate].
    destruct a as [| r0 i | | | | | | | |]; try discriminate. apply andb_true_iff in H1 as (Hr & Ho).
    apply Pos.eqb_eq in Hr. subst. pose proof (Ptrofs.eq_spec i Ptrofs.zero) as Ei. rewrite Ho in Ei. subst.
    pose proof (ld_sound _ _ _ _ L) as D. rewrite addr_M in D. rewrite D. cbn [den].
    rewrite Ptrofs.add_zero. reflexivity.
  - destruct (LD rM oF Mfloat32) as [a|] eqn:L; [| discriminate].
    pose proof (ld_sound _ _ _ _ L) as D. rewrite addr_M in D. rewrite D.
    apply orb_true_iff in H2 as [H2 | H2].
    2:{ destruct a; try discriminate. cbn [is_hf] in H2. apply existsb_exists in H2 as (f & If & Hf).
        destruct f as [| | | k args]; try discriminate.
        destruct args as [| a0 [| ya [|]]]; try discriminate; destruct a0; try discriminate.
        apply andb_true_iff in Hf as (Hk & Hn). apply Pos.eqb_eq in Hk. apply Pos.eqb_eq in Hn. subst.
        pose proof MM as (_ & _ & _ & _ & _ & _ & PC & _).
        destruct (PC _ If) as (_ & FH). cbn [fact_holds map] in FH.
        destruct (HUH _ FH) as (h & yv & Evs & _ & HT). injection Evs as E1 _.
        right. exists h. split; [exact E1 | exact HT]. }
    unfold is_land in H2. apply orb_true_iff in H2 as [H2 | H2].
    + apply sveqb_eq in H2. subst a. left. reflexivity.
    + destruct a; try discriminate.
      apply existsb_exists in H2 as (f & If & Hf).
      destruct (hfact_hit _ _ If Hf) as (h & E1 & HT).
      right. exists h. split; [exact E1 | exact HT].
Qed.

Theorem land_sound : land_ok LD IC (g_pc g) rM rO kH = true ->
  F32 v = true -> Rabs (R2 v) <= 128 ->
  keeps_asT
  /\ Mem.load Mfloat32 m (e_blk E rO) (addr E rO oG) = Mem.load Mfloat32 m (e_blk E rM) oY
  /\ (Mem.load Mfloat32 m (e_blk E rM) oY = den ge m0 E (IC rM oF Mfloat32)
      \/ exists h kq jz, Mem.load Mfloat32 m (e_blk E rM) oY = Some (Vsingle h) /\ (kq <= 4)%nat
           /\ HPi (Hit_at ge m0) (ycast (Vsingle (add_zeros jz (quarter_steps kq y (Float32.div v f4))))) h
           /\ Hit_at ge m0 h)
  /\ exists v', Mem.load Mfloat32 m (e_blk E rM) oV = Some (Vsingle v')
       /\ F32 v' = true /\ R2 fm75 <= R2 v' /\ (R2 v' <= R2 (gravity GK v) \/ v' = cutv GK).
Proof.
  intros H Fv Hv. unfold land_ok in H.
  destruct (same_cell LD IC rM oA Mint32) eqn:SA; [| discriminate].
  destruct (same_cell LD IC rM oS Mint16unsigned) eqn:SS; [| discriminate].
  destruct (same_cell LD IC rM oT Mint16unsigned) eqn:ST; [| discriminate].
  cbn [andb] in H.
  destruct (LD rM oY Mfloat32) as [py|] eqn:LY; [| discriminate].
  destruct (LD rM oV Mfloat32) as [vy|] eqn:LV; [| discriminate].
  destruct (LD rO oG Mfloat32) as [gy|] eqn:LG; [| discriminate].
  repeat rewrite andb_true_iff in H. destruct H as ((GE & L) & VO).
  unfold sveqb in GE. destruct (sval_eq gy py) as [->|]; [| discriminate].
  pose proof (ld_sound _ _ _ _ LY) as DY. pose proof (ld_sound _ _ _ _ LV) as DV.
  pose proof (ld_sound _ _ _ _ LG) as DG.
  rewrite addr_M in DY, DV.
  split; [exact (same3 SA SS ST) |].
  split; [congruence |]. split.
  - rewrite DY. unfold is_land in L. apply orb_true_iff in L as [L | L].
    + apply sveqb_eq in L. rewrite L. left. reflexivity.
    + destruct py; try discriminate.
      apply existsb_exists in L as (f & If & Hf).
      destruct f as [| | | k args]; cbn [hfact] in Hf; try discriminate.
      destruct args as [| a0 [| ya [|]]]; cbn [hfact] in Hf; try discriminate;
        destruct a0; cbn [hfact] in Hf; try discriminate.
      repeat rewrite andb_true_iff in Hf. destruct Hf as ((Hk & Hn) & Hq).
      apply Pos.eqb_eq in Hk. apply Pos.eqb_eq in Hn. subst.
      destruct (qrec (IC rM oY Mfloat32) (IC rM oV Mfloat32) ya) as [[kq jz]|] eqn:Q; [| discriminate].
      apply Nat.leb_le in Hq.
      pose proof MM as (_ & _ & _ & _ & _ & _ & PC & _).
      destruct (PC _ If) as (_ & FH). cbn [fact_holds map] in FH.
      rewrite (qrec_den ge m0 E _ _ y v HY HV ya kq jz Q) in FH.
      destruct (HUH _ FH) as (h & yv & Evs & HP & HT). cbn [den] in Evs.
      injection Evs as E1 E2. subst yv.
      right. exists h, kq, jz. split; [cbn [den]; exact E1 | split; [exact Hq | split; [exact HP | exact HT]]].
  - pose proof (F32_gk (IC rM oA Mint32)) as FG. pose proof (R2_gk (IC rM oA Mint32)) as RG.
    apply orb_true_iff in VO as [VC | VK].
    + rewrite (vel_cut_den _ _ VC) in DV. eexists; split; [exact DV |].
      split; [apply F32_cutv |]. split; [| right; reflexivity].
      rewrite B2R_fm75, R2_cutv. destruct RG as [RG | RG]; rewrite RG; lra.
    + destruct (vel_ok_den _ _ VK) as [(D & C) | [D | (D & C)]]; rewrite D in DV.
      * destruct (sub_ge_m75 _ FG RG v Fv Hv C) as [L75 F].
        eexists; split; [exact DV | split; [exact F | split; [exact L75 | left; apply vel_sub_le; assumption]]].
      * eexists; split; [exact DV | split; [exact F32_fm75 | split; [lra | left; apply vel_clamp_le; assumption]]].
      * destruct (vel_div_ok _ FG RG v Fv Hv C) as (F & L75 & U).
        eexists; split; [exact DV | split; [exact F | split; [exact L75 | left; exact U]]].
Qed.

Lemma vle0_sound : forall f, In f (g_pc g) -> vle0 IC rM f = true ->
  Float32.cmp Cgt v (Float32.of_int Int.zero) = false.
Proof.
  intros f If Hf.
  pose proof MM as (_ & _ & _ & _ & _ & _ & PC & _). destruct (PC f If) as [_ FH].
  destruct f as [c ty b | | |]; try discriminate.
  destruct c as [ | | | | | | | op a1 t1 a2 t2 | | ]; try discriminate.
  destruct op; try discriminate.
  destruct a2 as [w | | | | | | | | |]; try discriminate. destruct w; try discriminate. destruct b; try discriminate.
  cbn [vle0] in Hf. repeat rewrite andb_true_iff in Hf.
  destruct Hf as (((Hx & H1) & H2) & Hi).
  apply sveqb_eq in Hx. apply is_tf_eq in H1. subst.
  destruct (type_eq t2 ti32); [| discriminate]. pose proof (Int.eq_spec i Int.zero) as Ei.
  rewrite Hi in Ei. subst.
  cbn [fact_holds] in FH. destruct FH as (w & Dw & Bw).
  cbn [den] in Dw. rewrite HV in Dw.
  cbn in Dw. injection Dw as <-.
  unfold Float32.cmp, cmp_of_comparison.
  destruct (Float32.compare v (Float32.of_int Int.zero)) as [[| |]|]; try reflexivity.
  exfalso. revert Bw. unfold bool_val. destruct (classify_bool ty); cbn;
    try rewrite (Int.eq_false _ _ Int.one_not_zero); cbn; congruence.
Qed.

Lemma vle0c_sound : vle0c IC (g_pc g) rM = true ->
  Float32.cmp Cgt v (Float32.of_int Int.zero) = false.
Proof.
  intros N. unfold vle0c in N.
  assert (Hgen : existsb (vle0 IC rM) (g_pc g) = true -> Float32.cmp Cgt v (Float32.of_int Int.zero) = false)
    by (intros X; apply existsb_exists in X as (f & If & Hf); exact (vle0_sound f If Hf)).
  destruct (IC rM oV Mfloat32) as [w | | | | | | | | |] eqn:EV; try exact (Hgen N).
  destruct w; try exact (Hgen N).
  cbn [den] in HV. injection HV as ->. apply negb_true_iff in N. exact N.
Qed.

Theorem ledge_sound : ledge_ok LD IC (g_pc g) rM rO kH = true ->
  F32 v = true -> Rabs (R2 v) <= 128 ->
  keeps_asT
  /\ Mem.load Mfloat32 m (e_blk E rO) (addr E rO oG) = Mem.load Mfloat32 m (e_blk E rM) oY
  /\ (exists h kq jz, Mem.load Mfloat32 m (e_blk E rM) oY = Some (Vsingle h) /\ (kq <= 4)%nat
       /\ (Float32.cmp Cgt v (Float32.of_int Int.zero) = false \/ (kq <= 2)%nat)
       /\ HPi (Hit_at ge m0)
             (ycast (Vsingle (Float32.add (add_zeros jz (quarter_steps kq y (Float32.div v f4))) c160))) h
       /\ Hit_at ge m0 h)
  /\ exists v', Mem.load Mfloat32 m (e_blk E rM) oV = Some (Vsingle v')
       /\ F32 v' = true /\ R2 fm75 <= R2 v' /\ (R2 v' <= R2 (gravity GK v) \/ v' = cutv GK).
Proof.
  intros H Fv Hv. unfold ledge_ok in H.
  destruct (same_cell LD IC rM oA Mint32) eqn:SA; [| discriminate].
  destruct (same_cell LD IC rM oS Mint16unsigned) eqn:SS; [| discriminate].
  destruct (same_cell LD IC rM oT Mint16unsigned) eqn:ST; [| discriminate].
  cbn [andb] in H.
  destruct (LD rM oY Mfloat32) as [py|] eqn:LY; [| discriminate].
  destruct (LD rM oV Mfloat32) as [vy|] eqn:LV; [| discriminate].
  destruct (LD rO oG Mfloat32) as [gy|] eqn:LG; [| discriminate].
  repeat rewrite andb_true_iff in H. destruct H as ((GE & L) & VO).
  unfold sveqb in GE. destruct (sval_eq gy py) as [->|]; [| discriminate].
  pose proof (ld_sound _ _ _ _ LY) as DY. pose proof (ld_sound _ _ _ _ LV) as DV.
  pose proof (ld_sound _ _ _ _ LG) as DG.
  rewrite addr_M in DY, DV.
  split; [exact (same3 SA SS ST) |].
  split; [congruence |]. split.
  - rewrite DY. destruct py; try discriminate.
    apply existsb_exists in L as (f & If & Hf).
    destruct f as [| | | k args]; cbn [lfact] in Hf; try discriminate.
    destruct args as [| a0 [| ya [|]]]; try discriminate; destruct a0; try discriminate;
      destruct ya as [ | | | | | | | op q t1 c t2 | | ]; try discriminate;
      destruct op; try discriminate; destruct c; try discriminate.
    cbn [lfact] in Hf. repeat rewrite andb_true_iff in Hf.
    destruct Hf as (((((Hk & Hn) & H1) & H2) & Hc) & Hq).
    apply Pos.eqb_eq in Hk. apply Pos.eqb_eq in Hn. apply is_tf_eq in H1. apply is_tf_eq in H2.
    apply is_f_eq in Hc. subst.
    destruct (qrec (IC rM oY Mfloat32) (IC rM oV Mfloat32) q) as [[kq jz]|] eqn:Q; [| discriminate].
    apply Nat.leb_le in Hq.
    assert (Hk4 : (kq <= 4)%nat) by (revert Hq; destruct (vle0c IC (g_pc g) rM); lia).
    assert (Hor : Float32.cmp Cgt v (Float32.of_int Int.zero) = false \/ (kq <= 2)%nat).
    { revert Hq. destruct (vle0c IC (g_pc g) rM) eqn:VL; intros Hq; [left | right; exact Hq].
      exact (vle0c_sound VL). }
    pose proof MM as (_ & _ & _ & _ & _ & _ & PC & _).
    destruct (PC _ If) as (_ & FH). cbn [fact_holds map] in FH.
    destruct (HUH _ FH) as (h & yv & Evs & HP & HT).
    cbn [den] in Evs.
    rewrite (qrec_den ge m0 E _ _ y v HY HV q kq jz Q) in Evs.
    cbn in Evs. injection Evs as E1 E2. subst yv.
    exists h, kq, jz. split; [exact E1 | split; [exact Hk4 | split; [exact Hor | split; [exact HP | exact HT]]]].
  - pose proof (F32_gk (IC rM oA Mint32)) as FG. pose proof (R2_gk (IC rM oA Mint32)) as RG.
    apply orb_true_iff in VO as [VC | VK].
    + rewrite (vel_cut_den _ _ VC) in DV. eexists; split; [exact DV |].
      split; [apply F32_cutv |]. split; [| right; reflexivity].
      rewrite B2R_fm75, R2_cutv. destruct RG as [RG | RG]; rewrite RG; lra.
    + destruct (vel_ok_den _ _ VK) as [(D & C) | [D | (D & C)]]; rewrite D in DV.
      * destruct (sub_ge_m75 _ FG RG v Fv Hv C) as [L75 F].
        eexists; split; [exact DV | split; [exact F | split; [exact L75 | left; apply vel_sub_le; assumption]]].
      * eexists; split; [exact DV | split; [exact F32_fm75 | split; [lra | left; apply vel_clamp_le; assumption]]].
      * destruct (vel_div_ok _ FG RG v Fv Hv C) as (F & L75 & U).
        eexists; split; [exact DV | split; [exact F | split; [exact L75 | left; exact U]]].
Qed.
End CLS_SOUND.

(* ---- the landed height, as a real bound ---- *)

(* what land_sound's facts mean for a world whose hits are finite and
   moderate (FloorBound.HitB): the landed height is a hit (find_floor
   reported a floor, so not the -11000 sentinel) at most 80 above that
   quarter's yPos, hence at most y + max(v, 0) + 81 *)
Theorem land_height : forall Hit kq jz y v h, HitB Hit -> (kq <= 4)%nat ->
  F32 y = true -> F32 v = true -> Rabs (R2 v) <= 128 -> -11000 <= R2 y <= 15000 ->
  HPi Hit (ycast (Vsingle (add_zeros jz (quarter_steps kq y (Float32.div v f4))))) h -> Hit h ->
  R2 h <= R2 y + Rmax 0 (R2 v) + 81.
Proof.
  intros Hit kq jz y v h HB Hk Fy Fv Hv Hy H Hh.
  destruct (quarter_steps_up kq y v Hk Fy Fv ltac:(apply Rabs_le; lra) Hv) as (Fq & Up & Dn & _).
  destruct (quarter_spec v Fv Hv) as (Fq4 & Hqe & _).
  assert (Hqb : Rabs (R2 (Float32.div v f4)) <= 33).
  { apply Rabs_le_inv in Hv, Hqe. apply Rabs_le. lra. }
  destruct (quarter_steps_spec kq y (Float32.div v f4) Hk Fy Fq4 ltac:(apply Rabs_le; lra) Hqb)
    as (_ & (Lo & _) & _).
  assert (Hk4 : INR kq <= 4) by (replace 4 with (INR 4) by (simpl; lra); apply le_INR; exact Hk).
  pose proof (pos_INR kq) as Hk0.
  set (f := add_zeros jz (quarter_steps kq y (Float32.div v f4))) in *.
  assert (Ef : R2 f = R2 (quarter_steps kq y (Float32.div v f4))) by apply add_zeros_R2.
  assert (Ff : F32 f = true) by (apply add_zeros_F32; exact Fq).
  apply Rabs_le_inv in Hqb.
  assert (Hlo : -12000 <= R2 f) by (rewrite Ef; nra).
  assert (Hup : R2 f <= R2 y + Rmax 0 (R2 v) + / 128).
  { rewrite Ef. destruct (Rle_or_lt 0 (R2 v)) as [P | N].
    - rewrite Rmax_right by exact P. exact (Up P).
    - rewrite Rmax_left by lra. pose proof (Dn ltac:(lra)). lra. }
  assert (Hv' : Rmax 0 (R2 v) <= 128)
    by (apply Rabs_le_inv in Hv; apply Rmax_lub; lra).
  assert (HM : Rmax (R2 f) (-11000) <= R2 y + Rmax 0 (R2 v) + 1).
  { pose proof (Rmax_l 0 (R2 v)). apply Rmax_lub; lra. }
  destruct (ff_height_bound Hit f h HB Ff ltac:(pose proof (Rmax_l 0 (R2 v)); lra) H)
    as [E | (Ht & B)]; [| lra].
  subst h. rewrite B2R_c11000. pose proof (Rmax_l 0 (R2 v)). lra.
Qed.

(* ---- a landing is an attach to a WMotR floor ---- *)

(* the level data find_floor reads (TRUST 0.8(d), stated over the frame
   memory): every hit on a floor list of m0 is a finite height of a WMotR
   floor *)
Definition floor_data (ge : genv) (m0 : mem) : Prop :=
  forall h, Hit_at ge m0 h -> F32 h = true /\ Rabs (R2 h) <= 16384 /\ wmotr_floor (R2 h).

(* a landing on a fresh height meets HeightMoveCatalog.AttachOK's floor case *)
Theorem land_attach : forall ge m0 kq jz y v h, floor_data ge m0 -> (kq <= 4)%nat ->
  F32 y = true -> F32 v = true -> Rabs (R2 v) <= 128 -> -11000 <= R2 y <= 15000 -> R2 v <= 43 ->
  HPi (Hit_at ge m0) (ycast (Vsingle (add_zeros jz (quarter_steps kq y (Float32.div v f4))))) h ->
  Hit_at ge m0 h ->
  wmotr_floor (R2 h) /\ R2 h <= R2 y + STEP_UP.
Proof.
  intros ge m0 kq jz y v h FD Hk Fy Fv Hv Hy H43 HP Hh.
  assert (HB : HitB (Hit_at ge m0)) by (intros x Hx; destruct (FD x Hx) as (F & B & _); auto).
  pose proof (land_height _ kq jz y v h HB Hk Fy Fv Hv Hy HP Hh) as Le.
  split; [exact (proj2 (proj2 (FD h Hh))) |].
  assert (Rmax 0 (R2 v) <= 43) by (apply Rmax_lub; lra).
  unfold STEP_UP. lra.
Qed.

(* ---- a step that does not land ends above -11000 ---- *)

Lemma cle_false_gt : forall p x, F32 p = true -> F32 x = true ->
  Float32.cmp Cle p x = false -> R2 x < R2 p.
Proof.
  intros p x Fp Fx H. unfold Float32.cmp, Float32.compare in H.
  rewrite Binary.Bcompare_correct in H by assumption.
  destruct (Rcompare_spec (R2 p) (R2 x)) as [L | L | L]; simpl in H; try discriminate; lra.
Qed.

(* the compared height is the entry floorHeight (ranged by Phi's InRange)
   or a find_floor hit (a WMotR floor, so >= -11000: WMotRLevel) *)
Theorem above_low : forall ge m0 p x, floor_data ge m0 -> F32 p = true ->
  Float32.cmp Cle p x = false ->
  (F32 x = true /\ -11000 <= R2 x) \/ Hit_at ge m0 x ->
  -11000 < R2 p.
Proof.
  intros ge m0 p x FD Fp C [(Fx & Lx) | Hx].
  - pose proof (cle_false_gt p x Fp Fx C). lra.
  - destruct (FD x Hx) as (Fx & _ & Wx).
    pose proof (cle_false_gt p x Fp Fx C). pose proof (wmotr_floor_low _ Wx). lra.
Qed.

(* ---- a ledge grab is an attach to a WMotR floor ---- *)

Lemma B2R_c160 : R2 c160 = 160.
Proof. unfold c160. vm_compute (Float32.of_bits _). unfold Binary.B2R, F2R. simpl. lra. Qed.
Lemma F32_c160 : F32 c160 = true.  Proof. vm_compute. reflexivity. Qed.

Lemma cgt_false_le : forall v, F32 v = true -> Float32.cmp Cgt v (Float32.of_int Int.zero) = false ->
  R2 v <= 0.
Proof.
  intros v Fv H. assert (Z0 : Float32.of_int Int.zero = Float32.zero) by reflexivity. rewrite Z0 in H.
  unfold Float32.cmp, Float32.compare in H.
  rewrite Binary.Bcompare_correct in H by first [exact Fv | reflexivity].
  destruct (Rcompare_spec (R2 v) (R2 Float32.zero)) as [L | L | L]; simpl in H; try discriminate;
    replace (R2 Float32.zero) with 0 in L by reflexivity; lra.
Qed.

(* the ledge height: find_floor's height from nextPos + 160, with vel <= 0
   (nextPos <= pos) or nextPos at most two quarters up *)
Theorem ledge_height : forall Hit kq jz y v h, HitB Hit -> (kq <= 4)%nat ->
  F32 y = true -> F32 v = true -> Rabs (R2 v) <= 128 -> -11000 <= R2 y <= 15000 -> R2 v <= 43 ->
  (R2 v <= 0 \/ (kq <= 2)%nat) ->
  HPi Hit (ycast (Vsingle (Float32.add (add_zeros jz (quarter_steps kq y (Float32.div v f4))) c160))) h ->
  Hit h -> R2 h <= R2 y + Rmax 0 (R2 v) / 2 + STEP_UP.
Proof.
  intros Hit kq jz y v h HB Hk Fy Fv Hv Hy H43 Hor H Hh.
  destruct (quarter_steps_up kq y v Hk Fy Fv ltac:(apply Rabs_le; lra) Hv) as (Fq & _ & Dn & _).
  destruct (quarter_spec v Fv Hv) as (Fq4 & Hqe & _ & Hqp).
  pose proof Hv as Hv'. pose proof Hqe as Hqe'. apply Rabs_le_inv in Hv', Hqe'.
  assert (Hqb : Rabs (R2 (Float32.div v f4)) <= 33) by (apply Rabs_le; lra).
  destruct (quarter_steps_spec kq y (Float32.div v f4) Hk Fy Fq4 ltac:(apply Rabs_le; lra) Hqb)
    as (_ & (Lo & Up) & _).
  assert (Hk4 : INR kq <= 4) by (replace 4 with (INR 4) by (simpl; lra); apply le_INR; exact Hk).
  pose proof (pos_INR kq) as Hk0.
  pose proof (Rmax_l 0 (R2 v)) as M0.
  assert (M43 : Rmax 0 (R2 v) <= 43) by (apply Rmax_lub; lra).
  set (q := add_zeros jz (quarter_steps kq y (Float32.div v f4))) in *.
  assert (Eq : R2 q = R2 (quarter_steps kq y (Float32.div v f4))) by apply add_zeros_R2.
  assert (Fq' : F32 q = true) by (apply add_zeros_F32; exact Fq).
  pose proof Hqb as Hqb'. apply Rabs_le_inv in Hqb'.
  assert (Qlo : -12000 <= R2 q) by (rewrite Eq; nra).
  assert (Qhi : R2 q <= R2 y + Rmax 0 (R2 v) / 2 + 3 / 1024).
  { rewrite Eq. destruct (Rle_dec (R2 v) 0) as [Hn | Hp].
    - specialize (Dn Hn). lra.
    - rewrite Rmax_right by lra. destruct Hor as [Hn | H2]; [lra |].
      assert (K2 : INR kq <= 2) by (replace 2 with (INR 2) by (simpl; lra); apply le_INR; exact H2).
      assert (Q0 : 0 <= R2 (Float32.div v f4)) by (apply Hqp; lra).
      nra. }
  destruct (f32_add_val q c160 Fq' F32_c160) as (Av & Af).
  { rewrite B2R_c160. eapply Rle_trans; [| apply (bpow_le radix2 14 100); lia].
    simpl. apply Rabs_le. lra. }
  rewrite B2R_c160 in Av.
  pose proof (rnd_err (R2 q + 160) 14 ltac:(lia) ltac:(simpl; apply Rabs_le; lra)) as Es.
  replace (bpow radix2 (14 - 24)) with (/ 1024) in Es by (simpl; lra).
  rewrite <- Av in Es. apply Rabs_le_inv in Es.
  set (f := Float32.add q c160) in *.
  destruct (ff_height_bound Hit f h HB Af ltac:(lra) H) as [E | (Ht & B)].
  - subst h. rewrite B2R_c11000. unfold STEP_UP. lra.
  - assert (Rmax (R2 f) (-11000) <= R2 y + Rmax 0 (R2 v) / 2 + 161) by (apply Rmax_lub; lra).
    unfold STEP_UP. lra.
Qed.

Theorem ledge_attach : forall ge m0 kq jz y v h, floor_data ge m0 -> (kq <= 4)%nat ->
  F32 y = true -> F32 v = true -> Rabs (R2 v) <= 128 -> -11000 <= R2 y <= 15000 -> R2 v <= 43 ->
  (R2 v <= 0 \/ (kq <= 2)%nat) ->
  HPi (Hit_at ge m0)
    (ycast (Vsingle (Float32.add (add_zeros jz (quarter_steps kq y (Float32.div v f4))) c160))) h ->
  Hit_at ge m0 h ->
  wmotr_floor (R2 h) /\ R2 h <= R2 y + Rmax 0 (R2 v) / 2 + STEP_UP.
Proof.
  intros ge m0 kq jz y v h FD Hk Fy Fv Hv Hy H43 Hor HP Hh.
  assert (HB : HitB (Hit_at ge m0)) by (intros x Hx; destruct (FD x Hx) as (F & B & _); auto).
  split; [exact (proj2 (proj2 (FD h Hh))) |].
  exact (ledge_height _ kq jz y v h HB Hk Fy Fv Hv Hy H43 Hor HP Hh).
Qed.
