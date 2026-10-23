(* CannonWalk (GOAL 2): the walk of the real act_in_cannon, computed once
   per WMotR cannon on the link (every outcome passes CannonRun.ck_ok).
   The cannon's oPosY is the known cell, so the seat (oPosY + 350) folds to
   the cannon's base height; m->input's A bits are clear, so the shot is
   pruned. *)
From Coq Require Import ZArith.
From SM64.Generated Require mario_actions_automatic.
From SM64.Proofs.WMotRRequiresA Require Import CannonRun.

Lemma cannoncheck837 : cannon_walk 4977%Z 837%Z mario_actions_automatic.f_act_in_cannon = true.
Proof. vm_cast_no_check (eq_refl true). Qed.  (* computed once, by the kernel *)

Lemma cannoncheck2730 : cannon_walk 4977%Z (-2730)%Z mario_actions_automatic.f_act_in_cannon = true.
Proof. vm_cast_no_check (eq_refl true). Qed.  (* computed once, by the kernel *)
