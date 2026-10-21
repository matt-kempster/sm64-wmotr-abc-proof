(* ====================================================================== *)
(* KbDv (GOAL 2): the KbRun walk of the real act_dive, on the link.        *)
(* One walk per file, so the walks build in parallel.  vm_cast_no_check: *)
(* the kernel computes the walk once, at Qed.                             *)
(* ====================================================================== *)

From compcert Require Import Coqlib.
From SM64.Generated Require mario_actions_airborne.
From SM64.Proofs.WMotRRequiresA Require Import KbRun.

Lemma dvcheck12 : kb_walk 25692298 mario_actions_airborne.f_act_dive = true.
Proof. vm_cast_no_check (eq_refl true). Qed.
