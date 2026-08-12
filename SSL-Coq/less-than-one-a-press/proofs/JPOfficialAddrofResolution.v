(** Relocation-symbol premise for the official cleaned JP initial memory. *)

From Coq Require Import List.
From compcert Require Import AST Clight Ctypes Globalenvs.
From LessThanOneAPress.Proofs Require Import
  CleanedClightPrograms ClightLinkExecution ClightInitializerInventoryFacts.

Theorem jp_official_cleaned_variable_init_addrof_resolves :
  forall id variable referenced_id offset,
    In (id, Gvar variable) (prog_defs jp_official_cleaned_slice) ->
    In (Init_addrof referenced_id offset) (gvar_init variable) ->
    exists block,
      Genv.find_symbol (Clight.globalenv jp_official_cleaned_slice)
        referenced_id = Some block.
Proof.
  intros id variable referenced_id offset Hin Hreference.
  apply jp_source_init_addrof_resolves_in_official_target.
  eapply variable_init_addrof_occurs_in_source_union_inventory.
  - exact (jp_official_source_definition_provenance
      id (Gvar variable) Hin).
  - exact Hreference.
Qed.
