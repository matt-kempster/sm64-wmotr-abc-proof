(* SCRATCH (Unwired): feasibility-test the decidable callgraph facts over
   mario.prog that a reachability-rooted value engine would rest on. NOT yet
   load-bearing. *)
From Coq Require Import List.
Import ListNotations.
From compcert Require Import AST Clight.
From SM64.Proofs Require Import CallgraphReach.
From SM64.Generated Require Import mario.

(* The sole internal action-writer set_mario_action is NOT statically reached
   from execute_mario_action -- the doc's central claim, machine-checked. *)
Example emA_does_not_reach_set_mario_action :
  reaches prog _execute_mario_action _set_mario_action = false.
Proof. reflexivity. Qed.

(* Sanity: the static reach is not vacuously false -- emA DOES reach a known
   internal callee (mario_reset_bodystate). *)
Example emA_reaches_reset_bodystate :
  reaches prog _execute_mario_action _mario_reset_bodystate = true.
Proof. reflexivity. Qed.

(* The full goal-claim at the STATIC level: NONE of mario.prog's internal
   action-writer family (everything that assigns Mario's action field, directly
   via set_mario_action or transitively via the set_*_action helpers + init) is
   statically reachable from execute_mario_action. So leaf B (the writer case)
   is, INTERNALLY, vacuous -- the only action writes the frame can reach go
   through EXTERNAL TUs (the mario_execute_* dispatch). Machine-checked. *)
Definition internal_action_writers : list ident :=
  [ _set_mario_action
  ; _set_mario_action_airborne
  ; _set_mario_action_cutscene
  ; _set_mario_action_moving
  ; _set_mario_action_submerged
  ; _drop_and_set_mario_action
  ; _hurt_and_set_mario_action
  ; _set_jumping_action
  ; _set_steep_jump_action
  ; _set_water_plunge_action
  ; _init_mario
  ; _init_mario_from_save_file ].

Example emA_reaches_no_internal_action_writer :
  existsb (fun w => reaches prog _execute_mario_action w) internal_action_writers
    = false.
Proof. reflexivity. Qed.
