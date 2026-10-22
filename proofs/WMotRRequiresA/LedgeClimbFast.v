(* LedgeClimbFast: the walk of the real f_act_ledge_climb_fast on the link (LedgeRun.ledge_walk), action 1359. *)
From Coq Require Import ZArith.
From compcert Require Import Clight.
Local Open Scope Z_scope.
From SM64.Generated Require mario_actions_automatic.
From SM64.Proofs.WMotRRequiresA Require Import LedgeRun.

Lemma lcfastcheck12 : ledge_walk 1359 mario_actions_automatic.f_act_ledge_climb_fast = true.
Proof. vm_cast_no_check (eq_refl true). Qed.
