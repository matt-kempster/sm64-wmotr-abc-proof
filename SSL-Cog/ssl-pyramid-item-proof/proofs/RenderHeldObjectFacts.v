From Coq Require Import List.
Import ListNotations.
From compcert Require Import Clight.
From SSLPyramid.Generated Require Import mario_misc.
From SSLPyramid.Proofs Require Import ASTFacts.

Module MM := mario_misc.

Theorem geo_switch_mario_hand_grab_pos_direct_objnode_writers :
  direct_field_writers MM.prog MM._objNode =
  [MM._geo_switch_mario_hand_grab_pos].
Proof. vm_compute; reflexivity. Qed.

Theorem geo_switch_mario_hand_grab_pos_refreshes_objnode_from_mario_heldObj :
  event_subsequenceb
    [Event_assign_field_null MM._objNode;
     Event_set_temp_from_field MM._t'4 MM._marioState MM._heldObj;
     Event_set_temp_from_field MM._t'8 MM._marioState MM._heldObj;
     Event_assign_field_from_temp MM._objNode MM._t'8]
    (statement_events_s
      (fn_body MM.f_geo_switch_mario_hand_grab_pos)) = true.
Proof. vm_compute; reflexivity. Qed.
