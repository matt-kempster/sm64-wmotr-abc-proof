(* CannonWalk (GOAL 2): the walk of the real act_in_cannon, computed on
   the link at every seat of WMotRLevel.wmotr_cannon_list (every outcome
   passes CannonRun.ck_ok): each home seat (837, -2730) + 5k, k = 0..69, as
   the base rises in opened_cannon_act_4 (FOUND 2026-10-24).  The cannon's
   oPosY is the known cell, so the seat (oPosY + 350) folds to a constant;
   m->input's A bits are clear, so the shot is pruned. *)
From Coq Require Import ZArith List.
From SM64.Generated Require mario_actions_automatic.
From SM64.Proofs Require Import WMotRLevel.
From SM64.Proofs.WMotRRequiresA Require Import CannonRun.
Import ListNotations.

Definition seats_of (y : Z) : list Z :=
  map (fun k : nat => (y + CANNON_RISE * Z.of_nat k)%Z) (seq 0 CANNON_RISE_STEPS).

Lemma cannoncheck837 :
  cannon_walk_all 4977%Z (seats_of 837%Z) mario_actions_automatic.f_act_in_cannon = true.
Proof. vm_cast_no_check (eq_refl true). Qed.  (* computed once, by the kernel *)

Lemma cannoncheck2730 :
  cannon_walk_all 4977%Z (seats_of (-2730)%Z) mario_actions_automatic.f_act_in_cannon = true.
Proof. vm_cast_no_check (eq_refl true). Qed.  (* computed once, by the kernel *)

Lemma cannon_list_seats : wmotr_cannon_list = seats_of 837%Z ++ seats_of (-2730)%Z.
Proof. unfold wmotr_cannon_list. rewrite cannon_homes_value.
  cbn [flat_map]. rewrite app_nil_r. reflexivity. Qed.

Lemma cannoncheck_all : forall yc, In yc wmotr_cannon_list ->
  cannon_walk 4977%Z yc mario_actions_automatic.f_act_in_cannon = true.
Proof.
  intros yc Hy. rewrite cannon_list_seats in Hy. apply in_app_or in Hy as [Hy | Hy].
  - exact (cannon_walk_of_all _ _ _ _ cannoncheck837 Hy).
  - exact (cannon_walk_of_all _ _ _ _ cannoncheck2730 Hy).
Qed.
