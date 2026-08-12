(** Abstract source-name transport through normalization, viewport repair, and
    a program whose definition list is exactly the repaired normalized list. *)

From Coq Require Import List.
From compcert Require Import AST Clight Ctypes Globalenvs.
From LessThanOneAPress.Proofs Require Import
  NormalizedClightPrograms NormalizedDefinitionNameTransport
  USWholeASTTagRepair.

Theorem source_definition_has_normalized_repaired_symbol :
  forall definitions program id definition,
    prog_defs program =
      map repair_us_selected_global_definition
        (normalize_global_definitions definitions) ->
    In (id, definition) definitions ->
    exists block,
      Genv.find_symbol (Clight.globalenv program) id = Some block.
Proof.
  intros definitions program id definition Hprogram Hin.
  destruct (source_definition_has_normalized_name
    definitions id definition Hin) as [selected Hselected].
  destruct (repair_us_selected_global_definition (id, selected))
    as [repaired_id repaired_definition] eqn:Hrepair.
  pose proof
    (repair_us_selected_global_definition_preserves_identifier
      (id, selected)) as Hid.
  rewrite Hrepair in Hid. cbn in Hid. subst repaired_id.
  assert (Hdefinition :
    In (id, repaired_definition) (prog_defs program)).
  {
  rewrite Hprogram.
  apply in_map_iff. exists (id, selected). split.
  - exact Hrepair.
  - exact Hselected.
  }
  exact (Genv.find_symbol_exists
    (Ctypes.program_of_program program) id repaired_definition Hdefinition).
Qed.
