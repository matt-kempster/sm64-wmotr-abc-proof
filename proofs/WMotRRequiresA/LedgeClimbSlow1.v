(* LedgeClimbSlow1: the walk of the real f_act_ledge_climb_slow on the link (LedgeRun.ledge_walk), action 1356. *)
From Coq Require Import ZArith.
From compcert Require Import Clight.
Local Open Scope Z_scope.
From SM64.Generated Require mario_actions_automatic.
From SM64.Proofs.WMotRRequiresA Require Import LedgeRun.

Lemma lcslow1check12 : ledge_walk 1356 mario_actions_automatic.f_act_ledge_climb_slow = true.
Proof. vm_cast_no_check (eq_refl true). Qed.
