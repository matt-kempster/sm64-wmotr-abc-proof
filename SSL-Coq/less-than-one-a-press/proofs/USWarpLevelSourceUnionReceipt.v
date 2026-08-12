(** Transport the focused generated-US [_warp_level] receipt into the source
    union consumed by normalization.  No global map is computed here. *)

From Coq Require Import List.
From compcert Require Import AST Clight Coqlib Ctypes Linking.
From LessThanOneAPress.Generated Require Import us_level_update.
From LessThanOneAPress.Proofs Require Import
  LinkedClightPrograms NormalizedClightPrograms
  JPSourceSymbolTransport
  USWarpLevelSourceReceipt.

Fixpoint us_nlist_at {A : Type} (index : nat) (units : nlist A) : A :=
  match index, units with
  | O, _ => nfirst units
  | S next, nbase unit => unit
  | S next, ncons _ rest => us_nlist_at next rest
  end.

Lemma us_nlist_at_nIn :
  forall (A : Type) (index : nat) (units : nlist A),
    nIn (us_nlist_at index units) units.
Proof.
  intros A index. induction index as [| index IH];
    intros [head | head rest]; cbn.
  - reflexivity.
  - now left.
  - reflexivity.
  - right. apply IH.
Qed.

Theorem us_warp_level_source_union_member :
  In (us_level_update._warp_level,
      Gfun (Internal us_level_update.f_warp_level))
    (unit_global_definitions us_units).
Proof.
  assert (Hunit :
    us_nlist_at 28%nat us_units = us_level_update.prog).
  { reflexivity. }
  eapply source_unit_definition_enters_source_union
    with (unit := us_nlist_at 28%nat us_units).
  - exact (us_nlist_at_nIn _ 28%nat us_units).
  - rewrite Hunit.
    exact us_level_update_warp_level_prog_defs_member.
Qed.
