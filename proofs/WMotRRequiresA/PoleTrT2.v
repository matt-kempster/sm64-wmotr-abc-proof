(* PoleTrT2 (GOAL 2): the walk of the real act_top_of_pole_transition
   started with handstand animation 12 loaded (PoleStartT.avars), computed
   once on the link (every outcome passes PoleRunT.pk_okT). *)
From Coq Require Import ZArith.
From SM64.Generated Require mario_actions_automatic.
From SM64.Proofs.WMotRRequiresA Require Import PoleRunT.

Lemma trT_l12 : pole_walkT 1049412%Z (AL 12%Z) mario_actions_automatic.f_act_top_of_pole_transition = true.
Proof. vm_cast_no_check (eq_refl true). Qed.  (* computed once, by the kernel *)
