(* PoleSlow (GOAL 2): the walk of the real act_grab_pole_slow, computed once
   on the link (every outcome passes PoleRun.pk_ok) *)
From Coq Require Import ZArith.
From SM64.Generated Require mario_actions_automatic.
From SM64.Proofs.WMotRRequiresA Require Import PoleRun.

Lemma slowcheck12 : pole_walk 1049409%Z mario_actions_automatic.f_act_grab_pole_slow = true.
Proof. vm_cast_no_check (eq_refl true). Qed.  (* computed once, by the kernel *)
