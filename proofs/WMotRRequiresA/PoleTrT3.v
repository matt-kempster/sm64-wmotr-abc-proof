(* PoleTrT3 (GOAL 2): the walk of the real act_top_of_pole_transition
   started with neither handstand animation 11 nor 12 loaded
   (PoleStartT.avars), computed once on the link (every outcome passes
   PoleRunT.pk_okT): set_mario_animation loads the one it picks. *)
From Coq Require Import ZArith.
From SM64.Generated Require mario_actions_automatic.
From SM64.Proofs.WMotRRequiresA Require Import PoleRunT.

Lemma trT_r : pole_walkT 1049412%Z (AR (11%Z :: 12%Z :: nil))
                mario_actions_automatic.f_act_top_of_pole_transition = true.
Proof. vm_cast_no_check (eq_refl true). Qed.  (* computed once, by the kernel *)
