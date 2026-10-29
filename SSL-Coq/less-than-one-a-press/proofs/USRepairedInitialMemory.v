(** Successful initialization of the actual selected viewport-repaired US
    program. Alignment is checked per source unit; the existing repair keeps
    initializer bytes and the existing relocation census resolves symbols. *)
From Coq Require Import List ZArith.
From compcert Require Import AST Clight Ctypes Globalenvs Memory.
From LessThanOneAPress.Proofs Require Import
  LinkedClightPrograms NormalizedClightPrograms ClightInitialMemoryFacts
  ClightInitialMemoryExistence ClightInitializerInventoryFacts
  JPInitializerAggregate USInitializerAggregate USRepairedInitAddrofAudit
  USWholeASTTagRepair USViewportRepairedProgramSelection.

Local Open Scope Z_scope.
Local Opaque us_units unit_global_definitions us_normalized_global_definitions
  us_viewport_repaired_program.

Lemma us_source_variable_initializers_aligned : forall id variable,
  In (id, Gvar variable) (unit_global_definitions us_units) ->
  Genv.init_data_list_aligned 0 (gvar_init variable).
Proof.
  intros id variable Hin.
  eapply nlist_program_initializers_aligned_sound.
  - exact us_units_initializers_aligned.
  - rewrite <- unit_global_definitions_are_nlist_program_definitions.
    exact Hin.
Qed.

Theorem us_viewport_repaired_initializers_aligned : forall id variable,
  In (id, Gvar variable) (prog_defs us_viewport_repaired_program) ->
  Genv.init_data_list_aligned 0 (gvar_init variable).
Proof.
  intros id variable Hin.
  rewrite us_viewport_repaired_program_definitions_checked in Hin.
  unfold us_viewport_repaired_global_definitions in Hin.
  pose proof (proj1 (@in_map_iff
    (ident * globdef Clight.fundef type)
    (ident * globdef Clight.fundef type)
    repair_us_selected_global_definition us_normalized_global_definitions
    (id, Gvar variable)) Hin) as Hmember.
  destruct Hmember as [[source_id definition] [Hrepair Hsource]].
  destruct definition as [function | source_variable].
  - unfold repair_us_selected_global_definition in Hrepair.
    destruct (us_selected_definition_needs_viewport_repair
      (source_id, Gfun function)); discriminate Hrepair.
  - assert (Haligned :
      Genv.init_data_list_aligned 0 (gvar_init source_variable)).
    { apply us_source_variable_initializers_aligned with (id := source_id).
      exact (us_selected_definitions_have_source_provenance _ Hsource). }
    unfold repair_us_selected_global_definition in Hrepair.
    destruct (us_selected_definition_needs_viewport_repair
      (source_id, Gvar source_variable));
      cbn [fst snd rename_globdef_tag] in Hrepair;
      inversion Hrepair; subst; exact Haligned.
Qed.

Theorem us_viewport_repaired_initial_memory_conditions :
  ProgramInitialMemoryConditions us_viewport_repaired_program.
Proof.
  constructor.
  - exact us_viewport_repaired_initializers_aligned.
  - intros id variable referenced_id offset Hin Hreference.
    apply us_repaired_init_addrof_identifier_resolves.
    exact (variable_init_addrof_occurs_in_program_inventory
      us_viewport_repaired_program id variable referenced_id offset Hin Hreference).
Qed.

Theorem us_viewport_repaired_initial_memory_exists :
  exists memory,
    Genv.init_mem us_viewport_repaired_program = Some memory.
Proof.
  apply program_initial_memory_exists_from_conditions.
  exact us_viewport_repaired_initial_memory_conditions.
Qed.
