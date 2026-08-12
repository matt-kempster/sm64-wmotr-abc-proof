(** Fresh syntax/global audit of the actual repaired US selected target. *)

From compcert Require Import Clight.
From LessThanOneAPress.Proofs Require Import
  ClightRefinement SelectedClightTarget
  USRepairedBasicSyntaxAudit USRepairedEvarAudit
  USRepairedInitAddrofAudit USWholeASTTagRepair.

Theorem us_selected_target_syntax_audit_checked :
  forall projection,
    projection_program projection = us_viewport_repaired_program ->
    SelectedTargetSyntaxAuditObligation projection.
Proof.
  intros projection Hprogram. constructor; rewrite Hprogram.
  - exact us_repaired_target_has_no_direct_sbuiltin.
  - exact us_repaired_external_constructors_supported.
  - exact us_repaired_internal_body_evar_resolves.
  - exact us_repaired_init_addrof_identifier_resolves.
Qed.
