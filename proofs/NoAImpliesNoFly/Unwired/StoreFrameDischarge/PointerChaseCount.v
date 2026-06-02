(* PointerChaseCount.v -- MEASURING the per-function proof burden.
 *
 * The "no A => no fly" store-frame side splits each handler's stores into:
 *   - DIRECT  (m->field = ..)        : block = the param's block, offset decides;
 *                                      handled wholesale by Flying.v's syntactic
 *                                      enumeration + the generic capstone (cheap).
 *   - POINTER-CHASE (m->ptr->field=..): store through a tempvar loaded from a field;
 *                                      block-distinctness (MarioMemoryWF) is needed, and
 *                                      the generic capstone CANNOT see the temp's
 *                                      provenance -- so these need provenance work.
 *
 * This file COUNTS the chase functions, to decide whether per-function proofs
 * (ResetBodystate-style) are survivable or whether we must build the generic
 * temp-provenance capstone. A function "chases" iff some Sassign's lvalue dereferences
 * a tempvar that is NOT one of the function's parameters (clightgen loads each `->`
 * step into a local temp, so a store through a non-param temp is a chase). This is a
 * sound OVER-approximation of the proof burden (it may flag a temp that merely re-holds
 * a param, never the reverse).
 *)

From Coq Require Import List PArith.BinPos.
Import ListNotations.
From compcert Require Import AST Ctypes Cop Clight.
From SM64.Proofs Require Import CallgraphReach.
From SM64.Generated Require mario mario_actions_airborne mario_actions_moving
  mario_actions_stationary mario_actions_submerged mario_actions_cutscene
  mario_actions_object mario_actions_automatic.

(* does this expression dereference a tempvar that is NOT a parameter? *)
Fixpoint expr_chase (params : list ident) (e : expr) : bool :=
  match e with
  | Ederef (Etempvar t _) _ => negb (existsb (Pos.eqb t) params)
  | Ederef e1 _      => expr_chase params e1
  | Efield e1 _ _    => expr_chase params e1
  | Eaddrof e1 _     => expr_chase params e1
  | Eunop _ a _      => expr_chase params a
  | Ecast a _        => expr_chase params a
  | Ebinop _ a b _   => expr_chase params a || expr_chase params b
  | _                => false
  end.

Fixpoint chase_store_s (params : list ident) (s : statement) : bool :=
  match s with
  | Sassign lhs _       => expr_chase params lhs
  | Ssequence s1 s2     => chase_store_s params s1 || chase_store_s params s2
  | Sifthenelse _ s1 s2 => chase_store_s params s1 || chase_store_s params s2
  | Sloop s1 s2         => chase_store_s params s1 || chase_store_s params s2
  | Slabel _ s1         => chase_store_s params s1
  | Sswitch _ ls        => chase_store_ls params ls
  | _                   => false
  end
with chase_store_ls (params : list ident) (ls : labeled_statements) : bool :=
  match ls with
  | LSnil           => false
  | LScons _ s rest => chase_store_s params s || chase_store_ls params rest
  end.

Definition fn_chases (idf : ident * function) : bool :=
  chase_store_s (map fst (fn_params (snd idf))) (fn_body (snd idf)).

Definition chase_funcs (p : program) : list ident :=
  map fst (filter fn_chases (internal_funcs (prog_defs p))).

Definition n_internal (p : program) : nat := length (internal_funcs (prog_defs p)).
Definition n_chase    (p : program) : nat := length (chase_funcs p).

(* ===================================================================== *)
(* THE MEASUREMENT (machine-checked). Each fact is (chase_functions,       *)
(* total_internal_functions) for one TU. TOTAL across these 8 TUs:         *)
(*   chase = 111   internal = 435   (~26% of functions pointer-chase).     *)
(* And this EXCLUDES interaction.c, level_update.c and the ~111 behaviors  *)
(* in behavior_actions.c -- so the true program-wide chase count is higher.*)
(*                                                                         *)
(* CONCLUSION: 111+ functions cannot each get a bespoke ResetBodystate-    *)
(* style provenance proof. Per-function does NOT scale; the generic temp-  *)
(* provenance frame lemma (or VST) is the required lever.                  *)
(* ===================================================================== *)

Example c_mario      : (n_chase mario.prog, n_internal mario.prog) = (14, 62).
Proof. vm_compute. reflexivity. Qed.
Example c_airborne   : (n_chase mario_actions_airborne.prog, n_internal mario_actions_airborne.prog) = (16, 64).
Proof. vm_compute. reflexivity. Qed.
Example c_moving     : (n_chase mario_actions_moving.prog, n_internal mario_actions_moving.prog) = (11, 73).
Proof. vm_compute. reflexivity. Qed.
Example c_stationary : (n_chase mario_actions_stationary.prog, n_internal mario_actions_stationary.prog) = (7, 44).
Proof. vm_compute. reflexivity. Qed.
Example c_submerged  : (n_chase mario_actions_submerged.prog, n_internal mario_actions_submerged.prog) = (15, 57).
Proof. vm_compute. reflexivity. Qed.
Example c_cutscene   : (n_chase mario_actions_cutscene.prog, n_internal mario_actions_cutscene.prog) = (36, 93).
Proof. vm_compute. reflexivity. Qed.
Example c_object     : (n_chase mario_actions_object.prog, n_internal mario_actions_object.prog) = (4, 14).
Proof. vm_compute. reflexivity. Qed.
Example c_automatic  : (n_chase mario_actions_automatic.prog, n_internal mario_actions_automatic.prog) = (8, 28).
Proof. vm_compute. reflexivity. Qed.
