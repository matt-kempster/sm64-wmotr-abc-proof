(** Global-environment lookup for the exact official JP object-pool variable. *)

From Coq Require Import List ZArith.
From compcert Require Import
  AST Clight Coqlib Ctypes Globalenvs Linking Maps Memory.
From LessThanOneAPress.Generated Require Import jp_object_list_processor.
From LessThanOneAPress.Proofs Require Import
  CleanedClightPrograms JPObjectPoolOfficialDefmapReceipt
  LinkedGlobalInitialMemory.

Import ListNotations.
Local Open Scope Z_scope.

Theorem jp_official_gObjectPool_exact_variable_lookup :
  exists pool_block,
    Genv.find_symbol (Clight.globalenv jp_official_cleaned_slice)
      jp_object_list_processor._gObjectPool = Some pool_block /\
    Genv.find_var_info (Clight.globalenv jp_official_cleaned_slice)
      pool_block = Some jp_object_list_processor.v_gObjectPool.
Proof.
  eapply variable_definition_map_resolves_globalenv.
  exact jp_official_object_pool_exact_variable_defmap.
Qed.
