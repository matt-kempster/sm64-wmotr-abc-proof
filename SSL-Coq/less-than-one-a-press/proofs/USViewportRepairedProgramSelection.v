(** Opaque definition-list projection for the successful repaired-US target. *)

From compcert Require Import AST Clight Ctypes.
From LessThanOneAPress.Proofs Require Import
  CleanedClightPrograms USWholeASTTagRepair
  USViewportRepairedProgramCertificate
  SuccessfulMakeProgramResolution.

Lemma us_viewport_repaired_build_flag_is_result_success :
  us_viewport_repaired_program_builds =
    program_result_succeeds us_viewport_repaired_program_result.
Proof.
  unfold us_viewport_repaired_program_builds.
  reflexivity.
Qed.

Theorem us_viewport_repaired_program_definitions_checked :
  prog_defs us_viewport_repaired_program =
    us_viewport_repaired_global_definitions.
Proof.
  eapply selected_successful_program_definitions
    with (result := us_viewport_repaired_program_result).
  - reflexivity.
  - rewrite <- us_viewport_repaired_build_flag_is_result_success.
    exact us_viewport_repaired_program_success_flag_checked.
Qed.
