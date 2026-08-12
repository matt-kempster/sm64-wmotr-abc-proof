(** The two concrete premises needed by CompCert's JP initialization theorem. *)

From Coq Require Import List ZArith.
From compcert Require Import AST Clight Ctypes Globalenvs.
From LessThanOneAPress.Proofs Require Import
  CleanedClightPrograms ClightInitialMemoryExistence
  JPOfficialInitializerAlignment JPOfficialAddrofResolution.

Import ListNotations.
Local Open Scope Z_scope.

Theorem jp_official_cleaned_initial_memory_conditions :
  ProgramInitialMemoryConditions jp_official_cleaned_slice.
Proof.
  constructor.
  - intros id variable Hin.
    exact (jp_official_cleaned_initializers_aligned id variable Hin).
  - intros id variable referenced_id offset Hin Hreference.
    exact (jp_official_cleaned_variable_init_addrof_resolves
      id variable referenced_id offset Hin Hreference).
Qed.
