(** Abstract list-level syntax inventories preserved by viewport repair. *)

From Coq Require Import List.
From LessThanOneAPress.Proofs Require Import
  ClightLinkExecution USViewportRepairSyntaxPreservation
  USWholeASTTagRepair.

Lemma repair_definition_list_preserves_direct_sbuiltins :
  forall definitions,
    concat (map global_definition_direct_sbuiltins
      (map repair_us_selected_global_definition definitions)) =
    concat (map global_definition_direct_sbuiltins definitions).
Proof.
  intros definitions. rewrite map_map. f_equal.
  apply map_ext. intros entry.
  apply repair_us_selected_global_definition_preserves_direct_sbuiltins.
Qed.

Lemma repair_definition_list_preserves_init_addrofs :
  forall definitions,
    concat (map global_definition_init_addrof_identifiers
      (map repair_us_selected_global_definition definitions)) =
    concat (map global_definition_init_addrof_identifiers definitions).
Proof.
  intros definitions. rewrite map_map. f_equal.
  apply map_ext. intros entry.
  apply repair_us_selected_global_definition_preserves_init_addrofs.
Qed.

Lemma repair_definition_list_preserves_external_constructors :
  forall definitions,
    forallb external_global_has_supported_constructor
      (map repair_us_selected_global_definition definitions) =
    forallb external_global_has_supported_constructor definitions.
Proof.
  intros definitions. induction definitions as [| entry rest IH]; cbn;
    [reflexivity |].
  now rewrite
    repair_us_selected_global_definition_preserves_external_constructor, IH.
Qed.
