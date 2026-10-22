(* ====================================================================== *)
(* SbRet0Walk (GOAL 2): the SbRet0 walk of the real act_soft_bonk (every  *)
(* outcome returns 0), on the link.  One walk per file; vm_cast_no_check: *)
(* the kernel computes the walk once, at Qed.                             *)
(* ====================================================================== *)

From compcert Require Import Coqlib.
From SM64.Generated Require mario_actions_airborne.
From SM64.Proofs.WMotRRequiresA Require Import SbRet0.

Lemma sb0check12 : kb_walk0 16910518 mario_actions_airborne.f_act_soft_bonk = true.
Proof. vm_cast_no_check (eq_refl true). Qed.
