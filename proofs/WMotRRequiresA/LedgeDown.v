(* LedgeDown: the walk of the real f_act_ledge_climb_down on the link (LedgeRun.ledge_walk). *)
From Coq Require Import ZArith.
From compcert Require Import Clight.
Local Open Scope Z_scope.
From SM64.Generated Require mario_actions_automatic.
From SM64.Proofs.WMotRRequiresA Require Import LedgeRun.

Lemma lcdcheck12 : ledge_walk 1358 mario_actions_automatic.f_act_ledge_climb_down = true.
Proof. vm_cast_no_check (eq_refl true). Qed.
