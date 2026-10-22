(* PoleFast (GOAL 2): the walk of the real act_grab_pole_fast, computed once
   on the link (every outcome passes PoleRun.pk_ok) *)
From Coq Require Import ZArith.
From SM64.Generated Require mario_actions_automatic.
From SM64.Proofs.WMotRRequiresA Require Import PoleRun.

Lemma fastcheck12 : pole_walk 1049410%Z mario_actions_automatic.f_act_grab_pole_fast = true.
Proof. vm_cast_no_check (eq_refl true). Qed.  (* computed once, by the kernel *)
