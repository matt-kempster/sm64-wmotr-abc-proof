(** Exact resolution of JP [_warp_level] in the official cleaned link.
    This closes only the symbol/body premise used by the Area-1 boundary; it
    does not prove that the task reaches or executes the warp prefix. *)

From Coq Require Import List.
From compcert Require Import AST Clight Coqlib Ctypes Globalenvs Linking Maps.
From LessThanOneAPress.Generated Require Import jp_level_update.
From LessThanOneAPress.Proofs Require Import
  CleanedClightPrograms ClightLinkExecution.

Fixpoint nlist_at {A : Type} (index : nat) (units : nlist A) : A :=
  match index, units with
  | O, _ => nfirst units
  | S next, nbase unit => unit
  | S next, ncons _ rest => nlist_at next rest
  end.

Lemma nlist_at_nIn :
  forall (A : Type) (index : nat) (units : nlist A),
    nIn (nlist_at index units) units.
Proof.
  intros A index. induction index as [| index IH];
    intros [head | head rest]; cbn.
  - reflexivity.
  - now left.
  - reflexivity.
  - right. apply IH.
Qed.

(** [jp_level_update] is source/cleaned unit 28 in the zero-based 38-unit
    order retained by [clean_translation_units]. *)
Definition jp_level_update_cleaned_unit : Clight.program :=
  nlist_at 28%nat jp_cleaned_units.

Theorem jp_level_update_cleaned_unit_warp_level_defmap_checked :
  (prog_defmap jp_level_update_cleaned_unit) ! jp_level_update._warp_level =
    Some (Gfun (Internal jp_level_update.f_warp_level)).
Proof. vm_compute. reflexivity. Qed.

Theorem jp_warp_level_resolves_exact_body :
  exists warp_level_block,
    Genv.find_symbol (Clight.globalenv jp_official_cleaned_slice)
      jp_level_update._warp_level = Some warp_level_block /\
    Genv.find_funct_ptr (Clight.globalenv jp_official_cleaned_slice)
      warp_level_block = Some (Internal jp_level_update.f_warp_level).
Proof.
  eapply (official_link_resolves_internal_globalenv
    jp_cleaned_units jp_official_cleaned_slice
    jp_cleaned_units_official_link
    jp_level_update_cleaned_unit
    jp_level_update._warp_level
    jp_level_update.f_warp_level).
  - exact (nlist_at_nIn _ 28%nat jp_cleaned_units).
  - exact jp_level_update_cleaned_unit_warp_level_defmap_checked.
Qed.
