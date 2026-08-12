(** Identifier uniqueness for the repaired US selected definition list.

    The viewport repair preserves every identifier, so uniqueness is inherited
    directly from the [PTree.elements] list used by normalization. *)

From Coq Require Import List.
From compcert Require Import AST Clight Coqlib Ctypes Maps.
From LessThanOneAPress.Proofs Require Import
  NormalizedClightPrograms USWholeASTTagRepair.

Lemma us_viewport_repaired_definition_names_norepet :
  list_norepet (map fst us_viewport_repaired_global_definitions).
Proof.
  rewrite map_fst_repair_us_selected_global_definitions.
  unfold us_normalized_global_definitions.
  apply PTree.elements_keys_norepet.
Qed.
