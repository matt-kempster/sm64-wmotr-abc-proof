(** Generic membership facts for [Init_addrof] program inventories. *)

From Coq Require Import List.
From compcert Require Import AST Clight Ctypes.
From LessThanOneAPress.Proofs Require Import
  NormalizedClightPrograms ClightLinkExecution.

Import ListNotations.

Lemma variable_init_addrof_occurs_in_program_inventory :
  forall program definition_id variable referenced_id offset,
    In (definition_id, Gvar variable) (prog_defs program) ->
    In (Init_addrof referenced_id offset) (gvar_init variable) ->
    In referenced_id (program_init_addrof_identifiers program).
Proof.
  intros program definition_id variable referenced_id offset
    Hdefinition Hreference.
  unfold program_init_addrof_identifiers.
  apply in_concat.
  exists (global_definition_init_addrof_identifiers
    (definition_id, Gvar variable)).
  split; [now apply in_map |].
  unfold global_definition_init_addrof_identifiers.
  apply in_concat.
  exists (init_data_addrof_identifiers
    (Init_addrof referenced_id offset)).
  split; [now apply in_map | now left].
Qed.

Lemma variable_init_addrof_occurs_in_source_union_inventory :
  forall units definition_id variable referenced_id offset,
    In (definition_id, Gvar variable) (unit_global_definitions units) ->
    In (Init_addrof referenced_id offset) (gvar_init variable) ->
    In referenced_id (source_union_init_addrof_identifiers units).
Proof.
  intros units definition_id variable referenced_id offset
    Hdefinition Hreference.
  unfold source_union_init_addrof_identifiers.
  apply in_concat.
  exists (global_definition_init_addrof_identifiers
    (definition_id, Gvar variable)).
  split; [now apply in_map |].
  unfold global_definition_init_addrof_identifiers.
  apply in_concat.
  exists (init_data_addrof_identifiers
    (Init_addrof referenced_id offset)).
  split; [now apply in_map | now left].
Qed.
