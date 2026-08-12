(** Transfer the split JP source-unit alignment receipts to the official link. *)

From Coq Require Import List ZArith.
From compcert Require Import AST Clight Ctypes Globalenvs.
From LessThanOneAPress.Proofs Require Import
  CleanedClightPrograms ClightLinkExecution ClightInitialMemoryFacts
  JPInitializerAggregate.

Local Open Scope Z_scope.

Theorem jp_official_cleaned_initializers_aligned :
  forall id variable,
    In (id, Gvar variable) (prog_defs jp_official_cleaned_slice) ->
    Genv.init_data_list_aligned 0 (gvar_init variable).
Proof.
  intros id variable Hin.
  eapply nlist_program_initializers_aligned_sound.
  - exact jp_units_initializers_aligned.
  - rewrite <- unit_global_definitions_are_nlist_program_definitions.
    exact (jp_official_source_definition_provenance
      id (Gvar variable) Hin).
Qed.
