(** Existence of initialized memory for the official cleaned JP link. *)

From Coq Require Import List ZArith.
From compcert Require Import AST Clight Ctypes Globalenvs Memory.
From LessThanOneAPress.Proofs Require Import
  CleanedClightPrograms ClightInitialMemoryExistence
  JPOfficialInitializationConditions.

Import ListNotations.
Local Open Scope Z_scope.

Theorem jp_official_cleaned_initial_memory_exists :
  exists memory,
    Genv.init_mem jp_official_cleaned_slice = Some memory.
Proof.
  apply program_initial_memory_exists_from_conditions.
  exact jp_official_cleaned_initial_memory_conditions.
Qed.
