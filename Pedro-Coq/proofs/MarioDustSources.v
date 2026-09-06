From Coq Require Import Bool List ZArith.
From compcert Require Import AST Clight Cop Ctypes Integers.
From Pedro.Generated Require Import
  us_mario_actions_moving jp_mario_actions_moving
  us_mario_actions_airborne jp_mario_actions_airborne.
From Pedro.Proofs Require Import GameTypes.

Import ListNotations.
Module DS := us_mario_actions_moving.

(** Finite SYNTAX inventory of the explicit particleFlags |= PARTICLE_DUST
    form in the two generated action translation units. This is not a claim
    about all runtime seed changes: indirect helper calls, other translation
    units, computed particle masks, objects, and the camera are outside this
    inventory. Nor does membership establish that an action is reachable. *)
Definition literal_dust_bit (value : expr) : bool :=
  match value with
  | Econst_int n _ => Int.eq n Int.one
  | Ebinop Oshl (Econst_int n _) (Econst_int shift _) _ =>
      Int.eq n Int.one && Int.eq shift Int.zero
  | _ => false
  end.

Fixpoint direct_literal_dust_request (body : statement) : bool :=
  match body with
  | Sassign (Efield _ field _) (Ebinop Oor a b _) =>
      Pos.eqb field DS._particleFlags && (literal_dust_bit a || literal_dust_bit b)
  | Ssequence a b | Sloop a b =>
      direct_literal_dust_request a || direct_literal_dust_request b
  | Sifthenelse _ a b =>
      direct_literal_dust_request a || direct_literal_dust_request b
  | Sswitch _ cases => direct_literal_dust_cases cases
  | Slabel _ body => direct_literal_dust_request body
  | _ => false
  end
with direct_literal_dust_cases (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      direct_literal_dust_request body || direct_literal_dust_cases rest
  end.

Definition direct_literal_dust_writers (program : Clight.program) : list ident :=
  flat_map (fun entry =>
    match snd entry with
    | Gfun (Internal f) =>
        if direct_literal_dust_request (fn_body f) then [fst entry] else []
    | _ => []
    end) (prog_defs program).

Definition moving_dust_writers : list ident :=
  [DS._push_or_sidle_wall; DS._act_walking; DS._act_move_punching;
   DS._act_hold_walking; DS._act_turning_around; DS._act_braking;
   DS._act_decelerating; DS._act_hold_decelerating; DS._common_slide_action;
   DS._act_slide_kick_slide; DS._common_landing_action].

Definition mario_direct_dust_inventory_claim : Prop :=
  (forall version,
    direct_literal_dust_writers
      (match version with VersionUS => DS.prog
        | VersionJP => jp_mario_actions_moving.prog end) = moving_dust_writers) /\
  (forall version,
    direct_literal_dust_writers
      (match version with VersionUS => us_mario_actions_airborne.prog
        | VersionJP => jp_mario_actions_airborne.prog end) =
      [us_mario_actions_airborne._act_shot_from_cannon;
       us_mario_actions_airborne._act_flying]).

Theorem generated_mario_direct_dust_inventory_us_jp :
  mario_direct_dust_inventory_claim.
Proof. split; intros []; vm_compute; reflexivity. Qed.
