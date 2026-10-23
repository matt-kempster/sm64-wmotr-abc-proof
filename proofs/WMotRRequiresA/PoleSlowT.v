(* PoleSlowT (GOAL 2): the walk of the real act_grab_pole_slow (nothing
   known of the animation state, PoleStartT.avars), computed once on the
   link (every outcome passes PoleRunT.pk_okT; on HOLDING_POLE the
   animation state is anim_st, AnimEnd). *)
From Coq Require Import ZArith.
From SM64.Generated Require mario_actions_automatic.
From SM64.Proofs.WMotRRequiresA Require Import PoleRunT.

Lemma slowT : pole_walkT 1049409%Z (AU false) mario_actions_automatic.f_act_grab_pole_slow = true.
Proof. vm_cast_no_check (eq_refl true). Qed.  (* computed once, by the kernel *)
