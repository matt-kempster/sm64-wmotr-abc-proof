(* ====================================================================== *)
(* KbBkb (GOAL 2): the KbRun walk of the real act_backward_air_kb, on the link.        *)
(* One walk per file, so the walks build in parallel.  vm_cast_no_check: *)
(* the kernel computes the walk once, at Qed.                             *)
(* ====================================================================== *)

From compcert Require Import Coqlib.
From SM64.Generated Require mario_actions_airborne.
From SM64.Proofs.WMotRRequiresA Require Import KbRun.

Lemma bkbcheck12 : kb_walk 16910512 mario_actions_airborne.f_act_backward_air_kb = true.
Proof. vm_cast_no_check (eq_refl true). Qed.
