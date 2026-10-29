(** Initialization witnesses for the two actual selected programs. This is
    CompCert global-memory initialization, not boot or an object update. *)
From compcert Require Import AST Clight Ctypes Globalenvs Memory.
From LessThanOneAPress.Proofs Require Import
  GameTypes SelectedClightTarget USWholeASTTagRepair CleanedClightPrograms
  USRepairedInitialMemory JPOfficialInitialMemory.

Local Opaque us_viewport_repaired_program jp_official_cleaned_slice.

Theorem selected_clight_initial_memory_exists : forall version,
  exists memory,
    Genv.init_mem (selected_clight_target version) = Some memory.
Proof.
  intros [].
  - exact us_viewport_repaired_initial_memory_exists.
  - exact jp_official_cleaned_initial_memory_exists.
Qed.
