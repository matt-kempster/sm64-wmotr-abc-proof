(** Exact resolution of US [_warp_level] in the selected viewport-repaired
    program.

    The focused source, normalization, and repair receipts are compiled in
    separate modules.  This final layer uses only the repaired definition,
    identifier uniqueness, successful [make_program], and CompCert's global
    environment lemmas.  It establishes the symbol and exact function body,
    not reachability or an execution prefix. *)

From compcert Require Import AST Clight Ctypes Errors Globalenvs.
From LessThanOneAPress.Generated Require Import us_level_update.
From LessThanOneAPress.Proofs Require Import
  USWholeASTTagRepair SuccessfulMakeProgramResolution
  USViewportRepairedProgramSelection
  USWarpLevelRepairReceipt USViewportRepairedNamesNorepet.

Theorem us_warp_level_resolves_exact_body :
  exists warp_level_block,
    Genv.find_symbol (Clight.globalenv us_viewport_repaired_program)
      us_level_update._warp_level = Some warp_level_block /\
    Genv.find_funct_ptr (Clight.globalenv us_viewport_repaired_program)
      warp_level_block = Some (Internal us_level_update.f_warp_level).
Proof.
  eapply program_definitions_resolve_internal_globalenv.
  - exact us_viewport_repaired_program_definitions_checked.
  - exact us_viewport_repaired_definition_names_norepet.
  - exact us_warp_level_repaired_definition_member.
Qed.
