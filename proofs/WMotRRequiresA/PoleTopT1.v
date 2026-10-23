(* PoleTopT1 (GOAL 2): the walk of the real act_top_of_pole started with
   handstand animation 9 loaded (PoleStartT.avars), computed once on the
   link (every outcome passes PoleRunT.pk_okT).  The handler sets
   MARIO_ANIM_HANDSTAND_IDLE, then set_pole_position with the animation's
   y translation (RytXc.c_ryt). *)
From Coq Require Import ZArith.
From SM64.Generated Require mario_actions_automatic.
From SM64.Proofs.WMotRRequiresA Require Import PoleRunT.

Lemma topT_l9 : pole_walkT 1049413%Z (AL 9%Z) mario_actions_automatic.f_act_top_of_pole = true.
Proof. vm_cast_no_check (eq_refl true). Qed.  (* computed once, by the kernel *)
