(* ToyFrame.v -- Milestone 0: the generate -> load -> compute -> check spine,
 * validated on the toy TU.
 *
 * The analysis itself (writes_global) is generic and lives in Frame.v. Here we
 * just instantiate it on the generated Clight of experiments/toy/toy.c and pin
 * two controls by reflexivity.
 *)

From SM64.Proofs Require Import Frame.
From SM64.Generated Require Import toy.

(* --- The two machine-checked controls over the generated Clight of toy.c --- *)

(* Positive control: clobber() really does store into gUnrelated. *)
Example clobber_writes_gUnrelated :
  writes_global f_clobber _gUnrelated = true.
Proof. reflexivity. Qed.

(* Negative control: set_timer() never assigns to gUnrelated. *)
Example set_timer_does_not_write_gUnrelated :
  writes_global f_set_timer _gUnrelated = false.
Proof. reflexivity. Qed.
