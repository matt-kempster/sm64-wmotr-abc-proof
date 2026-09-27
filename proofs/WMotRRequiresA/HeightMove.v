(* ======================================================================= *)
(* GOAL 2: the moves a real frame makes on Phi's cells, and Phi_of_move.   *)
(* (design: docs/goal2-crux-decomposition.md)                               *)
(*                                                                          *)
(* HeightFrame's crux row used to be one opaque Prop: "one real            *)
(* execute_mario_action keeps Phi".  This file splits it:                   *)
(*                                                                          *)
(*   Step c c'   what the frame can do to the cells (action, actionState,   *)
(*               actionTimer, pos[1], vel[1], floorHeight, gfx.pos[1]):     *)
(*               a binary32 air step (full or cut by a ceiling), the        *)
(*               slide-kick air step, a ground-pound windup / hold frame,   *)
(*               an E3 action switch, an attach to a floor / ledge / pole   *)
(*               (landing, bounce, launch, ground move), a floor refresh,   *)
(*               the OOB recovery.  Each constructor is the SHAPE of real   *)
(*               code (sites in the comments); that the generated Clight    *)
(*               only makes these moves is HeightFrame's Hframe_move row.   *)
(*   Phi_of_moves   PROVED: PhiC is preserved by any chain of moves, given  *)
(*               two level-data rows about WMotR (WFloor gap, poles).       *)
(* ======================================================================= *)

From Coq Require Import ZArith Reals Lra Lia Relations.
From Flocq Require Import Binary Raux.
From compcert Require Import Coqlib Integers Floats.
From SM64.Proofs Require Import HeightPhi HeightBallistic HeightMoves.

Local Open Scope R_scope.

(* ----------------------------------------------------------------------- *)
(* 1. The credit, by kind.                                                  *)
(* ----------------------------------------------------------------------- *)
Inductive kind := KFF | KSK0 | KAir | KSK1 | KGP0 | KGP1 | KGround.

Definition kind_of (a : int) (st : Z) : kind :=
  if Int.eq a ACT_FREEFALL then KFF
  else if Int.eq a ACT_BUTT_SLIDE_AIR then KFF
  else if Int.eq a ACT_SLIDE_KICK then (if Z.eqb st 0 then KSK0 else KSK1)
  else if Int.eq a ACT_GROUND_POUND then (if Z.eqb st 0 then KGP0 else KGP1)
  else if is_air a then KAir else KGround.

Definition kcredit (k : kind) (tm : Z) (v : R) : R :=
  match k with
  | KFF => bal 4 v + GP_RESERVE
  | KSK0 => bal 2 v + GP_RESERVE
  | KAir => bal 4 v
  | KSK1 => sk1_credit v
  | KGP0 => windup_left tm
  | KGP1 => 0
  | KGround => PHI_A
  end.

Lemma credit_kind : forall a st tm v, credit a st tm v = kcredit (kind_of a st) tm v.
Proof.
  intros. unfold credit, kind_of.
  repeat match goal with |- context [ if ?b then _ else _ ] => destruct b end;
    reflexivity.
Qed.

Definition kd (c : cells) : kind := kind_of (c_a c) (st_of c).

Lemma cr_kind : forall c, cr c = kcredit (kd c) (tm_of c) (R2 (c_v c)).
Proof. intros. apply credit_kind. Qed.

Lemma int_eq_false_neq : forall x y, Int.eq x y = false -> x <> y.
Proof. intros x y H E. subst. rewrite Int.eq_true in H. discriminate. Qed.

(* what each kind says about the action (for the side clauses) *)
Lemma kind_inv : forall a st,
  (kind_of a st = KSK0 \/ kind_of a st = KSK1 <-> a = ACT_SLIDE_KICK)
  /\ (kind_of a st = KGP0 \/ kind_of a st = KGP1 <-> a = ACT_GROUND_POUND)
  /\ (kind_of a st = KSK1 \/ kind_of a st = KGP1 -> st <> 0%Z)
  /\ (kind_of a st = KSK0 \/ kind_of a st = KGP0 -> st = 0%Z)
  /\ (a = ACT_LEDGE_GRAB -> kind_of a st = KGround).
Proof.
  intros a st. unfold kind_of.
  destruct (Int.eq a ACT_FREEFALL) eqn:E1;
    [ apply Int.same_if_eq in E1; subst; vm_compute; intuition congruence | ].
  destruct (Int.eq a ACT_BUTT_SLIDE_AIR) eqn:E2;
    [ apply Int.same_if_eq in E2; subst; vm_compute; intuition congruence | ].
  apply int_eq_false_neq in E1. apply int_eq_false_neq in E2.
  destruct (Int.eq a ACT_SLIDE_KICK) eqn:E3.
  - apply Int.same_if_eq in E3. subst.
    destruct (Z.eqb_spec st 0); vm_compute; intuition congruence.
  - apply int_eq_false_neq in E3.
    destruct (Int.eq a ACT_GROUND_POUND) eqn:E4.
    + apply Int.same_if_eq in E4. subst.
      destruct (Z.eqb_spec st 0); vm_compute; intuition congruence.
    + apply int_eq_false_neq in E4.
      destruct (is_air a) eqn:E5.
      * repeat split; intros; try (intuition congruence).
        subst. vm_compute in E5. discriminate.
      * repeat split; intros; intuition congruence.
Qed.

Lemma kind_SK : forall a st, a = ACT_SLIDE_KICK ->
  kind_of a st = KSK0 \/ kind_of a st = KSK1.
Proof. intros a st H. apply (proj1 (kind_inv a st)). exact H. Qed.

Lemma kind_GP : forall a st, a = ACT_GROUND_POUND ->
  kind_of a st = KGP0 \/ kind_of a st = KGP1.
Proof. intros a st H. apply (proj1 (proj2 (kind_inv a st))). exact H. Qed.

(* ----------------------------------------------------------------------- *)
(* 2. Arithmetic the moves need (reals).                                    *)
(* ----------------------------------------------------------------------- *)
Lemma bal_mono : forall g a b, 0 < g -> a <= b -> bal g a <= bal g b.
Proof.
  intros g a b Hg Hab. unfold bal.
  destruct (Rle_dec a 0); destruct (Rle_dec b 0).
  - lra.
  - pose proof (bal_nonneg g b Hg) as H. unfold bal in H.
    destruct (Rle_dec b 0); [ contradiction | exact H ].
  - lra.
  - assert (energy g a <= energy g b) by (apply energy_mono; lra).
    assert (a / g <= b / g)
      by (unfold Rdiv; apply Rmult_le_compat_r; [ left; apply Rinv_0_lt_compat; lra | lra ]).
    unfold EPS. lra.
Qed.

Lemma bal_ge_v : forall g v, 0 < g -> 0 < v -> v + EPS <= bal g v.
Proof.
  intros g v Hg Hv. unfold bal. destruct (Rle_dec v 0); [ lra | ].
  pose proof (energy_ge_v g v Hg).
  assert (0 <= v / g)
    by (unfold Rdiv; apply Rmult_le_pos; [ lra | left; apply Rinv_0_lt_compat; lra ]).
  unfold EPS in *. nra.
Qed.

(* a step cut short (ceiling) or a falling step, ending with vel <= 0 *)
Lemma bal_cut : forall g y y' v v', 0 < g ->
  (0 <= v -> y' <= y + v + / 128) -> (v <= 0 -> y' <= y) -> v' <= 0 ->
  y' + bal g v' <= y + bal g v.
Proof.
  intros g y y' v v' Hg Hup Hdn Hv'.
  rewrite (bal_nonpos g v') by exact Hv'.
  destruct (Rle_dec v 0) as [Hn | Hp].
  - pose proof (bal_nonneg g v Hg). specialize (Hdn Hn). lra.
  - pose proof (bal_ge_v g v Hg ltac:(lra)). specialize (Hup ltac:(lra)).
    unfold EPS in *. lra.
Qed.

(* the slide kick hits a ceiling rising (v >= 0): vel := 0, then -2 *)
Lemma sk1_ceil : forall y y' v, 0 <= v -> y' <= y + v + / 128 ->
  y' + sk1_credit (-2) <= y + sk1_credit v.
Proof.
  intros y y' v Hv Hy. unfold sk1_credit, energy, EPS, SK_BONK.
  rewrite (Rmax_right 0 ((-2 + 75) / 2 + 1)) by lra.
  rewrite (Rmax_right 0 ((v + 75) / 2 + 1)) by lra.
  destruct (Rle_dec (-2) (-1)); [ | lra ].
  destruct (Rle_dec v (-1)); [ lra | ].
  assert ((v + 2 / 2) ^ 2 / (2 * 2) = v + (v - 1) ^ 2 / 4) by field.
  assert ((-2 + 2 / 2) ^ 2 / (2 * 2) = 1 / 4) by field.
  pose proof (pow2_ge_0 (v - 1)). lra.
Qed.

(* the per-kind velocity caps an attach may launch with; each keeps the
   credit within A, so launching from a floor <= K stays in budget *)
Definition vcap (k : kind) (tm : Z) (v : R) : Prop :=
  match k with
  | KFF => v <= 43                           (* dive/rollout: 20/30; walk-off 0 *)
  | KSK0 => v <= 30 /\ tm = 0%Z              (* slide-kick launch 12 *)
  | KAir => v <= 52
  | KSK1 => 0 <= v <= 37.5 /\ tm = 0%Z       (* bounce: -vel/2, vel >= -75 *)
  | KGP0 => True
  | KGP1 => v <= 0
  | KGround => True
  end.

Lemma windup_left_le : forall tm, (0 <= tm)%Z -> windup_left tm <= windup_left 0.
Proof.
  intros tm Htm. rewrite windup_left_0. unfold windup_left.
  destruct (Z.leb_spec 10 tm); [ lra | ].
  assert (IZR ((10 - tm) * (11 - tm)) <= 110) by (apply IZR_le; nia).
  assert (IZR (10 - tm) <= 10) by (apply IZR_le; lia).
  unfold EPS. lra.
Qed.

Lemma windup_left_mono : forall tm, (0 <= tm)%Z -> windup_left (tm + 1) <= windup_left tm.
Proof.
  intros tm Htm. destruct (Z_lt_le_dec tm 10) as [Hl | Hg].
  - pose proof (gp_windup_frame 0 tm ltac:(lia)).
    assert (0 <= 20 - 2 * IZR tm) by (assert (IZR tm <= 10) by (apply IZR_le; lia); lra).
    unfold EPS in *. lra.
  - rewrite !windup_left_done by lia. lra.
Qed.

Lemma vcap_credit : forall k tm v, -75 <= v -> (0 <= tm)%Z -> vcap k tm v ->
  kcredit k tm v <= PHI_A.
Proof.
  intros k tm v Hv Htm Hc. unfold PHI_A, GP_RESERVE.
  destruct k; simpl in Hc |- *; unfold GP_RESERVE, PHI_A.
  - unfold bal. destruct (Rle_dec v 0); [ lra | ].
    unfold energy, EPS. assert ((v + 4 / 2) ^ 2 <= 2025) by nra. lra.
  - unfold bal. destruct (Rle_dec v 0); [ lra | ].
    unfold energy, EPS. assert ((v + 2 / 2) ^ 2 <= 961) by nra. lra.
  - unfold bal. destruct (Rle_dec v 0); [ lra | ].
    unfold energy, EPS. assert ((v + 4 / 2) ^ 2 <= 2916) by nra. lra.
  - destruct Hc as [Hc _]. unfold sk1_credit, energy, EPS, SK_BONK.
    rewrite Rmax_right by lra.
    assert ((v + 2 / 2) ^ 2 <= 1482.25) by nra.
    destruct (Rle_dec v (-1)); lra.
  - pose proof (windup_left_le tm Htm). rewrite windup_left_0 in *. lra.
  - lra.
  - lra.
Qed.

(* ----------------------------------------------------------------------- *)
(* 3. The moves.                                                            *)
(* ----------------------------------------------------------------------- *)
Definition kg (k : kind) : R := match k with KSK0 | KSK1 => 2 | _ => 4 end.

(* E3's mid-air action switches (docs/goal2-episode-graph-e3.md §2); pos,
   gfx.pos, floorHeight untouched, vel carried or zeroed *)
Inductive Switch (c c' : cells) : Prop :=
  (* -> AIR_HIT_WALL / BACKWARD_AIR_KB / SOFT_BONK / DIVE (plain air):
     vel carried, or `if (vel[1] > 0) vel[1] = 0` (airborne.c:780,975,1454,..) *)
  | Sw_plain :
      kd c <> KGround -> kd c' = KAir -> R2 (c_v c') <= R2 (c_v c) ->
      (kd c <> KFF -> kd c <> KAir -> R2 (c_v c') <= 0) ->
      Switch c c'
  (* -> FREEFALL: butt-slide-air / slide kick after actionTimer > 30
     (airborne.c:1437,1587), vel carried *)
  | Sw_freefall :
      kd c' = KFF -> R2 (c_v c') <= R2 (c_v c) ->
      (kd c = KFF \/ (c_a c = ACT_SLIDE_KICK /\ (30 <= tm_of c)%Z)) ->
      Switch c c'
  (* FREEFALL -Z-> GROUND_POUND, state 0, timer 0 (airborne.c:532) *)
  | Sw_gp :
      kd c = KFF -> c_a c' = ACT_GROUND_POUND -> st_of c' = 0%Z -> tm_of c' = 0%Z ->
      Switch c c'.

Section Moves.
  (* ---- level data (WMotR), two named rows ------------------------------ *)
  (* WFloor h: h is the height of a WMotR floor triangle at some (x, z).
     wmotr_gap: no floor height lies in the moat (K, K + 622)
     (tools/goal2_gapfact_check.py over the sloped triangles). *)
  Variable WFloor : R -> Prop.
  Hypothesis wmotr_gap : forall h, WFloor h -> ~ (PHI_K < h < PHI_K + GAP).
  (* WPole base top: a WMotR pole whose grab window starts at base - 160
     (mario_actions_automatic.c / interaction.c, docs/goal2-pole-window.md)
     and on which set_pole_position never puts Mario above top.  Every pole
     is either low (top <= K; WMotR's reachable pole tops at -1919) or out
     of reach (its window starts above YMAX; pole 4 at 2994). *)
  Variable WPole : R -> R -> Prop.
  Hypothesis wmotr_poles :
    forall base top, WPole base top -> top <= PHI_K \/ PHI_YMAX < base - 160.

  (* what an attach may snap pos[1] up to *)
  Definition Anchor (c : cells) (h : R) : Prop :=
    (kd c = KGround /\ h <= R2 (c_y c))                    (* grounded: y <= K *)
    \/ (WFloor h /\ h <= R2 (c_y c) + STEP_UP)             (* landing, ledge grab *)
    \/ (c_a c = ACT_LEDGE_GRAB /\ h <= R2 (c_fh c))        (* ledge climb *)
    \/ (exists base top, WPole base top                    (* pole grab / climb *)
          /\ base - 160 <= R2 (c_y c) /\ h <= top).

  Definition Refreshed (y fh : R) : Prop :=
    fh = -11000 \/ (WFloor fh /\ fh <= y + STEP_UP).

  Inductive Step (c c' : cells) : Prop :=
  (* perform_air_step (mario_step.c:609-653): 4 quarter steps
     pos += vel/4, then apply_gravity (vel -= g, clamp -75), and gfx := pos.
     vel may end LOWER than gravity's (the jump-ascent vel /= 4). *)
  | S_air : forall gf,
      kd c = KFF \/ kd c = KSK0 \/ kd c = KAir ->
      F32 gf = true -> R2 gf = kg (kd c) ->
      c_a c' = c_a c -> c_st c' = c_st c ->
      c_y c' = air_y4 (c_y c) (c_v c) ->
      R2 (c_v c') <= R2 (gravity gf (c_v c)) ->
      c_gy c' = c_y c' ->
      (c_a c = ACT_SLIDE_KICK ->
         tm_of c' = (tm_of c + 1)%Z /\ c_v c' = gravity gf (c_v c)) ->
      Step c c'
  (* the same step cut by a ceiling (vel >= 0 zeroed, mario_step.c:446-452;
     the remaining quarters add 0) or any GP-state-1 fall; vel ends <= 0 *)
  | S_air_cut : forall n,
      kd c = KFF \/ kd c = KSK0 \/ kd c = KAir \/ kd c = KGP1 ->
      (n <= 4)%nat ->
      c_a c' = c_a c -> c_st c' = c_st c ->
      c_y c' = qiter n (c_y c) (Float32.div (c_v c) f4) ->
      R2 (c_v c') <= 0 ->
      c_gy c' = c_y c' ->
      (c_a c = ACT_SLIDE_KICK ->
         0 <= R2 (c_v c) /\ R2 (c_v c') = -2 /\ tm_of c' = (tm_of c + 1)%Z) ->
      Step c c'
  (* post-bounce slide kick air step (g = 2), exact *)
  | S_sk1 :
      kd c = KSK1 ->
      c_a c' = c_a c -> c_st c' = c_st c ->
      c_y c' = air_y4 (c_y c) (c_v c) -> c_v c' = gravity f2 (c_v c) ->
      tm_of c' = (tm_of c + 1)%Z -> c_gy c' = c_y c' ->
      Step c c'
  | S_sk1_cut : forall n,
      kd c = KSK1 -> (n <= 4)%nat ->
      c_a c' = c_a c -> c_st c' = c_st c ->
      0 <= R2 (c_v c) ->
      c_y c' = qiter n (c_y c) (Float32.div (c_v c) f4) -> R2 (c_v c') = -2 ->
      tm_of c' = (tm_of c + 1)%Z -> c_gy c' = c_y c' ->
      Step c c'
  (* act_ground_pound state 0, timer < 10 (airborne.c:925-938):
     pos[1] += 20 - 2*timer; vel := -50; timer++ (state may turn 1) *)
  | S_gp_windup : forall o,
      kd c = KGP0 -> (tm_of c < 10)%Z ->
      c_a c' = ACT_GROUND_POUND ->
      F32 o = true -> R2 o = IZR (20 - 2 * tm_of c) ->
      c_y c' = Float32.add (c_y c) o -> R2 (c_v c') = -50 ->
      tm_of c' = (tm_of c + 1)%Z -> c_gy c' = c_y c' ->
      Step c c'
  (* the same frame with the add skipped (ceiling test fails, or timer >= 10) *)
  | S_gp_hold :
      kd c = KGP0 -> c_a c' = ACT_GROUND_POUND ->
      c_y c' = c_y c -> R2 (c_v c') = -50 ->
      tm_of c' = (tm_of c + 1)%Z -> c_gy c' = c_gy c ->
      Step c c'
  | S_switch :
      c_y c' = c_y c -> c_gy c' = c_gy c -> c_fh c' = c_fh c ->
      Switch c c' ->
      Step c c'
  (* attach: landing / bounce (pos := floorHeight, airborne.c:1444,1602),
     ledge grab (pos := ledgePos, mario_step.c:371-377), ledge climb, pole
     (set_pole_position), a ground step, or a launch from the ground;
     the new vel within the kind's cap *)
  | S_attach : forall h,
      Anchor c h -> R2 (c_y c') <= h ->
      (c_gy c' = c_y c' \/ (c_gy c' = c_gy c /\ kd c = KGround)) ->
      vcap (kd c') (tm_of c') (R2 (c_v c')) ->
      (c_a c' = ACT_LEDGE_GRAB -> Anchor c (R2 (c_fh c'))) ->
      Step c c'
  (* update_mario_geometry_inputs: floorHeight := find_floor (mario.c:1320) *)
  | S_refresh :
      c_a c' = c_a c -> c_st c' = c_st c -> c_tm c' = c_tm c ->
      c_y c' = c_y c -> c_v c' = c_v c -> c_gy c' = c_gy c ->
      Refreshed (R2 (c_y c)) (R2 (c_fh c')) ->
      Step c c'
  (* OOB recovery: pos := gfx.pos, then find_floor again (mario.c:1327-1329) *)
  | S_oob :
      c_a c' = c_a c -> c_st c' = c_st c -> c_tm c' = c_tm c ->
      c_v c' = c_v c -> c_y c' = c_gy c -> c_gy c' = c_gy c ->
      Refreshed (R2 (c_gy c)) (R2 (c_fh c')) ->
      Step c c'.

  Definition HMove (c c' : cells) : Prop := Range c' /\ Step c c'.
  Definition FrameMove : cells -> cells -> Prop := clos_refl_trans cells HMove.

  (* ---- the proofs ------------------------------------------------------- *)
  Lemma anchor_le_K : forall c h, PhiC c -> Anchor c h -> h <= PHI_K.
  Proof.
    intros c h Hc Ha.
    pose proof (PhiC_y c Hc) as Hy.
    destruct Hc as (_ & Hb & _ & _ & _ & Hl).
    rewrite cr_kind in Hb.
    destruct Ha as [[Hk Hh] | [[Hf Hh] | [[Ha Hh] | (base & top & Hp & Hw & Hh)]]].
    - rewrite Hk in Hb. simpl in Hb. lra.
    - apply (gap_fact_step h (R2 (c_y c)) (kcredit (kd c) (tm_of c) (R2 (c_v c))));
        [ exact Hh | | exact Hb | apply wmotr_gap; exact Hf ].
      rewrite <- cr_kind. apply credit_nonneg.
    - specialize (Hl Ha). lra.
    - destruct (wmotr_poles base top Hp); lra.
  Qed.

  Lemma refreshed_ledge : forall c y fh,
    PhiC c -> y + cr c <= PHI_K + PHI_A -> Refreshed y fh -> fh <= PHI_K.
  Proof.
    intros c y fh Hc Hb [H | [Hf Hh]].
    - unfold PHI_K. lra.
    - apply (gap_fact_step fh y (cr c)); auto.
      apply credit_nonneg.
  Qed.

  (* the switch never raises the credit (y is unchanged) *)
  Lemma switch_credit : forall c c', PhiC c -> Range c' -> Switch c c' -> cr c' <= cr c.
  Proof.
    intros c c' Hc Hr' Hs.
    pose proof Hc as (Hr & _ & _ & Hsk & _).
    destruct Hr as (_ & _ & _ & _ & _ & Hv).
    destruct Hr' as (_ & _ & _ & _ & _ & Hv').
    rewrite !cr_kind.
    assert (B4 : forall a b, a <= b -> bal 4 a <= bal 4 b) by (intros; apply bal_mono; lra).
    pose proof (bal_nonneg 4 (R2 (c_v c)) ltac:(lra)).
    pose proof (bal_nonneg 2 (R2 (c_v c)) ltac:(lra)).
    pose proof (sk1_credit_nonneg (R2 (c_v c))).
    pose proof (windup_left_nonneg (tm_of c)).
    unfold GP_RESERVE, PHI_A in *.
    destruct Hs as [Hk Hk' Hle Hz | Hk' Hle Hsrc | Hk Ha' Hst' Htm'].
    - rewrite Hk'. simpl.
      assert (HB : bal 4 (R2 (c_v c')) <= bal 4 (R2 (c_v c))) by (apply B4; exact Hle).
      destruct (kd c) eqn:E; simpl; unfold GP_RESERVE, PHI_A;
        first [ exfalso; congruence | lra
              | (rewrite (bal_nonpos 4 (R2 (c_v c'))) by (apply Hz; congruence); lra) ].
    - rewrite Hk'. simpl.
      destruct Hsrc as [Hk | [Ha Ht]].
      + rewrite Hk. simpl. specialize (B4 _ _ Hle). lra.
      + (* slide kick after 30 ticks: vel below -22.4, so the reserve is paid *)
        specialize (Hsk Ha).
        assert (Hd : R2 (c_v c) <= -22.4).
        { apply (sk_clause_descending (R2 (c_v c)) (IZR (tm_of c)));
            [ apply IZR_le in Ht; exact Ht | exact Hsk ]. }
        rewrite (bal_nonpos 4 (R2 (c_v c'))) by lra.
        destruct (kind_SK (c_a c) (st_of c) Ha) as [E | E]; fold (kd c) in E; rewrite E; simpl.
        * rewrite (bal_nonpos 2) by lra. lra.
        * unfold GP_RESERVE, sk1_credit, energy, EPS, SK_BONK.
          rewrite Rmax_right by lra.
          destruct (Rle_dec (R2 (c_v c)) (-1)); [ | lra ].
          assert ((R2 (c_v c) + 2 / 2) ^ 2 >= 457) by nra.
          lra.
    - unfold kd at 1. rewrite Ha', Hst', Htm'.
      replace (kind_of ACT_GROUND_POUND 0) with KGP0 by (vm_compute; reflexivity).
      rewrite Hk. simpl.
      pose proof windup_left_0_le. unfold GP_RESERVE in *. lra.
  Qed.

  (* ---- per-move preservation ------------------------------------------- *)
  Lemma kind_of_SK_eq : forall st,
    kind_of ACT_SLIDE_KICK st = if Z.eqb st 0 then KSK0 else KSK1.
  Proof. reflexivity. Qed.

  Lemma kind_of_GP_eq : forall st,
    kind_of ACT_GROUND_POUND st = if Z.eqb st 0 then KGP0 else KGP1.
  Proof. reflexivity. Qed.

  Lemma kd_same : forall c c', c_a c' = c_a c -> c_st c' = c_st c -> kd c' = kd c.
  Proof. intros c c' Ha Hs. unfold kd, st_of. rewrite Ha, Hs. reflexivity. Qed.

  Lemma kc_bal : forall k tm v, k = KFF \/ k = KSK0 \/ k = KAir ->
    kcredit k tm v = bal (kg k) v + match k with KAir => 0 | _ => GP_RESERVE end.
  Proof. intros k tm v [-> | [-> | ->]]; simpl; ring. Qed.

  Lemma tm_nonneg : forall c, (0 <= tm_of c)%Z.
  Proof. intros c. unfold tm_of. pose proof (Int.unsigned_range (c_tm c)). lia. Qed.

  Lemma sk_clause_step : forall v v' tm,
    (v + 2 * IZR tm <= 37.5 + IZR tm / 1024 \/ v <= -73) ->
    ((v - 2 < -75 /\ v' = -75) \/ (-75 <= v' /\ Rabs (v' - (v - 2)) <= / 65536)) ->
    v' + 2 * IZR (tm + 1) <= 37.5 + IZR (tm + 1) / 1024 \/ v' <= -73.
  Proof.
    intros v v' tm Hc Hg. rewrite plus_IZR.
    destruct Hg as [[_ ->] | [_ Hd]]; [ right; lra | ].
    apply Rabs_le_inv in Hd. destruct Hc; [ left | right ]; lra.
  Qed.

  Lemma sk_clause_cut : forall v tm, 0 <= v ->
    (v + 2 * IZR tm <= 37.5 + IZR tm / 1024 \/ v <= -73) ->
    -2 + 2 * IZR (tm + 1) <= 37.5 + IZR (tm + 1) / 1024 \/ -2 <= -73.
  Proof. intros v tm Hv Hc. left. rewrite plus_IZR. destruct Hc; lra. Qed.

  Ltac dphi H :=
    destruct H as ((?Fy & ?Fv & ?Fgy & ?Hylo & ?Hgylo & ?Hvlo & ?Hvhi)
                   & ?Hb & ?Hgb & ?Hsk & ?Hgp & ?Hl).

  Lemma y_hi : forall c, PhiC c -> R2 (c_y c) <= 2744.
  Proof. intros c H. pose proof (PhiC_y c H). unfold PHI_YMAX, PHI_K, PHI_A in *. lra. Qed.

  Lemma not_ledge_air : forall c, kd c <> KGround -> c_a c <> ACT_LEDGE_GRAB.
  Proof. intros c Hk Ha. apply Hk. unfold kd. apply (kind_inv (c_a c) (st_of c)). exact Ha. Qed.

  Lemma not_SK : forall c, kd c <> KSK0 -> kd c <> KSK1 -> c_a c <> ACT_SLIDE_KICK.
  Proof.
    intros c H0 H1 Ha. destruct (kind_SK (c_a c) (st_of c) Ha); fold (kd c) in *; congruence.
  Qed.

  Lemma not_GP : forall c, kd c <> KGP0 -> kd c <> KGP1 -> c_a c <> ACT_GROUND_POUND.
  Proof.
    intros c H0 H1 Ha. destruct (kind_GP (c_a c) (st_of c) Ha); fold (kd c) in *; congruence.
  Qed.

  (* the three side clauses hold vacuously for a target of a plain kind *)
  Lemma sides_plain : forall c', kd c' = KFF \/ kd c' = KAir ->
    (c_a c' = ACT_SLIDE_KICK -> False)
    /\ (c_a c' = ACT_GROUND_POUND -> False)
    /\ (c_a c' = ACT_LEDGE_GRAB -> False).
  Proof.
    intros c' Hk. repeat split; intros Ha.
    - apply (not_SK c'); [ | | exact Ha ]; destruct Hk; congruence.
    - apply (not_GP c'); [ | | exact Ha ]; destruct Hk; congruence.
    - apply (not_ledge_air c'); [ | exact Ha ]; destruct Hk; congruence.
  Qed.

  Theorem Phi_of_step : forall c c', PhiC c -> Range c' -> Step c c' -> PhiC c'.
  Proof.
    intros c c' Hc Hr' Hs.
    pose proof (y_hi c Hc) as Hyhi.
    pose proof Hc as Hc0.
    dphi Hc.
    assert (Hy16 : Rabs (R2 (c_y c)) <= 16000) by (apply Rabs_le; split; lra).
    assert (Hv128 : Rabs (R2 (c_v c)) <= 128) by (apply Rabs_le; split; lra).
    pose proof Hr' as (Fy' & Fv' & Fgy' & Hylo' & Hgylo' & Hvlo' & Hvhi').
    pose proof (tm_nonneg c) as Htm0. pose proof (tm_nonneg c') as Htm0'.
    split; [ exact Hr' | ].
    destruct Hs as
      [ gf Hk Fgf Hgf Ha Hst Hy' Hv' Hgy' Hskp
      | n Hk Hn Ha Hst Hy' Hv' Hgy' Hskp
      | Hk Ha Hst Hy' Hv' Htm' Hgy'
      | n Hk Hn Ha Hst Hv0 Hy' Hv' Htm' Hgy'
      | o Hk Hlt Ha Fo Ho Hy' Hv' Htm' Hgy'
      | Hk Ha Hy' Hv' Htm' Hgy'
      | Hy' Hgy' Hfh' Hsw
      | h Han Hyh Hgy' Hcap Hla
      | Ha Hst Htmc Hy' Hv' Hgy' Hrf
      | Ha Hst Htmc Hv' Hy' Hgy' Hrf ].
    - (* S_air *)
      assert (Hk' : kd c' = kd c) by (apply kd_same; auto).
      assert (Hg4 : R2 gf = 2 \/ R2 gf = 4)
        by (rewrite Hgf; destruct Hk as [E | [E | E]]; rewrite E; simpl; auto).
      destruct (ballistic_frame gf (c_y c) (c_v c) Fgf Fy Fv Hg4 Hy16 Hv128) as [_ Hbf].
      rewrite <- Hy' in Hbf.
      assert (Hmono : bal (R2 gf) (R2 (c_v c')) <= bal (R2 gf) (R2 (gravity gf (c_v c))))
        by (apply bal_mono; [ destruct Hg4; lra | exact Hv' ]).
      assert (Hcr : R2 (c_y c') + cr c' <= R2 (c_y c) + cr c).
      { rewrite !cr_kind, Hk'. rewrite !(kc_bal (kd c)) by exact Hk. rewrite <- Hgf. lra. }
      split; [ lra | split; [ rewrite Hgy'; lra | split; [ | split ] ] ].
      + intros Ha'. rewrite Ha in Ha'. destruct (Hskp Ha') as [Ht Hvv].
        destruct (kind_SK (c_a c) (st_of c) Ha') as [E | E]; fold (kd c) in E;
          [ | exfalso; destruct Hk as [? | [? | ?]]; congruence ].
        rewrite E in Hgf. simpl in Hgf.
        pose proof (gravity_spec2 gf (c_v c) Fgf Fv (or_introl Hgf) Hv128) as Hgr.
        rewrite Hgf, <- Hvv in Hgr.
        rewrite Ht. exact (sk_clause_step _ _ _ (Hsk Ha') Hgr).
      + intros Ha'. exfalso. rewrite Ha in Ha'.
        apply (not_GP c); [ | | exact Ha' ]; destruct Hk as [? | [? | ?]]; congruence.
      + intros Ha'. exfalso. rewrite Ha in Ha'.
        apply (not_ledge_air c); [ | exact Ha' ]; destruct Hk as [? | [? | ?]]; congruence.
    - (* S_air_cut *)
      assert (Hk' : kd c' = kd c) by (apply kd_same; auto).
      destruct (qiter_up n (c_y c) (c_v c) Hn Fy Fv Hy16 Hv128) as (_ & Hup & Hdn & _).
      rewrite <- Hy' in Hup, Hdn.
      assert (Hcr : R2 (c_y c') + cr c' <= R2 (c_y c) + cr c).
      { rewrite !cr_kind, Hk'.
        destruct Hk as [E | [E | [E | E]]]; rewrite E; simpl;
          try (apply Rplus_le_compat_r || idtac);
          try (apply bal_cut; [ lra | exact Hup | exact Hdn | exact Hv' ]).
        - pose proof (bal_cut 4 _ _ _ _ ltac:(lra) Hup Hdn Hv'). lra.
        - pose proof (bal_cut 2 _ _ _ _ ltac:(lra) Hup Hdn Hv'). lra.
        - (* GP state 1 falls *)
          assert (Hga : c_a c = ACT_GROUND_POUND)
            by (apply (proj1 (proj2 (kind_inv (c_a c) (st_of c)))); right; exact E).
          assert (Hst0 : st_of c <> 0%Z)
            by (apply (proj1 (proj2 (proj2 (kind_inv (c_a c) (st_of c))))); right; exact E).
          specialize (Hgp Hga Hst0). specialize (Hdn Hgp). lra. }
      split; [ lra | split; [ rewrite Hgy'; lra | split; [ | split ] ] ].
      + intros Ha'. rewrite Ha in Ha'. destruct (Hskp Ha') as (Hv0 & Hv2 & Ht).
        rewrite Ht, Hv2. exact (sk_clause_cut _ _ Hv0 (Hsk Ha')).
      + intros Ha' Hst'. exact Hv'.
      + intros Ha'. exfalso. rewrite Ha in Ha'.
        apply (not_ledge_air c); [ | exact Ha' ]; destruct Hk as [? | [? | [? | ?]]]; congruence.
    - (* S_sk1 *)
      assert (Hk' : kd c' = kd c) by (apply kd_same; auto).
      pose proof (sk1_frame (c_y c) (c_v c) Fy Fv Hy16 (conj Hvlo Hvhi)) as Hf.
      rewrite <- Hy', <- Hv' in Hf.
      assert (Hcr : R2 (c_y c') + cr c' <= R2 (c_y c) + cr c)
        by (rewrite !cr_kind, Hk', Hk; simpl; exact Hf).
      assert (Ha0 : c_a c = ACT_SLIDE_KICK)
        by (apply (proj1 (kind_inv (c_a c) (st_of c))); right; exact Hk).
      split; [ lra | split; [ rewrite Hgy'; lra | split; [ | split ] ] ].
      + intros _. rewrite Htm'.
        pose proof (gravity_spec2 f2 (c_v c) F32_f2 Fv (or_introl B2R_f2) Hv128) as Hgr.
        rewrite B2R_f2, <- Hv' in Hgr.
        exact (sk_clause_step _ _ _ (Hsk Ha0) Hgr).
      + intros Ha'. exfalso. rewrite Ha, Ha0 in Ha'. discriminate.
      + intros Ha'. exfalso. rewrite Ha, Ha0 in Ha'. discriminate.
    - (* S_sk1_cut *)
      assert (Hk' : kd c' = kd c) by (apply kd_same; auto).
      destruct (qiter_up n (c_y c) (c_v c) Hn Fy Fv Hy16 Hv128) as (_ & Hup & _ & _).
      rewrite <- Hy' in Hup. specialize (Hup Hv0).
      pose proof (sk1_ceil _ _ _ Hv0 Hup) as Hf.
      assert (Hcr : R2 (c_y c') + cr c' <= R2 (c_y c) + cr c)
        by (rewrite !cr_kind, Hk', Hk; simpl; rewrite Hv'; exact Hf).
      assert (Ha0 : c_a c = ACT_SLIDE_KICK)
        by (apply (proj1 (kind_inv (c_a c) (st_of c))); right; exact Hk).
      split; [ lra | split; [ rewrite Hgy'; lra | split; [ | split ] ] ].
      + intros _. rewrite Htm', Hv'. exact (sk_clause_cut _ _ Hv0 (Hsk Ha0)).
      + intros Ha'. exfalso. rewrite Ha, Ha0 in Ha'. discriminate.
      + intros Ha'. exfalso. rewrite Ha, Ha0 in Ha'. discriminate.
    - (* S_gp_windup *)
      assert (Hoz : R2 o = 20 - 2 * IZR (tm_of c))
        by (rewrite Ho, minus_IZR, mult_IZR; reflexivity).
      assert (Htm10 : IZR (tm_of c) <= 9) by (apply IZR_le; lia).
      assert (Htm00 : 0 <= IZR (tm_of c)) by (apply IZR_le; lia).
      destruct (windup_add (c_y c) o Fy Fo ltac:(lra) ltac:(lra)) as [_ Hwa].
      rewrite <- Hy' in Hwa.
      pose proof (gp_windup_frame 0 (tm_of c) ltac:(lia)) as Hwf.
      pose proof (windup_left_nonneg (tm_of c + 1)) as Hw1.
      assert (Hcr : R2 (c_y c') + cr c' <= R2 (c_y c) + cr c).
      { rewrite !cr_kind, Hk. unfold kd. rewrite Ha, kind_of_GP_eq, Htm'. simpl.
        destruct (Z.eqb (st_of c') 0); simpl; lra. }
      split; [ lra | split; [ rewrite Hgy'; lra | split; [ | split ] ] ].
      + intros Ha'. rewrite Ha in Ha'. discriminate.
      + intros _ _. lra.
      + intros Ha'. rewrite Ha in Ha'. discriminate.
    - (* S_gp_hold *)
      pose proof (windup_left_mono (tm_of c) Htm0) as Hwm.
      pose proof (windup_left_nonneg (tm_of c + 1)) as Hw1.
      assert (Hcr : cr c' <= cr c).
      { rewrite !cr_kind, Hk. unfold kd. rewrite Ha, kind_of_GP_eq, Htm'. simpl.
        destruct (Z.eqb (st_of c') 0); simpl; lra. }
      split; [ rewrite Hy'; lra | split; [ rewrite Hgy'; lra | split; [ | split ] ] ].
      + intros Ha'. rewrite Ha in Ha'. discriminate.
      + intros _ _. lra.
      + intros Ha'. rewrite Ha in Ha'. discriminate.
    - (* S_switch *)
      pose proof (switch_credit c c' Hc0 Hr' Hsw) as Hcr.
      split; [ rewrite Hy'; lra | split; [ rewrite Hgy'; lra | ] ].
      destruct Hsw as [_ Hk' _ _ | Hk' _ _ | _ Ha' Hst' _].
      + destruct (sides_plain c' (or_intror Hk')) as (S1 & S2 & S3).
        split; [ intros H; destruct (S1 H) | split; [ intros H; destruct (S2 H) | intros H; destruct (S3 H) ] ].
      + destruct (sides_plain c' (or_introl Hk')) as (S1 & S2 & S3).
        split; [ intros H; destruct (S1 H) | split; [ intros H; destruct (S2 H) | intros H; destruct (S3 H) ] ].
      + rewrite Ha'. split; [ intros H; discriminate | split; [ intros _ H; contradiction | intros H; discriminate ] ].
    - (* S_attach *)
      pose proof (anchor_le_K c h Hc0 Han) as HhK.
      assert (Hca : cr c' <= PHI_A)
        by (rewrite cr_kind; apply vcap_credit; [ exact Hvlo' | exact Htm0' | exact Hcap ]).
      pose proof (credit_nonneg (c_a c') (st_of c') (tm_of c') (R2 (c_v c'))) as Hc'0.
      fold (cr c') in Hc'0.
      split; [ lra | split; [ | split; [ | split ] ] ].
      + destruct Hgy' as [-> | [-> Hkg]]; [ lra | ].
        rewrite cr_kind, Hkg in Hgb. simpl in Hgb. lra.
      + intros Ha'.
        destruct (kind_SK (c_a c') (st_of c') Ha') as [E | E]; fold (kd c') in E;
          rewrite E in Hcap; simpl in Hcap; left.
        * destruct Hcap as [Hc1 ->]. simpl. lra.
        * destruct Hcap as [Hc1 ->]. simpl. lra.
      + intros Ha' Hst'.
        destruct (kind_GP (c_a c') (st_of c') Ha') as [E | E]; fold (kd c') in E.
        * exfalso. apply Hst'.
          apply (proj1 (proj2 (proj2 (proj2 (kind_inv (c_a c') (st_of c')))))). right. exact E.
        * rewrite E in Hcap. exact Hcap.
      + intros Ha'. exact (anchor_le_K c _ Hc0 (Hla Ha')).
    - (* S_refresh *)
      assert (Hcr : cr c' = cr c) by (unfold cr, st_of, tm_of; rewrite Ha, Hst, Htmc, Hv'; reflexivity).
      split; [ rewrite Hy', Hcr; lra | split; [ rewrite Hgy', Hcr; lra | split; [ | split ] ] ].
      + intros Ha'. unfold tm_of. rewrite Hv', Htmc. rewrite Ha in Ha'. exact (Hsk Ha').
      + intros Ha' Hst'. rewrite Hv'. rewrite Ha in Ha'. unfold st_of in *. rewrite Hst in Hst'.
        exact (Hgp Ha' Hst').
      + intros _. exact (refreshed_ledge c _ _ Hc0 Hb Hrf).
    - (* S_oob *)
      assert (Hcr : cr c' = cr c) by (unfold cr, st_of, tm_of; rewrite Ha, Hst, Htmc, Hv'; reflexivity).
      split; [ rewrite Hy', Hcr; lra | split; [ rewrite Hgy', Hcr; lra | split; [ | split ] ] ].
      + intros Ha'. unfold tm_of. rewrite Hv', Htmc. rewrite Ha in Ha'. exact (Hsk Ha').
      + intros Ha' Hst'. rewrite Hv'. rewrite Ha in Ha'. unfold st_of in *. rewrite Hst in Hst'.
        exact (Hgp Ha' Hst').
      + intros _. exact (refreshed_ledge c _ _ Hc0 Hgb Hrf).
  Qed.

  Theorem Phi_of_moves : forall c c', PhiC c -> FrameMove c c' -> PhiC c'.
  Proof.
    intros c c' Hc Hm. induction Hm as [ x y [Hr Hs] | x | x y z _ IH1 _ IH2 ].
    - exact (Phi_of_step x y Hc Hr Hs).
    - exact Hc.
    - exact (IH2 (IH1 Hc)).
  Qed.
End Moves.
