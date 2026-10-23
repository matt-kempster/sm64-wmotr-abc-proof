(* PoleFastT (GOAL 2): the walk of the real act_grab_pole_fast (nothing
   known of the animation state, PoleStartT.avars), computed once on the
   link (every outcome passes PoleRunT.pk_okT). *)
From Coq Require Import ZArith.
From SM64.Generated Require mario_actions_automatic.
From SM64.Proofs.WMotRRequiresA Require Import PoleRunT.

Lemma fastT : pole_walkT 1049410%Z (AU false) mario_actions_automatic.f_act_grab_pole_fast = true.
Proof. vm_cast_no_check (eq_refl true). Qed.  (* computed once, by the kernel *)
