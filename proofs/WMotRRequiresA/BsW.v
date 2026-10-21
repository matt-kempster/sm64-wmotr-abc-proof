(* ====================================================================== *)
(* BsW (GOAL 2): the BsRun walk of the real act_butt_slide_air, on the    *)
(* link.  One walk per file, so the walks build in parallel.              *)
(* vm_cast_no_check: the kernel computes the walk once, at Qed.           *)
(* ====================================================================== *)

From compcert Require Import Coqlib.
From SM64.Generated Require mario_actions_airborne.
From SM64.Proofs.WMotRRequiresA Require Import BsRun.

Lemma bscheck12 : bs_walk mario_actions_airborne.f_act_butt_slide_air = true.
Proof. vm_cast_no_check (eq_refl true). Qed.
