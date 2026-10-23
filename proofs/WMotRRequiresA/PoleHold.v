(* PoleHold (GOAL 2): the walk of the real act_holding_pole, computed once
   on the link (every outcome passes PoleRun.pk_ok).  The handler reads the
   controller's stick (a world object, PoleRun.pc0P), may slide Mario down
   the pole (oMarioPolePos -= oMarioPoleYawVel / 0x100, yawVel <= 0x1000),
   switches to CLIMBING_POLE / TOP_OF_POLE_TRANSITION / SOFT_BONK without
   moving him, and calls set_sound_moving_speed (its real audio/external.c
   body since 2026-10-23: SndXc.c_ssms_sound, a clobber of region RSMS). *)
From Coq Require Import ZArith.
From SM64.Generated Require mario_actions_automatic.
From SM64.Proofs.WMotRRequiresA Require Import PoleRun.

Lemma holdcheck12 : pole_walk 135267136%Z mario_actions_automatic.f_act_holding_pole = true.
Proof. vm_cast_no_check (eq_refl true). Qed.  (* computed once, by the kernel *)
