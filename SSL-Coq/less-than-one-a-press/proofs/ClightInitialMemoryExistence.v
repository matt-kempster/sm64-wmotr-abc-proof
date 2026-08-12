(** An opaque wrapper around CompCert's constructive initialization theorem. *)

From Coq Require Import List ZArith.
From compcert Require Import AST Clight Ctypes Globalenvs Memory.

Local Open Scope Z_scope.

Record ProgramInitialMemoryConditions (program : Clight.program) : Prop := {
  program_initializers_aligned : forall id variable,
    In (id, Gvar variable) (prog_defs program) ->
    Genv.init_data_list_aligned 0 (gvar_init variable);
  program_init_addrof_resolved : forall id variable referenced_id offset,
    In (id, Gvar variable) (prog_defs program) ->
      In (Init_addrof referenced_id offset) (gvar_init variable) ->
      exists block,
        Genv.find_symbol (Clight.globalenv program) referenced_id = Some block
}.

Theorem program_initial_memory_exists_from_conditions :
  forall program,
    ProgramInitialMemoryConditions program ->
    exists memory, Genv.init_mem program = Some memory.
Proof.
  intros program Hconditions.
  apply Genv.init_mem_exists.
  intros id variable Hin. split.
  - exact (program_initializers_aligned program Hconditions id variable Hin).
  - intros referenced_id offset Hreference.
    exact (program_init_addrof_resolved program Hconditions id variable
      referenced_id offset Hin Hreference).
Qed.
