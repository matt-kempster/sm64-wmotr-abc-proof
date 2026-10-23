(* PoleTopT2 (GOAL 2): the walk of the real act_top_of_pole started with
   animation 9 not loaded (animID != 9, currentAddr not its entry;
   PoleStartT.avars), computed once on the link (every outcome passes
   PoleRunT.pk_okT): set_mario_animation loads it from the DMA table. *)
From Coq Require Import ZArith.
From SM64.Generated Require mario_actions_automatic.
From SM64.Proofs.WMotRRequiresA Require Import PoleRunT.

Lemma topT_r9 : pole_walkT 1049413%Z (AR (9%Z :: nil)) mario_actions_automatic.f_act_top_of_pole = true.
Proof. vm_cast_no_check (eq_refl true). Qed.  (* computed once, by the kernel *)
