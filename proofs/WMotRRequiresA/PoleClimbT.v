(* PoleClimbT (GOAL 2): the walk of the real act_climbing_pole from
   AnimWorld.anim_st (PoleStartT.avars), computed once on the link (every
   outcome passes PoleRunT.pk_okT).  The handler climbs oMarioPolePos +=
   stickY / 8.0f past !(stickY < 8.0f) (PoleClass.climb: the find_ceil
   cast makes the climb finite), sets the climb animation
   (set_mario_anim_with_accel, walked inline) and plays the climbing
   sounds (audio). *)
From Coq Require Import ZArith.
From SM64.Generated Require mario_actions_automatic.
From SM64.Proofs.WMotRRequiresA Require Import PoleRunT.

Lemma climbT : pole_walkT 1049411%Z (AU true) mario_actions_automatic.f_act_climbing_pole = true.
Proof. vm_cast_no_check (eq_refl true). Qed.  (* computed once, by the kernel *)
