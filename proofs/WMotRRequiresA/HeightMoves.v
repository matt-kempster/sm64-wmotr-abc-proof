(* GOAL 2: the non-ballistic budget arithmetic of the height frame moves.    *)
(* ======================================================================= *)
(* Over the REALS, in terms of HeightPhi's own definitions (credit, bal,   *)
(* energy, sk1_credit, windup_left, EPS, GP_RESERVE, PHI_K, PHI_A), the     *)
(* budget facts each non-ballistic move of the crux row needs:              *)
(*   1. launches from a floor y <= K (dive 20, rollout 30, slide kick 12    *)
(*      at g = 2, walk-off freefall at 0);                                  *)
(*   2. bounces (slide kick state 0 -> 1, butt-slide-air) at -75 <= v < 0;  *)
(*   3. slide kick state 1 -> freefall edge (timer >= 30);                  *)
(*   4. freefall -> ground pound, and one GP windup frame;                  *)
(*   5. landing / attach, and the gap-fact step (239 + 372 < 622).          *)
(* Real arithmetic only: the binary32 rounding of these moves is in        *)
(* HeightBallistic / HeightMove, and that the generated Clight performs     *)
(* them is HeightFrame's Hframe_move row.  Consumed by HeightMove.v.        *)
(* ======================================================================= *)

From Coq Require Import ZArith Reals Lra Lia.
From SM64.Proofs Require Import HeightPhi.

Local Open Scope R_scope.

Lemma bal_pos : forall g v, 0 < v -> bal g v = energy g v + EPS * (v / g + 1).
Proof. intros g v H. unfold bal. destruct (Rle_dec v 0); [ lra | reflexivity ]. Qed.

Lemma bal_nonpos : forall g v, v <= 0 -> bal g v = 0.
Proof. intros g v H. unfold bal. destruct (Rle_dec v 0); [ reflexivity | lra ]. Qed.

(* ---- 1. launches from a floor y <= K --------------------------------- *)

Lemma launch_budget : forall y g c extra,
  y <= PHI_K -> 0 < g -> 0 < c ->
  energy g c + EPS * (c / g + 1) + extra <= PHI_A ->
  y + bal g c + extra <= PHI_K + PHI_A.
Proof. intros. rewrite bal_pos by lra. lra. Qed.

Lemma dive_launch : forall y, y <= PHI_K ->
  y + bal 4 20 + GP_RESERVE <= PHI_K + PHI_A.       (* 60.59 + 110 *)
Proof.
  intros y Hy. apply launch_budget; try lra.
  unfold energy, EPS, GP_RESERVE, PHI_A. lra.
Qed.

Lemma rollout_launch : forall y, y <= PHI_K ->
  y + bal 4 30 + GP_RESERVE <= PHI_K + PHI_A.       (* 128.13 + 110 *)
Proof.
  intros y Hy. apply launch_budget; try lra.
  unfold energy, EPS, GP_RESERVE, PHI_A. lra.
Qed.

(* the reserve-free forms (dive / rollout are plain is_air: credit = bal 4) *)
Lemma dive_launch_noGP : forall y, y <= PHI_K -> y + bal 4 20 <= PHI_K + PHI_A.
Proof. intros y Hy. pose proof (dive_launch y Hy). unfold GP_RESERVE in *. lra. Qed.

Lemma rollout_launch_noGP : forall y, y <= PHI_K -> y + bal 4 30 <= PHI_K + PHI_A.
Proof. intros y Hy. pose proof (rollout_launch y Hy). unfold GP_RESERVE in *. lra. Qed.

Lemma slide_kick_launch : forall y, y <= PHI_K ->
  y + bal 2 12 + GP_RESERVE <= PHI_K + PHI_A.       (* 42.36 + 110 *)
Proof.
  intros y Hy. apply launch_budget; try lra.
  unfold energy, EPS, GP_RESERVE, PHI_A. lra.
Qed.

Lemma walk_off_launch : forall y, y <= PHI_K ->
  y + bal 4 0 + GP_RESERVE <= PHI_K + PHI_A.
Proof.
  intros y Hy. rewrite bal_nonpos by lra. unfold GP_RESERVE, PHI_K, PHI_A in *. lra.
Qed.

(* ---- 2. bounces -------------------------------------------------------- *)

(* slide kick state 0 landing: vel := -v/2, state 1, timer 0 *)
Lemma sk_bounce_budget : forall fh v,
  fh <= PHI_K -> -75 <= v < 0 ->
  fh + sk1_credit (- v / 2) <= PHI_K + PHI_A.
Proof.
  intros fh v Hfh Hv. unfold sk1_credit, energy, EPS, SK_BONK, PHI_K, PHI_A in *.
  rewrite Rmax_right by lra.
  destruct (Rle_dec (- v / 2) (-1)); [ lra | ].
  assert (0 < - v / 2 + 2 / 2 <= 38.5) by lra.
  assert ((- v / 2 + 2 / 2) ^ 2 <= 38.5 ^ 2) by nra.
  lra.
Qed.

(* the tightest point: v = -75 gives sk1_credit 37.5 = 371.707 <= 372 *)
Lemma sk_bounce_apex : sk1_credit 37.5 = 370.5625 + 57.25 / 64 + 1 / 4.
Proof.
  unfold sk1_credit, energy, EPS, SK_BONK. rewrite Rmax_right by lra.
  destruct (Rle_dec 37.5 (-1)); lra.
Qed.

Lemma bsa_bounce_budget : forall fh v,
  fh <= PHI_K -> -75 <= v < 0 ->
  fh + bal 4 (- v / 2) + GP_RESERVE <= PHI_K + PHI_A.
Proof.
  intros fh v Hfh Hv. rewrite bal_pos by lra.
  unfold energy, EPS, GP_RESERVE, PHI_K, PHI_A in *.
  assert (0 < - v / 2 + 4 / 2 <= 39.5) by lra.
  assert ((- v / 2 + 4 / 2) ^ 2 <= 39.5 ^ 2) by nra.
  lra.
Qed.

(* ---- 3. slide kick state 1 -> freefall edge --------------------------- *)
(* the edge needs actionTimer > 30 (airborne.c:1587); HeightPhi's slide-kick
   clause then puts vel below -22.4, so the signed energy pays the reserve *)
Lemma sk_clause_descending : forall v tm,
  30 <= tm ->
  v + 2 * tm <= 37.5 + tm / 1024 \/ v <= -73 ->
  v <= -22.4.
Proof. intros v tm Ht [H | H]; lra. Qed.

Lemma sk1_to_freefall : forall y v tm,
  y + sk1_credit v <= PHI_K + PHI_A ->
  30 <= tm ->
  v + 2 * tm <= 37.5 + tm / 1024 \/ v <= -73 ->
  y + bal 4 v + GP_RESERVE <= PHI_K + PHI_A.
Proof.
  intros y v tm Hb Ht Hs.
  pose proof (sk_clause_descending v tm Ht Hs) as Hv.
  rewrite bal_nonpos by lra.
  unfold sk1_credit, energy, EPS, GP_RESERVE, SK_BONK in *.
  pose proof (Rmax_l 0 ((v + 75) / 2 + 1)).
  destruct (Rle_dec v (-1)); [ | lra ].
  assert ((v + 2 / 2) ^ 2 >= 459) by nra.
  lra.
Qed.

(* ---- 4. freefall -> ground pound; GP windup ---------------------------- *)
Lemma windup_left_0 : windup_left 0 = 110 + 10 / 64.
Proof. unfold windup_left, EPS. simpl. lra. Qed.

Lemma windup_left_0_le : windup_left 0 <= GP_RESERVE.
Proof. rewrite windup_left_0. unfold GP_RESERVE. lra. Qed.

Lemma freefall_to_gp : forall y v,
  y + bal 4 v + GP_RESERVE <= PHI_K + PHI_A ->
  y + windup_left 0 <= PHI_K + PHI_A.
Proof.
  intros y v H. pose proof windup_left_0_le.
  pose proof (bal_nonneg 4 v ltac:(lra)). lra.
Qed.

(* one windup frame: the add may round up by < EPS, which the frame pays *)
Lemma gp_windup_frame : forall y tm, (0 <= tm < 10)%Z ->
  (y + (20 - 2 * IZR tm) + EPS) + windup_left (tm + 1) = y + windup_left tm.
Proof.
  intros y tm Htm. unfold windup_left.
  destruct (Z.leb_spec 10 tm); [ lia | ].
  destruct (Z.leb_spec 10 (tm + 1)).
  - assert (tm = 9%Z) by lia. subst. simpl. unfold EPS. lra.
  - rewrite !mult_IZR, !minus_IZR, plus_IZR. simpl. unfold EPS. ring.
Qed.

Lemma windup_left_done : forall tm, (10 <= tm)%Z -> windup_left tm = 0.
Proof. intros tm H. unfold windup_left. destruct (Z.leb_spec 10 tm); [ reflexivity | lia ]. Qed.

(* ---- 5. landing / attach; the gap-fact step --------------------------- *)

Lemma landing_budget : forall h, h <= PHI_K -> h + PHI_A <= PHI_K + PHI_A.
Proof. intros. lra. Qed.

Definition GAP : R := 622.
Definition STEP_UP : R := 239.

Lemma gap_margin : STEP_UP + PHI_A < GAP.           (* 611 < 622 *)
Proof. unfold STEP_UP, PHI_A, GAP. lra. Qed.

Lemma gap_fact_step : forall h y c,
  h <= y + STEP_UP -> 0 <= c -> y + c <= PHI_K + PHI_A ->
  ~ (PHI_K < h < PHI_K + GAP) -> h <= PHI_K.
Proof.
  intros h y c Hh Hc Hb Hgap. unfold STEP_UP, PHI_A, GAP in *.
  destruct (Rle_dec h PHI_K) as [ | Hn ]; [ assumption | ].
  exfalso. apply Hgap. lra.
Qed.

Lemma gap_fact_step_credit : forall h y a st tm v,
  h <= y + STEP_UP -> y + credit a st tm v <= PHI_K + PHI_A ->
  ~ (PHI_K < h < PHI_K + GAP) -> h <= PHI_K.
Proof.
  intros. eapply gap_fact_step; eauto. apply credit_nonneg.
Qed.
