(* ======================================================================= *)
(* GOAL 2: the catalog of moves a real frame makes on Mario's height       *)
(* cells, and chain_keeps_budget.                                           *)
(* (design: docs/goal2-crux-decomposition.md)                               *)
(*                                                                          *)
(* HeightFrame's crux row used to be one opaque Prop (one real              *)
(* execute_mario_action keeps Phi).  This file splits it:                   *)
(*                                                                          *)
(*   Move c c'   what the frame can do to the cells (action, actionState,   *)
(*               actionTimer, pos[1], vel[1], floorHeight, gfx.pos[1]):     *)
(*               a binary32 air step (full or cut by a ceiling), the        *)
(*               slide-kick air step, a ground-pound windup / hold frame,   *)
(*               an E3 action switch, an attach to a floor / ledge / pole   *)
(*               (landing, bounce, launch, ground move), a floor refresh,   *)
(*               the OOB recovery.  Each constructor is the SHAPE of real   *)
(*               code (sites in the comments); that the generated Clight    *)
(*               only makes these moves is HeightFrame's row                *)
(*               Hframe_is_move_chain.                                      *)
(*   chain_keeps_budget   PROVED: budget_ok is preserved by any chain of    *)
(*               moves, given two level-data rows about WMotR (floor gap,   *)
(*               poles).                                                    *)
(* ======================================================================= *)

From Coq Require Import ZArith Reals Lra Lia Relations.
From Flocq Require Import Binary Raux.
From compcert Require Import Coqlib Integers Floats.
From SM64.Proofs Require Import HeightInvariant HeightFloatSteps HeightBudgetArith.

Local Open Scope R_scope.

(* -----------------------------------------------------------------------  *)
(* 1. The credit, by mode.                                                  *)
(* -----------------------------------------------------------------------  *)
Inductive mode := M_Freefall | M_SlideKick | M_Air | M_SlideKickBounced | M_PoundWindup | M_PoundFall | M_Ground.

Definition mode_of_action (a : int) (st : Z) : mode :=
  if Int.eq a ACT_FREEFALL then M_Freefall
  else if Int.eq a ACT_BUTT_SLIDE_AIR then M_Freefall
  else if Int.eq a ACT_SLIDE_KICK then (if Z.eqb st 0 then M_SlideKick else M_SlideKickBounced)
  else if Int.eq a ACT_GROUND_POUND then (if Z.eqb st 0 then M_PoundWindup else M_PoundFall)
  else if is_air a then M_Air else M_Ground.

Definition mode_credit (k : mode) (tm : Z) (v : R) : R :=
  match k with
  | M_Freefall => rise_credit 4 v + GP_RESERVE
  | M_SlideKick => rise_credit 2 v + GP_RESERVE
  | M_Air => rise_credit 4 v
  | M_SlideKickBounced => sk_bounced_credit v
  | M_PoundWindup => windup_left tm
  | M_PoundFall => 0
  | M_Ground => PHI_A
  end.

Lemma credit_by_mode : forall a st tm v, credit a st tm v = mode_credit (mode_of_action a st) tm v.
Proof.
  intros. unfold credit, mode_of_action.
  repeat match goal with |- context [ if ?b then _ else _ ] => destruct b end;
    reflexivity.
Qed.

Definition mode_of (c : cells) : mode := mode_of_action (c_action c) (state_of c).

Lemma credit_of_mode : forall c, credit_of c = mode_credit (mode_of c) (timer_of c) (R2 (c_vely c)).
Proof. intros. apply credit_by_mode. Qed.

Lemma int_eq_false_neq : forall x y, Int.eq x y = false -> x <> y.
Proof. intros x y H E. subst. rewrite Int.eq_true in H. discriminate. Qed.

(* what each mode says about the action (for the side clauses)              *)
Lemma mode_of_action_inv : forall a st,
  (mode_of_action a st = M_SlideKick \/ mode_of_action a st = M_SlideKickBounced <-> a = ACT_SLIDE_KICK)
  /\ (mode_of_action a st = M_PoundWindup \/ mode_of_action a st = M_PoundFall <-> a = ACT_GROUND_POUND)
  /\ (mode_of_action a st = M_SlideKickBounced \/ mode_of_action a st = M_PoundFall -> st <> 0%Z)
  /\ (mode_of_action a st = M_SlideKick \/ mode_of_action a st = M_PoundWindup -> st = 0%Z)
  /\ (a = ACT_LEDGE_GRAB -> mode_of_action a st = M_Ground).
Proof.
  intros a st. unfold mode_of_action.
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

Lemma mode_slide_kick : forall a st, a = ACT_SLIDE_KICK ->
  mode_of_action a st = M_SlideKick \/ mode_of_action a st = M_SlideKickBounced.
Proof. intros a st H. apply (proj1 (mode_of_action_inv a st)). exact H. Qed.

Lemma mode_ground_pound : forall a st, a = ACT_GROUND_POUND ->
  mode_of_action a st = M_PoundWindup \/ mode_of_action a st = M_PoundFall.
Proof. intros a st H. apply (proj1 (proj2 (mode_of_action_inv a st))). exact H. Qed.

(* -----------------------------------------------------------------------  *)
(* 2. Arithmetic the moves need (reals).                                    *)
(* -----------------------------------------------------------------------  *)
Lemma rise_credit_mono : forall g a b, 0 < g -> a <= b -> rise_credit g a <= rise_credit g b.
Proof.
  intros g a b Hg Hab. unfold rise_credit.
  destruct (Rle_dec a 0); destruct (Rle_dec b 0).
  - lra.
  - pose proof (rise_credit_nonneg g b Hg) as H. unfold rise_credit in H.
    destruct (Rle_dec b 0); [ contradiction | exact H ].
  - lra.
  - assert (energy g a <= energy g b) by (apply energy_mono; lra).
    assert (a / g <= b / g)
      by (unfold Rdiv; apply Rmult_le_compat_r; [ left; apply Rinv_0_lt_compat; lra | lra ]).
    unfold EPS. lra.
Qed.

Lemma rise_credit_ge_v : forall g v, 0 < g -> 0 < v -> v + EPS <= rise_credit g v.
Proof.
  intros g v Hg Hv. unfold rise_credit. destruct (Rle_dec v 0); [ lra | ].
  pose proof (energy_ge_v g v Hg).
  assert (0 <= v / g)
    by (unfold Rdiv; apply Rmult_le_pos; [ lra | left; apply Rinv_0_lt_compat; lra ]).
  unfold EPS in *. nra.
Qed.

(* a step cut short (ceiling) or a falling step, ending with vel <= 0       *)
Lemma rise_credit_cut : forall g y y' v v', 0 < g ->
  (0 <= v -> y' <= y + v + / 128) -> (v <= 0 -> y' <= y) -> v' <= 0 ->
  y' + rise_credit g v' <= y + rise_credit g v.
Proof.
  intros g y y' v v' Hg Hup Hdn Hv'.
  rewrite (rise_credit_nonpos g v') by exact Hv'.
  destruct (Rle_dec v 0) as [Hn | Hp].
  - pose proof (rise_credit_nonneg g v Hg). specialize (Hdn Hn). lra.
  - pose proof (rise_credit_ge_v g v Hg ltac:(lra)). specialize (Hup ltac:(lra)).
    unfold EPS in *. lra.
Qed.

(* the slide kick hits a ceiling rising (v >= 0): vel := 0, then -2         *)
Lemma sk_bounced_ceil : forall y y' v, 0 <= v -> y' <= y + v + / 128 ->
  y' + sk_bounced_credit (-2) <= y + sk_bounced_credit v.
Proof.
  intros y y' v Hv Hy. unfold sk_bounced_credit, energy, EPS, SK_BONK.
  rewrite (Rmax_right 0 ((-2 + 75) / 2 + 1)) by lra.
  rewrite (Rmax_right 0 ((v + 75) / 2 + 1)) by lra.
  destruct (Rle_dec (-2) (-1)); [ | lra ].
  destruct (Rle_dec v (-1)); [ lra | ].
  assert ((v + 2 / 2) ^ 2 / (2 * 2) = v + (v - 1) ^ 2 / 4) by field.
  assert ((-2 + 2 / 2) ^ 2 / (2 * 2) = 1 / 4) by field.
  pose proof (pow2_ge_0 (v - 1)). lra.
Qed.

(* the per-mode velocity caps an attach may launch with; each keeps the
   credit within A, so launching from a floor <= K stays in budget *)
Definition launch_cap (k : mode) (tm : Z) (v : R) : Prop :=
  match k with
  | M_Freefall => v <= 43                           (* dive/rollout: 20/30; a walk-off can
                                                      carry a rising vel (<= 30) out of a
                                                      stationary landing, which keeps vel[1] *)
  | M_SlideKick => v <= 30 /\ tm = 0%Z              (* slide-kick launch 12 *)
  | M_Air => v <= 52
  | M_SlideKickBounced => 0 <= v <= 37.5 /\ tm = 0%Z       (* bounce: -vel/2, vel >= -75 *)
  | M_PoundWindup => True
  | M_PoundFall => v <= 0
  | M_Ground => True
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

Lemma launch_cap_credit : forall k tm v, -75 <= v -> (0 <= tm)%Z -> launch_cap k tm v ->
  mode_credit k tm v <= PHI_A.
Proof.
  intros k tm v Hv Htm Hc. unfold PHI_A, GP_RESERVE.
  destruct k; simpl in Hc |- *; unfold GP_RESERVE, PHI_A.
  - unfold rise_credit. destruct (Rle_dec v 0); [ lra | ].
    unfold energy, EPS. assert ((v + 4 / 2) ^ 2 <= 2025) by nra. lra.
  - unfold rise_credit. destruct (Rle_dec v 0); [ lra | ].
    unfold energy, EPS. assert ((v + 2 / 2) ^ 2 <= 961) by nra. lra.
  - unfold rise_credit. destruct (Rle_dec v 0); [ lra | ].
    unfold energy, EPS. assert ((v + 4 / 2) ^ 2 <= 2916) by nra. lra.
  - destruct Hc as [Hc _]. unfold sk_bounced_credit, energy, EPS, SK_BONK.
    rewrite Rmax_right by lra.
    assert ((v + 2 / 2) ^ 2 <= 1482.25) by nra.
    destruct (Rle_dec v (-1)); lra.
  - pose proof (windup_left_le tm Htm). rewrite windup_left_0 in *. lra.
  - lra.
  - lra.
Qed.

(* -----------------------------------------------------------------------  *)
(* 3. The moves.                                                            *)
(* -----------------------------------------------------------------------  *)
Definition mode_gravity (k : mode) : R := match k with M_SlideKick | M_SlideKickBounced => 2 | _ => 4 end.

(* E3's mid-air action switches (docs/goal2-episode-graph-e3.md §2); pos,
   gfx.pos, floorHeight untouched, vel carried or zeroed *)
Inductive Switch (c c' : cells) : Prop :=
  (* -> AIR_HIT_WALL / BACKWARD_AIR_KB / SOFT_BONK / DIVE (plain air):
     vel carried, or `if (vel[1] > 0) vel[1] = 0` (airborne.c:780,975,1454,..) *)
  | Sw_plain :
      mode_of c <> M_Ground -> mode_of c' = M_Air -> R2 (c_vely c') <= R2 (c_vely c) ->
      (mode_of c <> M_Freefall -> mode_of c <> M_Air -> R2 (c_vely c') <= 0) ->
      Switch c c'
  (* -> FREEFALL: butt-slide-air / slide kick after actionTimer > 30
     (airborne.c:1437,1587), vel carried *)
  | Sw_freefall :
      mode_of c' = M_Freefall -> R2 (c_vely c') <= R2 (c_vely c) ->
      (mode_of c = M_Freefall \/ (c_action c = ACT_SLIDE_KICK /\ (30 <= timer_of c)%Z)) ->
      Switch c c'
  (* FREEFALL -Z-> GROUND_POUND, state 0, timer 0 (airborne.c:532) *)
  | Sw_gp :
      mode_of c = M_Freefall -> c_action c' = ACT_GROUND_POUND -> state_of c' = 0%Z -> timer_of c' = 0%Z ->
      Switch c c'.

Section Moves.
  (* ---- level data (WMotR), two named rows ------------------------------ *)
  (* wmotr_floor h: h is the height of a WMotR floor triangle at some (x, z).
     wmotr_gap: no floor height lies in the moat (K, K + 622)
     (tools/goal2_gapfact_check.py over the sloped triangles). *)
  Variable wmotr_floor : R -> Prop.
  Hypothesis wmotr_gap : forall h, wmotr_floor h -> ~ (PHI_K < h < PHI_K + GAP).
  (* wmotr_pole base top: a WMotR pole whose grab window starts at base - 160
     (mario_actions_automatic.c / interaction.c, docs/goal2-pole-window.md)
     and on which set_pole_position never puts Mario above top.  Every pole
     is either low (top <= K; WMotR's reachable pole tops at -1919) or out
     of reach (its window starts above YMAX; pole 4 at 2994). *)
  Variable wmotr_pole : R -> R -> Prop.
  Hypothesis wmotr_poles :
    forall base top, wmotr_pole base top -> top <= PHI_K \/ PHI_YMAX < base - 160.
  (* wmotr_cannon h: entering a WMotR cannon puts Mario at h (act_in_cannon
     state 0, pos[1] := cannon.y + 350; no input gate, only firing reads A).
     WMotR's two cannons seat Mario at 837 and -2730. *)
  Variable wmotr_cannon : R -> Prop.
  Hypothesis wmotr_cannons : forall h, wmotr_cannon h -> h <= PHI_K.

  (* what an attach may snap pos[1] up to *)
  Definition AttachOK (c : cells) (h : R) : Prop :=
    (mode_of c = M_Ground /\ h <= R2 (c_posy c))                    (* grounded: y <= K *)
    \/ (wmotr_floor h /\ h <= R2 (c_posy c) + STEP_UP)             (* landing, ledge grab *)
    \/ (c_action c = ACT_LEDGE_GRAB /\ h <= R2 (c_floorh c))        (* ledge climb *)
    \/ (exists base top, wmotr_pole base top                    (* pole grab / climb *)
          /\ base - 160 <= R2 (c_posy c) /\ h <= top)
    \/ wmotr_cannon h.                                             (* cannon entry *)

  Definition FloorRefreshOK (y fh : R) : Prop :=
    fh = -11000 \/ (wmotr_floor fh /\ fh <= y + STEP_UP).

  Inductive Move (c c' : cells) : Prop :=
  (* perform_air_step (mario_step.c:609-653): 4 quarter steps
     pos += vel/4, then apply_gravity (vel -= g, clamp -75), and gfx := pos.
     vel may end LOWER than gravity's (the jump-ascent vel /= 4). *)
  | S_air : forall gf,
      mode_of c = M_Freefall \/ mode_of c = M_SlideKick \/ mode_of c = M_Air ->
      F32 gf = true -> R2 gf = mode_gravity (mode_of c) ->
      c_action c' = c_action c -> c_state c' = c_state c ->
      c_posy c' = air_step_y (c_posy c) (c_vely c) ->
      R2 (c_vely c') <= R2 (gravity gf (c_vely c)) ->
      c_gfxy c' = c_posy c' ->
      (c_action c = ACT_SLIDE_KICK ->
         timer_of c' = (timer_of c + 1)%Z /\ c_vely c' = gravity gf (c_vely c)) ->
      Move c c'
  (* the same step cut by a ceiling (vel >= 0 zeroed, mario_step.c:446-452;
     the remaining quarters add 0) or any GP-state-1 fall; vel ends <= 0 *)
  | S_air_cut : forall n,
      mode_of c = M_Freefall \/ mode_of c = M_SlideKick \/ mode_of c = M_Air \/ mode_of c = M_PoundFall ->
      (n <= 4)%nat ->
      c_action c' = c_action c -> c_state c' = c_state c ->
      c_posy c' = quarter_steps n (c_posy c) (Float32.div (c_vely c) f4) ->
      R2 (c_vely c') <= 0 ->
      c_gfxy c' = c_posy c' ->
      (c_action c = ACT_SLIDE_KICK ->
         0 <= R2 (c_vely c) /\ R2 (c_vely c') = -2 /\ timer_of c' = (timer_of c + 1)%Z) ->
      Move c c'
  (* post-bounce slide kick air step (g = 2), exact *)
  | S_sk_bounced :
      mode_of c = M_SlideKickBounced ->
      c_action c' = c_action c -> c_state c' = c_state c ->
      c_posy c' = air_step_y (c_posy c) (c_vely c) -> c_vely c' = gravity f2 (c_vely c) ->
      timer_of c' = (timer_of c + 1)%Z -> c_gfxy c' = c_posy c' ->
      Move c c'
  | S_sk_bounced_cut : forall n,
      mode_of c = M_SlideKickBounced -> (n <= 4)%nat ->
      c_action c' = c_action c -> c_state c' = c_state c ->
      0 <= R2 (c_vely c) ->
      c_posy c' = quarter_steps n (c_posy c) (Float32.div (c_vely c) f4) -> R2 (c_vely c') = -2 ->
      timer_of c' = (timer_of c + 1)%Z -> c_gfxy c' = c_posy c' ->
      Move c c'
  (* act_ground_pound state 0, timer < 10 (airborne.c:925-938):
     pos[1] += 20 - 2*timer; vel := -50; timer++ (state may turn 1) *)
  | S_gp_windup : forall o,
      mode_of c = M_PoundWindup -> (timer_of c < 10)%Z ->
      c_action c' = ACT_GROUND_POUND ->
      F32 o = true -> R2 o = IZR (20 - 2 * timer_of c) ->
      c_posy c' = Float32.add (c_posy c) o -> R2 (c_vely c') = -50 ->
      timer_of c' = (timer_of c + 1)%Z -> c_gfxy c' = c_posy c' ->
      Move c c'
  (* the same frame with the add skipped (ceiling test fails, or timer >= 10) *)
  | S_gp_hold :
      mode_of c = M_PoundWindup -> c_action c' = ACT_GROUND_POUND ->
      c_posy c' = c_posy c -> R2 (c_vely c') = -50 ->
      timer_of c' = (timer_of c + 1)%Z -> c_gfxy c' = c_gfxy c ->
      Move c c'
  | S_switch :
      c_posy c' = c_posy c -> c_gfxy c' = c_gfxy c -> c_floorh c' = c_floorh c ->
      Switch c c' ->
      Move c c'
  (* attach: landing / bounce (pos := floorHeight, airborne.c:1444,1602),
     ledge grab (pos := ledgePos, mario_step.c:371-377), ledge climb, pole
     (set_pole_position), cannon entry (act_in_cannon), a ground step, or a
     launch from the ground;
     the new vel within the mode's cap *)
  | S_attach : forall h,
      AttachOK c h -> R2 (c_posy c') <= h ->
      (c_gfxy c' = c_posy c' \/ (c_gfxy c' = c_gfxy c /\ mode_of c = M_Ground)) ->
      launch_cap (mode_of c') (timer_of c') (R2 (c_vely c')) ->
      (c_action c' = ACT_LEDGE_GRAB -> AttachOK c (R2 (c_floorh c'))) ->
      Move c c'
  (* update_mario_geometry_inputs: floorHeight := find_floor (mario.c:1320) *)
  | S_refresh :
      c_action c' = c_action c -> c_state c' = c_state c -> c_timer c' = c_timer c ->
      c_posy c' = c_posy c -> c_vely c' = c_vely c -> c_gfxy c' = c_gfxy c ->
      FloorRefreshOK (R2 (c_posy c)) (R2 (c_floorh c')) ->
      Move c c'
  (* OOB recovery: pos := gfx.pos, then find_floor again (mario.c:1327-1329) *)
  | S_oob :
      c_action c' = c_action c -> c_state c' = c_state c -> c_timer c' = c_timer c ->
      c_vely c' = c_vely c -> c_posy c' = c_gfxy c -> c_gfxy c' = c_gfxy c ->
      FloorRefreshOK (R2 (c_gfxy c)) (R2 (c_floorh c')) ->
      Move c c'.

  Definition RangedMove (c c' : cells) : Prop := InRange c' /\ Move c c'.
  Definition MoveChain : cells -> cells -> Prop := clos_refl_trans cells RangedMove.

  (* ---- the proofs ------------------------------------------------------- *)
  Lemma attach_le_K : forall c h, budget_ok c -> AttachOK c h -> h <= PHI_K.
  Proof.
    intros c h Hc Ha.
    pose proof (budget_ok_y c Hc) as Hy.
    destruct Hc as (_ & Hb & _ & _ & _ & Hl).
    rewrite credit_of_mode in Hb.
    destruct Ha as [[Hk Hh] | [[Hf Hh] | [[Ha Hh] | [(base & top & Hp & Hw & Hh) | Hcn]]]].
    - rewrite Hk in Hb. simpl in Hb. lra.
    - apply (gap_fact_step h (R2 (c_posy c)) (mode_credit (mode_of c) (timer_of c) (R2 (c_vely c))));
        [ exact Hh | | exact Hb | apply wmotr_gap; exact Hf ].
      rewrite <- credit_of_mode. apply credit_nonneg.
    - specialize (Hl Ha). lra.
    - destruct (wmotr_poles base top Hp); lra.
    - exact (wmotr_cannons h Hcn).
  Qed.

  Lemma floor_refresh_ledge : forall c y fh,
    budget_ok c -> y + credit_of c <= PHI_K + PHI_A -> FloorRefreshOK y fh -> fh <= PHI_K.
  Proof.
    intros c y fh Hc Hb [H | [Hf Hh]].
    - unfold PHI_K. lra.
    - apply (gap_fact_step fh y (credit_of c)); auto.
      apply credit_nonneg.
  Qed.

  (* the switch never raises the credit (y is unchanged) *)
  Lemma switch_credit : forall c c', budget_ok c -> InRange c' -> Switch c c' -> credit_of c' <= credit_of c.
  Proof.
    intros c c' Hc Hr' Hs.
    pose proof Hc as (Hr & _ & _ & Hsk & _).
    destruct Hr as (_ & _ & _ & _ & _ & Hv).
    destruct Hr' as (_ & _ & _ & _ & _ & Hv').
    rewrite !credit_of_mode.
    assert (B4 : forall a b, a <= b -> rise_credit 4 a <= rise_credit 4 b) by (intros; apply rise_credit_mono; lra).
    pose proof (rise_credit_nonneg 4 (R2 (c_vely c)) ltac:(lra)).
    pose proof (rise_credit_nonneg 2 (R2 (c_vely c)) ltac:(lra)).
    pose proof (sk_bounced_credit_nonneg (R2 (c_vely c))).
    pose proof (windup_left_nonneg (timer_of c)).
    unfold GP_RESERVE, PHI_A in *.
    destruct Hs as [Hk Hk' Hle Hz | Hk' Hle Hsrc | Hk Ha' Hst' Htm'].
    - rewrite Hk'. simpl.
      assert (HB : rise_credit 4 (R2 (c_vely c')) <= rise_credit 4 (R2 (c_vely c))) by (apply B4; exact Hle).
      destruct (mode_of c) eqn:E; simpl; unfold GP_RESERVE, PHI_A;
        first [ exfalso; congruence | lra
              | (rewrite (rise_credit_nonpos 4 (R2 (c_vely c'))) by (apply Hz; congruence); lra) ].
    - rewrite Hk'. simpl.
      destruct Hsrc as [Hk | [Ha Ht]].
      + rewrite Hk. simpl. specialize (B4 _ _ Hle). lra.
      + (* slide kick after 30 ticks: vel below -22.4, so the reserve is paid *)
        specialize (Hsk Ha).
        assert (Hd : R2 (c_vely c) <= -22.4).
        { apply (sk_clause_descending (R2 (c_vely c)) (IZR (timer_of c)));
            [ apply IZR_le in Ht; exact Ht | exact Hsk ]. }
        rewrite (rise_credit_nonpos 4 (R2 (c_vely c'))) by lra.
        destruct (mode_slide_kick (c_action c) (state_of c) Ha) as [E | E]; fold (mode_of c) in E; rewrite E; simpl.
        * rewrite (rise_credit_nonpos 2) by lra. lra.
        * unfold GP_RESERVE, sk_bounced_credit, energy, EPS, SK_BONK.
          rewrite Rmax_right by lra.
          destruct (Rle_dec (R2 (c_vely c)) (-1)); [ | lra ].
          assert ((R2 (c_vely c) + 2 / 2) ^ 2 >= 457) by nra.
          lra.
    - unfold mode_of at 1. rewrite Ha', Hst', Htm'.
      replace (mode_of_action ACT_GROUND_POUND 0) with M_PoundWindup by (vm_compute; reflexivity).
      rewrite Hk. simpl.
      pose proof windup_left_0_le. unfold GP_RESERVE in *. lra.
  Qed.

  (* ---- per-move preservation ------------------------------------------- *)
  Lemma mode_of_action_SK_eq : forall st,
    mode_of_action ACT_SLIDE_KICK st = if Z.eqb st 0 then M_SlideKick else M_SlideKickBounced.
  Proof. reflexivity. Qed.

  Lemma mode_of_action_GP_eq : forall st,
    mode_of_action ACT_GROUND_POUND st = if Z.eqb st 0 then M_PoundWindup else M_PoundFall.
  Proof. reflexivity. Qed.

  Lemma mode_of_same : forall c c', c_action c' = c_action c -> c_state c' = c_state c -> mode_of c' = mode_of c.
  Proof. intros c c' Ha Hs. unfold mode_of, state_of. rewrite Ha, Hs. reflexivity. Qed.

  Lemma mode_credit_rise : forall k tm v, k = M_Freefall \/ k = M_SlideKick \/ k = M_Air ->
    mode_credit k tm v = rise_credit (mode_gravity k) v + match k with M_Air => 0 | _ => GP_RESERVE end.
  Proof. intros k tm v [-> | [-> | ->]]; simpl; ring. Qed.

  Lemma tm_nonneg : forall c, (0 <= timer_of c)%Z.
  Proof. intros c. unfold timer_of. pose proof (Int.unsigned_range (c_timer c)). lia. Qed.

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

  Lemma y_hi : forall c, budget_ok c -> R2 (c_posy c) <= 2796.
  Proof. intros c H. pose proof (budget_ok_y c H). unfold PHI_YMAX, PHI_K, PHI_A in *. lra. Qed.

  Lemma not_ledge_air : forall c, mode_of c <> M_Ground -> c_action c <> ACT_LEDGE_GRAB.
  Proof. intros c Hk Ha. apply Hk. unfold mode_of. apply (mode_of_action_inv (c_action c) (state_of c)). exact Ha. Qed.

  Lemma not_SK : forall c, mode_of c <> M_SlideKick -> mode_of c <> M_SlideKickBounced -> c_action c <> ACT_SLIDE_KICK.
  Proof.
    intros c H0 H1 Ha. destruct (mode_slide_kick (c_action c) (state_of c) Ha); fold (mode_of c) in *; congruence.
  Qed.

  Lemma not_GP : forall c, mode_of c <> M_PoundWindup -> mode_of c <> M_PoundFall -> c_action c <> ACT_GROUND_POUND.
  Proof.
    intros c H0 H1 Ha. destruct (mode_ground_pound (c_action c) (state_of c) Ha); fold (mode_of c) in *; congruence.
  Qed.

  (* the three side clauses hold vacuously for a target of a plain mode *)
  Lemma sides_plain : forall c', mode_of c' = M_Freefall \/ mode_of c' = M_Air ->
    (c_action c' = ACT_SLIDE_KICK -> False)
    /\ (c_action c' = ACT_GROUND_POUND -> False)
    /\ (c_action c' = ACT_LEDGE_GRAB -> False).
  Proof.
    intros c' Hk. repeat split; intros Ha.
    - apply (not_SK c'); [ | | exact Ha ]; destruct Hk; congruence.
    - apply (not_GP c'); [ | | exact Ha ]; destruct Hk; congruence.
    - apply (not_ledge_air c'); [ | exact Ha ]; destruct Hk; congruence.
  Qed.

  Theorem move_keeps_budget : forall c c', budget_ok c -> InRange c' -> Move c c' -> budget_ok c'.
  Proof.
    intros c c' Hc Hr' Hs.
    pose proof (y_hi c Hc) as Hyhi.
    pose proof Hc as Hc0.
    dphi Hc.
    assert (Hy16 : Rabs (R2 (c_posy c)) <= 16000) by (apply Rabs_le; split; lra).
    assert (Hv128 : Rabs (R2 (c_vely c)) <= 128) by (apply Rabs_le; split; lra).
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
      assert (Hk' : mode_of c' = mode_of c) by (apply mode_of_same; auto).
      assert (Hg4 : R2 gf = 2 \/ R2 gf = 4)
        by (rewrite Hgf; destruct Hk as [E | [E | E]]; rewrite E; simpl; auto).
      destruct (ballistic_frame gf (c_posy c) (c_vely c) Fgf Fy Fv Hg4 Hy16 Hv128) as [_ Hbf].
      rewrite <- Hy' in Hbf.
      assert (Hmono : rise_credit (R2 gf) (R2 (c_vely c')) <= rise_credit (R2 gf) (R2 (gravity gf (c_vely c))))
        by (apply rise_credit_mono; [ destruct Hg4; lra | exact Hv' ]).
      assert (Hcr : R2 (c_posy c') + credit_of c' <= R2 (c_posy c) + credit_of c).
      { rewrite !credit_of_mode, Hk'. rewrite !(mode_credit_rise (mode_of c)) by exact Hk. rewrite <- Hgf. lra. }
      split; [ lra | split; [ rewrite Hgy'; lra | split; [ | split ] ] ].
      + intros Ha'. rewrite Ha in Ha'. destruct (Hskp Ha') as [Ht Hvv].
        destruct (mode_slide_kick (c_action c) (state_of c) Ha') as [E | E]; fold (mode_of c) in E;
          [ | exfalso; destruct Hk as [? | [? | ?]]; congruence ].
        rewrite E in Hgf. simpl in Hgf.
        pose proof (gravity_spec2 gf (c_vely c) Fgf Fv (or_introl Hgf) Hv128) as Hgr.
        rewrite Hgf, <- Hvv in Hgr.
        rewrite Ht. exact (sk_clause_step _ _ _ (Hsk Ha') Hgr).
      + intros Ha'. exfalso. rewrite Ha in Ha'.
        apply (not_GP c); [ | | exact Ha' ]; destruct Hk as [? | [? | ?]]; congruence.
      + intros Ha'. exfalso. rewrite Ha in Ha'.
        apply (not_ledge_air c); [ | exact Ha' ]; destruct Hk as [? | [? | ?]]; congruence.
    - (* S_air_cut *)
      assert (Hk' : mode_of c' = mode_of c) by (apply mode_of_same; auto).
      destruct (quarter_steps_up n (c_posy c) (c_vely c) Hn Fy Fv Hy16 Hv128) as (_ & Hup & Hdn & _).
      rewrite <- Hy' in Hup, Hdn.
      assert (Hcr : R2 (c_posy c') + credit_of c' <= R2 (c_posy c) + credit_of c).
      { rewrite !credit_of_mode, Hk'.
        destruct Hk as [E | [E | [E | E]]]; rewrite E; simpl;
          try (apply Rplus_le_compat_r || idtac);
          try (apply rise_credit_cut; [ lra | exact Hup | exact Hdn | exact Hv' ]).
        - pose proof (rise_credit_cut 4 _ _ _ _ ltac:(lra) Hup Hdn Hv'). lra.
        - pose proof (rise_credit_cut 2 _ _ _ _ ltac:(lra) Hup Hdn Hv'). lra.
        - (* GP state 1 falls *)
          assert (Hga : c_action c = ACT_GROUND_POUND)
            by (apply (proj1 (proj2 (mode_of_action_inv (c_action c) (state_of c)))); right; exact E).
          assert (Hst0 : state_of c <> 0%Z)
            by (apply (proj1 (proj2 (proj2 (mode_of_action_inv (c_action c) (state_of c))))); right; exact E).
          specialize (Hgp Hga Hst0). specialize (Hdn Hgp). lra. }
      split; [ lra | split; [ rewrite Hgy'; lra | split; [ | split ] ] ].
      + intros Ha'. rewrite Ha in Ha'. destruct (Hskp Ha') as (Hv0 & Hv2 & Ht).
        rewrite Ht, Hv2. exact (sk_clause_cut _ _ Hv0 (Hsk Ha')).
      + intros Ha' Hst'. exact Hv'.
      + intros Ha'. exfalso. rewrite Ha in Ha'.
        apply (not_ledge_air c); [ | exact Ha' ]; destruct Hk as [? | [? | [? | ?]]]; congruence.
    - (* S_sk_bounced *)
      assert (Hk' : mode_of c' = mode_of c) by (apply mode_of_same; auto).
      pose proof (sk_bounced_frame (c_posy c) (c_vely c) Fy Fv Hy16 (conj Hvlo Hvhi)) as Hf.
      rewrite <- Hy', <- Hv' in Hf.
      assert (Hcr : R2 (c_posy c') + credit_of c' <= R2 (c_posy c) + credit_of c)
        by (rewrite !credit_of_mode, Hk', Hk; simpl; exact Hf).
      assert (Ha0 : c_action c = ACT_SLIDE_KICK)
        by (apply (proj1 (mode_of_action_inv (c_action c) (state_of c))); right; exact Hk).
      split; [ lra | split; [ rewrite Hgy'; lra | split; [ | split ] ] ].
      + intros _. rewrite Htm'.
        pose proof (gravity_spec2 f2 (c_vely c) F32_f2 Fv (or_introl B2R_f2) Hv128) as Hgr.
        rewrite B2R_f2, <- Hv' in Hgr.
        exact (sk_clause_step _ _ _ (Hsk Ha0) Hgr).
      + intros Ha'. exfalso. rewrite Ha, Ha0 in Ha'. discriminate.
      + intros Ha'. exfalso. rewrite Ha, Ha0 in Ha'. discriminate.
    - (* S_sk_bounced_cut *)
      assert (Hk' : mode_of c' = mode_of c) by (apply mode_of_same; auto).
      destruct (quarter_steps_up n (c_posy c) (c_vely c) Hn Fy Fv Hy16 Hv128) as (_ & Hup & _ & _).
      rewrite <- Hy' in Hup. specialize (Hup Hv0).
      pose proof (sk_bounced_ceil _ _ _ Hv0 Hup) as Hf.
      assert (Hcr : R2 (c_posy c') + credit_of c' <= R2 (c_posy c) + credit_of c)
        by (rewrite !credit_of_mode, Hk', Hk; simpl; rewrite Hv'; exact Hf).
      assert (Ha0 : c_action c = ACT_SLIDE_KICK)
        by (apply (proj1 (mode_of_action_inv (c_action c) (state_of c))); right; exact Hk).
      split; [ lra | split; [ rewrite Hgy'; lra | split; [ | split ] ] ].
      + intros _. rewrite Htm', Hv'. exact (sk_clause_cut _ _ Hv0 (Hsk Ha0)).
      + intros Ha'. exfalso. rewrite Ha, Ha0 in Ha'. discriminate.
      + intros Ha'. exfalso. rewrite Ha, Ha0 in Ha'. discriminate.
    - (* S_gp_windup *)
      assert (Hoz : R2 o = 20 - 2 * IZR (timer_of c))
        by (rewrite Ho, minus_IZR, mult_IZR; reflexivity).
      assert (Htm10 : IZR (timer_of c) <= 9) by (apply IZR_le; lia).
      assert (Htm00 : 0 <= IZR (timer_of c)) by (apply IZR_le; lia).
      destruct (windup_add (c_posy c) o Fy Fo ltac:(lra) ltac:(lra)) as [_ Hwa].
      rewrite <- Hy' in Hwa.
      pose proof (gp_windup_frame 0 (timer_of c) ltac:(lia)) as Hwf.
      pose proof (windup_left_nonneg (timer_of c + 1)) as Hw1.
      assert (Hcr : R2 (c_posy c') + credit_of c' <= R2 (c_posy c) + credit_of c).
      { rewrite !credit_of_mode, Hk. unfold mode_of. rewrite Ha, mode_of_action_GP_eq, Htm'. simpl.
        destruct (Z.eqb (state_of c') 0); simpl; lra. }
      split; [ lra | split; [ rewrite Hgy'; lra | split; [ | split ] ] ].
      + intros Ha'. rewrite Ha in Ha'. discriminate.
      + intros _ _. lra.
      + intros Ha'. rewrite Ha in Ha'. discriminate.
    - (* S_gp_hold *)
      pose proof (windup_left_mono (timer_of c) Htm0) as Hwm.
      pose proof (windup_left_nonneg (timer_of c + 1)) as Hw1.
      assert (Hcr : credit_of c' <= credit_of c).
      { rewrite !credit_of_mode, Hk. unfold mode_of. rewrite Ha, mode_of_action_GP_eq, Htm'. simpl.
        destruct (Z.eqb (state_of c') 0); simpl; lra. }
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
      pose proof (attach_le_K c h Hc0 Han) as HhK.
      assert (Hca : credit_of c' <= PHI_A)
        by (rewrite credit_of_mode; apply launch_cap_credit; [ exact Hvlo' | exact Htm0' | exact Hcap ]).
      pose proof (credit_nonneg (c_action c') (state_of c') (timer_of c') (R2 (c_vely c'))) as Hc'0.
      fold (credit_of c') in Hc'0.
      split; [ lra | split; [ | split; [ | split ] ] ].
      + destruct Hgy' as [-> | [-> Hkg]]; [ lra | ].
        rewrite credit_of_mode, Hkg in Hgb. simpl in Hgb. lra.
      + intros Ha'.
        destruct (mode_slide_kick (c_action c') (state_of c') Ha') as [E | E]; fold (mode_of c') in E;
          rewrite E in Hcap; simpl in Hcap; left.
        * destruct Hcap as [Hc1 ->]. simpl. lra.
        * destruct Hcap as [Hc1 ->]. simpl. lra.
      + intros Ha' Hst'.
        destruct (mode_ground_pound (c_action c') (state_of c') Ha') as [E | E]; fold (mode_of c') in E.
        * exfalso. apply Hst'.
          apply (proj1 (proj2 (proj2 (proj2 (mode_of_action_inv (c_action c') (state_of c')))))). right. exact E.
        * rewrite E in Hcap. exact Hcap.
      + intros Ha'. exact (attach_le_K c _ Hc0 (Hla Ha')).
    - (* S_refresh *)
      assert (Hcr : credit_of c' = credit_of c) by (unfold credit_of, state_of, timer_of; rewrite Ha, Hst, Htmc, Hv'; reflexivity).
      split; [ rewrite Hy', Hcr; lra | split; [ rewrite Hgy', Hcr; lra | split; [ | split ] ] ].
      + intros Ha'. unfold timer_of. rewrite Hv', Htmc. rewrite Ha in Ha'. exact (Hsk Ha').
      + intros Ha' Hst'. rewrite Hv'. rewrite Ha in Ha'. unfold state_of in *. rewrite Hst in Hst'.
        exact (Hgp Ha' Hst').
      + intros _. exact (floor_refresh_ledge c _ _ Hc0 Hb Hrf).
    - (* S_oob *)
      assert (Hcr : credit_of c' = credit_of c) by (unfold credit_of, state_of, timer_of; rewrite Ha, Hst, Htmc, Hv'; reflexivity).
      split; [ rewrite Hy', Hcr; lra | split; [ rewrite Hgy', Hcr; lra | split; [ | split ] ] ].
      + intros Ha'. unfold timer_of. rewrite Hv', Htmc. rewrite Ha in Ha'. exact (Hsk Ha').
      + intros Ha' Hst'. rewrite Hv'. rewrite Ha in Ha'. unfold state_of in *. rewrite Hst in Hst'.
        exact (Hgp Ha' Hst').
      + intros _. exact (floor_refresh_ledge c _ _ Hc0 Hgb Hrf).
  Qed.

  Theorem chain_keeps_budget : forall c c', budget_ok c -> MoveChain c c' -> budget_ok c'.
  Proof.
    intros c c' Hc Hm. induction Hm as [ x y [Hr Hs] | x | x y z _ IH1 _ IH2 ].
    - exact (move_keeps_budget x y Hc Hr Hs).
    - exact Hc.
    - exact (IH2 (IH1 Hc)).
  Qed.
End Moves.
