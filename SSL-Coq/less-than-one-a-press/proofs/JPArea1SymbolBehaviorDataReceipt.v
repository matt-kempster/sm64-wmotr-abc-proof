(** Focused JP [behavior_data] receipt for the Area-1 boundary. *)

From Coq Require Import List.
From compcert Require Import AST Clight Coqlib Ctypes Globalenvs Maps.
From LessThanOneAPress.Generated Require Import jp_behavior_data.
From LessThanOneAPress.Proofs Require Import
  CleanedClightPrograms JPSourceSymbolTransport LinkedClightPrograms.

Fixpoint jp_area1_behavior_source_at
    (index : nat) (units : nlist Clight.program) : Clight.program :=
  match index, units with
  | O, _ => nfirst units
  | S next, nbase unit => unit
  | S next, ncons _ rest => jp_area1_behavior_source_at next rest
  end.

Lemma jp_area1_behavior_source_at_nIn :
  forall index units,
    nIn (jp_area1_behavior_source_at index units) units.
Proof.
  induction index as [| index IH]; intros [head | head rest]; cbn.
  - reflexivity.
  - now left.
  - reflexivity.
  - right. apply IH.
Qed.

Theorem jp_behavior_data_is_area1_symbol_source_unit :
  nIn jp_behavior_data.prog jp_units.
Proof.
  change (nIn (jp_area1_behavior_source_at 26 jp_units) jp_units).
  apply jp_area1_behavior_source_at_nIn.
Qed.

Theorem jp_behavior_data_bhvSpinAirborneWarp_defmap_checked :
  (AST.prog_defmap (Ctypes.program_of_program jp_behavior_data.prog)) !
      jp_behavior_data._bhvSpinAirborneWarp =
    Some (Gvar jp_behavior_data.v_bhvSpinAirborneWarp).
Proof. vm_compute. reflexivity. Qed.

Theorem jp_official_area1_spin_behavior_symbol_exists :
  exists block,
    Genv.find_symbol (Clight.globalenv jp_official_cleaned_slice)
      jp_behavior_data._bhvSpinAirborneWarp = Some block.
Proof.
  eapply (jp_source_definition_has_official_symbol jp_behavior_data.prog).
  - exact jp_behavior_data_is_area1_symbol_source_unit.
  - pose proof jp_behavior_data_bhvSpinAirborneWarp_defmap_checked as Hreceipt.
    apply AST.in_prog_defmap in Hreceipt. exact Hreceipt.
Qed.
