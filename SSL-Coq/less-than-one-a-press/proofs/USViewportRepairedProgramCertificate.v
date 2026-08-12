(** Kernel-checked success certificate for the concrete US viewport repair.

    [USWholeASTTagRepair] defines a total fallback value because
    [Ctypes.make_program] may fail.  The computation below proves that the
    repaired composite header and all repaired global definitions actually
    build, so later semantic work may use the repaired program without a
    fallback ambiguity.  This certificate does not prove the alpha-renaming
    step simulation or any normalized-to-retail memory relation. *)

From LessThanOneAPress.Proofs Require Import
  NormalizedClightPrograms USWholeASTTagRepair.

Theorem us_viewport_repaired_program_success_flag_checked :
  us_viewport_repaired_program_builds = true.
Proof. vm_compute. reflexivity. Qed.
