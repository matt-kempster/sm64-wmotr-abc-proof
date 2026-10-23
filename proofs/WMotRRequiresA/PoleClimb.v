(* PoleClimb (GOAL 2): the walk of the real act_climbing_pole, computed once
   on the link (every outcome passes PoleRun.pk_ok).  The handler reads the
   camera's yaw (m->area->camera->yaw, an opaque value: it only turns
   Mario), the controller's stick, and climbs oMarioPolePos += stickY / 8.0f
   past the test !(stickY < 8.0f); set_pole_position then puts Mario on the
   pole (PoleClass.climb: the find_ceil cast on that height makes the climb
   finite, PoleFloat.climb_val keeps it >= the entry's polePos).  The climb
   animation is set_mario_anim_with_accel (SmaXc.c_smawa) and
   play_climbing_sounds tests is_anim_past_frame (PoleXc's value contract)
   before play_sound (audio). *)
From Coq Require Import ZArith.
From SM64.Generated Require mario_actions_automatic.
From SM64.Proofs.WMotRRequiresA Require Import PoleRun.

Lemma climbcheck12 : pole_walk 1049411%Z mario_actions_automatic.f_act_climbing_pole = true.
Proof. vm_cast_no_check (eq_refl true). Qed.  (* computed once, by the kernel *)
