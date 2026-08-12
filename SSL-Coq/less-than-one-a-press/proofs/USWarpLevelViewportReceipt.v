(** Focused computation showing that US [f_warp_level] does not mention the
    viewport-wrapper composite tag.  This theorem is isolated because it is
    the only body-sized computation in the repaired-symbol chain. *)

From compcert Require Import AST Clight Ctypes.
From LessThanOneAPress.Generated Require Import us_level_update.
From LessThanOneAPress.Proofs Require Import USWholeASTTagRepair.

Theorem us_warp_level_needs_no_viewport_repair_checked :
  us_selected_definition_needs_viewport_repair
    (us_level_update._warp_level,
      Gfun (Internal us_level_update.f_warp_level)) = false.
Proof. vm_compute. reflexivity. Qed.
