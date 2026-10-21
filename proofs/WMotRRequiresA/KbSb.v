(* ====================================================================== *)
(* KbSb (GOAL 2): the KbRun walk of the real act_soft_bonk, on the link.        *)
(* One walk per file, so the walks build in parallel.  vm_cast_no_check: *)
(* the kernel computes the walk once, at Qed.                             *)
(* ====================================================================== *)

From compcert Require Import Coqlib.
From SM64.Generated Require mario_actions_airborne.
From SM64.Proofs.WMotRRequiresA Require Import KbRun.

Lemma sbcheck12 : kb_walk 16910518 mario_actions_airborne.f_act_soft_bonk = true.
Proof. vm_cast_no_check (eq_refl true). Qed.
