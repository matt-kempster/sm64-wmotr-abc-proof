(** One local computation fixing the cleaned JP object-pool definition. *)

From Coq Require Import List.
From compcert Require Import AST Clight Coqlib Ctypes Linking Maps.
From LessThanOneAPress.Generated Require Import jp_object_list_processor.
From LessThanOneAPress.Proofs Require Import CleanedClightPrograms.

Fixpoint jp_pool_nlist_at {A : Type} (index : nat) (units : nlist A) : A :=
  match index, units with
  | O, _ => nfirst units
  | S next, nbase unit => unit
  | S next, ncons _ rest => jp_pool_nlist_at next rest
  end.

Lemma jp_pool_nlist_at_nIn :
  forall (A : Type) (index : nat) (units : nlist A),
    nIn (jp_pool_nlist_at index units) units.
Proof.
  intros A index. induction index as [| index IH];
    intros [head | head rest]; cbn.
  - reflexivity.
  - now left.
  - reflexivity.
  - right. apply IH.
Qed.

(** [jp_object_list_processor] is unit 13 in the zero-based JP order. *)
Definition jp_object_pool_cleaned_unit : Clight.program :=
  jp_pool_nlist_at 13%nat jp_cleaned_units.

Theorem jp_object_pool_cleaned_unit_exact_variable_checked :
  (prog_defmap jp_object_pool_cleaned_unit) !
      jp_object_list_processor._gObjectPool =
    Some (Gvar jp_object_list_processor.v_gObjectPool).
Proof. vm_compute. reflexivity. Qed.
