(* PoleHoldT (GOAL 2): the walk of the real act_holding_pole from
   AnimWorld.anim_st (PoleStartT.avars), computed once on the link (every
   outcome passes PoleRunT.pk_okT).  The handler may slide Mario down the
   pole, switches to CLIMBING_POLE / TOP_OF_POLE_TRANSITION / SOFT_BONK,
   and calls set_sound_moving_speed (its real body, SndXc.c_ssms_sound). *)
From Coq Require Import ZArith.
From SM64.Generated Require mario_actions_automatic.
From SM64.Proofs.WMotRRequiresA Require Import PoleRunT.

Lemma holdT : pole_walkT 135267136%Z (AU true) mario_actions_automatic.f_act_holding_pole = true.
Proof. vm_cast_no_check (eq_refl true). Qed.  (* computed once, by the kernel *)
